//--------------------------------------------------------
// ncore_snoop_vseq
//---------------------------------------------------------
<%const chipletObj = obj.lib.getAllChipletRefs();%>

class ncore_snoop_vseq extends ncore_base_vseq;
    `uvm_object_utils(ncore_snoop_vseq)
    
    addr_trans_mgr m_addr_mgr;
    //ral_sys_ncore regmodel;
    uvm_status_e status;
    bit[31:0] data;
    real latency;
    real min_latency = 8.988e307; // A very large value close to maximum
    real max_latency = 0;
    int bandwidth;
    int loop = 0;
    real avg_latency;
    time start_time;
    time end_time;
    int pkt_id = 0;
    bit[<%=chipletObj[0].AiuInfo[0].wAddr%>-1:0] addr[int];
  
    <%for(let idx = 0; idx < chipletObj[0].nCHIs; idx++) { %>
        svt_chi_rn_transaction_sequencer chi_rn_sqr<%=idx%>;
    <%}%>

    <%let pidx=0;%>
    <%for(let idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) { %>
        <%if(!(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
            <%for (let mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                svt_axi_master_sequencer axi_xact_seqr<%=pidx%>;
                <%pidx++;%>
            <%}%>
        <%}%>
    <%}%>
  
    function new (string name = "ncore_snoop_vseq");
        super.new(name);
        m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction : new
    
    virtual task body();
        //super.body();
        //$cast(regmodel, this.regmodel);

        <%//Get the IDs of all coherent agents%>
        <%let caiu_id_arr = [];%>
        <%for(let idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) { %>
            <%if (chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI') || chipletObj[0].AiuInfo[idx].fnNativeInterface == 'ACE' || chipletObj[0].AiuInfo[idx].fnNativeInterface == 'ACE5' ){%>
                <%caiu_id_arr.push(idx);%>
            <%}%>
        <%}%>
        addr[0] = m_addr_mgr.gen_coh_addr(0, 1);
        addr[0][5:0] = 'd0;

        // Put all agents in SC state
        <%if(caiu_id_arr.length >= 2){%>
            <%pidx = 0;
            l_chi_idx = 0;
            for(let idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) { %>
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
                        chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_READSHARED;
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
                        axi_seq<%=pidx%>.transaction = svt_axi_transaction::READSHARED;
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
        <%}%>

        // Invalidate all caches to generate snoops
        <%if(chipletObj[0].AiuInfo[caiu_id_arr[0]].fnNativeInterface.includes('CHI')){%>
            begin
                ncore_chi_base_seq chi_seq<%=caiu_id_arr[0]%>;
                <%if(chipletObj[0].initiatorGroups){%>
                    <%chipletObj[0].initiatorGroups.forEach((group) => {%>
                        <%if(group.aPrimaryAiuPortBits.length > 0){%>
                            <%if(group.fUnitIds.includes(chipletObj[0].AiuInfo[caiu_id_arr[0]].FUnitId)){%>
                                {
                                    <%for(var i=group.aPrimaryAiuPortBits.length-1; i>=0; i--){%>
                                        addr[0][<%=group.aPrimaryAiuPortBits[i]%>] <%if(i > 0){%>,<%}%>
                                    <%}%>
                                } = <%=group.fUnitIds.indexOf(chipletObj[0].AiuInfo[caiu_id_arr[0]].FUnitId)%>;
                            <%}%>
                        <%}%>
                    <%})%>
                <%}%>

                chi_seq<%=caiu_id_arr[0]%> = ncore_chi_base_seq::type_id::create("chi_seq<%=caiu_id_arr[0]%>");
                chi_seq<%=caiu_id_arr[0]%>.sequence_length = 1;
                chi_seq<%=caiu_id_arr[0]%>.start_addr = addr;
                chi_seq<%=caiu_id_arr[0]%>.transaction = `SVT_CHI_XACT_TYPE_READUNIQUE;
                chi_seq<%=caiu_id_arr[0]%>.cache_value = 'h3e;
                chi_seq<%=caiu_id_arr[0]%>.txn_id = <%=caiu_id_arr[0]%>;
                chi_seq<%=caiu_id_arr[0]%>.start(chi_rn_sqr<%=caiu_id_arr[0]%>);
            end
        <%}else if(chipletObj[0].AiuInfo[caiu_id_arr[0]].fnNativeInterface == 'ACE' || chipletObj[0].AiuInfo[caiu_id_arr[0]].fnNativeInterface == 'ACE5'  ){%>
           <%for (let mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[caiu_id_arr[0]].nNativeInterfacePorts; mpu_io++){%>
            begin
                ncore_axi_base_seq axi_seq<%=caiu_id_arr[0]%>;

                axi_seq<%=caiu_id_arr[0]%> = ncore_axi_base_seq::type_id::create("axi_seq<%=caiu_id_arr[0]%>");
                axi_seq<%=caiu_id_arr[0]%>.sequence_length = 1;
                axi_seq<%=caiu_id_arr[0]%>.start_addr = addr;
                axi_seq<%=caiu_id_arr[0]%>.cache_value = 6'hf;
                axi_seq<%=caiu_id_arr[0]%>.datawidth = <%=(Math.log2(chipletObj[0].AiuInfo[caiu_id_arr[0]].interfaces.axiInt[mpu_io].params.wData / 8))%>;
                axi_seq<%=caiu_id_arr[0]%>.burstlen = 64 >> <%=(Math.log2(chipletObj[0].AiuInfo[caiu_id_arr[0]].interfaces.axiInt[mpu_io].params.wData / 8))%>;
                axi_seq<%=caiu_id_arr[0]%>.xact_set = svt_axi_transaction::COHERENT;
                axi_seq<%=caiu_id_arr[0]%>.transaction = svt_axi_transaction::READUNIQUE;
                //axi_seq<%=caiu_id_arr[0]%>.start(axi_xact_seqr<%=(caiu_id_arr[0]-obj.nCHIs)%>);
                axi_seq<%=caiu_id_arr[0]%>.start(axi_xact_seqr<%=caiu_id_arr[0]%>);
            end
        <%}%>
        <%}%>

    endtask: body

endclass: ncore_snoop_vseq

