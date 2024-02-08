#!/bin/bash

source ../func/messages.sh
source ../.env

expected_image="xrootd-se"
expected_command="xrootd -c /etc/xrootd/xrootd-standalone.cfg"
expected_ports=("1094/tcp")
expected_volumes=("$SHARED_VOLUME_PATH:/jalien-dev" )



# Check if the Docker container is running
if sudo docker ps --format '{{.Names}}' | grep -qw $CONTAINER_NAME_SE; then
    print_success "The JCentral container is running."

    # Check image
    actual_image=$(sudo docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME_SE")
    if [ "$actual_image" != "$expected_image" ]; then
        print_error "Error: $CONTAINER_NAME_SE is not using the expected image '$expected_image'."
    else
        print_success "Image is correct: $expected_image"
    fi

    # Check command
    actual_command=$(sudo docker inspect --format='{{.Config.Cmd}}' "$CONTAINER_NAME_SE")
    if [ ${#actual_command[@]} -eq 1 ] && [ "${actual_command[0]}" = "$expected_command" ]; then
        print_error "Error: $CONTAINER_NAME_SE does not have the expected command '$expected_command'."
    else
        print_success "Command is correct: $expected_command"
    fi

    # Check ports
    actual_ports=$(sudo docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}} {{end}}' "$CONTAINER_NAME_SE")
    for port in "${expected_ports[@]}"; do
        if [[ ! " ${actual_ports[*]} " =~  $port  ]]; then
            print_error "Error: Port $port is not found in the container's ports."
        else
            print_success "Port $port is correct."
        fi
    done

    # Check volumes
    actual_volumes=$(sudo docker inspect --format='{{range .Mounts}}{{.Source}}:{{.Destination}}:{{.Mode}} {{end}}' "$CONTAINER_NAME_SE")
    for volume in "${expected_volumes[@]}"; do
        if [[ ! " ${actual_volumes[*]} " =~  $volume  ]]; then
            print_error "Error: Volume $volume is not found in the container's volumes."
        else
            print_success "Volume $volume is correct."
        fi
    done

else
    print_error "The $CONTAINER_NAME_SE is not running."
fi

