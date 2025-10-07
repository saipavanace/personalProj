   //////////////////////////////////////////////////////////////////////////////
  // dce_probe_monitor
  //////////////////////////////////////////////////////////////////////////////
  class dce_probe_monitor extends uvm_monitor;

    `uvm_component_param_utils(dce_probe_monitor);

    //plusarg properties
    uvm_cmdline_processor clp; //= uvm_cmdline_processor::get_inst();
    bit m_delay_export;
    virtual <%=obj.BlockId%>_probe_if m_vif;

    uvm_analysis_port #(dm_seq_item) dm_ap;
    uvm_analysis_port #(bit [WATTVEC-1:0]) tm_ap;
    uvm_analysis_port #(sb_cmdrsp_s) sb_cmdrsp_ap;
    uvm_analysis_port #(smi_ncore_unit_id_bit_t) sb_syscorsp_ap;
    uvm_analysis_port #(probe_cmdreq_s) conc_mux_cmdreq_ap;
    uvm_analysis_port #(probe_cmdreq_s) arb_cmdreq_ap;
    uvm_analysis_port #(cycle_tracker_s) cycle_tracker_ap;
    uvm_analysis_port #(event_in_t) evt_ap;

    function new(string name = "dce_probe_monitor", uvm_component parent = null);
          super.new(name, parent);
          clp = uvm_cmdline_processor::get_inst();
    endfunction : new

    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task grab_dm_updstatus(); 
    extern task grab_dm_cohreq(); 
    extern task grab_dm_updreq(); 
    extern task grab_dm_lkprsp(); 
    extern task grab_dm_cmtreq(); 
    extern task grab_dm_rtyrsp(); 
    extern task grab_dm_recrsp(); 
    extern task grab_tm_attvec(); 
    extern task grab_sb_cmdrsp(); 
    extern task grab_sb_syscorsp(); 
    extern task grab_conc_mux_outputs(); 
    extern task grab_skid_arb_inputs(); 
    extern task grab_cycle_counter();
    extern task grab_sys_event();
    extern function int vec_to_id(bit [WATTVEC - 1 : 0] attvec);

  endclass: dce_probe_monitor


function void dce_probe_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    dm_ap               = new("dm_ap", this);
    tm_ap               = new("tm_ap", this);
    sb_cmdrsp_ap        = new("sb_cmdrsp_ap", this);
    sb_syscorsp_ap      = new("sb_syscorsp_ap", this);
    conc_mux_cmdreq_ap  = new("conc_mux_cmdreq_ap", this);
    arb_cmdreq_ap   = new("arb_cmdreq_ap", this);
    cycle_tracker_ap    = new("ct_ap", this);
    evt_ap          = new("evt_ap", this);

endfunction : build_phase

//*****************************************************
task dce_probe_monitor::run_phase(uvm_phase phase);
    fork
        grab_dm_cohreq(); 
        grab_dm_updreq(); 
        //CONC-15585: grab_dm_updstatus(); 
        grab_dm_lkprsp(); 
        grab_dm_cmtreq(); 
        grab_dm_rtyrsp(); 
        grab_dm_recrsp(); 
        grab_tm_attvec(); 
        grab_sb_cmdrsp(); 
        grab_sb_syscorsp(); 
        grab_conc_mux_outputs(); 
        grab_skid_arb_inputs(); 
        grab_cycle_counter();
    grab_sys_event();
    join_none
endtask: run_phase

//*****************************************************
task dce_probe_monitor::grab_cycle_counter();
    cycle_tracker_s cycle_tracker;
    forever begin
        @(m_vif.monitor_cb);
        cycle_tracker.m_time         = $time;
        cycle_tracker.m_cycle_count  = m_vif.get_cycle_count();
        cycle_tracker_ap.write(cycle_tracker);
    end

endtask: grab_cycle_counter
//*****************************************************
task dce_probe_monitor::grab_dm_cohreq();
    dm_seq_item coh_req_temp, coh_req_final;
    dm_seq_item coh_reqq[$];  
    //Chirag idea: Use mailbox instead of queue: mailbox #(dm_seq_item) mb_coh_reqq = new;

    bit grab_txn;
    event e_p1;
    <% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
    event e_p0plus;
    <% } %>

    fork
      begin //thread p0
        forever begin
            @(m_vif.monitor_cb);
            if (grab_txn == 1) begin
                grab_txn = 0;
                <% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
                ->e_p0plus;
                <%} else { %>
                ->e_p1;
                <% } %>
            end
            if (m_vif.monitor_cb.cmd_req_vld && m_vif.monitor_cb.cmd_req_rdy) begin
                coh_req_temp = new("cohreq");
                coh_req_temp.m_addr        = m_vif.monitor_cb.cmd_req_addr;
                coh_req_temp.m_ns          = m_vif.monitor_cb.cmd_req_ns;
                coh_req_temp.m_type        = eMsgCMD'(m_vif.monitor_cb.cmd_req_type);
                coh_req_temp.m_iid         = m_vif.monitor_cb.cmd_req_iid;
                coh_req_temp.m_sid         = m_vif.monitor_cb.cmd_req_sid;
                coh_req_temp.m_wakeup      = m_vif.monitor_cb.cmd_req_wakeup;
                coh_req_temp.m_attid       = vec_to_id(m_vif.monitor_cb.cmd_req_att_vec);
                coh_req_temp.m_time        = $time;
        coh_req_temp.m_msg_id      = m_vif.monitor_cb.cmd_req_msg_id;
                coh_req_temp.m_cycle_count = m_vif.get_cycle_count();
                coh_reqq.push_back(coh_req_temp);
                //Chirag idea: mb_coh_reqq.put(coh_req_temp);
                //$display("%t Pushed cohreq txn into q", $time);
                grab_txn = 1;
            end 
        end
      end

      <% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
      begin //thread p0plus
        forever begin
          @e_p0plus;
          fork
          begin
            @(m_vif.monitor_cb);
            ->e_p1;
          end
          join_none
        end
      end
      <% } %>

      begin//thread p1
        forever begin
            @e_p1;
            //$display("%t thread 2 forked", $time); 
            if (coh_reqq.size() != 0) begin
                //$display("%t Have to pull out cohreq txn from q", $time); 
                coh_req_final = new("cohreq");
                coh_req_final = coh_reqq.pop_front();
                //Chirag idea: mb_coh_reqq.get(coh_req_final);
                coh_req_final.m_access_type = DM_CMD_REQ;
                coh_req_final.m_filter_num  = m_vif.monitor_cb.cmd_req1_filter_num;
                coh_req_final.m_busy_vec    = m_vif.monitor_cb.cmd_req1_busy_vec;
                coh_req_final.m_alloc       = m_vif.monitor_cb.cmd_req1_alloc;
                coh_req_final.m_cancel      = m_vif.monitor_cb.cmd_req1_cancel;
		 //`uvm_info(get_name(), $psprintf("%t Put the dm_access pkt into port: %p", $time, coh_req_final.convert2string()), UVM_LOW);
                dm_ap.write(coh_req_final);
            end
         end
      end

    join_none

