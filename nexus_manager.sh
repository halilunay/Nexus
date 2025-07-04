#!/bin/bash

# ===================================================================================
# Professional Nexus L1 Node Manager
#
# Features:
# - Configuration via .env file.
# - Compares local vs. remote versions before taking action.
# - Avoids unnecessary downtime by only updating when a new version is available.
# - Checks if nodes are running and starts them if they are down.
# - Detailed logging of all actions.
# - Idempotent: safe to run repeatedly.
# ===================================================================================

# Stop on any error
set -e

# --- SCRIPT SETUP ---
# Move to the script's directory to ensure .env file is found
cd "$(dirname "$0")"

# Load configuration from .env file
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found. Please create it. Aborting."
    exit 1
fi

# Set PATH to find commands
export PATH="$HOME/.cargo/bin:$HOME/.nexus/bin:$PATH"

# --- LOGGING FUNCTION ---
# This function logs messages to both the console and the specified log file.
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a "$LOG_FILE"
}

# --- MAIN LOGIC ---
log "--- Nexus Manager Script Started ---"

# 1. CHECK LOCAL VERSION
# ========================
log "Checking local Nexus CLI version..."
if ! command -v nexus-network &> /dev/null; then
    log "Nexus CLI not found. Running the update/install process..."
    LOCAL_VERSION="0.0.0" # Set a non-existent version to force install
else
    # Example output: "nexus-cli 0.5.0", we need "0.5.0"
    LOCAL_VERSION=$(nexus-network --version | awk '{print $2}')
    log "Local version found: $LOCAL_VERSION"
fi

# 2. CHECK REMOTE VERSION
# =========================
log "Checking latest available Nexus CLI version from GitHub..."
# We use the GitHub API for releases, which is the most reliable method.
REMOTE_VERSION=$(curl -s "https://api.github.com/repos/nexus-xyz/nexus-cli/releases/latest" | jq -r '.tag_name' | sed 's/v//') # Removes 'v' prefix if present

if [ -z "$REMOTE_VERSION" ]; then
    log "Error: Could not fetch remote version from GitHub. Aborting."
    exit 1
fi
log "Latest available version: $REMOTE_VERSION"


# 3. COMPARE AND ACT
# ====================
if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
    log "New version available (Local: $LOCAL_VERSION, Remote: $REMOTE_VERSION). Starting update process."

    log "Stopping any running Nexus nodes..."
    pkill -f "nexus-network" || log "No running processes to stop."

    log "Running the official installer to update..."
    curl https://cli.nexus.xyz/ | sh

    log "Update complete. Starting nodes..."
    # The 'start_nodes' logic is called after this block
else
    log "Nexus CLI is already up-to-date (Version: $LOCAL_VERSION)."
fi

# 4. ENSURE NODES ARE RUNNING
# =============================
log "Checking if nodes are running..."
if [ -z "$NODE_IDS" ]; then
    log "Warning: NODE_IDS variable is not set in .env file. Cannot start nodes."
else
    for NODE_ID in $NODE_IDS; do
        # We check if a screen session with the Node ID name exists
        if ! screen -list | grep -q "$NODE_ID"; then
            log "Node $NODE_ID is not running. Starting it now..."
            command_to_run="nexus-network start --node-id $NODE_ID"
            screen -dmS "$NODE_ID" bash -c "$command_to_run"
            log "Started screen for Node ID: $NODE_ID"
        else
            log "Node $NODE_ID is already running in a screen session."
        fi
    done
fi

log "--- Nexus Manager Script Finished ---"
echo # Add a blank line in the log for readability
