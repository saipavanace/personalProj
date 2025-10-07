`ifndef SYSTEM_BFM_SEQ
`define SYSTEM_BFM_SEQ

////////////////////////////////////////////////////////////////////////////////
//
// System BFM Master Sequence
//
////////////////////////////////////////////////////////////////////////////////
<%      var num_of_dvms = 0;
        var num_of_dvms_sources = 0;
        var unit_with_smaller_bus_width = 0;
        var unit_with_bigger_bus_width  = 0;
        for (var i = 0; i < obj.AiuInfo.length; i++) {  
            if(obj.AiuInfo[i].NativeInfo.DvmInfo.nDvmCmpInFlight > 0) {
                num_of_dvms++;
            }
            if(obj.AiuInfo[i].NativeInfo.DvmInfo.nDvmMsgInFlight > 0) {
                num_of_dvms_sources++;
            }
            if(obj.wXData < obj.AiuInfo[i].NativeInfo.SignalInfo.wXData) {
                unit_with_bigger_bus_width = 1
            }
            if(obj.wXData > obj.AiuInfo[i].NativeInfo.SignalInfo.wXData) {
                unit_with_smaller_bus_width = 1
            }
        }
        for (var i = 0; i < obj.DmiInfo.length; i++) {  
            if(obj.wXData < obj.DmiInfo[i].NativeInfo.SignalInfo.wXData) {
                unit_with_bigger_bus_width = 1
            }
        }
        if(!obj.isBridgeInterface) {  
            if (obj.AiuInfo[obj.Id].NativeInfo.DvmInfo.nDvmCmpInFlight == 0) {
                num_of_dvms++;
            }
        }
        if (obj.fnNativeInterface == "ACE") { 
            var id_snoop_filter_slice = obj.idSnoopFilterSlice;
        }
        else if (obj.isBridgeInterface && obj.useIoCache) { 
            var id_snoop_filter_slice = obj.idSnoopFilterSlice;
        }
        else {
            var id_snoop_filter_slice = 0;
        }
	
%>
        <%
        var aiuid, sfid, sftype;
        var wrevict = 0;
        if(obj.Id < obj.AiuInfo.length) {
            aiuid  = obj.Id;
            if (obj.AiuInfo[aiuid].fnNativeInterface === "ACE-LITE") {
	       sftype = "UNDEFINED";
               wrevict = 0;
            } else {
               sfid   = obj.AiuInfo[aiuid].CmpInfo.idSnoopFilterSlice;
               sftype = obj.SnoopFilterInfo[sfid].fnFilterType;
               wrevict = obj.useWriteEvict;
            }		    
        } else {
            aiuid  = obj.Id - obj.AiuInfo.length;
            if (obj.BridgeAiuInfo[aiuid].fnNativeInterface === "ACE-LITE" && !obj.BridgeAiuInfo[aiuid].NativeInfo.useIoCache) {
	       sftype = "UNDEFINED";
            } else {
               sfid   = obj.BridgeAiuInfo[aiuid].CmpInfo.idSnoopFilterSlice;
               sftype = obj.SnoopFilterInfo[sfid].fnFilterType;
            }
        wrevict = "0";	  	
        }
       //console.log("aiuid = " +  aiuid);
       //console.log("wrevict = " + wrevict);
        %> 

////////////////////////////////////////////////////////////////////////////////
//
// System BFM Sequence
//
////////////////////////////////////////////////////////////////////////////////

