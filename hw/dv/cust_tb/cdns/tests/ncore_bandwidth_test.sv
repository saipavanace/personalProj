class ncore_bandwidth_test extends ncore_sys_test;
    `uvm_component_utils(ncore_bandwidth_test);
    ncore_bandwidth_vseq m_bandwidth_vseq;
    
    function new (string name="ncore_bandwidth_test", uvm_component parent);
        super.new (name, parent);
    endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        m_bandwidth_vseq = ncore_bandwidth_vseq::type_id::create("m_bandwidth_vseq");
        <%for(let i=0; i<obj.nCHIs; i++){%>
            m_bandwidth_vseq.chi_sequencer<%=i%> = env.m_aiuChiMstAgent<%=i%>.sequencer;
        <%}%>

        <%let pidx=0;%>
        <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
            <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                    m_bandwidth_vseq.axi_sequencer<%=pidx%> = env.m_aiuMstAgent<%=pidx%>.sequencer;
                    <%pidx++;%>
                <%}%>
            <%}%>
        <%}%>
        
        m_bandwidth_vseq.start(null);
        phase.drop_objection(this);
    endtask: run_phase

endclass: ncore_bandwidth_test


