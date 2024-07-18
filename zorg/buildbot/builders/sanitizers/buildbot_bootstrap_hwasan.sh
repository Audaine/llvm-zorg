#!/usr/bin/env bash

set -x
set -e
set -u

HERE="$(cd $(dirname $0) && pwd)"
. ${HERE}/buildbot_functions.sh

CMAKE_COMMON_OPTIONS+=" -DLLVM_ENABLE_ASSERTIONS=ON"

clobber

buildbot_update

# Stage 1

build_stage1_clang

check_stage1_hwasan

# Stage 2 / HWAddressSanitizer

build_stage2_hwasan

check_stage2_hwasan

# Stage 3 / HWAddressSanitizer

build_stage3_hwasan

check_stage3_hwasan

cleanup
