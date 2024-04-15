#!/bin/bash

# shellcheck source=/dev/null

id=$((id + 1))
name="Host Java Version Check"
description="Host machine requires Java to be installed to compile the jalien"
level="Critical"

if command -v java cersion &>/dev/null; then
    status="PASSED"
    message="Java is installed in the system"
else
    status="FAILED"
    message="Host machine requires Java to be installed to compile the jalien"
fi

print_full_test "$id" "$name" $status "$description" $level "$message"
