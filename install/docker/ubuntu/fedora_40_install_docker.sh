#!/bin/bash

#--------------------------------------------------------------------
# Script to Install Docker and Docker Compose on Fedora
# Tested on: 
#           Fedora 40
# Developed by Andrey Dubovsky
#--------------------------------------------------------------------
LOG_FILE="/var/log/docker_install_fedora.log"

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

# Remove old Docker versions and related programs
function remove_old_docker() {
    log_info "Removing old Docker versions and related programs..."
    sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
    check_command_success "Failed to remove old Docker versions" "Old Docker versions removed successfully"
}

# Add Docker's official repository to DNF
function add_docker_repository() {
    log_info "Adding Docker's official repository to DNF..."
    sudo dnf -y install dnf-plugins-core
    check_command_success "Failed to install dnf-plugins-core" "dnf-plugins-core installed successfully"
    
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    check_command_success "Failed to add Docker repository" "Docker repository added successfully"
}

# Install Docker and Docker Compose
function install_docker() {
    log_info "Installing Docker and Docker Compose..."
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    check_command_success "Failed to install Docker and Docker Compose" "Docker and Docker Compose installed successfully"
}

# Start Docker service
function start_docker() {
    log_info "Starting Docker service..."
    sudo systemctl start docker
    check_command_success "Failed to start Docker service" "Docker service started successfully"
}

# Verify Docker and Docker Compose installation
function verify_docker_installation() {
    log_info "Verifying Docker installation."
    
    sudo docker run hello-world
    check_command_success "Failed to run hello-world Docker container" "Docker hello-world container ran successfully"
    
    sudo docker version
    check_command_success "Failed to get Docker version" "Docker version obtained successfully"
    
    sudo docker compose version
    check_command_success "Failed to get Docker Compose version" "Docker Compose version obtained successfully"
}

# Add user to Docker group
function add_user_to_docker_group() {
    log_info "Adding user $DOCKER_USER to Docker group"
    
    sudo usermod -aG docker $DOCKER_USER
    check_command_success "Failed to add user $DOCKER_USER to docker group" "User $DOCKER_USER added to docker group successfully"
}

# Parse named parameters
function parse_params() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --user) DOCKER_USER="$2"; shift ;; # Устанавливаем DOCKER_USER если передан --user
            --help) 
                echo "Usage: $0 --user <username>"
                exit 0
                ;;
            *)
                echo "Unknown parameter passed: $1"
                echo "Use --help for usage information."
                exit 1
                ;;
        esac
        shift
    done

    # Если DOCKER_USER не задан, выводим ошибку
    if [ -z "$DOCKER_USER" ]; then
        echo "Error: --user parameter is required"
        echo "Usage: $0 --user <username>"
        exit 1
    fi
}

# Main function
function main() {
    log_info "Starting Docker installation process on Fedora..."

    remove_old_docker
    add_docker_repository
    install_docker
    start_docker
    verify_docker_installation
    add_user_to_docker_group

    log_info "Docker installation completed successfully on Fedora."
}

# Parse command-line arguments
parse_params "$@"

# Start the main function
main
