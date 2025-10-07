////////////////////////////////////////////////////////////////////////////////
//
// Q channel Interface
//
////////////////////////////////////////////////////////////////////////////////

 <% if (obj.testBench != "emu_t" ) { %>
import uvm_pkg::*;
`include "uvm_macros.svh" <% } %>

<% if (obj.testBench=="fsys" || obj.testBench=="emu_t" || obj.testBench=="emu" || obj.testBench=="cust_tb") { %> 
interface concerto_q_chnl_if (input clk, input rst_n);
// pragma attribute concerto_q_chnl_if partition_interface_xif
<% } else { %>
interface <%=obj.BlockId%>_q_chnl_if (input clk, input rst_n);
<% } %>

 <% if (obj.testBench != "emu_t" ) { %>
   import q_chnl_agent_pkg::*; <% } %>

   typedef enum bit [2:0] {Q_RUN,Q_REQUEST,Q_STOPPED,Q_EXIT,Q_DENIED,Q_CONTINUE} state_t;
   state_t state;
   state_t state_next;

  //----------------------------------------------------------------------- 
  // Delay values used in this interface
  //-----------------------------------------------------------------------
  // bunch up requests together
   parameter qchnl_setup_time = 10ps;
   parameter qchnl_hold_time = 0;
  // Assuming Qchannel is common
   parameter qchnl_enabled = <%=obj.AiuInfo[0].usePma%>;
                             
  //-----------------------------------------------------------------------
  // Event to cut the clock supply to the DUT 
  //-----------------------------------------------------------------------
 <% if (obj.testBench != "emu_t" ) { %>
   uvm_event                    toggle_clk; <% } %>

  //-----------------------------------------------------------------------
  // Q Signals
  //-----------------------------------------------------------------------

   logic                      QREQn=0;
   logic                      QACCEPTn;
   logic                      QDENY;
   logic                      QACTIVE;
   bit [2:0]                  IF_state_before_req;

  //-----------------------------------------------------------------------
  // Q channel clocking blocks 
  //-----------------------------------------------------------------------

  /**
   * Clocking block that defines the Q channel Interface
   */
   clocking q_chnl_master_cb @(posedge clk);

     default input #1step output #qchnl_hold_time;
     input  rst_n;

     input  QACCEPTn;
     input  QDENY;
     input  QACTIVE;

     output QREQn;

  endclocking : q_chnl_master_cb

   clocking q_chnl_monitor_cb @(posedge clk);

     default input #1step;
     input  rst_n;

     input  QACCEPTn;
     input  QDENY;
     input  QACTIVE;
                      
     input  QREQn;

  endclocking : q_chnl_monitor_cb


  initial begin
 <% if (obj.testBench != "emu_t" ) { %>
     #0;
     toggle_clk = new("toggle_clk");
     if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                     .inst_name(""),
                                     .field_name( "toggle_clk" ),
                                     .value( toggle_clk ))) begin
        `uvm_error("Q-chnl IF", "Event toggle_clk is not found")
     end <% } %>

  end


  //----------------------------------------------------------------------- 
  // Drive Q channel
  //----------------------------------------------------------------------- 
 <% if (obj.testBench != "emu_t" ) { %>
  task automatic drive_q_channel(ref q_chnl_seq_item pkt);
  // pragma tbx xtf

    bit  done=0;
    time t_start_time;
    bit temp_QACCEPTn;
    bit temp_QDENY;

    @(q_chnl_master_cb);

    temp_QACCEPTn = q_chnl_master_cb.QACCEPTn;
    temp_QDENY    = q_chnl_master_cb.QDENY;

    pkt.IF_state_before_req = state;

    if (pkt.QREQn !== q_chnl_monitor_cb.QREQn) begin
       pkt.QACTIVE             = q_chnl_monitor_cb.QACTIVE;
       q_chnl_master_cb.QREQn <=  pkt.QREQn;
       t_start_time            = $time;
       wait ((q_chnl_master_cb.QACCEPTn != temp_QACCEPTn) || (q_chnl_master_cb.QDENY != temp_QDENY));
       pkt.QACCEPTn = q_chnl_master_cb.QACCEPTn;
       pkt.QDENY    = q_chnl_master_cb.QDENY;
    end

  endtask : drive_q_channel <% } %>

  //----------------------------------------------------------------------- 
  // Collect packet from Q channel
  //----------------------------------------------------------------------- 

 <% if (obj.testBench != "emu_t" ) { %>
  task automatic collect_q_channel(ref q_chnl_seq_item pkt);
  // pragma tbx xtf

    time t_start_time;
    bit  temp_QREQn;
    bit  temp_QACCEPTn;
    bit  temp_QDENY;

    //To detect change in interface state
    temp_QREQn    = q_chnl_monitor_cb.QREQn;
    temp_QACCEPTn = q_chnl_monitor_cb.QACCEPTn;
    temp_QDENY    = q_chnl_monitor_cb.QDENY;

    //@(q_chnl_monitor_cb);

    t_start_time  = $time;

    pkt.IF_state_before_req = state;
    //pkt.QACTIVE = q_chnl_monitor_cb.QACTIVE;

    wait (q_chnl_monitor_cb.QREQn != temp_QREQn);
        pkt.QREQn = q_chnl_monitor_cb.QREQn;

    wait ((q_chnl_monitor_cb.QACCEPTn != temp_QACCEPTn) || (q_chnl_monitor_cb.QDENY != temp_QDENY));
        pkt.QACCEPTn = q_chnl_monitor_cb.QACCEPTn;
        pkt.QDENY    = q_chnl_monitor_cb.QDENY;
        pkt.QACTIVE = q_chnl_monitor_cb.QACTIVE;

  endtask : collect_q_channel <% } %>