class system_bfm_seq extends uvm_sequence;

    `uvm_object_utils(system_bfm_seq)

    typedef struct {
        <%=obj.BlockId + '_con'%>::AIUID_t      m_aiu_id;
        <%=obj.BlockId + '_con'%>::AIUTransID_t m_aiu_trans_id;
    } aiu_id_t;

    typedef struct {
        <%=obj.BlockId + '_con'%>::smi_addr_security_t m_addr;
        // Not sure if we need field below?
        <%=obj.BlockId + '_con'%>::smi_msg_id m_smi_msg_id;
    } req_in_process_t;

    typedef struct {
        <%=obj.BlockId + '_con'%>::smi_addr_security_t m_addr;
        <%=obj.BlockId + '_con'%>::cacheState_t        m_cache_state;
        bit                                            m_isDVM;
    } str_state_list_t;

    typedef struct {
        <%=obj.BlockId + '_con'%>::smi_addr_security_t m_addr;
        smi_seq_item                                   m_seq_item;
        time                                           t_smi_ndp_ready;
    } smi_seq_item_addr_t;

    smi_seq      m_cmdreq_rx;
    smi_seq      m_allrsp_rx;
    smi_seq      m_snpreq_tx;
    smi_seq      m_allrsp_tx;
    smi_seq      m_strreq_tx;
    smi_seq      m_dtrdtwreq_rx;
    smi_seq      m_dtrreq_tx;
    AddrTransMgr m_addr_mgr;
   
    <% if((obj.testBench == "cbi") && obj.isBridgeInterface && obj.useIoCache) {%>
    ncbu_scoreboard       m_ncbu_cache_handle;
    <%}%>

    bit start_snoop_traffic;
    // For Agent isolation mode
    bit       pause_snoops = 0;
    uvm_event e_agent_isolation_mode_flip;

    // Control Knobs
<% if (obj.fnNativeInterface == "ACE" ||
      (obj.isBridgeInterface && obj.useIoCache)
) { %>    
    int k_snp_req_q_size                  = <%=obj.nDCEs%> * <%=obj.SnoopFilterInfo[id_snoop_filter_slice].CmpInfo.nSnpInFlight%>;
<% } %>    
    int k_num_addr                 = 1000;
    int k_num_snp                  = 10;
    int wt_snp_cln_dtr             = 10;
    int wt_snp_nitc                = 10;
    int wt_snp_vld_dtr             = 10;
    int wt_snp_inv_dtr             = 10;
    int wt_snp_inv_dtw             = 10;
    int wt_snp_inv                 = 10;
    int wt_snp_cln_dtw             = 10;
    int wt_snp_recall              = 10;
    int wt_snp_nosdint             = 10;
    int wt_snp_inv_stsh            = 10;
    int wt_snp_unq_stsh            = 10;
    int wt_snp_stsh_sh             = 10;
    int wt_snp_stsh_unq            = 10;
    int wt_snp_dvm_msg             = 20;
    int wt_snp_nitcci              = 10;
    int wt_snp_nitcmi              = 10;
    int wt_snp_random_addr         = 10;
    int wt_snp_prev_addr           = 50;
    int wt_snp_cmd_req_addr        = 50;
    int wt_exokay_set              = 40;
    int wt_dvm_multipart_snp       = 20;
    int wt_dvm_sync_snp            = 20;
    int prob_multiple_dtr_for_read = 30;

    // TODO: Probabilities for error injection
    //int prob_strreq_addr_err_inj          = 0;
    //int prob_strreq_data_err_inj          = 0;
    //int prob_strreq_trspt_err_inj         = 0;
    //int prob_dtwrsp_data_err_inj          = 0;
    //int prob_dtrreq_data_err_inj          = 0;
    //int prob_cmdrsp_trspt_sec_err_inj     = 0;
    //int prob_upddtwrsp_trspt_sec_err_inj  = 0;
    //int prob_cmdrsp_trspt_tmo_err_inj     = 0;
    //int prob_upddtwrsp_trspt_tmo_err_inj  = 0;
    //int prob_cmdrsp_trspt_disc_err_inj    = 0;
    //int prob_upddtwrsp_trspt_disc_err_inj = 0;
    // v2.0 DTR_DATA_VIS related errors
    //int prob_dtrdatavis_trspt_sec_err_inj = 0;
    //int prob_dtrdatavis_trspt_tmo_err_inj = 0;
    //int prob_dtrdatavis_trspt_disc_err_inj = 0;
    //int prob_dtrdatavis_addr_err_inj = 0;

    //int k_sfi_cmd_rsp_delay_min  = 1;
    //int k_sfi_cmd_rsp_delay_max  = 3;
    //int k_sfi_cmd_rsp_burst_pct  = 80;
    //int k_sfi_dtw_rsp_delay_min  = 1;
    //int k_sfi_dtw_rsp_delay_max  = 3;
    //int k_sfi_dtw_rsp_burst_pct  = 80;
    //int k_sfi_upd_rsp_delay_min  = 1;
    //int k_sfi_upd_rsp_delay_max  = 3;
    //int k_sfi_upd_rsp_burst_pct  = 80;


    bit dis_delay_dtr_req              = 0;
    bit dis_delay_str_req              = 0;
    bit dis_delay_tx_resp              = 0;
    bit dis_delay_cmd_resp             = 0;
    bit dis_delay_dtw_resp             = 0;
    bit dis_delay_upd_resp             = 0;
    bit dis_delay_dtr_resp             = 0; // TODO: Need to use this variable below
    int high_system_bfm_slv_rsp_delays = 0;
    bit gen_more_streaming_traffic     = 0;

    typedef struct {
        smi_seq_item m_smi_seq_item;
        int          delay;
    } smi_slv_req_q_t;

    smi_seq_item_addr_t                            m_smi_cmd_req_q[$];
    smi_seq_item                                   m_smi_snp_req_q[$];
    smi_seq_item_addr_t                            m_smi_str_req_q[$];
    smi_seq_item                                   m_smi_dtr_req_q[$];
    smi_seq_item                                   m_smi_mst_req_q[$];
    smi_seq_item                                   m_smi_mst_rsp_q[$];
    smi_slv_req_q_t                                m_smi_slv_req_q[$];
    <%=obj.BlockId + '_con'%>::smi_addr_security_t m_smi_str_pending_addr_h[<%=obj.BlockId + '_con'%>::smi_msg_id_t];
    <%=obj.BlockId + '_con'%>::smi_addr_security_t m_addr_history[$];
    req_in_process_t                               m_req_in_process[$];
    <%=obj.BlockId + '_con'%>::smi_addr_security_t m_processing_cmdreq_addr_q[$]; 
    <%=obj.BlockId + '_con'%>::smi_addr_security_t m_processing_snpreq_addr_q[$]; 
    event                                          e_smi_slv_req_q;
    event                                          e_smi_mst_req_q;
    event                                          e_smi_mst_rsp_q;
    event                                          e_smi_cmd_req_q;
    event                                          e_smi_snp_req_q;
    event                                          e_smi_snp_req_del_q;
    event                                          e_smi_str_req_q;
    event                                          e_smi_dtr_req_q;
    event                                          e_smi_mst_transId_freeup;
    event                                          e_addr_history;

    event                                          e_unblock_process_cmd_req;
    int                                            cmd_count;
    bit                                            cmd_req_blocked;
    
    event                                          e_tb_clk;
    event                                          e_delay_equal_zero;

    <%=obj.BlockId + '_con'%>::coherResult_ST_t    m_req_aiu_id = <%=obj.Id%>;
    <%=obj.BlockId + '_con'%>::cacheState_t        state_list[bit [WSMIADDR-1-<%=obj.BlockId + '_con'%>::SYS_wSysCacheline+<%=obj.wSecurityAttribute%>:0]];
    str_state_list_t                               str_state_list[<%=obj.BlockId + '_con'%>::smi_msg_id_t];
    smi_virtual_sequencer                          m_smi_virtual_seqr;
    smi_sequencer                                  m_smi_seqr_rx_hash[string];
    smi_sequencer                                  m_smi_seqr_tx_hash[string];

    int snoop_count;
    int num_dvm_capable_aius = 0;
    int num_dvm_source_aius = 0;

    // BW test - to disable all delays
    bit       bw_test = 0;
    bit       delay_str_req;
    bit       delay_dtr_req;
    bit       delay_tx_resp;
    bit       delay_cmd_resp;
    bit       delay_dtw_resp;
    bit       delay_upd_resp;
    int       delay_str_req_val    = 1;
    int       delay_dtr_req_val    = 1;
    int       delay_tx_resp_val = 1;
    int       delay_cmd_resp_val = 1;
    int       delay_dtw_resp_val = 1;
    int       delay_upd_resp_val = 1;
    semaphore s_transid            = new(1);


    // dvm_sync_snoop_sent[X][1] : eDtrDvmCmp or SnpRsp received?
    // dvm_sync_snoop_sent[X][0] : DVM Sync snoop sent? 
<% if (num_of_dvms <= 2) { %> 
    bit [1][1:0] dvm_sync_snoop_sent;
<% } else { %>
    bit [<%=num_of_dvms%>-2:0][1:0] dvm_sync_snoop_sent;
<% } %>

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new (string name = "system_bfm_seq");
    super.new(name);
    num_dvm_capable_aius = <%=num_of_dvms%>; 
    num_dvm_source_aius  = <%=num_of_dvms_sources%>; 
    foreach(dvm_sync_snoop_sent[i]) begin
        dvm_sync_snoop_sent[i]  = '0;
    end
    m_addr_mgr = AddrTransMgr::GetInstance_AddrTransMgr();
    if ($test$plusargs("hit_streaming_strreqs")) begin
        gen_more_streaming_traffic = 1;
    end
    else begin
        gen_more_streaming_traffic = ($urandom_range(0,100) < 30);
    end
    if($test$plusargs("read_bw_test") || $test$plusargs("write_bw_test") || $test$plusargs("read_latency_test") )begin
        bw_test = 1;
    end
    else begin
        bw_test = 0;
    end
    if($test$plusargs("dis_drty_hndbck"))begin
        dis_drty_hndbck = 1;
    end

    if (bw_test) begin
        dis_delay_dtr_req              = 1;
        dis_delay_str_req              = 1;
        dis_delay_dtr_req              = 1;
        dis_delay_tx_resp           = 1;
        dis_delay_cmd_resp             = 1;
        dis_delay_dtw_resp             = 1;
        dis_delay_upd_resp             = 1;
        high_system_bfm_slv_rsp_delays = 0;
    end
    // Constructing sequencer hash for ease of use in main sequence code
    // Reversing TX and RX directions because polarity is opposite for TB than it is for RTL
    <% 
    for (var i = 0; i < obj.smiTxPortParams.length; i++) { 
       for (var j = 0; j < obj.smiTxPortParams[i].fnMsgClass; j++) {
    %>
            m_smi_seqr_rx_hash["<%=obj.smiTxPortParams[i].fnMsgClass[j]"] = m_smi_virtual_seqr.m_smi<%=i%>_seqr;
    <%
        }
    }
    %>

    <% 
    for (var i = 0; i < obj.smiRxPortParams.length; i++) { 
       for (var j = 0; j < obj.smiRxPortParams[i].fnMsgClass; j++) {
    %>
            m_smi_seqr_tx_hash["<%=obj.smiRxPortParams[i].fnMsgClass[j]"] = m_smi_virtual_seqr.m_smi<%=i%>_seqr;
    <%
        }
    }
    %>
endfunction : new

task monitor_rx_cmdreq;
    smi_seq m_smi_slv_seq_req;
    forever begin
        smi_seq_item m_tmp_seq_item;
        smi_slv_req_q_t m_tmp_smi_slv_req_item;
        smi_seq_item_addr_t m_tmp_seq_item_addr_t;
        bit                 m_cmdrsp_err_injected = 0;
        m_smi_slv_seq_req.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
        m_smi_slv_seq_req.return_response(m_tmp_seq_item, m_smi_seqr_rx_hash["CMD"]);

        // If CmdReq found, adding to cmdreqq 

        // TODO: Add CmdRsp Error code below
        // Deciding if CMDRsp error is going to be sent or not. If it is sent, then the STRReq should not be sent
        //if ($urandom_range(0,100) < prob_cmdrsp_trspt_sec_err_inj) begin
        //    m_tmp_seq_item.rsp_pkt.rsp_status  = <%=obj.BlockId + '_con'%>::ERR;
        //    m_tmp_seq_item.rsp_pkt.rsp_errCode = <%=obj.BlockId + '_con'%>::SEC;
        //    m_cmdrsp_err_injected              = 1;
        //    uvm_report_info("SYS BFM DEBUG", $sformatf("1 Injecting error for  address 0x%0x security %0d to queue %0p aiu_trans_id 0x%0x", m_cmd_trans.cmd_req.cache_addr, m_cmd_trans.cmd_req.req_security, m_tmp_seq_item_addr_t, m_cmd_trans.cmd_req.req_aiu_trans_id), UVM_HIGH); 
        //end
        //else if ($urandom_range(0,100) < prob_cmdrsp_trspt_tmo_err_inj) begin
        //    m_tmp_seq_item.rsp_pkt.rsp_status  = <%=obj.BlockId + '_con'%>::ERR;
        //    m_tmp_seq_item.rsp_pkt.rsp_errCode = <%=obj.BlockId + '_con'%>::TMO;
        //    m_cmdrsp_err_injected              = 1;
        //end
        //else if ($urandom_range(0,100) < prob_cmdrsp_trspt_disc_err_inj) begin
        //    m_tmp_seq_item.rsp_pkt.rsp_status  = <%=obj.BlockId + '_con'%>::ERR;
        //    m_tmp_seq_item.rsp_pkt.rsp_errCode = <%=obj.BlockId + '_con'%>::DISC;
        //    m_cmdrsp_err_injected              = 1;
        //end
        if (!m_cmdrsp_err_injected) begin
            m_tmp_seq_item_addr_t.m_seq_item = m_tmp_seq_item;
            m_tmp_seq_item_addr_t.t_smi_ndp_ready = $time;
            m_tmp_seq_item_addr_t.m_addr     = { 
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    m_tmp_seq_item.smi_attrv_ns,
                <% } %>
            m_tmp_seq_item.smi_addr};
            uvm_report_info("SYS BFM DEBUG", $sformatf("At 1 Pushing CmdReq for address 0x%0x to queue %0p", m_tmp_seq_item_addr_t.m_addr, m_tmp_seq_item_addr_t), UVM_HIGH); 
            m_smi_cmd_req_q.push_back(m_tmp_seq_item_addr_t);
            ->e_smi_cmd_req_q;
        end
        
        // TODO: Add if needed
        //To provide delay for CmdRsp
        //m_tmp_smi_slv_req_item.delay = ($urandom_range(1,100) <= k_smi_cmd_rsp_burst_pct) ? 0 : 
        //($urandom_range(k_smi_cmd_rsp_delay_min, k_smi_cmd_rsp_delay_max));
        m_tmp_smi_slv_req_item.m_smi_seq_item = m_tmp_seq_item; 
        m_smi_slv_req_q.push_back(m_tmp_smi_slv_req_item);
        ->e_smi_slv_req_q;
    end 
endtask : monitor_rx_cmdreq

task monitor_rx_dtrdtwreq;
    forever begin
        smi_seq_item m_tmp_seq_item;
        smi_slv_req_q_t m_tmp_smi_slv_req_item;
        m_smi_slv_seq_req.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
        // TODO: Fix below to look at correct virtual seqr.seqr port
        //m_smi_slv_seq_req.return_response(m_tmp_seq_item, m_smi_slv_req_seqr);

        // Commenting below because this might no longer happen 
        if (m_tmp_seq_item.isDtrMsg()) begin
            //<%=obj.BlockId + '_con'%>::DTRreqEntry_t m_dtr_req_entry = <%=obj.BlockId + '_con'%>::getDTRreqEntryFromsmi(m_tmp_seq_item.req_pkt);
            //if (m_dtr_req_entry.dtr_msg_type == <%=obj.BlockId + '_con'%>::eDtrDvmCmp) begin
            //    if (dvm_sync_snoop_sent[m_dtr_req_entry.req_aiu_unit_id - 1][1] == 1) begin
            //        dvm_sync_snoop_sent[m_dtr_req_entry.req_aiu_unit_id - 1][1] = 0;
            //        dvm_sync_snoop_sent[m_dtr_req_entry.req_aiu_unit_id - 1][0] = 0;
            //    end
            //    else begin
            //        dvm_sync_snoop_sent[m_dtr_req_entry.req_aiu_unit_id - 1][1] = 1;
            //    end
            //end
        end
       
        // TODO: Add if needed
        //To provide delay for DtrRsp, DtwRsp and UpdRsp packets
        //if (m_tmp_seq_item.isDtwMsg()) begin
        //    m_tmp_smi_slv_req_item.delay = ($urandom_range(1,100) <= k_smi_dtw_rsp_burst_pct) ? 0 : 
        //    ($urandom_range(k_smi_dtw_rsp_delay_min, k_smi_dtw_rsp_delay_max));
        //end else if (m_tmp_seq_item.req_pkt.req_transId[<%=obj.BlockId + '_con'%>::SLV_WTRANSID-1:<%=obj.BlockId + '_con'%>::SLV_WTRANSID-<%=obj.BlockId + '_con'%>::AIU_DTWUPD_OTT_TRANSID_PREFIX_WIDTH] == <%=obj.BlockId + '_con'%>::AIU_DTWUPD_OTT_TRANSID_PREFIX ||
        //    m_tmp_seq_item.req_pkt.req_transId[<%=obj.BlockId + '_con'%>::SLV_WTRANSID-1:<%=obj.BlockId + '_con'%>::SLV_WTRANSID-<%=obj.BlockId + '_con'%>::AIU_DTWUPD_UTT_TRANSID_PREFIX_WIDTH] == <%=obj.BlockId + '_con'%>::AIU_DTWUPD_UTT_TRANSID_PREFIX ||
        //    m_tmp_seq_item.req_pkt.req_transId[<%=obj.BlockId + '_con'%>::SLV_WTRANSID-1:<%=obj.BlockId + '_con'%>::SLV_WTRANSID-<%=obj.BlockId + '_con'%>::AIU_DTWUPD_STT_TRANSID_PREFIX_WIDTH] == <%=obj.BlockId + '_con'%>::AIU_DTWUPD_STT_TRANSID_PREFIX
        //) begin
        //    m_tmp_smi_slv_req_item.delay = ($urandom_range(1,100) <= k_smi_upd_rsp_burst_pct) ? 0 : 
        //    ($urandom_range(k_smi_upd_rsp_delay_min, k_smi_upd_rsp_delay_max));
        //end 

        m_tmp_smi_slv_req_item.m_smi_seq_item = m_tmp_seq_item; 
        m_smi_slv_req_q.push_back(m_tmp_smi_slv_req_item);
        ->e_smi_slv_req_q;
    end 
endtask : monitor_rx_dtrdtwreq

task send_tx_resp_delay;
    delay_tx_resp = 0;
    if (!dis_delay_tx_resp) begin
        forever begin
            #(delay_tx_resp_val * 1ns);
            delay_tx_resp = ~delay_tx_resp;
            if (high_system_bfm_slv_rsp_delays) begin
                delay_tx_resp_val = $urandom_range(1000,10000);
            end
            else begin
                delay_tx_resp_val = $urandom_range(1,1000);
            end
        end
    end
endtask: send_tx_resp_delay

task send_cmd_resp_delay;
    delay_cmd_resp = 0;
    if (!dis_delay_cmd_resp) begin
        forever begin
            #(delay_cmd_resp_val * 1ns);
            delay_cmd_resp = ~delay_cmd_resp;
            delay_cmd_resp_val = $urandom_range(1,1000);
        end
    end
endtask : send_cmd_resp_delay

task send_dtw_resp_delay;
    delay_dtw_resp = 0;
    if (!dis_delay_dtw_resp) begin
        forever begin
            #(delay_dtw_resp_val * 1ns);
            delay_dtw_resp = ~delay_dtw_resp;
            delay_dtw_resp_val = $urandom_range(1,1000);
        end
    end
endtask: send_dtw_resp_delay
 
task send_upd_resp_delay;
    delay_upd_resp = 0;
    if (!dis_delay_upd_resp) begin
        forever begin
            #(delay_upd_resp_val * 1ns);
            delay_upd_resp = ~delay_upd_resp;
            delay_upd_resp_val = $urandom_range(1,1000);
        end
    end
endtask : send_upd_resp_delay
 
task decrement_delay_count;
    forever begin
        @e_tb_clk;
        foreach (m_smi_slv_req_q[i]) begin
            if (m_smi_slv_req_q[i].delay > 0) begin
                m_smi_slv_req_q[i].delay--;
                if (m_smi_slv_req_q[i].delay == 0) begin
                    ->e_delay_equal_zero;
                end
            end
            else begin
                ->e_delay_equal_zero;
            end
        end
    end
endtask : decrement_delay_count
 
task send_tx_resp;
    forever begin
        int m_index_q[$];
        bit found;
        smi_seq_item    m_tmp_seq_item;
        smi_seq_item    m_rsp_seq_item;
        smi_slv_req_q_t m_tmp_smi_slv_req_item;
        bit             is_dtw_req;
        bit             done = 0;
        if (delay_tx_resp) begin
            wait(delay_tx_resp == 0);
        end
        found = 0;
        do begin
            m_index_q = {};
            m_index_q = m_smi_slv_req_q.find_index with (item.delay <= 0);
            if (m_index_q.size() == 0) begin
                @e_delay_equal_zero;
            end
            else begin
                found = 1;
            end
        end while (!found);
        m_index_q.shuffle();
        m_tmp_smi_slv_req_item = m_smi_slv_req_q[m_index_q[0]];
        m_tmp_seq_item = m_tmp_smi_slv_req_item.m_smi_seq_item;
        m_smi_slv_req_q.delete(m_index_q[0]);
        m_rsp_seq_item = smi_seq_item::type_id::create("m_seq_item");
        // Setting up SMI packet
        // CMH first
        m_rsp_seq_item.smi_targ_id = m_tmp_seq_item.smi_src_id;
        m_rsp_seq_item.smi_src_id  = m_tmp_seq_item.smi_targ_id;
        if (m_tmp_seq_item.isCMDreq()) begin
            if (m_tmp_seq_item.smi_attrv_ch) begin
                m_rsp_seq_item.smi_type =  <%=obj.BlockId + '_con'%>::C_CMD_RSP;
            end
            else begin
                m_rsp_seq_item.smi_type =  <%=obj.BlockId + '_con'%>::NC_CMD_RSP;
            end
        end
        m_tmp_seq_item.smi_msg_id = m_tmp_seq_item.smi_msg_id;
        // Rest of the packet
        m_rsp_seq_item.smi_cmstatus = 0; // This needs to be driven to non-zero for error testing
        m_rsp_seq_item.smi_rmsg_id = m_tmp_seq_item.smi_msg_id;
        if (m_tmp_seq_item.isCMDreq()) begin
            //m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_status  = m_tmp_seq_item.rsp_pkt.rsp_status;
            //m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_errCode = m_tmp_seq_item.rsp_pkt.rsp_errCode;
            //uvm_report_info("SYS BFM DEBUG", $sformatf("Sending response for address 0x%0x aiu_trans_id 0x%0x status 0x%0x errcode 0x%0x", m_tmp_seq_item.req_pkt.req_addr, m_tmp_seq_item.req_pkt.req_transId, m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_status, m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_errCode), UVM_HIGH); 
        end
        // DtwRsp
        if (m_tmp_seq_item.isDTWreq()) begin
            //if ($urandom_range(0,100) < prob_dtwrsp_data_err_inj) begin
            //    m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_status  = <%=obj.BlockId + '_con'%>::ERR;
            //    m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_errCode = <%=obj.BlockId + '_con'%>::DERR;
            //end
        end
        // DtwRsp & UpdRsp
        //if (m_tmp_seq_item.req_pkt.req_transId[<%=obj.BlockId + '_con'%>::SLV_WTRANSID-1:<%=obj.BlockId + '_con'%>::SLV_WTRANSID-<%=obj.BlockId + '_con'%>::AIU_DTWUPD_OTT_TRANSID_PREFIX_WIDTH] == <%=obj.BlockId + '_con'%>::AIU_DTWUPD_OTT_TRANSID_PREFIX ||
        //    m_tmp_seq_item.req_pkt.req_transId[<%=obj.BlockId + '_con'%>::SLV_WTRANSID-1:<%=obj.BlockId + '_con'%>::SLV_WTRANSID-<%=obj.BlockId + '_con'%>::AIU_DTWUPD_UTT_TRANSID_PREFIX_WIDTH] == <%=obj.BlockId + '_con'%>::AIU_DTWUPD_UTT_TRANSID_PREFIX ||
        //    m_tmp_seq_item.req_pkt.req_transId[<%=obj.BlockId + '_con'%>::SLV_WTRANSID-1:<%=obj.BlockId + '_con'%>::SLV_WTRANSID-<%=obj.BlockId + '_con'%>::AIU_DTWUPD_STT_TRANSID_PREFIX_WIDTH] == <%=obj.BlockId + '_con'%>::AIU_DTWUPD_STT_TRANSID_PREFIX
        //) begin
            //if ($urandom_range(0,100) < prob_upddtwrsp_trspt_sec_err_inj) begin
            //    m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_status  = <%=obj.BlockId + '_con'%>::ERR;
            //    m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_errCode = <%=obj.BlockId + '_con'%>::SEC;
            //end
            //else if ($urandom_range(0,100) < prob_upddtwrsp_trspt_tmo_err_inj) begin
            //    m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_status  = <%=obj.BlockId + '_con'%>::ERR;
            //    m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_errCode = <%=obj.BlockId + '_con'%>::TMO;
            //end
            //else if ($urandom_range(0,100) < prob_upddtwrsp_trspt_disc_err_inj) begin
            //    m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_status  = <%=obj.BlockId + '_con'%>::ERR;
            //    m_smi_slv_seq_rsp.m_seq_item.rsp_pkt.rsp_errCode = <%=obj.BlockId + '_con'%>::DISC;
            //end
        //end
        if (m_tmp_seq_item.isDTWreq()) begin
            m_smi_slv_seq_rsp.return_response(m_tmp_seq_item, m_smi_seqr_tx_hash["DTW"]);
        end else if (m_tmp_seq_item.isCMDreq()) begin
            m_smi_slv_seq_rsp.return_response(m_tmp_seq_item, m_smi_seqr_tx_hash["CMD"]);
        end else if (m_tmp_seq_item.isUPDreq()) begin
            m_smi_slv_seq_rsp.return_response(m_tmp_seq_item, m_smi_seqr_tx_hash["UPD"]);
        end else if (m_tmp_seq_item.isDTRreq()) begin
            m_smi_slv_seq_rsp.return_response(m_tmp_seq_item, m_smi_seqr_tx_hash["DTR"]);
        end
    end
endtask : send_tx_resp

task process_rx_resp;
    forever begin
        if (m_sfi_mst_rsp_q.size == 0) begin
            @e_sfi_mst_rsp_q;
        end
        else begin
            int          m_tmp_qA[$], m_tmp_qB[$];
            smi_seq_item m_tmp_seq_item;
            m_smi_mst_rsp_q.shuffle();
            m_tmp_seq_item = m_smi_mst_rsp_q[0];
            m_smi_mst_rsp_q.delete(0);
            if (m_tmp_seq_item.isStrRspMsg()) begin
                m_tmp_qA = {};
                m_tmp_qA = m_smi_mst_req_q.find_index with (item.isStrMsg());
            end else if (m_tmp_seq_item.isSnpRspMsg()) begin
                m_tmp_qA = {};
                m_tmp_qA = m_smi_mst_req_q.find_index with (item.isSnpMsg());
            end else if (m_tmp_seq_item.isDtrRspMsg()) begin
                m_tmp_qA = {};
                m_tmp_qA = m_smi_mst_req_q.find_index with (item.isDtrMsg());
            end
            m_tmp_qB = {};
            m_tmp_qB = m_tmp_qA.find_index with (m_smi_mst_req_q[item].smi_msg_id == m_tmp_seq_item.smi_rmsg_id);
            if (m_tmp_qB.size() == 0) begin
                uvm_report_info("SYSTEM BFM MASTER RSP", "Printing outstanding requests below:", UVM_NONE);
                foreach (m_smi_mst_req_q[i]) begin
                    uvm_report_info($sformatf("Entry %0d:", i), m_smi_mst_req_q[i].convert2string(), UVM_NONE);
                end
                uvm_report_info("SYSTEM BFM MASTER RSP", "Printing response below:", UVM_NONE);
                uvm_report_info("SYSTEM BFM MASTER RSP", m_tmp_seq_item.convert2string(), UVM_NONE);
                `uvm_error("SYSTEM BFM MASTER RSP", $sformatf("Got above SMI response message without finding a matching message that BFM sent"), UVM_NONE);
            end
            else if (m_tmp_qB.size() > 1) begin
                uvm_report_info("SYSTEM BFM MASTER RSP", "Printing all matching requests below:", UVM_NONE);
                foreach (m_tmp_qB[i]) begin
                    uvm_report_info($sformatf("Entry %0d:", i), m_smi_mst_req_q[m_tmp_qB[i]].convert2string(), UVM_NONE);
                end
                uvm_report_info("SYSTEM BFM MASTER RSP", "Printing response below:", UVM_NONE);
                uvm_report_info("SYSTEM BFM MASTER RSP", m_tmp_seq_item.convert2string(), UVM_NONE);
                `uvm_error("SYSTEM BFM MASTER RSP", $sformatf("TB Error: Got above SMI response message that matches multiple outstanding requests"), UVM_NONE);
            end
            else begin
                // Updating state_list based on snoop response
                // RV = 0 -> IX
                // RV = 1 RS = 1 -> SC
                // RV = 1 RS = 0 DC = 1 -> OC
                // RV = 1 RS = 0 DC = 0 -> Unique becomes owned else SS = ES
                if (m_smi_mst_req_q[m_tmp_qB[0]].isSnpMsg()) begin
                    if (m_smi_mst_req_q[m_tmp_qB[0]].smi_type !== <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
                        if (state_list.exists({
                            <% if (obj.wSecurityAttribute > 0) { %>                                             
                                m_smi_mst_req_q[m_tmp_qB[0]].smi_attrv_ns,
                            <% } %>                                                
                        m_smi_mst_req_q[m_tmp_qB[0]].smi_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]})) begin
                            if (m_tmp_seq_item.smi_snprspv_rv == 0) begin
                                state_list.delete({
                                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                                        m_smi_mst_req_q[m_tmp_qB[0]].smi_attrv_ns,
                                    <% } %>                                                
                                m_smi_mst_req_q[m_tmp_qB[0]].smi_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]});
                            end
                            else if (m_tmp_seq_item.smi_snprspv_rv == 1 && 
                                m_tmp_seq_item.smi_snprspv_rs == 1
                            ) begin
                                state_list[{
                                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                                        m_smi_mst_req_q[m_tmp_qB[0]].smi_attrv_ns,
                                    <% } %>                                                
                                m_smi_mst_req_q[m_tmp_qB[0]].smi_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]}] = <%=obj.BlockId + '_con'%>::SC;
                            end
                            else if (m_tmp_seq_item.smi_snprspv_rv == 1 && 
                                m_tmp_seq_item.smi_snprspv_rs == 0 && 
                                m_tmp_seq_item.smi_snprspv_dc == 1
                            ) begin
                                state_list[{
                                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                                        m_smi_mst_req_q[m_tmp_qB[0]].smi_attrv_ns,
                                    <% } %>                                                
                                m_smi_mst_req_q[m_tmp_qB[0]].smi_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]}] = <%=obj.BlockId + '_con'%>::OC;
                            end
                            else if (m_tmp_seq_item.smi_snprspv_rv == 1 && 
                                m_tmp_seq_item.smi_snprspv_rs == 0 && 
                                m_tmp_seq_item.smi_snprspv_dc == 0
                            ) begin
                                if (state_list[{
                                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                                        m_smi_mst_req_q[m_tmp_qB[0]].smi_attrv_ns,
                                    <% } %>                                                
                                m_smi_mst_req_q[m_tmp_qB[0]].smi_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]}] == <%=obj.BlockId + '_con'%>::UC) begin
                                    state_list[{
                                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                                            m_smi_mst_req_q[m_tmp_qB[0]].smi_attrv_ns,
                                        <% } %>                                                
                                    m_smi_mst_req_q[m_tmp_qB[0]].smi_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]}] = <%=obj.BlockId + '_con'%>::OC;
                                end
                                else if (state_list[{
                                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                                        m_smi_mst_req_q[m_tmp_qB[0]].smi_attrv_ns,
                                    <% } %>                                                
                                m_smi_mst_req_q[m_tmp_qB[0]].smi_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]}] == <%=obj.BlockId + '_con'%>::UD) begin
                                    state_list[{
                                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                                            m_smi_mst_req_q[m_tmp_qB[0]].smi_attrv_ns,
                                        <% } %>                                                
                                    m_smi_mst_req_q[m_tmp_qB[0]].smi_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]}] = <%=obj.BlockId + '_con'%>::OD;
                                end
                            end
                            uvm_report_info("SYS BFM DEBUG", $sformatf("Updating state_list after receiving SnpReq for address 0x%0x to state %0p", m_smi_mst_req_q[m_tmp_qB[0]].smi_addr, state_list[{
                            <% if (obj.wSecurityAttribute > 0) { %>                                             
                                m_smi_mst_req_q[m_tmp_qB[0]].smi_attrv_ns,
                            <% } %>                                                
                        m_smi_mst_req_q[m_tmp_qB[0]].smi_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]}]), UVM_HIGH);
                        end
                    end
                    else begin
                        // CG FIXME: TODO: Fix below smi_src_id to give ncore unit id
                        if (m_smi_mst_req_q[m_tmp_qB[0]].smi_type !== <%=obj.BlockId + '_con'%>::eSnpDvmSync) begin
                            if (dvm_sync_snoop_sent[m_smi_mst_req_q[m_tmp_qB[0]].smi_src_id - 1][1] == 1) begin
                                dvm_sync_snoop_sent[m_smi_mst_req_q[m_tmp_qB[0]].smi_src_id - 1][1] = 0;
                                dvm_sync_snoop_sent[m_smi_mst_req_q[m_tmp_qB[0]].smi_src_id - 1][0] = 0;
                            end
                            else begin
                                dvm_sync_snoop_sent[m_smi_mst_req_q[m_tmp_qB[0]].smi_src_id - 1][1] = 1;
                            end
                        end
                    end
                end
                else if (m_smi_mst_req_q[m_tmp_qB[0]].isSTRreq()) begin
                    if (!str_state_list.exists(m_tmp_seq_item.smi_rmsg_id)) begin
                        `uvm_error("SYS BFM SEQ", $sformatf("TB Error: STR response received but no entry found in str_state_list (id:0x%0x)", m_tmp_seq_item.smi_rmsg_id), UVM_NONE); 
                    end
                    else begin
                        if (str_state_list[m_tmp_seq_item.smi_rmsg_id].m_isDVM == 0) begin
                            if (str_state_list[m_tmp_seq_item.smi_rmsg_id].m_cache_state == <%=obj.BlockId + '_con'%>::IX) begin
                                state_list.delete(str_state_list[m_tmp_seq_item.smi_rmsg_id].m_addr[WSMIADDR-1+<%=obj.wSecurityAttribute%>:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]);
                            end
                            else begin
                                state_list[str_state_list[m_tmp_seq_item.smi_rmsg_id].m_addr[WSMIADDR-1+<%=obj.wSecurityAttribute%>:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]] = str_state_list[m_tmp_seq_item.smi_rmsg_id].m_cache_state;
                            end
                            uvm_report_info("SYS BFM DEBUG", $sformatf("Updating state_list after receiving StrRsp for address 0x%0x to state %0p", str_state_list[m_tmp_seq_item.smi_rmsg_id].m_addr, str_state_list[m_tmp_seq_item.smi_rmsg_id].m_cache_state), UVM_HIGH);
                        end
                        str_state_list.delete(m_tmp_seq_item.smi_rmsg_id);
                    end
                end
                m_smi_str_pending_addr_h.delete(m_tmp_seq_item.smi_rmsg_id);
                m_smi_mst_req_q.delete(m_tmp_qB[0]);
            end
            m_tmp_q = {};
            m_tmp_q = m_req_in_process.find_index with (item.m_smi_msg_id == m_tmp_seq_item.smi_rmsg_id);
            if (m_tmp_q.size() > 0) begin
                if (m_tmp_q.size() > 1) begin
                    uvm_report_info("SYSTEM BFM MASTER RSP REQ IN PROCESS QUEUE", "Printing all matching requests below:", UVM_NONE);
                    foreach (m_tmp_q[i]) begin
                        uvm_report_info($sformatf("Entry %0d:", i), $sformatf("%0p", m_req_in_process[m_tmp_q[i]]), UVM_NONE);
                    end
                    uvm_report_info("SYSTEM BFM MASTER RSP REQ IN PROCESS QUEUE", "Printing response below:", UVM_NONE);
                    uvm_report_info("SYSTEM BFM MASTER RSP REQ IN PROCESS QUEUE", m_tmp_seq_item.convert2string(), UVM_NONE);
                    `uvm_error("SYSTEM BFM MASTER RSP REQ IN PROCESS QUEUE", $sformatf("TB Error: Got above response on SFI master port with transID that matches multiple outstanding requests"), UVM_NONE);
                end
                else begin
                    m_req_in_process.delete(m_tmp_q[0]);
                end
            end
        end
    end 
endtask: process_rx_resp
//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    m_cmdreq_rx    = smi_seq::type_id::create("m_cmdreq_rx");
    m_allrsp_rx    = smi_seq::type_id::create("m_allrsp_rx");
    m_snpreq_tx    = smi_seq::type_id::create("m_snpreq_tx");
    m_allrsp_tx    = smi_seq::type_id::create("m_allrsp_tx");
    m_strreq_tx    = smi_seq::type_id::create("m_strreq_tx");
    m_dtrdtwreq_rx = smi_seq::type_id::create("m_dtrdtwreq_rx");
    m_dtrreq_tx    = smi_seq::type_id::create("m_dtrreq_tx");
    
    if (!uvm_config_db#(event)::get(.cntxt(this), 
        .inst_name ( "*" ), 
        .field_name( "e_tb_clk" ),
    .value(e_tb_clk))) begin
      `uvm_error( "system_bfm", "e_tb_clk not found" )
    end

    <% if((obj.testBench == "cbi") && obj.isBridgeInterface && obj.useIoCache) {%>
    if (!uvm_config_db#(ncbu_scoreboard)::get(.cntxt( uvm_root::get() ),
                                            .inst_name( "*" ),
                                            .field_name( "iocache_handle" ),
                                            .value( m_ncbu_cache_handle ))) begin
        `uvm_error("system_bfm", "cache model not found")
    end
    <%}%>

    fork
        begin : monitor_rx_cmdreq
            monitor_rx_req();
        end : monitor_rx_cmdreq
        begin : monitor_rx_dtrdtwreq
            monitor_rx_dtrdtwreq();
        end : monitor_rx_dtrdtwreq
        begin : send_tx_resp_delay
            send_tx_resp_delay();
        end : send_tx_resp_delay
        begin : send_cmd_resp_delay
            send_cmd_resp_delay();
        end : send_cmd_resp_delay
        begin : send_dtw_resp_delay
            send_dtw_resp_delay();
        end : send_dtw_resp_delay
        begin : send_upd_resp_delay
            send_upd_resp_delay();
        end : send_upd_resp_delay
        begin : decrement_delay_count
            decrement_delay_count();
        end : decrement_delay_count
        begin : send_tx_resp
            send_tx_resp();
        end : send_tx_resp
        begin : process_rx_resp
            process_rx_resp();
        end : process_rx_resp 
        begin : monitor_rx_resp
            forever begin
                sfi_seq_item m_tmp_seq_item;
                m_sfi_mst_seq_rsp.is_monitor_seq = 1;
                m_sfi_mst_seq_rsp.m_seq_item = sfi_seq_item::type_id::create("m_seq_item");
                m_sfi_mst_seq_rsp.m_seq_item.m_has_req = 0;
                m_sfi_mst_seq_rsp.m_seq_item.m_has_rsp = 0;
                m_sfi_mst_seq_rsp.return_response(m_tmp_seq_item, m_sfi_mst_rsp_seqr);
                // Should get a response here. Adding check to make sure
                if (m_tmp_seq_item.m_has_rsp !== 1) begin
                    uvm_report_info("SYSTEM BFM MASTER RSP", m_tmp_seq_item.convert2string(), UVM_NONE);
                    uvm_report_error("SYSTEM BFM MASTER RSP", $sformatf("TB Error: Should have gotten a valid response"), UVM_NONE);
                end
                else begin
                    m_sfi_mst_rsp_q.push_back(m_tmp_seq_item);
                    ->e_sfi_mst_rsp_q;
                end
            end 
        end : monitor_master_resp
        begin : process_cmd_req
            forever begin
                if (m_sfi_cmd_req_q.size == 0) begin
                    @e_sfi_cmd_req_q;
                end
                else begin

                    sfi_seq_item                                 m_tmp_cmd_item;
                    <%=obj.BlockId + '_con'%>::coherResult_t     coher_result [$];
                    //<%=obj.BlockId + '_con'%>::transResult_t     trans_result [$];
                    //<%=obj.BlockId + '_con'%>::cacheState_t      ending_state [$];
                    <%=obj.BlockId + '_con'%>::cacheState_t      start_state;
                    <%=obj.BlockId + '_con'%>::CMDreqEntryAce_t  m_cmd_trans;
                    <%=obj.BlockId + '_con'%>::coherResult_t     coher_result_final;
                    <%=obj.BlockId + '_con'%>::coherResult_t     coher_result_dvm;
                    bit                                          flag;
                    int                                          rand_index;
                    bit                                          isDVM;
                    int                                          count_cmdreq;
                    int                                          total_cmdreq;
                    // Added by Muffadal
                    //Added to support DTR error from DCE
                    bit      dtrdatavis_trspt_sec_err_inj;
                    bit      dtrdatavis_trspt_disc_err_inj;
                    bit      dtrdatavis_trspt_tmo_err_inj;

                    if($urandom_range(0,100) < prob_dtrdatavis_trspt_sec_err_inj) begin
                        dtrdatavis_trspt_sec_err_inj = 1;
                    end else if($urandom_range(0,100) < prob_dtrdatavis_trspt_disc_err_inj) begin
                        dtrdatavis_trspt_disc_err_inj = 1;
                    end else if($urandom_range(0,100) < prob_dtrdatavis_trspt_tmo_err_inj) begin
                        dtrdatavis_trspt_tmo_err_inj = 1;
                    end

                    `ifdef UPDREQ_TAG_TEST  
                        if(cmd_count > 300) begin
                            `uvm_info("SYSBFM",$psprintf("cmd_req BLOCKED cmd_count = %d",cmd_count),UVM_LOW)
                            cmd_req_blocked = 1;
                        end
                        if(cmd_req_blocked == 1) begin
                            @e_unblock_process_cmd_req;
                        end
                    `endif

                    total_cmdreq = m_sfi_cmd_req_q.size();
                    cmd_count = cmd_count+total_cmdreq;
                    m_sfi_cmd_req_q.shuffle(); 
                    count_cmdreq = 0;
                    do begin
                        int index;
                        int m_tmp_q[$];
                        flag= 1;
                        m_tmp_cmd_item = m_sfi_cmd_req_q[count_cmdreq].m_seq_item;
                        m_cmd_trans = <%=obj.BlockId + '_con'%>::getCMDreqEntryAceFromSfi(m_tmp_cmd_item.req_pkt);
                        if (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdDvmMsg) begin
                            isDVM = 1;
                        end
                        if (!isDVM) begin
                            foreach (m_sfi_mst_req_q[i]) begin
                                if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(m_sfi_mst_req_q[i].req_pkt)) begin
                                    <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_sfi_mst_req_q[i].req_pkt);
                                    if (m_snp_req_entry.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]
