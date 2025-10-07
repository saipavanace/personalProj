////////////////////////////////////////////////////////////////////////////////
//
// AXI Read Address Channel Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class axi_read_addr_chnl_sequencer extends uvm_sequencer #(axi_rd_seq_item);

  `uvm_component_param_utils(axi_read_addr_chnl_sequencer)

  extern function new(string name="axi_read_addr_chnl_sequencer", uvm_component parent = null);

endclass: axi_read_addr_chnl_sequencer

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function axi_read_addr_chnl_sequencer::new(string name="axi_read_addr_chnl_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////////////////////////
//
// AXI Read Data Channel Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class axi_read_data_chnl_sequencer extends uvm_sequencer #(axi_rd_seq_item);

  `uvm_component_param_utils(axi_read_data_chnl_sequencer)

  extern function new(string name="axi_read_data_chnl_sequencer", uvm_component parent = null);

endclass: axi_read_data_chnl_sequencer

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function axi_read_data_chnl_sequencer::new(string name="axi_read_data_chnl_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////////////////////////
//
// AXI Write Address Channel Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class axi_write_addr_chnl_sequencer extends uvm_sequencer #(axi_wr_seq_item);

  `uvm_component_param_utils(axi_write_addr_chnl_sequencer)

  extern function new(string name="axi_write_addr_chnl_sequencer", uvm_component parent = null);

endclass: axi_write_addr_chnl_sequencer

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function axi_write_addr_chnl_sequencer::new(string name="axi_write_addr_chnl_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////////////////////////
//
// AXI Write Data Channel Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class axi_write_data_chnl_sequencer extends uvm_sequencer #(axi_wr_seq_item);

  `uvm_component_param_utils(axi_write_data_chnl_sequencer)

  extern function new(string name="axi_write_data_chnl_sequencer", uvm_component parent = null);

endclass: axi_write_data_chnl_sequencer

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function axi_write_data_chnl_sequencer::new(string name="axi_write_data_chnl_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////////////////////////
//
// AXI Write Resp Channel Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class axi_write_resp_chnl_sequencer extends uvm_sequencer #(axi_wr_seq_item);

  `uvm_component_param_utils(axi_write_resp_chnl_sequencer)

  extern function new(string name="axi_write_resp_chnl_sequencer", uvm_component parent = null);

endclass: axi_write_resp_chnl_sequencer

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function axi_write_resp_chnl_sequencer::new(string name="axi_write_resp_chnl_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////////////////////////
//
// AXI Snoop Address Channel Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class axi_snoop_addr_chnl_sequencer extends uvm_sequencer #(axi_snp_seq_item);

  `uvm_component_param_utils(axi_snoop_addr_chnl_sequencer)

  extern function new(string name="axi_snoop_addr_chnl_sequencer", uvm_component parent = null);

endclass: axi_snoop_addr_chnl_sequencer

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function axi_snoop_addr_chnl_sequencer::new(string name="axi_snoop_addr_chnl_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////////////////////////
//
// AXI Snoop Data Channel Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class axi_snoop_data_chnl_sequencer extends uvm_sequencer #(axi_snp_seq_item);

  `uvm_component_param_utils(axi_snoop_data_chnl_sequencer)

  extern function new(string name="axi_snoop_data_chnl_sequencer", uvm_component parent = null);

endclass: axi_snoop_data_chnl_sequencer

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function axi_snoop_data_chnl_sequencer::new(string name="axi_snoop_data_chnl_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////////////////////////
//
// AXI Snoop Resp Channel Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class axi_snoop_resp_chnl_sequencer extends uvm_sequencer #(axi_snp_seq_item);

  `uvm_component_param_utils(axi_snoop_resp_chnl_sequencer)

  extern function new(string name="axi_snoop_resp_chnl_sequencer", uvm_component parent = null);

endclass: axi_snoop_resp_chnl_sequencer

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function axi_snoop_resp_chnl_sequencer::new(string name="axi_snoop_resp_chnl_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction : new




////////////////////////////////////////////////////////////////////////////////

