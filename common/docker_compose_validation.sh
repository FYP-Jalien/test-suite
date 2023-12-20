#!/bin/bash

# Check if Docker Compose is installed
if command -v docker compose &> /dev/null ; then
    echo "Docker Compose is installed on the system."
else
    echo "Docker Compose is not installed on the system. Please install Docker Compose before proceeding."
fi
