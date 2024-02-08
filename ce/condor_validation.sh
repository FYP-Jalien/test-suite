#!/bin/bash
source ../func/messages.sh
source ../.env

container_name="shared_volume-JCentral-dev-CE-1"

# Log in to the Docker container and run the "condor_q" command.
output1=$(sudo docker exec -it "$CONTAINER_NAME_CE" /bin/bash -c "condor_q")
output2=$(sudo docker exec -it "$CONTAINER_NAME_CE" /bin/bash -c "condor_status")

# Check if condor_q is working.
if echo "$output1" | grep -q 'Schedd: localhost.localdomain'; then
    print_success "Success! condor_q is working."
else
    print_error "Error! condor_q is not working."
fi

# Check if condor_status is working.
if echo "$output2" | grep -q 'Name\s*OpSys\s*Arch\s*State\s*Activity\s*LoadAv\s*Mem\s*ActvtyTime'; then
    print_success "Success! condor_status is working."
else
    print_error "Error! condor_status is not working."
fi
