

////////////////////////////////////////////////////////////////////////////////
//
//File: sfi_harness.sv
<% if (1 == 0) { %>
// Author: Satya Prakash
<% } %>
//
////////////////////////////////////////////////////////////////////////////////

//File connects internal RTL SFI signals

<%
    //Embedded javascript code to figure out
    // number of blocks
    var _child_m = [];
    var wProtbitsPerAgent = [];
    var removeData = [];
    var resetPorts = [];
    var clockPorts = [];
    var uclk = [];
    var urst = [];
    var wFunit = obj.DmiInfo[0].interfaces.uSysIdInt.params.wFUnitIdV[0];
    // Determine if anyone uses DVMs.
    var someoneUsesDvms = 0;
    var initiatorAgents   = obj.AiuInfo.length ;
    var aiu_NumCores = [];  

    for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
      if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
          aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
      } else {
          aiu_NumCores[pidx]    = 1;
      }
    }
    for(var i = 0; i< obj.AiuInfo.length; i++) {
        //if (obj.AiuInfo[i].cmpInfo.nDvmMsgInFlight) {
        //    someoneUsesDvms = 1;
        //}
        if (obj.AiuInfo[i].cmpInfo.nDvmSnpInFlight) {
            someoneUsesDvms = 1;
        }
    }



    var funitId = [];
    for( var i=0;i<obj.nAIUs;i++) {
      funitId[obj.AiuInfo[i].nUnitId] = obj.AiuInfo[i].FUnitId;
    }

    var portList = function(myObj, retList1, retList2) {

        if(obj.FULL_SYS_TB) {      
            myObj.agentPorts.forEach(function(c) {
                retList1.push(c);
            });

            myObj.dcePorts.forEach(function(c) {
                retList1.push(c);
            });

            myObj.dmiPorts.forEach(function(c) {
                retList1.push(c);
            });

            myObj.uniquePorts.forEach(function(c) {
                retList2.push(c.sig2);
            });
        }
    };

    portList(obj.ClockPorts, clockPorts, uclk);
    portList(obj.ResetPorts, resetPorts, urst);
%>
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var _child_blkSmiIf   = [];
   var pidx = 0;
   var qidx  = 0;
   var sysdii_idx  = 0;
   var idx  = 0;
   var ridx = 0;
   var initiatorAgents = obj.AiuInfo.length ;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + qidx;
       _child_blk[pidx]   = 'ioaiu';
       qidx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
       if(obj.DiiInfo[pidx].configuration){
           sysdii_idx  = pidx;
       }
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
   }
%>

module smi_harness (input logic tb_clk, tb_rstn);
<% if(obj.testBench !="emu") { %>
  import uvm_pkg::*;
  `include "<%=_child_blkid[0]%>_smi_widths.svh"
  static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
  static uvm_event csr_init_done = ev_pool.get("csr_init_done");
  bit conc_csr_init_done;
  // Global Register Block

<% for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
<% if(obj.DmiInfo[pidx].useCmc) { %>
   <%for( var i=0;i<obj.DmiInfo[pidx].ccpParams.nTagBanks;i++){%>
   <% } %>
   <%for( var i=0;i<obj.DmiInfo[pidx].ccpParams.nDataBanks;i++){%>
    static uvm_event         dmi_injectDoubleErrData_<%=pidx%>_<%=i%> = ev_pool.get("dmi_injectDoubleErrData_<%=pidx%>_<%=i%>");
    static uvm_event         dmi_injectSingleErrData_<%=pidx%>_<%=i%> = ev_pool.get("dmi_injectSingleErrData_<%=pidx%>_<%=i%>");
   <% } %>
<% } } %>

<% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
<% if(obj.AiuInfo[pidx].useCache==1 && obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') { %>
   <%for( var i=0;i<obj.AiuInfo[pidx].ccpParams.nDataBanks;i++){%>
    static uvm_event         ioaiu_injectDoubleErrData_<%=pidx%>_<%=i%> = ev_pool.get("ioaiu_injectDoubleErrData_<%=pidx%>_<%=i%>");
    static uvm_event         ioaiu_injectSingleErrData_<%=pidx%>_<%=i%> = ev_pool.get("ioaiu_injectSingleErrData_<%=pidx%>_<%=i%>");
   <% } %>
<% } } %>

<% for(pidx = 0; pidx < obj.nDCEs; pidx++) { 
   for( var i=0;i<obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem.length;i++){
     if( obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem[i].fnMemType == 'SRAM'){ %>
         static uvm_event         dce_injectSingleErrData_<%=pidx%>_<%=i%> = ev_pool.get("dce_injectSingleErrData_<%=pidx%>_<%=i%>");
         static uvm_event         dce_injectDoubleErrData_<%=pidx%>_<%=i%> = ev_pool.get("dce_injectDoubleErrData_<%=pidx%>_<%=i%>");
<% }}} %>
   initial begin
       csr_init_done.wait_trigger();
       conc_csr_init_done = 1;
       `uvm_info("CONC_HARNESS","Saw csr_init_done...", UVM_LOW);   
   end

`ifdef EN_DMI_MEM_ACCESS_TO_INJECT_ERR
<% for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
<% if(obj.DmiInfo[pidx].assertOn) { %>
<% if(obj.DmiInfo[pidx].useCmc) { %>
   <%for( var i=0;i<obj.DmiInfo[pidx].ccpParams.nTagBanks;i++){%>
   <% } %>
   <%for( var i=0;i<obj.DmiInfo[pidx].ccpParams.nDataBanks;i++){%>
    always@(tb_clk) begin
      if(conc_csr_init_done==1 && $test$plusargs("concerto_dmi_cmc_double_bit_error_to_datamem")) begin
        `uvm_info("CONC_HARNESS","Waiting in dmi_injectDoubleErrData_<%=pidx%>_<%=i%>", UVM_DEBUG);   
        dmi_injectDoubleErrData_<%=pidx%>_<%=i%>.wait_ptrigger();
        dmi_injectDoubleErrData_<%=pidx%>_<%=i%>.reset();
        `uvm_info("CONC_HARNESS","Saw dmi_injectDoubleErrData_<%=pidx%>_<%=i%>", UVM_LOW);   
        `DMI<%=pidx%>.<%=obj.DmiInfo[pidx].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
      end
    end

    always@(tb_clk) begin
      if(conc_csr_init_done==1 && $test$plusargs("concerto_dmi_cmc_single_bit_error_to_datamem")) begin
        `uvm_info("CONC_HARNESS","Waiting in dmi_injectSingleErrData_<%=pidx%>_<%=i%>", UVM_DEBUG);   
        dmi_injectSingleErrData_<%=pidx%>_<%=i%>.wait_ptrigger();
        dmi_injectSingleErrData_<%=pidx%>_<%=i%>.reset();
        `uvm_info("CONC_HARNESS","Saw dmi_injectSingleErrData_<%=pidx%>_<%=i%>", UVM_LOW);   
        `DMI<%=pidx%>.<%=obj.DmiInfo[pidx].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
      end
    end
   <% } %>
<% } } } %>
`endif // `ifdef EN_DMI_MEM_ACCESS_TO_INJECT_ERR

`ifdef EN_IOAIU_MEM_ACCESS_TO_INJECT_ERR
<% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
<% if(obj.AiuInfo[pidx].assertOn) { %>
<% if(obj.AiuInfo[pidx].useCache==1 && obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') { %>
   <%for( var i=0;i<obj.AiuInfo[pidx].ccpParams.nDataBanks;i++){%>
   <%if( obj.AiuInfo[pidx].MemoryGeneration.dataMem[i].fnMemType == 'SRAM'){%>
    always@(tb_clk) begin
      if(conc_csr_init_done==1 && $test$plusargs("concerto_ioaiu_cache_double_bit_error_to_datamem")) begin
        `uvm_info("CONC_HARNESS","Waiting in ioaiu_injectDoubleErrData_<%=pidx%>_<%=i%>", UVM_DEBUG);   
        ioaiu_injectDoubleErrData_<%=pidx%>_<%=i%>.wait_ptrigger();
        ioaiu_injectDoubleErrData_<%=pidx%>_<%=i%>.reset();
        `uvm_info("CONC_HARNESS","Saw ioaiu_injectDoubleErrData_<%=pidx%>_<%=i%>", UVM_LOW);   
<%if(obj.AiuInfo[pidx].hierPath && obj.AiuInfo[pidx].hierPath !== ''){%>
        tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.<%=obj.AiuInfo[pidx].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
<% } else {%>
        tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.<%=obj.AiuInfo[pidx].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
<% } %>
      end
    end

    always@(tb_clk) begin
      if(conc_csr_init_done==1 && $test$plusargs("concerto_ioaiu_cache_single_bit_error_to_datamem")) begin
        `uvm_info("CONC_HARNESS","Waiting in ioaiu_injectSingleErrData_<%=pidx%>_<%=i%>", UVM_DEBUG);   
        ioaiu_injectSingleErrData_<%=pidx%>_<%=i%>.wait_ptrigger();
        ioaiu_injectSingleErrData_<%=pidx%>_<%=i%>.reset();
        `uvm_info("CONC_HARNESS","Saw ioaiu_injectSingleErrData_<%=pidx%>_<%=i%>", UVM_LOW);   
<%if(obj.AiuInfo[pidx].hierPath && obj.AiuInfo[pidx].hierPath !== ''){%>
        tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.<%=obj.AiuInfo[pidx].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
<% } else {%>
        tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.<%=obj.AiuInfo[pidx].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
<% } %>
      end
    end
   <% } } %>
<% } } } %>
`endif // `ifdef EN_IOAIU_MEM_ACCESS_TO_INJECT_ERR

`ifdef EN_DCE_MEM_ACCESS_TO_INJECT_ERR
<% for(pidx = 0; pidx < obj.nDCEs; pidx++) { 
   if(obj.DceInfo[pidx].assertOn) {   
   for( var i=0;i<obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem.length;i++){
    if( obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem[i].fnMemType == 'SRAM'){ %>
    always@(tb_clk) begin
      if(conc_csr_init_done==1 && $test$plusargs("concerto_dce_double_bit_error_to_tagmem")) begin
        `uvm_info("CONC_HARNESS","Waiting in dce_injectDoubleErrData_<%=pidx%>_<%=i%>", UVM_DEBUG);   
        dce_injectDoubleErrData_<%=pidx%>_<%=i%>.wait_ptrigger();
        dce_injectDoubleErrData_<%=pidx%>_<%=i%>.reset();
        `uvm_info("CONC_HARNESS","Saw dce_injectDoubleErrData_<%=pidx%>_<%=i%>", UVM_LOW);   
<%if(obj.DceInfo[pidx].hierPath && obj.DceInfo[pidx].hierPath !== ''){%>
        tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
<% } else {%>
        tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
<% } %>
      end
    end

    always@(tb_clk) begin
      if(conc_csr_init_done==1 && $test$plusargs("concerto_dce_single_bit_error_to_tagmem")) begin
        `uvm_info("CONC_HARNESS","Waiting in dce_injectSingleErrData_<%=pidx%>_<%=i%>", UVM_DEBUG);   
        dce_injectSingleErrData_<%=pidx%>_<%=i%>.wait_ptrigger();
        dce_injectSingleErrData_<%=pidx%>_<%=i%>.reset();
        `uvm_info("CONC_HARNESS","Saw dce_injectSingleErrData_<%=pidx%>_<%=i%>", UVM_LOW);   
<%if(obj.DceInfo[pidx].hierPath && obj.DceInfo[pidx].hierPath !== ''){%>
        tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
<% } else {%>
        tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
<% } %>
      end
    end
   <% } %>
<% } } } %>
`endif // `ifdef EN_DCE_MEM_ACCESS_TO_INJECT_ERR

<% for(pidx = 0; pidx < obj.nDMIs; pidx++) {if(obj.DmiInfo[pidx].useCmc) { %>
  uvm_event  ev_inject_error_dmi<%=pidx%>_smc = uvm_event_pool::get_global("inject_error_dmi<%=pidx%>_smc");<%}}%>
   typedef bit [<%=wFunit*obj.nAIUs -1%>:0] aiu_funit_id_t;

    dii<%=sysdii_idx%>_apb_if  u_grb_apb_if( .clk(tb_clk),.rst_n(tb_rstn)); 
	assign u_grb_apb_if.IS_IF_A_MONITOR  = 1;
	assign u_grb_apb_if.paddr   = `GRB.apb_paddr   ;
	assign u_grb_apb_if.pwrite  = `GRB.apb_pwrite  ;
	assign u_grb_apb_if.psel    = `GRB.apb_psel    ;
	assign u_grb_apb_if.penable = `GRB.apb_penable ;
	assign u_grb_apb_if.prdata  = `GRB.apb_prdata  ;
	assign u_grb_apb_if.pwdata  = `GRB.apb_pwdata  ;
	assign u_grb_apb_if.pready  = `GRB.apb_pready  ;
	assign u_grb_apb_if.pslverr = `GRB.apb_pslverr ;

<% for(var pidx = 0,qidx = 0; pidx < initiatorAgents; pidx++) { %>
    <%  if(_child_blk[pidx].match('chiaiu')) { %>
      <% var NSMIIFTX = obj.AiuInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
    <%=_child_blkid[pidx]%>_smi_if    <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].interfaces.clkInt.name%>clk, tb_rstn, "<%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if");
`ifdef CHI_SUBSYS
    <%=_child_blkid[pidx]%>_smi_force_if    <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_force_if(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].interfaces.clkInt.name%>clk, tb_rstn, "<%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_force_if");
 `endif
      <% } %>
      <% var NSMIIFRX = obj.AiuInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
    <%=_child_blkid[pidx]%>_smi_if    <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].interfaces.clkInt.name%>clk, tb_rstn, "<%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if");
`ifdef CHI_SUBSYS
    <%=_child_blkid[pidx]%>_smi_force_if    <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].interfaces.clkInt.name%>clk, tb_rstn, "<%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if");
 `endif
      <% } %>
    dii<%=sysdii_idx%>_apb_if  u_chi_apb_if_<%=qidx%>( .clk(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn)); 
	assign u_chi_apb_if_<%=qidx%>.IS_IF_A_MONITOR  = 1;
    <%for(var i = 0; i < obj.AiuInfo[pidx].nSmiTx; i++) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_valid       = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_valid ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_ready       = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_ready ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_ndp_len         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_ndp_len   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_present      = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_dp_present;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_targ_id         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_targ_id   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_src_id          = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_src_id    ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_id          = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_id    ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_type        = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_type  ;
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_msg_valid       = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_valid ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_msg_ready       = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_ready ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_ndp_len         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_ndp_len   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_dp_present      = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_dp_present;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_targ_id         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_targ_id   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_src_id          = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_src_id    ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_msg_id          = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_id    ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_msg_type        = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_type  ;
 `endif

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_user        = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_user  ; 
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_msg_user        = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_user  ; 
 `endif
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_msg_user        = 'h0                                      ; 
 `endif
<% } %>
<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_tier        = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_tier  ; 
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_msg_tier        = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_tier  ; 
 `endif
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_steer           = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_steer	   ;  
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_steer           = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_steer	   ;  
 `endif
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_pri         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_pri   ;  
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_msg_pri         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_pri   ;  
 `endif
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wQos > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_qos         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_qos   ; 
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_msg_qos         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_qos   ; 
 `endif
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ; 
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_msg_qos         = 'h0                                      ; 
 `endif
<% } %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_ndp             = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_ndp	   ;
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_ndp             = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_ndp	   ;
 `endif

    <%  if (obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_valid        = `AIU<%=pidx%>.smi_tx<%=i%>_dp_valid	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_ready        = `AIU<%=pidx%>.smi_tx<%=i%>_dp_ready	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_last         = `AIU<%=pidx%>.smi_tx<%=i%>_dp_last	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_data         = `AIU<%=pidx%>.smi_tx<%=i%>_dp_data	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_user         = `AIU<%=pidx%>.smi_tx<%=i%>_dp_user	   ;  
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_dp_valid        = `AIU<%=pidx%>.smi_tx<%=i%>_dp_valid	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_dp_ready        = `AIU<%=pidx%>.smi_tx<%=i%>_dp_ready	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_dp_last         = `AIU<%=pidx%>.smi_tx<%=i%>_dp_last	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_dp_data         = `AIU<%=pidx%>.smi_tx<%=i%>_dp_data	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_dp_user         = `AIU<%=pidx%>.smi_tx<%=i%>_dp_user	   ;  
 `endif
    <%  } else {  %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0	      ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0	      ;  
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_dp_valid        = 'b0	      ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_dp_ready        = 'b0	      ;  
 `endif
    <%  }  %>

	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0	      ;  
`ifdef CHI_SUBSYS
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if.smi_msg_err         = 'b0	      ;  
 `endif
    <% } %>

    <%for(var i = 0; i < obj.AiuInfo[pidx].nSmiRx; i++) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_valid       = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_valid ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_ready       = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_ready ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_ndp_len         = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_ndp_len   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_present      = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_dp_present;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_targ_id         = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_targ_id   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_src_id          = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_src_id    ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_id          = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_id    ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_type        = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_type  ;

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_user        = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_user  ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_tier        = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_tier  ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_steer           = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_steer	   ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_pri         = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_pri   ;
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_qos         = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_qos   ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ;
<% } %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_ndp             = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_ndp	   ;

    <%  if (obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_valid        = `AIU<%=pidx%>.smi_rx<%=i%>_dp_valid	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_ready        = `AIU<%=pidx%>.smi_rx<%=i%>_dp_ready	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_last         = `AIU<%=pidx%>.smi_rx<%=i%>_dp_last	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_data         = `AIU<%=pidx%>.smi_rx<%=i%>_dp_data	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_user         = `AIU<%=pidx%>.smi_rx<%=i%>_dp_user	   ;  
    <%  } else {  %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0	      ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0	      ;  
    <%  }  %>

	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0	      ;  
    <% } %>
	assign u_chi_apb_if_<%=qidx%>.paddr   = `AIU<%=pidx%>.apb_paddr   ;
	assign u_chi_apb_if_<%=qidx%>.pwrite  = `AIU<%=pidx%>.apb_pwrite  ;
	assign u_chi_apb_if_<%=qidx%>.psel    = `AIU<%=pidx%>.apb_psel    ;
	assign u_chi_apb_if_<%=qidx%>.penable = `AIU<%=pidx%>.apb_penable ;
	assign u_chi_apb_if_<%=qidx%>.prdata  = `AIU<%=pidx%>.apb_prdata  ;
	assign u_chi_apb_if_<%=qidx%>.pwdata  = `AIU<%=pidx%>.apb_pwdata  ;
	assign u_chi_apb_if_<%=qidx%>.pready  = `AIU<%=pidx%>.apb_pready  ;
	assign u_chi_apb_if_<%=qidx%>.pslverr = `AIU<%=pidx%>.apb_pslverr ;
    <% qidx++; %>
   <% } %>
<% } %>

<% for(var pidx = 0,qidx = 0; pidx < initiatorAgents; pidx++) { %>
    <% if(obj.AiuInfo[pidx].useCache) { %>
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
      bit [<%=obj.AiuInfo[pidx].ccpParams.nWays%>-1:0]  <%=_child_blkid[pidx]%>_<%=i%>_nru_counter;
    <% } %>
    <% } %>
    <%  if(_child_blk[pidx].match('ioaiu')) { %>
      <% var NSMIIFTX = obj.AiuInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
    <%=_child_blkid[pidx]%>_smi_if    <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].interfaces.clkInt.name%>clk, tb_rstn, "<%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if");
      <% } %>
      <% var NSMIIFRX = obj.AiuInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
    <%=_child_blkid[pidx]%>_smi_if    <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].interfaces.clkInt.name%>clk, tb_rstn, "<%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if");
      <% } %>
    <% if(obj.AiuInfo[pidx].useCache) { %>
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
      <%=_child_blkid[pidx]%>_ccp_if  u_ioaiu_ccp_if_<%=qidx%>_<%=i%>( .clk(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn)); 
    <% } //foreach interfacePorts%>
    <% } //if useCache%>
     <%=_child_blkid[pidx]%>_apb_if  u_ioaiu_apb_if_<%=qidx%>( .clk(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn));
    dii<%=sysdii_idx%>_apb_if  u_sysdii_ioaiu_apb_if_<%=qidx%>( .clk(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn)); 

    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
    <%=_child_blkid[pidx]%>_axi_cmdreq_id_if u_axi_cmdreq_id_if<%=qidx%>_<%=i%>(.clk(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].interfaces.clkInt.name%>clk), .rst_n(tb_rstn));
    assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.w_pt_id           = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_id;
    assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.n_mrc0_mid        = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.n_mrc0_mid;
    assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.valid             = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.n_mrc0_valid & `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_valid;
    //CMD REQ
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_req_valid     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_valid;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_req_ready     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_ready;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_req_msg_type  = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_req_msg_id    = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_message_id;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_req_target_id = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_target_id;
    //CMD RSP
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_rsp_valid     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_valid;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_rsp_ready     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_ready;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_rsp_msg_type  = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_cm_type;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_rsp_r_msg_id  = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_r_message_id;
    <% } //foreach interfacePorts%>

					      
    <%for(var i = 0; i < obj.AiuInfo[pidx].nSmiTx; i++) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_valid       = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_valid ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_ready       = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_ready ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_ndp_len         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_ndp_len   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_present      = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_dp_present;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_targ_id         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_targ_id   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_src_id          = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_src_id	   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_id          = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_id    ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_type        = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_type  ;

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_user        = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_user  ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_tier        = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_tier  ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_steer           = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_steer	   ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_pri         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_pri   ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_qos         = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_msg_qos   ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_ndp             = `AIU<%=pidx%>.smi_tx<%=i%>_ndp_ndp	   ;

    <%  if (obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_valid        = `AIU<%=pidx%>.smi_tx<%=i%>_dp_valid	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_ready        = `AIU<%=pidx%>.smi_tx<%=i%>_dp_ready	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_last         = `AIU<%=pidx%>.smi_tx<%=i%>_dp_last	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_data         = `AIU<%=pidx%>.smi_tx<%=i%>_dp_data	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_user         = `AIU<%=pidx%>.smi_tx<%=i%>_dp_user	   ;  
    <%  } else {  %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0	      ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0	      ;  
    <%  }  %>

	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0	      ;  
    <% } %>
    
    <%for(var i = 0; i < obj.AiuInfo[pidx].nSmiRx; i++) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_valid       = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_valid ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_ready       = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_ready ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_ndp_len         = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_ndp_len   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_present      = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_dp_present;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_targ_id         = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_targ_id   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_src_id          = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_src_id	   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_id          = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_id    ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_type        = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_type  ;

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_user        = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_user  ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ;
<% } %>	    
<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_tier        = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_tier  ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_steer           = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_steer	   ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_pri         = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_pri   ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_qos         = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_msg_qos   ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_ndp             = `AIU<%=pidx%>.smi_rx<%=i%>_ndp_ndp	   ;

    <%  if (obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_valid        = `AIU<%=pidx%>.smi_rx<%=i%>_dp_valid	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_ready        = `AIU<%=pidx%>.smi_rx<%=i%>_dp_ready	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_last         = `AIU<%=pidx%>.smi_rx<%=i%>_dp_last	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_data         = `AIU<%=pidx%>.smi_rx<%=i%>_dp_data	   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_user         = `AIU<%=pidx%>.smi_rx<%=i%>_dp_user	   ;  
    <%  } else {  %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0	      ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0	      ;  
    <%  }  %>

	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0	      ;  
    <% } %>


    <% if(obj.AiuInfo[pidx].useCache) { %>
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>

//CTRL channel
        assign <%=_child_blkid[pidx]%>_<%=i%>_ccp_clk                    = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.clk;
        assign <%=_child_blkid[pidx]%>_<%=i%>_ccp_rstn                   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.reset_n;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>_nru_counter      = <%=_child_blkid[pidx]%>_<%=i%>_nru_counter;
        //Free Running Counter to mimic Eviction Counter in IO Cache.
        always @ (posedge <%=_child_blkid[pidx]%>_<%=i%>_ccp_clk or negedge <%=_child_blkid[pidx]%>_<%=i%>_ccp_rstn)
        begin
            if(~<%=_child_blkid[pidx]%>_<%=i%>_ccp_rstn) begin
                <%=_child_blkid[pidx]%>_<%=i%>_nru_counter <= '0;
            end else begin
                if(<%=_child_blkid[pidx]%>_<%=i%>_nru_counter<(<%=obj.AiuInfo[pidx].ccpParams.nWays%>-1)) 
                    <%=_child_blkid[pidx]%>_<%=i%>_nru_counter <= <%=_child_blkid[pidx]%>_<%=i%>_nru_counter+1'b1;
                else 
                    <%=_child_blkid[pidx]%>_<%=i%>_nru_counter <= '0;
            end
        end
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_vld           = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_valid_p0           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_addr          = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_address_p0         ;
        <% if (obj.wSecurityAttribute > 0) { %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_security      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_security_p0        ;
        <%}else{%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_security      = 0              ;
        <%}%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_allocate      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_allocate_p2        ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_rd_data       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_read_data_p2       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_wr_data       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_write_data_p2      ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_port_sel      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_port_sel_p2        ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_bypass        = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_bypass_p2          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_rp_update     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_rp_update_p2       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_tagstateup    = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_tag_state_update_p2;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_state         = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_state_p2           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_burstln       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_burst_len_p2       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_burstwrap     = 0                                                           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_setway_debug  = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_setway_debug_p2    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_waybusy_vec   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_ways_busy_vec_p2   ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_waystale_vec  = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_ways_stale_vec_p2  ;
	assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_cancel        = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_c2_cancel;
	assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.t_pt_err             = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_pt_err;
	assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_lookup_p2     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_c2_lookup;
	assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_pt_id_p2      = (u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isWrite_Wakeup ||
                                                                u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isRead_Wakeup  ||
                                                                u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isWrite        ||
                                                                u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isRead          ) ? `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_id :
                                                                {`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_st_iid[`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_kid],`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_st_mid[`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_kid]}; 

        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cacheop_rdy          = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_op_ready_p0          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_vld            = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_valid_p2             ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.out_req_valid_p2     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_valid_p2             ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_currentstate   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_current_state_p2     ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_set_index      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_set_index_p2     ;
         <%if ((obj.AiuInfo[pidx].ccpParams.RepPolicy != "RANDOM") && (obj.AiuInfo[pidx].ccpParams.nWays>1)) {%>
               assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_current_nru_vec = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_current_nru_vec_p2           ;
         <%}%>

        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_alloc_wayn     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_alloc_way_vec_p2     ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_hit_wayn       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_hit_way_vec_p2       ;

        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cachectrl_evict_vld  = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_valid_p2       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_addr     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_address_p2     ;

        <% if (obj.wSecurityAttribute > 0) { %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_security = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_security_p2    ;
        <%}else{%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_security = 0                                                           ;
        <%}%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_state    = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_state_p2       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_nack_uce       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_nack_uce_p2          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_nack           = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_nack_p2              ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_nack_ce        = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_nack_ce_p2           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_nack_noalloc   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_nack_no_allocate_p2  ;

//Fill CTRL Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_vld        = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_valid            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_fill_rdy       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_fill_ready           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_addr       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_address          ;

        <% if(obj.AiuInfo[pidx].ccpParams.nWays>1) { %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_wayn       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_way_num          ;
        <% }else{ %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_wayn       = 0                                                           ;
        <%}%>

        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_state      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_state            ;

        <% if (obj.wSecurityAttribute > 0) { %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_security   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_security         ;
        <%}else{%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_security   = 0                                                           ;
        <%}%>

 //Fill Data Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_vld    = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_valid       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_scratchpad = 0       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_data       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data             ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_id     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_id          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_last   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_last        ;

        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_byten  = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_byteen      ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_addr   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_address     ;


        <% if(obj.AiuInfo[pidx].ccpParams.nWays>1) { %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_wayn   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_way_num     ;
        <% }else{ %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_wayn   = 0                                                           ;
        <%}%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_beatn  = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_beat_num    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_filldata_rdy   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_fill_data_ready      ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_fill_done      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_fill_done            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_fill_done_id   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_fill_done_id         ;

//WR Data Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_wr_vld          = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_wr_valid              ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_wr_data         = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_wr_data               ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_wr_byte_en      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_wr_byte_en            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_wr_beat_num     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_wr_beat_num           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_wr_last         = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_wr_last               ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_wr_rdy         = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_wr_ready             ;

//Evict Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_rdy      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_ready          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_vld      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_valid          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_data     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_data           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_byten    = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_byteen         ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_last     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_last           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_cancel   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_cancel         ;

//Read response Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_rdy      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_ready          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_vld      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_valid          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_data     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_data           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_byten    = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_byteen         ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_last     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_last           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_cancel   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_cancel         ;

//Mnt Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_opcode     = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_opcode           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_data       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_data             ; // Was commented in IOAIU tb top
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_way        = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_way              ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_entry      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_entry            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_word       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_word             ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_array_sel  = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_array_sel        ; // was not present in IOAIU tb top

        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_active         = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_active               ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_read_data      = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_read_data            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_read_data_en   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_read_data_en         ;

