#!/bin/csh -f
if ( $#argv < 3) then
    echo "Usage: $0 rerun=0 delete_output_files=1 rerunifpass=0 deletetraceifpass=0"
    exit 1
endif

set vcs_run = 0
set checkfile = "../../../lib64/checker"
set statusfile = "../CHECKSTATUS"
if ( -f vcs.log ) then
    set vcs_run = 1
    set checkfile = "../../lib64/checker"
    set statusfile = "../../CHECKSTATUS"
endif

# rerun 1 => delete prev check state and run checker, else just report prev state
set rerun = 0
# deletef 1 => remove all checker output files, else retain
set deletef = 1
# rerunifpass => rerun even if prev run pass
set rerunifpass = 0
# deletetraceifpass => delete trace file if checker passes
set deletetraceifpass = 0

set outf = "checker.out checkerCompletedTxn.log cachestate.log cachedata.log cmemdata.log checker.log checker.cov"

if ( $#argv > 0 ) then
    set rerun = $1
endif
if ( $?CHKFULL ) then
    set rerun = 1
endif
if ( $#argv > 1 ) then
    set deletef = $2
endif
if ( $#argv > 2 ) then
    set rerunifpass = $3
endif
if ( $#argv > 3 ) then
    set deletetraceifpass = $4
endif

#echo "running : $0 rerun=$rerun in $cwd"
#echo "CHECKING $cwd ..."
set ldir = `basename $cwd`

if ( ( 0 == $vcs_run ) && ( ! -f DONE ) ) then
    set msg = "DONE not found"
    echo "$cwd : $msg"
    echo "$cwd : $msg" >! CHECKERROR
    cat CHECKERROR >> $statusfile
    if ( -f checker.trc ) then
	if ( ! -f checker.trc.gz ) then
	    gzip checker.trc
	else
	    \rm -f checker.trc
	endif
    endif
    exit 0
endif

if ( ( $rerun != 0 ) && ( $rerunifpass == 0 ) && ( -f CHECKDONE ) && ( -f CHECKPASS ) ) then
    set rerun = 0
endif
	    
if ( $rerun == 0 ) then
    if ( -f CHECKDONE ) then
	#echo "$cwd : CHECKDONE found"
#    	if ( -f CHECKPASS ) then
#    	    set deletef = 1
#    	endif
    	if ( $deletef != 0 ) then
    	    \rm -f $outf
    	else
	    gzip $outf
    	endif
	if ( ( -f CHECKPASS ) && ( $deletetraceifpass != 0 ) ) then
	    if ( ( -f checker.trc ) || ( -f checker.trc.gz ) ) then
		\rm -f *trc*
	    endif
	endif

        cat CHECK*
        exit 0
    endif
else 
# remove CHECK*
    find . -type f -name "CHECK*" | xargs \rm -f
endif

if ( ! -f $checkfile ) then
    echo "file $cwd/$checkfile not found"
    exit 1
endif

echo "$cwd : running $0"

set err = 0

if ( -f checker.trc.gz ) then
    if ( -f checker.trc ) then 
	\rm -f checker.trc
    endif
    gunzip checker.trc.gz 
endif
if ( ! -f checker.trc ) then
    echo "file checker.trc not found"
    exit 1
endif

if ( -f check.log.gz ) then
    gunzip check.log 
endif
if ( -f comp.log.gz ) then
    gunzip comp.log 
endif
if ( -f cpuUtils.s.gz ) then
    gunzip cpuUtils.s.gz
endif
\rm -f c*.gz;

#setenv CHECKER_LIB_DIR lib64
#setenv CHECKER_HOME `pwd`/../../..
#setenv LD_LIBRARY_PATH ${CHECKER_HOME}/${CHECKER_LIB_DIR}:${LD_LIBRARY_PATH}
#setenv PATH ${CHECKER_HOME}/${CHECKER_LIB_DIR}:${PATH}
if ( $?LD_LIBRARY_PATH ) then
    setenv LD_LIBRARY_PATH /engr/dev/tools/carbon/ModelStudio/8.0.2/Linux64/gcc472/lib64:${LD_LIBRARY_PATH}
else
    setenv LD_LIBRARY_PATH /engr/dev/tools/carbon/ModelStudio/8.0.2/Linux64/gcc472/lib64
endif
$checkfile >&! checker.out;
set rval = $status
gzip checker.trc

if ( $rval != 0 ) then
    set msg = "checker return BAD status $rval"
    echo "$cwd : $msg"
    echo "$cwd : $msg" >! CHECKFAIL
    cat CHECKFAIL >> $statusfile
    set err = 1
endif

set msg = `grep CHKRERROR checker.log`
set rval = $status

if ( $rval == 0 ) then
    echo "$cwd : $msg"
    echo "$cwd : $msg" >! CHECKERROR
    cat CHECKERROR >> $statusfile
    set err = 1
endif

if ( $err == 0 ) then
    set msg = "CHECKPASS"
    echo "$cwd : $msg"
    echo "$cwd : $msg" >! CHECKPASS
    cat CHECKPASS >> $statusfile
    set deletef = 1
    if ( $deletetraceifpass != 0 ) then
	\rm -f *trc*
    endif
endif

if ( $deletef != 0 ) then
    \rm -f $outf
else
    gzip $outf
endif

touch CHECKDONE



