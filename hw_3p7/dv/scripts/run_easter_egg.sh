#!/bin/sh -f

###########################################
# Author : David Clarino
# Date   : 12/19/15
# USAGE: test_config.sh <directory to put in> <number of iterations>
###########################################

date_dir=$1
num_configs=$2
cur_date="`date +\"%Y_%m_%d\"`"
#date_dir=/scratch2/dclarino/random_results/$cur_date
tcsh /home/mentor/setup
pushd $WORK_TOP/..
#/engr/dev/tools/script/refresh_hw
popd
if [ -z $ATRENTA_LICENSE_FILE ]; then
    export ATRENTA_LICENSE_FILE=5285@lic-node0.arteris.com
fi
if [ -z $VERILATOR_ROOT ]; then
    export VERILATOR_ROOT=/home/binx/verilator
fi

if [ -z $SPYGLASS_HOME ]; then
    export SPYGLASS_HOME=/engr/dev/tools/atrenta/SpyGlass/5.4.1.1/SPYGLASS_HOME
    export PATH=$SPYGLASS_HOME/bin:$PATH
fi

if [ -z $WORK_TOP ]; then
    echo "ERROR: Please set your WORK_TOP!"
    exit
fi


if [ -d $date_dir ]; then
    echo "ERROR $date_dir already exists! Specify a different directory"
    exit
fi

#source /engr/dev/tools/script/snps-eng.bash

mkdir -p $date_dir
rm -rf run_config_list*

constraint_solver_dir=$WORK_TOP/dv/common/config/random_configs

###########################################
#  Generate random configs
###########################################
echo "#!/bin/tcsh -f" > $date_dir/gen_config.sh
echo "source /engr/dev/tools/script/conductor.csh" >> $date_dir/gen_config.sh
echo "source /engr/dev/tools/script/mentor-eng.sh" >> $date_dir/gen_config.sh
echo "node $WORK_TOP/dv/scripts/gen_rand_configs.js -D $date_dir -n $num_configs -f $WORK_TOP/dv/scripts/configHelper.json" >> $date_dir/gen_config.sh
chmod 777 $date_dir/gen_config.sh
tcsh $date_dir/gen_config.sh

###########################################
# generate testlists
###########################################

# ===TODO: GET THE CORRECT TESTLIST IN HERE===
last_config=$[$num_configs - 1]
for j in `seq 0 $last_config`; do
#    echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -a -r -c -m -q -n rand$j -d INHOUSE_ACE_BFM,V1,SV_PSEUDO_NOC,PSEUDO_SYS_TB,DUMP_ON,DISABLE_STRRSP_TR_CHECK,EXCLUSIVE_MON,SFI_DELAY_DISABLE -s $date_dir/config``$j``.json -l -L" >> $date_dir/run_config_list
#    echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -a -r -c -m -q -n rand$j -d INHOUSE_ACE_BFM,V1,SV_PSEUDO_NOC,PSEUDO_SYS_TB,DUMP_ON,DISABLE_STRRSP_TR_CHECK,EXCLUSIVE_MON,SFI_DELAY_DISABLE -s $date_dir/config``$j``.json -l -L" >> $date_dir/run_config_list    
    echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -a -r -c -m -q -n rand$j -d INHOUSE_ACE_BFM,V1,SV_PSEUDO_NOC,PSEUDO_SYS_TB,DUMP_ON,DISABLE_STRRSP_TR_CHECK,EXCLUSIVE_MON,SFI_DELAY_DISABLE -s $date_dir/config``$j``.json -l -L" >> $date_dir/run_config_list  
    #    echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -a -r -c -m -q -n rand$j -d INHOUSE_ACE_BFM,V1,SV_PSEUDO_NOC,PSEUDO_SYS_TB,DUMP_ON,DISABLE_STRRSP_TR_CHECK,EXCLUSIVE_MON,SFI_DELAY_DISABLE -s $date_dir/``$cur_date``_config``$j``_derived.json" >> $date_dir/run_config_list    
