#!/bin/bash

id=$((id + 1))
name="Worker condor copy log dir logs existence check"
level="Warning"
description="Worker condor copy log dir logs should exist. If not, the job_flow_logs worker tests was not run."
test_dir="/host_files/condor_dir"
if ! docker exec "$CONTAINER_NAME_WORKER" test -d "$test_dir" ; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Directory $test_dir does not exist in $CONTAINER_NAME_WORKER."
fi

pattern="dir_[0-9]+"
matching_files=()
while IFS= read -r -d '' dir; do
    if [[ "$dir" =~ $pattern ]]; then
        matching_files+=("$dir")
    fi
done < <(docker exec "$CONTAINER_NAME_WORKER" find   "$test_dir" -type d -name "dir_[0-9]*" -print0)

if [ ${#matching_files[@]} -eq 0 ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "No dir log scripts found in $test_dir."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Found ${#matching_files[@]} dir log scripts in $test_dir."
fi

agent_log_path=${matching_files[0]}"/job-agent-1.log"
id=$((id + 1))
name="job-agent-1.log existence check"
level="Warning"
description="Worker host copy log files job-agent-1.log should exist."
if docker exec "$CONTAINER_NAME_WORKER" [ ! -f "$agent_log_path" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$agent_log_path does not exist."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "$agent_log_path exists."
fi

id=$((id + 1))
name="Worker Starting check"
level="Warning"
expected_start_line="alien.site.JobAgent <init> JobNumber: [0-9]\+"
description="Worker should start successfully with '$expected_start_line'."
if ! docker exec "$CONTAINER_NAME_WORKER" cat "$agent_log_path" | grep -q "$expected_start_line"; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Worker did not start successfully."
else
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Worker started successfully."
fi

agent_file_name="job-agent-1.log"
agent_log_path=${matching_files[0]}"/$agent_file_name"
expected_lines=()
function check_expected_lines() {
    local allFound=true
    for expected_line in "${expected_lines[@]}"; do
        if ! docker exec "$CONTAINER_NAME_WORKER" cat "$agent_log_path" | grep -q "$expected_line"; then
            allFound=false
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "Expected line $expected_line not found in $agent_file_name"
        fi
    done
    if $allFound; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "All expected lines found in $agent_file_name"
    fi
}

id=$((id + 1))
name="Worker idle running check"
level="Warning"
expected_lines=(
    "We have the following DN :C=ch,O=AliEn2,CN=JobAgent"
    "Getting probe list from Site Sonar for : worker1"
    "No probes returned from Site Sonar. Skipping ..."
    "cpuIsolation = false"
    "CPUFAMILY: [0-9a-fA-F]\+"
    "CPUMHZ: [0-9]\+"
     "NOCPUS: [0-9]\+"
     "Going to register memory limits ..."
)
description="Worker should run idly with the following lines: ${expected_lines[*]}."
check_expected_lines

# TODO - Find this accordngly
agent_file_name="job-agent-2.log"
agent_log_path=${matching_files[0]}"/$agent_file_name"
id=$((id + 1))
name="Worker running job agent check"
level="Warning"
expected_lines=(
    "Starting JobAgent 2 in worker1"
    "{Site=JTestSite, Partition=,,, CE=ALICE::JTestSite::firstce, Platform=Linux-x86_64, Host=localhost.localdomain, TTL=87000, alienCm=localhost.localdomain:10000, workdir=/var/lib/condor/execute/dir_[0-9]\+, Localhost=worker1, CEhost=localhost.localdomain, Disk=[0-9]\+, CPUCores=1, CVMFS=1"
    "Resources available: 1 CPU cores and [0-9]\+ MB of disk space"
    "Updating dynamic parameters of jobAgent map"
    "LegacyToken"
    "queueId 1888757065"
    "JDL"
     "User = \"jalien\";"
 "Executable = \"/localhost/localdomain/user/j/jalien/testscript.sh\";"
 "JDLPath = \"/localhost/localdomain/user/j/jalien/sample.jdl\";"
 "OutputDir = \"/localhost/localdomain/user/j/jalien/output_dir_new/\";"
 "Output = {
  \"stdout@disk=1\"
 };"
 "Requirements = ( other.TTL > 21600 ) && ( other.Price <= 1 );"
 "TTL = 21600;"
 "Price = 1.0;"
 "MemorySize = \"8GB\";"
 "JDLVariables = {
  \"CPUCores\"
 };"
 "CPUCores = \"1\";"
 "Type = \"Job\";"
     "TokenKey -----BEGIN RSA PRIVATE KEY-----"
    "TokenCertificate -----BEGIN CERTIFICATE-----"
    "Code 1"
    "/localhost/localdomain/user/j/jalien/testscript.sh"
    "jalien"
    "The recomputed disk space is [0-9]\+ MB"
    "Currently available CPUCores: 0"
    "Task isolation is set to false"
    "Job Price is set to 1.0"
    "Creating sandbox directory"
    "Started JA with:  User = \"jalien\";"

)
description="Worker should run job agent with the expected lines."
check_expected_lines

id=$((id + 1))
name="Worker job wrapper lanuch check"
level="Warning"
expected_lines=(
    "alien.site.JobRunner"
    "Launching jobwrapper using the command: \[java, -client, -Xms60M, -Xmx60M, -Djdk.lang.Process.launchMechanism=vfork, -XX:+UseSerialGC, 
    -XX:OnOutOfMemoryError=\"echo 'Process %p has run out of memory' \> ./[0-9]\+.oom\", -Djobagent.vmid=[0-9]\+, -DAliEnConfig=., -cp, /jalien-dev/alien-cs.jar, alien.site.JobWrapper\]"
    "JDL info sent to JobWrapper"
    "FRUNTIME | RUNTIME | CPUUSAGE | MEMUSAGE | CPUTIME | RMEM | VMEM | NOCPUS | CPUFAMILY | CPUMHZ | RESOURCEUSAGE | RMEMMAX | VMEMMAX"
    "+++++ Sending resources info +++++"
    "JobWrapper has finished execution. Exit code: 0"
    "Sending monitoring values..."
    "All done for job [0-9]\+. Final status: DONE"
    "Cleaning up after execution..."
    "Done!"
    "Removing job from Memory Controller Registries"
    "JobAgent finished, id:[[:alnum:]@#$ ]*"  
    "totalJobs: [0-9]\+"
    )
description="Worker should run job wrapper with the expected lines."
check_expected_lines