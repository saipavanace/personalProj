WORK_TOP = ../../../..

help:
	@echo ""
	@echo "SYNTAX: make [tool] NAME=[name] RTL=[rtl] TOP=[top] DIR=[dir]"
	@echo ""
	@echo "Run Verilator on top [rtl] Verilog file using the [top] module"
	@echo "Submodules are searched in the [dir] directory"
	@echo "Output directory will be created at verilator.[name]"
	@echo ""
	@echo "[tool]"
	@echo "verilator - run Verilator"
	@echo ""
	@echo "Example:"
	@echo "make verilator Name=verilator TOP=../../ TCL=verilator.js"
	@echo ""

clean:
	@rm -rf verilator.*
	@rm -rf reg_run.log testlist

create:
ifneq ("$(wildcard verilator.${NAME})", "")
	@echo "Directory verilator.${NAME} already existed"
else
	@mkdir verilator.${NAME}
endif

verilator:
	@make create NAME=${NAME}
	@cd verilator.${NAME}; /usr/local/bin/verilator_bin ${RTL} --top-module ${TOP} -y ${DIR} --cc >& verilator.txt
