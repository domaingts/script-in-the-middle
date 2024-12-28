# script-in-the-middle

## download docker
curl -fsSL https://get.docker.com -o get-docker.sh | sh -

## download docker compose file
curl -fsSL -o docker-compose.yaml https://raw.githubusercontent.com/domaingts/script-in-the-middle/main/docker/docker-test.yaml

## download sb
bash -c "$(curl -sSL https://raw.githubusercontent.com/domaingts/script-in-the-middle/main/sb/sing-box.sh)" @ install

## download xr
bash -c "$(curl -sSL https://raw.githubusercontent.com/domaingts/script-in-the-middle/main/xr/install-release.sh)" @ install

## dd your vps
bash <(curl -sSL https://raw.githubusercontent.com/domaingts/script-in-the-middle/main/dd/dd.sh)

## download realm
bash <(curl -sSL https://raw.githubusercontent.com/domaingts/script-in-the-middle/main/realm/realm.sh)

## download gurl
bash <(curl -sSL https://raw.githubusercontent.com/domaingts/script-in-the-middle/refs/heads/main/gurl/install.sh)

## download xanmoad kernel
bash -c "$(curl -sSL https://raw.githubusercontent.com/domaingts/script-in-the-middle/refs/heads/main/xanmod/install.sh)" @domaingts

## add optimizing parameters
bash <(cur -sSL https://raw.githubusercontent.com/domaingts/script-in-the-middle/refs/heads/main/xanmod/optimizing.sh)
