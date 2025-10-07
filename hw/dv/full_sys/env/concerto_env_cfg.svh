
////////////////////////////////////////////////////////////////////////////////
//
// concerto_env_cfg 
<% if (1 == 0) { %>
// Author: Satya Prakash
<% } %>
//
////////////////////////////////////////////////////////////////////////////////
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var pidx = 0;
   var qidx = 0;
   var idx  = 0;
   var ridx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
   var aiu_NumCores = [];
   var aiu_axiIntLen = [];

   for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
     if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
         aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
     } else {
         aiu_NumCores[pidx]    = 1;
     }
   }


   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
           _child_blkid[pidx] = 'chiaiu' + idx;
           _child_blk[pidx]   = 'chiaiu';
        idx++;
       } else {
	   _child_blkid[pidx] = 'ioaiu' + qidx;
           _child_blk[pidx]   = 'ioaiu';
           qidx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
   }
%>

class concerto_env_cfg extends uvm_object;
    //////////////////////////////////
    //UVM Registery
    //////////////////////////////////    
    `uvm_object_param_utils(concerto_env_cfg)
    bit enable_fsys_scb = 1;
    string funit_to_unitname_arr[int];
    mem_checker_cfg m_mem_checker_cfg;

<% if(obj.testBench=="emu"){ %>
       virtual mgc_resp_intf mgc_resp_if;
   <% } %>
<% if(obj.PmaInfo.length > 0) {
   for(var i=0; i<obj.PmaInfo.length; i++) { %>
   q_chnl_agent_config  m_q_chnl<%=i%>_agent_cfg;
   <% } %>
<% } %>
    
    cust_svt_amba_system_configuration svt_cfg;

<% if(obj.useResiliency == 1){ %>
   apb_debug_apb_agent_pkg::apb_agent_config m_apb_resiliency_cfg;
<% } %>
    <% if(obj.DebugApbInfo.length > 0) { %>
   apb_debug_apb_agent_pkg::apb_agent_config m_apb_debug_cfg;
    <% } %>

    //Handle for all Concerto env config objects
<% for(var pidx in _child_blkid) { %>
    <% if ( _child_blkid[pidx].match('ioaiu')) {%> 
    <%=_child_blkid[pidx]%>_env_pkg::<%=_child_blk[pidx]%>_env_config m_<%=_child_blkid[pidx]%>_env_cfg[<%=obj.AiuInfo[pidx].nNativeInterfacePorts%>];
    <%}// ioaiu%>
    <% if(_child_blkid[pidx].match('dmi') || _child_blkid[pidx].match('dii') || _child_blkid[pidx].match('chiaiu') || _child_blkid[pidx].match('dce') || _child_blkid[pidx].match('dve')) { %>
    <%=_child_blkid[pidx]%>_env_pkg::<%=_child_blk[pidx]%>_env_config m_<%=_child_blkid[pidx]%>_env_cfg;
    <%  } // others%>
<%  } //foreach pidx%>

    bit [<%=obj.nAIUs%>-1:0] sysco_implemented; // AIU[Unitindex]

    bit has_vip_snps;
    `ifdef USE_VIP_SNPS_CHI
      bit has_chi_vip_snps = 1;
    `else
      bit has_chi_vip_snps = 0;
    `endif
    `ifdef USE_VIP_SNPS_AXI_MASTERS
    bit has_ace_vip_snps=1;
    bit has_axi_vip_snps=1;
    `else
    bit has_ace_vip_snps =0;
    bit has_axi_vip_snps = 0;
    `endif
    `ifdef USE_VIP_SNPS_APB
    bit has_apb_vip_snps = 1;
    `else
    bit has_apb_vip_snps = 0;
    `endif
    `ifdef USE_VIP_SNPS_AXI_SLAVES
      bit has_axi_slv_vip_snps = 1;
    `else
      bit has_axi_slv_vip_snps = 0;
    `endif

    bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[] = new[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS];
    
    bit use_rw_csr_snps;
    int reduce_mem_size;
    //////////////////////////////////
    //Methods
    //////////////////////////////////
    extern function new(string name = "concerto_env_cfg");
    extern function void construct_apb_config();
    extern function void construct_chiaiu_config();
    extern function void construct_ioaiu_config();
    extern function void construct_dmi_config();
    extern function void construct_dii_config();
    extern function void construct_dce_config();
    extern function void construct_dve_config();
    extern function void construct_unit_name_array();
endclass:concerto_env_cfg
//////////////////////////////////
//Description: Constructor
//Arguments:   UVM Default
//Return type: N/A
//////////////////////////////////
function concerto_env_cfg::new(string name = "concerto_env_cfg");
    super.new(name);

   <%for(pidx=0; pidx<obj.nAIUs; pidx++) {%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) || (((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || (obj.AiuInfo[pidx].fnNativeInterface == "ACE5") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache)) || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && (obj.AiuInfo[pidx].useCache)) ||((obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && (obj.AiuInfo[pidx].useCache==0) && (obj.AiuInfo[pidx].orderedWriteObservation==true)) ||  ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache==0) && (obj.AiuInfo[pidx].orderedWriteObservation==true)) || ((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") && (obj.AiuInfo[pidx].orderedWriteObservation==true)) || ((obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE") && (obj.AiuInfo[pidx].orderedWriteObservation==true))) {%>
       sysco_implemented[<%=pidx%>] = 1; //<%=obj.AiuInfo[pidx].fnNativeInterface%> with sysco
   <%}%>
   <%}%>
     if (!$value$plusargs("reduce_addr_area=%d",reduce_mem_size)) begin
      reduce_mem_size=64;
    end else begin
      if (reduce_mem_size==1) reduce_mem_size=64;
    end
    if ($test$plusargs("use_rw_csr_snps")) use_rw_csr_snps=1;
    if ($test$plusargs("use_chi_vip_snps")) has_chi_vip_snps=1;
    if ($test$plusargs("use_ace_vip_snps")) has_ace_vip_snps=1;
    if ($test$plusargs("use_ace_vip_snps")) has_axi_vip_snps=1;
    if ($test$plusargs("use_apb_vip_snps")) has_apb_vip_snps=1;
    if ($test$plusargs("use_axi_slave_snps")) has_axi_slv_vip_snps=1;

    <%if(obj.nCHIs == 0) {%>
        has_chi_vip_snps = 0;
    <%}%>

    if (has_chi_vip_snps || has_ace_vip_snps |has_apb_vip_snps || has_axi_vip_snps || has_axi_slv_vip_snps) begin
        has_vip_snps=1;
        svt_cfg = cust_svt_amba_system_configuration::type_id::create("svt_cfg");
        svt_cfg.set_amba_sys_config(has_axi_vip_snps,has_apb_vip_snps,has_chi_vip_snps); //supply set_amba_sys_config to downstream cfg_h
        svt_cfg.reduce_mem_size = reduce_mem_size;
        uvm_config_db#(cust_svt_amba_system_configuration)::set(uvm_root::get(), "", "svt_cfg", svt_cfg);
    end
    construct_apb_config();
    construct_chiaiu_config();
    construct_ioaiu_config();
    construct_dmi_config();
    construct_dii_config();
    construct_dce_config();
    construct_dve_config();
    construct_unit_name_array();
<% if(obj.PmaInfo.length > 0) {
   for(var i=0; i<obj.PmaInfo.length; i++) { %>
   m_q_chnl<%=i%>_agent_cfg = q_chnl_agent_config::type_id::create("m_q_chnl<%=i%>_agent_config");
   <% } %>
<% } %>
endfunction: new

function void concerto_env_cfg::construct_apb_config();

if (!has_apb_vip_snps) begin
   <% if(obj.useResiliency == 1){ %>
    m_apb_resiliency_cfg = apb_debug_apb_agent_pkg::apb_agent_config::type_id::create("m_apb_resiliency_cfg");
   
    if (!uvm_config_db#(virtual apb_debug_apb_if)::get(.cntxt( uvm_root::get() ),
                                           .inst_name( "" ),
                                           .field_name( "m_apb_fsc" ),
                                           .value( m_apb_resiliency_cfg.m_vif ))) begin
        `uvm_error("concerto_base_test", "FSC APB if not found")
     end
   
   <% } %>
   
    <% if(obj.DebugApbInfo.length > 0) { %>
   m_apb_debug_cfg = apb_debug_apb_agent_pkg::apb_agent_config::type_id::create("m_apb_debug_cfg");
   m_apb_debug_cfg.has_driver = 1;
   
   if (!uvm_config_db#(virtual apb_debug_apb_if)::get(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "m_apb_debug_ncore_debug_atu" ),
                                        .value( m_apb_debug_cfg.m_vif ))) begin
      `uvm_error("concerto_base_test", "NCORE DEBUG APB if not found")
   end
   <% } %>
end else begin
   <% if(obj.DebugApbInfo.length > 0) { %>
   // Creating apb_agent_config since m_apb_debug_agent (type=apb_agent) needs apb_agent_config to select active/passive mode
   m_apb_debug_cfg = apb_debug_apb_agent_pkg::apb_agent_config::type_id::create("m_apb_debug_cfg");
   m_apb_debug_cfg.has_driver = 0;
   
   if (!uvm_config_db#(virtual apb_debug_apb_if)::get(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "m_apb_debug_ncore_debug_atu" ),
                                        .value( m_apb_debug_cfg.m_vif ))) begin
      `uvm_error("concerto_base_test", "NCORE DEBUG APB if not found")
   end
   <% } %>
