#!/bin/bash

set -e

host=127.0.0.1
sql_port=3307
password=pass
user=root

jalien_setup=$JALIEN_SETUP_PATH
sql_templates="$jalien_setup/bash-setup/templates/sql"

data_dB="alice_data"
user_dB="alice_users"
VO_name=localhost
base_home_dir="/localhost/localdomain/user/"
act_base_home_dir="localhost/localdomain/user/"

SE_HOST="JCentral-dev-SE"

sql_home="/test_suite/sql"
my_cnf="${sql_home}/my.cnf"

my_cnf_content="[client]
host = $host
port = $sql_port
user = $user
password = $password"

function mysql_command() {
    sudo docker exec "$CONTAINER_NAME_CENTRAL" /bin/bash -c "mysql --defaults-extra-file=$my_cnf --execute \"$1\""
}

function mysql_command_return() {
    result=$(sudo docker exec "$CONTAINER_NAME_CENTRAL" /bin/bash -c "mysql --defaults-extra-file=$my_cnf  --execute \"$1\"")
    echo "$result"

}

function mysql_dB_command() {
    mysql_command "USE $1;$2"
}

function mysql_dB_command_return() {
    result=$(mysql_command_return "USE $1;$2")
    echo "$result"
}

function mysql_data_dB_command() {
    mysql_dB_command "$data_dB" "$1"
}

function mysql_data_dB_command_return() {
    result=$(mysql_dB_command_return "$data_dB" "$1")
    echo "$result"
}

function mysql_user_dB_command_return() {
    result=$(mysql_dB_command_return "$user_dB" "$1")
    echo "$result"
}

function mysql_user_dB_command() {
    mysql_dB_command "$user_dB" "$1"
}

function mysql_catalogue_dB_command() {
    if [ "$1" = $user_dB ]; then
        mysql_user_dB_command "$2"
    elif [ "$1" = $data_dB ]; then
        mysql_data_dB_command "$2"
    fi
}

function mysql_catalogue_dB_command_return() {
    if [ "$1" = $user_dB ]; then
        result=$(mysql_user_dB_command_return "$2")
    elif [ "$1" = $data_dB ]; then
        result=$(mysql_data_dB_command_return "$2")
    fi
    echo "$result"
}

function check_create_catalogue_database_tables() {
    catalogue_tables=("SEDistance" "ACL" "ACTIONS" "COLLECTIONS" "COLLECTIONS_ELEM" "CONSTANTS" "ENVIRONMENT" "FQUOTAS" "G0L" "G0L_PFN" "G0L_QUOTA" "G0L_REF" "GL_ACTIONS" "GROUPS" "GUIDINDEX" "INDEXTABLE" "INDEXTABLE_UPDATE" "L0L" "L0L_QUOTA" "L0L_broken" "LFN_BOOKED" "LFN_UPDATES" "LL_ACTIONS" "LL_STATS" "PACKAGES" "SE" "SERanks" "HOSTS" "orphan_pfns")
    id=$((id + 1))
    name="MySQL $1 tables Check"
    level="Critical"
    description="MySQL $1 should have these tables: $(convert_array_to_string "${catalogue_tables[@]}")."
    show_tables=$(mysql_catalogue_dB_command "$1" "SHOW TABLES;")
    for table in "${catalogue_tables[@]}"; do
        if ! echo "$show_tables" | grep -q "\<$table\>"; then
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "Table $table does not exist."
        fi
    done
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "All tables exist."
}

function check_add_to_GUID_index_table() {
    id=$((id + 1))
    name="MySQL $1 insertion to GUID index table Check"
    level="Warning"
    description="MySQL $db GUID index table should have these values: indexId=$2, hostIndex=$3, tableName=$4, guidTime='guidTime', guid2Time2='guid2Time2'."
    indexId=$2
    hostIndex=$3
    tableName=$4
    guidTime='guidTime'
    guid2Time2='guid2Time2'
    result=$(mysql_catalogue_dB_command "$1" "SELECT indexId, hostIndex, tableName, 'guidTime', 'guid2Time2' FROM GUIDINDEX;" | tail -n +2)
    read -r -a values <<<"$result"
    if [ "${values[0]}" == "$indexId" ] && [ "${values[1]}" == "$hostIndex" ] && [ "${values[2]}" == "$tableName" ] && [ "${values[3]}" == "$guidTime" ] && [ "${values[4]}" == "$guid2Time2" ]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "$1 GUIDINDEX table entry is correct."
    else
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "$1 GUIDINDEX table entry (indexId=$2, hostIndex=$3, tableName=$4, guidTime='guidTime', guid2Time2='guid2Time2') is not found."
    fi
}