<% if (obj.wSecurityAttribute > 0) { %>                                             
    && m_snp_req_entry.req_security == m_cmd_trans.cmd_req.req_security
<% } %>                                                
                                    ) begin
                                        flag = 0; 
                                        break;
                                    end
                                end
                            end
                            if (m_smi_str_pending_addr_h.num() > 0) begin
                                bit tmp_flag = 0;
                                <%=obj.BlockId + '_con'%>::sfi_addr_security_t m_tmp_addr_0;
                                m_smi_str_pending_addr_h.first(index);
                                do begin
                                    int index_last;
                                    m_tmp_addr_0 = m_smi_str_pending_addr_h[index];
                                    if (m_tmp_addr_0[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] 
<% if (obj.wSecurityAttribute > 0) { %>                                             
                                    && m_tmp_addr_0[$size(m_tmp_addr_0) - 1 : $size(m_tmp_addr_0) - <%=obj.wSecurityAttribute%>] == m_cmd_trans.cmd_req.req_security    
<% } %>                                                
                                    ) begin
                                        flag = 0;
                                        break;
                                    end
                                    m_smi_str_pending_addr_h.last(index_last);
                                    if (index == index_last) begin
                                        tmp_flag = 1;
                                    end
                                    else begin
                                        m_smi_str_pending_addr_h.next(index); 
                                    end
                                end while (!tmp_flag);
                            end
                            m_tmp_q = {};
                            m_tmp_q = m_sfi_snp_req_q.find_first_index with (item.req_pkt.req_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]
<% if (obj.wSecurityAttribute > 0) { %>                                             
                            && item.req_pkt.req_security == m_cmd_trans.cmd_req.req_security    
<% } %>                                                
                            );
                            if (m_tmp_q.size() > 0) begin
                                flag = 0;
                            end
                            m_tmp_q = {};
                            m_tmp_q = m_processing_cmdreq_addr_q.find_first_index with (item[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]
<% if (obj.wSecurityAttribute > 0) { %>                                             
                            && item[$size(item) - 1 : $size(item) - <%=obj.wSecurityAttribute%>] == m_cmd_trans.cmd_req.req_security    
<% } %>                                                
                            );
                            if (m_tmp_q.size() > 0) begin
                                flag = 0;
                            end
                            m_tmp_q = {};
                            m_tmp_q = m_processing_snpreq_addr_q.find_first_index with (item[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]
<% if (obj.wSecurityAttribute > 0) { %>                                             
                            && item[$size(item) - 1 : $size(item) - <%=obj.wSecurityAttribute%>] == m_cmd_trans.cmd_req.req_security    
<% } %>                                                
                            );
                            if (m_tmp_q.size() > 0) begin
                                flag = 0;
                            end
                            if (!flag) begin
                                count_cmdreq++;
                                if (count_cmdreq >= total_cmdreq) begin
                                    @e_sfi_mst_transId_freeup;
                                    count_cmdreq = 0;
                                    total_cmdreq = m_sfi_cmd_req_q.size();
                                    m_sfi_cmd_req_q.shuffle(); 
                                end
                            end
                            else begin
                                // Processing the oldest CmdReq to this cacheline first
                                int  index;
                                time t_index;
                                m_tmp_q = {};
                                m_tmp_q = m_sfi_cmd_req_q.find_index with (item.m_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] 
                                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                                        && item.m_addr[$size(item.m_addr) - 1 : $size(item.m_addr) - <%=obj.wSecurityAttribute%>] == m_cmd_trans.cmd_req.req_security
                                    <% } %>                                                
                                );
                                if (m_tmp_q.size() == 0) begin
                                    uvm_report_error("SYS BFM SEQ", $sformatf("TB Error: Not possible to reach here for address 0x%0x", m_cmd_trans.cmd_req.cache_addr), UVM_NONE); 
                                end
                                else if (m_tmp_q.size() > 1) begin
                                    index = m_tmp_q[0];
                                    t_index = m_sfi_cmd_req_q[m_tmp_q[0]].t_smi_ndp_ready;
                                    for (int i = 1; i < m_tmp_q.size(); i++) begin
                                        if (t_index > m_sfi_cmd_req_q[m_tmp_q[i]].t_smi_ndp_ready) begin
                                            t_index = m_sfi_cmd_req_q[m_tmp_q[i]].t_smi_ndp_ready;
                                            index   = m_tmp_q[i];
                                        end
                                    end
                                end
                                else begin
                                    index = m_tmp_q[0];
                                end
                                count_cmdreq = index;
                                m_tmp_cmd_item = m_sfi_cmd_req_q[count_cmdreq].m_seq_item;
                                m_cmd_trans = <%=obj.BlockId + '_con'%>::getCMDreqEntryAceFromSfi(m_tmp_cmd_item.req_pkt);
                            end
                        end
                    end while (!flag);
                    m_sfi_cmd_req_q.delete(count_cmdreq);
                    // Only adding addresses to addr_history for read type requests where the cache will end up with the line
                    if ((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCpy) || 
                        (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCln) || 
                        (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdVld) || 
                        (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdUnq) || 
                        (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnUnq) || 
                        (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnVld) 
                    ) begin
                        m_addr_history.push_back({
<% if (obj.wSecurityAttribute > 0) { %>                                             
                                m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                        m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]});
                        ->e_addr_history;
                    end
                    if (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdDvmMsg) begin
                        isDVM = 1;
                    end
                    if (!isDVM) begin 
                        m_processing_cmdreq_addr_q.push_back({
<% if (obj.wSecurityAttribute > 0) { %>                                             
                                m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                        m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]});
                        uvm_report_info("CHIRAG", $sformatf("Adding address 0x%0x to processing queue size %0d", {m_cmd_trans.cmd_req.req_security, m_cmd_trans.cmd_req.cache_addr}, m_processing_cmdreq_addr_q.size()), UVM_HIGH);
