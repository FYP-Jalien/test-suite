#!/bin/bash

source ../.env

success_color="\033[32m"
error_color="\033[31m"
reset_color="\033[0m"

file_path="/docker-setup.sh"
if sudo docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME_WORKER$"; then
    # Check if the file exists in the container
    if sudo docker exec $CONTAINER_NAME_WORKER [ -e "$file_path" ]; then
        echo -e "${success_color}File $file_path exists in the container $CONTAINER_NAME_WORKER.${reset_color}"
    else
        echo -e "${error_color}File $file_path does not exist in the container $CONTAINER_NAME_WORKER.${reset_color}"
    fi
else
    echo -e "${error_color}Container $CONTAINER_NAME_WORKER is not running.${reset_color}"
fi
