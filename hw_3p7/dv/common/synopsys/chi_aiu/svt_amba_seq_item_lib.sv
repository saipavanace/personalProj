//=======================================================================
// COPYRIGHT (C) 2013 SYNOPSYS INC.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
// 
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//=======================================================================

/**
 * Abstract:
 * This test 'random_noncoherent_test', is extended from the
 * base test class.
 *
 * In the build_phase phase of the test we will set the necessary test related 
 * information:
 *  - Disable the virtual sequence by assigning the null sequence
 *  - Configure the svt_chi_rn_transaction_random_sequence as the default sequence 
 *  - Configure the Sequence length to 20
 *  - Configure the sequence to inject using non-blocking processes
 */

// Extend the RN transaction to apply a constraint to limit transaction types to
// noncoherent only types 
//=======================================================================

<%
var chi_bfm_types_pkg_prefix = ""
if(obj.testBench == "fsys") {
chi_bfm_types_pkg_prefix = "chiaiu0";
} else {
chi_bfm_types_pkg_prefix = obj.BlockId;
}
%>
 import uvm_pkg::*;
`include "uvm_macros.svh"
`ifdef CHI_UNITS_CNT_NON_ZERO
import  svt_chi_item_helper_pkg::*;
`endif // CHI_UNITS_CNT_NON_ZERO
<% if (obj.testBench == "fsys") { %>
 //`include "chiaiu0_chi_traffic_seq_lib_pkg.sv"
 import sv_assert_pkg::*;
 import addr_trans_mgr_pkg::*;
`ifdef CHI_UNITS_CNT_NON_ZERO
 import chiaiu0_chi_bfm_types_pkg::* ;
`endif // CHI_UNITS_CNT_NON_ZERO
<% } else { %>
 import sv_assert_pkg::*;
 import addr_trans_mgr_pkg::*;
 import <%=obj.BlockId%>_chi_bfm_types_pkg::* ;
<% } %>
`ifdef CHI_UNITS_CNT_NON_ZERO
 import chi_aiu_unit_args_pkg::*;
`endif // CHI_UNITS_CNT_NON_ZERO

 //Helper files
<% if (obj.testBench == "fsys") { %>
`ifdef CHI_UNITS_CNT_NON_ZERO
 import chiaiu0_chi_traffic_seq_lib_pkg::*;
`endif // CHI_UNITS_CNT_NON_ZERO
 //`include "chiaiu0_chi_traffic_helper_structs.svh"
  //Class picks start state depending on the command
 //`include "chiaiu0_chi_rand_start_state.svh"
<% } else { %>
 `include "<%=obj.BlockId%>_chi_traffic_helper_structs.svh"
  //Class picks start state depending on the command
 `include "<%=obj.BlockId%>_chi_rand_start_state.svh"
<% } %>
class rn_noncoherent_transaction extends svt_chi_rn_transaction;
`ifdef CHI_UNITS_CNT_NON_ZERO
<% if (obj.testBench == "fsys") { %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
  <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
  <% if (obj.testBench == "fsys") { %>
  int my_size     = chiaiu0_svt_chi_node_params_pkg::SVT_CHI_NODE_WSIZE;     //3
  int my_be_width = chiaiu0_svt_chi_node_params_pkg::SVT_CHI_NODE_WBE ;  //16
  <% } else { %>
  int my_size = <%=obj.AiuInfo[0].strRtlNamePrefix%>_svt_chi_node_params_pkg::SVT_CHI_NODE_WSIZE%>;
  int my_be_width = <%=obj.AiuInfo[0].strRtlNamePrefix%>_svt_chi_node_params_pkg::SVT_CHI_NODE_WBE%> ; 
  <% } %>
  <% break; } } %>

  int num_bytes = 2^my_size;
<% } %>

  // Only allow noncoherent transactions
  constraint noncoherent_only {
    xact_type inside {  svt_chi_rn_transaction::READNOSNP,
            	    `ifdef SVT_CHI_ISSUE_E_ENABLE
                     	svt_chi_rn_transaction::WRITENOSNPZERO,
            	    `endif
                       svt_chi_rn_transaction::WRITENOSNPPTL,
                       svt_chi_rn_transaction::WRITENOSNPFULL
                     };

    //addr inside {[44'h000_0000_0000:44'h000_FFFF_FFFF]};
  }

  constraint rn_constraints {

  // According to ARM CHI spec. in 2.4.4 (CHI-B) / 2.6.5 (CHI-E) Transaction ordering 
  //  The Order field must only be set to a non-zero value for the following transactions:
  //• ReadNoSnp / ReadNoSnpSep/ ReadOnce/ WriteNoSnp/ WriteNoSnpCMO/ WriteNoSnpZero/ WriteUnique / WriteUniqueCMO/ WriteUniqueZero / Atomic

  // if (xact_type == svt_chi_rn_transaction::READNOSNP)
  //      order_type == svt_chi_transaction::NO_ORDERING_REQUIRED;

    // Constraint the RespErr field to NORMAL_OKAY
    // for both RSP and DAT flits.
    response_resp_err_status == NORMAL_OKAY;
    foreach (data_resp_err_status[index]){
      data_resp_err_status[index] == NORMAL_OKAY;
    }

   <% if (obj.testBench == "fsys") { %>
    if (xact_type == svt_chi_transaction::WRITENOSNPFULL) { 
     byte_enable == ( (1 << 64) -1 - int'(addr%num_bytes)  ); 
     data_size   == svt_chi_transaction::SIZE_64BYTE;
    }   

    snp_attr_is_snoopable == 0;
    solve snp_attr_is_snoopable before snp_attr_snp_domain_type;
   <% } %>

  }

`endif // CHI_UNITS_CNT_NON_ZERO
  `svt_xvm_object_param_utils(rn_noncoherent_transaction)

  function new(string name = "rn_noncoherent_transaction");
    super.new(name);
  endfunction

endclass // rn_noncoherent_transaction

class rn_coherent_transaction extends svt_chi_rn_transaction;

`ifdef CHI_UNITS_CNT_NON_ZERO
  // Only allow coherent transactions
  constraint coherent_only {
    xact_type inside { 
                        svt_chi_rn_transaction::READONCE, 
                        svt_chi_rn_transaction::READCLEAN, 
                        svt_chi_rn_transaction::READSHARED, 
                        svt_chi_rn_transaction::READUNIQUE,
                        svt_chi_rn_transaction::WRITEBACKFULL, 
                        svt_chi_rn_transaction::WRITEBACKPTL, 
                        svt_chi_rn_transaction::WRITECLEANFULL, 
                        svt_chi_rn_transaction::WRITECLEANPTL, 
                        svt_chi_rn_transaction::WRITEEVICTFULL,
                        svt_chi_rn_transaction::WRITEUNIQUEFULL,
                        svt_chi_rn_transaction::WRITEUNIQUEPTL
                     };

                    if ( snp_attr_is_snoopable == 1) {
                     (snp_attr_snp_domain_type == INNER);
                    }

    //addr inside {[44'h000_0000_0000:44'h000_FFFF_FFFF]};
  }

		
`endif // CHI_UNITS_CNT_NON_ZERO
  
  `svt_xvm_object_param_utils(rn_coherent_transaction)

  function new(string name = "rn_coherent_transaction");
    super.new(name);
  endfunction

endclass // rn_coherent_transaction

// `ifndef SVT_CHI_ISSUE_A_ENABLE
class rn_stash_transaction extends svt_chi_rn_transaction;

`ifdef CHI_UNITS_CNT_NON_ZERO
  // Only allow stash transactions
  constraint coherent_only {
    xact_type inside { 
                        svt_chi_rn_transaction::WRITEUNIQUEFULLSTASH, 
                        svt_chi_rn_transaction::WRITEUNIQUEPTLSTASH, 
                        svt_chi_rn_transaction::STASHONCEUNIQUE, 
                        svt_chi_rn_transaction::STASHONCESHARED
                     };

                    if ( snp_attr_is_snoopable == 1) {
                     (snp_attr_snp_domain_type == INNER);
                    }

    //addr inside {[44'h000_0000_0000:44'h000_FFFF_FFFF]};
  }
`endif // CHI_UNITS_CNT_NON_ZERO
  
  `svt_xvm_object_param_utils(rn_stash_transaction)

  function new(string name = "rn_stash_transaction");
    super.new(name);
  endfunction

endclass // rn_stash_transaction

class rn_atomic_transaction extends svt_chi_rn_transaction;

`ifdef CHI_UNITS_CNT_NON_ZERO
  // Only allow atomic transactions
  constraint coherent_only {
    xact_type inside { 
                        svt_chi_rn_transaction::ATOMICSTORE_ADD, 
                        svt_chi_rn_transaction::ATOMICSTORE_CLR, 
                        svt_chi_rn_transaction::ATOMICSTORE_EOR, 
                        svt_chi_rn_transaction::ATOMICSTORE_SET,
                        svt_chi_rn_transaction::ATOMICSTORE_SMAX, 
                        svt_chi_rn_transaction::ATOMICSTORE_SMIN, 
                        svt_chi_rn_transaction::ATOMICSTORE_UMAX, 
                        svt_chi_rn_transaction::ATOMICSTORE_UMIN, 
                        svt_chi_rn_transaction::ATOMICLOAD_ADD, 
                        svt_chi_rn_transaction::ATOMICLOAD_CLR, 
                        svt_chi_rn_transaction::ATOMICLOAD_EOR, 
                        svt_chi_rn_transaction::ATOMICLOAD_SET,
                        svt_chi_rn_transaction::ATOMICLOAD_SMAX, 
                        svt_chi_rn_transaction::ATOMICLOAD_SMIN, 
                        svt_chi_rn_transaction::ATOMICLOAD_UMAX, 
                        svt_chi_rn_transaction::ATOMICLOAD_UMIN, 
                        svt_chi_rn_transaction::ATOMICSWAP, 
                        svt_chi_rn_transaction::ATOMICCOMPARE
                     };

                    if ( snp_attr_is_snoopable == 1) {
                     (snp_attr_snp_domain_type == INNER);
                    }

    //addr inside {[44'h000_0000_0000:44'h000_FFFF_FFFF]};
  }
`endif // CHI_UNITS_CNT_NON_ZERO
  
  `svt_xvm_object_param_utils(rn_atomic_transaction)

  function new(string name = "rn_atomic_transaction");
    super.new(name);
  endfunction

endclass // rn_atomic_transaction

// `endif // SVT_CHI_ISSUE_A_ENABLE

//this class is  for constraints. it will get_value of knob vale like
//done in inhouse chi_seq
//Class has all required fields to generate constrain randomized
//CHI read, CHI dataless, CHI write, CHI Atomic and other requests

