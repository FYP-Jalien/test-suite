#!/bin/bash

source ../.env

success_color="\033[32m"
error_color="\033[31m"
reset_color="\033[0m"

# List of packages to check
packages=(
    attr alicexrdplugins autoconf automake avahi-compat-libdns_sd-devel bc bind-export-libs bind-libs bind-libs-lite bind-utils binutils bison bzip2-devel cmake compat-libgfortran-41 compat-libstdc++-33 e2fsprogs e2fsprogs-libs environment-modules fftw-devel file-devel flex gcc gcc-c++ gcc-gfortran git glew-devel glibc-devel glibc-static gmp-devel graphviz-devel libcurl-devel libpng-devel libtool libX11-devel libXext-devel libXft-devel libxml2-devel libxml2-static libXmu libXpm-devel libyaml-devel mesa-libGL-devel mesa-libGLU-devel motif-devel mpfr-devel mysql-devel ncurses-devel openldap-devel openssl-devel openssl-static openssh-clients openssh-server pciutils-devel pcre-devel perl-ExtUtils-Embed perl-libwww-perl protobuf-devel python-devel python-pip readline-devel redhat-lsb rpm-build swig tcl tcsh texinfo tk-devel unzip uuid-devel wget which xrootd xrootd-server xrootd-client xrootd-client-devel xrootd-python yum-plugin-priorities zip zlib-devel zlib-static zsh strace net-tools xz
)

if ! sudo docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME_WORKER$"; then
    echo -e "${error_color}Container $CONTAINER_NAME_WORKER is not running.${reset_color}"
    exit 1
fi

for package in "${packages[@]}"; do
    # Check if the package is installed
    sudo docker exec "$CONTAINER_NAME_WORKER" yum list installed "$package" > /dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        echo -e "${success_color}Package '$package' is installed in container '$CONTAINER_NAME_WORKER'${reset_color}"
    else
        echo -e "${error_color}Package '$package' is not installed in container '$CONTAINER_NAME_WORKER'${reset_color}"
    fi
done


# Check whether Zulu java is installed or not
sudo docker exec "$CONTAINER_NAME_WORKER" yum list installed | grep zulu11.68.17-ca-jdk11.0.21-linux.x86_64 > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo -e "${success_color}Package 'zulu11.68.17-ca-jdk11.0.21-linux.x86_64' is installed in container '$CONTAINER_NAME_WORKER'${reset_color}"
else
    echo -e "${error_color}Package 'zulu11.68.17-ca-jdk11.0.21-linux.x86_64' is not installed in container '$CONTAINER_NAME_WORKER'${reset_color}"
fi

