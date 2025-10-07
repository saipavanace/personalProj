<% 
 let wRegion = obj.interfaces.axiInt.params.wRegion;
%>
class dii_coverage;
    dii_txn_q          statemachine_q;
    addr_trans_mgr     addr_mgr;
    smi_msg_type_bit_t smi_msg_type;
    bit                rd_after_rd;
    bit                rd_after_wr;
    bit                wr_after_rd;
    bit                wr_after_wr;
    bit                cm_after_wr;
    bit                wr_after_cm;
    bit                cm_after_rd;
    bit                rd_after_cm;
    bit                cm_after_cm;
    bit                smi_addr_match;
    bit                prev_msg_rd = 0;
    bit                prev_msg_wr = 0;
    bit                prev_msg_cm = 0;
    bit                cmeRspRcvd;
    bit                treRspRcvd;
    
    <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
    //Sys event
    int sys_opcode ;
    smi_msg_type_bit_t sys_smi_type ;
    bit sys_event_timeout_err_det_en ;
    bit sys_event_disable;
    bit [3:0] sys_event_uesr_err_type; 
    bit sys_event_irq_uc;
    <% } %>

    <% if (obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
    //skidbuf coverage
    bit [3:0] sram_enabled; 
    bit skidbuf_int_bit;
    bit skidbuf_err_det_bit;
    bit type_of_error;
    <% } %>

<%
    var ignore_awid_list = [30,29,28,25,24,23,22,21,15,14,13,12,11,10,7,6,5];
    var ignore_arid_list = [15, 14, 11, 10, 7, 6];
    var ignore_ids_var = (function() {
    var arr = [];
    var ignore_arids = 0; // Initialize the flag to 0
    var requiredValues = [5, 9, 16, 22]; // The exact values to match

    // Populate the array
    obj.DiiInfo[obj.Id].addressIdMap.addressBits.forEach(function(addressBits) {
        arr.push(addressBits);
    });

    // Check if arr matches requiredValues
    if (
        arr.length === requiredValues.length && // Check if lengths match
        [...arr].sort((a, b) => a - b).toString() === [...requiredValues].sort((a, b) => a - b).toString()
    ) {
        ignore_arids = 1; // Set the flag if arrays match exactly
    }

    return ignore_arids; // Return the result
})();
%>




    
    smi_ncore_unit_id_bit_t endpoint_id;
    enum {ar,aw} axi_msg_type; //only ar & aw as r, w & b are checked for these
    enum {DEFAULT,READ,EO_WRITE} transaction_type_1; 
    enum {DEFAULT_1,NON_EO_WRITE} transaction_type_2;
    int processed_txn_ids[int]; 

    axi_bresp_t bresp;
    axi_buser_t buser;
    axi_rresp_t rresp_per_beat;
    axi_awid_t awid;
    axi_axaddr_t awaddr, araddr;
    axi_arid_t arid;
<%if (wRegion==0){%>
    axi_axregion_t arregion, awregion;
<% } %>
    time t_wr_data, t_wr_addr;
    enum {addr_after_data,
          addr_before_data,
          addr_with_data} axi_wr_seq;
    //bit [3:0] beat_num; //NOTE: max beats supported (in AXI) are 16 (as discussed with Eric)
    bit [$clog2(SYS_nSysCacheline/(WXDATA/8))-1:0] beat_num;
    time t_cmdReq, t_cmdRsp;
    time t_strReq, t_strRsp;
    time t_dtrReq, t_dtrRsp;
    time t_dtwReq, t_dtwRsp;
    time t_cmeRsp, t_treRsp;
    enum {order_req0, order_req1, order_req_ep, order_wr_obs} order_request_type;
    bit order_ep = 0;
    bit ep_bndy_top_new = 0;
    bit ep_bndy_top_old = 0;
    bit ep_bndy_bottom_new = 0;
    bit ep_bndy_bottom_old = 0;
    enum {r_r, r_w, w_r, w_w, r_c, c_r, w_c, c_w} access_seq;
    enum {Cmd, NcCmdRsp, Str, StrRsp, Dtr,
          DtrRsp, Dtw, DtwRsp, DtwDbg, DtwDbgRsp, TreRsp, CmeRsp} concerto_msg_class;
    enum {cmdReq_cmdRsp_strReq_strRsp_dtrReq_dtrRsp,
          cmdReq_cmdRsp_strReq_dtrReq_dtrRsp_strRsp,
          cmdReq_cmdRsp_strReq_dtrReq_strRsp_dtrRsp,
          cmdReq_strReq_cmdRsp_strRsp_dtrReq_dtrRsp,
          cmdReq_strReq_cmdRsp_dtrReq_strRsp_dtrRsp,
          cmdReq_strReq_cmdRsp_dtrReq_dtrRsp_strRsp,
          cmdReq_strReq_dtrReq_cmdRsp_strRsp_dtrRsp,
          cmdReq_strReq_dtrReq_cmdRsp_dtrRsp_strRsp,
          cmdReq_strReq_dtrReq_strRsp_cmdRsp_dtrRsp,
          cmdReq_strReq_dtrReq_strRsp_dtrRsp_cmdRsp,
          cmdReq_strReq_dtrReq_dtrRsp_cmdRsp_strRsp,
          cmdReq_strReq_dtrReq_dtrRsp_strRsp_cmdRsp,
          cmdReq_cmdRsp_strReq_strRsp_dtwReq_dtwRsp,
          cmdReq_cmdRsp_strReq_dtwReq_dtwRsp_strRsp,
          cmdReq_cmdRsp_strReq_dtwReq_strRsp_dtwRsp,
          cmdReq_strReq_cmdRsp_strRsp_dtwReq_dtwRsp,
          cmdReq_strReq_cmdRsp_dtwReq_strRsp_dtwRsp,
          cmdReq_strReq_cmdRsp_dtwReq_dtwRsp_strRsp,
          cmdReq_strReq_dtwReq_cmdRsp_strRsp_dtwRsp,
          cmdReq_strReq_dtwReq_cmdRsp_dtwRsp_strRsp,
          cmdReq_strReq_dtwReq_strRsp_cmdRsp_dtwRsp,
          cmdReq_strReq_dtwReq_strRsp_dtwRsp_cmdRsp,
          cmdReq_strReq_dtwReq_dtwRsp_cmdRsp_strRsp,
          cmdReq_strReq_dtwReq_dtwRsp_strRsp_cmdRsp
          } dii_txn_states;
    enum {cmdReq_with_dtwReq,
          cmdReq_with_dtrReq,
          cmdReq_with_dtwRsq,
          cmdReq_with_dtrRsq,
          cmdReq_with_strRsq,
          cmdReq_with_cmdRsq,
          cmdReq_with_strReq,
          strReq_with_dtwReq,
          strReq_with_dtrReq,
          strReq_with_dtwRsp,
          strReq_with_dtrRsp,
          strReq_with_strRsp,
          strReq_with_cmdRsp,
          dtrReq_with_dtwRsp,
          dtrReq_with_dtrRsp,
          dtrReq_with_strRsp,
          dtrReq_with_cmdRsp,
          dtrReq_with_dtwReq,
          dtwReq_with_dtwRsp,
          dtwReq_with_dtrRsp,
          dtwReq_with_strRsp,
          dtwReq_with_cmdRsp,
          dtwRsp_with_dtrRsp,
          dtwRsp_with_strRsp,
          cmdRsp_with_dtrRsp,
          cmdRsp_with_strRsp} two_msg_in_same_cycle;
    enum {strReq_with_dtrReq_same_txn,
          strReq_with_cmdRsp_same_txn,
          strReq_with_dtrRsp_same_txn,
          dtrReq_with_cmdRsp_same_txn,
          dtrReq_with_strRsp_same_txn,
          dtwReq_with_cmdRsp_same_txn,
          cmdRsp_with_dtrRsp_same_txn,
          cmdRsp_with_strRsp_same_txn,
          strRsp_with_dtwRsp_same_txn} two_msg_same_txn_same_cycle;
    enum {strReq_treRsp, dtrReq_treRsp} treRsp_positions;
    enum {strReq_cmeRsp, dtrReq_cmeRsp, cmdReq_cmeRsp, dtwReq_cmeRsp} cmeRsp_positions;



    covergroup buffer_txns; //#Cover.DII.Concerto.v3.7.FillSkidBuffer
        coverpoint transaction_type_1 {
           
            bins read_txn = {READ};
            bins eo_write = {EO_WRITE};

        } 
        coverpoint transaction_type_2 {
            bins non_eo_write = {NON_EO_WRITE};
        }

    endgroup


