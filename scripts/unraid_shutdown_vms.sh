#!/bin/bash

# =========================================
# Made by glennigen
# Script to safely shut down all or specific QEMU VMs on the Unraid server.
# If VM_NAMES is empty, all running VMs will be shut down. If specific VMs are listed in VM_NAMES,
# only those VMs will be shut down.
# =========================================

# Variable to specify which VMs to shut down.
# If empty, all running VMs will be shut down. Otherwise, specify VM names separated by spaces.
VM_NAMES=""

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

# Check if VM_NAMES is empty
if [ -z "$VM_NAMES" ]; then
    log "INFO" "No specific VMs provided in VM_NAMES. Shutting down all running VMs."
    RUNNING_VMS=$(get_running_vms)
    
    if [[ -z "$RUNNING_VMS" ]]; then
        log "INFO" "No VMs are currently running."
        exit 0
    fi
    
    # Shut down all running VMs
    for VMNAME in $RUNNING_VMS; do
        if [[ -n "$VMNAME" ]]; then
            shutdown_vm "$VMNAME"
        fi
    done
else
    # Shut down only the VMs specified in VM_NAMES
    log "INFO" "Shutting down specified VMs: $VM_NAMES"
    for VMNAME in $VM_NAMES; do
        shutdown_vm "$VMNAME"
    done
fi

log "INFO" "VM shutdown process completed."
exit 0