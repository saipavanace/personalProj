
package <%=obj.BlockId%>_dii_args_pkg;

import uvm_pkg::*;
import common_knob_pkg::*;
`include "uvm_macros.svh"

//import dii_env_pkg::*;
import <%=obj.BlockId%>_env_pkg::*;

class dii_args extends uvm_object;

  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
  bit k_slow_system = 0;  //not from cli

<% if(obj.testBench == 'dii' || obj.testBench == 'fsys') { %>
   `ifdef VCS
    `define VCSorCDNS
   `elsif CDNS
    `define VCSorCDNS
   `endif 
<% }  %>

  //tb knobs
  bit k_randomize    = 1;
  int k_timeout      = 1000000;
  bit dii_scb_en     = 1;
  bit k_smi_cov_en   = 1;
  bit tcap_scb_en = 1;

  // sequence knobs
  string  k_csr_seq   = "";
  
  //SMI knobs
  <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiRx; i++) { %>
    int k_smi<%=i%>_tx_port_delay_min    = 0;
    int k_smi<%=i%>_tx_port_delay_max    = 1;
    int k_smi<%=i%>_tx_port_burst_pct    = 80;
    bit k_smi<%=i%>_tx_port_slow_port    = 0;
    int smi<%=i%>_tx_port_prob_slow_port = 35;

    bit smi<%=i%>_tx_port_delay_export            = 0;
    bit smi<%=i%>_tx_port_change_delays_over_time = 0;

  <% } %>
  <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiTx; i++) { %>
    int k_smi<%=i%>_rx_port_delay_min    = 0;
    int k_smi<%=i%>_rx_port_delay_max    = 1;
    int k_smi<%=i%>_rx_port_burst_pct    = 80;
    bit k_smi<%=i%>_rx_port_slow_port    = 0;
    int smi<%=i%>_rx_port_prob_slow_port = 35;

    bit smi<%=i%>_rx_port_delay_export            = 0;
    bit smi<%=i%>_rx_port_change_delays_over_time = 0;

  <% } %>

/*
  //AXI knobs
  int k_ace_slave_read_addr_chnl_delay_min   = 0;
  int k_ace_slave_read_addr_chnl_delay_max   = 1;
  int k_ace_slave_read_addr_chnl_burst_pct   = 80;
  int k_ace_slave_read_data_chnl_delay_min   = 0;
  int k_ace_slave_read_data_chnl_delay_max   = 1;
  int k_ace_slave_read_data_chnl_burst_pct   = 80;
  int k_ace_slave_read_data_reorder_size     = 4;
  int k_ace_slave_write_addr_chnl_delay_min  = 0;
  int k_ace_slave_write_addr_chnl_delay_max  = 1;
  int k_ace_slave_write_addr_chnl_burst_pct  = 80;
  int k_ace_slave_write_data_chnl_delay_min  = 0;
  int k_ace_slave_write_data_chnl_delay_max  = 1;
  int k_ace_slave_write_data_chnl_burst_pct  = 80;
  int k_ace_slave_write_resp_chnl_delay_min  = 0;
  int k_ace_slave_write_resp_chnl_delay_max  = 1;
  int k_ace_slave_write_resp_chnl_burst_pct  = 80;
  int k_ace_slave_read_data_interleave_dis   = 0;
*/
  bit k_slow_agent                           = 0;
  bit k_slow_read_agent                      = 0;
  bit k_slow_write_agent                     = 0;
  

   int prob_ace_rd_resp_error                = 10;
   int prob_ace_wr_resp_error                = 10;


    //APB knobs
