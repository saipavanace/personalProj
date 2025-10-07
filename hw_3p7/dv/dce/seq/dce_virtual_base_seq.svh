class dce_virtual_base_seq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(dce_virtual_base_seq);

  //All directions are with respect to TB
  
  smi_sequencer  m_smi_sqr_tx_hash[string];  //TX-SQR
  smi_sequencer  m_smi_sqr_rx_hash[string];  //RX-SQR

  uvm_phase         m_phase;
  dce_container     m_dce_cntr;
  dce_unit_args     m_unit_args;
  dce_scb           m_scb;
  addr_trans_mgr    m_addr_mgr;
  event             e_single_step;
  
  dce_mst_base_seq m_mst_seq;
  dce_slv_base_seq m_slv_seq4aius;
  dce_slv_base_seq m_slv_seq4dmis;
 
  //Methods
  extern function new(string name = "dce_virtual_base_seq");

endclass: dce_virtual_base_seq

function dce_virtual_base_seq::new(string name = "dce_virtual_base_seq");
  super.new(name);
  //construct dce_container
  m_dce_cntr = dce_container::type_id::create("dce_container");
  
  //Get address manager instance
  m_addr_mgr    = addr_trans_mgr::get_instance();

endfunction: new


