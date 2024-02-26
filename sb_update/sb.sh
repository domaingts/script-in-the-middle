#!/bin/bash

TEMPD=""

action='0'

architect='0'

get_cpu_version() {
  cpu_version="$(cat "/proc/cpuinfo" | grep -oP 'model name.*: \K.*' | head -n 1 | grep -oiP 'v\K[1-4]{1}')"
  if [[ $cpu_version -ge 3 ]]; then
    architect=1
  elif [[ -n $(cat "/proc/cpuinfo" | grep -oP 'model name.*: \K.*' | head -n 1 | grep -oiP 'amd') ]]; then
    architect=1
  else
    architect=0
  fi
}

pre_update() {
  TEMPD="$(mktemp -d)"
  local temp_file
  temp_file="$(mktemp)"
  if ! curl -sS -H "Accept: application/vnd.github.v3+json" -o "$temp_file" 'https://api.github.com/repos/SagerNet/sing-box/releases'; then
    "rm" "$temp_file"
    echo 'error: Failed to get release list, please check your network.'
  fi
  local releases_list
  releases_list="$(sed 'y/,/\n/' "$temp_file" | grep 'tag_name' | awk -F '"' '{print $4}')"
  "rm" "$temp_file"
 
  version="${releases_list[0]#v}"
  "echo" "${releases_list[0]}"
  "echo" "$version"
  get_cpu_version
  if [[ $architect == 1 ]]; then
    package="sing-box-$version-linux-amd64v3"
  else
    package="sing-box-$version-linux-amd64"
  fi
  curl -L "https://github.com/SagerNet/sing-box/releases/download/v$version/$package.tar.gz" -o "$TEMPD/$package.tar.gz"
  tar Cxzvf "$TEMPD" "$TEMPD/$package.tar.gz"
  location="$TEMPD/${package}/sing-box"

  mv "$location" /usr/bin/
  sing-box version | tee
}

update_sing_box_to_pre_release() {
  systemctl stop sing-box
  pre_update
  systemctl start sing-box
}

rm_all() {
  "rm" "-rf" "$TEMPD"
}

main() {
    update_sing_box_to_pre_release
    rm_all
}

main