///////////////////////////////////////////////////////////////////////////////////
// COVERPOINTS ON CONCERTO MESSAGES
///////////////////////////////////////////////////////////////////////////////////
    covergroup concerto_messages;
        
        // #Cover.DII.Concerto.valid_sequence
    seq_of_transitions: coverpoint dii_txn_states {
            bins cp_cmdReq_cmdRsp_strReq_strRsp_dtrReq_dtrRsp = {0};
            bins cp_cmdReq_cmdRsp_strReq_dtrReq_dtrRsp_strRsp = {1};
            bins cp_cmdReq_cmdRsp_strReq_dtrReq_strRsp_dtrRsp = {2};
            bins cp_cmdReq_strReq_cmdRsp_strRsp_dtrReq_dtrRsp = {3};
            bins cp_cmdReq_strReq_cmdRsp_dtrReq_strRsp_dtrRsp = {4};
            bins cp_cmdReq_strReq_cmdRsp_dtrReq_dtrRsp_strRsp = {5};
            bins cp_cmdReq_strReq_dtrReq_cmdRsp_strRsp_dtrRsp = {6};
            bins cp_cmdReq_strReq_dtrReq_cmdRsp_dtrRsp_strRsp = {7};
            bins cp_cmdReq_strReq_dtrReq_strRsp_cmdRsp_dtrRsp = {8};
            bins cp_cmdReq_strReq_dtrReq_dtrRsp_cmdRsp_strRsp = {10};
            bins cp_cmdReq_cmdRsp_strReq_strRsp_dtwReq_dtwRsp = {12};
            bins cp_cmdReq_cmdRsp_strReq_dtwReq_dtwRsp_strRsp = {13};
            bins cp_cmdReq_cmdRsp_strReq_dtwReq_strRsp_dtwRsp = {14};
            bins cp_cmdReq_strReq_cmdRsp_strRsp_dtwReq_dtwRsp = {15};
            bins cp_cmdReq_strReq_cmdRsp_dtwReq_strRsp_dtwRsp = {16};
            bins cp_cmdReq_strReq_cmdRsp_dtwReq_dtwRsp_strRsp = {17};
            bins cp_cmdReq_strReq_dtwReq_cmdRsp_strRsp_dtwRsp = {18};
            bins cp_cmdReq_strReq_dtwReq_cmdRsp_dtwRsp_strRsp = {19};
            bins cp_cmdReq_strReq_dtwReq_strRsp_cmdRsp_dtwRsp = {20};
            bins cp_cmdReq_strReq_dtwReq_strRsp_dtwRsp_cmdRsp = {21};
            bins cp_cmdReq_strReq_dtwReq_dtwRsp_cmdRsp_strRsp = {22};
<% if(obj.testBench == "fsys") { %>
`ifndef VCS           
            bins cp_dtwDbgReq_dtwDbgRsp = {24};

`endif            
<% } %>
            <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
                    type_option.weight  = 0;
                    type_option.goal    = 0;
            <% } %>

        }
        // #CoverTime.DII.concerto.each_two_msg_same_cycle
        // Review once updated in testplan
        each_two_msg_during_same_cycle: coverpoint two_msg_in_same_cycle {
            bins cp_cmdReq_with_dtwReq = {0};
            bins cp_cmdReq_with_dtrReq = {1};
            bins cp_cmdReq_with_dtwRsp = {2};
            bins cp_cmdReq_with_dtrRsp = {3};
            bins cp_cmdReq_with_strRsp = {4};
            bins cp_cmdReq_with_cmdRsp = {5};
            bins cp_cmdReq_with_strReq = {6};
            bins cp_strReq_with_dtwReq = {7};
            bins cp_strReq_with_dtrReq = {8};
            bins cp_strReq_with_dtwRsp = {9};
            bins cp_strReq_with_dtrRsp = {10};
            bins cp_strReq_with_strRsp = {11};
            bins cp_strReq_with_cmdRsp = {12};
            bins cp_dtrReq_with_dtwRsp = {13};
            bins cp_dtrReq_with_dtrRsp = {14};
            bins cp_dtrReq_with_strRsp = {15};
            bins cp_dtrReq_with_cmdRsp = {16};
            bins cp_dtrReq_with_dtwReq = {17};
            bins cp_dtwReq_with_dtwRsp = {18};
            bins cp_dtwReq_with_dtrRsp = {19};
            bins cp_dtwReq_with_strRsp = {20};
            bins cp_dtwReq_with_cmdRsp = {21};
            bins cp_dtwRsp_with_dtrRsp = {22};
            bins cp_dtwRsp_with_strRsp = {23};
            bins cp_cmdRsp_with_dtrRsp = {24};
            bins cp_cmdRsp_with_strRsp = {25};
            <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
                type_option.weight  = 0;
                type_option.goal    = 0;
            <% } %>
        }
        // #CoverTime.DII.concerto.each_two_msg_same_txn_same_cycle
        each_two_msg_same_txn_same_cycle: coverpoint two_msg_same_txn_same_cycle {
            bins cp_strReq_with_dtrReq_same_txn = {0};
            bins cp_strReq_with_cmdRsp_same_txn = {1};
            bins cp_strReq_with_dtrRsp_same_txn = {2};
            bins cp_dtrReq_with_cmdRsp_same_txn = {3};
            bins cp_dtrReq_with_strRsp_same_txn = {4};
            bins cp_dtwReq_with_cmdRsp_same_txn = {5};
            //bins cp_cmdRsp_with_dtrRsp_same_txn = {6};
            bins cp_cmdRsp_with_strRsp_same_txn = {7};
            bins cp_strRsp_with_dtwRsp_same_txn = {8};
            <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
                    type_option.weight  = 0;
                    type_option.goal    = 0;
            <% } %>

        }
        // #Cover.DII.concerto.treRsp_each_position
        treRsp_at_each_position: coverpoint treRsp_positions iff (treRspRcvd) {
            bins treRsp_after_dtrReq = {dtrReq_treRsp};
            bins treRsp_after_strReq = {strReq_treRsp};
            type_option.weight  = 0;
            type_option.goal    = 0;
        }
        // #Cover.DII.concerto.cmeRsp_each_position
        cmeRsp_at_each_position: coverpoint cmeRsp_positions iff (cmeRspRcvd) {
            bins cmeRsp_after_strReq = {strReq_cmeRsp};
            bins cmeRsp_after_dtrReq = {dtrReq_cmeRsp};
            bins cmeRsp_after_dtwReq = {dtwReq_cmeRsp};
            bins cmeRsp_after_cmdReq = {cmdReq_cmeRsp};
            type_option.weight  = 0;
            type_option.goal    = 0;
        }
    endgroup

    covergroup smi_cmdtype_seq;
        // #Cover.DII.concerto.all_msg_class
        all_concerto_msg_class: coverpoint concerto_msg_class {
            bins cp_Cmd       = {0};
            bins cp_NcCmdRsp  = {1};
            bins cp_Str       = {2};
            bins cp_StrRsp    = {3};
            bins cp_Dtr       = {4};
            bins cp_DtrRsp    = {5};
            bins cp_Dtw       = {6};
            bins cp_DtwRsp    = {7};
            bins cp_DtwDbg    = {8};
            bins cp_DtwDbgRsp = {9};
        }
        // #CoverTime.DII.CMDreq.Access_seq
        rd_followed_by_rd: coverpoint rd_after_rd {
            bins r_r = {1};
        }
        wr_followed_by_rd: coverpoint wr_after_rd {
            bins w_r = {1};
        }
        rd_followed_by_wr: coverpoint rd_after_wr {
            bins r_w = {1};
        }
        wr_followed_by_wr: coverpoint wr_after_wr {
            bins w_w = {1};
        }
        rd_followed_by_cm: coverpoint rd_after_cm {
            bins c_r = {1};
        }
        wr_followed_by_cm: coverpoint wr_after_cm {
            bins c_w = {1};
        }
        cm_followed_by_rd: coverpoint cm_after_rd {
            bins r_c = {1};
        }
        cm_followed_by_wr: coverpoint cm_after_wr {
            bins w_c = {1};
        }
        cm_followed_by_cm: coverpoint cm_after_cm {
            bins c_c = {1};
        }
        // #CoverTime.DII.CMDreq.Addr_match
        same_addr: coverpoint smi_addr_match{
            bins isMatch = {1};
        }
        // #CoverCross.DII.CMDreq.Access_seq_cross_addr_match
        cross_of_same_addr_rd_rd: cross same_addr, rd_followed_by_rd;
        cross_of_same_addr_wr_rd: cross same_addr, wr_followed_by_rd;
        cross_of_same_addr_rd_wr: cross same_addr, rd_followed_by_wr;
        cross_of_same_addr_wr_wr: cross same_addr, wr_followed_by_wr;
    endgroup

