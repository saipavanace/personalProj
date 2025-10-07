`include "uvm_macros.svh"

////////////////////////////////////////////////////////////////////////////////
//
// SFI Interface
//
////////////////////////////////////////////////////////////////////////////////

interface <%=obj.BlockId%>_rtl_if (input clk, input rst_n);
  import <%=obj.BlockId%>_rtl_agent_pkg::*;

  uvm_event_pool ev_pool    = uvm_event_pool::get_global_pool(); 
  uvm_event evt_addr_coll   = ev_pool.get("evt_addr_coll");

  parameter     setup_time = 1;
  parameter     hold_time  = 0;
  parameter     SYS_nSysCacheline   = 64;
  parameter     nDmiRbEntries = <%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%>;
  parameter     rdQDepth = 8;   //Hard-coded value used by RTL
  //parameter     rdQDepth = <%=obj.DmiInfo[obj.Id].cmpInfo.rdQDepth%>;

  <% var NumAccum = 3; %>

  logic                                                      cmd_starv_mode;
  logic                                                      cmd_rsp_push_valid;
  logic                                                      cmd_rsp_push_ready;
  logic [<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0]     cmd_rsp_push_rmsg_id;
  logic [<%=obj.Widths.Concerto.Ndp.Header.wFUnitId-1%>:0]   cmd_rsp_push_targ_id;

  logic                                                      mrd_pop_valid;
  logic                                                      mrd_pop_ready;
  logic [<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0]     mrd_pop_msg_id;
  logic [<%=obj.Widths.Concerto.Ndp.Header.wFUnitId-1%>:0]   mrd_pop_initiator_id;
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]        mrd_pop_addr;
  logic                                                      mrd_pop_ns;
  logic                                                      mrd_starv_mode;
  
  logic [31:0]                                               captured_count;
  logic [31:0]                                               dtwdbg_count;
  logic [31:0]                                               dropped_count;
  logic [31:0]                                               tsClock;      

  //logic                                                      acc0_cnt_expired;
  //logic                                                      acc1_cnt_expired;
  //logic                                                      acc2_cnt_expired;
  //logic                                                      acc0_cnt_dffre_en;
  //logic                                                      acc1_cnt_dffre_en;
  //logic                                                      acc2_cnt_dffre_en;
  //logic [31:0]                                               acc0_cnt_dffre;
  //logic [31:0]                                               acc1_cnt_dffre;
  //logic [31:0]                                               acc2_cnt_dffre;

  <% for (var i=0; i<NumAccum; i++) { %>
  logic                                                      acc<%=i%>_cnt_expired;
  logic                                                      acc<%=i%>_cnt_dffre_en;
  logic [31:0]                                               acc<%=i%>_cnt_dffre;
  <% } %>

  //signals required for address collision
  logic                                                      cmd_skid_buffer_pop_valid;   
  logic                                                      cmd_skid_buffer_pop_ready;   
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]        cmd_skid_buffer_pop_addr;   
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]        cmd_skid_buffer_pop_addr_q;
  logic                                                      cmd_skid_buffer_pop_ns;      

  logic [rdQDepth-1:0]                                                req_entry_valid;             
  logic [rdQDepth-1:0][<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]   req_entry_addr;              
  logic [rdQDepth-1:0]                                                req_entry_ns;


  logic [nDmiRbEntries-1:0]                                                 rb_id_valid;
  logic [nDmiRbEntries-1:0][<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]    rb_id_addr;
  logic [nDmiRbEntries-1:0]                                                 rb_id_ns;
                                                                                        
  logic                                                       prev_req_accepted;
  logic                                                       check_valid;
  logic                                                       addr_collision;


  function logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] cl_aligned(logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] addr);
    logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] cl_aligned_addr;
    cl_aligned_addr = (addr >> $clog2(SYS_nSysCacheline));
    return cl_aligned_addr;
  endfunction // cl_aligned
  
  initial begin
    prev_req_accepted = 1;
  end

  always @(posedge clk) begin
    cmd_skid_buffer_pop_addr_q <= cmd_skid_buffer_pop_addr;
  end

  always @(negedge clk) begin
    addr_collision = 0;
    if(cmd_skid_buffer_pop_addr_q != cmd_skid_buffer_pop_addr) begin
      prev_req_accepted = 1;
    end
    if(cmd_skid_buffer_pop_valid && prev_req_accepted) begin
      check_valid = 1;
    end
    else begin 
      check_valid = 0;
    end

    for(int i=0;i<rdQDepth;i++) begin   // HARDY..
        if(cmd_skid_buffer_pop_valid && check_valid &&(cl_aligned(cmd_skid_buffer_pop_addr) == cl_aligned(req_entry_addr[i])) && cmd_skid_buffer_pop_ns == req_entry_ns[i] && req_entry_valid[i])begin
          `uvm_info("<%=obj.BlockId%>:READ BUFFER COLLISION",$sformatf("time: %0d, addr :%0x, ns :%0x",$time,cl_aligned(cmd_skid_buffer_pop_addr),cmd_skid_buffer_pop_ns),UVM_MEDIUM);            
          addr_collision = 1;
          break;
        end
    end
    for(int i=0;i<nDmiRbEntries;i++) begin
        if(cmd_skid_buffer_pop_valid && check_valid && (cl_aligned(cmd_skid_buffer_pop_addr) == cl_aligned(rb_id_addr[i])) && cmd_skid_buffer_pop_ns == rb_id_ns[i] && rb_id_valid[i])begin
          `uvm_info("<%=obj.BlockId%>:WRITE BUFFER COLLISION",$sformatf("time: %0d, addr :%0x, ns :%0x",$time,cl_aligned(cmd_skid_buffer_pop_addr),cmd_skid_buffer_pop_ns),UVM_MEDIUM);            
          addr_collision = 1;
          break;
        end
    end
    if(addr_collision) begin 
      evt_addr_coll.trigger();
    end
    if(cmd_skid_buffer_pop_valid && !cmd_skid_buffer_pop_ready) begin
      prev_req_accepted = 0;
    end
    else begin
      prev_req_accepted = 1;
    end
  end
  // end of address collision

assert_cmd_rsp_push_valid_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cmd_rsp_push_valid)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "cmd_rsp_push_valid must not be unknown.");
   
assert_cmd_rsp_push_ready_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cmd_rsp_push_ready)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "cmd_rsp_push_ready must not be unknown.");


assert_cmd_rsp_push_rmsg_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
 cmd_rsp_push_valid |->   (!$isunknown(cmd_rsp_push_rmsg_id)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "cmd_rsp_push_rmsg_id must not be unknown.");


assert_cmd_rsp_push_targ_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  cmd_rsp_push_valid |->  (!$isunknown(cmd_rsp_push_targ_id)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "cmd_rsp_push_targ_id must not be unknown.");

  <%if (obj.DmiInfo[0].fnEnableQos) { %>
assert_cmd_starv_mode_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  cmd_rsp_push_valid |->  (!$isunknown(cmd_starv_mode)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "cmd_starv_mode must not be unknown.");
<% } %>

<% if(obj.testBench=='dmi') { %>
assert_mrd_pop_valid_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(mrd_pop_valid)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "mrd_pop_valid must not be unknown.");

assert_mrd_pop_ready_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(mrd_pop_ready)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "mrd_pop_ready must not be unknown.");

assert_mrd_pop_msg_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  mrd_pop_valid |->  (!$isunknown(mrd_pop_msg_id)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "mrd_pop_msg_id must not be unknown.");

assert_mrd_pop_initiator_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  mrd_pop_valid |->  (!$isunknown(mrd_pop_initiator_id)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "mrd_pop_initiator_id must not be unknown.");

assert_mrd_pop_addr_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  mrd_pop_valid |->  (!$isunknown(mrd_pop_addr)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "mrd_pop_addr must not be unknown.");

assert_mrd_pop_ns_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  mrd_pop_valid |->  (!$isunknown(mrd_pop_ns)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "mrd_pop_ns must not be unknown.");

  <%if (obj.DmiInfo[0].fnEnableQos) { %>
assert_mrd_starv_mode_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  cmd_rsp_push_valid |->  (!$isunknown(mrd_starv_mode)))
  else `uvm_error("<%=obj.BlockId%>_rtl_if", "mrd_starv_mode must not be unknown.");
