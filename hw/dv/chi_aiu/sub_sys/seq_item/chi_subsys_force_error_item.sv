class chi_subsys_force_error_item extends chi_subsys_base_item;
	`svt_xvm_object_utils(chi_subsys_force_error_item)

int chi_data_flit_data_err;
int wt_chi_data_flit_with_poison;
int unmapped_add_enabled = 0;
rand int  unsigned dmi_memory_domain_index;
rand int  unsigned dii_memory_domain_index;

    constraint c_no_error_on_native_intf {
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
                    data_resp_err_status[index] dist {
                       NORMAL_OKAY    :=100-chi_data_flit_data_err,
                       DATA_ERROR     :=chi_data_flit_data_err
                       };
            }
        }
    }

constraint data_poison {
                if (wt_chi_data_flit_with_poison > 0) 
                      { poison dist { 0 := (100-wt_chi_data_flit_with_poison), [1:((2**SVT_CHI_NODE_WPOSION)-1)] :/ wt_chi_data_flit_with_poison }; } }

constraint c_unmapp_addr {
       if(unmapped_add_enabled) {
              foreach (ncoreConfigInfo::dmi_memory_domain_start_addr[i]) {
                    !( addr inside {[ncoreConfigInfo::dmi_memory_domain_start_addr[i]:(ncoreConfigInfo::dmi_memory_domain_end_addr[i])]});
                 }

              foreach (ncoreConfigInfo::dii_memory_domain_start_addr[i]) {
                   !(addr inside {[ncoreConfigInfo::dii_memory_domain_start_addr[i]:
                                                                       ncoreConfigInfo::dii_memory_domain_end_addr[i]]}); 
                 }
              !addr inside  {[ncoreConfigInfo::BOOT_REGION_BASE:ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_BASE-1]};

       }
    }

	function new(string name = "chi_subsys_force_error_item");
        	 super.new(name);
                 void'($value$plusargs("chi_data_flit_data_err=%0d",chi_data_flit_data_err));
                 void'($value$plusargs("wt_chi_data_flit_with_poison=%d",wt_chi_data_flit_with_poison));
                 void'($value$plusargs("unmapped_add_enabled=%d",unmapped_add_enabled));
 	endfunction

endclass

