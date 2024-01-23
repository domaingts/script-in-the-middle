#!/bin/bash

version='0'

pre_install() {
  apt install gnupg2 -y
}

get_cpu_version() {
  version="$(cat "/proc/cpuinfo" | grep -oP 'model name.*: \K.*' | head -n 1 | grep -oiP 'v\K[1-4]{1}')"
}

get_version() {
   if [[ $1 -gt 0 ]]; then
    version=$1
  else
    get_cpu_version
  fi
}

install() {
  get_version "$@"
  echo "$version"
  wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg
  echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list
  apt update -y && "apt" "install" "linux-xanmod-x64v$version" "-y"
}

post_install() {
  apt purge -y gnupg2
}

main() {
  pre_install
  install "$@"
  post_install
}

main "$@"
