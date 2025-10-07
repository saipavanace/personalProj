import chi_ss_helper_pkg::*;

class chi_subsys_base_vseq extends svt_chi_system_base_virtual_sequence;

    `uvm_object_utils(chi_subsys_base_vseq)

    <%for(var idx = 0; idx < obj.nCHIs; idx++) { %>
        svt_chi_rn_transaction_sequencer rn_xact_seqr<%=idx%>;
    <%}%>

    chi_subsys_mstr_seq_cfg m_mstr_seq_cfg;

    addr_trans_mgr m_addr_mgr;
    protected static int chi_num_trans = 100;
    bit disable_dvmop = 0;

    function new(string name = "chi_subsys_base_vseq");
        super.new(name);
        m_addr_mgr = addr_trans_mgr::get_instance();
        m_mstr_seq_cfg = chi_subsys_mstr_seq_cfg::type_id::create("m_mstr_seq_cfg");
    endfunction: new

    virtual task body();
        super.body();
    endtask: body

    virtual task post_body();
        super.post_body();
        disable_directed_constraints();
    endtask: post_body

    task getCacheState(longint addr, int node);
        bit unq, cln;
        if(get_rn_cache_status(node, addr, unq, cln)) begin
            case ({unq, cln})
                2'b00: `uvm_info("Cache State", $psprintf("Cache state of addr:0x%0h changed to SD for CHI%0d", addr, node), UVM_MEDIUM)
                2'b01: `uvm_info("Cache State", $psprintf("Cache state of addr:0x%0h changed to SC for CHI%0d", addr, node), UVM_MEDIUM)
                2'b10: `uvm_info("Cache State", $psprintf("Cache state of addr:0x%0h changed to UD for CHI%0d", addr, node), UVM_MEDIUM)
                default: `uvm_info("Cache State", $psprintf("Cache state of addr:0x%0h changed to UC for CHI%0d", addr, node), UVM_MEDIUM)
            endcase
        end else begin
            `uvm_info("Cache State", $psprintf("Cache state of addr:0x%0h changed to IX for CHI%0d", addr, node), UVM_MEDIUM);
        end
    endtask: getCacheState

    function void set_txn_count(int txn);
        chi_num_trans = txn;
    endfunction : set_txn_count

    function int get_txn_count();
        return chi_num_trans;
    endfunction : get_txn_count

endclass: chi_subsys_base_vseq
