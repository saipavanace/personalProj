// DVM calculation
<%      var num_of_dvms = 0;
        for (var i = 0; i < obj.AiuInfo.length; i++) {  
            if(obj.AiuInfo[i].cmpInfo.nDvmSnpInFlight > 0) {
                num_of_dvms++;
            }
        }
        // Taking care of the case where ACE agent is only an issuer and there is another agent which is only a receiver
        if(!obj.isBridgeInterface && obj.Block === "aiu") {  
            if (num_of_dvms == 1 && obj.AiuInfo[obj.Id].cmpInfo.nDvmSnpInFlight == 0) {
                num_of_dvms = 2;
            }
        }
%>
<% var aiu;
if((obj.testBench === "fsys") || (obj.testBench == "emu") || (obj.testBench == "emu_t")) { aiu = obj.AiuInfo[obj.Id]; }
else { aiu = obj.DutInfo;}
%>

//-------------------------------------------------------------------------------------------------- 
// ACE transaction packets
//--------------------------------------------------------------------------------------------------
typedef bit[WXDATA-1:0]   data_size_t;
typedef bit[WXDATA/8-1:0] strb_size_t;
//-------------------------------------------------------------------------------------------------- 
// ACE Read address channel transaction packet (AR)
//-------------------------------------------------------------------------------------------------- 
class base_pkt_t extends uvm_sequence_item;
    `uvm_object_param_utils_begin(base_pkt_t)
    `uvm_object_utils_end
   

    axi_axaddr_security_t cacheline_addr_w_sec;
    axi_axaddr_security_t cacheline_addr_split;
    function new(string name = "base_pkt_t");
        super.new(name);
    endfunction : new
      
    <% if (obj.Block.includes('aiu')) { %>
    function void check_and_update_burst_length(input axi_axaddr_t addr, input bit sec, input axi_axburst_t burst, input axi_axsize_t size, inout int len);
        int core_id, native_core_id, len_tmp;
        bit unconnected_access, native_unconnected_access;

        bit [2:0] unit_unconnected;
        int num_bytes              = 2 ** size;
        int burst_length           = len + 1;
        int dtsize                 = num_bytes * burst_length;
        longint start_addr         = (addr/(WXDATA/8)) * (WXDATA/8);
        longint aligned_addr       = (start_addr/(num_bytes)) * num_bytes; 
        int beats_in_a_cacheline   = 64*8/WXDATA;

        longint cache_aligned_addr = (addr/(num_bytes * beats_in_a_cacheline)) * num_bytes * beats_in_a_cacheline;
        bit aligned           = (aligned_addr == start_addr);
        int total_split_count = 1;
        longint l_wrap_boundary = (start_addr/dtsize) * dtsize; 
        longint u_wrap_boundary = l_wrap_boundary + dtsize; 
        bit done;
        int itr = 0;

        native_core_id = 0;
        core_id = 0;
        <% if (aiu.nNativeInterfacePorts > 1) { %> 
            addrMgrConst::extract_intlv_bits_in_addr(addrMgrConst::mp_aiu_intv_bits[<%=obj.FUnitId%>].pri_bits, addr, native_core_id);
        <% } %> 
        native_unconnected_access = addrMgrConst::check_unmapped_add(.addr(addr),.agent_id(<%=obj.FUnitId%>),.unit_unconnected(unit_unconnected));
        
        //`uvm_info("AIU<%=obj.FUnitId%>", $sformatf("fn:check_and_update_burst_length native_unconnected_access:%0b reason(%0b)", native_unconnected_access, unit_unconnected),UVM_LOW)
        if (native_unconnected_access && !$test$plusargs("unmapped_add_access"))
            `uvm_error("AIU<%=obj.FUnitId%>", $sformatf("fn:check_and_update_burst_length - native address addr:0x%0h is unconnected reason:%0b", addr, unit_unconnected))

        //`uvm_info("AIU<%=obj.FUnitId%>", $sformatf("fn:check_and_update_burst_length i/p - native c%0d addr:0x%0h size:0x%0h len:0x%0h burst:%0p", native_core_id, addr, size, len, burst),UVM_LOW)
        
        len_tmp = len; 
        do 
            begin
                itr++;
                done = 1;
                burst_length = len_tmp + 1;
                dtsize = num_bytes * burst_length;
                start_addr = (addr/(WXDATA/8)) * (WXDATA/8);
                aligned_addr = (start_addr/(num_bytes)) * num_bytes;
                cache_aligned_addr = (addr/(num_bytes * beats_in_a_cacheline)) * num_bytes * beats_in_a_cacheline;
                aligned      = (aligned_addr == start_addr);
                l_wrap_boundary = (start_addr/dtsize) * dtsize; 
                u_wrap_boundary = l_wrap_boundary + dtsize; 
                total_split_count = 1;
                addrMgrConst::split_cacheable_addrq={};
                
                //`uvm_info("AIU<%=obj.FUnitId%>", $sformatf("fn:check_and_update_burst_length begin itr:%0d of while native c%0d addr:0x%0h size:0x%0h len_tmp:0x%0h burst:%0p aligned_addr:0x%0h", itr, native_core_id, addr, size, len_tmp, burst, aligned_addr),UVM_LOW)
                if (burst == AXIWRAP) begin 
                    //`uvm_info("AIU<%=obj.FUnitId%>", $sformatf("fn:check_and_update_burst_length native l_wrap_boundary:0x%0h u_wrap_boundary:0x%0h", l_wrap_boundary, u_wrap_boundary),UVM_LOW)
                end
               
                for (int i = 0; i < burst_length - 1; i++) begin : _num_split_count_loop_
                    if (aligned) begin
                        start_addr = start_addr + num_bytes;
                        if (burst == AXIWRAP) begin
                            if (start_addr >= u_wrap_boundary) begin
                                start_addr = l_wrap_boundary;
                            end
                        end
                    end
                    else begin
                        start_addr = aligned_addr + num_bytes; 
                        aligned    = 1;
                    end
                    if (start_addr[SYS_wSysCacheline-1:0] == '0 &&
                        (start_addr[WAXADDR-1:SYS_wSysCacheline] != addr[WAXADDR-1:SYS_wSysCacheline] || (burst == AXIWRAP && total_split_count > 1)) 
                        ) begin
                        total_split_count++;
                    end
                end : _num_split_count_loop_ 

                //`uvm_info("AIU<%=obj.FUnitId%>", $sformatf("fn:check_and_update_burst_length total_split_count:%0d", total_split_count),UVM_LOW)

                for (int i = 1; i < total_split_count; i++) begin: _all_split_txn_loop_
                    start_addr = cache_aligned_addr + (i * num_bytes * beats_in_a_cacheline); // Move to cacheline offset at "count"
                    if (burst === AXIWRAP) begin
                        if (start_addr >= u_wrap_boundary) begin
                            start_addr = l_wrap_boundary + (start_addr - u_wrap_boundary);
                        end
                    end
                    cacheline_addr_split=((start_addr >> 6) << 6) | (sec << addrMgrConst::ADDR_WIDTH);
                    addrMgrConst::split_cacheable_addrq.push_back(cacheline_addr_split);
           
                    <% if (aiu.nNativeInterfacePorts > 1) { %> 
                    addrMgrConst::extract_intlv_bits_in_addr(addrMgrConst::mp_aiu_intv_bits[<%=obj.FUnitId%>].pri_bits, start_addr, core_id);
                    <% } %> 
                    unconnected_access = addrMgrConst::check_unmapped_add(.addr(start_addr),.agent_id(<%=obj.FUnitId%>),.unit_unconnected(unit_unconnected));
                    //`uvm_info("AIU<%=obj.FUnitId%>", $sformatf("fn:check_and_update_burst_length addr_%0d:0x%0h core_id:%0d unconnected_access:%0b", i, start_addr, core_id, unconnected_access),UVM_LOW)
                    
                    if ((core_id != native_core_id) || (unconnected_access != native_unconnected_access) || (start_addr[WAXADDR-1:12] != addr[WAXADDR-1:12])) begin 
                        //`uvm_info("AIU<%=obj.FUnitId%>", $sformatf("fn:check_and_update_burst_length addr fail @ split_no:%0d native_core_id:%0d core_id:%0d unconnected_access:%0b reason(%0b) addr:0x%0h native_addr:0x%0h", i, native_core_id, core_id, unconnected_access, unit_unconnected, start_addr, addr),UVM_LOW)
                        done = 0;
                        break; 
                    end
                end: _all_split_txn_loop_
                //`uvm_info("AIU<%=obj.FUnitId%>", $sformatf("fn:check_and_update_burst_length end of while before len_tmp:%0d burst:%0p", len_tmp, burst),UVM_LOW)
        
                if (done == 0) begin: _done_
                    if (burst == AXIINCR) begin 
                        len_tmp--;
                    end else begin
                        if (len_tmp == 15) begin 
                            len_tmp = 7;
                        end else if (len_tmp == 7) begin 
                            len_tmp = 3;
                        end else if (len_tmp == 3) begin 
                            len_tmp = 1;
                        end else if (len_tmp == 1) begin 
                            len_tmp = 0;
                            burst = AXIINCR;
                            //`uvm_error("AIU<%=obj.FUnitId%>", $sformatf("fn:check_and_update_burst_length burst needs to the updated from WRAP to INCR with len=0"))
                            break;
                        end 
                    end
                end: _done_
                //`uvm_info("AIU<%=obj.FUnitId%>", $sformatf("fn:check_and_update_burst_length itr:%0d end of while after len_tmp:0x%0h(%0d) burst:%0p done:%0b", itr, len_tmp,len_tmp, burst, done),UVM_LOW)
            end
        while (!done && (len_tmp > 0));
        len = len_tmp;
    endfunction: check_and_update_burst_length
   <% } %>
 
endclass:base_pkt_t;

