typedef enum {
    AIU, DCE, DMI, DII, DVE
} unit_t;

class ncore_connectivity_vseq extends ncore_base_vseq;
    `uvm_object_utils(ncore_connectivity_vseq)
    
    addr_trans_mgr m_addr_mgr;
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;
    addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t  csr_q[$];
    bit unconnected;
    bit [2:0] unit_unconnected;
  
    function new (string name = "ncore_connectivity_vseq");
        super.new(name);
        m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction : new
    
    virtual task body();
            this.csrq = addr_trans_mgr_pkg::addrMgrConst::get_all_gpra();
            `uvm_info("VSEQ", "Starting ncore_connectivity_vseq", UVM_LOW);
        <% for(let idx = 0; idx < obj.nCHIs; idx++) {%>
            begin
                  ncore_chi_base_seq m_chi_base_seq<%=idx%>;

                foreach(addrMgrConst::memregions_info[region]) begin
                    if (addrMgrConst::memregions_info[region].hut == DMI && !addrMgrConst::get_addr_gprar_nc(addrMgrConst::memregions_info[region].start_addr)) begin
                        addr = addrMgrConst::memregions_info[region].start_addr;
                        m_chi_base_seq<%=idx%> = ncore_chi_base_seq::type_id::create("m_chi_base_seq<%=idx%>");
                        m_chi_base_seq<%=idx%>.start_addr = addr;
                        m_chi_base_seq<%=idx%>.sequence_length  =  1;
                        m_chi_base_seq<%=idx%>.txn_id           = <%=idx%>;
                        m_chi_base_seq<%=idx%>.tx_OpCode = DENALI_CHI_REQOPCODE_ReadOnce;
                        m_chi_base_seq<%=idx%>.cache_value = 6'he;
                        m_chi_base_seq<%=idx%>.start(chi_sequencer<%=idx%>);
                    end else begin
                        addr = addrMgrConst::memregions_info[region].start_addr;
                        m_chi_base_seq<%=idx%> = ncore_chi_base_seq::type_id::create("m_chi_base_seq<%=idx%>");
                        m_chi_base_seq<%=idx%>.start_addr = addr;
                        m_chi_base_seq<%=idx%>.sequence_length  =  1;
                        m_chi_base_seq<%=idx%>.txn_id           = <%=idx%>;
                        m_chi_base_seq<%=idx%>.tx_OpCode = DENALI_CHI_REQOPCODE_ReadNoSnp;
                        m_chi_base_seq<%=idx%>.cache_value = 6'h20;
                        m_chi_base_seq<%=idx%>.start(chi_sequencer<%=idx%>);
                    end
                end
            end
        <%}%>

        <%pidx = 0;
        for(let idx = 0; idx < obj.nAIUs; idx++) {%>
            <%if(!obj.AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
                <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                <%var aiuinfo_idx = obj.AllIoaiuInfo[pidx].aiuinfo_idx;%>
                begin
                    ncore_axi_base_seq axi_seq<%=pidx%>;

                    foreach(addrMgrConst::memregions_info[region]) begin
                        addr  = addrMgrConst::memregions_info[region].start_addr;
                        unconnected = addrMgrConst::check_unmapped_add(.addr(addr),.agent_id(<%=obj.AiuInfo[aiuinfo_idx].FUnitId%>),.unit_unconnected(unit_unconnected));
                        axi_seq<%=pidx%> = ncore_axi_base_seq::type_id::create("axi_seq<%=pidx%>");

                        <%if(!((obj.AiuInfo[idx].fnNativeInterface == 'AXI4')|| (obj.AiuInfo[idx].fnNativeInterface == 'AXI5'))) {%>
                        if (!unconnected) begin
                        axi_seq<%=pidx%>.start_addr  = addr;
                        axi_seq<%=pidx%>.sequence_length = 1;
                        axi_seq<%=pidx%>.command = "READ";
                        axi_seq<%=pidx%>.Read_txn    = DENALI_CDN_AXI_READSNOOP_ReadOnce;
                        axi_seq<%=pidx%>.start(axi_sequencer<%=pidx%>);
                        end
                        <%}else{%>
                        if (!(unconnected || addrMgrConst::memregions_info[region].hut == DII) ) begin
                        axi_seq<%=pidx%>.start_addr = addr;
                        axi_seq<%=pidx%>.sequence_length = 1;
                        axi_seq<%=pidx%>.command = "READ";
                        axi_seq<%=pidx%>.protocol = "AXI4";
                        axi_seq<%=pidx%>.start(axi_sequencer<%=pidx%>);
                        `uvm_info("VSEQ_SEQ<%=pidx%>_START",$sformatf(" axi_seq<%=pidx%>.start_addr %h", axi_seq<%=pidx%>.start_addr),UVM_LOW);
                        end
                        <%}%>
                    end
                end
            <%pidx++;%>
            <%}%>
            <%}%>
        <%}%>
        `uvm_info("VSEQ", "Finished ncore_connectivity_vseq", UVM_LOW);
    endtask: body

endclass: ncore_connectivity_vseq


