#!/bin/bash

source ../func/messages.sh

# Specify the Docker image name
DOCKER_IMAGE="shared_volume-JCentral-dev-CE-1"

# Check if the Docker container is running
if sudo docker ps --format '{{.Names}}' | grep -q "$DOCKER_IMAGE"; then
    print_success "The Docker container is running."
else
    print_error "The Docker container is not running."
fi
