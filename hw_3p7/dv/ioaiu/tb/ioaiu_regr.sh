#!/bin/bash
num_tests=50
source /scratch3/$USER/cron_regr_vars_today
#export WORK_TOP=$HW_DIR/concerto
#regr_dir=/scratch3/$USER/ioaiu_$CUR_DATE

regr_dir=/scratch/$USER/ioaiu_$CUR_DATE
if [ $1 ]; then
    regr_dir=$regr_dir``_$1
fi

mkdir -p $regr_dir
echo "node $WORK_TOP/../scripts/qrsim.js -e ioaiu -c -d DUMP_ON,ASSERT_ON,INHOUSE_OCP_VIP -q -n config1 -s $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -U $WORK_TOP/rtl/ioaiu/src/ioaiu_config1.json -l '+libext+.v+.vlib -y /home/masri/ovl/std_ovl +incdir+/home/masri/ovl/std_ovl +define+OVL_ASSERT_ON' -a" > $regr_dir/regr_list.sh
for j in `seq 0 $num_tests`; do
    echo "node $WORK_TOP/../scripts/qrsim.js -e ioaiu -q -n config1 -t bring_up_test -p +k_num_write_req=1000,+k_num_read_req=1000,+k_num_write_req=1000+UVM_VERBOSITY=UVM_NONE,+UVM_MAX_QUIT_COUNT=1 -l '+libext+.v+.vlib -y /home/masri/ovl/std_ovl +incdir+/home/masri/ovl/std_ovl +define+OVL_ASSERT_ON' -R $RANDOM``$((RANDOM%9999))" >> $regr_dir/regr_list.sh
done;
echo "node $WORK_TOP/../scripts/qrsim.js -e ioaiu -c -d DUMP_ON,ASSERT_ON,NO_SCB,NO_ADDR_MGR -q -n config2 -s $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config2AchlParams.json -U $WORK_TOP/rtl/ioaiu/src/ioaiu_config2.json -l '+libext+.v+.vlib -y /home/masri/ovl/std_ovl +incdir+/home/masri/ovl/std_ovl +define+OVL_ASSERT_ON' -a " >> $regr_dir/regr_list.sh
for j in `seq 0 $num_tests`; do
    echo "node $WORK_TOP/../scripts/qrsim.js -e ioaiu -q -n config2 -t bring_up_test -p +k_num_write_req=1000,+k_num_read_req=1000,+k_num_write_req=1000+UVM_VERBOSITY=UVM_NONE,+UVM_MAX_QUIT_COUNT=1 -l '+libext+.v+.vlib -y /home/masri/ovl/std_ovl +incdir+/home/masri/ovl/std_ovl +define+OVL_ASSERT_ON' -R $RANDOM``$((RANDOM%9999))" >> $regr_dir/regr_list.sh
done;

$WORK_TOP/../scripts/grid_sub_list.sh -d $regr_dir -f $regr_dir/regr_list.sh -m david.clarino@arteris.com
