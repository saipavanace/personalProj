<%const chipletObj = obj.lib.getAllChipletRefs();%>

class ncore_chi_directed_test extends ncore_sys_test;
    `uvm_component_utils(ncore_chi_directed_test)

    ncore_chi_directed_vseq m_chi_directed_vseq;

    function new(string name = "ncore_chi_directed_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction: build_phase


    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        m_chi_directed_vseq = ncore_chi_directed_vseq::type_id::create("m_chi_directed_vseq");
        //m_chi_directed_vseq.regmodel = m_env.regmodel;

        <%for(let i=0; i<chipletObj[0].nCHIs; i++){%>
            m_chi_directed_vseq.chi_rn_sqr<%=i%> = m_env.m_amba_env.chi_system[0].rn[<%=i%>].rn_xact_seqr;
        <%}%>

       `uvm_info(get_name(), "Starting ncore_chi_directed_test", UVM_NONE)
        m_chi_directed_vseq.start(null);
       `uvm_info(get_name(), "Done ncore_chi_directed_test", UVM_NONE)
        phase.drop_objection(this);
    endtask: run_phase

endclass: ncore_chi_directed_test

