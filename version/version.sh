#!/bin/bash

kernel_version="$(cat "/proc/cpuinfo" | grep -oP 'model name.*: \K.*' | head -n 1 | grep -oiP 'v\K[1-4]{1}')"

echo "$kernel_version"

if [[ $kernel_version == 2 ]]; then
    echo "2"
elif [[ $kernel_version == 4 ]]; then
    echo "4"
else
    echo "3"
fi