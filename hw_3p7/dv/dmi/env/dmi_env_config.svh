////////////////////////////////////////////////////////////////////////////////
//
// DMI Environment Configuration
//
////////////////////////////////////////////////////////////////////////////////
<%
  const getDmiIfvData = function(ifv_bundle){
    let out='';
    if(ifv_bundle.length == 0){
      out = "'{0,0}";
    }
    else{
      out = "'{";
      for(let i=0; i< ifv_bundle.length; i++){
        if(ifv_bundle[i].PrimaryBits.length > 0){ out += "1";}
        if(ifv_bundle.length == 1){ out += ",0";}
        if(i!=ifv_bundle.length-1){ out += ",";}
      }
      out += "}";
    }
    return out;
  };

  const getDmiIgsvData = function(igsv){
    let res ="";
    if(!DmiInfo[obj.Id].InterleaveInfo.dmiIGSV.length==0){
     for(let i=0; i <DmiInfo[obj.Id].InterleaveInfo.dmiIGSV.length;i++){
       if(!DmiInfo[obj.Id].InterleaveInfo.dmiIGSV[i].IGV.length==0){
       res+="'{";
       for(let j=0; j<DmiInfo[obj.Id].InterleaveInfo.dmiIGSV[i].IGV.length;j++){
         res += "'{" + DmiInfo[obj.Id].InterleaveInfo.dmiIGSV[i].IGV[j].DMIIDV;
         if(j== DmiInfo[obj.Id].InterleaveInfo.dmiIGSV[i].IGV.length-1) res+="}";
         else res+="},";
       }
       if(i== DmiInfo[obj.Id].InterleaveInfo.dmiIGSV.length-1) res+="}";
       else res+="},";
       }
     }
    }
    return res;
  }
%>

const static int dmi_igsv[$][$][$]= '{ <%=getDmiIgsvData(obj.DmiInfo[obj.Id].InterleaveInfo.dmiIGSV)%> };

const static bit intrlv_way_and_fn_en[5][2] ='{
                                                  <%=getDmiIfvData(obj.DmiInfo[obj.Id].InterleaveInfo.dmi2WIFV )%>,//2way IFV
                                                  <%=getDmiIfvData(obj.DmiInfo[obj.Id].InterleaveInfo.dmi3WIFV )%>,//3way IFV
                                                  <%=getDmiIfvData(obj.DmiInfo[obj.Id].InterleaveInfo.dmi4WIFV )%>,//4way IFV
                                                  <%=getDmiIfvData(obj.DmiInfo[obj.Id].InterleaveInfo.dmi8WIFV )%>,//8way IFV
                                                  <%=getDmiIfvData(obj.DmiInfo[obj.Id].InterleaveInfo.dmi16WIFV )%>//16way IFV
                                                }; 
