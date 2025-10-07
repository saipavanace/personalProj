class ncore_snoop_test extends ncore_sys_test;
    `uvm_component_utils(ncore_snoop_test)
    ncore_snoop_vseq m_snoop_vseq;

    function new(string name = "ncore_snoop_test",uvm_component parent);
        super.new(name,parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_snoop_vseq = ncore_snoop_vseq::type_id::create("m_snoop_vseq");
    endfunction 
  
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase); 
        phase.raise_objection(this);
        fork
            begin
                <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                    m_snoop_vseq.chi_sequencer<%=idx%> = env.m_aiuChiMstAgent<%=idx%>.sequencer; 
                <%}%>

                <%let pidx=0;%>
                    <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
                        <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                        <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                           m_snoop_vseq.axi_sequencer<%=pidx%> = env.m_aiuMstAgent<%=pidx%>.sequencer;
                        <%pidx++;%>
                        <%}%>
                    <%}%>
                <%}%>

                `uvm_info(get_name(), "Starting ncore_snoop_test", UVM_LOW)
                m_snoop_vseq.start(null);
                `uvm_info(get_name(), "Done ncore_snoop_test", UVM_LOW)
            end
        join 
        phase.drop_objection(this);
    endtask : run_phase

endclass : ncore_snoop_test
