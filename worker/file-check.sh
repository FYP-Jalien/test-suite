#!/bin/bash

success_color="\033[32m"
error_color="\033[31m"
reset_color="\033[0m"

container_name="shared_volume_worker1_1"
file_path="/docker-setup.sh"
if sudo docker ps --format '{{.Names}}' | grep -q "^$container_name$"; then
    # Check if the file exists in the container
    if sudo docker exec $container_name [ -e "$file_path" ]; then
        echo -e "${success_color}File $file_path exists in the container $container_name.${reset_color}"
    else
        echo -e "${error_color}File $file_path does not exist in the container $container_name.${reset_color}"
    fi
else
    echo -e "${error_color}Container $container_name is not running.${reset_color}"
fi