#!/bin/bash

func_path="/host_func/"
source $func_path"messages.sh"

ldap_port="8389"

generate_ldap_filter() {
    local array=("$@")
    local filter="(&"
    for element in "${array[@]}"; do
        filter+="(objectClass=$element)"
    done
    filter+=")"
    echo "$filter"
}

function ldap_search_count(){
   ldapsearch -x -b "$1" -s base "$2" -H ldap://localhost:$ldap_port | grep "numEntries" |  awk '{print $3}'
}

function check_localhost_localdomain(){
    base_dn="o=localhost,dc=localdomain"
    filter_array=("top" "organization")
    count=$(ldap_search_count $base_dn "$(generate_ldap_filter "${filter_array[@]}")")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# localhost, localdomain is configured in LDAP."
    else
        print_error "# localhost, localdomain is not configured corretly in LDAP."
    fi
}
function check_packages_localhost_localdomain() {
    base_dn="ou=Packages,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Packages, localhost, localdomain is configured in LDAP."
    else
        print_error "# Packages, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_institutions_localhost_localdomain() {
    base_dn="ou=Institutions,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Institutions, localhost, localdomain is configured in LDAP."
    else
        print_error "# Institutions, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_partitions_localhost_localdomain() {
    base_dn="ou=Partitions,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Partitions, localhost, localdomain is configured in LDAP."
    else
        print_error "# Partitions, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_people_localhost_localdomain() {
    base_dn="ou=People,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# People, localhost, localdomain is configured in LDAP."
    else
        print_error "# People, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_roles_localhost_localdomain() {
    base_dn="ou=Roles,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Roles, localhost, localdomain is configured in LDAP."
    else
        print_error "# Roles, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_services_localhost_localdomain() {
    base_dn="ou=Services,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Services, localhost, localdomain is configured in LDAP."
    else
        print_error "# Services, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_sites_localhost_localdomain() {
    base_dn="ou=Sites,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_config_localhost_localdomain() {
    base_dn="ou=Config,o=localhost,dc=localdomain"
    filter_array=("top" "AliEnVOConfig")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Config, localhost, localdomain is configured in LDAP."
    else
        print_error "# Config, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_admin_people_localhost_localdomain() {
    base_dn="uid=admin,ou=People,o=localhost,dc=localdomain"
    filter_array=("top" "posixAccount" "AliEnUser" "pkiUser")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# admin, People, localhost, localdomain is configured in LDAP."
    else
        print_error "# admin, People, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_admin_roles_localhost_localdomain() {
    base_dn="uid=admin,ou=Roles,o=localhost,dc=localdomain"
    filter_array=("top" "AliEnRole")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# admin, Roles, localhost, localdomain is configured in LDAP."
    else
        print_error "# admin, Roles, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_jalien_people_localhost_localdomain() {
    base_dn="uid=jalien,ou=People,o=localhost,dc=localdomain"
    filter_array=("top" "posixAccount" "AliEnUser" "pkiUser")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# jalien, People, localhost, localdomain is configured in LDAP."
    else
        print_error "# jalien, People, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_jalien_roles_localhost_localdomain() {
    base_dn="uid=jalien,ou=Roles,o=localhost,dc=localdomain"
    filter_array=("top" "AliEnRole")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# jalien, Roles, localhost, localdomain is configured in LDAP."
    else
        print_error "# jalien, Roles, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_vobox_roles_localhost_localdomain() {
    base_dn="uid=vobox,ou=Roles,o=localhost,dc=localdomain"
    filter_array=("top" "AliEnRole")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# vobox, Roles, localhost, localdomain is configured in LDAP."
    else
        print_error "# vobox, Roles, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_JTestSite_sites_localhost_localdomain() {
    base_dn="ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit" "AliEnSite")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_config_JTestSite_sites_localhost_localdomain() {
    base_dn="ou=Config,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Config, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# Config, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_services_JTestSite_sites_localhost_localdomain() {
    base_dn="ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_SE_services_JTestSite_sites_localhost_localdomain() {
    base_dn="ou=SE,ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# SE, Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# SE, Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_CE_services_JTestSite_sites_localhost_localdomain() {
    base_dn="ou=CE,ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# CE, Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# CE, Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_FTD_services_JTestSite_sites_localhost_localdomain() {
    base_dn="ou=FTD,ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    filter_array=("top" "organizationalUnit")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# FTD, Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# FTD, Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_firstse_SE_services_JTestSite_sites_localhost_localdomain() {
    base_dn="name=firstse,ou=SE,ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    filter_array=("top" "AliEnSE" "AliEnMSS" "AliEnSOAPServer")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# firstse, SE, Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# firstse, SE, Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_firstce_CE_services_JTestSite_sites_localhost_localdomain() {
    base_dn="name=firstce,ou=CE,ou=Services,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    filter_array=("top" "AliEnCE")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# firstce, CE, Services, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# firstce, CE, Services, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_localhost_localdomain_config_JTestSite_sites_localhost_localdomain() {
    base_dn="host=localhost.localdomain,ou=Config,ou=JTestSite,ou=Sites,o=localhost,dc=localdomain"
    filter_array=("top" "AliEnHostConfig")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
    count=$(ldap_search_count "$base_dn" "$ldap_filter")
    if [ -n "$count" ] && [ "$count" -ne 0 ]; then
        print_success "# localhost.localdomain, Config, JTestSite, Sites, localhost, localdomain is configured in LDAP."
    else
        print_error "# localhost.localdomain, Config, JTestSite, Sites, localhost, localdomain is not configured correctly in LDAP."
    fi
}
function check_jobagent_people_localhost_localdomain() {
    base_dn="uid=jobagent,ou=People,o=localhost,dc=localdomain"
    filter_array=("top" "posixAccount" "pkiUser" "AliEnUser")
    ldap_filter=$(generate_ldap_filter "${filter_array[@]}")
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