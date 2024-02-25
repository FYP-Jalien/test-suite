#!/bin/bash

source /host_func/messages.sh
source ../../.env

script_path="mysql.sh"
script_path_in_container="/mysql_test.sh"

func_path="../../func/"
func_path_in_container="/host_func/"

# Check if the Docker container is running
if sudo docker ps --format '{{.Names}}' | grep -qw $CONTAINER_NAME_CENTRAL; then
    chmod +x $script_path
    sudo docker cp $func_path $CONTAINER_NAME_CENTRAL:$func_path_in_container
    sudo docker cp $script_path $CONTAINER_NAME_CENTRAL:$script_path_in_container
    sudo docker exec -it $CONTAINER_NAME_CENTRAL /bin/bash -c "$script_path_in_container"
    sudo docker exec -it $CONTAINER_NAME_CENTRAL rm $script_path_in_container
    sudo docker exec -it $CONTAINER_NAME_CENTRAL rm -r $func_path_in_container
else
    print_error "The $CONTAINER_NAME_CENTRAL is not running."
fi
