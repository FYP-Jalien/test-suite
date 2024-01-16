#!/bin/bash

# Check if Python 3 is installed
if command -v python3 &> /dev/null ; then
    echo "Python 3 is installed on the system."
else
    echo "Python 3 is not installed on the system. Please install Python 3 before proceeding."
fi