endtask: grab_dm_cohreq

//*****************************************************
task dce_probe_monitor::grab_dm_updreq();
    dm_seq_item upd_req_temp, upd_req_final;
    dm_seq_item upd_reqq[$];  
    dm_seq_item upd_req_st_q[$];  
    dm_seq_item upd_req_st_final;  

    bit grab_txn;
    <% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
    event e_p0plus;
    <% } %>

    event e_p1;
    event e_p2;

    fork
        begin  //thread1
            forever begin
                @(m_vif.monitor_cb);
                //if (grab_txn == 1) begin //CONC-16312, CONC-16170, monitor upd_req_status_valid to capture upd_req_status
                //    grab_txn = 0;
                //    <% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
                //    ->e_p0plus;
                //    <%} else { %>
                //    ->e_p1;
                //    <% } %>
                //end
                if (m_vif.monitor_cb.upd_req_vld && m_vif.monitor_cb.upd_req_rdy) begin
                    upd_req_temp = new("updreq");
                    upd_req_temp.m_access_type = DM_UPD_REQ;
                    upd_req_temp.m_addr        = m_vif.monitor_cb.upd_req_addr;
                    upd_req_temp.m_ns          = m_vif.monitor_cb.upd_req_ns;
                    upd_req_temp.m_iid         = m_vif.monitor_cb.upd_req_iid;
                    upd_req_temp.m_time        = $time;
                    upd_req_temp.m_cycle_count = m_vif.get_cycle_count();
                    upd_reqq.push_back(upd_req_temp);
                    grab_txn = 1;
                end
            end// forever
        end //thread1

        //CONC-14874::CONC-15584
        //<% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
        //begin //thread p0plus
        //  forever begin
        //    @e_p0plus;
        //    fork
        //    begin
        //      @(m_vif.monitor_cb);
        //      ->e_p1;
        //    end
        //    join_none
        //  end
        //end
        //<% } %>