///////////////////////////////////////////////////////////////////////////////////
// COVERPOINTS ON AXI MESSAGES
///////////////////////////////////////////////////////////////////////////////////
    covergroup axi_sequence;
        // #Cover.DII.axi_txn_type
        axi_txn_type: coverpoint axi_msg_type {
            bins write = {aw};
            bins read = {ar};
        }
        // #CoverTime.DII.aw_w.sequence
        write_addr_data_order: coverpoint axi_wr_seq{
            bins addr_after_data = {0};
            bins addr_before_data = {1};
            bins addr_with_data = {2};
        }
    endgroup

    covergroup axi_read_addr;
        // #Cover.DII.ar.Arid
        read_addr_id: coverpoint arid {
            //option.auto_bin_max = 2 ** WARID;
            //option.auto_bin_max = 16;
             <% for (var i = 0; i < obj.DiiInfo[obj.Id].cmpInfo.nRttCtrlEntries; i++) { %>
        <% if (ignore_ids_var == 1 && ignore_arid_list.includes(i)) { %>
            ignore_bins arid_<%=i%> = {<%=i%>}; // Exclude specific ARID values
        <% } else { %>
            bins arid_<%=i%> = {<%=i%>}; // Create bins for other ARID values
        <% } %>
    <% } %>
            <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
                    type_option.weight  = 0;
                    type_option.goal    = 0;
            <% } %>

        }

        read_addr: coverpoint araddr {
            option.auto_bin_max = 16;
        } 
        // ARREGION is unused in DII
        //read_addr_region: coverpoint arregion;
<%if (wRegion==0 || obj.DiiInfo[obj.Id].nExclusiveEntries  > 0){%>
        // #Cover.DMI.ar.Arregion
        read_addr_region: coverpoint arregion{  // tied to zero
            type_option.weight  = 0;
            type_option.goal    = 0;
        }
<% } %>
    endgroup

    covergroup axi_write_addr;
        // #Cover.DII.aw.Awid
        write_addr_id: coverpoint awid {
            //option.auto_bin_max = 2 ** WAWID;
            //option.auto_bin_max = 16;
            
             <% for (var i = 0; i < obj.DiiInfo[obj.Id].cmpInfo.nWttCtrlEntries; i++) { %>
        <% if (ignore_ids_var == 1 && ignore_awid_list.includes(i)) { %>
            ignore_bins awid_<%=i%> = {<%=i%>}; // Exclude specific ARID values
        <% } else { %>
            bins awid_<%=i%> = {<%=i%>}; // Create bins for other ARID values
        <% } %>
    <% } %>
            <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
                    type_option.weight  = 0;
                    type_option.goal    = 0;
            <% } %>
        }
        //#Cover.DII.aw.Address
        write_addr: coverpoint awaddr {
            option.auto_bin_max = 16;
        }

        // AWREGION is unused in DII
        //write_addr_region: coverpoint awregion;
<%if (wRegion==0 || obj.DiiInfo[obj.Id].nExclusiveEntries  > 0){%>
        // #Cover.DMI.aw.Awregion
        write_addr_region: coverpoint awregion{ // tied to zero
            type_option.weight  = 0;
            type_option.goal    = 0;
        }
<% } %>
    endgroup

    covergroup axi_read_resp;
        // #Cover.DII.r.rresp_per_beat
        read_resp: coverpoint rresp_per_beat {
            bins okay = {OKAY};
           <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
            <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  == 0) { %>
               bins exokay = {EXOKAY};
             <% } %>
               bins slverr = {SLVERR};
               bins decerr = {DECERR};
           <% } %>
        }
        // #CoverCross.DII.r.rresp_per_beat_cross_beat_num
        <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
          cross_read_resp_beat_num: cross read_resp, beat_num;
        <% } %>
    endgroup

    // #CoverToggle.DII.r.Rdata
    toggle_coverage toggle_cg_read_data;

    covergroup axi_write_resp;
        // #Cover.DII.b.buser
        user_signal: coverpoint buser;
        // #Cover.DII.b.bresp
        write_resp: coverpoint bresp {
            bins okay = {OKAY};
            <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
             <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  == 0) { %>
                bins exokay = {EXOKAY};
             <% } %>
                bins slverr = {SLVERR};
                bins decerr = {DECERR};
            <% } %>
        }
    endgroup

