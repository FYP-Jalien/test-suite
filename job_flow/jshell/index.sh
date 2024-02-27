#!/bin/bash

shared_volume_env="$SHARED_VOLUME_PATH/env_setup.sh"

id=$((id + 1))
name="Alma-alienv xjalienfs setenv test"
level="Critical"
description="Alma-alienv xjalienfs set as env to run alien.py"
# shellcheck disable=SC1090
if ! source "$ALIENV_PATH" setenv xjalienfs; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Could not source $ALIENV_PATH setenv xjalienfs"
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Alienv setenv xjalienfs."
fi

id=$((id + 1))
name="Shared Volume env setenv test"
level="Critical"
description="Shared Volume env set as env to connect JCental when running alien.py"
# shellcheck disable=SC1090
if ! source "$shared_volume_env"; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Could not source $shared_volume_env"
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Shared Volume env set."
fi

id=$((id + 1))
name="alien.py start test"
level="Critical"
description="alien.py should be started"

if ! alien.py ls > /dev/null ; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Failed to start alien.py. Check JCentral is up and available."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "alien.py started."
fi