//Serialization Signal
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isRead               = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid  &&
					                      ~`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_snp&&
					                      ~`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_wake   &&
				                              ~`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isWrite              = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid  &&
                                                              ~`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_wake   &&
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isSnoop              = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid  &
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_snp         ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isMntOp              = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_maint;  // tb_top.dut.ncaiu0.ioaiu_core_wrapper.ioaiu_core0.ccp_maint;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isRead_Wakeup        = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid  &&
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_wake   &&
                                                              ~`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isWrite_Wakeup       = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid  &&
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_wake   &&
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.read_hit             = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid   &
                                                              ~`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write   &
                                                              ~`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_snp &
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_c2_chit            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.read_miss_allocate   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid   &
                                                              ~`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write   &
                                                              ~`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_snp &
                                                              ~`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_c2_chit    &
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.cp2_alloc_o          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.write_hit            = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid   &
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write   &
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_c2_chit            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.write_miss_allocate  = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid   &
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write   &
                                                           (~| `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.cp2_hits_i)  &
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.cp2_alloc_o          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.snoop_hit            = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid   &
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_snp &
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_c2_chit            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.write_hit_upgrade    = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid   &
                                                               `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write   &
                                                            (| `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.cp2_hits_i)  &
                                                           (~& `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_c2_state)          ;
                  
        // Assign zero to unused signals
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_vld         = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_data        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_byten       = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_last        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_rdy         = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_cancel      = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_vld            = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_data           = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_byte_en        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_beat_num       = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_last           = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_rdy            = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_rdy            = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_vld            = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_wr_data        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_rd_data        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_index_addr     = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_data_bank      = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_way_num        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_beat_num       = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_burst_len      = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_burst_type     = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_retry         = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.fake_hit_way         = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_wrdata         = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isRead_p1            = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isWrite_p1           = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isSnoop_p1           = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isMntOp_p1           = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isRead_Wakeup_p1     = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isWrite_Wakeup_p1    = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isSnoop_Wakeup_p1    = 0 ;
        //int unsigned current_index;
        //int unsigned prev_index;
        logic  stale_vec_detected<%=pidx%>_<%=i%>;

        always @ (posedge <%=_child_blkid[pidx]%>_<%=i%>_ccp_clk or negedge <%=_child_blkid[pidx]%>_<%=i%>_ccp_rstn)
            if(~<%=_child_blkid[pidx]%>_<%=i%>_ccp_rstn) begin 
                stale_vec_detected<%=pidx%>_<%=i%> <= '0;
            end else begin
                if(`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_valid_p2 && `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_nack_uce_p2) begin
                    stale_vec_detected<%=pidx%>_<%=i%> <= 1'b1; 
                end else begin
                    stale_vec_detected<%=pidx%>_<%=i%> <= 1'b0;
                end
            end
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.stale_vec_flag       = stale_vec_detected<%=pidx%>_<%=i%> & (|`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.u_ccp.u_tagpipe.way_alloc_residue);
     
  <% } // foreach interfacePorts %>
       
 <% } // if useCache %>

    assign u_ioaiu_apb_if_<%=qidx%>.IS_IF_A_MONITOR=1;
	assign u_ioaiu_apb_if_<%=qidx%>.paddr   = `AIU<%=pidx%>.apb_paddr   ;
	assign u_ioaiu_apb_if_<%=qidx%>.pwrite  = `AIU<%=pidx%>.apb_pwrite  ;
	assign u_ioaiu_apb_if_<%=qidx%>.psel    = `AIU<%=pidx%>.apb_psel    ;
	assign u_ioaiu_apb_if_<%=qidx%>.penable = `AIU<%=pidx%>.apb_penable ;
	assign u_ioaiu_apb_if_<%=qidx%>.prdata  = `AIU<%=pidx%>.apb_prdata  ;
	assign u_ioaiu_apb_if_<%=qidx%>.pwdata  = `AIU<%=pidx%>.apb_pwdata  ;
	assign u_ioaiu_apb_if_<%=qidx%>.pready  = `AIU<%=pidx%>.apb_pready  ;
	assign u_ioaiu_apb_if_<%=qidx%>.pslverr = `AIU<%=pidx%>.apb_pslverr ;
	
    assign u_sysdii_ioaiu_apb_if_<%=qidx%>.IS_IF_A_MONITOR =1; 
    assign u_sysdii_ioaiu_apb_if_<%=qidx%>.paddr   = `AIU<%=pidx%>.apb_paddr   ;
    assign u_sysdii_ioaiu_apb_if_<%=qidx%>.pwrite  = `AIU<%=pidx%>.apb_pwrite  ;
	assign u_sysdii_ioaiu_apb_if_<%=qidx%>.psel    = `AIU<%=pidx%>.apb_psel    ;
	assign u_sysdii_ioaiu_apb_if_<%=qidx%>.penable = `AIU<%=pidx%>.apb_penable ;
	assign u_sysdii_ioaiu_apb_if_<%=qidx%>.prdata  = `AIU<%=pidx%>.apb_prdata  ;
	assign u_sysdii_ioaiu_apb_if_<%=qidx%>.pwdata  = `AIU<%=pidx%>.apb_pwdata  ;
	assign u_sysdii_ioaiu_apb_if_<%=qidx%>.pready  = `AIU<%=pidx%>.apb_pready  ;
	assign u_sysdii_ioaiu_apb_if_<%=qidx%>.pslverr = `AIU<%=pidx%>.apb_pslverr ;
    <% qidx++; %>
   <% } %>
<% } %>

<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
     <% if(obj.DmiInfo[pidx].useCmc) { %>
      bit [<%=obj.DmiInfo[pidx].ccpParams.nWays%>-1:0]  dmi<%=pidx%>_nru_counter;
      <% if(obj.DmiInfo[pidx].useWayPartitioning) { %>
         aiu_funit_id_t   dmi<%=pidx%>_aiu_funit_id;
      <% }  %>
     <% } %>

       dmi<%=pidx%>_rtl_if  u_dmi<%=pidx%>_rtl_if(.clk(`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn));

       dmi<%=pidx%>_tt_if   u_dmi<%=pidx%>_tt_if(.clk(`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn));

       dmi<%=pidx%>_read_probe_if   u_dmi<%=pidx%>_read_probe_if(.clk(`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn));

       dmi<%=pidx%>_write_probe_if  u_dmi<%=pidx%>_write_probe_if(.clk(`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn));

  <%if (obj.DmiInfo[pidx].fnEnableQos) { %>
      assign  u_dmi<%=pidx%>_rtl_if.cmd_starv_mode       =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.cmd_skid_buffer.starv_mode; 
      assign  u_dmi<%=pidx%>_rtl_if.mrd_starv_mode       =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.mrd_skid_buffer.starv_mode; 
  <% } %>

     <% var NSMIIFTX = obj.DmiInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
       dmi<%=pidx%>_smi_if    dmi<%=pidx%>_port<%=i%>_tx_smi_if(`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].interfaces.clkInt.name%>clk,tb_rstn, "dmi<%=pidx%>_port<%=i%>_tx_smi_if");
     
     <% } %>
     <% var NSMIIFRX = obj.DmiInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
       dmi<%=pidx%>_smi_if    dmi<%=pidx%>_port<%=i%>_rx_smi_if(`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].interfaces.clkInt.name%>clk,tb_rstn, "dmi<%=pidx%>_port<%=i%>_rx_smi_if");
     <% } %>
     <% if(obj.DmiInfo[pidx].useCmc) { %>
       dmi<%=pidx%>_ccp_if  u_ccp_if_<%=pidx%>( .clk(`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn)); 
       dmi<%=pidx%>_apb_if   u_apb_if_<%=pidx%>( .clk(`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn));
       assign u_apb_if_<%=pidx%>.IS_IF_A_MONITOR=1;
     <% } %>
       dii<%=sysdii_idx%>_apb_if   u_dmi_apb_if_<%=pidx%>( .clk(`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn)); 


    <%for(var i = 0; i < obj.DmiInfo[pidx].nSmiTx; i++) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_valid       = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_valid	;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_ready       = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_ready	;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp_len         = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_ndp_len	;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_present      = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_dp_present;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_targ_id         = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_targ_id	;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_src_id          = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_src_id	;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_id          = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_id	;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_type        = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_type	;

<% if(obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_user	; 
<% } else { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_tier        = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_tier	;  
<% } %>

<% if(obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_steer           = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_steer	;  
<% } %>

<% if(obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_pri         = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_pri	;  
<% } %>

<% if(obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_qos	;
<% } else { %>
        assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ;
<% } %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp             = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_ndp	;

    <%  if (obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = `DMI<%=pidx%>.smi_tx<%=i%>_dp_valid	;  
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = `DMI<%=pidx%>.smi_tx<%=i%>_dp_ready	;  
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_last         = `DMI<%=pidx%>.smi_tx<%=i%>_dp_last	;  
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_data         = `DMI<%=pidx%>.smi_tx<%=i%>_dp_data	;  
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_user         = `DMI<%=pidx%>.smi_tx<%=i%>_dp_user	;  
    <%  } else {  %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0      ;  
    <%  }  %>

	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>
    
    <%for(var i = 0; i < obj.DmiInfo[pidx].nSmiRx; i++) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_valid       = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_valid ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_ready       = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_ready ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp_len         = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_ndp_len   ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_present      = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_dp_present;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_targ_id         = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_targ_id   ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_src_id          = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_src_id    ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_id          = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_id    ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_type        = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_type  ;

<% if(obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_user  ; 
<% } else { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_tier        = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_tier  ;  
<% } %>

<% if(obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_steer           = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_steer     ;
<% } %>

<% if(obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_pri         = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_pri   ;
<% } %>

<% if(obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_qos   ; 
<% } else { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp             = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_ndp       ;

    <%  if (obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = `DMI<%=pidx%>.smi_rx<%=i%>_dp_valid	;  
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = `DMI<%=pidx%>.smi_rx<%=i%>_dp_ready	;  
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_last         = `DMI<%=pidx%>.smi_rx<%=i%>_dp_last	;  
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_data         = `DMI<%=pidx%>.smi_rx<%=i%>_dp_data	;  
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_user         = `DMI<%=pidx%>.smi_rx<%=i%>_dp_user	;  
    <%  } else {  %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0      ;  
    <%  }  %>

	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>

<% if(obj.DmiInfo[pidx].useCmc) { %>
        //CTRL channel
        assign dmi<%=pidx%>_ccp_clk                    = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.clk;
        assign dmi<%=pidx%>_ccp_rstn                   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.reset_n;
        assign u_ccp_if_<%=pidx%>.ctrlop_vld           = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_valid_p0;
        assign u_ccp_if_<%=pidx%>.ctrlop_addr          = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_address_p0;
<% if(obj.wSecurityAttribute) { %>
        assign u_ccp_if_<%=pidx%>.ctrlop_security      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_security_p0        ;
<% } else { %>
        assign u_ccp_if_<%=pidx%>.ctrlop_security      = 0  ;
<% } %>
        assign u_ccp_if_<%=pidx%>.ctrlop_allocate      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_allocate_p2        ;
        assign u_ccp_if_<%=pidx%>.ctrlop_rd_data       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_read_data_p2       ;
        assign u_ccp_if_<%=pidx%>.ctrlop_wr_data       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_write_data_p2      ;
        assign u_ccp_if_<%=pidx%>.ctrlop_port_sel      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_port_sel_p2        ;
        assign u_ccp_if_<%=pidx%>.ctrlop_bypass        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_bypass_p2          ;
        assign u_ccp_if_<%=pidx%>.ctrlop_rp_update     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_rp_update_p2       ;
        assign u_ccp_if_<%=pidx%>.ctrlop_tagstateup    = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_tag_state_update_p2;
        assign u_ccp_if_<%=pidx%>.ctrlop_state         = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_state_p2           ;
        assign u_ccp_if_<%=pidx%>.ctrlop_burstln       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_burst_len_p2       ;
        assign u_ccp_if_<%=pidx%>.ctrlop_burstwrap     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_burst_wrap_p2      ;
        assign u_ccp_if_<%=pidx%>.ctrlop_setway_debug  = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_setway_debug_p2    ;
        assign u_ccp_if_<%=pidx%>.ctrlop_waybusy_vec   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_ways_busy_vec_p2   ;
        assign u_ccp_if_<%=pidx%>.ctrlop_waystale_vec  = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_ways_stale_vec_p2  ;


        assign u_ccp_if_<%=pidx%>.cacheop_rdy          = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_op_ready_p0          ;
        assign u_ccp_if_<%=pidx%>.cache_vld            = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_valid_p2             ;
        assign u_ccp_if_<%=pidx%>.cache_currentstate   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_current_state_p2     ;
     <% if(obj.DmiInfo[pidx].ccpParams.nWays>1) { %>
        assign u_ccp_if_<%=pidx%>.cache_alloc_wayn     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_alloc_way_vec_p2 ;
        assign u_ccp_if_<%=pidx%>.cache_hit_wayn       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_hit_way_vec_p2 ;
     <% } %>
        assign u_ccp_if_<%=pidx%>.cachectrl_evict_vld  = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_valid_p2       ;
        assign u_ccp_if_<%=pidx%>.cache_evict_addr     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_address_p2     ;
<% if(obj.wSecurityAttribute) { %>
        assign u_ccp_if_<%=pidx%>.cache_evict_security = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_security_p2    ;
<% } else { %>
        assign u_ccp_if_<%=pidx%>.cache_evict_security = 0  ;
<% } %>
        assign u_ccp_if_<%=pidx%>.cache_evict_state    = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_state_p2       ;
        assign u_ccp_if_<%=pidx%>.cache_nack_uce       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_nack_uce_p2          ;
        assign u_ccp_if_<%=pidx%>.cache_nack           = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_nack_p2              ;
        assign u_ccp_if_<%=pidx%>.cache_nack_ce        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_nack_ce_p2           ;
        assign u_ccp_if_<%=pidx%>.cache_nack_noalloc   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_nack_no_allocate_p2  ;

//Fill CTRL Channel
        assign u_ccp_if_<%=pidx%>.ctrl_fill_vld        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_valid            ;
        assign u_ccp_if_<%=pidx%>.ctrl_fill_addr       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_address          ;
     <% if(obj.DmiInfo[pidx].ccpParams.nWays>1) { %>
        assign u_ccp_if_<%=pidx%>.ctrl_fill_wayn       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_way_num          ;
     <% } %>
        assign u_ccp_if_<%=pidx%>.ctrl_fill_state      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_state            ;
<% if(obj.wSecurityAttribute) { %>
        assign u_ccp_if_<%=pidx%>.ctrl_fill_security   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_security         ;
<% } else { %>
        assign u_ccp_if_<%=pidx%>.ctrl_fill_security   = 0 ;
<% } %>
//Fill Data Channel
        assign u_ccp_if_<%=pidx%>.ctrl_filldata_vld    = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_valid       ;
        <% if (obj.DmiInfo[pidx].useCmc && obj.DmiInfo[pidx].ccpParams.useScratchpad && obj.DmiInfo[pidx].useAtomic) { %>
        assign u_ccp_if_<%=pidx%>.ctrl_filldata_scratchpad = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_scratchpad   ;
        <% } else { %>
        assign u_ccp_if_<%=pidx%>.ctrl_filldata_scratchpad = 0;
        <% } %>
        assign u_ccp_if_<%=pidx%>.ctrl_fill_data       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data             ;
        assign u_ccp_if_<%=pidx%>.ctrl_filldata_id     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_id          ;
        assign u_ccp_if_<%=pidx%>.ctrl_filldata_addr   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_address     ;
     <% if(obj.DmiInfo[pidx].ccpParams.nWays>1) { %>
        assign u_ccp_if_<%=pidx%>.ctrl_filldata_wayn   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_way_num     ;
     <% } %>
        assign u_ccp_if_<%=pidx%>.ctrl_filldata_beatn  = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_beat_num    ;
        assign u_ccp_if_<%=pidx%>.ctrl_filldata_byten  = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_byteen      ;
        assign u_ccp_if_<%=pidx%>.ctrl_filldata_last   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_last        ;
        assign u_ccp_if_<%=pidx%>.cache_filldata_rdy   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_fill_data_ready      ;
        assign u_ccp_if_<%=pidx%>.cache_fill_rdy       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_fill_ready           ;
        assign u_ccp_if_<%=pidx%>.cache_fill_done      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_fill_done            ;
        assign u_ccp_if_<%=pidx%>.cache_fill_done_id   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_fill_done_id         ;

//WR Data Channel
        assign u_ccp_if_<%=pidx%>.ctrl_wr_vld          = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_wr_valid              ;
        assign u_ccp_if_<%=pidx%>.ctrl_wr_data         = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_wr_data               ;
        assign u_ccp_if_<%=pidx%>.ctrl_wr_byte_en      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_wr_byte_en            ;
        assign u_ccp_if_<%=pidx%>.ctrl_wr_beat_num     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_wr_beat_num           ;
        assign u_ccp_if_<%=pidx%>.ctrl_wr_last         = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_wr_last               ;
        assign u_ccp_if_<%=pidx%>.cache_wr_rdy         = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_wr_ready             ;

//Evict Channel
        assign u_ccp_if_<%=pidx%>.cache_evict_rdy      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_ready          ;
        assign u_ccp_if_<%=pidx%>.cache_evict_vld      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_valid          ;
        assign u_ccp_if_<%=pidx%>.cache_evict_data     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_data           ;
        assign u_ccp_if_<%=pidx%>.cache_evict_byten    = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_byteen         ;
        assign u_ccp_if_<%=pidx%>.cache_evict_last     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_last           ;
        assign u_ccp_if_<%=pidx%>.cache_evict_cancel   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_cancel         ;

//Read response Channel
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_rdy      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_ready          ;
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_vld      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_valid          ;
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_data     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_data           ;
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_byten    = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_byteen         ;
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_last     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_last           ;
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_cancel   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_cancel         ;
//Mnt Channel
        assign u_ccp_if_<%=pidx%>.maint_req_opcode     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_opcode           ;
        assign u_ccp_if_<%=pidx%>.maint_wrdata         = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_data             ;
     <% if(obj.DmiInfo[pidx].ccpParams.nWays>1) { %>
        assign u_ccp_if_<%=pidx%>.maint_req_way        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_way              ;
     <% } %>
        assign u_ccp_if_<%=pidx%>.maint_req_entry      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_entry            ;
        assign u_ccp_if_<%=pidx%>.maint_req_word       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_word             ;
        assign u_ccp_if_<%=pidx%>.maint_req_array_sel  = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_array_sel        ;

        assign u_ccp_if_<%=pidx%>.maint_active         = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_active               ;
        assign u_ccp_if_<%=pidx%>.maint_read_data      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_read_data            ;
        assign u_ccp_if_<%=pidx%>.maint_read_data_en   = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_read_data_en         ;
        assign u_ccp_if_<%=pidx%>.isReplay             = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.replay_queue.ccp_p1_is_replay    ;
        assign u_ccp_if_<%=pidx%>.toReplay             = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.replay_queue.ccp_p1_to_replay    ;
        assign u_ccp_if_<%=pidx%>.isRecycle            = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.recycle_valid;
        assign u_ccp_if_<%=pidx%>.msgType_p2           = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.ccp_p2_cm_type   ;
        assign u_ccp_if_<%=pidx%>.msgType_p0           = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.ccp_p0_cm_type   ;
        assign u_ccp_if_<%=pidx%>.msgType_p1           = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.ccp_p1_cm_type   ;
        assign u_ccp_if_<%=pidx%>.isCoh_p0             = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.ccp_p0_write_nc_sel;
        assign u_ccp_if_<%=pidx%>.isMntOp              = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.ccp_p2_mnt;
        assign u_ccp_if_<%=pidx%>.isRply_vld_p0        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.replay_valid;
        assign u_ccp_if_<%=pidx%>.flush_fail_p2        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_mnt_op_ctrl_unit.flush_fail_p2;

// ScratchPad signals
<% if (obj.DmiInfo[pidx].ccpParams.useScratchpad) { %>
        assign u_ccp_if_<%=pidx%>.sp_rdrsp_vld         = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_valid        ;
        assign u_ccp_if_<%=pidx%>.sp_rdrsp_data        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_data         ;
        assign u_ccp_if_<%=pidx%>.sp_rdrsp_byten       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_byteen       ;
        assign u_ccp_if_<%=pidx%>.sp_rdrsp_last        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_last         ;
        assign u_ccp_if_<%=pidx%>.sp_rdrsp_rdy         = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_ready        ;
        assign u_ccp_if_<%=pidx%>.sp_rdrsp_cancel      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_cancel       ;
        
        assign u_ccp_if_<%=pidx%>.sp_wr_vld            = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_valid           ;
        assign u_ccp_if_<%=pidx%>.sp_wr_data           = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_data            ;
        assign u_ccp_if_<%=pidx%>.sp_wr_byte_en        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_byte_en         ;
        assign u_ccp_if_<%=pidx%>.sp_wr_beat_num       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_beat_num        ;
        assign u_ccp_if_<%=pidx%>.sp_wr_last           = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_last            ;
        assign u_ccp_if_<%=pidx%>.sp_wr_rdy            = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_ready           ;
        
        assign u_ccp_if_<%=pidx%>.sp_op_rdy            = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_ready           ;
        assign u_ccp_if_<%=pidx%>.sp_op_vld            = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_valid           ;
        assign u_ccp_if_<%=pidx%>.sp_op_wr_data        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_write_data      ;
        assign u_ccp_if_<%=pidx%>.sp_op_rd_data        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_read_data       ;
        assign u_ccp_if_<%=pidx%>.sp_op_index_addr     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_index_addr      ;
        assign u_ccp_if_<%=pidx%>.sp_op_way_num        = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_way_num         ;
        assign u_ccp_if_<%=pidx%>.sp_op_beat_num       = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_beat_num        ;
        assign u_ccp_if_<%=pidx%>.sp_op_burst_len      = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_burst_len       ;
        assign u_ccp_if_<%=pidx%>.sp_op_burst_type     = `DMI<%=pidx%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_burst_wrap      ;
<% } %>

       assign u_ccp_if_<%=pidx%>.nru_counter = dmi<%=pidx%>_nru_counter;
       
       always @ (posedge dmi<%=pidx%>_ccp_clk or negedge dmi<%=pidx%>_ccp_rstn)
       begin
           if(~dmi<%=pidx%>_ccp_rstn) begin
               dmi<%=pidx%>_nru_counter <= '0;
           end else begin
               if(dmi<%=pidx%>_nru_counter<(<%=obj.DmiInfo[pidx].ccpParams.nWays%>-1)) 
                   dmi<%=pidx%>_nru_counter <= dmi<%=pidx%>_nru_counter+1'b1;
               else 
                   dmi<%=pidx%>_nru_counter <= '0;
           end
       end
<% } %>

    assign u_dmi_apb_if_<%=pidx%>.IS_IF_A_MONITOR=1; 
	assign u_dmi_apb_if_<%=pidx%>.paddr   = `DMI<%=pidx%>.apb_paddr   ;
	assign u_dmi_apb_if_<%=pidx%>.pwrite  = `DMI<%=pidx%>.apb_pwrite  ;
	assign u_dmi_apb_if_<%=pidx%>.psel    = `DMI<%=pidx%>.apb_psel    ;
	assign u_dmi_apb_if_<%=pidx%>.penable = `DMI<%=pidx%>.apb_penable ;
	assign u_dmi_apb_if_<%=pidx%>.prdata  = `DMI<%=pidx%>.apb_prdata  ;
	assign u_dmi_apb_if_<%=pidx%>.pwdata  = `DMI<%=pidx%>.apb_pwdata  ;
	assign u_dmi_apb_if_<%=pidx%>.pready  = `DMI<%=pidx%>.apb_pready  ;
	assign u_dmi_apb_if_<%=pidx%>.pslverr = `DMI<%=pidx%>.apb_pslverr ;

      assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_valid   =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_cmd_resp_buffer_push_valid; 
      assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_ready   =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_cmd_resp_buffer_push_ready; 
      assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_rmsg_id =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_cmd_resp_buffer_push_r_message_id[<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0];
      assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_targ_id =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_cmd_resp_buffer_push_target_id[<%=obj.DmiInfo[pidx].wFUnitId+obj.DmiInfo[pidx].wFPortId-1%>:<%=obj.DmiInfo[pidx].wFPortId%>];

      assign  u_dmi<%=pidx%>_rtl_if.mrd_pop_valid        =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_valid; 
      assign  u_dmi<%=pidx%>_rtl_if.mrd_pop_ready        =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_ready; 
      assign  u_dmi<%=pidx%>_rtl_if.mrd_pop_msg_id       =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_message_id[<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0];
      assign  u_dmi<%=pidx%>_rtl_if.mrd_pop_initiator_id =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_initiator_id[<%=obj.DmiInfo[pidx].wFUnitId+obj.DmiInfo[pidx].wFPortId-1%>:<%=obj.DmiInfo[pidx].wFPortId%>];
      assign  u_dmi<%=pidx%>_rtl_if.mrd_pop_addr         =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_addr; 
      assign  u_dmi<%=pidx%>_rtl_if.mrd_pop_ns           =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_ns; 

      assign u_dmi<%=pidx%>_tt_if.read_alloc_valid              = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.rtt.alloc_valid; 
      assign u_dmi<%=pidx%>_tt_if.read_alloc_ready              = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.rtt.alloc_ready; 
      assign u_dmi<%=pidx%>_tt_if.read_alloc_addr               = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.rtt.alloc_addr;
      assign u_dmi<%=pidx%>_tt_if.read_alloc_ns                 = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.rtt.alloc_ns;
      assign u_dmi<%=pidx%>_tt_if.read_alloc_msg_id             = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.rtt.alloc_aiu_trans_id[<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0];
      assign u_dmi<%=pidx%>_tt_if.read_alloc_aiu_unit_id        = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.rtt.alloc_aiu_id[<%=obj.DmiInfo[pidx].wFUnitId+obj.DmiInfo[pidx].wFPortId-1%>:<%=obj.DmiInfo[pidx].wFPortId%>];
      assign u_dmi<%=pidx%>_tt_if.read_alloc_msg_type           = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.rtt.alloc_cm_type;
      assign u_dmi<%=pidx%>_tt_if.read_tt_dealloc_vld           = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.rtt.dealloc_valid;
                          
// Timing fix moved error qualifier inside of the WTT block. Thus need to qualify here if cache is present. 

      assign u_dmi<%=pidx%>_tt_if.write_alloc_valid             = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.wtt.write_alloc_valid;
      assign u_dmi<%=pidx%>_tt_if.write_alloc_ready             = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.wtt.write_alloc_ready;
      assign u_dmi<%=pidx%>_tt_if.write_alloc_addr              = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.wtt.write_alloc_addr;
      assign u_dmi<%=pidx%>_tt_if.write_alloc_ns                = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.wtt.write_alloc_ns;
      assign u_dmi<%=pidx%>_tt_if.write_alloc_msg_id            = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.wtt.write_alloc_aiu_trans_id[<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0];
      assign u_dmi<%=pidx%>_tt_if.write_alloc_aiu_unit_id       = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.wtt.write_alloc_aiu_id[<%=obj.DmiInfo[pidx].wFUnitId+obj.DmiInfo[pidx].wFPortId-1%>:<%=obj.DmiInfo[pidx].wFPortId%>];
      assign u_dmi<%=pidx%>_tt_if.write_alloc_msg_type          = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.wtt.write_alloc_cm_type;
      assign u_dmi<%=pidx%>_tt_if.write_tt_dealloc_vld          = `DMI<%=pidx%>.dmi_unit.dmi_transaction_control.wtt.dealloc_valid;

      assign u_dmi<%=pidx%>_read_probe_if.nc_read_valid        = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_valid;
      assign u_dmi<%=pidx%>_read_probe_if.nc_read_ready        = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_ready;
      assign u_dmi<%=pidx%>_read_probe_if.nc_read_addr         = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_addr;
      assign u_dmi<%=pidx%>_read_probe_if.nc_read_cm_type      = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_cm_type;
      assign u_dmi<%=pidx%>_read_probe_if.nc_read_aiu_trans_id = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_aiu_trans_id;
      assign u_dmi<%=pidx%>_read_probe_if.nc_read_aiu_id       = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_aiu_id;
      assign u_dmi<%=pidx%>_read_probe_if.nc_read_ns           = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_ns;
      
      assign u_dmi<%=pidx%>_read_probe_if.coh_read_valid       = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_valid;
      assign u_dmi<%=pidx%>_read_probe_if.coh_read_ready       = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_ready;
      assign u_dmi<%=pidx%>_read_probe_if.coh_read_addr        = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_addr;
      assign u_dmi<%=pidx%>_read_probe_if.coh_read_cm_type     = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_cm_type;
      assign u_dmi<%=pidx%>_read_probe_if.coh_read_aiu_trans_id= `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_aiu_trans_id;
      assign u_dmi<%=pidx%>_read_probe_if.coh_read_aiu_id      = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_aiu_id;
      assign u_dmi<%=pidx%>_read_probe_if.coh_read_ns          = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_ns;
      
      assign u_dmi<%=pidx%>_write_probe_if.nc_write_valid        = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_write_prot_valid;
      assign u_dmi<%=pidx%>_write_probe_if.nc_write_ready        = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_write_prot_ready;
      assign u_dmi<%=pidx%>_write_probe_if.nc_write_addr         = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_write_prot_addr;
      assign u_dmi<%=pidx%>_write_probe_if.nc_write_cm_type      = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_write_prot_cm_type;
      assign u_dmi<%=pidx%>_write_probe_if.nc_write_aiu_trans_id = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_write_prot_aiu_trans_id;
      assign u_dmi<%=pidx%>_write_probe_if.nc_write_aiu_id       = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_write_prot_aiu_id;
      assign u_dmi<%=pidx%>_write_probe_if.nc_write_ns           = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_write_prot_ns;
      
      assign u_dmi<%=pidx%>_write_probe_if.coh_write_valid       = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_valid;
      assign u_dmi<%=pidx%>_write_probe_if.coh_write_ready       = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_ready;
      assign u_dmi<%=pidx%>_write_probe_if.coh_write_addr        = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_addr;
      assign u_dmi<%=pidx%>_write_probe_if.coh_write_cm_type     = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_cm_type;
      assign u_dmi<%=pidx%>_write_probe_if.coh_write_aiu_trans_id= `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_aiu_trans_id;
      assign u_dmi<%=pidx%>_write_probe_if.coh_write_aiu_id      = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_aiu_id;
      assign u_dmi<%=pidx%>_write_probe_if.coh_write_ns          = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_ns;
      assign u_dmi<%=pidx%>_write_probe_if.dtw_aiu_src_id        = `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.write_data_initiator_id;
<% } %>

<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
     <% var NSMIIFTX = obj.DceInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
       dce<%=pidx%>_smi_if    dce<%=pidx%>_port<%=i%>_tx_smi_if(`DCE<%=pidx%>.<%=obj.DceInfo[pidx].interfaces.clkInt.name%>clk,tb_rstn, "dce<%=pidx%>_port<%=i%>_tx_smi_if");
     <% } %>
     <% var NSMIIFRX = obj.DceInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
       dce<%=pidx%>_smi_if    dce<%=pidx%>_port<%=i%>_rx_smi_if(`DCE<%=pidx%>.<%=obj.DceInfo[pidx].interfaces.clkInt.name%>clk,tb_rstn, "dce<%=pidx%>_port<%=i%>_rx_smi_if");
     <% } %>
       dii<%=sysdii_idx%>_apb_if   u_dce_apb_if_<%=pidx%>( .clk(`DCE<%=pidx%>.<%=obj.DceInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn)); 
       assign u_dce_apb_if_<%=pidx%>.IS_IF_A_MONITOR=1; 

    <%for(var i = 0; i < obj.DceInfo[pidx].nSmiTx; i++) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_valid       = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_valid	;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_ready       = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_ready	;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp_len         = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_ndp_len	;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_present      = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_dp_present;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_targ_id         = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_targ_id	;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_src_id          = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_src_id	;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_id          = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_id	;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_type        = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_type	;