///////////////////////////////////////////////////////////////////////////////////
// COVERPOINTS ON ORDERING (FEATURES)
///////////////////////////////////////////////////////////////////////////////////
    covergroup dii_txn_ordering;
        order_request: coverpoint order_request_type {
            // #Cover.DII.Order_req_with_req_outstanding
            bins order_request0 = {order_req0};
            // #Cover.DII.Order_req_with_ep_outstanding
            bins order_request1 = {order_req1};
            // #Cover.DII.Order_ep_with_req_outstanding
            bins order_request_endpoint = {order_req_ep};
            // #Cover.DII.Order_wr_obs
            bins order_write_observe = {order_wr_obs};
        }
        // #Cover.DII.Order_ep_with_ep_outstanding
        order_endpoint: coverpoint order_ep {
            bins order_ep1 = {1};
        }

        endpoint_id_cov: coverpoint endpoint_id {
            bins low = {0}; // Block level DII simulations is run on DII0. Other Endpoint IDs of DII are covered in sys_dii and fsys
            <% if(obj.Block =='sys_dii') { %>
                bins mid = {[1:14]};
                bins high = {15}; // Maximum of 16 DIIs supported in NCORE3 - Can be updated to use the Obj parameters
            <% } %>
        }

        //Not covering this as of now (access seq and order ep are sampled at diff places)
        // #CoverCross.DII.Order_ep_cross_access_seq
        //all_order_endpoint: cross order_endpoint, access_seq;
        ep_bndy_top_new_cov: coverpoint ep_bndy_top_new {
            type_option.weight = 0;
        }
        ep_bndy_top_old_cov: coverpoint ep_bndy_top_old {
            type_option.weight = 0;
        }
        ep_bndy_bottom_new_cov: coverpoint ep_bndy_bottom_new {
            type_option.weight = 0;
        }
        ep_bndy_bottom_old_cov: coverpoint ep_bndy_bottom_old {
            type_option.weight = 0;
        }

        // #CoverCross.DII.Order_ep_cross_ep_id, #Cover.DII.ep_id
        all_endpoints: cross order_endpoint, endpoint_id_cov;
        // #CoverCross.DII.All_ep_cross_ep_bndy_top_new
        ep_boundary_top_new_txn: cross all_endpoints, ep_bndy_top_new_cov {
            type_option.weight = 0;
        }
        // #CoverCross.DII.All_ep_cross_ep_bndy_top_old
        ep_boundary_top_old_txn: cross all_endpoints, ep_bndy_top_old_cov {
            type_option.weight = 0;
        }
        // #CoverCross.DII.All_ep_cross_ep_bndy_bottom_new
        ep_boundary_bottom_new_txn: cross all_endpoints, ep_bndy_bottom_new_cov {
            type_option.weight = 0;
        }
        // #CoverCross.DII.All_ep_cross_ep_bndy_bottom_old
        ep_boundary_bottom_old_txn: cross all_endpoints, ep_bndy_bottom_old_cov {
            type_option.weight = 0;
        }
    endgroup

    <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
    // Covergroup for system event messages
    covergroup cg_sys_event_smi_cmd ;

    	
    //#Cover.DII.EventMsg.opcode
    cp_sysreq_event_opcode      : coverpoint sys_opcode{
        bins event_opcode   = {3};
    }
    //#Cover.DII.EventMsg.MsgType
    cp_syscmd_smi_type         : coverpoint sys_smi_type {
        bins sysreq  = {'h7b};
        bins sysrsp  = {'hfb};
    }
    endgroup
    
    covergroup cg_sys_event_csr ;
    cp_timeout_err_det_en       : coverpoint sys_event_timeout_err_det_en {
        bins timeout_enable     = {1};
        bins timeout_disable    = {0};
    }   
    //#Cover.DII.EventMsg.EventDisable
    cp_sys_event_dis      : coverpoint sys_event_disable {
        bins sys_event_enable     = {0};
        bins sys_event_disable    = {1};
    }   
    //#Cover.DII.EventMsg.TimeoutError
    cp_uesr_err_type        : coverpoint sys_event_uesr_err_type{
        bins uesr_err_type  = {'hA};
    }

    cp_uc_int_occurred      : coverpoint sys_event_irq_uc{
        bins irq_occurred   = {1};
        bins no_irq     = {0};
        }

    endgroup
    <% } %>

    <% if (obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>


    covergroup skidbuf_error_testing; 

    // Coverpoint for interrupt enable status
    interrupt_enabled : coverpoint skidbuf_int_bit {
        bins int_is_enabled = {1};
        bins int_is_disabled = {0};
    }

    // Coverpoint for error detection enable status
    error_det_enabled : coverpoint skidbuf_err_det_bit {
        bins errdet_is_enabled = {1};
      <%if(obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) == "SECDED") { %>
        bins errdet_is_disabled = {0};
      <% } %>
      <%if(obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) == "PARITY") { %>
        ignore_bins errdet_is_disabled = {0};
      <% } %>
    }

    // Coverpoint for type of error
    type_of_error : coverpoint type_of_error {
      <%if(obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) == "SECDED") { %>
        bins corr_err = {1};   // Correctable error
      <% } %>
      <%if(obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) == "PARITY") { %>
        ignore_bins corr_err = {1};   // Correctable error
      <% } %>
        bins uncorr_err = {0}; // Uncorrectable error
    }

    // Coverpoint for SRAM status
    sram_enabled : coverpoint sram_enabled {
        bins sram_on = {5, 6}; // SRAM enabled states
    }

    // Cross coverage for corr_err when SRAM is on and different enable combinations
    corr_err_cross : cross type_of_error, sram_enabled, error_det_enabled, interrupt_enabled {
        // Ignore illegal combination where only interrupt is enabled
        ignore_bins uncorr_corr_memdet_disabled = binsof(type_of_error) intersect {0,1} && 
                              binsof(sram_enabled) intersect {5, 6} &&
                              binsof(error_det_enabled) intersect {0} && 
                              binsof(interrupt_enabled) intersect {1};

        ignore_bins uncorr_both_disabled = binsof(type_of_error) intersect {0} && 
                               binsof(sram_enabled) intersect {5, 6} &&
                               binsof(error_det_enabled) intersect {0} && 
                               binsof(interrupt_enabled) intersect {0};

    <%if(obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) == "SECDED") { %> //#Cover.DII.Concerto.v3.7.CorrectableSECDED


        bins corr_sram_int_errdet_enabled = binsof(type_of_error) intersect {1} && 
                                            binsof(sram_enabled) intersect {5, 6} &&
                                            binsof(error_det_enabled) intersect {1} && 
                                            binsof(interrupt_enabled) intersect {1};

        bins corr_sram_errdet_only = binsof(type_of_error) intersect {1} && 
                                     binsof(sram_enabled) intersect {5, 6} &&
                                     binsof(error_det_enabled) intersect {1} && 
                                     binsof(interrupt_enabled) intersect {0};

        bins corr_sram_both_disabled = binsof(type_of_error) intersect {1} && 
                                       binsof(sram_enabled) intersect {5, 6} &&
                                       binsof(error_det_enabled) intersect {0} && 
                                       binsof(interrupt_enabled) intersect {0};
    <% } %>

    <%if(obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) == "PARITY") { %>


        ignore_bins corr_sram_int_errdet_enabled = binsof(type_of_error) intersect {1} && 
                                            binsof(sram_enabled) intersect {5, 6} &&
                                            binsof(error_det_enabled) intersect {1} && 
                                            binsof(interrupt_enabled) intersect {1};

        ignore_bins corr_sram_errdet_only = binsof(type_of_error) intersect {1} && 
                                     binsof(sram_enabled) intersect {5, 6} &&
                                     binsof(error_det_enabled) intersect {1} && 
                                     binsof(interrupt_enabled) intersect {0};

        ignore_bins corr_sram_both_disabled = binsof(type_of_error) intersect {1} && 
                                       binsof(sram_enabled) intersect {5, 6} &&
                                       binsof(error_det_enabled) intersect {0} && 
                                       binsof(interrupt_enabled) intersect {0};
    <% } %>

        bins uncorr_sram_int_errdet_enabled = binsof(type_of_error) intersect {0} && //#Cover.DII.Concerto.v3.7.UncorrectableSECDED
                                            binsof(sram_enabled) intersect {5, 6} && //#Cover.DII.Concerto.v3.7.UncorrectablePARITY
                                            binsof(error_det_enabled) intersect {1} && 
                                            binsof(interrupt_enabled) intersect {1};

        bins uncorr_sram_errdet_only = binsof(type_of_error) intersect {0} && 
                                     binsof(sram_enabled) intersect {5, 6} &&
                                     binsof(error_det_enabled) intersect {1} && 
                                     binsof(interrupt_enabled) intersect {0};

    }

    endgroup



    <% } %>

    extern function void collect_smi_seq(smi_seq_item txn);
    extern function void collect_axi_write_addr_pkt(axi4_write_addr_pkt_t txn);
    extern function void collect_axi_write_data_pkt(axi4_write_data_pkt_t txn);
    extern function void collect_axi_write_resp_pkt(axi4_write_resp_pkt_t txn);
    extern function void collect_axi_read_addr_pkt(axi4_read_addr_pkt_t txn);
    extern function void collect_axi_read_data_pkt(axi4_read_data_pkt_t txn);
    extern function void collect_dii_seq(dii_txn txn);
    extern function void collect_dii_txn_ordering(dii_txn txn);
    extern function void find_access_seq(smi_seq_item txn);
    extern function void collect_time_before_RetireTxn(dii_txn txn);
    extern function bit  isCacheMaintOp(smi_msg_type_bit_t smi_msg_type);
    extern function new();
    <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
    extern function void collect_sys_event_smi (smi_msg_type_bit_t sys_event_smi_type,int sys_event_opcode);
    extern function void collect_sys_event_csr (bit sysevent_timeout_err_det_en, bit sysevent_disable , bit [3:0] uesr_err_type, bit irq_uc);
    <% } %>
    <% if(obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
    extern function void collect_skidbuff_err_csr (bit type_of_error_csr, bit skidbuf_err_det_bit_csr, bit skidbuf_int_bit_csr, bit [3:0] skidbuf_uesr_err_type_csr);
    <% } %>
endclass // dii_coverage

function void dii_coverage::find_access_seq(smi_seq_item txn);
    // after read
    if (prev_msg_rd == 1) begin
       if (txn.smi_msg_type == CMD_RD_NC) begin
          // read after read
          rd_after_rd = 1;
       end
       else if ((txn.smi_msg_type == CMD_WR_NC_PTL) || (txn.smi_msg_type == CMD_WR_NC_FULL)) begin
          // write after read
          wr_after_rd = 1;
       end
       else if (isCacheMaintOp(txn.smi_msg_type)) begin
          // cmo after read
          cm_after_rd = 1;
       end
    end // if (prev_msg_rd == 1)

    if (prev_msg_wr == 1) begin
       if (txn.smi_msg_type == CMD_RD_NC) begin
          // read after write
          rd_after_wr = 1;
       end
       else if ((txn.smi_msg_type == CMD_WR_NC_PTL) || (txn.smi_msg_type == CMD_WR_NC_FULL)) begin
          // write after write
          wr_after_wr = 1;
       end
       else if (isCacheMaintOp(txn.smi_msg_type)) begin
          // cmo after write
          cm_after_wr = 1;
       end
    end // if (prev_msg_wr == 1)
   
    if (prev_msg_cm == 1) begin
       if (txn.smi_msg_type == CMD_RD_NC) begin
          // read after cm
          rd_after_cm = 1;
       end
       else if ((txn.smi_msg_type == CMD_WR_NC_PTL) || (txn.smi_msg_type == CMD_WR_NC_FULL)) begin
          // write after cm
          wr_after_cm = 1;
       end
       else if (isCacheMaintOp(txn.smi_msg_type)) begin
          // cmo after cmo
          cm_after_cm = 1;
       end
    end // if (prev_msg_wr == 1)
       
    begin : RESET_PREVOP
       prev_msg_rd = 0;
       prev_msg_wr = 0;
       prev_msg_cm = 0;
       if (txn.smi_msg_type == CMD_RD_NC) begin
          prev_msg_rd = 1;
       end
       else if ((txn.smi_msg_type == CMD_WR_NC_PTL) || (txn.smi_msg_type == CMD_WR_NC_FULL)) begin
          prev_msg_wr = 1;
       end
       else if (isCacheMaintOp(txn.smi_msg_type)) begin
          prev_msg_cm = 1;
       end
    end : RESET_PREVOP
endfunction

function bit dii_coverage::isCacheMaintOp(smi_msg_type_bit_t smi_msg_type);
    if (smi_msg_type == CMD_CLN_VLD ||
        smi_msg_type == CMD_CLN_SH_PER ||
        smi_msg_type == CMD_CLN_INV ||
        smi_msg_type == CMD_MK_INV)
        return 1;
    else
        return 0;
