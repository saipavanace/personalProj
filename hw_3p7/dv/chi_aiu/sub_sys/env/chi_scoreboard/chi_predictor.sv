class chi_predictor extends uvm_component;
    `uvm_component_param_utils(chi_predictor)

    `uvm_analysis_imp_decl ( _smi_port         )
    `uvm_analysis_imp_decl ( _chi_req_port     )
    `uvm_analysis_imp_decl ( _chi_wdata_port   )
    `uvm_analysis_imp_decl ( _chi_srsp_port    )
    `uvm_analysis_imp_decl ( _chi_crsp_port    )
    `uvm_analysis_imp_decl ( _chi_rdata_port   )
    `uvm_analysis_imp_decl ( _chi_snpaddr_port )


    //CHI Ports
    uvm_analysis_imp_chi_req_port     #(chi_req_seq_item, chi_predictor) chi_req_port;
    uvm_analysis_imp_chi_wdata_port   #(chi_dat_seq_item, chi_predictor) chi_wdata_port;
    uvm_analysis_imp_chi_srsp_port    #(chi_rsp_seq_item, chi_predictor) chi_srsp_port;
    uvm_analysis_imp_chi_crsp_port    #(chi_rsp_seq_item, chi_predictor) chi_crsp_port;
    uvm_analysis_imp_chi_rdata_port   #(chi_dat_seq_item, chi_predictor) chi_rdata_port;
    uvm_analysis_imp_chi_snpaddr_port #(chi_snp_seq_item, chi_predictor) chi_snpaddr_port;

    //SMI Port
    uvm_analysis_imp_smi_port #(smi_seq_item, chi_predictor) smi_port;

    chi_txn_memory txn_mem;
    int txn_cnt;
    string tb_txnid;
    int chi_id;

    function new (string name="chi_predictor", uvm_component parent=null);
        super.new (name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        txn_mem = chi_txn_memory::get_instance();

        chi_req_port    = new("chi_req_port", this);
        chi_wdata_port  = new("chi_wdata_port", this);
        chi_srsp_port   = new("chi_srsp_port", this);
        chi_crsp_port   = new("chi_crsp_port", this);
        chi_rdata_port  = new("chi_rdata_port", this);
        chi_snpaddr_port= new("chi_snpaddr_port", this);
        smi_port        = new("smi_port", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase

    function void write_chi_req_port(const ref chi_req_seq_item m_pkt);
        txn_info txn;
        tb_txnid = $sformatf("CHI%s_%0d",chi_id, txn_cnt);
        `uvm_info("CHI Predictor", $sformatf("Found a REQ txn with TB_TXNID:%0s \n CHI_REQ_PKT:", tb_txnid, m_pkt.convert2string()), UVM_LOW)
        txn_cnt++;

        txn = new();
        txn.m_cmd_req_pkt = new();

        // expect a command request packet
        txn_mem.m_txn_q.push_back(txn);
        // need to update the expected cmd_req_pkt
    endfunction: write_chi_req_port

    function void write_chi_wdata_port( const ref chi_dat_seq_item m_pkt) ;
        `uvm_info("CHI Predictor", $sformatf("Found a WDATA txn with TB_TXNID:%0s", "tempId"), UVM_LOW)
    endfunction: write_chi_wdata_port

    function void write_chi_srsp_port(const ref chi_rsp_seq_item m_pkt) ;
        `uvm_info("CHI Predictor", $sformatf("Found a SRSP txn with TB_TXNID:%0s", "tempId"), UVM_LOW)
    endfunction: write_chi_srsp_port

    function void write_chi_crsp_port    ( const ref chi_rsp_seq_item m_pkt) ;
        `uvm_info("CHI Predictor", $sformatf("Found a CRSP txn with TB_TXNID:%0s", "tempId"), UVM_LOW)
    endfunction: write_chi_crsp_port

    function void write_chi_rdata_port   ( const ref chi_dat_seq_item m_pkt ) ;
        `uvm_info("CHI Predictor", $sformatf("Found a RDATA txn with TB_TXNID:%0s", "tempId"), UVM_LOW)
    endfunction: write_chi_rdata_port

    function void write_chi_snpaddr_port ( const ref chi_snp_seq_item m_pkt  ) ;
        `uvm_info("CHI Predictor", $sformatf("Found a SNPADDR txn with TB_TXNID:%0s", "tempId"), UVM_LOW)
    endfunction: write_chi_snpaddr_port

    function void write_smi_port ( const ref smi_seq_item m_pkt);
        // Need to decode SMI
    endfunction: write_smi_port
    
    

endclass: chi_predictor