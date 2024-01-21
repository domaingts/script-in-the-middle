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
  tar xzvf "$TEMPD/$package.tar.gz"
  location="$TEMPD/${package}/sing-box"

  mv "$location" /usr/bin/
  sing-box version | tee
}

add_sing_box_v3() {
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
    rm /usr/bin/sing-box /etc/systemd/system/sing-box.service
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
