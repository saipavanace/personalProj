class ncore_chi_directed_test extends ncore_sys_test;
    `uvm_component_utils(ncore_chi_directed_test)
    ncore_chi_directed_vseq m_chi_directed_vseq;

    function new(string name = "ncore_chi_directed_test", uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_chi_directed_vseq = ncore_chi_directed_vseq::type_id::create("m_chi_directed_vseq");
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        fork
            begin
                <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                    m_chi_directed_vseq.chi_sequencer<%=idx%> = env.m_aiuChiMstAgent<%=idx%>.sequencer; 
                <%}%>
                    `uvm_info(get_name(), "Starting ncore_chi_directed_test", UVM_LOW)
                    m_chi_directed_vseq.start(null);
                    `uvm_info(get_name(), "Done ncore_chi_directed_test", UVM_LOW)
            end
        join
        phase.drop_objection(this);
    endtask : run_phase
endclass : ncore_chi_directed_test
