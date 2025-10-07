
////////////////////////////////////////////////////////////////////////////////
//
// concerto_env_inhouse 
<% if (1 == 0) { %>
// Author: Satya Prakash
<% } %>
//
////////////////////////////////////////////////////////////////////////////////


<%
//Embedded javascript code to figure number of blocks
   var _child_blkid      = [];
   var _child_blk        = [];
   var pidx              = 0;
   var ridx              = 0;
   var qidx              = 0;
   var idx               = 0;
   var j                 = 0;
   var num_chi_aiu_tx_if = 0;
   var num_io_aiu_tx_if  = 0;
   var num_dmi_tx_if     = 0;
   var num_dii_tx_if     = 0;
   var num_dce_tx_if     = 0;
   var num_dve_tx_if     = 0;
   var num_chi_aiu_rx_if = 0;
   var num_io_aiu_rx_if  = 0;
   var num_dmi_rx_if     = 0;
   var num_dii_rx_if     = 0;
   var num_dce_rx_if     = 0;
   var num_dve_rx_if     = 0;
   var initiatorAgents   = obj.AiuInfo.length ;
   var numChiAiu         = 0;
   var numIoAiu          = 0;
   var aiu_NumCores = [];

   for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
     if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
         aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
     } else {
         aiu_NumCores[pidx]    = 1;
     }
   }
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       num_chi_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_chi_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + qidx;
       _child_blk[pidx]   = 'ioaiu';
       num_io_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_io_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numIoAiu = numIoAiu + 1;
       qidx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
       num_dce_tx_if = obj.DceInfo[pidx].smiPortParams.tx.length;
       num_dce_rx_if = obj.DceInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
       num_dmi_tx_if = obj.DmiInfo[pidx].smiPortParams.tx.length;
       num_dmi_rx_if = obj.DmiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
       num_dii_tx_if = obj.DiiInfo[pidx].smiPortParams.tx.length;
       num_dii_rx_if = obj.DiiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
       num_dve_tx_if = obj.DveInfo[pidx].smiPortParams.tx.length;
       num_dve_rx_if = obj.DveInfo[pidx].smiPortParams.rx.length;
   }
%>
typedef class concerto_env;

//performance class dedicated to collect and print performance result for every core
class core_perf_metrics extends uvm_object;
  `uvm_object_param_utils(core_perf_metrics)

  //types
  typedef struct {
    int val;
    int status;
  } perf_metrics_results;
  typedef struct {
    perf_metrics_results bw_perf_metrucs_rslt;
    perf_metrics_results lat_perf_metrucs_rslt;
  } txt_perf_metrics;

  //variables
  string core_name;
  txt_perf_metrics txt_list[string];

  //builder class method
  function new(string name="core_perf_metrics");
   super.new(name);
   core_name = name;
  endfunction: new 

  //set core name
  function void set_core_name(string name);
   core_name = name;
  endfunction: set_core_name 

  //add trasaction results
  function void add_txt_results(string txt_type, string result_type, int val, int status);
   case (result_type)
     "bw"       : begin
                    txt_list[txt_type].bw_perf_metrucs_rslt.val = val;
                    txt_list[txt_type].bw_perf_metrucs_rslt.status = status;
                  end
     "latency"  : begin
                    txt_list[txt_type].lat_perf_metrucs_rslt.val = val;
                    txt_list[txt_type].lat_perf_metrucs_rslt.status = status;
                  end
      default   : begin
                    `uvm_error("concerto_env:core_perf_metrics", $sformatf("result type %s is not correct, correct values are bw or latency ",result_type))
                  end
   endcase
  endfunction: add_txt_results 
  

  function string get_perf_results(string txt_type);
    string str_results;
    if (txt_list.exists(txt_type)) begin
      str_results = $sformatf("%0d,%0d,%0d,%0d,",txt_list[txt_type].bw_perf_metrucs_rslt.val,
                                                 txt_list[txt_type].bw_perf_metrucs_rslt.status,
                                                 txt_list[txt_type].lat_perf_metrucs_rslt.val,
                                                 txt_list[txt_type].lat_perf_metrucs_rslt.status);
    end else begin
      str_results = $sformatf(",,,,");
    end
    return str_results;
  endfunction: get_perf_results

endclass



