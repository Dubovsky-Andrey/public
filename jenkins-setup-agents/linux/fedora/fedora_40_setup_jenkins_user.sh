#!/bin/bash

#--------------------------------------------------------------------
# Script to check and configure SSH and sudo settings for Jenkins user on Fedora
#
# Purpose:
#   This script:
#   1. Checks if .ssh directory and authorized_keys file exist and have the correct permissions.
#   2. Offers to add an SSH key to authorized_keys.
#   3. Offers to add the Jenkins user to the sudo (wheel) group.
#
# Tested on:
#           Fedora 40
# Developed by Andrey Dubovsky
#--------------------------------------------------------------------

LOG_FILE="/var/log/jenkins_ssh_sudo_setup_fedora.log"

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

# Check and create .ssh directory if it doesn't exist
function check_ssh_dir() {
    if [ ! -d "/home/jenkins/.ssh" ]; then
        log_info "SSH directory not found. Creating it..."
        mkdir -p /home/jenkins/.ssh
        check_command_success "Failed to create .ssh directory" "SSH directory created with correct permissions."
    else
        log_info "SSH directory exists. Checking permissions..."
        chmod 700 /home/jenkins/.ssh
        chown jenkins:jenkins /home/jenkins/.ssh
        check_command_success "Failed to update permissions on .ssh directory" "Permissions on SSH directory updated."
    fi
}

# Check and create authorized_keys file if it doesn't exist
function check_authorized_keys() {
    if [ ! -f "/home/jenkins/.ssh/authorized_keys" ]; then
        log_info "authorized_keys file not found. Creating it..."
        touch /home/jenkins/.ssh/authorized_keys
        chmod 600 /home/jenkins/.ssh/authorized_keys
        chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys
        check_command_success "Failed to create authorized_keys file" "authorized_keys file created with correct permissions."
    else
        log_info "authorized_keys file exists. Checking permissions..."
        chmod 600 /home/jenkins/.ssh/authorized_keys
        chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys
        check_command_success "Failed to update permissions on authorized_keys" "Permissions on authorized_keys updated."
    fi
}

# Add SSH key
function add_ssh_key() {
    read -p "Please enter the public SSH key: " ssh_key
    echo "$ssh_key" >> /home/jenkins/.ssh/authorized_keys
    chmod 600 /home/jenkins/.ssh/authorized_keys
    chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys
    check_command_success "Failed to add SSH key to authorized_keys" "SSH key added to authorized_keys."
}

# Add Jenkins to sudo (wheel) group
function add_to_sudo() {
    sudo usermod -aG wheel jenkins
    check_command_success "Failed to add Jenkins user to wheel group" "Jenkins user added to wheel group."
    echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/jenkins > /dev/null
    check_command_success "Failed to configure sudo without password for Jenkins user" "Configured sudo without password for Jenkins user."
}

# Main function to run the checks and configurations
function main() {
    log_info "Starting SSH and sudo configuration for Jenkins user on Fedora."

    check_ssh_dir
    check_authorized_keys
    add_ssh_key
    add_to_sudo

    log_success "SSH and sudo configuration completed."
}

# Run the main function
main
