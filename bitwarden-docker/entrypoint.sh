#!/bin/bash
set -e

# Clean environment variables of any extra characters
BW_CLIENTID=$(echo -n "$BW_CLIENTID" | tr -d '\n\r')
BW_CLIENTSECRET=$(echo -n "$BW_CLIENTSECRET" | tr -d '\n\r')
BW_PASSWORD=$(echo -n "$BW_PASSWORD" | tr -d '\n\r')

bw config server ${BW_HOST}
bw login --apikey
export BW_SESSION=$(bw unlock "${BW_PASSWORD}" --raw)

# Function to refresh the session
refresh_session() {
  while true; do
    sleep 1800
    echo "Refreshing Bitwarden session"
    export BW_SESSION=$(bw unlock "${BW_PASSWORD}" --raw)
    bw sync
    echo "Session refreshed at $(date)"
  done
}

# Start the refresh process in the background and store the PID
refresh_session &
REFRESH_PID=$!

trap "kill $REFRESH_PID; exit" SIGTERM SIGINT

bw unlock --check
echo 'Running `bw server` on port 8087'
bw serve --hostname 0.0.0.0
