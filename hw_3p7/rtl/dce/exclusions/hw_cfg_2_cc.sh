cp /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_2/coverage/hier.cfg .

cp -r /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_2/coverage/../exe/comp_covdir.vdb .

cp -r /scratch/dv_reg/regr_ncore3.7/repository/coverage/nightly_dce_2025_01_07_2332/concerto/regression/2025_01_07_233518/debug/dce/hw_cfg_2/coverage/merged_dce_hw_cfg_2.vdb .

mkdir urgReport

urg -hier hier.cfg -metric line+cond+branch+fsm -metric group+assert -lca -parallel -dir comp_covdir.vdb merged_dce_hw_cfg_2.vdb -group merge_across_scopes -flex_merge union -show tests -dbname trial_merged_dce_hw_cfg_2.vdb -format both -report urgReport -map dce_att_entry_a dffre0 dce_dir_way_a dce_dir_rp_a dce_dir_a dce_dir_way_b dce_dir_rp_b dce_dir_b dce_vb_a dce_vb_entry_a find_first_rl_a rr_arb_comb_mux_therm_c

dve -cov -covdir trial_merged_dce_hw_cfg_2.vdb 

# base exclusion file is /scratch/rsalamat/dce_regression/hw_cfg_2/coverage/hw_cfg_2.el  