<% if(obj.INHOUSE_APB_VIP) { %>
   int k_apb_mcmd_delay_min                      = 0;
   int k_apb_mcmd_delay_max                      = 1;
   int k_apb_mcmd_burst_pct                      = 90;
   bit k_apb_mcmd_wait_for_scmdaccept            = 0;

   int k_apb_maccept_delay_min                   = 0;
   int k_apb_maccept_delay_max                   = 1;
   int k_apb_maccept_burst_pct                   = 90;
   bit k_apb_maccept_wait_for_sresp              = 0;

   bit k_slow_apb_agent                          = 0;
   bit k_slow_apb_mcmd_agent                     = 0;
   bit k_slow_apb_mrespaccept_agent              = 0;
   <% } %>


    
    //represent each field in uvm config_db
  `uvm_object_param_utils_begin(dii_args)
 
  //tb knobs
	`uvm_field_int(k_randomize		,UVM_DEC);
	`uvm_field_int(k_timeout		,UVM_DEC);
	`uvm_field_int(dii_scb_en		,UVM_DEC);
  `uvm_field_int(tcap_scb_en		,UVM_DEC);
	`uvm_field_int(k_smi_cov_en ,UVM_DEC);
    `uvm_field_string(k_csr_seq		,UVM_DEC);
  
  //SMI knobs
  <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiRx; i++) { %>
	`uvm_field_int(k_smi<%=i%>_tx_port_delay_min		,UVM_DEC);
	`uvm_field_int(k_smi<%=i%>_tx_port_delay_max		,UVM_DEC);
	`uvm_field_int(k_smi<%=i%>_tx_port_burst_pct		,UVM_DEC);
	`uvm_field_int(k_smi<%=i%>_tx_port_slow_port		,UVM_DEC);
	`uvm_field_int(smi<%=i%>_tx_port_prob_slow_port		,UVM_DEC);

	`uvm_field_int(smi<%=i%>_tx_port_delay_export		,UVM_DEC);
	`uvm_field_int(smi<%=i%>_tx_port_change_delays_over_time		,UVM_DEC);

  <% } %>
  <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiTx; i++) { %>
	`uvm_field_int(k_smi<%=i%>_rx_port_delay_min		,UVM_DEC);
	`uvm_field_int(k_smi<%=i%>_rx_port_delay_max		,UVM_DEC);
	`uvm_field_int(k_smi<%=i%>_rx_port_burst_pct		,UVM_DEC);
	`uvm_field_int(k_smi<%=i%>_rx_port_slow_port		,UVM_DEC);
	`uvm_field_int(smi<%=i%>_rx_port_prob_slow_port		,UVM_DEC);

	`uvm_field_int(smi<%=i%>_rx_port_delay_export		,UVM_DEC);
	`uvm_field_int(smi<%=i%>_rx_port_change_delays_over_time		,UVM_DEC);

  <% } %>
/*
  //AXI knobs
	`uvm_field_int(k_ace_slave_read_addr_chnl_delay_min		,UVM_DEC);
	`uvm_field_int(k_ace_slave_read_addr_chnl_delay_max		,UVM_DEC);
	`uvm_field_int(k_ace_slave_read_addr_chnl_burst_pct		,UVM_DEC);
	`uvm_field_int(k_ace_slave_read_data_chnl_delay_min		,UVM_DEC);
	`uvm_field_int(k_ace_slave_read_data_chnl_delay_max		,UVM_DEC);
	`uvm_field_int(k_ace_slave_read_data_chnl_burst_pct		,UVM_DEC);
	`uvm_field_int(k_ace_slave_read_data_reorder_size		,UVM_DEC);
	`uvm_field_int(k_ace_slave_write_addr_chnl_delay_min		,UVM_DEC);
	`uvm_field_int(k_ace_slave_write_addr_chnl_delay_max		,UVM_DEC);
	`uvm_field_int(k_ace_slave_write_addr_chnl_burst_pct		,UVM_DEC);
	`uvm_field_int(k_ace_slave_write_data_chnl_delay_min		,UVM_DEC);
	`uvm_field_int(k_ace_slave_write_data_chnl_delay_max		,UVM_DEC);
	`uvm_field_int(k_ace_slave_write_data_chnl_burst_pct		,UVM_DEC);
	`uvm_field_int(k_ace_slave_write_resp_chnl_delay_min		,UVM_DEC);
	`uvm_field_int(k_ace_slave_write_resp_chnl_delay_max		,UVM_DEC);
	`uvm_field_int(k_ace_slave_write_resp_chnl_burst_pct		,UVM_DEC);
    	`uvm_field_int(k_ace_slave_read_data_interleave_dis  ,UVM_DEC);
*/
    `uvm_field_int(k_slow_agent        ,UVM_DEC);
    `uvm_field_int(k_slow_read_agent        ,UVM_DEC); 
    `uvm_field_int(k_slow_write_agent        ,UVM_DEC);


     `uvm_field_int(prob_ace_rd_resp_error               ,UVM_DEC);
     `uvm_field_int(prob_ace_wr_resp_error               ,UVM_DEC);

  
    //APB knobs
<% if(obj.INHOUSE_APB_VIP) { %>
	`uvm_field_int(k_apb_mcmd_delay_min		,UVM_DEC);
	`uvm_field_int(k_apb_mcmd_delay_max		,UVM_DEC);
	`uvm_field_int(k_apb_mcmd_burst_pct		,UVM_DEC);
	`uvm_field_int(k_apb_mcmd_wait_for_scmdaccept		,UVM_DEC);

	`uvm_field_int(k_apb_maccept_delay_min		,UVM_DEC);
	`uvm_field_int(k_apb_maccept_delay_max		,UVM_DEC);
	`uvm_field_int(k_apb_maccept_burst_pct		,UVM_DEC);
	`uvm_field_int(k_apb_maccept_wait_for_sresp		,UVM_DEC);

	`uvm_field_int(k_slow_apb_agent		,UVM_DEC);
	`uvm_field_int(k_slow_apb_mcmd_agent		,UVM_DEC);
	`uvm_field_int(k_slow_apb_mrespaccept_agent		,UVM_DEC);
<% } %>

  `uvm_object_utils_end


  const int             m_weights_for_k_sram_single_err_pct[1]   = {100};
<% if(obj.testBench == 'dii' || obj.testBench == 'fsys') { %>
`ifdef VCSorCDNS
  const t_minmax_range  m_minmax_for_k_sram_single_err_pct[1]    = '{'{m_min_range:1,m_max_range:100}};
