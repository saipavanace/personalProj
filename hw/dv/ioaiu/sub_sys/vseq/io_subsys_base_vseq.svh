`ifndef GUARD_IO_SUBSYS_BASE_VSEQ_SVH
`define GUARD_IO_SUBSYS_BASE_VSEQ_SVH

<%
var aiu_NumCores = [];
var initiatorAgents   = obj.AiuInfo.length ;
const aiu_axiInt = [];
var AiuCore;

 for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
   } else {
       aiu_NumCores[pidx]    = 1;
   }
 }

for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt[0];
        AiuCore = 'ioaiu_core0';
    } else {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt;
        AiuCore = 'ioaiu_core0';
    }
}

%>


//This class will contain handles to all sequencers
//class io_subsys_base_vseq extends uvm_sequence #(uvm_sequence_item);
//class io_subsys_base_vseq extends svt_axi_system_base_sequence;
`ifdef USE_VIP_SNPS_AXI_MASTERS
class io_subsys_base_vseq extends svt_axi_ace_master_base_virtual_sequence;
`else
class io_subsys_base_vseq extends uvm_sequence;
`endif

  `uvm_object_utils(io_subsys_base_vseq)

  string mstr_agnt_seqr_str[`NUM_IOAIU_SVT_MASTERS];
  svt_axi_master_sequencer mstr_agnt_seqr_a[`NUM_IOAIU_SVT_MASTERS];
  concerto_env_cfg env_cfg;//placeholder
  int sequence_length;
  
   //INHOUSE IOAIU SEQ
    <% var qidx=0; var idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
             //sys_event agent seq
        <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
           ioaiu<%=qidx%>_event_agent_pkg::event_seq  m_ioaiu<%=qidx%>_event_seq;
           ioaiu<%=qidx%>_event_agent_pkg::event_sequencer m_event_sqr_ioaiu<%=qidx%>[<%=aiu_NumCores[pidx]%>];
        <% } %> 
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq          m_iocache_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq          m_iocache_read_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];  // read
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (aiu_axiInt[pidx].params.eAc==1) ){ %>
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_snoop_seq              m_iosnoop_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
      <% } %>
<%  qidx++; } %>
    <% } %>

  static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  <%for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
  uvm_event ev_wait_completion_of_seq_aiu<%=pidx%> = ev_pool.get("ev_wait_completion_of_seq_aiu<%=pidx%>");
  <% } %>

    bit 	has_axi_vip_snps;
    bit		k_directed_test;
    int		ioaiu_num_trans;
    int 	ioaiu_qos[int];
    bit		ioaiu_user_qos;
    string	ioaiu_qos_str[];
    string     	ioaiu_qos_arg;
    bit 	enable_ace_dvmsync;
    int 	no_snoop_seq;
    int 	ioaiu_en[int];

  function new(string name = "io_subsys_base_vseq");
    super.new(name);
  endfunction

  /**  Raise an objection if this is the parent sequence */
  virtual task pre_body();
    super.pre_body();
    if  (starting_phase!=null) begin
      starting_phase.raise_objection(this);
    end
  endtask: pre_body

  /**  Drop an objection if this is the parent sequence */
  virtual task post_body();
    super.post_body();
    if  (starting_phase!=null) begin
      starting_phase.drop_objection(this);
    end
  endtask: post_body

endclass: io_subsys_base_vseq

`endif // `ifndef GUARD_IO_SUBSYS_BASE_VSEQ_SVH