<% if (obj.fnNativeInterface == "ACE" ||
       (obj.isBridgeInterface && obj.useIoCache)) { %> 
                        start_state = <%=obj.BlockId + '_con'%>::IX;
                        if (state_list.exists({
<% if (obj.wSecurityAttribute > 0) { %>                                             
    m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                        m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]})) begin
                            start_state = state_list[{
<% if (obj.wSecurityAttribute > 0) { %>                                             
    m_cmd_trans.cmd_req.req_security,
<% } %>                                                
m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]}];
                        end
                        //<%=obj.BlockId + '_con'%>::genTransResults(m_cmd_trans.cmd_req.cmd_msg_type, coher_result, trans_result, ending_state, start_state);
                        <%=obj.BlockId + '_con'%>::giveLegalSTRreqResultForCmd(m_cmd_trans.cmd_req.cmd_msg_type, coher_result);
                        if ((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCpy) ||
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCln) ||
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdVld) ||
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdUnq)
                        ) begin
                            foreach (coher_result[i]) begin
                                coher_result[i].ST = 1;
                            end
                        end
                        else begin
                            foreach (coher_result[i]) begin
                                coher_result[i].ST = 0;
                            end
                        end
                        //`uvm_info("SYSBFM CHIRAG", $sformatf("CmdReq %p start state %p", m_cmd_trans.cmd_req.cmd_msg_type, start_state), UVM_NONE)  
                        //foreach (coher_result[i]) begin
                        //    `uvm_info("SYSBFM CHIRAG coher_result", $sformatf("i %0d coher_result %p", i, coher_result[i]), UVM_NONE)
                        //end
                        // Pruning out illegal values
                        // If previous install state is UC/UD then SS=0/SO=1/SD=0)
                        // If previous install state is OC/OD then SO=1/SD=0)
                        // Else anything goes
                        if (start_state == <%=obj.BlockId + '_con'%>::UC ||
                            start_state == <%=obj.BlockId + '_con'%>::UD
                        ) begin
                            int tmp_indx[$];
                            foreach (coher_result[i]) begin
                                if (coher_result[i].SS !== 0 ||
                                    coher_result[i].SO !== 1 ||
                                    coher_result[i].SD !== 0
                                ) begin
                                    tmp_indx.push_back(i);
                                end
                            end
                            for (int i = tmp_indx.size() - 1; i >= 0; i--) begin
                                //ending_state.delete(tmp_indx[i]);
                                coher_result.delete(tmp_indx[i]);
                            end
                        end
                        else if (start_state == <%=obj.BlockId + '_con'%>::OC ||
                                 start_state == <%=obj.BlockId + '_con'%>::OD
                        ) begin
                            int tmp_indx[$];
                            foreach (coher_result[i]) begin
                                if (coher_result[i].SO !== 1 ||
                                    coher_result[i].SD !== 0
                                ) begin
                                    tmp_indx.push_back(i);
                                end
                            end
                            for (int i = tmp_indx.size() - 1; i >= 0; i--) begin
                                //ending_state.delete(tmp_indx[i]);
                                coher_result.delete(tmp_indx[i]);
                            end
                        end
                        if (coher_result.size() == 0) begin
                            uvm_report_error("SYS BFM SEQ", $sformatf("TB ERROR: coher_result pruning gone wrong for address 0x%0x cmdtype %p start state %p", m_cmd_trans.cmd_req.cache_addr, m_cmd_trans.cmd_req.cmd_msg_type, start_state), UVM_NONE);
                        end
                        coher_result = coher_result.unique();
                        rand_index = $urandom_range(0, coher_result.size()-1);
                        if (coher_result[rand_index].ST > 0) begin
                            randcase
                                100-prob_multiple_dtr_for_read: ;
                                prob_multiple_dtr_for_read    :  if(bw_test)begin
                                                                     coher_result[rand_index].ST = 1 ;
                                                                 end else begin
                                                                     coher_result[rand_index].ST = (<%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs == 1) ? 1 : $urandom_range(1, <%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs - 1);
                                                                 end
                            endcase
                        end
                        //Added by Muffadal on 10/17/2016
                        //As per the new spec the following Cmd will always have ST=1 
                        //CmdCldUniq, CmdClnVld, CmdClnInv  
                        if((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnUnq) || 
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnVld) ||
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnInv) 
                            ) begin
                            foreach (coher_result[i]) begin
                                coher_result[i].ST = 1;
                            end
                        end

                        if (((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCpy) || 
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCln) || 
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdVld) || 
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdUnq)) &&
                            ( dtrdatavis_trspt_sec_err_inj || dtrdatavis_trspt_tmo_err_inj || 
                            dtrdatavis_trspt_disc_err_inj)) begin
                                foreach (coher_result[i]) begin
                                    coher_result[i].ST = 1;
                                end
                        end



                        coher_result_final = coher_result[rand_index];
                        if (!(m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdUnq) && (bw_test || dis_drty_hndbck)) begin
                            if(coher_result_final.SD == 1) begin
                              coher_result_final.SO = 1;
                              coher_result_final.SD = 0;
                              coher_result_final.SS = 0;
                            end
                        end
<% }  
else { %>    
                        <%=obj.BlockId + '_con'%>::giveLegalSTRreqResultForCmd(m_cmd_trans.cmd_req.cmd_msg_type, coher_result);
                        if((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnUnq) || 
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnVld) ||
                        (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnInv)) begin
                            foreach (coher_result[i]) begin
                                coher_result[i].ST = 1;
                            end
                        end


                        if ((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCpy)  ||
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCln)  ||
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdVld)  ||
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdUnq) &&
                            ( dtrdatavis_trspt_sec_err_inj || dtrdatavis_trspt_tmo_err_inj || 
                            dtrdatavis_trspt_disc_err_inj)) begin
                            foreach (coher_result[i]) begin
                                coher_result[i].ST = 1;
                            end
                        end
                        else begin
                            foreach (coher_result[i]) begin
                                coher_result[i].ST = 0;
                            end
                        end
                        coher_result = coher_result.unique();
                        rand_index = $urandom_range(0, coher_result.size()-1);
                        if (coher_result[rand_index].ST > 0 &&  !( dtrdatavis_trspt_sec_err_inj | dtrdatavis_trspt_tmo_err_inj |
                            dtrdatavis_trspt_disc_err_inj)) begin
                            randcase
                                100-prob_multiple_dtr_for_read: ;
                                prob_multiple_dtr_for_read    :  if(bw_test)begin
                                                                     coher_result[rand_index].ST = 1 ;
                                                                 end else begin
                                                                     coher_result[rand_index].ST = (<%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs == 1) ? 1 : $urandom_range(1, <%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs - 1);
                                                                 end
                            endcase
                        end
                        //Added by Muffadal on 10/17/2016
                        //As per the new spec the following Cmd will always have ST=1 
                        //CmdCldUniq, CmdClnVld, CmdClnInv  
                        if((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnUnq) || 
                            (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnVld) ||
                        (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnInv)) begin
                            foreach (coher_result[i]) begin
                                coher_result[i].ST = 1;
                            end
                        end
                        coher_result_final = coher_result[rand_index];

                        if (!(m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdUnq) && (bw_test || dis_drty_hndbck)) begin
                          coher_result_final.SO = 1;
                          coher_result_final.SD = 0;
                          coher_result_final.SS = 0;
                        end

<% } %>
                    end
                    else begin
                        coher_result_final.ST = 0;
                        coher_result_final.SS = 0;
                        if(bw_test)begin
                          coher_result_final.SO = 1;
                        end else begin
                          coher_result_final.SO = 1;
                        end
                        coher_result_final.SD = 0;
                    end
                    if (isDVM) begin
                        if (m_cmd_trans.cmd_req.cache_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT] == 1'b1) begin
                            randcase
                                50: coher_result_dvm = 0;
                                50: coher_result_dvm = $urandom_range(0, num_dvm_capable_aius - 1); 
                            endcase
                        end
                        else begin
                            coher_result_dvm = 0; 
                        end
                    end
                    fork 
                        begin : create_str_pkt
                            <%=obj.BlockId + '_con'%>::sfi_mst_transId_t m_tmp_transId;
                            <%=obj.BlockId + '_con'%>::coherResult_t     coher_result_tmp [$];
                            <%=obj.BlockId + '_con'%>::transResult_t     trans_result_tmp [$];
                            <%=obj.BlockId + '_con'%>::cacheState_t      ending_state_tmp [$];
                            int                                          index            [$];
                            sfi_seq_item_addr_t                          m_tmp_str_item;
                            req_in_process_t                             m_req;
                            bit                                          flag = 1;
                            bit                                          isUD, isUC, isOD, isOC, isSC;
                            bit                                          localIsDVM;

                            localIsDVM = isDVM;
                           // Find unused transID value
                            // Check if all transID values are in use
                            //uvm_report_info("CHIRAG", $sformatf("creating str req trans id for address 0x%0x", m_cmd_trans.cmd_req.cache_addr), UVM_NONE);
                            s_transid.get();
                            if (m_trans_id_array.num() == 2**<%=obj.BlockId + '_con'%>::MST_WTRANSID - 1) begin
                                @e_sfi_mst_transId_freeup;
                            end
                            flag = 0;
                            do begin
                                m_tmp_transId = $urandom_range(2**<%=obj.BlockId + '_con'%>::MST_WTRANSID - 1);
                                if (!m_trans_id_array.exists(m_tmp_transId)) begin
                                    flag = 1;
                                    m_trans_id_array[m_tmp_transId] = 1;
                                end
                            end while (!flag);
                            s_transid.put();
                            if (localIsDVM) begin
                                m_req.m_addr         = '0;
                            end
                            else begin
                                m_req.m_addr         = {
<% if (obj.wSecurityAttribute > 0) { %>                                             
                                m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                                m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]};
                            end
                            m_req.m_sfi_trans_id = m_tmp_transId;
                            m_req_in_process.push_back(m_req);
                            m_tmp_str_item.m_seq_item                      = sfi_seq_item::type_id::create("m_tmp_str_item");
                            m_tmp_str_item.m_seq_item.m_has_req            = 1;
                            m_tmp_str_item.m_seq_item.req_pkt.req_opc      = <%=obj.BlockId + '_con'%>::WRITE;
                            m_tmp_str_item.m_seq_item.req_pkt.req_burst    = <%=obj.BlockId + '_con'%>::INCR;
                            m_tmp_str_item.m_seq_item.req_pkt.req_length   = 0; 
                            m_tmp_str_item.m_seq_item.req_pkt.req_transId  = m_tmp_transId;
                            m_tmp_str_item.m_seq_item.req_pkt.req_sfiSlvId = m_cmd_trans.cmd_req.req_aiu_id; 
                            <% if (obj.wSecurityAttribute > 0) { %>   
                                m_tmp_str_item.m_seq_item.req_pkt.req_security = m_cmd_trans.cmd_req.req_security; 
                            <% } %>                                  
                            <% if (obj.wPriorityLevel > 0) { %>
                                m_tmp_str_item.m_seq_item.req_pkt.req_urgency  = $urandom_range(0, 2**<%=obj.wPriorityLevel%>) ; 
                            <% } %>                                  
                            if (localIsDVM) begin
                                m_tmp_str_item.m_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_LSB]      = <%=obj.BlockId + '_con'%>::STR_DVM_CMP; 
                            end
                            else begin
                                m_tmp_str_item.m_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_LSB]      = <%=obj.BlockId + '_con'%>::STR_STATE; 
                            end
                            m_tmp_str_item.m_seq_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_TRANS_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_TRANS_ID_LSB] = m_cmd_trans.cmd_req.req_aiu_trans_id; 
                            m_tmp_str_item.m_seq_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_AIU_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_AIU_ID_LSB]     = m_cmd_trans.cmd_req.req_aiu_id; 
                            if ($urandom_range(0,100) < prob_strreq_addr_err_inj && !(localIsDVM && m_cmd_trans.cmd_req.cache_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT] == 1)) begin
                                m_tmp_str_item.m_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ERR_RESULT_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ERR_RESULT_LSB] = <%=obj.BlockId + '_con'%>::eErrResAddrErr;
                            end
                            else if ($urandom_range(0,100) < prob_strreq_data_err_inj && !(localIsDVM && m_cmd_trans.cmd_req.cache_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT] == 1)) begin
                                m_tmp_str_item.m_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ERR_RESULT_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ERR_RESULT_LSB] = <%=obj.BlockId + '_con'%>::eErrResDataErr;
                            end
                            else if ($urandom_range(0,100) < prob_strreq_trspt_err_inj && !(localIsDVM && m_cmd_trans.cmd_req.cache_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT] == 1)) begin
                                m_tmp_str_item.m_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ERR_RESULT_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ERR_RESULT_LSB] = <%=obj.BlockId + '_con'%>::eErrResTransportErr;
                            end
                            else begin
                                m_tmp_str_item.m_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ERR_RESULT_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ERR_RESULT_LSB] = <%=obj.BlockId + '_con'%>::eErrResNoErr;
                            end
                            m_tmp_str_item.m_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ACE_EXOKAY_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ACE_EXOKAY_LSB] = (m_cmd_trans.ace.lock == 1) ? ((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCln || m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdVld) ? 1'b1 : ((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnUnq) ? (($urandom_range(0,100) < wt_exokay_set) ? 1'b1 : 1'b0) : 1'b0)) : 1'b0;
                            // Setting STRReq = 0100 (SO = 1) if CmdClnUnq lock failed
                            // Below is true for system level, but not required for AIU TB since we dont really do exclusive access modelling and a fail does not mean that requesting AIU does not have line
                            //if (m_tmp_str_item.m_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ACE_EXOKAY_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_STR_ACE_EXOKAY_LSB] == 0 &&
                            //    m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnUnq &&
                            //    m_cmd_trans.ace.lock == 1
                            //) begin
                            //    coher_result_final.SV = 0;
                            //    coher_result_final.SO = 1;
                            //    coher_result_final.SD = 0;
                            //    coher_result_final.ST = 0;
                            //end
                            if (localIsDVM) begin
                                coher_result_final = coher_result_dvm;
                            end
                            m_tmp_str_item.m_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_COHER_RESULT_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_COHER_RESULT_LSB] = coher_result_final; 
                            m_tmp_str_item.m_addr     = { 
                                <% if (obj.wSecurityAttribute > 0) { %>                                             
                                    m_cmd_trans.cmd_req.req_security,
                                <% } %>
                            m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]}; 
                            m_tmp_str_item.t_smi_ndp_ready = $time;
                            m_sfi_str_req_q.push_back(m_tmp_str_item);
                        //    uvm_report_info("SYS BFM DBG", $sformatf("Pushing str req for address 0x%0x coher %1p state %1p aiu trans id 0x%0x sfi trans id 0x%0x", m_cmd_trans.cmd_req.cache_addr, coher_result_final, start_state, m_cmd_trans.cmd_req.req_aiu_trans_id, m_tmp_transId), UVM_NONE);
                            //Trying to find the state that the address will be installed in
                            if (localIsDVM) begin
                                str_state_list[m_tmp_transId].m_addr[WSMIADDR-1+<%=obj.wSecurityAttribute%>:0] = {
<% if (obj.wSecurityAttribute > 0) { %>                                             
    m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                                    m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]};
                                str_state_list[m_tmp_transId].m_cache_state = <%=obj.BlockId + '_con'%>::IX;
                                str_state_list[m_tmp_transId].m_isDVM       = 1;
                            end
                            else begin
                                <%=obj.BlockId + '_con'%>::genTransResults(m_cmd_trans.cmd_req.cmd_msg_type, coher_result_tmp, trans_result_tmp, ending_state_tmp, start_state);

                                foreach (coher_result_tmp[i]) begin
                                    if (coher_result_final.SS == coher_result_tmp[i].SS &&
                                        coher_result_final.SO == coher_result_tmp[i].SO &&    
                                        coher_result_final.SD == coher_result_tmp[i].SD
                                    ) begin
                                        index.push_back(i);
                                    end
                                end
                                isUD = 0;
                                isUC = 0;
                                isOD = 0;
                                isOC = 0;
                                isSC = 0;
                                foreach (index[i]) begin
                                    if(ending_state_tmp[index[i]] == <%=obj.BlockId + '_con'%>::UD) begin
                                        isUD = 1;
                                    end
                                    if(ending_state_tmp[index[i]] == <%=obj.BlockId + '_con'%>::UC) begin
                                        isUC = 1;
                                    end
                                    if(ending_state_tmp[index[i]] == <%=obj.BlockId + '_con'%>::OD) begin
                                        isOD = 1;
                                    end
                                    if(ending_state_tmp[index[i]] == <%=obj.BlockId + '_con'%>::OC) begin
                                        isOC = 1;
                                    end
                                    if(ending_state_tmp[index[i]] == <%=obj.BlockId + '_con'%>::SC) begin
                                        isSC = 1;
                                    end
                                end
                                if (isUD) begin
                                    str_state_list[m_tmp_transId].m_addr        = {
<% if (obj.wSecurityAttribute > 0) { %>                                             
    m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                                        m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]};
                                    str_state_list[m_tmp_transId].m_cache_state = <%=obj.BlockId + '_con'%>::UD;
                                    str_state_list[m_tmp_transId].m_isDVM       = 0;
                                end
                                else if (isUC) begin
                                    str_state_list[m_tmp_transId].m_addr        = {
<% if (obj.wSecurityAttribute > 0) { %>                                             
    m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                                        m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]};
                                    str_state_list[m_tmp_transId].m_cache_state = <%=obj.BlockId + '_con'%>::UC;
                                    str_state_list[m_tmp_transId].m_isDVM       = 0;
                                end
                                else if (isOD) begin
                                    str_state_list[m_tmp_transId].m_addr        = {
<% if (obj.wSecurityAttribute > 0) { %>                                             
    m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                                        m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]};
                                    str_state_list[m_tmp_transId].m_cache_state = <%=obj.BlockId + '_con'%>::OD;
                                    str_state_list[m_tmp_transId].m_isDVM       = 0;
                                end
                                else if (isOC) begin
                                    str_state_list[m_tmp_transId].m_addr        = {
<% if (obj.wSecurityAttribute > 0) { %>                                             
    m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                                        m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]};
                                    str_state_list[m_tmp_transId].m_cache_state = <%=obj.BlockId + '_con'%>::OC;
                                    str_state_list[m_tmp_transId].m_isDVM       = 0;
                                end
                                else if (isSC) begin
                                    str_state_list[m_tmp_transId].m_addr        = {
<% if (obj.wSecurityAttribute > 0) { %>                                             
    m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                                        m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]};
                                    str_state_list[m_tmp_transId].m_cache_state = <%=obj.BlockId + '_con'%>::SC;
                                    str_state_list[m_tmp_transId].m_isDVM       = 0;
                                end
                                else begin
                                    str_state_list[m_tmp_transId].m_addr        = {
<% if (obj.wSecurityAttribute > 0) { %>                                             
    m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                                        m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]};
                                    str_state_list[m_tmp_transId].m_cache_state = <%=obj.BlockId + '_con'%>::IX;
                                    str_state_list[m_tmp_transId].m_isDVM       = 0;
                                end
                                if (m_smi_str_pending_addr_h.exists(m_tmp_transId)) begin
                                    uvm_report_error("SYS BFM SEQ", $sformatf("TB Error: Found an entry in sfi_str_pending_addr for trans ID 0x%0x (value:0x%0x) while attempting to write value 0x%0x", m_tmp_transId, m_smi_str_pending_addr_h[m_tmp_transId], m_cmd_trans.cmd_req.cache_addr), UVM_NONE);
                                end
                                m_smi_str_pending_addr_h[m_tmp_transId] = {
<% if (obj.wSecurityAttribute > 0) { %>                                             
                                m_cmd_trans.cmd_req.req_security,
<% } %>                                                
                                m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]};
                                uvm_report_info("CHIRAG", $sformatf("Looking for address 0x%0x in m_processing_cmdreq_addr_q", {m_cmd_trans.cmd_req.req_security, m_cmd_trans.cmd_req.cache_addr}), UVM_HIGH);
                                index = {};
                                index = m_processing_cmdreq_addr_q.find_first_index with (item[WSMIADDR-1:0] == m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:0]
