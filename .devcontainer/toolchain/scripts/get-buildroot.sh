#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

git clone git://git.buildroot.net/buildroot /buildroot

cd /buildroot
git checkout -b ses 2022.08.3

rsync -a /workspace/config/ /buildroot/

make ses_defconfig
