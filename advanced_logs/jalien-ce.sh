#!/bin/bash

set -e
logs_directory="$SHARED_VOLUME_PATH/logs"
id=$((id + 1))
name="Jalien CE logs existence check"
level="Critical"
description="$logs_directory jalien-ce logs should be created when proceeding with the jcentral."
if [ ! -d "$logs_directory" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Directory $logs_directory does not exist."
fi

max_iterations=2
cur_iteration=0

while [ $cur_iteration -lt $max_iterations ]; do
    matching_files=()
    while IFS= read -r -d '' file; do
        matching_files+=("$file")
    done < <(find "$logs_directory" -type f -name "jalien-ce-[0-9]\.log" -print0)
    if [ ${#matching_files[@]} -eq 0 ]; then
        sleep 10
    else
        break
    fi
    cur_iteration=$((cur_iteration + 1))
done

if [ $cur_iteration -eq $max_iterations ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "No jalien-ce log scripts found in $logs_directory."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Found ${#matching_files[@]} jalien-ce log scripts in $logs_directory."
fi

jalien_ce_log="${matching_files[0]}"

expected_lines=()
function check_expected_lines() {
    local allFound=true
    for expected_line in "${expected_lines[@]}"; do
        if ! grep -q "$expected_line" "$jalien_ce_log"; then
            allFound=false
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "Expected line $expected_line not found in $jalien_ce_log"
        fi
    done
    if $allFound; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "All expected lines found in $jalien_ce_log"
    fi
}

id=$((id + 1))
name="JCentral logs: JAliEn Commander strating"
description="$logs_directory jcentral logs should have logs for JAliEn Commander starting."
level="Warning"
expected_lines=(
    "alien.shell.commands.JAliEnCOMMander bootMessage"
    "Starting Commander"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Uploading sample.jdl "
description="$logs_directory jcentral logs should have logs for uploading sample.jdl."
level="Warning"
expected_lines=(
    "Starting Commander"
    "alien.shell.commands.JAliEnCOMMander execute"
    "Received JSh call \[ps\]"
    "alien.shell.commands.JAliEnCOMMander getCommand"
    "Entering command with ps and options \[alien.shell.commands.JAliEnCOMMander"
    "PWD line : /localhost/localdomain/user/j/jalien"
    "Received JSh call \[cp, .*, alien://sample.jdl\]"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Uploading testscript.sh"
description="$logs_directory jcentral logs should have logs for uploading testscript.sh."
level="Warning"
expected_lines=(
    "Received JSh call \[cp, .*, alien://testscript.sh\]"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Submitting sample.jdl"
description="$logs_directory jcentral logs should have logs for submitting sample.jdl."
level="Warning"
expected_lines=(
    "Received JSh call \[submit, \./sample.jdl\]"
    "Entering command with submit and options"
)
check_expected_lines