<% if (obj.wSecurityAttribute > 0) { %>                                             
                                && item[$size(item) - 1:$size(item) - <%=obj.wSecurityAttribute%>] == m_cmd_trans.cmd_req.req_security    
<% } %>                                                
                                );
                                if (index.size == 0) begin
                                    uvm_report_error("SYS BFM SEQ", $sformatf("TB Error: Could not find an entry in m_processing_cmdreq_addr_q for address 0x%0x", m_cmd_trans.cmd_req.cache_addr), UVM_NONE);
                                end
                                else begin
                                    m_processing_cmdreq_addr_q.delete(index[0]);
                                end
                                uvm_report_info("CHIRAG", $sformatf("Deleting address 0x%0x from processing queue", m_cmd_trans.cmd_req.cache_addr), UVM_HIGH);
                            end
                            ->e_sfi_str_req_q;
                        end : create_str_pkt
                        begin : create_dtr_pkt
                            bit localIsDVM        = isDVM;
                            bit isDTRDatDtyNeeded = !dis_drty_hndbck && !coher_result_final.SS && (coher_result_final.SD === 1 || (coher_result_final.ST === 1 && coher_result_final.SD === 0 && $urandom_range(0,100) > 25)) && !(m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCln) && !(m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCpy) ;
                            if (coher_result_final.ST > 0 && !localIsDVM) begin
                                bit flag = 1;
                                <%=obj.BlockId + '_con'%>::sfi_data_t m_random_data[] = new [<%=obj.BlockId + '_con'%>::SYS_nSysCacheline /  <%=obj.BlockId + '_con'%>::WBE];
                                <%=obj.BlockId + '_con'%>::sfi_be_t   m_random_be[] = new [<%=obj.BlockId + '_con'%>::SYS_nSysCacheline /  <%=obj.BlockId + '_con'%>::WBE];
                                // Check if Snoop Request has already been sent for this address
                                do begin
                                    flag= 1;
                                    foreach (m_sfi_mst_req_q[i]) begin
                                        if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(m_sfi_mst_req_q[i].req_pkt)) begin
                                            <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_sfi_mst_req_q[i].req_pkt);
                                            if (m_snp_req_entry.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_cmd_trans.cmd_req.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]
                                                <% if (obj.wSecurityAttribute > 0) { %>                                             
                                                    && m_snp_req_entry.req_security == m_cmd_trans.cmd_req.req_security    
                                                <% } %>                                                
                                            ) begin
                                                flag = 0; 
                                                break;
                                            end
                                        end
                                    end
                                    if (!flag) begin
                                        @e_sfi_mst_transId_freeup;
                                    end
                                end while (!flag);
                                for (int j = 0; j <  <%=obj.BlockId + '_con'%>::SYS_nSysCacheline /  <%=obj.BlockId + '_con'%>::WBE; j++) begin
                                    <%=obj.BlockId + '_con'%>::sfi_data_t tmp;
                                    assert(std::randomize(tmp))
                                    else begin
                                        uvm_report_error("SYS BFM SEQ", "Failure to randomize tmp", UVM_NONE);
                                    end
                                    m_random_data[j] = tmp;
                                    m_random_be[j]   = '1;
                                    foreach (m_random_be[i]) begin
                                        if ($urandom_range(1,100) < prob_dtrreq_data_err_inj) begin
                                            m_random_be[i] = '0;
                                        end
                                    end
                                end
                                for (int i = 0; i < coher_result_final.ST; i++) begin

                                    // Find unused transID value
                                    // Check if all transID values are in use
                                    fork
                                        begin
                                            <%=obj.BlockId + '_con'%>::sfi_mst_transId_t m_tmp_transId;
                                            sfi_seq_item                                 m_tmp_dtr_item;
                                            bit                                          m_sending_dtr_dat_vis;
                                            if((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnUnq) || 
                                               (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnVld) ||
                                               (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdClnInv) 
                                            ) begin
                                                m_sending_dtr_dat_vis = 1;
                                            end

                                            if (((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCpy) || 
                                                (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCln) || 
                                                (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdVld) || 
                                                (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdUnq)) &&
                                                ( dtrdatavis_trspt_sec_err_inj || dtrdatavis_trspt_tmo_err_inj || 
                                                dtrdatavis_trspt_disc_err_inj)) begin
                                                m_sending_dtr_dat_vis = 1;
                                            end

                                            s_transid.get();
                                            if (m_trans_id_array.num() == 2**<%=obj.BlockId + '_con'%>::MST_WTRANSID - 1) begin
                                                @e_sfi_mst_transId_freeup;
                                            end
                                            flag = 0;
                                            do begin
                                                m_tmp_transId = $urandom_range(2**<%=obj.BlockId + '_con'%>::MST_WTRANSID - 1);
                                                if (!m_trans_id_array.exists(m_tmp_transId)) begin
                                                    flag = 1;
                                                    m_trans_id_array[m_tmp_transId] = 1;
                                                end
                                            end while (!flag);
                                            s_transid.put();
                                            m_tmp_dtr_item = sfi_seq_item::type_id::create("m_tmp_dtr_item");
                                            m_tmp_dtr_item.m_has_req              = 1;
                                            m_tmp_dtr_item.req_pkt.req_opc      = <%= obj.BlockId + '_con'%>::WRITE;
                                            m_tmp_dtr_item.req_pkt.req_burst    = (!m_sending_dtr_dat_vis) ? <%= obj.BlockId + '_con'%>::WRAP : <%= obj.BlockId + '_con'%>::INCR;
                                            m_tmp_dtr_item.req_pkt.req_length   = (!m_sending_dtr_dat_vis) ? <%= obj.BlockId + '_con'%>::SYS_nSysCacheline-1 : 0;
                                            m_tmp_dtr_item.req_pkt.req_transId  = m_tmp_transId;
                                            if (m_sending_dtr_dat_vis) begin
                                                foreach (m_random_be[i]) begin
                                                    m_random_be[i] = '0;
                                                end
                                            end
                                            m_tmp_dtr_item.req_pkt.req_data     = m_random_data;
                                            m_tmp_dtr_item.req_pkt.req_be       = m_random_be;
                                            m_tmp_dtr_item.req_pkt.req_sfiSlvId = m_cmd_trans.cmd_req.req_aiu_id;
                                            <% if (obj.wSecurityAttribute > 0) { %>                                             
                                                m_tmp_dtr_item.req_pkt.req_security = $urandom_range(0, 2**<%=obj.wSecurityAttribute%>); 
                                            <% } %>                                                

                                            <% if (obj.wPriorityLevel > 0) { %>
                                                m_tmp_dtr_item.req_pkt.req_urgency  = $urandom_range(0, 2**<%=obj.wPriorityLevel%>) ; 
                                            <% } %>                                  

                                            // Added by Muffadal on 10/17/2016
                                            // As per the new spec DtrDataVis should be sent for  
                                            // CmdCldUniq, CmdClnVld, CmdClnInv  
                                            // For all other txns if SD equal one then send DtrDtaDty else 
                                            // always send Dtr
                                            if (m_sending_dtr_dat_vis) begin
                                                m_tmp_dtr_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_LSB]         = <%=obj.BlockId + '_con'%>::DTR_SYS_VIS; 

                                                if ($urandom_range(0,100) < prob_dtrdatavis_addr_err_inj) begin
                                                    m_tmp_dtr_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_DTR_ERR_RESULT_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_DTR_ERR_RESULT_LSB] = <%=obj.BlockId + '_con'%>::eErrResAddrErr;
                                                end else if(dtrdatavis_trspt_sec_err_inj) begin
                                                    m_tmp_dtr_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_DTR_ERR_RESULT_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_DTR_ERR_RESULT_LSB] = <%=obj.BlockId + '_con'%>::eErrResTransportErr;
                                                end else if(dtrdatavis_trspt_disc_err_inj) begin
                                                    m_tmp_dtr_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_DTR_ERR_RESULT_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_DTR_ERR_RESULT_LSB] = <%=obj.BlockId + '_con'%>::eErrResTransportErr;
                                                end else if(dtrdatavis_trspt_tmo_err_inj) begin
                                                    m_tmp_dtr_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_DTR_ERR_RESULT_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_DTR_ERR_RESULT_LSB] = <%=obj.BlockId + '_con'%>::eErrResTransportErr;
                                                end
                                            end
                                            //else if (((m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCpy)    ||
                                            //    (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdCln)     ||
                                            //    (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdVld)     ||
                                            //    (m_cmd_trans.cmd_req.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdRdUnq))    &&
                                            //    coher_result_final.SD == 1
                                            //) begin
                                            //    if (isDTRDatDtyNeeded) begin
                                            //        m_tmp_dtr_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_LSB]         = <%=obj.BlockId + '_con'%>::DTR_DATA_DTY; 
                                            //    end
                                            //    else begin
                                            //        m_tmp_dtr_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_LSB]         = <%=obj.BlockId + '_con'%>::DTR_DATA_CLN; 
                                            //    end
                                            //end 
                                            else begin
                                                if (isDTRDatDtyNeeded) begin
                                                    m_tmp_dtr_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_LSB]         = <%=obj.BlockId + '_con'%>::DTR_DATA_DTY; 
                                                    isDTRDatDtyNeeded = 0;
                                                end
                                                else begin
                                                    m_tmp_dtr_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_LSB]         = <%=obj.BlockId + '_con'%>::DTR_DATA_CLN; 
                                                end
                                                // Optionally sending non-zero DTR offset
                                                if (coher_result_final.ST == 1 && <%=unit_with_bigger_bus_width%>) begin
                                                    m_tmp_dtr_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_OFFSET_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_OFFSET_LSB] = $urandom_range(0,<%=obj.wXData%>/32-1); 
                                                end
                                            end
                                            m_tmp_dtr_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_TRANS_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_TRANS_ID_LSB] = m_cmd_trans.cmd_req.req_aiu_trans_id; 
                                            m_tmp_dtr_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_AIU_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_AIU_ID_LSB] = m_cmd_trans.cmd_req.req_aiu_id; 
                                            m_sfi_dtr_req_q.push_back(m_tmp_dtr_item);
                                            ->e_sfi_dtr_req_q;
                                        end
                                    join_none
                                end
                            end
                            else if (localIsDVM == 1 &&
                                     m_cmd_trans.cmd_req.cache_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT] == 1'b1
                            ) begin
                                //for (int i = 0; i < num_dvm_capable_aius - 1; i++) begin
                                for (int i = 0; i < num_dvm_capable_aius - coher_result_dvm - 1; i++) begin

                                    // Find unused transID value
                                    // Check if all transID values are in use
                                    fork
                                        begin
                                            <%=obj.BlockId + '_con'%>::sfi_mst_transId_t m_tmp_transId;
                                            sfi_seq_item                                 m_tmp_dtr_item;
                                            s_transid.get();
                                            if (m_trans_id_array.num() == 2**<%=obj.BlockId + '_con'%>::MST_WTRANSID - 1) begin
                                                @e_sfi_mst_transId_freeup;
                                            end
                                            flag = 0;
                                            do begin
                                                m_tmp_transId = $urandom_range(2**<%=obj.BlockId + '_con'%>::MST_WTRANSID - 1);
                                                if (!m_trans_id_array.exists(m_tmp_transId)) begin
                                                    flag = 1;
                                                    m_trans_id_array[m_tmp_transId] = 1;
                                                end
                                            end while (!flag);
                                            s_transid.put();
                                            m_tmp_dtr_item = sfi_seq_item::type_id::create("m_tmp_dtr_item");
                                            m_tmp_dtr_item.m_has_req            = 1;
                                            m_tmp_dtr_item.req_pkt.req_opc      = <%= obj.BlockId + '_con'%>::WRITE;
                                            m_tmp_dtr_item.req_pkt.req_burst    = <%= obj.BlockId + '_con'%>::INCR;
                                            m_tmp_dtr_item.req_pkt.req_length   = 0;
                                            m_tmp_dtr_item.req_pkt.req_transId  = m_tmp_transId;
                                            //m_tmp_dtr_item.req_pkt.req_data     = $urandom_range(0,'hff);
                                            //m_tmp_dtr_item.req_pkt.req_be       = $urandom_range(0,1);