class svt_chi_item extends svt_chi_rn_transaction; 
`ifdef CHI_UNITS_CNT_NON_ZERO
<% if (obj.testBench == "fsys") { %>   
//`include "chiaiu0_chi_traffic_helper_structs.svh"
//`include "chiaiu0_chi_rand_start_state.svh"
<% } else { %>
`include "<%=obj.BlockId%>_chi_traffic_helper_structs.svh"
<% } %>

    typedef enum {
      DMI, DII
    } ncore_unit_type_enum;

   //factory rgistration
   `svt_xvm_object_param_utils(svt_chi_item)
    
   //common_knob_list m_common_knob_list = common_knob_list::get_instance();

   static bit same_addr_test;
   static bit use_same_dvm_addr;
   static bit use_atomic;
   static bit coh_concurrent;
   static bit overlapping;
   static bit atomic_cfg_45;
   static bit add_selfid_rd;
   static bit [(`SVT_CHI_MAX_ADDR_WIDTH-1):0] same_dvm_addr = 0;
   static chi_aiu_unit_args    m_args;
   bit k_directed_test;
   int wr_dat_cancel_pct;
   int k_wr_nosnp_full_clnshr;
   int k_wr_nosnp_full_clninv;
   int k_wr_nosnp_full_clnshrpersep;
   int k_wr_back_full_clnshr;
   int k_wr_back_full_clninv;
   int k_wr_cln_full_clnshr;
   int k_wr_back_full_clnshrpersep;
   int k_wr_cln_full_clnshrpersep;
   int m_is_wrdata_cancel_vld_snps;
   int k_wr_nosnp_full_clnshr_snps;
   int k_wr_nosnp_full_clninv_snps;
   int k_wr_nosnp_full_clnshrpersep_snps;
   int k_wr_back_full_clnshr_snps;
   int k_wr_back_full_clninv_snps;
   int k_wr_cln_full_clnshr_snps;
   int k_wr_back_full_clnshrpersep_snps;
   int k_wr_cln_full_clnshrpersep_snps;
   int chi_e_bringup_temp;
   int fnmem_region_idx;
   bit unsupported_atomic_txn_to_dii;
   bit illegal_dii_access_check;
   bit all_dmi_non_coh_cmd_type;
   bit dii_non_coh_cmd_type;
   <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_rand_txn_t   m_rand_type;
   bit		       start_ix;
   bit		       force_cleanuniq;
   bit		       unmapped_addr_access_test;
   bit		       user_addr_for_csr;
   bit		       connectivity_test;
   static bit          user_addr;
   bit constraint_en_c_start_state;
   bit [2:0] boot_sysco_st;
   bit [2:0] sysco_test;

  static addrMgrConst::addrq user_addrq[];
  static int 		      user_addrq_idx[];
  static addrMgrConst::addrq user_write_addrq[];
  static int 		      user_write_addrq_idx[];
  static addrMgrConst::addrq user_read_addrq[];
  static int 		      user_read_addrq_idx[];
  static int txn_counter;
  rand int unsigned addr_zero_bits;
   
   //Random Proerties
   rand int                        m_tgtid;
   rand <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_opcode_type_t      m_opcode_type;
   rand <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_opcode_t           m_opcode;
   rand <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_addr_format_t      m_addr_type;
   rand bit                        m_new_addr;
   bit                             m_new_addr_tmp;
<% if (obj.testBench == "fsys") { %>   
   static bit                             m_boot_addr;
<% } else { %>
   bit                             m_boot_addr;
<% } %>
   bit                             m_excl_txn;
   bit                             m_excl_noncoh_txn;
   rand int                        m_qos;
   rand int  unsigned              dmi_memory_domain_index;
   rand int  unsigned              dii_memory_domain_index;
   rand ncore_unit_type_enum       ncore_unit_type;
   
   //Memory attributes
   rand <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_memory_target_t    m_mem_type;
   rand bit                        m_ewa;
   rand bit                        m_snpattr;
   rand bit                        m_snoopme;
   rand bit                        m_lpid;
   bit                             scm_bckpressure_test;
   bit                             ncbwrdatacompack_resp;
   bit                             force_exp_compack;
   bit                             illegal_csr_format_uncrr_snps;
   bit                             pick_boundary_addr_snps;
   bit                             wrtcmo_data_zero;
   bit                             align_unalign_addr;
   int                             align_unalign_addr_wgt;
   bit [addrMgrConst::W_SEC_ADDR -1:0] pick_soft_addr;

   <%=chi_bfm_types_pkg_prefix%>_chi_traffic_seq_lib_pkg::chi_req_size_t                  m_size;
   <%=chi_bfm_types_pkg_prefix%>_chi_traffic_seq_lib_pkg::chi_req_compack_t               m_expcompack;
   <%=chi_bfm_types_pkg_prefix%>_chi_traffic_seq_lib_pkg::chi_req_cacheable_alloc_t       m_cacheable_alloc;
   <%=chi_bfm_types_pkg_prefix%>_chi_traffic_seq_lib_pkg::chi_req_likelyshared_t          m_likelyshared;
   <%=chi_bfm_types_pkg_prefix%>_chi_traffic_seq_lib_pkg::chi_req_excl_t                  m_excl;
   <%=chi_bfm_types_pkg_prefix%>_chi_traffic_seq_lib_pkg::chi_req_order_t                 m_order;
   <%=chi_bfm_types_pkg_prefix%>_chi_traffic_seq_lib_pkg::chi_rand_start_state            m_rand_start_st;
   rand <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_cache_state_t           m_start_state;
   <%=chi_bfm_types_pkg_prefix%>_chi_traffic_seq_lib_pkg::chi_dvm_addr_data_t             m_dvm_addr_data;

   //Address Manager handle
   addr_trans_mgr m_addr_mgr;
   int chi_data_flit_data_err;

  // don't use CSR addr range 
  constraint c_no_csr_addr {
   if(!(add_selfid_rd ==1 || unsupported_atomic_txn_to_dii ==1))
     !( addr inside {[addrMgrConst::NRS_REGION_BASE:addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE-1]});
  }
   //constrained either for COH or NON-COH address
   constraint svt_chi_item_c_addr_type {
      
<% if (obj.testBench != "fsys") { %>
      if ((add_selfid_rd == 1) && (txn_counter == 0)) {
              m_addr_type ==  <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::NON_COH_ADDR;
      }else{
      m_addr_type dist {
         <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::COH_ADDR     := m_args.k_coh_addr_pct.get_value(),
         <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::NON_COH_ADDR := m_args.k_noncoh_addr_pct.get_value()
      };
      }
<% } else { %>
      m_addr_type dist {
         <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::COH_ADDR     := m_args.k_coh_addr_pct.get_value(),
         <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::NON_COH_ADDR := m_args.k_noncoh_addr_pct.get_value()
      };
<% } %>
      
<% if (obj.testBench != "fsys") { %>
      if((add_selfid_rd ==1) && (txn_counter == 0)) {
        soft addr == pick_nrs_region_addr();
      }
<% } %>
      if(same_addr_test || user_addr_for_csr || user_addr || pick_boundary_addr_snps) {
        //m_new_addr_tmp  == m_new_addr; 
          
      //soft addr == pick_cacheline(m_new_addr_tmp, m_addr_type);
        //solve m_opcode_type before xact_type;
      }
      solve m_addr_type before addr;
      solve m_addr_type before m_opcode_type;
      solve m_opcode_type before xact_type;
      if(unmapped_addr_access_test == 0 || unsupported_atomic_txn_to_dii == 1) {
         foreach (addrMgrConst::dmi_memory_domain_start_addr[i]) {
          solve m_addr_type before  dmi_memory_domain_index;
          solve m_addr_type before ncore_unit_type;
            }
         foreach (addrMgrConst::dmi_memory_domain_start_addr[i]) {
          solve m_addr_type before  dii_memory_domain_index;
          solve m_addr_type before ncore_unit_type;
            }
      }
     }
    
      `ifdef SVT_CHI_ISSUE_E_ENABLE
           // Waiting for Synospsys VIP to be fixed
           //#Stimulus.CHI.v3.6.NCBWrDataCompAck
      constraint svt_chi_ncbwrdatacompack_resp {
        if(ncbwrdatacompack_resp && cfg.chi_spec_revision > svt_chi_node_configuration::ISSUE_C) {
            is_ncbwrdatacompack_used_for_write_xact == 1;
        }
      }

      constraint svt_chi_exp_comp_ack {
        if(force_exp_compack) {
            exp_comp_ack == 1;
        }
      }
      `endif

     constraint svt_chi_qos {
           if(scm_bckpressure_test) {
                 qos == 6;
            }
     }


   constraint svt_chi_item_c_addr {
      if((unmapped_addr_access_test == 0 && svt_chi_item_helper::dis_addr_range_constraint==0 && user_addr==0 <% if (obj.testBench != "fsys") { %> && (add_selfid_rd == 1) && (txn_counter > 0)<% } %> ) || (unsupported_atomic_txn_to_dii == 1) <% if (obj.testBench != "fsys") { %>||(add_selfid_rd == 0 && unmapped_addr_access_test == 0)<% } %>) {
          if(addrMgrConst::dmi_memory_domain_start_addr.size() > 0) {
            dmi_memory_domain_index < addrMgrConst::dmi_memory_domain_start_addr.size();
          }
          if(addrMgrConst::dii_memory_domain_start_addr.size() > 0) {
            dii_memory_domain_index < addrMgrConst::dii_memory_domain_start_addr.size();
          }
          (m_addr_type==<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::COH_ADDR) -> ncore_unit_type == DMI;
         // (m_addr_type==<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::NON_COH_ADDR) -> ncore_unit_type inside {DMI,DII};
          //(addrMgrConst::dmi_memory_domain_start_addr.size() > 0) -> ncore_unit_type == DMI;
          //(addrMgrConst::dii_memory_domain_start_addr.size() > 0) -> ncore_unit_type == DII;
          if (m_addr_type==<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::NON_COH_ADDR) {
                 if ((addrMgrConst::dmi_memory_domain_start_addr.size() > 0) && (addrMgrConst::dii_memory_domain_start_addr.size() > 0)) {
                      if(unsupported_atomic_txn_to_dii == 0) {
                          if(all_dmi_non_coh_cmd_type == 1) {
                          ncore_unit_type == DMI;
                          } else if(dii_non_coh_cmd_type == 1) {
                          ncore_unit_type == DII;
			  } else {
                              ncore_unit_type inside {DMI,DII};
			  }
                      } else {
                          ncore_unit_type == DII;
                      }
                 }
                 else {
                      if(unsupported_atomic_txn_to_dii == 0) {
                        if ((addrMgrConst::dmi_memory_domain_start_addr.size() > 0) && (addrMgrConst::dii_memory_domain_start_addr.size() == 0)) {
                             ncore_unit_type == DMI;  
                        }   
                        else {
                           ((addrMgrConst::dii_memory_domain_start_addr.size() > 0) && (addrMgrConst::dmi_memory_domain_start_addr.size() == 0)) -> ncore_unit_type == DII;  
                        }
                      } else {
			ncore_unit_type == DII;
                      }
                 }
           }
          if(m_addr_type==<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::COH_ADDR) {
                 if(overlapping){
                 foreach (addrMgrConst::dmi_memory_domain_start_addr[i]) {
                   ((dmi_memory_domain_index == i) && (ncore_unit_type==DMI) && (cfg.enable_domain_based_addr_gen == 0) && (m_opcode_type != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DVM_OPERT_CMD)) ->  addr inside {[addrMgrConst::dmi_memory_domain_start_addr[i]:(addrMgrConst::dmi_memory_domain_start_addr[i]+20)]};
                 }
                }
                else{
                  foreach (addrMgrConst::dmi_memory_domain_start_addr[i]) {
                   ((dmi_memory_domain_index == i) && (ncore_unit_type==DMI) && (cfg.enable_domain_based_addr_gen == 0) && (m_opcode_type != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DVM_OPERT_CMD)) ->  addr inside {[addrMgrConst::dmi_memory_domain_start_addr[i]:(addrMgrConst::dmi_memory_domain_end_addr[i])]};
                 }
                }                 
          } else {
           if(unsupported_atomic_txn_to_dii == 0) {
                  if(overlapping){
                 foreach (addrMgrConst::dmi_memory_domain_start_addr[i]) {
                   ((dmi_memory_domain_index == i) && (ncore_unit_type==DMI) && (cfg.enable_domain_based_addr_gen == 0) && (m_opcode_type != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DVM_OPERT_CMD)) ->  addr inside {[addrMgrConst::dmi_memory_domain_start_addr[i]:(addrMgrConst::dmi_memory_domain_start_addr[i]+10)]};
                 }
                }
                else{
                  foreach (addrMgrConst::dmi_memory_domain_start_addr[i]) {
                   ((dmi_memory_domain_index == i) && (ncore_unit_type==DMI) && (cfg.enable_domain_based_addr_gen == 0) && (m_opcode_type != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DVM_OPERT_CMD)) ->  addr inside {[addrMgrConst::dmi_memory_domain_start_addr[i]:(addrMgrConst::dmi_memory_domain_end_addr[i])]};
                 }
                }                 

                 foreach (addrMgrConst::dii_memory_domain_start_addr[i]) {
                   ((dii_memory_domain_index == i) && (ncore_unit_type==DII) && (cfg.enable_domain_based_addr_gen == 0)) -> addr inside {[addrMgrConst::dii_memory_domain_start_addr[i]:
                                                                       addrMgrConst::dii_memory_domain_end_addr[i]]}; 
                 }
             } else {

                  if((addrMgrConst::dii_memory_domain_start_addr.size() > 0)){
                      if(connectivity_test == 0){
                          foreach (addrMgrConst::dii_memory_domain_start_addr[i]) {
                   	    ((dii_memory_domain_index == i) && (cfg.enable_domain_based_addr_gen == 0)) -> addr inside {[addrMgrConst::dii_memory_domain_start_addr[i]:
                                                                       addrMgrConst::dii_memory_domain_end_addr[i]], [addrMgrConst::NRS_REGION_BASE:addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE-1]}; 
                      }
		      } else {
                          foreach (addrMgrConst::dii_memory_domain_start_addr[i]) {
                   	    ((dii_memory_domain_index == i) && (cfg.enable_domain_based_addr_gen == 0)) -> addr inside {[addrMgrConst::dii_memory_domain_start_addr[i]:
                                                                       addrMgrConst::dii_memory_domain_end_addr[i]]}; 
		      }
		      }
		  } else {
			addr inside {[addrMgrConst::NRS_REGION_BASE:addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE-1]};
		  }
        	  addr != pick_nrs_region_addr();
              }
          }
          
         foreach(addrMgrConst::memregion_boundaries[idx]){
          solve m_opcode_type before addr;
         }
       }
       (data_size==svt_chi_rn_transaction::SIZE_1BYTE  ) ->  addr_zero_bits == 0;
       (data_size==svt_chi_rn_transaction::SIZE_2BYTE  ) ->  addr_zero_bits == 1;
       (data_size==svt_chi_rn_transaction::SIZE_4BYTE  ) ->  addr_zero_bits == 2;
       (data_size==svt_chi_rn_transaction::SIZE_8BYTE  ) ->  addr_zero_bits == 3;
       (data_size==svt_chi_rn_transaction::SIZE_16BYTE ) ->  addr_zero_bits == 4;
       (data_size==svt_chi_rn_transaction::SIZE_32BYTE ) ->  addr_zero_bits == 5;
       (data_size==svt_chi_rn_transaction::SIZE_64BYTE ) ->  addr_zero_bits == 6;
     }

//   <% if (obj.testBench == "chi_aiu") { %>
//  constraint svt_chi_item_expcompack {
//     if (
//         <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
//         (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_CMO_CMD && (m_opcode != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::BFM_CLEANSHARED) && (m_opcode != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::BFM_CLEANINVALID) && (m_opcode != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::BFM_MAKEINVALID)) ||
//        <% } else { %>
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_CMO_CMD ||
//        <% } %>
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_STH_CMD ||
//        (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_UPD_CMD && m_opcode == BFM_EVICT) ||
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NONCOH_CMD ||
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_STHUNQ_CMD ||
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_CPYBCK_CMD ||
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_ST_CMD ||
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_LD_CMD ||
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_SW_CMD ||
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_CM_CMD ||
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DVM_OPERT_CMD ||
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::PRE_FETCH_CMD /* ||
//         m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RQ_LCRDRT_CMD*/) {
      
//       exp_comp_ack == 0;

//     } else if ((m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD) ||
//                (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_UPD_CMD && m_opcode != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::BFM_EVICT )) {
             
//       exp_comp_ack == 0;

//     } else if (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_PRFR_UNQ_CMD){
//       exp_comp_ack == 1;
//     } else {
//       exp_comp_ack == 0;
//     }
//   }

// <% } %>

   constraint svt_chi_item_c_dvm_addr {
     if(use_same_dvm_addr) {
       if(same_dvm_addr!=0) {
         addr == same_dvm_addr;
       }
     }
   }

   //Request new cacheline from address manager
   constraint svt_chi_item_c_new_addr {
      m_new_addr dist {
          1 := m_args.k_new_addr_pct.get_value(),
          0 := 100 - m_args.k_new_addr_pct.get_value()
       };
     }
     
    //constrained based on user provided knobs for 
   //selecting opcode and Address type
   constraint svt_chi_item_c_opcode_type {
      if (m_addr_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::NON_COH_ADDR) {
          if(m_boot_addr /*&& k_directed_test==0*/){
              m_opcode_type dist { 
	          <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_NONCOH_CMD := m_args.k_rd_noncoh_pct.get_value(),
                  <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NONCOH_CMD := m_args.k_wr_noncoh_pct.get_value()
	       };
<% if (obj.testBench != "fsys") { %>
           } else if ((add_selfid_rd == 1) && (txn_counter == 0)) {
              m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_NONCOH_CMD;
<% } %>
          }else{

              if(unsupported_atomic_txn_to_dii) {
                m_opcode_type dist {
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_NONCOH_CMD := m_args.k_rd_noncoh_pct.get_value(),
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NONCOH_CMD := m_args.k_wr_noncoh_pct.get_value(),
                    //DII doesn't support Atomic commands from Chien
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_ST_CMD := m_args.k_atomic_st_pct.get_value(), 
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_LD_CMD := m_args.k_atomic_ld_pct.get_value(),
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_SW_CMD := m_args.k_atomic_sw_pct.get_value(),
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_CM_CMD := m_args.k_atomic_cm_pct.get_value(),
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RQ_LCRDRT_CMD := 0 /*m_args.k_rq_lcrdrt_pct.get_value()*/, 
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::UNSUP_TXN_CMD := 0 /*m_args.k_unsupported_txn_pct.get_value()*/
                };
              } else if(illegal_dii_access_check) {
		m_opcode_type dist {
                    `ifdef SVT_CHI_ISSUE_E_ENABLE
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_PRFR_UNQ_CMD := m_args.k_rd_prfr_unq_pct.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NOSNP_FULL_CMO_CMD  := m_args.k_wr_nosnp_full_cmo.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_BACK_FULL_CMO_CMD  := m_args.k_wr_back_full_cmo.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_CLN_FULL_CMO_CMD  := m_args.k_wr_cln_full_cmo.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_EVICT_OR_EVICT_CMD  := m_args.k_wr_evict_or_evict.get_value(),
                    `endif
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_NONCOH_CMD := m_args.k_rd_noncoh_pct.get_value(),
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NONCOH_CMD := m_args.k_wr_noncoh_pct.get_value()
                };
	      } else {
                m_opcode_type dist {
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_NONCOH_CMD := m_args.k_rd_noncoh_pct.get_value(),
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NONCOH_CMD := m_args.k_wr_noncoh_pct.get_value(),
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_STH_CMD := 0 /*m_args.k_dt_ls_sth_pct.get_value()*/,
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_UPD_CMD := 0 /*m_args.k_dt_ls_upd_pct.get_value()*/,
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_CMO_CMD := 0 /*m_args.k_dt_ls_cmo_pct.get_value()*/,
		    `ifdef SVT_CHI_ISSUE_E_ENABLE
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NOSNP_FULL_CMO_CMD        := m_args.k_wr_nosnp_full_cmo.get_value(),
                    `endif
                    //DII doesn't support Atomic commands from Chien
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_ST_CMD := 0 /*m_args.k_atomic_st_pct.get_value()*/, 
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_LD_CMD := 0 /*m_args.k_atomic_ld_pct.get_value()*/,
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_SW_CMD := 0 /*m_args.k_atomic_sw_pct.get_value()*/,
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_CM_CMD := 0 /*m_args.k_atomic_cm_pct.get_value()*/,
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RQ_LCRDRT_CMD := 0 /*m_args.k_rq_lcrdrt_pct.get_value()*/, 
                    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::UNSUP_TXN_CMD := 0 /*m_args.k_unsupported_txn_pct.get_value()*/
                };
              }
            }
        } 
        else {
	   if(!coh_concurrent){
               if(force_cleanuniq){
	          m_opcode_type dist { <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_UPD_CMD := m_args.k_dt_ls_upd_pct.get_value(), 
				       <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_CPYBCK_CMD := 1
                  };
                }
               else if(m_boot_addr){
      	          m_opcode_type dist { <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD := m_args.k_rd_ldrstr_pct.get_value()};
                }
               else{
                  m_opcode_type dist {
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_RDONCE_CMD := m_args.k_rd_rdonce_pct.get_value(),
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD := m_args.k_rd_ldrstr_pct.get_value(),
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_UPD_CMD := m_args.k_dt_ls_upd_pct.get_value(),
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_CMO_CMD := m_args.k_dt_ls_cmo_pct.get_value(),
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_COHUNQ_CMD := m_args.k_wr_cohunq_pct.get_value(),
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_CPYBCK_CMD := m_args.k_wr_cpybck_pct.get_value(),
                    // `ifndef SVT_CHI_ISSUE_A_ENABLE
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_STH_CMD := m_args.k_dt_ls_sth_pct.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_STHUNQ_CMD := 0, //m_args.k_wr_sthunq_pct.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_ST_CMD := m_args.k_atomic_st_pct.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_LD_CMD := m_args.k_atomic_ld_pct.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_SW_CMD := m_args.k_atomic_sw_pct.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_CM_CMD := m_args.k_atomic_cm_pct.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::PRE_FETCH_CMD := 0 /*m_args.k_pre_fetch_pct.get_value()*/,
                    // `endif // SVT_CHI_ISSUE_A_ENABLE
                    `ifdef SVT_CHI_ISSUE_E_ENABLE
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_PRFR_UNQ_CMD := m_args.k_rd_prfr_unq_pct.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NOSNP_FULL_CMO_CMD  := m_args.k_wr_nosnp_full_cmo.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_BACK_FULL_CMO_CMD  := m_args.k_wr_back_full_cmo.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_CLN_FULL_CMO_CMD  := m_args.k_wr_cln_full_cmo.get_value(),
                        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_EVICT_OR_EVICT_CMD  := m_args.k_wr_evict_or_evict.get_value(),
                    `endif
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DVM_OPERT_CMD := m_args.k_dvm_opert_pct.get_value(),
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RQ_LCRDRT_CMD := 0 /*m_args.k_rq_lcrdrt_pct.get_value()*/,
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::UNSUP_TXN_CMD := 0 /*m_args.k_unsupported_txn_pct.get_value()*/
                 };
               }
              }
	    else{
               m_opcode_type dist {
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_RDONCE_CMD := m_args.k_rd_rdonce_pct.get_value(),
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD := m_args.k_rd_ldrstr_pct.get_value(),
                     <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_CMO_CMD := m_args.k_dt_ls_cmo_pct.get_value()
                     //<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_ST_CMD := m_args.k_atomic_st_pct.get_value(),
                     //<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_LD_CMD := m_args.k_atomic_ld_pct.get_value(),
                     //<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_SW_CMD := m_args.k_atomic_sw_pct.get_value(),
                     //<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_CM_CMD := m_args.k_atomic_cm_pct.get_value()
                     };
	    }
        }
    } 
    
     constraint svt_chi_item_c_opcode {  
             (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NONCOH_CMD /*&& k_directed_test==0*/) ->
                 xact_type inside { 
            	    `ifdef SVT_CHI_ISSUE_E_ENABLE
                     	svt_chi_rn_transaction::WRITENOSNPZERO,
            	    `endif
                     	svt_chi_rn_transaction::WRITENOSNPFULL,
                     	svt_chi_rn_transaction::WRITENOSNPPTL 
                  };
              
             (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_COHUNQ_CMD) -> 
                  xact_type inside { 
            	    `ifdef SVT_CHI_ISSUE_E_ENABLE
                        svt_chi_rn_transaction::WRITEUNIQUEZERO,
            	    `endif
                        svt_chi_rn_transaction::WRITEUNIQUEFULL,
                        svt_chi_rn_transaction::WRITEUNIQUEPTL
                     };

// `ifndef SVT_CHI_ISSUE_A_ENABLE
             (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_STHUNQ_CMD) -> 
                 xact_type inside { 
                        svt_chi_rn_transaction::WRITEUNIQUEFULLSTASH,
                        svt_chi_rn_transaction::WRITEUNIQUEPTLSTASH
                     };
// `endif // SVT_CHI_ISSUE_A_ENABLE
                  
             (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_CPYBCK_CMD) -> 
                 xact_type inside { 
                        svt_chi_rn_transaction::WRITEBACKFULL, 
                        svt_chi_rn_transaction::WRITEBACKPTL, 
                        svt_chi_rn_transaction::WRITECLEANFULL, 
                        svt_chi_rn_transaction::WRITECLEANPTL, 
                        svt_chi_rn_transaction::WRITEEVICTFULL
                     };

             (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_NONCOH_CMD /*&& k_directed_test==0*/) -> xact_type == svt_chi_rn_transaction::READNOSNP;
           if (cfg.chi_spec_revision == svt_chi_node_configuration::ISSUE_A) {
             (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_RDONCE_CMD) -> xact_type inside {
                            svt_chi_rn_transaction::READONCE};
           } 
// `ifndef SVT_CHI_ISSUE_A_ENABLE
           else {
                  if(!coh_concurrent){
                     (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_RDONCE_CMD /*&& k_directed_test==0*/) -> xact_type inside {
                      svt_chi_rn_transaction::READONCE, svt_chi_rn_transaction::READONCECLEANINVALID, svt_chi_rn_transaction::READONCEMAKEINVALID};
                  }
                  else {
                       (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_RDONCE_CMD ) -> xact_type inside {
                        svt_chi_rn_transaction::READONCECLEANINVALID, svt_chi_rn_transaction::READONCEMAKEINVALID};
                  }
                 } 
            `ifdef SVT_CHI_ISSUE_E_ENABLE
                m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_PRFR_UNQ_CMD -> xact_type == svt_chi_rn_transaction::READPREFERUNIQUE ;
                m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_EVICT_OR_EVICT_CMD -> xact_type == svt_chi_rn_transaction::WRITEEVICTOREVICT ;
		(m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NOSNP_FULL_CMO_CMD ) -> 
		    xact_type inside {
                 	    svt_chi_rn_transaction::WRITENOSNPFULL_CLEANSHARED, 
			    svt_chi_rn_transaction::WRITENOSNPFULL_CLEANINVALID, 
			    svt_chi_rn_transaction::WRITENOSNPFULL_CLEANSHAREDPERSISTSEP
		    };

		(m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_BACK_FULL_CMO_CMD ) -> 
		    xact_type inside {
                 	    svt_chi_rn_transaction::WRITEBACKFULL_CLEANSHARED, 
			    svt_chi_rn_transaction::WRITEBACKFULL_CLEANINVALID,
			    svt_chi_rn_transaction::WRITEBACKFULL_CLEANSHAREDPERSISTSEP
		    };

		(m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_CLN_FULL_CMO_CMD ) -> 
		    xact_type inside {
                 	    svt_chi_rn_transaction::WRITECLEANFULL_CLEANSHARED, 
			    svt_chi_rn_transaction::WRITECLEANFULL_CLEANSHAREDPERSISTSEP
		    };
            `endif

// `endif // SVT_CHI_ISSUE_A_ENABLE
                      
                          if(m_boot_addr){
                           	(m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD) -> xact_type inside {
                            	svt_chi_rn_transaction::READSHARED,  svt_chi_rn_transaction::READUNIQUE};
                          }else{
                             if(m_excl_txn){
                           	(m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD) -> xact_type inside {
                            	svt_chi_rn_transaction::READSHARED};
                             }else{
                              if (cfg.chi_spec_revision == svt_chi_node_configuration::ISSUE_A) {
                              (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD) -> xact_type inside {
                               svt_chi_rn_transaction::READSHARED, svt_chi_rn_transaction::READCLEAN, svt_chi_rn_transaction::READUNIQUE};
                              } 
// `ifndef SVT_CHI_ISSUE_A_ENABLE
                              else { 
                               if(!coh_concurrent){
                                  (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD) -> xact_type inside {
                                  svt_chi_rn_transaction::READSHARED, svt_chi_rn_transaction::READCLEAN, svt_chi_rn_transaction::READUNIQUE, svt_chi_rn_transaction::READNOTSHAREDDIRTY};
                                }
                                else{
                                   (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD) -> xact_type inside {svt_chi_rn_transaction::READNOTSHAREDDIRTY};
                                }
                              } 
// `endif // SVT_CHI_ISSUE_A_ENABLE
                             }
               }

// `ifndef SVT_CHI_ISSUE_A_ENABLE
               (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_LD_CMD) -> xact_type inside {
                        svt_chi_rn_transaction::ATOMICLOAD_ADD, 
                        svt_chi_rn_transaction::ATOMICLOAD_CLR, 
                        svt_chi_rn_transaction::ATOMICLOAD_EOR, 
                        svt_chi_rn_transaction::ATOMICLOAD_SET,
                        svt_chi_rn_transaction::ATOMICLOAD_SMAX, 
                        svt_chi_rn_transaction::ATOMICLOAD_SMIN, 
                        svt_chi_rn_transaction::ATOMICLOAD_UMAX, 
                        svt_chi_rn_transaction::ATOMICLOAD_UMIN 
               };
    
               (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_ST_CMD) -> xact_type inside {
                       svt_chi_rn_transaction::ATOMICSTORE_ADD, 
                       svt_chi_rn_transaction::ATOMICSTORE_CLR, 
                       svt_chi_rn_transaction::ATOMICSTORE_EOR, 
                       svt_chi_rn_transaction::ATOMICSTORE_SET,
                       svt_chi_rn_transaction::ATOMICSTORE_SMAX, 
                       svt_chi_rn_transaction::ATOMICSTORE_SMIN, 
                       svt_chi_rn_transaction::ATOMICSTORE_UMAX, 
                       svt_chi_rn_transaction::ATOMICSTORE_UMIN 
               };

               (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_SW_CMD) -> xact_type == svt_chi_rn_transaction::ATOMICSWAP;
               (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_CM_CMD) -> xact_type == svt_chi_rn_transaction::ATOMICCOMPARE;
// `endif // SVT_CHI_ISSUE_A_ENABLE
               
               (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_UPD_CMD) -> if(force_cleanuniq) 
                                                     xact_type inside {
                                                       svt_chi_rn_transaction::CLEANUNIQUE, 
                                                       svt_chi_rn_transaction::EVICT 
                                                     };
						   else	if(m_excl_txn)
						     xact_type == svt_chi_rn_transaction::CLEANUNIQUE;
                                                   else  
                                                     xact_type inside {
                                                       svt_chi_rn_transaction::CLEANUNIQUE, 
                                                       svt_chi_rn_transaction::EVICT, 
                                                       svt_chi_rn_transaction::MAKEUNIQUE 
                                                     };
           if (cfg.chi_spec_revision == svt_chi_node_configuration::ISSUE_A) {
               (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_CMO_CMD) -> xact_type inside {
                 svt_chi_rn_transaction::CLEANSHARED, 
                 svt_chi_rn_transaction::CLEANINVALID, 
                 svt_chi_rn_transaction::MAKEINVALID};
           } 
// `ifndef SVT_CHI_ISSUE_A_ENABLE
           else { 
                if(!coh_concurrent){
                  (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_CMO_CMD) -> xact_type inside {
            `ifdef SVT_CHI_ISSUE_E_ENABLE
                  svt_chi_rn_transaction::CLEANSHAREDPERSISTSEP,
            `endif
                  svt_chi_rn_transaction::CLEANSHARED,
                  svt_chi_rn_transaction::CLEANSHAREDPERSIST,
                  svt_chi_rn_transaction::CLEANINVALID,
                  svt_chi_rn_transaction::MAKEINVALID
                  };
                 }
                else {
                 (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_CMO_CMD) -> xact_type inside {
            `ifdef SVT_CHI_ISSUE_E_ENABLE
                  svt_chi_rn_transaction::CLEANSHAREDPERSISTSEP,
            `endif
                  svt_chi_rn_transaction::CLEANSHAREDPERSIST
                  };
                 }
                }
// `endif // SVT_CHI_ISSUE_A_ENABLE

// `ifndef SVT_CHI_ISSUE_A_ENABLE
               (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_STH_CMD) -> xact_type inside {
                 svt_chi_rn_transaction::STASHONCEUNIQUE, 
                 svt_chi_rn_transaction::STASHONCESHARED};
// `endif // SVT_CHI_ISSUE_A_ENABLE

               (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DVM_OPERT_CMD) -> xact_type == svt_chi_rn_transaction::DVMOP;


               //if(
               //(m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_CPYBCK_CMD) || (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_STHUNQ_CMD) || (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_COHUNQ_CMD) ||
               //(m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_RDONCE_CMD) || (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD)
               //) { 
                 if ( snp_attr_is_snoopable == 1) {
                  (snp_attr_snp_domain_type == INNER);
                 }
               //}

        <% if(obj.testBench != "fsys") { %>
            if((unsupported_atomic_txn_to_dii == 0) && (( m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DVM_OPERT_CMD))) { 
                 if ( snp_attr_is_snoopable == 0) {
                  (snp_attr_snp_domain_type == INNER);
                  (mem_attr_is_early_wr_ack_allowed == 0);
                 }
               }
        <% } %>


// `ifndef SVT_CHI_ISSUE_A_ENABLE
               if((unsupported_atomic_txn_to_dii == 0) &&
               ((m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_ST_CMD) || (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_LD_CMD) || (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_SW_CMD) ||
               (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_CM_CMD))
               ) { 
                 if ( snp_attr_is_snoopable == 1) {
                  (snp_attr_snp_domain_type == INNER);
                 }
               }

// `endif // SVT_CHI_ISSUE_A_ENABLE

      }

