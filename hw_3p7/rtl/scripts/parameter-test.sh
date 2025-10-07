#!/bin/sh

export WORK_TOP=`pwd`/hw

cd $WORK_TOP
sleep 2

cd dv/scripts
npm i

cd $WORK_TOP
sleep 2

cd rtl/aiu/parameter_validation
./run run_only >& parameter-test.log &

cd $WORK_TOP
sleep 2

cd rtl/dce/parameter_validation
./run run_only >& parameter-test.log &

cd $WORK_TOP
sleep 2

cd rtl/dmi/parameter_validation
./run run_only >& parameter-test.log &

cd $WORK_TOP
sleep 2

cd rtl/top/parameter_validation
./run run_only >& parameter-test.log
