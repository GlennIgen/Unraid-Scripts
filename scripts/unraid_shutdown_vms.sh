#!/bin/bash

# =========================================
# Made by glennigen
# Script to safely shut down all or specific QEMU VMs on the Unraid server.
# =========================================

MAX_ATTEMPTS=20
LOGFILE="/mnt/remotes/NAS.local_backup/unraid_logs/unraid_shutdown_vm_$(date +"%Y-%m-%d").log"

# Function to log with timestamp
log() {
    local level="$1"
    local message="$2"
    echo "[$level] :: $(date +"%Y-%m-%d - %H:%M:%S") :: $message" | tee -a $LOGFILE
}

# Function to get all running VMs
get_running_vms() {
    virsh list --state-running --name
}

# Function to get VM status
get_vm_state() {
    local vmname=$1
    virsh domstats "$vmname" | grep state.state
}

# Function to shut down a VM
shutdown_vm() {
    local vmname=$1
    log "INFO" "Attempting to shut down VM: $vmname"
    
    VM_STATE=$(get_vm_state "$vmname")
    
    # Initialize attempt counter
    attempt=0

    # Loop until VM is stopped or MAX_ATTEMPTS is reached
    while [ "$VM_STATE" = "  state.state=1" ] && [ $attempt -lt $MAX_ATTEMPTS ]; do
        log "INFO" "Attempting to shut down $vmname (attempt $((attempt + 1)))"
        virsh shutdown "$vmname"
        sleep 30
        VM_STATE=$(get_vm_state "$vmname")
        attempt=$((attempt + 1))
    done

    # Check if MAX_ATTEMPTS is reached and if VM is still running
    if [ $attempt -ge $MAX_ATTEMPTS ] && [ "$VM_STATE" = "  state.state=1" ]; then
        log "ERROR" "Reached maximum attempts to stop $vmname."
        exit 1
    fi

    log "SUCCESS" "$vmname has been successfully shut down."
}

# If no arguments are passed, shut down all running VMs
if [ $# -eq 0 ]; then
    log "INFO" "No specific VMs provided. Shutting down all running VMs."
    RUNNING_VMS=$(get_running_vms)
    
    if [[ -z "$RUNNING_VMS" ]]; then
        log "INFO" "No VMs are currently running."
        exit 0
    fi
    
    for VMNAME in $RUNNING_VMS; do
        if [[ -n "$VMNAME" ]]; then
            shutdown_vm "$VMNAME"
        fi
    done
else
    # Shut down only the specified VMs passed as arguments
    for VMNAME in "$@"; do
        log "INFO" "Shutting down specified VM: $VMNAME"
        shutdown_vm "$VMNAME"
    done
fi

log "INFO" "VM shutdown process completed."
exit 0