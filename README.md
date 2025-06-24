# Caddy Reverse Proxy Docker Compose Deployment

This repository contains a Docker Compose configuration for deploying the Caddy reverse proxy to manage multiple backend services securely.

## Setup Instructions

### 1. Clone the Repository

Clone the project to your server in the `/docker/caddy/` directory:

```
mkdir -p /docker/caddy
cd /docker/caddy
git clone https://github.com/jordimock/docker-compose-caddy.git .
```

### 2. Review Docker Compose Configuration

Key service:

- `caddy`: A lightweight, extensible web server acting as a reverse proxy with automatic HTTPS.

The Caddy container is connected to the `caddy-universe` network for public access. Additional networks (e.g., `caddy-outline`, `caddy-git`) can be attached for private communication with backend services.

**Create the shared Docker network** (if it doesn't already exist):

   ```bash
   docker network create --driver bridge caddy-keycloak
   ```


### 3. Configure Caddyfile

The Caddyfile `./vol/caddy/etc/caddy/Caddyfile` is dynamically generated using the environment variables.

To configure and launch all required services, run the provided script:

```bash
./tools/init.bash
```

The script will:

- Prompt you to enter configuration values (press `Enter` to accept defaults).
- Generate secure random secrets automatically.
- Save all settings to the `.env` file located at the project root.

**Important:**  
Make sure to securely store your `.env` file locally for future reference or redeployment.


### 4. Start the Caddy Service

```
docker compose up -d
```

This will start Caddy and make your configured domains available.

### 5. Verify Running Containers

```
docker compose ps
```

You should see the `caddy` container running.

### 6. Persistent Data Storage

Caddy stores ACME certificates, account keys, and other important data in the following volumes:

- `./vol/caddy/data:/data` – ACME certificates and keys
- `./vol/caddy/config:/config` – Runtime configuration and state

Make sure these directories are backed up to avoid losing certificates and configuration.

---

### Example Directory Structure

```
/docker/caddy/
├── docker-compose.yml
├── vol/
│   └── caddy/
│       ├── data/
│       ├── config/
│       └── etc/
│           └── caddy/
│               └── Caddyfile
```

