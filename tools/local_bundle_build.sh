#!/bin/sh
# cd to parent dir of this script
pushd $(cd -P -- "$(dirname -- "$0")" && pwd -P)/..
# upon any kind of termination, return to our original directory
trap "popd" EXIT SIGHUP SIGINT SIGTERM

bundle
gem build bill_forward.gemspec