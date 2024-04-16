#!/bin/bash

function get_job_state() {
    result=$(remove_color "$("$JALIEN_PATH/jalien" -e ps)")
    job_row=$(grep "jalien[[:space:]]\{1,\}$1" <<<"$result")
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
    start_time=$SECONDS
    timeout=$((SECONDS + 60))
    while :; do
        state=$(get_job_state "$job_id")
        if [[ -z $state ]]; then
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "Job ID $job_id either not found or has a different format."
            break
        fi
        if [[ $state == "W" ]] || [[ $state == "_D" ]] || [[ $state == "ASG" ]]; then
            print_full_test "$id" "$name" "PASSED" "$description" "$level" "Job $job_id is in $state State."
            break
        elif [[ $state == "I" ]]; then
            if [[ $SECONDS -gt $timeout ]]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Timeout reached. Job state did not transition to 'W' within 60 seconds."
                break
            else
                echo "Current Job ID : $job_id"
                "$JALIEN_PATH/jalien" -e ps
                echo "Waiting for $(("$SECONDS" - "$start_time")) seconds"
            fi
        else
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "Unexpected state : $state"
            break
        fi
    done
elif [[ $state == "W" ]] || [[ $state == "_D" ]] || [[ $state == "ASG" ]]; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Job $job_id is in $state State."
fi

id=$((id + 1))
name="Job state transition check: from W to _D"
level="Critical"
description="Job should be moved from state W to state _D"
timeout=$((SECONDS + 300))
while :; do
    state=$(get_job_state "$job_id")
    if [[ -z $state ]]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "Job ID $job_id either not found or has a different format."
        break
    fi

    if [[ $state == "D" ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "Job $job_id is in $state State."
        break
    elif [[ $state == "ESV" ]]; then
        print_full_test "$id" "$name" "FAILED" "$description" "Warning" "An error occurred in saving the job output. This can be due to an already existing output file/directory."
        break
    elif [[ $state == "W" ]]; then
        if [[ $SECONDS -gt $timeout ]]; then
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "Timeout reached. Job state did not transition to 'D' within 5 minutes."
            break
        else
            echo "Current Job ID : $job_id"
            "$JALIEN_PATH/jalien" -e ps
            echo "Waiting for $(("$SECONDS" - "$start_time")) seconds"
        fi
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "Unexpected state : $state"
    fi
done
