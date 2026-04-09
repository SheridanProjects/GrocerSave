#!/usr/bin/env bash
# Install nginx TLS vhost, Cloudflare Origin cert paths, and systemd port-forward.
# Usage (on the droplet, from repo clone):
#   1. Cloudflare → SSL/TLS → Origin Server → Create certificate. Save PEM contents to:
#        /etc/ssl/cloudflare/grocersave-origin.pem
#        /etc/ssl/cloudflare/grocersave-origin.key   (chmod 640, root:root)
#   2. sudo ./Ops/host-nginx/install-grocersave-droplet.sh demo.yourdomain.com
#
# Cloudflare DNS: proxied A record → this droplet public IP. SSL mode: Full (strict).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DOMAIN="${1:?Usage: sudo $0 <hostname.example.com>}"

CERT_PEM="/etc/ssl/cloudflare/grocersave-origin.pem"
CERT_KEY="/etc/ssl/cloudflare/grocersave-origin.key"

if [[ "${EUID:-0}" -ne 0 ]]; then
  echo "Run with sudo: sudo $0 <hostname>"
  exit 1
fi

if [[ ! -f "${CERT_PEM}" || ! -f "${CERT_KEY}" ]]; then
  echo "Missing Cloudflare Origin certificate files."
  echo "Create them in Cloudflare (SSL/TLS → Origin Server), then write:"
  echo "  ${CERT_PEM}"
  echo "  ${CERT_KEY}"
  exit 1
fi

apt-get update
apt-get install -y nginx

install -d -m 0755 /etc/ssl/cloudflare
chmod 0644 "${CERT_PEM}" 2>/dev/null || true
chmod 0640 "${CERT_KEY}" 2>/dev/null || true

sed "s#@DOMAIN@#${DOMAIN}#g" "${REPO_ROOT}/Ops/host-nginx/grocersave.conf.template" \
  > /etc/nginx/sites-available/grocersave

ln -sf /etc/nginx/sites-available/grocersave /etc/nginx/sites-enabled/grocersave
if [[ -L /etc/nginx/sites-enabled/default ]]; then
  rm -f /etc/nginx/sites-enabled/default
fi

nginx -t
systemctl enable nginx
systemctl reload nginx

ENV_FILE="/etc/default/grocersave-portforward"
cp "${REPO_ROOT}/Ops/systemd/grocersave-portforward.env.example" "${ENV_FILE}"
sed -i "s|^KUBECONFIG=.*|KUBECONFIG=${REPO_ROOT}/Ops/.kubeconfig-localstack|" "${ENV_FILE}"
chmod 644 "${ENV_FILE}"

cp "${REPO_ROOT}/Ops/systemd/grocersave-frontend-portforward.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable grocersave-frontend-portforward.service
systemctl restart grocersave-frontend-portforward.service

echo "Done. Check: systemctl status grocersave-frontend-portforward nginx"
echo "HTTPS: https://${DOMAIN}/"