endfunction

function void dii_coverage::collect_smi_seq(smi_seq_item txn);
    int m_tmp_addr_match_q[$];
    smi_seq_item msg;
    msg = new();
    msg.copy(txn);
    if (msg.isCmdMsg())
        concerto_msg_class = Cmd;
    else if (msg.isDtwDbgReqMsg())
      concerto_msg_class = DtwDbg;
    else if (msg.isNcCmdRspMsg())
      concerto_msg_class = NcCmdRsp;
    else if (msg.isStrMsg())
      concerto_msg_class = Str;
    else if (msg.isStrRspMsg())
      concerto_msg_class = StrRsp;
    else if (msg.isDtrMsg())
      concerto_msg_class = Dtr;
    else if (msg.isDtrRspMsg())
      concerto_msg_class = DtrRsp;
    else if (msg.isDtwMsg())
      concerto_msg_class = Dtw;
    else if (msg.isDtwRspMsg())
      concerto_msg_class = DtwRsp;
    else if (msg.isTreRspMsg())
      concerto_msg_class = TreRsp;
    else if (msg.isCmeRspMsg())
      concerto_msg_class = CmeRsp;
    else if (msg.isDtwDbgRspMsg())
      concerto_msg_class = DtwDbgRsp;
   
   m_tmp_addr_match_q = {};
   m_tmp_addr_match_q = statemachine_q.txn_q.find_index with(item.smi_recd.exists(eConcMsgCmdReq) &&
                                                             item.smi_recd[eConcMsgCmdReq].isCmdMsg() &&
                                                             item.smi_recd[eConcMsgCmdReq].smi_msg_valid == 1 &&
                                                             item.smi_recd[eConcMsgCmdReq].smi_addr == msg.smi_addr);
   if (m_tmp_addr_match_q.size() > 0)
     smi_addr_match = 1;
   else
     smi_addr_match = 0;
   find_access_seq(msg);
   smi_cmdtype_seq.sample();
endfunction // collect_smi_seq

function void dii_coverage::collect_dii_seq(dii_txn txn);
    bit dii_txn_rd, dii_txn_wr;
    cmeRspRcvd = 0; treRspRcvd = 0;

    if(txn.smi_expd.size() == 0)begin

         if (txn.smi_recd.exists(eConcMsgCmdReq)) begin

              if (txn.smi_recd[eConcMsgCmdReq].smi_msg_type == CMD_RD_NC) begin 
             //$display("Vyshak debug in read: msg_type = %0d, order = %0h at time %0t and id %0d", txn.smi_recd[eConcMsgCmdReq].smi_msg_type, txn.smi_recd[eConcMsgCmdReq].smi_order, $time, txn.txn_id);
             transaction_type_1 = READ;
             buffer_txns.sample();
             transaction_type_1 = DEFAULT;
             
          end
          else if ((txn.smi_recd[eConcMsgCmdReq].smi_msg_type == CMD_WR_NC_PTL || txn.smi_recd[eConcMsgCmdReq].smi_msg_type == CMD_WR_NC_FULL) && txn.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT) begin
             //$display("Vyshak debug in eo: msg_type = %0d, order = %0h at time %0t and id %0d",txn.smi_recd[eConcMsgCmdReq].smi_msg_type, txn.smi_recd[eConcMsgCmdReq].smi_order, $time, txn.txn_id);
              transaction_type_1 = EO_WRITE;
             buffer_txns.sample();
              transaction_type_1 = DEFAULT;
          end
          else if ((txn.smi_recd[eConcMsgCmdReq].smi_msg_type == CMD_WR_NC_PTL || txn.smi_recd[eConcMsgCmdReq].smi_msg_type == CMD_WR_NC_FULL) && txn.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_ENDPOINT) begin
             //$display("Vyshak debug in non eo: msg_type = %0d, order = %0h at time %0t and id %0d", txn.smi_recd[eConcMsgCmdReq].smi_msg_type, txn.smi_recd[eConcMsgCmdReq].smi_order, $time, txn.txn_id);
             transaction_type_2 = NON_EO_WRITE;
             buffer_txns.sample();
             transaction_type_2 = DEFAULT_1;
           end else begin
             //$display("Vyshak but wasnt hit because already processed and the message is: msg_type = %0d, order = %0h at time %0t and id %0d", txn.smi_recd[eConcMsgCmdReq].smi_msg_type, txn.smi_recd[eConcMsgCmdReq].smi_order, $time, txn.txn_id);
           end
         end //if(txn.smi_recd.exists(eConcMsgCmdReq))

    end //if(txn.smi_expd.size() == 0)

    if (txn.smi_expd.size() == 0 && txn.axi_expd.size() == 0) begin
        // collect timing of cmds
       if (txn.smi_recd.exists(eConcMsgCmdReq)) begin
          if (txn.smi_recd[eConcMsgCmdReq]) 
            t_cmdReq = txn.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid;
          if (txn.smi_recd[eConcMsgNcCmdRsp]) 
            t_cmdRsp = txn.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid;
          if (txn.smi_recd[eConcMsgStrReq]) 
            t_strReq = txn.smi_recd[eConcMsgStrReq].t_smi_ndp_valid;
          if (txn.smi_recd[eConcMsgStrRsp]) 
            t_strRsp = txn.smi_recd[eConcMsgStrRsp].t_smi_ndp_valid;
          if (txn.smi_recd[eConcMsgDtrReq])
            t_dtrReq = txn.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid;
          if (txn.smi_recd[eConcMsgDtrRsp]) begin
             t_dtrRsp = txn.smi_recd[eConcMsgDtrRsp].t_smi_ndp_valid;
             dii_txn_rd = 1;
          end
          if (txn.smi_recd[eConcMsgDtwReq]) 
            t_dtwReq = txn.smi_recd[eConcMsgDtwReq].t_smi_ndp_valid;
          if (txn.smi_recd[eConcMsgDtwRsp]) begin
             t_dtwRsp = txn.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid;
             dii_txn_wr = 1;
          end
          if (txn.smi_recd[eConcMsgCmeRsp]) begin 
             t_cmeRsp = txn.smi_recd[eConcMsgCmeRsp].t_smi_ndp_valid;
             cmeRspRcvd = 1;
          end
          if (txn.smi_recd[eConcMsgTreRsp]) begin 
             t_treRsp = txn.smi_recd[eConcMsgTreRsp].t_smi_ndp_valid;
             treRspRcvd = 1;
          end
       end
    end
    // valid seq in txn state machine
    // read txns
    if (dii_txn_rd) begin
        if (t_cmdRsp < t_strReq && t_strRsp < t_dtrReq)
            dii_txn_states = cmdReq_cmdRsp_strReq_strRsp_dtrReq_dtrRsp;
        if (t_cmdRsp < t_strReq && t_strReq < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_strRsp)
            dii_txn_states = cmdReq_cmdRsp_strReq_dtrReq_dtrRsp_strRsp;
        if (t_cmdRsp < t_strReq && t_strReq < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_dtrRsp)
            dii_txn_states = cmdReq_cmdRsp_strReq_dtrReq_strRsp_dtrRsp;
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtrReq)
            dii_txn_states = cmdReq_strReq_cmdRsp_strRsp_dtrReq_dtrRsp;
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_dtrRsp)
            dii_txn_states = cmdReq_strReq_cmdRsp_dtrReq_strRsp_dtrRsp;
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_strRsp)
            dii_txn_states = cmdReq_strReq_cmdRsp_dtrReq_dtrRsp_strRsp;
        if (t_strReq < t_dtrReq && t_dtrReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtrRsp)
            dii_txn_states = cmdReq_strReq_dtrReq_cmdRsp_strRsp_dtrRsp;
        if (t_strReq < t_dtrReq && t_dtrReq < t_cmdRsp && t_cmdRsp < t_dtrRsp && t_dtrRsp < t_strRsp)
            dii_txn_states = cmdReq_strReq_dtrReq_cmdRsp_dtrRsp_strRsp;
        if (t_strReq < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_cmdRsp && t_cmdRsp < t_dtrRsp)
            dii_txn_states = cmdReq_strReq_dtrReq_strRsp_cmdRsp_dtrRsp;
        if (t_strReq < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_dtrRsp && t_dtrRsp < t_cmdRsp)
            dii_txn_states = cmdReq_strReq_dtrReq_strRsp_dtrRsp_cmdRsp;
        if (t_strReq < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_cmdRsp && t_cmdRsp < t_strRsp)
            dii_txn_states = cmdReq_strReq_dtrReq_dtrRsp_cmdRsp_strRsp;
        if (t_strReq < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_strRsp && t_strRsp < t_cmdRsp)
            dii_txn_states = cmdReq_strReq_dtrReq_dtrRsp_strRsp_cmdRsp;
        if (t_dtrReq < t_treRsp && t_treRsp < t_dtrRsp && t_treRsp < t_strRsp && t_treRsp < t_cmdRsp)
            treRsp_positions = dtrReq_treRsp;
        if (t_strReq < t_treRsp && t_treRsp < t_dtrReq && t_treRsp < t_strRsp && t_treRsp < t_cmdRsp)
            treRsp_positions = strReq_treRsp;
        if (t_strReq < t_cmeRsp && t_cmeRsp < t_dtrReq && t_cmeRsp < t_strRsp && t_cmeRsp < t_cmdRsp)
            cmeRsp_positions = strReq_cmeRsp;
        if (t_dtrReq < t_cmeRsp && t_cmeRsp < t_dtrRsp && t_cmeRsp < t_strRsp && t_cmeRsp < t_cmdRsp)
            cmeRsp_positions = dtrReq_cmeRsp;
        if (t_cmdReq < t_cmeRsp && t_cmeRsp < t_strReq && t_cmeRsp < t_cmdRsp)
            cmeRsp_positions = cmdReq_cmeRsp;
        concerto_messages.sample();
    end
    // write txns
    if (dii_txn_wr) begin
        if (t_cmdRsp < t_strReq && t_strRsp < t_dtwReq)
            dii_txn_states = cmdReq_cmdRsp_strReq_strRsp_dtwReq_dtwRsp;
        if (t_cmdRsp < t_strReq && t_strReq < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_strRsp)
            dii_txn_states = cmdReq_cmdRsp_strReq_dtwReq_dtwRsp_strRsp;
        if (t_cmdRsp < t_strReq && t_strReq < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_dtwRsp)
            dii_txn_states = cmdReq_cmdRsp_strReq_dtwReq_strRsp_dtwRsp;
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtwReq)
            dii_txn_states = cmdReq_strReq_cmdRsp_strRsp_dtwReq_dtwRsp;
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_dtwRsp)
            dii_txn_states = cmdReq_strReq_cmdRsp_dtwReq_strRsp_dtwRsp;
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_strRsp)
            dii_txn_states = cmdReq_strReq_cmdRsp_dtwReq_dtwRsp_strRsp;
        if (t_strReq < t_dtwReq && t_dtwReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtwRsp)
            dii_txn_states = cmdReq_strReq_dtwReq_cmdRsp_strRsp_dtwRsp;
        if (t_strReq < t_dtwReq && t_dtwReq < t_cmdRsp && t_cmdRsp < t_dtwRsp && t_dtwRsp < t_strRsp)
            dii_txn_states = cmdReq_strReq_dtwReq_cmdRsp_dtwRsp_strRsp;
        if (t_strReq < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_cmdRsp && t_cmdRsp < t_dtwRsp)
            dii_txn_states = cmdReq_strReq_dtwReq_strRsp_cmdRsp_dtwRsp;
        if (t_strReq < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_dtwRsp && t_dtwRsp < t_cmdRsp)
            dii_txn_states = cmdReq_strReq_dtwReq_strRsp_dtwRsp_cmdRsp;
        if (t_strReq < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_cmdRsp && t_cmdRsp < t_strRsp)
            dii_txn_states = cmdReq_strReq_dtwReq_dtwRsp_cmdRsp_strRsp;
        if (t_strReq < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_strRsp && t_strRsp < t_cmdRsp)
            dii_txn_states = cmdReq_strReq_dtwReq_dtwRsp_strRsp_cmdRsp;
        if (t_strReq < t_treRsp && t_treRsp < t_dtwReq && t_treRsp < t_strRsp && t_treRsp < t_cmdRsp)
            treRsp_positions = strReq_treRsp;
        if (t_dtwReq < t_cmeRsp && t_cmeRsp < t_dtwRsp && t_cmeRsp < t_strRsp && t_cmeRsp < t_cmdRsp)
            cmeRsp_positions = dtwReq_cmeRsp;
        if (t_strReq < t_cmeRsp && t_cmeRsp < t_dtwReq && t_cmeRsp < t_strRsp && t_cmeRsp < t_cmdRsp)
            cmeRsp_positions = strReq_cmeRsp;
        if (t_cmdReq < t_cmeRsp && t_cmeRsp < t_strReq && t_cmeRsp < t_cmdRsp)
            cmeRsp_positions = cmdReq_cmeRsp;
        concerto_messages.sample();
    end
