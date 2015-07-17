#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Find libpng.  This is used below, so must be first.
#
######################################################################

findLibpng() {

# Look for libpng-sersh in contrib directory on windows, but
# on mac and linux we use pkg-config
  case `uname` in
    CYGWIN*)
      findPackage Libpng png "$CONTRIB_DIR" sersh
      if test -n "$LIBPNG_SERSH_DIR"; then
        LIBPNG_SERSH_DIR=`cygpath -am $LIBPNG_SERSH_DIR`
      else
        techo "WARNING: libpng not found."
      fi
      ;;
    *)
      local libpngconfig=`which libpng-config`
      if test -z "$libpngconfig"; then
        techo "WARNING: [$FUNCNAME] libpng not found by bilder. Please install on system.  PATH = $PATH."
      else
        local libpngdir=`$libpngconfig --prefix`
        techo "Using libpng from $libpngdir."
        LIBPNG_SERSH_DIR=$libpngdir
      fi
      ;;
  esac

# If found, we set some arguments that can be used in other package
# configures to make sure libpng is consistent in all pkgs that use the args.
  if test -n "$LIBPNG_SERSH_DIR"; then
    techo "Setting configure args to use libpng in $LIBPNG_SERSH_DIR."
    CMAKE_LIBPNG_SERSH_DIR_ARG="-DPng_ROOT_DIR:PATH='$LIBPNG_SERSH_DIR'"
    CONFIG_LIBPNG_SERSH_DIR_ARG="--with-libpng-dir='$LIBPNG_SERSH_DIR'"
    printvar CMAKE_LIBPNG_SERSH_DIR_ARG
    printvar CONFIG_LIBPNG_SERSH_DIR_ARG
  fi

# Look for libpng in contrib
  if test -z "$LIBPNG_PYCSH_DIR"; then
    findPackage Libpng png "$CONTRIB_DIR" pycsh sersh
    findPycshDir Libpng
  fi

  if test -n "$LIBPNG_PYCSH_DIR" -a "$LIBPNG_PYCSH_DIR" != /usr; then
    addtopathvar PATH $LIBPNG_PYCSH_DIR/bin
    if [[ `uname` =~ CYGWIN ]]; then
      LIBPNG_PYCSH_DIR=`cygpath -am $LIBPNG_PYCSH_DIR`
    fi
    CMAKE_LIBPNG_PYCSH_DIR_ARG="-DPng_ROOT_DIR:PATH='$LIBPNG_PYCSH_DIR'"
    CONFIG_LIBPNG_PYCSH_DIR_ARG="--with-libpng-dir='$LIBPNG_PYCSH_DIR'"
  fi
  printvar CMAKE_LIBPNG_PYCSH_DIR_ARG
  printvar CONFIG_LIBPNG_PYCSH_DIR_ARG

}

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setLibpngTriggerVars() {
  LIBPNG_BLDRVERSION=${LIBPNG_BLDRVERSION:-"1.5.7"}
  case `uname` in
    CYGWIN*)
# Only attempt to build on Windows. Must be installed elsewhere.
      LIBPNG_DESIRED_BUILDS=${LIBPNG_DESIRED_BUILDS:-"sersh"}
      ;;
  esac
  computeBuilds libpng
  if [[ `uname` =~ CYGWIN ]]; then
    addPycshBuild libpng
  fi
  LIBPNG_DEPS=zlib,cmake
}
setLibpngTriggerVars

