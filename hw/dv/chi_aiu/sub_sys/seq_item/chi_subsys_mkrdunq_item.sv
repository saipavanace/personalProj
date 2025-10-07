class chi_subsys_mkrdunq_item extends chi_subsys_base_item; 

    `svt_xvm_object_utils(chi_subsys_mkrdunq_item)

    constraint c_force_exclusive {
        if (svt_chi_item_helper::disable_boot_addr_region) {
            xact_type == MAKEREADUNIQUE -> is_exclusive == 1;
            xact_type == READPREFERUNIQUE -> is_exclusive == 0;
            xact_type == READSHARED -> is_exclusive == 1;
        }
    }

    constraint c_force_lpid {
        lpid == 5'd2;
    }

    function new(string name = "chi_subsys_mkrdunq_item");
        super.new(name);
    endfunction: new

endclass: chi_subsys_mkrdunq_item