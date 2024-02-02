#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Running the common tests.
cd common/
source run_all_tests.sh


# Running the CE tests.
cd ce/
source run_all_tests.sh