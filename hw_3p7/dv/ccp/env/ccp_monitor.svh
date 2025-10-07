//-------------------------------------------------------------
//  CCP Monitor
//-------------------------------------------------------------

 class ccp_monitor extends uvm_component;

     `uvm_component_utils(ccp_monitor);

     virtual  <%=obj.BlockId + '_ccp_if'%> m_vif;
     bit      delay_export;
     //addr_trans_mgr            m_addr_mgr;
    uvm_analysis_port #(ccp_ctrl_pkt_t    )       ctrlstatus_ap;
    uvm_analysis_port #(ccp_ctrl_pkt_t    )       ctrlstatus_ap_p0;
    uvm_analysis_port #(ccp_filldata_pkt_t )      cachefilldata_ap;
    uvm_analysis_port #(ccp_filldata_pkt_t )      cachefilldata_before_done_ap;
    uvm_analysis_port #(ccp_fillctrl_pkt_t )      cachefillctrl_ap;
    uvm_analysis_port #(fill_addr_inflight_t )    cachefilldone_ap;
    uvm_analysis_port #(ccp_cachefill_seq_item )  cachefillmiss_ap;
    uvm_analysis_port #(ccp_evict_pkt_t   )       cacheevict_ap;
    uvm_analysis_port #(ccp_rd_rsp_pkt_t  )       cacherdrsp_ap;
    uvm_analysis_port #(ccp_rd_rsp_pkt_t  )       cacherdrsp_per_beat_ap;

    uvm_analysis_port #(ccp_sp_ctrl_pkt_t)        sp_ctrlstatus_ap;
    uvm_analysis_port #(ccp_sp_wr_pkt_t)          sp_input_ap;
    uvm_analysis_port #(ccp_sp_output_pkt_t)      sp_output_ap;
    //uvm_analysis_port #(ccp_ctrl_pkt_t    )     ctrlstatus_ap;
    //uvm_analysis_port #(ccp_ctrl_pkt_t    )     ctrlstatus_ap;

    uvm_analysis_port #(ccp_csr_maint_pkt_t  )    csr_maint_ap;
    uvm_analysis_port #(ccp_wr_data_pkt_t )       ctrlwr_ap;
    uvm_analysis_port #(cache_rtl_pkt)            cbi_req_ap;


    //----------------------------------------------------------------------- 
    // New
    //----------------------------------------------------------------------- 

    function new(string name = "ccp_monitor", uvm_component parent = null);
        super.new(name,parent);
	//m_addr_mgr = addr_trans_mgr::get_instance();  //added by Bhavya
    endfunction : new


    //----------------------------------------------------------------------- 
    // Build phase
    //----------------------------------------------------------------------- 
    
    function void build_phase(uvm_phase phase);
      ctrlstatus_ap                = new("ctrlstatus_ap",this);
      sp_ctrlstatus_ap             = new("sp_ctrlstatus_ap",this);
      sp_input_ap                  = new("sp_input_ap",this);
      sp_output_ap                 = new("sp_output_ap",this);
      ctrlstatus_ap_p0             = new("ctrlstatus_ap_p0",this);
      cachefilldata_ap             = new("cachefilldata_ap",this);
      cachefilldata_before_done_ap = new("cachefilldata_before_done_ap",this);
      cachefillctrl_ap             = new("cachefillctrl_ap",this);
      cachefilldone_ap             = new("cachefilldone_ap",this);
      cachefillmiss_ap             = new("cachefillmiss_ap",this);
      cacheevict_ap                = new("cacheevict_ap",this);
      cacherdrsp_ap                = new("cacherdrsp_ap",this);
      cacherdrsp_per_beat_ap       = new("cacherdrsp_per_beat_ap",this);
      csr_maint_ap                 = new("csr_maint_ap",this);
      ctrlwr_ap                    = new("ctrlwr_ap",this);
      cbi_req_ap                   = new("cbi_req_ap",this);
    endfunction : build_phase

    //----------------------------------------------------------------------- 
    // Connect phase
    //----------------------------------------------------------------------- 

    function void connect_phase(uvm_phase phase);
    endfunction : connect_phase

    //-----------------------------------------------------------------------
    // Run phase
    //----------------------------------------------------------------------- 

    task run_phase(uvm_phase phase);
       //`uvm_info("DCDEBUG","monitor_run_phase",UVM_NONE)
        wait(m_vif.rst_n == 1); 
        fork 
            monitor_ctrlstatus_loop();
            monitor_sp_ctrlstatus_loop();
            monitor_sp_input_loop();
            monitor_sp_output_loop();
            monitor_ctrlstatus_p0_loop();
<% if(obj.Block == "dmi") { %>
            monitor_ctrlstatus_p1_loop();
<% } %>
            monitor_cachefilldata_loop();
