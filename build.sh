#!/bin/bash
#----------------------------------------
#
# Purpose: gnsstk-apps build and install script
#
#     Automate the use of CMake, Doxygen, etc.  to build and install
#     the gnsstk-apps Applications and documentation.
#
# Help:
#    $ build.sh -h
#
#----------------------------------------

source $(dirname "$BASH_SOURCE")/build_setup.sh

# This is a bit of a hack.
# Downstream apps packages expect to find gnsstk-apps in gnsstk/bin
user_install_prefix+="/gnsstk"
system_install_prefix+="/gnsstk"

usage()
{
    cat << EOF
purpose: This script automates and documents how to build, test, and
  install gnsstk-apps.

usage:     $(basename $0) [opts] [-- cmake options...]

examples:
     Just build software
   $ build.sh
     Build and install to $system_install_prefix
   $ sudo build.sh -s -b /tmp/qwe
      Build, test and install to $gnsstk_apps
   $ build.sh -tue
     build for running debugger
   $ build.sh -vt  -- -DCMAKE_BUILD_TYPE=debug
     build for release
   $ build.sh -vt  -- -DCMAKE_BUILD_TYPE=release

OPTIONS:

   -h                   Display this help message.

   -b <build_path>      Specify the cmake build directory to use.

   -c                   Clean out any files in the build dir prior to
                        running cmake.

   -d                   Build documentation, including generate
                        dependency graphs using GraphViz (.DOT and
                        .PDF files).

   -p                   Build supported packages (source, binary, deb,  ...)

   -i <install_prefix>  Install the build to the given path.

   -j <num_threads>     Number of threads to have make use. Defauts to
                        $num_threads on this host.

   -n                   Do not use address sanitizer for debug build
                        (used by default)

   -P <install_path>    Path to installed package to use.

   -F <package>         Package to attempt to find and link with apps.

   -s                   Install the build into $system_install_prefix.
                        Make sure the build path is writable by root.

   -u                   Install the build to the path in the
                        \$gnsstk_apps environment variable.  If this
                        variable is not set, it will be installed to
                        $user_install_prefix.

   -e                   GNSSTk has several parts: core and ext.

                        See README.txt for details.
                        Default (without -e) will build only core
                        Optional (with -e) will build core, ext, and swig

   -t                   Build and run tests.
   -T                   Build and run tests but don't stop on test failures.

   -K                   Enable profiler.  Implies static linked debug build.

   -v                   Include debugging output.
EOF
}


while getopts ":hb:cdepi:j:nP:F:sutTKv" OPTION; do
    case $OPTION in
        h) usage
           exit 0
           ;;
        b) build_root=$(abspath ${OPTARG})
           ;;
        c) clean=1
           ;;
        d) build_docs=1
           ;;
        e) build_ext=1
           ;;
        p) build_packages=1
           ;;
        i) install=1
           install_prefix=$(abspath ${OPTARG})
           ;;
        j) num_threads=$OPTARG
           ;;
        n) no_address_sanitizer=1
           ;;
        P) prefixes=$prefixes";"$(abspath ${OPTARG})
           ;;
        F) extpkg="$extpkg ${OPTARG}"
           ;;
        s) install=1
           install_prefix=$system_install_prefix
           ;;
        u) install=1
           install_prefix=${gnsstk_apps:-$user_install_prefix}
           user_install=1
           ;;
        t) test_switch=1
           ;;
        T) test_switch=-1
           ;;
        K) enable_profiler=1
           link_static=1
           no_address_sanitizer=1
           EXTRA_CMAKE_ARGS="$EXTRA_CMAKE_ARGS -DCMAKE_BUILD_TYPE=debug"
           ;;
        v) verbose+=1
           ;;
        \?) echo "Invalid option: -$OPTARG" >&2
           usage
           exit 2
           ;;
        :) echo "Option -$OPTARG requires an argument" >&2
           usage
           exit 2
    esac
done

shift $(($OPTIND - 1))
LOG="$build_root"/build.log

#----------------------------------------
# Clean build directory
#----------------------------------------
if [ ! -d "$build_root" ]; then
    mkdir -p "$build_root"
fi

if [ -f "$LOG" ]; then
    rm $LOG
fi