<% if(obj.DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_user	; 
<% } else { %>
    	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_tier        = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_tier	;  
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_steer           = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_steer	;  
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_pri         = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_pri	;  
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_qos	; 
<% } else { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp             = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_ndp	;

	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0      ;  

	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>
    
    <%for(var i = 0; i < obj.DceInfo[pidx].nSmiRx; i++) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_valid       = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_valid ;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_ready       = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_ready ;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp_len         = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_ndp_len   ;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_present      = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_dp_present;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_targ_id         = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_targ_id   ;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_src_id          = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_src_id    ;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_id          = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_id    ;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_type        = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_type  ;

<% if(obj.DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_user  ; 
<% } else { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_tier        = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_tier  ;  
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_steer           = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_steer     ;
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_pri         = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_pri   ;
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_qos   ; 
<% } else { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp             = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_ndp       ;

	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0      ;  

	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>

	assign u_dce_apb_if_<%=pidx%>.paddr   = `DCE<%=pidx%>.apb_paddr   ;
	assign u_dce_apb_if_<%=pidx%>.pwrite  = `DCE<%=pidx%>.apb_pwrite  ;
	assign u_dce_apb_if_<%=pidx%>.psel    = `DCE<%=pidx%>.apb_psel    ;
	assign u_dce_apb_if_<%=pidx%>.penable = `DCE<%=pidx%>.apb_penable ;
	assign u_dce_apb_if_<%=pidx%>.prdata  = `DCE<%=pidx%>.apb_prdata  ;
	assign u_dce_apb_if_<%=pidx%>.pwdata  = `DCE<%=pidx%>.apb_pwdata  ;
	assign u_dce_apb_if_<%=pidx%>.pready  = `DCE<%=pidx%>.apb_pready  ;
	assign u_dce_apb_if_<%=pidx%>.pslverr = `DCE<%=pidx%>.apb_pslverr ;
<% } %>

<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
     <% if (obj.DiiInfo[pidx].configuration == 1) { %>  					       
      dii<%=pidx%>_axi_if      m_dii<%=pidx%>_axi_slv_if(`DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.clkInt.name%>clk, tb_rstn);
      dii<%=pidx%>_dii_rtl_if  m_dii_rtl_if<%=pidx%>(`DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.clkInt.name%>clk, tb_rstn);
     <% }%>
     <% var NSMIIFTX = obj.DiiInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
      dii<%=pidx%>_smi_if    dii<%=pidx%>_port<%=i%>_tx_smi_if(`DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.clkInt.name%>clk, tb_rstn, "dii<%=pidx%>_port<%=i%>_tx_smi_if");
     <% } %>
     <% var NSMIIFRX = obj.DiiInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
       dii<%=pidx%>_smi_if   dii<%=pidx%>_port<%=i%>_rx_smi_if(`DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.clkInt.name%>clk, tb_rstn, "dii<%=pidx%>_port<%=i%>_rx_smi_if");
     <% } %>
       dii<%=sysdii_idx%>_apb_if   u_dii_apb_if_<%=pidx%>( .clk(`DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn)); 
       assign u_dii_apb_if_<%=pidx%>.IS_IF_A_MONITOR=1;

     <% if (obj.DiiInfo[pidx].configuration == 1) { %>  					       
               assign m_dii<%=pidx%>_axi_slv_if.awready    = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_ready     ;
               assign m_dii<%=pidx%>_axi_slv_if.awvalid    = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_valid     ;
               assign m_dii<%=pidx%>_axi_slv_if.awid       = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_id        ;
               assign m_dii<%=pidx%>_axi_slv_if.awaddr     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_addr      ;
               assign m_dii<%=pidx%>_axi_slv_if.awburst    = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_burst     ;
               assign m_dii<%=pidx%>_axi_slv_if.awlen      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_len       ;
               assign m_dii<%=pidx%>_axi_slv_if.awlock     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_lock      ;
               assign m_dii<%=pidx%>_axi_slv_if.awprot     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_prot      ;
               assign m_dii<%=pidx%>_axi_slv_if.awsize     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_size      ;
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wQos > 0) { %>        
               assign m_dii<%=pidx%>_axi_slv_if.awqos      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_qos       ;
<%     } %>
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wRegion > 0) { %>
               assign m_dii<%=pidx%>_axi_slv_if.awregion   = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_region    ;
<%     } %>
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wAwUser > 0) { %>
               assign m_dii<%=pidx%>_axi_slv_if.awuser     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_user      ;
<%     } else { %>
               assign m_dii<%=pidx%>_axi_slv_if.awuser     = 'h0                            ;
<%     } %>
               assign m_dii<%=pidx%>_axi_slv_if.awcache    = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>aw_cache     ;
               assign m_dii<%=pidx%>_axi_slv_if.wready     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>w_ready      ;
               assign m_dii<%=pidx%>_axi_slv_if.wvalid     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>w_valid      ;
               assign m_dii<%=pidx%>_axi_slv_if.wdata      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>w_data       ;
               assign m_dii<%=pidx%>_axi_slv_if.wlast      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>w_last       ;
               assign m_dii<%=pidx%>_axi_slv_if.wstrb      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>w_strb       ;
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wWUser > 0) { %>
               assign m_dii<%=pidx%>_axi_slv_if.wuser      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>w_user       ;
<%     } else { %>
               assign m_dii<%=pidx%>_axi_slv_if.wuser      = 'h0                            ;
<%     } %>
               assign m_dii<%=pidx%>_axi_slv_if.bready     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>b_ready      ;
               assign m_dii<%=pidx%>_axi_slv_if.bvalid     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>b_valid      ;
               assign m_dii<%=pidx%>_axi_slv_if.bid        = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>b_id         ;
               assign m_dii<%=pidx%>_axi_slv_if.bresp      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>b_resp       ;
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wBUser > 0) { %>
               assign m_dii<%=pidx%>_axi_slv_if.buser      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>b_user       ;
<%     } else { %>
               assign m_dii<%=pidx%>_axi_slv_if.buser      = 'h0                            ;
<%     } %>
               assign m_dii<%=pidx%>_axi_slv_if.arready    = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_ready     ;
               assign m_dii<%=pidx%>_axi_slv_if.arvalid    = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_valid     ;
               assign m_dii<%=pidx%>_axi_slv_if.araddr     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_addr      ;
               assign m_dii<%=pidx%>_axi_slv_if.arburst    = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_burst     ;
               assign m_dii<%=pidx%>_axi_slv_if.arid       = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_id        ;
               assign m_dii<%=pidx%>_axi_slv_if.arlen      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_len       ;
               assign m_dii<%=pidx%>_axi_slv_if.arlock     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_lock      ;
               assign m_dii<%=pidx%>_axi_slv_if.arprot     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_prot      ;
               assign m_dii<%=pidx%>_axi_slv_if.arsize     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_size      ;
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wQos) { %>        
               assign m_dii<%=pidx%>_axi_slv_if.arqos      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_qos       ;
<%     } %>
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wRegion) { %>
               assign m_dii<%=pidx%>_axi_slv_if.arregion   = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_region    ;
<%     } %>
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wArUser > 0) {%>
               assign m_dii<%=pidx%>_axi_slv_if.aruser     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_user      ;
<%     } else { %>
               assign m_dii<%=pidx%>_axi_slv_if.aruser     = 'h0                            ;
<%     } %>
               assign m_dii<%=pidx%>_axi_slv_if.arcache    = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>ar_cache     ;
               assign m_dii<%=pidx%>_axi_slv_if.rready     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>r_ready      ;
               assign m_dii<%=pidx%>_axi_slv_if.rid        = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>r_id         ;
               assign m_dii<%=pidx%>_axi_slv_if.rresp      = {2'b0,`DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>r_resp};
               assign m_dii<%=pidx%>_axi_slv_if.rvalid     = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>r_valid      ;
               assign m_dii<%=pidx%>_axi_slv_if.rdata      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>r_data       ;
               assign m_dii<%=pidx%>_axi_slv_if.rlast      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>r_last       ;
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wRUser > 0) {%>
               assign m_dii<%=pidx%>_axi_slv_if.ruser      = `DII<%=pidx%>.<%=obj.DiiInfo[pidx].interfaces.axiInt.name%>r_user       ;
<%     } else { %>
               assign m_dii<%=pidx%>_axi_slv_if.ruser      = 'h0                            ;
<%     } %>
               
<%  }%>

    <%for(var i = 0; i < obj.DiiInfo[pidx].nSmiTx; i++) { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_valid       = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_valid	;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_ready       = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_ready	;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp_len         = `DII<%=pidx%>.smi_tx<%=i%>_ndp_ndp_len	;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_present      = `DII<%=pidx%>.smi_tx<%=i%>_ndp_dp_present;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_targ_id         = `DII<%=pidx%>.smi_tx<%=i%>_ndp_targ_id	;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_src_id          = `DII<%=pidx%>.smi_tx<%=i%>_ndp_src_id	;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_id          = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_id	;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_type        = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_type	;

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_user	; 
<% } else { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_tier        = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_tier	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_steer           = `DII<%=pidx%>.smi_tx<%=i%>_ndp_steer	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_pri         = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_pri	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_qos	; 
<% } else { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp             = `DII<%=pidx%>.smi_tx<%=i%>_ndp_ndp	;
    <%  if (obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = `DII<%=pidx%>.smi_tx<%=i%>_dp_valid	;  
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = `DII<%=pidx%>.smi_tx<%=i%>_dp_ready	;  
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_last         = `DII<%=pidx%>.smi_tx<%=i%>_dp_last	;  
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_data         = `DII<%=pidx%>.smi_tx<%=i%>_dp_data	;  
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_user         = `DII<%=pidx%>.smi_tx<%=i%>_dp_user	;  
    <%  } else {  %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0      ;  
    <%  }  %>

	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>

    <%for(var i = 0; i < obj.DiiInfo[pidx].nSmiRx; i++) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_valid       = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_valid	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_ready       = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_ready	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp_len         = `DII<%=pidx%>.smi_rx<%=i%>_ndp_ndp_len	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_present      = `DII<%=pidx%>.smi_rx<%=i%>_ndp_dp_present;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_targ_id         = `DII<%=pidx%>.smi_rx<%=i%>_ndp_targ_id	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_src_id          = `DII<%=pidx%>.smi_rx<%=i%>_ndp_src_id	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_id          = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_id	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_type        = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_type	;

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_user	; 
<% } else { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_tier        = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_tier	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_steer           = `DII<%=pidx%>.smi_rx<%=i%>_ndp_steer	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_pri         = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_pri	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_qos	; 
<% } else { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp             = `DII<%=pidx%>.smi_rx<%=i%>_ndp_ndp	;

    <%  if (obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = `DII<%=pidx%>.smi_rx<%=i%>_dp_valid	;  
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = `DII<%=pidx%>.smi_rx<%=i%>_dp_ready	;  
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_last         = `DII<%=pidx%>.smi_rx<%=i%>_dp_last	;  
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_data         = `DII<%=pidx%>.smi_rx<%=i%>_dp_data	;  
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_user         = `DII<%=pidx%>.smi_rx<%=i%>_dp_user	;  
    <%  } else {  %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0      ;  
    <%  }  %>

	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>

	assign u_dii_apb_if_<%=pidx%>.paddr   = `DII<%=pidx%>.apb_paddr   ;
	assign u_dii_apb_if_<%=pidx%>.pwrite  = `DII<%=pidx%>.apb_pwrite  ;
	assign u_dii_apb_if_<%=pidx%>.psel    = `DII<%=pidx%>.apb_psel    ;
	assign u_dii_apb_if_<%=pidx%>.penable = `DII<%=pidx%>.apb_penable ;
	assign u_dii_apb_if_<%=pidx%>.prdata  = `DII<%=pidx%>.apb_prdata  ;
	assign u_dii_apb_if_<%=pidx%>.pwdata  = `DII<%=pidx%>.apb_pwdata  ;
	assign u_dii_apb_if_<%=pidx%>.pready  = `DII<%=pidx%>.apb_pready  ;
	assign u_dii_apb_if_<%=pidx%>.pslverr = `DII<%=pidx%>.apb_pslverr ;
<% } %>

<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
     <% var NSMIIFTX = obj.DveInfo[pidx].nSmiRx;%>
     <% for (var i = 0; i < NSMIIFTX; i++) { %>
       dve<%=pidx%>_smi_if    dve<%=pidx%>_port<%=i%>_tx_smi_if(`DVE<%=pidx%>.<%=obj.DveInfo[pidx].interfaces.clkInt.name%>clk,tb_rstn, "dve<%=pidx%>_port<%=i%>_tx_smi_if");
     
     <% } %>
     <% var NSMIIFRX = obj.DveInfo[pidx].nSmiTx;%>
     <% for (var i = 0; i < NSMIIFRX; i++) { %>
       dve<%=pidx%>_smi_if    dve<%=pidx%>_port<%=i%>_rx_smi_if(`DVE<%=pidx%>.<%=obj.DveInfo[pidx].interfaces.clkInt.name%>clk,tb_rstn, "dve<%=pidx%>_port<%=i%>_rx_smi_if");
     <% } %>
       dii<%=sysdii_idx%>_apb_if   u_dve_apb_if_<%=pidx%>( .clk(`DVE<%=pidx%>.<%=obj.DveInfo[pidx].interfaces.clkInt.name%>clk),.rst_n(tb_rstn)); 
       assign u_dve_apb_if_<%=pidx%>.IS_IF_A_MONITOR=1; 

    <%for(var i = 0; i < obj.DveInfo[pidx].nSmiTx; i++) { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_valid       = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_msg_valid	;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_ready       = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_msg_ready	;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp_len         = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_ndp_len	;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_present      = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_dp_present;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_targ_id         = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_targ_id	;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_src_id          = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_src_id	;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_id          = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_msg_id	;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_type        = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_msg_type	;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp             = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_ndp	;

<% if(obj.DveInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_msg_user	; 
<% } else { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_steer           = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_steer	;  
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_tier        = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_msg_tier	;  
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_pri         = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_msg_pri	;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_msg_qos	; 
<% } else { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0      ;  

	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>

    <%for(var i = 0; i < obj.DveInfo[pidx].nSmiRx; i++) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_valid       = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_msg_valid ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_ready       = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_msg_ready ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp_len         = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_ndp_len   ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_present      = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_dp_present;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_targ_id         = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_targ_id   ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_src_id          = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_src_id    ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_id          = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_msg_id    ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_type        = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_msg_type  ;
<% if(obj.DveInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_msg_user  ; 
<% } else { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_tier        = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_msg_tier  ;  
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_steer           = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_steer     ;
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_pri         = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_msg_pri   ;
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_msg_qos   ; 
<% } else { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp             = `DVE<%=pidx%>.smi_rx<%=i%>_ndp_ndp       ;

    <%  if (obj.DveInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = `DVE<%=pidx%>.smi_rx<%=i%>_dp_valid	;  
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = `DVE<%=pidx%>.smi_rx<%=i%>_dp_ready	;  
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_last         = `DVE<%=pidx%>.smi_rx<%=i%>_dp_last	;  
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_data         = `DVE<%=pidx%>.smi_rx<%=i%>_dp_data	;  
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_user         = `DVE<%=pidx%>.smi_rx<%=i%>_dp_user	;  
    <%  } else {  %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0      ;  
    <%  }  %>

	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>

	assign m_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_clock_counter_if.probe_sig1 = `DVE<%=pidx%>.unit.u_protman.csr_DvmSnoopDisable_ff;

	assign u_dve_apb_if_<%=pidx%>.paddr   = `DVE<%=pidx%>.apb_paddr   ;
	assign u_dve_apb_if_<%=pidx%>.pwrite  = `DVE<%=pidx%>.apb_pwrite  ;
	assign u_dve_apb_if_<%=pidx%>.psel    = `DVE<%=pidx%>.apb_psel    ;
	assign u_dve_apb_if_<%=pidx%>.penable = `DVE<%=pidx%>.apb_penable ;
	assign u_dve_apb_if_<%=pidx%>.prdata  = `DVE<%=pidx%>.apb_prdata  ;
	assign u_dve_apb_if_<%=pidx%>.pwdata  = `DVE<%=pidx%>.apb_pwdata  ;
	assign u_dve_apb_if_<%=pidx%>.pready  = `DVE<%=pidx%>.apb_pready  ;
	assign u_dve_apb_if_<%=pidx%>.pslverr = `DVE<%=pidx%>.apb_pslverr ;
<% } %>

initial
  begin
         uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_grb_apb_if", u_grb_apb_if);
<% var chiidx=0;
   var ioidx=0;
   for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
   <%  if(_child_blk[pidx].match('chiaiu')) { %>
      <% var NSMIIFTX = obj.AiuInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_<%=_child_blkid[pidx]%>_smi<%=i%>_tx_port_if" ),
                                            .value(<%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if));
`ifdef CHI_SUBSYS
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_smi_force_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_<%=_child_blkid[pidx]%>_smi<%=i%>_tx_port_if" ),
                                            .value(<%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_force_if));
 `endif
     <% } %>
      <% var NSMIIFRX = obj.AiuInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                            .field_name( "m_<%=_child_blkid[pidx]%>_smi<%=i%>_rx_port_if" ),
                                             .value(<%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if));
`ifdef CHI_SUBSYS
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_smi_force_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                            .field_name( "m_<%=_child_blkid[pidx]%>_smi<%=i%>_rx_port_if" ),
                                             .value(<%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_force_if));
 `endif
     <% } %>
         uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_<%=_child_blkid[pidx]%>_apb_if", u_chi_apb_if_<%=chiidx%>);
     <% chiidx++; %>
   <%} else  if(_child_blk[pidx].match('ioaiu')) { %>
      <% var NSMIIFTX = obj.AiuInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_<%=_child_blkid[pidx]%>_smi<%=i%>_tx_port_if" ),
                                            .value(<%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if));
     <% } %>
      <% var NSMIIFRX = obj.AiuInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                            .field_name( "m_<%=_child_blkid[pidx]%>_smi<%=i%>_rx_port_if" ),
                                             .value(<%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if));
     <% } %>
     <% if(obj.AiuInfo[pidx].useCache) { %>
        <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_ccp_if)::set(uvm_root::get(), "", "m_<%=_child_blkid[pidx]%>_ccp_if_<%=i%>", u_ioaiu_ccp_if_<%=ioidx%>_<%=i%>);
        <% } %>
     <% } %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_apb_if)::set(uvm_root::get(), "", "m_<%=_child_blkid[pidx]%>_apb_if", u_ioaiu_apb_if_<%=ioidx%>);
         uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_<%=_child_blkid[pidx]%>_apb_if", u_sysdii_ioaiu_apb_if_<%=ioidx%>);
        <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_axi_cmdreq_id_if)::set(uvm_root::get(), "", "<%=_child_blkid[pidx]%>_axi_cmdreq_id_if_<%=i%>", u_axi_cmdreq_id_if<%=ioidx%>_<%=i%>);
     <% } %>
						   
     <% ioidx++; %>						       
   <% } %>
<% } %>
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
     <% var NSMIIFTX = obj.DmiInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual dmi<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dmi<%=pidx%>_smi<%=i%>_tx_port_if" ),
                                             .value(dmi<%=pidx%>_port<%=i%>_tx_smi_if));
     <% } %>
     <% var NSMIIFRX = obj.DmiInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual dmi<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dmi<%=pidx%>_smi<%=i%>_rx_port_if" ),
                                             .value(dmi<%=pidx%>_port<%=i%>_rx_smi_if));
     <% } %>
  <% if(obj.DmiInfo[pidx].useCmc) { %>
      uvm_config_db#(virtual dmi<%=pidx%>_ccp_if)::set(uvm_root::get(), "", "m_dmi<%=pidx%>_ccp_if", u_ccp_if_<%=pidx%>);
      uvm_config_db#(virtual dmi<%=pidx%>_apb_if)::set(uvm_root::get(), "", "m_dmi<%=pidx%>_apb_if", u_apb_if_<%=pidx%>);
      <% if(obj.DmiInfo[pidx].useWayPartitioning) { %>
      <% for (var iidx = 0; iidx < obj.nAIUs; iidx++) { %>
      dmi<%=pidx%>_aiu_funit_id[<%=(iidx+1)*obj.DmiInfo[pidx].interfaces.uSysIdInt.params.wFUnitIdV[0]-1%>:<%=iidx*obj.DmiInfo[pidx].interfaces.uSysIdInt.params.wFUnitIdV[0]%>] = <%=funitId[iidx]%>;
      <% } %>
      uvm_config_db#(aiu_funit_id_t)::set(uvm_root::get(), "uvm_test_top.m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb", "aiu_funit_id", dmi<%=pidx%>_aiu_funit_id);
      <%}%>
  <% } %>
      uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_dmi<%=pidx%>_apb_if", u_dmi_apb_if_<%=pidx%>);

      uvm_config_db#(virtual dmi<%=pidx%>_rtl_if)::set(uvm_root::get(), "", "m_dmi<%=pidx%>_rtl_if", u_dmi<%=pidx%>_rtl_if);
 
      uvm_config_db#(virtual dmi<%=pidx%>_tt_if)::set(uvm_root::get(), "", "m_dmi<%=pidx%>_tt_if", u_dmi<%=pidx%>_tt_if);

      uvm_config_db#(virtual dmi<%=pidx%>_read_probe_if)::set(uvm_root::get(), "", "m_dmi<%=pidx%>_read_probe_if", u_dmi<%=pidx%>_read_probe_if);

      uvm_config_db#(virtual dmi<%=pidx%>_write_probe_if)::set(uvm_root::get(), "", "m_dmi<%=pidx%>_write_probe_if", u_dmi<%=pidx%>_write_probe_if);
<% } %>
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
     <% if (obj.DiiInfo[pidx].configuration == 1) { %>  					       
         uvm_config_db #(virtual dii<%=pidx%>_axi_if)::set(uvm_root::get(), "", "m_dii<%=pidx%>_axi_slv_if", m_dii<%=pidx%>_axi_slv_if);
         uvm_config_db #(virtual dii<%=pidx%>_dii_rtl_if)::set(uvm_root::get(), "", "m_dii<%=pidx%>_rtl_if", m_dii_rtl_if<%=pidx%>);
     <% } %>
     <% var NSMIIFTX = obj.DiiInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual dii<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dii<%=pidx%>_smi<%=i%>_tx_port_if" ),
                                             .value(dii<%=pidx%>_port<%=i%>_tx_smi_if));
     <% } %>
     <% var NSMIIFRX = obj.DiiInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual dii<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dii<%=pidx%>_smi<%=i%>_rx_port_if" ),
                                             .value(dii<%=pidx%>_port<%=i%>_rx_smi_if));
     <% } %>
      uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_dii<%=pidx%>_apb_if", u_dii_apb_if_<%=pidx%>);
<% } %>
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
     <% var NSMIIFTX = obj.DceInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual dce<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dce<%=pidx%>_smi<%=i%>_tx_port_if" ),
                                             .value(dce<%=pidx%>_port<%=i%>_tx_smi_if));
     <% } %>
     <% var NSMIIFRX = obj.DceInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual dce<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dce<%=pidx%>_smi<%=i%>_rx_port_if" ),
                                             .value(dce<%=pidx%>_port<%=i%>_rx_smi_if));
     <% } %>
      uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_dce<%=pidx%>_apb_if", u_dce_apb_if_<%=pidx%>);
<% } %>
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
     <% var NSMIIFTX = obj.DveInfo[pidx].nSmiRx;%>
     <% for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual dve<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dve<%=pidx%>_smi<%=i%>_tx_port_if" ),
                                             .value(dve<%=pidx%>_port<%=i%>_tx_smi_if));
     <% } %>
     <% var NSMIIFRX = obj.DveInfo[pidx].nSmiTx; %>
     <% for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual dve<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dve<%=pidx%>_smi<%=i%>_rx_port_if" ),
                                             .value(dve<%=pidx%>_port<%=i%>_rx_smi_if));
     <% } %>
      uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_dve<%=pidx%>_apb_if", u_dve_apb_if_<%=pidx%>);
<% } %>

  end
<% for(pidx = 0; pidx < obj.nDMIs; pidx++) {if((obj.DmiInfo[pidx].useCmc) && (obj.DmiInfo[pidx].useWayPartitioning)) { %>
  initial begin 
     @(posedge tb_clk);
     assert(dmi<%=pidx%>_aiu_funit_id == `DMI<%=pidx%>.<%=obj.DmiInfo[pidx].interfaces.uSysIdInt.name%>f_unit_id)
     else `uvm_error("CONCERTO HARNESS",$sformatf("DMI<%=pidx%> receives <%=obj.DmiInfo[pidx].interfaces.uSysIdInt.name%>f_unit_id:0x%0h, should be :0x%0h",`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].interfaces.uSysIdInt.name%>f_unit_id,dmi<%=pidx%>_aiu_funit_id))
  end
<% } }%>

`ifndef CHI_SUBSYS
 // Inject (uncorrectable error) in DMI SMC for tempo testing
 <% for(pidx = 0; pidx < obj.nDMIs; pidx++) {if(obj.DmiInfo[pidx].useCmc) { %>
   always @(posedge tb_clk) begin 
      `uvm_info("CONC_HARNESS","Waiting in ev_inject_error_dmi<%=pidx%>_smc", UVM_MEDIUM);   
      ev_inject_error_dmi<%=pidx%>_smc.wait_ptrigger();
      ev_inject_error_dmi<%=pidx%>_smc.reset();
      `uvm_info("CONC_HARNESS","Saw wait in ev_inject_error_dmi<%=pidx%>_smc", UVM_MEDIUM);   
      <%if(obj.assertOn) {%>
      <%if(obj.DmiInfo[pidx].MemoryGeneration.dataMem.MemType == "NONE") { %>
      <%for(var i=0; i < obj.DmiInfo[pidx].ccpParams.nDataBanks; i++) {%>
      <%if(obj.DmiInfo[pidx].ccpParams.DataErrInfo == "SECDED") {%>
         `uvm_info("CONC_HARNESS","Injecting double error in DMI SCM dataMem", UVM_LOW);   
         `DMI<%=pidx%>.<%=obj.DmiInfo[pidx].MemoryGeneration.dataMem.rtlPrefixString%><%=i%>.internal_mem_inst.inject_double_error();
      <%} else { %>
         `uvm_info("CONC_HARNESS","Injecting single error in DMI SCM dataMem", UVM_LOW);   
         `DMI<%=pidx%>.<%=obj.DmiInfo[pidx].MemoryGeneration.dataMem.rtlPrefixString%><%=i%>.internal_mem_inst.inject_single_error();
      <%}}}}%>
   end
 <% } }%>
 `endif
