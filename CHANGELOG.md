# Changelog

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
