# Configure script for Digital Bazaar librdfa library
# Usage: Run ./configure once 
# 
# This file is part of librdfa.
#
# librdfa is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# librdfa is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with librdfa. If not, see <http://www.gnu.org/licenses/>.
# 
# Author: Manu Sporny

AC_INIT(librdfa, 0.18, support@digitalbazaar.com)
AC_CONFIG_AUX_DIR(setup)

# Setup standard build environment variables
RDFADIR=`pwd`
RELEASE=`date +%Y%m%d`

# Check for particular build options
# Check for particular build options
AC_ARG_ENABLE([linux],
   AS_HELP_STRING([--enable-linux], [compile for linux [[yes]]]),
   [
      case "${enableval}" in
         yes) BUILD_FOR_LINUX=yes ;;
         no) BUILD_FOR_LINUX=no ;;
         *) AC_MSG_ERROR(bad value ${enableval} for --enable-linux) ;;
      esac
   ], [BUILD_FOR_LINUX=yes])  dnl Default value

AC_ARG_ENABLE([windows],
   AS_HELP_STRING([--enable-windows], [compile for windows [[no]]]),
   [
      case "${enableval}" in
         yes) BUILD_FOR_WINDOWS=yes ;;
         no) BUILD_FOR_WINDOWS=no ;;
         *) AC_MSG_ERROR(bad value ${enableval} for --enable-windows) ;;
      esac
   ], [BUILD_FOR_WINDOWS=no])  dnl Default value

AC_ARG_ENABLE([macos],
   AS_HELP_STRING([--enable-macos], [compile for MacOS [[no]]]),
   [
      case "${enableval}" in
         yes) BUILD_FOR_MACOS=yes ;;
         no) BUILD_FOR_MACOS=no ;;
         *) AC_MSG_ERROR(bad value ${enableval} for --enable-macos) ;;
      esac
   ], [BUILD_FOR_MACOS=no])  dnl Default value

AC_ARG_ENABLE([python],
               AC_HELP_STRING([--enable-python],
                              [compile extensions for Python (default is NO)]),
              [ac_enable_python_build=yes], [ac_enable_python_build=no])

AC_ARG_ENABLE([docs],
               AC_HELP_STRING([--enable-docs],
                              [build documentation (default is NO)]),
              [ac_enable_docs_build=yes], [ac_enable_docs_build=no])

echo -e "\n--------- Configuring librdfa Build Environment -----------"

# Check the system type
AC_CANONICAL_BUILD()
AC_CANONICAL_HOST()
AC_CANONICAL_SYSTEM()
OS="$build_os"

# Checking for standard build tools
#AC_LANG(C++)
AC_PROG_INSTALL()

# Conditional setup for Windows build
if test "$BUILD_FOR_WINDOWS" = "yes" ; then
   BUILD_FOR_LINUX="no"
   BUILD_FOR_MACOS="no"
   AC_CHECK_PROGS(CC, i586-mingw32msvc-gcc gcc, not found)
   AC_CHECK_PROGS(AR, i586-mingw32msvc-ar ar, not found)
   AC_CHECK_PROGS(AS, i586-mingw32msvc-as as, not found)
   EXPAT_INCLUDE_DIRECTORY="$RDFADIR/3rdparty/expat/include"
   EXPAT_LIB_DIRECTORY="$RDFADIR/3rdparty/expat"
   OS="mingw32"
fi

# Conditional setup for MacOS build
if test "$BUILD_FOR_MACOS" = "yes" ; then
   BUILD_FOR_LINUX="no"
   BUILD_FOR_WINDOWS="no"
   AC_PROG_CC()
   AC_CHECK_PROG(AR, ar, ar, not found)
   AC_CHECK_PROG(AS, as, as, not found)
   EXPAT_INCLUDE_DIRECTORY="/opt/local/include"
   EXPAT_LIB_DIRECTORY="/opt/local/lib"
   OS="macos"
fi

