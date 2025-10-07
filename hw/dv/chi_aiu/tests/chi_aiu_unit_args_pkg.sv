`ifndef chi_aiu_unit_args_pkg
`define chi_aiu_unit_args_pkg
package chi_aiu_unit_args_pkg;

import uvm_pkg::*;
import common_knob_pkg::*;
`include "uvm_macros.svh"

class chi_aiu_unit_args extends uvm_object;

  `uvm_object_utils(chi_aiu_unit_args)

  const int            m_weights_for_k_num_requests[1]   = {100};
  const int            m_weights_for_k_on_fly_req[2]     = {50, 50};
<% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
`ifndef VCS
  const t_minmax_range m_minmax_for_k_num_requests[1]    = {{500,2000}};
  const t_minmax_range rs_m_minmax_for_k_num_requests[1]    = {{1 ,1}};
  const t_minmax_range m_minmax_for_k_on_fly_req[2]      = {{4, 16}, {17, 300}};
  const t_minmax_range m_minmax_for_weight_not0_knobs[3] = {{1,5}, {5,100}, {85,100}};
`else // `ifndef VCS
  const t_minmax_range m_minmax_for_k_num_requests[1]    = '{'{m_min_range:500,m_max_range:2000}};
  const t_minmax_range rs_m_minmax_for_k_num_requests[1]    = '{'{m_min_range:1,m_max_range:1}};
  const t_minmax_range m_minmax_for_k_on_fly_req[2]      = '{'{m_min_range:4,m_max_range:16}, '{m_min_range:17,m_max_range:300}};
  const t_minmax_range m_minmax_for_weight_not0_knobs[3] = '{'{m_min_range:1,m_max_range:5}, '{m_min_range:5,m_max_range:100}, '{m_min_range:85,m_max_range:100}};
