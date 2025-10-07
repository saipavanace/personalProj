//TODO: add js code here
<%if (obj.testBench == "io_aiu") {%>
`define NUM_MASTERS 1
`define NUM_SLAVES  0
<%}

if (obj.testBench == "fsys") {
  var pidx = 0;
  var axiaiu_master = 0;
  var axiaiu_slave = 0;

  for(pidx = 0; pidx < obj.nAIUs; pidx++) { 
    if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI5')||(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')) {
      if(obj.AiuInfo[pidx].interfaces.axiInt.direction == 'slave') { axiaiu_master++;}
      if(obj.AiuInfo[pidx].interfaces.axiInt.direction == 'master') { axiaiu_slave++;}
}}%>
`define NUM_MASTERS <%=axiaiu_master%>
`define NUM_SLAVES  <%=axiaiu_slave%>
<%}%>
class ace_env_config extends svt_axi_system_configuration;

  /** UVM Object Utility macro */
  `uvm_object_utils (ace_env_config)

  rand int default_sequence_length;
  addrMgrConst::sys_addr_csr_t csrq[$];
  addrMgrConst::intq noncoh_regionsq;
  addrMgrConst::intq coh_regionsq;
  addrMgrConst::intq iocoh_regionsq;
  addr_trans_mgr    m_addr_mgr;
  ncore_memory_map m_map;


  /** Class Constructor */
  function new (string name = "ace_env_config");
    super.new(name);

    default_sequence_length = 15;
    this.num_masters = `NUM_MASTERS;
    this.num_slaves  = `NUM_SLAVES;

    /** Create port configurations */
    /* 3rd and 4th arguments are for intercconnect */
    this.create_sub_cfgs(`NUM_MASTERS,`NUM_SLAVES,0,0);

    this.bus_inactivity_timeout = 0;
    this.use_interconnect = 0;
    this.system_monitor_enable = 0;
    //set_ace_config();
    //set_ace_domains();
  endfunction : new

  function void set_ace_domains();
    int inner_domain_masters_0[],non_shareable_master_0[];
    bit [63:0] start_addr;
    bit [63:0] end_addr;
    bit [63:0] domain_size;
     bit [63:0] adress_range [$];
    bit mem_regions_overlap;
    bit non, innr;
    `uvm_info(get_name(),$psprintf("inside ace_env_config::set_ace_domains"),UVM_NONE)
    csrq = addrMgrConst::get_all_gpra();
    if(csrq.size() == 0)`uvm_info(get_name(),$psprintf("empty csrq inside ace_env_config::set_ace_domains"),UVM_NONE)
 /*   foreach (csrq[i]) begin
      `uvm_info(get_name(),
          $psprintf("unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d",
              csrq[i].unit.name(), csrq[i].mig_nunitid,
              csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
          UVM_NONE) 
    end*/
  m_map = m_addr_mgr.get_memory_map_instance(); 
  noncoh_regionsq = m_map.get_noncoh_mem_regions();
  iocoh_regionsq = m_map.get_iocoh_mem_regions();
  coh_regionsq = m_map.get_coh_mem_regions();

    foreach(iocoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(iocoh_regionsq[indx], start_addr, end_addr);
        end_addr--;
        domain_size = end_addr - start_addr;
        foreach(adress_range[i]) begin
        if(adress_range[i] == start_addr)
        mem_regions_overlap = 1;
        end
        if(non==0) begin
          non_shareable_master_0 = new[1];
          non_shareable_master_0 = {0};
          void'(create_new_domain(0,svt_axi_system_domain_item::NONSHAREABLE,non_shareable_master_0));
          non=1;
        end
        if(mem_regions_overlap==0)
        set_addr_for_domain(0,start_addr,end_addr);
        mem_regions_overlap =0;
        adress_range.push_front(start_addr);
        `uvm_info(get_name(),$psprintf("ace_env_config:: set_addr_for_domain[%0d]:NONSHAREABLE start_addr 0x%0h end_addr 0x%0h domain_size 'd%0d",0,start_addr,end_addr,domain_size),UVM_NONE)
      end
    foreach(noncoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(noncoh_regionsq[indx], start_addr, end_addr);
        end_addr--;
        domain_size = end_addr - start_addr;
        foreach(adress_range[i]) begin
        if(adress_range[i] == start_addr)
        mem_regions_overlap = 1;
        end
        if(non==0) begin
          non_shareable_master_0 = new[1];
          non_shareable_master_0 = {0};
          void'(create_new_domain(0,svt_axi_system_domain_item::NONSHAREABLE,non_shareable_master_0));
          non=1;
        end
        if(mem_regions_overlap==0) 
        set_addr_for_domain(0,start_addr,end_addr);
        adress_range.push_front(start_addr);
        mem_regions_overlap =0;
        `uvm_info(get_name(),$psprintf("ace_env_config:: set_addr_for_domain[%0d]:NONSHAREABLE start_addr 0x%0h end_addr 0x%0h domain_size 'd%0d",0,start_addr,end_addr,domain_size),UVM_NONE)
      end
    foreach(coh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(coh_regionsq[indx], start_addr, end_addr);
        end_addr--;
        domain_size = end_addr - start_addr;
        if(innr==0) begin
          inner_domain_masters_0 = new[1];
          inner_domain_masters_0 = {0};
          void'(create_new_domain(1,svt_axi_system_domain_item::INNERSHAREABLE,inner_domain_masters_0));
          innr=1;
        end
        foreach(adress_range[i]) begin
        if(adress_range[i] == start_addr)
        mem_regions_overlap = 1;
        end
        if(mem_regions_overlap==0) 
        set_addr_for_domain(1,start_addr,end_addr);
        adress_range.push_front(start_addr);
         mem_regions_overlap =0;
        //this.master_cfg[0].set_addr_range(start_addr, end_addr, 1);
        //this.master_cfg[0].set_addr_range(start_addr, end_addr, 0);
        //set_addr_range(2*indx, start_addr, end_addr, 0, 1);
        //set_addr_range(2*indx + 1, start_addr, end_addr, 0, 0);
        `uvm_info(get_name(),$psprintf("ace_env_config:: set_addr_for_domain[%0d]:INNERSHAREABLE start_addr 0x%0h end_addr 0x%0h domain_size 'd%0d",1,start_addr,end_addr,domain_size),UVM_NONE)
    end
  endfunction: set_ace_domains

    function void set_ace_config();
        <%
        let computedAxiInt;
        if(Array.isArray(obj.DutInfo.interfaces.axiInt)){
            computedAxiInt = obj.DutInfo.interfaces.axiInt[0];
        }else{
            computedAxiInt = obj.DutInfo.interfaces.axiInt;
        }
        %>
    //TODO:add js code here
<%if (obj.testBench == "io_aiu") { 
      if(obj.DutInfo.fnNativeInterface == 'AXI4' && !obj.DutInfo.useCache) {%>
    this.master_cfg[0].axi_interface_type           = svt_axi_port_configuration::AXI4;<%}%>
<%if(obj.DutInfo.fnNativeInterface == 'ACE'||obj.DutInfo.fnNativeInterface == 'ACE5') {%>
    this.master_cfg[0].axi_interface_type           = svt_axi_port_configuration::AXI_ACE;
<%}%>
<%if(obj.DutInfo.fnNativeInterface == 'ACE-LITE' || (obj.DutInfo.fnNativeInterface == "AXI4" && obj.DutInfo.useCache)) {%>
    this.master_cfg[0].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;<%}%>
<%if(obj.DutInfo.fnNativeInterface == 'ACELITE-E') {%>
    this.master_cfg[0].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;//need to check if ACE_LITE_E is there in svt_axi_port_configuration
    this.master_cfg[0].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
    this.master_cfg[0].atomic_transactions_enable   = 1;
    this.master_cfg[0].deallocating_xacts_enable    = 1;
<%}%>
<%if(obj.DutInfo.fnNativeInterface == 'ACE'||obj.DutInfo.fnNativeInterface == 'ACE5'|| computedAxiInt.params.eAc==1) {%>
    this.master_cfg[0].dvm_enable                   = 1;
<%}%>
    this.master_cfg[0].is_active                    = 1;
    this.master_cfg[0].addr_width                   = <%=computedAxiInt.params.wAddr%>;
    this.master_cfg[0].data_width                   = <%=computedAxiInt.params.wData%>;
    this.master_cfg[0].snoop_data_width             = <%=(computedAxiInt.params.wCdData>0)?computedAxiInt.params.wCdData:0%>;
    this.master_cfg[0].cache_line_size              = 64; //json param? // c3.1.5
    this.master_cfg[0].speculative_read_enable      = 1;
   //  this.master_cfg[0].cache_line_state_change_type  = svt_axi_port_configuration::LEGAL_WITHOUT_SNOOP_FILTER_CACHE_LINE_STATE_CHANGE; 
    //this.master_cfg[0].num_cache_lines              = 256;
    this.master_cfg[0].enable_domain_based_addr_gen = 1;
    //this.master_cfg[0].enable_xml_gen               = 1;
    //this.master_cfg[0].transaction_coverage_enable  = 1;
    this.master_cfg[0].zero_delay_enable            = 1;
    this.master_cfg[0].update_cache_for_prot_type = 1;
    this.master_cfg[0].tagged_address_space_attributes_enable            = 1;
    this.allow_slaves_with_overlapping_addr         = 1;
    this.master_cfg[0].addr_width                   = `SVT_AXI_ADDR_WIDTH - 1;
    this.master_cfg[0].aruser_enable                = <%=(computedAxiInt.params.wArUser>0)?1:0%>;
    this.master_cfg[0].awuser_enable                = <%=(computedAxiInt.params.wAwUser>0)?1:0%>;
    this.master_cfg[0].ruser_enable                 = <%=(computedAxiInt.params.wRUser>0)?1:0%>;
    this.master_cfg[0].wuser_enable                 = <%=(computedAxiInt.params.wWUser>0)?1:0%>;
    this.master_cfg[0].buser_enable                 = <%=(computedAxiInt.params.wBUser>0)?1:0%>;
    this.master_cfg[0].writeevict_enable            = <%=(computedAxiInt.params.eUnique>0)?1:0%>;
    this.master_cfg[0].awunique_enable              = <%=(computedAxiInt.params.eUnique>0)?1:0%>;
    this.master_cfg[0].awqos_enable                 = <%=(computedAxiInt.params.wQos>0)?1:0%>;
    this.master_cfg[0].arqos_enable                 = <%=(computedAxiInt.params.wQos>0)?1:0%>;
<% if(computedAxiInt.params.wArId!=computedAxiInt.params.wAwId){%>
    this.master_cfg[0].use_separate_rd_wr_chan_id_width = 1;
    this.master_cfg[0].write_chan_id_width          = <%=computedAxiInt.params.wAwId%>;
    this.master_cfg[0].read_chan_id_width           = <%=computedAxiInt.params.wArId%>;
<%}%>
    this.wready_watchdog_timeout                 = 0;
if($test$plusargs("wrong_updrsp_target_id")||$test$plusargs("wrong_cmdrsp_target_id")||$test$plusargs("wrong_dtwrsp_target_id")||$test$plusargs("wrong_dtrrsp_target_id")||$test$plusargs("wrong_dtrreq_target_id")||$test$plusargs("wrong_strreq_target_id")||$test$plusargs("wrong_snpreq_target_id")) begin
    this.rdata_watchdog_timeout                     = 0; //CONC-8664//disable timeout
    this.bresp_watchdog_timeout                     = 0; //CONC-8664//disable timeout
    this.manage_objections_enable                   = 0; //CONC-8664//disable objections//required if response is dropped
end
<%}%>

    <%
    //Embedded javascript code to figure number of blocks
    var pidx = 0;
    var axiaiu_idx = 0;
    if (obj.testBench == "fsys") { 
        for(pidx = 0; pidx < obj.nAIUs; pidx++) { 
            let l_computedAxiInt;
            if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
                l_computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
            }else{
                l_computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
            }
            
            if(((obj.AiuInfo[pidx].fnNativeInterface == 'AXI5')||(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')) && l_computedAxiInt.direction == 'slave') {
                if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') {%>
                    this.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::AXI4;
                <%}%>
                <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE'||obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') {%>
                    this.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::AXI_ACE;
                <%}%>
                <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') {%>
                    this.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;
                <%}%>
                <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') {%>
                    this.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;//need to check if ACE_LITE_E is there in svt_axi_port_configuration
                <%}%>
                this.master_cfg[<%=axiaiu_idx%>].is_active                    = 1;
                this.master_cfg[<%=axiaiu_idx%>].addr_width                   = <%=l_computedAxiInt.params.wAddr%>;
                this.master_cfg[<%=axiaiu_idx%>].data_width                   = <%=l_computedAxiInt.params.wData%>;
                this.master_cfg[<%=axiaiu_idx%>].snoop_data_width             = <%=(l_computedAxiInt.params.wCdData>0)?computedAxiInt.params.wCdData:0
            %>;
            this.master_cfg[<%=axiaiu_idx%>].cache_line_size              = 64; //json param? // c3.1.5
            this.master_cfg[<%=axiaiu_idx%>].dvm_enable                   = 1;
            this.master_cfg[<%=axiaiu_idx%>].enable_domain_based_addr_gen = 1;
            this.master_cfg[<%=axiaiu_idx%>].transaction_coverage_enable  = 1;
            this.master_cfg[<%=axiaiu_idx%>].aruser_enable                = <%=(l_computedAxiInt.params.wArUser>0)?1:0%>;
            this.master_cfg[<%=axiaiu_idx%>].awuser_enable                = <%=(l_computedAxiInt.params.wAwUser>0)?1:0%>;
            this.master_cfg[<%=axiaiu_idx%>].ruser_enable                 = <%=(l_computedAxiInt.params.wRUser>0)?1:0%>;
            this.master_cfg[<%=axiaiu_idx%>].wuser_enable                 = <%=(l_computedAxiInt.params.wWUser>0)?1:0%>;
            this.master_cfg[<%=axiaiu_idx%>].buser_enable                 = <%=(l_computedAxiInt.params.wBUser>0)?1:0%>;
            this.master_cfg[<%=axiaiu_idx%>].writeevict_enable            = <%=(l_computedAxiInt.params.eUnique>0)?1:0%>;
            this.master_cfg[<%=axiaiu_idx%>].awunique_enable              = <%=(l_computedAxiInt.params.eUnique>0)?1:0%>;
            this.master_cfg[<%=axiaiu_idx%>].awqos_enable                 = <%=(l_computedAxiInt.params.wQos>0)?1:0%>;
            this.master_cfg[<%=axiaiu_idx%>].arqos_enable                 = <%=(l_computedAxiInt.params.wQos>0)?1:0%>;
            <%axiaiu_idx++;
            }
        }
    }%>
endfunction: set_ace_config

endclass