endfunction // collect_dii_seq

function void dii_coverage::collect_axi_write_addr_pkt(axi4_write_addr_pkt_t txn);
    axi_msg_type = aw;
    awid = txn.awid;
    awaddr = txn.awaddr;
    awregion = txn.awregion;
    axi_sequence.sample();
    axi_write_addr.sample();
endfunction // collect_axi_write_addr_pkt

function void dii_coverage::collect_axi_write_data_pkt(axi4_write_data_pkt_t txn);
endfunction // collect_axi_write_addr_pkt

function void dii_coverage::collect_axi_write_resp_pkt(axi4_write_resp_pkt_t txn);
    bresp = txn.bresp;
    buser = txn.buser;
    axi_write_resp.sample();
endfunction // collect_axi_write_resp_pkt

function void dii_coverage::collect_axi_read_addr_pkt(axi4_read_addr_pkt_t txn);
    axi_msg_type = ar;
    arid = txn.arid;
    araddr = txn.araddr;
    arregion = txn.arregion;
    axi_sequence.sample();
    axi_read_addr.sample();
endfunction // collect_axi_read_addr_pkt

function void dii_coverage::collect_axi_read_data_pkt(axi4_read_data_pkt_t txn);
    beat_num = 0;
    foreach (txn.rresp_per_beat[i]) begin
        rresp_per_beat = txn.rresp_per_beat[i];
        axi_read_resp.sample();
        beat_num++;
        for (int j = 0; j < WXDATA; j++) begin
            toggle_cg_read_data.field[j] = txn.rdata[i][j];
        end
        toggle_cg_read_data.sample();
    end
endfunction // collect_axi_read_data_pkt

