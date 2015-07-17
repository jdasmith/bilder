#!/bin/bash
#
# Build information for moab
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
# Putting the version information into moab_aux.sh eliminates the
# rebuild when one changes that file.  Of course, if the actual version
# changes, or this file changes, there will be a rebuild.  But with
# this one can change the experimental version without causing a rebuild
# in a non-experimental Bilder run.  One can also change any auxiliary
# functions without sparking a build.
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/moab_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMoabNonTriggerVars() {
  MOAB_UMASK=002
}
setMoabNonTriggerVars

######################################################################
#
# Launch moab builds.
#
######################################################################

buildMoab() {

# Whether using cmake
  if [[ `uname` =~ CYGWIN ]]; then
    MOAB_USE_CMAKE=true
  fi
  MOAB_USE_CMAKE=${MOAB_USE_CMAKE:-"false"}
  local moabcmakearg=
  local enable_shared=
  if $MOAB_USE_CMAKE; then
    techo "Building MOAB with cmake."
    moabcmakearg=-c
  else
    techo "Building MOAB with autotools."
  fi

# Get moab from repo, determine whether to build
  updateRepo moab
  getVersion moab
  if ! bilderPreconfig $moabcmakearg moab; then
    return 1
  fi

#
# Basic configure and build args
#
# ser BUILD needed by ulixes
  local MOAB_SER_CONFIG_ARGS=
# FORPYTHON_STATIC_BUILD needed by composers
  local MOAB_PYCST_CONFIG_ARGS=
# FORPYTHON_SHARED_BUILD needed by dagmc
  local MOAB_4PYSH_CONFIG_ARGS=
# par BUILD needed by ulixes
  local MOAB_PAR_CONFIG_ARGS=
  if $MOAB_USE_CMAKE; then
    MOAB_SER_CONFIG_ARGS="-DBUILD_SHARED_LIBS:BOOL=FALSE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER"
    if [[ `uname` =~ CYGWIN ]]; then
      MOAB_SER_CONFIG_ARGS="$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TARBALL_NODEFLIB_FLAGS"
    fi
    MOAB_PYCST_CONFIG_ARGS="-DBUILD_SHARED_LIBS:BOOL=FALSE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC"
    MOAB_4PYSH_CONFIG_ARGS="-DBUILD_SHARED_LIBS:BOOL=TRUE -DCMAKE_INSTALL_NAME_DIR='${BLDR_INSTALL_DIR}/moab-${MOAB_BLDRVERSION}-$FORPYTHON_SHARED_BUILD/lib' $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC"
    MOAB_PAR_CONFIG_ARGS="-DBUILD_SHARED_LIBS:BOOL=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR"
  else
    MOAB_SER_CONFIG_ARGS="--enable-static --disable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER"
    MOAB_PYCST_CONFIG_ARGS="--enable-static --disable-shared $CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC"
    MOAB_4PYSH_CONFIG_ARGS="--disable-static --enable-shared $CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC"
    MOAB_PAR_CONFIG_ARGS="--with-mpi='$CONTRIB_DIR/mpi' --enable-static --disable-shared $CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR"
  fi

#
# Additional build args
#
# FORPYTHON_STATIC_BUILD needed by composers
  if $MOAB_USE_CMAKE; then
# OCE always brought in shared
# MOAB uses root dirs for dirs.
    MOAB_SER_CONFIG_ARGS="$MOAB_SER_CONFIG_ARGS -DENABLE_IMESH:BOOL=TRUE -DMOAB_USE_HDF:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_SER_DIR' -DMOAB_USE_NETCDF:BOOL=TRUE -DNetCDF_DIR='$NETCDF_SER_DIR'"
    MOAB_PYCST_CONFIG_ARGS="$MOAB_PYCST_CONFIG_ARGS -DMOAB_USE_HDF:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PYCST_DIR' $OCE_PYCSH_CMAKE_DIR_ARG"
    MOAB_4PYSH_CONFIG_ARGS="$MOAB_PYSH_CONFIG_ARGS -DMOAB_USE_HDF:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PYCSH_DIR' $OCE_PYCSH_CMAKE_DIR_ARG"
    MOAB_PAR_CONFIG_ARGS="$MOAB_PAR_CONFIG_ARGS -DENABLE_IMESH:BOOL=TRUE -DMOAB_USE_HDF:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PAR_DIR' -DMOAB_USE_NETCDF:BOOL=TRUE -DNetCDF_DIR='$NETCDF_PAR_DIR'"
  else
# Moab cannot use recent vtk
# Moab cannot use recent cgm
# checking for /volatile/cgm-master.r1081-sersh/cgm.make... no
# configure: error: /volatile/cgm-master.r1081-sersh : not a configured CGM
    MOAB_SER_CONFIG_ARGS="$MOAB_SER_CONFIG_ARGS --enable-dagmc --without-vtk --with-hdf5='$HDF5_SER_DIR' --with-netcdf='$NETCDF_SER_DIR'"
# Neither CTK nor DagMC, which used shared moab, needs netcdf
    MOAB_PYCST_CONFIG_ARGS="$MOAB_PYCST_CONFIG_ARGS --enable-dagmc --without-vtk --with-hdf5='$HDF5_PYCST_DIR'"
# Neither CTK nor DagMC, which used shared moab, needs netcdf
    MOAB_4PYSH_CONFIG_ARGS="$MOAB_PYSH_CONFIG_ARGS --enable-dagmc --without-vtk --with-hdf5='$HDF5_PYCSH_DIR'"
# Build parallel with netcdf to get exodus reader
    MOAB_PAR_CONFIG_ARGS="$MOAB_PAR_CONFIG_ARGS --enable-dagmc --without-vtk --with-hdf5='$HDF5_PAR_DIR' --with-netcdf='$NETCDF_PAR_DIR'"
    case `uname` in
      Linux)
        local nclibsubdir=lib
        if test -d "$NETCDF_PYCSH_DIR/lib64"; then
          nclibsubdir=lib64
        fi
        MOAB_PYCSH_CONFIG_ARGS="$MOAB_PYCSH_CONFIG_ARGS LDFLAGS=-Wl,-rpath,'$HDF5_PYCSH_DIR/lib':'$NETCDF_PYCSH_DIR/$nclibsubdir'"
        ;;
    esac
