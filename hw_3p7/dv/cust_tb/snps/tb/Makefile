# extracted config parameters
PROJ_NAME	= <%=obj.strProjectName%>
HAS_RESIL	= <%=obj.useResiliency%>

# make variables
DEBUG		?= 0
DUMP		?= 0
PLUSARGS 	= 
RUN_ARG		= 
SEED		?= 0
# TESTS = valid tests for this config, derived from the test lib
TESTS = $(shell echo `grep include tests/ncore_test_lib.sv | grep -v \/\/ | cut -d\" -f2 | cut -d. -f1`)
# remove valid entries in ncore_test_lib that are not runnable tests
TESTS := $(filter-out ncore_seq_lib,$(TESTS))
TESTS := $(filter-out ncore_base_test,$(TESTS))
TESTS := $(filter-out ncore_system_base_test,$(TESTS))
# bit_bash_tests takes a long time, require them to be called directly
TESTS := $(filter-out ncore_ral_bit_bash_test,$(TESTS))
TESTS := $(filter-out ncore_fsc_ral_bit_bash_test,$(TESTS))

# Run Arguments for waves
ifeq ($(DUMP),1)
  RUN_ARG += +en_dump +fsdbfile+test.fsdb +svt_enable_pa=FSDB
endif
ifeq ($(DEBUG),1)
  RUN_ARG += +sps_enable_hier_trace +UVM_VERDI_TRACE=UVM_AWARE+HIER+RAL
endif

# UVM parameters
UVM_TIMEOUT ?= <%=obj.nDVEs + obj.nDCEs + obj.nDMIs + obj.nDIIs + obj.AiuInfo.length%>0000000000
UVM_VERBOSITY ?= UVM_NONE

# options for tests that need them, define the variable as blank for those that don't
OPTS =
ncore_bandwidth_test: OPTS = +performance_test
ncore_bandwidth_test_multi: OPTS = +performance_test
ncore_cache_access_test: OPTS = +performance_test +producer_consumer_m2_order
ncore_fsc_Uncorr_Error_test: OPTS = +inject_uncorrectable_error
ncore_memregions_override_test: OPTS = +override_memregions
ncore_snoop_test: OPTS = +performance_test

# message controls
LINTS = all,noPCTIO-L
WARNS = noLCA_FEATURES_ENABLED

# check for needed environment variables and prompt if missing
ifndef PROJ_HOME 
  $(error PROJ_HOME undefined. please point to RTL path and rerun )
endif

ifndef VCS_HOME
  $(error VCS_HOME undefined. It must point to VCS executable. please define this and make again)
endif

ifndef DESIGNWARE_HOME
  $(info DESIGNWARE_HOME undefined. It must point to Synopsys DESIGNWARE VIP source directory.)
  $(error Please define DESIGNWARE_HOME and make again)
endif

ifndef SNPS_AMBA_VIP
  $(info  Please extract Synopsys AMBA VIP src & include directory by running the dw_vip_setup script. Sample command:)
  $(info  $$DESIGNWARE_HOME/bin/dw_vip_setup -path amba_vip -e amba_svt/tb_chi_svt_uvm_basic_sys)
  $(info  SNPS_AMBA_VIP undefined. It must point to Synopsys AMBA VIP working directory.)
  $(error please define SNPS_AMBA_VIP and make again) 
endif