//==================================================
//  Correctable Error injection
//==================================================
<%if(obj.assertOn) {%>
<%for(pidx = 0; pidx < obj.nDMIs; pidx++) { 
if(obj.DmiInfo[pidx].useCmc){
if(obj.DmiInfo[pidx].fnErrDetectCorrect == "SECDED"){ 
if(obj.DmiInfo[pidx].MemoryGeneration.dataMem.MemType == "NONE") {
for(var i=0; i < obj.DmiInfo[pidx].ccpParams.nDataBanks; i++) {%>
  initial
     if($test$plusargs("inject_correctable_error") && $test$plusargs("error_test"))
        forever begin
           @(posedge tb_clk);
           wait(`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].MemoryGeneration.dataMem.rtlPrefixString%><%=i%>.internal_mem_inst.INJECT_SINGLE_NEXT == 0);
           @(posedge tb_clk);
           `uvm_info("CONC_HARNESS","Added correctable error in dmi<%=pidx%>_smc_data<%=i%>", UVM_LOW);   
           `DMI<%=pidx%>.<%=obj.DmiInfo[pidx].MemoryGeneration.dataMem.rtlPrefixString%><%=i%>.internal_mem_inst.inject_single_error();
        end<%}}%>
// Inject correctable error in DMI<%=pidx%> SMC Tag Memory
<%if(obj.DmiInfo[pidx].MemoryGeneration.tagMem.MemType == "NONE") {
for(var i=0; i < obj.DmiInfo[pidx].ccpParams.nTagBanks; i++) {%>
  initial
     if($test$plusargs("inject_correctable_error") && $test$plusargs("error_test"))
        forever begin
           @(posedge tb_clk);
           wait(`DMI<%=pidx%>.<%=obj.DmiInfo[pidx].MemoryGeneration.tagMem.rtlPrefixString%><%=i%>.internal_mem_inst.INJECT_SINGLE_NEXT == 0);
           @(posedge tb_clk);
           `uvm_info("CONC_HARNESS","Added correctable error in dmi<%=pidx%>_smc_tag<%=i%>", UVM_LOW);   
           `DMI<%=pidx%>.<%=obj.DmiInfo[pidx].MemoryGeneration.tagMem.rtlPrefixString%><%=i%>.internal_mem_inst.inject_single_error();
        end<%}}%>
// Inject correctable error in DMI<%=pidx%> Write Buffer memory
<%} 
if(obj.DmiInfo[pidx].fnErrDetectCorrect == "SECDED") { 
if(obj.DmiInfo[pidx].MemoryGeneration.dataMem.MemType == "NONE") {
for(var i=0; i < 2; i++) {%>
  initial
     if($test$plusargs("inject_correctable_error") && $test$plusargs("error_test"))
        forever begin
           @(posedge tb_clk);
           wait(`DMI<%=pidx%>.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst<%=i%>.INJECT_SINGLE_NEXT == 0);
           @(posedge tb_clk);
           `uvm_info("CONC_HARNESS","Added correctable error in dmi<%=pidx%>_write_buffer<%=i%>", UVM_LOW);   
           `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst<%=i%>.inject_single_error();
        end
<%} } } } } %>

<% for(pidx = 0; pidx < obj.nAIUs; pidx++) {
if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')){ 
if(obj.AiuInfo[pidx].useCache){
if(obj.AiuInfo[pidx].ccpParams.DataErrInfo == "SECDED") {
if(obj.AiuInfo[pidx].MemoryGeneration.dataMem.MemType == "NONE") {
for(var i=0; i < obj.AiuInfo[pidx].ccpParams.nDataBanks; i++) {%>
// Inject correctable error in IOAIU(AIU<%=pidx%>) proxy cache Data Memory
  initial
     if($test$plusargs("inject_correctable_error") && $test$plusargs("error_test"))
        forever begin
           @(posedge tb_clk);
           wait(`AIU<%=pidx%>.ccp_data_<%=i%>.internal_mem_inst.INJECT_SINGLE_NEXT == 0);
           @(posedge tb_clk);
           `uvm_info("CONC_HARNESS","Added correctable error in Aiu<%=pidx%>_ccp_data<%=i%>", UVM_LOW);   
           `AIU<%=pidx%>.ccp_data_<%=i%>.internal_mem_inst.inject_single_error();
        end
<%} } }%>
// Inject correctable error in IOAIU(AIU<%=pidx%>) proxy cache Tag Memory
<% if(obj.AiuInfo[pidx].ccpParams.TagErrInfo == "SECDED") { 
if(obj.AiuInfo[pidx].MemoryGeneration.tagMem.MemType == "NONE") {
for(var i=0; i < obj.AiuInfo[pidx].ccpParams.nTagBanks; i++) {%>
  initial
     if($test$plusargs("inject_correctable_error") && $test$plusargs("error_test"))
        forever begin
           @(posedge tb_clk);
           wait(`AIU<%=pidx%>.ccp_tag_<%=i%>.internal_mem_inst.INJECT_SINGLE_NEXT == 0);
           @(posedge tb_clk);
           `uvm_info("CONC_HARNESS","Added correctable error in Aiu<%=pidx%>_ccp_tag<%=i%>", UVM_LOW);   
           `AIU<%=pidx%>.ccp_tag_<%=i%>.internal_mem_inst.inject_single_error();
        end
<%} } } } }%>
// Inject correctable error in IOAIU(AIU<%=pidx%>) OTT
<% if(obj.AiuInfo[pidx].cmpInfo.OttErrorType == "SECDED") { 
if(obj.AiuInfo[pidx].MemoryGeneration.ottMem.MemType == "NONE") {
for(var i=0; i < obj.AiuInfo[pidx].cmpInfo.nOttDataBanks; i++) {%>
  initial
     if($test$plusargs("inject_correctable_error") && $test$plusargs("error_test"))
        forever begin
           @(posedge tb_clk);
           //wait(`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].MemoryGeneration.ottMem.rtlPrefixString%><%=i%>.internal_mem_inst.INJECT_SINGLE_NEXT == 0);
           wait(`AIU<%=pidx%>.ott_<%=i%>.internal_mem_inst.INJECT_SINGLE_NEXT == 0);
           @(posedge tb_clk);
           `uvm_info("CONC_HARNESS","Added correctable error in ioaiu<%=pidx%>_ott<%=i%>", UVM_LOW);   
           //`AIU<%=pidx%>.<%=obj.AiuInfo[pidx].MemoryGeneration.ottMem.rtlPrefixString%><%=i%>.internal_mem_inst.inject_single_error();
           `AIU<%=pidx%>.ott_<%=i%>.internal_mem_inst.inject_single_error();
        end
<%} } } }%>
// Inject correctable error in SnoopFilter DCE
<% for(pidx = 0; pidx < obj.nDCEs; pidx++) {
obj.DceInfo[pidx].SnoopFilterInfo.forEach(function injerr(item,idx) { 
if(item.TagFilterErrorInfo.fnErrDetectCorrect == "SECDED") { 
if(item.TagMem.MemType == "NONE") { 
for(var i=0; i < item.nWays; i++) {%>
  initial
     if($test$plusargs("inject_correctable_error") && $test$plusargs("error_test"))
        forever begin
           @(posedge tb_clk);
           wait(`DCE<%=pidx%>.f<%=idx%>m<%=i%>_memory.internal_mem_inst.INJECT_SINGLE_NEXT == 0);
           @(posedge tb_clk);
           `uvm_info("CONC_HARNESS","Added correctable error in Dce<%=pidx%>_SF<%=idx%>_tag_mem<%=i%>", UVM_LOW);   
           `DCE<%=pidx%>.f<%=idx%>m<%=i%>_memory.internal_mem_inst.inject_single_error();
        end
<%} } } } ); }%>

