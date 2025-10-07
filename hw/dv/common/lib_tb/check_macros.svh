`ifndef CHECKMACROSDEFINED
`define CHECKMACROSDEFINED
`define STRINGIFY(x) `"x`"
`define declare_check(checkname) \
          bit        checkname``_var = 0; \
          covergroup checkname``_cov; \
	    coverpoint checkname``_var {\
		 bins found = {1}; \
	     }\
	  endgroup \
          `define checkname``_CHECK

`define inst_check(checkname) checkname``_cov = new();

`define sample_check(checkname,checklabel,checktext,detailtext="",failcond=1,enablecheck=1) \
         `ifndef checkname``_CHECK \
           `uvm_fatal(get_instance_name(),$sformatf("%s is not declared!",`STRINGIFY(checkname)),UVM_NONE); \
	 `endif \
	  /*#checkname*/ \
	  if(checkname``_var == 0) begin \
	     checkname``_var = 1; \
	     checkname``_cov.sample(); \
	  end\
	  if(failcond && (enablecheck == 1)) begin \
	     `uvm_info(checklabel,$sformatf("%s %s",checktext,detailtext),UVM_NONE); \
	     `uvm_error(checklabel,checktext); \
	  end
`endif


