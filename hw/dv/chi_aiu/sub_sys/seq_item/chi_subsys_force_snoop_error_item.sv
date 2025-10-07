class chi_subsys_force_snoop_error_item extends chi_subsys_snoop_base_item;

    `svt_xvm_object_utils(chi_subsys_force_snoop_error_item)


   int                             SNPrsp_with_data_error_wgt;
   int                             SNPrsp_with_data_error;
   int                             SNPrsp_with_non_data_error;
   int                             SNPrsp_with_non_data_error_wgt;
   rand bit                        inject_data_error;


    constraint c_no_snoop_resp_error {
	 if(SNPrsp_with_non_data_error_wgt) {
		response_resp_err_status dist {
                    svt_chi_common_transaction::NORMAL_OKAY := 100 - SNPrsp_with_non_data_error_wgt,
                    svt_chi_common_transaction::NON_DATA_ERROR := SNPrsp_with_non_data_error_wgt
                };
	} else {
        	response_resp_err_status == svt_chi_common_transaction::NORMAL_OKAY;
	}
	
	if(SNPrsp_with_data_error_wgt) {
		inject_data_error dist {
                    0 := 100 - SNPrsp_with_data_error_wgt,
                    1 := SNPrsp_with_data_error_wgt
                };
	}

        foreach (data_resp_err_status[idx]){
	    if(inject_data_error) {
		data_resp_err_status[idx] inside {DATA_ERROR};
	    } else {
                data_resp_err_status[idx] inside {NORMAL_OKAY};
	    }
        }
        foreach (fwded_read_data_resp_err_status[idx]){
             fwded_read_data_resp_err_status[idx] inside {NORMAL_OKAY};
        }
	
	solve inject_data_error before data_resp_err_status;
    }

function new(string name = "chi_subsys_force_snoop_error_item");
        	 super.new(name);
           if ($value$plusargs("SNPrsp_with_data_error=%d",SNPrsp_with_data_error)) begin
              SNPrsp_with_data_error_wgt = SNPrsp_with_data_error ;
             end
           if ($value$plusargs("SNPrsp_with_non_data_error=%d",SNPrsp_with_non_data_error)) begin
              SNPrsp_with_non_data_error_wgt = SNPrsp_with_non_data_error ;
         end
endfunction

endclass