// `ifndef SVT_CHI_ISSUE_A_ENABLE
      constraint svt_chi_opcode_type_wise_c {
               if(
               (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_UPD_CMD) || (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_CMO_CMD) || (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_STH_CMD)
               ) { 
                 (stash_nid_valid == 1) -> stash_nid inside {addrMgrConst::aiu_nids};
               }
      }
// `endif // SVT_CHI_ISSUE_A_ENABLE
`ifdef SVT_CHI_ISSUE_E_ENABLE
   constraint svt_chi_item_cmo_memattr_snpattr_likelyshared_order {
	if(m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NOSNP_FULL_CMO_CMD) {
	({mem_attr_mem_type,mem_attr_allocate_hint,mem_attr_is_cacheable,mem_attr_is_early_wr_ack_allowed,snp_attr_snp_domain_type,snp_attr_is_snoopable,is_likely_shared,order_type} inside {9'h103, 9'h123, 9'h120, 9'h122, 9'h000, 9'h002, 9'h020, 9'h022, 9'h060, 9'h062, 9'h0e0, 9'h0e2, 9'h068, 9'h06a, 9'h06c, 9'h06e, 9'h0e8, 9'h0ea, 9'h0ec, 9'h0ee, 9'h078, 9'h07a, 9'h07c, 9'h07e, 9'h0f8, 9'h0fa, 9'h0fc, 9'h0fe});
	   }
        }
 `endif

