#!/bin/sh

export SPYGLASS_HOME=/engr/dev/tools/atrenta/SpyGlass/5.4.1.1/SPYGLASS_HOME
export PATH=$SPYGLASS_HOME/bin:$PATH
export ATRENTA_LICENSE_FILE=5289@lic-node0.arteris.com
export WORK_TOP=`pwd`/hw

cd $WORK_TOP
sleep 2

cd dv/scripts
npm i

cd $WORK_TOP
sleep 2

cd rtl/aiu/eslint
./run >& eslint.log &

cd $WORK_TOP
sleep 2

cd rtl/dce/eslint
./run >& eslint.log &

cd $WORK_TOP
sleep 2

cd rtl/dmi/eslint
./run >& eslint.log &

cd $WORK_TOP
sleep 2

cd rtl/aiu/lint
./run run_only >& lint-test.log

cd $WORK_TOP
sleep 2

cd rtl/dce/lint
./run run_only >& lint-test.log

cd $WORK_TOP
sleep 2

cd rtl/dmi/lint
./run run_only >& lint-test.log
