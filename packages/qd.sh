#!/bin/bash
#
# Version and build information for qd
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################
QD_BLDRVERSION=${QD_BLDRVERSION:-"2.3.13"}


######################################################################
#
# Other values
#
######################################################################

if test -z "$QD_BUILDS"; then
  QD_BUILDS=ser
fi

QD_DEPS=autotools
QD_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch qd builds.
#
######################################################################

buildQd() {
  if bilderUnpack qd; then
    if bilderConfig qd ser; then
      bilderBuild qd ser
    fi
  fi
}

######################################################################
#
# Test qd
#
######################################################################

testQd() {
  techo "Not testing qd."
}

######################################################################
#
# Install qd
#
######################################################################

installQd() {
  bilderInstall qd ser
}