end

endfunction:construct_apb_config

function void concerto_env_cfg::construct_chiaiu_config();
    string msg_idx;
    string msg_idx1;
    string msg_idx2;
    string field_idx1;
    string field_idx2;
    string field_idx;
<% var chi_idx=0;
   for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
  <%  if(_child_blk[pidx].match('chiaiu')) { %>
    msg_idx     = "m_<%=_child_blkid[pidx]%>_env_cfg";
    msg_idx1    = "chi<%=pidx%>_agent_cfg";
    msg_idx2    = "smi<%=pidx%>_agent_cfg";

    m_<%=_child_blkid[pidx]%>_env_cfg = <%=_child_blkid[pidx]%>_env_pkg::chiaiu_env_config::type_id::create(msg_idx);

    m_<%=_child_blkid[pidx]%>_env_cfg.m_chi_cfg        = <%=_child_blkid[pidx]%>_chi_agent_pkg::chi_agent_cfg::type_id::create(msg_idx1);

    m_<%=_child_blkid[pidx]%>_env_cfg.m_smi_cfg        = <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_agent_config::type_id::create(msg_idx2);

    //sys_event agent config
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
    m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg = <%=_child_blkid[pidx]%>_event_agent_pkg::event_agent_config::type_id::create("m_event_agent_cfg");
    <% } %>

    field_idx   = "m_chi_if<%=chi_idx%>";

    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_chi_if)::get(uvm_root::get(), "", field_idx,m_<%=_child_blkid[pidx]%>_env_cfg.m_chi_vif)))begin
    `uvm_fatal("Missing VIF", "m_chi_if<%=chi_idx%> CHI virtual interface not found");
    end


    <% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %> 
    field_idx1  = "m_<%=_child_blkid[pidx]%>_event_if_sender_master";
    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_event_if #(.IF_MASTER(1)))::get(uvm_root::get(), "", field_idx1,m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_master)))begin
        `uvm_fatal("Missing VIF", {field_idx1, "event virtual interface not found"});
    end     
    <% } %>
    <% if (obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
    field_idx2  = "m_<%=_child_blkid[pidx]%>_event_if_receiver_slave";
    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_event_if#(.IF_MASTER(0)))::get(uvm_root::get(), "", field_idx2,m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_slave)))begin
        `uvm_fatal("Missing VIF", {field_idx2, "event virtual interface not found"});
    end 
    <% } %>

<% if(obj.testBench=="emu") { %>
    field_idx   = "m_chi_emu_if<%=chi_idx%>";
    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_chi_emu_if)::get(uvm_root::get(), "", field_idx,m_<%=_child_blkid[pidx]%>_env_cfg.m_chi_emu_vif)))begin
    `uvm_fatal("Missing VIF", "m_chi_rn_vif<%=chi_idx%> MGC CHI virtual interface not found"); 
    end <% } %>

   <% var NSMIIFTX = obj.AiuInfo[pidx].nSmiRx;
     for (var i = 0; i < NSMIIFTX; i++) { %>
    m_<%=_child_blkid[pidx]%>_env_cfg.m_smi_cfg.m_smi<%=i%>_tx_port_config        = <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_port_config::type_id::create("smi<%=i%>_tx_port_config");
    
    <% } %>
     <% var NSMIIFRX = obj.AiuInfo[pidx].nSmiTx;
     for (var i = 0; i < NSMIIFRX; i++) { %>
    m_<%=_child_blkid[pidx]%>_env_cfg.m_smi_cfg.m_smi<%=i%>_rx_port_config        = <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_port_config::type_id::create("smi<%=i%>_rx_port_config");
    <% } %>
   <% var NSMIIFTX = obj.AiuInfo[pidx].nSmiRx;
     for (var i = 0; i < NSMIIFTX; i++) { %>
    field_idx   = "m_<%=_child_blkid[pidx]%>_smi<%=i%>_tx_port_if";
    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_smi_if)::get(uvm_root::get(), "", field_idx,m_<%=_child_blkid[pidx]%>_env_cfg.m_smi_cfg.m_smi<%=i%>_tx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_<%=_child_blkid[pidx]%>_smi<%=i%>_tx_port_if virtual interface not found");
    end
`ifdef CHI_SUBSYS
    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_smi_force_if)::get(uvm_root::get(), "", field_idx,m_<%=_child_blkid[pidx]%>_env_cfg.m_smi_cfg.m_smi<%=i%>_tx_port_config.m_force_vif)))begin
    `uvm_fatal("Missing VIF", "m_<%=_child_blkid[pidx]%>_smi<%=i%>_tx_port_if virtual interface not found");
    end
 `endif

    
    <% } %>
     <% var NSMIIFRX = obj.AiuInfo[pidx].nSmiTx;
     for (var i = 0; i < NSMIIFRX; i++) { %>
    field_idx   = "m_<%=_child_blkid[pidx]%>_smi<%=i%>_rx_port_if";
    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_smi_if)::get(uvm_root::get(), "", field_idx,m_<%=_child_blkid[pidx]%>_env_cfg.m_smi_cfg.m_smi<%=i%>_rx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_<%=_child_blkid[pidx]%>_smi<%=i%>_rx_port_if Inhouse ACE virtual interface not found");
    end
`ifdef CHI_SUBSYS
 if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_smi_force_if)::get(uvm_root::get(), "", field_idx,m_<%=_child_blkid[pidx]%>_env_cfg.m_smi_cfg.m_smi<%=i%>_rx_port_config.m_force_vif)))begin
    `uvm_fatal("Missing VIF", "m_<%=_child_blkid[pidx]%>_smi<%=i%>_rx_port_if Inhouse ACE virtual interface not found");
    end
 `endif

    <% } %>
    <% chi_idx++; %>
  <% } %>
