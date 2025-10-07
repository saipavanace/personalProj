////////////////////////////////////////////////////////////////////////////////
//
// AXI RD Seq Item 
//
////////////////////////////////////////////////////////////////////////////////
class axi_rd_seq_item extends uvm_sequence_item;

  `uvm_object_param_utils(axi_rd_seq_item)

  bit m_has_addr = 1;
  bit m_has_data = 1;

  rand ace_read_addr_pkt_t m_read_addr_pkt;
  rand ace_read_data_pkt_t m_read_data_pkt;


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_rd_seq_item");
  super.new(name);
  m_read_addr_pkt = new();
  m_read_data_pkt = new();
endfunction : new

//------------------------------------------------------------------------------
// Do Copy
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
  axi_rd_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  m_has_addr = rhs_.m_has_addr;
  m_has_data = rhs_.m_has_data;
  if (m_has_addr) begin
      m_read_addr_pkt.arid         = rhs_.m_read_addr_pkt.arid;
      m_read_addr_pkt.araddr       = rhs_.m_read_addr_pkt.araddr;
      m_read_addr_pkt.arlen        = rhs_.m_read_addr_pkt.arlen;
      m_read_addr_pkt.arsize       = rhs_.m_read_addr_pkt.arsize;
      m_read_addr_pkt.arburst      = rhs_.m_read_addr_pkt.arburst;
      m_read_addr_pkt.arlock       = rhs_.m_read_addr_pkt.arlock;
      m_read_addr_pkt.arcache      = rhs_.m_read_addr_pkt.arcache;
      m_read_addr_pkt.arprot       = rhs_.m_read_addr_pkt.arprot;
      m_read_addr_pkt.arqos        = rhs_.m_read_addr_pkt.arqos;
      m_read_addr_pkt.arregion     = rhs_.m_read_addr_pkt.arregion;
      m_read_addr_pkt.aruser       = rhs_.m_read_addr_pkt.aruser;
      m_read_addr_pkt.arcmdtype    = rhs_.m_read_addr_pkt.arcmdtype;
      m_read_addr_pkt.pkt_type     = rhs_.m_read_addr_pkt.pkt_type;
      if (m_read_addr_pkt.pkt_type == "ACE") begin
          m_read_addr_pkt.ardomain = rhs_.m_read_addr_pkt.ardomain;
          m_read_addr_pkt.arsnoop  = rhs_.m_read_addr_pkt.arsnoop;
          m_read_addr_pkt.arbar    = rhs_.m_read_addr_pkt.arbar;
          // ACE-LITE-E signals
          m_read_addr_pkt.arvmid   = rhs_.m_read_addr_pkt.arvmid;
          m_read_addr_pkt.artrace  = rhs_.m_read_addr_pkt.artrace;
          m_read_addr_pkt.arloop   = rhs_.m_read_addr_pkt.arloop;
          m_read_addr_pkt.arnsaid  = rhs_.m_read_addr_pkt.arnsaid;
      end

  end
  if (m_has_data) begin
      m_read_data_pkt.rid            = rhs_.m_read_data_pkt.rid;
      m_read_data_pkt.rdata          = rhs_.m_read_data_pkt.rdata;
      m_read_data_pkt.rresp          = rhs_.m_read_data_pkt.rresp;
      m_read_data_pkt.rresp_per_beat = rhs_.m_read_data_pkt.rresp_per_beat;
      m_read_data_pkt.ruser          = rhs_.m_read_data_pkt.ruser;
      m_read_data_pkt.pkt_type       = rhs_.m_read_data_pkt.pkt_type;
      if (m_read_data_pkt.pkt_type == "ACE") begin
          // ACE-LITE-E signals
          m_read_data_pkt.rpoison  = rhs_.m_read_data_pkt.rpoison;
          m_read_data_pkt.rdatachk = rhs_.m_read_data_pkt.rdatachk;
          m_read_data_pkt.rtrace   = rhs_.m_read_data_pkt.rtrace;
          m_read_data_pkt.rloop    = rhs_.m_read_data_pkt.rloop;
      end

  end
endfunction : do_copy

//------------------------------------------------------------------------------
// Do Compare
//------------------------------------------------------------------------------
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  axi_rd_seq_item rhs_;
  bit             compare_rd_addr;
  bit             compare_rd_data;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  compare_rd_addr = 
  ((m_has_addr) ? 
      (m_read_addr_pkt.arid         == rhs_.m_read_addr_pkt.arid) &&
      (m_read_addr_pkt.araddr       == rhs_.m_read_addr_pkt.araddr) &&
      (m_read_addr_pkt.arlen        == rhs_.m_read_addr_pkt.arlen) &&
      (m_read_addr_pkt.arsize       == rhs_.m_read_addr_pkt.arsize) &&
      (m_read_addr_pkt.arburst      == rhs_.m_read_addr_pkt.arburst) &&
      (m_read_addr_pkt.arlock       == rhs_.m_read_addr_pkt.arlock) &&
      (m_read_addr_pkt.arcache      == rhs_.m_read_addr_pkt.arcache) &&
      (m_read_addr_pkt.arprot       == rhs_.m_read_addr_pkt.arprot) &&
      (m_read_addr_pkt.arqos        == rhs_.m_read_addr_pkt.arqos) &&
      (m_read_addr_pkt.arregion     == rhs_.m_read_addr_pkt.arregion) &&
      (m_read_addr_pkt.aruser       == rhs_.m_read_addr_pkt.aruser) &&
      (m_read_addr_pkt.pkt_type     == rhs_.m_read_addr_pkt.pkt_type) &&
      ((m_read_addr_pkt.pkt_type == "ACE") ? 
          (m_read_addr_pkt.ardomain == rhs_.m_read_addr_pkt.ardomain) &&
          (m_read_addr_pkt.arsnoop  == rhs_.m_read_addr_pkt.arsnoop) &&
          (m_read_addr_pkt.arbar    == rhs_.m_read_addr_pkt.arbar) && 
          // ACE-LITE-E signals
          (m_read_addr_pkt.arvmid   == rhs_.m_read_addr_pkt.arvmid) && 
          (m_read_addr_pkt.artrace  == rhs_.m_read_addr_pkt.artrace) && 
          (m_read_addr_pkt.arloop   == rhs_.m_read_addr_pkt.arloop) && 
          (m_read_addr_pkt.arnsaid  == rhs_.m_read_addr_pkt.arnsaid) 
      : 1)
  : 1);
  compare_rd_data = 
  ((m_has_data) ? 
      (m_read_data_pkt.rid            == rhs_.m_read_data_pkt.rid) &&
      (m_read_data_pkt.rdata          == rhs_.m_read_data_pkt.rdata) &&
      (m_read_data_pkt.rresp          == rhs_.m_read_data_pkt.rresp) &&
      (m_read_data_pkt.rresp_per_beat == rhs_.m_read_data_pkt.rresp_per_beat) &&
      (m_read_data_pkt.ruser          == rhs_.m_read_data_pkt.ruser) &&
      (m_read_data_pkt.pkt_type       == rhs_.m_read_data_pkt.pkt_type) &&
      ((m_read_data_pkt.pkt_type == "ACE") ? 
          // ACE-LITE-E signals
          (m_read_data_pkt.rpoison  == rhs_.m_read_data_pkt.rpoison) &&
          (m_read_data_pkt.rdatachk == rhs_.m_read_data_pkt.rdatachk) &&
          (m_read_data_pkt.rtrace   == rhs_.m_read_data_pkt.rtrace) && 
          (m_read_data_pkt.rloop    == rhs_.m_read_data_pkt.rloop) 
      : 1)

  : 1);
  return super.do_compare(rhs, comparer) && compare_rd_addr && compare_rd_data;
endfunction : do_compare

//------------------------------------------------------------------------------
// Convert to String
//------------------------------------------------------------------------------
function string convert2string();
    string s;
    if (m_has_addr) begin
        s = m_read_addr_pkt.sprint_pkt();
    end
    else if (m_has_data) begin
        s = m_read_data_pkt.sprint_pkt();
    end
    return s;
endfunction : convert2string

//------------------------------------------------------------------------------
// Do Print
//------------------------------------------------------------------------------
function void do_print(uvm_printer printer);
  if(printer.knobs.sprint == 0) begin
    $display(convert2string());
  end
  else begin
    printer.m_string = convert2string();
  end
endfunction : do_print

////////////////////////////////////////////////////////////////////////////////

endclass : axi_rd_seq_item 


////////////////////////////////////////////////////////////////////////////////
//
// AXI WR Seq Item 
//
////////////////////////////////////////////////////////////////////////////////
class axi_wr_seq_item extends uvm_sequence_item;

  `uvm_object_param_utils(axi_wr_seq_item)

  bit m_has_addr = 1;
  bit m_has_data = 1;
  bit m_has_resp = 1;

  rand ace_write_addr_pkt_t m_write_addr_pkt;
  rand ace_write_data_pkt_t m_write_data_pkt;
  rand ace_write_resp_pkt_t m_write_resp_pkt;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_wr_seq_item");
  super.new(name);
  m_write_addr_pkt = new();
  m_write_data_pkt = new();
  m_write_resp_pkt = new();
