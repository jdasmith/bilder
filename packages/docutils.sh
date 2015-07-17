#!/bin/bash
#
# Build information for docutils
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in docutils_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/docutils_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setDocutilsNonTriggerVars() {
  DOCUTILS_UMASK=002
}
setDocutilsNonTriggerVars

######################################################################
#
# Launch docutils builds.
#
######################################################################

buildDocutils() {
# If cannot import roman, which comes with docutils, then reinstall
  if ! python -c "import roman" 2>/dev/null; then
    techo "Cannot import roman.  Will rebuild docutils."
    cmd="$BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR docutils,pycsh"
    techo "$cmd"
    $cmd
  fi
  if bilderUnpack docutils; then
# Must first remove any old installations
    cmd="rmall $CONTRIB_DIR/$PYTHON_LIBSUBDIR/python$PYTHON_MAJMIN/site-package/docutils*"
    techo "$cmd"
    $cmd
    techo "Running bilderDuBuild for docutils."
    bilderDuBuild docutils
  fi
}

######################################################################
#
# Test docutils
#
######################################################################

testDocutils() {
  techo "Not testing docutils."
}

######################################################################
#
# Install docutils
#
######################################################################

installDocutils() {
  if bilderDuInstall docutils "$DOCUTILS_ARGS" "$DOCUTILS_ENV"; then
    chmod a+r $PYTHON_SITEPKGSDIR/roman.py*
  fi
  # techo "WARNING: Quitting at end of docutils.sh."; exit
}

