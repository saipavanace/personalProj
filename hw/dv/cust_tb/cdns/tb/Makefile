# extracted config parameters
PROJ_NAME	= <%=obj.strProjectName%>
HAS_RESIL	= <%=obj.useResiliency%>

# make variables
DUMP		?= 0
PLUSARGS 	= 
RUN_ARG		= 
ifeq ($(DUMP),1)
    RUN_ARG += +en_dump
endif
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

# UVM parameters
UVM_TIMEOUT ?= <%=obj.nDVEs + obj.nDCEs + obj.nDMIs + obj.nDIIs + obj.AiuInfo.length%>0000000000
UVM_VERBOSITY ?= UVM_NONE

# options for tests that need them, define the variable as blank for those that don't
OPTS =
ncore_bandwidth_test: OPTS = +performance_test
ncore_bandwidth_test_multi: OPTS = +performance_test
ncore_cache_access_test: OPTS = +performance_test +producer_consumer_m2_order
ncore_fsc_Uncorr_Error_test: OPTS = +inject_uncorrectable_error
ncore_snoop_test: OPTS = +performance_test

# check for needed environment variables and prompt if missing
ifndef PROJ_HOME 
    $(error PROJ_HOME undefined. please point to RTL path and rerun )
endif

ifndef CDS_INST_DIR 
    $(error CDS_INST_DIR undefined. It must point to xrun executable. please define this and make again)
endif

ifndef CDN_VIP_ROOT
	$(info CDN_VIP_ROOT undefined. It must point to the Cadence VIP source.)
	$(error Please define CDN_VIP_ROOT and make again)
endif

ifndef CDN_VIP_LIB_PATH 
	$(info CDN_VIP_LIB_PATH undefined. It must point to Cadence VIP working directory.)
	$(error Please define CDN_VIP_LIB_PATH and make again )
endif

# Cadence specific environment variables
export SPECMAN_PATH := $(CDN_VIP_ROOT)/packages:$(CDN_VIP_LIB_PATH)/64bit
export DENALI := $(CDN_VIP_ROOT)/tools.lnx86/denali_64bit
export UVM_HOME := $(CDS_INST_DIR)/tools/methodology/UVM/CDNS-1.2/sv
export CADENCE_VIP_LIC_Q_TIMEOUT := -1
export CADENCE_VIP_LIC_Q_ONLY_WHEN_ALL_IN_USE := 0
# export UVC_MSI_MODE := 1
export LD_LIBRARY_PATH := $(CDN_VIP_LIB_PATH)/64bit:$(DENALI)/verilog:$(CDS_INST_DIR)/tools.lnx86/specman/lib/64bit:$(CDS_INST_DIR)/bin:$(CDS_INST_DIR)/tools.lnx86/lib/64bit:$(LD_LIBRARY_PATH)
export PATH := $(CDS_INST_DIR)/tools.lnx86/bin/64bit:$(CDN_VIP_ROOT)/tools.lnx86/bin/64bit:$(CDS_INST_DIR)/bin:$(CDS_INST_DIR)/tools.lnx86/bin/64bit/simvision:$(PATH)

# directories
TB_SRC 		= $(PROJ_HOME)/tb/xsim
BUILDDIR 	= $(TB_SRC)/build
RUNDIR 		= $(TB_SRC)/run

# the actual build command for this simulator

