import svt_chi_item_helper_pkg::*;
import chi_ss_helper_pkg::*;
typedef enum {
    AIU, DCE, DMI, DII, DVE
} unit_t;
class chi_subsys_base_item extends svt_chi_rn_transaction; 

    `svt_xvm_object_utils(chi_subsys_base_item)

    int chi_coh_dii_test_err;
    int use_dvm;
    int csr_access;
    int en_delay;
    ncoreConfigInfo::sys_addr_csr_t csrq[$];
    bit forbidden_stashnid;
    bit disable_atomic_constraint_to_dmi_with_no_atomic_support;
    addr_trans_mgr_pkg::addr_trans_mgr  m_addr_mgr;
    bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_from_sel_targ;
    bit    GEN_SEL_TARG_ADDR;  
    string test_targ_unit_type = "DII"; /* "DII" OR "DMI" */
    int    test_targ_unit_id=0; /* unit_type=DII : 0,1,2..., unit_type==DMI= 0,1,2...  */ 
    int    test_targ_index_in_group=0; /*For multiple mem region configured for any DII or DMI, select one of them.*/
    bit    test_targ_nc=1; /* Non-coherent or coherent region */


    `ifdef SVT_CHI_ISSUE_E_ENABLE
        constraint c_unsupported_opcodes {
            !(svt_chi_rn_transaction::xact_type inside {
                READNOSNPSEP
   
                });
        }
    `endif // `ifdef SVT_CHI_ISSUE_E_ENABLE
    
    `ifndef CHI_SUBSYS
      // FSYS don't know why seq don't use weight 
      constraint c_unsupported_opcodes_fsys {
            !(svt_chi_rn_transaction::xact_type inside {
                 EOBARRIER       
                ,ECBARRIER       
                ,PCRDRETURN 
                ,REQLINKFLIT
                ,WRITEUNIQUEFULLSTASH
                ,WRITEUNIQUEPTLSTASH
              `ifdef SVT_CHI_ISSUE_E_ENABLE
                    ,WRITEUNIQUEFULL_CLEANSHARED
                    ,WRITEUNIQUEPTL_CLEANSHARED
                    ,WRITEUNIQUEFULL_CLEANSHAREDPERSISTSEP
                    ,WRITEUNIQUEPTL_CLEANSHAREDPERSISTSEP
                    ,WRITENOSNPPTL_CLEANSHARED
                    ,WRITENOSNPPTL_CLEANINVALID
                    ,WRITENOSNPPTL_CLEANSHAREDPERSISTSEP
                    ,WRITENOSNPPTL_CLEANSHAREDPERSISTSEP
                    ,STASHONCESEPUNIQUE
                    ,STASHONCESEPSHARED
                    ,WRITEEVICTOREVICT     
              `endif // `ifdef SVT_CHI_ISSUE_E_ENABLE
                });
        }
    `endif

    constraint c_addr_not_in_boot_and_no_exclusives_during_boot {
        if (k_disable_boot_addr) {
            !(addr inside {[ncoreConfigInfo::NRS_REGION_BASE : (ncoreConfigInfo::NRS_REGION_BASE + ncoreConfigInfo::NRS_REGION_SIZE-1)]});
        } else {
            is_exclusive == 0;
        }
    }

    constraint c_prefetch_not_allowed_to_dii {
        xact_type == PREFETCHTGT -> snp_attr_is_snoopable == 1;
    }

    //FIXME: move this to a test specific seq_item once we start creating multiple seq items
    // constraint c_force_exp_compack {
    //     if (svt_chi_item_helper::exp_compack) {
    //         exp_comp_ack == 1;
    //     }
    // }

    // reserving some entries for stashes - FIXME, after solvnet ticket is created and resolved remove this constraint
    // constraint c_constraint_txnid {
    //     !(txn_id inside {reserved_ids});
    // }

    constraint c_valid_stash_target {
        if (forbidden_stashnid) {
        (stash_nid_valid == 1) -> stash_nid inside {ncoreConfigInfo::stash_nids,ncoreConfigInfo::stash_nids_forbidden};
        } else {
        (stash_nid_valid == 1) -> stash_nid inside {ncoreConfigInfo::stash_nids};
        }
    }

    constraint c_lpid_in_range {
        (k_directed_lpid == -1) -> lpid inside {[0:(<%=obj.AiuInfo[obj.Id].nProcs%>-1)]};
    }

    constraint c_stash_lpid_in_range {
        (k_directed_lpid == -1) -> stash_lpid inside {[0:(<%=obj.AiuInfo[obj.Id].nProcs%>-1)]};
    }

    
    // Ncore doesnt not support big endian access
    constraint c_endianess_is_little {
        endian == svt_chi_rn_transaction::LITTLE_ENDIAN;
    }

    // Ncore doesnt support ATOMICS to DII
    constraint c_no_atomics_to_dii {
        foreach(ncoreConfigInfo::memregions_info[region]) {
            (
                ncoreConfigInfo::memregions_info[region].hut == DII
                && (addr >= ncoreConfigInfo::memregions_info[region].start_addr)
                && (addr <= ncoreConfigInfo::memregions_info[region].end_addr)
            ) -> !( xact_type inside {
                ATOMICSTORE_ADD, ATOMICSTORE_CLR, ATOMICSTORE_EOR, ATOMICSTORE_SET, ATOMICSTORE_SMAX, ATOMICSTORE_SMIN,
                ATOMICSTORE_UMAX, ATOMICSTORE_UMIN, ATOMICLOAD_ADD, ATOMICLOAD_CLR, ATOMICLOAD_EOR, ATOMICLOAD_SET, ATOMICLOAD_SMAX, ATOMICLOAD_SMIN,
                ATOMICLOAD_UMAX, ATOMICLOAD_UMIN, ATOMICSWAP,ATOMICCOMPARE
            });
        }
    }

    // We cannot send atomics to DMI if atomics are disabled
    constraint c_no_atomics_to_dmi_with_no_support {
        if(disable_atomic_constraint_to_dmi_with_no_atomic_support==0){
        <%for(let i=0; i< obj.nDMIs; i++){%>
            <%if(obj.DmiInfo[i].useAtomic == 0){%>
                foreach(ncoreConfigInfo::memregions_info[j]) {
                    ((addr >= ncoreConfigInfo::memregions_info[j].start_addr) && (addr <= ncoreConfigInfo::memregions_info[j].end_addr) && (ncoreConfigInfo::memregions_info[j].hut == DMI)) -> 
		    <%if(obj.AiuInfo[0].InterleaveInfo.dmi2WIFV.length >0){%>
		    if((ncoreConfigInfo::memregions_info[j].UnitIds.size() == 2) ? (addr[<%=obj.AiuInfo[0].InterleaveInfo.dmi2WIFV[0].PrimaryBits[0]%>] == <%=i%>) : (csrq[j].mig_nunitid == <%=i%>)) {
		    <%} else {%>
		    if(csrq[j].mig_nunitid == <%=i%>) {
		    <%}%>
		    	!( xact_type inside {
                    	    ATOMICSTORE_ADD, ATOMICSTORE_CLR, ATOMICSTORE_EOR, ATOMICSTORE_SET, ATOMICSTORE_SMAX, ATOMICSTORE_SMIN,
                    	    ATOMICSTORE_UMAX, ATOMICSTORE_UMIN, ATOMICLOAD_ADD, ATOMICLOAD_CLR, ATOMICLOAD_EOR, ATOMICLOAD_SET, ATOMICLOAD_SMAX, ATOMICLOAD_SMIN,
                    	    ATOMICLOAD_UMAX, ATOMICLOAD_UMIN, ATOMICSWAP,ATOMICCOMPARE
                    	});
		    }
                }
            <%}%>
        <%}%>
        }
    }

    // CHI scoreboard cannot handle errors when errors are not predicted
    // so remove error constraints from VIP and only enable them in tests which try to introduce errors
    // This can be improved and ticket is opened for this : CONC-12115

    constraint c_no_error_on_native_intf {
        if (
            (xact_type == WRITEBACKFULL) ||
            (xact_type == WRITEBACKPTL) ||
            (xact_type == WRITECLEANFULL) ||
            (xact_type == WRITECLEANPTL) ||
            (xact_type == WRITENOSNPFULL) ||
            (xact_type == WRITENOSNPPTL) ||
            (xact_type == WRITEUNIQUEFULL) ||
            (xact_type == WRITEUNIQUEFULLSTASH) ||
            (xact_type == WRITEUNIQUEPTLSTASH) ||
     `ifdef SVT_CHI_ISSUE_E_ENABLE
            (xact_type == WRITEEVICTOREVICT) ||
            (xact_type == WRITENOSNPFULL_CLEANSHARED ||
            xact_type == WRITENOSNPFULL_CLEANINVALID ||
            xact_type == WRITENOSNPFULL_CLEANSHAREDPERSISTSEP ||
            xact_type == WRITENOSNPPTL_CLEANSHARED ||
            xact_type == WRITENOSNPPTL_CLEANINVALID ||
            xact_type == WRITENOSNPPTL_CLEANSHAREDPERSISTSEP) ||
            (xact_type == WRITEUNIQUEFULL_CLEANSHARED ||
            xact_type == WRITEUNIQUEPTL_CLEANSHARED ||
            xact_type == WRITEUNIQUEPTL_CLEANSHAREDPERSISTSEP ||
            xact_type == WRITEUNIQUEFULL_CLEANSHAREDPERSISTSEP) ||
            (xact_type == WRITEBACKFULL_CLEANSHARED ||
            xact_type == WRITEBACKFULL_CLEANINVALID ||
            xact_type == WRITEBACKFULL_CLEANSHAREDPERSISTSEP ||
            xact_type == WRITECLEANFULL_CLEANSHARED ||
            xact_type == WRITECLEANFULL_CLEANSHAREDPERSISTSEP) ||
     `endif
            (xact_type == WRITEUNIQUEPTL) ||
            (xact_type == WRITEEVICTFULL) ||
            xact_type == DVMOP
        ){
            foreach (data_resp_err_status[index]){
                data_resp_err_status[index] inside {NORMAL_OKAY};
            }
        }
        response_resp_err_status == NORMAL_OKAY;
    }

    constraint reasonable_atomic_write_data_resp_err_status_okay {
        if ((xact_type == ATOMICSTORE_ADD) || (xact_type == ATOMICSTORE_CLR) ||
        (xact_type == ATOMICSTORE_EOR) || (xact_type == ATOMICSTORE_SET) ||
        (xact_type == ATOMICSTORE_SMAX) || (xact_type == ATOMICSTORE_SMIN) ||
        (xact_type == ATOMICSTORE_UMAX) || (xact_type == ATOMICSTORE_UMIN) ||
        (xact_type == ATOMICLOAD_ADD) || (xact_type == ATOMICLOAD_CLR) ||
        (xact_type == ATOMICLOAD_EOR) || (xact_type == ATOMICLOAD_SET) ||
        (xact_type == ATOMICLOAD_SMAX) || (xact_type == ATOMICLOAD_SMIN) ||
        (xact_type == ATOMICLOAD_UMAX) || (xact_type == ATOMICLOAD_UMIN) ||
        (xact_type == ATOMICSWAP) || (xact_type == ATOMICCOMPARE)
        ){
            foreach (atomic_write_data_resp_err_status[idx]){
                atomic_write_data_resp_err_status[idx] inside {
                    NORMAL_OKAY
                }; 
            }
        }
    }

    //////////////////////////////////////////////////////////
    // Directed constraints toggled by a specific sequences //
    //////////////////////////////////////////////////////////

    constraint c_force_exclusive {
        (k_directed_excl != -1) -> is_exclusive == k_directed_excl;
    }

    constraint c_force_lpid {
        (k_directed_lpid != -1) -> lpid == k_directed_lpid;
    }

    constraint c_exp_comp_ack {
        (k_exp_comp_ack != -1) -> exp_comp_ack == k_exp_comp_ack;
    }
   `ifndef CHI_SUBSYS
        constraint c_fix_byteenable {
            if ((xact_type == WRITEBACKFULL) 
            || (xact_type == WRITECLEANFULL)
            || (xact_type == WRITENOSNPFULL)
            || (xact_type == WRITEUNIQUEFULL)
            || (xact_type == WRITEUNIQUEFULLSTASH)
     `ifdef SVT_CHI_ISSUE_E_ENABLE
            || (xact_type == WRITENOSNPFULL_CLEANSHARED) 
            || (xact_type == WRITENOSNPFULL_CLEANINVALID)
            || (xact_type == WRITENOSNPFULL_CLEANSHAREDPERSISTSEP)
            || (xact_type == WRITEUNIQUEFULL_CLEANSHARED)
            || (xact_type == WRITEUNIQUEFULL_CLEANSHAREDPERSISTSEP)
            || (xact_type == WRITEBACKFULL_CLEANSHARED)
            || (xact_type == WRITEBACKFULL_CLEANINVALID)
            || (xact_type == WRITEBACKFULL_CLEANSHAREDPERSISTSEP)
            || (xact_type == WRITECLEANFULL_CLEANSHARED)
            || (xact_type == WRITECLEANFULL_CLEANSHAREDPERSISTSEP) 
     `endif
            || (xact_type == WRITEEVICTFULL)) {
                  foreach (byte_enable[i]) byte_enable[i]==1;
            }
        }
        constraint c_fix_allocate {
              (mem_attr_mem_type == DEVICE) -> mem_attr_allocate_hint == 0; // CONC-13482
        }
        constraint c_authorize_dii_txn {
            solve xact_type before mem_attr_mem_type;
            solve mem_attr_mem_type before mem_attr_allocate_hint,mem_attr_is_cacheable,byte_enable;
            foreach(ncoreConfigInfo::memregions_info[region]) {
                if (
                    ncoreConfigInfo::memregions_info[region].hut == DII
                    && (addr >= ncoreConfigInfo::memregions_info[region].start_addr)
                    && (addr <= ncoreConfigInfo::memregions_info[region].end_addr)
                )  {  ( xact_type inside {
                                                                        READNOSNP  
                                                                    ,WRITENOSNPFULL
                                                                    ,WRITENOSNPPTL 
                                                                    `ifdef SVT_CHI_ISSUE_E_ENABLE
                                                                    ,WRITENOSNPZERO 
                                                                    ,WRITENOSNPFULL_CLEANSHARED  
                                                                    ,WRITENOSNPFULL_CLEANINVALID 
                                                                    ,WRITENOSNPFULL_CLEANSHAREDPERSISTSEP            
                                                                    ,CLEANSHAREDPERSISTSEP 
                                                                    `endif 
                                                                    /// Cache maintenance allow in case of DII
                                                                    ,CLEANINVALID      
                                                                    ,MAKEINVALID
                                                                    ,CLEANSHAREDPERSIST  
                                                                    ,CLEANSHARED
                          });
                }
            }
        }
        constraint c_no_dvm {
            (!use_dvm) -> (xact_type != DVMOP);
        }

        constraint error_dii_coh_test {
               (chi_coh_dii_test_err && xact_type inside {CLEANINVALID,MAKEINVALID,CLEANSHARED 
                                                               `ifdef SVT_CHI_ISSUE_E_ENABLE
                                                              ,WRITENOSNPFULL_CLEANSHARED  
                                                              ,WRITENOSNPFULL_CLEANINVALID 
                                                              ,WRITENOSNPFULL_CLEANSHAREDPERSISTSEP            
                                                              ,CLEANSHAREDPERSISTSEP
                                                               `endif 
                                                     }) -> snp_attr_is_snoopable ==1 ;
               solve xact_type,addr before snp_attr_is_snoopable;
        } 

   `ifndef CHI_SUBSYS
        constraint c_snp_attr {
            xact_type inside {WRITEBACKFULL,WRITEBACKPTL,WRITECLEANFULL,WRITECLEANPTL} -> snp_attr_is_snoopable ==1 ;
        }
    `endif

    `ifdef SVT_CHI_ISSUE_E_ENABLE
        constraint c_chi_b {
            // to be sure don't generate forbidden opcode in case CHI-B 
          (cfg.chi_spec_revision == svt_chi_node_configuration::ISSUE_B) -> !(xact_type inside {
                                                                    WRITENOSNPZERO 
                                                                    ,WRITENOSNPFULL_CLEANSHARED  
                                                                    ,WRITENOSNPFULL_CLEANINVALID 
                                                                    ,WRITENOSNPFULL_CLEANSHAREDPERSISTSEP            
                                                                    ,CLEANSHAREDPERSISTSEP 
                                                                    ,WRITEUNIQUEFULL_CLEANSHARED
                                                                    ,WRITEUNIQUEPTL_CLEANSHARED
                                                                    ,WRITEUNIQUEFULL_CLEANSHAREDPERSISTSEP
                                                                    ,WRITEUNIQUEPTL_CLEANSHAREDPERSISTSEP
                                                                    ,WRITENOSNPPTL_CLEANSHARED
                                                                    ,WRITENOSNPPTL_CLEANINVALID
                                                                    ,WRITENOSNPPTL_CLEANSHAREDPERSISTSEP
                                                                    ,STASHONCESEPUNIQUE
                                                                    ,STASHONCESEPSHARED
                                                                    ,WRITEEVICTOREVICT 
                                                                    ,WRITEUNIQUEZERO            
                                                                    ,READPREFERUNIQUE           
          }); 
      } 
     `endif // SVT_CHI_ISSUE_E_ENABLE
      <% if (obj.nCHIs < 2) {%>
      constraint c_no_stash {  // no stash when we have only one CHI
         !(xact_type inside {STASHONCEUNIQUE,STASHONCESHARED});
     }
     <% }%>
    `endif // CHI_SUBSYS

    // don't use CSR addr range 
      constraint c_no_csr_addr {
          (!csr_access) -> !( addr inside {[ncoreConfigInfo::NRS_REGION_BASE:ncoreConfigInfo::NRS_REGION_BASE + ncoreConfigInfo::NRS_REGION_SIZE-1]});
      } 
      constraint c_en_delay {
	if(en_delay){
  	<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
	  svt_chi_transaction::req_to_comppersist_flit_delay == 15;
          svt_chi_transaction::req_to_persist_flit_delay == 15;
          svt_chi_transaction::req_to_persist_flit_delay == 15;
  	<% } %>
	  svt_chi_transaction::req_to_comp_flit_delay == 15;
          svt_chi_transaction::req_to_compdata_flit_delay == 15;
          svt_chi_transaction::req_to_dbid_flit_delay == 15;
          svt_chi_transaction::dbid_to_comp_flit_delay == 15;
	}
      } 

      constraint c_GEN_SEL_TARG_ADDR {
       if(GEN_SEL_TARG_ADDR) {
           addr == addr_from_sel_targ;
       }
      }

    function new(string name = "chi_subsys_base_item");
        super.new(name);
	if(en_delay) begin
          LONG_DELAY_wt = 50;
          SHORT_DELAY_wt = 50;
          MIN_DELAY_wt = 50;
	end else begin
          LONG_DELAY_wt = 0;
          SHORT_DELAY_wt = 0;
          MIN_DELAY_wt = 100;
	end
    endfunction: new
    
    function void pre_randomize();
        super.pre_randomize();
         if (!($value$plusargs("k_csr_access_only=%d",csr_access)) && !($value$plusargs("use_csr_memregion=%d",csr_access)))  csr_access = 0;
         if (!($value$plusargs("use_chi_dvm=%d",use_dvm)) && !($value$plusargs("use_dvm=%d",use_dvm)))  use_dvm = 0;
         if (!($value$plusargs("chi_coh_dii_test_err=%d",chi_coh_dii_test_err)))  chi_coh_dii_test_err =0;
         if (!($value$plusargs("disable_atomic_checker=%b",disable_atomic_constraint_to_dmi_with_no_atomic_support)))  disable_atomic_constraint_to_dmi_with_no_atomic_support=0;
         if (!($value$plusargs("forbidden_stashnid=%d",forbidden_stashnid)))  forbidden_stashnid=0;
         if(!$value$plusargs("GEN_SEL_TARG_ADDR=%0b",GEN_SEL_TARG_ADDR))  GEN_SEL_TARG_ADDR = 0;
         if(!$value$plusargs("test_targ_unit_type=%0s",test_targ_unit_type)) test_targ_unit_type = "DII"; /* "DII" OR "DMI" */
         if(!$value$plusargs("test_targ_unit_id=%0d",test_targ_unit_id))  test_targ_unit_id=0; /* unit_type=DII : 0,1,2..., unit_type==DMI= 0,1,2...  */ 
         if(!$value$plusargs("test_targ_index_in_group=%0d",test_targ_index_in_group))  test_targ_index_in_group=0; /*For multiple mem region configured for any DII or DMI, select one of them.*/
         if(!$value$plusargs("test_targ_nc=%0d",test_targ_nc))  test_targ_nc=1;
         csrq = ncoreConfigInfo::get_all_gpra();
        m_addr_mgr = addr_trans_mgr::get_instance();
        if(GEN_SEL_TARG_ADDR==1) addr_from_sel_targ = gen_sel_targ_addr_from_unit_attr(test_targ_unit_type,test_targ_unit_id,test_targ_index_in_group,test_targ_nc);
	if(en_delay) begin
  	<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
	  this.req_to_comppersist_flit_delay.rand_mode(1);
	  this.req_to_persist_flit_delay.rand_mode(1);
	  this.req_to_persist_flit_delay.rand_mode(1);
  	<% } %>
	  this.req_to_comp_flit_delay.rand_mode(1);
	  this.req_to_compdata_flit_delay.rand_mode(1);
	  this.req_to_dbid_flit_delay.rand_mode(1);
	  this.dbid_to_comp_flit_delay.rand_mode(1);
	end


    endfunction: pre_randomize
    
    function void post_randomize();
        super.post_randomize();
              if (mem_attr_mem_type == DEVICE)  mem_attr_allocate_hint = 0; // CONC-13482
    endfunction: post_randomize

    function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_sel_targ_addr_from_unit_attr(
         string unit_type="DII", /* "DII" OR "DMI" */
         int unit_id=0, /* unit_type=DII : 0,1,2..., unit_type==DMI= 0,1,2...  */ 
         int index=0, /*For multiple mem region configured for any DII or DMI, select one of them.*/
         bit nc=1);
            return m_addr_mgr.gen_sel_targ_addr_from_unit_attr(unit_type,unit_id,index,nc);
    endfunction


endclass: chi_subsys_base_item