<% if (obj.testBench != "fsys") { %>
   constraint svt_chi_item_c_rd_size {
    if ((xact_type == svt_chi_transaction::READNOSNP) && ((add_selfid_rd == 1) && (txn_counter == 0))) { 
     if(illegal_csr_format_uncrr_snps==1){
     data_size   == svt_chi_transaction::SIZE_64BYTE;
     order_type == svt_chi_transaction::REQ_ORDERING_REQUIRED;
     mem_attr_mem_type ==svt_chi_rn_transaction::NORMAL;
     } else{
     data_size   == svt_chi_transaction::SIZE_4BYTE;
     order_type == svt_chi_transaction::REQ_EP_ORDERING_REQUIRED;
     mem_attr_mem_type ==svt_chi_rn_transaction::DEVICE;
     }
    }
   }
<% } %>

constraint c_start_state {
  if(constraint_en_c_start_state == 1) { //Don't have much idea about this constraints
    if (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_RDONCE_CMD) {
      if(start_ix){
	    m_start_state == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX;
      }else{
        m_start_state inside {<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_UCE };
      }

    } else if (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD) {
      if(start_ix){
	m_start_state == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX;
      }else{
	(xact_type inside {svt_chi_rn_transaction::READSHARED, svt_chi_rn_transaction::READCLEAN}) -> m_start_state inside{<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_UCE};
      	(xact_type inside {svt_chi_rn_transaction::READUNIQUE}) -> m_start_state inside{<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_SC, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_SD};
      }
    } else if (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_UPD_CMD) {
      (xact_type  == svt_chi_rn_transaction::EVICT) -> m_start_state  == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_UC;
      if(start_ix && (xact_type == svt_chi_rn_transaction::CLEANUNIQUE || xact_type == svt_chi_rn_transaction::MAKEUNIQUE)){
	m_start_state == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX;
      }else{
      	(xact_type == svt_chi_rn_transaction::CLEANUNIQUE || xact_type == svt_chi_rn_transaction::MAKEUNIQUE) ->
        	m_start_state inside {<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_SC, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_SD};
	}

    } else if (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_CMO_CMD) {
      if(start_ix){
	m_start_state == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX;
      }else{
        if (cfg.chi_spec_revision == svt_chi_node_configuration::ISSUE_A) {
      	(xact_type == svt_chi_rn_transaction::CLEANSHARED) ->
         	m_start_state inside {<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_SC};
        } 
// `ifndef SVT_CHI_ISSUE_A_ENABLE
        else { 
      	(xact_type == svt_chi_rn_transaction::CLEANSHARED || xact_type == svt_chi_rn_transaction::CLEANSHAREDPERSIST) ->
         	m_start_state inside {<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_SC};
        }
// `endif // SVT_CHI_ISSUE_A_ENABLE
      }
      (xact_type == svt_chi_rn_transaction::CLEANINVALID || xact_type == svt_chi_rn_transaction::MAKEINVALID) ->
         m_start_state == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX;

    } else if (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_COHUNQ_CMD) {
         (xact_type inside {svt_chi_rn_transaction::WRITEUNIQUEFULL,svt_chi_rn_transaction::WRITEUNIQUEPTL}) -> 
         m_start_state inside
           {<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX};

    } else if (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_CPYBCK_CMD) {
      (xact_type == svt_chi_rn_transaction::WRITEBACKFULL || xact_type == svt_chi_rn_transaction::WRITECLEANFULL) ->
         m_start_state inside {<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_UD, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_SD};
      if(start_ix && (xact_type == svt_chi_rn_transaction::WRITEBACKPTL  || xact_type == svt_chi_rn_transaction::WRITECLEANPTL)){
	m_start_state == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX;
      }else{
      	(xact_type == svt_chi_rn_transaction::WRITEBACKPTL  || xact_type == svt_chi_rn_transaction::WRITECLEANPTL)  ->
         	m_start_state inside {<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_UDP};
      }
      (xact_type == svt_chi_rn_transaction::WRITEEVICTFULL) -> m_start_state == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_UC;

    } else if (m_opcode_type ==<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_ST_CMD || 
               m_opcode_type ==<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_LD_CMD ||
               m_opcode_type ==<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_SW_CMD ||
               m_opcode_type ==<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_CM_CMD)   {
      	if(start_ix){
		m_start_state == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX;
      	}else{
        	m_start_state dist {
          	<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX  := 40,
          	<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_SC  := 10,
          	<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_SD  := 10,
          	<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_UC  := 10,
          	<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_UCE := 10,
          	<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_UD  := 10,
          	<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_UDP := 10
        	};
	}
    } else {
      m_start_state == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CHI_IX;
      //Need to add support for below senarios
      //(m_opcode_type == PRE_FETCH_CMD) -> 
    }
  }
}

