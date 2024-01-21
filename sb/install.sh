#!/bin/sh

version="1.8.2"

package="sing-box-$version-linux-amd64v3"

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

add_sing_box_v3() {
    curl -LO "https://github.com/SagerNet/sing-box/releases/download/v$version/$package.tar.gz"
    tar xzvf "$package.tar.gz"
    location="${package}/sing-box"

    mv "$location" /usr/bin/
    sing-box version | tee
}

rm_all() {
  rm -rf sing-box*
}

main() {
  add_systemd

  add_sing_box_v3

  rm_all
}

main