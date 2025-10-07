<% obj.Dvm_aiuInfo = [] ;
obj.Dvm_NUnitIds = [] ;
for (i in obj.AiuInfo) {
    if(obj.AiuInfo[i].cmpInfo.nDvmSnpInFlight > 0) {
        obj.Dvm_aiuInfo.push(obj.AiuInfo[i]);
        obj.Dvm_NUnitIds.push(obj.AiuInfo[i].nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}
var dvm_agent = obj.Dvm_aiuInfo.length
var trace_agents = [];
for (i in obj.AiuInfo) {
   trace_agents.push(obj.AiuInfo[i].FUnitId);
}
for (i in obj.DmiInfo) {
   trace_agents.push(obj.DmiInfo[i].FUnitId);
}
for (i in obj.DiiInfo) {
   trace_agents.push(obj.DiiInfo[i].FUnitId);
}
%>


import common_knob_pkg::*;

class dve_targt_id_err_seq extends uvm_sequence#(smi_seq_item);
  `uvm_object_utils(dve_targt_id_err_seq)

  dve_cntr m_ott_q[$];
  dve_cntr m_snp_rsp_q[$];
  dve_cntr m_dtw_dbg_q[$];
  dve_cntr m_sys_q[$];
//  dve_unit_args m_dve_unit_args;
  // dve_credit_pool credit_pool;

  smi_sequencer m_smi_seqr_tx_hash[string];
  smi_sequencer m_smi_seqr_rx_hash[string];
  smi_virtual_sequencer m_smi_virtual_seqr;
  // Randomize
  rand int r_agent_id;
  rand smi_seq_item r_cmd_req;

  int SnoopEn_FUNIT_IDS[$] = '{<%for(var unit=0; unit<obj.Dvm_FUnitIds.length; unit++) {%><%=obj.Dvm_FUnitIds[unit]%> <%if(unit < (obj.Dvm_FUnitIds.length-1)) {%>,<%} }%>};
  int SnoopEn_NUNIT_IDS[$] = '{<%for(var unit=0; unit<obj.Dvm_NUnitIds.length; unit++) {%><%=obj.Dvm_NUnitIds[unit]%> <%if(unit < (obj.Dvm_NUnitIds.length-1)) {%>,<%} }%>};
  int nDvmSnpAgents = <%=dvm_agent%>;//4;
  int cmd_type_weight = 0;
  bit           m_unq_id_array[int][smi_msg_id_t];
 <% if(obj.testBench == 'dve') { %>
 `ifndef VCS
  event         e_smi_unq_id_freeup[int];
 `else // `ifndef VCS
  static  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event         e_smi_unq_id_freeup[int];
 `endif // `ifndef VCS ... `else ...
 <% } else {%>
  event         e_smi_unq_id_freeup[int];
 <% } %>
  // rand eMsgCMD r_msg_type;
  rand bit [2:0] DvmOpType ; //3'b100 = Sync
  int       txn_cnt = 0;

  bit [127:0] SysCoAttach_agents;

int nTraceAgents = <%=trace_agents.length%>;
int TraceAgents[<%=trace_agents.length%>] = '{0<% for(var a=1;a<trace_agents.length;a++) { %>,<%=trace_agents[a]%><%}%>};


  // Constraints

  // Counts
  int cmd_credits[int];
  int cmd_req_cnt;
  int smi_rsp_cnt;
  int cmd_rsp_cnt;
  int str_req_cnt;
  int snp_rsp_cnt;
  int snp_req_cnt;
  int str_rsp_cnt;
  int cmp_rsp_cnt;
  int dtw_req_cnt;
  int sys_req_cnt;
  int sys_rsp_cnt;
  int num_active_dvm_cmds[int];
  bit [127:0] attaching_agents;
  bit [127:0] detaching_agents;

  bit delay_cmd_req;
  bit delay_dtw_req;
  bit delay_str_rsp;
  bit delay_snp_rsp;
  bit delay_dtw_dbg_req;

  int delay_cmd_req_value = 1;
  int delay_dtw_req_value = 1;
  int delay_str_rsp_value = 1;
  int delay_snp_rsp_value = 1;

  bit dis_delay_cmd_req = 0;
  bit dis_delay_dtw_req = 0;
  bit dis_delay_str_rsp = 0;
  bit dis_delay_snp_rsp = 0;

  // Events
  event e_cmd_rsp;
  event e_dtw_req;
  event e_str_rsp;
  event e_snp_rsp;
  event e_sys_req_por_done;

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
  smi_seq_item m_sys_req_pkt;
  smi_seq_item m_sys_rsp_pkt;
  smi_seq_item m_dtw_dbg_req_pkt;

  const int             m_weights_for_k_num_requests[3]   = {10, 85, 5};
<% if(obj.testBench == 'dve') { %>
`ifndef VCS
  const t_minmax_range  m_minmax_for_k_num_requests[3]    = {{100, 200}, {1000, 2000}, {10000,20000}};
`else // `ifndef VCS
  const t_minmax_range  m_minmax_for_k_num_requests[3]    ='{'{m_min_range:100,m_max_range:200}, '{m_min_range:1000,m_max_range:2000}, '{m_min_range:10000,m_max_range:20000}};
`endif // `ifndef VCS ... `else ... 
<% } else {%>
  const t_minmax_range  m_minmax_for_k_num_requests[3]    = {{100, 200}, {1000, 2000}, {10000,20000}};
<% } %>
  const int             m_weights_for_k_cm_status_err_wgt[2]   = {95, 5};
<% if(obj.testBench == 'dve') { %>
`ifndef VCS
  const t_minmax_range  m_minmax_for_k_cm_status_err_wgt[2]    = {{0, 10}, {91, 100}};
`else // `ifndef VCS
  const t_minmax_range  m_minmax_for_k_cm_status_err_wgt[2]    ='{'{m_min_range:0,m_max_range:10}, '{m_min_range:91,m_max_range:100}};
`endif // `ifndef VCS ... `else ... 
<% } else {%>
  const t_minmax_range  m_minmax_for_k_cm_status_err_wgt[2]    = {{0, 10}, {91, 100}};
<% } %>
  //Total number of requests  
  common_knob_class k_num_requests = new ("k_num_requests", this, m_weights_for_k_num_requests, m_minmax_for_k_num_requests);
  common_knob_class k_cmd_cm_status_err_wgt = new ("k_cmd_cm_status_err_wgt", this, m_weights_for_k_cm_status_err_wgt, m_minmax_for_k_cm_status_err_wgt);
  common_knob_class k_dtw_cm_status_err_wgt = new ("k_dtw_cm_status_err_wgt", this, m_weights_for_k_cm_status_err_wgt, m_minmax_for_k_cm_status_err_wgt);
  common_knob_class k_dtw_dbad_err_wgt = new ("k_dtw_dbad_err_wgt", this, m_weights_for_k_cm_status_err_wgt, m_minmax_for_k_cm_status_err_wgt);
  common_knob_class k_snp_rsp_err_wgt = new ("k_snp_rsp_err_wgt", this, m_weights_for_k_cm_status_err_wgt, m_minmax_for_k_cm_status_err_wgt);
  common_knob_class k_str_rsp_err_wgt = new ("k_str_rsp_err_wgt", this, m_weights_for_k_cm_status_err_wgt, m_minmax_for_k_cm_status_err_wgt);

  bit enable_error = 0;
  bit is_por_done = 0;
  bit pending_sys_req = 0;
  static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  static uvm_event ev = ev_pool.get("ev");
  static uvm_event ev_addr = ev_pool.get("ev_addr");


  // Functions
  function new(string name = "dve_targt_id_err_seq");
    super.new(name);

    <% for(idx=0; idx<obj.nAIUs; idx++) { %>
    cmd_credits[<%=obj.AiuInfo[idx].FUnitId%>] = <%=obj.AiuInfo[idx].cmpInfo.nDvmMsgInFlight%>;
    <% } %>
    cmd_req_cnt = 0;
    smi_rsp_cnt = 0;
    cmd_rsp_cnt = 0;
    str_req_cnt = 0;
    snp_rsp_cnt = 0;
    snp_req_cnt = 0;
    str_rsp_cnt = 0;
    cmp_rsp_cnt = 0;
    dtw_req_cnt = 0;
    sys_req_cnt = 0;
    sys_rsp_cnt = 0;
    // credit_pool = credit_pool::GetInstance();

    attaching_agents = 0;
    detaching_agents = 0;
    if($test$plusargs("sysco_enable")) begin
       SysCoAttach_agents = 0;
    end else begin
      foreach(DVM_AIU_FUNIT_IDS[j]) begin
         SysCoAttach_agents[funitid2nunitid(DVM_AIU_FUNIT_IDS[j])] = 1;
      end
    end
  endfunction // new

  task body();
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
        <% for (var j = 0; j < obj.smiPortParams.rx[i].params.fnMsgClass.length; j++) { %>
            m_smi_seqr_tx_hash["<%=obj.smiPortParams.rx[i].params.fnMsgClass[j]%>"] = m_smi_virtual_seqr.m_smi<%=i%>_tx_seqr;
        <% } %>
    <% } %>
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
        <% for (var j = 0; j < obj.smiPortParams.tx[i].params.fnMsgClass.length; j++) { %>
            m_smi_seqr_rx_hash["<%=obj.smiPortParams.tx[i].params.fnMsgClass[j]%>"] = m_smi_virtual_seqr.m_smi<%=i%>_rx_seqr;
        <% } %>
    <% } %>

    if ($test$plusargs("disable_delays")) begin
        dis_delay_cmd_req = 1;
        dis_delay_dtw_req = 1;
        dis_delay_str_rsp = 1;
        dis_delay_snp_rsp = 1;
    end
//    if ($test$plusargs("inject_cmd_trgt_id_err")) begin
//        fork
//          issue_cmd_req();
//        join_any
//    end   
    if ($test$plusargs("inject_sys_trgt_id_err")) begin
        fork
          issue_sys_req();
        join_any
    end
    else begin 

    fork
      begin 
        tx_cmd_delay_pulse();
      end
      begin 
        tx_dtw_delay_pulse();
      end
      begin 
        tx_str_rsp_delay_pulse();
      end
      begin 
        tx_snp_rsp_delay_pulse();
      end
      begin
        issue_cmd_req();
      end

      begin
        forever
          receive_smi_snpstr_msg();
      end

      begin
        forever
          receive_smi_rsp_msg();
      end

      begin
        forever
          issue_dtw_req();
      end

      begin
        forever
          issue_snp_rsp();
      end

      begin
        forever
          issue_str_rsp();
      end

     begin
         issue_dtw_dbg_req();
      end

    join_any
    end

    //wait_4_all_msg();
  endtask // body

  extern task issue_cmd_req();
  extern task issue_sys_req();
  extern task issue_dtw_req();
  extern task issue_snp_rsp();
  extern task issue_str_rsp();
  extern task issue_dtw_dbg_req(); 
  extern task receive_smi_snpstr_msg(); // SNPreq, STRreq
  extern task receive_smi_rsp_msg(); // CMDrsp, DTWrsp, CMPrsp
  extern function void process_snp_req();
  extern function void process_str_req();
  extern function void process_cmd_rsp();
  extern function void process_dtw_rsp();
  extern function void process_cmp_rsp();
  extern function void process_sys_rsp();
  extern task insert_random_dly();
  extern task wait_4_all_msg();
  extern task tx_cmd_delay_pulse();
  extern task tx_dtw_delay_pulse();
  extern task tx_str_rsp_delay_pulse();
  extern task tx_snp_rsp_delay_pulse();

  extern task get_unique_msg_id(const ref int unit_id, output smi_msg_id_t message_id);
  extern function int funitid2nunitid(int fUnitId);

endclass // dve_targt_id_err_seq

task dve_targt_id_err_seq::tx_cmd_delay_pulse();
    delay_cmd_req = 0;
    if (!dis_delay_cmd_req) begin
        forever begin
            #(delay_cmd_req_value * 1ns);
            delay_cmd_req = ~delay_cmd_req;
            delay_cmd_req_value = $urandom_range(200,1000);
        end
    end
endtask :tx_cmd_delay_pulse 

task dve_targt_id_err_seq::tx_dtw_delay_pulse();
    delay_dtw_req = 0;
    if (!dis_delay_dtw_req) begin
        forever begin
            #(delay_dtw_req_value * 1ns);
            delay_dtw_req = ~delay_dtw_req;
            delay_dtw_req_value = $urandom_range(200,1000);
        end
    end
endtask :tx_dtw_delay_pulse 

task dve_targt_id_err_seq::tx_str_rsp_delay_pulse();
    delay_str_rsp = 0;
    if (!dis_delay_str_rsp) begin
        forever begin
            #(delay_str_rsp_value * 1ns);
            delay_str_rsp = ~delay_str_rsp;
            delay_str_rsp_value = $urandom_range(200,1000);
        end
    end
endtask :tx_str_rsp_delay_pulse 

task dve_targt_id_err_seq::tx_snp_rsp_delay_pulse();
    delay_snp_rsp = 0;
    if (!dis_delay_snp_rsp) begin
        forever begin
            #(delay_snp_rsp_value * 1ns);
            delay_snp_rsp = ~delay_snp_rsp;
            delay_snp_rsp_value = $urandom_range(200,1000);
        end
    end
endtask :tx_snp_rsp_delay_pulse 

task dve_targt_id_err_seq::issue_cmd_req();
  dve_cntr m_dve_cntr;
  int num_avl_credit;
  smi_msg_id_t  message_id = 0;

  if ($value$plusargs ("WC=%d", cmd_type_weight)) begin
    `uvm_info(get_name(), $psprintf("Compile args: cmd_type_weight = %0d", cmd_type_weight), UVM_NONE)
  end
  else begin
     void'(std::randomize(cmd_type_weight) with {cmd_type_weight inside {[5:20]} ; }); 
     `uvm_info(get_name(), $psprintf("Std Randomization: cmd_type_weight = %0d", cmd_type_weight), UVM_NONE)
  end
  if ($test$plusargs("enable_error")) begin
      enable_error = 1;
  end

//  `uvm_info("issue_cmd_req", $psprintf("Start sending %0d CMDreq", m_dve_unit_args.k_num_txn), UVM_NONE)
  `uvm_info(get_type_name(), $psprintf("issue_cmd_req: Start sending CMDreq, k_num_requests=%0d with %0d agents with error %0s", k_num_requests.get_value(), nDvmSnpAgents, (enable_error == 1) ? "enabled" : "disabled"), UVM_NONE)

//  for(int i = 0; i < k_num_requests.get_value()/nDvmSnpAgents; i++) begin
  txn_cnt = 0;
  while(txn_cnt < k_num_requests.get_value()) begin
  //for(int i = 0; i < 30; i++) begin
   int msg_id;
   int src_id;
   int idx_q[$];

   // look at total available credits and stall if no credit available
   num_avl_credit = 0;
   for(int j = 0; j < nDvmSnpAgents; j++) begin
      num_avl_credit = num_avl_credit + cmd_credits[DVM_AIU_FUNIT_IDS[j]];
   end
   if(num_avl_credit == 0) begin
      @e_cmd_rsp;
   end

   for(int j = 0; j < nDvmSnpAgents; j++) begin
   if(cmd_credits[DVM_AIU_FUNIT_IDS[j]] > 0) begin
       //if (!dis_delay_cmd_req) delay_cmd_req = 1;
       if (delay_cmd_req) begin
            wait(delay_cmd_req == 0);
       end

       txn_cnt++;
       //m_dve_cntr.m_cmd_req_pkt = smi_seq_item::type_id::create("m_cmd_req_pkt");
       //m_dve_cntr.m_cmd_req_pkt.smi_msg_id = i+1;
       //m_dve_cntr.m_cmd_req_pkt.smi_msg_type = CMD_DVM_MSG;
       //m_dve_cntr.m_cmd_req_pkt.smi_addr = $urandom();
       //m_dve_cntr.m_cmd_req_pkt.smi_addr[3] = i[0];
       void'(std::randomize(DvmOpType) with {DvmOpType dist {3'b100 :/ cmd_type_weight, [3'b000:3'b011] :/ 100-cmd_type_weight};}) ;
       //`uvm_info(get_type_name(), $psprintf("construct_cmd_req_pkt: DvmOpType = 0x%0h", DvmOpType), UVM_NONE)

        if(DvmOpType == 3'b100) begin
            idx_q = {};
            idx_q = m_ott_q.find_index with (item.is_sync_pending && item.m_cmd_req_pkt != null && item.m_cmd_req_pkt.smi_src_ncore_unit_id == j+1) ;
        end

        if(idx_q.size() == 0) begin
          m_dve_cntr = dve_cntr::type_id::create("m_dve_cntr");
          if (enable_error) begin
              m_dve_cntr.k_dtw_dbad_err_wgt = k_dtw_dbad_err_wgt.get_value();
              m_dve_cntr.k_str_rsp_err_wgt = k_str_rsp_err_wgt.get_value();
          end
          //m_dve_cntr.txn_id = txn_cnt;
          //m_dve_cntr.cmd_type_weight = cmd_type_weight;

          m_dve_cntr.construct_cmd_req_pkt(DVM_AIU_FUNIT_IDS[j]); //Fixme: Make this a random index of src_ids
          src_id = DVM_AIU_FUNIT_IDS[j]; 
          get_unique_msg_id(src_id, message_id); 
          m_dve_cntr.m_cmd_req_pkt.smi_msg_id = message_id; 
          m_dve_cntr.m_cmd_req_pkt.smi_addr[13:11] = DvmOpType;
          m_dve_cntr.m_cmd_req_pkt.smi_addr[3] = 1'b0; // CHI spec table 8-3
          `uvm_info(get_type_name(), $psprintf("issue_cmd_req: Sending CMDReq#%0d : %0s\n", txn_cnt, m_dve_cntr.m_cmd_req_pkt.convert2string()), UVM_LOW)
          //`uvm_info(get_type_name(), $psprintf("issue_cmd_req: src_id=0x%0h, DVM unitid=0x%0h, msg_id=0x%0h", src_id, m_dve_cntr.m_cmd_req_pkt.smi_src_ncore_unit_id, message_id), UVM_LOW)

          if(DvmOpType == 3'b100) 
            m_dve_cntr.is_sync_pending = 1;

          if(this.randomize() == 0)
            `uvm_error(get_type_name(), "issue_cmd_req: Randomization failed")

//          if(m_dve_unit_args.k_no_addr_conflict) begin
//            addr = dve_cntr.unq_addr_q.pop_front();
//          end
//          begin
//            dve_cntr.unq_addr_q.shuffle();
//            addr = dve_cntr.unq_addr_q.pop_front();
//          end
//          msg_id = dve_cntr.get_unused_msg_id(r_agent_id, r_cmd_req.smi_msg_type, addr);
//
//          credit_pool.get_credit(r_agent_id, num_avl_credit);

          m_dve_cntr.m_cmd_req_seq.m_seq_item = m_dve_cntr.m_cmd_req_pkt;
 
          // sequence - sequencer interaction
          m_dve_cntr.m_cmd_req_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["CMDREQ"]]);

          cmd_req_cnt++;
          m_dve_cntr.txn_id = cmd_req_cnt;

          if (m_dve_cntr.m_cmd_req_seq.m_seq_item.smi_cmstatus_err) begin
              cmp_rsp_cnt++;
              `uvm_info(get_type_name(), $psprintf("issue_cmd_req: Sent CMDreq%0d with smi_cmstatus_err CMDrsp", cmd_req_cnt), UVM_NONE)
          end else begin
              cmd_credits[DVM_AIU_FUNIT_IDS[j]]--;
              m_ott_q.push_back(m_dve_cntr);
              `uvm_info(get_type_name(), $psprintf("issue_cmd_req: Sent CMDreq%0d from src_id %0d, remaining cmd_credits[%0d]=%0d", cmd_req_cnt, DVM_AIU_FUNIT_IDS[j], DVM_AIU_FUNIT_IDS[j], cmd_credits[DVM_AIU_FUNIT_IDS[j]]), UVM_NONE)
          end

        end
        else begin
          `uvm_info(get_type_name(), $psprintf("issue_cmd_req: Skipped transaction number %0d for DVM Agent %0d",message_id,j), UVM_NONE)
          str_rsp_cnt++; //for wait_4_all_msg() task to have matching str_rsp_cnt value to end the sequence
          cmp_rsp_cnt++; // for error cases, use cmp_rsp_cnt
        end    
   end // if (cmd_credits[DVM_AIU_FUNIT_IDS[j]] > 0)

       if(txn_cnt == k_num_requests.get_value()) begin
	  break;
       end
   end // for (int j = 0; j < nDvmSnpAgents; j++)
  end // while (txn_cnt < k_num_requests.get_value())

//  `uvm_info("issue_cmd_req", $psprintf("Sent %0d CMDreq", m_dve_unit_args.k_num_txn), UVM_NONE)
    `uvm_info(get_type_name(), $psprintf("issue_cmd_req: Sent all CMDreqs"), UVM_NONE)
endtask // issue_cmd_req

task dve_targt_id_err_seq::get_unique_msg_id(const ref int unit_id, output smi_msg_id_t message_id);

    smi_msg_id_t tmp_msg_id;
    int count = 0;
    bit flag = 0;
    do begin
        tmp_msg_id = $urandom_range(2**WSMIMSGID- 1);
        if (!m_unq_id_array[unit_id].exists(tmp_msg_id)) begin
            flag = 1;
            m_unq_id_array[unit_id][tmp_msg_id] = 1;
        end
        count++;
        if (count >= 2**WSMIMSGID) begin
           <% if(obj.testBench == 'dve') { %>
           `ifndef VCS
            @e_smi_unq_id_freeup[unit_id];
           `else // `ifndef VCS
            e_smi_unq_id_freeup[unit_id].wait_trigger();
           `endif // `ifndef VCS ... `else ...
           <% } else {%>
            @e_smi_unq_id_freeup[unit_id];
           <% } %>
        end
    end while (!flag);
    message_id = tmp_msg_id;

endtask : get_unique_msg_id

task dve_targt_id_err_seq::receive_smi_snpstr_msg();
  dve_cntr m_dve_cntr;
  smi_seq_item rcvd_pkt;

  m_smi_seqr_rx_hash[dvcmd2rtlcmd["SNPREQ"]].m_rx_analysis_fifo.get(rcvd_pkt);
  rcvd_pkt.unpack_smi_seq_item();

  if(rcvd_pkt.isSnpMsg()) begin
    if(rcvd_pkt.smi_addr[3] == 1) begin
      `uvm_info(get_type_name(), $psprintf("process_snp_req: Received both SMI0 RX SNPreq for smi_msg_id = 0x%0h", rcvd_pkt.smi_msg_id), UVM_LOW)
      m_dve_cntr = dve_cntr::type_id::create("m_dve_cntr");
      m_dve_cntr.save_snp_req_pkt(rcvd_pkt);
      m_snp_rsp_q.push_back(m_dve_cntr);
      //->e_snp_rsp;
    end
  end
  else if(rcvd_pkt.isStrMsg()) begin
    m_str_req_pkt = smi_seq_item::type_id::create("m_str_req_pkt");
    m_str_req_pkt.copy(rcvd_pkt);
    process_str_req();
  end
  else begin
    `uvm_error(get_type_name(), $psprintf("receive_smi_snpstr_msg: Unexpected message received"))
  end
endtask // receive_smi_snpstr_msg

task dve_targt_id_err_seq::receive_smi_rsp_msg();
  smi_seq_item rcvd_pkt;

  m_smi_seqr_rx_hash[dvcmd2rtlcmd["CMDRSP"]].m_rx_analysis_fifo.get(rcvd_pkt);
  rcvd_pkt.unpack_smi_seq_item();

  smi_rsp_cnt++;
  `uvm_info(get_type_name(), $psprintf("receive_smi_rsp_msg: Received SMI response#%0d: %0s", smi_rsp_cnt, rcvd_pkt.convert2string()), UVM_LOW)
  if(rcvd_pkt.isNcCmdRspMsg()) begin
    m_cmd_rsp_pkt = smi_seq_item::type_id::create("m_cmd_rsp_pkt");
    m_cmd_rsp_pkt.copy(rcvd_pkt);
    process_cmd_rsp();
  end
  else if(rcvd_pkt.isDtwRspMsg()) begin
    m_dtw_rsp_pkt = smi_seq_item::type_id::create("m_dtw_rsp_pkt");
    m_dtw_rsp_pkt.copy(rcvd_pkt);
    process_dtw_rsp();
  end
  else if(rcvd_pkt.isCmpRspMsg()) begin
    m_cmp_rsp_pkt = smi_seq_item::type_id::create("m_cmp_rsp_pkt");
    m_cmp_rsp_pkt.copy(rcvd_pkt);
    process_cmp_rsp();
  end
  else if(rcvd_pkt.isSysRspMsg()) begin
    m_sys_rsp_pkt = smi_seq_item::type_id::create("m_sys_rsp_pkt");
    m_sys_rsp_pkt.copy(rcvd_pkt);
    process_sys_rsp();
  end
  else begin
    `uvm_error(get_type_name(), $psprintf("receive_smi_rsp_msg: Unexpected message received"))
  end
endtask // receive_smi_rsp_msg

function void dve_targt_id_err_seq::process_cmd_rsp();
  string msg;
  int idx_q[$];

  idx_q = {};
  idx_q = m_ott_q.find_index with(
           (item.m_cmd_req_pkt.smi_msg_id == m_cmd_rsp_pkt.smi_rmsg_id) 
           && (item.m_cmd_req_pkt.smi_src_ncore_unit_id == m_cmd_rsp_pkt.smi_targ_ncore_unit_id)
           && (item.rcvd_cmd_rsp == 0)
          );

  if(idx_q.size() == 0) begin
    `uvm_error(get_type_name(), $psprintf("process_cmd_rsp: Not expecting SMI1 RX CMDrsp with smi_rmsg_id = 0x%0h", m_cmd_rsp_pkt.smi_rmsg_id))
  end
  else begin
    cmd_rsp_cnt++;
    `uvm_info(get_type_name(), $psprintf("process_cmd_rsp: Received SMI1 RX CMDrsp#%0d: txn_id = %0d, smi_rmsg_id = 0x%0h", cmd_rsp_cnt, m_ott_q[idx_q[0]].txn_id, m_cmd_rsp_pkt.smi_rmsg_id), UVM_LOW)
  end

    m_ott_q[idx_q[0]].rcvd_cmd_rsp = 1;
    // m_ott_q[idx_q[0]].save_cmd_rsp_pkt(m_cmd_rsp_pkt);

    cmd_credits[m_cmd_rsp_pkt.smi_targ_ncore_unit_id]++;
    ->e_cmd_rsp;

    if(m_ott_q[idx_q[0]].rcvd_cmp_rsp && m_ott_q[idx_q[0]].rcvd_dtw_rsp && m_ott_q[idx_q[0]].rcvd_cmd_rsp) begin
      m_ott_q[idx_q[0]].can_issue_str_rsp = 1;
      ->e_str_rsp;
    end
endfunction // process_cmd_rsp

function void dve_targt_id_err_seq::process_dtw_rsp();
  string msg;
  int idx_q[$];

  idx_q = {};
  idx_q = m_ott_q.find_index with(
           (item.m_cmd_req_pkt.smi_msg_id == m_dtw_rsp_pkt.smi_rmsg_id) 
           && (item.m_cmd_req_pkt.smi_src_ncore_unit_id == m_dtw_rsp_pkt.smi_targ_ncore_unit_id)
           && (item.m_dtw_req_pkt !== null)
           && (item.m_dtw_req_pkt.smi_msg_id == m_dtw_rsp_pkt.smi_rmsg_id) 
           && (item.rcvd_dtw_rsp == 0)
          );

  if(idx_q.size() == 0) begin
    `uvm_error(get_type_name(), $psprintf("process_dtw_rsp: Not expecting SMI1 RX DTWrsp with smi_rmsg_id = 0x%0h", m_dtw_rsp_pkt.smi_rmsg_id))
  end
  else begin
    `uvm_info(get_type_name(), $psprintf("process_dtw_rsp: Received SMI1 RX DTWrsp: txn_id = %0d, smi_rmsg_id = 0x%0h", m_ott_q[idx_q[0]].txn_id, m_dtw_rsp_pkt.smi_rmsg_id), UVM_LOW)

    m_ott_q[idx_q[0]].rcvd_dtw_rsp = 1;
    // m_ott_q[idx_q[0]].save_dtw_rsp_pkt(m_dtw_req_pkt);
    if(m_ott_q[idx_q[0]].rcvd_cmp_rsp && m_ott_q[idx_q[0]].rcvd_dtw_rsp && m_ott_q[idx_q[0]].rcvd_cmd_rsp) begin
      m_ott_q[idx_q[0]].can_issue_str_rsp = 1;
      ->e_str_rsp;
    end
  end
endfunction // process_dtw_rsp

function void dve_targt_id_err_seq::process_sys_rsp();
  string msg;
  int idx_q[$];
  int nunitid;
  idx_q = {};
  idx_q = m_sys_q.find_index with(
           (item.m_sys_req_pkt.smi_msg_id == m_sys_rsp_pkt.smi_rmsg_id) 
           && (item.m_sys_req_pkt.smi_src_ncore_unit_id == m_sys_rsp_pkt.smi_targ_ncore_unit_id)
          );

  if(idx_q.size() == 0) begin
    `uvm_error(get_type_name(), $psprintf("process_sys_rsp: Not expecting SMI RX1 SYSrsp with smi_rmsg_id = 0x%0h, smi_targ_id = 0x%0h", m_sys_rsp_pkt.smi_rmsg_id, m_sys_rsp_pkt.smi_targ_ncore_unit_id))
  end
  else begin
    nunitid = funitid2nunitid(m_sys_rsp_pkt.smi_targ_ncore_unit_id);

    if(m_sys_q[idx_q[0]].m_sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_ATTACH) begin
        SysCoAttach_agents[nunitid] = 1;
        attaching_agents[nunitid] = 0;
    end
    else if(m_sys_q[idx_q[0]].m_sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_DETACH) begin
        SysCoAttach_agents[nunitid] = 0;
        detaching_agents[nunitid] = 0;
    end

    `uvm_info(get_type_name(), $psprintf("process_sys_rsp: SMI RX1 Received SYSrsp txn_id = %0d smi_targ_id = 0x%0h nunitid = %0d smi_sysreq_op = %s.  SysCoAttach_agents=0x%0h", m_sys_q[idx_q[0]].txn_id, m_sys_rsp_pkt.smi_targ_ncore_unit_id, nunitid, (m_sys_q[idx_q[0]].m_sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_ATTACH? "ATTACH" : (m_sys_q[idx_q[0]].m_sys_req_pkt.smi_sysreq_op == SMI_SYSREQ_DETACH ? "DETACH" : "OTHER")), SysCoAttach_agents), UVM_LOW)

    sys_rsp_cnt++;
    m_sys_q[idx_q[0]].rcvd_sys_rsp = 1;
    m_sys_q[idx_q[0]].save_sys_rsp_pkt(m_sys_rsp_pkt);

    m_sys_q.delete(idx_q[0]); 

    pending_sys_req = 0;
  end
endfunction // process_sys_rsp

function void dve_targt_id_err_seq::process_cmp_rsp();
  string msg;
  int idx_q[$];

  idx_q = {};
  idx_q = m_ott_q.find_index with(
           (item.m_cmd_req_pkt.smi_msg_id == m_cmp_rsp_pkt.smi_rmsg_id) 
           && (item.m_cmd_req_pkt.smi_src_ncore_unit_id == m_cmp_rsp_pkt.smi_targ_ncore_unit_id)
           && (item.rcvd_cmp_rsp == 0)
          );

  if(idx_q.size() == 0) begin
    `uvm_error(get_type_name(), $psprintf("process_cmp_rsp: Not expecting SMI1 RX CMPrsp with smi_rmsg_id = 0x%0h", m_cmp_rsp_pkt.smi_rmsg_id))
  end
  else begin
    `uvm_info(get_type_name(), $psprintf("process_cmp_rsp: Received SMI1 RX CMPrsp: txn_id = %0d, smi_rmsg_id = 0x%0h", m_ott_q[idx_q[0]].txn_id, m_cmp_rsp_pkt.smi_rmsg_id), UVM_LOW)

    m_ott_q[idx_q[0]].rcvd_cmp_rsp = 1;
    cmp_rsp_cnt++;
    `uvm_info(get_type_name(), $psprintf("Num of CMP RSP received 'd%0d", cmp_rsp_cnt), UVM_LOW)
    // m_ott_q[idx_q[0]].save_cmp_rsp_pkt(m_cmp_rsp_pkt);

    if(m_ott_q[idx_q[0]].rcvd_cmp_rsp && m_ott_q[idx_q[0]].rcvd_dtw_rsp && m_ott_q[idx_q[0]].rcvd_cmd_rsp) begin
      m_ott_q[idx_q[0]].can_issue_str_rsp = 1;
      ->e_str_rsp;
    end
  end
endfunction // process_cmp_rsp

function void dve_targt_id_err_seq::process_str_req();
  string msg;
  int idx_q[$];

  idx_q = {};
  idx_q = m_ott_q.find_index with(item.rcvd_str_req == 0
                                  && item.m_cmd_req_pkt.smi_msg_id == m_str_req_pkt.smi_rmsg_id
                                  && item.m_cmd_req_pkt.smi_src_ncore_unit_id == m_str_req_pkt.smi_targ_ncore_unit_id);

  if(idx_q.size() == 0) begin
    `uvm_error(get_type_name(), $psprintf("process_str_req: Not expecting SMI1 RX STRreq with smi_msg_id = 0x%0h", m_str_req_pkt.smi_msg_id))
  end
  else begin
    str_req_cnt++;
    `uvm_info(get_type_name(), $psprintf("process_str_req: Received SMI1 RX STRreq#%0d: txn_id = %0d, smi_msg_id = 0x%0h", str_req_cnt, m_ott_q[idx_q[0]].txn_id, m_str_req_pkt.smi_msg_id), UVM_LOW)

    m_ott_q[idx_q[0]].rcvd_str_req = 1;
    m_ott_q[idx_q[0]].save_str_req_pkt(m_str_req_pkt);
  end

  m_ott_q[idx_q[0]].can_issue_dtw_req = 1;
  ->e_dtw_req;
endfunction // process_str_req

function void dve_targt_id_err_seq::process_snp_req();
  string msg;
  int idx_q[$];

  idx_q = {};
  idx_q = m_ott_q.find_index with(
           ((item.rcvd_snp_req1 == 0) ||
            (item.rcvd_snp_req2 == 0))
          );

  if(idx_q.size() == 0) begin
    `uvm_error(get_type_name(), $psprintf("process_snp_req: Not expecting SMI0 RX SNPreq with smi_msg_id = 0x%0h", m_snp_req_pkt.smi_msg_id))
  end
  else begin
    snp_req_cnt++;
    `uvm_info(get_type_name(), $psprintf("process_snp_req: Received SMI0 RX SNPreq%0d: txn_id = %0d, smi_msg_id = 0x%0h", snp_req_cnt, m_ott_q[idx_q[0]].txn_id, m_snp_req_pkt.smi_msg_id), UVM_LOW)

    if(m_ott_q[idx_q[0]].rcvd_snp_req1 == 1)
      m_ott_q[idx_q[0]].rcvd_snp_req2 = 1;
    else
      m_ott_q[idx_q[0]].rcvd_snp_req1 = 1;
    m_ott_q[idx_q[0]].save_snp_req_pkt(m_snp_req_pkt);

    if(m_ott_q[idx_q[0]].rcvd_snp_req2) begin
      m_ott_q[idx_q[0]].can_issue_snp_rsp = 1;
      ->e_snp_rsp;
    end
  end
endfunction // process_snp_req

task dve_targt_id_err_seq::issue_dtw_req();
  int idx_q[$];
  dve_cntr m_dve_cntr;

  if (delay_dtw_req) begin
    wait(delay_dtw_req == 0);
  end

  idx_q = {};
  idx_q = m_ott_q.find_index with(
           (item.can_issue_dtw_req) &&
           (item.issued_dtw_req == 0)
          );
  if(idx_q.size() == 0)
    @e_dtw_req;

  if(idx_q.size() != 0) begin
    idx_q.shuffle();
    m_dve_cntr = m_ott_q[idx_q[0]];
    m_ott_q[idx_q[0]].issued_dtw_req = 1;
    m_ott_q[idx_q[0]].can_issue_dtw_req = 0;
    m_dve_cntr.construct_dtw_req_pkt();
    m_dve_cntr.m_dtw_req_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["DTWREQ"]]);
    dtw_req_cnt++;
    `uvm_info(get_type_name(), $psprintf("issue_dtw_req: Sent DTWreq#%0d for txnid: %0d", dtw_req_cnt, m_dve_cntr.txn_id), UVM_NONE)
  end
endtask // issue_dtw_req

task dve_targt_id_err_seq::issue_dtw_dbg_req();
  dve_cntr m_dve_cntr;
  smi_msg_id_t  message_id = 0;
  int num_dtw_dbg_requests;
  int dtw_dbg_req_cnt;
  bit is_dve_dtwdbg_reader;
  bit dve_dtw_dbg_loss;
  int running_dtw_dbg_timestamp;
   
  if ($value$plusargs ("WC=%d", cmd_type_weight)) begin
    `uvm_info(get_name(), $psprintf("Compile args: cmd_type_weight = %0d", cmd_type_weight), UVM_NONE)
  end
  else begin
     void'(std::randomize(cmd_type_weight) with {cmd_type_weight inside {[5:20]} ; }); 
     `uvm_info(get_name(), $psprintf("Std Randomization: cmd_type_weight = %0d", cmd_type_weight), UVM_NONE)
  end
  if ($test$plusargs("enable_error")) begin
      enable_error = 1;
  end

  if(!$value$plusargs("num_dtw_dbg_requests=%d", num_dtw_dbg_requests)) begin
     num_dtw_dbg_requests = 0;
  end

  if($value$plusargs("is_dve_dtwdbg_reader=%0d", is_dve_dtwdbg_reader)) begin
    // if we have a dve_dtwdbg_reader, wait for it to finish programming CSRs
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event csr_init_done = ev_pool.get("dve_csr_init_done");
    csr_init_done.wait_trigger();
  end

  if(!$value$plusargs("dve_initial_timestamp=%0d", running_dtw_dbg_timestamp)) begin
    running_dtw_dbg_timestamp=0;
  end

  if(num_dtw_dbg_requests > 0) begin
//  `uvm_info("issue_cmd_req", $psprintf("Start sending %0d CMDreq", m_dve_unit_args.k_num_txn), UVM_NONE)
  `uvm_info(get_type_name(), $psprintf("issue_dtw_dbg_req: Start sending DTWDBGreq, k_num_requests=%0d with %0d agents", num_dtw_dbg_requests, nTraceAgents), UVM_NONE)
  end

  if($value$plusargs("dve_dtw_dbg_loss=%0d", dve_dtw_dbg_loss)) begin
    // make sure we have enough packets lined up to fill the buffer, or
    // else the reader will hang waiting for BufferFull
    num_dtw_dbg_requests += <%=nMainTraceBufSize%>;
  end

  dtw_dbg_req_cnt = 0;
  while(dtw_dbg_req_cnt < num_dtw_dbg_requests) begin
   int msg_id;
   int src_id;
   int idx_q[$];
   int smi_error;
   int rand_agent;
  
   //if (!dis_delay_cmd_req) delay_cmd_req = 1;
   if (delay_dtw_dbg_req) begin
      wait(delay_dtw_dbg_req == 0);
   end

   m_dve_cntr = dve_cntr::type_id::create("m_dve_cntr");

   rand_agent = $urandom() % nTraceAgents;  
   src_id = TraceAgents[rand_agent]; 
   m_dve_cntr.construct_dtw_dbg_req_pkt(src_id, running_dtw_dbg_timestamp); //Fixme: Make this a random index of src_ids
   get_unique_msg_id(src_id, message_id); 
   m_dve_cntr.m_dtw_dbg_req_pkt.smi_msg_id = message_id; 
   `uvm_info(get_type_name(), $psprintf("issue_dtw_dbg_req: Sending DTWDBGReq#%0d : %0s\n", txn_cnt, m_dve_cntr.m_dtw_dbg_req_pkt.convert2string()), UVM_LOW)
          //`uvm_info(get_type_name(), $psprintf("issue_cmd_req: src_id=0x%0h, DVM unitid=0x%0h, msg_id=0x%0h", src_id, m_dve_cntr.m_cmd_req_pkt.smi_src_ncore_unit_id, message_id), UVM_LOW)

   m_dve_cntr.m_dtw_dbg_req_seq.m_seq_item = m_dve_cntr.m_dtw_dbg_req_pkt;
 
   // sequence - sequencer interaction
   m_dve_cntr.m_dtw_dbg_req_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["DTWDBGREQ"]]);

   // update running timetamp - we want to approximately track the RTL, but with errors
   running_dtw_dbg_timestamp += $urandom_range(0, 255) - 127; // TODO tune these for coverage

   dtw_dbg_req_cnt++;
   m_dve_cntr.txn_id = dtw_dbg_req_cnt;
   m_dtw_dbg_q.push_back(m_dve_cntr);
   `uvm_info(get_type_name(), $psprintf("issue_dtw_dbg_req: Sent DTWDBGReq#%0d : %0s\n", dtw_dbg_req_cnt, m_dve_cntr.m_dtw_dbg_req_pkt.convert2string()), UVM_LOW)
  end // while (dtw_dbg_req_cnt < num_dtw_dbg_requests)

  if(num_dtw_dbg_requests > 0)
     `uvm_info(get_type_name(), $psprintf("issue_dtw_dbg_req: Sent all %0d DTWDBG requests", num_dtw_dbg_requests), UVM_NONE)

