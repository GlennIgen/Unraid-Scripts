# Unraid-Scripts

Welcome to the Unraid-Scripts repository! This repository contains a collection of scripts designed to enhance the functionality and automation of your Unraid server.

## Scripts Included

### 1. Veeam VM and Docker Shutdown and Reboot Script

This script safely shuts down the Veeam VM and all running Docker containers, then schedules a server reboot. It ensures that the VM and containers are properly stopped before rebooting to prevent data loss or corruption.

#### Features
- Safely shuts down the Veeam VM
- Stops all running Docker containers
- Logs all actions with timestamps
- Schedules a server reboot with a 2-minute warning

#### Usage
1. Place the script in your Unraid server, preferably under `/boot/config/plugins/user.scripts/scripts/` (If you are using '[User Scripts](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/)').
2. Ensure the script is executable:
    ```bash
    chmod +x /boot/config/plugins/user.scripts/scripts/unraid_reboot.sh
    ```
3. Schedule the script to run at your desired time using '[User Scripts](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/)' cron or by editing the crontab:
    ```plaintext
    0 2 * * 3 /boot/config/plugins/user.scripts/scripts/unraid_reboot.sh
    ```
    This example schedules the script to run every Wednesday at 2:00 AM.

## Contributing

Feel free to contribute to this repository by submitting issues or pull requests. If you have any useful scripts for Unraid, you are welcome to share them here.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
