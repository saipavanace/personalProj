`ifndef CHI_SS_HELPER_PKG
`define CHI_SS_HELPER_PKG

package chi_ss_helper_pkg;
    static int k_directed_excl = -1;
    static int k_directed_lpid = -1;
    static int k_exp_comp_ack  = -1;
    static bit k_disable_boot_addr = 0;
    static bit en_delay = 0;

    static int reserved_ids[] = {1,3,5,9,17,33,65,129,257,513,1025,2049};

    string chi_seq_item; 

    function void disable_directed_constraints();
        k_directed_excl = -1;
        k_directed_lpid = -1;
        k_exp_comp_ack  = -1;
        k_disable_boot_addr = 0;
    endfunction: disable_directed_constraints
    
endpackage: chi_ss_helper_pkg 

`endif
