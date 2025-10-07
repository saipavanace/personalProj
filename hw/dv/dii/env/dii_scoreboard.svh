
`uvm_analysis_imp_decl(_smi)

`uvm_analysis_imp_decl(_read_addr_chnl)
`uvm_analysis_imp_decl(_read_data_chnl)
`uvm_analysis_imp_decl(_write_addr_chnl)
`uvm_analysis_imp_decl(_write_data_chnl)
`uvm_analysis_imp_decl(_write_resp_chnl)

`uvm_analysis_imp_decl(_axi2cmd_rtt)
`uvm_analysis_imp_decl(_axi2cmd_wtt)
`uvm_analysis_imp_decl(_evt_port)

<%if (obj.DiiInfo[obj.Id].configuration) {%>
`uvm_analysis_imp_decl( _apb_chnl )
<% } %>

//Q-channel port
`uvm_analysis_imp_decl(_q_chnl)


class dii_scoreboard extends uvm_component;

    `uvm_component_param_utils(dii_scoreboard)


    uvm_analysis_imp_smi #(smi_seq_item, dii_scoreboard) analysis_smi;

    uvm_analysis_imp_read_addr_chnl #(axi4_read_addr_pkt_t, dii_scoreboard) analysis_read_addr_port;
    uvm_analysis_imp_read_data_chnl #(axi4_read_data_pkt_t, dii_scoreboard) analysis_read_data_port;
    uvm_analysis_imp_write_addr_chnl #(axi4_write_addr_pkt_t, dii_scoreboard) analysis_write_addr_port;
    uvm_analysis_imp_write_data_chnl #(axi4_write_data_pkt_t, dii_scoreboard) analysis_write_data_port;
    uvm_analysis_imp_write_resp_chnl #(axi4_write_resp_pkt_t, dii_scoreboard) analysis_write_resp_port;

    uvm_analysis_imp_axi2cmd_rtt #(axi2cmd_t,dii_scoreboard) analysis_axi2cmd_rtt_port;
    uvm_analysis_imp_axi2cmd_wtt #(axi2cmd_t,dii_scoreboard) analysis_axi2cmd_wtt_port;
    uvm_analysis_imp_evt_port    #(event_in_t, dii_scoreboard) analysis_evt_port;

    <%if (obj.DiiInfo[obj.Id].configuration) {%>
    uvm_analysis_imp_apb_chnl #(apb_pkt_t, dii_scoreboard) analysis_apb_port;
    <% } %>
    uvm_analysis_imp_q_chnl #(q_chnl_seq_item , dii_scoreboard) analysis_q_chnl_port;
   // size of exclusive Monitor : if exmon_size = 0 => exmon is disabled
   int exmon_size =  <%=obj.DiiInfo[obj.Id].nExclusiveEntries%>;
   // Queue to store dropped exclusive cmdReq
   smi_seq_item dropped_ex_cmd[$];
   //Exmon predictor
     exec_mon_predictor exec_mon;
     exec_mon_result_t m_exmon_result;
     exec_mon_event_t sys_req_expected[$];
     bit sys_event_disable = 0;
     bit jump_phase_scb; // to jump the run_phase when test is killed 
   
   //scb activity monitor.
    event heartbeat_refresh;     

    uvm_reg my_register;
    uvm_reg_data_t mirrored_value;
    uvm_status_e status;  

    static  common_knob_list      dm_common_knob_list;
    
    <% if (obj.testBench == "dii") { %>
    virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_if m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif; 
    <% } %>

    int unsigned txn_id; 
    bit request_32b_enabled = $test$plusargs("request_32b");
    int last_statemachine_q_size;
    int last_axi_w_q_size;

  <% if (obj.testBench == "dii") { %>
  <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map_pkg::ral_sys_ncore  m_regs;
  <% }  else if (obj.testBench == "fsys") { %>
  concerto_register_map_pkg::ral_sys_ncore  m_regs;
  <% } %>
  
    //perf counter if
    virtual <%=obj.BlockId%>_stall_if sb_stall_if;

    `ifndef FSYS_COVER_ON
    //coverage
    dii_coverage cov; 
    `endif

    //perf counting
    int  num__txn           = 0;
    int  num__rd            = 0;
    int  num__wr            = 0;
   
    int numDtrTxns = 0;
    int numDtwTxns = 0; 
    int dtwReqEvent[int];
    int dtrReqEvent[int];

    time t_txn_first        = 0;
    time t_rd_txn_first     = 0;
    time t_wr_txn_first     = 0;

    time smi_corr_err_log_time     = 0;
    time smi_uncorr_err_log_time   = 0;
    time smi_parity_err_log_time   = 0;
    bit  smi_error_detected        = 0;
   
    static time t_txn_last         = 0;
    static time t_rd_txn_last      = 0;
    static time t_wr_txn_last      = 0;
   
    static int  num__rd_commits    = 0;
    static int  num__wr_commits    = 0;
    static int  num__commits       = 0;

    uvm_event_pool ev_pool       = uvm_event_pool::get_global_pool();
    uvm_event ev_targ_id_err     = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_targ_id_err");
    uvm_event ev_wtt_allocate    = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_wtt_allocate");
    uvm_event ev_wtt_deallocate  = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_wtt_deallocate");
    uvm_event ev_pmon_wtt_count  = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_pmon_wtt_count");
    uvm_event ev_rtt_allocate    = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_rtt_allocate");
    uvm_event ev_rtt_deallocate1 = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_rtt_deallocate1");
    uvm_event ev_rtt_deallocate2 = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_rtt_deallocate2");
    uvm_event ev_pmon_rtt_count  = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_pmon_rtt_count");
    uvm_event ev_pmon_addr_collision  = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_pmon_addr_collision");

    uvm_event ev_sys_event_err     = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_sys_event_err");
    uvm_event ev_sys_event_req     = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_sys_event_req");
   
    int         num_wtt_entries;
    int         num_rtt_entries;
    int         pmon_wtt_count;
    int         pmon_rtt_count;
    int         pmon_addr_collision_count;
    bit targ_id_err = 0;
    // SMI error injection statistics
    int  tot_num_smi_corr_err = 0;
    int  res_smi_corr_err     = 0;
    int  num_smi_corr_err     = 0;
    int  num_smi_uncorr_err   = 0;
    int  num_smi_parity_err   = 0;  // also uncorrectable

    realtime res_smi_pkt_time_old, res_smi_pkt_time_new;
    int res_mod_dp_corr_error;
    bit res_is_pre_err_pkt;

    event kill_test;
    uvm_event kill_test_1;
   
    //axi temp storage for correlating ax to cmd
    //TODO deprecate in favor of data painting correlation?
    smi_unq_identifier_bit_t      axi2cmd_rtt_q[$];
    smi_unq_identifier_bit_t      axi2cmd_wtt_q[$];
    //axi temp storage for addr arriving before data and vice versa
    axi4_write_addr_pkt_t   axi_aw_q[$];
    axi4_write_data_pkt_t   axi_w_q[$];
    axi4_read_addr_pkt_t    axi_ar_q[$];
    <%if (obj.DiiInfo[obj.Id].configuration) {%>
    apb_pkt_t  apb_q[$]; // create expected APB txn q
    <% } %>
    

    //data store
    dii_txn_q statemachine_q;        //dealloc upon state machine completion
    dii_txn_q order_q;    //dealloc upon ordering completion

    // for address translation
<% if ((obj.DiiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != 'fsys')) { %>
    static bit [31:0] addrTransV[4];
    static bit [31:0] addrTransFrom[4];
    static bit [31:0] addrTransTo[4];
<% } %>

    // Trace Capture settings
    static bit [ 7: 0] smi_capture_en;
    static bit [ 3: 0] gain_value    ;
    static bit [11: 0] inc_value     ;   

    // system params

    const int    dut_ncore_unit_id = <%=obj.DiiInfo[obj.Id].FUnitId%>;

    // statistic collection
    static ncoreStat    cmd_str_lat;
    static ncoreStat    dtw_axi_w_lat;
    static ncoreStat    cmd_axi_aw_lat;
    static ncoreStat    cmd_axi_ar_lat;
    static ncoreStat    axi_r_dtr_lat;
    static ncoreStat    axi_b_dtwrsp_lat;   // no EWA
    static ncoreStat    dtwreq_dtwrsp_lat;  // EWA
    int          sample_start;
    static int   sample_end;
    int          sampled_rd = 0;
    int          sampled_wr = 0;

    int overflow_buffer_test;
    int unblock_if_after_delay;
   
    // CSR interface handle
<%      if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
    virtual <%=obj.BlockId%>_dii_csr_probe_if u_csr_probe_vif;
