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

setValgrindTriggerVars() {
  case `uname` in
    Darwin)
      if ! test -d /usr/include/mach; then
        techo "WARNING: [$FUNCNAME] Install command line tools per "'http://sourceforge.net/p/bilder/wiki/Preparing\%20a\%20Darwin\%20machine\%20for\%20Bilder'"/."
      fi
      VALGRIND_BLDRVERSION_STD=3.10.1
      VALGRIND_BLDRVERSION_EXP=3.10.1
      case `uname -r` in
# Mavericks or later OSX 10.9
        # 1[3-9]*) VALGRIND_BUILDS=${VALGRIND_BUILDS:-"ser"};;
        1[3-9]*) VALGRIND_BUILDS=${VALGRIND_BUILDS:-"NONE"};;
      esac
      ;;
    Linux)
      VALGRIND_BLDRVERSION_STD=3.10.1
      VALGRIND_BLDRVERSION_EXP=3.10.1
      VALGRIND_BUILDS=${VALGRIND_BUILDS:-"ser"}
      ;;
  esac
  VALGRIND_DEPS=
}
setValgrindTriggerVars

######################################################################
#
# Find valgrind
#
######################################################################

findValgrind() {
  addtopathvar PATH $CONTRIB_DIR/valgrind/bin
}

