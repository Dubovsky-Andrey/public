#!/bin/bash

#--------------------------------------------------------------------
# Script to Install Prometheus Node_Exporter on Linux
# Tested on: 
#           Ubuntu 24.04
# Developed by Andrey Dubovsky
#--------------------------------------------------------------------

NODE_EXPORTER_VERSION="1.8.2"
NODE_EXPORTER_USER="node_exporter"
LOG_FILE="/var/log/node_exporter_install.log"

function log_info() {
    echo "[INFO] $1"
    echo "[INFO] $1" >> "$LOG_FILE"
}

function log_error() {
    echo "[ERROR] $1" >&2
    echo "[ERROR] $1" >> "$LOG_FILE"
    exit 1
}

function check_command_success() {
    if [ $? -ne 0 ]; then
        log_error "$1"
    else
        log_info "$2"
    fi
}

function install_dependencies() {
    log_info "Installing dependencies..."
    if ! command -v wget &> /dev/null; then
        apt-get update && apt-get install -y wget
        check_command_success "Failed to install wget" "wget installed successfully"
    else
        log_info "wget is already installed"
    fi
}

function download_node_exporter() {
    log_info "Downloading Node Exporter version $NODE_EXPORTER_VERSION..."
    cd /tmp || log_error "Failed to change directory to /tmp"
    
    curl -L -o node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
    check_command_success "Failed to download Node Exporter" "Node Exporter downloaded successfully"
    
    tar xvfz node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
    check_command_success "Failed to extract Node Exporter" "Node Exporter extracted successfully"
    
    cd node_exporter-$NODE_EXPORTER_VERSION.linux-amd64 || log_error "Failed to change directory to node_exporter"
}

function install_node_exporter() {
    log_info "Installing Node Exporter..."
    
    mv node_exporter /usr/bin/
    check_command_success "Failed to move node_exporter binary to /usr/bin" "Node Exporter moved to /usr/bin successfully"
    
    rm -rf /tmp/node_exporter*
    log_info "Temporary files cleaned up"

    useradd -rs /bin/false $NODE_EXPORTER_USER
    chown $NODE_EXPORTER_USER:$NODE_EXPORTER_USER /usr/bin/node_exporter
    log_info "User $NODE_EXPORTER_USER created and permissions set"
}

function configure_systemd() {
    log_info "Configuring systemd service for Node Exporter..."

    cat <<EOF> /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=$NODE_EXPORTER_USER
Group=$NODE_EXPORTER_USER
Type=simple
Restart=on-failure
ExecStart=/usr/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    check_command_success "Failed to reload systemd daemon" "Systemd daemon reloaded successfully"
    
    systemctl start node_exporter
    check_command_success "Failed to start node_exporter service" "Node Exporter service started successfully"
    
    systemctl enable node_exporter
    check_command_success "Failed to enable node_exporter service" "Node Exporter service enabled to start on boot"
    
    systemctl status node_exporter -l --no-pager
}

function test_installation() {
    log_info "Testing Node Exporter installation..."
    
    /usr/bin/node_exporter --version &> /dev/null
    check_command_success "Node Exporter installation test failed" "Node Exporter installed successfully"
}

function main() {
    log_info "Starting Node Exporter installation..."
    
    install_dependencies
    download_node_exporter
    install_node_exporter
    configure_systemd
    test_installation
    
    log_info "Node Exporter installation completed successfully"
}

main