class axi4_read_addr_pkt_t extends base_pkt_t;
    rand  axi_arid_t          arid;
    rand  axi_axaddr_t        araddr;
    rand  axi_axlen_t         arlen;
    rand  axi_axsize_t        arsize;
    rand  axi_axburst_t       arburst;
    rand  axi_axlock_enum_t   arlock;
    rand  axi_arcache_enum_t  arcache;
    randc axi_axprot_t        arprot;
    <% if(obj.testBench == 'dii' || obj.testBench == 'dmi' || obj.testBench == 'fsys'|| obj.testBench == 'io_aiu') { %>
    `ifndef VCS
    randc axi_axqos_t         arqos;
    `else // `ifndef VCS
    rand axi_axqos_t         arqos;
    `endif // `ifndef VCS ... `else ... 
    <% } else {%>
    randc axi_axqos_t         arqos;
<% } %>
    //#Stimulus.IOAIU.axregion
    randc axi_axregion_t      arregion;
    //#Stimulus.IOAIU.axuser
    randc axi_aruser_t        aruser;
    rand  bit                                            useFullCL;
    rand  bit                                            use2FullCL;
    string                                               pkt_type;
    // Fix for weird monitor issue that is not getting the first request only if arid is 0
    rand bit                                             include_arid_0;
    rand bit                                             coh_domain;
    time                                                 t_pkt_seen_on_intf;
    int                                                  exclusive_weight;
    int  force_arcache;
    bit  constrained_addr;
    int  buf_rd_en;
    int  alloc_rd_en;
    bit         narrow_rd_en;
    bit         en_unaligned_addr;
    bit         use_ace_dvmsync;

    `uvm_object_param_utils_begin(axi4_read_addr_pkt_t)
        `uvm_field_int     (arid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (araddr, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (arlen, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (arsize, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (arburst, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_enum    (axi_axlock_enum_t, arlock, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_enum    (axi_arcache_enum_t, arcache, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (arprot, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (arqos, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (arregion, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (aruser, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    function new(string name = "axi4_read_addr_pkt_t");
        pkt_type = "AXI4";
        if(!$value$plusargs("exclusive_weight=%d", exclusive_weight)) begin
        <% if (! obj.useCache) { %>    
            std::randomize(exclusive_weight) with {exclusive_weight dist { 5:=60, 95:=20, 1:=10, 99:=10};};
        <% }  else { %>    
            exclusive_weight=0;
        <%}%>
        end
        if(!$value$plusargs("alloc_rd_en=%0d", alloc_rd_en)) begin
        	alloc_rd_en = -1;
        end
        if(!$value$plusargs("buf_rd_en=%0d", buf_rd_en)) begin
        	buf_rd_en = -1;
        end
        if ($test$plusargs("force_arcache")) force_arcache=1;
        if($test$plusargs("force_single_beat"))begin
        	narrow_rd_en = 1;
        end
        if($test$plusargs("en_unaligned_addr"))begin
        	en_unaligned_addr = 1;
        end
        if($test$plusargs("use_ace_dvmsync"))begin
        	use_ace_dvmsync = 1;
        end
    endfunction : new

    function bit do_compare_pkts(axi4_read_addr_pkt_t m_pkt);
        bit legal = 1;
        if (this.arid !== m_pkt.arid) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arid: 0x%0x Actual: arid: 0x%0x", pkt_type, this.arid, m_pkt.arid), UVM_NONE)
            legal = 0;
        end
        if (this.araddr !== m_pkt.araddr) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: araddr: 0x%0x Actual: araddr: 0x%0x", pkt_type, this.araddr, m_pkt.araddr), UVM_NONE)
            legal = 0;
        end
        if (this.arlen !== m_pkt.arlen) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arlen: 0x%0x Actual: arlen: 0x%0x", pkt_type, this.arlen, m_pkt.arlen), UVM_NONE)
            legal = 0;
        end
        if (this.arsize !== m_pkt.arsize) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arsize: 0x%0x Actual: arsize: 0x%0x", pkt_type, this.arsize, m_pkt.arsize), UVM_NONE)
            legal = 0;
        end
        if (this.arburst !== m_pkt.arburst) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arburst: 0x%0x Actual: arburst: 0x%0x", pkt_type, this.arburst, m_pkt.arburst), UVM_NONE) 
            legal = 0;
        end
        if (this.arlock !== m_pkt.arlock) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arlock: 0x%0x Actual: arlock: 0x%0x", pkt_type, this.arlock, m_pkt.arlock), UVM_NONE) 
            legal = 0;
        end
        if (WUSEACECACHE) begin
            if (this.arcache !== m_pkt.arcache) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arcache: 0x%0x Actual: arcache: 0x%0x", pkt_type, this.arcache, m_pkt.arcache), UVM_NONE) 
                legal = 0;
            end
        end
        if (WUSEACEPROT) begin
            if (this.arprot !== m_pkt.arprot) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arprot: 0x%0x Actual: arprot: 0x%0x", pkt_type, this.arprot, m_pkt.arprot), UVM_NONE) 
                legal = 0;
            end
        end
        if (WUSEACEQOS) begin
            if (this.arqos !== m_pkt.arqos) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arqos: 0x%0x Actual: arqos: 0x%0x", pkt_type, this.arqos, m_pkt.arqos), UVM_NONE) 
                legal = 0;
            end
        end
        if (WUSEACEREGION) begin
            if (this.arregion !== m_pkt.arregion) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arregion: 0x%0x Actual: arregion: 0x%0x", pkt_type, this.arregion, m_pkt.arregion), UVM_NONE) 
                legal = 0;
            end
        end
        if (WARUSER != 0) begin
            if (this.aruser !== m_pkt.aruser) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: aruser: 0x%0x Actual: aruser: 0x%0x", pkt_type, this.aruser, m_pkt.aruser), UVM_NONE) 
                legal = 0;
            end
        end


<% if(obj.testBench == 'dmi') { %>
        if($test$plusargs("wt_coh_noncoh_addr_collision")) begin
          legal = 1;
          if (this.arid !== m_pkt.arid) begin
              `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arid: 0x%0x Actual: arid: 0x%0x", pkt_type, this.arid, m_pkt.arid), UVM_NONE)
              legal = 0;
          end
          if (this.araddr !== m_pkt.araddr) begin
              `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: araddr: 0x%0x Actual: araddr: 0x%0x", pkt_type, this.araddr, m_pkt.araddr), UVM_NONE)
              legal = 0;
          end
        end
<% }  %>

        return legal;
    endfunction : do_compare_pkts

    function string sprint_pkt();
        
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("ID=0x%0x Addr=0x%0x Len=0x%0x Size=0x%0x BurstType=0x%0x Prot=0x%0x Cache=0b%0b QoS=0x%0x TIME=%0t"
                               , arid, araddr, arlen, arsize, arburst, arprot, arcache, arqos, t_pkt_seen_on_intf);  
        end else begin
            sprint_pkt = $sformatf("%0s READ AR: ID:0x%0x Addr:0x%0x Len:0x%0x Size:0x%0x BurstType:0x%0x NS:0x%0x Cache=0b%0b QoS=0x%0x Time:%0t"
                               , pkt_type, arid, araddr, arlen, arsize, arburst, arprot[1], arcache, arqos, t_pkt_seen_on_intf);  
        end
    endfunction : sprint_pkt

endclass : axi4_read_addr_pkt_t

class ace_read_addr_pkt_t extends axi4_read_addr_pkt_t;
    rand axi_axdomain_enum_t      ardomain;
    rand axi_arsnoop_t            arsnoop;
    rand ace_command_types_enum_t arcmdtype;
    rand axi_axbar_t              arbar;
    rand axi_arvmidext_t          arvmid;
    rand bit                      artrace;
    rand axi_arloop_t             arloop;
    rand axi_arnsaid_t            arnsaid;
    rand bit                      en_user_delay_after_txn;
    rand bit                      en_user_delay_before_txn;
    rand int                      val_user_delay_after_txn;
    rand int                      val_user_delay_before_txn;
    bit                           allow_arlock_1 = 0;
    int                           axi_trace_weight;
    bit                           dis_post_randomize = 0;
    bit en_qos;
     
<% if(obj.testBench == 'dii' || obj.testBench == 'dmi' || obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
   `ifdef VCS
    `define VCSorCDNS
   `elsif CDNS
    `define VCSorCDNS
   `endif 
<% }  %>
<% if(obj.testBench == 'dii' || obj.testBench == 'dmi' || obj.testBench == 'fsys' || obj.testBench == 'io_aiu') { %>
        int    en_axlen_127_255_vcs;
        int    unmapped_add_access;
<% }  %>
    constraint delay_c {
       soft  en_user_delay_after_txn==0;
       soft  en_user_delay_before_txn==0;
       soft  val_user_delay_after_txn==0;
       soft  val_user_delay_before_txn==0;
    };

    constraint c_arid {
        if (include_arid_0 == 0) {
            arid != 0;
        }
    };

    constraint c_arcmdtype_1 {
<% if (obj.fnNativeInterface == "ACE-LITE") { %>    
        arcmdtype inside {RDNOSNP , RDONCE, CLNSHRD, CLNINVL, MKINVL};
<% }
else if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
        //if (addrMgrConst::get_addr_gprar_nc(araddr)) {
        //    arcmdtype == RDNOSNP;
        //} else {
        //    arcmdtype == RDONCE;
        //}
        arcmdtype inside {RDNOSNP, RDONCE};
<% }  
else { %>    
        arcmdtype inside {RDNOSNP , RDONCE, RDSHRD, RDCLN, RDNOTSHRDDIR, RDUNQ, CLNUNQ, MKUNQ, CLNSHRD, CLNINVL, MKINVL, DVMMSG, DVMCMPL, RDONCECLNINVLD, RDONCEMAKEINVLD, CLNSHRDPERSIST};
<% } %>      
    };

    constraint c_arbar {
            arbar[0] == 1'b0;
    };

    constraint c_ardomain_0 {
        if ((arcmdtype == RDONCECLNINVLD) || (arcmdtype == RDONCEMAKEINVLD)) { 
            ardomain inside {'b01, 'b10};
        }
        if ((arcmdtype == MKINVL) || (arcmdtype == CLNINVL) || (arcmdtype == CLNSHRD) || (arcmdtype == CLNSHRDPERSIST)) { 
            ardomain inside {'b00, 'b01, 'b10};
        }
    };

    constraint c_arqos{
    if(en_qos==1) {
            arqos dist { [6:15] := 95,   [0:5] := 5};
                   }
            else {
            arqos dist { [5:15] := 95,   [0:4] := 5};
            }
    };


    constraint c_arsnoop_arcmdtype {
<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifdef VCS // CONC-11829
        (arcmdtype == RDNOSNP || arcmdtype == RDONCE || arcmdtype == BARRIER)         -> arsnoop == 'b0000;
`else        
        (arcmdtype == RDNOSNP)         -> arsnoop == 'b0000;
        (arcmdtype == RDONCE)          -> arsnoop == 'b0000;
`endif
<% } else { %>
        (arcmdtype == RDNOSNP)         -> arsnoop == 'b0000;
        (arcmdtype == RDONCE)          -> arsnoop == 'b0000;

<% } %>
        (arcmdtype == RDSHRD)          -> arsnoop == 'b0001;
        (arcmdtype == RDCLN)           -> arsnoop == 'b0010;
        (arcmdtype == RDNOTSHRDDIR)    -> arsnoop == 'b0011;
        (arcmdtype == RDUNQ)           -> arsnoop == 'b0111;
        (arcmdtype == CLNUNQ)          -> arsnoop == 'b1011;
        (arcmdtype == MKUNQ)           -> arsnoop == 'b1100;
        (arcmdtype == CLNSHRD)         -> arsnoop == 'b1000;
        (arcmdtype == CLNINVL)         -> arsnoop == 'b1001;
        (arcmdtype == MKINVL)          -> arsnoop == 'b1101;
<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifndef VCS // CONC-11829
        (arcmdtype == BARRIER)         -> arsnoop == 'b0000;
`endif
<% } else {%>
        (arcmdtype == BARRIER)         -> arsnoop == 'b0000;
<% } %>
        //#Stimulus.IOAIU.DVM.TxnConstraint.arsnoop
        (arcmdtype == DVMCMPL)         -> arsnoop == 'b1110;
        (arcmdtype == DVMMSG)          -> arsnoop == 'b1111;
        (arcmdtype == RDONCECLNINVLD)  -> arsnoop == 'b0100;
        (arcmdtype == RDONCEMAKEINVLD) -> arsnoop == 'b0101;
        (arcmdtype == CLNSHRDPERSIST)  -> arsnoop == 'b1010;
    };

    constraint order_cmdtype_1 { solve arcmdtype before arsnoop;};
    
   `ifndef  VCS  // CONC-11829
    constraint c_arsnoop {
            if (ardomain == SYSTEM) {
                arsnoop == 'b0000;
            }
            else if (ardomain == NONSHRBL) {
               //arsnoop inside {'b0000, 'b1000, 'b1001, 'b1101};
	       arsnoop inside {'b0000, 'b1000, 'b1001,'b1101,'b1010,'b1000,'b1001,'b1101};
            }
            else {
                arsnoop inside {'b0000, 'b0001, 'b0010, 'b0011, 'b0111, 'b1011, 'b1100, 'b1000, 'b1001, 'b1101, 'b1110, 'b1111, 'b0101, 'b0100, 'b1010};
            } 
    };
    constraint order_1 { solve  ardomain before arsnoop;};
   `endif

    <% if ((obj.fnNativeInterface != "AXI4") && (obj.fnNativeInterface != "AXI5")) { %>
    constraint c_ardomain {
        (arcache[1] == 0) -> ardomain == SYSTEM; 
        (arcache[3:2] != 0) -> ardomain != SYSTEM; 
        (arcache == RDEVNONBUF || arcache == RDEVBUF) -> ardomain == SYSTEM; 
        (arcache == RWBRALLOC || arcache == RWTWALLOC || arcache == RWBWALLOC || arcache == RWTRWALLOC || arcache == RWBRWALLOC) -> ardomain inside {NONSHRBL, INNRSHRBL, OUTRSHRBL};
        (arcmdtype == RDONCE || arcmdtype == RDSHRD || arcmdtype == RDCLN || arcmdtype == RDNOTSHRDDIR || arcmdtype == RDUNQ || arcmdtype == CLNUNQ || arcmdtype == MKUNQ ) -> ardomain inside {INNRSHRBL, OUTRSHRBL};  //Coherent
        (arcmdtype == RDNOSNP) -> ardomain inside {SYSTEM, NONSHRBL};   //Non-snooping
        (arcmdtype == CLNSHRD || arcmdtype == CLNINVL || arcmdtype == MKINVL || arcmdtype == CLNSHRDPERSIST) -> ardomain inside {NONSHRBL,INNRSHRBL, OUTRSHRBL};   //Cache maintenance
    };
    <% } %>
    

<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifdef VCS // CONC-11829
    constraint order_2_0 { solve arcache, arcmdtype before ardomain;};
    constraint order_2_1 { solve arcmdtype before coh_domain;};
`else    
    constraint order_2 { solve arcache before ardomain;};
`endif
<% } else {%>
    constraint order_2 { solve arcache before ardomain;};
<% } %>


    // The following constraints are only for cache line size requests
    constraint c_arlen {
        if (arcmdtype == RDCLN          ||
            arcmdtype == RDNOTSHRDDIR   ||
            arcmdtype == RDSHRD         ||
            arcmdtype == RDUNQ          ||
            arcmdtype == CLNUNQ         ||
            arcmdtype == MKUNQ          ||
            arcmdtype == CLNSHRD        ||
            arcmdtype == CLNSHRDPERSIST ||
            arcmdtype == CLNINVL        ||
            arcmdtype == MKINVL
        ) { 
            arlen inside {0, 1, 3, 7, 15};
        }
        (arburst == AXIWRAP) -> arlen inside {1, 3, 7, 15};
        
        if (arcmdtype != BARRIER &&
            arcmdtype != DVMMSG  &&
            arcmdtype != RDONCEMAKEINVLD &&
            arcmdtype != RDONCECLNINVLD &&
            arcmdtype != DVMCMPL &&
            arcmdtype != RDONCE  &&
            arcmdtype != RDNOSNP
        ){        
               arlen  == ((SYS_nSysCacheline*8/(WXDATA)) - 1);
        }
        <% if(obj.testBench == 'dii' || obj.testBench == 'dmi' || obj.testBench == 'fsys' || obj.testBench == 'io_aiu') { %>
        `ifndef VCS
        if ($test$plusargs("en_axlen_127_255")) {
            arlen dist {127 :=50, 255:=50};
         }
        `elsif VCS // `ifndef VCS
         if (en_axlen_127_255_vcs <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %> && arcmdtype != RDONCE  <%}%>) {
            arlen dist {127 :=50, 255:=50};
         }
        `endif  // `ifndef VCS 
      <% } else {%>
        if ($test$plusargs("en_axlen_127_255")) {
         arlen dist {127 :=50, 255:=50};
        }
      <% } %>
        if (arcmdtype == RDNOSNP) {
            arlen dist { [0 : ((SYS_nSysCacheline*8/(WXDATA)) - 2)] := 50,   ((SYS_nSysCacheline*8/(WXDATA)) - 1) := 50, [(SYS_nSysCacheline*8/(WXDATA)) : (2*SYS_nSysCacheline*8/(WXDATA))] := 50, [((2*SYS_nSysCacheline*8/(WXDATA))+1) : 255] := 10 };
        } 
        <% if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %> 

        if (arcmdtype == RDONCE) {
            arlen dist { [0 : ((SYS_nSysCacheline*8/(WXDATA)) - 2)] := 50,   ((SYS_nSysCacheline*8/(WXDATA)) - 1) := 50, [(SYS_nSysCacheline*8/(WXDATA)) : (2*SYS_nSysCacheline*8/(WXDATA))] := 50, [((2*SYS_nSysCacheline*8/(WXDATA))+1) : 255] := 10 };
        } 

        <% } else { %>
        //CONC-11571 coherent multiline transactions from ACE, ACE-LITE, ACE-LITE-E are not supported
        if (arcmdtype == RDONCE) {
            arlen dist { [0 : ((SYS_nSysCacheline*8/(WXDATA)) - 2)] := 25,   ((SYS_nSysCacheline*8/(WXDATA)) - 1) := 75 };
        } 
        <% } %>      
            
        //AXI_ACE_Update_v3.0.pdf
        //ReadOnceCleanInvalid and ReadOnceMakeInvalid transactions are only permitted to access one cache line. 
        //They are permitted to access less than a cache line, but they must not cross a cache line boundary.
        if ((arcmdtype == RDONCECLNINVLD) || (arcmdtype == RDONCEMAKEINVLD)) {
            arlen dist { [0 : ((SYS_nSysCacheline*8/(WXDATA)) - 2)] := 50,   ((SYS_nSysCacheline*8/(WXDATA)) - 1) := 50};
        }
    };
<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifdef VCS // CONC-11829
    constraint order_3_0 { solve arcmdtype,arlock,arburst before arlen;};
    constraint order_3_1 { solve arcmdtype,arlock,arburst before arsize;};
