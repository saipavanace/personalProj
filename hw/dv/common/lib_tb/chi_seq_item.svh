////////////////////////////////////////////////////////////////////////////////
// 
// Author       : Muffadal 
// Purpose      : CHI sequence item 
// Revision     :
//
//according to chi-spec max transaction-is = 256
////////////////////////////////////////////////////////////////////////////////
<%
var DVMV8_4=(obj.DveInfo[0].DVMVersionSupport==132)?1:0;
var DVMV8_1=(obj.DveInfo[0].DVMVersionSupport==129)?1:0;
var DVMV8_0=(obj.DveInfo[0].DVMVersionSupport==128)?1:0;
%>

class chi_base_seq_item extends uvm_sequence_item;
    rand chi_qos_t      qos   ;
    rand chi_tgtid_t    tgtid ;
    rand chi_srcid_t    srcid  ;
    rand chi_txnid_t    txnid  ;
    rand chi_tracetag_t tracetag;
    bit                 lcrdv;
    //Additional helper properties that do not
    //belong to CHI protocol
    //num cycles to delay before driving the txn on interface
    int n_cycles;
    //If set, lock the sequencer to this sequence until all
    //sequence items are forwarded to drive
    bit en_lock;

    //Helper variable to asser/deassert txsactive signal
    bit txsactv;

    //Helper variable to assert/deassert sysco signal
    chi_sysco_t sysco_req, sysco_ack;

    //Helper Properties
    chi_revision_t  rev_type;
    chi_node_t      node_type;
    time            pkt_time;
<% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
   `ifdef VCS
    int    unsupported_txn_vcs;
   `endif 
<% }  %>

    `uvm_object_param_utils_begin ( chi_base_seq_item   )
    `uvm_field_int          ( qos   ,   UVM_DEFAULT )
    `uvm_field_int          ( tgtid  ,   UVM_DEFAULT )
    `uvm_field_int          ( srcid ,   UVM_DEFAULT )
    `uvm_field_int          ( txnid ,   UVM_DEFAULT )
    `uvm_field_int          ( tracetag, UVM_NOCOMPARE)
    `uvm_field_int          ( sysco_req, UVM_NOCOMPARE)
    `uvm_field_int          ( sysco_ack, UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint c_qos {
        qos inside {[0:15]};
    }

    //Methods
    extern function new(string name = "chi_base_seq_item");
    extern virtual function void do_copy(uvm_object rhs);
    extern virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern virtual function string convert2string();
    extern virtual function string convert2string_helper_fields();
    extern virtual function void overwrite_pkt_time(time t);

    extern virtual function packed_flit_t pack_flit();
    extern virtual function void unpack_flit(const ref packed_flit_t flit);

endclass

//Constructor 
function chi_base_seq_item::new(string name = "chi_base_seq_item");
    super.new(name);
<% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
   `ifdef VCS
        if($test$plusargs("unsupported_txn")) begin
        	unsupported_txn_vcs = 1;
        end
   `endif 
<% }  %>

endfunction: new

function void chi_base_seq_item::do_copy(uvm_object rhs);
    chi_base_seq_item rhs_;

    super.do_copy(rhs);
    if(!$cast(rhs_, rhs)) begin
        $stacktrace;
        `uvm_error(get_name(), "Unable to cast")
    end

    //Packet fileds
    this.qos      = rhs_.qos;
    this.tgtid     = rhs_.tgtid;
    this.srcid    = rhs_.srcid;
    this.txnid    = rhs_.txnid;
    this.tracetag = rhs_.tracetag;
    this.sysco_req = rhs_.sysco_req;
    this.sysco_ack = rhs_.sysco_ack;

    //Helper fields
    this.rev_type  = rhs_.rev_type;
    this.node_type = rhs_.node_type;
    this.pkt_time  = rhs_.pkt_time;
endfunction: do_copy

function bit chi_base_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
    chi_base_seq_item rhs_;
    bit status;

    if(!$cast(rhs_, rhs)) begin
        $stacktrace;
        `uvm_error(get_name(), "Unable to cast")
    end
    
    status = ((this.qos      == rhs_.qos)      &&
              (this.tgtid     == rhs_.tgtid)     &&
              (this.srcid    == rhs_.srcid)    &&
              (this.txnid    == rhs_.txnid)) ? 1'b1 : 1'b0;
              //(this.tracetag == rhs_.tracetag)) ? 1'b1 : 1'b0;

    return(status);
endfunction: do_compare

function string chi_base_seq_item::convert2string();
    string s;
   <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
   `ifdef VCS
    string mypkt_time;
    $sformat(mypkt_time, "%0s", pkt_time);
   `endif // `ifndef VCS ... `else ... 
   <% } %>

    $timeformat(-9, 2, " ns", 10);
   <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
   `ifndef VCS
    $sformat(s, "%s time:%0t", super.convert2string(), pkt_time);
   `else // `ifndef VCS
    $sformat(s, "%s time:%0s", super.convert2string(), mypkt_time);
   `endif // `ifndef VCS ... `else ... 
   <% } else {%>
    $sformat(s, "%s time:%0t", super.convert2string(), pkt_time);
   <% } %>
    $sformat(s, "%s qos:0x%0h tgtid:0x%0h srcid:0x%0h txnid:0x%0h tracetag:0x%0h sysco_req:0x%0h sysco_ack:0x%0h",
        s, qos, tgtid, srcid, txnid, tracetag, sysco_req, sysco_ack);
    return(s);
endfunction:convert2string

function string chi_base_seq_item::convert2string_helper_fields();
    string s;

    $timeformat(-9, 2, " ns", 10);
    $sformat(s, "%s time:%0t", s, super.convert2string(), pkt_time);
    $sformat(s, "%s rev_type:%s", s, rev_type.name());

    return(s);
endfunction: convert2string_helper_fields

function void chi_base_seq_item::overwrite_pkt_time(time t);
    pkt_time = t;
endfunction: overwrite_pkt_time


function packed_flit_t chi_base_seq_item::pack_flit();
  packed_flit_t flitq;
  `uvm_fatal(get_name(), "Not yet implemented")
  return flitq; 
endfunction: pack_flit

function void chi_base_seq_item::unpack_flit(const ref packed_flit_t flit);
  //`uvm_fatal(get_name(), "Not yet implemented")
  this.qos = flit[0][`CHI_REQ_QOS_MSB:`CHI_REQ_QOS_LSB];
  this.tgtid = flit[0][`CHI_REQ_TGTID_MSB:`CHI_REQ_TGTID_LSB];
  this.srcid = flit[0][`CHI_REQ_SRCID_MSB:`CHI_REQ_SRCID_LSB];
  this.txnid = flit[0][`CHI_REQ_TXNID_MSB:`CHI_REQ_TXNID_LSB];
endfunction: unpack_flit

//******************************************************************************
// Class   : chi_req_seq_item
// Purpose : CHI request item to generate read/write txn.
//          
//
//******************************************************************************

