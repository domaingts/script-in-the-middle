#!/bin/bash

password=""

password_generate() {
  length=$((($RANDOM % 5) + 25))
  password="$(tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c $length)"
}

dd() {
  wget --no-check-certificate -qO InstallNET.sh 'https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh' \
  && chmod a+x InstallNET.sh \
  && "bash" "InstallNET.sh" "-debian" "12" "-pwd" "$password" "--bbr"
}

print() {
  "echo" "$password"
}

main() {
  password_generate
  dd
  print
}

main
