#!/bin/bash

# =========================================
# Made by glennigen
# Script to start all QEMU VMs on the Unraid server, 
# or only specified VMs if given as arguments.
# =========================================

LOGFILE="/mnt/remotes/NAS.local_backup/unraid_logs/unraid_start_vm_$(date +"%Y-%m-%d").log"

# Function to log with timestamp
log() {
    local level="$1"
    local message="$2"
    echo "[$level] :: $(date +"%Y-%m-%d - %H:%M:%S") :: $message" | tee -a $LOGFILE
}

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

# If no arguments are passed, start all VMs
if [ $# -eq 0 ]; then
    log "INFO" "No specific VMs provided. Starting all VMs."
    ALL_VMS=$(get_all_vms)
    
    if [[ -z "$ALL_VMS" ]]; then
        log "INFO" "No VMs defined."
        exit 0
    fi
    
    for VMNAME in $ALL_VMS; do
        if [[ -n "$VMNAME" ]]; then
            start_vm "$VMNAME"
        fi
    done
else
    # Start only the specified VMs passed as arguments
    for VMNAME in "$@"; do
        log "INFO" "Starting specified VM: $VMNAME"
        start_vm "$VMNAME"
    done
fi

log "INFO" "VM start process completed."
exit 0