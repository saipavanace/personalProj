#!/bin/bash -f 

if [ ! -e $WORK_TOP ]; then
    echo "ERROR: WORK_TOP NOT SET"
    exit 1
fi

mkdir -p $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build
mkdir -p $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv
mkdir -p $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/exe

#Run Perp commands
if [ ! -f $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json ]; then
    echo "ERROR: Config file missing"
    exit 1
fi

echo "executing prep on chi files"

$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/sv_assert_pkg.sv     -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/sv_assert_pkg.sv
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/ncore_config_info.sv -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/ncore_config_info.sv
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/addr_trans_mgr.sv     -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/addr_trans_mgr.sv
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/addr_trans_mgr_pkg.sv -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/addr_trans_mgr_pkg.sv

$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_widths.svh    -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_widths.svh
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_types.svh     -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_types.svh
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_seq_item.svh  -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_seq_item.svh
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_misc_txn.svh  -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_misc_txn.svh
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_driver.svh    -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_driver.svh
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_monitor.svh   -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_monitor.svh
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_seqr.svh      -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_seqr.svh
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_agent_cfg.svh -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_agent_cfg.svh
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_agent.svh     -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_agent.svh
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_agent_pkg.sv  -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_agent_pkg.sv
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_if.sv         -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_if.sv

$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_coverage.svh -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/dce0_chi_coverage.svh

$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/chi_unit_tb.flist -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/exe/build.flist
$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/tb_top.sv -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/tb_top.sv

$WORK_TOP/../scripts/node_modules/.bin/prep -p $WORK_TOP/../test_projects/fsys_v3.0_configs/simple_config1AchlParams.json -t $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/tests/chi_test.sv -o $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/dv/chi_test.sv

echo "executing questa compile"
pushd $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/exe

vlog -sv -mfcu -64 -timescale=1ps/1ps +incdir+/home/mentor/questa_10.6a/questasim/verilog_src/uvm-1.1d/src /home/mentor/questa_10.6a/questasim/verilog_src/uvm-1.1d/src/uvm.sv +define+QUESTA +define+SVT_UVM_TECHNOLOGY /home/mentor/questa_10.6a/questasim/verilog_src/uvm-1.1d/src/dpi/uvm_dpi.cc -printinfilenames -writetoplevels toplevels.f -stats=perf,verbose -warning 2367 -permissive -svext=ias,idcl,iddp +define+UVM_PACKER_MAX_BYTES=1500000 +define+UVM_DISABLE_AUTO_ITEM_RECORDING +define+UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE +define+ASSERT_ON +define+INHOUSE_OCP_VIP -f build.flist -l compile.log && vopt  -inlineFactor=1024 -64 -debug -f toplevels.f -o top_opt -stats=perf,verbose -svext=ias,idcl,iddp -permissive -l mti_vopt.log +designfile +acc=r +noacc+tb_top.

if [ "$?" != "0" ]; then
  echo "ERROR: COMPILE FAILED"
  exit 1
fi

vopt  -inlineFactor=1024 -64 -debug -f toplevels.f -o top_opt -stats=perf,verbose -svext=ias,idcl,iddp -permissive -l mti_vopt.log +designfile +acc=r +noacc+tb_top.
  
if [ "$?" != "0" ]; then
  echo "ERROR: ELABORATION FAILED"
  exit 1
fi

cat << EOF > dofile
set PrefMain(LinePrefix) {}; run -a; quit -f
EOF

vsim  -batch -64 +ntb_random_seed=57281136 +UVM_TESTNAME=chi_test +UVM_VERBOSITY=UVM_NONE +UVM_MAX_QUIT_COUNT=1 -lib $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/exe/work top_opt -L $WORK_TOP/dv/common/lib_tb/chi_agent_pkg/build/exe/work -do dofile -stats=perf,verbose -solvefaildebug -permissive -l vcs1.log -permit_unmatched_virtual_intf -warning 3829,8604,12003,12023,3008,3009 +nowarn3829 +nowarn8233 -uvmcontrol=none -modelsimini /engr/dev/tools/script/modelsim.ini -novopt -sv_seed 57281136 -qwavedb=+signal +compile_test

popd

