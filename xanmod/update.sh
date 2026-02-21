#!/bin/bash

apt install -y jq

curl "https://api.github.com/repos/domaingts/kernel-build/releases/latest" | jq -r '.assets | .[-2:] | .[].browser_download_url' | while read -r url; do
    curl -LO "$url"
done

dpkg -i linux-image-*xanmod*.deb linux-headers-*xanmod*.deb

rm linux-image-*xanmod*.deb linux-headers-*xanmod*.deb
