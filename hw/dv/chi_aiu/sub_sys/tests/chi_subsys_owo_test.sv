
class chi_subsys_owo_test extends chi_subsys_base_test;

    
    `uvm_component_utils(chi_subsys_owo_test)

    function new(string name = "chi_subsys_owo_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction: build_phase

    task start_sequence();
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            chi_subsys_pkg::chi_subsys_owo_writes_seq      m_owo_seq<%=idx%>;
        <%}%>
        // #Stimulus.CHI.v3.6.WriteNoSnpZero.Error
        
        fork
            <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                begin
                    `uvm_info(get_name(), "Starting m_owo_seq on RN<%=idx%>", UVM_NONE)
                    repeat(1000) begin
                        m_owo_seq<%=idx%> = chi_subsys_pkg::chi_subsys_owo_writes_seq::type_id::create("m_owo_seq<%=idx%>");
                        m_owo_seq<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr);
                    end
                    `uvm_info(get_name(), "Done m_owo_seq on RN<%=idx%>", UVM_NONE)
                end
            <%}%>
        join
    endtask: start_sequence

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase

endclass: chi_subsys_owo_test
