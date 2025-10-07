typedef enum {RSHARED, RPREFERUNIQUE, WRITEEVICTOREVICT} m_txn_type;

class chi_subsys_wrevctorevct_vseq extends chi_subsys_base_vseq;

    `uvm_object_utils(chi_subsys_wrevctorevct_vseq)

    chi_subsys_pkg::chi_subsys_wrevctorevct_seq      m_wrevctorevct_seq;
    bit is_non_secure_access;
    m_txn_type selected_cmd;

    function new(string name = "chi_subsys_wrevctorevct_vseq");
        super.new(name);
        m_wrevctorevct_seq = chi_subsys_pkg::chi_subsys_wrevctorevct_seq::type_id::create("m_wrevctorevct_seq");
        selected_cmd = ($urandom_range(1,0)) ? RPREFERUNIQUE : RSHARED;
    endfunction: new

    virtual task body();
        bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;
        bit isUnique;
        bit isClean;
        bit valid;
        `uvm_info("WrEvctOrEvct VSEQ", "Starting WriteEvictOrEvict vseq", UVM_LOW);
        super.body();

	repeat(chi_num_trans) begin
            is_non_secure_access = $urandom_range(1,0);
            addr = m_addr_mgr.gen_coh_addr(0, 1);
            l_send_txn(selected_cmd, addr, 0);
	      `ifdef SVT_CHI_ISSUE_E_ENABLE
              l_send_txn(WRITEEVICTOREVICT, addr, 0);
	      `endif
            <% if(obj.nCHIs > 1) { %>
            addr = m_addr_mgr.gen_coh_addr(0, 1);
              l_send_txn(RSHARED, addr, 1);
            <% } %>
	end
        `uvm_info("WrEvctOrEvct VSEQ", "Finished WriteEvictOrEvict vseq", UVM_LOW);
    endtask: body

    task l_send_txn(m_txn_type txn_type, bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr, bit node);

        m_wrevctorevct_seq.directed_addr_mailbox.put(addr);
        m_wrevctorevct_seq.directed_is_non_secure_access_mailbox.put(is_non_secure_access);
        m_wrevctorevct_seq.disable_all_weights();
        if (txn_type == RSHARED) begin
            m_wrevctorevct_seq.readshared_wt = 1;
        end 
	`ifdef SVT_CHI_ISSUE_E_ENABLE
        else if(txn_type == RPREFERUNIQUE) begin
            m_wrevctorevct_seq.readpreferunique_wt = 1;
        end else begin
            m_wrevctorevct_seq.writeevictorevict_wt = 1;
        end
	`endif
        if (node) begin
        <% if(obj.nCHIs > 1) { %>
            m_wrevctorevct_seq.start(rn_xact_seqr1);
        <% } %>
        end else begin
            m_wrevctorevct_seq.start(rn_xact_seqr0);
        end
        #250ns;
    endtask: l_send_txn

endclass: chi_subsys_wrevctorevct_vseq
