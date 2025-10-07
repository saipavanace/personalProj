//--------------------------------------------------------
// ncore_cache_access_vseq
//---------------------------------------------------------

class ncore_cache_access_vseq extends uvm_sequence;
    `uvm_object_utils(ncore_cache_access_vseq)
    
    addr_trans_mgr m_addr_mgr;
    ral_sys_ncore regmodel;
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
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr[int];
    bit unconnected;
    bit [2:0] unit_unconnected;
  
    <% for(let idx = 0; idx < obj.nCHIs; idx++) {%>
        svt_chi_rn_transaction_sequencer chi_rn_sqr<%=idx%>;
    <%}%>

    <%let pidx=0;%>
    <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
        <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
            <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                svt_axi_master_sequencer axi_xact_seqr<%=pidx%>;
                <%pidx++;%>
            <%}%>
        <%}%>
    <%}%>
  
    function new (string name = "ncore_cache_access_vseq");
        super.new(name);
        m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction : new
    
    virtual task body();
        super.body();
        $cast(regmodel, this.regmodel);
        addr[0] = m_addr_mgr.gen_coh_addr(0, 1);
        addr[0][5:0] = 'd0;
        
        <% for(let idx = 0; idx < obj.nCHIs; idx++) {%>
            begin
                ncore_chi_base_seq chi_seq<%=idx%>;
                addr[0] = m_addr_mgr.gen_coh_addr(0, 1);
                addr[0][5:0] = 'd0;

                <%if(obj.initiatorGroups){%>
                    <%obj.initiatorGroups.forEach((group) => {%>
                        <%if(group.aPrimaryAiuPortBits.length > 0){%>
                            <%if(group.fUnitIds.includes(obj.AiuInfo[idx].FUnitId)){%>
                                {
                                    <%for(var i=group.aPrimaryAiuPortBits.length-1; i>=0; i--){%>
                                        addr[0][<%=group.aPrimaryAiuPortBits[i]%>] <%if(i > 0){%>,<%}%>
                                    <%}%>
                                } = <%=group.fUnitIds.indexOf(obj.AiuInfo[idx].FUnitId)%>;
                            <%}%>
                        <%}%>
                    <%})%>
                <%}%>

                // Send WriteUnique txn
                chi_seq<%=idx%> = ncore_chi_base_seq::type_id::create("chi_seq<%=idx%>");
                chi_seq<%=idx%>.sequence_length = 1;
                chi_seq<%=idx%>.start_addr = addr;
                chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_WRITEUNIQUEFULL;
                chi_seq<%=idx%>.cache_value = 'h3e;
                chi_seq<%=idx%>.txn_id = <%=idx%>;
                chi_seq<%=idx%>.start(chi_rn_sqr<%=idx%>);
                #1us;

                // Send Readonce txn
                chi_seq<%=idx%>.sequence_length = 1;
                chi_seq<%=idx%>.start_addr = addr;
                chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_READONCE;
                chi_seq<%=idx%>.cache_value = 'h3e;
                chi_seq<%=idx%>.txn_id = <%=idx%>;
                chi_seq<%=idx%>.start(chi_rn_sqr<%=idx%>);
            end
        <%}%>
        addr[0] = m_addr_mgr.gen_coh_addr(0, 1);
        addr[0][5:0] = 'd0;

        <%pidx = 0;
        for(let idx = 0; idx < obj.nAIUs; idx++) {%>
            <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
            <%if(!obj.AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
            <%var aiuinfo_idx = obj.AllIoaiuInfo[pidx].aiuinfo_idx;%>
                unconnected = addrMgrConst::check_unmapped_add(.addr(addr[0]),.agent_id(<%=obj.AiuInfo[idx].FUnitId%>),.unit_unconnected(unit_unconnected));
                    if (!unconnected) begin
                        ncore_axi_base_seq axi_seq<%=pidx%>;
            
                        axi_seq<%=pidx%> = ncore_axi_base_seq::type_id::create("axi_seq<%=pidx%>");

                        axi_seq<%=pidx%>.sequence_length = 1;
                        axi_seq<%=pidx%>.start_addr = addr;
                        axi_seq<%=pidx%>.cache_value = 6'hf;
                        axi_seq<%=pidx%>.txn_no = loop;
                        axi_seq<%=pidx%>.datawidth = <%=(Math.log2(obj.AiuInfo[idx].wData / 8))%>;
                        <%if(obj.AiuInfo[idx].fnNativeInterface.includes('AXI4') || obj.AiuInfo[idx].fnNativeInterface.includes('AXI5') ){%>
                        axi_seq<%=pidx%>.xact_set = svt_axi_transaction::WRITE;
                        <% } else { %> 
                        axi_seq<%=pidx%>.xact_set = svt_axi_transaction::COHERENT;
                        axi_seq<%=pidx%>.transaction = svt_axi_transaction::WRITEUNIQUE;
                        <%}%>
                        axi_seq<%=pidx%>.start(axi_xact_seqr<%=pidx%>);

                        #1us;

                        axi_seq<%=pidx%>.sequence_length = 1;
                        axi_seq<%=pidx%>.start_addr = addr;
                        axi_seq<%=pidx%>.cache_value = 6'hf;
                        axi_seq<%=pidx%>.txn_no = loop;
                        axi_seq<%=pidx%>.datawidth = <%=(Math.log2(obj.AiuInfo[idx].wData / 8))%>;
                        <%if(obj.AiuInfo[idx].fnNativeInterface.includes('AXI4') || obj.AiuInfo[idx].fnNativeInterface.includes('AXI5') ){%>
                        axi_seq<%=pidx%>.xact_set = svt_axi_transaction::READ;
                        <% } else { %> 
                        axi_seq<%=pidx%>.xact_set = svt_axi_transaction::COHERENT;
                        axi_seq<%=pidx%>.transaction = svt_axi_transaction::READONCE;
                        <%}%>
                        axi_seq<%=pidx%>.start(axi_xact_seqr<%=pidx%>);
                    end
                <%pidx++;%>
            <%}%>
          <%}%>
        <%}%>
    endtask: body

endclass: ncore_cache_access_vseq

