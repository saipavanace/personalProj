class txn_info extends uvm_object;
    `uvm_object_param_utils(txn_info)

    int txn_id;
    chi_req_seq_item  m_chi_req_pkt;
    chi_dat_seq_item  m_chi_read_data_pkt[$];
    chi_dat_seq_item  m_chi_write_data_pkt[$];
    chi_rsp_seq_item  m_chi_crsp_pkt;
    chi_rsp_seq_item  m_chi_srsp_pkt;
    chi_dat_seq_item  m_chi_snp_data_pkt[$];
    chi_snp_seq_item  m_chi_snp_addr_pkt;
    chi_base_seq_item m_chi_sysco_req_pkt;
    chi_base_seq_item m_chi_sysco_ack_pkt;

    smi_seq_item  m_cmd_req_pkt;
    smi_seq_item  m_cmd_rsp_pkt;
    smi_seq_item  m_str_req_pkt;
    smi_seq_item  m_str_rsp_pkt;
    smi_seq_item  m_snp_dtw_req_pkt;
    smi_seq_item  m_snp_dtw_rsp_pkt;
    smi_seq_item  m_snp_dtr_req_pkt;
    smi_seq_item  m_snp_dtr_rsp_pkt;
    smi_seq_item  m_dtr_req_pkt;
    smi_seq_item  m_dtr_rsp_pkt;
    smi_seq_item  m_dtw_req_pkt;
    smi_seq_item  m_dtw_rsp_pkt;
    smi_seq_item  m_snp_req_pkt;
    smi_seq_item  m_snp_rsp_pkt;
    smi_seq_item  m_upd_req_pkt;
    smi_seq_item  m_upd_rsp_pkt;
    smi_seq_item  m_cmp_rsp_pkt;
    smi_seq_item  m_sys_req_pkt[$];
    smi_seq_item  m_sys_rsp_pkt[$];

    function new(name="txn_info");
        super.new(name);
    endfunction: new
endclass: txn_info