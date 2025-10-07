
//Representation of a CHI transaction that maps to all channels
//communication object between chi_container & chi_vseq (chi virtual sequence)
//CHI uvm seq items are mapped to this transaction. 

//
//Note: Some properties are defined local since there in-built dependency
//on how the values are set. Hence use provided set methods to change these
//properties
//

class chi_bfm_txn extends uvm_object;

  `uvm_object_param_utils(chi_bfm_txn)

  //
  //Status variables for state interpretation
  //
  bit                   m_txn_valid;
  chi_bfm_opcode_type_t m_opcode_type;
  bit                   m_txn_state_blkd;
  bit                   m_txn_order_blkd;
  bit                   m_dbidrsp_rcvd;
  bit                   m_comprsp_rcvd;
  bit                   m_rdrcpt_rcvd;
  local int             m_ndat_flits_rcvd;
  local bit             m_all_flits_rcvd;
  chi_bfm_cache_state_t m_start_state;
  time                  m_req_time;
  time                  m_dbidrsp_time;
  time                  m_comprsp_time;
  time                  m_rdrcpt_time;
  local time            m_compdata_time[$];

  //
  //Request channel attributes specified by chi containter
  //
  int                   m_req_tgtid;
  int                   m_req_srcid;
  int                   m_req_txnid;
  int                   m_req_lpid;
  int                   m_req_returnnid;
  int                   m_req_returntxnid;
  int                   m_req_stashnid;
  bit                   m_req_stashnid_valid;
  int                   m_req_stashlpid;
  bit                   m_req_stashlpid_valid;
  chi_bfm_opcode_t      m_req_opcode;
  addr_width_t          m_req_addr;
  bit                   m_req_ns;
  int                   m_req_size;
  bit                   m_req_allowretry;
  int                   m_req_pcrdtype;
  int                   m_req_expcompack;
  int                   m_req_memattr;
  int                   m_req_snpattr;
  bit                   m_req_snoopme;
  bit                   m_req_likelyshared;
  bit                   m_req_excl;
  chi_bfm_order_t       m_req_order;
  bit                   m_req_endian;
  int 			m_req_qos;
 
  int                   tried_to_state_unblock_counter = 0;

  //
  //For stashing snoops where RD-DATA is expected for this
  //snoop request, this information is required for sucessfull
  //completion of transaction
  chi_bfm_snp_opcode_t  m_sth_opcode;

  //Methods
  extern function new(string s = "chi_bfm_txn");
  extern function void reset();
  extern function bit is_ok2reset();
  extern function string convert2string();
  extern function void set_rxdat_flit_rcvd(int nbytes_per_flit);
  extern function bit  all_rxdat_flits_rcvd();
  extern function bit  rxdat_is_first_flit();

  //set/get methods for opcode type
  extern function void set_opcode_type(chi_bfm_opcode_type_t opcode_type);
  extern function chi_bfm_opcode_type_t get_opcode_type();

  //set/get methods for start cache state
  extern function void set_cache_st(chi_bfm_cache_state_t state);
  extern function chi_bfm_cache_state_t get_cache_st();

  //get cacheline address
  extern function addr_width_t get_cacheline_addr();

  //internal methods
  extern function int pow2(int size);
  extern function int bus_align_const(int nbytes_per_flit);
  extern function int num_beats(int st_byte, int size, int nbytes_per_flit);

endclass: chi_bfm_txn

function chi_bfm_txn::new(string s = "chi_bfm_txn");
  super.new(s);
endfunction: new

function void chi_bfm_txn::reset();
  m_txn_valid             = 1'b0;
  m_opcode_type           = RD_NONCOH_CMD;
  m_txn_state_blkd        = 0;
  m_txn_order_blkd        = 0;
  m_dbidrsp_rcvd          = 0;
  m_comprsp_rcvd          = 0;
  m_rdrcpt_rcvd           = 0;
  m_ndat_flits_rcvd       = 0;
  m_all_flits_rcvd        = 0;
  m_req_time              = 0;
  m_start_state           = CHI_IX;
  m_dbidrsp_time          = 0;
  m_comprsp_time          = 0;
  m_rdrcpt_time           = 0;
  m_req_tgtid             = 0;
  m_req_srcid             = 0;
  m_req_txnid             = 0;
  m_req_lpid              = 0;
  m_req_returnnid         = 0;
  m_req_returntxnid       = 0;
  m_req_stashnid          = 0;
  m_req_stashnid_valid    = 0;
  m_req_stashlpid         = 0;
  m_req_stashlpid_valid   = 0;
  m_req_opcode            = BFM_REQLCRDRETURN;
  m_req_addr              = 0;
  m_req_ns                = 0;
  m_req_size              = 0;
  m_req_allowretry        = 0;
  m_req_pcrdtype          = 0;
  m_req_expcompack        = 0;
  m_req_memattr           = 0;
  m_req_snpattr           = 0;
  m_req_snoopme           = 0;
  m_req_likelyshared      = 0;
  m_req_excl              = 0;
  m_req_order             = NO_ORDER;
  m_req_endian            = 0;
  m_req_qos               = 0;
  m_compdata_time.delete();
  tried_to_state_unblock_counter = 0;
endfunction: reset

function bit chi_bfm_txn::is_ok2reset();
  `ASSERT(m_txn_valid == 1, "TBERROR: Unexpected reset check invoked");
  `ASSERT(!(m_opcode_type == RQ_LCRDRT_CMD));

  if (m_txn_state_blkd || m_txn_order_blkd)
    return 0;

  if (m_opcode_type == RD_NONCOH_CMD ||
      m_opcode_type == RD_RDONCE_CMD ||
      m_opcode_type == RD_LDRSTR_CMD) begin

    if (m_req_order == REQUEST_ORDER || m_req_order == ENDPOINT_ORDER)
      return m_all_flits_rcvd && m_rdrcpt_rcvd;
    else 
      return m_all_flits_rcvd;
  end

  if (m_opcode_type == DT_LS_UPD_CMD ||
      m_opcode_type == DT_LS_CMO_CMD ||
      m_opcode_type == DT_LS_STH_CMD)
    return m_comprsp_rcvd;

  if (m_opcode_type == WR_NONCOH_CMD ||
      m_opcode_type == WR_COHUNQ_CMD ||
      m_opcode_type == WR_STHUNQ_CMD ||
      m_opcode_type == WR_CPYBCK_CMD ||
      m_opcode_type == DVM_OPERT_CMD)
    return m_comprsp_rcvd && m_dbidrsp_rcvd;

  //`ASSERT(!(m_opcode_type == PRE_FETCH_CMD), "Not yet implemented");
  
  if (m_opcode_type == ATOMIC_ST_CMD)
    return m_dbidrsp_rcvd && m_comprsp_rcvd;

  if (m_opcode_type == ATOMIC_LD_CMD || 
      m_opcode_type == ATOMIC_SW_CMD ||
      m_opcode_type == ATOMIC_CM_CMD)
    return m_all_flits_rcvd && m_dbidrsp_rcvd;

  if (m_opcode_type == SNP_STASH_CMD)
    return m_all_flits_rcvd;
  if (m_opcode_type == PRE_FETCH_CMD)
    return 1;

  `ASSERT(!(m_opcode_type == DVM_OPERT_CMD), "Not yet Implemented");

  return 0;
endfunction: is_ok2reset

function string chi_bfm_txn::convert2string();
  string s;
  $timeformat(-9, 2, " ns", 10);

  $sformat(s, "%s ", super.convert2string());
  $sformat(s, "%s txnid:0x%0h req_time:%0t opcode_type:%s opcode:%s",
           s, m_req_txnid, m_req_time, m_opcode_type, m_req_opcode);
  $sformat(s, "%s addr:0x%0h sec:%b size:%0d srcid:0x%0h tgtid:0x%0h order:0x%0h",
           s, m_req_addr, m_req_ns, m_req_size, m_req_tgtid, m_req_srcid, m_req_order);
  $sformat(s, "%s state_blocked:%b order_blocked:%b",
           s, m_txn_state_blkd, m_txn_order_blkd);

  case (m_opcode_type)
    RD_NONCOH_CMD, RD_RDONCE_CMD, RD_LDRSTR_CMD: begin
      if (m_req_order == REQUEST_ORDER || m_req_order == ENDPOINT_ORDER)
        $sformat(s, "%s rdrcpt_rcvd: %0t", s, m_rdrcpt_time);
      for (int i = 0; i < m_ndat_flits_rcvd; ++i) begin
        $sformat(s, "%s comdata_flit_time[%0d]:%0t", s, i, m_compdata_time[i]);
      end
      $sformat(s, "%s num_flits_rcvd:%0d all_flits_rcvd:%0d",
               s, m_ndat_flits_rcvd, m_all_flits_rcvd);
    end

    DT_LS_UPD_CMD, DT_LS_CMO_CMD, DT_LS_STH_CMD: begin
      if (m_req_order == REQUEST_ORDER || m_req_order == ENDPOINT_ORDER)
        $sformat(s, "%s rdrcpt_rcvd: %0t", s, m_rdrcpt_time);
      $sformat(s, "%s comprsp_rcvd:%0t", s, m_comprsp_time);
    end

    WR_NONCOH_CMD, WR_COHUNQ_CMD, WR_STHUNQ_CMD, WR_CPYBCK_CMD: begin
      $sformat(s, "%s dbidrsp_rcvd:%0t comprsp_rcvd:%0t",
               s, m_dbidrsp_time, m_comprsp_time);
   end

    DVM_OPERT_CMD: begin
      $sformat(s, "%s dbidrsp_rcvd:%0t comprsp_rcvd:%0t",
               s, m_dbidrsp_time, m_comprsp_time);
   end

    ATOMIC_ST_CMD:begin
      $sformat(s, "%s dbidrsp_rcvd:%0t comprsp_rcvd:%0t",
               s, m_dbidrsp_time, m_comprsp_time);
    end

    ATOMIC_LD_CMD, ATOMIC_SW_CMD, ATOMIC_CM_CMD: begin
      $sformat(s, "%s dbidrsp_rcvd:%0t num_flits_rcvd:%0d all_flits_rcvd:%0d",
               s, m_dbidrsp_time, m_ndat_flits_rcvd, m_all_flits_rcvd);
    end

    SNP_STASH_CMD: begin
      $sformat(s, "%s stash_snoop: %s stashnid:0x%0h stashlpid:0x%0h", 
               s, m_sth_opcode.name(), m_ndat_flits_rcvd, m_all_flits_rcvd);
      $sformat(s, "%s num_flits_rcvd:%0d all_flits_rcvd:%0d",
               s, m_ndat_flits_rcvd, m_all_flits_rcvd);
    end
    default: begin
      $sformat(s, "%s NOT YET IMPLEMENTED opcode:%s", s, m_opcode_type.name());
    end
  endcase
  return s;
endfunction: convert2string

function void chi_bfm_txn::set_rxdat_flit_rcvd(int nbytes_per_flit);
  int max_flits_exp;
  int st_byte;
  int lt_byte;

  if (m_req_opcode == BFM_ATOMICCOMPARE)
    max_flits_exp = num_beats(m_req_addr & 6'h3F,
        m_req_size - 1, nbytes_per_flit);
  else
    max_flits_exp = num_beats(m_req_addr & 6'h3F,
        m_req_size, nbytes_per_flit);

  //HACK, to fix this above num_beats mwthods must have knowledege that
  //this transaction is BFM_ATOMICCOMPARE
  //if (m_req_opcode == BFM_ATOMICCOMPARE &&
  //    m_req_size   == 5                 &&
  //    nbytes_per_flit == 16)
  //  max_flits_exp = max_flits_exp + 1;

  ++m_ndat_flits_rcvd;
  if (m_ndat_flits_rcvd == max_flits_exp)
    m_all_flits_rcvd = 1;
  `ASSERT(m_ndat_flits_rcvd <= 64 / nbytes_per_flit);
  m_compdata_time.push_back($time());
