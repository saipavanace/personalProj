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
#  Branch                   98          36          36 (36%)
#  Condition                18           2           2 (11%)
#  Expression             1483         316         316 (21%)
#  FSM State                 0           0           0
#  FSM Transition            0           0           0
#  Statement                43          26          26 (60%)
#  Toggle                    0           0           0
#  Coverbin                  0           0           0


# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/arb_comb_h.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_rr_arb/u_arb} -linerange 49 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem0_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem1_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/rd_ptr_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/wr_ptr_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmp_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 88 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 99 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ao.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ar.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_as.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_av.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_aw.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ax.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ay.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ay.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_bx.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_dp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_dk.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 395 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 106 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 108 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 122 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -feccondrow 614 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -feccondrow 614 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -feccondrow 158 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -feccondrow 158 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 660 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 660 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 788 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 788 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 788 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 788 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 806 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 806 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 806 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 806 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 824 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 824 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 824 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 824 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 842 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 842 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 842 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 842 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 860 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 860 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 860 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 860 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 878 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 878 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 878 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 878 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 896 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 896 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 896 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 896 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 914 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 914 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 914 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 914 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 932 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 945 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 945 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 983 13 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_protocol_man_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman} -fecexprrow 983 14 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 445 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 445 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 446 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 446 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 450 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 450 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 451 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 451 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 456 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 456 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 461 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 461 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 490 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 490 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 490 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 490 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 495 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 495 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 495 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 495 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 499 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 499 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 499 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 499 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 500 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 500 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 500 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 500 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 504 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 504 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 504 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 504 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 505 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 505 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 505 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 505 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 513 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 513 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 513 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 513 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 514 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 514 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 518 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 518 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 518 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 518 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 519 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 519 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 523 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 523 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 523 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 523 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 524 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 524 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 528 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 528 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 528 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 528 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 529 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 529 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 9 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 10 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 13 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 14 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 15 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 622 16 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 198 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 204 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 484 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 494 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 504 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 514 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 524 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 534 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 544 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 653 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 653 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 9 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 10 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 702 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 704 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 704 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 735 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 736 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 739 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 740 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 743 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 744 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 747 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 748 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 751 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 752 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 755 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 756 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 759 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_trace_accumulator_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator} -fecexprrow 760 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_unit_a.v
coverage exclude -scope {/tb_top/dut/unit} -fecexprrow 2019 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dve_unit_a.v
coverage exclude -scope {/tb_top/dut/unit} -fecexprrow 2019 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_cy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_fifo} -fecexprrow 84 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_cy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_fifo} -fecexprrow 84 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_dm.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/strreq_fifo} -fecexprrow 212 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_dm.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/strreq_fifo} -fecexprrow 212 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_dn.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_dbg_fifo} -fecexprrow 84 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_dn.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_dbg_fifo} -fecexprrow 84 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 51 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 51 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 60 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ov.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 60 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 54 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 23 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 23 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ow.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 27 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_ox.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 42 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 42 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/logic_tree_oy.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -fecexprrow 106 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -fecexprrow 106 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/thermo_fast_c.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/thermo_fast_c.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/thermo_fast_c.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/thermo_fast_c.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -linerange 1080 -item b 3 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/apb_csr_m.v
coverage exclude -scope {/tb_top/dut/unit/u_csr/u_apb_csr} -linerange 1271 -item b 3 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/arb_comb_h.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_rr_arb/u_arb} -linerange 49 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem0_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem1_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/rd_ptr_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/wr_ptr_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ai.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmd_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ak.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmp_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 87 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 98 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 139 -item b 2 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ao.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ap.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ar.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx0_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ar.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_as.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx1_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_as.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_av.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_aw.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ax.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ax.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ay.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_ay.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_bx.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_dp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/fifo_dk.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 348 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 395 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 103 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 105 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 107 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_10/rtl/pma_slave_d.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 121 -item b 1 -reason "EU"
