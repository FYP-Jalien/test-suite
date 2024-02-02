#!/bin/bash

source ../func/messages.sh

# Check if Python 3 is installed
if command -v python3 &> /dev/null ; then
    print_success "Python 3 is installed on the system."
else
    print_error "Python 3 is not installed on the system. Please install Python 3 before proceeding."
fi
