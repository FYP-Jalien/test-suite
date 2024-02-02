#!/bin/bash

. ../func/messages.sh

# Docker container name or ID
container_name="shared_volume_JCentral-dev_1"
if ! sudo docker ps --format '{{.Names}}' | grep -q "^$container_name$"; then
    print_error "Container $container_name is not running."
fi

# List of packages to check
packages=(
    debconf-utils mysql-server openjdk-11-jdk python3 python3-pip git slapd ldap-utils rsync vim tmux entr less cmake zlib1g-dev uuid uuid-dev libssl-dev wget htcondor supervisor environment-modules tcl
)

for package_name in "${packages[@]}"; do
    if sudo docker exec "$container_name" dpkg -l | grep -q "^ii.*$package_name"; then
        print_success "$package_name is installed."
    else
        print_error "$package_name is not installed."
    fi
done


## Check for xrootd