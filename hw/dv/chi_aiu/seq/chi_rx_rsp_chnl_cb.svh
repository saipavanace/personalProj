
class chi_rx_rsp_chnl_cb#(int ID = 0) extends uvm_object;

  `uvm_object_param_utils(chi_rx_rsp_chnl_cb#(ID))

  //Properties
  chi_aiu_unit_args     m_args;
  chi_bfm_cache_state_t m_end_state;
  chi_bfm_rsp_err_t     m_rsp_err;
  bit m_is_wrdata_cancel_vld;

  rand int m_data_bytes, m_data_st_bytes;
  rand bit m_all_bytes_vld, m_wrdata_cancel;
  bit m_atomic_compare;
  string arg_value;
  string k_csr_seq = "";
  //Command line processor UVM utility
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();

  //Methods
  extern function new(string s = "chi_rx_rsp_chnl_cb");
  extern function void set_chi_unit_args(const ref chi_aiu_unit_args args);
  extern virtual function void rcvd_chi_txn(
    ref chi_bfm_rsp_t txn,
    const ref chi_container#(ID) m_cntr);
  extern virtual function chi_bfm_cache_state_t get_end_state();
  extern virtual function chi_bfm_rsp_err_t     get_err_resp();
  extern virtual function chi_data_be_t         get_data_be();
  extern virtual function bit                   get_wrdata_cancel();

  //Constraints
  constraint c_data_st_bytes {
    if (m_end_state == CHI_UD || m_end_state == CHI_UDP)
      m_data_st_bytes inside {[0:63]};
    else 
      m_data_st_bytes == 0;
  }

  constraint c_data_bytes {
    if (m_end_state == CHI_UD)
      m_data_bytes == 64;
    else if (m_end_state == CHI_UDP)
      m_data_bytes inside {[1:64]};
    else
      m_data_bytes == 0;
  }

  constraint c_all_bytes_vld {
    m_all_bytes_vld dist {
        1 := m_args.k_all_bytes_vld_pct.get_value(),
        0 := 100 - m_args.k_all_bytes_vld_pct.get_value()
    };
  }

  constraint c_wrdata_cancel {
    if (m_is_wrdata_cancel_vld) {
      m_wrdata_cancel dist {
          1 := m_args.k_writedatacancel_pct.get_value(),
          0 := 100 - m_args.k_writedatacancel_pct.get_value()
      };
    } else {
      m_wrdata_cancel == 0;
    }
  }

  //Internal methods
  extern function void proc_dt_ls_upd_cmd(
    ref chi_bfm_rsp_t txn,
    const ref chi_container#(ID) m_cntr);
  extern function void proc_dt_ls_cmo_cmd(
    ref chi_bfm_rsp_t txn,
    const ref chi_container#(ID) m_cntr);
  extern function void proc_write_cmd(
    ref chi_bfm_rsp_t txn,
    const ref chi_container#(ID) m_cntr);
  extern function void proc_atomic_cmd(
    ref chi_bfm_rsp_t txn,
    const ref chi_container#(ID) m_cntr);
  extern function void proc_dvm_cmd(
    ref chi_bfm_rsp_t txn,
    const ref chi_container#(ID) m_cntr);

  extern function chi_bfm_cache_state_t pick_clnunq_state(
    chi_bfm_cache_state_t end_state);
  extern function chi_bfm_cache_state_t pick_mkunq_state(
    chi_bfm_cache_state_t end_state);
  extern function chi_bfm_cache_state_t pick_wrcln_state(
    chi_bfm_cache_state_t end_state);

  extern function int pick_swap_st_byte(int size);
endclass: chi_rx_rsp_chnl_cb

function chi_rx_rsp_chnl_cb::new(string s = "chi_rx_rsp_chnl_cb");
  super.new(s);
endfunction: new

function void chi_rx_rsp_chnl_cb::set_chi_unit_args(const ref chi_aiu_unit_args args);
  m_args = args;
   if (clp.get_arg_value("+k_csr_seq=", arg_value)) begin
      k_csr_seq = arg_value;
      `uvm_info(get_name(), $sformatf("k_csr_seq = %s",k_csr_seq),UVM_MEDIUM)
   end
