#!/bin/bash

source ../func/messages.sh

container_name="shared_volume-JCentral-dev-CE-1"

# Log in to the Docker container and run the "condor_q" command
directory="/home/submituser/tmp"
pattern="agent.startup\.[0-9]+"

# Array to store file names that match the pattern
matching_files=()

# Iterate over files in the directory and check if any matches the regex
while IFS= read -r -d '' file; do
    if [[ "$file" =~ $pattern ]]; then
        matching_files+=("$file")
        print_success "Success. Found job agent script."
    fi
done < <(sudo docker exec -it "$container_name" find "$directory" -type f -name "agent.startup.*" -print0)

# Check if any matching file is found
if [ ${#matching_files[@]} -gt 0 ]; then
    # Find the latest file based on numeric suffix
    latest_file=$(printf "%s\n" "${matching_files[@]}" | sort -t. -k4 -n | tail -n 1)

    validate_content(){
    if sudo docker exec -it "$container_name" /bin/bash -c "grep -q "$1" '$latest_file'"; then
        print_success "Success. $1 found in $latest_file."
    else
        print_error "$1 not found in $latest_file."
    fi
}

    # Check if JALIEN_TOKEN_Key exists in the latest file
    validate_content "JALIEN_TOKEN_KEY"
    # Check if JALIEN_TOKEN_Cert exists in the latest file
    validate_content "JALIEN_TOKEN_CERT"
    # Check if JALIEN_JOBAGENT_CMD exists in the latest file
    validate_content "JALIEN_JOBAGENT_CMD"

else
    print_error "No matching file found in $directory."
fi
