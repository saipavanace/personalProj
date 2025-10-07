////////////////////////////////////////////////////////////////////////////////
//
// CCP Cache Din & ctrl and status sequnece item 
//
////////////////////////////////////////////////////////////////////////////////
class ccp_ctrlstatus_seq_item extends uvm_sequence_item;

  `uvm_object_utils(ccp_ctrlstatus_seq_item)

  bit  m_has_ctrl_req  = 1;
  bit  m_has_data = 1;
  bit  m_reset    = 0;
  rand ccp_ctrl_pkt_t       m_ctrlstatus_pkt;
  rand ccp_wr_data_pkt_t    m_wr_pkt;
  

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "ccp_ctrlstatus_seq_item");
  super.new(name);
  m_ctrlstatus_pkt = new(); 
  m_wr_pkt         = new(); 
endfunction : new

//------------------------------------------------------------------------------
// Do Copy
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
  ccp_ctrlstatus_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  m_has_ctrl_req = rhs_.m_has_ctrl_req;
  m_has_data     = rhs_.m_has_data;
  m_reset        = rhs_.m_reset;

  if (m_has_ctrl_req) begin
    m_ctrlstatus_pkt.bnk              = rhs_.m_ctrlstatus_pkt.bnk;
    m_ctrlstatus_pkt.addr             = rhs_.m_ctrlstatus_pkt.addr;
    m_ctrlstatus_pkt.alloc            = rhs_.m_ctrlstatus_pkt.alloc;
    m_ctrlstatus_pkt.rd_data          = rhs_.m_ctrlstatus_pkt.rd_data;
    m_ctrlstatus_pkt.wr_data          = rhs_.m_ctrlstatus_pkt.wr_data;
    m_ctrlstatus_pkt.rsp_evict_sel    = rhs_.m_ctrlstatus_pkt.rsp_evict_sel;
    m_ctrlstatus_pkt.bypass           = rhs_.m_ctrlstatus_pkt.bypass;
    m_ctrlstatus_pkt.rp_update        = rhs_.m_ctrlstatus_pkt.rp_update ;
    m_ctrlstatus_pkt.tagstateup       = rhs_.m_ctrlstatus_pkt.tagstateup;
    m_ctrlstatus_pkt.state            = rhs_.m_ctrlstatus_pkt.state;
    m_ctrlstatus_pkt.burstln          = rhs_.m_ctrlstatus_pkt.burstln;
    m_ctrlstatus_pkt.setway_debug     = rhs_.m_ctrlstatus_pkt.setway_debug;
    m_ctrlstatus_pkt.waypbusy_vec     = rhs_.m_ctrlstatus_pkt.waypbusy_vec;
    m_ctrlstatus_pkt.waystale_vec     = rhs_.m_ctrlstatus_pkt.waystale_vec;
    m_ctrlstatus_pkt.currstate        = rhs_.m_ctrlstatus_pkt.currstate;
    m_ctrlstatus_pkt.wayn             = rhs_.m_ctrlstatus_pkt.wayn ;
    m_ctrlstatus_pkt.hitwayn          = rhs_.m_ctrlstatus_pkt.hitwayn ;
    m_ctrlstatus_pkt.evictaddr        = rhs_.m_ctrlstatus_pkt.evictaddr;
    m_ctrlstatus_pkt.evictstate       = rhs_.m_ctrlstatus_pkt.evictstate;
    m_ctrlstatus_pkt.nackuce          = rhs_.m_ctrlstatus_pkt.nackuce;
    m_ctrlstatus_pkt.nack             = rhs_.m_ctrlstatus_pkt.nack;
    m_ctrlstatus_pkt.nackce           = rhs_.m_ctrlstatus_pkt.nackce;
    m_ctrlstatus_pkt.nacknoalloc      = rhs_.m_ctrlstatus_pkt.nacknoalloc;

  end                
  if (m_has_data) begin
    m_wr_pkt.data          = rhs_.m_wr_pkt.data;    
    m_wr_pkt.byten         = rhs_.m_wr_pkt.byten;   
    m_wr_pkt.beatn         = rhs_.m_wr_pkt.beatn;      
  end
endfunction : do_copy

//------------------------------------------------------------------------------
// Do Compare
//------------------------------------------------------------------------------
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  ccp_ctrlstatus_seq_item rhs_;
  bit          compare_ctrlstatus;
  bit          compare_data;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  compare_ctrlstatus = (m_has_ctrl_req ?
    (m_ctrlstatus_pkt.bnk              == rhs_.m_ctrlstatus_pkt.bnk) &&
    (m_ctrlstatus_pkt.addr             == rhs_.m_ctrlstatus_pkt.addr) &&
    (m_ctrlstatus_pkt.alloc            == rhs_.m_ctrlstatus_pkt.alloc) &&
    (m_ctrlstatus_pkt.rd_data          == rhs_.m_ctrlstatus_pkt.rd_data) &&
    (m_ctrlstatus_pkt.wr_data          == rhs_.m_ctrlstatus_pkt.wr_data) &&
    (m_ctrlstatus_pkt.rsp_evict_sel    == rhs_.m_ctrlstatus_pkt.rsp_evict_sel) &&
    (m_ctrlstatus_pkt.bypass           == rhs_.m_ctrlstatus_pkt.bypass) &&
    (m_ctrlstatus_pkt.rp_update        == rhs_.m_ctrlstatus_pkt.rp_update ) &&
    (m_ctrlstatus_pkt.tagstateup       == rhs_.m_ctrlstatus_pkt.tagstateup) &&
    (m_ctrlstatus_pkt.state            == rhs_.m_ctrlstatus_pkt.state) &&
    (m_ctrlstatus_pkt.burstln          == rhs_.m_ctrlstatus_pkt.burstln) &&
    (m_ctrlstatus_pkt.setway_debug     == rhs_.m_ctrlstatus_pkt.setway_debug) &&
    (m_ctrlstatus_pkt.waypbusy_vec     == rhs_.m_ctrlstatus_pkt.waypbusy_vec) &&
    (m_ctrlstatus_pkt.waystale_vec     == rhs_.m_ctrlstatus_pkt.waystale_vec) &&
    (m_ctrlstatus_pkt.currstate        == rhs_.m_ctrlstatus_pkt.currstate) &&
    (m_ctrlstatus_pkt.wayn             == rhs_.m_ctrlstatus_pkt.wayn ) &&
    (m_ctrlstatus_pkt.hitwayn          == rhs_.m_ctrlstatus_pkt.hitwayn ) &&
    (m_ctrlstatus_pkt.evictaddr        == rhs_.m_ctrlstatus_pkt.evictaddr) &&
    (m_ctrlstatus_pkt.evictstate       == rhs_.m_ctrlstatus_pkt.evictstate) &&
    (m_ctrlstatus_pkt.nackuce          == rhs_.m_ctrlstatus_pkt.nackuce) &&
    (m_ctrlstatus_pkt.nack             == rhs_.m_ctrlstatus_pkt.nack) &&
    (m_ctrlstatus_pkt.nackce           == rhs_.m_ctrlstatus_pkt.nackce) &&
    (m_ctrlstatus_pkt.nacknoalloc      == rhs_.m_ctrlstatus_pkt.nacknoalloc):1);

  compare_data = ((m_has_data)?
    (m_wr_pkt.data          == rhs_.m_wr_pkt.data) &&    
    (m_wr_pkt.byten         == rhs_.m_wr_pkt.byten) &&   
    (m_wr_pkt.beatn         == rhs_.m_wr_pkt.beatn):1);      
  return super.do_compare(rhs, comparer) && compare_data && compare_ctrlstatus ;
endfunction : do_compare

//------------------------------------------------------------------------------
// Convert to String
//------------------------------------------------------------------------------
function string convert2string();
  string s;

  $timeformat(-9, 2, " ns", 10);
    if (m_has_ctrl_req) begin
        s = m_ctrlstatus_pkt.sprint_pkt();
    end
    else if (m_has_data) begin
        s = m_wr_pkt.sprint_pkt();
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
endclass : ccp_ctrlstatus_seq_item


////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// CCP Cache Dout  Packet
//
////////////////////////////////////////////////////////////////////////////////
class ccp_cacheevict_seq_item extends uvm_sequence_item;

  `uvm_object_utils(ccp_cacheevict_seq_item)

  bit  m_has_dout = 1;
  bit  m_reset   = 0;

  rand ccp_evict_pkt_t    m_evict_pkt;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "ccp_cacheevict_seq_item");
  super.new(name);
  m_evict_pkt = new();
