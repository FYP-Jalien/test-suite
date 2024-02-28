#!/bin/bash

id=$((id + 1))
name="Sample Test JDL check"
level="Critical"
description="$SAMPLE_JDL_PATH must be present to be used in tests"

# Check if the sample jdl exists
if [ ! -f "$SAMPLE_JDL_PATH" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$SAMPLE_JDL_PATH does not exist."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "$SAMPLE_JDL_PATH exists."
fi