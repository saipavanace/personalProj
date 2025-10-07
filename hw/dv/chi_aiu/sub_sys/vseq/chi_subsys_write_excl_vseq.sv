class chi_subsys_write_excl_vseq extends chi_subsys_base_vseq;
    `uvm_object_utils(chi_subsys_write_excl_vseq)
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        chi_subsys_write_excl_seq m_write_excl_seq<%=idx%>;
    <%}%>
    bit is_non_secure_access;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr_chi0;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr_chi1;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] mid_addr;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;

    function new(string name = "chi_subsys_write_excl_vseq");
        super.new(name);
        is_non_secure_access = $urandom_range(1,0);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            m_write_excl_seq<%=idx%> = chi_subsys_write_excl_seq::type_id::create("m_write_excl_seq<%=idx%>");
        <%}%>
    endfunction: new

    virtual task body();
        bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;

        `uvm_info("VSEQ", "Starting chi_subsys_write_excl_vseq", UVM_LOW);
        super.body();
	k_directed_excl = m_mstr_seq_cfg.en_excl_txn;
        // k_directed_lpid = 2;
        fork
            begin
                repeat(chi_num_trans) begin
                    k_directed_lpid = $urandom_range((<%=obj.AiuInfo[obj.Id].nProcs%>-1), 0);
                    is_non_secure_access = $urandom_range(1,0);
                    addr = m_addr_mgr.gen_noncoh_addr(0, 1);

                    // addr = m_addr_mgr.gen_noncoh_addr(0, 1);

                    foreach (ncoreConfigInfo::memregions_info[region]) begin
                        mid_addr = (ncoreConfigInfo::memregions_info[region].start_addr + ncoreConfigInfo::memregions_info[region].end_addr)/2;
                        
                        // if address belongs to this particular region?
                        if (addr >= ncoreConfigInfo::memregions_info[region].start_addr && addr <= ncoreConfigInfo::memregions_info[region].end_addr) begin
                            if (addr <= mid_addr) begin // Address belongs to CHI0
                                addr_chi0 = addr;
                                addr_chi1 = addr + (mid_addr - ncoreConfigInfo::memregions_info[region].start_addr + 1); // shift addr to push it to CHI1 region
                            end else begin // address belongs to CHI1
                                addr_chi1 = addr;
                                addr_chi0 = addr - (mid_addr - ncoreConfigInfo::memregions_info[region].start_addr + 1); // shift addr to push it to CHI0 region
                            end
                            break;
                        end
                    end
                    m_write_excl_seq0.directed_addr_mailbox.put(addr_chi0);
                    m_write_excl_seq0.directed_is_non_secure_access_mailbox.put(is_non_secure_access);
                    m_write_excl_seq0.directed_snp_attr_is_snoopable_mailbox.put(0);
                    m_write_excl_seq0.disable_all_weights();
                    m_write_excl_seq0.readnosnp_wt = 1;
                    m_write_excl_seq0.start(rn_xact_seqr0);
                    #250ns;
                    m_write_excl_seq0.directed_addr_mailbox.put(addr_chi0);
                    m_write_excl_seq0.directed_is_non_secure_access_mailbox.put(is_non_secure_access);
                    m_write_excl_seq0.directed_snp_attr_is_snoopable_mailbox.put(0);
                    m_write_excl_seq0.disable_all_weights();
                    m_write_excl_seq0.writenosnpptl_wt = 1;
                    m_write_excl_seq0.writenosnpfull_wt = 1;
                    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                        m_write_excl_seq0.writenosnpzero_wt = 1;
                    <%}%>
                    m_write_excl_seq0.start(rn_xact_seqr0);
                    #250ns;
                end
            end
        join
        `uvm_info("VSEQ", "Finished chi_subsys_write_excl_vseq", UVM_LOW);
    endtask: body

endclass: chi_subsys_write_excl_vseq
