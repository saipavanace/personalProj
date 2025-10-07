`include "uvm_macros.svh"
////////////////////////////////////////////////////////////////////////////////
//
// Transaction Table Interface
//
////////////////////////////////////////////////////////////////////////////////
interface <%=obj.BlockId%>_tt_if (input clk, input rst_n);
  import <%=obj.BlockId%>_tt_agent_pkg::*;

  uvm_event_pool ev_pool    = uvm_event_pool::get_global_pool();
  uvm_event evt_addr_coll   = ev_pool.get("evt_addr_coll");

  parameter     setup_time = 1;
  parameter     hold_time  = 0;
  parameter     SYS_nSysCacheline   = 64;

  logic                                                      read_alloc_valid;
  logic                                                      read_alloc_ready;
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]        read_alloc_addr;
  logic                                                      read_alloc_ns;
  logic [<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0]     read_alloc_msg_id;
  logic [<%=obj.Widths.Concerto.Ndp.Header.wFUnitId-1%>:0]   read_alloc_aiu_unit_id;
  logic [<%=obj.Widths.Concerto.Ndp.Header.wCmType-1%>:0]    read_alloc_msg_type;
  bit                                                        read_tt_dealloc_vld;

  logic                                                      write_alloc_valid;
  logic                                                      write_alloc_ready;
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]        write_alloc_addr;
  logic                                                      write_alloc_ns;
  logic [<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0]     write_alloc_msg_id;
  logic [<%=obj.Widths.Concerto.Ndp.Header.wFUnitId-1%>:0]   write_alloc_aiu_unit_id;
  logic [<%=obj.Widths.Concerto.Ndp.Header.wCmType-1%>:0]    write_alloc_msg_type;
  bit                                                        write_tt_dealloc_vld;

  //signals required for address collision
  parameter                                                nRttCtrlEntries = <%=obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries%>; 
  parameter                                                nWttCtrlEntries = <%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries%>;
  <%if(obj.useCmc) {%>
  parameter                                                nTagBanks = <%=obj.nTagBanks%>;
  <% } %>

  logic [<%=obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries-1%>:0]                         tt_valid;  
  logic [nRttCtrlEntries-1:0] [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]            tt_addr;
  logic [nRttCtrlEntries-1:0]                                                          tt_ns;

  logic [<%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries-1%>:0]                        wtt_valid;  
  logic [nWttCtrlEntries-1:0] [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]            wtt_addr;
  logic [nWttCtrlEntries-1:0]                                                          wtt_ns;

  <%if(obj.useCmc) {%>
  logic [nTagBanks-1:0]                                                           ctrlop_vld_p0; 
  logic [nTagBanks-1:0]                                                           ctrlop_vld_p0_plus; 
  logic [nTagBanks-1:0]                                                           ctrlop_vld_p1_minus;              
  logic [nTagBanks-1:0]                                                           ctrlop_vld_p1;
  logic [nTagBanks-1:0]                                                           cacheop_rdy_p0;
  logic [nTagBanks-1:0]                                                           cacheop_rdy_p0_plus;
  logic [nTagBanks-1:0]                                                           cacheop_rdy_p1_minus;
  logic [nTagBanks-1:0]                                                           cacheop_rdy_p1;
  logic                                                                           isReplay;
  logic                                                                           isRecycle;
  logic                                                                           isRecycle_q;
  logic                                                                           isMntOp;
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]                             cam_addr;
  logic                                                                           cam_ns;
  <% } else {%>
  logic                                                                           write_pipe_pop_valid;
  logic                                                                           write_pipe_pop_ready;
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]                             write_req_addr;
  logic                                                                           write_req_ns;

  logic                                                                           read_pipe_pop_valid;
  logic                                                                           read_pipe_pop_ready;
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]                             read_req_addr;
  logic                                                                           read_req_ns;
  <% } %>

  logic                                                                           addr_collision;
  logic                                                                           rtt_addr_collision;
  logic                                                                           wtt_addr_collision;
  logic                                                                           prev_write_req_accepted;
  logic                                                                           prev_read_req_accepted;
  logic                                                                           write_check_valid;
  logic                                                                           read_check_valid;
  
  function logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] cl_aligned(logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] addr);
    logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] cl_aligned_addr;
    cl_aligned_addr = (addr >> $clog2(SYS_nSysCacheline));
    return cl_aligned_addr;
  endfunction // cl_aligned

  always @(negedge clk) begin
    addr_collision = 0;
    rtt_addr_collision = 0;
    wtt_addr_collision = 0;
    <%if(obj.useCmc) {%>
    for(int i=0;i<nRttCtrlEntries;i++) begin
     for(int j=0; j<nTagBanks; j++) begin
         if(ctrlop_vld_p1[j] && cacheop_rdy_p1[j] && !isReplay && !isRecycle_q && !isMntOp && (cl_aligned(tt_addr[i]) == cl_aligned(cam_addr)) && (tt_ns[i] == cam_ns) && tt_valid[i]) begin
           addr_collision = 1;
           rtt_addr_collision = 1;
           `uvm_info("<%=obj.BlockId%>:RTT_COLLISION",$sformatf("time: %0d, addr :%0x, ns :%0x",$time,cl_aligned(cam_addr),cam_ns),UVM_MEDIUM);                
           break;
         end
     end
    end
    for(int i=0;i<nWttCtrlEntries;i++) begin
     for(int j=0; j<nTagBanks; j++) begin
         if(ctrlop_vld_p1[j] && cacheop_rdy_p1[j] && !isReplay && !isRecycle_q && !isMntOp && (cl_aligned(wtt_addr[i]) == cl_aligned(cam_addr)) && (wtt_ns[i] == cam_ns) && wtt_valid[i]) begin
           addr_collision = 1;
           wtt_addr_collision = 1;
           `uvm_info("<%=obj.BlockId%>:WTT_COLLISION",$sformatf("time: %0d, addr :%0x, ns :%0x",$time,cl_aligned(cam_addr),cam_ns),UVM_MEDIUM);
           break;
         end
     end
    end
    <% } else {%>
    if(write_pipe_pop_valid && prev_write_req_accepted) begin
      write_check_valid = 1;
    end
    else begin
      write_check_valid = 0;
    end
    if(read_pipe_pop_valid && prev_read_req_accepted) begin
      read_check_valid = 1;
    end
    else begin
      read_check_valid = 0;
    end

    for(int i=0;i<nWttCtrlEntries;i++) begin
     if(read_pipe_pop_valid && read_check_valid && (cl_aligned(wtt_addr[i]) == cl_aligned(read_req_addr)) && (wtt_ns[i] == read_req_ns) && wtt_valid[i]) begin
         addr_collision = 1;
         wtt_addr_collision = 1;
         `uvm_info("<%=obj.BlockId%>:WTT_COLLISION",$sformatf("time : %0d, addr :%0x, ns :%0x",$time,cl_aligned(read_req_addr),read_req_ns),UVM_MEDIUM);
        break;
     end
    end
    for(int i=0;i<nRttCtrlEntries;i++) begin
     if(write_pipe_pop_valid && write_check_valid && (cl_aligned(tt_addr[i]) == cl_aligned(write_req_addr)) && (tt_ns[i] == write_req_ns) && tt_valid[i]) begin
         addr_collision = 1;
         rtt_addr_collision = 1;
         `uvm_info("<%=obj.BlockId%>:RTT_COLLISION",$sformatf("time: %0d, addr :%0x, ns :%0x",$time,cl_aligned(write_req_addr),write_req_ns),UVM_MEDIUM);
         break;
     end
    end
    if(read_pipe_pop_valid && !read_pipe_pop_ready) begin
      prev_read_req_accepted = 0;
    end
    else begin
      prev_read_req_accepted = 1;
    end
    if(write_pipe_pop_valid && !write_pipe_pop_ready) begin
      prev_write_req_accepted = 0;
    end
    else begin
      prev_write_req_accepted = 1;
    end
    <% } %>
    if(addr_collision) begin
      evt_addr_coll.trigger();
    end
  end

  <%if(obj.useCmc) {%>
  always @(posedge clk) begin
    isRecycle_q     <= isRecycle;
  end

  always @(posedge clk) begin
    cacheop_rdy_p1   <= cacheop_rdy_p1_minus;
    ctrlop_vld_p1   <= ctrlop_vld_p1_minus;
  end

  <%if(obj.UseTagRamOutputFlop){%>
       always@(posedge clk) begin
       ctrlop_vld_p1_minus   <= ctrlop_vld_p0_plus;
       cacheop_rdy_p1_minus   <= cacheop_rdy_p0_plus;
       end
  <%} else {%>
       assign ctrlop_vld_p1_minus =ctrlop_vld_p0_plus;
       assign cacheop_rdy_p1_minus = cacheop_rdy_p0_plus;
  <% } %>


  <%if(obj.UseTagRamInputFlop){%>
      always@(posedge clk) begin
        ctrlop_vld_p0_plus   <= ctrlop_vld_p0;
        cacheop_rdy_p0_plus   <= cacheop_rdy_p0;
        end
  <% } else {%>
        assign ctrlop_vld_p0_plus   = ctrlop_vld_p0;
        assign cacheop_rdy_p0_plus  = cacheop_rdy_p0;
  <%}%>
  <% } %>
//        

  assert_read_alloc_valid_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(read_alloc_valid)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "read_alloc_valid must not be unknown.");
   
  assert_read_alloc_ready_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(read_alloc_ready)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "read_alloc_ready must not be unknown.");

  assert_read_alloc_addr_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  read_alloc_valid |->  (!$isunknown(read_alloc_addr)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "read_alloc_addr must not be unknown.");

  assert_read_alloc_ns_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  read_alloc_valid |->  (!$isunknown(read_alloc_ns)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "read_alloc_ns must not be unknown.");

  assert_read_alloc_msg_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  read_alloc_valid |->  (!$isunknown(read_alloc_msg_id)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "read_alloc_msg_id must not be unknown.");

  assert_read_alloc_aiu_unit_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  read_alloc_valid |->  (!$isunknown(read_alloc_aiu_unit_id)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "read_alloc_aiu_unit_id must not be unknown.");

  assert_read_alloc_msg_type_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  read_alloc_valid |->  (!$isunknown(read_alloc_msg_type)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "read_alloc_msg_type must not be unknown.");

  assert_write_alloc_valid_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(write_alloc_valid)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "write_alloc_valid must not be unknown.");
   
  assert_write_alloc_ready_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(write_alloc_ready)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "write_alloc_ready must not be unknown.");

  assert_write_alloc_addr_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  write_alloc_valid |->  (!$isunknown(write_alloc_addr)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "write_alloc_addr must not be unknown.");

  assert_write_alloc_ns_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  write_alloc_valid |->  (!$isunknown(write_alloc_ns)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "write_alloc_ns must not be unknown.");

  assert_write_alloc_msg_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  write_alloc_valid |->  (!$isunknown(write_alloc_msg_id)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "write_alloc_msg_id must not be unknown.");

  assert_write_alloc_aiu_unit_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  write_alloc_valid |->  (!$isunknown(write_alloc_aiu_unit_id)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "write_alloc_aiu_unit_id must not be unknown.");

  assert_write_alloc_msg_type_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
  write_alloc_valid |->  (!$isunknown(write_alloc_msg_type)))
  else `uvm_error("<%=obj.BlockId%>_tt_if", "write_alloc_msg_type must not be unknown.");

  clocking mon_cb @(negedge clk);
    default input #setup_time output #hold_time;

    input   read_alloc_valid;          
    input   read_alloc_ready;
    input   read_alloc_addr;
    input   read_alloc_ns;
    input   read_alloc_msg_id;
    input   read_alloc_aiu_unit_id;
    input   read_alloc_msg_type;
    input   read_tt_dealloc_vld;

    input   write_alloc_valid;
    input   write_alloc_ready;
    input   write_alloc_addr;
    input   write_alloc_ns;
    input   write_alloc_msg_id;
    input   write_alloc_aiu_unit_id;
    input   write_alloc_msg_type;
    input   write_tt_dealloc_vld;

  endclocking : mon_cb
  //------------------------------------------------------------------------------
  // Collect rtt packet
  //------------------------------------------------------------------------------
  task automatic collect_rtt_alloc_packet(ref <%=obj.BlockId%>_tt_alloc_pkt pkt);
    bit done = 0;
    pkt.alloc_valid       = 0;
    pkt.t_pkt             = 0;         
    pkt.isRtt             = 0;
    pkt.isWtt             = 0;
    pkt.alloc_addr        = 0;    
    pkt.alloc_ns          = 0;         
    pkt.alloc_msg_id      = 0;     
    pkt.alloc_aiu_unit_id = 0;   
    pkt.alloc_msg_type    = 0;
    pkt.dealloc_vld       = 0;
    do begin
       @(mon_cb);
       if(mon_cb.read_alloc_valid && mon_cb.read_alloc_ready) begin
         pkt.t_pkt                = $time;
         pkt.isRtt                = 1;
         pkt.alloc_valid          = 1;
         pkt.alloc_addr           = mon_cb.read_alloc_addr;
         pkt.alloc_ns             = mon_cb.read_alloc_ns;
         pkt.alloc_msg_id         = mon_cb.read_alloc_msg_id;
         pkt.alloc_aiu_unit_id    = mon_cb.read_alloc_aiu_unit_id;
         pkt.alloc_msg_type       = mon_cb.read_alloc_msg_type;
         done = 1;
       end
       if(mon_cb.read_tt_dealloc_vld) begin
          pkt.t_pkt               = $time;
          pkt.isRtt               = 1;
          pkt.dealloc_vld         = 1;
          done                    = 1;
       end
    end while (!done);
  endtask : collect_rtt_alloc_packet
  //------------------------------------------------------------------------------
  // Collect wtt packet
  //------------------------------------------------------------------------------
  task automatic collect_wtt_alloc_packet(ref <%=obj.BlockId%>_tt_alloc_pkt pkt);
    bit done = 0;
    pkt.alloc_valid       = 0;
    pkt.t_pkt             = 0;         
    pkt.isRtt             = 0;
    pkt.isWtt             = 0;
    pkt.alloc_addr        = 0;    
    pkt.alloc_ns          = 0;         
    pkt.alloc_msg_id      = 0;     
    pkt.alloc_aiu_unit_id = 0;   
    pkt.alloc_msg_type    = 0;
    pkt.dealloc_vld       = 0;
    do begin
       @(mon_cb);
       if(mon_cb.write_alloc_valid && mon_cb.write_alloc_ready)begin
         pkt.t_pkt                = $time;
         pkt.isWtt                = 1;
         pkt.alloc_valid          = 1;
         pkt.alloc_addr           = mon_cb.write_alloc_addr;
         pkt.alloc_ns             = mon_cb.write_alloc_ns;
         pkt.alloc_msg_id         = mon_cb.write_alloc_msg_id;
         pkt.alloc_aiu_unit_id    = mon_cb.write_alloc_aiu_unit_id;
         pkt.alloc_msg_type       = mon_cb.write_alloc_msg_type;
         pkt.dealloc_vld          = mon_cb.write_tt_dealloc_vld;
         done = 1;
       end
       if(mon_cb.write_tt_dealloc_vld) begin
          pkt.t_pkt               = $time;
          pkt.isWtt               = 1;
          pkt.dealloc_vld         = 1;
          done                    = 1;
       end
    end while (!done);
  endtask : collect_wtt_alloc_packet   
////////////////////////////////////////////////////////////////////////////////
endinterface
