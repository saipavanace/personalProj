
class chi_rx_dat_chnl_cb#(int ID = 0) extends uvm_object;

  `uvm_object_param_utils(chi_rx_dat_chnl_cb#(ID))

  typedef struct  {
    chi_bfm_cache_state_t  m_end_state;
    chi_bfm_rsp_err_t      m_rsp_err;
    chi_bfm_compdata_rsp_t m_rsp;
    chi_data_be_t          m_info;
    bit vld;
  } rx_dat_info_t;

  //Properties
  chi_aiu_unit_args     m_args;
  //indexed over txnid
  rx_dat_info_t         m_rxdat_info[];

  rand chi_bfm_cache_state_t rand_state;
  rand int m_data_bytes, m_data_st_bytes;
  rand bit m_all_bytes_vld, m_wrdata_cancel;

  //Methods
  extern function new(string s = "chi_rx_dat_chnl_cb");
  extern function void set_chi_unit_args(const ref chi_aiu_unit_args args);
  extern virtual function void rcvd_chi_txn(
    ref chi_bfm_dat_t txn,
    const ref chi_container#(ID) m_cntr);
  extern virtual function chi_bfm_cache_state_t get_end_state(int txnid);
  extern virtual function chi_bfm_rsp_err_t     get_err_resp(int txnid);
  extern virtual function chi_data_be_t         get_data_be(int txnid);

  //Constraints
  constraint c_data_st_bytes {
    if (rand_state == CHI_UD || rand_state == CHI_UDP)
      m_data_st_bytes inside {[0:63]};
    else 
      m_data_st_bytes == 0;
  }

  constraint c_data_bytes {
    if (rand_state == CHI_UD)
      m_data_bytes == 64;
    else if (rand_state == CHI_UDP)
      m_data_bytes inside {[1:64]};
    else
      m_data_bytes == 0;
  }

  constraint c_all_bytes_vld {
    m_all_bytes_vld dist {
        1 := m_args.k_all_bytes_vld_pct.get_value(),
      0 := 100 - m_args.k_all_bytes_vld_pct.get_value()};
  }

  //Internal Methods
  extern function chi_bfm_cache_state_t pick_end_state(
    ref chi_bfm_dat_t txn,
    const ref chi_container#(ID) m_cntr);
  extern function chi_data_be_t fillup_dirty_data(bit all_bytes_vld);
  extern function chi_bfm_cache_state_t pick_uc2posb_end_st();
  extern function chi_bfm_cache_state_t pick_sc2posb_end_st();
  extern function chi_bfm_cache_state_t pick_ud2posb_end_st();

endclass: chi_rx_dat_chnl_cb

function chi_rx_dat_chnl_cb::new(string s = "chi_rx_dat_chnl_cb");
  super.new(s);

  m_rxdat_info = new[256];
endfunction: new

function void chi_rx_dat_chnl_cb::set_chi_unit_args(
    const ref chi_aiu_unit_args args);
  m_args = args;
endfunction: set_chi_unit_args 

function void chi_rx_dat_chnl_cb::rcvd_chi_txn(
    ref chi_bfm_dat_t txn,
    const ref chi_container#(ID) m_cntr);
  byte_64_t tmp_data;
  bit_64_t  tmp_be;

  `ASSERT(m_cntr.m_chi_txns[txn.txnid].m_txn_valid);
  m_cntr.m_chi_txns[txn.txnid].set_rxdat_flit_rcvd(
      txn.m_info.get_bytes_pflit());
  tmp_data = txn.m_info.get_rx_data();
  tmp_be = txn.m_info.get_rx_be();


  //Checks and initialization
  if (m_cntr.m_chi_txns[txn.txnid].rxdat_is_first_flit()) begin
    `ASSERT(txn.m_info.get_ccid() ==
            m_cntr.m_chi_txns[txn.txnid].m_req_addr[5:4]);
    `ASSERT(!m_rxdat_info[txn.txnid].vld);
    m_rxdat_info[txn.txnid].vld    = 1;
    m_rxdat_info[txn.txnid].m_rsp  = txn.m_resp.get_compdata_rsp();
  end else begin
    `ASSERT(m_rxdat_info[txn.txnid].vld);
    `ASSERT(txn.m_info.get_ccid() ==
            m_cntr.m_chi_txns[txn.txnid].m_req_addr[5:4]);
    `ASSERT(m_rxdat_info[txn.txnid].m_rsp == txn.m_resp.get_compdata_rsp());
  end
  $cast(m_rxdat_info[txn.txnid].m_rsp_err, txn.m_resp.get_resp_err());
  //Read data
  for (int i = txn.m_info.get_rx_dataid() * txn.m_info.get_bytes_pflit(); 
       i < txn.m_info.get_rx_dataid() * txn.m_info.get_bytes_pflit() + 
           txn.m_info.get_bytes_pflit();
       ++i) begin

    m_rxdat_info[txn.txnid].m_info.m_data[i] = tmp_data[i];
    m_rxdat_info[txn.txnid].m_info.m_be[i]   = tmp_be[i];

  end

  if (m_cntr.m_chi_txns[txn.txnid].all_rxdat_flits_rcvd())
    m_rxdat_info[txn.txnid].m_end_state = pick_end_state(txn, m_cntr);

  if (m_rxdat_info[txn.txnid].m_end_state == CHI_UD ||
      m_rxdat_info[txn.txnid].m_end_state == CHI_UDP) begin
    rand_state = m_rxdat_info[txn.txnid].m_end_state;
    `ASSERT(this.randomize());
    for (int i = 0; i < 64; ++i) begin
      m_rxdat_info[txn.txnid].m_info.m_data[i] = 0;
      m_rxdat_info[txn.txnid].m_info.m_be[i] = 0;
    end
    m_all_bytes_vld = m_rxdat_info[txn.txnid].m_end_state == CHI_UDP ? m_all_bytes_vld :
                                                                       1; // In UD state, all the cacheline should be valid
    m_rxdat_info[txn.txnid].m_info = fillup_dirty_data(m_all_bytes_vld);
  end
