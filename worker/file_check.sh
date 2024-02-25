#!/bin/bash

id=$((id + 1))
name="Worker Container File Check"
level="Critical"
file_paths=("/docker-setup.sh")
description="Worker container should have these files: $(convert_array_to_string "${file_paths[@]}")."
status="PASSED"
for file_path in "${file_paths[@]}"; do
    if ! sudo docker exec "$CONTAINER_NAME_WORKER" [ -e "$file_path" ]; then
        status="FAILED"
        message="File $file_path does not exist in the container $CONTAINER_NAME_WORKER."
        print_full_test "$id" "$name" "$status" "$description" "$level" "$message"
    fi
done
if [ "$status" == "PASSED" ]; then
    message="All files exist in the container $CONTAINER_NAME_WORKER."
        print_full_test "$id" "$name" "$status" "$description" "$level" "$message"
fi

id=$((id + 1))
name="Worker Container Directory Check"
level="Critical"
directory_paths=("/var/lib/condor/execute")
description="Worker container should have these directories: $(convert_array_to_string "${directory_paths[@]}")."
status="PASSED"
for directory_path in "${directory_paths[@]}"; do
    if ! sudo docker exec "$CONTAINER_NAME_WORKER" [ -e "$directory_path" ]; then
        status="FAILED"
        message="Directory $directory_path does not exist in the container $CONTAINER_NAME_WORKER."
        print_full_test "$id" "$name" "$status" "$description" "$level" "$message"
    fi
done
if [ "$status" == "PASSED" ]; then
    message="All directories exist in the container $CONTAINER_NAME_WORKER."
        print_full_test "$id" "$name" "$status" "$description" "$level" "$message"
fi