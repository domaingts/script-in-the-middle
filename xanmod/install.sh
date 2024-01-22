#!/bin/bash

version='0'

pre_install() {
  apt install gnupg2 -y
}

install() {
  if [[ -z $1 ]]; then
    echo "$0: unknow parameters"
    exit 1
  else
    wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg
    echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list
    apt update -y && "apt" "install" "linux-xanmod-x64v$1" "-y"
  fi
}

post_install() {
  apt purge -y gpg
}

main() {
  pre_install
  install "$@"
  post_install
}

main "$@"