`else // `ifdef VCSorCDNS
  const t_minmax_range  m_minmax_for_k_sram_single_err_pct[1]    = {{1,100}};
`endif // `ifdef VCSorCDNS ... `else ...
<% } else {%>
  const t_minmax_range  m_minmax_for_k_sram_single_err_pct[1]    = {{1,100}};
<% } %>

  const int             m_weights_for_k_sram_double_err_pct[1]   = {100};
<% if(obj.testBench == 'dii' || obj.testBench == 'fsys') { %>
`ifdef VCSorCDNS
  const t_minmax_range  m_minmax_for_k_sram_double_err_pct[1]    = '{'{m_min_range:1,m_max_range:100}};
`else // `ifdef VCSorCDNS
  const t_minmax_range  m_minmax_for_k_sram_double_err_pct[1]    = {{1,100}};
`endif // `ifdef VCSorCDNS ... `else ...
<% } else {%>
  const t_minmax_range  m_minmax_for_k_sram_double_err_pct[1]    = {{1,100}};
<% } %>
  
  //Total number of requests  
  common_knob_class k_sram_single_err_pct = new ("k_sram_single_err_pct", this, m_weights_for_k_sram_single_err_pct, m_minmax_for_k_sram_single_err_pct);
  common_knob_class k_sram_double_err_pct = new ("k_sram_double_err_pct", this, m_weights_for_k_sram_double_err_pct, m_minmax_for_k_sram_double_err_pct);



  function new(string s = "dii_args");
    super.new(s);
    clp = uvm_cmdline_processor::get_inst();
  endfunction: new

  //helper fns - set from plusarg or rand, return true iff plusarg found
  
  function bit plusarg_get_str(ref string field, input string name);
      string arg_value;
      // 
      if (clp.get_arg_value({"+",name,"="}, arg_value)) begin
          field = arg_value;
          `uvm_info("", $sformatf("plusarg got \t%s \t== \t%p",name, field), UVM_MEDIUM);
          return 1;
      end
      else
          return 0;
  endfunction : plusarg_get_str
  
  function bit plusarg_get_int(ref int field, input string name);
      string arg_value;
      if( plusarg_get_str(arg_value, name) ) begin
          field = arg_value.atoi();
          `uvm_info("", $sformatf("plusarg got \t%s \t== \t%p",name, field), UVM_MEDIUM);
          return 1;
      end
      else begin
          `uvm_info("", $sformatf("plusarg default \t%s \t== \t%p",name, field), UVM_MEDIUM);
          return 0;
      end
  endfunction : plusarg_get_int 
  
  function bit plusarg_rand(ref int field, input string name, int lower = -1, int upper = -1);
      if( plusarg_get_int(field, name) ) 
          return 1;
      else if(k_randomize) begin
          if( (lower >= 0) && (upper >= 0) ) begin
              field = $urandom_range(lower, upper);
              `uvm_info("", $sformatf("plusarg random \t%s \t== \t%p",name, field), UVM_MEDIUM); 
          end
      end
      else begin
          $display("plusarg default \t%s\t== \t%p",name, field);
          return 0;
      end
  endfunction: plusarg_rand
  
  //----
  
  function bit plusarg_get_bit(ref bit field, input string name);
      string arg_value;
      // 
      if (clp.get_arg_value({"+",name,"="}, arg_value)) begin
          field = (1'b1 & arg_value.atoi());
          `uvm_info("", $sformatf("plusarg got \t%s \t== \t%p",name, field), UVM_MEDIUM); 
          return 1;
      end
      else
         return 0;
  endfunction : plusarg_get_bit
  
  function bit plusarg_rand_bit(ref bit field, input string name, int percent = 50);
      if( plusarg_get_bit(field, name) ) 
          return 1;
      else if(k_randomize) begin
              int pick = $urandom_range(0,99);
              field = (pick < percent) ;
          `uvm_info("", $sformatf("plusarg random \t%s \t== \t%p",name, field), UVM_MEDIUM); 
      end
      else begin
          $display("plusarg default \t%s\t== \t%p",name, field);
          return 0;
      end
  endfunction: plusarg_rand_bit
  
  
  //------------------------------------------
  

  function void grab_and_parse_args_from_cmdline(ref dii_env_config m_env_cfg);
    string arg_value;
    string myargs[$];
    bit flag = 0;
    bit useMemRspIntrlv = 0;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  Collect default knobs
/*  
    //tb knobs
  	uvm_config_db#(bit)::get(this,"","k_randomize",k_randomize);
  	uvm_config_db#(int)::get(this,"","k_timeout",k_timeout);
  	uvm_config_db#(bit)::get(this,"","dii_scb_en",dii_scb_en);
      
    uvm_config_db#(string)::get(this,"","k_csr_seq",k_csr_seq);
    
    //SMI knobs
    <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiRx; i++) { %>
  	uvm_config_db#(int)::get(this,"","k_smi<%=i%>_tx_port_delay_min",k_smi<%=i%>_tx_port_delay_min);
  	uvm_config_db#(int)::get(this,"","k_smi<%=i%>_tx_port_delay_max",k_smi<%=i%>_tx_port_delay_max);
  	uvm_config_db#(int)::get(this,"","k_smi<%=i%>_tx_port_burst_pct",k_smi<%=i%>_tx_port_burst_pct);
  	uvm_config_db#(bit)::get(this,"","k_smi<%=i%>_tx_port_slow_port",k_smi<%=i%>_tx_port_slow_port);
  	uvm_config_db#(int)::get(this,"","smi<%=i%>_tx_port_prob_slow_port",smi<%=i%>_tx_port_prob_slow_port);
  
  	uvm_config_db#(bit)::get(this,"","smi<%=i%>_tx_port_delay_export",smi<%=i%>_tx_port_delay_export);
  	uvm_config_db#(bit)::get(this,"","smi<%=i%>_tx_port_change_delays_over_time",smi<%=i%>_tx_port_change_delays_over_time);
  
    <% } %>
    <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiTx; i++) { %>
  	uvm_config_db#(int)::get(this,"","k_smi<%=i%>_rx_port_delay_min",k_smi<%=i%>_rx_port_delay_min);
  	uvm_config_db#(int)::get(this,"","k_smi<%=i%>_rx_port_delay_max",k_smi<%=i%>_rx_port_delay_max);
  	uvm_config_db#(int)::get(this,"","k_smi<%=i%>_rx_port_burst_pct",k_smi<%=i%>_rx_port_burst_pct);
  	uvm_config_db#(bit)::get(this,"","k_smi<%=i%>_rx_port_slow_port",k_smi<%=i%>_rx_port_slow_port);
  	uvm_config_db#(int)::get(this,"","smi<%=i%>_rx_port_prob_slow_port",smi<%=i%>_rx_port_prob_slow_port);
  
  	uvm_config_db#(bit)::get(this,"","smi<%=i%>_rx_port_delay_export",smi<%=i%>_rx_port_delay_export);
  	uvm_config_db#(bit)::get(this,"","smi<%=i%>_rx_port_change_delays_over_time",smi<%=i%>_rx_port_change_delays_over_time);
  
    <% } %>
  
    //AXI knobs
  	uvm_config_db#(int)::get(this,"","k_ace_slave_read_addr_chnl_delay_min",k_ace_slave_read_addr_chnl_delay_min);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_read_addr_chnl_delay_max",k_ace_slave_read_addr_chnl_delay_max);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_read_addr_chnl_burst_pct",k_ace_slave_read_addr_chnl_burst_pct);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_read_data_chnl_delay_min",k_ace_slave_read_data_chnl_delay_min);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_read_data_chnl_delay_max",k_ace_slave_read_data_chnl_delay_max);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_read_data_chnl_burst_pct",k_ace_slave_read_data_chnl_burst_pct);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_read_data_reorder_size",k_ace_slave_read_data_reorder_size);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_write_addr_chnl_delay_min",k_ace_slave_write_addr_chnl_delay_min);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_write_addr_chnl_delay_max",k_ace_slave_write_addr_chnl_delay_max);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_write_addr_chnl_burst_pct",k_ace_slave_write_addr_chnl_burst_pct);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_write_data_chnl_delay_min",k_ace_slave_write_data_chnl_delay_min);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_write_data_chnl_delay_max",k_ace_slave_write_data_chnl_delay_max);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_write_data_chnl_burst_pct",k_ace_slave_write_data_chnl_burst_pct);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_write_resp_chnl_delay_min",k_ace_slave_write_resp_chnl_delay_min);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_write_resp_chnl_delay_max",k_ace_slave_write_resp_chnl_delay_max);
  	uvm_config_db#(int)::get(this,"","k_ace_slave_write_resp_chnl_burst_pct",k_ace_slave_write_resp_chnl_burst_pct);
  
    uvm_config_db#(bit)::get(this,"","k_slow_agent",k_slow_agent);
    uvm_config_db#(bit)::get(this,"","k_slow_read_agent",k_slow_read_agent);
    uvm_config_db#(bit)::get(this,"","k_slow_write_agent",k_slow_write_agent);
  
  
      //APB knobs
  <% if(obj.INHOUSE_APB_VIP) { %>
  	uvm_config_db#(int)::get(this,"","k_apb_mcmd_delay_min",k_apb_mcmd_delay_min);
  	uvm_config_db#(int)::get(this,"","k_apb_mcmd_delay_max",k_apb_mcmd_delay_max);
  	uvm_config_db#(int)::get(this,"","k_apb_mcmd_burst_pct",k_apb_mcmd_burst_pct);
  	uvm_config_db#(bit)::get(this,"","k_apb_mcmd_wait_for_scmdaccept",k_apb_mcmd_wait_for_scmdaccept);
  
  	uvm_config_db#(int)::get(this,"","k_apb_maccept_delay_min",k_apb_maccept_delay_min);
  	uvm_config_db#(int)::get(this,"","k_apb_maccept_delay_max",k_apb_maccept_delay_max);
  	uvm_config_db#(int)::get(this,"","k_apb_maccept_burst_pct",k_apb_maccept_burst_pct);
  	uvm_config_db#(bit)::get(this,"","k_apb_maccept_wait_for_sresp",k_apb_maccept_wait_for_sresp);
  
  	uvm_config_db#(bit)::get(this,"","k_slow_apb_agent",k_slow_apb_agent);
  	uvm_config_db#(bit)::get(this,"","k_slow_apb_mcmd_agent",k_slow_apb_mcmd_agent);
  	uvm_config_db#(bit)::get(this,"","k_slow_apb_mrespaccept_agent",k_slow_apb_mrespaccept_agent);
     <% } %>
  
*/

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // cli plusargs and randomization

    //tb knobs
	plusarg_get_bit(k_randomize,"k_randomize");
	plusarg_get_int(k_timeout,"k_timeout");
	plusarg_get_bit(dii_scb_en,"dii_scb_en");
  plusarg_get_bit(tcap_scb_en,"tcap_scb_en");
	plusarg_get_bit(k_smi_cov_en,"k_smi_cov_en");

    // sequence knobs
	//plusarg_rand(k_num_addr,"k_num_addr",50,250);
	//plusarg_rand(k_num_cmd,"k_num_cmd",500,2000);

    //plusarg_rand(wt_cmd_rd_nc,"wt_cmd_rd_nc"); 
    //plusarg_rand(wt_cmd_wr_nc_ptl,"wt_cmd_wr_nc_ptl"); 
    //plusarg_rand(wt_cmd_wr_nc_full,"wt_cmd_wr_nc_full"); 
	
	//plusarg_rand(wt_reuse_addr,"wt_reuse_addr");
	//plusarg_rand(wt_order_request,"wt_order_request");
	//plusarg_rand(wt_order_endpoint,"wt_order_endpoint");
	
    plusarg_get_str(k_csr_seq,"k_csr_seq");
 
  //SMI knobs
  <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiRx; i++) { %>
	plusarg_rand(k_smi<%=i%>_tx_port_delay_min,"k_smi<%=i%>_tx_port_delay_min");
	plusarg_rand(k_smi<%=i%>_tx_port_delay_max,"k_smi<%=i%>_tx_port_delay_max");
	plusarg_rand(k_smi<%=i%>_tx_port_burst_pct,"k_smi<%=i%>_tx_port_burst_pct");
	plusarg_rand_bit(k_smi<%=i%>_tx_port_slow_port,"k_smi<%=i%>_tx_port_slow_port");
	plusarg_rand(smi<%=i%>_tx_port_prob_slow_port,"smi<%=i%>_tx_port_prob_slow_port");

	plusarg_rand_bit(smi<%=i%>_tx_port_delay_export,"smi<%=i%>_tx_port_delay_export");
    plusarg_rand_bit(smi<%=i%>_tx_port_change_delays_over_time,"smi<%=i%>_tx_port_change_delays_over_time");

  <% } %>
  <%for (var i = 0; i < obj.DiiInfo[obj.Id].nSmiTx; i++) { %>
	plusarg_rand(k_smi<%=i%>_rx_port_delay_min,"k_smi<%=i%>_rx_port_delay_min");
	plusarg_rand(k_smi<%=i%>_rx_port_delay_max,"k_smi<%=i%>_rx_port_delay_max");
	plusarg_rand(k_smi<%=i%>_rx_port_burst_pct,"k_smi<%=i%>_rx_port_burst_pct");
	plusarg_rand_bit(k_smi<%=i%>_rx_port_slow_port,"k_smi<%=i%>_rx_port_slow_port");
	plusarg_rand(smi<%=i%>_rx_port_prob_slow_port,"smi<%=i%>_rx_port_prob_slow_port");

	plusarg_rand_bit(smi<%=i%>_rx_port_delay_export,"smi<%=i%>_rx_port_delay_export");
	plusarg_rand_bit(smi<%=i%>_rx_port_change_delays_over_time,"smi<%=i%>_rx_port_change_delays_over_time");

  <% } %>

/*  
    //AXI knobs
	plusarg_rand(k_ace_slave_read_addr_chnl_delay_min,"k_ace_slave_read_addr_chnl_delay_min");
	plusarg_rand(k_ace_slave_read_addr_chnl_delay_max,"k_ace_slave_read_addr_chnl_delay_max");
	plusarg_rand(k_ace_slave_read_addr_chnl_burst_pct,"k_ace_slave_read_addr_chnl_burst_pct");
	plusarg_rand(k_ace_slave_read_data_chnl_delay_min,"k_ace_slave_read_data_chnl_delay_min");
	plusarg_rand(k_ace_slave_read_data_chnl_delay_max,"k_ace_slave_read_data_chnl_delay_max");
	plusarg_rand(k_ace_slave_read_data_chnl_burst_pct,"k_ace_slave_read_data_chnl_burst_pct");
	plusarg_rand(k_ace_slave_read_data_reorder_size,"k_ace_slave_read_data_reorder_size");
	plusarg_rand(k_ace_slave_write_addr_chnl_delay_min,"k_ace_slave_write_addr_chnl_delay_min");
	plusarg_rand(k_ace_slave_write_addr_chnl_delay_max,"k_ace_slave_write_addr_chnl_delay_max");
	plusarg_rand(k_ace_slave_write_addr_chnl_burst_pct,"k_ace_slave_write_addr_chnl_burst_pct");
	plusarg_rand(k_ace_slave_write_data_chnl_delay_min,"k_ace_slave_write_data_chnl_delay_min");
	plusarg_rand(k_ace_slave_write_data_chnl_delay_max,"k_ace_slave_write_data_chnl_delay_max");
	plusarg_rand(k_ace_slave_write_data_chnl_burst_pct,"k_ace_slave_write_data_chnl_burst_pct");
	plusarg_rand(k_ace_slave_write_resp_chnl_delay_min,"k_ace_slave_write_resp_chnl_delay_min");
	plusarg_rand(k_ace_slave_write_resp_chnl_delay_max,"k_ace_slave_write_resp_chnl_delay_max");
	plusarg_rand(k_ace_slave_write_resp_chnl_burst_pct,"k_ace_slave_write_resp_chnl_burst_pct");
*/
    plusarg_rand_bit(k_slow_agent,"k_slow_agent");
    plusarg_rand_bit(k_slow_read_agent,"k_slow_read_agent");
    plusarg_rand_bit(k_slow_write_agent,"k_slow_write_agent");

  
    //APB knob
<% if(obj.INHOUSE_APB_VIP) { %>
	plusarg_rand(k_apb_mcmd_delay_min,"k_apb_mcmd_delay_min");
	plusarg_rand(k_apb_mcmd_delay_max,"k_apb_mcmd_delay_max");
	plusarg_rand(k_apb_mcmd_burst_pct,"k_apb_mcmd_burst_pct");
	plusarg_rand_bit(k_apb_mcmd_wait_for_scmdaccept,"k_apb_mcmd_wait_for_scmdaccept");

	plusarg_rand(k_apb_maccept_delay_min,"k_apb_maccept_delay_min");
	plusarg_rand(k_apb_maccept_delay_max,"k_apb_maccept_delay_max");
	plusarg_rand(k_apb_maccept_burst_pct,"k_apb_maccept_burst_pct");
	plusarg_rand_bit(k_apb_maccept_wait_for_sresp,"k_apb_maccept_wait_for_sresp");

	flag = plusarg_rand_bit(k_slow_apb_agent,"k_slow_apb_agent");
	flag |= plusarg_rand_bit(k_slow_apb_mcmd_agent,"k_slow_apb_mcmd_agent");
	flag |= plusarg_rand_bit(k_slow_apb_mrespaccept_agent,"k_slow_apb_mrespaccept_agent");
    if ((!flag) && k_randomize) begin                           
           randcase                                
             70: ;                                 
             10: k_slow_apb_agent = 1;             
             10: k_slow_apb_mcmd_agent = 1;        
             10: k_slow_apb_mrespaccept_agent = 1; 
           endcase // randcase                     
    end                                        

<% } %>



//////////////////////////////////////////////////////////////////////////////
//
// Directed tests. Set knobs based on testname
//
//////////////////////////////////////////////////////////////////////////////

   clp.get_arg_value("+UVM_TESTNAME=", arg_value);
   if (arg_value == "dii_bresp_backpressure_test") begin
      k_slow_agent       = 0;
      k_slow_read_agent  = 0;
      k_slow_write_agent = 0;
/*
      k_ace_slave_read_addr_chnl_delay_min  = 0;
      k_ace_slave_read_addr_chnl_delay_max  = 0;
      k_ace_slave_read_addr_chnl_burst_pct  = 100;
      k_ace_slave_read_data_chnl_delay_min  = 0;
      k_ace_slave_read_data_chnl_delay_max  = 0;
      k_ace_slave_read_data_chnl_burst_pct  = 100;
      k_ace_slave_write_addr_chnl_delay_min = 0;
      k_ace_slave_write_addr_chnl_delay_max = 0;
      k_ace_slave_write_addr_chnl_burst_pct = 100;
      k_ace_slave_write_data_chnl_delay_min = 0;
      k_ace_slave_write_data_chnl_delay_max = 0;
      k_ace_slave_write_data_chnl_burst_pct = 100;
      k_ace_slave_write_resp_chnl_delay_min = 50;
      k_ace_slave_write_resp_chnl_delay_max = 100;
      k_ace_slave_write_resp_chnl_burst_pct = 10;
*/
      flag = 1;
   end


   if ((arg_value == "dii_arready_backpressure_test1") ||
       (arg_value == "dii_arready_backpressure_test2")) begin
      k_slow_agent       = 0;
      k_slow_read_agent  = 0;
      k_slow_write_agent = 0;
/*
      k_ace_slave_read_addr_chnl_delay_min  = 50;
      k_ace_slave_read_addr_chnl_delay_max  = 100;
      k_ace_slave_read_addr_chnl_burst_pct  = 10;
      k_ace_slave_read_data_chnl_delay_min  = 0;
      k_ace_slave_read_data_chnl_delay_max  = 0;
      k_ace_slave_read_data_chnl_burst_pct  = 100;
      k_ace_slave_write_addr_chnl_delay_min = 0;
      k_ace_slave_write_addr_chnl_delay_max = 0;
      k_ace_slave_write_addr_chnl_burst_pct = 100;
      k_ace_slave_write_data_chnl_delay_min = 0;
      k_ace_slave_write_data_chnl_delay_max = 0;
      k_ace_slave_write_data_chnl_burst_pct = 100;
      k_ace_slave_write_resp_chnl_delay_min = 0;
      k_ace_slave_write_resp_chnl_delay_max = 0;
      k_ace_slave_write_resp_chnl_burst_pct = 100;
*/
      flag = 1;
   end


    if($test$plusargs("performance_test"))begin
      //TODO FIXME str, dtr return as soon as possible.  also for dtwrsp?
      // k_slv_str_delay = 0;
      // k_slv_str_delay = 0;
      // k_slv_dtr_delay = 0;
      // k_slv_dtr_delay = 0;
      
      //k_num_addr = 1000;
      //k_num_cmd  = 1000;
    end


    // selected ace scenarios
   if ((!flag) && k_randomize) begin
      randcase
          20: ;
          10: k_slow_agent       = 1;
          10: k_slow_read_agent  = 1;
          10: k_slow_write_agent = 1;
          10: begin
            // k_ace_slave_read_addr_chnl_delay_min = $urandom_range(0,10);
            // k_ace_slave_read_addr_chnl_delay_max = $urandom_range(k_ace_slave_read_addr_chnl_delay_min,200);
            // k_ace_slave_read_addr_chnl_burst_pct = $urandom_range(1,10)*10;
          end
          10: begin
            // k_ace_slave_read_data_chnl_delay_min = $urandom_range(0,10);
            // k_ace_slave_read_data_chnl_delay_max = $urandom_range(k_ace_slave_read_data_chnl_delay_min,200);
            // k_ace_slave_read_data_chnl_burst_pct = $urandom_range(1,10)*10;
          end
          10: begin
            // k_ace_slave_write_addr_chnl_delay_min = $urandom_range(0,10);
            // k_ace_slave_write_addr_chnl_delay_max = $urandom_range(k_ace_slave_write_addr_chnl_delay_min,200);
            // k_ace_slave_write_addr_chnl_burst_pct = $urandom_range(1,10)*10;
          end
          10: begin
            // k_ace_slave_write_data_chnl_delay_min = $urandom_range(0,10);
            // k_ace_slave_write_data_chnl_delay_max = $urandom_range(k_ace_slave_write_data_chnl_delay_min,200);
            // k_ace_slave_write_data_chnl_burst_pct = $urandom_range(1,10)*10;
          end
          10: begin
            // k_ace_slave_write_resp_chnl_delay_min = $urandom_range(0,10);
            // k_ace_slave_write_resp_chnl_delay_max = $urandom_range(k_ace_slave_write_resp_chnl_delay_min,200);
            // k_ace_slave_write_resp_chnl_burst_pct = $urandom_range(1,10)*10;
          end
    endcase
   end // if (!flag)
  
   if(k_slow_agent || k_slow_read_agent || k_slow_write_agent /* ||
      ((k_ace_slave_read_addr_chnl_delay_max + k_ace_slave_read_data_chnl_delay_max) > 50) ||
      ((k_ace_slave_write_addr_chnl_delay_max + k_ace_slave_write_data_chnl_delay_max + k_ace_slave_write_resp_chnl_delay_max) > 50)  */
     ) begin
       k_slow_system                          = 1; 
  end


///////////////////////////////////////////////////////////////////////////////

    //useMemRspIntrlv = <%=obj.DiiInfo[0].cmpInfo.useMemRspIntrlv%>;  //defeature ncore3.0
    /*flag = plusarg_rand(k_ace_slave_read_data_interleave_dis,"k_ace_slave_read_data_interleave_dis");
    if(flag) begin
        `uvm_info("<%=obj.BlockId%>_base_test::plusarg_rand","WARNING: Use k_ace_slave_read_data_interleave_dis on the commandline carefully. No check for using interleaved memory with no RttDataEntries.", UVM_MEDIUM)
    end
    else if(useMemRspIntrlv && k_randomize) begin
        k_ace_slave_read_data_interleave_dis = $urandom_range(0,1);
    end
    */

    flag = plusarg_rand(prob_ace_rd_resp_error,"prob_ace_rd_resp_error");
    if((!flag) && k_randomize) begin
        randcase
            10: prob_ace_rd_resp_error = $urandom_range(0,10);
            90: prob_ace_rd_resp_error = 0;
        endcase //randcase
    end

    flag = plusarg_rand(prob_ace_wr_resp_error,"prob_ace_wr_resp_error");
    if((!flag) && k_randomize) begin
        randcase
            10: prob_ace_wr_resp_error = $urandom_range(0,10);
            90: prob_ace_wr_resp_error = 0;
        endcase //randcase
    end
    
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //configure env
    m_env_cfg.has_scoreboard = dii_scb_en; 
    m_env_cfg.has_tcap_scb = tcap_scb_en;
