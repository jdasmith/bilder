#!/bin/bash
#
# Version and build information for boost
#
# $Id$
#
# Preconfig:
# ./bootstrap.sh -show-libraries
# Configure: not present
# Build step
# ./b2 --build-dir=ser --stagedir=ser/stage link=static --without-python threading=multi variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi stage
# Install step
# ./b2 --prefix=/contrib/boost-1_50_0-ser --build-dir=ser --stagedir=ser/stage link=static --without-python threading=multi variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi install
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# version 1_50_0 does not build with Intel compiler on windows (Pletzer)
BOOST_BLDRVERSION_STD=1_53_0
BOOST_BLDRVERSION_EXP=1_53_0

######################################################################
#
# Other values
#
######################################################################

if test -z "$BOOST_DESIRED_BUILDS"; then
  BOOST_DESIRED_BUILDS=ser
# No need for shared library unless that is the library for Python
  if isCcPyc; then
    BOOST_DESIRED_BUILDS=$BOOST_DESIRED_BUILDS,sersh
  fi
fi
computeBuilds boost
addPycshBuild boost
# It does not hurt to add deps that do not get built
# (e.g., Python on Darwin and CYGWIN)
# Only certain builds depend on Python
BOOST_DEPS=Python,bzip2

######################################################################
#
# Launch boost builds.
#
######################################################################

buildBoost() {

# Look for needed packages
  case `uname` in
    Linux)
      if ! test -f /usr/include/bzlib.h; then
        techo "WARNING: May need to install bzip2-devel."
      fi
      ;;
  esac

# Process
  if bilderUnpack boost; then
    local BOOST_ALL_ADDL_ARGS="variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi"
    if [[`uname` =~ CYGWIN]] && $IS_64BIT; then
      BOOST_ALL_ADDL_ARGS="address-model=64 $BOOST_ALL_ADDL_ARGS"
    fi
# Determine the compilers.  This set needs expansion!
    case "$CXX" in
      *pgiCC)
        BOOST_ALL_ADDL_ARGS="toolset=pgi threading=single $BOOST_ALL_ADDL_ARGS --without-thread"
        ;;
      *)
        BOOST_ALL_ADDL_ARGS="threading=single $BOOST_ALL_ADDL_ARGS"
        ;;
    esac
# Only the shared and pycsh build boost python, as shared libs required.
    BOOST_SER_ADDL_ARGS="link=static $BOOST_ALL_ADDL_ARGS --without-python --build-dir=ser --stagedir=ser/stage"
    BOOST_SERSH_ADDL_ARGS="link=shared $BOOST_ALL_ADDL_ARGS --build-dir=sersh --stagedir=sersh/stage"
    BOOST_PYCSH_ADDL_ARGS="link=shared $BOOST_ALL_ADDL_ARGS --build-dir=pycsh --stagedir=pycsh/stage"

# Remove library interdependencies
    cd $BUILD_DIR/boost-$BOOST_BLDRVERSION
    cmd="sed -i.bak 's?// \(#define BOOST_ALL_NO_LIB\)?\1?' boost/config/user.hpp"
    techo "$cmd"
    eval "$cmd"

# Set variables for each build and build
    for bld in `echo $BOOST_BUILDS | tr ',' ' '`; do
      local addlargsvar=`genbashvar boost-$bld`_ADDL_ARGS
      local addlargsval=`deref $addlargsvar`
      local otherargsvar=`genbashvar boost-$bld`_OTHER_ARGS
      local otherargsval=`deref $otherargsvar`
      bilderBuild -s -m ./b2 boost ser "$addlargsval $otherargsval stage"
      local instdirvar=`genbashvar boost-$bld`_INSTALL_DIR
      eval $instdirvar=$CONTRIB_DIR
    done

  fi

}

######################################################################
#
# Test boost
#
######################################################################

testBoost() {
  techo "Not testing boost."
}

######################################################################
#
# Install boost
#
######################################################################

installBoost() {
  for bld in `echo $BOOST_BUILDS | tr ',' ' '`; do
    local boost_instdir=$CONTRIB_DIR/boost-$BOOST_BLDRVERSION-$bld
    local boost_mixed_instdir=
    case `uname` in
      CYGWIN*) boost_mixed_instdir=`cygpath -am $boost_instdir`;;
      *) boost_mixed_instdir=$boost_instdir;;
    esac
# For b2, installation directory must be added at install time,
# and it is relative to the C: root.
    local sfx=
    local instargs=
    case $bld in
      ser) instargs="$BOOST_SER_ADDL_ARGS $BOOST_SER_OTHER_ARGS";;
      sersh) sfx=-sersh; instargs="$BOOST_SERSH_ADDL_ARGS $BOOST_SERSH_OTHER_ARGS";;
      pycsh) sfx=-pycsh; instargs="$BOOST_PYCSH_ADDL_ARGS $BOOST_PYCSH_OTHER_ARGS";;
    esac
    if bilderInstall -S -m ./b2 boost $bld boost${sfx} "$instargs --prefix=$boost_mixed_instdir"; then
      setOpenPerms $boost_instdir
      findBoost
    fi
  done
}

