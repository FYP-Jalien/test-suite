#!/bin/bash

id=$((id + 1))
name="Host Python3 Check"
description="Host machine requires Python to be installed to run the JShell via alien.py"
level="Critical"

# Check if Python 3 is installed
if command -v python3 &> /dev/null ; then
    status="PASSED"
    message="Python 3 is installed on the system."

else
    status="FAILED"
    message="Python 3 is not installed on the system. Please install Python 3 before proceeding."
fi

print_full_test "$id" "$name" $status "$description" $level "$message"
