class chi_subsys_error_item extends chi_subsys_noatomic_item; 

    `svt_xvm_object_utils(chi_subsys_error_item)

     int wt_data_flit_non_data_error;
     int wt_data_flit_data_error;

 constraint c_no_error_on_native_intf {
     `ifdef SVT_CHI_ISSUE_E_ENABLE
        if (
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
            xact_type == WRITECLEANFULL_CLEANSHAREDPERSISTSEP) 
        ){
            foreach (data_resp_err_status[index]){
                data_resp_err_status[index] inside {NORMAL_OKAY};
            }
        }
        response_resp_err_status == NORMAL_OKAY;
     `endif

    }
 constraint c_error_on_native_intf {
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
            (xact_type == WRITEUNIQUEPTL) ||
            (xact_type == WRITEEVICTFULL) ||
            xact_type == DVMOP
        ){
            foreach (data_resp_err_status[index]){
                data_resp_err_status[index] dist {
                       NORMAL_OKAY    :=50,
                       DATA_ERROR     :=wt_data_flit_data_error,
                       NON_DATA_ERROR :=wt_data_flit_non_data_error
                       };
            }
        }
        response_resp_err_status dist {
            NORMAL_OKAY := 50,
            NON_DATA_ERROR :=wt_data_flit_non_data_error,
            DATA_ERROR :=wt_data_flit_data_error
        };
    }
    function new(string name = "chi_subsys_error_item");
        super.new(name);
    endfunction: new

    function void pre_randomize();
      super.pre_randomize();
      if(!$value$plusargs("chi_data_flit_non_data_err=%0d", wt_data_flit_non_data_error))
          wt_data_flit_non_data_error = 25;
      if(!$value$plusargs("chi_data_flit_data_err=%0d", wt_data_flit_data_error))
          wt_data_flit_data_error = 25;
    endfunction : pre_randomize
 
   function void post_randomize();
        super.post_randomize();
    endfunction: post_randomize 
endclass: chi_subsys_error_item
