cp /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_20/coverage/hier.cfg .

cp -r /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_20/coverage/../exe/comp_covdir.vdb .

cp -r /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_20/coverage/merged_dce_hw_cfg_20.vdb .

mkdir urgReport

urg -hier hier.cfg -metric line+cond+branch+fsm -metric group+assert -lca -parallel -dir comp_covdir.vdb merged_dce_hw_cfg_20.vdb -group merge_across_scopes -flex_merge union -show tests -dbname trial_merged_dce_hw_cfg_20.vdb -format both -report urgReport -map dce_att_entry_a dffre0 dce_dir_way_a dce_dir_rp_a dce_dir_a dce_dir_b find_first_rl_a find_first_one_j rr_arb_comb_mux_therm_c find_first_one_e rr_arb_comb_mux_therm_b variable_limit_credit_counter_b find_first_one_g ecc_dec_c dce_ecc_dec_err_a ecc_addr_err_a ecc_cor_c ecc_enc_a dce_mux_a dce_mux_b dce_mux_c dce_mux_d dce_demux_a

dve -cov -covdir trial_merged_dce_hw_cfg_20.vdb