endtask // issue_dtw_dbg_req

task dve_targt_id_err_seq::issue_snp_rsp();
  dve_cntr m_dve_cntr;

    wait(m_snp_rsp_q.size > 0); 
    //if (!dis_delay_snp_rsp) delay_snp_rsp = 1;
    if (delay_snp_rsp) begin
      wait(delay_snp_rsp == 0);
    end
    m_dve_cntr = dve_cntr::type_id::create("m_dve_cntr");
    m_snp_rsp_q.shuffle();
    m_dve_cntr = m_snp_rsp_q.pop_front();
    if (enable_error) m_dve_cntr.k_snp_rsp_err_wgt = k_snp_rsp_err_wgt.get_value();
    m_dve_cntr.construct_snp_rsp_pkt();
    m_dve_cntr.m_snp_rsp_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["SNPRSP"]]);
    snp_rsp_cnt++;
    `uvm_info(get_type_name(), $psprintf("issue_snp_rsp: Sent SNPrsp#%0d", snp_rsp_cnt), UVM_NONE)

endtask // issue_snp_rsp

task dve_targt_id_err_seq::issue_str_rsp();
  int idx_q[$];
  string msg;
  dve_cntr m_dve_cntr;

  if (delay_str_rsp) begin
    wait(delay_str_rsp == 0);
  end

  idx_q = {};
  idx_q = m_ott_q.find_index with(
           (item.can_issue_str_rsp) &&
           (item.rcvd_dtw_rsp) &&
           (item.issued_str_rsp == 0)
          );

  if(idx_q.size() == 0)
    @e_str_rsp;

  else if(idx_q.size() != 0) begin
    idx_q.shuffle();
    m_dve_cntr = m_ott_q[idx_q[0]];
    m_ott_q[idx_q[0]].issued_str_rsp = 1;
    m_dve_cntr.construct_str_rsp_pkt();
    m_dve_cntr.m_str_rsp_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["STRRSP"]]);
    str_rsp_cnt++;
    `uvm_info(get_type_name(), $psprintf("issue_str_rsp: Sent STRrsp%0d", str_rsp_cnt), UVM_NONE)

    m_unq_id_array[m_dve_cntr.m_cmd_req_pkt.smi_src_ncore_unit_id].delete(m_dve_cntr.m_cmd_req_pkt.smi_msg_id);
    <% if(obj.testBench == 'dve') { %>
    `ifndef VCS
    ->e_smi_unq_id_freeup[m_dve_cntr.m_cmd_req_pkt.smi_src_ncore_unit_id];
    `else // `ifndef VCS
      e_smi_unq_id_freeup[m_dve_cntr.m_cmd_req_pkt.smi_src_ncore_unit_id] = ev_pool.get($sformatf("e_smi_unq_id_freeup_%0d",m_dve_cntr.m_cmd_req_pkt.smi_src_ncore_unit_id));
      e_smi_unq_id_freeup[m_dve_cntr.m_cmd_req_pkt.smi_src_ncore_unit_id].trigger();
    `endif // `ifndef VCS ... `else ...
    <% } else {%>
    ->e_smi_unq_id_freeup[m_dve_cntr.m_cmd_req_pkt.smi_src_ncore_unit_id];
    <% } %>   
    m_ott_q.delete(idx_q[0]);
    `uvm_info(get_type_name(), $psprintf("issue_str_rsp: STRrsp is received, deleting OTT entry, %0d CMDreq sent, %0d pending txn", cmd_req_cnt, m_ott_q.size()), UVM_LOW)
  end
endtask // issue_str_rsp

task dve_targt_id_err_seq::issue_sys_req();
  dve_cntr m_dve_cntr;
  int nunitid;
  int nDveAgents = SnoopEn_FUNIT_IDS.size();
  int sysreq_op;
  int num_delays;
  int aiu;
  int num_sysreq_requests;
  int src_aiu;
  int detaching_aiu_cntr = 0;
  int attaching_aiu_cntr = 0;
   
   if(!$value$plusargs("num_sysreq_requests=%d", num_sysreq_requests))
     num_sysreq_requests = 0;

   if($test$plusargs("sysco_enable")) begin
   while((sys_req_cnt < num_sysreq_requests) || (is_por_done == 0)) begin
      if(is_por_done == 0) begin
         foreach(DVM_AIU_FUNIT_IDS[aiu]) begin
	    sys_req_cnt++;
            nunitid = funitid2nunitid(DVM_AIU_FUNIT_IDS[aiu]);
            attaching_agents[nunitid] = 1;
            m_dve_cntr = dve_cntr::type_id::create("m_dve_sys_cntr");
            m_dve_cntr.construct_sys_req_pkt(DVM_AIU_FUNIT_IDS[aiu], SMI_SYSREQ_ATTACH);
            m_dve_cntr.m_sys_req_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["SYSREQ"]]);
            `uvm_info(get_full_name(), $sformatf("issue_sys_req: Sent SysCo Attach for NUnitId %0d PKT ID: %0d.  SysReq: %s", nunitid, sys_req_cnt, m_dve_cntr.m_sys_req_pkt.convert2string()), UVM_LOW)

            m_dve_cntr.txn_id = sys_req_cnt;
	    m_sys_q.push_back(m_dve_cntr);
         end

         if(!$test$plusargs("inject_sys_trgt_id_err")) begin
           wait(sys_rsp_cnt == sys_req_cnt);
           `uvm_info(get_full_name(), $sformatf("issue_sys_req: Received all SysRsp's for powerup SysCo Attach"), UVM_LOW)
         end

         sys_req_cnt = 0;	 
         is_por_done = 1;
         ->e_sys_req_por_done;
      end // if (is_por_done == 0)      
      else begin
         // pick random attach or detach
	 if($countones(SysCoAttach_agents) == nDveAgents) begin
	   sysreq_op = 0;  // detach when all agents are attached
         end else if($countones(SysCoAttach_agents) < 3) begin
	   sysreq_op = 1;  // attach when 2 or less agent is attached
	 end else begin
	   sysreq_op = $urandom()%2;  // random attach or detach
	 end

         num_delays = ($urandom() % 900) + 100;  // 100 - 1000 * 5ns

