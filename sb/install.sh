#!/bin/bash

TEMPD=""

action='0'

judgement_parameters() {
  case "$1" in
  'install')
    action='1'
    ;;
  'uninstall')
    action='2'
    ;;
  'update')
    action='3'
    ;;
  'log')
    action='4'
    ;;
  'clear')
    action='5'
    ;;
  *)
    echo "$0: unknow parameters"
    exit 1
    ;;
  esac
}

add_systemd() {
  cat >/etc/systemd/system/sing-box.service <<EOF
[Unit]
Description=sing-box service
Documentation=https://sing-box.sagernet.org
After=network.target nss-lookup.target network-online.target

[Service]
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
ExecStart=/usr/bin/sing-box -D /var/lib/sing-box -C /etc/sing-box run
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF
}

add_configuration() {
  mkdir -p /etc/sing-box
  pwd="$(openssl rand -base64 32)"
  port=" $((($RANDOM % 30000) + 1000))"
  "echo" "$pwd" "$port"
  cat << EOF > /etc/sing-box/config.json
{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "cloudflare",
        "address": "https://1.1.1.1/dns-query"
      }
    ]
  },
  "inbounds": [
    {
      "type": "shadowsocks",
      "tag": "ss-in",
      "listen": "::1",
      "listen_port": "$port",
      "network": "tcp",
      "method": "2022-blake3-chacha20-poly1305",
      "password": "$pwd"
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "dns",
      "tag": "dns-out"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      },
      {
        "rule_set": [
          "geosite-play"
        ],
        "outbound": "direct"
      },
      {
        "ip_is_private": true,
        "rule_set": [
          "geoip-cn",
          "geosite-cn",
          "geosite-block",
          "geosite-ads"
        ],
        "rule_set_ipcidr_match_source": true,
        "outbound": "block"
      }
    ],
    "rule_set": [
      {
        "tag": "geoip-cn",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs"
      },
      {
        "tag": "geosite-cn",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs"
      },
      {
        "tag": "geosite-ads",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ads-all.srs"
      },
      {
        "tag": "geosite-play",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/domaingts/script-in-the-middle/rules/play.rule"
      },
      {
        "tag": "geosite-block",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/domaingts/script-in-the-middle/rules/block.rule"
      }
    ],
    "final": "direct"
  },
  "experimental": {
    "cache_file": {
      "enabled": true
    }
  }
}
EOF
}

common() {
  TEMPD="$(mktemp -d)"
  "echo" "$TEMPD"
  local temp_file
  temp_file="$(mktemp)"
  if ! curl -sS -H "Accept: application/vnd.github.v3+json" -o "$temp_file" 'https://api.github.com/repos/SagerNet/sing-box/releases/latest'; then
    "rm" "$temp_file"
     echo 'error: Failed to get release list, please check your network.'
  fi
  version="$(sed 'y/,/\n/' "$temp_file" | grep 'tag_name' | awk -F '"' '{print $4}')"
  "rm" "$temp_file"
  version="${version#v}"
  package="sing-box-$version-linux-amd64v3"
  curl -L "https://github.com/SagerNet/sing-box/releases/download/v$version/$package.tar.gz" -o "$TEMPD/$package.tar.gz"
  tar Cxzvf "$TEMPD" "$TEMPD/$package.tar.gz"
  location="$TEMPD/${package}/sing-box"

  mv "$location" /usr/bin/
  sing-box version | tee
}

add_sing_box_v3() {
  add_configuration
  common
}

update_sing_box_v3() {
  systemctl stop sing-box
  common
  systemctl start sing-box
}

rm_all() {
  "rm" "-rf" "$TEMPD"
}

main() {
  judgement_parameters "$@"

  if [[ "$action" -eq '1' ]]; then
    add_systemd
    add_sing_box_v3
    rm_all
  elif [[ "$action" -eq '2' ]]; then
    systemctl stop sing-box && systemctl disable sing-box
    rm -rf /etc/sing-box /usr/bin/sing-box /etc/systemd/system/sing-box.service
  elif [[ "$action" -eq '3' ]]; then
    update_sing_box_v3
    rm_all
  elif [[ "$action" -eq '4' ]]; then
    journalctl -fu sing-box -o cat
  elif [[ "$action" -eq '5' ]]; then
    journalctl --rotate && journalctl --vacuum-time=1s
  fi
}

main "$@"
