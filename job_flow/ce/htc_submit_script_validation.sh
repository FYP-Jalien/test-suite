#!/bin/bash

condor_directory="/home/submituser/htcondor"
pattern="htc-submit\.[0-9]+\.jdl"
matching_files=()

id=$((id + 1))
name="CE condor submit scripts existence check"
level="Critical"
description="condor submit scripts will be created when the job agent start up script is submitted to htcondor. "

if sudo docker exec "$CONTAINER_NAME_CE" [ ! -d "$condor_directory" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Directory $directory does not exist."
fi

today=$(date +"%Y-%m-%d")
directory="$condor_directory/$today"

if sudo docker exec "$CONTAINER_NAME_CE" [ ! -d "$directory" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Directory $directory does not exist."
fi

while IFS= read -r -d '' file; do
    if [[ "$file" =~ $pattern ]]; then
        matching_files+=("$file")
    fi
done < <(sudo docker exec "$CONTAINER_NAME_CE" find "$directory" -type f -name "htc-submit\.[0-9]*\.jdl" -print0)

if [ ${#matching_files[@]} -eq 0 ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "No condor submit scripts found in $directory."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Found ${#matching_files[@]} condor submit scripts in $directory."
fi

if ! latest__htcfile=$(sudo docker exec "$CONTAINER_NAME_CE" find "$directory" -type f -name "htc-submit\.[0-9]*\.jdl" -printf "%T@ %p\n" | sort -n | tail -n 1 | cut -d ' ' -f 2-); then
    id=$((id + 1))
    name="Latest htc submit Script Existence Check"
    level="Critical"
    description="Latest htc submit script must exist."
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Latest htc submit could not be found"
fi

submit_script_content=$(sudo docker exec "$CONTAINER_NAME_CE" cat "$latest__htcfile")

function validate_cmd() {
    local variable="cmd"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*/home/submituser/tmp/agent\.startup\.[0-9]+$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have cmd = /home/submituser/tmp/agent.startup.dd line"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_output() {
    local variable="output"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*$directory/jobagent_[0-9]+_[0-9]+\.out$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have $variable = $directory/jobagent_dd_dd.out"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_error() {
    local variable="error"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*$directory/jobagent_[0-9]+_[0-9]+\.err$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have $variable = $directory/jobagent_dd_dd.err"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_log() {
    local variable="log"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*$directory/jobagent_[0-9]+_[0-9]+\.log$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have $variable = $directory/jobagent_dd_dd.log"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_transfer_output() {
    local variable="+TransferOutput"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^\+TransferOutput\s*=\s*\"\"$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Warning"
    description="htc-submit script should have $variable = \"\""
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_periodic_hold() {
    local variable="periodic_hold"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*(.+)$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have $pattern"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_periodic_remove() {
    local variable="periodic_remove"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*.+$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have $pattern"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_universe() {
    local variable="universe"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*vanilla$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have $pattern"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_job_lease_duration() {
    local variable="job_lease_duration"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*[0-9]+$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have $pattern"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_should_transfer_files() {
    local variable="ShouldTransferFiles"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*YES$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have $pattern"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_want_job_router() {
    local variable="\+WantJobRouter"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*True$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have $pattern"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_use_proxy() {
    local variable="use_x509userproxy"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*.+$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have $pattern"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_environment() {
    local variable="environment"
    local variable_value
    variable_value=$(echo "$submit_script_content" | grep "^$variable = " | sed "s/^$variable=\"\(.*\)\";/\1/")
    local pattern="^$variable\s*=\s*\".+\"$"
    id=$((id + 1))
    name="htc_submit Script $variable Check"
    level="Critical"
    description="htc-submit script should have $pattern"
    if [ -z "$variable_value" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit scripts do not contain '$variable = ' line."
    elif [[ "$variable_value" =~ $pattern ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script $variable is valid."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable is invalid or in invalid format."
    fi
}

function validate_queue() {
    id=$((id + 1))
    name="htc_submit Script queue command Check"
    level="Critical"
    description="htc-submit script should have queue [0-9]+"
    local variable="queue\s*"
    if echo "$submit_script_content" | grep -q -E  "$variable"; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "htc-submit Script has $variable"
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "htc-submit Script $variable was not found."
    fi
}

validate_cmd
validate_output
validate_error
validate_log
validate_transfer_output
validate_periodic_hold
validate_periodic_remove
validate_universe
validate_job_lease_duration
validate_should_transfer_files
validate_want_job_router
validate_use_proxy
validate_environment
validate_queue
