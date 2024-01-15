#!/bin/bash

func_path="/host_func/"
source $func_path"messages.sh"

host=127.0.0.1
sql_port=3307
password=pass
user=root

jalien_setup="/jalien-setup"
sql_templates="$jalien_setup/bash-setup/templates/sql"


data_dB="alice_data"
user_dB="alice_users"
VO_name=localhost
base_home_dir="/localhost/localdomain/user/"
act_base_home_dir="localhost/localdomain/user/"


sql_home="/test_suite/sql"
my_cnf="${sql_home}/my.cnf"

my_cnf_content="[client]
host = $host
port = $sql_port
user = $user
password = $password"

function mysql_command() {
    mysql --defaults-extra-file="$my_cnf" --verbose --execute "$1"
}

function mysql_command_return() {
    result=$(mysql  --defaults-extra-file="$my_cnf" --verbose --execute "$1")
    echo "$result"    
}

function mysql_dB_command(){
    mysql_command "USE $1;$2"
}

function mysql_dB_command_return(){
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
    catalogue_tables=("SEDistance" "ACL" "ACTIONS" "COLLECTIONS" "COLLECTIONS_ELEM" "CONSTANTS" "ENVIRONMENT" "FQUOTAS" "G0L" "G0L_PFN" "G0L_QUOTA" "G0L_REF" "GL_ACTIONS" "GROUPS" "GUIDINDEX" "INDEXTABLE" "INDEXTABLE_UPDATE" "L0L" "L0L_QUOTA" "L0L_broken" "LFN_BOOKED" "LFN_UPDATES" "LL_ACTIONS" "LL_STATS" "PACKAGES" "SE" "SERanks" "HOSTS" "orphan_pfns" )
    show_tables=$(mysql_catalogue_dB_command "$1" "SHOW TABLES;")
    for table in "${catalogue_tables[@]}"; do
        if echo "$show_tables" | grep -q "\<$table\>"; then
            print_success "Table $table exists in $1."
        else
            print_error "Table $table in $1 does not exist."
        fi        
    done
}

function check_add_to_GUID_index_table(){
    indexId=$2
    hostIndex=$3
    tableName=$4
    guidTime='guidTime'
    guid2Time2='guid2Time2'
    result=$(mysql_catalogue_dB_command "$1" "SELECT indexId, hostIndex, tableName, 'guidTime', 'guid2Time2' FROM GUIDINDEX;"  | tail -n +6)
    read -r -a values <<< "$result"
    if [ "${values[0]}" == "$indexId" ] && [ "${values[1]}" == "$hostIndex" ] && [ "${values[2]}" == "$tableName" ] && [ "${values[3]}" == "$guidTime" ] && [ "${values[4]}" == "$guid2Time2" ]; then
        print_success "$1 GUIDINDEX table entry is correct."
    else
        print_error "$1 GUIDINDEX table entry is incorrect."
    fi
}

function check_add_to_index_table(){
    result=$(mysql_catalogue_dB_command "$1" "SELECT hostIndex FROM INDEXTABLE WHERE hostIndex='$2' AND tableName='$3' AND lfn='$4';" | tail -n +6)
    if [ "$result" != "$2" ]; then
        print_error "$1 INDEX table entry (hostIndex='$2' AND tableName='$3' AND lfn='$4') is not found."
        echo 0
    fi
    echo 1
}

function check_add_to_hosts_table(){
    result=$(mysql_catalogue_dB_command "$1" "SELECT hostIndex FROM HOSTS WHERE hostIndex='$2' AND address='$3' AND db='$4' AND driver='mysql';" | tail -n +6)
    if [ "$result" != "$2" ]; then
        print_error "$1 HOSTS table entry (hostIndex='$2' AND address='$3' AND db='$4' AND driver='mysql') is not found."
        echo 0
    fi
    echo 1
}

function check_add_to_l0l_table(){
    result=$(mysql_data_dB_command "SELECT entryId FROM L0L WHERE owner='admin' AND ctime='2011-10-06 17:07:26' AND broken='0' AND size='0' AND gowner='admin' AND type='d';" | tail -n +6)
    if [ -z "$result" ]; then
        print_error "L0L table entries (owner='admin' AND ctime='2011-10-06 17:07:26' AND broken='0' AND size='0' AND gowner='admin' AND type='d') is not found."
        return 0
    fi
    return 1
}

function get_parent_dir(){
    result=$(mysql_catalogue_dB_command_return "$1" "SELECT entryId FROM L0L WHERE lfn='$2';" | tail -n +6)
    echo "$result"
}