#    for k in `seq 0 4`; do

   # echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -r -t concerto_inhouse_ace_test -q -n rand$j -p +excl_postrand_disable,+focused_rd_test,+en_cpp_checker,+ntb_random_seed=$RANDOM``$((RANDOM%9999)),+aiu_scb_en=1,+dce_scb_en=1,+dmi_scb_en=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_NONE,+force_reset_values=1,+en_inline_cpp_checks" >> $date_dir/run_config_list
   # echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -r -t concerto_inhouse_ace_test -q -n rand$j -p +excl_postrand_disable,+focused_wr_test,+en_cpp_checker,+ntb_random_seed=$RANDOM``$((RANDOM%9999)),+aiu_scb_en=1,+dce_scb_en=1,+dmi_scb_en=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_NONE,+force_reset_values=1,+en_inline_cpp_checks" >> $date_dir/run_config_list
   #  echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -r -t concerto_inhouse_ace_test -q -n rand$j -p +excl_postrand_disable,+mixed_rd_wr_test,+en_cpp_checker,+ntb_random_seed=$RANDOM``$((RANDOM%9999)),+aiu_scb_en=1,+dce_scb_en=1,+dmi_scb_en=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_NONE,+force_reset_values=1,+en_inline_cpp_checks" >> $date_dir/run_config_list
   #  echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -r -t concerto_inhouse_ace_test -q -n rand$j -p +excl_postrand_disable,+en_cpp_checker,+ntb_random_seed=$RANDOM``$((RANDOM%9999)),+aiu_scb_en=1,+dce_scb_en=1,+dmi_scb_en=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_NONE,+force_reset_values=1,+en_inline_cpp_checks" >> $date_dir/run_config_list
   echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -r -t concerto_inhouse_ace_test -q -n rand$j -p +excl_postrand_disable,+focused_rd_test,+en_cpp_checker,+ntb_random_seed=$RANDOM``$((RANDOM%9999)),+init_mem_with_zero,+aiu_scb_en=1,+dce_scb_en=1,+dmi_scb_en=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_NONE,+force_reset_values=1" >> $date_dir/run_config_list
   echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -r -t concerto_inhouse_ace_test -q -n rand$j -p +excl_postrand_disable,+focused_wr_test,+en_cpp_checker,+ntb_random_seed=$RANDOM``$((RANDOM%9999)),+init_mem_with_zero,+aiu_scb_en=1,+dce_scb_en=1,+dmi_scb_en=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_NONE,+force_reset_values=1" >> $date_dir/run_config_list
    echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -r -t concerto_inhouse_ace_test -q -n rand$j -p +excl_postrand_disable,+mixed_rd_wr_test,+en_cpp_checker,+ntb_random_seed=$RANDOM``$((RANDOM%9999)),+init_mem_with_zero,+aiu_scb_en=1,+dce_scb_en=1,+dmi_scb_en=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_NONE,+force_reset_values=1" >> $date_dir/run_config_list
    echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -r -t concerto_inhouse_ace_test -q -n rand$j -p +excl_postrand_disable,+en_cpp_checker,+ntb_random_seed=$RANDOM``$((RANDOM%9999)),+init_mem_with_zero,+aiu_scb_en=1,+dce_scb_en=1,+dmi_scb_en=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_NONE,+force_reset_values=1" >> $date_dir/run_config_list

    #    done
#	echo "node $WORK_TOP/dv/scripts/rsim.js -e psys -r -t concerto_inhouse_ace_test -n rand$j -p +en_cpp_checker.+ntb_random_seed=769445,+aiu0_wt_ace_dvm_msg=0,+aiu1_wt_ace_dvm_msg=0,+aiu2_wt_ace_dvm_msg=0,+aiu3_wt_ace_dvm_msg=0,+aiu_scb_en=1,+dce_scb_en=1,+dmi_scb_en=1,+k_timeout=400000,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_NONE,+force_reset_values=1" >> $date_dir/run_config_list$j
done

###########################################
#  
###########################################


node $WORK_TOP/dv/scripts/run_easter_egg.js -d $date_dir
# $WORK_TOP/dv/scripts/grid_sub_list.sh -d $date_dir -f $date_dir/run_config_list -m $MAILTO -k
#echo "'use strict';" > $date_dir/test_grid_all.js
#echo "var directory = '$date_dir'" >> $date_dir/test_grid_all.js
#cat $WORK_TOP/random_grid_all.js >> $date_dir/test_grid_all.js

#$WORK_TOP/node_modules/.bin/mocha $date_dir/test_grid_all.js 2> /dev/null

