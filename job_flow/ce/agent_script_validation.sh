#!/bin/bash

directory="/home/submituser/tmp"
pattern="agent.startup\.[0-9]+"
matching_files=()

id=$((id + 1))
name="Agent Startup Script existence check"
level="Critical"
description="Agent start up scripts should be created. If not make sure the optimiser is running. If the optimiser is just started wait for a few minutes and check again. If the issue persists, try restarting the optimiser."

if sudo docker exec "$CONTAINER_NAME_CE" [ ! -d "$directory" ]; then
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "Directory $directory does not exist."
    exit 1
fi

# Iterate over files in the directory and check if any matches the regex
while IFS= read -r -d '' file; do
    if [[ "$file" =~ $pattern ]]; then
        matching_files+=("$file")
    fi
done < <(sudo docker exec "$CONTAINER_NAME_CE" find "$directory" -type f -name "agent.startup.*" -print0)

# Check if any matching file is found
if [ ${#matching_files[@]} -gt 0 ]; then
    print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent start up scripts found."
    latest_file=$(sudo docker exec "$CONTAINER_NAME_CE" find "$directory" -type f -name "agent.startup.*" -printf "%T@ %p\n" | sort -n | tail -n 1 | cut -d ' ' -f 2-)

    if ! latest_file=$(sudo docker exec "$CONTAINER_NAME_CE" find "$directory" -type f -name "agent.startup.*" -printf "%T@ %p\n" | sort -n | tail -n 1 | cut -d ' ' -f 2-); then
        id=$((id + 1))
        name="Latest Agent Startup Script Existence Check"
        level="Critical"
        description="Latest agent start up script must exist."
        print_full_test "$id" "$name" "FAILED" "$description" "$level" "Latest agent start up script could not be found"
    else

        startup_script_content=$(sudo docker exec "$CONTAINER_NAME_CE" cat "$latest_file")

        function validate_jalien_token_cert() {
            local variable="JALIEN_TOKEN_CERT"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            local pattern='^export JALIEN_TOKEN_CERT="-----BEGIN CERTIFICATE-----$'
            id=$((id + 1))
            name="Agent Startup Script JAliEn Token Cert Check"
            level="Critical"
            description="Agent Startup Script JALien Token Cert must be in the form -----BEGIN CERTIFICATE-----"
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script JALIEN_TOKEN_CERT is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script JALIEN_TOKEN_CERT is invalid or in invalid format."
            fi
        }

        function validate_jalien_token_key() {
            local variable="JALIEN_TOKEN_KEY"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            local pattern='^export JALIEN_TOKEN_KEY="-----BEGIN RSA PRIVATE KEY-----$'
            id=$((id + 1))
            name="Agent Startup Script JAliEn Token Key Check"
            level="Critical"
            description="Agent Startup Script JALien Token Key must be in the form -----BEGIN CERTIFICATE-----"
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script JALIEN_TOKEN_KEY is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script JALIEN_TOKEN_KEY is invalid or in invalid format."
            fi
        }

        function validate_home() {
            local variable="HOME"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export HOME=`pwd`\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \`pwd\`"
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_path() {
            local variable="PATH"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export PATH=`echo \$PATH`\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \`echo $PATH\`"
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_ld_library_path() {
            local variable="LD_LIBRARY_PATH"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export LD_LIBRARY_PATH=`echo \$LD_LIBRARY_PATH`\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \`echo $LD_LIBRARY_PATH\`"
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_tmp() {
            local variable="TMP"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export TMP=\$HOME\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to $HOME"
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        # TODO - validate TMPDIR
        function validate_tmp_dir() {
            local variable="TMPDIR"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern1='^.+export TMPDIR=\"\$HOME/tmp.+$'
            # shellcheck disable=SC2016
            local pattern2='^.+export TMPDIR=.+$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \$TMP or \"\$HOME/tmp\""
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern1 ]] && [[ "$variable_value" =~ $pattern2 ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_log_dir() {
            local variable="LOGDIR"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export LOGDIR=\"\$HOME/log\"\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \"\$HOME/log\""
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_cache_dir() {
            local variable="CACHEDIR"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export CACHEDIR=\"\$HOME/cache\"\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to CACHEDIR=\"\$HOME/cache\""
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_alien_cm_as_ldap_proxy() {
            local variable="ALIEN_CM_AS_LDAP_PROXY"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export ALIEN_CM_AS_LDAP_PROXY=\"\localhost.localdomain:10000"\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \"localhost.localdomain:10000\""
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_site() {
            local variable="site"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export site=\"JTestSite\"\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \"JTestSite\""
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_alien_site() {
            local variable="ALIEN_SITE"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export ALIEN_SITE=\"JTestSite\"\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \"JTestSite\""
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_ce() {
            local variable="CE"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export CE=\"ALICE::JTestSite::firstce\"\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \"ALICE::JTestSite::firstce\""
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_ce_host() {
            local variable="CEhost"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export CEhost=\"localhost.localdomain\"\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \"localhost.localdomain\""
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_ttl() {
            local variable="TTL"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export TTL=\"[0-9]+\"$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to number"
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_apmon_config() {
            local variable="APMON_CONFIG"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export APMON_CONFIG=.localhost\.localdomain.\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \'localhost.localdomain\'"
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_partition() {
            local variable="partition"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export partition=\",,\"\s*$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to \",,\""
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_jobagent_cmd() {
            local variable="JALIEN_JOBAGENT_CMD"
            local variable_value
            variable_value=$(echo "$startup_script_content" | grep "^export $variable=" | sed "s/^export $variable=\"\(.*\)\";/\1/")
            # shellcheck disable=SC2016
            local pattern='^export JALIEN_JOBAGENT_CMD=\"java.* alien.site.JobRunner\"$'
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to Job runner starting command"
            if [ -z "$variable_value" ]; then
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent start up scripts do not contain 'export $variable' line."
            elif [[ "$variable_value" =~ $pattern ]]; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        function validate_eval() {
            local variable="eval \$JALIEN_JOBAGENT_CMD"
            id=$((id + 1))
            name="Agent Startup Script $variable Check"
            level="Critical"
            description="Agent Startup Script $variable must be set to pwd"
            if echo "$startup_script_content" | grep -q "$variable"; then
                print_full_test "$id" "$name" "PASSED" "$description" "$level" "Agent Start up Script $variable is valid."
            else
                print_full_test "$id" "$name" "FAILED" "$description" "$level" "Agent Start up Script $variable is invalid or in invalid format."
            fi
        }

        validate_jalien_token_cert
        validate_jalien_token_key
        validate_home
        validate_path
        validate_ld_library_path
        validate_tmp
        validate_tmp_dir
        validate_log_dir
        validate_cache_dir
        validate_alien_cm_as_ldap_proxy
        validate_site
        validate_alien_site
        validate_ce
        validate_ce_host
        validate_ttl
        validate_apmon_config
        validate_partition
        validate_jobagent_cmd
        validate_eval
    fi

else
    print_full_test "$id" "$name" "FAILED" "$description" "$level" "No agent start up scripts found."
fi
