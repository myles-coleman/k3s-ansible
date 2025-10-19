#!/bin/bash
# User data script for multi-game reverse proxy
# This template is populated by Terraform with game configurations

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting multi-game reverse proxy setup..."

# Update system FIRST (before Tailscale overwrites DNS)
echo "Updating system packages..."
dnf update -y

# Install socat for UDP/TCP forwarding
echo "Installing socat..."
dnf install -y socat

# Update Dynamic DNS BEFORE Tailscale (to avoid DNS issues)
echo "Updating Dynamic DNS for bigcowgames.mooo.com..."
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
# Use --force-reauth to handle ephemeral nodes that were deleted when instance stopped
echo "Authenticating Tailscale..."
tailscale up --authkey=${tailscale_auth_key} --hostname=${hostname} --accept-routes --accept-dns=false --advertise-exit-node=false --force-reauth

# Wait for Tailscale to be ready
echo "Waiting for Tailscale to be ready..."
sleep 10

# Auto-discover homelab IP from Tailscale with fallback
echo "Discovering homelab IP from Tailscale..."
HOMELAB_IP=$(tailscale status | grep -i ${homelab_hostname} | awk '{print $1}')

if [ -z "$HOMELAB_IP" ]; then
  echo "WARNING: Could not auto-discover homelab IP, using fallback: ${homelab_fallback_ip}"
  HOMELAB_IP="${homelab_fallback_ip}"
else
  echo "Found homelab at IP: $HOMELAB_IP"
fi

# Create systemd services for each game
${game_services}

# Note: Firewall rules are managed by AWS Security Groups
# No need for host-based firewall configuration

# Verify service status
echo "Checking service status..."
${service_status_checks}

echo "Multi-game reverse proxy setup complete!"
echo "Enabled games: ${game_names}"
echo "All traffic forwarding to homelab: $HOMELAB_IP"