<%} // if assertOn %>
<%}%>
<% if(obj.testBench =="emu") { %>

`include "harness_smi_includes.svh"
`include "harness_apb_includes.svh"
`include "harness_axi_includes.svh"

import uvm_pkg::*;
import concerto_xrtl_pkg::*;
abc abc1 ;

  

    // Global Register Block
initial begin
   abc1 = new;
   $display($time, " Before_concerto_harness_init");
   abc1.set_myvif(ncore_hdl_top.concerto_phys_if) ;
   abc1.getValue ; 
   $display($time, " After_concerto_harness_init GetSignal");
           
end
 <% obj.DiiInfo.forEach(function(bundle, pidx) { %>
  //APB DII0 Block
     dii<%=sysdii_idx%>_harness_apb_paddr_logic_t        dii<%=pidx%>_capb_paddr  ; 
     dii<%=sysdii_idx%>_harness_apb_pwrite_logic_t       dii<%=pidx%>_capb_pwrite ;
     dii<%=sysdii_idx%>_harness_apb_psel_logic_t         dii<%=pidx%>_capb_psel   ;
     dii<%=sysdii_idx%>_harness_apb_penable_logic_t      dii<%=pidx%>_capb_penable;
     dii<%=sysdii_idx%>_harness_apb_prdata_logic_t       dii<%=pidx%>_capb_prdata ;
     dii<%=sysdii_idx%>_harness_apb_pwdata_logic_t       dii<%=pidx%>_capb_pwdata ;
     dii<%=sysdii_idx%>_harness_apb_pready_logic_t       dii<%=pidx%>_capb_pready ;
     dii<%=sysdii_idx%>_harness_apb_pslverr_logic_t      dii<%=pidx%>_capb_pslverr;

<% }); %>
<% for(var pidx = 0,qidx = 0; pidx < initiatorAgents; pidx++) { %>
 <%  if(_child_blk[pidx].match('chiaiu')) { %>
     dii<%=sysdii_idx%>_harness_apb_paddr_logic_t         <%=_child_blkid[pidx]%>_capb_paddr  ;
     dii<%=sysdii_idx%>_harness_apb_pwrite_logic_t        <%=_child_blkid[pidx]%>_capb_pwrite ; 
     dii<%=sysdii_idx%>_harness_apb_psel_logic_t          <%=_child_blkid[pidx]%>_capb_psel   ;
     dii<%=sysdii_idx%>_harness_apb_penable_logic_t       <%=_child_blkid[pidx]%>_capb_penable;
     dii<%=sysdii_idx%>_harness_apb_prdata_logic_t        <%=_child_blkid[pidx]%>_capb_prdata ;
     dii<%=sysdii_idx%>_harness_apb_pwdata_logic_t        <%=_child_blkid[pidx]%>_capb_pwdata ;
     dii<%=sysdii_idx%>_harness_apb_pready_logic_t        <%=_child_blkid[pidx]%>_capb_pready ;
     dii<%=sysdii_idx%>_harness_apb_pslverr_logic_t       <%=_child_blkid[pidx]%>_capb_pslverr;
 <% qidx++; %>
        <% } %>
 <% } %>

      //APB Signals AIU 
<% for(var pidx = 0,qidx = 0; pidx < initiatorAgents; pidx++) { %>
    <%  if(_child_blk[pidx].match('ioaiu')) { %>
//IOAIU
    dii<%=sysdii_idx%>_harness_apb_paddr_logic_t           <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_paddr   ;
    dii<%=sysdii_idx%>_harness_apb_pwrite_logic_t          <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pwrite  ;
    dii<%=sysdii_idx%>_harness_apb_psel_logic_t            <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_psel    ;
    dii<%=sysdii_idx%>_harness_apb_penable_logic_t         <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_penable ;
    dii<%=sysdii_idx%>_harness_apb_prdata_logic_t          <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_prdata  ;
    dii<%=sysdii_idx%>_harness_apb_pwdata_logic_t          <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pwdata  ;
    dii<%=sysdii_idx%>_harness_apb_pready_logic_t          <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pready  ;
    dii<%=sysdii_idx%>_harness_apb_pslverr_logic_t         <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pslverr ;
     <% qidx++; %>
       <% } %>
<% } %>
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
 //DMI
     dii<%=sysdii_idx%>_harness_apb_paddr_logic_t              dmi<%=pidx%>_capb_paddr   ;
     dii<%=sysdii_idx%>_harness_apb_pwrite_logic_t             dmi<%=pidx%>_capb_pwrite  ;
     dii<%=sysdii_idx%>_harness_apb_psel_logic_t               dmi<%=pidx%>_capb_psel    ;
     dii<%=sysdii_idx%>_harness_apb_penable_logic_t            dmi<%=pidx%>_capb_penable ;
     dii<%=sysdii_idx%>_harness_apb_prdata_logic_t             dmi<%=pidx%>_capb_prdata  ;
     dii<%=sysdii_idx%>_harness_apb_pwdata_logic_t             dmi<%=pidx%>_capb_pwdata  ;
     dii<%=sysdii_idx%>_harness_apb_pready_logic_t             dmi<%=pidx%>_capb_pready  ;
     dii<%=sysdii_idx%>_harness_apb_pslverr_logic_t            dmi<%=pidx%>_capb_pslverr ;

<% if(obj.DmiInfo[pidx].useCmc) { %>
 <% if(obj.DmiInfo[pidx].useWayPartitioning) { %>
 //CTRL channel
    dmi<%=pidx%>_harness_ccp_ctrlop_vld_logic_t    dmi<%=pidx%>_ctrl_op_valid_p0;
    dmi<%=pidx%>_harness_ccp_ctrlop_addr_logic_t   dmi<%=pidx%>_ctrl_op_address_p0;
    dmi<%=pidx%>_harness_ccp_ctrlop_security_t     dmi<%=pidx%>_ctrl_op_security_p0        ;
    dmi<%=pidx%>_harness_ccp_ctrlop_allocate_logic_t       dmi<%=pidx%>_ctrl_op_allocate_p2        ;
    dmi<%=pidx%>_harness_ccp_ctrlop_rd_data_logic_t        dmi<%=pidx%>_ctrl_op_read_data_p2       ;
    dmi<%=pidx%>_harness_ccp_ctrlop_wr_data_logic_t        dmi<%=pidx%>_ctrl_op_write_data_p2      ;
    dmi<%=pidx%>_harness_ccp_ctrlop_port_sel_logic_t       dmi<%=pidx%>_ctrl_op_port_sel_p2        ;
    dmi<%=pidx%>_harness_ccp_ctrlop_bypass_logic_t         dmi<%=pidx%>_ctrl_op_bypass_p2          ;
    dmi<%=pidx%>_harness_ccp_ctrlop_rp_update_logic_t      dmi<%=pidx%>_ctrl_op_rp_update_p2       ;
    dmi<%=pidx%>_harness_ccp_ctrlop_tagstateup_logic_t     dmi<%=pidx%>_ctrl_op_tag_state_update_p2;
    dmi<%=pidx%>_harness_ccp_cachestate_logic_t            dmi<%=pidx%>_ctrl_op_state_p2           ;
    dmi<%=pidx%>_harness_ccp_ctrlop_burstln_logic_t        dmi<%=pidx%>_ctrl_op_burst_len_p2       ;
    dmi<%=pidx%>_harness_ccp_ctrlop_burstwrap_logic_t      dmi<%=pidx%>_ctrl_op_burst_wrap_p2      ;
    dmi<%=pidx%>_harness_ccp_ctrlop_setway_debug_logic_t   dmi<%=pidx%>_ctrl_op_setway_debug_p2    ;
    dmi<%=pidx%>_harness_ccp_ctrlop_waybusy_vec_logic_t    dmi<%=pidx%>_ctrl_op_ways_busy_vec_p2   ;
    dmi<%=pidx%>_harness_ccp_ctrlop_waystale_vec_logic_t   dmi<%=pidx%>_ctrl_op_ways_stale_vec_p2  ;
    dmi<%=pidx%>_harness_ccp_cacheop_rdy_logic_t           dmi<%=pidx%>_cache_op_ready_p0          ;
    dmi<%=pidx%>_harness_ccp_cache_vld_logic_t             dmi<%=pidx%>_cache_valid_p2             ;
    dmi<%=pidx%>_harness_ccp_cachestate_logic_t            dmi<%=pidx%>_cache_current_state_p2     ;
    dmi<%=pidx%>_harness_ccp_cache_alloc_wayn_logic_t      dmi<%=pidx%>_cache_alloc_way_vec_p2 ;
    dmi<%=pidx%>_harness_ccp_cache_hit_wayn_logic_t        dmi<%=pidx%>_cache_hit_way_vec_p2 ;
    dmi<%=pidx%>_harness_ccp_cache_evictvld_logic_t        dmi<%=pidx%>_cache_evict_valid_p2       ;
    dmi<%=pidx%>_harness_ccp_cache_evictaddr_logic_t       dmi<%=pidx%>_cache_evict_address_p2     ;
    dmi<%=pidx%>_harness_ccp_cache_evictsecurity_t         dmi<%=pidx%>_cache_evict_security_p2    ;
    dmi<%=pidx%>_harness_ccp_cachestate_logic_t            dmi<%=pidx%>_cache_evict_state_p2       ;
    dmi<%=pidx%>_harness_ccp_cache_nackuce_logic_t         dmi<%=pidx%>_cache_nack_uce_p2          ;
    dmi<%=pidx%>_harness_ccp_cache_nack_logic_t            dmi<%=pidx%>_cache_nack_p2              ;
    dmi<%=pidx%>_harness_ccp_cache_nackce_logic_t          dmi<%=pidx%>_cache_nack_ce_p2           ;
    dmi<%=pidx%>_harness_ccp_cachenacknoalloc_logic_t      dmi<%=pidx%>_cache_nack_no_allocate_p2  ;
    //Fill CTRL Channel
    dmi<%=pidx%>_harness_ccp_ctrlfill_vld_logic_t          dmi<%=pidx%>_ctrl_fill_valid            ;
    dmi<%=pidx%>_harness_ccp_ctrlfill_addr_logic_t         dmi<%=pidx%>_ctrl_fill_address          ;
    dmi<%=pidx%>_harness_ccp_ctrlfilldata_wayn_logic_t     dmi<%=pidx%>_ctrl_fill_way_num          ;
    dmi<%=pidx%>_harness_ccp_ctrlfill_state_logic_t        dmi<%=pidx%>_ctrl_fill_state            ;
    dmi<%=pidx%>_harness_ccp_ctrlop_security_logic_t       dmi<%=pidx%>_ctrl_fill_security         ;
    //Fill Data Channel
    dmi<%=pidx%>_harness_ccp_ctrlfilldata_vld_logic_t      dmi<%=pidx%>_ctrl_fill_data_valid       ;
    dmi<%=pidx%>_harness_ccp_ctrlfill_data_logic_t         dmi<%=pidx%>_ctrl_fill_data             ;
    dmi<%=pidx%>_harness_ccp_ctrlfilldata_Id_logic_t       dmi<%=pidx%>_ctrl_fill_data_id          ;
    dmi<%=pidx%>_harness_ccp_ctrlfilldata_addr_logic_t     dmi<%=pidx%>_ctrl_fill_data_address     ;
    dmi<%=pidx%>_harness_ccp_ctrlfilldata_wayn_logic_t     dmi<%=pidx%>_ctrl_fill_data_way_num     ;
    
    dmi<%=pidx%>_harness_ccp_ctrlfilldata_beatn_logic_t    dmi<%=pidx%>_ctrl_fill_data_beat_num    ;
    dmi<%=pidx%>_harness_ccp_ctrlfilldata_byten_logic_t    dmi<%=pidx%>_ctrl_fill_data_byteen      ;
    dmi<%=pidx%>_harness_ccp_ctrlfilldata_last_logic_t     dmi<%=pidx%>_ctrl_fill_data_last        ;
    dmi<%=pidx%>_harness_ccp_cachefilldata_rdy_logic_t     dmi<%=pidx%>_cache_fill_data_ready      ;
    dmi<%=pidx%>_harness_ccp_cachefill_rdy_logic_t         dmi<%=pidx%>_cache_fill_ready           ;
    dmi<%=pidx%>_harness_ccp_cachefill_done_logic_t        dmi<%=pidx%>_cache_fill_done            ;
    dmi<%=pidx%>_harness_ccp_cachefill_doneId_logic_t      dmi<%=pidx%>_cache_fill_done_id         ;
    //WR Data Channel
    dmi<%=pidx%>_harness_ccp_ctrlwr_vld_logic_t            dmi<%=pidx%>_ctrl_wr_valid              ;
    dmi<%=pidx%>_harness_ccp_ctrlwr_data_logic_t           dmi<%=pidx%>_ctrl_wr_data               ;
    dmi<%=pidx%>_harness_ccp_ctrlwr_byten_logic_t          dmi<%=pidx%>_ctrl_wr_byte_en            ;
    dmi<%=pidx%>_harness_ccp_ctrlwr_beatn_logic_t          dmi<%=pidx%>_ctrl_wr_beat_num           ;
    dmi<%=pidx%>_harness_ccp_ctrlwr_last_logic_t           dmi<%=pidx%>_ctrl_wr_last               ;
    dmi<%=pidx%>_harness_ccp_cachewr_rdy_logic_t           dmi<%=pidx%>_cache_wr_ready             ;
    //Evict Channel
    dmi<%=pidx%>_harness_ccp_cache_evict_rdy_logic_t       dmi<%=pidx%>_cache_evict_ready          ;
    dmi<%=pidx%>_harness_ccp_cache_evict_vld_logic_t       dmi<%=pidx%>_cache_evict_valid          ;
    dmi<%=pidx%>_harness_ccp_cache_evict_data_logic_t      dmi<%=pidx%>_cache_evict_data           ;
    dmi<%=pidx%>_harness_ccp_cache_evict_byten_t           dmi<%=pidx%>_cache_evict_byteen         ;
    dmi<%=pidx%>_harness_ccp_cache_evict_last_logic_t      dmi<%=pidx%>_cache_evict_last           ;
    dmi<%=pidx%>_harness_ccp_cache_evict_cancel_logic_t    dmi<%=pidx%>_cache_evict_cancel         ;
    //Read response Channel
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_rdy_logic_t       dmi<%=pidx%>_cache_rdrsp_ready          ;
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_vld_t      dmi<%=pidx%>_cache_rdrsp_valid          ;
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_data_t           dmi<%=pidx%>_cache_rdrsp_data           ;
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_byten_t      dmi<%=pidx%>_cache_rdrsp_byteen         ;
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_last_logic_t    dmi<%=pidx%>_cache_rdrsp_last           ;
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_cancel_logic_t    dmi<%=pidx%>_cache_rdrsp_cancel         ;
    //Mnt Channel
    dmi<%=pidx%>_harness_ccp_csr_maint_req_opc_logic_t          dmi<%=pidx%>_maint_req_opcode           ;
    dmi<%=pidx%>_harness_ccp_csr_maint_wrdata_logic_t           dmi<%=pidx%>_maint_req_data             ;
    dmi<%=pidx%>_harness_ccp_csr_maint_req_way_logic_t          dmi<%=pidx%>_maint_req_way              ;
    dmi<%=pidx%>_harness_ccp_csr_maint_req_entry_logic_t        dmi<%=pidx%>_maint_req_entry            ;
    dmi<%=pidx%>_harness_ccp_csr_maint_req_word_logic_t         dmi<%=pidx%>_maint_req_word             ;
    dmi<%=pidx%>_harness_ccp_csr_maint_req_array_sel_logic_t    dmi<%=pidx%>_maint_req_array_sel        ;
    
    dmi<%=pidx%>_harness_ccp_csr_maint_active_logic_t           dmi<%=pidx%>_maint_active               ;
    dmi<%=pidx%>_harness_ccp_csr_maint_rddata_logic_t           dmi<%=pidx%>_maint_read_data            ;
    dmi<%=pidx%>_harness_ccp_csr_maint_rddata_en_logic_t        dmi<%=pidx%>_maint_read_data_en         ;
    bit                                                       dmi<%=pidx%>_is_replay    ;
    bit                                                       dmi<%=pidx%>_to_replay    ;
    bit                                                       dmi<%=pidx%>_recycle_valid;
    logic [dmi<%=pidx%>_harness_ccp_WSMIMSG-1:0]               dmi<%=pidx%>_ccp_p2_cm_type   ;
    logic [dmi<%=pidx%>_harness_ccp_WSMIMSG-1:0]               dmi<%=pidx%>_ccp_p0_cm_type   ;
    logic                           dmi<%=pidx%>_ccp_p0_write_nc_sel;
    logic                           dmi<%=pidx%>_ccp_p2_drop_hint;
    bit                             dmi<%=pidx%>_ccp_p2_mnt;
    logic                           dmi<%=pidx%>_replay_valid;
// ScratchPad signals
<% if (obj.DmiInfo[pidx].ccpParams.useScratchpad) { %>
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_vld_logic_t          dmi<%=pidx%>_scratch_rdrsp_valid        ;
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_data_logic_t         dmi<%=pidx%>_scratch_rdrsp_data         ;
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_byten_t              dmi<%=pidx%>_scratch_rdrsp_byteen       ;
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_last_logic_t         dmi<%=pidx%>_scratch_rdrsp_last         ;
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_rdy_logic_t          dmi<%=pidx%>_scratch_rdrsp_ready        ;
    dmi<%=pidx%>_harness_ccp_cache_rdrsp_cancel_logic_t       dmi<%=pidx%>_scratch_rdrsp_cancel       ;
    dmi<%=pidx%>_harness_ccp_ctrlwr_vld_logic_t              dmi<%=pidx%>_scratch_wr_valid           ;
    dmi<%=pidx%>_harness_ccp_ctrlwr_data_logic_t             dmi<%=pidx%>_scratch_wr_data            ;
    dmi<%=pidx%>_harness_ccp_ctrlwr_byten_logic_t            dmi<%=pidx%>_scratch_wr_byte_en         ;
    dmi<%=pidx%>_harness_ccp_ctrlwr_beatn_logic_t            dmi<%=pidx%>_scratch_wr_beat_num        ;
    dmi<%=pidx%>_harness_ccp_ctrlwr_last_logic_t             dmi<%=pidx%>_scratch_wr_last            ;
    dmi<%=pidx%>_harness_ccp_cachewr_rdy_logic_t             dmi<%=pidx%>_scratch_wr_ready           ;
    dmi<%=pidx%>_harness_ccp_sp_ctrl_rdy_logic_t            dmi<%=pidx%>_scratch_op_ready           ;
    dmi<%=pidx%>_harness_ccp_sp_ctrl_vld_logic_t            dmi<%=pidx%>_scratch_op_valid           ;
    dmi<%=pidx%>_harness_ccp_sp_ctrl_wr_data_logic_t        dmi<%=pidx%>_scratch_op_write_data      ;
    dmi<%=pidx%>_harness_ccp_sp_ctrl_rd_data_logic_t        dmi<%=pidx%>_scratch_op_read_data       ;
    dmi<%=pidx%>_harness_ccp_sp_ctrl_index_addr_logic_t     dmi<%=pidx%>_scratch_op_index_addr      ;
    dmi<%=pidx%>_harness_ccp_sp_ctrl_way_num_logic_t        dmi<%=pidx%>_scratch_op_way_num         ;
    dmi<%=pidx%>_harness_ccp_sp_ctrl_beat_num_logic_t       dmi<%=pidx%>_scratch_op_beat_num        ;
    dmi<%=pidx%>_harness_ccp_sp_ctrl_burst_len_logic_t      dmi<%=pidx%>_scratch_op_burst_len       ;
    dmi<%=pidx%>_harness_ccp_sp_ctrl_burst_type_logic_t     dmi<%=pidx%>_scratch_op_burst_wrap      ;
              <% } %>   
         <% } %>
     <% } %>
<% } %>

<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
 //DCE
    dii<%=sysdii_idx%>_harness_apb_paddr_logic_t              dce<%=pidx%>_capb_paddr   ;
    dii<%=sysdii_idx%>_harness_apb_pwrite_logic_t             dce<%=pidx%>_capb_pwrite  ;
    dii<%=sysdii_idx%>_harness_apb_psel_logic_t               dce<%=pidx%>_capb_psel    ;
    dii<%=sysdii_idx%>_harness_apb_penable_logic_t            dce<%=pidx%>_capb_penable ;
    dii<%=sysdii_idx%>_harness_apb_prdata_logic_t             dce<%=pidx%>_capb_prdata  ;
    dii<%=sysdii_idx%>_harness_apb_pwdata_logic_t             dce<%=pidx%>_capb_pwdata  ;
    dii<%=sysdii_idx%>_harness_apb_pready_logic_t             dce<%=pidx%>_capb_pready  ;
    dii<%=sysdii_idx%>_harness_apb_pslverr_logic_t            dce<%=pidx%>_capb_pslverr ;
<% } %>
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
//DVE
    dii<%=sysdii_idx%>_harness_apb_paddr_logic_t             dve<%=pidx%>_capb_paddr   ;
    dii<%=sysdii_idx%>_harness_apb_pwrite_logic_t            dve<%=pidx%>_capb_pwrite  ;
    dii<%=sysdii_idx%>_harness_apb_psel_logic_t              dve<%=pidx%>_capb_psel    ;
    dii<%=sysdii_idx%>_harness_apb_penable_logic_t           dve<%=pidx%>_capb_penable ;
    dii<%=sysdii_idx%>_harness_apb_prdata_logic_t            dve<%=pidx%>_capb_prdata  ;
    dii<%=sysdii_idx%>_harness_apb_pwdata_logic_t            dve<%=pidx%>_capb_pwdata  ;
    dii<%=sysdii_idx%>_harness_apb_pready_logic_t            dve<%=pidx%>_capb_pready  ;
    dii<%=sysdii_idx%>_harness_apb_pslverr_logic_t           dve<%=pidx%>_capb_pslverr ;
<% } %>
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
<% if (obj.DiiInfo[pidx].configuration == 1) { %> 
    dii<%=sysdii_idx%>_harness_apb_paddr_logic_t        dii<%=pidx%>_cgrb_apb_paddr  ; 
    dii<%=sysdii_idx%>_harness_apb_pwrite_logic_t       dii<%=pidx%>_cgrb_apb_pwrite ;
    dii<%=sysdii_idx%>_harness_apb_psel_logic_t         dii<%=pidx%>_cgrb_apb_psel   ;
    dii<%=sysdii_idx%>_harness_apb_penable_logic_t      dii<%=pidx%>_cgrb_apb_penable;
    dii<%=sysdii_idx%>_harness_apb_prdata_logic_t       dii<%=pidx%>_cgrb_apb_prdata ;
    dii<%=sysdii_idx%>_harness_apb_pwdata_logic_t       dii<%=pidx%>_cgrb_apb_pwdata ;
    dii<%=sysdii_idx%>_harness_apb_pready_logic_t       dii<%=pidx%>_cgrb_apb_pready ;
    dii<%=sysdii_idx%>_harness_apb_pslverr_logic_t      dii<%=pidx%>_cgrb_apb_pslverr;
    logic                                      dii<%=sysdii_idx%>_c_awready     ; 
    logic                                      dii<%=sysdii_idx%>_c_awvalid     ; 
    dii<%=pidx%>_harness_axi_awid_logic_t      dii<%=sysdii_idx%>_c_awid        ; 
    dii<%=pidx%>_harness_axi_axaddr_logic_t    dii<%=sysdii_idx%>_c_awaddr      ; 
    dii<%=pidx%>_harness_axi_axburst_logic_t   dii<%=sysdii_idx%>_c_awburst     ; 
    dii<%=pidx%>_harness_axi_axlen_logic_t     dii<%=sysdii_idx%>_c_awlen       ; 
    dii<%=pidx%>_harness_axi_axlock_logic_t    dii<%=sysdii_idx%>_c_awlock      ; 
    dii<%=pidx%>_harness_axi_axprot_logic_t    dii<%=sysdii_idx%>_c_awprot      ; 
    dii<%=pidx%>_harness_axi_axsize_logic_t    dii<%=sysdii_idx%>_c_awsize      ; 
    dii<%=pidx%>_harness_axi_axqos_logic_t     dii<%=sysdii_idx%>_c_awqos       ; 
    dii<%=pidx%>_harness_axi_axregion_logic_t  dii<%=sysdii_idx%>_c_awregion    ; 
    dii<%=pidx%>_harness_axi_awuser_logic_t    dii<%=sysdii_idx%>_c_awuser      ; 
    dii<%=pidx%>_harness_axi_axcache_logic_t   dii<%=sysdii_idx%>_c_awcache     ; 
    logic                                      dii<%=sysdii_idx%>_c_wready      ;
    logic                                      dii<%=sysdii_idx%>_c_wvalid      ;
    dii<%=pidx%>_harness_axi_xdata_logic_t     dii<%=sysdii_idx%>_c_wdata       ;
    logic                                      dii<%=sysdii_idx%>_c_wlast       ;
    dii<%=pidx%>_harness_axi_xstrb_logic_t     dii<%=sysdii_idx%>_c_wstrb       ;
    dii<%=pidx%>_harness_axi_wuser_logic_t     dii<%=sysdii_idx%>_c_wuser        ;
    logic                                      dii<%=sysdii_idx%>_c_bready       ;
    logic                                      dii<%=sysdii_idx%>_c_bvalid       ;
    dii<%=pidx%>_harness_axi_awid_logic_t      dii<%=sysdii_idx%>_c_bid          ;
    dii<%=pidx%>_harness_axi_bresp_logic_t     dii<%=sysdii_idx%>_c_bresp        ;
    dii<%=pidx%>_harness_axi_buser_logic_t     dii<%=sysdii_idx%>_c_buser        ;
    logic                                      dii<%=sysdii_idx%>_c_arready      ;
    logic                                      dii<%=sysdii_idx%>_c_arvalid      ;
    dii<%=pidx%>_harness_axi_axaddr_logic_t    dii<%=sysdii_idx%>_c_araddr       ;
    dii<%=pidx%>_harness_axi_axburst_logic_t   dii<%=sysdii_idx%>_c_arburst      ;
    dii<%=pidx%>_harness_axi_arid_logic_t      dii<%=sysdii_idx%>_c_arid         ;
    dii<%=pidx%>_harness_axi_axlen_logic_t     dii<%=sysdii_idx%>_c_arlen        ;
    dii<%=pidx%>_harness_axi_axlock_logic_t    dii<%=sysdii_idx%>_c_arlock       ;
    dii<%=pidx%>_harness_axi_axprot_logic_t    dii<%=sysdii_idx%>_c_arprot       ;
    dii<%=pidx%>_harness_axi_axsize_logic_t    dii<%=sysdii_idx%>_c_arsize      ;
    dii<%=pidx%>_harness_axi_axqos_logic_t     dii<%=sysdii_idx%>_c_arqos        ;
    dii<%=pidx%>_harness_axi_axregion_logic_t  dii<%=sysdii_idx%>_c_arregion     ;
    dii<%=pidx%>_harness_axi_aruser_logic_t    dii<%=sysdii_idx%>_c_aruser       ;
    dii<%=pidx%>_harness_axi_axcache_logic_t   dii<%=sysdii_idx%>_c_arcache      ;
    logic                                      dii<%=sysdii_idx%>_c_rready       ;
    dii<%=pidx%>_harness_axi_arid_logic_t      dii<%=sysdii_idx%>_c_rid          ;
    dii<%=pidx%>_harness_axi_rresp_logic_t     dii<%=sysdii_idx%>_c_rresp        ;
    logic                                      dii<%=sysdii_idx%>_c_rvalid       ;
    dii<%=pidx%>_harness_axi_xdata_logic_t     dii<%=sysdii_idx%>_c_rdata        ;
    logic                                      dii<%=sysdii_idx%>_c_rlast        ;
    dii<%=pidx%>_harness_axi_ruser_logic_t     dii<%=sysdii_idx%>_c_ruser        ;
        <% } %>
<% } %>
//DMI RTL IF
<%axiidx =0; obj.DmiInfo.forEach(function(bundle, pidx) { %>
    logic                                              dmi<%=pidx%>_c_cmd_starv_mode;
    logic                                                     dmi<%=pidx%>_c_cmd_rsp_push_valid;
    logic                                                     dmi<%=pidx%>_c_cmd_rsp_push_ready;
    logic [<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0]    dmi<%=pidx%>_c_cmd_rsp_push_rmsg_id;
    logic [<%=obj.Widths.Concerto.Ndp.Header.wFUnitId-1%>:0]  dmi<%=pidx%>_c_cmd_rsp_push_targ_id;
    
    logic                                                     dmi<%=pidx%>_c_mrd_pop_valid;
    logic                                                     dmi<%=pidx%>_c_mrd_pop_ready;
    logic [<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0]    dmi<%=pidx%>_c_mrd_pop_msg_id;
    logic [<%=obj.Widths.Concerto.Ndp.Header.wFUnitId-1%>:0]  dmi<%=pidx%>_c_mrd_pop_initiator_id;
    logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]       dmi<%=pidx%>_c_mrd_pop_addr;
    logic                                                     dmi<%=pidx%>_c_mrd_pop_ns;
    logic                                                     dmi<%=pidx%>_c_mrd_starv_mode;
    <% axiidx++ }); %>
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
<%for(var i = 0; i < obj.DiiInfo[pidx].nSmiTx; i++) { %>
    dii<%=pidx%>_harness_smi_msg_valid_logic_t      harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_valid; 
    dii<%=pidx%>_harness_smi_msg_ready_logic_t 	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_ready ;	
    dii<%=pidx%>_harness_smi_ndp_len_logic_t   	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp_len	;
    dii<%=pidx%>_harness_smi_dp_present_logic_t	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_dp_present;
    dii<%=pidx%>_harness_smi_targ_id_logic_t   	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_targ_id	;
    dii<%=pidx%>_harness_smi_src_id_logic_t    	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_src_id	;
    dii<%=pidx%>_harness_smi_msg_id_logic_t    	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_id	;
    dii<%=pidx%>_harness_smi_msg_type_logic_t  	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_type	;
<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
    dii<%=pidx%>_harness_smi_msg_user_logic_t	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_user	; 
<% }  %>
<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
    dii<%=pidx%>_harness_smi_msg_tier_logic_t harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_tier	;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
    dii<%=pidx%>_harness_smi_steer_logic_t harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_steer	;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
    dii<%=pidx%>_harness_smi_msg_pri_logic_t harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_pri	;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
    dii<%=pidx%>_harness_smi_msg_qos_logic_t harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_qos	; 
<% } %>
    dii<%=pidx%>_harness_smi_ndp_logic_t	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp 	;
    <%  if (obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
    dii<%=pidx%>_harness_smi_dp_valid_bit_t	        harness_dii<%=pidx%>_smi_tx<%=i%>_dp_valid   ;  
    dii<%=pidx%>_harness_smi_dp_ready_bit_t	        harness_dii<%=pidx%>_smi_tx<%=i%>_dp_ready   ;  
    dii<%=pidx%>_harness_smi_dp_last_bit_t	        harness_dii<%=pidx%>_smi_tx<%=i%>_dp_last    ;  
    dii<%=pidx%>_harness_smi_dp_data_logic_t	        harness_dii<%=pidx%>_smi_tx<%=i%>_dp_data    ;  
    dii<%=pidx%>_harness_smi_dp_user_logic_t	        harness_dii<%=pidx%>_smi_tx<%=i%>_dp_user    ;  
    <%  } %> 
<% } %>
<%for(var i = 0; i < obj.DiiInfo[pidx].nSmiRx; i++) { %>
    dii<%=pidx%>_harness_smi_msg_valid_logic_t          harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_valid	;
    dii<%=pidx%>_harness_smi_msg_ready_logic_t          harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_ready	;
    dii<%=pidx%>_harness_smi_ndp_len_logic_t            harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp_len	;
    dii<%=pidx%>_harness_smi_dp_present_logic_t         harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_dp_present;
    dii<%=pidx%>_harness_smi_targ_id_logic_t            harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_targ_id	;
    dii<%=pidx%>_harness_smi_src_id_logic_t             harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_src_id	;
    dii<%=pidx%>_harness_smi_msg_id_logic_t             harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_id	;
    dii<%=pidx%>_harness_smi_msg_type_logic_t           harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_type	;
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
    dii<%=pidx%>_harness_smi_msg_user_logic_t harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_user ; 
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
    dii<%=pidx%>_harness_smi_msg_tier_logic_t  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_tier	;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
    dii<%=pidx%>_harness_smi_steer_logic_t  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_steer	;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
    dii<%=pidx%>_harness_smi_msg_pri_logic_t  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_pri	;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
    dii<%=pidx%>_harness_smi_msg_qos_logic_t harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_qos	; 
<% } %> 
    dii<%=pidx%>_harness_smi_ndp_logic_t	 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp	;
<%  if (obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
    dii<%=pidx%>_harness_smi_dp_valid_bit_t	  	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_valid	;  
    dii<%=pidx%>_harness_smi_dp_ready_bit_t	  	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_ready	;  
    dii<%=pidx%>_harness_smi_dp_last_bit_t	  	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_last	;  
    dii<%=pidx%>_harness_smi_dp_data_logic_t	  	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_data	;  
    dii<%=pidx%>_harness_smi_dp_user_logic_t	  	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_user	;  
            <%  } %>
       <% } %>
<% } %>
initial begin
  forever begin
      $display($time, " harness_module_started_before");
      @(posedge tb_top.concerto_tb_aclk);
 // always @(posedge tb_top.concerto_tb_aclk) begin
      abc1.getValue ; 
      $display($time, " harness_module_started_after");
<% obj.DiiInfo.forEach(function(bundle, pidx) { %>
//APB DII0 Block
    dii<%=pidx%>_capb_paddr      =  abc1.dii<%=pidx%>_apb_paddr     ; 
    dii<%=pidx%>_capb_pwrite     =  abc1.dii<%=pidx%>_apb_pwrite    ;
    dii<%=pidx%>_capb_psel       =  abc1.dii<%=pidx%>_apb_psel      ;
    dii<%=pidx%>_capb_penable    =  abc1.dii<%=pidx%>_apb_penable   ;
    dii<%=pidx%>_capb_prdata     =  abc1.dii<%=pidx%>_apb_prdata    ;
    dii<%=pidx%>_capb_pwdata     =  abc1.dii<%=pidx%>_apb_pwdata    ;
    dii<%=pidx%>_capb_pready     =  abc1.dii<%=pidx%>_apb_pready    ;
    dii<%=pidx%>_capb_pslverr    =  abc1.dii<%=pidx%>_apb_pslverr   ;
    u_dii_apb_if_<%=pidx%>.paddr   =  dii<%=pidx%>_capb_paddr  ;
    u_dii_apb_if_<%=pidx%>.pwrite  =  dii<%=pidx%>_capb_pwrite ;
    u_dii_apb_if_<%=pidx%>.psel    =  dii<%=pidx%>_capb_psel   ;
    u_dii_apb_if_<%=pidx%>.penable =  dii<%=pidx%>_capb_penable;
    u_dii_apb_if_<%=pidx%>.prdata  =  dii<%=pidx%>_capb_prdata ;
    u_dii_apb_if_<%=pidx%>.pwdata  =  dii<%=pidx%>_capb_pwdata ;
    u_dii_apb_if_<%=pidx%>.pready  =  dii<%=pidx%>_capb_pready ;
    u_dii_apb_if_<%=pidx%>.pslverr =  dii<%=pidx%>_capb_pslverr;
<% }); %>
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
     <% if (obj.DiiInfo[pidx].configuration == 1) { %> 
    dii<%=pidx%>_cgrb_apb_paddr         =  abc1.dii<%=sysdii_idx%>_grb_apb_paddr  ;
    dii<%=pidx%>_cgrb_apb_pwrite        =  abc1.dii<%=sysdii_idx%>_grb_apb_pwrite ;
    dii<%=pidx%>_cgrb_apb_psel          =  abc1.dii<%=sysdii_idx%>_grb_apb_psel   ;
    dii<%=pidx%>_cgrb_apb_penable       =  abc1.dii<%=sysdii_idx%>_grb_apb_penable;
    dii<%=pidx%>_cgrb_apb_prdata        =  abc1.dii<%=sysdii_idx%>_grb_apb_prdata ;
    dii<%=pidx%>_cgrb_apb_pwdata        =  abc1.dii<%=sysdii_idx%>_grb_apb_pwdata ;
    dii<%=pidx%>_cgrb_apb_pready        =  abc1.dii<%=sysdii_idx%>_grb_apb_pready ;
    dii<%=pidx%>_cgrb_apb_pslverr       =  abc1.dii<%=sysdii_idx%>_grb_apb_pslverr;
    u_grb_apb_if.paddr                  =  dii<%=pidx%>_cgrb_apb_paddr  ; 
    u_grb_apb_if.pwrite                 =  dii<%=pidx%>_cgrb_apb_pwrite ; 
    u_grb_apb_if.psel                   =  dii<%=pidx%>_cgrb_apb_psel   ; 
    u_grb_apb_if.penable                =  dii<%=pidx%>_cgrb_apb_penable; 
    u_grb_apb_if.prdata                 =  dii<%=pidx%>_cgrb_apb_prdata ; 
    u_grb_apb_if.pwdata                 =  dii<%=pidx%>_cgrb_apb_pwdata ; 
    u_grb_apb_if.pready                 =  dii<%=pidx%>_cgrb_apb_pready ; 
    u_grb_apb_if.pslverr                =  dii<%=pidx%>_cgrb_apb_pslverr;
    dii<%=sysdii_idx%>_c_awready   =      abc1.dii<%=sysdii_idx%>_intf_awready ; 
    dii<%=sysdii_idx%>_c_awvalid   =      abc1.dii<%=sysdii_idx%>_intf_awvalid ; 
    dii<%=sysdii_idx%>_c_awid      =      abc1.dii<%=sysdii_idx%>_intf_awid    ; 
    dii<%=sysdii_idx%>_c_awaddr    =      abc1.dii<%=sysdii_idx%>_intf_awaddr  ; 
    dii<%=sysdii_idx%>_c_awburst   =      abc1.dii<%=sysdii_idx%>_intf_awburst ; 
    dii<%=sysdii_idx%>_c_awlen     =      abc1.dii<%=sysdii_idx%>_intf_awlen   ; 
    dii<%=sysdii_idx%>_c_awlock    =      abc1.dii<%=sysdii_idx%>_intf_awlock  ; 
    dii<%=sysdii_idx%>_c_awprot    =      abc1.dii<%=sysdii_idx%>_intf_awprot  ; 
    dii<%=sysdii_idx%>_c_awsize    =      abc1.dii<%=sysdii_idx%>_intf_awsize  ; 
    dii<%=sysdii_idx%>_c_awqos     =      abc1.dii<%=sysdii_idx%>_intf_awqos   ; 
    dii<%=sysdii_idx%>_c_awregion  =      abc1.dii<%=sysdii_idx%>_intf_awregion; 
    dii<%=sysdii_idx%>_c_awuser    =      abc1.dii<%=sysdii_idx%>_intf_awuser  ; 
    dii<%=sysdii_idx%>_c_awcache   =      abc1.dii<%=sysdii_idx%>_intf_awcache ; 
    dii<%=sysdii_idx%>_c_wready    =      abc1.dii<%=sysdii_idx%>_intf_wready  ; 
    dii<%=sysdii_idx%>_c_wvalid    =      abc1.dii<%=sysdii_idx%>_intf_wvalid  ; 
    dii<%=sysdii_idx%>_c_wdata     =      abc1.dii<%=sysdii_idx%>_intf_wdata   ; 
    dii<%=sysdii_idx%>_c_wlast     =      abc1.dii<%=sysdii_idx%>_intf_wlast   ; 
    dii<%=sysdii_idx%>_c_wstrb     =      abc1.dii<%=sysdii_idx%>_intf_wstrb   ; 
    dii<%=sysdii_idx%>_c_wuser     =      abc1.dii<%=sysdii_idx%>_intf_wuser   ; 
    dii<%=sysdii_idx%>_c_bready    =      abc1.dii<%=sysdii_idx%>_intf_bready  ; 
    dii<%=sysdii_idx%>_c_bvalid    =      abc1.dii<%=sysdii_idx%>_intf_bvalid  ; 
    dii<%=sysdii_idx%>_c_bid       =      abc1.dii<%=sysdii_idx%>_intf_bid     ; 
    dii<%=sysdii_idx%>_c_bresp     =      abc1.dii<%=sysdii_idx%>_intf_bresp   ; 
    dii<%=sysdii_idx%>_c_buser     =      abc1.dii<%=sysdii_idx%>_intf_buser   ; 
    dii<%=sysdii_idx%>_c_arready   =      abc1.dii<%=sysdii_idx%>_intf_arready ; 
    dii<%=sysdii_idx%>_c_arvalid   =      abc1.dii<%=sysdii_idx%>_intf_arvalid ; 
    dii<%=sysdii_idx%>_c_araddr    =      abc1.dii<%=sysdii_idx%>_intf_araddr  ; 
    dii<%=sysdii_idx%>_c_arburst   =      abc1.dii<%=sysdii_idx%>_intf_arburst ; 
    dii<%=sysdii_idx%>_c_arid      =      abc1.dii<%=sysdii_idx%>_intf_arid    ; 
    dii<%=sysdii_idx%>_c_arlen     =      abc1.dii<%=sysdii_idx%>_intf_arlen   ; 
    dii<%=sysdii_idx%>_c_arlock    =      abc1.dii<%=sysdii_idx%>_intf_arlock  ; 
    dii<%=sysdii_idx%>_c_arprot    =      abc1.dii<%=sysdii_idx%>_intf_arprot  ; 
    dii<%=sysdii_idx%>_c_arsize    =      abc1.dii<%=sysdii_idx%>_intf_arsize ; 
    dii<%=sysdii_idx%>_c_arqos     =      abc1.dii<%=sysdii_idx%>_intf_arqos   ; 
    dii<%=sysdii_idx%>_c_arregion  =      abc1.dii<%=sysdii_idx%>_intf_arregion; 
    dii<%=sysdii_idx%>_c_aruser    =      abc1.dii<%=sysdii_idx%>_intf_aruser  ; 
    dii<%=sysdii_idx%>_c_arcache   =      abc1.dii<%=sysdii_idx%>_intf_arcache ; 
    dii<%=sysdii_idx%>_c_rready    =      abc1.dii<%=sysdii_idx%>_intf_rready  ; 
    dii<%=sysdii_idx%>_c_rid       =      abc1.dii<%=sysdii_idx%>_intf_rid     ; 
    dii<%=sysdii_idx%>_c_rresp     =      abc1.dii<%=sysdii_idx%>_intf_rresp   ; 
    dii<%=sysdii_idx%>_c_rvalid    =      abc1.dii<%=sysdii_idx%>_intf_rvalid  ; 
    dii<%=sysdii_idx%>_c_rdata     =      abc1.dii<%=sysdii_idx%>_intf_rdata   ; 
    dii<%=sysdii_idx%>_c_rlast     =      abc1.dii<%=sysdii_idx%>_intf_rlast   ; 
    dii<%=sysdii_idx%>_c_ruser     =      abc1.dii<%=sysdii_idx%>_intf_ruser   ; 
     <% } %>
<% } %>
<% for(var pidx = 0,qidx = 0; pidx < initiatorAgents; pidx++) { %>
<%  if(_child_blk[pidx].match('chiaiu')) { %>
    <%=_child_blkid[pidx]%>_capb_paddr      = abc1.<%=_child_blkid[pidx]%>_apb_paddr      ;
    <%=_child_blkid[pidx]%>_capb_pwrite     = abc1.<%=_child_blkid[pidx]%>_apb_pwrite     ; 
    <%=_child_blkid[pidx]%>_capb_psel       = abc1.<%=_child_blkid[pidx]%>_apb_psel       ;
    <%=_child_blkid[pidx]%>_capb_penable    = abc1.<%=_child_blkid[pidx]%>_apb_penable    ;
    <%=_child_blkid[pidx]%>_capb_prdata     = abc1.<%=_child_blkid[pidx]%>_apb_prdata     ;
    <%=_child_blkid[pidx]%>_capb_pwdata     = abc1.<%=_child_blkid[pidx]%>_apb_pwdata     ;
    <%=_child_blkid[pidx]%>_capb_pready     = abc1.<%=_child_blkid[pidx]%>_apb_pready     ;
    <%=_child_blkid[pidx]%>_capb_pslverr    = abc1.<%=_child_blkid[pidx]%>_apb_pslverr    ;
    u_chi_apb_if_<%=qidx%>.paddr   =   <%=_child_blkid[pidx]%>_capb_paddr  ;
    u_chi_apb_if_<%=qidx%>.pwrite  =   <%=_child_blkid[pidx]%>_capb_pwrite ;
    u_chi_apb_if_<%=qidx%>.psel    =   <%=_child_blkid[pidx]%>_capb_psel   ;
    u_chi_apb_if_<%=qidx%>.penable =   <%=_child_blkid[pidx]%>_capb_penable;
    u_chi_apb_if_<%=qidx%>.prdata  =   <%=_child_blkid[pidx]%>_capb_prdata ;
    u_chi_apb_if_<%=qidx%>.pwdata  =   <%=_child_blkid[pidx]%>_capb_pwdata ;
    u_chi_apb_if_<%=qidx%>.pready  =   <%=_child_blkid[pidx]%>_capb_pready ;
    u_chi_apb_if_<%=qidx%>.pslverr =   <%=_child_blkid[pidx]%>_capb_pslverr;
    <% qidx++; %>
    <% } %>
<% } %>
//APB Signals AIU 
<% for(var pidx = 0,qidx = 0; pidx < initiatorAgents; pidx++) { %>
<%  if(_child_blk[pidx].match('ioaiu')) { %>
//IOAIU
    <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_paddr     =   abc1.<%=_child_blkid[pidx]%>_apb_paddr    ;
    <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pwrite    =   abc1.<%=_child_blkid[pidx]%>_apb_pwrite   ;
    <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_psel      =   abc1.<%=_child_blkid[pidx]%>_apb_psel     ;
    <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_penable   =   abc1.<%=_child_blkid[pidx]%>_apb_penable  ;
    <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_prdata    =   abc1.<%=_child_blkid[pidx]%>_apb_prdata   ;
    <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pwdata    =   abc1.<%=_child_blkid[pidx]%>_apb_pwdata   ;
    <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pready    =   abc1.<%=_child_blkid[pidx]%>_apb_pready   ;
    <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pslverr   =   abc1.<%=_child_blkid[pidx]%>_apb_pslverr  ;
    u_sysdii_ioaiu_apb_if_<%=qidx%>.IS_IF_A_MONITOR =1; 
    u_sysdii_ioaiu_apb_if_<%=qidx%>.paddr   =   <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_paddr  ; 
    u_sysdii_ioaiu_apb_if_<%=qidx%>.pwrite  =   <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pwrite ; 
    u_sysdii_ioaiu_apb_if_<%=qidx%>.psel    =   <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_psel   ; 
    u_sysdii_ioaiu_apb_if_<%=qidx%>.penable =   <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_penable; 
    u_sysdii_ioaiu_apb_if_<%=qidx%>.prdata  =   <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_prdata ; 
    u_sysdii_ioaiu_apb_if_<%=qidx%>.pwdata  =   <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pwdata ; 
    u_sysdii_ioaiu_apb_if_<%=qidx%>.pready  =   <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pready ; 
    u_sysdii_ioaiu_apb_if_<%=qidx%>.pslverr =   <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_capb_pslverr; 
     <% qidx++; %>
     <% } %>
<% } %>
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
//DMI
    dmi<%=pidx%>_capb_paddr      =   abc1.dmi<%=pidx%>_apb_paddr    ;
    dmi<%=pidx%>_capb_pwrite     =   abc1.dmi<%=pidx%>_apb_pwrite   ;
    dmi<%=pidx%>_capb_psel       =   abc1.dmi<%=pidx%>_apb_psel     ;
    dmi<%=pidx%>_capb_penable    =   abc1.dmi<%=pidx%>_apb_penable  ;
    dmi<%=pidx%>_capb_prdata     =   abc1.dmi<%=pidx%>_apb_prdata   ;
    dmi<%=pidx%>_capb_pwdata     =   abc1.dmi<%=pidx%>_apb_pwdata   ;
    dmi<%=pidx%>_capb_pready     =   abc1.dmi<%=pidx%>_apb_pready   ;
    dmi<%=pidx%>_capb_pslverr    =   abc1.dmi<%=pidx%>_apb_pslverr  ;
    u_dmi_apb_if_<%=pidx%>.paddr   =    dmi<%=pidx%>_capb_paddr     ;
    u_dmi_apb_if_<%=pidx%>.pwrite  =    dmi<%=pidx%>_capb_pwrite    ;
    u_dmi_apb_if_<%=pidx%>.psel    =    dmi<%=pidx%>_capb_psel      ;
    u_dmi_apb_if_<%=pidx%>.penable =    dmi<%=pidx%>_capb_penable   ;
    u_dmi_apb_if_<%=pidx%>.prdata  =    dmi<%=pidx%>_capb_prdata    ;
    u_dmi_apb_if_<%=pidx%>.pwdata  =    dmi<%=pidx%>_capb_pwdata    ;
    u_dmi_apb_if_<%=pidx%>.pready  =    dmi<%=pidx%>_capb_pready    ;
    u_dmi_apb_if_<%=pidx%>.pslverr =    dmi<%=pidx%>_capb_pslverr   ;
    dmi<%=pidx%>_c_cmd_starv_mode  =    abc1.dmi<%=pidx%>_cmd_starv_mode ;
    dmi<%=pidx%>_c_mrd_starv_mode  =    abc1.dmi<%=pidx%>_mrd_starv_mode ;
    dmi<%=pidx%>_c_cmd_rsp_push_valid = abc1.dmi<%=pidx%>_cmd_rsp_push_valid ;   
    dmi<%=pidx%>_c_cmd_rsp_push_ready = abc1.dmi<%=pidx%>_cmd_rsp_push_ready ;  
    dmi<%=pidx%>_c_cmd_rsp_push_rmsg_id = abc1.dmi<%=pidx%>_cmd_rsp_push_rmsg_id; 
    dmi<%=pidx%>_c_cmd_rsp_push_targ_id = abc1.dmi<%=pidx%>_cmd_rsp_push_targ_id ;
<% if(obj.DmiInfo[pidx].useCmc) { %>
    <% if(obj.DmiInfo[pidx].useWayPartitioning) { %>
    dmi<%=pidx%>_ctrl_op_valid_p0    =    abc1.dmi<%=pidx%>_intf_ctrl_op_valid_p0 ;  
    dmi<%=pidx%>_ctrl_op_address_p0  =    abc1.dmi<%=pidx%>_intf_ctrl_op_address_p0 ;
    dmi<%=pidx%>_ctrl_op_security_p0 =    abc1.dmi<%=pidx%>_intf_ctrl_op_security_p0 ;
    dmi<%=pidx%>_ctrl_op_allocate_p2               =      abc1.dmi<%=pidx%>_intf_ctrl_op_allocate_p2                    ;
    dmi<%=pidx%>_ctrl_op_read_data_p2              =      abc1.dmi<%=pidx%>_intf_ctrl_op_read_data_p2                   ;
    dmi<%=pidx%>_ctrl_op_write_data_p2             =      abc1.dmi<%=pidx%>_intf_ctrl_op_write_data_p2               ;
    dmi<%=pidx%>_ctrl_op_port_sel_p2               =      abc1.dmi<%=pidx%>_intf_ctrl_op_port_sel_p2                  ;
    dmi<%=pidx%>_ctrl_op_bypass_p2                 =      abc1.dmi<%=pidx%>_intf_ctrl_op_bypass_p2                    ;
    dmi<%=pidx%>_ctrl_op_rp_update_p2              =      abc1.dmi<%=pidx%>_intf_ctrl_op_rp_update_p2                 ;
    dmi<%=pidx%>_ctrl_op_tag_state_update_p2       =      abc1.dmi<%=pidx%>_intf_ctrl_op_tag_state_update_p2           ;
    dmi<%=pidx%>_ctrl_op_state_p2                  =      abc1.dmi<%=pidx%>_intf_ctrl_op_state_p2                ;
    dmi<%=pidx%>_ctrl_op_burst_len_p2              =      abc1.dmi<%=pidx%>_intf_ctrl_op_burst_len_p2            ;
    dmi<%=pidx%>_ctrl_op_burst_wrap_p2             =      abc1.dmi<%=pidx%>_intf_ctrl_op_burst_wrap_p2           ;
    dmi<%=pidx%>_ctrl_op_setway_debug_p2           =      abc1.dmi<%=pidx%>_intf_ctrl_op_setway_debug_p2         ;
    dmi<%=pidx%>_ctrl_op_ways_busy_vec_p2          =      abc1.dmi<%=pidx%>_intf_ctrl_op_ways_busy_vec_p2        ;
    dmi<%=pidx%>_ctrl_op_ways_stale_vec_p2         =      abc1.dmi<%=pidx%>_intf_ctrl_op_ways_stale_vec_p2       ;
    dmi<%=pidx%>_cache_op_ready_p0                 =      abc1.dmi<%=pidx%>_intf_cache_op_ready_p0                ;
    dmi<%=pidx%>_cache_valid_p2                    =      abc1.dmi<%=pidx%>_intf_cache_valid_p2                   ;
    dmi<%=pidx%>_cache_current_state_p2            =      abc1.dmi<%=pidx%>_intf_cache_current_state_p2           ;
    dmi<%=pidx%>_cache_alloc_way_vec_p2            =      abc1.dmi<%=pidx%>_intf_cache_alloc_way_vec_p2           ;
    dmi<%=pidx%>_cache_hit_way_vec_p2              =      abc1.dmi<%=pidx%>_intf_cache_hit_way_vec_p2             ;
    dmi<%=pidx%>_cache_evict_valid_p2              =      abc1.dmi<%=pidx%>_intf_cache_evict_valid_p2         ;
    dmi<%=pidx%>_cache_evict_address_p2            =      abc1.dmi<%=pidx%>_intf_cache_evict_address_p2       ;
    dmi<%=pidx%>_cache_evict_security_p2           =      abc1.dmi<%=pidx%>_intf_cache_evict_security_p2      ;
    dmi<%=pidx%>_cache_evict_state_p2              =      abc1.dmi<%=pidx%>_intf_cache_evict_state_p2         ;
    dmi<%=pidx%>_cache_nack_uce_p2                 =      abc1.dmi<%=pidx%>_intf_cache_nack_uce_p2            ;
    dmi<%=pidx%>_cache_nack_p2                     =      abc1.dmi<%=pidx%>_intf_cache_nack_p2               ;
    dmi<%=pidx%>_cache_nack_ce_p2                  =      abc1.dmi<%=pidx%>_intf_cache_nack_ce_p2            ;
    dmi<%=pidx%>_cache_nack_no_allocate_p2         =      abc1.dmi<%=pidx%>_intf_cache_nack_no_allocate_p2   ;
    dmi<%=pidx%>_ctrl_fill_valid                   =     abc1.dmi<%=pidx%>_intf_ctrl_fill_valid       ;
    dmi<%=pidx%>_ctrl_fill_address                 =     abc1.dmi<%=pidx%>_intf_ctrl_fill_address      ;
    dmi<%=pidx%>_ctrl_fill_way_num                 =     abc1.dmi<%=pidx%>_intf_ctrl_fill_way_num     ;
    dmi<%=pidx%>_ctrl_fill_state                   =     abc1.dmi<%=pidx%>_intf_ctrl_fill_state      ;
    dmi<%=pidx%>_ctrl_fill_security                =     abc1.dmi<%=pidx%>_intf_ctrl_fill_security  ;
    dmi<%=pidx%>_ctrl_fill_data                    =   abc1.dmi<%=pidx%>_intf_ctrl_fill_data               ;
    dmi<%=pidx%>_ctrl_fill_data_id                 =   abc1.dmi<%=pidx%>_intf_ctrl_fill_data_id            ;
    dmi<%=pidx%>_ctrl_fill_data_address            =   abc1.dmi<%=pidx%>_intf_ctrl_fill_data_address       ;
    dmi<%=pidx%>_ctrl_fill_data_way_num            =   abc1.dmi<%=pidx%>_intf_ctrl_fill_data_way_num       ;
    dmi<%=pidx%>_ctrl_fill_data_beat_num           =     abc1.dmi<%=pidx%>_intf_ctrl_fill_data_beat_num      ;
    dmi<%=pidx%>_ctrl_fill_data_byteen             =     abc1.dmi<%=pidx%>_intf_ctrl_fill_data_byteen        ;
    dmi<%=pidx%>_ctrl_fill_data_last               =     abc1.dmi<%=pidx%>_intf_ctrl_fill_data_last          ;
    dmi<%=pidx%>_cache_fill_data_ready             =     abc1.dmi<%=pidx%>_intf_cache_fill_data_ready        ;
    dmi<%=pidx%>_cache_fill_ready                  =     abc1.dmi<%=pidx%>_intf_cache_fill_ready             ;
    dmi<%=pidx%>_cache_fill_done                   =     abc1.dmi<%=pidx%>_intf_cache_fill_done              ;
    dmi<%=pidx%>_cache_fill_done_id                =     abc1.dmi<%=pidx%>_intf_cache_fill_done_id           ;
    dmi<%=pidx%>_ctrl_wr_valid                     =  abc1.dmi<%=pidx%>_intf_ctrl_wr_valid           ;
    dmi<%=pidx%>_ctrl_wr_data                      =  abc1.dmi<%=pidx%>_intf_ctrl_wr_data            ;
    dmi<%=pidx%>_ctrl_wr_byte_en                   =  abc1.dmi<%=pidx%>_intf_ctrl_wr_byte_en         ;
    dmi<%=pidx%>_ctrl_wr_beat_num                  =  abc1.dmi<%=pidx%>_intf_ctrl_wr_beat_num        ;
    dmi<%=pidx%>_ctrl_wr_last                      =  abc1.dmi<%=pidx%>_intf_ctrl_wr_last            ;
    dmi<%=pidx%>_cache_wr_ready                    =  abc1.dmi<%=pidx%>_intf_cache_wr_ready          ;
    dmi<%=pidx%>_cache_evict_ready                 =    abc1.dmi<%=pidx%>_intf_cache_evict_ready       ;
    dmi<%=pidx%>_cache_evict_valid                 =    abc1.dmi<%=pidx%>_intf_cache_evict_valid        ;
    dmi<%=pidx%>_cache_evict_data                  =    abc1.dmi<%=pidx%>_intf_cache_evict_data         ;
    dmi<%=pidx%>_cache_evict_byteen                =    abc1.dmi<%=pidx%>_intf_cache_evict_byteen       ;
    dmi<%=pidx%>_cache_evict_last                  =    abc1.dmi<%=pidx%>_intf_cache_evict_last         ;
    dmi<%=pidx%>_cache_evict_cancel                =    abc1.dmi<%=pidx%>_intf_cache_evict_cancel       ;
    dmi<%=pidx%>_cache_rdrsp_ready                 =    abc1.dmi<%=pidx%>_intf_cache_rdrsp_ready         ;
    dmi<%=pidx%>_cache_rdrsp_valid                 =    abc1.dmi<%=pidx%>_intf_cache_rdrsp_valid         ;
    dmi<%=pidx%>_cache_rdrsp_data                  =    abc1.dmi<%=pidx%>_intf_cache_rdrsp_data          ;
    dmi<%=pidx%>_cache_rdrsp_byteen                =    abc1.dmi<%=pidx%>_intf_cache_rdrsp_byteen        ;
    dmi<%=pidx%>_cache_rdrsp_last                  =    abc1.dmi<%=pidx%>_intf_cache_rdrsp_last          ;
    dmi<%=pidx%>_cache_rdrsp_cancel                =    abc1.dmi<%=pidx%>_intf_cache_rdrsp_cancel        ;
    dmi<%=pidx%>_maint_req_opcode                  =  abc1.dmi<%=pidx%>_intf_maint_req_opcode            ;                           
    dmi<%=pidx%>_maint_req_data                    =  abc1.dmi<%=pidx%>_intf_maint_req_data              ;
    dmi<%=pidx%>_maint_req_way                     =  abc1.dmi<%=pidx%>_intf_maint_req_way               ;
    dmi<%=pidx%>_maint_req_entry                   =  abc1.dmi<%=pidx%>_intf_maint_req_entry             ;
    dmi<%=pidx%>_maint_req_word                    =  abc1.dmi<%=pidx%>_intf_maint_req_word              ;
    dmi<%=pidx%>_maint_req_array_sel               =  abc1.dmi<%=pidx%>_intf_maint_req_array_sel          ;
    dmi<%=pidx%>_maint_active                      =   abc1.dmi<%=pidx%>_intf_maint_active             ;
    dmi<%=pidx%>_maint_read_data                   =   abc1.dmi<%=pidx%>_intf_maint_read_data          ;
    dmi<%=pidx%>_maint_read_data_en                =   abc1.dmi<%=pidx%>_intf_maint_read_data_en       ;
    dmi<%=pidx%>_is_replay                         =   abc1.dmi<%=pidx%>_intf_is_replay                ;
    dmi<%=pidx%>_to_replay                         =   abc1.dmi<%=pidx%>_intf_to_replay                ;
    dmi<%=pidx%>_recycle_valid                     =   abc1.dmi<%=pidx%>_intf_recycle_valid            ;
    
    dmi<%=pidx%>_ccp_p2_cm_type                    =   abc1.dmi<%=pidx%>_intf_ccp_p2_cm_type       ;
    dmi<%=pidx%>_ccp_p0_cm_type                    =   abc1.dmi<%=pidx%>_intf_ccp_p0_cm_type    ;
    dmi<%=pidx%>_ccp_p0_write_nc_sel               =  abc1.dmi<%=pidx%>_intf_ccp_p0_write_nc_sel    ;      
    dmi<%=pidx%>_ccp_p2_drop_hint                  =  abc1.dmi<%=pidx%>_intf_ccp_p2_drop_hint       ;   
    dmi<%=pidx%>_ccp_p2_mnt                        =  abc1.dmi<%=pidx%>_intf_ccp_p2_mnt             ; 
    dmi<%=pidx%>_replay_valid                      =  abc1.dmi<%=pidx%>_intf_replay_valid           ; 
<% if (obj.DmiInfo[pidx].ccpParams.useScratchpad) { %>
    dmi<%=pidx%>_scratch_rdrsp_valid        =   abc1.dmi<%=pidx%>_intf_scratch_rdrsp_valid        ;  
    dmi<%=pidx%>_scratch_rdrsp_data         =   abc1.dmi<%=pidx%>_intf_scratch_rdrsp_data         ;
    dmi<%=pidx%>_scratch_rdrsp_byteen       =   abc1.dmi<%=pidx%>_intf_scratch_rdrsp_byteen       ;
    dmi<%=pidx%>_scratch_rdrsp_last         =   abc1.dmi<%=pidx%>_intf_scratch_rdrsp_last         ;
    dmi<%=pidx%>_scratch_rdrsp_ready        =   abc1.dmi<%=pidx%>_intf_scratch_rdrsp_ready        ;
    dmi<%=pidx%>_scratch_rdrsp_cancel       =   abc1.dmi<%=pidx%>_intf_scratch_rdrsp_cancel       ;
    dmi<%=pidx%>_scratch_wr_valid           =  abc1.dmi<%=pidx%>_intf_scratch_wr_valid          ;    
    dmi<%=pidx%>_scratch_wr_data            =  abc1.dmi<%=pidx%>_intf_scratch_wr_data           ;  
    dmi<%=pidx%>_scratch_wr_byte_en         =  abc1.dmi<%=pidx%>_intf_scratch_wr_byte_en        ;  
    dmi<%=pidx%>_scratch_wr_beat_num        =  abc1.dmi<%=pidx%>_intf_scratch_wr_beat_num       ;  
    dmi<%=pidx%>_scratch_wr_last            =  abc1.dmi<%=pidx%>_intf_scratch_wr_last           ;  
    dmi<%=pidx%>_scratch_wr_ready           =  abc1.dmi<%=pidx%>_intf_scratch_wr_ready          ;  
    dmi<%=pidx%>_scratch_op_ready           =   abc1.dmi<%=pidx%>_intf_scratch_op_ready            ;
    dmi<%=pidx%>_scratch_op_valid           =   abc1.dmi<%=pidx%>_intf_scratch_op_valid            ;
    dmi<%=pidx%>_scratch_op_write_data      =   abc1.dmi<%=pidx%>_intf_scratch_op_write_data       ;
    dmi<%=pidx%>_scratch_op_read_data       =   abc1.dmi<%=pidx%>_intf_scratch_op_read_data        ;
    dmi<%=pidx%>_scratch_op_index_addr      =   abc1.dmi<%=pidx%>_intf_scratch_op_index_addr       ;
    dmi<%=pidx%>_scratch_op_way_num         =   abc1.dmi<%=pidx%>_intf_scratch_op_way_num          ;
    dmi<%=pidx%>_scratch_op_beat_num        =   abc1.dmi<%=pidx%>_intf_scratch_op_beat_num         ;
    dmi<%=pidx%>_scratch_op_burst_len       =   abc1.dmi<%=pidx%>_intf_scratch_op_burst_len        ;
    dmi<%=pidx%>_scratch_op_burst_wrap      =   abc1.dmi<%=pidx%>_intf_scratch_op_burst_wrap       ;
         <% } %>
       <% } %>
     <% } %>
<% } %>
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
    <%for(var i = 0; i < obj.DiiInfo[pidx].nSmiTx; i++) { %>
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_valid   =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_valid          ; 
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_ready   =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_ready            ;	
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp_len	   =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp_len ;         
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_dp_present  =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_dp_present;       
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_targ_id     =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_targ_id ;                
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_src_id      =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_src_id ;                
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_id      =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_id ;          
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_type	   =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_type ;               
<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_user = abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_user	; 
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_tier	=  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_tier   ;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_steer = abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_steer	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_pri = abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_pri	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_qos = abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_qos	; 
<% } %>
/* harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp= abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp	 ; */
    harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp= 0 ; //dummy since ndp_ndp is need to be checked with name
<%  if (obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
    harness_dii<%=pidx%>_smi_tx<%=i%>_dp_valid =  abc1.dii<%=pidx%>_smi_tx<%=i%>_dp_valid  ;  
    harness_dii<%=pidx%>_smi_tx<%=i%>_dp_ready =  abc1.dii<%=pidx%>_smi_tx<%=i%>_dp_ready  ;  
    harness_dii<%=pidx%>_smi_tx<%=i%>_dp_last  =  abc1.dii<%=pidx%>_smi_tx<%=i%>_dp_last   ;  
    harness_dii<%=pidx%>_smi_tx<%=i%>_dp_data  =  abc1.dii<%=pidx%>_smi_tx<%=i%>_dp_data   ;  
    harness_dii<%=pidx%>_smi_tx<%=i%>_dp_user  =  abc1.dii<%=pidx%>_smi_tx<%=i%>_dp_user   ;  
<%  }  %>
<% } %>
<%for(var i = 0; i < obj.DiiInfo[pidx].nSmiRx; i++) { %>
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_valid =   abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_valid ;	
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_ready   = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_ready ;                                      
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp_len	   = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp_len   ;                                      
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_dp_present  = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_dp_present;                                      
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_targ_id	   = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_targ_id   ;                                      
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_src_id	   = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_src_id    ;                                       
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_id      = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_id    ;                                       
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_type    = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_type  ;                                       
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_user = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_user	; 
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_tier	= abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_tier ;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_steer = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_steer	;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_pri = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_pri	;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
    harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_qos = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_qos	; 
<% } %>
/* harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp	; */
<%  if (obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
    harness_dii<%=pidx%>_smi_rx<%=i%>_dp_valid =   abc1.dii<%=pidx%>_smi_rx<%=i%>_dp_valid  	;  
    harness_dii<%=pidx%>_smi_rx<%=i%>_dp_ready =   abc1.dii<%=pidx%>_smi_rx<%=i%>_dp_ready	;  
    harness_dii<%=pidx%>_smi_rx<%=i%>_dp_last  =   abc1.dii<%=pidx%>_smi_rx<%=i%>_dp_last    ;  
    harness_dii<%=pidx%>_smi_rx<%=i%>_dp_data  =   abc1.dii<%=pidx%>_smi_rx<%=i%>_dp_data    ;  
    harness_dii<%=pidx%>_smi_rx<%=i%>_dp_user  =   abc1.dii<%=pidx%>_smi_rx<%=i%>_dp_user    ;  
<%  } %> 
<% } %>
<% } %>
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
//DCE
    dce<%=pidx%>_capb_paddr    =   abc1.dce<%=pidx%>_apb_paddr    ;
    dce<%=pidx%>_capb_pwrite   =   abc1.dce<%=pidx%>_apb_pwrite   ;
    dce<%=pidx%>_capb_psel     =   abc1.dce<%=pidx%>_apb_psel     ;
    dce<%=pidx%>_capb_penable  =   abc1.dce<%=pidx%>_apb_penable  ;
    dce<%=pidx%>_capb_prdata   =   abc1.dce<%=pidx%>_apb_prdata   ;
    dce<%=pidx%>_capb_pwdata   =   abc1.dce<%=pidx%>_apb_pwdata   ;
    dce<%=pidx%>_capb_pready   =   abc1.dce<%=pidx%>_apb_pready   ;
    dce<%=pidx%>_capb_pslverr  =   abc1.dce<%=pidx%>_apb_pslverr  ;
    u_dce_apb_if_<%=pidx%>.paddr   =   dce<%=pidx%>_capb_paddr  ; 
    u_dce_apb_if_<%=pidx%>.pwrite  =   dce<%=pidx%>_capb_pwrite ; 
    u_dce_apb_if_<%=pidx%>.psel    =   dce<%=pidx%>_capb_psel   ; 
    u_dce_apb_if_<%=pidx%>.penable =   dce<%=pidx%>_capb_penable; 
    u_dce_apb_if_<%=pidx%>.prdata  =   dce<%=pidx%>_capb_prdata ; 
    u_dce_apb_if_<%=pidx%>.pwdata  =   dce<%=pidx%>_capb_pwdata ; 
    u_dce_apb_if_<%=pidx%>.pready  =   dce<%=pidx%>_capb_pready ; 
    u_dce_apb_if_<%=pidx%>.pslverr =   dce<%=pidx%>_capb_pslverr; 
    <% } %>
    <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
    //DVE
    dve<%=pidx%>_capb_paddr       =   abc1.dve<%=pidx%>_apb_paddr     ;
    dve<%=pidx%>_capb_pwrite      =   abc1.dve<%=pidx%>_apb_pwrite    ;
    dve<%=pidx%>_capb_psel        =   abc1.dve<%=pidx%>_apb_psel      ;
    dve<%=pidx%>_capb_penable     =   abc1.dve<%=pidx%>_apb_penable   ;
    dve<%=pidx%>_capb_prdata      =   abc1.dve<%=pidx%>_apb_prdata    ;
    dve<%=pidx%>_capb_pwdata      =   abc1.dve<%=pidx%>_apb_pwdata    ;
    dve<%=pidx%>_capb_pready      =   abc1.dve<%=pidx%>_apb_pready    ;
    dve<%=pidx%>_capb_pslverr     =   abc1.dve<%=pidx%>_apb_pslverr   ;
    u_dve_apb_if_<%=pidx%>.paddr   =   dve<%=pidx%>_capb_paddr   ; 
    u_dve_apb_if_<%=pidx%>.pwrite  =   dve<%=pidx%>_capb_pwrite  ; 
    u_dve_apb_if_<%=pidx%>.psel    =   dve<%=pidx%>_capb_psel    ; 
    u_dve_apb_if_<%=pidx%>.penable =   dve<%=pidx%>_capb_penable ; 
    u_dve_apb_if_<%=pidx%>.prdata  =   dve<%=pidx%>_capb_prdata  ; 
    u_dve_apb_if_<%=pidx%>.pwdata  =   dve<%=pidx%>_capb_pwdata  ; 
    u_dve_apb_if_<%=pidx%>.pready  =   dve<%=pidx%>_capb_pready  ; 
    u_dve_apb_if_<%=pidx%>.pslverr =   dve<%=pidx%>_capb_pslverr ; 
<% } %>
    end
end

<% for(pidx = 0; pidx < obj.nDMIs; pidx++) {if(obj.DmiInfo[pidx].useCmc) { %>
    uvm_event  ev_inject_error_dmi<%=pidx%>_smc = uvm_event_pool::get_global("inject_error_dmi<%=pidx%>_smc");<%}}%>
    typedef bit [<%=wFunit*obj.nAIUs -1%>:0] aiu_funit_id_t;
    
    dii<%=sysdii_idx%>_apb_if  u_grb_apb_if( .clk(tb_clk),.rst_n(tb_rstn)); 
    //always@(*) begin
    /* u_grb_apb_if.paddr   <= `GRB.apb_paddr   ;
    u_grb_apb_if.pwrite  <= `GRB.apb_pwrite  ;
    u_grb_apb_if.psel    <= `GRB.apb_psel    ;
    u_grb_apb_if.penable <= `GRB.apb_penable ;
    u_grb_apb_if.prdata  <= `GRB.apb_prdata  ;
    u_grb_apb_if.pwdata  <= `GRB.apb_pwdata  ;
    u_grb_apb_if.pready  <= `GRB.apb_pready  ;
    u_grb_apb_if.pslverr <= `GRB.apb_pslverr ; */
    
    // end

<% for(var pidx = 0,qidx = 0; pidx < initiatorAgents; pidx++) { %>
    <%  if(_child_blk[pidx].match('chiaiu')) { %>
      <% var NSMIIFTX = obj.AiuInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
    <%=_child_blkid[pidx]%>_smi_if    <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if(tb_top.concerto_tb_aclk, tb_rstn, "<%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if");
      <% } %>
      <% var NSMIIFRX = obj.AiuInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
    <%=_child_blkid[pidx]%>_smi_if    <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if(tb_top.concerto_tb_aclk, tb_rstn, "<%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if");
      <% } %>
    dii<%=sysdii_idx%>_apb_if  u_chi_apb_if_<%=qidx%>( .clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn)); 
    <%for(var i = 0; i < obj.AiuInfo[pidx].nSmiTx; i++) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_valid       = 'h0 ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_ready       = 'h0 ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_ndp_len         = 'h0 ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_present      = 'h0 ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_targ_id         = 'h0 ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_src_id          = 'h0 ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_id          = 'h0 ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_type        = 'h0 ;

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0  ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_tier        = 'h0  ; 
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_steer           = 'h0	   ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_pri         = 'h0   ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wQos > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0   ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_ndp             = 'h0 	   ;

    <%  if (obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_last         = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_data         = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_user         = 'h0   ;  
    <%  } else {  %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0	      ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0	      ;  
    <%  }  %>

	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0	      ;  
    <% } %>


    <%for(var i = 0; i < obj.AiuInfo[pidx].nSmiRx; i++) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_valid       = 'h0   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_ready       = 'h0   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_ndp_len         = 'h0   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_present      = 'h0   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_targ_id         = 'h0   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_src_id          = 'h0   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_id          = 'h0   ;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_type        = 'h0   ;

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0  ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_tier        = 'h0  ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_steer           = 'h0   ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_pri         = 'h0  ;
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0   ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ;
<% } %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_ndp             = 'h0	   ;

    <%  if (obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_last         = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_data         = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_user         = 'h0   ;  
    <%  } else {  %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0	      ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0	      ;  
    <%  }  %>

	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0	      ;  
    <% } %>
      /*  always@(*) begin
	u_chi_apb_if_<%=qidx%>.paddr   <= abc1.<%=_child_blkid[pidx]%>_apb_paddr   ; //CHIAIU
	u_chi_apb_if_<%=qidx%>.pwrite  <= abc1.<%=_child_blkid[pidx]%>_apb_pwrite  ;
	u_chi_apb_if_<%=qidx%>.psel    <= abc1.<%=_child_blkid[pidx]%>_apb_psel    ;
	u_chi_apb_if_<%=qidx%>.penable <= abc1.<%=_child_blkid[pidx]%>_apb_penable ;
	u_chi_apb_if_<%=qidx%>.prdata  <= abc1.<%=_child_blkid[pidx]%>_apb_prdata  ;
	u_chi_apb_if_<%=qidx%>.pwdata  <= abc1.<%=_child_blkid[pidx]%>_apb_pwdata  ;
	u_chi_apb_if_<%=qidx%>.pready  <= abc1.<%=_child_blkid[pidx]%>_apb_pready  ;
	u_chi_apb_if_<%=qidx%>.pslverr <= abc1.<%=_child_blkid[pidx]%>_apb_pslverr ;
        end */
    <% qidx++; %>
   <% } %>
<% } %>

<% for(var pidx = 0,qidx = 0; pidx < initiatorAgents; pidx++) { %>
    <% if(obj.AiuInfo[pidx].useCache) { %>
      bit [<%=obj.AiuInfo[pidx].ccpParams.nWays%>-1:0]  <%=_child_blkid[pidx]%>_nru_counter;
    <% } %>
    <%  if(_child_blk[pidx].match('ioaiu')) { %>
      <% var NSMIIFTX = obj.AiuInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
    <%=_child_blkid[pidx]%>_smi_if    <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if(tb_top.concerto_tb_aclk, tb_rstn, "<%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if");
      <% } %>
      <% var NSMIIFRX = obj.AiuInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
    <%=_child_blkid[pidx]%>_smi_if    <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if(tb_top.concerto_tb_aclk, tb_rstn, "<%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if");
      <% } %>
    <% if(obj.AiuInfo[pidx].useCache) { %>
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
      <%=_child_blkid[pidx]%>_ccp_if  u_ioaiu_ccp_if_<%=qidx%>_<%=i%>( .clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn)); 
      <%=_child_blkid[pidx]%>_apb_if u_ioaiu_apb_if_<%=qidx%>_<%=i%>( .clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn));
    <% } //foreach interfacePorts%>
    <% } //if useCache%>
    <%=_child_blkid[pidx]%>_apb_if  u_ioaiu_apb_if_<%=qidx%>( .clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn));
    dii<%=sysdii_idx%>_apb_if  u_sysdii_ioaiu_apb_if_<%=qidx%>( .clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn)); 
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
    <%=_child_blkid[pidx]%>_axi_cmdreq_id_if u_axi_cmdreq_id_if<%=qidx%>_<%=i%>(.clk(tb_top.concerto_tb_aclk), .rst_n(tb_rstn));

    assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.w_pt_id           = 'h0;
    assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.n_mrc0_mid        = 'h0;
    assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.valid             = 'h0;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_req_valid     = 'h0;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_req_ready     = 'h0;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_req_msg_type  = 'h0;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_req_msg_id    = 'h0;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_req_target_id = 'h0;

        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_rsp_valid     = 'h0;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_rsp_ready     = 'h0;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_rsp_msg_type  = 'h0;
        assign u_axi_cmdreq_id_if<%=qidx%>_<%=i%>.cmd_rsp_r_msg_id  = 'h0 ;//`AIU<%=pidx%>.smi_rx<%=i%>_ndp_ndp[<%=obj.AiuInfo[pidx].concParams.cmdRspParams.wMsgId%>-1:0];
    <% } %>

	    <%for(var i = 0; i < obj.AiuInfo[pidx].nSmiTx; i++) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_valid       = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_ready       = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_ndp_len         = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_present      = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_targ_id         = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_src_id          = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_id          = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_type        = 'h0;

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0 ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_tier        = 'h0  ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_steer           = 'h0   ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_pri         = 'h0   ;  
<% } %>
<% if(obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0   ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_ndp             = 'h0	   ;

  <%  if (obj.AiuInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_last         = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_data         = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_user         = 'h0   ;  
    <%  } else {  %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0	      ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0	      ;  
    <%  }  %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0	      ;  
    <% } %>
    
     <%for(var i = 0; i < obj.AiuInfo[pidx].nSmiRx; i++) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_valid       = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_ready       = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_ndp_len         = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_present      = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_targ_id         = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_src_id          = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_id          = 'h0;
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_type        = 'h0;

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0  ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ;
<% } %>	    
<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_tier        = 'h0  ;  
<% } %>



