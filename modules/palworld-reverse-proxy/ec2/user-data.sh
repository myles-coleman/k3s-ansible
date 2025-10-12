#!/bin/bash
set -e

# Log all output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting Palworld reverse proxy setup..."

# Update system FIRST (before Tailscale overwrites DNS)
echo "Updating system packages..."
dnf update -y

# Install socat for UDP forwarding
echo "Installing socat..."
dnf install -y socat

# Update Dynamic DNS BEFORE Tailscale (to avoid DNS issues)
echo "Updating Dynamic DNS for bigbeevpn.mooo.com..."
wget -q --read-timeout=0.0 --waitretry=5 --tries=5 -O /tmp/ddns-update.log \
  "https://freedns.afraid.org/dynamic/update.php?bWpiM0JsbkdvZG81YzJkdENFWlVHNHJUOjIxNzU0MDUx"

if [ $? -eq 0 ]; then
  echo "Dynamic DNS updated successfully"
  cat /tmp/ddns-update.log
else
  echo "Warning: Dynamic DNS update failed, but continuing..."
fi

# Install Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# Start and authenticate Tailscale (disable DNS management to prevent resolv.conf overwrite)
echo "Authenticating Tailscale..."
tailscale up --authkey=${tailscale_auth_key} --hostname=palworld-reverse-proxy --accept-routes --accept-dns=false --advertise-exit-node=false

# Wait for Tailscale to be ready
echo "Waiting for Tailscale to be ready..."
sleep 10

# Auto-discover homelab IP from Tailscale
echo "Discovering homelab IP from Tailscale..."
HOMELAB_IP=$(tailscale status | grep -i homelab | awk '{print $1}')

# Create systemd service for UDP forwarding
echo "Creating systemd service for Palworld proxy..."
cat > /etc/systemd/system/palworld-proxy.service <<EOF
[Unit]
Description=Palworld UDP Reverse Proxy
After=network.target tailscaled.service
Wants=tailscaled.service

[Service]
Type=simple
ExecStart=/usr/bin/socat -d -d UDP4-LISTEN:8211,fork,reuseaddr UDP4:$HOMELAB_IP:8211
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
echo "Starting Palworld proxy service..."
systemctl daemon-reload
systemctl enable palworld-proxy.service
systemctl start palworld-proxy.service

# Verify service status
echo "Checking service status..."
systemctl status palworld-proxy.service --no-pager

echo "Palworld reverse proxy setup complete!"
echo "Instance is now forwarding UDP port 8211 to $HOMELAB_IP:8211"
echo "Homelab discovered via Tailscale: $HOMELAB_IP"