<%=(obj.usePartialFill) ? "monitor_cachefilldata_before_done_loop()" : ""%>;
            monitor_cachefillctrl_loop();
            monitor_cachefilldone_loop();
            monitor_cachefillmiss_loop();
            monitor_cacheevict_loop();
            monitor_cacherdrsp_loop();
            monitor_cacherdrsp_per_beat_loop();
            monitor_csr_maint_loop();
            monitor_ctrlwr_loop();
        join
    endtask : run_phase

    //-----------------------------------------------------------------------
    // Monitor ctrl wr data loop
    //----------------------------------------------------------------------- 

    task monitor_ctrlwr_loop;
        ccp_wr_data_pkt_t pkt;
        pkt = new();
       
        forever begin
            m_vif.collect_ctrlwr_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
              if (delay_export==1) begin
                  `uvm_info(get_full_name(), "ccp wr delay_export", UVM_HIGH)
                  #0;
              end
             ctrlwr_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_ctrlwr_loop


    //-----------------------------------------------------------------------
    // Monitor sp input data loop
    //----------------------------------------------------------------------- 

    task monitor_sp_input_loop;
        ccp_sp_wr_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_sp_wr_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
              if (delay_export==1) begin
                  `uvm_info(get_full_name(), "ccp wr delay_export", UVM_HIGH)
                  #0;
              end
             sp_input_ap.write(pkt);
            //`uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_sp_input_loop

    //-----------------------------------------------------------------------
    // Monitor sp output data loop
    //----------------------------------------------------------------------- 

    task monitor_sp_output_loop;
        ccp_sp_output_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_sp_output_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
              if (delay_export==1) begin
                  `uvm_info(get_full_name(), "ccp wr delay_export", UVM_HIGH)
                  #0;
              end
             sp_output_ap.write(pkt);
            //`uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_sp_output_loop

    //-----------------------------------------------------------------------
    // Monitor ctrlstatus data loop
    //----------------------------------------------------------------------- 

    task monitor_ctrlstatus_loop;
        ccp_ctrl_pkt_t pkt;
        cache_rtl_pkt cpkt;

        pkt = new();
        cpkt = new();
       //`uvm_info("DCDEBUG","monitor_ctrlstatus_loop",UVM_NONE)
       
        forever begin
            m_vif.collect_ctrlstatus_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
            // TODO: should there be a knob for #0 delay?
            #0;
            `uvm_info("temp: ccp_monitor", $psprintf("Got_CCPCtrlPkt: %s",pkt.sprint_pkt() ),UVM_HIGH)
            ctrlstatus_ap.write(pkt);

            //<% if(obj.testBench === "dmi") { %>
	    //	if (pkt.tagstateup && pkt.state == IX) begin
	    //	m_addr_mgr.addr_evicted_from_agent( <%=obj.DmiInfo[0].FUnitId%>  , {pkt.addr, pkt.security});
	    //	end

	    //	if (pkt.evictvld && pkt.alloc) begin
	    //	m_addr_mgr.addr_evicted_from_agent( <%=obj.DmiInfo[0].FUnitId%>,{pkt.evictaddr, pkt.evictsecurity});
	    //	end
	    // <%}%>

            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
            cpkt.addr              = pkt.addr;
            cpkt.acaddr            = pkt.addr;
            cpkt.acprot            = pkt.security;
            cpkt.isRead            = pkt.isRead || pkt.isRead_Wakeup;
            cpkt.isWrite           = pkt.isWrite || pkt.isWrite_Wakeup;
            if (cpkt.isRead) begin
                cpkt.cmd_type = <%=obj.BlockId + '_ccp_agent_pkg'%>::READ;
            end
            if (cpkt.isWrite) begin
                cpkt.cmd_type = <%=obj.BlockId + '_ccp_agent_pkg'%>::WRITE;
            end
            if (pkt.isSnoop) begin
                cpkt.cmd_type = <%=obj.BlockId + '_ccp_agent_pkg'%>::SNOOP;
            end
            cpkt.ctt_match         = 0;
            cpkt.utt_match         = 0;
            cpkt.read_hit          = pkt.read_hit || pkt.snoop_hit;
            cpkt.write_hit         = pkt.write_hit;
            cpkt.write_hit_upgrade = pkt.write_hit_upgrade;

            //0-read, 1-snoop, 2-evict, 3-read_fill, 4-write, 5-write_fill
            //if(pkt.rd_data == 1 && !pkt.wr_data) begin
            //    cpkt.cmd_type     = 0;
            //    if(pkt.state != IX && pkt.rd_data == 1 && !pkt.wr_data) begin
            //        cpkt.read_hit = 'b1;
            //    end else begin
            //        cpkt.read_hit = 'b0;
            //    end
            //end
            //if(!pkt.wr_data  && pkt.wr_data == 1) begin
            //    cpkt.cmd_type     = 4;
            //    if(pkt.state != IX && !pkt.wr_data  && pkt.wr_data == 1) begin
            //        cpkt.write_hit = 'b1;
            //    end else begin
            //        cpkt.write_hit = 'b0;
            //    end
            //end
            `uvm_info(get_full_name(), cpkt.sprint_pkt(), UVM_HIGH);

            if (!pkt.cancel && !pkt.nack && 
                (cpkt.isRead ||
                 cpkt.isWrite ||
                 pkt.isSnoop)
            )  begin
                cbi_req_ap.write(cpkt);
            end
        end
    endtask : monitor_ctrlstatus_loop
    //-----------------------------------------------------------------------
    // Monitor ctrlstatus data loop to capture addr in p0
    //----------------------------------------------------------------------- 

    task monitor_ctrlstatus_p0_loop;
        ccp_ctrl_pkt_t pkt;

        pkt = new();

        forever begin
            m_vif.collect_ctrlstatus_p0_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end

            ctrlstatus_ap_p0.write(pkt);

            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_ctrlstatus_p0_loop
    //-----------------------------------------------------------------------
    // Monitor ctrlstatus data loop to capture addr in p1
    //----------------------------------------------------------------------- 

