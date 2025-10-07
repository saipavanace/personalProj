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

class io_subsys_inhouse_vseq extends io_subsys_inhouse_base_vseq;
  `uvm_object_utils(io_subsys_inhouse_vseq)

  function new(string name = "io_subsys_inhouse_vseq");
    super.new(name);
    create_inhouse_seqs();
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
  
  task body();
     `uvm_info(get_full_name(), "Enter body", UVM_LOW);
      
      fork
      <% 
      var chiaiu_idx = 0;
      var ioaiu_idx = 0;
      var ioaiu_idx_with_multi_core = 0;
      for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
      <% if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
      <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>  
      begin
        if (ioaiu_en.exists(<%=ioaiu_idx%>)) begin: _ioaiu<%=ioaiu_idx%>_<%=i%>_inhouse
          <%if( pidx > 0 ) { %>
          if($test$plusargs("sequential")) begin
            ev_wait_completion_of_seq_aiu<%=pidx-1%>.wait_ptrigger();
          end
          <%}%>

          if  (starting_phase!=null)
          begin
            starting_phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] sequence");
          end
          `uvm_info("FULLSYS_TEST", "Start IOAIU<%=ioaiu_idx%>[<%=i%>] VSEQ", UVM_NONE)
          fork
            <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (aiu_axiInt[pidx].params.eAc==1) ){ %>
                               if(no_snoop_seq==0)m_iosnoop_seq<%=ioaiu_idx%>[<%=i%>].start(null); //SANJEEV: VSEQ_ALREADY: IOAIU INHOUSE: SNOOP
            <% } %>
                m_iocache_seq<%=ioaiu_idx%>[<%=i%>].start(null); //SANJEEV: VSEQ_ALREADY : IOAIU INHOUSE:
          <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
                  `uvm_info("FULLSYS_TEST", "START ioaiu<%=ioaiu_idx%> EVENT SEQ ", UVM_LOW)
                   m_ioaiu<%=ioaiu_idx%>_event_seq.start(m_event_sqr_ioaiu<%=ioaiu_idx%>[<%=i%>]); //SANJEEV: NOT VSEQ_ALREADY : IOAIU INHOUSE:
                  `uvm_info("FULLSYS_TEST", "END ioaiu<%=ioaiu_idx%> EVENT SEQ ", UVM_LOW)
                
          <% } %>                          
                       join_any
                `uvm_info("FULLSYS_TEST", "Done IOAIU<%=ioaiu_idx%>[<%=i%>] VSEQ", UVM_NONE)
                //#5us;
                if  (starting_phase!=null)
                begin
                  starting_phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] sequence");
                end
          
        end:_ioaiu<%=ioaiu_idx%>_<%=i%>_inhouse
      end
          <% ioaiu_idx_with_multi_core = ioaiu_idx_with_multi_core + 1;} // foreach core%> 
       <% ioaiu_idx++; } %>
       <% } // foreach AIUs%>
      join
      wait fork;

    //`uvm_error(get_full_name(), $psprintf("Exit to debug"));

  endtask: body

  function void create_inhouse_seqs();
    <% var qidx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
         //sys_event agent seq
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
       m_ioaiu<%=qidx%>_event_seq = ioaiu<%=qidx%>_event_agent_pkg::event_seq::type_id::create("m_ioaiu<%=qidx%>_event_seq") ;
    <% } %>        
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %> 
    m_iocache_seq<%=qidx%>[<%=i%>]                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq::type_id::create("m_ioaiu<%=qidx%>_seq");
    m_iocache_seq<%=qidx%>[<%=i%>].core_id = <%=i%>;
    m_iocache_seq<%=qidx%>[<%=i%>].set_seq_name("m_ioaiu<%=qidx%>_seq[<%=i%>]");

    // read
        m_iocache_read_seq<%=qidx%>[<%=i%>]                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq::type_id::create("m_ioaiu<%=qidx%>_read_seq");
        m_iocache_read_seq<%=qidx%>[<%=i%>].core_id = <%=i%> ;
        m_iocache_read_seq<%=qidx%>[<%=i%>].set_seq_name("m_ioaiu<%=qidx%>_read_seq[<%=i%>]");

      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (aiu_axiInt[pidx].params.eAc==1) ){ %>
    m_iosnoop_seq<%=qidx%>[<%=i%>]                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_snoop_seq::type_id::create("m_iosnoop<%=qidx%>_seq");

      <%}%>
    <% } // foreach core %>
    <% qidx++; } //foreach ioaiu%>
    <% } // foreahc AIU%>

  endfunction: create_inhouse_seqs


endclass: io_subsys_inhouse_vseq
