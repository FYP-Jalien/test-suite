#!/bin/bash

shared_volume_env="$SHARED_VOLUME_PATH/env_setup.sh"

id=$((id + 1))
name="Shared Volume check"
level="Critical"
description="$shared_volume_env must be present."

# Check if the testscript exists
if [ ! -f "$shared_volume_env" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$shared_volume_env does not exist."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "$shared_volume_env exists."
fi
