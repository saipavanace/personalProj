#!/bin/bash


#Compiling interfaces only for dii, dmi

#run the git clone once to get repo of .js scripts
#one level above directory 'concerto'
#git clone ssh://git@stash.arteris.com:7999/lib/hw_lib.git


#For each compile,
#cd concerto/rtl/dii/src

#Following command to generate DII RTL using dii_top.tachl
/engr/dev/tools/script/tachl_1.2.0/bin/tachl.js -p ../bringup/new_bringup_params.json -t dii_top.tachl -l ../src,$WORK_TOP/node_modules/hw_lib/rtl/lib/src,../../lib/src -j $WORK_TOP/node_modules/hw_lib/js/lib.js -o out


#Following command to compile the verilog:
cd out ;
vlog -sv -mfcu -64 -timescale=1ps/1ps -writetoplevels toplevels.f -f ./flist.f -l compile.log ; 
vopt -64 -debug -f toplevels.f -o top_opt -l mti_vopt.log +designfile +acc=r ; 