function check_parent_dir_add_to_l0l_table(){
    result=$(mysql_catalogue_dB_command "$1" "SELECT entryId FROM L0L WHERE owner='$2' AND ctime='2011-10-06 17:07:26' AND lfn='$3' AND   broken='0' AND size='0' AND dir='$4' AND gowner='admin' AND type='d' AND perm='755';" | tail -n +6)
    if [ -z "$result" ]; then
        print_error "$1 L0L table entry (owner='$2' AND ctime='2011-10-06 17:07:26' AND lfn='$3' AND   broken='0' AND size='0' AND dir='$4' AND gowner='admin' AND type='d' AND perm='755') is not found."
        return 0
    fi
    return 1
}



function check_catalogue_initial_directories_common(){
    check_add_to_GUID_index_table "$1" 1 1 0 
    if [ "$(check_add_to_index_table "$1" 1 0 /)" -eq 1 ] && [ "$(check_add_to_index_table "$1" 2 0 $base_home_dir)" -eq 1 ]; then
        print_success "$1 INDEXTABLE table entries are correct."
    fi
    if [ "$(check_add_to_hosts_table "$1" 1 "${VO_name}:${sql_port}" $data_dB)" -eq 1 ] && [ "$(check_add_to_hosts_table "$1" 2 "${VO_name}:${sql_port}" $user_dB)" -eq 1 ]; then
        print_success "$1 HOSTS table entries are correct."
    fi
}

function check_catalogue_initial_directories(){
    success=()
    success+=( "$(check_add_to_l0l_table)" )
    parent_dir=$(get_parent_dir $data_dB '')
    local IFS="/"
    arr=$act_base_home_dir
    new_path=''
    for i in $arr
    do
        unset IFS
        new_path+="${i}/"
        check_parent_dir_add_to_l0l_table $data_dB 'admin' "$new_path" "$parent_dir"
        success+=( $? )
        parent_dir=$(get_parent_dir $data_dB "$new_path")
    done
    if [[ ! " ${success[*]} " =~  0  ]]; then
        print_success "$data_dB L0L table entries are correct."
    fi
    parent_dir=$(get_parent_dir $data_dB "$new_path")
    check_parent_dir_add_to_l0l_table $user_dB 'admin' '' "$parent_dir"
    if [ $? -eq 1 ]; then
        print_success "$user_dB L0L table entries are correct."
    fi
}

function check_add_user_to_dB(){
    parent_dir=$(get_parent_dir $user_dB '')
    sub_string=$(echo "$1" | cut -c1)
    success=()
    check_parent_dir_add_to_l0l_table $user_dB 'admin' "$sub_string/" "$parent_dir"
    success+=( $? )
    parent_dir=$(get_parent_dir $user_dB "${sub_string}/")
    check_parent_dir_add_to_l0l_table $user_dB "$1" "$sub_string/${1}/" "$parent_dir"
    success+=( $? )
    if [[ ! " ${success[*]} " =~  0  ]]; then
        print_success "addUserToDB : $user_dB L0L table entries are correct."
    fi
}

