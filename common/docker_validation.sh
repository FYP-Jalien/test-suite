#!/bin/bash

id=$((id + 1))
name="Host Docker-Compose Check"
description="Host machine requires Docker to be installed to run the jalien-setup."
level="Critical"

if command -v docker &> /dev/null ; then
    message="Docker is installed on the system."
    status="PASSED"
else
    status="FAILED"
    message="Docker is not installed on the system."
fi

print_full_test "$id" "$name" $status "$description" $level "$message"