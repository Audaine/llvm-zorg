#!/usr/bin/env bash
# This script uses BUILDBOT_REVISION to read bad and good patch for bisect.
# The format is: BUILDBOT_REVISION=good:bad

set -x
set -e
set -u

HERE="$(cd $(dirname $0) && pwd)"
. ${HERE}/buildbot_functions.sh

BUILDBOT_REVISION=origin/main buildbot_update

build_step "bisecting ${BUILDBOT_REVISION}"

# Try to get them out from the bisect string in BUILDBOT_REVISION first.
GOOD="${BUILDBOT_REVISION/:*/}"
BAD="${BUILDBOT_REVISION/*:/}"

# If not provided through BUILDBOT_REVISION, use some defaults.
if [[ "$BAD" == "" ]]; then
  BAD="origin/main"
fi
if [[ "$GOOD" == "" ]]; then
  GOOD="origin/main~100"
fi

cd "${LLVM}/.."

(
  export BUILDBOT_BISECT_MODE=1

  if git bisect start $BAD $GOOD; then
    git bisect run bash -c "cd $ROOT && $*"
  fi

  build_step "bisect result"
  git bisect log
) || true

git bisect reset
build_exception  # Bisect is neither FAIL nor PASS.
