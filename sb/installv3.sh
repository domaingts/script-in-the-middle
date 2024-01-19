#!/bin/sh

version="1.8.2"

package="sing-box_${version}_linux_amd64v3.deb"

curl -LO "https://github.com/SagerNet/sing-box/releases/download/v$version/$package"

dpkg -i "$package"

rm "$package"