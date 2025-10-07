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
        m_bandwidth_vseq.regmodel = m_env.regmodel;
        <%for(let i=0; i<obj.nCHIs; i++){%>
            m_bandwidth_vseq.chi_rn_sqr<%=i%> = m_env.m_amba_env.chi_system[0].rn[<%=i%>].rn_xact_seqr;
        <%}%>

        <%let pidx=0;%>
        <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
            <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                    m_bandwidth_vseq.axi_xact_seqr<%=pidx%> = m_env.m_amba_env.axi_system[0].master[<%=pidx%>].sequencer;
                    <%pidx++;%>
                <%}%>
            <%}%>
        <%}%>
        
        m_bandwidth_vseq.start(null);
        phase.drop_objection(this);
    endtask: run_phase

endclass: ncore_bandwidth_test

