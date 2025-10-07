#!/bin/sh -f 
export VCS_HOME=/engr/dev/tools/synopsys/vcs-mx-J-2014.12
export VCS_BIN=${VCS_HOME}/bin
export VCS_TARGET_ARCH=amd64
export VCS_ARCH_OVERRIDE=linux
export OCP_AIP=${VCS_HOME}/packages/aip/OCP_AIP/src
export UVM_HOME=${VCS_HOME}/etc/uvm/
export DESIGNWARE_HOME=/engr/dev/tools/synopsys/designware-vip-J-2014.12
export VERA_HOME=/engr/dev/tools/synopsys/vera-I-2014.03/vera_vI-2014.03_amd64
export VERDI=/engr/dev/tools/synopsys/verdi_J-2014.12/
export SNPSLMD_LICENSE_FILE=5285@lic-node0.arteris.com
export PATH="${VCS_BIN}:${VERDI}/bin:${PATH}"
export WORK_TOP=`pwd`/hw
export DW_WAIT_LICENSE=1

cd $WORK_TOP
#export WORK_TOP=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd dv/scripts
npm i

cd $WORK_TOP
cd ..
tclsh $WORK_TOP/dv/scripts/bamboo_run.tcl -m 8 -c
sleep 2
$WORK_TOP/rtl/scripts/lint-test.sh &
$WORK_TOP/rtl/scripts/verilator-test.sh &
$WORK_TOP/rtl/scripts/parameter-test.sh &
tclsh $WORK_TOP/dv/scripts/bamboo_run.tcl -m 2 -r

# cd $WORK_TOP
# cd dv/aiu/tb
# tclsh $WORK_TOP/dv/scripts/par_run.tcl -e $WORK_TOP/dv/aiu/tb -f $WORK_TOP/dv/aiu/tb/testlist -m 2 &

# #./runtest_new

# #cd $WORK_TOP
# #cd dv/dce/tb
# tclsh $WORK_TOP/dv/scripts/par_run.tcl -e $WORK_TOP/dv/dce/tb -f $WORK_TOP/dv/dce/tb/testlist -m 2 &
# #tclsh $WORK_TOP/dv/scripts/par_run.tcl -e . -f testlist -m 4
# # #./runtest_new

# # cd $WORK_TOP
# # cd dv/dmi/tb
# tclsh $WORK_TOP/dv/scripts/par_run.tcl -e $WORK_TOP/dv/dmi/tb -f $WORK_TOP/dv/dmi/tb/testlist -m 2 &
# # tclsh $WORK_TOP/dv/scripts/par_run.tcl -e . -f testlist -m 4
# # #./runtest_new

# # cd $WORK_TOP
# # cd dv/sub_sys/tb
# tclsh $WORK_TOP/dv/scripts/par_run.tcl -e $WORK_TOP/dv/sub_sys/tb -f $WORK_TOP/dv/sub_sys/tb/testlist -m 4
# # tclsh $WORK_TOP/dv/scripts/par_run.tcl -e . -f testlist -m 4
# #./runtest_new

# #cd $WORK_TOP
# #cd dv/scripts

#./runtestp
#./testlist

exit 0
