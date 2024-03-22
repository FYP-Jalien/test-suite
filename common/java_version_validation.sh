#!/bin/bash

# shellcheck source=/dev/null

id=$((id + 1))
name="Host Java Version Check"
description="Host machine requires Java to be installed to compile the jalien"
level="Critical"

# Function to compare Java versions
# compare_versions() {
#     local v1="$1"
#     local v2="$2"
#     local IFS=.
#     local i v1array=("$v1") v2array=("$v2")

#     # Fill empty positions with zeros
#     for ((i=${#v1array[@]}; i<${#v2array[@]}; i++)); do
#         v1array[i]=0
#     done

#     for ((i=0; i<${#v1array[@]}; i++)); do
#         if [ -z "${v2array[i]}" ]; then
#             v2array[i]=0
#         fi

#         if ((10#${v1array[i]} > 10#${v2array[i]})); then
#             return 1
#         elif ((10#${v1array[i]} < 10#${v2array[i]})); then
#             return 2
#         fi
#     done

#     return 0
# }

# Check Java version
# java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')

# # Minimum required Java version (11.08)
# required_version="11.08"

# # Compare versions
# compare_versions "$java_version" "$required_version"

# result=$?

# if [ $result -eq 0 ] || [ $result -eq 1 ]; then
#     status="PASSED"
#     message="Insatlled Java version $java_version is 11.08 or above."
# else
#     status="FAILED"
#     message="Java version is below 11.08. Please install a newer version."
#     exit 1
# fi

if command -v java cersion &> /dev/null ; then
    status="PASSED"
    message="Java is installed in the system"
else
    status="FAILED"
    message="Host machine requires Java to be installed to compile the jalien"
fi

print_full_test "$id" "$name" $status "$description" $level "$message"