`else
    constraint order_3 { solve arcmdtype,arsize,arlock,arburst before arlen;};
`endif
<% } else { %>
    constraint order_3 { solve arcmdtype,arsize,arlock,arburst before arlen;};
<% } %>

    // For EXCLUSIVE access, the address must be aligned to 
    // the total number of bytes transferred
    constraint exclusive_txn_addr_aligned_c {
      if (arlock == EXCLUSIVE) {
        ((arlen+1) << arsize) inside {1,2,4,8,16,32,64,128};
      }
    };

    // IOAIU only supports single beat narrow transfer
    constraint c_arlen_arsize {
        if (arlen == 0) {
            (WXDATA == 8)    -> arsize <= AXI1B;
            (WXDATA == 16)   -> arsize <= AXI2B;
            (WXDATA == 32)   -> arsize <= AXI4B;
            (WXDATA == 64)   -> arsize <= AXI8B;
            (WXDATA == 128)  -> arsize <= AXI16B;
            (WXDATA == 256)  -> arsize <= AXI32B;
            (WXDATA == 512)  -> arsize <= AXI64B;
            (WXDATA == 1024) -> arsize <= AXI128B;
        }
        else {
            (WXDATA == 8)    -> arsize == AXI1B;
            (WXDATA == 16)   -> arsize == AXI2B;
            (WXDATA == 32)   -> arsize == AXI4B;
            (WXDATA == 64)   -> arsize == AXI8B;
            (WXDATA == 128)  -> arsize == AXI16B;
            (WXDATA == 256)  -> arsize == AXI32B;
            (WXDATA == 512)  -> arsize == AXI64B;
            (WXDATA == 1024) -> arsize == AXI128B;
        }


    };

    constraint order_4 { solve arcmdtype before arsize;};

    constraint c_arburst {
        <% if (obj.Block.includes('aiu') && (aiu.orderedWriteObservation == true)) {  %> 
            arburst == AXIINCR;
        <% } else { %> 
        arburst inside {AXIINCR, AXIWRAP};

        // Section 1.2 NCore sys spec Burst limitations
        if (arcache[1] == 0
            && (
                ((arlen + 1) * (2 ** arsize)) > 64
            )
            ) {
            arburst == AXIINCR;
        }
        <%}%>
    };

    constraint order_5 { solve arcmdtype before arburst;};

    constraint c_arcache {
    	
        if ((arcmdtype inside {DVMMSG, DVMCMPL}) == 0) {
         	if (alloc_rd_en == 0) {
			(arcache inside {RDEVNONBUF,RDEVBUF,RNORNCNONBUF,RNORNCBUF,RWTWALLOC,RWBWALLOC});
		}
         	if (alloc_rd_en == 1) {
			!(arcache inside {RDEVNONBUF,RDEVBUF,RNORNCNONBUF,RNORNCBUF,RWTWALLOC,RWBWALLOC});
		}
        	if (buf_rd_en == 0) {
			(arcache inside {RDEVNONBUF,RNORNCNONBUF,RWTWALLOC,RWBWALLOC,RWTRWALLOC});
		}
         	if (buf_rd_en == 1) {
			!(arcache inside {RDEVNONBUF,RNORNCNONBUF,RWTWALLOC,RWBWALLOC,RWTRWALLOC});
		}
	} else {
	//#Stimulus.IOAIU.DVM.TxnCostraint.arcache
	    arcache == 'b0010; 
	}

  `ifdef VCS 
	 //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
         //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
         //Non coherent GPRA access do not have restrictions
         //In general all coherent transactions are  buffer-able
        <% if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %> 
   	   if(unmapped_add_access==0) {
           (arcmdtype == RDONCE) -> arcache[1] == 'b1;
           (arcmdtype == RDONCE) -> arcache[0] dist { 1:=98,0:=2};
	      }
        <% } %>
  `endif
        //Spec section C3.1.6 Table C3-12
        <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
        if (arcmdtype == RDCLN          ||
            arcmdtype == RDONCE         ||
            arcmdtype == RDNOTSHRDDIR   ||
            arcmdtype == RDSHRD         ||
            arcmdtype == RDUNQ          ||
            arcmdtype == CLNUNQ         ||
            arcmdtype == MKUNQ          ||
            arcmdtype == CLNSHRD        ||
            arcmdtype == CLNSHRDPERSIST ||
            arcmdtype == CLNINVL        ||
            arcmdtype == MKINVL
        ) { 
            arcache[1] == 1;
        }
        <% } %>
	
         if (force_arcache) {arcache[3:2] == 2'b11;}

	  //ARM IHI 0022E A7.2 Exclusive accesses A7.2.4 Exclusive access restrictions
	  //The value of the AxCACHE signals must guarantee that the slave that is monitoring the exclusive access sees the transaction. 
	  //For example, an exclusive access must not have an AxCACHE value that indicates that the transaction is Cacheable.
     	(arlock == EXCLUSIVE) -> (arcache inside {RDEVNONBUF, RDEVBUF, RNORNCNONBUF, RNORNCBUF});

 	 solve arlock before arcache;
	 solve arcmdtype before arcache;
   };

    constraint c_arlock{
        if (arcmdtype == RDNOTSHRDDIR   ||
            arcmdtype == RDONCE         ||
            arcmdtype == RDUNQ          ||
            arcmdtype == MKUNQ          ||
            arcmdtype == CLNSHRD        ||
            arcmdtype == CLNSHRDPERSIST ||
            arcmdtype == CLNINVL        ||
            arcmdtype == MKINVL         ||
            arcmdtype == RDONCECLNINVLD ||
            arcmdtype == RDONCEMAKEINVLD
        ) { 
            arlock == NORMAL;
        }

<% if (((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) && (obj.orderedWriteObservation = false)) { %> 
        if ((arcmdtype == RDNOSNP) && addrMgrConst::get_addr_gprar_nc(araddr)) {
<%} else if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
        if (arcmdtype inside {RDCLN, RDSHRD, CLNUNQ, RDNOSNP}) { 
<%} else { %>
        if (arcmdtype == RDNOSNP) {
<%} %>
			arlock dist {NORMAL := (100-exclusive_weight), EXCLUSIVE := exclusive_weight};
		} else {
			arlock == NORMAL;
		}

	 solve arcmdtype before arlock;
    };

    constraint order_7 { solve coh_domain before ardomain;};

    constraint c_ardomain_1{
        if(coh_domain) {
            ardomain inside {INNRSHRBL, OUTRSHRBL};
        } else {
            ardomain inside {NONSHRBL, SYSTEM};
        }
    };
    //#Stimulus.IOAIU.AXtrace
    <% if (obj.fnNativeInterface == "ACELITE-E") { %>    
    constraint c_artrace_0{
       artrace dist {0 := (100-axi_trace_weight), 1 := axi_trace_weight};
    };
    <% } %>

    function void pre_randomize();
        super.pre_randomize();
      
      <% if(obj.testBench == 'dii' || obj.testBench == 'io_aiu') { %>
        en_axlen_127_255_vcs = 0;    
        if ($test$plusargs("en_axlen_127_255"))    en_axlen_127_255_vcs = 1;                                          
        unmapped_add_access = 0;    
        if ($test$plusargs("unmapped_add_access"))    unmapped_add_access = 1;                                          
     <% }  %>

        if ($test$plusargs("en_qos"))    en_qos = 1;                                          
        else en_qos=0;
    endfunction: pre_randomize

    function void post_randomize();
        int outgoing_data_size;
        bit [2:0] unit_unconnected;
        axi_axaddr_t araddr_tmp;
        int max_axlen, loop;
        int msb, total_txfr_size;
        int dest_id;
        int fnmem_region_idx;
        bit fnd=0; 

        if(narrow_rd_en==1 && arburst == AXIINCR && arcmdtype inside {RDONCEMAKEINVLD,RDONCECLNINVLD,RDONCE,RDNOSNP}) begin
        arlen=0;
        case (WXDATA)
                8    : arsize = $urandom_range(0,AXI1B);
                16   : arsize = $urandom_range(0,AXI2B);
                32   : arsize = $urandom_range(0,AXI4B);
                64   : arsize = $urandom_range(0,AXI8B);
                128  : arsize = $urandom_range(0,AXI16B);
                256  : arsize = $urandom_range(0,AXI32B);
                512  : arsize = $urandom_range(0,AXI64B);
                1024 : arsize = $urandom_range(0,AXI128B);
            endcase

        end

	//`uvm_info(get_type_name(), $sformatf("AIU<%=obj.FUnitId%> post_randomize begin araddr:0x%0h arlen:0x%0h arcmdtype:%0p arcache:%0p arcache:0x%0h arid:0x%0h", araddr, arlen, arcmdtype, arcache, arcache, arid),UVM_LOW)
        
        //adding for unaligned addr
        if((arcmdtype inside {DVMMSG, DVMCMPL}) == 0) begin //Spec: table C12-4
            if(en_unaligned_addr) begin:_unaligned_addr //Spec: table C12-4
                if(arburst == AXIINCR) begin
                    if (is_cacheline_size_txn())
                        araddr[SYS_wSysCacheline-1:0] = '0; 
                    else begin
                        araddr[SYS_wSysCacheline-1:0]=$urandom_range(0,SYS_nSysCacheline-1);
                        if(narrow_rd_en == 1) araddr[SYS_wSysCacheline-1:0]=$urandom_range((1 << SYS_wSysCacheline)-1,0);
                        if($test$plusargs("wide_txn_offset") || $test$plusargs("mid_offset")) begin 
                            araddr[SYS_wSysCacheline-1:0]=$urandom_range((1 << SYS_wSysCacheline)-1,0);
                            araddr[$clog2(<%=obj.wData%>/8)-1:0]='d0; 
                        end
                        if($test$plusargs("lwr_offset")) begin 
                            araddr[SYS_wSysCacheline-1:0]='d0;
                        end
                        if($test$plusargs("upr_offset")) begin 
                            araddr[SYS_wSysCacheline-1:0]=(1 << SYS_wSysCacheline)-1;
                            araddr[$clog2(<%=obj.wData%>/8)-1:0]='d0; 
                        end
                    end
                end   
                if(arburst == AXIWRAP) begin
                    //A3.4.1 Address structure : For WRAPs the start address must be aligned to the size of each transfer
                    araddr[WLOGXDATA-1:0] = '0;
                    araddr[SYS_wSysCacheline-1:WLOGXDATA] = $urandom;
                end   
            end:_unaligned_addr
            else begin:_default_case
                if (is_cacheline_size_txn()) begin
                    if(arburst == AXIINCR) 
                        araddr[SYS_wSysCacheline-1:0] = '0; 
                    else
                        araddr[WLOGXDATA-1:0] = '0;
                end
            end:_default_case
        end

        //AXI_ACE_Update_v3.0.pdf
        //ReadOnce, ReadOnceCleanInvalid and ReadOnceMakeInvalid transactions are only permitted to access one cache line. 
        //They are permitted to access less than a cache line, but they must not cross a cache line boundary.
              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
        if ((arcmdtype inside {RDONCECLNINVLD, RDONCEMAKEINVLD, RDONCE}) && arburst == AXIINCR) begin
           if ((araddr[SYS_wSysCacheline-1:0] + ((arlen+1) * 2** arsize)) > (1 << SYS_wSysCacheline) ) begin 
               araddr[SYS_wSysCacheline-1:0] = '0;
           end
        end 
              <%}%>

        //3.4 Ncore Proxy Cache update Architecture Specification v0.87.1
        //a. It is illegal to send Device type transactions to an address range mapped to normal memory.
        // NCOR-199
        if ((arcmdtype inside {DVMMSG, DVMCMPL}) == 0) begin
            dest_id = addrMgrConst::map_addr2dmi_or_dii(araddr,fnmem_region_idx);
            if(unmapped_add_access==0 && addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DMI) arcache[1] = 1;
        end
        
        if ($test$plusargs("prot_rand_disable")) begin
            arprot[1] = 0;
        end
        <% if (obj.testBench == "ioaiu") { %>
        if($test$plusargs("en_max_arlen_txn") && is_cacheline_size_txn() == 0) begin
            if (arburst == AXIINCR && arlock  == NORMAL && (arcmdtype == RDNOSNP <% if (obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") { %> ||  arcmdtype == RDONCE <%}%>)) begin
               <% if(obj.DutInfo.nNativeInterfacePorts > 1) {%>
                      araddr [(<%=obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]%>)-1:0] = '0;
                      if(!dis_post_randomize) begin
                          if(WXDATA/8 == 2**arsize)
                          arlen = 2**<%=obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]%>/(2**arsize) > 8'hff ? 8'hff : 4096/(2**arsize);
                      end
               <%} else {%>
                if(!dis_post_randomize) begin
                    if(WXDATA/8 == 2**arsize)
                    arlen = 4096/(2**arsize) > 8'hff ? 8'hff : 4096/(2**arsize);
                end 
                araddr[11:0] = '0;
               <%}%>
                
            end
        end
        <%}%>

        // allow plus arg to define arqos
        $value$plusargs("ioaiu_arqos=%d", arqos);

        //CONC-9935 Wrap non modifiable burst which cross 64-byte boundary are not supported cf Ncore Supplemental Architecture Specification.pdf
        if (arburst == AXIWRAP && arcache[1]==0) begin:_wrap_64b 
            outgoing_data_size = ((arlen+1)*(2**arsize));
	    while (outgoing_data_size > 64) begin: _while_64b
	        if (arsize > AXI64B) begin
                    if(dis_post_randomize) begin
                        `uvm_error(get_type_name(), $sformatf("incorrect arsize value is passed; arlen:0x%0h ,arsize:0x%0h. Wrap non modifiable burst which cross 64-byte boundary are not supported", arlen, arsize))
                    end
		    arsize--;	
		end else begin
                    if(dis_post_randomize) begin
                        `uvm_error(get_type_name(), $sformatf("incorrect arlen value is passed; arlen:0x%0h ,arsize:0x%0h. Wrap non modifiable burst which cross 64-byte boundary are not supported", arlen, arsize))
                    end
		    arlen--;
		end
		outgoing_data_size = ((arlen+1)*(2**arsize));
            end:_while_64b	
        end: _wrap_64b
       
        //For exclusives, address should be aligned to total size of transfer
        //CONC-15191 in exlcusive txn updated addr is unconnected addr then its coverted to NORMAL txn with old addr
        if (arlock == EXCLUSIVE) begin 
	  total_txfr_size = (arlen + 1) << arsize;
	  msb = $clog2(total_txfr_size);
          if(addrMgrConst::check_unmapped_add(.addr((araddr >> msb) << msb),.agent_id(<%=obj.FUnitId%>),.unit_unconnected(unit_unconnected))) begin
            arlock=NORMAL;
          end  else begin
	    araddr = (araddr >> msb) << msb;
	  end
	end
        
        <% if (obj.Block.includes('aiu')) { %> 
            
            if ((arcmdtype inside {DVMMSG, DVMCMPL}) == 0) begin 
                //`uvm_info(get_type_name(), $sformatf("AIU<%=obj.FUnitId%> rd old len:%0d", arlen),UVM_LOW)
                check_and_update_burst_length(araddr, arprot[1], arburst,arsize,arlen);
                //`uvm_info(get_type_name(), $sformatf("AIU<%=obj.FUnitId%> rd updated len:%0d", arlen),UVM_LOW)
            end

        <%}%>   
	
<% if(obj.testBench == "fsys") { %>
	if ($test$plusargs("random_gpra_nsx")) begin
  	//#Stimulus.FSYS.GPRAR.NS_zero.withatleast.oneTxnSecure
    	arprot[1] = addrMgrConst::get_addr_gprar_nsx(araddr) ;
	end
<% } %>  
        
     <% if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %> 

    //`uvm_info(get_type_name(), $sformatf("AIU<%=obj.FUnitId%> arlen:0x%0h arcmdtype:%0p arcache:%0p arcache:0x%0h arid:0x%0h", arlen, arcmdtype, arcache, arcache, arid),UVM_LOW)
     //TODO: should be re-evaluated when CONC-15264 is done
    //If an address was once access with cacheable attributes, it should always be accessed with Cacheable attributes.
    //CONC-15788  
    cacheline_addr_w_sec = ({arprot[1],araddr} >> 6) << 6;
        
    //`uvm_info(get_type_name(), $sformatf("AIU<%=obj.FUnitId%> araddr:0x%0h cacheline_addr:0x%0h", araddr, cacheline_addr_w_sec),UVM_LOW)
    if (arcache[3:2] == 'b00) begin 
       if(cacheline_addr_w_sec inside {addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>]}) begin 
         //`uvm_info(get_type_name(), $sformatf("axcache_cacheable_addrq:%0p", addrMgrConst::axcache_cacheable_addrq),UVM_LOW)
         //`uvm_warning(get_type_name(), $sformatf("cmdtype:%0p cacheline_addr_w_sec:0x%0h araddr:0x%0h arprot_1:%0b arcache:0x%0h", arcmdtype, cacheline_addr_w_sec, araddr, arprot[1], arcache))
         arcache[3:2] = $urandom_range(1,3);
         arcache[1] = 1;
         arlock=NORMAL;
         //`uvm_info(get_type_name(), $sformatf("updated arcache:0x%0h since orig addr is in axcache_cacheable_addrq[<%=obj.FUnitId%>]", arcache),UVM_LOW)
       end else begin 
        // `uvm_info(get_type_name(), $sformatf("split_cacheable_addrq:%0p", addrMgrConst::split_cacheable_addrq),UVM_LOW)
         fnd = 0;
         foreach(addrMgrConst::split_cacheable_addrq[i]) begin
            if (addrMgrConst::split_cacheable_addrq[i] inside {addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>]}) begin
                fnd = 1;
                break;
            end
         end
         if (fnd == 1) begin        
             arcache[3:2] = $urandom_range(1,3);
             arcache[1] = 1;
             arlock=NORMAL;
             //`uvm_info(get_type_name(), $sformatf("updated arcache:0x%0h since one of the split addr is in cacheable_addrq", arcache),UVM_LOW)
          end
       end
    end
    //Adding the address to cacheable_addrq. 
    if ((arcache[3:2] != 'b00) && (arcache[1] == 1) && !(cacheline_addr_w_sec inside {addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>]})) begin 
	addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>].push_back(cacheline_addr_w_sec);
        //`uvm_info(get_type_name(), $sformatf("cacheline_addr:0x%0h pushed into addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>] new size:%0d", cacheline_addr_w_sec,addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>].size()),UVM_LOW)
      foreach(addrMgrConst::split_cacheable_addrq[i]) begin
	addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>].push_back(addrMgrConst::split_cacheable_addrq[i]);
        //`uvm_info(get_type_name(), $sformatf("split cacheline_addr:0x%0h pushed into addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>] new size:%0d", addrMgrConst::split_cacheable_addrq[i], addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>].size()),UVM_LOW)
      end  
    end
    <% } %>

    endfunction : post_randomize

    // Constraints below are for DVM

