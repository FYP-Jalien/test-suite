#!/bin/bash

# Remove the output directory if existing
if "$JALIEN_PATH/jalien" -e ls | grep -q "^output_dir_new$"; then
    "$JALIEN_PATH/jalien" -e rm -rf output_dir_new
fi

id=$((id + 1))
name="Submit sample JDL check"
level="Critical"
description="Sample JDL should be submitted to JCentral"
if result=$(remove_color "$("$JALIEN_PATH/jalien" -e submit "./sample.jdl")"); then
    if echo "$result" | grep -q "Submitting /localhost/localdomain/user/j/jalien/sample.jdl" && echo "$result" | grep -q "Your new job ID is [0-9]\+$"; then
        job_id=$(echo "$result" | awk '/Your new job ID is/ {print $NF}')
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "Job submitted successfully. Job ID: $job_id"
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "Job submission failed or output format is not as expected."
    fi
else
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Job submission failed."
fi