`endif // `ifndef VCS ... `else ... 
<% } else {%>
  const t_minmax_range m_minmax_for_k_num_requests[1]    = {{500,2000}};
  const t_minmax_range rs_m_minmax_for_k_num_requests[1]    = {{1 ,1}};
  const t_minmax_range m_minmax_for_k_on_fly_req[2]      = {{4, 16}, {17, 300}};
  const t_minmax_range m_minmax_for_weight_not0_knobs[3] = {{1,5}, {5,100}, {85,100}};
<% } %>

  //Total number of requests  
  common_knob_class k_num_requests; // = new ("k_num_requests", this, m_weights_for_k_num_requests, m_minmax_for_k_num_requests);
  common_knob_class k_on_fly_req   = new ("k_on_fly_req", this,   m_weights_for_k_on_fly_req,   m_minmax_for_k_on_fly_req);

  //PCT split by command type
  common_knob_class k_rd_noncoh_pct     		= new ("k_rd_noncoh_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_rd_rdonce_pct     		= new ("k_rd_rdonce_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_rd_prfr_unq_pct   		= new ("k_rd_prfr_unq_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_wr_nosnp_full_cmo    		= new ("k_wr_nosnp_full_cmo", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_wr_back_full_cmo	    		= new ("k_wr_back_full_cmo", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_wr_cln_full_cmo   		= new ("k_wr_cln_full_cmo", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_wr_evict_or_evict	    		= new ("k_wr_evict_or_evict", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_rd_ldrstr_pct     		= new ("k_rd_ldrstr_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_dt_ls_upd_pct     		= new ("k_dt_ls_upd_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_dt_ls_cmo_pct     		= new ("k_dt_ls_cmo_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_dt_ls_sth_pct     		= new ("k_dt_ls_sth_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_wr_noncoh_pct     		= new ("k_wr_noncoh_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_wr_cohunq_pct     		= new ("k_wr_cohunq_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_wr_sthunq_pct     		= new ("k_wr_sthunq_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_wr_cpybck_pct     		= new ("k_wr_cpybck_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_atomic_st_pct     		= new ("k_atomic_st_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_atomic_ld_pct     		= new ("k_atomic_ld_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_atomic_sw_pct     		= new ("k_atomic_sw_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_atomic_cm_pct     		= new ("k_atomic_cm_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_dvm_opert_pct     		= new ("k_dvm_opert_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_pre_fetch_pct     		= new ("k_pre_fetch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_rq_lcrdrt_pct     		= new ("k_rq_lcrdrt_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);

  common_knob_class k_coh_addr_pct        		= new ("k_coh_addr_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_noncoh_addr_pct     		= new ("k_noncoh_addr_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_new_addr_pct        		= new ("k_new_addr_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_device_type_mem_pct 		= new ("k_device_type_mem_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);

  common_knob_class k_cacheable_pct         		= new ("k_cacheable_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_noncacheable_pct      		= new ("k_noncacheable_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_alloc_hint_pct        		= new ("k_alloc_hint_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_nonalloc_hint_pct     		= new ("k_nonalloc_hint_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_partial_bytes_vld_pct 		= new ("k_partial_bytes_vld_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_writedatacancel_pct   		= new ("k_writedatacancel_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_all_bytes_vld_pct     		= new ("k_all_bytes_vld_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);

    // Weights for CHI Subsystem sequence
    common_knob_class wt_read_preferunique          = new ("wt_read_preferunique", this, {0}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_make_readunique            = new ("wt_make_readunique", this, {0}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_cln_shrd_psist_sep         = new ("wt_cln_shrd_psist_sep", this, {0}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_write_unique_zero          = new ("wt_write_unique_zero", this, {0}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_write_nosnp_zero           = new ("wt_write_nosnp_zero", this, {0}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_wrnosnpfull_clnshrd        = new ("wt_wrnosnpfull_clnshrd", this, {0}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_wrnosnpfull_clninv         = new ("wt_wrnosnpfull_clninv", this, {0}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_wrnosnpfull_clnshrd_persep = new ("wt_wrnosnpfull_clnshrd_persep", this, {1}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_wrbkfull_clnshrd           = new ("wt_wrbkfull_clnshrd", this, {0}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_wrbkfull_clninv            = new ("wt_wrbkfull_inv", this, {0}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_wrbkfull_clnshrd_persep    = new ("wt_wrbkfull_clnshrd_persep", this, {0}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_wrclnfull_clnshrd          = new ("wt_wrclnfull_clnshrd", this, {0}, '{'{m_min_range:1,m_max_range:10}});
    common_knob_class wt_wrclnfull_clnshrd_persep   = new ("wt_wrclnfull_clnshrd_persep", this, {0}, '{'{m_min_range:1,m_max_range:10}});
  ////
  //State Changes
  ////
  //Args for down-grading to IX state 
  common_knob_class m_sc_to_ix_st_ch_pct  = new ("m_sc_to_ix_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class m_uc_to_ix_st_ch_pct  = new ("m_uc_to_ix_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class m_uce_to_ix_st_ch_pct = new ("m_uce_to_ix_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class m_sd_to_ix_st_ch_pct  = new ("m_sd_to_ix_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class m_ud_to_ix_st_ch_pct  = new ("m_ud_to_ix_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class m_udp_to_ix_st_ch_pct = new ("m_udp_to_ix_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  //Args for down-grading to Shared state
  common_knob_class m_uc_to_sc_st_ch_pct = new ("m_uc_to_sc_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class m_ud_to_sd_st_ch_pct = new ("m_ud_to_sd_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  //Args for dirty to clean state
  common_knob_class m_sd_to_sc_st_ch_pct = new ("m_sd_to_sc_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class m_ud_to_sc_st_ch_pct = new ("m_ud_to_sc_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class m_ud_to_uc_st_ch_pct = new ("m_ud_to_uc_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  //Args for moving clean to dirty owned state
  common_knob_class m_uc_to_ud_st_ch_pct   = new ("m_uc_to_ud_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class m_uc_to_udp_st_ch_pct  = new ("m_uc_to_udp_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class m_uce_to_ud_st_ch_pct  = new ("m_uce_to_ud_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class m_uce_to_udp_st_ch_pct = new ("m_uce_to_udp_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  //Args for moving partial dirty to dirty state
  common_knob_class m_udp_to_ud_st_ch_pct = new ("m_udp_to_ud_st_ch_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);

  //Issue data for snpReq's while data is clean
  common_knob_class k_snprspdata_in_uc_pct = new ("k_snprspdata_in_uc_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_snprspdata_in_sc_pct = new ("k_snprspdata_in_sc_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);

  //Data pull for stashing commands
  common_knob_class k_stashing_datapull_pct = new ("k_stashing_datapull_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);

  //Args to set delays between flits
  common_knob_class k_txreq_hld_dly = new ("k_txreq_hld_dly", this, m_weights_for_weight_knobs, m_minmax_for_weight_not0_knobs);
  common_knob_class k_txreq_dly_min = new ("k_txreq_dly_min", this, m_weights_for_weight_knobs, m_minmax_for_weight_not0_knobs);
  common_knob_class k_txreq_dly_max = new ("k_txreq_dly_max", this, m_weights_for_weight_knobs, m_minmax_for_weight_not0_knobs);

  common_knob_class k_txrsp_hld_dly = new ("k_txrsp_hld_dly", this, m_weights_for_weight_knobs, m_minmax_for_weight_not0_knobs);
  common_knob_class k_txrsp_dly_min = new ("k_txrsp_dly_min", this, m_weights_for_weight_knobs, m_minmax_for_weight_not0_knobs);
  common_knob_class k_txrsp_dly_max = new ("k_txrsp_dly_max", this, m_weights_for_weight_knobs, m_minmax_for_weight_not0_knobs);

  common_knob_class k_txdat_hld_dly = new ("k_txdat_hld_dly", this, m_weights_for_weight_knobs, m_minmax_for_weight_not0_knobs);
  common_knob_class k_txdat_dly_min = new ("k_txdat_dly_min", this, m_weights_for_weight_knobs, m_minmax_for_weight_not0_knobs);
  common_knob_class k_txdat_dly_max = new ("k_txdat_dly_max", this, m_weights_for_weight_knobs, m_minmax_for_weight_not0_knobs);

  //Knobs to control DVMOp types, only 
  //applicable if DVMOp is generated
  common_knob_class k_dvm_tlbi_pct = new ("k_dvm_tlbi_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_dvm_bpi_pct  = new ("k_dvm_bpi_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_dvm_pici_pct = new ("k_dvm_pici_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_dvm_vici_pct = new ("k_dvm_vici_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class k_dvm_sync_pct = new ("k_dvm_sync_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);

  //unsupported opcode
  common_knob_class k_unsupported_txn_pct = new ("k_unsupported_txn_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);

  //exclusive transaction
  common_knob_class k_excl_txn_pct = new ("k_excl_txn_pct", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);

  //Methods
  extern function new(string s = "chi_aiu_unit_args");
  extern function void read_plusargs();

endclass: chi_aiu_unit_args

function chi_aiu_unit_args::new(string s = "chi_aiu_unit_args");
  super.new(s);

  //Max num requests
 if (!$test$plusargs("RS_TEMP")) 
	k_num_requests = new ("k_num_requests", this, m_weights_for_k_num_requests, m_minmax_for_k_num_requests);
  else
	k_num_requests = new ("k_num_requests", this, m_weights_for_k_num_requests, rs_m_minmax_for_k_num_requests);

  //Command types
  /*
  k_rd_noncoh_pct       = 5;
  k_rd_rdonce_pct       = 5;
  k_rd_ldrstr_pct       = 40;
  k_dt_ls_upd_pct       = 10;
  k_dt_ls_cmo_pct       = 10;
  k_dt_ls_sth_pct       = 0;
  k_wr_noncoh_pct       = 5;
  k_wr_cohunq_pct       = 10;
  k_wr_sthunq_pct       = 0;
  k_wr_cpybck_pct       = 15;
  k_atomic_st_pct       = 0;
  k_atomic_ld_pct       = 0;
  k_atomic_sw_pct       = 0;
  k_atomic_cm_pct       = 0;
  k_dvm_opert_pct       = 0;
  k_pre_fetch_pct       = 0;
  k_rq_lcrdrt_pct       = 0;
  k_all_bytes_vld_pct   = 100;

  //Other Request channel attributes
  k_coh_addr_pct          = 50;
  k_noncoh_addr_pct       = 100 - k_coh_addr_pct;
  k_new_addr_pct          = 100;
  k_alloc_hint_pct        = 90;
  k_nonalloc_hint_pct     = 100 - k_alloc_hint_pct;
  k_cacheable_pct         = 90;
  k_noncacheable_pct      = 100  - k_cacheable_pct;
  k_partial_bytes_vld_pct = 10;
  k_writedatacancel_pct   = 0;

  //Default values for state change parameters
  m_sc_to_ix_st_ch_pct    = 1;
  m_uc_to_ix_st_ch_pct    = 1;
  m_uce_to_ix_st_ch_pct   = 1;
  m_ud_to_ix_st_ch_pct    = 2;
  m_udp_to_ix_st_ch_pct   = 2;
  m_sd_to_ix_st_ch_pct    = 2;
  m_uc_to_sc_st_ch_pct    = 4;
  
  m_ud_to_uc_st_ch_pct    = 5;
  m_ud_to_sd_st_ch_pct    = 5;
  m_ud_to_sc_st_ch_pct    = 5;
  m_sd_to_sc_st_ch_pct    = 5;
  m_udp_to_ud_st_ch_pct   = 5;
  m_uc_to_ud_st_ch_pct    = 15;
  m_uc_to_udp_st_ch_pct   = 15;
  m_uce_to_ud_st_ch_pct   = 15;
  m_uce_to_udp_st_ch_pct  = 15;

  k_snprspdata_in_uc_pct  = 90;
  k_snprspdata_in_sc_pct  = 20;
  k_stashing_datapull_pct = 100;

  k_txreq_hld_dly  = 1000;
  k_txreq_dly_min  = 0;
  k_txreq_dly_max  = 0;
 
  k_txrsp_hld_dly  = 1;
  k_txrsp_dly_min  = 0;
  k_txrsp_dly_max  = 16;

  k_txdat_hld_dly  = 7;
  k_txdat_dly_min  = 0;
  k_txdat_dly_max  = 8;

  k_dvm_tlbi_pct    = 15;
  k_dvm_bpi_pct     = 15;
  k_dvm_pici_pct    = 15;
  k_dvm_vici_pct    = 15;
  k_dvm_sync_pct    = 15;  
  */
endfunction: new

function void chi_aiu_unit_args::read_plusargs();

endfunction: read_plusargs

endpackage: chi_aiu_unit_args_pkg
`endif // `ifdef chi_aiu_unit_args_pkg
