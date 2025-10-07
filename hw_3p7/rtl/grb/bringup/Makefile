nop:
	echo "Generating Verilog RTL..."

build: nop
	/engr/dev/releases/tachl/versions/tachl-latest/bin/tachl.js  -p ../bringup/bringup_params.json -t ../src/grb.tachl -l ../src,../../../node_modules/@arteris/hw-lib/rtl/lib/src -j ../../../node_modules/@arteris/hw-lib/js/lib_utils.js,../../../node_modules/@arteris/hw-lib/js/interfaceGenerators.js,../../../node_modules/@arteris/hw-lib/js/bundleFunctions.js,../../../node_modules/@arteris/hw-lib/js/lib.js -z ../../../cpr/interface -o ./rtl_output
