all: run

build:
	/engr/dev/tools/script/tachl_1.2.0/bin/tachl.js -p ./bringup_params.json -t ../src/dmi.tachl -l ../src,../../lib/src/,../../../../hw_lib/rtl/lib/src/,../../ccp/src/ -j ../../../../hw_lib/js/lib.js,../src/dmiLib.js -o ./output

build_tb:
	cp output/dmi.attr output/dmi.json
	/home/thbj/Workspaces/prep/bin/prep.js -p output/dmi.json -t tb/tb.cpp -o ./output/tb.cpp

build_local:
	/home/thbj/Workspaces/tachl_bringup/tachl/bin/tachl.js -p ./bringup_params.json -t ../src/dmi.tachl -l ../src,../../../../hw_lib/rtl/lib/src/,../../ccp/src/ -j ../../../../hw_lib/js/lib.js,../src/dmiLib.js -o ./output

compile: build build_tb
	verilator -sc --trace ./output/dmi.v -I./output -exe ./output/tb.cpp
	make -j -C obj_dir -f Vdmi.mk Vdmi

run: compile
	cd obj_dir && ./Vdmi

# requires /engr/dev/tools/script/snps-eng.bash
dve: run
	cd obj_dir && dve -vpd sim.vcd

lint: build
	verilator --lint-only ./output/*.v

clean:
	rm -rf ./output
	rm -rf ./obj_dir
	rm -rf ./tb/output