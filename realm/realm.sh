#!/bin/bash

TEMPD=""

add_systemd() {
  cat >/etc/systemd/system/realm.service <<EOF
[Unit]
Description=realm service
After=network.target nss-lookup.target network-online.target

[Service]
User=bypass
Group=bypass
ProtectHome=yes
NoNewPrivileges=true
PrivateTmp=true
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
ExecStart=/usr/bin/realm -c /etc/realm/config.toml
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF
}

add_configuration() {
  mkdir -p /etc/realm
  cat <<EOF >/etc/realm/config.toml
[log]
level = "info"
output = "/etc/realm/output.log"

[network]
no_tcp = false
use_udp = true

[[endpoints]]
listen = "0.0.0.0:999"
remote = "[::1]:1000"
EOF
}

download() {
    TEMPD="$(mktemp -d)"
    local temp_file
    temp_file="$(mktemp)"
    if ! curl -sS -H "Accept: application/vnd.github.v3+json" -o "$temp_file" 'https://api.github.com/repos/domaingts/realm/releases/latest'; then
        "rm" "$temp_file"
        echo 'error: Failed to get release list, please check your network.'
    fi
    version="$(sed 'y/,/\n/' "$temp_file" | grep 'tag_name' | awk -F '"' '{print $4}')"
    "rm" "$temp_file"
    local package="realm-x86_64-unknown-linux-gnu.tar.gz"
    curl -L "https://github.com/domaingts/realm/releases/download/$version/$package" -o "$TEMPD/$package"
    tar Cxzvf "$TEMPD" "$TEMPD/$package"
    location="$TEMPD/realm"
    mv "$location" /usr/bin/
    realm -v | tee
    "rm" "-rf" "$TEMPD"
}

main() {
    add_systemd
    add_configuration
    download
}

main
