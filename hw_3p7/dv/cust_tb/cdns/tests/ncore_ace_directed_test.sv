class ncore_ace_directed_test extends ncore_sys_test;
    `uvm_component_utils(ncore_ace_directed_test)
    ncore_ace_directed_vseq m_ace_directed_vseq;

    function new(string name = "ncore_ace_directed_test", uvm_component parent);
        super.new(name,parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_ace_directed_vseq = ncore_ace_directed_vseq::type_id::create("m_ace_directed_vseq");
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        <%let pidx=0;%>
        <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
            <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                <%if(obj.AiuInfo[idx].fnNativeInterface == 'ACE' || obj.AiuInfo[idx].fnNativeInterface == 'ACE5'){%>
                      <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                        m_ace_directed_vseq.axi_sequencer<%=pidx%> = env.m_aiuMstAgent<%=pidx%>.sequencer; 
                      <%pidx++;%>
                   <%}%>
                <%}%>
            <%}%>
        <%}%>
        `uvm_info(get_name(), "Starting ncore_ace_directed_test", UVM_LOW)
        m_ace_directed_vseq.start(null);
        `uvm_info(get_name(), "Done ncore_ace_directed_test", UVM_LOW)
        phase.drop_objection(this);
    endtask : run_phase

endclass : ncore_ace_directed_test