//         `uvm_info(get_full_name(), $sformatf("Picked SysCo %s Req.  nDveAgents=%0d, SysCoAttach_agents=0x%0h, num_delays=%0d", (sysreq_op==0 ? "Detach" : "Attach"), nDveAgents, SysCoAttach_agents, num_delays), UVM_MEDIUM)

	 repeat(num_delays) insert_random_dly();

         // flag for pending SysReq and wait til all units are idle
	 pending_sys_req = 1;
	 wait(m_ott_q.size() == 0);
	 
	 sys_req_cnt++;
         if(sysreq_op == 0) begin  // detach
            // search for next attached agent
            for(aiu=0; aiu<nDveAgents; aiu++) begin
               nunitid = funitid2nunitid(DVM_AIU_FUNIT_IDS[detaching_aiu_cntr]);
               src_aiu = detaching_aiu_cntr;
               detaching_aiu_cntr++;
               if(detaching_aiu_cntr == nDveAgents) detaching_aiu_cntr = 0;
	       
	       if((SysCoAttach_agents[nunitid] == 1) && (detaching_agents[nunitid] == 0))
                  break;
	    end
            // set flag to stop sending more dvm requests and wait for current requests to finish
            `uvm_info(get_full_name(), $sformatf("issue_sys_req: Preparing to send SysCo Detach Req %0d of %0d for NUnitId %0d", sys_req_cnt, num_sysreq_requests, nunitid), UVM_MEDIUM)
	    detaching_agents[nunitid] = 1;
            wait(num_active_dvm_cmds[DVM_AIU_FUNIT_IDS[src_aiu]] == 0);
	    
            m_dve_cntr = dve_cntr::type_id::create("m_dve_sys_cntr");
            m_dve_cntr.construct_sys_req_pkt(DVM_AIU_FUNIT_IDS[src_aiu], SMI_SYSREQ_DETACH);
            m_dve_cntr.m_sys_req_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["SYSREQ"]]);
            `uvm_info(get_full_name(), $sformatf("issue_sys_req: Sent SysCo Req %0d of %0d for NUnitId %0d PKT ID: %0d.  SysReq Detach: %s", sys_req_cnt, num_sysreq_requests, nunitid, sys_req_cnt, m_dve_cntr.m_sys_req_pkt.convert2string()), UVM_LOW)

            m_dve_cntr.txn_id = sys_req_cnt;
	    m_sys_q.push_back(m_dve_cntr);
	 end 	 
         else if(sysreq_op == 1) begin // attach
            // search for next detached agent
            for(aiu=0; aiu<nDveAgents; aiu++) begin
               nunitid = funitid2nunitid(DVM_AIU_FUNIT_IDS[attaching_aiu_cntr]);
               src_aiu = attaching_aiu_cntr;
               attaching_aiu_cntr++;
               if(attaching_aiu_cntr == nDveAgents) attaching_aiu_cntr = 0;

	       if((SysCoAttach_agents[nunitid] == 0) && (attaching_agents[nunitid] == 0))
                  break;
	    end
            // set flag to stop sending more dvm requests and wait for current requests to finish
            `uvm_info(get_full_name(), $sformatf("issue_sys_req: Preparing to send SysCo Attach Req %0d of %0d for NUnitId %0d", sys_req_cnt, num_sysreq_requests, nunitid), UVM_MEDIUM)
	    attaching_agents[nunitid] = 1;
            wait(num_active_dvm_cmds[DVM_AIU_FUNIT_IDS[src_aiu]] == 0);

            m_dve_cntr = dve_cntr::type_id::create("m_dve_sys_cntr");
            m_dve_cntr.construct_sys_req_pkt(DVM_AIU_FUNIT_IDS[src_aiu], SMI_SYSREQ_ATTACH);
            m_dve_cntr.m_sys_req_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["SYSREQ"]]);
            `uvm_info(get_full_name(), $sformatf("issue_sys_req: Sent SysCo Req %0d of %0d for NUnitId %0d PKT ID: %0d.  SysReq Attach: %s", sys_req_cnt, num_sysreq_requests, nunitid, sys_req_cnt, m_dve_cntr.m_sys_req_pkt.convert2string()), UVM_LOW)

            m_dve_cntr.txn_id = sys_req_cnt;
	    m_sys_q.push_back(m_dve_cntr);
	 end // if (sysreq_op == 1)
      end // else: !if(is_por_done == 0)
   end // while ((sys_req_cnt < num_sysreq_requests) || (is_por_done == 0))
   end // if ($test$plusargs("sysco_enable"))
   else begin
      is_por_done = 1;
      ->e_sys_req_por_done;
   end // if ($test$plusargs("sysco_enable"))

