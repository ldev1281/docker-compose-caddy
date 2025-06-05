#!/bin/bash
set -e

# Get the absolute path of script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../.env"
VOL_DIR="${SCRIPT_DIR}/../vol/"

# -------------------------------------
# Caddy setup script
# -------------------------------------

FRP_VERSION=0.62.1

# Generate secure random defaults
generate_defaults() {
    _FRP_TOKEN=$(openssl rand -hex 32)
}

# Load existing configuration from .env file
load_existing_env() {
    set -o allexport
    source "$ENV_FILE"
    set +o allexport
}

# Prompt user to confirm or update configuration
prompt_for_configuration() {
    echo "Please enter configuration values (press Enter to keep current/default value):"
    echo ""
    
    echo "frp-client:"
    
    read -p "FRP_HOST [${FRP_HOST:-.onion}]: " input
    FRP_HOST=${input:-${FRP_HOST:-.onion}}

    read -p "FRP_PORT [${FRP_PORT:-7000}]: " input
    FRP_PORT=${input:-${FRP_PORT:-7000}}

    read -p "FRP_TOKEN [${FRP_TOKEN:-$_FRP_TOKEN}]: " input
    FRP_TOKEN=${input:-${FRP_TOKEN:-$_FRP_TOKEN}}
}


# Display configuration nicely and ask for user confirmation
confirm_and_save_configuration() {
    CONFIG_LINES=(
        "# frp-client"
        "FRP_HOST=${FRP_HOST}"
        "FRP_PORT=${FRP_PORT}"
        "FRP_TOKEN=${FRP_TOKEN}"
        ""
    )

    echo ""
    echo "The following environment configuration will be saved:"
    echo "-----------------------------------------------------"

    for line in "${CONFIG_LINES[@]}"; do
        echo "$line"
    done

    echo "-----------------------------------------------------"
    echo "" 

    #
    read -p "Proceed with this configuration? (y/n): " CONFIRM
    echo "" 
    if [[ "$CONFIRM" != "y" ]]; then
        echo "Configuration aborted by user."
        echo "" 
        exit 1
    fi

    #
    printf "%s\n" "${CONFIG_LINES[@]}" > "$ENV_FILE"
    echo ".env file saved to $ENV_FILE"
    echo "" 
}

# Set up containers and initialize the database
setup_containers() {
    echo "Stopping all containers and removing volumes..."
    docker compose down -v

    echo "Clearing volume data..."
    [ -d "${VOL_DIR}" ] && rm -rf "${VOL_DIR}"/*

    echo "Starting containers..."
    docker compose up -d

    echo "Waiting 60 seconds for services to initialize..."
    sleep 60

    echo "Done!"
    echo ""
}

# -----------------------------------
# Main logic
# -----------------------------------

# Check if .env file exists, load or generate defaults accordingly
if [ -f "$ENV_FILE" ]; then
    echo ".env file found. Loading existing configuration."
    load_existing_env
else
    echo ".env file not found. Generating defaults."
    generate_defaults
fi

# Always prompt user for configuration confirmation
prompt_for_configuration

# Ask user confirmation and save
confirm_and_save_configuration

# Run container setup
setup_containers