function void dii_coverage::collect_dii_txn_ordering(dii_txn txn);
    dii_txn find_order_req0_q[$];
    dii_txn find_order_req1_q[$];
    dii_txn find_order_req_ep_q[$];
    dii_txn find_order_ep_q[$];
    dii_txn ep_top_new_q[$];
    dii_txn ep_bottom_new_q[$];
    dii_txn ep_top_old_q[$];
    dii_txn ep_bottom_old_q[$];
    dii_txn find_order_wr_obs_q[$];
    ncore_memory_map m_map;
    m_map = addr_mgr.get_memory_map_instance();
    if (txn.smi_recd.exists(eConcMsgCmdReq)) begin
       case(txn.smi_recd[eConcMsgCmdReq].smi_order)
         SMI_ORDER_REQUEST_WR_OBS : begin
            find_order_req0_q = statemachine_q.txn_q.find with (item.smi_recd.exists(eConcMsgCmdReq) &&
                                                                item.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_REQUEST_WR_OBS &&
                                                                ncoreConfigInfo::cache_addr(item.smi_recd[eConcMsgCmdReq].smi_addr) == ncoreConfigInfo::cache_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr) &&
                                                                item.smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id == txn.smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id);
            if (find_order_req0_q.size() > 0) $cast(order_request_type , 0);

            find_order_req1_q = statemachine_q.txn_q.find with (item.smi_recd.exists(eConcMsgCmdReq) &&
                                                                item.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT &&
                                                                ncoreConfigInfo::cache_addr(item.smi_recd[eConcMsgCmdReq].smi_addr) == ncoreConfigInfo::cache_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr) &&
                                                                item.smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id == txn.smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id);
            if (find_order_req1_q.size() > 0) $cast(order_request_type , 1);

            find_order_wr_obs_q = statemachine_q.txn_q.find with (item.smi_recd.exists(eConcMsgCmdReq) &&
                                                                  txn.smi_recd[eConcMsgCmdReq].smi_msg_type == CMD_RD_NC &&
                                                                  (item.smi_recd[eConcMsgCmdReq].smi_msg_type == CMD_WR_NC_FULL ||
                                                                   item.smi_recd[eConcMsgCmdReq].smi_msg_type == CMD_WR_NC_PTL) &&
                                                                  ncoreConfigInfo::cache_addr(item.smi_recd[eConcMsgCmdReq].smi_addr) == ncoreConfigInfo::cache_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr)); 
            if (find_order_wr_obs_q.size() > 0) $cast(order_request_type , 3);
         end
         SMI_ORDER_ENDPOINT : begin
            find_order_ep_q = statemachine_q.txn_q.find with (item.smi_recd.exists(eConcMsgCmdReq) &&
                                                              ncoreConfigInfo::endpoint_addr(item.smi_recd[eConcMsgCmdReq].smi_addr, item.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id) == ncoreConfigInfo::endpoint_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr, txn.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id) &&
                                                              item.smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id == txn.smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id &&
                                                              ncoreConfigInfo::cache_addr(item.smi_recd[eConcMsgCmdReq].smi_addr) == ncoreConfigInfo::cache_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr) &&
                                                              item.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT);
            if (find_order_ep_q.size() > 0) order_ep = 1;

            find_order_req_ep_q = statemachine_q.txn_q.find with (item.smi_recd.exists(eConcMsgCmdReq) &&
                                                                  item.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_REQUEST_WR_OBS &&
                                                                  ncoreConfigInfo::cache_addr(item.smi_recd[eConcMsgCmdReq].smi_addr) == ncoreConfigInfo::cache_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr) &&
                                                                  item.smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id == txn.smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id);
            if (find_order_req_ep_q.size() > 0) $cast(order_request_type , 2);

            endpoint_id = ncoreConfigInfo::endpoint_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr, txn.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id);
            
            ep_top_new_q = statemachine_q.txn_q.find with (ncoreConfigInfo::cache_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr) == ncoreConfigInfo::memregion_boundaries[endpoint_id].end_addr - 1);
            if (ep_top_new_q.size() > 0) ep_bndy_top_new = 1;

            ep_top_old_q = statemachine_q.txn_q.find with (item.smi_recd.exists(eConcMsgCmdReq) &&
                                                           ncoreConfigInfo::cache_addr(item.smi_recd[eConcMsgCmdReq].smi_addr) == ncoreConfigInfo::memregion_boundaries[endpoint_id].end_addr - 1);
            if (ep_top_old_q.size() > 0) ep_bndy_top_old = 1;

            ep_bottom_new_q = statemachine_q.txn_q.find with (ncoreConfigInfo::cache_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr) == ncoreConfigInfo::memregion_boundaries[endpoint_id].start_addr - 1);
            if (ep_bottom_new_q.size() > 0) ep_bndy_bottom_new = 1;

            ep_bottom_old_q = statemachine_q.txn_q.find with (item.smi_recd.exists(eConcMsgCmdReq) &&
                                                              ncoreConfigInfo::cache_addr(item.smi_recd[eConcMsgCmdReq].smi_addr) == ncoreConfigInfo::memregion_boundaries[endpoint_id].start_addr - 1);
            if (ep_bottom_old_q.size() > 0) ep_bndy_bottom_old = 1;
         end
       endcase
       dii_txn_ordering.sample();
    end
endfunction // collect_dii_txn_ordering

