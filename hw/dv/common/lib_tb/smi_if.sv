////////////////////////////////////////////////////////////////////////////////
//
// SMI Interface
<% if (1 == 0) { %>
// Author: Chirag Gandhi
<% } %>
//
////////////////////////////////////////////////////////////////////////////////

interface <%=obj.BlockId%>_smi_if (input clk, input rst_n, input string interface_name);

  import <%=obj.BlockId%>_smi_agent_pkg::*;
  import uvm_pkg::*;

  uvm_event_pool ev_pool     = uvm_event_pool::get_global_pool();
  uvm_event evt_assert_dtw_rsp_ready = ev_pool.get("evt_assert_dtw_rsp_ready");

  parameter      setup_time = 1;
  parameter      hold_time  = 0;

  parameter      WSECURITYATTRIBUTE = <%=obj.wSecurityAttribute%>;

  parameter      UPDREQ_DELAY = 10;
  parameter      DTWREQ_DELAY = 100;
  
  int k_delay_min                  = 0;
  int k_delay_max                  = 1;
  int k_burst_pct                  = 80;
  bit k_is_bfm_delay_changing      = 0;
  int k_delay_changing_time_period = 20000; //in ns
  bit is_active                    = 0;
  bit is_receiver                  = 0;

  int my_smi_rx_id                 = 0;
  int force_rdy_dly_min            = 0;
  int force_rdy_dly_max            = 0;

  mailbox#(smi_seq_item)   m_drv_ndp_mb = new(10);
  event                    e_drv_ndp_mb;
  mailbox#(smi_seq_item)   m_drv_dp_mb  = new(10);
  smi_seq_item             m_mon_ndp_q[$];
  event                    e_mon_ndp_q;
  smi_seq_item             m_mon_dp_q[$];
  event                    e_mon_dp_q;
  smi_seq_item             msg_t = new();

  <% if(obj.Block == "dce") { %>
    smi_msg_valid_logic_t     smi_msg_valid;
    smi_msg_ready_logic_t     smi_msg_ready;
    smi_steer_logic_t         smi_steer;
    smi_targ_id_logic_t       smi_targ_id;
    smi_src_id_logic_t        smi_src_id;
    smi_msg_tier_logic_t      smi_msg_tier;
    smi_msg_qos_logic_t       smi_msg_qos;
    smi_msg_pri_logic_t       smi_msg_pri;
    smi_msg_type_logic_t      smi_msg_type;
    smi_ndp_len_logic_t       smi_ndp_len;
    smi_ndp_logic_t           smi_ndp;
    smi_dp_present_logic_t    smi_dp_present;
    smi_msg_id_logic_t        smi_msg_id;
    smi_msg_user_logic_t      smi_msg_user;
    smi_msg_err_logic_t       smi_msg_err;
    smi_dp_valid_logic_t      smi_dp_valid;
    smi_dp_ready_logic_t      smi_dp_ready;
    smi_dp_last_logic_t       smi_dp_last;
    smi_dp_data_logic_t       smi_dp_data;
    smi_dp_user_logic_t       smi_dp_user;
    <% } else { %>
    `ifdef VCS    
    tri0 smi_msg_valid_logic_t     smi_msg_valid;
    tri0 smi_msg_ready_logic_t     smi_msg_ready;
    tri0 smi_steer_logic_t         smi_steer;
    tri0 smi_targ_id_logic_t       smi_targ_id;
    tri0 smi_src_id_logic_t        smi_src_id;
    tri0 smi_msg_tier_logic_t      smi_msg_tier;
    tri0 smi_msg_qos_logic_t       smi_msg_qos;
    tri0 smi_msg_pri_logic_t       smi_msg_pri;
    tri0 smi_msg_type_logic_t      smi_msg_type;
    tri0 smi_ndp_len_logic_t       smi_ndp_len;
    tri0 smi_ndp_logic_t           smi_ndp;
    tri0 smi_dp_present_logic_t    smi_dp_present;
    tri0 smi_msg_id_logic_t        smi_msg_id;
    tri0 smi_msg_user_logic_t      smi_msg_user;
    tri0 smi_msg_err_logic_t       smi_msg_err;
    tri0 smi_dp_valid_logic_t      smi_dp_valid;
    tri0 smi_dp_ready_logic_t      smi_dp_ready;
    tri0 smi_dp_last_logic_t       smi_dp_last;
    tri0 smi_dp_data_logic_t       smi_dp_data;
    tri0 smi_dp_user_logic_t       smi_dp_user;
    `else
    smi_msg_valid_logic_t     smi_msg_valid;
    smi_msg_ready_logic_t     smi_msg_ready;
    smi_steer_logic_t         smi_steer;
    smi_targ_id_logic_t       smi_targ_id;
    smi_src_id_logic_t        smi_src_id;
    smi_msg_tier_logic_t      smi_msg_tier;
    smi_msg_qos_logic_t       smi_msg_qos;
    smi_msg_pri_logic_t       smi_msg_pri;
    smi_msg_type_logic_t      smi_msg_type;
    smi_ndp_len_logic_t       smi_ndp_len;
    smi_ndp_logic_t           smi_ndp;
    smi_dp_present_logic_t    smi_dp_present;
    smi_msg_id_logic_t        smi_msg_id;
    smi_msg_user_logic_t      smi_msg_user;
    smi_msg_err_logic_t       smi_msg_err;
    smi_dp_valid_logic_t      smi_dp_valid;
    smi_dp_ready_logic_t      smi_dp_ready;
    smi_dp_last_logic_t       smi_dp_last;
    smi_dp_data_logic_t       smi_dp_data;
    smi_dp_user_logic_t       smi_dp_user;
    `endif
    
    <% } %>


  //-----------------------------------------------------------------------
  //params to control SMI readys for perf counter(stall events)
  //-----------------------------------------------------------------------
  bit en_rx_stall  = 0;// enable SMI Rx stall TO DO:this shald be fixed to 0 as defailt value 
  int stall_period = 0;//number of clk cycles during which ready shall be maintained to low when valid is high
  bit bloc_smi_stall = 0;//bloc always ready to 0
  int cnt_rdy_blckd_duration = 0;//counter cycles of not asserted ready 
  int en_tx_stall = 0;

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  //SMI interface timeout assertions variables
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  //counter is incremented if 'Valid' is asserted but 'Ready' is not asserted. 
  //counter triggered on every clock clycle
  //Resets to 0 if above statement turns out to be false..
  int ndp_rdy_timeout_counter, dp_rdy_timeout_counter;
  int error_quit_count = 0;
   
  /*

  Following logic is not implemented

  //Counter is incremented for every pending SMI request for which response has not yet arrived
  //Counter is decremented for every response observed
  //This logic is binded only to Target SMI Slave request channel (from RTL prespective) 
  int pending_rsps_count;
  //Counter increments if there non-zero resonses outstanding. counter is triggered on every cycle
  //For every response observed counter is reset to 0.
  int rsps_pending_timeout_counter;
  //On observing first Response set this bit. If set, then the Check is turned on
  //This is required because initialization sequence in DCE, IO-Cache, DMI might take many cycles
  //Hence we will trun off the check until Initialization is complete.
  bit first_rsp_obsrvd;
  */

<% if(obj.testBench == 'dmi') { %>
  `ifndef VCS
    int RDY_NOT_ASSERTED_TIMEOUT = 15000;
  `else // `ifndef VCS
    int RDY_NOT_ASSERTED_TIMEOUT = 500000;
  `endif // `ifndef VCS ... `else ... 
<% } else {%>
   int RDY_NOT_ASSERTED_TIMEOUT = 150000;
<% } %>
  int RSPS_IDLE_TIMEOUT  = 2000; 
//-----------------------------------------------------------------------
//params to control SMI readys for perf counter(stall events)
//----------------------------------------------------------------------- 
  //int rdy_asserted_duration_div ;    
  //int RDY_NOT_ASSERTED_DURATION = (RDY_NOT_ASSERTED_TIMEOUT / 10) ; //Perf counter: duration during which ready  is blocked to 0
  int RDY_NOT_ASSERTED_DURATION =1; //Perf counter: duration during which ready  is blocked to 0

  clocking transmitter_cb @(posedge clk);

      default input #setup_time output #hold_time;
      output smi_msg_valid;
      input  smi_msg_ready;
      output smi_steer;
      output smi_targ_id;
      output smi_src_id;
      output smi_msg_tier;
      output smi_msg_qos;
      output smi_msg_pri;
      output smi_msg_type;
      output smi_ndp_len;
      output smi_ndp;
      output smi_dp_present;
      output smi_msg_id;
      output smi_msg_user;
      output smi_msg_err;
      output smi_dp_valid;
      input  smi_dp_ready;
      output smi_dp_last;
      output smi_dp_data;
      output smi_dp_user;

  endclocking : transmitter_cb

  clocking receiver_cb @(posedge clk);

      default input #setup_time output #hold_time;
      input  smi_msg_valid;
      output smi_msg_ready;
      input  smi_steer;
      input  smi_targ_id;
      input  smi_src_id;
      input  smi_msg_tier;
      input  smi_msg_qos;
      input  smi_msg_pri;
      input  smi_msg_type;
      input  smi_ndp_len;
      input  smi_ndp;
      input  smi_dp_present;
      input  smi_msg_id;
      input  smi_msg_user;
      input  smi_msg_err;
      input  smi_dp_valid;
      output smi_dp_ready;
      input  smi_dp_last;
      input  smi_dp_data;
      input  smi_dp_user;

  endclocking : receiver_cb

  clocking monitor_cb @(negedge clk);

    default input #setup_time;
      input smi_msg_valid;
      input smi_msg_ready;
      input smi_steer;
      input smi_targ_id;
      input smi_src_id;
      input smi_msg_tier;
      input smi_msg_qos;
      input smi_msg_pri;
      input smi_msg_type;
      input smi_ndp_len;
      input smi_ndp;
      input smi_dp_present;
      input smi_msg_id;
      input smi_msg_user;
      input smi_msg_err;
      input smi_dp_valid;
      input smi_dp_ready;
      input smi_dp_last;
      input smi_dp_data;
      input smi_dp_user;

  endclocking : monitor_cb

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
// Coverage and Assertions
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------

// Stability properties : smi_msg_* signals must hold when (smi_msg_valid & ~smi_msg_ready).

 <%if(!obj.CUSTOMER_ENV) { %>
`ifndef TT_DEBUG
//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------

// Signal Not Unknown properties : smi_msg_* signals must be not be X or Z.

assert_smi_msg_valid_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(smi_msg_valid)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_msg_valid must not be unknown."));

assert_smi_msg_ready_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(smi_msg_ready)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_msg_ready must not be unknown."));

assert_smi_msg_id_not_x_z:
 assert property( @(posedge clk) disable iff (~rst_n)
    (smi_msg_valid) |-> (!$isunknown(smi_msg_id)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_msg_id must not be unknown."));

assert_smi_targ_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (smi_msg_valid) |-> (!$isunknown(smi_targ_id)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_targ_id must not be unknown."));

assert_smi_src_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (smi_msg_valid) |-> (!$isunknown(smi_src_id)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_src_id must not be unknown."));

assert_smi_msg_type_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (smi_msg_valid) |-> (!$isunknown(smi_msg_type)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_msg_type must not be unknown."));

assert_smi_ndp_len_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (smi_msg_valid) |-> (!$isunknown(smi_ndp_len)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_ndp_len must not be unknown."));

// remove because not use // cf VCS_double_drive //assert_smi_ndp_not_x_z:
// remove because not use // cf VCS_double_drive //  assert property( @(posedge clk) disable iff (~rst_n)
// remove because not use // cf VCS_double_drive //    (transmitter_cb.smi_msg_valid) |-> (!$isunknown(transmitter_cb.smi_ndp)) )
// remove because not use // cf VCS_double_drive //else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_ndp must not be unknown."));

assert_smi_steer_not_x_z:
 assert property( @(posedge clk) disable iff (~(rst_n && <%=obj.smiObj.WSMISTEER %>))
    (smi_msg_valid) |-> (!$isunknown(smi_steer)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_steer must not be unknown."));

assert_smi_msg_pri_not_x_z:
 assert property( @(posedge clk) disable iff (~(rst_n && <%=obj.smiObj.WSMIMSGPRI %>))
    (smi_msg_valid) |-> (!$isunknown(smi_msg_pri)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_msg_pri must not be unknown."));

assert_smi_msg_tier_not_x_z:
  assert property( @(posedge clk) disable iff (~(rst_n && <%=obj.smiObj.WSMIMSGTIER %>))
    (smi_msg_valid) |-> (!$isunknown(smi_msg_tier)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_msg_tier must not be unknown."));

assert_smi_msg_qos_not_x_z:
  assert property( @(posedge clk) disable iff (~(rst_n && <%=obj.smiObj.WSMIMSGQOS %>))
    (smi_msg_valid) |-> (!$isunknown(smi_msg_qos)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_msg_qos must not be unknown."));

assert_smi_msg_user_not_x_z:
 assert property( @(posedge clk) disable iff (~(rst_n && <%=obj.smiObj.WSMIMSGUSER %>))
    (smi_msg_valid) |-> (!$isunknown(smi_msg_user)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_msg_user must not be unknown."));

assert_smi_msg_err_not_x_z:
 assert property( @(posedge clk) disable iff (~rst_n)
    (smi_msg_valid) |-> (!$isunknown(smi_msg_err)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_msg_err must not be unknown."));

assert_smi_dp_present_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (smi_msg_valid) |-> (!$isunknown(smi_dp_present)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_dp_present must not be unknown."));


//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------

// Signal Not Unknown properties : smi_dp_* signals must be not be X or Z.

assert_smi_dp_valid_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(smi_dp_valid)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_dp_valid must not be unknown."));

// remove because not use // cf VCS_double_drive //assert_smi_dp_ready_not_x_z:
// remove because not use // cf VCS_double_drive //  assert property( @(posedge clk) disable iff (~rst_n)
// remove because not use // cf VCS_double_drive //    (!$isunknown(smi_dp_ready)) )
// remove because not use // cf VCS_double_drive //else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_dp_ready must not be unknown."));

assert_smi_dp_last_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (smi_dp_valid) |-> (!$isunknown(smi_dp_last)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_dp_last must not be unknown."));

assert_smi_dp_data_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (smi_dp_valid) |-> (!$isunknown(smi_dp_data)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_dp_data must not be unknown."));

assert_smi_dp_user_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (smi_dp_valid) |-> (!$isunknown(smi_dp_user)) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_dp_user must not be unknown."));

//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------

// Handshake property : smi_msg_valid is eventually given a smi_msg_ready

assert_smi_msg_valid_eventually_given_smi_msg_ready:
  assert property( @(posedge clk) disable iff (~rst_n)
    (smi_msg_valid) |-> ##[0:$] (smi_msg_ready) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_msg_valid must have smi_msg_ready eventually."));

// Handshake property : smi_dp_valid is eventually given a smi_dp_ready

assert_smi_dp_valid_eventually_given_smi_dp_ready:
  assert property( @(posedge clk) disable iff (~rst_n)
    (smi_dp_valid) |-> ##[0:$] (smi_dp_ready) )
else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%>  SMI protocol violation: smi_dp_valid must have smi_dp_ready eventually."));
<% } %>

//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------
`endif //  `ifndef TT_DEBUG
////////////////////////////////////////////////////////////////////////////////
`ifndef TT_DEBUG
////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------
// ready must be deasserted on reset
 <%if(!obj.CUSTOMER_ENV) { %>
//assert_mst_req_vld_low_on_rstassert property (@(posedge clk) disable iff (MSTORSLV == "mst") 
//  assert property (@(posedge clk) 
//  else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%> MST a master asserted smi_msg_valid while in reset"))
/* 
assert_slv_req_rdy_low_on_rst:
  assert property (@(posedge clk)  
		   (~rst_n) |-> ((smi_msg_ready == 0) || (smi_msg_ready === 1'bx)))
       else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%> MST a slave asserted smi_msg_ready while in reset"))

assert_slv_rsp_vld_low_on_rst:
  assert property (@(posedge clk)  
		   (~rst_n) |-> ((smi_dp_valid == 0) || (smi_dp_valid === 1'bx)))
       else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%> MST a slave asserted smi_dp_valid while in reset"))
  
assert_mst_rsp_rdy_low_on_rst:
  assert property (@(posedge clk)  
		   (~rst_n) |-> ((smi_dp_ready == 0) || (smi_dp_ready === 1'bx)))
       else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%> MST a master asserted smi_dp_ready while in reset"))
       */
<% } %>
`endif //  `ifndef TT_DEBUG
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

    //VCS forbidden !!! VCS_double_drive !!! // Initializiing smi_ndp to non-zero because smi_ndp for different ports of one unit
    //VCS forbidden !!! VCS_double_drive !!! // can have different widths. If its not initialized, then MSB bits will be X/Zs
    //VCS forbidden !!! VCS_double_drive !!! //initial begin
    //VCS forbidden !!! VCS_double_drive !!! //    smi_ndp = '0;
    //VCS forbidden !!! VCS_double_drive !!! //    smi_dp_ready = 0;
    //VCS forbidden !!! VCS_double_drive !!! //end
//------------------------------------------------------------------------------
// Drive non-valid 
//------------------------------------------------------------------------------

  task automatic drive_ndp_nonvalid();
      <% if((((obj.Block == "chi_aiu") || ((obj.Block == "io_aiu"))) && obj.AiuInfo[0].ResilienceInfo.enableUnitDuplication) ||
            ((obj.Block == "dmi") && obj.DmiInfo[0].ResilienceInfo.enableUnitDuplication) ||
            ((obj.Block == "dce") && obj.DceInfo[0].ResilienceInfo.enableUnitDuplication) ||
//            ((obj.Block == "dii") && obj.DiiInfo[0].ResilienceInfo.enableUnitDuplication) ||
            ((obj.Block == "dve") && obj.DveInfo[0].ResilienceInfo.enableUnitDuplication)
           ) { %>
      bit drive_one;
      drive_one = $urandom_range(1,0);
      if (drive_one) begin
          transmitter_cb.smi_steer      <=  (1'b1 << WSMISTEER) - 1;
          transmitter_cb.smi_targ_id    <=  (1'b1 << WSMITGTID) - 1;
          transmitter_cb.smi_src_id     <=  (1'b1 << WSMISRCID) - 1;
          transmitter_cb.smi_msg_tier   <=  (1'b1 << WSMIMSGTIER) - 1;
          transmitter_cb.smi_msg_qos    <=  (1'b1 << WSMIMSGQOS) - 1;
          transmitter_cb.smi_msg_pri    <=  (1'b1 << WSMIMSGPRI) - 1;
          transmitter_cb.smi_msg_type   <=  (1'b1 << WSMIMSGTYPE) - 1;
          transmitter_cb.smi_ndp_len    <=  (1'b1 << WSMINDPLEN) - 1;
          transmitter_cb.smi_ndp        <=  (1'b1 << WSMINDP) - 1;
          transmitter_cb.smi_dp_present <=  (1'b1 << WSMIDPPRESENT) - 1;
          transmitter_cb.smi_msg_id     <=  (1'b1 << WSMIMSGID) - 1;
          transmitter_cb.smi_msg_user   <=  (1'b1 << WSMIMSGUSER) - 1;
          transmitter_cb.smi_msg_err    <=  (1'b1 << WSMIMSGERR) - 1;
      end
      else begin
          transmitter_cb.smi_steer      <=  'b0;
          transmitter_cb.smi_targ_id    <=  'b0;
          transmitter_cb.smi_src_id     <=  'b0;
          transmitter_cb.smi_msg_tier   <=  'b0;
          transmitter_cb.smi_msg_qos    <=  'b0;
          transmitter_cb.smi_msg_pri    <=  'b0;
          transmitter_cb.smi_msg_type   <=  'b0;
          transmitter_cb.smi_ndp_len    <=  'b0;
          transmitter_cb.smi_ndp        <=  'b0;
          transmitter_cb.smi_dp_present <=  'b0;
          transmitter_cb.smi_msg_id     <=  'b0;
          transmitter_cb.smi_msg_user   <=  'b0;
          transmitter_cb.smi_msg_err    <=  'b0;
      end
      <% } else { %>

      if ($test$plusargs("smi_idle_drive_rnd")) begin
         smi_steer_logic_t      tmp_smi_steer;
         smi_targ_id_logic_t    tmp_smi_targ_id;
         smi_src_id_logic_t     tmp_smi_src_id;
         smi_msg_tier_logic_t   tmp_smi_msg_tier;
         smi_msg_qos_logic_t    tmp_smi_msg_qos;
         smi_msg_pri_logic_t    tmp_smi_msg_pri;
         smi_msg_type_logic_t   tmp_smi_msg_type;
         smi_ndp_len_logic_t    tmp_smi_ndp_len;
         smi_ndp_logic_t        tmp_smi_ndp;
         smi_dp_present_logic_t tmp_smi_dp_present;
         smi_msg_id_logic_t     tmp_smi_msg_id;
         smi_msg_user_logic_t   tmp_smi_msg_user;
         smi_msg_err_logic_t    tmp_smi_msg_err;
     
         void'(std::randomize(tmp_smi_steer));
         void'(std::randomize(tmp_smi_targ_id));
         void'(std::randomize(tmp_smi_src_id));     
         void'(std::randomize(tmp_smi_msg_tier));
         void'(std::randomize(tmp_smi_msg_qos));
         void'(std::randomize(tmp_smi_msg_pri));
         void'(std::randomize(tmp_smi_msg_type));
         void'(std::randomize(tmp_smi_ndp_len));
         void'(std::randomize(tmp_smi_ndp));
         void'(std::randomize(tmp_smi_dp_present));
         void'(std::randomize(tmp_smi_msg_id));
         void'(std::randomize(tmp_smi_msg_user));
         void'(std::randomize(tmp_smi_msg_err));
     
         transmitter_cb.smi_steer      <=  tmp_smi_steer      ;
         transmitter_cb.smi_targ_id    <=  tmp_smi_targ_id    ;
         transmitter_cb.smi_src_id     <=  tmp_smi_src_id     ;
         transmitter_cb.smi_msg_tier   <=  tmp_smi_msg_tier   ;
         transmitter_cb.smi_msg_qos    <=  tmp_smi_msg_qos    ;
         transmitter_cb.smi_msg_pri    <=  tmp_smi_msg_pri    ;
         transmitter_cb.smi_msg_type   <=  tmp_smi_msg_type   ;
         transmitter_cb.smi_ndp_len    <=  tmp_smi_ndp_len    ;
         transmitter_cb.smi_ndp        <=  tmp_smi_ndp        ;
         transmitter_cb.smi_dp_present <=  tmp_smi_dp_present ;
         transmitter_cb.smi_msg_id     <=  tmp_smi_msg_id     ;
         transmitter_cb.smi_msg_user   <=  tmp_smi_msg_user   ;
         transmitter_cb.smi_msg_err    <=  tmp_smi_msg_err    ;
      end else begin
         transmitter_cb.smi_steer      <=  'bx ;
         transmitter_cb.smi_targ_id    <=  'bx ;
         transmitter_cb.smi_src_id     <=  'bx ;
         transmitter_cb.smi_msg_tier   <=  'bx ;
         transmitter_cb.smi_msg_qos    <=  'bx ;
         transmitter_cb.smi_msg_pri    <=  'bx ;
         transmitter_cb.smi_msg_type   <=  'bx ;
         transmitter_cb.smi_ndp_len    <=  'bx ;
         transmitter_cb.smi_ndp        <=  'bx ;
         transmitter_cb.smi_dp_present <=  'bx ;
         transmitter_cb.smi_msg_id     <=  'bx ;
         transmitter_cb.smi_msg_user   <=  'bx ;
         transmitter_cb.smi_msg_err    <=  'bx;
      end
<% } %>
      transmitter_cb.smi_msg_valid  <= 1'b0;
 endtask : drive_ndp_nonvalid 


  task automatic drive_dp_nonvalid();
      <% if((((obj.Block == "chi_aiu") || ((obj.Block == "io_aiu"))) && obj.AiuInfo[0].ResilienceInfo.enableUnitDuplication) ||
            ((obj.Block == "dmi") && obj.DmiInfo[0].ResilienceInfo.enableUnitDuplication) ||
            ((obj.Block == "dce") && obj.DceInfo[0].ResilienceInfo.enableUnitDuplication) ||
//            ((obj.Block == "dii") && obj.DiiInfo[0].ResilienceInfo.enableUnitDuplication) ||
            ((obj.Block == "dve") && obj.DveInfo[0].ResilienceInfo.enableUnitDuplication)
           ) { %>
      bit drive_one;
      drive_one = $urandom_range(1,0);
      if (drive_one) begin
         transmitter_cb.smi_dp_data  <=  (1'b1 << wSmiDPdata) - 1;
         transmitter_cb.smi_dp_user  <=  (1'b1 << wSmiDPuser) - 1;
         transmitter_cb.smi_dp_last  <=  (1'b1);
      end
      else begin
         transmitter_cb.smi_dp_data  <=  'b0;
         transmitter_cb.smi_dp_user  <=  'b0;
         transmitter_cb.smi_dp_last  <=  'b0;
      end
       <% } else { %>

    if ($test$plusargs("smi_idle_drive_rnd")) begin
       smi_dp_data_logic_t tmp_data;
       smi_dp_user_logic_t tmp_user;
       smi_dp_last_logic_t tmp_last;
 
       void'(std::randomize(tmp_data));
       void'(std::randomize(tmp_user));
       void'(std::randomize(tmp_last));     

       transmitter_cb.smi_dp_data  <=  tmp_data;
       transmitter_cb.smi_dp_user  <=  tmp_user;
       transmitter_cb.smi_dp_last  <=  tmp_last;
    end else begin
       transmitter_cb.smi_dp_data  <=  'bx;
       transmitter_cb.smi_dp_user  <=  'bx;
       transmitter_cb.smi_dp_last  <=  'bx;
    end
    <% } %>
    transmitter_cb.smi_dp_valid <=  'b0;
  endtask : drive_dp_nonvalid 

  task automatic drive_smi_rx_nonready();
      receiver_cb.smi_msg_ready <= 1'b0;
      receiver_cb.smi_dp_ready <= 1'b0;
  endtask : drive_smi_rx_nonready
  /*
  task automatic drive_dp_nonready();
      receiver_cb.smi_dp_ready <= 1'b0;
  endtask : drive_dp_nonready 
  */

//------------------------------------------------------------------------------
// Drive NDP interface
//------------------------------------------------------------------------------
  task automatic drive_ndp(smi_seq_item pkt, bit valid = 1);
      if (rst_n == 0) begin
          return;
      end
      wait (rst_n == 1);
      if (valid) begin
          m_drv_ndp_mb.put(pkt);
      end
  endtask : drive_ndp
//force ready for SMI NDP  RX for perf monitor test
 logic force_smi_msg_ready;
 logic force_smi_msg_valid;
 initial begin
     forever begin
         @(posedge clk) ; 
         force_smi_msg_ready = 1'bz;
         force_smi_msg_valid = 1'bz;
         if (en_tx_stall == 1 ) begin
          repeat(20) @(posedge clk) ;
          force_smi_msg_ready = 0;
          force_smi_msg_valid = 1;
          repeat($urandom_range(3,15)) @(posedge clk) ;
          force_smi_msg_ready = 0;
          force_smi_msg_valid = 1;
           @(posedge clk) ;
          force_smi_msg_ready = 1'bz;
          force_smi_msg_valid = 1'bz;
          @(posedge clk) ; 
          break;
         end
     end 
 end 
 
  initial begin
      #1
      if (is_active && !is_receiver) begin
          int  m_dly;
          bit  done;
          bit  was_ready_set_already;
          time t_start_time;
          smi_seq_item pkt;

<% if(obj.Block == "io_aiu") { %>
          static    uvm_event_pool ev_pool     = uvm_event_pool::get_global_pool();
          automatic uvm_event ev_delay_smi_msg = ev_pool.get("ev_delay_smi_msg");
<% }%>
          forever begin
              if (m_drv_ndp_mb.num() > 0) begin
                  pkt = new();
                  m_drv_ndp_mb.get(pkt);
                  m_dly = ($urandom_range(1,100) <= k_burst_pct) ? 0 : ($urandom_range(k_delay_min, k_delay_max));
                  was_ready_set_already = 1;
                  t_start_time            = $time;
                  done                    = 0;
<% if(obj.Block == "io_aiu") { %>
                  if(ev_delay_smi_msg.is_on()) begin
                    m_dly = 25000; //value is provided by designer to make sure the bubble is large enough to enter the starvation mode
                    ev_delay_smi_msg.reset();
                  end
<% } %>
                  //`uvm_info($psprintf("%s SMI_NDP", interface_name), $psprintf("Time %0t Reached here 1 valid %0d ready %0dt_start_time %0t", $time, smi_msg_valid, smi_msg_ready, t_start_time), UVM_HIGH)
                  do begin
                      if (m_dly > 0) begin
                          drive_ndp_nonvalid();
                          @(transmitter_cb);
                          if (rst_n == 0) begin
                              break;
                          end
                          m_dly--;
                      end
                      else begin
                          //`uvm_info($psprintf("%s SMI_NDP", interface_name), $psprintf("Time %0t Reached here 2 valid %0d ready %0dt_start_time %0t", $time, smi_msg_valid, smi_msg_ready, t_start_time), UVM_HIGH)
                          transmitter_cb.smi_msg_valid  <= 1'b1;
                          transmitter_cb.smi_steer      <= pkt.smi_steer  ;
                          transmitter_cb.smi_targ_id    <= pkt.smi_targ_id;
                          transmitter_cb.smi_src_id     <= pkt.smi_src_id;
                          transmitter_cb.smi_msg_tier   <= pkt.smi_msg_tier;
                          transmitter_cb.smi_msg_qos    <= pkt.smi_msg_qos;
                          transmitter_cb.smi_msg_pri    <= pkt.smi_msg_pri;
                          transmitter_cb.smi_msg_type   <= pkt.smi_msg_type;
                          transmitter_cb.smi_ndp_len    <= pkt.smi_ndp_len;
                          transmitter_cb.smi_ndp        <= pkt.smi_ndp;
                          transmitter_cb.smi_dp_present <= pkt.smi_dp_present;
                          transmitter_cb.smi_msg_id     <= pkt.smi_msg_id;
			  <% if (obj.AiuInfo[0].useResiliency) { %>
                          transmitter_cb.smi_msg_user   <= pkt.smi_msg_user;
                          <% } else { %>
                          transmitter_cb.smi_msg_user   <= 'h0;
                          <% } %>
                          transmitter_cb.smi_msg_err    <= pkt.smi_msg_err;
                          if (transmitter_cb.smi_msg_ready && (t_start_time !== $time)) begin
                              done = 1;
                              //`uvm_info($psprintf("%s SMI_NDP", interface_name), $psprintf("Time %0t Reached here 3 valid %0d ready %0dt_start_time %0t", $time, smi_msg_valid, smi_msg_ready, t_start_time), UVM_HIGH)
                          end
                          else begin
                              was_ready_set_already = 0;
                          end
                          if (!done || was_ready_set_already) begin
                              //`uvm_info($psprintf("%s SMI_NDP", interface_name), $psprintf("Time %0t Reached here 4 valid %0d ready %0dt_start_time %0t NDP MsgId %0x", $time, smi_msg_valid, smi_msg_ready, t_start_time, pkt.smi_msg_id), UVM_HIGH)
                              @(transmitter_cb);
                              //`uvm_info($psprintf("%s SMI_NDP", interface_name), $psprintf("Time %0t Reached here 5 valid %0d ready %0dt_start_time %0t NDP MsgId %0x", $time, smi_msg_valid, smi_msg_ready, t_start_time, pkt.smi_msg_id), UVM_HIGH)
                              if (rst_n == 0) begin
                                  break;
                              end
                          end
                      end
                  end while (!done);
              end
              else begin
                  drive_ndp_nonvalid();
                  @(transmitter_cb);
                  //$display("%t: Waiting for new packet", $time);
              end
          end
      end
  end

//------------------------------------------------------------------------------
// Drive DP interface
//------------------------------------------------------------------------------
  task automatic drive_dp(smi_seq_item pkt, bit valid = 1);
      if (rst_n == 0) begin
          return;
      end
      wait (rst_n == 1);
      if (valid) begin
          m_drv_dp_mb.put(pkt);
      end
  endtask : drive_dp
  initial begin
      #1
      if (is_active && !is_receiver) begin
          int  m_dly;
          bit  done;
          bit  was_ready_set_already;
          time t_start_time;
          smi_seq_item pkt;
          forever begin
              if (m_drv_dp_mb.num() > 0) begin
                  pkt = new();
                  m_drv_dp_mb.get(pkt);
                  m_dly = ($urandom_range(1,100) <= k_burst_pct) ? 0 : ($urandom_range(k_delay_min, k_delay_max));
                  was_ready_set_already = 1;
                  t_start_time            = $time;
                  done                    = 0;
                  //`uvm_info($psprintf("%s SMI_DP", interface_name), $psprintf("Time %0t Reached here 1 valid %0d ready %0d last %0d t_start_time %0t data 0x%0x", $time, smi_dp_valid, smi_dp_ready, smi_dp_last, t_start_time, smi_dp_data), UVM_HIGH)
                  `uvm_info($sformatf("%m"), $sformatf("DEBUG I0: %p delay:%0d mbsize:%0d", pkt.convert2string(), m_dly, m_drv_dp_mb.num()), UVM_HIGH)
                  do begin
                      if (m_dly > 0) begin
                          drive_dp_nonvalid();
                          @(transmitter_cb);
                          if (rst_n == 0) begin
                              break;
                          end
                          m_dly--;
                      end
                      else begin
                          //`uvm_info($psprintf("%s SMI_DP", interface_name), $psprintf("Time %0t Reached here 2 valid %0d ready %0d last %0d t_start_time %0t data 0x%0x", $time, smi_dp_valid, smi_dp_ready, smi_dp_last, t_start_time, smi_dp_data), UVM_HIGH)
                          transmitter_cb.smi_dp_valid <= 1'b1;
                          transmitter_cb.smi_dp_last  <= pkt.smi_dp_last;
                          transmitter_cb.smi_dp_data  <= pkt.smi_dp_data[0];
                          transmitter_cb.smi_dp_user  <= pkt.smi_dp_user[0];
                          if (transmitter_cb.smi_dp_ready && ((t_start_time !== $time) || was_ready_set_already)) begin
                              `uvm_info($sformatf("%m"), $sformatf("DEBUG I2: %p", pkt.convert2string()), UVM_HIGH)
                          end
                          if (transmitter_cb.smi_dp_ready && (t_start_time !== $time)) begin
                              done = 1;
                              //`uvm_info($psprintf("%s SMI_DP", interface_name), $psprintf("Time %0t Reached here 3 valid %0d ready %0d last %0d t_start_time %0t data 0x%0x", $time, smi_dp_valid, smi_dp_ready, smi_dp_last, t_start_time, smi_dp_data), UVM_HIGH)
                          end
                          else begin
                              was_ready_set_already = 0;
                          end
                          if (!done || was_ready_set_already) begin
                              //`uvm_info($psprintf("%s SMI_DP", interface_name), $psprintf("Time %0t Reached here 4 valid %0d ready %0d last %0d t_start_time %0t data 0x%0x", $time, smi_dp_valid, smi_dp_ready, smi_dp_last, t_start_time, smi_dp_data), UVM_HIGH)
                              @(transmitter_cb);
                              //`uvm_info($psprintf("%s SMI_DP", interface_name), $psprintf("Time %0t Reached here 5 valid %0d ready %0d last %0d t_start_time %0t data 0x%0x", $time, smi_dp_valid, smi_dp_ready, smi_dp_last, t_start_time, smi_dp_data), UVM_HIGH)
                              if (rst_n == 0) begin
                                  break;
                              end
                          end
                      end
                  end while (!done);
              end
              else begin
                 drive_dp_nonvalid(); 
                 @(transmitter_cb);
              end
          end
      end
  end
//------------------------------------------------------------------------------
// Perf counter clear stall function
//------------------------------------------------------------------------------
function void   smi_clear_stalls(int cnt_id);
   en_rx_stall  = 0 ;
endfunction: smi_clear_stalls

//------------------------------------------------------------------------------
// Drive NDP ready 
//------------------------------------------------------------------------------
  task automatic drive_smi_rx_ready(bit ready = 1);
      int m_dly;
	  int asserted_ready_dly;
      bit done;
      if (my_smi_rx_id == 0) begin
         if (! $value$plusargs("rx0_nordy_min=%d", force_rdy_dly_min)) begin
            force_rdy_dly_min = 0;
         end
         if ($value$plusargs("rx0_nordy_max=%d", force_rdy_dly_max)) begin
            assert(std::randomize(m_dly) with { m_dly inside {[force_rdy_dly_min:force_rdy_dly_max]};
                                                m_dly dist { force_rdy_dly_min := 6, [force_rdy_dly_min:force_rdy_dly_max] := 2, force_rdy_dly_max := 2}; });
         end else begin
            force_rdy_dly_max = 0;
			if($test$plusargs("smi_burst_delay_mode")) begin
                k_delay_min = $urandom_range(800,1000);
                k_delay_max = $urandom_range(k_delay_min, 1500);
                k_burst_pct = $urandom_range(80,100);
                asserted_ready_dly = $urandom_range(200,400);
                m_dly = $urandom_range(k_delay_min, k_delay_max);
                //assert(std::randomize(m_dly) with { m_dly inside {[k_delay_min:k_delay_max]};
                                                //m_dly dist { k_delay_min := 1, [k_delay_min:k_delay_max] := 4, k_delay_max := 5}; });
                //m_dly = ($urandom_range(50,100) <= k_burst_pct) ? $urandom_range(k_delay_min, k_delay_max) : 0;
			end else
                m_dly = ($urandom_range(1,100) <= k_burst_pct) ? 0 : ($urandom_range(k_delay_min, k_delay_max));

         end
      end else if (my_smi_rx_id == 1) begin
         if (! $value$plusargs("rx1_nordy_min=%d", force_rdy_dly_min)) begin
            force_rdy_dly_min = 0;
         end
         if ($value$plusargs("rx1_nordy_max=%d", force_rdy_dly_max)) begin
            assert(std::randomize(m_dly) with { m_dly inside {[force_rdy_dly_min:force_rdy_dly_max]};
                                                m_dly dist { force_rdy_dly_min := 6, [force_rdy_dly_min:force_rdy_dly_max] := 2, force_rdy_dly_max := 2}; });
         end else begin
            force_rdy_dly_max = 0;
            m_dly = ($urandom_range(1,100) <= k_burst_pct) ? 0 : ($urandom_range(k_delay_min, k_delay_max));
         end
      end else if (my_smi_rx_id == 2) begin
         if (! $value$plusargs("rx2_nordy_min=%d", force_rdy_dly_min)) begin
            force_rdy_dly_min = 0;
         end
         if ($value$plusargs("rx2_nordy_max=%d", force_rdy_dly_max)) begin
            assert(std::randomize(m_dly) with { m_dly inside {[force_rdy_dly_min:force_rdy_dly_max]};
                                                m_dly dist { force_rdy_dly_min := 6, [force_rdy_dly_min:force_rdy_dly_max] := 2, force_rdy_dly_max := 2}; });
         end else begin
            force_rdy_dly_max = 0;
            m_dly = ($urandom_range(1,100) <= k_burst_pct) ? 0 : ($urandom_range(k_delay_min, k_delay_max));
         end
      end // if (my_smi_rx_id == 2)
//     `uvm_info($sformatf("%m"), $sformatf("stall_en=%0d, stall_period=%0d, force_delay_min=%0d, force_delay_max=%0d m_dly=%0d",
//                                          en_rx_stall, stall_period, force_rdy_dly_min, force_rdy_dly_max, m_dly), UVM_HIGH)
      wait (rst_n == 1);
      if(interface_name == "m_smi1_rx"  && $test$plusargs("conc9307_test")) begin
        evt_assert_dtw_rsp_ready.wait_trigger();
        `uvm_info("dmi_scoreboard", "evt_assert_dtw_rsp_ready trigger recieved", UVM_DEBUG)
        receiver_cb.smi_msg_ready <= 1'b1;
        receiver_cb.smi_dp_ready <= 1'b1;
      end

      // YRAMASMAY
      // for single_step testing which is aimed at validating latency, no backpressure is expected
      // and hence m_dly can be set to '0'
      if($test$plusargs("single_step")) begin
        m_dly = 0;
      end
     //`uvm_info($sformatf("%m"), $sformatf("en_rx_stall=%0d, stall_period=%0d, force_delay_min=%0d, force_delay_max=%0d m_dly=%0d",en_rx_stall, stall_period, force_rdy_dly_min, force_rdy_dly_max, m_dly), UVM_LOW)

      do begin
          @(receiver_cb);
          if (ready) begin : LP1
              if (m_dly == 0) begin
                 if ( smi_msg_valid == 1 && bloc_smi_stall == 1 ) begin
                    receiver_cb.smi_msg_ready <= 1'b0;
                    receiver_cb.smi_dp_ready <= 1'b0;
                    cnt_rdy_blckd_duration++;
                    if ( cnt_rdy_blckd_duration == RDY_NOT_ASSERTED_DURATION ) begin
                        cnt_rdy_blckd_duration = 0;
                        bloc_smi_stall         = 0;
                    end 
                 end 
                else
                 if (smi_msg_valid == 1 && en_rx_stall == 1 ) begin
                    receiver_cb.smi_msg_ready <= 1'b0;
                    receiver_cb.smi_dp_ready <= 1'b0;
                     for (int i = 0; i <= stall_period; i++) begin
                        if (en_rx_stall == 0) begin 
                             break;
                        end
                        @(posedge clk) ; 
                     end
                     //cnt_stall++;
                    receiver_cb.smi_msg_ready <= 1'b1;
                    receiver_cb.smi_dp_ready <= 1'b1;
                     @(posedge clk) ;
                     /*if (cnt_stall == stall_number) begin
                        en_rx_stall = 0;
                        cnt_stall   = 0;
                     end */
                 end 
                 else begin
                  receiver_cb.smi_msg_ready <= 1'b1;
                  receiver_cb.smi_dp_ready <= 1'b1;
				  if(m_dly == 0) begin
				      repeat(asserted_ready_dly) 
				      @(posedge clk);
				  end
                 end
              end
              else begin
                  receiver_cb.smi_msg_ready <= m_dly > 0 ? 1'b0 : 1'b1;
                  receiver_cb.smi_dp_ready  <= m_dly > 0 ? 1'b0 : 1'b1;
              end
          end // block: LP1
          else begin
              receiver_cb.smi_msg_ready <= m_dly > 0 ? 1'b0 : 1'b1;
              receiver_cb.smi_dp_ready  <= m_dly > 0 ? 1'b0 : 1'b1;
          end

          done = m_dly ? 0 : 1;
          if (m_dly) m_dly--;
      end while (!done);  
  endtask : drive_smi_rx_ready

//------------------------------------------------------------------------------
// Drive DP ready: Below task not used 
//------------------------------------------------------------------------------
/*
  task automatic drive_dp_ready(bit ready = 1);
      int m_dly;
      bit done;

      m_dly = ($urandom_range(1,100) <= k_burst_pct) ? 0 : ($urandom_range(k_delay_min, k_delay_max));
      wait (rst_n == 1);
      do begin
          @(receiver_cb);
          if (ready) begin
              if (m_dly == 0) begin
                  receiver_cb.smi_dp_ready <= 1'b1;
              end
              else begin
                  receiver_cb.smi_dp_ready <= 1'b0;
              end
          end 
          else begin
              receiver_cb.smi_dp_ready <= 1'b0;
          end

          done = m_dly ? 0 : 1;
          if (m_dly) m_dly--;
      end while (!done);  
  endtask : drive_dp_ready
*/

//------------------------------------------------------------------------------
// Collect NDP
//------------------------------------------------------------------------------
  task automatic collect_ndp(ref smi_seq_item pkt);
      automatic bit first_pass = 1;
      automatic bit done = 0;
  
      while (!done) begin
          @(monitor_cb);
	  //not needed as sending empty packet to monitor
          //if (rst_n == 0) begin
          //    return;
          //end
          if (smi_msg_valid && first_pass) begin
              pkt.t_smi_ndp_valid = $time;
              pkt.smi_msg_valid  = 1;
              first_pass = 0;
          end
          if (smi_msg_valid & monitor_cb.smi_msg_ready) begin
              pkt.t_smi_ndp_ready = $time;
              pkt.smi_msg_ready  = 1;
              pkt.smi_steer      = monitor_cb.smi_steer;
              pkt.smi_targ_id    = monitor_cb.smi_targ_id;
              pkt.smi_src_id     = monitor_cb.smi_src_id;
              pkt.smi_msg_tier   = monitor_cb.smi_msg_tier;
              pkt.smi_msg_qos    = monitor_cb.smi_msg_qos;
              pkt.smi_msg_pri    = monitor_cb.smi_msg_pri;
              pkt.smi_msg_type   = monitor_cb.smi_msg_type;
              pkt.smi_ndp_len    = monitor_cb.smi_ndp_len;
              pkt.smi_ndp        = monitor_cb.smi_ndp;
              pkt.smi_dp_present = monitor_cb.smi_dp_present;
              pkt.smi_msg_id     = monitor_cb.smi_msg_id;
              <% if (obj.AiuInfo[0].useResiliency) { %>
              pkt.smi_msg_user   = monitor_cb.smi_msg_user;
              <% } else { %>
              pkt.smi_msg_user   = 'h0;
              <% } %>
              pkt.smi_msg_err    = monitor_cb.smi_msg_err;
              done               = 1;
          end
      end 
  endtask : collect_ndp

  task automatic collect_dp(ref smi_seq_item pkt);
      bit first_pass = 1;
      bit done = 0;
  
      while (!done) begin
          @(monitor_cb);
          //if (rst_n == 0) begin
          //    return;
          //end
          if (smi_dp_valid && first_pass) begin
              pkt.t_smi_dp_valid    = new[1];
              pkt.t_smi_dp_valid[0] = $time;
              pkt.smi_dp_valid      = 1;
              first_pass            = 0;
          end
          if (smi_dp_valid & monitor_cb.smi_dp_ready) begin
              pkt.t_smi_dp_ready    = new[1];
              pkt.t_smi_dp_ready[0] = $time;
              pkt.smi_dp_ready      = 1;
              pkt.smi_dp_last       = monitor_cb.smi_dp_last;
              pkt.smi_dp_data       = new [1];
              pkt.smi_dp_data[0]    = monitor_cb.smi_dp_data;
              pkt.smi_dp_user       = new [1];
              pkt.smi_dp_user[0]    = monitor_cb.smi_dp_user;
              done                  = 1;
              `uvm_info($sformatf("%m"), $sformatf("DEBUG O0: pkt:%p", pkt.convert2string()), UVM_HIGH)
          end
      end
  endtask : collect_dp

  //----------------------------------------------------------------------- 
  // Initial block where we vary speeds of the BFM over time 
  //----------------------------------------------------------------------- 

  initial begin
      #0;
      if (is_active) begin
          if (k_is_bfm_delay_changing) begin
              int random_start;

              random_start = $urandom_range(0, k_delay_changing_time_period); 
              #(random_start * 1ns);
              forever begin
                  k_delay_min = $urandom_range(1,25);
                  k_delay_max = $urandom_range(k_delay_min, 100);
                  k_burst_pct = $urandom_range(5,100);
                  #(k_delay_changing_time_period * 1ns);
                  k_delay_changing_time_period = $urandom_range(5000, 50000);
              end
          end
      end
  end

////////////////////////////////////////////////////////////////////////////////

<%if(!obj.CUSTOMER_ENV) { %>
//Ready Timeout counter logic
initial begin
    int sample_period;
    if (! $value$plusargs("SMI_READY_SAMPLE_PERIOD=%d", sample_period)) begin
       sample_period = 10000;
    end
    void'( $value$plusargs("RDY_NOT_ASSERTED_TIMEOUT=%0d", RDY_NOT_ASSERTED_TIMEOUT) );

    ndp_rdy_timeout_counter <= 0;
    dp_rdy_timeout_counter  <= 0;
    forever begin
        @(monitor_cb)
        if(smi_msg_valid && !smi_msg_ready) begin
            ndp_rdy_timeout_counter <= ndp_rdy_timeout_counter + 1;
        end else begin
            ndp_rdy_timeout_counter <= 0;
        end
        if(smi_dp_valid && !smi_dp_ready) begin
            dp_rdy_timeout_counter <= dp_rdy_timeout_counter + 1;
        end else begin
            dp_rdy_timeout_counter <= 0;
        end
        if ((ndp_rdy_timeout_counter > 0) && ((ndp_rdy_timeout_counter % sample_period) == 0)) begin
           `uvm_info($sformatf("%m"), $sformatf("RT_DBG: <%=obj.BlockId%> %s smi_msg_vld asserted, but smi_msg_ready not asserted for %0d cycles", interface_name, ndp_rdy_timeout_counter), UVM_MEDIUM)
        end
        if ((dp_rdy_timeout_counter > 0) && ((dp_rdy_timeout_counter % sample_period) == 0)) begin
           `uvm_info($sformatf("%m"), $sformatf("RT_DBG: <%=obj.BlockId%> %s smi_dp_vld asserted, but smi_dp_ready not asserted for %0d cycles", interface_name, dp_rdy_timeout_counter), UVM_MEDIUM)
        end
    end
end
//`ifdef CREDIT_ASSERT
<%if(obj.testBench == "fsys" || obj.testBench == "emu"){ %>
`ifdef VCS
logic expr_assert_strict_no_bkpressure;
assign expr_assert_strict_no_bkpressure = (msg_t.type2class(smi_msg_type) == eConcMsgCmdReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgCCmdRsp||
						msg_t.type2class(smi_msg_type) == eConcMsgSnpReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgSnpRsp ||
						msg_t.type2class(smi_msg_type) == eConcMsgMrdReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgMrdRsp ||
						msg_t.type2class(smi_msg_type) == eConcMsgStrReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgStrRsp ||
						msg_t.type2class(smi_msg_type) == eConcMsgRbReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgRbRsp ||
						msg_t.type2class(smi_msg_type) == eConcMsgRbUseReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgRbUseRsp||
						msg_t.type2class(smi_msg_type) == eConcMsgUpdRsp ||
						msg_t.type2class(smi_msg_type) == eConcMsgDtwRsp ||
						    msg_t.type2class(smi_msg_type) == eConcMsgDtrRsp);
`endif

assert_strict_no_bkpressure:
    assert property(@(monitor_cb) smi_msg_valid && is_receiver && 
`ifndef VCS
                                               (msg_t.type2class(smi_msg_type) == eConcMsgCmdReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgCCmdRsp||
						msg_t.type2class(smi_msg_type) == eConcMsgSnpReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgSnpRsp ||
						msg_t.type2class(smi_msg_type) == eConcMsgMrdReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgMrdRsp ||
						msg_t.type2class(smi_msg_type) == eConcMsgStrReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgStrRsp ||
						msg_t.type2class(smi_msg_type) == eConcMsgRbReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgRbRsp ||
						msg_t.type2class(smi_msg_type) == eConcMsgRbUseReq ||
						msg_t.type2class(smi_msg_type) == eConcMsgRbUseRsp||
						msg_t.type2class(smi_msg_type) == eConcMsgUpdRsp ||
						msg_t.type2class(smi_msg_type) == eConcMsgDtwRsp ||
						    msg_t.type2class(smi_msg_type) == eConcMsgDtrRsp)	
`else
                                                expr_assert_strict_no_bkpressure
`endif
                                                    |-> smi_msg_ready)
    else  `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s smi_msg_type:'h%x", interface_name, "<%=obj.BlockId%> smi_msg_ready not asserted immediately while smi_msg_valid is asserted.", smi_msg_type));

`ifdef VCS
logic expr_assert_dtwreq_bkpressure;
logic expr_assert_updreq_bkpressure;
assign expr_assert_dtwreq_bkpressure = (msg_t.type2class(smi_msg_type) == eConcMsgDtwReq);
assign expr_assert_updreq_bkpressure = (msg_t.type2class(smi_msg_type) == eConcMsgUpdReq);
`endif

assert_dtwreq_bkpressure:
`ifdef VCS
    assert property(@(monitor_cb) smi_msg_valid && is_receiver && expr_assert_dtwreq_bkpressure |-> ##[0:DTWREQ_DELAY] smi_msg_ready)
`else
    assert property(@(monitor_cb) smi_msg_valid && is_receiver && (msg_t.type2class(smi_msg_type) == eConcMsgDtwReq) |-> ##[0:DTWREQ_DELAY] smi_msg_ready)
`endif
    else  `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%> DTW Req smi_msg_ready not asserted immediately while smi_msg_valid is asserted."));

assert_updreq_bkpressure:
`ifdef VCS
    assert property(@(monitor_cb) smi_msg_valid && is_receiver && expr_assert_updreq_bkpressure |-> ##[0:UPDREQ_DELAY] smi_msg_ready)
`else
    assert property(@(monitor_cb) smi_msg_valid && is_receiver && (msg_t.type2class(smi_msg_type) == eConcMsgUpdReq) |-> ##[0:UPDREQ_DELAY] smi_msg_ready)
`endif
    else  `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s", interface_name, "<%=obj.BlockId%> UDP Req smi_msg_ready not asserted immediately while smi_msg_valid is asserted."));
<%}%>
//`endif

assert_ndp_vld_set_rdy_nset:
    assert property(@(monitor_cb) ndp_rdy_timeout_counter < RDY_NOT_ASSERTED_TIMEOUT)
    else begin
       `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s (%0d cycles)", interface_name,
                                        "<%=obj.BlockId%> smi_msg_ready not asserted while smi_msg_valid is asserted timeout", RDY_NOT_ASSERTED_TIMEOUT));
        error_quit_count++;
        if (error_quit_count > 1000) $finish;
    end

assert_dp_vld_set_rdy_nset:
    assert property(@(monitor_cb) dp_rdy_timeout_counter < RDY_NOT_ASSERTED_TIMEOUT)
    else `ASSERT_ERROR("ERROR", $psprintf("<%=obj.BlockId%> %s %s (%d cycles)", interface_name, "<%=obj.BlockId%> smi_dp_ready not asserted while smi_dp_valid is asserted timeout", RDY_NOT_ASSERTED_TIMEOUT));
<% } %>


endinterface

