#!/bin/bash

set -e

index_file_name="job_flow/files"

source "$index_file_name/alienv_check.sh"
source "$index_file_name/sample_jdl_check.sh"
source "$index_file_name/testscript_check.sh"
source "$index_file_name/shared_volume_check.sh"