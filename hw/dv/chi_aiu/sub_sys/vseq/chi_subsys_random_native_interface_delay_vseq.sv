class chi_subsys_random_native_interface_delay_vseq extends chi_subsys_base_vseq;
    `uvm_object_utils(chi_subsys_random_native_interface_delay_vseq)
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        chi_subsys_random_seq m_random_seq<%=idx%>;
    <%}%>
    int qos[int];
    int chiaiu_en[int];
    int init_all_cache = 0;


    function new(string name = "chi_subsys_random_native_interface_delay_vseq");
        super.new(name);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            m_random_seq<%=idx%> = chi_subsys_random_seq::type_id::create("m_random_seq<%=idx%>");
        <%}%>
    endfunction: new

    virtual task body();
        `uvm_info("VSEQ", "Starting chi_subsys_random_native_interface_delay_vseq", UVM_LOW);
        super.body();
  	en_delay = 1;
        fork
            <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                begin
                    repeat(chi_num_trans) begin
                        m_random_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                    end
                end
            <%}%>
        join
        `uvm_info("VSEQ", "Finished chi_subsys_random_native_interface_delay_vseq", UVM_LOW);
    endtask: body

endclass: chi_subsys_random_native_interface_delay_vseq
