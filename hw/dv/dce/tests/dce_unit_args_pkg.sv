package dce_unit_args_pkg;

import uvm_pkg::*;
import common_knob_pkg::*;
`include "uvm_macros.svh"

import <%=obj.BlockId%>_env_pkg::*;

class dce_unit_args extends uvm_object;

  `uvm_object_utils(dce_unit_args)

  //plusarg properties
  uvm_cmdline_processor clp; //= uvm_cmdline_processor::get_inst();

  int k_dce_scb_en         = 1;
  int k_dirm_scb_en        = 1;
  int k_dirm_dbg_en        = 0;
  int k_functional_cov     = 0;
  int ev_prot_timeout_val  = 0;

//defaults
//const int            m_weights_for_weight_knobs[3] = {15, 70, 15};
//const t_minmax_range m_minmax_for_weight_knobs[3]  = {{0,5}, {5,100}, {85,100}};

const int            m_weights_for_weight_knobs_for_alloc_ops[3] = {15, 15, 70};
<% if(obj.testBench == 'dce') { %>
//`ifndef VCS
//const t_minmax_range m_minmax_for_weight_knobs_for_alloc_ops[3]  = {{0,5}, {5,100}, {85,100}};
//`else // `ifndef VCS
const t_minmax_range m_minmax_for_weight_knobs_for_alloc_ops[3]  ='{'{m_min_range:0,m_max_range:5}, '{m_min_range:5,m_max_range:100}, '{m_min_range:85,m_max_range:100}};
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
const t_minmax_range m_minmax_for_weight_knobs_for_alloc_ops[3]  = {{0,5}, {5,100}, {85,100}};
<% } %>  
  
  //reads
  //Increased the % of allocting ops so the directory is always warmed up
<% if(obj.testBench == 'dce') { %>
//`ifndef VCS
//  common_knob_class k_cmd_rd_cln_pct         = new("k_cmd_rd_cln_pct"         , this , {5, 25, 70} , {{0,5}, {5,85}, {85,100}});
 // common_knob_class k_cmd_rd_not_shd_pct     = new("k_cmd_rd_not_shd_pct"     , this , {5, 25, 70} , {{0,5}, {5,85}, {85,100}});
  //common_knob_class k_cmd_rd_vld_pct         = new("k_cmd_rd_vld_pct"         , this , {5, 25, 70} , {{0,5}, {5,85}, {85,100}});
//`else // `ifndef VCS
  common_knob_class k_cmd_rd_cln_pct         = new("k_cmd_rd_cln_pct"         , this , {5, 25, 70} , '{'{m_min_range:0,m_max_range:5}, '{m_min_range:5,m_max_range:85}, '{m_min_range:85,m_max_range:100}});
  common_knob_class k_cmd_rd_not_shd_pct     = new("k_cmd_rd_not_shd_pct"     , this , {5, 25, 70} , '{'{m_min_range:0,m_max_range:5}, '{m_min_range:5,m_max_range:85}, '{m_min_range:85,m_max_range:100}});
  common_knob_class k_cmd_rd_vld_pct         = new("k_cmd_rd_vld_pct"         , this , {5, 25, 70} , '{'{m_min_range:0,m_max_range:5}, '{m_min_range:5,m_max_range:85}, '{m_min_range:85,m_max_range:100}});
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
  common_knob_class k_cmd_rd_cln_pct         = new("k_cmd_rd_cln_pct"         , this , {5, 25, 70} , {{0,5}, {5,85}, {85,100}});
  common_knob_class k_cmd_rd_not_shd_pct     = new("k_cmd_rd_not_shd_pct"     , this , {5, 25, 70} , {{0,5}, {5,85}, {85,100}});
  common_knob_class k_cmd_rd_vld_pct         = new("k_cmd_rd_vld_pct"         , this , {5, 25, 70} , {{0,5}, {5,85}, {85,100}});
