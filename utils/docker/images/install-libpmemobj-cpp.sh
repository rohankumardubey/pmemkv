#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2019-2022, Intel Corporation

#
# install-libpmemobj-cpp.sh [package_type]
#		- installs PMDK C++ bindings (libpmemobj-cpp)
#

set -e

if [ "${SKIP_LIBPMEMOBJCPP_BUILD}" ]; then
	echo "Variable 'SKIP_LIBPMEMOBJCPP_BUILD' is set; skipping building libpmemobj-cpp"
	exit
fi

PREFIX="/usr"
PACKAGE_TYPE=${1^^} #To uppercase
echo "PACKAGE_TYPE: ${PACKAGE_TYPE}"

# master: Merge pull request #1242 from lukaszstolarczuk/docs-update, 28.01.2022
# It contains fix for gcc-12 in radix_tree
LIBPMEMOBJ_CPP_VERSION="7e59f08f65d6d67cd893f4c6b7c1141a04f28ac3"
echo "LIBPMEMOBJ_CPP_VERSION: ${LIBPMEMOBJ_CPP_VERSION}"

build_dir=$(mktemp -d -t libpmemobj-cpp-XXX)

git clone https://github.com/pmem/libpmemobj-cpp --shallow-since=2020-06-01 ${build_dir}

pushd ${build_dir}
git checkout ${LIBPMEMOBJ_CPP_VERSION}

mkdir build
cd build

# turn off all redundant components
cmake .. -DCPACK_GENERATOR="${PACKAGE_TYPE}" -DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_DOC=OFF -DBUILD_BENCHMARKS=OFF \
	-DTESTS_USE_VALGRIND=OFF

if [ "${PACKAGE_TYPE}" = "" ]; then
	make -j$(nproc) install
else
	make -j$(nproc) package
	if [ "${PACKAGE_TYPE}" = "DEB" ]; then
		sudo dpkg -i libpmemobj++*.deb
	elif [ "${PACKAGE_TYPE}" = "RPM" ]; then
		sudo rpm -iv libpmemobj++*.rpm
	fi
fi

popd
rm -r ${build_dir} 
