# JAliEn Replica

JAliEn Replica is a Docker-based multi-container setup designed for local deployment. Serving as a mini version of the CERN ALICE grid, it leverages the same JAliEn code base as found in the ALICE grid. This project allows you to replicate and locally test the functionalities of the ALICE grid.

## Overview

The JAliEn Replica project focuses on providing a simplified environment for testing and verifying the correctness of JAliEn. To ensure the robustness and reliability of the replica, a comprehensive test suite has been developed. This suite concentrates on verifying the environment setup and essential functions, offering a systematic approach to quality assurance.

## Features

- **Docker Multi-Container Setup**: JAliEn Replica utilizes Docker for creating an isolated environment with multiple containers, allowing easy setup and testing.

- **ALICE Grid Compatibility**: By using the same JAliEn code base as the ALICE grid, this replica ensures compatibility with the larger ALICE grid infrastructure.

- **Test Suite**: A carefully crafted test suite is included to facilitate end-to-end tests. These tests are designed to verify the functionality of the replica, providing confidence in the correctness of JAliEn.

## Branches

- **develop**: The develop branch contains the latest changes and updates.
- **main**: The main branch houses stable changes that have been thoroughly tested.

## When Changing the test files

- If you adding new files or removing a test file, please update the `run_all_test.sh` file inside the directory.

## How to run the tests

- Create a `.env` file using the `.env.example` file as a template.
- Run the `sudo test.sh` file in the root directory.

## Criticality Levels

- Each Test has an assigned level which denotes its criticality.
1. Critical - Failing of these tests will cause the test suite to exit with 1
2. Warning - Failing will these give a warning however, test run will proceed
3. Minor - Failing will give an output message, no warning or exectuion stop.
