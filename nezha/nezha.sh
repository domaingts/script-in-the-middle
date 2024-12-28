#!/bin/bash

add_systemd() {
  cat >/etc/systemd/system/nezha-agent.service <<EOF
[Unit]
Description=Nezha Agent
ConditionFileIsExecutable=/opt/nezha/agent/nezha-agent
After=network.target nss-lookup.target network-online.target

[Service]
User=nezha
Group=nezha
ProtectHome=yes
NoNewPrivileges=true
PrivateTmp=true
StartLimitInterval=5
StartLimitBurst=10
ExecStart=/opt/nezha/agent/nezha-agent
WorkingDirectory=/opt/nezha/agent
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
}

add_user() {
  useradd --no-create-home --shell /bin/false nezha
}

add_configuration() {
  mkdir -p /opt/nezha/agent
  cat >/opt/nezha/agent/config.yml <<EOF
client_secret: $1
debug: false
disable_auto_update: true
disable_command_execute: true
disable_force_update: true
disable_nat: true
disable_send_query: false
gpu: false
insecure_tls: false
ip_report_period: 1800
report_delay: 2
server: $2
skip_connection_count: false
skip_procs_count: false
temperature: false
tls: true
use_gitee_to_upgrade: false
use_ipv6_country_code: false
uuid: 
EOF
}

main() {
  add_configuration $1 $2
  add_user
  add_systemd
}

main $1 $2