endtask // issue_sys_req

task dve_targt_id_err_seq::insert_random_dly();
  #5ns;
endtask // insert_random_dly

task dve_targt_id_err_seq::wait_4_all_msg();
  int expected_transactions = (k_num_requests.get_value()/nDvmSnpAgents) * nDvmSnpAgents; // this will be a number divisible by nDvmSnpAgents
  `uvm_info(get_type_name(), $psprintf("wait_4_all_msg: Waiting to complete all CMDReq -> STRRsp cycles"), UVM_NONE)
  if (enable_error == 0)
    wait(str_rsp_cnt == expected_transactions);
  else 
    wait(cmp_rsp_cnt == expected_transactions);
  `uvm_info(get_type_name(), $psprintf("wait_4_all_msg: Got STRRsp %0d for all transaction %0d",str_rsp_cnt,k_num_requests.get_value()), UVM_NONE)
endtask // wait_4_all_msg

function int dve_targt_id_err_seq::funitid2nunitid(int fUnitId);
   int nunitid = -1;

   foreach(SnoopEn_FUNIT_IDS[i]) begin
      if(SnoopEn_FUNIT_IDS[i] == fUnitId) begin
	 nunitid = SnoopEn_NUNIT_IDS[i];
	 break;
      end
   end
   return nunitid;
endfunction : funitid2nunitid
