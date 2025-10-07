<%const chipletObj = obj.lib.getAllChipletRefs();%>

class ncore_ace_directed_vseq extends ncore_base_vseq;

    `uvm_object_utils(ncore_ace_directed_vseq)
    addr_trans_mgr m_addr_mgr;
    //ral_sys_ncore regmodel;
    bit[<%=chipletObj[0].AiuInfo[0].wAddr%>-1:0] addr[int];
    int loop = 0;

    <%let pidx=0;%>
    <%for(let idx = 0; idx < chipletObj[0].nAIUs; idx++) { %>
        <%if(!(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
            <%if(chipletObj[0].AiuInfo[idx].fnNativeInterface == 'ACE' || chipletObj[0].AiuInfo[idx].fnNativeInterface == 'ACE5' ){%>
               <%for (let mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                  svt_axi_master_sequencer axi_xact_seqr<%=pidx%>;
                  <%pidx++;%>
               <%}%>
            <%}%>
        <%}%>
    <%}%>
    
    
    function new(string name = "ncore_ace_directed_vseq");
        super.new(name);
        m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction : new
    
    virtual task body();
        `uvm_info("VSEQ", "Starting ncore_ace_directed_vseq", UVM_LOW);
        //$cast(regmodel, this.regmodel);
        addr[0] = m_addr_mgr.gen_coh_addr(0, 1);
        addr[0][5:0] = 'd0;

        <%pidx = 0;
        for(let idx = 0; idx < chipletObj[0].nAIUs; idx++) {%>
            <%if(!chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
                <%if(chipletObj[0].AiuInfo[idx].fnNativeInterface == 'ACE'|| chipletObj[0].AiuInfo[idx].fnNativeInterface == 'ACE5'){%>
                <%for (let mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                    begin
                        ncore_axi_base_seq axi_seq<%=pidx%>;
            
                        axi_seq<%=pidx%> = ncore_axi_base_seq::type_id::create("axi_seq<%=pidx%>");
                        axi_seq<%=pidx%>.sequence_length = 1;
                        axi_seq<%=pidx%>.start_addr = addr;
                        axi_seq<%=pidx%>.cache_value = 6'hf;
                        axi_seq<%=pidx%>.txn_no = loop;
                        axi_seq<%=pidx%>.datawidth = <%=(Math.log2(chipletObj[0].AiuInfo[idx].interfaces.axiInt[mpu_io].params.wData / 8))%>;
                        axi_seq<%=pidx%>.xact_set = svt_axi_transaction::COHERENT;
                        axi_seq<%=pidx%>.transaction = svt_axi_transaction::WRITENOSNOOP;
                        axi_seq<%=pidx%>.start(axi_xact_seqr<%=pidx%>);

                        #1us;

                        axi_seq<%=pidx%>.sequence_length = 1;
                        axi_seq<%=pidx%>.start_addr = addr;
                        axi_seq<%=pidx%>.cache_value = 6'hf;
                        axi_seq<%=pidx%>.txn_no = loop;
                        axi_seq<%=pidx%>.datawidth = <%=(Math.log2(chipletObj[0].AiuInfo[idx].interfaces.axiInt[mpu_io].params.wData / 8))%>;
                        axi_seq<%=pidx%>.xact_set = svt_axi_transaction::COHERENT;
                        axi_seq<%=pidx%>.transaction = svt_axi_transaction::READNOSNOOP;
                        axi_seq<%=pidx%>.start(axi_xact_seqr<%=pidx%>);
                    end
                <%}%>
               <%}%>
                <%pidx++;%>
            <%}%>
        <%}%>
        `uvm_info("VSEQ", "Finished ncore_ace_directed_vseq", UVM_LOW);
    endtask : body

endclass : ncore_ace_directed_vseq

