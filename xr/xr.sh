#!/bin/bash

TEMPD=""

action='0'

architect='0'

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
  *)
    echo "$0: unknow parameters"
    exit 1
    ;;
  esac
}

add_systemd() {
  cat >/etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=bypass
Group=bypass
ProtectHome=yes
NoNewPrivileges=true
PrivateTmp=true
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
MemoryMax=256M
StartLimitInterval=10
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF
}

add_configuration() {
  mkdir -p /usr/local/etc/xray
  port=$((($RANDOM % 30000) + 5000))
  "echo" "$port"
  cat <<EOF >/usr/local/etc/xray/config.json
{
  "log": {
    "loglevel": "warning",
    "maskAddress": "quarter"
  },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": $port,
      "protocol": "vless",
      "tag": "",
      "settings": {
        "clients": [
          {
            "id": "",
            "email": "",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "target": "",
          "serverNames": [
            ""
          ],
          "privateKey": "",
          "shortIds": [
            ""
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct",
      "settings": {
        "domainStrategy": "UseIPv4v6"
      }
    },
    {
      "protocol": "blackhole",
      "tag": "block"
    }
  ],
  "routing": {
    "rules": [
      {
        "domain": [
          "geosite:category-ads-all"
        ],
        "outboundTag": "block"
      },
      {
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "block"
      },
      {
        "source": [
          "geoip:cn"
        ],
        "outboundTag": "block"
      }
    ]
  },
  "dns": {
    "servers": [
      "https://1.1.1.1/dns-query"
    ]
  }
}
EOF
}

uninstall() {
  systemctl stop xray && systemctl disable xray
  rm -rf /usr/local/etc/xray /usr/local/share/xray /usr/local/bin/xray /etc/systemd/system/xray.service
}

add_user() {
  useradd --no-create-home --shell /bin/false bypass
  mkdir -p /usr/local/share
  curl -L https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/202512122214/geosite.dat -o /usr/local/share/geosite.dat
  curl -L https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/202512122214/geoip.dat -o /usr/local/share/geoip.dat
}

common() {
  TEMPD="$(mktemp -d)"
  local temp_file
  temp_file="$(mktemp)"
  if ! curl -sS -H "Accept: application/vnd.github.v3+json" -o "$temp_file" 'https://api.github.com/repos/domaingts/alice/releases/latest'; then
    "rm" "$temp_file"
    echo 'error: Failed to get release list, please check your network.'
  fi
  version="$(sed 'y/,/\n/' "$temp_file" | grep 'tag_name' | awk -F '"' '{print $4}')"
  version="${version#v}"
  package="xray-linux-amd64-v3"

  curl -L "https://github.com/domaingts/alice/releases/download/v$version/$package.tar.gz" -o "$TEMPD/$package.tar.gz"
  tar Cxzvf "/usr/local/bin" "$TEMPD/$package.tar.gz"
  xray version | tee
}

add_xray() {
  add_configuration
  add_user
  common
}

update_xray() {
  common
  systemctl restart xray
}

rm_all() {
  "rm" "-rf" "$TEMPD"
}

main() {
  judgement_parameters "$@"

  if [[ "$action" -eq '1' ]]; then
    uninstall
    add_systemd
    add_xray
    rm_all
  elif [[ "$action" -eq '2' ]]; then
    uninstall
  elif [[ "$action" -eq '3' ]]; then
    update_xray
    rm_all
  fi
}

main "$@"
