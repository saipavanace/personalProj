//
// Class: dce_csr_bitbash_reg_test
//        CSR writing '1s 0's test
//
//#Test.DCE.RegisterWritesAndReads

class dce_csr_bitbash_reg_test extends dce_base_test;

  `uvm_component_utils(dce_csr_bitbash_reg_test)
   uvm_reg_bit_bash_seq reg_bit_bash_seq;


  function new(string name = "dce_csr_bitbash_reg_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

  endfunction : build_phase

  task run_phase(uvm_phase phase);
     super.run_phase(phase);
     uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUSFMCR.get_full_name()}, "NO_REG_TESTS", 1, this);
     uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUEDR0.get_full_name()}, "NO_REG_TESTS", 1, this);  //Excluded as per CONC-6909
     uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUSER0.get_full_name()}, "NO_REG_TESTS", 1, this);
	<%if(obj.DceInfo[0].nAius > 32) { %>
     uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUSER1.get_full_name()}, "NO_REG_TESTS", 1, this);
	<%}%>
     //uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.DCE.DCEUDCR.get_full_name()},
     //                     "NO_REG_TESTS", 1, this);
     reg_bit_bash_seq = uvm_reg_bit_bash_seq::type_id::create("reg_bit_bash_seq"); 
     reg_bit_bash_seq.model     = m_env.m_regs;
     fork
         begin
             `uvm_info("RUN_PHASE",$sformatf("raise objection "), UVM_LOW)
             phase.raise_objection(this, "Start dce_csr_bitbash_reg_test run_main");
             #200ns;
             reg_bit_bash_seq.start(m_env.m_apb_agent.m_apb_sequencer);
             #200ns;
             phase.drop_objection(this, "Finish dce_csr_bitbash_reg_test run_main");
             `uvm_info("RUN_PHASE",$sformatf("drop objection "), UVM_LOW)
         end
     join
  endtask : run_phase

endclass: dce_csr_bitbash_reg_test