<% if (obj.wSecurityAttribute > 0) { %>                                             
                                            m_tmp_dtr_item.req_pkt.req_security = m_cmd_trans.cmd_req.req_security; 
<% } %>                                                
                                            m_tmp_dtr_item.req_pkt.req_sfiSlvId = m_cmd_trans.cmd_req.req_aiu_id;
                                            m_tmp_dtr_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_LSB]      = <%=obj.BlockId + '_con'%>::DTR_DVM_CMP; 
                                            m_tmp_dtr_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_TRANS_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_TRANS_ID_LSB] = $urandom(); 
                                            m_tmp_dtr_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_AIU_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_ADDR_REQ_AIU_ID_LSB]     = m_cmd_trans.cmd_req.req_aiu_id; 
                                            m_sfi_dtr_req_q.push_back(m_tmp_dtr_item);
                                            ->e_sfi_dtr_req_q;
                                        end
                                    join_none
                                end
                            end
                        end : create_dtr_pkt
                    join
                end
            end
        end : process_cmd_req
        begin : send_str_req_delay
            delay_str_req = 0;
            if (!dis_delay_str_req) begin
                forever begin
                    #(delay_str_req_val * 1ns);
                    delay_str_req = ~delay_str_req;
                    if (gen_more_streaming_traffic) begin
                        delay_str_req_val = $urandom_range(100,1000);
                    end
                    else begin
                        delay_str_req_val = $urandom_range(1,1000);
                    end
                end
            end
        end : send_str_req_delay
        begin : send_str_req
            forever begin
                if (delay_str_req) begin
                    wait(delay_str_req == 0);
                end
                if (m_sfi_str_req_q.size == 0) begin
                    @e_sfi_str_req_q;
                end
                else begin
                    sfi_seq_item_addr_t m_tmp_seq_item;
                    int                 m_tmp_q[$];
                    int                 index;
                    time                t_index;

                    m_sfi_str_req_q.shuffle();
                    m_tmp_seq_item = m_sfi_str_req_q[0];
                    m_tmp_q = {};
                    m_tmp_q = m_sfi_str_req_q.find_index with (item.m_addr[$size(item.m_addr)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_tmp_seq_item.m_addr[$size(item.m_addr)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]);
                    if (m_tmp_q.size() == 0) begin
                        uvm_report_error("SYS BFM SEQ", $sformatf("TB Error: Not possible to reach here for address 0x%0x", m_tmp_seq_item.m_addr), UVM_NONE); 
                    end
                    else if (m_tmp_q.size() > 1) begin
                        index = m_tmp_q[0];
                        t_index = m_sfi_str_req_q[m_tmp_q[0]].t_smi_ndp_ready;
                        for (int i = 1; i < m_tmp_q.size(); i++) begin
                            if (t_index > m_sfi_str_req_q[m_tmp_q[i]].t_smi_ndp_ready) begin
                                t_index = m_sfi_str_req_q[m_tmp_q[i]].t_smi_ndp_ready;
                                index   = m_tmp_q[i];
                            end
                        end
                    end
                    else begin
                        index = m_tmp_q[0];
                    end
                    m_tmp_seq_item = m_sfi_str_req_q[index];
                    m_sfi_str_req_q.delete(index);
                    uvm_report_info("SYS BFM DBG", $sformatf("sending str req for aiu trans id %0d coher result %0d", m_tmp_seq_item.m_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_LSB], m_tmp_seq_item.m_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_COHER_RESULT_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_COHER_RESULT_LSB]), UVM_HIGH);
                    m_sfi_mst_seq_str_req.m_seq_item           = sfi_seq_item::type_id::create("m_seq_item");
                    m_sfi_mst_seq_str_req.m_seq_item           = m_tmp_seq_item.m_seq_item;
                    m_sfi_mst_seq_str_req.m_seq_item.m_has_req = 1;
                    m_sfi_mst_seq_str_req.return_response(m_tmp_seq_item.m_seq_item, m_sfi_mst_req_seqr);
                    // Pushing the request onto mst_req_q to wait for response
                    m_sfi_mst_req_q.push_back(m_tmp_seq_item.m_seq_item);
                    //if (m_sfi_mst_req_q.size() > <%=obj.nPendingTransactions%> + 1) begin
                    //    uvm_report_error("SYS BFM SEQ", $sformatf("There are more than nPendingTransactions sent on AIU's SFI slave interface without a SFI response (nPendingTrans: %0d Outstanding requests: %0d", <%=obj.nPendingTransactions%>, m_sfi_mst_req_q.size()), UVM_NONE);
                    //end
                    ->e_sfi_mst_req_q;
                end
            end
        end : send_str_req
        begin : send_dtr_req_delay
            delay_dtr_req = 0;
            if (!dis_delay_dtr_req) begin
                forever begin
                    #(delay_dtr_req_val * 1ns);
                    delay_dtr_req = ~delay_dtr_req;
                    if (gen_more_streaming_traffic) begin
                        delay_dtr_req_val = $urandom_range(100,1000);
                    end
                    else begin
                        delay_dtr_req_val = $urandom_range(1,1000);
                    end
                end
            end
        end : send_dtr_req_delay
        begin : send_dtr_req
            forever begin
                if (delay_dtr_req) begin
                    wait(delay_dtr_req == 0);
                end
                if (m_sfi_dtr_req_q.size == 0) begin
                    @e_sfi_dtr_req_q;
                end
                else begin
                    sfi_seq_item m_tmp_seq_item;

                    m_sfi_dtr_req_q.shuffle();
                    m_tmp_seq_item = m_sfi_dtr_req_q[0];
                    m_sfi_dtr_req_q.delete(0);
                    m_sfi_mst_seq_dtr_req.m_seq_item = sfi_seq_item::type_id::create("m_seq_item");
                    m_sfi_mst_seq_dtr_req.m_seq_item = m_tmp_seq_item;
                    m_sfi_mst_seq_dtr_req.m_seq_item.m_has_req = 1;
                    m_sfi_mst_seq_dtr_req.return_response(m_tmp_seq_item, m_sfi_mst_req_seqr);
                    // Pushing the request onto mst_req_q to wait for response
                    m_sfi_mst_req_q.push_back(m_tmp_seq_item);
                    //if (m_sfi_mst_req_q.size() > <%=obj.nPendingTransactions%> + 1) begin
                    //    uvm_report_error("SYS BFM SEQ", $sformatf("There are more than nPendingTransactions sent on AIU's SFI slave interface without a SFI response (nPendingTrans: %0d Outstanding requests: %0d", <%=obj.nPendingTransactions%>, m_sfi_mst_req_q.size()), UVM_NONE);
                    //end
                    ->e_sfi_mst_req_q;
                end
            end
        end : send_dtr_req
