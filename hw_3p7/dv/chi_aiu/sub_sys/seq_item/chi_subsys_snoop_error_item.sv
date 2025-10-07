class chi_subsys_snoop_error_item extends chi_subsys_snoop_base_item;
    `svt_xvm_object_utils(chi_subsys_snoop_error_item)

    int wt_snprsp_with_non_data_error;
    int wt_snprsp_with_data_error;

    constraint c_no_snoop_resp_error {
      //overwrite with empty contraints
    }
    constraint c_snoop_resp_error {
        response_resp_err_status dist {
             NORMAL_OKAY    := 50,
             NON_DATA_ERROR := wt_snprsp_with_non_data_error,
             DATA_ERROR     := 0
        };
`ifdef SVT_CHI_ISSUE_B_ENABLE
         if(response_resp_err_status == svt_chi_common_transaction::NON_DATA_ERROR) {
            data_pull == 0;
         }
`endif
         foreach (data_resp_err_status[index]){
                data_resp_err_status[index] dist {
                       NORMAL_OKAY    := 50,
                       DATA_ERROR     := wt_snprsp_with_data_error,
                       NON_DATA_ERROR := 0
                       };
            }
      
        foreach (fwded_read_data_resp_err_status[idx]){
            fwded_read_data_resp_err_status[idx] dist {
                       NORMAL_OKAY := 50,
                       DATA_ERROR  := wt_snprsp_with_data_error,
                       NON_DATA_ERROR := 0
                       };
        }
    }
    function new(string name = "chi_subsys_snoop_error_item");
        super.new(name);
        SHORT_DELAY_wt = 0;
        LONG_DELAY_wt = 0;
        MIN_DELAY_wt = 100;
    endfunction: new

    function void pre_randomize();
      super.pre_randomize();
      if(!$value$plusargs("SNPrsp_with_non_data_error=%0d", wt_snprsp_with_non_data_error))
          wt_snprsp_with_non_data_error = 25;
      if(!$value$plusargs("SNPrsp_with_data_error=%0d", wt_snprsp_with_data_error))
          wt_snprsp_with_data_error = 25;
    endfunction : pre_randomize
    
    function void post_randomize();
        super.post_randomize();
    endfunction: post_randomize 
endclass: chi_subsys_snoop_error_item