endfunction : new

//------------------------------------------------------------------------------
// Do Copy
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
  ccp_cacheevict_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  m_has_dout = rhs_.m_has_dout;
  m_reset   = rhs_.m_reset;
  if (m_has_dout) begin
    m_evict_pkt.data             = rhs_.m_evict_pkt.data;      
    m_evict_pkt.datacancel       = rhs_.m_evict_pkt.datacancel;
  end
endfunction : do_copy

//------------------------------------------------------------------------------
// Do Compare
//------------------------------------------------------------------------------
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  ccp_cacheevict_seq_item rhs_;
  bit          compare_data;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  compare_data = (m_has_dout ?
    (m_evict_pkt.data             == rhs_.m_evict_pkt.data) &&      
    (m_evict_pkt.datacancel       == rhs_.m_evict_pkt.datacancel):1);
  return super.do_compare(rhs, comparer) && compare_data;
endfunction : do_compare

//------------------------------------------------------------------------------
// Convert to String
//------------------------------------------------------------------------------
function string convert2string();
  string s;

  $timeformat(-9, 2, " ns", 10);
    if (m_has_dout) begin
        s = m_evict_pkt.sprint_pkt();
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
endclass : ccp_cacheevict_seq_item
class ccp_rdrsp_seq_item extends uvm_sequence_item;

  `uvm_object_utils(ccp_rdrsp_seq_item)

  bit  m_has_dout = 1;
  bit  m_reset   = 0;

  rand ccp_rd_rsp_pkt_t    m_rdrsp_pkt;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "ccp_rdrsp_seq_item");
  super.new(name);
  m_rdrsp_pkt = new();
endfunction : new

//------------------------------------------------------------------------------
// Do Copy
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
  ccp_rdrsp_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  m_has_dout = rhs_.m_has_dout;
  m_reset   = rhs_.m_reset;
  if (m_has_dout) begin
    m_rdrsp_pkt.data             = rhs_.m_rdrsp_pkt.data;      
    m_rdrsp_pkt.datacancel       = rhs_.m_rdrsp_pkt.datacancel;
  end
endfunction : do_copy

//------------------------------------------------------------------------------
// Do Compare
//------------------------------------------------------------------------------
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  ccp_rdrsp_seq_item rhs_;
  bit          compare_data;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  compare_data = (m_has_dout ?
    (m_rdrsp_pkt.data             == rhs_.m_rdrsp_pkt.data) &&      
    (m_rdrsp_pkt.datacancel       == rhs_.m_rdrsp_pkt.datacancel):1);
  return super.do_compare(rhs, comparer) && compare_data;
endfunction : do_compare

//------------------------------------------------------------------------------
// Convert to String
//------------------------------------------------------------------------------
function string convert2string();
  string s;

  $timeformat(-9, 2, " ns", 10);
    if (m_has_dout) begin
        s = m_rdrsp_pkt.sprint_pkt();
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
endclass : ccp_rdrsp_seq_item
////////////////////////////////////////////////////////////////////////////////
//
// CCP Cache fill  seq item
//
////////////////////////////////////////////////////////////////////////////////
class ccp_cachefill_seq_item extends uvm_sequence_item;

  `uvm_object_utils(ccp_cachefill_seq_item)

  bit  m_has_fillctrl_req = 1;
  bit  m_has_filldata_req = 1;
  bit  m_reset   = 0;
  rand bit miss;

  rand ccp_filldata_pkt_t  filldata_pkt;
  rand ccp_fillctrl_pkt_t  fillctrl_pkt;


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "ccp_cachefill_seq_item");
  super.new(name);
  filldata_pkt = new();
  fillctrl_pkt = new();
