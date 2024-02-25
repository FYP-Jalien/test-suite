#!/bin/bash

JALIEN_DEV=/jalien-dev
JALIEN_SETUP=/jalien-setup
LOGS=$JALIEN_DEV/logs

id=$((id + 1))
name="Central Container Directory Check"
level="Critical"
directory_paths=("/jalien-dev" "/jalien-setup" "/root/.alien/testVO" "/root/.globus" "$JALIEN_DEV" "$JALIEN_DEV/logs" "$JALIEN_SETUP")
description="Central container should have these directories: $(convert_array_to_string "${directory_paths[@]}")."
status="PASSED"
for directory_path in "${directory_paths[@]}"; do
    if ! sudo docker exec "$CONTAINER_NAME_CENTRAL" [ -e "$directory_path" ]; then
        status="FAILED"
        message="Directory $directory_path does not exist in the container $CONTAINER_NAME_CENTRAL."
        print_full_test "$id" "$name" "$status" "$description" "$level" "$message"
    fi
done
if [ "$status" == "PASSED" ]; then
    message="All directories exist in the container $CONTAINER_NAME_CENTRAL."
        print_full_test "$id" "$name" "$status" "$description" "$level" "$message"
fi

id=$((id + 1))
name="Central Container File Check"
level="Critical"
file_paths=("$LOGS/setup_log.txt" "/root/.globus/alien.p12" "/docker-setup.sh")
description="Central container should have these files: $(convert_array_to_string "${file_paths[@]}")."
status="PASSED"
for file_path in "${file_paths[@]}"; do
    if ! sudo docker exec "$CONTAINER_NAME_CENTRAL" [ -e "$file_path" ]; then
        status="FAILED"
        message="File $file_path does not exist in the container $CONTAINER_NAME_CENTRAL."
        print_full_test "$id" "$name" "$status" "$description" "$level" "$message"
    fi
done
if [ "$status" == "PASSED" ]; then
    message="All files exist in the container $CONTAINER_NAME_CENTRAL."
        print_full_test "$id" "$name" "$status" "$description" "$level" "$message"
fi