<% if (obj.testBench != "emu_t" ) { %>
  // Q-channel FSM

    // Sequential logic for state update
    always_ff @(posedge clk) begin
        if (!rst_n)
            state <= Q_RUN;
        else
            state <= state_next;
    end

    // Combinational logic for next state
    always_comb begin
        state_next = state;
        case (state)
            Q_RUN: begin
                if (!q_chnl_monitor_cb.QREQn) state_next = Q_REQUEST;
            end
            Q_REQUEST: begin
                if (!q_chnl_monitor_cb.QACCEPTn) state_next = Q_STOPPED;
                else if (q_chnl_monitor_cb.QDENY) state_next = Q_DENIED;
            end
            Q_STOPPED: begin
                if (q_chnl_monitor_cb.QREQn) state_next = Q_EXIT;
            end
            Q_EXIT: begin
                if (q_chnl_monitor_cb.QACCEPTn) state_next = Q_RUN;
            end
            Q_DENIED: begin
                if (q_chnl_monitor_cb.QREQn) state_next = Q_CONTINUE;
            end
            Q_CONTINUE: begin
                if (!q_chnl_monitor_cb.QDENY) state_next = Q_RUN;
            end
        endcase
    end

    // Trigger UVM event based on state transitions
    always_ff @(posedge clk) begin
        if ((state == Q_REQUEST && state_next == Q_STOPPED) ||
            (state == Q_STOPPED && state_next == Q_EXIT)) begin
            toggle_clk.trigger();
        end
    end

<% } %>

//----------------------------------------------------------------------- 
// Asserts for Q channel protocol 
//-----------------------------------------------------------------------

// QACCEPTn must assert (1->0) when QACTIVE is low (0)
property acceptn_h_l_assert;
   @(posedge clk) disable iff(!rst_n || !qchnl_enabled)
   $fell(QACCEPTn) |-> !QACTIVE;
endproperty

//Block will go into Power up state (QACTIVE -> 1) once QREQn deassert (QREQn -> 1)
property power_up_req_cond_assert;
   @(posedge clk) disable iff(!rst_n || !qchnl_enabled)
   $rose(QACTIVE) |-> QREQn;
endproperty

//Block will go into Power up state (QACTIVE -> 1) once QACTIVEn deassert (QACCEPTn -> 1)
property power_up_accept_cond_assert;
   @(posedge clk) disable iff(!rst_n || !qchnl_enabled)
   $rose(QACTIVE) |-> QACCEPTn;
endproperty

//QREQn can only be asserted (->0) when QACCEPTn is deasserted (1)
property qreq_accept_cond_assert_1;
   @(posedge clk) disable iff(!rst_n || !qchnl_enabled)
   $fell(QREQn) |-> QACCEPTn;