ifndef VERDI_HOME
  $(error VERDI_HOME undefined.  It must point to the VERDI installation.  Please define and make again or contact your AE if you don't have access to VERDI)
endif

# directories
TB_SRC 		= $(PROJ_HOME)/tb/vcs
BUILDDIR 	= $(TB_SRC)/build
RUNDIR 		= $(TB_SRC)/run

BUILD_CMD = $(VCS_HOME)/bin/vcs -q +vcs+lic+wait +define+DUMP_ON -kdb -lca \
			+incdir+$(SNPS_AMBA_VIP)/src/sverilog/vcs \
			+incdir+$(SNPS_AMBA_VIP)/include/sverilog \
			+incdir+$(SNPS_AMBA_VIP)/src/verilog/vcs \
			+incdir+$(SNPS_AMBA_VIP)/include/verilog \
			-CFLAGS -DVCS -ntb_opts uvm-1.2 \
			-full64 -sverilog \
			+define+UVM_PACKER_MAX_BYTES=1500000 \
			+define+UVM_DISABLE_AUTO_ITEM_RECORDING \
			+define+SVT_AMBA_INCLUDE_CHI_IN_AMBA_SYS_ENV \
			+define+SVT_AMBA_EXCLUDE_AXI_IN_CHI_SYS_ENV \
			+define+SVT_AMBA_OPTIMIZED_COMPILE -timescale=1ps/1ps \
			+plusarg_save -debug_access+pp+dmptf+thread+all \
			-debug_region=cell+encrypt -notice +define+SVT_UVM_TECHNOLOGY \
			+define+UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE \
			+define+SYNOPSYS_SV +incdir+$(PROJ_HOME)/rtl -V \
			-Mdir=$(BUILDDIR)/csrc \
			+lint=$(LINTS) \
			+warn=$(WARNS) \
			+incdir+$(PROJ_HOME)/rtl/design \
			-F $(PROJ_HOME)/rtl/design/top.flist \
			+incdir+$(PROJ_HOME)/rtl/models/memories/ \
			+incdir+$(PROJ_HOME)/rtl/placeholders \
			+incdir+$(TB_SRC)/common/lib_tb/addr_trans_mgr \
			+incdir+$(TB_SRC)/seq \
			+incdir+$(TB_SRC)/vseq \
			+incdir+$(TB_SRC)/tests \
			+incdir+$(TB_SRC)/utils \
			+incdir+$(TB_SRC)/env \
			+incdir+$(TB_SRC)/tb \
			$(TB_SRC)/tb/ncore_system_tb_top.sv 

RUN_CMD = $(BUILDDIR)/simv $(PLUSARGS) +UVM_VERBOSITY=$(UVM_VERBOSITY) \
			+UVM_MAX_QUIT_COUNT=1 \
			+UVM_TIMEOUT=$(UVM_TIMEOUT) \
			+vcs+lic+wait +verbose=$(DEBUG) \
			+ntb_random_seed=$(SEED) $(RUN_ARG) -reportstats -l vcs.log

# TARGETS
.PHONY: build all run clean $(TESTS) ncore_ral_bit_bash_test ncore_fsc_ral_bit_bash_test

# build the model, this is the default
build:
	mkdir -p $(BUILDDIR)
	mkdir -p $(RUNDIR)
	$(BUILD_CMD) -l $(BUILDDIR)/compile.log -o $(BUILDDIR)/simv

# Pattern rule target to run tests
$(TESTS) ncore_ral_bit_bash_test ncore_fsc_ral_bit_bash_test:
	@if echo $(TESTS) | grep -qw  "$@" || [ "$@" = "ncore_ral_bit_bash_test" ] || [ "$@" = "ncore_fsc_ral_bit_bash_test" ]; then \
		mkdir -p $(RUNDIR)/$@; \
		cd $(RUNDIR)/$@ && $(RUN_CMD) +UVM_TESTNAME=$@ $(OPTS); \
	fi

# Pattern rule to handle everything else
%:
	@if [ "$@" != "valid" ] && [ "$@" != "help" ]; then \
		echo ""; \
		echo "\"$@\" is not a valid test for this configuration."; \
	fi
	@echo ""
	@echo "valid tests for this configuration are:"
	@echo ""
	@echo $(TESTS) | tr ' ' '\n'
	@echo "ncore_ral_bit_bash_test"
	@echo "ncore_fsc_ral_bit_bash_test"
	@echo ""
	@echo "(note, there is no extension)"
	@echo ""
	@echo "besides tests above, valid targets are:"
	@echo ""
	@echo "build - build the model"
	@echo "run - run all tests but long running bit_bash_tests"
	@echo "all - build and run targets"
	@echo "clean - clean the build/ and run/ directories"
	@echo ""

# composite targets
run: $(TESTS)
	echo ""
	echo "NOTE: ncore_<ral|fsc>_bit_bash_test are long-running tests and are not run"
	echo "by this target.  Type 'make ncore_<ral|fsc>_bit_bash_test' to run directly"

all: build run

# clean all prior builds/runs
clean:
	rm -Rf $(RUNDIR) $(BUILDDIR)