<% if (obj.fnNativeInterface == "ACE" ||
      (obj.isBridgeInterface && obj.useIoCache)
) { %>    
        begin : send_snp_req
            forever begin
                if (m_sfi_snp_req_q.size == 0) begin
                    @e_sfi_snp_req_q;
                end
                else begin
                    sfi_seq_item m_tmp_seq_item;
                    bit          flag;
                    int          count_snoops;
                    int          count_dvm_snoops;
                    <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry;

                    flag = 0;
                    m_sfi_snp_req_q.shuffle();
                    m_tmp_seq_item = m_sfi_snp_req_q[0];
                    m_snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_tmp_seq_item.req_pkt);
                    do begin
                        flag             = 0;
                        count_snoops     = 0;
                        count_dvm_snoops = 0;
                        foreach(m_sfi_mst_req_q[i]) begin
                            if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(m_sfi_mst_req_q[i].req_pkt)) begin
                                <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry_tmp = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_sfi_mst_req_q[i].req_pkt);
                                if (m_snp_req_entry_tmp.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
                                    count_dvm_snoops++;
                                end
                                else begin
                                    count_snoops++;
                                end
                            end
                        end
                        if (m_snp_req_entry.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
                            if (count_dvm_snoops >= <%=obj.DceInfo[0].DvmInfo.nDvmSnpInFlight%>) begin
                                @e_sfi_mst_transId_freeup;
                            end
                            else begin
                                flag = 1;
                            end
                        end
    else begin
                            if (count_snoops > <%=obj.nDCEs%> * <%=obj.SnoopFilterInfo[id_snoop_filter_slice].CmpInfo.nSnpInFlight%> - 1) begin
                                @e_sfi_mst_transId_freeup;
                            end
                            else begin
                                flag = 1;
                            end
                        end
                    end while (!flag);
                    m_sfi_snp_req_q.delete(0);
                    ->e_sfi_snp_req_del_q;
                    m_sfi_mst_seq_snp_req.m_seq_item           = sfi_seq_item::type_id::create("m_seq_item");
                    m_sfi_mst_seq_snp_req.m_seq_item           = m_tmp_seq_item;
                    m_sfi_mst_seq_snp_req.m_seq_item.m_has_req = 1;
                    //wait(pause_snoops == 0);
                   // Pushing the request onto mst_req_q to wait for response
                    m_sfi_mst_req_q.push_back(m_tmp_seq_item);
                    //if (m_sfi_mst_req_q.size() > <%=obj.nPendingTransactions%> + 1) begin
                    //    uvm_report_error("SYS BFM SEQ", $sformatf("There are more than nPendingTransactions sent on AIU's SFI slave interface without a SFI response (nPendingTrans: %0d Outstanding requests: %0d", <%=obj.nPendingTransactions%>, m_sfi_mst_req_q.size()), UVM_NONE);
                    //end
                    ->e_sfi_mst_req_q;
                    //uvm_report_info("SYS BFM SEQ DEBUG", $sformatf("Sending snoop to address 0x%0x security 0x%0x snoop type 0x%0x", m_tmp_seq_item.req_pkt.req_addr, m_tmp_seq_item.req_pkt.req_security, m_tmp_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SYS_wSysMsgType-1:0]), UVM_LOW); 
                    m_sfi_mst_seq_snp_req.return_response(m_tmp_seq_item, m_sfi_mst_req_seqr);
                end
            end
        end : send_snp_req
        begin : agent_iso_mode
            forever begin
                e_agent_isolation_mode_flip.wait_trigger();
                pause_snoops = 1;
                e_agent_isolation_mode_flip.wait_trigger();
                pause_snoops = 0;
            end
        end : agent_iso_mode
        begin : create_snoop_req
            if (<%=obj.BlockId + '_con'%>::SYS_nSysAIUs > 1) begin
                int count;
                int count_outstanding_snps = 0;
                // Waiting till there are some CmdReqs that have already been sent to system BFM
                if (!($test$plusargs("snoop_bw_test"))) begin
                    wait (m_addr_history.size() > ((k_num_addr > 25) ? 25 : k_num_addr));
                end
                <% if(obj.isBridgeInterface && obj.useIoCache ) {%>
                if (($test$plusargs("snoop_bw_test"))) begin
                    wait (start_snoop_traffic==1);
                end
                <%}%>

                while (snoop_count < k_num_snp) begin
                    <%=obj.BlockId + '_con'%>::sfi_addr_security_t m_tmp_addr;
                    int                                            tmp_indx_prev_addr[$];
                    int                                            tmp_indx_cmd_req_addr[$];
                    int                                            wt_tmp_snp_prev_addr;
                    int                                            wt_tmp_snp_cmd_req_addr;
                    <%=obj.BlockId + '_con'%>::sfi_mst_transId_t   m_tmp_transId;
                    <%=obj.BlockId + '_con'%>::MsgType_t           snp;
                    sfi_seq_item                                   m_tmp_snp_item;
                    bit                                            flag;
                    bit                                            hit_full_snp_count;
                    int                                            wt_dvm_tmp;
                    int                                            wt_snp_recall_tmp;
                    int                                            count_dvm;
                    aiu_id_t                                       m_aiu_id_q[$];
                    aiu_id_t                                       m_aiu_id_final;
                    <%=obj.BlockId + '_con'%>::sfi_data_t          tmp[];
                    int                                            m_random_aiu_id_array[];
                    int                                            index[$];
    
                    tmp_indx_prev_addr = {};
                    tmp_indx_cmd_req_addr = {};
                    wait(pause_snoops == 0);

                    <% if((obj.testBench == "cbi") && obj.isBridgeInterface && obj.useIoCache) {%>

                    foreach (m_ncbu_cache_handle.m_ncbu_cache_q[i]) begin
                        int m_tmp_qA[$];
                        m_tmp_qA = {};
                        m_tmp_qA = m_req_in_process.find_first_index with (item.m_addr[$size(item.m_addr)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == {m_ncbu_cache_handle.m_ncbu_cache_q[i].security,m_ncbu_cache_handle.m_ncbu_cache_q[i].addr[$size(m_ncbu_cache_handle.m_ncbu_cache_q[i].addr)-2:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]});
                        if (m_tmp_qA.size == 0) begin
                            int m_tmp_qB[$];
                            tmp_indx_prev_addr.push_back(i);
                        end
                    end

                    // TODO: Add queue with CmdReq messages currently sent 
                    //foreach (m_processing_dtw_req_q[i]) begin
                    //    int m_tmp_qA[$];
                    //    m_tmp_qA = {};
                    //    m_tmp_qA = m_req_in_process.find_first_index with (item.m_addr[$size(item.m_addr)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == {m_processing_dtw_req_q[i].req_pkt.req_security,m_processing_dtw_req_q[i].req_pkt.req_addr[$size(m_processing_dtw_req_q[i].req_pkt.req_addr)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]});
                    //    if (m_tmp_qA.size == 0) begin
                    //        tmp_indx_cmd_req_addr.push_back(i);
                    //    end
                    //end

                    wt_tmp_snp_prev_addr    = (tmp_indx_prev_addr.size() > 0) ? wt_snp_prev_addr : 0;
                    wt_tmp_snp_cmd_req_addr = (tmp_indx_cmd_req_addr.size() > 0) ? wt_snp_cmd_req_addr : 0;
                    randcase
                        wt_tmp_snp_prev_addr: 
                        begin
                            tmp_indx_prev_addr.shuffle();
                            m_tmp_addr = {m_ncbu_cache_handle.m_ncbu_cache_q[tmp_indx_prev_addr[0]].security, m_ncbu_cache_handle.m_ncbu_cache_q[tmp_indx_prev_addr[0]].addr};
                        end
                        wt_tmp_snp_cmd_req_addr: 
                        begin
                            tmp_indx_cmd_req_addr.shuffle();
                            m_tmp_addr = {m_processing_dtw_req_q[tmp_indx_cmd_req_addr[0]].req_pkt.req_security, m_processing_dtw_req_q[tmp_indx_cmd_req_addr[0]].req_pkt.req_addr};
                        
                            //`uvm_info("DEBUG", $psprintf("Generated Addr:0x%0h Security:%0d", m_processing_dtw_req_q[tmp_indx_cmd_req_addr[0]].req_pkt.req_addr, m_processing_dtw_req_q[tmp_indx_cmd_req_addr[0]].req_pkt.req_security),UVM_NONE)
                        end
                        wt_snp_random_addr:
                        begin
                            bit done = 0;
                            ace_cache_line_model m_tmp[$]; //Empty cache handle
                            do begin
                                int m_tmp_qC[$];
                                bit [63:0] m_tmp_qH[$];

                                //assert(std::randomize(m_tmp_addr));
                                m_tmp_addr = m_addr_mgr.req_cacheline(1, m_tmp, m_tmp_qH, .gen_new_address(1'b1));
                                m_tmp_addr[$clog2(<%=obj.BlockId + '_con'%>::WDATA/8)-1:0] = '0;
                                m_tmp_qC = {};
                                m_tmp_qC = m_addr_history.find_first_index with (item[$size(item)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_tmp_addr[$size(m_tmp_addr)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]);
                                done = (m_tmp_qC.size() == 0);
                            end while (!done);
                        end
                    endcase
                    
                    <%}else{%>
                    foreach (m_addr_history[i]) begin
                        int m_tmp_qA[$];
                        m_tmp_qA = {};
                        m_tmp_qA = m_req_in_process.find_first_index with (item.m_addr[$size(item.m_addr)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_addr_history[i][$size(m_addr_history[i])-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]);
                        if (m_tmp_qA.size == 0) begin
                            int m_tmp_qB[$];
                            m_tmp_qB = {};
                            m_tmp_qB = m_sfi_cmd_req_q.find_first_index with (item.m_seq_item.req_pkt.req_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_addr_history[i][WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]
<% if (obj.wSecurityAttribute > 0) { %>                                             
                            &&  item.m_seq_item.req_pkt.req_security == m_addr_history[i][$size(m_addr_history[i])-1 : $size(m_addr_history[i]) - <%=obj.wSecurityAttribute%>]
<% } %>                                                
                            );
                            if (m_tmp_qB.size > 0) begin
                                tmp_indx_cmd_req_addr.push_back(i);
                            end
                            else if (m_tmp_qB.size == 0) begin
                                tmp_indx_prev_addr.push_back(i);
                            end
                        end
                    end
                    wt_tmp_snp_prev_addr    = (tmp_indx_prev_addr.size() > 0) ? wt_snp_prev_addr : 0;
                    wt_tmp_snp_cmd_req_addr = (tmp_indx_cmd_req_addr.size() > 0) ? wt_snp_cmd_req_addr : 0;
                    randcase
                        wt_tmp_snp_prev_addr: 
                        begin
                            tmp_indx_prev_addr.shuffle();
                            m_tmp_addr = m_addr_history[tmp_indx_prev_addr[0]];
                        end
                        wt_tmp_snp_cmd_req_addr: 
                        begin
                            tmp_indx_cmd_req_addr.shuffle();
                            m_tmp_addr = m_addr_history[tmp_indx_cmd_req_addr[0]];
                        end
                        wt_snp_random_addr:
                        begin
                            bit done = 0;
                            ace_cache_line_model m_tmp[$]; //Empty cache handle
                            do begin
                                int m_tmp_qC[$];
                                bit [63:0] m_tmp_qH[$];

                                //assert(std::randomize(m_tmp_addr));
                                m_tmp_addr = m_addr_mgr.req_cacheline(1, m_tmp, m_tmp_qH, .gen_new_address(1'b1));
                                m_tmp_addr[$clog2(<%=obj.BlockId + '_con'%>::WDATA/8)-1:0] = '0;
                                m_tmp_qC = {};
                                m_tmp_qC = m_addr_history.find_first_index with (item[$size(item)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_tmp_addr[$size(m_tmp_addr)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]);
                                done = (m_tmp_qC.size() == 0);
                            end while (!done);
                        end
                    endcase

                    <%}%>
                    m_processing_snpreq_addr_q.push_back(m_tmp_addr);
                    count_dvm = 0;
                    foreach (m_sfi_mst_req_q[i]) begin
                        if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(m_sfi_mst_req_q[i].req_pkt)) begin
                            <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_sfi_mst_req_q[i].req_pkt);
                            if (m_snp_req_entry.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
                                count_dvm++;
                            end
                        end
                    end
                    foreach (m_sfi_snp_req_q[i]) begin
                        <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_sfi_snp_req_q[i].req_pkt);
                        if (m_snp_req_entry.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
                            count_dvm++;
                        end
                    end
                    if ((count_dvm >= <%=obj.DceInfo[0].DvmInfo.nDvmSnpInFlight%> ||
                         num_dvm_capable_aius < 2
                     ) || 
                     <%=obj.nDvmCmpInFlight%> == 0
                    ) begin
                        wt_dvm_tmp = 0;
                    end
                    else begin
                        wt_dvm_tmp = wt_snp_dvm_msg;
                    end 
                    if ("<%=obj.SnoopFilterInfo[id_snoop_filter_slice].fnFilterType%>" == "NULL") begin
                        wt_snp_recall_tmp = 0;
                    end
                    else begin
                        wt_snp_recall_tmp = wt_snp_recall;
                    end
                    randcase
                        wt_snp_inv        : snp = <%=obj.BlockId + '_con'%>::SNP_INV;
                        wt_snp_cln_dtr    : snp = <%=obj.BlockId + '_con'%>::SNP_CLN_DTR; 
                        wt_snp_vld_dtr    : snp = <%=obj.BlockId + '_con'%>::SNP_VLD_DTR;
                        wt_snp_inv_dtr    : snp = <%=obj.BlockId + '_con'%>::SNP_INV_DTR;
                        wt_snp_cln_dtw    : snp = <%=obj.BlockId + '_con'%>::SNP_CLN_DTW;
                        wt_snp_inv_dtw    : snp = <%=obj.BlockId + '_con'%>::SNP_INV_DTW;
                        wt_snp_recall_tmp : snp = <%=obj.BlockId + '_con'%>::SNP_RECALL;
                        wt_dvm_tmp        : snp = <%=obj.BlockId + '_con'%>::SNP_DVM_MSG;
                    endcase
                    // Check if address is already being processed by AIU. If so, wait
                    if (!(snp == <%=obj.BlockId + '_con'%>::SNP_DVM_MSG)) begin
                        do begin
                            int m_tmp_q[$];
                            int index;
                            flag = 1;
                            foreach (m_sfi_mst_req_q[i]) begin
                                if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(m_sfi_mst_req_q[i].req_pkt)) begin
                                    <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_sfi_mst_req_q[i].req_pkt);
                                    if (m_tmp_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_snp_req_entry.cache_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]
<% if (obj.wSecurityAttribute > 0) { %>                                             
                                    && m_tmp_addr[$size(m_tmp_addr) - 1 : $size(m_tmp_addr) - <%=obj.wSecurityAttribute%>] == m_snp_req_entry.req_security    
<% } %>                                                
                                    ) begin
                                        flag = 0;
                                    end
                                end
                            end
                            if (m_smi_str_pending_addr_h.num() > 0) begin
                                bit tmp_flag = 0;
                                <%=obj.BlockId + '_con'%>::sfi_addr_security_t m_tmp_addr_0;
                                m_smi_str_pending_addr_h.first(index);
                                do begin
                                    int index_last;
                                    m_tmp_addr_0 = m_smi_str_pending_addr_h[index];
                                    if (m_tmp_addr_0[$size(m_tmp_addr_0)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_tmp_addr[$size(m_tmp_addr)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]) begin
                                        flag = 0;
                                        break;
                                    end
                                    m_smi_str_pending_addr_h.last(index_last);
                                    if (index == index_last) begin
                                        tmp_flag = 1;
                                    end
                                    else begin
                                        m_smi_str_pending_addr_h.next(index); 
                                    end
                                end while (!tmp_flag);
                            end
                            m_tmp_q = {};
                            m_tmp_q = m_sfi_snp_req_q.find_first_index with (item.req_pkt.req_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_tmp_addr[WSMIADDR-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]
<% if (obj.wSecurityAttribute > 0) { %>                                             
                            && item.req_pkt.req_security == m_tmp_addr[$size(m_tmp_addr) - 1 : $size(m_tmp_addr) - <%=obj.wSecurityAttribute%>]
<% } %>                                                
                            );
                            if (m_tmp_q.size() > 0) begin
                                flag = 0;
                            end
                            m_tmp_q = {};
                            m_tmp_q = m_processing_cmdreq_addr_q.find_first_index with (item[$size(item)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] == m_tmp_addr[$size(m_tmp_addr)-1:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]);
                            if (m_tmp_q.size() > 0) begin
                                flag = 0;
                            end
                            if (!flag) begin
                                @e_sfi_mst_transId_freeup;
                            end
                        end while (!flag);
                    end
                    s_transid.get();
                    if (m_trans_id_array.num() == 2**<%=obj.BlockId + '_con'%>::MST_WTRANSID - 1) begin
                        @e_sfi_mst_transId_freeup;
                    end
                    flag = 0;
                    do begin
                        m_tmp_transId = $urandom_range(2**<%=obj.BlockId + '_con'%>::MST_WTRANSID - 1);
                        if (!m_trans_id_array.exists(m_tmp_transId)) begin
                            flag = 1;
                            m_trans_id_array[m_tmp_transId] = 1;
                        end
                    end while (!flag);
                    s_transid.put();
                    // Finding a unique {aiu_id, aiu_trans_id} pair
                    m_aiu_id_q = {};
                    foreach (m_sfi_mst_req_q[i]) begin
                        if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(m_sfi_mst_req_q[i].req_pkt)) begin
                            <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_sfi_mst_req_q[i].req_pkt);
                            aiu_id_t                                 m_aiu_id_tmp;
    
                            m_aiu_id_tmp.m_aiu_id       = m_snp_req_entry.req_aiu_id;
                            m_aiu_id_tmp.m_aiu_trans_id = m_snp_req_entry.req_aiu_trans_id;
                            m_aiu_id_q.push_back(m_aiu_id_tmp);
                        end
                    end
                    foreach(m_sfi_snp_req_q[i]) begin
                        aiu_id_t m_aiu_id_tmp;
                        m_aiu_id_tmp.m_aiu_id       = m_sfi_snp_req_q[i].req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_LSB];
                        m_aiu_id_tmp.m_aiu_trans_id = m_sfi_snp_req_q[i].req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_LSB];
                        m_aiu_id_q.push_back(m_aiu_id_tmp);
                    end
                    flag = 0;
                    count = 0;
                    do begin
                        int                                     m_tmp_q[$];
                        <%=obj.BlockId + '_con'%>::AIUTransID_t m_aiu_trans_id_tmp;
                        assert(std::randomize(m_aiu_trans_id_tmp))
                        else begin
                            uvm_report_error("SYS BFM SEQ", "Failure to randomize m_aiu_id_final.m_aiu_trans_id", UVM_NONE);
                        end
                        m_aiu_id_final.m_aiu_trans_id = m_aiu_trans_id_tmp;
                        m_aiu_id_final.m_aiu_id = $urandom_range(1, <%=obj.BlockId + '_con'%>::SYS_nSysAIUs - 1);
                        if (m_aiu_id_final.m_aiu_id == <%=obj.Id%> &&
                            <%=obj.Id%> !== 0
                        ) begin
                            m_aiu_id_final.m_aiu_id = 0;
                        end
                        flag = 1;
                        m_tmp_q = m_aiu_id_q.find_first_index with (item == m_aiu_id_final);
                        if (m_tmp_q.size() > 0) begin
                            flag = 0;
                        end
                        count++;
                        if (count > 100) begin
                            @e_sfi_mst_transId_freeup;
                            //uvm_report_error("SYS BFM SEQ", "TB Error: Infinite loop possibility while trying to randomize aiu_id and aiu_trans_id", UVM_NONE);
                        end
                    end while (!flag);
                    m_tmp_snp_item                    = sfi_seq_item::type_id::create("m_tmp_snp_item");
                    m_tmp_snp_item.m_has_req          = 1;
                    m_tmp_snp_item.req_pkt.req_opc    = <%= obj.BlockId + '_con'%>::WRITE;
                    if (snp == <%=obj.BlockId + '_con'%>::SNP_DVM_MSG) begin
                        bit [2:0] tmp_type;
                        bit legal;
                        int beat_num = 0;
                        int wt_dvm_sync_tmp;
                        int dvm_count;
                        m_tmp_snp_item.req_pkt.req_length = 15; 
                        if (<%=obj.BlockId + '_con'%>::WDATA < 128) begin
                            tmp                             = new[128/<%=obj.BlockId + '_con'%>::WDATA]; 
                            m_tmp_snp_item.req_pkt.req_data = new[128/<%=obj.BlockId + '_con'%>::WDATA];
                            m_tmp_snp_item.req_pkt.req_be   = new[128/<%=obj.BlockId + '_con'%>::WDATA];
                            beat_num = 64/<%=obj.BlockId + '_con'%>::WDATA;
                        end
                        else begin
                            tmp                             = new[1];
                            m_tmp_snp_item.req_pkt.req_data = new[1];
                            m_tmp_snp_item.req_pkt.req_be   = new[1];
                            beat_num = 0;
                        end
                        for (int j = 0; j <  tmp.size(); j++) begin
                            <%=obj.BlockId + '_con'%>::sfi_data_t tmp_var;
                            assert(std::randomize(tmp_var))
                            else begin
                                uvm_report_error("SYS BFM SEQ", "Failure to randomize tmp_var", UVM_NONE);
                            end
                            tmp[j]                           = tmp_var;
                            m_tmp_snp_item.req_pkt.req_be[j] = '1;
                        end
                        if (<%=obj.BlockId + '_con'%>::WDATA < 128) begin
                            m_tmp_snp_item.req_pkt.req_data               = tmp;
                            m_tmp_snp_item.req_pkt.req_data[0][1]         = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[beat_num][1]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][7]         = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[beat_num][7]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][15]        = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[beat_num][15] = 1'b0;
                            do begin
                                legal = 1;
                                assert(std::randomize(tmp_type))
                                else begin
                                    uvm_report_error("SYS BFM SEQ", "Failure to randomize tmp_type", UVM_NONE);
                                end
                                if (tmp_type == 3'b111 ||
                                    tmp_type == 3'b101
                                ) begin
                                    legal = 0;
                                end
                            end while (!legal);
                            m_tmp_snp_item.req_pkt.req_data[0][14]        = tmp_type[2];
                            m_tmp_snp_item.req_pkt.req_data[0][13]        = tmp_type[1];
                            m_tmp_snp_item.req_pkt.req_data[0][12]        = tmp_type[0];
                            m_tmp_snp_item.req_pkt.req_data[beat_num][14] = tmp_type[2];
                            m_tmp_snp_item.req_pkt.req_data[beat_num][13] = tmp_type[1];
                            m_tmp_snp_item.req_pkt.req_data[beat_num][12] = tmp_type[0];
                            m_tmp_snp_item.req_pkt.req_data[beat_num][2]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[beat_num][1]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[beat_num][0]  = 1'b0;
                        end
                        else begin
                            m_tmp_snp_item.req_pkt.req_data           = tmp;
                            m_tmp_snp_item.req_pkt.req_data[0][1]     = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][1+64]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][7]     = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][7+64]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][15]    = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][15+64] = 1'b0;
                            do begin
                                legal = 1;
                                assert(std::randomize(tmp_type))
                                else begin
                                    uvm_report_error("SYS BFM SEQ", "Failure to randomize tmp_type", UVM_NONE);
                                end
                                if (tmp_type == 3'b111 ||
                                    tmp_type == 3'b101
                                ) begin
                                    legal = 0;
                                end
                            end while (!legal);
                            //m_tmp_snp_item.req_pkt.req_data[14:12] = tmp_type[2:0];
                            //m_tmp_snp_item.req_pkt.req_data[78:76] = tmp_type[2:0];
                            //m_tmp_snp_item.req_pkt.req_data[66:64] = 3'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][14] = tmp_type[2];
                            m_tmp_snp_item.req_pkt.req_data[0][13] = tmp_type[1];
                            m_tmp_snp_item.req_pkt.req_data[0][12] = tmp_type[0];
                            m_tmp_snp_item.req_pkt.req_data[0][78] = tmp_type[2];
                            m_tmp_snp_item.req_pkt.req_data[0][77] = tmp_type[1];
                            m_tmp_snp_item.req_pkt.req_data[0][76] = tmp_type[0];
                            m_tmp_snp_item.req_pkt.req_data[0][66] = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][65] = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][64] = 1'b0;
                        end
                        dvm_count = 0;
                        foreach (dvm_sync_snoop_sent[i]) begin
                            if (dvm_sync_snoop_sent[i][0] == 1) begin
                                dvm_count++;
                            end
                        end
                        if (dvm_count < (num_dvm_source_aius - 1)) begin
                            wt_dvm_sync_tmp = wt_dvm_sync_snp;
                        end
                        else begin
                            wt_dvm_sync_tmp = 0;
                        end
                        m_tmp_snp_item.req_pkt.req_addr     = '0;
                        m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT]      = ($urandom_range(0,100) < wt_dvm_sync_tmp) ? 1 : 0;
                        m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_MULTIPART_BIT] = ($urandom_range(0,100) < wt_dvm_multipart_snp && m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT] == 0) ? 1 : 0;
                        uvm_report_info("SYS BFM SEQ DEBUG", $sformatf("Reached DVM snoop data 0x%0x address 0x%0x", m_tmp_snp_item.req_pkt.req_data[0], m_tmp_snp_item.req_pkt.req_addr), UVM_HIGH); 
                        if (m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_MULTIPART_BIT] == 1) begin
                            m_tmp_snp_item.req_pkt.req_data[0][0]               = 1'b1;
                        end
                        else begin
                            m_tmp_snp_item.req_pkt.req_data[0][0]               = 1'b0;
                        end
                        if (m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT] == 1) begin
                            foreach (dvm_sync_snoop_sent[i]) begin
                                if (dvm_sync_snoop_sent[i][0] == 0) begin
                                    m_random_aiu_id_array = {m_random_aiu_id_array, i+1};
                                end
                            end
                            if (m_random_aiu_id_array.size == 0) begin
                                uvm_report_error("SYSTEM BFM SNOOP", $sformatf("TB Error: Should have at least one entry in dvm_sync_snoop_sent be 0"), UVM_NONE);
                            end
                            m_random_aiu_id_array.shuffle();
                            dvm_sync_snoop_sent[m_random_aiu_id_array[0] - 1][0] = 1;
                            m_tmp_snp_item.req_pkt.req_data[0][15]               = 1'b1;
                        end
                    end
                    else begin
                        m_tmp_snp_item.req_pkt.req_length = 0; 
                        m_tmp_snp_item.req_pkt.req_addr   = m_tmp_addr;
                        // Randomly sending snoop address requests with non-data width aligned addresses
                        <% if (unit_with_smaller_bus_width) { %>
                            m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::WLOGXDATA-1:3] = $urandom;
                        <% } %>
                    end
                    m_tmp_snp_item.req_pkt.req_sfiSlvId = m_req_aiu_id;
                    m_tmp_snp_item.req_pkt.req_transId  = m_tmp_transId;
                    m_tmp_snp_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_LSB] = <%=obj.BlockId + '_con'%>::MsgType_t'(snp);
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        m_tmp_snp_item.req_pkt.req_security = m_tmp_addr[$size(m_tmp_addr) - 1: $size(m_tmp_addr) - <%=obj.wSecurityAttribute%>]; 
                    <% } %>                                                

                    <% if (obj.wPriorityLevel > 0) { %>
                        m_tmp_snp_item.req_pkt.req_urgency  = $urandom_range(0, 2**<%=obj.wPriorityLevel%>) ; 
                    <% } %>                                  
                    m_tmp_snp_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_LSB] = m_aiu_id_final.m_aiu_trans_id;
                    if (snp == <%=obj.BlockId + '_con'%>::SNP_DVM_MSG &&
                        m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT] == 1
                    ) begin
                        m_tmp_snp_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_LSB]     = m_random_aiu_id_array[0];
                    end
                    else begin
                        m_tmp_snp_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_LSB]     = m_aiu_id_final.m_aiu_id;
                    end
                    //`uvm_info("DEBUG", $psprintf("Sent Addr:0x%0h Security:%0d", m_tmp_snp_item.req_pkt.req_addr, m_tmp_snp_item.req_pkt.req_security),UVM_NONE)
                    m_sfi_snp_req_q.push_back(m_tmp_snp_item);
                    ->e_sfi_snp_req_q;
                    //Removing from processing_snpreq
                    index = {};
                    index = m_processing_snpreq_addr_q.find_first_index with (item == m_tmp_addr);
                    if (index.size == 0) begin
                        uvm_report_error("SYS BFM SEQ", $sformatf("TB Error: Could not find an entry in m_processing_snpreq_addr_q for address 0x%0x", m_tmp_addr), UVM_NONE);
                    end
                    else begin
                        m_processing_snpreq_addr_q.delete(index[0]);
                    end
                    uvm_report_info("SYS BFM SEQ DEBUG", $sformatf("Queueing snoop with type %1p and address 0x%0x", <%=obj.BlockId + '_con'%>::eMsgSNP'(snp), m_tmp_addr), UVM_HIGH); 
                    snoop_count++;
                    flag = 0;
                    hit_full_snp_count = 0;
                    do begin
                        count_outstanding_snps = 0;
                        foreach (m_sfi_mst_req_q[i]) begin
                            if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(m_sfi_mst_req_q[i].req_pkt)) begin
                                count_outstanding_snps++;
                            end
                        end
                        if ((count_outstanding_snps + m_sfi_snp_req_q.size() - 1) > k_snp_req_q_size) begin
                            @e_sfi_mst_transId_freeup;
                            hit_full_snp_count = 1;
                        end
                        else begin
                            flag = 1;
                        end
                    end while (!flag);
                    if (hit_full_snp_count) begin
                        k_snp_req_q_size = $urandom_range(4,<%=obj.nDCEs%> * <%=obj.SnoopFilterInfo[id_snoop_filter_slice].CmpInfo.nSnpInFlight%>);
                    end
                end
            end
        end : create_snoop_req 
<% } %>      
<% if (obj.fnNativeInterface == "ACE-LITE" &&
      obj.nDvmCmpInFlight > 0
) { %>    
        begin : send_snp_req
            forever begin
                if (m_sfi_snp_req_q.size == 0) begin
                    @e_sfi_snp_req_q;
                end
                else begin
                    sfi_seq_item m_tmp_seq_item;
                    bit          flag;
                    int          count_dvm_snoops;
                    <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry;

                    flag = 0;
                    m_sfi_snp_req_q.shuffle();
                    m_tmp_seq_item = m_sfi_snp_req_q[0];
                    m_snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_tmp_seq_item.req_pkt);
                    do begin
                        flag             = 0;
                        count_dvm_snoops = 0;
                        foreach(m_sfi_mst_req_q[i]) begin
                            if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(m_sfi_mst_req_q[i].req_pkt)) begin
                                <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry_tmp = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_sfi_mst_req_q[i].req_pkt);
                                if (m_snp_req_entry_tmp.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
                                    count_dvm_snoops++;
                                end
                            end
                        end
                        if (count_dvm_snoops >= <%=obj.DceInfo[0].DvmInfo.nDvmSnpInFlight%>) begin
                            @e_sfi_mst_transId_freeup;
                        end
                        else begin
                            flag = 1;
                        end
                    end while (!flag);
                    m_sfi_snp_req_q.delete(0);
                    ->e_sfi_snp_req_del_q;
                    m_sfi_mst_seq_snp_req.m_seq_item           = sfi_seq_item::type_id::create("m_seq_item");
                    m_sfi_mst_seq_snp_req.m_seq_item           = m_tmp_seq_item;
                    m_sfi_mst_seq_snp_req.m_seq_item.m_has_req = 1;
                   // Pushing the request onto mst_req_q to wait for response
                    wait(pause_snoops == 0);
                    m_sfi_mst_req_q.push_back(m_tmp_seq_item);
                    //if (m_sfi_mst_req_q.size() > <%=obj.nPendingTransactions%> + 1) begin
                    //    uvm_report_error("SYS BFM SEQ", $sformatf("There are more than nPendingTransactions sent on AIU's SFI slave interface without a SFI response (nPendingTrans: %0d Outstanding requests: %0d", <%=obj.nPendingTransactions%>, m_sfi_mst_req_q.size()), UVM_NONE);
                    //end
                    ->e_sfi_mst_req_q;
                    uvm_report_info("SYS BFM SEQ DEBUG", $sformatf("Sending snoop to address 0x%0x security 0x%0x snoop type 0x%0x", m_tmp_seq_item.req_pkt.req_addr, m_tmp_seq_item.req_pkt.req_security, m_tmp_seq_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SYS_wSysMsgType-1:0]), UVM_LOW); 
                    m_sfi_mst_seq_snp_req.return_response(m_tmp_seq_item, m_sfi_mst_req_seqr);
                end
            end
        end : send_snp_req
        begin : agent_iso_mode
            forever begin
                e_agent_isolation_mode_flip.wait_trigger();
                pause_snoops = 1;
                e_agent_isolation_mode_flip.wait_trigger();
                pause_snoops = 0;
            end
        end : agent_iso_mode
        begin : create_snoop_req
            if (<%=obj.nDvmCmpInFlight%> > 0) begin
                while (snoop_count < k_num_snp) begin
                    int count;
                    <%=obj.BlockId + '_con'%>::sfi_addr_security_t m_tmp_addr;
                    <%=obj.BlockId + '_con'%>::sfi_mst_transId_t   m_tmp_transId;
                    <%=obj.BlockId + '_con'%>::MsgType_t           snp;
                    sfi_seq_item                                   m_tmp_snp_item;
                    bit                                            flag;
                    int                                            count_dvm;
                    aiu_id_t                                       m_aiu_id_q[$];
                    aiu_id_t                                       m_aiu_id_final;
                    <%=obj.BlockId + '_con'%>::sfi_data_t          tmp[];
                    int                                            m_random_aiu_id_array[];
    
                    assert(std::randomize(m_tmp_addr));
                    flag = 0;
                    wait(pause_snoops == 0);
                    //uvm_report_info("SYS BFM SEQ DEBUG CG", $sformatf("Reached here 1"), UVM_LOW); 
                    do begin
                        count_dvm = 0;
                        foreach (m_sfi_mst_req_q[i]) begin
                            if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(m_sfi_mst_req_q[i].req_pkt)) begin
                                <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_sfi_mst_req_q[i].req_pkt);
                                if (m_snp_req_entry.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
                                    count_dvm++;
                                end
                            end
                        end
                        foreach (m_sfi_snp_req_q[i]) begin
                            <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_sfi_snp_req_q[i].req_pkt);
                            if (m_snp_req_entry.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
                                count_dvm++;
                            end
                        end
                        if (count_dvm >= <%=obj.DceInfo[0].DvmInfo.nDvmSnpInFlight%> ||
                            num_dvm_capable_aius < 2 
                        ) begin
                            @e_sfi_mst_transId_freeup;
                            flag = 0;
                        end
                        else begin
                            flag = 1;
                        end
                    end while (!flag);
                    snp = <%=obj.BlockId + '_con'%>::SNP_DVM_MSG;
                    //uvm_report_info("SYS BFM SEQ DEBUG CG", $sformatf("Reached here 2"), UVM_LOW); 
                    s_transid.get();
                    if (m_trans_id_array.num() == 2**<%=obj.BlockId + '_con'%>::MST_WTRANSID - 1) begin
                        @e_sfi_mst_transId_freeup;
                    end
                    flag = 0;
                    do begin
                        m_tmp_transId = $urandom_range(2**<%=obj.BlockId + '_con'%>::MST_WTRANSID - 1);
                        if (!m_trans_id_array.exists(m_tmp_transId)) begin
                            flag = 1;
                            m_trans_id_array[m_tmp_transId] = 1;
                        end
                    end while (!flag);
                    s_transid.put();
                    // Finding a unique {aiu_id, aiu_trans_id} pair
                    m_aiu_id_q = {};
                    foreach (m_sfi_mst_req_q[i]) begin
                        if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(m_sfi_mst_req_q[i].req_pkt)) begin
                            <%=obj.BlockId + '_con'%>::SNPreqEntry_t m_snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(m_sfi_mst_req_q[i].req_pkt);
                            aiu_id_t                                 m_aiu_id_tmp;
    
                            m_aiu_id_tmp.m_aiu_id       = m_snp_req_entry.req_aiu_id;
                            m_aiu_id_tmp.m_aiu_trans_id = m_snp_req_entry.req_aiu_trans_id;
                            m_aiu_id_q.push_back(m_aiu_id_tmp);
                        end
                    end
                    foreach(m_sfi_snp_req_q[i]) begin
                        aiu_id_t m_aiu_id_tmp;
                        m_aiu_id_tmp.m_aiu_id       = m_sfi_snp_req_q[i].req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_LSB];
                        m_aiu_id_tmp.m_aiu_trans_id = m_sfi_snp_req_q[i].req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_LSB];
                        m_aiu_id_q.push_back(m_aiu_id_tmp);
                    end
                    flag = 0;
                    count = 0;
                    //uvm_report_info("SYS BFM SEQ DEBUG CG", $sformatf("Reached here 3"), UVM_LOW); 
                    do begin
                        int                                     m_tmp_q[$];
                        <%=obj.BlockId + '_con'%>::AIUTransID_t m_aiu_trans_id_tmp;
                        assert(std::randomize(m_aiu_trans_id_tmp))
                        else begin
                            uvm_report_error("SYS BFM SEQ", "Failure to randomize m_aiu_id_final.m_aiu_trans_id", UVM_NONE);
                        end
                        m_aiu_id_final.m_aiu_trans_id = m_aiu_trans_id_tmp;
                        m_aiu_id_final.m_aiu_id = $urandom_range(1, <%=obj.BlockId + '_con'%>::SYS_nSysAIUs - 1);
                        if (m_aiu_id_final.m_aiu_id == <%=obj.Id%> &&
                            <%=obj.Id%> !== 0
                        ) begin
                            m_aiu_id_final.m_aiu_id = 0;
                        end
                        flag = 1;
                        m_tmp_q = m_aiu_id_q.find_first_index with (item == m_aiu_id_final);
                        if (m_tmp_q.size() > 0) begin
                            flag = 0;
                        end
                        count++;
                        if (count > 100) begin
                            @e_sfi_mst_transId_freeup;
                            //uvm_report_error("SYS BFM SEQ", "TB Error: Infinite loop possibility while trying to randomize aiu_id and aiu_trans_id", UVM_NONE);
                        end
                    end while (!flag);
                    //uvm_report_info("SYS BFM SEQ DEBUG CG", $sformatf("Reached here 4"), UVM_LOW); 
                    m_tmp_snp_item                    = sfi_seq_item::type_id::create("m_tmp_snp_item");
                    m_tmp_snp_item.m_has_req          = 1;
                    m_tmp_snp_item.req_pkt.req_opc    = <%= obj.BlockId + '_con'%>::WRITE;
                    if (snp == <%=obj.BlockId + '_con'%>::SNP_DVM_MSG) begin
                        bit [2:0] tmp_type;
                        bit legal;
                        int beat_num = 0;
                        int wt_dvm_sync_tmp;
                        int dvm_count;
                        m_tmp_snp_item.req_pkt.req_length = 15; 
                        if (<%=obj.BlockId + '_con'%>::WDATA < 128) begin
                            tmp                             = new[128/<%=obj.BlockId + '_con'%>::WDATA]; 
                            m_tmp_snp_item.req_pkt.req_data = new[128/<%=obj.BlockId + '_con'%>::WDATA];
                            m_tmp_snp_item.req_pkt.req_be   = new[128/<%=obj.BlockId + '_con'%>::WDATA];
                            beat_num = 64/<%=obj.BlockId + '_con'%>::WDATA;
                        end
                        else begin
                            tmp                             = new[1];
                            m_tmp_snp_item.req_pkt.req_data = new[1];
                            m_tmp_snp_item.req_pkt.req_be   = new[1];
                            beat_num = 0;
                        end
                        for (int j = 0; j <  tmp.size(); j++) begin
                            <%=obj.BlockId + '_con'%>::sfi_data_t tmp_var;
                            assert(std::randomize(tmp_var))
                            else begin
                                uvm_report_error("SYS BFM SEQ", "Failure to randomize tmp_var", UVM_NONE);
                            end
                            tmp[j]                           = tmp_var;
                            m_tmp_snp_item.req_pkt.req_be[j] = '1;
                        end
                        if (<%=obj.BlockId + '_con'%>::WDATA < 128) begin
                            m_tmp_snp_item.req_pkt.req_data               = tmp;
                            m_tmp_snp_item.req_pkt.req_data[0][1]         = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[beat_num][1]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][7]         = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[beat_num][7]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][15]        = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[beat_num][15] = 1'b0;
                            do begin
                                legal = 1;
                                assert(std::randomize(tmp_type))
                                else begin
                                    uvm_report_error("SYS BFM SEQ", "Failure to randomize tmp_type", UVM_NONE);
                                end
                                if (tmp_type == 3'b111 ||
                                    tmp_type == 3'b101
                                ) begin
                                    legal = 0;
                                end
                            end while (!legal);
                            m_tmp_snp_item.req_pkt.req_data[0][14]        = tmp_type[2];
                            m_tmp_snp_item.req_pkt.req_data[0][13]        = tmp_type[1];
                            m_tmp_snp_item.req_pkt.req_data[0][12]        = tmp_type[0];
                            m_tmp_snp_item.req_pkt.req_data[beat_num][14] = tmp_type[2];
                            m_tmp_snp_item.req_pkt.req_data[beat_num][13] = tmp_type[1];
                            m_tmp_snp_item.req_pkt.req_data[beat_num][12] = tmp_type[0];
                            m_tmp_snp_item.req_pkt.req_data[beat_num][2]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[beat_num][1]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[beat_num][0]  = 1'b0;
                        end
                        else begin
                            m_tmp_snp_item.req_pkt.req_data           = tmp;
                            m_tmp_snp_item.req_pkt.req_data[0][1]     = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][1+64]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][7]     = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][7+64]  = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][15]    = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][15+64] = 1'b0;
                            do begin
                                legal = 1;
                                assert(std::randomize(tmp_type))
                                else begin
                                    uvm_report_error("SYS BFM SEQ", "Failure to randomize tmp_type", UVM_NONE);
                                end
                                if (tmp_type == 3'b111 ||
                                    tmp_type == 3'b101
                                ) begin
                                    legal = 0;
                                end
                            end while (!legal);
                            //m_tmp_snp_item.req_pkt.req_data[14:12] = tmp_type[2:0];
                            //m_tmp_snp_item.req_pkt.req_data[78:76] = tmp_type[2:0];
                            //m_tmp_snp_item.req_pkt.req_data[66:64] = 3'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][14] = tmp_type[2];
                            m_tmp_snp_item.req_pkt.req_data[0][13] = tmp_type[1];
                            m_tmp_snp_item.req_pkt.req_data[0][12] = tmp_type[0];
                            m_tmp_snp_item.req_pkt.req_data[0][78] = tmp_type[2];
                            m_tmp_snp_item.req_pkt.req_data[0][77] = tmp_type[1];
                            m_tmp_snp_item.req_pkt.req_data[0][76] = tmp_type[0];
                            m_tmp_snp_item.req_pkt.req_data[0][66] = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][65] = 1'b0;
                            m_tmp_snp_item.req_pkt.req_data[0][64] = 1'b0;
                        end
                        dvm_count = 0;
                        foreach (dvm_sync_snoop_sent[i]) begin
                            if (dvm_sync_snoop_sent[i][0] == 1) begin
                                dvm_count++;
                            end
                        end
                        if (dvm_count < (num_dvm_source_aius - 1)) begin
                            wt_dvm_sync_tmp = wt_dvm_sync_snp;
                        end
                        else begin
                            wt_dvm_sync_tmp = 0;
                        end
                        m_tmp_snp_item.req_pkt.req_addr     = '0;
                        m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT]      = ($urandom_range(0,100) < wt_dvm_sync_tmp) ? 1 : 0;
                        m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_MULTIPART_BIT] = ($urandom_range(0,100) < wt_dvm_multipart_snp && m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT] == 0) ? 1 : 0;
                        if (m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_MULTIPART_BIT] == 1) begin
                            m_tmp_snp_item.req_pkt.req_data[0][0] = 1;
                        end
                        else begin
                            m_tmp_snp_item.req_pkt.req_data[0][0] = 0;
                        end
                        uvm_report_info("SYS BFM SEQ DEBUG", $sformatf("Reached DVM snoop data 0x%0x address 0x%0x", m_tmp_snp_item.req_pkt.req_data[0], m_tmp_snp_item.req_pkt.req_addr), UVM_HIGH); 
                        if (m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT] == 1) begin
                            foreach (dvm_sync_snoop_sent[i]) begin
                                if (dvm_sync_snoop_sent[i][0] == 0) begin
                                    m_random_aiu_id_array = {m_random_aiu_id_array, i+1};
                                end
                            end
                            if (m_random_aiu_id_array.size == 0) begin
                                uvm_report_error("SYSTEM BFM SNOOP", $sformatf("TB Error: Should have at least one entry in dvm_sync_snoop_sent be 0"), UVM_NONE);
                            end
                            m_random_aiu_id_array.shuffle();
                            dvm_sync_snoop_sent[m_random_aiu_id_array[0] - 1][0] = 1;
                            m_tmp_snp_item.req_pkt.req_data[0][15]               = 1'b1;
                        end
                        m_tmp_snp_item.req_pkt.req_sfiSlvId = m_req_aiu_id;
                        m_tmp_snp_item.req_pkt.req_transId  = m_tmp_transId;
                        m_tmp_snp_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_LSB] = <%=obj.BlockId + '_con'%>::MsgType_t'(snp);