endfunction: set_chi_unit_args 

//Randomize m_end_state and m_rsp_err
function void chi_rx_rsp_chnl_cb::rcvd_chi_txn(
  ref chi_bfm_rsp_t txn,
  const ref chi_container#(ID) m_cntr);

  case (m_cntr.m_chi_txns[txn.txnid].get_opcode_type())
    DT_LS_UPD_CMD: proc_dt_ls_upd_cmd(txn, m_cntr);
    DT_LS_CMO_CMD: proc_dt_ls_cmo_cmd(txn, m_cntr);
    DT_LS_STH_CMD: proc_dt_ls_cmo_cmd(txn, m_cntr);
    WR_NONCOH_CMD: proc_write_cmd(txn, m_cntr);
    WR_COHUNQ_CMD: proc_write_cmd(txn, m_cntr);
    WR_CPYBCK_CMD: proc_write_cmd(txn, m_cntr);
    DVM_OPERT_CMD: proc_dvm_cmd(txn,m_cntr);
    ATOMIC_ST_CMD, ATOMIC_LD_CMD, ATOMIC_SW_CMD, ATOMIC_CM_CMD:
        proc_atomic_cmd(txn, m_cntr);
    UNSUP_TXN_CMD: `uvm_info(get_type_name(), "Do nothing for unsupported txn", UVM_LOW)
    default: if (!$test$plusargs("unmapped_add_access")) `ASSERT(0, "Unexpected opcode type received");
  endcase

  //constraint for byte enable
  if(m_cntr.m_chi_txns[txn.txnid].m_req_opcode inside {BFM_WRITEEVICTFULL, BFM_WRITECLEANFULL, BFM_WRITEUNIQUEFULL, BFM_WRITEBACKFULL, BFM_WRITENOSNPFULL, BFM_WRITEUNIQUEFULLSTASH})
		m_all_bytes_vld='1;

//$display("txnid %x resp_err %x", txn.txnid,  txn.m_resp.get_resp_err());
  if ($test$plusargs("unmapped_add_access") || $test$plusargs("user_addr_for_csr") || (k_csr_seq == "access_unmapped_csr_addr") || $test$plusargs("unsupported_txn") || $test$plusargs("strreq_cmstatus_with_error")) begin
      m_rsp_err = BFM_RESP_OK;
     // m_rsp_err = BFM_RESP_DERR;
  end else begin
     if ((txn.m_resp.get_resp_err() == BFM_RESP_EXOK) || (txn.m_resp.get_resp_err() == BFM_RESP_NDERR)) begin
         m_rsp_err = BFM_RESP_OK;
     end else begin
         $cast(m_rsp_err, txn.m_resp.get_resp_err());
     end
  end
endfunction: rcvd_chi_txn

function chi_bfm_cache_state_t chi_rx_rsp_chnl_cb::get_end_state();
  return m_end_state;
endfunction: get_end_state

function chi_bfm_rsp_err_t chi_rx_rsp_chnl_cb::get_err_resp();
  return m_rsp_err;
endfunction: get_err_resp

function bit chi_rx_rsp_chnl_cb::get_wrdata_cancel();
  return m_wrdata_cancel;
endfunction: get_wrdata_cancel

function chi_data_be_t chi_rx_rsp_chnl_cb::get_data_be();
  chi_data_be_t m_info;
  int tmp_val;

  //For ATOMICCOMPARE TXNS we need to save the m_data_st_bytes
  tmp_val = m_data_st_bytes;

  for (int i = 0; i < m_data_bytes; ++i) begin
    if (m_wrdata_cancel) begin
      m_info.m_data[tmp_val] = 0;
      m_info.m_be[tmp_val]   = 0;
    end else if (m_all_bytes_vld) begin
      m_info.m_data[tmp_val] = $urandom_range(0, 255);
      m_info.m_be[tmp_val]   = 1;
    end else begin
      randcase
        70: begin
          m_info.m_data[tmp_val] = $urandom_range(0, 255);
          m_info.m_be[tmp_val]   = 1;
        end

        30: begin
          m_info.m_data[tmp_val] = $urandom_range(0, 255);
          m_info.m_be[tmp_val]   = 0;
        end 
      endcase
    end
    ++tmp_val;
    if (tmp_val > 63)
      tmp_val = 0;
  end

  if (m_atomic_compare) begin
    int mask;
    //Refer to Pg 104 in CHI specification
    mask = 1 << pick_swap_st_byte(m_data_bytes);
    tmp_val = m_data_st_bytes ^ mask;
    for (int i = 0; i < m_data_bytes; ++i) begin
      m_info.m_data[tmp_val] = $urandom_range(0, 255);
      m_info.m_be[tmp_val]   = 1;
      ++tmp_val;
  `ifdef VCS
    if (tmp_val > 63)
      tmp_val = 0;
  `endif
    end
    `ASSERT(tmp_val <= 64);
  end

  m_data_st_bytes  = 0;
  m_data_bytes     = 0;
  m_all_bytes_vld  = 0;
  m_wrdata_cancel  = 0;
  m_atomic_compare = 0;
  return m_info;
endfunction: get_data_be

function void chi_rx_rsp_chnl_cb::proc_dt_ls_upd_cmd(
    ref chi_bfm_rsp_t txn,
    const ref chi_container#(ID) m_cntr);
  
  m_end_state = m_cntr.get_end_state(
      txn.txnid, txn.m_resp);

  if (txn.m_resp.get_comprsp_resp() == BFM_COMP_UC) begin

    if (m_cntr.m_chi_txns[txn.txnid].m_req_opcode == BFM_CLEANUNIQUE) begin
      if (m_end_state == CHI_IX) begin
          m_end_state = CHI_UCE;
      end else begin
          m_end_state = pick_clnunq_state(m_end_state);
      end
    end else
      m_end_state = pick_mkunq_state(m_end_state);

  end else if (txn.m_resp.get_comprsp_resp() == BFM_COMP_IX) begin

    if (m_cntr.m_chi_txns[txn.txnid].m_req_opcode == BFM_EVICT) begin
      m_end_state = CHI_IX;
    end

  end else begin
    `ASSERT(0, $psprintf("Unexpected resp for txnid:0x%0h", txn.txnid));
  end

  m_is_wrdata_cancel_vld = 0;
  `ASSERT(this.randomize());
endfunction: proc_dt_ls_upd_cmd

function void chi_rx_rsp_chnl_cb::proc_dt_ls_cmo_cmd(
    ref chi_bfm_rsp_t txn,
    const ref chi_container#(ID) m_cntr);

  m_end_state = m_cntr.get_end_state(
      txn.txnid, txn.m_resp);
  m_is_wrdata_cancel_vld = 0;
endfunction: proc_dt_ls_cmo_cmd

function void chi_rx_rsp_chnl_cb::proc_write_cmd(
    ref chi_bfm_rsp_t txn,
    const ref chi_container#(ID) m_cntr);

  m_is_wrdata_cancel_vld = m_cntr.is_partial(txn.txnid);
  this.c_data_bytes.constraint_mode(0);
  this.c_data_st_bytes.constraint_mode(0);
  `ASSERT(this.randomize());
  this.c_data_bytes.constraint_mode(1);
  this.c_data_st_bytes.constraint_mode(1);
  //Alter Size and Data-ID depending on request size
  m_data_bytes    = m_cntr.pow2(m_cntr.m_chi_txns[txn.txnid].m_req_size);
  m_data_st_bytes = m_cntr.m_chi_txns[txn.txnid].m_req_addr[5:4] * 16;
  if (m_cntr.m_chi_txns[txn.txnid].m_req_opcode == BFM_WRITECLEANFULL) 
<%if(obj.testBench != "fsys"){ %>
    m_end_state = pick_wrcln_state(m_end_state);
<%}else{%>
   begin
    m_end_state = m_cntr.get_end_state(txn.txnid, txn.m_resp);
    if(m_end_state inside {CHI_UC, CHI_UD}) m_end_state = CHI_UC;
    else if(m_end_state inside {CHI_SC, CHI_SD}) m_end_state = CHI_SC;
    else m_end_state = CHI_IX;
  end
<%}%>
  else
    m_end_state = CHI_IX;
endfunction: proc_write_cmd

function void chi_rx_rsp_chnl_cb::proc_dvm_cmd(
    ref chi_bfm_rsp_t txn,
    const ref chi_container#(ID) m_cntr);
  m_is_wrdata_cancel_vld = 0;
  this.c_data_bytes.constraint_mode(0);
  this.c_data_st_bytes.constraint_mode(0);
  `ASSERT(this.randomize());
  this.c_data_bytes.constraint_mode(1);
  this.c_data_st_bytes.constraint_mode(1);
  m_data_bytes    = m_cntr.pow2(m_cntr.m_chi_txns[txn.txnid].m_req_size);
  m_data_st_bytes = m_cntr.m_chi_txns[txn.txnid].m_req_addr[5:4] * 16;
  m_end_state = CHI_IX;
endfunction: proc_dvm_cmd


function void chi_rx_rsp_chnl_cb::proc_atomic_cmd(
    ref chi_bfm_rsp_t txn,
    const ref chi_container#(ID) m_cntr);

  m_data_bytes    = m_cntr.pow2(m_cntr.m_chi_txns[txn.txnid].m_req_size);
  if (m_cntr.m_chi_txns[txn.txnid].m_opcode_type == ATOMIC_CM_CMD && m_data_bytes<16) begin
    m_data_st_bytes = m_cntr.m_chi_txns[txn.txnid].m_req_addr & 6'h3F; 
    m_data_bytes = m_data_bytes >> 1;
    m_atomic_compare = 1;
  end else begin
    m_data_st_bytes = m_cntr.m_chi_txns[txn.txnid].m_req_addr & 6'h3F; 
  end

<%if(obj.AiuInfo[obj.Id].wData==128){ %>
  if( m_cntr.m_chi_txns[txn.txnid].m_req_addr[4] && m_data_bytes==32)
	m_data_st_bytes = m_data_st_bytes -16;
<%}%>

  m_wrdata_cancel = 0;
  m_all_bytes_vld = 1;
  m_end_state     = CHI_IX;
endfunction: proc_atomic_cmd

//Any state other than IX, SD is possible
function chi_bfm_cache_state_t chi_rx_rsp_chnl_cb::pick_clnunq_state(
    chi_bfm_cache_state_t end_state);
  int sum;

  if (end_state == CHI_SC) begin
    return CHI_UC;
  end else if (end_state == CHI_UC) begin
    return CHI_UC;
  end else if ( end_state == CHI_IX) begin
    return CHI_UCE;
  end else if ( end_state == CHI_SD) begin
    return CHI_UD;
  end else if (end_state == CHI_UD  || 
               end_state == CHI_UDP ||
               end_state == CHI_UCE) begin
    return end_state;
  end
  `ASSERT(0);
  return CHI_IX;
endfunction: pick_clnunq_state

//Any state other than IX, SD, UDP is possible
function chi_bfm_cache_state_t chi_rx_rsp_chnl_cb::pick_mkunq_state(
    chi_bfm_cache_state_t end_state);

  return CHI_UD;

  `ASSERT(0);
  return CHI_IX;
endfunction: pick_mkunq_state

function chi_bfm_cache_state_t chi_rx_rsp_chnl_cb::pick_wrcln_state(
    chi_bfm_cache_state_t end_state);
  randcase
  m_args.m_ud_to_uc_st_ch_pct.get_value(): return CHI_UC;
  100 - m_args.m_ud_to_uc_st_ch_pct.get_value(): return CHI_SC;
  endcase

  `ASSERT(0);
  return CHI_IX;
endfunction: pick_wrcln_state

function int chi_rx_rsp_chnl_cb::pick_swap_st_byte(int size);
  case (size)
    1:  return 0;
    2:  return 1;
    4:  return 2;
    8:  return 3;
    16: return 4;
    default: `ASSERT(0);
  endcase
  return 0;
endfunction: pick_swap_st_byte
