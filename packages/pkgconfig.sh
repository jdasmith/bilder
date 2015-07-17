#!/bin/bash
#
# Build information for pkgconfig
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in pkgconfig_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pkgconfig_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPkgconfigNonTriggerVars() {
  PKGCONFIG_UMASK=002
}
setPkgconfigNonTriggerVars

######################################################################
#
# Launch pkgconfig builds.
#
######################################################################

buildPkgconfig() {
# Build
  if ! bilderUnpack pkgconfig; then
    return
  fi
  if bilderConfig -p autotools-lt-$LIBTOOL_BLDRVERSION pkgconfig ser "--with-internal-glib"; then
    bilderBuild -m make pkgconfig ser
  fi
}

######################################################################
#
# Test pkgconfig
#
######################################################################

testPkgconfig() {
  techo "Not testing pkgconfig."
}

######################################################################
#
# Install pkgconfig
#
######################################################################

installPkgconfig() {
# pkgconfig installation dies if this is present, as it will not replace it.
  (cd $CONTRIB_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin; rm -f *-pkg-config)
  bilderInstall -m make pkgconfig ser autotools
}

