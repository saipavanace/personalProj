BUILDDIR = ../build
RUNDIR   = ../run
RTLF     = ../rtl/no_project_name__dce0__dirm__SnoopOwnerSharer1_victim_buff_ptr.v

ifndef VCS_HOME
    $(error VCS_HOME undefined. It must point to VCS executable. please define this and make again)
endif

all: build run

build:
	mkdir -p $(BUILDDIR)
	\cd $(BUILDDIR) && vcs -sverilog -parallel+sva -timescale=1ns/1ps +vpi +vcs+lic+wait +lint=TFIPC-L +acc -debug_pp ../tb/victim_buffer_tb.sv $(RTLF) -l compile.log

run:
	mkdir -p $(RUNDIR) 
	\cd $(RUNDIR) && ../build/simv +vcs+lic+wait -assert nopostproc -l vcs.log -cm_dir simv.vdb

clean:
	\rm -Rf $(BUILDDIR) 