endfunction : new

//------------------------------------------------------------------------------
// Do Copy
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
  ccp_cachefill_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  m_has_filldata_req = rhs_.m_has_filldata_req;
  m_has_fillctrl_req = rhs_.m_has_fillctrl_req;
  m_reset   = rhs_.m_reset;

  if (m_has_filldata_req) begin
    filldata_pkt.data         = rhs_.filldata_pkt.data;    
    filldata_pkt.fillId       = rhs_.filldata_pkt.fillId;   
    filldata_pkt.addr         = rhs_.filldata_pkt.addr;    
    filldata_pkt.wayn         = rhs_.filldata_pkt.wayn;  
    filldata_pkt.beatn        = rhs_.filldata_pkt.beatn; 
    filldata_pkt.doneId       = rhs_.filldata_pkt.doneId;
    filldata_pkt.done         = rhs_.filldata_pkt.done;  
    filldata_pkt.last         = rhs_.filldata_pkt.last;  
  end
  if (m_has_fillctrl_req) begin
    fillctrl_pkt.addr         = rhs_.fillctrl_pkt.addr;    
    fillctrl_pkt.wayn         = rhs_.fillctrl_pkt.wayn;  
    fillctrl_pkt.security     = rhs_.fillctrl_pkt.security;  
    fillctrl_pkt.state        = rhs_.fillctrl_pkt.state; 
  end
endfunction : do_copy

