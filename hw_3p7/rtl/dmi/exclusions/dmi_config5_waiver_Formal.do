#
#
# Generated Exclusion File
#
#

#
#Top module prefixes
#tb_top/dut
#

#
#  CoverCheck Exclude Summary
#-----------------------------------------------------
#  Coverage Type      Targeted         UNR    Excluded
#  Branch                 5020           0           0 (0%)
#  Condition               523           0           0 (0%)
#  Expression           118393        1416        1416 (1%)
#  FSM State                 0           0           0
#  FSM Transition            0           0           0
#  Statement               944         166         166 (17%)
#  Toggle                    0           0           0
#  Coverbin                  0           0           0


# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/arb_comb_e.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb1} -linerange 55 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/arb_comb_e.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb0} -linerange 55 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/arb_comb_e.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb1} -linerange 55 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/cam_fifo_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_bank0/control_queue} -linerange 152 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/cam_fifo_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_bank0/control_queue} -linerange 152 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/ccp_datapipe_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe} -linerange 654 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/ccp_datapipe_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe} -linerange 670 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/ccp_datapipe_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe} -linerange 654 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/ccp_datapipe_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe} -linerange 670 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/ccp_dualport_fifo_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_dout/rdrsp_control_fifo} -linerange 75 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/ccp_dualport_fifo_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_dout/rdrsp_control_fifo} -linerange 75 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/dmi_c_write_buffer_a.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/c_write_buffer} -linerange 117 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/dmi_c_write_buffer_a.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/c_write_buffer} -linerange 117 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/dmi_nc_write_buffer_a.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/nc_write_buffer} -linerange 122 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/dmi_nc_write_buffer_a.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/nc_write_buffer} -linerange 122 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/dmi_transaction_control_a.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_transaction_control} -linerange 1175 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/dmi_transaction_control_a.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_transaction_control} -linerange 1186 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/dmi_transaction_control_a.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_transaction_control} -linerange 1175 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/dmi_transaction_control_a.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_transaction_control} -linerange 1186 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_a.v
coverage exclude -scope {/tb_top/dut/trace_capture/smi_rx0_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_a.v
coverage exclude -scope {/tb_top/dut/trace_capture/smi_tx0_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_af.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_af.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_rx0_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_rx0_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_rx1_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx2_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_rx1_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx2_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx3_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx3_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aj.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_rx3_dp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aj.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx3_dp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aj.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_rx3_dp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aj.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx3_dp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ak.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_rx3_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ak.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_rx3_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aq.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_aq.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_b.v
coverage exclude -scope {/tb_top/dut/trace_capture/smi_rx1_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_b.v
coverage exclude -scope {/tb_top/dut/trace_capture/smi_rx2_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_b.v
coverage exclude -scope {/tb_top/dut/trace_capture/smi_tx1_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_b.v
coverage exclude -scope {/tb_top/dut/trace_capture/smi_tx2_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bc.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bc.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bd.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bd.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_be.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_be.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bg.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bg.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bh.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bh.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bi.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bi.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bj.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bj.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bl.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_output_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bl.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_output_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bm.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/nc_cmd_resp_buffer/fifo} -linerange 318 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bm.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/nc_cmd_resp_buffer/fifo} -linerange 318 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bn.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_input_fifo/fifo} -linerange 1774 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bn.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_input_fifo/fifo} -linerange 1774 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bo.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_output_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bo.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_output_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bt.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/rbr_resp_buffer/fifo} -linerange 1774 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bt.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/rbr_resp_buffer/fifo} -linerange 1774 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bv.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/dtr_rsp_match_fifo/fifo} -linerange 318 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bv.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/dtr_rsp_match_fifo/fifo} -linerange 318 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bw.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/dtr_rsp_no_match_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bw.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/dtr_rsp_no_match_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_by.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/trans_id_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_by.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/trans_id_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_c.v
coverage exclude -scope {/tb_top/dut/trace_capture/smi_rx3_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_c.v
coverage exclude -scope {/tb_top/dut/trace_capture/smi_tx3_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ca.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_transaction_control/read_trans_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ca.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_transaction_control/read_trans_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cb.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_transaction_control/read_data_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cb.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_transaction_control/read_data_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cc.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_transaction_control/write_trans_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cc.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_transaction_control/write_trans_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cd.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/evict_buffer/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cd.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_transaction_control/write_res_data_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cd.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/evict_buffer/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cd.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_transaction_control/write_res_data_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ce.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_transaction_control/write_resp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ce.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_transaction_control/write_resp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_transaction_control/dmi_merge_engine/req_out_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_transaction_control/dmi_merge_engine/req_out_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cg.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_transaction_control/dmi_merge_engine/mem_req_in_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cg.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_transaction_control/dmi_merge_engine/mem_req_in_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ch.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_native_interface/ar_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ch.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_native_interface/aw_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ch.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_native_interface/ar_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ch.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_native_interface/aw_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ci.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_native_interface/w_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ci.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_native_interface/w_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cj.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_native_interface/r_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cj.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_native_interface/r_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ck.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_native_interface/b_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ck.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_native_interface/b_fifo/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cw.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/c_write_buffer/data_fifo/mem_data_fifo} -linerange 165 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cw.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/c_write_buffer/data_fifo/mem_data_fifo} -linerange 165 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cx.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/c_write_buffer/data_fifo/mem_data_uce_fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cx.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/c_write_buffer/data_fifo/mem_data_uce_fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cy.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/write_data_buffer/input_data} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_cy.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/write_data_buffer/input_data} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_db.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/read_hit/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_db.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/read_hit/fifo} -linerange 162 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dc.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_transaction_control/dmi_merge_engine/mem_data_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dc.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_transaction_control/dmi_merge_engine/merge_result_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dc.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_transaction_control/dmi_merge_engine/mem_data_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dc.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_transaction_control/dmi_merge_engine/merge_result_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dj.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/write_bypass_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dj.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/write_bypass_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dk.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/write_control_fifo} -linerange 318 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dk.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/write_control_fifo} -linerange 318 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_do.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_dout/evict_port_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_do.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_dout/rdrsp_port_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_do.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_dout/evict_port_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_do.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_dout/rdrsp_port_fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dp.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_bank0/write_queue} -linerange 160 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dp.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_bank0/write_queue} -linerange 160 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dq.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_bank0/fill_queue} -linerange 160 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_dq.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_bank0/fill_queue} -linerange 160 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ds.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_dout/evict_control_fifo/order_fifo} -linerange 212 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ds.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_dout/rdrsp_control_fifo/order_fifo} -linerange 212 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ds.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_dout/evict_control_fifo/order_fifo} -linerange 212 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ds.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_datapipe/data_dout/rdrsp_control_fifo/order_fifo} -linerange 212 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_l.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/cmd_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_l.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/cmd_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_o.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/str_req_fifo} -linerange 318 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_o.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/str_req_fifo} -linerange 318 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_p.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/rb_use_fifo} -linerange 1774 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_q.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/wdata_sel_fifo} -linerange 188 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_q.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/wdata_sel_fifo} -linerange 188 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -linerange 88 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -linerange 99 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -linerange 132 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -linerange 88 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -linerange 99 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -linerange 88 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -linerange 99 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -linerange 132 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -linerange 88 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -linerange 99 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2623 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2623 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2625 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2625 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2658 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2658 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2660 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2660 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2693 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2693 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2695 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 2695 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 3559 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 3559 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 3563 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 3563 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 4658 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 4658 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 4676 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 4676 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 4921 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 4921 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 5815 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 5815 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 6060 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 6060 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 6180 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 6180 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 6182 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 6182 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 6657 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux} -fecexprrow 6657 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2623 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2623 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2625 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2625 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2658 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2658 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2660 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2660 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2693 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2693 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2695 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 2695 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 3559 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 3559 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 3563 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 3563 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 4676 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 4676 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 4921 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 4921 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 5815 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 5815 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 6060 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 6060 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 6180 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 6180 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 6182 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 6182 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 6657 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/concerto_mux_d.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux} -fecexprrow 6657 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_rsp_fifo/fifo} -fecexprrow 75 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_rsp_fifo/fifo} -fecexprrow 75 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bj.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_req_fifo/fifo} -fecexprrow 75 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bj.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_req_fifo/fifo} -fecexprrow 75 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bj.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_req_fifo/fifo} -fecexprrow 75 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_bj.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_req_fifo/fifo} -fecexprrow 75 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 67 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 67 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 67 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 67 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 73 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 73 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 75 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 75 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 75 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 75 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 110 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 110 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 110 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 110 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 117 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 117 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 117 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 117 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 73 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 73 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 75 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 75 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 75 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 75 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 67 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 67 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 67 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 67 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 73 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 73 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 74 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 75 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 75 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 75 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 75 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 110 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 110 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 110 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 110 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 117 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 117 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 117 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_rsp_fifo/fifo} -fecexprrow 117 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 73 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 73 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 75 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 75 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 75 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 75 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_aa.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 58 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 58 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 66 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ab.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_7} -fecexprrow 66 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 56 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 56 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ac.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ad.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 44 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ad.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 44 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ad.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 44 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ad.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 44 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ad.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 44 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ad.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_0_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 44 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ad.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 44 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ad.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_1_data_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 44 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 24 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 24 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 25 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 25 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 25 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 25 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 25 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 25 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 24 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 24 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 25 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 25 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 25 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 25 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 25 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 25 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 25 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 25 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 25 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ah.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 25 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_ai.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx3_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_au.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbu_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 33 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 33 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_bf.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_6} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtr_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx0_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/smi_tx1_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 29 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 29 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_w.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/str_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_x.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_5} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/mrd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_y.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_0} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_1} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_2} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_dbg_req_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/dtw_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_4} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/nc_cmd_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/logic_tree_z.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_concerto_mux/rbr_rsp_prot_interface/u_ecc_enc_0_0/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 815 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 815 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 815 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 815 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 817 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 817 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 817 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 817 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 827 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 827 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 827 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 827 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 828 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 828 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 828 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 828 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 815 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 815 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 815 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 815 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 817 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 817 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 817 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 817 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 827 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 827 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 827 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 827 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 828 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 828 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 828 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_b.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/cmd_skid_buffer} -fecexprrow 828 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2167 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2167 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2167 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2167 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2169 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2169 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2169 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2169 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2179 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2179 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2179 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2179 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2180 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2180 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2180 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2180 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2167 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2167 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2167 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2167 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2169 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2169 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2169 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2169 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2179 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2179 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2179 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2179 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2180 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2180 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2180 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/pri_age_buffer_arbiter_c.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_protocol_control/mrd_skid_buffer} -fecexprrow 2180 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb0/u_park_point_therm} -fecexprrow 91 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb0/u_park_point_therm} -fecexprrow 91 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb0/u_park_point_therm} -fecexprrow 91 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb0/u_park_point_therm} -fecexprrow 91 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb1/u_park_point_therm} -fecexprrow 91 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb1/u_park_point_therm} -fecexprrow 91 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb1/u_park_point_therm} -fecexprrow 91 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dmi_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb1/u_park_point_therm} -fecexprrow 91 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb0/u_park_point_therm} -fecexprrow 91 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb0/u_park_point_therm} -fecexprrow 91 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb0/u_park_point_therm} -fecexprrow 91 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb0/u_park_point_therm} -fecexprrow 91 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb1/u_park_point_therm} -fecexprrow 91 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb1/u_park_point_therm} -fecexprrow 91 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb1/u_park_point_therm} -fecexprrow 91 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/jasonv/ncore_env_3.4_CodeCovAllinOneCmd/hw-ncr/regression/2023_01_06_1402/debug/dmi/config5/rtl/thermo_fast_f.v
coverage exclude -scope {/tb_top/dut/dup_unit/dmi_resource_control/dmi_cache_wrap/dmi_ccp/u_ccp/u_tagpipe/u_replacement_policy/u_priority_arb1/u_park_point_therm} -fecexprrow 91 4 -item 1 -reason "EU"
