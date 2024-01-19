#!/bin/bash
source ../func/messages.sh

container_name="shared_volume-JCentral-dev-CE-1"

# Log in to the Docker container and run the "condor_q" command
output1=$(sudo docker exec -it "$container_name" /bin/bash -c "condor_q")
output2=$(sudo docker exec -it "$container_name" /bin/bash -c "condor_q")

# Check if both outputs contain the specified substring
if [[ $output1 == *"-- Schedd: localhost.localdomain"* && $output2 == *"-- Schedd: localhost.localdomain"* ]]; then
    print_success "Success! condor_q and condor_status is working."
else
    print_error "Error! condor_q or condor_status is not working."
fi