<% if (obj.wSecurityAttribute > 0) { %>                                             
                        m_tmp_snp_item.req_pkt.req_security = m_tmp_addr[$size(m_tmp_addr) - 1: $size(m_tmp_addr) - <%=obj.wSecurityAttribute%>]; 
<% } %>                                                
                        m_tmp_snp_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_LSB] = m_aiu_id_final.m_aiu_trans_id;
                        if (snp == <%=obj.BlockId + '_con'%>::SNP_DVM_MSG &&
                            m_tmp_snp_item.req_pkt.req_addr[<%=obj.BlockId + '_con'%>::SFI_ADDR_DVM_SYNC_BIT] == 1
                        ) begin
                            m_tmp_snp_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_LSB]     = m_random_aiu_id_array[0];
                        end
                        else begin
                            m_tmp_snp_item.req_pkt.req_sfiPriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_LSB]     = m_aiu_id_final.m_aiu_id;
                        end
                        m_sfi_snp_req_q.push_back(m_tmp_snp_item);
                        ->e_sfi_snp_req_q;
                        snoop_count++;
                    end
                end
            end
        end : create_snoop_req 
<% } %>      

        begin : maintain_addr_history_size
            forever begin
                if (m_addr_history.size > k_num_addr) begin
                    m_addr_history.shuffle();
                    m_addr_history.delete(0);
                end
                else begin
                    @e_addr_history;
                    m_addr_history = m_addr_history.unique();
                end
            end
        end : maintain_addr_history_size
        // WORK ON OBJECTION MECHANISM HERE
    join_none

endtask : body

endclass : system_bfm_seq

`endif