endfunction: set_rxdat_flit_rcvd

function bit chi_bfm_txn::rxdat_is_first_flit();
  return m_ndat_flits_rcvd - 1 == 0 ? 1 : 0;
endfunction: rxdat_is_first_flit

function bit chi_bfm_txn::all_rxdat_flits_rcvd();
  return m_all_flits_rcvd;
endfunction: all_rxdat_flits_rcvd

function void chi_bfm_txn::set_opcode_type(chi_bfm_opcode_type_t opcode_type);
  m_opcode_type = opcode_type;
endfunction: set_opcode_type

function chi_bfm_opcode_type_t chi_bfm_txn::get_opcode_type();
  return m_opcode_type;
endfunction: get_opcode_type

function void chi_bfm_txn::set_cache_st(chi_bfm_cache_state_t state);
  `ASSERT(state != CHI_IX);
  m_start_state = state;
endfunction: set_cache_st

function chi_bfm_cache_state_t chi_bfm_txn::get_cache_st();
  `ASSERT(m_start_state != CHI_IX, "Invoke set_** prior get_**");
  return m_start_state;
endfunction: get_cache_st

function addr_width_t chi_bfm_txn::get_cacheline_addr();
  addr_width_t addr;

  addr = m_req_addr;
  //setting security bit
  addr[ncoreConfigInfo::ADDR_WIDTH] = m_req_ns;
  return addr;
