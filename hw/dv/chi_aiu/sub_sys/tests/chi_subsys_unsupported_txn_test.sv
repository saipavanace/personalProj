class chi_subsys_unsupported_txn_test extends chi_subsys_base_test;
    `uvm_component_utils(chi_subsys_unsupported_txn_test)

    chi_subsys_unsupported_txn_vseq m_unsupported_txn_vseq;

    function new(string name = "chi_subsys_unsupported_txn_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_unsupported_txn_vseq = chi_subsys_unsupported_txn_vseq::type_id::create("m_unsupported_txn_vseq");
    endfunction: build_phase

    task start_sequence();
        // #Stimulus.CHI.v3.6.Unsupported_Opcode
        // #Stimulus.CHI.v3.6.Unsupported_Opcode.Random
        fork
            begin
                <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                    m_unsupported_txn_vseq.rn_xact_seqr<%=idx%> = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;
                <%}%>
                `uvm_info(get_name(), "Starting chi_subsys_unsupported_txn_test", UVM_NONE)
                m_unsupported_txn_vseq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
                `uvm_info(get_name(), "Done chi_subsys_unsupported_txn_test", UVM_NONE)
            end
        join
    endtask: start_sequence

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase

endclass: chi_subsys_unsupported_txn_test