endfunction : new

//------------------------------------------------------------------------------
// Do Copy
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
  axi_wr_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  m_has_addr = rhs_.m_has_addr;
  m_has_data = rhs_.m_has_data;
  m_has_resp = rhs_.m_has_resp;
  if (m_has_addr) begin
      m_write_addr_pkt.awid         = rhs_.m_write_addr_pkt.awid;
      m_write_addr_pkt.awaddr       = rhs_.m_write_addr_pkt.awaddr;
      m_write_addr_pkt.awlen        = rhs_.m_write_addr_pkt.awlen;
      m_write_addr_pkt.awsize       = rhs_.m_write_addr_pkt.awsize;
      m_write_addr_pkt.awburst      = rhs_.m_write_addr_pkt.awburst;
      m_write_addr_pkt.awlock       = rhs_.m_write_addr_pkt.awlock;
      m_write_addr_pkt.awcache      = rhs_.m_write_addr_pkt.awcache;
      m_write_addr_pkt.awprot       = rhs_.m_write_addr_pkt.awprot;
      m_write_addr_pkt.awqos        = rhs_.m_write_addr_pkt.awqos;
      m_write_addr_pkt.awregion     = rhs_.m_write_addr_pkt.awregion;
      m_write_addr_pkt.awuser       = rhs_.m_write_addr_pkt.awuser;
      m_write_addr_pkt.awcmdtype    = rhs_.m_write_addr_pkt.awcmdtype;
      m_write_addr_pkt.pkt_type     = rhs_.m_write_addr_pkt.pkt_type;
      if (m_write_addr_pkt.pkt_type == "ACE") begin
          m_write_addr_pkt.awdomain      = rhs_.m_write_addr_pkt.awdomain;
          m_write_addr_pkt.awsnoop       = rhs_.m_write_addr_pkt.awsnoop;
          m_write_addr_pkt.awbar         = rhs_.m_write_addr_pkt.awbar;
          m_write_addr_pkt.awunique      = rhs_.m_write_addr_pkt.awunique;
          m_write_addr_pkt.awatoptype    = rhs_.m_write_addr_pkt.awatoptype;
          m_write_addr_pkt.endiantype    = rhs_.m_write_addr_pkt.endiantype;
          m_write_addr_pkt.awatop        = rhs_.m_write_addr_pkt.awatop; 
          m_write_addr_pkt.awstashnid    = rhs_.m_write_addr_pkt.awstashnid; 
          m_write_addr_pkt.awstashniden  = rhs_.m_write_addr_pkt.awstashniden; 
          m_write_addr_pkt.awstashlpid   = rhs_.m_write_addr_pkt.awstashlpid; 
          m_write_addr_pkt.awstashlpiden = rhs_.m_write_addr_pkt.awstashlpiden;
          m_write_addr_pkt.awtrace       = rhs_.m_write_addr_pkt.awtrace;
          m_write_addr_pkt.awloop        = rhs_.m_write_addr_pkt.awloop;
          m_write_addr_pkt.awnsaid       = rhs_.m_write_addr_pkt.awnsaid;
      end
  end
  if (m_has_data) begin
      m_write_data_pkt.wdata    = rhs_.m_write_data_pkt.wdata;
      m_write_data_pkt.wstrb    = rhs_.m_write_data_pkt.wstrb;
      m_write_data_pkt.wuser    = rhs_.m_write_data_pkt.wuser;
      m_write_data_pkt.pkt_type = rhs_.m_write_data_pkt.pkt_type;
      if (m_write_data_pkt.pkt_type == "ACE") begin
          m_write_data_pkt.wpoison  = rhs_.m_write_data_pkt.wpoison;
          m_write_data_pkt.wdatachk = rhs_.m_write_data_pkt.wdatachk;
          m_write_data_pkt.wtrace   = rhs_.m_write_data_pkt.wtrace;
      end
  end
  if (m_has_resp) begin
      m_write_resp_pkt.bid      = rhs_.m_write_resp_pkt.bid;
      m_write_resp_pkt.bresp    = rhs_.m_write_resp_pkt.bresp;
      m_write_resp_pkt.buser    = rhs_.m_write_resp_pkt.buser;
      m_write_resp_pkt.pkt_type = rhs_.m_write_resp_pkt.pkt_type;
      if (m_write_resp_pkt.pkt_type == "ACE") begin
          m_write_resp_pkt.btrace = rhs_.m_write_resp_pkt.btrace;
          m_write_resp_pkt.bloop  = rhs_.m_write_resp_pkt.bloop;
      end
  end

