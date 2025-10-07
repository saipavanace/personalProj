<%const chipletObj = obj.lib.getAllChipletRefs();%>

class ncore_exclusive_access_test extends ncore_sys_test;
  `uvm_component_utils(ncore_exclusive_access_test)
  
  ncore_exclusive_access_vseq m_excl_vseq;
  
  function new(string name = "ncore_exclusive_access_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    m_excl_vseq = ncore_exclusive_access_vseq::type_id::create("m_excl_vseq");

        <%for(let i=0; i<chipletObj[0].nCHIs; i++){%>
            m_excl_vseq.chi_rn_sqr<%=i%> = m_env.m_amba_env.chi_system[0].rn[<%=i%>].rn_xact_seqr;
        <%}%>

        <%let pidx=0;%>
        <%for(let idx = 0; idx < chipletObj[0].nAIUs; idx++) { %>
            <%if(!(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                      <%for (let mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                      m_excl_vseq.axi_xact_seqr<%=pidx%> = m_env.m_amba_env.axi_system[0].master[<%=pidx%>].sequencer;
                      <%pidx++;%>
                   <%}%>
            <%}%>
        <%}%>


    `uvm_info(get_name(), "Starting ncore_exclusive_access_test", UVM_NONE)
    m_excl_vseq.start(null);
    `uvm_info(get_name(), "Done ncore_exclusive_access_test", UVM_NONE)
    phase.drop_objection(this);
  endtask: run_phase

endclass: ncore_exclusive_access_test
