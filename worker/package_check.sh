#!/bin/bash  

id=$((id + 1))
name="Worker Container Critical Package Check"
level="Warning"

critical_packages=(
    attr autoconf automake avahi-compat-libdns_sd-devel bc bind-export-libs bind-libs bind-libs-lite bind-utils binutils bison bzip2-devel cmake compat-libgfortran-41 compat-libstdc++-33 e2fsprogs e2fsprogs-libs environment-modules fftw-devel file-devel flex gcc gcc-c++ gcc-gfortran git glew-devel glibc-devel glibc-static gmp-devel graphviz-devel libcurl-devel libpng-devel libtool libX11-devel libXext-devel libXft-devel libxml2-devel libxml2-static libXmu libXpm-devel libyaml-devel mesa-libGL-devel mesa-libGLU-devel motif-devel mpfr-devel ncurses-devel openldap-devel openssl-devel openssl-static openssh-clients openssh-server pciutils-devel pcre-devel perl-ExtUtils-Embed perl-libwww-perl protobuf-devel python-devel readline-devel redhat-lsb rpm-build swig tcl tcsh texinfo tk-devel unzip uuid-devel wget which xrootd xrootd-server xrootd-client xrootd-client-devel yum-plugin-priorities zip zlib-devel zlib-static zsh strace net-tools xz
)

description="CENTRAL container must have these packages installed: $(convert_array_to_string "${critical_packages[@]}")."
status="PASSED"
level="Warning"
for package_name in "${critical_packages[@]}"; do
    if ! sudo docker exec "$CONTAINER_NAME_WORKER" yum list installed "$package_name" >/dev/null 2>&1; then
        status="FAILED"
        message="$package_name is not installed."
        print_full_test "$id" "$name" $status "$description" $level "$message"
    fi
done

if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="All packages are installed."
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi

warning_packages=(
    alicexrdplugins mysql-devel python-pip xrootd-python
)

id=$((id + 1))
name="Worker Container Warning Package Check"
level="Warning"
description="CENTRAL container may have these packages installed: $(convert_array_to_string "${warning_packages[@]}")."

status="PASSED"
for package_name in "${warning_packages[@]}"; do
    if ! sudo docker exec "$CONTAINER_NAME_WORKER" yum list installed "$package_name" >/dev/null 2>&1; then
        status="FAILED"
        message="$package_name is not installed."
        print_full_test "$id" "$name" $status "$description" $level "$message"
    fi
done

if [ "$status" != "FAILED" ]; then
    status="PASSED"
    message="All packages are installed."
    print_full_test "$id" "$name" $status "$description" $level "$message"
fi
