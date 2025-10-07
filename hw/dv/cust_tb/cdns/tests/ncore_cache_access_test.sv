class ncore_cache_access_test extends ncore_sys_test;
    `uvm_component_utils(ncore_cache_access_test)
    ncore_cache_access_vseq m_cache_access_vseq;

    function new(string name = "ncore_cache_access_test", uvm_component parent);
        super.new(name,parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_cache_access_vseq = ncore_cache_access_vseq::type_id::create("m_cache_access_vseq");
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        begin
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            m_cache_access_vseq.chi_sequencer<%=idx%> = env.m_aiuChiMstAgent<%=idx%>.sequencer; 
        <%}%>

                <%let pidx=0;%>
                    <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
                        <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                        <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                           m_cache_access_vseq.axi_sequencer<%=pidx%> = env.m_aiuMstAgent<%=pidx%>.sequencer;
                        <%pidx++;%>
                        <%}%>
                    <%}%>
                <%}%>

            `uvm_info(get_name(), "Starting ncore_cache_access_test", UVM_LOW)
            m_cache_access_vseq.start(null);
            `uvm_info(get_name(), "Done ncore_cache_access_test", UVM_LOW)
        end
        phase.drop_objection(this);
    endtask : run_phase
endclass : ncore_cache_access_test


