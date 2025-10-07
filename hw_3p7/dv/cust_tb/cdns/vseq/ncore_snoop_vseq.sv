class ncore_snoop_vseq extends ncore_base_vseq;
    `uvm_object_utils(ncore_snoop_vseq)

    bit unconnected;
    bit [2:0] unit_unconnected;
    int slave_id;
    addr_trans_mgr m_addr_mgr;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;

    function new(string name = "ncore_snoop_vseq");
        super.new(name);
        m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction : new
    
    virtual task body();
        `uvm_info("VSEQ", "Starting ncore_snoop_vseq", UVM_LOW);
        addr = m_addr_mgr.gen_coh_addr(0, 1);
        addr[5:0] = 'd0;
    
        <%//Get the IDs of all coherent agents%>
        <%let caiu_id_arr = [];%>
        <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
            <%if (obj.AiuInfo[idx].fnNativeInterface.includes('CHI') || obj.AiuInfo[idx].fnNativeInterface == 'ACE' || obj.AiuInfo[idx].fnNativeInterface == 'ACE5' ){%>
                <%caiu_id_arr.push(idx);%>
            <%}%>
        <%}%>

        <%if(caiu_id_arr.length >= 2){%>
            <%pidx = 0;
            l_chi_idx = 0;
            for(let idx = 0; idx < obj.nAIUs; idx++) { %>
                <%if(obj.AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
                    begin
                    ncore_chi_base_seq m_chi_base_seq<%=idx%>;
                        <%if(obj.initiatorGroups){%>
                            <%obj.initiatorGroups.forEach((group) => {%>
                                <%if(group.aPrimaryAiuPortBits.length > 0){%>
                                    <%if(group.fUnitIds.includes(obj.AiuInfo[idx].FUnitId)){%>
                                        {
                                            <%for(var i=group.aPrimaryAiuPortBits.length-1; i>=0; i--){%>
                                                addr[<%=group.aPrimaryAiuPortBits[i]%>] <%if(i > 0){%>,<%}%>
                                            <%}%>
                                        } = <%=group.fUnitIds.indexOf(obj.AiuInfo[idx].FUnitId)%>;
                                    <%}%>
                                <%}%>
                            <%})%>
                        <%}%>
                    m_chi_base_seq<%=idx%> = ncore_chi_base_seq::type_id::create("m_chi_base_seq<%=idx%>");
                    m_chi_base_seq<%=idx%>.start_addr  = addr;
                    m_chi_base_seq<%=idx%>.sequence_length  =  1;
                    m_chi_base_seq<%=idx%>.txn_id           = <%=idx%>;
                    m_chi_base_seq<%=idx%>.tx_OpCode    = DENALI_CHI_REQOPCODE_ReadShared;
                    m_chi_base_seq<%=idx%>.cache_value = 'h3e;
                    m_chi_base_seq<%=idx%>.start(chi_sequencer<%=idx%>);
                    end
                    <%l_chi_idx++;%>
                <%}else if(obj.AiuInfo[idx].fnNativeInterface == 'ACE'){%>
                    begin
                    ncore_axi_base_seq axi_seq<%=pidx%>;
                    axi_seq<%=pidx%> = ncore_axi_base_seq::type_id::create("axi_seq<%=pidx%>");
                    axi_seq<%=pidx%>.start_addr = addr;
                    axi_seq<%=pidx%>.sequence_length  =  1;
                    axi_seq<%=pidx%>.command = "READ";
                    axi_seq<%=pidx%>.cache_value = 6'hf;
                    axi_seq<%=pidx%>.burstlen = 64 >> <%=(Math.log2(obj.AiuInfo[idx].wData / 8))%>;
                    axi_seq<%=pidx%>.Read_txn    = DENALI_CDN_AXI_READSNOOP_ReadShared;
                    axi_seq<%=pidx%>.start(axi_sequencer<%=pidx%>);
                    end
                    <%pidx++;%>
                <%}else{%>
                    <%pidx++;%>
                <%}%>
            <%}%>
        <%}%>

        <%if(obj.AiuInfo[caiu_id_arr[0]].fnNativeInterface.includes('CHI')){%>
            begin
                ncore_chi_base_seq m_chi_base_seq<%=caiu_id_arr[0]%>;
                <%if(obj.initiatorGroups){%>
                    <%obj.initiatorGroups.forEach((group) => {%>
                        <%if(group.aPrimaryAiuPortBits.length > 0){%>
                            <%if(group.fUnitIds.includes(obj.AiuInfo[caiu_id_arr[0]].FUnitId)){%>
                                {
                                    <%for(var i=group.aPrimaryAiuPortBits.length-1; i>=0; i--){%>
                                        addr[<%=group.aPrimaryAiuPortBits[i]%>] <%if(i > 0){%>,<%}%>
                                    <%}%>
                                } = <%=group.fUnitIds.indexOf(obj.AiuInfo[caiu_id_arr[0]].FUnitId)%>;
                            <%}%>
                        <%}%>
                    <%})%>
                <%}%>
                m_chi_base_seq<%=caiu_id_arr[0]%> = ncore_chi_base_seq::type_id::create("m_chi_base_seq<%=caiu_id_arr[0]%>");
                m_chi_base_seq<%=caiu_id_arr[0]%>.start_addr  = addr;
                m_chi_base_seq<%=caiu_id_arr[0]%>.sequence_length  =  1;
                m_chi_base_seq<%=caiu_id_arr[0]%>.txn_id           = <%=caiu_id_arr[0]%>;
                m_chi_base_seq<%=caiu_id_arr[0]%>.tx_OpCode    = DENALI_CHI_REQOPCODE_ReadUnique;
                m_chi_base_seq<%=caiu_id_arr[0]%>.cache_value = 'h3e;
                m_chi_base_seq<%=caiu_id_arr[0]%>.start(chi_sequencer<%=caiu_id_arr[0]%>);
            end
        <%}else if(obj.AiuInfo[caiu_id_arr[0]].fnNativeInterface == 'ACE' || obj.AiuInfo[caiu_id_arr[0]].fnNativeInterface == 'ACE5'  ){%>
            begin
                ncore_axi_base_seq axi_seq<%=caiu_id_arr[0]%>;
                axi_seq<%=caiu_id_arr[0]%> = ncore_axi_base_seq::type_id::create("axi_seq<%=caiu_id_arr[0]%>");
                axi_seq<%=caiu_id_arr[0]%>.start_addr = addr;
                axi_seq<%=caiu_id_arr[0]%>.sequence_length = 1;
                axi_seq<%=caiu_id_arr[0]%>.cache_value = 6'hf;
                axi_seq<%=caiu_id_arr[0]%>.command = "READ";
                axi_seq<%=caiu_id_arr[0]%>.Read_txn    = DENALI_CDN_AXI_READSNOOP_ReadUnique;
                axi_seq<%=caiu_id_arr[0]%>.burstlen = 64 >> <%=(Math.log2(obj.AiuInfo[caiu_id_arr[0]].wData / 8))%>;
                axi_seq<%=caiu_id_arr[0]%>.Domain_t    = DENALI_CDN_AXI_DOMAIN_OUTER;
                axi_seq<%=caiu_id_arr[0]%>.start(axi_sequencer<%=(caiu_id_arr[0]-obj.nCHIs)%>);
            end
        <%}%>

        `uvm_info("VSEQ", "Finished ncore_snoop_vseq", UVM_LOW);
        endtask : body
endclass : ncore_snoop_vseq
