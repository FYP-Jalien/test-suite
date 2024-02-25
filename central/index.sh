#!/bin/bash

set -e

index_file_name="central"

source $index_file_name/container_validation.sh
source $index_file_name/package_check.sh
source $index_file_name/file_check.sh
source $index_file_name/mysql/mysql.sh
source $index_file_name/ldap/ldap.sh