# Conditional setup for Linux build
if test "$BUILD_FOR_LINUX" = "yes" ; then
   AC_PROG_CC()
   AC_CHECK_PROG(AR, ar, ar, not found)
   AC_CHECK_PROG(AS, as, as, not found)
   EXPAT_INCLUDE_DIRECTORY="/usr/include"
   EXPAT_LIB_DIRECTORY="/usr/lib"
fi

CC="$CC"

# Check to see if we need to build the Python modules
if test "$ac_enable_python_build" = "yes" ; then
   # guess default python version
   PY_DEFAULT=["`python -c \"import platform; print '.'.join(platform.python_version_tuple()[:2])\"`"]
   if test "x$PY_DEFAULT" = "x"; then
      AC_MSG_ERROR([No default Python found])
   fi

   # check all versions
   PY_POTENTIAL_VERSIONS="2.4 2.5 2.6 2.7"
   PY_VERSIONS=""
   for v in $PY_POTENTIAL_VERSIONS; do
      AC_CHECK_FILE(/usr/include/python$v/Python.h, [PY_VERSIONS="$PY_VERSIONS $v"])
   done
   # error if no verions found
   if test "x$PY_VERSIONS" = "x"; then
      AC_MSG_ERROR([No Python headers found (checked $PY_POTENTIAL_VERSIONS)])
   fi

   AC_SUBST(PY_DEFAULT)
   AC_SUBST(PY_VERSIONS)

   BUILD_FOR_PYTHON="yes"
fi

# Check doc build tools
if test "$ac_enable_docs_build" = "yes"; then
   AC_CHECK_PROG(HAVE_DOXYGEN, doxygen, yes, no)
   AC_SUBST(HAVE_DOXYGEN)
fi

# Perform compilation environment tests
#AC_CHECK_HEADERS(iostream)

# Make sure the proper libraries exist
if test "$BUILD_FOR_WINDOWS" = "no" ; then
   AC_CHECK_LIB(expat, main, [], AC_MSG_ERROR(could not find expat library), -L$EXPAT_LIB_DIRECTORY)
fi

# Make all the proper substitutions
AC_SUBST(RDFADIR)

# Make all the proper substitutions
VERSION="$PACKAGE_VERSION"
AC_SUBST(VERSION)
AC_SUBST(RELEASE)

AC_SUBST(BUILD_FOR_LINUX)
AC_SUBST(BUILD_FOR_WINDOWS)
AC_SUBST(BUILD_FOR_PYTHON)

AC_SUBST(CC)
AC_SUBST(AR)
AC_SUBST(AS)

AC_SUBST(OS)

AC_SUBST(EXPAT_LIB_DIRECTORY)
AC_SUBST(EXPAT_INCLUDE_DIRECTORY)

# Generating files
AC_CONFIG_FILES([
   .gitignore
   Makefile
   setup/Makefile.base
   c/Makefile
   python/Makefile
   docs/Makefile
   tests/Makefile
   installers/debian/changelog
   librdfa.pc
   librdfa-uninstalled.pc
])

# add newlines to internal output file list
CONFIGURE_GENERATED_FILES="`echo $ac_config_files | tr ' ' '\n'`"
AC_SUBST(CONFIGURE_GENERATED_FILES)

AC_OUTPUT

# Dump the build configuration for the developer
echo -e "\n--------- librdfa Build Environment -----------"
echo "Product        : $PACKAGE_STRING-$RELEASE"
echo "Build host     : $build_cpu-$build_vendor-$build_os"
echo "Build target   : $OS"
echo "C compiler     : $CC"
echo "Archiver       : $AR"
echo "Assembler      : $AS"

if test "$BUILD_FOR_PYTHON" = "yes"; then
   echo "Python modules : enabled (versions: $PY_VERSIONS, default: $PY_DEFAULT)"
else
   echo "Python modules : disabled (use --enable-python to enable)"
fi
if test "$ac_enable_docs_build" = "yes"; then
   echo "Documentation  : enabled"
else
   echo "Documentation  : disabled (use --enable-docs to enable)"
fi
