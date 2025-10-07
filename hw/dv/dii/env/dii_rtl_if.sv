////////////////////////////////////////////////////////////////////////////////
//
// RTL Interface
//
////////////////////////////////////////////////////////////////////////////////

<% var blockId = obj.BlockId;
   var cap = blockId.toUpperCase();
%>
<% if (obj.testBench == 'dii') { %>

        `define <%=cap%>   tb_top.dut.u_dii_unit    
<% } else { %>
    // will be defined elsewhere
`ifndef <%=cap%>
<% if (obj.hierPath && obj.hierPath!=='') {%>
    `define <%=cap%>   dut.<%=obj.instancePath%>.u_dii_unit
<%}else{%>
    `define <%=cap%>   dut.<%=obj.DutInfo.strRtlNamePrefix%>.u_dii_unit
<% } %>
<% if (obj.testBench == "emu" ) { %>
    
    //`define <%=cap%>   ncore_hdl_top.dut.<%=obj.DutInfo.strRtlNamePrefix%>.u_dii_unit
   <% } %>
`endif
<% } %>

<% if((obj.testBench == 'dii') ||(obj.testBench=="fsys")) { %>
   `ifdef VCS
    `define VCSorCDNS
   `elsif CDNS
    `define VCSorCDNS
   `endif 
<% }  %>
interface <%=obj.BlockId%>_dii_rtl_if (input clk, input rst_n);

   import <%=obj.BlockId%>_smi_agent_pkg::*;

   parameter      setup_time = 1;
   parameter      hold_time  = 1;

   uvm_event_pool ev_pool        = uvm_event_pool::get_global_pool();
   uvm_event ev_N_cycles         = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_N_cycles");
   uvm_event ev_wtt_allocate     = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_wtt_allocate");
   uvm_event ev_wtt_deallocate   = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_wtt_deallocate");
   uvm_event ev_pmon_wtt_count   = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_pmon_wtt_count");
   uvm_event ev_rtt_allocate     = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_rtt_allocate");   
   uvm_event ev_rtt_deallocate1  = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_rtt_deallocate1");
   uvm_event ev_rtt_deallocate2  = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_rtt_deallocate2");
   uvm_event ev_pmon_rtt_count   = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_pmon_rtt_count");
   uvm_event ev_pmon_addr_collision   = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_pmon_addr_collision");

   int old_rtt_count;
   int old_wtt_count;
   int new_rtt_count;
   int new_wtt_count;
   bit addr_matched;
    
    //Sys event signals :

    bit event_in_req; 
    bit event_in_ack;
    bit event_err_valid;



   clocking rtt_cb @(negedge clk);
   endclocking // rtt_cb

   clocking wtt_cb @(negedge clk);
   endclocking // wtt_cb



   clocking monitor_cb @(negedge clk);

    default input #setup_time output #hold_time;
	

    input event_in_req;
    input event_in_ack;
    input event_err_valid;

  endclocking : monitor_cb


<% if((obj.testBench == 'dii') ||(obj.testBench=="fsys")) { %>
`ifndef VCSorCDNS
   modport monitor (
     import collect_rtt_axi2cmd,
     import collect_wtt_axi2cmd,
    //input  attvld_vec,
    input event_in_req,
    input event_in_ack
   );
`endif // `ifndef VCSorCDNS
<% } else {%>
   modport monitor (
     import collect_rtt_axi2cmd,
     import collect_wtt_axi2cmd
   );
<% } %>

   int wait_cycles;
   
  //----------------------------------------------------------------------- 
  // Initial block where I call the main data tasks 
  //----------------------------------------------------------------------- 

<% var assert_str = [];
   var i = 0;
    if (obj.PSEUDO_SYS_TB) {
        for (i = 0; i < obj.nDIIs; i++){
            assert_str.push("tb_top"+".`"+cap+i)
        }
    }
    else {
            assert_str.push("tb_top.dut.u_dii_unit")
    }
    console.log(assert_str);
%>