endfunction: rcvd_chi_txn

function chi_bfm_cache_state_t chi_rx_dat_chnl_cb::get_end_state(int txnid);
  return m_rxdat_info[txnid].m_end_state;
endfunction: get_end_state

function chi_bfm_rsp_err_t chi_rx_dat_chnl_cb::get_err_resp(int txnid);
  return m_rxdat_info[txnid].m_rsp_err;
endfunction: get_err_resp

function chi_data_be_t chi_rx_dat_chnl_cb::get_data_be(int txnid);
  chi_data_be_t info;

  `ASSERT(m_rxdat_info[txnid].vld);
    info.m_data = m_rxdat_info[txnid].m_info.m_data;
    m_rxdat_info[txnid].m_info.m_data ='{default: '0};
    info.m_be = m_rxdat_info[txnid].m_info.m_be;
    m_rxdat_info[txnid].m_info.m_be  = '{default: '0};

  m_rxdat_info[txnid].vld = 0;
  return info;
endfunction: get_data_be

function chi_bfm_cache_state_t chi_rx_dat_chnl_cb::pick_uc2posb_end_st();
  int sum;

  sum = 100 - m_args.m_uc_to_ud_st_ch_pct.get_value() - m_args.m_uc_to_udp_st_ch_pct.get_value() -
  m_args.m_uc_to_sc_st_ch_pct.get_value() - m_args.m_uc_to_ix_st_ch_pct.get_value();
  randcase
    sum:                          return CHI_UC;
    m_args.m_uc_to_ud_st_ch_pct.get_value():  return CHI_UD;
    m_args.m_uc_to_udp_st_ch_pct.get_value(): return CHI_UDP;
    m_args.m_uc_to_sc_st_ch_pct.get_value():  return CHI_SC;
    m_args.m_uc_to_ix_st_ch_pct.get_value():  return CHI_IX;
  endcase
  
  `ASSERT(0);
  return CHI_UC;
endfunction: pick_uc2posb_end_st

function chi_bfm_cache_state_t chi_rx_dat_chnl_cb::pick_sc2posb_end_st();
  randcase
  100 - m_args.m_sc_to_ix_st_ch_pct.get_value(): return CHI_SC;
  m_args.m_sc_to_ix_st_ch_pct.get_value():       return CHI_IX;
  endcase

  `ASSERT(0);
  return CHI_SC;
endfunction: pick_sc2posb_end_st

function chi_bfm_cache_state_t chi_rx_dat_chnl_cb::pick_ud2posb_end_st();
  randcase
  m_args.m_ud_to_sd_st_ch_pct.get_value(): return CHI_SD;
  100 - m_args.m_ud_to_sd_st_ch_pct.get_value(): return CHI_UD;
  
  endcase

  `ASSERT(0);
  return CHI_SD;
endfunction: pick_ud2posb_end_st

function chi_bfm_cache_state_t chi_rx_dat_chnl_cb::pick_end_state(
    ref chi_bfm_dat_t txn,
    const ref chi_container#(ID) m_cntr);
  chi_bfm_cache_state_t end_state;

  end_state = m_cntr.get_end_state(
      txn.txnid, txn.m_resp);
`uvm_info(get_full_name(), $sformatf("rd_end_state %x, addr %x", end_state.name(), m_cntr.m_chi_txns[txn.txnid].m_req_addr ), UVM_LOW)

  //case (txn.m_resp.get_compdata_rsp())
  //  BFM_COMPDATA_IX:    end_state = CHI_IX;
  //  BFM_COMPDATA_UC:    end_state = pick_uc2posb_end_st();
  //  BFM_COMPDATA_SC:    end_state = pick_sc2posb_end_st();
  //  BFM_COMPDATA_UD_PD: end_state = pick_ud2posb_end_st();
  //  BFM_COMPDATA_SD_PD: end_state = CHI_IX;
  //endcase
  return end_state;
endfunction: pick_end_state

function chi_data_be_t chi_rx_dat_chnl_cb::fillup_dirty_data(
    bit all_bytes_vld);
  chi_data_be_t m_info;

  for (int i = 0; i < m_data_bytes; ++i) begin
    if (all_bytes_vld) begin
      m_info.m_data[m_data_st_bytes] = $urandom_range(0, 255);
      m_info.m_be[m_data_st_bytes]   = 1;

    end else begin
      randcase
        70: begin
          m_info.m_data[m_data_st_bytes] = $urandom_range(0, 255);
          m_info.m_be[m_data_st_bytes]   = 1;
        end

        30: begin
          m_info.m_data[m_data_st_bytes] = $urandom_range(0, 255);
          m_info.m_be[m_data_st_bytes]   = 0;
        end 
      endcase
    end

    ++m_data_st_bytes;
    if (m_data_st_bytes > 63)
      m_data_st_bytes = 0;
  end
  return m_info;
endfunction: fillup_dirty_data
