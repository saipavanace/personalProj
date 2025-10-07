class ncore_ace_directed_test extends ncore_sys_test;
  `uvm_component_utils(ncore_ace_directed_test)
  
  ncore_ace_directed_vseq m_ace_directed_vseq;
  
  function new(string name = "ncore_ace_directed_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    m_ace_directed_vseq = ncore_ace_directed_vseq::type_id::create("m_ace_directed_vseq");
    m_ace_directed_vseq.regmodel = m_env.regmodel;

        <%let pidx=0;%>
        <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
            <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                <%if(obj.AiuInfo[idx].fnNativeInterface == 'ACE' || obj.AiuInfo[idx].fnNativeInterface == 'ACE5'){%>
                      <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                      m_ace_directed_vseq.axi_xact_seqr<%=pidx%> = m_env.m_amba_env.axi_system[0].master[<%=pidx%>].sequencer;
                      <%pidx++;%>
                   <%}%>
                <%}%>
            <%}%>
        <%}%>
        
    `uvm_info(get_name(), "Starting ncore_ace_directed_test", UVM_NONE)
    m_ace_directed_vseq.start(null);
    `uvm_info(get_name(), "Done ncore_ace_directed_test", UVM_NONE)
    phase.drop_objection(this);
  endtask: run_phase

endclass: ncore_ace_directed_test


