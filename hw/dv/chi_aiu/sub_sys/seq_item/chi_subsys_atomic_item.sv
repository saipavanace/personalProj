class chi_subsys_atomic_item extends chi_subsys_base_item; 
  `svt_xvm_object_utils(chi_subsys_atomic_item)
  
   rand bit select ;
   bit atomic_addr_constraint = 0;
   constraint c_select { select dist {0 := 30, 1 := 70 };}
   constraint c_atomic {
           (select == 0) ->   xact_type  inside {
     READNOSNP  
    ,WRITENOSNPFULL
    ,WRITENOSNPPTL 
    ,READCLEAN         
    ,READSHARED        
    ,READUNIQUE        
    ,READNOTSHAREDDIRTY
    ,WRITEUNIQUEFULL   
    ,WRITEUNIQUEPTL   
    ,DVMOP 
    ,WRITEBACKFULL
    ,WRITEBACKPTL
    ,EVICT
`ifdef SVT_CHI_ISSUE_E_ENABLE
    ,WRITEUNIQUEZERO            
    ,WRITENOSNPZERO             
    ,READPREFERUNIQUE           
`endif
             } ;
   (select == 1 ) -> xact_type inside {ATOMICSTORE_ADD, ATOMICSTORE_CLR, ATOMICSTORE_EOR, ATOMICSTORE_SET, ATOMICSTORE_SMAX, ATOMICSTORE_SMIN,
   ATOMICSTORE_UMAX, ATOMICSTORE_UMIN, ATOMICLOAD_ADD, ATOMICLOAD_CLR, ATOMICLOAD_EOR, ATOMICLOAD_SET, ATOMICLOAD_SMAX, ATOMICLOAD_SMIN,
   ATOMICLOAD_UMAX, ATOMICLOAD_UMIN, ATOMICSWAP,ATOMICCOMPARE};
   
   }

   constraint c_atomic_addr {
       if(atomic_addr_constraint) {
               addr == ncoreConfigInfo::memregions_info[0].start_addr;
       }
    }
   
    function new(string name = "chi_subsys_atomic_item");
        super.new(name);
    endfunction: new

    function void pre_randomize();
        super.pre_randomize();
        if ($test$plusargs("aiu_atomic_addr")) begin
            $value$plusargs("aiu_atomic_addr=%d", atomic_addr_constraint);
        end
    endfunction: pre_randomize
    
endclass: chi_subsys_atomic_item
