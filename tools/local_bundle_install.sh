#!/bin/sh
# cd to parent dir of this script
MYDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
pushd $MYDIR/..
# upon any kind of termination, return to our original directory
trap "popd" EXIT SIGHUP SIGINT SIGTERM

sh $MYDIR/local_bundle_build.sh
gem install bill_forward