//------------------------------------------------------------------------------
// Do Compare
//------------------------------------------------------------------------------
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  ccp_cachefill_seq_item rhs_;
  bit          compare_datareq;
  bit          compare_ctrlreq;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  compare_datareq =( m_has_filldata_req ?
    (filldata_pkt.data    ==   rhs_.filldata_pkt.data  ) && 
    (filldata_pkt.fillId  ==   rhs_.filldata_pkt.fillId) &&      
    (filldata_pkt.addr    ==   rhs_.filldata_pkt.addr) &&   
    (filldata_pkt.wayn    ==   rhs_.filldata_pkt.wayn) &&  
    (filldata_pkt.beatn   ==   rhs_.filldata_pkt.beatn) &&
    (filldata_pkt.doneId  ==   rhs_.filldata_pkt.doneId) &&
    (filldata_pkt.done    ==   rhs_.filldata_pkt.done):1);
  compare_ctrlreq =( m_has_fillctrl_req ?
    (fillctrl_pkt.addr    ==   rhs_.fillctrl_pkt.addr) &&   
    (fillctrl_pkt.wayn    ==   rhs_.fillctrl_pkt.wayn) &&  
    (fillctrl_pkt.security==   rhs_.fillctrl_pkt.security) &&  
    (fillctrl_pkt.state   ==   rhs_.fillctrl_pkt.state):1);
  return super.do_compare(rhs, comparer) && compare_datareq && compare_ctrlreq;
endfunction : do_compare

//------------------------------------------------------------------------------
// Convert to String
//------------------------------------------------------------------------------
function string convert2string();
  string s;

  $timeformat(-9, 2, " ns", 10);

    if (m_has_filldata_req) begin
        s = filldata_pkt.sprint_pkt();
    end
    if (m_has_filldata_req) begin
        s = fillctrl_pkt.sprint_pkt();
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
endclass : ccp_cachefill_seq_item

////////////////////////////////////////////////////////////////////////////////
//
// CCP Cache maintenance  seq item
//
////////////////////////////////////////////////////////////////////////////////
class ccp_csr_maint_seq_item extends uvm_sequence_item;

  `uvm_object_utils(ccp_csr_maint_seq_item)

  bit  m_has_wr_req = 1;
  bit  m_has_rd_req = 1;
  bit  m_reset   = 0;

  rand ccp_csr_maint_pkt_t  csr_maint_pkt;


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "ccp_csr_maint_seq_item");
  super.new(name);
  csr_maint_pkt = new();
endfunction : new

//------------------------------------------------------------------------------
// Do Copy
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
  ccp_csr_maint_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  m_has_wr_req = rhs_.m_has_wr_req;
  m_has_rd_req = rhs_.m_has_rd_req;
  m_reset   = rhs_.m_reset;

  if (m_has_wr_req) begin
    csr_maint_pkt.wrdata         = rhs_.csr_maint_pkt.wrdata;    
    csr_maint_pkt.opcode         = rhs_.csr_maint_pkt.opcode;   
    csr_maint_pkt.wayn           = rhs_.csr_maint_pkt.wayn;  
    csr_maint_pkt.entry          = rhs_.csr_maint_pkt.entry; 
    csr_maint_pkt.word           = rhs_.csr_maint_pkt.word;
  end
  if (m_has_rd_req) begin
    csr_maint_pkt.rddata         = rhs_.csr_maint_pkt.rddata;
    csr_maint_pkt.active         = rhs_.csr_maint_pkt.active;  
    csr_maint_pkt.rddata_en      = rhs_.csr_maint_pkt.rddata_en;  
  end
endfunction : do_copy

//------------------------------------------------------------------------------
// Do Compare
//------------------------------------------------------------------------------
function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  ccp_csr_maint_seq_item rhs_;
  bit          compare_wrreq;
  bit          compare_rdreq;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  compare_wrreq =( m_has_wr_req ?
    (csr_maint_pkt.wrdata ==   rhs_.csr_maint_pkt.wrdata  ) && 
    (csr_maint_pkt.opcode ==   rhs_.csr_maint_pkt.opcode) &&      
    (csr_maint_pkt.wayn   ==   rhs_.csr_maint_pkt.wayn) &&   
    (csr_maint_pkt.entry  ==   rhs_.csr_maint_pkt.entry) &&  
    (csr_maint_pkt.word   ==   rhs_.csr_maint_pkt.word):1);
  compare_rdreq =( m_has_rd_req ?
    (csr_maint_pkt.rddata     ==   rhs_.csr_maint_pkt.rddata   ) &&   
    (csr_maint_pkt.active     ==   rhs_.csr_maint_pkt.active   ) &&  
    (csr_maint_pkt.rddata_en  ==   rhs_.csr_maint_pkt.rddata_en):1);
  return super.do_compare(rhs, comparer) && compare_wrreq && compare_rdreq;
endfunction : do_compare

//------------------------------------------------------------------------------
// Convert to String
//------------------------------------------------------------------------------
function string convert2string();
  string s;

  $timeformat(-9, 2, " ns", 10);

        s = csr_maint_pkt.sprint_pkt();
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
endclass : ccp_csr_maint_seq_item

