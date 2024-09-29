#!/bin/bash

#--------------------------------------------------------------------
# Script to Create and Setup Jenkins User on Linux (Ubuntu/Fedora), Add SSH Key, and Optionally Configure sudo
#
# Purpose:
#   This script: 
#   1. Run install_java_21.sh
#   2. Run setup_jenkins_user.sh
#
# Tested on: 
#           Ubuntu 24.04,
#           Fedora 40
# Developed by Andrey Dubovsky
#--------------------------------------------------------------------

# Function to make a script executable and run it
function make_executable_and_run() {
    local script_name=$1

    if [ -f "$script_name" ]; then
        chmod +x "$script_name"
        echo "Running $script_name "
        ./"$script_name"
        if [ $? -ne 0 ]; then
            echo "[ERROR] Failed to execute $script_name"
            exit 1
        else
            echo "[SUCCESS] $script_name executed successfully"
        fi
    else
        echo "[ERROR] $script_name not found!"
        exit 1
    fi
}

# Run the install_java_21.sh script
make_executable_and_run "install_java_21.sh"

# Run the setup.sh script
make_executable_and_run "setup_jenkins_user.sh"
