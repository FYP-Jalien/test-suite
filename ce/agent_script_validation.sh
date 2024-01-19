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
        print_success "Success. Found job agent scripts."
    fi
done < <(sudo docker exec -it "$container_name" find "$directory" -type f -name "agent.startup.*" -print0)

# Check if any matching file is found
if [ ${#matching_files[@]} -gt 0 ]; then
    # Find the latest file based on numeric suffix
    latest_file=$(printf "%s\n" "${matching_files[@]}" | sort -t. -k4 -n | tail -n 1)

    # Check if JALIEN_TOKEN_Key exists in the latest file
    if sudo docker exec -it "$container_name" /bin/bash -c "grep -q 'JALIEN_TOKEN_KEY' '$latest_file'"; then
        print_success "Success. JALIEN_TOKEN_KEY found in $latest_file."
        exit 0
    else
        print_error "JALIEN_TOKEN_KEY not found in $latest_file."
        exit 1
    fi
else
    print_error "No matching file found in $directory."
    exit 1
fi
