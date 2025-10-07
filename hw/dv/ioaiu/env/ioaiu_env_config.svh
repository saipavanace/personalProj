<% // Fix MultiCSRAccess -> following code maybe moved out from here -> Consult Sai
var ioaiu_id=0;
var hit_ioaiu=0;
obj.AiuInfo.forEach(function findId(item,index){
   if((item.fnNativeInterface != "CHI-A" )&&(item.fnNativeInterface != "CHI-B" )){
      if (hit_ioaiu == 0) {
        ioaiu_id = index;
        hit_ioaiu = 1;
      }
   }
});%>
// Fix MultiCSRAccess -> following code maybe moved out from here -> Consult Sai
bit tag_secded = ("<%=obj.AiuInfo[obj.Id].ccpParams.TagErrInfo%>" == "SECDED");
bit data_secded = ("<%=obj.AiuInfo[obj.Id].ccpParams.DataErrInfo%>" == "SECDED");
bit tag_parity = ("<%=obj.AiuInfo[obj.Id].ccpParams.TagErrInfo%>" == "PARITYENTRY");
bit data_parity = ("<%=obj.AiuInfo[obj.Id].ccpParams.DataErrInfo%>" == "PARITYENTRY");
bit ott_secded = ("<%=obj.AiuInfo[obj.Id].cmpInfo.OttErrorType%>" == "SECDED");
bit ott_parity = ("<%=obj.AiuInfo[obj.Id].cmpInfo.OttErrorType%>" == "PARITY");
////////////////////////////////////////////////////////////////////////////////
//
// AIU Environment Configuration
//
////////////////////////////////////////////////////////////////////////////////
class ioaiu_env_config extends uvm_object;

  `uvm_object_param_utils(ioaiu_env_config)

  bit has_scoreboard = 1;
  bit hasRAL = 0;
  bit has_functional_coverage ;

  //Delcarations fro Software Credit Management Arrays
  typedef  int t_dceCreditDb[<%=obj.nDCEs%>];
  typedef  int t_dmiCreditDb[<%=obj.nDMIs%>];
  typedef  int t_diiCreditDb[<%=obj.nDIIs%>];

  //SCM Kavish
  t_dceCreditDb       dceCreditLimit, dceCreditLimitTemp;
  t_dmiCreditDb       dmiCreditLimit, dmiCreditLimitTemp;
  t_diiCreditDb       diiCreditLimit, diiCreditLimitTemp;


  axi_agent_config m_axi_master_agent_cfg;
  axi_agent_config m_axi_slave_agent_cfg;
  smi_agent_config m_smi_agent_cfg;
  <% if(obj.testBench=="fsys" || obj.testBench =="io_aiu" ){ %>
  <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
  //sys_event agent config
    <%=obj.BlockId%>_event_agent_pkg::event_agent_config m_event_agent_cfg;
<%}%>
<%}%>
<% if(obj.testBench=="emu") { %>
   virtual <%=obj.BlockId%>_ace_emu_if m_ace_vif ; 
   virtual mgc_axi_master_if mgc_ace_vif ; 
<% } %>




<% if(obj.INHOUSE_APB_VIP) { %>
   apb_agent_config m_apb_cfg;
<% } %>

<% if( obj.useCache) { %>                   
    ccp_agent_config  m_ccp_agent_cfg;
<%}%>
   q_chnl_agent_config  m_q_chnl_agent_cfg;

   virtual <%=obj.BlockId%>_axi_cmdreq_id_if axi_cmdreq_id_if;

   `ifndef PSEUDO_SYS_TB
<% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
`ifndef VCS
  virtual <%=obj.BlockId%>_reset_if m_reset_vif;
`else // `ifndef VCS
 // virtual <%=obj.BlockId%>_reset_if m_reset_vif;
`endif // `ifndef VCS
<% } else {%>
  virtual <%=obj.BlockId%>_reset_if m_reset_vif;
<% } %>
   `endif
  extern function new(string name = "ioaiu_env_config");

endclass : ioaiu_env_config

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function ioaiu_env_config::new(string name = "ioaiu_env_config");
  super.new(name);
 `ifdef COVER_ON
   this.has_functional_coverage =  1;
 `else
   this.has_functional_coverage =  0;
 `endif
 `ifdef FSYS_COVER_ON
   this.has_functional_coverage =  0;
 `endif
  //sys_event agent config
    <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
    m_event_agent_cfg = <%=obj.BlockId%>_event_agent_pkg::event_agent_config::type_id::create("m_event_agent_cfg");
    <% } %>

    <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %> 
    if(!(uvm_config_db #(virtual <%=obj.BlockId%>_event_if #(.IF_MASTER(1)))::get(uvm_root::get(), "", "m_<%=obj.BlockId%>_event_if_sender_master",m_event_agent_cfg.m_vif_master)))begin
        `uvm_fatal("Missing VIF", {"m_<%=obj.BlockId%>_event_if_sender_master", "event virtual interface not found"});
    end     
    <% } %>
    <% if (obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false) { %>
    if(!(uvm_config_db #(virtual <%=obj.BlockId%>_event_if#(.IF_MASTER(0)))::get(uvm_root::get(), "", "m_<%=obj.BlockId%>_event_if_receiver_slave",m_event_agent_cfg.m_vif_slave)))begin
        `uvm_fatal("Missing VIF", { "m_<%=obj.BlockId%>_event_if_receiver_slave", "event virtual interface not found"});
    end 
    <% } %>
endfunction : new

////////////////////////////////////////////////////////////////////////////////

