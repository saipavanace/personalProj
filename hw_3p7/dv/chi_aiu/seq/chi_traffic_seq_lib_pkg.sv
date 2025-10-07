
package <%=obj.BlockId%>_chi_traffic_seq_lib_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import <%=obj.BlockId%>_chi_bfm_types_pkg::*;
import sv_assert_pkg::*;
import chi_aiu_unit_args_pkg::*;

//
//Helper files
//
`include "<%=obj.BlockId%>_chi_traffic_helper_structs.svh"
//Class picks start state depending on the command
`include "<%=obj.BlockId%>_chi_rand_start_state.svh"

//Base class for all Traffic generation sequences;

class chi_rn_traffic_base_seq extends uvm_object;

   `uvm_object_param_utils(chi_rn_traffic_base_seq)

  //CHI command line knobs
  chi_aiu_unit_args    m_args;
  chi_bfm_rand_txn_t   m_rand_type;

  bit		       start_ix;
  bit		       force_cleanuniq;
  bit		       enable_dii_atomic;
  bit                  cache_flush_start;
  bit                  non_secure_access_test;
  bit                  zero_nonzero_crd_test;
  int                  dii_cmo_test;

  //INIT Methods
  function new(string s = "chi_rn_traffic_base_seq");
    super.new(s);
  endfunction: new

  function void get_cmd_args(const ref chi_aiu_unit_args args);
    m_args = args;
  endfunction: get_cmd_args

  function void pre_randomize();
    `ASSERT(m_args != null);
    if (!$test$plusargs("unsupported_txn")) begin
      m_args.k_unsupported_txn_pct.set_value(0);
    end
    //TODO: remove eventually when fullsys tests enable the excl txns
    if (!$test$plusargs("en_excl_txn") && !$test$plusargs("en_excl_noncoh_txn")) begin
      m_args.k_excl_txn_pct.set_value(0);
    end

    if ($test$plusargs("enable_dii_atomic")) begin
      enable_dii_atomic = 1;
    end

    if ($test$plusargs("non_secure_access_test")) begin
      non_secure_access_test = 1;
    end

    if ($test$plusargs("zero_nonzero_crd_test")) begin
      zero_nonzero_crd_test = 1;
    end

    if ($test$plusargs("dii_cmo_test")) begin
      dii_cmo_test = 1;
    end

  endfunction: pre_randomize

endclass: chi_rn_traffic_base_seq

