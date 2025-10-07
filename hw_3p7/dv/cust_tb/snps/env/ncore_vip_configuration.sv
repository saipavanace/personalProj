<%var nIOAIUs=0;
for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(!obj.AiuInfo[pidx].fnNativeInterface.includes('CHI')) {
        nIOAIUs += obj.AiuInfo[pidx].nNativeInterfacePorts;
    }
}%>

`define INNERSHAREABLE_END_ADDR    64'hfffffffffffff

class ncore_vip_configuration extends svt_amba_system_configuration;

    `svt_xvm_object_utils(ncore_vip_configuration)

    function new (string name="ncore_vip_configuration");
        super.new(name);
    endfunction
 
    //-------------------------------------------------------------------------  
    //  Utility method in the testbench to initialize the configuration of AMBA
    //  System ENV, and underlying CHI System ENV.
    //-------------------------------------------------------------------------  
    function void set_amba_sys_config();
    
        <% if(obj.nCHIs > 0 ) {%>
            <% if (obj.SNPS_PERF == 1) { %>
                int l_ace_lite_master_port_id [];
                int l_chi_rn_i_node_idx [];

                l_ace_lite_master_port_id = new[<%=nIOAIUs%>];
                l_chi_rn_i_node_idx = new[<%=nIOAIUs%>];
                <%for(var idx = 0; idx < nIOAIUs ; idx++){%>
                    l_ace_lite_master_port_id[<%=idx%>] = <%=idx%>;
                    l_chi_rn_i_node_idx[<%=idx%>] = <%=obj.nCHIs+idx%>;
                <%}%>
            <%}%>
        <%}%>

        //-----------------------------------------------------------------------------------------------------------  
        //   svt_amba_system_configuration::create_sub_cfgs allows user to allocate
        //   system configurations for AXI, and CHI System Envs.
        //-----------------------------------------------------------------------------------------------------------  

        <%var chi_system = 0 ;if(obj.nCHIs > 0 ) {%>
            <%chi_system=1; %>
        <%}%>
        <%let apb_system=0;
        if(obj.useResiliency == 1 && (obj.DebugApbInfo.length > 0)){%>
            <%apb_system=2%>
        <%}else if(obj.useResiliency == 1 || (obj.DebugApbInfo.length > 0)){%>
            <%apb_system=1%>
        <%}%>

        // create_sub_cfgs (int num_axi_systems, int num_ahb_systems, int num_apb_systems,int num_chi_systems )
        create_sub_cfgs(1, 0, <%=apb_system%>, <%=chi_system%>);

        //  Set the CHI System configuration parameters. 
        set_chi_system_configuration(this.chi_sys_cfg[0]);
        //------------------------------------------------------------------------------
        // set AXI configuration
        //------------------------------------------------------------------------------
        //  Set the AXI System configuration parameters. 
        
        set_axi_system_configuration(this.axi_sys_cfg[0]);
 
       <%if(obj.useResiliency == 1 || (obj.DebugApbInfo.length>0)){%>
            //set APB configuration
            set_apb_system_configuration(this.apb_sys_cfg[0]);
        <%}%>

    endfunction:set_amba_sys_config

    //---------------------------------------------------------------------------------------------   
    //  Utility method in the testbench to set the CHI System configuration parameters 
    //---------------------------------------------------------------------------------------------  

    function void set_chi_system_configuration(svt_chi_system_configuration chi_sys_cfg);
        //------------------------------------------------------------------------------------------------------------  
        //  Allocates the RN and SN node configurations before a user sets the parameters.
        //------------------------------------------------------------------------------------------------------------  

        if(nCHIs>0) begin
            //performance metrics, please set system_monitor_enable to 0 as default
            <% if (obj.SNPS_PERF == 1) { %>
                chi_sys_cfg.create_sub_cfgs(nAIUs,0,0,0);
                chi_sys_cfg.system_monitor_enable = 1;
                chi_sys_cfg.perf_tracking_enable = 1;
                chi_sys_cfg.display_perf_summary_report = 1;
            <%}else {%>
                chi_sys_cfg.create_sub_cfgs(nCHIs,0,0,0);
                chi_sys_cfg.system_monitor_enable = 0;
            <%}%>
        end
        
        // for (int i=0; i<nCHIs; i++) begin
        <%let l_chi_idx=0;%>
        <%for(let i=0; i<obj.AiuInfo.length; i++){%>
            <%if(obj.AiuInfo[i].fnNativeInterface.includes('CHI')){%>

            //----------------------------------------------------------------------------
            //  Configure the number of CHI Home Nodes in the CHI System ENV. 
            //------------------------------------------------------------------------------
            //  Set unique node id for each node 
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].node_id              = <%=i%>; 
            //  Set the interface type.
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].chi_interface_type   = svt_chi_node_configuration::RN_F;
            //  Set the width of Data field within Data VC Flit.
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].flit_data_width      = <%=obj.AiuInfo[i].wData%>;
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].addr_width           = <%=obj.AiuInfo[i].wAddr%>;
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].node_id_width        = <%=obj.AiuInfo[i].interfaces.chiInt.params.SrcID%>;
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].wysiwyg_enable       = 0;
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].dat_flit_rsvdc_width = 0;
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].req_flit_rsvdc_width = <%=(obj.AiuInfo[i].interfaces.chiInt.params.REQ_RSVDC>0)?obj.AiuInfo[i].interfaces.chiInt.params.REQ_RSVDC:0%>;
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].rx_rsp_vc_flit_buffer_size = <%= obj.AiuInfo[i].cmpInfo.nCHIReqInFlight%>;
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].rx_dat_vc_flit_buffer_size = <%= obj.AiuInfo[i].cmpInfo.nCHIReqInFlight%> ;
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].rx_snp_vc_flit_buffer_size = <%= obj.AiuInfo[i].cmpInfo.nCHIReqInFlight%>;
            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].rx_req_vc_flit_buffer_size = <%= obj.AiuInfo[i].cmpInfo.nCHIReqInFlight%>;

            if($test$plusargs("test_with_delay"))begin
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].prot_layer_delays_enable = 1;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].delays_enable            = 1;
            end
            <%if(obj.AiuInfo[i].fnNativeInterface == 'CHI-A'){%>
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].chi_spec_revision    = svt_chi_node_configuration::ISSUE_A; 
            <%} else if(obj.AiuInfo[i].fnNativeInterface == 'CHI-B'){%>
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].chi_spec_revision    = svt_chi_node_configuration::ISSUE_B;
            <%} else if(obj.AiuInfo[i].fnNativeInterface == 'CHI-C'){%>
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].chi_spec_revision    = svt_chi_node_configuration::ISSUE_C;
            <%} else if(obj.AiuInfo[i].fnNativeInterface == 'CHI-D'){%>
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].chi_spec_revision    = svt_chi_node_configuration::ISSUE_D;
            <%} else if(obj.AiuInfo[i].fnNativeInterface == 'CHI-E'){%>
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].chi_spec_revision    = svt_chi_node_configuration::ISSUE_E;
            <%}%>
            // set RN VIP to Generate Maximum Throughput for bandwidth_test
            if($test$plusargs("performance_test"))begin
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].num_outstanding_xact = 50;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].delays_enable = 0;
            end
                
            if($test$plusargs("en_snps_vip_performance_calc"))begin
                // Following are the prerequisites to do performance monitoring interval
                // configure RN
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_recording_interval = -1;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_min_write_xact_latency = 100;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_min_read_xact_latency = 100;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_max_write_xact_latency = 20000000;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_max_read_xact_latency = 20000000;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_avg_min_write_xact_latency = 100;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_avg_min_read_xact_latency = 100;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_avg_max_write_xact_latency = 20000000;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_avg_max_read_xact_latency = 20000000;
                
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_min_write_throughput = 0.001;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_min_read_throughput = 0.00001;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_max_write_throughput = 200000;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_max_read_throughput = 200000;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_exclude_inactive_periods_for_throughput = 1;
                chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].perf_inactivity_algorithm_type = svt_chi_node_configuration::EXCLUDE_BEGIN_END; 
            end

            chi_sys_cfg.rn_cfg[<%=l_chi_idx%>].is_active = 1;
            <%l_chi_idx++%>
            <%}%>
        <%}%>
    endfunction:set_chi_system_configuration

    //----------------------------------------------------------------------------------------------- 
    //  utility method in the testbench to configure the axi master configuration parameter
    //-------------------------------------------------------------------------------------------------
    
    function void set_axi_system_configuration(svt_axi_system_configuration axi_sys_cfg);
        axi_sys_cfg.num_masters = <%=nIOAIUs%>;
        axi_sys_cfg.num_slaves  = <%=obj.nDMIs+obj.nDIIs -1%>;
        axi_sys_cfg.bus_inactivity_timeout = 0;
        axi_sys_cfg.system_monitor_enable = 0;
        axi_sys_cfg.allow_slaves_with_overlapping_addr = 1;
                
        /** Set Clock Mode */
        axi_sys_cfg.common_clock_mode = 0;
        axi_sys_cfg.create_sub_cfgs(<%=nIOAIUs%>,<%=obj.nDMIs+obj.nDIIs -1%>,0,0);
        axi_sys_cfg.wready_watchdog_timeout                 = 0;
        axi_sys_cfg.rdata_watchdog_timeout                  = 0;
        axi_sys_cfg.bready_watchdog_timeout                 = 0;
        axi_sys_cfg.bresp_watchdog_timeout                  = 0;

        <%var pidx = 0;%>
        <%for(let idx = 0; idx < obj.AiuInfo.length; idx++){%>
            <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){
                for (var mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                    axi_sys_cfg.master_cfg[<%=pidx%>].is_active                    = 1;
                    axi_sys_cfg.master_cfg[<%=pidx%>].num_outstanding_xact         = 128;
                    if($test$plusargs("performance_test"))begin
                        axi_sys_cfg.master_cfg[<%=pidx%>].zero_delay_enable        = 1; 
                    end
                    <%if (obj.AiuInfo[idx].fnNativeInterface == "ACE-LITE" || obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E' ){%>
                        axi_sys_cfg.master_cfg[<%=pidx%>].axi_interface_type       = svt_axi_port_configuration::ACE_LITE;
                    <%}else if (obj.AiuInfo[idx].fnNativeInterface == "AXI4" || obj.AiuInfo[idx].fnNativeInterface == "AXI5" ) { %>    
                        axi_sys_cfg.master_cfg[<%=pidx%>].axi_interface_type       = svt_axi_port_configuration::AXI4;
                            <%if(obj.AiuInfo[idx].fnNativeInterface == 'AXI5' ){%>
                                axi_sys_cfg.master_cfg[<%=pidx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
                                axi_sys_cfg.master_cfg[<%=pidx%>].atomic_transactions_enable = <%=(obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.atomicTransactions==true)?1:0%>;
                                                            <%}%>
                    <%}else{%>  
                        axi_sys_cfg.master_cfg[<%=pidx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
                        axi_sys_cfg.master_cfg[<%=pidx%>].axi_interface_type           = svt_axi_port_configuration::AXI_ACE;
                        axi_sys_cfg.master_cfg[<%=pidx%>].enable_multi_cacheline_ace_wu_ro_xacts = 1;
                    <%}%>

                    //drive idles to LOW_VAL(zero)
                    //axi_sys_cfg.master_cfg[<%=pidx%>].read_addr_chan_idle_val        = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
                    //axi_sys_cfg.master_cfg[<%=pidx%>].read_data_chan_idle_val        = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
                    //axi_sys_cfg.master_cfg[<%=pidx%>].write_addr_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
                    //axi_sys_cfg.master_cfg[<%=pidx%>].write_data_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
                    //axi_sys_cfg.master_cfg[<%=pidx%>].write_resp_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;


                    //axi_sys_cfg.master_cfg[<%=pidx%>].update_cache_for_prot_type = 1;
                    //axi_sys_cfg.master_cfg[<%=pidx%>].tagged_address_space_attributes_enable            = 0;
                    //axi_sys_cfg.allow_slaves_with_overlapping_addr         = 1;      
                    axi_sys_cfg.master_cfg[<%=pidx%>].protocol_checks_enable       = 1;
                    axi_sys_cfg.master_cfg[<%=pidx%>].auto_gen_dvm_complete_enable = 1;
                    axi_sys_cfg.master_cfg[<%=pidx%>].addr_width                   = <%=obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.wAddr%>;
                    axi_sys_cfg.master_cfg[<%=pidx%>].data_width                   = <%=obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.wData%>;
                    axi_sys_cfg.master_cfg[<%=pidx%>].id_width                     = <%=Math.max(obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.wAwId,obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.wArId)%>;
                    <%if (obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>
                    axi_sys_cfg.master_cfg[<%=pidx%>].check_type                   = svt_axi_port_configuration::ODD_PARITY_BYTE_ALL;
                    <% if(obj.AiuInfo[idx].fnNativeInterface === "ACE" || obj.AiuInfo[idx].fnNativeInterface === "ACE5" || obj.AiuInfo[idx].fnNativeInterface === "AXI5" ) { %>
                    axi_sys_cfg.master_cfg[<%=pidx%>].trace_tag_enable                   = 0;
                    <%}else{%>  
                    axi_sys_cfg.master_cfg[<%=pidx%>].trace_tag_enable                   = 1;
                    <%}%>
                    <%}%>
                    <% if(obj.AiuInfo[idx].fnNativeInterface === "ACE" || obj.AiuInfo[idx].fnNativeInterface === "ACE5") { %>
                        axi_sys_cfg.master_cfg[<%=pidx%>].snoop_data_width         = <%=obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.wCdData%>;
                    <%}%>
                    axi_sys_cfg.master_cfg[<%=pidx%>].cache_line_size              = <%=Math.pow(2, obj.wCacheLineOffset)%>;
                    axi_sys_cfg.master_cfg[<%=pidx%>].num_cache_lines              = 2048;
                    //axi_sys_cfg.master_cfg[<%=pidx%>].speculative_read_enable      = 1;
                    <%if (obj.AiuInfo[idx].fnNativeInterface == "ACE-LITE"){%>
                        axi_sys_cfg.master_cfg[<%=pidx%>].dvm_enable               = 0; 
                    <%}else{%>  
                        <%if(obj.AiuInfo[idx].fnNativeInterface == "ACELITE-E") {%>
                            axi_sys_cfg.master_cfg[<%=pidx%>].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;
                            axi_sys_cfg.master_cfg[<%=pidx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
                            axi_sys_cfg.master_cfg[<%=pidx%>].atomic_transactions_enable   = 0; 
                            axi_sys_cfg.master_cfg[<%=pidx%>].cache_stashing_enable = 1;
                            <%if (obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.eAc > 0) { %>
                            axi_sys_cfg.master_cfg[<%=pidx%>].dvm_enable               = (<%=obj.AiuInfo[idx].cmpInfo.nDvmMsgInFlight%> > 0); 
                            <%}else{%>
                            axi_sys_cfg.master_cfg[<%=pidx%>].dvm_enable               = 0; 
                            <%}%>
                            axi_sys_cfg.master_cfg[<%=pidx%>].deallocating_xacts_enable = 1;
                        <%}%>
                    <%}%>      
                    axi_sys_cfg.master_cfg[<%=pidx%>].barrier_enable               = 0; 
                    <% if(1==0) { %>
                        axi_sys_cfg.master_cfg[<%=pidx%>].enable_domain_based_addr_gen = 1;   
                    <%}%>      
                    axi_sys_cfg.master_cfg[<%=pidx%>].enable_xml_gen               = 0;      
                    axi_sys_cfg.master_cfg[<%=pidx%>].transaction_coverage_enable  = 0;      

                    <%if (obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.wArUser > 0) { %>
                        axi_sys_cfg.master_cfg[<%=pidx%>].aruser_enable                = 1;
                    <%}else{%>
                        axi_sys_cfg.master_cfg[<%=pidx%>].aruser_enable                = 0;
                    <%}%>

                    <%if (obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.wAwUser > 0) { %>
                        axi_sys_cfg.master_cfg[<%=pidx%>].awuser_enable                = 1;
                    <%}else{%>
                        axi_sys_cfg.master_cfg[<%=pidx%>].awuser_enable                = 0;
                    <%}%>
                    <%if (obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.wRUser > 0){%>
                        axi_sys_cfg.master_cfg[<%=pidx%>].ruser_enable                 = 1;
                    <%}else{%>
                        axi_sys_cfg.master_cfg[<%=pidx%>].ruser_enable                 = 0;
                    <%}%>
                    <%if (obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.wWUser > 0) { %>
                        axi_sys_cfg.master_cfg[<%=pidx%>].wuser_enable                 = 1;
                    <%}else {%>
                        axi_sys_cfg.master_cfg[<%=pidx%>].wuser_enable                 = 0;
                    <%}%>

                    <%if (obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.wBUser > 0) { %>
                        axi_sys_cfg.master_cfg[<%=pidx%>].buser_enable                 = 1;
                    <%}else{%>
                        axi_sys_cfg.master_cfg[<%=pidx%>].buser_enable                 = 0;
                    <%}%>
                    <%if (obj.AiuInfo[idx].interfaces.axiInt[mpu_io].params.wQos > 0) { %>
                        axi_sys_cfg.master_cfg[<%=pidx%>].awqos_enable                 = 1;
                        axi_sys_cfg.master_cfg[<%=pidx%>].arqos_enable                 = 1;
                    <%}else{%>
                        axi_sys_cfg.master_cfg[<%=pidx%>].awqos_enable                 = 0;
                        axi_sys_cfg.master_cfg[<%=pidx%>].arqos_enable                 = 0;
                    <%}%>
                    // bandwidth_test		
                    if($test$plusargs("performance_test"))begin
                        axi_sys_cfg.master_cfg[<%=pidx%>].zero_delay_enable 	       = 1;
                    end 

                    <%if (obj.AiuInfo[idx].fnNativeInterface == "ACE" || obj.AiuInfo[idx].fnNativeInterface == "ACE5" ) { %>
                        axi_sys_cfg.master_cfg[<%=pidx%>].writeevict_enable            = 1;
                        axi_sys_cfg.master_cfg[<%=pidx%>].awunique_enable              = 1;
                    <%}%> 
                    <%pidx++;%>
                <%}%>
            <%}%>
        <%}%>


        //for slaves
        <%
        var pidx = 0;
        for(pidx =  0; pidx < obj.nDMIs; pidx++) {%>
            axi_sys_cfg.set_addr_range(<%=pidx%>, 'h0, `INNERSHAREABLE_END_ADDR);
            axi_sys_cfg.slave_cfg[<%=pidx%>].is_active                    = 1;
            //axi_sys_cfg.master_cfg[<%=pidx%>].read_addr_chan_idle_val        = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
            //axi_sys_cfg.master_cfg[<%=pidx%>].read_data_chan_idle_val        = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
            //axi_sys_cfg.master_cfg[<%=pidx%>].write_addr_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
            //axi_sys_cfg.master_cfg[<%=pidx%>].write_data_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
            //axi_sys_cfg.master_cfg[<%=pidx%>].write_resp_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
            if($test$plusargs("performance_test"))begin
                axi_sys_cfg.slave_cfg[<%=pidx%>].zero_delay_enable          = 1; 	
                axi_sys_cfg.slave_cfg[<%=pidx%>].num_outstanding_xact       = -1; 	
                axi_sys_cfg.slave_cfg[<%=pidx%>].num_read_outstanding_xact  = 50;
                axi_sys_cfg.slave_cfg[<%=pidx%>].num_write_outstanding_xact = 50;
                axi_sys_cfg.slave_cfg[<%=pidx%>].id_width                   = <%=Math.max(obj.DmiInfo[pidx].interfaces.axiInt.params.wAwId,obj.DmiInfo[pidx].interfaces.axiInt.params.wArId)%>;
            end else begin
                axi_sys_cfg.slave_cfg[<%=pidx%>].zero_delay_enable          = 0; 	
                axi_sys_cfg.slave_cfg[<%=pidx%>].num_read_outstanding_xact  = 1;
                axi_sys_cfg.slave_cfg[<%=pidx%>].num_write_outstanding_xact = 10;
                axi_sys_cfg.slave_cfg[<%=pidx%>].id_width                   = <%=Math.max(obj.DmiInfo[pidx].interfaces.axiInt.params.wAwId,obj.DmiInfo[pidx].interfaces.axiInt.params.wArId)%>;
            end
            axi_sys_cfg.slave_cfg[<%=pidx%>].axi_interface_type           = svt_axi_port_configuration::AXI4;
            axi_sys_cfg.slave_cfg[<%=pidx%>].protocol_checks_enable       = 1;
            axi_sys_cfg.slave_cfg[<%=pidx%>].addr_width                   = <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wAddr%>;
            axi_sys_cfg.slave_cfg[<%=pidx%>].data_width                   = <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wData%>;
            axi_sys_cfg.slave_cfg[<%=pidx%>].enable_xml_gen               = 0;
            axi_sys_cfg.slave_cfg[<%=pidx%>].transaction_coverage_enable  = 0;
            axi_sys_cfg.slave_cfg[<%=pidx%>].default_arready              = 0;
            axi_sys_cfg.slave_cfg[<%=pidx%>].default_awready              = 0;
            axi_sys_cfg.slave_cfg[<%=pidx%>].default_wready               = 0;
                
            <%if(obj.DmiInfo[pidx].interfaces.axiInt.params.wArUser > 0){%>
                axi_sys_cfg.slave_cfg[<%=pidx%>].aruser_enable                = 1;
            <%}else{%>
                axi_sys_cfg.slave_cfg[<%=pidx%>].aruser_enable                = 0;
            <%}%>

            <%if(obj.DmiInfo[pidx].interfaces.axiInt.params.wAwUser > 0) { %>
                axi_sys_cfg.slave_cfg[<%=pidx%>].awuser_enable                = 1;
            <%}else{%>
                axi_sys_cfg.slave_cfg[<%=pidx%>].awuser_enable                = 0;
            <%}%>

            <%if(obj.DmiInfo[pidx].interfaces.axiInt.params.wRUser > 0) { %>
                axi_sys_cfg.slave_cfg[<%=pidx%>].ruser_enable                 = 1;
            <%} else {%>
                axi_sys_cfg.slave_cfg[<%=pidx%>].ruser_enable                 = 0;
            <%}%>

            <%if (obj.DmiInfo[pidx].interfaces.axiInt.params.wWUser > 0) { %>
                axi_sys_cfg.slave_cfg[<%=pidx%>].wuser_enable                 = 1;
            <%}else {%>
                axi_sys_cfg.slave_cfg[<%=pidx%>].wuser_enable                 = 0;
            <%}%>

            <%if (obj.DmiInfo[pidx].interfaces.axiInt.params.wBUser > 0) { %>
                axi_sys_cfg.slave_cfg[<%=pidx%>].buser_enable                 = 1;
            <%}else {%>
                axi_sys_cfg.slave_cfg[<%=pidx%>].buser_enable                 = 0;
            <%}%>
            <%if (obj.DmiInfo[pidx].interfaces.axiInt.params.wQos > 0) { %>
                axi_sys_cfg.slave_cfg[<%=pidx%>].awqos_enable                 = 1;
                axi_sys_cfg.slave_cfg[<%=pidx%>].arqos_enable                 = 1;
            <%}else{%>
                axi_sys_cfg.slave_cfg[<%=pidx%>].awqos_enable                 = 0;
                axi_sys_cfg.slave_cfg[<%=pidx%>].arqos_enable                 = 0;
            <%}%>
        <%}%>
        <%for(var diipidx = 0; diipidx < obj.nDIIs; diipidx++) {%>
            <%if(obj.DiiInfo[diipidx].configuration == 0) {   	%>
                axi_sys_cfg.set_addr_range(<%=pidx%>, 'h0, `INNERSHAREABLE_END_ADDR);
                axi_sys_cfg.slave_cfg[<%=pidx%>].is_active                    = 1;
                axi_sys_cfg.slave_cfg[<%=pidx%>].num_read_outstanding_xact    = 1;
                axi_sys_cfg.slave_cfg[<%=pidx%>].num_write_outstanding_xact   = 10;
                axi_sys_cfg.slave_cfg[<%=pidx%>].axi_interface_type           = svt_axi_port_configuration::AXI4;
                axi_sys_cfg.slave_cfg[<%=pidx%>].protocol_checks_enable       = 1;
                axi_sys_cfg.slave_cfg[<%=pidx%>].addr_width                   = <%=obj.DiiInfo[diipidx].interfaces.axiInt.params.wAddr%>;
                axi_sys_cfg.slave_cfg[<%=pidx%>].data_width                   = <%=obj.DiiInfo[diipidx].interfaces.axiInt.params.wData%>;
                axi_sys_cfg.slave_cfg[<%=pidx%>].id_width                     = <%=Math.max(obj.DiiInfo[diipidx].interfaces.axiInt.params.wAwId,obj.DiiInfo[diipidx].interfaces.axiInt.params.wArId)%>;
                axi_sys_cfg.slave_cfg[<%=pidx%>].enable_xml_gen               = 0;
                axi_sys_cfg.slave_cfg[<%=pidx%>].transaction_coverage_enable  = 0;
                axi_sys_cfg.slave_cfg[<%=pidx%>].default_arready              = 0;
                axi_sys_cfg.slave_cfg[<%=pidx%>].default_awready              = 0;
                axi_sys_cfg.slave_cfg[<%=pidx%>].default_wready               = 0;
                
                <%if(obj.DiiInfo[diipidx].interfaces.axiInt.params.wArUser > 0) { %>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].aruser_enable                = 1;
                <%}else {%>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].aruser_enable                = 0;
                <%}%>

                <%if(obj.DiiInfo[diipidx].interfaces.axiInt.params.wAwUser > 0) { %>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].awuser_enable                = 1;
                <%}else{%>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].awuser_enable                = 0;
                <%}%>

                <%if(obj.DiiInfo[diipidx].interfaces.axiInt.params.wRUser > 0) { %>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].ruser_enable                 = 1;
                <%}else{%>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].ruser_enable                 = 0;
                <%}%>

                <%if (obj.DiiInfo[diipidx].interfaces.axiInt.params.wWUser > 0) { %>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].wuser_enable                 = 1;
                <%} else {%>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].wuser_enable                 = 0;
                <%}%>

                <%if (obj.DiiInfo[diipidx].interfaces.axiInt.params.wBUser > 0) { %>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].buser_enable                 = 1;
                <%} else {%>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].buser_enable                 = 0;
                <%}%>
                <%if(obj.DiiInfo[diipidx].interfaces.axiInt.params.wQos > 0) { %>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].awqos_enable                 = 1;
                    axi_sys_cfg.slave_cfg[<%=pidx%>].arqos_enable                 = 1;
                <%}else {%>
                    axi_sys_cfg.slave_cfg[<%=pidx%>].awqos_enable                 = 0;
                    axi_sys_cfg.slave_cfg[<%=pidx%>].arqos_enable                 = 0;
                <%}%>
                <%pidx++;%>
            <%}%>
        <%}%>

    endfunction:set_axi_system_configuration

    <%if(obj.useResiliency == 1 || (obj.DebugApbInfo.length>0)){%>
        function void set_apb_system_configuration(svt_apb_system_configuration apb_sys_cfg);
            <%if(obj.useResiliency == 1 && (obj.DebugApbInfo.length > 0)){%>
                int nApbPorts = 2;
            <%}else{%>
                int nApbPorts = 1;
            <%}%>
            apb_sys_cfg.create_sub_cfgs(nApbPorts);
            apb_sys_cfg.slave_addr_allocation_enable = 1;
            apb_sys_cfg.wait_for_reset_enable = 1;
            apb_sys_cfg.disable_x_check_of_presetn = 0;
            apb_sys_cfg.disable_x_check_of_pclk = 0;
            apb_sys_cfg.slave_addr_allocation_enable = 1;
            apb_sys_cfg.paddr_width = svt_apb_system_configuration::paddr_width_enum'(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>); //warning: Illegal assignment to enum variable
            apb_sys_cfg.pdata_width = svt_apb_system_configuration::pdata_width_enum'(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wData%>);
            apb_sys_cfg.apb3_enable = 0;
            apb_sys_cfg.apb4_enable = 1;
            /** Master setup */
            apb_sys_cfg.is_active = 1;
            apb_sys_cfg.enable_xml_gen = 1;
            for(int i=0; i<nApbPorts;i++) begin
                apb_sys_cfg.slave_cfg[i].enable_xml_gen = 1;
                apb_sys_cfg.slave_cfg[i].is_active = 0;
            end
            

            /** Enable UVM APB Ral Adapter */
            apb_sys_cfg.uvm_reg_enable = 1;

            apb_sys_cfg.transaction_coverage_enable = 0;
            apb_sys_cfg.protocol_checks_coverage_enable = 0;
            apb_sys_cfg.transaction_coverage_enable = 0;
            apb_sys_cfg.protocol_checks_coverage_enable = 0;
            
        endfunction:set_apb_system_configuration
    <%}%>
endclass