endproperty

// QACCEPTn can only be asserted (1->0) when QREQ is asserted (0)
property acceptn_reqn_assert_1;
   @(posedge clk) disable iff(!rst_n || !qchnl_enabled)
   $fell(QACCEPTn) |-> !QREQn;
endproperty

// QACCEPTn can only be deasserted (0-> 1) when QREQ is deasserted (1)
property acceptn_reqn_assert_2;
   @(posedge clk) disable iff(!rst_n || !qchnl_enabled)
   $rose(QACCEPTn) |-> QREQn;
endproperty

// X-check
property no_Q_chnl_signal_should_be_x_ever;
   @(posedge clk) disable iff(!rst_n || !qchnl_enabled)
   ((q_chnl_monitor_cb.QREQn !== 1'bx) || (q_chnl_monitor_cb.QACCEPTn !== 1'bx) ||
   (q_chnl_monitor_cb.QDENY !== 1'bx) || (q_chnl_monitor_cb.QACTIVE !== 1'bx));
endproperty

//QACTIVE is low and QREQn is assert(1->0) when after 5 or more clock cycles QACCEPTn is asserted(1->0)
property reqn_acceptn_assert_1;
   @(posedge clk) disable iff(!rst_n  || !qchnl_enabled || QACTIVE)
   (!QACTIVE && $fell(QREQn)) |-> ##[1:20] $fell(QACCEPTn);
endproperty

//QACTIVE is high and QREQn is assert(1->0) when QACTIVE is deasserted any time and then after 1 or more clock cycle QACCEPTN is asserted (1->0) 
property reqn_acceptn_assert_2;
   @(posedge clk) disable iff(!rst_n || !qchnl_enabled)
   (QACTIVE && $fell(QREQn)) |-> $fell(QACTIVE)[=1] ##[1:20] $fell(QACCEPTn);
endproperty

// Request during Command execution
property request_during_command;
   @(posedge clk) disable iff(!rst_n || !qchnl_enabled)
    $fell(QREQn) |-> QACTIVE;
endproperty

// Request between Command execution
property request_between_command;
   @(posedge clk) disable iff(!rst_n || !qchnl_enabled)
    $fell(QREQn) |-> !QACTIVE;
endproperty

//Multiple Request between Command execution
property multiple_request_between_command;
   @(posedge clk) disable iff(!rst_n || !qchnl_enabled)
    $fell(QACTIVE) |-> $fell(QREQn)[=2];
endproperty


