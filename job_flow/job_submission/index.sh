#!/bin/bash

set -e

index_file_name="job_flow/job_submission"

source "$index_file_name/job_submit.sh"
source "$index_file_name/state_change.sh"