//
        //    
        //begin//thread2
        //    forever begin
        //        @e_p1;
        //    //$display("%t thread 2 forked", $time); 
        //        if (upd_reqq.size() != 0) begin
        //        //$display("%t Have to pull out cohreq txn from q", $time); 
        //            upd_req_final = new("cohreq");
        //            upd_req_final = upd_reqq.pop_front();
        //            upd_req_final.m_access_type = DM_UPD_REQ;
        //            //CONC-15663: cmd_req1_busy_vec is nothing to do with Update interface
        //            //upd_req_final.m_busy_vec    = m_vif.monitor_cb.cmd_req1_busy_vec;
        //            //`uvm_info(get_name(), $psprintf("%t Put the dm_access pkt into port: %p", $time, upd_req_final.convert2string()), UVM_LOW);
        //            if (m_delay_export) begin
        //                #0;
        //            end
        //            upd_req_st_q.push_back(upd_req_final);
        //            dm_ap.write(upd_req_final);
        //            fork
        //            begin
        //              @(m_vif.monitor_cb);
        //              ->e_p2;
        //            end
        //            join_none
        //        end//if 
        //    end //forever
        //end //thread2
//
        ////CONC-15585
        begin
          forever
          begin
            //CONC-16312, CONC-16170, monitor upd_req_status_valid to capture upd_req_status
            //@e_p2
            @(m_vif.monitor_cb);
            if (m_vif.monitor_cb.upd_req_status_vld) begin
                if (upd_reqq.size()>0) begin
                    upd_req_st_final 			= new("");
                    upd_req_st_final 			= upd_reqq.pop_front();
                    upd_req_st_final.m_access_type 	= DM_UPD_REQ;
                    upd_req_st_final.m_time        	= $time;
                    upd_req_st_final.m_status_cycle_count 	= m_vif.get_cycle_count();
                    upd_req_st_final.m_status      	= upd_status_t'(m_vif.monitor_cb.upd_req_status);
                    if (m_delay_export) begin
                        #0;
                    end
                    dm_ap.write(upd_req_st_final);
                end else begin
                    `uvm_error(get_name(), $psprintf("upd_reqq is empty when upd_req_status_vld is set"));
                end
            end
            //`uvm_info(get_name(), $sformatf("Put the dm_access_pkt into port: %p", upd_req_status.convert2string()), UVM_LOW);
          end
        end

    join_none
endtask: grab_dm_updreq