function check_add_to_index_table() {
    id=$((id + 1))
    name="MySQL $1 insertion to INDEXTABLE table Check"
    level="Warning"
    description="MySQL $db INDEXTABLE table should have these values: hostIndex=$2, tableName=$3, lfn=$4"
    result=$(mysql_catalogue_dB_command "$1" "SELECT hostIndex FROM INDEXTABLE WHERE hostIndex='$2' AND tableName='$3' AND lfn='$4';")
    if ! echo "$result" | grep -q "$2"; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "$1 INDEX table entry (hostIndex='$2' AND tableName='$3' AND lfn='$4') is not found."
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "$1 INDEX table entry is correct."
    fi
}

function check_add_to_hosts_table() {
    id=$((id + 1))
    name="MySQL $1 insertion to HOSTS table Check"
    level="Warning"
    description="MySQL $db HOSTS table should have these values: hostIndex=$2, address=$3, db=$4, driver='mysql'."
    result=$(mysql_catalogue_dB_command "$1" "SELECT hostIndex FROM HOSTS WHERE hostIndex='$2' AND address='$3' AND db='$4' AND driver='mysql';" | tail -n +2)
    if [ "$result" != "$2" ]; then
        echo "Inqueal"
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "$1 HOSTS table entry (hostIndex='$2' AND address='$3' AND db='$4' AND driver='mysql') is not found."
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "$1 HOSTS table entry is correct."
    fi

}

