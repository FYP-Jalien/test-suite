#!/bin/bash

source ../func/messages.sh

# Check if Docker is installed
if command -v docker &> /dev/null ; then
    print_success "Docker is installed on the system."
else
    print_error "Docker is not installed on the system. Please install Docker before proceeding."
fi
