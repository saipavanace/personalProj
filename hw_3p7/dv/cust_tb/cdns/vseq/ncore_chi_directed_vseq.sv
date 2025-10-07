class ncore_chi_directed_vseq extends ncore_base_vseq;
    `uvm_object_utils(ncore_chi_directed_vseq)

    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        ncore_chi_base_seq m_chi_base_seq<%=idx%>;
    <%}%>

    addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t  csr_q[$];

    function new(string name = "ncore_chi_directed_vseq");
        super.new(name);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                m_chi_base_seq<%=idx%> = ncore_chi_base_seq::type_id::create("m_chi_base_seq<%=idx%>");
        <%}%>
    endfunction: new
  
    virtual task body();
        this.csrq = addr_trans_mgr_pkg::addrMgrConst::get_all_gpra();
        csr_q = csrq.find (s) with(s.unit ==  addrMgrConst::DMI);
        `uvm_info("VSEQ", "Starting ncore_chi_directed_vseq", UVM_LOW);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            begin
                m_chi_base_seq<%=idx%>.sequence_length = 1;
                m_chi_base_seq<%=idx%>.start_addr       = addr_trans_mgr_pkg::addrMgrConst::memregions_info[<%=idx%>%csr_q.size].start_addr + 'h3000*(<%=idx%>/csr_q.size);
                m_chi_base_seq<%=idx%>.tx_OpCode         = DENALI_CHI_REQOPCODE_WriteNoSnpPtl;
                m_chi_base_seq<%=idx%>.txn_id           = <%=idx%>;
                m_chi_base_seq<%=idx%>.start(chi_sequencer<%=idx%>);
                #1us;

                m_chi_base_seq<%=idx%>.sequence_length = 1;
                m_chi_base_seq<%=idx%>.start_addr       = addr_trans_mgr_pkg::addrMgrConst::memregions_info[<%=idx%>%csr_q.size].start_addr + 'h3000*(<%=idx%>/csr_q.size);
                m_chi_base_seq<%=idx%>.tx_OpCode         = DENALI_CHI_REQOPCODE_ReadNoSnp;
                m_chi_base_seq<%=idx%>.txn_id           = <%=idx%>;
                m_chi_base_seq<%=idx%>.start(chi_sequencer<%=idx%>);
            end
        <%}%>
        `uvm_info("VSEQ", "Finished ncore_chi_directed_vseq", UVM_LOW);
    endtask: body
  
endclass: ncore_chi_directed_vseq


