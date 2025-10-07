class ncore_cache_access_vseq extends ncore_base_vseq;
    `uvm_object_utils(ncore_cache_access_vseq)

        bit unconnected;
        bit [2:0] unit_unconnected;
        bit [ncoreConfigInfo::W_SEC_ADDR -1: 0] addr;
        int slave_id;
        ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t  csr_q[$];

        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            ncore_chi_base_seq m_chi_base_seq<%=idx%>;
        <%}%>

        <%for(pidx = 0; pidx < obj.ioaiu_nb; pidx++) {%>
            ncore_axi_base_seq m_ace_base_seq<%= pidx %>;
        <%}%>

        function new(string name = "ncore_cache_access_vseq");
            super.new(name);
            <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                m_chi_base_seq<%=idx%> = ncore_chi_base_seq::type_id::create("m_chi_base_seq<%=idx%>");
            <%}%>
            <%for(pidx = 0; pidx < obj.ioaiu_nb; pidx++) {%>
                m_ace_base_seq<%= pidx %> = ncore_axi_base_seq::type_id::create("m_ace_base_seq<%=pidx%>");
            <%}%>
        endfunction : new
    
        virtual task body();
            this.csrq = ncore_config_pkg::ncoreConfigInfo::get_all_gpra();
            csr_q = csrq.find (s) with(s.unit ==  ncoreConfigInfo::DMI);
            `uvm_info("VSEQ", "Starting ncore_cache_access_vseq", UVM_LOW);

        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            begin
                m_chi_base_seq<%=idx%>.start_addr  = ncore_config_pkg::ncoreConfigInfo::memregions_info[<%=idx%>%csr_q.size].start_addr + 'h3000*(<%=idx%>/csr_q.size);
                m_chi_base_seq<%=idx%>.sequence_length  =  1;
                m_chi_base_seq<%=idx%>.txn_id           = <%=idx%>;
                m_chi_base_seq<%=idx%>.tx_OpCode    = DENALI_CHI_REQOPCODE_WriteUniqueFull;
                m_chi_base_seq<%=idx%>.cache_value = 6'h1e;
                m_chi_base_seq<%=idx%>.start(chi_sequencer<%=idx%>);
                #1us;

                m_chi_base_seq<%=idx%>.start_addr  = ncore_config_pkg::ncoreConfigInfo::memregions_info[<%=idx%>%csr_q.size].start_addr + 'h3000*(<%=idx%>/csr_q.size);
                m_chi_base_seq<%=idx%>.sequence_length  =  1;
                m_chi_base_seq<%=idx%>.txn_id           = <%=idx%>;
                m_chi_base_seq<%=idx%>.tx_OpCode    = DENALI_CHI_REQOPCODE_ReadOnce;
                m_chi_base_seq<%=idx%>.cache_value = 6'h1e;
                m_chi_base_seq<%=idx%>.start(chi_sequencer<%=idx%>);
            end
        <%}%>

        <%var sidx = 0;%>
        <% for(pidx = 0; pidx < obj.ioaiu_nb; pidx++){%>
                <%var aiuinfo_idx = obj.IoaiuInfo[pidx].aiuinfo_idx;%>
                    begin
                        addr = ncore_config_pkg::ncoreConfigInfo::memregions_info[<%=sidx%>%csr_q.size].start_addr + 'h3000*(<%=sidx%>/csr_q.size);
                        unconnected = ncoreConfigInfo::check_unmapped_add(.addr(addr),.agent_id(<%=obj.AiuInfo[aiuinfo_idx].FUnitId%>),.unit_unconnected(unit_unconnected));
                        if (!unconnected) begin
                            <%if(obj.AiuInfo[aiuinfo_idx].fnNativeInterface == 'AXI4' || obj.AiuInfo[aiuinfo_idx].fnNativeInterface == 'AXI5') {%>
                                m_ace_base_seq<%=sidx%>.protocol = "AXI4" ;
                                m_ace_base_seq<%=sidx%>.start_addr  = ncore_config_pkg::ncoreConfigInfo::memregions_info[<%=sidx%>%csr_q.size].start_addr + 'h3000*(<%=sidx%>/csr_q.size);
                                m_ace_base_seq<%=sidx%>.sequence_length = 1;
                                m_ace_base_seq<%=sidx%>.command = "WRITE";
                                m_ace_base_seq<%=sidx%>.start(axi_sequencer<%=sidx%>);
                            #1us;
                                m_ace_base_seq<%=sidx%>.protocol = "AXI4" ;
                                m_ace_base_seq<%=sidx%>.start_addr  = ncore_config_pkg::ncoreConfigInfo::memregions_info[<%=sidx%>%csr_q.size].start_addr + 'h3000*(<%=sidx%>/csr_q.size);
                                m_ace_base_seq<%=sidx%>.sequence_length = 1;
                                m_ace_base_seq<%=sidx%>.Read_txn    = DENALI_CDN_AXI_READSNOOP_ReadOnce;
                                m_ace_base_seq<%=sidx%>.command = "READ";
                                m_ace_base_seq<%=sidx%>.start(axi_sequencer<%=sidx%>);
                        end
                            <%}else{%>
                                m_ace_base_seq<%=sidx%>.start_addr  = ncore_config_pkg::ncoreConfigInfo::memregions_info[<%=sidx%>%csr_q.size].start_addr + 'h3000*(<%=sidx%>/csr_q.size);
                                m_ace_base_seq<%=sidx%>.sequence_length = 1;
                                m_ace_base_seq<%=sidx%>.command = "WRITE";
                                m_ace_base_seq<%=sidx%>.Write_txn   = DENALI_CDN_AXI_WRITESNOOP_WriteUnique;
                                m_ace_base_seq<%=sidx%>.cache_value = 6'hf;
                                m_ace_base_seq<%=sidx%>.start(axi_sequencer<%=sidx%>);
                                #1us;
                                m_ace_base_seq<%=sidx%>.start_addr  = ncore_config_pkg::ncoreConfigInfo::memregions_info[<%=sidx%>%csr_q.size].start_addr + 'h3000*(<%=sidx%>/csr_q.size);
                                m_ace_base_seq<%=sidx%>.sequence_length = 1;
                                m_ace_base_seq<%=sidx%>.command = "READ";
                                m_ace_base_seq<%=sidx%>.Read_txn    = DENALI_CDN_AXI_READSNOOP_ReadOnce;
                                m_ace_base_seq<%=sidx%>.cache_value = 6'hf;
                                m_ace_base_seq<%=sidx%>.start(axi_sequencer<%=sidx%>);
                        end
                            <%} %>
                    end
        <% sidx++;%>
        <%}%>
        `uvm_info("VSEQ", "Finished ncore_cache_access_vseq", UVM_LOW);
        endtask : body
endclass : ncore_cache_access_vseq


