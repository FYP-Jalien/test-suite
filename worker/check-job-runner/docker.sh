#!/bin/bash
func_path="/host_func/"
source $func_path"messages.sh"

max_tries=10

test_tries=0

duplicate_dir="test_dir_copy"
duplicate_dir_path="/var/lib/condor/execute/$duplicate_dir"

get_directory_name() {
    directories=$(ls -d /var/lib/condor/execute/*/)
    directory_name=""
    for directory in $directories; do
        directory_name=$directory
    done
    echo $directory_name
}

duplicate_directory() {
    dir_name=$1
    mkdir $duplicate_dir_path
    cd $dir_name
    cp -r ./* $duplicate_dir_path
    echo "Directory created"
}

check_directory() {
    ls -d /var/lib/condor/execute/*/ >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        print_success "Sub directory exit for job runner"
        
        dir_name=$(get_directory_name)
        duplicate_directory $dir_name
        return 1
    fi
    print_error "No sub directory found for job runner"
    return 0
    
}

directory_check=0

while [ $test_tries -le $max_tries ]; do
    check_directory
    directory_check=( $? )
    if [ $directory_check -eq 0 ]; then
        echo "Waiting for directory to come live"
        sleep 10
    else   
        break
    fi
done
echo "Test one"

if [ $directory_check -eq 0 ]; then
    print_err "Directory not found"
    exit 0
fi

# Check for the file cheks
echo "Cd for duplicate path"
cd $duplicate_dir_path
if grep '"command":"boot"' access_log; then
    print_success "Command boot log found"
else
    print_error "Command boot log not found"
fi

if grep '"command":"login"' access_log; then
    print_success "Command login log found"
else
    print_error "Command login log not found"
fi

if grep "JALIEN_TOKEN_CERT" condor_exec.exe; then
    print_success "JALIEN_TOKEN_CERT is available in the context"
else
    print_error "JALIEN_TOKEN_CERT is not available in the context"
fi

if grep "JALIEN_TOKEN_KEY" condor_exec.exe; then
    print_success "JALIEN_TOKEN_KEY is available in the context"
else
    print_error "JALIEN_TOKEN_KEY is not available in the context"
fi