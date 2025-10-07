<%
const Dvm_NUnitIds = [] ;
const nMainTraceBufSize = obj.DutInfo.nMainTraceBufSize;

for (const elem of obj.AiuInfo) {
    if(elem.cmpInfo.nDvmSnpInFlight >0) {
        Dvm_NUnitIds.push(elem.nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

const dvm_agent = Dvm_NUnitIds.length;
%>


import common_knob_pkg::*;

class dve_tacc_test_seq extends uvm_sequence#(smi_seq_item);
  `uvm_object_utils(dve_tacc_test_seq)

  dve_cntr m_ott_q[$];
  dve_cntr m_snp_rsp_q[$];
//  dve_unit_args m_dve_unit_args;
  // dve_credit_pool credit_pool;

  smi_sequencer m_smi_seqr_tx_hash[string];
  smi_sequencer m_smi_seqr_rx_hash[string];
  smi_virtual_sequencer m_smi_virtual_seqr;
  // Randomize
  rand int r_agent_id;
  rand smi_seq_item r_cmd_req;

  int nDvmSnpAgents = <%=dvm_agent%>;//4;
  int cmd_type_weight = 0;
  bit           m_unq_id_array[int][smi_msg_id_t];
 <% if(obj.testBench == 'dve') { %>
 `ifndef VCS
  event         e_smi_unq_id_freeup[int];
 `else // `ifndef VCS
  uvm_event         e_smi_unq_id_freeup[int];
 `endif // `ifndef VCS ... `else ...
 <% } else {%>
  event         e_smi_unq_id_freeup[int];
 <% } %>  
  // rand eMsgCMD r_msg_type;
  rand bit [2:0] DvmOpType ; //3'b100 = Sync
  int       txn_cnt = 0;

  // variables for accessing CSRs
  <% if(obj.testBench == 'dve') { %>
  ral_sys_ncore          m_regs;
  <% } else if(obj.testBench == 'fsys') { %>
  concerto_register_map_pkg::ral_sys_ncore m_regs;
  <% } %>
  uvm_reg_data_t         rd_data,wr_data;
  uvm_reg_data_t         data;
  uvm_reg_data_t         field_rd_data;
  uvm_status_e           status;

  // Constraints

  // Counts
  int cmd_credits[int];
  int smi_rsp_cnt;
  int dtw_dbg_req_cnt;
  int dtw_dbg_rsp_cnt;
  dve_cntr m_dtw_dbg_q[$];

  bit delay_dtw_dbg_req;

  int delay_dtw_dbg_req_value = 1;

  bit dis_delay_dtw_dbg_req = 0;

  // Events
  event e_dtw_dbg_req;

  // Global dynamic handles for SMI request/responses
  smi_seq_item m_dtw_dbg_req_pkt;
  smi_seq_item m_dtw_dbg_rsp_pkt;

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

  static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  static uvm_event ev = ev_pool.get("ev");
  static uvm_event ev_addr = ev_pool.get("ev_addr");
  
  // Functions
  function new(string name = "dve_tacc_test_seq");
    super.new(name);

    <% for(idx=0; idx<obj.nAIUs; idx++) { %>
    cmd_credits[<%=obj.AiuInfo[idx].FUnitId%>] = <%=obj.AiuInfo[idx].cmpInfo.nDvmMsgInFlight%>;
    <% } %>
    dtw_dbg_req_cnt = 0;
    // credit_pool = credit_pool::GetInstance();
  endfunction // new

  task body();
    bit empty = 1'b0;
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
        dis_delay_dtw_dbg_req = 1;
    end

    if($test$plusargs("dve_dtw_dbg_circular")) begin
      set_buffer_is_circular(1'b1);
    end

    // Wait for DVE to assert empty so we know the buffer has been zeroed properly - CONC-9338
    while(!empty) begin
      buffer_is_empty(empty);
      if(!empty) begin
       `uvm_info(get_name(), "Waiting for TACC state machine to be ready", UVM_DEBUG)
      end
    end
  endtask // body
  
  extern task issue_dtw_dbg_req();
  extern task receive_smi_rsp_msg(); // CMDrsp, DTWrsp, CMPrsp
  extern function void process_dtw_dbg_rsp();
  extern task tx_dtw_delay_pulse();
  extern task buffer_is_empty(output bit is_empty);
  extern task buffer_is_full(output bit is_full);
  extern task set_buffer_is_circular(bit circular);
  extern task issue_csr_read();
  extern task issue_csr_clear();
  extern task fill_buffer();
  extern task drain_buffer();
  extern task get_unique_msg_id(const ref int unit_id, output smi_msg_id_t message_id);

  /////////////////////////////////////////////////////////////
  // Stolen from ral_csr_base seq

    ////////////////////////////////////////////////////////////////////////////////
    //helpers

    function void compareValues(string one, string two, int data1, int data2);
        if (data1 == data2) begin
            `uvm_info("RUN_MAIN",$sformatf("%s:0x%x, expd %s:0x%0x OKAY", one, data1, two, data2), UVM_MEDIUM)
        end else begin
            `uvm_error("RUN_MAIN",$sformatf("Mismatch %s:0x%0x, expd %s:0x%0x",one, data1, two, data2));
        end
    endfunction // compareValues

    function uvm_reg_data_t mask_data(int lsb, int msb);
        uvm_reg_data_t mask_data_val = 0;

        for(int i=0;i<32;i++)begin
            if(i>=lsb &&  i<=msb)begin
                mask_data_val[i] = 1;     
            end
        end
        //$display("func maskdataval:0x%0x",mask_data_val);
        return mask_data_val;
    endfunction:mask_data

    ////////////////////////////////////////////////////////////////////////////////
    //accessors

    task write_csr(uvm_reg_field field, uvm_reg_data_t wr_data);
        int lsb, msb;
        uvm_reg_data_t mask;
        field.get_parent().read(status, field_rd_data/*, .parent(this)*/);
        lsb = field.get_lsb_pos();
        msb = lsb + field.get_n_bits() - 1;
        `uvm_info("CSR Ralgen Base Seq", $sformatf("Write %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_MEDIUM);
        // and with actual field bits 0
        mask = mask_data(lsb, msb);
        //$display("mask:0x%0x",mask);
        mask = ~mask;
        field_rd_data = field_rd_data & mask;
        // shift write data to appropriate position
        wr_data = wr_data << lsb;
        // then or with this data to get value to write
        wr_data = field_rd_data | wr_data;
        field.get_parent().write(status, wr_data/*, .parent(this)*/);
    endtask : write_csr

    task read_csr(uvm_reg_field field, output uvm_reg_data_t fieldVal);
        int lsb, msb;
        uvm_reg_data_t mask;
        field.get_parent().read(status, field_rd_data/*, .parent(this)*/);
        lsb = field.get_lsb_pos();
        msb = lsb + field.get_n_bits() - 1;
        `uvm_info("CSR Ralgen Base Seq", $sformatf("Read %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_MEDIUM);
        //$display("rd_data:0x%0x",field_rd_data);
        // AND other bits to 0
        mask = mask_data(lsb, msb);
        //$display("mask:0x%0x",mask);
        field_rd_data = field_rd_data & mask;
        //$display("masked data:0x%0x",field_rd_data);
        // shift read data by lsb to return field
        fieldVal = field_rd_data >> lsb;
        //$display("fieldVal:0x%0x",fieldVal);
    endtask : read_csr

    task poll_csr(uvm_reg_field field, bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        int timeout;
        timeout = 5000;
        do begin
            timeout -=1;
            read_csr(field, fieldVal);
            //fieldVal = field_rd_data;
            `uvm_info("CSR Ralgen Base Seq", $sformatf("%s poll_till=0x%0x fieldVal=0x%0x timeout=%0d", field.get_name(), poll_till, fieldVal, timeout), UVM_NONE);
        end while ((fieldVal != poll_till) && (timeout != 0)); // UNMATCHED !!
        if (timeout == 0) begin
            `uvm_error("CSR Ralgen Base Seq", $sformatf("Timeout! Polling %s, poll_till=0x%0x fieldVal=0x%0x", field.get_name(), poll_till, fieldVal))
        end
    endtask : poll_csr
endclass // dve_tacc_test_seq

task dve_tacc_test_seq::buffer_is_empty(output bit is_empty);
    read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETASCR.BufferIsEmpty, is_empty);
endtask: buffer_is_empty

task dve_tacc_test_seq::buffer_is_full(output bit is_full);
    read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETASCR.BufferIsFull, is_full);
endtask: buffer_is_full

task dve_tacc_test_seq::set_buffer_is_circular(bit circular);
    write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETASCR.BufferIsCircular, circular);
endtask: set_buffer_is_circular

task dve_tacc_test_seq::issue_csr_clear();
    write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETASCR.BufferClear, 1'b1);
    // TODO: how do we get a coverage object in-scope here? does this test even have a dve_env?
    //cov.collect_dve_buffer_clear(1'b1);
endtask: issue_csr_clear

task dve_tacc_test_seq::issue_csr_read();
    bit data_ready = 1'b0;
    write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETASCR.BufferRead, 1'b1);

    // Wait for the state machine
    while(data_ready != 1'b1) begin
      #1000 // TODO use a real delay here. We need 10 clocks or so.
      read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETADHR.valid, data_ready);
    end
endtask: issue_csr_read

task dve_tacc_test_seq::tx_dtw_delay_pulse();
    delay_dtw_dbg_req = 0;
    if (!dis_delay_dtw_dbg_req) begin
        forever begin
            #(delay_dtw_dbg_req_value * 1ns);
            delay_dtw_dbg_req = ~delay_dtw_dbg_req;
            delay_dtw_dbg_req_value = $urandom_range(200,1000);
        end
    end
endtask :tx_dtw_delay_pulse 

task dve_tacc_test_seq::get_unique_msg_id(const ref int unit_id, output smi_msg_id_t message_id);

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

task dve_tacc_test_seq::receive_smi_rsp_msg();
  smi_seq_item rcvd_pkt;

  m_smi_seqr_rx_hash[dvcmd2rtlcmd["NCCMDRSP"]].m_rx_analysis_fifo.get(rcvd_pkt);
  rcvd_pkt.unpack_smi_seq_item();

  smi_rsp_cnt++;
  `uvm_info(get_type_name(), $psprintf("receive_smi_rsp_msg: Received SMI response#%0d: %0s", smi_rsp_cnt, rcvd_pkt.convert2string()), UVM_LOW)
  if(rcvd_pkt.isDtwDbgRspMsg()) begin
    m_dtw_dbg_rsp_pkt = smi_seq_item::type_id::create("m_dtw_rsp_pkt");
    m_dtw_dbg_rsp_pkt.copy(rcvd_pkt);
    process_dtw_dbg_rsp();
  end
  else begin
    `uvm_error(get_type_name(), $psprintf("receive_smi_rsp_msg: Unexpected message received"))
  end
endtask // receive_smi_rsp_msg

function void dve_tacc_test_seq::process_dtw_dbg_rsp();
  string msg;
  int idx_q[$];

  idx_q = {};
  idx_q = m_dtw_dbg_q.find_index with(
           (item.m_dtw_dbg_req_pkt.smi_msg_id == m_dtw_dbg_rsp_pkt.smi_rmsg_id) 
           && (item.m_dtw_dbg_req_pkt.smi_src_ncore_unit_id == m_dtw_dbg_rsp_pkt.smi_targ_ncore_unit_id)
          );

  if(idx_q.size() == 0) begin
    `uvm_error(get_type_name(), $psprintf("process_dtw_dbg_rsp: Not expecting SMI RX2 DTWDBGrsp with smi_rmsg_id = 0x%0h", m_dtw_dbg_rsp_pkt.smi_rmsg_id))
  end
  else begin
    `uvm_info(get_type_name(), $psprintf("process_dtw_dbg_rsp: SMI RX1 Received DTWDBGrsp: txn_id = %0d, smi_rmsg_id = 0x%0h", m_dtw_dbg_q[idx_q[0]].txn_id, m_dtw_dbg_rsp_pkt.smi_rmsg_id), UVM_LOW)

    dtw_dbg_rsp_cnt++;
    m_dtw_dbg_q[idx_q[0]].rcvd_dtw_dbg_rsp = 1;
    m_dtw_dbg_q[idx_q[0]].save_dtw_dbg_rsp_pkt(m_dtw_dbg_rsp_pkt);
  end
endfunction // process_dtw_dbg_rsp

task dve_tacc_test_seq::issue_dtw_dbg_req();
   dve_cntr m_dve_cntr;
   int msg_id;
   int idx_q[$];
   int smi_error;
   smi_msg_id_t  message_id = 0;
  
   m_dve_cntr = dve_cntr::type_id::create("m_dve_cntr");

   m_dve_cntr.construct_dtw_dbg_req_pkt(dtw_dbg_req_cnt);
   get_unique_msg_id(dtw_dbg_req_cnt, message_id); 
   m_dve_cntr.m_dtw_dbg_req_pkt.smi_msg_id = message_id; 
   `uvm_info(get_type_name(), $psprintf("issue_dtw_dbg_req: Sending DTWDBGReq#%0d : %0s\n", txn_cnt, m_dve_cntr.m_dtw_dbg_req_pkt.convert2string()), UVM_LOW)
          //`uvm_info(get_type_name(), $psprintf("issue_cmd_req: src_id=0x%0h, DVM unitid=0x%0h, msg_id=0x%0h", dtw_dbg_req_cnt, m_dve_cntr.m_cmd_req_pkt.smi_src_ncore_unit_id, message_id), UVM_LOW)

   m_dve_cntr.m_dtw_dbg_req_seq.m_seq_item = m_dve_cntr.m_dtw_dbg_req_pkt;
 
   // sequence - sequencer interaction
   m_dve_cntr.m_dtw_dbg_req_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["DTWDBGREQ"]]);

   dtw_dbg_req_cnt++;
   m_dve_cntr.txn_id = dtw_dbg_req_cnt;
   m_dtw_dbg_q.push_back(m_dve_cntr);
   `uvm_info(get_type_name(), $psprintf("issue_dtw_dbg_req: Sent DTWDBGReq#%0d : %0s\n", dtw_dbg_req_cnt, m_dve_cntr.m_dtw_dbg_req_pkt.convert2string()), UVM_LOW)
endtask // issue_dtw_dbg_req

task dve_tacc_test_seq::fill_buffer();
  bit full;
  for(int i = 0; i < <%=nMainTraceBufSize%>; i++) begin
    issue_dtw_dbg_req();
  end
  #20000000 buffer_is_full(full);
  if(!full) begin
    `uvm_error(get_name(), "TACC buffer not full after filling");
  end
endtask: fill_buffer

task dve_tacc_test_seq::drain_buffer();
  bit empty;
  buffer_is_empty(empty);
  while(!empty) begin
    issue_csr_read();
    buffer_is_empty(empty);
  end
endtask: drain_buffer
