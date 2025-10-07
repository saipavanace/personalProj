<%const chipletObj = obj.lib.getAllChipletRefs();%>

class ncore_chi_directed_vseq extends ncore_base_vseq;

  `uvm_object_utils(ncore_chi_directed_vseq)

    addr_trans_mgr m_addr_mgr;
    //ral_sys_ncore regmodel;
    bit[<%=chipletObj[0].AiuInfo[0].wAddr%>-1:0] addr[int];
  
    <% for(let idx = 0; idx < chipletObj[0].nCHIs; idx++) {%>
        svt_chi_rn_transaction_sequencer chi_rn_sqr<%=idx%>;
    <%}%>
  
  function new(string name = "ncore_chi_directed_vseq");
    super.new(name);
    m_addr_mgr = addr_trans_mgr::get_instance();
  endfunction: new
  
  virtual task body();
        //super.body();
        //$cast(regmodel, this.regmodel);
        `uvm_info("VSEQ", "Starting ncore_chi_directed_vseq", UVM_LOW);
        <% for(let idx = 0; idx < chipletObj[0].nCHIs; idx++) {%>
            begin
                ncore_chi_base_seq chi_seq<%=idx%>;
                addr[0] = m_addr_mgr.gen_coh_addr(0, 1);
                addr[0][5:0] = 'd0;

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
                chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_WRITENOSNPFULL;
                chi_seq<%=idx%>.txn_id = <%=idx%>;
                chi_seq<%=idx%>.start(chi_rn_sqr<%=idx%>);
                #1us;

                chi_seq<%=idx%>.sequence_length = 1;
                chi_seq<%=idx%>.start_addr = addr;
                chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_READNOSNP;
                chi_seq<%=idx%>.txn_id = <%=idx%>;
                chi_seq<%=idx%>.start(chi_rn_sqr<%=idx%>);
            end
        <%}%>
        `uvm_info("VSEQ", "Finished ncore_chi_directed_vseq", UVM_LOW);
  endtask: body
  
endclass: ncore_chi_directed_vseq

