#!/bin/bash

function pre_install() {
  apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring -y
}

function install() {
  curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
  gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg | tee
  echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/debian $(lsb_release -cs) nginx" | tee /etc/apt/sources.list.d/nginx.list
  "echo" "-e" "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/99nginx
}

function post_install() {
  apt update -y && apt install nginx -y
}

function main() {
  pre_install
  install
  post_install
}

main