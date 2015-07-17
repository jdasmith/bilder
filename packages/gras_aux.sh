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

setGrasTriggerVars() {
  GRAS_BLDRVERSION=${GRAS_BLDRVERSION:-"03-03-r1561"}
  GRAS_BUILDS=${GRAS_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  GRAS_DEPS=geant4
}
setGrasTriggerVars

######################################################################
#
# Find gras
#
######################################################################

# Find the directory containing the gras cmake files
findGras() {

# Look for Gras in the contrib directory
  findContribPackage Gras G4global sersh pycsh
  findPycshDir Gras

# Set envvars for other packages
  local GRAS_HOME="$CONTRIB_DIR/gras-sersh"
  printvar GRAS_HOME
  source $GRAS_HOME/bin/gras-env.sh
  addtopathvar PATH $CONTRIB_DIR/gras-$FORPYTHON_SHARED_BUILD/bin

}

