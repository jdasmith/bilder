#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
##################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setPsplineTriggerVars() {
  PSPLINE_BLDRVERSION=${PSPLINE_BLDRVERSION:-"1.1.1-r67+1118"}
  PSPLINE_BUILDS=${PSPLINE_BUILDS:-"ser,par"}
  addBenBuild pspline
  PSPLINE_DEPS=cmake,fciowrappers
}
setPsplineTriggerVars

######################################################################
#
# Find pspline
#
######################################################################

findPspline() {
  :
}

