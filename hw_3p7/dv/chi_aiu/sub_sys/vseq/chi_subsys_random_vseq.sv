class chi_subsys_random_vseq extends chi_subsys_base_vseq;
    `uvm_object_utils(chi_subsys_random_vseq)
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        chi_subsys_random_seq m_random_seq<%=idx%>;
    <%}%>
    int qos[int];
    int chiaiu_en[int];
    int init_all_cache = 0;

    protected bit to_execute_body_method_of_chi_subsys_random_vseq=1; // Knob for extended sequence to decide whether body method of base sequence to be run or not. 

    function new(string name = "chi_subsys_random_vseq");
        super.new(name);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            m_random_seq<%=idx%> = chi_subsys_random_seq::type_id::create("m_random_seq<%=idx%>");
            m_random_seq<%=idx%>.disable_dvmop = disable_dvmop;
        <%}%>
    endfunction: new

    virtual task body();
        `uvm_info("VSEQ", "Starting chi_subsys_random_vseq", UVM_LOW);
        super.body();
        if(to_execute_body_method_of_chi_subsys_random_vseq) begin
        fork
            <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                begin
                  if(chiaiu_en[<%=idx%>]) begin
                    repeat(chi_num_trans) begin
                        m_random_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                    end
                  end
                end
            <%}%>
        join
        end
        `uvm_info("VSEQ", "Finished chi_subsys_random_vseq", UVM_LOW);
    endtask: body

endclass: chi_subsys_random_vseq
