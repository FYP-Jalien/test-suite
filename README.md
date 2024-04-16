# JAliEn Replica

JAliEn Replica is a Docker-based multi-container setup designed for local deployment. Serving as a mini version of the CERN ALICE grid, it leverages the same JAliEn code base as found in the ALICE grid. This project allows you to replicate and locally test the functionalities of the ALICE grid.

## Overview

The JAliEn Replica project focuses on providing a simplified environment for testing and verifying the correctness of JAliEn. To ensure the robustness and reliability of the replica, a comprehensive test suite has been developed. This suite concentrates on verifying the environment setup and essential functions, offering a systematic approach to quality assurance.

## Features

- **Docker Multi-Container Setup**: JAliEn Replica utilizes Docker for creating an isolated environment with multiple containers, allowing easy setup and testing.

- **ALICE Grid Compatibility**: By using the same JAliEn code base as the ALICE grid, this replica ensures compatibility with the larger ALICE grid infrastructure.

- **Test Suite**: A carefully crafted test suite is included to facilitate end-to-end tests. These tests are designed to verify the functionality of the replica, providing confidence in the correctness of JAliEn.

## Prerequisites

Before proceeding, ensure the following prerequisites are met:

### jalien-setup

- jalien-setup: Ensure that jalien-setup is properly set up and operational. Failure to have jalien-setup running may result in tests failing and exiting with an error code of 1.

### Install xrootd

```bash
sudo apt install xrootd-client xrootd-server python3-xrootd
```

### Update /etc/hosts

```bash
sudo bash -c "echo '
127.0.0.1       JCentral-dev
127.0.0.1       JCentral-dev-SE
172.18.0.2      alice-jcentral.cern.ch
' >> /etc/hosts"
cat /etc/hosts
```

### Add current user to `docker` group

- Add current user to the `docker` group if it not already done. Follow below steps accordinly.

1. Create the `docker` group

```bash
sudo groupadd docker
```

2. Add the user to the `docker` group

```bash
sudo usermod -aG docker $USER
```

3. Log out and log back or use following command to activate the changes to groups:

```bash
newgrp docker
```

4. Verify that `docker` commands can be run without `sudo`

```bash
docker ps
```

## When Changing the test files

- If you adding new files or removing a test file, please update the respective `index.sh` files inside the respective directories.

## How to run the tests

- Create a `.env` file using the `.env.example` file as a template.
- Run the `index.sh` file in the root directory.
- Make sure that docker is in the user group in the running environment. If not please follow this [Article](https://docs.docker.com/engine/install/linux-postinstall/) to add the user to the docker group 

### Running the test with optional command-line argumanets

In default, running `index.sh` will run all the available tests. If need to run a segment of tests can use followin arguments

- --host-only: Execute only the host specific tests
- --container-only: Execute the host specfic tests and container specifci tests only
- --flow-only: Execute all tests except the advanced logs tests
- --csv: Write test log outputs and test summary to csv
- --no-error-on-exit: Exit with 0 instead of 1  when a critical test fails.

#### Examples

````bash
# Run only the host specific tests and also create the csv
./index.sh --host-only --csv

# Run host specific tests and container specific test only
./index.sh --container-only

# Run all tests excepts advanced logs tests and also create the csv
./index.sh --flow-only --csv
````

## Criticality Levels

- Each Test has an assigned level which denotes its criticality.
  
1. Critical - Failing of these tests will cause the test suite to exit with 1
2. Warning - Failing will these give a warning however, test run will proceed
3. Minor - Failing will give an output message, no warning or exectuion stop.
