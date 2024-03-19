#!/bin/bash

set -e
logs_directory="$SHARED_VOLUME_PATH/logs"
id=$((id + 1))
name="$logs_directory jcentral logs existence check"
level="Critical"
description="$logs_directory jcentral logs should be created when proceeding with the jcentral."
if [ ! -d "$logs_directory" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Directory $logs_directory does not exist."
fi

max_iterations=2
cur_iteration=0

while [ $cur_iteration -lt $max_iterations ]; do
    matching_files=()
    while IFS= read -r -d '' file; do
        matching_files+=("$file")
    done < <(find "$logs_directory" -type f -name "jcentral-[0-9]\.log" -print0)
    if [ ${#matching_files[@]} -eq 0 ]; then
        sleep 10
    else
        break
    fi
    cur_iteration=$((cur_iteration + 1))
done

if [ $cur_iteration -eq $max_iterations ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "No jcentral log scripts found in $logs_directory."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Found ${#matching_files[@]} jcentral log scripts in $logs_directory."
fi

id=$((id + 1))
name="$logs_directory jcentral logs content check"
level="Critical"
description="$logs_directory jcentral logs should have the expected content."

mapfile -t jcentral_logs_array < <(find "$logs_directory" -type f -name "jcentral-[0-9]*.log" -print0 | xargs -0 ls -1t)
found=false
expected_start_line="alien.config.ConfigUtils init"
for log_file in "${jcentral_logs_array[@]}"; do
    if grep -q "$expected_start_line" "$log_file"; then
        found=true
        start_line=$(tac "$log_file" | grep -m 1 "$expected_start_line")  # $(grep -n "sentence" "$log_file" | head -n 1 | cut -d':' -f1)
        total_lines=$(wc -l <"$log_file")
        echo "$total_lines"
        echo "$start_line"
        start_line_number=$((total_lines - start_line + 1))
        echo "$start_line_number"
        jcentral_log=$log_file
        break
    fi
done
if [ "$found" = false ]; then
    description="JCentral should start wotj loading alien config"
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "JCentral is not started or alien config is not loaded to jcentral"
fi

echo "$start_line"
echo "$start_line_number"
# cur_iteration=0
# max_iterations=2
# first_expected_line="alien.api.Request authorizeUserAndRole"
# while [ $cur_iteration -lt $max_iterations ]; do
#     line_numbers=$(grep -n "$first_expected_line"  "$jcentral_log" | cut -d ':' -f 1 | tail -n 2)
#     num_lines=$(echo "$line_numbers" | wc -l)
#     if [ "$num_lines" -eq 2 ]; then
#         break
#     elif [ "$num_lines" -eq 1 ]; then
#         sleep 60
#         cur_iteration=$((cur_iteration + 1))
#     else
#         sleep 60
#         cur_iteration=$((cur_iteration + 1))
#     fi
# done

# if [ $cur_iteration -eq $max_iterations ]; then
#     print_full_test "$id" "$name" "FAILED" "$description" "$level" "jcentral log has no lines for $first_expected_line "
# fi
