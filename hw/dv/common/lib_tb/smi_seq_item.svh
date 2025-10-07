////////////////////////////////////////////////////////////////////////////////
//
// SMI Sequence Item 
<% if (1 != 0) { %>
// Author: Chirag Gandhi
<% } %>
//
////////////////////////////////////////////////////////////////////////////////

`include "<%=obj.BlockId%>_ConcertoHelperFunctions.svh"

<%
var _ncore_blk_id = 0;
var _ncore_module_name = [];
var _ncore_module_FunitId = [];
var _ncore_module_FunitId_width = [];
var _ncore_module_FportId_width = [];
var pidx = 0;
var qidx = 0;

for(var idx = 0; idx < obj.AiuInfo.length; idx++) {
if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-E')) {
    _ncore_module_name.push('caiu' + pidx);
    _ncore_module_FunitId.push(obj.AiuInfo[idx].FUnitId);
    _ncore_module_FunitId_width.push(obj.AiuInfo[idx].wFUnitId);
    _ncore_module_FportId_width.push(obj.AiuInfo[idx].wFPortId);
    pidx++;
} else {
    _ncore_module_name.push('ioaiu' + qidx);
    _ncore_module_FunitId.push(obj.AiuInfo[idx].FUnitId);
    _ncore_module_FunitId_width.push(obj.AiuInfo[idx].wFUnitId);
    _ncore_module_FportId_width.push(obj.AiuInfo[idx].wFPortId);
    qidx++;
}
_ncore_blk_id++;
}

for(var idx = 0; idx < obj.DceInfo.length; idx++) {
    _ncore_module_name.push('dce' + idx);
    _ncore_module_FunitId.push(obj.DceInfo[idx].FUnitId);
    _ncore_module_FunitId_width.push(obj.DceInfo[idx].wFUnitId);
    _ncore_module_FportId_width.push(obj.DceInfo[idx].wFPortId);
_ncore_blk_id++;
}

for(var idx = 0; idx < obj.DmiInfo.length; idx++) {
    _ncore_module_name.push('dmi' + idx);
    _ncore_module_FunitId.push(obj.DmiInfo[idx].FUnitId);
    _ncore_module_FunitId_width.push(obj.DmiInfo[idx].wFUnitId);
    _ncore_module_FportId_width.push(obj.DmiInfo[idx].wFPortId);
_ncore_blk_id++;
}

for(var idx = 0; idx < obj.DiiInfo.length; idx++) {
    _ncore_module_name.push('dii' + idx);
    _ncore_module_FunitId.push(obj.DiiInfo[idx].FUnitId);
	if(obj.DiiInfo[idx].wFUnitId === undefined)
    _ncore_module_FunitId_width.push(4);
	else
    _ncore_module_FunitId_width.push(obj.DiiInfo[idx].wFUnitId);
    _ncore_module_FportId_width.push(obj.DiiInfo[idx].wFPortId);
_ncore_blk_id++;
}

if (obj.GiuInfo && obj.GiuInfo.length >0) {
    for(var idx = 0; idx < obj.GiuInfo.length; idx++) {
        _ncore_module_name.push('giu' + idx);
        _ncore_module_FunitId.push(obj.GiuInfo[idx].FUnitId);
        _ncore_module_FunitId_width.push(obj.GiuInfo[idx].system.wFUnitId);
        _ncore_module_FportId_width.push(obj.GiuInfo[idx].system.wFPortId);
    _ncore_blk_id++;
    }
}

for(var idx = 0; idx < obj.DveInfo.length; idx++) {
    _ncore_module_name.push('dve' + idx);
    _ncore_module_FunitId.push(obj.DveInfo[idx].FUnitId);
    _ncore_module_FunitId_width.push(obj.DveInfo[idx].wFUnitId);
    _ncore_module_FportId_width.push(obj.DveInfo[idx].wFPortId);
_ncore_blk_id++;
}
%>
class smi_seq_item extends uvm_sequence_item;
    //NDP ports
    smi_msg_valid_bit_t      smi_msg_valid;
    smi_msg_ready_bit_t      smi_msg_ready;
    rand smi_steer_logic_t   smi_steer;
    rand smi_targ_id_bit_t   smi_targ_id;
    rand smi_src_id_bit_t    smi_src_id;
    rand smi_msg_tier_bit_t  smi_msg_tier;
    rand smi_msg_qos_bit_t   smi_msg_qos;
    rand smi_msg_pri_bit_t   smi_msg_pri;
    rand smi_msg_type_bit_t  smi_msg_type;
    smi_ndp_len_bit_t        smi_ndp_len; // TODO: This is constant for a config and a message class. Should constraint this value in this seq_item class
    smi_ndp_bit_t            smi_ndp;
    smi_dp_present_bit_t     smi_dp_present; 
    rand smi_msg_id_bit_t    smi_msg_id;
    rand smi_msg_user_bit_t  smi_msg_user;
    rand smi_msg_hprot_bit_t smi_msg_hprot;
    rand smi_msg_err_bit_t   smi_msg_err;

    //DP ports
    smi_dp_valid_bit_t       smi_dp_valid;
    smi_dp_ready_bit_t       smi_dp_ready;
    smi_dp_last_bit_t        smi_dp_last;
    rand smi_dp_data_bit_t   smi_dp_data[];
    smi_dp_user_bit_t        smi_dp_user[];

//
    // Ncore NDP and DP by-field break down
    rand smi_addr_t                      smi_addr;
    rand smi_vz_t                        smi_vz;
    rand smi_ca_t                        smi_ca;
    rand smi_ac_t                        smi_ac;
    rand smi_ch_t                        smi_ch;
    rand smi_st_t                        smi_st;
    rand smi_en_t                        smi_en;
    rand smi_es_t                        smi_es;
    rand smi_ns_t                        smi_ns; //security bit
    rand smi_pr_t                        smi_pr;
    rand smi_order_t                     smi_order;
    rand smi_lk_t                        smi_lk;
    rand smi_rl_t                        smi_rl;
    rand smi_tm_t                        smi_tm;
    rand smi_prim_t                      smi_prim;
    rand smi_mw_t                        smi_mw;
    rand smi_up_t                        smi_up;
    rand smi_sysreq_op_t                 smi_sysreq_op;
    rand smi_requestor_id_t              smi_requestor_id;
    rand smi_mpf1_stash_valid_t          smi_mpf1_stash_valid;
    rand smi_mpf1_stash_nid_t            smi_mpf1_stash_nid;
    rand smi_mpf1_argv_t                 smi_mpf1_argv;
    rand smi_mpf1_dtr_tgt_id_t           smi_mpf1_dtr_tgt_id;
    rand smi_mpf1_burst_type_t           smi_mpf1_burst_type;
    rand smi_mpf1_alength_t              smi_mpf1_alength;
    rand smi_mpf1_asize_t                smi_mpf1_asize;
    rand smi_mpf1_dtr_long_dtw_t         smi_mpf1_dtr_long_dtw;
    rand smi_mpf1_vmid_ext_t             smi_mpf1_vmid_ext;
    rand smi_mpf1_dtr_msg_id_t           smi_mpf1_dtr_msg_id;
    rand smi_mpf1_awunique_t             smi_mpf1_awunique;
    rand smi_mpf1_t                      smi_mpf1;
    rand smi_mpf2_stash_valid_t          smi_mpf2_stash_valid;
    rand smi_mpf2_stash_lpid_t           smi_mpf2_stash_lpid;
    rand smi_mpf2_flowid_t               smi_mpf2_flowid;
    rand smi_mpf2_flowid_valid_t         smi_mpf2_flowid_valid;
    rand smi_mpf2_dtr_msg_id_t           smi_mpf2_dtr_msg_id;
    rand smi_mpf2_dvmop_id_t             smi_mpf2_dvmop_id;
    rand smi_mpf2_t                      smi_mpf2;
    rand smi_mpf3_intervention_unit_id_t smi_mpf3_intervention_unit_id;
    rand smi_mpf3_dvmop_portion_t        smi_mpf3_dvmop_portion;
    rand smi_mpf3_range_t                smi_mpf3_range;
    rand smi_mpf3_num_t                  smi_mpf3_num;
    rand smi_intfsize_t                  smi_intfsize;
    rand smi_dest_id_t                   smi_dest_id;
    rand smi_size_t                      smi_size;
    rand smi_tof_t                       smi_tof;
    rand smi_qos_t                       smi_qos;
    rand smi_ndp_aux_t                   smi_ndp_aux;
    rand smi_ndp_protection_t            smi_ndp_protection;
    rand smi_rbid_t                      smi_rbid;
    rand smi_rtype_t                     smi_rtype;
    rand smi_type_t                      smi_ecmd_type;
    rand smi_msg_id_bit_t                smi_rmsg_id;
    rand smi_dp_be_t                     smi_dp_be[];
    rand smi_dp_protection_t             smi_dp_protection[];
    rand smi_dp_dwid_t                   smi_dp_dwid[];
    rand smi_dp_dbad_t                   smi_dp_dbad[];
    rand smi_dp_concuser_t               smi_dp_concuser[];
    rand smi_cmstatus_t                  smi_cmstatus;
    rand smi_cmstatus_err_t              smi_cmstatus_err; // If set, CMStatus[7] = 'b1 
    rand smi_cmstatus_err_payload_t      smi_cmstatus_err_payload; // If smi_cm_status_err = 1, this is CMStatus[6:0] 
    rand smi_cmstatus_so_t               smi_cmstatus_so;
    rand smi_cmstatus_ss_t               smi_cmstatus_ss;
    rand smi_cmstatus_sd_t               smi_cmstatus_sd;
    rand smi_cmstatus_st_t               smi_cmstatus_st;
    rand smi_cmstatus_state_t            smi_cmstatus_state;
    rand smi_cmstatus_snarf_t            smi_cmstatus_snarf;
    rand smi_cmstatus_exok_t             smi_cmstatus_exok;
    rand smi_cmstatus_rv_t               smi_cmstatus_rv;
    rand smi_cmstatus_rs_t               smi_cmstatus_rs;
    rand smi_cmstatus_dc_t               smi_cmstatus_dc;
    rand smi_cmstatus_dt_aiu_t           smi_cmstatus_dt_aiu;
    rand smi_cmstatus_dt_dmi_t           smi_cmstatus_dt_dmi;
    rand smi_ncore_unit_id_bit_t         smi_src_ncore_unit_id;
    rand smi_ncore_unit_id_bit_t         smi_targ_ncore_unit_id;
    rand smi_ncore_port_id_bit_t         smi_src_ncore_port_id;
    rand smi_ncore_port_id_bit_t         smi_targ_ncore_port_id;
    eConcMsgClass                        smi_conc_msg_class;
    eConcMsgClass                        smi_conc_rmsg_class; // Will map to the requesting message's msg class
    smi_unq_identifier_bit_t             smi_unq_identifier; // Concat of {smi_conc_msg_class, smi_src_ncore_unit_id, smi_msg_id}
    smi_unq_identifier_bit_t             smi_rsp_unq_identifier; // Concat of {smi_conc_rmsg_class, smi_targ_ncore_unit_id, smi_rmsg_id}
    // Below is to match DTWReq due to Snoop requests to original CmdReq (TODO: need to think about stash snoop DTWs, if any) 
    smi_unq_identifier_bit_t             smi_snp_dtw_unq_identifier; // Concat of {eConcMsgSnpReq, DmiTgtId, DmiRbId}
    smi_unq_identifier_bit_t             smi_snp_dtr_unq_identifier; // Concat of {eConcMsgCmdReq, RequestingSrcId, RequestingMsgId}
    smi_unq_identifier_bit_t             smi_rsp_snp_dtw_unq_identifier; // Concat of {eConcMsgSnpReq, smi_targ_ncore_unit_id, smi_rbid}
    bit                                  smi_transmitter;

    time                                 t_smi_ndp_valid;
    time                                 t_smi_ndp_ready;
    time                                 t_smi_dp_valid[];
    time                                 t_smi_dp_ready[];

    bit				         not_RTL;
    int                                  ndp_corr_error;
    int                                  hdr_corr_error;
    int                                  dp_corr_error;
    int                                  dp_corr_error_eb;
    int                                  ndp_uncorr_error;
    int                                  hdr_uncorr_error;
    int                                  dp_uncorr_error;
    int                                  ndp_parity_error;
    int                                  hdr_parity_error;
    int                                  dp_parity_error;
    int                                  legato_scb_dis;
        string s;
	  string                               block_name[$]; 
	  int                                  FunitId[$];
	  int                                  wFunitId[$];
	  int                                  wPortId[$];
    int                                  pkt_uid;
  
	`uvm_object_param_utils(smi_seq_item)

    function new(string name = "smi_seq_item");
        super.new(name);
        ndp_uncorr_error = 0;
        hdr_uncorr_error = 0;
        dp_uncorr_error  = 0;
        ndp_parity_error = 0;
        hdr_parity_error = 0;
        dp_parity_error  = 0;
        ndp_corr_error   = 0;
        hdr_corr_error   = 0;
        dp_corr_error    = 0;
        dp_corr_error_eb = 0;
	    	legato_scb_dis   = 1; //It should be disable in default state
		    get_FunitId_data();
        pkt_uid = 'hDEADBEEF;
    endfunction : new

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        smi_seq_item _rhs;
        bit legal = 1;
        bit uncorr_error_injcd;
        bit test_unit_duplication;
        bit [2:0] inj_cntl;
        if(!$cast(_rhs, rhs)) begin
            `uvm_error("do_compare", "cast of rhs object failed")
            return 0;
        end
        s = ""; 
        inj_cntl = 3'b000;
        // disable compare for uncorrectable error injection
        void'($value$plusargs("inject_smi_uncorr_error=%d", uncorr_error_injcd));
        void'($value$plusargs("inj_cntl=%d", inj_cntl));
<% if (obj.useResiliency) { %>
<%    if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "none") { %>
        inj_cntl = 3'b000;
<%    } else  { %>
<%       if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
        inj_cntl = inj_cntl & 3'b100;
<%       } else { %>
        inj_cntl = inj_cntl & 3'b011;
<%       }  %>
<%    } %>
<% } else { %>
        inj_cntl = 3'b000;
<% } %>
        void'($value$plusargs("test_unit_duplication=%d", test_unit_duplication));
        if ((uncorr_error_injcd) || (inj_cntl > 1) || (test_unit_duplication)) begin
           `uvm_info($sformatf("%m"), $sformatf("UN-correctable error injected. Skip packet comparison!"), UVM_LOW)
           return legal;
        end

        //argv is don't care in cases of Atomic swap and compare. only applicable for read/write atomics.
        if (smi_msg_type == CMD_CMP_ATM || smi_msg_type == CMD_SW_ATM) begin
            _rhs.smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB] = this.smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB];
        end
        if (smi_msg_type == CMD_WR_STSH_FULL || smi_msg_type == CMD_WR_STSH_PTL
            || smi_msg_type == CMD_LD_CCH_SH || smi_msg_type == CMD_LD_CCH_UNQ) begin
            //Dont care if mpf2_valid is not set
            if (!this.smi_mpf2_stash_valid) begin
                _rhs.smi_mpf2_stash_lpid = this.smi_mpf2_stash_lpid; 
            end
            if (!this.smi_mpf1_stash_valid) begin
                _rhs.smi_mpf1_stash_nid = this.smi_mpf1_stash_nid; 
            end
        end
        if(smi_msg_type == CMD_WR_NC_FULL) begin
            if(!this.smi_mpf2_flowid_valid) begin
                _rhs.smi_mpf2_flowid = this.smi_mpf2_flowid; 
            end
        end
        if (smi_msg_type == CMD_WR_UNQ_FULL || smi_msg_type == CMD_WR_UNQ_PTL) begin
            _rhs.smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB] = this.smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB];
        end
        // Packing because I am only comparing variables that are being driven on the bus
        _rhs.pack_smi_seq_item(.isRtl(!not_RTL));
        this.pack_smi_seq_item();
        // Disabling check till we work out a scheme where both RTL and DV are correct
        if ($test$plusargs("k_targ_src_id_chk_en")) begin
            if (this.smi_targ_id !== _rhs.smi_targ_id) begin
                `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_targ_id: 0x%0x Actual: smi_targ_id: 0x%0x", this.smi_targ_id, _rhs.smi_targ_id), UVM_NONE);
                s = $sformatf("SMI_TARG_ID field mismatched");
                legal = 0;
            end
            if (this.smi_src_id !== _rhs.smi_src_id) begin
                `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_src_id: 0x%0x Actual: smi_src_id: 0x%0x", this.smi_src_id, _rhs.smi_src_id), UVM_NONE); 
                s = $sformatf("SMI_SRC_ID field mismatched");
                // Disabling check till we work out a scheme where both RTL and DV are correct
                legal = 0;
            end
        end
        if (WSMISTEER_EN == 1'b1) begin
        	if (this.smi_steer !== _rhs.smi_steer) begin
       			`uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_steer: 0x%0x Actual: smi_steer: 0x%0x", this.smi_steer, _rhs.smi_steer), UVM_NONE);
               s = $sformatf("SMI_STEER field mismatched");         
            	legal = 0;
            end
        end
        if (WSMIMSGTIER_EN == 1'b1) begin
            if (this.smi_msg_tier !== _rhs.smi_msg_tier) begin
                `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_msg_tier: 0x%0x Actual: smi_msg_tier: 0x%0x", this.smi_msg_tier, _rhs.smi_msg_tier), UVM_NONE); 
                s = $sformatf("SMI_MSG_TIER field mismatched");
                legal = 0;
            end
        end
        if ((WSMIMSGQOS_EN == 1'b1) && (! $test$plusargs("disable_qos_check"))) begin
            if (this.smi_msg_qos !== _rhs.smi_msg_qos) begin
                `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_msg_qos: 0x%0x Actual: smi_msg_qos: 0x%0x", this.smi_msg_qos, _rhs.smi_msg_qos), UVM_NONE); 
                s = $sformatf("SMI_MSG_QOS field mismatched");
                legal = 0;
            end
        end
        if ((WSMIMSGPRI_EN == 1'b1) && (! $test$plusargs("disable_pri_check"))) begin
            if (this.smi_msg_pri !== _rhs.smi_msg_pri) begin
                `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_msg_pri: 0x%0x Actual: smi_msg_pri: 0x%0x", this.smi_msg_pri, _rhs.smi_msg_pri), UVM_NONE); 
                s = $sformatf("SMI_MSG_PRI field mismatched");
                legal = 0;
            end
        end
        if (this.smi_msg_type !== _rhs.smi_msg_type) begin
            `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_msg_type: 0x%0x Actual: smi_msg_type: 0x%0x", this.smi_msg_type, _rhs.smi_msg_type), UVM_NONE);
            s = $sformatf("SMI_MSG_TYPE field mismatched");
            legal = 0;
        end
        if (this.smi_ndp_len !== _rhs.smi_ndp_len) begin
            `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_ndp_len: 0x%0x Actual: smi_ndp_len: 0x%0x", this.smi_ndp_len, _rhs.smi_ndp_len), UVM_NONE); 
            s = $sformatf("SMI_NDP_LEN field mismatched");
            legal = 0;
        end
        if (this.smi_ndp !== _rhs.smi_ndp) begin
            legal &= check_ndp_field_mismatches(_rhs);
            <% if(obj.testBench == "chi_aiu" || obj.testBench == "io_aiu" || obj.testBench == "dce" || obj.testBench == "dii") { %>
                `uvm_info(get_full_name(), $sformatf("%s Expected: smi_ndp: 0x%0x Actual: smi_ndp: 0x%0x (msg_type %p ndp_corr_err:%0d)",
                                                legal?"WARNING":"ERROR", this.smi_ndp, _rhs.smi_ndp, this.smi_msg_type, _rhs.ndp_corr_error), UVM_NONE); 
                if (_rhs.ndp_corr_error == 0) begin
                    legal = 0;
                end
            <% } %>
        end
<% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
        if (this.smi_ndp_protection != _rhs.smi_ndp_protection) begin
            `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_ndp_protection: 0x%0x Actual: ndp_protection: 0x%0x", this.smi_ndp_protection, _rhs.smi_ndp_protection), UVM_NONE); 
            //legal = 1;   // TODO: Need to list all NDP error injection to disable this check
            <% if(obj.testBench == "chi_aiu" || obj.testBench == "io_aiu" || obj.testBench == "dce" || obj.testBench == "dii") { %>
           if (_rhs.ndp_corr_error==0) begin
               legal = 0;
            end else begin            
               `uvm_info(get_full_name(), $sformatf("SMI packet has injected error. Skip smi_ndp_protection checking"), UVM_LOW)
            end
            <% } %>
        end
<% } %>
        if (this.smi_dp_present !== _rhs.smi_dp_present) begin
            `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_dp_present: 0x%0x Actual: smi_dp_present: 0x%0x", this.smi_dp_present, _rhs.smi_dp_present), UVM_NONE); 
            s = $sformatf("SMI_DP_PRESENT field mismatched");
            legal = 0;
        end
        <%if(obj.DutInfo.nNativeInterfacePorts && obj.DutInfo.nNativeInterfacePorts>1 && obj.testBench === "fsys") {%>
            if(this.smi_msg_id[WSMIMSGID-$clog2(<%=obj.DutInfo.nNativeInterfacePorts%>)-1:0] !== _rhs.smi_msg_id[WSMIMSGID-$clog2(<%=obj.DutInfo.nNativeInterfacePorts%>)-1:0]) begin
                `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_msg_id: 0x%0x Actual: smi_msg_id: 0x%0x (core_id info ignored)", this.smi_msg_id, _rhs.smi_msg_id), UVM_NONE);
                s = $sformatf("SMI_MSG_ID field mismatched");
                legal = 0;
            end
        <%} else if (obj.testBench == "chi_aiu" || obj.testBench == "io_aiu") {%>
        if (!(smi_conc_msg_class inside{ eConcMsgCCmdRsp ,eConcMsgNcCmdRsp,eConcMsgDtwRsp}))begin
                 if (this.smi_msg_id !== _rhs.smi_msg_id) begin
                `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_msg_id: 0x%0x Actual: smi_msg_id: 0x%0x", this.smi_msg_id, _rhs.smi_msg_id), UVM_NONE);
                s = $sformatf("SMI_MSG_ID field mismatched");
                legal = 0;
                 end
               end
        <%} else {%>
            if (this.smi_msg_id !== _rhs.smi_msg_id) begin
                `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_msg_id: 0x%0x Actual: smi_msg_id: 0x%0x", this.smi_msg_id, _rhs.smi_msg_id), UVM_NONE); 
                s = $sformatf("SMI_MSG_ID field mismatched");
                legal = 0;
            end
        <%}%>
        <% if (obj.smiObj.WSMINDPAUX > 0) { %> begin
            if (this.smi_ndp_aux !== _rhs.smi_ndp_aux) begin
                if (smi_conc_msg_class == eConcMsgSnpReq && (SNP_REQ_NDP_AUX_MSB == SNP_REQ_NDP_AUX_LSB)) begin
                    `uvm_info(get_full_name(), $sformatf("WARNING Expected: smi_ndp_aux: 0x%0x Actual: smi_ndp_aux: 0x%0x", this.smi_ndp_aux, _rhs.smi_ndp_aux), UVM_NONE);
                    // WSMINDPAUX is by-system, but not all packet types are guaranteed to have space actually allocated for the systems WSMINDPAUX
                    // CONC-10390 -- should this be moved into check_ndp_field_mismatches?
                end else begin
                    `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_ndp_aux: 0x%0x Actual: smi_ndp_aux: 0x%0x", this.smi_ndp_aux, _rhs.smi_ndp_aux), UVM_NONE);
                     s = $sformatf("SNPreq.NDP_AUX field mismatched");
                     legal = 0;
                end

            end
        end
        <% } %>
        if (WSMIMSGERR_EN == 1'b1) begin
            if (this.smi_msg_err !== _rhs.smi_msg_err) begin
                `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_msg_err: 0x%0x Actual: smi_msg_err: 0x%0x", this.smi_msg_err, _rhs.smi_msg_err), UVM_NONE); 
                s = $sformatf("SMI_MSG_ERR field mismatched");
                legal = 0;
            end
        end
        if (this.smi_dp_data !== _rhs.smi_dp_data) begin
            `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_dp_data: %p Actual: smi_dp_data: %p", this.smi_dp_data, _rhs.smi_dp_data), UVM_NONE); 
            s = $sformatf("SMI_DP_DATA field mismatched");
            legal = 0;
        end
        if (WSMIDPUSER_EN == 1'b1) begin
            if (this.smi_dp_user !== _rhs.smi_dp_user) begin
                `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_dp_user: %p Actual: smi_dp_user: %p", this.smi_dp_user, _rhs.smi_dp_user), UVM_NONE); 
                legal &= check_dp_user_field_mismatches(_rhs);
            end
        end
        if (!legal) begin
	    $stacktrace;
		    //Check if legato scoreboard enable or disable
		    if ($value$plusargs("legato_scb_dis=%d", legato_scb_dis));
            
			// If legato scoreboard is enable then we get the below error from there so turning it to UVM_INFO for the same.
			if(legato_scb_dis == 0) begin
			  `uvm_info("do_compare", $sformatf("Above fields of smi_seq_item have mismatched for %p", this.convert2string()),UVM_NONE) 
			end else begin
			  `uvm_info("do_compare", $sformatf("Above fields of smi_seq_item have mismatched for %p", this.convert2string()),UVM_NONE)
			end
	    end
        return legal;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        smi_seq_item _rhs;
        bit legal = 1;
        if(!$cast(_rhs, rhs)) begin
            `uvm_error("do_copy", "cast of rhs object failed")
        end
        this.smi_msg_valid                  = _rhs.smi_msg_valid;
        this.smi_msg_ready                  = _rhs.smi_msg_ready;
        this.smi_steer                      = _rhs.smi_steer;
        this.smi_targ_id                    = _rhs.smi_targ_id;
        this.smi_src_id                     = _rhs.smi_src_id;
        this.smi_msg_tier                   = _rhs.smi_msg_tier;
        this.smi_msg_qos                    = _rhs.smi_msg_qos;
        this.smi_msg_pri                    = _rhs.smi_msg_pri;
        this.smi_msg_type                   = _rhs.smi_msg_type;
        <% if (obj.useResiliency) { %>
        this.smi_msg_user                   = _rhs.smi_msg_user;
        this.smi_msg_hprot                  = _rhs.smi_msg_hprot;
        <% } %>
        this.smi_ndp_len                    = _rhs.smi_ndp_len;
        this.smi_ndp                        = _rhs.smi_ndp;
        this.smi_dp_present                 = _rhs.smi_dp_present;
        this.smi_msg_id                     = _rhs.smi_msg_id;
        this.smi_ndp_aux                    = _rhs.smi_ndp_aux;
        this.smi_msg_err                    = _rhs.smi_msg_err;
        this.smi_dp_valid                   = _rhs.smi_dp_valid;
        this.smi_dp_ready                   = _rhs.smi_dp_ready;
        this.smi_dp_last                    = _rhs.smi_dp_last;
        this.smi_dp_data                    = _rhs.smi_dp_data;
        this.smi_dp_user                    = _rhs.smi_dp_user;
        this.smi_addr                       = _rhs.smi_addr;
        this.smi_vz                         = _rhs.smi_vz;
        this.smi_ca                         = _rhs.smi_ca;
        this.smi_ac                         = _rhs.smi_ac;
        this.smi_ch                         = _rhs.smi_ch;
        this.smi_st                         = _rhs.smi_st;
        this.smi_en                         = _rhs.smi_en;
        this.smi_es                         = _rhs.smi_es;
        this.smi_ns                         = _rhs.smi_ns;
        this.smi_pr                         = _rhs.smi_pr;
        this.smi_order                      = _rhs.smi_order;
        this.smi_lk                         = _rhs.smi_lk;
        this.smi_rl                         = _rhs.smi_rl;
        this.smi_tm                         = _rhs.smi_tm;
        this.smi_prim                       = _rhs.smi_prim;
        this.smi_sysreq_op                  = _rhs.smi_sysreq_op;
        this.smi_requestor_id               = _rhs.smi_requestor_id;
        this.smi_mw                         = _rhs.smi_mw;
        this.smi_up                         = _rhs.smi_up;
        this.smi_mpf1                       = _rhs.smi_mpf1;
        this.smi_mpf1_stash_valid           = _rhs.smi_mpf1_stash_valid;
        this.smi_mpf1_stash_nid             = _rhs.smi_mpf1_stash_nid;
        this.smi_mpf1_argv                  = _rhs.smi_mpf1_argv;
        this.smi_mpf1_dtr_tgt_id            = _rhs.smi_mpf1_dtr_tgt_id;
        this.smi_mpf1_dtr_msg_id            = _rhs.smi_mpf1_dtr_msg_id;
        this.smi_mpf1_asize                 = _rhs.smi_mpf1_asize;
        this.smi_mpf1_dtr_long_dtw          = _rhs.smi_mpf1_dtr_long_dtw;
        this.smi_mpf1_vmid_ext              = _rhs.smi_mpf1_vmid_ext;
        this.smi_mpf1_alength               = _rhs.smi_mpf1_alength;
        this.smi_mpf1_burst_type            = _rhs.smi_mpf1_burst_type;
        this.smi_mpf1_awunique              = _rhs.smi_mpf1_awunique;
        this.smi_mpf2                       = _rhs.smi_mpf2;
        this.smi_mpf2_stash_valid           = _rhs.smi_mpf2_stash_valid;
        this.smi_mpf2_stash_lpid            = _rhs.smi_mpf2_stash_lpid;
        this.smi_mpf2_flowid                = _rhs.smi_mpf2_flowid;
        this.smi_mpf2_flowid_valid          = _rhs.smi_mpf2_flowid_valid;
        this.smi_mpf2_dtr_msg_id            = _rhs.smi_mpf2_dtr_msg_id;
        this.smi_mpf2_dvmop_id              = _rhs.smi_mpf2_dvmop_id;
        this.smi_mpf3_intervention_unit_id  = _rhs.smi_mpf3_intervention_unit_id;
        this.smi_mpf3_dvmop_portion         = _rhs.smi_mpf3_dvmop_portion;
        this.smi_mpf3_range                 = _rhs.smi_mpf3_range;
        this.smi_mpf3_num                   = _rhs.smi_mpf3_num;
        this.smi_size                       = _rhs.smi_size;
        this.smi_tof                        = _rhs.smi_tof;
        this.smi_qos                        = _rhs.smi_qos;
        this.smi_ndp_aux                    = _rhs.smi_ndp_aux;
        this.smi_ndp_protection             = _rhs.smi_ndp_protection;
        this.smi_rbid                       = _rhs.smi_rbid;
        this.smi_rtype                      = _rhs.smi_rtype;
        this.smi_ecmd_type                  = _rhs.smi_ecmd_type;
        this.smi_rmsg_id                    = _rhs.smi_rmsg_id;
        this.smi_dp_be                      = _rhs.smi_dp_be;
        this.smi_dp_protection              = _rhs.smi_dp_protection;
        this.smi_dp_dwid                    = _rhs.smi_dp_dwid;
        this.smi_dp_dbad                    = _rhs.smi_dp_dbad;
        this.smi_dp_concuser                = _rhs.smi_dp_concuser;
        this.smi_cmstatus                   = _rhs.smi_cmstatus;
        this.smi_cmstatus_err               = _rhs.smi_cmstatus_err;
        this.smi_cmstatus_err_payload       = _rhs.smi_cmstatus_err_payload;
        this.smi_cmstatus_so                = _rhs.smi_cmstatus_so;
        this.smi_cmstatus_ss                = _rhs.smi_cmstatus_ss;
        this.smi_cmstatus_sd                = _rhs.smi_cmstatus_sd;
        this.smi_cmstatus_st                = _rhs.smi_cmstatus_st;
        this.smi_cmstatus_state             = _rhs.smi_cmstatus_state;
        this.smi_cmstatus_snarf             = _rhs.smi_cmstatus_snarf;
        this.smi_cmstatus_exok              = _rhs.smi_cmstatus_exok;
        this.smi_cmstatus_rv                = _rhs.smi_cmstatus_rv;
        this.smi_cmstatus_rs                = _rhs.smi_cmstatus_rs;
        this.smi_cmstatus_dc                = _rhs.smi_cmstatus_dc;
        this.smi_cmstatus_dt_aiu            = _rhs.smi_cmstatus_dt_aiu;
        this.smi_cmstatus_dt_dmi            = _rhs.smi_cmstatus_dt_dmi;
        this.smi_intfsize                   = _rhs.smi_intfsize;
        this.smi_dest_id                    = _rhs.smi_dest_id;
        this.smi_src_ncore_unit_id          = _rhs.smi_src_ncore_unit_id;
        this.smi_targ_ncore_unit_id         = _rhs.smi_targ_ncore_unit_id;
        this.smi_src_ncore_port_id          = _rhs.smi_src_ncore_port_id;
        this.smi_targ_ncore_port_id         = _rhs.smi_targ_ncore_port_id;
        this.smi_conc_msg_class             = _rhs.smi_conc_msg_class;
        this.smi_conc_rmsg_class            = _rhs.smi_conc_rmsg_class;
        this.smi_unq_identifier             = _rhs.smi_unq_identifier;
        this.smi_rsp_unq_identifier         = _rhs.smi_rsp_unq_identifier;
        this.smi_snp_dtw_unq_identifier     = _rhs.smi_snp_dtw_unq_identifier;
        this.smi_snp_dtr_unq_identifier     = _rhs.smi_snp_dtr_unq_identifier;
        this.smi_rsp_snp_dtw_unq_identifier = _rhs.smi_rsp_snp_dtw_unq_identifier;
        this.smi_transmitter                = _rhs.smi_transmitter;
        this.t_smi_ndp_ready                = _rhs.t_smi_ndp_ready;
        this.t_smi_ndp_valid                = _rhs.t_smi_ndp_valid;
        this.t_smi_dp_valid                 = _rhs.t_smi_dp_valid;
        this.ndp_corr_error                 = _rhs.ndp_corr_error;
        this.ndp_uncorr_error               = _rhs.ndp_uncorr_error;
        this.ndp_parity_error               = _rhs.ndp_parity_error;
        this.hdr_corr_error                 = _rhs.hdr_corr_error;
        this.hdr_uncorr_error               = _rhs.hdr_uncorr_error;
        this.hdr_parity_error               = _rhs.hdr_parity_error;
        this.dp_corr_error                  = _rhs.dp_corr_error;
        this.dp_corr_error_eb               = _rhs.dp_corr_error_eb;
        this.dp_uncorr_error                = _rhs.dp_uncorr_error;
        this.dp_parity_error                = _rhs.dp_parity_error;

        this.pkt_uid                        = _rhs.pkt_uid;
    endfunction : do_copy

    function void do_copy_one_beat_data_only(uvm_object rhs);
        smi_seq_item _rhs;
        bit legal = 1;
        if(!$cast(_rhs, rhs)) begin
            `uvm_error("do_copy_one_beat_data_only", "cast of rhs object failed")
        end
        this.smi_dp_valid                                   = _rhs.smi_dp_valid;
        this.smi_dp_ready                                   = _rhs.smi_dp_ready;
        this.smi_dp_present                                 = _rhs.smi_dp_present;
        this.smi_dp_last                                    = _rhs.smi_dp_last;
        this.smi_dp_data                                    = new[this.smi_dp_data.size() + 1] (this.smi_dp_data);
        this.smi_dp_data[this.smi_dp_data.size() - 1]       = _rhs.smi_dp_data[0];
        this.smi_dp_user                                    = new[this.smi_dp_user.size() + 1] (this.smi_dp_user);
        this.smi_dp_user[this.smi_dp_user.size() - 1]       = _rhs.smi_dp_user[0];
        this.t_smi_dp_valid                                 = new[this.t_smi_dp_valid.size() + 1] (this.t_smi_dp_valid);
        this.t_smi_dp_valid[this.t_smi_dp_valid.size() - 1] = _rhs.t_smi_dp_valid[0];
    endfunction : do_copy_one_beat_data_only

    function void do_copy_one_beat_data_zero_out(uvm_object rhs);
        smi_seq_item _rhs;
        bit legal = 1;
        if(!$cast(_rhs, rhs)) begin
            `uvm_error("do_copy_one_beat_zero_out", "cast of rhs object failed")
        end
        this.smi_dp_present     = _rhs.smi_dp_present;
        this.smi_dp_valid       = _rhs.smi_dp_valid;
        this.smi_dp_ready       = _rhs.smi_dp_ready;
        this.smi_dp_last        = _rhs.smi_dp_last;
        this.smi_dp_data        = new[1];
        this.smi_dp_data[0]     = _rhs.smi_dp_data[0];
        this.smi_dp_user        = new[1];
        this.smi_dp_user[0]     = _rhs.smi_dp_user[0];
        this.t_smi_dp_valid     = new[1];
        this.t_smi_dp_valid[0]  = _rhs.t_smi_dp_valid[0];
    endfunction : do_copy_one_beat_data_zero_out


    function string convert2string();
        string s;
		    string smi_src;
		    string smi_targ;
		    string msg_type_s;
        smi_msg_type_e  smi_msg_type_enum;

        eMsgCMD     cmd_type;	
        eMsgSNP     snp_type;	
        eMsgSnpRsp  snprsp_type;
        eMsgDTR		dtr_type;

        foreach(FunitId[i]) begin
          if(smi_src_id[WSMISRCID-1:WSMINCOREPORTID] == FunitId[i]) begin
		        smi_src = block_name[i];
		      end
          if(smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == FunitId[i]) begin
		        smi_targ = block_name[i];
		      end
    		end

        s = super.convert2string();
//        $sformat(s, "%s Time:%0t Tx:%p Source:%p Target:%p TargId:%p SrcId:%p MsgType:%p MsgId:%p hprot:%p Tier:%p Steer:%p Pri:%p QoSLabel:%p NdpLen:%p Ndp:%p NdpProt:%p DpPresent:%p TM:%p RMsgId:%p UnqId:%p RUnqId:%p SnpDtwUnqId:%p SnpDtrUnqId:%p SnpRspDtwUnqId:%p, cmstatus_exok:%p, CMStatus:8b%08b",
//                 s, t_smi_ndp_valid, smi_transmitter, smi_src, smi_targ, smi_targ_id, smi_src_id, smi_msg_type, smi_msg_id,smi_msg_hprot,smi_msg_tier, smi_steer, smi_msg_pri, smi_msg_qos, smi_ndp_len,
//                 smi_ndp,smi_ndp_protection,smi_dp_present, smi_tm, smi_rmsg_id, smi_unq_identifier, smi_rsp_unq_identifier, smi_snp_dtw_unq_identifier, smi_snp_dtr_unq_identifier, smi_rsp_snp_dtw_unq_identifier,smi_cmstatus_exok,smi_cmstatus);

        //Updating SMI prints as per requirements mentioned in CONC-10750
        smi_msg_type_enum = smi_msg_type_e'(smi_msg_type);
        msg_type_s =$sformatf("%0s", smi_msg_type_enum.name);
        $sformat(s, "%s Time:%0t Tx:%p Source:%p Target:%p TargId:%p SrcId:%p MsgType:'h%h(%0s) MsgId:%h hprot:%p Tier:%p Steer:%p Pri:%p QoSLabel:%p NdpLen:%p Ndp:%p NdpProt:%p DpPresent:%p TM:%p RMsgId:%h UnqId:0x%h RUnqId:0x%h SnpDtwUnqId:%p SnpDtrUnqId:%p SnpRspDtwUnqId:%p, cmstatus_exok:%p, CMStatus:8b%08b",
                 s, t_smi_ndp_valid, smi_transmitter, smi_src, smi_targ, smi_targ_id[WSMITGTID-1:WSMINCOREPORTID], smi_src_id[WSMISRCID-1:WSMINCOREPORTID], smi_msg_type, msg_type_s.substr(0,msg_type_s.len()-3), smi_msg_id,smi_msg_hprot,smi_msg_tier, smi_steer, smi_msg_pri, smi_msg_qos, smi_ndp_len,
                 smi_ndp,smi_ndp_protection,smi_dp_present, smi_tm, smi_rmsg_id, smi_unq_identifier, smi_rsp_unq_identifier, smi_snp_dtw_unq_identifier, smi_snp_dtr_unq_identifier, smi_rsp_snp_dtw_unq_identifier,smi_cmstatus_exok,smi_cmstatus);
        if (this.smi_dp_present || this.hasDP()) begin
           $sformat(s, "%s Time:%0t DataBE:%p Data:%p Dwid:%p DataUser:%p DataDbad:%p smi_dp_protection:%p dp_last:%p",
                    s, t_smi_dp_valid[t_smi_dp_valid.size() -1], smi_dp_be, smi_dp_data, smi_dp_dwid, smi_dp_user, smi_dp_dbad, smi_dp_protection, smi_dp_last);
        end
		if (this.isDtrMsg()) begin 
        	dtr_type = eMsgDTR'(smi_msg_type);
        	$sformat(s, "%s DtrType: %p", s, dtr_type);
		end 
        if(this.isCmdMsg()) begin
//	$cast(cmd_type, smi_msg_type);
        cmd_type = eMsgCMD'(smi_msg_type);
        $sformat(s, "%s CmdType: %p CMStatus:8b%08b Addr:0x%0h VZ:%p CA:%p AC:%p CH:%p ST:%p EN:%p ES:%p NS:%p PR:%p OR:%p LK:0b%0b RL:0b%0b TM:%p MPF1:{StashValid:%p, StashNId:%p, Argv:%p, BurstType:%p, ALength:%p, ASize:%p, AwUnique:%p}, MPF2:{Valid:%p, StashLPId:%p, FlowIdV:%p, FlowId:%p} Size:0x%0x IntfSize:%p DId:%p TOF:%p QoS:%p AUX:%p NDPProt:%p",
		 s,
		 cmd_type, smi_cmstatus, smi_addr,
		 smi_vz,smi_ca,smi_ac,smi_ch,smi_st,smi_en,smi_es,smi_ns,smi_pr,smi_order,smi_lk,smi_rl,smi_tm,
		 smi_mpf1_stash_valid, smi_mpf1_stash_nid, smi_mpf1_argv,
		 smi_mpf1_burst_type,smi_mpf1_alength,smi_mpf1_asize, smi_mpf1_awunique,
		 smi_mpf2_stash_valid, smi_mpf2_stash_lpid, smi_mpf2_flowid_valid, smi_mpf2_flowid,
		 smi_size,smi_intfsize,smi_dest_id,smi_tof,smi_qos,smi_ndp_aux,smi_ndp_protection
                 );
	end
        if(this.isUpdMsg()) begin
        $sformat(s, "%s TM:%p CMStatus:8b%08b Addr:0x%0x NS:%p Qos:%p NDPProt:0x%0x",
		 s,
		 smi_tm, smi_cmstatus, smi_addr,smi_ns,smi_qos,smi_ndp_protection
                 );
	end
        if(this.isUpdRspMsg()) begin
        $sformat(s, "%s TM:%p RmsgId:%p CMStatus:8b%08b NDPProt:0x%0x",
		 s,
		 smi_tm, smi_rmsg_id, smi_cmstatus, smi_ndp_protection
                 );
	end

        if(this.isSnpMsg()) begin
	   //$cast(snp_type,smi_msg_type);
	   snp_type=eMsgSNP'(smi_msg_type);//Explicit conversion from logic vector to enum bit

           $sformat(s, "%s CMStatus:8b%08b Addr:0x%0h VZ:%p CA:%p AC:%p NS:%p PR:%p UP:%p RL:0b%b TM:%p MPF1:{StashValid:%p, StashNId:%p, DtrTgtId:%p, vmId_ext:%p}, MPF2:{StashValid:%p, StashLPId:%p, DtrMsgId:%p, dvmOpId:%p}, MPF3:{InterventionUnitId:%p, dvmOpPortion:%p, Range:%p, Num:%p}, IntfSize:%p DId:%p TOF:%p QoS:%p RBID:0x%0h Aux:%p NDPProt:%p SnpType:%s",
		 s,
		 smi_cmstatus, smi_addr,
		 smi_vz,smi_ca,smi_ac,smi_ns,smi_pr,smi_up,smi_rl,smi_tm,
		 smi_mpf1_stash_valid, smi_mpf1_stash_nid, smi_mpf1_dtr_tgt_id, smi_mpf1_vmid_ext,
                 smi_mpf2_stash_valid, smi_mpf2_stash_lpid, smi_mpf2_dtr_msg_id, smi_mpf2_dvmop_id,
                 smi_mpf3_intervention_unit_id, smi_mpf3_dvmop_portion, smi_mpf3_range, smi_mpf3_num,
		 smi_intfsize,smi_dest_id,smi_tof,smi_qos,smi_rbid,smi_ndp_aux,smi_ndp_protection,
		 snp_type.name()
                 );
	end
        if(this.isSnpRspMsg()) begin
			$cast(snprsp_type, smi_msg_type);
       		$sformat(msg_type_s, "%p", snprsp_type); 

           $sformat(s, "%s TM:%p RMsgId:%p CMStatus:%0s MPF1:{DtrMsgId:%p} IntfSize:%p NDPProt:%p MsgType:%0s",
		 s,
		 smi_tm, smi_rmsg_id, 
		 (smi_cmstatus_err == 1) ? $psprintf("{Err:%0p Err_Payload:%0p}", smi_cmstatus_err, smi_cmstatus_err_payload) : $psprintf("{RV:%p RS:%p DC:%p DT_aiu:%p DT_dmi:%p Snarf:%p}", smi_cmstatus_rv, smi_cmstatus_rs, smi_cmstatus_dc, smi_cmstatus_dt_aiu, smi_cmstatus_dt_dmi, smi_cmstatus_snarf),
		 smi_mpf1_dtr_msg_id,
		 smi_intfsize,smi_ndp_protection,
		 msg_type_s
                 );
	end
        if (this.isMrdMsg()) begin
        	$sformat(s, "%s Addr:0x%0h NS:%p AC:%p PR:%p RL:0b%0b TM:%p MPF1:{DtrTgtId:%p}, MPF2:{DtrMsgId:%p} Size:0x%0x IntfSize:%p", 
                 s,
                smi_addr, smi_ns, smi_ac, smi_pr, smi_rl, smi_tm,  
		 		smi_mpf1_dtr_tgt_id,
		 		smi_mpf2_dtr_msg_id,
		 		smi_size,
		 		smi_intfsize);
		end

        if(this.isDtwMsg()) begin
           $sformat(s, "%s RBID:%0h CMStatus:8b%08b {Err:0b%b Payload:0b%b} RL:0b%0b TM:%p Primary:%p MPF1:{mpf1:%p} MPF2:{mpf2:%p} IntfSize:%p QOS:%p AUX:%p NDPProt:%p",
		 s,
		 smi_rbid,smi_cmstatus,smi_cmstatus_err, smi_cmstatus_err_payload, smi_rl,smi_tm,smi_prim,
		 smi_mpf1,smi_mpf2,
		 smi_intfsize,smi_qos,smi_ndp_aux,smi_ndp_protection
                 );
	end
    if(this.isStrMsg()) begin
        $sformat(s, "%s TM:%p RMsgId:%p CMStatus:%0s RBID:%0h MPF1:{mpf1:%p StashNId:%0h}, MPF2:{mpf2:%p, mpf2_dtr_msg_id:%0h} IntfSize:%p AUX:%p NDPProt:%p",
		 s,
		 smi_tm, smi_rmsg_id,
		 (smi_cmstatus_err == 1) ? $psprintf("{Err:%0p Err_Payload:%0p}", smi_cmstatus_err, smi_cmstatus_err_payload) : $psprintf("{State:%0p Snarf:%0p ExOk:%0p}", smi_cmstatus_state, smi_cmstatus_snarf, smi_cmstatus_exok),
		 smi_rbid,
		 smi_mpf1,smi_mpf1_stash_nid,smi_mpf2,smi_mpf2_dtr_msg_id,
		 smi_intfsize,smi_ndp_aux,smi_ndp_protection
                 );
	end
        if(this.isRbMsg()) begin
        $sformat(s, "%s TM:%p RBId:%0h CMStatus:8b%08b RType:%p Addr:0x%0h Size:%p VS:%p AC:%p CA:%p NS:%p PR:%p MW:%p RL:%p MPF1:%p TOF:%p QOS:%p AUX:%p NDPProt:%p",
		 s,
		 smi_tm, smi_rbid,smi_cmstatus,smi_rtype,smi_addr,smi_size,
		 smi_vz,smi_ac,smi_ca,smi_ns,smi_pr,smi_mw,smi_rl,
		 smi_mpf1,smi_tof,smi_qos,smi_ndp_aux,smi_ndp_protection);
	end
        if (this.isRbRspMsg()) begin
        $sformat(s, "%s TM:%p RBId:%0h CMStatus:8b%08b RL:%p QOS:%p AUX:%p NDPProt:%p",
                 s,
		 smi_tm,smi_rbid,smi_cmstatus,smi_rl,smi_qos,smi_ndp_aux,smi_ndp_protection);
	end
        if (this.isSysReqMsg()) begin
          smi_sysreq_op_enum_t sysreq_op;
	   	  $cast(sysreq_op, smi_sysreq_op);
          $sformat(s, "SysReq_Op:%p %s", sysreq_op, s);
	end
        return s;
    endfunction : convert2string 

    function void unpack_smi_unq_identifier();
        unpack_smi_conc_msg_class();
        smi_unq_identifier         = {smi_conc_msg_class, smi_src_ncore_unit_id, smi_msg_id};
        // {eConcMsgSnpReq, DmiTgtId, DmiRbId} should be unique for Snp DTWs
        smi_snp_dtw_unq_identifier = {smi_conc_msg_class, smi_dest_id, smi_rbid};
        // {eConcMsgCmdReq, RequestingSrcId, RequestingMsgId} should be unique for Snp DTRs
        smi_snp_dtr_unq_identifier = {smi_conc_rmsg_class, smi_mpf1_dtr_tgt_id, smi_mpf2_dtr_msg_id};
        if (smi_conc_msg_class == eConcMsgDtwReq) begin
            smi_rsp_snp_dtw_unq_identifier = {eConcMsgSnpReq, smi_targ_ncore_unit_id, smi_rbid};
        end
        // non snooping dtw comes from same unit as initiating cmd
        if (smi_conc_msg_class == eConcMsgDtwReq) begin
            smi_rsp_unq_identifier = {smi_conc_rmsg_class, smi_src_ncore_unit_id, smi_rmsg_id};
        end
        // all other msg-rsp come from opposite unit as req,
        //including Snoop related DTR  && errors
        else begin
            smi_rsp_unq_identifier = {smi_conc_rmsg_class, smi_targ_ncore_unit_id, smi_rmsg_id};
        end
    endfunction : unpack_smi_unq_identifier


    function void unpack_smi_conc_msg_class();
        smi_conc_msg_class = type2class(smi_msg_type);
        smi_conc_rmsg_class = rsp2req[smi_conc_msg_class]; 
        
        //error rsp responds to the msg with error
        if(
            (smi_conc_msg_class == eConcMsgCmeRsp)
            || (smi_conc_msg_class == eConcMsgTreRsp)
        )
            smi_conc_rmsg_class = type2class(smi_ecmd_type);

    endfunction : unpack_smi_conc_msg_class


    function void unpack_smi_seq_item();
        bit uncorr_error_injcd;
        bit [2:0] inj_cntl;
        // disable compare for uncorrectable error injection
        void'($value$plusargs("inject_smi_uncorr_error=%d", uncorr_error_injcd));
        void'($value$plusargs("inj_cntl=%d", inj_cntl));

        smi_src_ncore_port_id  = smi_src_id[WSMINCOREPORTID-1:0];
        smi_src_ncore_unit_id  = smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        smi_targ_ncore_port_id = smi_targ_id[WSMINCOREPORTID-1:0];
        smi_targ_ncore_unit_id = smi_targ_id[WSMITGTID-1:WSMINCOREPORTID];
        // assign smi_msg_hprot from smi_msg_user since it is an alias
        smi_msg_hprot = smi_msg_user;
       
        unpack_smi_unq_identifier();
        if (smi_conc_msg_class == eConcMsgCmdReq) begin
            smi_cmstatus = smi_ndp[CMD_REQ_CMSTATUS_MSB:CMD_REQ_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[CMD_REQ_CMSTATUS_MSB-1: CMD_REQ_CMSTATUS_LSB];
            smi_addr  = smi_ndp[CMD_REQ_ADDR_MSB:CMD_REQ_ADDR_LSB];
            smi_vz    = smi_ndp[CMD_REQ_VZ_MSB:CMD_REQ_VZ_LSB];
            smi_ca    = smi_ndp[CMD_REQ_CA_MSB:CMD_REQ_CA_LSB];
            smi_ac    = smi_ndp[CMD_REQ_AC_MSB:CMD_REQ_AC_LSB];
            smi_ch    = smi_ndp[CMD_REQ_CH_MSB:CMD_REQ_CH_LSB];
            smi_st    = smi_ndp[CMD_REQ_ST_MSB:CMD_REQ_ST_LSB];
            smi_en    = smi_ndp[CMD_REQ_EN_MSB:CMD_REQ_EN_LSB];
            smi_es    = smi_ndp[CMD_REQ_ES_MSB:CMD_REQ_ES_LSB];
            smi_ns    = smi_ndp[CMD_REQ_NS_MSB:CMD_REQ_NS_LSB];
            smi_pr    = smi_ndp[CMD_REQ_PR_MSB:CMD_REQ_PR_LSB];
            smi_order = smi_ndp[CMD_REQ_OR_MSB:CMD_REQ_OR_LSB];
            smi_lk    = smi_ndp[CMD_REQ_LK_MSB:CMD_REQ_LK_LSB];
            smi_rl    = smi_ndp[CMD_REQ_RL_MSB:CMD_REQ_RL_LSB];
            smi_tm    = smi_ndp[CMD_REQ_TM_MSB:CMD_REQ_TM_LSB];
            smi_mpf2  = smi_ndp[CMD_REQ_MPF2_MSB:CMD_REQ_MPF2_LSB];
            if (smi_msg_type inside {CMD_WR_STSH_FULL, 
            			     CMD_WR_STSH_PTL, 
            			     CMD_LD_CCH_SH, 
            			     CMD_LD_CCH_UNQ}) begin
				smi_mpf1_stash_valid = smi_ndp[CMD_REQ_MPF1_MSB];
                smi_mpf1_stash_nid   = smi_ndp[CMD_REQ_MPF1_MSB-1:CMD_REQ_MPF1_LSB];
            end
            else if (smi_msg_type == CMD_WR_ATM || smi_msg_type == CMD_RD_ATM ||
                     smi_msg_type == CMD_CMP_ATM || smi_msg_type == CMD_SW_ATM) begin
                smi_mpf1_argv = smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB]; 
            end 
            else if (smi_msg_type == CMD_RD_NC || 
                     smi_msg_type == CMD_WR_NC_PTL ||
                     smi_msg_type == CMD_WR_NC_FULL
            ) begin
                {smi_mpf1_burst_type, smi_mpf1_asize, smi_mpf1_alength} = smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB];
                smi_mpf2_stash_valid  = smi_ndp[SNP_REQ_MPF2_MSB:SNP_REQ_MPF2_MSB];
                smi_mpf2_stash_lpid   = smi_ndp[SNP_REQ_MPF2_MSB-1:SNP_REQ_MPF2_LSB]; 
                smi_mpf2_flowid_valid = smi_ndp[SNP_REQ_MPF2_MSB:SNP_REQ_MPF2_MSB]; 
            end else if (smi_msg_type == CMD_WR_UNQ_FULL || smi_msg_type == CMD_WR_UNQ_PTL) begin
                smi_mpf1_awunique = smi_ndp[CMD_REQ_MPF1_LSB];
            end else begin
	       // don't care
	    end
            if (smi_msg_type == CMD_WR_STSH_FULL || smi_msg_type == CMD_WR_STSH_PTL
                || smi_msg_type == CMD_LD_CCH_SH || smi_msg_type == CMD_LD_CCH_UNQ) begin
                smi_mpf2_stash_valid  = smi_ndp[CMD_REQ_MPF2_MSB];
                smi_mpf2_stash_lpid   = smi_ndp[CMD_REQ_MPF2_MSB-1:CMD_REQ_MPF2_LSB]; 
            end
            else begin
                smi_mpf2_flowid_valid = smi_ndp[CMD_REQ_MPF2_MSB];
                smi_mpf2_flowid       = smi_ndp[CMD_REQ_MPF2_MSB-1:CMD_REQ_MPF2_LSB]; 
            end
            smi_size     = smi_ndp[CMD_REQ_SIZE_MSB:CMD_REQ_SIZE_LSB];
            smi_intfsize = smi_ndp[CMD_REQ_INTF_SIZE_MSB:CMD_REQ_INTF_SIZE_LSB];
            smi_dest_id  = smi_ndp[CMD_REQ_DEST_ID_MSB:CMD_REQ_DEST_ID_LSB];
            smi_tof      = smi_ndp[CMD_REQ_TOF_MSB:CMD_REQ_TOF_LSB];
            smi_qos      = smi_ndp[CMD_REQ_QOS_MSB:CMD_REQ_QOS_LSB];
            <% if (obj.smiObj.WSMINDPAUX != 0) { %>
            smi_ndp_aux      = smi_ndp[CMD_REQ_NDP_AUX_MSB:CMD_REQ_NDP_AUX_LSB];
            <% } %>
            <% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
            smi_ndp_protection = smi_ndp[CMD_REQ_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.cmdReqParams.wMProt%>-1:CMD_REQ_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgSnpReq) begin
            smi_cmstatus = smi_ndp[SNP_REQ_CMSTATUS_MSB:SNP_REQ_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_addr = smi_ndp[SNP_REQ_ADDR_MSB:SNP_REQ_ADDR_LSB];
            smi_vz   = smi_ndp[SNP_REQ_VZ_MSB:SNP_REQ_VZ_LSB];
            smi_ca   = smi_ndp[SNP_REQ_CA_MSB:SNP_REQ_CA_LSB];
            smi_ac   = smi_ndp[SNP_REQ_AC_MSB:SNP_REQ_AC_LSB];
            smi_ns   = smi_ndp[SNP_REQ_NS_MSB:SNP_REQ_NS_LSB];
            smi_pr   = smi_ndp[SNP_REQ_PR_MSB:SNP_REQ_PR_LSB];
            smi_up   = smi_ndp[SNP_REQ_UP_MSB:SNP_REQ_UP_LSB];
            smi_rl   = smi_ndp[SNP_REQ_RL_MSB:SNP_REQ_RL_LSB];
            smi_tm   = smi_ndp[SNP_REQ_TM_MSB:SNP_REQ_TM_LSB];
            if (smi_msg_type == SNP_INV_STSH || 
                smi_msg_type == SNP_UNQ_STSH ||
                smi_msg_type == SNP_STSH_SH ||
                smi_msg_type == SNP_STSH_UNQ
            ) begin
				smi_mpf1_stash_valid = smi_ndp[SNP_REQ_MPF1_MSB];
                smi_mpf1_stash_nid   = smi_ndp[SNP_REQ_MPF1_MSB-1:SNP_REQ_MPF1_LSB];
                smi_mpf2_stash_valid = smi_ndp[SNP_REQ_MPF2_MSB];
                smi_mpf2_stash_lpid  = smi_ndp[SNP_REQ_MPF2_MSB-1:SNP_REQ_MPF2_LSB]; 
            end
	    else if (smi_msg_type == SNP_NOSDINT ||
		smi_msg_type == SNP_CLN_DTR ||
		smi_msg_type == SNP_VLD_DTR ||
		smi_msg_type == SNP_INV_DTR ||
		smi_msg_type == SNP_NITC    ||
		smi_msg_type == SNP_NITCCI  ||
		smi_msg_type == SNP_INV_DTW ||
		smi_msg_type == SNP_INV ||
		smi_msg_type == SNP_CLN_DTW ||
		smi_msg_type == SNP_NITCMI ) begin
                smi_mpf1_dtr_tgt_id = smi_ndp[SNP_REQ_MPF1_MSB:SNP_REQ_MPF1_LSB];  
                smi_mpf2_dtr_msg_id = smi_ndp[SNP_REQ_MPF2_MSB:SNP_REQ_MPF2_LSB];
            end
	    else if (smi_msg_type == SNP_DVM_MSG) begin
	        smi_mpf1_vmid_ext = smi_ndp[SNP_REQ_MPF1_MSB:SNP_REQ_MPF1_LSB];
	        smi_mpf2_dvmop_id = smi_ndp[SNP_REQ_MPF2_MSB:SNP_REQ_MPF2_LSB];
        end else begin
	       // don't care
	    end
	    if (smi_msg_type == SNP_NOSDINT ||
		smi_msg_type == SNP_CLN_DTR ||
		smi_msg_type == SNP_VLD_DTR ||
		smi_msg_type == SNP_INV_DTR ||
		smi_msg_type == SNP_NITC    ||
		smi_msg_type == SNP_NITCCI  ||
                <% if (obj.testBench == "chi_aiu") { %>
		smi_msg_type == SNP_INV_STSH ||
		smi_msg_type == SNP_UNQ_STSH ||
		smi_msg_type == SNP_STSH_SH  ||
		smi_msg_type == SNP_STSH_UNQ ||
		smi_msg_type == SNP_INV_DTW  ||
		smi_msg_type == SNP_CLN_DTW  ||
		smi_msg_type == SNP_INV      || 
                <% } %>
		smi_msg_type == SNP_NITCMI ) begin
                if (smi_up != SMI_UP_NONE) begin
                   smi_mpf3_intervention_unit_id = smi_ndp[SNP_REQ_MPF3_MSB:SNP_REQ_MPF3_LSB];
		end
	    end
            else if (smi_msg_type == SNP_DVM_MSG) begin
                smi_mpf3_dvmop_portion = smi_ndp[SNP_REQ_MPF3_LSB];
                if(smi_mpf3_dvmop_portion == 0) begin
                    smi_mpf3_range     = smi_ndp[SNP_REQ_MPF3_MSB:SNP_REQ_MPF3_LSB+1];
                end else begin
                    smi_mpf3_num       = smi_ndp[SNP_REQ_MPF3_MSB:SNP_REQ_MPF3_LSB+1];
                end
            end else begin
	       // don't care but pass in what is there
                 if (smi_up != SMI_UP_NONE) begin
                   smi_mpf3_intervention_unit_id = smi_ndp[SNP_REQ_MPF3_MSB:SNP_REQ_MPF3_LSB];
		end
	    end
            smi_intfsize = smi_ndp[SNP_REQ_INTF_SIZE_MSB:SNP_REQ_INTF_SIZE_LSB];
            smi_dest_id  = smi_ndp[SNP_REQ_DEST_ID_MSB:SNP_REQ_DEST_ID_LSB];
            smi_tof      = smi_ndp[SNP_REQ_TOF_MSB:SNP_REQ_TOF_LSB];
            smi_qos      = smi_ndp[SNP_REQ_QOS_MSB:SNP_REQ_QOS_LSB];
            smi_rbid     = smi_ndp[SNP_REQ_RBID_MSB:SNP_REQ_RBID_LSB];
            <% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp_aux      = 0; //smi_ndp[SNP_REQ_NDP_AUX_MSB:SNP_REQ_NDP_AUX_LSB]; <% } %> 
            <% if (obj.AiuInfo[0].concParams.snpReqParams.wMProt != 0) { %>
            smi_ndp_protection = smi_ndp[SNP_REQ_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.snpReqParams.wMProt%>-1:SNP_REQ_NDP_PROT_LSB];
            <% } %>

        end
        if (smi_conc_msg_class == eConcMsgHntReq) begin
            smi_cmstatus = smi_ndp[HNT_REQ_CMSTATUS_MSB:HNT_REQ_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_addr = smi_ndp[HNT_REQ_ADDR_MSB:HNT_REQ_ADDR_LSB];
            smi_ac   = smi_ndp[HNT_REQ_AC_MSB:HNT_REQ_AC_LSB];
            smi_ns   = smi_ndp[HNT_REQ_NS_MSB:HNT_REQ_NS_LSB];
            <% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp_aux      = smi_ndp[HNT_REQ_NDP_AUX_MSB:HNT_REQ_NDP_AUX_LSB]; <% } %> 
            <% if (obj.AiuInfo[0].concParams.mrdReqParams.wMProt != 0) { %>
            smi_ndp_protection = smi_ndp[HNT_REQ_NDP_PROT_MSB:HNT_REQ_NDP_PROT_LSB];
            <% } %> 
        end
        if (smi_conc_msg_class == eConcMsgMrdReq) begin
            smi_cmstatus = smi_ndp[MRD_REQ_CMSTATUS_MSB:MRD_REQ_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_addr            = smi_ndp[MRD_REQ_ADDR_MSB:MRD_REQ_ADDR_LSB];
            smi_ac              = smi_ndp[MRD_REQ_AC_MSB:MRD_REQ_AC_LSB];
            smi_ns              = smi_ndp[MRD_REQ_NS_MSB:MRD_REQ_NS_LSB];
            smi_pr              = smi_ndp[MRD_REQ_PR_MSB:MRD_REQ_PR_LSB];
            smi_rl              = smi_ndp[MRD_REQ_RL_MSB:MRD_REQ_RL_LSB];
            smi_tm              = smi_ndp[MRD_REQ_TM_MSB:MRD_REQ_TM_LSB];
            smi_mpf1_dtr_tgt_id = smi_ndp[MRD_REQ_MPF1_MSB:MRD_REQ_MPF1_LSB];
            smi_mpf2_dtr_msg_id = smi_ndp[MRD_REQ_MPF2_MSB:MRD_REQ_MPF2_LSB];
            smi_size            = smi_ndp[MRD_REQ_SIZE_MSB:MRD_REQ_SIZE_LSB];
            smi_intfsize        = smi_ndp[MRD_REQ_INTF_SIZE_MSB:MRD_REQ_INTF_SIZE_LSB];
            smi_qos             = smi_ndp[MRD_REQ_QOS_MSB:MRD_REQ_QOS_LSB];
            <% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp_aux      = smi_ndp[MRD_REQ_NDP_AUX_MSB:MRD_REQ_NDP_AUX_LSB]; <% } %> 
            <% if (obj.AiuInfo[0].concParams.mrdReqParams.wMProt != 0) { %>
            smi_ndp_protection  = smi_ndp[MRD_REQ_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.mrdReqParams.wMProt%>-1:MRD_REQ_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgStrReq) begin
            smi_cmstatus = smi_ndp[STR_REQ_CMSTATUS_MSB:STR_REQ_CMSTATUS_LSB];
	    	if (smi_cmstatus[SMICMSTATUSERRBIT]) begin 
            	smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            	smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            end else begin 
            	smi_cmstatus_err         = 'h0;
            	smi_cmstatus_err_payload = 'h0;
                smi_cmstatus_so    = smi_cmstatus[SMICMSTATUSSTRREQSO];
                smi_cmstatus_ss    = smi_cmstatus[SMICMSTATUSSTRREQSS];
                smi_cmstatus_sd    = smi_cmstatus[SMICMSTATUSSTRREQSD];
                smi_cmstatus_st    = smi_cmstatus[SMICMSTATUSSTRREQST];
                smi_cmstatus_state = smi_cmstatus[3:1]; //Refer to CONC-6925
                smi_cmstatus_snarf = smi_cmstatus[SMICMSTATUSSTRREQSNARF];
                smi_cmstatus_exok  = smi_cmstatus[SMICMSTATUSSTRREQEXOK];
            end
            smi_tm      = smi_ndp[STR_REQ_TM_MSB:STR_REQ_TM_LSB];
            smi_rbid    = smi_ndp[STR_REQ_RBID_MSB:STR_REQ_RBID_LSB];
            smi_rmsg_id = smi_ndp[STR_REQ_RMSGID_MSB:STR_REQ_RMSGID_LSB];
            smi_mpf1_stash_nid  = smi_ndp[STR_REQ_MPF1_MSB:STR_REQ_MPF1_LSB];
            smi_mpf2_dtr_msg_id = smi_ndp[STR_REQ_MPF2_MSB:STR_REQ_MPF2_LSB];
            smi_mpf1            = smi_ndp[STR_REQ_MPF1_MSB:STR_REQ_MPF1_LSB];
            smi_mpf2            = smi_ndp[STR_REQ_MPF2_MSB:STR_REQ_MPF2_LSB];
            smi_intfsize        = smi_ndp[STR_REQ_INTF_SIZE_MSB:STR_REQ_INTF_SIZE_LSB];
//            <% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp_aux      = smi_ndp[STR_REQ_NDP_AUX_MSB:STR_REQ_NDP_AUX_LSB]; <% } %> 
            <% if (obj.AiuInfo[0].concParams.strReqParams.wMProt != 0) { %>
            smi_ndp_protection  = smi_ndp[STR_REQ_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.strReqParams.wMProt%>-1:STR_REQ_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgDtrReq) begin
            smi_cmstatus = smi_ndp[DTR_REQ_CMSTATUS_MSB:DTR_REQ_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_cmstatus_exok     = smi_cmstatus[SMICMSTATUSSTRREQEXOK];
            smi_rl                = smi_ndp[DTR_REQ_RL_MSB:DTR_REQ_RL_LSB];
            smi_tm                = smi_ndp[DTR_REQ_TM_MSB:DTR_REQ_TM_LSB];
            smi_rmsg_id           = smi_ndp[DTR_REQ_RMSGID_MSB:DTR_REQ_RMSGID_LSB];
            smi_mpf1_dtr_long_dtw = smi_ndp[DTR_REQ_MPF1_MSB:DTR_REQ_MPF1_LSB];
            <% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp_aux      = 0; //smi_ndp[DTR_REQ_NDP_AUX_MSB:DTR_REQ_NDP_AUX_LSB]; <% } %> 
            <% if (obj.AiuInfo[0].concParams.dtrReqParams.wMProt != 0) { %>
            smi_ndp_protection    = smi_ndp[DTR_REQ_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.dtrReqParams.wMProt%>-1:DTR_REQ_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgDtwReq) begin
            smi_cmstatus = smi_ndp[DTW_REQ_CMSTATUS_MSB:DTW_REQ_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_rl   = smi_ndp[DTW_REQ_RL_MSB:DTW_REQ_RL_LSB];
            smi_tm   = smi_ndp[DTW_REQ_TM_MSB:DTW_REQ_TM_LSB];
            smi_prim = smi_ndp[DTW_REQ_PRIMARY_LSB:DTW_REQ_PRIMARY_MSB];
            if (smi_msg_type == DTW_MRG_MRD_INV ||
                smi_msg_type == DTW_MRG_MRD_SCLN ||
                smi_msg_type == DTW_MRG_MRD_SDTY ||
                smi_msg_type == DTW_MRG_MRD_UCLN ||
                smi_msg_type == DTW_MRG_MRD_UDTY
            ) begin
                smi_mpf1_dtr_tgt_id = smi_ndp[DTW_REQ_MPF1_MSB:DTW_REQ_MPF1_LSB];
            end
            smi_rbid           = smi_ndp[DTW_REQ_RBID_MSB:DTW_REQ_RBID_LSB];
	        smi_mpf1           = smi_ndp[DTW_REQ_MPF1_MSB:DTW_REQ_MPF1_LSB];
            smi_mpf2           = smi_ndp[DTW_REQ_MPF2_MSB:DTW_REQ_MPF2_LSB];
            smi_intfsize       = smi_ndp[DTW_REQ_INTF_SIZE_MSB:DTW_REQ_INTF_SIZE_LSB];
            <% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp_aux      = 0; //smi_ndp[DTW_REQ_NDP_AUX_MSB:DTW_REQ_NDP_AUX_LSB]; <% } %> 
            <% if (obj.AiuInfo[0].concParams.dtwReqParams.wMProt != 0) { %>
            smi_ndp_protection = smi_ndp[DTW_REQ_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.dtwReqParams.wMProt%>-1:DTW_REQ_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgDtwDbgReq) begin
            smi_tm   = smi_ndp[DTW_DBG_REQ_TM_MSB:DTW_DBG_REQ_TM_LSB];
            smi_cmstatus = smi_ndp[DTW_DBG_REQ_CMSTATUS_MSB:DTW_DBG_REQ_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_rl   = smi_ndp[DTW_DBG_REQ_RL_MSB:DTW_DBG_REQ_RL_LSB];
            <% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp_aux      = 0; //smi_ndp[DTW_DBG_REQ_NDP_AUX_MSB:DTW_DBG_REQ_NDP_AUX_LSB]; <% } %> 
            <% if (obj.AiuInfo[0].concParams.dtwReqParams.wMProt != 0) { %>
            smi_ndp_protection = smi_ndp[DTW_DBG_REQ_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.dtwReqParams.wMProt%>-1:DTW_DBG_REQ_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgUpdReq) begin
            smi_tm       = smi_ndp[UPD_REQ_TM_MSB:UPD_REQ_TM_LSB];
            smi_cmstatus = smi_ndp[UPD_REQ_CMSTATUS_MSB:UPD_REQ_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_addr = smi_ndp[UPD_REQ_ADDR_MSB:UPD_REQ_ADDR_LSB];
            smi_ns   = smi_ndp[UPD_REQ_NS_MSB:UPD_REQ_NS_LSB];
            smi_qos  = smi_ndp[UPD_REQ_QOS_MSB:UPD_REQ_QOS_LSB];
            <% if (obj.AiuInfo[0].concParams.updReqParams.wMProt != 0) { %>
            smi_ndp_protection     = smi_ndp[UPD_REQ_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.updReqParams.wMProt%>-1:UPD_REQ_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgRbReq) begin
            smi_tm       = smi_ndp[RB_REQ_TM_MSB:RB_REQ_TM_LSB];
            smi_rbid     = smi_ndp[RB_REQ_RBID_MSB:RB_REQ_RBID_LSB];
            smi_cmstatus = smi_ndp[RB_REQ_CMSTATUS_MSB:RB_REQ_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_rtype    = smi_ndp[RB_REQ_RTYPE_MSB:RB_REQ_RTYPE_LSB];
            smi_addr     = smi_ndp[RB_REQ_ADDR_MSB:RB_REQ_ADDR_LSB];
            smi_size     = smi_ndp[RB_REQ_SIZE_MSB:RB_REQ_SIZE_LSB];
            smi_vz       = smi_ndp[RB_REQ_VZ_MSB:RB_REQ_VZ_LSB];
            smi_ca       = smi_ndp[RB_REQ_CA_MSB:RB_REQ_CA_LSB];
            smi_ac       = smi_ndp[RB_REQ_AC_MSB:RB_REQ_AC_LSB];
            smi_ns       = smi_ndp[RB_REQ_NS_MSB:RB_REQ_NS_LSB];
            smi_pr       = smi_ndp[RB_REQ_PR_MSB:RB_REQ_PR_LSB];
            smi_mw       = smi_ndp[RB_REQ_MW_MSB:RB_REQ_MW_LSB];
            smi_rl       = smi_ndp[RB_REQ_RL_MSB:RB_REQ_RL_LSB];
            smi_mpf1     = smi_ndp[RB_REQ_MPF1_MSB:RB_REQ_MPF1_LSB];
            smi_tof      = smi_ndp[RB_REQ_TOF_MSB:RB_REQ_TOF_LSB];
            smi_qos      = smi_ndp[RB_REQ_QOS_MSB:RB_REQ_QOS_LSB];
            <% if (obj.smiObj.WSMINDPAUX != 0) { %>
            smi_ndp_aux      = smi_ndp[RB_REQ_NDP_AUX_MSB:RB_REQ_NDP_AUX_LSB];
            <% } %>

            <% if (obj.AiuInfo[0].concParams.rbrReqParams.wMProt != 0) { %>
            smi_ndp_protection     = smi_ndp[RB_REQ_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.rbrReqParams.wMProt%>-1:RB_REQ_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgRbUseReq) begin
            smi_cmstatus = smi_ndp[RBUSE_REQ_CMSTATUS_MSB:RBUSE_REQ_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_tm    = smi_ndp[RBUSE_REQ_TM_MSB:RBUSE_REQ_TM_LSB];
            smi_rbid  = smi_ndp[RBUSE_REQ_RBID_MSB:RBUSE_REQ_RBID_LSB];
            smi_rl       = smi_ndp[RBUSE_REQ_RL_MSB:RBUSE_REQ_RL_LSB];  
            <% if (obj.AiuInfo[0].concParams.rbuReqParams.wMProt != 0) { %>
            smi_ndp_protection     = smi_ndp[RBUSE_REQ_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.rbuReqParams.wMProt%>-1:RBUSE_REQ_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgCCmdRsp) begin
            smi_tm       = smi_ndp[C_CMD_RSP_TM_MSB:C_CMD_RSP_TM_LSB];
            smi_rmsg_id  = smi_ndp[C_CMD_RSP_RMSGID_MSB:C_CMD_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[C_CMD_RSP_CMSTATUS_MSB:C_CMD_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            <% if (obj.AiuInfo[0].concParams.cmdRspParams.wMProt != 0) { %>
            smi_ndp_protection     = smi_ndp[C_CMD_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.cmdRspParams.wMProt%>-1:C_CMD_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgNcCmdRsp) begin
            smi_tm       = smi_ndp[NC_CMD_RSP_TM_MSB:NC_CMD_RSP_TM_LSB];
            smi_rmsg_id  = smi_ndp[NC_CMD_RSP_RMSGID_MSB:NC_CMD_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[NC_CMD_RSP_CMSTATUS_MSB:NC_CMD_RSP_CMSTATUS_LSB];
            if (smi_cmstatus[SMICMSTATUSERRBIT]) begin
                smi_cmstatus_err         = 1;
                smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            end else begin
                smi_cmstatus_err         = 0;
                smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            end
            <% if (obj.AiuInfo[0].concParams.ncCmdRspParams.wMProt != 0) { %>
            smi_ndp_protection     = smi_ndp[NC_CMD_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.ncCmdRspParams.wMProt%>-1:NC_CMD_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgSnpRsp) begin
            smi_tm              = smi_ndp[SNP_RSP_TM_MSB:SNP_RSP_TM_LSB];
            smi_rmsg_id         = smi_ndp[SNP_RSP_RMSGID_MSB:SNP_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[SNP_RSP_CMSTATUS_MSB:SNP_RSP_CMSTATUS_LSB];
                smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
                smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
                smi_cmstatus_rv     = smi_cmstatus[SMICMSTATUSSNPRSPRV];
                smi_cmstatus_rs     = smi_cmstatus[SMICMSTATUSSNPRSPRS];
                smi_cmstatus_dc     = smi_cmstatus[SMICMSTATUSSNPRSPDC];
                smi_cmstatus_dt_aiu = smi_cmstatus[SMICMSTATUSSNPRSPDTAIU];
                smi_cmstatus_dt_dmi = smi_cmstatus[SMICMSTATUSSNPRSPDTDMI];
                smi_cmstatus_snarf  = smi_cmstatus[SMICMSTATUSSNPRSPSNARF];
                smi_mpf1_dtr_msg_id = smi_ndp[SNP_RSP_MPF1_MSB:SNP_RSP_MPF1_LSB];
                smi_intfsize        = smi_ndp[SNP_RSP_INTF_SIZE_MSB:SNP_RSP_INTF_SIZE_LSB];
            <% if (obj.AiuInfo[0].concParams.snpRspParams.wMProt != 0) { %>
            smi_ndp_protection     = smi_ndp[SNP_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.snpRspParams.wMProt%>-1:SNP_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgDtwRsp) begin
            smi_tm       = smi_ndp[DTW_RSP_TM_MSB:DTW_RSP_TM_LSB];
            smi_rmsg_id  = smi_ndp[DTW_RSP_RMSGID_MSB:DTW_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[DTW_RSP_CMSTATUS_MSB:DTW_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_cmstatus_exok     = smi_cmstatus[SMICMSTATUSSTRREQEXOK];
            smi_rl      = smi_ndp[DTW_RSP_RL_MSB:DTW_RSP_RL_LSB];
            <% if (obj.AiuInfo[0].concParams.dtwRspParams.wMProt != 0) { %>
            smi_ndp_protection     = smi_ndp[DTW_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.dtwRspParams.wMProt%>-1:DTW_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgDtwDbgRsp) begin
            smi_rmsg_id = smi_ndp[DTW_DBG_RSP_RMSGID_MSB:DTW_DBG_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[DTW_DBG_RSP_CMSTATUS_MSB:DTW_DBG_RSP_CMSTATUS_LSB];
            smi_rl      = smi_ndp[DTW_DBG_RSP_RL_MSB:DTW_DBG_RSP_RL_LSB];
            <% if (obj.AiuInfo[0].concParams.dtwRspParams.wMProt != 0) { %>
            smi_ndp_protection     = smi_ndp[DTW_DBG_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.dtwRspParams.wMProt%>-1:DTW_DBG_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgDtrRsp) begin
            smi_tm       = smi_ndp[DTR_RSP_TM_MSB:DTR_RSP_TM_LSB];
            smi_rmsg_id  = smi_ndp[DTR_RSP_RMSGID_MSB:DTR_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[DTR_RSP_CMSTATUS_MSB:DTR_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            <% if (obj.AiuInfo[0].concParams.dtrRspParams.wMProt != 0) { %>
            smi_ndp_protection     = smi_ndp[DTR_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.dtrRspParams.wMProt%>-1:DTR_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgHntRsp) begin
            smi_rmsg_id = smi_ndp[HNT_RSP_RMSGID_MSB:HNT_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[HNT_RSP_CMSTATUS_MSB:HNT_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT]; 
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            <% if (obj.smiObj.WSMINDPPROT != 0) { %> smi_ndp_protection = smi_ndp[HNT_RSP_NDP_PROT_MSB:HNT_RSP_NDP_PROT_LSB]; <% } %> 
        end
        if (smi_conc_msg_class == eConcMsgMrdRsp) begin
            smi_tm      = smi_ndp[MRD_RSP_TM_MSB:MRD_RSP_TM_LSB];
            smi_rmsg_id = smi_ndp[MRD_RSP_RMSGID_MSB:MRD_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[MRD_RSP_CMSTATUS_MSB:MRD_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            <% if (obj.AiuInfo[0].concParams.mrdRspParams.wMProt != 0) { %>
            smi_ndp_protection = smi_ndp[MRD_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.mrdRspParams.wMProt%>-1:MRD_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgStrRsp) begin
            smi_tm       = smi_ndp[STR_RSP_TM_MSB:STR_RSP_TM_LSB];
            smi_rmsg_id  = smi_ndp[STR_RSP_RMSGID_MSB:STR_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[STR_RSP_CMSTATUS_MSB:STR_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            <% if (obj.AiuInfo[0].concParams.strRspParams.wMProt != 0) { %>
            smi_ndp_protection = smi_ndp[STR_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.strRspParams.wMProt%>-1:STR_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgUpdRsp) begin
            smi_tm       = smi_ndp[UPD_RSP_TM_MSB:UPD_RSP_TM_LSB];
            smi_rmsg_id  = smi_ndp[UPD_RSP_RMSGID_MSB:UPD_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[UPD_RSP_CMSTATUS_MSB:UPD_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            <% if (obj.AiuInfo[0].concParams.updRspParams.wMProt != 0) { %>
            smi_ndp_protection = smi_ndp[UPD_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.updRspParams.wMProt%>-1:UPD_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgRbRsp) begin
            smi_tm      = smi_ndp[RB_RSP_TM_MSB:RB_RSP_TM_LSB];
            smi_rbid    = smi_ndp[RB_RSP_RBID_MSB:RB_RSP_RBID_LSB];
            smi_cmstatus = smi_ndp[RB_RSP_CMSTATUS_MSB:RB_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            <% if (obj.AiuInfo[0].concParams.rbrRspParams.wMProt != 0) { %>
            smi_ndp_protection = smi_ndp[RB_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.rbrRspParams.wMProt%>-1:RB_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgRbUseRsp) begin
            smi_tm       = smi_ndp[RBUSE_RSP_TM_MSB:RBUSE_RSP_TM_LSB];
            smi_rmsg_id  = smi_ndp[RBUSE_RSP_RMSGID_MSB:RBUSE_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[RBUSE_RSP_CMSTATUS_MSB:RBUSE_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            <% if (obj.AiuInfo[0].concParams.rbuRspParams.wMProt != 0) { %>
            smi_ndp_protection = smi_ndp[RBUSE_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.rbuRspParams.wMProt%>-1:RBUSE_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgCmpRsp) begin
            smi_tm       = smi_ndp[CMP_RSP_TM_MSB:CMP_RSP_TM_LSB];
            smi_rmsg_id  = smi_ndp[CMP_RSP_RMSGID_MSB:CMP_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[CMP_RSP_CMSTATUS_MSB:CMP_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            <% if (obj.AiuInfo[0].concParams.cmpRspParams.wMProt != 0) { %>
            smi_ndp_protection = smi_ndp[CMP_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.cmpRspParams.wMProt%>-1:CMP_RSP_NDP_PROT_LSB];
            <% } %>
        end
        if (smi_conc_msg_class == eConcMsgCmeRsp) begin
            smi_rmsg_id   = smi_ndp[CME_RSP_RMSGID_MSB:CME_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[CME_RSP_CMSTATUS_MSB:CME_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_ecmd_type = smi_ndp[CME_RSP_ECMDTYPE_MSB:CME_RSP_ECMDTYPE_LSB];
            <% if (obj.AiuInfo[0].concParams.mrdReqParams.wMProt != 0) { %>
                smi_ndp_protection = smi_ndp[CME_RSP_NDP_PROT_MSB:CME_RSP_NDP_PROT_LSB];
            <% } %> 
        end
        if (smi_conc_msg_class == eConcMsgTreRsp) begin
            smi_rmsg_id   = smi_ndp[TRE_RSP_RMSGID_MSB:TRE_RSP_RMSGID_LSB];
            smi_cmstatus = smi_ndp[TRE_RSP_CMSTATUS_MSB:TRE_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_ecmd_type = smi_ndp[TRE_RSP_ECMDTYPE_MSB:TRE_RSP_ECMDTYPE_LSB];
            <% if (obj.AiuInfo[0].concParams.mrdReqParams.wMProt != 0) { %>
                smi_ndp_protection = smi_ndp[TRE_RSP_NDP_PROT_MSB:TRE_RSP_NDP_PROT_LSB];
            <% } %> 
        end
        if (smi_conc_msg_class == eConcMsgSysReq) begin
            smi_tm        = smi_ndp[SYS_REQ_TM_MSB:SYS_REQ_TM_LSB];
            smi_rmsg_id   = smi_ndp[SYS_REQ_RMSGID_MSB:SYS_REQ_RMSGID_LSB];
            smi_cmstatus  = smi_ndp[SYS_REQ_CMSTATUS_MSB:SYS_REQ_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            smi_sysreq_op = smi_ndp[SYS_REQ_OP_MSB:SYS_REQ_OP_LSB];
            smi_requestor_id = smi_ndp[SYS_REQ_REQUESTORID_MSB:SYS_REQ_REQUESTORID_LSB];
            <% if (obj.AiuInfo[0].concParams.sysReqParams.wMProt != 0) { %>
                smi_ndp_protection = smi_ndp[SYS_REQ_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.sysReqParams.wMProt%>-1:SYS_REQ_NDP_PROT_LSB];
            <% } %> 
        end
        if (smi_conc_msg_class == eConcMsgSysRsp) begin
            smi_rmsg_id   = smi_ndp[SYS_RSP_RMSGID_MSB:SYS_RSP_RMSGID_LSB];
            smi_cmstatus  = smi_ndp[SYS_RSP_CMSTATUS_MSB:SYS_RSP_CMSTATUS_LSB];
            smi_cmstatus_err         = smi_cmstatus[SMICMSTATUSERRBIT];
            smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0];
            <% if (obj.AiuInfo[0].concParams.sysRspParams.wMProt != 0) { %>
                smi_ndp_protection = smi_ndp[SYS_RSP_NDP_PROT_LSB+<%=obj.AiuInfo[0].concParams.sysRspParams.wMProt%>-1:SYS_RSP_NDP_PROT_LSB];
            <% } %> 
        end
        if (hasDP()) begin
          if(!($test$plusargs("test_unit_duplication") || inj_cntl || uncorr_error_injcd) &&
                (smi_conc_msg_class != eConcMsgDtrReq &&
                 smi_conc_msg_class != eConcMsgDtwReq &&
                 smi_conc_msg_class != eConcMsgDtwDbgReq)
            ) begin
                `uvm_error("unpack_smi_seq_item", $psprintf("smi_dp_present should not be set for %p", this))
            end
        end
        // Calling again to correctly set up smi_rsp_msg_identifier
        unpack_smi_unq_identifier();
    endfunction : unpack_smi_seq_item

    function void unpack_dp_smi_seq_item();
        smi_dp_be         = new[this.smi_dp_user.size()];
        smi_dp_protection = new[this.smi_dp_user.size()];
        smi_dp_dwid       = new[this.smi_dp_user.size()];
        smi_dp_dbad       = new[this.smi_dp_user.size()];
        smi_dp_concuser   = new[this.smi_dp_user.size()];
        foreach (smi_dp_user[i]) begin
            for (int j = 0; j < wSmiDPdata/64; j++) begin
                case ({WSMIDPCONCUSER_EN, WSMIDPPROTPERDW_EN})
                    'b00: begin 
                        {
                            smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                            smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
                            smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                        } = smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW];
                    end
                    'b01: begin 
                        {
                            smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                            smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
<% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
                            smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW],
<% } %>
                            smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                        } = smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW];
                    end
                    'b10: begin 
                        {
                            smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                            smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                            smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW],
            <% } %>
                            smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                        } = smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW];
                    end
                    'b11: begin 
                        {
                            smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                            smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
<% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
                            smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW], <%}%>
<% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                            smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW],  <%}%>
                            smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                        } = smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW];
                    end
                endcase
            end 
        end
    endfunction : unpack_dp_smi_seq_item

    function void pack_smi_seq_item(bit isRtl = 0);
        string retval; 
        int     ndp_prot_lsb, ndp_prot_msb;
       
        unpack_smi_conc_msg_class();
        retval = class2string[smi_conc_msg_class];
        
        <% for (var i = 0; i < obj.smiPortParams.tx.length; i++) { %>
            <% for (var j = 0; j < obj.smiPortParams.tx[i].params.fnMsgClass.length; j++) { %>
                if (dvcmd2rtlcmd[retval] == "<%=obj.smiPortParams.tx[i].params.fnMsgClass[j]%>") begin
                    smi_src_ncore_port_id  = <%=obj.smiPortParams.tx[i].params.fPortId[j]%>;
                    smi_targ_ncore_port_id = <%=obj.smiPortParams.tx[i].params.fPortId[j]%>;
                end
            <% } %>
        <% } %>
        <% for (var i = 0; i < obj.smiPortParams.rx.length; i++) { %>
            <% for (var j = 0; j < obj.smiPortParams.rx[i].params.fnMsgClass.length; j++) { %>
                if (dvcmd2rtlcmd[retval] == "<%=obj.smiPortParams.rx[i].params.fnMsgClass[j]%>") begin
                    smi_src_ncore_port_id  = <%=obj.smiPortParams.rx[i].params.fPortId[j]%>;
                    smi_targ_ncore_port_id = <%=obj.smiPortParams.rx[i].params.fPortId[j]%>;
                end
                <% if(obj.smiPortParams.rx[i].params.fnMsgClass[j] == "cmd_rsp_") { %>
                if (dvcmd2rtlcmd[retval] == "nc_<%=obj.smiPortParams.rx[i].params.fnMsgClass[j]%>") begin
                    	smi_src_ncore_port_id  = <%=obj.smiPortParams.rx[i].params.fPortId[j]%>;
                    	smi_targ_ncore_port_id = <%=obj.smiPortParams.rx[i].params.fPortId[j]%>;
                end
		<% } %>

                <% if(obj.smiPortParams.rx[i].params.fnMsgClass[j] == "dtr_rsp_rx_") { %>
                if (dvcmd2rtlcmd[retval] == "dtr_rsp_") begin
                    	smi_src_ncore_port_id  = <%=obj.smiPortParams.rx[i].params.fPortId[j]%>;
                    	smi_targ_ncore_port_id = <%=obj.smiPortParams.rx[i].params.fPortId[j]%>;
                end
		<% } %>
            <% } %>
        <% } %>

        smi_ndp_len = class2ndp_len[smi_conc_msg_class];
        if (!isRtl) begin
               smi_src_id [WSMINCOREPORTID-1:0] = smi_src_ncore_port_id;
               smi_targ_id[WSMINCOREPORTID-1:0] = smi_targ_ncore_port_id;
        end
        smi_src_id[WSMISRCID-1:WSMINCOREPORTID]  = smi_src_ncore_unit_id;
        smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] = smi_targ_ncore_unit_id;
        `uvm_info("DBG - pack_smi_seq_item", $sformatf("isRtl:%0b retval:%0s smi_targ_id:0x%0x port_id:0x%0x unit_id:0x%0x msg_type=0x%0x ndp_len=0x%0x",
						       isRtl, retval, smi_targ_id, smi_targ_ncore_port_id, smi_targ_ncore_unit_id, smi_msg_type, smi_ndp_len), UVM_MEDIUM)   
        `uvm_info("DBG", $sformatf("isRtl:%0b retval:%0s smi_src_id:0x%0x port_id:0x%0x unit_id:0x%0x",
				   isRtl, retval, smi_src_id, smi_src_ncore_port_id, smi_src_ncore_unit_id), UVM_MEDIUM)   

        // ndp protection constructed per msg class.
        // NOTE: NDP_PROT (MPROT) width are based on Message types, and are the same for all AIUs for the same message
        // So use AiuInfo[0]'s values
        unpack_smi_unq_identifier();
        if (smi_conc_msg_class == eConcMsgCmdReq) begin
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end 
            smi_ndp[CMD_REQ_CMSTATUS_MSB:CMD_REQ_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[CMD_REQ_ADDR_MSB:CMD_REQ_ADDR_LSB]         = smi_addr;
            smi_ndp[CMD_REQ_VZ_MSB:CMD_REQ_VZ_LSB]             = smi_vz;
            smi_ndp[CMD_REQ_CA_MSB:CMD_REQ_CA_LSB]             = smi_ca;
            smi_ndp[CMD_REQ_AC_MSB:CMD_REQ_AC_LSB]             = smi_ac;
            smi_ndp[CMD_REQ_CH_MSB:CMD_REQ_CH_LSB]             = smi_ch;
            smi_ndp[CMD_REQ_ST_MSB:CMD_REQ_ST_LSB]             = smi_st;
            smi_ndp[CMD_REQ_EN_MSB:CMD_REQ_EN_LSB]             = smi_en;
            smi_ndp[CMD_REQ_ES_MSB:CMD_REQ_ES_LSB]             = smi_es;
            smi_ndp[CMD_REQ_NS_MSB:CMD_REQ_NS_LSB]             = smi_ns;
            smi_ndp[CMD_REQ_PR_MSB:CMD_REQ_PR_LSB]             = smi_pr;
            smi_ndp[CMD_REQ_OR_MSB:CMD_REQ_OR_LSB]             = smi_order;
            smi_ndp[CMD_REQ_LK_MSB:CMD_REQ_LK_LSB]             = smi_lk;
            smi_ndp[CMD_REQ_RL_MSB:CMD_REQ_RL_LSB]             = smi_rl;
            smi_ndp[CMD_REQ_TM_MSB:CMD_REQ_TM_LSB]             = smi_tm;
            smi_ndp[CMD_REQ_DEST_ID_MSB:CMD_REQ_DEST_ID_LSB]   = smi_dest_id;
            smi_ndp[CMD_REQ_INTF_SIZE_MSB:CMD_REQ_INTF_SIZE_LSB] = smi_intfsize;
            if (smi_msg_type inside { CMD_WR_STSH_FULL,
            			      CMD_WR_STSH_PTL,
            			      CMD_LD_CCH_SH,
            			      CMD_LD_CCH_UNQ }) begin
                smi_ndp[CMD_REQ_MPF1_MSB]                    = smi_mpf1_stash_valid;
                smi_ndp[CMD_REQ_MPF1_MSB-1:CMD_REQ_MPF1_LSB] = smi_mpf1_stash_nid;
            end else if (smi_msg_type == CMD_WR_ATM || smi_msg_type == CMD_RD_ATM ||
			 smi_msg_type == CMD_CMP_ATM || smi_msg_type == CMD_SW_ATM) begin
                smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB] = smi_mpf1_argv;
            end if (smi_msg_type == CMD_RD_NC || 
                    smi_msg_type == CMD_WR_NC_PTL ||
                    smi_msg_type == CMD_WR_NC_FULL
            ) begin
                smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB] = {smi_mpf1_burst_type, smi_mpf1_asize, smi_mpf1_alength};
            <% if((obj.testBench == "io_aiu" && obj.fnNativeInterface == "ACE") || (obj.testBench == "dce")) { %>
            end else if (smi_msg_type == CMD_WR_UNQ_FULL || smi_msg_type == CMD_WR_UNQ_PTL) begin
                smi_ndp[CMD_REQ_MPF1_LSB] = smi_mpf1_awunique;
            <% } %>
            end else begin
	       // Don't care. Let random stands
	        end
            if (smi_msg_type == CMD_WR_STSH_FULL || smi_msg_type == CMD_WR_STSH_PTL
                || smi_msg_type == CMD_LD_CCH_SH || smi_msg_type == CMD_LD_CCH_UNQ) begin
                smi_ndp[CMD_REQ_MPF2_MSB-1:CMD_REQ_MPF2_LSB] = smi_mpf2_stash_lpid; 
                smi_ndp[CMD_REQ_MPF2_MSB] = smi_mpf2_stash_valid;
            end
            else if (smi_msg_type == CMD_RD_NC || 
                    smi_msg_type == CMD_WR_NC_PTL ||
                    smi_msg_type == CMD_WR_NC_FULL
            ) begin
                smi_ndp[CMD_REQ_MPF2_MSB:CMD_REQ_MPF2_MSB]   = smi_mpf2_flowid_valid;
                smi_ndp[CMD_REQ_MPF2_MSB-1:CMD_REQ_MPF2_LSB] = smi_mpf2_flowid;
            end
            else begin
                smi_ndp[CMD_REQ_MPF2_MSB:CMD_REQ_MPF2_MSB]   = smi_mpf2_flowid_valid;
                smi_ndp[CMD_REQ_MPF2_MSB-1:CMD_REQ_MPF2_LSB] = smi_mpf2_flowid;
            end
            smi_ndp[CMD_REQ_SIZE_MSB:CMD_REQ_SIZE_LSB] = smi_size;
            <% if (obj.smiObj.WSMITOF != 0) { %>
            smi_ndp[CMD_REQ_TOF_MSB:CMD_REQ_TOF_LSB]   = smi_tof;<% }
	    %>
            <% if (obj.smiObj.WSMIQOS != 0) { %>
            smi_ndp[CMD_REQ_QOS_MSB:CMD_REQ_QOS_LSB]   = smi_qos;<% }
	    %>
            <% if (obj.smiObj.WSMINDPAUX != 0) { %>
	    smi_ndp[CMD_REQ_NDP_AUX_MSB:CMD_REQ_NDP_AUX_LSB] = smi_ndp_aux; <% }
	    %>
	    ndp_prot_lsb = CMD_REQ_NDP_PROT_LSB;
	    ndp_prot_msb = CMD_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.cmdReqParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgSnpReq) begin
            smi_ndp[SNP_REQ_CMSTATUS_MSB:SNP_REQ_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[SNP_REQ_ADDR_MSB:SNP_REQ_ADDR_LSB]         = smi_addr;
            smi_ndp[SNP_REQ_VZ_MSB:SNP_REQ_VZ_LSB]             = smi_vz;
            smi_ndp[SNP_REQ_CA_MSB:SNP_REQ_CA_LSB]             = smi_ca;
            smi_ndp[SNP_REQ_AC_MSB:SNP_REQ_AC_LSB]             = smi_ac;
            smi_ndp[SNP_REQ_NS_MSB:SNP_REQ_NS_LSB]             = smi_ns;
            smi_ndp[SNP_REQ_PR_MSB:SNP_REQ_PR_LSB]             = smi_pr;
            smi_ndp[SNP_REQ_UP_MSB:SNP_REQ_UP_LSB]             = smi_up;
            smi_ndp[SNP_REQ_RL_MSB:SNP_REQ_RL_LSB]             = smi_rl;
            smi_ndp[SNP_REQ_TM_MSB:SNP_REQ_TM_LSB]             = smi_tm;
            smi_ndp[SNP_REQ_DEST_ID_MSB:SNP_REQ_DEST_ID_LSB]   = smi_dest_id;
            smi_ndp[SNP_REQ_INTF_SIZE_MSB:SNP_REQ_INTF_SIZE_LSB] = smi_intfsize;
            if (smi_msg_type == SNP_INV_STSH || 
                smi_msg_type == SNP_UNQ_STSH ||
                smi_msg_type == SNP_STSH_SH ||
                smi_msg_type == SNP_STSH_UNQ
            ) begin
                smi_ndp[SNP_REQ_MPF1_MSB]                    = smi_mpf1_stash_valid;
                smi_ndp[SNP_REQ_MPF1_MSB-1:SNP_REQ_MPF1_LSB] = smi_mpf1_stash_nid;
                smi_ndp[SNP_REQ_MPF2_MSB]                    = smi_mpf2_stash_valid;
                smi_ndp[SNP_REQ_MPF2_MSB-1:SNP_REQ_MPF2_LSB] = smi_mpf2_stash_lpid;
            end
            else if (smi_msg_type == SNP_NOSDINT ||
		     smi_msg_type == SNP_CLN_DTR ||
		     smi_msg_type == SNP_VLD_DTR ||
		     smi_msg_type == SNP_INV_DTR ||
             smi_msg_type == SNP_NITC    ||
		     smi_msg_type == SNP_NITCCI  ||
		     smi_msg_type == SNP_NITCMI
	    ) begin
                smi_ndp[SNP_REQ_MPF1_MSB:SNP_REQ_MPF1_LSB] = smi_mpf1_dtr_tgt_id;
                smi_ndp[SNP_REQ_MPF2_MSB:SNP_REQ_MPF2_LSB] = smi_mpf2_dtr_msg_id;
            end
            else if (smi_msg_type == SNP_DVM_MSG) begin
	        	smi_ndp[SNP_REQ_MPF1_MSB:SNP_REQ_MPF1_LSB] = smi_mpf1_vmid_ext;
                smi_ndp[SNP_REQ_MPF2_MSB:SNP_REQ_MPF2_LSB] = smi_mpf2_dvmop_id;
	    end
	    else begin
	       // don't care
	    end
            if (smi_msg_type == SNP_NOSDINT ||
		     smi_msg_type == SNP_CLN_DTR ||
		     smi_msg_type == SNP_VLD_DTR ||
		     smi_msg_type == SNP_INV_DTR ||
                     smi_msg_type == SNP_NITC    ||
		     smi_msg_type == SNP_NITCCI  ||
                  <% if (obj.testBench == "chi_aiu") { %>
		     smi_msg_type == SNP_INV_STSH ||
		     smi_msg_type == SNP_UNQ_STSH ||
		     smi_msg_type == SNP_STSH_SH  ||
		     smi_msg_type == SNP_STSH_UNQ ||
		     smi_msg_type == SNP_INV_DTW  ||
		     smi_msg_type == SNP_CLN_DTW  ||
		     smi_msg_type == SNP_INV      ||
                  <% } %>
		     smi_msg_type == SNP_NITCMI
		) begin
               if(smi_up != SMI_UP_NONE) begin
                  smi_ndp[SNP_REQ_MPF3_MSB:SNP_REQ_MPF3_LSB] = smi_mpf3_intervention_unit_id;
               end
	    end
            else if (smi_msg_type == SNP_DVM_MSG) begin
                smi_ndp[SNP_REQ_MPF3_LSB]                    = smi_mpf3_dvmop_portion;
                if(smi_mpf3_dvmop_portion == 0) begin
                    smi_ndp[SNP_REQ_MPF3_MSB:SNP_REQ_MPF3_LSB+1] = smi_mpf3_range;
                end else begin
                    smi_ndp[SNP_REQ_MPF3_MSB:SNP_REQ_MPF3_LSB+1] = smi_mpf3_num;
                end
            end else begin
	       // don't care
	    end
            smi_ndp[SNP_REQ_TOF_MSB:SNP_REQ_TOF_LSB] = smi_tof;
            smi_ndp[SNP_REQ_QOS_MSB:SNP_REQ_QOS_LSB] = smi_qos;
            smi_ndp[SNP_REQ_RBID_MSB:SNP_REQ_RBID_LSB] = smi_rbid;
            //<% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp[SNP_REQ_NDP_AUX_MSB:SNP_REQ_NDP_AUX_LSB] = smi_ndp_aux; <% } %> 
	    ndp_prot_lsb = SNP_REQ_NDP_PROT_LSB;
	    ndp_prot_msb = SNP_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.snpReqParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgHntReq) begin
	    // not supported
            smi_ndp[HNT_REQ_CMSTATUS_MSB:HNT_REQ_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[HNT_REQ_ADDR_MSB:HNT_REQ_ADDR_LSB]         = smi_addr;
            smi_ndp[HNT_REQ_AC_MSB:HNT_REQ_AC_LSB]             = smi_ac;
            smi_ndp[HNT_REQ_NS_MSB:HNT_REQ_NS_LSB]             = smi_ns;
            <% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp[HNT_REQ_NDP_AUX_MSB:HNT_REQ_NDP_AUX_LSB] = smi_ndp_aux; <% } %> 
	    ndp_prot_lsb = HNT_REQ_NDP_PROT_LSB;
	    ndp_prot_msb = HNT_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.cmdReqParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgMrdReq) begin
            smi_ndp[MRD_REQ_CMSTATUS_MSB:MRD_REQ_CMSTATUS_LSB]   = smi_cmstatus;
            smi_ndp[MRD_REQ_ADDR_MSB:MRD_REQ_ADDR_LSB]           = smi_addr;
            smi_ndp[MRD_REQ_AC_MSB:MRD_REQ_AC_LSB]               = smi_ac;
            smi_ndp[MRD_REQ_NS_MSB:MRD_REQ_NS_LSB]               = smi_ns;
            smi_ndp[MRD_REQ_PR_MSB:MRD_REQ_PR_LSB]               = smi_pr;
            smi_ndp[MRD_REQ_RL_MSB:MRD_REQ_RL_LSB]               = smi_rl;
            smi_ndp[MRD_REQ_TM_MSB:MRD_REQ_TM_LSB]               = smi_tm;
            //since smi_mpf1_dtr_tgt_id is WSMINCOREUNITID wide, just assign that.
            smi_ndp[MRD_REQ_MPF1_LSB+WSMINCOREUNITID-1:MRD_REQ_MPF1_LSB] = smi_mpf1_dtr_tgt_id;
            smi_ndp[MRD_REQ_MPF2_MSB:MRD_REQ_MPF2_LSB]           = smi_mpf2_dtr_msg_id;
            smi_ndp[MRD_REQ_SIZE_MSB:MRD_REQ_SIZE_LSB]           = smi_size;
            smi_ndp[MRD_REQ_INTF_SIZE_MSB:MRD_REQ_INTF_SIZE_LSB] = smi_intfsize;
            smi_ndp[MRD_REQ_QOS_MSB:MRD_REQ_QOS_LSB]             = smi_qos;
            <% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp[MRD_REQ_NDP_AUX_MSB:MRD_REQ_NDP_AUX_LSB] = smi_ndp_aux; <% } %> 
	    ndp_prot_lsb = MRD_REQ_NDP_PROT_LSB;
	    ndp_prot_msb = MRD_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.mrdReqParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgStrReq) begin
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            else begin
                smi_cmstatus[SMICMSTATUSSTRREQSO]    = smi_cmstatus_so;
                smi_cmstatus[SMICMSTATUSSTRREQSS]    = smi_cmstatus_ss;
                smi_cmstatus[SMICMSTATUSSTRREQSD]    = smi_cmstatus_sd;
                smi_cmstatus[SMICMSTATUSSTRREQST]    = smi_cmstatus_st;
                smi_cmstatus[3:1]				     = smi_cmstatus_state; //CONC-6925
                smi_cmstatus[SMICMSTATUSSTRREQSNARF] = 0;
                if (smi_cmstatus_snarf) begin
                    smi_cmstatus[SMICMSTATUSSTRREQSNARF] = smi_cmstatus_snarf;
                end else if (smi_cmstatus_exok) begin
                    smi_cmstatus[SMICMSTATUSSTRREQEXOK]  = smi_cmstatus_exok;
                end
	       
            end
            smi_ndp[STR_REQ_CMSTATUS_MSB:STR_REQ_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[STR_REQ_RBID_MSB:STR_REQ_RBID_LSB]         = smi_rbid;
            smi_ndp[STR_REQ_RMSGID_MSB:STR_REQ_RMSGID_LSB]     = smi_rmsg_id;
            smi_ndp[STR_REQ_TM_MSB:STR_REQ_TM_LSB]             = smi_tm;
            <% if(obj.testBench == "chi_aiu" || obj.testBench == "io_aiu" ) { %>
            if(smi_cmstatus_snarf)
                smi_ndp[STR_REQ_MPF1_MSB:STR_REQ_MPF1_LSB]     = smi_mpf1_stash_nid;
            else
                smi_ndp[STR_REQ_MPF1_MSB:STR_REQ_MPF1_LSB]     = smi_mpf1;
            <% } else { %>
            smi_ndp[STR_REQ_MPF1_MSB:STR_REQ_MPF1_LSB]         = smi_mpf1;
            <% } %>
            smi_ndp[STR_REQ_MPF2_MSB:STR_REQ_MPF2_LSB]         = smi_mpf2;
            smi_ndp[STR_REQ_INTF_SIZE_MSB:STR_REQ_INTF_SIZE_LSB] = smi_intfsize;
//            <% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp[STR_REQ_NDP_AUX_MSB:STR_REQ_NDP_AUX_LSB] = smi_ndp_aux; <% } %> 
	    ndp_prot_lsb = STR_REQ_NDP_PROT_LSB;
	    ndp_prot_msb = STR_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.strReqParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgDtrReq) begin
            smi_dp_present = 1;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            if (smi_cmstatus_exok) begin
                smi_cmstatus[SMICMSTATUSSTRREQEXOK]  = smi_cmstatus_exok;
            end
            smi_ndp[DTR_REQ_CMSTATUS_MSB:DTR_REQ_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[DTR_REQ_RL_MSB:DTR_REQ_RL_LSB]             = smi_rl;
            smi_ndp[DTR_REQ_TM_MSB:DTR_REQ_TM_LSB]             = smi_tm;
            smi_ndp[DTR_REQ_RMSGID_MSB:DTR_REQ_RMSGID_LSB]     = smi_rmsg_id;
            smi_ndp[DTR_REQ_MPF1_MSB:DTR_REQ_MPF1_LSB]         = smi_mpf1_dtr_long_dtw;
            //<% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp[DTR_REQ_NDP_AUX_MSB:DTR_REQ_NDP_AUX_LSB] = smi_ndp_aux; <% } %> 
	    ndp_prot_lsb = DTR_REQ_NDP_PROT_LSB;
	    ndp_prot_msb = DTR_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.dtrReqParams.wMProt%>;
            smi_dp_user                                        = new[this.smi_dp_be.size()];
            smi_dp_protection                                  = new[this.smi_dp_be.size()];
            foreach (smi_dp_user[i]) begin
                for (int j = 0; j < wSmiDPdata/64; j++) begin
                    case ({WSMIDPCONCUSER_EN, WSMIDPPROTPERDW_EN})
                        'b00: begin 
                           smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
                                smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                            };
                        end
                        'b01: begin 
	    <% if (obj.useResiliency) { %>
            <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkSECDED_N({ smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW, 0);
            <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkPARITY_N({ smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW);
            <% } } %>
                           smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                                                                   smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                   smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
<% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
                                                                                   smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW], <%}%>
                                                                                   smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                   };
                        end
                        'b10: begin 
                            smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                                                                    smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                    smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                                                                                    smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW], <%}%>
                                                                                    smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                    };
                        end
                        'b11: begin 
	    <% if (obj.useResiliency) { %>
            <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkSECDED_N({ smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                                                                                                           smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW],  <%}%>
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW, 0);
            <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkPARITY_N({ smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                                                                                                           smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW], <%}%>
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW);
            <% } } %>
                            smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                                                                    smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                    smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                                                                                    smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW],  <%}%>
            <% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
                                                                                    smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW], <%}%>
                                                                                    smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                    };
                        end
                    endcase
                end
            end // foreach (smi_dp_user[i])
        end
        if (smi_conc_msg_class == eConcMsgDtwReq) begin
            smi_dp_present = 1;
            smi_ndp[DTW_REQ_RBID_MSB:DTW_REQ_RBID_LSB]     = smi_rbid;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[DTW_REQ_CMSTATUS_MSB:DTW_REQ_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[DTW_REQ_RL_MSB:DTW_REQ_RL_LSB]             = smi_rl;
            smi_ndp[DTW_REQ_TM_MSB:DTW_REQ_TM_LSB]             = smi_tm;
            smi_ndp[DTW_REQ_PRIMARY_LSB:DTW_REQ_PRIMARY_MSB]   = smi_prim;
	    smi_ndp[DTW_REQ_MPF1_MSB:DTW_REQ_MPF1_LSB]         = smi_mpf1;
            smi_ndp[DTW_REQ_MPF2_MSB:DTW_REQ_MPF2_LSB]         = smi_mpf2;
            smi_ndp[DTW_REQ_INTF_SIZE_MSB:DTW_REQ_INTF_SIZE_LSB] = smi_intfsize;
            //<% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp[DTW_REQ_NDP_AUX_MSB:DTW_REQ_NDP_AUX_LSB] = smi_ndp_aux; <% } %> 
	    ndp_prot_lsb = DTW_REQ_NDP_PROT_LSB;
	    ndp_prot_msb = DTW_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.dtwReqParams.wMProt%>;
            smi_dp_user        = new[this.smi_dp_be.size()];
            smi_dp_protection  = new[this.smi_dp_be.size()];
            foreach (smi_dp_user[i]) begin
                for (int j = 0; j < wSmiDPdata/64; j++) begin
                    case ({WSMIDPCONCUSER_EN, WSMIDPPROTPERDW_EN})
                        'b00: begin 
                            smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
                                smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                            };
                        end
                        'b01: begin 
	    <% if (obj.useResiliency) { %>
            <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkSECDED_N({ smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW, 0);
            <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkPARITY_N({ smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW);
            <% } } %>
                            smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
<% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
                                smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW], <%}%>
                                smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                            };
                        end
                        'b10: begin 
                            smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                                smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW],  <%}%>
                                smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                            };
                        end
                        'b11: begin 
	    <% if (obj.useResiliency) { %>
            <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkSECDED_N({ smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                                                                                                           smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW],  <%}%>
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW, 0);
            <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkPARITY_N({ smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                                                                                                           smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW],  <%}%>
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW);
            <% } } %>
                            smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
            <% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
                                smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW],  <% } %>
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                                smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW],  <% } %>
                                smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                            };
                        end
                    endcase
                end 
            end // foreach (smi_dp_user[i])
        end
        if (smi_conc_msg_class == eConcMsgDtwDbgReq) begin
            smi_dp_present = 1;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[DTW_DBG_REQ_TM_MSB:DTW_DBG_REQ_TM_LSB]             = smi_tm;
            smi_ndp[DTW_DBG_REQ_CMSTATUS_MSB:DTW_DBG_REQ_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[DTW_DBG_REQ_RL_MSB:DTW_DBG_REQ_RL_LSB]             = smi_rl;
            //<% if (obj.smiObj.WSMINDPAUX != 0) { %> smi_ndp[DTW_DBG_REQ_NDP_AUX_MSB:DTW_DBG_REQ_NDP_AUX_LSB] = smi_ndp_aux; <% } %> 
	    ndp_prot_lsb = DTW_DBG_REQ_NDP_PROT_LSB;
	    ndp_prot_msb = DTW_DBG_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.dtwReqParams.wMProt%>;
            smi_dp_user        = new[this.smi_dp_be.size()];
            smi_dp_protection  = new[this.smi_dp_be.size()];
            foreach (smi_dp_user[i]) begin
                for (int j = 0; j < wSmiDPdata/64; j++) begin
                    case ({WSMIDPCONCUSER_EN, WSMIDPPROTPERDW_EN})
                        'b00: begin 
                            smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
                                smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                            };
                        end
                        'b01: begin 
	    <% if (obj.useResiliency) { %>
            <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkSECDED_N( {smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW, 0);
            <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkPARITY_N( {smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW);
            <% } } %>
                            smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
<% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
                                smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW],
