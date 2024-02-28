#!/bin/bash

function get_job_state() {
    result=$(alien.py ps)
    job_row=$(grep "jalien $1" <<<"$result")
    if [ -n "$job_row" ]; then
        echo "$job_row" | awk '{split($0, a); print a[NF-1]}'
    fi
}

id=$((id + 1))
name="Job state transition check: from I to W"
level="Critical"
description="Job should be moved from state I to state W"
# shellcheck disable=SC2154
state=$(get_job_state "$job_id")
if [[ -z $state ]]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Job ID $job_id either not found or has a different format."
fi

if [[ $state == "I" ]]; then
    echo "Waiting 45 seconds to start the job."
    sleep 45
    state=$(get_job_state "$job_id")
    if [[ -z $state ]]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "Job ID $job_id either not found or has a different format."
    fi

    if [[ $state == "I" ]]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "Job $job_id is in $state State and should be moved to W. Check whether the optimiser is running and error logs. "
    elif [[ $state == "W" ]] || [[ $state == "_D" ]] || [[ $state == "ASG" ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "Job $job_id is in $state State."
    fi
elif [[ $state == "W" ]] || [[ $state == "_D" ]] || [[ $state == "ASG" ]]; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Job $job_id is in $state State."
fi

id=$((id + 1))
name="Job state transition check: from W to _D"
level="Critical"
description="Job should be moved from state W to state _D"
echo "Waiting 5 minutes to complete the job."
sleep 300
state=$(get_job_state "$job_id")
if [[ -z $state ]]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Job ID $job_id either not found or has a different format."
fi

if [[ $state == "W" ]]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$job_id still is W state. Please check the logs"
elif [[ $state == "D" ]]; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Job $job_id is in $state State."
elif [[ $state == "ESV" ]]; then
    print_full_test "$id" "$name" "FAILED" "$description" "Warning" "An error occured in saving the job output. This can be due to already existing output file/directory."
else
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Unexpected state : $state"
fi
