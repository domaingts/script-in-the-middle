#!/bin/sh

version="1.8.2"

curl -LO "https://github.com/SagerNet/sing-box/releases/download/v1.8.2/sing-box_$version_linux_amd64v3.deb"

dpkg -i sing-box_$version_linux_amd64v3.deb

rm sing-box_$version_linux_amd64v3.deb