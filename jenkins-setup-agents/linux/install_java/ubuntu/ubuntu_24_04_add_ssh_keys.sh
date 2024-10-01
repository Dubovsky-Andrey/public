#!/bin/bash

#--------------------------------------------------------------------
# Script to check and configure SSH and sudo settings for Jenkins user
#
# Purpose:
#   This script:
#   1. Checks if .ssh directory and authorized_keys file exist and have the correct permissions.
#   2. Offers to add an SSH key to authorized_keys.
#   3. Offers to add the Jenkins user to the sudo group.
#
# Tested on:
#           Ubuntu 24.04
# Developed by Andrey Dubovsky
#--------------------------------------------------------------------

# Function for logging info
function log_info() {
    echo "[INFO] $1"
}

# Function for logging success
function log_success() {
    echo "[SUCCESS] $1"
}

# Function for logging errors
function log_error() {
    echo "[ERROR] $1"
    exit 1
}

# Check and create .ssh directory if it doesn't exist
function check_ssh_dir() {
    if [ ! -d "/home/jenkins/.ssh" ]; then
        log_info "SSH directory not found. Creating it..."
        mkdir /home/jenkins/.ssh
        chmod 700 /home/jenkins/.ssh
        chown jenkins:jenkins /home/jenkins/.ssh
        log_success "SSH directory created with correct permissions."
    else
        log_info "SSH directory exists. Checking permissions..."
        chmod 700 /home/jenkins/.ssh
        chown jenkins:jenkins /home/jenkins/.ssh
        log_success "Permissions on SSH directory updated."
    fi
}

# Check and create authorized_keys file if it doesn't exist
function check_authorized_keys() {
    if [ ! -f "/home/jenkins/.ssh/authorized_keys" ]; then
        log_info "authorized_keys file not found. Creating it..."
        touch /home/jenkins/.ssh/authorized_keys
        chmod 600 /home/jenkins/.ssh/authorized_keys
        chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys
        log_success "authorized_keys file created with correct permissions."
    else
        log_info "authorized_keys file exists. Checking permissions..."
        chmod 600 /home/jenkins/.ssh/authorized_keys
        chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys
        log_success "Permissions on authorized_keys updated."
    fi
}

# Ask if user wants to add SSH key
function add_ssh_key() {
    read -p "Do you want to add an SSH key to authorized_keys? (yes/no): " response
    if [[ "$response" == "yes" ]]; then
        read -p "Please enter the public SSH key: " ssh_key
        echo "$ssh_key" >> /home/jenkins/.ssh/authorized_keys
        chmod 600 /home/jenkins/.ssh/authorized_keys
        chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys
        log_success "SSH key added to authorized_keys."
    else
        log_info "Skipping SSH key addition."
    fi
}

# Ask if user wants to add Jenkins to sudo group
function add_to_sudo() {
    read -p "Do you want to add the Jenkins user to the sudo group? (yes/no): " response
    if [[ "$response" == "yes" ]]; then
        sudo usermod -aG sudo jenkins
        log_success "Jenkins user added to sudo group."
        
        # Ask if user wants to configure sudo without a password
        read -p "Do you want to configure sudo without a password for Jenkins user? (yes/no): " nopasswd_response
        if [[ "$nopasswd_response" == "yes" ]]; then
            echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/jenkins > /dev/null
            log_success "Configured sudo without password for Jenkins user."
        else
            log_info "Skipping sudo without password configuration."
        fi
    else
        log_info "Skipping sudo group addition."
    fi
}

# Main function to run the checks and configurations
function main() {
    log_info "Starting SSH and sudo configuration for Jenkins user."

    check_ssh_dir
    check_authorized_keys
    add_ssh_key
    add_to_sudo

    log_success "SSH and sudo configuration completed."
}

# Run the main function
main
