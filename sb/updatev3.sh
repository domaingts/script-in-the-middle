#!/bin/sh

version="1.8.2"

curl -LO "https://github.com/SagerNet/sing-box/releases/download/v$version/sing-box-$version-linux-amd64v3.tar.gz"

systemctl stop sing-box

tar xzvf sing-box-$version-linux-amd64v3.tar.gz

rm /usr/bin/sing-box

mv sing-box-$version-linux-amd64v3/sing-box /usr/bin/

sing-box version | tee

systemctl start sing-box

rm -rf sing*