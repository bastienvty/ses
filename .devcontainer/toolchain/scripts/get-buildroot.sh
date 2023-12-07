#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

git clone git://git.buildroot.net/buildroot /buildroot

cd /buildroot
git checkout -b ses 2022.08.3

rsync -a /workspace/config/Makefile /buildroot/Makefile
rsync -a /workspace/config/board/ /buildroot/board/
rsync -a /workspace/config/configs/ /buildroot/configs/
rsync -a /workspace/config/package/ /buildroot/package/

make ses_defconfig
