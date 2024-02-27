#!/bin/bash

id=$((id + 1))
name="alma-alienv check"
level="Critical"
description="$ALIENV_PATH must be present and executable to start alien.py"

# Check if the alienv script exists
if [ ! -f "$ALIENV_PATH" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$ALIENV_PATH does not exist."
fi

# Check if the alienv script is executable
if [ ! -x "$ALIENV_PATH" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$ALIENV_PATH is not executable."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "$ALIENV_PATH exists and is executable."
fi