if [ $clean ]; then

    case `uname` in
    Linux)
       echo "Uninstalling using install_manifest.txt if it exists..."
       find $build_root -name "install_manifest.txt" -exec cat {} \; | xargs rm -fv
       ;;
    *)
        echo "Not running make uninstall on non-Linux systems"
        ;;
    esac

    rm -rf "$build_root"/*
    log "Cleaned out $build_root ..."

fi

if ((verbose>0)); then
    log "============================================================"
    log "GNSSTk-apps build config ..."
    log "repo                 = $repo"
    log "build_root           = $build_root"
    log "prefixes             = $prefixes"
    log "extpkg               = $extpkg"
    log "install              = $(ptof $install)"
    log "install_prefix       = $install_prefix"
    log "build_ext            = $(ptof $build_ext)"
    log "python_install       = $python_install"
    log "no_address_sanitizer = $(ptof $no_address_sanitizer)"
    log "build_docs           = $(ptof $build_docs)"
    log "build_packages       = $(ptof $build_packages)"
    log "test_switch          = $(ptof $test_switch)"
    log "clean                = $(ptof $clean)"
    log "link_static          = $(ptof $link_static)"
    log "enable_profiler      = $(ptof $enable_profiler)"
    log "verbose              = $(ptof $verbose)"
    log "num_threads          = $num_threads"
    log "cmake args           = $@"
    log "time                 =" `date`
    log "hostname             =" $hostname
    log "uname                =" `uname -a`
    log "git id               =" $(get_repo_state $repo)
    log "logfile              =" $LOG
    log
fi

if ((verbose>2)); then
    log "============================================================"
    set >> $LOG
    log "============================================================"
fi

if ((verbose>3)); then
    exit
fi

# Doxygen should be run in the top level directory so it picks up
# formatting files
cd "$repo"
if [ $build_docs ]; then
    log "Pre-build documentation processing ..."
    # Dynamically configure the Doxyfile with the source and destination paths
    log "Generating Doxygen files from C/C++ source ..."
    sed -e "s#^INPUT *=.*#INPUT = $sources#" -e "s#gnsstk-apps_sources#$sources#g" -e "s#gnsstk-apps_doc_dir#$build_root/doc#g" $repo/Doxyfile >$repo/doxyfoo
    sed -e "s#^INPUT *=.*#INPUT = $sources#" -e "s#gnsstk-apps_sources#$sources#g" -e "s#gnsstk-apps_doc_dir#$build_root/doc#g" $repo/Doxyfile | doxygen - >"$build_root"/Doxygen.log
    tar -czf gnsstk-apps_doc_cpp.tgz -C "$build_root"/doc/html .
fi

# Create the External Linkage include file
rm -f ExtLinkage.cmake
for pkg in $extpkg ; do
    echo "find_package( ${pkg^^} CONFIG )" >>ExtLinkage.cmake
done

cd "$build_root"

# setup the cmake command
args=$@
args+=${prefixes:+" -DCMAKE_PREFIX_PATH=$prefixes"}
args+=${install_prefix:+" -DCMAKE_INSTALL_PREFIX=$install_prefix"}
args+=" -DCMAKE_PREFIX_PATH=$HOME/Software/gnsstk/install/"
args+=${build_ext:+" -DBUILD_EXT=ON"}
args+=${verbose:+" -DDEBUG_SWITCH=ON"}
args+=${user_install:+" -DPYTHON_USER_INSTALL=ON"}
args+=${test_switch:+" -DTEST_SWITCH=ON"}
args+=${link_static:+" -DLINK_STATIC=ON"}
# RPATH can't be used with statically linked executables
args+=${enable_profiler:+" -DPROFILER=ON -DUSE_RPATH=OFF"}
args+=${build_docs:+" --graphviz=$build_root/doc/graphviz/gnsstk-apps_graphviz.dot"}
if [ $no_address_sanitizer ]; then
    args+=" -DADDRESS_SANITIZER=OFF"
else
    args+=" -DADDRESS_SANITIZER=ON"
fi

case `uname` in
    MINGW32_NT-6.1)
        run cmake $args -G "Visual Studio 14 2015 Win64" $repo
        run cmake --build . --config Release
        ;;
    MINGW64_NT-6.3)
        run cmake $args -G "Visual Studio 14 2015 Win64" $repo
        run cmake --build . --config Release
        ;;
    *)
        echo "Run cmake $args $repo ##########################"
        run cmake $args $repo
        run make all -j $num_threads
        #run make all -j $num_threads VERBOSE=1   # BWT make make verbose
esac


if [ $test_switch ]; then
  if ((test_switch < 0)); then
      ignore_failures=1
  fi
  case `uname` in
      MINGW32_NT-6.1)
          run cmake --build . --target RUN_TESTS --config Release
          ;;
      MINGW64_NT-6.3)
          run cmake --build . --target RUN_TESTS --config Release
          ;;
      *)
          run ctest -v -j $num_threads
          test_status=$?
  esac
  unset ignore_failures
fi

if [ $install ]; then
    case `uname` in
    MINGW32_NT-6.1)
        run cmake --build . --config Release --target install
        ;;
    MINGW64_NT-6.3)
        run cmake --build . --config Release --target install
        ;;
    *)
        run make install -j $num_threads
    esac
fi

if [ $build_docs ]; then
    log "Post-build documentation processing ..."

    log "Generating GraphViz output PDF ..."
    dot -Tpdf "$build_root"/doc/graphviz/gnsstk-apps_graphviz.dot -o "$build_root"/doc/graphviz/gnsstk-apps_graphviz.pdf
fi

if [ $build_packages ]; then
    case `uname` in
        MINGW64_NT-6.3)
            run cpack -C Release
            ;;
        MINGW32_NT-6.1)
            run cpack -C Release
            ;;
        *)
            run make package
            run make package_source
    esac
fi

log
if [ $test_switch ]; then
    if [ $test_status == 0 ]; then
        log "All tests passed!"
    else
        log $test_status " test failures."
    fi
else
    log "Tests not run."
fi
log "See $build_root/Testing/Temporary/LastTest.log for detailed test log"
log "See $LOG for detailed build log"
log
log "gnsstk-apps build done."
log `date`
