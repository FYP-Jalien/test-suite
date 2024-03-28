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
start_jcentral_log_found=false
for log_file in "${jcentral_logs_array[@]}"; do
    if grep -q "$expected_start_line" "$log_file"; then
        found=true
        start_line_number=$(grep -a -n "$expected_start_line" "$log_file" | head -n 1 | cut -d':' -f1)
        if [[ "$start_line_number" -eq 1 ]]; then
            jcentral_log=$log_file
            start_jcentral_log_found=true
            break
        fi
    fi
done
if ! $found; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "JCentral is not started or alien config is not loaded to jcentral"
fi
if ! $start_jcentral_log_found; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "JCentral log file does not have $expected_start_line at the start."
fi
cur_line_number=$((start_line_number + 1))
expected_content="Own logging configuration: (true|false), ML configuration detected: (true|false)"
description="Jcentral logs should have $expected_content after $expected_start_line."
line_content=$(sed -n "${cur_line_number}p" "$jcentral_log")
if ! echo "$line_content" | grep -qE 'Own logging configuration: (true|false), ML configuration detected: (true|false)'; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "JCentral is started and alien config is loaded to jcentral"
fi

expected_lines=()
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
name="JCentral logs: Running DispatchSSLServer"
description="$logs_directory jcentral logs should have logs for running DispatchSSLServer."
level="Critical"
expected_lines=(
    "alien.api.DispatchSSLServer runService"
    "Running JCentral with host cert: C=CH,O=JAliEn,CN=localhost.localdomain"
    "JCentral listening on  /0.0.0.0:8098"
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
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser Resync LDAP: SEs"
description="$logs_directory jcentral logs should have logs for running Resync LDAP: SEs."
level="Warning"
expected_lines=(
    "Synchronising DB SEs and volumes with LDAP"
    "param: (objectClass=AliEnSE)"
    "root extension: ou=Sites,"
    "key: dn"
    "result:"
    "\[name=firstse,ou=SE,ou=Services,ou=JTestSite\]"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser Resync LDAP: CEs"
description="$logs_directory jcentral logs should have logs for running Resync LDAP: CEs."
level="Warning"
expected_lines=(
    "Synchronising DB CEs with LDAP"
    "param: (objectClass=AliEnCE)"
    "root extension: ou=Sites,"
    "key: dn"
    "result:"
    "\[name=firstce,ou=CE,ou=Services,ou=JTestSite\]"
    "param: name=firstce"
    "root extension: name=firstce,ou=CE,ou=Services,ou=JTestSite,ou=Sites,"
    "key: maxjobs"
    "\[3000\]"
    "Inserting or updating database entry for CE ALICE::JTestSite::firstce"
    "CEs: 1 synchronized. 1 changes. "
    "CEs updated 2 parameters \[maxjobs (new value = 3000), maxqueued (new value = 300)\]"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser Resync LDAP: CE max jobs"
description="$logs_directory jcentral logs should have logs for running Resync LDAP: CE max jobs."
level="Warning"
expected_lines=(
    "param: name=firstce"
    "root extension: name=firstce,ou=CE,ou=Services,ou=JTestSite,ou=Sites,"
    "key: maxqueuedjobs"
    "result:"
    "\[300\]"
    "Inserting or updating database entry for CE ALICE::JTestSite::firstce"
    "CEs: 1 synchronized. 1 changes."
    "ALICE::JTestSite::firstce :
 	 CEs updated 2 parameters \[maxjobs (new value = 3000), maxqueued (new value = 300)]"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running Optimiser SiteQueueReconciler"
description="$logs_directory jcentral logs should have logs for running SiteQueueReconciler."
level="Warning"
expected_lines=(
    "SitequeueReconciler... trying to establish database connections"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running OldJobRemover"
description="$logs_directory jcentral logs should have logs for running OldJobRemover."
level="Warning"
expected_lines=(
    "OldJobRemover starting"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running OverwaitingJobHandler"
description="$logs_directory jcentral logs should have logs for running OverwaitingJobHandler."
level="Warning"
expected_lines=(
    "OverwaitingJobHandler finished in "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running MemoryRecorder"
description="$logs_directory jcentral logs should have logs for running MemoryRecorder."
level="Warning"
expected_lines=(
    "MemoryReporter optimizer starts"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running CheckJobStatus"
description="$logs_directory jcentral logs should have logs for running CheckJobStatus."
level="Warning"
expected_lines=(
    "CheckJobStatus starting"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running ActiveUserReconciler"
description="$logs_directory jcentral logs should have logs for running ActiveUserReconciler."
level="Warning"
expected_lines=(
    "ActiveUserReconciler starting"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running PriorityRapidUpdater"
description="$logs_directory jcentral logs should have logs for running PriorityRapidUpdater."
level="Warning"
expected_lines=(
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Running JobAgentUpdater"
description="$logs_directory jcentral logs should have logs for running JobAgentUpdater."
level="Warning"
expected_lines=(
    "JobAgentUpdater starting"
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
    "Host is : Host: hostIndex: [0-9]\+"
    "address	: localhost:3307"
    "database	: alice_users"
    "driver	: mysql"
    "organization	:"
    "INDEXTABLE cache updated successfully"
    "Host is : Host: hostIndex: [0-9]\+"
    "address	: localhost:3307"
    "database	: alice_data"
    "driver	: mysql"
    "organization	: "
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: TaskQueue moving state"
description="$logs_directory jcentral logs should have logs for moving state."
level="Warning"
expected_lines=(
    "alien.taskQueue.TaskQueueUtils moveState"
    "Successfully moved 0 jobs to ERROR_EW state"
    "Successfully moved 0 jobs to ZOMBIE state"
    "Successfully moved 0 jobs to EXPIRED state"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Handling one SSL Socket"
description="$logs_directory jcentral logs should have logs for handling one SSL Socket."
level="Warning"
expected_lines=(
    "alien.api.DispatchSSLServer handleOneSSLSocket"
    "Printing client information:"
    "alien.api.DispatchSSLServer handleOneSSLSocket"
    "Peer Certificate Information:"
    "Subject: CN=localhost.localdomain, O=JAliEn, C=CH- Issuer:
CN=JAliEnCA, O=JAliEn, C=CH- Version:"
    "alien.user.UserFactory getByCertificate"
    "Checking for chain 0: /C=CH/O=JAliEn/CN=localhost.localdomain"
    "alien.user.UserFactory getAllByDN"
    "Checking for chain: /C=CH/O=JAliEn/CN=localhost.localdomain"
    "Account for 0 (/C=CH/O=JAliEn/CN=localhost.localdomain) is: \[jalien\]"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Insert into sites"
description="$logs_directory jcentral logs should have logs for inserting into sites."
level="Warning"
expected_lines=(
    "alien.taskQueue.TaskQueueUtils insertIntoSites"
    "insertIntoSites: insert into SITES (siteName,siteId,masterHostId,adminName,location,domain, longitude, latitude,record,url) values (?,?,?,?,?,?,?,?,?,?); with domain: localdomain"
    "Returning SITES siteId: 933"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Insert Host"
description="$logs_directory jcentral logs should have logs for inserting host."
level="Warning"
expected_lines=(
    "alien.taskQueue.TaskQueueUtils insertHost"
    "insertHost with query : insert into HOSTS (hostId, hostName, siteId, hostPort, Version) values (?,?,?,?,?); with ?=localhost.localdomain and siteId: 933"
    "Returning HOST hostId: [0-9]\+"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Update Host"
description="$logs_directory jcentral logs should have logs for updating host."
level="Warning"
expected_lines=(
    "alien.taskQueue.TaskQueueUtils updateHost"
    "Going to updateHost for: localhost.localdomain status: ACTIVE"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Select site queue blocked"
description="$logs_directory jcentral logs should have logs for selecting site queue blocked."
level="Warning"
expected_lines=(
    "alien.taskQueue.TaskQueueUtils getSiteQueueBlocked"
    "Going to select SITEQUEUES.blocked for: ALICE::JTestSite::firstce"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Select number of queued ces"
description="$logs_directory jcentral logs should have logs for selecting number of queued ces."
level="Warning"
expected_lines=(
    "alien.taskQueue.TaskQueueUtils getNumberMaxAndQueuedCE"
    "Going to select HOSTS.maxQueued,maxJobs for: localhost.localdomain - ALICE::JTestSite::firstce"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Select number of free slots"
description="$logs_directory jcentral logs should have logs for selecting number of free slots."
level="Warning"
expected_lines=(
    "Got request from \[jalien\] : alien.api.taskQueue.GetNumberFreeSlots"
    "alien.taskQueue.JobBroker getNumberFreeSlots"
    "Error: getNumberFreeSlots, failed to get slots: localhost.localdomain - ALICE::JTestSite::firstce"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Get constraint cache"
description="$logs_directory jcentral logs should have logs for getting constraint cache."
level="Warning"
expected_lines=(
    "alien.taskQueue.TaskQueueUtils getConstraintCache"
    "Updating constraint cache at [0-9]\+"
    "Added the constraint name: CGROUPSv2_AVAILABLE, type: equality to the constraint cache"
    "Added the constraint name: CPU_flags, type: regex to the constraint cache"
    "Added the constraint name: OS_NAME, type: equality to the constraint cache"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Get number of waitings for site"
description="$logs_directory jcentral logs should have logs for getting number of waitings for site."
level="Warning"
expected_lines=(
    "Got request from \[jalien\] : alien.api.taskQueue.GetNumberWaitingJobs"
    "alien.taskQueue.JobBroker getNumberWaitingForSite"
    "Enforcing additional constraints for localhost.localdomain"
    "Constraint name : CPU_flags"
    "Constraint expression : regex"
    "Site map does not contain a value for : CPU_flags. Setting the constraint value to null"
    "Going to select agents (select sum(counter) as counter from JOBAGENT where priority>0 AND counter>0 and ttl < ? and cpucores <= ? and (site='' or site like concat('%,',?,',%'))  and (ce like '' or ce like concat('%,',?,',%')) and noce not like concat('%,',?,',%') and \`partition\`='%'  and (CPU_flags is null) and (CGROUPSv2_AVAILABLE is null) and (OS_NAME is null) order by priority desc, price desc, oldestQueueId asc limit 1)"
    "Bind values: \[[0-9]\+, [0-9]\+, JTestSite, ALICE::JTestSite::firstce, ALICE::JTestSite::firstce\]"
    "Putting counter-"
)
check_expected_lines

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
    "alien.shell.commands.JAliEnCOMMander bootMessage"
    "Starting Commander"
    "alien.shell.commands.JAliEnCOMMander execute"
    "Received JSh call \[commandlist\]"
    "alien.shell.commands.JAliEnCOMMander getCommand"
    "Entering command with commandlist and options \[alien.shell.commands.JAliEnCOMMander"
    "Received JSh call \[ls, -nokeys, -F\]"
    "Entering command with ls and options \[alien.shell.commands.JAliEnCOMMander"
    "alien.shell.commands.JAliEnCommandls run"
    "listing for directory = \"/localhost/localdomain/user/j/jalien"
    "alien.api.Request authorizeUserAndRole"
    "Successfully switched user from '\[admin\]' to '\[jalien\]'."
    "alien.catalogue.LFNUtils getLFN"
    "Using IndexTableEntry indexId: [0-9]\+"
    "hostIndex		: [0-9]\+"
    "tableName		: [0-9]\+"
    "lfn			: /localhost/localdomain/user/"
    "for: /localhost/localdomain/user/j/jalien"
    "alien.catalogue.IndexTableEntry getDB"
    "Host is : Host: hostIndex: [0-9]\+"
    "address	: localhost:3307"
    "database	: alice_users"
    "driver	: mysql"
    "organization	: "
    "alien.catalogue.IndexTableEntry getLFN"
    "Empty result set for SELECT \* FROM L0L WHERE lfn=? OR lfn=? and j/jalien/sample.jdl"
    "Received JSh call \[mkdir, -nomsg, -p, /localhost/localdomain/user/j/jalien\]"
    "Entering command with mkdir and options \[alien.shell.commands.JAliEnCOMMander"
    "alien.catalogue.CatalogueUtils updateGuidIndexCache"
    "Updating GUIDINDEX cache"
    "Finished updating GUIDINDEX cache"
    "alien.api.catalogue.PFNforWrite <init>"
    "got qos: {disk=[0-9]\+}"
    "Successfully switched user from '\[jalien\]' to '\[jalien\]'."
    "alien.api.catalogue.PFNforWrite run"
    "alien.user.AuthorizationChecker canWrite"
    "The user \"jalien\" has the right to write \"/localhost/localdomain/user/j/jalien/\""
    "alien.quotas.QuotaUtilities updateFileQuotasCache"
    "Updating File Quota cache"
    "alien.catalogue.access.AuthorizationFactory fillAccess"
    "PFN: guidId	: 0"
    "pfn		: root://JCentral-dev-SE:1094//tmp/"
    "seNumber	: [0-9]\+"
    "GUID cache value: guidID		: 0 (exists: false)"
    "ctime		: null"
    "owner		: jalien:jalien"
    "SE lists	: \[\] , \[]"
    "aclId		: -[0-9]\+"
    "expireTime	: null"
    "size		: [0-9]\+"
    "guid		: "
    "type		: 0 (0)"
    "md5		: "
    "permissions	: [0-9]\+"
    "job ID	: unknown, user: \[jalien\], access: write"
    "alien.io.protocols.Xrootd <clinit>"
    "Local Xrootd version is v[0-9]\+.[0-9]\+.[0-9]\+, newer than 4: true"
    "alien.user.JAKeyStore loadPrivX509"
    "Private key loaded from file: /jalien-dev/globus/authz/AuthZ_priv.pem"
    "alien.user.JAKeyStore loadPubX509"
    "Loading public key: /jalien-dev/globus/authz/AuthZ_pub.pem"
    "Public key loaded from file: /jalien-dev/globus/authz/AuthZ_pub.pem"
    "Private key loaded from file: /jalien-dev/globus/SE/SE_priv.pem"
    " Loading public key: /jalien-dev/globus/SE/SE_pub.pem"
    "Public key loaded from file: /jalien-dev/globus/SE/SE_pub.pem"
    "alien.io.xrootd.envelopes.XrootDEnvelopeSigner encryptEnvelope"
    "Encrypting this envelope:"
    "alien.api.catalogue.PFNforWrite run"
    "Returning: Asked for write: LFN entryId	: 0"
    "owner		: jalien:admin"
    "ctime		: null (expires null)"
    "replicated	: false"
    "aclId		: 0"
    "lfn		: j/jalien/sample.jdl"
    "dir		: [0-9]\+"
    "Received JSh call \[commit, \-nokeys, \-\-\-\-\-BEGIN SEALED CIPHER-----"
    "END SEALED CIPHER"
    "BEGIN SEALED ENVELOPE"
    "END SEALED ENVELOPE"
    "alien.api.catalogue.RegisterEnvelopes run"
    "Commit line : /localhost/localdomain/user/j/jalien/sample.jdl 1"
    "alien.user.UserFactory getByCertificate"
    "Checking for chain 0: /C=CH/O=JAliEn/CN=jalien"
    "alien.user.UserFactory getAllByDN"
    "alien.user.UserFactory getByCertificate"
    "Account for 0 (/C=CH/O=JAliEn/CN=jalien) is: \[jalien\]"
    "alien.user.LdapCertificateRealm hasRole"
    "hasRole('\[jalien\]', 'users')"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Uploading testscript.sh"
description="$logs_directory jcentral logs should have logs for uploading testscript.sh."
level="Warning"
expected_lines=(
    "alien.shell.commands.JAliEnCOMMander bootMessage"
    "Starting Commander"
    "alien.shell.commands.JAliEnCOMMander execute"
    "Received JSh call \[commandlist\]"
    "alien.shell.commands.JAliEnCOMMander getCommand"
    "Entering command with commandlist and options \[alien.shell.commands.JAliEnCOMMander"
    "Received JSh call \[stat, -nomsg, /localhost/localdomain/user/j/jalien/testscript.sh\]"
    "Entering command with stat and options \[alien.shell.commands.JAliEnCOMMander"
    "alien.api.Request authorizeUserAndRole"
    "Successfully switched user from '\[admin\]' to '\[jalien\]'."
    "alien.catalogue.LFNUtils getLFN"
    "Using IndexTableEntry indexId: [0-9]\+"
    "hostIndex		: [0-9]\+"
    "tableName		: [0-9]\+"
    "lfn			: /localhost/localdomain/user/"
    "for: /localhost/localdomain/user/j/jalien/testscript.sh"
    "alien.catalogue.IndexTableEntry getDB"
    "Host is : Host: hostIndex: [0-9]\+"
    "address	: localhost:3307"
    "database	: alice_users"
    "driver	: mysql"
    "organization	: "
    "alien.catalogue.IndexTableEntry getLFN"
    "Empty result set for SELECT \* FROM L0L WHERE lfn=? OR lfn=? and j/jalien/testscript.sh"
    "Received JSh call \[mkdir, -nomsg, -p, /localhost/localdomain/user/j/jalien\]"
    "Entering command with mkdir and options \[alien.shell.commands.JAliEnCOMMander"
    "alien.api.Request authorizeUserAndRole"
    "Successfully switched user from '\[admin\]' to '\[jalien\]'."
    "Using IndexTableEntry indexId: [0-9]\+"
    "hostIndex		: [0-9]\+"
    "tableName		: 0"
    "lfn			: /localhost/localdomain/user/"
    "for: /localhost/localdomain/user/j/jalien"
    "alien.catalogue.IndexTableEntry getDB"
    "alien.user.AuthorizationChecker canWrite"
    "The user \"jalien\" has the right to write \"/localhost/localdomain/user/j/jalien/\""
    "Received JSh call \[stat, -nomsg, /localhost/localdomain/user/j/jalien/testscript.sh\]"
    "Entering command with stat and options \[alien.shell.commands.JAliEnCOMMander"
    "alien.catalogue.IndexTableEntry getLFN"
    "Empty result set for SELECT \* FROM L0L WHERE lfn=? OR lfn=? and j/jalien/testscript.sh"
    "Received JSh call \[access, -nomsg, -s, [0-9]\+, -m, [0-9a-z]\+, write, /localhost/localdomain/user/j/jalien/testscript.sh, disk:[0-9]\+\]"
    "Entering command with access and options \[alien.shell.commands.JAliEnCOMMander@[0-9a-z]\+, \[-s, [0-9]\+, -m, [0-9a-z]\+, write, /localhost/localdomain/user/j/jalien/testscript.sh, disk:[0-9]\+\]\]"
    "alien.shell.commands.JAliEnCommandaccess <init>"
    "Access = write"
    "lien.shell.commands.JAliEnCommandaccess run"
    "Access called for a write operation"
    "alien.api.catalogue.PFNforWrite <init>"
    "Successfully switched user from '\[jalien\]' to '\[jalien\]'."
    "REQUEST IS:Asked for write: LFN entryId	: 0"
    "owner		: jalien:admin"
    "ctime		: null (expires null)"
    "replicated	: false"
    "aclId		: 0"
    "lfn		: j/jalien/testscript.sh"
    "dir		: [0-9]\+"
    "Request details : [-]\+"
    "guidID		: [0-9]\+ (exists: false)"
    "ctime		: null"
    "owner		: jalien:jalien"
    "SE lists	: \[\] , \[\]"
    "aclId		: -1"
    "expireTime	: null"
    "size		: [0-9]\+"
    "guid		: "
    "type		: 0 (0)"
    "md5		: "
    "permissions	: 755"
    "job ID	: unknown"
    "LFN entryId	: [0-9]\+"
    "owner		: jalien:admin"
    "ctime		: null (expires null)"
    "replicated	: false"
    "aclId		: 0"
    "lfn		: j/jalien/testscript.sh"
    "dir		: [0-9]\+"
    "alien.se.SEUtils getBestSEsOnSpecs"
    "got qos: {disk=[0-9]\+}"
    "Returning SE list: \[SE: seName: LOCALHOST::JTESTSITE::FIRSTSE"
    "seNumber	: [0-9]\+"
    "seVersion	: 0"
    "qos	: \[disk\]"
    "seioDaemons	: root://JCentral-dev-SE:1094"
    "seStoragePath	: /tmp"
    "seSize:	: [0-9]\+"
    "seUsedSpace	: [0-9]\+"
    "seNumFiles	: [0-9]\+"
    "seMinSize	: [0-9]\+"
    "seType	: disk"
    "exclusiveUsers	: \[\]"
    "seExclusiveRead	: \[\]"
    "seExclusiveWrite	: \[\]"
    "options:	{}\]"
    "alien.catalogue.access.AuthorizationFactory fillAccess"
    "alien.io.xrootd.envelopes.XrootDEnvelopeSigner encryptEnvelope"
    "Encrypting this envelope:"
    "Received JSh call \[commit, \-nokeys, [-]\+BEGIN SEALED CIPHER[-]\+"
    "[-]\+END SEALED CIPHER[-]\+"
    "[-]\+BEGIN SEALED ENVELOPE[-]\+"
    "[-]\+END SEALED ENVELOPE[-]\+"
    "alien.api.catalogue.RegisterEnvelopes run"
    " Successfully moved root://JCentral-dev-SE:1094//tmp/[0-9]\+/[0-9]\+/[0-9a-z-]\+ to the Catalogue"
    "Commit line : /localhost/localdomain/user/j/jalien/testscript.sh 1"
    "alien.user.UserFactory getByCertificate"
    "Account for 0 (/C=CH/O=JAliEn/CN=jalien) is: \[jalien\]"
    "alien.user.LdapCertificateRealm hasRole"
    "hasRole('\[jalien\]', 'users')"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Submitting sample.jdl"
description="$logs_directory jcentral logs should have logs for submitting sample.jdl."
level="Warning"
expected_lines=(
    "alien.shell.commands.JAliEnCOMMander bootMessage"
    "Starting Commander"
    "alien.shell.commands.JAliEnCOMMander execute"
    "Received JSh call \[commandlist\]"
    "alien.shell.commands.JAliEnCOMMander getCommand"
    "Entering command with commandlist and options \[alien.shell.commands.JAliEnCOMMander@[0-9a-z]\+, \[\]\]"
    "Received JSh call \[submit, /localhost/localdomain/user/j/jalien/sample.jdl"
    "Entering command with submit and options \[alien.shell.commands.JAliEnCOMMander@[0-9a-z]\+, \[/localhost/localdomain/user/j/jalien/sample.jdl\]"
    "Entering command with cp and options \[alien.shell.commands.JAliEnCOMMander@[0-9a-z]\+, \[\-t, /localhost/localdomain/user/j/jalien/sample.jdl\]\]"
    "alien.api.Request authorizeUserAndRole"
    " Successfully switched user from '\[admin\]' to '\[jalien\]'."
    "alien.catalogue.LFNUtils getLFN"
    "Using IndexTableEntry indexId: [0-9]\+"
    "hostIndex		: [0-9]\+"
    "tableName		: 0"
    "lfn			: /localhost/localdomain/user/"
    "for: /localhost/localdomain/user/j/jalien/sample.jdl"
    "alien.catalogue.IndexTableEntry getDB"
    "Host is : Host: hostIndex: [0-9]\+"
    "address	: localhost:3307"
    "database	: alice_users"
    "driver	: mysql"
    "organization	: "
    "alien.shell.commands.JAliEnCommandcp copyGridToLocal"
    "Longest matching path: /localhost/localdomain/user/j/jalien/"
    "alien.catalogue.access.AuthorizationFactory fillAccess"
    "PFN: guidId	: [0-9]\+"
    "pfn		: root://JCentral-dev-SE:1094//tmp/[0-9]\+/[0-9]\+/[0-9a-z-]\+"
    "seNumber	: [0-9]\+"
    "GUID cache value: guidID		: [0-9]\+ (exists: true)"
    "ctime		: [0-9-]\+ [0-9.:]\+"
    "owner		: jalien:jalien"
    "SE lists	: \[1\] , \[\]"
    "aclId		: -1"
    "expireTime	: null"
    "size		: [0-9]\+"
    "guid		: [0-9a-z-]\+"
    "type		: 0 (0)"
    "md5		: [0-9a-f]\+"
    "permissions	: 755"
    "job ID	: unknown, user: \[jalien\], access: read"
    "alien.user.AuthorizationChecker canRead"
    "The user \"jalien\" has the right to read"
    "alien.io.xrootd.envelopes.XrootDEnvelopeSigner encryptEnvelope"
    "Encrypting this envelope:"
    "<authz>"
    "<file>"
    "<access>read</access>"
    "<turl>root://JCentral-dev-SE:1094//tmp/[0-9]\+/[0-9]\+/[0-9a-z-]\+</turl>"
    "<lfn>/localhost/localdomain/user/j/jalien/sample.jdl</lfn>"
    "<size>[0-9]\+</size>"
    "<guid>[0-9A-Z-]\+</guid>"
    "<md5>[0-9a-z]\+</md5>"
    "<pfn>/tmp/[0-9]\+/[0-9]\+/[0-9a-z-]\+</pfn>"
    "<se>LOCALHOST::JTESTSITE::FIRSTSE</se>"
    "</file>"
    "</authz>"
    "alien.shell.commands.JAliEnCommandcp\$GridToLocal run"
    "Trying root://JCentral-dev-SE:1094//tmp/[0-9]\+/[0-9]\+/[0-9a-z-]\+"
    "alien.io.protocols.TempFileManager removeEldestEntry"
    "Decision on ('/tmp/jalien.get.[0-9]\+.temp'): false, count: [0-9]\+ / [0-9]\+, size: [0-9]\+ / [0-9]\+, locked: false"
    "alien.io.protocols.TempFileManager lock"
    "alien.io.protocols.TempFileManager release"
    "alien.user.UserFactory getByCertificate"
    "Checking for chain 0: /C=CH/O=JAliEn/CN=jalien"
    "alien.user.UserFactory getAllByDN"
    "alien.user.UserFactory getByCertificate"
    "Account for 0 (/C=CH/O=JAliEn/CN=jalien) is: \[jalien\]"
    "alien.user.LdapCertificateRealm hasRole"
    "hasRole('\[jalien\]', 'users')"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Getting match job"
description="$logs_directory jcentral logs should have logs for getting match job."
level="Warning"
expected_lines=(
    "alien.taskQueue.JobBroker getMatchJob"
    " We received parameters: {Site=JTestSite, Partition=,,, CE=ALICE::JTestSite::firstce, Platform=Linux-x86_64, Host=localhost.localdomain, Users=\[\], TTL=[0-9]\+, alienCm=localhost.localdomain:10000, AliEnPrincipal=\[jobagent\], CheckedLDAP=, workdir=/var/lib/condor/execute/dir_[0-9]\+, NoUsers=\[\], Localhost=worker1, CEhost=localhost.localdomain, Disk=[0-9]\+, CPUCores=[0-9], CVMFS=1}"
    "alien.taskQueue.TaskQueueUtils updateHostStatus"
    "Updating host localhost.localdomain to status ACTIVE"
    "alien.taskQueue.JobBroker getNumberWaitingForSite"
    "Enforcing additional constraints for worker1"
    "Constraint name : CPU_flags"
    "Constraint expression : regex"
    "Site map does not contain a value for : CPU_flags. Setting the constraint value to null"
    "Constraint name : CGROUPSv2_AVAILABLE"
    "Constraint expression : equality"
    "Site map does not contain a value for : CGROUPSv2_AVAILABLE. Setting the constraint value to null"
    "Constraint name : OS_NAME"
    "Constraint expression : equality"
    "Site map does not contain a value for : OS_NAME. Setting the constraint value to null"
    "Going to select agents (select entryId from JOBAGENT where priority>0 AND counter>0 and ttl < ? and disk < ? and cpucores <= ? and (site='' or site like concat('%,',?,',%'))  and (ce like '' or ce like concat('%,',?,',%')) and noce not like concat('%,',?,',%') and \`partition\`='%'  and (CPU_flags is null) and (CGROUPSv2_AVAILABLE is null) and (OS_NAME is null) order by priority desc, price desc, oldestQueueId asc limit 1)"
    "Bind values: [[0-9]\+, [0-9]\+, 1, JTestSite, ALICE::JTestSite::firstce, ALICE::JTestSite::firstce]"
    "Putting entryId-1"
    "We have a job back"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Getting the waiting job for the agent"
description="$logs_directory jcentral logs should have logs for getting the waiting job for the agent."
level="Warning"
expected_lines=(
    "alien.taskQueue.TaskQueueUtils getSiteId"
    "Going to select siteId: select siteid from SITEQUEUES where site=? ALICE::JTestSite::firstce"
    "alien.taskQueue.JobBroker getWaitingJobForAgentId"
    "Getting a waiting job for 1 and localhost.localdomain and [0-9]\+ and 1"
    "Updated and getting fields queueId, jdl, user for queueId [0-9]\+"
    "Going to return [0-9]\+ and jalien and"
    "User = \"jalien\";"
    "Executable = \"/localhost/localdomain/user/j/jalien/testscript.sh\";"
    "JDLPath = \"/localhost/localdomain/user/j/jalien/sample.jdl\";"
    "OutputDir = \"/localhost/localdomain/user/j/jalien/output_dir_new/\";"
    "Output = {
  \"stdout@disk=1\"
 };"
    "Requirements = ( other.TTL > 21600 ) && ( other.Price <= 1 );"
    "TTL = [0-9]\+;"
    "Price = 1.0;"
    "MemorySize = \"[0-9]\+GB\";"
    "JDLVariables = {
  \"CPUCores\"
 };"
    "CPUCores = \"1\";"
    "Type = \"Job\";"
    "alien.taskQueue.JobToken updateOrInsert"
    "Replace JobToken for: [0-9]\+ and exists: false, known resubmission count: 0"
    "alien.api.Request authorizeUserAndRole"
    "Successfully switched user from '\[admin\]' to '\[jobagent\]'."
    "alien.taskQueue.JRTracker <init>"
    "Starting new JRTracker"
    "alien.taskQueue.JRTracker run"
    "Entering RUN method of JRTRacker"
    "Created a TokenCertificate for the job..."
    "alien.taskQueue.TaskQueueUtils setSiteQueueStatus"
    "Setting site with ce ALICE::JTestSite::firstce to jobagent-match"
    "Got request from \[jobagent\] : alien.api.taskQueue.GetMatchJob"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Executing the job"
description="$logs_directory jcentral logs should have logs for executing the job."
level="Warning"
expected_lines=(
    "alien.api.Request authorizeUserAndRole"
    "Successfully switched user from '\[jobagent\]' to '\[jobagent\]'."
    "alien.taskQueue.TaskQueueUtils getResubmission"
    "Going to select resubmission for: [0-9]\+"
    "alien.api.DispatchSSLServer run"
    "Got request from \[jobagent\] : alien.api.taskQueue.PutJobLog"
    "alien.taskQueue.TaskQueueUtils setJobExtraFields"
    "extrafields: {batchid=BatchId GlobalJobId = \"localhost.localdomain#1.0#[0-9]\+\";}"
    "Got request from \[jobagent\] : alien.api.taskQueue.SetJobStatus"
    "alien.taskQueue.TaskQueueUtils setJobExtraFields"
    "extrafields: {node=worker1, CE=ALICE::JTestSite::firstce, exechost=localhost.localdomain, userId=[0-9]\+}"
    "alien.taskQueue.TaskQueueUtils setFinalStatusOOM"
    "Going to record preemption for job [0-9]\+"
    "Updating status but not in oom db ([0-9]\+ - STARTED)"
    "Updating status but not in oom db ([0-9]\+ - RUNNING)"
    "Updating status but not in oom db ([0-9]\+ - SAVING)"
    "Updating status but not in oom db ([0-9]\+ - DONE)"
)
check_expected_lines

id=$((id + 1))
name="JCentral logs: Uploading the job output"
description="$logs_directory jcentral logs should have logs for uploading the job output."
level="Warning"
expected_lines=(
    "alien.api.Request authorizeUserAndRole"
    "Successfully switched user from '\[jalien\]' to '\[jalien\]'."
    "alien.catalogue.LFNUtils getLFN"
    "Using IndexTableEntry indexId: [0-9]\+"
    "hostIndex		: [0-9]\+"
    "tableName		: 0"
    "lfn			: /localhost/localdomain/user/"
    "for: /localhost/localdomain/user/j/jalien/output_dir_new/stdout"
    "alien.catalogue.IndexTableEntry getDB"
    "Host is : Host: hostIndex: [0-9]\+"
    "address	: localhost:3307"
    "database	: alice_users"
    "driver	: mysql"
    "organization	: "
    "alien.catalogue.IndexTableEntry getLFN"
    "Empty result set for SELECT \* FROM L0L WHERE lfn=? OR lfn=? and j/jalien/output_dir_new/stdout"
    "Successfully switched user from '\[jalien\]' to '\[jalien\]'."
    "alien.catalogue.IndexTableEntry getDB"
    "Host is : Host: hostIndex: [0-9]\+"
    "address	: localhost:3307"
    "database	: alice_users"
    "driver	: mysql"
    "organization	: "
    "alien.se.SEUtils getBestSEsOnSpecs"
    "Returning SE list: \[SE: seName: LOCALHOST::JTESTSITE::FIRSTSE"
    "seNumber	: 1"
    "seVersion	: 0"
    "qos	: \[disk\]"
    "seioDaemons	: root://JCentral-dev-SE:1094"
    "seStoragePath	: /tmp"
    "seSize:	: [0-9]\+"
    "seUsedSpace	: [0-9]\+"
    "seNumFiles	: [0-9]\+"
    "seMinSize	: [0-9]\+"
    "seType	: disk"
    "exclusiveUsers	: \[\]"
    "seExclusiveRead	: \[\]"
    "seExclusiveWrite	: \[\]"
    "options:	{}\]"
    "alien.user.AuthorizationChecker canWrite"
    "The user \"jalien\" has the right to write \"/localhost/localdomain/user/j/jalien/output_dir_new/\""
    "alien.catalogue.access.AuthorizationFactory fillAccess"
    "Error executing 'SELECT distinct guidId, pfn, seNumber FROM G-1L_PFN WHERE guidId=?;'"
    "alien.io.xrootd.envelopes.XrootDEnvelopeSigner encryptEnvelope"
    "Encrypting this envelope:"
    "<authz>"
    "<file>"
    "<access>write-once</access>"
    "<turl>root://JCentral-dev-SE:1094//tmp/[0-9]\+/[0-9]\+/[0-9a-z-]\+</turl>"
    "<lfn>/localhost/localdomain/user/j/jalien/output_dir_new/stdout</lfn>"
    "<size>[0-9]\+</size>"
    "<guid>[0-9A-Z-]\+</guid>"
    "<md5>[0-9a-z]\+</md5>"
    "<pfn>/tmp/[0-9]\+/[0-9]\+/[0-9a-z-]\+</pfn>"
    "<se>LOCALHOST::JTESTSITE::FIRSTSE</se>"
    "</file>"
    "</authz>"
    "alien.api.catalogue.PFNforWrite run"
    "Returning: Asked for write: LFN entryId	: [0-9]\+"
    "owner		: jalien:admin"
    "ctime		: "
    "replicated	: false"
    "aclId		: 0"
    "lfn		: j/jalien/output_dir_new/stdout"
    "dir		: 0"
    "size		: [0-9]\+"
    "Access ticket attached (write)\]"
    "alien.api.catalogue.RegisterEnvelopes run"
    "Successfully moved root://JCentral-dev-SE:1094//tmp/[0-9]\+/[0-9]\+/[0-9a-z-]\+ to the Catalogue"
)
check_expected_lines
