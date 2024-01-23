#!/bin/bash

kernel_version=''

get_version() {
  kernel_version="$(cat "/proc/cpuinfo" | grep -oP 'model name.*: \K.*' | head -n 1 | grep -oiP 'v\K[1-4]{1}')"
}

do_something() {
  if [[ $kernel_version == 2 ]]; then
    echo "2"
  elif [[ $kernel_version == 4 ]]; then
    echo "4"
  else
    echo "3"
  fi
}

main() {
  if [[ $1 -gt 0 ]]; then
    kernel_version=$1
  else
    get_version
  fi
  do_something
}

main "$1"