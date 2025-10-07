class chi_subsys_ip_error_test extends chi_subsys_base_test;
    `uvm_component_utils(chi_subsys_ip_error_test)

    chi_subsys_ip_error_vseq m_ip_error_vseq;

    function new(string name = "chi_subsys_ip_error_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_ip_error_vseq = chi_subsys_ip_error_vseq::type_id::create("m_ip_error_vseq");
    endfunction: build_phase

    task start_sequence();
        uvm_status_e    status;
        // FIXME: Make this random 
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUEDR.IntfCheckErrDetEn.write(status,$urandom_range(1,0));
            m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUEIR.IntfCheckErrIntEn.write(status,$urandom_range(1,0));
        <%}%>
        // #Stimulus.CHI.v3.6.InterfaceParity_all_signals
        // #Stimulus.CHI.v3.6.InterfaceParity_eror
        // #Stimulus.CHI.v3.6.InterfaceParity
        // #Stimulus.CHI.v3.7.InterfaceParity
        // #Stimulus.CHI.v3.7.InterfaceParity.Error
        fork
            begin
                <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                    m_ip_error_vseq.rn_xact_seqr<%=idx%> = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;
                <%}%>
                `uvm_info(get_name(), "Starting chi_subsys_ip_error_test", UVM_NONE)
                m_ip_error_vseq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
                `uvm_info(get_name(), "Done chi_subsys_ip_error_test", UVM_NONE)
            end
        join
    endtask: start_sequence

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase

endclass: chi_subsys_ip_error_test
