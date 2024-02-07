#!/bin/bash

source ../func/messages.sh

# Check if MySQL is installed
if command -v mysql &> /dev/null ; then
    print_success "MySQL is installed on the system."
else
    print_error "MySQL is not installed on the system. Please install MySQL before proceeding."
fi
