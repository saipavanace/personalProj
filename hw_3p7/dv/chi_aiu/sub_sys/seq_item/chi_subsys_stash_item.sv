class chi_subsys_stash_item extends chi_subsys_base_item; 
  `svt_xvm_object_utils(chi_subsys_stash_item)
  
   rand bit select ;
   constraint c_select { select dist {0 := 30, 1 := 70 };}
   constraint c_stash {
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
`ifdef SVT_CHI_ISSUE_E_ENABLE
    ,WRITEUNIQUEZERO            
    ,WRITENOSNPZERO             
    ,READPREFERUNIQUE           
`endif
             } ;
   (select == 1 ) -> xact_type inside {STASHONCEUNIQUE,STASHONCESHARED};
   
   }
   
    function new(string name = "chi_subsys_stash_item");
        super.new(name);
    endfunction: new
    
    function void post_randomize();
        super.post_randomize();
    endfunction: post_randomize 

endclass: chi_subsys_stash_item