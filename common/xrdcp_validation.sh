#!/bin/bash

id=$((id + 1))
name="Host Xrootd Check"
description="Host machine requires Xrootd to be installed to handle SE operations"
level="Critical"

if xrdcp --version &>/dev/null; then
    status="PASSED"
    message="Xrootd is installed in the system"
else
    status="FAILED"
    message="Host machine requires Xrootd to be installed to compile the jalien"
fi

print_full_test "$id" "$name" $status "$description" $level "$message"
