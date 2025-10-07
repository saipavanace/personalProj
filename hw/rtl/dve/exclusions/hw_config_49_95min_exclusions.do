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
#  Branch                  253          34          34 (13%)
#  Condition                23           1           1 (4%)
#  Expression            10030         234         234 (2%)
#  FSM State                 0           0           0
#  FSM Transition            0           0           0
#  Statement               125          26          26 (20%)
#  Toggle                    0           0           0
#  Coverbin                  0           0           0


# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/arb_comb_g.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_rr_arb/u_arb} -linerange 49 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem0_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem1_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/rd_ptr_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/wr_ptr_dffre} -linerange 21 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_ad.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_am.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_ao.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_ar.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_at.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmp_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 88 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 99 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_av.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_av.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_bg.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_bt.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_dp_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_by.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 395 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 106 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 108 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 122 -item s 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -feccondrow 210 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/sys_coh_receiver_b.v
coverage exclude -scope {/tb_top/dut/unit/u_sys_evt_coh_concerto/u_sys_evt_coh_wrapper/u_sys_coh_receiver} -feccondrow 210 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 410 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 410 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 411 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 411 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 415 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 415 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 416 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 416 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 420 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 420 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 421 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 421 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 425 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 425 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 426 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 426 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 454 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 455 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 459 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 460 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 464 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 465 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 469 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 470 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 478 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 479 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 479 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 483 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 484 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 484 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 488 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 489 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 493 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 494 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 5 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 6 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 7 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 8 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 9 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 10 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 11 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 12 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 13 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 14 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 15 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_stt_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/stt} -fecexprrow 587 16 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_unit_a.v
coverage exclude -scope {/tb_top/dut/unit} -fecexprrow 1982 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dve_unit_a.v
coverage exclude -scope {/tb_top/dut/unit} -fecexprrow 1982 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_de.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/strreq_fifo} -fecexprrow 348 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_de.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/strreq_fifo} -fecexprrow 348 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_df.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_fifo} -fecexprrow 84 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_df.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_fifo} -fecexprrow 84 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_dg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_dbg_fifo} -fecexprrow 84 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_dg.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/skidbuf/dtwrsp_dbg_fifo} -fecexprrow 84 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 14 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 36 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 46 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 47 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_cf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_5} -fecexprrow 54 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 41 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 41 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 42 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 42 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 53 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 53 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 53 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 53 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_0} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 41 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 42 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 42 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 53 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lc.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_7} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 41 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 41 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 42 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 42 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 53 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 53 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 53 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 53 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_1} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 39 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 41 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 41 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 42 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 42 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 52 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 53 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 53 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 53 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 53 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_2} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 40 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 41 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 42 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 42 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 53 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 53 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 53 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 53 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 61 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_ld.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_3} -fecexprrow 61 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 15 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 16 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 17 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 18 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 22 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 22 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 22 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 22 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 35 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 36 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 38 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 38 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 38 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 38 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 39 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 39 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 48 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 48 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 49 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 49 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 49 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 49 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 57 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_le.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_4} -fecexprrow 57 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 19 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 20 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 21 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 21 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 21 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 21 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 29 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 29 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 30 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 30 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 30 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 30 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 37 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/logic_tree_lf.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_trace_accumulator/ecc_hdr_enc/u_xor_tree_ecc_6} -fecexprrow 37 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -fecexprrow 106 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -fecexprrow 106 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/thermo_fast_k.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 1 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/thermo_fast_k.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 2 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/thermo_fast_k.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 3 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/thermo_fast_k.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/u_dve_flm/u_allocate1/u_thermo} -fecexprrow 34 4 -item 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/arb_comb_g.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_rr_arb/u_arb} -linerange 49 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem0_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/mem1_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/rd_ptr_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/dffre.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo/wr_ptr_dffre} -linerange 20 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_ad.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_rsp_tx_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_ah.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmd_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_al.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_am.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx0_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_an.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx0_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_ao.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx1_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_ao.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_tx1_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_ar.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_at.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/snp_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/cmp_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/nc_cmd_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 87 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 98 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 132 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_au.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo/fifo} -linerange 139 -item b 2 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_av.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_av.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_rsp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_bg.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/str_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_bt.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/smi_rx2_dp_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_by.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/fifo_dc.v
coverage exclude -scope {/tb_top/dut/unit/dve_concerto_mux/dtw_req_fifo/fifo} -linerange 134 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 348 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/multiport_fifo_a.v
coverage exclude -scope {/tb_top/dut/unit/u_protman/cmp_issue_fifo} -linerange 395 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 103 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 105 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 107 -item b 1 -reason "EU"
# CoverCheck srcfile = /scratch/saadz/ncore/hw-ncr/regression/2022_02_07_1624/debug/dve/hw_config_49/rtl/pma_slave_b.v
coverage exclude -scope {/tb_top/dut/unit/dve_pma} -linerange 121 -item b 1 -reason "EU"
