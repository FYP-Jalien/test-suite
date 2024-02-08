#!/bin/bash

source ../func/messages.sh
source ../.env


# Check if the Docker container is running
if sudo docker ps --format '{{.Names}}' | grep -q "$CONTAINER_NAME_CE"; then
    print_success "The Docker container is running."
else
    print_error "The Docker container is not running."
fi
