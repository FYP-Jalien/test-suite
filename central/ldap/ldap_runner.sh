#!/bin/bash

source ../../func/messages.sh

container_name="shared_volume_JCentral-dev_1"

script_path="ldap.sh"
script_path_in_container="/ldap_test.sh"

func_path="../../func/"
func_path_in_container="/host_func/"

# Check if the Docker container is running
if sudo docker ps --format '{{.Names}}' | grep -qw $container_name; then
    chmod +x $script_path
    sudo docker cp $func_path $container_name:$func_path_in_container
    sudo docker cp $script_path $container_name:$script_path_in_container
    sudo docker exec -it $container_name /bin/bash -c "$script_path_in_container"
    sudo docker exec -it $container_name rm $script_path_in_container
    sudo docker exec -it $container_name rm -r $func_path_in_container
else
    print_error "The $container_name is not running."
fi