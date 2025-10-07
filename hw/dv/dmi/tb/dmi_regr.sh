#!/bin/bash -f 
##############################################
## Author : satya
## Date : 6/11/18
##############################################
#source /scratch3/$USER/cron_regr_vars_today
#export REGR_DIR=/scratch3/$USER/cron/dmi/regr
#
#echo "I m running" >> $REGR_DIR/cron_dmi.log
#
#export ARTERIS_UGLIFY_OFF=1
#export WORK_TOP=$HW_DIR/concerto >> $REGR_DIR/cron_dmi.log
export REGR_DIR=/scratch3/$USER/DMI_MASTER_REGR

##############################################
## RUN TEST
##############################################
pushd $WORK_TOP/dv/dmi/tb > $REGR_DIR/cron_dmi.log

node $WORK_TOP/scripts/gen_my_regr.js -e dmi -r -d $REGR_DIR -m satya.prakash@arteris.com,chirag.gandhi@arteris.com,mohammed.khaleeluddin@arteris.com,david.clarino@arteris.com,steve.kromer@arteris.com -s DMI_MASTER -f $WORK_TOP/dv/dmi/tb/dmi_testlist.json >> $REGR_DIR/cron_dmi.log 
#node $WORK_TOP/dv/scripts/gen_my_regr.js -e dmi -r -d $REGR_DIR -m satya.prakash@arteris.com -s DMI_MASTER -f $WORK_TOP/dv/dmi/tb/dmi_testlist.json >> $REGR_DIR/cron_dmi.log 

if [ ! -e "$WORK_TOP/dv/dmi/tb/regr_cmd.sh" ]; then
    echo "ERROR: gen_my_regr failed couldn't find regr_cmd.sh file" >> $REGR_DIR/cron_dmi.log
    exit 1
fi

echo "STATUS: Successfully generated regr_cmd.sh and reglist.sh" >> $REGR_DIR/cron_dmi.log
source $WORK_TOP/dv/dmi/tb/regr_cmd.sh  >> $REGR_DIR/cron_dmi.log
popd
