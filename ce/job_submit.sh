#!/bin/bash

: <<'COMMENT'
This script is used to test the jdl file is created in the htcondor directory in the CE container.
It will only look for the most recent file which should be created on the current date.
After checking the file presence, it will also check the content in the .jdl file.

Note: In here for the file validation we are only validating the file reference in cmd since other files are created 
by the worker node and not the CE.
COMMENT

source ../func/messages.sh
source ../.env

current_date=$(date +'%Y-%m-%d')
directory_path="/home/submituser/htcondor/$current_date"


# Get the most recent .jdl file
most_recent_jdl=$(sudo docker exec -it "$CONTAINER_NAME_CE" bash -c "ls -t $directory_path/*.jdl 2>/dev/null | head -n 1")

# Remove trailing \r characters from the file name
most_recent_jdl=$(echo "$most_recent_jdl" | tr -d '\r')

# Check if any .jdl file exists
if [ -n "$most_recent_jdl" ]; then
    print_success "Success. jdl file found: $most_recent_jdl"
else
    print_error "Error. No jdl file found."
fi

# Function to validate the content of the most recent .jdl file.
validate_content(){
    content=$(sudo docker exec -it "$CONTAINER_NAME_CE" /bin/bash -c "grep '$1' '$most_recent_jdl'")
    if [ -n "$content" ]; then
        print_success "Success. $1 variable found in .jdl file."
        file_path=$(echo "$content" | awk -F ' = ' '{print $2}' | tr -d '\r')
    else
        print_error "$1 not found in .jdl file."
    fi
}

# Function to validate the file existence in the container.
validate_file(){
    if sudo docker exec -it "$CONTAINER_NAME_CE" /bin/bash -c "test -e '$1'"; then
        print_success "Success. $1 file found."
    else
        print_error "Error. $1 file not found."
    fi
}

# Validate the content of the most recent .jdl file.

validate_content "log"
validate_content "output"
validate_content "error"
validate_content "cmd"

# Validate the job agent file existence in the container.
validate_file $file_path
