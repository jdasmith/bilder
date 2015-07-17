#!/bin/bash
#
# Build information for pyne
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in pyne_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pyne_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPyneNonTriggerVars() {
  :
}
setPyneNonTriggerVars

######################################################################
#
# Launch pyne builds.
#
######################################################################

buildPyne() {

# Get pyne from repo, determine whether to build
  updateRepo pyne
  getVersion pyne
  PYNE_INSTALL_DIRS=$CONTRIB_DIR
  if ! bilderPreconfig pyne; then
    return 1
  fi

# This is a new case for Bilder: a repo for a python module.

# Build/install
  PYNE_ARGS="--hdf5=$HDF5_PYCSH_DIR --moab=$MOAB_PYCSH_DIR"
  PYNE_ENV="$DISTUTILS_NOLV_ENV"
  bilderDuBuild pyne "$PYNE_ARGS" "$PYNE_ENV"

}

######################################################################
#
# Test pyne
#
######################################################################

testPyne() {
  techo "Not testing pyne."
}

######################################################################
#
# Install pyne
#
######################################################################

installPyne() {

# Install library if not present, make link if needed
  if bilderDuInstall $instopts pyne "$PYNE_ARGS" "$PYNE_ENV"; then
    (cd $PROJECT_DIR/pyne; ./scripts/nuc_data_make)
  fi

}

