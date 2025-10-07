////////////////////////////////////////////////////////////////////////////////
//
// CHI miscellaneous transactions
//
////////////////////////////////////////////////////////////////////////////////

class chi_credit_txn extends uvm_object;

  //parameters. Constrainted specific to CHI Spec
  parameter int MAX_CREDITS = 15;

  //Properties
  int              num_credits;
  longint unsigned timeout;
  string           name;

  `uvm_object_param_utils(chi_credit_txn)

  //Setup Methods
  extern function new(string name = "chi_credit_txn");
  extern function void set_link_name(string s);
  extern function void link_in_rx_mode();
  extern function void set_timeout_cycles(longint unsigned t);

  //Usage methods
  extern function void put_credit();
  extern function int  peek_credits();
  extern task get_credit(const ref uvm_event e);

endclass: chi_credit_txn

//Constructor
function chi_credit_txn::new(string name = "chi_credit_txn");
  super.new(name);
  this.name = name;
  num_credits = 0;
endfunction: new

function void chi_credit_txn::set_link_name(string s);
  name = s;
endfunction: set_link_name

function void chi_credit_txn::link_in_rx_mode();
  num_credits = 15;
endfunction: link_in_rx_mode

function void chi_credit_txn::set_timeout_cycles(longint unsigned t);
  timeout = t;
endfunction: set_timeout_cycles

function void chi_credit_txn::put_credit();
  `ASSERT(num_credits <= MAX_CREDITS, {name, $psprintf(" Illegal number of link credits. num_credits:%0d, MAX_CREDITS:%0d", num_credits, MAX_CREDITS)});

  num_credits++;
endfunction: put_credit

function int chi_credit_txn::peek_credits();
  `ASSERT(num_credits >= 0 || num_credits < MAX_CREDITS,
    {name, " Illegal number of link credits"});

  return num_credits;
endfunction: peek_credits

task chi_credit_txn::get_credit(const ref uvm_event e);
  `ASSERT(num_credits >= 0, {name, " Illegal number of link credits"});

  fork: wait4crd
    begin
      wait (num_credits > 0);
    end
    begin
      repeat (timeout) begin
        e.wait_trigger();
      end
      `uvm_fatal(name, {name, " Timeout Triggered due to lack of link credits"})
    end
  join_any: wait4crd

  disable wait4crd;
  num_credits--;

endtask: get_credit

////////////////
// CHI Link state machine
////////////////

class chi_link_state extends uvm_object;
  
  chi_link_state_t m_link_st;

  local bit ret_lcredits;
  local int  chnls_idle;

  `uvm_object_param_utils(chi_link_state)

  extern function new(string name = "chi_link_state");
  extern function void link_signal_value(logic req, logic ack);

  extern function bit is_link_alive();
  extern function chi_link_state_t get_link_state();

  //Interface methods to either indicate or check status
  //of link power down
  extern function void initiate_ret_lcredits();
  extern function bit  start_chnl_powdn();
  extern function void chnl_ready4shutdown();

endclass: chi_link_state

function chi_link_state::new(string name = "chi_link_state");
  super.new(name);
endfunction: new

function void chi_link_state::link_signal_value(logic req, logic ack);
  case (m_link_st)
    STOP: begin
      case ({req, ack})
        0: m_link_st = STOP;
        1: `ASSERT(0, "STOP->INACTIVE Link state is illegal");
        2: m_link_st = ACTIVE;
        3: m_link_st = RUN;
        default: `ASSERT(0, $psprintf("Illegal value %0h, %0h", req, ack));
      endcase
    end
   
    ACTIVE: begin
      case ({req, ack})
        0: `ASSERT(0, "ACTIVE->STOP Link state is illegal");
        1: `ASSERT(0, "ACTIVE->INACTIVE Link state is illegal");
        2: m_link_st = ACTIVE;
        3: m_link_st = RUN;
        default: `ASSERT(0, $psprintf("Illegal value %0h, %0h", req, ack));
      endcase
    end

    RUN: begin
      case ({req, ack})
        0: `ASSERT(0, "RUN->STOP Link state is illegal");
        1: m_link_st = INACTIVE;
        2: `ASSERT(0, "RUN->ACTIVE Link state is illegal");
        3: m_link_st = RUN;
        default: `ASSERT(0, $psprintf("Illegal value %0h, %0h", req, ack));
      endcase
    end

    INACTIVE: begin
      case ({req, ack})
        0: m_link_st = STOP;
        1: m_link_st = INACTIVE;
        2: `ASSERT(0, "INACTIVE->ACTIVE Link state is illegal");
        3: `ASSERT(0, "INACTIVE->RUNLink state is illegal");
        default: `ASSERT(0, $psprintf("Illegal value %0h, %0h", req, ack));
      endcase
    end

  endcase
endfunction: link_signal_value

function bit chi_link_state::is_link_alive();
  return m_link_st == RUN ? 1'b1 : 1'b0;
endfunction: is_link_alive

function chi_link_state_t chi_link_state::get_link_state();
  return m_link_st;
endfunction: get_link_state

function void chi_link_state::initiate_ret_lcredits();
  ret_lcredits = 1'b1;
endfunction: initiate_ret_lcredits

function bit chi_link_state::start_chnl_powdn();
  return ret_lcredits;
endfunction: start_chnl_powdn

function void chi_link_state::chnl_ready4shutdown();
  chnls_idle++;
endfunction: chnl_ready4shutdown

////////////////
// Counts number of TX-Link transactions in-flight
////////////////
class chi_num_flits extends uvm_object;

  `uvm_object_param_utils(chi_num_flits)

  int m_num_flits[string];

  extern function new(string name = "chi_num_flits");
  extern function void set_num_pending_flits(string key, int flits);
  extern function int  get_num_pending_flits();
endclass: chi_num_flits

function chi_num_flits::new(string name = "chi_num_flits");
  super.new(name);
endfunction: new

function void chi_num_flits::set_num_pending_flits(string key, int flits);
  m_num_flits[key] = flits;
endfunction: set_num_pending_flits

function int chi_num_flits::get_num_pending_flits();
  int val = 0;
  string str;

  if (m_num_flits.first(str)) begin
    do
      val += m_num_flits[str];  
    while (m_num_flits.next(str));
  end
  return val;
endfunction: get_num_pending_flits

