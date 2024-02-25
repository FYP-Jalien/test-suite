#!/bin/bash

id=$((id + 1))
name="Worker Container condor_status check"
level="Critical"
description="condor_status should give the status of the condor"

condor_status_output=$(sudo docker exec -it "$CONTAINER_NAME_WORKER" /bin/bash -c condor_status)

if echo "$condor_status_output" | grep -q "slot" && echo "$condor_status_output" | grep -q "Total Owner Claimed Unclaimed Matched Preempting Backfill  Drain"; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "condor_status is working"
else
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "condor_status is not working"
fi