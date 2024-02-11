#!/bin/sh

cni_version="1.4.0"
nerd_version="1.7.3"
cni_file="cni-plugins-linux-amd64-v$cni_version.tgz"
nerd_file="nerdctl-$nerd_version-linux-amd64.tar.gz"
cni="https://github.com/containernetworking/plugins/releases/download/v$cni_version/$cni_file"
nerd="https://github.com/containerd/nerdctl/releases/download/v$nerd_version/$nerd_file"

curl -sSLO "$cni"

mkdir -p /opt/cni/bin && mkdir -p /home/nerdctl

tar Cxzvf /opt/cni/bin "$cni_file"

curl -sSLO "$nerd"

tar Cxzvf /usr/local/bin "$nerd_file"

rm "$cni_file" "$nerd_file"

apt install -y containerd
