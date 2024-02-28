#!/bin/bash

source func/messages.sh
source func/conversions.sh
source .env

id=0

source common/index.sh
source central/index.sh
source schedd/index.sh
source se/index.sh
source ce/index.sh
source worker/index.sh
source job_flow/index.sh

