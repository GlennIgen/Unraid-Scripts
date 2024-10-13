# Changelog

## [1.0.3] - 2024-10-13

### Added
- Added `unraid_shutdown_vms.sh` script:
  - Allows shutting down all or specific QEMU VMs on the Unraid server.
  - Logs all actions with timestamps.
  - Supports argument-based control for shutting down specific VMs.
  
- Added `unraid_start_vms.sh` script:
  - Allows starting all or specific QEMU VMs on the Unraid server.
  - Logs all actions with timestamps.
  - Supports argument-based control for starting specific VMs.

## [1.0.2] - 2024-10-13

### Changed
- Updated the log file path to save logs on remote location.
- Added additional checks to ensure that Docker containers are running before attempting to stop them.
- Improved logging with clearer messages during the Docker container shutdown process.

## [1.0.1] - 2024-05-20

### Changed
- Updated log timestamp format to ISO 8601 (YYYY-MM-DD) for consistency and clarity.

## [1.0.0] - 2024-05-20

### Added
- Initial upload of the repository.
- Added Veeam VM and Docker Shutdown and Reboot Script.
  - Safely shuts down the Veeam VM.
  - Stops all running Docker containers.
  - Logs all actions with timestamps.
  - Schedules a server reboot with a 2-minute warning.

### Repository Structure
- Created `scripts` directory to house all the Unraid scripts.