# Parallel moab needs partitioning
    MOAB_PAR_CONFIG_ARGS="$MOAB_PAR_CONFIG_ARGS --with-zoltan='$TRILINOS_INSTALL_DIRS/trilinos-parcomm' --enable-mbzoltan"
  fi

#
# Moab configure and build environment
#
  local MOAB_ENV=

# When not all dependencies right on Windows, need nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$MOAB_MAKEJ_ARGS"
  fi

# Configure and build serial
  if bilderConfig $makerargs $moabcmakearg moab ser "$MOAB_SER_CONFIG_ARGS $MOAB_SER_OTHER_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab ser "$makejargs" "$MOAB_ENV"
  fi

# Configure and build python serial.  This may not be needed.
# Cannot use FORPYTHON_STATIC_BUILD on unixish where it can resolve to ser,
  if bilderConfig $makerargs $moabcmakearg moab pycst "$MOAB_PYCST_CONFIG_ARGS $MOAB_PYCST_OTHER_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab pycst "$makejargs" "$MOAB_ENV"
  fi

# Python shared build for composers.  Build with cmake.
  local otherargsvar=`genbashvar MOAB_${FORPYTHON_SHARED_BUILD}`_OTHER_ARGS
  local otherargs=`deref ${otherargsvar}`
  if bilderConfig $makerargs -c moab $FORPYTHON_SHARED_BUILD "-DBUILD_SHARED_LIBS:BOOL=true $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DMOAB_USE_HDF:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PYCSH_DIR' $OCE_PYCSH_CMAKE_DIR_ARG $otherargs" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab $FORPYTHON_SHARED_BUILD "$makejargs" "$MOAB_ENV"
  fi

# Configure and build parallel
  if bilderConfig $makerargs $moabcmakearg moab par "$MOAB_PAR_CONFIG_ARGS $MOAB_PAR_OTHER_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab par "$makejargs" "$MOAB_ENV"
  fi

}

######################################################################
#
# Test moab
#
######################################################################

testMoab() {
  techo "Not testing moab."
}

######################################################################
#
# Install moab
#
######################################################################

installMoab() {
  bilderInstallAll moab
# sersh build of moab needs hdf5 library installed, but moab does
# not install it.
# JRC: Why?  Applications need to collect all libs.  Libraries need not.
# Test applications can have a library path modification script.
  # if ! [[ `uname` =~ CYGWIN ]]; then
    # cp $HDF5_PYCSH_DIR/lib/libhdf5.* $BLDR_INSTALL_DIR/moab-sersh/lib
  # fi
}

