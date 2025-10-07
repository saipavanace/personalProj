#! /bin/echo The SOURCEME.csh file is meant to be sourced, not executed

set script=($_)
set script_fullpath=`realpath $script[2]`
set work_top_relative=`dirname $script_fullpath`/../../../hw-ncr
set work_top_resolved=`realpath $work_top_relative`
setenv WORK_TOP $work_top_resolved
#setenv WORK_TOP `dirname $script_fullpath`/../../../hw-ncr

module load dev/concerto/by_path_ncore3_8

##module unload node/v16.19.0
##module load node/lts
