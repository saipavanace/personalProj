//////////////////////////////
<% if (1 == 0) { %>
//                                                        //
//Description: Class reads all Concerto unit plusargs     //
//             and base test passes them down the TB      //
//             hierarchy                                  //
//                                                        //
//File:        concerto_unit_args.svh                     //
//Author:      satya prakash                     //
<% } %>
//                                                        //
//////////////////////////////


//Embedded javascript code to figure number of blocks
//Collects list of block id's and slave id's in two arrays
<%
    var aiuBlkid       = [];  // AXI4 & ACE & ACE_light only
    var aiuNativeInf   = [];
    var dvmMsgEnabled  = [];
    var agentMinTrans  = [];  //Lower limit for each Agent (AgentAIU's, BridgeAIU's)
    var agentMaxTrans  = [];  //Higher limit for each Agent (AgentAIU's, BridgeAIU's)

    //Not needed because dvmCmp messages are not driven by BFM
    var dvmCmpEnabled = [];  

    var dceBlkid  = [];
    var dmiBlkid  = [];
    var diiBlkid  = [];
    var dveBlkid  = [];
    var initiatorAgents = obj.AiuInfo.length ;

    //Embedded javascript code to figure out
    // number of blocks
     var _child_m = [];

    obj.AiuInfo.forEach(function(bundle, indx, array) {
        aiuBlkid.push('aiu' + indx);

        aiuNativeInf.push(bundle.fnNativeInterface);

        if(bundle.fnNativeInterface === "ACE"||bundle.fnNativeInterface === "ACE5") { 
            agentMinTrans.push(800);
            agentMaxTrans.push(1000);

            if(bundle.nAius > 1) {
                dvmMsgEnabled.push(0);
                dvmCmpEnabled.push(0);  
            } else { 

                if(bundle.cmpInfo.nDvmSnpInFlight > 0) {
                    dvmMsgEnabled.push(1);
                } else {
                    dvmMsgEnabled.push(0);
                }

                if(bundle.cmpInfo.nDvmSnpInFlight) {
                    dvmCmpEnabled.push(1);
                } else {
                    dvmCmpEnabled.push(0);
                } 
            }
        } else {
            dvmMsgEnabled.push(0);
            if(bundle.cmpInfo.nDvmSnpInFlight) {
                dvmCmpEnabled.push(1);
            } else {
                dvmCmpEnabled.push(0);
            }
            agentMinTrans.push(200);
            agentMaxTrans.push(400);
        }
    });


    for(var idx = 0; idx < obj.DceInfo.nDces; idx++) {
        dceBlkid.push('dce' + idx);
    }

    obj.DmiInfo.forEach(function(bundle, indx, array) {
        dmiBlkid.push('dmi' + indx);
    });

    obj.DiiInfo.forEach(function(bundle, indx, array) {
        diiBlkid.push('dii' + indx);
    });

    obj.DveInfo.forEach(function(bundle, indx, array) {
        dveBlkid.push('dve' + indx);
    });
%>

//
// Plusargs that are common for all components are 
// defines in base class
//