<% } %>
                                smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                            };
                        end
                        'b10: begin 
                            smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                                smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW],  <% } %>
                                smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                            };
                        end
                        'b11: begin 
	    <% if (obj.useResiliency) { %>
            <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkSECDED_N({ smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                                                                                                           smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW],  <%}%>
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW, 0);
            <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
                            smi_dp_protection[i][(j*WSMIDPPROTPERDW) +: WSMIDPPROTPERDW] = checkPARITY_N({ smi_dp_data[i][j*64 +: 64],
                                                                                                           smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                                                                                           smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
                                                                                                           smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                                                                                                           },
                                                                                                         64+WSMIDPUSERPERDW-WSMIDPPROTPERDW);
            <% } } %>
                            smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = {
                                smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW],
                                smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW],
<% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
                                smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW],  <% } %>
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                                smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW],   <% } %>
                                smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]
                            };
                        end
                    endcase
                end 
            end // foreach (smi_dp_user[i])
        end
        if (smi_conc_msg_class == eConcMsgUpdReq) begin
            smi_ndp[UPD_REQ_TM_MSB:UPD_REQ_TM_LSB]             = smi_tm;
            smi_ndp[UPD_REQ_CMSTATUS_MSB:UPD_REQ_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[UPD_REQ_ADDR_MSB:UPD_REQ_ADDR_LSB]         = smi_addr;
            smi_ndp[UPD_REQ_NS_MSB:UPD_REQ_NS_LSB]             = smi_ns;
            smi_ndp[UPD_REQ_QOS_MSB:UPD_REQ_QOS_LSB]           = smi_qos;
	    ndp_prot_lsb = UPD_REQ_NDP_PROT_LSB;
	    ndp_prot_msb = UPD_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.updReqParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgRbReq) begin
            smi_ndp[RB_REQ_CMSTATUS_MSB:RB_REQ_CMSTATUS_LSB]   = smi_cmstatus;
            smi_ndp[RB_REQ_TM_MSB:RB_REQ_TM_LSB]               = smi_tm;
            smi_ndp[RB_REQ_RBID_MSB:RB_REQ_RBID_LSB]           = smi_rbid;
            smi_ndp[RB_REQ_RTYPE_MSB:RB_REQ_RTYPE_LSB]         = smi_rtype;
            smi_ndp[RB_REQ_ADDR_MSB:RB_REQ_ADDR_LSB]           = smi_addr;
            smi_ndp[RB_REQ_SIZE_MSB:RB_REQ_SIZE_LSB]           = smi_size;
            smi_ndp[RB_REQ_VZ_MSB:RB_REQ_VZ_LSB]               = smi_vz;
            smi_ndp[RB_REQ_CA_MSB:RB_REQ_CA_LSB]               = smi_ca;
            smi_ndp[RB_REQ_AC_MSB:RB_REQ_AC_LSB]               = smi_ac;
            smi_ndp[RB_REQ_NS_MSB:RB_REQ_NS_LSB]               = smi_ns;
            smi_ndp[RB_REQ_PR_MSB:RB_REQ_PR_LSB]               = smi_pr;
            smi_ndp[RB_REQ_MW_MSB:RB_REQ_MW_LSB]               = smi_mw;
            smi_ndp[RB_REQ_RL_MSB:RB_REQ_RL_LSB]               = smi_rl;
	    	smi_ndp[RB_REQ_MPF1_MSB:RB_REQ_MPF1_LSB]           = smi_mpf1;
            smi_ndp[RB_REQ_TOF_MSB:RB_REQ_TOF_LSB]             = smi_tof;
            smi_ndp[RB_REQ_QOS_MSB:RB_REQ_QOS_LSB]             = smi_qos;
       <% if (obj.smiObj.WSMINDPAUX != 0) { %>
	    smi_ndp[RB_REQ_NDP_AUX_MSB:RB_REQ_NDP_AUX_LSB] = smi_ndp_aux; <% }
	    %>
	    ndp_prot_lsb = RB_REQ_NDP_PROT_LSB;
	    ndp_prot_msb = RB_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.rbrReqParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgRbUseReq) begin
            smi_ndp[RBUSE_REQ_CMSTATUS_MSB:RBUSE_REQ_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[RBUSE_REQ_RBID_MSB:RBUSE_REQ_RBID_LSB]         = smi_rbid;
            smi_ndp[RBUSE_REQ_RL_MSB:RBUSE_REQ_RL_LSB]             = smi_rl;  
            smi_ndp[RBUSE_REQ_TM_MSB:RBUSE_REQ_TM_LSB]             = smi_tm;  
	    	ndp_prot_lsb = RBUSE_REQ_NDP_PROT_LSB;
	    	ndp_prot_msb = RBUSE_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.rbuReqParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgCCmdRsp) begin
            smi_ndp[C_CMD_RSP_TM_MSB:C_CMD_RSP_TM_LSB]         = smi_tm;
            smi_ndp[C_CMD_RSP_RMSGID_MSB:C_CMD_RSP_RMSGID_LSB] = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[C_CMD_RSP_CMSTATUS_MSB:C_CMD_RSP_CMSTATUS_LSB] = smi_cmstatus;
	    ndp_prot_lsb = C_CMD_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = C_CMD_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.cmdRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgNcCmdRsp) begin
            smi_ndp[NC_CMD_RSP_TM_MSB:NC_CMD_RSP_TM_LSB]             = smi_tm;
            smi_ndp[NC_CMD_RSP_RMSGID_MSB:NC_CMD_RSP_RMSGID_LSB]     = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[NC_CMD_RSP_CMSTATUS_MSB:NC_CMD_RSP_CMSTATUS_LSB] = smi_cmstatus;
	    ndp_prot_lsb = NC_CMD_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = NC_CMD_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.ncCmdRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgSnpRsp) begin
            smi_ndp[SNP_RSP_TM_MSB:SNP_RSP_TM_LSB]         = smi_tm;
            smi_ndp[SNP_RSP_RMSGID_MSB:SNP_RSP_RMSGID_LSB] = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end else begin
                smi_cmstatus[SMICMSTATUSSNPRSPRV]    = smi_cmstatus_rv;
                smi_cmstatus[SMICMSTATUSSNPRSPRS]    = smi_cmstatus_rs;
                smi_cmstatus[SMICMSTATUSSNPRSPDC]    = smi_cmstatus_dc;
                smi_cmstatus[SMICMSTATUSSNPRSPDTAIU] = smi_cmstatus_dt_aiu;
                smi_cmstatus[SMICMSTATUSSNPRSPDTDMI] = smi_cmstatus_dt_dmi;
                smi_cmstatus[SMICMSTATUSSNPRSPSNARF] = smi_cmstatus_snarf;
            end
            smi_ndp[SNP_RSP_CMSTATUS_MSB:SNP_RSP_CMSTATUS_LSB]   = smi_cmstatus;
            smi_ndp[SNP_RSP_MPF1_MSB:SNP_RSP_MPF1_LSB]           = smi_mpf1_dtr_msg_id;
            smi_ndp[SNP_RSP_INTF_SIZE_MSB:SNP_RSP_INTF_SIZE_LSB] = smi_intfsize;
	    ndp_prot_lsb = SNP_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = SNP_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.snpRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgDtwRsp) begin
            smi_ndp[DTW_RSP_TM_MSB:DTW_RSP_TM_LSB]         = smi_tm;
            smi_ndp[DTW_RSP_RMSGID_MSB:DTW_RSP_RMSGID_LSB] = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[DTW_RSP_CMSTATUS_MSB:DTW_RSP_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[DTW_RSP_RL_MSB:DTW_RSP_RL_LSB]             = smi_rl;
	    ndp_prot_lsb = DTW_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = DTW_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.dtwRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgDtwDbgRsp) begin
            smi_ndp[DTW_DBG_RSP_RMSGID_MSB:DTW_DBG_RSP_RMSGID_LSB]     = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[DTW_DBG_RSP_CMSTATUS_MSB:DTW_DBG_RSP_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[DTW_DBG_RSP_RL_MSB:DTW_DBG_RSP_RL_LSB]             = smi_rl;
	    ndp_prot_lsb = DTW_DBG_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = DTW_DBG_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.dtwDbgRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgDtrRsp) begin
            smi_ndp[DTR_RSP_TM_MSB:DTR_RSP_TM_LSB]         = smi_tm;
            smi_ndp[DTR_RSP_RMSGID_MSB:DTR_RSP_RMSGID_LSB] = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[DTR_RSP_CMSTATUS_MSB:DTR_RSP_CMSTATUS_LSB] = smi_cmstatus;
	    ndp_prot_lsb = DTR_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = DTR_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.dtrRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgHntRsp) begin
	    // not supported
            smi_ndp[HNT_RSP_RMSGID_MSB:HNT_RSP_RMSGID_LSB]     = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[HNT_RSP_CMSTATUS_MSB:HNT_RSP_CMSTATUS_LSB] = smi_cmstatus;
	    ndp_prot_lsb = HNT_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = HNT_RSP_NDP_PROT_MSB;
        end
        if (smi_conc_msg_class == eConcMsgMrdRsp) begin
            smi_ndp[MRD_RSP_TM_MSB:MRD_RSP_TM_LSB]             = smi_tm;
            smi_ndp[MRD_RSP_RMSGID_MSB:MRD_RSP_RMSGID_LSB]     = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[MRD_RSP_CMSTATUS_MSB:MRD_RSP_CMSTATUS_LSB] = smi_cmstatus;
	    ndp_prot_lsb = MRD_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = MRD_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.mrdRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgStrRsp) begin
            smi_ndp[STR_RSP_TM_MSB:STR_RSP_TM_LSB]             = smi_tm;
            smi_ndp[STR_RSP_RMSGID_MSB:STR_RSP_RMSGID_LSB]     = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[STR_RSP_CMSTATUS_MSB:STR_RSP_CMSTATUS_LSB] = smi_cmstatus;
	    ndp_prot_lsb = STR_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = STR_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.strRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgUpdRsp) begin
            smi_ndp[UPD_RSP_TM_MSB:UPD_RSP_TM_LSB]             = smi_tm;
            smi_ndp[UPD_RSP_RMSGID_MSB:UPD_RSP_RMSGID_LSB]     = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[UPD_RSP_CMSTATUS_MSB:UPD_RSP_CMSTATUS_LSB] = smi_cmstatus;
	    ndp_prot_lsb = UPD_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = UPD_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.updRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgRbRsp) begin
            smi_ndp[RB_RSP_TM_MSB:RB_RSP_TM_LSB]             = smi_tm;
            smi_ndp[RB_RSP_RBID_MSB:RB_RSP_RBID_LSB]         = smi_rbid;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[RB_RSP_CMSTATUS_MSB:RB_RSP_CMSTATUS_LSB] = smi_cmstatus;
	    ndp_prot_lsb = RB_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = RB_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.rbrRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgRbUseRsp) begin
            smi_ndp[RBUSE_RSP_TM_MSB:RBUSE_RSP_TM_LSB]             = smi_tm;
            smi_ndp[RBUSE_RSP_RMSGID_MSB:RBUSE_RSP_RMSGID_LSB]     = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[RBUSE_RSP_CMSTATUS_MSB:RBUSE_RSP_CMSTATUS_LSB] = smi_cmstatus;
	    ndp_prot_lsb = RBUSE_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = RBUSE_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.rbuRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgCmpRsp) begin
            smi_ndp[CMP_RSP_RMSGID_MSB:CMP_RSP_RMSGID_LSB]     = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[CMP_RSP_CMSTATUS_MSB:CMP_RSP_CMSTATUS_LSB] = smi_cmstatus;
	    ndp_prot_lsb = CMP_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = CMP_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.cmpRspParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgCmeRsp) begin
            smi_ndp[CME_RSP_RMSGID_MSB:CME_RSP_RMSGID_LSB]     = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[CME_RSP_CMSTATUS_MSB:CME_RSP_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[CME_RSP_ECMDTYPE_MSB:CME_RSP_ECMDTYPE_LSB] = smi_ecmd_type;
	    ndp_prot_lsb = CME_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = CME_RSP_NDP_PROT_MSB;
        end
        if (smi_conc_msg_class == eConcMsgTreRsp) begin
            smi_ndp[TRE_RSP_RMSGID_MSB:TRE_RSP_RMSGID_LSB] = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[TRE_RSP_CMSTATUS_MSB:TRE_RSP_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[TRE_RSP_ECMDTYPE_MSB:TRE_RSP_ECMDTYPE_LSB] = smi_ecmd_type;
	    ndp_prot_lsb = TRE_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = TRE_RSP_NDP_PROT_MSB;
        end
        if (smi_conc_msg_class == eConcMsgSysReq) begin
            smi_ndp[SYS_REQ_RMSGID_MSB:SYS_REQ_RMSGID_LSB] = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[SYS_REQ_CMSTATUS_MSB:SYS_REQ_CMSTATUS_LSB] = smi_cmstatus;
            smi_ndp[SYS_REQ_OP_MSB:SYS_REQ_OP_LSB]             = smi_sysreq_op;
            smi_ndp[SYS_REQ_REQUESTORID_MSB:SYS_REQ_REQUESTORID_LSB]   = smi_requestor_id;
	    ndp_prot_lsb = SYS_REQ_NDP_PROT_LSB;
	    ndp_prot_msb = SYS_REQ_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.sysReqParams.wMProt%>;
        end
        if (smi_conc_msg_class == eConcMsgSysRsp) begin
            smi_ndp[SYS_RSP_RMSGID_MSB:SYS_RSP_RMSGID_LSB] = smi_rmsg_id;
            if (smi_cmstatus_err) begin
                smi_cmstatus[SMICMSTATUSERRBIT]            = smi_cmstatus_err;
                smi_cmstatus[WSMICMSTATUSERRPAYLOAD - 1:0] = smi_cmstatus_err_payload;
            end
            smi_ndp[SYS_RSP_CMSTATUS_MSB:SYS_RSP_CMSTATUS_LSB] = smi_cmstatus;
	    ndp_prot_lsb = SYS_RSP_NDP_PROT_LSB;
	    ndp_prot_msb = SYS_RSP_NDP_PROT_LSB + <%=obj.AiuInfo[0].concParams.sysRspParams.wMProt%>;
        end
        //construct Header, NDP, and DP protection
        if (! isRtl) begin
           `uvm_info($sformatf("%m"), $sformatf("NDP=%p", smi_ndp), UVM_DEBUG)
    //#Cover.DMI.Concerto.v3.0.MrdReqHProt
	<% if (obj.useResiliency) { %>
            <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
            smi_msg_user        = checkSECDED_N({smi_targ_id, smi_src_id, smi_msg_type, smi_msg_id}, WSMITGTID+WSMISRCID+WSMIMSGTYPE+WSMIMSGID, 0);   //protect header
            <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
            smi_msg_user        = checkPARITY_N({smi_targ_id, smi_src_id, smi_msg_type, smi_msg_id}, WSMITGTID+WSMISRCID+WSMIMSGTYPE+WSMIMSGID);   //protect header
            <% } %>
            smi_msg_hprot       = smi_msg_user; //protect header
            smi_ndp             = (smi_ndp & ((1 << ndp_prot_lsb)-1));  // remove possible protection bits
            smi_ndp_protection  = gen_smi_ndp_prot(smi_ndp, ndp_prot_lsb);
            smi_ndp            |= (smi_ndp_protection << ndp_prot_lsb);
            `uvm_info($sformatf("%m"), $sformatf("smi_dp_data beats=%0d, smi_dp_data beat size=%0d wSize=%0d smi_dp_protection size=%0d, HPROT=%0h HDR=%0h, NDP_PROT=%0h NDP=%p",
                                                 smi_dp_data.size(), $size(smi_dp_data[0]), wSmiDPdata, smi_dp_protection.size(),
                                                 smi_msg_user, {smi_targ_id, smi_src_id, smi_msg_type, smi_msg_id}, smi_ndp_protection, smi_ndp), UVM_MEDIUM)
       <% } %>
       end // if (! isRtl)

       for (int i=smi_ndp_len; i<WSMINDP; i++) begin
          smi_ndp[i] = 1'b0;
       end
    endfunction : pack_smi_seq_item 

    function bit check_ndp_field_mismatches(smi_seq_item rhs);
        bit legal = 1;
        if (smi_conc_msg_class == eConcMsgCmdReq) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("CMDreq.CMSTATUS field mismatched"); 
	            legal = 0;
            end 
            if (this.smi_addr !== rhs.smi_addr) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_addr mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_addr, rhs.smi_addr), UVM_NONE)   
                s = $sformatf("CMDreq.ADDR field mismatched"); 
	       legal = 0;
            end 
            if (this.smi_vz !== rhs.smi_vz) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_vz mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_vz, rhs.smi_vz), UVM_NONE)
                s = $sformatf("CMDreq.VZ field mismatched"); 
	       legal = 0;
            end 
            if (this.smi_ca !== rhs.smi_ca) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ca mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ca, rhs.smi_ca), UVM_NONE) 
                s = $sformatf("CMDreq.CA field mismatched"); 
	       legal = 0;
            end 
            if (this.smi_ac !== rhs.smi_ac) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ac mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ac, rhs.smi_ac), UVM_NONE) 
                s = $sformatf("CMDreq.AC field mismatched"); 
	       legal = 0;
            end 
            if (this.smi_ch !== rhs.smi_ch) begin
                `uvm_info("NDP field mismatch: 20191122 CCMP Don't Care", $sformatf("smi_ch mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ch, rhs.smi_ch), UVM_LOW)
	       // Should not assign 1 as previous comparisons will not be considered //legal = 1;
            end 
            if (this.smi_st !== rhs.smi_st) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_st mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_st, rhs.smi_st), UVM_NONE) 
                s = $sformatf("CMDreq.ST field mismatched"); 
	       legal = 0;
            end 
            if (this.smi_en !== rhs.smi_en) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_en mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_en, rhs.smi_en), UVM_NONE)
                s = $sformatf("CMDreq.EN field mismatched"); 
	       legal = 0;
            end 
            if (this.smi_es !== rhs.smi_es) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_es mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_es, rhs.smi_es), UVM_NONE) 
                s = $sformatf("CMDreq.ES field mismatched"); 
	       legal = 0;
            end 
            if (this.smi_ns !== rhs.smi_ns) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ns mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ns, rhs.smi_ns), UVM_NONE)
                s = $sformatf("CMDreq.NS field mismatched"); 
	       legal = 0;
            end 
            if (this.smi_pr !== rhs.smi_pr) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_pr mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_pr, rhs.smi_pr), UVM_NONE)
                s = $sformatf("CMDreq.PR field mismatched"); 
	       legal = 0;
            end 
            if (this.smi_order !== rhs.smi_order) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_order mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_order, rhs.smi_order), UVM_NONE)
               s = $sformatf("CMDreq.ORDER field mismatched"); 
	       legal = 0;
            end 
            if (this.smi_lk !== rhs.smi_lk) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_lk mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_lk, rhs.smi_lk), UVM_NONE)
               s = $sformatf("CMDreq.LK field mismatched"); 
	       legal = 0;
            end 
            if (this.smi_rl !== rhs.smi_rl) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rl mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rl, rhs.smi_rl), UVM_NONE)
               s = $sformatf("CMDreq.RL field mismatched"); 
	       legal = 0;
            end
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("CMDreq.TM field mismatched");
	       legal = 0;
            end
            // not supported for NCore 3.1 
            //if (this.smi_tm !== rhs.smi_tm) begin
            //    `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)   
	    //   legal = 0;
            //end 
            if (smi_msg_type == CMD_WR_STSH_FULL || smi_msg_type == CMD_WR_STSH_PTL
                || smi_msg_type == CMD_LD_CCH_SH || smi_msg_type == CMD_LD_CCH_UNQ) begin
                if (this.smi_mpf1_stash_valid !== rhs.smi_mpf1_stash_valid) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_stash_valid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_stash_valid, rhs.smi_mpf1_stash_valid), UVM_NONE)
                    s = $sformatf("CMDreq.STASH_VALID field mismatched");
		    legal = 0;
                end 
                if (this.smi_mpf1_stash_nid !== rhs.smi_mpf1_stash_nid) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_stash_nid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_stash_nid, rhs.smi_mpf1_stash_nid), UVM_NONE)
                    s = $sformatf("CMDreq.STASH_NID field mismatched");
		    legal = 0;
		   		end
            end
            if (smi_msg_type == CMD_WR_ATM || smi_msg_type == CMD_RD_ATM ||
                smi_msg_type == CMD_CMP_ATM || smi_msg_type == CMD_SW_ATM) begin
                if (this.smi_mpf1_argv !== rhs.smi_mpf1_argv) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_argv mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_argv, rhs.smi_mpf1_argv), UVM_NONE)
                    s = $sformatf("CMDreq.MPF1_ARGV field mismatched");
		   legal = 0;
                end 
            end
            if (smi_msg_type == CMD_RD_NC || 
                smi_msg_type == CMD_WR_NC_PTL ||
                smi_msg_type == CMD_WR_NC_FULL
            ) begin
                if (this.smi_mpf1_burst_type !== rhs.smi_mpf1_burst_type) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_burst_type mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_burst_type, rhs.smi_mpf1_burst_type), UVM_NONE)
                   s = $sformatf("CMDreq.MPF1_BURST_TYPE field mismatched");
		   legal = 0;
                end 
                if (this.smi_mpf1_asize !== rhs.smi_mpf1_asize) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_asize mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_asize, rhs.smi_mpf1_asize), UVM_NONE)  
                   s = $sformatf("CMDreq.MPF1_ASIZE field mismatched");
		   legal = 0;
                end 
                if (this.smi_mpf1_alength !== rhs.smi_mpf1_alength) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_alength mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_alength, rhs.smi_mpf1_alength), UVM_NONE)
                    s = $sformatf("CMDreq.MPF1_ALENGTH field mismatched");
		   legal = 0;
                end 
            end 
            if (smi_msg_type == CMD_WR_UNQ_FULL || smi_msg_type == CMD_WR_UNQ_PTL) begin
                if (this.smi_mpf1_awunique !== rhs.smi_mpf1_awunique) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_awunique mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_awunique, rhs.smi_mpf1_awunique), UVM_NONE)
                    s = $sformatf("CMDreq.MPF1_AWUNIQUE field mismatched");
		   legal = 0;
                end
            end
            if (smi_msg_type == CMD_WR_STSH_FULL || smi_msg_type == CMD_WR_STSH_PTL
                || smi_msg_type == CMD_LD_CCH_SH || smi_msg_type == CMD_LD_CCH_UNQ) begin
                if (this.smi_mpf2_stash_valid !== rhs.smi_mpf2_stash_valid) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf2_stash_valid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf2_stash_valid, rhs.smi_mpf2_stash_valid), UVM_NONE)
                   s = $sformatf("CMDreq.MPF2_AVALID field mismatched");
		   legal = 0;
                end 
                if (this.smi_mpf2_stash_lpid !== rhs.smi_mpf2_stash_lpid) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf2_stash_lpid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf2_stash_lpid, rhs.smi_mpf2_stash_lpid), UVM_NONE)
                    s = $sformatf("CMDreq.MPF2_STASH_LPID field mismatched");
		   legal = 0;
                end 
            end
            else begin
                if (this.smi_mpf2_flowid_valid !== rhs.smi_mpf2_flowid_valid) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf2_flowid_valid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf2_flowid_valid, rhs.smi_mpf2_flowid_valid), UVM_NONE)
                   s = $sformatf("CMDreq.MPF2_FLOWID_VALID field mismatched");
		   legal = 0;
                end 
                if (rhs.smi_mpf2_flowid_valid && (this.smi_mpf2_flowid !== rhs.smi_mpf2_flowid)) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf2_flowid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf2_flowid, rhs.smi_mpf2_flowid), UVM_NONE)
                   s = $sformatf("CMDreq.MPF2_FLOWID_VALID field mismatched");
		   legal = 0;
                end 
            end
            if (this.smi_size !== rhs.smi_size) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_size mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_size, rhs.smi_size), UVM_NONE)  
                s = $sformatf("CMDreq.SIZE field mismatched");
	       legal = 0;
            end 
            if (this.smi_intfsize !== rhs.smi_intfsize) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_intfsize mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_intfsize, rhs.smi_intfsize), UVM_NONE)
                s = $sformatf("CMDreq.INTFSIZE field mismatched");
	       legal = 0;
            end 
            if (this.smi_dest_id !== rhs.smi_dest_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_dest_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_dest_id, rhs.smi_dest_id), UVM_NONE)   
                s = $sformatf("CMDreq.DEST_ID field mismatched");
	       legal = 0;
            end 
            if (this.smi_tof !== rhs.smi_tof) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tof mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tof, rhs.smi_tof), UVM_NONE)   
                s = $sformatf("CMDreq.TOF field mismatched");
	       legal = 0;
            end 
	    if ((WSMIQOS_EN == 1'b1) && (! $test$plusargs("disable_qos_check"))) begin
	       if (this.smi_qos !== rhs.smi_qos) begin
		  `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_qos: 0x%0x Actual: smi_qos: 0x%0x", this.smi_qos, rhs.smi_qos), UVM_NONE);
                  s = $sformatf("CMDreq.QOS field mismatched");
		  legal = 0;
	       end
	    end
        end // if (smi_conc_msg_class == eConcMsgCmdReq)
        if (smi_conc_msg_class == eConcMsgSnpReq) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("SNPreq.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_addr !== rhs.smi_addr) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_addr mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_addr, rhs.smi_addr), UVM_NONE)   
                s = $sformatf("SNPreq.ADDR field mismatched");
	       legal = 0;
            end 
            if (this.smi_vz !== rhs.smi_vz) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_vz mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_vz, rhs.smi_vz), UVM_NONE) 
                s = $sformatf("SNPreq.VZ field mismatched");
	       legal = 0;
            end 
            if (this.smi_ca !== rhs.smi_ca) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ca mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ca, rhs.smi_ca), UVM_NONE)
                s = $sformatf("SNPreq.CA field mismatched");
	       legal = 0;
            end 
            if (this.smi_ac !== rhs.smi_ac) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ac mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ac, rhs.smi_ac), UVM_NONE)
                s = $sformatf("SNPreq.AC field mismatched");
	       legal = 0;
            end 
            if (this.smi_ns !== rhs.smi_ns) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ns mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ns, rhs.smi_ns), UVM_NONE)
                s = $sformatf("SNPreq.NS field mismatched");
	       legal = 0;
            end 
            if (this.smi_pr !== rhs.smi_pr) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_pr mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_pr, rhs.smi_pr), UVM_NONE)
                s = $sformatf("SNPreq.PR field mismatched");
	       legal = 0;
            end 
            if (this.smi_up !== rhs.smi_up) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_up mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_up, rhs.smi_up), UVM_NONE)
                s = $sformatf("SNPreq.UP field mismatched");
	       legal = 0;
            end 
            if (this.smi_rl !== rhs.smi_rl) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rl mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rl, rhs.smi_rl), UVM_NONE)
                s = $sformatf("SNPreq.RL field mismatched");
	       legal = 0;
            end 
            if (this.smi_tof !== rhs.smi_tof) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tof mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tof, rhs.smi_tof), UVM_NONE)   
                s = $sformatf("SNPreq.TOF field mismatched");
	        legal = 0;
            end 
	    // not supported for NCore 3.1
            //if (this.smi_tm !== rhs.smi_tm) begin
            //    `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)   
	    //   legal = 0;
            //end 
            if (smi_msg_type == SNP_INV_STSH || 
                smi_msg_type == SNP_UNQ_STSH ||
                smi_msg_type == SNP_STSH_SH ||
                smi_msg_type == SNP_STSH_UNQ
            ) begin
                if (this.smi_mpf1_stash_valid !== rhs.smi_mpf1_stash_valid) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_stash_valid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_stash_valid, rhs.smi_mpf1_stash_valid), UVM_NONE)
                    s = $sformatf("SNPreq.MPF1_STASH_VALID field mismatched");
		   legal = 0;
                end 
                if (this.smi_mpf1_stash_nid !== rhs.smi_mpf1_stash_nid) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_stash_nid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_stash_nid, rhs.smi_mpf1_stash_nid), UVM_NONE)  
                    s = $sformatf("SNPreq.MPF1_STASH_NID field mismatched");
		   legal = 0;
                end 
                if (this.smi_mpf2_stash_lpid !== rhs.smi_mpf2_stash_lpid) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf2_stash_lpid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf2_stash_lpid, rhs.smi_mpf2_stash_lpid), UVM_NONE)
                    s = $sformatf("SNPreq.MPF2_STASH_LPID field mismatched");
		   legal = 0;
                end 

            end else if (smi_msg_type == SNP_NOSDINT ||
		smi_msg_type == SNP_CLN_DTR ||
		smi_msg_type == SNP_VLD_DTR ||
		smi_msg_type == SNP_INV_DTR ||
		smi_msg_type == SNP_NITC    ||
		smi_msg_type == SNP_NITCCI  ||
		smi_msg_type == SNP_NITCMI ) begin
                if (this.smi_mpf1_dtr_tgt_id !== rhs.smi_mpf1_dtr_tgt_id) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_dtr_tgt_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_dtr_tgt_id, rhs.smi_mpf1_dtr_tgt_id), UVM_NONE) 
                    s = $sformatf("SNPreq.MPF1_DTR_TGT_ID field mismatched");
		   legal = 0;
                end 
                if (this.smi_mpf2_dtr_msg_id !== rhs.smi_mpf2_dtr_msg_id) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf2_dtr_msg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf2_dtr_msg_id, rhs.smi_mpf2_dtr_msg_id), UVM_NONE)
                    s = $sformatf("SNPreq.MPF2_DTR_MSG_ID field mismatched");
		   legal = 0;
                end 
            end else if (smi_msg_type == SNP_DVM_MSG) begin
  	            if (this.smi_mpf1_vmid_ext != rhs.smi_mpf1_vmid_ext) begin
	               `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_vmid_ext mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_vmid_ext, rhs.smi_mpf1_vmid_ext), UVM_NONE)   
                       s = $sformatf("SNPreq.MPF1_VMID_EXT field mismatched");
                   legal = 0;
		        end
	            if (this.smi_mpf2_dvmop_id != rhs.smi_mpf2_dvmop_id) begin
		           `uvm_info("NDP field mismatch", $sformatf("smi_mpf2_dvmop_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf2_dvmop_id, rhs.smi_mpf2_dvmop_id), UVM_NONE)  
                           s = $sformatf("SNPreq.MPF2_DVMOP_ID field mismatched");
		            legal = 0;
		        end
                if (this.smi_mpf3_dvmop_portion != rhs.smi_mpf3_dvmop_portion) begin
                  `uvm_info("NDP field mismatch", $sformatf("smi_mpf3_dvmop_portion mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf3_dvmop_portion, rhs.smi_mpf3_dvmop_portion), UVM_NONE)
                  s = $sformatf("SNPreq.PF3_DVMOP_PORTION field mismatched");
		            legal = 0;
                end
                if (this.smi_mpf3_range != rhs.smi_mpf3_range) begin
                  `uvm_info("NDP field mismatch", $sformatf("smi_mpf3_range mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf3_range, rhs.smi_mpf3_range), UVM_NONE)
                  s = $sformatf("SNPreq.MPF3_RANGE field mismatched");
		            legal = 0;
                end
                if (this.smi_mpf3_num != rhs.smi_mpf3_num) begin
                  `uvm_info("NDP field mismatch", $sformatf("smi_mpf3_num mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf3_num, rhs.smi_mpf3_num), UVM_NONE)
                  s = $sformatf("SNPreq.MPF3_NUM field mismatched");
		            legal = 0;
                end
            end

            if (smi_up != SMI_UP_NONE) begin
                if (this.smi_mpf3_intervention_unit_id !== rhs.smi_mpf3_intervention_unit_id) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf3_intervention_unit_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf3_intervention_unit_id, rhs.smi_mpf3_intervention_unit_id), UVM_NONE)
                    s = $sformatf("SNPreq.MPF3_INTERVATION_UNIT_ID field mismatched");
		   legal = 0;
                end
            end
            if (this.smi_intfsize !== rhs.smi_intfsize) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_intfsize mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_intfsize, rhs.smi_intfsize), UVM_NONE)  
                s = $sformatf("SNPreq.INTFSIZE field mismatched");
	       legal = 0;
            end 
            if (this.smi_dest_id !== rhs.smi_dest_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_dest_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_dest_id, rhs.smi_dest_id), UVM_NONE) 
                s = $sformatf("SNPreq.DEST_ID field mismatched");
	       legal = 0;
            end 
            if (this.smi_rbid !== rhs.smi_rbid) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rbid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rbid, rhs.smi_rbid), UVM_NONE)
                s = $sformatf("SNPreq.RBID field mismatched");
	       legal = 0;
            end 
	    if ((WSMIQOS_EN == 1'b1) && (! $test$plusargs("disable_qos_check"))) begin
	       if (this.smi_qos !== rhs.smi_qos) begin
		  `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_qos: 0x%0x Actual: smi_qos: 0x%0x", this.smi_qos, rhs.smi_qos), UVM_NONE);
                  s = $sformatf("SNPreq.QOS field mismatched");
		  legal = 0;
	       end
	    end
        end // if (smi_conc_msg_class == eConcMsgSnpReq)
        if (smi_conc_msg_class == eConcMsgHntReq) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)
                s = $sformatf("HNTreq.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_addr !== rhs.smi_addr) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_addr mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_addr, rhs.smi_addr), UVM_NONE)   
                s = $sformatf("HNTreq.ADDR field mismatched");
	       legal = 0;
            end 
            if (this.smi_ac !== rhs.smi_ac) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ac mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ac, rhs.smi_ac), UVM_NONE)   
                s = $sformatf("HNTreq.AC field mismatched");
	       legal = 0;
            end 
            if (this.smi_ns !== rhs.smi_ns) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ns mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ns, rhs.smi_ns), UVM_NONE)   
                s = $sformatf("HNTreq.NS field mismatched");
	       legal = 0;
            end 
	    if ((WSMIQOS_EN == 1'b1) && (! $test$plusargs("disable_qos_check"))) begin
	       if (this.smi_qos !== rhs.smi_qos) begin
		  `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_qos: 0x%0x Actual: smi_qos: 0x%0x", this.smi_qos, rhs.smi_qos), UVM_NONE);
		  s = $sformatf("HNTreq.QOS field mismatched");
                  legal = 0;
	       end
	    end
        end // if (smi_conc_msg_class == eConcMsgHntReq)
        if (smi_conc_msg_class == eConcMsgMrdReq) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("MRDreq.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_addr !== rhs.smi_addr) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_addr mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_addr, rhs.smi_addr), UVM_NONE)   
                s = $sformatf("MRDreq.ADDR field mismatched");
	       legal = 0;
            end 
            if (this.smi_ac !== rhs.smi_ac) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ac mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ac, rhs.smi_ac), UVM_NONE)
                s = $sformatf("MRDreq.AC field mismatched");
	       legal = 0;
            end 
            if (this.smi_ns !== rhs.smi_ns) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ns mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ns, rhs.smi_ns), UVM_NONE) 
                s = $sformatf("MRDreq.NS field mismatched");
	       legal = 0;
            end 
            if (this.smi_pr !== rhs.smi_pr) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_pr mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_pr, rhs.smi_pr), UVM_NONE)
                s = $sformatf("MRDreq.PR field mismatched");
	       legal = 0;
            end 
            if (this.smi_rl !== rhs.smi_rl) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rl mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rl, rhs.smi_rl), UVM_NONE)
                 s = $sformatf("MRDreq.RL field mismatched");
	       legal = 0;
            end
	    // not supported for NCore 3.1
            //if (this.smi_tm !== rhs.smi_tm) begin
            //    `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)   
	    //   legal = 0;
            //end 
	   if (smi_msg_type != MRD_PREF) begin 
	      if (this.smi_mpf1_dtr_tgt_id !== rhs.smi_mpf1_dtr_tgt_id) begin
		 	`uvm_info("NDP field mismatch", $sformatf("smi_mpf1_dtr_tgt_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_dtr_tgt_id, rhs.smi_mpf1_dtr_tgt_id), UVM_NONE) 
                        s = $sformatf("MRDreq.MPF1_DTR_TGT_ID field mismatched");
		 	legal = 0;
	      end 
	      if (this.smi_mpf2_dtr_msg_id !== rhs.smi_mpf2_dtr_msg_id) begin
		 	`uvm_info("NDP field mismatch", $sformatf("smi_mpf2_dtr_msg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf2_dtr_msg_id, rhs.smi_mpf2_dtr_msg_id), UVM_NONE)   
                        s = $sformatf("MRDreq.MPF2_DTR_MSG_ID field mismatched");
		 	legal = 0;
	      end 
       end
            if (this.smi_size !== rhs.smi_size) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_size mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_size, rhs.smi_size), UVM_NONE)   
                s = $sformatf("MRDreq.SIZE field mismatched");
             legal = 0;
            end 
            if (this.smi_intfsize !== rhs.smi_intfsize) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_intfsize mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_intfsize, rhs.smi_intfsize), UVM_NONE)   
                s = $sformatf("MRDreq.INTFSIZE field mismatched");
	       legal = 0;
            end 
	    if ((WSMIQOS_EN == 1'b1) && (! $test$plusargs("disable_qos_check"))) begin
	       if (this.smi_qos !== rhs.smi_qos) begin
		  `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_qos: 0x%0x Actual: smi_qos: 0x%0x", this.smi_qos, rhs.smi_qos), UVM_NONE)
                  s = $sformatf("MRDreq.QOS field mismatched");
		  legal = 0;
	       end
	    end
        end // if (smi_conc_msg_class == eConcMsgMrdReq)
        if (smi_conc_msg_class == eConcMsgStrReq) begin
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE) 
                s = $sformatf("STRreq.TM field mismatched");
	       	legal = 0;
            end 
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("STRreq.CMSTATUS field mismatched");
	       	legal = 0;
            end 
            if (smi_cmstatus[SMICMSTATUSERRBIT]) begin
                if (this.smi_cmstatus_err_payload !== rhs.smi_cmstatus_err_payload) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus_err_payload mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus_err_payload, rhs.smi_cmstatus_err_payload), UVM_NONE)
                    s = $sformatf("STRreq.CMSTATUS_ERR_PAYLOAD field mismatched");
		   legal = 0;
                end 
            end
            else begin
                if (this.smi_cmstatus_state !== rhs.smi_cmstatus_state) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus_state mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus_state, rhs.smi_cmstatus_state), UVM_NONE)
                    s = $sformatf("STRreq.CMSTATUS_STATE field mismatched");
		    legal = 0;
                end 
                if (this.smi_cmstatus_snarf !== rhs.smi_cmstatus_snarf) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus_snarf mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus_snarf, rhs.smi_cmstatus_snarf), UVM_NONE)  
                    s = $sformatf("STRreq.CMSTATUS_SNARF field mismatched");
		   legal = 0;
                end 
                if (this.smi_cmstatus_exok !== rhs.smi_cmstatus_exok) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus_exok mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus_exok, rhs.smi_cmstatus_exok), UVM_NONE)  
                    s = $sformatf("STRreq.CMSTATUS_EXOK field mismatched");
		   legal = 0;
                end 
            end
            if (this.smi_rbid !== rhs.smi_rbid) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rbid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rbid, rhs.smi_rbid), UVM_NONE)   
                s = $sformatf("STRreq.RBID field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)  
                s = $sformatf("STRreq.RMSG_ID field mismatched");
	       legal = 0;
            end 
            if (smi_cmstatus_snarf) begin
                if (this.smi_mpf1_stash_nid !== rhs.smi_mpf1_stash_nid) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_stash_nid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_stash_nid, rhs.smi_mpf1_stash_nid), UVM_NONE) 
                    s = $sformatf("STRreq.MPF1_STASH_NID field mismatched");
		   			legal = 0;
                end 
                if (this.smi_mpf2_dtr_msg_id !== rhs.smi_mpf2_dtr_msg_id) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_mpf2_dtr_msg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf2_dtr_msg_id, rhs.smi_mpf2_dtr_msg_id), UVM_NONE) 
                    s = $sformatf("STRreq.MPF2_DTR_MSG_ID field mismatched");
		   legal = 0;
                end 
			end 
			if (this.smi_intfsize !== rhs.smi_intfsize) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_intfsize mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_intfsize, rhs.smi_intfsize), UVM_NONE)   
                s = $sformatf("STRreq.INTFSIZE field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgDtrReq) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("DTRreq.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rl !== rhs.smi_rl) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rl mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rl, rhs.smi_rl), UVM_NONE) 
                s = $sformatf("DTRreq.RL field mismatched");
	       legal = 0;
            end 
	    // not supported for NCore 3.1
            //if (this.smi_tm !== rhs.smi_tm) begin
            //    `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)   
	    //   legal = 0;
            //end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("DTRreq.RMSG_ID field mismatched");
	       legal = 0;
            end 
            if (this.smi_mpf1_dtr_long_dtw !== rhs.smi_mpf1_dtr_long_dtw) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_dtr_long_dtw mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_dtr_long_dtw, rhs.smi_mpf1_dtr_long_dtw), UVM_NONE) 
                s = $sformatf("DTRreq.MPF1_DTR_LONG_DTW field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgDtwReq) begin
            if (this.smi_rbid !== rhs.smi_rbid) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rbid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rbid, rhs.smi_rbid), UVM_NONE)   
                s = $sformatf("DTWreq.RBID field mismatched");
	       legal = 0;
            end 
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("DTWreq.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rl !== rhs.smi_rl) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rl mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rl, rhs.smi_rl), UVM_NONE) 
                s = $sformatf("DTWreq.RL field mismatched");
	       legal = 0;
            end 
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("DTWreq.TM field mismatched");
	       legal = 0;
            end 
            if (this.smi_prim !== rhs.smi_prim) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_prim mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_prim, rhs.smi_prim), UVM_NONE)   
                s = $sformatf("DTWreq.PRIM field mismatched");
	       legal = 0;
            end 
            if (smi_msg_type == DTW_MRG_MRD_INV ||
                smi_msg_type == DTW_MRG_MRD_SCLN ||
                smi_msg_type == DTW_MRG_MRD_UCLN ||
                smi_msg_type == DTW_MRG_MRD_UDTY
            ) begin
                if (this.smi_mpf1_stash_nid !== rhs.smi_mpf1_stash_nid) begin
                   `uvm_info("NDP field mismatch", $sformatf("smi_mpf1_stash_nid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1_stash_nid, rhs.smi_mpf1_stash_nid), UVM_NONE)  
                   s = $sformatf("DTWreq.MPF1_STATSH_NID field mismatched");
		   legal = 0;
                end 
            end
            if (this.smi_mpf2 != rhs.smi_mpf2) begin
               `uvm_info("NDP field mismatch", $sformatf("smi_mpf2 mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf2, rhs.smi_mpf2), UVM_NONE)
               s = $sformatf("DTWreq.MPF2 field mismatched");
	       legal = 0;
	    end
	    if (this.smi_intfsize != rhs.smi_intfsize) begin
	       `uvm_info("NDP field mismatch", $sformatf("smi_intfsize mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_intfsize, rhs.smi_intfsize), UVM_NONE)
               s = $sformatf("DTWreq.INTFSIZE field mismatched");
	    end
        end // if (smi_conc_msg_class == eConcMsgDtwReq)
        if (smi_conc_msg_class == eConcMsgDtwDbgReq) begin
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("DTWDBGreq.TM field mismatched");
	       legal = 0;
            end 
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("DTWDBGreq.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rl !== rhs.smi_rl) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rl mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rl, rhs.smi_rl), UVM_NONE)
                s = $sformatf("DTWDBGreq.RL field mismatched");
	       legal = 0;
            end 
        end // if (smi_conc_msg_class == eConcMsgDtwReq)
        if (smi_conc_msg_class == eConcMsgUpdReq) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("UPDreq.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_addr !== rhs.smi_addr) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_addr mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_addr, rhs.smi_addr), UVM_NONE)   
                s = $sformatf("UPDreq.ADDR field mismatched");
	       legal = 0;
            end 
            if (this.smi_ns !== rhs.smi_ns) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ns mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ns, rhs.smi_ns), UVM_NONE)
                s = $sformatf("UPDreq.NS field mismatched");
	       legal = 0;
            end 
	    if ((WSMIQOS_EN == 1'b1) && (! $test$plusargs("disable_qos_check"))) begin
	       if (this.smi_qos !== rhs.smi_qos) begin
		  `uvm_info(get_full_name(), $sformatf("ERROR Expected: smi_qos: 0x%0x Actual: smi_qos: 0x%0x", this.smi_qos, rhs.smi_qos), UVM_NONE);
                  s = $sformatf("UPDreq.QOS field mismatched");
		  legal = 0;
	       end
	    end
        end // if (smi_conc_msg_class == eConcMsgUpdReq)
        if (smi_conc_msg_class == eConcMsgRbReq) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("RBreq.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("RBreq.TM field mismatched");
	       legal = 0;
            end 
            if (this.smi_rbid !== rhs.smi_rbid) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rbid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rbid, rhs.smi_rbid), UVM_NONE)   
                s = $sformatf("RBreq.RBID field mismatched");
	       legal = 0;
            end 
            if (this.smi_rtype !== rhs.smi_rtype) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rtype mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rtype, rhs.smi_rtype), UVM_NONE)   
                s = $sformatf("RBreq.RTYPE field mismatched");
	       legal = 0;
            end 
            if (this.smi_addr !== rhs.smi_addr) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_addr mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_addr, rhs.smi_addr), UVM_NONE)   
                s = $sformatf("RBreq.ADDR field mismatched");
	       legal = 0;
            end 
            if (this.smi_size !== rhs.smi_size) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_size mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_size, rhs.smi_size), UVM_NONE)   
                s = $sformatf("RBreq.SIZE field mismatched");
	       legal = 0;
            end 
            if (this.smi_vz !== rhs.smi_vz) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_vz mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_vz, rhs.smi_vz), UVM_NONE)
                s = $sformatf("RBreq.VZ field mismatched");
	       legal = 0;
            end 
            if (this.smi_ca !== rhs.smi_ca) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ca mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ca, rhs.smi_ca), UVM_NONE)
                s = $sformatf("RBreq.CA field mismatched");
	       legal = 0;
            end 
            if (this.smi_ac !== rhs.smi_ac) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ac mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ac, rhs.smi_ac), UVM_NONE)
                s = $sformatf("RBreq.AC field mismatched");
	       legal = 0;
            end 
            if (this.smi_ns !== rhs.smi_ns) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ns mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ns, rhs.smi_ns), UVM_NONE)
                s = $sformatf("RBreq.NS field mismatched");
	       legal = 0;
            end 
            if (this.smi_pr !== rhs.smi_pr) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_pr mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_pr, rhs.smi_pr), UVM_NONE)
                s = $sformatf("RBreq.PR field mismatched");
	       legal = 0;
            end 
            if (this.smi_mw !== rhs.smi_mw) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_mw mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mw, rhs.smi_mw), UVM_NONE)
                s = $sformatf("RBreq.MW field mismatched");
	       legal = 0;
            end 
            if (this.smi_rl !== rhs.smi_rl) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rl mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rl, rhs.smi_rl), UVM_NONE)
                s = $sformatf("RBreq.RL field mismatched");
	       legal = 0;
            end 
            if (this.smi_mpf1 !== rhs.smi_mpf1) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_mpf1 mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf1, rhs.smi_mpf1), UVM_NONE)   
                s = $sformatf("RBreq.MPF1 field mismatched");
	       legal = 0;
            end 
            if (this.smi_tof !== rhs.smi_tof) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tof mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tof, rhs.smi_tof), UVM_NONE)   
                s = $sformatf("RBreq.TOF field mismatched");
	       legal = 0;
            end 
	    if ((WSMIQOS_EN == 1'b1) && (! $test$plusargs("disable_qos_check"))) begin
               if (this.smi_qos !== rhs.smi_qos) begin
                  `uvm_info("NDP field mismatch", $sformatf("smi_qos mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_qos, rhs.smi_qos), UVM_NONE)   
                  s = $sformatf("RBreq.QOS field mismatched");
	          legal = 0;
               end
            end 
        end // if (smi_conc_msg_class == eConcMsgRbReq)
        if (smi_conc_msg_class == eConcMsgRbUseReq) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("RBUSEreq.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rbid !== rhs.smi_rbid) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rbid mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rbid, rhs.smi_rbid), UVM_NONE)   
                s = $sformatf("RBUSEreq.RBID field mismatched");
	       legal = 0;
            end 
            if (this.smi_rl !== rhs.smi_rl) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rl mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rl, rhs.smi_rl), UVM_NONE)
                s = $sformatf("RBUSEreq.RL field mismatched");
	       		legal = 0;
            end 
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("RBUSEreq.TM field mismatched");
	       		legal = 0;
            end 
        end // if (smi_conc_msg_class == eConcMsgRbUseReq)
        if (smi_conc_msg_class == eConcMsgCCmdRsp) begin
        	//#Check.DCE.CMDRsp.Cmstatus
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("CCMDrsp.TM field mismatched");
	       legal = 0;
            end 
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("CCMDrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("CCMDrsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgSysReq) begin
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("SYSreq.TM field mismatched");
	       legal = 0;
            end
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)
                s = $sformatf("SYSreq.CMSTATUS field mismatched");
	       legal = 0;
            end
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)
                s = $sformatf("SYSreq.RMSG_ID field mismatched");
	       legal = 0;
            end
            if (this.smi_sysreq_op !== rhs.smi_sysreq_op) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_sysreq_op mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_sysreq_op, rhs.smi_sysreq_op), UVM_NONE)
                s = $sformatf("SYSreq.SYSREQ_OP field mismatched");
	       legal = 0;
            end 
            if (this.smi_requestor_id !== rhs.smi_requestor_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_requestor_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_requestor_id, rhs.smi_requestor_id), UVM_NONE)
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgNcCmdRsp) begin
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("NCCMDrsp.TM field mismatched");
	       legal = 0;
            end 
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("NCCMDrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("NCCMDrsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgSnpRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)
                s = $sformatf("SNPrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (smi_cmstatus[SMICMSTATUSERRBIT]) begin
                if (this.smi_cmstatus_err_payload !== rhs.smi_cmstatus_err_payload) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus_err_payload mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus_err_payload, rhs.smi_cmstatus_err_payload), UVM_NONE)  
                    s = $sformatf("SNPrsp.CMSTATUS_ERR_PAYLOAD field mismatched");
		   legal = 0;
                end 
            end else begin
                if (this.smi_cmstatus_rv !== rhs.smi_cmstatus_rv) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus_rv mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus_rv, rhs.smi_cmstatus_rv), UVM_NONE)   
                    s = $sformatf("SNPrsp.CMSTATUS_RV field mismatched");
		   legal = 0;
                end 
                if (this.smi_cmstatus_rs !== rhs.smi_cmstatus_rs) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus_rs mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus_rs, rhs.smi_cmstatus_rs), UVM_NONE) 
                    s = $sformatf("SNPrsp.CMSTATUS_RS field mismatched");
		   legal = 0;
                end 
                if (this.smi_cmstatus_dc !== rhs.smi_cmstatus_dc) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus_dc mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus_dc, rhs.smi_cmstatus_dc), UVM_NONE)   
                    s = $sformatf("SNPrsp.CMSTATUS_DC field mismatched");
		   legal = 0;
                end 
                if (this.smi_cmstatus_dt_aiu !== rhs.smi_cmstatus_dt_aiu) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus_dt_aiu mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus_dt_aiu, rhs.smi_cmstatus_dt_aiu), UVM_NONE)  
                    s = $sformatf("SNPrsp.CMSTATUS_DT_AIU field mismatched");
		   legal = 0;
                end 
                if (this.smi_cmstatus_dt_dmi !== rhs.smi_cmstatus_dt_dmi) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus_dt_dmi mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus_dt_dmi, rhs.smi_cmstatus_dt_dmi), UVM_NONE)  
                    s = $sformatf("SNPrsp.CMSTATUS_DT_DMI field mismatched");
		   legal = 0;
                end 
                if (this.smi_cmstatus_snarf !== rhs.smi_cmstatus_snarf) begin
                    `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus_snarf mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus_snarf, rhs.smi_cmstatus_snarf), UVM_NONE) 
                    s = $sformatf("SNPrsp.CMSTATUS_SNARF field mismatched");
		   legal = 0;
                end 
            end
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("SNPrsp.TM field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("SNPrsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
            if (this.smi_mpf2_dtr_msg_id !== rhs.smi_mpf2_dtr_msg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_mpf2_dtr_msg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_mpf2_dtr_msg_id, rhs.smi_mpf2_dtr_msg_id), UVM_NONE) 
                s = $sformatf("SNPrsp.MPF2_DTR_MSG_ID field mismatched");
	       legal = 0;
            end 
            if (this.smi_intfsize !== rhs.smi_intfsize) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_intfsize mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_intfsize, rhs.smi_intfsize), UVM_NONE)   
                s = $sformatf("SNPrsp.INTFSIZE field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgDtwRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("DTWrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rl !== rhs.smi_rl) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rl mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rl, rhs.smi_rl), UVM_NONE)
                s = $sformatf("DTWrsp.RL field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("DTWrsp.RSMG_ID field mismatched");
	       legal = 0;
            end 
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("DTWrsp.TM field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgDtwDbgRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("DTWDBGrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rl !== rhs.smi_rl) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rl mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rl, rhs.smi_rl), UVM_NONE)
                s = $sformatf("DTWDBGrsp.RL field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("DTWDBGrsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgDtrRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("DTRrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("DTRrsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("DTRrsp.TM field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgHntRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("HNTrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("HNTrsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgMrdRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)  
                s = $sformatf("MRDrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("MRDrsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("MRDrsp.TM field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgStrRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("STRrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("STRrsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("STRrsp.TM field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgUpdRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)  
                s = $sformatf("UPDrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("STRrsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("STRrsp.TM field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgRbRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("RBrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("RBrsp.TM field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("RBrsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgRbUseRsp) begin
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("RBUSErsp.TM field mismatched");
	       legal = 0;
            end 
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)
                s = $sformatf("RBUSErsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("RBUSErsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgCmpRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("CMPrsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("CMPrsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgCmeRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)   
                s = $sformatf("CMErsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_ecmd_type !== rhs.smi_ecmd_type) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ecmd_type mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ecmd_type, rhs.smi_ecmd_type), UVM_NONE)   
                s = $sformatf("CMErsp.ECMD_TYPE field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("CMErsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
        end
        if (smi_conc_msg_class == eConcMsgTreRsp) begin
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE) 
                s = $sformatf("TRErsp.CMSTATUS field mismatched");
	       legal = 0;
            end 
            if (this.smi_ecmd_type !== rhs.smi_ecmd_type) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_ecmd_type mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_ecmd_type, rhs.smi_ecmd_type), UVM_NONE) 
                s = $sformatf("TRErsp.ECMD_TYPE field mismatched");
	       legal = 0;
            end 
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)   
                s = $sformatf("TRErsp.RMSG_ID field mismatched");
	       legal = 0;
            end 
        end
 // if (smi_conc_msg_class == eConcMsgTreRsp)
        if (smi_conc_msg_class == eConcMsgSysRsp) begin
            if (this.smi_tm !== rhs.smi_tm) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_tm mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_tm, rhs.smi_tm), UVM_NONE)
                s = $sformatf("SYSrsp.TM field mismatched");
	        legal = 0;
            end
            if (this.smi_cmstatus !== rhs.smi_cmstatus) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_cmstatus mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_cmstatus, rhs.smi_cmstatus), UVM_NONE)
                s = $sformatf("SYSrsp.CMSTATUS field mismatched");
	        legal = 0;
            end
            if (this.smi_rmsg_id !== rhs.smi_rmsg_id) begin
                `uvm_info("NDP field mismatch", $sformatf("smi_rmsg_id mismatches. Exp value: 0x%0x Act value: 0x%0x", this.smi_rmsg_id, rhs.smi_rmsg_id), UVM_NONE)
                s = $sformatf("SYSrsp.RMSG_ID field mismatched");
	       legal = 0;
            end
        end

       return legal;       
    endfunction : check_ndp_field_mismatches

    local function bit check_dp_user_field_mismatches(smi_seq_item rhs);
        bit legal = 1;
        foreach (smi_dp_user[i]) begin
            for (int j = 0; j < wSmiDPdata/64; j++) begin
                case ({WSMIDPCONCUSER_EN, WSMIDPPROTPERDW_EN})
                    'b00: begin 
                        if (this.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] !== rhs.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW]) begin
                           `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_dbad[%0d][%0d*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
									i, j, this.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW], rhs.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW]), UVM_NONE)
                            s = $sformatf("SMI_DP_DBAD.DP_DBAD field mismatched");
			   legal = 0;
                        end
                        if (this.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] !== rhs.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_dwid[%0d][%0d*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
									 i, j, this.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW], rhs.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]), UVM_NONE)
                           s = $sformatf("SMI_DP_DWID field mismatched");
			   legal = 0;
                        end
                        if (this.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW] !== rhs.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]) begin
                        //    `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_be[%0d][%0d*WSMIDPBEPERDW +: WSMIDPBEPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
						//			 i, j, this.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW], rhs.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]), UVM_NONE)
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_be[%0d][%0d*%0d +: %0d] mismatches. Exp value: 0x%0x Act value: 0x%0x",
									 i, j,WSMIDPBEPERDW,WSMIDPBEPERDW,this.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW], rhs.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]), UVM_NONE)
                           s = $sformatf("SMI_DP_BE field mismatched");
			   legal = 0;
                        end
                    end
                    'b01: begin 
                        if (this.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] !== rhs.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_dbad[%0d][%0d*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
                                                                         i, j,  this.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW], rhs.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW]), UVM_NONE)
                           s = $sformatf("SMI_DP_DBAD field mismatched");
			   legal = 0;
                        end
                        if (this.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] !== rhs.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_dwid[%0d][%0d*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
                                                                         i, j,  this.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW], rhs.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]), UVM_NONE)
                           s = $sformatf("SMI_DP_DWID field mismatched");
			   legal = 0;
                        end
                        <% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
                        if (this.smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW] !== rhs.smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_protection[%0d][%0d*WSMIDPPROTPERDW +: WSMIDPPROTPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
									 i, j, this.smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW], rhs.smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW]), UVM_NONE)
                            s = $sformatf("SMI_DP_PROTECTION field mismatched");
			    legal = 0;
                        end
                        <% } %> 
                        if (this.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW] !== rhs.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_be[%0d][%0d*WSMIDPBEPERDW +: WSMIDPBEPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
                                                                         i, j, this.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW], rhs.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]), UVM_NONE)
                           s = $sformatf("SMI_DP_BE field mismatched");
			   legal = 0;
                        end
                    end
                    'b10: begin 
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                        if (this.smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW] !== rhs.smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_concuser[%0d][%0d*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
                                                                         i, j, this.smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW], rhs.smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW]), UVM_NONE)
                           s = $sformatf("SMI_DP_CONCUSER field mismatched");
			   legal = 0;
                        end
            <% } %>
                        if (this.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] !== rhs.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_dbad[%0d][%0d*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
                                                                         i, j, this.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW], rhs.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW]), UVM_NONE)
			   s = $sformatf("SMI_DP_DBAD field mismatched");
                           legal = 0;
                        end
                        if (this.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] !== rhs.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_dwid[%0d][%0d*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
                                                                         i, j, this.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW], rhs.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]), UVM_NONE)
			   s = $sformatf("SMI_DP_DWID field mismatched");
                           legal = 0;
                        end
                        if (this.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW] !== rhs.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_be[%0d][%0d*WSMIDPBEPERDW +: WSMIDPBEPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
                                                                         i, j, this.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW], rhs.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]), UVM_NONE)
			   s = $sformatf("SMI_DP_BE field mismatched");
                           legal = 0;
                        end
                    end
                    'b11: begin 
            <% if (obj.Widths.Concerto.Dp.Aux.wDpAux > 0) { %>
                        if (this.smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW] !== rhs.smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW]) begin
                            `uvm_info("NDP field mismatch", $sformatf("smi_dp_concuser[%0d][%0d*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
                                                                         i, j, this.smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW], rhs.smi_dp_concuser[i][j*WSMIDPCONCUSERPERDW +: WSMIDPCONCUSERPERDW]), UVM_NONE)
			   s = $sformatf("SMI_DP_CONCUSER field mismatched");
                           legal = 0;
                        end
            <% } %>
                        if (this.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] !== rhs.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_dbad[%0d][%0d*WSMIDPDBADPERDW +: WSMIDPDBADPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
                                                                         i, j, this.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW], rhs.smi_dp_dbad[i][j*WSMIDPDBADPERDW +: WSMIDPDBADPERDW]), UVM_NONE)
			   s = $sformatf("SMI_DP_DBAD field mismatched");
                           legal = 0;
                        end
                        if (this.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] !== rhs.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_dwid[%0d][%0d*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
                                                                         i, j, this.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW], rhs.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]), UVM_NONE)
			   s = $sformatf("SMI_DP_DWID field mismatched");
                           legal = 0;
                        end
                        <% if (obj.AiuInfo[0].concParams.cmdReqParams.wMProt != 0) { %>
                        if (this.smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW] !== rhs.smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_protection[%0d][%0d*WSMIDPPROTPERDW +: WSMIDPPROTPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
									 i, j, this.smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW], rhs.smi_dp_protection[i][j*WSMIDPPROTPERDW +: WSMIDPPROTPERDW]), UVM_NONE) 
			    s = $sformatf("SMI_DP_PROTECTION field mismatched");
                            legal = 0;
                        end
                        <% } %> 
                        if (this.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW] !== rhs.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]) begin
                            `uvm_info("DPUSER field mismatch", $sformatf("smi_dp_be[%0d][%0d*WSMIDPBEPERDW +: WSMIDPBEPERDW] mismatches. Exp value: 0x%0x Act value: 0x%0x",
                                                                         i, j, this.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW], rhs.smi_dp_be[i][j*WSMIDPBEPERDW +: WSMIDPBEPERDW]), UVM_NONE)
			   s = $sformatf("SMI_DP_BE field mismatched");
                           legal = 0;
                        end
                    end
                endcase
            end 
        end
 // foreach (smi_dp_user[i])
       return legal;
    endfunction : check_dp_user_field_mismatches

    // Call this function as follows
    /*
    m_exp_seq_item.construct_cmdmsg(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_addr               ( ),
        .smi_vz                 ( ),
        .smi_ca                 ( ),
        .smi_ac                 ( ),
        .smi_ch                 ( ),
        .smi_st                 ( ),
        .smi_en                 ( ),
        .smi_es                 ( ),
        .smi_ns                 ( ),
        .smi_pr                 ( ),
        .smi_order              ( ),
        .smi_lk                 ( ),
        .smi_rl                 ( ),
        .smi_tm                 ( ),
        .smi_mpf1_stash_valid   ( ),
        .smi_mpf1_stash_nid     ( ),
        .smi_mpf1_argv          ( ),
        .smi_mpf1_burst_type    ( ),
        .smi_mpf1_alength       ( ),
        .smi_mpf1_asize         ( ),
        .smi_mpf2_stash_valid   ( ),
        .smi_mpf2_stash_lpid    ( ),
        .smi_mpf2_flowid_valid  ( ),
        .smi_mpf2_flowid        ( ),
        .smi_size               ( ),
        .smi_intfsize           ( ),
        .smi_dest_id            ( ),
        .smi_tof                ( ),
        .smi_qos                ( ),
        .smi_ndp_aux            ( )
    );
    */
    function void construct_cmdmsg(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_addr_t              smi_addr,
            smi_vz_t                smi_vz,
            smi_ca_t                smi_ca,
            smi_ac_t                smi_ac,
            smi_ch_t                smi_ch,
            smi_st_t                smi_st,
            smi_en_t                smi_en,
            smi_es_t                smi_es,
            smi_ns_t                smi_ns,
            smi_pr_t                smi_pr,
            smi_order_t             smi_order,
            smi_lk_t                smi_lk,
            smi_rl_t                smi_rl,
            smi_tm_t                smi_tm,
            smi_mpf1_stash_valid_t  smi_mpf1_stash_valid,
            smi_mpf1_stash_nid_t    smi_mpf1_stash_nid,
            smi_mpf1_argv_t         smi_mpf1_argv,
            smi_mpf1_burst_type_t   smi_mpf1_burst_type,
            smi_mpf1_alength_t      smi_mpf1_alength,
            smi_mpf1_asize_t        smi_mpf1_asize,
            smi_mpf1_awunique_t     smi_mpf1_awunique,
            smi_mpf2_stash_valid_t  smi_mpf2_stash_valid,
            smi_mpf2_stash_lpid_t   smi_mpf2_stash_lpid,
            smi_mpf2_flowid_valid_t smi_mpf2_flowid_valid,
            smi_mpf2_flowid_t       smi_mpf2_flowid,
            smi_size_t              smi_size,
            smi_intfsize_t          smi_intfsize,
            smi_dest_id_t           smi_dest_id,
            smi_tof_t               smi_tof,
            smi_qos_t               smi_qos,
            smi_ndp_aux_t           smi_ndp_aux
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_msg_err            = smi_msg_err;
        this.smi_addr               = smi_addr;
        this.smi_vz                 = smi_vz;
        this.smi_ca                 = smi_ca;
        this.smi_ac                 = smi_ac;
        this.smi_ch                 = smi_ch;
        this.smi_st                 = smi_st;
        this.smi_en                 = smi_en;
        this.smi_es                 = smi_es;
        this.smi_ns                 = smi_ns;
        this.smi_pr                 = smi_pr;
        this.smi_order              = smi_order;
        this.smi_lk                 = smi_lk;
        this.smi_rl                 = smi_rl;
        this.smi_tm                 = smi_tm;
        this.smi_mpf1_stash_valid   = smi_mpf1_stash_valid;
        this.smi_mpf1_stash_nid     = smi_mpf1_stash_nid;
        this.smi_mpf1_argv          = smi_mpf1_argv;
        this.smi_mpf1_burst_type    = smi_mpf1_burst_type;
        this.smi_mpf1_alength       = smi_mpf1_alength;
        this.smi_mpf1_asize         = smi_mpf1_asize;
        this.smi_mpf1_awunique      = smi_mpf1_awunique;
        this.smi_mpf2_stash_valid   = smi_mpf2_stash_valid;
        this.smi_mpf2_stash_lpid    = smi_mpf2_stash_lpid;
        this.smi_mpf2_flowid_valid  = smi_mpf2_flowid_valid;
        this.smi_mpf2_flowid        = smi_mpf2_flowid;
        this.smi_size               = smi_size;
        this.smi_intfsize           = smi_intfsize;
        this.smi_dest_id            = smi_dest_id;
        this.smi_tof                = smi_tof;
        this.smi_qos                = smi_qos;
        this.smi_ndp_aux            = smi_ndp_aux;
        this.pack_smi_seq_item();
    endfunction : construct_cmdmsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_snpmsg(
        .smi_targ_ncore_unit_id        ( ),
        .smi_src_ncore_unit_id         ( ),
        .smi_msg_type                  ( ),
        .smi_msg_id                    ( ),
        .smi_steer                     ( ),
        .smi_msg_tier                  ( ),
        .smi_msg_pri                   ( ),
        .smi_msg_qos                   ( ),
        .smi_msg_err                   ( ),
        .smi_cmstatus                  ( ),
        .smi_addr                      ( ),
        .smi_vz                        ( ),
        .smi_ca                        ( ),
        .smi_ac                        ( ),
        .smi_ns                        ( ),
        .smi_pr                        ( ),
        .smi_up                        ( ),
        .smi_rl                        ( ),
        .smi_tm                        ( ),
	.smi_mpf1_stash_valid          ( ),
        .smi_mpf1_stash_nid            ( ),
        .smi_mpf1_dtr_tgt_id           ( ),
        .smi_mpf1_vmid_ext             ( ),
        .smi_mpf2_stash_lpid           ( ),
        .smi_mpf2_dtr_msg_id           ( ),
	.smi_mpf2_stash_valid          ( ),
        .smi_mpf2_dvmop_id            ( ),
        .smi_mpf3_intervention_unit_id ( ),
        .smi_mpf3_dvmop_portion      ( ),
        .smi_intfsize                  ( ),
        .smi_dest_id                   ( ),
        .smi_tof                       ( ),
        .smi_qos                       ( ),
        .smi_rbid                      ( ),
        .smi_ndp_aux                   ( )
    );
    */
    function void construct_snpmsg(
            smi_ncore_unit_id_bit_t         smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t         smi_src_ncore_unit_id,
            smi_msg_type_bit_t              smi_msg_type,
            smi_msg_id_bit_t                smi_msg_id,
            smi_msg_tier_bit_t              smi_msg_tier,
            smi_steer_logic_t               smi_steer,
            smi_msg_pri_bit_t               smi_msg_pri,
            smi_msg_qos_bit_t               smi_msg_qos,
            smi_msg_err_bit_t               smi_msg_err,
            smi_cmstatus_t                  smi_cmstatus,
            smi_addr_t                      smi_addr,
            smi_vz_t                        smi_vz,
            smi_ca_t                        smi_ca,
            smi_ac_t                        smi_ac,
            smi_ns_t                        smi_ns,
            smi_pr_t                        smi_pr,
            smi_up_t                        smi_up,
            smi_rl_t                        smi_rl,
            smi_tm_t                        smi_tm,
            smi_mpf1_stash_valid_t          smi_mpf1_stash_valid,
            smi_mpf1_stash_nid_t            smi_mpf1_stash_nid,
            smi_mpf1_dtr_tgt_id_t           smi_mpf1_dtr_tgt_id,
            smi_mpf1_vmid_ext_t             smi_mpf1_vmid_ext,
            smi_mpf2_dtr_msg_id_t           smi_mpf2_dtr_msg_id,
            smi_mpf2_stash_valid_t          smi_mpf2_stash_valid,
            smi_mpf2_stash_lpid_t           smi_mpf2_stash_lpid,
            smi_mpf2_dvmop_id_t             smi_mpf2_dvmop_id,
            smi_mpf3_intervention_unit_id_t smi_mpf3_intervention_unit_id,
            smi_mpf3_dvmop_portion_t        smi_mpf3_dvmop_portion,
            smi_mpf3_range_t                smi_mpf3_range,
            smi_mpf3_num_t                  smi_mpf3_num,
            smi_intfsize_t                  smi_intfsize,
            smi_dest_id_t                   smi_dest_id,
            smi_tof_t                       smi_tof,
            smi_qos_t                       smi_qos,
            smi_rbid_t                      smi_rbid,
            smi_ndp_aux_t                   smi_ndp_aux
        );
        this.smi_steer                     = smi_steer;
        this.smi_targ_ncore_unit_id        = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id         = smi_src_ncore_unit_id;
        this.smi_msg_tier                  = smi_msg_tier;
        this.smi_msg_qos                   = smi_msg_qos;
        this.smi_msg_pri                   = smi_msg_pri;
        this.smi_msg_type                  = smi_msg_type;
        this.smi_msg_id                    = smi_msg_id;
        this.smi_msg_err                   = smi_msg_err;
        this.smi_cmstatus                  = smi_cmstatus;
        this.smi_addr                      = smi_addr;
        this.smi_vz                        = smi_vz;
        this.smi_ca                        = smi_ca;
        this.smi_ac                        = smi_ac;
        this.smi_ns                        = smi_ns;
        this.smi_pr                        = smi_pr;
        this.smi_rl                        = smi_rl;
        this.smi_up                        = smi_up;
        this.smi_tm                        = smi_tm;
        this.smi_mpf1_stash_valid          = smi_mpf1_stash_valid;
        this.smi_mpf1_stash_nid            = smi_mpf1_stash_nid;
        this.smi_mpf1_dtr_tgt_id           = smi_mpf1_dtr_tgt_id;
        this.smi_mpf1_vmid_ext             = smi_mpf1_vmid_ext;
        this.smi_mpf2_dtr_msg_id           = smi_mpf2_dtr_msg_id;
        this.smi_mpf2_stash_valid          = smi_mpf2_stash_valid;
        this.smi_mpf2_stash_lpid           = smi_mpf2_stash_lpid;
        this.smi_mpf2_dvmop_id             = smi_mpf2_dvmop_id;
        this.smi_mpf3_intervention_unit_id = smi_mpf3_intervention_unit_id;
        this.smi_mpf3_dvmop_portion        = smi_mpf3_dvmop_portion;
        this.smi_mpf3_range                = smi_mpf3_range;
        this.smi_mpf3_num                  = smi_mpf3_num;
        this.smi_intfsize                  = smi_intfsize;
        this.smi_dest_id                   = smi_dest_id;
        this.smi_tof                       = smi_tof;
        this.smi_qos                       = smi_qos;
        this.smi_rbid                      = smi_rbid;
        this.smi_ndp_aux                   = smi_ndp_aux;
        this.pack_smi_seq_item();
    endfunction : construct_snpmsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_hntmsg(
        .smi_steer              ( ),
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_tier           ( ),
        .smi_msg_qos            ( ),
        .smi_msg_pri            ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_addr               ( ),
        .smi_ns                 ( ),
        .smi_ndp_aux            ( )
    );
    */
    function void construct_hntmsg(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_addr_t              smi_addr,
            smi_ac_t                smi_ac,
            smi_ns_t                smi_ns,
            smi_rl_t                smi_rl,
            smi_ndp_aux_t           smi_ndp_aux
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_addr               = smi_addr;
        this.smi_ac                 = smi_ac;
        this.smi_ns                 = smi_ns;
        this.smi_rl                 = smi_rl;
        this.smi_ndp_aux            = smi_ndp_aux;
    endfunction : construct_hntmsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_mrdmsg(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_steer              ( ),
        .smi_msg_tier           ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_addr               ( ),
        .smi_vz                 ( ),
        .smi_ac                 ( ),
        .smi_ns                 ( ),
        .smi_pr                 ( ),
        .smi_rl                 ( ),
        .smi_tm                 ( ),
        .smi_mpf1_dtr_tgt_id    ( ),
        .smi_mpf2_dtr_msg_id    ( ),
        .smi_size               ( ),
        .smi_intfsize           ( ),
        .smi_qos                ( ),
        .smi_ndp_aux            ( )
    );
    */
    function void construct_mrdmsg(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_addr_t              smi_addr,
            smi_vz_t                smi_vz,
            smi_ac_t                smi_ac,
            smi_ns_t                smi_ns,
            smi_pr_t                smi_pr,
            smi_rl_t                smi_rl,
            smi_tm_t                smi_tm,
            smi_mpf1_dtr_tgt_id_t   smi_mpf1_dtr_tgt_id,
            smi_mpf2_dtr_msg_id_t   smi_mpf2_dtr_msg_id,
            smi_size_t              smi_size,
            smi_intfsize_t          smi_intfsize,
	    smi_qos_t               smi_qos,
            smi_ndp_aux_t           smi_ndp_aux
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_addr               = smi_addr;
        this.smi_ac                 = smi_ac;
        this.smi_ns                 = smi_ns;
        this.smi_pr                 = smi_pr;
        this.smi_rl                 = smi_rl;
        this.smi_tm                 = smi_tm;
        this.smi_mpf1_dtr_tgt_id    = smi_mpf1_dtr_tgt_id;
        this.smi_mpf2_dtr_msg_id    = smi_mpf2_dtr_msg_id;
        this.smi_size               = smi_size;
        this.smi_intfsize           = smi_intfsize;
        this.smi_qos                = smi_qos;
        this.smi_ndp_aux            = smi_ndp_aux;
        this.pack_smi_seq_item();
    endfunction : construct_mrdmsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_strmsg(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_cmstatus_so        ( ),
        .smi_cmstatus_ss        ( ),
        .smi_cmstatus_sd        ( ),
        .smi_cmstatus_st        ( ),
        .smi_cmstatus_state     ( ),
        .smi_cmstatus_snarf     ( ),
        .smi_cmstatus_exok      ( ),
        .smi_tm                 ( ),
        .smi_rbid               ( ),
        .smi_mpf1               ( ),
        .smi_mpf2               ( ),
        .smi_intfsize           ( )
//        .smi_ndp_aux            ( )
    );
    */
    function void construct_strmsg(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_err_bit_t       smi_msg_err,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_cmstatus_t          smi_cmstatus,
            smi_cmstatus_so_t       smi_cmstatus_so,
            smi_cmstatus_ss_t       smi_cmstatus_ss,
            smi_cmstatus_sd_t       smi_cmstatus_sd,
            smi_cmstatus_st_t       smi_cmstatus_st,
            smi_cmstatus_state_t    smi_cmstatus_state,
            smi_cmstatus_snarf_t    smi_cmstatus_snarf,
            smi_cmstatus_exok_t     smi_cmstatus_exok,
            smi_tm_t                smi_tm,
            smi_rbid_t              smi_rbid,
            smi_mpf1_t              smi_mpf1,
            smi_mpf2_t              smi_mpf2,
            smi_intfsize_t          smi_intfsize
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_msg_type           = smi_msg_type;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        if (!smi_cmstatus[SMICMSTATUSERRBIT]) begin
            this.smi_cmstatus_so    = smi_cmstatus_so;
            this.smi_cmstatus_ss    = smi_cmstatus_ss;
            this.smi_cmstatus_sd    = smi_cmstatus_sd;
            this.smi_cmstatus_st    = smi_cmstatus_st;
            this.smi_cmstatus_state = smi_cmstatus_state;
            this.smi_cmstatus_snarf = smi_cmstatus_snarf;
            this.smi_cmstatus_exok  = smi_cmstatus_exok;
		end else begin 
            this.smi_cmstatus_err 		  = smi_cmstatus[SMICMSTATUSERRBIT];
            this.smi_cmstatus_err_payload = smi_cmstatus[WSMICMSTATUSERRPAYLOAD-1:0];
		end 
        this.smi_tm                 = smi_tm;
        this.smi_rbid               = smi_rbid;
        this.smi_mpf1               = smi_mpf1;
        this.smi_mpf2               = smi_mpf2;
        this.smi_intfsize           = smi_intfsize;
//        this.smi_ndp_aux            = smi_ndp_aux;
        this.pack_smi_seq_item();
    endfunction : construct_strmsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_dtrmsg(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_rl                 ( ),
        .smi_tm                 ( ),
        .smi_mpf1_dtr_long_dtw  ( ),
        .smi_ndp_aux            ( ),
        .smi_dp_last            ( ),
        .smi_dp_data            ( ),
        .smi_dp_be              ( ),
        .smi_dp_protection      ( ),
        .smi_dp_dwid            ( ),
        .smi_dp_dbad            ( ),
        .smi_dp_concuser        ( )
    );
    */
 
    function void construct_dtrmsg(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_rl_t                smi_rl,
            smi_tm_t                smi_tm,
            smi_mpf1_dtr_long_dtw_t smi_mpf1_dtr_long_dtw,
            smi_ndp_aux_t           smi_ndp_aux,
            smi_dp_last_bit_t       smi_dp_last,
            smi_dp_data_bit_t       smi_dp_data[],
            smi_dp_be_t             smi_dp_be[],
            smi_dp_protection_t     smi_dp_protection[],
            smi_dp_dwid_t           smi_dp_dwid[],
            smi_dp_dbad_t           smi_dp_dbad[],
            smi_dp_concuser_t       smi_dp_concuser[]
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_rl                 = smi_rl;
        this.smi_tm                 = smi_tm;
        this.smi_mpf1_dtr_long_dtw  = smi_mpf1_dtr_long_dtw;
        this.smi_ndp_aux            = smi_ndp_aux;
        this.smi_dp_data            = smi_dp_data;
        this.smi_dp_be              = smi_dp_be;
        this.smi_dp_protection      = smi_dp_protection;
        this.smi_dp_dwid            = smi_dp_dwid;
        this.smi_dp_dbad            = smi_dp_dbad;
        this.smi_dp_concuser        = smi_dp_concuser;
        this.smi_dp_last            = smi_dp_last;
        this.pack_smi_seq_item();
    endfunction : construct_dtrmsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_dtwmsg(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_rbid               ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_rl                 ( ),
        .smi_tm                 ( ),
        .smi_prim               ( ),
        .smi_mpf1               ( ), // from the message, cannot decide contents. Driver/Receiver needs to provide/check 
        .smi_mpf2               ( ), // from the message, cannot decide contents. Driver/Receiver needs to provide/check 
        .smi_intfsize           ( ),
        .smi_ndp_aux            ( ),
        .smi_dp_last            ( ),
        .smi_dp_data            ( ),
        .smi_dp_be              ( ),
        .smi_dp_protection      ( ),
        .smi_dp_dwid            ( ),
        .smi_dp_dbad            ( ),
        .smi_dp_concuser        ( )
    );
    */
    function void construct_dtwmsg(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_rbid_t              smi_rbid,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_rl_t                smi_rl,
            smi_tm_t                smi_tm,
            smi_prim_t              smi_prim,
	    smi_mpf1_t              smi_mpf1,
            smi_mpf2_t              smi_mpf2,
            smi_intfsize_t          smi_intfsize,
            smi_ndp_aux_t           smi_ndp_aux,
            smi_dp_last_bit_t       smi_dp_last,
            smi_dp_data_bit_t       smi_dp_data[],
            smi_dp_be_t             smi_dp_be[],
            smi_dp_protection_t     smi_dp_protection[],
            smi_dp_dwid_t           smi_dp_dwid[],
            smi_dp_dbad_t           smi_dp_dbad[],
            smi_dp_concuser_t       smi_dp_concuser[]
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_rbid               = smi_rbid;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_rl                 = smi_rl;
        this.smi_tm                 = smi_tm;
        this.smi_prim               = smi_prim;
        this.smi_mpf1               = smi_mpf1;
        this.smi_mpf2               = smi_mpf2;
        this.smi_intfsize           = smi_intfsize;
        this.smi_ndp_aux            = smi_ndp_aux;
        this.smi_dp_data            = smi_dp_data;
        this.smi_dp_be              = smi_dp_be;
        this.smi_dp_protection      = smi_dp_protection;
        this.smi_dp_dwid            = smi_dp_dwid;
        this.smi_dp_dbad            = smi_dp_dbad;
        this.smi_dp_concuser        = smi_dp_concuser;
        this.smi_dp_last            = smi_dp_last;
        this.pack_smi_seq_item();
    endfunction : construct_dtwmsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_dtwdbgmsg(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_msg_err            ( ),
        .smi_tm                 ( ),
        .smi_cmstatus           ( ),
        .smi_rl                 ( ),
        .smi_ndp_aux            ( ),
        .smi_dp_last            ( ),
        .smi_dp_data            ( ),
        .smi_dp_be              ( ),
        .smi_dp_protection      ( ),
        .smi_dp_dwid            ( ),
        .smi_dp_dbad            ( ),
        .smi_dp_concuser        ( )
    );
    */
    function void construct_dtwdbgmsg(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_err_bit_t       smi_msg_err,
            smi_tm_t                smi_tm,
            smi_cmstatus_t          smi_cmstatus,
            smi_rl_t                smi_rl,
            smi_ndp_aux_t           smi_ndp_aux,
            smi_dp_last_bit_t       smi_dp_last,
            smi_dp_data_bit_t       smi_dp_data[],
            smi_dp_be_t             smi_dp_be[],
            smi_dp_protection_t     smi_dp_protection[],
            smi_dp_dwid_t           smi_dp_dwid[],
            smi_dp_dbad_t           smi_dp_dbad[],
            smi_dp_concuser_t       smi_dp_concuser[]
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_rl                 = smi_rl;
        this.smi_ndp_aux            = smi_ndp_aux;
        this.smi_dp_data            = smi_dp_data;
        this.smi_dp_be              = smi_dp_be;
        this.smi_dp_protection      = smi_dp_protection;
        this.smi_dp_dwid            = smi_dp_dwid;
        this.smi_dp_dbad            = smi_dp_dbad;
        this.smi_dp_concuser        = smi_dp_concuser;
        this.smi_dp_last            = smi_dp_last;
        this.pack_smi_seq_item();
    endfunction : construct_dtwdbgmsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_updmsg(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_msg_err            ( ),
        .smi_tm                 ( ),
        .smi_cmstatus           ( ),
        .smi_addr               ( ),
        .smi_ns                 ( ),
        .smi_qos                ( ),
    );
    */
    function void construct_updmsg(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_err_bit_t       smi_msg_err,
            smi_tm_t                smi_tm,
            smi_cmstatus_t          smi_cmstatus,
            smi_addr_t              smi_addr,
            smi_ns_t                smi_ns,
	    smi_qos_t               smi_qos
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_err            = smi_msg_err;
        this.smi_tm                 = smi_tm;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_addr               = smi_addr;
        this.smi_ns                 = smi_ns;
        this.smi_qos                = smi_qos;
        this.pack_smi_seq_item();
    endfunction : construct_updmsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_rbmsg(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rbid               ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_rtype              ( ),
        .smi_addr               ( ),
        .smi_size               ( ),
        .smi_vz                 ( ),
        .smi_ac                 ( ),
        .smi_ca                 ( ),
        .smi_ns                 ( ),
        .smi_pr                 ( ),
        .smi_mw                 ( ),
        .smi_rl                 ( ),
        .smi_mpf1               ( ),
        .smi_tof                ( ),
        .smi_qos                ( ),
        .smi_ndp_aux            ( )
    );
    */
    function void construct_rbmsg(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_rbid_t              smi_rbid,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_rtype_t             smi_rtype,
            smi_addr_t              smi_addr,
            smi_size_t              smi_size,
            smi_vz_t                smi_vz,
            smi_ca_t                smi_ca,
            smi_ac_t                smi_ac,
            smi_ns_t                smi_ns,
            smi_pr_t                smi_pr,
            smi_mw_t                smi_mw,
            smi_rl_t                smi_rl,
            smi_mpf1_t              smi_mpf1,
            smi_tof_t               smi_tof,
	    smi_qos_t               smi_qos,
            smi_ndp_aux_t           smi_ndp_aux
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_rbid               = smi_rbid;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_rtype              = smi_rtype;
        this.smi_addr               = smi_addr;
        this.smi_size               = smi_size;
        this.smi_vz                 = smi_vz;
        this.smi_ca                 = smi_ca;
        this.smi_ac                 = smi_ac;
        this.smi_ns                 = smi_ns;
        this.smi_pr                 = smi_pr;
        this.smi_mw                 = smi_mw;
        this.smi_rl                 = smi_rl;
        this.smi_mpf1               = smi_mpf1;
        this.smi_tof                = smi_tof;
        this.smi_qos                = smi_qos;
        this.smi_ndp_aux            = smi_ndp_aux;
        this.pack_smi_seq_item();
    endfunction : construct_rbmsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_sysmsg(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_sysreq_op          ( ),
        .smi_ndp_aux            ( )
    );
    */
    function void construct_sysmsg(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
	    smi_sysreq_op_t         smi_sysreq_op,
            smi_ndp_aux_t           smi_ndp_aux
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_sysreq_op          = smi_sysreq_op;
        this.smi_ndp_aux            = smi_ndp_aux;
        this.pack_smi_seq_item();
    endfunction : construct_sysmsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_sysrsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_ndp_aux            ( )
    );
    */
    function void construct_sysrsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_ndp_aux_t           smi_ndp_aux
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_tm                 = smi_tm;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_ndp_aux            = smi_ndp_aux;
        this.pack_smi_seq_item();
    endfunction : construct_sysrsp

    function void construct_sysreq(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
	    smi_sysreq_op_t         smi_sysreq_op,
            smi_ndp_aux_t           smi_ndp_aux
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_tm                 = smi_tm;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_sysreq_op          = smi_sysreq_op;
        this.smi_ndp_aux            = smi_ndp_aux;
        this.pack_smi_seq_item();
    endfunction : construct_sysreq


    // Call this function as follows
    /*
    m_exp_seq_item.construct_rbusemsg(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rbid               ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_rl                 ( )
    );
    */
    function void construct_rbusemsg(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_rbid_t              smi_rbid,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_rl_t                smi_rl
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_rbid               = smi_rbid;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_rl                 = smi_rl;
        this.pack_smi_seq_item();
    endfunction : construct_rbusemsg

    // Call this function as follows
    /*
    m_exp_seq_item.construct_ccmdrsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( )
    );
    */
    function void construct_ccmdrsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_steer              = smi_steer;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.pack_smi_seq_item();
    endfunction : construct_ccmdrsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_nccmdrsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( )
    );
    */
    function void construct_nccmdrsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_steer_logic_t       smi_steer,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_tm                 = smi_tm;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.pack_smi_seq_item();
    endfunction : construct_nccmdrsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_snprsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_cmstatus_rv        ( ),
        .smi_cmstatus_rs        ( ),
        .smi_cmstatus_dc        ( ),
        .smi_cmstatus_dt_aiu    ( ),
        .smi_cmstatus_dt_dmi    ( ),
        .smi_cmstatus_snarf     ( ),
        .smi_mpf1_dtr_msg_id    ( ),
        .smi_intfsize           ( )
    );
    */
    function void construct_snprsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_cmstatus_rv_t       smi_cmstatus_rv,
            smi_cmstatus_rs_t       smi_cmstatus_rs,
            smi_cmstatus_dc_t       smi_cmstatus_dc,
            smi_cmstatus_dt_aiu_t   smi_cmstatus_dt_aiu,
            smi_cmstatus_dt_dmi_t   smi_cmstatus_dt_dmi,
            smi_cmstatus_snarf_t    smi_cmstatus_snarf,
            smi_mpf1_dtr_msg_id_t   smi_mpf1_dtr_msg_id,
            smi_intfsize_t          smi_intfsize
        );
        this.smi_steer              = smi_steer;
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_type           = smi_msg_type;
        this.smi_tm                 = smi_tm;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_cmstatus_rv        = smi_cmstatus_rv;
        this.smi_cmstatus_rs        = smi_cmstatus_rs;
        this.smi_cmstatus_dc        = smi_cmstatus_dc;
        this.smi_cmstatus_dt_aiu    = smi_cmstatus_dt_aiu;
        this.smi_cmstatus_dt_dmi    = smi_cmstatus_dt_dmi;
        this.smi_cmstatus_snarf     = smi_cmstatus_snarf;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_mpf1_dtr_msg_id    = smi_mpf1_dtr_msg_id;
        this.smi_intfsize           = smi_intfsize;
        this.pack_smi_seq_item();
    endfunction : construct_snprsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_dtwrsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_rl                 ( )
    );
    */
    function void construct_dtwrsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_rl_t                smi_rl
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_rl                 = smi_rl;
        this.pack_smi_seq_item();
    endfunction : construct_dtwrsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_dtw_dbg_rsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_rl                 ( )
    );
    */
    function void construct_dtw_dbg_rsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_rl_t                smi_rl
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_rl                 = smi_rl;
        this.pack_smi_seq_item();
    endfunction : construct_dtw_dbg_rsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_dtrrsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( )
    );
    */
    function void construct_dtrrsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.pack_smi_seq_item();
    endfunction : construct_dtrrsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_hntrsp(
        .smi_steer              ( ),
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_tier           ( ),
        .smi_msg_qos            ( ),
        .smi_msg_pri            ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_rmsg_id            ( ),
        .smi_ndp_aux            ( )
    );
    */
    function void construct_hntrsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.pack_smi_seq_item();
    endfunction : construct_hntrsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_mrdrsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_qos            ( ),
        .smi_msg_pri            ( ),
        .smi_tm                 ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( )
    );
    */
    function void construct_mrdrsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.pack_smi_seq_item();
    endfunction : construct_mrdrsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_strrsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( )
    );
    */
    function void construct_strrsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.pack_smi_seq_item();
    endfunction : construct_strrsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_updrsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_tm                 ( ),
        .smi_cmstatus           ( )
    );
    */
    function void construct_updrsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_tm_t                smi_tm,
            smi_cmstatus_t          smi_cmstatus,
            smi_msg_id_bit_t        smi_rmsg_id
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.pack_smi_seq_item();
    endfunction : construct_updrsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_rbrsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( )
    );
    */
    function void construct_rbrsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_rbid_t              smi_rbid,
            smi_cmstatus_t          smi_cmstatus
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_rbid               = smi_rbid;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.pack_smi_seq_item();
    endfunction : construct_rbrsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_rbusersp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( )
    );
    */
    function void construct_rbusersp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.pack_smi_seq_item();
    endfunction : construct_rbusersp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_cmprsp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_tm                 ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( )
    );
    */
    function void construct_cmprsp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_tm_t                smi_tm,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_tm                 = smi_tm;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.pack_smi_seq_item();
    endfunction : construct_cmprsp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_cmersp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_rmsg_id            ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_ecmd_type          ( )
    );
    */
    function void construct_cmersp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_msg_id_bit_t        smi_rmsg_id,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_type_t              smi_ecmd_type
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_ecmd_type          = smi_ecmd_type;
        this.pack_smi_seq_item();
    endfunction : construct_cmersp

    // Call this function as follows
    /*
    m_exp_seq_item.construct_trersp(
        .smi_targ_ncore_unit_id ( ),
        .smi_src_ncore_unit_id  ( ),
        .smi_msg_type           ( ),
        .smi_msg_id             ( ),
        .smi_msg_tier           ( ),
        .smi_steer              ( ),
        .smi_msg_pri            ( ),
        .smi_msg_qos            ( ),
        .smi_ecmd_type          ( ),
        .smi_msg_err            ( ),
        .smi_cmstatus           ( ),
        .smi_rmsg_id            ( )
    );
    */
    function void construct_trersp(
            smi_ncore_unit_id_bit_t smi_targ_ncore_unit_id,
            smi_ncore_unit_id_bit_t smi_src_ncore_unit_id,
            smi_msg_type_bit_t      smi_msg_type,
            smi_msg_id_bit_t        smi_msg_id,
            smi_msg_tier_bit_t      smi_msg_tier,
            smi_steer_logic_t       smi_steer,
            smi_msg_pri_bit_t       smi_msg_pri,
            smi_msg_qos_bit_t       smi_msg_qos,
            smi_type_t              smi_ecmd_type,
            smi_msg_err_bit_t       smi_msg_err,
            smi_cmstatus_t          smi_cmstatus,
            smi_msg_id_bit_t        smi_rmsg_id
        );
        this.smi_targ_ncore_unit_id = smi_targ_ncore_unit_id;
        this.smi_src_ncore_unit_id  = smi_src_ncore_unit_id;
        this.smi_msg_type           = smi_msg_type;
        this.smi_msg_id             = smi_msg_id;
        this.smi_msg_tier           = smi_msg_tier;
        this.smi_steer              = smi_steer;
        this.smi_msg_pri            = smi_msg_pri;
        this.smi_msg_qos            = smi_msg_qos;
        this.smi_ecmd_type          = smi_ecmd_type;
        this.smi_msg_err            = smi_msg_err;
        this.smi_cmstatus           = smi_cmstatus;
        this.smi_rmsg_id            = smi_rmsg_id;
        this.pack_smi_seq_item();
    endfunction : construct_trersp



    //---------------------------------------------------------------------------------
    //of which class is given msg type?
    static function eConcMsgClass type2class(smi_type_t smi_type);
        begin
            eMsgCMD    eMsg;
            if ((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgCmdReq;
        end
        begin
            eMsgSysReq eMsg;
            if ((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgSysReq;
        end
        begin
            eMsgCCmdRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgCCmdRsp;
        end
        begin
            eMsgNCCmdRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgNcCmdRsp;
        end
        begin
            eMsgSNP eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgSnpReq;
        end
        begin
            eMsgSnpRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgSnpRsp;
        end
        begin
            eMsgHNT eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgHntReq;
        end
        begin
            eMsgHntRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgHntRsp;
        end
        begin
            eMsgMRD eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgMrdReq;
        end
        begin
            eMsgMrdRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgMrdRsp;
        end
        begin
            eMsgSTR eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgStrReq;
        end
        begin
            eMsgStrRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgStrRsp;
        end
        begin
            eMsgDTR eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgDtrReq;
        end
        begin
            eMsgDtrRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgDtrRsp;
        end
        begin
            eMsgDTW       eMsg1;
            eMsgDTWMrgMRD eMsg2;
            if (
                ((smi_type >= eMsg1.first()) && (smi_type <= eMsg1.last())) 
                || ((smi_type >= eMsg2.first()) && (smi_type <= eMsg2.last()))
            )
                return eConcMsgDtwReq;
        end
        begin
            eMsgDtwRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgDtwRsp;
        end
        begin
            eMsgDtwDbgReq  eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgDtwDbgReq;
        end
        begin
            eMsgDtwDbgRsp    eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgDtwDbgRsp;
        end
        begin
            eMsgUPD eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgUpdReq;
        end
        begin
            eMsgUpdRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgUpdRsp;
        end
        begin
            eMsgRBReq eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgRbReq;
        end
        begin
            eMsgRBRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgRbRsp;
        end
        begin
            eMsgRBUsed eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgRbUseReq;
        end
        begin
            eMsgRBUseRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgRbUseRsp;
        end
        begin
            eMsgCmpRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgCmpRsp;
        end
        begin
            eMsgCmeRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgCmeRsp;
        end
        begin
            eMsgTreRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgTreRsp;
        end
        begin
            eMsgSysRsp eMsg;
            if((smi_type >= eMsg.first()) && (smi_type <= eMsg.last()))
                return eConcMsgSysRsp;
        end

        //TODO FIXME how throw error in static method?
        //`uvm_error($sformatf("%m"), $sformatf("invalid msgtype: %p", smi_type))

    endfunction : type2class

    //---------------------------------------------------------------------------------
    // getting the name of the msg type for debug purpose
    function string type2cmdname();
        begin
            eMsgCMD    eMsg;
            if ((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgSysReq eMsg;
            if ((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgCCmdRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgNCCmdRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgSNP eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgSnpRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgHNT eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgHntRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgMRD eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgMrdRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgSTR eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgStrRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgDTR eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgDtrRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgDTW       eMsg;
            if ((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last()))  begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgDTWMrgMRD eMsg;
            if ((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgDtwRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgDtwDbgReq  eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgDtwDbgRsp    eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgUPD eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgUpdRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgRBReq eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgRBRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgRBUsed eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgRBUseRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgCmpRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgCmeRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgTreRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end
        begin
            eMsgSysRsp eMsg;
            if((this.smi_msg_type >= eMsg.first()) && (this.smi_msg_type <= eMsg.last())) begin
                $cast(eMsg, this.smi_msg_type);
                return eMsg.name();
            end
        end

        //TODO FIXME how throw error in static method?
        //`uvm_error($sformatf("%m"), $sformatf("invalid msgtype: %p", this.smi_msg_type))

    endfunction : type2cmdname


    function bit isCmdMsg();
        return (type2class(this.smi_msg_type) == eConcMsgCmdReq);
    endfunction : isCmdMsg

    function bit isCmdNcRdMsg();
        return (smi_msg_type == CMD_RD_NC); 
    endfunction : isCmdNcRdMsg

    function bit isCmdCacheOpsMsg();
        return (smi_msg_type == CMD_CLN_INV || smi_msg_type == CMD_CLN_VLD ||  smi_msg_type == CMD_CLN_SH_PER || smi_msg_type == CMD_MK_INV); 
    endfunction : isCmdCacheOpsMsg

    function bit isCmdNcWrMsg();
        return ((smi_msg_type == CMD_WR_NC_PTL) || (smi_msg_type == CMD_WR_NC_FULL)); 
    endfunction : isCmdNcWrMsg

    function bit isCmdAtmStoreMsg();
        return (smi_msg_type == CMD_WR_ATM); 
    endfunction : isCmdAtmStoreMsg

    function bit isCmdAtmLoadMsg();
        return ((smi_msg_type == CMD_RD_ATM) || (smi_msg_type == CMD_SW_ATM) || (smi_msg_type == CMD_CMP_ATM)); 
    endfunction : isCmdAtmLoadMsg

    function bit isUpdMsg();
        return (type2class(this.smi_msg_type) == eConcMsgUpdReq);
    endfunction : isUpdMsg

    function bit isSnpMsg();
        return (type2class(this.smi_msg_type) == eConcMsgSnpReq);
    endfunction : isSnpMsg

    function bit isHntMsg();
        return (type2class(this.smi_msg_type) == eConcMsgHntReq);
    endfunction : isHntMsg

    function bit isMrdMsg();
        return (type2class(this.smi_msg_type) == eConcMsgMrdReq);
    endfunction : isMrdMsg

    function bit isStrMsg();
        return (type2class(this.smi_msg_type) == eConcMsgStrReq);
    endfunction : isStrMsg

    function bit isDtrMsg();
        return (type2class(this.smi_msg_type) == eConcMsgDtrReq);
    endfunction : isDtrMsg

    function bit isDtwMsg();
        return (type2class(this.smi_msg_type) == eConcMsgDtwReq);
    endfunction : isDtwMsg

    function bit isDtwDbgReqMsg();
        return (type2class(this.smi_msg_type) == eConcMsgDtwDbgReq);
    endfunction : isDtwDbgReqMsg
   
    function bit hasDP();
       return (isDtrMsg() || isDtwMsg() || isDtwDbgReqMsg());
    endfunction : hasDP
   
    function bit isDtwRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgDtwRsp);
    endfunction : isDtwRspMsg

    function bit isDtwMrgMrd();
      eMsgDTWMrgMRD eMsg;
      return ((smi_msg_type >= eMsg.first()) && (smi_msg_type <= eMsg.last())); 
    endfunction: isDtwMrgMrd

    function bit isRbMsg();
        return (type2class(this.smi_msg_type) == eConcMsgRbReq);
    endfunction : isRbMsg

    function bit isSysReqMsg();
        return (type2class(this.smi_msg_type) == eConcMsgSysReq);
    endfunction : isSysReqMsg
  
    function bit isSysRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgSysRsp);
    endfunction : isSysRspMsg
  
    function bit isRbUseMsg();
        return (type2class(this.smi_msg_type) == eConcMsgRbUseReq);
    endfunction : isRbUseMsg

    function bit isCCmdRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgCCmdRsp);
    endfunction : isCCmdRspMsg 

    function bit isNcCmdRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgNcCmdRsp);
    endfunction : isNcCmdRspMsg

    function bit isSnpRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgSnpRsp);
    endfunction : isSnpRspMsg

    function bit isDtwDbgRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgDtwDbgRsp);
    endfunction : isDtwDbgRspMsg

    function bit isDtrRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgDtrRsp);
    endfunction : isDtrRspMsg

    function bit isHntRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgHntRsp);
    endfunction : isHntRspMsg

    function bit isStrRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgStrRsp);
    endfunction : isStrRspMsg

    function bit isMrdRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgMrdRsp);
    endfunction : isMrdRspMsg

    function bit isUpdRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgUpdRsp);
    endfunction : isUpdRspMsg

    function bit isRbRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgRbRsp);
    endfunction : isRbRspMsg

    function bit isRbUseRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgRbUseRsp);
    endfunction : isRbUseRspMsg

    function bit isCmpRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgCmpRsp);
    endfunction : isCmpRspMsg

    function bit isCmeRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgCmeRsp);
    endfunction : isCmeRspMsg

    function bit isTreRspMsg();
        return (type2class(this.smi_msg_type) == eConcMsgTreRsp);
    endfunction : isTreRspMsg

  
    function smi_ndp_protection_t gen_smi_ndp_prot(smi_ndp_bit_t ndp, int len);
        smi_ndp_protection_t smi_ndp_prot;
     <% if (obj.useResiliency && (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity")) { %>
      smi_ndp_prot = checkPARITY_N(smi_ndp, len);
     <% } else if (obj.useResiliency && (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc")) { %>
      // len indicates the ndp without protection. Note: ndp_prot width depends on the length
      smi_ndp_prot = checkSECDED_N(ndp, len, 0);
     <% } %>
     `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG: NDP_PROT SMI LEN=%0d, NDP_PROT=%p", len, smi_ndp_prot), UVM_HIGH)
     return smi_ndp_prot;      
    endfunction : gen_smi_ndp_prot

<% if (obj.useResiliency) { %>
     function void correct_smi_error( );
        smi_err_class_t smi_error_ndp, smi_error_hdr, smi_error_dp[];
        smi_ndp_bit_t   corr_dat;

        `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG: Error CHECK"), UVM_HIGH)
         correct_smi_hdr_error( );
         correct_smi_ndp_error( );
         correct_smi_dp_error( );
     endfunction : correct_smi_error;

     function void correct_smi_hdr_error( );
       smi_err_class_t smi_error_hdr;
       smi_ndp_bit_t   corr_dat;
       `uvm_info($sformatf("%m"), $sformatf("ECC HDR DEBUG 0: prot:%p, targ_id:%p, src_id:%p, msg_type:%p, msg_id:%p", this.smi_msg_user, this.smi_targ_id, this.smi_src_id, this.smi_msg_type, this.smi_msg_id), UVM_DEBUG)

<% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType != "none") { %>
       // Check and Correct HDR error first
       hdr_corr_error   = 0;
       hdr_uncorr_error = 0;
       hdr_parity_error = 0;
       smi_error_hdr = smi_check_err( {this.smi_msg_user,this.smi_targ_id,this.smi_src_id,this.smi_msg_type,this.smi_msg_id},
                                      WSMITGTID+WSMISRCID+WSMIMSGTYPE+WSMIMSGID, WSMIHPROT+WSMITGTID+WSMISRCID+WSMIMSGTYPE+WSMIMSGID, corr_dat );
       if (smi_error_hdr == CORR_ECC_ERR) begin
           `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG HDR 2C: CORRECTED NDP HDR Error: TRGTID(orig:%p new:%p) SRCID(orig:%p new:%p) MSGTP(old:%p new:%p) MSGID(orig:%p new:%p PROT(orig:%p new:%p)",
                                                this.smi_targ_id,   corr_dat[WSMITGTID+WSMISRCID+WSMIMSGTYPE+WSMIMSGID-1:WSMISRCID+WSMIMSGTYPE+WSMIMSGID],
                                                this.smi_src_id,    corr_dat[WSMISRCID+WSMIMSGTYPE+WSMIMSGID-1:WSMIMSGTYPE+WSMIMSGID],
                                                this.smi_msg_type,  corr_dat[WSMIMSGTYPE+WSMIMSGID-1:WSMIMSGID],
                                                this.smi_msg_id,    corr_dat[WSMIMSGID-1:0],
                                                this.smi_msg_user,  corr_dat[WSMIHPROT+WSMITGTID+WSMISRCID+WSMIMSGTYPE+WSMIMSGID-1:WSMITGTID+WSMISRCID+WSMIMSGTYPE+WSMIMSGID]), UVM_HIGH)
            {this.smi_msg_user, this.smi_targ_id, this.smi_src_id, this.smi_msg_type, this.smi_msg_id} = corr_dat;
           `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG HDR 2D: corrected msg_type:%p", this.smi_msg_type), UVM_HIGH)
            hdr_corr_error++;
       end else if ((smi_error_hdr == UNCORR_ECC_ERR) || (smi_error_hdr == PARITY_ERR)) begin
           `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG HDR 2E: UNCORRECTABLE NDP HDR Error (ECC or PARITY): PROT:%p TGTID:%p SRCID:%p MSGTYP:%p MSGID:%p",
                                                this.smi_msg_user, this.smi_targ_id, this.smi_src_id, this.smi_msg_type, this.smi_msg_id), UVM_HIGH)
           if (smi_error_hdr == UNCORR_ECC_ERR) begin
              hdr_uncorr_error++;
           end else if (smi_error_hdr == PARITY_ERR) begin
              hdr_parity_error++;
           end
       end