BUILD_CMD 	= xrun -allowredefinition -64 -mess -sv -uvm -uvmhome CDNS-1.2 \
			-timescale 1ps/1ps \
			+define+DENALI_SV_NC \
			+defineall+CDN_ACE \
			+define+DENALI_UVM  \
			-access +rw \
			-loadvpi $(DENALI)/verilog/libcdnsv.so:cdnsvVIP:export \
			-incdir $(DENALI)/ddvapi/sv \
			$(DENALI)/ddvapi/sv/denaliMem.sv \
			$(DENALI)/ddvapi/sv/denaliCdn_axi.sv \
			-incdir $(DENALI)/ddvapi/sv/uvm/cdn_axi \
			$(DENALI)/ddvapi/sv/uvm/cdn_axi/cdnAxiUvmTop.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_axi/cb_interfaces/cdnAceFullInterface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_axi/cb_interfaces/cdnAceLiteDvmInterface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_axi/cb_interfaces/cdnAceLiteInterface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_axi/cb_interfaces/cdnAxi4Interface.sv \
			-incdir $(DENALI)/ddvapi/sv/uvm/chi \
			$(DENALI)/ddvapi/sv/denaliChi.sv \
			$(DENALI)/ddvapi/sv/uvm/chi/cdnChiUvmTop.sv \
			-incdir $(DENALI)/ddvapi/sv/hdl_interfaces/chi/ \
			$(DENALI)/ddvapi/sv/hdl_interfaces/chi/chi_B_Interface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/chi/chi_E_Interface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/chi/chiInterface_Rn2Hn_FD.sv \
            $(DENALI)/ddvapi/sv/denaliCdn_apb.sv \
			-incdir $(DENALI)/ddvapi/sv/uvm/cdn_apb \
			$(DENALI)/ddvapi/sv/uvm/cdn_apb/cdnApbUvmTop.sv \
			-incdir $(DENALI)/ddvapi/sv/hdl_interfaces/cdn_apb/ \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_apb/cdnApbMacros.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_apb/cdnApb3Interface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_apb/cb_interfaces/cdnApb3Interface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_apb/cdnApb4Interface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_apb/cb_interfaces/cdnApb4Interface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_axi/cb_interfaces/cdnAce5LiteDvmInterface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_axi/cb_interfaces/cdnAce5LiteInterface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_axi/cb_interfaces/cdnAce5FullInterface.sv \
            $(DENALI)/ddvapi/sv/hdl_interfaces/cdn_axi/cb_interfaces/cdnAce5LiteDvmInterface.sv \
			$(DENALI)/ddvapi/sv/hdl_interfaces/cdn_axi/cb_interfaces/cdnAxi5Interface.sv \
            +define+UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE \
			+define+DUMP_ON \
			+define+CDN_AUTO_TEST  \
			-snprerun notest \
			-snnoauto \
            $(CDN_VIP_LIB_PATH)/64bit/ncsim_psui.sv  \
			-nbasync \
			+define+CDN_AXI_USING_CLOCKING_BLOCK \
			+define+CHI_USING_CLOCKING_BLOCK \
			-licqueue  \
            -elaborate \
			-top tb_top \
			+incdir+$(TB_SRC) \
			+incdir+$(TB_SRC)/common/lib_tb/addr_trans_mgr \
			+incdir+$(TB_SRC)/seq \
			+incdir+$(TB_SRC)/vseq \
			+incdir+$(TB_SRC)/tests \
			+incdir+$(TB_SRC)/utils \
			+incdir+$(TB_SRC)/env \
			+incdir+$(TB_SRC)/tb \
			+incdir+$(PROJ_HOME)/rtl \
			+incdir+$(PROJ_HOME)/rtl/design \
			+incdir+$(PROJ_HOME)/rtl/models/memories/ \
            +incdir+$(PROJ_HOME)/rtl/placeholders \
            -F $(PROJ_HOME)/rtl/design/top.flist \
            -l $(BUILDDIR)/compile.log \
			-xmlibdirpath $(BUILDDIR) \
			$(TB_SRC)/tb/ncore_system_tb_top.sv

# the actual run command for this simulator
RUN_CMD 	= xrun -snprerun notest \
			-licqueue \
            $(PLUSARGS) \
			+UVM_MAX_QUIT_COUNT=1 \
			+UVM_TIMEOUT=$(UVM_TIMEOUT) \
			-l xrun.log \
			-64 \
			+UVM_VERBOSITY=$(UVM_VERBOSITY) \
			-xmlibdirname $(BUILDDIR)/xcelium.d \
			$(RUN_ARG) \
			-xmsimargs "-loadrun $(CDN_VIP_LIB_PATH)/64bit/libcdnvipcuvm.so" \
			-R \
			-xmfatal SVRNDF \
			-perfstat

# TARGETS
.PHONY: build all run clean $(TESTS) ncore_ral_bit_bash_test ncore_fsc_ral_bit_bash_test

# build the model, this is the default
build:
	mkdir -p $(BUILDDIR)
	mkdir -p $(RUNDIR)
	$(BUILD_CMD)

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

