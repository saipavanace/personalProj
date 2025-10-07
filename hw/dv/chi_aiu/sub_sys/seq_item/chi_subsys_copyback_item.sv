class chi_subsys_copyback_item extends chi_subsys_noatomic_item; 
  `svt_xvm_object_utils(chi_subsys_copyback_item)

  rand bit select ;
  rand bit allocate_in_cache;
  bit en_addr_constraint = 0;
  constraint reuse_cache { allocate_in_cache dist {0 := 50, 1 :=50 };}
  constraint c_select { select dist {0 := 20, 1 := 80 };}
  constraint c_copyback {
             (select == 0) -> xact_type inside {
    READCLEAN         
    ,READSHARED        
    ,READUNIQUE        
    ,READNOTSHAREDDIRTY
    ,WRITEUNIQUEFULL   
    ,READNOSNP   
    ,WRITEUNIQUEPTL   
    ,DVMOP 
`ifdef SVT_CHI_ISSUE_E_ENABLE
    , WRITEUNIQUEZERO            
    , READPREFERUNIQUE           
`endif 
    
    ,WRITEBACKFULL     
    ,WRITEBACKPTL      
    ,WRITEEVICTFULL    
    ,WRITECLEANFULL    
    ,WRITECLEANPTL     
    ,EVICT    
    ,MAKEUNIQUE
    ,MAKEREADUNIQUE 
    ,CLEANUNIQUE   
    ,WRITENOSNPFULL
    ,WRITENOSNPPTL  
`ifdef SVT_CHI_ISSUE_E_ENABLE
    ,WRITEEVICTOREVICT          
`endif 
          };
   (select == 1 ) -> xact_type inside {CLEANUNIQUE,MAKEREADUNIQUE};

 if(en_addr_constraint) {
    foreach(ncoreConfigInfo::memregions_info[region]) {
      (ncoreConfigInfo::memregions_info[region].hut == DMI) ->
         addr inside {[ncoreConfigInfo::memregions_info[region].start_addr : (ncoreConfigInfo::memregions_info[region].start_addr+'h10)]};
 }
  }
    }
    function new(string name = "chi_subsys_copyback_item");
        super.new(name);
        if ($test$plusargs("aiu_addr_contraint_en")) begin
            $value$plusargs("aiu_addr_contraint_en=%d", en_addr_constraint);
        end
    endfunction: new
   
    function void post_randomize();
        super.post_randomize();
    endfunction: post_randomize 
endclass: chi_subsys_copyback_item