class concerto_args extends uvm_object;

    uvm_cmdline_processor clp;
    
    `uvm_object_param_utils(concerto_args)
  
    bit en_cpp_checker;
    bit chiaiu_scb_en       = 0;
    bit ioaiu_scb_en        = 0;
    bit dce_scb_en          = 0;
    bit dmi_scb_en          = 0;
    bit dii_scb_en          = 0;
    bit dve_scb_en          = 0;
    bit dirm_scb_en         = 0;
    bit dirm_dbg_en         = 0;
    bit dce_dm_dbg_en       = 0;
    bit force_reset_values  = 0;
    bit en_perf_analysis    = 0;
    int k_num_addr          = 100;
    int k_num_exclusive_req = 100;
    bit hit_cbi_cache       = 0;
    bit hit_dce_cache       = 0;
    bit hit_dmi_cache       = 0;
    bit mult_txn_by_ten     = 0;

   int k_apb_mcmd_delay_min                      = 0;
   int k_apb_mcmd_delay_max                      = 1;
   int k_apb_mcmd_burst_pct                      = 90;
   bit k_apb_mcmd_wait_for_scmdaccept            = 0;

   int k_apb_maccept_delay_min                   = 0;
   int k_apb_maccept_delay_max                   = 1;
   int k_apb_maccept_burst_pct                   = 90;
   bit k_apb_maccept_wait_for_sresp              = 0;


   bit inject_random_csr_seq                 = 0;
   bit inject_ttdebug                        = 0;
   bit no_quiesce                            = 0;
   bit back_to_back_csr                      = 0;

   //Error injection 
   //Directed test error plusargs
   bit k_inj_ott_error                      = 0;
   bit k_inj_cbi_tag_error                  = 0;
   bit k_inj_cbi_data_error                 = 0;
   bit k_inj_cbi_fill_error                 = 0;
   bit k_inj_dmi_rtt_error                  = 0;
   bit k_inj_dmi_tag_error                  = 0;
   bit k_inj_dmi_data_error                 = 0;
   bit k_inj_dir_transport_err              = 0;
   bit k_inj_cmdrsp_sec_err                 = 0;
   bit k_inj_cmdrsp_tmo_err                 = 0;
   bit k_inj_cmdrsp_pow_err                 = 0; 
   bit k_inj_snprsp_pow_err                = 0;
   bit k_inj_snprsp_tmo_err                 = 0;
   bit k_inj_dtrrsp_pow_err                = 0;
   bit k_inj_dtrrsp_tmo_err                 = 0;
   bit k_inj_dtwrsp_pow_err                = 0;
   bit k_inj_dtwrsp_tmo_err                 = 0;
   bit k_inj_hntrsp_pow_err                = 0;
   bit k_inj_hntrsp_tmo_err                 = 0;
   bit k_inj_mrdrsp_pow_err                = 0;
   bit k_inj_mrdrsp_tmo_err                 = 0;
   bit k_inj_strrsp_pow_err                = 0; 
   bit k_inj_strrsp_tmo_err                 = 0;
   bit k_inj_updrsp_sec_err                 = 0; 
   bit k_inj_updrsp_pow_err                = 0;
   bit k_inj_updrsp_tmo_err                 = 0;

    //Delay in microseconds
<%  if(obj.SFI_DELAY_DISABLE) { %>
    longint k_timeout       = 250000;
<% } else { %>
    longint k_timeout       = 250000;
<% } %>
    longint k_sim_timeout   = 32000;

    // block specifc control knobs
<% for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
    int <%=aiuBlkid[pidx]%>_prob_unq_cln_to_unq_dirty              = ($test$plusargs("fsys_directed_test")) ? 0 : 50;
    int <%=aiuBlkid[pidx]%>_prob_unq_cln_to_invalid                = ($test$plusargs("fsys_directed_test")) ? 0 : 10;
    int <%=aiuBlkid[pidx]%>_total_outstanding_coh_writes           = 10;
    int <%=aiuBlkid[pidx]%>_total_min_ace_cache_size               = 50;
    int <%=aiuBlkid[pidx]%>_total_max_ace_cache_size               = 150;
    int <%=aiuBlkid[pidx]%>_size_of_wr_queue_before_flush          = 10;
    int <%=aiuBlkid[pidx]%>_wt_expected_end_state                  = 60;
    int <%=aiuBlkid[pidx]%>_wt_legal_end_state_with_sf             = 25;
    int <%=aiuBlkid[pidx]%>_wt_legal_end_state_without_sf          = 5;
    int <%=aiuBlkid[pidx]%>_wt_expected_start_state                = 60;
    int <%=aiuBlkid[pidx]%>_wt_legal_start_state                   = 40;
    int <%=aiuBlkid[pidx]%>_wt_lose_cache_line_on_snps             = 25;
    int <%=aiuBlkid[pidx]%>_wt_keep_drty_cache_line_on_snps        = 50;
    int <%=aiuBlkid[pidx]%>_prob_respond_to_snoop_coll_with_wr     = 50;
    int <%=aiuBlkid[pidx]%>_prob_was_unique_snp_resp               = ($test$plusargs("fsys_directed_test")) ? 100 :50;
    int <%=aiuBlkid[pidx]%>_prob_was_unique_always0_snp_resp       = ($test$plusargs("fsys_directed_test")) ? 0 :25;
    int <%=aiuBlkid[pidx]%>_prob_dataxfer_snp_resp_on_clean_hit    = ($test$plusargs("fsys_directed_test")) ? 100 :50;
    int <%=aiuBlkid[pidx]%>_prob_ace_wr_ix_start_state             = 50;
    int <%=aiuBlkid[pidx]%>_prob_ace_rd_ix_start_state             = 50;
    int <%=aiuBlkid[pidx]%>_prob_cache_flush_mode_per_1k           = 100;
    int <%=aiuBlkid[pidx]%>_prob_ace_snp_resp_error                = 0;
    int <%=aiuBlkid[pidx]%>_prob_ace_coh_win_error                 = 0;
    int <%=aiuBlkid[pidx]%>_k_num_read_req                         = 1200;
    int <%=aiuBlkid[pidx]%>_k_num_write_req                        = 100;
    int <%=aiuBlkid[pidx]%>_k_reorder_rsp_max                      = 0;
    int <%=aiuBlkid[pidx]%>_k_reorder_rsp_tmr                      = 0;
    int <%=aiuBlkid[pidx]%>_k_req_vld_delay_min                    = 0;
    int <%=aiuBlkid[pidx]%>_k_req_vld_delay_max                    = 1;
    int <%=aiuBlkid[pidx]%>_k_req_vld_burst_pct                    = 80;
    int <%=aiuBlkid[pidx]%>_k_req_rdy_delay_min                    = 0;
    int <%=aiuBlkid[pidx]%>_k_req_rdy_delay_max                    = 1;
    int <%=aiuBlkid[pidx]%>_k_req_rdy_burst_pct                    = 80;
    int <%=aiuBlkid[pidx]%>_k_rsp_vld_delay_min                    = 0;
    int <%=aiuBlkid[pidx]%>_k_rsp_vld_delay_max                    = 2;
    int <%=aiuBlkid[pidx]%>_k_rsp_vld_burst_pct                    = 80;
    int <%=aiuBlkid[pidx]%>_k_rsp_rdy_delay_min                    = 0;
    int <%=aiuBlkid[pidx]%>_k_rsp_rdy_delay_max                    = 2;
    int <%=aiuBlkid[pidx]%>_k_rsp_rdy_burst_pct                    = 80;
    int <%=aiuBlkid[pidx]%>_wt_ace_rdnosnp                         = 0;
    int <%=aiuBlkid[pidx]%>_wt_ace_rdonce                          = 10;
<% if((aiuNativeInf[pidx].match('CHI'))) { %>
    int <%=aiuBlkid[pidx]%>_wt_chi_data_flit_data_err              = 0;
    int <%=aiuBlkid[pidx]%>_wt_chi_data_flit_non_data_err          = 0;
    int <%=aiuBlkid[pidx]%>_k_snp_rsp_data_err_wgt                 = 0;
    int <%=aiuBlkid[pidx]%>_k_snp_rsp_non_data_err_wgt             = 0;
<% } %>
<% if(aiuNativeInf[pidx] === "ACE-LITE") { %>
    int <%=aiuBlkid[pidx]%>_wt_ace_rdshrd                          = 0;
    int <%=aiuBlkid[pidx]%>_wt_ace_rdcln                           = 0;
    int <%=aiuBlkid[pidx]%>_wt_ace_rdnotshrddty                    = 0;
    int <%=aiuBlkid[pidx]%>_wt_ace_rdunq                           = 0;
    int <%=aiuBlkid[pidx]%>_wt_ace_clnunq                          = 0;
    int <%=aiuBlkid[pidx]%>_wt_ace_mkunq                           = 0;
    int <%=aiuBlkid[pidx]%>_wt_ace_dvm_msg                         = 0;
<% } else { %>
    int <%=aiuBlkid[pidx]%>_wt_ace_rdshrd                          = 10;
    int <%=aiuBlkid[pidx]%>_wt_ace_rdcln                           = 10;
    int <%=aiuBlkid[pidx]%>_wt_ace_rdnotshrddty                    = 10;
    int <%=aiuBlkid[pidx]%>_wt_ace_rdunq                           = 10;
    int <%=aiuBlkid[pidx]%>_wt_ace_clnunq                          = 10;
    int <%=aiuBlkid[pidx]%>_wt_ace_mkunq                           = 10;
    int <%=aiuBlkid[pidx]%>_wt_ace_dvm_msg                         = 0;
<% } %>
   
    //True for Non Bridge agents 
<% } %>
   

<% for(var pidx = 0; pidx < dmiBlkid.length; pidx++) { %>
    int <%=dmiBlkid[pidx]%>_prob_ace_slave_rd_resp_error           = 0;
    int <%=dmiBlkid[pidx]%>_prob_ace_slave_wr_resp_error           = 0;
<% } %>

<% for(var pidx = 0; pidx < diiBlkid.length; pidx++) { %>
    int <%=diiBlkid[pidx]%>_prob_ace_slave_rd_resp_error           = 0;
    int <%=diiBlkid[pidx]%>_prob_ace_slave_wr_resp_error           = 0;
<% } %>

   bit flag              = 0;
   bit power_test        = 0;
   bit iocache_perf_test = 0;

    function new(string name = "concerto_args");
        super.new(name);

        clp = uvm_cmdline_processor::get_inst();
        read_args();
    endfunction: new

    function void read_args();
       string arg_value, arg_value1, arg_value2; 
       int    len;
       string myargs[$];

       if (clp.get_arg_value("+mult_txn_by_ten=", arg_value)) begin
           mult_txn_by_ten = 1;
       end
       else begin
           mult_txn_by_ten = 0;
       end
       clp.get_arg_value("+UVM_TESTNAME=", arg_value);
       if (arg_value == "concerto_inhouse_iocache_perf_test") begin
           iocache_perf_test = 1;
       end
       else begin
           iocache_perf_test = 0;
       end
       if(clp.get_arg_value("+chiaiu_scb_en=", arg_value)) begin
          chiaiu_scb_en = arg_value.atoi();
       end
       if(clp.get_arg_value("+ioaiu_scb_en=", arg_value)) begin
          ioaiu_scb_en = arg_value.atoi();
       end
       if(clp.get_arg_value("+dce_scb_en=", arg_value)) begin
          dce_scb_en = arg_value.atoi();
       end
       if(clp.get_arg_value("+dmi_scb_en=", arg_value)) begin
          dmi_scb_en = arg_value.atoi();
       end
       if(clp.get_arg_value("+dii_scb_en=", arg_value)) begin
          dii_scb_en = arg_value.atoi();
       end
       if(clp.get_arg_value("+dve_scb_en=", arg_value)) begin
          dve_scb_en = arg_value.atoi();
       end
       if(clp.get_arg_value("+dirm_scb_en=", arg_value)) begin
          dirm_scb_en = arg_value.atoi();
       end
	   if (clp.get_arg_value("+dce_dm_dbg_en=", arg_value)) begin
	   	  dce_dm_dbg_en = arg_value.atoi();
	   end

       if(clp.get_arg_value("+dirm_dbg_en", arg_value)) begin
          dirm_dbg_en = 1'b1;
       end
       if(clp.get_arg_value("+en_cpp_checker", arg_value)) begin
           en_cpp_checker = 1'b1;
       end

       //Address MGR knobs
       if(clp.get_arg_value("+hit_cbi_cache=", arg_value)  ||
          clp.get_arg_value("+hit_dce_cache=", arg_value1) ||
          clp.get_arg_value("+hit_dmi_cache=", arg_value2)) begin

           hit_cbi_cache = arg_value.atoi();
           hit_dce_cache = arg_value1.atoi();
           hit_dmi_cache = arg_value2.atoi();
       end else begin
           if($urandom_range(0, 1) > 0) begin
               hit_cbi_cache = $urandom_range(0, 1);
               hit_dce_cache = 0; //$urandom_range(0, 1);
               hit_dmi_cache = $urandom_range(0, 1);
           end
       end

       if(clp.get_arg_value("+force_reset_values=", arg_value)) begin
          force_reset_values = arg_value.atoi();
       end
       if (clp.get_arg_value("+k_num_addr=", arg_value)) begin
         k_num_addr = arg_value.atoi();
       end
      if (clp.get_arg_value("+k_timeout=", arg_value)) begin
         k_timeout = arg_value.atoi();
       end
      if (clp.get_arg_value("+k_sim_timeout=", arg_value)) begin
         k_sim_timeout = arg_value.atoi();
       end
      //Enable TB to log performance related metrics
      //Default to do not inject SFI delays
      if(clp.get_arg_value("+en_perf_analysis", arg_value)) begin
          en_perf_analysis = 1'b1;
      end

  if (clp.get_arg_value("+k_apb_mcmd_delay_min=", arg_value)) begin
    k_apb_mcmd_delay_min = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_mcmd_delay_max=", arg_value)) begin
    k_apb_mcmd_delay_max = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_mcmd_burst_pct=", arg_value)) begin
    k_apb_mcmd_burst_pct = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_mcmd_wait_for_scmdaccept=", arg_value)) begin
    k_apb_mcmd_wait_for_scmdaccept = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_maccept_delay_min=", arg_value)) begin
    k_apb_maccept_delay_min = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_maccept_delay_max=", arg_value)) begin
    k_apb_maccept_delay_max = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_maccept_burst_pct=", arg_value)) begin
    k_apb_maccept_burst_pct = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_maccept_wait_for_sresp=", arg_value)) begin
    k_apb_maccept_wait_for_sresp = arg_value.atoi();
  end

   if (iocache_perf_test) begin
       inject_random_csr_seq = 0;
   end

   //Error injection knobs
   myargs = '{};
   if(clp.get_arg_matches("+inj_ott_error", myargs)) begin
       k_inj_ott_error = 1'b1;
   end
   myargs = '{};
   if(clp.get_arg_matches("+inj_cbi_tag_error", myargs)) begin
       k_inj_cbi_tag_error = 1'b1;
   end
   myargs = '{};
   if(clp.get_arg_matches("+inj_cbi_data_error", myargs)) begin
       k_inj_cbi_data_error = 1'b1;
   end
   myargs = '{};
   if(clp.get_arg_matches("+inj_cbi_fill_error", myargs)) begin
       k_inj_cbi_fill_error = 1'b1;
   end

   myargs = '{};
   if(clp.get_arg_matches("+inj_dmi_rtt_error", myargs)) begin
       k_inj_dmi_rtt_error = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_dmi_tag_error", myargs)) begin
       k_inj_dmi_tag_error = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_dmi_data_error", myargs)) begin
       k_inj_dmi_data_error = 1'b1;
   end

   myargs = '{};
   if(clp.get_arg_matches("+inj_dir_transport_error", myargs)) begin
       k_inj_dir_transport_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_cmdrsp_sec_error", myargs)) begin
       k_inj_cmdrsp_sec_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_cmdrsp_tmo_error", myargs)) begin
       k_inj_cmdrsp_tmo_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_cmdrsp_pow_error", myargs)) begin
       k_inj_cmdrsp_pow_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_snprsp_tmo_error", myargs)) begin
       k_inj_snprsp_tmo_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_snprsp_pow_error", myargs)) begin
       k_inj_snprsp_pow_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_dtrrsp_tmo_error", myargs)) begin
       k_inj_dtrrsp_tmo_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_dtrrsp_pow_error", myargs)) begin
       k_inj_dtrrsp_pow_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_dtwrsp_tmo_error", myargs)) begin
       k_inj_dtwrsp_tmo_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_dtwrsp_pow_error", myargs)) begin
       k_inj_dtwrsp_pow_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_hntrsp_tmo_error", myargs)) begin
       k_inj_hntrsp_tmo_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_hntrsp_pow_error", myargs)) begin
       k_inj_hntrsp_tmo_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_mrdrsp_tmo_error", myargs)) begin
       k_inj_mrdrsp_tmo_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_mrdrsp_pow_error", myargs)) begin
       k_inj_mrdrsp_pow_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_strrsp_tmo_error", myargs)) begin
       k_inj_strrsp_tmo_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_strrsp_pow_error", myargs)) begin
       k_inj_strrsp_pow_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_updrsp_sec_error", myargs)) begin
       k_inj_updrsp_sec_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_updrsp_tmo_error", myargs)) begin
       k_inj_updrsp_tmo_err = 1'b1;
   end
 
   myargs = '{};
   if(clp.get_arg_matches("+inj_updrsp_pow_error", myargs)) begin
       k_inj_updrsp_pow_err = 1'b1;
   end
<% for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
       if (clp.get_arg_value("+<%=aiuBlkid[pidx]%>_k_num_read_req=", arg_value)) begin
         <%=aiuBlkid[pidx]%>_k_num_read_req = arg_value.atoi();
       end        
       else begin
           <%=aiuBlkid[pidx]%>_k_num_read_req = $urandom_range(<%=agentMinTrans[pidx]%>, <%=agentMaxTrans[pidx]%>);
           // Increasing the number of read transadtions so that power tests dont fail with false timeouts
           if (power_test) begin
               <%=aiuBlkid[pidx]%>_k_num_read_req = 5000;
           end
       end

       if (clp.get_arg_value("+<%=aiuBlkid[pidx]%>_k_num_write_req=", arg_value)) begin
         <%=aiuBlkid[pidx]%>_k_num_write_req = arg_value.atoi();
       end
       else begin 
<% if(aiuNativeInf[pidx] === "ACE") { %>
				      <%=aiuBlkid[pidx]%>_k_num_write_req = $urandom_range(1, int'(<%=aiuBlkid[pidx]%>_k_num_read_req * 0.05));
<% } else { %>
           <%=aiuBlkid[pidx]%>_k_num_write_req = $urandom_range(int'(<%=aiuBlkid[pidx]%>_k_num_read_req * 0.1),
                                                                int'(<%=aiuBlkid[pidx]%>_k_num_read_req * 0.2));
<% } %>
       end
       if (mult_txn_by_ten && !power_test) begin
           randcase
               10 : <%=aiuBlkid[pidx]%>_k_num_read_req *= 10;
               10 : <%=aiuBlkid[pidx]%>_k_num_write_req *= 10;
               10 : begin
                   <%=aiuBlkid[pidx]%>_k_num_read_req  *= 10;
                   <%=aiuBlkid[pidx]%>_k_num_write_req *= 10;
               end
           endcase
       end
 
       if (clp.get_arg_value("+wt_expected_start_state=", arg_value)) begin
          <%=aiuBlkid[pidx]%>_wt_expected_start_state           = arg_value.atoi();
       end
       if (clp.get_arg_value("+wt_legal_start_state=", arg_value)) begin
          <%=aiuBlkid[pidx]%>_wt_legal_start_state              = arg_value.atoi();
       end
       if (clp.get_arg_value("+wt_expected_end_state=", arg_value)) begin
          <%=aiuBlkid[pidx]%>_wt_expected_end_state             = arg_value.atoi();
       end
       if (clp.get_arg_value("+wt_legal_end_state_with_sf=", arg_value)) begin
          <%=aiuBlkid[pidx]%>_wt_legal_end_state_with_sf        = arg_value.atoi();
       end
       if (clp.get_arg_value("+wt_legal_end_state_without_sf=", arg_value)) begin
          <%=aiuBlkid[pidx]%>_wt_legal_end_state_without_sf     = arg_value.atoi();
       end
       if (clp.get_arg_value("+wt_lose_cache_line_on_snps=", arg_value)) begin
          <%=aiuBlkid[pidx]%>_wt_lose_cache_line_on_snps        = arg_value.atoi();
       end
       if (clp.get_arg_value("+wt_keep_drty_cache_line_on_snps=", arg_value)) begin
          <%=aiuBlkid[pidx]%>_wt_keep_drty_cache_line_on_snps   = arg_value.atoi();
       end
<% } %>

<% 
var chiaiu_idx = 0;
var ioaiu_idx = 0;
%>
<% for(var pidx = 0; pidx < aiuBlkid.length; pidx++) { %>
    if (clp.get_arg_value("+error_test=", arg_value)) begin
        <% if(!((obj.AiuInfo[pidx].fnNativeInterface.match("CHI")))) { %>
        if (clp.get_arg_value("+prob_ace_snp_resp_error=", arg_value)) begin
            <%=aiuBlkid[pidx]%>_prob_ace_snp_resp_error = arg_value.atoi();
        end else if (clp.get_arg_value("+<%=aiuBlkid[pidx]%>_prob_ace_snp_resp_error=", arg_value)) begin
            <%=aiuBlkid[pidx]%>_prob_ace_snp_resp_error = arg_value.atoi();
        end
        else begin
            <%=aiuBlkid[pidx]%>_prob_ace_snp_resp_error = $urandom_range(5,10);
        end
        <% ioaiu_idx++; %>
        <% } else { %>
        if (clp.get_arg_value("+chi_data_flit_data_err=", arg_value)) begin
            <%=aiuBlkid[pidx]%>_wt_chi_data_flit_data_err = arg_value.atoi();
        end else if (clp.get_arg_value("+<%=aiuBlkid[pidx]%>_chi_data_flit_data_err=", arg_value)) begin
            <%=aiuBlkid[pidx]%>_wt_chi_data_flit_data_err = arg_value.atoi();
        end
        else begin
            <%=aiuBlkid[pidx]%>_wt_chi_data_flit_data_err = $urandom_range(5,10);
        end
        if (clp.get_arg_value("+chi_data_flit_non_data_err=", arg_value)) begin
            <%=aiuBlkid[pidx]%>_wt_chi_data_flit_non_data_err = arg_value.atoi();
        end else if (clp.get_arg_value("+<%=aiuBlkid[pidx]%>_chi_data_flit_non_data_err=", arg_value)) begin
            <%=aiuBlkid[pidx]%>_wt_chi_data_flit_non_data_err = arg_value.atoi();
        end
        else begin
            <%=aiuBlkid[pidx]%>_wt_chi_data_flit_non_data_err = $urandom_range(5,10);
        end
        if (clp.get_arg_value("+SNPrsp_with_data_error=", arg_value)) begin
            <%=aiuBlkid[pidx]%>_k_snp_rsp_data_err_wgt = arg_value.atoi();
        end else if (clp.get_arg_value("+<%=aiuBlkid[pidx]%>_SNPrsp_with_data_error=", arg_value)) begin
            <%=aiuBlkid[pidx]%>_k_snp_rsp_data_err_wgt = arg_value.atoi(); 
        end
        else begin
            <%=aiuBlkid[pidx]%>_k_snp_rsp_data_err_wgt = $urandom_range(5,10);
        end
        if (clp.get_arg_value("+SNPrsp_with_non_data_error=", arg_value)) begin
            <%=aiuBlkid[pidx]%>_k_snp_rsp_non_data_err_wgt = arg_value.atoi();
        end else if (clp.get_arg_value("+<%=aiuBlkid[pidx]%>_SNPrsp_with_non_data_error=", arg_value)) begin
            <%=aiuBlkid[pidx]%>_k_snp_rsp_non_data_err_wgt = arg_value.atoi();
        end
        else begin
            <%=aiuBlkid[pidx]%>_k_snp_rsp_non_data_err_wgt = $urandom_range(5,10);
        end
        <% chiaiu_idx++;%>
        <% } %>
    end
<% } %>

<% for(var pidx = 0; pidx < dmiBlkid.length; pidx++) { %>
       if (clp.get_arg_value("+error_test=", arg_value)) begin
           if (clp.get_arg_value("+prob_ace_slave_rd_resp_error=", arg_value)) begin
            <%=dmiBlkid[pidx]%>_prob_ace_slave_rd_resp_error = arg_value.atoi();
           end else if (clp.get_arg_value("+<%=dmiBlkid[pidx]%>_prob_ace_slave_rd_resp_error=", arg_value)) begin
               <%=dmiBlkid[pidx]%>_prob_ace_slave_rd_resp_error = arg_value.atoi();
           end
           else begin
               <%=dmiBlkid[pidx]%>_prob_ace_slave_rd_resp_error = $urandom_range(5,10);
           end
           if (clp.get_arg_value("+prob_ace_slave_wr_resp_error=", arg_value)) begin
            <%=dmiBlkid[pidx]%>_prob_ace_slave_wr_resp_error = arg_value.atoi();
           end else if (clp.get_arg_value("+<%=dmiBlkid[pidx]%>_prob_ace_slave_wr_resp_error=", arg_value)) begin
               <%=dmiBlkid[pidx]%>_prob_ace_slave_wr_resp_error = arg_value.atoi();
           end
           else begin
               <%=dmiBlkid[pidx]%>_prob_ace_slave_wr_resp_error = $urandom_range(5,10);
           end
       end
<% } %>
<% for(var pidx = 0; pidx < diiBlkid.length; pidx++) { %>
       if (clp.get_arg_value("+error_test=", arg_value)) begin
           if (clp.get_arg_value("+prob_ace_slave_rd_resp_error=", arg_value)) begin
               <%=diiBlkid[pidx]%>_prob_ace_slave_rd_resp_error = arg_value.atoi();
           end else if (clp.get_arg_value("+<%=diiBlkid[pidx]%>_prob_ace_slave_rd_resp_error=", arg_value)) begin
               <%=diiBlkid[pidx]%>_prob_ace_slave_rd_resp_error = arg_value.atoi();
           end
           else begin
               <%=diiBlkid[pidx]%>_prob_ace_slave_rd_resp_error = $urandom_range(5,10);
           end
           if (clp.get_arg_value("+prob_ace_slave_wr_resp_error=", arg_value)) begin
            <%=diiBlkid[pidx]%>_prob_ace_slave_wr_resp_error = arg_value.atoi();
           end else if (clp.get_arg_value("+<%=diiBlkid[pidx]%>_prob_ace_slave_wr_resp_error=", arg_value)) begin
               <%=diiBlkid[pidx]%>_prob_ace_slave_wr_resp_error = arg_value.atoi();
           end
           else begin
               <%=diiBlkid[pidx]%>_prob_ace_slave_wr_resp_error = $urandom_range(5,10);
           end
       end
<% } %>
 
    endfunction: read_args

endclass: concerto_args


