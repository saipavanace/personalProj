TECHNODE=CLN28HPM
LIBRARY=tcbn28hpmbwp35
REVISION=120a
FFCORNER=ff0p88vm40c
SSCORNER=ss0p72v125c
PERIOD=1.000
WIRELOAD=topo
SCAN=yes
COMPILE=yes
DIRNAME=${TCL}_${TECHNODE}_${LIBRARY}_${REVISION}_${FFCORNER}_${SSCORNER}_${PERIOD}_${WIRELOAD}_${SCAN}_${COMPILE}

help:
	@echo ""
	@echo "SYNTAX: make [tool] TCL=[file] FILELIST=[file list] {optional parameters}"
	@echo ""
	@echo "Output directory will be created at syn.[file]"
	@echo ""
	@echo "[tool]"
	@echo "dc - run Design Compiler"
	@echo ""
	@echo "[file]"
	@echo "Any script under the /scripts directory, without .tcl"
	@echo ""
	@echo "[file list]"
	@echo "Path to the file list or a .ddc file for a synthesized design (relative to the output directory)"
	@echo "File in the file list or a .ddc file is also relative to the output directory"
	@echo ""
	@echo "{optional parameters}"
	@echo "Additional run-time parameters. Here is a list with examples"
	@echo ""
	@echo "TECHNODE={technology node}"
	@echo "LIBRARY={library name}"
	@echo "REVISION={revision #}"
	@echo "FFCORNER={Fast corner}"
	@echo "SSCORNER={Slow corner}"
	@echo "PERIOD={clock period in ns}"
	@echo "WIRELOAD={topo/ZeroWireload}"
	@echo "SCAN={yes/no}"
	@echo "COMPILE={yes/no}"
	@echo ""
	@echo "Example:"
	@echo "make dc TCL=synthesis FILELIST=../../shared/filelist_rtl TECHNODE=CLN28HPM LIBRARY=tcbn28hpmbwp35 REVISION=120a FFCORNER=ff0p88vm40c SSCORNER=ss0p72v125c PERIOD=1.000 WIRELOAD=topo SCAN=yes COMPILE=yes"
	@echo ""

clean:
	@rm -rf syn.*

create:
ifneq ("$(wildcard syn.${DIRNAME})", "")
	@echo "Directory syn.${DIRNAME} already existed, it will be overwritten"
	@rm -rf syn.${DIRNAME}
endif
	@mkdir syn.${DIRNAME}
ifeq ("${COMPILE}", "yes")
	@cd syn.${DIRNAME}; awk '{print "read_file -format sverilog -library WORK "$$1}' ${FILELIST} > filelist
else
	@cd syn.${DIRNAME}; echo "read_ddc ${FILELIST}" > filelist
endif
	@cd syn.${DIRNAME}; touch variables
	@cd syn.${DIRNAME}; echo "set TECHNODE ${TECHNODE}" >> variables 
	@cd syn.${DIRNAME}; echo "set LIBRARY ${LIBRARY}" >> variables
	@cd syn.${DIRNAME}; echo "set REVISION ${REVISION}" >> variables 
	@cd syn.${DIRNAME}; echo "set FFCORNER ${FFCORNER}" >> variables
	@cd syn.${DIRNAME}; echo "set SSCORNER ${SSCORNER}" >> variables
	@cd syn.${DIRNAME}; echo "set PERIOD ${PERIOD}" >> variables
	@cd syn.${DIRNAME}; echo "set WIRELOAD ${WIRELOAD}" >> variables
	@cd syn.${DIRNAME}; echo "set SCAN ${SCAN}" >> variables
	@cd syn.${DIRNAME}; echo "set COMPILE ${COMPILE}" >> variables

dc:
	@make create TCL=${TCL}
ifeq ("${WIRELOAD}", "topo")
	@cd syn.${DIRNAME}; dc_shell-t -topo -64bit -f ../scripts/${TCL}.tcl | tee dc_shell.log
else
	@cd syn.${DIRNAME}; dc_shell-t -64bit -f ../scripts/${TCL}.tcl | tee dc_shell.log
endif
