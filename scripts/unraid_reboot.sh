#!/bin/bash

# =========================================
# Made by glennigen
# Script to safely shut down QEMU VMs and Docker containers,
# then restart the Unraid server
# =========================================

VMNAME="Veeam"
VM_RUNNING_STATE="  state.state=1"
VM_STOPPED_STATE="  state.state=5"
MAX_ATTEMPTS=20
LOGFILE="/boot/logs/unraid_reboot.log"

# Function to get VM status
get_vm_state() {
    virsh domstats "$VMNAME" | grep state.state
}

# Function to log with timestamp
log() {
    local level="$1"
    local message="$2"
    echo "[$level] :: $(date +"%d/%m-%Y - %H:%M:%S") :: $message" | tee -a $LOGFILE
}

# Function to check Docker container status
are_docker_containers_running() {
    [[ $(docker ps -q) ]]
}

# Initial VM status
VM_STATE=$(get_vm_state)

# Initialize attempt counter
attempt=0

# Loop until VM is stopped or MAX_ATTEMPTS is reached
while [ "$VM_STATE" = "$VM_RUNNING_STATE" ] && [ $attempt -lt $MAX_ATTEMPTS ]; do
    log "INFO" "Attempting to shut down $VMNAME (attempt $((attempt + 1)))"
    virsh shutdown "$VMNAME"
    sleep 30
    VM_STATE=$(get_vm_state)
    attempt=$((attempt + 1))
done

# Check if MAX_ATTEMPTS is reached and if VM is still running
if [ $attempt -ge $MAX_ATTEMPTS ] && [ "$VM_STATE" = "$VM_RUNNING_STATE" ]; then
    log "ERROR" "Reached maximum attempts to stop the VM."
    exit 1
fi

# Wait 30 seconds
sleep 30

# Final check on VM status and plan restart
VM_STATE=$(get_vm_state)
if [ "$VM_STATE" = "$VM_STOPPED_STATE" ]; then
    # Initialize attempt counter for Docker containers
    attempt=0

    # Loop until Docker containers are stopped or MAX_ATTEMPTS is reached
    while are_docker_containers_running && [ $attempt -lt $MAX_ATTEMPTS ]; do
        log "INFO" "Attempting to stop Docker containers (attempt $((attempt + 1)))"
        docker stop $(docker ps -q)
        sleep 30
        attempt=$((attempt + 1))
    done

    # Check if MAX_ATTEMPTS is reached and if Docker containers are still running
    if [ $attempt -ge $MAX_ATTEMPTS ] && are_docker_containers_running; then
        log "ERROR" "Reached maximum attempts to stop Docker containers."
        exit 1
    fi
    
    # Calculate restart time
    RESTART_TIME=$(date -d "2 minutes" +"%H:%M:%S")
    shutdown -r +2 &
    log "SUCCESS" "Server will restart in 2 minutes at $RESTART_TIME."
    exit 0
else
    log "ERROR" "VM did not stop as expected."
    exit 1
fi