<% if (!obj.PSEUDO_SYS_TB) { %>
   initial
     begin
        // Format for time reporting
        $timeformat(-9, 0, " ns", 0);

<% if (obj.assertOn) { %>
        $display("DII_ASSERT_INFO: Emitting DII Assertions");
`ifdef ASSERT_ON
/*
        wait (rst_n);
        //#Check.DII.ResetDeAssertionStructuresEmpty
        if ((<%=assert_str[i]%>.prot.fifo_mrd_req.empty == 0)) begin
            `uvm_error("diiReset", "fifo_mrd_req not empty")
        end
    <% if (obj.useRttDataEntries | obj.useMemRspIntrlv) { %>
        if (<%=assert_str[i]%>.prot.fifo_dtr_req.pop_valid == 1) begin
            `uvm_error("diiReset", "fifo_dtr_req not empty")
        end
    <% } %>
        // niface
        if (<%=assert_str[i]%>.niface.fifo_aw_req.empty == 0) begin
            `uvm_error("diiReset", "fifo_aw_req not empty")
        end
        if (<%=assert_str[i]%>.niface.fifo_w_req.empty == 0) begin
            `uvm_error("diiReset", "fifo_w_req not empty")
        end

        // rtt
        // These fifos need to output entry 1
        if (<%=assert_str[i]%>.prot.rtt.fifo_flm.full == 1) begin
            `uvm_error("diiReset", "rtt.flm not outputing entry 1")
        end
    <% for (j = 0; j < obj.DutInfo.cmpInfo.nRttCtrlEntries; j++){ %>
        if (<%=assert_str[i]%>.prot.rtt.entry<%=j%>.s_state !== 0) begin
            `uvm_error("diiReset", "rtt.entry.s_state not free for this entry")
        end
    <% } %>
        // wtt
    <% for (j = 0; j < obj.DutInfo.cmpInfo.nWttCtrlEntries; j++){ %>
        if (<%=assert_str[i]%>.prot.wtt.entry<%=j%>.s_state !== 0) begin
            `uvm_error("diiReset", "wtt.entry.s_state not free for this entry")
        end
    <% } %>
        if (<%=assert_str[i]%>.prot.wtt.flm.allocate0 == 0) begin
            `uvm_error("diiReset", "wtt.flm not outputing entry 1")
        end
*/
`else
    $display("DII_ASSERT_INFO: assertions disabled");
`endif
<% } %>
   end


<% if (obj.assertOn) { %>
`ifdef ASSERT_ON
   //#Check.DII.EOSChecks
   final
     begin
        $display ("Executing DII End Of Simulation checks");

/*
//#Check.DII.IfNoErrorsInjThenCSRErrValuesAtEOSAreCorrect 
<% if(obj.testBench == "dii") {%>
     if(csr_noerr_flag)begin 
        csr_cmiu_cesr_errvld_eos:
            assert ((!$isunknown(cmiu_cesr_errvld) && !cmiu_cesr_errvld)) else begin
                `uvm_error($sformatf("DII  Assertion Checker"), $sformatf("cmiu_cesr_errvld bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,cmiu_cesr_errvld)); 
            end
        csr_cmiu_cesr_errOvf_eos:
            assert ((!$isunknown(cmiu_cesr_errOvf) && !cmiu_cesr_errOvf)) else begin
                `uvm_error($sformatf("DII  Assertion Checker"), $sformatf("cmiu_cesr_errOvf bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,cmiu_cesr_errOvf)); 
            end
        cmiu_cesr_errcnt_eos:
            assert ((!$isunknown(corr_errcnt) && !corr_errcnt)) else begin
                `uvm_error($sformatf("DII  Assertion Checker"), $sformatf("cmiu_cesr_errcnt   not at reset value (Expected:0x%0x Actual:0x%0x)",0,corr_errcnt)); 
            end
        csr_cmiu_uesr_errvld_eos:
            assert ((!$isunknown(cmiu_uesr_errvld) && !cmiu_uesr_errvld)) else begin
                `uvm_error($sformatf("DII  Assertion Checker"), $sformatf("cmiu_uesr_errvld bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,cmiu_uesr_errvld)); 
            end
        csr_cmiu_uesr_errOvf_eos:
            assert ((!$isunknown(cmiu_uesr_errOvf) && !cmiu_uesr_errOvf)) else begin
                `uvm_error($sformatf("DII  Assertion Checker"), $sformatf("cmiu_uesr_errOvf bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,cmiu_uesr_errOvf)); 
            end
       end
<% } %>i
*/
        $display ("DII End Of Simulation checks completed");
     end // final begin
`endif
<% } %>

<% } %>

//----------------------------------------------------------------------------------
// generate event every 10000 cycles
//----------------------------------------------------------------------------------
   initial begin
      automatic int waited_cycles    = 0;
      automatic int print_threshold = 20000;
      if (! $value$plusargs("wait_cycles=%d", wait_cycles)) begin
         wait_cycles = 5;
      end

      forever begin
         repeat (wait_cycles) @(posedge clk);
         ev_N_cycles.trigger();
         if (waited_cycles < print_threshold) begin
            waited_cycles += wait_cycles;
         end else begin
            `uvm_info($sformatf("%m"), $sformatf("DII RTL IF: %0d cycles passed", waited_cycles), UVM_HIGH)
            waited_cycles = 0;
         end
      end
   end

<% if (obj.testBench != "emu" ) { %>
   always @(negedge clk) begin
      case ( {`<%=cap%><%=tt%>.wtt_allocate_new_entry, `<%=cap%><%=tt%>.wtt_deallocated_entry} )
        2'b10: ev_wtt_allocate.trigger();
        2'b01: ev_wtt_deallocate.trigger();
        default: ;
      endcase
   end
   always @(negedge clk) begin
     case ( {`<%=cap%><%=tt%>.rtt_allocate_new_entry, `<%=cap%><%=tt%>.rtt_deallocated_entry, `<%=cap%><%=tt%>.rtt_deallocated_entry_cmo} )
       3'b100: ev_rtt_allocate.trigger();
       3'b001: ev_rtt_deallocate1.trigger();
       3'b010: ev_rtt_deallocate1.trigger();
       3'b011: ev_rtt_deallocate2.trigger();
       3'b111: ev_rtt_deallocate1.trigger();
       default: ;
     endcase
   end
   always @(posedge clk) begin
      #(100*1ps);
      new_wtt_count = `<%=cap%>.pmon_wtt_count;
      if (old_wtt_count != new_wtt_count) begin
         uvm_config_db#(int)::set(null, "tb_top", "<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_TB_pmon_wtt_count", new_wtt_count);
         `uvm_info($sformatf("%m"), $sformatf("PMON DBG: set %s to %0d (old_wtt_count %0d)",
                                              "<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_TB_pmon_wtt_count", new_wtt_count, old_wtt_count), UVM_HIGH)
         ev_pmon_wtt_count.trigger();
         old_wtt_count = new_wtt_count;
      end         
   end
   always @(posedge clk) begin
      #(100*1ps);
      new_rtt_count = `<%=cap%>.pmon_rtt_count;
      if (new_rtt_count != old_rtt_count) begin
         uvm_config_db#(int)::set(null, "tb_top", "<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_TB_pmon_rtt_count", new_rtt_count);
         `uvm_info($sformatf("%m"), $sformatf("PMON DBG: set %s to %0d (old_rtt_count %0d)",
                                              "<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_TB_pmon_rtt_count", new_rtt_count, old_rtt_count), UVM_HIGH)
         ev_pmon_rtt_count.trigger();
         old_rtt_count = new_rtt_count;
      end
   end

   always @(posedge clk) begin : ADDR_COLLISION
      addr_matched = 0;
      if (`<%=cap%><%=tt%>.rtt_allocate_new_entry || `<%=cap%><%=tt%>.wtt_allocate_new_entry) begin
<% for (i=0; i<obj.DiiInfo[obj.Id].cmpInfo.nRttCtrlEntries; i++) { %>
         if ( (! addr_matched) && `<%=cap%>.rtt_valid_entries[<%=i%>] &&
              ({`<%=cap%>.rtt_entry<%=i%>_prot[1], `<%=cap%>.rtt_entry<%=i%>_addr[WSMIADDR-1:$clog2(CACHELINESIZE)]} ==
               {`<%=cap%>.tt_prot[1], `<%=cap%>.tt_addr[WSMIADDR-1:$clog2(CACHELINESIZE)]}) ) begin
             addr_matched = 1;
         end
<% } %>
      end
      if (`<%=cap%><%=tt%>.rtt_allocate_new_entry || `<%=cap%><%=tt%>.wtt_allocate_new_entry) begin
<% for (i=0; i<obj.DiiInfo[obj.Id].cmpInfo.nWttCtrlEntries; i++) { %>
         if ( (! addr_matched) && `<%=cap%>.wtt_valid_entries[<%=i%>] &&
              ({`<%=cap%>.wtt_entry<%=i%>_prot[1], `<%=cap%>.wtt_entry<%=i%>_addr[WSMIADDR-1:$clog2(CACHELINESIZE)]} ==
               {`<%=cap%>.tt_prot[1], `<%=cap%>.tt_addr[WSMIADDR-1:$clog2(CACHELINESIZE)]}) ) begin
             addr_matched = 1;
         end
<% } %>
      end
      if (addr_matched) begin
         ev_pmon_addr_collision.trigger();
      end
   end : ADDR_COLLISION
   
   initial begin
      wait (rst_n === 1'b1);
      old_rtt_count = 0;
      old_wtt_count = 0;
   end
   
<% } %>
//------------------------------------------------------------------------------
// Collect the id of packet exiting the tt, at point where ordering has been finally determined
//------------------------------------------------------------------------------

    <% 
        function jsUcfirst(string) {
            return string.charAt(0).toUpperCase() + string.slice(1);
        }

        var tts = ["rtt", "wtt"];
        for(i in tts){ 
            var tt = tts[i];
    %>
    //wire <%=tt%>_granting;
    //assign <%=tt%>_granting = ((~ clk) & (| `<%=cap%>.<%=tt%>.<%=tt%>_muxarb_grant)) ;  //sample grant at the negedge clk
   <% if (obj.testBench != "emu" ) { %>
    wire <%=tt%>_granting = ((~ clk) & (| `<%=cap%>.<%=tt%>.<%=tt%>_muxarb_grant)) ;  //sample grant at the negedge clk

    task automatic collect_axi2cmd_<%=tt%>(ref smi_unq_identifier_bit_t unq_id, ref smi_addr_t cmd_addr , ref bit cmd_lock);
        int which_entry;

        @(posedge <%=tt%>_granting);
        // @(<%=tt%>_cb);
        // if(`<%=cap%>.<%=tt%>.<%=tt%>_muxarb_grant) begin
        which_entry = $clog2(`<%=cap%>.<%=tt%>.<%=tt%>_muxarb_grant); //decode the 1-hot grant vector
        case(which_entry)
        <%  
            for (j = 0; j < obj.DutInfo.cmpInfo["n" + jsUcfirst(tt) + "CtrlEntries"]; j++){ 
                var ttentry = "`" + cap + "." + tt + "." + tt + "_entry" + j ;
        %>
            <%=j%> : begin
            unq_id = {
                eConcMsgCmdReq,                                       // ==smi_conc_msg_class
                (<%=ttentry%>.init_id) , // ==smi_src_ncore_unit_id
                <%=ttentry%>.tid                                      // ==smi_msg_id
            };
            cmd_addr = <%=ttentry%>.addr;
            cmd_lock = <%=ttentry%>.lock;
            `uvm_info($sformatf("%m"), $sformatf("<%=tt%>[%0d]: unq_id=%0h , smi_src_ncore_unit_id = %0h, axi_id=%p intfsize=%0d st=%0d tof=%0d or=%0d mpf1=%p addr=%0h vz=%p",
						 <%=j%>, unq_id, <%=ttentry%>.init_id, <%=ttentry%>.axi_id, <%=ttentry%>.intfsize, <%=ttentry%>.st, <%=ttentry%>.tof,
						 <%=ttentry%>.ordering, <%=ttentry%>.mpf1, <%=ttentry%>.addr, <%=ttentry%>.vz), UVM_MEDIUM)
            end
        <% } %>
            default : `uvm_error($sformatf("%m"), $sformatf("tt access out of bounds: entry %d (grant %p)", which_entry, <%=tt%>_granting))
        endcase
    endtask : collect_axi2cmd_<%=tt%>
    <% } %>
    <% } %>



endinterface
