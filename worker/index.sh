#!/bin/bash

set -e

index_file_name="worker"

source $index_file_name/container_validation.sh
source $index_file_name/package_check.sh
source $index_file_name/file_check.sh
source $index_file_name/condor_validation.sh
