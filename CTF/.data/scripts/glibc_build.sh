#!/bin/sh
#
# Script to download and build the supplied glibc version with debug symbols, useful
# to fetch specific GLIBC versions when playing PWN challenges.

set -e

usage() {
    echo "usage: $(basename $0) [-32] [<prefix>] <version>"
    echo ""
    echo "where:"
    echo "  -32        compile the 32-bit version of GLIBC"
    echo "  prefix     directory to install the GLIBC (<prefix>/<version>)"
    echo "  version    desired GLIBC version to install"
    echo ""
}

# parse the arguments
case "$#" in
    1)
        version="$1"
        ;;
    2)
        [ "$1" = "-32" ] && hostflag="--host=i686-linux-gnu" || prefix="$1"
        version="$2"
        ;;
    3)
        if [ "$1" != "-32" ]; then
            usage
            exit 1
        fi

        hostflag="--host=i686-linux-gnu"
        prefix="$2"
        version="$3"
        ;;
    *)
        usage; exit 1
        ;;
esac

# download the source code (clone git repo)
git clone git://sourceware.org/git/glibc.git && cd glibc

# checkout the according release branch
git checkout "release/${version}/master"

# compile and install
mkdir build && cd $_
../configure --prefix="${prefix:-/opt/glibc/}/$([ -z "$hostflag" ] && echo "64" || echo "32")" --disable-werror \
    --enable-debug=yes $hostflag

make && make install

# clean up
cd ../../ && rm -rf glibc
