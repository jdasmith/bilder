#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setPythonTriggerVars() {

# Patch number needed for repo and tarball
  PY_BLDRVERSION_PATCH_STD=9
  PY_BLDRVERSION_PATCH_EXP=10
  PY_BLDRVERSION_PATCH=$PY_BLDRVERSION_PATCH_STD
  $BUILD_EXPERIMENTAL && PY_BLDRVERSION_PATCH=$PY_BLDRVERSION_PATCH_EXP

# Determine how to get python
  if test -n "$VISUALSTUDIO_VERSION"; then
    if test "$VISUALSTUDIO_VERSION" -ge 12; then
      PYTHON_USE_REPO=true
    fi
  fi
  PYTHON_USE_REPO=${PYTHON_USE_REPO:-"false"}
  if $PYTHON_USE_REPO; then
    PYTHON_REPO_URL=https://github.com/Tech-XCorp/pythoncm.git
# Master for pull requests to upstream and to rebase against upstream
# Our best working branch.  After mastertxc is rebased, it is pulled in
# and commits squashed.
    PYTHON_REPO_BRANCH_STD=mastertxc
# Where we develop fixes.  We rebase against mastertxc.
    PYTHON_REPO_BRANCH_EXP=develop
    PYTHON_UPSTREAM_URL=https://github.com/davidsansome/python-cmake-buildsystem.git
    PYTHON_UPSTREAM_BRANCH_STD=master
    PYTHON_UPSTREAM_BRANCH_EXP=master
# Do not create installer in this case, as it is not yet working.
    BDIST_WININST_ARG=
  else
    PYTHON_BLDRVERSION_STD=2.7.$PY_BLDRVERSION_PATCH_STD
    PYTHON_BLDRVERSION_EXP=2.7.$PY_BLDRVERSION_PATCH_EXP
    BDIST_WININST_ARG=bdist_wininst
  fi
  computeVersion Python
# Export so available to setinstald.sh
  export PYTHON_BLDRVERSION
  case `uname` in
    Linux | CYGWIN*) PYTHON_BUILDS=${PYTHON_BUILDS:-"$FORPYTHON_SHARED_BUILD"};;
  esac
  PYTHON_DEPS=chrpath,sqlite,bzip2
  if $PYTHON_USE_REPO; then
    PYTHON_DEPS=$PYTHON_DEPS,cmake
  fi
  if [[ `uname` =~ CYGWIN ]]; then
    PYTHON_DEPS=$PYTHON_DEPS,zlib,bzip2
  fi
}

setPythonTriggerVars

######################################################################
#
# Find python
#
######################################################################

findPython() {
  source $BILDER_DIR/bilderpy.sh
  if test `uname` = Linux; then
    addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/python/lib
  fi
}