function check_add_SE_to_dB(){
    seNumber=$3
    site=$4
    seName=$2
    storedir=$6
    disk=$7
    qos=$7
    iodeamon=$5
    free_space=$8
    sub_string=$(echo "$5" | cut -d':' -f1)
    success=()
    result=$(mysql_catalogue_dB_command_return "$1" "SELECT seNumber FROM SE WHERE seNumber='$seNumber' AND seMinSize='0' AND seExclusiveWrite='' AND  seName='$VO_name::$site::$seName'  AND seQoS=',$qos,' AND seStoragePath='$storedir' AND seType='$disk' AND seExclusiveRead='' AND seioDaemons='root://$iodeamon' AND seVersion='' ;" | tail -n +6)
    if [ "$result" != "$seNumber" ]; then
        print_error "$1 SE table entry (seNumber='$seNumber' AND seMinSize='0' AND seExclusiveWrite='' AND  seName='$VO_name::$site::$seName'  AND seQoS=',$qos,' AND seStoragePath='$storedir' AND seType='$disk' AND seExclusiveRead='' AND seioDaemons='root://$iodeamon' AND seVersion='' ) is not found."
        success+=( 0 )
    fi
    result=$(mysql_catalogue_dB_command_return "$1" "SELECT volumeId FROM SE_VOLUMES WHERE volume='$storedir' AND volumeId='$seNumber' AND usedSpace='0' AND seName='$VO_name::$site::$seName' AND mountpoint='$storedir' AND size='-1' AND method='file://$sub_string' AND freespace='$free_space' ;" | tail -n +6)
    if [ "$result" != "$seNumber" ]; then
        print_error "$1 SE_VOLUMES table entry (volume='$storedir' AND volumeId='$seNumber' AND usedSpace='0' AND seName='$VO_name::$site::$seName' AND mountpoint='$storedir' AND size='-1' AND method='file://$sub_string' AND freespace='$free_space' ) is not found."
        success+=( 0 )
    fi
    result=$(mysql_catalogue_dB_command_return "$1" "SELECT seNumber FROM SERanks WHERE sitename='$site' AND seNumber='$seNumber' AND updated='0' AND rank='0'  ;" | tail -n +6)
    if [ "$result" != "$seNumber" ]; then
        print_error "$1 SERanks table entry (sitename='$site' AND seNumber='$seNumber' AND updated='0' AND rank='0' ) is not found."
        success+=( 0 )
    fi
    result=$(mysql_catalogue_dB_command_return "$1" "SELECT senumber FROM SEDistance WHERE sitename='$site' AND senumber='$seNumber' AND updated='0' AND distance='0'  ;" | tail -n +6)
    if [ "$result" != "$seNumber" ]; then
        print_error "$1 SEDistance table entry (sitename='$site' AND senumber='$seNumber' AND updated='0' AND distance='0' ) is not found."
        success+=( 0 )
    fi
    if [[ ! " ${success[*]} " =~  0  ]]; then
        print_success "addSEToDB : $1 SE tables entries are correct."
    fi
}

function check_create_processes_database_tables() {
    tables=( "ACTIONS" "FAH_WORKDIR" "FILES_BROKER" "HOSTS" "JOBAGENT" "SITESONAR_CONSTRAINTS" "JOBMESSAGES" "JOBSTOMERGE" "JOBTOKEN" "MESSAGES" "PRIORITY" "QUEUE" "QUEUEJDL" "QUEUEPROC" "QUEUE_CPU" "QUEUE_COMMAND" "QUEUE_HOST" "QUEUE_HOST_backup" "QUEUE_HOST_temp" "QUEUE_NOTIFY" "QUEUE_STATUS" "QUEUE_TMP_EXP" "QUEUE_TOKEN" "QUEUE_TRACE" "QUEUE_USER" "QUEUE_VIEW" "REVISION" "SITEQUEUES" "SITES" "STAGING" "TESTTABLE" "TODELETE"    )
    show_tables=$(mysql_dB_command "processes" "SHOW TABLES;")
    for table in "${tables[@]}"; do
        if echo "$show_tables" | grep -q "\<$table\>"; then
            print_success "Table $table exists in processes."
        else
            print_error "Table $table in processes does not exist."
        fi        
    done
}

function check_add_to_sitesonar_constraints(){ 
    result=$(mysql_dB_command_return "processes" "SELECT name FROM SITESONAR_CONSTRAINTS WHERE name='$1' AND expression='$2' AND enabled='$3' AND lastupdated='$4';" | tail -n +6)
    if [ "$result" != "$1" ]; then
        print_error "SITESONAR_CONSTRAINTS table entry (name='$1' AND expression='$2' AND enabled='$3' AND lastupdated='$4') is not found."
        return 0
    fi
    return 1
}

function check_add_to_sitequeues(){ 
    result=$(mysql_dB_command_return "processes" "SELECT siteId FROM SITEQUEUES WHERE siteId='1' AND runload='0' AND blocked='open' AND status='down' AND site='ALICE::JTESTSITE::FIRSTCE' AND statustime='0' ;" | tail -n +6)
    if [ "$result" != 1 ]; then
        print_error "processes SITEQUEUES table entry ( siteId='1' AND runload='0' AND blocked='open' AND status='down' AND site='ALICE::JTESTSITE::FIRSTCE' AND statustime='0' ) is not found."
    else
        print_success "processes SITEQUEUES table entry is correct."
    fi
    
}

function check_add_status(){
    success=()
    while IFS= read -r n
    do
        code=$(echo "$n" | cut -d "," -f 1)
        status=$(echo "$n" | cut -d "," -f 2)
        result=$(mysql_dB_command_return "processes" "SELECT statusId FROM QUEUE_STATUS WHERE statusId='$code' AND status=$status ;" | tail -n +6)
        if [ "$result" != "$code" ]; then
            print_error "processes QUEUE_STATUS table entry (statusId='$code' AND status='$status' ) is not found."
            success+=( 0 )
        fi
    done < <(grep -v '^ *#' < ${sql_templates}/status_codes.txt)
    if [[ ! " ${success[*]} " =~  0  ]]; then
        print_success "processes QUEUE_STATUS table entries are correct."
    fi
}

