#!/bin/bash

#--------------------------------------------------------------------
# Script to Install Temurin JDK 21 on Ubuntu
# Purpose: 
#           This script installs the necessary Java 21 (Temurin JDK)
#           for running Jenkins Node and connecting to Jenkins Master Docker container.
#
#           The script installs the correct packages and repository for Temurin JDK 21.
#
# Tested on: 
#           Ubuntu 24.04
# Developed by Andrey Dubovsky
#--------------------------------------------------------------------

LOG_FILE="/var/log/temurin_install_ubuntu.log"

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

# Install Temurin JDK on Ubuntu
function install_temurin_ubuntu() {
    log_info "Updating package lists and installing Temurin JDK on Ubuntu."
    
    sudo apt update -y
    check_command_success "Failed to update package lists on Ubuntu" "Package lists updated successfully on Ubuntu"
    
    sudo apt install -y wget apt-transport-https
    check_command_success "Failed to install wget and apt-transport-https on Ubuntu" "wget and apt-transport-https installed successfully on Ubuntu"
    
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add -
    check_command_success "Failed to add Adoptium GPG key on Ubuntu" "Adoptium GPG key added successfully on Ubuntu"
    
    echo "deb https://packages.adoptium.net/artifactory/deb focal main" | sudo tee /etc/apt/sources.list.d/adoptium.list
    check_command_success "Failed to add Adoptium repository on Ubuntu" "Adoptium repository added successfully on Ubuntu"
    
    sudo apt update -y
    check_command_success "Failed to update package lists after adding Adoptium repository on Ubuntu" "Package lists updated successfully after adding Adoptium repository on Ubuntu"
    
    sudo apt install -y temurin-21-jdk
    check_command_success "Failed to install Temurin 21 JDK on Ubuntu" "Temurin 21 JDK installed successfully on Ubuntu"
}

# Verify Temurin JDK installation
function verify_temurin() {
    log_info "Verifying Temurin JDK installation."
    
    java -version
    check_command_success "Failed to verify Temurin JDK installation" "Temurin JDK installation verified successfully"
}

# Main function 
function main() {
    log_info "Starting Temurin JDK installation process on Ubuntu."
    
    install_temurin_ubuntu
    verify_temurin
    
    log_success "Temurin JDK installation on Ubuntu completed successfully"
}

main
