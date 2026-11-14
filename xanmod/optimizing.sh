main() {
    cat >> /etc/sysctl.d/99-custom.conf << EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
fs.file-max=2097152
EOF

    sysctl --system
}

main
