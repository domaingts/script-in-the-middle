#!/bin/bash

version='0'

pre_install() {
  apt install gnupg2 -y
}

get_cpu_version() {
  cpu_version="$(cat "/proc/cpuinfo" | grep -oP 'model name.*: \K.*' | head -n 1 | grep -oiP 'v\K[1-4]{1}')"
  if [[ $cpu_version -ge 2 ]]; then
    version=$cpu_version
  elif [[ -n $(cat "/proc/cpuinfo" | grep -oP 'model name.*: \K.*' | head -n 1 | grep -oiP 'amd') ]]; then
    version=3
  else
    version=2
  fi
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
  wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -vo /etc/apt/keyrings/xanmod-archive-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list
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
