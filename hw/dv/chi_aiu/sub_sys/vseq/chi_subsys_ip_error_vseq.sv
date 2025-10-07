class chi_subsys_ip_error_vseq extends chi_subsys_base_vseq;
    `uvm_object_utils(chi_subsys_ip_error_vseq)
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        chi_subsys_ip_error_seq m_ip_error_seq<%=idx%>;
    <%}%>

    function new(string name = "chi_subsys_ip_error_vseq");
        super.new(name);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            m_ip_error_seq<%=idx%> = chi_subsys_ip_error_seq::type_id::create("m_ip_error_seq<%=idx%>");
        <%}%>
    endfunction: new

    virtual task body();
        `uvm_info("VSEQ", "Starting chi_subsys_ip_error_vseq", UVM_LOW);
        super.body();
        fork
            <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                begin
                    repeat(10) begin
                        m_ip_error_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                    end
                end
            <%}%>
        join
        `uvm_info("VSEQ", "Finished chi_subsys_ip_error_vseq", UVM_LOW);
    endtask: body

endclass: chi_subsys_ip_error_vseq