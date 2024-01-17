#!/bin/bash

func_path="/host_func/"
source $func_path"messages.sh"

ldap_port="8389"

generate_ldap_filter() {
    combined=("$@")
    length=${combined[0]}
    keys=("${combined[@]:1:$length}")
    values=("${combined[@]:$length+1}")

    filter="(&"
    for ((i = 0; i < "$length"; i++)); do
        filter+="(${keys[i]}=${values[i]})"
    done
    filter+=")"
    echo "$filter"
}

function ldap_search_count(){
   ldapsearch -x -b "$1" -s base "$2" -H ldap://localhost:$ldap_port | grep "numEntries" |  awk '{print $3}'
}

function check_localhost_localdomain(){
    base_dn="o=localhost,dc=localdomain"
    keys=("objectClass" "objectClass")
    values=("top" "organization")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# localhost, localdomain is configured in LDAP."
    else
        print_error "# localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_packages_localhost_localdomain(){
    base_dn="ou=Packages,o=localhost,dc=localdomain"
    keys=("objectClass" "objectClass" "ou")
    values=("top" "organizationalUnit" "Packages")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Packages, localhost, localdomain is configured in LDAP."
    else
        print_error "# Packages, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_institutions_localhost_localdomain(){
    base_dn="ou=Institutions,o=localhost,dc=localdomain"
    keys=("objectClass" "objectClass" "ou")
    values=("top" "organizationalUnit" "Institutions")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Institutions, localhost, localdomain is configured in LDAP."
    else
        print_error "# Institutions, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_partitions_localhost_localdomain(){
    base_dn="ou=Partitions,o=localhost,dc=localdomain"
    keys=("objectClass" "objectClass" "ou")
    values=("top" "organizationalUnit" "Partitions")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Partitions, localhost, localdomain is configured in LDAP."
    else
        print_error "# Partitions, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_people_localhost_localdomain(){
    base_dn="ou=People,o=localhost,dc=localdomain"
    keys=("objectClass" "objectClass" "ou")
    values=("top" "organizationalUnit" "People")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# People, localhost, localdomain is configured in LDAP."
    else
        print_error "# People, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_roles_localhost_localdomain(){
    base_dn="ou=Roles,o=localhost,dc=localdomain"
    keys=("objectClass" "objectClass" "ou")
    values=("top" "organizationalUnit" "Roles")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Roles, localhost, localdomain is configured in LDAP."
    else
        print_error "# Roles, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_services_localhost_localdomain(){
    base_dn="ou=Services,o=localhost,dc=localdomain"
    keys=("objectClass" "objectClass" "ou")
    values=("top" "organizationalUnit" "Services")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Services, localhost, localdomain is configured in LDAP."
    else
        print_error "# Services, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_sites_localhost_localdomain(){
    base_dn="ou=Sites,o=localhost,dc=localdomain"
    keys=("objectClass" "objectClass" "ou")
    values=("top" "organizationalUnit" "Sites")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_config_localhost_localdomain(){
    base_dn="ou=Config,o=localhost,dc=localdomain"
    keys=("objectClass" "transferBrokerAddress" "lbsgDatabase" "jobManagerAddress" "catalogueDatabase" "jobinfoManagerAddress" "isDatabase" "authenDriver" "transferOptimizerAddress" "packmanmasterAddress" "sedefaultQosandCount" "semasterDatabase" "authHost" "catalogueOptimizerAddress" "queueDriver" "queueHost" "catalogDatabase" "isPort" "messagesmasterAddress" "authenHost" "queueDbHost" "jobOptimizerAddress" "catalogPort" "jobBrokerAddress" "lbsgAddress" "processPort" "logHost" "brokerPort" "transferDatabase" "semasterManagerAddress" "transferManagerAddress" "jobDatabase" "userDir" "catalogDriver" "clusterMonitorUser" "isDriver" "isHost" "catalogHost" "isDbHost" "brokerHost" "clustermonitorPort" "authenDatabase" "authPort" "queuePort" "logPort" "queueDatabase" "authenSubject" "ldapmanager")
    values=("top" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "disk=1" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8081" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "8082" "testVO/user" "8082" "8082" "8082" "8082" "8082" "ADMIN" "8080" "8082" "8082" "8082" "/C=CH/O=JAliEn/CN=jalien" "dc=localdomain")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Config, localhost, localdomain is configured in LDAP."
    else
        print_error "# Config, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_admin_people_localhost_localdomain(){
    base_dn="uid=admin,ou=People,o=localhost,dc=localdomain"
    keys=("objectClass" "loginShell" "gidNumber" "uidNumber" "roles" "uid" "subject" "cn" "homeDirectory")
    values=("top" "false" "1" "1" "admin" "admin" "/C=CH/O=JAliEn/CN=NOadmin" "admin" "/localhost/localdomain/user/a/admin")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# admin, People, localhost, localdomain is configured in LDAP."
    else
        print_error "# admin, People, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_admin_roles_localhost_localdomain(){
    base_dn="uid=admin,ou=Roles,o=localhost,dc=localdomain"
    keys=("objectClass" "uid" "users")
    values=("top" "admin" "admin")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# admin, Roles, localhost, localdomain is configured in LDAP."
    else
        print_error "# admin, Roles, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_jalien_people_localhost_localdomain(){
    base_dn="uid=jalien,ou=People,o=localhost,dc=localdomain"
    keys=("objectClass" "loginShell" "gidNumber" "uidNumber" "roles" "uid" "subject" "cn" "homeDirectory")
    values=("top" "false" "1" "2" "admin" "jalien" "/C=CH/O=JAliEn/CN=jalien" "jalien" "/localhost/localdomain/user/j/jalien")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# jalien, People, localhost, localdomain is configured in LDAP."
    else
        print_error "# jalien, People, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_jalien_roles_localhost_localdomain(){
    base_dn="uid=jalien,ou=Roles,o=localhost,dc=localdomain"
    keys=("objectClass" "uid" "users")
    values=("top" "jalien" "admin")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# jalien, Roles, localhost, localdomain is configured in LDAP."
    else
        print_error "# jalien, Roles, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_vobox_roles_localhost_localdomain(){
    base_dn="uid=vobox,ou=Roles,o=localhost,dc=localdomain"
    keys=("objectClass" "uid" "users")
    values=("AliEnRole" "vobox" "admin" "jalien")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# vobox, Roles, localhost, localdomain is configured in LDAP."
    else
        print_error "# vobox, Roles, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_JTestSite_sites_localhost_localdomain(){
    base_dn="ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    keys=("objectClass" "accountName" "logdir" "cachedir" "ou" "domain" "tmpdir")
    values=("top" "JTestSite" "/tmp" "/tmp" "JTestSite" "localdomain" "/tmp")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_config_JTestSite_sites_localhost_localdomain(){
    base_dn="ou=Config,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    keys=("objectClass" "ou")
    values=("top" "Config")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Config, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# Config, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_services_JTestSite_sites_localhost_localdomain(){
    base_dn="ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    keys=("objectClass" "ou")
    values=("top" "Services")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_SE_services_JTestSite_sites_localhost_localdomain(){
    base_dn="ou=SE,ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    keys=("objectClass" "ou")
    values=("top" "SE")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# SE, Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# SE, Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_CE_services_JTestSite_sites_localhost_localdomain(){
    base_dn="ou=CE,ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    keys=("objectClass" "ou")
    values=("top" "CE")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# CE, Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# CE, Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_FTD_services_JTestSite_sites_localhost_localdomain(){
    base_dn="ou=FTD,ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    keys=("objectClass" "ou")
    values=("top" "FTD")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# FTD, Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# FTD, Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_firstse_SE_services_JTestSite_sites_localhost_localdomain(){
    base_dn="name=firstse,ou=SE,ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    keys=("objectClass" "name" "port" "ftdprotocol" "QoS" "savedir" "mss" "ioDaemons" "host")
    values=("top" "firstse" "8389" "cp" "disk" "/root/.alien/testVO/SE_storage/firstse" "File" "file:host=localhost:port=\${port}" "localhost")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# firstse, SE, Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# firstse, SE, Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_firstce_CE_services_JTestSite_sites_localhost_localdomain(){
    base_dn="name=firstce,ou=CE,ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    keys=("objectClass" "name" "host" "installMethod" "maxjobs" "environment" "maxqueuedjobs" "TTL" "type")
    values=("AliEnCE" "firstce" "localhost.localdomain" "CVMFS" "3000" "CE_LCGCE=schedd:9618" "300" "87000" "HTCONDOR")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# firstce, CE, Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# firstce, CE, Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_localhost_localdomain_config_JTestSite_sites_localhost_localdomain(){
    base_dn="host=localhost.localdomain,ou=Config,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    keys=("objectClass" "cachedir" "tmpdir" "logdir" "ce" "host")
    values=("top" "\$HOME/cache" "\$HOME/tmp" "\$HOME/log" "firstce" "localhost.localdomain")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# localhost.localdomain, Config, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# localhost.localdomain, Config, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}

function check_jobagent_people_localhost_localdomain(){
    base_dn="uid=jobagent,ou=People,o=localhost,dc=localdomain"
    keys=("objectClass" "accountName" "cn" "gecos" "gidNumber" "homeDirectory" "subject" "uid" "uidNumber")
    values=("top" "special_account_jobagent" "JobAgent generic identity" "JobAgent" "-2" "/localhost/localdomain/user/j/jobagent" "/C=ch/O=AliEn/CN=JobAgent" "jobagent" "-2")
    ldap_filter=$(generate_ldap_filter "${#keys[@]}" "${keys[@]}" "${values[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# jobagent, People, localhost, localdomain is configured in LDAP."
    else
        print_error "# jobagent, People, localhost, localdomain is not configured correctly in LDAP."
    fi
}

check_localhost_localdomain
check_packages_localhost_localdomain
check_institutions_localhost_localdomain
check_partitions_localhost_localdomain
check_people_localhost_localdomain
check_roles_localhost_localdomain
check_services_localhost_localdomain
check_sites_localhost_localdomain
check_config_localhost_localdomain
check_admin_people_localhost_localdomain
check_admin_roles_localhost_localdomain
check_jalien_people_localhost_localdomain
check_jalien_roles_localhost_localdomain
check_vobox_roles_localhost_localdomain
check_JTestSite_sites_localhost_localdomain
check_config_JTestSite_sites_localhost_localdomain
check_services_JTestSite_sites_localhost_localdomain
check_SE_services_JTestSite_sites_localhost_localdomain
check_CE_services_JTestSite_sites_localhost_localdomain
check_FTD_services_JTestSite_sites_localhost_localdomain
check_firstse_SE_services_JTestSite_sites_localhost_localdomain
check_firstce_CE_services_JTestSite_sites_localhost_localdomain
check_localhost_localdomain_config_JTestSite_sites_localhost_localdomain
check_jobagent_people_localhost_localdomain