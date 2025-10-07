//--------------------------------------------------------
// ncore_bandwidth_multi_vseq
//---------------------------------------------------------

class ncore_bandwidth_multi_vseq extends uvm_sequence;
    `uvm_object_utils(ncore_bandwidth_multi_vseq)
    
    addr_trans_mgr m_addr_mgr;
    ral_sys_ncore regmodel;
    int txn_count = $value$plusargs("num_txns_per_initiator_target=%0d", txn_count) ? txn_count : 50; 
    int addr_incr = $value$plusargs("addr_incr=%0h", addr_incr) ? addr_incr : 'h40; 
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr[int];
    bit[<%=obj.AiuInfo[0].wAddr%>-1:0] last_used_addr[int];
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

    function ncore_addr_t get_unique_addr(int region);
        ncore_addr_t start_addr = addrMgrConst::memregions_info[region].start_addr;
        ncore_addr_t end_addr   = addrMgrConst::memregions_info[region].end_addr;
        ncore_addr_t unique_addr;
        `uvm_info("GET_ADDRESS",$sformatf("REGION: %0d, START_ADDR: %0h, END_ADDR: %0h",region,start_addr,end_addr),UVM_DEBUG)
            if (last_used_addr.exists(region)) begin
                unique_addr = last_used_addr[region] +addr_incr;
                unique_addr[5:0] = 'd0; // Ensure alignment
                    if (unique_addr > end_addr) begin
                        unique_addr = start_addr;
                        unique_addr[5:0] = 'd0; // Ensure alignment
                    end
            end else begin
                unique_addr = start_addr;
                unique_addr[5:0] = 'd0; // Ensure alignment
            end
        // Mark the address as used
        last_used_addr[region] = unique_addr; // Update the last used address
        `uvm_info("RETURN_UNIQUE_ADDRESS",$sformatf("REGION: %0d, unique_addr: %0h",region,unique_addr),UVM_DEBUG)
        return unique_addr;
    endfunction: get_unique_addr

    function string check_memregion_id(ncore_addr_t addr);
        foreach(addrMgrConst::memregions_info[region]) begin
            if (addrMgrConst::is_dii_addr(addr)) begin 
                return "DII";
            end
            if (addrMgrConst::is_dmi_addr(addr)) begin 
                if(!addrMgrConst::get_addr_gprar_nc(addr))begin
                return "DMI (NC=0)";
                end
                if(addrMgrConst::get_addr_gprar_nc(addr))begin
                return "DMI (NC=1)";
                end
            end
        end
        return "UNKNOWN";
    endfunction: check_memregion_id

    function new (string name = "ncore_bandwidth_multi_vseq");
        super.new(name);
        m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction : new
    
    virtual task body();
        super.body();
        $cast(regmodel, this.regmodel);
        fork  
        <% for(let idx = 0; idx < obj.nCHIs; idx++) {%>
            begin
                ncore_chi_base_seq chi_seq<%=idx%>;
                real bandwidth;
                real avg_bandwidth;
                real latency;
                real min_latency;
                real max_latency;
                real avg_latency;
                int loop=0;
                string memregion_id = "UNKNOWN";

                //====================CHI Read Coherent Commands===========================
                foreach(addrMgrConst::memregions_info[region]) begin
                    if (addrMgrConst::memregions_info[region].hut == DMI) begin // Coherent transaction will initiate only on DMI Regions
                        bandwidth = 0;
                        latency = 0;
                        avg_bandwidth = 0;
                        avg_latency = 0;
                        loop = 0;
                        min_latency = 0;
                        max_latency = 0;
                        memregion_id = "UNKNOWN";
                        repeat(txn_count) begin
                            addr[region] = get_unique_addr(region);
                            <%if(obj.initiatorGroups){%>
                                <%obj.initiatorGroups.forEach((group) => {%>
                                    <%if(group.aPrimaryAiuPortBits.length > 0){%>
                                        <%if(group.fUnitIds.includes(obj.AiuInfo[idx].FUnitId)){%>
                                            {
                                                <%for(var i=group.aPrimaryAiuPortBits.length-1; i>=0; i--){%>
                                                    addr[region][<%=group.aPrimaryAiuPortBits[i]%>] <%if(i > 0){%>,<%}%>
                                                <%}%>
                                            } = <%=group.fUnitIds.indexOf(obj.AiuInfo[idx].FUnitId)%>;
                                        <%}%>
                                    <%}%>
                                <%})%>
                            <%}%>

                            chi_seq<%=idx%> = ncore_chi_base_seq::type_id::create("chi_seq<%=idx%>");
                            chi_seq<%=idx%>.sequence_length = 1;
                            chi_seq<%=idx%>.start_addr[0] = addr[region];
                            chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_READONCE;
                            chi_seq<%=idx%>.cache_value = 'h3e;
                            chi_seq<%=idx%>.txn_id = <%=idx%>;
                            memregion_id = check_memregion_id(addr[region]);
                            `uvm_info("CUST_TB_CHI_READ_COH_<%=idx%>",$sformatf("ADDR : %0h, REGION : %0d",chi_seq<%=idx%>.start_addr[0], region),UVM_HIGH)
                            chi_seq<%=idx%>.start(chi_rn_sqr<%=idx%>);

                            latency = chi_seq<%=idx%>.latency;
                            //bandwidth = (64 / (latency*1.0)) * 1000000000.0;
                            bandwidth = ((2**chi_seq<%=idx%>.burst_size) / latency) * 1000000.0;  // MB/s
                            if (loop == 0) begin
                                min_latency = latency;
                            end
                            else if (latency <= min_latency) begin
                                min_latency = latency;
                            end
                            if (latency >= max_latency) begin
                                max_latency = latency;
                            end
                            avg_latency = ((avg_latency * loop) + latency)/((loop+1)*1.0);
                            avg_bandwidth = ((avg_bandwidth * loop) + bandwidth)/((loop+1)*1.0);
	                        `uvm_info("body", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: READONCE, NUM_OF_TXNS: (%0d/%0d), Bandwidth: %0d MB/s, Latency: %.2f ps",region, memregion_id, loop+1, txn_count, bandwidth, latency), UVM_HIGH);
                            loop++;
                        end // repeat
	                    `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                    `uvm_info("body", $sformatf("Performance Results"), UVM_NONE);
	                    `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                    `uvm_info("summary", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: READONCE, TOTAL_NUM_OF_TXNS: %0d, Bandwidth(avg): %.2f MB/s, Latency(avg/min/max): %.2f ps/ %.2f ps/ %.2f ps",region, memregion_id, loop, avg_bandwidth, avg_latency, min_latency, max_latency), UVM_NONE);
                    end
                end 

                //====================CHI Write Coherent Commands==========================
                foreach(addrMgrConst::memregions_info[region]) begin
                    if (addrMgrConst::memregions_info[region].hut == DMI) begin
                        bandwidth = 0;
                        latency = 0;
                        avg_bandwidth = 0;
                        avg_latency = 0;
                        loop = 0;
                        min_latency = 0;
                        max_latency = 0;
                        memregion_id = "UNKNOWN";
                        repeat(txn_count) begin
                            addr[region] = get_unique_addr(region);
                                <%if(obj.initiatorGroups){%>
                                    <%obj.initiatorGroups.forEach((group) => {%>
                                        <%if(group.aPrimaryAiuPortBits.length > 0){%>
                                            <%if(group.fUnitIds.includes(obj.AiuInfo[idx].FUnitId)){%>
                                                {
                                                    <%for(var i=group.aPrimaryAiuPortBits.length-1; i>=0; i--){%>
                                                        addr[region][<%=group.aPrimaryAiuPortBits[i]%>] <%if(i > 0){%>,<%}%>
                                                    <%}%>
                                                } = <%=group.fUnitIds.indexOf(obj.AiuInfo[idx].FUnitId)%>;
                                            <%}%>
                                        <%}%>
                                    <%})%>
                                <%}%>
                            chi_seq<%=idx%> = ncore_chi_base_seq::type_id::create("chi_seq<%=idx%>");
                            chi_seq<%=idx%>.sequence_length = 1;
                            chi_seq<%=idx%>.start_addr[0] = addr[region];
                            chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_WRITEUNIQUEFULL;;
                            chi_seq<%=idx%>.cache_value = 'he;
                            chi_seq<%=idx%>.txn_id = <%=idx%>;
                            memregion_id = check_memregion_id(addr[region]);
                            `uvm_info("CUST_TB_CHI_WRITE_COH_<%=idx%>",$sformatf("ADDR : %0h, REGION : %0d",chi_seq<%=idx%>.start_addr[0], region),UVM_HIGH)
                            chi_seq<%=idx%>.start(chi_rn_sqr<%=idx%>);

                            latency = chi_seq<%=idx%>.latency;
                            //bandwidth = (64 / (latency*1.0)) * 1000000000.0;
                            bandwidth = ((2**chi_seq<%=idx%>.burst_size) / latency) * 1000000.0;  // MB/s
                            if (loop == 0) begin
                                min_latency = latency;
                            end
                            else if (latency <= min_latency) begin
                                min_latency = latency;
                            end
                            if (latency >= max_latency) begin
                                max_latency = latency;
                            end
                            avg_latency = ((avg_latency * loop) + latency)/((loop+1)*1.0);
                            avg_bandwidth = ((avg_bandwidth * loop) + bandwidth)/((loop+1)*1.0);
	                        `uvm_info("body", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: WRITEUNIQUE, NUM_OF_TXNS: (%0d/%0d), Bandwidth: %0d MB/s, Latency: %.2f ps",region, memregion_id, loop+1, txn_count, bandwidth, latency), UVM_HIGH);
                            loop++;
                        end // repeat
	                    `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                    `uvm_info("body", $sformatf("Performance Results"), UVM_NONE);
	                    `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                    `uvm_info("summary", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: WRITEUNIQUE, TOTAL_NUM_OF_TXNS: %0d, Bandwidth(avg): %.2f MB/s, Latency(avg/min/max): %.2f ps/ %.2f ps/ %.2f ps",region, memregion_id, loop, avg_bandwidth, avg_latency, min_latency, max_latency), UVM_NONE);
                    end
                end

                //====================CHI Read Non Coherent Commands=======================
                foreach(addrMgrConst::memregions_info[region]) begin
                    bandwidth = 0;
                    latency = 0;
                    avg_bandwidth = 0;
                    avg_latency = 0;
                    loop = 0;
                    min_latency = 0;
                    max_latency = 0;
                    memregion_id = "UNKNOWN";
                    repeat(txn_count) begin
                        addr[region] = get_unique_addr(region);
                        <%if(obj.initiatorGroups){%>
                            <%obj.initiatorGroups.forEach((group) => {%>
                                <%if(group.aPrimaryAiuPortBits.length > 0){%>
                                    <%if(group.fUnitIds.includes(obj.AiuInfo[idx].FUnitId)){%>
                                        {
                                            <%for(var i=group.aPrimaryAiuPortBits.length-1; i>=0; i--){%>
                                                addr[region][<%=group.aPrimaryAiuPortBits[i]%>] <%if(i > 0){%>,<%}%>
                                            <%}%>
                                        } = <%=group.fUnitIds.indexOf(obj.AiuInfo[idx].FUnitId)%>;
                                    <%}%>
                                <%}%>
                            <%})%>
                        <%}%>
                        chi_seq<%=idx%> = ncore_chi_base_seq::type_id::create("chi_seq<%=idx%>");
                        chi_seq<%=idx%>.sequence_length = 1;
                        chi_seq<%=idx%>.start_addr[0] = addr[region];
                        chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_READNOSNP;
                        chi_seq<%=idx%>.cache_value = 'h38;
                        chi_seq<%=idx%>.txn_id = <%=idx%>;
                        memregion_id = check_memregion_id(addr[region]);
                        `uvm_info("CUST_TB_CHI_READ_NON_COH_<%=idx%>",$sformatf("ADDR : %0h, REGION : %0h",chi_seq<%=idx%>.start_addr[0], region),UVM_HIGH)
                        chi_seq<%=idx%>.start(chi_rn_sqr<%=idx%>);

                        latency = chi_seq<%=idx%>.latency;
                        //bandwidth = (64 / (latency*1.0)) * 1000000000.0;
                        bandwidth = ((2**chi_seq<%=idx%>.burst_size) / latency) * 1000000.0;  // MB/s
                        if (loop == 0) begin
                            min_latency = latency;
                        end
                        else if (latency <= min_latency) begin
                            min_latency = latency;
                        end
                        if (latency >= max_latency) begin
                            max_latency = latency;
                        end
                        avg_latency = ((avg_latency * loop) + latency)/((loop+1)*1.0);
                        avg_bandwidth = ((avg_bandwidth * loop) + bandwidth)/((loop+1)*1.0);
	                    `uvm_info("body", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: READNOSNOOP, NUM_OF_TXNS: (%0d/%0d), Bandwidth: %0d MB/s, Latency: %.2f ps",region, memregion_id, loop+1, txn_count, bandwidth, latency), UVM_HIGH);
                        loop++;
                    end //repeat
	                `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                `uvm_info("body", $sformatf("Performance Results"), UVM_NONE);
	                `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                `uvm_info("summary", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: READNOSNOOP, TOTAL_NUM_OF_TXNS: %0d, Bandwidth(avg): %.2f MB/s, Latency(avg/min/max): %.2f ps/ %.2f ps/ %.2f ps",region, memregion_id, loop, avg_bandwidth, avg_latency, min_latency, max_latency), UVM_NONE);
                end

                // ====================CHI Write Non Coherent Commands=====================
                foreach(addrMgrConst::memregions_info[region]) begin
                    bandwidth = 0;
                    latency = 0;
                    avg_bandwidth = 0;
                    avg_latency = 0;
                    loop = 0;
                    min_latency = 0;
                    max_latency = 0;
                    memregion_id = "UNKNOWN";
                    repeat(txn_count) begin
                        addr[region] = get_unique_addr(region);
                        <%if(obj.initiatorGroups){%>
                            <%obj.initiatorGroups.forEach((group) => {%>
                                <%if(group.aPrimaryAiuPortBits.length > 0){%>
                                    <%if(group.fUnitIds.includes(obj.AiuInfo[idx].FUnitId)){%>
                                        {
                                            <%for(var i=group.aPrimaryAiuPortBits.length-1; i>=0; i--){%>
                                                addr[region][<%=group.aPrimaryAiuPortBits[i]%>] <%if(i > 0){%>,<%}%>
                                            <%}%>
                                        } = <%=group.fUnitIds.indexOf(obj.AiuInfo[idx].FUnitId)%>;
                                    <%}%>
                                <%}%>
                            <%})%>
                        <%}%>
                        chi_seq<%=idx%> = ncore_chi_base_seq::type_id::create("chi_seq<%=idx%>");
                        chi_seq<%=idx%>.sequence_length = 1;
                        chi_seq<%=idx%>.start_addr[0] = addr[region];
                        chi_seq<%=idx%>.transaction = `SVT_CHI_XACT_TYPE_WRITENOSNPFULL;
                        chi_seq<%=idx%>.cache_value = 'h0;
                        chi_seq<%=idx%>.txn_id = <%=idx%>;
                        memregion_id = check_memregion_id(addr[region]);
                        `uvm_info("CUST_TB_CHI_WRITE_NON_COH_<%=idx%>",$sformatf("ADDR : %0h, REGION : %0d",chi_seq<%=idx%>.start_addr[0], region),UVM_HIGH)
                        chi_seq<%=idx%>.start(chi_rn_sqr<%=idx%>);

                        latency = chi_seq<%=idx%>.latency;
                        //bandwidth = (64 / (latency*1.0)) * 1000000000.0;
                        bandwidth = ((2**chi_seq<%=idx%>.burst_size) / latency) * 1000000.0;  // MB/s
                        if (loop == 0) begin
                            min_latency = latency;
                        end
                        else if (latency <= min_latency) begin
                            min_latency = latency;
                        end
                        if (latency >= max_latency) begin
                            max_latency = latency;
                        end
                        avg_latency = ((avg_latency * loop) + latency)/((loop+1)*1.0);
                        avg_bandwidth = ((avg_bandwidth * loop) + bandwidth)/((loop+1)*1.0);
	                    `uvm_info("body", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: WRITENOSNOOP, NUM_OF_TXNS: (%0d/%0d), Bandwidth: %0d MB/s, Latency: %.2f ps",region, memregion_id, loop+1, txn_count, bandwidth, latency), UVM_HIGH);
                        loop++;
                    end  //repeat
	                `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                `uvm_info("body", $sformatf("Performance Results"), UVM_NONE);
	                `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                `uvm_info("summary", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: WRITENOSNOOP, TOTAL_NUM_OF_TXNS: %0d, Bandwidth(avg): %.2f MB/s, Latency(avg/min/max): %.2f ps/ %.2f ps/ %.2f ps",region, memregion_id, loop, avg_bandwidth, avg_latency, min_latency, max_latency), UVM_NONE);
                end
            end // begin
        <%}%>

        <%pidx = 0;
        let np_idx = 0;
        for(let idx = 0; idx < obj.nAIUs; idx++) {%>
            <%if(!obj.AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
            <%var aiuinfo_idx = obj.AllIoaiuInfo[pidx].aiuinfo_idx;%>

                begin
                    ncore_axi_base_seq axi_seq<%=np_idx%>;
                    int loop=0;
                    real bandwidth;
                    real avg_bandwidth;
                    real latency;
                    real min_latency;
                    real max_latency;
                    real avg_latency;
                    string memregion_id = "UNKNOWN";

                    //====================IOAIU Read Coherent Commands====================
                    foreach(addrMgrConst::memregions_info[region]) begin
                        <%if(obj.AiuInfo[idx].fnNativeInterface == 'AXI4'){%>
                            if (addrMgrConst::memregions_info[region].hut == DMI && !addrMgrConst::get_addr_gprar_nc(addrMgrConst::memregions_info[region].start_addr)) begin
                        <% } else { %> 
                            if (addrMgrConst::memregions_info[region].hut == DMI) begin
                        <%}%>
                        bandwidth = 0;
                        latency = 0;
                        avg_bandwidth = 0;
                        avg_latency = 0;
                        loop = 0;
                        min_latency = 0;
                        max_latency = 0;
                        memregion_id = "UNKNOWN";
                        repeat(txn_count) begin
                            addr[region] = get_unique_addr(region);
                            unconnected = addrMgrConst::check_unmapped_add(.addr(addr[region]),.agent_id(<%=obj.AiuInfo[idx].FUnitId%>),.unit_unconnected(unit_unconnected));
                            if (!unconnected) begin
                                <%if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
                                    {
                                        <%for(var i=obj.AiuInfo[idx].aNcaiuIntvFunc.aPrimaryBits.length-1; i>=0; i--){%>
                                            addr[region][<%=obj.AiuInfo[idx].aNcaiuIntvFunc.aPrimaryBits[i]%>] <%if(i>0){%>,<%}%>
                                        <%}%>
                                    } = 'd0;
                                <%}%>
                                axi_seq<%=np_idx%> = ncore_axi_base_seq::type_id::create("axi_seq<%=np_idx%>");
                                axi_seq<%=np_idx%>.sequence_length = 1;
                                axi_seq<%=np_idx%>.start_addr[0] = addr[region];
                                axi_seq<%=np_idx%>.cache_value = 6'hf;
                                axi_seq<%=np_idx%>.txn_no = loop;
                                <%if(obj.AiuInfo[idx].fnNativeInterface.includes('AXI4') || obj.AiuInfo[idx].fnNativeInterface.includes('AXI5') ){%>
                                axi_seq<%=np_idx%>.xact_set = svt_axi_transaction::READ;
                                <% } else { %> 
                                axi_seq<%=np_idx%>.xact_set = svt_axi_transaction::COHERENT;
                                axi_seq<%=np_idx%>.transaction = svt_axi_transaction::READONCE;
                                <%}%>
                                axi_seq<%=np_idx%>.datawidth = <%=(Math.log2(obj.AiuInfo[idx].wData / 8))%>;
                                axi_seq<%=np_idx%>.burstlen = 64 >> <%=(Math.log2(obj.AiuInfo[idx].wData / 8))%>;
                                memregion_id = check_memregion_id(addr[region]);
                                `uvm_info("CUST_TB_IOAIU_READ_COH_<%=idx%>",$sformatf("ADDR : %0h",axi_seq<%=np_idx%>.start_addr[0]),UVM_HIGH)
                                axi_seq<%=np_idx%>.start(axi_xact_seqr<%=np_idx%>);

                                latency = axi_seq<%=np_idx%>.latency;
                                //bandwidth = (64 / (latency*1.0)) * 1000000000.0;
                                bandwidth =  ((axi_seq<%=np_idx%>.burstlen * (2**axi_seq<%=np_idx%>.datawidth)) / latency) * 1000000.0;  // MB/s
                                if (loop == 0) begin
                                    min_latency = latency;
                                end
                                else if (latency <= min_latency) begin
                                    min_latency = latency;
                                end
                                if (latency >= max_latency) begin
                                    max_latency = latency;
                                end
                                avg_latency = ((avg_latency * loop) + latency)/((loop+1)*1.0);
                                avg_bandwidth = ((avg_bandwidth * loop) + bandwidth)/((loop+1)*1.0);
                            end // unconnected
	                        `uvm_info("body", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: READONCE, NUM_OF_TXNS: (%0d/%0d), Bandwidth: %0d MB/s, Latency: %.2f ps",region, memregion_id, loop+1, txn_count, bandwidth, latency), UVM_HIGH);
                            loop++;
                            end //repeat
	                        `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                        `uvm_info("body", $sformatf("Performance Results"), UVM_NONE);
	                        `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                        `uvm_info("summary", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: READONCE, TOTAL_NUM_OF_TXNS: %0d, Bandwidth(avg): %.2f MB/s, Latency(avg/min/max): %.2f ps/ %.2f ps/ %.2f ps",region, memregion_id, loop, avg_bandwidth, avg_latency, min_latency, max_latency), UVM_NONE);
                        end
                    end

                    //====================IOAIU Write Coherent Commands===================
                    foreach(addrMgrConst::memregions_info[region]) begin
                        <%if(obj.AiuInfo[idx].fnNativeInterface == 'AXI4'){%>
                            if (addrMgrConst::memregions_info[region].hut == DMI && !addrMgrConst::get_addr_gprar_nc(addrMgrConst::memregions_info[region].start_addr)) begin
                        <% } else { %> 
                            if (addrMgrConst::memregions_info[region].hut == DMI) begin
                        <%}%>
                        bandwidth = 0;
                        latency = 0;
                        avg_bandwidth = 0;
                        avg_latency = 0;
                        loop = 0;
                        min_latency = 0;
                        max_latency = 0;
                        memregion_id = "UNKNOWN";
                        repeat(txn_count) begin
                            addr[region] = get_unique_addr(region);
                            unconnected = addrMgrConst::check_unmapped_add(.addr(addr[region]),.agent_id(<%=obj.AiuInfo[idx].FUnitId%>),.unit_unconnected(unit_unconnected));
                            if (!unconnected) begin
                                <%if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
                                    {
                                        <%for(var i=obj.AiuInfo[idx].aNcaiuIntvFunc.aPrimaryBits.length-1; i>=0; i--){%>
                                            addr[region][<%=obj.AiuInfo[idx].aNcaiuIntvFunc.aPrimaryBits[i]%>] <%if(i>0){%>,<%}%>
                                        <%}%>
                                    } = 'd0;
                                <%}%>
                                axi_seq<%=np_idx%> = ncore_axi_base_seq::type_id::create("axi_seq<%=np_idx%>");
                                axi_seq<%=np_idx%>.sequence_length = 1;
                                axi_seq<%=np_idx%>.start_addr[0] = addr[region];
                                axi_seq<%=np_idx%>.cache_value = 6'hf;
                                axi_seq<%=np_idx%>.txn_no = loop;
                                axi_seq<%=np_idx%>.datawidth = <%=(Math.log2(obj.AiuInfo[idx].wData / 8))%>;
                                axi_seq<%=np_idx%>.burstlen = 64 >> <%=(Math.log2(obj.AiuInfo[idx].wData / 8))%>;
                                <%if(obj.AiuInfo[idx].fnNativeInterface.includes('AXI4') || obj.AiuInfo[idx].fnNativeInterface.includes('AXI5') ){%>
                                axi_seq<%=np_idx%>.xact_set = svt_axi_transaction::WRITE;
                                <% } else { %> 
                                axi_seq<%=np_idx%>.xact_set = svt_axi_transaction::COHERENT;
                                axi_seq<%=np_idx%>.transaction = svt_axi_transaction::WRITEUNIQUE;
                                <%}%>
                                memregion_id = check_memregion_id(addr[region]);
                                `uvm_info("CUST_TB_IOAIU_WRITE_COH_<%=idx%>",$sformatf("ADDR : %0h",axi_seq<%=np_idx%>.start_addr[0]),UVM_HIGH)
                                axi_seq<%=np_idx%>.start(axi_xact_seqr<%=np_idx%>);

                                latency = axi_seq<%=np_idx%>.latency;
                                //bandwidth = (64 / (latency*1.0)) * 1000000000.0;
                                bandwidth =  ((axi_seq<%=np_idx%>.burstlen * (2**axi_seq<%=np_idx%>.datawidth)) / latency) * 1000000.0;  // MB/s
                                if (loop == 0) begin
                                    min_latency = latency;
                                end
                                else if (latency <= min_latency) begin
                                    min_latency = latency;
                                end
                                if (latency >= max_latency) begin
                                    max_latency = latency;
                                end
                                avg_latency = ((avg_latency * loop) + latency)/((loop+1)*1.0);
                                avg_bandwidth = ((avg_bandwidth * loop) + bandwidth)/((loop+1)*1.0);
                                end
	                            `uvm_info("body", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: WRITEUNIQUE, NUM_OF_TXNS: (%0d/%0d), Bandwidth: %0d MB/s, Latency: %.2f ps",region, memregion_id, loop+1, txn_count, bandwidth, latency), UVM_HIGH);
                                loop++;
                            end // repeat
	                        `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                        `uvm_info("body", $sformatf("Performance Results"), UVM_NONE);
	                        `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                        `uvm_info("summary", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: WRITEUNIQUE, TOTAL_NUM_OF_TXNS: %0d, Bandwidth(avg): %.2f MB/s, Latency(avg/min/max): %.2f ps/ %.2f ps/ %.2f ps",region, memregion_id, loop, avg_bandwidth, avg_latency, min_latency, max_latency), UVM_NONE);
                        end
                    end

                    //====================IOAIU Read Non Coherent Commands================
                    foreach(addrMgrConst::memregions_info[region]) begin
                        bandwidth = 0;
                        latency = 0;
                        avg_bandwidth = 0;
                        avg_latency = 0;
                        loop = 0;
                        min_latency = 0;
                        max_latency = 0;
                        memregion_id = "UNKNOWN";
                        repeat(txn_count) begin
                        addr[region] = get_unique_addr(region);
                        unconnected = addrMgrConst::check_unmapped_add(.addr(addr[region]),.agent_id(<%=obj.AiuInfo[idx].FUnitId%>),.unit_unconnected(unit_unconnected));
                        if (!unconnected) begin
                            <%if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
                                {
                                    <%for(var i=obj.AiuInfo[idx].aNcaiuIntvFunc.aPrimaryBits.length-1; i>=0; i--){%>
                                        addr[region][<%=obj.AiuInfo[idx].aNcaiuIntvFunc.aPrimaryBits[i]%>] <%if(i>0){%>,<%}%>
                                    <%}%>
                                } = 'd0;
                            <%}%>
                            axi_seq<%=np_idx%> = ncore_axi_base_seq::type_id::create("axi_seq<%=np_idx%>");
                            axi_seq<%=np_idx%>.sequence_length = 1;
                            axi_seq<%=np_idx%>.start_addr[0] = addr[region];
                            axi_seq<%=np_idx%>.cache_value = 6'h0;
                            axi_seq<%=np_idx%>.txn_no = loop;
                            <%if(obj.AiuInfo[idx].fnNativeInterface.includes('AXI4') || obj.AiuInfo[idx].fnNativeInterface.includes('AXI5') ){%>
                            axi_seq<%=np_idx%>.xact_set = svt_axi_transaction::READ;
                            <% } else { %> 
                            axi_seq<%=np_idx%>.xact_set = svt_axi_transaction::COHERENT;
                            axi_seq<%=np_idx%>.transaction = svt_axi_transaction::READNOSNOOP;
                            <%}%>
                            axi_seq<%=np_idx%>.datawidth = <%=(Math.log2(obj.AiuInfo[idx].wData / 8))%>;
                            axi_seq<%=np_idx%>.burstlen = 64 >> <%=(Math.log2(obj.AiuInfo[idx].wData / 8))%>;
                            memregion_id = check_memregion_id(addr[region]);
                            `uvm_info("CUST_TB_IOAIU_READ_NON_COH_<%=idx%>",$sformatf("ADDR : %0h",axi_seq<%=np_idx%>.start_addr[0]),UVM_HIGH)
                            axi_seq<%=np_idx%>.start(axi_xact_seqr<%=np_idx%>);

                            latency = axi_seq<%=np_idx%>.latency;
                            //bandwidth = (64 / (latency*1.0)) * 1000000000.0;
                            bandwidth =  ((axi_seq<%=np_idx%>.burstlen * (2**axi_seq<%=np_idx%>.datawidth)) / latency) * 1000000.0;  // MB/s
                            if (loop == 0) begin
                                min_latency = latency;
                            end
                            else if (latency <= min_latency) begin
                                min_latency = latency;
                            end
                            if (latency >= max_latency) begin
                                max_latency = latency;
                            end
                            avg_latency = ((avg_latency * loop) + latency)/((loop+1)*1.0);
                            avg_bandwidth = ((avg_bandwidth * loop) + bandwidth)/((loop+1)*1.0);
                            end
	                        `uvm_info("body", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: READNOSNOOP, NUM_OF_TXNS: (%0d/%0d), Bandwidth: %0d MB/s, Latency: %.2f ps",region, memregion_id, loop+1, txn_count, bandwidth, latency), UVM_HIGH);
                            loop++;
                        end //repeat
	                    `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                    `uvm_info("body", $sformatf("Performance Results"), UVM_NONE);
	                    `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                    `uvm_info("summary", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: READNOSNOOP, TOTAL_NUM_OF_TXNS: %0d, Bandwidth(avg): %.2f MB/s, Latency(avg/min/max): %.2f ps/ %.2f ps/ %.2f ps",region, memregion_id, loop, avg_bandwidth, avg_latency, min_latency, max_latency), UVM_NONE);
                    end

                    //====================IOAIU Write Non Coherent Commands===============
                    foreach(addrMgrConst::memregions_info[region]) begin
                        bandwidth = 0;
                        latency = 0;
                        avg_bandwidth = 0;
                        avg_latency = 0;
                        loop = 0;
                        min_latency = 0;
                        max_latency = 0;
                        memregion_id = "UNKNOWN";
                        repeat(txn_count) begin
                        addr[region] = get_unique_addr(region);
                        unconnected = addrMgrConst::check_unmapped_add(.addr(addr[region]),.agent_id(<%=obj.AiuInfo[idx].FUnitId%>),.unit_unconnected(unit_unconnected));
                        if (!unconnected) begin
                            <%if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
                                {
                                    <%for(var i=obj.AiuInfo[idx].aNcaiuIntvFunc.aPrimaryBits.length-1; i>=0; i--){%>
                                        addr[region][<%=obj.AiuInfo[idx].aNcaiuIntvFunc.aPrimaryBits[i]%>] <%if(i>0){%>,<%}%>
                                    <%}%>
                                } = 'd0;
                            <%}%>
                            axi_seq<%=np_idx%> = ncore_axi_base_seq::type_id::create("axi_seq<%=np_idx%>");
                            axi_seq<%=np_idx%>.sequence_length = 1;
                            axi_seq<%=np_idx%>.start_addr[0] = addr[region];
                            axi_seq<%=np_idx%>.cache_value = 6'h0;
                            axi_seq<%=np_idx%>.txn_no = loop;
                            axi_seq<%=np_idx%>.datawidth = <%=(Math.log2(obj.AiuInfo[idx].wData / 8))%>;
                            axi_seq<%=np_idx%>.burstlen = 64 >> <%=(Math.log2(obj.AiuInfo[idx].wData / 8))%>;
                            <%if(obj.AiuInfo[idx].fnNativeInterface.includes('AXI4') || obj.AiuInfo[idx].fnNativeInterface.includes('AXI5') ){%>
                            axi_seq<%=np_idx%>.xact_set = svt_axi_transaction::WRITE;
                            <% } else { %> 
                            axi_seq<%=np_idx%>.xact_set = svt_axi_transaction::COHERENT;
                            axi_seq<%=np_idx%>.transaction = svt_axi_transaction::WRITENOSNOOP;
                            <%}%>
                            memregion_id = check_memregion_id(addr[region]);
                            `uvm_info("CUST_TB_IOAIU_WRITE_NON_COH_<%=idx%>",$sformatf("ADDR : %0h",axi_seq<%=np_idx%>.start_addr[0]),UVM_HIGH)
                            axi_seq<%=np_idx%>.start(axi_xact_seqr<%=np_idx%>);

                            latency = axi_seq<%=np_idx%>.latency;
                            //bandwidth = (64 / (latency*1.0)) * 1000000000.0;
                            bandwidth =  ((axi_seq<%=np_idx%>.burstlen * (2**axi_seq<%=np_idx%>.datawidth)) / latency) * 1000000.0;  // MB/s
                            if (loop == 0) begin
                                min_latency = latency;
                            end
                            else if (latency <= min_latency) begin
                                min_latency = latency;
                            end
                            if (latency >= max_latency) begin
                                max_latency = latency;
                            end
                            avg_latency = ((avg_latency * loop) + latency)/((loop+1)*1.0);
                            avg_bandwidth = ((avg_bandwidth * loop) + bandwidth)/((loop+1)*1.0);
                        end
	                        `uvm_info("body", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: WRITENOSNOOP, NUM_OF_TXNS: (%0d/%0d), Bandwidth: %0d MB/s, Latency: %.2f ps",region, memregion_id, loop+1, txn_count, bandwidth, latency), UVM_HIGH);
                            loop++;
                        end //repeat
	                        `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                        `uvm_info("body", $sformatf("Performance Results"), UVM_NONE);
	                        `uvm_info("body", $sformatf("==============================================================="), UVM_NONE);
	                        `uvm_info("summary", $sformatf("SOURCE: <%=obj.AiuInfo[idx].strRtlNamePrefix%> (<%=obj.AiuInfo[idx].fnNativeInterface%>), REGION: %0d %0s, TXN_TYPE: WRITENOSNOOP, TOTAL_NUM_OF_TXNS: %0d, Bandwidth(avg): %.2f MB/s, Latency(avg/min/max): %.2f ps/ %.2f ps/ %.2f ps",region, memregion_id, loop, avg_bandwidth, avg_latency, min_latency, max_latency), UVM_NONE);
                    end
                end  // begin
                <%np_idx += obj.AiuInfo[idx].nNativeInterfacePorts;%>
            <%}%>
        <%}%>
        join
    endtask: body

endclass: ncore_bandwidth_multi_vseq

