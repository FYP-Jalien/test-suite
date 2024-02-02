echo -e "====== Running all tests for Common ======\n"

source python3_validation.sh
source mysql_validation.sh
source java_version_validation.sh
source docker_validation.sh
source docker_compose_validation.sh

cd ..