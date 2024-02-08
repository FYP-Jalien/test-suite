#!/bin/bash

source ../func/messages.sh
source ../.env

# Docker container name or ID
if ! sudo docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME_CENTRAL$"; then
    print_error "Container $CONTAINER_NAME_CENTRAL is not running."
fi

# List of packages to check
packages=(
    debconf-utils mysql-server openjdk-11-jdk python3 python3-pip git slapd ldap-utils rsync vim tmux entr less cmake zlib1g-dev uuid uuid-dev libssl-dev wget htcondor supervisor environment-modules tcl
)

for package_name in "${packages[@]}"; do
    if sudo docker exec "$CONTAINER_NAME_CENTRAL" dpkg -l | grep -q "^ii.*$package_name"; then
        print_success "$package_name is installed."
    else
        print_error "$package_name is not installed."
    fi
done


## Check for xrootd