class dmi_env_config extends uvm_object;

  bit has_scoreboard = 1;
  bit has_functional_coverage = 0;

  dmi_cmd_args m_args;
  resource_manager m_rsrc_mgr;
  smi_agent_config m_smi_agent_cfg;

 <%if(obj.testBench=="emu") { %>
  virtual mgc_axi_master_if mgc_ace_vif ; 
 <%}%>
  <%=obj.BlockId%>_rtl_agent_config m_dmi_rtl_agent_cfg;
  <%=obj.BlockId%>_tt_agent_config  m_dmi_tt_agent_cfg;
  <%=obj.BlockId%>_read_probe_agent_config m_dmi_read_probe_agent_cfg;
  <%=obj.BlockId%>_write_probe_agent_config m_dmi_write_probe_agent_cfg;
  axi_agent_config m_axi_slave_agent_cfg;
 <%if(obj.useCmc) { %>                   
  ccp_agent_config  ccp_agent_cfg;
 <%}%>
 <%if((obj.testBench=='dmi' || obj.useCmc) && (obj.INHOUSE_APB_VIP)) { %>
  apb_agent_config m_apb_cfg;
 <%}%>
  q_chnl_agent_config  m_q_chnl_agent_cfg;

  //Variables for randomization -- Begin
  //Control knobs --Begin
  rand int wt_merging_write_success;
  rand int randomly_streamed_exclusives, wt_randomly_streamed_exclusives;
  rand bit read_data_interleaving;
  rand bit csr_wr_data_cln_prop_en;
  //AXI Delays--Begin
  rand bit rand_OOO_axi_mode;
  rand long_delay_mode_e long_delay_mode;
  rand bit enable_axi_backpressure, enable_suspend_axi;
  //Generic backpressure on AW/W/B and AR. Check AXI response for values
  rand bit axi_rw_address_chnl_backpressure, axi_wr_data_chnl_backpressure, axi_wr_resp_chnl_backpressure;
  rand bit axi_rd_data_chnl_backpressure, axi_rd_resp_chnl_backpressure;
  //To fill RTT and WTT use BVALID and RDATA backpressure
  rand bit axi_suspend_W_resp, axi_suspend_R_resp; 
  //AXI Delays--End
  //Control knobs --End
  //Scratchpad Control-- Begin
  int amig_valid, amig_set, amif_way, amif_func;
  int k_sp_size,k_sp_ns, sp_ways_rsvd;
  bit k_sp_enabled;
  smi_addr_t sp_roof_addr;
  rand smi_addr_t sp_base_addr;
  rand bit sp_ns, sp_exists;
  rand smi_addr_t sp_base_addr_i, sp_roof_addr_i;
  //Scratchpad Control-- End
  //QoS Programming--Begin
  rand int dmi_qos_th_val[2];
  rand int wtt_qos_rsv_val[2];
  rand int rtt_qos_rsv_val[2];
  dmi_qos_seq_type_t qos_mode = QOS_NORMAL;
  //QoS Programming--End
  <% if(obj.USE_VIP_SNPS) { %>
  svt_axi_port_configuration::reordering_algorithm_enum axi_reordering_algorithm = svt_axi_port_configuration::ROUND_ROBIN ;
  <% } %>
  //Variables for randomization -- End

  //Non-random variables --Begin
  bit EN_DMI_VSEQ;

  bit disable_vseq_flw_ctrl_timeout;
  int exclusive_monitor_size =<%=obj.DmiInfo[obj.Id].nExclusiveEntries%>;
  int allowedIntfSize[<%=obj.DmiInfo[obj.Id].nAius%>];
  int allowedIntfSize_alternate[<%=obj.DmiInfo[obj.Id].nAius%>];
  int allowedIntfSizeActual[<%=obj.DmiInfo[obj.Id].nAius%>];
  int rtt_qos_rsv_max, wtt_qos_rsv_max;
  
  //Non-random variables --End
  
  `uvm_object_utils_begin(dmi_env_config)
    `uvm_field_int(wt_merging_write_success,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(randomly_streamed_exclusives,UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(wt_randomly_streamed_exclusives,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(read_data_interleaving,UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(k_sp_size,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(k_sp_ns,UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(sp_ns,UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(sp_exists,UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(sp_base_addr,UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(sp_base_addr_i,UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(sp_roof_addr,UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(sp_roof_addr_i,UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(amig_valid,UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(amig_set,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(amif_way,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(amif_func,UVM_ALL_ON | UVM_DEC)
    `uvm_field_sarray_int(dmi_qos_th_val,UVM_ALL_ON | UVM_DEC)
    `uvm_field_sarray_int(wtt_qos_rsv_val,UVM_ALL_ON | UVM_DEC)
    `uvm_field_sarray_int(rtt_qos_rsv_val,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(wtt_qos_rsv_max,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(rtt_qos_rsv_max,UVM_ALL_ON | UVM_DEC)
  `uvm_object_utils_end

  //Function Declarations -- Begin
  extern function new(string name = "dmi_env_config");
  extern function void pre_randomize();
  extern function void post_randomize();
  
  extern function void arg_overrides();
  extern function void delay_forces();
  extern function string smi_type_string(smi_type_t msg_type);

<% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
  extern function int find_legal_way(int set);
  extern function randomize_spad_intrlv(ref int set, way, func);
<%}%>
  extern function int get_rtt_qos_max();
  extern function int get_wtt_qos_max();
  extern function bit isMrd(MsgType_t msgType);
  extern function bit isRbMsg(MsgType_t msgType);
  extern function bit isAnyDtw(MsgType_t msgType);
  extern function bit isDtw(MsgType_t msgType);
  extern function bit isNcRd(MsgType_t msgType);
  extern function bit isCmdNcCacheOpsMsg(MsgType_t msgType);
  extern function bit isNcWr(MsgType_t msgType);
  extern function bit isNcCmd(MsgType_t msgType);
  extern function bit isAtomics(MsgType_t msgType);
  extern function bit isDtwMrgMrd(MsgType_t msgType);
  extern function smi_addr_t isSpAddrAfterTranslate(smi_addr_t addr);
  extern function smi_addr_t isSpAddr(smi_addr_t addr);
  extern function smi_addr_t cl_aligned(smi_addr_t addr);
  extern function smi_addr_t align(smi_addr_t addr, int size);
  extern function int get_payload_size(smi_type_t m_opcode, bit m_primary);
  //Function Declarations -- End
  //Constraints -- Begin
  constraint data_interleave_c{
    <% if(obj.DmiInfo[obj.Id].cmpInfo.useMemRspIntrlv) {%>
    read_data_interleaving dist {
      1 := 7,
      0 := 3
    };
    <%} else {%>
    read_data_interleaving == 0;
    <%}%>
  }
  constraint mw_c{
    wt_merging_write_success dist {
      0        := 1,
      [10:100] := 9
    };
  }
  constraint exclusive_c{
    if(m_args.k_pattern_type == DMI_EXCLUSIVE_p) {
      randomly_streamed_exclusives == 1;
      wt_randomly_streamed_exclusives == 100;
    }
    else {
      randomly_streamed_exclusives dist {
        1 := 3,
        0 := 7
      };
      (randomly_streamed_exclusives == 1) -> wt_randomly_streamed_exclusives inside {[1:100]};
    }
  }
  constraint scratchpad_c {
    sp_base_addr > 0; sp_base_addr < ((2 ** ADDR_WIDTH) - (k_sp_size << CCP_CL_OFFSET) - 1);
    sp_base_addr[CCP_CL_OFFSET-1:0] == 0;
    //Allow sp_ns programming override
    <%if(obj.wSysAddr>32){ %> 
    sp_base_addr[ADDR_WIDTH-CCP_CL_OFFSET-32] == 0;
    <%} else{ %> 
    sp_base_addr[ADDR_WIDTH-CCP_CL_OFFSET] == 0; <%}%>
    sp_base_addr_i == addrMgrConst::gen_spad_intrlv_rmvd_addr(sp_base_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
    sp_roof_addr_i == sp_base_addr_i + (k_sp_size << CCP_CL_OFFSET) - 1;
    <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
    ( (sp_roof_addr_i > sp_base_addr_i) && k_sp_enabled &&  (k_sp_size != 0)) -> (sp_exists == 1);
    <%} else { %> 
    sp_exists == 0;
    <%}%>
  }
  constraint axi_delays_c {
    enable_suspend_axi == 0;
    if( (m_args.k_OOO_axi_response == -1) && (m_args.k_OOO_axi_rd_response == 0) && (m_args.k_OOO_axi_wr_response == 0) ){
      rand_OOO_axi_mode dist{
        1 := 2,
        0 := 8
      };
    }
    else {
      rand_OOO_axi_mode == 0;
    }
    if(m_args.k_disable_axi_backpressure || m_args.k_axi_zero_delay) { 
      enable_axi_backpressure == 0; 
    } else { 
      enable_axi_backpressure dist { 1 :/ 10, 0 :/ 500}; 
    }

    solve enable_axi_backpressure before axi_rw_address_chnl_backpressure, axi_wr_data_chnl_backpressure;

    if(!enable_axi_backpressure){
      axi_rw_address_chnl_backpressure == 0;
      axi_wr_data_chnl_backpressure == 0;
      axi_wr_resp_chnl_backpressure == 0;
      axi_rd_data_chnl_backpressure  == 0;
      axi_rd_resp_chnl_backpressure  == 0;
    }
    if(m_args.k_axi_long_delay == 1){ //TODO randomize on default
      long_delay_mode != NO_LONG_DELAY;
    }
  }
  constraint qos_pgm_c{
   <% if(obj.DmiInfo[obj.Id].fnEnableQos) { %>
    foreach(dmi_qos_th_val[i]){
      dmi_qos_th_val[i] dist {
        1      := 1,
        [2:7 ] := 2,
        [8:14] := 2,
        15     := 1
      };
      wtt_qos_rsv_val[i] dist {
        0                                            := 1,
        [1                   : (wtt_qos_rsv_max/2)-1]:= 2,
        [(wtt_qos_rsv_max/2) : wtt_qos_rsv_max      ]:= 2
      };
      rtt_qos_rsv_val[i] dist {
        0                                            := 1,
        [1                   : (rtt_qos_rsv_max/2)-1]:= 2,
        [(rtt_qos_rsv_max/2) : rtt_qos_rsv_max      ]:= 2
      };
    }
    dmi_qos_th_val[0]  != dmi_qos_th_val[1];
    wtt_qos_rsv_val[0] != wtt_qos_rsv_val[1];
    rtt_qos_rsv_val[0] != rtt_qos_rsv_val[1];
   <%}else{%>
    foreach(dmi_qos_th_val[i]){
     dmi_qos_th_val[i]  == 0;
     rtt_qos_rsv_val[i] == 0;
     wtt_qos_rsv_val[i] == 0;
    }
   <%}%>
  }
  //Constraints -- End
endclass : dmi_env_config
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dmi_env_config::new(string name = "dmi_env_config");
  super.new(name);
<% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
  randomize_spad_intrlv(amig_set,amif_way,amif_func);
<%}%>
<% if(obj.testBench == 'dmi') { %>
  addrMgrConst::set_dmi_spad_intrlv_info(amig_set,amif_way,amif_func,<%=obj.DmiInfo[obj.Id].nUnitId%>);
<% } %>
  m_args = dmi_cmd_args::type_id::create("m_args");
  if($test$plusargs("EN_DMI_VSEQ")) begin
    EN_DMI_VSEQ = 1;
    m_rsrc_mgr  = resource_manager::type_id::create("m_rsrc_mgr");
    m_rsrc_mgr.get_args(m_args);
  end
 <% let j = Math.floor(Math.random() *3) + 0;
  let k = j+1; if(k>2) { k=0;}
  for( let i=0;i<obj.DmiInfo[obj.Id].nAius;i++){%>
  allowedIntfSize[<%=i%>] = <%=j%>;
  allowedIntfSize_alternate[<%=i%>] = <%=k%>;
  allowedIntfSizeActual[<%=i%>] = <%=Math.log2(obj.AiuInfo[i].wData/64)%>;
 <%j++; k++; if(j>2){ j=0;} if(k>2){ k=0;} } %>
  if($urandom_range(0,1)) begin //For better coverage toggle between varying Interface Size per simulation which are otherwise compile time defined
    allowedIntfSize = allowedIntfSize_alternate;
    `uvm_info(get_type_name(),$sformatf("Using allowedIntfSize_alternate instead of allowedIntfSize"),UVM_LOW)
  end
  wtt_qos_rsv_max = get_wtt_qos_max();
  rtt_qos_rsv_max = get_rtt_qos_max();
endfunction : new

function int dmi_env_config::get_wtt_qos_max();
  int m_val = 33;
  if(<%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries%> < m_val) begin
    m_val = <%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries%>;
  end
  if(<%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%> < m_val) begin
    m_val = <%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%>;
  end
  if(<%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%> < m_val) begin
    m_val = <%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%>;
  end
  return(m_val - 1);
endfunction

function int dmi_env_config::get_rtt_qos_max();
  int m_val;
  m_val = (<%=obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries%> > 33) ? 32 : (<%=obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries%> - 1);
  return(m_val);
endfunction
  
function void dmi_env_config::pre_randomize();
endfunction

function void dmi_env_config::post_randomize();
  sp_roof_addr = addrMgrConst::gen_full_cache_addr_from_spad_addr(sp_roof_addr_i,<%=obj.DmiInfo[obj.Id].nUnitId%>);
  arg_overrides();
  `uvm_info(get_type_name(),$sformatf("---------------------DMI_ENV_CONFIG RANDOMIZATION INFO--------------------"),UVM_LOW)
  print();
  `uvm_info(get_type_name(),$sformatf("--------------------------------------------------------------------------"),UVM_LOW)
  if(sp_exists && m_rsrc_mgr != null) begin
    if(m_args.k_SP_warmup) begin
      m_args.k_num_cmd        = m_args.k_num_cmd + k_sp_size;
      `uvm_info(get_type_name(),$sformatf("Overriding to overflow scratchpad k_num_cmd to k_num_cmd + SP_size :%0d",m_args.k_num_cmd),UVM_LOW)
    end
    m_rsrc_mgr.allowedIntfSize = allowedIntfSize;
    m_rsrc_mgr.allowedIntfSizeActual = allowedIntfSizeActual;
    m_rsrc_mgr.sp_exists    = sp_exists;
    m_rsrc_mgr.sp_size      = k_sp_size;
    m_rsrc_mgr.sp_ways      = sp_ways_rsvd;
    m_rsrc_mgr.sp_base_addr = sp_base_addr;
    m_rsrc_mgr.sp_roof_addr = sp_roof_addr;
    m_rsrc_mgr.sp_base_addr_i = sp_base_addr_i;
    m_rsrc_mgr.sp_roof_addr_i = sp_roof_addr_i;
  end
endfunction

function void dmi_env_config::arg_overrides();
  if(m_args.k_dmi_qos_th_val != -1) begin
    dmi_qos_th_val[0] = m_args.k_dmi_qos_th_val;
  end
  if(m_args.wt_randomly_streamed_exclusives != -1) begin
    randomly_streamed_exclusives = (m_args.wt_randomly_streamed_exclusives == 0) ? 0 : 1;
    wt_randomly_streamed_exclusives = m_args.wt_randomly_streamed_exclusives;
  end
  if(randomly_streamed_exclusives != 0) begin
    m_args.prob_ace_rd_resp_error = 0;
    m_args.prob_ace_wr_resp_error = 0;
  end
  delay_forces();
  <% if(obj.DmiInfo[obj.Id].fnEnableQos) { %>
  `uvm_info(get_type_name(),$sformatf("QoS Programmed Values:: Threshold:%0p WTTRsv:%0p RTTRsv:%0p",dmi_qos_th_val,wtt_qos_rsv_val,rtt_qos_rsv_val),UVM_LOW)
  <% } %>
  <% if(obj.USE_VIP_SNPS) { %>
  if(m_args.k_OOO_axi_response == 1 || m_args.k_OOO_axi_rd_response || m_args.k_OOO_axi_wr_response || rand_OOO_axi_mode) begin
    axi_reordering_algorithm = svt_axi_port_configuration::RANDOM;
    `uvm_info(get_type_name(),$sformatf("Turning on OOO responses for AXI VIP"),UVM_LOW)
  end
  <% } %>
endfunction
function void dmi_env_config::delay_forces();
  if (m_args.k_enable_cmdline_backpressure == 1) begin
    enable_axi_backpressure           = 1;
    axi_rw_address_chnl_backpressure  = m_args.axi_rw_address_chnl_backpressure;
    axi_wr_data_chnl_backpressure     = m_args.axi_wr_data_chnl_backpressure;
    axi_wr_resp_chnl_backpressure     = m_args.axi_wr_resp_chnl_backpressure;
    axi_rd_data_chnl_backpressure     = m_args.axi_rd_data_chnl_backpressure;
    axi_rd_resp_chnl_backpressure     = m_args.axi_rd_resp_chnl_backpressure;
  end
  else if (m_args.k_enable_suspend_axi == 1) begin
    enable_suspend_axi  = 1;
    axi_suspend_R_resp  = m_args.axi_suspend_R_resp;
    axi_suspend_W_resp  = m_args.axi_suspend_W_resp;
  end
  if(m_args.k_long_delay_mode != NO_LONG_DELAY) begin
    long_delay_mode = m_args.k_long_delay_mode;
    disable_vseq_flw_ctrl_timeout = 1;
    m_args.k_seq_timeout_max = 500000;
    m_args.k_seq_delay = 5000;
    `uvm_info(get_type_name(),$sformatf("Choosing AXI long_delay_mode:%0s",long_delay_mode.name),UVM_LOW)
  end
  if(enable_suspend_axi) begin
    `uvm_info(get_type_name(),$sformatf("::suspend_axi_knobs:: RResp:%0b WResp:%0b",axi_suspend_R_resp,axi_suspend_W_resp),UVM_LOW)
  end
  if(enable_axi_backpressure)begin
    disable_vseq_flw_ctrl_timeout = 1;
    m_args.k_seq_timeout_max = 1000000;
    m_args.k_seq_delay = 10000;
    `uvm_info(get_type_name(),$sformatf("::backpressure_axi_knobs:: RW_addr:%0b WData:%0b WResp:%0b RData:%0b RResp:%0b"
      ,axi_rw_address_chnl_backpressure,axi_wr_data_chnl_backpressure,axi_wr_resp_chnl_backpressure,axi_rd_data_chnl_backpressure,axi_rd_resp_chnl_backpressure),UVM_LOW)
  end
endfunction

function string dmi_env_config::smi_type_string(smi_type_t msg_type);
  smi_msg_type_e _type;
  string _s, _sfx;
  _type = smi_msg_type_e'(msg_type);
  _sfx  = $sformatf("%0s",_type.name);
  _s    = _sfx.substr(0,_sfx.len()-3);
  return(_s);
endfunction


//Search function conditions End   ///////////////////////////////////////////////////////////////////////////////////////////
//Resource Allocation End/////////////////////////////////////////////////////////////////////////////////////////////////////
//Common set functions Begin//////////////////////////////////////////////////////////////////////////////////////////////////

//Common set functions End////////////////////////////////////////////////////////////////////////////////////////////////////
//Whoami Types///////////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit dmi_env_config::isMrd(MsgType_t msgType);
  eMsgMRD eMsg;
  return ((msgType >= eMsg.first()) && (msgType <= eMsg.last())); 
endfunction: isMrd

function bit dmi_env_config::isRbMsg(MsgType_t msgType);
  eMsgRBReq eMsg;
  return ( (msgType >= eMsg.first()) && (msgType <= eMsg.last()) );
endfunction

function bit dmi_env_config::isAnyDtw(MsgType_t msgType);
  return(isDtw(msgType) || isDtwMrgMrd(msgType));
endfunction

function bit dmi_env_config::isDtw(MsgType_t msgType);
  eMsgDTW eMsg;
  return (msgType inside {DTW_NO_DATA,DTW_DATA_CLN,DTW_DATA_PTL,DTW_DATA_DTY}); 
endfunction: isDtw

function bit dmi_env_config::isNcRd(MsgType_t msgType);
  eMsgCMD eMsg;
  return (msgType == CMD_RD_NC); 
endfunction: isNcRd

function bit dmi_env_config::isCmdNcCacheOpsMsg(MsgType_t msgType);
  return (msgType inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF}); 
endfunction : isCmdNcCacheOpsMsg

function bit dmi_env_config::isNcWr(MsgType_t msgType);
  eMsgCMD eMsg;
  return ((msgType == CMD_WR_NC_PTL) || (msgType == CMD_WR_NC_FULL )); 
endfunction: isNcWr

function bit dmi_env_config::isNcCmd(MsgType_t msgType);
  eMsgCMD eMsg;
  return (msgType inside {CMD_WR_NC_PTL,CMD_WR_NC_FULL,CMD_RD_NC,CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF}); 
endfunction: isNcCmd

function bit dmi_env_config::isAtomics(MsgType_t msgType);
   eMsgCMD eMsg;
   return (msgType inside {CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM});
endfunction : isAtomics

function bit dmi_env_config::isDtwMrgMrd(MsgType_t msgType);
  eMsgDTWMrgMRD eMsg;
  return (msgType inside {DTW_MRG_MRD_UCLN,DTW_MRG_MRD_UDTY,DTW_MRG_MRD_INV}); 
endfunction: isDtwMrgMrd

function smi_addr_t dmi_env_config::isSpAddrAfterTranslate(smi_addr_t addr);
  if(isSpAddr(addrMgrConst::gen_spad_intrlv_rmvd_addr(addr,<%=obj.DmiInfo[obj.Id].nUnitId%>))) begin
    return 1;
  end
  else begin
    return 0;
  end
endfunction

function smi_addr_t dmi_env_config::isSpAddr(smi_addr_t addr);
  if(   (cl_aligned(addr) >= cl_aligned(sp_base_addr_i)) 
     && (cl_aligned(addr) <= cl_aligned(sp_roof_addr_i))) begin
    return 1;
  end
  else begin
    return 0;
  end
endfunction

function smi_addr_t dmi_env_config::align(smi_addr_t addr, int size);
  return((addr >> $clog2(size))<<$clog2(size));
endfunction

function smi_addr_t dmi_env_config::cl_aligned(smi_addr_t addr);
  return((addr >> $clog2(N_SYS_CACHELINE)));
endfunction // cl_aligned

function int dmi_env_config::get_payload_size(smi_type_t m_opcode, bit m_primary);
  int num_payload_bytes, allowed_payload_bytes[$];
  //Pick legal payload size as defined by SPEC.
  <%switch(true) {
  case((obj.DmiInfo[0].wData/8) == 32): %>
    allowed_payload_bytes = {64};
    num_payload_bytes = allowed_payload_bytes[0];
  <%   break;
  case((obj.DmiInfo[0].wData/8) == 16): %>
    allowed_payload_bytes = {32,64};
    num_payload_bytes = allowed_payload_bytes[$urandom_range(1,0)];
  <%   break;
  case((obj.DmiInfo[0].wData/8) == 8): %>
    allowed_payload_bytes = {16,32,64};
    num_payload_bytes = allowed_payload_bytes[$urandom_range(2,0)];
  <%   break; } %>
  if(m_opcode inside {DTW_DATA_CLN,DTW_DATA_DTY,CMD_WR_NC_FULL}) begin
    num_payload_bytes = 64;   
  end
  if(isMrd(m_opcode))begin
    allowed_payload_bytes = {1,2,4,8,16,32,64};
    num_payload_bytes = allowed_payload_bytes[$urandom_range(6,0)];
  end

  if(m_opcode inside {MRD_PREF,CMD_PREF})begin
    num_payload_bytes = 64;
  end
  else if(isDtwMrgMrd(m_opcode) && m_primary)begin
    allowed_payload_bytes = {1,2,4,8,16,32,64};
    num_payload_bytes = allowed_payload_bytes[$urandom_range(6,0)];
  end
  else if(isDtwMrgMrd(m_opcode) && !m_primary)begin
    num_payload_bytes = 64;
  end
  else if(m_opcode == DTW_DATA_PTL || m_opcode == CMD_WR_NC_PTL)begin
    allowed_payload_bytes = {1,2,4,8,16,32,64};
    num_payload_bytes = allowed_payload_bytes[$urandom_range(6,0)];
  end
  else if (isNcRd(m_opcode)) begin
    allowed_payload_bytes = {1,2,4,8,16,32,64};
    num_payload_bytes = allowed_payload_bytes[$urandom_range(6,0)];
  end
  else if(m_opcode inside {CMD_WR_ATM,CMD_RD_ATM,CMD_SW_ATM})begin
    allowed_payload_bytes = {1,2,4,8};
    num_payload_bytes = allowed_payload_bytes[$urandom_range(3,0)];    
  end
  else if(m_opcode == CMD_CMP_ATM)begin
    allowed_payload_bytes = {2,4,8,16,32};
    if(m_args.k_atomic_directed) begin 
      //num_payload_bytes = allowed_payload_bytes[size_counter]; FIXME-priority-5 FIXME randc 
    end
    else begin
      num_payload_bytes = allowed_payload_bytes[$urandom_range(4,0)];
    end
  end
  if(m_args.k_full_cl_only && !(m_opcode inside {CMD_WR_ATM, CMD_RD_ATM, CMD_SW_ATM, CMD_CMP_ATM}))begin
    num_payload_bytes = 64;
  end
  if(m_args.k_force_size > 0) begin
    num_payload_bytes = m_args.k_force_size;
  end
  return num_payload_bytes;
endfunction

//Scratchpad Programming//////////////////////////////////////////////////////////////////////////////////////////////////////
<% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
function int dmi_env_config::find_legal_way(int set);
  int unit_id = <%=obj.DmiInfo[obj.Id].nUnitId%>;
  foreach(dmi_igsv[set][i])begin
    foreach(dmi_igsv[set][i][j])begin
      if(dmi_igsv[set][i][j]==unit_id)begin
        return(dmi_igsv[set][i].size);
      end
    end
  end
endfunction

function dmi_env_config::randomize_spad_intrlv(ref int set, way, func);
  int idx, legal_ways[$], legal_funcs[$];
  int way_map[5] = '{2,3,4,8,16};
  int legal_set = $urandom_range(0,<%=obj.DmiInfo[obj.Id].InterleaveInfo.dmiIGSV.length%>-1);
  int legal_way = find_legal_way(legal_set);

  if(legal_way > 1) begin
    amig_valid = 1;
  end
  else begin //Randomization couldn't find a legal way. Turn off MIGR.AMIGS override and default to set 0
    amig_valid = 0;
    legal_set  = 0;
    legal_way  = find_legal_way(legal_set);
    `uvm_info("randomize_spad_intrlv",$sformatf("Resorting to using default set:%0d way:%0d.", legal_set, legal_way),UVM_LOW)
  end

  foreach(intrlv_way_and_fn_en[i]) begin
    foreach(intrlv_way_and_fn_en[i][j]) begin
      if(intrlv_way_and_fn_en[i][j]) begin
        if(way_map[i] == legal_way) begin
          legal_ways.push_back(legal_way);
          legal_funcs.push_back(j);
        end
      end
    end
  end
  if(legal_ways.size != legal_funcs.size) `uvm_error("randomize_spad_intrlv","Probable JS initialization error, check your arrays")
  if(amig_valid) begin
    idx = $urandom_range(legal_ways.size-1);
  end
  set  = legal_set;
  way  = legal_ways[idx];
  func = legal_funcs[idx];
  `uvm_info("randomize_spad_intrlv",$sformatf("Picking Set:%0d Way:%0d Function:%0d.", set, way, func),UVM_LOW)
endfunction
<%}%>
////////////////////////////////////////////////////////////////////////////////
