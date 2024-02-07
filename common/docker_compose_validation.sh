#!/bin/bash

source ../func/messages.sh

# Check if Docker Compose is installed
if command -v docker compose &> /dev/null ; then
    print_success "Docker Compose is installed on the system."
else
    print_error "Docker Compose is not installed on the system. Please install Docker Compose before proceeding."
fi
