<% if(obj.useResiliency == 1){ %>
class ncore_fsc_ral_reset_value_test extends ncore_sys_test;

    `uvm_component_utils(ncore_fsc_ral_reset_value_test);
    uvm_reg_hw_reset_seq   csr_seq;

    function new (string name="ncore_fsc_ral_reset_value_test", uvm_component parent);
        super.new (name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        bit status;
        super.build_phase(phase);
        csr_seq = uvm_reg_hw_reset_seq::type_id::create("csr_seq");
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        `uvm_info("run_phase", "Entered...", UVM_LOW)
        csr_seq.model = m_env.resiliency_m_regs;

        <% for(var pidx = 0; pidx < 4; pidx++) { %>
            uvm_resource_db#(bit)::set({"REG::",m_env.resiliency_m_regs.fsc.FSCMF<%=pidx%>.get_full_name()}, "NO_REG_TESTS", 1,this);
        <% } %>

        phase.raise_objection(this);
        csr_seq.start(null);
        phase.drop_objection(this);
    endtask : run_phase

endclass : ncore_fsc_ral_reset_value_test
<% } %>
