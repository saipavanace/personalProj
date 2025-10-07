typedef enum {RDSHARED, RDPREFERUNIQUE, MAKERDUNIQUE} t_txn;

class chi_subsys_mkrdunq_error_vseq extends chi_subsys_base_vseq;

    `uvm_object_utils(chi_subsys_mkrdunq_error_vseq)

    chi_subsys_pkg::chi_subsys_mkrdunq_error_seq      m_mkrdunq_error_seq;
    bit is_exclusive_mkrdunq;
    bit is_exclusive_pass_or_fail;
    bit is_non_secure_access;
    int lpid_value;
    t_txn selected_cmd;

    function new(string name = "chi_subsys_mkrdunq_error_vseq");
        super.new(name);
        is_exclusive_mkrdunq = 1; //$urandom_range(1,0);
        is_exclusive_pass_or_fail = 0; //$urandom_range(1,0);
        is_non_secure_access = $urandom_range(1,0);
        lpid_value = $urandom_range(<%=obj.AiuInfo[obj.Id].nProcs%>, 0);
        `uvm_info("MkRdUnq VSEQ", $sformatf("Is Exclusive Access? : %0d, Is exclusive pass (if excl access)? : %0d", is_exclusive_mkrdunq, is_exclusive_pass_or_fail), UVM_MEDIUM);
        m_mkrdunq_error_seq = chi_subsys_pkg::chi_subsys_mkrdunq_error_seq::type_id::create("m_mkrdunq_error_seq");
        selected_cmd = ($urandom_range(1,0)) ? RDPREFERUNIQUE : RDSHARED;
    endfunction: new

    virtual task body();
        bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;
        bit isUnique;
        bit isClean;
        bit valid;
        `uvm_info("MkRdUnq VSEQ", "Starting MakeReadUnique error vseq", UVM_LOW);
        super.body();

        addr = m_addr_mgr.gen_coh_addr(0, 1);
        l_send_txn(selected_cmd, addr, 0);
	`ifdef SVT_CHI_ISSUE_E_ENABLE
        l_send_txn(MAKERDUNIQUE, addr, 0);
	`endif
        <% if(obj.nCHIs > 1) { %>
          l_send_txn(selected_cmd, addr, 1);
        <% } %>
        `uvm_info("MkRdUnq VSEQ", "Finished MakeReadUnique error vseq", UVM_LOW);
    endtask: body

    task l_send_txn(t_txn txn_type, bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr, bit node);

        m_mkrdunq_error_seq.directed_addr_mailbox.put(addr);
        m_mkrdunq_error_seq.directed_is_non_secure_access_mailbox.put(is_non_secure_access);
        m_mkrdunq_error_seq.disable_all_weights();
        if (txn_type == RDSHARED) begin
            m_mkrdunq_error_seq.readshared_wt = 1;
        end 
        `ifdef SVT_CHI_ISSUE_E_ENABLE
            else if(txn_type == RDPREFERUNIQUE) begin
                m_mkrdunq_error_seq.readpreferunique_wt = 1;
            end else begin
                m_mkrdunq_error_seq.makereadunique_wt = 1;
            end
        `endif
        k_directed_excl = is_exclusive_mkrdunq;
        k_directed_lpid = is_exclusive_pass_or_fail ? lpid_value : (++lpid_value);
        if (node) begin
            <%if(obj.nCHIs > 1){%>
                m_mkrdunq_error_seq.start(rn_xact_seqr1);
            <%}%>
        end else begin
            m_mkrdunq_error_seq.start(rn_xact_seqr0);
        end
        #250ns;
    endtask: l_send_txn

endclass: chi_subsys_mkrdunq_error_vseq
