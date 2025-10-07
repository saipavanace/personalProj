class chi_subsys_regular_item extends chi_subsys_noatomic_item; 
  `svt_xvm_object_utils(chi_subsys_regular_item)

   int alloc_rd_en = -1;
   int alloc_wr_en = -1;
  constraint c_regular {
             xact_type inside {
     READNOSNP  
    ,WRITENOSNPFULL
    ,WRITENOSNPPTL 
    ,READONCE         
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
          };
     if((alloc_wr_en != -1) && xact_type inside {
              WRITENOSNPFULL
             ,WRITENOSNPPTL 
             ,WRITEUNIQUEFULL   
             ,WRITEUNIQUEPTL    
         `ifdef SVT_CHI_ISSUE_E_ENABLE
             ,WRITEUNIQUEZERO            
             ,WRITENOSNPZERO             
         `endif        
     }) {mem_attr_allocate_hint == alloc_wr_en;}
     if((alloc_rd_en != -1) && xact_type inside {
             READNOSNP  
            ,READONCE         
            ,READCLEAN         
            ,READSHARED        
            ,READUNIQUE        
            ,READNOTSHAREDDIRTY
        `ifdef SVT_CHI_ISSUE_E_ENABLE
            ,READPREFERUNIQUE           
        `endif
     }) {mem_attr_allocate_hint == alloc_rd_en;}
    }
    function new(string name = "chi_subsys_regular_item");
        super.new(name);
         if (!($value$plusargs("alloc_rd_en=%d",alloc_rd_en))) alloc_rd_en= -1;
         if (!($value$plusargs("alloc_wr_en=%d",alloc_wr_en))) alloc_wr_en= -1;
    endfunction: new
    
endclass: chi_subsys_regular_item