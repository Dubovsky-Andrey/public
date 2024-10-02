#!/bin/bash

#--------------------------------------------------------------------
# Script to Install Docker
#
# Purpose:
#   This script:
#   1. Detects the OS (Ubuntu or Fedora) and its version.
#   2. Checks the CPU architecture (only x86_64 is supported).
#   3. Runs the appropriate setup scripts based on the OS and architecture.
# 
# Tested on:
#           Ubuntu 24.04,
#           Fedora 40
# Developed by Andrey Dubovsky
#--------------------------------------------------------------------

LOG_FILE="/var/log/os_arch_detection.log"

# Function to log info messages
function log_info() {
    echo "[INFO] $1"
    echo "[INFO] $1" >> "$LOG_FILE"
}

# Function to log error messages
function log_error() {
    echo "[ERROR] $1"
    echo "[ERROR] $1" >> "$LOG_FILE"
    exit 1
}

# Function to make a script executable and run it
function make_executable_and_run() {
    local script_name=$1

    if [ -f "$script_name" ]; then
        chmod +x "$script_name"
        log_info "Running $script_name"
        ./"$script_name"
        if [ $? -ne 0 ]; then
            log_error "Failed to execute $script_name"
        else
            log_info "$script_name executed successfully"
        fi
    else
        log_error "$script_name not found!"
    fi
}

# Function to detect the operating system and version
function detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    else
        log_error "Cannot determine the OS or version"
    fi

    log_info "Detected OS: $DISTRO, Version: $VERSION"
}

# Function to detect CPU architecture
function detect_architecture() {
    ARCH=$(uname -m)
    log_info "Detected CPU architecture: $ARCH"

    if [ "$ARCH" != "x86_64" ]; then
        log_error "Unsupported architecture: $ARCH. Only x86_64 is supported."
    fi
}

# Main function
function main() {
    detect_architecture
    detect_os

    # Ubuntu 24.04 logic
    if [ "$DISTRO" = "ubuntu" ] && [ "$VERSION" = "24.04" ]; then
        log_info "Running setup for Ubuntu 24.04"
        make_executable_and_run "./ubuntu/ubuntu_24_04_install_docker.sh"

    # Fedora 40 logic  
    elif [ "$DISTRO" = "fedora" ] && [ "$VERSION" = "40" ]; then
        log_info "Running setup for Fedora 40"

        make_executable_and_run "./fedora/fedora_40_install_docker.sh"
 
    else
        log_error "Unsupported OS or version: $DISTRO $VERSION"
    fi
}

# Start the main process
main
