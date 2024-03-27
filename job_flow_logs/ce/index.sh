#!/bin/bash

set -e

index_file_name="job_flow_logs/ce"

source "$index_file_name/agent_script_validation.sh"
source "$index_file_name/htc_submit_script_validation.sh"
source "$index_file_name/condor_log_scripts_validation.sh"