
class chi_subsys_mkrdunq_copyback_hazard_test extends chi_subsys_base_test;

    
    `uvm_component_utils(chi_subsys_mkrdunq_copyback_hazard_test)
    `ifdef SVT_CHI_ISSUE_E_ENABLE
    svt_chi_system_protocol_flow_ctrl_hn_makereadunique_copyback_hazard_directed_virtual_sequence m_hazard_vseq;
    `endif

    function new(string name = "chi_subsys_mkrdunq_copyback_hazard_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(int)::set(this, "", "initiating_rn_node_idx_0", 0); 
        uvm_config_db#(int)::set(this, "", "initiating_rn_node_idx_1", 1); 
    endfunction: build_phase

    task start_sequence();
    `ifdef SVT_CHI_ISSUE_E_ENABLE
        uvm_config_db#(uvm_object_wrapper)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr.main_phase", "default_sequence", svt_chi_system_protocol_flow_ctrl_hn_makereadunique_copyback_hazard_directed_virtual_sequence::type_id::get()); 
        m_hazard_vseq = svt_chi_system_protocol_flow_ctrl_hn_makereadunique_copyback_hazard_directed_virtual_sequence::type_id::create("m_hazard_vseq");
        `uvm_info(get_name(), "Starting m_hazard_vseq", UVM_NONE)
        // m_hazard_vseq.initiating_rn_node_idx_0 = 1;
        // m_hazard_vseq.initiating_rn_node_idx_1 = 1;

        m_hazard_vseq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
        `uvm_info(get_name(), "Done m_hazard_vseq", UVM_NONE)
    `endif
    endtask: start_sequence

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase

endclass: chi_subsys_mkrdunq_copyback_hazard_test
