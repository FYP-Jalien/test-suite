#!/bin/bash

set -e

index_file_name="job_flow"
source "$index_file_name/files/index.sh"

index_file_name="job_flow"
source "$index_file_name/jshell/index.sh"


index_file_name="job_flow"
source "$index_file_name/se_operations/index.sh"

index_file_name="job_flow"
source "$index_file_name/job_submission/index.sh"

index_file_name="job_flow"
source "$index_file_name/ce/index.sh"

index_file_name="job_flow"
source "$index_file_name/worker/index.sh"
