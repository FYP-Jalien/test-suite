#!/bin/bash

source ../func/messages.sh
source ../.env

JALIEN_DEV=/jalien-dev
JALIEN_SETUP=/jalien-setup
LOGS=$JALIEN_DEV/logs

directory_paths=("/jalien-dev" "/jalien-setup" "/root/.alien/testVO" "/root/.globus" "$JALIEN_DEV" "$JALIEN_DEV/logs" "$JALIEN_SETUP" )
file_paths=("$LOGS/setup_log.txt" "/root/.globus/alien.p12" "$LOGS/jcentral-stdout.txt" )



file_path="/docker-setup.sh"
if sudo docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME_CENTRAL$"; then

    # Check directories
    for file_path in "${file_paths[@]}"; do
        if sudo docker exec $CONTAINER_NAME_CENTRAL [ -e "$file_path" ]; then
            print_success "File $file_path exists in the container $CONTAINER_NAME_CENTRAL."
        else
            print_error "File $file_path does not exist in the container $CONTAINER_NAME_CENTRAL."
        fi    
    done

    for directory_path in "${directory_paths[@]}"; do
        if sudo docker exec $CONTAINER_NAME_CENTRAL [ -e "$directory_path" ]; then
            print_success "Directory $directory_path exists in the container $CONTAINER_NAME_CENTRAL."
        else
            print_error "Directory $directory_path does not exist in the container $CONTAINER_NAME_CENTRAL."
        fi   
    done


else
     print_error "The $CONTAINER_NAME_CENTRAL is not running."
fi