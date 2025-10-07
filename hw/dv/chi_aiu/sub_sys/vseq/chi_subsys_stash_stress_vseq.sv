class chi_subsys_stash_stress_vseq extends chi_subsys_base_vseq;
    `uvm_object_utils(chi_subsys_stash_stress_vseq)
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        chi_subsys_stash_stress_seq m_stash_stress_seq<%=idx%>;
    <%}%>

    bit is_non_secure_access;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;

    function new(string name = "chi_subsys_stash_stress_vseq");
        super.new(name);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            m_stash_stress_seq<%=idx%> = chi_subsys_stash_stress_seq::type_id::create("m_stash_stress_seq<%=idx%>");
        <%}%>
        is_non_secure_access = $urandom_range(1,0);
    endfunction: new

    virtual task body();
        `uvm_info("VSEQ", "Starting chi_subsys_stash_stress_vseq", UVM_LOW);
        super.body();
        addr = m_addr_mgr.gen_coh_addr(0, 1);
        if ($urandom_range(1,0)) begin
            addr[3:0] = $urandom_range(15,1);
        end
        fork
            <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                begin
                    repeat(chi_num_trans) begin
                        m_stash_stress_seq<%=idx%>.directed_addr_mailbox.put(addr);
                        m_stash_stress_seq<%=idx%>.directed_is_non_secure_access_mailbox.put(is_non_secure_access);
                        m_stash_stress_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                    end
                end
            <%}%>
        join
        `uvm_info("VSEQ", "Finished chi_subsys_stash_stress_vseq", UVM_LOW);
    endtask: body

endclass: chi_subsys_stash_stress_vseq