current_date=$(date +'%Y-%m-%d')
directory_path="/home/submituser/htcondor/$current_date"
container_name="shared_volume-JCentral-dev-CE-1"


files=$(sudo docker exec -it "$container_name" bin/bash -c "ls $directory_path")
