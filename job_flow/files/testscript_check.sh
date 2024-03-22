#!/bin/bash

id=$((id + 1))
name="Testscript check"
level="Critical"
description="$TESTSCRIPT_PATH must be present to be used in tests"

# Check if the testscript exists
if [ ! -f "$TESTSCRIPT_PATH" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$TESTSCRIPT_PATH does not exist."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "$TESTSCRIPT_PATH exists."
fi