<% } %>
     endfunction : correct_smi_hdr_error

     function void correct_smi_ndp_error( );
        smi_err_class_t smi_error_ndp;
        smi_ndp_bit_t   corr_dat;

<% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType != "none") { %>
       `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG NDP 3C: msg_type=%0h ndp=%p pld_len=%0d prot=%0h", this.smi_msg_type, this.smi_ndp, this.smi_ndp_len, this.smi_ndp_protection), UVM_DEBUG)
        ndp_corr_error   = 0;
        ndp_uncorr_error = 0;
        ndp_parity_error = 0;
        smi_error_ndp = smi_check_err( this.smi_ndp, get_ndp_len(this.smi_msg_type, 0), get_ndp_len(this.smi_msg_type, 1), corr_dat);
       `uvm_info(get_name(), $psprintf("[RY-DBG-NDP-ECC] before correcting (err: %20s) [addr: 0x%016h]", smi_error_ndp.name(), smi_addr), UVM_NONE);
        if (smi_error_ndp == CORR_ECC_ERR) begin
            `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG NDP 3D: CORRECTED NDP Error: orig:%p new:%p", this.smi_ndp, corr_dat), UVM_HIGH)
             this.smi_ndp = corr_dat;
             ndp_corr_error++;
        end else if ((smi_error_ndp == UNCORR_ECC_ERR) || (smi_error_ndp == PARITY_ERR)) begin
            `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG 3E: UNCORRECTABLE NDP Error (ECC or PARITY): orig:%p new:%p", this.smi_ndp, corr_dat), UVM_HIGH)
            if (smi_error_ndp == UNCORR_ECC_ERR) begin
               ndp_uncorr_error++;
            end else if (smi_error_ndp == PARITY_ERR) begin
               ndp_parity_error++;
            end
        end
       `uvm_info($sformatf("%m"), $sformatf("ECC NDP DEBUG: error_type:%p: prot:%p, targ_id:%p, sr_id:%p, msg_type:%p, msg_id:%p",
                                            smi_error_ndp, this.smi_msg_user, this.smi_targ_id, this.smi_src_id, this.smi_msg_type, this.smi_msg_id), UVM_DEBUG)
<% } %>
     endfunction : correct_smi_ndp_error

     function void correct_smi_dp_error( );
        smi_err_class_t           smi_error_dp, smi_error_dp_eb;
        bit [64-1             :0] dpDataIn      , corr_dpData;
        bit [wSmiDPbundle-1   :0] dpBundleIn    , corr_dpBundle;
        bit [WSMIDPUSERPERDW-1:0] dpUserIn      , corr_dpUser;
        bit [WSMIDPPROTPERDW-1:0] dpProtIn      , corr_dpProc;
        bit [wSmiDPuser     -1:0] dpUserBeatIn  , corr_dpUserBeat;
<% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType != "none") { %>
       if (this.smi_dp_present) begin
           `uvm_info($sformatf("%m"), $sformatf("ECC DP DEBUG 0: prot:%p, targ_id:%p, src_id:%p, msg_type:%p, msg_id:%p", this.smi_msg_user, this.smi_targ_id, this.smi_src_id, this.smi_msg_type, this.smi_msg_id), UVM_DEBUG)
           `uvm_info($sformatf("%m"), $sformatf("ECC DP DEBUG 1: %p", this.convert2string()), UVM_HIGH)
           dp_corr_error   = 0;
           dp_corr_error_eb= 0;
           dp_uncorr_error = 0;
           dp_parity_error = 0;
           for (int i=0; i<this.smi_dp_data.size(); i++) begin
              dpUserBeatIn = this.smi_dp_user[i];
              smi_error_dp = FN_NOERROR;
              smi_error_dp_eb = smi_error_dp;
              for (int j=0; j < wSmiDPdata/64; j++) begin
                  dpUserIn   = userToProtChk(dpUserBeatIn[j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW]);
                  dpDataIn   = this.smi_dp_data[i][j*64 +: 64];
                  dpBundleIn = { dpUserIn[SmiDPUserProtNpM:SmiDPUserProtNpL], dpDataIn, dpUserIn[SmiDPUserDbadNpM:0]};
                  smi_error_dp = smi_check_err(dpBundleIn, wSmiDPbundleNoProt, wSmiDPbundle, corr_dpBundle);
                  if (smi_error_dp == CORR_ECC_ERR) begin
                     corr_dpUser = { corr_dpBundle[wSmiDPbundle-1:wSmiDPbundleNoProt], corr_dpBundle[wSmiDPbundleNoProt-64-1:0] };
                     corr_dpData = corr_dpBundle[wSmiDPbundleNoProt-1:wSmiDPbundleNoProt-64];
                     `uvm_info($sformatf("%m"), $sformatf("ECC DP DEBUG 10: CORR ERROR: Beat%0d DW%0d: BUNDLE (old:%p new:%p) DP_USER (old:%p new:%p) DP_DATA(old:%p new:%p)",
                                                          i, j, dpBundleIn, corr_dpBundle, dpUserIn, corr_dpUser, dpDataIn, corr_dpData), UVM_HIGH)
                     this.smi_dp_data[i][j*64              +: 64             ] = corr_dpData;
                     this.smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = this.userFromProtChk(corr_dpUser);
                     dp_corr_error++;
                     if(smi_error_dp_eb != smi_error_dp) smi_error_dp_eb = smi_error_dp;
                  end else if ((smi_error_dp == UNCORR_ECC_ERR) || (smi_error_dp == PARITY_ERR)) begin
                     if ($test$plusargs("inject_smi_uncorr_error") || $test$plusargs("has_ucerr")) begin
                        `uvm_info($sformatf("%m"), $sformatf("ECC DP DEBUG 11: UNCORRECTABLE DP DATA (ECC or PARITY): Beat%0d DW%0d DP_USER:%p",
                                                             i, j, dpUserIn, dpDataIn), UVM_HIGH)
                     end else begin
                        `uvm_error($sformatf("%m"), $sformatf("ECC DP DEBUG 12: UNCORRECTABLE DP DATA (ECC or PARITY): Beat%0d DW%0d DP_USER:%p DP_DATA:%p; dpIn:%p",
                                                              i, j, dpUserIn, dpDataIn, dpBundleIn))
                     end
                     if (smi_error_dp == UNCORR_ECC_ERR) begin
                         dp_uncorr_error++;
                     end else if (smi_error_dp == PARITY_ERR) begin
                         dp_parity_error++;
                     end
                  end
              end // for (int j=0; j < wSmiDPdata/64; j++)
              if(smi_error_dp_eb == CORR_ECC_ERR) dp_corr_error_eb++;
           end
        end // if (this.smi_dp_present)
<% } %>
     endfunction : correct_smi_dp_error

     function [wSmiDPuser-1:0] userToProtChk (input [wSmiDPuser-1:0] userIn);
        // move protection field to MSBs
        userToProtChk[SmiDPUserBeM    :SmiDPUserBeL    ] = userIn[SmiDPUserBeM  :SmiDPUserBeL  ];
