echo -e "\n====== Running all tests for CE ======\n"

source docker_image_validation.sh
source container_validation.sh
source condor_validation.sh
source agent_script_validation.sh
source job_submit.sh

cd ..