//Class has all required fields to generate constrain randomized
//CHI read, CHI dataless, CHI write, CHI Atomic and other requests
class chi_rn_traffic_cmd_seq extends chi_rn_traffic_base_seq;

  `uvm_object_param_utils(chi_rn_traffic_cmd_seq)

  //Random Proerties
  rand int                        m_tgtid;
  rand chi_bfm_opcode_type_t      m_opcode_type;
  rand chi_bfm_opcode_t           m_opcode;
  rand chi_bfm_addr_format_t      m_addr_type;
  rand bit                        m_new_addr;
  bit                             m_boot_addr;
  bit                             m_excl_txn;
  bit                             m_excl_noncoh_txn;
  rand int                        m_qos;
   
  //Memory attributes
  rand chi_bfm_memory_target_t    m_mem_type;
  rand bit                        m_ewa;
  rand bit                        m_snpattr;
  rand bit                        m_snoopme;
//rand bit                        m_lpid;
  rand int                        m_lpid;

  chi_req_size_t                  m_size;
  chi_req_compack_t               m_expcompack;
  chi_req_cacheable_alloc_t       m_cacheable_alloc;
  chi_req_likelyshared_t          m_likelyshared;
  chi_req_allowretry_t            m_allowretry;
  chi_req_excl_t                  m_excl;
  chi_req_ns                      m_ns;
  chi_req_stashnid_t              m_stashnid;
  chi_req_order_t                 m_order;
  chi_rand_start_state            m_rand_start_st;
  chi_bfm_cache_state_t           m_start_state;
  chi_dvm_addr_data_t             m_dvm_addr_data;

  int 				  num_alt_qos_values;
  int 				  total_aiu_qos_cycle;
  int 				  aiu_qos1;
  int 				  aiu_qos1_cycle;
  int 				  aiu_qos2;
  int 				  aiu_qos2_cycle;
  int 				  aiu_qos3;
  int 				  aiu_qos3_cycle;
  int 				  aiu_qos4;
  int 				  aiu_qos4_cycle;
  static int 			  qos_cycle_count;
   
  local bit     force_snoopable = $test$plusargs("force_chi_snoopable_txn") ? 1 : 0;
  local bit     force_ewa = $test$plusargs("force_chi_ewwa_txn") ? 1 : 0;
  local bit     fsys_chi_force_cleanunique = $test$plusargs("fsys_chi_force_cleanunique") ? 1 : 0;

  constraint c_targetid {
    m_tgtid inside {[0:127]};
  }

  //constrained either for COH or NON-COH address
  constraint c_addr_type {
    m_addr_type dist {
        COH_ADDR     := m_args.k_coh_addr_pct.get_value(),
        NON_COH_ADDR := m_args.k_noncoh_addr_pct.get_value()
    };
  }

  //Request new cacheline from address manager
  constraint c_new_addr {
    m_new_addr dist {
        1 := m_args.k_new_addr_pct.get_value(),
        0 := 100 - m_args.k_new_addr_pct.get_value()
    };
  }

  //constrained based on user provided knobs for 
  //selecting opcode and Address type
  constraint c_opcode_type {
    if (m_addr_type == NON_COH_ADDR) {
      if(m_boot_addr){
        m_opcode_type dist { 
          RD_NONCOH_CMD := m_args.k_rd_noncoh_pct.get_value(),
          WR_NONCOH_CMD := m_args.k_wr_noncoh_pct.get_value()
        };
      } 
      else {
        if(enable_dii_atomic) {
          m_opcode_type dist {
            RD_NONCOH_CMD := m_args.k_rd_noncoh_pct.get_value(),
            WR_NONCOH_CMD := m_args.k_wr_noncoh_pct.get_value(),
            ATOMIC_ST_CMD := m_args.k_atomic_st_pct.get_value(), 
            ATOMIC_LD_CMD := m_args.k_atomic_ld_pct.get_value(),
            ATOMIC_SW_CMD := m_args.k_atomic_sw_pct.get_value(),
            ATOMIC_CM_CMD := m_args.k_atomic_cm_pct.get_value(),
            RQ_LCRDRT_CMD := m_args.k_rq_lcrdrt_pct.get_value()
          };
        } 
        else {

         if (non_secure_access_test == 'h0 && zero_nonzero_crd_test == 'h0) {

          m_opcode_type dist {
          RD_NONCOH_CMD := m_args.k_rd_noncoh_pct.get_value(),
          WR_NONCOH_CMD := m_args.k_wr_noncoh_pct.get_value(),
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
          DT_LS_CMO_CMD := m_args.k_dt_ls_cmo_pct.get_value(),
        <%}%>
          //DII doesn't support Atomic commands from Chien
          // ATOMIC_ST_CMD := m_args.k_atomic_st_pct.get_value(), 
          // ATOMIC_LD_CMD := m_args.k_atomic_ld_pct.get_value(),
          // ATOMIC_SW_CMD := m_args.k_atomic_sw_pct.get_value(),
          // ATOMIC_CM_CMD := m_args.k_atomic_cm_pct.get_value(),
          RQ_LCRDRT_CMD := m_args.k_rq_lcrdrt_pct.get_value(), 
          UNSUP_TXN_CMD := m_args.k_unsupported_txn_pct.get_value()
          };

        } else {
          m_opcode_type dist {
          RD_NONCOH_CMD := m_args.k_rd_noncoh_pct.get_value(),
          WR_NONCOH_CMD := m_args.k_wr_noncoh_pct.get_value(),
          //DII doesn't support Atomic commands from Chien
          // ATOMIC_ST_CMD := m_args.k_atomic_st_pct.get_value(), 
          // ATOMIC_LD_CMD := m_args.k_atomic_ld_pct.get_value(),
          // ATOMIC_SW_CMD := m_args.k_atomic_sw_pct.get_value(),
          // ATOMIC_CM_CMD := m_args.k_atomic_cm_pct.get_value(),
          RQ_LCRDRT_CMD := m_args.k_rq_lcrdrt_pct.get_value(), 
          UNSUP_TXN_CMD := m_args.k_unsupported_txn_pct.get_value()
          };

         }

        }
      }
    } else {
        if(force_cleanuniq){
	  m_opcode_type == DT_LS_UPD_CMD;
        }else if(m_boot_addr){
      	  m_opcode_type dist { RD_LDRSTR_CMD := m_args.k_rd_ldrstr_pct.get_value()};
        }else{
          m_opcode_type dist {
           RD_RDONCE_CMD := m_args.k_rd_rdonce_pct.get_value(),
           RD_LDRSTR_CMD := m_args.k_rd_ldrstr_pct.get_value(),
           DT_LS_UPD_CMD := m_args.k_dt_ls_upd_pct.get_value(),
           DT_LS_CMO_CMD := m_args.k_dt_ls_cmo_pct.get_value(),
           WR_COHUNQ_CMD := m_args.k_wr_cohunq_pct.get_value(),
           WR_CPYBCK_CMD := m_args.k_wr_cpybck_pct.get_value(),
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
           DT_LS_STH_CMD := m_args.k_dt_ls_sth_pct.get_value(),
           WR_STHUNQ_CMD := 0, //m_args.k_wr_sthunq_pct.get_value(),
           ATOMIC_ST_CMD := m_args.k_atomic_st_pct.get_value(),
           ATOMIC_LD_CMD := m_args.k_atomic_ld_pct.get_value(),
           ATOMIC_SW_CMD := m_args.k_atomic_sw_pct.get_value(),
           ATOMIC_CM_CMD := m_args.k_atomic_cm_pct.get_value(),
           PRE_FETCH_CMD := m_args.k_pre_fetch_pct.get_value(),
<% } %>
           DVM_OPERT_CMD := m_args.k_dvm_opert_pct.get_value(),
           RQ_LCRDRT_CMD := m_args.k_rq_lcrdrt_pct.get_value(),
           UNSUP_TXN_CMD := m_args.k_unsupported_txn_pct.get_value() 
         };
      }
    }
  }

  //Pick the opcode CHI SPEC chapter 4.4 , Pg 144
  constraint c_opcode {
    (m_opcode_type == RD_RDONCE_CMD) -> m_opcode inside {
<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
      BFM_READONCE};
<% } else { %>
      BFM_READONCE, BFM_READONCECLEANINVALID, BFM_READONCEMAKEINVALID};
<% } %>


    if(m_boot_addr){
     	(m_opcode_type == RD_LDRSTR_CMD) -> m_opcode inside {
      	BFM_READSHARED,  BFM_READUNIQUE};
    }else{
       if(m_excl_txn){
     	(m_opcode_type == RD_LDRSTR_CMD) -> m_opcode inside {
      	BFM_READSHARED, BFM_READCLEAN};
       }else{
        (m_opcode_type == RD_LDRSTR_CMD) -> m_opcode inside {
<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
         BFM_READSHARED, BFM_READCLEAN, BFM_READUNIQUE};
<% } else { %>
         BFM_READSHARED, BFM_READCLEAN, BFM_READUNIQUE, BFM_READNOTSHAREDDIRTY};
<% } %>
       }
     }

  (m_opcode_type == DT_LS_UPD_CMD) -> if(force_cleanuniq || m_excl_txn || fsys_chi_force_cleanunique) m_opcode == BFM_CLEANUNIQUE;
        else  m_opcode inside {BFM_CLEANUNIQUE, BFM_MAKEUNIQUE, BFM_EVICT};
 
if(dii_cmo_test) {
    (m_opcode_type == DT_LS_CMO_CMD) -> m_opcode inside {
<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
      BFM_CLEANSHARED, BFM_CLEANINVALID, BFM_MAKEINVALID};
<% } else { %>
      BFM_CLEANSHARED, BFM_CLEANSHAREDPERSIST,BFM_CLEANINVALID, BFM_MAKEINVALID};
<% } %>
} else {
    (m_opcode_type == DT_LS_CMO_CMD) -> m_opcode inside {
<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
      BFM_CLEANSHARED, BFM_CLEANINVALID, BFM_MAKEINVALID};
<% } else { %>
      BFM_CLEANSHARED, BFM_CLEANSHAREDPERSIST,BFM_CLEANINVALID, BFM_MAKEINVALID};
<% } %>
}

    (m_opcode_type == DT_LS_STH_CMD) -> m_opcode inside {
      BFM_STASHONCEUNIQUE, BFM_STASHONCESHARED};

    (m_opcode_type == WR_NONCOH_CMD) -> m_opcode inside {
      BFM_WRITENOSNPFULL, BFM_WRITENOSNPPTL};

    (m_opcode_type == WR_COHUNQ_CMD) -> m_opcode inside {
      BFM_WRITEUNIQUEFULL, BFM_WRITEUNIQUEPTL};

    (m_opcode_type == WR_STHUNQ_CMD) -> m_opcode inside {
      BFM_WRITEUNIQUEFULLSTASH, BFM_WRITEUNIQUEPTLSTASH};

<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
    (m_opcode_type == WR_CPYBCK_CMD) -> m_opcode inside {
      BFM_WRITEBACKFULL, BFM_WRITEBACKPTL, BFM_WRITECLEANFULL, BFM_WRITECLEANPTL,   
      BFM_WRITEEVICTFULL};
<% } else { %>
    (m_opcode_type == WR_CPYBCK_CMD) -> m_opcode inside {
      BFM_WRITEBACKFULL, BFM_WRITEBACKPTL, BFM_WRITECLEANFULL,                      
      BFM_WRITEEVICTFULL};
<% } %>

    (m_opcode_type == ATOMIC_LD_CMD) -> m_opcode inside {
      BFM_ATOMICLOAD_LDADD, BFM_ATOMICLOAD_LDCLR, BFM_ATOMICLOAD_LDEOR,
      BFM_ATOMICLOAD_LDSET, BFM_ATOMICLOAD_LDSMAX, BFM_ATOMICLOAD_LDMIN,
      BFM_ATOMICLOAD_LDUSMAX, BFM_ATOMICLOAD_LDUMIN, BFM_ATOMICCOMPARE};
    
    (m_opcode_type == ATOMIC_ST_CMD) -> m_opcode inside {
      BFM_ATOMICSTORE_STADD, BFM_ATOMICSTORE_STCLR, BFM_ATOMICSTORE_STEOR,
      BFM_ATOMICSTORE_STSET, BFM_ATOMICSTORE_STSMAX, BFM_ATOMICSTORE_STMIN,
      BFM_ATOMICSTORE_STUSMAX, BFM_ATOMICSTORE_STUMIN};

    (m_opcode_type == RD_NONCOH_CMD) -> m_opcode == BFM_READNOSNP;
    (m_opcode_type == ATOMIC_SW_CMD) -> m_opcode == BFM_ATOMICSWAP;
    (m_opcode_type == ATOMIC_CM_CMD) -> m_opcode == BFM_ATOMICCOMPARE;
    (m_opcode_type == DVM_OPERT_CMD) -> m_opcode == BFM_DVMOP;
    (m_opcode_type == PRE_FETCH_CMD) -> m_opcode == BFM_PREFETCHTARGET;
    (m_opcode_type == RQ_LCRDRT_CMD) -> m_opcode == BFM_REQLCRDRETURN;
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    (m_opcode_type == UNSUP_TXN_CMD) -> m_opcode inside {BFM_UNSUP_OPCODE_0,BFM_UNSUP_OPCODE_1,BFM_UNSUP_OPCODE_2,BFM_UNSUP_OPCODE_3
    
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-E') { %>
        ,BFM_UNSUP_OPCODE_4
    <%}%>
    ,BFM_UNSUP_OPCODE_5,BFM_UNSUP_OPCODE_6,BFM_UNSUP_OPCODE_7,BFM_UNSUP_OPCODE_8,BFM_UNSUP_OPCODE_9,BFM_UNSUP_OPCODE_10,BFM_UNSUP_OPCODE_11,BFM_EOBARRIER,BFM_ECBARRIER};
<% } else { %>
    (m_opcode_type == UNSUP_TXN_CMD) -> m_opcode inside {BFM_UNSUP_OPCODE_0,BFM_UNSUP_OPCODE_1,BFM_UNSUP_OPCODE_2,BFM_UNSUP_OPCODE_3,BFM_UNSUP_OPCODE_4,BFM_UNSUP_OPCODE_5,BFM_UNSUP_OPCODE_6};
<% } %>
  };

  //Request target to either Device or Normal Memory
  constraint c_mem_type {
<%if(obj.AiuInfo[obj.Id].nDiis >1){%>
    (m_addr_type == NON_COH_ADDR) -> m_mem_type dist {
        NORMAL := 100 - m_args.k_device_type_mem_pct.get_value(),
        DEVICE := m_args.k_device_type_mem_pct.get_value()
    };
    (m_addr_type == COH_ADDR) ->     m_mem_type == NORMAL;
<%}else{%>
    m_mem_type == NORMAL;
<%}%>
  }

  //CHI Spec Ch 2.9.3 Pg 92
  constraint c_ewa_type {
    (m_opcode_type == RD_RDONCE_CMD || m_opcode_type == RD_LDRSTR_CMD ||
     m_opcode_type == DT_LS_UPD_CMD || m_opcode_type == DT_LS_CMO_CMD ||
     m_opcode_type == DT_LS_STH_CMD ||
     m_opcode_type == WR_STHUNQ_CMD || m_opcode_type == WR_CPYBCK_CMD) ->
       m_ewa == 1;

    (m_opcode_type == RQ_LCRDRT_CMD || m_opcode_type == WR_NONCOH_CMD) -> m_ewa inside {[0:1]};

    (m_opcode_type == DVM_OPERT_CMD) -> m_ewa == 0;
    
    (force_ewa == 1 && !(m_opcode_type == DVM_OPERT_CMD)) -> m_ewa == 1;
  }

  //CHI SPEC Ch 2.9.6 Pg 98
  constraint c_snp_attr {
    (m_opcode_type == RD_NONCOH_CMD || m_opcode_type == WR_NONCOH_CMD || m_opcode_type == DVM_OPERT_CMD) ->

       m_snpattr == 0;

   <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>	   
    (m_opcode_type == RD_RDONCE_CMD || m_opcode_type == RD_LDRSTR_CMD ||
     m_opcode_type == WR_COHUNQ_CMD || m_opcode_type == WR_STHUNQ_CMD ||
     m_opcode_type == WR_CPYBCK_CMD || m_opcode_type == DT_LS_UPD_CMD || m_opcode_type == DT_LS_STH_CMD
     ) ->
       m_snpattr == 1;
   <% } %> 


    (m_opcode_type == RQ_LCRDRT_CMD
   <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>       ||
     m_opcode_type == RD_RDONCE_CMD || m_opcode_type == RD_LDRSTR_CMD ||
     m_opcode_type == WR_COHUNQ_CMD || m_opcode_type == DT_LS_UPD_CMD ||
     m_opcode_type == WR_STHUNQ_CMD || m_opcode_type == WR_CPYBCK_CMD <% } %>

     ) -> m_snpattr inside {[0:1]};

    (m_opcode_type == DT_LS_CMO_CMD) ->  m_snpattr inside {1}; // According to CHI-B spec. appendix A.1 Request message field mappings

    (force_snoopable == 1 && m_mem_type == NORMAL && 
    (!(m_opcode_type == RD_NONCOH_CMD || m_opcode_type == WR_NONCOH_CMD || m_opcode_type == DVM_OPERT_CMD)) 
      ) ->  m_snpattr == 1;

}

  constraint c_starting_byte {

  }
  ////TODO FIXME, Requires more understanding..
  ////for now tieing it to zero
  //constraint c_excl {
  //  m_excl == 0;
  //}

  constraint c_lpid {
   <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
         m_lpid inside {[0:7]};
   <% } else { %>
         m_lpid inside {[0:31]};
   <% } %>
  }

  constraint c_qos {
      m_qos inside {[0:15]};
  }

  //INIT Methods
  extern function new(string s = "chi_rn_traffic_cmd_seq");

  extern function void post_randomize();
  extern function string convert2string();

endclass: chi_rn_traffic_cmd_seq

function chi_rn_traffic_cmd_seq::new(string s = "chi_rn_traffic_cmd_seq");
  super.new(s);

  m_rand_type       = CMD_BASED;
  m_size            = new("chi_req_size_t");
  m_expcompack      = new("chi_req_compack_t");
  m_stashnid        = new("chi_req_stashnid_t");
  m_cacheable_alloc = new("chi_req_cacheable_alloc_t");
  m_likelyshared    = new("chi_req_likelyshared_t");
  m_allowretry      = new("chi_req_allowretry_t");
  m_order           = new("chi_req_order_t");
  m_rand_start_st   = new("chi_rand_start_state");
  m_dvm_addr_data   = new("chi_req_dvm_addr_data");
  m_excl            = new("chi_req_excl");
  m_ns              = new("chi_req_ns");
  //m_returnnid       = new("chi_req_returnnid");
  m_boot_addr       = 0;
  m_excl_txn        = 0;
  m_excl_noncoh_txn  = 0;
  qos_cycle_count    = 0; 
  num_alt_qos_values = 0;
   
  if($value$plusargs("<%=obj.BlockId%>_alt_qos_values=%d", num_alt_qos_values)) begin
     if(num_alt_qos_values <= 1) begin
	`uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_alt_qos_values has to be greater than 1.  Specified value=%0d", num_alt_qos_values))
     end
     if(num_alt_qos_values > 1) begin
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos1=%d", aiu_qos1)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos1 not specified."))
	end
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos1_cycle=%d", aiu_qos1_cycle)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos1_cycle not specified."))
	end
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos2=%d", aiu_qos2)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos2 not specified."))
	end
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos2_cycle=%d", aiu_qos2_cycle)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos2_cycle not specified."))
	end
        total_aiu_qos_cycle = aiu_qos1_cycle + aiu_qos2_cycle;
     end
     if(num_alt_qos_values > 2) begin
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos3=%d", aiu_qos3)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos3 not specified."))
	end
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos3_cycle=%d", aiu_qos3_cycle)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos3_cycle not specified."))
	end
        total_aiu_qos_cycle += aiu_qos3_cycle;
     end
     if(num_alt_qos_values > 3) begin
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos4=%d", aiu_qos4)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos4 not specified."))
	end
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos4_cycle=%d", aiu_qos4_cycle)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos4_cycle not specified."))
	end
        total_aiu_qos_cycle += aiu_qos4_cycle;
     end
     if(num_alt_qos_values > 4) begin
	`uvm_error(get_full_name(), $sformatf("Only supporting maximum <%=obj.BlockId%>_alt_qos_values of 4.  Specified value=%0d", num_alt_qos_values))
     end
  end
endfunction: new

function void chi_rn_traffic_cmd_seq::post_randomize();
  int 				  aiu_qos;
   
  m_size.set_req_fields(m_opcode);
  `ASSERT(m_size.randomize());
  m_expcompack.set_req_fields(m_opcode_type, m_opcode);
  `ASSERT(m_expcompack.randomize());
  m_cacheable_alloc.set_req_fields(m_opcode, m_opcode_type, m_mem_type);
  `ASSERT(m_cacheable_alloc.randomize());
  m_likelyshared.set_req_fields(m_opcode);
  `ASSERT(m_likelyshared.randomize());
  m_allowretry.set_req_fields(m_opcode_type,m_opcode);
  `ASSERT(m_allowretry.randomize());
  m_order.set_req_fields(m_opcode_type, m_mem_type, m_opcode);
  `ASSERT(m_stashnid.randomize());
  m_stashnid.set_req_fields(m_opcode_type,m_opcode);
  `ASSERT(m_order.randomize()); //TODO: randomize when RTL support is added
  m_excl.set_req_fields(m_opcode, m_args.k_excl_txn_pct.get_value());
  `ASSERT(m_excl.randomize());
  m_ns.set_req_fields(m_opcode);
  `ASSERT(m_ns.randomize());
  m_dvm_addr_data.set_dvm_knobs(.dvm_tlbi_pct(m_args.k_dvm_tlbi_pct.get_value()), 
                                .dvm_bpi_pct(m_args.k_dvm_bpi_pct.get_value()), 
                                .dvm_pici_pct(m_args.k_dvm_pici_pct.get_value()), 
                                .dvm_vici_pct(m_args.k_dvm_vici_pct.get_value()), 
                                .dvm_sync_pct(m_args.k_dvm_sync_pct.get_value())); 
  `ASSERT(m_dvm_addr_data.randomize());
  if (m_addr_type == COH_ADDR) begin
    m_start_state = m_rand_start_st.pick_rand_start_state(
      				    m_opcode, m_opcode_type, start_ix);
    m_snoopme     = m_rand_start_st.pick_snoopme();
  end else begin
    m_start_state = CHI_IX;
    m_snoopme     = 0;
  end
  //if (m_opcode_type inside {ATOMIC_LD_CMD, ATOMIC_ST_CMD, ATOMIC_CM_CMD, ATOMIC_SW_CMD}) begin
  //    if (m_addr_type == COH_ADDR)
  //        m_snpattr = 1;
  //    else
  //        m_snpattr = 0;
  //end
  if (m_opcode_type inside {ATOMIC_LD_CMD, ATOMIC_ST_CMD, ATOMIC_CM_CMD, ATOMIC_SW_CMD} &&
   $test$plusargs("force_coh_atomic")) begin
        m_snpattr = 1;
  end

  if($value$plusargs("aiu_qos=%d", aiu_qos)) begin
     m_qos = aiu_qos;
  end

  if(num_alt_qos_values > 1) begin
     if(qos_cycle_count < aiu_qos1_cycle) m_qos = aiu_qos1;
     else if(qos_cycle_count < (aiu_qos1_cycle + aiu_qos2_cycle)) m_qos = aiu_qos2;
     else if(qos_cycle_count < (aiu_qos1_cycle + aiu_qos2_cycle + aiu_qos3_cycle)) m_qos = aiu_qos3;
     else m_qos = aiu_qos4;

     qos_cycle_count += 1;
     if(qos_cycle_count == total_aiu_qos_cycle) qos_cycle_count = 0;
  end

endfunction: post_randomize

function string chi_rn_traffic_cmd_seq::convert2string();
  string s;

  $sformat(s, "%s cmd_seq: CMD", s);
  $sformat(s, "%s opcode_type:%s opcode:%s addr_type:%s memory_type:%s",
           s, m_opcode_type.name(), m_opcode.name(),
           m_addr_type.name(), m_mem_type.name());
  $sformat(s, "%s ewa:%b snpattr:%b snoopme:%b exclusive:%b ns:%b size:%0d",
           s, m_ewa, m_snpattr, m_snoopme, m_excl.m_excl, m_ns.m_ns, m_size.m_size);
  $sformat(s, "%s expcompack:%b stashnid:%b cacheable:%b alloc:%b likelyshared:%b allowretry:%b",
           s, m_expcompack.m_expcompack, m_stashnid.m_stashnid, m_cacheable_alloc.m_cacheable,
           m_cacheable_alloc.m_alloc, m_likelyshared.m_likelyshared, m_allowretry.m_allowretry);
  $sformat(s, "%s order:%s start_state:%s",
           s, m_order.m_order.name(), m_start_state.name());
  return s;
endfunction: convert2string

endpackage: <%=obj.BlockId%>_chi_traffic_seq_lib_pkg
