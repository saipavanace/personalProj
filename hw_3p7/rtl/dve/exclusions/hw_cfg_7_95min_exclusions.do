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
#  Branch                   91          36          36 (39%)
#  Condition                18           2           2 (11%)
#  Expression              493         314         314 (63%)
#  FSM State                 0           0           0
#  FSM Transition            0           0           0
#  Statement                43          26          26 (60%)
#  Toggle                    0           0           0
#  Coverbin                  0           0           0


# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/arb_comb_g.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_rr_arb/u_arb} -linerange 49 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem0_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem1_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/rd_ptr_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/wr_ptr_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ac.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ah.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ai.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_aj.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_am.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ao.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmp_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 88 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 99 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_aq.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_aq.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_bc.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_cf.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_dp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ch.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 395 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 106 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 108 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 122 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -feccondrow 576 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -feccondrow 576 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -feccondrow 158 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -feccondrow 158 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 622 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 622 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 750 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 750 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 750 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 750 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 768 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 768 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 768 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 768 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 786 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 786 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 786 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 786 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 804 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 804 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 804 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 804 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 822 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 822 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 822 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 822 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 840 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 840 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 840 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 840 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 858 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 858 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 858 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 858 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 876 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 876 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 876 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 876 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 894 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 894 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 894 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 894 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 894 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 894 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 907 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 907 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 945 13 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 945 14 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 410 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 410 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 411 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 411 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 415 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 415 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 416 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 416 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 420 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 420 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 421 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 421 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 425 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 425 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 426 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 426 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 479 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 479 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 484 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 484 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 9 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 10 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 13 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 14 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 15 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 16 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 356 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 356 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 356 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 356 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 366 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 366 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 366 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 366 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 376 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 376 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 376 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 376 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 386 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 386 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 386 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 386 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 396 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 396 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 396 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 396 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 406 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 406 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 406 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 406 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 416 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 416 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 416 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 416 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 525 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 525 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 574 9 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 574 10 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 574 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 574 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 576 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 576 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 607 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 607 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 607 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 607 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 608 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 608 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 608 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 608 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 611 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 611 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 611 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 611 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 612 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 612 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 612 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 612 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 615 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 615 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 615 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 615 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 616 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 616 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 616 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 616 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 619 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 619 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 619 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 619 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 620 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 620 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 620 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 620 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 623 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 623 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 623 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 623 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 624 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 624 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 624 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 624 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 627 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 627 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 627 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 627 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 628 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 628 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 628 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 628 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 631 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 631 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 631 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 631 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 632 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 632 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 632 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 632 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_unit_a.v
coverage exclude -scope {/tb_top/dut/unit} -fecexprrow 1928 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dve_unit_a.v
coverage exclude -scope {/tb_top/dut/unit} -fecexprrow 1928 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_cd.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_fifo} -fecexprrow 84 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_cd.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_fifo} -fecexprrow 84 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_cj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/strreq_fifo} -fecexprrow 140 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_cj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/strreq_fifo} -fecexprrow 140 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ck.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_dbg_fifo} -fecexprrow 84 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ck.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_dbg_fifo} -fecexprrow 84 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fh.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fi.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 26 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 26 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/logic_tree_fj.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -fecexprrow 106 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -fecexprrow 106 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/thermo_fast_l.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/thermo_fast_l.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/thermo_fast_l.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/thermo_fast_l.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/apb_csr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -linerange 1080 -item b 3 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/apb_csr_i.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -linerange 1271 -item b 3 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/arb_comb_g.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_rr_arb/u_arb} -linerange 49 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem0_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem1_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/rd_ptr_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/wr_ptr_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ab.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmd_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ac.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ag.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ah.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ai.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx0_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ai.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_aj.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx1_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_aj.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_am.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ao.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmp_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 87 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 98 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 139 -item b 2 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_aq.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_aq.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_bc.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_cf.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_dp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_cg.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/fifo_ch.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 348 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 395 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 103 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 105 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 107 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_cfg_7/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 121 -item b 1 -reason "EU"
