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

setPyparsingTriggerVars() {
  PYPARSING_BLDRVERSION_STD=${PYPARSING_BLDRVERSION_STD:-"1.5.7"}
  PYPARSING_BLDRVERSION_EXP=${PYPARSING_BLDRVERSION_EXP:-"1.5.7"}
  PYPARSING_BUILDS=${PYPARSING_BUILDS:-"pycsh"}
  PYPARSING_DEPS=Python
}
setPyparsingTriggerVars

######################################################################
#
# Find pyparsing
#
######################################################################

findPyparsing() {
  :
}