<% } %>

  common_knob_class k_cmd_rd_unq_pct         = new("k_cmd_rd_unq_pct"         , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_rd_nitc_pct        = new("k_cmd_rd_nitc_pct"        , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_rd_nitc_clninv_pct = new("k_cmd_rd_nitc_clninv_pct" , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_rd_nitc_mkinv_pct  = new("k_cmd_rd_nitc_mkinv_pct"  , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

  //atomics
  //reduce weight knobs for atm ops since they are mostly invalidating ops.
<% if(obj.testBench == 'dce') { %>
//`ifndef VCS
  //common_knob_class k_cmd_rd_atm_pct         = new("k_cmd_rd_atm_pct"         , this , {5, 10, 85} , {{90,100}, {20,89}, {0,19}});
  //common_knob_class k_cmd_wr_atm_pct         = new("k_cmd_wr_atm_pct"         , this , {5, 10, 85} , {{90,100}, {20,89}, {0,19}});
  //common_knob_class k_cmd_cmp_atm_pct        = new("k_cmd_cmp_atm_pct"        , this , {5, 10, 85} , {{90,100}, {20,89}, {0,19}});
  //common_knob_class k_cmd_swp_atm_pct        = new("k_cmd_swp_atm_pct"        , this , {5, 10, 85} , {{90,100}, {20,89}, {0,19}});
//`else // `ifndef VCS
  common_knob_class k_cmd_rd_atm_pct         = new("k_cmd_rd_atm_pct"         , this , {5, 10, 85} , '{'{m_min_range:90,m_max_range:100}, '{m_min_range:20,m_max_range:89}, '{m_min_range:0,m_max_range:19}});
  common_knob_class k_cmd_wr_atm_pct         = new("k_cmd_wr_atm_pct"         , this , {5, 10, 85} , '{'{m_min_range:90,m_max_range:100}, '{m_min_range:20,m_max_range:89}, '{m_min_range:0,m_max_range:19}});
  common_knob_class k_cmd_cmp_atm_pct        = new("k_cmd_cmp_atm_pct"        , this , {5, 10, 85} , '{'{m_min_range:90,m_max_range:100}, '{m_min_range:20,m_max_range:89}, '{m_min_range:0,m_max_range:19}});
  common_knob_class k_cmd_swp_atm_pct        = new("k_cmd_swp_atm_pct"        , this , {5, 10, 85} , '{'{m_min_range:90,m_max_range:100}, '{m_min_range:20,m_max_range:89}, '{m_min_range:0,m_max_range:19}});
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
  common_knob_class k_cmd_rd_atm_pct         = new("k_cmd_rd_atm_pct"         , this , {5, 10, 85} , {{90,100}, {20,89}, {0,19}});
  common_knob_class k_cmd_wr_atm_pct         = new("k_cmd_wr_atm_pct"         , this , {5, 10, 85} , {{90,100}, {20,89}, {0,19}});
  common_knob_class k_cmd_cmp_atm_pct        = new("k_cmd_cmp_atm_pct"        , this , {5, 10, 85} , {{90,100}, {20,89}, {0,19}});
  common_knob_class k_cmd_swp_atm_pct        = new("k_cmd_swp_atm_pct"        , this , {5, 10, 85} , {{90,100}, {20,89}, {0,19}});
<% } %>
  
  //non stash writes
  common_knob_class k_cmd_wr_unq_ptl_pct     = new("k_cmd_wr_unq_ptl_pct"     , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_wr_unq_full_pct    = new("k_cmd_wr_unq_full_pct"    , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_wr_cln_full_pct    = new("k_cmd_wr_cln_full_pct"    , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_wr_cln_ptl_pct     = new("k_cmd_wr_cln_ptl_pct"     , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_wr_bk_ptl_pct      = new("k_cmd_wr_bk_ptl_pct"      , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_wr_bk_full_pct     = new("k_cmd_wr_bk_full_pct"     , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_wr_evct_pct        = new("k_cmd_wr_evct_pct"        , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

  //dataless
  common_knob_class k_cmd_evct_pct           = new("k_cmd_evct_pct"           , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

  //stash writes
  common_knob_class k_cmd_wr_stsh_ptl_pct    = new("k_cmd_wr_stsh_ptl_pct"    , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_wr_stsh_full_pct   = new("k_cmd_wr_stsh_full_pct"   , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

  //cleans
  common_knob_class k_cmd_cln_unq_pct        = new("k_cmd_cln_unq_pct"        , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_cln_vld_pct        = new("k_cmd_cln_vld_pct"        , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_cln_inv_pct        = new("k_cmd_cln_inv_pct"        , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_cln_shd_per_pct    = new("k_cmd_cln_shd_per_pct"    , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

  //makes
  common_knob_class k_cmd_mk_unq_pct         = new("k_cmd_mk_unq_pct"         , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_mk_inv_pct         = new("k_cmd_mk_inv_pct"         , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

  //stashing reads
  common_knob_class k_cmd_ldcch_shd_pct      = new("k_cmd_ldcch_shd_pct"      , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class k_cmd_ldcch_unq_pct      = new("k_cmd_ldcch_unq_pct"      , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
 
  // k_num_coh_cmds : 1k-3k (90%) 10k (10%)
  // no_addr_conflict: 1 (30%) 0 (70%)
  // recall_all : 1(5%)
  // max_num_addr : 50-1k (100%) 

  const int            m_weights_k_perform_recall_all[1] = {5};
<% if(obj.testBench == 'dce') { %>
//`ifndef VCS
  //const t_minmax_range m_minmax_k_perform_recall_all[1]  = {{1,1}};
  //const t_minmax_range m_minmax_k_no_addr_conflicts[2]   = {{1,1}, {0,0}};
//`else // `ifndef VCS
  const t_minmax_range m_minmax_k_perform_recall_all[1]  = '{'{m_min_range:1,m_max_range:1}};
  const t_minmax_range m_minmax_k_no_addr_conflicts[2]   = '{'{m_min_range:1,m_max_range:1}, {m_min_range:0,m_max_range:0}};
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
  const t_minmax_range m_minmax_k_perform_recall_all[1]  = {{1,1}};
  const t_minmax_range m_minmax_k_no_addr_conflicts[2]   = {{1,1}, {0,0}};
<% } %>  
  const int            m_weights_k_no_addr_conflicts[2]  = {1, 99};
  const int             m_weights_k_max_num_setaddr[3]   = {70, 25, 5};
<% if(obj.testBench == 'dce') { %>
//`ifndef VCS
//  const t_minmax_range  m_minmax_k_max_num_setaddr[3]    = {{1,1}, {2,5}, {6,10}};
//`else // `ifndef VCS
  const t_minmax_range  m_minmax_k_max_num_setaddr[3]    = '{'{m_min_range:1,m_max_range:1}, {m_min_range:2,m_max_range:5}, {m_min_range:6,m_max_range:10}};
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
  const t_minmax_range  m_minmax_k_max_num_setaddr[3]    = {{1,1}, {2,5}, {6,10}};
<% } %>  

  //in use knobs
  const int            m_weights_k_num_upd_cmds[3]       = {80, 15, 5};
<% if(obj.testBench == 'dce') { %>
//`ifndef VCS
  //const t_minmax_range m_minmax_k_num_upd_cmds[3]        = {{50, 100}, {101, 200}, {201, 300}};
//`else // `ifndef VCS
  const t_minmax_range m_minmax_k_num_upd_cmds[3]        = '{'{m_min_range:50,m_max_range:100}, {m_min_range:101,m_max_range:200}, {m_min_range:201,m_max_range:300}};
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
  const t_minmax_range m_minmax_k_num_upd_cmds[3]        = {{50, 100}, {101, 200}, {201, 300}};
<% } %>  
  
  const int            m_weights_k_num_coh_cmds[3]       = {20, 70, 10};
<% if(obj.testBench == 'dce') { %>
//`ifndef VCS
  //const t_minmax_range m_minmax_k_num_coh_cmds[3]        = {{1000, 2000}, {2001, 5000}, {5001, 10000}};
//`else // `ifndef VCS
  const t_minmax_range m_minmax_k_num_coh_cmds[3]        = '{'{m_min_range:1000,m_max_range:2000}, {m_min_range:2001,m_max_range:5000}, {m_min_range:5001,m_max_range:10000}};
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
  const t_minmax_range m_minmax_k_num_coh_cmds[3]        = {{1000, 2000}, {2001, 5000}, {5001, 10000}};
<% } %>  
  
  const int            m_weights_k_max_num_addr[5]       = {30, 40, 15, 10, 5};
<% if(obj.testBench == 'dce') { %>
//`ifndef VCS
 // const t_minmax_range m_minmax_k_max_num_addr[5]        = {{30, 50}, {51, 70}, {71, 90}, {91, 150}, {151, 200}};
//`else // `ifndef VCS
  const t_minmax_range m_minmax_k_max_num_addr[5]        = '{'{m_min_range:30,m_max_range:50}, {m_min_range:51,m_max_range:70}, {m_min_range:71,m_max_range:90}, {m_min_range:91,m_max_range:150}, {m_min_range:151,m_max_range:200}};
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
  const t_minmax_range m_minmax_k_max_num_addr[5]        = {{30, 50}, {51, 70}, {71, 90}, {91, 150}, {151, 200}};
<% } %>  

  const int            m_weights_k_pck_ch_agent_pct[2]   = {80, 20};
<% if(obj.testBench == 'dce') { %>
//`ifndef VCS
 // const t_minmax_range m_minmax_k_pck_ch_agent_pct[2]    = {{95,70}, {69,50}};
//`else // `ifndef VCS
  const t_minmax_range m_minmax_k_pck_ch_agent_pct[2]    = '{'{m_min_range:95,m_max_range:70}, {m_min_range:69,m_max_range:50}};
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
  const t_minmax_range m_minmax_k_pck_ch_agent_pct[2]    = {{95,70}, {69,50}};
<% } %>  

  // TODO: Below 2 knobs are not used in the code and need to be implemented
  common_knob_class k_num_coh_cmds                       = new("k_num_coh_cmds"       , this , m_weights_k_num_coh_cmds       , m_minmax_k_num_coh_cmds);
  common_knob_class k_num_upd_cmds                       = new("k_num_upd_cmds"       , this , m_weights_k_num_upd_cmds       , m_minmax_k_num_upd_cmds);
  common_knob_class k_perform_recall_all                 = new("k_perform_recall_all" , this , m_weights_k_perform_recall_all , m_minmax_k_perform_recall_all);
  common_knob_class k_no_addr_conflicts                  = new("k_no_addr_conflicts"  , this , m_weights_k_no_addr_conflicts  , m_minmax_k_no_addr_conflicts);
  common_knob_class k_max_num_setaddr                    = new("k_max_num_setaddr"    , this , m_weights_k_max_num_setaddr    , m_minmax_k_max_num_setaddr);
  common_knob_class k_max_num_addr                       = new("k_max_num_addr"       , this , m_weights_k_max_num_addr       , m_minmax_k_max_num_addr);
  common_knob_class k_pck_ch_agent_pct                   = new("k_pck_ch_agent_pct"   , this , m_weights_k_pck_ch_agent_pct   , m_minmax_k_pck_ch_agent_pct);
<% if(obj.testBench == 'dce') { %>
//`ifndef VCS
 // common_knob_class k_silent_pct                         = new("k_silent_pct"         , this , {10, 30, 60} , {{100,71}, {70,31}, {30,0}});
//`else // `ifndef VCS
  common_knob_class k_silent_pct                         = new("k_silent_pct"         , this , {10, 30, 60} ,'{'{m_min_range:100,m_max_range:71}, {m_min_range:70,m_max_range:31}, {m_min_range:30,m_max_range:0}});
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
  common_knob_class k_silent_pct                         = new("k_silent_pct"         , this , {10, 30, 60} , {{100,71}, {70,31}, {30,0}});
<% } %>  
  //TODO: enable in regr 
<% if(obj.testBench == 'dce') { %>
//`ifndef VCS
 // common_knob_class k_exc_pct                            = new("k_exc_pct"            , this , {100}, {{0,0}});
 // common_knob_class k_awunique_pct                       = new("k_awunique_pct"       , this , {50, 50}, {{1,1}, {0,0}});
  //common_knob_class k_slow_dmi_rsp_port                  = new("k_slow_dmi_rsp_port"  , this , {100}, {{0,0}});
  //common_knob_class k_qoscr_event_threshold              = new("k_qoscr_event_threshold", this , {10,10,80}, {{16,16},{0, 0},{1,15}});
  //common_knob_class k_ev_prot_timeout_val		 = new("k_ev_prot_timeout_val", this, {100}, {{4096, 4096}});
  //common_knob_class k_ev_prot_timeout_val		 = new("k_ev_prot_timeout_val", this, {100}, {{1, 4}});
//`else // `ifndef VCS
  common_knob_class k_exc_pct                            = new("k_exc_pct"            , this , {100}, '{'{m_min_range:0,m_max_range:0}});
  common_knob_class k_awunique_pct                       = new("k_awunique_pct"       , this , {50, 50}, '{'{m_min_range:1,m_max_range:1}, {m_min_range:0,m_max_range:0}});
  common_knob_class k_slow_dmi_rsp_port                  = new("k_slow_dmi_rsp_port"  , this , {100}, '{'{m_min_range:0,m_max_range:0}});
  common_knob_class k_qoscr_event_threshold              = new("k_qoscr_event_threshold", this , {10,10,80}, '{'{m_min_range:16,m_max_range:16}, {m_min_range:0,m_max_range:0},{m_min_range:1,m_max_range:15}});
  //common_knob_class k_ev_prot_timeout_val		 = new("k_ev_prot_timeout_val", this, {100}, {{4096, 4096}});
  common_knob_class k_ev_prot_timeout_val		 = new("k_ev_prot_timeout_val", this, {100}, '{'{m_min_range:1,m_max_range:4}});
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
  common_knob_class k_exc_pct                            = new("k_exc_pct"            , this , {100}, {{0,0}});
  common_knob_class k_awunique_pct                       = new("k_awunique_pct"       , this , {50, 50}, {{1,1}, {0,0}});
  common_knob_class k_slow_dmi_rsp_port                  = new("k_slow_dmi_rsp_port"  , this , {100}, {{0,0}});
  common_knob_class k_qoscr_event_threshold              = new("k_qoscr_event_threshold", this , {10,10,80}, {{16,16},{0, 0},{1,15}});
  //common_knob_class k_ev_prot_timeout_val		 = new("k_ev_prot_timeout_val", this, {100}, {{4096, 4096}});
  common_knob_class k_ev_prot_timeout_val		 = new("k_ev_prot_timeout_val", this, {100}, {{1, 4}});
<% } %>  


  function new(string s = "dce_unit_args");
    super.new(s);
    clp = uvm_cmdline_processor::get_inst();
  endfunction: new

  function void set_zero_pct_all_ops();
    //clear update
	//k_upd_pct.set_value(0);

	//clear reads
	k_cmd_rd_vld_pct.set_value(0);
	k_cmd_rd_cln_pct.set_value(0);
	k_cmd_rd_not_shd_pct.set_value(0);
	k_cmd_rd_unq_pct.set_value(0);
	k_cmd_rd_nitc_pct.set_value(0);
	k_cmd_rd_nitc_clninv_pct.set_value(0);
	k_cmd_rd_nitc_mkinv_pct.set_value(0);
	
	//clear writes
	k_cmd_wr_unq_full_pct.set_value(0);
	k_cmd_wr_unq_ptl_pct.set_value(0);
	k_cmd_wr_cln_ptl_pct.set_value(0);
	k_cmd_wr_cln_full_pct.set_value(0);
	k_cmd_wr_bk_ptl_pct.set_value(0);
	k_cmd_wr_bk_full_pct.set_value(0);
	k_cmd_wr_evct_pct.set_value(0);
	
	//clear clean
	k_cmd_cln_unq_pct.set_value(0);
	k_cmd_cln_vld_pct.set_value(0);
	k_cmd_cln_shd_per_pct.set_value(0);
	k_cmd_cln_inv_pct.set_value(0);

	//clear dataless
	k_cmd_evct_pct.set_value(0);
	
	//clear makes
	k_cmd_mk_unq_pct.set_value(0);
	k_cmd_mk_inv_pct.set_value(0);
	
	//clear atomics
	k_cmd_rd_atm_pct.set_value(0);
	k_cmd_wr_atm_pct.set_value(0);
	k_cmd_cmp_atm_pct.set_value(0);
	k_cmd_swp_atm_pct.set_value(0);

	//clear stashing ops
	k_cmd_wr_stsh_full_pct.set_value(0);
    k_cmd_wr_stsh_ptl_pct.set_value(0);
	k_cmd_ldcch_unq_pct.set_value(0);
	k_cmd_ldcch_shd_pct.set_value(0);

  endfunction: set_zero_pct_all_ops

  function void grab_and_parse_args_from_cmdline(ref dce_env_config m_env_cfg);
    string arg_value;
    string myargs[$];

    
	if(clp.get_arg_matches("+en_wr_cln_ptl", myargs)) begin
    	k_cmd_wr_cln_ptl_pct.set_value(100);
	end
 
	if(clp.get_arg_matches("+wr_awunq", myargs)) begin
		set_zero_pct_all_ops();
    		k_cmd_rd_vld_pct.set_value(10);
    		k_cmd_rd_cln_pct.set_value(10);
    		k_cmd_rd_not_shd_pct.set_value(10);
    		k_cmd_rd_unq_pct.set_value(10);
    		k_cmd_wr_unq_ptl_pct.set_value(30);
    		k_cmd_wr_unq_full_pct.set_value(30);
	end 
	
	if(clp.get_arg_matches("+exc_ops_only", myargs)) begin

		set_zero_pct_all_ops();
    	k_cmd_rd_vld_pct.set_value(30);
    	k_cmd_rd_cln_pct.set_value(30);
    	k_cmd_rd_not_shd_pct.set_value(30);
        k_cmd_cln_unq_pct.set_value(40);
        
        k_exc_pct.set_value(100);
	end 

	if(clp.get_arg_matches("+allocops_only", myargs)) begin
		set_zero_pct_all_ops();
        
        //set pct for required ops
    	k_cmd_rd_vld_pct.set_value(20);
    	k_cmd_rd_cln_pct.set_value(20);
    	k_cmd_rd_not_shd_pct.set_value(20);
	end
	if(clp.get_arg_matches("+alloc_ops_w_updreqs", myargs)) begin
		set_zero_pct_all_ops();
        
        //set pct for required ops
    	k_cmd_rd_vld_pct.set_value(20);
    	k_cmd_rd_cln_pct.set_value(20);
    	k_cmd_rd_not_shd_pct.set_value(20);
    	//k_upd_pct.set_value(40);
	end
	if(clp.get_arg_matches("+updreq", myargs)) begin
        //set pct for required ops
    	//k_upd_pct.set_value(30);
	end
	if(clp.get_arg_matches("+ldcchshd", myargs)) begin
		set_zero_pct_all_ops();
    		k_cmd_ldcch_shd_pct.set_value(100);
	end
	if(clp.get_arg_matches("+rdunq", myargs)) begin
		set_zero_pct_all_ops();
    		k_cmd_rd_unq_pct.set_value(100);
	end
	if(clp.get_arg_matches("+non_inv_rds", myargs)) begin
		set_zero_pct_all_ops();
    		k_cmd_rd_vld_pct.set_value(25);
    		k_cmd_rd_cln_pct.set_value(25);
    		k_cmd_rd_not_shd_pct.set_value(25);
    		k_cmd_rd_nitc_pct.set_value(25);
	end
	if(clp.get_arg_matches("+inv_rds", myargs)) begin
		set_zero_pct_all_ops();
        	k_cmd_rd_nitc_clninv_pct.set_value(50);
    		k_cmd_rd_nitc_mkinv_pct.set_value(50);
	end
	if(clp.get_arg_matches("+ldcchunq", myargs)) begin
		set_zero_pct_all_ops();
    		k_cmd_ldcch_unq_pct.set_value(100);
	end
	if(clp.get_arg_matches("+wrstashfull", myargs)) begin
		set_zero_pct_all_ops();
    		k_cmd_wr_stsh_full_pct.set_value(100);
	end
	if(clp.get_arg_matches("+wrstashptl", myargs)) begin
		set_zero_pct_all_ops();
    		k_cmd_wr_stsh_ptl_pct.set_value(100);
	end
	if(clp.get_arg_matches("+wrunqptl", myargs)) begin
		set_zero_pct_all_ops();
    		k_cmd_wr_unq_ptl_pct.set_value(100);
	end
	if(clp.get_arg_matches("+wrunqfull", myargs)) begin
		set_zero_pct_all_ops();
    		k_cmd_wr_unq_full_pct.set_value(100);
	end
	if(clp.get_arg_matches("+stashreq", myargs)) begin
        //set pct for required ops
    	k_cmd_ldcch_unq_pct.set_value(30);
    	k_cmd_ldcch_shd_pct.set_value(30);
    	k_cmd_wr_stsh_full_pct.set_value(30);
    	k_cmd_wr_stsh_ptl_pct.set_value(30);
	end
	if(clp.get_arg_matches("+addr_conflicts", myargs)) begin
        k_no_addr_conflicts.set_value(0);
	end
	if(clp.get_arg_matches("+single_txn", myargs)) begin
    	k_cmd_rd_vld_pct.set_value(100);
    	k_cmd_rd_cln_pct.set_value(100);
    	k_cmd_rd_not_shd_pct.set_value(100);
    	k_cmd_rd_unq_pct.set_value(100);
    	k_cmd_rd_nitc_pct.set_value(100);
        k_cmd_rd_nitc_clninv_pct.set_value(100);
    	k_cmd_rd_nitc_mkinv_pct.set_value(100);
    	k_cmd_wr_unq_full_pct.set_value(100);
    	k_cmd_wr_unq_ptl_pct.set_value(100);
        k_cmd_cln_unq_pct.set_value(100);
        k_cmd_cln_vld_pct.set_value(100);
        k_cmd_cln_shd_per_pct.set_value(100);
        k_cmd_cln_inv_pct.set_value(100);
        k_num_coh_cmds.set_value(1);
	end
	if(clp.get_arg_matches("+allocops_w_stashops", myargs)) begin
		
		set_zero_pct_all_ops();
    	
    	//set pct for required ops , give more weights to allocating ops and less to ops that invalidate
    	k_cmd_rd_vld_pct.set_value(20);
    	k_cmd_rd_cln_pct.set_value(15);
    	k_cmd_rd_not_shd_pct.set_value(10);
    	k_cmd_rd_unq_pct.set_value(5);
    	
    	k_cmd_ldcch_unq_pct.set_value(15);
    	k_cmd_ldcch_shd_pct.set_value(15);
    	k_cmd_wr_stsh_full_pct.set_value(10);
    	k_cmd_wr_stsh_ptl_pct.set_value(10);
	end
	if(clp.get_arg_matches("+reads", myargs)) begin
		
		set_zero_pct_all_ops();
    	
    	//set pct for required ops , give more weights to allocating ops and less to ops that invalidate
    	k_cmd_rd_vld_pct.set_value(20);
    	k_cmd_rd_cln_pct.set_value(20);
    	k_cmd_rd_not_shd_pct.set_value(20);
    	k_cmd_rd_unq_pct.set_value(10);
    	k_cmd_rd_nitc_pct.set_value(10);
        k_cmd_rd_nitc_clninv_pct.set_value(10);
    	k_cmd_rd_nitc_mkinv_pct.set_value(10);
	end
	if(clp.get_arg_matches("+reads_and_writes", myargs)) begin
		
		set_zero_pct_all_ops();
    	
    	//set pct for required ops , give more weights to allocating ops and less to ops that invalidate
    	k_cmd_rd_vld_pct.set_value(20);
    	k_cmd_rd_cln_pct.set_value(20);
    	k_cmd_rd_not_shd_pct.set_value(20);
    	k_cmd_rd_unq_pct.set_value(5);
    	k_cmd_rd_nitc_pct.set_value(10);
        k_cmd_rd_nitc_clninv_pct.set_value(5);
    	k_cmd_rd_nitc_mkinv_pct.set_value(5);
    	
    	k_cmd_wr_unq_full_pct.set_value(10);
    	k_cmd_wr_unq_ptl_pct.set_value(10);
    	k_cmd_wr_bk_full_pct.set_value(10);
    	k_cmd_wr_bk_ptl_pct.set_value(10);
  		k_cmd_wr_cln_ptl_pct.set_value(10);
        k_cmd_wr_cln_full_pct.set_value(10);
    	k_cmd_wr_evct_pct.set_value(10);
	end

	if(clp.get_arg_matches("+atomics", myargs)) begin
		
		set_zero_pct_all_ops();
  		
  		k_cmd_rd_atm_pct.set_value(100);
  		k_cmd_wr_atm_pct.set_value(100);
  		k_cmd_cmp_atm_pct.set_value(100);
  		k_cmd_swp_atm_pct.set_value(100);
	end
	if(clp.get_arg_matches("+cleans", myargs)) begin
		set_zero_pct_all_ops();
        k_cmd_cln_unq_pct.set_value(100);
        k_cmd_cln_vld_pct.set_value(100);
        k_cmd_cln_shd_per_pct.set_value(100);
        k_cmd_cln_inv_pct.set_value(100);
	end
	if(clp.get_arg_matches("+makes", myargs)) begin
		set_zero_pct_all_ops();
        k_cmd_mk_unq_pct.set_value(100);
        k_cmd_mk_inv_pct.set_value(100);
	end
	if(clp.get_arg_matches("+cmos", myargs)) begin
	set_zero_pct_all_ops();
        k_cmd_cln_shd_per_pct.set_value(35);
        k_cmd_cln_vld_pct.set_value(25);
        k_cmd_cln_inv_pct.set_value(20);
        k_cmd_mk_inv_pct.set_value(20);
	end	
	if(clp.get_arg_matches("+writes", myargs)) begin
  		//drive all others to 0
		set_zero_pct_all_ops();
    	
    	k_cmd_wr_unq_full_pct.set_value(10);
    	k_cmd_wr_unq_ptl_pct.set_value(10);
    	k_cmd_wr_bk_full_pct.set_value(10);
    	k_cmd_wr_bk_ptl_pct.set_value(10);
  		k_cmd_wr_cln_ptl_pct.set_value(10);
        k_cmd_wr_cln_full_pct.set_value(10);
    	k_cmd_wr_evct_pct.set_value(10);
	end
	if(clp.get_arg_matches("+wrstshfull_dm_miss", myargs)) begin
        k_no_addr_conflicts.set_value(1);
        k_num_coh_cmds.set_value(1);
        k_num_upd_cmds.set_value(0);

  		//drive all others to 0
		set_zero_pct_all_ops();
  		
  		//set wr stash ops to non-zero
  		k_cmd_wr_stsh_full_pct.set_value(100);
  	end
	if(clp.get_arg_matches("+wrstshfull_dm_hit", myargs)) begin
	    k_pck_ch_agent_pct.set_value(70);
        k_num_coh_cmds.set_value(200);
        k_num_upd_cmds.set_value(0);

  		//drive all others to 0
		set_zero_pct_all_ops();
        
		// Need address conflict to have hit
		k_max_num_addr.set_value(20);
  		
  		//set wr stash ops to non-zero
  		k_cmd_wr_stsh_full_pct.set_value(100);
    	k_cmd_rd_vld_pct.set_value(100);
  	end
	if(clp.get_arg_matches("+wrstshptl_dm_miss", myargs)) begin
        k_no_addr_conflicts.set_value(1);
        k_num_coh_cmds.set_value(1);
        k_num_upd_cmds.set_value(0);

  		//drive all others to 0
		set_zero_pct_all_ops();
  		
  		//set wr stash ops to non-zero
  		k_cmd_wr_stsh_ptl_pct.set_value(100);
  	end
	if(clp.get_arg_matches("+wrstshptl_dm_hit", myargs)) begin
	    k_pck_ch_agent_pct.set_value(70);
        k_num_coh_cmds.set_value(200);
        k_num_upd_cmds.set_value(0);

  		//drive all others to 0
		set_zero_pct_all_ops();
        
		// Need address conflict to have hit
		k_max_num_addr.set_value(20);
  		
  		//set wr stash ops and alloc op rdvld (to load dir) to non-zero
  		k_cmd_wr_stsh_ptl_pct.set_value(100);
    	k_cmd_rd_vld_pct.set_value(100);
  	end
	if(clp.get_arg_matches("+stash_write_bringup", myargs)) begin
	    k_pck_ch_agent_pct.set_value(0);
        k_num_coh_cmds.set_value(5);

  		//drive all others to 0
		set_zero_pct_all_ops();
  		
  		//set wr stash ops to non-zero
  		k_cmd_wr_stsh_ptl_pct.set_value(100);
  		k_cmd_wr_stsh_full_pct.set_value(100);
  	end
	if(clp.get_arg_matches("+ldcchshd_dm_miss", myargs)) begin
        k_no_addr_conflicts.set_value(1);
        k_num_coh_cmds.set_value(10);
        k_num_upd_cmds.set_value(0);

  		//drive all others to 0
		set_zero_pct_all_ops();
  		
  		//set read stash ops to non-zero
  		k_cmd_ldcch_shd_pct.set_value(99);
  		k_cmd_rd_vld_pct.set_value(1);
  	end
    if(clp.get_arg_matches("+ldcchshd_dm_hit", myargs)) begin
        k_pck_ch_agent_pct.set_value(70);
        k_num_coh_cmds.set_value(300);
        k_num_upd_cmds.set_value(0);

        //drive all others to 0
        set_zero_pct_all_ops();
        
        // Need address conflict to have hit
        k_max_num_addr.set_value(25);
        
        //set read stash ops to non-zero
        k_cmd_ldcch_shd_pct.set_value(100);
        k_cmd_rd_vld_pct.set_value(100);
    end

    if(clp.get_arg_matches("+non_allocs", myargs)) begin
	
	set_zero_pct_all_ops();
    	k_cmd_rd_vld_pct.set_value(10);
    	k_cmd_rd_cln_pct.set_value(10);
    	k_cmd_rd_not_shd_pct.set_value(10);
    	k_cmd_rd_nitc_pct.set_value(30);
        k_cmd_rd_nitc_clninv_pct.set_value(30);
    	k_cmd_rd_nitc_mkinv_pct.set_value(30);
	
	
    end

	if(clp.get_arg_matches("+ldcchunq_dm_miss", myargs)) begin
        k_no_addr_conflicts.set_value(1);
        k_num_coh_cmds.set_value(5);
        k_num_upd_cmds.set_value(0);

  		//drive all others to 0
		set_zero_pct_all_ops();
  		
  		//set read stash ops to non-zero
  		k_cmd_ldcch_unq_pct.set_value(100);
  	end
    if(clp.get_arg_matches("+ldcchunq_dm_hit", myargs)) begin
        k_pck_ch_agent_pct.set_value(70);
        k_num_coh_cmds.set_value(200);
        k_num_upd_cmds.set_value(0);

        //drive all others to 0
        set_zero_pct_all_ops();
        
        // Need address conflict to have hit
        k_max_num_addr.set_value(22);
        
        //set read stash ops to non-zero
        k_cmd_ldcch_unq_pct.set_value(100);
        k_cmd_rd_vld_pct.set_value(100);
    end
	
	myargs = '{};

    if (clp.get_arg_matches("+perform_recall_all", myargs))
       k_perform_recall_all.set_value(1'b1);

    if (clp.get_arg_value("+k_dce_scb_en=", arg_value))
      m_env_cfg.set_dce_scb(int'(arg_value.atoi()));
 
    if (clp.get_arg_value("+k_dm_chks_en=", arg_value))
      m_env_cfg.en_dm_chks(int'(arg_value.atoi()));
    
    if (clp.get_arg_value("+k_dm_dbg_en=", arg_value))
      m_env_cfg.en_dm_dbg(int'(arg_value.atoi()));
    
    if (clp.get_arg_value("+k_dv_rec_en=", arg_value))
      m_env_cfg.en_dv_rec = int'(arg_value.atoi());
    
    if (clp.get_arg_value("+k_rl_chks_en=", arg_value))
      m_env_cfg.en_rl_chks = int'(arg_value.atoi());

    if (clp.get_arg_value("+k_up_chks_en=", arg_value))
      m_env_cfg.en_up_chks = int'(arg_value.atoi());

    if (clp.get_arg_value("+k_mpf1_dtr_tgt_id_chks_en=", arg_value))
      m_env_cfg.en_mpf1_tgtid_chks = int'(arg_value.atoi());
    
    if (clp.get_arg_value("+k_functional_cov=", arg_value))
      m_env_cfg.set_fun_cov(int'(arg_value.atoi()));
    
    if (clp.get_arg_value("+k_awunique_pct=", arg_value))
      k_awunique_pct.set_value(int'(arg_value.atoi()));

    m_env_cfg.m_qoscr_event_threshold = k_qoscr_event_threshold.get_value();

   if (clp.get_arg_value("+k_ev_prot_timeout_value=", arg_value))
     k_ev_prot_timeout_val.set_value(int'(arg_value.atoi()));  

     ev_prot_timeout_val = k_ev_prot_timeout_val.get_value();
     m_env_cfg.ev_prot_timeout_val = ev_prot_timeout_val;

  endfunction: grab_and_parse_args_from_cmdline

endclass: dce_unit_args

endpackage: dce_unit_args_pkg
