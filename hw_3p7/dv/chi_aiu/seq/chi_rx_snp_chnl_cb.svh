
class chi_rx_snp_chnl_cb#(int ID = 0) extends uvm_object;

  `uvm_object_param_utils(chi_rx_snp_chnl_cb#(ID))

  //Properties
  chi_bfm_cache_state_t      m_end_state;
  chi_bfm_snprsp_type_t      m_snprsp_type;
  chi_bfm_snprsp_rsp_t       m_snprsp_rsp;
  chi_bfm_snprsp_fwd_t       m_snprsp_fwd_rsp;
  chi_bfm_snprsp_data_t      m_snprsp_data_rsp;
  chi_bfm_snprsp_data_fwd_t  m_snprsp_data_fwd_rsp;
  chi_bfm_rsp_err_t          m_snprsp_err;
  bit [2:0]                  m_datapull;
  //Properties
  chi_aiu_unit_args m_args;
  
  //Array index is SNPDVM txnid, bit0/1=snpreq0/1 observed
  // Send SNPResp when m_snp_dvm_req_observed[txnid] == 2'b11
  bit[1:0]                   m_snp_dvm_req_observed[int]; 

  //
  //Methods
  //
  extern function new(string s = "chi_rx_snp_chnl_cb");
  extern function void set_chi_unit_args(
    const ref chi_aiu_unit_args args);

  extern virtual function void rcvd_chi_txn(
    ref chi_bfm_snp_t txn,
    const ref chi_container#(ID) m_cntr);

  extern virtual function chi_bfm_cache_state_t get_end_state();
  extern virtual function chi_bfm_snprsp_type_t get_snprsp_type();
  extern virtual function bit                   get_snprsp_rdy(int txnid);
  extern virtual function void                  reset_snpreq_observed_flag(int txnid);

  extern virtual function chi_bfm_snprsp_rsp_t      get_snprsp();
  extern virtual function chi_bfm_snprsp_fwd_t      get_snprsp_fwd();
  extern virtual function chi_bfm_snprsp_data_t     get_snprsp_data();
  extern virtual function chi_bfm_snprsp_data_fwd_t get_snprsp_data_fwd();
  extern virtual function chi_bfm_rsp_err_t         get_snprsp_err();
  extern virtual function bit [2:0]                 get_datapull();

  //
  //Internal methods
  //
  extern function addr_width_t get_cacheline_addr(
    const ref chi_bfm_snp_t txn);

  extern function void pick_snponce_info(
    chi_bfm_cache_state_t init_state, bit ret2src, bit donogotoSD);

  extern function void pick_snpcln_info(
    chi_bfm_cache_state_t init_state, bit ret2src, bit donogotoSD);

  extern function void pick_snpunq_info(
    chi_bfm_cache_state_t init_state, bit ret2src);

  extern function void pick_snpcln_shrd_info(
    chi_bfm_cache_state_t init_state, bit ret2src);

  extern function void pick_snpcln_invld_info(
    chi_bfm_cache_state_t init_state, bit ret2src);

  extern function void pick_snpmk_invld_info(
    chi_bfm_cache_state_t init_state, bit ret2src);

  extern function void pick_snpdvm_info(
    chi_bfm_cache_state_t init_state, bit ret2src);

  //Stashing snoops
  extern function void pick_snpunq_stsh_info(
    chi_bfm_cache_state_t init_state,
    int donot_datapull,
    bit addr_matches_outstq);

  extern function void pick_snpmk_invld_stsh_info(
    chi_bfm_cache_state_t init_state,
    int donot_datapull,
    bit addr_matches_outstq);

  extern function void pick_snpstsh_unq_info(
    chi_bfm_cache_state_t init_state,
    int donot_datapull,
    bit addr_matches_outstq);

  extern function void pick_snpstsh_shrd_info(
    chi_bfm_cache_state_t init_state,
    int donot_datapull,
    bit addr_matches_outstq);

  //Forwarding snoops
  extern function void pick_snponce_fwd_info(
    chi_bfm_cache_state_t init_state, bit ret2src);

  extern function void pick_snpcln_fwd_info(
    chi_bfm_cache_state_t init_state, bit ret2src);

  extern function void pick_snpntshrddirty_fwd_info(
    chi_bfm_cache_state_t init_state, bit ret2src);

  extern function void pick_snpunq_fwd_info(
    chi_bfm_cache_state_t init_state, bit ret2src);

endclass: chi_rx_snp_chnl_cb

function chi_rx_snp_chnl_cb::new(string s = "chi_rx_snp_chnl_cb");
  super.new(s);
endfunction: new

function void chi_rx_snp_chnl_cb::set_chi_unit_args(
    const ref chi_aiu_unit_args args);
  m_args = args;
endfunction: set_chi_unit_args 

function void chi_rx_snp_chnl_cb::rcvd_chi_txn(
  ref chi_bfm_snp_t txn,
  const ref chi_container#(ID) m_cntr);

  //Reset previous values
  m_end_state            = CHI_IX;
  m_snprsp_type          = BFM_SNPRSP;
  m_snprsp_err           = BFM_RESP_OK;
  m_datapull             = 0;

  case (txn.opcode)
    BFM_SNPLCRDRETURN: begin
      `uvm_fatal(get_name(), "Unexpected SnpReq received")
    end

    BFM_SNPONCE: begin
      pick_snponce_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.ret2src,
	  txn.donotgoto_sd);
    end

    BFM_SNPCLEAN, BFM_SNPSHARED, BFM_SNPNOTSHAREDDIRTY: begin
      pick_snpcln_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.ret2src,
	  txn.donotgoto_sd);
    end

    BFM_SNPUNIQUE: begin
      pick_snpunq_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.ret2src
          );
    end

    BFM_SNPCLEANSHARED: begin
      pick_snpcln_shrd_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.ret2src);
    end

    BFM_SNPCLEANINVALID: begin
      pick_snpcln_invld_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.ret2src);
    end

    BFM_SNPMAKEINVALID: begin
      pick_snpmk_invld_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.ret2src);
    end

    BFM_SNPDVMOP: begin
      pick_snpdvm_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.ret2src);
      if (txn.addr[0] == 1'b0)
        m_snp_dvm_req_observed[txn.txnid][0] = 1'b1;
      else
        m_snp_dvm_req_observed[txn.txnid][1] = 1'b1;
    end

    BFM_SNPUNIQUESTASH: begin
      pick_snpunq_stsh_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.donot_datapull,
          m_cntr.txn_outsanding4addr(get_cacheline_addr(txn)));
    end

    BFM_SNPMAKEINVALIDSTASH: begin
      `ASSERT(txn.ret2src == 0);
      pick_snpmk_invld_stsh_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.donot_datapull,
          m_cntr.txn_outsanding4addr(get_cacheline_addr(txn)));
    end

    BFM_SNPSTASHUNIQUE: begin
     `ASSERT(txn.ret2src == 0);
     pick_snpstsh_unq_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.donot_datapull,
          m_cntr.txn_outsanding4addr(get_cacheline_addr(txn)));
    end

    BFM_SNPSTASHSHARED: begin
      `ASSERT(txn.ret2src == 0);
      pick_snpstsh_shrd_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.donot_datapull,
          m_cntr.txn_outsanding4addr(get_cacheline_addr(txn)));
    end

    BFM_SNPSHAREDFWD: begin
      pick_snpstsh_shrd_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.donot_datapull,
          m_cntr.txn_outsanding4addr(get_cacheline_addr(txn)));
    end

    BFM_SNPONCEFWD: begin
      pick_snponce_fwd_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.ret2src);
    end

    BFM_SNPCLEANFWD: begin
      pick_snpcln_fwd_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.ret2src);
    end

    BFM_SNPNOTSHAREDDIRTYFWD: begin
      pick_snpntshrddirty_fwd_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.ret2src);
    end

    BFM_SNPUNIQUEFWD: begin
      pick_snpunq_fwd_info(
          m_cntr.get_installed_cache_state(get_cacheline_addr(txn)),
          txn.ret2src);
    end

    default: begin
      `uvm_fatal(get_name(), $psprintf("Unexpected SnpReq received: %s",
                                       txn.opcode.name()));
    end
  endcase
  
  //`uvm_info("RFRF", $sformatf("RFRF SNP  Addr = %0h INIT_ST = %0p  END_STATE= %0p  SNP_RSP_TYPE = %0p  SNP_RSP = %0p  SNP_RSP_DATA = %0p",txn.addr,m_cntr.get_installed_cache_state(get_cacheline_addr(txn)), m_end_state, m_snprsp_type, m_snprsp_rsp, m_snprsp_data_rsp),UVM_NONE)

