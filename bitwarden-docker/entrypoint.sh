#!/bin/bash
set -e

BW_CLIENTID=$(echo -n "$BW_CLIENTID" | tr -d '\n\r')
BW_CLIENTSECRET=$(echo -n "$BW_CLIENTSECRET" | tr -d '\n\r')
BW_PASSWORD=$(echo -n "$BW_PASSWORD" | tr -d '\n\r')

bw config server ${BW_HOST}
bw login --apikey
export BW_SESSION=$(bw unlock "${BW_PASSWORD}" --raw)
bw unlock --check
echo 'Running `bw server` on port 8087'
bw serve --hostname 0.0.0.0