constraint rn_data_err_constraints {
if ( (chi_data_flit_data_err > 0) && (
     (xact_type == WRITEBACKFULL) ||
     (xact_type == WRITEBACKPTL) ||
     (xact_type == WRITECLEANFULL) ||
     (xact_type == WRITECLEANPTL) ||
     (xact_type == WRITENOSNPFULL) ||
     (xact_type == WRITENOSNPPTL) ||
     (xact_type == WRITEUNIQUEFULL) ||
    //  `ifndef SVT_CHI_ISSUE_A_ENABLE
     (xact_type == WRITEUNIQUEFULLSTASH) ||
     (xact_type == WRITEUNIQUEPTLSTASH) ||
    //  `endif
     `ifdef SVT_CHI_ISSUE_E_ENABLE
     (xact_type == WRITEEVICTOREVICT) ||
     (xact_type == WRITENOSNPFULL_CLEANSHARED) ||
     (xact_type == WRITENOSNPFULL_CLEANINVALID) ||
     (xact_type == WRITENOSNPFULL_CLEANSHAREDPERSISTSEP) ||
     (xact_type == WRITEBACKFULL_CLEANINVALID) ||
     (xact_type == WRITEBACKFULL_CLEANSHARED) ||
     (xact_type == WRITECLEANFULL_CLEANSHARED) ||
     (xact_type == WRITEBACKFULL_CLEANSHAREDPERSISTSEP) ||
     (xact_type == WRITECLEANFULL_CLEANSHAREDPERSISTSEP) ||
     `SVT_CHI_IS_NON_COHERENT_COMBINED_NCBWRITE_CMO || 
     `SVT_CHI_IS_COHERENT_COMBINED_NCBWRITE_CMO || 
     `SVT_CHI_IS_COHERENT_COMBINED_CBWRITE_CMO || 
     `endif
     (xact_type == WRITEUNIQUEPTL) ||
     (xact_type == WRITEEVICTFULL)
   )){
     foreach (data_resp_err_status[index]) {data_resp_err_status[index] dist {DATA_ERROR := (100-chi_data_flit_data_err), NORMAL_OKAY := chi_data_flit_data_err};}
    // foreach (data_resp_err_status[index]) {data_resp_err_status[index] dist {DATA_ERROR := 100};}
     }
 if ( (chi_data_flit_data_err == 0) && (
     (xact_type == WRITEBACKFULL) ||
     (xact_type == WRITEBACKPTL) ||
     (xact_type == WRITECLEANFULL) ||
     (xact_type == WRITECLEANPTL) ||
     (xact_type == WRITENOSNPFULL) ||
     (xact_type == WRITENOSNPPTL) ||
     (xact_type == WRITEUNIQUEFULL) ||
    //  `ifndef SVT_CHI_ISSUE_A_ENABLE
     (xact_type == WRITEUNIQUEFULLSTASH) ||
     (xact_type == WRITEUNIQUEPTLSTASH) ||
    //  `endif
     `ifdef SVT_CHI_ISSUE_E_ENABLE
     (xact_type == WRITEEVICTOREVICT) ||
     `SVT_CHI_IS_NON_COHERENT_COMBINED_NCBWRITE_CMO || 
     `SVT_CHI_IS_COHERENT_COMBINED_NCBWRITE_CMO || 
     `SVT_CHI_IS_COHERENT_COMBINED_CBWRITE_CMO || 
     `endif
     (xact_type == WRITEUNIQUEPTL) ||
     (xact_type == WRITEEVICTFULL) ||
     (xact_type == DVMOP)

   )){
     foreach (data_resp_err_status[index]) {data_resp_err_status[index] inside {NORMAL_OKAY};}
     }
   }
     //constraint svt_chi_item_c_resp_err {
     //       response_resp_err_status != svt_chi_rn_transaction::NON_DATA_ERROR;
     //       response_resp_err_status != svt_chi_rn_transaction::DATA_ERROR;
     //       }
    
     
      constraint c_snp_attr  {
               snp_attr_is_snoopable dist {
                   0 := m_args.k_noncoh_addr_pct.get_value(),
                   1 := m_args.k_coh_addr_pct.get_value()
                   };
        }
      //Request target to either Device or Normal Memory
      constraint c_mem_type {
            if(addrMgrConst::dii_memory_domain_start_addr.size() > 0 || (m_boot_addr) || ((add_selfid_rd == 1'h1) && (txn_counter == 0))) {  
               (m_addr_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::NON_COH_ADDR) -> svt_chi_rn_transaction::mem_attr_mem_type dist {
                   NORMAL := 100 - m_args.k_device_type_mem_pct.get_value(),
                   DEVICE := m_args.k_device_type_mem_pct.get_value()
                   };
            } else {
	    	svt_chi_rn_transaction::mem_attr_mem_type == NORMAL;
	    }
           (m_addr_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::COH_ADDR) -> svt_chi_rn_transaction::mem_attr_mem_type == NORMAL;
        <% if (obj.testBench == "fsys") { %> 
            if(svt_chi_item_helper::dis_addr_range_constraint==1) { // dis_addr_range_constraint is set to 1 during ncore space register configuration 
              svt_chi_rn_transaction::mem_attr_mem_type == DEVICE;
            }
        <% } %>
        }

      constraint svt_chi_c_endianness {
        endian == svt_chi_rn_transaction::LITTLE_ENDIAN;
      }

`ifdef SVT_CHI_ISSUE_B_ENABLE
      constraint is_writedatacancel_valid {
        if ((svt_chi_rn_transaction::xact_type == WRITENOSNPPTL && svt_chi_rn_transaction::mem_attr_mem_type == NORMAL) ||
            (svt_chi_rn_transaction::xact_type == WRITEUNIQUEPTL) || (svt_chi_rn_transaction::xact_type == WRITEUNIQUEPTLSTASH))
     {
         is_writedatacancel_used_for_write_xact dist {
                 1 := m_is_wrdata_cancel_vld_snps,
                 0 := 100 - m_is_wrdata_cancel_vld_snps
         };
     }
       else {
        is_writedatacancel_used_for_write_xact == 1'b0;
        }
     }
`endif


      /*
      //CHI Spec Ch 2.9.3 Pg 92
      constraint c_ewa_type {
        (m_opcode_type == RD_RDONCE_CMD || m_opcode_type == RD_LDRSTR_CMD ||
         m_opcode_type == DT_LS_UPD_CMD || m_opcode_type == DT_LS_CMO_CMD ||
         m_opcode_type == DT_LS_STH_CMD ||
         m_opcode_type == WR_STHUNQ_CMD || m_opcode_type == WR_CPYBCK_CMD) ->
         m_ewa == 1;

        (m_opcode_type == DVM_OPERT_CMD || m_opcode_type == RQ_LCRDRT_CMD) ->
         m_ewa == 0;
       } */ // given variable is-> mem_attr_is_early_wr_ack_allowed  

      /* //CHI SPEC Ch 2.9.6 Pg 98
      constraint c_snp_attr {
        (m_opcode_type == RD_NONCOH_CMD || m_opcode_type == WR_NONCOH_CMD) ->
            m_snpattr == 0;
        (m_opcode_type == RD_RDONCE_CMD || m_opcode_type == RD_LDRSTR_CMD ||
         m_opcode_type == DT_LS_UPD_CMD || m_opcode_type == DT_LS_STH_CMD ||
         m_opcode_type == WR_COHUNQ_CMD || m_opcode_type == WR_STHUNQ_CMD ||
         m_opcode_type == WR_CPYBCK_CMD || m_opcode_type == DVM_OPERT_CMD ||
         m_opcode_type == RQ_LCRDRT_CMD) -> 
         m_snpattr == 1;
       }*/ // NEED TO ADD LOGIC FOR SYNPS -> snp_attr_is_snoopable


`endif // CHI_UNITS_CNT_NON_ZERO
   //Methods
   extern function new(string name = "svt_chi_item");
   extern function void print ();
`ifdef CHI_UNITS_CNT_NON_ZERO
   extern function void get_cmd_args(const ref chi_aiu_unit_args args);
   extern function void pre_randomize();
   extern function void post_randomize();
   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] pick_atomic_addr();
   extern function bit check_addr_in_gpa (bit [`SVT_CHI_MAX_ADDR_WIDTH-1:0] addr);
   extern function bit [`SVT_CHI_MAX_ADDR_WIDTH-1:0] get_addr_in_gpa (bit [`SVT_CHI_MAX_ADDR_WIDTH-1:0] tmp_inp_addr);
   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] pick_cacheline(bit m_new_addr, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_addr_format_t m_addr_type_tmp);
   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] pick_nrs_region_addr();
   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] aligned64B_addr(bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] addr);

   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] get_device_mem_addr(bit req_new_addr);
   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] get_boot_mem_addr(bit req_new_addr);
   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] get_boot_noncoh_mem_addr(bit req_new_addr);
   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] get_boot_coh_mem_addr(bit req_new_addr);
   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] get_normal_noncoh_mem_addr(bit req_new_addr);
   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] get_normal_coh_mem_addr(bit req_new_addr);
   extern function bit get_normal_local_cache_addr(
    input <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_cache_state_t st, 
    output bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] addr);

   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] get_write_user_addrq_addr();
   extern function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] get_read_user_addrq_addr();
   //extern function <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_cache_state_t select_initial_cache_state(svt_chi_transaction::xact_type_enum m_xact_type,<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_opcode_type_t opcode_type,bit start_ix); 
   
   // newperf_test to allow loop. hence we are able to manage hit & miss
   int use_loop_addr; // nbr of addr before loop
   int use_loop_addr_offset; // addr_offset = nbr of miss
`endif // CHI_UNITS_CNT_NON_ZERO
    
    
   

endclass // svt_chi_item

   
   function svt_chi_item::new(string name = "svt_chi_item");
`ifdef CHI_UNITS_CNT_NON_ZERO
     svt_chi_rn_transaction::cache_state_enum f;
     addrMgrConst::addr_format_t af;
`endif // CHI_UNITS_CNT_NON_ZERO
     super.new(name);
     if ($test$plusargs("chi_intf_b2b")) begin
         SHORT_DELAY_wt = 0;
         LONG_DELAY_wt = 0;
         MIN_DELAY_wt = 100;
     end
     //reasonable_txdatflitv_delay.constraint_mode(0);
`ifdef CHI_UNITS_CNT_NON_ZERO
     if ($test$plusargs("scm_bckpressure_test")) begin
         scm_bckpressure_test = 1;
     end
     if ($test$plusargs("wrtcmo_data_zero")) begin
         wrtcmo_data_zero = 1;
     end
     if ($test$plusargs("align_unalign_addr")) begin
         align_unalign_addr = 1;
     end
          
     void'($value$plusargs("same_addr_test=%0d",same_addr_test));
     void'($value$plusargs("use_user_addrq=%0d",user_addr));
     void'($value$plusargs("chi_data_flit_data_err=%0d",chi_data_flit_data_err));
     void'($value$plusargs("align_unalign_addr=%0d",align_unalign_addr_wgt));
     if($test$plusargs("boot_sysco_st")) begin
       sysco_test = 1;
       $display($time, "SVT_CHI_SEQ_ITEM_LIB : sysco_test_enabled");
     end
     if($test$plusargs("use_atomic")) begin
       use_atomic = 1;
     end
     if($test$plusargs("atomic_cfg_45")) begin
        atomic_cfg_45 = 1;
     end

