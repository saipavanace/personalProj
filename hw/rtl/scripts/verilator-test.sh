#!/bin/sh

export WORK_TOP=`pwd`/hw

cd $WORK_TOP
sleep 2

cd dv/scripts
npm i

cd $WORK_TOP
sleep 2

cd rtl/aiu/verilator
./run run_only >& verilator-test.log &

cd $WORK_TOP
sleep 2

cd rtl/dce/verilator
./run run_only >& verilator-test.log &

cd $WORK_TOP
sleep 2

cd rtl/dmi/verilator
./run run_only >& verilator-test.log &

cd $WORK_TOP
sleep 2

cd rtl/top/verilator
./run run_only >& verilator-test.log