<% } %>
endfunction: construct_chiaiu_config

function void concerto_env_cfg::construct_ioaiu_config();
    string msg_idx;
    string field_idx;
    string field_idx1;
    string field_idx2;
    string field_idx3;
    string field_idx4;
    string ace_field_idx ;
    <%var qidx = 0;%>
<% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
  <%  if(_child_blk[pidx].match('ioaiu')) { %>
<%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>

    //-1- CREATE  m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>] cfgs instance
    msg_idx     = "m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>]";
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>] = <%=_child_blkid[pidx]%>_env_pkg::ioaiu_env_config::type_id::create(msg_idx);
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_axi_master_agent_cfg = <%=_child_blkid[pidx]%>_axi_agent_pkg::axi_agent_config::type_id::create("m_axi_master_agent_cfg");                                        
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.active = (has_axi_vip_snps==1)? UVM_PASSIVE :UVM_ACTIVE;
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_axi_slave_agent_cfg  = <%=_child_blkid[pidx]%>_axi_agent_pkg::axi_agent_config::type_id::create("m_axi_slave_agent_cfg");
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_smi_agent_cfg  = <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_agent_config::type_id::create("m_smi<%=pidx%>_agent_cfg");
    <% var NSMIIFTX = obj.AiuInfo[pidx].nSmiRx;
    for (var j = 0; j < NSMIIFTX; j++) { %>
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_smi_agent_cfg.m_smi<%=j%>_tx_port_config        = <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_port_config::type_id::create("smi<%=j%>_tx_port_config");
    <% } %>

    <% var NSMIIFRX = obj.AiuInfo[pidx].nSmiTx;
    for (var j = 0; j < NSMIIFRX; j++) { %>
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_smi_agent_cfg.m_smi<%=j%>_rx_port_config        = <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_port_config::type_id::create("smi<%=j%>_rx_port_config");
    <% } %>
    <% if(obj.AiuInfo[pidx].useCache) { %>
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_ccp_agent_cfg       = <%=_child_blkid[pidx]%>_ccp_agent_pkg::ccp_agent_config::type_id::create("m_ccp_agent_cfg");
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_ccp_agent_cfg.active = UVM_PASSIVE;
    <% } %>
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].hasRAL =1;
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_apb_cfg             = <%=_child_blkid[pidx]%>_apb_agent_pkg::apb_agent_config::type_id::create("m_apb_agent_cfg");
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_apb_cfg.has_driver   = 0; // use only monitor to probe the registerspb_agetn in the scb
    //sys_event agent config
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
    m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_event_agent_cfg = <%=_child_blkid[pidx]%>_event_agent_pkg::event_agent_config::type_id::create("m_event_agent_cfg");
    <% } %>

    //-2- Get VIF from tb_top  for  m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>]
    field_idx   = "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_axi_if_<%=i%>";
    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_axi_if)::get(uvm_root::get(), "", field_idx,m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.m_vif)))begin
    `uvm_fatal("Missing VIF", "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_axi_if_<%=i%> virtual interface not found");
    end

    <% if(obj.AiuInfo[pidx].useCache) { %>
    field_idx1  = "m_ioaiu<%=qidx%>_ccp_if_<%=i%>";
    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_ccp_if)::get(uvm_root::get(), "", field_idx1,m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_ccp_agent_cfg.m_vif)))begin
        `uvm_fatal("Missing VIF", "<%=_child_blkid[pidx]%>_ccp_if virtual interface not found");
    end
    <% } %>
    field_idx2  = "m_ioaiu<%=qidx%>_apb_if";
    if(!(uvm_config_db #(virtual ioaiu<%=qidx%>_apb_if)::get(uvm_root::get(), "", field_idx2,m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_apb_cfg.m_vif)))begin
        `uvm_fatal("Missing VIF", {field_idx2, "apb virtual interface not found"});
    end
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %> 
    field_idx3  = "m_ioaiu<%=qidx%>_event_if_sender_master";
    if(!(uvm_config_db #(virtual ioaiu<%=qidx%>_event_if #(.IF_MASTER(1)))::get(uvm_root::get(), "", field_idx3,m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_event_agent_cfg.m_vif_master )))begin
        `uvm_fatal("Missing VIF", {field_idx3, " event virtual interface not found"});
    end     
    <% } %>
    <% if (obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
    field_idx4  = "m_ioaiu<%=qidx%>_event_if_receiver_slave";
    if(!(uvm_config_db #(virtual ioaiu<%=qidx%>_event_if#(.IF_MASTER(0)) )::get(uvm_root::get(), "", field_idx4,m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_event_agent_cfg.m_vif_slave) ))begin
        `uvm_fatal("Missing VIF", {field_idx4, " event virtual interface not found"});
    end   
    <% } %>
    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_axi_cmdreq_id_if)::get(uvm_root::get(), "", "<%=_child_blkid[pidx]%>_axi_cmdreq_id_if_<%=i%>",m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].axi_cmdreq_id_if)))begin
        `uvm_fatal("Missing VIF", "<%=_child_blkid[pidx]%>_axi_cmdreq_id_if virtual interface not found");
    end

    <% for (var j = 0; j < NSMIIFTX; j++) { %>
    field_idx   = "m_<%=_child_blkid[pidx]%>_smi<%=j%>_tx_port_if";
    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_smi_if)::get(null, "", field_idx,m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_smi_agent_cfg.m_smi<%=j%>_tx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_<%=_child_blkid[pidx]%>_smi<%=j%>_tx_port_if virtual interface not found");
    end
    <% } %>
        <% if(obj.testBench=="emu") { %>
        <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
        if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(uvm_root::get(),"","mgc_ace_m_if_<%=_child_blkid[pidx]%>",m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].mgc_ace_vif))) begin
        `uvm_fatal("Missing VIF::", "mgc_ace_m_if_<%=_child_blkid[pidx]%> ACE EMU virtual interface not found"); end
        ace_field_idx   = "m_ace_emu_if<%=qidx%>";
        if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_ace_emu_if)::get(uvm_root::get(), "", ace_field_idx,m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_ace_vif)))begin
        `uvm_fatal("Missing VIF::", "m_ace_vif<%=qidx%> ACE EMU virtual interface not found"); 
        end
        <% } else if((obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE") || (obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" )) { %>
        if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(uvm_root::get(),"","mgc_acelite_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>",m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].mgc_ace_vif))) begin
        `uvm_fatal("Missing VIF::", "mgc_acelite_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%> ACE LITE EMU virtual interface not found"); end
        ace_field_idx   = "m_ace_emu_if<%=qidx%>";
        if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_ace_emu_if)::get(uvm_root::get(), "", ace_field_idx,m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_ace_vif)))begin
        `uvm_fatal("Missing VIF::", "m_ace_vif<%=qidx%> ACE EMU virtual interface not found"); 
        end
        <% } else if (!((obj.AiuInfo[pidx].fnNativeInterface == "ACE")||(obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE")||(obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" )||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')))  { %>
               <% if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) { %>
                   if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(uvm_root::get(),"","mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>",m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].mgc_ace_vif))) begin
                   `uvm_fatal("Missing VIF::", "mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%> AXI EMU virtual interface not found"); end
                   ace_field_idx   = "m_ace_emu_if<%=qidx%>_<%=i%>";
                   if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_ace_emu_if)::get(uvm_root::get(), "", ace_field_idx,m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_ace_vif)))begin
                   `uvm_fatal("Missing VIF::", "m_ace_emu_if<%=qidx%>_<%=i%> ACE EMU virtual interface not found");
			   <%} else {%> 
                   if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(uvm_root::get(),"","mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>",m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].mgc_ace_vif))) begin
                   `uvm_fatal("Missing VIF::", "mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%> AXI EMU virtual interface not found"); end
                   ace_field_idx   = "m_ace_emu_if<%=qidx%>";
                   if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_ace_emu_if)::get(uvm_root::get(), "", ace_field_idx,m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_ace_vif)))begin
                   `uvm_fatal("Missing VIF::", "m_ace_emu_if<%=qidx%> ACE EMU virtual interface not found");
			   <% } %>
        end
        <% } %>
		
    <% } %>

    <% for (var j = 0; j < NSMIIFRX; j++) { %>
    field_idx   = "m_<%=_child_blkid[pidx]%>_smi<%=j%>_rx_port_if";
    if(!(uvm_config_db #(virtual <%=_child_blkid[pidx]%>_smi_if)::get(null, "", field_idx,m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_smi_agent_cfg.m_smi<%=j%>_rx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_<%=_child_blkid[pidx]%>_smi<%=j%>_rx_port_if Inhouse ACE virtual interface not found");
    end
    <% } %>
<%} //foreach  InterfacePorts%>
<% qidx++; %>
<%} // if match ioaiu %> 
<%} // foreach AIUs %>

endfunction: construct_ioaiu_config

function void concerto_env_cfg::construct_dmi_config();
    string msg_idx;
    string msg_idx1;
    string msg_idx2;
    string field_idx;
    string field_idx1;
    string field_idx2;
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
<% if(obj.DmiInfo[pidx].useCmc) { %>
    msg_idx1    = "dmi<%=pidx%>_ccp_agent_config";
    msg_idx2    = "dmi<%=pidx%>_apb_agent_config";
    field_idx1  = "m_dmi<%=pidx%>_ccp_if";
    field_idx2  = "m_dmi<%=pidx%>_apb_if";
<% } %>
    msg_idx     = "dmi<%=pidx%>_env_cfg";

    m_dmi<%=pidx%>_env_cfg = dmi<%=pidx%>_env_pkg::dmi_env_config::type_id::create(msg_idx);
    m_dmi<%=pidx%>_env_cfg.m_smi_agent_cfg        = dmi<%=pidx%>_smi_agent_pkg::smi_agent_config::type_id::create("smi<%=pidx%>_agent_cfg");

    m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg = dmi<%=pidx%>_axi_agent_pkg::axi_agent_config::type_id::create("m_axi_slave_cfg");

    m_dmi<%=pidx%>_env_cfg.m_dmi_rtl_agent_cfg   = dmi<%=pidx%>_rtl_agent_pkg::dmi<%=pidx%>_rtl_agent_config::type_id::create("m_dmi<%=pidx%>_rtl_agent_cfg");

    m_dmi<%=pidx%>_env_cfg.m_dmi_tt_agent_cfg    = dmi<%=pidx%>_tt_agent_pkg::dmi<%=pidx%>_tt_agent_config::type_id::create("m_dmi<%=pidx%>_tt_agent_cfg");
    m_dmi<%=pidx%>_env_cfg.m_dmi_read_probe_agent_cfg  = dmi<%=pidx%>_read_probe_agent_pkg::dmi<%=pidx%>_read_probe_agent_config::type_id::create("m_dmi<%=pidx%>_read_probe_agent_cfg");
    m_dmi<%=pidx%>_env_cfg.m_dmi_write_probe_agent_cfg = dmi<%=pidx%>_write_probe_agent_pkg::dmi<%=pidx%>_write_probe_agent_config::type_id::create("m_dmi<%=pidx%>_write_probe_agent_cfg");

    <% var NSMIIFTX = obj.DmiInfo[pidx].nSmiRx;
     for (var i = 0; i < NSMIIFTX; i++) { %>
    m_dmi<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config        = dmi<%=pidx%>_smi_agent_pkg::smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config");
    
    <% } %>
    <% var NSMIIFRX = obj.DmiInfo[pidx].nSmiTx;
     for (var i = 0; i < NSMIIFRX; i++) { %>
    m_dmi<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config        = dmi<%=pidx%>_smi_agent_pkg::smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config");
    <% } %>

    field_idx   = "m_dmi<%=pidx%>_axi_slv_if";
    if(!(uvm_config_db #(virtual dmi<%=pidx%>_axi_if)::get(uvm_root::get(), "", field_idx,
                                                  m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.m_vif)))begin
        `uvm_fatal("Missing VIF", "m_dmi<%=pidx%>_axi_slave_if virtual interface not found");
    end

    field_idx   = "m_dmi<%=pidx%>_rtl_if";
    if(!(uvm_config_db #(virtual dmi<%=pidx%>_rtl_if)::get(uvm_root::get(), "", field_idx,
                                                  m_dmi<%=pidx%>_env_cfg.m_dmi_rtl_agent_cfg.m_vif)))begin
        `uvm_fatal("Missing VIF", "m_dmi<%=pidx%>_dmi_rtl_if virtual interface not found");
    end

    field_idx  = "m_dmi<%=pidx%>_tt_if";
    if(!(uvm_config_db #(virtual dmi<%=pidx%>_tt_if)::get(uvm_root::get(), "", field_idx,
                                                    m_dmi<%=pidx%>_env_cfg.m_dmi_tt_agent_cfg.m_vif)))begin
        `uvm_fatal("Missing VIF", "m_dmi<%=pidx%>_dmi_tt_if virtual interface not found");
    end

    field_idx  = "m_dmi<%=pidx%>_read_probe_if";
    if(!(uvm_config_db #(virtual dmi<%=pidx%>_read_probe_if)::get(uvm_root::get(), "", field_idx,
                                                    m_dmi<%=pidx%>_env_cfg.m_dmi_read_probe_agent_cfg.m_vif)))begin
        `uvm_fatal("Missing VIF", "m_dmi<%=pidx%>_dmi_read_probe_if virtual interface not found");
    end

    field_idx  = "m_dmi<%=pidx%>_write_probe_if";
    if(!(uvm_config_db #(virtual dmi<%=pidx%>_write_probe_if)::get(uvm_root::get(), "", field_idx,
                                                    m_dmi<%=pidx%>_env_cfg.m_dmi_write_probe_agent_cfg.m_vif)))begin
        `uvm_fatal("Missing VIF", "m_dmi<%=pidx%>_dmi_write_probe_if virtual interface not found");
    end

<% if(obj.DmiInfo[pidx].useCmc) { %>
    m_dmi<%=pidx%>_env_cfg.ccp_agent_cfg = dmi<%=pidx%>_ccp_agent_pkg::ccp_agent_config::type_id::create(msg_idx1);
    if(!(uvm_config_db #(virtual dmi<%=pidx%>_ccp_if)::get(uvm_root::get(), "", field_idx1,m_dmi<%=pidx%>_env_cfg.ccp_agent_cfg.m_vif)))begin
        `uvm_fatal("Missing VIF", "dmi<%=pidx%>_ccp_if virtual interface not found");
    end
    m_dmi<%=pidx%>_env_cfg.m_apb_cfg = dmi<%=pidx%>_apb_agent_pkg::apb_agent_config::type_id::create(msg_idx2);
    if(!(uvm_config_db #(virtual dmi<%=pidx%>_apb_if)::get(uvm_root::get(), "", field_idx2,m_dmi<%=pidx%>_env_cfg.m_apb_cfg.m_vif)))begin
        `uvm_fatal("Missing VIF", "dmi<%=pidx%>_apb_if virtual interface not found");
    end
<% } %>

   <% var NSMIIFTX = obj.DmiInfo[pidx].nSmiRx;
     for (var i = 0; i < NSMIIFTX; i++) { %>
    field_idx   = "m_dmi<%=pidx%>_smi<%=i%>_tx_port_if";
    if(!(uvm_config_db #(virtual dmi<%=pidx%>_smi_if)::get(uvm_root::get(), "", field_idx,m_dmi<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_dmi<%=pidx%>_smi<%=i%>_tx_port_if virtual interface not found");
    end
    
    <% } %>
     <% var NSMIIFRX = obj.DmiInfo[pidx].nSmiTx;
     for (var i = 0; i < NSMIIFRX; i++) { %>
    field_idx   = "m_dmi<%=pidx%>_smi<%=i%>_rx_port_if";
    if(!(uvm_config_db #(virtual dmi<%=pidx%>_smi_if)::get(uvm_root::get(), "", field_idx,m_dmi<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_dmi<%=pidx%>_smi<%=i%>_rx_port_if Inhouse ACE virtual interface not found");
    end
    <% } %>
<% if(obj.testBench=="emu") { %>
        //if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(uvm_root::get(),"","mgc_ace_m_if_<%=_child_blkid[pidx]%>",m_dmi<%=pidx%>_env_cfg.mgc_ace_vif))) begin
        //`uvm_fatal("Missing VIF::", "mgc_ace_m_if_<%=_child_blkid[pidx]%> ACE EMU virtual interface not found"); end
    <% } %>


<% } %>
endfunction: construct_dmi_config

function void concerto_env_cfg::construct_dii_config();
    string msg_idx;
    string msg_idx1;
    string field_idx;
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
    msg_idx     = "dii<%=pidx%>_env_cfg";

    m_dii<%=pidx%>_env_cfg = dii<%=pidx%>_env_pkg::dii_env_config::type_id::create(msg_idx);
    m_dii<%=pidx%>_env_cfg.m_smi_agent_cfg        = dii<%=pidx%>_smi_agent_pkg::smi_agent_config::type_id::create("smi<%=pidx%>_agent_cfg");
    m_dii<%=pidx%>_env_cfg.m_dii_rtl_agent_cfg    = dii<%=pidx%>_env_pkg::dii_rtl_agent_config::type_id::create("m_dii<%=pidx%>_rtl_if");
        
    m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg = dii<%=pidx%>_axi_agent_pkg::axi_agent_config::type_id::create("m_axi_slave_cfg");
   <% var NSMIIFTX = obj.DiiInfo[pidx].nSmiRx;
     for (var i = 0; i < NSMIIFTX; i++) { %>
    m_dii<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config        = dii<%=pidx%>_smi_agent_pkg::smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config");
    
    <% } %>
     <% var NSMIIFRX = obj.DiiInfo[pidx].nSmiTx;
     for (var i = 0; i < NSMIIFRX; i++) { %>
    m_dii<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config        = dii<%=pidx%>_smi_agent_pkg::smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config");
    <% } %>
    field_idx   = "m_dii<%=pidx%>_axi_slv_if";
    if(!(uvm_config_db #(virtual dii<%=pidx%>_axi_if)::get(uvm_root::get(), "", field_idx,
                                                  m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.m_vif)))begin
        `uvm_fatal("Missing VIF", "m_dii<%=pidx%>_axi_slv_if virtual interface not found");
    end
    if(!(uvm_config_db #(virtual dii<%=pidx%>_dii_rtl_if)::get(uvm_root::get(), "", "m_dii<%=pidx%>_rtl_if",
                                                  m_dii<%=pidx%>_env_cfg.m_dii_rtl_agent_cfg.m_vif)))begin
        `uvm_fatal("Missing VIF", " m_dii<%=pidx%>_rtl_if virtual interface not found");
    end
   <% var NSMIIFTX = obj.DiiInfo[pidx].nSmiRx;
     for (var i = 0; i < NSMIIFTX; i++) { %>
    field_idx   = "m_dii<%=pidx%>_smi<%=i%>_tx_port_if";
    if(!(uvm_config_db #(virtual dii<%=pidx%>_smi_if)::get(uvm_root::get(), "", field_idx,m_dii<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_dii<%=pidx%>_smi<%=i%>_tx_port_if virtual interface not found");
    end
    
    <% } %>
     <% var NSMIIFRX = obj.DiiInfo[pidx].nSmiTx;
     for (var i = 0; i < NSMIIFRX; i++) { %>
    field_idx   = "m_dii<%=pidx%>_smi<%=i%>_rx_port_if";
    if(!(uvm_config_db #(virtual dii<%=pidx%>_smi_if)::get(uvm_root::get(), "", field_idx,m_dii<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_dii<%=pidx%>_smi<%=i%>_rx_port_if Inhouse ACE virtual interface not found");
    end
    <% } %>
<% if(obj.testBench=="emu") { %>
        //if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(uvm_root::get(),"","mgc_ace_m_if_<%=_child_blkid[pidx]%>",m_dii<%=pidx%>_env_cfg.mgc_ace_vif))) begin
        //`uvm_fatal("Missing VIF::", "mgc_ace_m_if_<%=_child_blkid[pidx]%> ACE EMU virtual interface not found"); end
    <% } %>



<% } %>
endfunction: construct_dii_config

function void concerto_env_cfg::construct_dce_config();
    string msg_idx;
    string msg_idx1;
    string field_idx;
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
    msg_idx     = "dce<%=pidx%>_env_cfg";

    m_dce<%=pidx%>_env_cfg = dce<%=pidx%>_env_pkg::dce_env_config::type_id::create(msg_idx);
    m_dce<%=pidx%>_env_cfg.m_smi_agent_cfg        = dce<%=pidx%>_smi_agent_pkg::smi_agent_config::type_id::create("smi<%=pidx%>_agent_cfg");
        
    <% var NSMIIFTX = obj.DceInfo[pidx].nSmiRx;
     for (var i = 0; i < NSMIIFTX; i++) { %>
    m_dce<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config        = dce<%=pidx%>_smi_agent_pkg::smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config");
    <% } %>
    <% var NSMIIFRX = obj.DceInfo[pidx].nSmiTx;
     for (var i = 0; i < NSMIIFRX; i++) { %>
    m_dce<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config        = dce<%=pidx%>_smi_agent_pkg::smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config");
    <% } %>

    <% var NSMIIFTX = obj.DceInfo[pidx].nSmiRx;
     for (var i = 0; i < NSMIIFTX; i++) { %>
    field_idx   = "m_dce<%=pidx%>_smi<%=i%>_tx_port_if";
    if(!(uvm_config_db #(virtual dce<%=pidx%>_smi_if)::get(uvm_root::get(), "", field_idx,m_dce<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_dce<%=pidx%>_smi<%=i%>_tx_port_if virtual interface not found");
    end
    <% } %>
    <% var NSMIIFRX = obj.DceInfo[pidx].nSmiTx;
     for (var i = 0; i < NSMIIFRX; i++) { %>
    field_idx   = "m_dce<%=pidx%>_smi<%=i%>_rx_port_if";
    if(!(uvm_config_db #(virtual dce<%=pidx%>_smi_if)::get(uvm_root::get(), "", field_idx,m_dce<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_dce<%=pidx%>_smi<%=i%>_rx_port_if virtual interface not found");
    end
    <% } %>
<% } %>
endfunction: construct_dce_config

function void concerto_env_cfg::construct_dve_config();
    string msg_idx;
    string msg_idx1;
    string field_idx;
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
    msg_idx     = "dve<%=pidx%>_env_cfg";

    m_dve<%=pidx%>_env_cfg = dve<%=pidx%>_env_pkg::dve_env_config::type_id::create(msg_idx);
    m_dve<%=pidx%>_env_cfg.m_smi_agent_cfg        = dve<%=pidx%>_smi_agent_pkg::smi_agent_config::type_id::create("smi<%=pidx%>_agent_cfg");
    m_dve<%=pidx%>_env_cfg.m_apb_agent_cfg        = dve<%=pidx%>_apb_agent_pkg::apb_agent_config::type_id::create("dve<%=pidx%>_m_apb_agent_config");        

    <% var NSMIIFTX = obj.DveInfo[pidx].nSmiRx;%>
    <% for (var i = 0; i < NSMIIFTX; i++) { %>
    m_dve<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config        = dve<%=pidx%>_smi_agent_pkg::smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config");
    <% } %>
    <% var NSMIIFRX = obj.DveInfo[pidx].nSmiTx;%>
    <% for (var i = 0; i < NSMIIFRX; i++) { %>
    m_dve<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config        = dve<%=pidx%>_smi_agent_pkg::smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config");
    <% } %>

    <% var NSMIIFTX = obj.DveInfo[pidx].nSmiRx;%>
    <% for (var i = 0; i < NSMIIFTX; i++) { %>
    field_idx   = "m_dve<%=pidx%>_smi<%=i%>_tx_port_if";
    if(!(uvm_config_db #(virtual dve<%=pidx%>_smi_if)::get(uvm_root::get(), "", field_idx,m_dve<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_dve<%=pidx%>_smi<%=i%>_tx_port_if virtual interface not found");
    end
    <% } %>
    <% var NSMIIFRX = obj.DveInfo[pidx].nSmiTx;%>
    <% for (var i = 0; i < NSMIIFRX; i++) { %>
    field_idx   = "m_dve<%=pidx%>_smi<%=i%>_rx_port_if";
    if(!(uvm_config_db #(virtual dve<%=pidx%>_smi_if)::get(uvm_root::get(), "", field_idx,m_dve<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif)))begin
    `uvm_fatal("Missing VIF", "m_dve<%=pidx%>_smi<%=i%>_rx_port_if virtual interface not found");
    end
    <% } %>

    field_idx   = "dve<%=pidx%>_m_apb_if";
    if (!uvm_config_db#(virtual dve<%=pidx%>_apb_if)::get(uvm_root::get(),"", field_idx,
                                                          m_dve<%=pidx%>_env_cfg.m_apb_agent_cfg.m_vif)) begin
        `uvm_fatal("Missing VIF", "DVE<%=pidx%> m_apb_if not found")
    end
<% } %>
endfunction: construct_dve_config

function void concerto_env_cfg::construct_unit_name_array();
   funit_to_unitname_arr = '{
<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
   <%  if(_child_blk[pidx].match('chiaiu')) { %>
      <%  if(pidx == 0) { %>
      <%=obj.AiuInfo[pidx].FUnitId%> : "<%=_child_blkid[pidx]%>"
      <% } else { %>
      , <%=obj.AiuInfo[pidx].FUnitId%> : "<%=_child_blkid[pidx]%>"
      <% } // if pidx not 0%>
   <% } // if chiaui%>
   <%  if(_child_blk[pidx].match('ioaiu')) { %>
   <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
      <%  if(pidx == 0 && i == 0) { %>
      <%=obj.AiuInfo[pidx].FUnitId%> : "<%=_child_blkid[pidx]%>_core<%=i%>" 
      <% } else { %>
      , <%=obj.AiuInfo[pidx].FUnitId%> : "<%=_child_blkid[pidx]%>_core<%=i%>" 
      <% } // if pidx not 0%>
   <%}%>
   <% } // if ioaui%>
<% } // foreach aius%>
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
      , <%=obj.DceInfo[pidx].FUnitId%> : "dce<%=pidx%>"
<% } //foreach DCE %>
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
      , <%=obj.DmiInfo[pidx].FUnitId%> : "dmi<%=pidx%>"
<% } //foreach DMI %>
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
      , <%=obj.DiiInfo[pidx].FUnitId%> : "dii<%=pidx%>"
<% } //foreach DII %>
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
      , <%=obj.DveInfo[pidx].FUnitId%> : "dve<%=pidx%>"
<% } //foreach DVE %>
};
   `uvm_info("FSYS_Config", $psprintf("Array of all units in this NCORE instance: %0p", funit_to_unitname_arr), UVM_NONE)
endfunction : construct_unit_name_array
