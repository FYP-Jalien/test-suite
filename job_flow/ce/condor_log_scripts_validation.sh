#!/bin/bash

condor_directory="/home/submituser/htcondor"
pattern="jobagent\_[0-9]+_[0-9]+\.log"
matching_files=()

id=$((id + 1))
name="CE condor log scripts existence check"
level="Critical"
description="condor log scripts will be created when the job agent start up script is submitted to htcondor. "

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
done < <(sudo docker exec "$CONTAINER_NAME_CE" find "$directory" -type f -name "jobagent_[0-9]*_[0-9]*.log" -print0)

if [ ${#matching_files[@]} -eq 0 ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "No condor log scripts found in $directory."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Found ${#matching_files[@]} condor log scripts in $directory."
fi

if ! latest_log_file=$(sudo docker exec "$CONTAINER_NAME_CE" find "$directory" -type f -name "jobagent_[0-9]*_[0-9]*.log" -printf "%T@ %p\n" | sort -n | tail -n 1 | cut -d ' ' -f 2-); then
    id=$((id + 1))
    name="Latest log Script Existence Check"
    level="Critical"
    description="Latest log script must exist."
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Latest log could not be found"
fi

log_script_content=$(sudo docker exec "$CONTAINER_NAME_CE" cat "$latest_log_file")

id=$((id + 1))
name="CE condor log scripts content check"
level="Warning"
description="condor log script has ..Job submitted from host.."

expected_content_array=("Job submitted from host")
if [ "${log_script_content: -3}" != "..." ]; then
    expected_contents+=("Started transferring input files" "Job executing on host" "Finished transferring input files" "Job terminated")
fi

script_not_found=false
for expected_content in "${expected_content_array[@]}"; do
    if ! echo "$log_script_content" | grep -q "$expected_content"; then
        print_full_test "$id" "$name" "FAILED" "condor log script should container $expected_content" "$level" "No ..$expected_content.. found in $latest_log_file."
        script_not_found=true
    fi
done

if [ "$script_not_found" = false ]; then
    print_full_test "$id" "$name" "PASSED" "condor log script should container $expected_content" "$level" "Found all expected contents in $latest_log_file."
fi

pattern="jobagent\_[0-9]+_[0-9]+\.out"
matching_files=()
id=$((id + 1))
name="CE condor out scripts existence check"
level="Minor"
description="condor out scripts will be created after the job agent execution finished. "

while IFS= read -r -d '' file; do
    if [[ "$file" =~ $pattern ]]; then
        matching_files+=("$file")
    fi
done < <(sudo docker exec "$CONTAINER_NAME_CE" find "$directory" -type f -name "jobagent_[0-9]*_[0-9]*.out" -print0)

if [ ${#matching_files[@]} -eq 0 ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "No condor out scripts found in $directory."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Found ${#matching_files[@]} condor out scripts in $directory."
    if ! latest_out_file=$(sudo docker exec "$CONTAINER_NAME_CE" find "$directory" -type f -name "jobagent_[0-9]*_[0-9]*.out" -printf "%T@ %p\n" | sort -n | tail -n 1 | cut -d ' ' -f 2-); then
        id=$((id + 1))
        name="Latest out Script Existence Check"
        level="Warning"
        description="Latest out script must exist."
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "Latest out could not be found"
    fi

    out_script_content=$(sudo docker exec "$CONTAINER_NAME_CE" cat "$latest_log_file")
    id=$((id + 1))
    name="CE condor out scripts content check"
    level="Minor"
    description="condor out scripts may contain \'Connecting to JCentral on JCentral-dev:8098\' "
    if ! echo "$out_script_content" | grep -q "Connecting to JCentral on JCentral-dev:8098"; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "No \'Connecting to JCentral on JCentral-dev:8098\' found in $latest_out_file."
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "Found \'Connecting to JCentral on JCentral-dev:8098\' in $latest_out_file."
    fi

fi

pattern="jobagent\_[0-9]+_[0-9]+\.err"
matching_files=()
id=$((id + 1))
name="CE condor err scripts existence check"
level="Minor"
description="condor err scripts will be created after the job agent execution finished if there were amy errors. "

while IFS= read -r -d '' file; do
    if [[ "$file" =~ $pattern ]]; then
        matching_files+=("$file")
    fi
done < <(sudo docker exec "$CONTAINER_NAME_CE" find "$directory" -type f -name "jobagent_[0-9]*_[0-9]*.err" -print0)

if [ ${#matching_files[@]} -eq 0 ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "No condor err scripts found in $directory."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Found ${#matching_files[@]} condor err scripts in $directory."
fi
