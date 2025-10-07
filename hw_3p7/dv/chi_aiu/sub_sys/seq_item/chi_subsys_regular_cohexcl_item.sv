class chi_subsys_regular_cohexcl_item extends chi_subsys_noatomic_item; 
  `svt_xvm_object_utils(chi_subsys_regular_cohexcl_item)

  constraint c_regular {
             xact_type inside {
     CLEANUNIQUE  
    ,READCLEAN
    ,READSHARED 
          };
    }
    function new(string name = "chi_subsys_regular_cohexcl_item");
        super.new(name);
    endfunction: new
    
endclass: chi_subsys_regular_cohexcl_item
