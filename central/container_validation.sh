#!/bin/bash

. ../func/messages.sh

SHARED_VOLUME="/home/jananga/FYP/SHARED_VOLUME"
JALIEN_SETUP_DIR="/home/jananga/FYP/jalien-setup"

container_name="shared_volume_JCentral-dev_1"
expected_image="jalien-base-18"
expected_command="/jalien-setup/bash-setup/entrypoint.sh"
expected_ports=("8098/tcp" "8097/tcp" "3307/tcp" "8389/tcp")
expected_volumes=("$SHARED_VOLUME:/jalien-dev:rw" "$JALIEN_SETUP_DIR:/jalien-setup:ro")
healthcheck_commands=("mysql --verbose --host=127.0.0.1 --port=3307 --password=pass --user=root --execute \"SHOW DATABASES;\"" "ldapsearch -x -b \"o=localhost,dc=localdomain\" -H ldap://localhost:8389")
expected_start_period="600s"
expected_environment="SE_HOST=JCentral-dev-SE"


# Check if the Docker container is running
if sudo docker ps --format '{{.Names}}' | grep -qw $container_name; then
    print_success "The JCentral container is running."

    # Check image
    actual_image=$(sudo docker inspect --format='{{.Config.Image}}' "$container_name")
    if [ "$actual_image" != "$expected_image" ]; then
        print_error "Error: $container_name is not using the expected image '$expected_image'."
    else
        print_success "Image is correct: $expected_image"
    fi

    # Check command
    actual_command=$(sudo docker inspect --format='{{.Config.Cmd}}' "$container_name")
    if [ ${#actual_command[@]} -eq 1 ] && [ "${actual_command[0]}" = "$expected_command" ]; then
        print_error "Error: $container_name does not have the expected command '$expected_command'."
    else
        print_success "Command is correct: $expected_command"
    fi

    # Check ports
    actual_ports=$(sudo docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}} {{end}}' "$container_name")
    for port in "${expected_ports[@]}"; do
        if [[ ! " ${actual_ports[@]} " =~ " $port " ]]; then
            print_error "Error: Port $port is not found in the container's ports."
        else
            print_success "Port $port is correct."
        fi
    done

    # Check volumes
    actual_volumes=$(sudo docker inspect --format='{{range .Mounts}}{{.Source}}:{{.Destination}}:{{.Mode}} {{end}}' "$container_name")
    for volume in "${expected_volumes[@]}"; do
        if [[ ! " ${actual_volumes[@]} " =~ " $volume " ]]; then
            print_error "Error: Volume $volume is not found in the container's volumes."
        else
            print_success "Volume $volume is correct."
        fi
    done

    # Check healthcheck
    actual_healthcheck=$(sudo docker inspect --format='{{.Config.Healthcheck}}' "$container_name")
    if [ -z "$actual_healthcheck" ]; then
        print_error "Error: $container_name does not have a healthcheck."
    else
        print_success "Healthcheck is present."
    fi

    # Check environment variables
    actual_environment=$(sudo docker inspect --format='{{range $key, $value := .Config.Env}}{{$value}} {{end}}' "$container_name")
    for env in "${expected_environment[@]}"; do
        if [[ ! " ${actual_environment[@]} " =~ " $env " ]]; then
            print_error "Error: env $env is not set in the container's environment."
        else
            print_success "env $env is set."
        fi
    done

else
    print_error "The $container_name is not running."
fi

