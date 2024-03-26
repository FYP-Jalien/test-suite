#!/bin/bash

set -e

ce_log_path="/home/submituser/log/CE.log.0"
id=$((id + 1))
name="CE.log.0 existence check"
level="Critical"
description="Computing Environment log file CE.log.0 should exist."
if sudo docker exec "$CONTAINER_NAME_CE" [ ! -f "$ce_log_path" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$ce_log_path does not exist."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "$ce_log_path exists."
fi

ce_pid_path="/home/submituser/log/CE.pid"
id=$((id + 1))
name="CE.pid existence check"
level="Critical"
description="Computing Environment pid file CE.pid should exist."
if sudo docker exec "$CONTAINER_NAME_CE" [ ! -f "$ce_pid_path" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$ce_pid_path does not exist."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "$ce_pid_path exists."
fi

id=$((id + 1))
name="Computing Element Starting check"
level="Critical"
expected_start_line="Starting ComputingElement in localhost.localdomain"
description="Computing Element should start successfully with '$expected_start_line'."
if ! sudo docker exec "$CONTAINER_NAME_CE" cat "$ce_log_path" | grep -q "$expected_start_line"; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Computing Element did not start successfully."

else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Computing Element started successfully."
fi

function check_expected_lines() {
    local allFound=true
    for expected_line in "${expected_lines[@]}"; do
        if ! sudo docker exec "$CONTAINER_NAME_CE" cat "$ce_log_path" | grep -q "$expected_line"; then
            allFound=false
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "Expected line $expected_line not found CE.log.0"
        fi
    done
    if $allFound; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "All expected lines found in CE.log.0"
    fi
}

id=$((id + 1))
name="Computing Element: LDAP Sync Check"
level="Critical"
expected_lines=(
    "Time to sync with LDAP"
    "Building new SiteMap."
    "New sitemap:"
    "[Site: JTestSite]"
    "[Partition: ,,]"
    "[CE: ALICE::JTestSite::firstce]"
    "[Platform: Linux-x86_64]"
    "[Host: localhost.localdomain]"
    "[TTL: 87000]"
    "[alienCm: localhost.localdomain:10000]"
    "[workdir: /home/submituser]"
    "[Localhost: localhost.localdomain]"
    "[CEhost: localhost.localdomain]"
    "[CPUCores: [0-9]\+]"
    "[CVMFS: [0-9]\+]"
)
description="Computing Element should sync with LDAP successfully."
check_expected_lines

id=$((id + 1))
name="Computing Element: Get number of free slots check"
level="Critical"
expected_lines=(
    "alien.site.ComputingElement getNumberFreeSlots"
    "Failed getting slots in getNumberFreeSlots"
    "alien.site.ComputingElement offerAgent"
    "No slots available in the CE!"
    "Max jobs: [0-9]\+ Max queued: [0-9]\+"
)
description="Computing Element should get number of free slots successfully."
check_expected_lines

id=$((id + 1))
name="Computing Element: Get batch queue status check"
level="Critical"
expected_lines=(
    "alien.site.batchqueue.BatchQueue executeCommand"
    "Executing: condor_q -const 'JobStatus < 3' -af JobStatus -format local_pool GridResource"
    "Process exit status: NORMAL"
    "alien.site.batchqueue.HTCONDOR getJobNumbers"
    "Found [0-9]\+ idle (and [0-9]\+ running) jobs:"
    "[0-9]\+ (    [0-9]\+) for local_pool"
    "Agents queued: [0-9]\+"
    "Agents active: [0-9]\+"
    "CE free slots: [0-9]\+"
)
description="Computing Element should get batch queue status successfully."
check_expected_lines

id=$((id + 1))
name="Computing Element: Get waiting jobs check"
level="Critical"
expected_lines=(
    "Broker returned [0-9]\+ available waiting jobs"
    "Waiting jobs: [0-9]\+"
)
description="Computing Element should get waiting jobs successfully."
check_expected_lines

id=$((id + 1))
name="Computing Element: Submitting jobs check"
level="Critical"
expected_lines=(
    "Going to submit [0-9]\+ agents"
    "Created AgentStartup script: /home/submituser/tmp/agent.startup.[0-9]\+"
    "alien.site.batchqueue.HTCONDOR submit"
    "Submit HTCONDOR"
    "Custom attributes added from file: /home/submituser/custom-classad.jdl"
    "Executing: condor_submit  /home/submituser/htcondor/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/htc-submit\.[0-9]\+\.jdl"
    "Submitting job(s)."
    "1 job(s) submitted to cluster [0-9]\+."
    "Submitted [0-9]\+"
)
description="Computing Element should submit jobs successfully."
check_expected_lines