<% if (obj.testBench != "fsys") { %>
     if($test$plusargs("add_selfid_rd")) begin
        add_selfid_rd = 1;
        compack_follows_readreceipt = 0;
        `uvm_info(get_name(),$psprintf("here_selfid_val = %0d",add_selfid_rd),UVM_NONE)
     end
<% } %>

     if($test$plusargs("coh_concurrent")) begin
        coh_concurrent = 1;
     end

     if($test$plusargs("overlapping")) begin
        overlapping = 1;
     end

     if($test$plusargs("use_same_dvm_addr")) begin
       use_same_dvm_addr = 1;
     end
     if($test$plusargs("unsupported_atomic_txn_to_dii")) begin
       unsupported_atomic_txn_to_dii = 1;
     end
     if($test$plusargs("illegal_dii_access_check")) begin
       illegal_dii_access_check = 1;
     end
     if($test$plusargs("connectivity_test")) begin
       connectivity_test = 1;
     end
     if($test$plusargs("all_dmi_non_coh_cmd_type")) begin
       all_dmi_non_coh_cmd_type = 1;
     end
     if($test$plusargs("dii_non_coh_cmd_type")) begin
       dii_non_coh_cmd_type = 1;
     end
<% if(obj.testBench != "fsys") { %>
     if($test$plusargs("use_copyback")) begin
       force_cleanuniq = 1;
       $display($time, "SVT_CHI_SEQ_ITEM_LIB : use_copyback_enabled");
     end
<%} %>
     if($test$plusargs("unmapped_add_enabled")) begin
       unmapped_addr_access_test = 1;
       $display($time, "SVT_CHI_SEQ_ITEM_LIB : unmapped_test_is_enabled");
     end
     if($test$plusargs("user_addr_for_csr")) begin
       user_addr_for_csr = 1;
       $display($time, "SVT_CHI_SEQ_ITEM_LIB : user_addr_for_csr_test_is_enabled");
     end

     if(!$value$plusargs("k_directed_test=%d",k_directed_test))begin
       k_directed_test = 0;
    end

     if($test$plusargs("illegal_csr_format_uncrr")) begin
       illegal_csr_format_uncrr_snps=1 ;
     end
 
     if ($test$plusargs("pick_boundary_addr")) begin
       pick_boundary_addr_snps=1 ;
     end
 
     if ($value$plusargs("wr_dat_cancel_pct=%d",wr_dat_cancel_pct)) begin
       m_is_wrdata_cancel_vld_snps=wr_dat_cancel_pct ;
     end

     if ($test$plusargs("chi_e_bringup_temp")) begin
       chi_e_bringup_temp = 1 ;
     end

     if ($test$plusargs("ncbwrdatacompack_resp")) begin
       ncbwrdatacompack_resp = 1 ;
     end
     if ($test$plusargs("force_exp_compack")) begin
       force_exp_compack = 1 ;
     end
     if ($value$plusargs("k_wr_nosnp_full_clnshr=%d",k_wr_nosnp_full_clnshr)) begin
       k_wr_nosnp_full_clnshr_snps=k_wr_nosnp_full_clnshr ;
     end

     if ($value$plusargs("k_wr_nosnp_full_clninv=%d",k_wr_nosnp_full_clninv)) begin
       k_wr_nosnp_full_clninv_snps=k_wr_nosnp_full_clninv ;
     end

     if ($value$plusargs("k_wr_nosnp_full_clnshrpersep=%d",k_wr_nosnp_full_clnshrpersep)) begin
       k_wr_nosnp_full_clnshrpersep_snps=k_wr_nosnp_full_clnshrpersep ;
     end 
     if ($value$plusargs("k_wr_back_full_clnshr=%d",k_wr_back_full_clnshr)) begin
       k_wr_back_full_clnshr_snps=k_wr_back_full_clnshr ;
     end
     if ($value$plusargs("k_wr_back_full_clninv=%d",k_wr_back_full_clninv)) begin
       k_wr_back_full_clninv_snps=k_wr_back_full_clninv ;
     end
     if ($value$plusargs("k_wr_cln_full_clnshr=%d",k_wr_cln_full_clnshr)) begin
       k_wr_cln_full_clnshr_snps=k_wr_cln_full_clnshr ;
     end
     if ($value$plusargs("k_wr_back_full_clnshrpersep=%d",k_wr_back_full_clnshrpersep)) begin
       k_wr_back_full_clnshrpersep_snps=k_wr_back_full_clnshrpersep ;
     end
     if ($value$plusargs("k_wr_cln_full_clnshrpersep=%d",k_wr_cln_full_clnshrpersep)) begin
       k_wr_cln_full_clnshrpersep_snps=k_wr_cln_full_clnshrpersep ;
     end

 

     m_rand_type       = <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::CMD_BASED;
     m_size            = new("chi_req_size_t");
     m_expcompack      = new("chi_req_compack_t");
     m_cacheable_alloc = new("chi_req_cacheable_alloc_t");
     m_likelyshared    = new("chi_req_likelyshared_t");
     m_order           = new("chi_req_order_t");
     m_rand_start_st   = new("chi_rand_start_state");
	 //select_initial_cache_state_h = new("select_initial_cache_state");
     m_dvm_addr_data   = new("chi_req_dvm_addr_data");
     m_excl            = new("chi_req_excl");
     m_boot_addr       = 0;
     m_excl_txn        = 0;
     m_excl_noncoh_txn    = 0;
     if(user_addrq_idx.size()<=0) 
       user_addrq_idx = new[af.num()];
     if(user_write_addrq_idx.size()<=0) 
       user_write_addrq_idx = new[af.num()];
     if(user_read_addrq_idx.size()<=0) 
       user_read_addrq_idx = new[af.num()];
     if(user_addrq.size()<=0) 
       user_addrq = new[af.num()];
     if(user_write_addrq.size()<=0) 
       user_write_addrq = new[af.num()];
     if(user_read_addrq.size()<=0) 
       user_read_addrq = new[af.num()];
     if($test$plusargs("use_seq_user_addrq")) begin
       foreach (user_addrq_idx[i])
         user_addrq_idx[i] = 0;
       foreach (user_write_addrq_idx[i])
         user_write_addrq_idx[i] = 0;
       foreach (user_read_addrq_idx[i])
         user_read_addrq_idx[i] = 0;
     end else begin
       foreach (user_addrq_idx[i])
         user_addrq_idx[i] = -1;
       foreach (user_write_addrq_idx[i])
         user_write_addrq_idx[i] = -1;
       foreach (user_read_addrq_idx[i])
         user_read_addrq_idx[i] = -1;
     end
     m_addr_mgr = addr_trans_mgr::get_instance();
`endif // CHI_UNITS_CNT_NON_ZERO
   endfunction

   function void svt_chi_item::print ();

`ifdef CHI_UNITS_CNT_NON_ZERO
      `uvm_info(get_name(),$psprintf("value of k_dt_ls_upd_pct = %0d",m_args.k_dt_ls_upd_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_dt_ls_cmo_pct = %0d",m_args.k_dt_ls_cmo_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_pre_fetch_pct = %0d",m_args.k_pre_fetch_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_wr_cpybck_pct = %0d",m_args.k_wr_cpybck_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_dt_ls_sth_pct = %0d",m_args.k_dt_ls_sth_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_wr_sthunq_pct = %0d",m_args.k_wr_sthunq_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_atomic_st_pct = %0d",m_args.k_atomic_st_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_atomic_ld_pct = %0d",m_args.k_atomic_ld_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_atomic_sw_pct = %0d",m_args.k_atomic_sw_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_atomic_cm_pct = %0d",m_args.k_atomic_cm_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_rd_noncoh_pct = %0d",m_args.k_rd_noncoh_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_rd_ldrstr_pct = %0d",m_args.k_rd_ldrstr_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_rd_rdonce_pct = %0d",m_args.k_rd_rdonce_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_wr_noncoh_pct = %0d",m_args.k_wr_noncoh_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_wr_cohunq_pct = %0d",m_args.k_wr_cohunq_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_wr_nosnp_full_cmo = %0d",m_args.k_wr_nosnp_full_cmo.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_wr_back_full_cmo = %0d",m_args.k_wr_back_full_cmo.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_wr_cln_full_cmo = %0d",m_args.k_wr_cln_full_cmo.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_wr_evict_or_evict = %0d",m_args.k_wr_evict_or_evict.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_coh_addr_pct = %0d",m_args.k_coh_addr_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_noncoh_addr_pct = %0d",m_args.k_noncoh_addr_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_device_type_mem_pct = %0d",m_args.k_device_type_mem_pct.get_value()),UVM_NONE)
      `uvm_info(get_name(),$psprintf("value of k_dvm_opert_pct = %0d",m_args.k_dvm_opert_pct.get_value()),UVM_NONE)
    
`endif // CHI_UNITS_CNT_NON_ZERO

   endfunction: print

`ifdef CHI_UNITS_CNT_NON_ZERO
   function void svt_chi_item::get_cmd_args(const ref chi_aiu_unit_args args);
    m_args = args;
   endfunction: get_cmd_args

   function void svt_chi_item::pre_randomize();
    super.pre_randomize();
    `ASSERT(m_args != null);
     if (!$test$plusargs("unsupported_txn")) begin
       m_args.k_unsupported_txn_pct.set_value(0);
     end
    
    //TODO: remove eventually when fullsys tests enable the excl txns
     if (!$test$plusargs("en_excl_txn") && !$test$plusargs("en_excl_noncoh_txn")) begin
       m_args.k_excl_txn_pct.set_value(0);
     end
     `uvm_info(get_name(),$psprintf("svt_chi_item::pre_randomize, dis_addr_range_constraint %0d user_addr %0d unmapped_addr_access_test %0d",svt_chi_item_helper::dis_addr_range_constraint,user_addr,unmapped_addr_access_test),UVM_DEBUG)

   endfunction: pre_randomize

   function void svt_chi_item::post_randomize();

if(align_unalign_addr) begin
       randcase
                align_unalign_addr_wgt :begin
		                        addr_zero_bits = 0;
                                        end
                (100-align_unalign_addr_wgt): begin
                                              end
        endcase
end

  if(unmapped_addr_access_test != 0 && addrMgrConst::map_addr2dmi_or_dii(addr, fnmem_region_idx) != -1) begin
    if(addrMgrConst::is_dii_addr(addr) == 1) begin
      snp_attr_is_snoopable = 0;
      m_addr_type =  <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::NON_COH_ADDR;
      ncore_unit_type = DII;
      xact_type = svt_chi_rn_transaction::READNOSNP;
      mem_attr_mem_type = svt_chi_rn_transaction::NORMAL;
      mem_attr_allocate_hint = 0;
      mem_attr_is_cacheable = 0;
      mem_attr_is_early_wr_ack_allowed = 0;
      is_likely_shared = 0;
      stash_nid_valid = 0;
      order_type = svt_chi_transaction::NO_ORDERING_REQUIRED;
      stash_nid = 1'b0;
      stash_lpid_valid = 1'b0;
      stash_lpid = 1'b0;
      snoopme = 1'b0;
      `ifdef SVT_CHI_ISSUE_E_ENABLE
        is_ncbwrdatacompack_used_for_write_xact = 1'b0;
        deep = 1'b0;
        groupid_ext = 0;
      `endif // `ifdef SVT_CHI_ISSUE_E_ENABLE
    end
  end
	

if(wrtcmo_data_zero ==1) begin 
         if((m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NOSNP_FULL_CMO_CMD) || (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_BACK_FULL_CMO_CMD) || (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_CLN_FULL_CMO_CMD)|| (m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DT_LS_UPD_CMD))begin
              data = 0;
         end
end

<% if (obj.testBench == "fsys") { %>
if( svt_chi_item_helper::dis_addr_range_constraint==0)begin
<% } else { %>
if((!add_selfid_rd) || ((add_selfid_rd == 1) && (txn_counter > 0)))begin
<% } %>
 if((m_opcode_type != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DVM_OPERT_CMD) || (m_opcode_type != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RQ_LCRDRT_CMD)) begin
       for(int i=0;i<addr_zero_bits;i++)
         addr[i] = 1'b0; // CCMP only supports 2Size bytes of aligned accesses, where Size = 0, 1, 2, 3, etc., up to a CG
    end
    if(scm_bckpressure_test == 1 && !$test$plusargs("dmi_state_fcov") && !$test$plusargs("dce_state_fcov")) begin
         addr[6] = 1'b0;
    end
 end
 
 if(same_addr_test || user_addr_for_csr || user_addr || pick_boundary_addr_snps)begin 
    addr = pick_cacheline(m_new_addr, m_addr_type);
 end
  if(atomic_cfg_45)begin
    if(use_atomic )begin
          addr = pick_atomic_addr();
    end 
  end
    `uvm_info(get_name(),$psprintf("svt_chi_item::post_randomize addr 'h%0h dmi_memory_domain_index %0d dii_memory_domain_index %0d ncore_unit_type %0s xact_type %0s start_ix %0d, force_cleanuniq %0d, m_tgtid %0d, m_opcode_type %0s, m_opcode %0s, m_addr_type %0s, m_new_addr %0d, m_boot_addr %0d,m_excl_txn %0d, m_excl_noncoh_txn %0d, m_qos %0d, m_mem_type %0s, m_ewa %0d, m_snpattr %0d, m_snoopme %0d, m_lpid %0d data_size %0s addr_zero_bits %0d qos %0d endian %0d stash nid valid %0d",addr,dmi_memory_domain_index,dii_memory_domain_index,ncore_unit_type.name,xact_type.name,start_ix, force_cleanuniq, m_tgtid, m_opcode_type, m_opcode, m_addr_type, m_new_addr, m_boot_addr,m_excl_txn, m_excl_noncoh_txn, m_qos, m_mem_type, m_ewa, m_snpattr, m_snoopme, m_lpid,data_size.name,addr_zero_bits,qos,endian, stash_nid_valid),UVM_NONE)
     //foreach(addrMgrConst::dmi_memory_domain_start_addr[i])
     //  `uvm_info(get_name(),$psprintf("%0d dmi_memory_domain_start_addr %0h dmi_memory_domain_end_addr %0h",i,addrMgrConst::dmi_memory_domain_start_addr[i],addrMgrConst::dmi_memory_domain_end_addr[i]),UVM_DEBUG)
     //foreach(addrMgrConst::dmi_memory_domain_start_addr[i])
     //  `uvm_info(get_name(),$psprintf("%0d dii_memory_domain_start_addr %0h dii_memory_domain_end_addr %0h",i,addrMgrConst::dii_memory_domain_start_addr[i],addrMgrConst::dii_memory_domain_end_addr[i]),UVM_DEBUG)
     super.post_randomize();
     if(m_opcode_type==<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DVM_OPERT_CMD && use_same_dvm_addr) begin
       if(same_dvm_addr==0) begin
         same_dvm_addr = addr;
       end
       //`uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,post_randomize: DVM addr %0h", addr), UVM_DEBUG)
     end
     //`uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,post_randomize: same_dvm_addr %0h use_same_dvm_addr %0b m_opcode_type %0h",same_dvm_addr, use_same_dvm_addr,m_opcode_type.name), UVM_DEBUG)
     txn_counter = txn_counter + 1;
     `uvm_info("svt_chi_item::",$psprintf("txn_counter %0d",txn_counter),UVM_NONE)

 if (m_opcode_type inside {<%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_LD_CMD, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_ST_CMD, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_CM_CMD, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_SW_CMD} &&
    $test$plusargs("force_coh_atomic")) begin
        snp_attr_is_snoopable = 1;
        mem_attr_is_cacheable = 1;
        mem_attr_is_early_wr_ack_allowed = 1;
 end

  if (svt_chi_rn_transaction::mem_attr_mem_type == DEVICE && (m_opcode_type != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::DVM_OPERT_CMD) && (m_opcode_type != <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RQ_LCRDRT_CMD))begin
     addr[5:0] =0;
  end

   endfunction:post_randomize

   function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::pick_atomic_addr();
     bit [addrMgrConst::W_SEC_ADDR -1:0] t_addr;
     bit [addrMgrConst::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1;
     enum {dmi0,dmi1} state;
     std::randomize(state); 

     m_addr_mgr.get_dmi_unit_addr_range(start_addr0,end_addr0,start_addr1,end_addr1);
     if(state==dmi0)begin
       std::randomize(t_addr)with{t_addr inside {[start_addr0:end_addr0]};};
      // `uvm_info("svt_chi_item::",$psprintf("dmi0 ADDR:%0h",t_addr),UVM_DEBUG)
     end
     else begin
       std::randomize(t_addr)with{t_addr inside {[start_addr1:end_addr1]};};
      // `uvm_info("svt_chi_item::",$psprintf("dmi1 ADDR:%0h",t_addr),UVM_DEBUG)
     end
    
    return t_addr; 
    
   endfunction

  function bit svt_chi_item::check_addr_in_gpa(bit [`SVT_CHI_MAX_ADDR_WIDTH-1:0] addr);

    bit mapped_addr_gpa;
    mapped_addr_gpa = 0;

    foreach(addrMgrConst::memregion_boundaries[idx]) begin
        if (addr inside {[addrMgrConst::memregion_boundaries[idx].start_addr[addrMgrConst::ADDR_WIDTH - 1 : 0] : (addrMgrConst::memregion_boundaries[idx].end_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]-1)]} ) begin
            mapped_addr_gpa = 1;
        end
    end
    return mapped_addr_gpa;
  endfunction: check_addr_in_gpa

  function bit [`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::get_addr_in_gpa(input bit [`SVT_CHI_MAX_ADDR_WIDTH-1:0] tmp_inp_addr);

     bit [`SVT_CHI_MAX_ADDR_WIDTH-1:0] tmp_op_addr;
     bit[2:0] sel_boundary_addr ;
     bit mapped_addr_in_gpa = 0;
     sel_boundary_addr = $urandom_range(4,1);
     foreach(addrMgrConst::memregion_boundaries[idx]) begin
        if (tmp_inp_addr inside {[addrMgrConst::memregion_boundaries[idx].start_addr[addrMgrConst::ADDR_WIDTH - 1 : 0] : (addrMgrConst::memregion_boundaries[idx].end_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]-1)]} ) begin

          if (sel_boundary_addr == 1) begin
                tmp_op_addr = addrMgrConst::memregion_boundaries[idx].start_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]; 
          end else if (sel_boundary_addr == 2) begin
                tmp_op_addr = addrMgrConst::memregion_boundaries[idx].end_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]-1; 
          end else if (sel_boundary_addr == 3) begin
                tmp_op_addr = addrMgrConst::memregion_boundaries[idx].start_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]-1; 
                mapped_addr_in_gpa = check_addr_in_gpa(tmp_op_addr); 
                if (mapped_addr_in_gpa) begin
                    tmp_op_addr = addrMgrConst::memregion_boundaries[idx].start_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]; 
                end
                if (tmp_op_addr  == 'h0) begin
                    tmp_op_addr = addrMgrConst::memregion_boundaries[idx].start_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]; 
                end
          end else if (sel_boundary_addr == 4) begin
                tmp_op_addr = addrMgrConst::memregion_boundaries[idx].end_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]; 
                mapped_addr_in_gpa = check_addr_in_gpa(tmp_op_addr); 
                if (mapped_addr_in_gpa) begin
                    tmp_op_addr = addrMgrConst::memregion_boundaries[idx].end_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]-1; 
                end
                if (tmp_op_addr  == 'h0) begin
                    tmp_op_addr = addrMgrConst::memregion_boundaries[idx].end_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]-1; 
                end
          end
        end
     end
    
     return tmp_op_addr;