class concerto_env_inhouse extends uvm_env;

    //////////////////////////////////
    //UVM Registery
    //////////////////////////////////        
    `uvm_component_utils(concerto_env_inhouse)
  
    //////////////////////////////////
    //Concerto env config handle
    concerto_env parent;
    concerto_env_cfg m_cfg;

    //perf metrics variables
    core_perf_metrics core_perf_metrics_tab[string];

    <% var cidx=0; var qidx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(obj.AiuInfo[pidx].fnNativeInterface.match('CHI')) { %>
           chiaiu<%=cidx%>_chi_container_pkg::chi_container#(<%=obj.AiuInfo[pidx].FUnitId%>)       m_chi<%=cidx%>_container;
	   <%  cidx++;   %>
       <% } else { %>
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::ace_cache_model                   m_ace_cache_model_ioaiu<%=qidx%>[<%=aiu_NumCores[pidx]%>];
           ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer                   m_ioaiu_vseqr<%=qidx%>[<%=aiu_NumCores[pidx]%>];
      <%  qidx++; } %>
    <% } %>  
   
// START END ENV & ENV_CFG
    //Unit block env handle, Packet forwader handle to dpic
<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
<% if(_child_blkid[pidx].match('dmi') || _child_blkid[pidx].match('dii') || _child_blkid[pidx].match('chiaiu') || _child_blkid[pidx].match('dce') || _child_blkid[pidx].match('dve')) { %>
    <%=_child_blkid[pidx]%>_env_pkg::<%=_child_blk[pidx]%>_env m_<%=_child_blkid[pidx]%>_env;
<% } else { %>
    <%=_child_blkid[pidx]%>_env_pkg::<%=_child_blk[pidx]%>_multiport_env m_<%=_child_blkid[pidx]%>_env;
    <% if(obj.AiuInfo[pidx].useCache) { %>
    <%=_child_blkid[pidx]%>_ccp_env_pkg::ccp_scoreboard m_<%=_child_blkid[pidx]%>_ccp_scb[<%=obj.AiuInfo[pidx].nNativeInterfacePorts%>];
    <% } //useCache%>

<% } %>
<% } %>
// END ENV & ENV_CFG


   legato_scb m_legato_scb;
<% var idx; for (idx = 0; idx < obj.nDIIs;idx++) {
    if(obj.DiiInfo[idx].configuration) { %>
    // Monitors' handle for CSR_Network APB ports
    <%for (pidx = 0; pidx < _child_blkid.length; pidx++) { %>
    dii<%=idx%>_apb_agent_pkg::apb_monitor  m_sys_dii_<%=_child_blkid[pidx]%>_apb_mon;
    <%}%>
    dii<%=idx%>_apb_agent_pkg::apb_monitor  m_sys_dii_grb_apb_mon;
  <%} // if configuration
   } %>

    int legato_scb_dis;

<% if(obj.PmaInfo.length > 0) {
    for(i=0; i<obj.PmaInfo.length; i++) { %>
    q_chnl_agent  m_q_chnl_agent<%=i%>;
    q_chnl_seq m_q_chnl_seq<%=i%>;
    virtual concerto_q_chnl_if <%=obj.PmaInfo[i].strRtlNamePrefix%>_qc_if; 
   <% } %>
<% } %>
    int time_bw_Q_chnl_req;

// BEGIN SLAVE_SEQ
    <% var axi_slv_idx=0; %>
    <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
        dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_memory_model     m_axi_slv_memory_model_dmi<%=pidx%>;
        dmi<%=pidx%>_axi_agent_pkg::axi_agent_config  m_dmi<%=pidx%>_axi_slave_cfg;
    <% } %>
      <% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
	<% if(obj.DiiInfo[pidx].configuration == 0) { %>
        dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_memory_model     m_axi_slv_memory_model_dii<%=pidx%>;
        <% } %>
    <% } %>
  // END SLAVE_SEQ
 
 
<% if(obj.useResiliency == 1){ %>
    apb_debug_apb_agent_pkg::apb_agent          m_apb_resiliency_agent;
<% } %>
    <% if(obj.DebugApbInfo.length > 0) { %>
    apb_debug_apb_agent_pkg::apb_agent       m_apb_debug_agent;
    <% } %>

 
 //FSYS Scoreboard
    fsys_scoreboard m_fsys_scb;
    int fsys_scb_en;


    //////////////////////////////////
    extern function new(string name = "concerto_env_inhouse", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);
    
    int tolerance_pct; // use in the function below
    string str_ref_csv_file;
    extern function void check_bw();
    extern function void check_ref_csv_bw();
    extern function void compare_bw_allagents(string line);
    extern function int compare_bw_agent(string line,string agent,real current_value);
    extern function void dump_ref_csv_bw();
    extern function void dump_ref_csv_latency();
    extern function int  find_first_of(string s, string char_to_find, int start_pos);
    extern function void check_ref_csv_latency();
    extern function void compare_latency_allagents(string line);
    extern function int compare_latency_agent(string line, string agent, real current_value);
    extern function void dump_perf_final_result();



endclass:concerto_env_inhouse
////////////////////////////////////////
// Constructing the concerto_env_inhouse
///////////////////////////////////////
function concerto_env_inhouse::new(string name = "concerto_env_inhouse", uvm_component parent = null);
  int tolerance_arg;
  super.new(name,parent);
  tolerance_pct =  ($value$plusargs("check_bw_tolerance_pct=%0d",tolerance_arg))? tolerance_arg:4;
  legato_scb_dis = 0;
endfunction
// ////////////////////////////////////////////////////////////////////////////
// #     # #     # #     #         ######  #     #    #     #####  #######
// #     # #     # ##   ##         #     # #     #   # #   #     # #
// #     # #     # # # # #         #     # #     #  #   #  #       #
// #     # #     # #  #  #         ######  ####### #     #  #####  #####
// #     #  #   #  #     #         #       #     # #######       # #
// #     #   # #   #     #         #       #     # #     # #     # #
//  #####     #    #     # ####### #       #     # #     #  #####  #######
////////////////////////////////////////////////////////////////////////////
function void concerto_env_inhouse::build_phase(uvm_phase phase);
    string inst_name;
    
     parent = concerto_env'(this.get_parent()); 
    //`uvm_info("Connect", "Entered Concerto Environment build Phase", UVM_LOW);
    if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_cfg)))begin
        `uvm_fatal("Missing Config Obj", "Could not find concerto_env_inhouse_cfg object in UVM DB");
    end


   if (!m_cfg.has_chi_vip_snps) begin:_chi_inhouse
 <% var cidx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if (obj.AiuInfo[pidx].fnNativeInterface.match('CHI')) { %>
      m_chi<%=cidx%>_container = chiaiu<%=cidx%>_chi_container_pkg::chi_container#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("chi<%=cidx%>_container");
      m_chi<%=cidx%>_container.set_chi_node_type(chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_RN, <%=obj.AiuInfo[pidx].interfaces.chiInt.params.BE%>);
   <%  cidx++;   %>
   <% } %>
   <% } %>
   end:_chi_inhouse
   if (!m_cfg.has_axi_vip_snps) begin:_axi_inhouse
    <% var qidx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if (!obj.AiuInfo[pidx].fnNativeInterface.match('CHI')) { %>  
      <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
      m_ioaiu_vseqr<%=qidx%>[<%=i%>]           = ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer::type_id::create("m_ioaiu_vseqr<%=qidx%>[<%=i%>]", this);
      uvm_config_db#(ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer)::set(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=qidx%>[<%=i%>]" ),.value( m_ioaiu_vseqr<%=qidx%>[<%=i%>] ) );
      <%}%>
      <% qidx++; } %>
    <% } %>
   end:_axi_inhouse
    <% var qidx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if (!obj.AiuInfo[pidx].fnNativeInterface.match('CHI')) { %>  
      <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
      m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>] = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::ace_cache_model::type_id::create("m_ace_cache_model_ioaiu<%=qidx%>_<%=i%>");
      m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>].core_id = <%=i%>;
      <%}%>
      <% qidx++; } %>
    <% } %>

// ENV & ENV_CFG
<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
  <%  if(_child_blk[pidx].match('chiaiu')) { %>
    inst_name = "m_<%=_child_blkid[pidx]%>_env";
    uvm_config_db #(<%=_child_blkid[pidx]%>_env_pkg::chiaiu_env_config)::set(this, inst_name, "chi_aiu_env_config",
                                                       m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg);

    inst_name   = "m_<%=_child_blkid[pidx]%>_env.m_chi_agent";
    uvm_config_db #(<%=_child_blkid[pidx]%>_chi_agent_pkg::chi_agent_cfg)::set(this, inst_name, "chi_agent_config",
                                                       m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_chi_cfg);

    inst_name   = "m_<%=_child_blkid[pidx]%>_env.m_smi_agent";
    uvm_config_db #(<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_agent_config)::set(this, inst_name, "smi_agent_config",
                                                       m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_smi_cfg);
    m_<%=_child_blkid[pidx]%>_env = <%=_child_blkid[pidx]%>_env_pkg::chiaiu_env::type_id::create("m_<%=_child_blkid[pidx]%>_env", this);
    //sys_event agent
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
    inst_name   = "m_<%=_child_blkid[pidx]%>_env.m_event_agent";
    uvm_config_db #(<%=_child_blkid[pidx]%>_event_agent_pkg::event_agent_config)::set(this,"*", "event_agent_config",
                                                       m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg);    
    <% } %>
  <% } // if chiaui%>
  <%  if(_child_blk[pidx].match('ioaiu')) { %>
    m_<%=_child_blkid[pidx]%>_env = <%=_child_blkid[pidx]%>_env_pkg::ioaiu_multiport_env::type_id::create("m_<%=_child_blkid[pidx]%>_env", this);
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
    //SET DB  m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>] cfgs instance
    uvm_config_db#(<%=_child_blkid[pidx]%>_env_pkg::ioaiu_env_config)::set(this, "m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>]", "ioaiu_env_config",  m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>]);
    uvm_config_db#(<%=_child_blkid[pidx]%>_axi_agent_pkg::axi_agent_config)::set(this, "m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_master_agent", "axi_master_agent_config", m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_axi_master_agent_cfg);
    uvm_config_db#(<%=_child_blkid[pidx]%>_axi_agent_pkg::axi_agent_config)::set(this, "m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_slave_agent", "axi_slave_agent_config", m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_axi_slave_agent_cfg);
    uvm_config_db#(<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_agent_config)::set(this, "m_<%=_child_blkid[pidx]%>_env.m_smi_agent", "smi_agent_config", m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_smi_agent_cfg);
    <% if(obj.AiuInfo[pidx].useCache) { %>
   if(!$test$plusargs("FSYS_PRED_OFF")) begin
      if (m_cfg.enable_fsys_scb == 1) begin
         m_<%=_child_blkid[pidx]%>_ccp_scb[<%=i%>] = <%=_child_blkid[pidx]%>_ccp_env_pkg::ccp_scoreboard::type_id::create("m_<%=_child_blkid[pidx]%>_ccp_scb[<%=i%>]", this);
         uvm_config_db#(<%=_child_blkid[pidx]%>_ccp_env_pkg::ccp_cache_model)::set(this, "m_fsys_scb.fsys_scb_ioaiu_predictor", "m_ccp_cache_model_<%=pidx%>_<%=i%>", m_<%=_child_blkid[pidx]%>_ccp_scb[<%=i%>].m_ccpCacheModel);
      end
   end
    uvm_config_db#(<%=_child_blkid[pidx]%>_ccp_agent_pkg::ccp_agent_config)::set(this, "m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_ccp_agent", "ccp_agent_config", m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_ccp_agent_cfg);
    <% } //useCache%>
    uvm_config_db#(<%=_child_blkid[pidx]%>_apb_agent_pkg::apb_agent_config)::set(this, "m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_apb_agent", "apb_agent_config", m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_apb_cfg);
    //sys_event agent
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
    uvm_config_db#(<%=_child_blkid[pidx]%>_event_agent_pkg::event_agent_config)::set(this, "*", "event_agent_config", m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_event_agent_cfg);
    <% } %>
  <% } // froeach InterfacePorts%>

  <% } // if ioaiu%>
<% } // foreach aius%>


    //Push DMI config file to UVM DB
    //Constructing DMI's
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    inst_name   = "m_dmi<%=pidx%>_env";
    uvm_config_db #(dmi<%=pidx%>_env_pkg::dmi_env_config)::set(this, inst_name, "dmi_env_config",
                                                       m_cfg.m_dmi<%=pidx%>_env_cfg);

    inst_name   = "m_dmi<%=pidx%>_env.m_axi_slave_agent";
    uvm_config_db #(dmi<%=pidx%>_axi_agent_pkg::axi_agent_config)::set(this, inst_name, "axi_slave_agent_config",
                                                       m_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg);
    inst_name   = "m_dmi<%=pidx%>_env.m_smi_agent";
    uvm_config_db #(dmi<%=pidx%>_smi_agent_pkg::smi_agent_config)::set(this, inst_name, "smi_agent_config",
                                                       m_cfg.m_dmi<%=pidx%>_env_cfg.m_smi_agent_cfg);

<% if(obj.DmiInfo[pidx].useCmc) { %>
    inst_name   = "m_dmi<%=pidx%>_env.m_ccp_agent";
    uvm_config_db #(dmi<%=pidx%>_ccp_agent_pkg::ccp_agent_config)::set(this, inst_name, "ccp_agent_config",
                                                       m_cfg.m_dmi<%=pidx%>_env_cfg.ccp_agent_cfg);
<% } %>
    m_dmi<%=pidx%>_env = dmi<%=pidx%>_env_pkg::dmi_env::type_id::create("m_dmi<%=pidx%>_env", this);
<% } %>
    //Push DII config file to UVM DB
    //Constructing DII's
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
    inst_name   = "m_dii<%=pidx%>_env";
    uvm_config_db #(dii<%=pidx%>_env_pkg::dii_env_config)::set(this, inst_name, "dii_env_config",
                                                       m_cfg.m_dii<%=pidx%>_env_cfg);

    inst_name   = "m_dii<%=pidx%>_env.m_axi_slave_agent";
    uvm_config_db #(dii<%=pidx%>_axi_agent_pkg::axi_agent_config)::set(this, inst_name, "axi_slave_agent_config",
                                                       m_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg);
    inst_name   = "m_dii<%=pidx%>_env.m_smi_agent";
    uvm_config_db #(dii<%=pidx%>_smi_agent_pkg::smi_agent_config)::set(this, inst_name, "smi_agent_config",
                                                       m_cfg.m_dii<%=pidx%>_env_cfg.m_smi_agent_cfg);
    m_dii<%=pidx%>_env = dii<%=pidx%>_env_pkg::dii_env::type_id::create("m_dii<%=pidx%>_env", this);
<% } %>
 

    //Push DCE config file to UVM DB
    //Constructing DCE's
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
    inst_name   = "m_dce<%=pidx%>_env";
    uvm_config_db #(dce<%=pidx%>_env_pkg::dce_env_config)::set(this, inst_name, "dce_env_config",
                                                       m_cfg.m_dce<%=pidx%>_env_cfg);

    inst_name   = "m_dce<%=pidx%>_env.m_smi_agent";
    uvm_config_db #(dce<%=pidx%>_smi_agent_pkg::smi_agent_config)::set(this, inst_name, "smi_agent_config",
                                                       m_cfg.m_dce<%=pidx%>_env_cfg.m_smi_agent_cfg);
    m_dce<%=pidx%>_env = dce<%=pidx%>_env_pkg::dce_env::type_id::create("m_dce<%=pidx%>_env", this);
<% } %>

    //Push DVE config file to UVM DB
    //Constructing DVE's
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
    inst_name   = "m_dve<%=pidx%>_env";
    uvm_config_db #(dve<%=pidx%>_env_pkg::dve_env_config)::set(this, inst_name, "dve_env_config",
                                                       m_cfg.m_dve<%=pidx%>_env_cfg);

    inst_name   = "m_dve<%=pidx%>_env.m_smi_agent";
    uvm_config_db #(dve<%=pidx%>_smi_agent_pkg::smi_agent_config)::set(this, inst_name, "smi_agent_config",
                                                       m_cfg.m_dve<%=pidx%>_env_cfg.m_smi_agent_cfg);
    m_dve<%=pidx%>_env = dve<%=pidx%>_env_pkg::dve_env::type_id::create("m_dve<%=pidx%>_env", this);
<% } %>
    //`uvm_info("Build", "Exit Concerto Environment Build Phase", UVM_LOW);
<% if(obj.PmaInfo.length > 0) {
    for(var i=0; i<obj.PmaInfo.length; i++) { %>
    if (! m_cfg.m_q_chnl<%=i%>_agent_cfg) `uvm_fatal( get_name(), "m_cfg.m_q_chnl<%=i%>_agent_cfg not found" )
    uvm_config_db#(q_chnl_agent_config )::set(.cntxt( this ),
        .inst_name( "m_q_chnl_agent<%=i%>" ),
        .field_name( "q_chnl_agent_config" ),
        .value( m_cfg.m_q_chnl<%=i%>_agent_cfg ));

    m_cfg.m_q_chnl<%=i%>_agent_cfg.time_bw_Q_chnl_req = time_bw_Q_chnl_req;
    m_q_chnl_agent<%=i%> = q_chnl_agent::type_id::create("m_q_chnl_agent<%=i%>", this);
    <% } %>
<% } %>

<% var idx; for (idx = 0; idx < obj.nDIIs;idx++) {
    if(obj.DiiInfo[idx].configuration) { %>
    // Create Monitors for CSR_Network APB ports
    <%for (pidx = 0; pidx < _child_blkid.length; pidx++) { %>
      m_sys_dii_<%=_child_blkid[pidx]%>_apb_mon = dii<%=idx%>_apb_agent_pkg::apb_monitor::type_id::create("m_sys_dii_<%=_child_blkid[pidx]%>_apb_mon",this);
    <%}%>
      m_sys_dii_grb_apb_mon = dii<%=idx%>_apb_agent_pkg::apb_monitor::type_id::create("m_sys_dii_grb_apb_mon",this);
 <% } // if configuration
   } %>

// END ENV & ENV_CFG
    //DVE
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
     <% var NSMIIFRX = obj.DveInfo[pidx].nSmiTx; %>
         <% for (var i = 0; i < NSMIIFRX; i++) { %>
    m_cfg.m_dve<%=pidx%>_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.delay_export  = 1;
    <% }
} %>

// BEGIN SLAVE   
  if (m_cfg.has_axi_slv_vip_snps) begin:_build_axi_slv_vip
  end:_build_axi_slv_vip else begin:_build_axi_slv_inhouse
  <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
    m_axi_slv_memory_model_dmi<%=pidx%> = dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_memory_model::type_id::create("m_axi_slv_memory_model");
    m_dmi<%=pidx%>_axi_slave_cfg      = dmi<%=pidx%>_axi_agent_pkg::axi_agent_config::type_id::create("m_dmi<%=pidx%>_axi_slave_cfg",  this);
    m_dmi<%=pidx%>_axi_slave_cfg.active = UVM_ACTIVE;
    m_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.active = UVM_ACTIVE;
<% } %>
 
<% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
    <% if(obj.DiiInfo[pidx].configuration == 0) { %>
    m_axi_slv_memory_model_dii<%=pidx%> = dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_memory_model::type_id::create("m_axi_slv_memory_model");
    m_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.active = UVM_ACTIVE;
<% } %>
<% } %> 
  end:_build_axi_slv_inhouse
//END SLAVE

<% if(obj.PmaInfo.length > 0) {
// QCHANNEL
   for(var i=0; i<obj.PmaInfo.length; i++) { %>
    uvm_config_db#(virtual concerto_q_chnl_if )::get(.cntxt(null),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if_<%=obj.PmaInfo[i].strRtlNamePrefix%>" ),
                                        .value(<%=obj.PmaInfo[i].strRtlNamePrefix%>_qc_if));

    m_q_chnl_seq<%=i%> = q_chnl_seq::type_id::create("m_q_chnl_seq<%=i%>");

    if (!uvm_config_db#(virtual concerto_q_chnl_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if_<%=obj.PmaInfo[i].strRtlNamePrefix%>" ),
                                        .value(m_cfg.m_q_chnl<%=i%>_agent_cfg.m_vif ))) begin
        `uvm_error("BASE_TEST", "m_q_chnl_if_<%=obj.PmaInfo[i].strRtlNamePrefix%> not found")
    end
    <% } %>
//END QCHANNEL
<% } %>

   if ($value$plusargs("legato_scb_dis=%d", legato_scb_dis));

    if(legato_scb_dis == 0) begin
        m_legato_scb  = legato_scb::type_id::create("m_legato_scb",this);
    end

   
    $value$plusargs("EN_FSYS_SCB=%0d", fsys_scb_en);
    if (fsys_scb_en == 0) begin
      m_cfg.enable_fsys_scb = 0;
    end
    if (m_cfg.enable_fsys_scb == 1) begin
      m_fsys_scb = fsys_scoreboard::type_id::create("m_fsys_scb", this);
      `uvm_info(get_full_name(), "Creating instance of fsys_scoreboard", UVM_NONE)
    end

 <% if(obj.useResiliency == 1){ %>
    m_apb_resiliency_agent = apb_debug_apb_agent_pkg::apb_agent::type_id::create("m_apb_resiliency_agent", this);
     uvm_config_db#(apb_debug_apb_agent_pkg::apb_agent_config )::set(.cntxt( this ),
                                           .inst_name( "m_apb_resiliency_agent" ),
                                           .field_name( "apb_agent_config" ),
                                           .value( m_cfg.m_apb_resiliency_cfg ));
    
<% } %>
    <% if(obj.DebugApbInfo.length > 0) { %>
    m_apb_debug_agent = apb_debug_apb_agent_pkg::apb_agent::type_id::create("m_apb_debug_agent", this);
    uvm_config_db#(apb_debug_apb_agent_pkg::apb_agent_config )::set(.cntxt( this ),
                                           .inst_name( "m_apb_debug_agent" ),
                                           .field_name( "apb_agent_config" ),
                                           .value( m_cfg.m_apb_debug_cfg ));

    <% } %>

   <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
    <%  if(_child_blk[pidx].match('ioaiu')) { %>
         <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
              m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_regs = parent.m_regs;
        <% } // froeach InterfacePorts%>
    <% } // if ioaiu %>
    <% } // foreach aius%>

endfunction: build_phase

function void concerto_env_inhouse::connect_phase(uvm_phase phase);
    //`uvm_info("Connect", "Entered Concerto Environment Connect Phase", UVM_LOW);
      super.connect_phase(phase);
 //`uvm_info("Connect", "Entered Concerto Environment Connect Phase", UVM_LOW);
      super.connect_phase(phase);
      <% var tmptx = 0;%>
      <% var tmprx = 0;%>

<% var qidx = 0; %>
<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
  <%  if(_child_blk[pidx].match('ioaiu')) { %>
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
    if(m_cfg.m_ioaiu<%=qidx%>_env_cfg[<%=i%>].has_scoreboard)
        m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_scb.m_regs = parent.m_regs;
    //m_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[<%=i%>].m_axi_slave_agent_cfg.active = UVM_PASSIVE;
      <% if(obj.AiuInfo[pidx].useCache) { %>
   if(!$test$plusargs("FSYS_PRED_OFF")) begin
      if (m_cfg.enable_fsys_scb == 1) begin
         m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_ccp_agent.ctrlwr_ap.connect(m_<%=_child_blkid[pidx]%>_ccp_scb[<%=i%>].ccp_wr_data_port);
         m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_ccp_agent.ctrlstatus_ap.connect(m_<%=_child_blkid[pidx]%>_ccp_scb[<%=i%>].ccp_ctrl_port);
         m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_ccp_agent.cachefillctrl_ap.connect(m_<%=_child_blkid[pidx]%>_ccp_scb[<%=i%>].ccp_fill_ctrl_port);
         m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_ccp_agent.cachefilldata_ap.connect(m_<%=_child_blkid[pidx]%>_ccp_scb[<%=i%>].ccp_fill_data_port);
         m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_ccp_agent.cacherdrsp_ap.connect(m_<%=_child_blkid[pidx]%>_ccp_scb[<%=i%>].ccp_rd_rsp_port);
         m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_ccp_agent.cacheevict_ap.connect(m_<%=_child_blkid[pidx]%>_ccp_scb[<%=i%>].ccp_evict_port);
      end
   end
      <% } //useCache%>
  <% } // froeach InterfacePorts%>
  <% qidx++; %>
  <% } // if ioaiu%>
<% } // foreach aius%>

