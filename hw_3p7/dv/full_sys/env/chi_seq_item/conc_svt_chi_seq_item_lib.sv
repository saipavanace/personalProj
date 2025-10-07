`ifndef GUARD_CONC_SVT_CHI_SEQ_ITEM_LIB_SV
`define GUARD_CONC_SVT_CHI_SEQ_ITEM_LIB_SV

class conc_base_svt_chi_rn_transaction extends svt_chi_rn_transaction; 

    `svt_xvm_object_utils(conc_base_svt_chi_rn_transaction)

    constraint c_no_error_on_native_intf {
        if (
            (xact_type == WRITEBACKFULL) ||
            (xact_type == WRITEBACKPTL) ||
            (xact_type == WRITECLEANFULL) ||
            (xact_type == WRITECLEANPTL) ||
            (xact_type == WRITENOSNPFULL) ||
            (xact_type == WRITENOSNPPTL) ||
            (xact_type == WRITEUNIQUEFULL) ||
     `ifdef SVT_CHI_ISSUE_B_ENABLE
            (xact_type == WRITEUNIQUEFULLSTASH) ||
            (xact_type == WRITEUNIQUEPTLSTASH) ||
     `endif
     `ifdef SVT_CHI_ISSUE_E_ENABLE
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
            xact_type == WRITECLEANFULL_CLEANSHAREDPERSISTSEP) ||
     `endif
            (xact_type == WRITEUNIQUEPTL) ||
            (xact_type == WRITEEVICTFULL) ||
            xact_type == DVMOP
        ){
            foreach (data_resp_err_status[index]){
                data_resp_err_status[index] inside {NORMAL_OKAY};
            }
        }
        response_resp_err_status == NORMAL_OKAY;
    }

`ifdef SVT_CHI_ISSUE_B_ENABLE
    // Ncore doesnt not support big endian access
    constraint c_endianess_is_little {
        endian == svt_chi_rn_transaction::LITTLE_ENDIAN;
    }
`endif    

    function new(string name = "conc_base_svt_chi_rn_transaction");
        super.new(name);
    endfunction: new

    function void post_randomize();
        super.post_randomize();
    endfunction: post_randomize
endclass: conc_base_svt_chi_rn_transaction    

`endif // `ifndef GUARD_CONC_SVT_CHI_SEQ_ITEM_LIB_SV 
