class chi_subsys_directed_atomic_self_check_vseq extends chi_subsys_random_vseq;
    `uvm_object_utils(chi_subsys_directed_atomic_self_check_vseq)

    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        chi_subsys_directed_atomic_self_check_seq m_directed_wr_rd_seq<%=idx%>;
    <%}%>
    bit is_non_secure_access;
    bit[ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] addr;

    function new(string name = "chi_subsys_directed_atomic_self_check_vseq");
        super.new(name);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            m_directed_wr_rd_seq<%=idx%> = chi_subsys_directed_atomic_self_check_seq::type_id::create("m_directed_wr_rd_seq<%=idx%>");
        <%}%>
        is_non_secure_access = $urandom_range(1,0);
        to_execute_body_method_of_chi_subsys_random_vseq = 0;
    endfunction: new

    virtual task body();
        `uvm_info("VSEQ", "Starting chi_subsys_directed_atomic_self_check_vseq", UVM_LOW);
        super.body();

        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            begin
                repeat(chi_num_trans) begin
                    m_directed_wr_rd_seq<%=idx%>.chiaiu_idx = <%=idx%>;
                    m_directed_wr_rd_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                end
            end
        <%}%>

        `uvm_info("VSEQ", "Finished chi_subsys_directed_atomic_self_check_vseq", UVM_LOW);
    endtask: body

endclass: chi_subsys_directed_atomic_self_check_vseq