<% if (obj.testBench != "emu_t" && obj.testBench != "emu") { %>
/*
ASSERT_ACCEPTn_H_L : assert property (acceptn_h_l_assert) `uvm_info("Q_Channel_Interface",$sformatf("ASSERT_ACCEPTn_H_L Assertion successful"); 
else `ASSERT_ERROR("ERROR","\n ASSERT_ACCEPTn_H_L Assertion failed : QACCEPT asserted when QACTIVE was not low. ");

ASSERT_POWER_UP_REQ : assert property (power_up_req_cond_assert) `uvm_info("Q_Channel_Interface",$sformatf("ASSERT_POWER_UP_REQ : Assertion successful"); 
else `ASSERT_ERROR("ERROR","\n ASSERT_POWER_UP_REQ : Assertion failed : REQn was asserted when block went into power up. ");

ASSERT_POWER_UP_ACCEPT : assert property (power_up_accept_cond_assert) `uvm_info("Q_Channel_Interface",$sformatf("ASSERT_POWER_UP_ACCEPT : Assertion successful"); 
else `ASSERT_ERROR("ERROR","\n ASSERT_POWER_UP_ACCEPT : Assertion failed : ACCEPTn was asserted when block went into power up. ");
*/

ASSERT_negREQn : assert property (qreq_accept_cond_assert_1) `uvm_info("Q_Channel_Interface",$sformatf("ASSERT_negREQn : Assertion successful"),UVM_DEBUG) 
else `ASSERT_ERROR("ERROR","\n negREQn : Assertion failed : QREQn was deasserted when QACCEPTn was already asserted. ");

ASSERT_negACCEPTn : assert property (acceptn_reqn_assert_1) `uvm_info("Q_Channel_Interface",$sformatf("ASSERT_negACCEPTn : Assertion successful"),UVM_DEBUG) 
else `ASSERT_ERROR("ERROR","\n negACCEPTn : Assertion failed : QACCEPT asserted when QREQn was not asserted. ");

ASSERT_posACCEPTn : assert property (acceptn_reqn_assert_2) `uvm_info("Q_Channel_Interface",$sformatf("ASSERT_posACCEPTn : Assertion successful"),UVM_DEBUG) 
else `ASSERT_ERROR("ERROR","\n posACCEPTn : Assertion failed : QACCEPT deasserted when QREQn was asserted. ");

ASSERT_Q_CHNL_X_CHECK : assert property (no_Q_chnl_signal_should_be_x_ever)
else `ASSERT_ERROR("ERROR","\n ASSERT_Q_CHNL_X_CHECK : Assertion failed : One or more then one Q channel signals are driving x. ");

ASSERT_REQn_ACCEPTn_NOT_ACTIVE : assert property (reqn_acceptn_assert_1) `uvm_info("Q_Channel_Interface",$sformatf("ASSERT_REQn_ACCEPTn_NOT_ACTIVE Assertion successful"),UVM_DEBUG) 
else `ASSERT_ERROR("ERROR","\n ASSERT_REQn_ACCEPTn Assertion failed : QACCEPTn is not asserted after 5 clock cycle of QREQn asserted. ");

ASSERT_REQn_ACCEPTn_ACTIVE : assert property (reqn_acceptn_assert_2) `uvm_info("Q_Channel_Interface",$sformatf("ASSERT_REQn_ACCEPTn_ACTIVE Assertion successful"),UVM_DEBUG) 
else `ASSERT_ERROR("ERROR","\n ASSERT_REQn_ACCEPTn Assertion failed : QACCEPTn is not asserted after 5 clock cycle of QREQn asserted. ");

/*ASSERT_ACCEPTn_H_L_COV     : cover property (acceptn_h_l_assert);
ASSERT_POWER_UP_REQ_COV    : cover property (power_up_req_cond_assert);
ASSERT_POWER_UP_ACCEPT_COV : cover property (power_up_accept_cond_assert);*/
<% if (obj.testBench == "dce" && obj.DceInfo[0].usePma  == 0) { %>
	//None of the cover properties apply (updated for DCE)
<%}
	else{%>
ASSERT_QREQn_ACCEPT_COV_1            : cover property (qreq_accept_cond_assert_1);
ASSERT_ACCEPTn_REQn_COV_1            : cover property (acceptn_reqn_assert_1);
ASSERT_ACCEPTn_REQn_COV_2            : cover property (acceptn_reqn_assert_2);
ASSERT_Q_CHNL_X_CHECK_COV            : cover property (no_Q_chnl_signal_should_be_x_ever);
ASSERT_REQn_ACCEPTn_NOT_ACTIVE_COV   : cover property (reqn_acceptn_assert_1);
ASSERT_REQn_ACCEPTn_ACTIVE_COV       : cover property (reqn_acceptn_assert_2);
ASSERT_REQ_DURING_CMD_COV            : cover property (request_during_command) `uvm_info("Q_Channel_Interface",$sformatf("ASSERT_REQ_DURING_CMD_COV covered "),UVM_DEBUG) //#Cover.CHIAIU.v3.Qchnlreqduringcmd
ASSERT_REQ_BETWEEN_CMD_COV           : cover property (request_between_command) `uvm_info("Q_Channel_Interface",$sformatf("ASSERT_REQ_BETWEEN_CMD_COV covered "),UVM_DEBUG) //#Cover.CHIAIU.v3.Qchnlreqbetncmd
//ASSERT_MULTIPLE_REQ_BETWEEN_CMD_COV  : cover property (multiple_request_between_command) `uvm_info("Q_Channel_Interface",$sformatf("ASSERT_MULTIPLE_REQ_BETWEEN_CMD_COV covered "),UVM_DEBUG) //#Cover.CHIAIU.v3.Qchnlmulreqbetncmd	
	<%}
  } %>

endinterface
