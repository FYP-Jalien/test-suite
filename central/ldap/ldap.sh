#!/bin/bash

func_path="/host_func/"
source $func_path"messages.sh"

ldap_port="8389"

result=$(ldapsearch -x -b "o=localhost,dc=localdomain" -H ldap://localhost:$ldap_port | grep "numEntries" |  awk '{print $3}')
if [ "$result" -eq 24 ]; then
    print_success "LDAP is configured correctly."
else
    print_error "LDAP configuration is incorrect."
fi
