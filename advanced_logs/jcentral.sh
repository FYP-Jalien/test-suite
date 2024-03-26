#!/bin/bash

set -e
logs_directory="$SHARED_VOLUME_PATH/logs"
id=$((id + 1))
name="JCentral logs existence check"
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
expected_start_line="alien.config.ConfigUtils init"
name="JCentral logs: Loading alien config check"
level="Critical"
description="$logs_directory jcentral logs should have content starting with $expected_start_line."
mapfile -t jcentral_logs_array < <(find "$logs_directory" -type f -name "jcentral-[0-9]*.log" -print0 | xargs -0 ls -1t)
found=false
for log_file in "${jcentral_logs_array[@]}"; do
    if grep -q "$expected_start_line" "$log_file"; then
        found=true
        start_line_number=$(grep -n "$expected_start_line" "$log_file" | head -n 1 | cut -d':' -f1)
        total_lines=$(wc -l <"$log_file")
        jcentral_log=$log_file
        break
    fi
done
if ! $found; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "JCentral is not started or alien config is not loaded to jcentral"
fi
cur_line_number=$((start_line_number + 1))
expected_content="Own logging configuration: (true|false), ML configuration detected: (true|false)"
description="Jcentral logs should have $expected_content after $expected_start_line."
line_content=$(sed -n "${cur_line_number}p" "$jcentral_log")
if ! echo "$line_content" | grep -qE 'Own logging configuration: (true|false), ML configuration detected: (true|false)'; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "JCentral is started and alien config is loaded to jcentral"
fi

function check_expected_lines() {
    local allFound=true
    for expected_line in "${expected_lines[@]}"; do
        if ! grep -q "$expected_line" "$jcentral_log"; then
            allFound=false
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "Expected line $expected_line not found in $jcentral_log"
        fi
    done
    if $allFound; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "All expected lines found in $jcentral_log"
    fi
}

expected_lines=(
    "Loading trusts from /jalien-dev/trusts"
    "Trusting now: CN=JAliEnCA, O=JAliEn, C=CH"
    "Loaded 1 certificates from /jalien-dev/trusts"
    "Trying to load HOST CERT"
    "Loading trusts from /jalien-dev/trusts"
    "Trusting now: CN=JAliEnCA, O=JAliEn, C=CH"
    "Loaded 1 certificates from /jalien-dev/trusts"
    "Private key loaded from file: /jalien-dev/globus/host/hostkey.pem"
    "Loading public key: /jalien-dev/globus/host/hostcert.pem"
    "Public key loaded from file: /jalien-dev/globus/host/hostcert.pem"
    "Loaded HOST CERT"
    "Local hostname resolved as jcentral-dev"
)
level="Warning"
check_expected_lines

