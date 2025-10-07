<%const chipletObj = obj.lib.getAllChipletRefs();%>

class ncore_exclusive_access_vseq extends ncore_base_vseq;

    `uvm_object_utils(ncore_exclusive_access_vseq)
    addr_trans_mgr m_addr_mgr;
    bit[<%=chipletObj[0].AiuInfo[0].wAddr%>-1:0] addr[int];
    int loop = 0;

    <% for(let idx = 0; idx < chipletObj[0].nCHIs; idx++) {%>
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
    
    
    function new(string name = "ncore_exclusive_access_vseq");
        super.new(name);
        m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction : new
    
    virtual task body();
        `uvm_info("VSEQ", "Starting ncore_exclusive_access_vseq", UVM_LOW);
        addr[0] = m_addr_mgr.gen_coh_addr(0, 1);
        addr[0][5:0] = 'd0;

        <% for(let idx = 0; idx < chipletObj[0].nCHIs; idx++) {%>
        begin
            ncore_chi_base_seq chi_seq<%=idx%>;
            foreach(ncoreConfigInfo::memregions_info[region]) begin
                addr[0] = ncoreConfigInfo::memregions_info[region].start_addr;
                chi_seq<%=idx%> = ncore_chi_base_seq::type_id::create("chi_seq<%=idx%>");
                chi_seq<%=idx%>.sequence_length = 1;
                chi_seq<%=idx%>.start_addr = addr;
                chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_READNOSNP;
                chi_seq<%=idx%>.cache_value = 'h38;
                chi_seq<%=idx%>.txn_id = <%=idx%>;
                chi_seq<%=idx%>.exclusive = 1;
                chi_seq<%=idx%>.start(chi_rn_sqr<%=idx%>);

                #1us;

                addr[0] = ncoreConfigInfo::memregions_info[region].start_addr;
                chi_seq<%=idx%> = ncore_chi_base_seq::type_id::create("chi_seq<%=idx%>");
                chi_seq<%=idx%>.sequence_length = 1;
                chi_seq<%=idx%>.start_addr = addr;
                chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_WRITENOSNPFULL;
                chi_seq<%=idx%>.cache_value = 'h38;
                chi_seq<%=idx%>.txn_id = <%=idx%>;
                chi_seq<%=idx%>.exclusive = 1;
                chi_seq<%=idx%>.start(chi_rn_sqr<%=idx%>);
            end        
        end
        <%}%>

        <%pidx = 0;
        for(let idx = 0; idx < chipletObj[0].nAIUs; idx++) {%>
            <%if(!(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                <%for (let mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                    begin

                        ncore_axi_base_seq axi_seq<%=pidx%>;
                        axi_seq<%=pidx%> = ncore_axi_base_seq::type_id::create("axi_seq<%=pidx%>");
                        axi_seq<%=pidx%>.sequence_length = 1;
                        axi_seq<%=pidx%>.start_addr = addr;
                        axi_seq<%=pidx%>.cache_value = 6'hf;
                        axi_seq<%=pidx%>.txn_no = loop;
                        axi_seq<%=pidx%>.datawidth = <%=(Math.log2(chipletObj[0].AiuInfo[idx].interfaces.axiInt[mpu_io].params.wData / 8))%>;
                        axi_seq<%=pidx%>.atomic_type_tx = svt_axi_transaction::EXCLUSIVE;
                        <%if(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('AXI4') || chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('AXI5') ){%>
                            axi_seq<%=pidx%>.xact_set = svt_axi_transaction::READ;
                            axi_seq<%=pidx%>.cache_value = 6'h2; 
                        <% } else { %> 
                            axi_seq<%=pidx%>.xact_set = svt_axi_transaction::COHERENT;
                            axi_seq<%=pidx%>.transaction = svt_axi_transaction::READNOSNOOP;
                        <%}%>
                        axi_seq<%=pidx%>.start(axi_xact_seqr<%=pidx%>);

                        #1us;

                        axi_seq<%=pidx%>.sequence_length = 1;
                        axi_seq<%=pidx%>.start_addr = addr;
                        axi_seq<%=pidx%>.cache_value = 6'hf;
                        axi_seq<%=pidx%>.txn_no = loop;
                        axi_seq<%=pidx%>.datawidth = <%=(Math.log2(chipletObj[0].AiuInfo[idx].interfaces.axiInt[mpu_io].params.wData / 8))%>;
                        axi_seq<%=pidx%>.atomic_type_tx = svt_axi_transaction::EXCLUSIVE;
                        <%if(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('AXI4') || chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('AXI5') ){%>
                            axi_seq<%=pidx%>.xact_set = svt_axi_transaction::WRITE;
                            axi_seq<%=pidx%>.cache_value = 6'h2;
                        <% } else { %> 
                            axi_seq<%=pidx%>.xact_set = svt_axi_transaction::COHERENT;
                            axi_seq<%=pidx%>.transaction = svt_axi_transaction::WRITENOSNOOP;
                        <%}%>
                        axi_seq<%=pidx%>.start(axi_xact_seqr<%=pidx%>);
                    end
                    <%pidx++;%>
                <%}%>
            <%}%>
        <%}%>

        



        `uvm_info("VSEQ", "Finished ncore_exclusive_access_vseq", UVM_LOW);
    endtask : body

endclass : ncore_exclusive_access_vseq

