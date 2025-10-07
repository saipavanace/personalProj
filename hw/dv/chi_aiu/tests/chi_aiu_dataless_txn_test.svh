

class chi_aiu_dataless_txn_test extends chi_aiu_base_test;

  `uvm_component_utils(chi_aiu_dataless_txn_test)
  //properties
  chi_txn_seq#(chi_req_seq_item)  m_req_seq;
  chi_txn_seq#(chi_lnk_seq_item)  m_lnk_seq;
  chi_txn_seq#(chi_base_seq_item) m_txs_seq;

  int num_trans;

  //Interface Methods
  extern function new(
    string name = "chi_aiu_dataless_txn_test",
    uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
  //Run task
  extern task run_phase(uvm_phase phase);

  //Helper methods
  extern function void construct_lk_seq(
    ref chi_txn_seq#(chi_lnk_seq_item) m_lnk_seq);
  extern function void construct_rd_seq(
    ref chi_txn_seq#(chi_req_seq_item) m_req_seq);
  extern function void construct_txs_seq(
    ref chi_txn_seq#(chi_base_seq_item) m_txs_seq);

endclass: chi_aiu_dataless_txn_test

function chi_aiu_dataless_txn_test::new(
  string name = "chi_aiu_dataless_txn_test",
  uvm_component parent = null);

  super.new(name, parent);
endfunction: new

function void chi_aiu_dataless_txn_test::build_phase(uvm_phase phase);
  uvm_config_db #(bit)::set(this, "m_env", "default_chi_sysco", 1'b1);
  super.build_phase(phase);
endfunction: build_phase

function void chi_aiu_dataless_txn_test::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction: connect_phase

function void chi_aiu_dataless_txn_test::report_phase(uvm_phase phase);
  super.report_phase(phase);
endfunction: report_phase

task chi_aiu_dataless_txn_test::run_phase(uvm_phase phase);
  bit timeout;
 super.run_phase(phase);
  if (!$value$plusargs("num_trans=%d",num_trans)) begin
      num_trans = 1;
  end


  m_req_seq = chi_txn_seq#(chi_req_seq_item)::type_id::create("m_req_seq");
  m_lnk_seq = chi_txn_seq#(chi_lnk_seq_item)::type_id::create("m_lnk_seq");
  m_txs_seq = chi_txn_seq#(chi_base_seq_item)::type_id::create("m_txs_seq");

  phase.raise_objection(this, "bringup_test");
  `uvm_info(get_name(), "construct Link seq", UVM_NONE)
  construct_lk_seq(m_lnk_seq);
  construct_txs_seq(m_txs_seq);
  `uvm_info(get_name(), "construct Rd request seq", UVM_NONE)
  construct_rd_seq(m_req_seq);
  
  fork: tFrok
    begin
      //issue Link initiation sequence
      `uvm_info(get_name(), "Start Link seq", UVM_NONE)
      m_lnk_seq.start(m_env.m_chi_agent.m_lnk_hske_seqr);
      `uvm_info(get_name(), "Done Link seq", UVM_NONE)
      m_txs_seq.start(m_env.m_chi_agent.m_txs_actv_seqr);
      //issue Read CHI request
      `uvm_info(get_name(), "Start Rd request seq", UVM_NONE)
      m_req_seq.start(m_env.m_chi_agent.m_rn_tx_req_chnl_seqr);
      `uvm_info(get_name(), "Done Rd request seq", UVM_NONE)
    end
    begin
      #5us;
      timeout = 1;
    end
    begin
      m_system_bfm_seq.k_num_snp = 0; //FIXME: use proper way to pass the value of this knob
      m_system_bfm_seq.start(null);
    end
    
  join_any

  if (timeout)
    `uvm_fatal(get_name(), "Test Timeout")
  #50us;
  phase.drop_objection(this, "bringup_test");
endtask: run_phase

function void chi_aiu_dataless_txn_test::construct_lk_seq(
  ref chi_txn_seq#(chi_lnk_seq_item) m_lnk_seq);

  chi_lnk_seq_item seq_item;

  seq_item = chi_lnk_seq_item::type_id::create("chi_lnk_seq_item");
  seq_item.m_txactv_st = POWUP_TX_LN;
  m_lnk_seq.push_back(seq_item);

endfunction: construct_lk_seq

function void chi_aiu_dataless_txn_test::construct_txs_seq(
    ref chi_txn_seq#(chi_base_seq_item) m_txs_seq);

    chi_base_seq_item seq_item;

    seq_item = chi_base_seq_item::type_id::create("chi_base_seq_item");
    seq_item.txsactv = 1'b1;
    m_txs_seq.push_back(seq_item);

endfunction: construct_txs_seq

function void chi_aiu_dataless_txn_test::construct_rd_seq(
  ref chi_txn_seq#(chi_req_seq_item) m_req_seq);

  chi_req_seq_item seq_item;

  for (int i = 0; i < num_trans; i++) begin 
    automatic int id = i;
    seq_item = chi_req_seq_item::type_id::create("chi_req_seq_item");
    seq_item.qos      = 1;
    seq_item.tgtid    = 3;
    seq_item.srcid    = 0;
    seq_item.tracetag = 0;
    seq_item.txnid = id;
    seq_item.addr = $urandom();
    seq_item.addr[5:0] = 6'b0;
    //seq_item.opcode   = MAKEUNIQUE;
    seq_item.randomize(opcode) with {opcode inside {dataless_ops};};
    seq_item.size     = 'h6;
    m_req_seq.push_back(seq_item);
  end

endfunction: construct_rd_seq

