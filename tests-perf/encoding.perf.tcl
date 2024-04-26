#!/usr/bin/tclsh

# ------------------------------------------------------------------------
#
# encoding.perf.tcl --
#
#  This file provides performance tests for comparison of tcl-speed
#  of tcl encoding.
#
# ------------------------------------------------------------------------
#
# Copyright (c) 2018-2021 Serg G. Brester (aka sebres)
#
# See the file "license.terms" for information on usage and redistribution
# of this file.
#


if {![namespace exists ::tclTestPerf]} {
  source [file join [file dirname [info script]] test-performance.tcl]
}


namespace eval ::tclTestPerf-Enc {

namespace path {::tclTestPerf}

proc test-encoding-object {{reptime 1000}} {
  _test_run $reptime {
    # static object and cached encoding (utf-8 must be already there):
    {encoding convertfrom utf-8 xxx}
    {encoding convertto utf-8 xxx}
    # system encoding:
    {encoding convertfrom xxx}
    {encoding convertto xxx}
    # dynamic object :
    {encoding convertfrom [string trimright "shiftjis "] xxx}
    {encoding convertto [string trimright "shiftjis "] xxx}
    # object shimmering :
    {encoding convertfrom jis0208 xxx; llength jis0208}
    {encoding convertto jis0208 xxx; llength jis0208}
  }
}
proc test-multi-encoding {{reptime 1000}} {
  _test_run $reptime {
    # dynamic object 2x convert:
    {encoding convertfrom [string trimright "jis0208 "] [encoding convertto [string trimright "shiftjis "] xxx]}
    # dynamic object 3x convert:
    {encoding convertto [string trimright "jis0212 "] [encoding convertfrom [string trimright "jis0208 "] [encoding convertto [string trimright "shiftjis "] xxx]]}
    # dynamic object 4x convert (with nested encodings load):
    {encoding convertfrom [string trimright "iso2022-kr "] [encoding convertto [string trimright "ebcdic "] [encoding convertfrom [string trimright "dingbats "] [encoding convertto [string trimright "iso2022-jp "] xxx]]]}
  }
}

proc test-channel-encoding {{reptime 1000}} {
  _test_run $reptime {
    setup {set o [fconfigure stdout -encoding]; list}
    # dynamic object :
    {fconfigure stdout -encoding [string trimright "shiftjis "]; fconfigure stdout -encoding $o}
    # static object (shimmering) :
    {fconfigure stdout -encoding shiftjis; fconfigure stdout -encoding $o}
  }
}

proc test {{reptime 1000}} {
  test-encoding-object $reptime
  test-multi-encoding $reptime
  test-channel-encoding $reptime
  puts \n**OK**
}

}; # end of ::tclTestPerf-Enc

# ------------------------------------------------------------------------

# if calling direct:
if {[info exists ::argv0] && [file tail $::argv0] eq [file tail [info script]]} {
  array set in {-time 250}
  array set in $argv
  ::tclTestPerf-Enc::test $in(-time)
}