<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_steer           = 'h0	   ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_pri         = 'h0   ;  
<% } %>

<% if(obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0)  { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0   ; 
<% } else { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_ndp             = 'h0	   ;


    <%  if (obj.AiuInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_last         = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_data         = 'h0   ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_user         = 'h0   ;  
    <%  } else {  %>
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0	      ;  
	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0	      ;  
    <%  }  %>

	assign <%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0	      ;  
    <% } %>


    <% if(obj.AiuInfo[pidx].useCache) { %>
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>

//CTRL channel

        assign <%=_child_blkid[pidx]%>_ccp_clk                    = 'h0;
        assign <%=_child_blkid[pidx]%>_ccp_rstn                   = 'h0;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.nru_counter      = <%=_child_blkid[pidx]%>_nru_counter;
        //Free Running Counter to mimic Eviction Counter in IO Cache.
        always @ (posedge <%=_child_blkid[pidx]%>_ccp_clk or negedge <%=_child_blkid[pidx]%>_ccp_rstn)
        begin
            if(~<%=_child_blkid[pidx]%>_ccp_rstn) begin
                <%=_child_blkid[pidx]%>_nru_counter <= '0;
            end else begin
                if(<%=_child_blkid[pidx]%>_nru_counter<(<%=obj.AiuInfo[pidx].ccpParams.nWays%>-1)) 
                    <%=_child_blkid[pidx]%>_nru_counter <= <%=_child_blkid[pidx]%>_nru_counter+1'b1;
                else 
                    <%=_child_blkid[pidx]%>_nru_counter <= '0;
            end
        end
 assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_vld           = 'h0         ;
 assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_addr          = 'h0         ;
      <% if (obj.wSecurityAttribute > 0) { %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_security      = 'h0       ;
        <%}else{%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_security      = 0              ;
        <%}%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_allocate      = 'h0;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_rd_data       = 'h0;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_wr_data       = 'h0;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_port_sel      = 'h0;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_bypass        = 'h0;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_rp_update     = 'h0;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_tagstateup    = 'h0;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_state         = 'h0;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_burstln       = 'h0;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_burstwrap     = 'h0 ;          
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_setway_debug  = 'h0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_waybusy_vec   = 'h0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_waystale_vec  = 'h0  ;
	assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_cancel        = 'h0;
	assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_lookup_p2     = 'h0;
//	assign u_ioaiu_ccp_if_<%=qidx%>.ctrlop_pt_id_p2      = (u_ioaiu_ccp_if_<%=qidx%>.isWrite_Wakeup ||
//                                                                u_ioaiu_ccp_if_<%=qidx%>.isRead_Wakeup  ||
//                                                                u_ioaiu_ccp_if_<%=qidx%>.isWrite        ||
//                                                                u_ioaiu_ccp_if_<%=qidx%>.isRead          ) ? `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_id :
//                                                                {`AIU<%=pidx%>.ioaiu_core.ioaiu_control.t_st_iid[`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_kid],`AIU<%=pidx%>.ioaiu_core.ioaiu_control.t_st_mid[`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_kid]}; 
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_pt_id_p2      = 'h0;
                                                               
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cacheop_rdy          = 'h0    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_vld            = 'h0    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.out_req_valid_p2     = 'h0    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_currentstate   = 'h0    ;

        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_alloc_wayn     = 'h0    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_hit_wayn       = 'h0    ;

        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cachectrl_evict_vld  = 'h0  ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_addr     = 'h0  ;

        <% if (obj.wSecurityAttribute > 0) { %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_security = 'h0    ;
        <%}else{%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_security = 0                                                           ;
        <%}%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_state    = 'h0  ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_nack_uce       = 'h0  ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_nack           = 'h0  ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_nack_ce        = 'h0  ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_nack_noalloc   = 'h0  ;

        


        //Fill CTRL Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_vld        = 'h0       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_fill_rdy       = 'h0       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_addr       = 'h0       ;
        <% if(obj.AiuInfo[pidx].ccpParams.nWays>1) { %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_wayn       = 'h0         ;
        <% }else{ %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_wayn       = 0                                                           ;
        <%}%>

        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_state      = 'h0           ;

        <% if (obj.wSecurityAttribute > 0) { %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_security   = 'h0       ;
        <%}else{%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_security   = 0                                                           ;
        <%}%>

 //Fill Data Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_vld    = 'h0   ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_scratchpad    = 'h0   ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_fill_data       = 'h0   ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_id     = 'h0   ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_last   = 'h0   ;

        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_byten  = 'h0    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_addr   = 'h0    ;


        <% if(obj.AiuInfo[pidx].ccpParams.nWays>1) { %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_wayn   = 'h0    ;
        <% }else{ %>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_wayn   = 0                                                           ;
        <%}%>
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_filldata_beatn  = 'h0   ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_filldata_rdy   = 'h0   ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_fill_done      = 'h0   ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_fill_done_id   = 'h0   ;

//WR Data Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_wr_vld          = 'h0       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_wr_data         = 'h0       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_wr_byte_en      = 'h0       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_wr_beat_num     = 'h0       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrl_wr_last         = 'h0       ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_wr_rdy         = 'h0       ;

//Evict Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_rdy      = 'h0        ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_vld      = 'h0        ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_data     = 'h0        ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_byten    = 'h0        ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_last     = 'h0        ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_evict_cancel   = 'h0        ;

//Read response Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_rdy      = 'h0    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_vld      = 'h0    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_data     = 'h0    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_byten    = 'h0    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_last     = 'h0    ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.cache_rdrsp_cancel   = 'h0    ;

//Mnt Channel
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_opcode     = 'h0        ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_data       = 'h0        ; // Was commented in IOAIU tb top
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_way        = 'h0        ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_entry      = 'h0        ;
 
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_word     = 'h0; //`AIU<%=pidx%>.ioaiu_core.ccp_top.maint_req_word             ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_req_array_sel  = 'h0; //`AIU<%=pidx%>.ioaiu_core.ccp_top.maint_req_array_sel        ; // was not present in IOAIU tb top

        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_active         = 'h0; //`AIU<%=pidx%>.ioaiu_core.ccp_top.maint_active               ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_read_data      = 'h0; //`AIU<%=pidx%>.ioaiu_core.ccp_top.maint_read_data            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_read_data_en   = 'h0; //`AIU<%=pidx%>.ioaiu_core.ccp_top.maint_read_data_en         ;

//Serialization Signal
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isRead               = 'h0; //`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_p2_valid  &&
					                                           //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_partial&&
					                                           //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_wake   &&
				                                               //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_write           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isWrite              = 'h0; // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_p2_valid  &&
                                                              ; //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_wake   &&
                                                              ; // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_write           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isSnoop              = 'h0; // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_p2_valid  &
                                                              ; //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_write  &
                                                              ; // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.t_pt_partial         ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isMntOp              = 'h0; //`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_maint;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isRead_Wakeup        = 'h0; // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_p2_valid  &&
                                                              ; // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_wake   &&
                                                              ; //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_write           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isWrite_Wakeup       = 'h0; // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_p2_valid  &&
                                                               // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_wake   &&
                                                               // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_write           ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.read_hit             = 'h0; // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_p2_valid   &
                                                               //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_write   &
                                                               //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.t_pt_partial &
                                                               // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_c2_chit            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.read_miss_allocate   = 'h0; // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_p2_valid   &
                                                               //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_write   &
                                                               //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.t_pt_partial &
                                                               //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_c2_chit    &
                                                               // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.cp2_alloc_o          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.write_hit            = 'h0; // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_p2_valid   &
                                                               // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_write   &
                                                               // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_c2_chit            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.write_miss_allocate  = 'h0; // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_p2_valid   &
                                                               // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_write   &
                                                               //(~| `AIU<%=pidx%>.ioaiu_core.ioaiu_control.cp2_hits_i)  &
                                                               //`AIU<%=pidx%>.ioaiu_core.ioaiu_control.cp2_alloc_o          ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.snoop_hit            = 'h0;// `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_p2_valid   &
                                                               //~`AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_write   &
                                                               // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.t_pt_partial &
                                                               // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_c2_chit            ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.write_hit_upgrade    = 'h0;// `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_p2_valid   &
                                                               // `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_pt_write   &
                                                               // (| `AIU<%=pidx%>.ioaiu_core.ioaiu_control.cp2_hits_i)  &
                                                               // (~& `AIU<%=pidx%>.ioaiu_core.ioaiu_control.w_c2_state)          ;

        //int unsigned current_index;
        //int unsigned prev_index;
        //logic  stale_vec_detected<%=pidx%>;

        //always @ (posedge <%=_child_blkid[pidx]%>_ccp_clk or negedge <%=_child_blkid[pidx]%>_ccp_rstn)
        //    if(~<%=_child_blkid[pidx]%>_ccp_rstn) begin 
        //        stale_vec_detected<%=pidx%> <= '0;
        //    end else begin
        //        //if(`AIU<%=pidx%>.ioaiu_core.ccp_top.cache_valid_p2 && `AIU<%=pidx%>.ioaiu_core.ccp_top.cache_nack_uce_p2) begin
        //        //    stale_vec_detected<%=pidx%> <= 1'b1; 
        //        //end else begin
        //            stale_vec_detected<%=pidx%> <= 1'b0;
        //        //end
        //    end
                     
                        
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.stale_vec_flag       = 'h0; //stale_vec_detected<%=pidx%> & (|`AIU<%=pidx%>.ioaiu_core.ccp_top.u_ccp.u_tagpipe.way_alloc_residue);
        // Assign zero to unused signal>s
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_vld         = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_data        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_byten       = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_last        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_rdy         = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_rdrsp_cancel      = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_vld            = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_data           = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_byte_en        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_beat_num       = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_last           = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_wr_rdy            = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_rdy            = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_vld            = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_wr_data        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_rd_data        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_index_addr     = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_data_bank      = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_way_num        = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_beat_num       = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_burst_len      = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.sp_op_burst_type     = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.ctrlop_retry         = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.fake_hit_way         = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.maint_wrdata         = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isRead_p1            = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isWrite_p1           = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isSnoop_p1           = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isMntOp_p1           = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isRead_Wakeup_p1     = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isWrite_Wakeup_p1    = 0 ;
        assign u_ioaiu_ccp_if_<%=qidx%>_<%=i%>.isSnoop_Wakeup_p1    = 0 ;
    <% } %>
    <% } %>

    <% qidx++; %>
   <% } %>
