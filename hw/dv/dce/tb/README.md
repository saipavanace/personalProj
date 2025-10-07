# Concerto DCE Design Verifcation

## Instructions for DCE Testbench compile and run

source /home/boon/tool_setup.cshrc

setenv WORK_TOP /home/boon/hw_repo/hw

cd /home/boon/hw_repo/hw/dv/dce

### DCE RTL Regression tests

make -f Makefile.vcs comp_rtl | tee compile_rtl.log

./simv +UVM_TESTNAME=dce_test +k_num_addr=600 +k_num_cmd=60 +wt_cmd_rd_cpy=60 +wt_cmd_rd_vld=60 +wt_cmd_rd_unq=60 +wt_cmd_rd_cln=60 +wt_cmd_cln_unq=0 +wt_cmd_cln_vld=0 +wt_cmd_cln_inv=0 +wt_cmd_wr_unq_ptl=60 +wt_cmd_wr_unq_full=60 +wt_cmd_upd_vld=0 +wt_cmd_upd_inv=0 +wt_cmd_dvm_msg=0 +k_init_rand_state=0 +ntb_random_seed=1234 +k_timeout_usec=600 +k_force_req_aiu0=1 +UVM_MAX_QUIT_COUNT=1 | tee dce.log

### DCE Regression tests

make -f Makefile.vcs comp | tee compile.log

./simv +UVM_TESTNAME=dce_test +ntb_random_seed=`date +%N` +UVM_MAX_QUIT_COUNT=1 +k_num_addr=8 +k_num_cmd=2000 | tee sim1.log

./simv +UVM_TESTNAME=dce_graph_test +ntb_random_seed=`date +%N` +UVM_MAX_QUIT_COUNT=1 | tee sim2.log

./simv +UVM_TESTNAME=dce_graph_search_test +ntb_random_seed=`date +%N` +UVM_MAX_QUIT_COUNT=1 | tee sim3.log

## UVM command line setting

+UVM_MAX_QUIT_COUNT=N

so as to set the max quit count to N, which causes the first N error to quit the simulation. 

## Knobs for DCE Testbench

To specify the timeout value in usec:

  k_timeout_usec

To specify the number of CMDreq messages:

  k_num_cmd

To specify the number of cache addresses:

  k_num_addr

To specify if the initial states of AIUs should be randomized or not (default is randomized):

  k_init_rand_state

To specify if the AIU_nCMDInflight feature (to prevent any AIU from hogging DCE) is to be enabled or not (default not):

  k_aiucmdinflight_enb

To specify the maximum number of reorder responses, and the timer window (in terms of clock cycles) for accumulating responses for reorder:

  k_reorder_rsp_max

  k_reorder_rsp_tmr

To specify the delay on the DUT SFI slave request interface:

  k_req_vld_delay_min

  k_req_vld_delay_max

  k_req_vld_burst_pct

To specify the delay on the DUT SFI master request interface:

  k_req_rdy_delay_min

  k_req_rdy_delay_max

  k_req_rdy_burst_pct

To specify the delay on the DUT SFI master response interface:

  k_rsp_vld_delay_min

  k_rsp_vld_delay_max

  k_rsp_vld_burst_pct

To specify the delay on the DUT SFI slave response interface:

  k_rsp_rdy_delay_min

  k_rsp_rdy_delay_max

  k_rsp_rdy_burst_pct

To specify the weightage for each of CMDreq messages:

  wt_cmd_rd_cpy

  wt_cmd_rd_cln

  wt_cmd_rd_vld

  wt_cmd_rd_unq

  wt_cmd_cln_unq

  wt_cmd_cln_vld

  wt_cmd_cln_inv

  wt_cmd_wr_unq_ptl

  wt_cmd_wr_unq_full

  wt_cmd_upd_inv

  wt_cmd_upd_vld

  wt_cmd_dvm_msg

### Usage Examples:

./simv +UVM_TESTNAME=dce_test +k_num_addr=2 +k_num_cmd=20 +wt_cmd_rd_cpy=30 +wt+cmd_rd_cln=30 +wt_cmd_rd_vld=20 +wt_cmd_rd_unq=20 +wt_cmd_cln_unq=0 +wt_cmd_cln_vld=0 +wt_cmd_cln_inv=0 +wt_cmd_wr_unq_ptl=0 +wt_cmd_wr_unq_full=0 +wt_cmd_upd_inv=0 +wt_cmd_upd_vld=0

./simv +UVM_TESTNAME=dce_graph_test +ntb_random_seed=1234 +k_timeout_usec=50000

