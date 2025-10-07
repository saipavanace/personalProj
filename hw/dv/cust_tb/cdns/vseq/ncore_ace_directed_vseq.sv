class ncore_ace_directed_vseq extends ncore_base_vseq;
    `uvm_object_utils(ncore_ace_directed_vseq)

        bit unconnected;
        bit [2:0] unit_unconnected;
        bit [ncoreConfigInfo::W_SEC_ADDR -1: 0] addr;
        int slave_id;
        ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t  csr_q[$];

    <% for(pidx = 0; pidx < obj.ioaiu_nb-obj.axiaiu_nb; pidx++) {%>
        ncore_axi_base_seq m_ace_directed_seq<%= pidx %>;
    <% } %>

    function new(string name = "ncore_ace_directed_vseq");
        super.new(name);
        <%for(pidx = 0; pidx < obj.ioaiu_nb-obj.axiaiu_nb; pidx++) {%>
            m_ace_directed_seq<%= pidx %> = ncore_axi_base_seq::type_id::create("m_ace_directed_seq<%=pidx%>");
        <%}%>
    endfunction : new
    
    virtual task body();
        this.csrq = ncore_config_pkg::ncoreConfigInfo::get_all_gpra();
        csr_q = csrq.find (s) with(s.unit ==  ncoreConfigInfo::DMI);
        `uvm_info("VSEQ", "Starting ncore_ace_directed_vseq", UVM_LOW);
        <%pidx = 0;
        for(let idx = 0; idx < obj.nAIUs; idx++) {%>
            <%if(!obj.AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
                <%if(obj.AiuInfo[idx].fnNativeInterface == 'ACE'|| obj.AiuInfo[idx].fnNativeInterface == 'ACE5'){%>
                <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                        begin
                            addr = ncore_config_pkg::ncoreConfigInfo::memregions_info[<%=pidx%>%csr_q.size].start_addr + 'h3000*(<%=pidx%>/csr_q.size);
                            unconnected = ncoreConfigInfo::check_unmapped_add(.addr(addr),.agent_id(<%=obj.AiuInfo[idx].FUnitId%>),.unit_unconnected(unit_unconnected));
                            if (!unconnected) begin
                                m_ace_directed_seq<%=pidx%>.start_addr = ncore_config_pkg::ncoreConfigInfo::memregions_info[<%=pidx%>%csr_q.size].start_addr + 'h3000*(<%=pidx%>/csr_q.size);
                                m_ace_directed_seq<%=pidx%>.sequence_length = 1;
                                m_ace_directed_seq<%=pidx%>.command = "WRITE";
                                m_ace_directed_seq<%=pidx%>.Write_txn = DENALI_CDN_AXI_WRITESNOOP_WriteUnique;
                                m_ace_directed_seq<%=pidx%>.Domain_t = DENALI_CDN_AXI_DOMAIN_NON_SHAREABLE;
                                m_ace_directed_seq<%=pidx%>.start(axi_sequencer<%=pidx%>);
                                #1us;

                                m_ace_directed_seq<%=pidx%>.start_addr = ncore_config_pkg::ncoreConfigInfo::memregions_info[<%=pidx%>%csr_q.size].start_addr + 'h3000*(<%=pidx%>/csr_q.size);
                                m_ace_directed_seq<%=pidx%>.sequence_length = 1;
                                m_ace_directed_seq<%=pidx%>.command = "READ";
                                m_ace_directed_seq<%=pidx%>.Read_txn = DENALI_CDN_AXI_READSNOOP_ReadOnce;
                                m_ace_directed_seq<%=pidx%>.Domain_t = DENALI_CDN_AXI_DOMAIN_NON_SHAREABLE;
                                m_ace_directed_seq<%=pidx%>.start(axi_sequencer<%=pidx%>);
                            end
                        end
                <%}%>
               <%}%>
                <%pidx++;%>
            <%}%>
        <%}%>
        `uvm_info("VSEQ", "Finished ncore_ace_directed_vseq", UVM_LOW);
    endtask : body

endclass : ncore_ace_directed_vseq

