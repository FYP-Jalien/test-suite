#!/bin/bash

# Check if MySQL is installed
if command -v mysql &> /dev/null ; then
    echo "MySQL is installed on the system."
else
    echo "MySQL is not installed on the system. Please install MySQL before proceeding."
fi
