class ncore_connectivity_test extends ncore_sys_test;
    `uvm_component_utils(ncore_connectivity_test);
    
    ncore_connectivity_vseq m_connectivity_vseq;
    
    function new (string name="ncore_connectivity_test", uvm_component parent);
        super.new (name, parent);
    endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        m_connectivity_vseq = ncore_connectivity_vseq::type_id::create("m_connectivity_vseq");
        m_connectivity_vseq.regmodel = m_env.regmodel;
        <%for(let i=0; i<obj.nCHIs; i++){%>
            m_connectivity_vseq.chi_rn_sqr<%=i%> = m_env.m_amba_env.chi_system[0].rn[<%=i%>].rn_xact_seqr;
        <%}%>

        <%let pidx=0;%>
        <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
            <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                    m_connectivity_vseq.axi_xact_seqr<%=pidx%> = m_env.m_amba_env.axi_system[0].master[<%=pidx%>].sequencer;
                    <%pidx++;%>
                <%}%>
            <%}%>
        <%}%>
        
        m_connectivity_vseq.start(null);
        phase.drop_objection(this);
    endtask: run_phase

endclass: ncore_connectivity_test

