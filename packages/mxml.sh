#!/bin/bash
#
# Version and build information for mini xml
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

MXML_BLDRVERSION=${MXML_BLDRVERSION:-"2.6"}

######################################################################
#
# Other values
#
######################################################################

MXML_BUILDS=${MXML_BUILDS:-"ser"}
MXML_DEPS=

######################################################################
#
# Launch mxml builds.
#
######################################################################

# Convention for lower case package is to capitalize only first letter
buildMxml() {
  if bilderUnpack -i mxml; then
    if bilderConfig -i mxml ser; then
      bilderBuild mxml ser
    fi
  fi
}

######################################################################
#
# Test mxml
#
######################################################################

testMxml() {
  techo "Not testing mxml."
}

######################################################################
#
# Install mxml
#
######################################################################

installMxml() {
  bilderInstall mxml ser
}
