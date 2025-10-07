class chi_subsys_nondata_item extends chi_subsys_noatomic_item; 
  `svt_xvm_object_utils(chi_subsys_nondata_item)
  int dtrudty_case; 

  constraint c_nondata {
      if(!dtrudty_case) {
             xact_type inside {
     READCLEAN         
    ,READSHARED        
    ,READUNIQUE        
    ,READNOTSHAREDDIRTY
    ,WRITEUNIQUEFULL   
    ,WRITEUNIQUEPTL  
    ,DVMOP  
`ifdef SVT_CHI_ISSUE_E_ENABLE
    , WRITEUNIQUEZERO            
    , WRITENOSNPZERO             
    , READPREFERUNIQUE           
`endif 
    ,READONCECLEANINVALID 
    ,READONCEMAKEINVALID 
    ,CLEANUNIQUE       
    ,MAKEUNIQUE       
    ,CLEANSHARED       
    ,CLEANINVALID      
    ,MAKEINVALID      
    ,PREFETCHTGT
    ,WRITEBACKFULL
    ,WRITEBACKPTL
    ,EVICT
 `ifdef SVT_CHI_ISSUE_E_ENABLE
    ,CLEANSHAREDPERSIST   
    ,MAKEREADUNIQUE             
    ,WRITENOSNPFULL_CLEANSHARED  
    ,WRITENOSNPFULL_CLEANINVALID 
    ,WRITENOSNPFULL_CLEANSHAREDPERSISTSEP 
    ,WRITEBACKFULL_CLEANSHARED  
    ,WRITEBACKFULL_CLEANINVALID 
    ,WRITEBACKFULL_CLEANSHAREDPERSISTSEP
    ,WRITECLEANFULL_CLEANSHARED 
    ,WRITECLEANFULL_CLEANSHAREDPERSISTSEP   
 `endif
          };
    }
    }

    constraint chi0_clnunq {
      if(dtrudty_case) {
          (cfg.node_id == 0) ->  xact_type inside {CLEANUNIQUE,WRITENOSNPFULL};
          (cfg.node_id == 1) ->  xact_type inside {READUNIQUE,READNOSNP};
      }
    }    
    function new(string name = "chi_subsys_nondata_item");
        super.new(name);
        if ($test$plusargs("dtrudty_case")) dtrudty_case =1; 
    endfunction: new
    
    function void post_randomize();
        super.post_randomize();
    endfunction: post_randomize 
  
endclass: chi_subsys_nondata_item
