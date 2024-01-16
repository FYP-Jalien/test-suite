#!/bin/bash

source ../func/messages.sh

JALIEN_DEV=/jalien-dev
JALIEN_SETUP=/jalien-setup
LOGS=$JALIEN_DEV/logs

container_name="shared_volume_JCentral-dev_1"
directory_paths=("/jalien-dev" "/jalien-setup" "/root/.alien/testVO" "/root/.globus" "$JALIEN_DEV" "$JALIEN_DEV/logs" "$JALIEN_SETUP" )
file_paths=("$LOGS/setup_log.txt" "/root/.globus/alien.p12" "$LOGS/jcentral-stdout.txt" )



file_path="/docker-setup.sh"
if sudo docker ps --format '{{.Names}}' | grep -q "^$container_name$"; then

    # Check directories
    for file_path in "${file_paths[@]}"; do
        if sudo docker exec $container_name [ -e "$file_path" ]; then
            print_success "File $file_path exists in the container $container_name."
        else
            print_error "File $file_path does not exist in the container $container_name."
        fi    
    done

    for directory_path in "${directory_paths[@]}"; do
        if sudo docker exec $container_name [ -e "$directory_path" ]; then
            print_success "Directory $directory_path exists in the container $container_name."
        else
            print_error "Directory $directory_path does not exist in the container $container_name."
        fi   
    done


else
     print_error "The $container_name is not running."
fi