

class concerto_apb_debug_test extends concerto_fullsys_test;
   
    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_apb_debug_test)

    //////////////////
    //Methods
    //////////////////
    extern function new(string name = "concerto_apb_debug_test", uvm_component parent = null);
    extern virtual task ncore_test_stimulus(uvm_phase phase);

    extern virtual function void report_phase(uvm_phase phase);
    extern virtual function void print_status();
    extern function void compareValues(string one, string two, int data1, int data2);

endclass: concerto_apb_debug_test


function concerto_apb_debug_test::new(string name = "concerto_apb_debug_test", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

task concerto_apb_debug_test::ncore_test_stimulus(uvm_phase phase);
    uvm_status_e    status;
    bit[31:0]       read_data;
    bit[31:0]       write_data;

    phase.raise_objection(this, "concerto_apb_debug_test");

    #100ns;

   `uvm_info("CONCERTO_APB_DEBUG_TEST", "START ncore_test_stimulus", UVM_LOW)

    phase.phase_done.set_drain_time(this, 100ns);
    <% if(obj.DebugApbInfo.length > 0) { %>

    <% obj.DmiInfo.forEach(function(unit) {%>			
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DMIUFUIDR.FUnitId.read(status,read_data); 
    compareValues("<%=unit.strRtlNamePrefix%>.DMIUFUIDR.FUnitId APB Debug value read","Expected FUnitId value",read_data, 'd<%=unit.FUnitId%>); 
    write_data = 32'hDEAD_0000 | 32'd<%=unit.FUnitId%>;
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DMIUUELR0.write(status,write_data); 
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DMIUUELR0.read(status,read_data); 
    if($test$plusargs("disable_bist")) 
        write_data = m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DMIUUELR0.get_reset();
    compareValues("<%=unit.strRtlNamePrefix%>.DMIUUELR0 APB Debug value read","Expected UELR0 register value",read_data, write_data); 
    <%});%>
    <% obj.DiiInfo.forEach(function(unit) {%>			
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DIIUFUIDR.FUnitId.read(status,read_data); 
    compareValues("<%=unit.strRtlNamePrefix%>.DIIUFUIDR.FUnitId APB Debug value read","Expected FUnitId value",read_data, 'd<%=unit.FUnitId%>); 
    write_data = 32'hFACE_0000 | 32'd<%=unit.FUnitId%>;
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DIIUUELR0.write(status,write_data); 
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DIIUUELR0.read(status,read_data); 
    if($test$plusargs("disable_bist")) 
        write_data = m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DIIUUELR0.get_reset();
    compareValues("<%=unit.strRtlNamePrefix%>.DMIUUELR0 APB Debug value read","Expected UELR0 register value",read_data, write_data); 
    <%});%>
    <% obj.DceInfo.forEach(function(unit) {%>			
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DCEUFUIDR.FUnitId.read(status,read_data); 
    compareValues("<%=unit.strRtlNamePrefix%>.DCEUFUIDR.FUnitId APB Debug value read","Expected FUnitId value",read_data, 'd<%=unit.FUnitId%>); 
    write_data = 32'hDEAD_0000 | 32'd<%=unit.FUnitId%>;
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DCEUUELR0.write(status,write_data); 
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DCEUUELR0.read(status,read_data); 
    if($test$plusargs("disable_bist")) 
        write_data = m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DCEUUELR0.get_reset();
    compareValues("<%=unit.strRtlNamePrefix%>.DMIUUELR0 APB Debug value read","Expected UELR0 register value",read_data, write_data); 
    <%});%>
    <% obj.DveInfo.forEach(function(unit) {%>			
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DVEUFUIDR.FUnitId.read(status,read_data); 
    compareValues("<%=unit.strRtlNamePrefix%>.DVEUFUIDR.FUnitId APB Debug value read","Expected FUnitId value",read_data, 'd<%=unit.FUnitId%>); 
    write_data = 32'hAA55_0000 | 32'd<%=unit.FUnitId%>;
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DVEUUELR0.write(status,write_data); 
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DVEUUELR0.read(status,read_data); 
    if($test$plusargs("disable_bist")) 
        write_data = m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.DVEUUELR0.get_reset();
    compareValues("<%=unit.strRtlNamePrefix%>.DMIUUELR0 APB Debug value read","Expected UELR0 register value",read_data, write_data); 
    <%});%>
    <% obj.AiuInfo.forEach(function(unit) {%>
    <% if ((unit.fnNativeInterface == 'CHI-A')||(unit.fnNativeInterface == 'CHI-B' || unit.fnNativeInterface == 'CHI-E')) {%>
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.CAIUFUIDR.FUnitId.read(status,read_data); 
    compareValues("<%=unit.strRtlNamePrefix%>.CAIUFUIDR.FUnitId APB Debug value read","Expected FUnitId value",read_data, 'd<%=unit.FUnitId%>); 
    <%} else {%>
    <% if (Array.isArray(unit.interfaces.axiInt)) {%>
    <% unit.interfaces.axiInt.forEach(function(core,coreid) {%>
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>_<%=coreid%>.XAIUFUIDR.FUnitId.read(status,read_data);
    compareValues("<%=unit.strRtlNamePrefix%>_<%=coreid%>.XAIUFUIDR.FUnitId APB Debug value read","Expected FUnitId value",read_data, 'd<%=unit.FUnitId%>);
    <%});%>
    <%} else {%>
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.XAIUFUIDR.FUnitId.read(status,read_data);
    compareValues("<%=unit.strRtlNamePrefix%>.XAIUFUIDR.FUnitId APB Debug value read","Expected FUnitId value",read_data, 'd<%=unit.FUnitId%>);
    <%}%>
    <%}%>
    <% if ((unit.fnNativeInterface == 'CHI-A')||(unit.fnNativeInterface == 'CHI-B' || unit.fnNativeInterface == 'CHI-E')) {%>
    write_data = 32'hDEAD_0000 | 32'd<%=unit.FUnitId%>;
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.CAIUUELR0.write(status,write_data);  
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.CAIUUELR0.read(status,read_data);
    if($test$plusargs("disable_bist")) 
        write_data = m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.CAIUUELR0.get_reset();
    compareValues("<%=unit.strRtlNamePrefix%>.CAIUUUELR0 APB Debug value read","Expected UELR0 register value",read_data, write_data); 
    <%} else {%>
    <% if (Array.isArray(unit.interfaces.axiInt)) {%>
    <% unit.interfaces.axiInt.forEach(function(core,coreid) {%>
    write_data = 32'hFACE_0000 | 32'd<%=unit.FUnitId%> | 32'h<%=coreid%>000;
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>_<%=coreid%>.XAIUUELR0.write(status,write_data);  
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>_<%=coreid%>.XAIUUELR0.read(status,read_data);
    if($test$plusargs("disable_bist")) 
        write_data = m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>_<%=coreid%>.XAIUUELR0.get_reset(); 
    compareValues("<%=unit.strRtlNamePrefix%>.XAIUUUELR0 APB Debug value read","Expected UELR0 register value",read_data, write_data); 
    <%});%>
    <%} else {%>
    write_data = 32'hFACE_0000 | 32'd<%=unit.FUnitId%>;
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.XAIUUELR0.write(status,write_data);  
    m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.XAIUUELR0.read(status,read_data);
    if($test$plusargs("disable_bist")) 
        write_data = m_concerto_env.m_regs.<%=unit.strRtlNamePrefix%>.XAIUUELR0.get_reset(); 
    compareValues("<%=unit.strRtlNamePrefix%>.XAIUUUELR0 APB Debug value read","Expected UELR0 register value",read_data, write_data); 
    <%}%>
    <%}%>
    <%});%>
    write_data[15:0]  = <%=obj.AiuInfo[0].implVerId%>;
    write_data[19:16] = <%=obj.DceInfo[0].wCacheLineOffset%> - 5;
    write_data[27:20] = <%=obj.SnoopFilterInfo.length%> - 1;
    write_data = 32'h0FFF_FFFF & write_data;
    m_concerto_env.m_regs.sys_global_register_blk.GRBUNSIDR.read(status,read_data);
    if($test$plusargs("disable_bist")) 
        write_data = m_concerto_env.m_regs.sys_global_register_blk.GRBUNSIDR.get_reset(); 
    compareValues("sys_global_register_blk.GRBUNSIDR APB Debug value read","Expected NSIDR register value",read_data, write_data);
    <% } %>

    exec_inhouse_seq(phase);
    wait_seq_totaly_done(phase);
    ev_sim_done.trigger();

    phase.drop_objection(this, "concerto_apb_debug_test");

   `uvm_info("CONCERTO_APB_DEBUG_TEST", "END ncore_test_stimulus", UVM_LOW)
endtask: ncore_test_stimulus 


function void concerto_apb_debug_test::report_phase(uvm_phase phase);
   print_status();
endfunction : report_phase


function void concerto_apb_debug_test::print_status();
        int error_count, fatal_count;
        uvm_report_server m_urs;

        m_urs = uvm_report_server::get_server();
            `uvm_info("TEST","..Closing file\n", UVM_MEDIUM);
       
        error_count = m_urs.get_severity_count(UVM_ERROR);
        fatal_count = m_urs.get_severity_count(UVM_FATAL);

        if((error_count != 0) | (fatal_count != 0)) begin
            $display("\n===================================================================");
            $display("UVM FAILED!");
            $display("===================================================================");
        end else begin
            $display("\n===================================================================");
            $display("UVM PASSED!");
            $display("===================================================================");
        end
endfunction: print_status


function void concerto_apb_debug_test::compareValues(string one, string two, int data1, int data2);
    if(!($test$plusargs("apb4_csr_nonsecure"))) begin
       if (data1 == data2) begin
           `uvm_info("COMPARE_VALUES",$sformatf("%s:0x%0x, expd %s:0x%0x OKAY", one, data1, two, data2), UVM_LOW)
       end else begin
           `uvm_error("COMPARE_VALUES",$sformatf("Mismatch %s:0x%0x, expd %s:0x%0x",one, data1, two, data2));
       end
    end 
    else begin
       if (data1 != 0) 
         `uvm_error("COMPARE_VALUES - Non Secure access",$sformatf("Mismatch %s:0x%0x, expd %s: 0",one, data1, two));
    end
endfunction // compareValues
  
