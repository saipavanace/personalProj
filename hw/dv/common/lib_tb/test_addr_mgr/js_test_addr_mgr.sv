

class base_test;

    function new (string name = "base_test");
    endfunction: new

endclass: base_test

class duplicate_address_test extends base_test;

    function new(string name = "duplicate_address_test");
        super.new(name);
    endfunction: new

    task run_test();

    endtask: run_test

endclass: duplicate_address_test;

class aiu_interleaving_test extends base_test;

    ace_cache_line_model agent0_cache[$];
    ace_cache_line_model agent1_cache[$];
    ace_cache_line_model agent2_cache[$];
    ace_cache_line_model agent3_cache[$];
    ace_cache_line_model agent4_cache[$];
    ace_cache_line_model agent5_cache[$];
    bit[63:0] inflight_q[$];

    AddrTransMgr m_mgr0;
    AddrTransMgr m_mgr1;
    AddrTransMgr m_mgr2;
    AddrTransMgr m_mgr3;
    AddrTransMgr m_mgr4;
    AddrTransMgr m_mgr5;

    function new(string name = "aiu_interleaving_test");
    endfunction: new

    task run_test();
       bit [ncoreConfigInfo::ADDR_WIDTH-1:0] cacheline;
       int q[$];

       //print_cacheid(3);
       //print_cacheid(4);

       $display("Test: width = %0d", ncoreConfigInfo::get_agent_selbits_width(3));
       $display("Test: value = %0d", ncoreConfigInfo::get_agent_selbits_value(3));
       ncoreConfigInfo::get_agent_selbits(3, q);

       foreach(q[indx]) begin
           $display("Test: select bit index = %0d", q[indx]);
       end

       m_mgr0 = AddrTransMgr::GetInstance_AddrTransMgr();
       cacheline = m_mgr0.req_cacheline(3, agent0_cache, inflight_q);

       $display("Value1: cacheline = %h", cacheline);

       $display("\n=====================================\n");
       cacheline = m_mgr0.req_cacheline(4, agent0_cache, inflight_q);
       $display("Value2: cacheline = %h", cacheline);

       $display("\n=====================================\n");
       $display("interleaved = %b predicted = 1", ncoreConfigInfo::agent_is_interleaved(0, 1));
       $display("interleaved = %b predicted = 0", ncoreConfigInfo::agent_is_interleaved(0, 5));
       $display("interleaved = %b predicted = 1", ncoreConfigInfo::agent_is_interleaved(2, 0));
       $display("interleaved = %b predicted = 0", ncoreConfigInfo::agent_is_interleaved(3, 4));
       $display("interleaved = %b predicted = 1", ncoreConfigInfo::agent_is_interleaved(1, 3));
       

    endtask: run_test

    function print_cacheid(int agent_id);
        int cache_id, col_indx;

        ncoreConfigInfo::get_cacheid(agent_id, cache_id, col_indx);
        $display("cahceid = %0d col_indx = %0d", cache_id, col_indx);
    endfunction: print_cacheid

endclass: aiu_interleaving_test

class memory_prefix_test extends base_test;

<%
    var memRegionPrefix = [];
    var memRegionWidth = [];
    for(var i = 0; i < obj.MemRegionInfo.length; i++) {
        memRegionPrefix.push(obj.MemRegionInfo[i].nRegionPrefix);
        memRegionWidth.push(obj.MemRegionInfo[i].wRegionAddr);
    }
%>
    int mem_region_prefix[$] = '{<%=memRegionPrefix%>};
    localparam MSB    = <%=obj.AiuInfo[0].NativeInfo.SignalInfo.wAxAddr%> - 1;
    int lsb[$] = '{<%=memRegionWidth%>};

    AddrTransMgr m_mgr0;
    ace_cache_line_model agent0_cache[$];
    bit[63:0] inflight_q[$];
    

    function new(string name = "memory_prefix_test");
        super.new(name);
    endfunction: new

    task run_test();
        bit [ncoreConfigInfo::ADDR_WIDTH-1:0] cacheline;

        m_mgr0 = AddrTransMgr::GetInstance_AddrTransMgr();
        
        for(int i = 0; i < 50; i++) begin
            bit check;
        
            cacheline = m_mgr0.req_cacheline(0, agent0_cache, inflight_q);
            foreach(mem_region_prefix[idx]) begin
                bit [MSB:0] prefix_bits;

                prefix_bits = cacheline >> lsb[idx];   //shift left to remove bits until prefix
                if(mem_region_prefix[idx] == prefix_bits) begin
                    $display("PASSED: caheline %h mem_region: %0d prefix: %0h", cacheline, idx, prefix_bits);
                    check = 1;
                    break;
                end else begin
                    //$display("Mismatch: caheline %h mem_region: %0d prefix: %0h", cacheline, idx, prefix_bits);
                end
            end
            if(!check) begin
                $display("ERROR: caheline %h; prefix bits do not match with any of config values", cacheline);
                $finish();
            end
        end
     endtask: run_test

endclass: memory_prefix_test

class iocache_test extends base_test;

    function new(string name = "memory_prefix_test");
        super.new(name);
    endfunction: new

    task run_test();
        AddrTransMgr m_mgr0;
        bit [ncoreConfigInfo::ADDR_WIDTH-1:0] non_coh_addr;

        for(int i = 0; i < ncoreConfigInfo::NUM_AIUS; i++) begin
            $display("Agent is %s", ncoreConfigInfo::get_native_interface(i).name());
        end

        m_mgr0 = AddrTransMgr::GetInstance_AddrTransMgr();

        repeat(10)
            non_coh_addr = m_mgr0.non_coherent_address();

    endtask: run_test
endclass: iocache_test

class noncoherent_addr_test extends base_test;

    function new(string name = "noncoherent_addr_test");
        super.new(name);
    endfunction: new

    task run_test();
        AddrTransMgr m_mgr0;
        bit [ncoreConfigInfo::ADDR_WIDTH-1:0] non_coh_addr;

        ncoreConfigInfo::construct_unique_memregion_msb_values();
        foreach(ncoreConfigInfo::unique_coherent_window_subprefixes[idx]) begin
            $display("sub_prefix[%0d] = %0d", idx, ncoreConfigInfo::unique_coherent_window_subprefixes[idx]);
        end

        m_mgr0 = AddrTransMgr::GetInstance_AddrTransMgr();
        repeat(10)
            non_coh_addr = m_mgr0.non_coherent_address();

    endtask: run_test
endclass: noncoherent_addr_test


module test();

initial begin
    call_test();
end

task call_test();

    if($test$plusargs("duplicate_address_test")) begin
        duplicate_address_test m_test;

        $display("Calling duplicate_address_test");
        m_test = new("duplicate_address_test");
        m_test.run_test();
    end

    if($test$plusargs("aiu_interleaving")) begin
        aiu_interleaving_test m_test;
  
        $display("Calling aiu_interleaving_test");
        m_test = new("aiu_interleaving_test");
        m_test.run_test();
   end

   if($test$plusargs("memory_prefix_test")) begin
       memory_prefix_test m_test;

       $display("calling memory_prefix_test");
       m_test = new("memory_prefix_test");
       m_test.run_test();
   end

   if($test$plusargs("iocache_test")) begin
       iocache_test m_test;

       $display("calling io-cache test");
       m_test = new("iocache_test");
       m_test.run_test();
   end

   if($test$plusargs("noncoherent_addr_test")) begin
       noncoherent_addr_test m_test;

       $display("call noncoherent_addr test");
       m_test = new("noncoherent_addr_test");
       m_test.run_test();
   end

endtask: call_test


endmodule: test
