#!/bin/bash -f 

# -D directory to dump to
# -I id of current run. we'll be dumping to $WORK_TOP/debug/$module_name_regr_$id
#TEST_NAME=

local_dir=/local/$CONCERTO_USER
##RUN COMMAND
if [ -d $local_dir/$JOB_ID ]
then
    rm -rf $local_dir/$JOB_ID
fi
    mkdir -p $local_dir/$JOB_ID

OPTIND=3
OPTERR=0
cd $local_dir/$JOB_ID
QUESTA=0
LABEL=""
while getopts 'D:l:op:e:t:rn:a:cd:rqEs:imu:b:' flag; do
    case "${flag}" in
	D) DUMP_DIR=${OPTARG};;
	u) REGR_ID=${OPTARG};;
	e) BLOCK_NAME=${OPTARG};;
	n) CONFIG_NAME=${OPTARG};;
	t) TEST_NAME=${OPTARG};;
	q) QUESTA=1;;
	b) LABEL=${OPTARG};;
	*) ;;
    esac
done

if [ -z $LABEL ]; then
    LABEL=""
else
    LABEL="_$LABEL"
fi

#
#  Function to move files after run is finished
#
function mv_files {
    pushd $local_dir/$JOB_ID
    
    mkdir -p $HOME_DIRECTORY/debug/$BLOCK_NAME/$CONFIG_NAME/run/$TEST_NAME$TEST_ID$LABEL
    cur_files=`ls`
    cur_pwd=`pwd`
    if [[ $cur_pwd =~ \/local\/ ]]; then
	for this_file in $cur_files; do
	    mv $this_file $HOME_DIRECTORY/debug/$BLOCK_NAME/$CONFIG_NAME/run/$TEST_NAME$TEST_ID$LABEL
	done
    fi
    popd
}


#
# Trap in case run goes on too long or user kills run
# Can still get files back if this is the case
#
trap mv_files SIGINT SIGKILL SIGTERM

#should work since simv is deleted before every run
if [ -f $DUMP_DIR/debug/$BLOCK_NAME/$CONFIG_NAME/exe/simv ];
then
#    /engr/dev/tools/script/tarf/tlog.js -s running -c "cmd" -r $RUN_NAME -t $BLOCK_NAME``_$CONFIG_NAME``_test$TEST_ID -e $TEST_HOSTNAME -u process.env.USER -p "$HOME_DIRECTORY"
    run_files=`$* -g $JOB_ID`
    if [ "$RUN_CHECKER" -eq "1" ];
    then
	pushd /local/$USER/$JOB_ID
	$DUMP_DIR/debug/$BLOCK_NAME/$CONFIG_NAME/lib64/checker
	popd
    fi
    run_files=$TEST_NAME$TEST_ID
    mv_files
elif [ "$QUESTA" -eq "1" ];
then
#    /engr/dev/tools/script/tarf/tlog.js -s running -c "cmd" -r $RUN_NAME -t $BLOCK_NAME``_$CONFIG_NAME``_test$TEST_ID -e $TEST_HOSTNAME -u process.env.USER -p "$HOME_DIRECTORY"
    run_files=`$* -g $JOB_ID`
    echo "Tail of output" 
    if [ "$RUN_CHECKER" -eq "1" ];
    then
	pushd /local/$USER/$JOB_ID
	$DUMP_DIR/debug/$BLOCK_NAME/$CONFIG_NAME/lib64/checker
	popd
    fi

    run_files=$TEST_NAME$TEST_ID
    
    mv_files
else
    echo "ERROR: COMPILE FOR $CONFIG_NAME DID NOT FINISH"
    exit
fi



    

