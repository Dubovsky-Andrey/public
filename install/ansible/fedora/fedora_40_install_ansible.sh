#!/bin/bash

#--------------------------------------------------------------------
# Script to Install Ansible on Linux (Ubuntu/Fedora)
# Purpose:
#   This script automates the installation of Ansible on Linux systems.
#
# Tested on: 
#           Ubuntu 24.04, 
#           Fedora 40
# Developed by Andrey Dubovsky
#--------------------------------------------------------------------

LOG_FILE="/var/log/ansible_install.log"

# Function for logging info
function log_info() {
    echo "[INFO] $1"
    echo "[INFO] $1" >> "$LOG_FILE"
}
# Function for logging success
function log_success() {
    echo "[SUCCESS] $1"
    echo "[SUCCESS] $1" >> "$LOG_FILE"
}

# Function for logging errors
function log_error() {
    echo "[ERROR] $1" >&2
    echo "[ERROR] $1" >> "$LOG_FILE"
    exit 1
}

# Function for checking command success
function check_command_success() {
    if [ $? -ne 0 ]; then
        log_error "$1"
    else
        log_success "$2"
    fi
}

# Detect Linux distribution
function detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        log_error "Cannot determine the Linux distribution."
    fi
    log_info "Detected Linux distribution: $DISTRO"
}

# Install Ansible on Ubuntu
function install_ansible_ubuntu() {
    log_info "Updating package lists and installing Ansible on Ubuntu."
    sudo apt-get update
    check_command_success "Failed to update package lists on Ubuntu" "Package lists updated successfully on Ubuntu"
    
    sudo apt-get install -y ansible
    check_command_success "Failed to install Ansible on Ubuntu" "Ansible installed successfully on Ubuntu"
}

# Install Ansible on Fedora
function install_ansible_fedora() {
    log_info "Updating package lists and installing Ansible on Fedora."
    sudo dnf update -y
    check_command_success "Failed to update package lists on Fedora" "Package lists updated successfully on Fedora"
    
    sudo dnf install -y ansible
    check_command_success "Failed to install Ansible on Fedora" "Ansible installed successfully on Fedora"
}

# Verify installation
function verify_ansible() {
    log_info "Verifying Ansible installation."
    
    ansible --version
    check_command_success "Ansible verification failed" "Ansible verified successfully"
}

# Main function 
function main() {
    log_info "Starting Ansible installation process."
    
    detect_distro
    
    if [ "$DISTRO" = "ubuntu" ]; then
        install_ansible_ubuntu
    elif [ "$DISTRO" = "fedora" ]; then
        install_ansible_fedora
    else
        log_error "Unsupported Linux distribution: $DISTRO"
    fi

    verify_ansible
    log_success "Ansible installation on $DISTRO completed successfully"
}

main