#!/bin/bash

# # Running the se tests.
# cd se/
# source run_all_tests.sh

# # Running the central tests.
# cd central/
# source run_all_tests.sh

# # Running the CE tests.
# cd ce/
# source run_all_tests.sh

# # Running the job submission tests.
# cd job_submission/
# source run_all_tests.sh

# shellcheck disable=SC1091
source func/messages.sh
source func/conversions.sh
source .env



id=0

source common/index.sh
source central/index.sh
source schedd/index.sh
source se/index.sh
source ce/index.sh
source worker/index.sh

