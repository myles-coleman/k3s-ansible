#!/bin/bash
# Generate user-data script from games.yaml template
# This script is called by Terragrunt to create the final user-data.sh

set -e

GAMES_YAML="$1"
TEMPLATE_FILE="$2"
OUTPUT_FILE="$3"

if [ -z "$GAMES_YAML" ] || [ -z "$TEMPLATE_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 <games.yaml> <template.sh> <output.sh>"
    exit 1
fi

# Read games from YAML and generate socat services
python3 - <<EOF
import yaml
import sys

with open('${GAMES_YAML}', 'r') as f:
    config = yaml.safe_load(f)

enabled_games = [g for g in config['games'] if g.get('enabled', False)]

# Generate socat service definitions
services = []
for game in enabled_games:
    name = game['name']
    port = game['port']
    protocol = game['protocol'].upper()
    description = game['description']
    
    # Determine socat protocol
    if protocol == 'UDP':
        socat_proto = 'UDP4'
    elif protocol == 'TCP':
        socat_proto = 'TCP4'
    else:
        print(f"Unknown protocol: {protocol}", file=sys.stderr)
        continue
    
    service = f'''
# Create systemd service for {name} proxy
echo "Creating systemd service for {name} proxy..."
cat > /etc/systemd/system/{name}-proxy.service <<'SERVICE_EOF'
[Unit]
Description={description} Reverse Proxy
After=network.target tailscaled.service
Wants=tailscaled.service

[Service]
Type=simple
ExecStart=/usr/bin/socat -d -d {socat_proto}-LISTEN:{port},fork,reuseaddr {socat_proto}:\$HOMELAB_IP:{port}
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE_EOF

systemctl daemon-reload
systemctl enable {name}-proxy.service
systemctl start {name}-proxy.service
'''
    services.append(service)

# Output the services section
print(''.join(services))
EOF
