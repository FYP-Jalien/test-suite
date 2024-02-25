#!/bin/bash

set -e

index_file_name="common"

source $index_file_name/python3_validation.sh
source $index_file_name/java_version_validation.sh
source $index_file_name/docker_validation.sh
source $index_file_name/docker_compose_validation.sh

