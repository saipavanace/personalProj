import chi_ss_helper_pkg::*;

class chi_subsys_snoop_perf_item extends svt_chi_rn_snoop_transaction;
    `svt_xvm_object_utils(chi_subsys_snoop_perf_item)

    constraint c_no_snoop_resp_error {
        response_resp_err_status == svt_chi_common_transaction::NORMAL_OKAY;

        foreach (data_resp_err_status[idx]){
            data_resp_err_status[idx] inside {NORMAL_OKAY};
        }
        foreach (fwded_read_data_resp_err_status[idx]){
            fwded_read_data_resp_err_status[idx] inside {NORMAL_OKAY};
        }
    }
    
    constraint c_snoop_resp_data_transfer {
        snp_rsp_datatransfer == 1; //always provide data response to a snoop

    }


    function new(string name = "chi_subsys_snoop_perf_item");
        super.new(name);
        SHORT_DELAY_wt = 0;
        LONG_DELAY_wt = 0;
        MIN_DELAY_wt = 100;
    endfunction: new

endclass: chi_subsys_snoop_perf_item