<% } %>

  <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
     <% if(obj.DmiInfo[pidx].useCmc) { %>
      bit [<%=obj.DmiInfo[pidx].ccpParams.nWays%>-1:0]  dmi<%=pidx%>_nru_counter;
      <% if(obj.DmiInfo[pidx].useWayPartitioning) { %>
         aiu_funit_id_t   dmi<%=pidx%>_aiu_funit_id;
      <% }  %>
     <% } %>

       dmi<%=pidx%>_rtl_if  u_dmi<%=pidx%>_rtl_if(.clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn));

  <%if (obj.DmiInfo[pidx].fnEnableQos) { %>   
      /*assign  u_dmi<%=pidx%>_rtl_if.cmd_starv_mode     =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.cmd_skid_buffer.starv_mode; 
      assign  u_dmi<%=pidx%>_rtl_if.mrd_starv_mode       =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.mrd_skid_buffer.starv_mode; */ 
      assign  u_dmi<%=pidx%>_rtl_if.cmd_starv_mode       =  dmi<%=pidx%>_c_cmd_starv_mode ;
      assign  u_dmi<%=pidx%>_rtl_if.mrd_starv_mode       =  dmi<%=pidx%>_c_mrd_starv_mode ;
  <% } %> 

        <% var NSMIIFTX = obj.DmiInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
       dmi<%=pidx%>_smi_if    dmi<%=pidx%>_port<%=i%>_tx_smi_if(tb_top.concerto_tb_aclk,tb_rstn, "dmi<%=pidx%>_port<%=i%>_tx_smi_if");
     
     <% } %>
     <% var NSMIIFRX = obj.DmiInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
       dmi<%=pidx%>_smi_if    dmi<%=pidx%>_port<%=i%>_rx_smi_if(tb_top.concerto_tb_aclk,tb_rstn, "dmi<%=pidx%>_port<%=i%>_rx_smi_if");
     <% } %>
     <% if(obj.DmiInfo[pidx].useCmc) { %>
       dmi<%=pidx%>_ccp_if  u_ccp_if_<%=pidx%>( .clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn)); 
       dmi<%=pidx%>_apb_if u_apb_if_<%=pidx%>( .clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn));
     <% } %>
       dii<%=sysdii_idx%>_apb_if u_dmi_apb_if_<%=pidx%>( .clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn)); 


    <%for(var i = 0; i < obj.DmiInfo[pidx].nSmiTx; i++) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_valid       = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_ready       = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp_len         = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_present      = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_targ_id         = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_src_id          = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_id          = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_type        = 'h0  ;

     
<% if(obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0	; 
<% } else { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_tier        = 'h0	;  
<% } %>

<% if(obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_steer           = 'h0	;  
<% } %>

<% if(obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_pri         = 'h0	;  
<% } %>

<% if(obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0	;
<% } else { %>
        assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ;
<% } %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp             = 'h0	;

    <%  if (obj.DmiInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'h0  ;  
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'h0  ;  
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_last         = 'h0  ;  
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_data         = 'h0  ;  
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_user         = 'h0  ;  
    <%  } else {  %>
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0      ;  
    <%  }  %>

	assign dmi<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>
    
    <%for(var i = 0; i < obj.DmiInfo[pidx].nSmiRx; i++) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_valid       = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_ready       = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp_len         = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_present      = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_targ_id         = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_src_id          = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_id          = 'h0  ;
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_type        = 'h0  ;

<% if(obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0  ; 
<% } else { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_tier        = 'h0 ;  
<% } %>

<% if(obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_steer           = 'h0     ;
<% } %>

<% if(obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_pri         = 'h0   ;
<% } %>

  
<% if(obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0   ; 
<% } else { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp             = 'h0       ;

    <%  if (obj.DmiInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'h0  ;  
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'h0  ;  
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_last         = 'h0  ;  
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_data         = 'h0  ;  
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_user         = 'h0  ;  
    <%  } else {  %>
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0      ;  
    <%  }  %>

     
	assign dmi<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>

<% if(obj.DmiInfo[pidx].useCmc) { %>
        //CTRL channel
        assign dmi<%=pidx%>_ccp_clk                    = tb_top.concerto_tb_aclk;
        assign dmi<%=pidx%>_ccp_rstn                   = tb_rstn;
        assign u_ccp_if_<%=pidx%>.ctrlop_vld           = dmi<%=pidx%>_ctrl_op_valid_p0;
        assign u_ccp_if_<%=pidx%>.ctrlop_addr          = dmi<%=pidx%>_ctrl_op_address_p0;
<% if(obj.wSecurityAttribute) { %>
        assign u_ccp_if_<%=pidx%>.ctrlop_security      = dmi<%=pidx%>_ctrl_op_security_p0        ;
<% } else { %>
        assign u_ccp_if_<%=pidx%>.ctrlop_security      = 0  ;
<% } %>
        assign u_ccp_if_<%=pidx%>.ctrlop_allocate      = dmi<%=pidx%>_ctrl_op_allocate_p2        ;
        assign u_ccp_if_<%=pidx%>.ctrlop_rd_data       = dmi<%=pidx%>_ctrl_op_read_data_p2       ;
        assign u_ccp_if_<%=pidx%>.ctrlop_wr_data       = dmi<%=pidx%>_ctrl_op_write_data_p2      ;
        assign u_ccp_if_<%=pidx%>.ctrlop_port_sel      = dmi<%=pidx%>_ctrl_op_port_sel_p2        ;
        assign u_ccp_if_<%=pidx%>.ctrlop_bypass        = dmi<%=pidx%>_ctrl_op_bypass_p2          ;
        assign u_ccp_if_<%=pidx%>.ctrlop_rp_update     = dmi<%=pidx%>_ctrl_op_rp_update_p2       ;
        assign u_ccp_if_<%=pidx%>.ctrlop_tagstateup    = dmi<%=pidx%>_ctrl_op_tag_state_update_p2;
        assign u_ccp_if_<%=pidx%>.ctrlop_state         = dmi<%=pidx%>_ctrl_op_state_p2           ;
        assign u_ccp_if_<%=pidx%>.ctrlop_burstln       = dmi<%=pidx%>_ctrl_op_burst_len_p2       ;
        assign u_ccp_if_<%=pidx%>.ctrlop_burstwrap     = dmi<%=pidx%>_ctrl_op_burst_wrap_p2      ;
        assign u_ccp_if_<%=pidx%>.ctrlop_setway_debug  = dmi<%=pidx%>_ctrl_op_setway_debug_p2    ;
        assign u_ccp_if_<%=pidx%>.ctrlop_waybusy_vec   = dmi<%=pidx%>_ctrl_op_ways_busy_vec_p2   ;
        assign u_ccp_if_<%=pidx%>.ctrlop_waystale_vec  = dmi<%=pidx%>_ctrl_op_ways_stale_vec_p2  ;


        assign u_ccp_if_<%=pidx%>.cacheop_rdy          = dmi<%=pidx%>_cache_op_ready_p0          ;
        assign u_ccp_if_<%=pidx%>.cache_vld            = dmi<%=pidx%>_cache_valid_p2             ;
        assign u_ccp_if_<%=pidx%>.cache_currentstate   = dmi<%=pidx%>_cache_current_state_p2     ;
     <% if(obj.DmiInfo[pidx].ccpParams.nWays>1) { %>
        assign u_ccp_if_<%=pidx%>.cache_alloc_wayn     = dmi<%=pidx%>_cache_alloc_way_vec_p2 ;
        assign u_ccp_if_<%=pidx%>.cache_hit_wayn       = dmi<%=pidx%>_cache_hit_way_vec_p2 ;
     <% } %>
        assign u_ccp_if_<%=pidx%>.cachectrl_evict_vld  = dmi<%=pidx%>_cache_evict_valid_p2       ;
        assign u_ccp_if_<%=pidx%>.cache_evict_addr     = dmi<%=pidx%>_cache_evict_address_p2     ;
<% if(obj.wSecurityAttribute) { %>
        assign u_ccp_if_<%=pidx%>.cache_evict_security = dmi<%=pidx%>_cache_evict_security_p2    ;
<% } else { %>
        assign u_ccp_if_<%=pidx%>.cache_evict_security = 0  ;
<% } %>
        assign u_ccp_if_<%=pidx%>.cache_evict_state    = dmi<%=pidx%>_cache_evict_state_p2       ;
        assign u_ccp_if_<%=pidx%>.cache_nack_uce       = dmi<%=pidx%>_cache_nack_uce_p2          ;
        assign u_ccp_if_<%=pidx%>.cache_nack           = dmi<%=pidx%>_cache_nack_p2              ;
        assign u_ccp_if_<%=pidx%>.cache_nack_ce        = dmi<%=pidx%>_cache_nack_ce_p2           ;
        assign u_ccp_if_<%=pidx%>.cache_nack_noalloc   = dmi<%=pidx%>_cache_nack_no_allocate_p2  ;

     
//WR Data Channel
        assign u_ccp_if_<%=pidx%>.ctrl_wr_vld          =  dmi<%=pidx%>_ctrl_wr_valid              ;
        assign u_ccp_if_<%=pidx%>.ctrl_wr_data         =  dmi<%=pidx%>_ctrl_wr_data               ;
        assign u_ccp_if_<%=pidx%>.ctrl_wr_byte_en      =  dmi<%=pidx%>_ctrl_wr_byte_en            ;
        assign u_ccp_if_<%=pidx%>.ctrl_wr_beat_num     =  dmi<%=pidx%>_ctrl_wr_beat_num           ;
        assign u_ccp_if_<%=pidx%>.ctrl_wr_last         =  dmi<%=pidx%>_ctrl_wr_last               ;
        assign u_ccp_if_<%=pidx%>.cache_wr_rdy         =  dmi<%=pidx%>_cache_wr_ready             ;

//Evict Channel
        assign u_ccp_if_<%=pidx%>.cache_evict_rdy      = dmi<%=pidx%>_cache_evict_ready          ;
        assign u_ccp_if_<%=pidx%>.cache_evict_vld      = dmi<%=pidx%>_cache_evict_valid          ;
        assign u_ccp_if_<%=pidx%>.cache_evict_data     = dmi<%=pidx%>_cache_evict_data           ;
        assign u_ccp_if_<%=pidx%>.cache_evict_byten    = dmi<%=pidx%>_cache_evict_byteen         ;
        assign u_ccp_if_<%=pidx%>.cache_evict_last     = dmi<%=pidx%>_cache_evict_last           ;
        assign u_ccp_if_<%=pidx%>.cache_evict_cancel   = dmi<%=pidx%>_cache_evict_cancel         ;

//Read response Channel
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_rdy      = dmi<%=pidx%>_cache_rdrsp_ready          ;
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_vld      = dmi<%=pidx%>_cache_rdrsp_valid          ;
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_data     = dmi<%=pidx%>_cache_rdrsp_data           ;
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_byten    = dmi<%=pidx%>_cache_rdrsp_byteen         ;
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_last     = dmi<%=pidx%>_cache_rdrsp_last           ;
        assign u_ccp_if_<%=pidx%>.cache_rdrsp_cancel   = dmi<%=pidx%>_cache_rdrsp_cancel         ;
//Mnt Channel
        assign u_ccp_if_<%=pidx%>.maint_req_opcode     = dmi<%=pidx%>_maint_req_opcode           ;
        assign u_ccp_if_<%=pidx%>.maint_wrdata         = dmi<%=pidx%>_maint_req_data             ;
     <% if(obj.DmiInfo[pidx].ccpParams.nWays>1) { %>
        assign u_ccp_if_<%=pidx%>.maint_req_way        = dmi<%=pidx%>_maint_req_way              ;
     <% } %>
        assign u_ccp_if_<%=pidx%>.maint_req_entry      = dmi<%=pidx%>_maint_req_entry            ;
        assign u_ccp_if_<%=pidx%>.maint_req_word       = dmi<%=pidx%>_maint_req_word             ;
        assign u_ccp_if_<%=pidx%>.maint_req_array_sel  = dmi<%=pidx%>_maint_req_array_sel        ;

        assign u_ccp_if_<%=pidx%>.maint_active         = dmi<%=pidx%>_maint_active               ;
        assign u_ccp_if_<%=pidx%>.maint_read_data      = dmi<%=pidx%>_maint_read_data            ;
        assign u_ccp_if_<%=pidx%>.maint_read_data_en   = dmi<%=pidx%>_maint_read_data_en         ;
        assign u_ccp_if_<%=pidx%>.isReplay             = dmi<%=pidx%>_is_replay    ;
        assign u_ccp_if_<%=pidx%>.toReplay             = dmi<%=pidx%>_to_replay    ;
        assign u_ccp_if_<%=pidx%>.isRecycle            = dmi<%=pidx%>_recycle_valid;
        assign u_ccp_if_<%=pidx%>.msgType_p2           = dmi<%=pidx%>_ccp_p2_cm_type   ;
        assign u_ccp_if_<%=pidx%>.msgType_p0           = dmi<%=pidx%>_ccp_p0_cm_type   ;
        assign u_ccp_if_<%=pidx%>.msgType_p1           = dmi<%=pidx%>_ccp_p1_cm_type   ;
        assign u_ccp_if_<%=pidx%>.isCoh_p0             = dmi<%=pidx%>_ccp_p0_write_nc_sel;
        assign u_ccp_if_<%=pidx%>.isMntOp              = dmi<%=pidx%>_ccp_p2_mnt;
        assign u_ccp_if_<%=pidx%>.isRply_vld_p0        = dmi<%=pidx%>_replay_valid;

// ScratchPad signals
<% if (obj.DmiInfo[pidx].ccpParams.useScratchpad) { %>
           assign u_ccp_if_<%=pidx%>.sp_rdrsp_vld         = dmi<%=pidx%>_scratch_rdrsp_valid        ;
        assign u_ccp_if_<%=pidx%>.sp_rdrsp_data        = dmi<%=pidx%>_scratch_rdrsp_data         ;
        assign u_ccp_if_<%=pidx%>.sp_rdrsp_byten       = dmi<%=pidx%>_scratch_rdrsp_byteen       ;
        assign u_ccp_if_<%=pidx%>.sp_rdrsp_last        = dmi<%=pidx%>_scratch_rdrsp_last         ;
        assign u_ccp_if_<%=pidx%>.sp_rdrsp_rdy         = dmi<%=pidx%>_scratch_rdrsp_ready        ;
        assign u_ccp_if_<%=pidx%>.sp_rdrsp_cancel      = dmi<%=pidx%>_scratch_rdrsp_cancel       ;
        
        assign u_ccp_if_<%=pidx%>.sp_wr_vld            = dmi<%=pidx%>_scratch_wr_valid           ;
        assign u_ccp_if_<%=pidx%>.sp_wr_data           = dmi<%=pidx%>_scratch_wr_data            ;
        assign u_ccp_if_<%=pidx%>.sp_wr_byte_en        = dmi<%=pidx%>_scratch_wr_byte_en         ;
        assign u_ccp_if_<%=pidx%>.sp_wr_beat_num       = dmi<%=pidx%>_scratch_wr_beat_num        ;
        assign u_ccp_if_<%=pidx%>.sp_wr_last           = dmi<%=pidx%>_scratch_wr_last            ;
        assign u_ccp_if_<%=pidx%>.sp_wr_rdy            = dmi<%=pidx%>_scratch_wr_ready           ;
        
        assign u_ccp_if_<%=pidx%>.sp_op_rdy            = dmi<%=pidx%>_scratch_op_ready           ;
        assign u_ccp_if_<%=pidx%>.sp_op_vld            = dmi<%=pidx%>_scratch_op_valid           ;
        assign u_ccp_if_<%=pidx%>.sp_op_wr_data        = dmi<%=pidx%>_scratch_op_write_data      ;
        assign u_ccp_if_<%=pidx%>.sp_op_rd_data        = dmi<%=pidx%>_scratch_op_read_data       ;
        assign u_ccp_if_<%=pidx%>.sp_op_index_addr     = dmi<%=pidx%>_scratch_op_index_addr      ;
        assign u_ccp_if_<%=pidx%>.sp_op_way_num        = dmi<%=pidx%>_scratch_op_way_num         ;
        assign u_ccp_if_<%=pidx%>.sp_op_beat_num       = dmi<%=pidx%>_scratch_op_beat_num        ;
        assign u_ccp_if_<%=pidx%>.sp_op_burst_len      = dmi<%=pidx%>_scratch_op_burst_len       ;
        assign u_ccp_if_<%=pidx%>.sp_op_burst_type     = dmi<%=pidx%>_scratch_op_burst_wrap      ;
<% } %>

       assign u_ccp_if_<%=pidx%>.nru_counter = dmi<%=pidx%>_nru_counter;
       
       always @ (posedge tb_top.concerto_tb_aclk or negedge tb_rstn)
       begin
           if(~dmi<%=pidx%>_ccp_rstn) begin
               dmi<%=pidx%>_nru_counter <= '0;
           end else begin
               if(dmi<%=pidx%>_nru_counter<(<%=obj.DmiInfo[pidx].ccpParams.nWays%>-1)) 
                   dmi<%=pidx%>_nru_counter <= dmi<%=pidx%>_nru_counter+1'b1;
               else 
                   dmi<%=pidx%>_nru_counter <= '0;
           end
       end
<% } %>

   /*     always@(*) begin   //moved to always block above
	u_dmi_apb_if_<%=pidx%>.paddr   <= abc1.dmi<%=pidx%>_apb_paddr   ;
	u_dmi_apb_if_<%=pidx%>.pwrite  <= abc1.dmi<%=pidx%>_apb_pwrite  ;
	u_dmi_apb_if_<%=pidx%>.psel    <= abc1.dmi<%=pidx%>_apb_psel    ;
	u_dmi_apb_if_<%=pidx%>.penable <= abc1.dmi<%=pidx%>_apb_penable ;
	u_dmi_apb_if_<%=pidx%>.prdata  <= abc1.dmi<%=pidx%>_apb_prdata  ;
	u_dmi_apb_if_<%=pidx%>.pwdata  <= abc1.dmi<%=pidx%>_apb_pwdata  ;
	u_dmi_apb_if_<%=pidx%>.pready  <= abc1.dmi<%=pidx%>_apb_pready  ;
	u_dmi_apb_if_<%=pidx%>.pslverr <= abc1.dmi<%=pidx%>_apb_pslverr ;
        end */

    /*  assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_valid   =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_cmd_resp_buffer_push_valid; 
      assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_ready   =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_cmd_resp_buffer_push_ready; 
      assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_rmsg_id =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_cmd_resp_buffer_push_r_message_id[<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0];
      assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_targ_id =  `DMI<%=pidx%>.dmi_unit.dmi_protocol_control.nc_cmd_resp_buffer_push_target_id[<%=obj.DmiInfo[pidx].wFUnitId+obj.DmiInfo[pidx].wFPortId-1%>:<%=obj.DmiInfo[pidx].wFPortId%>];  */
      assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_valid   = dmi<%=pidx%>_c_cmd_rsp_push_valid ;    
      assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_ready   = dmi<%=pidx%>_c_cmd_rsp_push_ready ;    
      assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_rmsg_id = dmi<%=pidx%>_c_cmd_rsp_push_rmsg_id;   
      assign  u_dmi<%=pidx%>_rtl_if.cmd_rsp_push_targ_id = dmi<%=pidx%>_c_cmd_rsp_push_targ_id ;   
<% } %>
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
     <% var NSMIIFTX = obj.DceInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
       dce<%=pidx%>_smi_if    dce<%=pidx%>_port<%=i%>_tx_smi_if(tb_top.concerto_tb_aclk,tb_rstn, "dce<%=pidx%>_port<%=i%>_tx_smi_if");
     <% } %>
     <% var NSMIIFRX = obj.DceInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
       dce<%=pidx%>_smi_if    dce<%=pidx%>_port<%=i%>_rx_smi_if(tb_top.concerto_tb_aclk,tb_rstn, "dce<%=pidx%>_port<%=i%>_rx_smi_if");
     <% } %>
       dii<%=sysdii_idx%>_apb_if  u_dce_apb_if_<%=pidx%>( .clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn)); 

    <%for(var i = 0; i < obj.DceInfo[pidx].nSmiTx; i++) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_valid       = 'h0 ;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_ready       = 'h0 ;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp_len         = 'h0 ;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_present      = 'h0 ;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_targ_id         = 'h0 ;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_src_id          = 'h0 ;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_id          = 'h0 ;
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_type        = 'h0 ;