endfunction: get_cacheline_addr

function int chi_bfm_txn::pow2(int size);
  case (size)
    0: return 1;
    1: return 2;
    2: return 4;
    3: return 8;
    4: return 16;
    5: return 32;
    6: return 64;
    default: `ASSERT(0, $psprintf("Unexepected size:%0d", size));
  endcase
endfunction: pow2

function int chi_bfm_txn::bus_align_const(int nbytes_per_flit);
  int res;
  int width;

  width = 1;
  while (!(width << res == nbytes_per_flit))
    ++res;
  return res;
endfunction: bus_align_const

function int chi_bfm_txn::num_beats(int st_byte,
    int size, int nbytes_per_flit);
  int nbeats;
  int ed_byte;
  int st_ch_algn_byte, ed_ch_algn_byte;
  string s;

  ed_byte = st_byte + pow2(size);
  st_ch_algn_byte = (st_byte >> 
      bus_align_const(nbytes_per_flit)) << bus_align_const(nbytes_per_flit);

  ed_ch_algn_byte = (ed_byte >>
      bus_align_const(nbytes_per_flit)) << bus_align_const(nbytes_per_flit);

  if ((ed_ch_algn_byte-st_ch_algn_byte) < nbytes_per_flit)
    ed_ch_algn_byte = ed_ch_algn_byte + (1 << bus_align_const(nbytes_per_flit));

  if (ed_ch_algn_byte > st_ch_algn_byte) begin
    `ASSERT((ed_ch_algn_byte - st_ch_algn_byte) % nbytes_per_flit == 0);
    nbeats =  (ed_ch_algn_byte - st_ch_algn_byte) / nbytes_per_flit;
  end else begin
    `ASSERT((st_ch_algn_byte - ed_ch_algn_byte) % nbytes_per_flit == 0);
    nbeats = (st_ch_algn_byte - ed_ch_algn_byte) / nbytes_per_flit;
  end
  //FIXME: Fix the above logic to generate correct nbeats rather than below hardcoded ones
  if (nbytes_per_flit == 32) begin
      if (size == 6)
        nbeats = 2;
      else
        nbeats = 1;
  end
  if (nbytes_per_flit == 64) begin
      nbeats = 1;
  end

  $sformat(s, "%s nbeats: %0d st_ch_algn_byte:%0d ed_ch_algn_byte: %0d",
      s, nbeats, st_ch_algn_byte, ed_ch_algn_byte);
  $sformat(s, "%s st_byte:%0d ed_byte:%0d size:%0d nbytes_per_flit:%0d",
      s, st_byte, ed_byte, size, nbytes_per_flit);

  `ASSERT(nbeats > 0 && nbeats <= 64 / nbytes_per_flit, s);
  return nbeats;
endfunction: num_beats

