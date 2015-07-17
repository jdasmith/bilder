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

setMpichTriggerVars() {
  MPICH_BLDRVERSION_STD=3.1.4
  MPICH_BLDRVERSION_EXP=3.1.4
  if $BUILD_MPIS && test -z "$MPICH_BUILDS" && [[ $USE_MPI =~ mpich ]]; then
    MPICH_BUILDS=static,shared
  fi
  MPICH_DEPS=libtool,automake
}
setMpichTriggerVars

######################################################################
#
# Find mpich
#
######################################################################

findMpich() {
# Not adding for now to not conflict with openmpi
  if [[ "$USE_MPI" =~ mpich ]] && test -d $CONTRIB_DIR/$USE_MPI/bin; then
    addtopathvar PATH $CONTRIB_DIR/$USE_MPI/bin
    local mpichdir=`(cd $CONTRIB_DIR/$USE_MPI/bin; pwd -P)`
    for c in MPICC MPICXX MPIFC MPIF77; do
      case $c in
        MPIFC) MPIFC=$mpichdir/mpif90;;
        *) exe=`echo $c | tr '[:upper:]' '[:lower:]'`; eval $c=$mpichdir/$exe;;
      esac
      exe=`deref $c`
      if ! test -x $exe; then
        techo "WARNING: $exe not found."
      fi
      printvar $c
    done
    MPICH2_LIBDIR=`$MPICC -show | sed -e 's/^.*-L//' -e 's/ .*$//'`
    PAR_EXTRA_LDFLAGS="$PAR_EXTRA_LDFLAGS ${RPATH_FLAG}$MPICH2_LIBDIR"
    PAR_EXTRA_LT_LDFLAGS="$PAR_EXTRA_LDFLAGS ${LT_RPATH_FLAG}$MPICH2_LIBDIR"
    printvar PAR_EXTRA_LDFLAGS
    printvar PAR_EXTRA_LT_LDFLAGS
    getCombinedCompVars
  fi
}

