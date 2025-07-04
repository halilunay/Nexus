# Nexus L1 Fully Automated Node Installation & Management Script

This repository contains a solution designed to completely automate the process of installing, updating, and managing a Nexus L1 testnet node. With a single command, you can deploy a fully automated management system on your server, ensuring your nodes remain consistently up-to-date and active.

The system checks your nodes hourly, automatically installs new updates if they are available, and restarts any nodes that may have stopped for any reason.

## 🚀 Features

* **One-Command Setup:** Installs the entire system, including dependencies and configurations, with a single command.
* **Automatic Update Checks:** Your server checks for a new Nexus version every hour.
* **Smart Management:** The script only takes action if a new version is available or if your nodes are not running. It does not restart nodes unnecessarily, minimizing downtime.
* **Automated Cron Job:** Sets up the scheduled task (`cron job`) for hourly checks on your behalf.
* **Detailed Logging:** All actions (version checks, updates, node starts) are logged with a timestamp to `/root/nexus_manager.log`.
* **Easy Configuration:** All your Node IDs are managed in a simple `.env` file.
* **Version Comparison:** Compares local vs. remote versions using GitHub API to avoid unnecessary updates.
* **Screen Session Management:** Each node runs in its own screen session for easy monitoring.

## ⚙️ Prerequisites

* **Operating System:** A server running Ubuntu 22.04 or 24.04.
* **User:** Access as the `root` user.
* **Dependencies:** The script automatically installs required dependencies (`jq`, `curl`, `screen`).

## ⚡ Quick Installation

You only need to copy the command below, paste it into your server's terminal, and press Enter. The setup script will ask for your Node IDs and then automate the rest of the process.

```bash
bash <(curl -sSL "https://raw.githubusercontent.com/halilunay/Nexus/main/setup.sh")
```

### What happens during installation:

1. **Dependency Installation:** Automatically installs `jq` for JSON parsing.
2. **Script Download:** Downloads the main manager script from GitHub.
3. **Configuration Setup:** Creates a `.env` file with your Node IDs.
4. **Cron Job Setup:** Automatically configures hourly execution at the 5th minute of each hour.
5. **Initial Run:** Offers to run the manager for the first time immediately.

## 🛠️ Post-Installation

Once the setup is complete, your system will begin operating in fully automatic mode. You can check the status of the system using the following commands:

### Viewing Logs

To see what the script is doing in real-time or to review past actions:

```bash
tail -f /root/nexus_manager.log
```

(Press `CTRL + C` to exit.)

### Listing Running Nodes

To list the `screen` sessions for your nodes:

```bash
screen -ls
```

In the output, you should see `(Detached)` sessions with the same names as your Node IDs.

### Watching a Node's Live Output

To connect to a specific node's "screen" and see its real-time output:

```bash
screen -r NODE_ID
```

*(Example: `screen -r 10414353`)*

(To detach from the screen, press `CTRL + A` followed by `D`.)

### Manual Script Execution

If you want to run the manager manually (outside of the scheduled cron job):

```bash
cd /root && ./nexus_manager.sh
```

## 🔧 Configuration and Management

### Adding or Removing a Node

To manage your Node IDs, you simply need to edit the `.env` file located in the `/root` directory.

1. Open the file with `nano`:

```bash
nano /root/.env
```

2. Update the list of IDs on the `NODE_IDS` line. When adding or removing IDs, ensure they are separated by spaces.

```ini
# Example:
NODE_IDS="111111 222222 333333 444444"

# Path for the log file.
LOG_FILE="/root/nexus_manager.log"
```

3. Save and exit the file (`CTRL + X`, then `Y`, then `Enter`). The script will automatically use the new list on its next hourly check.

### Checking Cron Job Status

To verify that the cron job is properly configured:

```bash
crontab -l
```

You should see a line like:
```
5 * * * * cd /root && /root/nexus_manager.sh
```

## 🏗️ How It Works

This system consists of two main scripts:

### 1. `setup.sh` (The Installer Script)
This script runs only once during initial setup. It performs the following actions:
- Installs system dependencies (`jq`)
- Downloads the main manager script from GitHub
- Creates the `.env` configuration file interactively
- Sets up the cron job for automatic execution
- Offers to run the manager immediately

### 2. `nexus_manager.sh` (The Manager Script)
This is the main worker script that is executed by cron every hour. It performs the following operations:

**Version Management:**
- Checks the locally installed Nexus CLI version
- Fetches the latest version from GitHub API
- Only proceeds with updates if versions differ

**Update Process:**
- Stops running nodes gracefully
- Downloads and installs the latest Nexus CLI
- Restarts all configured nodes

**Node Management:**
- Checks if each configured node is running in a screen session
- Starts any nodes that are not currently running
- Maintains separate screen sessions for each node

**Logging:**
- Logs all actions with timestamps
- Provides detailed information about version checks, updates, and node status

## 📋 Log Format

The log file (`/root/nexus_manager.log`) contains timestamped entries showing:
- Script start/finish times
- Version check results
- Update operations
- Node start/stop activities
- Error messages and warnings

Example log entries:
```
2024-01-15 10:05:01 | --- Nexus Manager Script Started ---
2024-01-15 10:05:02 | Checking local Nexus CLI version...
2024-01-15 10:05:03 | Local version found: 0.5.0
2024-01-15 10:05:04 | Checking latest available Nexus CLI version from GitHub...
2024-01-15 10:05:05 | Latest available version: 0.5.1
2024-01-15 10:05:06 | New version available (Local: 0.5.0, Remote: 0.5.1). Starting update process.
```

## 🔒 Security Considerations

- The script runs as root and has full system access
- All downloads are performed over HTTPS
- Scripts are fetched from the official GitHub repository
- Version verification is performed via GitHub API

## 🐛 Troubleshooting

### Common Issues:

**Script not running automatically:**
- Check cron job: `crontab -l`
- Check system logs: `grep CRON /var/log/syslog`

**Nodes not starting:**
- Check if Node IDs are correctly configured in `/root/.env`
- Verify screen sessions: `screen -ls`
- Check log file for error messages: `tail -f /root/nexus_manager.log`

**Permission errors:**
- Ensure script is executable: `chmod +x /root/nexus_manager.sh`
- Verify running as root user

**Network issues:**
- Check internet connectivity
- Verify access to GitHub API: `curl -s https://api.github.com/repos/nexus-xyz/nexus-cli/releases/latest`

## 📞 Support

If you encounter any issues or have questions about the script, please:
1. Check the log file for detailed error messages
2. Review the troubleshooting section above
3. Create an issue on the GitHub repository with relevant log excerpts

## 📜 License

This project is provided as-is for educational and automation purposes. Use at your own risk and ensure you understand the scripts before running them on production systems.

---

**Author:** @halilunay  
**Repository:** https://github.com/halilunay/Nexus
