class chi_subsys_atomic_stress_vseq extends chi_subsys_base_vseq;
    `uvm_object_utils(chi_subsys_atomic_stress_vseq)
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        chi_subsys_atomic_stress_seq m_atomic_stress_seq<%=idx%>;
    <%}%>

    bit is_non_secure_access;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr_chi0;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr_chi1;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] mid_addr;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;

    function new(string name = "chi_subsys_atomic_stress_vseq");
        super.new(name);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            m_atomic_stress_seq<%=idx%> = chi_subsys_atomic_stress_seq::type_id::create("m_atomic_stress_seq<%=idx%>");
        <%}%>
        is_non_secure_access = $urandom_range(1,0);
    endfunction: new

    virtual task body();
        `uvm_info("VSEQ", "Starting chi_subsys_atomic_stress_vseq", UVM_LOW);
        super.body();

        //if ($urandom_range(1,0)) begin // randomly select a coherent or non-coherent address //Remove CONC-13882
            addr = m_addr_mgr.gen_coh_addr(0, 1);
            if ($urandom_range(1,0)) begin
                addr[3:0] = $urandom_range(15,1);
            end
            fork
                <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                    begin
                        repeat(chi_num_trans) begin
                            m_atomic_stress_seq<%=idx%>.directed_addr_mailbox.put(addr);
                            m_atomic_stress_seq<%=idx%>.directed_is_non_secure_access_mailbox.put(is_non_secure_access);
                            m_atomic_stress_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                        end
                    end
                <%}%>
            join
        //end else begin
        //    addr = m_addr_mgr.gen_noncoh_addr(0, 1);

        //    foreach (ncoreConfigInfo::memregions_info[region]) begin
        //        mid_addr = (ncoreConfigInfo::memregions_info[region].start_addr + ncoreConfigInfo::memregions_info[region].end_addr)/2;
        //        
        //        // if address belongs to this particular region?
        //        if (addr >= ncoreConfigInfo::memregions_info[region].start_addr && addr <= ncoreConfigInfo::memregions_info[region].end_addr) begin
        //            if (addr <= mid_addr) begin // Address belongs to CHI0
        //                addr_chi0 = addr;
        //                addr_chi1 = addr + (mid_addr - ncoreConfigInfo::memregions_info[region].start_addr + 1); // shift addr to push it to CHI1 region
        //            end else begin // address belongs to CHI1
        //                addr_chi1 = addr;
        //                addr_chi0 = addr - (mid_addr - ncoreConfigInfo::memregions_info[region].start_addr + 1); // shift addr to push it to CHI0 region
        //            end
        //            break;
        //        end
        //    end

        //    if ($urandom_range(1,0)) begin
        //        addr_chi0[3:0] = $urandom_range(15,1);
        //    end

        //    if ($urandom_range(1,0)) begin
        //        addr_chi1[3:0] = $urandom_range(15,1);
        //    end

        //    fork
        //        begin
        //            for (int i=0; i<chi_num_trans; i++) begin
        //                m_atomic_stress_seq0.directed_addr_mailbox.put(addr_chi0);
        //                m_atomic_stress_seq0.directed_is_non_secure_access_mailbox.put(is_non_secure_access);
        //                m_atomic_stress_seq0.start(rn_xact_seqr0);
        //            end
        //        end
        //        <%if (obj.nCHIs > 1) { %>
        //        begin
        //            for (int i=0; i<chi_num_trans; i++) begin
        //                m_atomic_stress_seq1.directed_addr_mailbox.put(addr_chi1);
        //                m_atomic_stress_seq1.directed_is_non_secure_access_mailbox.put(is_non_secure_access);
        //                m_atomic_stress_seq1.start(rn_xact_seqr1);
        //            end
        //        end
        //        <%}%>
        //    join
        //end

        
        `uvm_info("VSEQ", "Finished chi_subsys_atomic_stress_vseq", UVM_LOW);
    endtask: body

endclass: chi_subsys_atomic_stress_vseq
