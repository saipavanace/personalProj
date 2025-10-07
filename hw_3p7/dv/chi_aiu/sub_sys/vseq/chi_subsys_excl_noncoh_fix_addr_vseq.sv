
class chi_subsys_excl_noncoh_fix_addr_vseq extends chi_subsys_base_vseq;
    `uvm_object_utils(chi_subsys_excl_noncoh_fix_addr_vseq)
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        chi_subsys_write_excl_seq m_excl_seq<%=idx%>;
    	int pick_addr<%=idx%>;
    	bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr<%=idx%>;
    <%}%>
    bit is_non_secure_access;
    bit is_nc_dmi_available;
    int addrq_size;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] noncoh_addrq[$];
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] temp_addr;

    function new(string name = "chi_subsys_excl_noncoh_fix_addr_vseq");
        super.new(name);
        is_non_secure_access = $urandom_range(1,0);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            m_excl_seq<%=idx%> = chi_subsys_write_excl_seq::type_id::create("m_excl_seq<%=idx%>");
        <%}%>
    endfunction: new

    virtual task body();
        `uvm_info("VSEQ", "Starting chi_subsys_excl_noncoh_fix_addr_vseq", UVM_LOW);
        super.body();
        k_directed_excl = 1;
        // k_directed_lpid = 2;
	
	foreach (addrMgrConst::memregions_info[region]) begin
	    if(addrMgrConst::is_dmi_addr(addrMgrConst::memregions_info[region].start_addr) && addrMgrConst::get_addr_gprar_nc(addrMgrConst::memregions_info[region].start_addr))begin
	    	is_nc_dmi_available = 1;
		break;
	    end
	end
	do begin
            temp_addr = m_addr_mgr.gen_noncoh_addr(0, 1);
	    foreach (addrMgrConst::memregions_info[region]) begin
                if (temp_addr >= addrMgrConst::memregions_info[region].start_addr && temp_addr <= addrMgrConst::memregions_info[region].end_addr) begin
                    if (addrMgrConst::memregions_info[region].hut == DMI && is_nc_dmi_available) begin // Address belongs to noncoh DMI 
	    	    	noncoh_addrq.push_back(temp_addr);
	    	    	addrq_size++;
                        break;
                    end else if(!is_nc_dmi_available) begin
	    	    	noncoh_addrq.push_back(temp_addr);
	    	    	addrq_size++;
                        break;
		    end
                end
            end
        end while (addrq_size < 10);
        fork
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            begin
                repeat(chi_num_trans) begin
                    k_directed_lpid = $urandom_range((<%=obj.AiuInfo[obj.Id].nProcs%>-1), 0);
                    is_non_secure_access = $urandom_range(1,0);
                    pick_addr<%=idx%> = $urandom_range(noncoh_addrq.size()-1);
                    addr<%=idx%> = noncoh_addrq[pick_addr<%=idx%>];

                    m_excl_seq<%=idx%>.directed_addr_mailbox.put(addr<%=idx%>);
                    m_excl_seq<%=idx%>.directed_is_non_secure_access_mailbox.put(is_non_secure_access);
                    m_excl_seq<%=idx%>.directed_snp_attr_is_snoopable_mailbox.put(0);
                    m_excl_seq<%=idx%>.disable_all_weights();
                    m_excl_seq<%=idx%>.readnosnp_wt = 1;
                    m_excl_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                    #250ns;
                    m_excl_seq<%=idx%>.directed_addr_mailbox.put(addr<%=idx%>);
                    m_excl_seq<%=idx%>.directed_is_non_secure_access_mailbox.put(is_non_secure_access);
                    m_excl_seq<%=idx%>.directed_snp_attr_is_snoopable_mailbox.put(0);
                    m_excl_seq<%=idx%>.disable_all_weights();
                    m_excl_seq<%=idx%>.writenosnpptl_wt = 1;
                    m_excl_seq<%=idx%>.writenosnpfull_wt = 1;
                    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                        m_excl_seq<%=idx%>.writenosnpzero_wt = 1;
                    <%}%>
                    m_excl_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                    #250ns;
                end
            end
        <%}%>
        join
        `uvm_info("VSEQ", "Finished chi_subsys_excl_noncoh_fix_addr_vseq", UVM_LOW);
    endtask: body

endclass: chi_subsys_excl_noncoh_fix_addr_vseq