function check_add_to_l0l_table() {
    id=$((id + 1))
    name="MySQL data database insertion to L0L table Check"
    level="Warning"
    description="MySQL data database L0L table should have these values: owner='admin' AND ctime='2011-10-06 17:07:26' AND broken='0' AND size='0' AND gowner='admin' AND type='d'."
    result=$(mysql_data_dB_command "SELECT entryId FROM L0L WHERE owner='admin' AND ctime='2011-10-06 17:07:26' AND broken='0' AND size='0' AND gowner='admin' AND type='d';" | tail -n +4)
    if [ -z "$result" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "L0L table entries are incorrect."
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "L0L table entries are correct."
    fi
}

function get_parent_dir() {
    result=$(mysql_catalogue_dB_command_return "$1" "SELECT entryId FROM L0L WHERE lfn='$2';" | tail -n +2)
    echo "$result"
}

function check_parent_dir_add_to_l0l_table() {
    id=$((id + 1))
    name="MySQL $1 parent dir insertion to L0L table Check"
    level="Warning"
    description="MySQL $1 L0L table should have these values: owner='$2' AND lfn='$3' AND   broken='0' AND size='0' AND dir='$4' AND gowner='admin' AND type='d' AND perm='755'."
    result=$(mysql_catalogue_dB_command "$1" "SELECT entryId, size, dir, gowner, type, perm FROM L0L WHERE owner='$2' AND lfn='$3' AND   broken='0' AND size='0' AND dir='$4'  AND gowner='admin' AND type='d' AND perm='755';")
    if [ -z "$result" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "$1 L0L table entries are incorrect."
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "$1 L0L table entries are correct."
    fi
}

function check_catalogue_initial_directories_common() {
    check_add_to_GUID_index_table "$1" 1 1 0
    check_add_to_index_table "$1" 1 0 /
    check_add_to_index_table "$1" 2 0 $base_home_dir
    check_add_to_hosts_table "$1" 1 "${VO_name}:${sql_port}" $data_dB
    check_add_to_hosts_table "$1" 2 "${VO_name}:${sql_port}" $user_dB
}

function check_catalogue_initial_directories() {
    check_add_to_l0l_table
    parent_dir=$(get_parent_dir $data_dB '')
    local IFS="/"
    arr=$act_base_home_dir
    new_path=''
    for i in $arr; do
        unset IFS
        new_path+="${i}/"
        check_parent_dir_add_to_l0l_table $data_dB 'admin' "$new_path" "$parent_dir"
        parent_dir=$(get_parent_dir $data_dB "$new_path")
    done
    parent_dir=$(get_parent_dir $data_dB "$new_path")
    check_parent_dir_add_to_l0l_table $user_dB 'jalien' '' "$parent_dir"
}

function check_add_user_to_dB() {
    parent_dir=$(get_parent_dir $user_dB '')
    sub_string=$(echo "$1" | cut -c1)
    check_parent_dir_add_to_l0l_table $user_dB 'admin' "$sub_string/" "$parent_dir"
    parent_dir=$(get_parent_dir $user_dB "${sub_string}/")
    check_parent_dir_add_to_l0l_table $user_dB "$1" "$sub_string/${1}/" "$parent_dir"
}

function check_add_SE_to_dB() {
    seNumber=$3
    site=$4
    seName=$2
    storedir=$6
    disk=$7
    qos=$7
    iodeamon=$5
    free_space=$8
    sub_string=$(echo "$5" | cut -d':' -f1)
    id=$((id + 1))
    name="MySQL $1 database insertion to SE table Check"
    level="Critical"
    description="MySQL $1 database should have these SE tables entries: (seNumber='$seNumber' AND seMinSize='0' AND seExclusiveWrite='' AND  seName='$VO_name::$site::$seName'  AND seQoS=',$qos,' AND seStoragePath='$storedir' AND seType='$disk' AND seExclusiveRead='' AND seioDaemons='root://$iodeamon' AND seVersion='' )."
    result=$(mysql_catalogue_dB_command_return "$1" "SELECT seNumber FROM SE WHERE seNumber='$seNumber' AND seMinSize='0' AND seExclusiveWrite='' AND  seName='$VO_name::$site::$seName'  AND seQoS=',$qos,' AND seStoragePath='$storedir' AND seType='$disk' AND seExclusiveRead='' AND seioDaemons='root://$iodeamon' AND seVersion='' ;" | tail -n +2)
    if [ "$result" != "$seNumber" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "SE table entry is incorrect."
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "SE table entry is correct."
    fi
    id=$((id + 1))
    name="MySQL $1 database insertion to SE_VOLUMES table Check"
    level="Critical"
    description="MySQL $1 database should have these SE_VOLUMES tables entries: (volume='$storedir' AND volumeId='$seNumber' AND usedSpace='0' AND seName='$VO_name::$site::$seName' AND mountpoint='$storedir' AND size='-1' AND method='file://$sub_string' AND freespace='$free_space' )."
    result=$(mysql_catalogue_dB_command_return "$1" "SELECT volumeId FROM SE_VOLUMES WHERE volume='$storedir' AND volumeId='$seNumber' AND usedSpace='0' AND seName='$VO_name::$site::$seName' AND mountpoint='$storedir' AND size='-1' AND method='file://$sub_string' AND freespace='$free_space' ;" | tail -n +2)
    if [ "$result" != "$seNumber" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "SE_VOLUMES table entry is incorrect."
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "SE_VOLUMES table entry is correct."
    fi
    id=$((id + 1))
    name="MySQL $1 database insertion to SE_ACTIONS table Check"
    level="Critical"
    description="MySQL $1 database should have these SE_ACTIONS tables entries: (seNumber='$seNumber' AND action
    result=$(mysql_catalogue_dB_command_return "$1" "SELECT seNumber FROM SERanks WHERE sitename='$site' AND seNumber='$seNumber' AND updated='0' AND rank='0'  ;" | tail -n +2)"
    if [ "$result" != "$seNumber" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "SE_ACTIONS table entry is incorrect."
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "SE_ACTIONS table entry is correct."
    fi
    id=$((id + 1))
    name="MySQL $1 database insertion to SE_ACTIONS table Check"
    level="Critical"
    description="MySQL $1 database should have these SE_ACTIONS tables entries: (seNumber='$seNumber' AND action"
    result=$(mysql_catalogue_dB_command_return "$1" "SELECT senumber FROM SEDistance WHERE sitename='$site' AND senumber='$seNumber' AND updated='0' AND distance='0'  ;" | tail -n +2)
    if [ "$result" != "$seNumber" ]; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "SE_ACTIONS table entry is incorrect."
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "SE_ACTIONS table entry is correct."
    fi
}

function check_create_processes_database_tables() {
    tables=("ACTIONS" "FAH_WORKDIR" "FILES_BROKER" "HOSTS" "JOBAGENT" "SITESONAR_CONSTRAINTS" "JOBMESSAGES" "JOBSTOMERGE" "JOBTOKEN" "MESSAGES" "PRIORITY" "QUEUE" "QUEUEJDL" "QUEUEPROC" "QUEUE_CPU" "QUEUE_COMMAND" "QUEUE_HOST" "QUEUE_HOST_backup" "QUEUE_HOST_temp" "QUEUE_NOTIFY" "QUEUE_STATUS" "QUEUE_TMP_EXP" "QUEUE_TOKEN" "QUEUE_TRACE" "QUEUE_USER" "QUEUE_VIEW" "REVISION" "SITEQUEUES" "SITES" "STAGING" "TESTTABLE" "TODELETE")
    id=$((id + 1))
    name="MySQL processes tables Check"
    level="Critical"
    description="MySQL processes should have these tables: $(convert_array_to_string "${tables[@]}")."
    show_tables=$(mysql_dB_command "processes" "SHOW TABLES;")
    for table in "${tables[@]}"; do
        if ! echo "$show_tables" | grep -q "\<$table\>"; then
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "Table $table does not exist in processes database."
        fi
    done
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "All tables exist in processes database."
}

function check_add_to_sitesonar_constraints() {
    id=$((id + 1))
    name="MySQL processes insertion to SITESONAR_CONSTRAINTS table Check"
    level="Warning"
    description="MySQL processes SITESONAR_CONSTRAINTS table should have these values: name='$1' AND expression='$2' AND enabled='$3' AND lastupdated='$4'."
    result=$(mysql_dB_command_return "processes" "SELECT name FROM SITESONAR_CONSTRAINTS WHERE name='$1' AND expression='$2' AND enabled='$3' AND lastupdated='$4';" | tail -n +2)
    if [ "$result" != "$1" ]; then
        print_full_test "$id" "$name" "FAILED" "SITESONAR_CONSTRAINTS table entry (name='$1' AND expression='$2' AND enabled='$3' AND lastupdated='$4') is not found." "$level" "SITESONAR_CONSTRAINTS table entry (name='$1' AND expression='$2' AND enabled='$3' AND lastupdated='$4') is not found."
    else
        print_full_test "$id" "$name" "PASSED" "SITESONAR_CONSTRAINTS table entry is correct." "$level" "SITESONAR_CONSTRAINTS table entry is correct."
    fi
}

function check_add_to_sitequeues() {
    id=$((id + 1))
    name="MySQL processes insertion to SITEQUEUES table Check"
    level="Critical"
    description="MySQL processes SITEQUEUES table should have these values: siteId='1' AND runload='0' AND blocked='open'  AND site='ALICE::JTESTSITE::FIRSTCE' '."
    result=$(mysql_dB_command_return "processes" "SELECT siteId FROM SITEQUEUES WHERE siteId='1' AND runload='0' AND blocked='open' AND site='ALICE::JTESTSITE::FIRSTCE' ;")
    if ! echo "$result" | grep -q "1"; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "SITEQUEUES table entry (siteId='1' AND runload='0' AND blocked='open'  AND site='ALICE::JTESTSITE::FIRSTCE') is not found."
    else
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "SITEQUEUES table entry is correct."
    fi

}

function check_add_status() {
    id=$((id + 1))
    name="MySQL processes insertion to QUEUE_STATUS table Check"
    level="Warning"
    description="MySQL processes QUEUE_STATUS table should have these values: statusId AND status."
    success=()
    result=$(mysql_dB_command_return "processes" "SELECT statusId FROM QUEUE_STATUS WHERE statusId='-1' AND status='ERROR_A' ;")
    while IFS= read -r n; do
        code=$(echo "$n" | cut -d "," -f 1)
        status=$(echo "$n" | cut -d "," -f 2)
        result=$(mysql_dB_command_return "processes" "SELECT statusId FROM QUEUE_STATUS WHERE status=$status  ;" | tail -n +2)
        if [[ "$result" != "$code" ]]; then
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "QUEUE_STATUS table entry (statusId='$code' AND status=$status) is not found."
            success+=(0)
        fi
    done < <(grep -v '^ *#' <"$sql_templates"/status_codes.txt)
    if [[ ! " ${success[*]} " =~ 0 ]]; then
        print_full_test "$id" "$name" "PASSED" "$description" "$level" "QUEUE_STATUS table entries are correct."
    fi
}

function check_optimizer() {
    id=$((id + 1))
    name="MySQL processes Optimiser operations Check"
    level="Critical"
    result=$(mysql_dB_command_return "processes" "SELECT maxJobs, maxqueued FROM HOSTS ;" | tail -n +2)
    read -r -a values <<<"$result"
    if [ "${values[0]}" != "3000" ]; then
        description="processes HOSTS table entry maxJobs is ${values[0]}. It should be 3000."
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "processes HOSTS table entry maxJobs is ${values[0]}. It should be 3000."
        success+=(0)
    fi
    if [ "${values[1]}" != "300" ]; then
        description="processes HOSTS table entry maxqueued is ${values[1]}. It should be 300."
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "processes HOSTS table entry maxqueued is ${values[1]}. It should be 300."
        success+=(0)
    fi
    result=$(mysql_dB_command_return "processes" "SELECT blocked FROM SITEQUEUES ;" | tail -n +2)
    read -r -a values <<<"$result"
    for value in "${values[@]}"; do
        if [ "$value" != 'open' ]; then
            description="processes SITEQUEUES table entry blocked is $value. It should be open."
            print_full_test "$id" "$name" "FAILED" "$description" "$level" "processes SITEQUEUES table entry blocked is $value. It should be open."
            success+=(0)
        fi
    done

    result=$(mysql_dB_command_return "processes" "SELECT userId FROM PRIORITY WHERE userId=1235890 AND maxUnfinishedJobs=10000 AND maxTotalCpuCost=10000 AND  maxTotalRunningTime=10000 ;" | tail -n +2)
    if [ "$result" != 1235890 ]; then
        description="processes PRIORITY table entry (userId=1235890 AND maxUnfinishedJobs=10000 AND maxTotalCpuCost=10000 AND  maxTotalRunningTime=10000 ) is not found."
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "processes PRIORITY table entry (userId=1235890 AND maxUnfinishedJobs=10000 AND maxTotalCpuCost=10000 AND  maxTotalRunningTime=10000 ) is not found."
        success+=(0)
    fi
    result=$(mysql_dB_command_return "processes" "SELECT siteId FROM SITEQUEUES WHERE siteId='-1' AND site='unassigned::site';" | tail -n +2)
    if [ "$result" != -1 ]; then
        description="processes SITEQUEUES table entry (siteId='-1' AND site='unassigned::site') is not found."
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "processes SITEQUEUES table entry (siteId='-1' AND site='unassigned::site') is not found."
        success+=(0)
    fi
    print_full_test "$id" "$name" "PASSED" "Optimiser operations are complete." "$level" "Optimiser operations are complete."
}

sudo docker exec "$CONTAINER_NAME_CENTRAL" /bin/bash -c "mkdir -p $sql_home"
sudo docker exec "$CONTAINER_NAME_CENTRAL" /bin/bash -c "echo -e '$my_cnf_content' >'$my_cnf'"

execution_error_message="MySQL execution failed."

databases=("ADMIN" "alice_data" "alice_users" "processes")

id=$((id + 1))
name="MySQL Databases Check"
level="Critical"
description="MySQL should have these databases: $(convert_array_to_string "${databases[@]}")."
if ! show_databases=$(mysql_command "SHOW DATABASES;"); then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "$execution_error_message"
    exit 1
fi
for db in "${databases[@]}"; do
    if ! echo "$show_databases" | grep -q "\<$db\>"; then
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "Database $db does not exist."
    fi
done
print_full_test "$id" "$name" "PASSED" "$description" "$level" "All databases exist."

catalogue_databases=("$data_dB" "$user_dB")

for db in "${catalogue_databases[@]}"; do
    id=$((id + 1))
    check_create_catalogue_database_tables "$db"
    id=$((id + 1))
    check_catalogue_initial_directories_common "$db"
done

id=$((id + 1))
check_catalogue_initial_directories $id
# no user Index Table - LactuidL

check_add_user_to_dB "jalien" 0
for db in "${catalogue_databases[@]}"; do
    check_add_SE_to_dB "$db" "firstse" 1 "JTestSite" "${SE_HOST}:1094" "/tmp" "disk"
done
check_create_processes_database_tables
check_add_to_sitesonar_constraints "CGROUPSv2_AVAILABLE" "equality" 1 '0000-00-00 00:00:00'
check_add_to_sitesonar_constraints 'OS_NAME' 'equality' 1 '0000-00-00 00:00:00'
check_add_to_sitesonar_constraints 'CPU_flags' 'regex' 1 '0000-00-00 00:00:00'
check_add_to_sitequeues
check_add_status

check_optimizer

sudo docker exec "$CONTAINER_NAME_CENTRAL" /bin/bash -c "rm -r $sql_home"