endfunction: rcvd_chi_txn

function chi_bfm_cache_state_t chi_rx_snp_chnl_cb::get_end_state();
  return m_end_state;
endfunction: get_end_state

function chi_bfm_snprsp_type_t chi_rx_snp_chnl_cb::get_snprsp_type();
  return m_snprsp_type;
endfunction: get_snprsp_type

function bit chi_rx_snp_chnl_cb::get_snprsp_rdy(int txnid);
  return (m_snp_dvm_req_observed[txnid] == 2'b11);
endfunction: get_snprsp_rdy

function void chi_rx_snp_chnl_cb::reset_snpreq_observed_flag(int txnid);
  m_snp_dvm_req_observed[txnid] = 2'b00;
endfunction: reset_snpreq_observed_flag

function chi_bfm_snprsp_rsp_t chi_rx_snp_chnl_cb::get_snprsp();
  `ASSERT(m_snprsp_type == BFM_SNPRSP);
  return m_snprsp_rsp;
endfunction: get_snprsp

function chi_bfm_snprsp_fwd_t chi_rx_snp_chnl_cb::get_snprsp_fwd();
  `ASSERT(m_snprsp_type == BFM_SNPRSP_FWD);
  return m_snprsp_fwd_rsp;
endfunction: get_snprsp_fwd

function chi_bfm_snprsp_data_t chi_rx_snp_chnl_cb::get_snprsp_data();
  `ASSERT(m_snprsp_type == BFM_SNPRSP_DATA);
  return m_snprsp_data_rsp;
endfunction: get_snprsp_data

function chi_bfm_snprsp_data_fwd_t chi_rx_snp_chnl_cb::get_snprsp_data_fwd();
  `ASSERT(m_snprsp_type == BFM_SNPRSP_DATA_FWD);
  return m_snprsp_data_fwd_rsp;
endfunction: get_snprsp_data_fwd

function chi_bfm_rsp_err_t chi_rx_snp_chnl_cb::get_snprsp_err();
  return m_snprsp_err;
endfunction: get_snprsp_err

function bit [2:0] chi_rx_snp_chnl_cb::get_datapull();
  return m_datapull;
endfunction: get_datapull

function addr_width_t chi_rx_snp_chnl_cb::get_cacheline_addr(
    const ref chi_bfm_snp_t txn);
  addr_width_t addr;

  addr = txn.addr << 3;
  addr[addrMgrConst::ADDR_WIDTH] = txn.ns;
  return addr;
endfunction: get_cacheline_addr

function void chi_rx_snp_chnl_cb::pick_snponce_info(
    chi_bfm_cache_state_t init_state,
    bit ret2src,
    bit donogotoSD);
  if (init_state == CHI_IX) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_UC) begin
    int sum;
<% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
`ifndef VCS
    sum = 100 - m_args.m_uc_to_ix_st_ch_pct.get_value() - m_args.m_uc_to_sc_st_ch_pct.get_value();
`else // `ifndef VCS
    if((m_args.m_uc_to_ix_st_ch_pct.get_value() + m_args.m_uc_to_sc_st_ch_pct.get_value())>100)
    sum = $urandom_range(1, 10); //CONC-11276
    else
    sum = 100 - m_args.m_uc_to_ix_st_ch_pct.get_value() - m_args.m_uc_to_sc_st_ch_pct.get_value();
`endif // `ifndef VCS
<% } else {%>
    sum = 100 - m_args.m_uc_to_ix_st_ch_pct.get_value() - m_args.m_uc_to_sc_st_ch_pct.get_value();
<% } %>
    randcase
      sum:                         m_end_state = CHI_UC;
      m_args.m_uc_to_ix_st_ch_pct.get_value(): m_end_state = CHI_IX;
      m_args.m_uc_to_sc_st_ch_pct.get_value(): m_end_state = CHI_SC;
    endcase
    if (m_end_state == CHI_UC) begin
        if ($urandom_range(1, 100) <= m_args.k_snprspdata_in_uc_pct.get_value() && (ret2src == 'h1)) begin // #Check.CHIAIU.v3.SP.RetToSrc
         m_snprsp_type     = BFM_SNPRSP_DATA;
         m_snprsp_data_rsp = BFM_SNPRSP_DATA_UC_OR_UD;
      end else begin
         m_snprsp_type     = BFM_SNPRSP;
         m_snprsp_rsp      = BFM_SNPRSP_UC_OR_UD;
      end
    end else if (m_end_state == CHI_SC) begin
        if ($urandom_range(1, 100) <= m_args.k_snprspdata_in_uc_pct.get_value() && (ret2src == 'h1)) begin
         m_snprsp_type     = BFM_SNPRSP_DATA;
         m_snprsp_data_rsp = BFM_SNPRSP_DATA_SC;
      end else begin
         m_snprsp_type     = BFM_SNPRSP;
         m_snprsp_rsp      = BFM_SNPRSP_SC;
      end
    end else if (m_end_state == CHI_IX) begin
        if ($urandom_range(1, 100) <= m_args.k_snprspdata_in_uc_pct.get_value() && (ret2src == 'h1)) begin
         m_snprsp_type     = BFM_SNPRSP_DATA;
         m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX;
      end else begin
         m_snprsp_type     = BFM_SNPRSP;
         m_snprsp_rsp      = BFM_SNPRSP_IX;
      end
    end else begin
      `ASSERT(0);
    end

  end else if (init_state == CHI_UCE) begin

    randcase
    100 - m_args.m_uc_to_ix_st_ch_pct.get_value(): m_end_state = CHI_UCE;
    m_args.m_uc_to_ix_st_ch_pct.get_value():       m_end_state = CHI_IX;
    endcase
    if (m_end_state == CHI_UCE) begin
      m_snprsp_type = BFM_SNPRSP;
      m_snprsp_rsp  = BFM_SNPRSP_UC_OR_UD;
    end else if (m_end_state == CHI_IX) begin
      m_snprsp_type = BFM_SNPRSP;
      m_snprsp_rsp  = BFM_SNPRSP_IX;
    end else begin
      `ASSERT(0);
    end

  end else if (init_state == CHI_UD) begin
    int sum;
<% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
`ifndef VCS
    sum = 100 -
    m_args.m_ud_to_sd_st_ch_pct.get_value() -
    m_args.m_ud_to_sc_st_ch_pct.get_value() -
    m_args.m_ud_to_ix_st_ch_pct.get_value();
`else // `ifndef VCS
    if((m_args.m_ud_to_sd_st_ch_pct.get_value() + m_args.m_ud_to_sc_st_ch_pct.get_value()+ m_args.m_ud_to_ix_st_ch_pct.get_value())>100)
    sum =$urandom_range(1, 10); //CONC-11276
    else
    sum = 100 -
    m_args.m_ud_to_sd_st_ch_pct.get_value() -
    m_args.m_ud_to_sc_st_ch_pct.get_value() -
    m_args.m_ud_to_ix_st_ch_pct.get_value();
`endif // `ifndef VCS
<% } else {%>
    sum = 100 -
    m_args.m_ud_to_sd_st_ch_pct.get_value() -
    m_args.m_ud_to_sc_st_ch_pct.get_value() -
    m_args.m_ud_to_ix_st_ch_pct.get_value();
<% } %>
    randcase
    m_args.m_ud_to_sd_st_ch_pct.get_value(): if(donogotoSD)m_end_state = CHI_UD; else m_end_state = CHI_SD;
    m_args.m_ud_to_sc_st_ch_pct.get_value(): m_end_state = CHI_SC;
    m_args.m_ud_to_ix_st_ch_pct.get_value(): m_end_state = CHI_IX;
      sum:                         m_end_state = CHI_UD;
    endcase

    m_snprsp_type   = BFM_SNPRSP_DATA;
    case (m_end_state)
      CHI_UD: m_snprsp_data_rsp = BFM_SNPRSP_DATA_UC_OR_UD;
      CHI_SD: m_snprsp_data_rsp = BFM_SNPRSP_DATA_SD;
      CHI_SC: m_snprsp_data_rsp = BFM_SNPRSP_DATA_SC_PD;
      CHI_IX: m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX_PD;
      default: `ASSERT(0);
    endcase

  end else if (init_state == CHI_UDP) begin

    randcase
    m_args.m_udp_to_ix_st_ch_pct.get_value():       m_end_state = CHI_IX;
    100 - m_args.m_udp_to_ix_st_ch_pct.get_value(): m_end_state = CHI_UDP;
    endcase
    m_snprsp_type   = BFM_SNPRSP_DATA;
    if (m_end_state == CHI_UDP)
       m_snprsp_data_rsp = BFM_SNPRSP_DATAPTL_UD;
    else if (m_end_state == CHI_IX)
       m_snprsp_data_rsp = BFM_SNPRSP_DATAPTL_IX_PD;

  end else if (init_state == CHI_SC) begin

    randcase
    m_args.m_sc_to_ix_st_ch_pct.get_value():       m_end_state = CHI_IX;
    100 - m_args.m_sc_to_ix_st_ch_pct.get_value(): m_end_state = CHI_SC;
    endcase
    if (ret2src) begin
      m_snprsp_type = BFM_SNPRSP_DATA;
      if (m_end_state == CHI_SC)
        m_snprsp_data_rsp = BFM_SNPRSP_DATA_SC;
      else if (m_end_state == CHI_IX)
        m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX;
    end else begin
      m_snprsp_type = BFM_SNPRSP;
      if (m_end_state == CHI_SC)
        m_snprsp_rsp = BFM_SNPRSP_SC;
      else if (m_end_state == CHI_IX)
        m_snprsp_rsp = BFM_SNPRSP_IX;
    end

  end else if (init_state == CHI_SD) begin
    int sum;
<% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
`ifndef VCS
    sum = 100 - m_args.m_sd_to_sc_st_ch_pct.get_value() - m_args.m_sd_to_ix_st_ch_pct.get_value();
`else // `ifndef VCS
    if((m_args.m_sd_to_sc_st_ch_pct.get_value() + m_args.m_sd_to_ix_st_ch_pct.get_value())>100)
    sum =$urandom_range(1, 10); //CONC-11276
    else
    sum = 100 - m_args.m_sd_to_sc_st_ch_pct.get_value() - m_args.m_sd_to_ix_st_ch_pct.get_value();
`endif // `ifndef VCS
<% } else {%>
    sum = 100 - m_args.m_sd_to_sc_st_ch_pct.get_value() - m_args.m_sd_to_ix_st_ch_pct.get_value();
<% } %>

 randcase
    m_args.m_sd_to_sc_st_ch_pct.get_value(): m_end_state = CHI_SC;
    m_args.m_sd_to_ix_st_ch_pct.get_value(): m_end_state = CHI_IX;
      sum:                        if(donogotoSD)m_end_state = CHI_IX; else m_end_state = CHI_SD; 
    endcase
    m_snprsp_type = BFM_SNPRSP_DATA;
    if (m_end_state == CHI_IX)
      m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX_PD;
    else if (m_end_state == CHI_SC)
      m_snprsp_data_rsp = BFM_SNPRSP_DATA_SC_PD;
    else if (m_end_state == CHI_SD)
      m_snprsp_data_rsp = BFM_SNPRSP_DATA_SD;
    
  end
endfunction: pick_snponce_info

function void chi_rx_snp_chnl_cb::pick_snpcln_info(
    chi_bfm_cache_state_t init_state,
    bit ret2src,
    bit donogotoSD);
  if (init_state == CHI_IX) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_UC) begin

    randcase
    m_args.m_uc_to_ix_st_ch_pct.get_value(): m_end_state = CHI_IX;
    m_args.m_uc_to_sc_st_ch_pct.get_value(): m_end_state = CHI_SC;
    endcase
    if (m_end_state == CHI_SC) begin
        if ($urandom_range(1, 100) <= m_args.k_snprspdata_in_uc_pct.get_value() && (ret2src == 'h1)) begin
         m_snprsp_type     = BFM_SNPRSP_DATA;
         m_snprsp_data_rsp = BFM_SNPRSP_DATA_SC;
      end else begin
         m_snprsp_type     = BFM_SNPRSP;
         m_snprsp_rsp      = BFM_SNPRSP_SC;
      end
    end else if (m_end_state == CHI_IX) begin
        if ($urandom_range(1, 100) <= m_args.k_snprspdata_in_uc_pct.get_value() && (ret2src == 'h1)) begin
         m_snprsp_type     = BFM_SNPRSP_DATA;
         m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX;
      end else begin
         m_snprsp_type     = BFM_SNPRSP;
         m_snprsp_rsp      = BFM_SNPRSP_IX;
      end
    end else begin
      `ASSERT(0);
    end

  end else if (init_state == CHI_UCE) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_UD) begin
    randcase
    m_args.m_ud_to_sd_st_ch_pct.get_value(): if(donogotoSD)m_end_state = CHI_IX; else m_end_state = CHI_SD;
    m_args.m_ud_to_sc_st_ch_pct.get_value(): m_end_state = CHI_SC;
    m_args.m_ud_to_ix_st_ch_pct.get_value(): m_end_state = CHI_IX;
    endcase

    m_snprsp_type   = BFM_SNPRSP_DATA;
    case (m_end_state)
      CHI_SD: m_snprsp_data_rsp = BFM_SNPRSP_DATA_SD;
      CHI_SC: m_snprsp_data_rsp = BFM_SNPRSP_DATA_SC_PD;
      CHI_IX: m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX_PD;
      default: `ASSERT(0);
    endcase

  end else if (init_state == CHI_UDP) begin

      m_end_state = CHI_IX;
      m_snprsp_type = BFM_SNPRSP_DATA;
      m_snprsp_data_rsp = BFM_SNPRSP_DATAPTL_IX_PD;

  end else if (init_state == CHI_SC) begin

    randcase
    m_args.m_sc_to_ix_st_ch_pct.get_value():       m_end_state = CHI_IX;
    100 - m_args.m_sc_to_ix_st_ch_pct.get_value(): m_end_state = CHI_SC;
    endcase
    if (ret2src) begin
      m_snprsp_type = BFM_SNPRSP_DATA;
      if (m_end_state == CHI_SC)
        m_snprsp_data_rsp = BFM_SNPRSP_DATA_SC;
      else if (m_end_state == CHI_IX)
        m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX;
    end else begin
      m_snprsp_type = BFM_SNPRSP;
      if (m_end_state == CHI_SC)
        m_snprsp_rsp = BFM_SNPRSP_SC;
      else if (m_end_state == CHI_IX)
        m_snprsp_rsp = BFM_SNPRSP_IX;
    end

  end else if (init_state == CHI_SD) begin
    int sum;
<% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
`ifndef VCS
    sum = 100 - m_args.m_sd_to_sc_st_ch_pct.get_value() - m_args.m_sd_to_ix_st_ch_pct.get_value();
`else // `ifndef VCS
    if((m_args.m_sd_to_sc_st_ch_pct.get_value() + m_args.m_sd_to_ix_st_ch_pct.get_value())>100)
    sum =$urandom_range(1, 10); //CONC-11276
    else
    sum = 100 - m_args.m_sd_to_sc_st_ch_pct.get_value() - m_args.m_sd_to_ix_st_ch_pct.get_value();
`endif // `ifndef VCS
<% } else {%>
    sum = 100 - m_args.m_sd_to_sc_st_ch_pct.get_value() - m_args.m_sd_to_ix_st_ch_pct.get_value();
<% } %>
    randcase
    m_args.m_sd_to_sc_st_ch_pct.get_value(): m_end_state = CHI_SC;
    m_args.m_sd_to_ix_st_ch_pct.get_value(): m_end_state = CHI_IX;
    sum: if(donogotoSD)m_end_state = CHI_IX; else m_end_state = CHI_SD;
    endcase
    m_snprsp_type = BFM_SNPRSP_DATA;
    if (m_end_state == CHI_IX)
      m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX_PD;
    else if (m_end_state == CHI_SC)
      m_snprsp_data_rsp = BFM_SNPRSP_DATA_SC_PD;
    else if (m_end_state == CHI_SD)
      m_snprsp_data_rsp = BFM_SNPRSP_DATA_SD;
    
  end

endfunction: pick_snpcln_info

function void chi_rx_snp_chnl_cb::pick_snpunq_info(
    chi_bfm_cache_state_t init_state,
    bit ret2src);
  if (init_state == CHI_IX) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_UC) begin

    m_end_state = CHI_IX;
    if ($urandom_range(1, 100) <= m_args.k_snprspdata_in_uc_pct.get_value() && (ret2src == 'h1)) begin  // #Check.CHIAIU.v3.SP.RetToSrc
       m_snprsp_type     = BFM_SNPRSP_DATA;
       m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX;
    end else begin
       m_snprsp_type     = BFM_SNPRSP;
       m_snprsp_rsp      = BFM_SNPRSP_IX;
    end

  end else if (init_state == CHI_UCE) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_UD) begin

    m_end_state = CHI_IX;
    m_snprsp_type   = BFM_SNPRSP_DATA;
    m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX_PD;

  end else if (init_state == CHI_UDP) begin

    m_end_state = CHI_IX;
    m_snprsp_type   = BFM_SNPRSP_DATA;
    m_snprsp_data_rsp = BFM_SNPRSP_DATAPTL_IX_PD;

  end else if (init_state == CHI_SC) begin

    m_end_state = CHI_IX;
    if (ret2src) begin
      m_snprsp_type = BFM_SNPRSP_DATA;
      m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX;
    end else begin
      m_snprsp_type = BFM_SNPRSP;
      m_snprsp_rsp = BFM_SNPRSP_IX;
    end

  end else if (init_state == CHI_SD) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP_DATA;
    m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX_PD;

  end
endfunction: pick_snpunq_info

 function void chi_rx_snp_chnl_cb::pick_snpcln_shrd_info(
    chi_bfm_cache_state_t init_state,
    bit ret2src);

  if (init_state == CHI_IX) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_UC) begin
    int sum;
<% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
`ifndef VCS
    sum = 100 - m_args.m_uc_to_ix_st_ch_pct.get_value() - m_args.m_uc_to_sc_st_ch_pct.get_value();
`else // `ifndef VCS
    if((m_args.m_uc_to_ix_st_ch_pct.get_value() + m_args.m_uc_to_sc_st_ch_pct.get_value())>100)
    sum =$urandom_range(1, 10); //CONC-11276
    else
    sum = 100 - m_args.m_uc_to_ix_st_ch_pct.get_value() - m_args.m_uc_to_sc_st_ch_pct.get_value();
`endif // `ifndef VCS
<% } else {%>
    sum = 100 - m_args.m_uc_to_ix_st_ch_pct.get_value() - m_args.m_uc_to_sc_st_ch_pct.get_value();
<% } %>
    randcase
      sum:                         m_end_state = CHI_UC;
      m_args.m_uc_to_ix_st_ch_pct.get_value(): m_end_state = CHI_IX;
      m_args.m_uc_to_sc_st_ch_pct.get_value(): m_end_state = CHI_SC;
    endcase
    if (m_end_state == CHI_UC) begin
       m_snprsp_type     = BFM_SNPRSP;
       m_snprsp_rsp      = BFM_SNPRSP_UC_OR_UD;
    end else if (m_end_state == CHI_SC) begin
       m_snprsp_type     = BFM_SNPRSP;
       m_snprsp_rsp      = BFM_SNPRSP_SC;
    end else if (m_end_state == CHI_IX) begin
       m_snprsp_type     = BFM_SNPRSP;
       m_snprsp_rsp      = BFM_SNPRSP_IX;
    end else begin
      `ASSERT(0);
    end

  end else if (init_state == CHI_UCE) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_UD) begin

    randcase
    m_args.m_ud_to_uc_st_ch_pct.get_value(): m_end_state = CHI_UC;
    m_args.m_ud_to_sc_st_ch_pct.get_value(): m_end_state = CHI_SC;
    m_args.m_ud_to_ix_st_ch_pct.get_value(): m_end_state = CHI_IX;
    endcase
    m_snprsp_type   = BFM_SNPRSP_DATA;
    case (m_end_state)
      CHI_UC: m_snprsp_data_rsp = BFM_SNPRSP_DATA_UC_PD;
      CHI_SC: m_snprsp_data_rsp = BFM_SNPRSP_DATA_SC_PD;
      CHI_IX: m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX_PD;
      default: `ASSERT(0);
    endcase

  end else if (init_state == CHI_UDP) begin

    m_end_state = CHI_IX;
    m_snprsp_type   = BFM_SNPRSP_DATA;
    m_snprsp_data_rsp = BFM_SNPRSP_DATAPTL_IX_PD;

  end else if (init_state == CHI_SC) begin

    randcase
    m_args.m_sc_to_ix_st_ch_pct.get_value():       m_end_state = CHI_IX;
    100 - m_args.m_sc_to_ix_st_ch_pct.get_value(): m_end_state = CHI_SC;
    endcase
    /* Ret2Src is always 0 for SnpClnShrd according to CHI-B Spec Appendix A.4 Snoop Request message field mappings
    if (ret2src) begin
      m_snprsp_type = BFM_SNPRSP_DATA;
      if (m_end_state == CHI_SC)
        m_snprsp_data_rsp = BFM_SNPRSP_DATA_SC;
      else if (m_end_state == CHI_IX)
        m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX;
    end else begin
      */
      m_snprsp_type = BFM_SNPRSP;
      if (m_end_state == CHI_SC)
        m_snprsp_rsp = BFM_SNPRSP_SC;
      else if (m_end_state == CHI_IX)
        m_snprsp_rsp = BFM_SNPRSP_IX;

    //end

  end else if (init_state == CHI_SD) begin

    randcase
    m_args.m_sd_to_sc_st_ch_pct.get_value(): m_end_state = CHI_SC;
    m_args.m_sd_to_ix_st_ch_pct.get_value(): m_end_state = CHI_IX;
    endcase
    m_snprsp_type = BFM_SNPRSP_DATA;
    if (m_end_state == CHI_IX)
      m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX_PD;
    else if (m_end_state == CHI_SC)
      m_snprsp_data_rsp = BFM_SNPRSP_DATA_SC_PD;
    else
      `ASSERT(0);
    
  end

endfunction: pick_snpcln_shrd_info

function void chi_rx_snp_chnl_cb::pick_snpcln_invld_info(
    chi_bfm_cache_state_t init_state,
    bit ret2src);
  if (init_state == CHI_IX) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_UC) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_UCE) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_UD) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP_DATA;
    m_snprsp_data_rsp  = BFM_SNPRSP_DATA_IX_PD;

  end else if (init_state == CHI_UDP) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP_DATA;
    m_snprsp_data_rsp = BFM_SNPRSP_DATAPTL_IX_PD;

  end else if (init_state == CHI_SC) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_SD) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP_DATA;
    m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX_PD;
    
  end

endfunction: pick_snpcln_invld_info

function void chi_rx_snp_chnl_cb::pick_snpmk_invld_info(
    chi_bfm_cache_state_t init_state,
    bit ret2src);

  m_end_state = CHI_IX;
  m_snprsp_type = BFM_SNPRSP;
  m_snprsp_rsp  = BFM_SNPRSP_IX;

endfunction: pick_snpmk_invld_info

function void chi_rx_snp_chnl_cb::pick_snpunq_stsh_info(
    chi_bfm_cache_state_t init_state,
    int donot_datapull,
    bit addr_matches_outstq);

  if (donot_datapull || addr_matches_outstq) begin
    m_datapull = 0;
  end else begin
    randcase 
    m_args.k_stashing_datapull_pct.get_value(): m_datapull = 1;
      100 - m_args.k_stashing_datapull_pct.get_value(): m_datapull = 0;
    endcase
  end
     
  if (init_state == CHI_IX || init_state == CHI_UCE) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp  = BFM_SNPRSP_IX;

  end else if (init_state == CHI_UC)  begin

    m_end_state = CHI_IX;
    randcase
    m_args.k_snprspdata_in_uc_pct.get_value(): begin
        m_snprsp_type     = BFM_SNPRSP_DATA;
        m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX;
      end

      100 - m_args.k_snprspdata_in_uc_pct.get_value(): begin
        m_snprsp_type = BFM_SNPRSP;
        m_snprsp_rsp  = BFM_SNPRSP_IX;
      end
    endcase

  end else if (init_state == CHI_UD) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP_DATA;
    m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX_PD;

  end else if (init_state == CHI_UDP) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP_DATA;
    m_snprsp_data_rsp = BFM_SNPRSP_DATAPTL_IX_PD;

  end else if (init_state == CHI_SC) begin
    
    m_end_state = CHI_IX;
    randcase
    m_args.k_snprspdata_in_sc_pct.get_value(): begin
        m_snprsp_type = BFM_SNPRSP_DATA;
        m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX;
      end

      100 - m_args.k_snprspdata_in_sc_pct.get_value(): begin
        m_snprsp_type = BFM_SNPRSP;
        m_snprsp_rsp  = BFM_SNPRSP_IX;
      end
    endcase

  end else if (init_state == CHI_SD) begin

    m_end_state = CHI_IX;
    m_snprsp_type = BFM_SNPRSP_DATA;
    m_snprsp_data_rsp = BFM_SNPRSP_DATA_IX_PD;

  end else begin
    `ASSERT(0);
  end
endfunction: pick_snpunq_stsh_info

function void chi_rx_snp_chnl_cb::pick_snpmk_invld_stsh_info(
    chi_bfm_cache_state_t init_state,
    int donot_datapull,
    bit addr_matches_outstq);

  if (donot_datapull || addr_matches_outstq) begin
    m_datapull = 0;
  end else begin
    randcase 
    m_args.k_stashing_datapull_pct.get_value(): m_datapull = 1;
    100 - m_args.k_stashing_datapull_pct.get_value(): m_datapull = 0;
    endcase
  end
     
  m_end_state = CHI_IX;
  m_snprsp_type = BFM_SNPRSP;
  m_snprsp_rsp  = BFM_SNPRSP_IX;

endfunction: pick_snpmk_invld_stsh_info

function void chi_rx_snp_chnl_cb::pick_snpstsh_unq_info(
    chi_bfm_cache_state_t init_state,
    int donot_datapull,
    bit addr_matches_outstq);

  m_end_state = init_state;
  m_snprsp_type = BFM_SNPRSP;

  if (donot_datapull || addr_matches_outstq) begin
    m_datapull = 0;
  end else begin
    randcase 
    m_args.k_stashing_datapull_pct.get_value(): m_datapull = 1;
    100 - m_args.k_stashing_datapull_pct.get_value(): m_datapull = 0;
    endcase
  end

  if (m_datapull && init_state inside {CHI_IX,CHI_SC,CHI_SD} ) begin //  Datapull support from CHI_UCE state in Ncore3.4 removed TODO To re removed in ncore 3.6
    case (init_state)
      CHI_IX:  m_snprsp_rsp = BFM_SNPRSP_IX;
      CHI_UCE: m_snprsp_rsp = BFM_SNPRSP_UC_OR_UD;
      CHI_SC:  m_snprsp_rsp = BFM_SNPRSP_SC;
      CHI_SD:  m_snprsp_rsp = BFM_SNPRSP_SD;
    endcase
  end else begin
    m_datapull = 0;
    case (init_state)
      CHI_IX:  m_snprsp_rsp = BFM_SNPRSP_IX;
      CHI_UC:  m_snprsp_rsp = BFM_SNPRSP_UC_OR_UD;
      CHI_UCE: m_snprsp_rsp = BFM_SNPRSP_UC_OR_UD;
      CHI_UD:  m_snprsp_rsp = BFM_SNPRSP_UC_OR_UD;
      CHI_UDP: m_snprsp_rsp = BFM_SNPRSP_UC_OR_UD;
      CHI_SC:  m_snprsp_rsp = BFM_SNPRSP_SC;
      CHI_SD:  m_snprsp_rsp = BFM_SNPRSP_SD;
    endcase
    <%if(obj.testBench != "fsys"){ %> //To keep consistency at FSYS level (DCE) of final cache state which will not change
    if($urandom%5==1) m_snprsp_rsp = BFM_SNPRSP_IX; //randomize to cover the snp resp can always be invalid
    <%}%>
  end

endfunction: pick_snpstsh_unq_info

function void chi_rx_snp_chnl_cb::pick_snpstsh_shrd_info(
    chi_bfm_cache_state_t init_state,
    int donot_datapull,
    bit addr_matches_outstq);
  m_end_state = init_state;
  m_snprsp_type = BFM_SNPRSP;

  if (donot_datapull || addr_matches_outstq) begin
    m_datapull = 0;
  end else begin
    randcase 
    m_args.k_stashing_datapull_pct.get_value(): m_datapull = 1;
    100 - m_args.k_stashing_datapull_pct.get_value(): m_datapull = 0;
    endcase
  end

  if (m_datapull && init_state inside {CHI_IX}) begin  //  Datapull support from CHI_UCE state in Ncore3.4 removed TODO To re removed in ncore 3.6
    case (init_state)
      CHI_IX:  m_snprsp_rsp = BFM_SNPRSP_IX;
      CHI_UCE: m_snprsp_rsp  = BFM_SNPRSP_UC_OR_UD;
    endcase
  end else begin
    m_datapull = 0;
    case (init_state)
      CHI_IX:  m_snprsp_rsp = BFM_SNPRSP_IX;
      CHI_UC:  m_snprsp_rsp  = BFM_SNPRSP_UC_OR_UD;
      CHI_UCE: m_snprsp_rsp  = BFM_SNPRSP_UC_OR_UD;
      CHI_UD:  m_snprsp_rsp  = BFM_SNPRSP_UC_OR_UD;
      CHI_UDP: m_snprsp_rsp  = BFM_SNPRSP_UC_OR_UD;
      CHI_SC:  m_snprsp_rsp   = BFM_SNPRSP_SC;
      CHI_SD:  m_snprsp_rsp   = BFM_SNPRSP_SD;
    endcase
    <%if(obj.testBench != "fsys"){ %>//To keep consistency at FSYS level (DCE) of final cache state which will not change
    if($urandom%5==1) m_snprsp_rsp = BFM_SNPRSP_IX; //randomize to cover the snp resp can always be invalid
    <%}%>
  end
endfunction: pick_snpstsh_shrd_info

function void chi_rx_snp_chnl_cb::pick_snpdvm_info(
    chi_bfm_cache_state_t init_state,
    bit ret2src);

    m_snprsp_type = BFM_SNPRSP;
    m_snprsp_rsp = BFM_SNPRSP_IX;

endfunction: pick_snpdvm_info


function void chi_rx_snp_chnl_cb::pick_snponce_fwd_info(
    chi_bfm_cache_state_t init_state,
    bit ret2src);

endfunction: pick_snponce_fwd_info

function void chi_rx_snp_chnl_cb::pick_snpcln_fwd_info(
    chi_bfm_cache_state_t init_state,
    bit ret2src);

endfunction: pick_snpcln_fwd_info

function void chi_rx_snp_chnl_cb::pick_snpntshrddirty_fwd_info(
    chi_bfm_cache_state_t init_state,
    bit ret2src);

endfunction: pick_snpntshrddirty_fwd_info

function void chi_rx_snp_chnl_cb::pick_snpunq_fwd_info(
    chi_bfm_cache_state_t init_state,
    bit ret2src);

endfunction: pick_snpunq_fwd_info

