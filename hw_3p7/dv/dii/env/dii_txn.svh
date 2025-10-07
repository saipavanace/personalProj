
////////////////////////////////////////////////////////////////////////////////
//
// DII txn
// represent a sequence of msgs constituting one data transfer
// represent a sequence of txns constituting one test
//
////////////////////////////////////////////////////////////////////////////////

//similar to econcmsgclass
typedef enum {
    axi_ar,
    axi_r,
    axi_aw,
    axi_w,
    axi_b
} eAxiMsgClass ;
<% if((obj.testBench == 'dii') ||(obj.testBench=="fsys")) { %>
   `ifdef VCS
    `define VCSorCDNS
   `elsif CDNS
    `define VCSorCDNS
   `endif 
<% }  %>

//get which msg class is a rsp to this
// mapping is complete within dii only.
<% if(obj.testBench == 'dii') { %>
`ifndef CDNS
const eConcMsgClass rsp_to[eConcMsgClass] = {
`else // `ifndef CDNS
const eConcMsgClass rsp_to[eConcMsgClass] = '{
`endif // `ifndef CDNS
<% } else {%>
const eConcMsgClass rsp_to[eConcMsgClass] = {
<% } %>
    eConcMsgCmdReq    :   eConcMsgNcCmdRsp , 
    eConcMsgStrReq    :   eConcMsgStrRsp   ,
    eConcMsgDtrReq    :   eConcMsgDtrRsp   ,
    eConcMsgDtwReq    :   eConcMsgDtwRsp   ,
    eConcMsgDtwDbgReq :   eConcMsgDtwDbgRsp,
    eConcMsgSysReq    :   eConcMsgSysRsp,
    default           :   eConcMsgBAD  //rsp never outstanding
};

//number of credits for each msg class
<% if(obj.testBench == 'dii') { %>
`ifndef CDNS
const int num_smi_msg_id[eConcMsgClass] = {
`else // `ifndef CDNS
const int num_smi_msg_id[eConcMsgClass] = '{
`endif // `ifndef CDNS
<% } else {%>
const int num_smi_msg_id[eConcMsgClass] = {
<% } %>
<% if ( obj.DiiInfo[obj.Id].strRtlNamePrefix == 'sys_dii' ) { %>
    eConcMsgCmdReq  :   2 ,
<% } else { %>
    eConcMsgCmdReq  :   <%=obj.DiiInfo[obj.Id].nCMDSkidBufSize%> ,
<% } %>
    eConcMsgDtwReq  :   <%=obj.DiiInfo[obj.Id].nCMDSkidBufSize%> ,
    default         :   0   //=> not controlled by credits.
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
typedef class dii_scoreboard;
<% if((obj.testBench == 'dii') ||(obj.testBench=="fsys")) { %>
`ifndef VCSorCDNS
typedef class addr_trans_mgr;
`endif // `ifndef VCSorCDNS
<% } else {%>
typedef class addr_trans_mgr;
<% } %>

   
//represent a sequence of msgs constituting one data transfer
// keep track of exclusive accesses
class dii_exclusive_c extends uvm_object;
    smi_tof_t                 tof;
    smi_st_t                  st;
    smi_ac_t                  ac;
    smi_ca_t                  ca;
    smi_intfsize_t            intfsize;
    smi_addr_t                addr;
    smi_size_t                size;
    smi_mpf1_burst_type_t     burst_type;
    smi_mpf1_asize_t          asize;
    smi_mpf1_alength_t        alen;
    smi_msg_type_bit_t        msg_type;
    smi_ncore_unit_id_bit_t   src_id;
    smi_mpf2_flowid_t         flowid;
    smi_ns_t                  ns;
    //------------------------------------------------------------------------------
    // constructor
    //------------------------------------------------------------------------------
    function new(string name="");
       super.new(name);
    endfunction : new
endclass : dii_exclusive_c

class dii_txn extends uvm_object;
<%
var addressMapId = function() {
    var arr = [];
    obj.DiiInfo[obj.Id].addressIdMap.addressBits.forEach(function(addressBits) {
        arr.push(addressBits);
    });
    return(arr);
};
%>
    string parent;
    int unsigned txn_id;
    bit force_awid = 0;  
    bit force_arid = 0; 


    //smi
    // true && exists iff msg of class expected.
    // TODO if txn contains multiple msgs of same class: could use payload wrapper or array of arrays to distinguish
    int smi_expd [eConcMsgClass];
    //true iff msg of class received, then contains msg.
    smi_seq_item smi_recd [eConcMsgClass] ;

    //axi
    //must break out axi msgs individually because not all axi_seq_item with eAxiMsgClass

    bit axi_expd [eAxiMsgClass] ;
    time axi_recd [eAxiMsgClass] ;  //keep the time stamp here to make it iterable

    axi4_read_addr_pkt_t      axi_read_addr_pkt;
    axi4_read_data_pkt_t      axi_read_data_pkt;
    axi4_write_addr_pkt_t     axi_write_addr_pkt;
    axi4_write_data_pkt_t     axi_write_data_pkt;
    axi4_write_resp_pkt_t     axi_write_resp_pkt;

    // local variables
    semaphore s_retire;
    bit       retired;
    bit       axi_w_handled;
    common_knob_class k_32b_cmdset      = new ("k_32b_cmdset"      , this , m_weights_const            , m_minmax_const_0         );
    
    
    // variable used to store exclusive monitor status that will be used for cmstatus in DtwRsp
    exmon_status_t    m_exmon_status ;
    int exmon_size =  <%=obj.DiiInfo[obj.Id].nExclusiveEntries%>;
    //Used for Gen AXID
    int wCacheLineOffset =  <%=obj.DiiInfo[obj.Id].wCacheLineOffset%>;
    int addressMapId[] = '{<%=addressMapId()%>};//<%=obj.DiiInfo[obj.Id].addressIdMap.addressBits%>;
    //------------------------------------------------------------------------------
    // constructor
    //------------------------------------------------------------------------------

    //must add msg to txn externally, same as noninitiating msgs.
    function new(smi_seq_item initiator, string parent_in = "");
        eConcMsgClass smi_expd_q[$];
        eAxiMsgClass axi_expd_q[$];
        super.new("dii_txn");   //set the class for log prints
        parent = parent_in;

        //expected activity for each txn type
        if(initiator.isCmdNcRdMsg()) begin
            smi_expd_q = {eConcMsgCmdReq, eConcMsgNcCmdRsp, eConcMsgStrReq, eConcMsgStrRsp,      eConcMsgDtrReq, eConcMsgDtrRsp};
            axi_expd_q = {axi_ar, axi_r};
        end
        else if(initiator.isCmdNcWrMsg()) begin
            smi_expd_q = {eConcMsgCmdReq, eConcMsgNcCmdRsp, eConcMsgStrReq, eConcMsgStrRsp,      eConcMsgDtwReq, eConcMsgDtwRsp};
            axi_expd_q = {axi_aw, axi_w, axi_b};
        end
        else if(initiator.isCmdCacheOpsMsg()) begin     //cmo is always dataless.
            smi_expd_q = {eConcMsgCmdReq, eConcMsgNcCmdRsp, eConcMsgStrReq, eConcMsgStrRsp};
            axi_expd_q = {};
        end
        else if(initiator.isDtwDbgReqMsg()) begin
            smi_expd_q = {eConcMsgDtwDbgReq, eConcMsgDtwDbgRsp};
            axi_expd_q = {};
        end
        else if (initiator.isSysReqMsg()) begin
        smi_expd_q = {eConcMsgSysReq,eConcMsgSysRsp};
        axi_expd_q = {};
        end
        else begin
            $stacktrace;
            `uvm_error($sformatf("%m (%s)", parent), $sformatf("msg is not a valid initiator: %p", initiator))
        end

        //represent as assoc arrays
        foreach(smi_expd_q[i]) smi_expd[smi_expd_q[i]] = 1;
        foreach(axi_expd_q[i]) axi_expd[axi_expd_q[i]] = 1;

        //foreach(axi_recd[i])   axi_recd[i]             = 0;
       
        //cmdreq recd
        s_retire = new(1);
        retired  = 0;
        axi_w_handled = 0;

        //clear time stamps for axi_recd
        foreach (axi_recd[i]) axi_recd[i] = 0;

    endfunction : new


    //------------------------------------------------------------------------------

    function void print_entry();
        if(smi_recd.exists(eConcMsgCmdReq))
            `uvm_info($sformatf("%m (%s)", parent), $sformatf("\n%t: \n:%p\nsmi_recd[eConcMsgCmdReq] :%p", smi_recd[eConcMsgCmdReq].t_smi_ndp_valid,this,smi_recd[eConcMsgCmdReq].convert2string()), UVM_MEDIUM)
        else if (smi_recd.exists(eConcMsgDtwDbgReq))
            `uvm_info($sformatf("%m (%s)", parent), $sformatf("\n%t: \n:%p\nsmi_recd[eConcMsgDtwDbgReq] :%p", smi_recd[eConcMsgDtwDbgReq].t_smi_ndp_valid,this,smi_recd[eConcMsgDtwDbgReq].convert2string()), UVM_MEDIUM)
        else if (smi_recd.exists(eConcMsgSysReq)) 
          `uvm_info($sformatf("%m (%s)", parent), $sformatf("\n%t: \n:%p\nsmi_recd[eConcMsgSysReq] :%p", smi_recd[eConcMsgSysReq].t_smi_ndp_valid,this,smi_recd[eConcMsgSysReq].convert2string()), UVM_MEDIUM)
        else begin
           eConcMsgClass i;
           foreach (smi_recd[i] ) begin
              `uvm_info($sformatf("%m (%s)", parent), $sformatf("smi_recd[%p]: %p", i, smi_recd[i].convert2string()), UVM_MEDIUM)
           end
        end
    endfunction : print_entry
    //------------------------------------------------------------------------------
    //return the time of the most recent activity
    function time latest_activity();
        latest_activity = 0;   //start with minimum time

        foreach(smi_recd[i])
            if(smi_recd[i].t_smi_ndp_valid > latest_activity)    latest_activity = smi_recd[i].t_smi_ndp_valid ;

        foreach(axi_recd[i])    //contains the time directly
            if(axi_recd[i] > latest_activity)   latest_activity = axi_recd[i] ;

    endfunction : latest_activity



    //------------------------------------------------------------------------------
    // txn state machine
    //TODO make *_expd a state machine holding nextmsgs, rather than all remaining msgs
    //------------------------------------------------------------------------------

    //add a msg to this txn
    function add_msg(smi_seq_item msg);
        //DNE Ncore 3.0
        //if(msg.isCmeRspMsg() || msg.isTreRspMsg()) begin
        //    //error rsp ends txn immediately
        //    smi_expd.delete();
        //    axi_expd.delete();
        //end
        //else 
       `uvm_info($sformatf("%m"), $sformatf("ADD_MSG: txn=%p\nadd_msg=%p", this, msg), UVM_MEDIUM)
       if(smi_expd[msg.smi_conc_msg_class]) begin
          smi_recd[msg.smi_conc_msg_class] = msg;
          smi_expd.delete(msg.smi_conc_msg_class);
          if (msg.isDtwDbgReqMsg() || msg.isDtwDbgRspMsg() || msg.isSysReqMsg() || msg.isSysRspMsg()) begin
	     `uvm_info($sformatf("%m"), $sformatf("DEBUG: txn=%p, smi_expd=%0d, msg_id=%2h recd_msg_type=%2h unq_id=%p",
                                                  this, smi_expd.size(), msg.smi_msg_id, msg.smi_msg_type, msg.smi_unq_identifier), UVM_MEDIUM)
          end else begin
	     `uvm_info($sformatf("%m"), $sformatf("DEBUG: txn=%p, smi_expd=%0d, cmd msg_id=%2h recd_msg_type=%2h unq_id=%p",
                                                  this, smi_expd.size(), smi_recd[eConcMsgCmdReq].smi_msg_id, msg.smi_msg_type, msg.smi_unq_identifier), UVM_MEDIUM)
          end
           //txn ex_store with EX_FAIL is not expecting AXI Write transactions
           //#Check.DII.ExMon.ExFailDropped
           if ((msg.smi_msg_type inside {CMD_WR_NC_PTL, CMD_WR_NC_FULL})) begin
               if (m_exmon_status  == EX_FAIL) begin

                  axi_expd.delete(axi_aw);
                  axi_expd.delete(axi_w);
                  axi_expd.delete(axi_b);

               end

           end
      end
       else begin
          $stacktrace;
         `uvm_error($sformatf("%m (%s)", parent), $sformatf("msg not expd by this txn:\n%p\n%p", msg, this))
       end
    endfunction : add_msg


    //------------------------------------------------------------------------------
    // generate expected msgs
    //  for stimulus: overwrite the nonderivative data with rand after creation
    //  deliberately not using do_copy here.  in order to ensure that every field is accounted for.
    //------------------------------------------------------------------------------

    //triage which msg to gen
    // deliberately not generating common values here.  to ensure that all content is present explicity at a single call to the constructor.
    function smi_seq_item gen_exp_smi(smi_seq_item template);
        if (template == null)
            `uvm_error($sformatf("%m (%s)", parent), "DV ERROR must specify msg type to randomize msg");

        //constraints global to dii

        //#Check.DII.CMDreq.Ndp_protection
        //#Check.DII.STRreq.Ndp_protection
        //#Check.DII.DTRreq.Ndp_protection
        //#Check.DII.DTWreq.Ndp_protection
        <% if (smiObj.WSMINDPPROT_EN) { %>
        if(! (template.smi_ndp_protection inside {SMI_NDP_PROTECTION_NONE, SMI_NDP_PROTECTION_PARITY}))
            `uvm_error($sformatf("%m (%s)", parent), "disallowed smi_ndp_protection");
        <% } %>

        //#Check.DII.DTRreq.Dp_protection
        //#Check.DII.DTWreq.Dp_protection
        <% if (smiObj.WSMIDPPROT_EN) { %>
        if(! (template.smi_dp_protection inside {SMI_DP_PROTECTION_NONE, SMI_DP_PROTECTION_PARITY}))
            `uvm_error($sformatf("%m (%s)", parent), "disallowed smi_dp_protection");
        <% } %>

        case(template.smi_conc_msg_class)
            eConcMsgCmdReq:	    gen_exp_smi = gen_exp_smi__cmd_req(template) ;
            eConcMsgNcCmdRsp:	    gen_exp_smi = gen_exp_smi__cmd_rsp(template) ;

            eConcMsgStrReq:	    gen_exp_smi = gen_exp_smi__str_req(template) ;
            eConcMsgStrRsp:	    gen_exp_smi = gen_exp_smi__str_rsp(template) ;

            eConcMsgDtrReq:	    gen_exp_smi = gen_exp_smi__dtr_req(template) ;
            eConcMsgDtrRsp:	    gen_exp_smi = gen_exp_smi__dtr_rsp(template) ;
            eConcMsgDtwReq:	    gen_exp_smi = gen_exp_smi__dtw_req(template) ;
            eConcMsgDtwRsp:	    gen_exp_smi = gen_exp_smi__dtw_rsp(template) ;

            eConcMsgDtwDbgReq:      gen_exp_smi = gen_exp_smi__dtw_dbg_req(template) ;
            eConcMsgDtwDbgRsp:      gen_exp_smi = gen_exp_smi__dtw_dbg_rsp(template) ;
            //#Check.DII.EventMsg.SysReq
            eConcMsgSysReq :        gen_exp_smi = gen_exp_smi__sys_req(template) ;
            //#Check.DII.EventMsg.SysResp
            eConcMsgSysRsp :        gen_exp_smi = gen_exp_smi__sys_rsp(template) ;
            //dne v3.0
            // eConcMsgCmeRsp:     gen_exp_smi = gen_exp_smi__cme_rsp(template) ;
            // eConcMsgTreRsp:     gen_exp_smi = gen_exp_smi__tre_rsp(template) ;

            default:    begin
                      <% if(obj.testBench == 'dii') { %>
                      `ifndef CDNS
                        $stacktrace();
                      `else
                        $stacktrace;
                      `endif
                      <% } else { %>
                        $stacktrace();
                      <% } %>
                       `uvm_error($sformatf("%m (%s)", parent), $sformatf("invalid template class: %p; incomming cmd: %p",
                                                                           template.smi_conc_msg_class, template.convert2string()))
            end
        endcase
    endfunction : gen_exp_smi


    //-----------------------------------


    function smi_seq_item gen_exp_smi__cmd_req(smi_seq_item template = null);
        int wrong_dut_id;
        smi_rl_enum_t gen_exp_smi__cmd_req_smi_rl;
       
        if (template == null) begin
            template = new();
        end

        if (! $value$plusargs("wt_wrong_dut_id_cmd=%d", wrong_dut_id) ) begin
           wrong_dut_id = 0;
        end
        gen_exp_smi__cmd_req = smi_seq_item::type_id::create("gen_exp_smi__cmd_req");
        gen_exp_smi__cmd_req.not_RTL = 1;

        // CONC - 8836 and CONC - 8972 - cmdreq can have a RL of 2'b10 for a CMO if vz = 1
        gen_exp_smi__cmd_req_smi_rl = template.smi_vz ? (template.smi_msg_type == CMD_CLN_VLD || template.smi_msg_type == CMD_CLN_SH_PER || template.smi_msg_type == CMD_CLN_INV || template.smi_msg_type == CMD_MK_INV) ? SMI_RL_COHERENCY : SMI_RL_TRANSPORT : SMI_RL_TRANSPORT ;

//        gen_exp_smi__cmd_req.smi_mpf2 = template.smi_mpf2;
        gen_exp_smi__cmd_req.construct_cmdmsg(
            .smi_targ_ncore_unit_id (wrong_dut_id?template.smi_targ_ncore_unit_id:<%=obj.DiiInfo[obj.Id].FUnitId%>),   //#Check.DII.CMDreq.Dii_unit_id
            .smi_src_ncore_unit_id  (template.smi_src_ncore_unit_id),
            .smi_msg_type           (template.smi_msg_type),
            .smi_msg_id             (template.smi_msg_id),
            .smi_msg_tier           (template.smi_msg_tier),
            .smi_steer              (template.smi_steer),
            .smi_msg_qos            (template.smi_msg_qos),
            .smi_msg_pri            (template.smi_msg_pri),
            .smi_msg_err            (template.smi_msg_err),

            .smi_cmstatus           (template.smi_cmstatus),
            .smi_addr               (template.smi_addr),
            .smi_vz                 (template.smi_vz),                   //#Check.DII.CMDreq.Visible_iff_well_behaved  
            .smi_ca                 (template.smi_ca),                   // #Check.DII.CMDreq.Cacheable
            .smi_ac                 (template.smi_ac),
//            .smi_ch                 (0),                                 // #Check.DII.CMDreq.non_coherent
            .smi_ch                 (template.smi_ch),                   // CONC-7133. Random for NCORE3.0/3.1
            .smi_st                 (template.smi_st),
            .smi_en                 (template.smi_en),                                 
            .smi_es                 (template.smi_es),                   // #Check.DII.CMDreq.non_exclusive
            .smi_ns                 (template.smi_ns),
            .smi_pr                 (template.smi_pr),
            .smi_order              (template.smi_order),
            .smi_lk                 (SMI_LK_NOP),                        // #Check.DII.CMDreq.lock
            .smi_rl                 (gen_exp_smi__cmd_req_smi_rl),                  // #Check.DII.CMDreq.Response_level
            .smi_tm                 (template.smi_tm),

            .smi_mpf1_stash_valid   (template.smi_mpf1_stash_valid),     // for coherent only
            .smi_mpf1_stash_nid     (template.smi_mpf1_stash_nid),       // for coherent only
            .smi_mpf1_argv          (template.smi_mpf1_argv),            // for coherent only
            .smi_mpf1_burst_type    (template.smi_mpf1_burst_type),
            .smi_mpf1_alength       (template.smi_mpf1_alength),
            .smi_mpf1_asize         (template.smi_mpf1_asize),
            .smi_mpf1_awunique      (0),
            .smi_mpf2_stash_valid   (template.smi_mpf2_stash_valid),     // for coherent only
            .smi_mpf2_stash_lpid    (template.smi_mpf2_stash_lpid),      // for coherent only
            .smi_mpf2_flowid_valid  (template.smi_mpf2_flowid_valid),    // for coherent only
            .smi_mpf2_flowid        (template.smi_mpf2_flowid),          // for coherent only

            .smi_size               (template.smi_size),
            .smi_intfsize           (template.smi_intfsize),
            .smi_dest_id            (template.smi_dest_id),
            .smi_tof                (template.smi_tof),
            .smi_qos                (template.smi_qos),
            .smi_ndp_aux            (template.smi_ndp_aux)
        );

        //#Check.DII.CMDreq.Incr_in_cacheline
        if (
            (gen_exp_smi__cmd_req.smi_tof != SMI_TOF_CHI) && (gen_exp_smi__cmd_req.smi_mpf1_burst_type == INCR) &&
            ((((gen_exp_smi__cmd_req.smi_addr & (~(2**(gen_exp_smi__cmd_req.smi_intfsize+3)-1))) & (CACHELINESIZE-1)) +
              ((2**gen_exp_smi__cmd_req.smi_mpf1_asize)*(gen_exp_smi__cmd_req.smi_mpf1_alength+1)) > CACHELINESIZE))
           ) begin
           `uvm_error($sformatf("%m (%s)", parent), $sformatf("incrment start+size exceeds cache line size: cmd=%p", template.convert2string()))
        end

        //#Check.DII.CMDreq.Size
        if (2**gen_exp_smi__cmd_req.smi_size > CACHELINESIZE)
            `uvm_error($sformatf("%m (%s)", parent), "size out of bounds");
        
        //#Check.DII.CMDreq.IntfSize
        if (gen_exp_smi__cmd_req.smi_intfsize > 2)
            `uvm_error($sformatf("%m (%s)", parent), "intfsize out of bounds");

        //#Check.DII.CMDreq.tof
        if(! (gen_exp_smi__cmd_req.smi_tof inside {SMI_TOF_CHI, SMI_TOF_AXI, SMI_TOF_ACE}))
            `uvm_error($sformatf("%m (%s)", parent), "tof invalid");
        
        //#Check.DII.CMDreq.order
        if(! (gen_exp_smi__cmd_req.smi_order inside {SMI_ORDER_NONE, SMI_ORDER_WRITE, SMI_ORDER_REQUEST_WR_OBS, SMI_ORDER_ENDPOINT}))
            `uvm_error($sformatf("%m (%s)", parent), "order invalid");

    endfunction : gen_exp_smi__cmd_req


    function smi_seq_item gen_exp_smi__cmd_rsp(smi_seq_item template = null);
        if (template == null) begin
            template = new();
         end
        
        if(!smi_recd[eConcMsgCmdReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes cmd_req");

        gen_exp_smi__cmd_rsp = smi_seq_item::type_id::create("gen_exp_smi__cmd_rsp");
        gen_exp_smi__cmd_rsp.not_RTL = 1;
        gen_exp_smi__cmd_rsp.construct_nccmdrsp(
                                        .smi_targ_ncore_unit_id (smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id),
                                        .smi_msg_type           (NC_CMD_RSP),
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_tier           (smi_recd[eConcMsgCmdReq].smi_msg_tier),
					.smi_steer              (template.smi_steer),
                                        .smi_msg_pri            (smi_recd[eConcMsgCmdReq].smi_msg_pri),
                                        .smi_msg_qos            ('b0),
                                        .smi_msg_err            (template.smi_msg_err),
                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_tm                 (smi_recd[eConcMsgCmdReq].smi_tm),
                                        .smi_rmsg_id            (smi_recd[eConcMsgCmdReq].smi_msg_id)
                                        );
    endfunction : gen_exp_smi__cmd_rsp



    function smi_seq_item gen_exp_smi__str_req(smi_seq_item template = null);
        if (template == null) begin
            template = new();
         end
        
        if(!smi_recd[eConcMsgCmdReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes cmd_req");

        gen_exp_smi__str_req = smi_seq_item::type_id::create("gen_exp_smi__str_req");
        gen_exp_smi__str_req.not_RTL = 1;
        gen_exp_smi__str_req.construct_strmsg(
                                        .smi_targ_ncore_unit_id (smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id),
                                        .smi_msg_type           (STR_STATE), //#Check.DII.STRreq.Message_Type
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_tier           (smi_recd[eConcMsgCmdReq].smi_msg_tier),
					.smi_steer              (template.smi_steer),
                                        .smi_msg_err            (template.smi_msg_err),
                                        .smi_msg_pri            (smi_recd[eConcMsgCmdReq].smi_msg_pri),
                                        .smi_msg_qos            ('b0),

                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_cmstatus_so        (template.smi_cmstatus_so),
                                        .smi_cmstatus_ss        (template.smi_cmstatus_ss),
                                        .smi_cmstatus_sd        (template.smi_cmstatus_sd),
                                        .smi_cmstatus_st        (template.smi_cmstatus_st),
                                        .smi_cmstatus_state     (template.smi_cmstatus_state),
                                        .smi_cmstatus_snarf     (template.smi_cmstatus_snarf),
                                        .smi_cmstatus_exok      (template.smi_cmstatus_exok),
                                        .smi_tm                 (smi_recd[eConcMsgCmdReq].smi_tm),
                                        .smi_rbid               (template.smi_rbid),
                                        .smi_rmsg_id            (smi_recd[eConcMsgCmdReq].smi_msg_id), //#Check.DII.STRreq.RMessageId
                                        .smi_mpf1               (template.smi_mpf1),
                                        .smi_mpf2               (template.smi_mpf2),
                                        .smi_intfsize           (template.smi_intfsize)       // DII's STR_REQ does not contain valid intfsize
                                        );


        //#Check.DII.STRreq.Return_buffer_id
        if(
            (smi_recd[eConcMsgCmdReq].isCmdNcWrMsg())
            && (gen_exp_smi__str_req.smi_rbid >= <%=obj.nWttCtrlEntries%>)
        )
            `uvm_error($sformatf("%m (%s)", parent), "rbid out of range");

       //#Check.DII.STRreq.cm_status
       if ((smi_recd[eConcMsgCmdReq].isCmdNcRdMsg()) && (smi_recd[eConcMsgCmdReq].smi_es == 1'b1)) begin
          if((gen_exp_smi__str_req.smi_cmstatus != 8'b0) || (gen_exp_smi__str_req.smi_cmstatus_exok != 1'b0))
             `uvm_error($sformatf("%m (%s)", parent), "STR_REQ cm_status is non zero");
       end
   
    endfunction : gen_exp_smi__str_req


    function smi_seq_item gen_exp_smi__str_rsp(smi_seq_item template = null);
        if (template == null) begin
            template = new();
         end
        
        if(!smi_recd[eConcMsgStrReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes str_req");

        gen_exp_smi__str_rsp = smi_seq_item::type_id::create("gen_exp_smi__str_rsp");
        gen_exp_smi__str_rsp.not_RTL = 1;
        gen_exp_smi__str_rsp.construct_strrsp(
                                        .smi_targ_ncore_unit_id (smi_recd[eConcMsgStrReq].smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (smi_recd[eConcMsgStrReq].smi_targ_ncore_unit_id),
                                        .smi_msg_type           (STR_RSP),
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_tier           (smi_recd[eConcMsgStrReq].smi_msg_tier),
					.smi_steer              (template.smi_steer),
                                        .smi_msg_pri            (template.smi_msg_pri),
                                        .smi_msg_qos            ('b0),

                                        .smi_tm                 (smi_recd[eConcMsgStrReq].smi_tm),
                                        .smi_rmsg_id            (smi_recd[eConcMsgStrReq].smi_msg_id),
                                        .smi_msg_err            (template.smi_msg_err),
                                        .smi_cmstatus           (template.smi_cmstatus)
                                        );
    endfunction : gen_exp_smi__str_rsp


    function smi_seq_item gen_exp_smi__dtr_req(smi_seq_item template = null);
        smi_dp_concuser_t dp_concuser[];
        smi_dp_dwid_t     dp_dwid[];
        int               smi_dp_beats;
        axi4_read_data_pkt_t tmp_axi__r;
        axi_rresp_t       axi_rresp;
        axi_rresp_t       merged_bus_rresp[];
        axi_rresp_t       axi_rresp_per_dw[];
        axi_rresp_t       r_axi_rresp_per_dw[];
        axi_rresp_t       merged_rresp_per_dw[8];
        smi_cmstatus_t    smi_cmstatus;
        smi_cmstatus_t    t_smi_cmstatus;
        smi_addr_t        smi_addr_dw;
        int               intf_size;
        int               intfsize_dw, bus_size_dw;
        smi_dp_dbad_t     dp_dbad[];
        int               dbad_offset;
        int               bus_offset_dw;
        int               axi_offset_dw;
        int               intf_offset_dw;
        int               wrap_base;
        int               wrap_top;
        int               access_size_dw;
        int               num_smi_beats; // allocate one extra
        int               rresp_size_per_beat;
        int               axi_size_dw;
        int               offset_limit;
        smi_dp_dwid_t     t_dp_dwid[];
        bit               ok;
       
        if(!this.smi_recd[eConcMsgCmdReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes cmd_req")
        if(!this.axi_recd[axi_r])
            `uvm_error($sformatf("%m (%s)", parent), "precedes axi_r")
        if(!this.axi_read_data_pkt)
	    `uvm_error($sformatf("%m (%s)", parent), $sformatf("axi_read_data_pkt is NULL.\ntxn:%p\ncmd:%p\naxi_ar:%p",
                       this, smi_recd[eConcMsgCmdReq],this.axi_read_addr_pkt))
        if (template == null) begin
	   `uvm_error($sformatf("%m (%s)", parent), $sformatf("does expect null template"))
        end

        `uvm_info($sformatf("%m"), $sformatf("AuxPresent=%0d, smisize=%0d, DATA=%0d",
                                             <%=obj.Widths.Concerto.Dp.Aux.wDpAux%>, smi_recd[eConcMsgCmdReq].smi_size,<%=obj.DiiInfo[obj.Id].wData%>), UVM_HIGH)
        <% if ( obj.Widths.Concerto.Dp.Aux.wDpAux > 0 ) { %>
        dp_concuser = new [(2**smi_recd[eConcMsgCmdReq].smi_size)/(wSmiDPdata/8)] ;
        foreach(dp_concuser[i])
            dp_concuser[i] = this.axi_read_data_pkt.ruser;
        <% } %>

        tmp_axi__r = new();
        tmp_axi__r.copy(this.axi_read_data_pkt);  //most of axi r pkt already checked when arrived

        intf_size    = smi_recd[eConcMsgCmdReq].smi_intfsize;
        smi_dp_beats = max((2**(intf_size+3)),(2**smi_recd[eConcMsgCmdReq].smi_size))/(wSmiDPdata/8);
        rresp_size_per_beat = (smi_recd[eConcMsgCmdReq].smi_st)?(2**max((this.axi_read_addr_pkt.arsize-3),0)):max(WXDATA/64,1);
        if (smi_dp_beats == 0) smi_dp_beats = 1;
        dp_dwid      = new [smi_dp_beats];
        dp_dbad      = new [smi_dp_beats];
        `uvm_info($sformatf("%m"), $sformatf("DWID: beats=%0d, smi_size_dw=%0d, data_dw=%0d",
                                             smi_dp_beats, 2**smi_recd[eConcMsgCmdReq].smi_size/8, wSmiDPdata/64), UVM_HIGH)
        foreach (tmp_axi__r.rresp_per_beat[i]) begin
           `uvm_info($sformatf("%m"), $sformatf("DBAD: rresp[%0d]=%0d (dw per beat %0d total %0d)", i, tmp_axi__r.rresp_per_beat[i],
                                                rresp_size_per_beat, tmp_axi__r.rresp_per_beat.size()), UVM_HIGH)
        end

        // cmstatus takes the rresp from first data beat. dbad will take care of the other beats if the access does not wrap. Otherwise, need to check all rrsp
        smi_addr_dw    = this.smi_recd[eConcMsgCmdReq].smi_addr >> 3;
        intfsize_dw    = (2**this.smi_recd[eConcMsgCmdReq].smi_intfsize);
        bus_size_dw    = max(WXDATA/64, 1);
        intf_offset_dw = ((this.smi_recd[eConcMsgCmdReq].smi_addr >> 3) & (intfsize_dw-1));
        axi_size_dw    = 2**max(this.axi_read_addr_pkt.arsize-3,0);
        axi_offset_dw  = ((this.axi_read_addr_pkt.araddr >> 3) & (axi_size_dw-1));
        bus_offset_dw  = ((this.smi_recd[eConcMsgCmdReq].smi_addr >> 3) & (bus_size_dw-1));
        access_size_dw = axi_size_dw*(this.axi_read_addr_pkt.arlen+1);

        // need to adjust for INCR access
        if (((this.smi_recd[eConcMsgCmdReq].smi_tof != SMI_TOF_CHI) || (this.smi_recd[eConcMsgCmdReq].smi_st)) && (this.axi_read_addr_pkt.arburst != AXIWRAP)) begin
           access_size_dw = access_size_dw - (bus_offset_dw%axi_size_dw);
        end
        wrap_base      = ((this.axi_read_addr_pkt.arburst == AXIWRAP) || ((this.smi_recd[eConcMsgCmdReq].smi_tof == SMI_TOF_CHI) && (this.smi_recd[eConcMsgCmdReq].smi_st == 0))) ?
                          (smi_addr_dw & (~(access_size_dw-1)) & (intfsize_dw-1)) : (smi_addr_dw & (intfsize_dw-1));
        wrap_top       = wrap_base + access_size_dw;

        for (int i=0; i<smi_dp_beats; i++) begin
	   dp_dwid[i] = calcDwid(smi_recd[eConcMsgCmdReq], i);
        end

        // get AXI responses for each DW
        axi_rresp_per_dw   = new[8];
        r_axi_rresp_per_dw = new[8+3];  // array larger for rotation

        foreach (axi_rresp_per_dw[i]) begin
           axi_rresp_per_dw[i] = 0;
        end
        foreach (r_axi_rresp_per_dw[i]) begin
           r_axi_rresp_per_dw[i] = 0;
        end
        foreach (merged_rresp_per_dw[i]) begin
           merged_rresp_per_dw[i] = 0;
        end
        foreach (tmp_axi__r.rresp_per_beat[i]) begin
           `uvm_info($sformatf("%m"), $sformatf("RRESP M0: rresp per dw[%0d] = %0h size = %0d", i, tmp_axi__r.rresp_per_beat[i], rresp_size_per_beat), UVM_HIGH)
        end
       
        for (int i=0; i<(this.axi_read_addr_pkt.arlen+1); i++) begin
           for (int j=0; j<rresp_size_per_beat; j++) begin
              axi_rresp_per_dw[i*rresp_size_per_beat+j] = tmp_axi__r.rresp_per_beat[i] ;
           end
        end
        foreach (axi_rresp_per_dw[i]) begin
           `uvm_info($sformatf("%m"), $sformatf("RRESP M1: resp per dw[%0d] = %0h for %0d dw", i, axi_rresp_per_dw[i], rresp_size_per_beat), UVM_HIGH)
        end

        // May need to rotate to align with host interface data width
        for (int i=0; i<max(access_size_dw,intfsize_dw); i++) begin
           int bus_idx;
           int intf_idx;
           int bus_acc_top;
           
           if (i >= access_size_dw) break;
           if (access_size_dw < intfsize_dw) begin
              bus_acc_top = ((axi_read_addr_pkt.arburst == AXIWRAP) || ((this.smi_recd[eConcMsgCmdReq].smi_tof == SMI_TOF_CHI) && (this.smi_recd[eConcMsgCmdReq].smi_st == 0))) ?
                            ((intf_offset_dw&(~(access_size_dw-1)))+access_size_dw):max(access_size_dw,intfsize_dw);
           end else begin
              bus_acc_top = ((axi_read_addr_pkt.arburst == AXIWRAP) || ((this.smi_recd[eConcMsgCmdReq].smi_tof == SMI_TOF_CHI) && (this.smi_recd[eConcMsgCmdReq].smi_st == 0))) ?
                            access_size_dw:CACHELINESIZE/8;
           end
           if (intfsize_dw < bus_size_dw) begin
              // may need to shift rresp so first beat will get the critical dword
              if (this.smi_recd[eConcMsgCmdReq].smi_st == 0) begin
                 bus_idx  = (bus_offset_dw+i)  - (((bus_offset_dw+i) >=bus_acc_top)?access_size_dw:0);
                 intf_idx = (intf_offset_dw+i) - (((intf_offset_dw+i)>=bus_acc_top)?access_size_dw:0);
                 r_axi_rresp_per_dw[intf_idx] = axi_rresp_per_dw[bus_idx];
                 `uvm_info($sformatf("%m"), $sformatf("RRESP N0: intf idx=%0d, bus_idx=%0d", intf_idx, bus_idx), UVM_MEDIUM)
              end else begin
                 bus_offset_dw   &= (axi_size_dw-1);
                 intf_offset_dw  &= (axi_size_dw-1);
                 bus_idx  = (bus_offset_dw+i)  - (((bus_offset_dw+i) >=bus_acc_top)?access_size_dw:0);
                 intf_idx = (intf_offset_dw+i) - (((intf_offset_dw+i)>=bus_acc_top)?access_size_dw:0);
                 r_axi_rresp_per_dw[intf_idx] = axi_rresp_per_dw[bus_idx];
                 `uvm_info($sformatf("%m"), $sformatf("RRESP N1: intf idx=%0d, bus_idx=%0d", intf_idx, bus_idx), UVM_MEDIUM)
              end
           end else begin // if (intfsize_dw < bus_size_dw)
              if (this.smi_recd[eConcMsgCmdReq].smi_st == 0) begin
                 // data is bus aligned for normal memory
                 bus_idx  = (bus_offset_dw+i)  - (((bus_offset_dw+i) >=bus_acc_top)?access_size_dw:0);
                 intf_idx = (intf_offset_dw+i) - (((intf_offset_dw+i)>=bus_acc_top)?access_size_dw:0);
                 r_axi_rresp_per_dw[intf_idx] = axi_rresp_per_dw[bus_idx];
                 `uvm_info($sformatf("%m"), $sformatf("RRESP N2: intf idx=%0d, bus_idx=%0d", intf_idx, bus_idx), UVM_MEDIUM)
              end else begin
                 bus_offset_dw  &= (~(axi_size_dw-1));
                 intf_offset_dw &= (~(axi_size_dw-1));
                 bus_idx  = (bus_offset_dw+i) - (((bus_offset_dw+i)>=bus_acc_top)?access_size_dw:0);
                 intf_idx = (intf_offset_dw+i) - (((intf_offset_dw+i)>=bus_acc_top)?access_size_dw:0);
                 r_axi_rresp_per_dw[intf_idx] = axi_rresp_per_dw[i];
                 `uvm_info($sformatf("%m"), $sformatf("RRESP N3: intf idx=%0d, bus_idx=%0d", intf_idx, i), UVM_MEDIUM)
              end
           end // else: !if(intfsize_dw < bus_size_dw)
        end // for (int i=0; i<max(access_size_dw,intfsize_dw); i++)
        `uvm_info($sformatf("%m"), $sformatf("RRESP N5: smi_st:%0d intfsize=%0d bus_size=%0d access_dw=%0d intf_offset=%0d bus_offset=%0d",
                                             this.smi_recd[eConcMsgCmdReq].smi_st, intfsize_dw, bus_size_dw, access_size_dw, intf_offset_dw, bus_offset_dw), UVM_MEDIUM)
        foreach (r_axi_rresp_per_dw[i]) begin
           `uvm_info($sformatf("%m"), $sformatf("RRESP N6: smi_dw[%0d]=%0d", i, r_axi_rresp_per_dw[i]), UVM_HIGH)
        end

        // first merge axi accesses into smi bus accesses. This will happen for device
        num_smi_beats    = access_size_dw/bus_size_dw + ((access_size_dw<bus_size_dw)?1:0);
        merged_bus_rresp = new[num_smi_beats];
        for (int i=0; i<num_smi_beats; i++) begin
           merged_bus_rresp[i] = 0;
        end
        if (axi_size_dw < bus_size_dw) begin
           int bus_idx;
           int effective_bo = this.smi_recd[eConcMsgCmdReq].smi_st ? bus_offset_dw : 0;
           int arlen = this.axi_read_addr_pkt.arlen+1;
           for (int i=0; i<access_size_dw; i++) begin
              bus_idx = (i+effective_bo)/bus_size_dw - ((((i+effective_bo)/bus_size_dw) < num_smi_beats) ? 0 : (((i+effective_bo)/bus_size_dw)-num_smi_beats));
              if (merged_bus_rresp[bus_idx] < 1) begin
                 merged_bus_rresp[bus_idx] = tmp_axi__r.rresp_per_beat[(i/axi_size_dw)%arlen];
              end else if ((merged_bus_rresp[bus_idx] < 2) && (tmp_axi__r.rresp_per_beat[(i/axi_size_dw)%arlen] > 0)) begin
                 merged_bus_rresp[bus_idx] = tmp_axi__r.rresp_per_beat[(i/axi_size_dw)%arlen];
              end else if (tmp_axi__r.rresp_per_beat[(i/axi_size_dw)%arlen] == 3) begin
                 merged_bus_rresp[bus_idx] = 3;
              end
              `uvm_info($sformatf("%m"), $sformatf("RRESP F0: Merged rresp[%0d]=%0d RRESP[%0d]=%0d",
                                                   bus_idx/bus_size_dw, merged_bus_rresp[bus_idx],
                                                   (i/axi_size_dw)%arlen, tmp_axi__r.rresp_per_beat[(i/axi_size_dw)%arlen]), UVM_HIGH)
           end // for (int i=0; i<access_size_dw; i++)
        end else begin // for (int i=0; i<access_size_dw; i++)
           for (int i=0; i<(this.axi_read_addr_pkt.arlen+1); i++) begin
              merged_bus_rresp[i] = tmp_axi__r.rresp_per_beat[i];
              `uvm_info($sformatf("%m"), $sformatf("RRESP F1: Merged rresp[%0d]=%0d RRESP[%0d]=%0d", i, merged_bus_rresp[i], i, tmp_axi__r.rresp_per_beat[i]), UVM_HIGH)
           end
        end // else: !if(axi_size_dw < bus_size_dw)
        `uvm_info($sformatf("%m"), $sformatf("RRESP FN: Addr=%0h AW=%0d BW=%0d BOFF=%0d IOFF=%0d Merged rresp: size=%0d [0]=%0d [N]=%0d",
                                             this.axi_read_addr_pkt.araddr, access_size_dw, bus_size_dw, bus_offset_dw, intf_offset_dw,
                                             (access_size_dw+bus_offset_dw-1)/bus_size_dw, merged_bus_rresp[0],
                                             merged_bus_rresp[(access_size_dw+bus_offset_dw-1)/bus_size_dw]), UVM_HIGH)
        axi_rresp        = merged_bus_rresp[0];
        if (intfsize_dw < bus_size_dw) begin
           if ( (axi_read_addr_pkt.arburst == AXIWRAP) && (bus_offset_dw > 0) ) begin
              if (axi_rresp <= 1) begin
                 axi_rresp = merged_bus_rresp[num_smi_beats-1];
              end else if (merged_bus_rresp[num_smi_beats-1] == 3) begin
                 axi_rresp = 3;
              end
           end
           `uvm_info($sformatf("%m"), $sformatf("RRESP G1: axi_rresp=%0d (merged rresp[%0d]=%0d (AW=%0d BO=%0d)", axi_rresp, num_smi_beats-1,
                                                bus_offset_dw?merged_bus_rresp[num_smi_beats-1]:merged_bus_rresp[0], access_size_dw, bus_offset_dw), UVM_HIGH)
        end else if (intfsize_dw > min(bus_size_dw, axi_size_dw)) begin // if (intfsize_dw < bus_size_dw)
           // no merging. Get smi bus cycle 0
           int offset     = intf_offset_dw % access_size_dw;
           int last_entry = ((access_size_dw+bus_offset_dw)/(bus_size_dw))-1;
           if ( (offset > 0) && (this.axi_read_addr_pkt.arburst == AXIWRAP) ) begin
              axi_rresp = merged_bus_rresp[last_entry-(offset/bus_size_dw)+1];
           end
           `uvm_info($sformatf("%m"), $sformatf("RRESP G2: last=%0d axi_rresp=%0d (merged rresp[%0d])", last_entry, axi_rresp, last_entry-(offset/bus_size_dw)+1), UVM_HIGH)
        end
       
        dp_dbad   = new[template.smi_dp_dbad.size()];
        foreach (dp_dbad[i]) begin
           dp_dbad[i] = 0;
        end

       for (int i=0; i<max(access_size_dw,intfsize_dw); i++) begin
          dp_dbad[i/bus_size_dw] |= ((r_axi_rresp_per_dw[i] > 1) << (i%bus_size_dw));
       end

        // handle garbage data at the beginning
        `uvm_info($sformatf("%m"), $sformatf("DBAD: intf_dw:%0d bus_dw:%0d intf_off:%0d bus_off:%0d smi_offset=%0d BT:%p size:%0d ST:%0d",
                                             intfsize_dw, bus_size_dw, intf_offset_dw, bus_offset_dw, smi_addr_dw&(bus_size_dw-1), this.axi_read_addr_pkt.arburst, access_size_dw,
                                             smi_recd[eConcMsgCmdReq].smi_st), UVM_HIGH)
        foreach (dp_dbad[i]) begin
           `uvm_info($sformatf("%m"), $sformatf("Before Prefill: dp_dbad[%0d]=%0h", i, dp_dbad[i]), UVM_HIGH)
        end

        if (intf_offset_dw > 0) begin
           int idx    ;
           int offset ;
           int limit;

           limit = (axi_read_addr_pkt.arburst != AXIWRAP) ? intf_offset_dw : (intf_offset_dw & (~(access_size_dw-1)));
           for (int i=0; i<limit; i++) begin
                 idx    = i/bus_size_dw;
                 offset = i%bus_size_dw;
                 dp_dbad[idx][offset*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] = template.smi_dp_dbad[idx][offset*WSMIDPDBADPERDW +: WSMIDPDBADPERDW];
                 `uvm_info($sformatf("%m"), $sformatf("Prefill: i=%0d: dp_dbad[%0d]=%0h (offset=%0d)", i, idx, dp_dbad[idx], offset), UVM_HIGH)
           end
        end
        foreach (dp_dbad[i]) begin
           `uvm_info($sformatf("%m"), $sformatf("After Prefill: dp_dbad[%0d]=%0h", i, dp_dbad[i]), UVM_HIGH)
        end

        // handle garbage data at the end
        begin : postFill
           int idx    ;
           int offset ;
           int start_idx;
           int end_idx;

           start_idx = (((axi_read_addr_pkt.arburst != AXIWRAP) ? (intf_offset_dw + access_size_dw - 1) : ((intf_offset_dw&(~(access_size_dw-1))) + access_size_dw))) &
                       (max(access_size_dw,max(intfsize_dw, bus_size_dw))-1);
           end_idx = template.smi_dp_dwid.size()*bus_size_dw;
           //end_idx   = ((start_idx/max(intfsize_dw, bus_size_dw))+1)*max(intfsize_dw, bus_size_dw);
           for (int i=start_idx; i<end_idx; i++) begin
              idx    = i/bus_size_dw;
              offset = i%bus_size_dw;
              if (idx < dp_dwid.size()) begin
                 dp_dwid[idx][offset*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] = template.smi_dp_dwid[idx][offset*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW];
                 dp_dbad[idx][offset*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] = template.smi_dp_dbad[idx][offset*WSMIDPDBADPERDW +: WSMIDPDBADPERDW];
                 `uvm_info($sformatf("%m"), $sformatf("Postfill: i=%0d: dp_dbad[%0d]=%0h (offset=%0d start=%0d end=%0d) accsize=%0d",
                                                      i, idx, dp_dbad[idx], offset, start_idx, end_idx, access_size_dw), UVM_HIGH)
              end
           end
        end : postFill
        foreach (dp_dbad[i]) begin
           `uvm_info($sformatf("%m"), $sformatf("After Postfill: dp_dbad[%0d]=%0h", i, dp_dbad[i]), UVM_HIGH)
        end

        `uvm_info($sformatf("%m"), $sformatf("DBAD: dp_beats:%0d wSmiDP:%0d", smi_dp_beats, wSmiDPdata/64), UVM_HIGH)

        if (|axi_rresp == 1'bX) begin
           `uvm_error($sformatf("%m"), $sformatf("AXI READ Resp has X: %p; axi_pkt:%p", axi_rresp, tmp_axi__r.rresp_per_beat[0]))
        end
       // if (axi_rresp > 1) begin // decode error or slave error
           //smi_cmstatus = (axi_rresp == 2) ? 8'b10000011 : 8'b10000100;
        //end else begin
            if (exmon_size > 0 ) begin
               if (m_exmon_status == EX_PASS) begin // Case of Exclusive Read 
                  smi_cmstatus = 8'b00000001;
               end else begin   // Case of Non-Exclusive Read 

                  smi_cmstatus = 8'b00000000;
               end
            end
           // else  begin 
              // smi_cmstatus = 8'b00000000 | axi_rresp;
           // end
       // end
<% if(obj.testBench == 'dii' ||(obj.testBench=="fsys")) { %>
`ifndef VCS
        `uvm_info($sformatf("%m"), $sformatf("DTR REQ: axi rid:%p axi rresp:%p; cmstatus:%p dp_dbad:%p",
                                             tmp_axi__r.rid, {<<{tmp_axi__r.rresp_per_beat}}, smi_cmstatus, dp_dbad), UVM_HIGH)
`endif // `ifndef VCS
<% } else {%>
        `uvm_info($sformatf("%m"), $sformatf("DTR REQ: axi rid:%p axi rresp:%p; cmstatus:%p dp_dbad:%p",
                                             tmp_axi__r.rid, {<<{tmp_axi__r.rresp_per_beat}}, smi_cmstatus, dp_dbad), UVM_HIGH)
<% } %>
        bus_offset_dw  = ((this.smi_recd[eConcMsgCmdReq].smi_addr >> 3) & (bus_size_dw-1));
        // If rotation is done, then cmstatus will be based on either the first transfer, or the whole payload
        
        if (exmon_size > 0) t_smi_cmstatus = smi_cmstatus;
        else t_smi_cmstatus = 0;
        if (axi_read_addr_pkt.arburst != AXIWRAP) begin
           for (int i=0; i<(bus_size_dw-bus_offset_dw); i++) begin
              if (t_smi_cmstatus == 0) t_smi_cmstatus = (axi_rresp_per_dw[i] < 1) ? 8'h00 : ((axi_rresp_per_dw[i] < 2) ? 8'h01 : ((axi_rresp_per_dw[i] == 2) ? 8'h83 : 8'h84));
              else if ((t_smi_cmstatus < 2) && (axi_rresp_per_dw[i] == 2)) t_smi_cmstatus = 8'h83;
              else if (axi_rresp_per_dw[i] == 3)                           t_smi_cmstatus = 8'h84;
              `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS 0: intf_dw:%0d bus_dw:%0d i=%0d rresp=%0d cmstatus=%0h", intfsize_dw, bus_size_dw, i, axi_rresp_per_dw[i], t_smi_cmstatus), UVM_HIGH);
           end
           `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS 0: intf_dw:%0d bus_dw:%0d bo:%0d rresp=%p cmstatus=%0h", intfsize_dw, bus_size_dw, bus_offset_dw, axi_rresp_per_dw, t_smi_cmstatus), UVM_HIGH);
        end else begin
           int         bus_idx, axi_idx, idx;
           int         adjusted_bus_offset_dw;
           axi_rresp_t merged_rresp;
           axi_rresp_t rr;

           // for RTL, for each bus_size, there is only on rresp stored. So need to merge
           // for st==0 the access will be bus aligned if access_size_dw > bus_size_dw
           adjusted_bus_offset_dw = (this.smi_recd[eConcMsgCmdReq].smi_st == 0) ? 0 : bus_offset_dw;
           merged_rresp           = 0;

           if (access_size_dw < bus_size_dw) begin
              for (int i=0; i<bus_size_dw; i++) begin
                 bus_idx = (((adjusted_bus_offset_dw)&(access_size_dw-1))+i)&(bus_size_dw-1);
                 axi_idx = (access_size_dw-(adjusted_bus_offset_dw&(access_size_dw-1))+i)&(access_size_dw-1);
                 rr = axi_rresp_per_dw[axi_idx];

                 if (merged_rresp == 0)                      merged_rresp = rr;
                 else if ( (merged_rresp < 2) && (rr >= 2) ) merged_rresp = rr;
                 else if ( rr == 3 )                         merged_rresp = rr;
              end
              for (int i=0; i<bus_size_dw; i++) begin
                 merged_rresp_per_dw[i/bus_size_dw]       = merged_rresp;
              end
           end else begin
              for (int i=0; i<access_size_dw; i++) begin
                 bus_idx = ((adjusted_bus_offset_dw&(~(access_size_dw-1))) + i)&(bus_size_dw-1);
                 axi_idx = (access_size_dw-(adjusted_bus_offset_dw&(access_size_dw-1))+i)&(access_size_dw-1);
                 rr = axi_rresp_per_dw[axi_idx];

                 if (merged_rresp == 0)                      merged_rresp = rr;
                 else if ( (merged_rresp < 2) && (rr >= 2) ) merged_rresp = rr;
                 else if ( rr == 3 )                         merged_rresp = rr;

                 `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS M0: i=%0d: bus_idx=%0d axi_idx=%0d per_dw_idx=%0d merged_rresp=%0d",
                                                      i, bus_idx, axi_idx, i/bus_size_dw, merged_rresp), UVM_HIGH)
                 if ((i&(bus_size_dw-1))==(bus_size_dw-1)) begin
                    for (int j=i-(bus_size_dw-1); j<=i; j++) begin
                       merged_rresp_per_dw[j] = merged_rresp;
                       `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS M1: j=%0d merged_rresp=%0d", j, merged_rresp), UVM_HIGH)
                    end
                    merged_rresp              = 0;
                 end
              end
           end
           `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS M: accsize:%0d bo:%0d io:%0d intf_dw:%0d bus_dw:%0d merged_rresp:%p raw_rresp:%p",
                                                access_size_dw, bus_offset_dw, intf_offset_dw, intfsize_dw, bus_size_dw, merged_rresp_per_dw, axi_rresp_per_dw), UVM_HIGH)
           
           if (this.smi_recd[eConcMsgCmdReq].smi_st == 1) begin
              if (intfsize_dw < bus_size_dw) begin
                 for (int i=0; i<min(access_size_dw, bus_size_dw); i++) begin
                    idx = (bus_offset_dw+i)&(access_size_dw-1);
                    if (t_smi_cmstatus == 0) t_smi_cmstatus = (merged_rresp_per_dw[idx] < 1) ? 8'h00 : ((merged_rresp_per_dw[idx] < 2) ? 8'h01 : ((merged_rresp_per_dw[idx] == 2) ? 8'h83 : 8'h84));
                    else if ((t_smi_cmstatus < 2) && (merged_rresp_per_dw[idx] == 2)) t_smi_cmstatus = 8'h83;
                    else if (merged_rresp_per_dw[idx] == 3)                           t_smi_cmstatus = 8'h84;
                    `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS 1: accsize:%0d bo:%0d io:%0d intf_dw:%0d bus_dw:%0d idx:%0d rresp=%0d cmstatus=%0h",
                                                         access_size_dw, bus_offset_dw, intf_offset_dw, intfsize_dw, bus_size_dw, idx, merged_rresp_per_dw[idx], t_smi_cmstatus), UVM_HIGH);
                 end
              end else begin
                 for (int i=0; i<min(access_size_dw, bus_size_dw); i++) begin
                    idx = (access_size_dw-intf_offset_dw+i)&(access_size_dw-1);
                    if (t_smi_cmstatus == 0) t_smi_cmstatus = (merged_rresp_per_dw[idx] < 1) ? 8'h00 : ((merged_rresp_per_dw[idx] < 2) ? 8'h01 : ((merged_rresp_per_dw[idx] == 2) ? 8'h83 : 8'h84));
                    else if ((t_smi_cmstatus < 2) && (merged_rresp_per_dw[idx] == 2)) t_smi_cmstatus = 8'h83;
                    else if (merged_rresp_per_dw[idx] == 3)                           t_smi_cmstatus = 8'h84;
                    `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS 2: accsize:%0d bo:%0d io:%0d intf_dw:%0d bus_dw:%0d idx:%0d rresp=%0d cmstatus=%0h",
                                                         access_size_dw, bus_offset_dw, intf_offset_dw, intfsize_dw, bus_size_dw, idx, merged_rresp_per_dw[idx], t_smi_cmstatus), UVM_HIGH);
                 end
              end                    
           end else begin // if (this.smi_recd[eConcMsgCmdReq].smi_st == 1)
              int start_addr;
              int end_addr;
              // Note for non-device, accesses are always bus size aligned
              if (intfsize_dw < bus_size_dw) begin
                 // for non-device, SMI packet is contained in a single bus response
                 start_addr = (intf_offset_dw & (~(bus_size_dw-1)));
                 end_addr   = (start_addr > 0) ? min(intfsize_dw, start_addr+access_size_dw) : min(intfsize_dw, access_size_dw);
                 for (int i=start_addr; i<end_addr; i++) begin
                    if (t_smi_cmstatus == 0) t_smi_cmstatus = (merged_rresp_per_dw[i+start_addr] < 1) ? 8'h00 : ((merged_rresp_per_dw[i+start_addr] < 2) ? 8'h01 : ((merged_rresp_per_dw[i+start_addr] == 2) ? 8'h83 : 8'h84));
                    else if ((t_smi_cmstatus < 2) && (merged_rresp_per_dw[i+start_addr] == 2)) t_smi_cmstatus = 8'h83;
                    else if (merged_rresp_per_dw[i+start_addr] == 3)                           t_smi_cmstatus = 8'h84;
                    `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS 5: intf_dw:%0d bus_dw:%0d io=%0d bo=%0d start_addr=%0d rresp=%p idx=%0d rresp[]=%d cmstatus=%p",
                                                         intfsize_dw, bus_size_dw, intf_offset_dw, start_addr, start_addr, merged_rresp_per_dw, i, merged_rresp_per_dw[i], t_smi_cmstatus), UVM_HIGH);
                 end
              end else begin // if (intfsize_dw <= bus_size_dw)
                 // may need rotation (combining two bus responses) to form a SMI packet
                 // Need to find the starting address first
                 // for non-device accesses, the address is bus size aligned

                 // start address may be different from 0 if this is wrapped access
                 int offset;
//                 offset          = ((access_size_dw < intfsize_dw) ? (intf_offset_dw - ((this.axi_read_addr_pkt.araddr>>3)&(intfsize_dw-1))) : intf_offset_dw) & (~(bus_size_dw-1));
                 offset          = (intf_offset_dw) & (~(bus_size_dw-1));

                 `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS DBG: intf_dw:%0d bus_dw:%0d io=%0d bo=%0d start_addr=%0d end_addr=%0d offset=%0d",
                                                      intfsize_dw, bus_size_dw, intf_offset_dw, bus_offset_dw, start_addr, access_size_dw, offset), UVM_HIGH);
                 if ( (offset == 0) || (this.axi_read_addr_pkt.arburst != AXIWRAP) ) begin
                    for (int i=0; i<bus_size_dw; i++) begin
                       if (t_smi_cmstatus == 0) t_smi_cmstatus = (merged_rresp_per_dw[i] < 1) ? 8'h00 : ((merged_rresp_per_dw[i] < 2) ? 8'h01 : ((merged_rresp_per_dw[i] == 2) ? 8'h83 : 8'h84));
                       else if ((t_smi_cmstatus < 2) && (merged_rresp_per_dw[i] == 2)) t_smi_cmstatus = 8'h83;
                       else if (merged_rresp_per_dw[i] == 3)                           t_smi_cmstatus = 8'h84;
                       `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS 6: intf_dw:%0d bus_dw:%0d io=%0d bo=%0d start_addr=%0d rresp=%p idx=%0d rresp[]=%d cmstatus=%p",
                                                            intfsize_dw, bus_size_dw, intf_offset_dw, bus_offset_dw, start_addr, merged_rresp_per_dw, i, merged_rresp_per_dw[i], t_smi_cmstatus), UVM_HIGH);
                    end
                 end else begin
                    // get to the address of the first SMI packet
                    // for the case that starting address is outside of the access, the CMSTATUS will indicate no error
                    if (((intf_offset_dw & (~(access_size_dw-1))) > 0) && ((intf_offset_dw & (~(access_size_dw-1))) != intf_offset_dw) && (template.smi_cmstatus == 0)) begin
                       //t_smi_cmstatus = 0;
                       `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS 7: intf_dw:%0d bus_dw:%0d acc_size_dw:%0d io=%0d bo=%0d",
                                                            intfsize_dw, bus_size_dw, access_size_dw, intf_offset_dw, bus_offset_dw), UVM_HIGH)
                    end else begin
                       // first adjust offset for multiples of bus_sizes
                       int inx;
                       start_addr = (access_size_dw - ((intf_offset_dw & (access_size_dw-1))&(~(bus_size_dw-1))));
                       //t_smi_cmstatus = 0;
                       if (exmon_size > 0) t_smi_cmstatus = smi_cmstatus;
                       else t_smi_cmstatus = 0;
                       for (int i=start_addr; i<(start_addr+min(bus_size_dw,access_size_dw)); i++) begin
                          inx = i & (access_size_dw-1);
                          if (t_smi_cmstatus == 0) t_smi_cmstatus = (merged_rresp_per_dw[inx] < 1) ? 8'h00 : ((merged_rresp_per_dw[inx] < 2) ? 8'h01 : ((merged_rresp_per_dw[inx] == 2) ? 8'h83 : 8'h84));
                          else if ((t_smi_cmstatus < 2) && (merged_rresp_per_dw[inx] == 2)) t_smi_cmstatus = 8'h83;
                          else if (merged_rresp_per_dw[inx] == 3)                           t_smi_cmstatus = 8'h84;
                          `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS 8: intf_dw:%0d bus_dw:%0d io=%0d bo=%0d start_addr=%0d rresp=%p inx=%0d rresp[]=%d cmstatus=%p",
                                                               intfsize_dw, bus_size_dw, intf_offset_dw, bus_offset_dw, start_addr, merged_rresp_per_dw, inx, merged_rresp_per_dw[inx], t_smi_cmstatus), UVM_HIGH);
                       end
                    end // else: !if((intf_offset_dw & (~(access_size_dw-1))) > 0)
                 end // else: !if(offset == 0)
              end // else: !if(intfsize_dw <= bus_size_dw)
           end // else: !if(this.smi_recd[eConcMsgCmdReq].smi_st == 1)
        end // else: !if( (axi_read_addr_pkt.arburst != AXIWRAP) || ((this.smi_recd[eConcMsgCmdReq].smi_st == 1) &&...

        if (0) begin
           // code deprecated
           if (smi_cmstatus != template.smi_cmstatus) begin
              `uvm_info($sformatf("%m"), $sformatf("CMSTATUS: intf_dw:%0d bus_dw:%0d intf_off:%0d bus_off:%0d smi_offset=%0d BT:%p size:%0d ST:%0d RRESP:%p",
                                                   intfsize_dw, bus_size_dw, intf_offset_dw, bus_offset_dw, smi_addr_dw&((CACHELINESIZE/8)-1), this.axi_read_addr_pkt.arburst,
                                                   access_size_dw, smi_recd[eConcMsgCmdReq].smi_st, tmp_axi__r.rresp_per_beat), UVM_NONE)
              `uvm_warning($sformatf("%m"), $sformatf("CMSTATUS mismatch: exp %0h act %0h access_size=%0d addr[3]=%0d",
                                                      smi_cmstatus, template.smi_cmstatus, access_size_dw, (this.axi_read_addr_pkt.araddr>>3)&1))
              //           smi_cmstatus = template.smi_cmstatus;
           end // if (smi_cmstatus != template.smi_cmstatus)
        end
        if (t_smi_cmstatus != template.smi_cmstatus) begin
           if ( $test$plusargs("CONC-9000-WORKAROUND") || $test$plusargs("error_test") ) begin
              bit error_detected = 0;
              foreach (dp_dbad[i]) begin
                 if ( dp_dbad[i] != 0) begin
                    error_detected = 1;
                    break;
                 end
              end
              //#Check.DII.DTWrsp.CMStatusDataerr
              if ( error_detected && ((t_smi_cmstatus == 8'h84) || (t_smi_cmstatus == 8'h83) ||
                                      (template.smi_cmstatus == 8'h84) || (template.smi_cmstatus == 8'h83)) ) begin
                 t_smi_cmstatus = template.smi_cmstatus;
              end else begin
                 `uvm_error($sformatf("%m"), $sformatf("DTR_REQ CMSTATUS mismatch: t exp %0h act %0h access_size=%0d addr[3]=%0d DBAD asserted=%0d",
                                                       t_smi_cmstatus, template.smi_cmstatus, access_size_dw, (this.axi_read_addr_pkt.araddr>>3)&1, error_detected))
              end
           end else begin
              bit                      rsp_unq_id_v = 0  ;
              smi_unq_identifier_bit_t rsp_unq_id_0 = 'h0;
              smi_unq_identifier_bit_t rsp_unq_id_1 = 'h0;
              smi_unq_identifier_bit_t rsp_unq_id_2 = 'h0;
              smi_unq_identifier_bit_t rsp_unq_id_3 = 'h0;
              smi_unq_identifier_bit_t rsp_unq_id_4 = 'h0;
              smi_unq_identifier_bit_t rsp_unq_id_5 = 'h0;
              smi_unq_identifier_bit_t rsp_unq_id_6 = 'h0;
              smi_unq_identifier_bit_t rsp_unq_id_7 = 'h0;
              smi_unq_identifier_bit_t rsp_unq_id_8 = 'h0;
              smi_unq_identifier_bit_t rsp_unq_id_9 = 'h0;
              `uvm_info($sformatf("%m"), $sformatf("T_CMSTATUS: exp:%0h act:%0h; intf_dw:%0d bus_dw:%0d intf_off:%0d bus_off:%0d smi_offset=%0d BT:%p size:%0d ST:%0d RRESP:%p",
                                                   t_smi_cmstatus, template.smi_cmstatus, intfsize_dw, bus_size_dw, intf_offset_dw, bus_offset_dw, smi_addr_dw&((CACHELINESIZE/8)-1),
                                                   this.axi_read_addr_pkt.arburst, access_size_dw, smi_recd[eConcMsgCmdReq].smi_st, tmp_axi__r.rresp_per_beat), UVM_NONE)
              rsp_unq_id_v  = $value$plusargs("rsp_unq_id_0=0x%h", rsp_unq_id_0);
              rsp_unq_id_v |= $value$plusargs("rsp_unq_id_1=0x%h", rsp_unq_id_1);
              rsp_unq_id_v |= $value$plusargs("rsp_unq_id_2=0x%h", rsp_unq_id_2);
              rsp_unq_id_v |= $value$plusargs("rsp_unq_id_3=0x%h", rsp_unq_id_3);
              rsp_unq_id_v |= $value$plusargs("rsp_unq_id_4=0x%h", rsp_unq_id_4);
              rsp_unq_id_v |= $value$plusargs("rsp_unq_id_5=0x%h", rsp_unq_id_5);
              rsp_unq_id_v |= $value$plusargs("rsp_unq_id_6=0x%h", rsp_unq_id_6);
              rsp_unq_id_v |= $value$plusargs("rsp_unq_id_7=0x%h", rsp_unq_id_7);
              rsp_unq_id_v |= $value$plusargs("rsp_unq_id_8=0x%h", rsp_unq_id_8);
              rsp_unq_id_v |= $value$plusargs("rsp_unq_id_9=0x%h", rsp_unq_id_9);
              if ((rsp_unq_id_v) && ((this.smi_recd[eConcMsgCmdReq].smi_unq_identifier == rsp_unq_id_0) ||
                                     (this.smi_recd[eConcMsgCmdReq].smi_unq_identifier == rsp_unq_id_1) ||
                                     (this.smi_recd[eConcMsgCmdReq].smi_unq_identifier == rsp_unq_id_2) ||
                                     (this.smi_recd[eConcMsgCmdReq].smi_unq_identifier == rsp_unq_id_3) ||
                                     (this.smi_recd[eConcMsgCmdReq].smi_unq_identifier == rsp_unq_id_4) ||
                                     (this.smi_recd[eConcMsgCmdReq].smi_unq_identifier == rsp_unq_id_5) ||
                                     (this.smi_recd[eConcMsgCmdReq].smi_unq_identifier == rsp_unq_id_6) ||
                                     (this.smi_recd[eConcMsgCmdReq].smi_unq_identifier == rsp_unq_id_7) ||
                                     (this.smi_recd[eConcMsgCmdReq].smi_unq_identifier == rsp_unq_id_8) ||
                                     (this.smi_recd[eConcMsgCmdReq].smi_unq_identifier == rsp_unq_id_9)
                                     )) begin
                 `uvm_warning($sformatf("%m"), $sformatf("T_CMSTATUS mismatch: t exp %0h act %0h access_size=%0d addr[3]=%0d",
                                                         t_smi_cmstatus, template.smi_cmstatus, access_size_dw, (this.axi_read_addr_pkt.araddr>>3)&1))
                 t_smi_cmstatus = template.smi_cmstatus;
              end else begin
                 // when there is padding, the cmstatus may be based on the first beat of AXI status before rotation.
                 if ((intfsize_dw > bus_size_dw) && (intf_offset_dw > 0) && (access_size_dw < intfsize_dw)) begin
                    `uvm_warning($sformatf("%m"), $sformatf("Adjust CMSATUS: T_CMSATUS:%0h change to %0h", t_smi_cmstatus, template.smi_cmstatus))
                    t_smi_cmstatus = template.smi_cmstatus;
                 end else begin
                    `uvm_error($sformatf("%m"), $sformatf("T_CMSTATUS mismatch: t exp %0h act %0h access_size=%0d addr[3]=%0d",
                                                       t_smi_cmstatus, template.smi_cmstatus, access_size_dw, (this.axi_read_addr_pkt.araddr>>3)&1))
                 end
              end // else: !if((rsp_unq_id_v) && ((this.smi_recd[eConcMsgCmdReq].smi_unq_identifier == rsp_unq_id_0) ||...
           end // else: !if( $test$plusargs("CONC-9000-WORKAROUND") )
        end // if (t_smi_cmstatus != template.smi_cmstatus)
         /*
        if ($test$plusargs("CONC-8860-WORKAROUND")) begin
           int access_top;
           int idx;
           int access_start;
           
           if ((smi_recd[eConcMsgCmdReq].smi_tof == SMI_TOF_CHI) && (smi_recd[eConcMsgCmdReq].smi_st == 1) && (intf_offset_dw > 0) &&
               ((dp_dwid[0] != template.smi_dp_dwid[0]) || (dp_dbad[0] != template.smi_dp_dbad[0]))) begin
              `uvm_warning("CONC-8860", $sformatf("DTR DPDWID or DPDBAD not match: exp %p %p; act %p %p",
                            dp_dwid[0], dp_dbad[0], template.smi_dp_dwid[0], template.smi_dp_dbad[0]))
              for (int i=0; i<intf_offset_dw; i++) begin
                 dp_dwid[0][i*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] = template.smi_dp_dwid[0][i*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW];
                 dp_dbad[0][i*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] = template.smi_dp_dbad[0][i*WSMIDPDBADPERDW +: WSMIDPDBADPERDW];
              end
              `uvm_info($sformatf("%m"), $sformatf("CONC-8860: prefill dp_dwid/dp_dbad[0] 0-%0d", intf_offset_dw-1), UVM_HIGH)
           end
           access_start = (smi_addr_dw & ((CACHELINESIZE/8)-1) & (~(intfsize_dw-1)));
           if ((access_start + access_size_dw) >= (CACHELINESIZE/8)) begin
              access_top = (CACHELINESIZE/8) - access_start;
           end else begin
              access_top = intf_offset_dw + access_size_dw;
           end
           `uvm_info($sformatf("%m"), $sformatf("CONC-8860: postfill top_index=%0d, size_dw=%0d to top_index=%0d",
                                                access_top/bus_size_dw, access_size_dw, template.smi_dp_dwid.size()), UVM_HIGH)
           for (int i=access_top; i<template.smi_dp_dwid.size()*bus_size_dw; i++) begin
              idx    = i/bus_size_dw;
              if ((dp_dwid[idx] != template.smi_dp_dwid[idx]) || (dp_dbad[idx] != template.smi_dp_dbad[idx])) begin
                 if ((i%bus_size_dw) == (bus_size_dw-1)) begin
                    `uvm_warning("CONC-8860", $sformatf("DTR DPDWID or DPDBAD not match at entry %0d: exp %p %p; act %p %p",
                                                        idx, dp_dwid[idx], dp_dbad[idx], template.smi_dp_dwid[idx], template.smi_dp_dbad[idx]))
                 end
                 dp_dwid[idx][(i%bus_size_dw)*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] = template.smi_dp_dwid[idx][(i%bus_size_dw)*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW];
                 dp_dbad[idx][(i%bus_size_dw)*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] = template.smi_dp_dbad[idx][(i%bus_size_dw)*WSMIDPDBADPERDW +: WSMIDPDBADPERDW];
              end
              `uvm_info($sformatf("%m"), $sformatf("CONC-8860: postfill dp_dwid/dp_dbad from %0d to %0d", access_top, template.smi_dp_dwid.size()-1), UVM_HIGH)
           end
        end // if ($test$plusargs("CONC-8860-WORKAROUND"))
         */ 
        gen_exp_smi__dtr_req = smi_seq_item::type_id::create("gen_exp_smi__dtr_req");
        gen_exp_smi__dtr_req.not_RTL = 1;
        gen_exp_smi__dtr_req.construct_dtrmsg(
                                        .smi_targ_ncore_unit_id (smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id),
                                        .smi_msg_type           (DTR_DATA_INV),       //#Check.DII.DTRreq.Msg_type
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_tier           (smi_recd[eConcMsgCmdReq].smi_msg_tier),
					.smi_steer              (template.smi_steer),
                                        .smi_msg_pri            (smi_recd[eConcMsgCmdReq].smi_msg_pri),
                                        .smi_msg_qos            ('b0),

                                        .smi_rmsg_id            (smi_recd[eConcMsgCmdReq].smi_msg_id), //#Check.DII.DtrReq.ReadInflight
                                        .smi_msg_err            (template.smi_msg_err),
//                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_cmstatus           (t_smi_cmstatus),
                                        .smi_rl                 (SMI_RL_TRANSPORT),                                // #Check.DII.DTRreq.Response_level
                                        .smi_tm                 (smi_recd[eConcMsgCmdReq].smi_tm),                 // #Check.DII.DTRreq.Trace_me
                                        .smi_mpf1_dtr_long_dtw  (template.smi_mpf1_dtr_long_dtw),                  // Ncore 3.0: not used -- csymlayers: Used to identify starting DW for multi-DTW response for Long-NCReads (future).
					.smi_ndp_aux            (template.smi_ndp_aux),

                                        .smi_dp_last            (1'b1),                                            // interface has already collected all the data beats
                                        .smi_dp_data            (template.smi_dp_data),
                                        .smi_dp_be              (template.smi_dp_be),
                                        .smi_dp_protection      (template.smi_dp_protection),                      // TODO construct error protection : ecc,parity,errinject
                                        .smi_dp_dwid            (dp_dwid),                                         // #Check.DII.DTRreq.Double_word_id
                                        .smi_dp_dbad            (dp_dbad),                                         // #Check.DII.DTRreq.dp_dbad
                                        .smi_dp_concuser        (dp_concuser)                                      // #Check.DII.DTRreq.Dp_user
                                        );

        `uvm_info($sformatf("%m"), $sformatf("DEBUG: smi_addr=%p cmd_msg_id=%0h dtr_msg_id=%0h dtr_rmsg_id=%0h smi_data=%p axi_ar=(bt=%0d,as=%0d,al=%0d,id=%0d,addr=%p), axi_r=(id=%0d,data=%p)",
					     smi_recd[eConcMsgCmdReq].smi_addr, smi_recd[eConcMsgCmdReq].smi_msg_id, template.smi_msg_id, template.smi_rmsg_id, template.smi_dp_data,
					     this.axi_read_addr_pkt.arburst,this.axi_read_addr_pkt.arsize,this.axi_read_addr_pkt.arlen,this.axi_read_addr_pkt.arid,this.axi_read_addr_pkt.araddr,
					     tmp_axi__r.rid,tmp_axi__r.rdata), UVM_DEBUG)
        `uvm_info($sformatf("%m"), $sformatf("DEBUG: smi_expd=%p smi_recd=%p axi_expd=%p axi_recd=%p", smi_expd, smi_recd, axi_expd, axi_recd), UVM_DEBUG)
       
        // #Check.DII.DTRreq.Data
        //generate an expected axi from this dtr and compare to the real axi
        tmp_axi__r.rdata = xdata(this.smi_recd[eConcMsgCmdReq], template, this.axi_read_data_pkt.rdata) ;
        // need to copy over bytes which are not accessed in single beat from AXI
        if ( (2**smi_recd[eConcMsgCmdReq].smi_size) < (WXDATA/8) ) begin
	   int offset = smi_recd[eConcMsgCmdReq].smi_addr % (WXDATA/8);
	   int size   = 2**smi_recd[eConcMsgCmdReq].smi_size;
	   `uvm_info($sformatf("%m"), $sformatf("AXI R: addr offset=%0h, size=%0d", offset, size), UVM_DEBUG)
	   for (int i=0; i<(smi_recd[eConcMsgCmdReq].smi_addr%(WXDATA/8)); i++) begin
	      tmp_axi__r.rdata[i] = this.axi_read_data_pkt.rdata[i];
	      `uvm_info($sformatf("%m"), $sformatf("AXI4 R Data[%0d]: exp updated to actual: %p", i, this.axi_read_data_pkt.rdata[i]), UVM_DEBUG)
	   end
	   for (int i=((smi_recd[eConcMsgCmdReq].smi_addr%(WXDATA/8))+(2**smi_recd[eConcMsgCmdReq].smi_size)); i<(WXDATA/8); i++) begin
	      tmp_axi__r.rdata[i] = this.axi_read_data_pkt.rdata[i];
	      `uvm_info($sformatf("%m"), $sformatf("AXI4 R Data[%0d]: exp updated to actual: %p", i, this.axi_read_data_pkt.rdata[i]), UVM_DEBUG)
	   end
	end	      
        ok = tmp_axi__r.do_compare_pkts(this.axi_read_data_pkt);
        if(!ok) `uvm_error($sformatf("%m (%s)", parent), $sformatf("dtr does not match axi: see ERROR above queue print"))


    endfunction : gen_exp_smi__dtr_req

    function smi_seq_item gen_exp_smi__dtr_rsp(smi_seq_item template = null);
        int wrong_dut_id;

        if (template == null) begin
            template = new();
        end
        
        if (! $value$plusargs("wt_wrong_dut_id_dtrrsp=%d", wrong_dut_id) ) begin
           wrong_dut_id = 0;
        end

        if(!smi_recd[eConcMsgCmdReq]) begin
            `uvm_error($sformatf("%m (%s)", parent), "precedes cmd_req");
        end else begin
            gen_exp_smi__dtr_rsp = smi_seq_item::type_id::create("gen_exp_smi__dtr_rsp");
            gen_exp_smi__dtr_rsp.not_RTL = 1;
            gen_exp_smi__dtr_rsp.construct_dtrrsp(
                                            .smi_targ_ncore_unit_id (wrong_dut_id?template.smi_targ_ncore_unit_id:smi_recd[eConcMsgDtrReq].smi_src_ncore_unit_id), //#Check.DII.DTrRsp.FunitId
                                            .smi_src_ncore_unit_id  (smi_recd[eConcMsgDtrReq].smi_targ_ncore_unit_id),
                                            .smi_msg_type           (DTR_RSP),
                                            .smi_msg_id             (template.smi_msg_id),
                                            .smi_msg_tier           (smi_recd[eConcMsgDtrReq].smi_msg_tier),
		                            .smi_steer              (template.smi_steer),
                                            .smi_msg_pri            (template.smi_msg_pri),
                                            .smi_msg_qos            (template.smi_msg_qos),

                                            .smi_tm                 (smi_recd[eConcMsgDtrReq].smi_tm),
                                            .smi_rmsg_id            (smi_recd[eConcMsgDtrReq].smi_msg_id), //#Check.DII.DtrRsp.RMessageId
                                            .smi_msg_err            (template.smi_msg_err),
                                            .smi_cmstatus           (template.smi_cmstatus)
                                            );
        end
    endfunction : gen_exp_smi__dtr_rsp


    function smi_seq_item gen_exp_smi__dtw_req(smi_seq_item template = null);
        int wrong_dut_id;

        if (template == null) begin
            template = new();
         end
        
        if (! $value$plusargs("wt_wrong_dut_id_dtw=%d", wrong_dut_id) ) begin
           wrong_dut_id = 0;
        end

        if(!smi_recd[eConcMsgCmdReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes cmd_req");
        if(!smi_recd[eConcMsgStrReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes str_req ");

        gen_exp_smi__dtw_req = smi_seq_item::type_id::create("gen_exp_smi__dtw_req");
        gen_exp_smi__dtw_req.not_RTL = 1;

        gen_exp_smi__dtw_req.construct_dtwmsg(
                                        .smi_targ_ncore_unit_id (wrong_dut_id?template.smi_targ_ncore_unit_id:smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id), //#Check.DII.DtwReq.DiiFunitId
                                        .smi_src_ncore_unit_id  (smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id),
                                        .smi_msg_type           (template.smi_msg_type),                          //TODO FIXME derive and bounds check which dtw type
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_tier           (smi_recd[eConcMsgCmdReq].smi_msg_tier),
					.smi_steer              (template.smi_steer),
                                        .smi_msg_pri            (smi_recd[eConcMsgCmdReq].smi_msg_pri),
                                        .smi_msg_qos            (smi_recd[eConcMsgCmdReq].smi_msg_qos),

                                        .smi_tm                 (template.smi_tm),                 // #Check.DII.DTWreq.Trace_me
                                        .smi_rbid               (smi_recd[eConcMsgStrReq].smi_rbid),               // #Check.DII.DTWreq.Return_buffer_id
                                        .smi_msg_err            (template.smi_msg_err),
                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_rl                 (template.smi_rl),                                 // #Check.DII.DTWreq.Response_level
                                        .smi_prim               (1'b1),                                               // #Check.DII.DTWreq.Primary_data
                                        .smi_mpf1               (template.smi_mpf1),                              //dne in nc
                                        .smi_mpf2               (template.smi_mpf2),                              //dne in nc
                                        .smi_intfsize           (template.smi_intfsize),
                                        .smi_ndp_aux            (template.smi_ndp_aux),
					      
                                        .smi_dp_last            (1'b1),                            //interface has already collected all the data beats
                                        .smi_dp_data            (template.smi_dp_data),
                                        .smi_dp_be              (template.smi_dp_be),                              // TODO bounds check be : cmd size,len
                                        .smi_dp_protection      (template.smi_dp_protection),                      // TODO construct error protection : ecc,parity,errinject
                                        .smi_dp_dwid            (template.smi_dp_dwid),                            // TODO construct dwid
                                        .smi_dp_dbad            (template.smi_dp_dbad),
                                        .smi_dp_concuser        (template.smi_dp_concuser)
                                        );

        //#Check.DII.DTWreq.Response_level
        if ( !( gen_exp_smi__dtw_req.smi_rl inside {SMI_RL_TRANSPORT, SMI_RL_COHERENCY} ) )
            `uvm_error($sformatf("%m (%s)", parent), "rl invalid");

    endfunction : gen_exp_smi__dtw_req

    function smi_seq_item gen_exp_smi__dtw_dbg_req(smi_seq_item template = null);
        int wrong_dut_id;

        if (! $value$plusargs("wt_wrong_dut_id_dtw=%d", wrong_dut_id) ) begin
           wrong_dut_id = 0;
        end

        gen_exp_smi__dtw_dbg_req = smi_seq_item::type_id::create("gen_exp_smi__dtw_dbg_req");
        gen_exp_smi__dtw_dbg_req.not_RTL = 1;
        // DTW does not care about intfsize.
        gen_exp_smi__dtw_dbg_req.construct_dtwdbgmsg(
                                        .smi_targ_ncore_unit_id (wrong_dut_id?template.smi_targ_ncore_unit_id:<%=obj.DveInfo[0].FUnitId%>),
                                        .smi_src_ncore_unit_id  (<%=obj.DiiInfo[obj.Id].FUnitId%>),
                                        .smi_msg_type           (8'ha0),
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_tier           (template.smi_msg_tier),
					.smi_steer              (template.smi_steer),
                                        .smi_msg_pri            (template.smi_msg_pri),
                                        .smi_msg_qos            (template.smi_msg_qos),

                                        .smi_tm                 (template.smi_tm),
                                        .smi_msg_err            (template.smi_msg_err),
                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_rl                 (2'b01),                                 // #Check.DII.DTWreq.Response_level
                                        .smi_ndp_aux            (template.smi_ndp_aux),
					      
                                        .smi_dp_last            (1'b1),                            //interface has already collected all the data beats
                                        .smi_dp_data            (template.smi_dp_data),
                                        .smi_dp_be              (template.smi_dp_be),                              // TODO bounds check be : cmd size,len
                                        .smi_dp_protection      (template.smi_dp_protection),                      // TODO construct error protection : ecc,parity,errinject
                                        .smi_dp_dwid            (template.smi_dp_dwid),                            // TODO construct dwid
                                        .smi_dp_dbad            (template.smi_dp_dbad),
                                        .smi_dp_concuser        (template.smi_dp_concuser)
                                        );
    endfunction : gen_exp_smi__dtw_dbg_req

    function smi_seq_item gen_exp_smi__dtw_rsp(smi_seq_item template = null);
        smi_cmstatus_t    smi_cmstatus;
        smi_cmstatus_t    bresp_status;

        if (template == null) begin
	   `uvm_error($sformatf("%m (%s)", parent), $sformatf("does expect null template"))
        end
        
        if(!smi_recd[eConcMsgDtwReq])
            `uvm_error($sformatf("%m (%s)", parent), "dtw_rsp precedes dtw_req");

        if(smi_recd[eConcMsgCmdReq].smi_vz == 1 && smi_recd[eConcMsgCmdReq].smi_es == 0) begin
             if((int'(axi_recd[axi_w]) == 0) || (int'(axi_recd[axi_b]) == 0)) begin
             `uvm_info($sformatf("%m"), $sformatf("Debug before error : CmdReq = %p  && DtwReq = %p  && DtwRsp = %p ", smi_recd[eConcMsgCmdReq],smi_recd[eConcMsgDtwReq], template), UVM_LOW) 
                 `uvm_error($sformatf("%m (%s)", parent), "CMD req with VZ = 1 and non-exclusive : DtwRsp should not precedes axi_w or axi_b ");
         end
         end
         //#Check.DII.ExMon.ExPassLate
         if(m_exmon_status == EX_PASS && smi_recd[eConcMsgCmdReq].smi_es == 1) begin
            if((int'(axi_recd[axi_w]) == 0) || (int'(axi_recd[axi_b]) == 0)) begin
            `uvm_info($sformatf("%m"), $sformatf("Debug before error : CmdReq = %p  && DtwReq = %p  && DtwRsp = %p ", smi_recd[eConcMsgCmdReq],smi_recd[eConcMsgDtwReq], template), UVM_LOW) 
                `uvm_error($sformatf("%m (%s)", parent), "exmon status = EX_PASS for exclusive CMD: DtwRsp should not precedes axi_w or axi_b ");
        end
        end

         if(smi_recd[eConcMsgCmdReq].smi_es == 1 && exmon_size > 0) begin
            //#Check.DII.ExMon.ExFailEarly
            if (m_exmon_status == EX_FAIL) begin

               smi_cmstatus = 8'b0000_0000;
            end
            //#Check.DII.ExMon.ExPassLate
            else if (m_exmon_status == EX_PASS) begin
               //EX Satus = Pass // Native = SLVERR or Native = DECERR
               if ((axi_write_resp_pkt.bresp == SLVERR) || (axi_write_resp_pkt.bresp == DECERR)) begin
                  smi_cmstatus = 8'b10000000 | ((axi_write_resp_pkt.bresp == SLVERR)?3'b011:3'b100); 

               end
               //EX Satus = Pass // Native = OKAY
               else begin
               
                  smi_cmstatus = 8'b0000_0001;
               end
            end
            else  begin
               `uvm_info($sformatf("%m"), $sformatf("Debug before error : CmdReq = %p  && DtwReq = %p  && DtwRsp = %p ", smi_recd[eConcMsgCmdReq],smi_recd[eConcMsgDtwReq], template), UVM_LOW) 
                `uvm_error($sformatf("%m"), $sformatf("Exlusive Monitor status Unknowen Exmon_status = %s",m_exmon_status.name()))
            end

         end

         // for EWA no response status is taken. Assuming all good.
        //#CheckTime.DII.DTWrsp.Cmstatus
        //#Check.DII.v3.protocol
         
         else if (smi_recd[eConcMsgCmdReq].smi_es == 0 || exmon_size == 0) begin
          if (int'(axi_recd[axi_b])) begin
           //$display("The and axi_write_resp_pkt.bresp before is %b", axi_write_resp_pkt.bresp);       
            
            if ((axi_write_resp_pkt.bresp == SLVERR) || (axi_write_resp_pkt.bresp == DECERR)) begin
               bresp_status = 8'b10000000 | ((axi_write_resp_pkt.bresp == SLVERR)?3'b011:3'b100);
            end else begin
               bresp_status = ((axi_write_resp_pkt.bresp==EXOKAY)?8'b0000_0001:8'b0000_0000);
            end
            if (smi_recd[eConcMsgCmdReq].smi_vz == 0 && smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_NONE) begin
               // EWA cmstatus has no error
               bresp_status = 8'b0000_0000;
            end
            smi_cmstatus = bresp_status;
            
            if (template.smi_cmstatus != bresp_status) begin
               if ($test$plusargs("CONC-9108-WORKAROUND") && (smi_recd[eConcMsgCmdReq].smi_vz==0) && template.smi_cmstatus[7]) begin
                  smi_cmstatus = template.smi_cmstatus;
               end else begin
                  smi_cmstatus = bresp_status;
               end
            end
            
            `uvm_info($sformatf("%m"), $sformatf(" axi_b:%p cmstatus:%p (tb status:%p", axi_write_resp_pkt.bresp, smi_cmstatus, bresp_status), UVM_DEBUG)
            end else begin
               smi_cmstatus = 8'b00000000;
               `uvm_info($sformatf("%m"), $sformatf("cmstatus:%p", smi_cmstatus), UVM_DEBUG)
            end
          end
        gen_exp_smi__dtw_rsp = smi_seq_item::type_id::create("gen_exp_smi__dtw_rsp");
        gen_exp_smi__dtw_rsp.not_RTL = 1;
        gen_exp_smi__dtw_rsp.construct_dtwrsp(
                                        .smi_targ_ncore_unit_id (smi_recd[eConcMsgDtwReq].smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (smi_recd[eConcMsgDtwReq].smi_targ_ncore_unit_id),
                                        .smi_msg_type           (DTW_RSP), //#Check.DII.DTwrsp.Message_Type
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_tier           (smi_recd[eConcMsgDtwReq].smi_msg_tier),
					.smi_steer              (template.smi_steer),
                                        .smi_msg_pri            (smi_recd[eConcMsgDtwReq].smi_msg_pri),
                                        .smi_msg_qos            ('b0),

                                        .smi_tm                 (smi_recd[eConcMsgDtwReq].smi_tm),
                                        .smi_rmsg_id            (smi_recd[eConcMsgDtwReq].smi_msg_id), //#Check.DII.DtwRsp.ReadInflight
                                        .smi_msg_err            (template.smi_msg_err),
                                        .smi_cmstatus           (smi_cmstatus),
                                        .smi_rl                 (template.smi_rl)
                                        );

        //#CheckTime.DII.DTWrsp.Sequence
        if( (smi_recd[eConcMsgDtwReq].smi_rl) && (!axi_recd[axi_b]))
            `uvm_error($sformatf("%m (%s)", parent), $sformatf("rsp violates rsp level"))

    endfunction : gen_exp_smi__dtw_rsp

    function smi_seq_item gen_exp_smi__dtw_dbg_rsp(smi_seq_item template);
         gen_exp_smi__dtw_dbg_rsp = smi_seq_item::type_id::create("gen_exp_smi__dtw_dbg_rsp");
         gen_exp_smi__dtw_dbg_rsp.construct_dtw_dbg_rsp(
                                        .smi_targ_ncore_unit_id (<%=obj.DiiInfo[obj.Id].FUnitId%>),    // target: this DII
                                        .smi_src_ncore_unit_id  (<%=obj.DveInfo[0].FUnitId%>),         // source: DVE
                                        .smi_msg_type           (DTW_DBG_RSP),                         // msg type: DTW_DBG_RSP
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_tier           (template.smi_msg_tier),
					.smi_steer              (template.smi_steer),
                                        .smi_msg_pri            (template.smi_msg_pri),
                                        .smi_msg_qos            (template.smi_msg_qos),

                                        .smi_rmsg_id            (smi_recd[eConcMsgDtwDbgReq].smi_msg_id),
                                        .smi_msg_err            (template.smi_msg_err),
                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_rl                 (2'b00)
                                        );


    endfunction : gen_exp_smi__dtw_dbg_rsp
   
   function smi_seq_item gen_exp_smi__sys_req(smi_seq_item template = null);
        int wrong_dut_id;

        if (! $value$plusargs("wt_wrong_dut_id_dtw=%d", wrong_dut_id) ) begin
           wrong_dut_id = 0;
        end

        gen_exp_smi__sys_req = smi_seq_item::type_id::create("gen_exp_smi__sys_req");
        gen_exp_smi__sys_req.not_RTL = 1;
        // DTW does not care about intfsize.
        gen_exp_smi__sys_req.construct_sysmsg(
                                        .smi_targ_ncore_unit_id (<%=obj.DveInfo[0].FUnitId%>),
                                        .smi_src_ncore_unit_id  (<%=obj.DiiInfo[obj.Id].FUnitId%>),
                                        .smi_msg_type           (SYS_REQ),
                                        .smi_msg_id             (0),
                                        .smi_msg_tier           (0),
                                        .smi_steer              (0),
                                        .smi_msg_pri            (0),
                                        .smi_msg_qos            (0),
                                       .smi_rmsg_id            (0),
                                       .smi_msg_err            (0),
                                       .smi_cmstatus           (0),
                                       .smi_sysreq_op          (3),
                                       .smi_ndp_aux            (0)
                );
   endfunction : gen_exp_smi__sys_req

   
   
   
   function smi_seq_item gen_exp_smi__sys_rsp(smi_seq_item template);
         gen_exp_smi__sys_rsp = smi_seq_item::type_id::create("gen_exp_smi__sys_rsp");
         gen_exp_smi__sys_rsp.construct_sysrsp(
                               
                                        .smi_targ_ncore_unit_id (<%=obj.DiiInfo[obj.Id].FUnitId%>),
                                        .smi_src_ncore_unit_id  (<%=obj.DveInfo[0].FUnitId%>),
                                        .smi_msg_type           (SYS_RSP),
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_tier           ('h0),
                                        .smi_steer              (smi_recd[eConcMsgSysReq].smi_steer),
                                        .smi_msg_pri            (smi_recd[eConcMsgSysReq].smi_msg_pri),
                                        .smi_msg_qos            (smi_recd[eConcMsgSysReq].smi_msg_qos),
                                        .smi_tm                 (smi_recd[eConcMsgSysReq].smi_tm),
                                        .smi_rmsg_id            (smi_recd[eConcMsgSysReq].smi_msg_id),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_ndp_aux            (smi_recd[eConcMsgSysReq].smi_ndp_aux)
        );
                                       


    endfunction : gen_exp_smi__sys_rsp
    

    //-------------------------------------------------------------------------------------------------
   //Generation of expected AXID : CONC-13589 - CONC-13533
    //-------------------------------------------------------------------------------------------------
    function axi_arid_t gen_arid (smi_seq_item cmd_req);
      int startBit = 0;
      axi_arid_t arid;


      
      if (addressMapId.size() > 0 ) begin
         foreach(addressMapId[i]) begin
            if (startBit < WARID) begin
               arid[startBit] = cmd_req.smi_addr[addressMapId[i]];
               startBit++;
            end
         end

      end

      for (int i = startBit; i < WARID; i++) begin
         arid[i] = cmd_req.smi_addr[wCacheLineOffset+i-startBit];

      end
      if(force_arid == 1) arid = 0;
      return (arid);
    endfunction : gen_arid   
    
   function axi_awid_t gen_awid (smi_seq_item cmd_req);
      int startBit = 0;
      axi_awid_t awid;

       if (addressMapId.size() > 0 ) begin
         foreach(addressMapId[i]) begin
            if (startBit < WAWID) begin
               awid[startBit] = cmd_req.smi_addr[addressMapId[i]];
               startBit++;
            end
         end

      end
      for (int i = startBit; i < WAWID; i++) begin
         awid[i] = cmd_req.smi_addr[wCacheLineOffset+3+i-startBit];

      end
      if(force_awid == 1) awid = 0;
      return (awid);
   endfunction : gen_awid   

//------------------------------------------------------------------------------------------------
    function smi_addr_t axi4_addr_trans_addr( smi_addr_t smi_addr );
        bit found;
        smi_addr_t adjusted_smi_addr, adjusted_from_addr, adjusted_to_addr, adjusted_smi_to_addr;
        bit transV;
        bit [3:0] mask;
        
        found = 0;
        <% if ( (obj.DiiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys") ) { %>
        for (int i=0; i < <%=obj.DiiInfo[obj.Id].nAddrTransRegisters%>; i++) begin
           transV               = (dii_scoreboard::addrTransV[i] >> 31);            
           mask                 = (dii_scoreboard::addrTransV[i] & 4'hf);
           adjusted_smi_addr    = (smi_addr >> (20 + mask));
           adjusted_from_addr   = (dii_scoreboard::addrTransFrom[i] >> mask);
           adjusted_to_addr     = ((dii_scoreboard::addrTransTo[i] >> mask) << (20+mask));
           adjusted_smi_to_addr = (smi_addr & ((1<<(20+mask))-1));
           if (transV && (adjusted_smi_addr == adjusted_from_addr)) begin
              axi4_addr_trans_addr = (((dii_scoreboard::addrTransTo[i] >> mask) << (20+mask)) | (smi_addr & ((1 << (20+mask))-1)));
              axi4_addr_trans_addr &= ((1 << WAXADDR)-1);
              `uvm_info($sformatf("%m"), $sformatf("AddrTrans: i=%0d V=%0h from=%08h (adjusted=%08h) to=%08h (adjusted=%08h) smi_addr=%p (adjusted=%08h) new smi_addr=%08h",
                                                   i,dii_scoreboard::addrTransV[i],dii_scoreboard::addrTransFrom[i],adjusted_from_addr,
                                                   dii_scoreboard::addrTransTo[i],adjusted_to_addr,smi_addr,adjusted_smi_addr,adjusted_to_addr|adjusted_smi_to_addr), UVM_LOW)
             found = 1;
             break;
           end else begin
             `uvm_info($sformatf("%m"), $sformatf("AddrTrans:Not found yet interation%0d V=%0d smi_addr adj=%p from_addr_adj=%p", i,transV,adjusted_smi_addr,adjusted_from_addr), UVM_LOW)
           end
        end
        <% } %>
        if (found == 0) begin
           axi4_addr_trans_addr = smi_addr;
        <% if ( (obj.DiiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys") ) { %>
           `uvm_info($sformatf("%m"), $sformatf("AddrTrans: No translation is performed"), UVM_LOW)
           `uvm_info("AddrTrans", $sformatf("ATEV:%p, ATEFR:%p, ATET %p; smi_addr:%p", dii_scoreboard::addrTransV, dii_scoreboard::addrTransFrom,
                                            dii_scoreboard::addrTransTo, smi_addr), UVM_HIGH)
        <% } %>
        end
    endfunction : axi4_addr_trans_addr
   
    function axi4_read_addr_pkt_t gen_exp_axi__ar(axi4_read_addr_pkt_t template);
        smi_seq_item cmd_req,cmd_req_copy;
        
        if(!smi_recd[eConcMsgCmdReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes cmd_req");
              `uvm_info($sformatf("%m"), $sformatf("Zied AVANT TRANSFOR GEN ARID : smi_addr=%0h , bit32 smi_addr = %b", smi_recd[eConcMsgCmdReq].smi_addr,smi_recd[eConcMsgCmdReq].smi_addr[32]), UVM_LOW)
        cmd_req_copy= new();
        cmd_req_copy.copy(smi_recd[eConcMsgCmdReq]);
        $cast(cmd_req, smi_recd[eConcMsgCmdReq]);
       
        cmd_req.smi_addr         = axi4_addr_trans_addr(smi_recd[eConcMsgCmdReq].smi_addr);
       
        gen_exp_axi__ar          = new();

//       gen_exp_axi__ar.arid     = (smi_recd[eConcMsgCmdReq].smi_es) ? (smi_recd[eConcMsgCmdReq].smi_mpf2[WSMIMPF2-2:0]) : template.arid ;
        if (smi_recd[eConcMsgCmdReq].smi_es && exmon_size == 0) begin
           // Build the ARID from the src_id and mpf2 fields in specified locations
            gen_exp_axi__ar.arid  = {WARID{1'b0}};
            gen_exp_axi__ar.arid |= smi_recd[eConcMsgCmdReq].smi_src_id >> WSMINCOREPORTID;
            gen_exp_axi__ar.arid |= smi_recd[eConcMsgCmdReq].smi_mpf2[WSMIMPF2-2:0] << (WSMISRCID-1);
        end else begin
          `uvm_info($sformatf("%m"), $sformatf("Zied GEN ARID : axi_addr=%0h smi_addr=%0h , bit32 axi_addr=%b, bit32 smi_addr = %b", cmd_req.smi_addr,smi_recd[eConcMsgCmdReq].smi_addr,cmd_req.smi_addr[32],smi_recd[eConcMsgCmdReq].smi_addr[32]), UVM_LOW)
           gen_exp_axi__ar.arid  = gen_arid(cmd_req_copy) ;
        end
        gen_exp_axi__ar.araddr   = axaddr(cmd_req);                      // #Check.DII.ar.Address
        gen_exp_axi__ar.arlen    = axlen(cmd_req) ;                      // #Check.DII.ar.Length
        gen_exp_axi__ar.arsize   = axsize(cmd_req) ;                     // #Check.DII.ar.Size
        gen_exp_axi__ar.arburst  = axburst(cmd_req) ;                    // #Check.DII.ar.Burst
                    
        if(exmon_size == 0) begin
             $cast(gen_exp_axi__ar.arlock   , cmd_req.smi_es) ;          // #Check.DII.ar.Lock    
        end
        else begin
          $cast(gen_exp_axi__ar.arlock ,0) ; //In case of EXMON arlock should be 0                        
        end
        $cast(gen_exp_axi__ar.arcache  , axcache(cmd_req)) ;             // #Check.DII.ar.Cache
        gen_exp_axi__ar.arprot   = {1'b0, cmd_req.smi_ns, cmd_req.smi_pr} ; // #Check.DII.ar.Protection
        gen_exp_axi__ar.arqos    = cmd_req.smi_qos ;                     // #Check.DII.ar.Qos
        gen_exp_axi__ar.arregion = template.arregion ;                   // TODO .arregion
        gen_exp_axi__ar.aruser   = cmd_req.smi_ndp_aux ;                 // #Check.DII.ar.User
    endfunction : gen_exp_axi__ar

    function axi4_read_data_pkt_t gen_exp_axi__r(axi4_read_data_pkt_t template);
        smi_seq_item   dtr_req;
        smi_seq_item   msg;
        smi_addr_t     smi_addr;
        smi_cmstatus_t cmstatus;
        smi_dp_dbad_t  dp_dbad[];

        int            smi_size_dw;
        int            smi_intfsize_dw;
        int            bus_size_dw;
        int            access_size_dw;
        int            intf_offset_dw;
        int            bus_offset_dw;
        int            wrap_base;
        int            wrap_top;
       

        if(!axi_recd[axi_ar])
            `uvm_error($sformatf("%m (%s)", parent), "precedes axi_ar");

        $cast(dtr_req, smi_recd[eConcMsgDtrReq]);
        // depending on back pressure, may not have received DTR REQ
        // if (smi_recd[eConcMsgDtrReq]) begin
           

        msg              = smi_recd[eConcMsgCmdReq];
        smi_addr         = msg.smi_addr;
        smi_size_dw      = 2**((msg.smi_size >= 3) ? (msg.smi_size-3) : 0);
        smi_intfsize_dw  = 2**msg.smi_intfsize;
        bus_size_dw      = (wSmiDPdata/64);
        
        access_size_dw   = ((2**axi_read_addr_pkt.arsize)*(axi_read_addr_pkt.arlen+1))/8;
        intf_offset_dw   = (smi_addr>>3) & (~(smi_intfsize_dw-1)) & (CACHELINESIZE-1);
        wrap_base        = intf_offset_dw & (access_size_dw-1);
        wrap_top         = wrap_base + access_size_dw;
        bus_offset_dw    = (smi_addr>>3) & (~((WXDATA/64)-1)) & (CACHELINESIZE-1);

        gen_exp_axi__r                = new();
 
        gen_exp_axi__r.rid            = axi_read_addr_pkt.arid ;  // #Check.DII.r.Id
        gen_exp_axi__r.rdata          = template.rdata ;
        gen_exp_axi__r.rresp          = template.rresp ;
        gen_exp_axi__r.rresp_per_beat = template.rresp_per_beat ;
        gen_exp_axi__r.ruser          = template.ruser ;
 
    endfunction : gen_exp_axi__r



    function axi4_write_addr_pkt_t gen_exp_axi__aw(axi4_write_addr_pkt_t template);
        smi_seq_item cmd_req,cmd_req_copy;

        if(!smi_recd[eConcMsgCmdReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes cmd_req");

        if(!smi_recd[eConcMsgDtwReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes dtw_req");
        cmd_req_copy= new();
        cmd_req_copy.copy(smi_recd[eConcMsgCmdReq]);
        $cast(cmd_req, smi_recd[eConcMsgCmdReq]);
        cmd_req.smi_addr         = axi4_addr_trans_addr(smi_recd[eConcMsgCmdReq].smi_addr);

        gen_exp_axi__aw          = new();
//        gen_exp_axi__aw.awid     = (smi_recd[eConcMsgCmdReq].smi_es) ? (smi_recd[eConcMsgCmdReq].smi_mpf2[WSMIMPF2-2:0]) : template.awid ;
        if (smi_recd[eConcMsgCmdReq].smi_es && exmon_size == 0) begin
            // Build the AWID from the src_id and mpf2 fields in specified locations
            gen_exp_axi__aw.awid  = {WAWID{1'b0}};
            gen_exp_axi__aw.awid |= smi_recd[eConcMsgCmdReq].smi_src_id >> WSMINCOREPORTID;
            gen_exp_axi__aw.awid |= smi_recd[eConcMsgCmdReq].smi_mpf2[WSMIMPF2-2:0] << (WSMISRCID-1);
        end else begin
           gen_exp_axi__aw.awid  = gen_awid(cmd_req_copy) ;
        end
        gen_exp_axi__aw.awaddr   = axaddr(cmd_req) ;                        // #Check.DII.aw.Address
        gen_exp_axi__aw.awlen    = axlen(cmd_req) ;                         // #Check.DII.aw.Length
        if ( k_32b_cmdset.get_value() ) begin 

         gen_exp_axi__aw.awsize = ($test$plusargs("32b_asize_err")?2:axsize(cmd_req));
        
        end else begin

        gen_exp_axi__aw.awsize   = axsize(cmd_req) ;                        // #Check.DII.aw.Size
        
        end
        gen_exp_axi__aw.awburst  = axburst(cmd_req) ;                       // #Check.DII.aw.Burst
        if(exmon_size == 0) begin
            $cast(gen_exp_axi__aw.awlock   , cmd_req.smi_es) ;             // #Check.DII.aw.Lock      
        end
        else begin
           $cast(gen_exp_axi__aw.awlock, 0) ; //In case of EXMON awlock should be 0                        
        end
        
        $cast(gen_exp_axi__aw.awcache  , axcache(cmd_req)) ;                // #Check.DII.aw.Cache
        gen_exp_axi__aw.awprot   = {1'b0, cmd_req.smi_ns, cmd_req.smi_pr} ;    // #Check.DII.aw.Protection
        gen_exp_axi__aw.awqos    = cmd_req.smi_qos ;                        // #Check.DII.aw.Qos
        gen_exp_axi__aw.awregion = template.awregion ;                      // TODO .awregion
        gen_exp_axi__aw.awuser   = cmd_req.smi_ndp_aux ;                    // #Check.DII.aw.User
    endfunction : gen_exp_axi__aw


    function axi4_write_data_pkt_t gen_exp_axi__w(axi4_write_data_pkt_t template);
        if(!axi_recd[axi_aw])
            `uvm_error($sformatf("%m (%s)", parent), "precedes axi_aw");

        gen_exp_axi__w = new();

        //NB no wid, see  axi4 spec  "A5.4 Removal of write interleaving support"
        gen_exp_axi__w.wdata = xdata(smi_recd[eConcMsgCmdReq], smi_recd[eConcMsgDtwReq], template.wdata) ; // #Check.DII.w.Data
        gen_exp_axi__w.wstrb = xstrb(smi_recd[eConcMsgCmdReq], smi_recd[eConcMsgDtwReq]) ;                 // #Check.DII.w.Strb
        gen_exp_axi__w.wuser = smi_recd[eConcMsgDtwReq].smi_ndp_aux ;                                      // #Check.DII.w.User
    endfunction : gen_exp_axi__w

    function axi4_write_resp_pkt_t gen_exp_axi__b(axi4_write_resp_pkt_t template);
        if(!axi_recd[axi_w])
            `uvm_error($sformatf("%m (%s)", parent), "precedes axi_w");

        gen_exp_axi__b = new();

        gen_exp_axi__b.bid   = axi_write_addr_pkt.awid ;   // #Check.DII.b.Id
        gen_exp_axi__b.bresp = template.bresp ;
        gen_exp_axi__b.buser = template.buser ;
    endfunction : gen_exp_axi__b



    //------------------------------------------------------------------------------
    // status ops
    //------------------------------------------------------------------------------

    //== the msgid deallocation condition
    function bit isOutstanding(eConcMsgClass msg_class);
        isOutstanding = 0;

        //typical req outstanding iff was sent and has not received rsp
        isOutstanding = (
            (smi_recd[msg_class])
            && (smi_expd[rsp_to[msg_class]])
        );

        if(msg_class == eConcMsgCmdReq) begin
            //cmdreq limited by requirement to propagate any cmstatus error to upstream.
            // outstanding until cmdRSP && last entailed upstream concerto msg
            //ASSUME any downstream error rsp shall not propagate to initiator => need not wait for downstream rsps
            isOutstanding = (
                (smi_recd[msg_class])
                &&(
                    (smi_expd[eConcMsgNcCmdRsp])
                    || (smi_expd[eConcMsgStrReq])
                    || (smi_expd[eConcMsgDtrReq])
                    || (smi_expd[eConcMsgDtwRsp])
                )
            );
        end else if (msg_class == eConcMsgDtwDbgReq) begin // if (msg_class == eConcMsgCmdReq)
            isOutstanding = (
                (smi_recd[msg_class]) &&
                (
                 smi_expd.exists(eConcMsgDtwDbgRsp)
                )
            );
        end else if (msg_class == eConcMsgSysReq) begin // if (msg_class == eConcMsgCmdReq)
            isOutstanding = (
                (smi_recd[msg_class]) &&
                (
                 smi_expd.exists(eConcMsgSysRsp)
                )
            );
        end

    endfunction : isOutstanding


    //txn ordered wrt given old txn?
    //ordering point is ax.
    //precondition: call @receive axi ax
    //mechanism:  this method fails unless explicitly contemplated ordering correct scenario.
    function void check_ordered(dii_txn old, int lrgstEp);
        time new_seen;
        if (! this.smi_recd.exists(eConcMsgCmdReq) ) return;
       
        new_seen = this.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid ; // 

        //check that I am at bottommost ordering point
        if (this.axi_expd[axi_ar] || this.axi_expd[axi_aw] || (this.smi_expd[eConcMsgStrReq] && !(this.smi_recd[eConcMsgCmdReq].isCmdNcRdMsg)))
        // streq for a NCRdreq can be backpressured at the SMI Interface. r_data and r_resp can arrive at the AXI native interface and the DTRReq can go ahead of a STRReq since they are on 2 diff SMI channels
            `uvm_error($sformatf("%m (%s)", parent), $sformatf("txn has not reached ordering point"))

        //no ordering requirement for this txn vs
        // newer txn
        // txn beginning in same cycle (note. cannot occur in dii 3.0)  also prevents collision with self
        if (new_seen < old.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid) begin : oldest_one
            return;
        end else if (this.smi_recd[eConcMsgCmdReq].isCmdCacheOpsMsg() || old.smi_recd[eConcMsgCmdReq].isCmdCacheOpsMsg()) begin : no_check_cmo
          // no ordering check for CMO
            return;
        //for older txn, ordering must persist across axi link.
        end else if (old.smi_recd[eConcMsgCmdReq].smi_ns == this.smi_recd[eConcMsgCmdReq].smi_ns) begin : older_txn // skip if NS bits do not match
            // for ordering: all requests with ENDPOINT ordering can not bypass others with ENDPOINT ordering.
            // Other request following AXI ordering rules
            bit cond0 , cond1, cond2;
            if (this.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT && old.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT && addrMgrConst::endpoint_addr(this.smi_recd[eConcMsgCmdReq].smi_addr, this.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id) == addrMgrConst::endpoint_addr(old.smi_recd[eConcMsgCmdReq].smi_addr, old.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id)) begin
               cond0 = 1;
            end

            if ( this.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_REQUEST_WR_OBS && this.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_WRITE 
                  && addrMgrConst::cache_addr(this.smi_recd[eConcMsgCmdReq].smi_addr) == addrMgrConst::cache_addr(old.smi_recd[eConcMsgCmdReq].smi_addr)) begin
               cond1 = 1;
            end

            if ( int'(old.axi_expd[axi_ar]) == 1 || int'(old.axi_expd[axi_aw]) == 1 || int'(old.smi_expd[eConcMsgStrReq]) == 1) begin
               cond2 = 1;
            end

            if  ((cond0 || cond1) && cond2)  begin
              order_error($sformatf("%m"), "older txn has not passed ordering point", old);
            end

            if( old.smi_recd[eConcMsgStrReq] ) begin : recd_strreq // begin ordering check only if the strreq (ordering point of ncore) has been received

            if (this.smi_recd[eConcMsgCmdReq].isCmdNcRdMsg()) begin : this_rd
                if (old.smi_recd[eConcMsgCmdReq].isCmdNcRdMsg() && old.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_NONE && this.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_NONE) begin : rd_vs_rd

                    if ( old.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT && this.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT &&
                         (addrMgrConst::endpoint_addr(old.smi_recd[eConcMsgCmdReq].smi_addr,old.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id) != addrMgrConst::endpoint_addr(this.smi_recd[eConcMsgCmdReq].smi_addr,this.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id))
                        || (!addrMgrConst::memorder_policy_is3(old.smi_recd[eConcMsgCmdReq].smi_addr) && !addrMgrConst::memorder_policy_is3(this.smi_recd[eConcMsgCmdReq].smi_addr)) ) return; //return if both txns are EO and their addresses dont fall under EO range
         
                    if (old.axi_recd[axi_r] <= new_seen) return;
                    if (old.axi_read_data_pkt.t_pkt_seen_on_intf <= this.axi_read_addr_pkt.t_pkt_seen_on_intf) return;   //axi txn on this channel completed before this ax issued
                    if(old.axi_read_addr_pkt.arid == this.axi_read_addr_pkt.arid)  return;  //this ax is part of ongoing ordering set on same channel
                    order_error($sformatf("%m"), "Ordering faliure between the two txns rd_vs_rd", old); 
                end : rd_vs_rd
                else if (old.smi_recd[eConcMsgCmdReq].isCmdNcWrMsg() && 
                         (((old.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_WRITE && this.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_WRITE) &&  
                         (addrMgrConst::cache_addr(old.smi_recd[eConcMsgCmdReq].smi_addr) == addrMgrConst::cache_addr(this.smi_recd[eConcMsgCmdReq].smi_addr))) ||
                         (old.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_WRITE && this.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_WRITE))) begin : rd_vs_wr
                    if ( (old.axi_recd[axi_b] <= new_seen && exmon_size == 0) || (old.axi_recd[axi_b] <= new_seen && exmon_size > 0 && old.m_exmon_status != EX_FAIL)) return;
                    if (old.axi_write_resp_pkt.t_pkt_seen_on_intf <= this.axi_read_addr_pkt.t_pkt_seen_on_intf)  return;     //axi txn on other channel completed before 
                    if ((exmon_size > 0 && old.m_exmon_status == EX_FAIL)) return; //wRITE CMD WITH EX_FAIL don't send axi transaction.

                    order_error($sformatf("%m"), "Ordering faliure between read (new) and write (old) - rd_vs_wr", old);
                end : rd_vs_wr
            end :  this_rd

            else if (this.smi_recd[eConcMsgCmdReq].isCmdNcWrMsg())begin : this_wr
                if (old.smi_recd[eConcMsgCmdReq].isCmdNcWrMsg()) begin : wr_vs_wr
                   `uvm_info($sformatf("%m"), $sformatf("BRESP ordering ignored: old=%0t current=%0t order_old=%0d, order_cur=%0d\nOLD CMD=%p\nCURRENT CMD=%p",
                                                           old.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid, this.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid,
                                                           old.smi_recd[eConcMsgCmdReq].smi_order, this.smi_recd[eConcMsgCmdReq].smi_order,
                                                           old.smi_recd[eConcMsgCmdReq], this.smi_recd[eConcMsgCmdReq]),UVM_DEBUG)
                   if ( old.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT && this.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT &&
                         (addrMgrConst::endpoint_addr(old.smi_recd[eConcMsgCmdReq].smi_addr,old.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id) != addrMgrConst::endpoint_addr(this.smi_recd[eConcMsgCmdReq].smi_addr,this.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id))
                        || (!addrMgrConst::memorder_policy_is3(old.smi_recd[eConcMsgCmdReq].smi_addr) && !addrMgrConst::memorder_policy_is3(this.smi_recd[eConcMsgCmdReq].smi_addr)) ) return; //return if both txns are EO and their addresses dont fall under EO range

                   if (((this.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_ENDPOINT) || (old.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_ENDPOINT)) &&
                       ((addrMgrConst::cache_addr(this.smi_recd[eConcMsgCmdReq].smi_addr) != addrMgrConst::cache_addr(old.smi_recd[eConcMsgCmdReq].smi_addr)) ||
                        (this.smi_recd[eConcMsgCmdReq].smi_ns != old.smi_recd[eConcMsgCmdReq].smi_ns))) begin
                      `uvm_info($sformatf("%m"), $sformatf("ORDER CHECK: Current or older does not have SMI_ORDER_ENDPOINT. They are with different cacheline addr"), UVM_MEDIUM)
                      // Request Ordering satisfied
                      return;
                   end
                   if(old.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_WRITE && this.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_WRITE) begin
                       if ((old.axi_write_addr_pkt.t_pkt_seen_on_intf < this.axi_write_addr_pkt.t_pkt_seen_on_intf) && (old.axi_write_resp_pkt.t_pkt_seen_on_intf <= this.axi_write_addr_pkt.t_pkt_seen_on_intf)) begin
                          return;
                       end
                   end
//                    if (old.axi_recd[axi_b] <= new_seen)
//                        if (old.axi_write_resp_pkt.t_pkt_seen_on_intf <= this.axi_write_addr_pkt.t_pkt_seen_on_intf) return;   //axi txn on this channel completed before this ax issued
                   if(old.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_WRITE && this.smi_recd[eConcMsgCmdReq].smi_order != SMI_ORDER_WRITE) begin
                       if(old.axi_write_addr_pkt.awid == this.axi_write_addr_pkt.awid)    return;    //this ax is part of ongoing ordering set on same channel
                   end
                   // Write Transactions with WO ordering [OR = 01] from the same agent should always complete in order ir-respective of the target or endpoint address[CONC-10000].
                   //#Check.DII.Order_write
                   if((old.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_WRITE) && (this.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_WRITE) && (old.smi_recd[eConcMsgCmdReq].smi_src_id == this.smi_recd[eConcMsgCmdReq].smi_src_id))  begin
                       if (old.axi_write_addr_pkt.t_pkt_seen_on_intf < this.axi_write_addr_pkt.t_pkt_seen_on_intf) begin
                          return;
                       end
                   end
                   
                   order_error($sformatf("%m"), "outstanding ax on same channel with different awid - wr_vs_wr", old);
                end : wr_vs_wr
                else if ((old.smi_recd[eConcMsgCmdReq].isCmdNcRdMsg()) &&
                         ( (old.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT) &&
                           (this.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT) &&
                           (addrMgrConst::endpoint_addr(old.smi_recd[eConcMsgCmdReq].smi_addr, old.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id) == 
                           addrMgrConst::endpoint_addr(this.smi_recd[eConcMsgCmdReq].smi_addr, this.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id)) ) 
                         || ( (this.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_REQUEST_WR_OBS) &&
                               (addrMgrConst::cache_addr(old.smi_recd[eConcMsgCmdReq].smi_addr) == addrMgrConst::cache_addr(this.smi_recd[eConcMsgCmdReq].smi_addr)) )
                         )  begin : wr_vs_rd
                    // Note for PCIe ordering: write with order==NONE can bypass read
                  //if ( old.axi_recd.exists(axi_r)) begin
                     if ( old.axi_recd[axi_r] &&
                         (old.axi_recd[axi_r] <= new_seen) ||
                         (old.axi_read_data_pkt.t_pkt_seen_on_intf <= this.axi_write_addr_pkt.t_pkt_seen_on_intf) ) begin
                       return;   //axi txn on other channel completed before this ax issued
                    end

                   if (old.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_REQUEST_WR_OBS && this.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_REQUEST_WR_OBS) return; //CONC-17794 because RO Write(younger) can bypass RO Read(older)
                   if ((old.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT && old.smi_recd[eConcMsgCmdReq].isCmdNcRdMsg()) && (this.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_REQUEST_WR_OBS && this.smi_recd[eConcMsgCmdReq].isCmdNcWrMsg())) return; //CONC-17877 because RO Write(younger) can bypass EO Read(older)
                 
                    order_error($sformatf("%m"), "Ordering failiure between write (new) and read (old) - wr_vs_rd ", old);
                  //end
                 
                end : wr_vs_rd
                else order_error($sformatf("%m"), "not expect ordering for following transactions", old);
            end : this_wr

            else if (this.smi_recd[eConcMsgCmdReq].isCmdCacheOpsMsg()) begin : this_cmo
//                if (old.isOutstanding(eConcMsgCmdReq)) begin
//                  if (old.smi_recd[eConcMsgCmdReq].isCmdNcWrMsg() && (old.smi_recd[eConcMsgCmdReq].smi_vz == 0)) begin
//                     order_error($sformatf("%m"), "cmo returned prior to completion of older wr", old);
//		  end
            end : this_cmo

          end : recd_strreq
        end : older_txn

        //    order_error($sformatf("%m"), "ordering case not contemplated by checks.  SHOULD NEVER GET HERE.", old);

    endfunction : check_ordered


    function void order_error(string caller, string msg, dii_txn old);
        $stacktrace;
        `uvm_error($sformatf("%s (%s)", caller, parent), $sformatf("%p\nthis txn: cmd msg_type=%2h\tsrc_id=%p\tmpf2=%p\tunqid=%p\tns=%0h\torder=%0d\tvz=%0d\tst=%0d\taddr=%0h\tepaddr=%0h\tepsize=%0h\ttrgid=%0h\n%p\nconflicting txn: cmd msg_type=%02h\tsrc_id=%p\tmpf2=%p\tunqid=%p\tns=%0h\torder=%0d\tvz=%0d\tst=%0d\taddr=%0h\tepaddr=%0h\tepsize=%0h\ttrgid=%0h\n%p", 
             msg, this.smi_recd[eConcMsgCmdReq].smi_msg_type, this.smi_recd[eConcMsgCmdReq].smi_src_id,this.smi_recd[eConcMsgCmdReq].smi_mpf2,
                  this.smi_recd[eConcMsgCmdReq].smi_unq_identifier, this.smi_recd[eConcMsgCmdReq].smi_ns, this.smi_recd[eConcMsgCmdReq].smi_order,
                  this.smi_recd[eConcMsgCmdReq].smi_vz, this.smi_recd[eConcMsgCmdReq].smi_st, this.smi_recd[eConcMsgCmdReq].smi_addr,
                  addrMgrConst::endpoint_addr(this.smi_recd[eConcMsgCmdReq].smi_addr, this.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id), <%=obj.DiiInfo[obj.Id].wLargestEndpoint%>,
                  this.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id, this,
                  old.smi_recd[eConcMsgCmdReq].smi_msg_type, old.smi_recd[eConcMsgCmdReq].smi_src_id, old.smi_recd[eConcMsgCmdReq].smi_mpf2,
                  old.smi_recd[eConcMsgCmdReq].smi_unq_identifier, old.smi_recd[eConcMsgCmdReq].smi_ns, old.smi_recd[eConcMsgCmdReq].smi_order,
                  old.smi_recd[eConcMsgCmdReq].smi_vz, old.smi_recd[eConcMsgCmdReq].smi_st, old.smi_recd[eConcMsgCmdReq].smi_addr,
                  addrMgrConst::endpoint_addr(old.smi_recd[eConcMsgCmdReq].smi_addr, old.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id), <%=obj.DiiInfo[obj.Id].wLargestEndpoint%>,
                  old.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id, old
         ))                                      
    endfunction : order_error

    function smi_dp_dwid_t calcDwid(smi_seq_item msg, int dwid_index);
       int smi_size_dw, smi_intfsize_dw, bus_size_dw;
       int wrap_base, wrap_top;
       bit [WSMIDPDWIDPERDW:0] dwid;  // need one more bit to handle wrap

       smi_size_dw      = 2**max(msg.smi_size-3,0);
       smi_intfsize_dw  = 2**msg.smi_intfsize;
       bus_size_dw      = (wSmiDPdata/64);
      
       if (smi_intfsize_dw > bus_size_dw) begin
          wrap_base = ((msg.smi_addr >> 3) & (~(max(smi_intfsize_dw,smi_size_dw)-1))) & ((CACHELINESIZE/8)-1);
          wrap_top  = (wrap_base + max(smi_intfsize_dw,smi_size_dw));
       end else if (smi_intfsize_dw == bus_size_dw) begin
          wrap_base = ((msg.smi_addr >> 3) & (~(max(bus_size_dw,smi_size_dw)-1))) & ((CACHELINESIZE/8)-1);
          wrap_top  = (wrap_base + max(bus_size_dw,smi_size_dw));
       end else begin
          wrap_base = (msg.smi_addr >> 3) & (~(max(smi_size_dw, smi_intfsize_dw)-1)) & ((CACHELINESIZE/8)-1);
          wrap_top  = (wrap_base + ((smi_size_dw == 1) ? max(bus_size_dw,smi_size_dw) : max(smi_size_dw,smi_intfsize_dw)));
       end
       calcDwid = 'h0;
       if (smi_intfsize_dw < bus_size_dw) begin
	  for (int i=0; i<bus_size_dw; i+=smi_intfsize_dw) begin
	     for (int j=0; j<smi_intfsize_dw; j++) begin
		dwid = ((msg.smi_addr >> 3) & (~(smi_intfsize_dw-1)) & ((CACHELINESIZE/8)-1)) + (dwid_index*bus_size_dw) + i + j;
		`uvm_info($sformatf("%m"), $sformatf("OLD DWID 1: i=%0d j=%0d dwid=%0d", i, j, dwid), UVM_DEBUG)
		if (dwid >= wrap_top) dwid = (dwid - wrap_top + wrap_base) & ((CACHELINESIZE/8)-1);
		calcDwid[(i+j)*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] = WSMIDPDWIDPERDW'(dwid);
		`uvm_info($sformatf("%m"), $sformatf("DWID: index=%0d i=%0d j=%0d dwid=%0d calcDwid=%0h", dwid_index, i, j, dwid, calcDwid), UVM_HIGH)
	     end
	  end
       end else begin
	  for (int i=0; i<bus_size_dw; i++) begin
	     dwid = ((msg.smi_addr >> 3) & (~(smi_intfsize_dw-1)) & ((CACHELINESIZE/8)-1)) + (dwid_index)*bus_size_dw + i;
	     `uvm_info($sformatf("%m"), $sformatf("OLD DWID 2: i=%0d dwid=%0d", i, dwid), UVM_DEBUG)
	     if (dwid >= wrap_top) dwid = (dwid - wrap_top + wrap_base) & ((CACHELINESIZE/8)-1);
	     calcDwid[i*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] = WSMIDPDWIDPERDW'(dwid);
	     `uvm_info($sformatf("%m"), $sformatf("DWID: index=%0d, i=%0d dwid=%0d calcDwid=%0h", dwid_index, i, dwid, calcDwid), UVM_HIGH)
	  end
       end // else: !if(smi_intfsize_dw < bus_size_dw)
      `uvm_info($sformatf("%m"), $sformatf("Addr=%p, index=%0d, dwid=%0d, calcdwid=%p, intfsize=%0d smi_size=%0d bus=%0d wrap_base=%0h wrap_top=%0h",
					   msg.smi_addr, dwid_index, dwid, calcDwid, smi_intfsize_dw, smi_size_dw, bus_size_dw, wrap_base, wrap_top), UVM_HIGH)
    endfunction : calcDwid
     
endclass : dii_txn



////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

//represent a collection of txns
// (for practicality should be kept in order of txn arrival)
class dii_txn_q;

    string parent;
    dii_txn txn_q[$];   //data store

    // for address deallocation
    addr_trans_mgr addr_mgr ;


    //------------------------------------------------------------------------------
    // constructor
    //------------------------------------------------------------------------------
    function new(string parent_in = "");
        parent = parent_in ;
        txn_q = {};

        // get addr mgr for deallocation
        addr_mgr = addr_trans_mgr::get_instance();    //singleton class constructed in base test
    endfunction : new

    //------------------------------------------------------------------------------
    // Print contents of pending txns
    function print();

        `uvm_info($sformatf("%m (%s)", parent), $sformatf("contains %d items\n", txn_q.size()), UVM_MEDIUM)
        `uvm_info($sformatf("%m (%s)", parent), "-----------------------------------------------", UVM_MEDIUM)
        foreach (txn_q[i])
            txn_q[i].print_entry();
        `uvm_info($sformatf("%m (%s)", parent), "-----------------------------------------------", UVM_MEDIUM)
         
    endfunction : print

   
   function bit all_oustanding_is_SysCmd();
      int i = 0;
      bit is_sys_txn = 1;
      while (is_sys_txn == 1 && i < txn_q.size()) begin
         if (!txn_q[i].smi_recd.exists(eConcMsgSysReq)) begin
            is_sys_txn = 0;
         end
         i++;
      end
      return(is_sys_txn);     
    endfunction : all_oustanding_is_SysCmd
    //------------------------------------------------------------------------------
    // queue ops
    //------------------------------------------------------------------------------

    //obtain the txn corresponding to this msg.

    function dii_txn get_txn(smi_seq_item msg, inout int unsigned txn_id);
        dii_txn find_q[$];

        //default to bogus txn
        get_txn = null;


        //cmd starts a new txn
        if(msg.isCmdMsg()) begin
             get_txn = new(msg, parent);
             get_txn.txn_id = txn_id;
             txn_id ++;
             txn_q.push_back(get_txn);
            `uvm_info($sformatf("%m (%s)", parent), $sformatf("new txn for msg: %p\ntxn: %p", msg, get_txn), UVM_HIGH)
             return get_txn ;
        end
        //dtw dbg starts a new txn
        else if (msg.isDtwDbgReqMsg()) begin
             get_txn = new(msg, parent);
             get_txn.txn_id = txn_id;
             txn_id ++;
             txn_q.push_back(get_txn);
             `uvm_info($sformatf("%m (%s)", parent), $sformatf("new txn for msg: %p\ntxn: %p", msg, get_txn), UVM_HIGH)
             return get_txn;
         end
         else if (msg.isSysReqMsg()) begin
             find_q = txn_q.find with (
                (item.smi_recd[eConcMsgSysReq] && item.smi_expd[eConcMsgSysRsp])
             );
             if (find_q.size() > 0 && !$test$plusargs("dii_sys_event_ev_timeout")) begin
                  `uvm_error($sformatf("%m (%s)", parent), $sformatf("Receiving new Sys Req command while there's another oustanding Sys_req"))
             end
             else begin
               get_txn = new(msg, parent);
               get_txn.txn_id = txn_id;
               txn_id ++;
               txn_q.push_back(get_txn);
               `uvm_info($sformatf("%m (%s)", parent), $sformatf("new txn for msg: %p\ntxn: %p", msg, get_txn), UVM_LOW)
               return get_txn;
             end
        end
        //dtw matches str by rbid
        else if(msg.isDtwMsg()) begin
            find_q = txn_q.find with (
                (item.smi_recd[eConcMsgStrReq] && item.smi_expd[eConcMsgDtwReq])
            );
            if (find_q.size() == 0) begin
                for (int i=0; i<txn_q.size(); i++) begin
                   `uvm_info($sformatf("%m"), $sformatf("TXNQ:%d TXN:%p", i, txn_q[i]), UVM_LOW)
                end
                `uvm_error($sformatf("%m"), $sformatf("No TXN match"))
            end
            find_q = find_q.find with (
                (item.smi_recd[eConcMsgStrReq].smi_rbid == msg.smi_rbid)
            );
            `uvm_info($sformatf("%m (%s)", parent), $sformatf("find txn for DTW msg (%0d items): %p\ntxn: %p", msg, find_q[0], find_q.size()), UVM_HIGH)
        end
        //any other msg matches its rmsg class
        else begin
            int targ_id_err_inj;
            if (msg.smi_msg_type == <%=obj.DiiInfo[obj.Id].cmType.DtrRsp%>) begin
               if (! $value$plusargs("wt_wrong_dut_id_dtrrsp=%d",targ_id_err_inj)) targ_id_err_inj = 0;
            end else if (msg.smi_msg_type == <%=obj.DiiInfo[obj.Id].cmType.StrRsp%>) begin
               if (! $value$plusargs("wt_wrong_dut_id_strrsp=%d",targ_id_err_inj)) targ_id_err_inj = 0;
            end else if (msg.smi_msg_type == <%=obj.DiiInfo[obj.Id].cmType.DtwDbgRsp%>) begin
               if (! $value$plusargs("wt_wrong_dut_id_dtwdbgrsp=%d",targ_id_err_inj)) targ_id_err_inj = 0;
            end
            find_q = txn_q.find with (
                (item.isOutstanding(msg.smi_conc_rmsg_class))
            );
            `uvm_info($sformatf("%m (%s)", parent), $sformatf("find txn for rmsg class (%p) found %0d matches", msg.smi_conc_rmsg_class, find_q.size()), UVM_HIGH)
            if (targ_id_err_inj) begin
               `uvm_warning($sformatf("%m"), $sformatf("Restore smi_targ_id to %0h from %0h", <%=obj.DiiInfo[obj.Id].FUnitId%>, msg.smi_targ_id))
               msg.smi_targ_ncore_unit_id = <%=obj.DiiInfo[obj.Id].FUnitId%>;
               msg.pack_smi_seq_item();
               `uvm_warning($sformatf("%m"), $sformatf("smi rsp_unq_identifier changed to %p", msg.smi_rsp_unq_identifier))
            end
            find_q = find_q.find with (
                (item.smi_recd[msg.smi_conc_rmsg_class].smi_unq_identifier == msg.smi_rsp_unq_identifier)
            );
            `uvm_info($sformatf("%m (%s)", parent), $sformatf("find txn for OTHER msg (%0d items): %p\ntxn: %p", msg, find_q[0], find_q.size()), UVM_HIGH)
        end

        if (find_q.size() == 0)   `uvm_error($sformatf("%m (%s)", parent), $sformatf("No TXN match : find_q.size =%0d", find_q.size()))

        else begin
            //unique match
             `uvm_info($sformatf("%m (%s)", parent), $sformatf("msg matches %0d txns. msg:%p:", find_q.size(), msg), UVM_HIGH)

             if(find_q.size() == 1) begin
                 if(
                     (find_q[0].smi_expd[msg.smi_conc_msg_class])    //found unique match
                     //|| (msg.isTreRspMsg() || msg.isCmeRspMsg())   //error response never 'expected' in normal operation  //DNE Ncore 3.0
                 )
                     return find_q[0];
                 else
                     `uvm_error($sformatf("%m (%s)", parent), $sformatf("txn not expecting msg\n\nmsg: %p\n\ntxn: %p\ncmd: %p", msg, find_q[0], find_q[0].smi_recd[eConcMsgCmdReq]))
             end else begin // multiple matches
                `uvm_info($sformatf("%m (%s)", parent), $sformatf("ERROR: msg matches %0d txns: msg=%p", find_q.size(), msg), UVM_LOW)
                // For DTWDBGREQ: a MsgId can be used again before it is retired
                if (find_q[0].smi_recd.exists(eConcMsgDtwDbgReq)) begin
                   `uvm_warning($sformatf("%m (%s)", parent), $sformatf("Mulitple DTWDBGREQ messages may be in the queue"))
                   return find_q[0];
                end else if ($test$plusargs("expect_mission_fault") && $test$plusargs("multiple_mission_faults")) begin
                   `uvm_warning($sformatf("%m (%s)", parent), $sformatf("some responses may have be dropped so would have multiple matches"))
                   return find_q[0];
                end else begin
                   foreach(find_q[i]) find_q[i].print_entry();
                   `uvm_error($sformatf("%m (%s)", parent), $sformatf("msg matches %0d txns", find_q.size()))
                end
             end
        end
    endfunction : get_txn


    //------------------------------------------------------------------------------
    //if txn is complete, retire txn
    function bit tryRetireTxn(ref dii_txn txn, input bit from_scb=0) ;

        int index_to_del[$];
        int txn_retired;
       
        if (txn.smi_recd.exists(eConcMsgCmdReq)) begin
           `uvm_info($sformatf("%m (%s)", parent), $sformatf("In tryRetireTxn (unq_id=%p cmd_msg_id=%p type=%02h addr=%p retired=%0d smi_expd=%0d axi_expd=%0d)\ntxn: %p",
							     txn.smi_recd[eConcMsgCmdReq].smi_unq_identifier, txn.smi_recd[eConcMsgCmdReq].smi_msg_id,
                                                             txn.smi_recd[eConcMsgCmdReq].smi_msg_type, txn.smi_recd[eConcMsgCmdReq].smi_addr,
                                                             txn.retired, txn.smi_expd.size(), txn.axi_expd.size(), txn), UVM_MEDIUM)
        end else if (txn.smi_recd.exists(eConcMsgDtwDbgReq)) begin       
           `uvm_info($sformatf("%m (%s)", parent), $sformatf("In tryRetireTxn (unq_id=%p cmd_msg_id=%p type=%02h retired=%0d smi_expd=%0d axi_expd=%0d)\ntxn: %p",
							     txn.smi_recd[eConcMsgDtwDbgReq].smi_unq_identifier, txn.smi_recd[eConcMsgDtwDbgReq].smi_msg_id,
                                                             txn.smi_recd[eConcMsgDtwDbgReq].smi_msg_type,
                                                             txn.retired, txn.smi_expd.size(), txn.axi_expd.size(), txn), UVM_MEDIUM)
        end       
           
        txn_retired  = txn.retired;  // need to restore txn
        txn.retired  = 0;
        tryRetireTxn = 0;
        if(
            //no more activity expd in this txn
            (txn_retired == 0) &&
            (txn.smi_expd.size() == 0) &&
            (txn.axi_expd.size() == 0)
        ) begin
            index_to_del = txn_q.find_index with ( item == txn );
	    if (index_to_del.size == 0) begin
               if (txn.smi_recd.exists(eConcMsgCmdReq)) begin
	          `uvm_error($sformatf("%m (%s)", parent), $sformatf("NO retire candidate: cmd_msg_id=%2h msg_type=%2h",
								     txn.smi_recd[eConcMsgCmdReq].smi_msg_id, txn.smi_recd[eConcMsgCmdReq].smi_msg_type))
               end else if (txn.smi_recd.exists(eConcMsgDtwDbgReq)) begin
	          `uvm_error($sformatf("%m (%s)", parent), $sformatf("NO retire candidate: cmd_msg_id=%2h msg_type=%2h",
								     txn.smi_recd[eConcMsgDtwDbgReq].smi_msg_id, txn.smi_recd[eConcMsgDtwDbgReq].smi_msg_type))
               end else if (txn.smi_recd.exists(eConcMsgSysReq)) begin
                        `uvm_error($sformatf("%m (%s)", parent), $sformatf("NO retire candidate: cmd_msg_id=%2h msg_type=%2h",
								     txn.smi_recd[eConcMsgSysReq].smi_msg_id, txn.smi_recd[eConcMsgSysReq].smi_msg_type))

               end
	    end

	    if (index_to_del.size() == 1) begin
               if (txn.smi_recd.exists(eConcMsgDtwDbgReq)) begin
                `uvm_info($sformatf("%m (%s)", parent), $sformatf("retired txn: qIdx=%0d txn_q (size=%0d) msg_uid=%p, rmsg_uid=%5h msg_type=%p msg_id=%p addr=%p",
								    index_to_del[0], txn_q.size(),
                                                                    txn.smi_recd[eConcMsgDtwDbgReq].smi_unq_identifier,
                                                                    txn.smi_recd[eConcMsgDtwDbgReq].smi_rsp_unq_identifier,
								    txn.smi_recd[eConcMsgDtwDbgReq].smi_msg_type, txn.smi_recd[eConcMsgDtwDbgReq].smi_msg_id,
								    txn.smi_recd[eConcMsgDtwDbgReq].smi_addr), UVM_LOW)
	            `uvm_info($sformatf("%m"), $sformatf("committed:%0d\tfrom:%0d\tUint:%p\tTXN:%p\tDEALLOC CMD unq_id: %p type: %p",
                                                       dii_scoreboard::num__commits, from_scb, <%=obj.DiiInfo[obj.Id].FUnitId%>,
                                                       txn, txn.smi_recd[eConcMsgDtwDbgReq].smi_unq_identifier, txn.smi_recd[eConcMsgDtwDbgReq].smi_msg_type), UVM_LOW)

               end else if (txn.smi_recd.exists(eConcMsgSysReq)) begin
                `uvm_info($sformatf("%m (%s)", parent), $sformatf("retired txn: qIdx=%0d txn_q (size=%0d) msg_uid=%p, rmsg_uid=%5h msg_type=%p msg_id=%p addr=%p",
								    index_to_del[0], txn_q.size(),
                                                                    txn.smi_recd[eConcMsgSysReq].smi_unq_identifier,
                                                                    txn.smi_recd[eConcMsgSysReq].smi_rsp_unq_identifier,
								    txn.smi_recd[eConcMsgSysReq].smi_msg_type, txn.smi_recd[eConcMsgSysReq].smi_msg_id,
								    txn.smi_recd[eConcMsgSysReq].smi_addr), UVM_LOW)
	            `uvm_info($sformatf("%m"), $sformatf("committed:%0d\tfrom:%0d\tUint:%p\tTXN:%p\tDEALLOC CMD unq_id: %p type: %p",
                                                       dii_scoreboard::num__commits, from_scb, 30,
                                                       txn, txn.smi_recd[eConcMsgSysReq].smi_unq_identifier, txn.smi_recd[eConcMsgSysReq].smi_msg_type), UVM_LOW)
               
               
               end else begin
                  `uvm_info($sformatf("%m (%s)", parent), $sformatf("retired txn: qIdx=%0d txn_q (size=%0d) msg_uid=%p, rmsg_uid=%5h msg_type=%2h msg_id=%2h addr=%p",
								    index_to_del[0], txn_q.size(),
                                                                    txn.smi_recd[eConcMsgCmdReq].smi_unq_identifier,
                                                                    txn.smi_recd[eConcMsgCmdReq].smi_rsp_unq_identifier,
								    txn.smi_recd[eConcMsgCmdReq].smi_msg_type, txn.smi_recd[eConcMsgCmdReq].smi_msg_id,
								    txn.smi_recd[eConcMsgCmdReq].smi_addr), UVM_LOW)

                  if (from_scb) begin // only count if called from scoreboard
                     dii_scoreboard::num__commits++;
	             dii_scoreboard::cmd_str_lat.sample(txn.smi_recd[eConcMsgStrReq].t_smi_ndp_valid-txn.smi_recd[eConcMsgCmdReq].t_smi_ndp_ready);
                     if ( dii_scoreboard::num__commits == dii_scoreboard::sample_end )     dii_scoreboard::t_txn_last    = $time;

                     if ( txn.smi_recd[eConcMsgCmdReq].isCmdNcWrMsg()) begin
                        int dp_valid_idx = txn.smi_recd[eConcMsgDtwReq].t_smi_dp_valid.size() - 1;

                        dii_scoreboard::num__wr_commits++;
                        if (dii_scoreboard::num__wr_commits == dii_scoreboard::sample_end) dii_scoreboard::t_wr_txn_last = $time;
	                dii_scoreboard::dtw_axi_w_lat.sample(txn.axi_recd[axi_w] - txn.smi_recd[eConcMsgDtwReq].t_smi_dp_valid[dp_valid_idx]);
	                dii_scoreboard::cmd_axi_aw_lat.sample(txn.axi_recd[axi_aw] - txn.smi_recd[eConcMsgDtwReq].t_smi_dp_valid[dp_valid_idx]);
	                if (txn.smi_recd[eConcMsgCmdReq].smi_vz) begin // NON-EWA
                           `uvm_info($sformatf("%m"), $sformatf("LAT: B_DTWR: Bt:%p DTWRt:%p", txn.axi_recd[axi_b], txn.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid), UVM_DEBUG)
		           dii_scoreboard::axi_b_dtwrsp_lat.sample(txn.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid - txn.axi_recd[axi_b]);
	                end else begin // EWA
                           `uvm_info($sformatf("%m"), $sformatf("LAT: DTWRReq_DTWRsp: REQt:%p RSPt:%p", txn.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid,
                                                                txn.smi_recd[eConcMsgDtwReq].t_smi_dp_valid[dp_valid_idx]), UVM_DEBUG)
		           dii_scoreboard::dtwreq_dtwrsp_lat.sample(txn.smi_recd[eConcMsgDtwRsp].t_smi_ndp_valid - txn.smi_recd[eConcMsgDtwReq].t_smi_dp_valid[dp_valid_idx]);
	                end
                     end if ( txn.smi_recd[eConcMsgCmdReq].isCmdNcRdMsg()) begin
                        dii_scoreboard::num__rd_commits++;
                        if (dii_scoreboard::num__rd_commits == dii_scoreboard::sample_end) dii_scoreboard::t_rd_txn_last = $time;
	                dii_scoreboard::cmd_axi_ar_lat.sample(txn.axi_recd[axi_ar] - txn.smi_recd[eConcMsgCmdReq].t_smi_ndp_ready);
                        dii_scoreboard::axi_r_dtr_lat.sample(txn.smi_recd[eConcMsgDtrReq].t_smi_ndp_valid - txn.axi_recd[axi_r]);
                     end
                  end

	          // decrement use count in addr_mgr
	          `uvm_info($sformatf("%m"), $sformatf("committed:%0d\tfrom:%0d\tUint:%p\tTXN:%p\tDEALLOC CMD unq_id: %p type: %p addr: %p ",
                                                       dii_scoreboard::num__commits, from_scb, <%=obj.DiiInfo[obj.Id].FUnitId%>,
                                                       txn, txn.smi_recd[eConcMsgCmdReq].smi_unq_identifier, txn.smi_recd[eConcMsgCmdReq].smi_msg_type, txn.smi_recd[eConcMsgCmdReq].smi_addr), UVM_LOW)
	          addr_mgr.addr_evicted_from_agent(<%=obj.DiiInfo[obj.Id].FUnitId%>, 1, (txn.smi_recd[eConcMsgCmdReq].smi_addr>>4)<<4);
               end // else: !if(txn.smi_recd.exists(eConcMsgDtwDbgReq))

	       `uvm_info($sformatf("%m"), $sformatf("delete qIdx=%0d for txn_q (size=%0d)",
                                                    index_to_del[0], txn_q.size()), UVM_LOW)
              //`uvm_info("Vyshak",$sformatf("Vyshak and txn that is going to be deleted is %0p and txn_id is %0d and the order is %0h",txn_q[index_to_del[0]],txn_q[index_to_del[0]].txn_id,txn_q[index_to_del[0]].smi_recd[eConcMsgCmdReq].smi_order),UVM_MEDIUM);
               txn_q.delete(index_to_del[0]);
               tryRetireTxn = 1;
               txn.retired = 1;
	    end else begin // if (index_to_del.size() == 1)
	       for (int i=0; i<index_to_del.size(); i++) begin
		  `uvm_info($sformatf("%m (%s)", parent), $sformatf("retire txn: other candidates %0d\n%p", i, txn_q[index_to_del[i]].smi_recd[eConcMsgCmdReq]), UVM_MEDIUM)
	       end
	    end
	end // if (...

        if (tryRetireTxn == 0) begin
	   txn.retired = txn_retired;
	end
    endfunction : tryRetireTxn


    //------------------------------------------------------------------------------
    //checkers
    //------------------------------------------------------------------------------

    //check whether given msg collides with any outstanding msg
    function void check_collides(smi_seq_item msg);
        bit [2:0] inj_cntl;
        dii_txn find_q[$];

        if (! $value$plusargs("inj_cntl=%d", inj_cntl) ) begin
           inj_cntl = 0;
        end
        find_q = txn_q.find with (
            (item.isOutstanding(msg.smi_conc_msg_class))
        );
        find_q = find_q.find_first with (
            ((item.smi_recd[msg.smi_conc_msg_class].smi_unq_identifier == msg.smi_unq_identifier) &&
             (item.smi_recd[msg.smi_conc_msg_class].smi_ns             == msg.smi_ns)           )
        );

        if (find_q.size() != 0) begin
            foreach (find_q[i]) begin
               `uvm_info($sformatf("%m"), $sformatf("TXN%0d smi_cmd:%p", i, find_q[i].smi_recd[eConcMsgCmdReq]), UVM_LOW)
            end
            if ((inj_cntl > 1) && msg.isDtrMsg()) begin
               `uvm_warning($sformatf("%m (%s)", parent), $sformatf(
                   "concerto message collision\n%p msg_type=%p unqid=%0h ns=%0h collides with previous msg at %0d ps",
                   msg.smi_conc_msg_class, msg.smi_msg_type, msg.smi_unq_identifier, msg.smi_ns,
                   find_q[0].smi_recd[msg.smi_conc_msg_class].t_smi_ndp_valid
               ))
            end else begin
// FIXME !!!
//               `uvm_error($sformatf("%m (%s)", parent), $sformatf(
//                   "concerto message collision\n%p msg_type=%p unqid=%0h ns=%0h collides with previous msg at %0d ps",
//                   msg.smi_conc_msg_class, msg.smi_msg_type, msg.smi_unq_identifier, msg.smi_ns,
//                   find_q[0].smi_recd[msg.smi_conc_msg_class].t_smi_ndp_valid
//               ))
            end
        end

    endfunction : check_collides



    //-----------------------------------------------------------------------

    //remove all txn from q which presently satisfy ordering.  Flag any ordering errors.
    //precondition: all aw correlated to txn.
    //precondition: 
    function void resolve_ordering(bit enforce_same_agent);
        dii_txn dealloc_q[$];
        dii_txn txn;
        dii_txn find_q[$];
        int     deletion_index[$];
        int 	diiIds[<%=obj.DiiInfo.length%>] = '{<% for (var i=0; i<obj.DiiInfo.length; i++) { %><%=obj.DiiInfo[i].FUnitId%><%if (i < obj.DiiInfo.length-1) { %>,<% } } %> };
        int     diiEPs[<%=obj.DiiInfo.length%>] = '{<% for (var i=0; i<obj.DiiInfo.length; i++) { %><%=obj.DiiInfo[i].wLargestEndpoint%><%if (i < obj.DiiInfo.length-1) { %>,<% } } %> };       
        int 	lrgstEp;
        int temp_indexes[$];
        typedef struct packed {
           bit [1:0] policy;  // bit [4:3]
           bit writeid;       // bit 2
           bit readid;        // bit 1
        } mem_order_t;
       
        `uvm_info($sformatf("%m (%s)", parent), $sformatf("Entered..."), UVM_HIGH)

        //txns which have passed bottommost ordering point must have no effect on future txns, so are ready to resolve.
        dealloc_q = txn_q.find with ( 
            item.smi_recd.exists(eConcMsgCmdReq) &&
            ( ( (item.axi_recd[axi_r]) || (item.axi_recd[axi_b])) //txn whose axi has completed
              || ( (item.smi_recd[eConcMsgCmdReq].isCmdCacheOpsMsg()) && item.smi_recd[eConcMsgStrReq] )  //cmo 
            )
        ); 

        for(int i = 0; i < dealloc_q.size() ; i++ ) begin
            txn = dealloc_q[i];

            //////////////////////////////////////////////////////////////////////////////
            //select txns wrt which this must be ordered
            
            foreach (diiIds[i]) begin
	      if (diiIds[i] == txn.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id) begin
	         lrgstEp = diiEPs[i];
	      end
	    end
      
            find_q = txn_q.find with (
                item.smi_recd.exists(eConcMsgCmdReq) &&
		(item.smi_recd[eConcMsgCmdReq].smi_ns == txn.smi_recd[eConcMsgCmdReq].smi_ns) &&                                           //Secure bit for trustzone
                (item.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid < txn.smi_recd[eConcMsgCmdReq].t_smi_ndp_valid)    //older txn
                && (
                    (
                        //from same agent  NOTE ncore agent is a superset of CHI agent
                         ( !enforce_same_agent
                         || ((item.smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id == txn.smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id)
                         && (item.smi_recd[eConcMsgCmdReq].smi_mpf2[WSMIMPF2-2:0] == txn.smi_recd[eConcMsgCmdReq].smi_mpf2[WSMIMPF2-2:0])
                            )
                         )
                        && (
                            (
                                //txn in same request order set
                                //#Check.DII.Order_req_with_req_outstanding
                                //#Check.DII.Order_req_with_ep_outstanding
                                (addrMgrConst::cache_addr(item.smi_recd[eConcMsgCmdReq].smi_addr) == addrMgrConst::cache_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr))  //to same cacheline
                                && ((item.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_REQUEST_WR_OBS) || (item.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT))
                                && (txn.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_REQUEST_WR_OBS)
                            )
                            || (
                                //txn in same endpoint order set
                                //#Check.DII.Order_ep_with_ep_outstanding
                                ( //to same endpoint
                                    addrMgrConst::aligned_addr(item.smi_recd[eConcMsgCmdReq].smi_addr, lrgstEp)
                                    == addrMgrConst::aligned_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr, lrgstEp)
                                )
                                && (item.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT)
                                && (txn.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT)
                            )
                            || (
                                //txn with no ordering set
                                //Need to make sure the ordering for the same src and same flow is maintained
                                (txn.smi_recd[eConcMsgCmdReq].smi_src_id == item.smi_recd[eConcMsgCmdReq].smi_src_id)
                                && (txn.smi_recd[eConcMsgCmdReq].smi_mpf2[WSMIMPF2-2:0] == item.smi_recd[eConcMsgCmdReq].smi_mpf2[WSMIMPF2-2:0])
                                && (txn.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_NONE) && (item.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_NONE)
                                && (addrMgrConst::cache_addr(item.smi_recd[eConcMsgCmdReq].smi_addr) == addrMgrConst::cache_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr))
                                )
                            || (
                                //write observation: from each initiator, all writes with nonnone order must pass point of serialization in order  https://jira.arteris.com/browse/CONC-4964
                                //#Check.DII.Order_wr_obs
                                (txn.smi_recd[eConcMsgCmdReq].isCmdNcWrMsg())
                                && (item.smi_recd[eConcMsgCmdReq].isCmdNcWrMsg())
                                && ((item.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_REQUEST_WR_OBS) || (item.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT))
                                && ((txn.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_REQUEST_WR_OBS) || (txn.smi_recd[eConcMsgCmdReq].smi_order == SMI_ORDER_ENDPOINT))
                            )
                        )
                    )
                    || (
                        //Cache Maintenance Operation
                        // irrespective of source agent
                        (txn.smi_recd[eConcMsgCmdReq].isCmdCacheOpsMsg())
                        && (addrMgrConst::cache_addr(item.smi_recd[eConcMsgCmdReq].smi_addr) == addrMgrConst::cache_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr))  //to same cacheline
                        && (item.smi_recd[eConcMsgCmdReq].isCmdNcWrMsg())
                        && (! item.smi_recd[eConcMsgCmdReq].smi_vz)   //== EWA
                    )
                )
            );
                    
            ///////////////////////////////////////////////////////////////////////////////////////////////

	    // get q entries with matching NS fields
	    find_q = find_q.find with (
	       ( txn.smi_recd.exists(eConcMsgCmdReq) &&
                 (txn.smi_recd[eConcMsgCmdReq].smi_ns == item.smi_recd[eConcMsgCmdReq].smi_ns ) )
	    );

            for (int j = 0; j < find_q.size();  j++) begin
               if (find_q[j].smi_recd.exists(eConcMsgCmdReq) && ((find_q[j].axi_recd[axi_r]) || (find_q[j].axi_recd[axi_b]))) begin
                  `uvm_info($sformatf("%m (%s)", parent), $sformatf("NKR: Check ordering for the Transaction %p", txn), UVM_MEDIUM)
                  `uvm_info($sformatf("%m (%s)", parent), $sformatf("Txn: cmd msg_type=%2h\tsrc_id=%p\tmpf2=%p\tunqid=%p\tns=%0h\torder=%0d\tvz=%0d\tst=%0d\taddr=%p\tepaddr=%0h\tepsize=%0h\ttrgid=%0h\n", 
                  txn.smi_recd[eConcMsgCmdReq].smi_msg_type, txn.smi_recd[eConcMsgCmdReq].smi_src_id,txn.smi_recd[eConcMsgCmdReq].smi_mpf2,
                  txn.smi_recd[eConcMsgCmdReq].smi_unq_identifier, txn.smi_recd[eConcMsgCmdReq].smi_ns, txn.smi_recd[eConcMsgCmdReq].smi_order,
                  txn.smi_recd[eConcMsgCmdReq].smi_vz, txn.smi_recd[eConcMsgCmdReq].smi_st, txn.smi_recd[eConcMsgCmdReq].smi_addr,
                  addrMgrConst::endpoint_addr(txn.smi_recd[eConcMsgCmdReq].smi_addr, txn.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id), <%=obj.DiiInfo[obj.Id].wLargestEndpoint%>,
                  txn.smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id), UVM_MEDIUM)

                  txn.check_ordered(find_q[j],lrgstEp);                  
               end
            end

            ///////////////////////////////////////////////////////////////////////////////////////////////

            //store txn to delete, for which order resolved successfully
            temp_indexes = txn_q.find_index with ((item == txn) &&  (item.smi_recd.exists(eConcMsgCmdReq)) && (((item.axi_recd[axi_r]) || (item.axi_recd[axi_b])) || ((item.smi_recd[eConcMsgCmdReq].isCmdCacheOpsMsg()) && item.smi_recd[eConcMsgStrReq] ))); //gives indices of txns and is stored in temp_indexes 
            foreach (temp_indexes[i]) begin
                deletion_index.push_back(temp_indexes[i]); // stores that index in deletion_index
            end

            
        end //dealloc_q loop

        foreach (deletion_index[idx]) begin // Finally loops through the stored indices and deletes them
          int q_index = deletion_index[idx];
          if (q_index >= 0 && q_index < txn_q.size()) begin
            `uvm_info($sformatf("%m (%s)", parent),$sformatf("order dealloc idx=%0d %p", q_index, txn),UVM_MEDIUM);
            txn_q.delete(q_index);
          end else begin
          //`uvm_warning($sformatf("%m (%s)", parent),$sformatf("Skipping invalid txn_q index %0d", q_index));
          end
        end


    endfunction : resolve_ordering

endclass : dii_txn_q


////////////////////////////////////////////////////////////////////////////////////////////////////

//EOF
