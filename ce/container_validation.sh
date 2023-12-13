#!/bin/bash

# Specify the Docker image name
DOCKER_IMAGE="shared_volume-JCentral-dev-CE-1"

# Check if the Docker container is running
if sudo docker ps --format '{{.Names}}' | grep -q "$DOCKER_IMAGE"; then
    echo "The Docker container is running."
else
    echo "The Docker container is not running."
fi
