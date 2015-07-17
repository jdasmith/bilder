#!/bin/bash
#
# Build information for freetype
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in freetype_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/freetype_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setFreetypeNonTriggerVars() {
  FREETYPE_UMASK=002
}
setFreetypeNonTriggerVars

######################################################################
#
# Launch freetype builds.
#
######################################################################

buildFreetype() {

  if $FREETYPE_USE_REPO; then
    updateRepo freetype
    getVersion freetype
# Always install in contrib dir for consistency
    bilderPreconfig -I $CONTRIB_DIR freetype
  else
    bilderUnpack freetype
    res=$?
  fi
  if test $res != 0; then
    return
  fi

# For cygwin, get zlib version
  local FREETYPE_ADDL_ARGS=
  local FREETYPE_MAKE_ARGS=
  case `uname` in
    CYGWIN*)
      if test -z "$ZLIB_BLDRVERSION"; then
        source $BILDER_DIR/packages/zlib.sh
      fi
      if test -z "$LIBPNG_BLDRVERSION"; then
        source $BILDER_DIR/packages/libpng.sh
      fi
      FREETYPE_SERSH_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sersh/include -DZLIB_LIBRARY:FILEPATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-sersh/lib/zlib.lib"
      FREETYPE_PYCSH_ADDL_ARGS="-DZLIB_INCLUDE_DIR:PATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-pycsh/include -DZLIB_LIBRARY:FILEPATH=$MIXED_CONTRIB_DIR/zlib-${ZLIB_BLDRVERSION}-pycsh/lib/zlib.lib"
      FREETYPE_MAKE_ARGS="-m nmake"
      ;;
  esac

# Static builds for windows
  eval FREETYPE_PYCST_INSTALL_DIR=$CONTRIB_DIR
  if bilderConfig -c freetype pycst "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $FREETYPE_ADDL_ARGS $FREETYPE_PYCST_OTHER_ARGS"; then
    bilderBuild $FREETYPE_MAKE_ARGS freetype pycst
  fi
  eval FREETYPE_SERMD_INSTALL_DIR=$CONTRIB_DIR
  if bilderConfig -c freetype sermd "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $FREETYPE_ADDL_ARGS $FREETYPE_SERMD_OTHER_ARGS"; then
    bilderBuild $FREETYPE_MAKE_ARGS freetype sermd
  fi

# Shared builds for unix
  eval FREETYPE_PYCSH_INSTALL_DIR=$CONTRIB_DIR
  if bilderConfig -c freetype pycsh "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC -DBUILD_SHARED_LIBS:BOOL=ON $FREETYPE_ADDL_ARGS $FREETYPE_PYCSH_OTHER_ARGS"; then
    bilderBuild $FREETYPE_MAKE_ARGS freetype pycsh
  fi
  eval FREETYPE_SERSH_INSTALL_DIR=$CONTRIB_DIR
  if bilderConfig -c freetype sersh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DBUILD_SHARED_LIBS:BOOL=ON $FREETYPE_ADDL_ARGS $FREETYPE_SERSH_OTHER_ARGS"; then
    bilderBuild $FREETYPE_MAKE_ARGS freetype sersh
  fi

}

######################################################################
#
# Test freetype
#
######################################################################

testFreetype() {
  techo "Not testing freetype."
}

######################################################################
#
# Install freetype
#
######################################################################

installFreetype() {

  for bld in `echo $FREETYPE_BUILDS | sed 's/,/ /g'`; do
    if bilderInstall freetype $bld; then
      instdir=$CONTRIB_DIR/freetype-${FREETYPE_BLDRVERSION}-$bld
      case `uname` in
        CYGWIN*) # Correct library names on Windows.  DLLs?
          if test -f $instdir/lib/libfreetype.lib; then
            mv $instdir/lib/libfreetype.lib $instdir/lib/freetype.lib
          elif test -f $instdir/lib/libfreetype.dll.a; then
            mv $instdir/lib/libfreetype.dll.a $instdir/lib/freetype.lib
          fi
          if test -f $instdir/bin/libfreetype.dll; then
            mv $instdir/bin/libfreetype.dll $instdir/bin/freetype.dll
          fi
          ;;
        Darwin | Linux)
# Matplotlib overrides any parameters for location of freetype if
# freetype-config is in one's path.  So old system gets preferred to contrib.
# This puts last installed freetype-config first in path.
          cmd="(cd $CONTRIB_DIR/bin; ln -sf $CONTRIB_DIR/freetype-$bld/bin/freetype-config .)"
          techo "$cmd"
          eval "$cmd"
          ;;
      esac
    fi
  done

}