class chi_req_seq_item extends chi_base_seq_item;
  rand   chi_lpid_t               lpid           ;
  rand   chi_req_returnnid_t      returnnid      ;
  rand   chi_req_returntxnid_t    returntxnid    ;
  rand   chi_req_stashnid_t       stashnid       ;
  rand   chi_req_stashnidvalid_t  stashnidvalid  ;
  rand   chi_lpid_t               stashlpid      ;
  rand   chi_lpidvalid_t          stashlpidvalid ;
  rand   chi_req_opcode_enum_t    opcode         ;
  rand   chi_addr_t               addr           ;
  rand   chi_ns_t                 ns             ;
  rand   chi_req_size_t           size           ;
  rand   chi_req_allowretry_t     allowretry     ;
  rand   chi_req_pcrdtype_t       pcrdtype       ;
  rand   chi_req_expcompack_t     expcompack     ;
  rand   chi_req_memattr_t        memattr        ;
  rand   chi_req_snpattr_t        snpattr        ;
  rand   chi_req_snoopme_t        snoopme        ;
  rand   chi_req_likelyshared_t   likelyshared   ;
  rand   chi_req_excl_t           excl           ;
  rand   chi_req_order_t          order          ;
  rand   chi_req_endian_t         endian         ;
  rand   chi_req_rsvdc_t          rsvdc          ;
  bit    allow_retry_rand                        ;
  // New fiels for CHI-E
  rand   chi_req_slcrephint_t     slcrephint     ;
  rand   chi_req_deep_t           deep           ;
  rand   chi_req_dodwt_t          dodwt          ;
  rand   chi_req_pgroupid_t       pgroupid       ;
  rand   chi_req_stashgroupid_t   stashgroupid   ;
  rand   chi_req_taggroupid_t     taggroupid     ;
  rand   chi_req_rsvdc_t          tagop          ;
  rand   chi_req_rsvdc_t          mpam           ;




  //CHI SPEC: Ch: 2.6 Pg: 73 must be tied to 0
  //CHI SPEC: Ch: 2.6 Pg: 73 must be tied to 0
  constraint c_returnnid {
      if((node_type != SN_F) && (node_type != SN_I)) {
         returnnid == 0;
         returntxnid == 0;
      } else {
          if(opcode != READNOSNP) {
              returnnid == 0;
              returntxnid == 0;
          }
      }
  }

  constraint c_stashnidvalid {
     <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
     `ifndef VCS
      if(is_stash_opcode()) {
     `else // `ifndef VCS
      if((opcode inside {stash_ops})) {
     `endif // `ifndef VCS ... `else ... 
     <% } else {%>
      if(is_stash_opcode()) {
     <% } %>
          stashnidvalid dist {
            0 := 30,
            1 := 70
          };
      } else {
          stashnidvalid == 1'b0;
      }
  }

<%if(obj.AiuInfo[obj.Id].fnNativeInterface != "CHI-A"){%>
	constraint c_chi_opcode {
           <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
            `ifndef VCS
            if($test$plusargs("unsupported_txn")) {
		!(opcode  inside {WRITECLEANPTL});
            `else // `ifndef VCS
            if(unsupported_txn_vcs) {
		!(opcode  inside {WRITECLEANPTL});
            `endif // `ifndef VCS ... `else ... 
            <% } else {%>
            if($test$plusargs("unsupported_txn")) {
		!(opcode  inside {WRITECLEANPTL});
            <% } %>
            } else {
		!(opcode  inside {EOBARRIER, ECBARRIER, WRITECLEANPTL});
            }
	}
<%}%>

  //constraint c_order {
  

  //}

  //Constraint for setting for various stash opcode's related fields
  //method is_atomic_opcode() returns 'True' only if selected opcode
  //is stashing command and there are ACE-lite-e agents in the system.
  //
  //stashlpid value is set in post-randomization phase
  
  constraint c_stashnid {
    <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
     `ifndef VCS
      if(is_stash_opcode()) {
     `else // `ifndef VCS
      if((opcode inside {stash_ops})) {
     `endif // `ifndef VCS ... `else ... 
     <% } else {%>
      if(is_stash_opcode()) {
     <% } %>
          (stashnidvalid == 1) -> stashnid inside {ncoreConfigInfo::aiu_nids};
          (stashnidvalid == 1) -> stashnid !=  <%=obj.AiuInfo[obj.Id].nUnitId%> ;
          (stashnidvalid == 0) -> stashnid == 0;
          (stashnidvalid == 1) -> stashlpidvalid dist {0 := 10, 1 := 90};
      } else {
          stashnidvalid  == 0;
          stashnid       == 0;
          stashlpidvalid == 0;
      }
      solve stashnidvalid before stashnid;
      solve stashnidvalid before stashlpidvalid;
  }

  //Randomize only if opcode is of atomic flavor
  constraint c_endian {
      <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
      `ifndef VCS
      (!is_atomic_opcode()) -> endian == 1'b0;
      `else // `ifndef VCS
      (!((opcode inside {atomic_dat_ops, atomic_dtls_ops}))) -> endian == 1'b0;
      `endif // `ifndef VCS ... `else ... 
      <% } else {%>
      (!is_atomic_opcode()) -> endian == 1'b0;
      <% } %>
  }

  //Altered in post randomization phase
  constraint c_size {
      size inside {[0:6]};
  }

  //Likely shared constraints
  constraint c_likelyshared {
<% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
      <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
     `ifndef VCS
      if((is_likely_shared()) || (opcode == PREFETCHTARGET))
      `else // `ifndef VCS
      if(((
<% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
              (opcode == READNOTSHAREDDIRTY)   ||
              (opcode == STASHONCEUNIQUE)      ||
              (opcode == STASHONCESHARED)      ||
              (opcode == WRITEUNIQUEPTLSTASH)  ||
              (opcode == WRITEUNIQUEFULLSTASH) ||
<% } %>
	      (opcode == READCLEAN)            ||
              (opcode == READSHARED)           ||
              (opcode == WRITEUNIQUEPTL)       ||
              (opcode == WRITEUNIQUEFULL)      ||
              (opcode == WRITEBACKFULL)        ||
              (opcode == WRITECLEANFULL)       ||
              (opcode == WRITEEVICTFULL))) || (opcode == PREFETCHTARGET))
      `endif // `ifndef VCS ... `else ... 
      <% } else {%>
      if((is_likely_shared()) || (opcode == PREFETCHTARGET))
      <% } %>
          soft likelyshared inside {[0:1]};
      else
<% } %>
          soft likelyshared == 0;
  }

  //In Ncore v3.0 this feature is disabled
<%if(obj.testBench == "chi_aiu"){ %>
  constraint c_allowretry {
	if (!allow_retry_rand)
	    allowretry == 1'b0; 
  }
<%} else { %>
  constraint c_allowretry {
	    allowretry == 1'b0; 
  }
<%}%>

  //Inc Ncore v3.0 this feature is disabled
  constraint c_pcrdtype {
    pcrdtype == 0;
  }

  `uvm_object_param_utils_begin ( chi_req_seq_item   )
      `uvm_field_int          ( lpid          , UVM_DEFAULT )
      `uvm_field_int          ( returnnid     , UVM_DEFAULT )
      `uvm_field_int          ( returntxnid   , UVM_DEFAULT )
      `uvm_field_int          ( stashnidvalid , UVM_DEFAULT )
      `uvm_field_int          ( stashlpid     , UVM_DEFAULT )
      `uvm_field_int          ( stashlpidvalid, UVM_DEFAULT )
      `uvm_field_enum         ( chi_req_opcode_enum_t, opcode, UVM_DEFAULT )
      `uvm_field_int          ( addr          , UVM_DEFAULT )
      `uvm_field_int          ( ns            , UVM_DEFAULT )
      `uvm_field_int          ( size          , UVM_DEFAULT )
      `uvm_field_int          ( allowretry    , UVM_DEFAULT )
      `uvm_field_int          ( pcrdtype      , UVM_DEFAULT )
      `uvm_field_int          ( expcompack    , UVM_DEFAULT )
      `uvm_field_int          ( memattr       , UVM_DEFAULT )
      `uvm_field_int          ( snpattr       , UVM_DEFAULT )
      `uvm_field_int          ( snoopme       , UVM_DEFAULT )
      `uvm_field_int          ( likelyshared  , UVM_DEFAULT )
      `uvm_field_int          ( excl          , UVM_DEFAULT )
      `uvm_field_int          ( order         , UVM_DEFAULT )
      `uvm_field_int          ( endian        , UVM_DEFAULT )
      `uvm_field_int          ( rsvdc         , UVM_DEFAULT )
  `uvm_object_utils_end

  //API methods to perfrom sequence item operations
  extern function               new(string name = "chi_req_seq_item");
  extern function void          do_copy(uvm_object rhs);
  extern function bit           do_compare(
    uvm_object rhs,
    uvm_comparer comparer);
  extern function string        convert2string();
  extern function void          do_print(uvm_printer printer);
  extern function packed_flit_t pack_flit();
  extern function void          unpack_flit(const ref packed_flit_t flit);

  //Helper methods
  extern function bit is_stash_opcode();
  extern function bit is_exclusive_opcode();
  extern function bit is_atomic_opcode();
  extern function bit is_likely_shared();
  extern function bit is_coh_opcode();
  extern function bit is_legal_dvm_request(bit isDVMSync);

  function void post_randomize();
          if(stashnidvalid == 1)
          begin
		foreach(ncoreConfigInfo::aiu_nids[i])
			if(ncoreConfigInfo::aiu_nids[i]== stashnid)
				stashnid = ncoreConfigInfo::funit_ids[i];
         	//$display("stashnid %x", stashnid);
      end
      if ($test$plusargs("pmon_bw_user_bits") && WREQRSVDC > 0) begin
        rsvdc = $urandom_range(5,15);
        `uvm_info($sformatf("%m"), $sformatf("CHI VSEQ debug Pmon bw user bits testcase is enabled randomized NDP_AUX = %0p", rsvdc), UVM_MEDIUM)
     end
  
  endfunction

endclass

//Constructor
function chi_req_seq_item::new(string name = "chi_req_seq_item");
    super.new(name);
    if($test$plusargs("allow_retry_rand")) begin
      	allow_retry_rand = 1;
    end	else begin
      	allow_retry_rand = 0;
    end
endfunction: new

function void chi_req_seq_item::do_copy(uvm_object rhs);
    chi_req_seq_item  rhs_;

    super.do_copy(rhs);
    if(!$cast(rhs_, rhs)) begin
        `uvm_error(get_name(), "Unable to cast")
    end

    this.lpid           = rhs_.lpid;
    this.returnnid      = rhs_.returnnid;
    this.returntxnid    = rhs_.returntxnid;
    this.stashnid       = rhs_.stashnid;
    this.stashnidvalid  = rhs_.stashnidvalid;
    this.stashlpid      = rhs_.stashlpid;
    this.stashlpidvalid = rhs_.stashlpidvalid;
    this.opcode         = rhs_.opcode;
    this.addr           = rhs_.addr;
    this.ns             = rhs_.ns;
    this.size           = rhs_.size;
    this.allowretry     = rhs_.allowretry;
    this.pcrdtype       = rhs_.pcrdtype;
    this.expcompack     = rhs_.expcompack;
    this.memattr        = rhs_.memattr;
    this.snpattr        = rhs_.snpattr;
    this.snoopme        = rhs_.snoopme;
    this.likelyshared   = rhs_.likelyshared;
    this.excl           = rhs_.excl;
    this.order          = rhs_.order;
    this.endian         = rhs_.endian;
    this.rsvdc          = rhs_.rsvdc;
endfunction: do_copy

function bit chi_req_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
    bit status;
    chi_req_seq_item rhs_;

    if(!$cast(rhs_, rhs)) begin
        `uvm_error(get_name(), "Unable to cast")
    end

   status = super.do_compare(rhs_, comparer);
   if(status) begin
   <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
   `ifndef VCS
      status = ((this.lpid           = rhs_.lpid)           &&
                 (this.returnnid      = rhs_.returnnid)      &&
                 (this.returntxnid    = rhs_.returntxnid)    &&
                 (this.stashnid       = rhs_.stashnid)       &&
                 (this.stashnidvalid  = rhs_.stashnidvalid)  &&
                 (this.stashlpid      = rhs_.stashlpid)      &&
                 (this.stashlpidvalid = rhs_.stashlpidvalid) &&
                 (this.opcode         = rhs_.opcode)         &&
                 (this.addr           = rhs_.addr)           &&
                 (this.ns             = rhs_.ns)             &&
                 (this.size           = rhs_.size)           &&
                 (this.allowretry     = rhs_.allowretry)     &&
                 (this.pcrdtype       = rhs_.pcrdtype)       &&
                 (this.expcompack     = rhs_.expcompack)     &&
                 (this.memattr        = rhs_.memattr)        &&
                 (this.snpattr        = rhs_.snpattr)        &&
                 (this.snoopme        = rhs_.snoopme)        &&
                 (this.likelyshared   = rhs_.likelyshared)   &&
                 (this.excl           = rhs_.excl)           &&
                 (this.order          = rhs_.order)          &&
                 (this.endian         = rhs_.endian)         &&
                 (this.rsvdc          = rhs_.rsvdc)) ? 1'b1 : 1'b0;

   `else // `ifndef VCS
      status = ((this.lpid            == rhs_.lpid)           &&
                 (this.returnnid      == rhs_.returnnid)      &&
                 (this.returntxnid    == rhs_.returntxnid)    &&
                 (this.stashnid       == rhs_.stashnid)       &&
                 (this.stashnidvalid  == rhs_.stashnidvalid)  &&
                 (this.stashlpid      == rhs_.stashlpid)      &&
                 (this.stashlpidvalid == rhs_.stashlpidvalid) &&
                 (this.opcode         == rhs_.opcode)         &&
                 (this.addr           == rhs_.addr)           &&
                 (this.ns             == rhs_.ns)             &&
                 (this.size           == rhs_.size)           &&
                 (this.allowretry     == rhs_.allowretry)     &&
                 (this.pcrdtype       == rhs_.pcrdtype)       &&
                 (this.expcompack     == rhs_.expcompack)     &&
                 (this.memattr        == rhs_.memattr)        &&
                 (this.snpattr        == rhs_.snpattr)        &&
                 (this.snoopme        == rhs_.snoopme)        &&
                 (this.likelyshared   == rhs_.likelyshared)   &&
                 (this.excl           == rhs_.excl)           &&
                 (this.order          == rhs_.order)          &&
                 (this.endian         == rhs_.endian)         &&
                 (this.rsvdc          == rhs_.rsvdc)) ? 1'b1 : 1'b0;

   `endif // `ifndef VCS ... `else ... 
   <% } else {%>
       status = ((this.lpid           = rhs_.lpid)           &&
                 (this.returnnid      = rhs_.returnnid)      &&
                 (this.returntxnid    = rhs_.returntxnid)    &&
                 (this.stashnid       = rhs_.stashnid)       &&
                 (this.stashnidvalid  = rhs_.stashnidvalid)  &&
                 (this.stashlpid      = rhs_.stashlpid)      &&
                 (this.stashlpidvalid = rhs_.stashlpidvalid) &&
                 (this.opcode         = rhs_.opcode)         &&
                 (this.addr           = rhs_.addr)           &&
                 (this.ns             = rhs_.ns)             &&
                 (this.size           = rhs_.size)           &&
                 (this.allowretry     = rhs_.allowretry)     &&
                 (this.pcrdtype       = rhs_.pcrdtype)       &&
                 (this.expcompack     = rhs_.expcompack)     &&
                 (this.memattr        = rhs_.memattr)        &&
                 (this.snpattr        = rhs_.snpattr)        &&
                 (this.snoopme        = rhs_.snoopme)        &&
                 (this.likelyshared   = rhs_.likelyshared)   &&
                 (this.excl           = rhs_.excl)           &&
                 (this.order          = rhs_.order)          &&
                 (this.endian         = rhs_.endian)         &&
                 (this.rsvdc          = rhs_.rsvdc)) ? 1'b1 : 1'b0;
   <% } %>
   end

   return(status);
endfunction: do_compare

function string chi_req_seq_item::convert2string();
    string s;

    s = super.convert2string();
    $sformat(s, "%s opcode:%s addr:0x%0h ns:0x%0h size:0x%0h likelyshared:0x%0h allowretry:0x%0h",
        s, opcode, addr, ns, size, likelyshared, allowretry);
    $sformat(s, "%s order:0x%0h pcrdtype:0x%0h memattr:0x%0h snpattr:0x%0h lpid:0x%0h, expcompack:0x%0h",
        s, order, pcrdtype, memattr, snpattr, lpid, expcompack);

    if(is_stash_opcode()) begin
        $sformat(s, "%s stashnidvalid:0x%0h", s, stashnidvalid);
        //if(stashnidvalid) begin
            $sformat(s, "%s stashnid:0x%0h", s, stashnid);
        //end 
        $sformat(s, "%s stashlpidvalid:0x%0h", s, stashlpidvalid);
        //if(stashlpidvalid) begin
            $sformat(s, "%s stashlpid:0x%0h", s, stashlpid);
        //end
    end
    //if(is_exclusive_opcode()) begin
        $sformat(s, "%s excl:0x%0h", s, excl);
    //end
    if(is_atomic_opcode()) begin
        $sformat(s, "%s snoopme:0x%0h", s, snoopme);
    end
    if (WREQRSVDC > 0) begin
        $sformat(s, "%s rsvdc:0x%0h", s, rsvdc);
    end
    return(s);
endfunction: convert2string

function bit chi_req_seq_item::is_stash_opcode();
    bit status;

    status = (opcode inside {stash_ops}) ? 1'b1 : 1'b0;

    return(status);
endfunction: is_stash_opcode

function bit chi_req_seq_item::is_exclusive_opcode();
    bit status;

    status = ((opcode == READSHARED)         ||
              (opcode == READCLEAN)          ||
<% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
	      (opcode == READNOTSHAREDDIRTY) ||
<% } %>
              (opcode == CLEANUNIQUE)) ? 1'b1 : 1'b0;
              // below ops not supported as excl in Ncore3.0
              //(opcode == READNOSNP)          ||
              //(opcode == WRITENOSNPFULL)     ||
              //(opcode == WRITENOSNPPTL)) ? 1'b1 : 1'b0;
    return(status);
endfunction: is_exclusive_opcode

function bit chi_req_seq_item::is_atomic_opcode();
    bit status;
    status = ((opcode inside {atomic_dat_ops, atomic_dtls_ops})) ? 1'b1 : 1'b0;
    return(status);

    return(status);
endfunction: is_atomic_opcode

function bit chi_req_seq_item::is_likely_shared();
    bit status;

    status = (
<% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
              (opcode == READNOTSHAREDDIRTY)   ||
              (opcode == STASHONCEUNIQUE)      ||
              (opcode == STASHONCESHARED)      ||
              (opcode == WRITEUNIQUEPTLSTASH)  ||
              (opcode == WRITEUNIQUEFULLSTASH) ||
<% } %>
	      (opcode == READCLEAN)            ||
              (opcode == READSHARED)           ||
              (opcode == WRITEUNIQUEPTL)       ||
              (opcode == WRITEUNIQUEFULL)      ||
              (opcode == WRITEBACKFULL)        ||
              (opcode == WRITECLEANFULL)       ||
              (opcode == WRITEEVICTFULL)) ? 1'b1 : 1'b0;
    return(status);
endfunction: is_likely_shared

function bit chi_req_seq_item::is_coh_opcode();
    return ((opcode == CLEANINVALID
        || opcode == MAKEINVALID
	|| opcode == CLEANSHARED
<% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
	|| opcode == CLEANSHAREDPERSIST
    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
    || opcode == CLEANSHAREDPERSISTSEP
    <%}%>
<% } %>
 <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
    || opcode == CLEANSHAREDPERSISTSEP
    <%}%>
	|| opcode inside {atomic_dat_ops, atomic_dtls_ops}) ? this.snpattr :  
	(opcode == READNOSNP
        || opcode == WRITENOSNPPTL
        || opcode == WRITENOSNPFULL
 <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
        || opcode == WRITENOSNPZERO
        || opcode == WRITENOSNPFULL_CLEANSHARED 
        || opcode == WRITENOSNPFULL_CLEANINVALID 
        || opcode == WRITENOSNPFULL_CLEANSHAREDPERSISTSEP 
        || opcode == WRITEEVICTOREVICT 
        || opcode == WRITEBACKFULL_CLEANSHARED 
        || opcode == WRITEBACKFULL_CLEANINVALID 
        || opcode == WRITEBACKFULL_CLEANSHAREDPERSISTSEP 
        || opcode == WRITECLEANFULL_CLEANSHARED 
        || opcode == WRITECLEANFULL_CLEANSHAREDPERSISTSEP 
<% } %>
        || opcode == WRITEBACKPTL
        || opcode == WRITEBACKFULL
        || opcode == WRITECLEANPTL
        || opcode == WRITECLEANFULL
        || opcode == WRITEEVICTFULL
	|| opcode == WRITENOSNPPTL
	|| opcode == WRITENOSNPFULL
        || opcode == EVICT
        || opcode == DVMOP
<% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
	|| opcode == PREFETCHTARGET
<% } %>
	) ? 0 : 1);
endfunction : is_coh_opcode

function bit chi_req_seq_item::is_legal_dvm_request(bit isDVMSync);

    // #Check.CHI.v3.6.DVM_req_p1

    bit legal = 1;
    string label_string = $sformatf("CHI_AIU<%=obj.Id%> DVMOp request field mismatch"); 


    if(isDVMSync &&
    (addr[10:0] != 'h0  || addr[40:38] != 'h0)
    ) begin
        `uvm_info(label_string, $sformatf("ERROR: DVM Sync operation => ADDR field mismatches. Act value: 0x%0x", this.addr), UVM_NONE)   
        legal = 0;      
        return legal;      
    end

    // ARM CHI Architecture Spec Section 8.1.4 DVMop field value restrictions

    /*
    if (this.qos !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: qos field mismatches. Exp value: 'h0 Act value: 0x%0x", this.qos), UVM_NONE)   
        `uvm_info(label_string, $sformatf("QoS value zero is defined by Ncore 3.X Achitecture spec"), UVM_NONE)   
        legal = 0;
    end
    if (this.tgtid !== 'h<%=obj.DveInfo[0].FUnitId%>) begin
        `uvm_info(label_string, $sformatf("ERROR: TargetId field mismatches. Exp value: 'h<%=obj.DveInfo[0].FUnitId%> Act value: 0x%0x", this.tgtid), UVM_NONE)   
        legal = 0;
    end 
    */
    if (this.returnnid !== 'h0 ) begin
        `uvm_info("`LABEL_ITEM CHI DVMOp request field mismatch", $sformatf("ERROR: returnnid field mismatches. Exp value: 'h0 Act value: 0x%0x", this.returnnid), UVM_NONE)   
        legal = 0;
    end 
    if (this.stashnid !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: stashnid field mismatches. Exp value: 'h0 Act value: 0x%0x", this.stashnid), UVM_NONE)   
        legal = 0;
    end 
    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
    if (this.slcrephint !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: slcrephint field mismatches. Exp value: 'h0 Act value: 0x%0x", this.slcrephint), UVM_NONE)   
        legal = 0;
    end 
    if (this.deep !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: deep field mismatches. Exp value: 'h0 Act value: 0x%0x", this.deep), UVM_NONE)   
        legal = 0;
    end 
    <% } %>
    if (this.endian !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: endian field mismatches. Exp value: 'h0 Act value: 0x%0x", this.endian), UVM_NONE)   
        legal = 0;
    end 
    if (this.stashnidvalid !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: stashnidvalid field mismatches. Exp value: 'h0 Act value: 0x%0x", this.stashnidvalid), UVM_NONE)   
        legal = 0;
    end 
    if (this.returntxnid !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: returntxnid field mismatches. Exp value: 'h0 Act value: 0x%0x", this.returntxnid), UVM_NONE)   
        legal = 0;
    end 
    if (this.stashlpid !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: stashlpid field mismatches. Exp value: 'h0 Act value: 0x%0x", this.stashlpid), UVM_NONE)   
        legal = 0;
    end 
    if (this.stashlpidvalid !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: stashlpidvalid field mismatches. Exp value: 'h0 Act value: 0x%0x", this.stashlpidvalid), UVM_NONE)   
        legal = 0;
    end 
    if ( ! this.opcode inside {DVMOP} ) begin
        `uvm_info(label_string, $sformatf("ERROR: opcode field mismatches. Exp value: 'h%0h Act value: 0x%0x", DVMOP, this.opcode), UVM_NONE)   
        legal = 0;
    end 
    if (this.size !== 'h3 ) begin
        `uvm_info(label_string, $sformatf("ERROR: size field mismatches. Exp value: 'h3 (8 Bytes) Act value: 0x%0x", this.size), UVM_NONE)   
        legal = 0;
    end 
    if (this.ns !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: ns field mismatches. Exp value: 'h0 Act value: 0x%0x", this.ns), UVM_NONE)   
        legal = 0;
    end 
    if (this.likelyshared !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: likelyshared field mismatches. Exp value: 'h0 Act value: 0x%0x", this.likelyshared), UVM_NONE)   
        legal = 0;
    end 
    if (this.order !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: order field mismatches. Exp value: 'h0 Act value: 0x%0x", this.order), UVM_NONE)   
        legal = 0;
    end 
    if (this.pcrdtype !== 'h0 && this.allowretry) begin
        `uvm_info(label_string, $sformatf("ERROR: pcrdtype field mismatches. Exp value: 'h0 Act value: 0x%0x", this.pcrdtype), UVM_NONE)   
        legal = 0;
    end 
    if (this.memattr !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: memattr field mismatches. Exp value: 'h0 Act value: 0x%0x", this.memattr), UVM_NONE)   
        legal = 0;
    end
    <% if (!DVMV8_4) { %>
    if (this.snpattr !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: snpattr field mismatches. Exp value: 'h0 for CHI below rev. E Act value: 0x%0x", this.snpattr), UVM_NONE)   
        legal = 0;
    end 
    <% } %>
    if (this.excl !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: excl field mismatches. Exp value: 'h0 Act value: 0x%0x", this.excl), UVM_NONE)
        legal = 0;
    end
    if (this.snoopme !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: snoopme field mismatches. Exp value: 'h0 Act value: 0x%0x", this.snoopme), UVM_NONE)   
        legal = 0;
    end
    if (this.expcompack !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: expcompack field mismatches. Exp value: 'h0 Act value: 0x%0x", this.expcompack), UVM_NONE)   
        legal = 0;
    end
    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
    if (this.tagop !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: tagop field mismatches. Exp value: 'h0 Act value: 0x%0x", this.tagop), UVM_NONE)   
        legal = 0;
    end 
    if (this.mpam !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: mpam field mismatches. Exp value: 'h0 Act value: 0x%0x", this.mpam), UVM_NONE)   
        legal = 0;
    end 
    <% } %>
    if (this.addr[2:0] !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: addr[2:0] Reserved field mismatches. Exp value: 'h0 (Reserved) Act value: 0x%0x", this.addr[2:0]), UVM_NONE)   
        legal = 0;
    end 
    if (this.addr[3] !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: addr[3] Part field mismatches. Exp value: 'h0 Act value: 0x%0x", this.addr[3]), UVM_NONE)   
        legal = 0;
    end 
    if ((this.addr[5] ^ this.addr[6]) && this.addr[13:11] == 3'b010 ) begin  //PICI operation
        `uvm_info(label_string, $sformatf("ERROR: addr[6:5] field mismatches. Exp value: 'h0 or 'h3 Act value: 0x%0x", this.addr[6:5]), UVM_NONE)   
        legal = 0;
    end

    <% if (!DVMV8_4) { %>
    if (this.addr[8:7] == 2'b01 ) begin
        `uvm_info(label_string, $sformatf("ERROR: addr[8:7] Security field mismatches. Act value: 0x%0x is Reserved ", this.addr[8:7]), UVM_NONE)   
        legal = 0;
    end 
    <% } %>

    if (this.addr[13:11] inside {[3'b101:3'b111]} ) begin  //Reserved DVMOp Type
        `uvm_info(label_string, $sformatf("ERROR: addr[13:11] field mismatches. Exp value: from 'h0 to 'h4 Act value: 0x%0x", this.addr[13:11]), UVM_NONE)   
        legal = 0;
    end

    if (this.addr[5] == 0 && this.addr[21:14] != 'h0 ) begin  //VMID addr
       //`uvm_info(label_string, $sformatf("ERROR: VMID addr[21:14] field mismatches. Exp value: 'h0 Act value: 0x%0x", this.addr[21:14]), UVM_NONE)   
       //legal = 0; Ignore VMID
    end
    if (this.addr[6] == 0 && this.addr[37:22] != 'h0 ) begin  //ASID addr
       //`uvm_info(label_string, $sformatf("ERROR: ASID addr[37:22] field mismatches. Exp value: 'h0 Act value: 0x%0x", this.addr[37:22]), UVM_NONE)   
       //legal = 0; Ignore ASID
    end

    if (this.addr[39:38] ==  2'b11 ) begin  //Reserved 
        `uvm_info(label_string, $sformatf("ERROR: addr[39:38] field mismatches. Stage invalidation Exp value: from 'h0 to 'h2 Act value: 0x%0x", this.addr[39:38]), UVM_NONE)   
        legal = 0;
    end 

    <% if (!DVMV8_4) { %>
    if (this.addr[41] !== 'h0 ) begin  //Range applicable only for non TLBI DVM transactions operation
        `uvm_info(label_string, $sformatf("ERROR: addr[41] field mismatches. Range not Supported in actual DVM version. Act value: 0x%0x", this.addr[41]), UVM_NONE)   
        legal = 0;
    end 
    if (this.addr[42] !== 'h0 ) begin  //Num[4] applicable only for non TLBI DVM transactions operation
        `uvm_info(label_string, $sformatf("ERROR: addr[42] field mismatches. Num[4] not Supported in actual DVM version. Act value: 0x%0x", this.addr[42]), UVM_NONE)   
        legal = 0;
    end 
    <% } else {%>

    if ((this.addr[13:11] !== 'h0 ) && this.addr[41] == 'h1 ) begin  //Range applicable only for non TLBI DVM transactions operation
        `uvm_info(label_string, $sformatf("ERROR: addr[41] field mismatches. Range Exp value: 'h0 Act value: 0x%0x", this.addr[41]), UVM_NONE)   
        legal = 0;
    end 
    if ((this.addr[13:11] !== 'h0 || this.addr[41] == 'h0) && this.addr[42] !== 'h0 ) begin  //Num[4] applicable only for non TLBI DVM transactions operation or Range is deaserted
        `uvm_info(label_string, $sformatf("ERROR: addr[42] field mismatches. Num[4] Exp value: 'h0 Act value: 0x%0x", this.addr[42]), UVM_NONE)   
        legal = 0;
    end 
    <% } %>

    return legal;

endfunction: is_legal_dvm_request

function void chi_req_seq_item::do_print(uvm_printer printer);
    
    super.do_print(printer);
    if(printer.knobs.sprint == 0) begin
        $display(convert2string());
    end else begin
        printer.m_string = convert2string();
    end
endfunction: do_print

function packed_flit_t chi_req_seq_item::pack_flit();
    packed_flit_t bitstream;

    `uvm_info("CHI_SEQ_ITEM", $psprintf("packing the txn: %0s", this.convert2string()), UVM_HIGH)

<%   if(obj.AiuInfo[obj.Id].fnNativeInterface != "CHI-A"){ %>
    if(is_stash_opcode()) begin
        if (WREQRSVDC > 0) 
          bitstream.push_back(
            {rsvdc, tracetag, expcompack, excl, lpid, snpattr, memattr, pcrdtype, order,
             allowretry, likelyshared, ns, addr, size, opcode, 2'b0, stashlpidvalid,
             stashlpid, stashnidvalid, stashnid, txnid, srcid, tgtid, qos});
        else
          bitstream.push_back(
            {tracetag, expcompack, excl, lpid, snpattr, memattr, pcrdtype, order,
             allowretry, likelyshared, ns, addr, size, opcode, 2'b0, stashlpidvalid,
             stashlpid, stashnidvalid, stashnid, txnid, srcid, tgtid, qos});

    end else if(is_atomic_opcode()) begin
        if (WREQRSVDC > 0) 
          bitstream.push_back(
            {rsvdc, tracetag, expcompack, snoopme, lpid, snpattr, memattr, pcrdtype, order, allowretry,
             likelyshared, ns, addr, size, opcode, returntxnid, endian, returnnid, txnid,
             srcid, tgtid, qos});
        else
          bitstream.push_back(
            {tracetag, expcompack, snoopme, lpid, snpattr, memattr, pcrdtype, order, allowretry,
             likelyshared, ns, addr, size, opcode, returntxnid, endian, returnnid, txnid,
             srcid, tgtid, qos});

    end else begin
        if (WREQRSVDC > 0) 
          bitstream.push_back(
            {rsvdc, tracetag, expcompack, excl, lpid, snpattr, memattr, pcrdtype, order, allowretry,
             likelyshared, ns, addr, size, opcode, returntxnid, 1'b0, returnnid, txnid,
             srcid, tgtid, qos});
        else
          bitstream.push_back(
            {tracetag, expcompack, excl, lpid, snpattr, memattr, pcrdtype, order, allowretry,
             likelyshared, ns, addr, size, opcode, returntxnid, 1'b0, returnnid, txnid,
             srcid, tgtid, qos});
    end
<%  } else { %>
    if(is_stash_opcode()) begin
        if (WREQRSVDC > 0) 
          bitstream.push_back(
            {rsvdc, expcompack, excl, lpid, snpattr, memattr, pcrdtype, order,
             allowretry, likelyshared, ns, addr, size, opcode,
             txnid, srcid, tgtid, qos});
        else
          bitstream.push_back(
            {expcompack, excl, lpid, snpattr, memattr, pcrdtype, order,
             allowretry, likelyshared, ns, addr, size, opcode,
             txnid, srcid, tgtid, qos});

    end else if(is_atomic_opcode()) begin
        if (WREQRSVDC > 0) 
          bitstream.push_back(
            {rsvdc, expcompack, snoopme, lpid, snpattr, memattr, pcrdtype, order,
             allowretry, likelyshared, ns, addr, size, opcode,
             txnid, srcid, tgtid, qos});
        else
          bitstream.push_back(
            {expcompack, snoopme, lpid, snpattr, memattr, pcrdtype, order,
             allowretry, likelyshared, ns, addr, size, opcode,
             txnid, srcid, tgtid, qos});

    end else begin
        if (WREQRSVDC > 0) 
          bitstream.push_back(
            {rsvdc, expcompack, excl, lpid, snpattr, memattr, pcrdtype, order,
             allowretry, likelyshared, ns, addr, size, opcode, txnid,
             srcid, tgtid, qos});
        else
          bitstream.push_back(
            {expcompack, excl, lpid, snpattr, memattr, pcrdtype, order,
             allowretry, likelyshared, ns, addr, size, opcode, txnid,
             srcid, tgtid, qos});
    end
<%  } %>


    `uvm_info("CHI_SEQ_ITEM", $psprintf("Packed: %0p", bitstream), UVM_HIGH)
    unpack_flit(bitstream);

    return bitstream;
endfunction: pack_flit

function void chi_req_seq_item::unpack_flit(const ref packed_flit_t flit);

    super.unpack_flit(flit);
    //TODO: add unpacking of ATOMIC/STASH specific fields
    this.lpid           = flit[0][`CHI_REQ_LPID_MSB:`CHI_REQ_LPID_LSB];
    $cast(this.opcode  ,  flit[0][`CHI_REQ_OPCODE_MSB:`CHI_REQ_OPCODE_LSB]);
<%   if(obj.AiuInfo[obj.Id].fnNativeInterface != "CHI-A"){ %>
    if (this.is_stash_opcode()) begin
        this.stashnid       = flit[0][`CHI_REQ_RTRN_NID_MSB:`CHI_REQ_RTRN_NID_LSB];
        this.stashnidvalid  = flit[0][`CHI_REQ_ENDIAN_MSB:`CHI_REQ_ENDIAN_LSB];
        this.stashlpid      = flit[0][`CHI_REQ_STSH_LPID_MSB:`CHI_REQ_STSH_LPID_LSB];
        this.stashlpid      = flit[0][`CHI_REQ_RTRN_TXNID_LSB+WLPID-1:`CHI_REQ_RTRN_TXNID_LSB];
        <%if(obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-E"){%>
            this.stashlpidvalid = flit[0][`CHI_REQ_RTRN_TXNID_LSB+5];
        <%}else{%>
            this.stashlpidvalid = flit[0][`CHI_REQ_RTRN_TXNID_LSB+WLPID];
        <%}%>
    end else if (this.is_atomic_opcode()) begin
        this.returnnid      = flit[0][`CHI_REQ_RTRN_NID_MSB:`CHI_REQ_RTRN_NID_LSB];
        this.returntxnid    = flit[0][`CHI_REQ_RTRN_TXNID_MSB:`CHI_REQ_RTRN_TXNID_LSB];
        this.endian         = flit[0][`CHI_REQ_ENDIAN_MSB:`CHI_REQ_ENDIAN_LSB];
    end else begin
        this.returnnid      = flit[0][`CHI_REQ_RTRN_NID_MSB:`CHI_REQ_RTRN_NID_LSB];
        this.returntxnid    = flit[0][`CHI_REQ_RTRN_TXNID_MSB:`CHI_REQ_RTRN_TXNID_LSB];
    end

    //end
    this.tracetag = flit[0][`CHI_REQ_TRACETAG_MSB:`CHI_REQ_TRACETAG_LSB];
<%  } else { %>
<%  } %>

    if (WREQRSVDC > 0)
<% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
    begin
       `ifndef VCS
        this.rsvdc          = flit[0][`CHI_REQ_RSVDC_MSB:`CHI_REQ_RSVDC_LSB];
       `else
       <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) { %>
        this.rsvdc          = flit[0][`CHI_REQ_RSVDC_MSB:`CHI_REQ_RSVDC_LSB];
       <%  } %>
       `endif // `ifndef VCS ... `else ... 
   end
<%  } else {%>
        this.rsvdc          = flit[0][`CHI_REQ_RSVDC_MSB:`CHI_REQ_RSVDC_LSB];
<%  } %>
    this.addr           = flit[0][`CHI_REQ_ADDR_MSB:`CHI_REQ_ADDR_LSB];
    this.ns             = flit[0][`CHI_REQ_NS_MSB:`CHI_REQ_NS_LSB];
    this.size           = flit[0][`CHI_REQ_SIZE_MSB:`CHI_REQ_SIZE_LSB];
    this.allowretry     = flit[0][`CHI_REQ_ALLOWRETRY_MSB:`CHI_REQ_ALLOWRETRY_LSB];
    this.pcrdtype       = flit[0][`CHI_REQ_PCRDTYPE_MSB:`CHI_REQ_PCRDTYPE_LSB];
    this.excl           = flit[0][`CHI_REQ_EXCL_MSB:`CHI_REQ_EXCL_LSB];
    this.snoopme        = this.excl; //For atomics, this indicates ICN to snoop the requestor.
    this.expcompack     = flit[0][`CHI_REQ_EXPCOMPACK_MSB:`CHI_REQ_EXPCOMPACK_LSB];
    this.memattr        = flit[0][`CHI_REQ_MEMATTR_MSB:`CHI_REQ_MEMATTR_LSB];
    this.snpattr        = flit[0][`CHI_REQ_SNPATTR_MSB:`CHI_REQ_SNPATTR_LSB];
    this.likelyshared   = flit[0][`CHI_REQ_LIKELYSHARED_MSB:`CHI_REQ_LIKELYSHARED_LSB];
    this.order          = flit[0][`CHI_REQ_ORDER_MSB:`CHI_REQ_ORDER_LSB];
    `uvm_info("CHI_SEQ_ITEM", $psprintf("after unpacking the txn flit(%0p): %0s", flit, this.convert2string()), UVM_HIGH)
endfunction: unpack_flit

//******************************************************************************
// Class   : chi_dat_seq_item
// Purpose : CHI request item to generate write/read data txn.
//          
//
//******************************************************************************

class chi_dat_seq_item extends chi_base_seq_item;

    rand chi_dat_homenid_t      homenid     ;
    rand chi_dat_dbid_t         dbid        ;
    rand chi_dat_opcode_enum_t  opcode      ;
    rand chi_dat_resperr_t      resperr   ;
    rand chi_dat_resp_t         resp        ;
    rand chi_dat_fwdstate_t     fwdstate    ;
    rand chi_dat_datapull_t     datapull    ;
    rand chi_dat_datasource_t   datasource  ;
    rand chi_dat_ccid_t         ccid        ;
    rand chi_dat_dataid_t       dataid    ;
    rand chi_dat_be_t           be        ;
    rand chi_dat_data_t         data      ;
    rand chi_dat_poison_t       poison      ;
    rand chi_dat_rsvdc_t        rsvdc       ;
    rand bit                    last        ;
    


    `uvm_object_param_utils_begin ( chi_dat_seq_item   )
        `uvm_field_int          ( homenid ,   UVM_DEFAULT )
        `uvm_field_int          ( dbid    ,   UVM_DEFAULT )
        `uvm_field_enum         ( chi_dat_opcode_enum_t, opcode, UVM_DEFAULT )
        `uvm_field_int          ( resperr ,   UVM_DEFAULT )
        `uvm_field_int          ( resp    ,   UVM_DEFAULT )
        `uvm_field_int          ( fwdstate,   UVM_DEFAULT )
        `uvm_field_int          ( datapull,   UVM_DEFAULT )
        `uvm_field_int          ( datasource, UVM_DEFAULT )
        `uvm_field_int          ( ccid    ,   UVM_DEFAULT )
        `uvm_field_int          ( dataid  ,   UVM_DEFAULT )
        `uvm_field_int          ( be      ,   UVM_DEFAULT )
        `uvm_field_int          ( data    ,   UVM_DEFAULT )
        `uvm_field_int          (poison   ,   UVM_DEFAULT )
        `uvm_field_int          (rsvdc    ,   UVM_DEFAULT )
        `uvm_field_int          (last     ,   UVM_DEFAULT )
    `uvm_object_utils_end

    //Constructor
    //For data sequence items lock the sequence-sequencer-driver
    //arbitation until all data-beats for given transaction are delivered
    function new(string name = "chi_dat_seq_item");
      super.new(name);

      en_lock = 1;
    endfunction
    extern virtual function packed_flit_t pack_flit();
    extern virtual function string convert2string();
    extern virtual function void unpack_flit(const ref packed_flit_t flit);
    extern function bit is_legal_dvm_request(chi_req_seq_item  dvmop_req);

endclass

function string chi_dat_seq_item::convert2string();
    string s;

    s = super.convert2string();

    $sformat(s, "%s opcode:%s, data: 0x%0h, be: 0x%0h, ccid:0x%0h, dataid:0x%0h, resp:0x%0h, resperr:0x%0h, dbid:0x%0h, homenid:0x%0h, poison:%x",
                 s, opcode, data, be, ccid, dataid, resp, resperr, dbid, homenid, poison);
    if (WDATRSVDC > 0) begin
        $sformat(s, "%s rsvdc:0x%0h", s, rsvdc);
    end
    return(s);
endfunction:convert2string


function packed_flit_t chi_dat_seq_item::pack_flit();
    packed_flit_t bitstream;

    //FIXME: is_stash_opcode not defined
    //if(is_stash_opcode()) begin
    //    bitstream.push_back(
    //        {poison, datacheck, data, be, rsvdc, tracetag, dataid, ccid, dbid,
    //        datapull, resp, resperr, opcode, homenid, txnid, srcid, tgtid, qos});

    //end else begin
<%   if(obj.AiuInfo[obj.Id].fnNativeInterface != "CHI-A"){ %>
    <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.enPoison) { %>
    if (WDATRSVDC > 0) begin
        bitstream.push_back(
            {poison, data, be, rsvdc, tracetag, dataid, ccid, dbid,
            datapull, resp, resperr, opcode, homenid, txnid, srcid, tgtid, qos});
    end else begin
        bitstream.push_back(
            {poison, data, be, tracetag, dataid, ccid, dbid,
            datapull, resp, resperr, opcode, homenid, txnid, srcid, tgtid, qos});
    end
    //FIXME: For SNP RSP, use datasource in place of fwdstate and datapull
    <%  } else { %>
    if (WDATRSVDC > 0) begin
        bitstream.push_back(
            {data, be, rsvdc, tracetag, dataid, ccid, dbid,
            datapull, resp, resperr, opcode, homenid, txnid, srcid, tgtid, qos});
    end else begin
        bitstream.push_back(
            {data, be, tracetag, dataid, ccid, dbid,
            datapull, resp, resperr, opcode, homenid, txnid, srcid, tgtid, qos});
    end
    <% } %>
<%  } else { %>
    if (WDATRSVDC > 0) begin
        bitstream.push_back(
            {data, be, rsvdc, dataid, ccid, dbid,
            resp, resperr, opcode, txnid, srcid, tgtid, qos});
    end else begin
        bitstream.push_back(
            {data, be, dataid, ccid, dbid,
            resp, resperr, opcode, txnid, srcid, tgtid, qos});
    end
<%  } %>

    return(bitstream);

endfunction : pack_flit

function void chi_dat_seq_item::unpack_flit(const ref packed_flit_t flit);
    super.unpack_flit(flit);
    $cast(this.opcode   , flit[0][`CHI_DAT_OPCODE_MSB:`CHI_DAT_OPCODE_LSB]);
    this.resperr        = flit[0][`CHI_DAT_RESPERR_MSB:`CHI_DAT_RESPERR_LSB];
    this.resp           = flit[0][`CHI_DAT_RESP_MSB:`CHI_DAT_RESP_LSB];
    this.dbid           = flit[0][`CHI_DAT_DBID_MSB:`CHI_DAT_DBID_LSB];
    this.ccid           = flit[0][`CHI_DAT_CCID_MSB:`CHI_DAT_CCID_LSB];
    this.dataid         = flit[0][`CHI_DAT_DATAID_MSB:`CHI_DAT_DATAID_LSB];
    if (WDATRSVDC > 0) 
<% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
       `ifndef VCS
        this.rsvdc          = flit[0][`CHI_DAT_RSVDC_MSB:`CHI_DAT_RSVDC_LSB];
       `else
        <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.DATA_RSVDC) { %>
        this.rsvdc          = flit[0][`CHI_DAT_RSVDC_MSB:`CHI_DAT_RSVDC_LSB];
        <% } %>
       `endif // `ifndef VCS ... `else ... 
<% } else {%>
        this.rsvdc          = flit[0][`CHI_DAT_RSVDC_MSB:`CHI_DAT_RSVDC_LSB];
<% } %>
    this.be             = flit[0][`CHI_DAT_BE_MSB:`CHI_DAT_BE_LSB];
    this.data           = flit[0][`CHI_DAT_DATA_MSB:`CHI_DAT_DATA_LSB];
    this.be             = flit[0][`CHI_DAT_BE_MSB:`CHI_DAT_BE_LSB];
<%   if(obj.AiuInfo[obj.Id].fnNativeInterface != "CHI-A"){ %>
    this.homenid        = flit[0][`CHI_DAT_HOMENID_MSB:`CHI_DAT_HOMENID_LSB];
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
    this.fwdstate       = flit[0][`CHI_DAT_DATASOURCE_MSB:`CHI_DAT_DATASOURCE_LSB];
    this.datapull       = flit[0][`CHI_DAT_DATASOURCE_MSB:`CHI_DAT_DATASOURCE_LSB];
    this.datasource     = flit[0][`CHI_DAT_DATASOURCE_MSB:`CHI_DAT_DATASOURCE_LSB];
<%  } else { %>
    this.fwdstate       = flit[0][`CHI_DAT_FWDSTATE_MSB:`CHI_DAT_FWDSTATE_LSB];
    this.datapull       = flit[0][`CHI_DAT_FWDSTATE_MSB:`CHI_DAT_FWDSTATE_LSB];
    this.datasource     = flit[0][`CHI_DAT_FWDSTATE_MSB:`CHI_DAT_FWDSTATE_LSB];
<%  } %>
    this.tracetag       = flit[0][`CHI_DAT_TRACETAG_MSB:`CHI_DAT_TRACETAG_LSB];
    <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.enPoison) { %>
    this.poison         = flit[0][`CHI_DAT_POISON_MSB:`CHI_DAT_POISON_LSB];
    <% } %>
<%  } else { %>
<%  } %>
endfunction : unpack_flit


function bit chi_dat_seq_item::is_legal_dvm_request(chi_req_seq_item  dvmop_req);
    bit legal = 1;
    string label_string = $sformatf("CHI_AIU<%=obj.Id%> DVMOp request field mismatch"); 

    //#Check.CHI.v3.6.DVM_req_p2

    if(dvmop_req.addr[13:11] == 3'b100 && this.data != 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: DVM Sync operation => DATA field mismatches. Act value: 0x%0x", this.data), UVM_NONE)   
        legal = 0;
        return legal;
    end

    // ARM CHI Architecture Spec Table 8-2 Data message field value restrictions for DVMOp

    /*
    if (this.qos !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: qos field mismatches. Exp value: 'h0 Act value: 0x%0x", this.qos), UVM_NONE)   
        `uvm_info(label_string, $sformatf("QoS value zero is defined by Ncore 3.X Achitecture spec"), UVM_NONE)   
        legal = 0;
    end

    if (this.tgtid !== 'h<%=obj.DveInfo[0].FUnitId%>) begin
        `uvm_info(label_string, $sformatf("ERROR: TargetId field mismatches. Exp value: 'h<%=obj.DveInfo[0].FUnitId%> Act value: 0x%0x", this.tgtid), UVM_NONE)   
        legal = 0;
    end 
    */

    if (this.homenid !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: homenid field mismatches. Exp value: 'h0 Act value: 0x%0x", this.homenid), UVM_NONE)   
        legal = 0;
    end 
    if ( ! this.opcode inside {NONCOPYBACKWRDATA} ) begin
        `uvm_info(label_string, $sformatf("ERROR: opcode field mismatches. Exp value: NONCOPYBACKWRDATA 'h%0h Act value: 0x%0x", NONCOPYBACKWRDATA, this.opcode), UVM_NONE)   
        legal = 0;
    end 

    <% if (!DVMV8_4) { %>
        if ( ! (this.resperr inside {'b0})) begin
            `uvm_info(label_string, $sformatf("ERROR: resperr field mismatches. Exp value: 'h0     Act value: 0x%0x", this.resperr), UVM_NONE)   
            legal = 0;
        end 
    <% } else { %>
        if ( ! (this.resperr inside {'b0, 'b10})) begin
            `uvm_info(label_string, $sformatf("ERROR: resperr field mismatches. Exp value: 'h0 or 'h2    Act value: 0x%0x", this.resperr), UVM_NONE)   
            legal = 0;
        end 
    <% } %>
    if (this.resp !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: resp field mismatches. Exp value: 'h0 Act value: 0x%0x", this.resp), UVM_NONE)   
        legal = 0;
    end 
    if (this.fwdstate !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: fwdstate field mismatches. Exp value: 'h0 Act value: 0x%0x", this.fwdstate), UVM_NONE)   
        legal = 0;
    end 
    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
    /*
    if (this.cbusy !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: cbusy field mismatches. Exp value: 'h0 for CHI rev. E Act value: 0x%0x", this.cbusy), UVM_NONE)   
        legal = 0;
    end 
    if (this.tagop !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: tagop field mismatches. Exp value: 'h0 for CHI rev. E Act value: 0x%0x", this.tagop), UVM_NONE)   
        legal = 0;
    end 
    if (this.tag !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: tag field mismatches. Exp value: 'h0 for CHI rev. E Act value: 0x%0x", this.tag), UVM_NONE)   
        legal = 0;
    end 
    if (this.tu !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: TU field mismatches. Exp value: 'h0 for CHI rev. E Act value: 0x%0x", this.tu), UVM_NONE)   
        legal = 0;
    end
    */
    <% } %>
    if (this.ccid !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: ccid field mismatches. Exp value: 'h0 Act value: 0x%0x", this.ccid), UVM_NONE)   
        legal = 0;
    end 
    if (this.dataid !== 'h0 ) begin
        `uvm_info(label_string, $sformatf("ERROR: dataid field mismatches. Exp value: 'h0 Act value: 0x%0x", this.dataid), UVM_NONE)   
        legal = 0;
    end 
    if (this.be[7:0] !== 'hff) begin
        `uvm_info(label_string, $sformatf("ERROR: BE[7:0] field mismatches. Exp value: 'hff Act value: 0x%0x", this.be[7:0]), UVM_NONE)   
        legal = 0;
    end 

    <% if (!DVMV8_4) { %>
    if ( this.data[3:0] !== 'h0) begin
        `uvm_info(label_string, $sformatf("ERROR: Num[3:0] field mismatches. Num not Supported in actual DVM version. Act value: 0x%0x", this.data[3:0]), UVM_NONE)  
        legal = 0;
    end
    if (this.data[5:4] !== 'h0) begin
        `uvm_info(label_string, $sformatf("ERROR: Scale field mismatches (not Supported in actual DVM version). Act value: 0x%0x", this.data[5:4]), UVM_NONE)   
        legal = 0;
    end
    if (this.data[7:6] !== 'h0) begin
        `uvm_info(label_string, $sformatf("ERROR: TTL field mismatches (not Supported in actual DVM version). Act value: 0x%0x", this.data[7:6]), UVM_NONE)   
        legal = 0;
    end
    if (this.data[9:8] !== 'h0) begin
        `uvm_info(label_string, $sformatf("ERROR: TG field mismatches (not Supported in actual DVM version). Act value: 0x%0x", this.data[9:8]), UVM_NONE)   
        legal = 0;
    end
    <% } else {%>
    if ( this.data[3:0] !== 'h0 && !(dvmop_req.addr[41] == 'h1 && dvmop_req.addr[13:11] == 'h0) ) begin
        `uvm_info(label_string, $sformatf("ERROR: Num[3:0] field mismatches. Exp value: 'h0 Act value: 0x%0x", this.data[3:0]), UVM_NONE)  
        legal = 0;
    end
    if (this.data[5:4] !== 'h0 && !(dvmop_req.addr[41] == 'h1 && dvmop_req.addr[13:11] == 'h0) ) begin
        `uvm_info(label_string, $sformatf("ERROR: Scale field mismatches. Exp value: 'h0 Act value: 0x%0x", this.data[5:4]), UVM_NONE)   
        legal = 0;
    end
    if (this.data[7:6] !== 'h0 && ( dvmop_req.addr[13:11] !== 'h0 || (dvmop_req.addr[41] == 'h0 && dvmop_req.addr[4] !== 'h1 ))) begin
        `uvm_info(label_string, $sformatf("ERROR: TTL field mismatches. Exp value: 'h0 Act value: 0x%0x", this.data[7:6]), UVM_NONE)   
        legal = 0;
    end
    if (this.data[9:8] !== 'h0 && ( dvmop_req.addr[13:11] !== 'h0 || (dvmop_req.addr[41] == 'h0 && dvmop_req.addr[4] !== 'h1 ))) begin
        `uvm_info(label_string, $sformatf("ERROR: TG field mismatches. Exp value: 'h0 Act value: 0x%0x", this.data[9:8]), UVM_NONE)   
        legal = 0;
    end
    <% } %>


    if ((this.data[55:51] !== 'h0 )) begin  //Range applicable only for non TLBI DVM transactions operation
        `uvm_info(label_string, $sformatf("ERROR: data[55:51] field mismatches. Reserved Exp value: 'h0 Act value: 0x%0x", this.data[55:51]), UVM_NONE)   
        legal = 0;
    end 

    return legal;

endfunction: is_legal_dvm_request


//******************************************************************************
// Class   : chi_rsp_seq_item
// Purpose : CHI request item to generate write/read data txn.
//          
//
//******************************************************************************


class chi_rsp_seq_item extends chi_base_seq_item;

    rand chi_rsp_dbid_t         dbid     ;
    rand chi_rsp_pcrdtype_t     pcrdtype ;
    rand chi_rsp_opcode_enum_t  opcode   ;
    rand chi_rsp_resperr_t      resperr  ;
    rand chi_rsp_resp_t         resp     ;
    rand chi_dat_fwdstate_t    fwdstate ;
    rand chi_dat_datapull_t    datapull ;

    `uvm_object_param_utils_begin ( chi_rsp_seq_item   )
        `uvm_field_enum         ( chi_rsp_opcode_enum_t, opcode, UVM_DEFAULT )
        `uvm_field_int          ( resperr ,  UVM_DEFAULT )
        `uvm_field_int          ( resp    ,  UVM_DEFAULT )
        `uvm_field_int          ( dbid    ,  UVM_DEFAULT )
        `uvm_field_int          ( pcrdtype,  UVM_DEFAULT )
        `uvm_field_int          ( fwdstate,   UVM_DEFAULT )
        `uvm_field_int          ( datapull,   UVM_DEFAULT )
    `uvm_object_utils_end

    //Constructor
    function new(string name = "chi_rsp_seq_item");
        super.new(name);
    endfunction
    extern virtual function packed_flit_t pack_flit();
    extern virtual function void unpack_flit(const ref packed_flit_t flit);
    extern virtual function string convert2string();
endclass

function packed_flit_t chi_rsp_seq_item::pack_flit();
    packed_flit_t bitstream;

<%   if(obj.AiuInfo[obj.Id].fnNativeInterface != "CHI-A"){ %>
    //FIXME: is_stash_opcode not defined for chi_rsp_item
    //if(is_stash_opcode()) begin
    //    bitstream.push_back(
    //        {tracetag, pcrdtype, dbid, datapull, resp, resperr, opcode, txnid, srcid, tgtid, qos});

    //end else begin
        bitstream.push_back(
            {tracetag, pcrdtype, dbid, datapull, resp, resperr, opcode, txnid, srcid, tgtid, qos});
    //end
<%  } else { %>
    //FIXME: is_stash_opcode not defined for chi_rsp_item
    //if(is_stash_opcode()) begin
    //    bitstream.push_back(
    //        {tracetag, pcrdtype, dbid, datapull, resp, resperr, opcode, txnid, srcid, tgtid, qos});

    //end else begin
        bitstream.push_back(
            {pcrdtype, dbid, resp, resperr, opcode, txnid, srcid, tgtid, qos});
    //end
<%  } %>
    `uvm_info("CHI_SEQ_ITEM", $psprintf("packing response: txnid: %0h, after pack: %0p", txnid, bitstream), UVM_HIGH)

    return(bitstream);

endfunction : pack_flit


function void chi_rsp_seq_item::unpack_flit(const ref packed_flit_t flit);
    super.unpack_flit(flit);
    $cast(this.opcode   , flit[0][`CHI_RSP_OPCODE_MSB:`CHI_RSP_OPCODE_LSB]);
    this.resperr        = flit[0][`CHI_RSP_RESPERR_MSB:`CHI_RSP_RESPERR_LSB];
    this.resp           = flit[0][`CHI_RSP_RESP_MSB:`CHI_RSP_RESP_LSB];
    this.dbid           = flit[0][`CHI_RSP_DBID_MSB:`CHI_RSP_DBID_LSB];
    this.pcrdtype       = flit[0][`CHI_RSP_PCRDTYPE_MSB:`CHI_RSP_PCRDTYPE_LSB];
<%   if(obj.AiuInfo[obj.Id].fnNativeInterface != "CHI-A"){ %>
    this.fwdstate       = flit[0][`CHI_RSP_FWDSTATE_MSB:`CHI_RSP_FWDSTATE_LSB];
    this.datapull       = flit[0][`CHI_RSP_FWDSTATE_MSB:`CHI_RSP_FWDSTATE_LSB];
    this.tracetag       = flit[0][`CHI_RSP_TRACETAG_MSB:`CHI_RSP_TRACETAG_LSB];
<%  } else { %>
<%  } %>
    `uvm_info("CHI_SEQ_ITEM", $psprintf("unpacking response: txnid: %0h, before unpack: %0p", txnid, flit[0]), UVM_HIGH)
endfunction : unpack_flit

function string chi_rsp_seq_item::convert2string();
    string s;

    s = super.convert2string();

    $sformat(s, "%s opcode:%0s, resp:0x%0h, resperr:0x%0h, datapull:0x%0h, fwdstate:0x%0h, dbid:0x%0h, pcrdtype:0x%0h",
                 s, opcode.name, resp, resperr, datapull, fwdstate, dbid, pcrdtype);
    return(s);
endfunction:convert2string

//******************************************************************************
// Class   : chi_snp_seq_item
// Purpose : CHI request item to generate snoop address txn.
//          
//
//******************************************************************************

class chi_snp_seq_item extends chi_base_seq_item;
    rand chi_snp_fwdnid_t         fwdnid ;
    rand chi_snp_fwdtxnid_t       fwdtxnid;
    rand chi_lpid_t               stashlpid;
    rand chi_lpidvalid_t          stashlpidvalid;
    rand chi_snp_vmidext_t        vmidext;
    rand chi_snp_opcode_enum_t    opcode ;
    rand chi_snpaddr_t            addr ;
    rand chi_ns_t                 ns     ;
    rand chi_snp_donotgotosd_t    donotgotosd;
    rand chi_snp_donotdatapull_t  donotdatapull;
    rand chi_snp_rettosrc_t       rettosrc;

    `uvm_object_param_utils_begin ( chi_snp_seq_item   )
        `uvm_field_int          ( fwdnid,         UVM_DEFAULT )
        `uvm_field_int          ( fwdtxnid,       UVM_DEFAULT )
        `uvm_field_int          ( stashlpid,      UVM_DEFAULT )
        `uvm_field_int          ( stashlpidvalid, UVM_DEFAULT )
        `uvm_field_int          ( vmidext,        UVM_DEFAULT )
        `uvm_field_int          ( donotgotosd,    UVM_DEFAULT )
        `uvm_field_enum         ( chi_snp_opcode_enum_t, opcode, UVM_DEFAULT )
        `uvm_field_int          ( addr ,          UVM_DEFAULT )
        `uvm_field_int          ( ns     ,        UVM_DEFAULT )
        `uvm_field_int          ( rettosrc,       UVM_DEFAULT )
    `uvm_object_utils_end

    //Constructor
    function new(string name = "chi_snp_seq_item");
        super.new(name);
    endfunction
    extern virtual function void unpack_flit(const ref packed_flit_t flit);
    extern virtual function string convert2string();

endclass

function void chi_snp_seq_item::unpack_flit(const ref packed_flit_t flit);
    this.qos            = flit[0][`CHI_SNP_QOS_MSB:`CHI_SNP_QOS_LSB];
    this.srcid          = flit[0][`CHI_SNP_SRCID_MSB:`CHI_SNP_SRCID_LSB];
    this.txnid          = flit[0][`CHI_SNP_TXNID_MSB:`CHI_SNP_TXNID_LSB];
    $cast(this.opcode   , flit[0][`CHI_SNP_OPCODE_MSB:`CHI_SNP_OPCODE_LSB]);
    this.addr           = flit[0][`CHI_SNP_ADDR_MSB:`CHI_SNP_ADDR_LSB];
    this.ns             = flit[0][`CHI_SNP_NS_MSB:`CHI_SNP_NS_LSB];
<%   if(obj.AiuInfo[obj.Id].fnNativeInterface != "CHI-A"){ %>
    this.fwdnid         = flit[0][`CHI_SNP_FWDNID_MSB:`CHI_SNP_FWDNID_LSB];
    this.fwdtxnid       = flit[0][`CHI_SNP_FWDTXNID_MSB:`CHI_SNP_FWDTXNID_LSB];
    this.vmidext        = this.fwdtxnid;
    <%if(obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-E"){ %>
        this.stashlpid      = this.fwdtxnid[WLPID-4:0]; // For CHIE, LPID field is 8 bit out of which only 5 bits are lpid
        this.stashlpidvalid = this.fwdtxnid[WLPID-3];
    <%}else{%>
        this.stashlpid      = this.fwdtxnid[WLPID-1:0];
        this.stashlpidvalid = this.fwdtxnid[WLPID];
    <%}%>
    this.donotgotosd    = flit[0][`CHI_SNP_DNGSD_MSB:`CHI_SNP_DNGSD_LSB];
    this.donotdatapull  = flit[0][`CHI_SNP_DNGSD_MSB:`CHI_SNP_DNGSD_LSB];
    this.rettosrc       = flit[0][`CHI_SNP_RETSRC_MSB:`CHI_SNP_RETSRC_LSB];
    this.tracetag       = flit[0][`CHI_SNP_TRACETAG_MSB:`CHI_SNP_TRACETAG_LSB];
<%  } else { %>
<%  } %>
endfunction : unpack_flit

function string chi_snp_seq_item::convert2string();
    string s;

    s = super.convert2string();

    $sformat(s, "%s addr:0x%0h, opcode:%0s, donotgotosd: 0x%0h vmidext: 0x%0h stashlpidvalid: 0x%0h stashlpid: 0x%0h fwdtxnid: 0x%0h fwdnid: 0x%0h rettosrc: 0x%0h",
                 s, addr, opcode.name, donotgotosd, vmidext, stashlpidvalid, stashlpid, fwdtxnid, fwdnid, rettosrc);
    return(s);
endfunction:convert2string


class chi_lnk_seq_item extends chi_base_seq_item;

  chi_txactv_st_t m_txactv_st;

  `uvm_object_param_utils_begin(chi_lnk_seq_item)
  `uvm_object_utils_end

  function new(string name = "chi_lnk_seq_item");
    super.new(name);
  endfunction: new

endclass: chi_lnk_seq_item

