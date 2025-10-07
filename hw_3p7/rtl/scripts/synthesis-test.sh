#!/bin/sh

export SYNTHESIS_HOME=/engr/dev/tools/synopsys/syn_J-2014.09
export FM_HOME=/engr/dev/tools/synopsys/fm_J-2014.09
export PATH=$SYNTHESIS_HOME/bin:$FM_HOME/bin:$PATH
export LM_LICENSE_FILE=5285@lic-node0.arteris.com
export WORK_TOP=`pwd`

cd $WORK_TOP

cd dv/scripts
npm i

cd $WORK_TOP

cd rtl/aiu/synthesis
./run

cd $WORK_TOP

cd rtl/dce/synthesis
./run

cd $WORK_TOP

cd rtl/dmi/synthesis
./run
