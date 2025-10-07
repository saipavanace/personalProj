package ioaiu_unit_args_pkg;

import uvm_pkg::*;
import common_knob_pkg::*;
`include "uvm_macros.svh"

class ioaiu_unit_args extends uvm_object;

	`uvm_object_utils(ioaiu_unit_args)
  
  	uvm_cmdline_processor clp;
    
  	//master agent configs
    int wt_ace_rdnosnp                        = 0;
    int wt_ace_rdonce                         = 0;
    int wt_ace_rdshrd                         = 0;
	int wt_ace_rdcln                          = 0;
    int wt_ace_rdnotshrddty                   = 0;
    int wt_ace_rdunq                          = 0;
    int wt_ace_clnunq                         = 0;
    int wt_ace_mkunq                          = 0;
    int wt_ace_dvm_msg                        = 0;
    int wt_ace_dvm_sync                       = 0;
    int wt_ace_clnshrd                        = 0;
    int wt_ace_clnshrd_pers                   = 0;
    int wt_ace_clninvl                        = 0;
    int wt_ace_mkinvl                         = 0;
    int wt_ace_rd_bar                         = 0;
    int wt_ace_wrnosnp                        = 0;
    int wt_ace_wrunq                          = 0;
    int wt_ace_wrlnunq                        = 0;
    int wt_ace_wrcln                          = 0;
    int wt_ace_wrbk                           = 0;
    int wt_ace_wrevct                         = 0;
    int wt_ace_evct                           = 0;
    int wt_ace_wr_bar                         = 0;
    int wt_ace_atm_str                        = 0;
    int wt_ace_atm_ld                         = 0;
    int wt_ace_atm_swap                       = 0;
    int wt_ace_atm_comp                       = 0;
    int wt_ace_rd_cln_invld                   = 0;
    int wt_ace_rd_make_invld                  = 0;
    int wt_ace_ptl_stash                      = 0;
    int wt_ace_full_stash                     = 0;
    int wt_ace_shared_stash                   = 0;
    int wt_ace_unq_stash                      = 0;
    int wt_ace_stash_trans                    = 0;

	function new(string s = "ioaiu_unit_args");
    	super.new(s);
    	clp = uvm_cmdline_processor::get_inst();

		//Goal: update to use common_knob_class 
		//ncore does not support bar and stash trans
    	wt_ace_wrbk = 0;
        wt_ace_stash_trans = 0;

		<%if((obj.DutInfo.fnNativeInterface == "ACE-LITE") || (obj.DutInfo.fnNativeInterface == "ACELITE-E")){%>
		//Below commands not mastered by ACE-LITE/ACE-LITE-E 
        wt_ace_rdshrd                         = 0;
        wt_ace_rdcln                          = 0;
        wt_ace_rdnotshrddty                   = 0;
        wt_ace_rdunq                          = 0;
        wt_ace_clnunq                         = 0;
        wt_ace_mkunq                          = 0;
    <%}else{%>    
        wt_ace_rdshrd                         = $urandom_range(1,100);
        wt_ace_rdcln                          = $urandom_range(1,100);
        wt_ace_rdnotshrddty                   = $urandom_range(1,100);
        wt_ace_rdunq                          = $urandom_range(1,100);
        wt_ace_clnunq                         = $urandom_range(1,100);
        wt_ace_mkunq                          = $urandom_range(1,100);
    <%}%>      
  	endfunction: new

  	function void parse_args_from_cmdline();

    	string arg_value;
    	string myargs[$];
	
    	if (clp.get_arg_matches("+allocating_ops", myargs)) begin
        	clear_wt_all_ops();
        	wt_ace_rdshrd                         = $urandom_range(1,100);
        	wt_ace_rdcln                          = $urandom_range(1,100);
        	wt_ace_rdnotshrddty                   = $urandom_range(1,100);
        	wt_ace_rdunq                          = $urandom_range(1,100);
        	wt_ace_clnunq                         = $urandom_range(1,100);
        	wt_ace_mkunq                          = $urandom_range(1,100);
		end        

	endfunction: parse_args_from_cmdline

	function void clear_wt_all_ops();

	endfunction: clear_wt_all_ops

endclass:ioaiu_unit_args

endpackage:ioaiu_unit_args_pkg
