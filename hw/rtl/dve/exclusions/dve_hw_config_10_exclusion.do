
# Exclude expression coverage and condition coverage for concerto_mux, apb_csr.

#coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux -r
#coverage exclude -code c -scope /tb_top/dut/unit/dve_concerto_mux -r

#coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux -r
#coverage exclude -code c -scope /tb_top/dut/dup_unit/dve_concerto_mux -r

#coverage exclude -code e -scope /tb_top/dut/unit/u_csr/u_apb_csr -r
#coverage exclude -code c -scope /tb_top/dut/unit/u_csr/u_apb_csr -r

#coverage exclude -code e -scope /tb_top/dut/dup_unit/u_csr/u_apb_csr -r
#coverage exclude -code c -scope /tb_top/dut/dup_unit/u_csr/u_apb_csr -r


#coverage exclude -code e -scope /tb_top/dut/u_fault_checker/mission_fault_xor_tree -r
#coverage exclude -code e -scope /tb_top/dut/u_fault_checker/latent_fault_xor_tree -r

coverage exclude -code e -scope /tb_top/dut/unit/u_ncr_pmon -r
coverage exclude -code c -scope /tb_top/dut/unit/u_ncr_pmon -r

coverage exclude -code e -scope /tb_top/dut/unit/u_protman/u_dve_trace_accumulator -r
coverage exclude -code c -scope /tb_top/dut/unit/u_protman/u_dve_trace_accumulator -r


# Exclude expression coverage and condition coverage for concerto_mux

#coverage exclude -clear -scope /tb_top/dut/unit/dve_concerto_mux -r

#coverage exclude -clear -scope /tb_top/dut/dup_unit/dve_concerto_mux -r


coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/dtw_req_fifo -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/snp_rsp_fifo -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/cmd_req_fifo -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/smi_rx1_fifo -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/smi_rx0_fifo -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/str_req_fifo -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/dtw_rsp_fifo -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/dtw_dbg_rsp_fifo -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo -r

coverage exclude -code s -scope /tb_top/dut/unit/dve_concerto_mux/dtw_req_fifo -r
coverage exclude -code s -scope /tb_top/dut/unit/dve_concerto_mux/dtw_dbg_req_fifo -r
coverage exclude -code s -scope /tb_top/dut/unit/dve_concerto_mux/snp_rsp_fifo -r
coverage exclude -code s -scope /tb_top/dut/unit/dve_concerto_mux/cmd_req_fifo -r
coverage exclude -code s -scope /tb_top/dut/unit/dve_concerto_mux/smi_rx1_fifo -r
coverage exclude -code s -scope /tb_top/dut/unit/dve_concerto_mux/smi_rx0_fifo -r
coverage exclude -code s -scope /tb_top/dut/unit/dve_concerto_mux/sys_req_rx_fifo -r

coverage exclude -code e -scope /tb_top/dut/unit/u_csr -r
coverage exclude -code c -scope /tb_top/dut/unit/u_csr -r


coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/dtw_req_fifo -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/dtw_dbg_req_fifo -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/snp_rsp_fifo -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/cmd_req_fifo -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/smi_rx1_fifo -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/smi_rx0_fifo -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/str_req_fifo -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/dtw_rsp_fifo -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/dtw_dbg_rsp_fifo -r

coverage exclude -code s -scope /tb_top/dut/dup_unit/dve_concerto_mux/dtw_req_fifo -r
coverage exclude -code s -scope /tb_top/dut/dup_unit/dve_concerto_mux/dtw_dbg_req_fifo -r
coverage exclude -code s -scope /tb_top/dut/dup_unit/dve_concerto_mux/snp_rsp_fifo -r
coverage exclude -code s -scope /tb_top/dut/dup_unit/dve_concerto_mux/cmd_req_fifo -r
coverage exclude -code s -scope /tb_top/dut/dup_unit/dve_concerto_mux/smi_rx1_fifo -r
coverage exclude -code s -scope /tb_top/dut/dup_unit/dve_concerto_mux/smi_rx0_fifo -r

coverage exclude -code e -scope /tb_top/dut/dup_unit/u_csr -r
coverage exclude -code c -scope /tb_top/dut/dup_unit/u_csr -r






coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/str_req_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/dtw_rsp_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/snp_req_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/smi_tx1_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/smi_tx0_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/nc_cmd_rsp_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/cmp_rsp_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/smi_rx0_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/smi_rx1_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/smi_rx2_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/cmd_req_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/dtw_req_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/dtw_req_0_data_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/cmp_rsp_fifo -r
coverage exclude -code e -scope /tb_top/dut/unit/dve_concerto_mux/str_rsp_fifo -r

coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/str_req_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/dtw_rsp_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/snp_req_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/smi_tx1_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/smi_tx0_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/nc_cmd_rsp_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/cmp_rsp_prot_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/smi_rx0_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/smi_rx1_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/smi_rx2_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/cmd_req_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/dtw_req_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/dtw_req_0_data_correct_interface -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/cmp_rsp_fifo -r
coverage exclude -code e -scope /tb_top/dut/dup_unit/dve_concerto_mux/str_rsp_fifo -r

coverage exclude -code c -scope /tb_top/dut/unit/dve_concerto_mux

coverage exclude -code c -scope /tb_top/dut/dup_unit/dve_concerto_mux

coverage exclude -code e -scope /tb_top/dut/unit/u_protman/u_dve_trace_accumulator -r
coverage exclude -code c -scope /tb_top/dut/unit/u_protman/u_dve_trace_accumulator -r
