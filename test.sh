#!/bin/bash

# Check if the script is run as root.
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Running the common tests.
cd common/
source run_all_tests.sh

# Running the schedd tests.
cd schedd/
source run_all_tests.sh

# Running the se tests.
cd se/
source run_all_tests.sh

# Running the central tests.
cd central/
source run_all_tests.sh

# Running the CE tests.
cd ce/
source run_all_tests.sh

# Running the job submission tests.
cd job_submission/
source run_all_tests.sh
