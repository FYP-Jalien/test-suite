#!/bin/bash

file="/home/submituser/JA-custom-1.sh"
id=$((id + 1))
name="Custom Job Agent Script Check"
level="Critical"
description="Custom job agent script should be present."
if docker exec "$CONTAINER_NAME_CE" [ ! -f "$file" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "File $file does not exist."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "File $file exists."
fi

ja_cutom_content=$(docker exec "$CONTAINER_NAME_CE" cat "$file")

id=$((id + 1))
name="Custom Job Agent Script Content Check"
level="Critical"
variable="PATH"
variable_value=$(echo "$ja_cutom_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
pattern='^export PATH=`echo \$PATH`\s*$'
description="Agent Startup Script $variable must be set to \`echo $PATH\`"
if [ -z "$variable_value" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
elif [[ "$variable_value" =~ $pattern ]]; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
else
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
fi


id=$((id + 1))
name="Agent Startup Script LD_LIBRARY_PATH Check"
level="Critical"
variable="LD_LIBRARY_PATH"
variable_value=$(echo "$ja_cutom_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
pattern='^export LD_LIBRARY_PATH=`echo \$LD_LIBRARY_PATH`\s*$'
description="Agent Startup Script $variable must be set to \`echo $LD_LIBRARY_PATH\`"
if [ -z "$variable_value" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
elif [[ "$variable_value" =~ $pattern ]]; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
else
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
fi

# function validate_ld_library_path() {
#     local variable="LD_LIBRARY_PATH"
#     local variable_value
#     variable_value=$(echo "$ja_cutom_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
#     # shellcheck disable=SC2016
#     local pattern='^export LD_LIBRARY_PATH=`echo \$LD_LIBRARY_PATH`\s*$'
#     id=$((id + 1))
#     name="Agent Startup Script $variable Check"
#     level="Critical"
#     description="Agent Startup Script $variable must be set to \`echo $LD_LIBRARY_PATH\`"
#     if [ -z "$variable_value" ]; then
#         print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
#     elif [[ "$variable_value" =~ $pattern ]]; then
#         print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
#     else
#         print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
#     fi
# }
