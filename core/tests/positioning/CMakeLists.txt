set( SD ${GNSSTK_APPS_TEST_DATA_DIR} )
set( TD ${GNSSTK_APPS_TEST_OUTPUT_DIR} )

###############################################################################
# TEST PRSolve
###############################################################################

# test with minimum required inputs - RINEX obs, SP3 Ephemeris, Solution Descriptor
set( ARGS1 --obs\ ${GNSSTK_APPS_TEST_DATA_DIR}/arlm200b.15o\ --eph\ ${GNSSTK_APPS_TEST_DATA_DIR}/test_input_sp3_nav_2015_200.sp3\ --sol\ GPS:12:WC\ --log\ ${TD}/PRSolve_Required.out )
add_test(NAME PRSolve_Required
    COMMAND ${CMAKE_COMMAND}
    -DTEST_PROG=$<TARGET_FILE:PRSolve>
    -DDIFF_PROG=${df_diff}
    -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
    -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
    -DTESTBASE=PRSolve_Required
    -DTESTNAME=PRSolve_Required
    -DARGS=${ARGS1}
    -DDIFF_ARGS=-I\ 12,RPF.*RMS\ -l52\ -z1
    -DOWNOUTPUT=1
    -DEXTPATH=${EXTPATH}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# test with minimum required inputs, RINEX output - RINEX obs, SP3 Ephemeris, Solution Descriptor, adequate ephemerides
# This tests assumes you've got your build directory as gnsstk-apps.
# If the directory name is something else, it will fail.
set( ARGS2 --obs\ ${GNSSTK_APPS_TEST_DATA_DIR}/arlm200b.15o\ --eph\ ${GNSSTK_APPS_TEST_DATA_DIR}/test_input_sp3_nav_2015_200.sp3\ --sol\ GPS:12:WC\ --out\ ${TD}/PRSolve_Rinexout.out\ --log\ ${TD}/PRSolve_Rinexout.log)
set(DIFF_ARGS_2 -I\ 12,RPF.*RMS\ -v\ -l2\ -X\ /gnsstk-apps/\ -X\ DATE )
add_test(NAME PRSolve_Rinexout
    COMMAND ${CMAKE_COMMAND}
    -DTEST_PROG=$<TARGET_FILE:PRSolve>
    -DDIFF_PROG=${df_diff}
    -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
    -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
    -DTESTBASE=PRSolve_Rinexout
    -DTESTNAME=PRSolve_Rinexout
    -DARGS=${ARGS2}
    -DDIFF_ARGS=${DIFF_ARGS_2}
    -DOWNOUTPUT=1
    -DDIFFLOG=1
    -DEXTPATH=${EXTPATH}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test that the output of PRSolve_Rinexout is a valid Rinex Obs file.
add_test(NAME PRSolve_ValidOutput
    COMMAND ${CMAKE_COMMAND}
    -DTEST_PROG=$<TARGET_FILE:rowcheck>
    -DARGS=${TD}/PRSolve_Rinexout.out
    -DTESTBASE=PRSolve_ValidOutput
    -DTESTNAME=PRSolve_ValidOutput
    -DTARGETDIR=${TD}
    -DNODIFF=1
    -DEXTPATH=${EXTPATH}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)
set_tests_properties(PRSolve_ValidOutput PROPERTIES DEPENDS PRSolve_Rinexout)

# Test using RINEX clock for input
# NOTE: The final numerical quantity in the RMS records in the log
# file are the Convergence values from PRSolution::outputRMSString.
# This value may "wander" a bit, but the df_diff should have a
# reasonable tolerance for this.  The critical issue is that the other
# data are identical.
# RPF GPS:12:PWXC RMS 2154 181830.000  9    0.955    0.95    1.83    2.06   5.2  4 2.21e-09 G02 G06 G12 G13 G15 G17 G19 G24 G25 (0 ok) V
#                                                                                  ^^^^^^^^
set( ARGSRINEXCLK --obs\ ${SD}/cord1100.21o\ --eph\ ${SD}/cod21542.sp3\ --clk\ ${SD}/cod21542.clk\ --sol\ GPS:12:PWXC\ -v\ --out\ ${TD}/PRSolve_RINEXClock.out\ --log\ ${TD}/PRSolve_RINEXClock.log )
set(DIFF_ARGS_CLK -I\ 12,RPF.*RMS\ -v\ -l2\ -X\ /gnsstk-apps/\ -X\ DATE )
add_test(NAME PRSolve_RINEXClock
  COMMAND ${CMAKE_COMMAND}
  -DTEST_PROG=$<TARGET_FILE:PRSolve>
  -DDIFF_PROG=${df_diff}
  -DSOURCEDIR=${SD}
  -DTARGETDIR=${TD}
  -DTESTBASE=PRSolve_RINEXClock
  -DTESTNAME=PRSolve_RINEXClock
  -DARGS=${ARGSRINEXCLK}
  -DDIFF_ARGS=${DIFF_ARGS_CLK}
  -DOWNOUTPUT=1
  -DDIFFLOG=1
  -DEXTPATH=${EXTPATH}
  -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)


###############################################################################
# TEST poscvt
###############################################################################

# check that -h option is valid
add_test(NAME poscvt_CmdOpt_1
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testhelp.cmake)

# no options should result in failure
add_test(NAME poscvt_CmdOpt_2
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testfailexp.cmake)

# Test ECEF conversion
add_test(NAME poscvt_ECEF
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DTESTBASE=poscvt_ECEF
         -DTESTNAME=poscvt_ECEF
         -DSPARG1=--ecef=-740289.9180\ -5457071.7340\ 3207245.5420
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test Geodetic conversion
add_test(NAME poscvt_Geodetic
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DTESTBASE=poscvt_Geodetic
         -DTESTNAME=poscvt_Geodetic
         -DSPARG1=--geodetic=30.38366382\ 262.27458654\ 217.6452
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test Geocentric conversion
add_test(NAME poscvt_Geocentric
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DTESTBASE=poscvt_Geocentric
         -DTESTNAME=poscvt_Geocentric
         -DSPARG1=--geocentric=30.21602743\ 262.27458654\ 6372918.0945
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test Spherical conversion
add_test(NAME poscvt_Spherical
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DTESTBASE=poscvt_Spherical
         -DTESTNAME=poscvt_Spherical
         -DSPARG1=--spherical=59.78397257\ 262.27458654\ 6372918.0945
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test formatted output
add_test(NAME poscvt_Format_1
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DSPARG1=--ecef=-740289.9180\ -5457071.7340\ 3207245.5420
         -DTESTBASE=poscvt_Format_1
         -DTESTNAME=poscvt_Format_1
         -DSPARG2=--output-format=%X\ %Y\ %Z
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test formatted output
add_test(NAME poscvt_Format_2
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DSPARG1=--ecef=-740289.9180\ -5457071.7340\ 3207245.5420
         -DTESTBASE=poscvt_Format_2
         -DTESTNAME=poscvt_Format_2
         -DSPARG2=--output-format=%x\ %y\ %z
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test formatted output
add_test(NAME poscvt_Format_3
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DSPARG1=--ecef=-740289.9180\ -5457071.7340\ 3207245.5420
         -DTESTBASE=poscvt_Format_3
         -DTESTNAME=poscvt_Format_3
         -DSPARG2=--output-format=%a\ %l\ %r
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test formatted output
add_test(NAME poscvt_Format_4
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DSPARG1=--ecef=-740289.9180\ -5457071.7340\ 3207245.5420
         -DTESTBASE=poscvt_Format_4
         -DTESTNAME=poscvt_Format_4
         -DSPARG2=--output-format=%A\ %L\ %h
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test formatted output
add_test(NAME poscvt_Format_5
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DSPARG1=--ecef=-740289.9180\ -5457071.7340\ 3207245.5420
         -DTESTBASE=poscvt_Format_5
         -DTESTNAME=poscvt_Format_5
         -DSPARG2=--output-format=%a\ %w\ %R
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test formatted output
add_test(NAME poscvt_Format_6
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DSPARG1=--ecef=-740289.9180\ -5457071.7340\ 3207245.5420
         -DTESTBASE=poscvt_Format_6
         -DTESTNAME=poscvt_Format_6
         -DSPARG2=--output-format=%A\ %W\ %H
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test formatted output
add_test(NAME poscvt_Format_7
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DSPARG1=--ecef=-740289.9180\ -5457071.7340\ 3207245.5420
         -DTESTBASE=poscvt_Format_7
         -DTESTNAME=poscvt_Format_7
         -DSPARG2=--output-format=%t\ %p\ %r
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)

# Test formatted output
add_test(NAME poscvt_Format_8
         COMMAND ${CMAKE_COMMAND}
         -DTEST_PROG=$<TARGET_FILE:poscvt>
         -DSOURCEDIR=${GNSSTK_APPS_TEST_DATA_DIR}
         -DTARGETDIR=${GNSSTK_APPS_TEST_OUTPUT_DIR}
         -DSPARG1=--ecef=-740289.9180\ -5457071.7340\ 3207245.5420
         -DTESTBASE=poscvt_Format_8
         -DTESTNAME=poscvt_Format_8
         -DSPARG2=--output-format=%T\ %P\ %R
         -DEXTPATH=${EXTPATH}
         -P ${CMAKE_CURRENT_SOURCE_DIR}/../testsuccexp.cmake)