<% } %>
                                                     
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //uvm phases

    //------------------------------------------------------------------------------
    // Build Phase
    //------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        analysis_smi = new ("analysis_smi", this);

        analysis_read_addr_port = new ("analysis_read_addr_port", this);
        analysis_read_data_port = new ("analysis_read_data_port", this);
        analysis_write_addr_port = new ("analysis_write_addr_port", this);
        analysis_write_data_port = new ("analysis_write_data_port", this);
        analysis_write_resp_port = new ("analysis_write_resp_port", this);

        analysis_axi2cmd_rtt_port = new ("analysis_axi2cmd_rtt_port", this);
        analysis_axi2cmd_wtt_port = new ("analysis_axi2cmd_wtt_port", this);
        analysis_evt_port = new("analysis_evt_port", this);
        <%if (obj.DiiInfo[obj.Id].configuration) {%>
        analysis_apb_port = new("analysis_apb_port",this) ;
        <% } %>
        analysis_q_chnl_port = new("analysis_q_chnl_port",this);
    
        `ifndef FSYS_COVER_ON
        cov = new();
        `endif

        cmd_str_lat       = new("<%=obj.BlockId%>_CMD_STR_LAT");
        dtw_axi_w_lat     = new("<%=obj.BlockId%>_DTW_W_LAT");
        cmd_axi_aw_lat    = new("<%=obj.BlockId%>_CMD_AW_LAT");
        cmd_axi_ar_lat    = new("<%=obj.BlockId%>_CMD_AR_LAT");
        axi_r_dtr_lat     = new("<%=obj.BlockId%>_R_DTR_LAT");
        axi_b_dtwrsp_lat  = new("<%=obj.BlockId%>_B_DTWRSP_LAT");
        dtwreq_dtwrsp_lat = new("<%=obj.BlockId%>_DTWREQ_DTWRSP_LAT");

        <% if (obj.testBench == "dii") { %>
         if(!uvm_config_db #(virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_if)::get(this, "", "m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_slv_if",  m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif)) begin //vyshak
            `uvm_error(get_full_name(), $sformatf("Cannot find m_dii0_axi_slv_if in config db")); 
        end
        <% } %>
        // perf monitor:Bound stall_if Interface
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_m_top_stall_if", sb_stall_if)) 
        begin
         `uvm_fatal("dii_scoreboard stall interface error", "virtual interface must be set for stall_if");
        end
       if (exmon_size > 0) exec_mon = new();

        <% if(obj.testBench == "dii" || obj.testBench == "cust_tb")  { %> 
        if(!uvm_config_db #(<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map_pkg::ral_sys_ncore)::get(null, "", "m_regs", m_regs))
        begin
            `uvm_fatal("SB","Failed to get m_regs from config_db to sb @239");
        end
        <% } else if(obj.testBench == "fsys") { %>
           if(!(uvm_config_db #(concerto_register_map_pkg::ral_sys_ncore)::get(null, "","m_regs",m_regs)))  `uvm_fatal("Missing in DB::", "RAL m_regs not found");
           //m_regs = concerto_register_map_pkg::ral_sys_ncore::type_id::create("m_regs", this);
        <% } %>
    endfunction : build_phase

    function void set_kill_test_event(uvm_event kill_test_1);
        this.kill_test_1 = kill_test_1;
    endfunction



    //------------------------------------------------------------------------------------------
    // Run Phase
    //------------------------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        bit wtt_inc, wtt_dec, rtt_inc, rtt_dec;
        int  quit_count = 0;
        bit statemachine_objection_raised = 0;
        bit axi_write_objection_raised = 0;

      <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
        bit test_unit_duplication_uecc;
      <% } %>
        last_statemachine_q_size = 0;
        last_axi_w_q_size = 0;

        super.run_phase(phase);

<%      if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
        if(!uvm_config_db#(virtual <%=obj.BlockId%>_dii_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif)) begin
            `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
        end
<% } %>

        if (! $value$plusargs("sample_start=%d", sample_start)) begin
           sample_start = 100;
        end

        if(!$value$plusargs("overflow_buffer_test=%d", overflow_buffer_test))begin
             overflow_buffer_test = 0;
        end

        if(!$value$plusargs("unblock_if_after_delay=%d", unblock_if_after_delay))begin
          unblock_if_after_delay = 0;
        end

        if (! $value$plusargs("sample_end=%d", sample_end)) begin
           int num_cmds;
           if (! $value$plusargs("k_num_cmd=%d", num_cmds)) begin
              num_cmds = 100;
           end
           // test will do num_cmds for each AIU
           sample_end = num_cmds - 100;
        end

        begin // RAL mirror value
        #55ns;

        my_register = m_regs.get_reg_by_name("DIIUUELR0");
        mirrored_value = my_register.get_mirrored_value();
        `uvm_info("SB",$sformatf("The mirrored value in scoreboard is %0h",mirrored_value),UVM_LOW)

        end
       
        if($test$plusargs("sys_event_disable")) begin
            sys_event_disable = 1;
        end

        num_wtt_entries = 0;
        num_rtt_entries = 0;
        pmon_addr_collision_count = 0;
       
        fork
            //ready to proceed when all activity completed.
            // mechanism: edge detection
            // use with a test objection around seq which stays until all txns issued.
            forever begin
                last_statemachine_q_size = statemachine_q.txn_q.size();
                last_axi_w_q_size = axi_w_q.size();
                
                 if($test$plusargs("uncorr_skid_buffer_test")) begin
                  kill_test_1.wait_trigger();
                  `uvm_info("SKIDBUFERROR", $sformatf("Going to jump phase in scb because uncorr error check finished"), UVM_HIGH)
                  phase.jump(uvm_report_phase::get());
                end
                
                #1us

                /*if( (last_statemachine_q_size == 0) && (statemachine_q.txn_q.size() > 0) ) begin
                   `uvm_info($sformatf("%m"), $sformatf("Zied Raise TXN"), UVM_NONE)
                    phase.raise_objection(this, "txns outstanding");
                      
                end
                else if( (last_statemachine_q_size > 0) && (statemachine_q.txn_q.size() == 0) ) begin
                   `uvm_info($sformatf("%m"), $sformatf("Zied Drop TXN"), UVM_NONE)
                    phase.drop_objection(this, "txns outstanding");
                end
                if( (last_axi_w_q_size == 0) && (axi_w_q.size() > 0) ) begin
                      `uvm_info($sformatf("%m"), $sformatf("Zied Raise axi write"), UVM_NONE)
                    phase.raise_objection(this, "axi aw/w outstanding");
                end
                else if( (last_axi_w_q_size > 0) && (axi_w_q.size() == 0) ) begin
                       `uvm_info($sformatf("%m"), $sformatf("Zied drop axi write"), UVM_NONE)
                    phase.drop_objection(this, "axi aw/w outstanding");
                end */

                
                if( (last_statemachine_q_size == 0) && (statemachine_q.txn_q.size() > 0) && !statemachine_objection_raised ) begin
                  phase.raise_objection(this, "txns outstanding");
                  statemachine_objection_raised = 1;
                end
                else if( (last_statemachine_q_size > 0) && (statemachine_q.txn_q.size() == 0) && statemachine_objection_raised ) begin
                  phase.drop_objection(this, "txns outstanding");
                  statemachine_objection_raised = 0;
                end
                if( (last_axi_w_q_size == 0) && (axi_w_q.size() > 0) && !axi_write_objection_raised ) begin
                  phase.raise_objection(this, "axi aw/w outstanding");
                  axi_write_objection_raised = 1;
                end
                else if( (last_axi_w_q_size > 0) && (axi_w_q.size() == 0) && axi_write_objection_raised ) begin
                  phase.drop_objection(this, "axi aw/w outstanding");
                  axi_write_objection_raised = 0;
                end
                
                if (statemachine_q.all_oustanding_is_SysCmd() && $test$plusargs("dii_sys_event_ev_timeout")) begin

                  -> kill_test;   // otherwise the test will hang and timeout
                  `uvm_info($sformatf("%m"), $sformatf("End of dii_sys_event_ev_timeout testcase. Jump to report phase"), UVM_NONE)
                  phase.jump(uvm_report_phase::get());
                end
                
                if (last_statemachine_q_size == 0 && statemachine_q.txn_q.size() == 0 && last_axi_w_q_size == 0 && axi_w_q.size() == 0 &&  $test$plusargs("qchannel_test")) begin
                  -> kill_test;   // otherwise the test will hang and timeout
                  `uvm_info($sformatf("%m"), $sformatf("Qchannel testcase. Jump to report phase"), UVM_NONE)
                  phase.jump(uvm_report_phase::get());
                end

                   
            end

            //scb activity monitor, give a signal when triggered
            forever begin
                @heartbeat_refresh;
                phase.raise_objection(this, "heart_beat");
                phase.drop_objection(this, "heart_beat");
            end
        join_none
        `uvm_info($sformatf("%m"), $sformatf("useRsiliency=%0d, testBenchName=%s", <%=obj.useResiliency%>, "<%=obj.testBench%>"), UVM_NONE)

        fork
           forever begin
              ev_wtt_allocate.wait_trigger();
              sb_stall_if.perf_count_events["Active_WTT_entries"].push_back(num_wtt_entries);
              num_wtt_entries++;
              sb_stall_if.perf_count_events["Active_WTT_entries"].push_back(num_wtt_entries);
              `uvm_info($sformatf("%m"), $sformatf("PMON DBG: get ev_wtt_allocate"), UVM_HIGH)
           end
           forever begin
              ev_wtt_deallocate.wait_trigger();
              sb_stall_if.perf_count_events["Active_WTT_entries"].push_back(num_wtt_entries);
              num_wtt_entries--;
              sb_stall_if.perf_count_events["Active_WTT_entries"].push_back(num_wtt_entries);
              `uvm_info($sformatf("%m"), $sformatf("PMON DBG: get ev_wtt_deallocate"), UVM_HIGH)
           end
           forever begin
              ev_rtt_allocate.wait_trigger();
              sb_stall_if.perf_count_events["Active_RTT_entries"].push_back(num_rtt_entries);
              num_rtt_entries++;
              sb_stall_if.perf_count_events["Active_RTT_entries"].push_back(num_rtt_entries);
              `uvm_info($sformatf("%m"), $sformatf("PMON DBG: get ev_rtt_allocate"), UVM_HIGH)
           end
           forever begin
              ev_rtt_deallocate1.wait_trigger();
              sb_stall_if.perf_count_events["Active_RTT_entries"].push_back(num_rtt_entries);
              num_rtt_entries--;
              sb_stall_if.perf_count_events["Active_RTT_entries"].push_back(num_rtt_entries);
              `uvm_info($sformatf("%m"), $sformatf("PMON DBG: get ev_rtt_deallocate1"), UVM_HIGH)
           end
           forever begin
              ev_rtt_deallocate2.wait_trigger();
              sb_stall_if.perf_count_events["Active_RTT_entries"].push_back(num_rtt_entries);
              num_rtt_entries -= 2;
              sb_stall_if.perf_count_events["Active_RTT_entries"].push_back(num_rtt_entries);
              `uvm_info($sformatf("%m"), $sformatf("PMON DBG: get ev_rtt_deallocate2"), UVM_HIGH)
           end

           forever begin
              ev_pmon_wtt_count.wait_trigger();
              uvm_config_db#(int)::get(null, "tb_top", "<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_TB_pmon_wtt_count", pmon_wtt_count);
              `uvm_info($sformatf("%m"), $sformatf("PMON DBG: get %s: %0d", "<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_TB_pmon_wtt_count", pmon_wtt_count), UVM_HIGH)
              if (pmon_wtt_count != num_wtt_entries) begin
                 if (quit_count > 2) begin
                    `uvm_warning($sformatf("%m"), $sformatf("PMON_WTT_COUNT mismatch! TB:%0h RTL:%0h", num_wtt_entries, pmon_wtt_count))
                 end else begin
                    quit_count++;
                    `uvm_warning($sformatf("%m"), $sformatf("PMON_WTT_COUNT mismatch! TB:%0h RTL:%0h", num_wtt_entries, pmon_wtt_count))
                 end
              end
              if (pmon_wtt_count > <%=obj.DiiInfo[obj.Id].cmpInfo.nWttCtrlEntries%>) begin
                if (exmon_size == 0) `uvm_error($sformatf("%m"), $sformatf("PMON_WTT_COUNT exceeds nWttCtrlEntries! TB:%0h RTL:%0h", num_wtt_entries, <%=obj.DiiInfo[obj.Id].cmpInfo.nWttCtrlEntries%>))
              end
           end
           
           forever begin
              ev_pmon_rtt_count.wait_trigger();
              uvm_config_db#(int)::get(null, "tb_top", "<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_TB_pmon_rtt_count", pmon_rtt_count);
              `uvm_info($sformatf("%m"), $sformatf("PMON DBG: get %s:  %0d", "<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_TB_pmon_rtt_count", pmon_rtt_count), UVM_HIGH)
              if (pmon_rtt_count != num_rtt_entries) begin
                 if (quit_count > 2) begin
                    `uvm_warning($sformatf("%m"), $sformatf("PMON_RTT_COUNT mismatch! TB:%0h RTL:%0h", num_rtt_entries, pmon_rtt_count))
                 end else begin
                    quit_count++;
                    `uvm_warning($sformatf("%m"), $sformatf("PMON_RTT_COUNT mismatch! TB:%0h RTL:%0h", num_rtt_entries, pmon_rtt_count))
                 end                    
              end
              if (pmon_rtt_count > <%=obj.DiiInfo[obj.Id].cmpInfo.nRttCtrlEntries%>) begin
                if (exmon_size == 0) `uvm_error($sformatf("%m"), $sformatf("PMON_RTT_COUNT exceeds nRttCtrlEntries! TB:%0h RTL:%0h", num_rtt_entries, <%=obj.DiiInfo[obj.Id].cmpInfo.nRttCtrlEntries%>))
              end
           end
        join_none
       
        fork
           forever begin
              ev_pmon_addr_collision.wait_trigger();
              sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
              pmon_addr_collision_count++;
           end
        join_none

      <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
        if ($test$plusargs("expect_mission_fault")) begin
        fork
          if(!$test$plusargs("test_unit_duplication")) begin
            begin
              forever begin
                 #(100*1ns);
                 if (u_csr_probe_vif.fault_mission_fault == 0) begin
                    @u_csr_probe_vif.fault_mission_fault;
                 end
                 if ($test$plusargs("multiple_mission_faults")) begin
                    `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> delay mission fault kill by 5000ns"), UVM_NONE)
                    #(5000*1ns);  // allow more errors to be injected
                 end else begin
                    #(10*1ns);  // make sure enough time elapsed so we can ensure the errored request is dropped
                 end
                 `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                 -> kill_test;   // otherwise the test will hang and timeout
                 `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
                 phase.jump(uvm_report_phase::get());
              end
            end
          end else begin
            begin
              forever begin
                #(100*1ns);
                uvm_config_db#(bit)::wait_modified(this, "", "test_unit_duplication_uecc");
                `uvm_info(get_name(), "modified value of test_unit_duplication_uecc", UVM_LOW)
                uvm_config_db#(bit)::get(this, "", "test_unit_duplication_uecc", test_unit_duplication_uecc);
                if(test_unit_duplication_uecc) begin
                  if(u_csr_probe_vif.fault_mission_fault == 0) begin
                     @u_csr_probe_vif.fault_mission_fault;
                  end
                  if ($test$plusargs("multiple_mission_faults")) begin
                     `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> delay mission fault kill by 5000ns"), UVM_NONE)
                     #(5000*1ns);  // allow more errors to be injected
                  end else begin
                     #(10*1ns);  // make sure enough time elapsed so we can ensure the errored request is dropped
                  end
                  `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                  -> kill_test;   // otherwise the test will hang and timeout
                  `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
                  phase.jump(uvm_report_phase::get());
                end
              end
            end
          end
        join_none
        end
      <% } %>

    endtask // run_phase


    //------------------------------------------------------------------------------
    // Check Phase
    //------------------------------------------------------------------------------

    function void check_phase(uvm_phase phase);
        int error = 0;
        bit [2:0] inj_cntl;

        int period;
        int cmd_str_latency, exp_cmd_str_latency;
        int dtw_axi_w_latency, exp_dtw_axi_w_latency;
        int cmd_axi_aw_latency, exp_cmd_axi_aw_latency;
        int cmd_axi_ar_latency, exp_cmd_axi_ar_latency;
        int axi_r_dtr_latency, exp_axi_r_dtr_latency;
        int axi_b_dtwrsp_latency, exp_axi_b_dtwrsp_latency;
        int dtwreq_dtwrsp_latency, exp_dtwreq_dtwrsp_latency;
       
        order_q.resolve_ordering(); //resolve any remaining ordering now that sim is quiet.

        // dump statistic
        cmd_str_lat.print_stat();
        dtw_axi_w_lat.print_stat();
        cmd_axi_aw_lat.print_stat();
        cmd_axi_ar_lat.print_stat();
        axi_r_dtr_lat.print_stat();
        axi_b_dtwrsp_lat.print_stat();
        dtwreq_dtwrsp_lat.print_stat();

       if($test$plusargs("latency_chk_test")) begin

            period = <%=obj.Clocks[0].params.period%>;

            // Get the minimum latency if the packet type is part of the stimulus
            cmd_str_latency       = (int'(cmd_str_lat.get_max() == 0)) ? 0 : int'(cmd_str_lat.get_min()/period);
            dtw_axi_w_latency     = (int'(dtw_axi_w_lat.get_max() == 0)) ? 0 : int'(dtw_axi_w_lat.get_min()/period);
            cmd_axi_aw_latency    = (int'(cmd_axi_aw_lat.get_max() == 0)) ? 0 : int'(cmd_axi_aw_lat.get_min()/period);
            cmd_axi_ar_latency    = (int'(cmd_axi_ar_lat.get_max() == 0)) ? 0 : int'(cmd_axi_ar_lat.get_min()/period);
            axi_r_dtr_latency     = (int'(axi_r_dtr_lat.get_max() == 0)) ? 0 : int'(axi_r_dtr_lat.get_min()/period);
            axi_b_dtwrsp_latency  = (int'(axi_b_dtwrsp_lat.get_max() == 0)) ? 0 : int'(axi_b_dtwrsp_lat.get_min()/period);
            dtwreq_dtwrsp_latency = (int'(dtwreq_dtwrsp_lat.get_max() == 0)) ? 0 : int'(dtwreq_dtwrsp_lat.get_min()/period);

            // From DII Micro Arch Spec
            exp_cmd_str_latency       = 5; 
            exp_dtw_axi_w_latency     = 5;
            exp_cmd_axi_aw_latency    = 4; // One cycle more than the exp value in Arch Spec
            exp_cmd_axi_ar_latency    = 4;
            exp_axi_r_dtr_latency     = 3;
            exp_axi_b_dtwrsp_latency  = 3;
            exp_dtwreq_dtwrsp_latency = 3;

            assert (cmd_str_latency <= exp_cmd_str_latency) else
            `uvm_error($sformatf("%m"), $sformatf("CMD_REQ -> STR_REQ Latency is greater than the expected value. Actual value : %0d, Expected_value : %0d", cmd_str_latency, exp_cmd_str_latency))
       
            assert (dtw_axi_w_latency <= exp_dtw_axi_w_latency) else
            `uvm_error($sformatf("%m"), $sformatf("DTW_REQ -> AXI_W Latency is greater than the expected value. Actual value : %0d, Expected_value : %0d", dtw_axi_w_latency, exp_dtw_axi_w_latency))
       
            assert (cmd_axi_aw_latency <= exp_cmd_axi_aw_latency) else
            `uvm_error($sformatf("%m"), $sformatf("CMD_REQ -> AXI_AW Latency is greater than the expected value. Actual value : %0d, Expected_value : %0d", cmd_axi_aw_latency, exp_cmd_axi_aw_latency))
       
            assert (cmd_axi_ar_latency <= exp_cmd_axi_ar_latency) else
            `uvm_error($sformatf("%m"), $sformatf("CMD_REQ -> AXI_AR Latency is greater than the expected value. Actual value : %0d, Expected_value : %0d", cmd_axi_ar_latency, exp_cmd_axi_ar_latency))
       
            assert (axi_r_dtr_latency <= exp_axi_r_dtr_latency) else
            `uvm_error($sformatf("%m"), $sformatf("AXI_R -> DTR Latency is greater than the expected value. Actual value : %0d, Expected_value : %0d", axi_r_dtr_latency, exp_axi_r_dtr_latency))
       
            assert (axi_b_dtwrsp_latency <= exp_axi_b_dtwrsp_latency) else
            `uvm_error($sformatf("%m"), $sformatf("AXI_B -> DTW_RSP Latency is greater than the expected value. Actual value : %0d, Expected_value : %0d", axi_b_dtwrsp_latency, exp_axi_b_dtwrsp_latency))
       
            assert (dtwreq_dtwrsp_latency <= exp_dtwreq_dtwrsp_latency) else
            `uvm_error($sformatf("%m"), $sformatf("DTW_REQ -> DTW_RSP Latency is greater than the expected value. Actual value : %0d, Expected_value : %0d", dtwreq_dtwrsp_latency, exp_dtwreq_dtwrsp_latency))
      
        end // if($test$plusargs("latency_chk_test"))
 
        // Trace and Debug register settings
        `uvm_info("%m", $sformatf("CCTRLR CaptureEn=%0h, gain=%0d, inc=%0d",
                                  smi_capture_en, gain_value, inc_value), UVM_LOW)
        // Error inject
        `uvm_info($sformatf("%m"), $sformatf("Error Injection: corr=%0d, uncorr=%0d, parity=%0d tot_corr_err=%0d res_corr_err=%0d",
                                             num_smi_corr_err, num_smi_uncorr_err, num_smi_parity_err, tot_num_smi_corr_err, res_smi_corr_err), UVM_NONE)
        if (! $value$plusargs("inj_cntl=%d", inj_cntl)) begin
           inj_cntl = 0;
        end
        //end of sim checks
        if( ! ($test$plusargs("has_ucerr") || (inj_cntl <= 1)) ) begin
           if(statemachine_q.txn_q.size()!=0)  error++;    //#Check.DII.EndOfSim.all_completed
           if(order_q.txn_q.size()!=0)         error++;    //#Check.DII.EndOfSim.order_resolved
           if(axi_w_q.size()!=0)               error++;    //#Check.DII.EndOfSim.axi_w_aw
           if (num_wtt_entries != 0 && exmon_size == 0)           error++;    //#Check.DII.EndOfSim.wtt_entries
           if (num_rtt_entries != 0 && exmon_size == 0)           error++;    //#Check.DII.EndOfSim.rtt_entries
          `uvm_info("%m", $sformatf("Queues status : statemachine_q.txn_q.size =%0d, order_q.txn_q.size()=%0d, axi_w_q.size()=%0d, num_wtt_entries = %0d,num_rtt_entries = %0d",
                                  statemachine_q.txn_q.size(), order_q.txn_q.size(), axi_w_q.size(),num_wtt_entries,num_rtt_entries), UVM_LOW)
           <%if (obj.DiiInfo[obj.Id].configuration) {%>
           if(apb_q.size()!=0) error++;
           <% } %>
           end else begin
<%             if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
<%                if (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
                     if ( (u_csr_probe_vif.fault_mission_fault == 0) && (inj_cntl == 4) && (! $test$plusargs("dont_check_mf"))) begin
                          error++;
                     end
<%        } %>
<%                if (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                     if ( (u_csr_probe_vif.fault_mission_fault == 0) && (inj_cntl == 2) && (! $test$plusargs("dont_check_mf"))) begin
                          error++;
                     end            
<%        } %>
<% } %>
        end
       
        if(error != 0)
            `uvm_error($sformatf("%m"), $sformatf("error count: %d", error))
        else
            pre_abort();    //print the same only once without signalling error

    endfunction: check_phase

    function void report_phase(uvm_phase phase);
      bit [2:0] inj_cntl;
      super.report_phase(phase);
      if (! $value$plusargs("inj_cntl=%d", inj_cntl)) begin
         inj_cntl = 0;
      end

      <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
         if($test$plusargs("expect_mission_fault")) begin
           if (u_csr_probe_vif.fault_mission_fault == 0) begin
<%           if ( (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType != "parity") &&
                  (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType != "ecc") ) { %>
             if (inj_cntl == 0) begin
             `uvm_error({"fault_injector_checker_",get_name()}
               , $sformatf({"NON PAR/ECC: expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}
                 , u_csr_probe_vif.fault_mission_fault))
             end
<% }     else if (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
             if (inj_cntl == 4) begin
             `uvm_error({"fault_injector_checker_",get_name()}
               , $sformatf({"PARITY: expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}
                 , u_csr_probe_vif.fault_mission_fault))
             end
<% }     else if (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
             if (inj_cntl == 2) begin
             `uvm_error({"fault_injector_checker_",get_name()}
               , $sformatf({"ECC: expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}
                 , u_csr_probe_vif.fault_mission_fault))
             end
<% } %>
           end else begin
             `uvm_info(get_name()
               , $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}
                 , u_csr_probe_vif.fault_mission_fault)
               , UVM_LOW)
           end
        end
<% } %>
    endfunction: report_phase
    

    //print info upon fatal exit.
    function void pre_abort();
        real cnt_adjust = 1.024*1.024*1.024; // from base 10 to base 2
        real raw_total;

        //print queues
        `uvm_info($sformatf("%m"), "Start printing Oustanding txns", UVM_MEDIUM)
        statemachine_q.print();
        `uvm_info($sformatf("%m"), "End printing Oustanding txns", UVM_MEDIUM)
        //
        `uvm_info($sformatf("%m"), "order_q", UVM_MEDIUM)
         `uvm_info($sformatf("%m"), "Start printing Ordering Queue", UVM_MEDIUM)
         order_q.print();
         `uvm_info($sformatf("%m"), "End printing Ordering Queue", UVM_MEDIUM)
        `uvm_info($sformatf("%m"), $sformatf("axi_aw_q : %d entries", axi_aw_q.size()), UVM_MEDIUM)
        `uvm_info($sformatf("%m"), $sformatf("%p", axi_aw_q), UVM_MEDIUM); 

        //perf stats
        if (num__wr > 0) begin
            raw_total = (real'(sampled_wr))*(CACHELINESIZE/(request_32b_enabled?2:1));
           `uvm_info($sformatf("%m"), $sformatf("t_wr_txn_last :%0t t_wr_txn_first :%0t num__wr :%0d total data %f",t_wr_txn_last,t_wr_txn_first,sampled_wr,raw_total), UVM_NONE)
           `uvm_info($sformatf("%m"), $sformatf("wr bandwidth      (GB/s): %.2f", (raw_total/((t_wr_txn_last-t_wr_txn_first)*cnt_adjust))*(10**(12-9))), UVM_NONE)
        end
        if (num__rd > 0) begin
            raw_total = (real'(sampled_rd))*(CACHELINESIZE/(request_32b_enabled?2:1));
           `uvm_info($sformatf("%m"), $sformatf("t_rd_txn_last :%0t t_rd_txn_first :%0t num_rd :%0d total data %f:",t_rd_txn_last,t_rd_txn_first,sampled_rd,raw_total), UVM_NONE)
           `uvm_info($sformatf("%m"), $sformatf("rd bandwidth      (GB/s): %.2f", (raw_total/((t_rd_txn_last-t_rd_txn_first)*cnt_adjust))*(10**(12-9))), UVM_NONE)
        end
        if ((num__rd > 0) && (num__wr > 0)) begin
            raw_total = (real'(sampled_rd+sampled_wr))*(CACHELINESIZE/(request_32b_enabled?2:1));
            `uvm_info($sformatf("%m"), $sformatf("mixed bandwidth  (GB/s): %.2f", (raw_total/((t_txn_last-t_txn_first)*cnt_adjust))*(10**(12-9))), UVM_NONE)
        end
        `uvm_info($sformatf("%m"), $sformatf("address collision count: %0d", pmon_addr_collision_count), UVM_NONE)

        <% if (obj.useResiliency) { %>
        `uvm_info($sformatf("%m"), $sformatf("Error Injection: tot commands=%0d corr=%0d, uncorr=%0d, parity=%0d",
                                             num__rd+num__wr, num_smi_corr_err, num_smi_uncorr_err, num_smi_parity_err), UVM_NONE)
        <% } %>
    endfunction : pre_abort


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Constructor
    
    function new(string name = "dii_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        
        $timeformat(-9, 2, " ns", 10);
    
        statemachine_q   = new($sformatf("%s, state",name));    //data store
        order_q   = new($sformatf("%s, order",name));  
        txn_id = 0;  
    
        ////TODO enable pw_down_test
        //if($test$plusargs("pw_down_test")) begin
        //    pw_down_test_en = 1;
        //end
        //else begin
       //    pw_down_test_en = 0;
        //end

    endfunction : new



    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // receive msgs from interfaces

    //------------------------------------------------------------------------------
    // triage any smi msg
    //------------------------------------------------------------------------------
    function void write_smi(smi_seq_item msg_in);
        int deletion_index;
        smi_seq_item msg;
        dii_txn txn;
        dii_txn find_q[$];
        int  wt_wrong_dut_id_cmd, wt_wrong_dut_id_dtw, wt_wrong_dut_id_dtr, wt_wrong_dut_id_dtwdbgrsp;
        exec_mon_event_t m_exmon_event;
        msg_in.unpack_smi_seq_item();

        `uvm_info($sformatf("%m"), $sformatf("DII got new smi msg: %p: cmd=%p unq_id=%p rsp_unq_id=%p smi_order=%p",
                                             msg_in.convert2string(), msg_in.smi_msg_type, msg_in.smi_unq_identifier, msg_in.smi_rsp_unq_identifier, msg_in.smi_order), UVM_LOW)

        //clean copy of packet to keep in the dii_txn
        msg = new();
        msg.copy(msg_in);

        if (! $value$plusargs("wt_wrong_dut_id_cmd=%d", wt_wrong_dut_id_cmd)) begin
           wt_wrong_dut_id_cmd = 0;
        end
        if (! $value$plusargs("wt_wrong_dut_id_dtw=%d", wt_wrong_dut_id_dtw)) begin
           wt_wrong_dut_id_dtw = 0;
        end
        if (! $value$plusargs("wt_wrong_dut_id_dtr=%d", wt_wrong_dut_id_dtr)) begin
           wt_wrong_dut_id_dtr = 0;
        end
        if (! $value$plusargs("wt_wrong_dut_id_dtwdbgrsp=%d", wt_wrong_dut_id_dtwdbgrsp)) begin
           wt_wrong_dut_id_dtwdbgrsp = 0;
        end
        //#Check.DII.tagiderr.V3.cmdreq
 	//#Check.DII.tagiderr.V3.dtrrsp
	//#Check.DII.tagiderr.V3.dtwdbgrsp
	//#Check.DII.tagiderr.V3.dtwreq
	//#Check.DII.tagiderr.V3.strrsp
        if (msg.smi_targ_ncore_unit_id != <%=obj.DiiInfo[obj.Id].FUnitId%>) begin
           if ( (msg.isCmdMsg() && $test$plusargs("wt_wrong_dut_id_cmd")) || (msg.isDtwMsg && $test$plusargs("wt_wrong_dut_id_dtw")) ||
                (msg.isStrRspMsg && $test$plusargs("wt_wrong_dut_id_strrsp")) || (msg.isDtrRspMsg && $test$plusargs("wt_wrong_dut_id_dtrrsp")) ||
                (msg.isDtwDbgRspMsg && $test$plusargs("wt_wrong_dut_id_dtwdbgrsp")) )  begin
              `uvm_info($sformatf("%m"), $sformatf("MSG TYPE: %p detected target id error TARGID: %p SRCID: %p",
                                                   msg.smi_msg_type, msg.smi_targ_id, msg.smi_src_id), UVM_LOW)
              ev_targ_id_err.trigger(msg);
	      targ_id_err = 1;
           end
        end
       
        // Handle unused SMI fields for CMDREQ
        <% if (smiObj.WSMISTEER == 0) { %>
            msg.smi_steer = 1'b0;
        <% } %>
        <% if (smiObj.WSMIMSGPRI == 0) { %>
            msg.smi_msg_pri = 1'b0;
        <% } %>
        <% if (smiObj.WSMIMSGTIER == 0) { %>
            msg.smi_msg_tier = 1'b0;
        <% } %>
        <% if (smiObj.WSMIMSGQOS == 0) { %>
            msg.smi_msg_qos = 1'b0;
        <% } %>
        <% if (smiObj.WSMINDPAUX == 0) { %>
            msg.smi_ndp_aux = 1'b0;
        <% } %>

        // get error statistics
        msg.clear_error_counts();
        if(msg_in.ndp_corr_error || msg_in.hdr_corr_error || msg_in.dp_corr_error) begin
           update_resiliency_ce_cnt(msg_in);
        end
        if (msg.update_error_counts(msg_in)) begin
           smi_error_detected = 1;
           `uvm_info($sformatf("%m"), $sformatf("DII SCB error detected: %p", msg_in.convert2string()), UVM_HIGH)
           `uvm_info($sformatf("%m"), $sformatf("DII SCB error counter updat: MsgType=%p C=(H%0d N%0d D%0d) UC=(H%0d N%0d D%0d) P=(H%0d N%0d D%0d)",
                                                msg_in.smi_msg_type, msg_in.hdr_corr_error  , msg_in.ndp_corr_error  , msg_in.dp_corr_error,
                                                msg_in.hdr_uncorr_error, msg_in.ndp_uncorr_error, msg_in.dp_uncorr_error,
                                                msg_in.hdr_parity_error, msg_in.ndp_parity_error, msg_in.dp_parity_error), UVM_HIGH)
        end
        tot_num_smi_corr_err  += msg_in.ndp_corr_error   + msg_in.hdr_corr_error   + msg_in.dp_corr_error;
//        num_smi_corr_err      += (msg_in.ndp_corr_error  + msg_in.hdr_corr_error   + (msg_in.dp_corr_error   > 0));
//        num_smi_uncorr_err    += msg_in.ndp_uncorr_error + msg_in.hdr_uncorr_error + (msg_in.dp_uncorr_error > 0);
//        num_smi_parity_err    += msg_in.ndp_parity_error + msg_in.hdr_uncorr_error + (msg_in.dp_parity_error > 0);
        if (smi_error_detected && (smi_corr_err_log_time != $time)) begin
           num_smi_corr_err      += (msg_in.ndp_corr_error   + msg_in.hdr_corr_error   + msg_in.dp_corr_error);
           smi_corr_err_log_time  = $time;
        end
        if (smi_error_detected && (smi_uncorr_err_log_time != $time)) begin
           num_smi_uncorr_err     += (msg_in.ndp_uncorr_error + msg_in.hdr_uncorr_error + msg_in.dp_uncorr_error);
           smi_uncorr_err_log_time = $time;
        end           
        if (smi_error_detected && (smi_parity_err_log_time != $time)) begin
           num_smi_parity_err     += (msg_in.ndp_parity_error + msg_in.hdr_uncorr_error + msg_in.dp_parity_error);
           smi_parity_err_log_time = $time;
        end           
        // for uncorrectable ECC error or Parity error, the incoming SMI will be dropped
        // Will DP errors be handled differently?
        if ( ~ ( (msg_in.ndp_uncorr_error || msg_in.hdr_uncorr_error || msg_in.dp_uncorr_error) ||
                 (msg_in.ndp_parity_error || msg_in.hdr_parity_error ) || 
                 ($test$plusargs("has_ucerr") && ((msg_in.isCmdMsg() && (msg_in.smi_targ_ncore_unit_id != <%=obj.DiiInfo[obj.Id].FUnitId%>)) ||
                                                  (msg_in.isDtwMsg() && (msg_in.smi_targ_ncore_unit_id != <%=obj.DiiInfo[obj.Id].FUnitId%>)))) ) && !$test$plusargs("uncorr_skid_buffer_test"))  begin
           
           //#Check.DII.EventMsg.EventInReq
           if (msg.smi_msg_type == SYS_REQ) begin

               if (sys_req_expected.size() == 0)   begin 
                  `uvm_error($sformatf("%m"), $psprintf("SysReq message was not expected"))
               end else  begin
                  m_exmon_event = sys_req_expected.pop_front(); // sys_req is expected and it's correctly sent by RTL so DV delete it from expected queue.
               end
   
           end
           
           //obtain corresponding txn
           //#CheckTime.DII.Concerto.sequence
           statemachine_q.check_collides(msg);
           txn = statemachine_q.get_txn(msg,txn_id);  //enqueues new txn iff cmd

           `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%>_UID:%0p :Smi msg got recently in scb : %p: cmd=%p unq_id=%p rsp_unq_id=%p \ncorresponds to the txn %0p",
                                             txn.txn_id, msg_in.convert2string(), msg_in.smi_msg_type, msg_in.smi_unq_identifier, msg_in.smi_rsp_unq_identifier, txn), UVM_LOW)

            if(msg.smi_msg_type == DTW_RSP && txn.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_NONE ) begin //check if dtw_rsp is late for wr trans with order 00 and vz 0/1

                if(txn.axi_expd.size() == 0) begin //got all the axi side transactions
                    `uvm_info("LATE_DTW_RSP", $sformatf("The DTW_RSP was indeed a late response for txn %p and txn_id as %0d",txn,txn.txn_id), UVM_HIGH);
                end
                else begin
                    `uvm_error("LATE_DTW_RSP", $sformatf("DTW_RSP was not a late response for txn %p with txn_id!",txn,txn.txn_id));
                end

            end
                 // exclusive monitor prediction 
           if ((msg.smi_msg_type inside {CMD_RD_NC, CMD_WR_NC_PTL, CMD_WR_NC_FULL}) && exmon_size > 0) begin
               
               //#Check.DII.ExMon.Func
               m_exmon_result = exec_mon.predict_exmon(msg) ; 
               
               txn.m_exmon_status = m_exmon_result.exmon_status ;   //store exclusive monitor status
               if(txn.m_exmon_status == EX_FAIL) begin

                  dropped_ex_cmd.push_back(msg);  // store dropped cmd_req
               end
               //#Check.DII.EventMsg.DisableEvent
               if (m_exmon_result.exmon_event.event_trig == 1 && sys_event_disable == 0) begin
                  sys_req_expected.push_back(m_exmon_result.exmon_event);
               end
           end                                   
           //generate reference msg and compare all fields   

           txn.gen_exp_smi(msg).compare(msg);

            //at this point, I know msg is correctly formed 
           
           txn.add_msg(msg);

           //checks among msgs.
           // also checks the type.
           //#Check.DII.CMDreq.Msg_type
           //#Check.DII.CMDreq.Cache_Maintenance_type
           //#Check.DII.DTRreq.Msg_type
           //#Check.DII.DTWreq.Msg_type
           case(msg.smi_msg_type)
             // req dut <- smi
             CMD_RD_NC, CMD_WR_NC_PTL, CMD_WR_NC_FULL: begin
                if(msg.smi_order != SMI_ORDER_NONE )
                  order_q.txn_q.push_back(txn);  //Ordering checks use q with different deallocation condition

                //perf monitoring
                num__txn ++;   
                if (num__txn == sample_start) t_txn_first    = $time;

                if(msg.isCmdNcRdMsg()) begin;
                   num__rd++;
                   if (num__rd == sample_start)  t_rd_txn_first = $time;
                   if ( (num__rd >= sample_start) && (num__rd <= sample_end) ) begin
                      sampled_rd++;
                   end
                end
                else if (msg.isCmdNcWrMsg()) begin
                   num__wr++;
                   if (num__wr == sample_start) t_wr_txn_first = $time;
                   if ( (num__wr >= sample_start) && (num__wr <= sample_end) ) begin
                      sampled_wr++;
                   end
                end
             end
             CMD_CLN_SH_PER, CMD_CLN_INV, CMD_MK_INV, CMD_CLN_VLD: 
               order_q.txn_q.push_back(txn);  //Ordering checks use q with different deallocation condition
             DTW_DATA_PTL, DTW_DATA_DTY, DTW_DATA_CLN:   begin end //checkDtwReq(msg, txn);
             DTW_NO_DATA:                                begin end //treated identical to other dtws for ease of protocol completion at dii.

             // rsp dut -> smi
             NC_CMD_RSP:                                 begin end //checkCmdRsp(msg, txn);
             DTW_RSP:                                    begin end //checkDtwRsp(msg, txn);
             
             // req dut -> smi
             DTW_DBG_REQ:                                begin
                `uvm_info("%m", $sformatf("SMI_DTWDBGRSP message received"), UVM_LOW) end //Trace-Debug Request
             STR_STATE:                                  begin end //checkStrReq(msg, txn);
             DTR_DATA_INV: begin
                //max dtrs in flight
                find_q = statemachine_q.txn_q.find with (
                                                         (item.smi_recd[eConcMsgDtrReq])
                                                         && (item.smi_expd[eConcMsgDtrRsp])
                                                         );
             end

             // rsp dut <- smi
             STR_RSP:                                    begin end //checkStrRsp(msg, txn);
             DTR_RSP:                                    begin end //checkDtrRsp(msg, txn);
             DTW_DBG_RSP:                                begin end //
             SYS_REQ  :                         begin 
                   <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
                  `ifndef FSYS_COVER_ON
                   cov.collect_sys_event_smi(msg.smi_msg_type,msg.smi_sysreq_op);
                   `endif
                    <% } %>

             end
             SYS_RSP  :                                  begin 
                   <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
                  `ifndef FSYS_COVER_ON
                   cov.collect_sys_event_smi(msg.smi_msg_type,0);
                  `endif
                    <% } %>
             end
             //Ncore 3.0 ignores these
             // // error msgs
             // CME_RSP:                                    begin end //checkCmeRsp(msg, txn);
             // TRE_RSP:                                    begin end //checkTreRsp(msg, txn);
             default:                                  `uvm_error($sformatf("%m"), $sformatf("invalid msg type: %p", msg.smi_msg_type))
           endcase


           `ifndef FSYS_COVER_ON
           cov.statemachine_q = statemachine_q;
           // Time sequence coverage
           cov.collect_smi_seq(msg);
           cov.collect_dii_seq(txn);
           cov.collect_time_before_RetireTxn(txn);
           `endif

           //retire txn iff complete
           if(txn.smi_expd.size() == 0)    
             ->heartbeat_refresh;     //scb activity monitor.   
           if( axi_aw_q.size() == 0 && axi_ar_q.size() == 0)  //all ordering has been committed at this moment => ok to check all ordering.
             order_q.resolve_ordering();

           if (msg.isDtwDbgReqMsg() || msg.isDtwDbgRspMsg() || msg.isSysReqMsg() || msg.isSysRspMsg()) begin
              `uvm_info($sformatf("%m"), $sformatf("WRITE_SMI: msg_id=%2h rmsg_id=%2h msg_type=%2h smi_expd=%0d axi_expd=%0d",
					           msg.smi_msg_id, msg.smi_rmsg_id, msg.smi_msg_type, txn.smi_expd.size(), txn.axi_expd.size()), UVM_LOW)
           end else begin
              `uvm_info($sformatf("%m"), $sformatf("WRITE_SMI: cmd_msg_id=%2h msg_id=%2h rmsg_id=%2h msg_type=%2h smi_expd=%0d axi_expd=%0d",
					           txn.smi_recd[eConcMsgCmdReq].smi_msg_id, msg.smi_msg_id, msg.smi_rmsg_id, msg.smi_msg_type, txn.smi_expd.size(), txn.axi_expd.size()), UVM_LOW)
           end
           fork
              scTryRetire(txn);
           join_none
        end // if ( ~ ( (msg_in.ndp_uncorr_error || msg_in.hdr_uncorr_error || msg_in.dp_uncorr_error) ||...
        else begin
           `uvm_info($sformatf("%m"), $sformatf("WRITE SMI input\n%p\n has UNcorrectable error, and is dropped", msg_in), UVM_LOW)
//            -> kill_test;
        end

    endfunction : write_smi



    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // axi boundary
    
    //----------------------------------------------------------------------- 
    // ACE Read Address Channel
    function void write_read_addr_chnl(axi4_read_addr_pkt_t axi_in);
        axi4_read_addr_pkt_t axi;

        axi = new();
        axi.copy(axi_in);
        `uvm_info($sformatf("%m"), $sformatf("got axi read Adress: %s",axi.sprint_pkt()), UVM_LOW)
        axi_ar_q.push_back(axi);
        if(!$test$plusargs("uncorr_skid_buffer_test")) checkArChnl(axi);

    endfunction : write_read_addr_chnl

    //----------------------------------------------------------------------- 
    // ACE Read Data Channel
    function void write_read_data_chnl(axi4_read_data_pkt_t axi_in);
        axi4_read_data_pkt_t axi;
        axi4_read_addr_pkt_t axi_ar;

        axi = new();
        axi.copy(axi_in);
       `uvm_info($sformatf("%m"), $sformatf("got axi read Data: %s",axi.sprint_pkt()), UVM_LOW)
        axi_ar = axi_ar_q.pop_front();
         if(!$test$plusargs("uncorr_skid_buffer_test")) checkRChnl(axi);

    endfunction : write_read_data_chnl

    //----------------------------------------------------------------------- 
    // ACE Write Address Channel
    function void write_write_addr_chnl(axi4_write_addr_pkt_t axi_in);
        axi4_write_addr_pkt_t axi_aw;
        axi4_write_data_pkt_t axi_w;

        axi_aw = new();
        axi_aw.copy(axi_in);

        `uvm_info($sformatf("%m"), $sformatf("got axi: %s",axi_aw.sprint_pkt()), UVM_LOW)

        if (axi_w_q.size() == 0) begin
            axi_aw_q.push_back(axi_aw);
            `uvm_info($sformatf("%m"), $sformatf("aw -> tmp queue"), UVM_MEDIUM)
        end
        else begin
            axi_w = axi_w_q.pop_front();    //axi4 guarantees data order
             if(!$test$plusargs("uncorr_skid_buffer_test")) check_axi_aw_w(axi_aw, axi_w);
        end

    endfunction : write_write_addr_chnl

    //----------------------------------------------------------------------- 
    // ACE Write Data Channel
    function void write_write_data_chnl(axi4_write_data_pkt_t axi_in);
        axi4_write_addr_pkt_t axi_aw;
        axi4_write_data_pkt_t axi_w;

        axi_w = new();
        axi_w.copy(axi_in);


        `uvm_info($sformatf("%m"), $sformatf("got axi: %s",axi_w.sprint_pkt()), UVM_LOW)

        if (axi_aw_q.size() == 0) begin
            axi_w_q.push_back(axi_w);
            `uvm_info($sformatf("%m"), $sformatf("w -> tmp queue"), UVM_MEDIUM)
        end
        else begin
            axi_aw = axi_aw_q.pop_front();    //axi4 guarantees data order
            if(!$test$plusargs("uncorr_skid_buffer_test")) check_axi_aw_w(axi_aw, axi_w);
        end

    endfunction : write_write_data_chnl

    //----------------------------------------------------------------------- 
    // ACE Write Resp Channel
    function void write_write_resp_chnl(axi4_write_resp_pkt_t axi_in);
        axi4_write_resp_pkt_t axi;

        axi = new();
        axi.copy(axi_in);


        if(!$test$plusargs("uncorr_skid_buffer_test")) checkBChnl(axi);

    endfunction : write_write_resp_chnl


   //----------------------------------------------------------------------- 
    // Sys event

   function void write_evt_port(event_in_t sys_event);
      if(sys_event == err) begin

                `uvm_info($sformatf("%m"),$psprintf("Received a sys_event_err on the event_interface."), UVM_DEBUG)
                ev_sys_event_err.trigger();
      end else if (sys_event == req) begin

           `uvm_info($sformatf("%m"),$psprintf("Received a sys_event req on the event_interface."), UVM_DEBUG)
            ev_sys_event_req.trigger();

      end 

   endfunction : write_evt_port





    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    // Update rd txn with AXI_read_addr_channel
    //------------------------------------------------------------------------------
    function checkArChnl(axi4_read_addr_pkt_t axi_in);
        axi4_read_addr_pkt_t axi;
        smi_unq_identifier_bit_t unq_id;
        dii_txn find_q[$];
        dii_txn txn;
        bit ok;
        int index_q[$];
        <%if (obj.DiiInfo[obj.Id].configuration) {%>
        apb_pkt_t apb_exp_pkt = new();
        <% } %>

        axi = new();
        axi.copy(axi_in);

        `uvm_info($sformatf("%m"), $sformatf("AXI2CMD_RTT_Q size = %0d", axi2cmd_rtt_q.size()), UVM_LOW)
        `uvm_info($sformatf("%m"), $sformatf("got axi: %s",axi.sprint_pkt()), UVM_LOW)


        //#CheckTime.DII.ar.Sequence
        unq_id = axi2cmd_rtt_q.pop_front();
        find_q = statemachine_q.txn_q.find with (
            (item.isOutstanding(eConcMsgCmdReq))
            && (item.smi_recd[eConcMsgCmdReq].smi_unq_identifier == unq_id)
        );

        if (find_q.size() == 0) begin
            `uvm_error($sformatf("%m"), $sformatf("axi matched %d txns: %p", find_q.size(), axi))
        end else if (find_q.size() > 1) begin
            `uvm_info($sformatf("%m"), $sformatf("ERROR: axi matched %d txns", find_q.size()), UVM_NONE)
            for (int i=0; i<find_q.size(); i++) begin
               `uvm_info($sformatf("%m"), $sformatf("TXN %d\n%p", i, find_q[i].smi_recd[eConcMsgCmdReq]), UVM_NONE)
            end
            `uvm_error($sformatf("%m"), $sformatf("axi matched %d txns: %p", find_q.size(), axi))
	end

        txn = find_q[0];
        `uvm_info($sformatf("%m"), $sformatf("matched CmdReq for AXI AR: %p",txn.smi_recd[eConcMsgCmdReq]), UVM_MEDIUM);
        `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%>_UID:%0p :AXI AR address msg got recently in scb : %s \n corresponds to the txn %0p",
                                             txn.txn_id, axi.sprint_pkt(), txn), UVM_MEDIUM);
        
        //construct and check expd pkts
        ok = txn.gen_exp_axi__ar(axi).do_compare_pkts(axi);
        if(!ok) `uvm_error($sformatf("%m"), $sformatf("axi mismatch: see ERROR above queue print"))

        if (txn.axi_recd[axi_ar] != 0) begin
	   `uvm_error($sformatf("%m"), $sformatf("AXI_RECD[axi_ar] is not 0, but %0d", txn.axi_recd[axi_ar]))
	end
        //add received to txn
        txn.axi_expd.delete(axi_ar);
        txn.axi_recd[axi_ar] = axi.t_pkt_seen_on_intf;
        txn.axi_read_addr_pkt = axi;


        `ifndef FSYS_COVER_ON
        cov.statemachine_q = statemachine_q;
        cov.collect_axi_read_addr_pkt(axi);
        cov.collect_dii_txn_ordering(txn);
        `endif

    <%if ( (obj.DiiInfo[obj.Id].configuration) && (obj.testBench == 'fsys') ) {%>
        // Commented as SYS_DII's APB will not be used
        if ( (txn.axi_read_addr_pkt.araddr >= ((<%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20) + (dut_ncore_unit_id<<12))) &&
             (txn.axi_read_addr_pkt.araddr  <  ((<%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20) + ((dut_ncore_unit_id+1)<<12))) ) begin
             // APB is active only when its own APB is accessed
           apb_exp_pkt.paddr   = axi.araddr & ((1 << <%=obj.DiiInfo[obj.Id].interfaces.apbInt.params.wAddr%>)-1);
           apb_exp_pkt.prdata  = 'h0;
           apb_exp_pkt.pwdata  = 'h0;
           apb_exp_pkt.psel    = 1'b1;
           apb_exp_pkt.pwrite  = 1'b0;
           apb_exp_pkt.pslverr = 1'b0;
           apb_q.push_back(apb_exp_pkt);
        end
    <% } %>
    endfunction : checkArChnl


    //------------------------------------------------------------------------------
    // Update rd txn with AXI_read_data_channel
    //------------------------------------------------------------------------------
    function checkRChnl(axi4_read_data_pkt_t axi_in);
        axi4_read_data_pkt_t axi;
        dii_txn find_q[$];
        dii_txn txn;
        bit ok;
        uvm_event ev_rresp = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_rresp");
        <%if (obj.DiiInfo[obj.Id].configuration) {%>
        apb_pkt_t apb_exp_pkt,m_apb_pkt;
        m_apb_pkt = new();
        <% } %>

        axi = new();
        axi.copy(axi_in);


        `uvm_info($sformatf("%m"), $sformatf("got axi: %s",axi.sprint_pkt()), UVM_LOW)

        //#CheckTime.DII.r.Sequence
        //Axi4 select the oldest ar with this arid
        find_q = statemachine_q.txn_q.find with (
            (item.axi_expd[axi_r]) 
            && (item.axi_recd[axi_ar]) 
        );
        find_q = find_q.find with (
            (item.axi_read_addr_pkt.arid == axi.rid)
        );

        txn = find_q[0];
        foreach(find_q[i]) begin
            if (find_q[i].axi_read_addr_pkt.t_pkt_seen_on_intf  < txn.axi_read_addr_pkt.t_pkt_seen_on_intf)
                txn = find_q[i];
        end

        if (find_q.size() > 1) begin
            foreach (find_q[i]) begin
               `uvm_info($sformatf("%m"), $sformatf("AXI R matching TXN[%0d] %p", i, find_q[i].smi_recd[eConcMsgCmdReq]), UVM_LOW)
            end
        end

        `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%>_UID:%0p :AXI R data msg got recently in scb : %s \n corresponds to the txn %0p",
                                             txn.txn_id, axi.sprint_pkt(), txn), UVM_MEDIUM);

        //construct and check expd pkts
        ok = txn.gen_exp_axi__r(axi).do_compare_pkts(axi);
        if(!ok) `uvm_error($sformatf("%m"), $sformatf("axi mismatch: see ERROR above queue print"))

        `uvm_info($sformatf("%m"), $sformatf("DEBUG: AXI_R matched txn: msg_id=%p msg_type=%08h addr=%p unq_id=%p",
					     txn.smi_recd[eConcMsgCmdReq].smi_msg_id, txn.smi_recd[eConcMsgCmdReq].smi_msg_type,
                                             txn.smi_recd[eConcMsgCmdReq].smi_addr, txn.smi_recd[eConcMsgCmdReq].smi_unq_identifier), UVM_DEBUG)
       
        if (txn.axi_recd[axi_r] != 0) begin
	   `uvm_error($sformatf("%m"), $sformatf("AXI_RECD[axi_r] is not 0, but %0d", txn.axi_recd[axi_r]))
	end

        //add received to txn
        txn.axi_expd.delete(axi_r);
        txn.axi_recd[axi_r] = axi.t_pkt_seen_on_intf;
        txn.axi_read_data_pkt = axi;
        
       `uvm_info($sformatf("%m"), $sformatf("AXI R matched %0d entries TXN:%p", find_q.size(), txn), UVM_HIGH)
        
        `ifndef FSYS_COVER_ON
        cov.collect_axi_read_data_pkt(axi);
        `endif
        //Pass araddr to CSR sequence when rresp = 2/3
        foreach(axi.rresp_per_beat[i])begin
          if(axi.rresp_per_beat[i] == 2 || axi.rresp_per_beat[i] == 3) begin
            ev_rresp.trigger(txn);
          end
        end

    <%if ( (obj.DiiInfo[obj.Id].configuration) && (obj.testBench == 'fsys') ) {%>
        // Commented as SYS_DII's APB will not be used
        if (
             (txn.axi_read_addr_pkt.araddr >= ((<%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20) + (dut_ncore_unit_id<<12))) &&
             (txn.axi_read_addr_pkt.araddr  <  ((<%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20) + ((dut_ncore_unit_id+1)<<12))) ) begin
           // APB is active only when its own APB is accessed
               `uvm_info($sformatf("%m"), $sformatf("ZIED DEBUG IN DII APB CHECK"), UVM_LOW)
           apb_exp_pkt = apb_q.pop_front();
           m_apb_pkt.paddr = (txn.axi_read_addr_pkt.araddr & ((1 << <%=obj.DiiInfo[obj.Id].interfaces.apbInt.params.wAddr%>)-1));
           if(
              (apb_exp_pkt.paddr   !== m_apb_pkt.paddr  ) ||
              (apb_exp_pkt.prdata  !== txn.axi_read_data_pkt.rdata[0]) ||
              ((apb_exp_pkt.pslverr) ? (txn.axi_read_data_pkt.rresp!=2'b01) : (txn.axi_read_data_pkt.rresp!=2'b00)) 
            ) begin
	         `uvm_error($sformatf("%m"), $sformatf("AXI_READ DATA error: \n Exp: Addr:%0h Rdata:%0h Rresp:%0h \n Act: Addr:%0h Rdata:%0h Rresp:%0h",apb_exp_pkt.paddr, apb_exp_pkt.prdata, (apb_exp_pkt.pslverr ? 2'b01 : 2'b00), txn.axi_read_addr_pkt.araddr, txn.axi_read_data_pkt.rdata[0], txn.axi_read_data_pkt.rresp) )
            end 
        end
    <% } %>
    endfunction : checkRChnl

    //------------------------------------------------------------------------------
    // Update wr txn with AXI_write_addr_channel, AXI_write_data_channel
    //------------------------------------------------------------------------------

    function void check_axi_aw_w(axi4_write_addr_pkt_t axi_aw_pkt, axi4_write_data_pkt_t axi_w_pkt);
        smi_unq_identifier_bit_t unq_id;
        dii_txn find_q[$];
        dii_txn txn;
        bit ok;
        int order_index;
        int index_q[$];
        int q_idx;
        bit txn_found;
       
        <%if (obj.DiiInfo[obj.Id].configuration) {%>
        apb_pkt_t apb_exp_pkt = new();
        <% } %>
       
        `uvm_info($sformatf("%m"), $sformatf("AXI2CMD_WTT_Q size = %0d", axi2cmd_wtt_q.size()), UVM_LOW);
        //correlate axi to txn
        //#CheckTime.DII.aw.Sequence
        unq_id = axi2cmd_wtt_q.pop_front(); //id of corresponding cmd from rtl
        `uvm_info($sformatf("%m"), $sformatf("Zied axi txn: unq_id = %p axi_aw:%p axi_w:%p",unq_id, axi_aw_pkt, axi_w_pkt), UVM_LOW)
        find_q = statemachine_q.txn_q.find with (
            item.smi_recd.exists(eConcMsgCmdReq)
            && (item.smi_recd[eConcMsgCmdReq].smi_unq_identifier == unq_id)
            && (item.smi_recd[eConcMsgDtwReq]
            && (item.axi_w_handled == 0))
        );

        if (find_q.size() >= 1) begin
           for (int i=0; i<find_q.size(); i++) begin
              `uvm_info(get_full_name(), $sformatf("WR: index=%0d of %0d, T=%t msg_type=%p unq_id=%p addr=%p TXN=%p with txn_id as %0h",
                                                   i, find_q.size(), find_q[i].smi_recd[eConcMsgCmdReq].t_smi_ndp_valid,
                                                   find_q[i].smi_recd[eConcMsgCmdReq].smi_msg_type,
                                                   find_q[i].smi_recd[eConcMsgCmdReq].smi_unq_identifier,
                                                   find_q[i].smi_recd[eConcMsgCmdReq].smi_addr, find_q[i], find_q[i].txn_id), UVM_MEDIUM)
           end
        end else begin
           for (int i=0; i<statemachine_q.txn_q.size(); i++) begin
              if (statemachine_q.txn_q[i].smi_recd.exists(eConcMsgCmdReq)) begin
                 `uvm_warning(get_full_name(), $sformatf("WR: index=%0d of %0d, T=%t msg_type=%p unq_id=%p addr=%p trans_addr=%p axi_addr=%p",
                                                         i, statemachine_q.txn_q.size(), statemachine_q.txn_q[i].smi_recd[eConcMsgCmdReq].t_smi_ndp_valid,
                                                         statemachine_q.txn_q[i].smi_recd[eConcMsgCmdReq].smi_msg_type,
                                                         statemachine_q.txn_q[i].smi_recd[eConcMsgCmdReq].smi_unq_identifier,
                                                         statemachine_q.txn_q[i].smi_recd[eConcMsgCmdReq].smi_addr,
                                                         statemachine_q.txn_q[i].axi4_addr_trans_addr(statemachine_q.txn_q[i].smi_recd[eConcMsgCmdReq].smi_addr), axi_aw_pkt.awaddr))
              end
           end
           `uvm_error(get_full_name(), $sformatf("AXI matched %0h txn: unq_id = %p axi_aw:%p axi_w:%p ", find_q.size(),unq_id, axi_aw_pkt, axi_w_pkt))
        end
        foreach (find_q[i]) begin
         `uvm_info(get_full_name(), $sformatf("Print debug before second find CmdReq=%p",find_q[i].smi_recd[eConcMsgCmdReq]), UVM_MEDIUM)
         `uvm_info(get_full_name(), $sformatf("Print debug before second find DtwReq=%p",find_q[i].smi_recd[eConcMsgDtwReq]), UVM_MEDIUM)
        end
        if (exmon_size == 0) begin
            find_q = find_q.find with (
               //posted wr => aw may correspond to >1 cmd having same unqid. (after dtwrsp, cmd no longer outstanding)
               // use ~~uniqueness of data payload as proxy to correlate dtw.
               ((xdata(item.smi_recd[eConcMsgCmdReq], item.smi_recd[eConcMsgDtwReq], axi_w_pkt.wdata,0) == axi_w_pkt.wdata) && (smi_es_t'(axi_aw_pkt.awlock) == item.smi_recd[eConcMsgCmdReq].smi_es) )
            );
        end
        else begin
            find_q = find_q.find with (
               //posted wr => aw may correspond to >1 cmd having same unqid. (after dtwrsp, cmd no longer outstanding)
               // use ~~uniqueness of data payload as proxy to correlate dtw.
               (xdata(item.smi_recd[eConcMsgCmdReq], item.smi_recd[eConcMsgDtwReq], axi_w_pkt.wdata,0) == axi_w_pkt.wdata)
            );
        end
        if (find_q.size() == 0) begin
           $stacktrace;
            `uvm_error(get_full_name(), $sformatf("axi matched %d txn: %p %p", find_q.size(), axi_aw_pkt, axi_w_pkt))
        end else if (find_q.size() > 1) begin
           // multiple entries are possible due to canceled requests or EWA
           for (int i=0; i<find_q.size(); i++) begin
              `uvm_warning($sformatf("%m"), $sformatf("WR: index=%0d of %0d, T=%t msg_type=%p unq_id=%p addr=%p trans_addr=%p axi_addr=%p TXN=%p",
                                                      i, find_q.size(), find_q[i].smi_recd[eConcMsgCmdReq].t_smi_ndp_valid,
                                                      find_q[i].smi_recd[eConcMsgCmdReq].smi_msg_type,
                                                      find_q[i].smi_recd[eConcMsgCmdReq].smi_unq_identifier,
                                                      find_q[i].smi_recd[eConcMsgCmdReq].smi_addr,
                                                      find_q[i].axi4_addr_trans_addr(find_q[i].smi_recd[eConcMsgCmdReq].smi_addr), axi_aw_pkt.awaddr, find_q[i]))
           end

           q_idx     = find_q.size();
           txn_found = 0;
           if (find_q.size() > 1) begin
             `uvm_warning($sformatf("%m"), $sformatf("axi matched %d TXNs", find_q.size()))
              for (int i=0; (i<find_q.size()) && (txn_found == 0); i++) begin
                 if (find_q[i].smi_recd[eConcMsgStrReq] && (find_q[i].axi_recd.size() == 0) &&
                     ((find_q[i].axi4_addr_trans_addr(find_q[i].smi_recd[eConcMsgCmdReq].smi_addr) & (~(CACHELINESIZE-1))) ==
                      (axi_aw_pkt.awaddr & (~(CACHELINESIZE-1)))) && (find_q[i].axi_w_handled == 0)) begin
                    `uvm_info($sformatf("%m"), $sformatf("DTW MSG_TYPE: %0h", find_q[i].smi_recd[eConcMsgDtwReq].smi_msg_type), UVM_HIGH)
                    if (find_q[i].smi_recd[eConcMsgStrReq]) begin
                       `uvm_info($sformatf("%m"), $sformatf("txn%0d. STRREQ:%p", i, find_q[i].smi_recd[eConcMsgStrReq]), UVM_HIGH)
                    end
                    `uvm_info($sformatf("%m"), $sformatf("TXN%0d found:%0d addr:%p", i, txn_found, axi_aw_pkt.awaddr), UVM_HIGH)
                    if (txn_found == 0) begin
                       q_idx     = i;
                       txn_found = 1;
                       find_q[i].axi_w_handled = 1;
                    end
                    `uvm_info($sformatf("%m"), $sformatf("TXN%0d found:%0d; index:%0d", i, txn_found, q_idx), UVM_HIGH)
                 end // if (find_q[i].smi_recd[eConcMsgStrReq] && (find_q[i].axi_recd.size() == 0) && (find_q[i].axi_w_handled == 0))
              end // for (int i=0; (i<find_q.size()) && (txn_found == 0); i++)
           end // if (find_q.size() > 1)
        end // if (find_q.size() > 1)
       
        if (q_idx < find_q.size()) begin
           txn = find_q[q_idx];
           `uvm_info($sformatf("%m"), $sformatf("matched txn_q[%0d]: %p with txn_id %0d and received the axi_packet at %0t time with order type as %0h", q_idx, txn, txn.txn_id, axi_aw_pkt.t_pkt_seen_on_intf, txn.smi_recd[eConcMsgCmdReq].smi_order ), UVM_MEDIUM)
           
          `uvm_info($sformatf("%m"), $sformatf("Print debug  third find CmdReq=%p", txn.smi_recd[eConcMsgCmdReq]), UVM_MEDIUM)
          `uvm_info($sformatf("%m"), $sformatf("Print debug  third find DtwReq=%p", txn.smi_recd[eConcMsgDtwReq]), UVM_MEDIUM)
        
          `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%>_UID:%0p :AXI Write packet got in scb is axi_aw_pkt: %s  and axi_w_pkt %s \n which corresponds to the txn %0p", txn.txn_id, axi_aw_pkt.sprint_pkt(), axi_w_pkt.sprint_pkt(), txn), UVM_MEDIUM);
                

           //construct and check expd 
           ok = txn.gen_exp_axi__aw(axi_aw_pkt).do_compare_pkts(axi_aw_pkt);
           ok = (ok && txn.gen_exp_axi__w(axi_w_pkt).do_compare_pkts(axi_w_pkt));
           if(!ok) `uvm_error($sformatf("%m"), $sformatf("axi mismatch: see ERROR above queue print"))

           if (txn.axi_recd[axi_aw] != 0) begin
	      `uvm_error($sformatf("%m"), $sformatf("AXI_RECD[axi_aw] is not 0, but %0d", txn.axi_recd[axi_aw]))
	   end
           if (txn.axi_recd[axi_w] != 0) begin
	      `uvm_error($sformatf("%m"), $sformatf("AXI_RECD[axi_w] is not 0, but %0d", txn.axi_recd[axi_w]))
           end

           //add to txn
           txn.axi_expd.delete(axi_aw);
           txn.axi_recd[axi_aw] = axi_aw_pkt.t_pkt_seen_on_intf;
           txn.axi_write_addr_pkt = axi_aw_pkt;
           //
           txn.axi_expd.delete(axi_w);
           txn.axi_recd[axi_w] = axi_w_pkt.t_pkt_seen_on_intf;
           txn.axi_write_data_pkt = axi_w_pkt;


           `ifndef FSYS_COVER_ON
           //coverage
           cov.statemachine_q = statemachine_q;
           cov.collect_axi_write_addr_pkt(axi_aw_pkt);
           cov.collect_axi_write_data_pkt(axi_w_pkt);
           cov.collect_dii_txn_ordering(txn);
           `endif
           <%if ( (obj.DiiInfo[obj.Id].configuration) && (obj.testBench == 'fsys') ) {%>
           // Commented as SYS_DII's APB will not be used
           if ( 
                (axi_aw_pkt.awaddr >= ((<%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20) + (dut_ncore_unit_id<<12))) &&
                (axi_aw_pkt.awaddr  < ((<%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20) + ((dut_ncore_unit_id+1)<<12))) ) begin
               // APB is active only when its own APB is accessed
               apb_exp_pkt         = new();
               apb_exp_pkt.paddr   = (axi_aw_pkt.awaddr & ((1<<(<%=obj.DiiInfo[obj.Id].interfaces.apbInt.params.wAddr%>)) - 1));
               apb_exp_pkt.prdata  = 'h0;
               apb_exp_pkt.pwdata  = (axi_w_pkt.wstrb[0] == 4'hf) ? axi_w_pkt.wdata[0] : 0;
               apb_exp_pkt.psel    = 1'b1;
               apb_exp_pkt.pwrite  = 1'b1;
               apb_exp_pkt.pslverr = 1'b0;
               apb_q.push_back(apb_exp_pkt);
           end
           <% } %>
        end else begin
          `uvm_error($sformatf("%m"), $sformatf("No pending transactions found in TXN"))
        end
    endfunction : check_axi_aw_w

            

    //------------------------------------------------------------------------------
    // Update wr txn with AXI_write_resp_channel
    //------------------------------------------------------------------------------
    function checkBChnl(axi4_write_resp_pkt_t axi_in);
        axi4_write_resp_pkt_t axi;
        dii_txn find_q[$];
        dii_txn txn;
        bit ok;
        uvm_event ev_bresp = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_bresp");
        <%if (obj.DiiInfo[obj.Id].configuration) {%>
        apb_pkt_t apb_exp_pkt,m_apb_pkt;
        m_apb_pkt = new();
        <% } %>

        axi = new();
        axi.copy(axi_in);

        
        `uvm_info($sformatf("%m"), $sformatf("got axi: %s",axi.sprint_pkt()), UVM_LOW)


        //#CheckTime.DII.b.Sequence
        //find oldest aw with same id which is waiting for axi rsp
        //not dependent on axi w.
        find_q = statemachine_q.txn_q.find with (
            (item.axi_expd[axi_b])
            && (item.axi_recd[axi_aw])
        );
        find_q = find_q.find with (
            (item.axi_write_addr_pkt.awid == axi.bid)
        );

        if (find_q.size() == 0)
            `uvm_error($sformatf("%m"), $sformatf("AT B CHANNEL: axi matched %d txn: %p ", find_q.size(), axi))

        //oldest aw
        txn = find_q[0];
        foreach (find_q[i])
            if (find_q[i].axi_write_addr_pkt.t_pkt_seen_on_intf < txn.axi_write_addr_pkt.t_pkt_seen_on_intf)
                txn = find_q[i] ;
        `uvm_info($sformatf("%m"), $sformatf("For B channel matched txn: %p with txn id as %0d and order is %0h",txn,txn.txn_id, txn.smi_recd[eConcMsgCmdReq].smi_order), UVM_MEDIUM)
                
        `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%>_UID:%0p :AXI Write B resp msg got recently in scb : %s \n corresponds to the txn %0p",
                                             txn.txn_id, axi.sprint_pkt(), txn), UVM_MEDIUM);      
        //construct and check expd pkts
        ok = txn.gen_exp_axi__b(axi).do_compare_pkts(axi);
        if(!ok) `uvm_error($sformatf("%m"), $sformatf("axi mismatch: see ERROR above queue print"))


        if (txn.axi_recd[axi_b] != 0) begin
	   `uvm_error($sformatf("%m"), $sformatf("AXI_RECD[axi_b] is not 0, but %0d", txn.axi_recd[axi_b]))
	end

        //add received to corresponding txn
        txn.axi_expd.delete(axi_b) ;
        txn.axi_recd[axi_b] = axi.t_pkt_seen_on_intf;
        txn.axi_write_resp_pkt = axi;
        //Pass awaddr to CSR sequence when bresp = 2/3
        if(axi.bresp == 2 || axi.bresp == 3) begin
          ev_bresp.trigger(txn);
        end
        
        

        `ifndef FSYS_COVER_ON
        cov.collect_axi_write_resp_pkt(axi);
        //retire txn iff complete
        // (axi b may be the last activity in txn)
        cov.statemachine_q = statemachine_q;
        cov.collect_time_before_RetireTxn(txn);
        `endif

       `uvm_info($sformatf("%m"), $sformatf("WRITE_AXI_B: cmd_msg_id=%2h smi_order= %0h smi_expd=%0d axi_expd=%0d and txn id is %0d",
					    txn.smi_recd[eConcMsgCmdReq].smi_msg_id, txn.smi_recd[eConcMsgCmdReq].smi_order, txn.smi_expd.size(), txn.axi_expd.size(), txn.txn_id), UVM_LOW)
        fork
	   scTryRetire(txn);
	join_none

    <%if (obj.DiiInfo[obj.Id].configuration) {%>
        if (apb_q.size() > 0) begin
           apb_exp_pkt = apb_q.pop_front();
           m_apb_pkt.paddr = (txn.axi_write_addr_pkt.awaddr & ((1 << <%=obj.DiiInfo[obj.Id].interfaces.apbInt.params.wAddr%>)-1));
           if(
              (apb_exp_pkt.paddr   !== m_apb_pkt.paddr ) ||
              (apb_exp_pkt.pwdata  !== (txn.axi_write_data_pkt.wstrb[0] == 'hf ? txn.axi_write_data_pkt.wdata[0] : 0)) ||
              (apb_exp_pkt.pwrite  !== 1'b1) ||
              (apb_exp_pkt.psel    !== 1'b1) ||
              ((apb_exp_pkt.pslverr) ? (txn.axi_write_resp_pkt.bresp!=2'b01) : (txn.axi_write_resp_pkt.bresp!=2'b00)) 
            ) begin
	         `uvm_error($sformatf("%m"), $sformatf("WRITE_AXI_B error: \n Exp: Addr:%0h Wdata:%0h Bresp:%0h \n Act: Addr:%0h Wdata:%0h Bresp:%0h",
                                                       apb_exp_pkt.paddr, apb_exp_pkt.pwdata, (apb_exp_pkt.pslverr ? 2'b01 : 2'b00), txn.axi_write_addr_pkt.awaddr,
                                                       txn.axi_write_data_pkt.wdata[0], txn.axi_write_resp_pkt.bresp) )
            end
        end else begin
//          Cannot really monitor APB input if the target is not to this AIU as this depends on CSR network implementation
//         `uvm_warning($sformatf("%m"), $sformatf("APB_addr:%0h not in expected queue", m_apb_pkt.paddr))                                              
        end
    <% } %>
    endfunction : checkBChnl

    task automatic scTryRetire(ref dii_txn txn);
      bit retired = 0;
       
       txn.s_retire.get(1);
       retired = statemachine_q.tryRetireTxn(txn, 1);

       if(retired) begin  //deleting knob of the retired txn
         dm_common_knob_list = common_knob_list::get_instance();
         `uvm_info("KNOB_DELETE",$sformatf("Going to attempt deleting %s_%s_%d", txn.get_full_name(), "k_32b_cmdset", txn.get_inst_id()),UVM_MEDIUM)
         if(dm_common_knob_list.m_list_of_knobs.exists($sformatf("%s_%s_%d", txn.get_full_name(), "k_32b_cmdset", txn.get_inst_id()))) begin
           dm_common_knob_list.m_list_of_knobs.delete($sformatf("%s_%s_%d", txn.get_full_name(), "k_32b_cmdset", txn.get_inst_id()));
         end
     <% if (obj.testBench == "dii") { %>
        if(overflow_buffer_test && unblock_if_after_delay != 1) begin
           if(txn.smi_recd[eConcMsgCmdReq].smi_msg_type inside {CMD_WR_NC_PTL, CMD_WR_NC_FULL} && txn.smi_recd[eConcMsgCmdReq].smi_order inside {SMI_ORDER_NONE, SMI_ORDER_WRITE, SMI_ORDER_REQUEST_WR_OBS}) begin //#Check.DII.Concerto.v3.7.BypassableWriteswithReads
             `uvm_info("TXN_CHECKER", $sformatf("Vyshak and Transaction of type %2h found and retired", txn.smi_recd[eConcMsgCmdReq].smi_msg_type), UVM_MEDIUM);
             `uvm_info("Vyshak", "Vyshak Unblocking dii0 native i/f", UVM_LOW);
             m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.stall_ar_chnl_till_en_ar_stall_deassrt = 0;
             m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.en_ar_stall = 0;
             m_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_vif.enable_r_stall  = 0;
           end
         end // overflow_buffer_test 
     <% } %>
      end 

       txn.s_retire.put(1);
    endtask : scTryRetire
   
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // look inside rtl to correlate axi2cmd.
    // queues popped in ax fns.
    
    function void write_axi2cmd_rtt(axi2cmd_t axi2cmd_obj);
        `uvm_info($sformatf("%m"), $sformatf("got RTT unq_id:%p", axi2cmd_obj.unq_id), UVM_LOW)
        axi2cmd_rtt_q.push_back(axi2cmd_obj.unq_id);
    endfunction : write_axi2cmd_rtt
    
    function void write_axi2cmd_wtt(axi2cmd_t axi2cmd_obj);
      int_queue find_q;
      `uvm_info($sformatf("%m"), $sformatf("got WTT unq_id:%p for addr = 0x%h", axi2cmd_obj.unq_id,axi2cmd_obj.cmd_addr), UVM_LOW)
      //#Check.DII.ExMon.ExFailDropped
      if (axi2cmd_obj.cmd_lock == 1) begin
         find_q = dropped_ex_cmd.find_first_index with (
            (item.smi_unq_identifier == axi2cmd_obj.unq_id && item.smi_addr == axi2cmd_obj.cmd_addr)
         );
      end
      // if uniq_id and cmd_addr correspond to dropped ex cmd => it should be dropped and cmd will be also removed form dropped cmd queue
      if (find_q.size() > 0) begin
      `uvm_info($sformatf("%m"), $sformatf("dropping unq_id:%p for addr = 0x%h cmd_req = %p", axi2cmd_obj.unq_id,axi2cmd_obj.cmd_addr,dropped_ex_cmd[find_q[0]]), UVM_MEDIUM)
         dropped_ex_cmd.delete(find_q[0]);

      end
      //storing uniq_id
      else axi2cmd_wtt_q.push_back(axi2cmd_obj.unq_id);
    endfunction : write_axi2cmd_wtt

    <%if (obj.DiiInfo[obj.Id].configuration) {%>
    function void write_apb_chnl(apb_pkt_t m_pkt);
       apb_pkt_t m_apb_pkt;
       apb_pkt_t apb_exp_pkt;
       string spkt;
       m_apb_pkt = new();
       m_apb_pkt.copy(m_pkt);
       `uvm_info($sformatf("%m"), $sformatf("DEBUG DII Got_ApbReqPkt: %s",m_apb_pkt.sprint_pkt() ),UVM_MEDIUM)

       if (apb_q.size() > 0) begin
          apb_exp_pkt =  apb_q.pop_front();
          // <%console.log(typeof(obj.testBench)); console.log(typeof("fsys")); %>
          if((apb_exp_pkt.paddr !== m_apb_pkt.paddr  ) ||
             (apb_exp_pkt.pwrite !== m_apb_pkt.pwrite) || 
             (apb_exp_pkt.psel !== m_apb_pkt.psel) || 
             (apb_exp_pkt.pwrite ? (apb_exp_pkt.pwdata !== m_apb_pkt.pwdata) : 0)
            ) begin
	         `uvm_error($sformatf("%m"), $sformatf("APB_WRITE error: \n Exp: PAddr:%0h PWdata:%0h PWrite:%0h Psel:%0h \n Act: PAddr:%0h PWdata:%0h PWrite:%0h Psel:%0h",apb_exp_pkt.paddr, apb_exp_pkt.pwdata, apb_exp_pkt.pwrite, apb_exp_pkt.psel, m_apb_pkt.paddr,(apb_exp_pkt.pwrite ? m_apb_pkt.pwdata : 0), m_apb_pkt.pwrite, m_apb_pkt.psel))
              end

            if(apb_exp_pkt.pwrite == 0) begin
               apb_exp_pkt.prdata = m_apb_pkt.prdata;
           end 
           apb_exp_pkt.pslverr= m_apb_pkt.pslverr;
           apb_q.push_front(apb_exp_pkt);
        end else begin // if (apb_q.size() > 0)
//          Cannot really monitor APB input if the target is not to this AIU as this depends on CSR network implementation
//           `uvm_warning($sformatf("%m"), $sformatf("APB_addr:%0h not in expected queue", m_apb_pkt.paddr))                                              
        end
    endfunction
    <% } %>
    //----------------------------------------------------------------------- 
    // Q Channel
    //----------------------------------------------------------------------- 
    function void write_q_chnl(q_chnl_seq_item m_pkt);
        q_chnl_seq_item m_packet;
        q_chnl_seq_item m_packet_tmp;
        dii_txn         m_scb_txn;
        m_packet = new();

        $cast(m_packet_tmp, m_pkt);
        m_packet.copy(m_packet_tmp);

        `uvm_info("Q_Channel_resp_chnl", $sformatf("Entered..."), UVM_HIGH)
        //If power_down request has been accepted, at that time no outstanding transaction should be there
        if(m_packet.QACCEPTn == 'b0 && m_packet.QREQn == 'b0 && m_packet.QACTIVE == 'b0) begin
          `uvm_info("Q_Channel_resp_chnl", $sformatf("Q_Channel : Checking WTT and RTT Queue should be empty when Q Channel Req receives Accept."), UVM_HIGH)
          //RTT Queue
          if (axi2cmd_rtt_q.size != 0) begin
            `uvm_error("<%=obj.BlockId%>:print_axi2cmd_rtt_q", $sformatf("RTT queue is not empty when dii asserted QACCEPTn"))
          end
          else begin
            `uvm_info("<%=obj.BlockId%>:print_axi2cmd_rtt_q", $sformatf("RTT queue is empty"), UVM_MEDIUM)
          end
          //WTT Queue
          if (axi2cmd_wtt_q.size != 0) begin
            `uvm_error("<%=obj.BlockId%>:print_axi2cmd_wtt_q", $sformatf("WTT queue is not empty when dii asserted QACCEPTn"))
          end
          else begin
            `uvm_info("<%=obj.BlockId%>:print_axi2cmd_wtt_q", $sformatf("WTT queue is empty"), UVM_MEDIUM)
          end
        end
     endfunction : write_q_chnl

     virtual function void update_resiliency_ce_cnt(const ref smi_seq_item m_item);
       <%  if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
         int tmp_dp_corr_error;
         string func_s = "update_resiliency_ce_cnt";

         `uvm_info({func_s}, $sformatf("time1 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
         res_smi_pkt_time_new = $realtime;
         if(res_smi_pkt_time_new != res_smi_pkt_time_old) begin
           // get error statistics
           if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
             res_smi_corr_err++;
             if(m_item.dp_corr_error_eb) begin
               res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
               res_mod_dp_corr_error = m_item.dp_corr_error_eb;
               `uvm_info({func_s}, $sformatf("(if/if)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
             end
             res_is_pre_err_pkt = 1'b1;
             `uvm_info({func_s}, $sformatf("new smi_pkt(if). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
           end else begin
             res_is_pre_err_pkt = 1'b0;
           end
           `uvm_info({func_s}, $sformatf("time2 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
         end else begin
           if(res_is_pre_err_pkt) begin
             if(m_item.dp_corr_error_eb) begin
               tmp_dp_corr_error = m_item.dp_corr_error_eb - this.res_mod_dp_corr_error;
               if(tmp_dp_corr_error < 0)
                 tmp_dp_corr_error = 1'b0;
               else
                 this.res_mod_dp_corr_error = this.res_mod_dp_corr_error + tmp_dp_corr_error;
               `uvm_info({func_s}, $sformatf("(else/if)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
               res_smi_corr_err = res_smi_corr_err + tmp_dp_corr_error;
             end
             `uvm_info({func_s}, $sformatf("new smi_pkt(else/if). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
           end else begin
             if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
               res_smi_corr_err++;
               if(m_item.dp_corr_error_eb) begin
                 res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
                 res_mod_dp_corr_error = m_item.dp_corr_error_eb;
                 `uvm_info({func_s}, $sformatf("(else/else)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
               end
               res_is_pre_err_pkt = 1'b1;
             end
             `uvm_info({func_s}, $sformatf("new smi_pkt(else/else). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
           end
           `uvm_info({func_s}, $sformatf("time3 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
         end
         res_smi_pkt_time_old = res_smi_pkt_time_new;
         `uvm_info({func_s}, $sformatf("time4 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
       <% } %>
     endfunction : update_resiliency_ce_cnt

endclass : dii_scoreboard


