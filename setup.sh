#!/bin/bash

# ===================================================================================
# Nexus Automation Setup Script by @halilunay
#
# This script will perform a one-time setup for the Nexus Node Manager.
# It installs dependencies, downloads the main manager script, creates the .env
# file by asking for Node IDs, and sets up the cron job automatically.
# ===================================================================================

# Stop on any error
set -e

# --- CONFIGURATION ---
# The URL for the main manager script.
MAIN_SCRIPT_URL="https://raw.githubusercontent.com/halilunay/Nexus/main/nexus_manager.sh"

# --- SCRIPT VARIABLES ---
DEST_DIR="/root"
MANAGER_SCRIPT_PATH="$DEST_DIR/nexus_manager.sh"
ENV_FILE_PATH="$DEST_DIR/.env"

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- HELPER FUNCTIONS ---
log_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

log_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}WARN:${NC} $1"
}

# --- SETUP STEPS ---

log_info "Starting the all-in-one setup for the Nexus Node Manager..."

# 1. Install Prerequisites
log_info "Updating package lists and installing 'jq'..."
sudo apt-get update > /dev/null
sudo apt-get install -y jq > /dev/null
log_success "'jq' is installed."

# 2. Download the Main Manager Script
log_info "Downloading the main manager script from GitHub..."
curl -sSL "$MAIN_SCRIPT_URL" -o "$MANAGER_SCRIPT_PATH"
chmod +x "$MANAGER_SCRIPT_PATH"
log_success "Manager script downloaded to $MANAGER_SCRIPT_PATH and made executable."

# 3. Create .env File Interactively
log_info "Now, let's set up your Node IDs."
log_warn "Please enter your Node IDs, separated by spaces, then press Enter."
read -p "Node ID(s): " NODE_IDS_INPUT

if [ -z "$NODE_IDS_INPUT" ]; then
    log_warn "No Node IDs entered. You can edit the .env file later manually."
fi

cat > "$ENV_FILE_PATH" << EOL
# --- Nexus Node Configuration ---
# Node IDs to be managed by the script.
NODE_IDS="$NODE_IDS_INPUT"

# Path for the log file.
LOG_FILE="$DEST_DIR/nexus_manager.log"
EOL
log_success ".env file created at $ENV_FILE_PATH"

# 4. Setup Cron Job Automatically
log_info "Setting up the cron job for automatic execution..."
CRON_JOB="5 * * * * cd $DEST_DIR && $MANAGER_SCRIPT_PATH"

(crontab -l 2>/dev/null | grep -vF "$MANAGER_SCRIPT_PATH") | { cat; echo "$CRON_JOB"; } | crontab -

log_success "Cron job set up to run every hour at the 5th minute."

# --- FINAL MESSAGE ---
echo
log_success "🚀 All-in-one setup complete!"
log_info "The system will now automatically check for updates and manage your nodes."
log_info "You can view the logs at any time with: tail -f $DEST_DIR/nexus_manager.log"
echo

read -p "Do you want to run the manager for the first time now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Running the first check..."
    "$MANAGER_SCRIPT_PATH"
fi
