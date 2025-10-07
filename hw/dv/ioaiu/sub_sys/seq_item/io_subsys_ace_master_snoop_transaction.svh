class io_subsys_ace_master_snoop_transaction extends svt_axi_master_snoop_transaction; 

    string arg_value;
    string inject_parity_err_cr_chnl,inject_parity_err_cd_chnl; 
<% if(obj.testBench == "fsys") { %>
static int io_subsys_axi_intf_parity_err_count[ncoreConfigInfo::NUM_IO_MASTERS];
static bit io_subsys_axi_dis_inject_intf_parity_err[ncoreConfigInfo::NUM_IO_MASTERS]='{default:1}; // '{{ 4'h0 }}
<% } %>
    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();

    `svt_xvm_object_utils(io_subsys_ace_master_snoop_transaction)
    
        
    function new(string name = "io_subsys_ace_master_snoop_transaction");
        super.new(name);
    endfunction: new

    function void pre_randomize();
      //#Stimulus.IOAIU.Snoop_parity
      //All snoop parity signals are driven by VIP.
        super.pre_randomize();
<% if(obj.testBench == "fsys") { %>
        if((port_cfg.check_type==svt_axi_port_configuration::ODD_PARITY_BYTE_ALL) && (io_subsys_axi_dis_inject_intf_parity_err[port_cfg.port_id]==0))begin
<% } else { %>
        if(port_cfg.check_type==svt_axi_port_configuration::ODD_PARITY_BYTE_ALL)begin
<% } %>
          `ifdef SVT_AXI_DISABLE_BEAT_LEVEL_PARITY
            if($value$plusargs("inject_parity_err_cr_chnl=%0s",inject_parity_err_cr_chnl) || $value$plusargs("inject_parity_err_cd_chnl=%0s",inject_parity_err_cd_chnl))begin
              auto_parity_gen_enable = 0;
            end
          `endif
        end
        if (clp.get_arg_value("+prob_ace_snp_resp_error=", arg_value)) begin
            LARGE_wt = (100 - arg_value.atoi());
            SMALL_wt = arg_value.atoi();
        end else begin
            SMALL_wt = 0;
        end

        //`uvm_info(get_full_name(), $psprintf("fn:after pre_randomize LARGE_wt=%0p, SMALL_wt=%0p *** io_subsys_ace_master_snoop_transaction *** \n %0s", LARGE_wt, SMALL_wt, sprint()), UVM_LOW);

    endfunction: pre_randomize

    function void post_randomize();
        super.post_randomize();
<% if(obj.testBench == "fsys") { %>
        if(port_cfg.check_type==svt_axi_port_configuration::ODD_PARITY_BYTE_ALL && io_subsys_axi_dis_inject_intf_parity_err[port_cfg.port_id]==0)begin
           inject_intf_parity_err(); 
	end 
<% } else { %>
        if(port_cfg.check_type==svt_axi_port_configuration::ODD_PARITY_BYTE_ALL)begin
           inject_intf_parity_err(); 
	end 
<% } %>
        if (port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE) begin  
            `uvm_info(get_full_name(), $psprintf("fn:after post_randomize *** io_subsys_ace_master_snoop_transaction *** snoop_xact_type:%0p addr:0x%0h ns:%0b initial_cacheline_st:%0p final_cacheline_state:%0p", snoop_xact_type, snoop_addr, snoop_prot[1], snoop_initial_cache_line_state, snoop_final_cache_line_state), UVM_LOW);
        end
        //`uvm_info(get_full_name(), $psprintf("fn:after post_randomize *** io_subsys_ace_master_snoop_transaction *** \n %0s", sprint()), UVM_LOW);
    endfunction: post_randomize

    function void inject_intf_parity_err();
    //#Stimulus.IOAIU.Snoop_parity_Err
      `ifdef SVT_AXI_DISABLE_BEAT_LEVEL_PARITY
         if($value$plusargs("inject_parity_err_cr_chnl=%0s",inject_parity_err_cr_chnl))begin
           if(inject_parity_err_cr_chnl == "ACE5LITE")begin
                randcase
                1 : inject_parity_err_cr_chnl = "CRRESP_CHK";
                1 : inject_parity_err_cr_chnl = "CRTRACE_CHK";
                endcase
           end
           if(inject_parity_err_cr_chnl == "ACE5")begin
                inject_parity_err_cr_chnl = "CRRESP_CHK";
           end

           if(inject_parity_err_cr_chnl== "CRRESP_CHK")begin                        
               user_inject_parity_signal_array[CRRESPCHK_EN] = 1;
               do
                 crresp_chk = $urandom;
               while(($countones(crresp_chk) + $countones(snoop_resp_datatransfer) + $countones(snoop_resp_error) + $countones(snoop_resp_passdirty) + $countones(snoop_resp_isshared) + $countones(snoop_resp_wasunique)) %2 ==1);
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
           end
           if(inject_parity_err_cr_chnl== "CRTRACE_CHK")begin
             user_inject_parity_signal_array[CRTRACECHK_EN] = 1;
             do
               crtrace_chk = $urandom(); 
             while(($countones(crtrace_chk)+$countones(snoop_resp_trace_tag)) % 2 == 1);
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
           end  
           `uvm_info(get_full_name(), $psprintf("inject_intf_parity_err.inject_parity_err_cr_chnl %0s",inject_parity_err_cr_chnl), UVM_LOW);
         end
         if($value$plusargs("inject_parity_err_cd_chnl=%0s",inject_parity_err_cd_chnl))begin
           if(inject_parity_err_cd_chnl == "ACE5")begin
                randcase
                1 : inject_parity_err_cd_chnl = "CDDATA_CHK";
                1 : inject_parity_err_cd_chnl = "CDLAST_CHK";
                endcase
           end

            if(inject_parity_err_cd_chnl== "CDDATA_CHK")begin
             user_inject_parity_signal_array[CDDATACHK_EN] = 1;
             foreach(snoop_data[i])begin
               for(int j=0; (`SVT_AXI_ACE_SNOOP_DATA_WIDTH/8)<j; j++)begin
                 do
                   cddata_chk[i][j] = $urandom; 
                 while(($countones(cddata_chk[i][j]) + $countones(snoop_data[i][(j*8) +: 8])) %2 ==1);
               end
             end
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
           end
           `uvm_info(get_full_name(), $psprintf("inject_intf_parity_err.inject_parity_err_cd_chnl %0s",inject_parity_err_cd_chnl), UVM_LOW);
           if(inject_parity_err_cd_chnl== "CDLAST_CHK")begin
             user_inject_parity_signal_array[CDLASTCHK_EN] = 1;
             //do
               foreach(cdlast_chk[i])
               cdlast_chk[i] = 1; 
            // while(($countones(cdlast_chk) + $countones()) %2 ==1);
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
           end 
         end
      `endif
    endfunction

endclass: io_subsys_ace_master_snoop_transaction
