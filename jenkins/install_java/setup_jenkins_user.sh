#!/bin/bash

#--------------------------------------------------------------------
# Script to Create and Setup Jenkins User on Linux (Ubuntu/Fedora), Add SSH Key, and Optionally Configure sudo
#
# Purpose:
#   This script: 
#   1. Creates a Jenkins user
#   2. Sets a Jenkins user password 
#   3. Adds the Jenkins user to the sudo/ wheel  group, 
#   4. Checks and creates the Jenkins home directory,
#   5. Sets permissions for the Jenkins user's home directory, 
#   6. Add an SSH key to the `authorized_keys` file, 
#   7. Configures sudo access without a password.
#
#
# Tested on: 
#           Ubuntu 24.04,
#           Fedora 40
# Developed by Andrey Dubovsky
#--------------------------------------------------------------------

LOG_FILE="/var/log/jenkins_user_setup.log"

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

# Function to create and setup Jenkins user
function setup_jenkins_user() {
    # Create jenkins user with home directory and bash shell
    sudo useradd -m -s /bin/bash jenkins
    check_command_success "Failed to create jenkins user" "Jenkins user created successfully"

    # Set password for jenkins user
    echo "Please enter password for jenkins user:"
    sudo passwd jenkins
    check_command_success "Failed to set password for jenkins user" "Password for jenkins user set successfully"

    # Add jenkins user to sudo group
    sudo usermod -aG sudo jenkins
    check_command_success "Failed to add jenkins user to sudo group" "Jenkins user added to sudo group"

    # Check if /home/jenkins directory exists, and create if necessary
    if [ ! -d "/home/jenkins" ]; then
        log_info "/home/jenkins directory does not exist. Creating it."
        sudo mkdir /home/jenkins
        check_command_success "Failed to create /home/jenkins directory" "/home/jenkins directory created"
    else
        log_info "/home/jenkins directory already exists"
    fi

    # Set ownership and permissions for /home/jenkins
    sudo chown jenkins:jenkins /home/jenkins
    check_command_success "Failed to set ownership of /home/jenkins" "Ownership of /home/jenkins set to jenkins user"

    sudo chmod 750 /home/jenkins
    check_command_success "Failed to set permissions for /home/jenkins" "Permissions for /home/jenkins set to 750"
}

# Run the setup function
log_info "Starting Jenkins user setup process"
setup_jenkins_user
log_success "Jenkins user setup completed successfully"
