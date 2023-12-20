#!/bin/bash

# Function to compare Java versions
compare_versions() {
    local v1="$1"
    local v2="$2"
    local IFS=.
    local i v1array=($v1) v2array=($v2)

    # Fill empty positions with zeros
    for ((i=${#v1array[@]}; i<${#v2array[@]}; i++)); do
        v1array[i]=0
    done

    for ((i=0; i<${#v1array[@]}; i++)); do
        if [ -z "${v2array[i]}" ]; then
            v2array[i]=0
        fi

        if ((10#${v1array[i]} > 10#${v2array[i]})); then
            return 1
        elif ((10#${v1array[i]} < 10#${v2array[i]})); then
            return 2
        fi
    done

    return 0
}

# Check Java version
java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')

echo "Installed Java Version: $java_version"

# Minimum required Java version (11.08)
required_version="11.08"

# Compare versions
compare_versions "$java_version" "$required_version"

if [ $? -eq 0 ] || [ $? -eq 1 ]; then
    echo "Java version is 11.08 or above."
else
    echo "Java version is below 11.08. Please install a newer version."
fi