/*
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_delay_min   = k_ace_slave_read_addr_chnl_delay_min;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_delay_max   = k_ace_slave_read_addr_chnl_delay_max;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_burst_pct   = k_ace_slave_read_addr_chnl_burst_pct;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_delay_min   = k_ace_slave_read_data_chnl_delay_min;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_delay_max   = k_ace_slave_read_data_chnl_delay_max;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_burst_pct   = k_ace_slave_read_data_chnl_burst_pct;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_reorder_size     = k_ace_slave_read_data_reorder_size;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_addr_chnl_delay_min  = k_ace_slave_write_addr_chnl_delay_min;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_addr_chnl_delay_max  = k_ace_slave_write_addr_chnl_delay_max;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_addr_chnl_burst_pct  = k_ace_slave_write_addr_chnl_burst_pct;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_data_chnl_delay_min  = k_ace_slave_write_data_chnl_delay_min;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_data_chnl_delay_max  = k_ace_slave_write_data_chnl_delay_max;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_data_chnl_burst_pct  = k_ace_slave_write_data_chnl_burst_pct;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_resp_chnl_delay_min  = k_ace_slave_write_resp_chnl_delay_min;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_resp_chnl_delay_max  = k_ace_slave_write_resp_chnl_delay_max;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_resp_chnl_burst_pct  = k_ace_slave_write_resp_chnl_burst_pct;
    m_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_interleave_dis   = k_ace_slave_read_data_interleave_dis;
*/
    m_env_cfg.m_axi_slave_agent_cfg.k_slow_agent                           = k_slow_agent;
    m_env_cfg.m_axi_slave_agent_cfg.k_slow_read_agent                      = k_slow_read_agent;
    m_env_cfg.m_axi_slave_agent_cfg.k_slow_write_agent                     = k_slow_write_agent;


    m_env_cfg.m_axi_slave_agent_cfg.prob_ace_rd_resp_error = prob_ace_rd_resp_error;
    m_env_cfg.m_axi_slave_agent_cfg.prob_ace_wr_resp_error = prob_ace_wr_resp_error;


  endfunction: grab_and_parse_args_from_cmdline

endclass: dii_args

endpackage: <%=obj.BlockId%>_dii_args_pkg
