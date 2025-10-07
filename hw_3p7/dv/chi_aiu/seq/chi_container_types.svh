
//Typedefs
//
//chi_cache_data_t
//
class chi_cache_data_t;

  int m_max_beats;
  int m_ccid;
  int m_dataid[$];
  bit [7:0] m_data[64];
  bit  m_be[64];
  local int m_nbytes_per_flit;

  function new(int nbytes);
    m_nbytes_per_flit = nbytes;
  endfunction: new

  function int get_bytes_pflit();
    return m_nbytes_per_flit;
  endfunction: get_bytes_pflit

  function int num_flits();
    return m_max_beats;
  endfunction: num_flits

  function int get_ccid();
    return m_ccid;
  endfunction: get_ccid

  function int get_tx_dataid(int itr);
  <% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
    `ifndef VCS
    `ASSERT(itr < m_max_beats);
    `else // `ifndef VCS
    `ASSERT(itr < m_max_beats);
    `endif // `ifndef VCS
  <% } else {%>
    `ASSERT(itr < m_max_beats);
  <% } %>
    return m_dataid[itr];
  endfunction: get_tx_dataid

  function bit [511:0] get_tx_data(int itr);
    bit [511:0] data;
    int id;
    int data_offset;
     
  <% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
    `ifndef VCS
    `ASSERT(itr < m_max_beats);
    `else // `ifndef VCS
    `ASSERT(itr < m_max_beats);
    `endif // `ifndef VCS
  <% } else {%>
    `ASSERT(itr < m_max_beats);
  <% } %>
    id = m_dataid[itr];
    if(m_nbytes_per_flit==32) begin
       id = id/2;
    end
    for (int i = id * m_nbytes_per_flit;
         i < id * m_nbytes_per_flit + m_nbytes_per_flit; i=i+1) begin

      data = data >> 8;
      data[511:504] = m_data[i];
    end
    data = data >> (512 - m_nbytes_per_flit * 8);
    return data; 
  endfunction: get_tx_data

  function bit [63:0] get_tx_be(int itr);
    bit [63:0] be;
    int id;

  <% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
    `ifndef VCS
    `ASSERT(itr < m_max_beats);
    `else // `ifndef VCS
    `ASSERT(itr < m_max_beats);
    `endif // `ifndef VCS
  <% } else {%>
    `ASSERT(itr < m_max_beats);
  <% } %>
    id = m_dataid[itr];
    if(m_nbytes_per_flit==32) begin
       id = id/2;
    end    
    for (int i = id * m_nbytes_per_flit;
         i < id * m_nbytes_per_flit + m_nbytes_per_flit; i=i+1) begin

      be = be >> 1;
      be[63] = m_be[i];
    end
    be = be >> (64 - m_nbytes_per_flit);
    return be; 
  endfunction: get_tx_be

  //Invoked when Data is tranferred from chi container to RTL 
  function void set_txdat_info(
    int st_word,
    int num_words,
    bit [7:0] data[64],
    bit be[64], int txnid=-1);

    int count;
    `ASSERT(num_words > 0 && num_words <= 64 / m_nbytes_per_flit, $psprintf("num_words:%0d", num_words));

<%if(obj.testBench == "fsys"){%>
    count   = (m_nbytes_per_flit == 16) ? st_word : (m_nbytes_per_flit == 32) ? {st_word[1],1'b0} : 2'b00;
<%} else {%>
    count   = (m_nbytes_per_flit == 16) ? st_word : (m_nbytes_per_flit == 32) ? st_word : 2'b00;
<%}%>
   // if (m_nbytes_per_flit == 16)
   //     `ASSERT(count < 64 / m_nbytes_per_flit, $psprintf("st_word:0x%0h", st_word));
   // else if (m_nbytes_per_flit == 32)
   //     `ASSERT(count < 3, $psprintf("st_word:0x%0h", st_word));
   // else
   //     `ASSERT(count < 2, $psprintf("st_word:0x%0h", st_word));
    m_max_beats = num_words;
    m_ccid      = st_word;
    m_data      = data;
    m_be        = be;
    for (int i = 0; i < num_words; i=i+1) begin
      if (txnid == -1) begin
      m_dataid.push_back(count);
      end
      else begin
      m_dataid.push_back(txnid);
      end
//$display("txnid: %x, count: %x, num_words: %x, m_nbytes_per_flit %x", txnid, count, num_words, m_nbytes_per_flit);
      if (m_nbytes_per_flit == 16) begin
        if(num_words==2 && (count==1 || count==3))
		count--;
	else
        	++count;
        if (count == 64 / m_nbytes_per_flit)
          count = 0;
      end else begin
        if(count[1]) 
	  count[1]--; 
        else
          count[1]++;
     //   if (count > 64/m_nbytes_per_flit)
     //     count = 0;
      end
    end
  endfunction: set_txdat_info

  // Invoked when Data is to be corrupted
  function void inj_err_txdat(bit be_en=1);
    for (int i=0; i<64; i++)
      if (m_be[i] == be_en) begin
        `uvm_info("chi_cache_data_t",$sformatf("Injected error in %0d BE:%0d Data:%0h ,Corrupted Data:%0h",i,m_be[i],m_data[i],~m_data[i]),UVM_NONE)
        m_data[i] = ~m_data[i];
      end
  endfunction: inj_err_txdat

  //Invoked when Data is received from RTL and is forwarded to 
  //chi container
  function void set_rxdat_info(
    int ccid,
    int dataid,
    bit [511:0] data,
    bit [63:0]be);
    int data_offset;
     
    m_max_beats = 1;
    m_ccid = ccid;
    m_dataid.push_back(dataid);
    if(m_nbytes_per_flit==32) begin
       dataid = dataid/2;
    end
    for (int i = 0; i < m_nbytes_per_flit; i=i+1) begin
       m_data[(dataid * m_nbytes_per_flit) + i] = data[i*8+:8];
       m_be[(dataid * m_nbytes_per_flit) + i]   = be[i];
    end
  endfunction: set_rxdat_info
  
  function int get_rx_dataid();
    `ASSERT(m_dataid.size() == 1);
    return (m_nbytes_per_flit==32 ? m_dataid[0]/2 : m_dataid[0]) ;
  endfunction: get_rx_dataid

  function byte_64_t get_rx_data();
    return m_data;
  endfunction: get_rx_data

  function bit_64_t get_rx_be();
    return m_be;
  endfunction: get_rx_be

endclass: chi_cache_data_t

//Typedefs
//
//chi_rsp_dat_chnl_resp_t
//
class chi_rsp_dat_chnl_resp_t extends uvm_object;
  local bit [3:0] m_raw_opcode;
  local bit [2:0] m_raw_resp;
  local bit [1:0] m_raw_resp_err;
  local bit [2:0] m_raw_fwd_state;
  local chi_bfm_chnl_t m_chnl;

  `uvm_object_param_utils(chi_rsp_dat_chnl_resp_t);

  function new(chi_bfm_chnl_t chnl=RX_DAT_CHNL);
    m_chnl = chnl;
  endfunction:  new

  ////////////////////////////////////////////////////////////////////////
  //Below Methods are for chi_aiu_vseq. These must not be used by BFM
  ////////////////////////////////////////////////////////////////////////
  function void set_opcode_resp_fwd(
    bit [3:0] opcode,
    bit [2:0] resp,
    bit [1:0] rsp_err,
    bit [2:0] fwd_state);

    m_raw_opcode    = opcode;
    m_raw_resp      = resp;
    m_raw_resp_err  = rsp_err;
    m_raw_fwd_state = fwd_state;
  endfunction: set_opcode_resp_fwd

  function bit [3:0] get_opcode();
    return m_raw_opcode;
  endfunction: get_opcode

  function bit [2:0] get_resp();
    return m_raw_resp;
  endfunction: get_resp

  function bit [1:0] get_resp_err();
    return m_raw_resp_err;
  endfunction: get_resp_err

  function bit [2:0] get_fwd_state();
    return m_raw_fwd_state;
  endfunction: get_fwd_state

  ////////////////////////////////////////////////////////////////////////
  //Below methods are for BFM. Using these methods provides self checking
  //capabilities
  ////////////////////////////////////////////////////////////////////////
  function chi_bfm_dat_opcode_t get_compdata_opcode();
    chi_bfm_dat_opcode_t opcode;

    `ASSERT(m_chnl == RX_DAT_CHNL);
    if (!$cast(opcode, m_raw_opcode))
      `ASSERT(0);
    `ASSERT(opcode == BFM_COMPDATA, 
      $psprintf("Unexpected opcode: %s", opcode.name()));
 
    return opcode;
  endfunction: get_compdata_opcode

  function chi_bfm_compdata_rsp_t get_compdata_rsp();
    chi_bfm_compdata_rsp_t resp;

     `ASSERT(m_chnl == RX_DAT_CHNL);
     if (!$cast(resp, m_raw_resp))
       `ASSERT(0);

     return resp;
  endfunction: get_compdata_rsp

  function void set_comprsp_opcode_resp(
    chi_bfm_rsp_opcode_t opcode,
    chi_bfm_comp_rsp_t   resp,
    chi_bfm_rsp_err_t    resp_err);

    `ASSERT(m_chnl == TX_RSP_CHNL);
    if (!$cast(m_raw_opcode, opcode))
      `ASSERT(0);
    `ASSERT(opcode == BFM_COMPACK || opcode == BFM_RESPLCRDRETURN);
    m_raw_resp = 0;
    if (!$cast(m_raw_resp_err, resp_err))
      `ASSERT(0);
  endfunction: set_comprsp_opcode_resp

  function chi_bfm_rsp_opcode_t get_comprsp_opcode();
    chi_bfm_rsp_opcode_t opcode;

    `ASSERT(m_chnl == TX_RSP_CHNL || m_chnl == RX_RSP_CHNL);
    if (!$cast(opcode, m_raw_opcode))
      `ASSERT(0);
    `ASSERT(!(opcode == BFM_SNPRESP || opcode == BFM_SNPRESPFWD),
            "invoke get_snprsp() method");
    return opcode;
  endfunction: get_comprsp_opcode

  function chi_bfm_comp_rsp_t get_comprsp_resp();
    chi_bfm_comp_rsp_t resp;

    if (!$cast(resp, m_raw_resp))
      `ASSERT(0);
    return resp;
  endfunction: get_comprsp_resp

  function void set_wrdat_opcode_resp(
    chi_bfm_dat_opcode_t   opcode,
    chi_bfm_copyback_rsp_t resp,
    chi_bfm_rsp_err_t      resp_err);

    `ASSERT(m_chnl == TX_DAT_CHNL);
    if (!$cast(m_raw_opcode, opcode))
      `ASSERT(0);
    if (!$cast(m_raw_resp, resp))
      `ASSERT(0);
    if (!$cast(m_raw_resp_err, resp_err))
      `ASSERT(0);
  endfunction: set_wrdat_opcode_resp

  function void set_snprsp_opcode_resp(
    chi_bfm_rsp_opcode_t opcode,
    chi_bfm_snprsp_rsp_t resp,
    chi_bfm_rsp_err_t    resp_err);

    `ASSERT(m_chnl == TX_RSP_CHNL);
    `ASSERT(opcode == BFM_SNPRESP);
    if (!($cast(m_raw_opcode, opcode)))
      `ASSERT(0);
    if (!($cast(m_raw_resp, resp)))
      `ASSERT(0);
    if (!($cast(m_raw_resp_err, resp_err)))
      `ASSERT(0);
  endfunction: set_snprsp_opcode_resp

  function void set_snprsp_fwd_opcode_resp(
    chi_bfm_rsp_opcode_t opcode,
    chi_bfm_snprsp_fwd_t resp,
    chi_bfm_rsp_err_t    resp_err);

    bit [5:0] result;
    bit [2:0] tmp_resp;
    bit [2:0] fwd_state;

    `ASSERT(m_chnl == TX_RSP_CHNL);
    `ASSERT(opcode == BFM_SNPRESPFWD);
    if (!($cast(m_raw_opcode, opcode)))
      `ASSERT(0);
    if (!($cast(result, resp)))
      `ASSERT(0);

    m_raw_opcode = result[2:0];
    result       = result >> 3;
    m_raw_resp   = result[2:0];
    if (!($cast(m_raw_resp_err, resp_err)))
      `ASSERT(0);
  endfunction: set_snprsp_fwd_opcode_resp

  function void set_snprsp_data_opcode_resp(
    chi_bfm_snprsp_data_t resp,
    chi_bfm_rsp_err_t     resp_err);

    bit [5:0] result;
    `ASSERT(m_chnl == TX_DAT_CHNL);
    if (!($cast(result, resp)))
      `ASSERT(0);

    m_raw_resp   = result[2:0];
    result       = result >> 3;
    m_raw_opcode = result[2:0];
    if (!($cast(m_raw_resp_err, resp_err)))
      `ASSERT(0);
  endfunction: set_snprsp_data_opcode_resp

  function void set_snprsp_data_fwd_opcode_resp(
    chi_bfm_snprsp_data_fwd_t resp,
    chi_bfm_rsp_err_t         resp_err);

    bit [8:0] result;
    `ASSERT(m_chnl == TX_DAT_CHNL);
    if (!($cast(result, resp)))
      `ASSERT(0);
    m_raw_fwd_state = result[2:0];
    result          = result >> 3;
    m_raw_resp      = result[2:0];
    result          = result >> 3;
    m_raw_opcode    = result[2:0];
    if (!($cast(m_raw_resp_err, resp_err)))
      `ASSERT(0);
    `ASSERT(m_raw_opcode == BFM_SNPRESPDATAFWDED);
  endfunction: set_snprsp_data_fwd_opcode_resp

  function chi_bfm_dat_opcode_t get_dat_opcode_type();
    chi_bfm_dat_opcode_t opcode;
    if (!($cast(opcode, m_raw_opcode)))
      `ASSERT(0);
    return opcode;
  endfunction: get_dat_opcode_type

  function chi_bfm_rsp_opcode_t get_rsp_opcode_type();
   chi_bfm_rsp_opcode_t opcode;
    if (!($cast(opcode, m_raw_opcode)))
      `ASSERT(0);
    return opcode;
  endfunction: get_rsp_opcode_type

  function chi_bfm_rsp_err_t get_resp_err_type();
    chi_bfm_rsp_err_t resp;

    if (!$cast(resp, m_raw_resp_err))
	`uvm_error(get_type_name(), $sformatf("%m, resp error type mismatched"));

    return resp;
  endfunction: get_resp_err_type

endclass: chi_rsp_dat_chnl_resp_t

typedef struct {
  int                     tgtid;
  int                     srcid;
  int                     txnid;
  int                     dbid;
  chi_rsp_dat_chnl_resp_t m_resp;
  int                     resperr;
  int                     resp;
  int                     fwdstate;
  int                     datapull;
} chi_bfm_rsp_t;

typedef struct {
  int                     tgtid;
  int                     srcid;
  int                     txnid;
  int                     dbid;
  chi_rsp_dat_chnl_resp_t m_resp;
  int                     datapull;
  int                     datasource;
  chi_cache_data_t        m_info;
} chi_bfm_dat_t;

typedef struct {
  int                     tgtid;
  int                     txnid;
  int                     fwdtxnid;
  int                     stashlpid;
  int                     stashlpid_vld;
  int                     vmid_ext;
  int                     srcid;
  chi_bfm_snp_opcode_t    opcode;
  addr_width_t            addr;
  bit                     ns;
  int                     donotgoto_sd;
  int                     donot_datapull;
  int                     ret2src;
} chi_bfm_snp_t;

typedef struct {
  chi_bfm_snprsp_type_t   snp_type;
  chi_bfm_snp_opcode_t    opcode;
  addr_width_t            addr;
  bit                     ns;
  chi_bfm_rsp_t           stash_rsp;
  chi_bfm_dat_t           stash_dat;
} chi_stashing_snp_t;

//Forward declaration
typedef class chi_container;

