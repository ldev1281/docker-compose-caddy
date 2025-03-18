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

### 3. Create Docker Networks

Before starting the Caddy service, create the required Docker networks. Example:

```
docker network create --driver bridge caddy-universe
```

For backend services, you may create additional isolated networks:

```
docker network create --internal --driver bridge caddy-outline
```

### 4. Configure Caddyfile

The Caddyfile is located at `./vol/caddy/etc/caddy/Caddyfile`.

#### Example for Adding Outline Reverse Proxy:

```
outline.example.com {
    reverse_proxy outline-app:3000
}
```

- Replace `outline.example.com` with your actual domain name.
- Replace `outline-app` with the container name of your Outline service.
- Ensure the Outline service is connected to the `caddy-outline` network.

You can add multiple sites by repeating the block for different services.

### 5. Start the Caddy Service

```
docker compose up -d
```

This will start Caddy and make your configured domains available.

### 6. Verify Running Containers

```
docker compose ps
```

You should see the `caddy` container running.

### 7. Persistent Data Storage

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

