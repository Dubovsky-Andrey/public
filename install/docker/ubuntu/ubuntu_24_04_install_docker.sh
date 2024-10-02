#!/bin/bash

#--------------------------------------------------------------------
# Script to Install Docker and Docker Compose on Ubuntu
# Tested on: 
#           Ubuntu 24.04
# Developed by Andrey Dubovsky
#--------------------------------------------------------------------

LOG_FILE="/var/log/docker_install.log"

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

function check_command_success() {
    if [ $? -ne 0 ]; then
        log_error "$1"
    else
        log_success "$2"
    fi
}

# Remove old Docker versions and related programs
function remove_old_docker() {
    log_info "Removing old Docker versions and related programs..."
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get remove -y $pkg
        check_command_success "Failed to remove $pkg" "$pkg removed successfully"
    done
}

# Add Docker's official GPG key
function add_docker_keys() {
    log_info "Adding Docker's official GPG key..."
    sudo apt-get update
    check_command_success "Failed to update package lists" "Package lists updated successfully"
    
    sudo apt-get install -y ca-certificates curl
    check_command_success "Failed to install ca-certificates and curl" "ca-certificates and curl installed successfully"
    
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    check_command_success "Failed to download Docker GPG key" "Docker GPG key downloaded successfully"
    
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    check_command_success "Failed to set permissions on Docker GPG key" "Permissions set successfully on Docker GPG key"
}

# Add Docker repository to Apt sources
function add_docker_repository() {
    log_info "Adding Docker repository to Apt sources..."
    
    VERSION_CODENAME=$(lsb_release -cs)
    check_command_success "Failed to get Ubuntu codename" "Ubuntu codename is $VERSION_CODENAME"
    
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    ${VERSION_CODENAME} stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    check_command_success "Failed to add Docker repository" "Docker repository added successfully"
}

# Install Docker and Docker Compose
function install_docker() {
    log_info "Installing Docker and Docker Compose..."
    sudo apt-get update
    check_command_success "Failed to update package lists" "Package lists updated successfully"
    
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
    check_command_success "Failed to install Docker and Docker Compose" "Docker and Docker Compose installed successfully"
}

# Verify Docker and Docker Compose installation
function verify_docker_installation() {
    log_info "Verifying Docker installation..."
    
    sudo docker run hello-world
    check_command_success "Failed to run hello-world Docker container" "Docker hello-world container ran successfully"
    
    sudo docker version
    check_command_success "Failed to get Docker version" "Docker version obtained successfully"
    
    sudo docker compose version
    check_command_success "Failed to get Docker Compose version" "Docker Compose version obtained successfully"
}

function main() {
    log_info "Starting Docker installation process..."
    
    remove_old_docker
    add_docker_keys
    add_docker_repository
    install_docker
    verify_docker_installation
    
    log_info "Docker installation completed successfully"
}

main
