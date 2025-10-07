make -f Makefile.vcs clean
mkdir rtl
/engr/dev/tools/achl/achl-current/.bin/ac -vvv ../../../rtl/top/src/tb_top.achl.js -p ../../common/config/dce/tf_bringup_config.js ../../../rtl/lib/src/concerto_encodings.js -d rtl
../../scripts/node_modules/.bin/prep  -p  ../../../rtl/lib/src/concerto_system_params_hier.js -t ./tb/tb.js.sv -o tb.sv
make -f Makefile.vcs comp
./simv +ntb_random_seed=1234 +num_trans=5 +num_addrs=3 +addr=abcdef,b78901,c12345 | tee sim.log
#grep Offending sim.log
#grep ERROR sim.log
