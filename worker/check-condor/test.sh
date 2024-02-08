#!/bin/bash

source ../../func/messages.sh
source ../../.env

script_path="docker.sh"
script_path_in_container="/docker.sh"

func_path="../../func/"
func_path_in_container="/host_func/"

# Check if the Docker container is running
if sudo docker ps --format '{{.Names}}' | grep -qw $CONTAINER_NAME_WORKER; then
    chmod +x $script_path
    sudo docker cp $func_path $CONTAINER_NAME_WORKER:$func_path_in_container
    sudo docker cp $script_path $CONTAINER_NAME_WORKER:$script_path_in_container
    sudo docker exec -it $CONTAINER_NAME_WORKER /bin/bash -c "$script_path_in_container"
    sudo docker exec -it $CONTAINER_NAME_WORKER rm $script_path_in_container
    sudo docker exec -it $CONTAINER_NAME_WORKER rm -r $func_path_in_container
else
    print_error "The $CONTAINER_NAME_WORKER is not running."
fi