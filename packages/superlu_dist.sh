#!/bin/bash
#
# Build information for superlu_dist
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in superlu_dist_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/superlu_dist_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSuperlu_DistNonTriggerVars() {
  SUPERLU_DIST_UMASK=002
}
setSuperlu_DistNonTriggerVars

######################################################################
#
# Launch superlu_dist builds.
#
######################################################################

buildSuperlu_Dist() {

  if test -d $PROJECT_DIR/superlu_dist; then
    getVersion superlu_dist
    bilderPreconfig -c superlu_dist
    res=$?
  else
    bilderUnpack superlu_dist
    res=$?
  fi

  if test $res != 0; then
    return
  fi

  if bilderConfig -c superlu_dist par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST_PAR_OTHER_ARGS"; then
    bilderBuild superlu_dist par
  fi
  if bilderConfig superlu_dist parsh "-DENABLE_PARALLEL:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_LINLIB_SERSH_ARGS $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST_PARSH_OTHER_ARGS"; then
    bilderBuild superlu_dist parsh
  fi
  if bilderConfig -c superlu_dist parcomm "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_PARMETIS:BOOL=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST_PARCOMM_OTHER_ARGS"; then
    bilderBuild superlu_dist parcomm
  fi
  if bilderConfig superlu_dist parcommsh "-DENABLE_PARALLEL:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=ON -DENABLE_PARMETIS:BOOL=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST_PARCOMMSH_OTHER_ARGS"; then
    bilderBuild superlu_dist parcommsh
  fi
  if bilderConfig -c superlu_dist ben "-DENABLE_PARALLEL:BOOL=TRUE -DDISABLE_CPUCHECK:BOOL=TRUE $CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $CMAKE_HDF5_BEN_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST_BEN_OTHER_ARGS"; then
    bilderBuild superlu_dist ben
  fi

}

######################################################################
#
# Test superlu_dist
#
######################################################################

testSuperlu_Dist() {
  techo "Not testing superlu_dist."
}

######################################################################
#
# Install superlu_dist
#
######################################################################

installSuperlu_Dist() {
  for bld in parcommsh parcomm parsh par ben; do
    if bilderInstall -r superlu_dist $bld; then
      bldpre=`echo $bld | sed 's/sh$//'`
      local instdir=$CONTRIB_DIR/superlu_dist-$SUPERLU_DIST_BLDRVERSION-$bldpre
      setOpenPerms $instdir
    fi
  done
}