id=$((id + 1))
name="JCentral logs: Starting Tomcat server"
description="$logs_directory jcentral logs should have logs for starting Tomcat server."
level="Warning" # Make Critical
expected_lines=(
    "Tomcat starting ..."
    "Creating the initial Tomcat SSL host configuration"
    "Tomcat listening on \*:8097"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Starting Optimizers"
description="$logs_directory jcentral logs should have logs for starting Optimizers."
level="Critical"
expected_lines=(
    "Starting optimizers: all"
    "New catalogue optimizer: alien.optimizers.catalogue.LTables"
    "New catalogue optimizer: alien.optimizers.catalogue.GuidTable"
    "New catalogue optimizer: alien.optimizers.catalogue.ResyncLDAP"
    "New catalogue optimizer: alien.optimizers.site.SitequeueReconciler"
    "New catalogue optimizer: alien.optimizers.sync.OldJobRemover"
    "New catalogue optimizer: alien.optimizers.catalogue.MemoryRecorder"
    "New catalogue optimizer: alien.optimizers.sync.CheckJobStatus"
    "New catalogue optimizer: alien.optimizers.priority.ActiveUserReconciler"
    "New catalogue optimizer: alien.optimizers.priority.PriorityRapidUpdater"
    "New catalogue optimizer: alien.optimizers.priority.JobAgentUpdater"
    "New catalogue optimizer: alien.optimizers.priority.PriorityReconciliationService"
    "New catalogue optimizer: alien.optimizers.priority.InactiveJobHandler"
    "New catalogue optimizer: alien.optimizers.sync.OverwaitingJobHandler"

)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser LTables"
description="$logs_directory jcentral logs should have logs for running LTables."
level="Warning"
expected_lines=(
    "LTables optimizer starts"
    "LTables wakes up!: going to get L tables counts with max:"
    "LTables sleeps "

)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser GuidTable"
description="$logs_directory jcentral logs should have logs for running GuidTable."
level="Warning"
expected_lines=(
    "GuidTable optimizer starts"
    "GuidTable wakes up!: going to get G tables counts with max:"
    "GuidTable sleeps "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser ResyncLDAP"
description="$logs_directory jcentral logs should have logs for running ResyncLDAP."
level="Critical"
expected_lines=(
    "DB resyncLDAP starts"
    "Checking if an LDAP resynchronisation is needed"
    "alien.optimizers.catalogue.ResyncLDAP updateUsers"
    "alien.optimizers.catalogue.ResyncLDAP updateRoles"
    "alien.optimizers.catalogue.ResyncLDAP updateSEs"
    "alien.optimizers.catalogue.ResyncLDAP updateCEs"
    "Periodic sleeps 60000"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser Resync LDAP: Roles"
description="$logs_directory jcentral logs should have logs for running Resync LDAP: Roles."
level="Warning"
expected_lines=(
    "Synchronising DB roles with LDAP"
    "Inserting 3 roles"
    "Could not get DBs!"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser Resync LDAP: Users"
description="$logs_directory jcentral logs should have logs for running Resync LDAP: Users."
level="Warning"
expected_lines=(
    "Synchronising DB users with LDAP"
    "Query was:
param: (objectClass=AliEnRole)
root extension: ou=Roles,
key: uid
result:
[admin, jalien, vobox]"
    "Inserting 3 users"
    "Could not get DBs!"
    "Query was:
param: subject=/C=CH/O=JAliEn/CN=localhost.localdomain
root extension: ou=People,
key: uid
result:
[jalien]"
    "Query was:
param: users=admin
root extension: ou=Roles,
key: uid
result:
[admin, jalien, vobox]"
    "Query was:
param: users=jalien
root extension: ou=Roles,
key: uid
result:
[vobox]"

)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser Resync LDAP: SEs"
description="$logs_directory jcentral logs should have logs for running Resync LDAP: SEs."
level="Warning"
expected_lines=(
    "Query was:
param: (objectClass=AliEnSE)
root extension: ou=Sites,
key: dn
result:
[name=firstse,ou=SE,ou=Services,ou=JTestSite]"
    "Could not get DBs!"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser Resync LDAP: CEs"
description="$logs_directory jcentral logs should have logs for running Resync LDAP: CEs."
level="Warning"
expected_lines=(
    "Synchronising DB CEs with LDAP"
    "Query was:
    param: (objectClass=AliEnCE)
root extension: ou=Sites,
key: dn
result:
[name=firstce,ou=CE,ou=Services,ou=JTestSite]"
    "Could not get DBs!"

    "Query was:
param: subject=/C=CH/O=JAliEn/CN=localhost.localdomain
root extension: ou=People,
key: uid
result:
[jalien]"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser Resync LDAP: CE max jobs"
description="$logs_directory jcentral logs should have logs for running Resync LDAP: CE max jobs."
level="Warning"
expected_lines=(
    "Query was:
param: name=firstce
root extension: name=firstce,ou=CE,ou=Services,ou=JTestSite,ou=Sites,
key: maxqueuedjobs
result:
[300]"
    "Inserting or updating database entry for CE ALICE::JTestSite::firstce"
    "CEs: 1 synchronized. 1 changes."
    "ALICE::JTestSite::firstce :  
 	 CEs updated 2 parameters [maxjobs (new value = 3000), maxqueued (new value = 300)]"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser SiteQueueReconciler"
description="$logs_directory jcentral logs should have logs for running SiteQueueReconciler."
level="Warning"
expected_lines=(
    "SitequeueReconciler... trying to establish database connections"
    "SitequeueReconciler(processesDev) could not get a DB connection"
    "SitequeueReconciler sleeps "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running OldJobRemover"
description="$logs_directory jcentral logs should have logs for running OldJobRemover."
level="Warning"
expected_lines=(
    "OldJobRemover starting"
    "OldJobRemover(processesDev) could not get a DB connection"
    "OldJobRemover sleeping for "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running OverwaitingJobHandler"
description="$logs_directory jcentral logs should have logs for running OverwaitingJobHandler."
level="Warning"
expected_lines=(
    "OverwaitingJobHandler finished in "
    "OverwaitingJobHandler sleeping for "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running MemoryRecorder"
description="$logs_directory jcentral logs should have logs for running MemoryRecorder."
level="Warning"
expected_lines=(
    "MemoryReporter optimizer starts"
    "MemoryRecorder sleeps "

)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running CheckJobStatus"
description="$logs_directory jcentral logs should have logs for running CheckJobStatus."
level="Warning"
expected_lines=(
    "CheckJobStatus starting"
    "CheckJobStatus(processesDev) could not get a DB connection"
    "CheckJobStatus sleeping for "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running ActiveUserReconciler"
description="$logs_directory jcentral logs should have logs for running ActiveUserReconciler."
level="Warning"
expected_lines=(
    "ActiveUserReconciler starting"
    "ActiveUserReconciler(processesDev) could not get a DB connection"
    "ActiveUserReconciler sleeps "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running PriorityRapidUpdater"
description="$logs_directory jcentral logs should have logs for running PriorityRapidUpdater."
level="Warning"
expected_lines=(
    "PriorityRapidUpdater(processesDev) could not get a DB connection"
    "PriorityRapidUpdater sleeping for "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running JobAgentUpdater"
description="$logs_directory jcentral logs should have logs for running JobAgentUpdater."
level="Warning"
expected_lines=(
    "JobAgentUpdater starting"
    "JobAgentUpdater(processesDev) could not get a DB connection"
    "JobAgentUpdater sleeping for "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running ReconcilePriority"
description="$logs_directory jcentral logs should have logs for running ReconcilePriority."
level="Warning"
expected_lines=(
    "ReconcilePriority(processesDev) could not get a DB connection"
    "ReconcilePriority sleeps "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running InactiveJobHandler"
description="$logs_directory jcentral logs should have logs for running InactiveJobHandler."
level="Warning"
expected_lines=(
    "InactiveJobHandler starting"
    "InactiveJobHandler starting to move inactive jobs to zombie state."
    "InactiveJobHandler starting to move 2h inactive zombie state jobs to expired state. "
    "InactiveJobHandler finished in "
    "InactiveJobHandler sleeping for "

)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Catalogue utils updating index table"
description="$logs_directory jcentral logs should have logs for updating index table."
level="Warning"
expected_lines=(
    "Updating INDEXTABLE cache"
    "INDEXTABLE cache updated successfully"
    "Host is : Host: hostIndex: 2\n
address	: localhost:3307\n
database	: alice_users\n
driver	: mysql\n
organization	:"
    "INDEXTABLE cache updated successfully"
    "Host is : Host: hostIndex: 1
address	: localhost:3307
database	: alice_data
driver	: mysql
organization	: "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: TaskQueue moving state"
description="$logs_directory jcentral logs should have logs for moving state."
level="Warning"
expected_lines=(
    "Successfully moved 0 jobs to ERROR_EW state"
    "Successfully moved 0 jobs to ZOMBIE state"
    "Successfully moved 0 jobs to EXPIRED state"
)
check_expected_lines

# "New catalogue optimizer: utils.lfncrawler.LFNCrawler"