<% if(obj.DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0	; 
<% } else { %>
    	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_tier        = 'h0	;  
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_steer           = 'h0	;  
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_pri         = 'h0	;  
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0	; 
<% } else { %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp             = 'h0	;

	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0      ;  

	assign dce<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>
    
    <%for(var i = 0; i < obj.DceInfo[pidx].nSmiRx; i++) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_valid       = 'h0;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_ready       = 'h0;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp_len         = 'h0;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_present      = 'h0;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_targ_id         = 'h0;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_src_id          = 'h0;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_id          = 'h0;
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_type        = 'h0;

<% if(obj.DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0   ; 
<% } else { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_tier        = 'h0  ;  
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_steer           = 'h0     ;
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_pri         = 'h0   ;
<% } %>

<% if(obj.DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0   ; 
<% } else { %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp             = 'h0      ;

	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0      ;  

	assign dce<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>

      //  always@(*) begin
      //  u_dce_apb_if_<%=pidx%>.paddr   <= abc1.dce<%=pidx%>_apb_paddr   ;
      //  u_dce_apb_if_<%=pidx%>.pwrite  <= abc1.dce<%=pidx%>_apb_pwrite  ;
      //  u_dce_apb_if_<%=pidx%>.psel    <= abc1.dce<%=pidx%>_apb_psel    ;
      //  u_dce_apb_if_<%=pidx%>.penable <= abc1.dce<%=pidx%>_apb_penable ;
      //  u_dce_apb_if_<%=pidx%>.prdata  <= abc1.dce<%=pidx%>_apb_prdata  ;
      //  u_dce_apb_if_<%=pidx%>.pwdata  <= abc1.dce<%=pidx%>_apb_pwdata  ;
      //  u_dce_apb_if_<%=pidx%>.pready  <= abc1.dce<%=pidx%>_apb_pready  ;
      //  u_dce_apb_if_<%=pidx%>.pslverr <= abc1.dce<%=pidx%>_apb_pslverr ;
      //  end 
<% } %>


<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
     <% if (obj.DiiInfo[pidx].configuration == 1) { %>  					       
      dii<%=pidx%>_axi_if      m_dii<%=pidx%>_axi_slv_if(tb_top.concerto_tb_aclk, tb_rstn);
      dii<%=pidx%>_dii_rtl_if  m_dii_rtl_if<%=pidx%>(tb_top.concerto_tb_aclk, tb_rstn);
     <% }%>
     <% var NSMIIFTX = obj.DiiInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
      dii<%=pidx%>_smi_if    dii<%=pidx%>_port<%=i%>_tx_smi_if(tb_top.concerto_tb_aclk, tb_rstn, "dii<%=pidx%>_port<%=i%>_tx_smi_if");
     <% } %>
     <% var NSMIIFRX = obj.DiiInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
       dii<%=pidx%>_smi_if   dii<%=pidx%>_port<%=i%>_rx_smi_if(tb_top.concerto_tb_aclk, tb_rstn, "dii<%=pidx%>_port<%=i%>_rx_smi_if");
     <% } %>
       dii<%=sysdii_idx%>_apb_if  u_dii_apb_if_<%=pidx%>( .clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn)); 

     <% if (obj.DiiInfo[pidx].configuration == 1) { %>  					       
               assign m_dii<%=pidx%>_axi_slv_if.awready    = dii<%=sysdii_idx%>_c_awready     ;
               assign m_dii<%=pidx%>_axi_slv_if.awvalid    = dii<%=sysdii_idx%>_c_awvalid     ;
               assign m_dii<%=pidx%>_axi_slv_if.awid       = dii<%=sysdii_idx%>_c_awid        ;
               assign m_dii<%=pidx%>_axi_slv_if.awaddr     = dii<%=sysdii_idx%>_c_awaddr      ;
               assign m_dii<%=pidx%>_axi_slv_if.awburst    = dii<%=sysdii_idx%>_c_awburst     ;
               assign m_dii<%=pidx%>_axi_slv_if.awlen      = dii<%=sysdii_idx%>_c_awlen       ;
               assign m_dii<%=pidx%>_axi_slv_if.awlock     = dii<%=sysdii_idx%>_c_awlock      ;
               assign m_dii<%=pidx%>_axi_slv_if.awprot     = dii<%=sysdii_idx%>_c_awprot      ;
               assign m_dii<%=pidx%>_axi_slv_if.awsize     = dii<%=sysdii_idx%>_c_awsize      ;
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wQos > 0) { %>        
               assign m_dii<%=pidx%>_axi_slv_if.awqos      = dii<%=sysdii_idx%>_c_awqos       ;
<%     } %>
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wRegion > 0) { %>
               assign m_dii<%=pidx%>_axi_slv_if.awregion   = dii<%=sysdii_idx%>_c_awregion    ;
<%     } %>
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wAwUser > 0) { %>
               assign m_dii<%=pidx%>_axi_slv_if.awuser     = dii<%=sysdii_idx%>_c_awuser      ;
<%     } else { %>
               assign m_dii<%=pidx%>_axi_slv_if.awuser     = 'h0                            ;
<%     } %>
               assign m_dii<%=pidx%>_axi_slv_if.awcache    = dii<%=sysdii_idx%>_c_awcache   ;
               assign m_dii<%=pidx%>_axi_slv_if.wready     = dii<%=sysdii_idx%>_c_wready   ;
               assign m_dii<%=pidx%>_axi_slv_if.wvalid     = dii<%=sysdii_idx%>_c_wvalid    ;
               assign m_dii<%=pidx%>_axi_slv_if.wdata      = dii<%=sysdii_idx%>_c_wdata    ;
               assign m_dii<%=pidx%>_axi_slv_if.wlast      = dii<%=sysdii_idx%>_c_wlast    ;
               assign m_dii<%=pidx%>_axi_slv_if.wstrb      = dii<%=sysdii_idx%>_c_wstrb    ;
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wWUser > 0) { %>
               assign m_dii<%=pidx%>_axi_slv_if.wuser      = dii<%=sysdii_idx%>_c_wuser       ;
<%     } else { %>
               assign m_dii<%=pidx%>_axi_slv_if.wuser      = 'h0                            ;
<%     } %>
               assign m_dii<%=pidx%>_axi_slv_if.bready     =  dii<%=sysdii_idx%>_c_bready      ;
               assign m_dii<%=pidx%>_axi_slv_if.bvalid     =  dii<%=sysdii_idx%>_c_bvalid     ;
               assign m_dii<%=pidx%>_axi_slv_if.bid        =  dii<%=sysdii_idx%>_c_bid        ;
               assign m_dii<%=pidx%>_axi_slv_if.bresp      =  dii<%=sysdii_idx%>_c_bresp      ;
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wBUser > 0) { %>
               assign m_dii<%=pidx%>_axi_slv_if.buser      = dii<%=sysdii_idx%>_c_buser      ;
<%     } else { %>
               assign m_dii<%=pidx%>_axi_slv_if.buser      = 'h0                            ;
<%     } %>
               assign m_dii<%=pidx%>_axi_slv_if.arready    = dii<%=sysdii_idx%>_c_arready     ;
               assign m_dii<%=pidx%>_axi_slv_if.arvalid    = dii<%=sysdii_idx%>_c_arvalid     ;
               assign m_dii<%=pidx%>_axi_slv_if.araddr     = dii<%=sysdii_idx%>_c_araddr     ;
               assign m_dii<%=pidx%>_axi_slv_if.arburst    = dii<%=sysdii_idx%>_c_arburst    ;
               assign m_dii<%=pidx%>_axi_slv_if.arid       = dii<%=sysdii_idx%>_c_arid       ;
               assign m_dii<%=pidx%>_axi_slv_if.arlen      = dii<%=sysdii_idx%>_c_arlen      ;
               assign m_dii<%=pidx%>_axi_slv_if.arlock     = dii<%=sysdii_idx%>_c_arlock     ;
               assign m_dii<%=pidx%>_axi_slv_if.arprot     = dii<%=sysdii_idx%>_c_arprot     ;
               assign m_dii<%=pidx%>_axi_slv_if.arsize     = dii<%=sysdii_idx%>_c_arsize     ;
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wQos) { %>        
               assign m_dii<%=pidx%>_axi_slv_if.arqos      = dii<%=sysdii_idx%>_c_arqos       ;
<%     } %>
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wRegion) { %>
               assign m_dii<%=pidx%>_axi_slv_if.arregion   = dii<%=sysdii_idx%>_c_arregion    ;
<%     } %>
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wArUser > 0) {%>
               assign m_dii<%=pidx%>_axi_slv_if.aruser     = dii<%=sysdii_idx%>_c_aruser      ;
<%     } else { %>
               assign m_dii<%=pidx%>_axi_slv_if.aruser     = 'h0                            ;
<%     } %>
               assign m_dii<%=pidx%>_axi_slv_if.arcache    = dii<%=sysdii_idx%>_c_arcache  ;
               assign m_dii<%=pidx%>_axi_slv_if.rready     = dii<%=sysdii_idx%>_c_rready  ;
               assign m_dii<%=pidx%>_axi_slv_if.rid        = dii<%=sysdii_idx%>_c_rid     ;
               assign m_dii<%=pidx%>_axi_slv_if.rresp      = {2'b0,dii<%=sysdii_idx%>_c_rresp};
               assign m_dii<%=pidx%>_axi_slv_if.rvalid     = dii<%=sysdii_idx%>_c_rvalid      ;
               assign m_dii<%=pidx%>_axi_slv_if.rdata      = dii<%=sysdii_idx%>_c_rdata       ;
               assign m_dii<%=pidx%>_axi_slv_if.rlast      = dii<%=sysdii_idx%>_c_rlast        ;
<%     if (obj.DiiInfo[pidx].interfaces.axiInt.params.wRUser > 0) {%>
               assign m_dii<%=pidx%>_axi_slv_if.ruser      = dii<%=sysdii_idx%>_c_ruser       ;
<%     } else { %>
               assign m_dii<%=pidx%>_axi_slv_if.ruser      = 'h0                            ;
<%     } %>
               
<%  } %> 

      //=========================================================== Local Regs for Dii Smi ===============================================

/*      <%for(var i = 0; i < obj.DiiInfo[pidx].nSmiTx; i++) { %>
 
         dii<%=pidx%>_harness_smi_msg_valid_logic_t      harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_valid; 
         dii<%=pidx%>_harness_smi_msg_ready_logic_t 	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_ready ;	
         dii<%=pidx%>_harness_smi_ndp_len_logic_t   	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp_len	;
         dii<%=pidx%>_harness_smi_dp_present_logic_t	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_dp_present;
         dii<%=pidx%>_harness_smi_targ_id_logic_t   	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_targ_id	;
         dii<%=pidx%>_harness_smi_src_id_logic_t    	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_src_id	;
         dii<%=pidx%>_harness_smi_msg_id_logic_t    	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_id	;
         dii<%=pidx%>_harness_smi_msg_type_logic_t  	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_type	;

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
      dii<%=pidx%>_harness_smi_msg_user_logic_t	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_user	; 
<% }  %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
    dii<%=pidx%>_harness_smi_msg_tier_logic_t harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_tier	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	dii<%=pidx%>_harness_smi_steer_logic_t harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_steer	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	dii<%=pidx%>_harness_smi_msg_pri_logic_t harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_pri	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
       dii<%=pidx%>_harness_smi_msg_qos_logic_t harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_qos	; 
<% } %>
       dii<%=pidx%>_harness_smi_ndp_logic_t	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp 	;
    <%  if (obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
     dii<%=pidx%>_harness_smi_dp_valid_bit_t	        harness_dii<%=pidx%>_smi_tx<%=i%>_dp_valid   ;  
     dii<%=pidx%>_harness_smi_dp_ready_bit_t	        harness_dii<%=pidx%>_smi_tx<%=i%>_dp_ready   ;  
     dii<%=pidx%>_harness_smi_dp_last_bit_t	        harness_dii<%=pidx%>_smi_tx<%=i%>_dp_last    ;  
     dii<%=pidx%>_harness_smi_dp_data_logic_t	        harness_dii<%=pidx%>_smi_tx<%=i%>_dp_data    ;  
     dii<%=pidx%>_harness_smi_dp_user_logic_t	        harness_dii<%=pidx%>_smi_tx<%=i%>_dp_user    ;  
    <%  } %> 
    <% } %>


<%for(var i = 0; i < obj.DiiInfo[pidx].nSmiRx; i++) { %>
        dii<%=pidx%>_harness_smi_msg_valid_logic_t          harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_valid	;
        dii<%=pidx%>_harness_smi_msg_ready_logic_t          harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_ready	;
        dii<%=pidx%>_harness_smi_ndp_len_logic_t            harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp_len	;
        dii<%=pidx%>_harness_smi_dp_present_logic_t         harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_dp_present;
        dii<%=pidx%>_harness_smi_targ_id_logic_t            harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_targ_id	;
        dii<%=pidx%>_harness_smi_src_id_logic_t             harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_src_id	;
        dii<%=pidx%>_harness_smi_msg_id_logic_t             harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_id	;
        dii<%=pidx%>_harness_smi_msg_type_logic_t           harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_type	;

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
	dii<%=pidx%>_harness_smi_msg_user_logic_t harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_user ; 
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
     dii<%=pidx%>_harness_smi_msg_tier_logic_t  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_tier	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	 dii<%=pidx%>_harness_smi_steer_logic_t  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_steer	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>

      	dii<%=pidx%>_harness_smi_msg_pri_logic_t  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_pri	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
         dii<%=pidx%>_harness_smi_msg_qos_logic_t harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_qos	; 
<% } %> 
      dii<%=pidx%>_harness_smi_ndp_logic_t	 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp	;

    <%  if (obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
          dii<%=pidx%>_harness_smi_dp_valid_bit_t	  	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_valid	;  
          dii<%=pidx%>_harness_smi_dp_ready_bit_t	  	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_ready	;  
          dii<%=pidx%>_harness_smi_dp_last_bit_t	  	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_last	;  
          dii<%=pidx%>_harness_smi_dp_data_logic_t	  	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_data	;  
          dii<%=pidx%>_harness_smi_dp_user_logic_t	  	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_user	;  
    <%  } %>

    <% } %>

*/

     //======================================================== End Smi Dii ===============================================================

/*  always @(posedge tb_top.concerto_tb_aclk) begin
   //     abc1.getSignal ;
                

        <%for(var i = 0; i < obj.DiiInfo[pidx].nSmiTx; i++) { %>
 
	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_valid   =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_valid          ; 
	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_ready   =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_ready            ;	
	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp_len	   =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp_len ;         
	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_dp_present  =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_dp_present;       
	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_targ_id     =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_targ_id ;                
	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_src_id      =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_src_id ;                
	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_id      =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_id ;          
	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_type	   =  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_type ;               

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_user = abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_user	; 
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_tier	=  abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_tier   ;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_steer = abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_steer	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_pri = abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_pri	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
	harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_qos = abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_qos	; 
<% } %>
	 // harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp= abc1.dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp	 ; 
	 harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp= 0 ; //dummy since ndp_ndp is need to be checked with name
    <%  if (obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	harness_dii<%=pidx%>_smi_tx<%=i%>_dp_valid =  abc1.dii<%=pidx%>_smi_tx<%=i%>_dp_valid  ;  
	harness_dii<%=pidx%>_smi_tx<%=i%>_dp_ready =  abc1.dii<%=pidx%>_smi_tx<%=i%>_dp_ready  ;  
	harness_dii<%=pidx%>_smi_tx<%=i%>_dp_last  =  abc1.dii<%=pidx%>_smi_tx<%=i%>_dp_last   ;  
	harness_dii<%=pidx%>_smi_tx<%=i%>_dp_data  =  abc1.dii<%=pidx%>_smi_tx<%=i%>_dp_data   ;  
	harness_dii<%=pidx%>_smi_tx<%=i%>_dp_user  =  abc1.dii<%=pidx%>_smi_tx<%=i%>_dp_user   ;  
    <%  }  %>

    <% } %>

    <%for(var i = 0; i < obj.DiiInfo[pidx].nSmiRx; i++) { %>
	 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_valid =   abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_valid ;	
	 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_ready   = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_ready ;                                      
	 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp_len	   = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp_len   ;                                      
	 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_dp_present  = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_dp_present;                                      
	 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_targ_id	   = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_targ_id   ;                                      
	 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_src_id	   = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_src_id    ;                                       
	 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_id      = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_id    ;                                       
	 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_type    = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_type  ;                                       
                                                                                      
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
	harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_user = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_user	; 
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_tier	= abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_tier ;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_steer = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_steer	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>

 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_pri = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_pri	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
 harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_qos = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_qos	; 
<% } %>
	// harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp = abc1.dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp	; 

    <%  if (obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_valid =   abc1.dii<%=pidx%>_smi_rx<%=i%>_dp_valid  	;  
	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_ready =   abc1.dii<%=pidx%>_smi_rx<%=i%>_dp_ready	;  
	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_last  =   abc1.dii<%=pidx%>_smi_rx<%=i%>_dp_last    ;  
	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_data  =   abc1.dii<%=pidx%>_smi_rx<%=i%>_dp_data    ;  
	harness_dii<%=pidx%>_smi_rx<%=i%>_dp_user  =   abc1.dii<%=pidx%>_smi_rx<%=i%>_dp_user    ;  
    <%  } %> 

    <% } %>

end */


            <%for(var i = 0; i < obj.DiiInfo[pidx].nSmiTx; i++) { %>
	//assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_valid       = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_valid	;
	//assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_ready       = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_ready	;
 
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_valid       = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_valid; 
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_ready       = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_ready ;	
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp_len         = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp_len	;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_present      = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_dp_present;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_targ_id         = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_targ_id	;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_src_id          = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_src_id	;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_id          = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_id	;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_type        = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_type	;

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
	//assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_user	; 
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user          =  harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_user	; 
<% } else { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
	//assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_tier        = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_tier	;  
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_tier        = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_tier	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_steer           = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_steer	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_pri         = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_pri	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_msg_qos	; 
<% } else { %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	//assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp             = `DII<%=pidx%>.smi_tx<%=i%>_ndp_ndp	;
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp               = harness_dii<%=pidx%>_smi_tx<%=i%>_ndp_ndp	;
    <%  if (obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = harness_dii<%=pidx%>_smi_tx<%=i%>_dp_valid	;  
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = harness_dii<%=pidx%>_smi_tx<%=i%>_dp_ready	;  
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_last         = harness_dii<%=pidx%>_smi_tx<%=i%>_dp_last	;  
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_data         = harness_dii<%=pidx%>_smi_tx<%=i%>_dp_data	;  
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_user         = harness_dii<%=pidx%>_smi_tx<%=i%>_dp_user	;  
    <%  } else {  %>
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0      ;  
    <%  }  %>

	assign dii<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>  //upto hee added local haness regs afte first task call

    <%for(var i = 0; i < obj.DiiInfo[pidx].nSmiRx; i++) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_valid       =  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_valid	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_ready       =  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_ready	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp_len         =  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp_len	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_present      =  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_dp_present;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_targ_id         =  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_targ_id	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_src_id          =  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_src_id	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_id          =  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_id	;
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_type        =  harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_type	;

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
	//assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_user	; 
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user         = harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_user	; 
<% } else { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_tier        = harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_tier	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_steer           = harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_steer	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_pri         = harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_pri	;  
<% } %>

<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_msg_qos	; 
<% } else { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
/*	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp             = harness_dii<%=pidx%>_smi_rx<%=i%>_ndp_ndp	; */
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp             = 0	; 

    <%  if (obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = harness_dii<%=pidx%>_smi_rx<%=i%>_dp_valid	;  
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = harness_dii<%=pidx%>_smi_rx<%=i%>_dp_ready	;  
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_last         = harness_dii<%=pidx%>_smi_rx<%=i%>_dp_last	;  
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_data         = harness_dii<%=pidx%>_smi_rx<%=i%>_dp_data	;  
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_user         = harness_dii<%=pidx%>_smi_rx<%=i%>_dp_user	;  
    <%  } else {  %>
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0      ;  
    <%  }  %>

	assign dii<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>    //copied this block for local eg
 //end
     /*   always@(*) begin
	u_dii_apb_if_<%=pidx%>.paddr   <= abc1.dii<%=pidx%>_apb_paddr   ;
	u_dii_apb_if_<%=pidx%>.pwrite  <= abc1.dii<%=pidx%>_apb_pwrite  ;
	u_dii_apb_if_<%=pidx%>.psel    <= abc1.dii<%=pidx%>_apb_psel    ;
	u_dii_apb_if_<%=pidx%>.penable <= abc1.dii<%=pidx%>_apb_penable ;
	u_dii_apb_if_<%=pidx%>.prdata  <= abc1.dii<%=pidx%>_apb_prdata  ;
	u_dii_apb_if_<%=pidx%>.pwdata  <= abc1.dii<%=pidx%>_apb_pwdata  ;
	u_dii_apb_if_<%=pidx%>.pready  <= abc1.dii<%=pidx%>_apb_pready  ;
	u_dii_apb_if_<%=pidx%>.pslverr <= abc1.dii<%=pidx%>_apb_pslverr ; 
        end */
<% } %>

<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
     <% var NSMIIFTX = obj.DveInfo[pidx].nSmiRx;%>
     <% for (var i = 0; i < NSMIIFTX; i++) { %>
       dve<%=pidx%>_smi_if    dve<%=pidx%>_port<%=i%>_tx_smi_if(tb_top.concerto_tb_aclk,tb_rstn, "dve<%=pidx%>_port<%=i%>_tx_smi_if");
     
     <% } %>
     <% var NSMIIFRX = obj.DveInfo[pidx].nSmiTx;%>
     <% for (var i = 0; i < NSMIIFRX; i++) { %>
       dve<%=pidx%>_smi_if    dve<%=pidx%>_port<%=i%>_rx_smi_if(tb_top.concerto_tb_aclk,tb_rstn, "dve<%=pidx%>_port<%=i%>_rx_smi_if");
     <% } %>
       dii<%=sysdii_idx%>_apb_if u_dve_apb_if_<%=pidx%>( .clk(tb_top.concerto_tb_aclk),.rst_n(tb_rstn)); 

    <%for(var i = 0; i < obj.DveInfo[pidx].nSmiTx; i++) { %>
	 assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_valid      = 'h0;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_ready       = 'h0;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp_len         = 'h0;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_present      = 'h0;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_targ_id         = 'h0;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_src_id          = 'h0;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_id          = 'h0;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_type        = 'h0;
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_ndp             = 'h0; 



<% if(obj.DveInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
	//assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = `DVE<%=pidx%>.smi_tx<%=i%>_ndp_msg_user	; 
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0	; 
<% } else { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_steer           = 'h0	;  
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_tier        = 'h0	;  
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_pri         = 'h0	;  
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0	; 
<% } else { %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_dp_ready        = 'b0      ;  

	assign dve<%=pidx%>_port<%=i%>_rx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>

    <%for(var i = 0; i < obj.DveInfo[pidx].nSmiRx; i++) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_valid       =  'h0  ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_ready       =  'h0  ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp_len         =  'h0  ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_present      =  'h0  ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_targ_id         =  'h0  ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_src_id          =  'h0  ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_id          =  'h0  ;
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_type        =  'h0  ;
<% if(obj.DveInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0  ; 
<% } else { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_user        = 'h0                                      ; 
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_tier        = 'h0  ;  
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_steer           = 'h0     ;
<% } %>
<% if(obj.DveInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_pri         = 'h0   ;
<% } %>
<% if(obj.DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0   ; 
<% } else { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_qos         = 'h0                                      ; 
<% } %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_ndp             = 'h0       ;

    <%  if (obj.DveInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc) { %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'h0 ;  
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'h0 ;  
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_last         = 'h0 ;  
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_data         = 'h0 ;  
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_user         = 'h0 ;  
    <%  } else {  %>
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_valid        = 'b0      ;  
	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_dp_ready        = 'b0      ;  
    <%  }  %>

	assign dve<%=pidx%>_port<%=i%>_tx_smi_if.smi_msg_err         = 'b0      ;  
    <% } %>

     /*   always@(*) begin
	u_dve_apb_if_<%=pidx%>.paddr   <= abc1.dve<%=pidx%>_apb_paddr   ;
	u_dve_apb_if_<%=pidx%>.pwrite  <= abc1.dve<%=pidx%>_apb_pwrite  ;
	u_dve_apb_if_<%=pidx%>.psel    <= abc1.dve<%=pidx%>_apb_psel    ;
	u_dve_apb_if_<%=pidx%>.penable <= abc1.dve<%=pidx%>_apb_penable ;
	u_dve_apb_if_<%=pidx%>.prdata  <= abc1.dve<%=pidx%>_apb_prdata  ;
	u_dve_apb_if_<%=pidx%>.pwdata  <= abc1.dve<%=pidx%>_apb_pwdata  ;
	u_dve_apb_if_<%=pidx%>.pready  <= abc1.dve<%=pidx%>_apb_pready  ;
	u_dve_apb_if_<%=pidx%>.pslverr <= abc1.dve<%=pidx%>_apb_pslverr ;
        end */
<% } %>



initial
  begin

         uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_grb_apb_if", u_grb_apb_if);
<% var chiidx=0;
   var ioidx=0;
   for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
   <%  if(_child_blk[pidx].match('chiaiu')) { %>
      <% var NSMIIFTX = obj.AiuInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_<%=_child_blkid[pidx]%>_smi<%=i%>_tx_port_if" ),
                                            .value(<%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if));
     <% } %>
      <% var NSMIIFRX = obj.AiuInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                            .field_name( "m_<%=_child_blkid[pidx]%>_smi<%=i%>_rx_port_if" ),
                                             .value(<%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if));
     <% } %>
         uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_<%=_child_blkid[pidx]%>_apb_if", u_chi_apb_if_<%=chiidx%>);
     <% chiidx++; %>
   <%} else  if(_child_blk[pidx].match('ioaiu')) { %>
      <% var NSMIIFTX = obj.AiuInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_<%=_child_blkid[pidx]%>_smi<%=i%>_tx_port_if" ),
                                            .value(<%=_child_blkid[pidx]%>_port<%=i%>_tx_smi_if));
     <% } %>
      <% var NSMIIFRX = obj.AiuInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                            .field_name( "m_<%=_child_blkid[pidx]%>_smi<%=i%>_rx_port_if" ),
                                             .value(<%=_child_blkid[pidx]%>_port<%=i%>_rx_smi_if));
     <% } %>
     <% if(obj.AiuInfo[pidx].useCache) { %>
        <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_ccp_if)::set(uvm_root::get(), "", "m_<%=_child_blkid[pidx]%>_ccp_if_<%=i%>", u_ioaiu_ccp_if_<%=ioidx%>_<%=i%>);
        <% } %>
     <% } %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_apb_if)::set(uvm_root::get(), "", "m_<%=_child_blkid[pidx]%>_apb_if", u_ioaiu_apb_if_<%=ioidx%>);
         uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_<%=_child_blkid[pidx]%>_apb_if", u_sysdii_ioaiu_apb_if_<%=ioidx%>);
        <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
         uvm_config_db#(virtual <%=_child_blkid[pidx]%>_axi_cmdreq_id_if)::set(uvm_root::get(), "", "<%=_child_blkid[pidx]%>_axi_cmdreq_id_if_<%=i%>", u_axi_cmdreq_id_if<%=ioidx%>_<%=i%>);
     <% } %>
						   
     <% ioidx++; %>						       
   <% } %>
<% } %>
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
     <% var NSMIIFTX = obj.DmiInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual dmi<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dmi<%=pidx%>_smi<%=i%>_tx_port_if" ),
                                             .value(dmi<%=pidx%>_port<%=i%>_tx_smi_if));
     <% } %>
     <% var NSMIIFRX = obj.DmiInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual dmi<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dmi<%=pidx%>_smi<%=i%>_rx_port_if" ),
                                             .value(dmi<%=pidx%>_port<%=i%>_rx_smi_if));
     <% } %>
  <% if(obj.DmiInfo[pidx].useCmc) { %>
      uvm_config_db#(virtual dmi<%=pidx%>_ccp_if)::set(uvm_root::get(), "", "m_dmi<%=pidx%>_ccp_if", u_ccp_if_<%=pidx%>);
      uvm_config_db#(virtual dmi<%=pidx%>_apb_if)::set(uvm_root::get(), "", "m_dmi<%=pidx%>_apb_if", u_apb_if_<%=pidx%>);
      <% if(obj.DmiInfo[pidx].useWayPartitioning) { %>
      <% for (var iidx = 0; iidx < obj.nAIUs; iidx++) { %>
      dmi<%=pidx%>_aiu_funit_id[<%=(iidx+1)*obj.DmiInfo[pidx].interfaces.uSysIdInt.params.wFUnitIdV[0]-1%>:<%=iidx*obj.DmiInfo[pidx].interfaces.uSysIdInt.params.wFUnitIdV[0]%>] = <%=funitId[iidx]%>;
      <% } %>
      uvm_config_db#(aiu_funit_id_t)::set(uvm_root::get(), "uvm_test_top.m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb", "aiu_funit_id", dmi<%=pidx%>_aiu_funit_id);
      <%}%>
  <% } %>
      uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_dmi<%=pidx%>_apb_if", u_dmi_apb_if_<%=pidx%>);

      uvm_config_db#(virtual dmi<%=pidx%>_rtl_if)::set(uvm_root::get(), "", "m_dmi<%=pidx%>_rtl_if", u_dmi<%=pidx%>_rtl_if);
<% } %>

                             
 <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
     <% if (obj.DiiInfo[pidx].configuration == 1) { %>  					       
         uvm_config_db #(virtual dii<%=pidx%>_axi_if)::set(uvm_root::get(), "", "m_dii<%=pidx%>_axi_slv_if", m_dii<%=pidx%>_axi_slv_if);
         uvm_config_db #(virtual dii<%=pidx%>_dii_rtl_if)::set(uvm_root::get(), "", "m_dii<%=pidx%>_rtl_if", m_dii_rtl_if<%=pidx%>);
     <% } %>
     <% var NSMIIFTX = obj.DiiInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual dii<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dii<%=pidx%>_smi<%=i%>_tx_port_if" ),
                                             .value(dii<%=pidx%>_port<%=i%>_tx_smi_if));
     <% } %>
     <% var NSMIIFRX = obj.DiiInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual dii<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dii<%=pidx%>_smi<%=i%>_rx_port_if" ),
                                             .value(dii<%=pidx%>_port<%=i%>_rx_smi_if));
     <% } %>
      uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_dii<%=pidx%>_apb_if", u_dii_apb_if_<%=pidx%>);
<% } %>
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
     <% var NSMIIFTX = obj.DceInfo[pidx].nSmiRx;
      for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual dce<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dce<%=pidx%>_smi<%=i%>_tx_port_if" ),
                                             .value(dce<%=pidx%>_port<%=i%>_tx_smi_if));
     <% } %>
     <% var NSMIIFRX = obj.DceInfo[pidx].nSmiTx;
      for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual dce<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dce<%=pidx%>_smi<%=i%>_rx_port_if" ),
                                             .value(dce<%=pidx%>_port<%=i%>_rx_smi_if));
     <% } %>
      uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_dce<%=pidx%>_apb_if", u_dce_apb_if_<%=pidx%>);
<% } %>
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
     <% var NSMIIFTX = obj.DveInfo[pidx].nSmiRx;%>
     <% for (var i = 0; i < NSMIIFTX; i++) { %>
         uvm_config_db#(virtual dve<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dve<%=pidx%>_smi<%=i%>_tx_port_if" ),
                                             .value(dve<%=pidx%>_port<%=i%>_tx_smi_if));
     <% } %>
     <% var NSMIIFRX = obj.DveInfo[pidx].nSmiTx; %>
     <% for (var i = 0; i < NSMIIFRX; i++) { %>
         uvm_config_db#(virtual dve<%=pidx%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                             .inst_name( "" ),
                                             .field_name( "m_dve<%=pidx%>_smi<%=i%>_rx_port_if" ),
                                             .value(dve<%=pidx%>_port<%=i%>_rx_smi_if));
     <% } %>
      uvm_config_db#(virtual dii<%=sysdii_idx%>_apb_if)::set(uvm_root::get(), "", "m_sys_dii_dve<%=pidx%>_apb_if", u_dve_apb_if_<%=pidx%>);
<% } %>

  end


// Inject correctable error in SnoopFilter DCE

// if assertOn %>



<%}%>
endmodule
