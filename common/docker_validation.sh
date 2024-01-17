#!/bin/bash

# Check if Docker is installed
if command -v docker &> /dev/null ; then
    echo "Docker is installed on the system."
else
    echo "Docker is not installed on the system. Please install Docker before proceeding."
fi
