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
#  Branch                  298          55          55 (18%)
#  Condition                43           4           4 (9%)
#  Expression             4436        1482        1482 (33%)
#  FSM State                 0           0           0
#  FSM Transition            0           0           0
#  Statement               167          31          31 (18%)
#  Toggle                    0           0           0
#  Coverbin                  0           0           0


# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/arb_comb_h.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_rr_arb/u_arb} -linerange 49 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem0_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem1_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/rd_ptr_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/wr_ptr_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ai.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmd_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ak.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmp_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 88 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 99 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ao.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ar.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx0_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ar.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_as.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx1_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_as.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_av.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_aw.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ax.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ax.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ay.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ay.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_bx.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_dp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_dk.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 395 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 106 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 108 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 122 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -feccondrow 188 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -feccondrow 188 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -feccondrow 188 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -feccondrow 188 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -feccondrow 614 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -feccondrow 614 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -feccondrow 158 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -feccondrow 158 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_11_1} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_11_1} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_11_1} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_11_1} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_2_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_2_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_2_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_2_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_3_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_3_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_3_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_3_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_4_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_4_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_4_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_4_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_5_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_5_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_5_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_5_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_10_1} -fecexprrow 12 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_10_1} -fecexprrow 12 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_10_1} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_10_1} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_10_1} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_10_1} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_10_1} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_10_1} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_12_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_12_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_12_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_12_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_12_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_12_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_16_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_16_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_16_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_3_16_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_11_1} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_11_1} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_11_1} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_11_1} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_2_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_2_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_2_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_2_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_3_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_3_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_3_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_3_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_4_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_4_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_4_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_4_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_5_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_5_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_5_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_5_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_10_1} -fecexprrow 12 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_10_1} -fecexprrow 12 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_10_1} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_10_1} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_10_1} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_10_1} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_10_1} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_10_1} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_12_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_12_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_12_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_12_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_12_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_12_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_16_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_16_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_16_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_3_16_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_11_1} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_11_1} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_11_1} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_11_1} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_2_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_2_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_2_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_2_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_3_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_3_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_3_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_3_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_4_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_4_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_4_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_4_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_5_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_5_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_5_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_5_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_10_1} -fecexprrow 12 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_10_1} -fecexprrow 12 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_10_1} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_10_1} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_10_1} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_10_1} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_10_1} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_10_1} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_12_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_12_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_12_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_12_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_12_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_12_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_16_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_16_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_16_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_3_16_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_11_1} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_11_1} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_11_1} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_11_1} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_2_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_2_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_2_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_2_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_3_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_3_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_3_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_3_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_4_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_4_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_4_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_4_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_5_2} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_5_2} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_5_2} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_5_2} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_10_1} -fecexprrow 12 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_10_1} -fecexprrow 12 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_10_1} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_10_1} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_10_1} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_10_1} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_10_1} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_10_1} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_12_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_12_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_12_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_12_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_12_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_12_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_13_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_13_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_13_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_13_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_13_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_13_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_14_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_14_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_14_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_14_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_14_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_14_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_15_0} -fecexprrow 12 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_15_0} -fecexprrow 12 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_15_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_15_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_15_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_15_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_16_0} -fecexprrow 13 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_16_0} -fecexprrow 13 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_16_0} -fecexprrow 13 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_2bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_3_16_0} -fecexprrow 13 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_0_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_10_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_13_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_13_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_13_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_13_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_13_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_13_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_1_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_2_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_2_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_2_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_2_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_2_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_2_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_4_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_4_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_5_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_5_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_5_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_5_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_5_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_5_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_6_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_6_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_6_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_6_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_6_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_6_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_7_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_7_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_7_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_7_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_7_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_7_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_8_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_0_9_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_0_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_0_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_0_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_0_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_0_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_0_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_1_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_2_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_2_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_2_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_2_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_2_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_2_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_3_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_3_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_3_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_3_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_3_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_3_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_4_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_4_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_4_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_4_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_4_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_4_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_5_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_5_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_5_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_5_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_5_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_5_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_6_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_6_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_6_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_6_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_6_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_6_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_7_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_7_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_7_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_7_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_7_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_7_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_8_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_8_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_8_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_8_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_8_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_8_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_9_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_9_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_9_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_9_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_9_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_1_9_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_10_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_10_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_10_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_10_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_1_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_1_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_1_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_1_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_2_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_2_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_3_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_3_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_4_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_4_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_5_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_5_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_6_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_6_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_7_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_7_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_8_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_8_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_9_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder_2_9_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_0_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_10_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_13_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_13_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_13_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_13_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_13_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_13_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_1_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_2_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_2_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_2_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_2_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_2_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_2_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_4_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_4_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_5_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_5_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_5_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_5_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_5_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_5_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_6_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_6_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_6_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_6_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_6_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_6_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_7_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_7_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_7_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_7_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_7_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_7_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_8_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_0_9_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_0_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_0_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_0_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_0_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_0_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_0_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_1_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_2_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_2_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_2_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_2_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_2_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_2_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_3_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_3_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_3_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_3_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_3_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_3_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_4_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_4_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_4_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_4_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_4_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_4_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_5_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_5_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_5_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_5_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_5_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_5_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_6_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_6_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_6_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_6_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_6_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_6_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_7_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_7_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_7_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_7_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_7_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_7_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_8_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_8_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_8_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_8_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_8_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_8_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_9_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_9_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_9_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_9_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_9_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_1_9_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_10_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_10_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_10_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_10_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_1_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_1_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_1_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_1_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_2_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_2_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_3_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_3_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_4_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_4_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_5_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_5_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_6_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_6_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_7_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_7_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_8_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_8_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_9_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder_2_9_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_0_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_10_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_13_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_13_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_13_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_13_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_13_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_13_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_1_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_2_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_2_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_2_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_2_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_2_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_2_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_4_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_4_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_5_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_5_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_5_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_5_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_5_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_5_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_6_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_6_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_6_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_6_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_6_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_6_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_7_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_7_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_7_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_7_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_7_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_7_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_8_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_0_9_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_0_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_0_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_0_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_0_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_0_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_0_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_1_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_2_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_2_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_2_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_2_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_2_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_2_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_3_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_3_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_3_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_3_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_3_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_3_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_4_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_4_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_4_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_4_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_4_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_4_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_5_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_5_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_5_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_5_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_5_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_5_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_6_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_6_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_6_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_6_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_6_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_6_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_7_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_7_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_7_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_7_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_7_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_7_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_8_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_8_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_8_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_8_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_8_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_8_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_9_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_9_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_9_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_9_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_9_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_1_9_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_10_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_10_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_10_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_10_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_1_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_1_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_1_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_1_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_2_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_2_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_3_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_3_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_4_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_4_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_5_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_5_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_6_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_6_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_7_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_7_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_8_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_8_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_9_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder_2_9_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_0_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_10_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_13_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_13_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_13_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_13_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_13_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_13_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_1_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_2_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_2_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_2_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_2_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_2_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_2_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_4_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_4_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_5_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_5_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_5_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_5_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_5_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_5_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_6_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_6_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_6_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_6_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_6_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_6_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_7_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_7_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_7_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_7_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_7_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_7_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_8_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_0_9_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_0_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_0_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_0_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_0_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_0_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_0_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_1_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_2_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_2_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_2_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_2_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_2_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_2_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_3_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_3_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_3_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_3_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_3_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_3_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_4_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_4_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_4_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_4_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_4_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_4_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_5_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_5_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_5_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_5_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_5_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_5_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_6_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_6_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_6_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_6_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_6_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_6_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_7_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_7_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_7_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_7_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_7_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_7_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_8_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_8_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_8_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_8_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_8_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_8_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_9_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_9_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_9_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_9_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_9_1} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_1_9_1} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_10_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_10_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_10_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_10_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_10_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_10_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_11_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_11_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_11_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_11_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_11_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_11_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_12_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_12_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_12_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_12_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_12_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_12_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_1_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_1_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_1_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_1_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_1_0} -fecexprrow 17 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_1_0} -fecexprrow 17 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_2_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_2_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_3_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_3_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_4_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_4_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_5_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_5_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_6_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_6_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_7_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_7_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_8_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_8_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_9_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_3bit_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder_2_9_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_10} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_10} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_10} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_10} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_10} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_10} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_11} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_11} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_11} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_11} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_11} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_11} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_12} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_12} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_12} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_12} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_12} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_12} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_13} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_13} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_13} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_13} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_13} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_13} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_13} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c0_13} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_10} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_10} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_10} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_10} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_10} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_10} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_11} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_11} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_11} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_11} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_11} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_11} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_12} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_12} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_12} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_12} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_12} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_12} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_13} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_13} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_13} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_13} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_13} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_13} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_13} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_adder_full_c1_13} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_10} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_10} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_10} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_10} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_10} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_10} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_11} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_11} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_11} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_11} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_11} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_11} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_12} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_12} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_12} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_12} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_12} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_12} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_13} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_13} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_13} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_13} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_13} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_13} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_13} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c0_13} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_10} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_10} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_10} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_10} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_10} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_10} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_11} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_11} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_11} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_11} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_11} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_11} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_12} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_12} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_12} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_12} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_12} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_12} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_13} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_13} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_13} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_13} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_13} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_13} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_13} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_adder_full_c1_13} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_10} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_10} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_10} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_10} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_10} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_10} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_11} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_11} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_11} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_11} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_11} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_11} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_12} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_12} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_12} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_12} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_12} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_12} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_13} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_13} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_13} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_13} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_13} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_13} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_13} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c0_13} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_10} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_10} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_10} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_10} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_10} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_10} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_11} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_11} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_11} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_11} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_11} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_11} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_12} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_12} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_12} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_12} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_12} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_12} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_13} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_13} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_13} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_13} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_13} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_13} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_13} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_adder_full_c1_13} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_10} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_10} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_10} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_10} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_10} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_10} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_11} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_11} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_11} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_11} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_11} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_11} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_12} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_12} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_12} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_12} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_12} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_12} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_13} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_13} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_13} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_13} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_13} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_13} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_13} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c0_13} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_10} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_10} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_10} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_10} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_10} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_10} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_11} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_11} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_11} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_11} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_11} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_11} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_12} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_12} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_12} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_12} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_12} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_12} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_13} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_13} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_13} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_13} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_13} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_13} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_13} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/adder_full_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_adder_full_c1_13} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 927 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 927 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 992 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 992 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1019 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1019 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1049 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1049 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1080 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1080 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1085 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1085 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1085 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1085 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1116 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1116 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1141 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1141 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1174 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1174 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1208 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1208 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1242 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1242 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1271 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1271 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1274 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1274 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1274 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1274 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1305 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1305 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1330 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1330 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1359 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1359 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1385 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1385 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1421 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1421 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1430 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1430 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1466 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1466 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1475 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1475 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1511 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1511 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1520 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1520 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1556 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1556 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1565 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1565 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1592 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1592 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1618 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1618 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1644 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1644 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1670 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1670 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1696 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1696 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1722 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1722 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1748 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1748 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1774 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -fecexprrow 1774 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -fecexprrow 158 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -fecexprrow 158 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -fecexprrow 158 9 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -fecexprrow 158 10 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -fecexprrow 192 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -fecexprrow 192 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -fecexprrow 192 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_pipe_e.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr/u_apb_pipe} -fecexprrow 192 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/concerto_mux_k.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux} -fecexprrow 2781 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/concerto_mux_k.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux} -fecexprrow 2781 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 660 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 660 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 788 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 788 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 788 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 788 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 806 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 806 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 806 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 806 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 824 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 824 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 824 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 824 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 842 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 842 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 842 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 842 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 860 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 860 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 860 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 860 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 878 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 878 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 878 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 878 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 896 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 896 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 896 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 896 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 914 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 914 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 914 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 914 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 945 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 945 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 983 13 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 983 14 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 445 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 445 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 446 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 446 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 450 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 450 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 451 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 451 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 456 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 456 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 461 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 461 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 490 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 490 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 490 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 490 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 495 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 495 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 495 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 495 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 499 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 499 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 499 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 499 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 500 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 500 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 500 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 500 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 504 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 504 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 504 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 504 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 505 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 505 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 505 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 505 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 513 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 513 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 513 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 513 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 514 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 514 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 518 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 518 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 518 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 518 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 519 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 519 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 523 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 523 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 523 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 523 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 524 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 524 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 528 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 528 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 528 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 528 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 529 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 529 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 9 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 10 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 13 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 14 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 15 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 16 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 653 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 653 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 9 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 10 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 704 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 704 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 67 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 73 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 73 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 74 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 110 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -fecexprrow 117 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_cy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_fifo} -fecexprrow 84 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_cy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_fifo} -fecexprrow 84 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_dm.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/strreq_fifo} -fecexprrow 212 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_dm.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/strreq_fifo} -fecexprrow 212 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_dn.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_dbg_fifo} -fecexprrow 84 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_dn.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_dbg_fifo} -fecexprrow 84 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 24 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 24 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 68 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 68 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 68 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_0} -fecexprrow 68 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 24 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 24 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 68 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 68 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 68 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_0} -fecexprrow 68 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 24 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 24 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 68 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 68 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 68 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_0} -fecexprrow 68 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 24 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 24 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 24 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 24 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 68 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 68 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 68 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_a.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_0} -fecexprrow 68 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 28 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 28 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 30 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 30 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 32 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 32 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 43 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 43 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 45 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 45 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 47 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 47 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 61 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 61 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 62 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 62 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 62 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 62 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 62 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_0_1} -fecexprrow 62 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 28 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 28 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 30 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 30 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 32 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 32 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 43 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 43 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 45 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 45 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 47 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 47 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 61 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 61 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 62 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 62 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 62 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 62 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 62 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt0/u_adder/u_cla_1_1} -fecexprrow 62 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 28 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 28 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 30 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 30 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 32 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 32 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 43 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 43 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 45 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 45 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 47 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 47 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 61 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 61 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 62 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 62 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 62 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 62 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 62 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_0_1} -fecexprrow 62 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 28 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 28 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 30 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 30 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 32 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 32 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 43 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 43 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 45 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 45 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 47 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 47 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 61 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 61 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 62 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 62 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 62 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 62 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 62 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt1/u_adder/u_cla_1_1} -fecexprrow 62 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 28 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 28 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 30 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 30 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 32 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 32 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 43 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 43 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 45 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 45 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 47 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 47 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 61 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 61 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 62 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 62 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 62 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 62 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 62 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_0_1} -fecexprrow 62 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 28 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 28 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 30 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 30 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 32 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 32 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 43 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 43 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 45 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 45 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 47 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 47 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 61 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 61 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 62 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 62 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 62 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 62 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 62 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt2/u_adder/u_cla_1_1} -fecexprrow 62 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 28 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 28 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 30 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 30 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 32 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 32 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 43 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 43 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 45 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 45 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 47 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 47 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 61 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 61 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 62 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 62 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 62 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 62 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 62 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_0_1} -fecexprrow 62 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 26 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 26 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 28 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 28 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 30 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 30 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 31 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 31 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 31 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 31 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 32 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 32 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 32 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 32 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 32 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 32 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 43 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 43 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 45 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 45 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 45 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 45 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 45 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 45 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 47 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 47 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 60 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 60 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 61 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 61 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 62 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 62 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 62 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 62 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 62 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ks_cla_b.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_lpf_CoreFilt3/u_adder/u_cla_1_1} -fecexprrow 62 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 42 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 42 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -fecexprrow 106 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -fecexprrow 106 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0LO} -fecexprrow 102 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0LO} -fecexprrow 102 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0LO} -fecexprrow 109 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0LO} -fecexprrow 109 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0LO} -fecexprrow 109 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0LO} -fecexprrow 109 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0LO} -fecexprrow 111 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0LO} -fecexprrow 111 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1LO} -fecexprrow 102 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1LO} -fecexprrow 102 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1LO} -fecexprrow 109 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1LO} -fecexprrow 109 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1LO} -fecexprrow 109 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1LO} -fecexprrow 109 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1LO} -fecexprrow 111 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1LO} -fecexprrow 111 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2LO} -fecexprrow 102 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2LO} -fecexprrow 102 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2LO} -fecexprrow 109 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2LO} -fecexprrow 109 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2LO} -fecexprrow 109 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2LO} -fecexprrow 109 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2LO} -fecexprrow 111 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2LO} -fecexprrow 111 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3LO} -fecexprrow 102 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3LO} -fecexprrow 102 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3LO} -fecexprrow 109 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3LO} -fecexprrow 109 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3LO} -fecexprrow 109 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3LO} -fecexprrow 109 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3LO} -fecexprrow 111 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_f.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3LO} -fecexprrow 111 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0HI} -fecexprrow 102 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0HI} -fecexprrow 102 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0HI} -fecexprrow 109 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0HI} -fecexprrow 109 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0HI} -fecexprrow 109 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount0HI} -fecexprrow 109 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1HI} -fecexprrow 102 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1HI} -fecexprrow 102 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1HI} -fecexprrow 109 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1HI} -fecexprrow 109 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1HI} -fecexprrow 109 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount1HI} -fecexprrow 109 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2HI} -fecexprrow 102 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2HI} -fecexprrow 102 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2HI} -fecexprrow 109 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2HI} -fecexprrow 109 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2HI} -fecexprrow 109 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount2HI} -fecexprrow 109 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3HI} -fecexprrow 102 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3HI} -fecexprrow 102 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3HI} -fecexprrow 109 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3HI} -fecexprrow 109 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3HI} -fecexprrow 109 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreCount3HI} -fecexprrow 109 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0} -fecexprrow 80 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0} -fecexprrow 80 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0} -fecexprrow 80 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0} -fecexprrow 80 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0} -fecexprrow 105 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0} -fecexprrow 105 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0} -fecexprrow 105 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0} -fecexprrow 105 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0} -fecexprrow 105 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0} -fecexprrow 105 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1} -fecexprrow 80 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1} -fecexprrow 80 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1} -fecexprrow 80 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1} -fecexprrow 80 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1} -fecexprrow 105 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1} -fecexprrow 105 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1} -fecexprrow 105 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1} -fecexprrow 105 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1} -fecexprrow 105 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1} -fecexprrow 105 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2} -fecexprrow 80 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2} -fecexprrow 80 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2} -fecexprrow 80 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2} -fecexprrow 80 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2} -fecexprrow 105 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2} -fecexprrow 105 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2} -fecexprrow 105 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2} -fecexprrow 105 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2} -fecexprrow 105 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2} -fecexprrow 105 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3} -fecexprrow 80 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3} -fecexprrow 80 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3} -fecexprrow 80 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3} -fecexprrow 80 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3} -fecexprrow 105 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3} -fecexprrow 105 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3} -fecexprrow 105 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3} -fecexprrow 105 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3} -fecexprrow 105 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3} -fecexprrow 105 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0} -fecexprrow 80 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0} -fecexprrow 80 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0} -fecexprrow 80 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0} -fecexprrow 80 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0} -fecexprrow 105 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0} -fecexprrow 105 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0} -fecexprrow 105 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0} -fecexprrow 105 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0} -fecexprrow 105 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0} -fecexprrow 105 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1} -fecexprrow 80 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1} -fecexprrow 80 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1} -fecexprrow 80 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1} -fecexprrow 80 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1} -fecexprrow 105 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1} -fecexprrow 105 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1} -fecexprrow 105 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1} -fecexprrow 105 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1} -fecexprrow 105 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1} -fecexprrow 105 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2} -fecexprrow 80 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2} -fecexprrow 80 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2} -fecexprrow 80 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2} -fecexprrow 80 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2} -fecexprrow 105 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2} -fecexprrow 105 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2} -fecexprrow 105 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2} -fecexprrow 105 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2} -fecexprrow 105 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2} -fecexprrow 105 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3} -fecexprrow 80 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3} -fecexprrow 80 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3} -fecexprrow 80 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3} -fecexprrow 80 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3} -fecexprrow 105 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3} -fecexprrow 105 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3} -fecexprrow 105 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3} -fecexprrow 105 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3} -fecexprrow 105 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_h.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3} -fecexprrow 105 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad0} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad0} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad0} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad0} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad0} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad0} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad1} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad1} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad1} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad1} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad1} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad1} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad2} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad2} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad2} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad2} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad2} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad2} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad3} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad3} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad3} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad3} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad3} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreLoad3} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt0} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt0} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt0} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt0} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt0} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt0} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt1} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt1} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt1} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt1} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt1} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt1} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt2} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt2} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt2} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt2} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt2} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt2} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt3} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt3} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt3} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt3} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt3} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreFilt3} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax0} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax0} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax0} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax0} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax0} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax0} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax1} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax1} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax1} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax1} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax1} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax1} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax2} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax2} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax2} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax2} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax2} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax2} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax3} -fecexprrow 101 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax3} -fecexprrow 101 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax3} -fecexprrow 108 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax3} -fecexprrow 108 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax3} -fecexprrow 108 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncore_pmon_tmr_k.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_CoreMax3} -fecexprrow 108 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncr_pmon_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon} -fecexprrow 193 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncr_pmon_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon} -fecexprrow 193 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncr_pmon_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon} -fecexprrow 211 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncr_pmon_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon} -fecexprrow 211 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncr_pmon_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon} -fecexprrow 229 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncr_pmon_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon} -fecexprrow 229 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncr_pmon_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon} -fecexprrow 247 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/ncr_pmon_g.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon} -fecexprrow 247 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/thermo_fast_c.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/thermo_fast_c.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/thermo_fast_c.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/thermo_fast_c.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -linerange 1080 -item b 3 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -linerange 1113 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -linerange 1114 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -linerange 1115 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -linerange 1271 -item b 3 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/arb_comb_h.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_rr_arb/u_arb} -linerange 49 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem0_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem1_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/rd_ptr_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/wr_ptr_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0/u_tmr_ovf/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA0/u_tmr_value/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1/u_tmr_ovf/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA1/u_tmr_value/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2/u_tmr_ovf/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA2/u_tmr_value/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3/u_tmr_ovf/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntA3/u_tmr_value/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0/u_tmr_ovf/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB0/u_tmr_value/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1/u_tmr_ovf/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB1/u_tmr_value/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2/u_tmr_ovf/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB2/u_tmr_value/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3/u_tmr_ovf/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/u_ncr_pmon/u_pmon_stats_core/u_StallCntB3/u_tmr_value/reg_out_dffre} -linerange 18 -item b 1 -allfalse  -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ai.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmd_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ak.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmp_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 87 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 98 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 139 -item b 2 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ao.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ar.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx0_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ar.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_as.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx1_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_as.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_av.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_aw.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ax.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ax.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ay.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_ay.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_bx.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_dp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/fifo_dk.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 348 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 395 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 103 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 105 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 107 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/andrewb/ncore/hw-ncr/regression/2022_01_17_0839/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 121 -item b 1 -reason "EU"
