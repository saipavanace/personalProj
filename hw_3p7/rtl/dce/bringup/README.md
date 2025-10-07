cd /home/boon/hw_repo/hw/rtl/top/src

/home/savitha/ACHL/node_modules-v0.15.1/.bin/ac tb_top.achl.js -p ../../lib/src/concerto_system_params.js,../../lib/src/concerto_encodings.js -o top.v

cd /home/boon/hw_repo/hw/rtl/dce/bringup

make -f Makefile.vcs comp | tee compile.log

./simv +UVM_TESTNAME=sub_sys_test_base | tee sim.log

