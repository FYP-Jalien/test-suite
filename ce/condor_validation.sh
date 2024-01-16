#!/bin/bash

container_name="shared_volume-JCentral-dev-SE-1"

# Log in to the Docker container and run the "condor_q" command
output=$(sudo docker exec -it "$container_name" /bin/bash -c "condor_q")

# Check if the output contains the specified substring
if [[ $output == *"-- Schedd: localhost.localdomain"* ]]; then
    echo "Success! Condor is working."
else
    echo "Error! Condor is not working."
fi