function check_optimizer(){
    success=()
    result=$(mysql_dB_command_return "processes" "SELECT maxJobs, maxqueued FROM HOSTS ;" | tail -n +6)
    read -r -a values <<< "$result"
    if [ "${values[0]}" != "3000" ]  ; then
        print_error "processes HOSTS table entry maxJobs is ${values[0]}. It should be 3000."
        success+=( 0 )
    fi
    if [ "${values[1]}" != "300" ]  ; then
        print_error "processes HOSTS table entry maxqueued is ${values[1]}. It should be 300."
        success+=( 0 )
    fi
    result=$(mysql_dB_command_return "processes" "SELECT blocked FROM SITEQUEUES ;" | tail -n +6)
    read -r -a values <<< "$result"
    for value in "${values[@]}"; do
        if [ "$value" != 'open' ] ; then
            print_error "processes SITEQUEUES table entry blocked is $value. It should be open."
            success+=( 0 )
        fi
    done
    result=$(mysql_dB_command_return "processes" "SELECT userId FROM PRIORITY WHERE userId=1235890 AND maxUnfinishedJobs=10000 AND maxTotalCpuCost=10000 AND  maxTotalRunningTime=10000 ;" | tail -n +6)
    if [ "$result" != 1235890 ]; then
        print_error "processes PRIORITY table entry (userId=1235890 AND maxUnfinishedJobs=10000 AND maxTotalCpuCost=10000 AND  maxTotalRunningTime=10000 ) is not found."
        success+=( 0 )
    fi
    result=$(mysql_dB_command_return "processes" "SELECT siteId FROM SITEQUEUES WHERE siteId='-1' AND site='unassigned::site';" | tail -n +6)
    if [ "$result" != -1 ]; then
        print_error "processes SITEQUEUES table entry (siteId='-1' AND site='unassigned::site') is not found."
        success+=( 0 )
    fi
    if [[ ! " ${success[*]} " =~  0  ]]; then
        print_success "Optimiser operations are correct."
    else
        print_error "Optimiser has not run or operations are incomplete."
    fi
}


mkdir -p $sql_home
echo -e "$my_cnf_content" > $my_cnf


catalogue_databases=("$data_dB" "$user_dB" )
databases=("ADMIN" "alice_data" "alice_users" "processes")

show_databases=$(mysql_command "SHOW DATABASES;")    
for db in "${databases[@]}"; do
    if echo "$show_databases" | grep -q "\<$db\>"; then
        print_success "Database $db exists."
    else
        print_error "Database $db does not exist."
    fi
done

catalogue_tables=("SEDistance" "ACL" "ACTIONS" "COLLECTIONS" "COLLECTIONS_ELEM" "CONSTANTS" "ENVIRONMENT" "FQUOTAS" "G0L" "G0L_PFN" "G0L_QUOTA" "G0L_REF" "GL_ACTIONS" "GROUPS" "GUIDINDEX" "INDEXTABLE" "INDEXTABLE_UPDATE" "L0L" "L0L_QUOTA" "L0L_broken" "LFN_BOOKED" "LFN_UPDATES" "LL_ACTIONS" "LL_STATS" "PACKAGES" "SE" "SERanks" "HOSTS" "orphan_pfns" )
for db in "${catalogue_databases[@]}"; do
    check_create_catalogue_database_tables "$db"
    check_catalogue_initial_directories_common "$db"
done
check_catalogue_initial_directories
# no user Index Table - LactuidL
check_add_user_to_dB "jalien" 0
for db in "${catalogue_databases[@]}"; do
    check_add_SE_to_dB "$db" "firstse" 1 "JTestSite" "${SE_HOST}:1094" "/tmp" "disk"
done
check_create_processes_database_tables
success=()
check_add_to_sitesonar_constraints "CGROUPSv2_AVAILABLE" "equality" 1 '0000-00-00 00:00:00'
success+=( $? )
check_add_to_sitesonar_constraints 'OS_NAME' 'equality' 1 '0000-00-00 00:00:00'
success+=( $? )
check_add_to_sitesonar_constraints 'CPU_flags' 'regex' 1 '0000-00-00 00:00:00'
success+=( $? )
if [[ ! " ${success[*]} " =~  0  ]]; then
    print_success "processes SITESONAR_CONSTRAINTS table entries are correct."
fi
check_add_to_sitequeues
check_add_status

check_optimizer

rm -r $sql_home