<% if(obj.PmaInfo.length > 0) {
   var pidx = 0;
   var chi_idx = 0;
   var io_idx = 0;
   var i;
		
   for(pidx=0; pidx<obj.nAIUs; pidx++) {
      if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
         for(i=0; i<obj.PmaInfo.length; i++) {
            if(obj.PmaInfo[i].unitClk[0] == obj.AiuInfo[pidx].nativeClk) { %>
         if(m_cfg.m_chiaiu<%=chi_idx%>_env_cfg.has_scoreboard==1) begin
            m_q_chnl_agent<%=i%>.q_chnl_ap.connect(m_chiaiu<%=chi_idx%>_env.m_scb.q_chnl_port);
         end
            <% }
         } 
         chi_idx++;
      }
      else {
         for(i=0; i<obj.PmaInfo.length; i++) {
            if(obj.PmaInfo[i].unitClk[0] == obj.AiuInfo[pidx].nativeClk) { %>
            <%for(var n = 0; n < obj.AiuInfo[pidx].nNativeInterfacePorts; n++){%>
         if(m_cfg.m_ioaiu<%=io_idx%>_env_cfg[<%=n%>].has_scoreboard==1) begin
            m_q_chnl_agent<%=i%>.q_chnl_ap.connect(m_ioaiu<%=io_idx%>_env.m_env[<%=n%>].m_scb.analysis_q_chnl_port);
         end
         <% } %>
            <% } 
         }
         io_idx++; 
      }
   } %>

   <% for(pidx=0; pidx<obj.nDMIs; pidx++) {
         for(i=0; i<obj.PmaInfo.length; i++) {
            if(obj.PmaInfo[i].unitClk[0] == obj.DmiInfo[pidx].unitClk[0]) { %>
         if(m_cfg.m_dmi<%=pidx%>_env_cfg.has_scoreboard==1) begin
            m_q_chnl_agent<%=i%>.q_chnl_ap.connect(m_dmi<%=pidx%>_env.m_sb.analysis_q_chnl_port);
         end
            <% } 
         }
   } %>

   <% for(pidx=0; pidx<obj.nDIIs; pidx++) {
         if(obj.DiiInfo[pidx].configuration == 0) {
         for(i=0; i<obj.PmaInfo.length; i++) {
            if(obj.PmaInfo[i].unitClk[0] == obj.DiiInfo[pidx].unitClk[0]) { %>
         if(m_cfg.m_dii<%=pidx%>_env_cfg.has_scoreboard==1) begin
            m_q_chnl_agent<%=i%>.q_chnl_ap.connect(m_dii<%=pidx%>_env.m_scb.analysis_q_chnl_port);
         end
            <% } 
         } }
   } %>

   <% for(pidx=0; pidx<obj.nDCEs; pidx++) {
         for(i=0; i<obj.PmaInfo.length; i++) {
            if(obj.PmaInfo[i].unitClk[0] == obj.DceInfo[pidx].unitClk[0]) { %>
         if(m_cfg.m_dce<%=pidx%>_env_cfg.has_scoreboard==1) begin
            m_q_chnl_agent<%=i%>.q_chnl_ap.connect(m_dce<%=pidx%>_env.m_dce_scb.analysis_q_chnl_port);
         end
            <% } 
         }
   } %>

   <% for(pidx=0; pidx<obj.nDVEs; pidx++) {
         for(i=0; i<obj.PmaInfo.length; i++) {
            if(obj.PmaInfo[i].unitClk[0] == obj.DveInfo[pidx].unitClk[0]) { %>
         if(m_cfg.m_dve<%=pidx%>_env_cfg.has_sb==1) begin
            m_q_chnl_agent<%=i%>.q_chnl_ap.connect(m_dve<%=pidx%>_env.m_dve_sb.q_chnl_port);
         end
             <% } 
         }
   } %>

 <% } %>

      if(legato_scb_dis == 0) begin
      <% for (pidx = 0; pidx < _child_blkid.length; pidx++) { %>
          <% if (_child_blkid[pidx].match('chiaiu')) { %>
              <% for (var i = 0; i < num_chi_aiu_tx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_legato_scb.m_tx_<%=tmptx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmptx++; %>
              <% } %>
              <% for (var i = 0; i < num_chi_aiu_rx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_legato_scb.m_rx_<%=tmprx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmprx++; %>
              <% } %>
          <% } %>
          <% if (_child_blkid[pidx].match('ioaiu')) { %>
              <% for (var i = 0; i < num_io_aiu_tx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_legato_scb.m_tx_<%=tmptx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmptx++; %>
              <% } %>
              <% for (var i = 0; i < num_io_aiu_rx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_legato_scb.m_rx_<%=tmprx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmprx++; %>
              <% } %>
          <% } %>
          <% if (_child_blkid[pidx].match('dce')) { %>
              <% for (var i = 0; i < num_dce_tx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_legato_scb.m_tx_<%=tmptx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmptx++; %>
              <% } %>
              <% for (var i = 0; i < num_dce_rx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_legato_scb.m_rx_<%=tmprx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmprx++; %>
              <% } %>
          <% } %>
          <% if (_child_blkid[pidx].match('dmi')) { %>
              <% for (var i = 0; i < num_dmi_tx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_legato_scb.m_tx_<%=tmptx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmptx++; %>
              <% } %>
              <% for (var i = 0; i < num_dmi_rx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_legato_scb.m_rx_<%=tmprx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmprx++; %>
              <% } %>
          <% } %>
          <% if (_child_blkid[pidx].match('dii')) { %>
              <% for (var i = 0; i < num_dii_tx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_legato_scb.m_tx_<%=tmptx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmptx++; %>
              <% } %>
              <% for (var i = 0; i < num_dii_rx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_legato_scb.m_rx_<%=tmprx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmprx++; %>
              <% } %>
          <% } %>
          <% if (_child_blkid[pidx].match('dve')) { %>
              <% for (var i = 0; i < num_dve_rx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_legato_scb.m_tx_<%=tmptx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmptx++; %>
              <% } %>
              <% for (var i = 0; i < num_dve_tx_if; i++) { %>
                  m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_legato_scb.m_rx_<%=tmprx%>_<%=_child_blkid[pidx]%>_port);
                  <% tmprx++; %>
              <% } %>
          <% } %>
      <% } %>
        end

      <% var idx; for (idx = 0; idx < obj.nDIIs;idx++) {
             if(obj.DiiInfo[idx].configuration) {%>
      //Get apb virtual interface and connect the apb monitor to SYS_SII scoreboard
          <% for (pidx = 0; pidx < _child_blkid.length; pidx++) { %>
      if(!(uvm_config_db #(virtual dii<%=idx%>_apb_if)::get(uvm_root::get(), "", "m_sys_dii_<%=_child_blkid[pidx]%>_apb_if",m_sys_dii_<%=_child_blkid[pidx]%>_apb_mon.m_vif)))begin
          `uvm_fatal("Missing VIF", "m_sys_dii_<%=_child_blkid[pidx]%>_apb_if virtual interface not found");
      end
      <% if(obj.testBench!="emu") { %>
      if(m_dii<%=idx%>_env.m_scb != null) // If dii_scb_en=1
        m_sys_dii_<%=_child_blkid[pidx]%>_apb_mon.apb_req_ap.connect(m_dii<%=idx%>_env.m_scb.analysis_apb_port);
      <% } %>
          <% } %>
      if(!(uvm_config_db #(virtual dii<%=idx%>_apb_if)::get(uvm_root::get(), "", "m_sys_dii_grb_apb_if",m_sys_dii_grb_apb_mon.m_vif)))begin
          `uvm_fatal("Missing VIF", "m_sys_dii_grb_apb_mon virtual interface not found");
      end
      <% if(obj.testBench!="emu") { %>
      if(m_dii<%=idx%>_env.m_scb != null)  // If dii_scb_en=1
        m_sys_dii_grb_apb_mon.apb_req_ap.connect(m_dii<%=idx%>_env.m_scb.analysis_apb_port);
      <% } %>
      <%     } // if configuration
         } %>

  if (m_cfg.enable_fsys_scb == 1) begin
   // FSYS SCOREBOARD analysis ports connections
   // AIU port connetions
   <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
     <%  if(_child_blk[pidx].match('chiaiu')) { %>
      m_<%=_child_blkid[pidx]%>_env.m_chi_agent.chi_txreq_pkt_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_req_port);
      m_<%=_child_blkid[pidx]%>_env.m_chi_agent.chi_txrsp_pkt_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_srsp_port);
      m_<%=_child_blkid[pidx]%>_env.m_chi_agent.chi_txdat_pkt_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_wdata_port);
      m_<%=_child_blkid[pidx]%>_env.m_chi_agent.chi_rxrsp_pkt_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_crsp_port);
      m_<%=_child_blkid[pidx]%>_env.m_chi_agent.chi_rxdat_pkt_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_rdata_port);
      m_<%=_child_blkid[pidx]%>_env.m_chi_agent.chi_rxsnp_pkt_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_snpaddr_port);
      <% for (var i = 0; i < obj.AiuInfo[pidx].smiPortParams.rx.length; i++) { %>
      m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_smi_port);
      <%}%>
      <% for (var i = 0; i < obj.AiuInfo[pidx].smiPortParams.tx.length; i++) { %>
      m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_smi_port);
      <%}%>
   <% } // if chiaui%>
   <%  if(_child_blk[pidx].match('ioaiu')) { %>
      <% for (var i = 0; i < obj.AiuInfo[pidx].smiPortParams.rx.length; i++) { %>
      m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_tx_port_ap.connect( m_fsys_scb.<%=_child_blkid[pidx]%>_smi_port) ;
      <%}%>
      <% for (var i = 0; i < obj.AiuInfo[pidx].smiPortParams.tx.length; i++) { %>
      m_<%=_child_blkid[pidx]%>_env.m_smi_agent.m_smi<%=i%>_rx_port_ap.connect( m_fsys_scb.<%=_child_blkid[pidx]%>_smi_port) ;
      <%}%>
     <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
      m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_master_agent.read_addr_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_core<%=i%>_read_addr_port) ;
      m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_master_agent.write_addr_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_core<%=i%>_write_addr_port) ;
      m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_master_agent.read_data_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_core<%=i%>_read_data_port) ;
      m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_master_agent.read_data_advance_copy_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_core<%=i%>_read_data_advance_copy_port) ;
      m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_master_agent.write_data_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_core<%=i%>_write_data_port) ;
      m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_master_agent.write_resp_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_port) ;
      m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_master_agent.write_resp_advance_copy_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_advance_copy_port) ;
      <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" || obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE"){ %>
      m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_master_agent.snoop_addr_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_core<%=i%>_snoop_addr_port) ;
      m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_master_agent.snoop_resp_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_core<%=i%>_snoop_resp_port) ;
      m_<%=_child_blkid[pidx]%>_env.m_env[<%=i%>].m_axi_master_agent.snoop_data_ap.connect(m_fsys_scb.<%=_child_blkid[pidx]%>_core<%=i%>_snoop_data_port) ;
       <%}%>
       <% } // foreach InterfacePorts%>
     <% } // if ioaiu%>
   <% } // foreach aius%>
      <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
      // DMI port connetions
      m_dmi<%=pidx%>_env.m_axi_slave_agent.read_addr_ap.connect(m_fsys_scb.dmi<%=pidx%>_read_addr_port);
      m_dmi<%=pidx%>_env.m_axi_slave_agent.read_data_ap.connect(m_fsys_scb.dmi<%=pidx%>_read_data_port);
      m_dmi<%=pidx%>_env.m_axi_slave_agent.write_addr_ap.connect(m_fsys_scb.dmi<%=pidx%>_write_addr_port);
      m_dmi<%=pidx%>_env.m_axi_slave_agent.write_data_ap.connect(m_fsys_scb.dmi<%=pidx%>_write_data_port);
      m_dmi<%=pidx%>_env.m_axi_slave_agent.write_resp_ap.connect(m_fsys_scb.dmi<%=pidx%>_write_resp_port);
      <% for (var i = 0; i < obj.DmiInfo[pidx].smiPortParams.tx.length; i++) { %>
      m_dmi<%=pidx%>_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_fsys_scb.dmi<%=pidx%>_smi);
      <%}%>
      <% for (var i = 0; i < obj.DmiInfo[pidx].smiPortParams.rx.length; i++) { %>
      m_dmi<%=pidx%>_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_fsys_scb.dmi<%=pidx%>_smi);
      <%}%>
      <% } //foreach DMI %>
      <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
      // DII port connetions
      m_dii<%=pidx%>_env.m_axi_slave_agent.read_addr_ap.connect(m_fsys_scb.dii<%=pidx%>_read_addr_port);
      m_dii<%=pidx%>_env.m_axi_slave_agent.read_data_ap.connect(m_fsys_scb.dii<%=pidx%>_read_data_port);
      m_dii<%=pidx%>_env.m_axi_slave_agent.write_addr_ap.connect(m_fsys_scb.dii<%=pidx%>_write_addr_port);
      m_dii<%=pidx%>_env.m_axi_slave_agent.write_data_ap.connect(m_fsys_scb.dii<%=pidx%>_write_data_port);
      m_dii<%=pidx%>_env.m_axi_slave_agent.write_resp_ap.connect(m_fsys_scb.dii<%=pidx%>_write_resp_port);
      <% for (var i = 0; i < obj.DiiInfo[pidx].smiPortParams.tx.length; i++) { %>
      m_dii<%=pidx%>_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_fsys_scb.dii<%=pidx%>_smi);
      <%}%>
      <% for (var i = 0; i < obj.DiiInfo[pidx].smiPortParams.rx.length; i++) { %>
      m_dii<%=pidx%>_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_fsys_scb.dii<%=pidx%>_smi);
      <%}%>
      <% } //foreach DII %>
      <% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
      // DCE port connetions
      <% for (var i = 0; i < obj.DceInfo[pidx].smiPortParams.tx.length; i++) { %>
      m_dce<%=pidx%>_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_fsys_scb.dce<%=pidx%>_smi);
      <%}%>
      <% for (var i = 0; i < obj.DceInfo[pidx].smiPortParams.rx.length; i++) { %>
      m_dce<%=pidx%>_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_fsys_scb.dce<%=pidx%>_smi);
      <%}%>
      <% } //foreach DCE %>
      <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
       // DVE port connetions
      <% for (var i = 0; i < obj.DveInfo[pidx].smiPortParams.tx.length; i++) { %>
      m_dve<%=pidx%>_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_fsys_scb.dve<%=pidx%>_smi);
      <%}%>
      <% for (var i = 0; i < obj.DveInfo[pidx].smiPortParams.rx.length; i++) { %>
      m_dve<%=pidx%>_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_fsys_scb.dve<%=pidx%>_smi);
      <%}%>
      <% } //foreach DVE %>
   /////////////////////////////////////////////////////////////////
   end // if fsys_scoreboard not disabled

   if(!m_cfg.has_apb_vip_snps) begin
     <% if(obj.useResiliency == 1){ %>
         parent.resiliency_m_regs.default_map.set_sequencer(.sequencer(m_apb_resiliency_agent.m_apb_sequencer),
                                          .adapter(m_apb_resiliency_agent.m_apb_reg_adapter));
     <% } %>

    <% if(obj.DebugApbInfo.length > 0) { %>
    parent.m_regs.default_map.set_auto_predict(0);
    parent.m_regs.default_map.set_sequencer(.sequencer(m_apb_debug_agent.m_apb_sequencer),
                                     .adapter(m_apb_debug_agent.m_apb_reg_adapter));
    <% } %>
   end
endfunction: connect_phase

function void concerto_env_inhouse::report_phase(uvm_phase phase);
   super.report_phase(phase);

   if ($test$plusargs("newperf_test_scb") && $test$plusargs("check_bw")) begin:_check_bw
      check_bw(); 
   end:_check_bw
      
   if ($test$plusargs("newperf_test_scb") && $test$plusargs("dump_bw_results_csv") && !$test$plusargs("check_bw")) begin:_dump_ref_csv_bw
      dump_ref_csv_bw();
   end:_dump_ref_csv_bw

   if ($test$plusargs("newperf_test_scb") && $test$plusargs("dump_latency_results_csv") && !$test$plusargs("check_bw")) begin:_dump_ref_csv_latency
    dump_ref_csv_latency();
   end:_dump_ref_csv_latency

   if ($test$plusargs("newperf_test_scb") && $test$plusargs("check_ref_csv_bw") && !$test$plusargs("check_bw")) begin:_check_ref_csv_bw
    check_ref_csv_bw();
   end:_check_ref_csv_bw

   if ($test$plusargs("newperf_test_scb") && $test$plusargs("check_latency_ref_csv") && !$test$plusargs("check_bw")) begin:_check_latency__ref_csv
    check_ref_csv_latency();
   end:_check_latency__ref_csv

   if ($test$plusargs("newperf_test_scb") && ($test$plusargs("check_latency_ref_csv")|| $test$plusargs("check_ref_csv_bw")) && !$test$plusargs("check_bw")) begin:_dump_perf_final_result
    dump_perf_final_result();
   end:_dump_perf_final_result
 
   
endfunction: report_phase
/////////////////////////////////////
// #######    #     #####  #    #
//    #      # #   #     # #   #
//    #     #   #  #       #  #
//    #    #     #  #####  ###
//    #    #######       # #  #
//    #    #     # #     # #   #
//    #    #     #  #####  #    #
// /////////////////////////////////////
//Close perf file handle if it is open


function void concerto_env_inhouse::check_bw();
    <%
    var dmi_clk = obj.Clocks.find (item => item.name == obj.DmiInfo[0].unitClk[0]);// TODO later: to be updated in case of multiple DMI & interleave
    var dmi_clk_Ghz = dmi_clk.params.frequency / 1000000;
    %>
    real sum_bw;
    real dmi_max_bw = <%=dmi_clk_Ghz%> * <%=obj.DmiInfo[0].wData/8%>; // TODO later: to be updated in case of multiple DMI & interleave // use max_bw_aim
    real max_bw_aim_arg;
    real max_bw_aim =  ($value$plusargs("max_bw_aim=%0f",max_bw_aim_arg))? max_bw_aim_arg:0;
    real expected_bw = (max_bw_aim>0)? max_bw_aim:dmi_max_bw;
    real pct_diff;
    <% var qidx=0;var idx=0; %>
    <% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
      sum_bw = sum_bw + m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.read_bw_tools.bw_stats["steady"];
      sum_bw = sum_bw + m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.write_bw_tools.bw_stats["steady"];
    <% idx++;  %>
    <%} else { %>
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
      sum_bw = sum_bw + m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.read_bw_tools.bw_stats["steady"];
      sum_bw = sum_bw + m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.write_bw_tools.bw_stats["steady"];
    <% } %>
    <% qidx++; %>
    <% } %>
    <% } %>
    if (max_bw_aim >0) begin
      `uvm_info("concerto_env:check_bw", $sformatf("MAX BW AIM:%0.2f",max_bw_aim), UVM_NONE);
    end else begin 
       `uvm_info("concerto_env:check_bw", $sformatf("DMI MAX BW:%0.2f",dmi_max_bw), UVM_NONE);
    end
    `uvm_info("concerto_env:check_bw", $sformatf("sum of Steady BW:%0.2f",sum_bw), UVM_NONE);
    `uvm_info("concerto_env:check_bw", $sformatf("tolerance:%0d%%",tolerance_pct), UVM_NONE);
     pct_diff = 100 - (sum_bw*100/expected_bw);
    if (pct_diff>tolerance_pct || pct_diff < -tolerance_pct) begin
        `uvm_error("concerto_env:check_bw", $sformatf("Don't reach target perf: diff=%0.2f%% between Steady BW=%0.2f & Expected MAX BW =%0.2f , tolerance:%0d%% ",pct_diff,sum_bw,expected_bw,tolerance_pct));
    end else begin
        `uvm_info("concerto_env:check_bw", $sformatf("Steady BW=%0.2f & Expected MAX BW =%0.2f",sum_bw,expected_bw), UVM_NONE);
    end
endfunction: check_bw

function void concerto_env_inhouse::check_ref_csv_bw();
    // FORMAT of ref_csv file:
    // # => comment
    // line => <label>,<rd or wr>_<agent><agentidx>_qos<qos number>=<value>, <rd or wr>...    
    string bw_ref_file_path;
    string bw_ref_file_name = "bw_ref_results.csv";
    string label; // label= testcase name in plusargs  for example "+label="1chi_rd_200ns"
    
    //cehck label
    if (!$value$plusargs("label=%s", label)) begin:_no_label
        `uvm_error("concerto_env:check_ref_csv_bw","you don't setup +label with testcasename when enable +check_ref_csv_bw");
         return;
    end:_no_label
    
    //set bw file ref path and name
    if (!$value$plusargs("ref_perf_file_path=%0s", bw_ref_file_path)) begin
      `uvm_error("concerto_env:check_ref_csv_bw","you must setup bw_ref_file_path");
       return;
    end
    $value$plusargs("bw_ref_file_name=%0s", bw_ref_file_name);
    bw_ref_file_name= {bw_ref_file_path,"/",bw_ref_file_name};
    

    begin:_check_with_csv_file
       //if($value$plusargs("bw_ref_file_name=%0s", bw_ref_file_name)) begin:_read_ref
         int file;
         string regexp_testcase = uvm_glob_to_re({label,"*"});
         string regexp_comment  = uvm_glob_to_re("#*");
         string line;
         string lines[$];
         int dont_find=1;
         int result;

        // str_ref_csv_file= {"<%=process.env.WORK_TOP%>/dv/full_sys/",bw_ref_file_name};
         file = $fopen(bw_ref_file_name,"r");
         if (!file) begin:_file_error
             `uvm_error("concerto_env:check_ref_csv_bw",{"Don't find the ref file:",bw_ref_file_name,". Define bw_ref_file_name variable"});
              return;//disable check_ref_csv_bw;
         end
         while (!$feof(file)) begin: _read_file
            result= $fgets(line,file);
            lines.push_back(line);
         end: _read_file   
        
        foreach (lines[i]) begin: _scan_file
            if (!uvm_re_match(regexp_comment, lines[i])) continue; // if comment next line
            dont_find= uvm_re_match(regexp_testcase, lines[i]);
            if (!dont_find) begin: _find_label
                compare_bw_allagents(lines[i]);
                break;
            end:_find_label
        end: _scan_file

        if (dont_find) begin:_dont_find 
         `uvm_error("concerto_env:check_ref_csv_bw",{"Don't find the label:",label, " in the ref file:",bw_ref_file_name});
         return;//disable check_ref_csv_bw;
        end: _dont_find

       //end:_read_ref else  begin:_no_plusargs_ref_file
       //  `uvm_error("concerto_env:check_ref_csv_bw","please setup <+bw_ref_file_name>");
       //  return;//disable check_ref_csv_bw;
       //end:_no_plusargs_ref_file
    end:_check_with_csv_file
//endtask:check_ref_csv_bw
    endfunction:check_ref_csv_bw

function void concerto_env_inhouse::compare_bw_allagents(string line);
    // FORMAT of ref_csv file:
    // line => <label>,<rd or wr>_<agent><agentidx>_qos<qos number>=<value>, <rd or wr>...
    string str_agent;
    int i;
    int result;
    int nbr_error;
    <% var qidx=0;var idx=0; %>
    <% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       if (!core_perf_metrics_tab.exists("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>")) begin
         core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"] = new("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>");
       end
       str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
       foreach(m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.read_bw_tools.bw_stats_qos[i]) begin:_read_chi<%=idx%>
         str_agent = $sformatf("%0s%0d",str_agent,i);
         result = compare_bw_agent(line,str_agent,m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.read_bw_tools.bw_stats_qos[i]["average"]);
         core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"].add_txt_results("rd","bw",m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.read_bw_tools.bw_stats_qos[i]["average"],result);
         if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_bw",{"Don't find the value for ",str_agent});
            return;
         end else nbr_error +=result;
       end: _read_chi<%=idx%>
       str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
       foreach(m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.write_bw_tools.bw_stats_qos[i]) begin:_write_chi<%=idx%>
         str_agent = $sformatf("%0s%0d",str_agent,i);
         result = compare_bw_agent(line,str_agent,m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.write_bw_tools.bw_stats_qos[i]["average"]);
         core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"].add_txt_results("wr","bw",m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.write_bw_tools.bw_stats_qos[i]["average"],result); 
         if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_bw",{"Don't find the value for ",str_agent});
            return;
         end else nbr_error +=result;
       end: _write_chi<%=idx%>
    <% idx++;  %>
    <%} else { %>
    <% if (aiu_NumCores[pidx] == 1) { %>
       if (!core_perf_metrics_tab.exists("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>")) begin
         core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"] = new("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>");
       end
       str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
       foreach(m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.read_bw_tools.bw_stats_qos[i]) begin:_read_ioaiu<%=qidx%>
        str_agent = $sformatf("%0s%0d",str_agent,i);
        result = compare_bw_agent(line,str_agent,m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.read_bw_tools.bw_stats_qos[i]["average"]);
        core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"].add_txt_results("rd","bw",m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.read_bw_tools.bw_stats_qos[i]["average"],result);
        if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_bw",{"Don't find the value for ",str_agent});
           return;
        end else nbr_error +=result;
      end: _read_ioaiu<%=qidx%>

       str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
       foreach(m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.write_bw_tools.bw_stats_qos[i])begin:_write_ioaiu<%=qidx%>
        str_agent = $sformatf("%0s%0d",str_agent,i);
        result = compare_bw_agent(line,str_agent,m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.write_bw_tools.bw_stats_qos[i]["average"]);
        core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"].add_txt_results("wr","bw",m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.write_bw_tools.bw_stats_qos[i]["average"],result);
        if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_bw",{"Don't find the value for ",str_agent});
           return;
        end else nbr_error +=result;
       end: _write_ioaiu<%=qidx%>
     <%} else { %>  
        <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
       if (!core_perf_metrics_tab.exists("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>")) begin
         core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>"] = new("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>");
       end
       str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>_qos"; 
       foreach(m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.read_bw_tools.bw_stats_qos[i]) begin:_read_ioaiu<%=qidx%>
        str_agent = $sformatf("%0s%0d",str_agent,i);
        result = compare_bw_agent(line,str_agent,m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.read_bw_tools.bw_stats_qos[i]["average"]);
        core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>"].add_txt_results("rd","bw",m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.read_bw_tools.bw_stats_qos[i]["average"],result);
        if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_bw",{"Don't find the value for ",str_agent});
           return;
        end else nbr_error +=result;
      end: _read_ioaiu<%=qidx%>

       str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>_qos"; 
       foreach(m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.write_bw_tools.bw_stats_qos[i])begin:_write_ioaiu<%=qidx%>
        str_agent = $sformatf("%0s%0d",str_agent,i);
        result = compare_bw_agent(line,str_agent,m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.write_bw_tools.bw_stats_qos[i]["average"]);
        core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>"].add_txt_results("wr","bw",m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.write_bw_tools.bw_stats_qos[i]["average"],result);
        if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_bw",{"Don't find the value for ",str_agent});
           return;
        end else nbr_error +=result;
       end: _write_ioaiu<%=qidx%>
        
        
        <% } %> 

     <% } %>  
       <% qidx++; %>
    <% } %>
    <% } %>
    if (nbr_error) 
           `uvm_error("concerto_env:check_ref_csv_bw",$sformatf("find %0d mismatch with the ref csv BW file:%0s",nbr_error,str_ref_csv_file));
endfunction:compare_bw_allagents

function int concerto_env_inhouse::compare_bw_agent(string line,string agent,real current_value);
    // line => <label>,<rd or wr>_<agent><agentidx>_qos<qos number>=<value>, <rd or wr>...
    // return 0:success 2:dont_find agent 1: too much diff in the value
    string regexp_agent = uvm_glob_to_re({"*",agent,"=*"});
    string str_error="";
    int return_value;
    string str_extract_value;
    real extract_value;
    real diff_percentage;
    int result;
    if (!uvm_re_match(regexp_agent, line)) begin: _find_agent
        int agent_len = agent.len();
        for( int i =0; i < line.len();i++) begin:_scan_line
              if(line.substr(i,i+agent.len) == {agent,"="}) begin:_found_agent
                  for( int j=i+agent.len+1; j<i+agent.len+10;j++) begin: _extract_string_real_value
                     str_extract_value={str_extract_value,line.getc(j)};
                     if(line.getc(j+1) == ",") begin: _end_extract
                        extract_value = str_extract_value.atoreal(); 
                        break;
                     end:_end_extract
                  end:_extract_string_real_value     
                  break;
              end:_found_agent
        end:_scan_line 
       diff_percentage = 100 - (current_value*100/extract_value);//extract_value = expected value
       if (diff_percentage > tolerance_pct || diff_percentage < -tolerance_pct)  begin: _diff_error
        str_error = $sformatf("!!ERROR: > tolerance=%0d%% !!!",tolerance_pct);
        return_value=1;
       end:_diff_error 
       `uvm_info("Concerto_env:check_ref_csv_bw:compare_bw_agent", $sformatf("%20s current_value=%0.2f ref_value=%0.2f diff=%0.2f%% %0s",agent,current_value,extract_value,diff_percentage,str_error), UVM_NONE);
       return return_value;
    end:_find_agent else return 2;
endfunction:compare_bw_agent

function void concerto_env_inhouse::dump_ref_csv_bw();
    string bw_result_file_name;
    string str_result_csv_file;
    string label; // label= testcase name in plusargs  for example "+label="1chi_rd_200ns"

    if (!$value$plusargs("bw_result_file_name=%0s", bw_result_file_name)) bw_result_file_name = "bw_results.csv";
    str_result_csv_file = {"<%=process.env.WORK_TOP%>/",bw_result_file_name};


    if ($value$plusargs("label=%s", label)) begin:_label
          string str_line; // line to post in the file
          begin:_build_str_line
             int i;
             string str_agent;
             str_line = $sformatf("%0s,",label);
             str_agent = str_line;
            <% var qidx=0;var idx=0; %>
            <% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
            <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
               str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
               foreach(m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.read_bw_tools.bw_stats_qos[i])
                 str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.read_bw_tools.bw_stats_qos[i]["average"]);
               str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
               foreach(m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.write_bw_tools.bw_stats_qos[i])
                 str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.write_bw_tools.bw_stats_qos[i]["average"]);
            <% idx++;  %>
            <%} else { %>
            <% if (aiu_NumCores[pidx] == 1) { %>
               str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
               foreach(m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.read_bw_tools.bw_stats_qos[i])
                  str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.read_bw_tools.bw_stats_qos[i]["average"]);
               str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
               foreach(m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.write_bw_tools.bw_stats_qos[i])
                     str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.write_bw_tools.bw_stats_qos[i]["average"]);
               
               <%} else { %>  
                <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %> 
                str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>_qos"; 
               foreach(m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.read_bw_tools.bw_stats_qos[i])
                  str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.read_bw_tools.bw_stats_qos[i]["average"]);
               str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>_qos"; 
               foreach(m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.write_bw_tools.bw_stats_qos[i])
                     str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.write_bw_tools.bw_stats_qos[i]["average"]);


                <% } %>  
                <% } %>  

               <% qidx++; %>
            <% } %>
            <% } %>
          end:_build_str_line
          begin:_write_file
                int file;
                int try = 100000;  // try to open file but others simulations could open file therefore try until file available
                while (try) begin:_try_open_file
                    file = $fopen(str_result_csv_file,"a");
                    try--;
                    if (!file) begin:_failed_fopen
                         if (!try) begin: _end_try
                            `uvm_error("concerto_env:check_ref_csv_bw",$sformatf("Impossible to open file certainly because too much simulations open in same time the file:%0s recommand:increase the <try> number",str_result_csv_file));
                            return;
                         end: _end_try
                    end:_failed_fopen else break; // stop while loop
                end:_try_open_file
               $fdisplay(file,str_line);
               $fflush(file);
               $fclose(file);
               $display("CSV line: %0s",str_line);  // print in the log because some time 2 test benchs write in same time in the csv file.
          end:_write_file
    end:_label else begin:_no_label
        `uvm_error("concerto_env:check_ref_csv_bw","you don't setup +label with testcasename when enable +check_ref_csv_bw or +dump_bw_results_csv");
         return;
    end:_no_label
endfunction: dump_ref_csv_bw



function void concerto_env_inhouse::dump_ref_csv_latency();
    string latency_result_file_name;
    string str_result_csv_file;
    string label; // label= testcase name in plusargs  for example "+label="1chi_rd_200ns"

    if (!$value$plusargs("latency_result_file_name=%0s", latency_result_file_name)) latency_result_file_name = "latency_results.csv";
    str_result_csv_file = {"<%=process.env.WORK_TOP%>/",latency_result_file_name};


    if ($value$plusargs("label=%s", label)) begin:_label
          string temp_str_line,str_line; // line to post in the file
          begin:_build_str_line
             int i;
             string str_agent;
             str_line = $sformatf("%0s,",label);
             str_agent = str_line;
            <% var qidx=0;var idx=0; %>
            <% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
            <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
               str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos";
               foreach(m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.read_latency_tools.latency_req_qos_1stdata[i])
               str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.read_latency_tools.latency_req_qos_1stdata[i]["min"]);
               str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
               foreach(m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.write_latency_tools.latency_req_qos_1stdata[i])
               str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.write_latency_tools.latency_req_qos_1stdata[i]["min"]);

            <% idx++;  %>
            <%} else { %>
            <% if (aiu_NumCores[pidx] == 1) { %>  

               str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos";
                foreach(m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.read_latency_tools.latency_req_qos_1stdata[i])
               str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.read_latency_tools.latency_req_qos_1stdata[i]["min"]);
               str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
                foreach(m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.write_latency_tools.latency_req_qos_1stdata[i])
               str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.write_resp_latency_tools.latency_req_qos_1stdata[i]["min"]);
               
            <%} else { %>   
            <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %> 
                str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>_qos";
                foreach(m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.read_latency_tools.latency_req_qos_1stdata[i])
               str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.read_latency_tools.latency_req_qos_1stdata[i]["min"]);
               str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>_qos"; 
                foreach(m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.write_latency_tools.latency_req_qos_1stdata[i])
               str_line = $sformatf("%0s%0s%0d=%0.2f,",str_line,str_agent,i,m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.write_resp_latency_tools.latency_req_qos_1stdata[i]["min"]);

            <% } %>  
            <% } %>  
               
               
            <% qidx++; %>
            
            
            
            <% } %>
            <% } %>
          end:_build_str_line
          begin:_write_file
                int file;
                int try = 100000;  // try to open file but others simulations could open file therefore try until file available
                while (try) begin:_try_open_file
                    file = $fopen(str_result_csv_file,"a");
                    try--;
                    if (!file) begin:_failed_fopen
                         if (!try) begin: _end_try
                            `uvm_error("concerto_env:check_ref_csv_latency",$sformatf("Impossible to open file certainly because too much simulations open in same time the file:%0s recommand:increase the <try> number",str_result_csv_file));
                            return;
                         end: _end_try
                    end:_failed_fopen else break; // stop while loop
                end:_try_open_file
               $fdisplay(file,str_line);
               $fflush(file);
               $fclose(file);
               $display("CSV line: %0s",str_line);  // print in the log because some time 2 test benchs write in same time in the csv file.
          end:_write_file
    end:_label else begin:_no_label
        `uvm_error("concerto_env:check_ref_csv_latency","you don't setup +label with testcasename when enable +check_ref_latency_bw or +dump_latency_results_csv");
         return;
    end:_no_label
endfunction: dump_ref_csv_latency

function int concerto_env_inhouse::find_first_of(string s, string char_to_find, int start_pos);
    for (int i = start_pos; i < s.len(); i++) begin
        if (s.substr(i, i) == char_to_find) begin
            return i; // Retourne l'index du premier caractère trouvé
        end
    end
    return -1; // Retourne -1 si le caractère n'est pas trouvé
endfunction:find_first_of