endfunction: get_addr_in_gpa

   function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::pick_cacheline(bit m_new_addr, <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_addr_format_t  m_addr_type_tmp);
   bit [addrMgrConst::W_SEC_ADDR -1:0] t_addr;
   bit [addrMgrConst::W_SEC_ADDR - 1 : 0] tmp_inp_addr;
   bit [addrMgrConst::W_SEC_ADDR - 1 : 0] tmp_out_addr;
   bit [addrMgrConst::W_SEC_ADDR - 1 : 0] random_unmapped_addr;
   <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_addr_format_t      m_addr_type;
     begin 
      //int k_unmapped_add_access_wgt;

      if(m_addr_type_tmp == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::NON_COH_ADDR) begin
        if(0 /*m_boot_addr == 1*/) begin
             t_addr = get_boot_noncoh_mem_addr(m_new_addr);
        end
        
        //else if (0 /*svt_chi_rn_transaction::mem_attr_mem_type == DEVICE*/) begin
        else if (svt_chi_rn_transaction::mem_attr_mem_type == DEVICE) begin
           t_addr = get_device_mem_addr(m_new_addr);
           if(addrMgrConst::NUM_DIIS > 1) begin
            `ASSERT(t_addr != 0);
           end
        end else begin
           t_addr = get_normal_noncoh_mem_addr(m_new_addr);
           if(addrMgrConst::NUM_DIIS > 1) begin
              `ASSERT(t_addr != 0);
           end
        end
      end
      else begin
         `ASSERT(svt_chi_rn_transaction::mem_attr_mem_type == NORMAL);
          if(0 /* m_boot_addr == 1*/ ) begin
            t_addr = get_boot_coh_mem_addr(m_new_addr);
          end
          else if(1 /*svt_chi_rn_transaction::initial_cache_line_state == I*/ ) begin // || user_req.m_new_addr ) begin
            //addr_try_counter = 0;
            //Added a loop to check if the new address already exists in the local cache or not, for CONC-4909
            //do begin 
                if($test$plusargs("perf_test") && $test$plusargs("use_user_addrq") && $test$plusargs("use_user_write_read_addrq")) begin
                    if((m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_COHUNQ_CMD)||(m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::WR_NONCOH_CMD)) begin
                        t_addr = get_write_user_addrq_addr();
                    end
	            else if((m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_RDONCE_CMD)||(m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_LDRSTR_CMD)||(m_opcode_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::RD_NONCOH_CMD)) begin
                       t_addr = get_read_user_addrq_addr();
                    end
	        end
	        else begin	  
                    t_addr = get_normal_coh_mem_addr(1);
                   /* addr_try_counter++;
                    if (addr_try_counter > 10 || $test$plusargs("seq_case")) begin //newperf_test add plusargs
                        `uvm_warning(get_type_name(), $psprintf("Number of tries to get a new address failed for 10 times"));
                        break;
                    end*/
                end // else: !if($test$plusargs("perf_test") && $test$plusargs("use_user_addrq") && $test$plusargs("use_user_write_read_addrq"))
          //end while (aligned64B_addr(t_addr));
          `ASSERT(t_addr != 0);
          //install_cacheline(user_req.m_start_state, t_addr);
          //$display("%t, CHI[%d], 8normal t_addr %x, opocode %s, start state %s", $time, ID, t_addr, user_req.m_opcode.name, user_req.m_start_state.name());
         end else begin
           bit ret;

           ret = get_normal_local_cache_addr(m_start_state, t_addr);
           if (ret) begin
             `ASSERT(t_addr != 0);
           end else begin
             return 0;
           end
         end // else: !if(user_req.m_start_state == CHI_IX || user_req.m_new_addr)
       end // else: !if(user_req.m_addr_type == <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::NON_COH_ADDR)
     end
     if ($test$plusargs("pick_boundary_addr")) begin
         tmp_inp_addr = t_addr; 
         tmp_out_addr = get_addr_in_gpa(tmp_inp_addr);
         t_addr = tmp_out_addr; 
    end
     return t_addr;
 endfunction: pick_cacheline

 function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::pick_nrs_region_addr();

   bit [addrMgrConst::W_SEC_ADDR -1:0] t_addr;
   int csr_addr_offset;
   int boot_addr_offset;

                      // setting csrBaseAddress
    t_addr = addr_trans_mgr_pkg::addrMgrConst::NRS_REGION_BASE ; //  addr = {'h00b9b90, 8'hFF, 12'h000};
    if($test$plusargs("boot_addr_offset")) begin
        t_addr = addr_trans_mgr_pkg::addrMgrConst::BOOT_REGION_BASE ; //  addr = {'h00b9b90, 8'hFF, 12'h000};
    end
    if(!$value$plusargs("csr_addr_offset=%d",csr_addr_offset))
        csr_addr_offset = 0;
    if(!$value$plusargs("boot_addr_offset=%d",boot_addr_offset))
        boot_addr_offset = 0;
    if($test$plusargs("illegal_csr_format_uncrr")) begin
    t_addr[19:0] = csr_addr_offset ? (20'hFF000 + csr_addr_offset + 1) : boot_addr_offset ? (20'h40000 + boot_addr_offset) : 20'hFF000;
      end 
      else begin
       t_addr[19:0] = csr_addr_offset ? (20'hFF000 + csr_addr_offset) : boot_addr_offset ? (20'h40000 + boot_addr_offset) : 20'hFF000;
      end

     return t_addr;

 endfunction: pick_nrs_region_addr



 function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::aligned64B_addr(bit [`SVT_CHI_MAX_ADDR_WIDTH-1:0] addr);
   return ((addr >> 6) << 6);
 endfunction: aligned64B_addr
 
 function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::get_device_mem_addr(bit req_new_addr);
   if (req_new_addr) begin
     ncore_memory_map m_map;
     int q[$];
 
     m_map = m_addr_mgr.get_memory_map_instance();
     q = m_map.get_iocoh_mem_regions();
     `ASSERT(q.size() > 0);
     q.shuffle();  
     return m_addr_mgr.gen_iocoh_addr(svt_chi_rn_transaction::src_id, 1, q[0]);
   end
 
   return m_addr_mgr.get_iocoh_addr(svt_chi_rn_transaction::src_id, 1);
 endfunction: get_device_mem_addr
 
 function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::get_boot_mem_addr(
   bit req_new_addr);
 
    return m_addr_mgr.get_bootreg_addr(svt_chi_rn_transaction::src_id, 1);
 endfunction: get_boot_mem_addr
 
 function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::get_boot_noncoh_mem_addr(
   bit req_new_addr);
    return m_addr_mgr.get_noncohboot_addr(svt_chi_rn_transaction::src_id, 1);
 endfunction: get_boot_noncoh_mem_addr
 
 function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::get_boot_coh_mem_addr(
   bit req_new_addr);
 
   return m_addr_mgr.get_cohboot_addr(svt_chi_rn_transaction::src_id, 1);
 endfunction: get_boot_coh_mem_addr
 
 function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::get_normal_noncoh_mem_addr(bit req_new_addr);
   bit [addrMgrConst::W_SEC_ADDR -1:0] t_addr;
   int 				      pick_itr;
    

   //`uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,get_normal_noncoh_mem_addr: use_user_addrq %0d size %0d",$test$plusargs("use_user_addrq"), user_addrq[addrMgrConst::NONCOH].size()), UVM_MEDIUM)
        if($test$plusargs("user_addr_for_csr")) begin
          user_addrq[addrMgrConst::NONCOH] = addrMgrConst::user_addrq[addrMgrConst::NONCOH];
        end

   if($test$plusargs("use_user_addrq") && (user_addrq[addrMgrConst::NONCOH].size()>0)) begin
      if(user_addrq_idx[addrMgrConst::NONCOH] == -1) begin
         pick_itr = $urandom_range(0, user_addrq[addrMgrConst::NONCOH].size()-1);
         t_addr = user_addrq[addrMgrConst::NONCOH][pick_itr];
      // `uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,get_normal_noncoh_mem_addr: generated user NC-1 address %p", t_addr), UVM_MEDIUM)
      end
      else begin
         t_addr = user_addrq[addrMgrConst::NONCOH][user_addrq_idx[addrMgrConst::NONCOH]];
       //`uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,get_normal_noncoh_mem_addr : generated user NC-2 address %p", t_addr), UVM_MEDIUM)
         if(!$test$plusargs("force_unique_addr")) user_addrq_idx[addrMgrConst::NONCOH] = user_addrq_idx[addrMgrConst::NONCOH] + 1;  //newperf test add plusargs 
         if(user_addrq_idx[addrMgrConst::NONCOH] >= user_addrq[addrMgrConst::NONCOH].size() || (use_loop_addr>0 && user_addrq_idx[addrMgrConst::NONCOH] >= use_loop_addr)) begin
            user_addrq_idx[addrMgrConst::NONCOH] = use_loop_addr_offset;
            use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
            use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
         end
      end
      return t_addr;
   end else begin
      if (req_new_addr) begin
         /**** Don't generate new addr using addr mgr, Use addr generated by synopsys vip ****/
         //
         t_addr = m_addr_mgr.gen_noncoh_addr(src_id, 1);
         user_addrq[addrMgrConst::NONCOH].push_back(t_addr);
         //`uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,get_normal_noncoh_mem_addr : generated user NC-3 address %p", t_addr), UVM_MEDIUM)
         return t_addr;
      end
      /**** Don't generate new addr using addr mgr, Use addr generated by synopsys vip ****/
      //
      t_addr = m_addr_mgr.get_noncoh_addr(src_id, 1);
      user_addrq[addrMgrConst::NONCOH].push_back(t_addr);
      //`uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,get_normal_noncoh_mem_addr : generated user NC-4 address %p", t_addr), UVM_MEDIUM)
      return t_addr;
   end
 endfunction: get_normal_noncoh_mem_addr
 
 function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::get_normal_coh_mem_addr(
 bit req_new_addr);
 bit [addrMgrConst::W_SEC_ADDR -1:0] t_addr;
 int 				      pick_itr;
 
// `uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,get_normal_coh_mem_addr: use_user_addrq %0d size %0d",$test$plusargs("use_user_addrq"), user_addrq[addrMgrConst::COH].size()), UVM_MEDIUM)

        if($test$plusargs("user_addr_for_csr")) begin
          user_addrq[addrMgrConst::COH] = addrMgrConst::user_addrq[addrMgrConst::COH];
        end

   if($test$plusargs("use_user_addrq") && (user_addrq[addrMgrConst::COH].size()>0)) begin
      if(user_addrq_idx[addrMgrConst::COH] == -1) begin
         pick_itr = $urandom_range(0, user_addrq[addrMgrConst::COH].size()-1);
         t_addr = user_addrq[addrMgrConst::COH][pick_itr];
      // `uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,get_normal_coh_mem_addr : generated user C-1 address %p", t_addr), UVM_MEDIUM)
      end
      else begin
         t_addr = user_addrq[addrMgrConst::COH][user_addrq_idx[addrMgrConst::COH]];
      // `uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,get_normal_coh_mem_addr : generated user C-2 address %p", t_addr), UVM_MEDIUM)
 	    if(!$test$plusargs("force_unique_addr")) user_addrq_idx[addrMgrConst::COH] = user_addrq_idx[addrMgrConst::COH] + 1; //newperf test add plusargs
 	    if(user_addrq_idx[addrMgrConst::COH] >= user_addrq[addrMgrConst::COH].size() || (use_loop_addr>0 && user_addrq_idx[addrMgrConst::COH] >= use_loop_addr)) begin
 	       user_addrq_idx[addrMgrConst::COH] = use_loop_addr_offset;
 		   use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
 	       use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
 	    end
      end
      return t_addr;
   end else begin
      if (req_new_addr) begin
        /**** Don't generate new addr using addr mgr, Use addr generated by synopsys vip ****/
        //
        t_addr = m_addr_mgr.gen_coh_addr(src_id, 1);
        user_addrq[addrMgrConst::COH].push_back(t_addr);
       // `uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,get_normal_coh_mem_addr : generated user C-3 address %p", t_addr), UVM_MEDIUM)
        return t_addr;
      end
    
      /**** Don't generate new addr using addr mgr, Use addr generated by synopsys vip ****/
      //
      t_addr = m_addr_mgr.get_coh_addr(src_id, 1);
      user_addrq[addrMgrConst::COH].push_back(t_addr);
      //`uvm_info($sformatf("%m"), $sformatf("svt_chi_item-DEBUG,get_normal_coh_mem_addr : generated user C-4 address %p", t_addr), UVM_MEDIUM)
      return t_addr;
   end
 endfunction: get_normal_coh_mem_addr
 
 function bit svt_chi_item::get_normal_local_cache_addr(
   input <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_cache_state_t st, 
   output bit [`SVT_CHI_MAX_ADDR_WIDTH-1:0] addr);
  /* chi_bfm_cache_state_t c_st;
 
   if (m_installed_cachelines[st].size() > 0) begin
     int pick_itr;
 
     pick_itr = $urandom_range(0, m_installed_cachelines[st].size() - 1);
     addr = m_installed_cachelines[st][pick_itr];
     if(m_chi_cache.exists(aligned64B_addr(addr)))
 	return 0;
     c_st = st.first;
     do
     begin
 	foreach(m_installed_cachelines[c_st][i])
 	begin
 	//$display("%t, 6normal addr %x, state %s pick_itr %x", $time, addr, c_st.name, i);
 		if(m_installed_cachelines[c_st][i] === addr)begin
 			m_installed_cachelines[c_st].delete(i);
 		end
 	end
 	c_st = c_st.next;
     end while(c_st!=c_st.first);
     m_installed_cachelines[st].push_back(addr);
     return 1;
   end

     do
     begin
 	foreach(m_installed_cachelines[c_st][i])
 	begin
 	//`uvm_info(get_type_name(), $psprintf("%t, 6normal addr %x, state %s pick_itr %x", $time, addr, c_st.name, i), UVM_LOW)
 	end
 	c_st = c_st.next;
     end while(c_st!=c_st.first);
 
 	
   return 0;*/
 endfunction: get_normal_local_cache_addr
 

 
 function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::get_write_user_addrq_addr();
   bit [addrMgrConst::W_SEC_ADDR -1:0] addr;
    int 				      pick_itr;
 
   if($test$plusargs("use_user_addrq") && (user_write_addrq[addrMgrConst::COH].size()>0)) begin
      if(user_write_addrq_idx[addrMgrConst::COH] == -1) begin
         pick_itr = $urandom_range(0, user_write_addrq[addrMgrConst::COH].size()-1);
         addr = user_write_addrq[addrMgrConst::COH][pick_itr];
      end
      else begin
         addr = user_write_addrq[addrMgrConst::COH][user_write_addrq_idx[addrMgrConst::COH]];
 	if(!$test$plusargs("force_unique_addr")) user_write_addrq_idx[addrMgrConst::COH] = user_write_addrq_idx[addrMgrConst::COH] + 1; //newperf test add plusargs
 	if(user_write_addrq_idx[addrMgrConst::COH] >= user_write_addrq[addrMgrConst::COH].size() || (use_loop_addr>0 && user_write_addrq_idx[addrMgrConst::COH] >= use_loop_addr)) begin
 	   user_write_addrq_idx[addrMgrConst::COH] = use_loop_addr_offset;
 	   use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
 	   use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
 	end
      end // else: !if(user_write_addrq_idx[addrMgrConst::COH] == -1)
   end						  
   return addr;
 endfunction // get_write_user_addrq_addr
 						  
 function bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] svt_chi_item::get_read_user_addrq_addr();
   bit [addrMgrConst::W_SEC_ADDR -1:0] addr;
    int 				      pick_itr;
 
   if($test$plusargs("use_user_addrq") && (user_read_addrq[addrMgrConst::COH].size()>0)) begin
      if(user_read_addrq_idx[addrMgrConst::COH] == -1) begin
         pick_itr = $urandom_range(0, user_read_addrq[addrMgrConst::COH].size()-1);
         addr = user_read_addrq[addrMgrConst::COH][pick_itr];
      end
      else begin
         addr = user_read_addrq[addrMgrConst::COH][user_read_addrq_idx[addrMgrConst::COH]];
 	if(!$test$plusargs("force_unique_addr")) user_read_addrq_idx[addrMgrConst::COH] = user_read_addrq_idx[addrMgrConst::COH] + 1; //newperf test add plusargs
 	if(user_read_addrq_idx[addrMgrConst::COH] >= user_read_addrq[addrMgrConst::COH].size() || (use_loop_addr>0 && user_read_addrq_idx[addrMgrConst::COH] >= use_loop_addr)) begin
 	   user_read_addrq_idx[addrMgrConst::COH] = use_loop_addr_offset;
 	   use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
 	   use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
 	end
      end // else: !if(user_read_addrq_idx[addrMgrConst::COH] == -1)
   end						  
   return addr;
 endfunction // get_read_user_addrq_addr
`endif // CHI_UNITS_CNT_NON_ZERO


`ifdef CHI_UNITS_CNT_NON_ZERO
// class chi_subsys_item extends svt_chi_rn_transaction; 

//     `svt_xvm_object_utils(chi_subsys_item)

//     static chi_aiu_unit_args    m_args;
//     addr_trans_mgr m_addr_mgr;

//     typedef enum {
//       AIU, DCE, DMI, DII, DVE
//     } unit_t;

//     `ifdef SVT_CHI_ISSUE_E_ENABLE
//         constraint c_unsupported_opcodes {
//             !(svt_chi_rn_transaction::xact_type inside {
//                 READNOSNPSEP
//             });
//         }
//     `endif // `ifdef SVT_CHI_ISSUE_E_ENABLE

//     constraint c_addr_not_in_boot_and_no_exclusives_during_boot {
//         if (svt_chi_item_helper::disable_boot_addr_region) {
//             !(addr inside {[addrMgrConst::NRS_REGION_BASE : (addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE-1)]});
//         } else {
//             is_exclusive == 0;
//         }
//     }

//     //FIXME: move this to a test specific seq_item once we start creating multiple seq items
//     constraint c_force_exp_compack {
//         if (svt_chi_item_helper::exp_compack) {
//             exp_comp_ack == 1;
//         }
//     } 

//     constraint c_force_exclusive {
//         if (svt_chi_item_helper::disable_boot_addr_region) {
//             xact_type == MAKEREADUNIQUE -> is_exclusive == 1;
//             xact_type == READPREFERUNIQUE -> is_exclusive == 1;
//         } else {
//             is_exclusive == 0;
//         }
//     }

//     // Ncore doesnt not support big endian access
//     constraint c_endianess_is_little {
//         endian == svt_chi_rn_transaction::LITTLE_ENDIAN;
//     }

//     // Ncore doesnt support ATOMICS to DII
//     constraint c_no_atomics_to_dii {
//         foreach(addrMgrConst::memregions_info[region]) {
//             (
//                 addrMgrConst::memregions_info[region].hut == DII
//                 && (addr >= addrMgrConst::memregions_info[region].start_addr)
//                 && (addr <= addrMgrConst::memregions_info[region].end_addr)
//             ) -> !( xact_type inside {
//                 ATOMICSTORE_ADD, ATOMICSTORE_CLR, ATOMICSTORE_EOR, ATOMICSTORE_SET, ATOMICSTORE_SMAX, ATOMICSTORE_SMIN,
//                 ATOMICSTORE_UMAX, ATOMICSTORE_UMIN, ATOMICLOAD_ADD, ATOMICLOAD_CLR, ATOMICLOAD_EOR, ATOMICLOAD_SET, ATOMICLOAD_SMAX, ATOMICLOAD_SMIN,
//                 ATOMICLOAD_UMAX, ATOMICLOAD_UMIN, ATOMICSWAP,ATOMICCOMPARE
//             });
//         }
//     }

//     // CHI scoreboard cannot handle errors when errors are not predicted
//     // so remove error constraints from VIP and only enable them in tests which try to introduce errors
//     // This can be improved and ticket is opened for this : CONC-12115

//     constraint c_no_error_on_native_intf {
//         if (
//             (xact_type == WRITEBACKFULL) ||
//             (xact_type == WRITEBACKPTL) ||
//             (xact_type == WRITECLEANFULL) ||
//             (xact_type == WRITECLEANPTL) ||
//             (xact_type == WRITENOSNPFULL) ||
//             (xact_type == WRITENOSNPPTL) ||
//             (xact_type == WRITEUNIQUEFULL) ||
//             (xact_type == WRITEUNIQUEFULLSTASH) ||
//             (xact_type == WRITEUNIQUEPTLSTASH) ||
//      `ifdef SVT_CHI_ISSUE_E_ENABLE
//             (xact_type == WRITEEVICTOREVICT) ||
//             (xact_type == WRITENOSNPFULL_CLEANSHARED ||
//             xact_type == WRITENOSNPFULL_CLEANINVALID ||
//             xact_type == WRITENOSNPFULL_CLEANSHAREDPERSISTSEP ||
//             xact_type == WRITENOSNPPTL_CLEANSHARED ||
//             xact_type == WRITENOSNPPTL_CLEANINVALID ||
//             xact_type == WRITENOSNPPTL_CLEANSHAREDPERSISTSEP) ||
//             (xact_type == WRITEUNIQUEFULL_CLEANSHARED ||
//             xact_type == WRITEUNIQUEPTL_CLEANSHARED ||
//             xact_type == WRITEUNIQUEPTL_CLEANSHAREDPERSISTSEP ||
//             xact_type == WRITEUNIQUEFULL_CLEANSHAREDPERSISTSEP) ||
//             (xact_type == WRITEBACKFULL_CLEANSHARED ||
//             xact_type == WRITEBACKFULL_CLEANINVALID ||
//             xact_type == WRITEBACKFULL_CLEANSHAREDPERSISTSEP ||
//             xact_type == WRITECLEANFULL_CLEANSHARED ||
//             xact_type == WRITECLEANFULL_CLEANSHAREDPERSISTSEP) ||
//      `endif
//             (xact_type == WRITEUNIQUEPTL) ||
//             (xact_type == WRITEEVICTFULL) ||
//             xact_type == DVMOP
//         ){
//             foreach (data_resp_err_status[index]){
//                 data_resp_err_status[index] inside {NORMAL_OKAY};
//             }
//         }
//         response_resp_err_status == NORMAL_OKAY;
//     }

//     function new(string name = "chi_subsys_item");
//         super.new(name);
//         m_addr_mgr = addr_trans_mgr::get_instance();
//     endfunction: new

// endclass // chi_subsys_item

// class chi_subsys_snoop_item extends svt_chi_rn_snoop_transaction;
//     `svt_xvm_object_utils(chi_subsys_snoop_item)

//     constraint c_no_snoop_resp_error {
//         response_resp_err_status == svt_chi_common_transaction::NORMAL_OKAY;

//         foreach (data_resp_err_status[idx]){
//             data_resp_err_status[idx] inside {NORMAL_OKAY};
//         }
//         foreach (fwded_read_data_resp_err_status[idx]){
//             fwded_read_data_resp_err_status[idx] inside {NORMAL_OKAY};
//         }
//     }

//     function new(string name = "chi_subsys_snoop_item");
//         super.new(name);
//     endfunction: new

// endclass

class chi_snoop_item extends svt_chi_rn_snoop_transaction;
    `svt_xvm_object_param_utils(chi_snoop_item)

   int                             SNPrsp_with_data_error_wgt;
   int                             SNPrsp_with_data_error;
   int                             SNPrsp_with_non_data_error;
   int                             SNPrsp_with_non_data_error_wgt;
   rand bit                        inject_data_error;


    constraint c_no_snoop_resp_error {
	 if(SNPrsp_with_non_data_error_wgt) {
		response_resp_err_status dist {
                    svt_chi_common_transaction::NORMAL_OKAY := 100 - SNPrsp_with_non_data_error_wgt,
                    svt_chi_common_transaction::NON_DATA_ERROR := SNPrsp_with_non_data_error_wgt
                };
	} else {
        	response_resp_err_status == svt_chi_common_transaction::NORMAL_OKAY;
	}
	
	if(SNPrsp_with_data_error_wgt) {
		inject_data_error dist {
                    0 := 100 - SNPrsp_with_data_error_wgt,
                    1 := SNPrsp_with_data_error_wgt
                };
	}

        foreach (data_resp_err_status[idx]){
	    if(inject_data_error) {
		data_resp_err_status[idx] inside {DATA_ERROR};
	    } else {
                data_resp_err_status[idx] inside {NORMAL_OKAY};
	    }
        }
        foreach (fwded_read_data_resp_err_status[idx]){
             fwded_read_data_resp_err_status[idx] inside {NORMAL_OKAY};
        }
	
	solve inject_data_error before data_resp_err_status;
    }

     function new(string name = "chi_snoop_item");
         super.new(name);

         if ($value$plusargs("SNPrsp_with_data_error=%d",SNPrsp_with_data_error)) begin
           SNPrsp_with_data_error_wgt = SNPrsp_with_data_error ;
         end
         if ($value$plusargs("SNPrsp_with_non_data_error=%d",SNPrsp_with_non_data_error)) begin
           SNPrsp_with_non_data_error_wgt = SNPrsp_with_non_data_error ;
         end

     endfunction: new

endclass
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO
