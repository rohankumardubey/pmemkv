#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2019-2021, Intel Corporation

#
# install-memkind.sh - installs memkind from sources; depends on
#		the system it uses proper installation parameters
#

set -e

# memkind v1.13.0
MEMKIND_VERSION=a8c54e4920a4859e9e00073280363ca7281dde10

WORKDIR=$(pwd)

git clone https://github.com/memkind/memkind
cd ${WORKDIR}/memkind
git checkout ${MEMKIND_VERSION}

echo "set OS-specific configure options"
OS_SPECIFIC=""
case $(echo ${OS} | cut -d'-' -f1) in
	centos|opensuse)
		OS_SPECIFIC="--libdir=/usr/lib64"
		;;
esac

./autogen.sh
./configure --prefix=/usr ${OS_SPECIFIC}
make -j$(nproc)
make -j$(nproc) install

echo "cleanup:"
cd ${WORKDIR}
rm -r memkind
