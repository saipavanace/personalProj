class chi_subsys_coherency_entry_seq extends svt_chi_protocol_service_base_sequence; 

    /** 
    * Factory Registration.
    */
    `svt_xvm_object_utils(chi_subsys_coherency_entry_seq) 

    /** Constrain the sequence length one for this sequence */
    constraint reasonable_sequence_length {
        sequence_length == 1;
    }
    
    int delay_in_ns;
    bit wait_mode_using_delay;
    bit wait_mode_using_trigger=1;
    static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
    static uvm_event csr_init_done = ev_pool.get("csr_init_done");
  
    //------------------------------------------------------------------------------
    function new(string name = "chi_subsys_coherency_entry_seq");
        super.new(name);
        // Make the default sequence_length equal to 1
        sequence_length = 1;
    endfunction

    //------------------------------------------------------------------------------
    task body();
    
        super.body();
        
        if (wait_mode_using_delay) begin
            `svt_xvm_debug("body", $sformatf("Adding delay %0d ns chi_subsys_coherency_entry_seq",delay_in_ns));
            #(delay_in_ns*1ns);
        end else if(wait_mode_using_trigger) begin
            `svt_xvm_debug("body", $sformatf("Waiting for csr_init_done trigger chi_subsys_coherency_entry_seq"));
            csr_init_done.wait_trigger();
            #2ns;
            `svt_xvm_debug("body", $sformatf("Done waiting for csr_init_done trigger chi_subsys_coherency_entry_seq"));
        end
        //   `ifndef SVT_CHI_ISSUE_A_ENABLE
            /** check if current environment is supported or not */ 
            if(!is_supported(node_cfg, silent))  begin
            `svt_xvm_note("body",$sformatf("This sequence cannot be run based on the current system configuration. Exiting..."))
            return;
            end
            repeat(sequence_length) begin
            `svt_xvm_do_with(req, { service_type == svt_chi_protocol_service::COHERENCY_ENTRY; })
            end
        //   `endif
    endtask: body

    //------------------------------------------------------------------------------
    function bit is_supported(svt_configuration cfg, bit silent = 0);
        string str_is_supported_info_prefix = "This sequence cannot be run based on the current configuration.\n";
        string str_is_supported_info = "";
        string str_is_supported_info_suffix = "Modify the configurations \n";
        is_supported = super.is_supported(cfg, silent);
        // `ifndef SVT_CHI_ISSUE_A_ENABLE
        if(is_supported) begin
            if(!( 
                (node_cfg.sysco_interface_enable == 1) &&
                (node_cfg.chi_spec_revision >= svt_chi_node_configuration::ISSUE_B) && 
                (node_cfg.chi_interface_type == svt_chi_node_configuration::RN_F || (node_cfg.chi_interface_type == svt_chi_node_configuration::RN_D && node_cfg.dvm_enable == 1))
                ) 
            ) begin
            is_supported = 0;
            str_is_supported_info = $sformatf("sysco_interface_enable %0b, chi_spec_revision %0s, chi_interface_type %0s, dvm_enable %0b", node_cfg.sysco_interface_enable, node_cfg.chi_spec_revision.name(), node_cfg.chi_interface_type.name(), node_cfg.dvm_enable);
            end else begin
            is_supported = 1;
            end  
        end 
        // `endif
        if (!is_supported) begin
        string str_complete_is_supported_info = {str_is_supported_info_prefix, str_is_supported_info, str_is_supported_info_suffix};
        issue_is_supported_failure(str_complete_is_supported_info);
        end
    endfunction
endclass

