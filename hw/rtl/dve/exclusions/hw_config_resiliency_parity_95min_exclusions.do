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
#  Branch                   99          34          34 (34%)
#  Condition                18           2           2 (11%)
#  Expression              638         337         337 (52%)
#  FSM State                 0           0           0
#  FSM Transition            0           0           0
#  Statement                37          25          25 (67%)
#  Toggle                    0           0           0
#  Coverbin                  0           0           0


# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/arb_comb_g.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_rr_arb/u_arb} -linerange 49 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem0_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem1_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/rd_ptr_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/wr_ptr_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_af.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_aj.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_am.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 88 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 99 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_bf.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmp_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_bf.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_bg.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_bg.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_bh.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_cl.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_cm.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_dp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_dq.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver/sysreq_fifo} -linerange 147 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_dr.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver/sysrsp_fifo} -linerange 147 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 395 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -feccondrow 534 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -feccondrow 534 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -feccondrow 146 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -feccondrow 146 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_age_buffer_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/u_dve_cmd_age_buffer} -fecexprrow 120 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_age_buffer_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/u_dve_cmd_age_buffer} -fecexprrow 120 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 580 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 580 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 660 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 660 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 660 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 660 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 678 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 678 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 678 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 678 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 696 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 696 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 696 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 696 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 696 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 696 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 709 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 709 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 747 13 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 747 14 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_skid_buffer_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf} -fecexprrow 775 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_skid_buffer_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf} -fecexprrow 775 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 410 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 410 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 411 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 411 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 415 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 415 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 416 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 416 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 420 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 420 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 421 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 421 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 425 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 425 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 426 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 426 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 479 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 479 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 484 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 484 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 9 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 10 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 13 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 14 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 15 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 16 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 653 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 653 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 9 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 10 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 704 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 704 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_unit_a.v
coverage exclude -scope {/tb_top/dut/unit} -fecexprrow 2028 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dve_unit_a.v
coverage exclude -scope {/tb_top/dut/unit} -fecexprrow 2028 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_cp.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/strreq_fifo} -fecexprrow 92 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_cp.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/strreq_fifo} -fecexprrow 92 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_cq.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_fifo} -fecexprrow 84 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_cq.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_fifo} -fecexprrow 84 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_cr.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_dbg_fifo} -fecexprrow 84 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_cr.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_dbg_fifo} -fecexprrow 84 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_dq.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver/sysreq_fifo} -fecexprrow 79 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_dq.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver/sysreq_fifo} -fecexprrow 79 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_prot_interface/u_parit_tree_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_prot_interface/u_parit_tree_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_prot_interface/u_parit_tree_0} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_prot_interface/u_parit_tree_0} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_prot_interface/u_parit_tree_0} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_prot_interface/u_parit_tree_0} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 53 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 53 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gv.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 23 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 23 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 24 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 24 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 48 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 48 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gw.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_gx.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 28 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 28 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 28 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 28 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 29 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 29 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_j.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_prot_interface/u_parit_tree_0} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 42 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 42 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/logic_tree_m.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -fecexprrow 106 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -fecexprrow 106 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -fecexprrow 134 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -fecexprrow 134 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -fecexprrow 139 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -fecexprrow 139 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/thermo_fast_k.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/thermo_fast_k.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/thermo_fast_k.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/thermo_fast_k.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/apb_csr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -linerange 1080 -item b 3 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/apb_csr_j.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -linerange 1271 -item b 3 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/arb_comb_g.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_rr_arb/u_arb} -linerange 49 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem0_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem1_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/rd_ptr_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/wr_ptr_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_af.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx0_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_af.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx1_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_aj.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_am.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 87 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 98 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 139 -item b 2 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_az.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmd_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_bb.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_bf.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmp_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_bf.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_bg.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_bg.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_bh.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_cl.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_cm.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_dp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_cn.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_dq.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver/sysreq_fifo} -linerange 147 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_dr.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver/sysrsp_fifo} -linerange 147 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/fifo_z.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 348 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_resiliency_parity/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 395 -item b 1 -reason "EU"
