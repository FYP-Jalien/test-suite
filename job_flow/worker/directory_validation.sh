#!/bin/bash

set -e

condor_execute_directory="/var/lib/condor/execute"
id=$((id + 1))
name="Worker $condor_execute_directory existence check"
level="Critical"
description="$condor_execute_directory should be created when condor started and procedding."
if sudo docker exec "$CONTAINER_NAME_CE" [ ! -d "$condor_execute_directory" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Directory $condor_execute_directory does not exist."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Directory $condor_execute_directory exists."
fi

id=$((id + 1))
name="Worker condor log dir existence check"
level="Critical"
description="Worker condor log should be created when jobagnet script is started in the worker"
max_iterations=5
cur_iteration=0
test_dir="/host_files/condor_dir"
sudo docker exec "$CONTAINER_NAME_WORKER" mkdir -p "$test_dir"
pattern="dir_[0-9]+"
while [ $cur_iteration -lt $max_iterations ]; do
    matching_files=()
    while IFS= read -r -d '' dir; do
        if [[ "$dir" =~ $pattern ]]; then
            matching_files+=("$dir")
        fi
    done < <(sudo docker exec "$CONTAINER_NAME_WORKER" find "$condor_execute_directory" -type d -name "dir_[0-9]*" -print0)
    if [ ${#matching_files[@]} -eq 0 ]; then
        sleep 10
    else
        dir="${matching_files[0]}"
        if sudo docker exec "$CONTAINER_NAME_WORKER" cp -r "$dir" "$test_dir"; then
            break
        fi
    fi
    cur_iteration=$((cur_iteration + 1))
done

if [ $cur_iteration -eq $max_iterations ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "No condor log scripts found in $condor_execute_directory after $max_iterations iterations."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Found ${#matching_files[@]} condor log scripts in $condor_execute_directory."
fi

directories=$(sudo docker exec "$CONTAINER_NAME_WORKER" ls -t $test_dir)
log_dir="$test_dir/$(echo "$directories" | head -n 1)"

# expected_content_array=("access_log" "_condor_stderr" "_condor_stdout" "condor_exec.exe")

# id=$((id + 1))
# name="Worker condor log dir files existence check"
# level="Critical"
# description="Worker condor log dir should contain $(convert_array_to_string "${expected_content_array[@]}")"

# fail=false
# for file in "${expected_content_array[@]}"; do
#     if ! sudo docker exec "$CONTAINER_NAME_WORKER" [ ! -d "$log_dir/$file" ]; then
#         print_full_test "$id" "$name" "FAILED" "$description" "$level" "File '$file' does not exist in '$log_dir'"
#         fail=true
#     fi
# done
# if ! $fail; then
#     print_full_test "$id" "$name" "PASSED" "$description" "$level" "All expected files exist in '$log_dir'"
# fi

function validate_access_log() {
    local log_file="access_log"
    id=$((id + 1))
    name="Worker condor logs access_log content check"
    level="Warning"
    if ! sudo docker exec "$CONTAINER_NAME_WORKER" [ ! -d "$log_dir/$log_file" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "Critical" "File '$log_file' does not exist in '$log_dir'"
    fi
    local expected_content=("\"user\":\"jobagent\"" "\"role\":\"jobagent\"" "\"command\":\"boot\"")
    description="access_log should contain $(convert_array_to_string "${expected_content[@]}")"
    local fail=false
    for content in "${expected_content[@]}"; do
        if ! sudo docker exec "$CONTAINER_NAME_WORKER" grep -q "$content" "$log_dir/access_log"; then
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "No '$content' found in access_log"
            false=true
        fi
    done
    if ! $fail; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "All required expected content in access_log"
    fi
}

function validate_condor_stdout() {
    local log_file="_condor_stdout"
    id=$((id + 1))
    name="Worker condor logs $log_file content check"
    level="Warning"
    if ! sudo docker exec "$CONTAINER_NAME_WORKER" [ ! -d "$log_dir/$log_file" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "Critical" "File '$log_file' does not exist in '$log_dir'"
    fi
    local expected_content=("Connecting to JCentral on JCentral-dev:8098")
    description="$log_file should contain $(convert_array_to_string "${expected_content[@]}")"
    local fail=false
    for content in "${expected_content[@]}"; do
        if ! sudo docker exec "$CONTAINER_NAME_WORKER" grep -q "$content" "$log_dir/$log_file"; then
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "No '$content' found in $log_file"
            false=true
        fi
    done
    if ! $fail; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "All required expected content in $log_file"
    fi
}

function validate_condor_stderr() {
    local log_file="_condor_stderr"
    id=$((id + 1))
    name="Worker condor logs $log_file content check"
    level="Warning"
    if ! sudo docker exec "$CONTAINER_NAME_WORKER" [ ! -d "$log_dir/$log_file" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "Critical" "File '$log_file' does not exist in '$log_dir'"
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "$log_file exists in $log_dir"
    fi
}

function validate_condor_exec() {
    local log_file="condor_exec.exe"
    id=$((id + 1))
    name="Worker condor logs $log_file content check"
    level="Warning"
    if ! sudo docker exec "$CONTAINER_NAME_WORKER" [ ! -d "$log_dir/$log_file" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "Critical" "File '$log_file' does not exist in '$log_dir'"
    fi
    local expected_content=("JALIEN_TOKEN_CERT" "JALIEN_TOKEN_KEY" "HOME" "PATH" "LD_LIBRARY_PATH" "TMP" "TMPDIR" "LOGDIR" "CACHEDIR" "ALIEN_CM_AS_LDAP_PROXY" "site" "ALIEN_SITE" "CE" "CEhost" "TTL" "APMON_CONFIG" "partition" "JALIEN_JOBAGENT_CMD")
    description="$log_file should contain $(convert_array_to_string "${expected_content[@]}")"
    local fail=false
    for content in "${expected_content[@]}"; do
        if ! sudo docker exec "$CONTAINER_NAME_WORKER" grep -q "export $content=" "$log_dir/$log_file"; then
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "No '$content' found in $log_file"
            false=true
        fi
    done
    if ! $fail; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "All required expected content in $log_file"
    fi
}

function validate_job_agent() {
    local log_file="job-agent-1.log"
    id=$((id + 1))
    name="Worker condor logs $log_file content check"
    level="Warning"
    if ! sudo docker exec "$CONTAINER_NAME_WORKER" [ ! -d "$log_dir/$log_file" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "File '$log_file' does not exist in '$log_dir'"
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "$log_file exists in $log_dir"
    fi
}

function validate_job_agent_lck() {
    local log_file="job-agent-1.log.lck"
    id=$((id + 1))
    name="Worker condor logs $log_file content check"
    level="Warning"
    if ! sudo docker exec "$CONTAINER_NAME_WORKER" [ ! -d "$log_dir/$log_file" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "File '$log_file' does not exist in '$log_dir'"
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "$log_file exists in $log_dir"
    fi
}

validate_access_log
validate_condor_stdout
validate_condor_stderr
validate_condor_exec
validate_job_agent_lck
