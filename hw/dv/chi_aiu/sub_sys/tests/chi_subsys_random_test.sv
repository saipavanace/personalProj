// #Stimulus.CHI.v3.6.CleanSharedPersistSep
// #Stimulus.CHI.v3.6.MakeReadUnique
// #Stimulus.CHI.v3.6.No_datapull_attribute
// #Stimulus.CHI.v3.6.OWO
// #Stimulus.CHI.v3.6.ReadPreferUnique
// #Stimulus.CHI.v3.6.WrNoSnpFull_expCompAck
// #Stimulus.CHI.v3.6.WrNoSnpPtl_expCompAck
// #Stimulus.CHI.v3.6.WriteBackFullCleanShPerSep
// #Stimulus.CHI.v3.6.WriteBackFullCleanSh
// #Stimulus.CHI.v3.6.WriteCleanFullCleanShPreSep
// #Stimulus.CHI.v3.6.WriteCleanFullCleanSh
// #Stimulus.CHI.v3.6.WriteNoSnpFullCleanShPerSep
// #Stimulus.CHI.v3.6.WriteNoSnpFullCleanSh
// #Stimulus.CHI.v3.6.WriteNoSnpFullCleanInv
// #Stimulus.CHI.v3.6.WriteNoSnpZero
// #Stimulus.CHI.v3.6.WriteUniqueZero
// #Stimulus.CHI.v3.6.WriteBackFullCleanInv
// #Stimulus.CHI.v3.6.ReadPreferUnique.Error
// #Check.CHI.v3.6.ReadPreferUnique_Err
// #Stimulus.CHI.v3.6.TagOp
// #Stimulus.CHI.v3.6.TXN_WIDTH

class chi_subsys_random_test extends chi_subsys_base_test;
    `uvm_component_utils(chi_subsys_random_test)

    chi_subsys_random_vseq m_random_vseq;

    function new(string name = "chi_subsys_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_random_vseq = chi_subsys_random_vseq::type_id::create("m_random_vseq");
    endfunction: build_phase

    task start_sequence();
        fork
            begin
                <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                    m_random_vseq.rn_xact_seqr<%=idx%> = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;
                <%}%>
                `uvm_info(get_name(), "Starting chi_subsys_random_test", UVM_NONE)
                m_random_vseq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
                `uvm_info(get_name(), "Done chi_subsys_random_test", UVM_NONE)
            end
        join
    endtask: start_sequence

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase

endclass: chi_subsys_random_test