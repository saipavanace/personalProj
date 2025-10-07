<%
let computedAxiInt;
if(Array.isArray(obj.interfaces.axiInt)){
    computedAxiInt = obj.interfaces.axiInt[0];
}else{
    computedAxiInt = obj.interfaces.axiInt;
}
%>

////////////////////////////////////////////////////////////////////////////////
//******************************************************************************
// Class    : ioaiu_AXI_register_access_test 
// Purpose  : Write and read USIDR register
//******************************************************************************
class ioaiu_AXI_register_access_test extends base_test;
  `uvm_component_utils(ioaiu_AXI_register_access_test)
   axi_single_rdnosnp_seq register_rd_seq;
   axi_single_wrnosnp_seq register_wr_seq;

  function new(string name = "ioaiu_AXI_register_access_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  task run_phase (uvm_phase phase);
      super.run_phase(phase);
      register_rd_seq       = axi_single_rdnosnp_seq::type_id::create("register_rd_seq");
      register_wr_seq       = axi_single_wrnosnp_seq::type_id::create("register_wr_seq");
      fork 
        begin
            phase.raise_objection(this, "Start IOAIU AXI register access sequence");
            #200ns;
            `uvm_info("IOAIU AXI Seq", "Starting IOAIU AXI register access sequence",UVM_NONE)
            if($test$plusargs("csr_read")) begin
                register_rd_seq.m_addr = <%=computedAxiInt.params.wAddr%><%=obj.DutInfo.CsrInfo.csrBaseAddress.replace("0x","'h")%>F_F000; //BRSBAR_Base
                register_rd_seq.start(mp_env.m_env[0].m_axi_master_agent.m_axi_virtual_seqr);
            end
            if($test$plusargs("csr_write")) begin
                register_wr_seq.m_addr = <%=computedAxiInt.params.wAddr%><%=obj.DutInfo.CsrInfo.csrBaseAddress.replace("0x","'h")%>F_F000; //BRSBAR_Base
                register_wr_seq.m_data = <%=computedAxiInt.params.wData%>'hdead_beaf;
                register_wr_seq.start(mp_env.m_env[0].m_axi_master_agent.m_axi_virtual_seqr);
            end
            #200ns;
            phase.drop_objection(this, "Finish IOAIU AXI register access sequence");
        end
      join

    endtask : run_phase
endclass: ioaiu_AXI_register_access_test
