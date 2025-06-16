#!/bin/sh

set -e

mkdir -p /etc/caddy

echo -n >/etc/caddy/Caddyfile

# --- Keycloak ---
if [ -n "$KEYCLOAK_APP_HOSTNAME" ]; then
    echo "[+] Generating config for Keycloak"
    echo "# Auto-generated Keycloak config" >>/etc/caddy/Caddyfile

    export KEYCLOAK_APP_HOST="${KEYCLOAK_APP_HOST:-127.0.0.1}"
    export KEYCLOAK_APP_HTTP_PORT="${KEYCLOAK_APP_HTTP_PORT:-8080}"
    export KEYCLOAK_APP_HTTPS_PORT="${KEYCLOAK_APP_HTTPS_PORT:-8443}"

    envsubst '${KEYCLOAK_APP_HOSTNAME} ${KEYCLOAK_APP_HOST} ${KEYCLOAK_APP_HTTP_PORT} ${KEYCLOAK_APP_HTTPS_PORT}' </conf.d/keycloak.conf >>/etc/caddy/Caddyfile
    echo "" >>/etc/caddy/Caddyfile
else
    echo "[ ] Skipping Keycloak — KEYCLOAK_APP_HOSTNAME is not set"
fi

# --- Outline example ---
if [ -n "$OUTLINE_APP_HOSTNAME" ]; then
    echo "[+] Generating config for Outline"
    echo "# Auto-generated Outline config" >>/etc/caddy/Caddyfile

    export OUTLINE_APP_HOST="${OUTLINE_APP_HOST:-127.0.0.1}"
    export OUTLINE_APP_PORT="${OUTLINE_APP_PORT:-3000}"

    envsubst '${OUTLINE_APP_HOSTNAME} ${OUTLINE_APP_HOST} ${OUTLINE_APP_PORT}' </conf.d/outline.conf >>/etc/caddy/Caddyfile
    echo "" >>/etc/caddy/Caddyfile
else
    echo "[ ] Skipping Outline — OUTLINE_APP_HOSTNAME is not set"
fi

if [ ! -s /etc/caddy/Caddyfile ]; then
    echo "[i] No services enabled, using default response"
    echo "# Default response auto-generated config" >>/etc/caddy/Caddyfile
    {
        echo ":80 {"
        echo "    respond "Caddy is running, but no services are configured." 200"
        echo "}"
    } >/etc/caddy/Caddyfile
fi

echo "[✓] Final Caddyfile generated:"
cat /etc/caddy/Caddyfile
