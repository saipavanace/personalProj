class chi_subsys_noatomic_item extends chi_subsys_base_item; 
  `svt_xvm_object_utils(chi_subsys_noatomic_item)

  bit all_noncoh_gpra;
  bit random_gpra_nsx;

   bit en_addr_constraint = 0;
  // disable atomics
  constraint c_no_atomics {
             !( xact_type inside {
                ATOMICSTORE_ADD, ATOMICSTORE_CLR, ATOMICSTORE_EOR, ATOMICSTORE_SET, ATOMICSTORE_SMAX, ATOMICSTORE_SMIN,
                ATOMICSTORE_UMAX, ATOMICSTORE_UMIN, ATOMICLOAD_ADD, ATOMICLOAD_CLR, ATOMICLOAD_EOR, ATOMICLOAD_SET, ATOMICLOAD_SMAX, ATOMICLOAD_SMIN,
                ATOMICLOAD_UMAX, ATOMICLOAD_UMIN, ATOMICSWAP,ATOMICCOMPARE
            });
       //if(en_addr_constraint) {
       //   foreach(ncoreConfigInfo::memregions_info[region]) {
       //     (ncoreConfigInfo::memregions_info[region].hut == DMI) ->
       //        addr inside {[ncoreConfigInfo::memregions_info[region].start_addr : (ncoreConfigInfo::memregions_info[region].start_addr+'h80)]};
       //}
       // }
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
                    ,STASHONCESEPUNIQUE
                    ,STASHONCESEPSHARED
                    ,WRITEEVICTOREVICT     
              `endif // `ifdef SVT_CHI_ISSUE_E_ENABLE
                });
  }
    
    constraint c_disable_snpattr {
        (all_noncoh_gpra) -> snp_attr_is_snoopable == 0;
    }

    
    constraint c_non_secure_access {
        (random_gpra_nsx) -> is_non_secure_access == ncoreConfigInfo::get_addr_gprar_nsx(addr);
    }

    constraint solve_addr_before_security {
       solve addr before is_non_secure_access;
    }
    
    function new(string name = "chi_subsys_noatomic_item");
        super.new(name);
        <% if ( obj.testBench =="fsys") { %>
        stash_nid_valid= 1; //use stashnid  
        <% }%>
        if (!$value$plusargs("all_gpra_ncmode=%0d", all_noncoh_gpra)) begin
            all_noncoh_gpra = 0;
        end
        if ($test$plusargs("random_gpra_nsx")) 
            random_gpra_nsx = 1;
        else
            random_gpra_nsx = 0; 
    endfunction: new

    function void pre_randomize();
        super.pre_randomize();
        if ($test$plusargs("aiu_addr_contraint_en")) begin
            $value$plusargs("aiu_addr_contraint_en=%d", en_addr_constraint);
        end
    endfunction: pre_randomize
 
    function void post_randomize();
        super.post_randomize();
    endfunction: post_randomize 
endclass: chi_subsys_noatomic_item
