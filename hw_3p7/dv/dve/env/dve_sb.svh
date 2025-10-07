<% obj.Dvm_aiuInfo = [] ;
obj.Dvm_FUnitIds = [] ;
obj.Dvm_NUnitIds = [] ;
for (i in obj.AiuInfo) {
    if(obj.AiuInfo[i].cmpInfo.nDvmSnpInFlight > 0) {
        obj.Dvm_aiuInfo.push(obj.AiuInfo[i]);
        obj.Dvm_FUnitIds.push(obj.AiuInfo[i].FUnitId);
        obj.Dvm_NUnitIds.push(obj.AiuInfo[i].nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

var SnpsEnb;
var SnpsEnb1;
var SnpsEnb2;
var SnpsEnb3;
SnpsEnb = 0;
SnpsEnb1 = 0;
SnpsEnb2 = 0;
SnpsEnb3 = 0;
for(i in obj.Dvm_NUnitIds) {
   if(obj.Dvm_NUnitIds[i] > 95) { SnpsEnb3 |= 1 << (obj.Dvm_NUnitIds[i]-96); }
   else if(obj.Dvm_NUnitIds[i] > 63) { SnpsEnb2 |= 1 << (obj.Dvm_NUnitIds[i]-64); }
   else if(obj.Dvm_NUnitIds[i] > 31) { SnpsEnb1 |= 1 << (obj.Dvm_NUnitIds[i]-32); }
   else {  SnpsEnb |= 1 << obj.Dvm_NUnitIds[i]; }
}
  
var unit_frequency;
var unit_period;
for(var clk=0; clk<obj.Clocks.length; clk++) {
   if(obj.DveInfo[obj.Id].unitClk[0] == obj.Clocks[clk].name) {
      unit_frequency = obj.Clocks[clk].params.frequency;
      unit_period = obj.Clocks[clk].params.period;
      break;
   }
}

var dvm_agent = obj.Dvm_aiuInfo.length  %>

import uvm_pkg::*;
import <%=obj.BlockId%>_concerto_register_map_pkg::*;
`include "uvm_macros.svh"

// Interfaces from TB perspective
// SMI 0 non data [request]  | TX | CMDreq
// SMI 0 non data [request]  | RX | SNPreq, STRreq
// SMI 1 non data [response] | TX | SNPrsp, STRrsp
// SMI 1 non data [response] | RX | CMDrsp, DTWrsp, CMPrsp
// SMI 2 data     [request]  | TX | DTWreq
// APB TODO

`uvm_analysis_imp_decl(_smi_port);
`uvm_analysis_imp_decl(_clock_counter_port);

//Q-channel port
`uvm_analysis_imp_decl(_q_chnl)

`uvm_analysis_imp_decl(_dve_debug_txn)

class dve_sb extends uvm_scoreboard;
  `uvm_component_utils(dve_sb)
  // perf monitor stall Interface
  virtual <%=obj.BlockId%>_stall_if sb_stall_if;
  // SMI ports
  uvm_analysis_imp_smi_port #(smi_seq_item, dve_sb) smi_port;
  uvm_analysis_imp_clock_counter_port #(<%=obj.BlockId%>_clock_counter_seq_item, dve_sb) m_clock_counter_port;

  // Q_Channele Ports
  uvm_analysis_imp_q_chnl #(q_chnl_seq_item, dve_sb) q_chnl_port;

  // Debug CSR reads port
  uvm_analysis_imp_dve_debug_txn #(dve_debug_txn, dve_sb) dbg_txn_port;

  // Queues
  dve_sb_txn m_ott_q[$];
  dve_sb_txn m_sys_q[$];
  dve_sb_txn m_sysEvent_q[$];
  smi_seq_item trace_pkt_q[$];
  bit[7:0] trace_ts_corr_q[$], trace_ts_corr_late_q[$];
  bit [127:0] previous_csr_DvmSnoopDisable;
   
  // Counts
  int cmd_objection_cnt = 0;
  int txn_id = 0;
  int sys_req_txn_id = 0;
  int snp_credit_max = <%=obj.DveInfo[0].cmpInfo.nDvmSnpCredits%>; 
  int snp_credit_cnt;
  int dtw_dbg_req_seen = 0;
  int debug_txn_seen = 0;
  int debug_txn_seen_rtl = 0;
  int nb_DtwDbgReq_packet = 0;

  int DveSnpCapAgents = <%=dvm_agent%>;//4;
  int SnoopEn_FUNIT_IDS[$] = '{<%for(var unit=0; unit<obj.Dvm_FUnitIds.length; unit++) {%><%=obj.Dvm_FUnitIds[unit]%> <%if(unit < (obj.Dvm_FUnitIds.length-1)) {%>,<%} }%>};
  int SnoopEn_NUNIT_IDS[$] = '{<%for(var unit=0; unit<obj.Dvm_NUnitIds.length; unit++) {%><%=obj.Dvm_NUnitIds[unit]%> <%if(unit < (obj.Dvm_NUnitIds.length-1)) {%>,<%} }%>};
  int numSnpsEnb = 0;
  bit save_num_SnpEn = 0;//save snoop number when a valid sysco req is received
  bit [127:0] SnoopEn = 'h0;
  bit [127:0] SysReq_Aiu = 0;
  int anticipate_drop_linear = 0;
  int overall_traces_dropped = 0;
  int overall_traces_dropped_rtl = 0;
  int prev_empty = 0; // how many previous runs have had the queue empty?

  bit circular = 1'b0; // whether DVE reports that it is running in circular mode or not

  // Events
  event e_cmd_req;
  event e_str_rsp;
  int per_aiu_snp_crd[int];

  // BEGIN PERF_MONITOR
  const int    max_stt = 3;//max stt enteries should be hardcoded to 3 CONC-8213 <%=obj.DveInfo[obj.Id].cmpInfo.nSttEntries%>;
  event evt_stt;
  int   stt_skid_size;
  int   real_stt_size;
  event evt_del_stt;

  <% if (obj.testBench == "dve") { %>
  <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore  m_regs;
  <% }  else if (obj.testBench == "fsys") { %>
  concerto_register_map_pkg::ral_sys_ncore  m_regs;
  <% } %>
  
  uvm_reg my_register; 
  uvm_reg_data_t mirrored_value;
  uvm_reg_data_t write_value = 32'hFFFF_FFFF; 
  uvm_status_e status; 
  uvm_reg_field my_field;



  // SMI error injection statistics
  int  res_smi_corr_err   = 0;
  int  num_smi_corr_err   = 0;
  int  num_smi_uncorr_err = 0;
  int  num_smi_parity_err = 0;  // also uncorrectable

  // TACC buffer error injection tracking
  int seen_single_errors = 0;
  int seen_double_errors = 0;
  int seen_addr_errors = 0;
  int injected_single_errors = 0;
  int injected_double_errors = 0;
  int injected_addr_errors = 0;

  realtime res_smi_pkt_time_old, res_smi_pkt_time_new;
  int res_mod_dp_corr_error;
  bit res_is_pre_err_pkt;

  event kill_test;

  // Global dynamic handles for SMI request/responses
  smi_seq_item m_cmd_req_pkt;
  smi_seq_item m_cmd_rsp_pkt;
  smi_seq_item m_str_req_pkt;
  smi_seq_item m_dtw_req_pkt;
  smi_seq_item m_dtw_rsp_pkt;
  smi_seq_item m_snp_req_pkt;
  smi_seq_item m_snp_rsp_pkt;
  smi_seq_item m_cmp_rsp_pkt;
  smi_seq_item m_str_rsp_pkt;
  smi_seq_item m_dtw_dbg_req_pkt;
  smi_seq_item m_dtw_dbg_rsp_pkt;
  smi_seq_item m_sys_req_pkt;
  smi_seq_item m_sys_rsp_pkt;
  //smi_msg_id_bit_t DTWreq_msg_id_random_Dbad[smi_msg_id_bit_t];
  smi_src_id_bit_t DTWreq_msg_id_random_Dbad[smi_msg_id_bit_t];

  //latency measurement
  longint latency_collection_strreq_q[$];
  longint latency_collection_snpreq_q[$];
  longint latency_collection_cmprsp_q[$];
  longint strreq_min_latency[$];
  longint strreq_max_latency[$];
  longint snpreq_min_latency[$];
  longint snpreq_max_latency[$];
  longint cmprsp_min_latency[$];
  longint cmprsp_max_latency[$];
  longint strreq_latency_sum, strreq_avg_latency;
  longint snpreq_latency_sum, snpreq_avg_latency;
  longint cmprsp_latency_sum, cmprsp_avg_latency;
  /// dve coverage//////
  `ifndef FSYS_COVER_ON
  dve_coverage cov;
  `endif
  int RBID_state;
  int strRq_gen;
  int CmdReq_type;
  int dvmRq_order;
  int dtwReq_cmstatus,snpRsp_cmstatus,cmdReq_cmstatus,cmdRsp_cmstatus,dtwRsp_cmstatus,snpReq_cmstatus,sysReq_cmstatus;
  bit dvm_sync = 0;
  bit dvm_no_sync = 0;
  bit snpreq_active ;
  bit snpreq_order  ;
  bit snpreq_order_sync_op;
  bit snpreq_1_2_same_agt;
  bit credit_alloc;
  bit credit_dealloc;
  int num_avl_credit;
  bit STTID_max_range;
  bit STTID_snp_msg_id;
  bit DVM_NonSync_bypass;
  int snpreq_msg_id_width =31;
  int cmd_credits[int];
  int drop_bad_dvm_msg;
  int drop_transport_error_dvm_msg;
  int drop_dtw_req_transport_error_dvm_msg;
  int drop_snp_rsp_transport_error_dvm_msg;
  int wrong_target_id;
  int snprsp_first_err;
  int SysReqAttach_from_attached_aiu;
  int SysReqAttach_from_detached_aiu;
  int SysReqDetach_from_attached_aiu;
  int SysReqDetach_from_detached_aiu;
  int SysReqAttach_while_active;
  int SysReqDetach_while_active;
  bit inject_cmdreq_transport_err;
  smi_msg_id_t snpreq_msg_id = 0;
  
  ///////////////////////
  // CSR interface handle
  <% if ((obj.useResiliency) && (obj.testBench != "fsys" && obj.testBench != "cust_tb")) { %>
    virtual dve_csr_probe_if u_csr_probe_vif;
  <% } %>
   
  //Constructor
  function new(string name = "dve_sb", uvm_component parent = null);
    super.new(name, parent);
    <% for(idx=0; idx<obj.nAIUs; idx++) { %>
    cmd_credits[<%=obj.AiuInfo[idx].FUnitId%>] = <%=obj.AiuInfo[idx].cmpInfo.nDvmMsgInFlight%>;
    <% } %>
  endfunction // new

  //Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    smi_port = new("smi_port", this);
    m_clock_counter_port = new("m_clock_counter_port", this);
    q_chnl_port = new("q_chnl_port",this);
    dbg_txn_port = new("dbg_txn_port", this);

    <% if(obj.testBench == "dve" || obj.testBench == "cust_tb")  { %>
        if(!uvm_config_db #(<%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore)::get(null, "", "m_regs", m_regs))
        begin
            `uvm_fatal("SB","Failed to get m_regs from config_db to sb @239");
         end
    <% } else if(obj.testBench == "fsys") { %>
    if(!(uvm_config_db #(concerto_register_map_pkg::ral_sys_ncore)::get(null, "","m_regs",m_regs)))  `uvm_fatal("Missing in DB::", "RAL m_regs not found");
    //m_regs = concerto_register_map_pkg::ral_sys_ncore::type_id::create("m_regs", this);
    <% } %>


    snp_credit_cnt = snp_credit_max;
    <% for (var i = 0; i < obj.Dvm_aiuInfo.length; i++) { %>
    per_aiu_snp_crd[<%=obj.Dvm_aiuInfo[i].FUnitId%>] = <%=obj.Dvm_aiuInfo[i].cmpInfo.nDvmSnpInFlight%>;
    `uvm_info(get_type_name(), $psprintf("AIU with funitid: 0x%0h has 0x%0h DVM snoop credits", <%=obj.Dvm_aiuInfo[i].FUnitId%>, per_aiu_snp_crd[<%=obj.Dvm_aiuInfo[i].FUnitId%>]), UVM_LOW)
    <% } %>

    <% if(obj.testBench == "fsys") { %>
    if($test$plusargs("sysco_disable")) begin
       SnoopEn[31:0] = <%=SnpsEnb%>;
       <% if(SnpsEnb1 > 0) { %>
       SnoopEn[63:32] = <%=SnpsEnb1%>;
       <% } %>	     
       <% if(SnpsEnb2 > 0) { %>
       SnoopEn[95:64] = <%=SnpsEnb2%>;
       <% } %>	     
       <% if(SnpsEnb3 > 0) { %>
       SnoopEn[127:96] = <%=SnpsEnb3%>;
       <% } %>	     
       `uvm_info(get_type_name(), $psprintf("numDvmAgents=%0d, SnpsEnb=0x%0h, SnpsEnb1=0x%0h, SnpsEnb2=0x%0h, SnpsEnb3=0x%0h, initial SnoopEn: 0x%0h", DveSnpCapAgents, <%=SnpsEnb%>, <%=SnpsEnb1%>, <%=SnpsEnb2%>, <%=SnpsEnb3%>, SnoopEn), UVM_NONE)
    end // if ($test$plusargs("sysco_disable"))				     
    <% } else { %>
    if(!$test$plusargs("sysco_enable")) begin
       SnoopEn[31:0] = <%=SnpsEnb%>;
       <% if(SnpsEnb1 > 0) { %>
       SnoopEn[63:32] = <%=SnpsEnb1%>;
       <% } %>	     
       <% if(SnpsEnb2 > 0) { %>
       SnoopEn[95:64] = <%=SnpsEnb2%>;
       <% } %>	     
       <% if(SnpsEnb3 > 0) { %>
       SnoopEn[127:96] = <%=SnpsEnb3%>;
       <% } %>	     
       `uvm_info(get_type_name(), $psprintf("numDvmAgents=%0d, SnpsEnb=0x%0h, SnpsEnb1=0x%0h, SnpsEnb2=0x%0h, SnpsEnb3=0x%0h, initial SnoopEn: 0x%0h", DveSnpCapAgents, <%=SnpsEnb%>, <%=SnpsEnb1%>, <%=SnpsEnb2%>, <%=SnpsEnb3%>, SnoopEn), UVM_NONE)
    end // if (!$test$plusargs("sysco_enable"))
    <% } %>
     
    //SnoopEn = ((1 << DveSnpCapAgents)-1);
    
    //foreach(SnoopEn[i]) begin
    //   if(SnoopEn[i] == 1) begin
    //   	SnoopEn_FUNIT_IDS.push_back(DVM_AIU_FUNIT_IDS[i]);
    //    `uvm_info(get_type_name(),$sformatf("%0d:SnoopEn for FUNIT ID = %d and DVM_AIU_FUNIT_IDS = %d ",i,SnoopEn_FUNIT_IDS[i],DVM_AIU_FUNIT_IDS[i]), UVM_LOW)
    //   end
    //end

    if (!$value$plusargs("inject_cmdreq_transport_err=%d", inject_cmdreq_transport_err)) begin
      inject_cmdreq_transport_err = 0;
    end
    `ifndef FSYS_COVER_ON
    cov = new();
    `endif
    uvm_config_db #(dve_sb)::set(this, "dve_sb", "dve_sb", this);
  endfunction // build_pase

  // Run phase
  extern task run_phase(uvm_phase phase);

  extern function void report_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);

  // Write to ports
  extern function void write_smi_port(const ref smi_seq_item rcvd_pkt);
  extern function void write_clock_counter_port(<%=obj.BlockId%>_clock_counter_seq_item m_pkt);
  extern function void write_q_chnl(q_chnl_seq_item m_pkt) ;
  extern function void write_dve_debug_txn(dve_debug_txn csr);

  // DVE input manager
  extern function void process_cmd_req();
  extern function void process_cmd_rsp();
  extern function void process_str_req();
  extern function void process_dtw_req();
  extern function void process_dtw_rsp();
  extern function void process_dtw_dbg_req();
  extern function void process_dtw_dbg_rsp();
  extern function void process_sys_req();
  extern function void process_sys_rsp();
  extern function void process_sysEvent_req();

  // DVE snoop manager
  extern function void process_snp_req();
  extern function void process_snp_rsp();
  extern function void process_cmp_rsp();
  extern function void process_str_rsp();

  extern function void print_me(int idx=0, bit debug=0);
  extern function void print_ott_info();
  extern function void print_latency_data();
  extern function int  is_dvm_sync(const ref smi_seq_item m_item);

  extern virtual function void update_resiliency_ce_cnt(const ref smi_seq_item m_item);
  extern function int funitid2nunitid(int fUnitId);  
  extern function bit fuzzy_match(bit [31:0] a, bit [31:0] b, output bit error);
  extern task log_tacc_double_error();
  extern task log_tacc_single_error();
  extern task log_tacc_addr_error();
  extern task rtl_tacc_double_error();
  extern task rtl_tacc_single_error();
  extern task rtl_tacc_addr_error();
  extern task rtl_trace_captured();
  extern task rtl_trace_dropped();

endclass // dve_sb

////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------- 
// Q Channel
//----------------------------------------------------------------------- 
function void dve_sb::write_q_chnl(q_chnl_seq_item m_pkt);
  q_chnl_seq_item m_packet;
  q_chnl_seq_item m_packet_tmp;
  dve_sb_txn     txn;

  m_packet = new();

  $cast(m_packet_tmp, m_pkt);
  m_packet.copy(m_packet_tmp);

  `uvm_info("Q_Channel_resp_chnl", $sformatf("Entered..."), UVM_HIGH)
  //If power_down request has been accepted, at that time no outstanding transaction should be there
  if(m_packet.QACCEPTn == 'b0 && m_packet.QREQn == 'b0 && m_packet.QACTIVE == 'b0) begin
    `uvm_info("Q_Channel_resp_chnl", $sformatf("Q_Channel : Checking WTT and RTT Queue should be empty when Q Channel Req receives Accept."), UVM_HIGH)
    if (m_ott_q.size != 0) begin
      if(m_ott_q.size == 1 && ($stime - m_ott_q[0].cmd_req_pkt.t_smi_ndp_valid) <= 5ns) begin
        // CONC-11090: In certain situations the DVE SMI sequencer can inject a CMDreq in the same cycle that DVE
        // goes to sleep, and, per Satya, the SMI VIP must pick it up on that negedge, before clock gating can happen.
        // The RTL, in contrast, picks it up on the following posedge, which doesn't happen until wakeup.
        //
        // Because of this, it's possible to have one very recent SMI sequence item in the transaction table
        // as we go to sleep without it necessarily being a problem or indicative of an error.
        `uvm_warning("<%=obj.BlockId%>:print_m_ott_q", $sformatf("SMI seq injected packet while DVE was quiescing"))
      end else begin
        `uvm_error("<%=obj.BlockId%>:print_m_ott_q", $sformatf("Command queue is not empty when rtl asserted QACCEPTn"))
      end
    end
    else begin
      `uvm_info("<%=obj.BlockId%>:print_m_ott_q", $sformatf("Command queue is empty"), UVM_MEDIUM)
    end
  end
endfunction : write_q_chnl


// SMI 0 non data [request]  | TX | CMDreq
function void dve_sb::write_smi_port(const ref smi_seq_item rcvd_pkt);
  string msg;
  smi_seq_item m_packet, m_packet_tmp;
   
  //`uvm_info(get_type_name(), $psprintf("Inside write_smi_port: Received below SMI packet: %0s", rcvd_pkt.convert2string()), UVM_LOW)

  m_packet = new();
  $cast(m_packet_tmp, rcvd_pkt);
  m_packet.copy(m_packet_tmp);


        // get error statistics
        if(m_packet_tmp.ndp_corr_error || m_packet_tmp.hdr_corr_error || m_packet_tmp.dp_corr_error) begin
          update_resiliency_ce_cnt(m_packet_tmp);
        end
        num_smi_corr_err      += m_packet_tmp.ndp_corr_error + m_packet_tmp.hdr_corr_error + m_packet_tmp.dp_corr_error;
        num_smi_uncorr_err    += m_packet_tmp.ndp_uncorr_error + m_packet_tmp.hdr_uncorr_error + m_packet_tmp.dp_uncorr_error;
        num_smi_parity_err    += m_packet_tmp.ndp_parity_error + m_packet_tmp.hdr_uncorr_error + m_packet_tmp.dp_parity_error;

      

        m_packet.t_smi_ndp_valid = $time; 
        if(rcvd_pkt.isCmdMsg()) begin
          m_cmd_req_pkt = m_packet;
          process_cmd_req();
          cmdReq_cmstatus = m_cmd_req_pkt.smi_cmstatus_err;
        end else if(rcvd_pkt.isSnpMsg()) begin
          m_snp_req_pkt = m_packet;
          process_snp_req();
          snpReq_cmstatus = m_snp_req_pkt.smi_cmstatus_err;
        end else if(rcvd_pkt.isStrMsg()) begin
          m_str_req_pkt = m_packet;
          process_str_req();
        end else if(rcvd_pkt.isSnpRspMsg()) begin
          m_snp_rsp_pkt = m_packet;
          process_snp_rsp();
          snpRsp_cmstatus = m_snp_rsp_pkt.smi_cmstatus_err;
        end else if(rcvd_pkt.isStrRspMsg()) begin
          m_str_rsp_pkt = m_packet;
          process_str_rsp();
        end else  if(rcvd_pkt.isNcCmdRspMsg()) begin
          m_cmd_rsp_pkt = m_packet;
          process_cmd_rsp();
          cmdRsp_cmstatus = m_cmd_rsp_pkt.smi_cmstatus_err;
        end else if(rcvd_pkt.isDtwRspMsg()) begin
          m_dtw_rsp_pkt = m_packet;
          process_dtw_rsp();
          dtwReq_cmstatus = m_dtw_rsp_pkt.smi_cmstatus_err;
        end else if(rcvd_pkt.isCmpRspMsg()) begin
          m_cmp_rsp_pkt = m_packet;
          process_cmp_rsp();
        end else if(rcvd_pkt.isDtwMsg()) begin
          m_dtw_req_pkt = m_packet;
          process_dtw_req();
          dtwReq_cmstatus = m_dtw_req_pkt.smi_cmstatus_err;
        end else if(rcvd_pkt.isDtwDbgReqMsg()) begin
          m_dtw_dbg_req_pkt = m_packet;
          nb_DtwDbgReq_packet++;
          process_dtw_dbg_req();
        end else if(rcvd_pkt.isDtwDbgRspMsg()) begin
          m_dtw_dbg_rsp_pkt = m_packet;
          process_dtw_dbg_rsp();
        end else if(rcvd_pkt.isSysReqMsg()) begin
          m_sys_req_pkt = m_packet;
          sysReq_cmstatus = m_sys_req_pkt.smi_cmstatus_err;
          process_sys_req();
        end else if(rcvd_pkt.isSysRspMsg()) begin
          m_sys_rsp_pkt = m_packet;
          process_sys_rsp();
        end else begin
          msg = {"Received incorrect packet on SMI port: "};
          `uvm_error(get_type_name(), $psprintf("%0s %0s", msg, rcvd_pkt.convert2string()))
        end

        sb_stall_if.dropped_dtwdbgreq_packets = overall_traces_dropped;
        sb_stall_if.captured_dtwdbgreq_packets = nb_DtwDbgReq_packet - overall_traces_dropped;

        // record coverage
       `ifndef FSYS_COVER_ON
        cov.collect_smi_seq(m_packet);
        cov.collect_dve_input_manager(RBID_state,strRq_gen,CmdReq_type,dvmRq_order,DVM_NonSync_bypass);
        cov.collect_msg_cmstatus_error(cmdReq_cmstatus,cmdRsp_cmstatus,dtwReq_cmstatus,dtwRsp_cmstatus,snpReq_cmstatus,snpRsp_cmstatus,sysReq_cmstatus);
       `endif
        RBID_state = 0 ;
        strRq_gen  = 0 ;
        CmdReq_type = 0;
        dvmRq_order = 0 ;
	      DVM_NonSync_bypass = 0;
        cmdReq_cmstatus = 2;
        dtwReq_cmstatus = 2; //reset value
        snpRsp_cmstatus = 2; //reset value
        cmdRsp_cmstatus = 2; //reset value
        snpReq_cmstatus = 2;
        dtwRsp_cmstatus = 2;
        sysReq_cmstatus = 2;
endfunction // write_smi_port

function void dve_sb::write_clock_counter_port(<%=obj.BlockId%>_clock_counter_seq_item m_pkt);
   int sys_idx_q[$];
   int snp_idx_q[$];
   int del_idx_q[$];
   int nunitid;
   int src_nunitid;
   int update_snoop;
   
   if(m_pkt.probe_sig1 !== previous_csr_DvmSnoopDisable) begin
      `uvm_info(get_name(), $sformatf("csr_DvmSnoopDisable change: previous=0x%0h, current=0x%0h, m_sys_q size=%0d", previous_csr_DvmSnoopDisable, m_pkt.probe_sig1, m_sys_q.size()), UVM_MEDIUM)
      update_snoop = 0;
      if(m_sys_q.size() > 0) begin
         sys_idx_q = m_sys_q.find_index with(item.rcvd_snoop_update == 0);
         foreach(sys_idx_q[i]) begin
            nunitid = funitid2nunitid(m_sys_q[sys_idx_q[i]].sys_req_pkt.smi_src_ncore_unit_id);
            `uvm_info(get_name(), $sformatf("update_snoop_enables:DVE_UID:%0d: Update SnoopEn smi_src_id=0x%0h, nunitid=%0d", m_sys_q[sys_idx_q[i]].txn_id, m_sys_q[sys_idx_q[i]].sys_req_pkt.smi_src_ncore_unit_id, nunitid), UVM_MEDIUM)
            if(m_sys_q[sys_idx_q[i]].sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_ATTACH) begin
               SnoopEn[nunitid] = 1;
            end
            else if(m_sys_q[sys_idx_q[i]].sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_DETACH) begin
               SnoopEn[nunitid] = 0;
            end
            `uvm_info(get_name(), $sformatf("csr_DvmSnoopDisable change: old=0x%0h current SnoopEn=0x%0h", SnoopEn ^ (1<<nunitid), SnoopEn), UVM_MEDIUM)

            update_snoop = 1;
            m_sys_q[sys_idx_q[i]].rcvd_snoop_update = 1;
	    if(m_sys_q[sys_idx_q[i]].rcvd_sys_rsp == 1) begin
               `uvm_info(get_type_name(), $sformatf("update_snoop_enables:DVE_UID:%0d: Deleting m_sys_q[%0d] smi_src_id = 0x%0h", m_sys_q[sys_idx_q[i]].txn_id, sys_idx_q[i], m_sys_q[sys_idx_q[i]].sys_rsp_pkt.smi_src_ncore_unit_id), UVM_LOW)
               del_idx_q.push_front(sys_idx_q[i]);
	    end
         end // foreach (sys_idx_q[i])
      end // if (m_sys_q.size() > 0)

      foreach(del_idx_q[i]) begin
         // Do this deletion in the opposite order of the above loop.
         // This is to preserve the lower indices for their deletion.
         m_sys_q.delete(del_idx_q[i]);
      end
	 
      if(update_snoop == 1) begin
         numSnpsEnb = <%=dvm_agent%> - $countones(m_pkt.probe_sig1);
         snp_idx_q =  m_ott_q.find_index with((item.dtw_dbad_err==0) && (item.num_rcvd_snp_req1==0) && (item.num_rcvd_snp_req2==0));
         foreach(snp_idx_q[i]) begin
            src_nunitid = funitid2nunitid(m_ott_q[snp_idx_q[i]].cmd_req_pkt.smi_src_ncore_unit_id);
            if(SnoopEn[src_nunitid] == 0) begin
               if(numSnpsEnb > 0) begin
                  m_ott_q[snp_idx_q[i]].expd_snp_req1 = 1;
                  m_ott_q[snp_idx_q[i]].expd_snp_req2 = 1;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_req1 = numSnpsEnb;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_req2 = numSnpsEnb;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_rsp = numSnpsEnb;
               end
               else begin
                  m_ott_q[snp_idx_q[i]].expd_snp_req1 = 0;
                  m_ott_q[snp_idx_q[i]].expd_snp_req2 = 0;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_req1 = 0;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_req2 = 0;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_rsp = 0;
                  m_ott_q[snp_idx_q[i]].expd_cmp_rsp = 1;
               end
            end 
            else begin
               if(numSnpsEnb > 1) begin
                  m_ott_q[snp_idx_q[i]].expd_snp_req1 = 1;
                  m_ott_q[snp_idx_q[i]].expd_snp_req2 = 1;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_req1 = numSnpsEnb-1;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_req2 = numSnpsEnb-1;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_rsp = numSnpsEnb-1;
               end
               else begin
                  m_ott_q[snp_idx_q[i]].expd_snp_req1 = 0;
                  m_ott_q[snp_idx_q[i]].expd_snp_req2 = 0;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_req1 = 0;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_req2 = 0;
                  m_ott_q[snp_idx_q[i]].num_expd_snp_rsp = 0;
                  m_ott_q[snp_idx_q[i]].expd_cmp_rsp = 1;
               end
            end
             save_num_SnpEn = 1;
            `uvm_info(get_name(), $sformatf("update_snoop_enables:DVE_UID:%0d: Update SnpReq smi_src_id=0x%0h, smi_msg_id=0x%0h, num_expd_snp_req=%0d, num_expd_snp_rsp=%0d, SnoopEn=0x%0h", m_ott_q[snp_idx_q[i]].txn_id, m_ott_q[snp_idx_q[i]].cmd_req_pkt.smi_src_ncore_unit_id, m_ott_q[snp_idx_q[i]].cmd_req_pkt.smi_msg_id, m_ott_q[snp_idx_q[i]].num_expd_snp_req1, m_ott_q[snp_idx_q[i]].num_expd_snp_rsp, SnoopEn), UVM_LOW)
	 end // foreach (snp_idx_q[i])
      end // if (update_snoop == 1)
   end // if (m_pkt.probe_sig1 !== previous_csr_DvmSnoopDisable)

   previous_csr_DvmSnoopDisable = m_pkt.probe_sig1;

endfunction // write_cycle_tracker_port

////////////////////////////////////////////////////////////////////////////////

// DVE input manager
// SMI0 non data TX CMDreq
function void dve_sb::process_cmd_req();
  dve_sb_txn sb_pkt;
  string msg;
  int idx_q[$];
  int smi_error;
   
  `uvm_info(get_type_name(), $psprintf("process_cmd_req: Received SMI0 TX CMDreq %0s", m_cmd_req_pkt.convert2string()), UVM_LOW)

  idx_q = {};
  if(m_ott_q.size() > 0) begin
  idx_q = m_ott_q.find_index with(
           (item.cmd_req_pkt.smi_msg_id == m_cmd_req_pkt.smi_msg_id
            && item.cmd_req_pkt.smi_src_ncore_unit_id == m_cmd_req_pkt.smi_src_ncore_unit_id)
          );
  end

  for (int idx = idx_q.size()-1; idx >= 0; idx--) begin
    if (m_ott_q[idx_q[idx]].rcvd_cmp_rsp == 1) 
        idx_q.delete(idx);
  end

  if(idx_q.size() == 0) begin
    txn_id++;

    sb_pkt = new();
    sb_pkt.save_cmd_req_pkt(m_cmd_req_pkt);
    sb_pkt.rcvd_cmd_req = 1;
    sb_pkt.txn_id = txn_id;
 
    smi_error = m_cmd_req_pkt.hdr_uncorr_error + m_cmd_req_pkt.ndp_uncorr_error + m_cmd_req_pkt.hdr_parity_error + m_cmd_req_pkt.ndp_parity_error; 
    if(smi_error == 0) begin
       sb_pkt.expd_cmd_rsp = 1'b1;
       if (!m_cmd_req_pkt.smi_cmstatus_err) begin
          sb_pkt.expd_str_req = 1'b1;
       end
       if(m_cmd_req_pkt.smi_addr[13:11] == 3'b100) begin
          sb_pkt.is_cmd_sync = 1;
          CmdReq_type = 1;
          dvm_sync = 1;
        
          `uvm_info(get_type_name(), $psprintf("process_cmd_req:DVE_UID:%0d: Received SMI0 TX Sync CMDreq:%0s", sb_pkt.txn_id, sb_pkt.cmd_req_pkt.convert2string()), UVM_LOW)
       end
	   //#Check.DVE.DropTxn
       else begin
          `uvm_info(get_type_name(), $psprintf("process_cmd_req:DVE_UID:%0d: Received SMI0 TX CMDreq:%0s", sb_pkt.txn_id, sb_pkt.cmd_req_pkt.convert2string()), UVM_LOW)
          CmdReq_type = 2;
          dvm_no_sync = 1;
      end
      if ((m_cmd_req_pkt.smi_cmstatus[7:6] == 2'b11) && (inject_cmdreq_transport_err == 1)) begin
        // drop entire dvm msg when transport error
        drop_transport_error_dvm_msg = 1;
       <% if(obj.testBench == 'dve') { %>
       `ifndef VCS
        m_ott_q.delete(idx_q[0]);
       `else  // `ifndef VCS
        if (idx_q.size())begin
        m_ott_q.delete(idx_q[0]);
        end
       `endif  // `ifndef VCS ... `else ...
       <% } else {%>
        m_ott_q.delete(idx_q[0]);
       <% } %>
      end
       if (!m_cmd_req_pkt.smi_cmstatus_err) begin
          //sb_stall_if.perf_count_events["Active_STT_entries"].push_back(m_ott_q.size());
          m_ott_q.push_back(sb_pkt);->evt_stt;
          //sb_stall_if.perf_count_events["Active_STT_entries"].push_back(m_ott_q.size());
          ->e_cmd_req;
       end
    end // if (smi_error == 0)
    else begin
       `uvm_info(get_type_name(), $psprintf("process_cmd_req: Received SMI0 TX CMDreq with smi error.  ndp_uncorr_error=%0d, hdr_uncorr_error=%0d, ndp_parity_error=%0d, hdr_parity_error=%0d", m_cmd_req_pkt.ndp_uncorr_error, m_cmd_req_pkt.hdr_uncorr_error, m_cmd_req_pkt.ndp_parity_error, m_cmd_req_pkt.hdr_parity_error), UVM_LOW)
       `uvm_info(get_type_name(), $psprintf("process_cmd_req:DVE_UID:%0d: Received SMI0 TX CMDreq: %0s", sb_pkt.txn_id, sb_pkt.cmd_req_pkt.convert2string()), UVM_LOW)
    end
  end
  else begin
    `uvm_error(get_type_name(), $psprintf("process_cmd_req: Found pending SMI0 TX CMDreq with matching smi_msg_id = 0x%0h", m_cmd_req_pkt.smi_msg_id))
  end
  `ifndef FSYS_COVER_ON
  cov.collect_drop_transport_error_dvm_msg(drop_transport_error_dvm_msg);
  `endif
  drop_transport_error_dvm_msg=0;
endfunction // process_cmd_req

// SMI1 RX CMDrsp
function void dve_sb::process_cmd_rsp();
  string msg;
  int idx_q[$];

  `uvm_info(get_type_name(), $psprintf("process_cmd_rsp: Received SMI1 RX CMDrsp %0s", m_cmd_rsp_pkt.convert2string()), UVM_MEDIUM)

  idx_q = {};
  idx_q = m_ott_q.find_index with(
           (item.expd_cmd_rsp == 1)
           && (item.cmd_req_pkt.smi_msg_id == m_cmd_rsp_pkt.smi_rmsg_id)
           && (item.cmd_req_pkt.smi_src_ncore_unit_id == m_cmd_rsp_pkt.smi_targ_ncore_unit_id)
          );

  if(idx_q.size() == 0) begin
    `uvm_error(get_type_name(), $psprintf("process_cmd_rsp: Not expecting SMI1 RX CMDrsp with smi_rmsg_id = 0x%0h.  Received CMDrsp: %s", m_cmd_rsp_pkt.smi_rmsg_id, m_cmd_rsp_pkt.convert2string()))
  end
  else if(idx_q.size() > 1) begin
    `uvm_error(get_type_name(), $psprintf("process_cmd_rsp: Found more than 1 matching SMI1 RX CMDrsp with smi_rmsg_id = 0x%0h.  Received CMDrsp: %s", m_cmd_rsp_pkt.smi_rmsg_id, m_cmd_rsp_pkt.convert2string()))
  end
  else begin
    `uvm_info(get_type_name(), $psprintf("process_cmd_rsp:DVE_UID:%0d: Received SMI1 RX CMDrsp#%0d: %0s", m_ott_q[idx_q[0]].txn_id, m_ott_q[idx_q[0]].txn_id, m_cmd_rsp_pkt.convert2string()), UVM_LOW)

    if (m_ott_q[idx_q[0]].cmd_req_pkt.smi_targ_ncore_unit_id !== <%=obj.DveInfo[0].FUnitId%> && m_ott_q[idx_q[0]].cmd_req_pkt.smi_msg_id == m_cmd_rsp_pkt.smi_rmsg_id) begin
      `uvm_error(get_full_name(),$sformatf("DVE not dropping CMDreq with wrong targ_id, CMDreq smi_msg_id: %0h",m_ott_q[idx_q[0]].cmd_req_pkt.smi_msg_id))
       wrong_target_id=2;
    end
    wrong_target_id=1;

    // Clear CMDrsp flag
    m_ott_q[idx_q[0]].expd_cmd_rsp = 0;
    m_ott_q[idx_q[0]].rcvd_cmd_rsp = 1;
    m_ott_q[idx_q[0]].save_cmd_rsp_pkt(m_cmd_rsp_pkt);

    `uvm_info(get_type_name(), $psprintf("process_cmd_rsp:DVE_UID:%0d: Expected CMDrsp: %0s", m_ott_q[idx_q[0]].txn_id,  m_ott_q[idx_q[0]].expd_cmd_rsp_pkt.convert2string()), UVM_LOW)
    m_ott_q[idx_q[0]].expd_cmd_rsp_pkt.smi_msg_id = m_ott_q[idx_q[0]].cmd_rsp_pkt.smi_msg_id;
    void'(m_ott_q[idx_q[0]].expd_cmd_rsp_pkt.compare(m_ott_q[idx_q[0]].cmd_rsp_pkt));    

    // delete entry here for out-of-order case where CMDrsp is seen at SMI intf later
    if(m_ott_q[idx_q[0]].transport_error) begin
       m_ott_q.delete(idx_q[0]);
       ->e_str_rsp;
    end
    //if(m_ott_q[idx_q[0]].rcvd_cmd_rsp && m_ott_q[idx_q[0]].rcvd_str_req)
    //  m_ott_q[idx_q[0]].expd_dtw_req = 1;
    //print_me(idx_q[0]);
  end
  `ifndef FSYS_COVER_ON
  cov.collect_wrong_target_id(wrong_target_id);
  `endif
  wrong_target_id = 0;
endfunction // process_cmd_rsp

// SMI0 TX STRreq
function void dve_sb::process_str_req();
  string msg;
  int idx_q[$];
  int idx;
  int inflight_str_txn_idx_q[$];
  int src_id_match;
  int numSnpsEnb_str =$countones(SnoopEn);
  // to  resolve issue of number of snoop when we noo longer receive a sysco req and we still receive cmdreq 
  //number of snoop should be the latest value calculated on function write_clock_counter_port
   if($test$plusargs("enable_sysco_reattach")) begin
      if (save_num_SnpEn) begin
      numSnpsEnb_str = numSnpsEnb;
      `uvm_info(get_type_name(), $psprintf("process_str_req: numSnpsEnb_str= %0d, numSnpsEnb = %0d", numSnpsEnb_str, numSnpsEnb), UVM_MEDIUM)
      end
   end
  `uvm_info(get_type_name(), $psprintf("process_str_req: Received SMI0 RX STRreq %0s", m_str_req_pkt.convert2string()), UVM_MEDIUM)

  idx_q = {};
  idx_q = m_ott_q.find_index with(item.expd_str_req == 1
                                  && item.cmd_req_pkt.smi_msg_id == m_str_req_pkt.smi_rmsg_id
                                  && item.cmd_req_pkt.smi_src_ncore_unit_id == m_str_req_pkt.smi_targ_ncore_unit_id);

  inflight_str_txn_idx_q = {};
  inflight_str_txn_idx_q = m_ott_q.find_index with(
                            (item.rcvd_str_rsp == 0) &&
                            (item.rcvd_str_req == 1)
                           );

  //if(inflight_str_txn_idx_q.size() > 0) begin
  //  for(int i=0; i<inflight_str_txn_idx_q.size(); i++) begin
  //    if(m_str_req_pkt.smi_msg_id == m_ott_q[inflight_str_txn_idx_q[i]].str_req_pkt.smi_msg_id)
  //      `uvm_error("process_str_req", $psprintf("STRreq msg_id is not unique, matches with txn_id=%0d", m_ott_q[inflight_str_txn_idx_q[i]].txn_id))
  //  end
  //end

  if(idx_q.size() == 0) begin
      print_ott_info();
    `uvm_error(get_type_name(), $psprintf("process_str_req: Not expecting SMI0 RX STRreq with smi_rmsg_id = 0x%0h.  Received STRreq: %s", m_str_req_pkt.smi_rmsg_id, m_str_req_pkt.convert2string()))
      strRq_gen = 2;
    end
  else begin
    `uvm_info(get_type_name(), $psprintf("process_str_req:DVE_UID:%0d: Received SMI0 RX STRreq smi_rmsg_id = 0x%0h, targ_id = 0x%0h", m_ott_q[idx_q[0]].txn_id, m_str_req_pkt.smi_rmsg_id, m_str_req_pkt.smi_targ_ncore_unit_id), UVM_LOW)
    strRq_gen = 1;
    // Clear STRreq flag
    m_ott_q[idx_q[0]].expd_str_req = 0;
    m_ott_q[idx_q[0]].rcvd_str_req = 1;
    m_ott_q[idx_q[0]].save_str_req_pkt(m_str_req_pkt);
    m_ott_q[idx_q[0]].expd_snpreq_msg_id = snpreq_msg_id;

    // increment snpreq_msg_id counter
    snpreq_msg_id++;

    dvmRq_order = 1 ;
    // check DVE execution order - CONC-8845
    if(idx_q[0] > 0) begin
       for(idx=0; idx<idx_q[0]; idx++) begin
          if(m_ott_q[idx].rcvd_str_req == 0) begin
             print_me(idx);
             `uvm_error(get_type_name(),$sformatf("process_str_req: DVE sent STRreq out of order.  Received m_ott_q index %0d while index %0d hasn't receive STRreq.", idx_q[0], idx))
             dvmRq_order = 2;
          end
       end
    end

    latency_collection_strreq_q.push_back((m_ott_q[idx_q[0]].str_req_pkt.t_smi_ndp_valid - m_ott_q[idx_q[0]].cmd_req_pkt.t_smi_ndp_valid)/1000);
    `uvm_info(get_type_name(), $psprintf("process_str_req:DVE_UID:%0d: CMDReq time: %t, STRReq time: %t, latency:%0d", m_ott_q[idx_q[0]].txn_id, m_ott_q[idx_q[0]].cmd_req_pkt.t_smi_ndp_valid, m_ott_q[idx_q[0]].str_req_pkt.t_smi_ndp_valid, (m_ott_q[idx_q[0]].str_req_pkt.t_smi_ndp_valid - m_ott_q[idx_q[0]].cmd_req_pkt.t_smi_ndp_valid)/1000), UVM_HIGH)

    `uvm_info(get_type_name(), $psprintf("process_str_req:DVE_UID:%0d: Expected STRreq: %0s", m_ott_q[idx_q[0]].txn_id,  m_ott_q[idx_q[0]].expd_str_req_pkt.convert2string()), UVM_LOW)
    m_ott_q[idx_q[0]].expd_str_req_pkt.smi_msg_id = m_ott_q[idx_q[0]].str_req_pkt.smi_msg_id; 
    m_ott_q[idx_q[0]].expd_str_req_pkt.smi_rbid = m_ott_q[idx_q[0]].str_req_pkt.smi_rbid; 
    void'(m_ott_q[idx_q[0]].expd_str_req_pkt.compare(m_ott_q[idx_q[0]].str_req_pkt));

    m_ott_q[idx_q[0]].expd_dtw_req = 1;
     
    // Moved from process_dtw_req() since RTL can send SnpReq early, after 1 beat of DtwReq
    //set_expd_snp_reqrsp_count(m_ott_q) 
    m_ott_q[idx_q[0]].num_expd_snp_req1 = 0;
    m_ott_q[idx_q[0]].num_expd_snp_req2 = 0;
    m_ott_q[idx_q[0]].num_expd_snp_rsp  = 0;
    m_ott_q[idx_q[0]].num_rcvd_snp_req1 = 0;
    m_ott_q[idx_q[0]].num_rcvd_snp_req2 = 0;
    m_ott_q[idx_q[0]].num_rcvd_snp_rsp  = 0;
    foreach(SnoopEn_FUNIT_IDS[i]) begin
       if(m_ott_q[idx_q[0]].cmd_req_pkt.smi_src_ncore_unit_id == SnoopEn_FUNIT_IDS[i]) begin
          src_id_match = 1;
          break;
       end
       else begin
          src_id_match = 0;
       end
    end
    if ((src_id_match == 0) && (numSnpsEnb_str == 0)) begin
       m_ott_q[idx_q[0]].expd_cmp_rsp = 1'b1;
       m_ott_q[idx_q[0]].expd_snp_req1 = 0;
       m_ott_q[idx_q[0]].expd_snp_req2 = 0;
    end
    else if (src_id_match && (numSnpsEnb_str == 1)) begin
       m_ott_q[idx_q[0]].expd_cmp_rsp = 1'b1;
       m_ott_q[idx_q[0]].expd_snp_req1 = 0;
       m_ott_q[idx_q[0]].expd_snp_req2 = 0;
    end
    else begin
       m_ott_q[idx_q[0]].expd_snp_req1 = 1;
       m_ott_q[idx_q[0]].expd_snp_req2 = 1;
       m_ott_q[idx_q[0]].num_expd_snp_req1 = numSnpsEnb_str-1;
       m_ott_q[idx_q[0]].num_expd_snp_req2 = numSnpsEnb_str-1;
       m_ott_q[idx_q[0]].num_expd_snp_rsp  = numSnpsEnb_str-1;
    end
    `uvm_info(get_type_name(),$sformatf("process_str_req:DVE_UID:%0d: Expected number SNPreq1=%0d, number SNPrsp=%0d, numSnpsEnb_str=%0d \(SnoopEn=0x%0h\)", m_ott_q[idx_q[0]].txn_id, m_ott_q[idx_q[0]].num_expd_snp_req1, m_ott_q[idx_q[0]].num_expd_snp_rsp, numSnpsEnb_str, SnoopEn), UVM_LOW)

    //print_me(idx_q[0]);
  end
endfunction // process_str_req

function void dve_sb::process_dtw_req();
  string msg;
  int idx_q[$];
  int idx;
  bit dbad_err=0;
  bit src_id_match = 0;


  `uvm_info(get_type_name(), $psprintf("process_dtw_req: Received SMI2 TX DTWreq: %s", m_dtw_req_pkt.convert2string()), UVM_MEDIUM)

  idx_q = {};
  idx_q = m_ott_q.find_index with(
            (item.expd_dtw_req == 1) && (item.rcvd_dtw_req == 0) && (item.str_req_pkt != null) &&
            (item.str_req_pkt.smi_rbid == m_dtw_req_pkt.smi_rbid) &&
            (item.str_req_pkt.smi_targ_ncore_unit_id == m_dtw_req_pkt.smi_src_ncore_unit_id) 
          );
  //foreach(idx_q[i]) begin
  //  print_me(idx_q[i]);
  //end
  if(idx_q.size() == 0) begin
    print_ott_info();
    msg = {"Not expecting SMI2 TX DTWreq with smi_rbid = 0x%0h with SrcId = 0x%0h"};
    `uvm_error(get_type_name(), $psprintf("process_dtw_req: Not expecting SMI2 TX DTWreq with rbId=0x%0h SrcId = 0x%0h",
            m_dtw_req_pkt.smi_rbid, m_dtw_req_pkt.smi_src_ncore_unit_id))
   RBID_state = 2;
  end
  else if(idx_q.size() > 1) begin
    for (int i=0; i<$size(idx_q); i++) begin
       `uvm_info(get_name(), $psprintf("OTT[%0d] DTW: E=%0h R=%h; STR: E=%0d R=%0d; RBID=%0h",
				       i, m_ott_q[idx_q[i]].expd_dtw_req, m_ott_q[idx_q[i]].rcvd_dtw_req,
				       i, m_ott_q[idx_q[i]].expd_str_req, m_ott_q[idx_q[i]].rcvd_str_req,
				       m_dtw_req_pkt.smi_rbid), UVM_LOW)
    end
    `uvm_error(get_type_name(), $psprintf("process_dtw_req: Found more than 1 matching SMI2 TX DTWreq with smi_msg_id = 0x%0h smi_rbid=0x%0h",
            m_dtw_req_pkt.smi_msg_id, m_dtw_req_pkt.smi_rbid))
  RBID_state = 2;
  end
  else begin
    `uvm_info(get_type_name(), $psprintf("process_dtw_req:DVE_UID:%0d: Received SMI2 TX DTWreq: %p", m_ott_q[idx_q[0]].txn_id, m_dtw_req_pkt.convert2string()), UVM_LOW)
    `uvm_info(get_type_name(), $psprintf("process_dtw_req: Matching CMDREQ: %p", m_ott_q[idx_q[0]].cmd_req_pkt.convert2string()), UVM_LOW)
    `uvm_info(get_type_name(), $psprintf("process_dtw_req: Matching STRREQ: %p", m_ott_q[idx_q[0]].str_req_pkt.convert2string()), UVM_LOW)
    `uvm_info(get_type_name(), $psprintf("process_dtw_req: print m_ott_q idx: %p", m_ott_q[idx_q[0]]), UVM_LOW)
    RBID_state = 1;

    // Clear DTWreq flag
    m_ott_q[idx_q[0]].expd_dtw_req = 0;
    m_ott_q[idx_q[0]].rcvd_dtw_req = 1;
    m_ott_q[idx_q[0]].save_dtw_req_pkt(m_dtw_req_pkt);

    m_ott_q[idx_q[0]].expd_dtw_rsp = 1;

    //CONC-13283 Following check is to know if there are no snoop enabled agents available for the DVE to send snp_reqs to.
    //When DveSnpCapAgents=1 that signifies only the DVM intiating agent is snoop enabled, therefore it cannot snoop itself
    //Since there are no snoops, set expd_cmp_rsp here itself for forward progress of the txn handshake.
    if (DveSnpCapAgents == 1) begin
        m_ott_q[idx_q[0]].expd_cmp_rsp = 1'b1;
    end

    foreach(m_dtw_req_pkt.smi_dp_dbad[idx]) begin
        if (m_dtw_req_pkt.smi_dp_dbad[idx] !== 0) begin
            dbad_err = 1;
            DTWreq_msg_id_random_Dbad[m_dtw_req_pkt.smi_msg_id] = m_dtw_req_pkt.smi_src_ncore_unit_id;
        end
    end

    if (m_dtw_req_pkt.smi_cmstatus_err 
        || dbad_err) begin
        m_ott_q[idx_q[0]].expd_cmp_rsp = 1'b1;
        m_ott_q[idx_q[0]].expd_snp_req1 = 0;
        m_ott_q[idx_q[0]].expd_snp_req2 = 0;
        m_ott_q[idx_q[0]].num_expd_snp_req1 = 0;
        m_ott_q[idx_q[0]].num_expd_snp_req2 = 0;
        m_ott_q[idx_q[0]].num_expd_snp_rsp  = 0;
        if(dbad_err) 
           m_ott_q[idx_q[0]].dtw_dbad_err  = 1;
        //DVE  COV no_snoop CPMrsp with CMstatus error when bad req is received
        drop_bad_dvm_msg=1;
    end 
    if(m_dtw_req_pkt.smi_cmstatus[7:6] == 2'b11) // transport error
    begin
	//#Check.DVE.DTWreq.Drop
       // drop entire dvm msg when transport error
       `uvm_info(get_type_name(),$psprintf("process_dtw_req:DVE_UID:%0d: DTWreq has transport_error (cmstatus=0x%0h).  Dropping DVM pkt.", m_ott_q[idx_q[0]].txn_id, m_dtw_req_pkt.smi_cmstatus), UVM_LOW)
       drop_dtw_req_transport_error_dvm_msg=1;
       drop_transport_error_dvm_msg=2;
       m_ott_q.delete(idx_q[0]);
       ->e_str_rsp;
    end
  end // else: !if(idx_q.size() > 1)
//DVE cov
`ifndef FSYS_COVER_ON
cov.collect_drop_dtw_msg (drop_bad_dvm_msg);
cov.collect_drop_transport_error_dvm_msg(drop_transport_error_dvm_msg);
`endif
drop_bad_dvm_msg=0;
drop_transport_error_dvm_msg=0;
endfunction // process_dtw_req

// SMI1 RX DTWrsp
function void dve_sb::process_dtw_rsp();
  string msg;
  int idx_q[$];

  `uvm_info(get_type_name(), $psprintf("process_dtw_rsp: Received SMI TX1 DTWrsp: %s", m_dtw_rsp_pkt.convert2string()), UVM_MEDIUM)

  idx_q = {};
  idx_q = m_ott_q.find_index with(
           (item.expd_dtw_rsp == 1)
           && (item.dtw_req_pkt.smi_msg_id == m_dtw_rsp_pkt.smi_rmsg_id)
           && (item.cmd_req_pkt.smi_src_ncore_unit_id == m_dtw_rsp_pkt.smi_targ_ncore_unit_id)
          );

  foreach(idx_q[i]) begin
    `uvm_info(get_type_name(), $psprintf("process_dtw_rsp:DVE_UID:%0d: DTW MSGId:0x%0h and DTW RSP RMSGID:0x%0h", m_ott_q[idx_q[i]].txn_id,m_ott_q[idx_q[i]].dtw_req_pkt.smi_msg_id, m_dtw_rsp_pkt.smi_rmsg_id), UVM_LOW)
    end
  //foreach(idx_q[i]) begin
  //  print_me(idx_q[i]);
  //end
  if(idx_q.size() == 0) begin
    `uvm_error(get_type_name(), $psprintf("process_dtw_rsp: Not expecting SMI1 RX DTWrsp with smi_rmsg_id = 0x%0h", m_dtw_rsp_pkt.smi_rmsg_id))
  end
  else if(idx_q.size() > 1) begin
    `uvm_error(get_type_name(), $psprintf("process_dtw_rsp: Found more than 1 matching SMI1 RX DTWrsp with smi_rmsg_id = 0x%0h", m_dtw_rsp_pkt.smi_rmsg_id))
  end
  else begin
    `uvm_info(get_type_name(), $psprintf("process_dtw_rsp:DVE_UID:%0d: Received SMI1 RX DTWrsp smi_rmsg_id = 0x%0h", m_ott_q[idx_q[0]].txn_id, m_dtw_rsp_pkt.smi_rmsg_id), UVM_LOW)
     //if (m_dtw_rsp_pkt.smi_rmsg_id inside {DTWreq_msg_id_random_Dbad}) begin
     if ((DTWreq_msg_id_random_Dbad.exists(m_dtw_rsp_pkt.smi_rmsg_id)) && (DTWreq_msg_id_random_Dbad[m_dtw_rsp_pkt.smi_rmsg_id] == m_dtw_rsp_pkt.smi_targ_ncore_unit_id)) begin
       if (m_dtw_rsp_pkt.smi_cmstatus !== 8'b00000000) begin
         foreach (DTWreq_msg_id_random_Dbad[id])
	     `uvm_info("get_full_name()", $sformatf("DTWreq_msg_id_random_Dbad[0x%0h] = 0x%0h", id, DTWreq_msg_id_random_Dbad[id]), UVM_MEDIUM)
         `uvm_error(get_full_name(),$sformatf("smi_rmsg_id=0x%0h cmstatus = 0x%0h for nonzero Dbad value on DTWreq, should be 8'h0", m_dtw_rsp_pkt.smi_rmsg_id, m_dtw_rsp_pkt.smi_cmstatus))
       end
       DTWreq_msg_id_random_Dbad.delete(m_dtw_rsp_pkt.smi_rmsg_id);
     end
     
     if (m_ott_q[idx_q[0]].dtw_req_pkt.smi_targ_ncore_unit_id !== <%=obj.DveInfo[0].FUnitId%> && m_ott_q[idx_q[0]].dtw_req_pkt.smi_msg_id == m_dtw_rsp_pkt.smi_rmsg_id) begin
       `uvm_error(get_full_name(),$sformatf("DVE not dropping DTWreq with wrong targ_id, DTWreq smi_msg_id: %0h",m_ott_q[idx_q[0]].dtw_req_pkt.smi_msg_id))
     end

    // Clear DTWrsp flag
    m_ott_q[idx_q[0]].expd_dtw_rsp = 0;
    m_ott_q[idx_q[0]].rcvd_dtw_rsp = 1;
    m_ott_q[idx_q[0]].save_dtw_rsp_pkt(m_dtw_rsp_pkt);

    `uvm_info(get_type_name(), $psprintf("process_dtw_rsp:DVE_UID:%0d: Expected DTWrsp: %0s", m_ott_q[idx_q[0]].txn_id,  m_ott_q[idx_q[0]].expd_dtw_rsp_pkt.convert2string()), UVM_LOW)
    m_ott_q[idx_q[0]].expd_dtw_rsp_pkt.smi_msg_id = m_ott_q[idx_q[0]].dtw_rsp_pkt.smi_msg_id;
    void'(m_ott_q[idx_q[0]].expd_dtw_rsp_pkt.compare(m_ott_q[idx_q[0]].dtw_rsp_pkt));

    // m_ott_q[idx_q[0]].expd_snp_req1 = 1;
    // m_ott_q[idx_q[0]].expd_snp_req2 = 1;
  end
endfunction // process_dtw_rsp

function void dve_sb::process_dtw_dbg_req();

  `uvm_info(get_type_name(), $psprintf("process_dtw_dbg_req: Received SMI2 TX DTWDBGreq: %s", m_dtw_dbg_req_pkt.convert2string()), UVM_LOW)
  // Shunt trace/debug packets into their own queue
  trace_pkt_q.push_back(m_dtw_dbg_req_pkt);
  dtw_dbg_req_seen++;
  `uvm_info(get_type_name(), $psprintf("process_dtw_dbg_req: TS funit=0x%2h ts=0x%8h", m_dtw_dbg_req_pkt.smi_src_ncore_unit_id, m_dtw_dbg_req_pkt.smi_dp_data[0][31:0]), UVM_DEBUG)

endfunction // process_dtw_dbg_req

function void dve_sb::process_dtw_dbg_rsp();

  `uvm_info(get_type_name(), $psprintf("process_dtw_dbg_rsp: Received SMI2 TX DTWDBGrsp: %s", m_dtw_dbg_rsp_pkt.convert2string()), UVM_MEDIUM)
  // extract actual timestamp correction from RSP cmstatus. This looks like:
  // {pkt.smi_cmstatus_err[0], pkt.smi_cmstatus_err_payload[6:0]}, but that's just the whole field
  `uvm_info(get_type_name(), $psprintf("process_dtw_dbg_rsp: TS funit=%2h corr=%0d", m_dtw_dbg_rsp_pkt.smi_targ_ncore_unit_id, m_dtw_dbg_rsp_pkt.smi_cmstatus), UVM_DEBUG)
  if(trace_ts_corr_late_q.size() > 0) begin: rsp_is_late
    bit [7:0] exp_timestamp_correction, act_timestamp_correction;
    exp_timestamp_correction = trace_ts_corr_late_q.pop_front();
    act_timestamp_correction = m_dtw_dbg_rsp_pkt.smi_cmstatus;
    // usually this SMI transaction arrives before read-out from the CSRs can complete
    // However, that is not guaranteed, and in this case the CSRs were first
    if(exp_timestamp_correction != act_timestamp_correction) begin
      `uvm_error("<%=obj.BlockId%>_dve_sb:process_dtw_dbg_rsp",
                 $psprintf("Debug timestamp correction mismatch: updating ? -> ? csr = %2h smi = %2h",
                 exp_timestamp_correction, act_timestamp_correction))
    end
  end: rsp_is_late else begin
    // In this case the SMI does beat the CSR, so we don't do any checking here
    trace_ts_corr_q.push_back(m_dtw_dbg_rsp_pkt.smi_cmstatus);
  end

endfunction // process_dtw_dbg_rsp

// SMI0 non data TX SYSreq
function void dve_sb::process_sys_req();
  dve_sb_txn sb_pkt;
  string msg;
  int idx_q[$];
  int smi_error;
  int nunitid;
   
  `uvm_info(get_type_name(), $psprintf("process_sys_req: Received SMI0 TX SYSreq %0s", m_sys_req_pkt.convert2string()), UVM_MEDIUM)
  if(m_sys_req_pkt.smi_sysreq_op != 3) begin //If SysReq OP != Event
    // Check wrong target_id case
    if(m_sys_req_pkt.smi_targ_ncore_unit_id != DVE_FUNIT_IDS[0]) begin
      if(!$test$plusargs("inject_sys_trgt_id_err")) begin
          `uvm_error(get_type_name(), $psprintf("process_sys_req: Received SMI0 TX SYSreq with wrong target_id.  SysReq pkt: %s", m_sys_req_pkt.convert2string()))
      end
      else begin
          `uvm_info(get_type_name(), $psprintf("process_sys_req: Dropping SYSreq packet with wrong target_id.  SysReq pkt: %s", m_sys_req_pkt.convert2string()), UVM_LOW)
      end
    end
    else begin
    idx_q = {};
    idx_q = m_sys_q.find_index with(item.sys_req_pkt.smi_src_ncore_unit_id == m_sys_req_pkt.smi_src_ncore_unit_id);

    if(idx_q.size() == 0) begin
      sys_req_txn_id++;
  
      sb_pkt = new();
      sb_pkt.save_sys_req_pkt(m_sys_req_pkt);
      sb_pkt.txn_id = sys_req_txn_id;
      nunitid = funitid2nunitid(m_sys_req_pkt.smi_src_ncore_unit_id);

      smi_error = m_sys_req_pkt.hdr_uncorr_error + m_sys_req_pkt.ndp_uncorr_error + m_sys_req_pkt.hdr_parity_error + m_sys_req_pkt.ndp_parity_error; 
      if((m_sys_req_pkt.smi_cmstatus_err == 0) && (smi_error == 0)) begin
        sb_pkt.expd_sys_rsp = 1'b1;
        SysReq_Aiu[nunitid] = 1;

        if(m_sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_ATTACH) begin
            if(SnoopEn[nunitid] == 1) begin
              // redundant SysReq Attach
        sb_pkt.rcvd_snoop_update = 1;
        SysReqAttach_from_attached_aiu = 1;
            end
      else begin
        SysReqAttach_from_detached_aiu = 1;
            end
      
            if(m_ott_q.size() > 0)
        SysReqAttach_while_active = 1;
        
        end
        if(m_sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_DETACH) begin
            if(SnoopEn[nunitid] == 1) begin
        SysReqDetach_from_attached_aiu = 1;
            end
      else begin
              // redundant SysReq Detach
        sb_pkt.rcvd_snoop_update = 1;
        SysReqDetach_from_detached_aiu = 1;
            end

            if(m_ott_q.size() > 0)
        SysReqDetach_while_active = 1;
        end
        m_sys_q.push_back(sb_pkt);

        `ifndef FSYS_COVER_ON
        cov.collect_dve_sysreq(SysReqAttach_from_attached_aiu, SysReqAttach_from_detached_aiu, SysReqDetach_from_attached_aiu, SysReqDetach_from_detached_aiu, SysReqAttach_while_active, SysReqDetach_while_active);
        `endif
        SysReqAttach_from_attached_aiu = 0;
        SysReqAttach_from_detached_aiu = 0;
        SysReqDetach_from_attached_aiu = 0;
        SysReqDetach_from_detached_aiu = 0;
        SysReqAttach_while_active = 0;
        SysReqDetach_while_active = 0;
  
      end // if (smi_error == 0)
      else begin
        if(m_sys_req_pkt.smi_cmstatus[7:6] == 2'b11) begin
            `uvm_info(get_type_name(), $psprintf("process_sys_req: Dropping SYSreq packet with smi_cmstatus_error.  smi_cmstatus=0x%0h", m_sys_req_pkt.smi_cmstatus), UVM_MEDIUM)
        end
        else if(m_sys_req_pkt.smi_cmstatus[7:6] == 2'b10) begin
            `uvm_info(get_type_name(), $psprintf("process_sys_req: Got SYSreq packet with smi_cmstatus_error.  smi_cmstatus=0x%0h.  Expect SYSrsp but no snoop_enable update.", m_sys_req_pkt.smi_cmstatus), UVM_MEDIUM)
            SysReq_Aiu[nunitid] = 1;
            sb_pkt.expd_sys_rsp = 1'b1;
            sb_pkt.rcvd_snoop_update = 1'b1;
            m_sys_q.push_back(sb_pkt);
        end
        else begin
        `uvm_info(get_type_name(), $psprintf("process_sys_req: Dropping SYSreq packet with smi error.  ndp_uncorr_error=%0d, hdr_uncorr_error=%0d, ndp_parity_error=%0d, hdr_parity_error=%0d", m_sys_req_pkt.ndp_uncorr_error, m_sys_req_pkt.hdr_uncorr_error, m_sys_req_pkt.ndp_parity_error, m_sys_req_pkt.hdr_parity_error), UVM_MEDIUM)
        //`uvm_info(get_type_name(), $psprintf("process_sys_req: Received SMI0 TX SYSreq DVE_UID:%0d: %0s", sb_pkt.txn_id, sb_pkt.sys_req_pkt.convert2string()), UVM_MEDIUM)
        end	
      end // else: !if((m_sys_req_pkt.smi_cmstatus_error == 0) && (smi_error == 0))	
    end // if (idx_q.size() == 0)	
    else begin
      `uvm_error(get_type_name(), $psprintf("process_sys_req: Found pending SMI0 TX SYSreq with matching smi_msg_id = 0x%0h and smi_src_id = 0x%0h", m_sys_req_pkt.smi_msg_id, m_sys_req_pkt.smi_src_ncore_unit_id))
    end // else: !if(idx_q.size() == 0)	
    end // else: !if(m_sys_req_pkt.smi_targ_ncore_unit_id != DVE_FUNIT_IDS[0])
  end
  // Event Req
  else begin
    process_sysEvent_req();
    
    end
endfunction // process_sys_req

function void dve_sb::process_sysEvent_req();
  `undef LABEL
  `define LABEL "process_sysEvent_req"
  dve_sb_txn sb_pkt;

  sys_req_txn_id++;
  sb_pkt = new();
  sb_pkt.save_sys_req_pkt(m_sys_req_pkt);
  sb_pkt.txn_id = sys_req_txn_id;
   // `uvm_info(get_type_name(),$psprintf("Received sys req for AIU = %0h",m_sys_req_pkt.smi_targ_ncore_unit_id),UVM_NONE)
  // SysEvent req from sequence.
  if(m_sys_req_pkt.smi_targ_ncore_unit_id == DVE_FUNIT_IDS[0]) begin
      `uvm_info(get_type_name(),$psprintf("Received SysReq.Event into DVE= %0d %s",m_sys_req_pkt.smi_src_ncore_unit_id,m_sys_req_pkt.convert2string()),UVM_NONE+50)
      // Response from DVE RTL after RTL receiving all the responces from the AIU.
      sb_pkt.expd_sysEvent_rsp_out = 1'b1;
      <% for(i = 0; i < obj.DveInfo[0].sysEvtReceivers.length; i++) { %>
      if (<%=obj.DveInfo[0].sysEvtReceivers[i]%> !== m_sys_req_pkt.smi_src_ncore_unit_id) begin
          dve_sb_txn::sys_evnt_rcvrs_s rcvr;
          rcvr.funit_id = <%=obj.DveInfo[0].sysEvtReceivers[i]%>;
          rcvr.smi_msg_id = -1;
          `uvm_info(get_type_name(),$psprintf("Pushing above SysReq.Event into sys_evnt_rcvrs_q"),UVM_NONE+50)
          sb_pkt.sys_evnt_rcvrs_q.push_back(rcvr);
          //fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q.push_back(rcvr);
      end
      <% } %>
      m_sysEvent_q.push_back(sb_pkt);
  end
  // SysEvent req from DVE broadcaster
  else begin
      bit matched = 0;
      foreach (m_sysEvent_q[idx]) begin //Can just do with idx=0 hardcode
          //#Check.DVE.SysReqEvent_OutStandingReq
          //$display("KDB00 m_sysEvent_q[idx]=%p",m_sysEvent_q[idx]);
          foreach(m_sysEvent_q[idx].sys_evnt_rcvrs_q[pkt]) begin
              //$display("KDB00 m_sysEvent_q[idx].sys_evnt_rcvrs_q[pkt]=%p",m_sysEvent_q[idx].sys_evnt_rcvrs_q[pkt]);
              if(m_sys_req_pkt.smi_targ_ncore_unit_id == m_sysEvent_q[idx].sys_evnt_rcvrs_q[pkt].funit_id
                 && m_sysEvent_q[idx].sys_evnt_rcvrs_q[pkt].dve_sent == 0) begin
                  matched = 1;
                  m_sysEvent_q[idx].sys_evnt_rcvrs_q[pkt].dve_sent = 1;
                  m_sysEvent_q[idx].sys_evnt_rcvrs_q[pkt].smi_msg_id = m_sys_req_pkt.smi_msg_id;
                  `uvm_info(`LABEL, $sformatf(
                    "DVE_PKT_ID:%0d : DVE broadcasted SYSREQ for a SYS_EVENT transaction. %0s", 
                    m_sysEvent_q[idx].txn_id, m_sys_req_pkt.convert2string()), UVM_NONE+50)
                  break;
              end
          end
          if (matched == 1) break;
      end
      if (matched == 0) begin
          `uvm_error(`LABEL, $sformatf("Incoming SYS_EVENT didn't match any pending transactions. PKT: %0s", m_sys_req_pkt.convert2string()))
      end
      // Response from AIU that received event req.
      sb_pkt.expd_sysEvent_rsp_in = 1'b1; 
  end  
  //m_sysEvent_q.push_back(sb_pkt);

endfunction

// SMI1 RX SYSrsp
function void dve_sb::process_sys_rsp();
  `undef LABEL
  `define LABEL "process_sys_rsp"
  string msg;
  int idx_q[$];
  int idxEvent_TX_q[$];
  int idxEvent_RX_q[$];
  int nunitid;
  bit matched = 0;


  `uvm_info(get_type_name(), $psprintf("process_sys_rsp: Received SMI1 RX SYSrsp %0s", m_sys_rsp_pkt.convert2string()), UVM_MEDIUM)


  if(m_sys_rsp_pkt.smi_targ_ncore_unit_id == DVE_FUNIT_IDS[0]) begin //Incoming SysResp from AIUs
      foreach (m_sysEvent_q[idx]) begin
          foreach (m_sysEvent_q[idx].sys_evnt_rcvrs_q[i]) begin
              //#Check.DVE.SysReqEvent_ActiveAgents
              if (m_sysEvent_q[idx].sys_evnt_rcvrs_q[i].funit_id == m_sys_rsp_pkt.smi_src_ncore_unit_id
                 && m_sysEvent_q[idx].sys_evnt_rcvrs_q[i].dve_sent == 1
                 && m_sysEvent_q[idx].sys_evnt_rcvrs_q[i].smi_msg_id == m_sys_rsp_pkt.smi_rmsg_id) begin
                  m_sysEvent_q[idx].sys_evnt_rcvrs_q[i].rsp_rcvd = 1;
                  m_sysEvent_q[idx].sys_evnt_rcvrs_q.delete(i);
                  `uvm_info(`LABEL, $sformatf(
                     "DVE_PKT_ID:%0d : DVE received SYSRSP for a SYS_EVENT transaction. Deleting entry from sys_evnt_rcvrs_q %0s", 
                     m_sysEvent_q[idx].txn_id, m_sys_rsp_pkt.convert2string()), UVM_NONE+50)
                  matched = 1;
                  break;
              end // if match found
          end // foreach sys_evnt_rcvrs_q
      end // foreach sys_event txns
      if (matched == 0) begin
         `uvm_error(`LABEL, $sformatf("Incoming SYSRSP didn't match any pending transactions. PKT: %0s", m_sys_rsp_pkt.convert2string()))
      end
  end
  else begin

    idx_q = {};
    idxEvent_TX_q = {};
    idxEvent_RX_q = {};
    idx_q = m_sys_q.find_index with(
            (item.expd_sys_rsp == 1)
            && (item.sys_req_pkt.smi_msg_id == m_sys_rsp_pkt.smi_rmsg_id)
            && (item.sys_req_pkt.smi_src_ncore_unit_id == m_sys_rsp_pkt.smi_targ_ncore_unit_id)
            && (item.expd_sysEvent_rsp_out == 0) // Queue only for sys req
            && (item.expd_sysEvent_rsp_in == 0)
            );
    // Event Rsp from AIU
    idxEvent_TX_q = m_sysEvent_q.find_index with(
              (item.expd_sysEvent_rsp_in == 1)
              && (item.sys_req_pkt.smi_msg_id == m_sys_rsp_pkt.smi_rmsg_id)
              && (item.sys_req_pkt.smi_src_ncore_unit_id == m_sys_rsp_pkt.smi_targ_ncore_unit_id)
              );
    // Event Rsp from DVE after receiving all the rsp from AIU
    idxEvent_RX_q = m_sysEvent_q.find_index with(
              (item.expd_sysEvent_rsp_out == 1)
              && (item.sys_req_pkt.smi_msg_id == m_sys_rsp_pkt.smi_rmsg_id)
              && (item.sys_req_pkt.smi_src_ncore_unit_id == m_sys_rsp_pkt.smi_targ_ncore_unit_id)
    );
    

   if(idxEvent_TX_q.size() == 0 && idxEvent_RX_q.size() == 0) begin
    if(idx_q.size() == 0) begin
      `uvm_error(get_type_name(), $psprintf("process_sys_rsp: Not expecting SMI1 RX SYSrsp with smi_rmsg_id = 0x%0h.  Received SYSrsp: %s", m_sys_rsp_pkt.smi_rmsg_id, m_sys_rsp_pkt.convert2string()))
    end
    else if(idx_q.size() > 1) begin
      `uvm_error(get_type_name(), $psprintf("process_sys_rsp: Found more than 1 matching SYSreq for SMI1 RX SYSrsp with smi_rmsg_id = 0x%0h.  Received SYSrsp: %s", m_sys_rsp_pkt.smi_rmsg_id, m_sys_rsp_pkt.convert2string()))
    end
    else begin
      `uvm_info(get_type_name(), $psprintf("process_sys_rsp: Received SMI1 RX SYSrsp#%0d: %0s", m_sys_q[idx_q[0]].txn_id, m_sys_rsp_pkt.convert2string()), UVM_MEDIUM)

      nunitid = funitid2nunitid(m_sys_rsp_pkt.smi_targ_ncore_unit_id);
      <% if (!obj.noDVM) { %>
      if(SysReq_Aiu[nunitid] == 0) begin
        `uvm_error(get_type_name(), $psprintf("process_sys_rsp: SysReq_Aiu[%0d] is not set", nunitid))
      end
      <% } %>

      // clear attaching/detaching state
      SysReq_Aiu[nunitid] = 0;

      // set/unset SnoopEnable - now set in write_clock_counter_port based on csr probe
      //if(m_sys_q[idx_q[0]].sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_ATTACH) begin
      //   SnoopEn[nunitid] = 1;
      //end
      //else if(m_sys_q[idx_q[0]].sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_DETACH) begin
      //   SnoopEn[nunitid] = 0;
      //end

      `uvm_info(get_type_name(), $psprintf("process_sys_rsp:DVE_UID:%0d: Received SMI1 RX SYSrsp smi_rmsg_id = 0x%0h, smi_targ_id = 0x%0h, nunitid = %0d, SnoopEn=0x%0h", m_sys_q[idx_q[0]].txn_id, m_sys_rsp_pkt.smi_rmsg_id, m_sys_rsp_pkt.smi_targ_ncore_unit_id, nunitid, SnoopEn), UVM_LOW)

      // Clear SYSrsp flag
      m_sys_q[idx_q[0]].expd_sys_rsp = 0;
      m_sys_q[idx_q[0]].rcvd_sys_rsp = 1;
      m_sys_q[idx_q[0]].save_sys_rsp_pkt(m_sys_rsp_pkt);

      if(m_sys_q[idx_q[0]].rcvd_snoop_update == 1) begin
        `uvm_info(get_type_name(), $psprintf("process_sys_rsp:DVE_UID:%0d: Deleting m_sys_q[%0d] smi_rmsg_id = 0x%0h, smi_targ_id = 0x%0h", m_sys_q[idx_q[0]].txn_id, idx_q[0], m_sys_rsp_pkt.smi_rmsg_id, m_sys_rsp_pkt.smi_targ_ncore_unit_id), UVM_LOW)
        m_sys_q.delete(idx_q[0]);
      end
      else begin
        // delete entry if SysReq is redundant (ATTACH request when AIU is already in attached or DETACH request when AIU is already in detached)
        if (((m_sys_q[idx_q[0]].sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_ATTACH) && (SnoopEn[nunitid] == 1)) ||
            ((m_sys_q[idx_q[0]].sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_DETACH) && (SnoopEn[nunitid] == 0))
            )
        begin
            `uvm_info(get_type_name(), $psprintf("process_sys_rsp:DVE_UID:%0d: Deleting redundant SysReq in m_sys_q[%0d] smi_rmsg_id = 0x%0h, smi_targ_id = 0x%0h", m_sys_q[idx_q[0]].txn_id, idx_q[0], m_sys_rsp_pkt.smi_rmsg_id, m_sys_rsp_pkt.smi_targ_ncore_unit_id), UVM_LOW)
            `uvm_info(get_type_name(), $psprintf("process_sys_rsp: SnoopEn=0x%0h, sys_req pkt: %s", SnoopEn, m_sys_q[idx_q[0]].sys_req_pkt.convert2string()), UVM_LOW)
            m_sys_q.delete(idx_q[0]);
        end
      end // else: !if(m_sys_q[idx_q[0]].rcvd_snoop_update == 1)

    end // else: !if(idx_q.size() > 1)
   end
   else begin
   //process_sysEvent_rsp();

       int find_q[$];
       find_q = m_sysEvent_q.find_index with (item.sys_req_pkt.smi_msg_id == m_sys_rsp_pkt.smi_rmsg_id
                     && item.sys_req_pkt.smi_src_ncore_unit_id == m_sys_rsp_pkt.smi_targ_ncore_unit_id);
       if (find_q.size() > 0) begin
           //m_sysEvent_q[find_q[0]].sys_rsp_sent = 1;
           if (m_sysEvent_q[find_q[0]].sys_evnt_rcvrs_q.size() !== 0) begin
           `uvm_error(`LABEL, $sformatf("DVE sent SYS_EVENT RSP to originating unit, while it's still waiting for %0d SYSRSPes from other attached units. PKT: %0s",
               m_sysEvent_q[find_q[0]].sys_evnt_rcvrs_q.size(), m_sys_rsp_pkt.convert2string()))
           end
       end // foreach sys_event txns
       else begin
           `uvm_error(`LABEL, $sformatf("Outgoing SYSRSP didn't match any pending transactions. PKT: %0s", m_sys_rsp_pkt.convert2string()))
       end
       //$display("KDB0 idxEvent_RX_q.size()=%0d, idxEvent_TX_q.size()=%0d", idxEvent_RX_q.size(), idxEvent_TX_q.size());
       if(idxEvent_RX_q.size() > 0) begin
        `uvm_info(get_type_name(), $psprintf("Process_sys_rsp:  Rceived SMI RX SysEvent rep, idxEvent_RX_q.size()=%0d", idxEvent_RX_q.size()),UVM_LOW)
        //$display("KDB0 idxEvent_RX_q=%p", idxEvent_RX_q);
         m_sysEvent_q[idxEvent_TX_q[0]].expd_sysEvent_rsp_out = 0;
       end
       else begin
        `uvm_info(get_type_name(), $psprintf("Process_sys_rsp:  Rceived SMI TX SysEvent rep, idxEvent_TX_q.size()=%0d", idxEvent_TX_q.size()),UVM_LOW)
        //$display("KDB0 idxEvent_TX_q=%p", idxEvent_TX_q);
        m_sysEvent_q[idxEvent_TX_q[0]].expd_sysEvent_rsp_in = 0;
       end

   end

  end

endfunction // process_sys_rsp
////////////////////////////////////////////////////////////////////////////////

// DVE snoop manager
// SMI0 TX SNPreq
function void dve_sb::process_snp_req();
  string msg;
  bit is_snp_req2;
  int idx_q[$];
  int idx;
  int sync_idx_q[$];
  int inflight_snp_txn_idx_q[$];
  int nunitid; 
   num_avl_credit = 0;
  <% if (!obj.noDVM) { %>
   for(int j = 0; j < DveSnpCapAgents; j++) begin
      num_avl_credit = num_avl_credit + cmd_credits[DVM_AIU_FUNIT_IDS[j]];
   end
  <% } %>

  is_snp_req2 = m_snp_req_pkt.smi_mpf3_dvmop_portion;
  
  `uvm_info(get_type_name(), $psprintf("process_snp_req: Received SMI RX0 SNPreq #%0d: %s", (is_snp_req2 ? 2 : 1), m_snp_req_pkt.convert2string()), UVM_MEDIUM)
  //#Check.DVE.SnpReq_Detached_AIU

  nunitid = funitid2nunitid(m_snp_req_pkt.smi_targ_ncore_unit_id);
  if((is_snp_req2 == 0) && (SnoopEn[nunitid] == 0)) begin
      `uvm_error(get_type_name(), $psprintf("DVE sent a SnpReq1 to FunitID: 0x%0h, NunitId: %0d. That AIU is not in Attached state.  Current SnoopEn=0x%0h", m_snp_req_pkt.smi_targ_ncore_unit_id, nunitid, SnoopEn))
  end 
  //DVE cov the 2xSnpReq are sent in order
  snpreq_order=1;

  idx_q = {};

  <% if (obj.DveInfo[0].wAddr >= 44) { %>
  idx_q = is_snp_req2 ?
          m_ott_q.find_index with((item.expd_snp_req2 && item.dtw_req_pkt != null && item.str_req_pkt != null) && (item.dtw_req_pkt.smi_dp_data[0][43:4] == m_snp_req_pkt.smi_addr[43:4]) && (item.str_req_pkt.smi_msg_id == m_snp_req_pkt.smi_msg_id)) :
          m_ott_q.find_index with((item.expd_snp_req1 && item.cmd_req_pkt != null && item.str_req_pkt != null) && (item.cmd_req_pkt.smi_addr[40:4] == m_snp_req_pkt.smi_addr[40:4]) && (item.str_req_pkt.smi_msg_id == m_snp_req_pkt.smi_msg_id));
  <% } else { %>
  idx_q = is_snp_req2 ?
          m_ott_q.find_index with((item.expd_snp_req2 && item.dtw_req_pkt != null && item.str_req_pkt != null) && (item.dtw_req_pkt.smi_dp_data[0][<%=obj.DveInfo[0].wAddr%>-1:4] == m_snp_req_pkt.smi_addr[<%=obj.DveInfo[0].wAddr%>-1:4]) && (item.str_req_pkt.smi_msg_id == m_snp_req_pkt.smi_msg_id)) :
          m_ott_q.find_index with((item.expd_snp_req1 && item.cmd_req_pkt != null && item.str_req_pkt != null) && (item.cmd_req_pkt.smi_addr[<%=obj.DveInfo[0].wAddr%>-1:4] == m_snp_req_pkt.smi_addr[<%=obj.DveInfo[0].wAddr%>-1:4]) && (item.str_req_pkt.smi_msg_id == m_snp_req_pkt.smi_msg_id));
  <% } %>

  if (idx_q.size() != 1) begin
     `uvm_info($sformatf("%m"), $sformatf("SNP2=%0d, SNPREQ MSG_TYPE=%0h ADDR=%0h", is_snp_req2, m_snp_req_pkt.smi_msg_type,
					  m_snp_req_pkt.smi_addr[43:0]),UVM_LOW)
     foreach (m_ott_q[i]) begin
        if (is_snp_req2 && (m_ott_q[i].dtw_req_pkt != null)) begin
           `uvm_info($sformatf("%m"), $sformatf("DEBUG: DTWREQ = %p expd_snp_req1=%0d expd_snp_req2=%0d", m_ott_q[i].dtw_req_pkt.convert2string(), m_ott_q[i].expd_snp_req1, m_ott_q[i].expd_snp_req2), UVM_LOW)
        end else if (m_ott_q[i].cmd_req_pkt != null) begin
           `uvm_info($sformatf("%m"), $sformatf("DEBUG: CMDREQ = %p expd_snp_req1=%0d expd_snp_req2=%0d", m_ott_q[i].cmd_req_pkt.convert2string(), m_ott_q[i].expd_snp_req1, m_ott_q[i].expd_snp_req2), UVM_LOW)
        end
     end   
  end
  if (m_snp_req_pkt.smi_msg_id == snpreq_msg_id_width ) begin
       STTID_max_range =1;
  end
  //#Check.DVE.AIU_SNP_Credits
  if(idx_q.size() == 1) begin
    if (per_aiu_snp_crd[m_snp_req_pkt.smi_targ_ncore_unit_id] == 0) begin
        `uvm_error(get_type_name(), $psprintf("DVE sent a snoop to FunitID: 0x%0h. That AIU is out of all DVM snoop credits", m_snp_req_pkt.smi_targ_ncore_unit_id))
    end
    //#Check.DVE.SNP_Capable_AIU
    if (per_aiu_snp_crd.exists(m_snp_req_pkt.smi_targ_ncore_unit_id)) begin
        per_aiu_snp_crd[m_snp_req_pkt.smi_targ_ncore_unit_id]--;
        //DVE cov credit allocation/deallocation
        credit_dealloc = 1;
        `uvm_info(get_type_name(), $psprintf("process_snp_req: AIU with funitid: 0x%0h has 0x%0h DVM snoop credits", m_snp_req_pkt.smi_targ_ncore_unit_id, per_aiu_snp_crd[m_snp_req_pkt.smi_targ_ncore_unit_id]), UVM_LOW)
    end else begin
        `uvm_error(get_type_name(), $psprintf("Snoop received for Ncore unit ID: 0x%0h, but that isn't one of the DVM capable AIU", m_snp_req_pkt.smi_targ_ncore_unit_id))
    end

    //DVE should have only one out-standing Snp_Req : CONC-11981
    sync_idx_q = {};
    sync_idx_q = m_ott_q.find_index with(item.is_cmd_sync) ;
    if(sync_idx_q.size() == 0) begin
        `uvm_info(get_type_name(), $psprintf("process_snp_req: [Good] No Outstanding SNPreq found for DvmOpType Sync transaction"), UVM_LOW)
    end
    else begin
        foreach(sync_idx_q[i]) begin
          if((m_ott_q[idx_q[0]].txn_id != m_ott_q[sync_idx_q[i]].txn_id) && m_ott_q[idx_q[0]].is_cmd_sync && (m_ott_q[sync_idx_q[i]].rcvd_snp_req1 == 1)) begin
           //`uvm_error(get_type_name(), $psprintf("process_snp_req: Size of Sync CMDs %0d and Pending sync DVE_UID:%0d with requests received %0d and Requesting SNPreq's DVE_UID:%0d",sync_idx_q.size(), m_ott_q[sync_idx_q[i]].txn_id, m_ott_q[sync_idx_q[i]].num_expd_snp_req1,m_ott_q[idx_q[0]].txn_id))
          end
        end
    end

    //#Check.DVE.AIU_FUID_Snoop
    if (m_ott_q[idx_q[0]].cmd_req_pkt.smi_src_ncore_unit_id == m_snp_req_pkt.smi_targ_ncore_unit_id) begin
        print_me(idx_q[0]);
        `uvm_error(get_type_name(), $psprintf("process_snp_req: DVE shouldn't snoop the DVM initiator AIU. The targ_id of snp_req matches CMD_REQ's src_id."))
    end
    //DVE cov : snpreq_to_actif_agent only not to the rdvm requester
    snpreq_active =1;

      
    if(is_snp_req2) begin
      if((m_ott_q[idx_q[0]].rcvd_snp_req2 == 1) && (m_ott_q[idx_q[0]].num_expd_snp_req2 == m_ott_q[idx_q[0]].num_rcvd_snp_req2) && (m_ott_q[idx_q[0]].num_expd_snp_req1 == m_ott_q[idx_q[0]].num_rcvd_snp_req1))
        `uvm_error(get_type_name(), $psprintf("process_snp_req: SNPreq2 is already recieved, this should have been SNPreq1"))

      m_ott_q[idx_q[0]].rcvd_snp_req2 = 1;
      //m_ott_q[idx_q[0]].expd_snp_req2 = 0;
      m_ott_q[idx_q[0]].num_rcvd_snp_req2++;

      if(m_ott_q[idx_q[0]].num_expd_snp_req2 == m_ott_q[idx_q[0]].num_rcvd_snp_req2) 
        m_ott_q[idx_q[0]].expd_snp_req2 = 0;

      m_ott_q[idx_q[0]].save_snp_req2_pkt(m_snp_req_pkt);
      if(m_ott_q[idx_q[0]].snp_req1_pkt.smi_msg_id != m_snp_req_pkt.smi_msg_id)
        `uvm_error(get_type_name(), $psprintf("process_snp_req: SNPreq1 msg_id = 0x%0h is different from SNPreq2 msg_id = 0x%0h", m_ott_q[idx_q[0]].snp_req1_pkt.smi_msg_id, m_snp_req_pkt.smi_msg_id))

        //DVE cov 2xsnpreq are send to the same agent
        snpreq_1_2_same_agt=1;
    end
    else begin
      if((m_ott_q[idx_q[0]].rcvd_snp_req1 == 1) && (m_ott_q[idx_q[0]].num_expd_snp_req1 == m_ott_q[idx_q[0]].num_rcvd_snp_req1))
        `uvm_error(get_type_name(), $psprintf("process_snp_req: SNPreq1 is already recieved, this should have been SNPreq2"))

      // check SNPreq order - CONC-8842
      // #Check.DVE.v3.0.Transaction_order
      if(m_ott_q[idx_q[0]].rcvd_snp_req1 == 0) begin
        if(idx_q[0] > 0) begin
          for(idx=0; idx<idx_q[0]; idx++) begin
            if((m_ott_q[idx].num_expd_snp_req1 > 0) && (m_ott_q[idx].rcvd_snp_req1 == 0)) begin
              // allow NonSync to bypass Sync - CONC-8844
              if((m_ott_q[idx_q[0]].is_cmd_sync==0) && (m_ott_q[idx].is_cmd_sync==1)) begin
                `uvm_info(get_type_name(), $psprintf("process_snp_req: DVM NonSync bypass seen"), UVM_LOW)
		        DVM_NonSync_bypass = 1;
	          end
              else begin
                print_me(idx);
                print_me(idx_q[0]);
                //CONC-14114 Disabling following check for more than one outstanding DVM Sync Snoop. With the new csr update MaxOneDvmSync reset value is 0
                //This means DVE can send more than 1 outstanding Sync Snoop Txn.
                //A DVM Sync snoop transaction is outstanding if the transaction has SNPreq sent but SNPrsp not received
                //1 outstanding DVM Sync means 1 outstanding DVM Sync Broadcast
                `uvm_info(get_type_name(),$sformatf("process_snp_req: DVE sent SNPreq out of order, there is more than one outsanding DVM Sync Op.  Received m_ott_q index %0d while index %0d hasn't receive SNPreq.", idx_q[0], idx), UVM_LOW)
              end
            end
            //DVE COV SnpReq is sent with respect to the received CmdReq for Sync Op
            snpreq_order_sync_op = 1;  
	      end
	    end
        // check SNPreq msg_id is a running counter - CONC-8843
        if(m_snp_req_pkt.smi_msg_id != m_ott_q[idx_q[0]].expd_snpreq_msg_id) begin
          `uvm_error(get_type_name(),$sformatf("process_snp_req: SNPreq msg_id is not expected.  Received SNPreq msg_id=0x%0h, expect msg_id=0x%0h.", m_snp_req_pkt.smi_msg_id, m_ott_q[idx_q[0]].expd_snpreq_msg_id))
	    end
	    //increment snpreq_msg_id counter
        //snpreq_msg_id++;
        //DVE COv check STTID =snpred_msg_id
        STTID_snp_msg_id=1;
      end

      m_ott_q[idx_q[0]].rcvd_snp_req1 = 1;
      //m_ott_q[idx_q[0]].expd_snp_req1 = 0;
      m_ott_q[idx_q[0]].num_rcvd_snp_req1++;

      if(m_ott_q[idx_q[0]].num_expd_snp_req1 == m_ott_q[idx_q[0]].num_rcvd_snp_req1) 
        m_ott_q[idx_q[0]].expd_snp_req1 = 0;

      m_ott_q[idx_q[0]].save_snp_req1_pkt(m_snp_req_pkt);

      if(m_ott_q[idx_q[0]].rcvd_dtw_req) begin
      latency_collection_snpreq_q.push_back((m_ott_q[idx_q[0]].snp_req1_pkt.t_smi_ndp_valid - m_ott_q[idx_q[0]].dtw_req_pkt.t_smi_ndp_valid)/1000);
      `uvm_info(get_type_name(), $psprintf("process_snp_req:DVE_UID:%0d, DTWReq time: %t, SNPReq time: %t, latency:%0d", m_ott_q[idx_q[0]].txn_id, m_ott_q[idx_q[0]].dtw_req_pkt.t_smi_ndp_valid, m_ott_q[idx_q[0]].snp_req1_pkt.t_smi_ndp_valid, (m_ott_q[idx_q[0]].snp_req1_pkt.t_smi_ndp_valid - m_ott_q[idx_q[0]].dtw_req_pkt.t_smi_ndp_valid)/1000), UVM_HIGH)
      end
    end

    if(m_ott_q[idx_q[0]].rcvd_snp_req2) begin
      `uvm_info(get_type_name(), $psprintf("process_snp_req:DVE_UID:%0d: Received SMI0 SNPreq2 \#%0d: %0s,", m_ott_q[idx_q[0]].txn_id, m_ott_q[idx_q[0]].num_rcvd_snp_req2, m_snp_req_pkt.convert2string()), UVM_LOW)

      `uvm_info(get_type_name(), $psprintf("process_snp_req:DVE_UID:%0d: Expected SNPreq2: %0s", m_ott_q[idx_q[0]].txn_id,  m_ott_q[idx_q[0]].expd_snp_req2_pkt.convert2string()), UVM_LOW)
      //m_ott_q[idx_q[0]].expd_snp_req2_pkt.smi_msg_id = m_ott_q[idx_q[0]].snp_req2_pkt.smi_msg_id;
      //m_ott_q[idx_q[0]].expd_snp_req2_pkt.smi_targ_ncore_unit_id = m_ott_q[idx_q[0]].snp_req2_pkt.smi_targ_ncore_unit_id;
      //m_ott_q[idx_q[0]].expd_snp_req2_pkt.smi_mpf1_dtr_tgt_id= m_ott_q[idx_q[0]].snp_req2_pkt.smi_mpf1_dtr_tgt_id;
      //m_ott_q[idx_q[0]].expd_snp_req2_pkt.smi_mpf2_dtr_msg_id = m_ott_q[idx_q[0]].snp_req2_pkt.smi_mpf2_dtr_msg_id;
      //m_ott_q[idx_q[0]].expd_snp_req2_pkt.smi_mpf3_dvmop_portion = m_ott_q[idx_q[0]].snp_req2_pkt.smi_mpf3_dvmop_portion;
      if(m_ott_q[idx_q[0]].rcvd_dtw_req)
         //#Check.DVE.SMI_Snp2
         void'(m_ott_q[idx_q[0]].expd_snp_req2_pkt.compare(m_ott_q[idx_q[0]].snp_req2_pkt));
    end
    //else begin
    if(m_ott_q[idx_q[0]].rcvd_snp_req1) begin
      `uvm_info(get_type_name(), $psprintf("process_snp_req:DVE_UID:%0d: Received SMI0 SNPreq1 \#%0d: %0s", m_ott_q[idx_q[0]].txn_id, m_ott_q[idx_q[0]].num_rcvd_snp_req1, m_snp_req_pkt.convert2string()), UVM_LOW)

      if(m_ott_q[idx_q[0]].rcvd_dtw_req) begin
        `uvm_info(get_type_name(), $psprintf("process_snp_req:DVE_UID:%0d: Expected SNPreq1: %0s", m_ott_q[idx_q[0]].txn_id,  m_ott_q[idx_q[0]].expd_snp_req1_pkt.convert2string()), UVM_MEDIUM)
        //m_ott_q[idx_q[0]].expd_snp_req1_pkt.smi_msg_id = m_ott_q[idx_q[0]].snp_req1_pkt.smi_msg_id;
        //m_ott_q[idx_q[0]].expd_snp_req1_pkt.smi_targ_ncore_unit_id = m_ott_q[idx_q[0]].snp_req1_pkt.smi_targ_ncore_unit_id;
        //m_ott_q[idx_q[0]].expd_snp_req1_pkt.smi_mpf2_dtr_msg_id = m_ott_q[idx_q[0]].snp_req1_pkt.smi_mpf2_dtr_msg_id;
        //m_ott_q[idx_q[0]].expd_snp_req1_pkt.smi_mpf3_dvmop_portion = m_ott_q[idx_q[0]].snp_req1_pkt.smi_mpf3_dvmop_portion;
        //#Check.DVE.SMI_Snp1
        void'(m_ott_q[idx_q[0]].expd_snp_req1_pkt.compare(m_ott_q[idx_q[0]].snp_req1_pkt));
      end
    end

    if(m_ott_q[idx_q[0]].rcvd_snp_req1 && m_ott_q[idx_q[0]].rcvd_snp_req2 /*&& (m_ott_q[idx_q[0]].num_expd_snp_req1 == m_ott_q[idx_q[0]].num_rcvd_snp_req1) && (m_ott_q[idx_q[0]].num_expd_snp_req2 == m_ott_q[idx_q[0]].num_expd_snp_req2)*/)
      m_ott_q[idx_q[0]].expd_snp_rsp = 1;


    //print_me(idx_q[0]);
  end
  else begin
    `uvm_error(get_type_name(), $psprintf("process_snp_req: Not expecting SMI0 RX SNPreq with smi_msg_id = 0x%0h, smi_addr = 0x%0h and size of index is %0d", m_snp_req_pkt.smi_msg_id,m_snp_req_pkt.smi_addr,idx_q.size()))
  end
  `ifndef FSYS_COVER_ON
  cov.collect_snoop_manager(snpreq_active,snpreq_order,snpreq_order_sync_op,snpreq_1_2_same_agt,credit_dealloc,credit_alloc,STTID_max_range,STTID_snp_msg_id);
  `endif
  snpreq_active = 0;
  snpreq_order  =0;
  snpreq_order_sync_op = 0;
  snpreq_1_2_same_agt = 0;
  credit_dealloc = 0;
  STTID_max_range = 0;
  STTID_snp_msg_id = 0;
endfunction // process_snp_req

// SMI1 TX SNPrsp
function void dve_sb::process_snp_rsp();
  string msg;
  int idx_q[$];
  int snp_rsp_id_q[$];
  //if(snp_credit_cnt == snp_credit_max)
  //  `uvm_error("process_snp_rsp", $psprintf("snp_credit_cnt('d%0d) is at MAX='d%0d, so SNPrsp is not expected", snp_credit_cnt, snp_credit_max))


  idx_q = {};
  idx_q = m_ott_q.find_index with(
           (item.expd_snp_rsp == 1) //&&
           //(item.snp_req1_pkt.smi_msg_id == m_snp_rsp_pkt.smi_rmsg_id && item.snp_req1_pkt.smi_targ_ncore_unit_id == m_snp_rsp_pkt.smi_src_ncore_unit_id)
          );

  foreach(idx_q[i]) begin
     //print_me(idx_q[i]);
     `uvm_info(get_type_name(), $psprintf("process_snp_rsp:DVE_UID:%0d: TargId:0x%0h and SrcId:0x%0h", m_ott_q[idx_q[i]].txn_id,m_ott_q[idx_q[i]].snp_req1_pkt.smi_targ_ncore_unit_id, m_snp_rsp_pkt.smi_src_ncore_unit_id), UVM_LOW)
  end     

  if(idx_q.size() > 0) begin
      foreach(idx_q[i]) begin
         snp_rsp_id_q = {};
         snp_rsp_id_q = m_ott_q[idx_q[i]].snp_req1_pkt_q.find_index with (item.smi_msg_id == m_snp_rsp_pkt.smi_rmsg_id && item.smi_targ_ncore_unit_id == m_snp_rsp_pkt.smi_src_ncore_unit_id);

         if(snp_rsp_id_q.size() == 1) begin
             if (m_snp_rsp_pkt.smi_cmstatus_err == 1
                 && m_ott_q[idx_q[i]].snp_rsp_cmstatus_err == 0) begin
                 m_ott_q[idx_q[i]].snp_rsp_cmstatus_err = 1'b1;
                 // Error Arch spec 0.85 - any SNPrsp cmstatus_err will be logged as Address error
                 m_ott_q[idx_q[i]].snp_rsp_cmstatus_err_payload = 'h4;  // m_snp_rsp_pkt.smi_cmstatus_err_payload;
                 //DVE COV
                 snprsp_first_err = m_snp_rsp_pkt.smi_cmstatus_err_payload;
             end
              //m_ott_q[snp_rsp_id_q[0]].expd_snp_rsp = 0;
              m_ott_q[idx_q[i]].num_rcvd_snp_rsp++;
              if (m_ott_q[idx_q[i]].num_expd_snp_rsp == m_ott_q[idx_q[i]].num_rcvd_snp_rsp)
                m_ott_q[idx_q[i]].rcvd_snp_rsp = 1;
			  //#Check.DVE.SnpRsp_counter

              if (per_aiu_snp_crd.exists(m_snp_rsp_pkt.smi_src_ncore_unit_id)) begin
                per_aiu_snp_crd[m_snp_rsp_pkt.smi_src_ncore_unit_id] = per_aiu_snp_crd[m_snp_rsp_pkt.smi_src_ncore_unit_id] + 2;
                  //DVE cov credit allocation/deallocation
                  credit_alloc = 1;
                `uvm_info(get_type_name(), $psprintf("process_snp_rsp: AIU with funitid: 0x%0h has 0x%0h DVM snoop credits", m_snp_rsp_pkt.smi_src_ncore_unit_id, per_aiu_snp_crd[m_snp_rsp_pkt.smi_src_ncore_unit_id]), UVM_LOW)
                //TODO: Add a check to make sure this value doesnt exceed the total allocated credit. low priority
              end else begin
                `uvm_error(get_type_name(), $psprintf("Snoop received for Ncore unit ID: 0x%0h, but that isn't one of the DVM capable AIU", m_snp_rsp_pkt.smi_src_ncore_unit_id))
              end


              if(m_ott_q[idx_q[i]].num_expd_snp_rsp == m_ott_q[idx_q[i]].num_rcvd_snp_rsp) begin 
                m_ott_q[idx_q[i]].expd_snp_rsp = 0;
                m_ott_q[idx_q[i]].save_snp_rsp_pkt(m_snp_rsp_pkt);
                `uvm_info(get_type_name(), $psprintf("process_snp_rsp:DVE_UID:%0d: Received all SMI0 RX SNPrsp smi_rmsg_id = 0x%0h", m_ott_q[idx_q[i]].txn_id, m_snp_rsp_pkt.smi_rmsg_id), UVM_LOW)
              end
              else begin
                `uvm_info(get_type_name(), $psprintf("process_snp_rsp:DVE_UID:%0d: Received SMI0 RX SNPrsp \#%0d (of %0d) smi_rmsg_id = 0x%0h", m_ott_q[idx_q[i]].txn_id, m_ott_q[idx_q[i]].num_rcvd_snp_rsp, m_ott_q[idx_q[i]].num_expd_snp_rsp, m_snp_rsp_pkt.smi_rmsg_id), UVM_LOW)
              end

             `uvm_info(get_type_name(),$psprintf("process_snp_rsp:DVE_UID:%0d: Deleting SNPrsp TargId:0x%0h and SrcID:0x%0h", m_ott_q[idx_q[i]].txn_id,m_ott_q[idx_q[i]].snp_req1_pkt_q[snp_rsp_id_q[0]].smi_targ_ncore_unit_id,m_snp_rsp_pkt.smi_src_ncore_unit_id), UVM_LOW)
             m_ott_q[idx_q[i]].snp_req1_pkt_q.delete(snp_rsp_id_q[0]);
             if((m_ott_q[idx_q[i]].rcvd_snp_rsp == 1) && (m_ott_q[idx_q[i]].num_expd_snp_rsp == m_ott_q[idx_q[i]].num_rcvd_snp_rsp)) begin
                if (m_snp_rsp_pkt.smi_cmstatus[7:6] == 2'b11) begin
                   // drop entire dvm msg when transport error
                   `uvm_info(get_type_name(),$psprintf("process_snp_rsp:DVE_UID:%0d: SNPrsp has transport_error (cmstatus=0x%0h).  Dropping DVM pkt.", m_ott_q[idx_q[i]].txn_id, m_snp_rsp_pkt.smi_cmstatus), UVM_NONE)
                   m_ott_q[idx_q[i]].transport_error = 1;
                   drop_snp_rsp_transport_error_dvm_msg = 1;
                   drop_transport_error_dvm_msg = 3;
                   if(m_ott_q[idx_q[i]].rcvd_cmd_rsp == 1) begin  // workaround when CMDrsp is seen out-of-order on SMI intf
                      m_ott_q.delete(idx_q[i]);
                      ->e_str_rsp;
                   end
                end
                else begin
                   `uvm_info(get_type_name(),$psprintf("process_snp_rsp:DVE_UID:%0d: Received all SNPrsp for Setting expd_cmp_rsp", m_ott_q[idx_q[i]].txn_id), UVM_LOW)
                   m_ott_q[idx_q[i]].expd_cmp_rsp = 1;
		end
             end
       end // if (snp_rsp_id_q.size() == 1)
    end // foreach (idx_q[i])
  end // if (idx_q.size() > 0)
  else begin
    `uvm_error(get_type_name(), $psprintf("process_snp_rsp: Not expecting SMI1 TX SNPrsp with smi_rmsg_id = 0x%0h and index = %0d", m_snp_rsp_pkt.smi_rmsg_id,idx_q.size()))
  end
  `ifndef FSYS_COVER_ON
  cov.collect_snoop_manager(snpreq_active,snpreq_order,snpreq_order_sync_op,snpreq_1_2_same_agt,credit_dealloc,credit_alloc,STTID_max_range,STTID_snp_msg_id);
  credit_alloc = 0;
  cov.collect_SNPrsp_first_error(snprsp_first_err);
  snprsp_first_err = 0;
  cov.collect_drop_transport_error_dvm_msg(drop_transport_error_dvm_msg);
  drop_transport_error_dvm_msg=0;
  `endif 
endfunction // process_snp_rsp

// SMI1 RX CMPrsp
function void dve_sb::process_cmp_rsp();
  string msg;
  int idx_q[$];
  int idx;
  bit cmprsp_gen;

  `uvm_info(get_type_name(), $psprintf("process_cmp_rsp: Received SMI1 RX CMPrsp: %s", m_cmp_rsp_pkt.convert2string()), UVM_LOW)

  idx_q = {};
  idx_q = m_ott_q.find_index with(
           (item.expd_cmp_rsp == 1)
           && (item.cmd_req_pkt.smi_msg_id == m_cmp_rsp_pkt.smi_rmsg_id)
           && (item.cmd_req_pkt.smi_src_ncore_unit_id == m_cmp_rsp_pkt.smi_targ_ncore_unit_id)
          );

  //foreach(idx_q[i]) begin
  //  print_me(idx_q[i]);
  //end
  //if(idx_q.size() == 0) begin
  //  msg = {"Not expecting SMI1 RX CMPrsp with smi_rmsg_id = %0d"};
  //  `uvm_error("process_cmp_rsp", $psprintf(msg, m_cmp_rsp_pkt.smi_rmsg_id))
  //end
  //else if(idx_q.size() > 1) begin
  //  msg = {"Found more than 1 matching SMI1 RX CMPrsp with smir_msg_id = %0d"};
  //  `uvm_error("process_cmp_rsp", $psprintf(msg, m_cmp_rsp_pkt.smi_rmsg_id))
  //end
  //else begin
  //  snp_credit_cnt++;
  if(idx_q.size() == 1) begin
    `uvm_info(get_type_name(), $psprintf("process_cmp_rsp:DVE_UID:%0d: Received SMI1 RX CMPrsp smi_rmsg_id = 0x%0h", m_ott_q[idx_q[0]].txn_id, m_cmp_rsp_pkt.smi_rmsg_id), UVM_LOW)
    cmprsp_gen=1;
    if (m_ott_q[idx_q[0]].rcvd_snp_rsp === 1 && m_ott_q[idx_q[0]].snp_rsp_pkt.smi_targ_ncore_unit_id !== <%=obj.DveInfo[0].FUnitId%>) begin
      `uvm_error(get_type_name(),$sformatf("process_cmp_rsp: DVE not dropping SNPrsp with wrong targ_id, SNPrsp smi_msg_id: %0h",m_ott_q[idx_q[0]].snp_rsp_pkt.smi_msg_id))
    end

    // check CMPrsp order - CONC-8803 - not valid
    //if(idx_q[0] > 0) begin
    //   for(idx=0; idx<idx_q[0]; idx++) begin
    //      if(m_ott_q[idx].rcvd_cmp_rsp == 0) begin
    //          print_me(idx);
    //         `uvm_error(get_type_name(),$sformatf("process_cmp_rsp: DVE sent CMPrsp out of order.  Received m_ott_q index %0d while index %0d hasn't receive CMPrsp.", idx_q[0], idx))
    //      end
    //   end
    //end       

    // Clear CMPrsp flag
    m_ott_q[idx_q[0]].expd_cmp_rsp = 0;
    m_ott_q[idx_q[0]].rcvd_cmp_rsp = 1;
    `uvm_info(get_type_name(), $psprintf("process_cmp_rsp:DVE_UID:%0d: setting expd_cmp_rsp=0", m_ott_q[idx_q[0]].txn_id), UVM_MEDIUM)
    m_ott_q[idx_q[0]].save_cmp_rsp_pkt(m_cmp_rsp_pkt);

    if( m_ott_q[idx_q[0]].num_rcvd_snp_rsp > 0) begin
       latency_collection_cmprsp_q.push_back((m_ott_q[idx_q[0]].cmp_rsp_pkt.t_smi_ndp_valid - m_ott_q[idx_q[0]].snp_rsp_pkt.t_smi_ndp_valid)/1000);
       `uvm_info(get_type_name(), $psprintf("process_cmp_rsp:DVE_UID:%0d: SNPRsp time: %t, CMPRsp time: %t, latency:%0d", m_ott_q[idx_q[0]].txn_id, m_ott_q[idx_q[0]].snp_rsp_pkt.t_smi_ndp_valid, m_ott_q[idx_q[0]].cmp_rsp_pkt.t_smi_ndp_valid, (m_ott_q[idx_q[0]].cmp_rsp_pkt.t_smi_ndp_valid - m_ott_q[idx_q[0]].snp_rsp_pkt.t_smi_ndp_valid)/1000), UVM_HIGH)
    end else begin
       latency_collection_cmprsp_q.push_back(0);
    end

    `uvm_info(get_type_name(), $psprintf("process_cmp_rsp:DVE_UID:%0d: Expected CMPrsp: %0s", m_ott_q[idx_q[0]].txn_id,  m_ott_q[idx_q[0]].expd_cmp_rsp_pkt.convert2string()), UVM_LOW)
    m_ott_q[idx_q[0]].expd_cmp_rsp_pkt.smi_msg_id = m_ott_q[idx_q[0]].cmp_rsp_pkt.smi_msg_id;
    void'(m_ott_q[idx_q[0]].expd_cmp_rsp_pkt.compare(m_ott_q[idx_q[0]].cmp_rsp_pkt));

    m_ott_q[idx_q[0]].expd_str_rsp = 1;
  end
  else begin
    print_ott_info();
    `uvm_error(get_type_name(), $psprintf("process_cmp_rsp: Not expecting SMI1 RX CMPrsp with smi_targ_id = 0x%0h smi_rmsg_id = 0x%0h.  Found %0d matches in OTT queue.", m_cmp_rsp_pkt.smi_targ_ncore_unit_id, m_cmp_rsp_pkt.smi_rmsg_id, idx_q.size()))
  end
  //DVE cov CMPrsp generation 
  `ifndef FSYS_COVER_ON
  cov.collect_cmprsp(cmprsp_gen);
  cov.collect_drop_dtw_msg (m_ott_q[idx_q[0]].drop_bad_dvm_msg);
  `endif
endfunction // process_cmp_rsp

// SMI1 TX STRrsp
function void dve_sb::process_str_rsp();
  string msg;
  int idx_q[$];

  idx_q = {};
  idx_q = m_ott_q.find_index with(
           (item.expd_str_rsp == 1) && (item.rcvd_dtw_rsp == 1)
           && (item.str_req_pkt.smi_msg_id == m_str_rsp_pkt.smi_rmsg_id)
           && (item.str_req_pkt.smi_targ_ncore_unit_id == m_str_rsp_pkt.smi_src_ncore_unit_id)
          );

  if(idx_q.size() == 0) begin
    `uvm_error(get_type_name(), $psprintf("process_str_rsp: Not expecting SMI1 TX STRrsp with smi_rmsg_id = 0x%0h.  Received STRrsp: %s", m_str_rsp_pkt.smi_rmsg_id, m_str_rsp_pkt.convert2string()))
  end
  else if(idx_q.size() > 1) begin
    `uvm_error(get_type_name(), $psprintf("process_str_rsp: Found more than 1 matching SMI1 TX STRrsp with smi_rmsg_id = 0x%0h.  Received STRrsp: %s", m_str_rsp_pkt.smi_rmsg_id, m_str_rsp_pkt.convert2string()))
  end
  else begin
    `uvm_info(get_type_name(), $psprintf("process_str_rsp:DVE_UID:%0d: Received SMI1 TX STRrsp: %s.", m_ott_q[idx_q[0]].txn_id, m_str_rsp_pkt.convert2string()), UVM_LOW)

    // Clear STRrsp flag
    m_ott_q[idx_q[0]].expd_str_rsp = 0;
    m_ott_q[idx_q[0]].rcvd_str_rsp = 1;
    m_ott_q[idx_q[0]].save_str_rsp_pkt(m_str_rsp_pkt);

    if((m_ott_q[idx_q[0]].rcvd_cmd_req == 0) ||
       (m_ott_q[idx_q[0]].rcvd_cmd_rsp == 0) ||
       (m_ott_q[idx_q[0]].rcvd_str_req == 0) ||
       (m_ott_q[idx_q[0]].rcvd_dtw_req == 0) ||
       (m_ott_q[idx_q[0]].rcvd_dtw_rsp == 0) ||
       (m_ott_q[idx_q[0]].expd_snp_req1 == 1) ||
       (m_ott_q[idx_q[0]].expd_snp_req2 == 1) ||
       (m_ott_q[idx_q[0]].expd_snp_rsp == 1) ||
       (m_ott_q[idx_q[0]].rcvd_cmp_rsp == 0) ||
       (m_ott_q[idx_q[0]].rcvd_str_rsp == 0)) begin
        print_me(idx_q[0]);
        `uvm_error(get_type_name(), $psprintf("process_str_rsp: All packets are not received. Failing packet print above"))
       end

    //`uvm_info(get_type_name(), $psprintf("process_str_rsp: Before deleting"), UVM_LOW)
    //foreach(idx_q[i])begin
    //  print_me(idx_q[i]);
    //end
    `uvm_info(get_type_name(), $psprintf("process_str_rsp:DVE_UID:%0d: STRrsp is received, deleting OTT entry. total entries = %0d, pending entries = %0d", m_ott_q[idx_q[0]].txn_id, txn_id, m_ott_q.size()), UVM_LOW)
    m_ott_q.delete(idx_q[0]);->evt_del_stt;
    //sb_stall_if.perf_count_events["Active_STT_entries"].push_back(m_ott_q.size());
    //`uvm_info(get_type_name(), $psprintf("process_str_rsp: After deleting"), UVM_LOW)
    //foreach(idx_q[i])begin
    //  print_me(idx_q[i]);
    //end
    ->e_str_rsp;
  end
endfunction // process_str_rsp

function void dve_sb::print_me(int idx=0, bit debug=0);
    //bit rcvd_pkts_status_arr[string];
    string msg;

    //rcvd_pkts_status_arr[]
    $sformat(msg, "\nPKT#%0d: %0s",
                        m_ott_q[idx].txn_id,
                        (m_ott_q[idx].cmd_req_pkt != null) ? m_ott_q[idx].cmd_req_pkt.convert2string() : "CMDReq not found in entry");
        if (m_ott_q[idx].cmd_req_pkt!== null)
            $sformat(msg, "%s, \nCMDReq MSGID: 0x%0h",msg, m_ott_q[idx].cmd_req_pkt.smi_msg_id);
        if (m_ott_q[idx].cmd_req_pkt!== null)
            $sformat(msg, "%s, is_cmd_sync: 0x%0h",msg, m_ott_q[idx].is_cmd_sync);            
        if (m_ott_q[idx].str_req_pkt!== null)
            $sformat(msg, "%s, STRReq MSGID: 0x%0h",msg, m_ott_q[idx].str_req_pkt.smi_msg_id);
        if (m_ott_q[idx].str_req_pkt!== null)
            $sformat(msg, "%s, STRReq RMSGID: 0x%0h",msg, m_ott_q[idx].str_req_pkt.smi_rmsg_id);
        if (m_ott_q[idx].str_req_pkt!== null)
            $sformat(msg, "%s, STRReq TargId: 0x%0h",msg, m_ott_q[idx].str_req_pkt.smi_targ_ncore_unit_id);
        if (m_ott_q[idx].dtw_req_pkt!== null)
            $sformat(msg, "%s, DTWReq RMSGID: 0x%0h",msg, m_ott_q[idx].dtw_req_pkt.smi_rmsg_id);
        if (m_ott_q[idx].dtw_req_pkt!== null)
            $sformat(msg, "%s, DTWReq SrcId: 0x%0h",msg, m_ott_q[idx].dtw_req_pkt.smi_src_ncore_unit_id);
        if (m_ott_q[idx].dtw_req_pkt!== null)
            $sformat(msg, "%s, DTWReq MSGID: 0x%0h",msg, m_ott_q[idx].dtw_req_pkt.smi_msg_id);
        if (m_ott_q[idx].dtw_rsp_pkt!== null)
            $sformat(msg, "%s, DTWRsp RMSGID: 0x%0h",msg, m_ott_q[idx].dtw_rsp_pkt.smi_rmsg_id);
        if (m_ott_q[idx].snp_req1_pkt!== null)
            $sformat(msg, "%s, SNPReq1 MSGID: 0x%0h",msg, m_ott_q[idx].snp_req1_pkt.smi_msg_id);
        if (m_ott_q[idx].snp_req1_pkt!== null)
            $sformat(msg, "%s, SNPReq1 TargId: 0x%0h",msg, m_ott_q[idx].snp_req1_pkt.smi_targ_ncore_unit_id);
        if (m_ott_q[idx].snp_req2_pkt!== null)
            $sformat(msg, "%s, SNPReq2 MSGID: 0x%0h",msg, m_ott_q[idx].snp_req2_pkt.smi_msg_id);
        if (m_ott_q[idx].snp_rsp_pkt!== null)
            $sformat(msg, "%s, SNPRsp RMSGID: 0x%0h",msg, m_ott_q[idx].snp_rsp_pkt.smi_rmsg_id);
        if (m_ott_q[idx].snp_rsp_pkt!== null)
            $sformat(msg, "%s, SNPRsp RMSGID: 0x%0h",msg, m_ott_q[idx].snp_rsp_pkt.smi_src_ncore_unit_id);
        if (m_ott_q[idx].cmp_rsp_pkt!== null)
            $sformat(msg, "%s, CMPRsp RMSGID: 0x%0h",msg, m_ott_q[idx].cmp_rsp_pkt.smi_rmsg_id);
    $sformat(msg, "\n%s, expd_cmd_req: 0x%0h",msg, m_ott_q[idx].expd_cmd_req);
    $sformat(msg, "%s, expd_cmd_rsp: 0x%0h",msg, m_ott_q[idx].expd_cmd_rsp);
    $sformat(msg, "%s, expd_str_req: 0x%0h",msg, m_ott_q[idx].expd_str_req);
    $sformat(msg, "%s, expd_dtw_req: 0x%0h",msg, m_ott_q[idx].expd_dtw_req);
    $sformat(msg, "%s, expd_dtw_rsp: 0x%0h",msg, m_ott_q[idx].expd_dtw_rsp);
    $sformat(msg, "%s, expd_snp_req1: 0x%0h",msg, m_ott_q[idx].expd_snp_req1);
    $sformat(msg, "%s, expd_snp_req2: 0x%0h",msg, m_ott_q[idx].expd_snp_req2);
    $sformat(msg, "%s, expd_snp_rsp: 0x%0h",msg, m_ott_q[idx].expd_snp_rsp);
    $sformat(msg, "%s, expd_cmp_rsp: 0x%0h",msg, m_ott_q[idx].expd_cmp_rsp);
    $sformat(msg, "%s, expd_str_rsp: 0x%0h",msg, m_ott_q[idx].expd_str_rsp);
    $sformat(msg, "\n%s, rcvd_cmd_req: 0x%0h",msg, m_ott_q[idx].rcvd_cmd_req);
    $sformat(msg, "%s, rcvd_cmd_rsp: 0x%0h",msg, m_ott_q[idx].rcvd_cmd_rsp);
    $sformat(msg, "%s, rcvd_str_req: 0x%0h",msg, m_ott_q[idx].rcvd_str_req);
    $sformat(msg, "%s, rcvd_dtw_req: 0x%0h",msg, m_ott_q[idx].rcvd_dtw_req);
    $sformat(msg, "%s, rcvd_dtw_rsp: 0x%0h",msg, m_ott_q[idx].rcvd_dtw_rsp);
    $sformat(msg, "%s, rcvd_snp_req1: 0x%0h",msg, m_ott_q[idx].rcvd_snp_req1);
    $sformat(msg, "%s, rcvd_snp_req2: 0x%0h",msg, m_ott_q[idx].rcvd_snp_req2);
    $sformat(msg, "%s, rcvd_snp_rsp: 0x%0h",msg, m_ott_q[idx].rcvd_snp_rsp);
    $sformat(msg, "%s, rcvd_cmp_rsp: 0x%0h",msg, m_ott_q[idx].rcvd_cmp_rsp);
    $sformat(msg, "%s, rcvd_str_rsp: 0x%0h",msg, m_ott_q[idx].rcvd_str_rsp);

    `uvm_info("PRINT_ME", $psprintf("%0s",msg), UVM_NONE);
endfunction

/* Fuzzy match allowing double-bit errors: if things are equal, it will return
   true with error=0, else if they are within distance=2, it will return true
   with error=1, else it will return false. */
function bit dve_sb::fuzzy_match(bit [31:0] a, bit [31:0] b, output bit error);
    bit [31:0] diff = a ^ b;
    int distance = $countones(diff);
    error = (distance > 0);
    `uvm_info(get_name(), $psprintf("fuzzy_match: %8h %8h %0d", a, b, distance), UVM_DEBUG)
    // distance == 0 -> no error
    // distance == 1 -> double-bit error, corrected toward correct
    // distance == 2 -> double-bit error, attempted correction in (hidden) ECC bits
    // distance == 3 -> double-bit error, corrected toward incorrect
    if($test$plusargs("enable_errors")) begin
      // in the presence of address errors, the result of the read is completely
      // unknown, since it comes from some other unpredictable address in the SRAM
      return 1;
    end else begin
      return (distance == 0);
    end
endfunction: fuzzy_match

function void dve_sb::write_dve_debug_txn(dve_debug_txn csr);
    bit[7:0] srcid;
    bit[31:0] capture_timestamp;
    bit[7:0] exp_timestamp_correction = 8'h00;
    bit[7:0] act_timestamp_correction = 8'h00;
    bit[31:0] data [15:0];
    bit src_error = 1'b0;
    bit anticipate_drop_circular = 1'b0;
    smi_seq_item pkt;

    // empty -> not a valid transaction, only used for coverage
    if(csr.empty) begin
      //CONC-16723::The read_csr returned isEmpty=1 and invokes this function for coverage purpose but the pkt in trace_pkt_q was
      //falsely getting dropped in that scenario. Added an empty_write flag in dvedtwdbg_reader to only send the empty txn once.
      if(prev_empty < 2) begin
        prev_empty++;
      end else if(trace_pkt_q.size() > 0) begin
        overall_traces_dropped += trace_pkt_q.size();
        `uvm_info("<%=obj.BlockId%>_dve_sb", $psprintf("dtwdbg csr empty Dropped %0d packets from SMI queue", trace_pkt_q.size()), UVM_NONE)
        trace_pkt_q.delete();
        sb_stall_if.dropped_dtwdbgreq_packets = overall_traces_dropped;
        sb_stall_if.captured_dtwdbgreq_packets = nb_DtwDbgReq_packet - overall_traces_dropped;
      end
      `ifndef FSYS_COVER_ON
      cov.collect_dve_debug_txn(csr);
      `endif
      return;
    end

    prev_empty = 0;
    debug_txn_seen++;

    /* pull next debug request from process_dtw_req */
    if(trace_pkt_q.size() > 0) begin
        pkt = trace_pkt_q.pop_front();
    end else begin
        `uvm_error("<%=obj.BlockId%>_dve_sb", $psprintf("dtwdbg Unexpected transaction src=%2h ts=%8h data(0)=%8h read from CSRs", csr.srcid, csr.timestamp, csr.data[0]))
    end

    `uvm_info("<%=obj.BlockId%>_dve_sb", $psprintf("dtwdbg Received CSR: src=%2h ts=%8h data(0)=%8h dropping=%0b", csr.srcid, csr.timestamp, csr.data[0], csr.dropping), UVM_MEDIUM)

    //*******************************
    // Is there a drop in our future?
    //*******************************
    // linear drops will show up at some later time
    // Specifically, eventually there will be a gap in the CSR side packets,
    // and we will need to at some point discard from trace_pkt_q until we
    // catch up and resynchronize.
    if(csr.dropping && !csr.circular) begin
      // Keep track of the number of resynchronization windows ahead
      anticipate_drop_linear++;
    end
    // circular drops will show up as the current packet being overwritten
    // and our read pointer getting advanced in front of it. In this case,
    // we will need to drop from trace_pkt_q right now to catch up with
    // the CSR side.
    anticipate_drop_circular = csr.dropping && csr.circular;
    // Note that it is an error for circular drops to cause dropping later or
    // for linear drops to cause dropping now, though we may not detect it.

    // Addendum: this is a nice theory, but it turns out not to work in
    // practice, I think because the buffer fills up before we actually
    // start dropping packets in a way that's not entirely predictable.
    
    //*******************************
    // OK, now do the buffer resync
    //*******************************
    // #Check.DVE.v3.2.Loss
    begin: resync_trace_pkt_q
      int current_traces_dropped = 0;
      bit ts_error = 1'b0;
      bit data_error = 1'b0;
      smi_seq_item candidate = pkt;
      if((!fuzzy_match(csr.srcid, candidate.smi_src_ncore_unit_id, src_error) || !fuzzy_match(csr.data[0], candidate.smi_dp_data[0][31:0], ts_error) || !fuzzy_match(csr.data[1], candidate.smi_dp_data[0][63:32], data_error)) && !anticipate_drop_circular && anticipate_drop_linear > 0) begin
        anticipate_drop_linear--;
        // We may overestimate the number of upcomping linear drop windows, but we will never underestimate them.
        if(anticipate_drop_linear < 0) begin
          `uvm_error("<%=obj.BlockId%>_dve_sb", $psprintf("Unexpected drop window in linear mode."))
        end
      end
      `uvm_info("<%=obj.BlockId%>_dve_sb", $psprintf("write_dve_debug_txn Considering initial SMI src_id = 0x%0h data[0] = 0x%8h data[1] = 0x%8h, CSR src_id = 0x%0h CSR data[0] = 0x%0h data[1] = 0x%0h", candidate.smi_src_ncore_unit_id, candidate.smi_dp_data[0][31:0], candidate.smi_dp_data[0][63:32], csr.srcid, csr.data[0], csr.data[1]), UVM_LOW)
      while((!fuzzy_match(csr.srcid, candidate.smi_src_ncore_unit_id, src_error)) || (!fuzzy_match(csr.data[0], candidate.smi_dp_data[0][31:0], ts_error)) || !fuzzy_match(csr.data[1], candidate.smi_dp_data[0][63:32], data_error)) begin
        if(trace_pkt_q.size() > 0) begin
          candidate = trace_pkt_q.pop_front();
          current_traces_dropped++;
          `uvm_info("<%=obj.BlockId%>_dve_sb", $psprintf("write_dve_debug_txn Considering SMI%0d src_id = 0x%2h data[0] = 0x%8h data[1] = 0x%8h, CSR src_id = 0x%0h CSR data[0] = 0x%0h data[1] = 0x%0h", current_traces_dropped, candidate.smi_src_ncore_unit_id, candidate.smi_dp_data[0][31:0], candidate.smi_dp_data[0][63:32], csr.srcid, csr.data[0], csr.data[1]), UVM_LOW)
        end else begin
          `uvm_error("<%=obj.BlockId%>_dve_sb", $psprintf("Ran out of DtwDbgReqs while resyncing read from CSRs circular=%b current_traces_dropped=%0d", csr.circular, current_traces_dropped))
        end
      end 
      overall_traces_dropped += current_traces_dropped;
      pkt = candidate;
      `uvm_info(get_name(), $sformatf("dtwdbg current_traces_dropped: %0d, overall_traces_dropped: %0d", current_traces_dropped, overall_traces_dropped), UVM_MEDIUM)
      // The response side too
      //`uvm_info("<%=obj.BlockId%>_dve_sb", $psprintf("Dropped %0d traces", current_traces_dropped), UVM_DEBUG)
      for(int i = 0; i < current_traces_dropped; i++) begin
        //`uvm_info("<%=obj.BlockId%>_dve_sb", $psprintf("Dropping ts_corr %2h", trace_ts_corr_q[0]), UVM_DEBUG)
        trace_ts_corr_q.delete(0);
      end
    end: resync_trace_pkt_q

    // #Check.DVE.v3.2.Integrity
    //*******************************
    // Header checking
    //*******************************
    if(!fuzzy_match(csr.srcid, pkt.smi_src_ncore_unit_id, src_error)) begin
        `uvm_error("<%=obj.BlockId%>_dve_sb:write_dve_debug_txn",
          $psprintf("Debug Funit ID mismatch: csr = %2h smi = %2h", csr.srcid, pkt.smi_src_ncore_unit_id))
    end
    if(src_error) begin
      // do nothing: because some errors are silent, this number doesn't match anything else
      // seen_double_errors++;
    end

    //*******************************
    // Data checking
    //*******************************
    // Check data against CSR readout
    begin: data_checking
      bit was_error = 1'b0;
      for(int i = 0; i<16; i++) begin
        // i indexes 32-bit chunks, and this math assumes wSmiDPdata will be >= 32
        bit [31:0] smi_data = pkt.smi_dp_data[i/(wSmiDPdata/32)][i%(wSmiDPdata/32)*32+:32];
        bit data_error = 1'b0;
        if(!fuzzy_match(csr.data[i], smi_data, data_error)) begin
          `uvm_error("<%=obj.BlockId%>_dve_sb:write_dve_debug_txn",
            $psprintf("dtwdbg: Debug data mismatch: csr(%0d) = %8h smi(%0d) = %8h data_error=%0b", i, csr.data[i], i, smi_data, data_error))
        end
        if(data_error && (!was_error || !i[0])) begin
          // data errors are injected on 64-bit words but here we have 32-bit ones
          // This means they can be spread across two adjacent data words here, but
          // we are only allowed to count them once.
          // do nothing: because some errors are silent, this number doesn't match anything else
          // seen_double_errors++;
          `uvm_info("<%=obj.BlockId%>_dve_sb:write_dve_debug_txn",
            $psprintf("error seen %0d -> %0d data=%8h %8h", injected_double_errors, seen_double_errors, csr.data[i|4'h1], csr.data[i&4'he]), UVM_DEBUG)
          was_error = 1'b1;
        end else begin
          was_error = 1'b0;
        end
      end
    end: data_checking

    //*******************************
    // Timestamp checking
    //*******************************
    // #Check.DVE.v3.2.TSRoll
    // extract capture unit's idea of time from the data
    capture_timestamp = csr.data[0];
    // determine timestamp correction
    if(capture_timestamp[31:4] <= csr.timestamp[31:4]) begin
      // a correction is required
      exp_timestamp_correction[7] = 1'b1;
    end
    if(capture_timestamp[31:4] != csr.timestamp[31:4]) begin
      int difference = csr.timestamp - capture_timestamp;
      int ndifference = capture_timestamp - csr.timestamp;
      bit saturate = |difference[31:11];
      bit nsaturate = |ndifference[31:11];
      bit [6:0] cor = saturate ? 7'h7f : difference[10:4];
      bit [6:0] ncor = nsaturate ? 7'h7f : ndifference[10:4];
      `uvm_info("<%=obj.BlockId%>_dve_sb:write_dve_debug_txn", $psprintf("saturate=%0b difference=%0h nsaturate=%0b ndifference=%0h select=%0h>%0h=%0b", saturate, difference, nsaturate, ndifference, csr.timestamp, capture_timestamp, csr.timestamp > capture_timestamp), UVM_DEBUG)
      //bit [31:0] difference = capture_timestamp - csr.timestamp;
      // this subtraction is saturating
      exp_timestamp_correction[6:0] = (csr.timestamp > capture_timestamp) ? cor : ncor;
      //exp_timestamp_correction[6:0] = csr.timestamp[10:4];
    end
    // get the actual correction from process_dtw_rsp
    // TODO: can we guarantee this will have happened yet (e.g. due to DTW_rsp losing smi arbitration)
    if(trace_ts_corr_q.size > 0) begin: have_actual_correction
      act_timestamp_correction = trace_ts_corr_q.pop_front();
      if(exp_timestamp_correction != act_timestamp_correction) begin
          if($test$plusargs("enable_errors")) begin
            // the readout of the FRC value can be corrupt: this is uncorrectable, so we can't have
            // a terminating error if this miscompares, if data corruption could be present
            `uvm_warning("<%=obj.BlockId%>_dve_sb:write_dve_debug_txn",
              $psprintf("Debug timestamp correction mismatch: updating %0h 0x%0h -> 0x%0h csr = %2h smi = %2h",
              csr.srcid, capture_timestamp, csr.timestamp, exp_timestamp_correction, act_timestamp_correction))
          end else begin
            `uvm_error("<%=obj.BlockId%>_dve_sb:write_dve_debug_txn",
              $psprintf("Debug timestamp correction mismatch: updating %0h 0x%0h -> 0x%0h csr = %2h smi = %2h",
              csr.srcid, capture_timestamp, csr.timestamp, exp_timestamp_correction, act_timestamp_correction))
          end
      end else begin
          // this is UVM_NONE so we can see it in diagnostic runs for Khaleel more easily -- Andrew
          `uvm_info("<%=obj.BlockId%>_dve_sb:write_dve_debug_txn",
            $psprintf("TS: updating TCAP %0h %0d -> TACC %0d csr = %2h smi = %2h", csr.srcid,
            capture_timestamp, csr.timestamp, exp_timestamp_correction, act_timestamp_correction), UVM_NONE)
      end
      csr.correction = act_timestamp_correction;
      `ifndef FSYS_COVER_ON
      cov.collect_dve_debug_txn(csr);
      `endif
    end: have_actual_correction
    else begin: ts_corr_not_present
      `uvm_warning("<%=obj.BlockId%>_dve_sb:write_dve_debug_txn", "Debug timestamp not yet present")
      trace_ts_corr_late_q.push_back(exp_timestamp_correction);
    end: ts_corr_not_present

    //****************************************
    // Collect data for later perfmon checking
    //****************************************
    circular = csr.circular;
    sb_stall_if.dropped_dtwdbgreq_packets = overall_traces_dropped;
    sb_stall_if.captured_dtwdbgreq_packets = nb_DtwDbgReq_packet - overall_traces_dropped;

endfunction: write_dve_debug_txn

function void dve_sb::print_ott_info();
    string msg;
    int    find_q[$];

    foreach(m_ott_q[idx]) begin
        find_q.delete();
    $sformat(msg, "\nDVE_UID:%0d %0s",
                        m_ott_q[idx].txn_id,
                        (m_ott_q[idx].cmd_req_pkt != null) ? m_ott_q[idx].cmd_req_pkt.convert2string() : "CMDReq not found in entry");
        if (m_ott_q[idx].cmd_req_pkt!== null)
            $sformat(msg, "\n%s, CMDReq MSGID: 0x%0h",msg, m_ott_q[idx].cmd_req_pkt.smi_msg_id);
        if (m_ott_q[idx].str_req_pkt!== null)
            $sformat(msg, "%s, STRReq MSGID: 0x%0h",msg, m_ott_q[idx].str_req_pkt.smi_msg_id);
        if (m_ott_q[idx].dtw_req_pkt!== null)
            $sformat(msg, "%s, DTWReq MSGID: 0x%0h",msg, m_ott_q[idx].dtw_req_pkt.smi_msg_id);
        if (m_ott_q[idx].snp_req1_pkt!== null)
            $sformat(msg, "%s, SNPReq1 MSGID: 0x%0h",msg, m_ott_q[idx].snp_req1_pkt.smi_msg_id);
        if (m_ott_q[idx].snp_req2_pkt!== null)
            $sformat(msg, "%s, SNPReq2 MSGID: 0x%0h",msg, m_ott_q[idx].snp_req2_pkt.smi_msg_id);
        if (m_ott_q[idx].cmp_rsp_pkt!== null)
            $sformat(msg, "%s, CMPRsp RMSGID: 0x%0h",msg, m_ott_q[idx].cmp_rsp_pkt.smi_rmsg_id);
    $sformat(msg, "\n%s, expd_cmd_req: 0x%0h",msg, m_ott_q[idx].expd_cmd_req);
    $sformat(msg, "%s, expd_cmd_rsp: 0x%0h",msg, m_ott_q[idx].expd_cmd_rsp);
    $sformat(msg, "%s, expd_str_req: 0x%0h",msg, m_ott_q[idx].expd_str_req);
    $sformat(msg, "%s, expd_dtw_req: 0x%0h",msg, m_ott_q[idx].expd_dtw_req);
    $sformat(msg, "%s, expd_snp_req1: 0x%0h",msg, m_ott_q[idx].expd_snp_req1);
    $sformat(msg, "%s, expd_snp_req2: 0x%0h",msg, m_ott_q[idx].expd_snp_req2);
    $sformat(msg, "%s, expd_snp_rsp: 0x%0h",msg, m_ott_q[idx].expd_snp_rsp);
    $sformat(msg, "%s, expd_cmp_rsp: 0x%0h",msg, m_ott_q[idx].expd_cmp_rsp);
    $sformat(msg, "%s, expd_str_rsp: 0x%0h",msg, m_ott_q[idx].expd_str_rsp);
    $sformat(msg, "\n%s, rcvd_cmd_req: 0x%0h",msg, m_ott_q[idx].rcvd_cmd_req);
    $sformat(msg, "%s, rcvd_cmd_rsp: 0x%0h",msg, m_ott_q[idx].rcvd_cmd_rsp);
    $sformat(msg, "%s, rcvd_str_req: 0x%0h",msg, m_ott_q[idx].rcvd_str_req);
    $sformat(msg, "%s, rcvd_dtw_req: 0x%0h",msg, m_ott_q[idx].rcvd_dtw_req);
    $sformat(msg, "%s, rcvd_dtw_rsp: 0x%0h",msg, m_ott_q[idx].rcvd_dtw_rsp);
    $sformat(msg, "%s, rcvd_snp_req1: 0x%0h",msg, m_ott_q[idx].rcvd_snp_req1);
    $sformat(msg, "%s, rcvd_snp_req2: 0x%0h",msg, m_ott_q[idx].rcvd_snp_req2);
    $sformat(msg, "%s, rcvd_snp_rsp: 0x%0h",msg, m_ott_q[idx].rcvd_snp_rsp);
    $sformat(msg, "%s, rcvd_cmp_rsp: 0x%0h",msg, m_ott_q[idx].rcvd_cmp_rsp);
    $sformat(msg, "%s, rcvd_str_rsp: 0x%0h",msg, m_ott_q[idx].rcvd_str_rsp);
    `uvm_info("PRINT_OTT", $psprintf("%0s",msg), UVM_NONE);
        if (find_q.size() == 1)
            print_me(find_q[0]);
    end
endfunction : print_ott_info

//function : Print Latency data for commands
function void dve_sb::print_latency_data();

  //Printing CMDReq to STRReq command min,max and average latency.  
  strreq_min_latency = latency_collection_strreq_q.min;
  strreq_max_latency = latency_collection_strreq_q.max;
  foreach(latency_collection_strreq_q[i]) begin
    strreq_latency_sum = strreq_latency_sum + latency_collection_strreq_q[i];
  end  
  strreq_avg_latency = strreq_latency_sum/latency_collection_strreq_q.size();
  `uvm_info("DVE_SB", $psprintf("CMDReq -> STRReq: Num of commands %0d, Latency Min : %0d, Max : %0d, Average : %0d", latency_collection_strreq_q.size(),strreq_min_latency[0],strreq_max_latency[0],strreq_avg_latency), UVM_MEDIUM)

  //Printing DTWReq to SNPReq command min,max and average latency.  
  snpreq_min_latency = latency_collection_snpreq_q.min;
  snpreq_max_latency = latency_collection_snpreq_q.max;
  foreach(latency_collection_snpreq_q[i]) begin
    snpreq_latency_sum = snpreq_latency_sum + latency_collection_snpreq_q[i];
  end  
  snpreq_avg_latency = snpreq_latency_sum/latency_collection_snpreq_q.size();
  `uvm_info("DVE_SB", $psprintf("DTWReq -> SNPReq: Num of commands %0d, Latency Min : %0d, Max : %0d, Average : %0d",latency_collection_snpreq_q.size(),snpreq_min_latency[0],snpreq_max_latency[0],snpreq_avg_latency), UVM_MEDIUM)

  //Printing SNPRsp to CMPRsp command min,max and average latency.  
  cmprsp_min_latency = latency_collection_cmprsp_q.min;
  cmprsp_max_latency = latency_collection_cmprsp_q.max;
  foreach(latency_collection_cmprsp_q[i]) begin
    cmprsp_latency_sum = cmprsp_latency_sum + latency_collection_cmprsp_q[i];
  end  
  cmprsp_avg_latency = cmprsp_latency_sum/latency_collection_cmprsp_q.size();
  `uvm_info("DVE_SB", $psprintf("SNPRsp -> CMPRsp: Num of commands %0d, Latency Min : %0d, Max : %0d, Average : %0d",latency_collection_cmprsp_q.size(),cmprsp_min_latency[0],cmprsp_max_latency[0],cmprsp_avg_latency), UVM_MEDIUM)

endfunction : print_latency_data

////////////////////////////////////////////////////////////////////////////////

task dve_sb::run_phase(uvm_phase phase);
  uvm_objection objection;
  <% if ((obj.useResiliency) && (obj.testBench != "fsys" && obj.testBench != "cust_tb")) { %>
    bit test_unit_duplication_uecc;
  <% } %>
   // perf minitor:Bound stall_if Interface
  if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_m_top_stall_if", sb_stall_if)) 
  begin
    `uvm_fatal("Ioaiu_scoreboard stall interface error", "virtual interface must be set for stall_if");
  end
  super.main_phase(phase);
  objection = phase.get_objection();
<% if ((obj.useResiliency) && (obj.testBench != "fsys" && obj.testBench != "cust_tb")) { %>
   if(!uvm_config_db#(virtual dve_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif)) begin
       `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
   end
<% } %>

  fork
    begin
      forever begin
        @(e_cmd_req);
        cmd_objection_cnt++;
        `uvm_info(get_type_name(),$psprintf("Received CMDreq, raise objection in DVE scoreboard.  cmd_objection_cnt=%0d", cmd_objection_cnt),UVM_LOW)
        phase.raise_objection(this, "Received CMDreq, raise objection in DVE scoreboard");
      end
    end

    begin
      forever begin
        @(e_str_rsp);
        cmd_objection_cnt--;
        `uvm_info(get_type_name(),$psprintf("Received STRrsp, drop objection in DVE scoreboard.  cmd_objection_cnt=%0d", cmd_objection_cnt),UVM_LOW)
        phase.drop_objection(this, "Received STRrsp, drop objection in DVE scoreboard");
      end
    end
      // BEGIN PERF MONITOR
      begin
       forever begin:updateskidstt
          @(evt_stt);
          if (real_stt_size < max_stt) begin
                real_stt_size++;
                sb_stall_if.perf_count_events["Active_STT_entries"].push_back(real_stt_size);
          end else begin
                stt_skid_size++;
          end
       end:updateskidstt
      end
      begin
       forever begin:updatestt
          @(evt_del_stt);
           if (real_stt_size) begin
             real_stt_size--;
             sb_stall_if.perf_count_events["Active_STT_entries"].push_back(real_stt_size);
           end 
           if (stt_skid_size) begin
                stt_skid_size--;
                real_stt_size++;
                sb_stall_if.perf_count_events["Active_STT_entries"].push_back(real_stt_size);
           end
       end:updatestt
      end

    begin
      forever log_tacc_double_error();
    end

    begin
      forever log_tacc_single_error();
    end

    begin
      forever log_tacc_addr_error();
    end

    begin
      forever rtl_tacc_double_error();
    end

    begin
      forever rtl_tacc_single_error();
    end

    begin
      forever rtl_tacc_addr_error();
    end

    begin
      forever rtl_trace_captured();
    end

    begin
      forever rtl_trace_dropped();
    end

    begin: check_ral_process
       #900ns;
        my_register = m_regs.get_reg_by_name("DVECELR0"); 

        mirrored_value = my_register.get_mirrored_value(); 

        `uvm_info("SB", $sformatf("Mirrored value of DVECELR0 in scoreboard :%0h", mirrored_value), UVM_LOW) 
    end
  join_none
  `uvm_info($sformatf("%m"), $sformatf("useRsiliency=%0d, testBenchName=%s", <%=obj.useResiliency%>, "<%=obj.testBench%>"), UVM_NONE)

  <% if ((obj.useResiliency) && (obj.testBench != "fsys" && obj.testBench != "cust_tb")) { %>
     if ($test$plusargs("expect_mission_fault")) begin
       fork
         if(!$test$plusargs("test_unit_duplication")) begin
           begin
             forever begin
                #(100*1ns);
                if (u_csr_probe_vif.fault_mission_fault == 0) begin
                   @u_csr_probe_vif.fault_mission_fault;
                end
                #(500*1ns);  // make sure enough time elapsed so we can ensure the errored request is dropped
                `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                -> kill_test;   // otherwise the test will hang and timeout
                `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
                phase.jump(uvm_report_phase::get());
             end
           end
         end else begin
           begin
             forever begin
               #(100*1ns);
               uvm_config_db#(bit)::wait_modified(this, "", "test_unit_duplication_uecc");
               `uvm_info(get_name(), "modified value of test_unit_duplication_uecc", UVM_LOW)
               uvm_config_db#(bit)::get(this, "", "test_unit_duplication_uecc", test_unit_duplication_uecc);
               if(test_unit_duplication_uecc) begin
                 if(u_csr_probe_vif.fault_mission_fault == 0) begin
                    @u_csr_probe_vif.fault_mission_fault;
                 end
                 #(500*1ns);  // make sure enough time elapsed so we can ensure the errored request is dropped
                 `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                 -> kill_test;   // otherwise the test will hang and timeout
                 `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
                 phase.jump(uvm_report_phase::get());
               end
             end
           end
         end

       join_none
     end
  <% } %>
endtask // run_phase

////////////////////////////////////////////////////////////////////////////////

function void dve_sb::report_phase(uvm_phase phase);
  super.report_phase(phase);

    `ifndef FSYS_COVER_ON
    cov.collect_dve_dvmOps_type(dvm_sync,dvm_no_sync);
    `endif
    //Printing latency statistics
    print_latency_data();

    <% if ((obj.useResiliency) && (obj.testBench != "fsys" && obj.testBench != "cust_tb")) { %>
       if($test$plusargs("expect_mission_fault")) begin
         if (u_csr_probe_vif.fault_mission_fault == 0) begin
           `uvm_error({"fault_injector_checker_",get_name()}
             , $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}
               , u_csr_probe_vif.fault_mission_fault))
         end else begin
           `uvm_info(get_name()
             , $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}
               , u_csr_probe_vif.fault_mission_fault)
             , UVM_LOW)
         end
       end
    <% } %>
endfunction: report_phase

function void dve_sb::check_phase(uvm_phase phase);
  super.check_phase(phase);
  if(m_ott_q.size() == 0) begin
      `uvm_info(get_type_name(),$psprintf("check_phase: Transaction queue is empty"),UVM_NONE)
  end
  else begin
      `uvm_error(get_type_name(),$psprintf("check_phase: %0d transaction are still in queue",m_ott_q.size()))
  end
  if(m_sys_q.size() == 0) begin
      `uvm_info(get_type_name(),$psprintf("check_phase: SysReq queue is empty"),UVM_NONE)
  end
  else begin
      `uvm_error(get_type_name(),$psprintf("check_phase: %0d SysReq are still in queue",m_sys_q.size()))
  end
  /* In a trace loss scenario, we can't guarantee this will empty */
  if(trace_pkt_q.size() == 0) begin
      `uvm_info(get_type_name(),$psprintf("check_phase: DtwDbgTxn queue is empty"),UVM_NONE)
  end
  else begin
      `uvm_info(get_type_name(),$psprintf("check_phase: %0d DtwDbgTxn are still in queue",trace_pkt_q.size()), UVM_NONE)
      overall_traces_dropped += trace_pkt_q.size();
  end
  `uvm_info(get_name(), $psprintf("TACC_STATUS --- Number of DTWDbgReq seen on SMI ------> %0d",dtw_dbg_req_seen), UVM_NONE)
  `uvm_info(get_name(), $psprintf("TACC_STATUS --- Number of DTWDbgReq read on CSR ------> %0d",debug_txn_seen), UVM_NONE)
  `uvm_info(get_name(), $psprintf("TACC_STATUS --- Number of DTWDbgReq reported accepted ------> %0d",debug_txn_seen_rtl), UVM_NONE)
  `uvm_info(get_name(), $psprintf("TACC_STATUS --- Number of DTWDbgReq calculated dropped ---> %0d",overall_traces_dropped), UVM_NONE)
  `uvm_info(get_name(), $psprintf("TACC_STATUS --- Number of DTWDbgReq reported dropped ---> %0d",overall_traces_dropped_rtl), UVM_NONE)
  if(debug_txn_seen + overall_traces_dropped != dtw_dbg_req_seen) begin
    `uvm_error(get_name(), "DV inconsistency: seen + dropped != total");
  end
  if(circular && dtw_dbg_req_seen != debug_txn_seen_rtl) begin
    `uvm_error(get_name(), "RTL/DV mismatch in packets seen (circular)");
  end
  if(!circular && debug_txn_seen != debug_txn_seen_rtl) begin
    `uvm_error(get_name(), "RTL/DV mismatch in packets seen (linear)");
  end
<% if (obj.testBench != "fsys" && obj.testBench != "cust_tb") { // disable this check pending CONC-8005 resolution. This fixes CONC-8357. %>
  if(overall_traces_dropped != overall_traces_dropped_rtl) begin
    `uvm_error(get_name(), "RTL/DV mismatch in packets dropped");
  end
<% } %>
  `uvm_info(get_name(), $psprintf("injected_single_errors=%0d seen_single_errors=%0d", injected_single_errors, seen_single_errors), UVM_DEBUG)
  `uvm_info(get_name(), $psprintf("injected_double_errors=%0d seen_double_errors=%0d", injected_double_errors, seen_double_errors), UVM_DEBUG)
  `uvm_info(get_name(), $psprintf("injected_addr_errors=%0d seen_addr_errors=%0d", injected_addr_errors, seen_addr_errors), UVM_DEBUG)
  if(injected_double_errors + injected_addr_errors != seen_double_errors && (injected_double_errors + injected_addr_errors != (seen_double_errors+1))) begin
    // we can inject at most one error after the last successful readout of a data packet
    `uvm_error(get_name(), $psprintf("injected_double_errors=%0d != seen_double_errors=%0d", injected_double_errors, seen_double_errors))
  end
  if(injected_single_errors != seen_single_errors && (injected_single_errors != (seen_single_errors+1))) begin
    // we can inject at most one error after the last successful readout of a data packet
    `uvm_warning(get_name(), $psprintf("injected_single_errors=%0d != seen_single_errors=%0d", injected_single_errors, seen_single_errors))
  end
endfunction : check_phase

function void dve_sb::update_resiliency_ce_cnt(const ref smi_seq_item m_item);
<%  if ((obj.useResiliency) && (obj.testBench != "fsys" && obj.testBench != "cust_tb")) { %>
  int tmp_dp_corr_error;
  string func_s = "update_resiliency_ce_cnt";

  `uvm_info({func_s}, $sformatf("time1 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  res_smi_pkt_time_new = $realtime;
  if(res_smi_pkt_time_new != res_smi_pkt_time_old) begin
    // get error statistics
    if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
      res_smi_corr_err++;
      if(m_item.dp_corr_error_eb) begin
        res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
        res_mod_dp_corr_error = m_item.dp_corr_error_eb;
        `uvm_info({func_s}, $sformatf("(if/if)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
      end
      res_is_pre_err_pkt = 1'b1;
      `uvm_info({func_s}, $sformatf("new smi_pkt(if). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end else begin
      res_is_pre_err_pkt = 1'b0;
    end
    `uvm_info({func_s}, $sformatf("time2 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  end else begin
    if(res_is_pre_err_pkt) begin
      if(m_item.dp_corr_error_eb) begin
        tmp_dp_corr_error = m_item.dp_corr_error_eb - this.res_mod_dp_corr_error;
        if(tmp_dp_corr_error < 0)
          tmp_dp_corr_error = 1'b0;
        else
          this.res_mod_dp_corr_error = this.res_mod_dp_corr_error + tmp_dp_corr_error;
        `uvm_info({func_s}, $sformatf("(else/if)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
        res_smi_corr_err = res_smi_corr_err + tmp_dp_corr_error;
      end
      `uvm_info({func_s}, $sformatf("new smi_pkt(else/if). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end else begin
      if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
        res_smi_corr_err++;
        if(m_item.dp_corr_error_eb) begin
          res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
          res_mod_dp_corr_error = m_item.dp_corr_error_eb;
          `uvm_info({func_s}, $sformatf("(else/else)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
        end
        res_is_pre_err_pkt = 1'b1;
      end
      `uvm_info({func_s}, $sformatf("new smi_pkt(else/else). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end
    `uvm_info({func_s}, $sformatf("time3 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  end
  res_smi_pkt_time_old = res_smi_pkt_time_new;
  `uvm_info({func_s}, $sformatf("time4 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
<% } %>
endfunction : update_resiliency_ce_cnt

function int dve_sb::funitid2nunitid(int fUnitId);
   int nunitid = -1;

   foreach(SnoopEn_FUNIT_IDS[i]) begin
      if(SnoopEn_FUNIT_IDS[i] == fUnitId) begin
	 nunitid = SnoopEn_NUNIT_IDS[i];
	 break;
      end
   end
   return nunitid;
endfunction : funitid2nunitid

function int dve_sb::is_dvm_sync(const ref smi_seq_item m_item);
   if(m_item.smi_addr[13:11] == 3'b100)
     return 1;
   else
     return 0;
   
endfunction : is_dvm_sync

task dve_sb::log_tacc_double_error();
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event inject_double = ev_pool.get("dve_trace_mem_log_double_error");
  inject_double.wait_trigger();
  injected_double_errors++;
  inject_double.reset();
endtask: log_tacc_double_error

task dve_sb::log_tacc_single_error();
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event inject_single = ev_pool.get("dve_trace_mem_log_single_error");
  inject_single.wait_trigger();
  injected_single_errors++;
  inject_single.reset();
endtask: log_tacc_single_error

task dve_sb::log_tacc_addr_error();
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event inject_addr = ev_pool.get("dve_trace_mem_log_addr_error");
  inject_addr.wait_trigger();
  injected_addr_errors++;
  inject_addr.reset();
endtask: log_tacc_addr_error

task dve_sb::rtl_tacc_double_error();
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event seen_double = ev_pool.get("dve_trace_mem_rtl_saw_double_error");
  seen_double.wait_trigger();
  seen_double_errors++;
  `ifndef FSYS_COVER_ON
  cov.collect_dve_ecc(1'b0, 1'b1);
  `endif
  seen_double.reset();
endtask: rtl_tacc_double_error

task dve_sb::rtl_tacc_single_error();
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event seen_single = ev_pool.get("dve_trace_mem_rtl_saw_single_error");
  seen_single.wait_trigger();
  seen_single_errors++;
  `ifndef FSYS_COVER_ON
  cov.collect_dve_ecc(1'b1, 1'b0);
  `endif
  seen_single.reset();
endtask: rtl_tacc_single_error

task dve_sb::rtl_tacc_addr_error();
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event seen_addr = ev_pool.get("dve_trace_mem_rtl_saw_addr_error");
  seen_addr.wait_trigger();
  seen_addr_errors++;
  `ifndef FSYS_COVER_ON
  cov.collect_dve_ecc(1'b1, 1'b0);
  `endif
  seen_addr.reset();
endtask: rtl_tacc_addr_error

task dve_sb::rtl_trace_captured();
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event rtl_captured = ev_pool.get("dve_trace_captured");
  rtl_captured.wait_trigger();
  debug_txn_seen_rtl++;
  rtl_captured.reset();
endtask: rtl_trace_captured

task dve_sb::rtl_trace_dropped();
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event rtl_dropped = ev_pool.get("dve_trace_dropped");
  rtl_dropped.wait_trigger();
  overall_traces_dropped_rtl++;
  rtl_dropped.reset();
endtask: rtl_trace_dropped
