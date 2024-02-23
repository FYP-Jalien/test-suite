#!/bin/bash

id=$((id + 1))
name="CENTRAL Container Package Check"
level="Critical"

packages=(
    debconf-utils mysql-server openjdk-11-jdk python3 python3-pip git slapd ldap-utils rsync vim tmux entr less cmake zlib1g-dev uuid uuid-dev libssl-dev wget htcondor supervisor environment-modules tcl
)

description="CENTRAL container should have these packages installed: $(convert_array_to_string "${packages[@]}")."

status="PASSED"
for package_name in "${packages[@]}"; do
    if ! sudo docker exec "$CONTAINER_NAME_CENTRAL" dpkg -l | grep -q "^ii.*$package_name"; then
        status="FAILED"
        message="$package_name is not installed."
        print_full_test "$id" "$name" $status "$description" $level "$message"
    fi
done

if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="All packages are installed."
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi
