##!/bin/sh

set -e

mkdir -p /etc/caddy

echo -n >/etc/caddy/Caddyfile

# Configure redsocks if SOCKS5 proxy is defined
if [ -n "${SOCKS5H_HOST:-}" ]; then
  : "${SOCKS5H_PORT:=1080}"
  : "${SOCKS5H_USER:=}"
  : "${SOCKS5H_PASSWORD:=}"

  echo "[+] Configuring redsocks for SOCKS5 proxy ${SOCKS5H_HOST}:${SOCKS5H_PORT}"

  cat <<EOF >/etc/redsocks.conf
base {
  log_debug = off;
  log_info = on;
  daemon = on;
  redirector = iptables;
}
redsocks {
  local_ip = 127.0.0.1;
  local_port = 12345;
  ip = ${SOCKS5H_HOST};
  port = ${SOCKS5H_PORT};
  type = socks5;
  login = "${SOCKS5H_USER}";
  password = "${SOCKS5H_PASSWORD}";
}
EOF

  redsocks -c /etc/redsocks.conf &

  iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-ports 12345
  iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDIRECT --to-ports 12345
else
  echo "[ ] SOCKS5 proxy is not set — Caddy will connect directly"
fi

# --- Keycloak ---
if [ -n "$KEYCLOAK_APP_HOSTNAME" ]; then
    echo "[+] Generating config for Keycloak"
    echo "# Auto-generated Keycloak config" >>/etc/caddy/Caddyfile

    export KEYCLOAK_APP_HOST="${KEYCLOAK_APP_HOST:-keycloak-app}"
    export KEYCLOAK_APP_HTTP_PORT="${KEYCLOAK_APP_HTTP_PORT:-8080}"

    {
        echo "${KEYCLOAK_APP_HOSTNAME} {"
        echo "    reverse_proxy ${KEYCLOAK_APP_HOST}:${KEYCLOAK_APP_HTTP_PORT}"
        echo "}"
    } >>/etc/caddy/Caddyfile
    echo "" >>/etc/caddy/Caddyfile
else
    echo "[ ] Skipping Keycloak — KEYCLOAK_APP_HOSTNAME is not set"
fi

# --- Firefly ---
if [ -n "$FIREFLY_APP_HOSTNAME" ]; then
    echo "[+] Generating config for Firefly"
    echo "# Auto-generated Firefly config" >>/etc/caddy/Caddyfile

    export FIREFLY_APP_HOST="${FIREFLY_APP_HOST:-firefly-app}"
    export FIREFLY_APP_HTTP_PORT="${FIREFLY_APP_HTTP_PORT:-8080}"

    {
        echo "${FIREFLY_APP_HOSTNAME} {"
        echo "    reverse_proxy ${FIREFLY_APP_HOST}:${FIREFLY_APP_HTTP_PORT}"
        echo "}"
    } >>/etc/caddy/Caddyfile
    echo "" >>/etc/caddy/Caddyfile
else
    echo "[ ] Skipping Firefly — FIREFLY_APP_HOSTNAME is not set"
fi

# --- Wekan ---
if [ -n "$WEKAN_APP_HOSTNAME" ]; then
    echo "[+] Generating config for Wekan"
    echo "# Auto-generated Wekan config" >>/etc/caddy/Caddyfile

    export WEKAN_APP_HOST="${WEKAN_APP_HOST:-wekan-app}"
    export WEKAN_APP_HTTP_PORT="${WEKAN_APP_HTTP_PORT:-8080}"

    {
        echo "${WEKAN_APP_HOSTNAME} {"
        echo "    reverse_proxy ${WEKAN_APP_HOST}:${WEKAN_APP_HTTP_PORT}"
        echo "}"
    } >>/etc/caddy/Caddyfile
    echo "" >>/etc/caddy/Caddyfile
else
    echo "[ ] Skipping Wekan — WEKAN_APP_HOSTNAME is not set"
fi

# --- Outline ---
if [ -n "$OUTLINE_APP_HOSTNAME" ]; then
    echo "[+] Generating config for Outline"
    echo "# Auto-generated Outline config" >>/etc/caddy/Caddyfile

    export OUTLINE_APP_HOST="${OUTLINE_APP_HOST:-127.0.0.1}"
    export OUTLINE_APP_PORT="${OUTLINE_APP_PORT:-3000}"

    {
        echo "http://${OUTLINE_APP_HOSTNAME} {"
        echo "    reverse_proxy ${OUTLINE_APP_HOST}:${OUTLINE_APP_PORT}"
        echo "}"
    } >>/etc/caddy/Caddyfile
    echo "" >>/etc/caddy/Caddyfile
else
    echo "[ ] Skipping Outline — OUTLINE_APP_HOSTNAME is not set"
fi

if [ ! -s /etc/caddy/Caddyfile ]; then
    echo "[i] No services enabled, using default response"
    echo "# Default response auto-generated config" >>/etc/caddy/Caddyfile
    {
        echo ":80 {"
        echo "    respond \"Caddy is running, but no services are configured.\" 200"
        echo "}"
    } >>/etc/caddy/Caddyfile
fi

echo "[✓] Final Caddyfile generated:"
cat /etc/caddy/Caddyfile

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
