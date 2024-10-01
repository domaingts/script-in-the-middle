#!/bin/bash

function main() {
    curl -LO https://github.com/domaingts/gurl/releases/download/v0.0.1/gurl.tar.gz
    tar xzvf gurl.tar.gz
    mv gurl /usr/local/bin
    rm gurl.tar.gz
}

main