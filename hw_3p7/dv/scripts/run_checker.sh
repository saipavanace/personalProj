#!/bin/csh -f
# Build checker if needed
# Run checker
# Check for errors
# Report results
# Run it from your test dir (i.e. debug/psys/<config_dir>/run/concert*)

if (! -d ../../dv ) then
    echo "run_checker not invoked in test dir, dir ../../dv not FOUND!"
    exit 1
endif

if (! -f ../../lib64/checker ) then
    pushd ../..
    if (! -f dv/Makefile.checker ) then
        echo "$cwd/dv/Makefile.checker not found!"
        exit 1
    endif
    cp -p dv/Makefile.checker .
    make -f Makefile.checker >&! make.checker.log
    if ( $status != 0 ) then
	echo "cmd: make -f Makefile.checker >&! make.checker.log FAIL!"
	exit 1
    endif
    popd
endif
if (! -f ../../lib64/checker ) then
    echo "$cwd/lib64/checker not found!"
    exit 1
endif

../../lib64/checker >&! checker.out

if ( $status != 0 ) then
    echo "checker run return BAD status $status see checker.out"
    exit 1
endif
set err = `grep ERR checker.log`
if ( $status == 0 ) then
    echo "CHECKER FAIL: see checker.log: $err"
else
    echo "CHECKER PASS: No errors in checker.log"
endif
exit 0    
