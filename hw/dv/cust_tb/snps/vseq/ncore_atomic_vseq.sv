<%const chipletObj = obj.lib.getAllChipletRefs();%>

class ncore_atomic_vseq extends uvm_sequence;
    `uvm_object_utils(ncore_atomic_vseq)
    
    addr_trans_mgr m_addr_mgr;
    ral_sys_ncore regmodel;
    bit[<%=chipletObj[0].AiuInfo[0].wAddr%>-1:0] addr[int];
  
    <%for(let idx = 0; idx < chipletObj[0].nCHIs; idx++) { %>
        svt_chi_rn_transaction_sequencer chi_rn_sqr<%=idx%>;
    <%}%>

    <%let pidx=0;%>
    <%for(let idx = 0; idx < chipletObj[0].nAIUs; idx++) { %>
        <%if(!(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
            <%for (let mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                svt_axi_master_sequencer axi_xact_seqr<%=pidx%>;
                <%pidx++;%>
            <%}%>
        <%}%>
    <%}%>
  
    function new (string name = "ncore_atomic_vseq");
        super.new(name);
        m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction : new
    
    virtual task body();
        super.body();
        $cast(regmodel, this.regmodel);

        addr[0] = m_addr_mgr.gen_coh_addr(0, 1);
        addr[0][5:0] = 'd0;

            <%pidx = 0;
            l_chi_idx = 0;
            for(let idx = 0; idx < chipletObj[0].nAIUs; idx++) { %>
                <%if(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
                    begin
                        ncore_chi_base_seq chi_seq<%=idx%>;
                        <%if(chipletObj[0].initiatorGroups){%>
                            <%chipletObj[0].initiatorGroups.forEach((group) => {%>
                                <%if(group.aPrimaryAiuPortBits.length > 0){%>
                                    <%if(group.fUnitIds.includes(chipletObj[0].AiuInfo[idx].FUnitId)){%>
                                        {
                                            <%for(var i=group.aPrimaryAiuPortBits.length-1; i>=0; i--){%>
                                                addr[0][<%=group.aPrimaryAiuPortBits[i]%>] <%if(i > 0){%>,<%}%>
                                            <%}%>
                                        } = <%=group.fUnitIds.indexOf(chipletObj[0].AiuInfo[idx].FUnitId)%>;
                                    <%}%>
                                <%}%>
                            <%})%>
                        <%}%>

                        chi_seq<%=idx%> = ncore_chi_base_seq::type_id::create("chi_seq<%=idx%>");
                        chi_seq<%=idx%>.sequence_length = 1;
                        chi_seq<%=idx%>.start_addr = addr;
                        chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_ATOMICSTORE_ADD;
                        chi_seq<%=idx%>.datawidth = svt_chi_transaction::SIZE_2BYTE;
                        chi_seq<%=idx%>.cache_value = 'h3e;
                        chi_seq<%=idx%>.txn_id = <%=idx%>;
                        chi_seq<%=idx%>.start(chi_rn_sqr<%=l_chi_idx%>);
                    end
                    <%l_chi_idx++;%>
                <%}else if(chipletObj[0].AiuInfo[idx].fnNativeInterface == 'ACE' || chipletObj[0].AiuInfo[idx].fnNativeInterface == 'ACE5' ){%>
                    <%for (let mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                    begin
                        ncore_axi_base_seq axi_seq<%=pidx%>;

                        axi_seq<%=pidx%> = ncore_axi_base_seq::type_id::create("axi_seq<%=pidx%>");
                        axi_seq<%=pidx%>.sequence_length = 1;
                        axi_seq<%=pidx%>.start_addr = addr;
                        axi_seq<%=pidx%>.cache_value = 6'hf;
                        axi_seq<%=pidx%>.xact_set = svt_axi_transaction::COHERENT;
                        axi_seq<%=pidx%>.transaction = `SVT_AXI_TRANSACTION_TYPE_ATOMIC;
                        axi_seq<%=pidx%>.datawidth = <%=(Math.log2(chipletObj[0].AiuInfo[idx].interfaces.axiInt[mpu_io].params.wData / 8))%>;
                        axi_seq<%=pidx%>.burstlen = 64 >> <%=(Math.log2(chipletObj[0].AiuInfo[idx].interfaces.axiInt[mpu_io].params.wData / 8))%>;
                        axi_seq<%=pidx%>.start(axi_xact_seqr<%=pidx%>);
                    end
                    <%}%>
                    <%pidx++;%>
                <%}else{%>
                    <%pidx++;%>
                <%}%>
            <%}%>


    endtask: body

endclass: ncore_atomic_vseq