endfunction : do_copy

//------------------------------------------------------------------------------
// Do Compare
//------------------------------------------------------------------------------
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  axi_wr_seq_item rhs_;
  bit             compare_wr_addr;
  bit             compare_wr_data;
  bit             compare_wr_resp;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  compare_wr_addr = 
  ((m_has_addr) ? 
      (m_write_addr_pkt.awid         == rhs_.m_write_addr_pkt.awid) &&
      (m_write_addr_pkt.awaddr       == rhs_.m_write_addr_pkt.awaddr) &&
      (m_write_addr_pkt.awlen        == rhs_.m_write_addr_pkt.awlen) &&
      (m_write_addr_pkt.awsize       == rhs_.m_write_addr_pkt.awsize) &&
      (m_write_addr_pkt.awburst      == rhs_.m_write_addr_pkt.awburst) &&
      (m_write_addr_pkt.awlock       == rhs_.m_write_addr_pkt.awlock) &&
      (m_write_addr_pkt.awcache      == rhs_.m_write_addr_pkt.awcache) &&
      (m_write_addr_pkt.awprot       == rhs_.m_write_addr_pkt.awprot) &&
      (m_write_addr_pkt.awqos        == rhs_.m_write_addr_pkt.awqos) &&
      (m_write_addr_pkt.awregion     == rhs_.m_write_addr_pkt.awregion) &&
      (m_write_addr_pkt.awuser       == rhs_.m_write_addr_pkt.awuser) &&
      (m_write_addr_pkt.pkt_type     == rhs_.m_write_addr_pkt.pkt_type) &&
      ((m_write_addr_pkt.pkt_type == "ACE") ?
          (m_write_addr_pkt.awdomain      == rhs_.m_write_addr_pkt.awdomain) &&
          (m_write_addr_pkt.awsnoop       == rhs_.m_write_addr_pkt.awsnoop) &&
          (m_write_addr_pkt.awbar         == rhs_.m_write_addr_pkt.awbar) &&
          (m_write_addr_pkt.awatop        == rhs_.m_write_addr_pkt.awatop) &&
          (m_write_addr_pkt.awstashnid    == rhs_.m_write_addr_pkt.awstashnid) &&
          (m_write_addr_pkt.awstashniden  == rhs_.m_write_addr_pkt.awstashniden) &&
          (m_write_addr_pkt.awstashlpid   == rhs_.m_write_addr_pkt.awstashlpid) &&
          (m_write_addr_pkt.awstashlpiden == rhs_.m_write_addr_pkt.awstashlpiden) &&
          (m_write_addr_pkt.awtrace       == rhs_.m_write_addr_pkt.awtrace) &&
          (m_write_addr_pkt.awloop        == rhs_.m_write_addr_pkt.awloop) &&
          (m_write_addr_pkt.awnsaid       == rhs_.m_write_addr_pkt.awnsaid) &&
          (m_write_addr_pkt.awunique      == rhs_.m_write_addr_pkt.awunique)
      : 1)
  : 1);
  compare_wr_data = 
  ((m_has_data) ? 
      (m_write_data_pkt.wdata    == rhs_.m_write_data_pkt.wdata) &&
      (m_write_data_pkt.wstrb    == rhs_.m_write_data_pkt.wstrb) &&
      (m_write_data_pkt.wuser    == rhs_.m_write_data_pkt.wuser) &&
      (m_write_data_pkt.pkt_type == rhs_.m_write_data_pkt.pkt_type) &&
      ((m_write_data_pkt.pkt_type == "ACE") ?
          (m_write_data_pkt.wpoison == rhs_.m_write_data_pkt.wpoison) &&
          (m_write_data_pkt.wdatachk == rhs_.m_write_data_pkt.wdatachk) &&
          (m_write_data_pkt.wtrace   == rhs_.m_write_data_pkt.wtrace)
      : 1)
  : 1);
  compare_wr_resp = 
  ((m_has_resp) ? 
      (m_write_resp_pkt.bid      == rhs_.m_write_resp_pkt.bid) &&
      (m_write_resp_pkt.bresp    == rhs_.m_write_resp_pkt.bresp) &&
      (m_write_resp_pkt.buser    == rhs_.m_write_resp_pkt.buser) &&
      (m_write_resp_pkt.pkt_type == rhs_.m_write_resp_pkt.pkt_type) &&
      ((m_write_resp_pkt.pkt_type == "ACE") ?
          (m_write_resp_pkt.btrace == rhs_.m_write_resp_pkt.btrace) &&
          (m_write_resp_pkt.bloop  == rhs_.m_write_resp_pkt.bloop)
      : 1)

  : 1);

  return super.do_compare(rhs, comparer) && compare_wr_addr && compare_wr_data && compare_wr_resp;
