class chi_subsys_cmo_vseq extends chi_subsys_base_vseq;
    `uvm_object_utils(chi_subsys_cmo_vseq)

    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        chi_subsys_cmo_seq m_cmo_seq<%=idx%>;
    <%}%>

    bit is_non_secure_access;
    //int num_chi_txns;
    int chi_num_trans;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;

    function new(string name = "chi_subsys_cmo_vseq");
        super.new(name);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            m_cmo_seq<%=idx%> = chi_subsys_cmo_seq::type_id::create("m_cmo_seq<%=idx%>");
        <%}%>
    is_non_secure_access = $urandom_range(1,0);
    endfunction: new

    virtual task body();
        `uvm_info("VSEQ", "Starting chi_subsys_cmo_vseq", UVM_LOW);
        super.body();
        addr = m_addr_mgr.gen_coh_addr(0, 1);

        fork
            <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                begin
                    for (int i=0; i<1000; i++) begin
                        m_cmo_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                    end
                end
            <%}%>
        join

        `uvm_info("VSEQ", "Finished chi_subsys_cmo_vseq", UVM_LOW);
    endtask: body

endclass: chi_subsys_cmo_vseq