function void dii_coverage::collect_time_before_RetireTxn(dii_txn txn);
     dii_txn find_cmdReq_with_dtwReq_q[$];
     dii_txn find_cmdReq_with_dtrReq_q[$];
     dii_txn find_cmdReq_with_dtwRsp_q[$];
     dii_txn find_cmdReq_with_dtrRsp_q[$];
     dii_txn find_cmdReq_with_strRsp_q[$];
     dii_txn find_cmdReq_with_cmdRsp_q[$];
     dii_txn find_cmdReq_with_strReq_q[$];
     dii_txn find_strReq_with_dtwReq_q[$];
     dii_txn find_strReq_with_dtrReq_q[$];
     dii_txn find_strReq_with_dtwRsp_q[$];
     dii_txn find_strReq_with_dtrRsp_q[$];
     dii_txn find_strReq_with_strRsp_q[$];
     dii_txn find_strReq_with_cmdRsp_q[$];
     dii_txn find_dtrReq_with_dtwRsp_q[$];
     dii_txn find_dtrReq_with_dtrRsp_q[$];
     dii_txn find_dtrReq_with_strRsp_q[$];
     dii_txn find_dtrReq_with_cmdRsp_q[$];
     dii_txn find_dtrReq_with_dtwReq_q[$];
     dii_txn find_dtwReq_with_dtwRsp_q[$];
     dii_txn find_dtwReq_with_dtrRsp_q[$];
     dii_txn find_dtwReq_with_strRsp_q[$];
     dii_txn find_dtwReq_with_cmdRsp_q[$];
     dii_txn find_dtwRsp_with_dtrRsp_q[$];
     dii_txn find_dtwRsp_with_strRsp_q[$];
     dii_txn find_cmdRsp_with_dtrRsp_q[$];
     dii_txn find_cmdRsp_with_strRsp_q[$];

     //no more activity expd in this txn
     if(txn.smi_recd.exists(eConcMsgCmdReq) && (txn.smi_expd.size() == 0) && (txn.axi_expd.size() == 0)) begin

         find_cmdReq_with_dtwReq_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtwReq] &&
                                             txn.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtwReq].t_smi_ndp_valid);
         find_cmdReq_with_dtrReq_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtrReq] &&
                                             txn.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid);
         find_cmdReq_with_dtwRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtwRsp] &&
                                             txn.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid);
         find_cmdReq_with_dtrRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtrRsp] &&
                                             txn.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtrRsp].t_smi_ndp_valid);
         find_cmdReq_with_strRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgStrRsp] &&
                                             txn.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid == item.smi_recd[eConcMsgStrRsp].t_smi_ndp_valid);
         find_cmdReq_with_cmdRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgNcCmdRsp] &&
                                             txn.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid == item.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid);
         find_cmdReq_with_strReq_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgStrReq] &&
                                             txn.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid == item.smi_recd[eConcMsgStrReq].t_smi_ndp_valid);
         find_strReq_with_dtwReq_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtwReq] &&
                                             txn.smi_recd[eConcMsgStrReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtwReq].t_smi_ndp_valid);
         find_strReq_with_dtrReq_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtrReq] &&
                                             txn.smi_recd[eConcMsgStrReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid);
         find_strReq_with_dtwRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtwRsp] &&
                                             txn.smi_recd[eConcMsgStrReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid);
         find_strReq_with_dtrRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtrRsp] &&
                                             txn.smi_recd[eConcMsgStrReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtrRsp].t_smi_ndp_valid);
         find_strReq_with_strRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgStrRsp] &&
                                             txn.smi_recd[eConcMsgStrReq].t_smi_ndp_valid == item.smi_recd[eConcMsgStrRsp].t_smi_ndp_valid);
         find_strReq_with_cmdRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgNcCmdRsp] &&
                                             txn.smi_recd[eConcMsgStrReq].t_smi_ndp_valid == item.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid);
         find_dtrReq_with_dtwRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtwRsp] && txn.smi_recd[eConcMsgDtrReq] &&
                                             txn.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid);
         find_dtrReq_with_dtrRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtrRsp] && txn.smi_recd[eConcMsgDtrReq] &&
                                             txn.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtrRsp].t_smi_ndp_valid);
         find_dtrReq_with_strRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgStrRsp] && txn.smi_recd[eConcMsgDtrReq] &&
                                             txn.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid == item.smi_recd[eConcMsgStrRsp].t_smi_ndp_valid);
         find_dtrReq_with_cmdRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgNcCmdRsp] && txn.smi_recd[eConcMsgDtrReq] &&
                                             txn.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid == item.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid);
         find_dtrReq_with_dtwReq_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtwReq] && txn.smi_recd[eConcMsgDtrReq] &&
                                             txn.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtwReq].t_smi_ndp_valid);
         find_dtwReq_with_dtwRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtwRsp] && txn.smi_recd[eConcMsgDtwReq] &&
                                             txn.smi_recd[eConcMsgDtwReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid);
         find_dtwReq_with_dtrRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtrRsp] && txn.smi_recd[eConcMsgDtwReq] &&
                                             txn.smi_recd[eConcMsgDtwReq].t_smi_ndp_valid == item.smi_recd[eConcMsgDtrRsp].t_smi_ndp_valid);
         find_dtwReq_with_strRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgStrRsp] && txn.smi_recd[eConcMsgDtwReq] &&
                                             txn.smi_recd[eConcMsgDtwReq].t_smi_ndp_valid == item.smi_recd[eConcMsgStrRsp].t_smi_ndp_valid);
         find_dtwReq_with_cmdRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgNcCmdRsp] && txn.smi_recd[eConcMsgDtwReq] &&
                                             txn.smi_recd[eConcMsgDtwReq].t_smi_ndp_valid == item.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid);
         find_dtwRsp_with_dtrRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtrRsp] && txn.smi_recd[eConcMsgDtwRsp] &&
                                             txn.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid == item.smi_recd[eConcMsgDtrRsp].t_smi_ndp_valid);
         find_dtwRsp_with_strRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgStrRsp] && txn.smi_recd[eConcMsgDtwRsp] &&
                                             txn.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid == item.smi_recd[eConcMsgStrRsp].t_smi_ndp_valid);
         find_cmdRsp_with_dtrRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgDtrRsp] &&
                                             txn.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid == item.smi_recd[eConcMsgDtrRsp].t_smi_ndp_valid);
         find_cmdRsp_with_strRsp_q = statemachine_q.txn_q.find with(item.smi_recd[eConcMsgStrRsp] &&
                                             txn.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid == item.smi_recd[eConcMsgStrRsp].t_smi_ndp_valid);
         if (find_cmdReq_with_dtwReq_q.size() > 0) $cast(two_msg_in_same_cycle , 0);
         if (find_cmdReq_with_dtrReq_q.size() > 0) $cast(two_msg_in_same_cycle , 1);
         if (find_cmdReq_with_dtwRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 2);
         if (find_cmdReq_with_dtrRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 3);
         if (find_cmdReq_with_strRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 4);
         if (find_cmdReq_with_cmdRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 5);
         if (find_cmdReq_with_strReq_q.size() > 0) $cast(two_msg_in_same_cycle , 6);
         if (find_strReq_with_dtwReq_q.size() > 0) $cast(two_msg_in_same_cycle , 7);
         if (find_strReq_with_dtrReq_q.size() > 0) $cast(two_msg_in_same_cycle , 8);
         if (find_strReq_with_dtwRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 9);
         if (find_strReq_with_dtrRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 10);
         if (find_strReq_with_strRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 11);
         if (find_strReq_with_cmdRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 12);
         if (find_dtrReq_with_dtwRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 13);
         if (find_dtrReq_with_dtrRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 14);
         if (find_dtrReq_with_strRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 15);
         if (find_dtrReq_with_cmdRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 16);
         if (find_dtrReq_with_dtwReq_q.size() > 0) $cast(two_msg_in_same_cycle , 17);
         if (find_dtwReq_with_dtwRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 18);
         if (find_dtwReq_with_dtrRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 19);
         if (find_dtwReq_with_strRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 20);
         if (find_dtwReq_with_cmdRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 21);
         if (find_dtwRsp_with_dtrRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 22);
         if (find_dtwRsp_with_strRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 23);
         if (find_cmdRsp_with_dtrRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 24);
         if (find_cmdRsp_with_strRsp_q.size() > 0) $cast(two_msg_in_same_cycle , 25);

         if (txn.smi_recd.exists(eConcMsgDtrReq) && txn.smi_recd.exists(eConcMsgStrReq) &&
             txn.smi_recd[eConcMsgStrReq].t_smi_ndp_valid == txn.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid) begin
            $cast(two_msg_same_txn_same_cycle , 0);
         end
         if (txn.smi_recd.exists(eConcMsgNcCmdRsp) && txn.smi_recd.exists(eConcMsgStrReq) &&
             txn.smi_recd[eConcMsgStrReq].t_smi_ndp_valid == txn.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid) begin
            $cast(two_msg_same_txn_same_cycle , 1);
         end
         if (txn.smi_recd.exists(eConcMsgDtrRsp) && txn.smi_recd.exists(eConcMsgStrReq) &&
             txn.smi_recd[eConcMsgStrReq].t_smi_ndp_valid == txn.smi_recd[eConcMsgDtrRsp].t_smi_ndp_valid) begin
            $cast(two_msg_same_txn_same_cycle , 2);
         end
         if (txn.smi_recd.exists(eConcMsgNcCmdRsp) && txn.smi_recd.exists(eConcMsgDtrReq) &&
             txn.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid == txn.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid) begin
            $cast(two_msg_same_txn_same_cycle , 3);
         end
         if (txn.smi_recd.exists(eConcMsgStrRsp) && txn.smi_recd.exists(eConcMsgDtrReq) &&
             txn.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid == txn.smi_recd[eConcMsgStrRsp].t_smi_ndp_valid) begin
            $cast(two_msg_same_txn_same_cycle , 4);
         end
         if (txn.smi_recd.exists(eConcMsgNcCmdRsp) && txn.smi_recd.exists(eConcMsgDtwReq) &&
             txn.smi_recd[eConcMsgDtwReq].t_smi_ndp_valid == txn.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid) begin
            $cast(two_msg_same_txn_same_cycle , 5);
         end
         if (txn.smi_recd.exists(eConcMsgDtrRsp) && txn.smi_recd.exists(eConcMsgNcCmdRsp) &&
             txn.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid == txn.smi_recd[eConcMsgDtrRsp].t_smi_ndp_valid) begin
            $cast(two_msg_same_txn_same_cycle , 6);
         end
         if (txn.smi_recd.exists(eConcMsgStrRsp) && txn.smi_recd.exists(eConcMsgNcCmdRsp) &&
             txn.smi_recd[eConcMsgNcCmdRsp].t_smi_ndp_valid == txn.smi_recd[eConcMsgStrRsp].t_smi_ndp_valid) begin
            $cast(two_msg_same_txn_same_cycle , 7);
         end
         if (txn.smi_recd.exists(eConcMsgStrRsp) && txn.smi_recd.exists(eConcMsgDtwRsp) &&
             txn.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid == txn.smi_recd[eConcMsgStrRsp].t_smi_ndp_valid) begin
            $cast(two_msg_same_txn_same_cycle , 8);
         end
     end
    concerto_messages.sample();

    //wr addr and data timings
    t_wr_data = txn.axi_recd[axi_w];
    t_wr_addr = txn.axi_recd[axi_aw];
    if      (t_wr_data < t_wr_addr) axi_wr_seq = addr_after_data;
    else if (t_wr_data > t_wr_addr) axi_wr_seq = addr_before_data;
    else                            axi_wr_seq = addr_with_data;
    axi_sequence.sample();
endfunction // collect_time_before_RetireTxn

function dii_coverage::new();
    statemachine_q = new();
    smi_cmdtype_seq = new();
    axi_write_resp = new();
    axi_write_addr = new();
    axi_read_resp = new();
    axi_read_addr = new();
    axi_sequence = new();
    dii_txn_ordering = new();
    buffer_txns = new();
    concerto_messages = new();
    toggle_cg_read_data = new(WXDATA,"axi_read_data");
    addr_mgr = addr_trans_mgr::get_instance();
    <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
    cg_sys_event_smi_cmd = new();
    cg_sys_event_csr =  new();
    <% } %>
    <% if(obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
    skidbuf_error_testing = new();
    <% } %>
endfunction // new
<% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>

function void dii_coverage::collect_sys_event_smi (smi_msg_type_bit_t sys_event_smi_type,int sys_event_opcode);
    sys_opcode = sys_event_opcode;
    sys_smi_type = sys_event_smi_type;
    cg_sys_event_smi_cmd.sample();
endfunction 
function void  dii_coverage::collect_sys_event_csr (bit sysevent_timeout_err_det_en, bit sysevent_disable , bit [3:0] uesr_err_type, bit irq_uc);
    sys_event_timeout_err_det_en = sysevent_timeout_err_det_en;
    sys_event_disable = sysevent_disable;
    sys_event_uesr_err_type = uesr_err_type;
    sys_event_irq_uc = irq_uc;
    cg_sys_event_csr.sample();
endfunction 

<% } %>

<% if(obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
function void dii_coverage::collect_skidbuff_err_csr (bit type_of_error_csr, bit skidbuf_err_det_bit_csr, bit skidbuf_int_bit_csr, bit [3:0] skidbuf_uesr_err_type_csr);
    $display("Skidbuf error coverage values before sampling 1 type_of_error_csr = %0b, skidbuf_err_det_bit_csr = %0b , skidbuf_int_bit_csr = %0b , skidbuf_uesr_err_type_csr = %0h", type_of_error_csr, skidbuf_err_det_bit_csr, skidbuf_int_bit_csr, skidbuf_uesr_err_type_csr);
    type_of_error = type_of_error_csr;
    skidbuf_err_det_bit = skidbuf_err_det_bit_csr;
    skidbuf_int_bit = skidbuf_int_bit_csr;
    sram_enabled = skidbuf_uesr_err_type_csr;
     $display("Skidbuf error coverage values before sampling 2 type_of_error = %0b, skidbuf_err_det_bit = %0b , skidbuf_int_bit = %0b , sram_enabled = %0h", type_of_error, skidbuf_err_det_bit, skidbuf_int_bit, sram_enabled);
    skidbuf_error_testing.sample();
endfunction
<% } %>