endfunction : do_compare

//------------------------------------------------------------------------------
// Convert to String
//------------------------------------------------------------------------------
function string convert2string();
    string s;
    if (m_has_addr) begin
        s = m_write_addr_pkt.sprint_pkt();
    end
    else if (m_has_data) begin
        s = m_write_data_pkt.sprint_pkt();
    end
    else if (m_has_resp) begin
        s = m_write_resp_pkt.sprint_pkt();
    end
    return s;
endfunction : convert2string

//------------------------------------------------------------------------------
// Do Print
//------------------------------------------------------------------------------
function void do_print(uvm_printer printer);
  if(printer.knobs.sprint == 0) begin
    $display(convert2string());
  end
  else begin
    printer.m_string = convert2string();
  end
endfunction : do_print

////////////////////////////////////////////////////////////////////////////////

endclass : axi_wr_seq_item 


////////////////////////////////////////////////////////////////////////////////
//
// AXI SNP Seq Item 
//
////////////////////////////////////////////////////////////////////////////////
class axi_snp_seq_item extends uvm_sequence_item;

  `uvm_object_param_utils(axi_snp_seq_item)

  bit m_has_addr = 1;
  bit m_has_data = 1;
  bit m_has_resp = 1;

  rand ace_snoop_addr_pkt_t m_snoop_addr_pkt;
  rand ace_snoop_data_pkt_t m_snoop_data_pkt;
  rand ace_snoop_resp_pkt_t m_snoop_resp_pkt;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_snp_seq_item");
  super.new(name);
  m_snoop_addr_pkt = new();
  m_snoop_data_pkt = new();
  m_snoop_resp_pkt = new();
endfunction : new

//------------------------------------------------------------------------------
// Do Copy
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
  axi_snp_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  m_has_addr = rhs_.m_has_addr;
  m_has_data = rhs_.m_has_data;
  m_has_resp = rhs_.m_has_resp;
  if (m_has_addr) begin
      m_snoop_addr_pkt.acaddr  = rhs_.m_snoop_addr_pkt.acaddr;
      m_snoop_addr_pkt.acprot  = rhs_.m_snoop_addr_pkt.acprot;
      m_snoop_addr_pkt.acsnoop = rhs_.m_snoop_addr_pkt.acsnoop;
      m_snoop_addr_pkt.acvmid  = rhs_.m_snoop_addr_pkt.acvmid;
      m_snoop_addr_pkt.actrace = rhs_.m_snoop_addr_pkt.actrace;
  end
  if (m_has_data) begin
      m_snoop_data_pkt.cddata    = rhs_.m_snoop_data_pkt.cddata;
      m_snoop_data_pkt.cdpoison  = rhs_.m_snoop_data_pkt.cdpoison;
      m_snoop_data_pkt.cddatachk = rhs_.m_snoop_data_pkt.cddatachk;
      m_snoop_data_pkt.cdtrace   = rhs_.m_snoop_data_pkt.cdtrace;
  end
  if (m_has_resp) begin
      m_snoop_resp_pkt.crresp  = rhs_.m_snoop_resp_pkt.crresp;
      m_snoop_resp_pkt.crtrace = rhs_.m_snoop_resp_pkt.crtrace;
      m_snoop_resp_pkt.crnsaid = rhs_.m_snoop_resp_pkt.crnsaid;
      m_snoop_resp_pkt.is_dvm_sync_crresp = rhs_.m_snoop_resp_pkt.is_dvm_sync_crresp;
  end
endfunction : do_copy

//------------------------------------------------------------------------------
// Do Compare
//------------------------------------------------------------------------------
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  axi_snp_seq_item rhs_;
  bit             compare_snp_addr;
  bit             compare_snp_data;
  bit             compare_snp_resp;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  compare_snp_addr = 
  ((m_has_addr) ? 
      (m_snoop_addr_pkt.acaddr  == rhs_.m_snoop_addr_pkt.acaddr) &&
      (m_snoop_addr_pkt.acprot  == rhs_.m_snoop_addr_pkt.acprot) &&
      (m_snoop_addr_pkt.acvmid  == rhs_.m_snoop_addr_pkt.acvmid) &&
      (m_snoop_addr_pkt.actrace == rhs_.m_snoop_addr_pkt.actrace) &&
      (m_snoop_addr_pkt.acsnoop == rhs_.m_snoop_addr_pkt.acsnoop)
  : 1);
  compare_snp_data = 
  ((m_has_data) ? 
      (m_snoop_data_pkt.cddata    == rhs_.m_snoop_data_pkt.cddata) &&
      (m_snoop_data_pkt.cdpoison  == rhs_.m_snoop_data_pkt.cdpoison) &&
      (m_snoop_data_pkt.cddatachk == rhs_.m_snoop_data_pkt.cddatachk) &&
      (m_snoop_data_pkt.cdtrace   == rhs_.m_snoop_data_pkt.cdtrace)
  : 1);
  compare_snp_resp = 
  ((m_has_resp) ? 
      (m_snoop_resp_pkt.crresp   == rhs_.m_snoop_resp_pkt.crresp) &&
      (m_snoop_resp_pkt.crtrace  == rhs_.m_snoop_resp_pkt.crtrace) &&
      (m_snoop_resp_pkt.crnsaid == rhs_.m_snoop_resp_pkt.crnsaid)
  : 1);

  return super.do_compare(rhs, comparer) && compare_snp_addr && compare_snp_data && compare_snp_resp;
endfunction : do_compare

//------------------------------------------------------------------------------
// Convert to String
//------------------------------------------------------------------------------
function string convert2string();
    string s;
    if (m_has_addr) begin
        s = m_snoop_addr_pkt.sprint_pkt();
    end
    else if (m_has_data) begin
        s = m_snoop_data_pkt.sprint_pkt();
    end
    else if (m_has_resp) begin
        s = m_snoop_resp_pkt.sprint_pkt();
    end
    return s;
endfunction : convert2string

//------------------------------------------------------------------------------
// Do Print
//------------------------------------------------------------------------------
function void do_print(uvm_printer printer);
  if(printer.knobs.sprint == 0) begin
    $display(convert2string());
  end
  else begin
    printer.m_string = convert2string();
  end
endfunction : do_print

////////////////////////////////////////////////////////////////////////////////

endclass : axi_snp_seq_item 


////////////////////////////////////////////////////////////////////////////////
//
// AXI SysCo Item 
//
////////////////////////////////////////////////////////////////////////////////
class axi_sysco_seq_item extends uvm_sequence_item;

  `uvm_object_param_utils(axi_sysco_seq_item)

  bit syscoreq = 0;
  bit syscoack = 0;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_sysco_seq_item");
  super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Do Copy
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
  axi_sysco_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  syscoreq = rhs_.syscoreq;
  syscoack = rhs_.syscoack;
endfunction : do_copy

//------------------------------------------------------------------------------
// Do Compare
//------------------------------------------------------------------------------
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  axi_sysco_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end

  return super.do_compare(rhs, comparer);
endfunction : do_compare

//------------------------------------------------------------------------------
// Convert to String
//------------------------------------------------------------------------------
function string convert2string();
    string s;
    s = $sformatf("syscoreq: %0d, syscoack: %0d", syscoreq, syscoack);

    return s;
endfunction : convert2string

//------------------------------------------------------------------------------
// Do Print
//------------------------------------------------------------------------------
function void do_print(uvm_printer printer);
  if(printer.knobs.sprint == 0) begin
    $display(convert2string());
  end
  else begin
    printer.m_string = convert2string();
  end
endfunction : do_print

////////////////////////////////////////////////////////////////////////////////

endclass : axi_sysco_seq_item 

