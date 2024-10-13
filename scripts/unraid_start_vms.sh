#!/bin/bash

# =========================================
# Made by glennigen
# Script to start all or specific QEMU VMs on the Unraid server.
# If VM_NAMES is empty, all VMs will be started. If specific VMs are listed in VM_NAMES,
# only those VMs will be started.
# =========================================

# Variable to specify which VMs to start.
# If empty, all VMs will be started. Otherwise, specify VM names separated by spaces.
VM_NAMES=""

LOGFILE="/mnt/remotes/NAS.local_backup/unraid_logs/unraid_start_vm_$(date +"%Y-%m-%d").log"

# Function to log with timestamp
log() {
    local level="$1"
    local message="$2"
    echo "[$level] :: $(date +"%Y-%m-%d - %H:%M:%S") :: $message" | tee -a $LOGFILE
}

# Cleanup function to ensure the log always ends with a separator line
cleanup() {
    log "INFO" "==========================================================="
}
# Ensure cleanup runs on script exit (success or failure)
trap cleanup EXIT

# Add a separator line at the beginning of the log
log "INFO" "==========================================================="
log "INFO" "Starting VM process..."

# Function to get all defined VMs
get_all_vms() {
    virsh list --all --name
}

# Function to start a VM
start_vm() {
    local vmname=$1
    log "INFO" "Attempting to start VM: $vmname"
    virsh start "$vmname"
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "Successfully started $vmname."
    else
        log "ERROR" "Failed to start $vmname."
    fi
}

# Check if VM_NAMES is empty
if [ -z "$VM_NAMES" ]; then
    log "INFO" "No specific VMs provided in VM_NAMES. Starting all VMs."
    ALL_VMS=$(get_all_vms)
    
    if [[ -z "$ALL_VMS" ]]; then
        log "INFO" "No VMs defined."
        exit 0
    fi
    
    # Start all VMs
    for VMNAME in $ALL_VMS; do
        if [[ -n "$VMNAME" ]]; then
            start_vm "$VMNAME"
        fi
    done
else
    # Start only the VMs specified in VM_NAMES
    log "INFO" "Starting specified VMs: $VM_NAMES"
    for VMNAME in $VM_NAMES; do
        start_vm "$VMNAME"
    done
fi

log "INFO" "VM start process completed."
exit 0