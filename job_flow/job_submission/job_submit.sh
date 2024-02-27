#!/bin/bash

id=$((id + 1))
name="Submit sample JDL check"
level="Critical"
description="Sample JDL should be submitted to JCentral"
job_result=$(alien.py submit "./sample.jdl")

if result=$(alien.py submit "./sample.jdl"); then
    if echo "$result" | grep -q "Submitting /localhost/localdomain/user/j/jalien/sample.jdl" && echo "$result" | grep -q "^Your new job ID is [0-9]\+$"; then
        job_id=$(echo "$job_result" | awk '/Your new job ID is/ {print $NF}')
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "Job submitted successfully. Job ID: $job_id"
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "Job submission failed or output format is not as expected."
    fi
else
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Job submission failed."
fi