function int concerto_env_inhouse::compare_latency_agent(string line, string agent, real current_value);
      // line => <label>,<rd or wr>_<agent><agentidx>_qos<qos number>=<value>, <rd or wr>...
    // return 0:success 2:dont_find agent 1: too much diff in the value
    string regexp_agent = uvm_glob_to_re({"*",agent,"=*"});
    string str_error="";
    int return_value;
    string str_extract_value;
    real extract_value;
    real diff_percentage;
    int result;
    if (!uvm_re_match(regexp_agent, line)) begin: _find_agent
        int agent_len = agent.len();
        for( int i =0; i < line.len();i++) begin:_scan_line
              if(line.substr(i,i+agent.len) == {agent,"="}) begin:_found_agent
                  for( int j=i+agent.len+1; j<i+agent.len+10;j++) begin: _extract_string_real_value
                     str_extract_value={str_extract_value,line.getc(j)};
                     if(line.getc(j+1) == ",") begin: _end_extract
                        extract_value = str_extract_value.atoreal(); 
                        break;
                     end:_end_extract
                  end:_extract_string_real_value     
                  break;
              end:_found_agent
        end:_scan_line 
       diff_percentage = 100 - (current_value*100/extract_value);//extract_value = expected value
       if (diff_percentage > tolerance_pct || diff_percentage < -tolerance_pct)  begin: _diff_error
        str_error = $sformatf("!!ERROR: > tolerance=%0d%% !!!",tolerance_pct);
        return_value=1;
       end:_diff_error 
       `uvm_info("Concerto_env:check_ref_csv_latency:compare_latency_agent", $sformatf("%20s current_value=%0.2f ref_value=%0.2f diff=%0.2f%% %0s",agent,current_value,extract_value,diff_percentage,str_error), UVM_NONE);
       return return_value;
    end:_find_agent else return 2;
endfunction:compare_latency_agent


function void concerto_env_inhouse::compare_latency_allagents(string line);
    // FORMAT of ref_csv file:
    // line => <label>,<rd or wr>_<agent><agentidx>_qos<qos number>=<value>, <rd or wr>...
    string str_agent;
    int i;
    int result;
    int nbr_error;
    <% var qidx=0;var idx=0; %>
    <% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       if (!core_perf_metrics_tab.exists("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>")) begin
         core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"] = new("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>");
       end      
       str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
       foreach(m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.read_latency_tools.latency_req_qos_1stdata[i]) begin:_read_chi<%=idx%>
         str_agent = $sformatf("%0s%0d",str_agent,i);
         result = compare_latency_agent(line,str_agent,m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.read_latency_tools.latency_req_qos_1stdata[i]["min"]);
         core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"].add_txt_results("rd","latency",m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.read_latency_tools.latency_req_qos_1stdata[i]["min"],result);

         if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_latency",{"Don't find the value for ",str_agent});
            return;
         end else nbr_error +=result;
       end: _read_chi<%=idx%>
       str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
       foreach(m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.write_latency_tools.latency_req_qos_1stdata[i]) begin:_write_chi<%=idx%>
         str_agent = $sformatf("%0s%0d",str_agent,i);
         result = compare_latency_agent(line,str_agent,m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.write_latency_tools.latency_req_qos_1stdata[i]["min"]);
         core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"].add_txt_results("wr","latency",m_chiaiu<%=idx%>_env.m_newperf_test_chi_scb.write_latency_tools.latency_req_qos_1stdata[i]["min"],result);
         if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_latency",{"Don't find the value for ",str_agent});
            return;
         end else nbr_error +=result;
       end: _write_chi<%=idx%>
    <% idx++;  %>
    <%} else { %>
    <% if (aiu_NumCores[pidx] == 1) { %>
       if (!core_perf_metrics_tab.exists("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>")) begin
         core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"] = new("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>");
       end      
       str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
       foreach(m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.read_latency_tools.latency_req_qos_1stdata[i]) begin:_read_ioaiu<%=qidx%>
        str_agent = $sformatf("%0s%0d",str_agent,i);
        result = compare_latency_agent(line,str_agent,m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.read_latency_tools.latency_req_qos_1stdata[i]["min"]);
        core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"].add_txt_results("rd","latency",m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.read_latency_tools.latency_req_qos_1stdata[i]["min"],result);
        if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_latency",{"Don't find the value for ",str_agent});
           return;
        end else nbr_error +=result;
      end: _read_ioaiu<%=qidx%>

       str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_qos"; 
       foreach(m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.write_latency_tools.latency_req_qos_1stdata[i])begin:_write_ioaiu<%=qidx%>
        str_agent = $sformatf("%0s%0d",str_agent,i);
        result = compare_latency_agent(line,str_agent,m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.write_resp_latency_tools.latency_req_qos_1stdata[i]["min"]);
        core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"].add_txt_results("wr","latency",m_ioaiu<%=qidx%>_env.m_env[0].m_newperf_test_ace_scb.write_resp_latency_tools.latency_req_qos_1stdata[i]["min"],result);
        if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_latency",{"Don't find the value for ",str_agent});
           return;
        end else nbr_error +=result;
       end: _write_ioaiu<%=qidx%>
       <%} else { %>  
        <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %> 
        
        if (!core_perf_metrics_tab.exists("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>")) begin
         core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>"] = new("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>");
       end      
       str_agent ="rd_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>_qos"; 
       foreach(m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.read_latency_tools.latency_req_qos_1stdata[i]) begin:_read_ioaiu<%=qidx%>
        str_agent = $sformatf("%0s%0d",str_agent,i);
        result = compare_latency_agent(line,str_agent,m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.read_latency_tools.latency_req_qos_1stdata[i]["min"]);
        core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>"].add_txt_results("rd","latency",m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.read_latency_tools.latency_req_qos_1stdata[i]["min"],result);
        if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_latency",{"Don't find the value for ",str_agent});
           return;
        end else nbr_error +=result;
      end: _read_ioaiu<%=qidx%>

       str_agent ="wr_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>_qos"; 
       foreach(m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.write_latency_tools.latency_req_qos_1stdata[i])begin:_write_ioaiu<%=qidx%>
        str_agent = $sformatf("%0s%0d",str_agent,i);
        result = compare_latency_agent(line,str_agent,m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.write_resp_latency_tools.latency_req_qos_1stdata[i]["min"]);
        core_perf_metrics_tab["<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>"].add_txt_results("wr","latency",m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_newperf_test_ace_scb.write_resp_latency_tools.latency_req_qos_1stdata[i]["min"],result);
        if (result ==2) begin
            `uvm_error("concerto_env:check_ref_csv_latency",{"Don't find the value for ",str_agent});
           return;
        end else nbr_error +=result;
       end: _write_ioaiu<%=qidx%>

        <% } %> 

        <% } %>  
       <% qidx++; %>
    <% } %>
    <% } %>
    if (nbr_error) 
           `uvm_error("concerto_env:check_ref_csv_latency",$sformatf("find %0d mismatch with the ref csv latency file:%0s",nbr_error,str_ref_csv_file));
endfunction:compare_latency_allagents




function void concerto_env_inhouse::check_ref_csv_latency();
    // FORMAT of ref_csv file:
    // # => comment
    // line => <label>,<rd or wr>_<agent><agentidx>_qos<qos number>=<value>-Min=<value>-Max=<value>, <rd or wr>...
    string latency_ref_file_path;
    string latency_ref_file_name = "latency_ref_results.csv";    
    string label; // label= testcase name in plusargs  for example "+label="1chi_rd_200ns"

    if (!$value$plusargs("label=%s", label)) begin:_no_label
        `uvm_error("concerto_env:check_ref_csv_latency","you don't setup +label with testcasename when enable +check_ref_csv_latency");
         return;
    end:_no_label

    
    //set bw file ref path and name
    if (!$value$plusargs("ref_perf_file_path=%0s", latency_ref_file_path)) begin
      `uvm_error("concerto_env:check_ref_csv_latency","you must setup latency_ref_file_path");
       return;
    end
    $value$plusargs("latency_ref_file_name=%0s", latency_ref_file_name);
    latency_ref_file_name= {latency_ref_file_path,"/",latency_ref_file_name};

    begin:_check_with_csv_file
       //if($value$plusargs("latency_ref_file_name=%0s", latency_ref_file_name)) begin:_read_ref
         int file;
         string regexp_testcase = uvm_glob_to_re({label,"*"});
         string regexp_comment  = uvm_glob_to_re("#*");
         string line;
         string lines[$];
         int dont_find=1;
         int result;

         //str_ref_csv_file= {"<%=process.env.WORK_TOP%>/dv/full_sys/",latency_ref_file_name};
         file = $fopen(latency_ref_file_name,"r");
         if (!file) begin:_file_error
             `uvm_error("concerto_env:check_ref_csv_latency",{"Don't find the ref file:",latency_ref_file_name,". Define latency_ref_file_name variable"});
              return;//disable check_ref_csv_latency;
         end
         while (!$feof(file)) begin: _read_file
            result= $fgets(line,file);
            lines.push_back(line);
         end: _read_file   
        
        foreach (lines[i]) begin: _scan_file
            if (!uvm_re_match(regexp_comment, lines[i])) continue; // if comment next line
            dont_find= uvm_re_match(regexp_testcase, lines[i]);
            if (!dont_find) begin: _find_label
                compare_latency_allagents(lines[i]);
                break;
            end:_find_label
        end: _scan_file

        if (dont_find) begin:_dont_find 
         `uvm_error("concerto_env:check_ref_csv_latency",{"Don't find the label:",label, " in the ref file:",latency_ref_file_name});
         return;//disable check_ref_csv_latency;
        end: _dont_find

      // end:_read_ref else  begin:_no_plusargs_ref_file
      //   `uvm_error("concerto_env:check_ref_csv_latency","please setup <+latency_ref_file_name>");
      //   return;//disable check_ref_csv_latency;
      // end:_no_plusargs_ref_file
    end:_check_with_csv_file
//endtask:check_ref_csv_latency
    endfunction:check_ref_csv_latency

function void concerto_env_inhouse::dump_perf_final_result();
    string str_final_result_csv_file;
    string label; // label= testcase name in plusargs  for example "+label="1chi_rd_200ns"
    string str_agent, str_line, str_head_line_1, str_head_line_2, str_line_1, str_line_2;
    int file;
    int try = 100000;  // try to open file but others simulations could open file therefore try until file available
    str_final_result_csv_file = "<%=process.env.WORK_TOP%>/perf_metrics_results.csv";


    if ($value$plusargs("label=%s", label)) begin:_label
      //open the output
      while (try) begin:_try_open_file
          file = $fopen(str_final_result_csv_file,"a+");
          try--;
          if (!file) begin:_failed_fopen
               if (!try) begin: _end_try
                  `uvm_error("concerto_env:dump_perf_final_result",$sformatf("Impossible to open file certainly because too much simulations open in same time the file:%0s recommand:increase the <try> number",str_final_result_csv_file));
                  return;
               end: _end_try
          end:_failed_fopen else begin
               $fgets(str_line,file);
               break; // stop while loop
          end
      end:_try_open_file
      if (str_line.len() == 0) begin:_head_printing
        //first line
        str_head_line_1 = "Test Name,txt type,";
        str_head_line_2 = "Test Name,txt type,";
       <% for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
        <% if ((!obj.AiuInfo[pidx].fnNativeInterface.match('CHI')) && aiu_NumCores[pidx] > 1) { %>
       str_agent ="<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>";
         <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
        str_head_line_1 = {str_head_line_1,$sformatf("%0s_<%=i%>,%0s_<%=i%>,%0s_<%=i%>,%0s_<%=i%>,",str_agent,str_agent,str_agent,str_agent)};
        str_head_line_2 = {str_head_line_2,$sformatf("BW,Status,Latency,Status,")};
         <% } %>
        <%} else { %>
        str_agent ="<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"; 
        str_head_line_1 = {str_head_line_1,$sformatf("%0s,%0s,%0s,%0s,",str_agent,str_agent,str_agent,str_agent)};
        str_head_line_2 = {str_head_line_2,$sformatf("BW,Status,Latency,Status,")};
        <% } %>
       <% } %> 
       str_line = {str_head_line_1,"\n",str_head_line_2,"\n"};
      end:_head_printing else begin
        str_line = "";
      end

      //filling with values
      str_line_1 = $sformatf("%0s,rd,",label);
      str_line_2 = $sformatf("%0s,wr,",label);
     <% for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
        str_agent ="<%=obj.AiuInfo[pidx].strRtlNamePrefix%>";
      <% if ((!obj.AiuInfo[pidx].fnNativeInterface.match('CHI')) && aiu_NumCores[pidx] > 1) { %> 
       <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
       str_agent ="<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=i%>";
       if (core_perf_metrics_tab.exists(str_agent)) begin
         str_line_1 = {str_line_1,$sformatf("%0s",core_perf_metrics_tab[str_agent].get_perf_results("rd"))};
         str_line_2 = {str_line_2,$sformatf("%0s",core_perf_metrics_tab[str_agent].get_perf_results("wr"))};
       end 
       <% } %>
      <%} else { %>
       if (core_perf_metrics_tab.exists(str_agent)) begin
         str_line_1 = {str_line_1,$sformatf("%0s",core_perf_metrics_tab[str_agent].get_perf_results("rd"))};
         str_line_2 = {str_line_2,$sformatf("%0s",core_perf_metrics_tab[str_agent].get_perf_results("wr"))};
       end
      <% } %>
     <% } %> 
       str_line = {str_line,str_line_1,"\n",str_line_2};

      begin:_write_file
           $display("perf metrics lines: %0s",str_line);  // print in the log because some time 2 test benchs write in same time in the csv file.
           $display("Abdelkader %p",core_perf_metrics_tab);
           $fdisplay(file,str_line);
           $fflush(file);
           $fclose(file);
      end:_write_file
    end:_label else begin:_no_label
        `uvm_error("concerto_env:dump_perf_final_result","you don't setup +label with testcasename when enable +check_ref_csv_bw or +dump_bw_results_csv");
         return;
    end:_no_label
endfunction: dump_perf_final_result