<% if(obj.Block == "dmi") { %>
    task monitor_ctrlstatus_p1_loop;
        ccp_ctrl_pkt_t pkt;

        pkt = new();

        forever begin
            m_vif.collect_ctrlstatus_p1_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end

            ctrlstatus_ap.write(pkt);

            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_ctrlstatus_p1_loop
<% } %>
    //-----------------------------------------------------------------------
    // Monitor cache fill data loop
    //----------------------------------------------------------------------- 

    task monitor_cachefilldata_loop;
        ccp_filldata_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_cachefilldata_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
              if (delay_export==1) begin
                  `uvm_info(get_full_name(), "ccp wr delay_export", UVM_HIGH)
                  #0;
              end
             cachefilldata_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_cachefilldata_loop

    //-----------------------------------------------------------------------
    // Monitor cache fill data before fill_done loop
    //----------------------------------------------------------------------- 

    task monitor_cachefilldata_before_done_loop;
        ccp_filldata_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_cachefilldata_before_done_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
              if (delay_export==1) begin
                  `uvm_info(get_full_name(), "ccp wr delay_export", UVM_HIGH)
                  #0;
              end
             cachefilldata_before_done_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_cachefilldata_before_done_loop

    //-----------------------------------------------------------------------
    // Monitor cache fill ctrl loop
    //----------------------------------------------------------------------- 

    task monitor_cachefillctrl_loop;
        ccp_fillctrl_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_cachefillctrl_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
              if (delay_export==1) begin
                  `uvm_info(get_full_name(), "ccp wr delay_export", UVM_HIGH)
                  #0;
              end
             cachefillctrl_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_cachefillctrl_loop
    //-----------------------------------------------------------------------
    // Monitor cache fill done loop
    //----------------------------------------------------------------------- 

    task monitor_cachefilldone_loop;
        fill_addr_inflight_t pkt;
      //  pkt = new();

        forever begin
            m_vif.collect_filldone_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
             cachefilldone_ap.write(pkt);
            //`uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_cachefilldone_loop

    //-----------------------------------------------------------------------
    // Monitor ctrlfillmiss data loop
    //----------------------------------------------------------------------- 

    task monitor_cachefillmiss_loop;
        ccp_cachefill_seq_item pkt;
        pkt = new();

        forever begin
            m_vif.collect_cachefillmiss_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
             cachefillmiss_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.fillctrl_pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_cachefillmiss_loop
    //-----------------------------------------------------------------------
    // Monitor cache evict loop
    //----------------------------------------------------------------------- 

    task monitor_cacheevict_loop;
        ccp_evict_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_cacheevict_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
             cacheevict_ap.write(pkt);
	     `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_cacheevict_loop
    //-----------------------------------------------------------------------
    // Monitor cache rdrsp loop
    //----------------------------------------------------------------------- 

    task monitor_cacherdrsp_loop;
        ccp_rd_rsp_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_cacherdrsp_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
             cacherdrsp_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_cacherdrsp_loop

    //-----------------------------------------------------------------------
    // Monitor cache rdrsp loop
    //----------------------------------------------------------------------- 

    task monitor_cacherdrsp_per_beat_loop;
        ccp_rd_rsp_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_cacherdrsp_per_beat_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
             cacherdrsp_per_beat_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_cacherdrsp_per_beat_loop

    //-----------------------------------------------------------------------
    // Monitor sp_ctrl loop
    //----------------------------------------------------------------------- 
    task monitor_sp_ctrlstatus_loop;
        ccp_sp_ctrl_pkt_t pkt;

        pkt = new();

        forever begin
            m_vif.collect_sp_ctrlstatus_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
            // TODO: should there be a knob for #0 delay?
            #0;

            sp_ctrlstatus_ap.write(pkt);
        end
    endtask : monitor_sp_ctrlstatus_loop

    //-----------------------------------------------------------------------
    // Monitor csr_maint loop
    //----------------------------------------------------------------------- 

    task monitor_csr_maint_loop;
        ccp_csr_maint_pkt_t pkt;
        pkt = new();

        forever begin
            m_vif.collect_csr_maint_pkt(pkt);
            if (m_vif.rst_n == 0) begin
                wait(m_vif.rst_n == 1);
                continue;
            end
             csr_maint_ap.write(pkt);
            `uvm_info(get_full_name(), pkt.sprint_pkt(), UVM_HIGH);
        end
    endtask : monitor_csr_maint_loop

 endclass:ccp_monitor
     