//*****************************************************
task dce_probe_monitor::grab_dm_updstatus();
    dm_seq_item upd_req_status;

    forever begin
        @(m_vif.monitor_cb);
        if (upd_status_t'(m_vif.monitor_cb.upd_req_status) inside {UPD_FAIL, UPD_COMP}) begin
            upd_req_status = new("");
            upd_req_status.m_access_type = DM_UPD_REQ;
            upd_req_status.m_time        = $time;
            upd_req_status.m_cycle_count = m_vif.get_cycle_count();
            upd_req_status.m_status      = upd_status_t'(m_vif.monitor_cb.upd_req_status);
            if (m_delay_export) begin
                #0;
            end
            dm_ap.write(upd_req_status);
            //`uvm_info(get_name(), $sformatf("Put the dm_access_pkt into port: %p", upd_req_status.convert2string()), UVM_LOW);
        end
    end
endtask: grab_dm_updstatus

//*****************************************************
task dce_probe_monitor::grab_dm_lkprsp();
    dm_seq_item lkp_rsp;

    forever begin
        @(m_vif.monitor_cb);
        if (m_vif.monitor_cb.cmd_rsp_vld && m_vif.monitor_cb.cmd_rsp_rdy) begin
            lkp_rsp = new("lkprsp");
            lkp_rsp.m_access_type = DM_LKP_RSP;
            lkp_rsp.m_attid           = vec_to_id(m_vif.monitor_cb.cmd_rsp_att_vec);
            lkp_rsp.m_owner_val       = m_vif.monitor_cb.cmd_rsp_owner_val;
            lkp_rsp.m_owner_num       = m_vif.monitor_cb.cmd_rsp_owner_num;
            lkp_rsp.m_sharer_vec      = m_vif.monitor_cb.cmd_rsp_sharer_vec;
            lkp_rsp.m_way_vec_or_mask = m_vif.monitor_cb.cmd_rsp_way_vec;
            //lkp_rsp.m_vhit            = m_vif.monitor_cb.cmd_rsp_vhit;//CONC-5362
            lkp_rsp.m_wr_required     = m_vif.monitor_cb.cmd_rsp_wr_required;
            lkp_rsp.m_rtl_vbhit_sfvec = m_vif.monitor_cb.cmd_rsp_vbhit_sfvec;
            lkp_rsp.m_error           = m_vif.monitor_cb.cmd_rsp_error;
            lkp_rsp.m_time            = $time;
            lkp_rsp.m_cycle_count     = m_vif.get_cycle_count();
            if (m_delay_export) begin
                #0;
            end
            dm_ap.write(lkp_rsp);
               //`uvm_info(get_name(), $sformatf("Put the dm_access_pkt into port: %p", lkp_rsp.convert2string()), UVM_LOW);
        end
    end
endtask: grab_dm_lkprsp

//*****************************************************
task dce_probe_monitor::grab_dm_cmtreq();

    dm_seq_item cmt_req;
    forever begin
        @(m_vif.monitor_cb);
        if (m_vif.monitor_cb.write_vld && m_vif.monitor_cb.write_rdy) begin
            cmt_req = new("cmtreq");
            cmt_req.m_access_type = DM_CMT_REQ;
            cmt_req.m_addr        = m_vif.monitor_cb.write_addr;
            cmt_req.m_ns          = m_vif.monitor_cb.write_ns;
            cmt_req.m_way_vec_or_mask = m_vif.monitor_cb.write_way_vec;
            cmt_req.m_owner_val   = m_vif.monitor_cb.write_owner_val;
            cmt_req.m_owner_num   = m_vif.monitor_cb.write_owner_num;
            cmt_req.m_sharer_vec  = m_vif.monitor_cb.write_sharer_vec;
            cmt_req.m_change_vec  = m_vif.monitor_cb.write_change_vec;
            cmt_req.m_time        = $time;
            cmt_req.m_cycle_count = m_vif.get_cycle_count();
            if (m_delay_export) begin
                #0;
            end
            dm_ap.write(cmt_req);
           //`uvm_info(get_name(), $sformatf("Put the cmt_req_pkt into port: %p", cmt_req.convert2string()), UVM_HIGH);
        end
    end
endtask: grab_dm_cmtreq

//*****************************************************
task dce_probe_monitor::grab_dm_rtyrsp();

    dm_seq_item rty_rsp;
    forever begin
        @(m_vif.monitor_cb);
        if (m_vif.monitor_cb.retry_vld && m_vif.monitor_cb.retry_rdy) begin
            rty_rsp = new("rtyrsp");
            rty_rsp.m_access_type = DM_RTY_RSP;
            rty_rsp.m_attid           = vec_to_id(m_vif.monitor_cb.retry_att_vec);
            rty_rsp.m_way_vec_or_mask = m_vif.monitor_cb.retry_way_mask;
            rty_rsp.m_filter_num      = vec_to_id(m_vif.monitor_cb.retry_filter_vec);
            rty_rsp.m_time            = $time;
            rty_rsp.m_cycle_count     = m_vif.get_cycle_count();
            if (m_delay_export) begin
                #0;
            end
            dm_ap.write(rty_rsp);
           //`uvm_info(get_name(), $sformatf("Put the rty_req_pkt into port: %p", rty_req.convert2string()), UVM_HIGH);
        end
    end
endtask: grab_dm_rtyrsp

//*****************************************************
task dce_probe_monitor::grab_sb_cmdrsp();

    sb_cmdrsp_s sb_cmdrsp;
    forever begin
        @(m_vif.monitor_cb);
        if (m_vif.monitor_cb.sb_cmdrsp_vld && m_vif.monitor_cb.sb_cmdrsp_rdy) begin
            //sb_cmdrsp = new("sb_cmdrsp");
            sb_cmdrsp.tgtid           = m_vif.monitor_cb.sb_cmdrsp_tgtid;
            sb_cmdrsp.rmsgid          = m_vif.monitor_cb.sb_cmdrsp_rmsgid;
            sb_cmdrsp.starv_mode      = m_vif.monitor_cb.sb_starv_mode;
            sb_cmdrsp.m_time          = $time;
            sb_cmdrsp.m_cycle_count   = m_vif.get_cycle_count();
            if (m_delay_export) begin
                #0;
            end

            sb_cmdrsp_ap.write(sb_cmdrsp);
            //`uvm_info(get_name(), $sformatf("Put the sb_cmdrsp_pkt into port: %p", sb_cmdrsp), UVM_LOW);
        end
    end
endtask: grab_sb_cmdrsp
//*****************************************************
task dce_probe_monitor::grab_sb_syscorsp();
    smi_ncore_unit_id_bit_t target_id;
    forever begin
            @(m_vif.monitor_cb);
            if (m_vif.monitor_cb.sb_sysrsp_vld && m_vif.monitor_cb.sb_sysrsp_rdy) begin
            target_id = m_vif.monitor_cb.sb_sysrsp_tgtid[WSMITGTID-1:WSMINCOREPORTID];
                //@(m_vif.monitor_cb);
            sb_syscorsp_ap.write(target_id);    
        end
    end
endtask: grab_sb_syscorsp

//*****************************************************
task dce_probe_monitor::grab_conc_mux_outputs();

    probe_cmdreq_s conc_mux_cmdreq;
    forever begin
        @(m_vif.monitor_cb);
        if (m_vif.monitor_cb.cmux_cmdreq_vld && m_vif.monitor_cb.cmux_cmdreq_rdy) begin
            conc_mux_cmdreq.addr        = m_vif.monitor_cb.cmux_cmdreq_addr;
            conc_mux_cmdreq.ns          = m_vif.monitor_cb.cmux_cmdreq_ns;
            conc_mux_cmdreq.iid         = m_vif.monitor_cb.cmux_cmdreq_iid;
            conc_mux_cmdreq.cm_type     = m_vif.monitor_cb.cmux_cmdreq_cm_type;
            conc_mux_cmdreq.msg_id      = m_vif.monitor_cb.cmux_cmdreq_msg_id;
            conc_mux_cmdreq.m_time      = $time;
            conc_mux_cmdreq.cycle_count = m_vif.get_cycle_count();
            if (m_delay_export) begin
                #0;
            end

            conc_mux_cmdreq_ap.write(conc_mux_cmdreq);
            //`uvm_info(get_name(), $sformatf("Put the conc_mux_cmdreq_pkt into port: %p", conc_mux_cmdreq), UVM_LOW);
        end
    end
endtask: grab_conc_mux_outputs

//*****************************************************
task dce_probe_monitor::grab_skid_arb_inputs();

    probe_cmdreq_s arb_cmdreq;
    forever begin
        @(m_vif.monitor_cb);
        if (m_vif.monitor_cb.arb_cmdreq_vld && m_vif.monitor_cb.arb_cmdreq_rdy) begin
            arb_cmdreq.addr     = m_vif.monitor_cb.arb_cmdreq_addr;
            arb_cmdreq.ns       = m_vif.monitor_cb.arb_cmdreq_ns;
            arb_cmdreq.iid      = m_vif.monitor_cb.arb_cmdreq_iid;
            arb_cmdreq.cm_type  = m_vif.monitor_cb.arb_cmdreq_cm_type;
            arb_cmdreq.msg_id   = m_vif.monitor_cb.arb_cmdreq_msg_id;
            arb_cmdreq.m_time   = $time;
            arb_cmdreq.cycle_count = m_vif.get_cycle_count();
            if (m_delay_export) begin
                #0;
            end

            arb_cmdreq_ap.write(arb_cmdreq);
           //`uvm_info(get_name(), $sformatf("Put the arb_cmdreq_pkt into port: %p", arb_cmdreq), UVM_LOW);
        end
    end
endtask: grab_skid_arb_inputs

//*****************************************************
task dce_probe_monitor::grab_dm_recrsp();

    dm_seq_item rec_rsp;
    forever begin
        @(m_vif.monitor_cb);
        if (m_vif.monitor_cb.recall_vld && m_vif.monitor_cb.recall_rdy) begin
            rec_rsp = new("recrsp");
            rec_rsp.m_access_type = DM_REC_REQ;
            rec_rsp.m_addr        = m_vif.monitor_cb.recall_addr;
            rec_rsp.m_ns          = m_vif.monitor_cb.recall_ns;
            rec_rsp.m_owner_val   = m_vif.monitor_cb.recall_owner_val;
            rec_rsp.m_owner_num   = m_vif.monitor_cb.recall_owner_num;
            rec_rsp.m_sharer_vec  = m_vif.monitor_cb.recall_sharer_vec;
            rec_rsp.m_time        = $time;
            rec_rsp.m_cycle_count = m_vif.get_cycle_count();
            rec_rsp.m_attid           = vec_to_id(m_vif.monitor_cb.recall_att_vec);
            dm_ap.write(rec_rsp);
           //`uvm_info(get_name(), $sformatf("Put the rec_req_pkt into port: %p", rec_rsp.convert2string()), UVM_LOW);
        end
    end
endtask: grab_dm_recrsp

//*****************************************************
task dce_probe_monitor::grab_tm_attvec();

    bit [WATTVEC-1:0] attvld_vec;
    bit [WATTVEC-1:0] attvld_vec_prev;
     
    forever begin
        @(m_vif.monitor_cb);
        if (attvld_vec_prev != m_vif.monitor_cb.attvld_vec) begin
            attvld_vec      = m_vif.monitor_cb.attvld_vec;
            attvld_vec_prev = attvld_vec;
            //@(m_vif.monitor_cb);
            //@(m_vif.monitor_cb);
            tm_ap.write(attvld_vec);
            //`uvm_info(get_name(), $sformatf("Time: %t Put the attvld_vec into tm_ap port: 0b%0b", $time, attvld_vec), UVM_LOW);
        end
    end
endtask: grab_tm_attvec

//****************************************************
task dce_probe_monitor::grab_sys_event();
    
    event_in_t sys_event;
    bit prev_ack,prev_req;
    
    forever begin
        @(m_vif.monitor_cb);

        if(m_vif.monitor_cb.event_in_req && !prev_req) begin
            sys_event = req;
            evt_ap.write(sys_event);
        end

        if(m_vif.monitor_cb.event_in_ack && !prev_ack) begin
            sys_event = ack;
            evt_ap.write(sys_event);
        end

        if(m_vif.monitor_cb.event_err_valid) begin
            sys_event = err;
            evt_ap.write(sys_event);
        end

        prev_req = m_vif.monitor_cb.event_in_req;   
        prev_ack = m_vif.monitor_cb.event_in_ack;   
    end
endtask: grab_sys_event
        

//****************************************************
function int dce_probe_monitor::vec_to_id(bit [WATTVEC - 1 : 0] attvec);
    int attid = 0;

    while (attvec > 0) begin
        attvec = attvec >> 1; 
        if (attvec == 0) begin
            break;
        end else begin
            attid++;
        end
    end
    return attid;
endfunction: vec_to_id
