class chi_subsys_write_excl_test extends chi_subsys_base_test;
    `uvm_component_utils(chi_subsys_write_excl_test)

    chi_subsys_write_excl_vseq m_write_excl_vseq;

    bit en_excl_txn;

    function new(string name = "chi_subsys_write_excl_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
	en_excl_txn = 1;
	uvm_config_db#(bit)::set(null,"*","chi_subsys_mstr_seq_cfg_en_excl_txn",en_excl_txn);
        super.build_phase(phase);
        m_write_excl_vseq = chi_subsys_write_excl_vseq::type_id::create("m_write_excl_vseq");

    endfunction: build_phase

    task start_sequence();
        fork
            begin
                <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                    m_write_excl_vseq.rn_xact_seqr<%=idx%> = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;
                <%}%>
                `uvm_info(get_name(), "Starting chi_subsys_write_excl_test", UVM_NONE)
                m_write_excl_vseq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
                `uvm_info(get_name(), "Done chi_subsys_write_excl_test", UVM_NONE)
            end
        join
    endtask: start_sequence

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase

endclass: chi_subsys_write_excl_test
