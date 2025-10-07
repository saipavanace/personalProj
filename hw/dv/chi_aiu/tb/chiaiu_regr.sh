#!/bin/bash -f 
##############################################
## Author : Neha 
## Date : 6/14/2018
##############################################
source /scratch3/$USER/cron_regr_vars_today
export REGR_DIR=/scratch3/$USER/cron/chiaiu/regr

echo "I m running" >> $REGR_DIR/cron_chiaiu.log

export ARTERIS_UGLIFY_OFF=1
export WORK_TOP=$HW_DIR/concerto >> $REGR_DIR/cron_chiaiu.log

##############################################
## RUN TEST
##############################################
pushd $WORK_TOP/dv/chi_aiu/tb > $REGR_DIR/cron_chiaiu.log

node $WORK_TOP/scripts/gen_my_regr.js -e chi_aiu -r -d $REGR_DIR -m neha.fotaria@arteris.com,chirag.gandhi@arteris.com,shilpa.sawant@arteris.com,abhinav.nippuleti@arteris.com -s CHI_MASTER -f $WORK_TOP/dv/chi_aiu/tb/chiaiu_testlist.json >> $REGR_DIR/cron_chiaiu.log 

if [ ! -e "$WORK_TOP/dv/chi_aiu/tb/regr_cmd.sh" ]; then
    echo "ERROR: gen_my_regr failed couldn't find regr_cmd.sh file" >> $REGR_DIR/cron_chiaiu.log
    exit 1
fi

echo "STATUS: Successfully generated regr_cmd.sh and reglist.sh" >> $REGR_DIR/cron_chiaiu.log
source $WORK_TOP/dv/chi_aiu/tb/regr_cmd.sh  >> $REGR_DIR/cron_chiaiu.log
popd
