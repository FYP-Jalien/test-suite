#!/bin/bash

id=$((id + 1))
name="CE Container condor_status check"
level="Critical"
description="condor_status should give the status of the condor"

condor_status_output=$(sudo docker exec -t "$CONTAINER_NAME_CE" /bin/bash -c condor_status)

if echo "$condor_status_output" | grep -q "slot" && echo "$condor_status_output" | grep -q "Total Owner Claimed Unclaimed Matched"; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "condor_status is working"
else
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "condor_status is not working"
fi

id=$((id + 1))
name="CE Container condor_q check"
level="Critical"
description="condor_q should give the queue status of the condor"

condor_q_output=$(sudo docker exec -t "$CONTAINER_NAME_CE" /bin/bash -c condor_q)

if echo "$condor_q_output" | grep -q "Schedd: localhost.localdomain"; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "condor_q is working"
else
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "condor_q is not working"
fi
