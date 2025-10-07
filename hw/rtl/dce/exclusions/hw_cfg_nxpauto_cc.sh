cp /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_nxpauto/coverage/hier.cfg .

cp -r /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_nxpauto/coverage/../exe/comp_covdir.vdb .

cp -r /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_nxpauto/coverage/merged_dce_hw_cfg_nxpauto.vdb .

mkdir urgReport

urg -hier hier.cfg -metric line+cond+branch+fsm -metric group+assert -lca -parallel -dir comp_covdir.vdb merged_dce_hw_cfg_nxpauto.vdb -group merge_across_scopes -flex_merge union -show tests -dbname trial_merged_dce_hw_cfg_nxpauto.vdb -format both -report urgReport -map dce_att_entry_a dffre0 dce_dir_way_a dce_dir_rp_a dce_dir_a dce_vb_a dce_vb_entry_a fault_checker_xor_tree_pipe_b logic_tree_pipe_rdy_vld_b find_first_rl_a encoder_i find_first_rl_b find_first_lr_a find_first_one_d thermo_fast_e rr_arb_comb_mux_therm_b arb_comb_therm_d thermo_fast_e dce_mux_b dce_mux_c dce_demux_a ecc_addr_err_a ecc_cor_q ecc_dec_q ecc_enc_l ncore_pmon_tmr_f ncore_pmon_tmr_g ncore_pmon_tmr_i ncore_pmon_tmr_j ncore_pmon_tmr_k ncore_pmon_tmr_h lpf_a ao_mux_aw ao_mux_ax ao_mux_ap ao_mux_aq ao_mux_ar ao_mux_as 

dve -cov -covdir trial_merged_dce_hw_cfg_nxpauto.vdb

