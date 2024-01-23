#!/bin/bash

source ../func/messages.sh

current_date=$(date +'%Y-%m-%d')
directory_path="/home/submituser/htcondor/$current_date"
container_name="shared_volume-JCentral-dev-CE-1"

# Get the most recent .jdl file
most_recent_jdl=$(sudo docker exec -it "$container_name" bash -c "ls -t $directory_path/*.jdl | head -n 1")

# Check if the most recent .jdl file exists
if [ -n "$most_recent_jdl" ]; then
    print_success "Success. jdl file found: $most_recent_jdl"
else
    print_error "Error. No jdl file found."
    exit 1
fi

# Function to validate the content of the most recent .jdl file.
validate_content(){
    if sudo docker exec -it "$container_name" /bin/bash -c "grep -q "$1" '$most_recent_jdl'"; then
        print_success "Success. $1 found in .jdl file."
    else
        print_error "$1 not found in .jdl file."
        exit 1
    fi
}

# Validate the content of the most recent .jdl file.
validate_content "cmd"



