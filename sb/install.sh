#!/bin/bash

version="1.8.2"

package="sing-box-$version-linux-amd64v3"

action='0'

judgement_parameters() {
    case "$2" in
      'install')
        action='1'
        ;;
      'remove')
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
    cat > /etc/systemd/system/sing-box.service << EOF
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

common() {
    curl -LO "https://github.com/SagerNet/sing-box/releases/download/v$version/$package.tar.gz"
    tar xzvf "$package.tar.gz"
    location="${package}/sing-box"

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
  rm -rf sing-box*
}

main() {
  judgement_parameters "$@"

  if [[ "$action" -eq '1' ]]; then
    add_systemd
    add_sing_box_v3
    rm_all
  elif [[ "$action" -eq '2' ]]; then
    rm /usr/bin/sing-box /etc/systemd/system/sing-box.service
  elif [[ "action" -eq '3' ]]; then
    update_sing_box_v3
    rm_all
  fi
}

main "$@"