<% } %>
<% } %>

  clocking mon_cb @(negedge clk);
    default input #setup_time output #hold_time;

    input cmd_rsp_push_valid;
    input cmd_rsp_push_ready;
    input cmd_rsp_push_rmsg_id;
    input cmd_rsp_push_targ_id;
    input cmd_starv_mode;
    input mrd_pop_valid;
    input mrd_pop_ready;
    input mrd_pop_msg_id;
    input mrd_pop_initiator_id;
    input mrd_pop_addr;
    input mrd_pop_ns;
    input mrd_starv_mode;

  endclocking : mon_cb


<% if (obj.assertOn) { %>
`ifdef ASSERT_ON
   //#Check.DMI.EOSChecks
/*   final
     begin
        $display ("Executing DMI End Of Simulation checks");

//#Check.DMI.IfNoErrorsInjThenCSRErrValuesAtEOSAreCorrect 
<% if(obj.testBench == "dmi") {%>
     if(csr_noerr_flag)begin 
        csr_cmiu_cesr_errvld_eos:
            assert ((!$isunknown(cmiu_cesr_errvld) && !cmiu_cesr_errvld)) else begin
                `uvm_error($sformatf("DMI  Assertion Checker"), $sformatf("cmiu_cesr_errvld bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,cmiu_cesr_errvld)); 
            end
        csr_cmiu_cesr_errOvf_eos:
            assert ((!$isunknown(cmiu_cesr_errOvf) && !cmiu_cesr_errOvf)) else begin
                `uvm_error($sformatf("DMI  Assertion Checker"), $sformatf("cmiu_cesr_errOvf bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,cmiu_cesr_errOvf)); 
            end
        cmiu_cesr_errcnt_eos:
            assert ((!$isunknown(corr_errcnt) && !corr_errcnt)) else begin
                `uvm_error($sformatf("DMI  Assertion Checker"), $sformatf("cmiu_cesr_errcnt   not at reset value (Expected:0x%0x Actual:0x%0x)",0,corr_errcnt)); 
            end
        csr_cmiu_uesr_errvld_eos:
            assert ((!$isunknown(cmiu_uesr_errvld) && !cmiu_uesr_errvld)) else begin
                `uvm_error($sformatf("DMI  Assertion Checker"), $sformatf("cmiu_uesr_errvld bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,cmiu_uesr_errvld)); 
            end
        csr_cmiu_uesr_errOvf_eos:
            assert ((!$isunknown(cmiu_uesr_errOvf) && !cmiu_uesr_errOvf)) else begin
                `uvm_error($sformatf("DMI  Assertion Checker"), $sformatf("cmiu_uesr_errOvf bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,cmiu_uesr_errOvf)); 
            end
       end
  <% if(obj.useCmc) { %>
         csr_cmiu_mntopActv:
              assert ((!$isunknown(MaintOpActv) && !MaintOpActv)) else begin
                  `uvm_error($sformatf("DMI  Assertion Checker"), $sformatf("MaintOpActv bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,MaintOpActv)); 
              end
         csr_cmiu_EvictActv:
              assert ((!$isunknown(EvictActv) && !EvictActv)) else begin
                  `uvm_error($sformatf("DMI  Assertion Checker"), $sformatf("EvictActv bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,EvictActv)); 
              end
         csr_cmiu_FillActv:
              assert ((!$isunknown(fillActv) && !fillActv)) else begin
                  `uvm_error($sformatf("DMI  Assertion Checker"), $sformatf("fillActv bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,fillActv)); 
              end
  <% } %>   
         csr_cmiu_TransActv:
              assert ((!$isunknown(transActv) && !transActv)) else begin
                  `uvm_error($sformatf("DMI  Assertion Checker"), $sformatf("transActv bit not at reset value (Expected:0x%0x Actual:0x%0x)",0,transActv)); 
              end
<% } %>
        $display ("DMI End Of Simulation checks completed");
     end // final begin
     */
`endif
<% } %>

//------------------------------------------------------------------------------
// Collect packet from master request interface
//------------------------------------------------------------------------------
   task automatic collect_cmd_rsp_packet(ref <%=obj.BlockId%>_rtl_cmd_rsp_pkt pkt);
      bit done = 0;
      pkt.cmd_rsp_push_valid = 0;
      do begin
         @(mon_cb);
         if(mon_cb.cmd_rsp_push_valid && mon_cb.cmd_rsp_push_ready)begin
           pkt.t_pkt                = $time;
           pkt.isCmd                = 1;
           pkt.cmd_rsp_push_valid   = 1;
           pkt.cmd_rsp_push_rmsg_id = mon_cb.cmd_rsp_push_rmsg_id;
           pkt.cmd_rsp_push_targ_id = mon_cb.cmd_rsp_push_targ_id;
           pkt.cmd_starv_mode       = mon_cb.cmd_starv_mode;
           done = 1;
         end
      end while (!done);

   endtask : collect_cmd_rsp_packet

//------------------------------------------------------------------------------
// Collect packet from master request interface
//------------------------------------------------------------------------------
   task automatic collect_mrd_pop_packet(ref <%=obj.BlockId%>_rtl_cmd_rsp_pkt pkt);
      bit done = 0;
      pkt.mrd_pop_valid = 0;
      do begin
         @(mon_cb);
         if(mon_cb.mrd_pop_valid && mon_cb.mrd_pop_ready)begin
           pkt.t_pkt                = $time;
           pkt.isMrd                = 1;
           pkt.mrd_pop_valid        = 1;
           pkt.mrd_pop_msg_id       = mon_cb.mrd_pop_msg_id;
           pkt.mrd_pop_initiator_id = mon_cb.mrd_pop_initiator_id;
           pkt.mrd_pop_addr         = mon_cb.mrd_pop_addr;
           pkt.mrd_pop_ns           = mon_cb.mrd_pop_ns;
           pkt.mrd_starv_mode       = mon_cb.mrd_starv_mode;
           done = 1;
         end
      end while (!done);

   endtask : collect_mrd_pop_packet
    

////////////////////////////////////////////////////////////////////////////////

endinterface