<% if (obj.Widths.Concerto.Dp.Aux.wDPAux > 0) { %>
        userToProtChk[SmiDPUserConcM  :SmiDPUserConcL  ] = userIn[SmiDPUserConcM:SmiDPUserConcL]; <%}%>
        userToProtChk[SmiDPUserDwidNpM:SmiDPUserDwidNpL] = userIn[SmiDPUserDwidM:SmiDPUserDwidL];
        userToProtChk[SmiDPUserDbadNpM:SmiDPUserDbadNpL] = userIn[SmiDPUserDbadM:SmiDPUserDbadL];
<% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType != "none") { %>
        userToProtChk[SmiDPUserProtNpM:SmiDPUserProtNpL] = userIn[SmiDPUserProtM:SmiDPUserProtL]; <%}%>
     endfunction : userToProtChk
                            
     function [wSmiDPuser-1:0] userFromProtChk (input [wSmiDPuser-1:0] userIn);
        // move protection feild from MSBs
        userFromProtChk[SmiDPUserBeM  :SmiDPUserBeL  ] = userIn[SmiDPUserBeM    :SmiDPUserBeL    ];
<% if (obj.Widths.Concerto.Dp.Aux.wDPAux > 0) { %>
        userFromProtChk[SmiDPUserConcM:SmiDPUserConcL] = userIn[SmiDPUserConcM  :SmiDPUserConcL  ]; <%}%>
<% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType != "none") { %>
        userFromProtChk[SmiDPUserProtM:SmiDPUserProtL] = userIn[SmiDPUserProtNpM:SmiDPUserProtNpL]; <%}%>
        userFromProtChk[SmiDPUserDwidM:SmiDPUserDwidL] = userIn[SmiDPUserDwidNpM:SmiDPUserDwidNpL];
        userFromProtChk[SmiDPUserDbadM:SmiDPUserDbadL] = userIn[SmiDPUserDbadNpM:SmiDPUserDbadNpL];
     endfunction : userFromProtChk
   
<% } %>

     function bit update_error_counts(uvm_object rhs);
       smi_seq_item _rhs;
       if(!$cast(_rhs, rhs)) begin
          `uvm_error("update_error_counts", "cast of rhs object failed")
       end
       this.ndp_corr_error   += _rhs.ndp_corr_error;
       this.ndp_uncorr_error += _rhs.ndp_uncorr_error;
       this.ndp_parity_error += _rhs.ndp_parity_error;
       this.hdr_corr_error   += _rhs.hdr_corr_error;
       this.hdr_uncorr_error += _rhs.hdr_uncorr_error;
       this.hdr_parity_error += _rhs.hdr_parity_error;
       this.dp_corr_error    += _rhs.dp_corr_error;
       this.dp_corr_error_eb += _rhs.dp_corr_error_eb;
       this.dp_uncorr_error  += _rhs.dp_uncorr_error;
       this.dp_parity_error  += _rhs.dp_parity_error;
       return ( (_rhs.ndp_corr_error + _rhs.ndp_uncorr_error + _rhs.ndp_parity_error +
                 _rhs.hdr_corr_error + _rhs.hdr_uncorr_error + _rhs.hdr_parity_error +
                 _rhs.dp_corr_error  + _rhs.dp_uncorr_error  + _rhs.dp_parity_error) > 0);
     endfunction : update_error_counts

     function clear_error_counts( );
       this.ndp_corr_error   = 0;
       this.ndp_uncorr_error = 0;
       this.ndp_parity_error = 0;
       this.hdr_corr_error   = 0;
       this.hdr_uncorr_error = 0;
       this.hdr_parity_error = 0;
       this.dp_corr_error    = 0;
       this.dp_corr_error_eb = 0;
       this.dp_uncorr_error  = 0;
       this.dp_parity_error  = 0;
     endfunction : clear_error_counts

	 function get_FunitId_data();
	   <% for(var idx = 0; idx<_ncore_module_name.length; idx++) { %>
	       block_name.push_back("<%=_ncore_module_name[idx]%>");
	       FunitId.push_back(<%=_ncore_module_FunitId[idx]%>);
	       wFunitId.push_back(<%=_ncore_module_FunitId_width[idx]%>);
	       wPortId.push_back(<%=_ncore_module_FportId_width[idx]%>);
	   <% } %>
       //`uvm_info(get_type_name,$sformatf("Size of block_name = %0d,FunitId = %0d, size of wFunitId = %0d, size of FportId = %0d",block_name.size(),FunitId.size(),wFunitId.size(),wPortId.size()),UVM_NONE)
	 endfunction
endclass : smi_seq_item

