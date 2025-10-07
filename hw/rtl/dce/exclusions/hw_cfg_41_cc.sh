cp /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_41/coverage/hier.cfg .

cp -r /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_41/coverage/../exe/comp_covdir.vdb .

cp -r /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_41/coverage/merged_dce_hw_cfg_41.vdb .

mkdir urgReport

urg -hier hier.cfg -metric line+cond+branch+fsm -metric group+assert -lca -parallel -dir comp_covdir.vdb merged_dce_hw_cfg_41.vdb -group merge_across_scopes -flex_merge union -show tests -dbname trial_merged_dce_hw_cfg_41.vdb -format both -report urgReport -map dce_att_entry_a dffre0 dce_dir_a dce_dir_b dce_dir_c dce_dir_d dce_dir_e dce_dir_f dce_dir_g dce_dir_h dce_dir_i dce_dir_j dce_dir_k dce_dir_l dce_dir_m dce_dir_n dce_dir_o dce_dir_p dce_dir_rp_a dce_dir_rp_b dce_dir_rp_c dce_dir_rp_d dce_dir_rp_e dce_dir_rp_f dce_dir_rp_g dce_dir_rp_h dce_dir_way_a dce_dir_way_b dce_dir_way_c dce_dir_way_d dce_dir_way_e dce_dir_way_f dce_dir_way_g dce_dir_way_h dce_dir_way_i dce_dir_way_j dce_dir_way_k dce_dir_way_l dce_dir_way_m dce_dir_way_n dce_vb_a dce_vb_b dce_vb_c dce_vb_d dce_vb_e dce_vb_f dce_vb_g dce_vb_h dce_vb_i dce_vb_j dce_vb_k dce_vb_l dce_vb_entry_a dce_vb_entry_b dce_vb_entry_c dce_vb_entry_d dce_vb_entry_e dce_vb_entry_f dce_vb_entry_g dce_vb_entry_h dce_vb_entry_i dce_vb_entry_j dce_vb_entry_k rr_arb_comb_mux_therm_a rr_arb_comb_mux_therm_b rr_arb_comb_mux_therm_c find_first_one_k encoder_i find_first_one_e dce_credit_var_a variable_limit_credit_counter_c

dve -cov -covdir trial_merged_dce_hw_cfg_41.vdb

