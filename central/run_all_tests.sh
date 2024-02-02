source ./func/messages.sh

print_test_header "Central"

source container_validation.sh
source package_check.sh
source file_check.sh

# Running the tests in mysql.
cd mysql/
source run_all_tests.sh

# Running the tests in ldap.
cd ldap/
source run_all_tests.sh

cd ..
