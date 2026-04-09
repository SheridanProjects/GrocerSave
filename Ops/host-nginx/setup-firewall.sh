#!/usr/bin/env bash
# Can forego running this script if you have a firewall already in place.
# Open HTTP/HTTPS for host nginx. Run on the droplet: sudo ./setup-firewall.sh
# Prerequisites (manual): In Cloudflare DNS, create a proxied A record for your demo
# hostname pointing to this server's public IPv4 address.

set -euo pipefail

if [[ "${EUID:-0}" -ne 0 ]]; then
  echo "Run with sudo: sudo $0"
  exit 1
fi

if ! command -v ufw >/dev/null 2>&1; then
  apt-get update
  apt-get install -y ufw
fi

ufw allow OpenSSH comment 'SSH'
ufw allow 80/tcp comment 'HTTP nginx'
ufw allow 443/tcp comment 'HTTPS nginx'
echo "Enabling ufw (default deny incoming)..."
ufw --force enable
ufw status verbose
