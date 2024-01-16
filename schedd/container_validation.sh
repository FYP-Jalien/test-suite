#!/bin/bash

source ../func/messages.sh

JALIEN_SETUP_DIR="/home/jananga/FYP/jalien-setup"

container_name="shared_volume_schedd_1"
expected_image="htcondor/cm:10.0.0-el7"
expected_volumes=( "$JALIEN_SETUP_DIR"/ce-setup/htcondor-conf/pool_password )
expected_environment="USE_POOL_PASSWORD=yes "


# Check if the Docker container is running
if sudo docker ps --format '{{.Names}}' | grep -qw $container_name; then
    print_success "The schedd container is running."

    # Check image
    actual_image=$(sudo docker inspect --format='{{.Config.Image}}' "$container_name")
    if [ "$actual_image" != "$expected_image" ]; then
        print_error "Error: $container_name is not using the expected image '$expected_image'."
    else
        print_success "Image is correct: $expected_image"
    fi

    # Check volumes
    actual_volumes=$(sudo docker inspect --format='{{range .Mounts}}{{.Source}}:{{.Destination}}:{{.Mode}} {{end}}' "$container_name")
    for volume in "${expected_volumes[@]}"; do
        if [[ ! " ${actual_volumes[*]} " =~  $volume  ]]; then
            print_error "Error: Volume $volume is not found in the container's volumes."
        else
            print_success "Volume $volume is correct."
        fi
    done

    # Check environment variables
    actual_environment=$(sudo docker inspect --format='{{range $key, $value := .Config.Env}}{{$value}} {{end}}' "$container_name")
    for env in "${expected_environment[@]}"; do
        if [[ ! " ${actual_environment[*]} " =~  $env  ]]; then
            print_error "Error: env $env is not set in the container's environment."
        else
            print_success "env $env is set."
        fi
    done

else
    print_error "The $container_name is not running."
fi