<% if(obj.Block !== 'dmi') { %>
    //#Stimulus.IOAIU.DVM.TxnCostraint.araddr
    constraint c_araddr_4{
        if (arcmdtype == DVMMSG) { 
            //#Stimulus.IOAIU.DVM.TxnCostraint.araddr.MsgType
            //araddr[WAXADDR-1:32] == '0;
            //#Stimulus.IOAIU.DVM.TxnCostraint.araddr.Completion
            araddr[14:12] == 'b100                          -> araddr[15] == 'b1;
            araddr[14:12] == 'b100                          -> araddr[11:0] == '0;
            araddr[14:12] != 'b100                          -> araddr[15] == 'b0;
            //#Stimulus.IOAIU.DVM.TxnCostraint.araddr.MsgType
            araddr[14:12] inside {'b000, 'b001, 'b010, 'b011, 'b100, 'b110};
            //#Stimulus.IOAIU.DVM.TxnCostraint.araddr.Security
            <% if (obj.DVMVersionSupport < 132) { /*DVMVersionSupport  = 132 -> DVM v8.4  */ %> 
            araddr[9:8]                                     != 'b01;
            <% } %>
            //#Stimulus.IOAIU.DVM.TxnCostraint.araddr.Range
            //araddr[7]                                       == 'b0;
            //araddr[14:12] == 'b000                        -> araddr[7] = $urandom;
            //OR
            <% if (obj.DVMVersionSupport >= 132) {   //DVMVersionSupport = 132 -> DVM v8.4 %>
            araddr[14:12] != 'b000                        -> araddr[7] == 'b0;  //Range is constrained to 0 when DVM OpType != TLBI
            <% } else { %>
            araddr[7]                                       == 'b0;
            <% } %>
            //#Stimulus.IOAIU.DVM.TxnCostraint.araddr.VMID
            //#Stimulus.IOAIU.DVM.TxnCostraint.araddr.ASID
            //#Stimulus.IOAIU.DVM.TxnCostraint.araddr.Leaf
            //#Stimulus.IOAIU.DVM.TxnCostraint.araddr.Stage
            araddr[0] == 'b0                               -> araddr[3:2] != 'b11;
            araddr[1]                                       == 'b0;
        }
        if (arcmdtype == DVMCMPL) { 
            araddr[WAXADDR-1:0] == '0;
        }
    };

    <% if(num_of_dvms < 2) { %>
        constraint c_araddr_5{
            if (arcmdtype == DVMMSG && use_ace_dvmsync==0) { 
                araddr[14:12] != 'b100;
            }
        }
    <% } %>
<% } %>
    //#Stimulus.IOAIU.DVM.TxnCostraint.arburst
    constraint c_arburst_4{
        if (arcmdtype == DVMMSG ||
            arcmdtype == DVMCMPL
        ) { 
            arburst == AXIINCR;
        }
    };

    //#Stimulus.IOAIU.DVM.TxnCostraint.arlen
    constraint c_arlen_4{
        if (arcmdtype == DVMMSG ||
            arcmdtype == DVMCMPL
        ) { 
            arlen == 0; 
        }
    };

    //#Stimulus.IOAIU.DVM.TxnCostraint.arsize
    constraint c_arsize_4{
        if (arcmdtype == DVMMSG ||
            arcmdtype == DVMCMPL
        ) { 
            (WXDATA == 8)    -> arsize == AXI1B;
            (WXDATA == 16)   -> arsize == AXI2B;
            (WXDATA == 32)   -> arsize == AXI4B;
            (WXDATA == 64)   -> arsize == AXI8B;
            (WXDATA == 128)  -> arsize == AXI16B;
            (WXDATA == 256)  -> arsize == AXI32B;
            (WXDATA == 512)  -> arsize == AXI64B;
            (WXDATA == 1024) -> arsize == AXI128B;
        }
    };

    //#Stimulus.IOAIU.DVM.TxnCostraint.arlock
    constraint c_arlock_4{
        if (arcmdtype == DVMMSG ||
            arcmdtype == DVMCMPL
        ) { 
            arlock == 'b0; 
        }
    };

    //#Stimulus.IOAIU.DVM.TxnCostraint.ardomain
    constraint c_ardomain_4{
        if (arcmdtype == DVMMSG ||
            arcmdtype == DVMCMPL
        ) { 
            ardomain inside {INNRSHRBL, OUTRSHRBL};
        }
    };


    <% if(obj.testBench == 'fsys') { %>   //CONC-12247 TEMP constrain till MAES-6334 is not resolved 
    constraint c_arvmid{
        arvmid == 0;
    }
    <% } %>

    `uvm_object_param_utils_begin(ace_read_addr_pkt_t)
        `uvm_field_enum    (axi_axdomain_enum_t, ardomain, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (arsnoop, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (arbar, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (arvmid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (artrace, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (arloop, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (arnsaid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (en_user_delay_after_txn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (en_user_delay_before_txn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (val_user_delay_after_txn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (val_user_delay_before_txn, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    function new(string name = "ace_read_addr_pkt_t");
        pkt_type = "ACE";
        axi_trace_weight = 0;
        //std::randomize(axi_trace_weight) with {axi_trace_weight dist { 0:=25, 25:=25, 50:=25, 100:=25 };};
        $value$plusargs("native_trace_weight=%d", axi_trace_weight);
        $value$plusargs("axi_trace_weight=%d", axi_trace_weight);
    endfunction : new

    function string sprint_pkt();
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("ID=0x%0x Addr=0x%0x Type=%0s Len=0x%0x Size=0x%0x BurstType=0x%0x Prot=0x%0x Lock=0x%0x  Cache=0x%0x QoS=0x%0x TIME=%0t"
                               , arid, araddr, print_snoop_type(), arlen, arsize, arburst, arprot, arlock,  arcache, arqos, t_pkt_seen_on_intf);  
        end else begin
            sprint_pkt = $sformatf("%0s READ AR: ID:0x%0x Addr:0x%0x Type:%0s Len:0x%0x Size:0x%0x BurstType:0x%0x NS:0x%0x Lock:0x%0x Cache:0x%0x QoS:0x%0x Domain:%0d Snoop:0x%0h %0s Time:%0t"
                               , pkt_type, arid, araddr, print_snoop_type(), arlen, arsize, arburst, arprot[1], arlock, arcache, arqos, ardomain, arsnoop, ((print_snoop_type() == "DVMMSG" ? $psprintf("VmidExt:0x%0x DVMOpType:%0s", arvmid, print_dvmop_type()) : "")), t_pkt_seen_on_intf); 

            <%if(obj.eTrace > 0) { %>
            sprint_pkt = $sformatf("%0s Trace: 0x%0x", sprint_pkt, artrace);
            <% } %>
        end
    endfunction : sprint_pkt
    
    function string print_snoop_type(); 
        <% if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %> 
            if (addrMgrConst::get_addr_gprar_nc(araddr))
                print_snoop_type = "RDNOSNP";
            else 
                print_snoop_type = "RDONCE";
        <%} else { %>
            case ({ this.ardomain, this.arsnoop}) 
                'b000000, 'b110000: print_snoop_type = "RDNOSNP";
                'b010000, 'b100000: print_snoop_type = "RDONCE";
                'b010001, 'b100001: print_snoop_type = "RDSHRD";
                'b010010, 'b100010: print_snoop_type = "RDCLN";
                'b010011, 'b100011: print_snoop_type = "RDNOTSHRDDIR";
                'b010111, 'b100111: print_snoop_type = "RDUNQ";
                'b011011, 'b101011: print_snoop_type = "CLNUNQ";
                'b011100, 'b101100: print_snoop_type = "MKUNQ";
                'b001000, 'b011000,
                'b101000           : print_snoop_type = "CLNSHRD";
                'b001001, 'b011001,
                'b101001           : print_snoop_type = "CLNINVL";
                'b001101, 'b011101,
                'b101101           : print_snoop_type = "MKINVL";
                'b011110, 'b101110: print_snoop_type = "DVMCMPL";
                'b011111, 'b101111: print_snoop_type = "DVMMSG";
                'b001010, 'b011010,
                'b101010           : print_snoop_type = "CLNSHRDPERSIST";
                'b010101, 'b100101: print_snoop_type = "RDONCEMAKEINVLD";
                'b010100, 'b100100: print_snoop_type = "RDONCECLNINVLD";
                default             : `uvm_info(get_type_name(), $sformatf("Undefined read address channel snoop type: ID:\
                                                                                   0x%0x Addr:0x%0x  Domain:0x%0x Snoop:0x%0x Val:'b%b"
                                                                               , arid, araddr,  ardomain, arsnoop,{ this.ardomain, this.arsnoop}), UVM_NONE)
            endcase
        <% } %>
    endfunction : print_snoop_type 

    function string print_dvmop_type();
        case (this.araddr[14:12])
            'b000: print_dvmop_type = "TLBI";
            'b001: print_dvmop_type = "BPI";
            'b010: print_dvmop_type = "PICI";
            'b011: print_dvmop_type = "VICI";
            'b100: print_dvmop_type = "SYNC";
            'b101: print_dvmop_type = "RES1";
            'b110: print_dvmop_type = "HINT";
            'b111: print_dvmop_type = "RES2";
        endcase
    endfunction : print_dvmop_type

    function bit do_compare_pkts(ace_read_addr_pkt_t m_pkt);
        bit legal = 1;
        legal = super.do_compare_pkts(m_pkt);
        if (WUSEACEDOMAIN) begin
            if (this.ardomain !== m_pkt.ardomain) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: ardomain: 0x%0x Actual: ardomain: 0x%0x", pkt_type, this.ardomain, m_pkt.ardomain), UVM_NONE) 
                legal = 0;
            end
        end
        if (this.arsnoop !== m_pkt.arsnoop) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arsnoop: 0x%0x Actual: arsnoop: 0x%0x", pkt_type, this.arsnoop, m_pkt.arsnoop), UVM_NONE) 
            legal = 0;
        end
        if (this.arvmid !== m_pkt.arvmid) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arvmid: 0x%0x Actual: arvmid: 0x%0x", pkt_type, this.arvmid, m_pkt.arvmid), UVM_NONE) 
            legal = 0;
        end
        if (this.artrace !== m_pkt.artrace) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: artrace: 0x%0x Actual: artrace: 0x%0x", pkt_type, this.artrace, m_pkt.artrace), UVM_NONE) 
            legal = 0;
        end
        if (this.arloop !== m_pkt.arloop) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arloop: 0x%0x Actual: arloop: 0x%0x", pkt_type, this.arloop, m_pkt.arloop), UVM_NONE) 
            legal = 0;
        end
        if (this.arnsaid !== m_pkt.arnsaid) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: arnsaid: 0x%0x Actual: arnsaid: 0x%0x", pkt_type, this.arnsaid, m_pkt.arnsaid), UVM_NONE) 
            legal = 0;
        end

        return legal;
    endfunction : do_compare_pkts

    function bit is_cacheline_size_txn();
        if (arcmdtype inside {RDCLN, RDNOTSHRDDIR, RDSHRD, RDUNQ, CLNUNQ, MKUNQ, CLNSHRD, CLNSHRDPERSIST, CLNINVL, MKINVL})
            return 1;
        else 
            return 0;
    endfunction: is_cacheline_size_txn

endclass : ace_read_addr_pkt_t

//-------------------------------------------------------------------------------------------------- 
// ACE Write address channel transaction packet (AW)
//-------------------------------------------------------------------------------------------------- 

class axi4_write_addr_pkt_t extends base_pkt_t;
    rand  axi_awid_t          awid;
    rand  axi_axaddr_t        awaddr;
    rand  axi_axlen_t         awlen;
    rand  axi_axsize_t        awsize;
    rand  axi_axburst_t       awburst;
    rand  axi_axlock_enum_t   awlock;
    rand  axi_awcache_enum_t  awcache;
    randc axi_axprot_t        awprot;
    <% if(obj.testBench == 'dii' || obj.testBench == 'dmi' || obj.testBench == 'fsys' || obj.testBench == 'io_aiu') { %>
    `ifndef VCS
    randc axi_axqos_t         awqos;
    `else // `ifndef VCS
    rand axi_axqos_t         awqos;
    `endif // `ifndef VCS ... `else ... 
    <% } else {%>
    randc axi_axqos_t         awqos;
<% } %>
    randc axi_axregion_t      awregion;
    randc axi_awuser_t        awuser;
    rand  bit                 useFullCL;
    string                    pkt_type;
    rand bit                  coh_domain;
    time                      t_pkt_seen_on_intf;
    int                       force_awcache;
    int                       exclusive_weight;
    int 		      buf_wr_en;
    int 		      alloc_wr_en;
    bit  		      narrow_wr_en;
    bit  		      en_unaligned_addr;

    `uvm_object_param_utils_begin(axi4_write_addr_pkt_t)
        `uvm_field_int     (awid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awaddr, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awlen, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awsize, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awburst, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_enum    (axi_axlock_enum_t, awlock, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_enum    (axi_awcache_enum_t, awcache, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awprot, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awqos, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awregion, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awuser, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    function new(string name = "axi4_write_addr_pkt_t");
        pkt_type = "AXI4";
        if ($test$plusargs("force_awcache")) force_awcache=1;
        if(!$value$plusargs("exclusive_weight=%d", exclusive_weight)) begin
        <% if (! obj.useCache) { %>    
            std::randomize(exclusive_weight) with {exclusive_weight dist { 5:=60, 95:=20, 1:=10, 99:=10};};
        <% }  else { %>    
        exclusive_weight=0;
        <%}%> 
        end
        if(!$value$plusargs("alloc_wr_en=%0d", alloc_wr_en)) begin
        	alloc_wr_en = -1;
        end
         if(!$value$plusargs("buf_wr_en=%0d", buf_wr_en)) begin
        	buf_wr_en = -1;
        end
        if($test$plusargs("force_single_beat"))begin
        	narrow_wr_en = 1;
        end
        if($test$plusargs("en_unaligned_addr"))begin
        	en_unaligned_addr = 1;
        end
    endfunction : new

    function bit do_compare_pkts(axi4_write_addr_pkt_t m_pkt);
        bit legal = 1;
        if (this.awid !== m_pkt.awid) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awid: 0x%0x Actual: awid: 0x%0x", pkt_type, this.awid, m_pkt.awid), UVM_NONE) 
            legal = 0;
        end
        if (this.awaddr !== m_pkt.awaddr) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awaddr: 0x%0x Actual: awaddr: 0x%0x", pkt_type, this.awaddr, m_pkt.awaddr), UVM_NONE) 
            legal = 0;
        end
        if (this.awlen !== m_pkt.awlen) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awlen: 0x%0x Actual: awlen: 0x%0x", pkt_type, this.awlen, m_pkt.awlen), UVM_NONE) 
            legal = 0;
        end
        if (this.awsize !== m_pkt.awsize) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awsize: 0x%0x Actual: awsize: 0x%0x", pkt_type, this.awsize, m_pkt.awsize), UVM_NONE) 
            legal = 0;
        end
        if (this.awburst !== m_pkt.awburst) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awburst: 0x%0x Actual: awburst: 0x%0x", pkt_type, this.awburst, m_pkt.awburst), UVM_NONE) 
            legal = 0;
        end
        if (this.awlock !== m_pkt.awlock) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awlock: 0x%0x Actual: awlock: 0x%0x", pkt_type, this.awlock, m_pkt.awlock), UVM_NONE) 
            legal = 0;
        end
        if (WUSEACECACHE) begin
            if (this.awcache !== m_pkt.awcache) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awcache: 0x%0x Actual: awcache: 0x%0x", pkt_type, this.awcache, m_pkt.awcache), UVM_NONE) 
                legal = 0;
            end
        end
        if (WUSEACEPROT) begin
            if (this.awprot !== m_pkt.awprot) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awprot: 0x%0x Actual: awprot: 0x%0x", pkt_type, this.awprot, m_pkt.awprot), UVM_NONE) 
                legal = 0;
            end
        end
        if (WUSEACEQOS) begin
            if (this.awqos !== m_pkt.awqos) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awqos: 0x%0x Actual: awqos: 0x%0x", pkt_type, this.awqos, m_pkt.awqos), UVM_NONE) 
                legal = 0;
            end
        end
        if (WUSEACEREGION) begin
            if (this.awregion !== m_pkt.awregion) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awregion: 0x%0x Actual: awregion: 0x%0x", pkt_type, this.awregion, m_pkt.awregion), UVM_NONE) 
                legal = 0;
            end
        end
        if (WAWUSER != 0) begin
            if (this.awuser !== m_pkt.awuser) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awuser: 0x%0x Actual: awuser: 0x%0x", pkt_type, this.awuser, m_pkt.awuser), UVM_NONE) 
                legal = 0;
            end
        end
        return legal;
    endfunction : do_compare_pkts


    function string sprint_pkt();
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("ID=0x%0x Addr=0x%0x Len=0x%0x Size=0x%0x BurstType=0x%0x Prot=0x%0x Lock=0x%0x Cache=0x%0x QoS=0x%0x TIME=%0t"
                               , awid, awaddr, awlen, awsize, awburst, awprot, awlock, awcache, awqos, t_pkt_seen_on_intf);  
        end else begin
            sprint_pkt = $sformatf("%0s WRITE AW: ID:0x%0x Addr:0x%0x Len:0x%0x Size:0x%0x BurstType:0x%0x NS:0x%0x Lock=0x%0x Cache=0x%0x QoS=0x%0x Time:%0t"
                               , pkt_type, awid, awaddr, awlen, awsize, awburst, awprot[1], awlock, awcache, awqos, t_pkt_seen_on_intf); 

        end
    endfunction : sprint_pkt
 
endclass : axi4_write_addr_pkt_t

class ace_write_addr_pkt_t extends axi4_write_addr_pkt_t;
    rand axi_axdomain_enum_t      awdomain;
    
    //#Stimulus.IOAIU.nativeInterface.axsnoop	Not found
    rand axi_awsnoop_t            awsnoop;
    rand axi_axbar_t              awbar;
    rand logic                    awunique;
    rand ace_command_types_enum_t awcmdtype; 
    rand awatop_types_enum_t      awatoptype;
    rand endian_types_enum_t      endiantype;
    rand axi_awatop_t             awatop; 
    rand axi_awstashnid_t         awstashnid; 
    rand bit                      awstashniden; 
    rand axi_awstashlpid_t        awstashlpid; 
    rand bit                      awstashlpiden;
    rand bit                      awtrace;
    rand axi_awloop_t             awloop;
    rand axi_awnsaid_t            awnsaid;
    rand bit                      en_user_delay_after_txn;
    rand bit                      en_user_delay_before_txn;
    rand int                      val_user_delay_after_txn;
    rand int                      val_user_delay_before_txn;
    aceAtomic_enum_t              atomic_type;
    int  atm_txn_except_comp_data_size = (2**$urandom_range(0,3));
    //int  atm_comp_data_size            = (2**$urandom_range(1,5));
    int                           axi_trace_weight;
    bit constrained_addr;
    bit en_qos;
    rand int atm_comp_data_size;

<% if(obj.testBench == 'dii' || obj.testBench == 'dmi' || obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
   `ifdef VCS
    `define VCSorCDNS
   `elsif CDNS
    `define VCSorCDNS
   `endif 
<% }  %>

<% if(obj.testBench == 'dii' || obj.testBench == 'dmi' || obj.testBench == 'fsys' || obj.testBench == 'io_aiu') { %>
    int    en_axlen_127_255_vcs;
    int    unmapped_add_access;
<% }  %>
    constraint delay_c {
       soft  en_user_delay_after_txn==0;
       soft  en_user_delay_before_txn==0;
       soft  val_user_delay_after_txn==0;
       soft  val_user_delay_before_txn==0;
    };

    constraint c_awsnoop_awcmdtype {
<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifdef VCS // CONC-11829
        (awcmdtype == WRNOSNP || awcmdtype == WRUNQ || awcmdtype == BARRIER || awcmdtype == ATMSTR || awcmdtype == ATMLD || awcmdtype == ATMSWAP || awcmdtype == ATMCOMPARE)         -> awsnoop == 'b0000;
`else        
        (awcmdtype == WRNOSNP)         -> awsnoop == 'b0000;
        (awcmdtype == WRUNQ)           -> awsnoop == 'b0000;
`endif
<% } else { %>
        (awcmdtype == WRNOSNP)         -> awsnoop == 'b0000;
        (awcmdtype == WRUNQ)           -> awsnoop == 'b0000;
<% } %>
        (awcmdtype == WRLNUNQ)         -> awsnoop == 'b0001;
        (awcmdtype == WRCLN)           -> awsnoop == 'b0010;
        (awcmdtype == WRBK)            -> awsnoop == 'b0011;
        (awcmdtype == EVCT)            -> awsnoop == 'b0100;
        (awcmdtype == WREVCT)          -> awsnoop == 'b0101;
<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifndef VCS // CONC-11829
        (awcmdtype == BARRIER)         -> awsnoop == 'b0000;
        (awcmdtype == ATMSTR)          -> awsnoop == 'b0000;
        (awcmdtype == ATMLD)           -> awsnoop == 'b0000;
        (awcmdtype == ATMSWAP)         -> awsnoop == 'b0000;
        (awcmdtype == ATMCOMPARE)      -> awsnoop == 'b0000;
`endif
<% } else {%>
        (awcmdtype == BARRIER)         -> awsnoop == 'b0000;
        (awcmdtype == ATMSTR)          -> awsnoop == 'b0000;
        (awcmdtype == ATMLD)           -> awsnoop == 'b0000;
        (awcmdtype == ATMSWAP)         -> awsnoop == 'b0000;
        (awcmdtype == ATMCOMPARE)      -> awsnoop == 'b0000;
<% } %>
        (awcmdtype == WRUNQPTLSTASH)   -> awsnoop == 'b1000;
        (awcmdtype == WRUNQFULLSTASH)  -> awsnoop == 'b1001;
        (awcmdtype == STASHONCESHARED) -> awsnoop == 'b1100;
        (awcmdtype == STASHONCEUNQ)    -> awsnoop == 'b1101;
        (awcmdtype == STASHTRANS)      -> awsnoop == 'b1110;
    };
 
    constraint c_stash_id_awcmdtype {
        if ((awcmdtype != WRUNQPTLSTASH) && (awcmdtype != WRUNQFULLSTASH) &&
            (awcmdtype != STASHONCESHARED) && (awcmdtype != STASHONCEUNQ)) { 
            awstashlpiden == 0;
            awstashniden  == 0;
        } else {
            awstashniden dist {0 := 2, 1 := 98};
        }
    };

    constraint c_stashlpid {
            (awstashlpiden == 0) -> (awstashlpid == 0);
            solve awstashlpiden before awstashlpid;
    };
 
    constraint c_axlock_axbar_zero_for_stash_txns {
        if ((awcmdtype == WRUNQPTLSTASH) || (awcmdtype == WRUNQFULLSTASH) ||
            (awcmdtype == STASHONCESHARED) || (awcmdtype == STASHONCEUNQ) ||
            (awcmdtype == STASHTRANS)) { 
            awlock == 0;
        }
    };
 
    constraint c_awcache_for_stash_txns {
        if ((awcmdtype == WRUNQPTLSTASH) || (awcmdtype == WRUNQFULLSTASH) ||
            (awcmdtype == STASHONCESHARED) || (awcmdtype == STASHONCEUNQ) ||
            (awcmdtype == STASHTRANS)) { 
            awcache[1] == 1;
        }
    };
    constraint c_awdomain_for_stash_txns_1 {
        if ((awcmdtype == STASHONCESHARED) || (awcmdtype == STASHONCEUNQ)) { 
            awdomain inside {'b01, 'b10};
        }
    };

    constraint c_awdomain_for_stash_txns_2 {
        if ((awcmdtype == WRUNQPTLSTASH) || (awcmdtype == WRUNQFULLSTASH)) { 
            awdomain inside {'b01, 'b10};
        }
    };
    constraint c_awcache_for_atm_txns {
        if (awcmdtype inside {ATMCOMPARE, ATMLD, ATMSWAP, ATMSTR}) {
                //CONC-8962 //Ncore 3.x supports only cacheable non-coherent and coherent atomics to normal memory 
                //Ncore Supplemental Architecture Specification 1.4 Atomics Support
                awcache[3:2] !=0;
                awcache[1] ==1;
        }
    };
    
    constraint c_awdomain_0 {
        if(coh_domain) {
            awdomain inside {INNRSHRBL, OUTRSHRBL};
        } else {
            awdomain inside {NONSHRBL, SYSTEM};
        }
        solve coh_domain before awdomain;
    };
   
    //#Stimulus.IOAIU.awatop 
    constraint c_awatop_awcmdtype {
        //3.6 Additional AXI Signals  
        (awcmdtype == ATMSTR)     -> awatop[5:4] == 2'b01;
        (awcmdtype == ATMLD)      -> awatop[5:4] == 2'b10;
        (awcmdtype == ATMSWAP)    -> awatop      == 6'b110000;
        (awcmdtype == ATMCOMPARE) -> awatop      == 6'b110001;
        !(awcmdtype inside {ATMSTR, ATMLD, ATMSWAP, ATMCOMPARE}) -> awatop == 6'h0;
    };

    constraint c_atomic_little_endian {
        awatop[3] == 0;
    };

    constraint order_cmdtype_1 { solve awcmdtype before awsnoop;};

    constraint order_cmdtype_2 { solve awcmdtype before awatop;};

    constraint c_awcmdtype_1 {
<% if (obj.fnNativeInterface == "ACE-LITE") { %>    
        awcmdtype inside {WRNOSNP, WRUNQ, WRLNUNQ};
<% }
else if ((obj.fnNativeInterface == "AXI4") ) { %>
        //if (addrMgrConst::get_addr_gprar_nc(awaddr)) {
        //    awcmdtype == WRNOSNP;
        //} else {
        //    awcmdtype == WRUNQ;
        //}
        awcmdtype inside {WRNOSNP, WRUNQ};
<% } 
else if ((obj.fnNativeInterface == "AXI5")) {%>

  awcmdtype inside {WRNOSNP, WRUNQ,ATMSTR, ATMLD,ATMSWAP, ATMCOMPARE};
<% }
else { %>    
        awcmdtype inside {WRNOSNP, WRUNQ, WRLNUNQ, WRCLN, WRBK, EVCT, WREVCT, ATMSTR, ATMLD,
        ATMSWAP, ATMCOMPARE, WRUNQPTLSTASH, WRUNQFULLSTASH, STASHONCESHARED, STASHONCEUNQ, STASHTRANS};
<% } %>      
    };

<% if (obj.fnNativeInterface === "ACE"|| obj.fnNativeInterface == "ACE5") { %>
    constraint c_awunique {
      if(WUSEACEUNIQUE>0) {
        (awcmdtype == WREVCT) -> awunique == 1;
        (awcmdtype == WRCLN) -> awunique == 0;
      } else {
        awunique == 0;
      }
    };
<% } else { %>
    constraint c_awunique {
         //Table C3-9 AWUNIQUE signaling requirements for different write transactions
         if (awcmdtype == WRNOSNP || awcmdtype == WRUNQ || awcmdtype == WRLNUNQ) {
             awunique inside{0, 1};
         } else {
             awunique == 0;
         }
    };
<% } %>

    constraint c_awqos{
    if(en_qos==1) {
            awqos dist { [6:15] := 95,   [0:5] := 5};
                   }
    else {
            awqos dist { [5:15] := 95,   [0:4] := 5};
            }
    };

    constraint order_0 { solve awcmdtype before awunique;};
    
    
    constraint c_awbar {
            awbar[0] == 1'b0;
       
    };

  `ifndef  VCS  // CONC-11829
    constraint c_awsnoop {
            if (awdomain == SYSTEM) {
                awsnoop == 'b0000;
            }
            else if (awdomain == NONSHRBL) {
                awsnoop inside {'b0000, 'b0010, 'b0011, 'b0101, 'b1100, 'b1101};
            }
            else {
                awsnoop inside {'b0000, 'b0001, 'b0010, 'b0011, 'b0100, 'b0101, 'b1000, 'b1001, 'b1100, 'b1101, 'b1110};
            }
    };
   constraint order_1 { solve awdomain before awsnoop;};
   `endif
             

    constraint c_awdomain {
        (awcache[1] == 0) -> awdomain == SYSTEM; 
        (awcache[3:2] != 0) -> awdomain != SYSTEM; 
        (awcache == WDEVNONBUF || awcache == WDEVBUF) -> awdomain == SYSTEM; 
        (awcache == WWBRALLOC || awcache == WWTWALLOC || awcache == WWBWALLOC || awcache == WWTRWALLOC || awcache == WWBRWALLOC) -> awdomain inside {NONSHRBL, INNRSHRBL, OUTRSHRBL};
        (awcmdtype == WRNOSNP) -> awdomain inside {SYSTEM, NONSHRBL};
        (awcmdtype != WRNOSNP && awcmdtype != BARRIER && awcmdtype != ATMSWAP && awcmdtype != ATMSTR && awcmdtype != ATMLD &&
         awcmdtype != ATMCOMPARE && awcmdtype != WRUNQFULLSTASH && awcmdtype != WRUNQPTLSTASH && awcmdtype != STASHONCEUNQ &&
         awcmdtype != STASHONCESHARED && awcmdtype != STASHTRANS &&
         awcmdtype != WRCLN && awcmdtype != WRBK && awcmdtype != WREVCT) -> (awdomain != SYSTEM && awdomain != NONSHRBL);
         (awcmdtype == WRCLN || awcmdtype == WRBK || awcmdtype == WREVCT) -> (awdomain != SYSTEM);

    };

<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifdef VCS // CONC-11829
    constraint order_2_0 { solve awcache, awcmdtype before awdomain;};
    constraint order_2_1 { solve awcmdtype before coh_domain;};
    constraint order_2_2 { solve awcmdtype before awcache;};
`else    
    constraint order_2 { solve awcache, awcmdtype before awdomain;};
`endif
<% } else {%>
    constraint order_2 { solve awcache, awcmdtype before awdomain;};
<% } %>

    constraint c_awlen {

        (awburst == AXIWRAP && awcmdtype == ATMCOMPARE) -> awlen inside {0, 1, 3, 7, 15};
        (awburst == AXIWRAP && awcmdtype != ATMCOMPARE) -> awlen inside {1, 3, 7, 15};
        (awburst == AXIINCR) -> awlen < 256;

        //#Stimulus.IOAIU.nativeInterface.WrBk_WrCln.axlen
        //#Stimulus.IOAIU.nativeInterface.WrBk_WrCln.axsize
        //#Stimulus.IOAIU.nativeInterface.WriteDataStrobes
        if (awcmdtype == WRLNUNQ         || 
            awcmdtype == WREVCT          || 
            awcmdtype == EVCT            ||
            awcmdtype == STASHONCEUNQ    ||
            awcmdtype == STASHONCESHARED ||
            awcmdtype == WRUNQFULLSTASH  
        ) { 
            awlen inside {0, 1, 3, 7, 15};
            awlen == ((SYS_nSysCacheline*8/WXDATA) - 1);
        }

	else if (
            awcmdtype == WRUNQPTLSTASH
        ) { 
            awlen inside {1, 3, 7, 15};
            awlen <= ((SYS_nSysCacheline*8/WXDATA) - 1);
        }
	
        else if (awcmdtype == WRCLN ||
                 awcmdtype == WRBK) {
            awlen dist { [0 : (SYS_nSysCacheline*8/(WXDATA)) - 2] := 15, ((SYS_nSysCacheline*8/(WXDATA)) - 1) := 85};
          }
        
        <% if(obj.testBench == 'dii'|| obj.testBench == 'dmi' || obj.testBench == 'fsys' || obj.testBench == 'io_aiu') { %>
        `ifndef VCS
        if ($test$plusargs("en_axlen_127_255")) {
            awlen dist {127 :=50, 255:=50};
         }
        `elsif VCS // `ifndef VCS
         if (en_axlen_127_255_vcs <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %> && awcmdtype != WRUNQ <%}%>) {
            awlen dist {127 :=50, 255:=50};
         }
        `endif  // `ifndef VCS 
      <% } else {%>
        if ($test$plusargs("en_axlen_127_255")) {
            awlen dist {127 :=50, 255:=50};
        }
      <% } %>

        if (awcmdtype == WRNOSNP) {
            awlen dist { [0 : ((SYS_nSysCacheline*8/(WXDATA)) - 2)] := 50,   ((SYS_nSysCacheline*8/(WXDATA)) - 1) := 50, [(SYS_nSysCacheline*8/(WXDATA)) : (2*SYS_nSysCacheline*8/(WXDATA))] := 50, [((2*SYS_nSysCacheline*8/(WXDATA))+1) : 255] := 10 };
        } 
        <% if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) { %> 

        if (awcmdtype == WRUNQ) {
        //CONC-16429
            awlen dist { [0 : ((SYS_nSysCacheline*8/(WXDATA)) - 2)] := 50,   ((SYS_nSysCacheline*8/(WXDATA)) - 1) := 50, [(SYS_nSysCacheline*8/(WXDATA)) : (2*SYS_nSysCacheline*8/(WXDATA))] := 50, [((2*SYS_nSysCacheline*8/(WXDATA))+1) : 255] := 10 };
        } 

        <% } else { %>
        //CONC-11571 coherent multiline transactions from ACE are not supported
        if (awcmdtype == WRUNQ) {
            awlen dist { [0 : ((SYS_nSysCacheline*8/(WXDATA)) - 2)] := 25,   ((SYS_nSysCacheline*8/(WXDATA)) - 1) := 75 };
        } 
        <% } %> 

        if(awcmdtype == BARRIER){ 
            awlen == 0;
            awcache == 'b0010;
        }
        if((awcmdtype == ATMSTR) || (awcmdtype == ATMLD) || (awcmdtype == ATMSWAP)){
            atm_txn_except_comp_data_size < WXDATA/8 -> awlen == 0;
            awlen == (atm_txn_except_comp_data_size/(2**awsize)) - 1;
        }
        
        if(awcmdtype == ATMCOMPARE){
            if (atm_comp_data_size < WXDATA/8) {
                awlen == 0;
            } else {
                awlen == (atm_comp_data_size/(2**awsize)) - 1 ; 
            }
        }
        (atm_comp_data_size inside {1, 2, 4, 8, 16, 32});
    };
    constraint c_atm_txn_size {
       if(awcmdtype == ATMCOMPARE) {
	  (1 + awlen) * (2**awsize) inside {2,4,8,16,32};
       } 
       else if((awcmdtype == ATMSTR) || (awcmdtype == ATMLD) || (awcmdtype == ATMSWAP)) {
	  (1 + awlen) * (2**awsize) inside {1,2,4,8};	       
       }
    }

<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifdef VCS // CONC-11829
    constraint order_3_0 { solve awcmdtype,awlock,awburst before awlen;};
    constraint order_3_1 { solve awcmdtype,awlock,awburst before awsize;};
`else
    constraint order_3 { solve awcmdtype,awsize,awlock,awburst before awlen;};
`endif
<% } else { %>
    constraint order_3 { solve awcmdtype,awsize,awlock,awburst before awlen;};
<% } %>

      // For EXCLUSIVE access, the address must be aligned to 
      // the total number of bytes transferred
    constraint exclusive_txn_addr_aligned_c {
      if (awlock == EXCLUSIVE) {
        ((awlen+1) << awsize) inside {1,2,4,8,16,32,64,128};

      }
    };
    //#Stimulus.IOAIU.nativeInterface.CacheLineSizeTxns.axlen
    //#Stimulus.IOAIU.nativeInterface.CacheLineSizeTxns.axsize

    // IOAIU only supports single beat narrow transfer
    constraint c_awlen_awsize {
        if (awlen == 0) {
            (WXDATA == 8)    -> awsize <= AXI1B;
            (WXDATA == 16)   -> awsize <= AXI2B;
            (WXDATA == 32)   -> awsize <= AXI4B;
            (WXDATA == 64)   -> awsize <= AXI8B;
            (WXDATA == 128)  -> awsize <= AXI16B;
            (WXDATA == 256)  -> awsize <= AXI32B;
            (WXDATA == 512)  -> awsize <= AXI64B;
            (WXDATA == 1024) -> awsize <= AXI128B;
        }
        else {
            (WXDATA == 8)    -> awsize == AXI1B;
            (WXDATA == 16)   -> awsize == AXI2B;
            (WXDATA == 32)   -> awsize == AXI4B;
            (WXDATA == 64)   -> awsize == AXI8B;
            (WXDATA == 128)  -> awsize == AXI16B;
            (WXDATA == 256)  -> awsize == AXI32B;
            (WXDATA == 512)  -> awsize == AXI64B;
            (WXDATA == 1024) -> awsize == AXI128B;
        }
    };
    constraint c_awsize {
        if (awcmdtype == WRLNUNQ         || 
            awcmdtype == WREVCT          || 
            awcmdtype == EVCT            ||
            awcmdtype == STASHONCEUNQ    ||
            awcmdtype == STASHONCESHARED ||
            awcmdtype == WRUNQFULLSTASH  
        ) { 
            (WXDATA == 8)    -> awsize == AXI1B;
            (WXDATA == 16)   -> awsize == AXI2B;
            (WXDATA == 32)   -> awsize == AXI4B;
            (WXDATA == 64)   -> awsize == AXI8B;
            (WXDATA == 128)  -> awsize == AXI16B;
            (WXDATA == 256)  -> awsize == AXI32B;
            (WXDATA == 512)  -> awsize == AXI64B;
            (WXDATA == 1024) -> awsize == AXI128B;
        }
    
    };

    
    constraint c_awsize_1 {
        if((awcmdtype == ATMSTR) || (awcmdtype == ATMLD) || (awcmdtype == ATMSWAP)){
            (atm_txn_except_comp_data_size >= WXDATA/8) && (WXDATA == 8)    -> awsize == AXI1B;
            (atm_txn_except_comp_data_size >= WXDATA/8) && (WXDATA == 16)   -> awsize == AXI2B;
            (atm_txn_except_comp_data_size >= WXDATA/8) && (WXDATA == 32)   -> awsize == AXI4B;
            (atm_txn_except_comp_data_size >= WXDATA/8) && (WXDATA == 64)   -> awsize == AXI8B;
            (atm_txn_except_comp_data_size >= WXDATA/8) && (WXDATA == 128)  -> awsize == AXI16B;
            (atm_txn_except_comp_data_size >= WXDATA/8) && (WXDATA == 256)  -> awsize == AXI32B;
            (atm_txn_except_comp_data_size >= WXDATA/8) && (WXDATA == 512)  -> awsize == AXI64B;
            (atm_txn_except_comp_data_size >= WXDATA/8) && (WXDATA == 1024) -> awsize == AXI128B;
        }
        else if(awcmdtype == ATMCOMPARE){
            (atm_comp_data_size >= WXDATA/8) && (WXDATA == 8)    -> awsize == AXI1B;
            (atm_comp_data_size >= WXDATA/8) && (WXDATA == 16)   -> awsize == AXI2B;
            (atm_comp_data_size >= WXDATA/8) && (WXDATA == 32)   -> awsize == AXI4B;
            (atm_comp_data_size >= WXDATA/8) && (WXDATA == 64)   -> awsize == AXI8B;
            (atm_comp_data_size >= WXDATA/8) && (WXDATA == 128)  -> awsize == AXI16B;
            (atm_comp_data_size >= WXDATA/8) && (WXDATA == 256)  -> awsize == AXI32B;
            (atm_comp_data_size >= WXDATA/8) && (WXDATA == 512)  -> awsize == AXI64B;
            (atm_comp_data_size >= WXDATA/8) && (WXDATA == 1024) -> awsize == AXI128B;
        }
        //don't support Narrow transfer for WRCLN/WRBK in IOAIU
        /* else if((awcmdtype == WRCLN || */
        /*          awcmdtype == WRBK) && */
        /*         awburst == AXIINCR) { */
        /*     (WXDATA == 8)    -> awsize <= AXI1B; */
        /*     (WXDATA == 16)   -> awsize <= AXI2B; */
        /*     (WXDATA == 32)   -> awsize <= AXI4B; */
        /*     (WXDATA == 64)   -> awsize <= AXI8B; */
        /*     (WXDATA == 128)  -> awsize <= AXI16B; */
        /*     (WXDATA == 256)  -> awsize <= AXI32B; */
        /*     (WXDATA >= 512)  -> awsize <= AXI64B; */
        /* } */
<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifdef VCS // CONC-11829
        else if (awlen > 0){
`else
        else {
`endif
<% } else { %>
        else {
<% } %>
            (WXDATA == 8)    -> awsize == AXI1B;
            (WXDATA == 16)   -> awsize == AXI2B;
            (WXDATA == 32)   -> awsize == AXI4B;
            (WXDATA == 64)   -> awsize == AXI8B;
            (WXDATA == 128)  -> awsize == AXI16B;
            (WXDATA == 256)  -> awsize == AXI32B;
            (WXDATA == 512)  -> awsize == AXI64B;
            (WXDATA == 1024) -> awsize == AXI128B;
        }
    };
    

    constraint order_4 { solve awcmdtype before awsize;};
    //#Stimulus.IOAIU.nativeInterface.CacheLineSizeTxns.burst_type

    constraint c_awburst {
        <% if (obj.Block.includes('aiu') && (aiu.orderedWriteObservation == true)) {  %> 
            (awcmdtype != ATMCOMPARE) -> (awburst == AXIINCR);
        <% } else { %> 
        awburst inside {AXIINCR, AXIWRAP};
        // Section 1.2 NCore sys spec Burst limitations
        if (awcache[1] == 0
            && (
                ((awlen + 1) * (2 ** awsize)) > 64
            )
            ) {
            awburst == AXIINCR;
        }
        <%}%>
    };

    constraint order_5 { solve awcmdtype before awburst;};

    constraint c_awcache {
		if (alloc_wr_en == 0) {
			(awcache inside {WDEVNONBUF,WDEVBUF,WNORNCNONBUF,WNORNCBUF,WWTNALLOC,WWBRALLOC});
		}
        if (alloc_wr_en == 1) {
			!(awcache inside {WDEVNONBUF,WDEVBUF,WNORNCNONBUF,WNORNCBUF,WWTNALLOC,WWBRALLOC});
		}
        if (buf_wr_en == 0) {
			(awcache inside {WDEVNONBUF,WNORNCNONBUF,WWTNALLOC,WWBRALLOC,WWTWALLOC});
		} 
        if (buf_wr_en == 1) {
			!(awcache inside {WDEVNONBUF,WNORNCNONBUF,WWTNALLOC,WWBRALLOC,WWTWALLOC});
		}
        //Spec section C3.1.6 Table C3-12
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
        if (awcmdtype == WRLNUNQ || 
            awcmdtype == WRUNQ || 
            awcmdtype == WREVCT || 
            awcmdtype == EVCT  
        ) { 
            awcache[1] == 1;
        }
<%}%>
         //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
         //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
         //Non coherent GPRA access do not have restrictions
         //In general all coherent transactions are  buffer-able
<%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5") ) { %>
        (awcmdtype == WRUNQ) -> awcache[1] == 'b1;
        (awcmdtype == WRUNQ) -> awcache[0] dist { 1:=98,0:=2};
<% } %>
       if (force_awcache) {awcache[3:2] == 2'b11;}
	  //ARM IHI 0022E A7.2 Exclusive accesses A7.2.4 Exclusive access restrictions
	  //The value of the AxCACHE signals must guarantee that the slave that is monitoring the exclusive access sees the transaction. 
	  //For example, an exclusive access must not have an AxCACHE value that indicates that the transaction is Cacheable.
     (awlock == EXCLUSIVE) -> (awcache inside {WDEVNONBUF, WDEVBUF, WNORNCNONBUF, WNORNCBUF});
 	
 	 solve awlock before awcache;

    };

    constraint c_awlock {
        if (awcmdtype == WRLNUNQ || 
            awcmdtype == WRUNQ || 
<% if ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %>    
          (awcmdtype == WRNOSNP && !addrMgrConst::get_addr_gprar_nc(awaddr)) ||
<%}%>
            awcmdtype == WREVCT || 
            awcmdtype == EVCT  
        ) { 
            awlock == NORMAL;
        }
    };

    constraint order_6 { solve awcmdtype,awaddr before awlock;};


    // The constraints below are for WriteBack and WriteClean

    constraint c_awburst_2 {
        if (awcmdtype == WRBK || 
            awcmdtype == WRCLN  
        ) { 
            awburst inside {AXIINCR, AXIWRAP};
        }
    };
    constraint c_awcache_2 {
        if (awcmdtype == WRBK || 
            awcmdtype == WRCLN  
        ) { 
            awcache[1] == 1;
        }
    };

    constraint c_awlock_2 {
        if (awcmdtype == WRBK || 
            awcmdtype == WRCLN  
        ) { 
            awlock == NORMAL;
        }
    };
    
    // For Atomic transactions (except Atomic Compare), burst type must be INCR
    constraint c_awburst_4{
        if (awcmdtype == ATMSTR ||
            awcmdtype == ATMLD  ||
            awcmdtype == ATMSWAP
        ) { 
            awburst == AXIINCR;
        }
    };


    constraint c_awlock_4{
                <% if (((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) && (obj.orderedWriteObservation == false)) { %> 
        if ((awcmdtype == WRNOSNP) && addrMgrConst::get_addr_gprar_nc(awaddr)) {
		<%} else {%>
        if (awcmdtype == WRNOSNP) {
		<%}%>
			awlock dist {NORMAL := (100-exclusive_weight), EXCLUSIVE := exclusive_weight};
		} else {
			awlock == NORMAL;
		}
    };

    //#Stimulus.IOAIU.AXtrace
    <% if (obj.fnNativeInterface == "ACELITE-E") { %>    
    constraint c_awtrace_0{
       awtrace dist {0 := (100-axi_trace_weight), 1 := axi_trace_weight};
    };
    <% } %>

    `uvm_object_param_utils_begin(ace_write_addr_pkt_t)
        `uvm_field_enum    (axi_axdomain_enum_t, awdomain, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awsnoop, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awbar, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awunique, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awatop, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awstashnid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awstashniden, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awstashlpid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awstashlpiden, UVM_DEFAULT + UVM_NOPRINT)
	`uvm_field_int     (awtrace, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awloop, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (awnsaid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (en_user_delay_after_txn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (en_user_delay_before_txn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (val_user_delay_after_txn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (val_user_delay_before_txn, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    function void pre_randomize();
        super.pre_randomize();
       <% if(obj.testBench == 'dii' || obj.testBench == 'fsys' || obj.testBench == 'io_aiu') { %>
        en_axlen_127_255_vcs = 0;    
        if ($test$plusargs("en_axlen_127_255"))    en_axlen_127_255_vcs = 1;                                          
        unmapped_add_access = 0;    
        if ($test$plusargs("unmapped_add_access"))    unmapped_add_access = 1;                                          
     <% }  %>
        if ($test$plusargs("en_qos"))    en_qos = 1;                                          
        else en_qos=0;
    endfunction: pre_randomize

    function void post_randomize();
        axi_axaddr_t awaddr_tmp;
        int max_axlen, loop;
        int outgoing_data_size;
        int  outgoing_data_size_bits;
        bit [2:0] unit_unconnected;
        int total_txfr_size, msb;
        int dest_id;
        int fnmem_region_idx;
        bit fnd=0;
        // Constraining awsize to be different from full cacheline

        if (narrow_wr_en == 1 && awburst == AXIINCR && (awcmdtype inside {WRUNQ, WRNOSNP,WRCLN,WRBK}) ) begin
        awlen=0;
            case (WXDATA)
                8    : awsize = $urandom_range(0,AXI1B);
                16   : awsize = $urandom_range(0,AXI2B);
                32   : awsize = $urandom_range(0,AXI4B);
                64   : awsize = $urandom_range(0,AXI8B);
                128  : awsize = $urandom_range(0,AXI16B);
                256  : awsize = $urandom_range(0,AXI32B);
                512  : awsize = $urandom_range(0,AXI64B);
                1024 : awsize = $urandom_range(0,AXI128B);
            endcase
        end

        outgoing_data_size = ((awlen+1)*(2**awsize));
        if (awburst == AXIFIXED) begin
            awburst = AXIINCR;
        end
	//`uvm_info(get_type_name(), $sformatf("AIU<%=obj.FUnitId%> post_randomize begin awlen:0x%0h awcmdtype:%0p", awlen, awcmdtype),UVM_LOW)
        //adding for unaligned addr
       if(en_unaligned_addr) begin:_unaligned_addr //Spec: table C12-4
            if(awburst == AXIINCR) begin
                if (is_cacheline_size_txn())
                    awaddr[SYS_wSysCacheline-1:0] = '0; 
                else begin
                    awaddr[SYS_wSysCacheline-1:0]=$urandom_range(0,SYS_nSysCacheline-1);
                    if(narrow_wr_en == 1) awaddr[SYS_wSysCacheline-1:0]=$urandom_range((1 << SYS_wSysCacheline)-1,0);
                    if($test$plusargs("wide_txn_offset") || $test$plusargs("mid_offset")) begin 
                        awaddr[SYS_wSysCacheline-1:0]=$urandom_range((1 << SYS_wSysCacheline)-1,0);
                        awaddr[$clog2(<%=obj.wData%>/8)-1:0]='d0; // Added for coverage offset on the wide txns
                    end
                    if($test$plusargs("lwr_offset")) begin 
                        awaddr[SYS_wSysCacheline-1:0]='d0;
                    end
                    if($test$plusargs("upr_offset")) begin 
                        awaddr[SYS_wSysCacheline-1:0]=(1 << SYS_wSysCacheline)-1;
                        awaddr[$clog2(<%=obj.wData%>/8)-1:0]='d0; 
                    end
                end
            end   
            if(awburst == AXIWRAP) begin
                //A3.4.1 Address structure : For WRAPs the start address must be aligned to the size of each transfer
                awaddr[WLOGXDATA-1:0] = '0;
                awaddr[SYS_wSysCacheline-1:WLOGXDATA] = $urandom;
            end   
        end:_unaligned_addr
         else begin:_default_case
            if (is_cacheline_size_txn()) begin
                if(awburst == AXIINCR) 
                    awaddr[SYS_wSysCacheline-1:0] = '0; 
                else
                    awaddr[WLOGXDATA-1:0] = '0;
            end
        end:_default_case

        
        outgoing_data_size_bits = $clog2(outgoing_data_size);
       
        if ($test$plusargs("prot_rand_disable")) begin
            awprot[1] = 0;
        end
        if (awburst == AXIINCR) begin
            if (is_cacheline_size_txn() == 1) begin
                awaddr[SYS_wSysCacheline-1:0] = '0; 
            end
            if (awcmdtype == WRCLN ||
                awcmdtype == WRBK
            ) begin
                if ($urandom_range(0,100) < 50) begin
                    awaddr[WLOGXDATA-1:0] = $urandom;
                end
                if (awburst == AXIWRAP) begin
                    awaddr[WLOGXDATA-1:0] = '0;
                end
                if ((awaddr[SYS_wSysCacheline-1:0] + ((awlen+1) * 2** awsize)) > (1 << SYS_wSysCacheline) ) begin
                    awaddr[SYS_wSysCacheline-1:0] = '0;
                end
            end
        end
        //if(awcmdtype == WRUNQPTLSTASH &&
	//   ((awaddr + outgoing_data_size) > (awaddr[SYS_wSysCacheline-1:0] + 2**SYS_wSysCacheline)) &&
	//   awburst == AXIINCR) begin
	//   awburst = AXIWRAP;
	//end
       
        // Randomizing beat number for a update with type wrap, wrap aligned with data size constraint
        // is not applicable to atomic transactions, their specific constraints are below
        if ((awburst == AXIWRAP) && (awcmdtype != ATMSTR && awcmdtype != ATMLD &&
             awcmdtype != ATMSWAP && awcmdtype != ATMCOMPARE) && (!$test$plusargs("perf_test"))) begin
            bit [SYS_wSysCacheline-WLOGXDATA-1:0] m_tmp_var = '1;
            awaddr[SYS_wSysCacheline-1:WLOGXDATA]           = $urandom() & m_tmp_var;
            awaddr[WLOGXDATA-1:0]                                                      = '0;
        end
        //CONC-11571 coherent multiline transactions from ACE, ACE-LITE, ACE-LITE-E are not supported
 <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE") { %>
        if (awcmdtype == WRUNQ) begin 
            if ($urandom_range(0,100) < 25 && awburst == AXIINCR) begin
                awaddr[WLOGXDATA-1:0] = $urandom;
            end
            if (awburst == AXIWRAP) begin
                awaddr[WLOGXDATA-1:0] = '0;
            end
            if ((awaddr[SYS_wSysCacheline-1:0] + ((awlen+1) * 2** awsize)) > (1 << SYS_wSysCacheline) ) begin
                awaddr[SYS_wSysCacheline-1:0] = '0;
            end
        end
<% } %>      

        //3.4 Ncore Proxy Cache update Architecture Specification v0.87.1
        //a. It is illegal to send Device type transactions to an address range mapped to normal memory.
        // NCOR-199
       
        dest_id = addrMgrConst::map_addr2dmi_or_dii(awaddr,fnmem_region_idx);
        if(unmapped_add_access==0 && addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DMI) awcache[1] = 1;


<% if (!obj.CUSTOMER_ENV) { %>
        // Constraining address for INCR type to '0 ( FIXME: TODO)
    <% } %>
        // This restriction needs to be removed
//        if (awcmdtype == WRUNQ && awburst == AXIINCR && awlen == ((SYS_nSysCacheline*8/(WXDATA)) - 1)) begin 
//            awaddr[SYS_wSysCacheline-1:0] = '0;
//        end
//        if (awcmdtype == WRUNQ && awburst == AXIINCR && ((awaddr + ((awlen+1) * 2**(awsize)) - 1) & ('1 << SYS_wSysCacheline) !== (awaddr & ('1 << SYS_wSysCacheline)))) begin
//            awaddr[SYS_wSysCacheline-1:0] = '0;
//        end

        	
        // Constraining awsize to be different from full cacheline
        if ((awcmdtype inside {ATMSTR, ATMLD, ATMSWAP}) && (awlen == 0) && awlock != EXCLUSIVE) begin
            case (WXDATA)
                8    : awsize = $urandom_range(0,AXI1B);
                16   : awsize = $urandom_range(0,AXI2B);
                32   : awsize = $urandom_range(0,AXI4B);
                64   : awsize = $urandom_range(0,AXI8B);
                128  : awsize = $urandom_range(0,AXI8B);
                256  : awsize = $urandom_range(0,AXI8B);
                512  : awsize = $urandom_range(0,AXI8B);
                1024 : awsize = $urandom_range(0,AXI8B);
            endcase
        end
        if((awcmdtype == ATMCOMPARE) && (awlen == '0)) begin
            case (WXDATA)
                8    : awsize = AXI1B; //Not a valid config for Atomic
                16   : awsize = AXI2B;
                32   : awsize = $urandom_range(AXI2B,AXI4B);
            // cf weight from the table https://arterisip.atlassian.net/browse/CONC-11504   
                64   : randcase
                          8 : awsize = AXI2B; // more case to cover
                          4:  awsize = AXI4B;
                          2:  awsize = AXI8B;
                       endcase
                128  : randcase
                                 16 : awsize = AXI2B; // more case to cover
                                 8 :  awsize = AXI4B;
                                 4 :  awsize = AXI8B;
                                 2 :  awsize = AXI16B;
                        endcase
                256  :randcase
                                 32 : awsize = AXI2B; // more case to cover
                                 16 :  awsize = AXI4B;
                                 8 :  awsize = AXI8B;
                                 4 :  awsize = AXI16B;
                                 2 :  awsize = AXI32B;
                        endcase 
                512  : awsize = $urandom_range(AXI2B,AXI32B);
                1024 : awsize = $urandom_range(AXI2B,AXI32B);
            endcase
        end
        
        // Address should be aligned to the Data size for Atomic transactions except AtomicCompare
        outgoing_data_size = ((awlen+1)*(2**awsize));
        outgoing_data_size_bits = $clog2(outgoing_data_size);
        if (awcmdtype inside {ATMSTR, ATMLD, ATMSWAP}) begin
             if(!($test$plusargs("address_error_test_ott") || $test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test")))begin
	    awaddr[<%=obj.wCacheLineOffset - 1%>:0] = $urandom;
            end
            for (int i=0; i<$clog2(outgoing_data_size); i++) begin
                awaddr[i] = 0;
            end
        // For AtomicCompare, Address should be aligned to half of outgoing data size
        end else if (awcmdtype == ATMCOMPARE) begin
            `uvm_info(get_type_name(), $sformatf("AIU<%=obj.FUnitId%> atomic compare outgoing_data_size:%0d", outgoing_data_size),UVM_LOW)
            if(!($test$plusargs("address_error_test_ott") || $test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test")))begin
            awaddr[5:0] = $urandom_range(63,0);
            end
            case(outgoing_data_size)
                2: 
                    begin 
                        if (awburst == AXIINCR) awaddr[0] = 0; //0x0, 0x2, 0x4, 0x6 ...
                        else awaddr[0] = 1; //0x1, 0x3, 0x5, 0x7 ...
                    end
                4: 
                    begin 
                        if (awburst == AXIINCR) awaddr[1:0] = 'b00;
                        else awaddr[1:0] = 'b10;
                    end
                8: 
                    begin 
                        if (awburst == AXIINCR) awaddr[2:0] = 'b000;
                        else awaddr[2:0] = 'b100;
                    end  
                16: 
                    begin
                        if (awburst == AXIINCR) awaddr[3:0] = 'b0000;
                        else awaddr[3:0] = 'b1000;
                    end 
                32: 
                    begin 
                        if (awburst == AXIINCR) awaddr[4:0] = 'b00000;
                        else awaddr[4:0] = 'b10000;
                    end
            endcase
        end 
      //  else begin 

      //HS: remove if stable. just commented out for now for future reference. 
      //The constraints below are too tight. So loosened them up
      //          if($test$plusargs("use_atomic_compare")) begin // fsys plusargs
      //          // cf just to cover exactly the table https://arterisip.atlassian.net/browse/CONC-11504   
      //              awaddr[4:0] = $urandom_range(31,0);
      //              case(awsize)
      //                         AXI4B : awaddr[0]   = 1'b0;
      //                         AXI8B : awaddr[1:0] = 2'b0;
      //                         AXI16B: awaddr[2:0] = 3'b0;
      //                         AXI32B: awaddr[3:0] = 4'b0;
      //              endcase
      //              case (awlen)
      //                       0: if (WXDATA !=256) awaddr[4] =0; 
      //                       1: begin 
      //                          if (awsize == AXI16B) awaddr[3:0] = 4'b0; else awaddr[4] = 1'b0;
      //                          if (WXDATA == 64 && awsize == AXI8B) awaddr[2:0] = 3'b0;
      //                          end
      //                       3:  awaddr[3:0] = 4'b0;
      //              endcase
      //          // end cover table
      //          end else begin // keep legacy constraints
      //             if(en_unaligned_addr && $clog2(outgoing_data_size)==1) awaddr[0] = $urandom;//adding for coverage CONC-9195-b01_1_0 
      //             for (int i=0; i< outgoing_data_size_bits -1; i++) begin                                                                              
      //                 awaddr[i] = 0;                                                                                                                   
      //             end                                                                                                                                  
      //          end 
      //          if (awaddr % outgoing_data_size == 0) begin
      //              awburst = AXIINCR;
      //          end else begin
      //              awburst = AXIWRAP;
      //          end
      //      end
      //  end

        // allow plus arg to define awqos
        $value$plusargs("ioaiu_awqos=%d", awqos);
        
        //CONC-9935 Wrap non modifiable burst which cross 64-byte boundary are not supported cf Ncore Supplemental Architecture Specification.pdf
        if (awburst == AXIWRAP && awcache[1]==0) begin:_wrap_64b
           outgoing_data_size = ((awlen+1)*(2**awsize));
			while (outgoing_data_size > 64) begin: _while_64b
					if (awsize > AXI64B) begin
						awsize--;	
				    end else begin
					    awlen--;
					end
			outgoing_data_size = ((awlen+1)*(2**awsize));
           	end:_while_64b	
        end: _wrap_64b
       //CONC-15191 in exlcusive txn updated addr is unconnected addr then its coverted to NORMAL txn with old addr
        if (awlock == EXCLUSIVE) begin 
	  total_txfr_size = (awlen + 1) << awsize;
	  msb = $clog2(total_txfr_size);
          if(addrMgrConst::check_unmapped_add(.addr((awaddr >> msb) << msb),.agent_id(<%=obj.FUnitId%>),.unit_unconnected(unit_unconnected))) begin
            awlock=NORMAL;
          end  else begin
            awaddr = (awaddr >> msb) << msb;
          end
        end

        <%if (obj.Block.includes('aiu')) { %> 

            //`uvm_info(get_type_name(), $sformatf("AIU<%=obj.FUnitId%> wr old len:%0d", awlen),UVM_LOW)
            check_and_update_burst_length(awaddr, awprot[1], awburst,awsize,awlen);
            //`uvm_info(get_type_name(), $sformatf("AIU<%=obj.FUnitId%> wr updated len:%0d", awlen),UVM_LOW)

        <% } %>   

    <% if(obj.testBench == "fsys") { %>
    	if ($test$plusargs("random_gpra_nsx")) begin
       //#Stimulus.FSYS.GPRAR.NS_zero.withatleast.oneTxnSecure
        	awprot[1] = addrMgrConst::get_addr_gprar_nsx(awaddr) ;
    	end
    <% } %>
    
     <% if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %> 
    //Adding the address to cacheable_addrq. The addresses in the q should always be accessed with cacheable attributes. 
    //CONC-15788  
    cacheline_addr_w_sec = ({awprot[1],awaddr} >> 6) << 6;
    
    //`uvm_info(get_type_name(), $sformatf("AIU<%=obj.FUnitId%> awaddr:0x%0h cacheline_addr:0x%0h", awaddr, cacheline_addr_w_sec),UVM_LOW)
    if (awcache[3:2] == 'b00) begin 
       if(cacheline_addr_w_sec inside {addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>]}) begin 
         //`uvm_info(get_type_name(), $sformatf("axcache_cacheable_addrq:%0p", addrMgrConst::axcache_cacheable_addrq),UVM_LOW)
         //`uvm_warning(get_type_name(), $sformatf("cmdtype:%0p cacheline_addr_w_sec:0x%0h awaddr:0x%0h awprot_1:%0b awcache:0x%0h", awcmdtype, cacheline_addr_w_sec, awaddr, awprot[1], awcache))
         awcache[3:2] = $urandom_range(1,3);
         awcache[1] = 1;
         awlock=NORMAL;
     //    `uvm_info(get_type_name(), $sformatf("updated awcache:0x%0h since orig addr is cacheable_addrq", awcache),UVM_LOW)
       end else begin
      //   `uvm_info(get_type_name(), $sformatf("split_cacheable_addrq:%0p", addrMgrConst::split_cacheable_addrq),UVM_LOW)
         fnd = 0;
         foreach(addrMgrConst::split_cacheable_addrq[i]) begin
           if (addrMgrConst::split_cacheable_addrq[i] inside {addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>]}) begin
               fnd = 1;
               break;
           end
         end
         if (fnd == 1) begin        
             awcache[3:2] = $urandom_range(1,3);
             awcache[1] = 1;
             awlock=NORMAL;
       //      `uvm_info(get_type_name(), $sformatf("updated awcache:0x%0h since one of the split addr is in cacheable_addrq", awcache),UVM_LOW)
         end 
       end
    end
    if ((awcache[3:2] != 'b00) && (awcache[1] == 1) && !(cacheline_addr_w_sec inside {addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>]})) begin 
	addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>].push_back(cacheline_addr_w_sec);
       // `uvm_info(get_type_name(), $sformatf("cacheline_addr:0x%0h pushed into addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>] new size:%0d", cacheline_addr_w_sec,addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>].size()),UVM_LOW)
      foreach(addrMgrConst::split_cacheable_addrq[i]) begin
	addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>].push_back(addrMgrConst::split_cacheable_addrq[i]);
       // `uvm_info(get_type_name(), $sformatf("split cacheline_addr:0x%0h pushed into addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>] new size:%0d", addrMgrConst::split_cacheable_addrq[i], addrMgrConst::axcache_cacheable_addrq[<%=obj.FUnitId%>].size()),UVM_LOW)
      end  
    end
     <% } %>
    endfunction : post_randomize

    function new(string name = "ace_write_addr_pkt_t");
        pkt_type = "ACE";
        axi_trace_weight = 0;
        //std::randomize(axi_trace_weight) with {axi_trace_weight dist { 0:=25, 25:=25, 50:=25, 100:=25 };};
        $value$plusargs("native_trace_weight=%d", axi_trace_weight);
        $value$plusargs("axi_trace_weight=%d", axi_trace_weight);
    endfunction : new

    function string sprint_pkt();
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("ID=0x%0x Addr=0x%0x Type=%0s Len=0x%0x Size=0x%0x BurstType=0x%0x Prot=0x%0x Unq=0x%0x  Cache=0x%0x QoS=0x%0x TIME=%0t", awid, awaddr, print_snoop_type(), awlen, awsize, awburst, awprot, awunique,  awcache, awqos, t_pkt_seen_on_intf);  

        end else begin
            sprint_pkt = $sformatf("%0s WRITE AW: ID:0x%0x Addr:0x%0x Type:%0s Len:0x%0x Size:0x%0x BurstType:0x%0x NS:0x%0x Unq:0x%0x Lock:0x%0x Cache:0x%0x QoS:0x%0x User:0x%0h awstashniden:%0h awstashnid:%0h Time:%0t,"
                               , pkt_type, awid, awaddr, print_snoop_type(), awlen, awsize, awburst, awprot[1], awunique, awlock, awcache, awqos, awuser, awstashniden, awstashnid, t_pkt_seen_on_intf); 

            <%if(obj.eTrace > 0) { %>
            sprint_pkt = $sformatf("%0s Trace: 0x%0x", sprint_pkt, awtrace);
            <% } %>
        end
    endfunction : sprint_pkt
    
    function string print_snoop_type();
       if((awatop !== 0) && (awsnoop === 0)) begin
          case(awatop[5:3])
	    'b010,'b011 : print_snoop_type = "ATMSTR";
	    'b100,'b111 : print_snoop_type = "ATMLD";
	    'b110       : begin
	       case(awatop[2:0])
		 'b000       : print_snoop_type = "ATMSWAP";		 
		 'b001       : print_snoop_type = "ATMCOMPARE";
                 default             : `uvm_info(get_type_name(), $sformatf("Undefined AWATOP 0x%0b Addr:0x%0x", awatop,awaddr),UVM_NONE)
	       endcase // case (awatop[2:0])
	    end
            default             : `uvm_info(get_type_name(), $sformatf("Undefined AWATOP 0x%0b Addr:0x%0x", awatop,awaddr),UVM_NONE)
	  endcase
       end else begin
        //#Stimulus.IOAIU.nativeInterface.RdOnce_WrUnq..axdomain
        <% if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %> 
            if (addrMgrConst::get_addr_gprar_nc(awaddr))
                print_snoop_type = "WRNOSNP";
            else 
                print_snoop_type = "WRUNQ";
        <%} else { %>
          case({awsnoop,  awdomain}) 
            'b0000_00,  'b0000_11       : print_snoop_type = "WRNOSNP";
            'b0000_01,  'b0000_10       : print_snoop_type = "WRUNQ";
            'b0001_01,  'b0001_10       : print_snoop_type = "WRLNUNQ";
            'b0010_00,  'b0010_01,
            'b0010_10                   : print_snoop_type = "WRCLN";
            'b0011_00,  'b0011_01,
            'b0011_10                   : print_snoop_type = "WRBK";
            'b0100_01,  'b0100_10       : print_snoop_type = "EVCT";
            'b0101_00,  'b0101_01,
            'b0101_10                   : print_snoop_type = "WREVCT";
            'b1000_01,  'b1000_10       : print_snoop_type = "WRUNQPTLSTASH";
            'b1001_01,  'b1001_10       : print_snoop_type = "WRUNQFULLSTASH";
            'b1100_01,  'b1100_10       : print_snoop_type = "STASHONCESHARED";
            'b1101_01,  'b1101_10       : print_snoop_type = "STASHONCEUNQ";
            'b1110_00,  'b1110_01,
            'b1110_10,  'b1110_11       : print_snoop_type = "STASHTRANS";

	    default           : `uvm_info(get_type_name(), $sformatf("Undefined write address channel snoop type: ID:\
                                                                             0x%0x Addr:0x%0x  Domain:0x%0x Snoop:0x%0x"
                                                                            , awid, awaddr,  awdomain, awsnoop), UVM_NONE)
          endcase // case ({ awdomain, awsnoop})
        <% } %>
       end // else: !if(awatop !== 0)
    endfunction : print_snoop_type 

    function bit do_compare_pkts(ace_write_addr_pkt_t m_pkt);
        bit legal = 1;
        legal = super.do_compare_pkts(m_pkt);
        if (WUSEACEDOMAIN) begin
            if (this.awdomain !== m_pkt.awdomain) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awdomain: 0x%0x Actual: awdomain: 0x%0x", pkt_type, this.awdomain, m_pkt.awdomain), UVM_NONE) 
                legal = 0;
            end
        end
        if (this.awsnoop !== m_pkt.awsnoop) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awsnoop: 0x%0x Actual: awsnoop: 0x%0x", pkt_type, this.awsnoop, m_pkt.awsnoop), UVM_NONE) 
            legal = 0;
        end
        if (this.awatop !== m_pkt.awatop) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awatop: 0x%0x Actual: awatop: 0x%0x", pkt_type, this.awatop, m_pkt.awatop), UVM_NONE) 
            legal = 0;
        end
        if (this.awstashniden !== m_pkt.awstashniden) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awstashniden: 0x%0x Actual: awstashniden: 0x%0x", pkt_type, this.awstashniden, m_pkt.awstashniden), UVM_NONE) 
            legal = 0;
        end
        if (this.awstashnid !== m_pkt.awstashnid) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awstashnid: 0x%0x Actual: awstashnid: 0x%0x", pkt_type, this.awstashnid, m_pkt.awstashnid), UVM_NONE) 
            legal = 0;
        end
        if (this.awstashlpiden !== m_pkt.awstashlpiden) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awstashlpiden: 0x%0x Actual: awstashlpiden: 0x%0x", pkt_type, this.awstashlpiden, m_pkt.awstashlpiden), UVM_NONE) 
            legal = 0;
        end
        if (this.awstashlpid !== m_pkt.awstashlpid) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awstashlpid: 0x%0x Actual: awstashlpid: 0x%0x", pkt_type, this.awstashlpid, m_pkt.awstashlpid), UVM_NONE) 
            legal = 0;
        end
        if (this.awtrace !== m_pkt.awtrace) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awtrace: 0x%0x Actual: awtrace: 0x%0x", pkt_type, this.awtrace, m_pkt.awtrace), UVM_NONE) 
            legal = 0;
        end
        if (this.awloop !== m_pkt.awloop) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awloop: 0x%0x Actual: awloop: 0x%0x", pkt_type, this.awloop, m_pkt.awloop), UVM_NONE) 
            legal = 0;
        end
        if (this.awnsaid !== m_pkt.awnsaid) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awnsaid: 0x%0x Actual: awnsaid: 0x%0x", pkt_type, this.awnsaid, m_pkt.awnsaid), UVM_NONE) 
            legal = 0;
        end
        if (WUSEACEUNIQUE) begin
            if (this.awunique !== m_pkt.awunique) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: awunique: 0x%0x Actual: awunique: 0x%0x", pkt_type, this.awunique, m_pkt.awunique), UVM_NONE) 
                legal = 0;
            end
        end
        return legal;
    endfunction : do_compare_pkts
    function bit is_cacheline_size_txn();
        if (awcmdtype inside {WRLNUNQ  , WREVCT, EVCT, STASHONCEUNQ, STASHONCESHARED , WRUNQFULLSTASH , WRUNQPTLSTASH})

            return 1;
        else 
            return 0;
    endfunction: is_cacheline_size_txn
 
endclass : ace_write_addr_pkt_t


//-------------------------------------------------------------------------------------------------- 
// ACE Read data channel transaction packet (R)
//-------------------------------------------------------------------------------------------------- 

class axi4_read_data_pkt_t extends uvm_object;
    randc axi_arid_t  rid;
    rand  axi_xdata_t rdata[];
    randc axi_rresp_t rresp;
    randc axi_rresp_t rresp_per_beat[];
    randc axi_ruser_t ruser;
    int                                          rdata_pattern[];
    time                                         t_rtime[];
    string                                       pkt_type;
    bit                                          rlast;
    time                                         t_pkt_seen_on_intf;

    `uvm_object_param_utils_begin (axi4_read_data_pkt_t)
        `uvm_field_int      (rid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int(rdata, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int(rresp_per_beat, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (rresp, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (ruser, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int(rdata_pattern, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (rlast, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    constraint c_rresp {
        rresp[CBRESP-1:0] == OKAY;
        foreach (rresp_per_beat[i]) {
            rresp_per_beat[i][CBRESP-1:0] == OKAY;
        }
    };

    function new(string name = "axi4_read_data_pkt_t");
        pkt_type = "AXI4";
    endfunction : new

    function string sprint_pkt();
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("Burst=0x%0x ID=0x%0x Resp0=%0s Data0=0x%0x TIME=%0t"
                ,  0, rid, print_resp_type(0), rdata[0], t_pkt_seen_on_intf);  

        end else begin
            sprint_pkt = $sformatf("%0s READ R: Burst:0x%0x ID:0x%0x Resp0:%0s Data0:0x%0x Time:%0t"
                , pkt_type, 0, rid, print_resp_type(0), rdata[0], t_pkt_seen_on_intf); 
            for (int i = 1; i < rdata.size; i++) begin
                sprint_pkt = {sprint_pkt, $sformatf("Data%0d:0x%0x Resp%0d:%0s"
                , i, rdata[i], i, print_resp_type(i))};  
            end
        end
    endfunction : sprint_pkt

    function bit do_compare_pkts(axi4_read_data_pkt_t m_pkt, bit only_check_data = 0);
        bit legal = 1;
        if (this.rid !== m_pkt.rid && !only_check_data) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: rid: 0x%0x Actual: rid: 0x%0x", pkt_type, this.rid, m_pkt.rid), UVM_NONE) 
            legal = 0;
        end
        if (this.rdata.size() !== m_pkt.rdata.size()) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: rdata size: 0x%0x Actual: rdata size: 0x%0x", pkt_type, this.rdata.size(), m_pkt.rdata.size()), UVM_NONE) 
            legal = 0;
        end
        foreach (rdata[i]) begin
            if (this.rdata[i] !== m_pkt.rdata[i] && m_pkt.rresp_per_beat[i][1] !== 1) begin // Only check if there is no SLVERR or DECERR in error response
                `uvm_info(get_type_name(), $sformatf("ERROR %0s beat:0x%0x Expected: rdata: 0x%0x Actual: rdata: 0x%0x", pkt_type, i, this.rdata[i], m_pkt.rdata[i]), UVM_NONE) 
                legal = 0;
            end
        end
        if (this.rresp_per_beat.size() !== m_pkt.rresp_per_beat.size() && !only_check_data) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: rresp_per_beat size: 0x%0x Actual: rresp_per_beat size: 0x%0x", pkt_type, this.rresp_per_beat.size(), m_pkt.rresp_per_beat.size()), UVM_NONE) 
            legal = 0;
        end
        foreach (rresp_per_beat[i]) begin
            if (this.rresp_per_beat[i] !== m_pkt.rresp_per_beat[i] && !only_check_data) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s beat:0x%0x Expected: rresp_per_beat: 0x%0x Actual: rresp_per_beat: 0x%0x", pkt_type, i, this.rresp_per_beat[i], m_pkt.rresp_per_beat[i]), UVM_NONE) 
                legal = 0;
            end
        end
        if (WRUSER != 0) begin
            if (this.ruser !== m_pkt.ruser && !only_check_data) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: ruser: 0x%0x Actual: ruser: 0x%0x", pkt_type, this.ruser, m_pkt.ruser), UVM_NONE) 
                legal = 0;
            end
        end
        return legal;
    endfunction : do_compare_pkts

    function string print_resp_type(int beat);
        case(this.rresp_per_beat[beat][CBRESP-1:0]) 
            'b00   : print_resp_type = "OKAY";
            'b01   : print_resp_type = "EXOKAY";
            'b10   : print_resp_type = "SLVERR";
            'b11   : print_resp_type = "DECERR";
            default: print_resp_type = "UNDEF";
        endcase
    endfunction : print_resp_type 
endclass : axi4_read_data_pkt_t  


class ace_read_data_pkt_t extends axi4_read_data_pkt_t;
    rand axi_rpoison_t  rpoison[];
    rand axi_rdatachk_t rdatachk[];
    rand bit            rtrace;
    rand axi_rloop_t    rloop;

    `uvm_object_param_utils_begin(ace_read_data_pkt_t)
        `uvm_field_array_int(rpoison, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int(rdatachk, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int(rtrace, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int(rloop, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    function new(string name = "ace_read_data_pkt_t");
        pkt_type = "ACE";
    endfunction : new

    function string sprint_pkt();
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("Burst=0x%0x ID=0x%0x PD=0x%0x IS=0x%0x Resp0=%0s Data0=0x%0x TIME=%0t" , 0, rid, 
            <% if (obj.fnNativeInterface == "ACE"|| obj.fnNativeInterface == "ACE5") { %> 
            rresp_per_beat[0][CRRESPPASSDIRTYBIT], rresp_per_beat[0][CRRESPISSHAREDBIT], 
             <% } else { %>
            0,0,
            <%}%>
            print_resp_type(0), rdata[0], t_pkt_seen_on_intf);  

        end else begin
            sprint_pkt = $sformatf("%0s READ R: Burst:0x%0x ID:0x%0x Resp:(PD:0x%0x IS:0x%0x) Resp0:%0s Data0:0x%0x Time:%0t" , pkt_type, 0, rid, 
            <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %> 
            rresp_per_beat[0][CRRESPPASSDIRTYBIT], rresp_per_beat[0][CRRESPISSHAREDBIT],
             <% } else { %>
            0,0,
            <%}%>
            print_resp_type(0), rdata[0], t_pkt_seen_on_intf); 
            <%if(obj.eTrace > 0) { %>
            sprint_pkt = $sformatf("%0s Trace: 0x%0x ", sprint_pkt, rtrace);
            <% } %>
            for (int i = 1; i < rdata.size; i++) begin
                sprint_pkt = {sprint_pkt, $sformatf("Data%0d:0x%0x Resp%0d:%0s"
                , i, rdata[i], i, print_resp_type(i))};  
            end
        end
    endfunction : sprint_pkt
    
    function bit do_compare_pkts(ace_read_data_pkt_t m_pkt, bit only_check_data);
        bit legal = 1;
        legal = super.do_compare_pkts(m_pkt, only_check_data);

        if (this.rtrace !== m_pkt.rtrace) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: rtrace: 0x%0x Actual: rtrace: 0x%0x", pkt_type, this.rtrace, m_pkt.rtrace), UVM_NONE) 
            legal = 0;
        end

        if (this.rloop !== m_pkt.rloop) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: rloop: 0x%0x Actual: rloop: 0x%0x", pkt_type, this.rloop, m_pkt.rloop), UVM_NONE) 
            legal = 0;
        end

        foreach (rpoison[i]) begin
            if (this.rpoison[i] !== m_pkt.rpoison[i]) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s beat:0x%0x Expected: rpoison: 0x%0x Actual: rpoison: 0x%0x", pkt_type, i, this.rpoison[i], m_pkt.rpoison[i]), UVM_NONE) 
                legal = 0;
            end
        end

        foreach (rdatachk[i]) begin
            if (this.rdatachk[i] !== m_pkt.rdatachk[i]) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s beat:0x%0x Expected: rdatachk: 0x%0x Actual: rdatachk: 0x%0x", pkt_type, i, this.rdatachk[i], m_pkt.rdatachk[i]), UVM_NONE) 
                legal = 0;
            end
        end

        return legal;
    endfunction : do_compare_pkts

endclass : ace_read_data_pkt_t

class ace_read_data_pkt_cell_t extends uvm_object;
    randc axi_arid_t  rid;
    rand  axi_xdata_t rdata;
    randc axi_rresp_t rresp;
    randc axi_ruser_t ruser;
    rand axi_rpoison_t  rpoison;
    rand axi_rdatachk_t rdatachk;
    rand bit            rtrace;
    rand axi_rloop_t    rloop;

    bit                                          rlast;
    // Used to make sure read data packets go in order
    int                                          rctr;
    // When the packet was received. This is to support multiple
    // outstanding requests with the same axid
    time                                         rtime;
    int                                          rtime_counter = 0;

    `uvm_object_param_utils_begin (ace_read_data_pkt_cell_t)
        `uvm_field_int      (rid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (rdata, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (rresp, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (ruser, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (rlast, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (rpoison, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (rdatachk, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (rtrace, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (rloop, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    function new(string name = "ace_read_data_pkt_cell_t");
    endfunction : new
endclass : ace_read_data_pkt_cell_t


//-------------------------------------------------------------------------------------------------- 
// ACE Write data channel transaction packet (W)
//-------------------------------------------------------------------------------------------------- 

class axi4_write_data_pkt_t extends uvm_object;
    //axi_awid_t  wid;
    rand  axi_xdata_t wdata[];
    rand  axi_xstrb_t wstrb[];
    randc axi_wuser_t wuser;
    rand bit                      en_user_delay_after_txn;
    rand bit                      en_user_delay_before_txn;
    rand int                      val_user_delay_after_txn;
    rand int                      val_user_delay_before_txn;
    time                                         t_wtime[];
    string                                       pkt_type;
    bit                                          wlast;
    time                                         t_pkt_seen_on_intf;

    constraint delay_c {
       soft  en_user_delay_after_txn==0;
       soft  en_user_delay_before_txn==0;
       soft  val_user_delay_after_txn==0;
       soft  val_user_delay_before_txn==0;
       //soft  val_user_delay_after_txn inside {[1:2]};
       //soft  val_user_delay_before_txn inside {[1:2]};
    };

    `uvm_object_param_utils_begin (axi4_write_data_pkt_t)
        //`uvm_field_int      (wid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int(wdata, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int(wstrb, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int(t_wtime, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (wuser, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (wlast, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (en_user_delay_after_txn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (en_user_delay_before_txn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (val_user_delay_after_txn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (val_user_delay_before_txn, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    function new(string name = "axi4_write_data_pkt_t");
        pkt_type = "AXI4";
    endfunction : new

    function string sprint_pkt();
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("Burst=0x%0x Strb0=0x%0x Data0=0x%0x TIME=%0t"
                ,  0, wstrb[0], wdata[0], t_pkt_seen_on_intf);  
        end else begin

            sprint_pkt = $sformatf("%0s WRITE W: Burst:0x%0x Strb0:0x%0x Data0:0x%0x Time:%0t"
                , pkt_type, 0, wstrb[0], wdata[0], t_pkt_seen_on_intf); 
            for (int i = 1; i < wdata.size; i++) begin
                sprint_pkt = {sprint_pkt, $sformatf(" Strb%0d:0x%0x Data%0d:0x%0x"
                , i, wstrb[i], i, wdata[i])};  
            end
        end
        return sprint_pkt;
       
    endfunction : sprint_pkt
    
    function bit do_compare_pkts(axi4_write_data_pkt_t m_pkt, bit only_check_data = 0, bit aiu_double_bit_errors_enabled = 0);
        bit legal = 1;
        if (this.wdata.size() !== m_pkt.wdata.size()) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: wdata size: 0x%0x Actual: wdata size: 0x%0x", pkt_type, this.wdata.size(), m_pkt.wdata.size()), UVM_NONE) 
            legal = 0;
        end
        foreach (wdata[i]) begin
            if (this.wdata[i] !== m_pkt.wdata[i] && m_pkt.wstrb[i] !== '0 && this.wstrb[i] !== '0) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s beat:0x%0x Expected: wdata: 0x%0x Actual: wdata: 0x%0x", pkt_type, i, this.wdata[i], m_pkt.wdata[i]), UVM_NONE) 
                legal = 0;
            end
        end
        if (this.wstrb.size() !== m_pkt.wstrb.size()) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: wstrb size: 0x%0x Actual: wstrb size: 0x%0x", pkt_type, this.wstrb.size(), m_pkt.wstrb.size()), UVM_NONE) 
            legal = 0;
        end
        foreach (wstrb[i]) begin
            if (this.wstrb[i] !== m_pkt.wstrb[i] && !aiu_double_bit_errors_enabled) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s beat:0x%0x Expected: wstrb: 0x%0x Actual: wstrb: 0x%0x", pkt_type, i, this.wstrb[i], m_pkt.wstrb[i]), UVM_NONE) 
                legal = 0;
            end
        end
        if (WWUSER != 0) begin
            if (this.wuser !== m_pkt.wuser) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: wuser: 0x%0x Actual: wuser: 0x%0x", pkt_type, this.wuser, m_pkt.wuser), UVM_NONE) 
                legal = 0;
            end
        end
        return legal;
    endfunction : do_compare_pkts

    function bit do_compare_pkts_per_byte(axi4_write_data_pkt_t m_pkt, bit only_check_data = 0, bit aiu_double_bit_errors_enabled = 0);
        bit legal = 1;
        if (this.wdata.size() !== m_pkt.wdata.size()) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: wdata size: 0x%0x Actual: wdata size: 0x%0x", pkt_type, this.wdata.size(), m_pkt.wdata.size()), UVM_NONE) 
            legal = 0;
        end
        if (this.wstrb.size() !== m_pkt.wstrb.size()) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: wstrb size: 0x%0x Actual: wstrb size: 0x%0x", pkt_type, this.wstrb.size(), m_pkt.wstrb.size()), UVM_NONE) 
            legal = 0;
        end
        foreach (wstrb[i]) begin
            if (this.wstrb[i] !== m_pkt.wstrb[i] && !aiu_double_bit_errors_enabled) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s beat:0x%0x Expected: wstrb: 0x%0x Actual: wstrb: 0x%0x", pkt_type, i, this.wstrb[i], m_pkt.wstrb[i]), UVM_NONE) 
                legal = 0;
            end
        end
        foreach (wdata[i]) begin
            if (this.wdata[i] !== m_pkt.wdata[i] ) begin
              foreach(wstrb[i][j]) begin
               if(wstrb[i][j]) begin
                 if(this.wdata[i][j*8+:8] !== m_pkt.wdata[i][j*8+:8]) begin
                  `uvm_info(get_type_name(), $sformatf("ERROR %0s beat:0x%0x byte:%0d Expected: wdata: 0x%0x Actual: wdata: 0x%0x", pkt_type, i,j,this.wdata[i][j*8+:8], m_pkt.wdata[i][j*8+:8]), UVM_NONE) 
                  legal = 0;
                 end
               end
              end
            end
        end
        if (WWUSER != 0) begin
            if (this.wuser !== m_pkt.wuser) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: wuser: 0x%0x Actual: wuser: 0x%0x", pkt_type, this.wuser, m_pkt.wuser), UVM_NONE) 
                legal = 0;
            end
        end
        return legal;
    endfunction : do_compare_pkts_per_byte
    /*
    function bit do_compare_sfi_data(sfi_data_t m_sfi_data[], sfi_be_t m_sfi_be[], bit aiu_double_bit_errors_enabled = 0);
        bit legal = 1;
        
        // Assuming that SFI data width is same as ACE data width - Concerto V1 requirement
        if (WXDATA !== wSmiDPdata) begin
            `uvm_info(get_full_name(), $sformatf("Concerto V1 assumption is that SFI data width is same as write data with, but its not (SFI:0x%0x ACE:0x%0x)", wSmiDPdata, WXDATA), UVM_NONE)
        end
        else if (wdata.size() !== m_sfi_data.size()) begin
            `uvm_info(get_type_name(), $sformatf("%0s data size mismatch (SFI:%0d ACE:%0d)", pkt_type, m_sfi_data.size(), wdata.size()), UVM_NONE) 
            legal = 0;
        end
        else begin
            foreach (wdata[i]) begin
                foreach (m_sfi_be[i][j]) begin
                    if ((data_size_t'(wdata[i][(j*8) +: 8]) !== data_size_t'(m_sfi_data[i][(j*8) +: 8])) && m_sfi_be[i][j] == 1) begin
                        //if (!(aiu_double_bit_errors_enabled)) begin 
                            `uvm_info(get_type_name(), $sformatf("%0s data mismatch (beat:0x%0x SFI:0x%0x ACE:0x%0x)", pkt_type, i, m_sfi_data[i], wdata[i]), UVM_NONE) 
                            legal = 0;
                        //end
                    end
                end
            end
        end
        if (wstrb.size() !== m_sfi_be.size()) begin
            `uvm_info(get_type_name(), $sformatf("%0s strobe size mismatch (SFI:%0d ACE:%0d)", pkt_type, m_sfi_be.size(), wstrb.size()), UVM_NONE) 
            legal = 0;
        end
        else begin
            foreach (wstrb[i]) begin
                if (strb_size_t'(wstrb[i]) !== strb_size_t'(m_sfi_be[i])) begin
                    if (!(aiu_double_bit_errors_enabled && m_sfi_be[i] == '0)) begin 
                        `uvm_info(get_type_name(), $sformatf("%0s strb mismatch (beat:0x%0x SFI:0x%0x ACE:0x%0x)", pkt_type, i, m_sfi_be[i], wstrb[i]), UVM_NONE) 
                        legal = 0;
                    end
                end
            end
        end
 
        return legal;
    endfunction : do_compare_sfi_data
    */
endclass : axi4_write_data_pkt_t

class ace_write_data_pkt_t extends axi4_write_data_pkt_t;
    rand axi_wpoison_t  wpoison[];
    rand axi_wdatachk_t wdatachk[];
    rand bit            wtrace;

    `uvm_object_param_utils_begin(ace_write_data_pkt_t)
        `uvm_field_array_int(wpoison, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int(wdatachk, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (wtrace, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    function new(string name = "ace_write_data_pkt_t");
        pkt_type = "ACE";
    endfunction : new

    function bit do_compare_pkts(ace_write_data_pkt_t m_pkt, bit only_check_data = 0, bit aiu_double_bit_errors_enabled = 0);
        bit legal = 1;
        legal = super.do_compare_pkts(m_pkt, only_check_data, aiu_double_bit_errors_enabled);

        foreach (wpoison[i]) begin
            if (this.wpoison[i] !== m_pkt.wpoison[i] && m_pkt.wstrb[i] !== '0 && this.wstrb[i] !== '0) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s beat:0x%0x Expected: wpoison: 0x%0x Actual: wpoison: 0x%0x", pkt_type, i, this.wpoison[i], m_pkt.wpoison[i]), UVM_NONE) 
                legal = 0;
            end
        end

        foreach (wdatachk[i]) begin
            if (this.wdatachk[i] !== m_pkt.wdatachk[i] && m_pkt.wstrb[i] !== '0 && this.wstrb[i] !== '0) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s beat:0x%0x Expected: wdatachk: 0x%0x Actual: wdatachk: 0x%0x", pkt_type, i, this.wdatachk[i], m_pkt.wdatachk[i]), UVM_NONE) 
                legal = 0;
            end
        end

        if (this.wtrace !== m_pkt.wtrace) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: wtrace: 0x%0x Actual: wtrace: 0x%0x", pkt_type, this.wtrace, m_pkt.wtrace), UVM_NONE) 
            legal = 0;
        end

        return legal;
    endfunction : do_compare_pkts

endclass : ace_write_data_pkt_t


//-------------------------------------------------------------------------------------------------- 
// ACE Write response channel transaction packet (B)
//-------------------------------------------------------------------------------------------------- 

class axi4_write_resp_pkt_t extends uvm_object;
    randc axi_awid_t       bid;
    randc axi_bresp_enum_t bresp;
    randc axi_buser_t      buser;
    string                                            pkt_type;
    time                                              t_pkt_seen_on_intf;
    int                                          rtime_counter = 0;

    `uvm_object_param_utils_begin(axi4_write_resp_pkt_t)
        `uvm_field_int     (bid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_enum    (axi_bresp_enum_t, bresp, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (buser, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    constraint c_bresp {
        bresp[CBRESP-1:0] == OKAY;
    };

    function new(string name = "axi4_write_resp_pkt_t");
        pkt_type = "AXI4";
    endfunction : new

    function string sprint_pkt();
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("ID=0x%0x Resp=%0s TIME=%0t"
                               , bid, bresp.name(), t_pkt_seen_on_intf);  
        end else begin
            sprint_pkt = $sformatf("%0s WRITE B: ID:0x%0x Resp:%0s Time:%0t"
                               , pkt_type, bid, bresp.name(), t_pkt_seen_on_intf); 
        end
    endfunction : sprint_pkt
    
    function string print_resp_type();
        case(this.bresp[CBRESP-1:0]) 
            'b00   : print_resp_type = "OKAY";
            'b01   : print_resp_type = "EXOKAY";
            'b10   : print_resp_type = "SLVERR";
            'b11   : print_resp_type = "DECERR";
            default: print_resp_type = "UNDEF";
        endcase
    endfunction : print_resp_type 
    
    function bit do_compare_pkts(axi4_write_resp_pkt_t m_pkt);
        bit legal = 1;
        if (this.bresp !== m_pkt.bresp) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: bresp: 0x%0x Actual: bresp: 0x%0x", pkt_type, this.bresp, m_pkt.bresp), UVM_NONE) 
            legal = 0;
        end
        if (this.bid !== m_pkt.bid) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: bid: 0x%0x Actual: bid: 0x%0x", pkt_type, this.bid, m_pkt.bid), UVM_NONE) 
            legal = 0;
        end
        if (WBUSER != 0) begin
            if (this.buser !== m_pkt.buser) begin
                `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: buser: 0x%0x Actual: buser: 0x%0x", pkt_type, this.buser, m_pkt.buser), UVM_NONE) 
                legal = 0;
            end
        end
        return legal;
    endfunction : do_compare_pkts

    /*
    function bit do_compare_sfi(STRreqAce_t m_sfi_str_req);
        bit              legal = 1;

        if ((m_sfi_str_req.ex_okay) ? this.bresp !== EXOKAY : this.bresp == EXOKAY) begin
            `uvm_info(get_type_name(), $sformatf("%0s bresp: %s SFI STR ex_okay: 0x%0x", pkt_type, bresp.name(), m_sfi_str_req.ex_okay), UVM_NONE) 
            legal = 0;
        end
        return legal;
    endfunction : do_compare_sfi
    */
endclass : axi4_write_resp_pkt_t

class ace_write_resp_pkt_t extends axi4_write_resp_pkt_t;
    rand bit            btrace;
    rand axi_bloop_t    bloop;

    `uvm_object_param_utils_begin(ace_write_resp_pkt_t)
        `uvm_field_int     (btrace, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (bloop, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end


    function new(string name = "ace_write_resp_pkt_t");
        pkt_type = "ACE";
    endfunction : new

    function bit do_compare_pkts(ace_write_resp_pkt_t m_pkt);
        bit legal = 1;
        legal = super.do_compare_pkts(m_pkt);
        if (this.btrace !== m_pkt.btrace) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: btrace: 0x%0x Actual: btrace: 0x%0x", pkt_type, this.btrace, m_pkt.btrace), UVM_NONE) 
            legal = 0;
        end
        if (this.bloop !== m_pkt.bloop) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: bloop: 0x%0x Actual: bloop: 0x%0x", pkt_type, this.bloop, m_pkt.bloop), UVM_NONE) 
            legal = 0;
        end

        return legal;
    endfunction : do_compare_pkts

    function string sprint_pkt();
            sprint_pkt = super.sprint_pkt;
            <%if(obj.eTrace > 0) { %>
            sprint_pkt = $sformatf("%0s Trace: 0x%0x", sprint_pkt, btrace);
            <% } %>
    endfunction : sprint_pkt
endclass : ace_write_resp_pkt_t

//-------------------------------------------------------------------------------------------------- 
// ACE Snoop address channel transaction packet (AC)
//-------------------------------------------------------------------------------------------------- 

class ace_snoop_addr_pkt_t extends uvm_object;
    rand  axi_axaddr_t    acaddr;
    rand  axi_acsnoop_t   acsnoop;
    rand  axi_acvmidext_t acvmid;
    rand  bit             actrace;
    randc axi_axprot_t    acprot;
    time                  t_pkt_seen_on_intf;

    `uvm_object_param_utils_begin(ace_snoop_addr_pkt_t)
        `uvm_field_int     (acaddr, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (acsnoop, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (acvmid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (actrace, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (acprot, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT +UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "ace_snoop_addr_pkt_t");
    endfunction : new

    function string sprint_pkt();
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("Addr=0x%0x Type=%0s Prot=0x%0x Trace:0x%0x TIME=%0t"
                               ,acaddr, print_snoop_type(), acprot, actrace, t_pkt_seen_on_intf);
        end else begin
            sprint_pkt = $sformatf("ACE SNOOP AC: Addr:0x%0x Type:%0s NS:0x%0x VmidExt:0x%0x Trace:0x%0x Time:%0t"
                               ,acaddr, print_snoop_type(), acprot[1], acvmid, actrace, t_pkt_seen_on_intf);
        end
    endfunction : sprint_pkt
    
    function string print_snoop_type();
        case(this.acsnoop) 
            'b0000: print_snoop_type = "RDONCE";
            'b0001: print_snoop_type = "RDSHRD";
            'b0010: print_snoop_type = "RDCLN";
            'b0011: print_snoop_type = "RDNOTSHRDDIR";
            'b0111: print_snoop_type = "RDUNQ";
            'b1000: print_snoop_type = "CLNSHRD";
            'b1001: print_snoop_type = "CLNINVL";
            'b1101: print_snoop_type = "MKINVL";
            'b1110: print_snoop_type = "DVMCMPL";
            'b1111: print_snoop_type = "DVMMSG";
            default           : `uvm_info(get_type_name(), $sformatf("Undefined snoop address channel snoop type:\
                                                                             Addr:0x%0x Prot:0x%0x Snoop:0x%0x"
                                                                               , acaddr, acprot, acsnoop), UVM_NONE)
        endcase
    endfunction : print_snoop_type 

    function bit do_compare_pkts(ace_snoop_addr_pkt_t m_pkt);
        bit legal = 1;
        string pkt_type = "ACE";
        if (this.acaddr !== m_pkt.acaddr) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: acaddr: 0x%0x Actual: acaddr: 0x%0x", pkt_type, this.acaddr, m_pkt.acaddr), UVM_NONE) 
            legal = 0;
        end
        if (this.acprot !== m_pkt.acprot) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: acprot: 0x%0x Actual: acprot: 0x%0x", pkt_type, this.acprot, m_pkt.acprot), UVM_NONE) 
            legal = 0;
        end
        <% if (obj.DVMVersionSupport > 128) { %>
        if (this.acvmid !== m_pkt.acvmid) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: acvmid: 0x%0x Actual: acvmid: 0x%0x", pkt_type, this.acvmid, m_pkt.acvmid), UVM_NONE) 
            legal = 0;
        end
        <% } %>
        if (this.acsnoop !== m_pkt.acsnoop) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: acsnoop: 0x%0x Actual: acsnoop: 0x%0x", pkt_type, this.acsnoop, m_pkt.acsnoop), UVM_NONE)
            legal = 0;
        end
        <%if(obj.eTrace > 0) { %>
        if (this.actrace !== m_pkt.actrace) begin
            `uvm_info(get_type_name(), $sformatf("ERROR %0s Expected: actrace: 0x%0x Actual: actrace: 0x%0x", pkt_type, this.actrace, m_pkt.actrace), UVM_NONE)
            legal = 0;
        end
        <% } %>
        return legal;
    endfunction : do_compare_pkts
endclass : ace_snoop_addr_pkt_t

//-------------------------------------------------------------------------------------------------- 
// ACE Snoop response channel transaction packet (CR)
//-------------------------------------------------------------------------------------------------- 

class ace_snoop_resp_pkt_t extends uvm_object;
    randc axi_crresp_t crresp;
    rand  bit          crtrace;
    rand axi_crnsaid_t crnsaid;
    rand  bit          is_dvm_sync_crresp;
    time               t_pkt_seen_on_intf;

    `uvm_object_param_utils_begin(ace_snoop_resp_pkt_t)
        `uvm_field_int     (crresp, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (crtrace, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (crnsaid, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (is_dvm_sync_crresp, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    function new(string name = "ace_snoop_resp_pkt_t");
    endfunction : new

    function string sprint_pkt();
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("WU:0x%0x IS=0x%0x PD=0x%0x Err=0x%0x DT=0x%0x Trace=0x%0x TIME=%0t"
                               ,crresp[CCRRESPWASUNIQUEBIT], crresp[CCRRESPISSHAREDBIT], crresp[CCRRESPPASSDIRTYBIT], crresp[CCRRESPERRBIT], crresp[CCRRESPDATXFERBIT], crtrace, t_pkt_seen_on_intf);  
        end else begin
            sprint_pkt = $sformatf("ACE SNOOP CR: Resp:(WU:0x%0x IS:0x%0x PD:0x%0x Err:0x%0x DT:0x%0x) Trace=0x%0x is_dvm_sync_crresp:0x%0x Time:%0t)"
                                   ,crresp[CCRRESPWASUNIQUEBIT], crresp[CCRRESPISSHAREDBIT], crresp[CCRRESPPASSDIRTYBIT], crresp[CCRRESPERRBIT], crresp[CCRRESPDATXFERBIT], crtrace, is_dvm_sync_crresp, t_pkt_seen_on_intf);
        end
    endfunction : sprint_pkt
    
endclass : ace_snoop_resp_pkt_t


//-------------------------------------------------------------------------------------------------- 
// ACE Snoop data channel transaction packet (CD)
//-------------------------------------------------------------------------------------------------- 

class ace_snoop_data_pkt_t extends uvm_object;
    rand axi_cddata_t    cddata[];
    rand axi_cdpoison_t  cdpoison[];
    rand axi_cddatachk_t cddatachk[];
    rand bit             cdtrace;
    time                 t_cdtime[];
    bit                  cdlast;
    time                 t_pkt_seen_on_intf;

    `uvm_object_param_utils_begin(ace_snoop_data_pkt_t)
        `uvm_field_array_int(cddata, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int(cdpoison, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int(cddatachk, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (cdtrace, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int      (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    function new(string name = "ace_snoop_data_pkt_t");
    endfunction : new

    function string sprint_pkt();
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("Data0=0x%0x TIME=%0t"
                , cddata[0], t_pkt_seen_on_intf);  
        end else begin
            sprint_pkt = $sformatf("ACE SNOOP CD: Data0:0x%0x Time:%0t"
                , cddata[0], t_pkt_seen_on_intf);  
            for (int i = 1; i < cddata.size; i++) begin
                sprint_pkt = {sprint_pkt, $sformatf("Data%0d:0x%0x"
                , i, cddata[i])};  
            end
        end
    endfunction : sprint_pkt
    
endclass : ace_snoop_data_pkt_t


