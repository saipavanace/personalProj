////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//construct funitid format for dut instantiation and seq stim
//  (magic numbers come from json)
<% 
function capitalize(str) { return (str.charAt(0).toUpperCase() + str.slice(1)) ; } //set the first letter uppercase

var unittypes = ["aiu", "dce", "dve", "dmi", "dii"];
var Funittypes = unittypes.slice(); //copy

	var ace_present = 0;
	var chi_a_present = 0;
	var chi_b_present = 0;
    var chi_e_present = 0;
	var axi_present = 0;
	var acelite_present = 0;
	var acelite_e_present = 0;
	var iocache_present = 0;
        var aiuIds = [];
        var cohIds = [];
        var chiIds = [];   
        obj.AiuInfo.forEach(function(bundle, indx) {
            aiuIds.push(indx);
	    if((bundle.BlockId != obj.BlockId) &&
	       ((bundle.fnNativeInterface == "ACE") ||
	       (bundle.fnNativeInterface == "CHI") ||
	       (bundle.fnNativeInterface == "CHI-A") ||
	       (bundle.fnNativeInterface == "CHI-B") ||
	       (bundle.fnNativeInterface == "CHI-E") ||
	       ((bundle.fnNativeInterface == "AXI4" || bundle.fnNativeInterface == "AXI5") && bundle.useCache))) {
	       cohIds.push(indx);
	       }
	    if((bundle.fnNativeInterface == "CHI") ||
	       (bundle.fnNativeInterface == "CHI-A") ||
	       (bundle.fnNativeInterface == "CHI-E") ||
	       (bundle.fnNativeInterface == "CHI-B")) {
	       chiIds.push(indx);
	    }
        });

	obj.AiuInfo.forEach(function(bundle, idx, array) {
		if (bundle.fnNativeInterface === "ACE") {
			ace_present++;
		}
		if (bundle.fnNativeInterface === "CHI-A") {
			chi_a_present++;
		}	
		if (bundle.fnNativeInterface === "CHI-B") {
			chi_b_present++;
		}
        if (bundle.fnNativeInterface === "CHI-E") {
			chi_e_present++;
		}
		if ((bundle.fnNativeInterface === "AXI4" || bundle.fnNativeInterface === "AXI5") && (bundle.useCache == 1)) {
			iocache_present++;
		}
		if ((bundle.fnNativeInterface === "AXI4") && (bundle.useCache == 0)) {
			axi_present++;
		}
		if ((bundle.fnNativeInterface === "AXI5") && (bundle.useCache == 0)) {
			axi_present++;
		}
		if (bundle.fnNativeInterface === "ACE-LITE") {
			acelite_present++;
		}
		if (bundle.fnNativeInterface === "ACELITE-E") {
			acelite_e_present++;
		}
	})

//dve requires vector of which aius are dvm capable, ordered by NUnitId
// Ncore3.0: nunitid taken to be the index of this aiu within json AiuInfo
const Dvm_NUnitIds = [];
for (const elem of obj.AiuInfo) {
    if(elem.cmpInfo.nDvmSnpInFlight > 0) {
        Dvm_NUnitIds.push(elem.nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

Dvm_NUnitIds.sort((a,b) => a - b);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
const smiObj = obj.smiObj;
function funitids() {
  var arr = [];

  obj.AiuInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });


  obj.DceInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });

  obj.DveInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });

  obj.DmiInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });

  obj.DiiInfo.forEach(function(bundle, indx) {
                arr.push(bundle.FUnitId);
  });

  return arr;
};

function funitids_dce_dmi() {
  var arr = [];


  obj.DceInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });

  obj.DmiInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });

  return arr;
};

%>

`uvm_analysis_imp_decl(_smi)

class smi_coverage extends uvm_component;

    `uvm_component_param_utils(smi_coverage)
    uvm_analysis_imp_smi #(smi_seq_item, smi_coverage) analysis_smi;

    smi_seq_item  m_smi_seq;
    smi_seq_item  m_smi_snp_cov_seq;
    eMsgCMD cmd_type;
   
    int funit_ids[<%=funitids().length%>] = {<%=funitids()%>};

<% if(obj.Block =='chi_aiu') { %>
    parameter qos_width = (WSMIQOS > 0) ? (WSMIQOS-1) : 0; 
    bit [7:0] vld_rdy_delay;
    bit       isMpf3AiuID;
    bit       isStashnidAiuID;
    bit       smi_msg_direction;
    bit       [1:0] rv_rs;
    bit       [1:0] smi_up;
    smi_seq_item  m_smi_snp_seq[$];
    smi_msg_type_bit_t  smi_snp_type;
    bit       [qos_width:0] smi_qos;
<% } %>

<%     if(obj.Block =='dii') { %>
    smi_dp_be_t m_smi_dp_be;
    smi_dp_dwid_t m_smi_dp_dwid;
    smi_dp_protection_t m_smi_dp_protection; 
<% } %>


    // Covergroups for dynamic sized signals
<%     if(obj.Block =='dii') { %>
    covergroup dp_dwid_dtrtype;
        coverpoint m_smi_dp_dwid[2:0];
    endgroup
    covergroup dp_protection_dtrtype;
        <% if (smiObj.WSMIDPPROT_EN) { %>
        coverpoint m_smi_dp_protection {
            bins none = {SMI_DP_PROTECTION_NONE};
            bins parity = {SMI_DP_PROTECTION_PARITY};
        }
        <% } %> 
    endgroup
    covergroup dp_dwid_dtwtype;
        coverpoint m_smi_dp_dwid[2:0];
    endgroup
    covergroup dp_protection_dtwtype;
        <% if (smiObj.WSMIDPPROT_EN) { %>
        coverpoint m_smi_dp_protection {
            bins none = {SMI_DP_PROTECTION_NONE};
            bins parity = {SMI_DP_PROTECTION_PARITY};
        }
        <% } %> 
    endgroup
    //#CoverToggle.DII.CMDreq.Addr
    covergroup dii_smi_addr;
         low_smi_addr: coverpoint m_smi_seq.smi_addr[<%=Math.round(obj.Widths.Concerto.Ndp.Body.wAddr/3-1)%>:0];
         mid_smi_addr :  coverpoint  m_smi_seq.smi_addr[<%=Math.round(obj.Widths.Concerto.Ndp.Body.wAddr*2/3-1)%>:<%=Math.round(obj.Widths.Concerto.Ndp.Body.wAddr/3)%>];
         high_smi_addr: coverpoint m_smi_seq.smi_addr[<%=Math.round(obj.Widths.Concerto.Ndp.Body.wAddr-1)%>:<%=Math.round(obj.Widths.Concerto.Ndp.Body.wAddr*2/3)%>];
    endgroup
	
<% } %>

    covergroup smi_transaction_type;

    
	<% if (obj.Block == 'dmi') { %>
	    // #Cover.DMI.Concerto.v3.0.MrdReqDceunitId
        mrd_dce_unit_id:coverpoint m_smi_seq.smi_src_ncore_unit_id iff (m_smi_seq.isMrdMsg()){
        <% for (i=0; i<obj.DceInfo.length;i++) { %>
            bins unit_id<%=i%> = {<%=obj.DceInfo[i].FUnitId%>};
        <% } %>
        }

        // #Cover.DMI.Concerto.v3.0.MrdMsgType
            mrd_type:coverpoint m_smi_seq.smi_msg_type iff (m_smi_seq.isMrdMsg())
            {
                bins mrd_rd_with_shr_cln    = {MRD_RD_WITH_SHR_CLN};
                bins mrd_rd_with_unq_cln    = {MRD_RD_WITH_UNQ_CLN};
                bins mrd_rd_with_unq        = {MRD_RD_WITH_UNQ};
                bins mrd_rd_with_inv        = {MRD_RD_WITH_INV};
                bins mrd_cln                = {MRD_CLN};
                bins mrd_inv                = {MRD_INV};
                bins mrd_flush              = {MRD_FLUSH};
            }
    
        // #Cover.DMI.Concerto.v3.0.Mrdmsgid
            mrd_msg_id:coverpoint m_smi_seq.smi_msg_id iff (m_smi_seq.isMrdMsg());

        <% if (obj.Block == 'dmi' && obj.DmiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType != "none") { %>
        // #Cover.DMI.Concerto.v3.0.ReqHProt
           mrd_h_protection:coverpoint m_smi_seq.smi_msg_user iff (m_smi_seq.isMrdMsg()){
                type_option.goal = 50;
           }
        <% } %>

        // #Cover.DMI.Concerto.v3.0.MrdReqAddrMinMidMax
            mrd_address: coverpoint m_smi_seq.smi_addr iff (m_smi_seq.isMrdMsg()) {
			  bins low_values  = {[0                                                                            : 64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))/3-1))%>]};	
			  bins mid_values  = {[64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))/3))%>	    : 64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))*2/3-1))%>]};	
			  bins high_values = {[64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))*2/3))%>                  : 64'd<%=((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))-1)%>]};	
        }

        // #Cover.DMI.Concerto.v3.0.MrdReqAddrOffset
            mrd_addr_aligned:coverpoint m_smi_seq.smi_addr[5:0] iff (m_smi_seq.isMrdMsg());
    
        // #Cover.DMI.Concerto.v3.0.MrdReqallocate
            mrd_allocate_hint:coverpoint m_smi_seq.smi_ac iff (m_smi_seq.isMrdMsg());
        // #Cover.DMI.Concerto.v3.0.MrdSecurityAttribute
            mrd_security_attribute:coverpoint m_smi_seq.smi_ns iff (m_smi_seq.isMrdMsg());
        // #Cover.DMI.Concerto.v3.0.MrdReqprivilege
            mrd_req_privilege:coverpoint m_smi_seq.smi_pr iff (m_smi_seq.isMrdMsg());
        // #Cover.DMI.Concerto.v3.0.MrdRqTM
            mrd_trace_me:coverpoint m_smi_seq.smi_tm iff (m_smi_seq.isMrdMsg());
        
    // #Cover.DMI.Concerto.v3.MrdReqAiUIds
        mrd_MPF1: coverpoint m_smi_seq.smi_mpf1_dtr_tgt_id iff (m_smi_seq.isMrdMsg()){
        <% for(i=0; i<obj.AiuInfo.length;i++) { %>
            bins aiu_<%=i%>     = {<%=obj.AiuInfo[i].FUnitId%>};
        <% } %>
        }
    // #Cover.DMI.Concerto.v3.3.MaxDtrlnFlightperAius
        mrd_MPF2: coverpoint m_smi_seq.smi_mpf2_dtr_msg_id iff (m_smi_seq.isMrdMsg()){
            <% for(var i=0; i<(Math.pow(2,smiObj.WSMIMSGID)); i++) { %>
                bins msg_id_<%=i%> = {<%=i%>};
            <% } %>
        }

    // #Cover.DMI.Concerto.v3.0.MrdReqsize
       mrd_size: coverpoint m_smi_seq.smi_size iff (m_smi_seq.isMrdMsg()){
            bins size[] = {[0:6]};
        }

    // #Cover.DMI.Concerto.v3.0.MrdReqQos
    <% if(obj.DmiInfo[obj.Id].fnEnableQos == 1) { %>
        mrd_qos: coverpoint m_smi_seq.smi_qos iff (m_smi_seq.isMrdMsg());
    <% } %>

    // #Cover.DMI.Concerto.v3.0.RxTxncmStatus
     <% if (obj.Block != 'dmi') { %>
        mrd_cmstatus : coverpoint m_smi_seq.smi_cmstatus iff (m_smi_seq.isMrdMsg()) {
            type_option.goal = 0;
            type_option.weight = 0;
        }
    <% } %>
    <% } %>

    <% if (obj.Block == 'dmi') { %>
	    // #Cover.DMI.Concerto.v3.0.RbReqDceunitId
        rb_req_dce_unit_id:coverpoint m_smi_seq.smi_src_ncore_unit_id iff (m_smi_seq.isRbMsg()){
        <% for (i=0; i<obj.DceInfo.length;i++) { %>
            bins unit_id<%=i%> = {<%=obj.DceInfo[i].FUnitId%>};
        <% } %>
        }
        // #Cover.DMI.Concerto.v3.0.RbReqType
        rb_req_type:coverpoint m_smi_seq.smi_msg_type iff (m_smi_seq.isRbMsg()){
            bins rb_req = {RB_REQ}; 
        }
        // #Cover.DMI.Concerto.v3.0.RbReqInflight
        rb_req_msg_id:coverpoint m_smi_seq.smi_msg_id iff (m_smi_seq.isRbMsg());

        // #Cover.DMI.Concerto.v3.0.ReqHProt
        <% if (obj.Block == 'dmi' && obj.DmiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType != "none") { %>
           rb_req_h_protection:coverpoint m_smi_seq.smi_msg_user iff (m_smi_seq.isRbMsg()){
                type_option.goal = 50;
           }
        <% } %>

        // #Cover.DMI.Concerto.v3.0.RbReq_RbId
        rb_req_id : coverpoint m_smi_seq.smi_rbid iff (m_smi_seq.isRbMsg()){
        <% for(var i=0;i<obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries; i++) { %>
            bins rbid_<%=i%> = {<%=i%>};  
        <% } %>
        }
       
        // #Cover.DMI.Concerto.v3.0.RbReqRType
        //rb_req_reqtype : coverpoint m_smi_seq.smi_rtype iff (m_smi_seq.isRbMsg()); Depreceated with removal of RBUse

        // #Cover.DMI.Concerto.v3.0.RbReqAddrMinMidMax
        rb_req_addr: coverpoint m_smi_seq.smi_addr iff (m_smi_seq.isRbMsg()) {
			  bins low_values  = {[0                                                                            : 64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))/3-1))%>]};	
			  bins mid_values  = {[64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))/3))%>	    : 64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))*2/3-1))%>]};	
			  bins high_values = {[64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))*2/3))%>                  : 64'd<%=((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))-1)%>]};	
        }        
    
        // #Cover.DMI.Concerto.v3.0.RbReqAddrOffset
        rb_req_addr_5_0 : coverpoint m_smi_seq.smi_addr[5:0] iff (m_smi_seq.isRbMsg());

        // #Cover.DMI.Concerto.v3.0.RbReqsize
        rb_req_size : coverpoint m_smi_seq.smi_size iff (m_smi_seq.isRbMsg()){
            bins size[] = {[0:6]};
        }
        // #Cover.DMI.Concerto.v3.0.RbReqvisibility
        rb_req_vz : coverpoint m_smi_seq.smi_vz iff (m_smi_seq.isRbMsg());
        // #Cover.DMI.Concerto.v3.0.RbReqcacheability
        rb_req_ca : coverpoint m_smi_seq.smi_ca iff (m_smi_seq.isRbMsg());
        // #Cover.DMI.Concerto.v3.0.RbReqallocate
        rb_req_ac : coverpoint m_smi_seq.smi_ac iff (m_smi_seq.isRbMsg());
        // #Cover.DMI.Concerto.v3.0.RbReqsecurity
        rb_req_ns : coverpoint m_smi_seq.smi_ns iff (m_smi_seq.isRbMsg());
        // #Cover.DMI.Concerto.v3.0.RbReqprivilege
        rb_req_pr : coverpoint m_smi_seq.smi_pr iff (m_smi_seq.isRbMsg());
        // #Cover.DMI.Concerto.v3.0.RbreqMW
        rb_req_mw : coverpoint m_smi_seq.smi_mw iff (m_smi_seq.isRbMsg());
        // #Cover.DMI.Concerto.v3.0.RbReqRL
        rb_req_rl : coverpoint m_smi_seq.smi_rl iff (m_smi_seq.isRbMsg()){
            bins reserving = {1,2};
            bins releasing = {2};
        }
        // #Cover.DMI.Concerto.v3.0.RbReqMpf1
        rb_req_mpf1 : coverpoint m_smi_seq.smi_mpf1 iff (m_smi_seq.isRbMsg());
        // #Cover.DMI.Concerto.v3.0.RbReqTof
        rb_req_tof: coverpoint m_smi_seq.smi_tof iff (m_smi_seq.isRbMsg());
        // #Cover.DMI.Concerto.v3.0.RbReqQos
        <% if(obj.DmiInfo[obj.Id].fnEnableQos == 1) { %>
        rb_req_qos: coverpoint m_smi_seq.smi_qos iff (m_smi_seq.isRbMsg());
        <% } %>
        <% if(obj.Widths.Concerto.Ndp.Body.wNdpAux > 0) { %>
        // #Cover.DMI.Concerto.v3.0.RbReqAux
        rb_req_aux: coverpoint m_smi_seq.smi_ndp_aux iff (m_smi_seq.isRbMsg());
        <% } %>
        // #Cover.DMI.Concerto.v3.0.RbReqCmstatus 
        <% if (obj.Block != 'dmi') { %>
        rb_req_cmstatus : coverpoint m_smi_seq.smi_cmstatus iff (m_smi_seq.isRbMsg()){
            type_option.goal = 0;
            type_option.weight = 0;
        }
        // #Cover.DMI.Concerto.v3.0.RbRspCmstatus 
        rb_rsp_cmstatus : coverpoint m_smi_seq.smi_cmstatus iff (m_smi_seq.isRbRspMsg()){
            type_option.goal = 0;
            type_option.weight = 0;
        }
	<% } %>

	<% } %>

    <% if (obj.Block == 'dmi') { %>
        // #Cover.DMI.Concerto.v3.0.DtwReqAiuUnitId
        dtw_req_aiu_unit_id:coverpoint m_smi_seq.smi_src_ncore_unit_id iff (m_smi_seq.isDtwMsg()){
        <% for (i=0; i<obj.AiuInfo.length;i++) { %>
            bins unit_id<%=i%> = {<%=obj.AiuInfo[i].FUnitId%>};
        <% } %>
        }
        // #Cover.DMI.Concerto.v3.0.DtwReqType
        dtw_req_reqtype:coverpoint m_smi_seq.smi_msg_type
        {
            bins dtwnodata      = {DTW_NO_DATA};
            bins dtwdatacln     = {DTW_DATA_CLN};
            bins dtwdatadty     = {DTW_DATA_DTY};
            bins dtwdataptl     = {DTW_DATA_PTL};
            bins dtwmrgmrd_inv  = {DTW_MRG_MRD_INV};
            bins dtwmrgmrd_ucln = {DTW_MRG_MRD_UCLN};
            bins dtwmrgmrd_udty = {DTW_MRG_MRD_UDTY};
        }

        // #Cover.DMI.Concerto.v3.0.DtwReqMessageId
        dtw_req_msg_id:coverpoint m_smi_seq.smi_msg_id iff (m_smi_seq.isDtwMsg());

        <% if (obj.Block == 'dmi' && obj.DmiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType != "none") { %>
        // #Cover.DMI.Concerto.v3.0.ReqHProt
           dtw_req_h_protection:coverpoint m_smi_seq.smi_msg_user iff (m_smi_seq.isDtwMsg());
        <% } %>
        
        // #Cover.DMI.Concerto.v3.0.DtwReqRb
        dtw_req_rbid:coverpoint m_smi_seq.smi_rbid iff (m_smi_seq.isDtwMsg()){
        <% for(var i=0; i<(obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries+obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries);i++) { %>
            bins rbid_<%=i%> = {<%=i%>};
        <% } %>
        }

        // #Cover.DMI.Concerto.v3.0.DtwReqPrim
        dtw_req_prim:coverpoint m_smi_seq.smi_prim iff (m_smi_seq.isDtwMsg()){
            bins secondary_data = {0};
            bins primary_data   = {1};
        }

        // #Cover.DMI.Concerto.v3.0.DtwReqMpf1
        dtw_req_mpf1:coverpoint m_smi_seq.smi_mpf1 iff (m_smi_seq.isDtwMsg() && (m_smi_seq.smi_msg_type inside {DTW_MRG_MRD_INV, DTW_MRG_MRD_SCLN, DTW_MRG_MRD_SDTY, DTW_MRG_MRD_UCLN, DTW_MRG_MRD_UDTY})){
    <% for (i=0; i<obj.AiuInfo.length;i++) { %>
            bins unit_id<%=i%> = {<%=obj.AiuInfo[i].FUnitId%>};
    <% } %>
    }
        // #Cover.DMI.Concerto.v3.0.DtwReqMpf2
        dtw_req_mpf2:coverpoint m_smi_seq.smi_mpf2 iff (m_smi_seq.isDtwMsg() && (m_smi_seq.smi_msg_type inside {DTW_MRG_MRD_INV, DTW_MRG_MRD_SCLN, DTW_MRG_MRD_SDTY, DTW_MRG_MRD_UCLN, DTW_MRG_MRD_UDTY})){
    <% for (i=0; i<Math.pow(2,obj.Widths.Concerto.Ndp.Header.wMsgId); i++) { %>
            bins msgid_<%=i%> = {<%=i%>};
    <% } %>
    }
        // #Cover.DMI.Concerto.v3.0.DtwReqIntfSize
        dtw_req_intfsize:coverpoint m_smi_seq.smi_intfsize  iff (m_smi_seq.isDtwMsg() && (m_smi_seq.smi_msg_type inside {DTW_MRG_MRD_INV, DTW_MRG_MRD_SCLN, DTW_MRG_MRD_SDTY, DTW_MRG_MRD_UCLN, DTW_MRG_MRD_UDTY})) {
            bins valid_size[] = {[0:2]};
        }
        // #Cover.DMI.Concerto.v3.0.DTWRspspCmstatus
        dtw_rsp_cmstatus:coverpoint m_smi_seq.smi_cmstatus iff (m_smi_seq.isDtwRspMsg()){
            bins cmstatus_1000_0011 = {8'b1000_0011};
            bins cmstatus_1000_0100 = {8'b1000_0100};
            bins cmstatus_1000_0001 = {8'b0000_0001};
        }

        // #Cover.DMI.Concerto.v3.0.CMDRspCMStatus
        cmd_rsp_cmstatus:coverpoint m_smi_seq.smi_cmstatus iff (m_smi_seq.isCCmdRspMsg() || m_smi_seq.isNcCmdRspMsg()){
            bins cmstatus_1000_0011 = {8'b1000_0011};
            bins cmstatus_1000_0100 = {8'b1000_0100};
            bins cmstatus_1000_0001 = {8'b0000_0001};
        }
       
        //#Cover.DMI.Concerto.v3.0.MrdRspCMStatus
        mrd_rsp_cmstatus:coverpoint m_smi_seq.smi_cmstatus iff (m_smi_seq.isMrdRspMsg()){
            bins cmstatus_1000_0011 = {8'b1000_0011};
            bins cmstatus_1000_0100 = {8'b1000_0100};
            bins cmstatus_1000_0001 = {8'b0000_0001};
        }

        //#Cover.DMI.Concerto.v3.0.DtwRspRL
        dtwrsp_rl : coverpoint m_smi_seq.smi_rl iff (m_smi_seq.isDtwMsg()){
                bins protocol_lvl_comp = {2'b10};
                bins transport_lvl_ack = {2'b01};
        }
    <% } %>

    <% if(obj.Block == 'dmi') { %>
       // #Cover.DMI.Concerto.v3.0.AiuUnitId 
            cmdreq_aiu_unit_id : coverpoint m_smi_seq.smi_src_ncore_unit_id iff (m_smi_seq.isCmdMsg()){
        <% for (i=0; i<obj.AiuInfo.length;i++) { %>
            bins unit_id<%=i%> = {<%=obj.AiuInfo[i].FUnitId%>};
        <% } %>
        }
            // #Cover.DMI.Concerto.v3.0.CmdReqType
            cmdreq_msg_type : coverpoint m_smi_seq.smi_msg_type iff (m_smi_seq.isCmdMsg()){
                bins cmdrdnc        = {CMD_RD_NC};
                bins cmdwrncptl     = {CMD_WR_NC_PTL};
                bins cmdwrncfull    = {CMD_WR_NC_FULL};
                bins cmdpref        = {CMD_PREF};
                bins cmdclninv      = {CMD_CLN_INV};
                bins cmdclnvld      = {CMD_CLN_VLD};
                bins cmdmkinv       = {CMD_MK_INV};
            }
            
            // #Cover.DMI.Concerto.v3.0.maxNcCmdInflight
            cmdreq_msg_id : coverpoint m_smi_seq.smi_msg_id iff (m_smi_seq.isCmdMsg());
            <% if (obj.Block != 'dmi') { %>
            // #Cover.DMI.Concerto.v3.0.CmdReqCmStatus
            cmdreq_cmstatus : coverpoint m_smi_seq.smi_cmstatus iff (m_smi_seq.isCmdMsg()){
                type_option.weight = 0;
                type_option.goal = 0;
            }
            <% } %>
        // #Cover.DMI.Concerto.v3.0.CmdReqAddrMinMidMax
         cmdreq_address: coverpoint m_smi_seq.smi_addr iff (m_smi_seq.isCmdMsg()) {
			  bins low_values  = {[0                                                                            : 64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))/3-1))%>]};	
			  bins mid_values  = {[64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))/3))%>	    : 64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))*2/3-1))%>]};	
			  bins high_values = {[64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))*2/3))%>                  : 64'd<%=((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))-1)%>]};	
        }   
        // #Cover.DMI.Concerto.v3.0.CmdReqAddrOffset 
            cmdreq_addr : coverpoint m_smi_seq.smi_addr[5:0] iff (m_smi_seq.isCmdMsg());
       // #Cover.DMI.Concerto.v3.0.CmdReqvisibility     
            cmdreq_vz : coverpoint m_smi_seq.smi_vz iff (m_smi_seq.isCmdMsg());
       // #Cover.DMI.Concerto.v3.0.CmdReqCacheable
            cmdreq_ca : coverpoint m_smi_seq.smi_ca iff (m_smi_seq.isCmdMsg());
      // #Cover.DMI.Concerto.v3.0.CmdReqallocate      
            cmdreq_ac : coverpoint m_smi_seq.smi_ac iff (m_smi_seq.isCmdMsg());
      // #Cover.DMI.Concerto.v3.0.CmdReqAc_Ca1
            cmdreq_ac_ca : coverpoint m_smi_seq.smi_ac iff (m_smi_seq.isCmdMsg() && m_smi_seq.smi_ca== 1);
      // #Cover.DMI.Concerto.v3.0.CmdReqStoragetype
            cmdreq_st : coverpoint m_smi_seq.smi_st iff (m_smi_seq.isCmdMsg());
      // #Cover.DMI.Concerto.v3.0.CmdReqEndianess
            cmdreq_en : coverpoint m_smi_seq.smi_en iff (m_smi_seq.isCmdMsg()) {
                bins little_endian = {0};
            }
     // #Cover.DMI.Concerto.v3.0.CmdReqExclusive
            cmdreq_es : coverpoint m_smi_seq.smi_es iff (m_smi_seq.isCmdMsg());
    // #Cover.DMI.Concerto.v3.0.CmdReqsecurity
            cmdreq_ns : coverpoint m_smi_seq.smi_ns iff (m_smi_seq.isCmdMsg());
    // #Cover.DMI.Concerto.v3.0.CmdReqprivilege
            cmdreq_pr : coverpoint m_smi_seq.smi_pr iff (m_smi_seq.isCmdMsg());
    // #Cover.DMI.Concerto.v3.0.CmdReqOR
            cmdreq_order : coverpoint m_smi_seq.smi_order iff (m_smi_seq.isCmdMsg());
    // #Cover.DMI.Concerto.v3.0.CmdReqlock
            cmdreq_lk : coverpoint m_smi_seq.smi_lk iff (m_smi_seq.isCmdMsg()){
                bins no_op      = {0};
                bins lock       = {1};
                bins unlock     = {2};
                bins reserved   = {3};
            }   
    // #Cover.DMI.Concerto.v3.0.CmdReqRL
            cmdreq_rl : coverpoint m_smi_seq.smi_rl iff (m_smi_seq.isCmdMsg()){
                bins protocol_lvl_comp = {2'b10};
                bins transport_lvl_ack = {2'b01};
            }
    // #Cover.DMI.Concerto.v3.0.CmdReqTM
            cmdreq_tm : coverpoint m_smi_seq.smi_tm iff (m_smi_seq.isCmdMsg()){
                bins no_op = {0};
                bins trace = {1};
            }
    // #Cover.DMI.Concerto.v3.0.CmdReqsize
            cmdreq_size : coverpoint m_smi_seq.smi_size iff (m_smi_seq.isCmdMsg()){
                bins size[]             = {[0:6]};
            }
    // #Cover.DMI.Concerto.v3.0.CmdReqIntfSize
            cmdreq_intfsize : coverpoint m_smi_seq.smi_intfsize iff (m_smi_seq.isCmdMsg()){
                bins size[]             = {[0:2]};
            }
    // #Cover.DMI.Concerto.v3.0.CmdReqDid_6
            cmdreq_did : coverpoint m_smi_seq.smi_dest_id iff (m_smi_seq.isCmdMsg());
    // #Cover.DMI.Concerto.v3.0.CmdReqTOF
            cmdreq_tof : coverpoint m_smi_seq.smi_tof iff (m_smi_seq.isCmdMsg());

    // #Cover.DMI.Concerto.v3.0.CmdReqQos 
    <% if(obj.DmiInfo[obj.Id].fnEnableQos == 1) { %>
            cmdreq_qos : coverpoint m_smi_seq.smi_qos iff (m_smi_seq.isCmdMsg());
    <% } %>
    // #Cover.DMI.Concerto.v3.0.CmdReqAux
            <% if(obj.Widths.Concerto.Ndp.Body.wNdpAux > 0) { %>
            cmdreq_aux : coverpoint m_smi_seq.smi_ndp_aux iff (m_smi_seq.isCmdMsg());
            <% } %>
    <% } %>

    <% if(obj.Block == 'dmi') { %>
            
            // #Cover.DMI.Concerto.v3.0.AIUunitId

            nc_strrsp_aiu_unit_id :coverpoint m_smi_seq.smi_src_ncore_unit_id iff (m_smi_seq.isStrRspMsg()){
        <% for (i=0; i<obj.AiuInfo.length;i++) { %>
            bins unit_id<%=i%> = {<%=obj.AiuInfo[i].FUnitId%>};
        <% } %>
        }

            // #Cover.DMI.Concerto.v3.0.STRrspType

            nc_strrsp_cmtype : coverpoint m_smi_seq.smi_msg_type iff (m_smi_seq.isStrRspMsg()){
                    bins strrsp = {STR_RSP};
            }
            // #Cover.DMI.Concerto.v3.0.STRrspMessageid
            nc_strrsp_msg_id : coverpoint m_smi_seq.smi_msg_id iff (m_smi_seq.isStrRspMsg());

    <% } %>

    <% if(obj.Block == 'dmi' && obj.DmiInfo[obj.Id].useAtomic) { %>

            // #Cover.DMI.Concerto.v3.0.AtomicType
            atomic_cmtype : coverpoint m_smi_seq.smi_msg_type iff (m_smi_seq.isCmdAtmStoreMsg() || m_smi_seq.isCmdAtmLoadMsg()){
                bins cmdrdatm   = {CMD_RD_ATM};
                bins cmdwratm   = {CMD_WR_ATM};
                bins cmdswatm   = {CMD_SW_ATM};
                bins cmdcmpatm  = {CMD_CMP_ATM};
            }
           
            // #Cover.DMI.Concerto.v3.0.AtomicAddrMinMidMax
            atomic_address: coverpoint m_smi_seq.smi_addr iff (m_smi_seq.isCmdAtmStoreMsg() || m_smi_seq.isCmdAtmLoadMsg()) {
			  bins low_values  = {[0                                                                            : 64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))/3-1))%>]};	
			  bins mid_values  = {[64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))/3))%>	    : 64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))*2/3-1))%>]};	
			  bins high_values = {[64'd<%=Math.round(((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))*2/3))%>                  : 64'd<%=((Math.pow(2,obj.Widths.Concerto.Ndp.Body.wAddr))-1)%>]};	
        }
            // #Cover.DMI.Concerto.v3.0.AtomicAddrOffset
            atomic_addr : coverpoint m_smi_seq.smi_addr[5:0] iff (m_smi_seq.isCmdAtmStoreMsg() || m_smi_seq.isCmdAtmLoadMsg());

            // #Cover.DMI.Concerto.v3.0.Atomicvisibility
            atomic_vz : coverpoint m_smi_seq.smi_vz iff (m_smi_seq.isCmdAtmStoreMsg() || m_smi_seq.isCmdAtmLoadMsg()){
                bins vz_0 = {0};
                illegal_bins not_valid = {1};
            }
            //#Cover.DMI.Concerto.v3.0.AtomicST
            atomic_st : coverpoint m_smi_seq.smi_st iff (m_smi_seq.isCmdAtmStoreMsg() || m_smi_seq.isCmdAtmLoadMsg()){
                bins st_0 = {0};
                illegal_bins not_valid = {1};
            }
            //#Cover.DMI.Concerto.v3.0.AtomicArgV
            atomic_mpf1 : coverpoint m_smi_seq.smi_mpf1_argv iff (m_smi_seq.isCmdAtmStoreMsg() || m_smi_seq.isCmdAtmLoadMsg()){
                bins argv[] = {[0:7]};
            }
            // #Cover.DMI.Concerto.v3.0.Atomic_size
            atomic_size_cmdatmcmp : coverpoint m_smi_seq.smi_size iff ((m_smi_seq.isCmdAtmStoreMsg() || m_smi_seq.isCmdAtmLoadMsg())&& m_smi_seq.smi_msg_type == CMD_CMP_ATM){
                bins size_2     = {1};
                bins size_4     = {2};
                bins size_8     = {3};
                bins size_16    = {4};
                bins size_32    = {5};
            }
            atomic_size : coverpoint m_smi_seq.smi_size iff (m_smi_seq.isCmdAtmStoreMsg() || m_smi_seq.isCmdAtmLoadMsg()){
                bins size_1     = {0};
                bins size_2     = {1};
                bins size_4     = {2};
                bins size_5     = {3};
            }
            //#Cover.DMI.Concerto.v3.0.AtomicStoreLoadArv
            AtomicStoreLoadArv : cross atomic_cmtype, atomic_mpf1;

            atomic_intfsize : coverpoint m_smi_seq.smi_intfsize iff (m_smi_seq.isCmdAtmStoreMsg() || m_smi_seq.isCmdAtmLoadMsg()){
                bins intfsize_0 = {0};
                bins intfsize_1 = {1};
                bins intfsize_2 = {2};
            }

            atomiccross_size_intfsize_0 : cross atomic_cmtype, atomic_intfsize, atomic_size_cmdatmcmp{
                ignore_bins ignore_cmtype_0 = binsof(atomic_cmtype) intersect {CMD_RD_ATM, CMD_WR_ATM, CMD_SW_ATM};
            }
            atomiccross_size_intfsize_1 : cross atomic_cmtype, atomic_intfsize, atomic_size{
                ignore_bins ignore_cmtype_1 = binsof(atomic_cmtype) intersect {CMD_CMP_ATM};
            }
    <% } %>

	<% if(obj.Block =='dii') { %>
        // coverpoint on smi_msg_type for DII
	    str_type: coverpoint m_smi_seq.smi_msg_type
	    {
	        bins str_state           = {STR_STATE};
	    }
            dtr_type: coverpoint m_smi_seq.smi_msg_type
            {
                bins dtr_data_inv        = {DTR_DATA_INV};
            }

            critical_data_beat : coverpoint m_smi_seq.smi_addr[5:3];

            // Cover.DII.DTWreq.Msg_type
	    dtw_type: coverpoint m_smi_seq.smi_msg_type
	    {
	        bins dtw_data_ptl        = {DTW_DATA_PTL};
                <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
	           bins dtw_data_cln        = {DTW_DATA_CLN};
	           bins dtw_data_dty        = {DTW_DATA_DTY};
                <% } %>
	    }
        //#Cover.DII.CMDreq.Msg_type
	    cmd_type: coverpoint m_smi_seq.smi_msg_type
	    {
                bins cmd_rd_nc           = {CMD_RD_NC};
                bins cmd_wr_nc_ptl       = {CMD_WR_NC_PTL};
                <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
                    bins cmd_wr_nc_full      = {CMD_WR_NC_FULL};
                <% } %>
	    }

            c_dtw_dbg_rsp: coverpoint m_smi_seq.smi_msg_type
            {
               bins dtw_dbg_msg = {DTW_DBG_RSP};
            }
             
            //#Cover.DII.CMDreq.Cache_Maintenance_type
            <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
	        cache_maintenance_type: coverpoint m_smi_seq.smi_msg_type
	        {
                    bins cmd_cln_vld          = {CMD_CLN_VLD};
                    bins cmd_cln_sh_per       = {CMD_CLN_SH_PER};
                    bins cmd_cln_inv          = {CMD_CLN_INV};
                    bins cmd_mk_inv           = {CMD_MK_INV};
	        }
            <% } %> 
	<% } %>

        <% if (obj.Block =='dce') { %>
            mrd_type:coverpoint m_smi_seq.smi_msg_type
            {
                bins mrd_rd_with_shr_cln = {MRD_RD_WITH_SHR_CLN};
                bins mrd_rd_with_unq_cln = {MRD_RD_WITH_UNQ_CLN};
                bins mrd_rd_with_unq     = {MRD_RD_WITH_UNQ};
                bins mrd_rd_with_inv     = {MRD_RD_WITH_INV};
                bins mrd_flush           = {MRD_FLUSH};
            }
        <% } %>       

        <% if((obj.Block =='dmi') || (obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
            dtr_type: coverpoint m_smi_seq.smi_msg_type
            {
                bins dtr_data_inv        = {DTR_DATA_INV};
                bins dtr_data_shr_cln    = {DTR_DATA_SHR_CLN};
        <% if(obj.Block !=='dmi') { %>
                bins dtr_data_shr_dty    = {DTR_DATA_SHR_DTY};
	    <% } %>
                bins dtr_data_unq_cln    = {DTR_DATA_UNQ_CLN};
                bins dtr_data_unq_dty    = {DTR_DATA_UNQ_DTY};
        <% if(obj.Block =='dmi') { %>
                illegal_bins dtr_data_shr_dty    = {DTR_DATA_SHR_DTY};
	    <% } %>

             }
	<% } %>

	<% if((obj.Block =='dmi') || (obj.Block =='dce') || (obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
	str_type: coverpoint m_smi_seq.smi_msg_type
	{
		bins str_state           = {STR_STATE};
	}
	<% } %>

        // This set of coverpoints are expected to be hit in every
        // Ncore blocks with the exception of the two that are
        // mentioned below... (CONC-8386)
	<% if((obj.Block !=='dce') && (obj.Block !=='dve')) { %>
	dtw_dbg_type: coverpoint m_smi_seq.smi_msg_type
	{
                bins dtw_dbg_msg_req     = {DTW_DBG_REQ};
                bins dtw_dbg_msg_rsp     = {DTW_DBG_RSP};
	}
	<% } %>

	<% if((obj.Block =='dmi') || (obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
	dtw_type: coverpoint m_smi_seq.smi_msg_type
	{
		bins dtw_no_data         = {DTW_NO_DATA};
		bins dtw_data_cln        = {DTW_DATA_CLN};
		bins dtw_data_ptl        = {DTW_DATA_PTL};
		bins dtw_data_dty        = {DTW_DATA_DTY};
		bins dtw_mrg_mrd_inv     = {DTW_MRG_MRD_INV};
		bins dtw_mrg_mrd_ucln    = {DTW_MRG_MRD_UCLN};
		bins dtw_mrg_mrd_udty    = {DTW_MRG_MRD_UDTY};
      <% if(obj.Block !=='dmi') { %>

        <%if(obj.testBench == "chi_aiu") { %>
		ignore_bins dtw_mrg_mrd_scln    = {DTW_MRG_MRD_SCLN};
		ignore_bins dtw_mrg_mrd_sdty    = {DTW_MRG_MRD_SDTY};
	 <% }else{ %>
		bins dtw_mrg_mrd_scln    = {DTW_MRG_MRD_SCLN};
		bins dtw_mrg_mrd_sdty    = {DTW_MRG_MRD_SDTY};
	 <% } %>
	  <% }else{ %>
        illegal_bins not_valid_dtwMrgMrd  = {DTW_MRG_MRD_SCLN,DTW_MRG_MRD_SDTY};
	  <% } %>
	}
	<% } %>

   
	<%     if(obj.Block =='dce') { %>
	upd_type: coverpoint m_smi_seq.smi_msg_type
	{
		bins upd_rsp             = {UPD_RSP};
		bins upd_inv             = {UPD_INV};
	}
	<% } %>

	<%     if((obj.Block =='dmi') || (obj.Block =='dce')){ %>
	rb_rsp_type: coverpoint m_smi_seq.smi_msg_type
	{
		bins rb_rsp              = {RB_RSP};
	}
	<% } %>

	<%     if((obj.Block =='dmi') || (obj.Block =='dce') || (obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
	cmd_type: coverpoint m_smi_seq.smi_msg_type
	{
      <% if(obj.Block !=='dmi') { %>
    	       bins cmd_rd_cln           = {CMD_RD_CLN};
             <% if((obj.Block =='chi_aiu') && (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A')) { %>
               ignore_bins cmd_rd_not_shd       = {CMD_RD_NOT_SHD};
             <% } else { %>
               bins cmd_rd_not_shd       = {CMD_RD_NOT_SHD};
	     <% } %>
               bins cmd_rd_vld           = {CMD_RD_VLD};
               bins cmd_rd_unq           = {CMD_RD_UNQ};
               bins cmd_cln_unq          = {CMD_CLN_UNQ};
               bins cmd_mk_unq           = {CMD_MK_UNQ};
               bins cmd_rd_nitc          = {CMD_RD_NITC};
      <% if(obj.Block !=='dce') { %>
               bins cmd_dvm_msg          = {CMD_DVM_MSG};
	  <% } %>
	  <% } %>
               bins cmd_cln_vld          = {CMD_CLN_VLD};
               bins cmd_cln_inv          = {CMD_CLN_INV};
               bins cmd_mk_inv           = {CMD_MK_INV};
      <% if(obj.Block !=='dce') { %>
               bins cmd_rd_nc            = {CMD_RD_NC};
	  <% } %>
      <% if(obj.Block !=='dmi') { %>
               bins cmd_wr_unq_ptl       = {CMD_WR_UNQ_PTL};
               bins cmd_wr_unq_full      = {CMD_WR_UNQ_FULL};
	  <% } %>
	  <% if(obj.Block !='dmi') { %>
             <% if((obj.Block =='chi_aiu') && (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A')) { %>
               ignore_bins cmd_wr_atm           = {CMD_WR_ATM};
               ignore_bins cmd_rd_atm           = {CMD_RD_ATM};
               ignore_bins cmd_sw_atm           = {CMD_SW_ATM};
               ignore_bins cmd_cmp_atm          = {CMD_CMP_ATM};
             <% } else { %>
               bins cmd_wr_atm           = {CMD_WR_ATM};
               bins cmd_rd_atm           = {CMD_RD_ATM};
               bins cmd_sw_atm           = {CMD_SW_ATM};
               bins cmd_cmp_atm          = {CMD_CMP_ATM};
             <% } %>
	  <% }else if(obj.Block =='dmi' &&  obj.DmiInfo[obj.Id].useAtomic) { %>
               bins cmd_wr_atm           = {CMD_WR_ATM};
               bins cmd_rd_atm           = {CMD_RD_ATM};
               bins cmd_sw_atm           = {CMD_SW_ATM};
               bins cmd_cmp_atm          = {CMD_CMP_ATM};
	  <% } %>
      <% if(obj.Block !=='dce') { %>
             <% if((obj.Block =='chi_aiu') && (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A')) { %>
               ignore_bins cmd_pref             = {CMD_PREF};
             <% } else { %>
               bins cmd_pref             = {CMD_PREF};
	     <% } %>
               bins cmd_wr_nc_ptl        = {CMD_WR_NC_PTL};
               bins cmd_wr_nc_full       = {CMD_WR_NC_FULL};
	  <% } %>
      <% if(obj.Block !=='dmi') { %>
               bins cmd_wr_bk_full       = {CMD_WR_BK_FULL};
               bins cmd_wr_cln_full      = {CMD_WR_CLN_FULL};
               bins cmd_wr_evict         = {CMD_WR_EVICT};
               bins cmd_evict            = {CMD_EVICT};
               bins cmd_wr_bk_ptl        = {CMD_WR_BK_PTL};
             <% if((obj.Block =='chi_aiu') && (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A')) { %>
               ignore_bins cmd_wr_cln_ptl     = {CMD_WR_CLN_PTL};
             <% } else { %>
               bins cmd_wr_cln_ptl            = {CMD_WR_CLN_PTL};
	     <% } %>
             <% if((obj.Block =='chi_aiu') && (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A')) { %>
               ignore_bins cmd_wr_stsh_ptl      = {CMD_WR_STSH_PTL};
               ignore_bins cmd_wr_stsh_full     = {CMD_WR_STSH_FULL};
               ignore_bins cmd_ld_cch_sh        = {CMD_LD_CCH_SH};
               ignore_bins cmd_ld_cch_unq       = {CMD_LD_CCH_UNQ};
               ignore_bins cmd_rd_nitc_cln_inv  = {CMD_RD_NITC_CLN_INV};
               ignore_bins cmd_rd_nitc_mk_inv   = {CMD_RD_NITC_MK_INV};
               ignore_bins cmd_cln_sh_per       = {CMD_CLN_SH_PER};
             <% } else { %>
              <% if((obj.Block =='chi_aiu')) { %>
               ignore_bins cmd_wr_stsh_ptl      = {CMD_WR_STSH_PTL};
               ignore_bins cmd_wr_stsh_full     = {CMD_WR_STSH_FULL};
              <% } else { %>
               bins cmd_wr_stsh_ptl      = {CMD_WR_STSH_PTL};
               bins cmd_wr_stsh_full     = {CMD_WR_STSH_FULL};
	      <% } %>
               bins cmd_ld_cch_sh        = {CMD_LD_CCH_SH};
               bins cmd_ld_cch_unq       = {CMD_LD_CCH_UNQ};
               bins cmd_rd_nitc_cln_inv  = {CMD_RD_NITC_CLN_INV};
               bins cmd_rd_nitc_mk_inv   = {CMD_RD_NITC_MK_INV};
               bins cmd_cln_sh_per       = {CMD_CLN_SH_PER};
             <% } %>

	 <% }
	if(obj.Block ==='dce') {
		if(chi_a_present == 0){%>
		ignore_bins ignore_cmd_wr_cln_ptl 	= {CMD_WR_CLN_PTL};
		<%}
		if(chi_b_present == 0){%>
		ignore_bins ignore_cmd_wr_cln_full 	= {CMD_WR_CLN_FULL};
		<%}
		if(acelite_e_present == 0){ %>
		ignore_bins ignore_cmd_wr_stsh_ptl	= {CMD_WR_STSH_PTL};
                ignore_bins ignore_cmd_wr_stsh_full    = {CMD_WR_STSH_FULL};
		<%}
		if(chi_b_present == 0 && acelite_e_present == 0){ %>
               	ignore_bins ignore_cmd_ld_cch_sh        = {CMD_LD_CCH_SH};
               	ignore_bins ignore_cmd_ld_cch_unq       = {CMD_LD_CCH_UNQ};
		<%}
	} %>
	}
	<% } %>
	 
	<%     if((obj.Block =='dce') || (obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
	snp_type: coverpoint m_smi_seq.smi_msg_type
	{
	       bins snp_cln_dtr          = {SNP_CLN_DTR};
               bins snp_nitc             = {SNP_NITC};
               bins snp_vld_dtr          = {SNP_VLD_DTR};
               bins snp_inv_dtr          = {SNP_INV_DTR};
               bins snp_inv_dtw          = {SNP_INV_DTW};
               bins snp_inv              = {SNP_INV};
               bins snp_cln_dtw          = {SNP_CLN_DTW};
      <% if(obj.Block !=='dce') { %>
              <% if((obj.Block =='chi_aiu')) { %>
               ignore_bins snp_recall           = {SNP_RECALL};
              <% } else { %>
               bins snp_recall           = {SNP_RECALL};
	      <% } %>
	  <% } %>
               bins snp_nosdint          = {SNP_NOSDINT};
             <% if((obj.Block =='chi_aiu') && (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A')) { %>
               ignore_bins snp_inv_stsh         = {SNP_INV_STSH};
               ignore_bins snp_unq_stsh         = {SNP_UNQ_STSH};
               ignore_bins snp_stsh_sh          = {SNP_STSH_SH};
               ignore_bins snp_stsh_unq         = {SNP_STSH_UNQ};
             <% } else { %>
               bins snp_inv_stsh         = {SNP_INV_STSH};
               bins snp_unq_stsh         = {SNP_UNQ_STSH};
               bins snp_stsh_sh          = {SNP_STSH_SH};
               bins snp_stsh_unq         = {SNP_STSH_UNQ};
	     <% } %>
      <% if(obj.Block !=='dce') { %>
               bins snp_dvm_msg          = {SNP_DVM_MSG};
	  <% } %>
               bins snp_nitcci           = {SNP_NITCCI};
               bins snp_nitcmi           = {SNP_NITCMI};
        <%if(obj.Block ==='dce') {
		if(chi_b_present == 0){ %>
               ignore_bins ignore_snp_stsh_sh          = {SNP_STSH_SH};
               ignore_bins ignore_snp_stsh_unq         = {SNP_STSH_UNQ};
		<%}
	     if(acelite_e_present == 0 || chi_b_present == 0){ %>
               ignore_bins ignore_snp_inv_stsh         = {SNP_INV_STSH};
               ignore_bins ignore_snp_unq_stsh         = {SNP_UNQ_STSH};
		<%}
		if(obj.DceInfo[0].nCachingAgents == 1) { %>
		ignore_bins ignore_snp_vld_dtr		= {SNP_VLD_DTR};
		ignore_bins ignore_snp_inv_dtr		= {SNP_INV_DTR};
		ignore_bins ignore_snp_nosdint		= {SNP_NOSDINT};
		ignore_bins ignore_snp_cln_dtr		= {SNP_CLN_DTR};
		
		<% }
	}%>
         }
	 <% } %>


	<%     if(obj.Block =='dve') { %>
	    cmd_type: coverpoint m_smi_seq.smi_msg_type
	    {
                bins cmd_dvm_msg           = {CMD_DVM_MSG};
            }
	    str_type: coverpoint m_smi_seq.smi_msg_type
	    {
		bins str_state           = {STR_STATE};
            }
	    dtw_type: coverpoint m_smi_seq.smi_msg_type
	    {
		bins dtw_data_cln        = {DTW_DATA_CLN};
            }
	    snp_type: coverpoint m_smi_seq.smi_msg_type
	    {
               bins snp_dvm_msg          = {SNP_DVM_MSG};
            } 
<% if(Dvm_NUnitIds.length > 0) { %>
    	    src_ncore_unit_id: coverpoint m_smi_seq.smi_src_ncore_unit_id
            {
	       bins src_unit_id          = { 
    <% for( j=(Dvm_NUnitIds.length - 1) ; j >= 0 ; j-- ) {     //0th entry is rightmost in array decl %>
        <%=smiObj.WNUNITID%>'d<%=Dvm_NUnitIds[j]%><% if (j != 0) { %>,<% } %>
    <% } %>                                };
	    }
    	    targ_ncore_unit_id: coverpoint m_smi_seq.smi_targ_ncore_unit_id
            {
	       bins targ_unit_id         = { 
    <% for( j=(Dvm_NUnitIds.length - 1) ; j >= 0 ; j-- ) {     //0th entry is rightmost in array decl %>
        <%=smiObj.WNUNITID%>'d<%=Dvm_NUnitIds[j]%><% if (j != 0) { %>,<% } %>
    <% } %>                                };
	    }
	    src_id: coverpoint m_smi_seq.smi_src_id
            {
	       bins src_id_dve           = {
    <% for( j=(Dvm_NUnitIds.length - 1) ; j >= 0 ; j-- ) {     //0th entry is rightmost in array decl %>
        <%=smiObj.WNUNITID%>'d<%=Dvm_NUnitIds[j]%><% if (j != 0) { %>,<% } %>
    <% } %>                                };
	    }
	    targ_id: coverpoint m_smi_seq.smi_targ_id
            {
	       bins targ_id_dve          = {
    <% for( j=(Dvm_NUnitIds.length - 1) ; j >= 0 ; j-- ) {     //0th entry is rightmost in array decl %>
        <%=smiObj.WNUNITID%>'d<%=Dvm_NUnitIds[j]%><% if (j != 0) { %>,<% } %>
    <% } %>                                };
	    }
<% } else { %>
    	    src_ncore_unit_id: coverpoint m_smi_seq.smi_src_ncore_unit_id;
    	    targ_ncore_unit_id: coverpoint m_smi_seq.smi_targ_ncore_unit_id;
	    targ_id: coverpoint m_smi_seq.smi_targ_id;
	    src_id: coverpoint m_smi_seq.smi_src_id;
<% } %>				       
	    src_ncore_port_id: coverpoint m_smi_seq.smi_src_ncore_port_id
	    {
	       bins src_port_id_dve = { 'd0, 'd1 };
	    }
	    targ_ncore_port_id: coverpoint m_smi_seq.smi_targ_ncore_port_id
	    {
	       bins targ_port_id_dve = { 'd0, 'd1 };
	    }
	    conc_msg_class: coverpoint m_smi_seq.smi_conc_msg_class
            {
               bins conc_msg_class_dve = { eConcMsgCmdReq, eConcMsgNcCmdRsp, eConcMsgSnpReq, eConcMsgSnpRsp, eConcMsgStrReq, eConcMsgStrRsp, eConcMsgDtwReq, eConcMsgDtwRsp, eConcMsgCmpRsp };
	    }
    	    cmstatus: coverpoint m_smi_seq.smi_cmstatus
	    {
	       bins cmstatus_dve = { 0 };
	    }
            addr_part_num: coverpoint m_smi_seq.smi_addr[3];
            addr_va_valid: coverpoint m_smi_seq.smi_addr[4];
            addr_vmid_valid: coverpoint m_smi_seq.smi_addr[5];
            addr_asid_valid: coverpoint m_smi_seq.smi_addr[6];
            addr_sec: coverpoint m_smi_seq.smi_addr[8:7];
            addr_excep: coverpoint m_smi_seq.smi_addr[10:9];
            addr_dvmop: coverpoint m_smi_seq.smi_addr[13:11];
            addr_vmid: coverpoint m_smi_seq.smi_addr[21:14];
            //addr_asid: coverpoint m_smi_seq.smi_addr[37:22];
            //addr_s1s2: coverpoint m_smi_seq.smi_addr[39:38];
            //addr_leaf_entry_inval: coverpoint m_smi_seq.smi_addr[40];
            //addr_va: coverpoint m_smi_seq.smi_addr[43:41];
	    //msg_valid: coverpoint m_smi_seq.smi_msg_valid;
	    //msg_ready: coverpoint m_smi_seq.smi_msg_ready;
            //ndp_len: coverpoint m_smi_seq.smi_ndp_len;
    	    lock: coverpoint m_smi_seq.smi_lk;
	    rmsg_id: coverpoint m_smi_seq.smi_rmsg_id;
	    steer: coverpoint m_smi_seq.smi_steer;
	    tier: coverpoint m_smi_seq.smi_msg_tier;
    	    qos: coverpoint m_smi_seq.smi_msg_qos;
    	    pri: coverpoint m_smi_seq.smi_msg_pri;
    	    msg_id: coverpoint m_smi_seq.smi_msg_id;
    	    msg_err: coverpoint m_smi_seq.smi_msg_err;
    	    dp_present: coverpoint m_smi_seq.smi_dp_present;
    	    dp_valid: coverpoint m_smi_seq.smi_dp_valid;
	    dp_ready: coverpoint m_smi_seq.smi_dp_ready;
	    dp_last: coverpoint m_smi_seq.smi_dp_last;
	<% } %>

	<% if((obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
        // SMI FIELDS FOR CHIAIU ONLY
         smi_valid_ready_delay: coverpoint vld_rdy_delay {

           bins delay_0_63            = {['h0:'h3F]};
           bins delay_64_127          = {['h40:'h7F]};
           bins delay_128_191         = {['h80:'hBF]};
           bins delay_192_255         = {['hC0:'hFF]};

}
    	 exclusive: coverpoint m_smi_seq.smi_es;
         coherent_access: coverpoint m_smi_seq.smi_ch;
	<% if(obj.Block =='chi_aiu') { %>
    	 quality_of_service: coverpoint smi_qos;
        <% } else { %>
    	 quality_of_service: coverpoint m_smi_seq.smi_qos;
	<% } %>
         unique_precense_provider: coverpoint m_smi_seq.smi_up {
           illegal_bins smi_up_rsvd = {2};
          }
	 <% } %>

	<% if(obj.Block == 'dce') {
   	
	 if(obj.Block.fnEnableQos == 1){%>	
    	//#Cover.DCE.CmdReq.Qos
    	cmdreq_quality_of_service: coverpoint m_smi_seq.smi_qos iff (m_smi_seq.isCmdMsg());

	<%}%>
    	
    	//#Cover.DCE.CmdReq.MsgId
    	cmdreq_msg_id			 : coverpoint m_smi_seq.smi_msg_id iff (m_smi_seq.isCmdMsg()) {
			  bins low_values  = {[0                  : ((2**WSMIMSGID)/3) - 1]};	
			  bins mid_values  = {[(2**WSMIMSGID)/3	  : ((2**WSMIMSGID)*2/3) - 1]};	
			  bins high_values = {[(2**WSMIMSGID)*2/3 : (2**WSMIMSGID-1)]};	
    	}
	
    	//#Cover.DCE.CmdReq.Addr
        cmdreq_address: coverpoint m_smi_seq.smi_addr iff (m_smi_seq.isCmdMsg());
		//	  bins low_values  = {[0                  : ((2**WSMIADDR)/3) - 1]};	
		//	  bins mid_values  = {[(2**WSMIADDR)/3	  : ((2**WSMIADDR)*2/3) - 1]};	
		//	  bins high_values = {[(2**WSMIADDR)*2/3 : (2**WSMIADDR-1)]}; 	
        //}
       
       	//#Cover.DCE.UpdReq_Addr
        updreq_address: coverpoint m_smi_seq.smi_addr iff (m_smi_seq.isUpdMsg());
	//		  bins low_values  = {[0                  : ((2**WSMIADDR)/3) - 1]};	
	//		  bins mid_values  = {[(2**WSMIADDR)/3	  : ((2**WSMIADDR)*2/3) - 1]};	
	//		  bins high_values = {[(2**WSMIADDR)*2/3 : (2**WSMIADDR-1)]};	
        //}

    	//#Cover.DCE.CmdReq.BlockOffsetAddr
        cmdreq_blockoffset_address: coverpoint m_smi_seq.smi_addr & (2**ncoreConfigInfo::WCACHE_OFFSET-1) iff (m_smi_seq.isCmdMsg()) {
            <% for(var i = 0; i < 2**obj.wCacheLineOffset; i++) { %>
			  bins block_offset_address_<%=i%> = {<%=i%>};
		   <% } %>
		}
		//#Cover.DCE.CmdReq.NonSecure
         cmdreq_nonsecure: coverpoint m_smi_seq.smi_ns iff (m_smi_seq.isCmdMsg());
		
		 //#Cover.DCE.UpdReq.NonSecure
         updreq_nonsecure: coverpoint m_smi_seq.smi_ns iff (m_smi_seq.isUpdMsg());
		
		//#Cover.DCE.CmdReq.Visibility
         cmdreq_visibility: coverpoint m_smi_seq.smi_vz iff (m_smi_seq.isCmdMsg());
         
		//#Cover.DCE.CmdReq.Cacheability
         cmdreq_cacheability: coverpoint m_smi_seq.smi_ca iff (m_smi_seq.isCmdMsg());

		 //#Cover.DCE.CmdReq.AllocationHint
         cmdreq_allocate_hint: coverpoint m_smi_seq.smi_ac iff (m_smi_seq.isCmdMsg());
         
		 //#Cover.DCE.CmdReq.Endianness
         cmdreq_endianness: coverpoint m_smi_seq.smi_en iff (m_smi_seq.isCmdMsg());

         //#Cover.DCE.CmdReq.ExclusiveOps_ES 
         cmdreq_exc_ops_es: coverpoint m_smi_seq.smi_es iff (m_smi_seq.isCmdMsg() && (m_smi_seq.smi_msg_type inside {CMD_RD_CLN, CMD_RD_VLD, CMD_RD_NOT_SHD, CMD_CLN_UNQ}));
        
         //#Cover.DCE.CmdReq.AtomicOps_SS 
         cmdreq_atomic_ops_es: coverpoint m_smi_seq.smi_es iff (m_smi_seq.isCmdMsg() && (m_smi_seq.smi_msg_type inside {CMD_WR_ATM, CMD_RD_ATM, CMD_SW_ATM, CMD_CMP_ATM}));
         
         //#Cover.DCE.CmdReq.PrivilegedAccess
         cmdreq_privileged_access: coverpoint m_smi_seq.smi_pr iff (m_smi_seq.isCmdMsg());
         
         //#Cover.DCE.CmdReq.Order
         cmdreq_order: coverpoint m_smi_seq.smi_order iff (m_smi_seq.isCmdMsg());

         //#Cover.DCE.CmdReq.Linelocking
    	 cmdreq_lock: coverpoint m_smi_seq.smi_lk iff (m_smi_seq.isCmdMsg());
         
         //#Cover.DCE.CmdReq.TraceMe
    	 cmdreq_traceme: coverpoint m_smi_seq.smi_tm iff (m_smi_seq.isCmdMsg());

         //#Cover.DCE.CmdReq.IntfSize
		 cmdreq_interface_size: coverpoint m_smi_seq.smi_intfsize iff (m_smi_seq.isCmdMsg());
         
         //#Cover.DCE.CmdReq.Size
		 cmdreq_size: coverpoint m_smi_seq.smi_intfsize iff (m_smi_seq.isCmdMsg()) {
	     	illegal_bins not_valid_seize = {7};
		 }
         
	<%if(obj.Block =='dce') {%>
         //#Cover.DCE.CmdReq.DId
        cmdreq_dest_id: coverpoint m_smi_seq.smi_dest_id iff (m_smi_seq.isCmdMsg()) {
    	<%	obj.DceInfo[0].hexDceConnectedDmiFunitId.forEach(function(bundle) { %>
			bins dmi_funitid_<%=bundle%> = {<%=bundle%>};
		<%})%>
		}
	<%}
	else {%>
        cmdreq_dest_id: coverpoint m_smi_seq.smi_dest_id iff (m_smi_seq.isCmdMsg()) {
    	<%	obj.DmiInfo.forEach(function(bundle) { %>
			bins dmi_funitid_<%=bundle.FUnitId%> = {<%=bundle.FUnitId%>};
		<%})%>
		}
         <%}%>
        //#Cover.DCE.CmdReq.NDProt
         <% if (smiObj.WSMINDPPROT_EN) { %>
    	cmdreq_ndprot: coverpoint m_smi_seq.smi_ndp_protection iff (m_smi_seq.isCmdMsg());
         <% } %>
    	
    	 //#Cover.DCE.SnpReq.UP
    	 snpreq_up: coverpoint m_smi_seq.smi_up iff (m_smi_seq.isSnpMsg()){
        	<%if(obj.Block ==='dce') { 
			if(obj.DceInfo[0].nCachingAgents == 1) {%>
		ignore_bins up_00 = {0};
		ignore_bins up_10 = {2};
		ignore_bins up_11 = {3};
			<%}
			else {%>
		ignore_bins up_00 = {0};
		ignore_bins up_10 = {2};
			<%}
		}%>
		}	

	<% } %>


	<% if((obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
        // SMI FIELDS FOR CHIAIU AND DII
         visibility: coverpoint m_smi_seq.smi_vz;
    	 transaction_odering_framework: coverpoint m_smi_seq.smi_tof {
             bins smi_tof_chi = {SMI_TOF_CHI};
             bins smi_tof_axi = {SMI_TOF_AXI};
             bins smi_tof_ace = {SMI_TOF_ACE};
         }
         allocate: coverpoint m_smi_seq.smi_ac;
         cacheable: coverpoint m_smi_seq.smi_ca;
         storage_type: coverpoint m_smi_seq.smi_st;
         non_secure_access: coverpoint m_smi_seq.smi_ns;
         privilege: coverpoint m_smi_seq.smi_pr;

         order: coverpoint m_smi_seq.smi_order {
             bins none = {SMI_ORDER_NONE};
             bins endpoint = {SMI_ORDER_ENDPOINT};
             bins request_wr_obs = {SMI_ORDER_REQUEST_WR_OBS};
         }

    	 response_level: coverpoint m_smi_seq.smi_rl {
             bins transport = {SMI_RL_TRANSPORT};
             bins coherency = {SMI_RL_COHERENCY};
         }
    	 trace_me: coverpoint m_smi_seq.smi_tm;
	 <% } %>

         <% if(obj.Block =='dii') { %>
        // DII - Similar coverpoints like the CHIAIU and AIU above, but needs a guard for sys_dii which is not present in AIUs and hence duplicated
         visibility: coverpoint m_smi_seq.smi_vz;
    	 transaction_odering_framework: coverpoint m_smi_seq.smi_tof {
             bins smi_tof_chi = {SMI_TOF_CHI};
             bins smi_tof_axi = {SMI_TOF_AXI};
             bins smi_tof_ace = {SMI_TOF_ACE};
         }
         allocate: coverpoint m_smi_seq.smi_ac {
             bins no_cache_line_allocate = {0};
             <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
                 bins cache_line_allocate = {1};
	     <% } %>
         }
         cacheable: coverpoint m_smi_seq.smi_ca{
             bins non_cacheable = {0};
             <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
                 bins cachable = {1};
	     <% } %>
         }
         storage_type: coverpoint m_smi_seq.smi_st;
         non_secure_access: coverpoint m_smi_seq.smi_ns;
         privilege: coverpoint m_smi_seq.smi_pr;

         order: coverpoint m_smi_seq.smi_order {
             bins none = {SMI_ORDER_NONE};
             bins endpoint = {SMI_ORDER_ENDPOINT};
             <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
                 bins request_wr_obs = {SMI_ORDER_REQUEST_WR_OBS};
	     <% } %>
         }

    	 response_level: coverpoint m_smi_seq.smi_rl {
             bins transport = {SMI_RL_TRANSPORT};
             bins coherency = {SMI_RL_COHERENCY};
         }
         trace_me: coverpoint m_smi_seq.smi_tm;
        
         endianness : coverpoint m_smi_seq.smi_en {
                bins little_endian = {0};
                bins big_endian = {1};

        }
        exclusive: coverpoint m_smi_seq.smi_es;
	 <% } %>

	<% if(obj.Block != 'dve' && obj.Block != 'dce' && obj.Block != 'dii') { %>
	 access_size: coverpoint m_smi_seq.smi_size iff (!((m_smi_seq.ndp_uncorr_error) || (m_smi_seq.hdr_uncorr_error) || (m_smi_seq.dp_uncorr_error) || (m_smi_seq.ndp_parity_error) || (m_smi_seq.hdr_parity_error) || (m_smi_seq.dp_parity_error))){
             bins bytes_4  = {2};
             bins bytes_1  = {0};
             bins bytes_2  = {1};
             bins bytes_8  = {3};
             bins bytes_16 = {4};
             bins bytes_32 = {5};
             bins bytes_64 = {6};
	     illegal_bins not_valid_size = {7};
	 }
        <% } %>

        <% if(obj.Block == 'dii') { %>
	 access_size: coverpoint m_smi_seq.smi_size iff (!((m_smi_seq.ndp_uncorr_error) || (m_smi_seq.hdr_uncorr_error) || (m_smi_seq.dp_uncorr_error) || (m_smi_seq.ndp_parity_error) || (m_smi_seq.hdr_parity_error) || (m_smi_seq.dp_parity_error))){
             bins bytes_4  = {2};
             <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
                 bins bytes_1  = {0};
                 bins bytes_2  = {1};
                 bins bytes_8  = {3};
                 bins bytes_16 = {4};
                 bins bytes_32 = {5};
                 bins bytes_64 = {6};
	         illegal_bins not_valid_size = {7};
             <% } %>
	     }
        <% } %>

	<% if((obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
         // dtr type generated and received (rest of the msg can only be generated or received)
         dtr_type_received_and_generated: cross dtr_type, smi_msg_direction;
         // smi fields cross Cmd msg type
	<% if(obj.Block =='chi_aiu') { %>
         cmd_type_cross_visibility: cross cmd_type, visibility {
            illegal_bins CMD_RD_CLN_VZ              = binsof(cmd_type) intersect {CMD_RD_CLN} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_RD_NITC_VZ             = binsof(cmd_type) intersect {CMD_RD_NITC} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_RD_VLD_VZ              = binsof(cmd_type) intersect {CMD_RD_VLD} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_RD_UNQ_VZ              = binsof(cmd_type) intersect {CMD_RD_UNQ} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_CLN_UNQ_VZ             = binsof(cmd_type) intersect {CMD_CLN_UNQ} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_MK_UNQ_VZ              = binsof(cmd_type) intersect {CMD_MK_UNQ} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_EVICT_VZ               = binsof(cmd_type) intersect {CMD_EVICT} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_DVM_MSG_VZ             = binsof(cmd_type) intersect {CMD_DVM_MSG} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_WR_EVICT_VZ            = binsof(cmd_type) intersect {CMD_WR_EVICT} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_WR_CLN_PTL_VZ          = binsof(cmd_type) intersect {CMD_WR_CLN_PTL} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_WR_CLN_FULL_VZ         = binsof(cmd_type) intersect {CMD_WR_CLN_FULL} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_WR_UNQ_PTLT_VZ         = binsof(cmd_type) intersect {CMD_WR_UNQ_PTL} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_WR_UNQ_FULL_VZ         = binsof(cmd_type) intersect {CMD_WR_UNQ_FULL} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_WR_BK_PTL_VZ           = binsof(cmd_type) intersect {CMD_WR_BK_PTL} && binsof (visibility) intersect {'h1};
            illegal_bins CMD_WR_BK_FULL_VZ          = binsof(cmd_type) intersect {CMD_WR_BK_FULL} && binsof (visibility) intersect {'h1};

            illegal_bins CMD_MK_INV_VZ             = binsof(cmd_type) intersect {CMD_MK_INV} &&  binsof(visibility) intersect {0};
            illegal_bins CMD_CLN_INV_VZ            = binsof(cmd_type) intersect {CMD_CLN_INV} &&  binsof(visibility) intersect {0};
            illegal_bins CMD_CLN_VLD_VZ            = binsof(cmd_type) intersect {CMD_CLN_VLD} &&  binsof(visibility) intersect {0};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins CMD_RD_NOT_VZ             = binsof(cmd_type) intersect {CMD_RD_NOT_SHD} && binsof(visibility) intersect {'h1};
            illegal_bins CMD_RD_NITC_CLN_INV_VZ    = binsof(cmd_type) intersect {CMD_RD_NITC_CLN_INV} && binsof(visibility) intersect {'h1};
            illegal_bins CMD_RD_NITC_MK_INV_VZ     = binsof(cmd_type) intersect {CMD_RD_NITC_MK_INV} && binsof(visibility) intersect {'h1};
            illegal_bins CMD_LD_CCH_SH_VZ          = binsof(cmd_type) intersect {CMD_LD_CCH_SH} && binsof(visibility) intersect {'h1};
            illegal_bins CMD_LD_CCH_UNQ_VZ         = binsof(cmd_type) intersect {CMD_LD_CCH_UNQ} && binsof(visibility) intersect {'h1};
            illegal_bins CMD_CMP_ATM_VZ            = binsof(cmd_type) intersect {CMD_CMP_ATM} && binsof(visibility) intersect {'h1};
            illegal_bins CMD_RD_ATM_VZ             = binsof(cmd_type) intersect {CMD_RD_ATM} && binsof(visibility) intersect {'h1};
            illegal_bins CMD_WR_ATM_VZ             = binsof(cmd_type) intersect {CMD_WR_ATM} && binsof(visibility) intersect {'h1};
            illegal_bins CMD_SW_ATM_VZ             = binsof(cmd_type) intersect {CMD_SW_ATM} && binsof(visibility) intersect {'h1};
            illegal_bins CMD_PREF_VZ               = binsof(cmd_type) intersect {CMD_PREF} &&  binsof(visibility) intersect {1};
            illegal_bins CMD_CLN_SH_PER_VZ         = binsof(cmd_type) intersect {CMD_CLN_SH_PER} &&  binsof(visibility) intersect {0};
        <% } %>

}
        <% } else { %>
         cmd_type_cross_visibility: cross cmd_type, visibility;
        <% } %>
	<% if(obj.Block =='chi_aiu') { %>
         cmd_type_cross_allocate: cross cmd_type, allocate {
            illegal_bins CMD_EVICT_ALLOCATE              = binsof(cmd_type) intersect {CMD_EVICT} && binsof (allocate) intersect {'h1};
            illegal_bins CMD_DVM_MSG_ALLOCATE            = binsof(cmd_type) intersect {CMD_DVM_MSG} && binsof (allocate) intersect {'h1};

            illegal_bins CMD_WR_EVICT_ALLOCATE           = binsof(cmd_type) intersect {CMD_WR_EVICT} && binsof (allocate) intersect {'h0};


        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins CMD_RD_NITC_MK_INV_ALLOCATE     = binsof(cmd_type) intersect {CMD_RD_NITC_MK_INV} && binsof(allocate) intersect {'h1};
            illegal_bins CMD_CMP_ATM_ALLOCATE            = binsof(cmd_type) intersect {CMD_CMP_ATM} && binsof(allocate) intersect {0};
            illegal_bins CMD_RD_ATM_ALLOCATE             = binsof(cmd_type) intersect {CMD_RD_ATM} &&  binsof(allocate) intersect {0};
            illegal_bins CMD_WR_ATM_ALLOCATE             = binsof(cmd_type) intersect {CMD_WR_ATM} &&  binsof(allocate) intersect {0};
            illegal_bins CMD_SW_ATM_ALLOCATE             = binsof(cmd_type) intersect {CMD_SW_ATM} &&  binsof(allocate) intersect {0};
            illegal_bins CMD_PREF_ALLOCATE               = binsof(cmd_type) intersect {CMD_PREF} &&  binsof(allocate) intersect {0};
        <% } %>

         }
        <% } else { %>
         cmd_type_cross_allocate: cross cmd_type, allocate;
        <% } %>
	<% if(obj.Block =='chi_aiu') { %>
         cmd_type_cross_cacheable: cross cmd_type, cacheable {
            illegal_bins CMD_RD_CLN_CACHEABLE            = binsof(cmd_type) intersect {CMD_RD_CLN} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_RD_NITC_CACHEABLE            = binsof(cmd_type) intersect {CMD_RD_NITC} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_RD_VLD_CACHEABLE             = binsof(cmd_type) intersect {CMD_RD_VLD} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_RD_UNQ_CACHEABLE             = binsof(cmd_type) intersect {CMD_RD_UNQ} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_CLN_UNQ_CACHEABLE            = binsof(cmd_type) intersect {CMD_CLN_UNQ} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_MK_UNQ_CACHEABLE             = binsof(cmd_type) intersect {CMD_MK_UNQ} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_EVICT_CACHEABLE              = binsof(cmd_type) intersect {CMD_EVICT} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_WR_EVICT_CACHEABLE           = binsof(cmd_type) intersect {CMD_WR_EVICT} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_WR_CLN_PTL_CACHEABLE         = binsof(cmd_type) intersect {CMD_WR_CLN_PTL} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_WR_CLN_FULL_CACHEABLE        = binsof(cmd_type) intersect {CMD_WR_CLN_FULL} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_WR_UNQ_PTL_CACHEABLE         = binsof(cmd_type) intersect {CMD_WR_UNQ_PTL} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_WR_UNQ_FULL_CACHEABLE        = binsof(cmd_type) intersect {CMD_WR_UNQ_FULL} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_WR_BK_PTL_CACHEABLE          = binsof(cmd_type) intersect {CMD_WR_BK_PTL} && binsof (cacheable) intersect {'h0};
            illegal_bins CMD_WR_BK_FULL_CACHEABLE         = binsof(cmd_type) intersect {CMD_WR_BK_FULL} && binsof (cacheable) intersect {'h0};

            illegal_bins CMD_DVM_MSG_CACHEABLE            = binsof(cmd_type) intersect {CMD_DVM_MSG} && binsof (cacheable) intersect {'h1};


        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins CMD_RD_NOT_CACHEABLE             = binsof(cmd_type) intersect {CMD_RD_NOT_SHD} && binsof(cacheable) intersect {'h0};
            illegal_bins CMD_RD_NITC_CLN_INV_CACHEABLE    = binsof(cmd_type) intersect {CMD_RD_NITC_CLN_INV} && binsof(cacheable) intersect {'h0};
            illegal_bins CMD_RD_NITC_MK_INV_CACHEABLE     = binsof(cmd_type) intersect {CMD_RD_NITC_MK_INV} && binsof(cacheable) intersect {'h0};
            illegal_bins CMD_LD_CCH_SH_CACHEABLE          = binsof(cmd_type) intersect {CMD_LD_CCH_SH} && binsof(cacheable) intersect {'h0};
            illegal_bins CMD_LD_CCH_UNQ_CACHEABLE         = binsof(cmd_type) intersect {CMD_LD_CCH_UNQ} && binsof(cacheable) intersect {'h0};

            illegal_bins CMD_CMP_ATM_CACHEABLE            = binsof(cmd_type) intersect {CMD_CMP_ATM} && binsof(cacheable) intersect {0};
            illegal_bins CMD_RD_ATM_CACHEABLE             = binsof(cmd_type) intersect {CMD_RD_ATM} &&  binsof(cacheable) intersect {0};
            illegal_bins CMD_WR_ATM_CACHEABLE             = binsof(cmd_type) intersect {CMD_WR_ATM} &&  binsof(cacheable) intersect {0};
            illegal_bins CMD_SW_ATM_CACHEABLE             = binsof(cmd_type) intersect {CMD_SW_ATM} &&  binsof(cacheable) intersect {0};
            illegal_bins CMD_PREF_CACHEABLE               = binsof(cmd_type) intersect {CMD_PREF} &&  binsof(cacheable) intersect {0};
        <% } %>
        }
      
        <% } else { %>
         cmd_type_cross_cacheable: cross cmd_type, cacheable;
        <% } %>
	<% if(obj.Block =='chi_aiu') { %>
         cmd_type_cross_coherent_access: cross cmd_type, coherent_access {
            illegal_bins CMD_RD_CLN_CH            = binsof(cmd_type) intersect {CMD_RD_CLN} && binsof (coherent_access) intersect {'h0};
            illegal_bins CMD_RD_VLD_CH            = binsof(cmd_type) intersect {CMD_RD_VLD} && binsof (coherent_access) intersect {'h0};
            illegal_bins CMD_RD_NITC_CH           = binsof(cmd_type) intersect {CMD_RD_NITC} && binsof (coherent_access) intersect {'h0};
            illegal_bins CMD_RD_UNQ_CH            = binsof(cmd_type) intersect {CMD_RD_UNQ} && binsof (coherent_access) intersect {'h0};
            illegal_bins CMD_CLN_UNQ_CH           = binsof(cmd_type) intersect {CMD_CLN_UNQ} && binsof (coherent_access) intersect {'h0};
            illegal_bins CMD_MK_UNQ_CH            = binsof(cmd_type) intersect {CMD_MK_UNQ} && binsof (coherent_access) intersect {'h0};
            illegal_bins CMD_WR_UNQ_PTL_CH        = binsof(cmd_type) intersect {CMD_WR_UNQ_PTL} && binsof (coherent_access) intersect {'h0};
            illegal_bins CMD_WR_UNQ_FULL_CH       = binsof(cmd_type) intersect {CMD_WR_UNQ_FULL} && binsof (coherent_access) intersect {'h0};


            illegal_bins CMD_WR_BK_PTL_CH         = binsof(cmd_type) intersect {CMD_WR_BK_PTL} && binsof (coherent_access) intersect {'h1};
          //illegal_bins CMD_WR_BK_FULL_CH        = binsof(cmd_type) intersect {CMD_WR_BK_FULL} && binsof (coherent_access) intersect {'h1};
          //illegal_bins CMD_WR_CLN_FULL_CH       = binsof(cmd_type) intersect {CMD_WR_CLN_FULL} && binsof (coherent_access) intersect {'h1};
            illegal_bins CMD_PREF_CH              = binsof(cmd_type) intersect {CMD_PREF} && binsof (coherent_access) intersect {'h1};
            illegal_bins CMD_WR_CLN_PTL_CH        = binsof(cmd_type) intersect {CMD_WR_CLN_PTL} && binsof (coherent_access) intersect {'h1};
            illegal_bins CMD_RD_NC_CH             = binsof(cmd_type) intersect {CMD_RD_NC} && binsof (coherent_access) intersect {'h1};
            illegal_bins CMD_DVM_MSG_CH           = binsof(cmd_type) intersect {CMD_DVM_MSG} && binsof (coherent_access) intersect {'h1};
            illegal_bins CMD_WR_EVICT_CH          = binsof(cmd_type) intersect {CMD_WR_EVICT} && binsof (coherent_access) intersect {'h1};
            illegal_bins CMD_EVICT_CH             = binsof(cmd_type) intersect {CMD_EVICT} && binsof (coherent_access) intersect {'h1};
            illegal_bins CMD_WR_NC_PTL_CH         = binsof(cmd_type) intersect {CMD_WR_NC_PTL} && binsof (coherent_access) intersect {'h1};
            illegal_bins CMD_WR_NC_FULL_CH        = binsof(cmd_type) intersect {CMD_WR_NC_FULL} && binsof (coherent_access) intersect {'h1};


        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins CMD_RD_NOT_SHD_CH        = binsof(cmd_type) intersect {CMD_RD_NOT_SHD} && binsof (coherent_access) intersect {'h0};
            illegal_bins CMD_RD_NITC_CLN_INV_CH   = binsof(cmd_type) intersect {CMD_RD_NITC_CLN_INV} && binsof (coherent_access) intersect {'h0};
            illegal_bins CMD_RD_NITC_MK_INV_CH    = binsof(cmd_type) intersect {CMD_RD_NITC_MK_INV} && binsof (coherent_access) intersect {'h0};
            illegal_bins CMD_LD_CCH_SH_CH         = binsof(cmd_type) intersect {CMD_LD_CCH_SH} && binsof (coherent_access) intersect {'h0};
            illegal_bins CMD_LD_CCH_UNQ_CH        = binsof(cmd_type) intersect {CMD_LD_CCH_UNQ} && binsof (coherent_access) intersect {'h0};
            //illegal_bins CMD_CLN_SH_PER_CH        = binsof(cmd_type) intersect {CMD_CLN_SH_PER} &&  binsof(coherent_access) intersect {'h0};
            //illegal_bins CMD_MK_INV_CH            = binsof(cmd_type) intersect {CMD_MK_INV} && binsof (coherent_access) intersect {'h0};
            //illegal_bins CMD_CLN_INV_CH           = binsof(cmd_type) intersect {CMD_CLN_INV} && binsof (coherent_access) intersect {'h0};
            //illegal_bins CMD_CLN_VLD_CH           = binsof(cmd_type) intersect {CMD_CLN_VLD} && binsof (coherent_access) intersect {'h0};

        <% } %>

        }

        <% } else { %>
         cmd_type_cross_coherent_access: cross cmd_type, coherent_access;
        <% } %>
	<% if(obj.Block =='chi_aiu') { %>
         cmd_type_cross_storage_type: cross cmd_type, storage_type {
            illegal_bins CMD_RD_CLN_STORAGE              = binsof(cmd_type) intersect {CMD_RD_CLN} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_RD_NITC_STORAGE             = binsof(cmd_type) intersect {CMD_RD_NITC} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_RD_VLD_STORAGE              = binsof(cmd_type) intersect {CMD_RD_VLD} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_RD_UNQ_STORAGE              = binsof(cmd_type) intersect {CMD_RD_UNQ} && binsof (storage_type) intersect {'h1};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            illegal_bins CMD_CLN_VLD_STORAGE             = binsof(cmd_type) intersect {CMD_CLN_VLD} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_CLN_INV_STORAGE             = binsof(cmd_type) intersect {CMD_CLN_INV} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_MK_INV_STORAGE              = binsof(cmd_type) intersect {CMD_MK_INV} && binsof (storage_type) intersect {'h1};
        <% } %>
            illegal_bins CMD_CLN_UNQ_STORAGE             = binsof(cmd_type) intersect {CMD_CLN_UNQ} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_MK_UNQ_STORAGE              = binsof(cmd_type) intersect {CMD_MK_UNQ} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_EVICT_STORAGE               = binsof(cmd_type) intersect {CMD_EVICT} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_WR_EVICT_STORAGE            = binsof(cmd_type) intersect {CMD_WR_EVICT} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_WR_CLN_PTL_STORAGE          = binsof(cmd_type) intersect {CMD_WR_CLN_PTL} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_WR_CLN_FULL_STORAGE         = binsof(cmd_type) intersect {CMD_WR_CLN_FULL} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_WR_UNQ_PTL_STORAGE          = binsof(cmd_type) intersect {CMD_WR_UNQ_PTL} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_WR_UNQ_FULL_STORAGE         = binsof(cmd_type) intersect {CMD_WR_UNQ_FULL} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_WR_BK_PTL_STORAGE           = binsof(cmd_type) intersect {CMD_WR_BK_PTL} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_WR_BK_FULL_STORAGE          = binsof(cmd_type) intersect {CMD_WR_BK_FULL} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_DVM_MSG_STORAGE             = binsof(cmd_type) intersect {CMD_DVM_MSG} && binsof (storage_type) intersect {'h1};


        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins CMD_RD_NOT_SHD_STORAGE          = binsof(cmd_type) intersect {CMD_RD_NOT_SHD} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_RD_NITC_CLN_INV_STORAGE     = binsof(cmd_type) intersect {CMD_RD_NITC_CLN_INV} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_RD_NITC_MK_INV_STORAGE      = binsof(cmd_type) intersect {CMD_RD_NITC_MK_INV} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_LD_CCH_SH_STORAGE           = binsof(cmd_type) intersect {CMD_LD_CCH_SH} && binsof (storage_type) intersect {'h1};
            illegal_bins CMD_LD_CCH_UNQ_STORAGE          = binsof(cmd_type) intersect {CMD_LD_CCH_UNQ} && binsof (storage_type) intersect {'h1};

            illegal_bins CMD_CMP_ATM_STORAGE            = binsof(cmd_type) intersect {CMD_CMP_ATM} && binsof(storage_type) intersect {1};
            illegal_bins CMD_RD_ATM_STORAGE             = binsof(cmd_type) intersect {CMD_RD_ATM} &&  binsof(storage_type) intersect {1};
            illegal_bins CMD_WR_ATM_STORAGE             = binsof(cmd_type) intersect {CMD_WR_ATM} &&  binsof(storage_type) intersect {1};
            illegal_bins CMD_SW_ATM_STORAGE             = binsof(cmd_type) intersect {CMD_SW_ATM} &&  binsof(storage_type) intersect {1};
            illegal_bins CMD_PREF_STORAGE               = binsof(cmd_type) intersect {CMD_PREF} &&  binsof(storage_type) intersect {1};

        <% } %>


}
        <% } else { %>
         cmd_type_cross_storage_type: cross cmd_type, storage_type;
        <% } %>
	<% if(obj.Block =='chi_aiu') { %>
    	 cmd_type_cross_exclusive: cross cmd_type, exclusive {
            illegal_bins CMD_RD_NITC_EXCL             = binsof(cmd_type) intersect {CMD_RD_NITC} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_RD_UNQ_EXCL              = binsof(cmd_type) intersect {CMD_RD_UNQ} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_CLN_VLD_EXCL             = binsof(cmd_type) intersect {CMD_CLN_VLD} && binsof (exclusive) intersect {'h1};

            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins CMD_CLN_SH_PER_EXCL          = binsof(cmd_type) intersect {CMD_CLN_SH_PER} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_RD_NITC_CLN_INV_EXCL     = binsof(cmd_type) intersect {CMD_RD_NITC_CLN_INV} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_RD_NITC_MK_INV_EXCL      = binsof(cmd_type) intersect {CMD_RD_NITC_MK_INV} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_LD_CCH_SH_EXCL           = binsof(cmd_type) intersect {CMD_LD_CCH_SH} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_LD_CCH_UNQ_EXCL          = binsof(cmd_type) intersect {CMD_LD_CCH_UNQ} && binsof (exclusive) intersect {'h1};
            <% } %>

            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            illegal_bins CMD_WR_CLN_PTL_EXCL          = binsof(cmd_type) intersect {CMD_WR_CLN_PTL} && binsof (exclusive) intersect {'h1};
            <% } %>
            illegal_bins CMD_CLN_INV_EXCL             = binsof(cmd_type) intersect {CMD_CLN_INV} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_MK_INV_EXCL              = binsof(cmd_type) intersect {CMD_MK_INV} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_MK_UNQ_EXCL              = binsof(cmd_type) intersect {CMD_MK_UNQ} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_EVICT_EXCL               = binsof(cmd_type) intersect {CMD_EVICT} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_WR_EVICT_EXCL            = binsof(cmd_type) intersect {CMD_WR_EVICT} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_WR_CLN_FULL_EXCL         = binsof(cmd_type) intersect {CMD_WR_CLN_FULL} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_WR_BK_PTL_EXCL           = binsof(cmd_type) intersect {CMD_WR_BK_PTL} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_WR_BK_FULL_EXCL          = binsof(cmd_type) intersect {CMD_WR_BK_FULL} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_WR_UNQ_FULL_EXCL         = binsof(cmd_type) intersect {CMD_WR_UNQ_FULL} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_WR_UNQ_PTL_EXCL          = binsof(cmd_type) intersect {CMD_WR_UNQ_PTL} && binsof (exclusive) intersect {'h1};
            illegal_bins CMD_DVM_MSG_EXCL             = binsof(cmd_type) intersect {CMD_DVM_MSG} && binsof (exclusive) intersect {'h1};

}
        <% } else { %>
    	 cmd_type_cross_exclusive: cross cmd_type, exclusive;
        <% } %>
        <%if(obj.testBench == "chi_aiu") { %>
         cmd_type_cross_non_secure_access: cross cmd_type, non_secure_access {
            illegal_bins CMD_DVM_MSG_NS             = binsof(cmd_type) intersect {CMD_DVM_MSG} && binsof (non_secure_access) intersect {'h1};
         }
        <% } else { %>
         cmd_type_cross_non_secure_access: cross cmd_type, non_secure_access;
        <% } %>
	<% if(obj.Block =='chi_aiu') { %>
         cmd_type_cross_privilege: cross cmd_type, privilege {
            ignore_bins CMD_PRIV           = binsof(cmd_type)  && binsof(privilege) intersect {1};

              }
        <% } else { %>
         cmd_type_cross_privilege: cross cmd_type, privilege;
        <% } %>
	<% if(obj.Block =='chi_aiu') { %>
         cmd_type_cross_order: cross cmd_type, order {
            illegal_bins CMD_RD_VLD_ORDER              = binsof(cmd_type) intersect {CMD_RD_VLD} && binsof (order) intersect {'h3};
            illegal_bins CMD_RD_CLN_ORDER              = binsof(cmd_type) intersect {CMD_RD_CLN} && binsof (order) intersect {'h3};
            illegal_bins CMD_RD_UNQ_ORDER              = binsof(cmd_type) intersect {CMD_RD_UNQ} && binsof (order) intersect {'h3};
            //illegal_bins CMD_CLN_VLD_ORDER             = binsof(cmd_type) intersect {CMD_CLN_VLD} && binsof (order) intersect {'h2,'h3}; // Need to check this
            //illegal_bins CMD_CLN_INV_ORDER             = binsof(cmd_type) intersect {CMD_CLN_INV} && binsof (order) intersect {'h2,'h3}; // Need to check this
            illegal_bins CMD_CLN_UNQ_ORDER             = binsof(cmd_type) intersect {CMD_CLN_UNQ} && binsof (order) intersect {'h3};
            illegal_bins CMD_MK_UNQ_ORDER              = binsof(cmd_type) intersect {CMD_MK_UNQ} && binsof (order) intersect {'h3};
            illegal_bins CMD_MK_INV_ORDER              = binsof(cmd_type) intersect {CMD_MK_INV} && binsof (order) intersect {'h2,'h3};
            illegal_bins CMD_EVICT_ORDER               = binsof(cmd_type) intersect {CMD_EVICT} && binsof (order) intersect {'h3};
            illegal_bins CMD_WR_EVICT_ORDER            = binsof(cmd_type) intersect {CMD_WR_EVICT} && binsof (order) intersect {'h3};
            illegal_bins CMD_WR_CLN_PTL_ORDER          = binsof(cmd_type) intersect {CMD_WR_CLN_PTL} && binsof (order) intersect {'h3};
            illegal_bins CMD_WR_CLN_FULL_ORDER         = binsof(cmd_type) intersect {CMD_WR_CLN_FULL} && binsof (order) intersect {'h3};
            illegal_bins CMD_WR_BK_PTL_ORDER           = binsof(cmd_type) intersect {CMD_WR_BK_PTL} && binsof (order) intersect {'h3};
            illegal_bins CMD_WR_BK_FULL_ORDER          = binsof(cmd_type) intersect {CMD_WR_BK_FULL} && binsof (order) intersect {'h3};

            //illegal_bins CMD_RD_NITC_ORDER              = binsof(cmd_type) intersect {CMD_RD_NITC} && binsof (order) intersect {'h3};
            //illegal_bins CMD_RD_NITC_CLN_INV_ORDER     = binsof(cmd_type) intersect {CMD_RD_NITC_CLN_INV} && binsof (order) intersect {'h0};
            //illegal_bins CMD_RD_NITC_MK_INV_ORDER      = binsof(cmd_type) intersect {CMD_RD_NITC_MK_INV} && binsof (order) intersect {'h0};
            //illegal_bins CMD_WR_UNQ_FULL_ORDER         = binsof(cmd_type) intersect {CMD_WR_UNQ_FULL} && binsof (order) intersect {'h0};
            //illegal_bins CMD_WR_UNQ_PTL_ORDER          = binsof(cmd_type) intersect {CMD_WR_UNQ_PTL} && binsof (order) intersect {'h0};


            illegal_bins CMD_DVM_MSG_ORDER             = binsof(cmd_type) intersect {CMD_DVM_MSG} && binsof (order) intersect {'h3};
            ignore_bins CMD_PREF_ORDER                = binsof(cmd_type) intersect {CMD_PREF} && binsof (order) intersect {'h2,'h3}; //need to check this


        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
           // illegal_bins CMD_CMP_ATM_ORDER            = binsof(cmd_type) intersect {CMD_CMP_ATM} && binsof(order) intersect {0};
           // illegal_bins CMD_RD_ATM_ORDER             = binsof(cmd_type) intersect {CMD_RD_ATM} &&  binsof(order) intersect {0};
           // illegal_bins CMD_WR_ATM_ORDER             = binsof(cmd_type) intersect {CMD_WR_ATM} &&  binsof(order) intersect {0};
           // illegal_bins CMD_SW_ATM_ORDER             = binsof(cmd_type) intersect {CMD_SW_ATM} &&  binsof(order) intersect {0};

            illegal_bins CMD_RD_NOT_SHD_ORDER         = binsof(cmd_type) intersect {CMD_RD_NOT_SHD} && binsof (order) intersect {'h3};
          //illegal_bins CMD_CLN_SH_PER_ORDER         = binsof(cmd_type) intersect {CMD_CLN_SH_PER} && binsof (order) intersect {'h2,'h3};
            illegal_bins CMD_LD_CCH_SH_ORDER          = binsof(cmd_type) intersect {CMD_LD_CCH_SH} && binsof (order) intersect {'h3};
            illegal_bins CMD_LD_CCH_UNQ_ORDER         = binsof(cmd_type) intersect {CMD_LD_CCH_UNQ} && binsof (order) intersect {'h3};

           // illegal_bins CMD_RD_NITC_MK_INV_ORDER     = binsof(cmd_type) intersect {CMD_RD_NITC_MK_INV} && binsof (order) intersect {'h3};
           // illegal_bins CMD_RD_NITC_CLN_INV_ORDER    = binsof(cmd_type) intersect {CMD_RD_NITC_CLN_INV} && binsof (order) intersect {'h3};
        <% } %>

         }
        <% } else { %>
         cmd_type_cross_order: cross cmd_type, order;
        <% } %>
	<% if(obj.Block =='chi_aiu') { %>
	 cmd_type_cross_access_size: cross cmd_type, access_size {

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins CMD_CMP_ATM_SIZE            = binsof(cmd_type) intersect {CMD_CMP_ATM} && binsof(access_size) intersect {0,6};
            ignore_bins CMD_RD_ATM_SIZE             = binsof(cmd_type) intersect {CMD_RD_ATM} &&  binsof(access_size) intersect {4,5,6};
            ignore_bins CMD_WR_ATM_SIZE             = binsof(cmd_type) intersect {CMD_WR_ATM} &&  binsof(access_size) intersect {4,5,6};
            ignore_bins CMD_SW_ATM_SIZE             = binsof(cmd_type) intersect {CMD_SW_ATM} &&  binsof(access_size) intersect {4,5,6};
        <% } %>

            illegal_bins CMD_RD_VLD_SIZE            = binsof(cmd_type) intersect {CMD_RD_VLD} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_RD_CLN_SIZE            = binsof(cmd_type) intersect {CMD_RD_CLN} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_RD_NITC_SIZE           = binsof(cmd_type) intersect {CMD_RD_NITC} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_RD_UNQ_SIZE            = binsof(cmd_type) intersect {CMD_RD_UNQ} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_CLN_VLD_SIZE           = binsof(cmd_type) intersect {CMD_CLN_VLD} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_CLN_INV_SIZE           = binsof(cmd_type) intersect {CMD_CLN_INV} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_MK_INV_SIZE            = binsof(cmd_type) intersect {CMD_MK_INV} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_CLN_UNQ_SIZE           = binsof(cmd_type) intersect {CMD_CLN_UNQ} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_MK_UNQ_SIZE            = binsof(cmd_type) intersect {CMD_MK_UNQ} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_EVICT_SIZE             = binsof(cmd_type) intersect {CMD_EVICT} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_WR_NC_FULL_SIZE        = binsof(cmd_type) intersect {CMD_WR_NC_FULL} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_WR_EVICT_SIZE          = binsof(cmd_type) intersect {CMD_WR_EVICT} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_WR_CLN_FULL_SIZE       = binsof(cmd_type) intersect {CMD_WR_CLN_FULL} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_WR_BK_PT_SIZE          = binsof(cmd_type) intersect {CMD_WR_BK_PTL} && binsof(access_size) intersect {['h0:'h5]};
            //ignore_bins WRITEBACKPTL_SIZE         = binsof(cmd_type) intersect {'h1A} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_WR_BK_FULL_SIZE        = binsof(cmd_type) intersect {CMD_WR_BK_FULL} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_WR_UNQ_FULL_SIZE       = binsof(cmd_type) intersect {CMD_WR_UNQ_FULL} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_DVM_MSG_SIZE           = binsof(cmd_type) intersect {CMD_DVM_MSG} && binsof(access_size) intersect {'h0,'h1,'h2,'h4,'h5,'h6};


            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins CMD_RD_NOT_SHD_SIZE        = binsof(cmd_type) intersect {CMD_RD_NOT_SHD} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_CLN_SH_PER_SIZE        = binsof(cmd_type) intersect {CMD_CLN_SH_PER} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_RD_NITC_CLN_INV_SIZE   = binsof(cmd_type) intersect {CMD_RD_NITC_CLN_INV} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_RD_NITC_MK_INV_SIZE    = binsof(cmd_type) intersect {CMD_RD_NITC_MK_INV} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_LD_CCH_SH_SIZE         = binsof(cmd_type) intersect {CMD_LD_CCH_SH} && binsof(access_size) intersect {['h0:'h5]};
            illegal_bins CMD_LD_CCH_UNQ_SIZE        = binsof(cmd_type) intersect {CMD_LD_CCH_UNQ} && binsof(access_size) intersect {['h0:'h5]};
            <% } %>


            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            illegal_bins CMD_WR_CLN_PTL_SIZE        = binsof(cmd_type) intersect {CMD_WR_CLN_PTL} && binsof (access_size) intersect {['h0:'h05]};
            <% } %>


           }
        <% } else { %>
	 cmd_type_cross_access_size: cross cmd_type, access_size;
        <% } %>
	<% if(obj.Block =='chi_aiu') { %>
    	 cmd_type_cross_transaction_odering_framework: cross cmd_type, transaction_odering_framework {
            illegal_bins CMD_TYPE_TOF_AXI            = binsof(cmd_type) && binsof(transaction_odering_framework) intersect {SMI_TOF_AXI};
            illegal_bins CMD_TYPE_TOF_ACE            = binsof(cmd_type) && binsof(transaction_odering_framework) intersect {SMI_TOF_ACE};
          } 
        <% } else { %>
    	 cmd_type_cross_transaction_odering_framework: cross cmd_type, transaction_odering_framework;
        <% } %>
    	 cmd_type_cross_quality_of_service: cross cmd_type, quality_of_service;

         // smi fields cross Snp msg type
	<% if(obj.Block =='chi_aiu') { %>
         snp_type_cross_visibility: cross snp_type, visibility {
            illegal_bins SNP_NITCCI_VZ            = binsof(snp_type) intersect {SNP_NITCCI}  && binsof(visibility) intersect {1};
            illegal_bins SNP_NITCMI_VZ            = binsof(snp_type) intersect {SNP_NITCMI}  && binsof(visibility) intersect {1};


            illegal_bins SNP_CLN_DTR_VZ           = binsof(snp_type) intersect {SNP_CLN_DTR}  && binsof(visibility) intersect {1};
            //illegal_bins SNP_NITC_VZ            = binsof(snp_type) intersect {SNP_NITC}  && binsof(visibility) intersect {1};  //Need to check why it is failing for FSYS
            ignore_bins SNP_NITC_VZ               = binsof(snp_type) intersect {SNP_NITC}  && binsof(visibility) intersect {1};
            illegal_bins SNP_VLD_DTR_VZ           = binsof(snp_type) intersect {SNP_VLD_DTR}  && binsof(visibility) intersect {1};
            illegal_bins SNP_INV_DTR_VZ           = binsof(snp_type) intersect {SNP_INV_DTR}  && binsof(visibility) intersect {1};
         <%if(obj.testBench == "chi_aiu") { %>
            illegal_bins SNP_CLN_DTW_VZ            = binsof(snp_type) intersect {SNP_CLN_DTW}  && binsof(visibility) intersect {0}; //Check it further
            //ignore_bins SNP_CLN_DTW_VZ            = binsof(snp_type) intersect {SNP_CLN_DTW}  && binsof(visibility) intersect {1};
        <% } else { %>
            ignore_bins SNP_CLN_DTW_VZ            = binsof(snp_type) intersect {SNP_CLN_DTW}  && binsof(visibility) intersect {1};
        <% } %>
            illegal_bins SNP_NOSDINT_VZ           = binsof(snp_type) intersect {SNP_NOSDINT}  && binsof(visibility) intersect {1};
            illegal_bins SNP_DVM_MSG_VZ           = binsof(snp_type) intersect {SNP_DVM_MSG}  && binsof(visibility) intersect {1};

            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins SNP_INV_STSH_VZ          = binsof(snp_type) intersect {SNP_INV_STSH}  && binsof(visibility) intersect {1};
            illegal_bins SNP_UNQ_STSH_VZ          = binsof(snp_type) intersect {SNP_UNQ_STSH}  && binsof(visibility) intersect {1};
            illegal_bins SNP_STSH_SH_VZ           = binsof(snp_type) intersect {SNP_STSH_SH}  && binsof(visibility) intersect {1};
            illegal_bins SNP_STSH_UNQ_VZ          = binsof(snp_type) intersect {SNP_STSH_UNQ}  && binsof(visibility) intersect {1};
            <% } %>

          }
        <% } else { %>
         snp_type_cross_visibility: cross snp_type, visibility;
        <% } %>
	<% if(obj.Block =='chi_aiu') { %>
         snp_type_cross_allocate: cross snp_type, allocate {


         <%if(obj.testBench == "chi_aiu") { %>
            illegal_bins SNP_NITCCI_AC            = binsof(snp_type) intersect {SNP_NITCCI}  && binsof(allocate) intersect {1};
            illegal_bins SNP_NITCMI_AC            = binsof(snp_type) intersect {SNP_NITCMI}  && binsof(allocate) intersect {1};

            illegal_bins SNP_CLN_DTR_AC           = binsof(snp_type) intersect {SNP_CLN_DTR}  && binsof(allocate) intersect {0};
            illegal_bins SNP_VLD_DTR_AC           = binsof(snp_type) intersect {SNP_VLD_DTR}  && binsof(allocate) intersect {0};
            illegal_bins SNP_NITC_AC              = binsof(snp_type) intersect {SNP_NITC}  && binsof(allocate) intersect {0};
            illegal_bins SNP_NOSDINT_AC           = binsof(snp_type) intersect {SNP_NOSDINT}  && binsof(allocate) intersect {0};
            //illegal_bins SNP_INV_DTW_AC           = binsof(snp_type) intersect {SNP_INV_DTW}  && binsof(allocate) intersect {0};
            illegal_bins SNP_INV_DTR_AC           = binsof(snp_type) intersect {SNP_INV_DTR}  && binsof(allocate) intersect {0};
           // illegal_bins SNP_CLN_DTW_AC           = binsof(snp_type) intersect {SNP_CLN_DTW}  && binsof(allocate) intersect {0};
            ignore_bins SNP_CLN_DTW_AC           = binsof(snp_type) intersect {SNP_CLN_DTW}  && binsof(allocate) intersect {0};
            illegal_bins SNP_DVM_MSG_AC           = binsof(snp_type) intersect {SNP_DVM_MSG}  && binsof(allocate) intersect {0};
        <% } else { %>
            ignore_bins SNP_NITCCI_AC            = binsof(snp_type) intersect {SNP_NITCCI}  && binsof(allocate) intersect {1};
            ignore_bins SNP_NITCMI_AC            = binsof(snp_type) intersect {SNP_NITCMI}  && binsof(allocate) intersect {1};

            ignore_bins SNP_CLN_DTR_AC           = binsof(snp_type) intersect {SNP_CLN_DTR}  && binsof(allocate) intersect {0};
            ignore_bins SNP_VLD_DTR_AC           = binsof(snp_type) intersect {SNP_VLD_DTR}  && binsof(allocate) intersect {0};
            ignore_bins SNP_NITC_AC              = binsof(snp_type) intersect {SNP_NITC}  && binsof(allocate) intersect {0};
            ignore_bins SNP_NOSDINT_AC           = binsof(snp_type) intersect {SNP_NOSDINT}  && binsof(allocate) intersect {0};
            //ignore_bins SNP_INV_DTW_AC           = binsof(snp_type) intersect {SNP_INV_DTW}  && binsof(allocate) intersect {0};
            ignore_bins SNP_INV_DTR_AC           = binsof(snp_type) intersect {SNP_INV_DTR}  && binsof(allocate) intersect {0};
            ignore_bins SNP_CLN_DTW_AC           = binsof(snp_type) intersect {SNP_CLN_DTW}  && binsof(allocate) intersect {0};
            ignore_bins SNP_DVM_MSG_AC           = binsof(snp_type) intersect {SNP_DVM_MSG}  && binsof(allocate) intersect {0};
        <% } %>

         <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
           <%if(obj.testBench == "chi_aiu") { %>
            illegal_bins SNP_INV_STSH_AC          = binsof(snp_type) intersect {SNP_INV_STSH}  && binsof(allocate) intersect {0};
            illegal_bins SNP_UNQ_STSH_AC          = binsof(snp_type) intersect {SNP_UNQ_STSH}  && binsof(allocate) intersect {0};
            illegal_bins SNP_STSH_SH_AC           = binsof(snp_type) intersect {SNP_STSH_SH}  && binsof(allocate) intersect {0};
            illegal_bins SNP_STSH_UNQ_AC          = binsof(snp_type) intersect {SNP_STSH_UNQ}  && binsof(allocate) intersect {0};
           <% } else { %>
            ignore_bins SNP_INV_STSH_AC          = binsof(snp_type) intersect {SNP_INV_STSH}  && binsof(allocate) intersect {0};
            ignore_bins SNP_UNQ_STSH_AC          = binsof(snp_type) intersect {SNP_UNQ_STSH}  && binsof(allocate) intersect {0};
            ignore_bins SNP_STSH_SH_AC           = binsof(snp_type) intersect {SNP_STSH_SH}  && binsof(allocate) intersect {0};
            ignore_bins SNP_STSH_UNQ_AC          = binsof(snp_type) intersect {SNP_STSH_UNQ}  && binsof(allocate) intersect {0};
           <% } %>
         <% } %>

          }
        <% } else { %>
         snp_type_cross_allocate: cross snp_type, allocate;
        <% } %>
	<% if(obj.Block =='chi_aiu') { %>
         snp_type_cross_cacheable: cross snp_type, cacheable {
         <%if(obj.testBench == "chi_aiu") { %>
            illegal_bins SNP_CA           = binsof(snp_type)  && binsof(cacheable) intersect {0};
        <% } else { %>
            ignore_bins SNP_CA           = binsof(snp_type)  && binsof(cacheable) intersect {0};
        <% } %>
          }
        <% } else { %>
         snp_type_cross_cacheable: cross snp_type, cacheable;
        <% } %>

        <%if(obj.testBench == "chi_aiu") { %>
         snp_type_cross_non_secure_access: cross snp_type, non_secure_access {
            illegal_bins SNP_DVM_MSG_NS           = binsof(snp_type) intersect {SNP_DVM_MSG}  && binsof(non_secure_access) intersect {1};
         }
        <% } else { %>
         snp_type_cross_non_secure_access: cross snp_type, non_secure_access;
        <% } %>


        <%if(obj.Block == "chi_aiu") { %>
        smi_rv_rs         : coverpoint rv_rs {
           ignore_bins rv_rs = {1};
        }
        smi_cov_up        : coverpoint smi_up {
           illegal_bins smi_up_2 = {2};
        }
        <% } %>


         snp_type_cross_privilege: cross snp_type, privilege;

      <%if(obj.testBench == "chi_aiu") { %>
         snp_type_cross_smi_up: cross snp_type, unique_precense_provider {
            illegal_bins SNP_CLN_DTR_UP_2             = binsof(snp_type) intersect {SNP_CLN_DTR} && binsof (unique_precense_provider) intersect {'h0, 'h2};
            illegal_bins SNP_NOSDINT_UP_2             = binsof(snp_type) intersect {SNP_NOSDINT} && binsof (unique_precense_provider) intersect {'h0, 'h2};
            illegal_bins SNP_VLD_DTR_UP_2             = binsof(snp_type) intersect {SNP_VLD_DTR} && binsof (unique_precense_provider) intersect {'h0, 'h2};
            illegal_bins SNP_INV_DTR_UP_2             = binsof(snp_type) intersect {SNP_INV_DTR} && binsof (unique_precense_provider) intersect {'h0, 'h2};
            illegal_bins SNP_NITCCI_UP_2              = binsof(snp_type) intersect {SNP_NITCCI} && binsof (unique_precense_provider) intersect {'h0, 'h2};
            illegal_bins SNP_NITCMI_UP_2              = binsof(snp_type) intersect {SNP_NITCMI} && binsof (unique_precense_provider) intersect {'h0, 'h2};
            illegal_bins SNP_NITC_UP_2                = binsof(snp_type) intersect {SNP_NITC} && binsof (unique_precense_provider) intersect {'h0, 'h2};
            illegal_bins SNP_INV_UP_2                 = binsof(snp_type) intersect {SNP_INV} && binsof (unique_precense_provider) intersect {'h0, 'h2};

            illegal_bins SNP_INV_DTW_UP_2             = binsof(snp_type) intersect {SNP_INV_DTW} && binsof (unique_precense_provider) intersect {'h2};
            illegal_bins SNP_CLN_DTW_UP_2             = binsof(snp_type) intersect {SNP_CLN_DTW} && binsof (unique_precense_provider) intersect {'h0,'h2};
            illegal_bins SNP_UNQ_STSH_UP_2            = binsof(snp_type) intersect {SNP_UNQ_STSH} && binsof (unique_precense_provider) intersect {'h0, 'h2};
            illegal_bins SNP_STSH_UNQ_UP_2            = binsof(snp_type) intersect {SNP_STSH_UNQ} && binsof (unique_precense_provider) intersect {'h0, 'h2};
            illegal_bins SNP_STSH_SH_UP_2             = binsof(snp_type) intersect {SNP_STSH_SH} && binsof (unique_precense_provider) intersect {'h0, 'h2};
            illegal_bins SNP_INV_STSH_UP_2            = binsof(snp_type) intersect {SNP_INV_STSH} && binsof (unique_precense_provider) intersect {'h0, 'h2};

            illegal_bins SNP_DVM_MSG_UP_2             = binsof(snp_type) intersect {SNP_DVM_MSG} && binsof (unique_precense_provider) intersect {'h1,'h2,'h3};
            illegal_bins SNP_RECALL_UP_2              = binsof(snp_type) intersect {SNP_RECALL} && binsof (unique_precense_provider) intersect {'h1,'h2,'h3};

          //  ignore_bins SNP_INV_UP_1_3                 = binsof(snp_type) intersect {SNP_INV} && binsof (unique_precense_provider) intersect {'h1,'h3};  // need to check
          //  ignore_bins SNP_INV_DTW_UP_1_3             = binsof(snp_type) intersect {SNP_INV_DTW} && binsof (unique_precense_provider) intersect {'h1,'h3};
          //  ignore_bins SNP_CLN_DTW_UP_1_3             = binsof(snp_type) intersect {SNP_CLN_DTW} && binsof (unique_precense_provider) intersect {'h1,'h3};
         }
        <% } else { %>
         snp_type_cross_smi_up: cross snp_type, unique_precense_provider;
        <% } %>

	<% if(obj.Block =='chi_aiu') { %>
         snp_type_cross_response_level: cross snp_type, response_level {
         <%if(obj.testBench == "chi_aiu") { %>
            illegal_bins SNP_RL          = binsof(snp_type)  && binsof(response_level) intersect {SMI_RL_TRANSPORT};
        <% } else { %>
            ignore_bins SNP_RL          = binsof(snp_type)  && binsof(response_level) intersect {SMI_RL_TRANSPORT};
        <% } %>

            } 
        <% } else { %>
         snp_type_cross_response_level: cross snp_type, response_level;
        <% } %>
         snp_type_cross_trace_me: cross snp_type, trace_me;
	<% if(obj.Block =='chi_aiu') { %>
    	 snp_type_cross_transaction_odering_framework: cross snp_type, transaction_odering_framework {
            ignore_bins SNP_DVM_MSG_SMI_TOF_AXI            = binsof(snp_type) intersect {SNP_DVM_MSG} && binsof(transaction_odering_framework) intersect {SMI_TOF_AXI};
            ignore_bins SNP_NITCMI_SMI_TOF_ACE            = binsof(snp_type) intersect {SNP_NITCMI} && binsof(transaction_odering_framework) intersect {SMI_TOF_ACE};
            ignore_bins SNP_NITCCI_SMI_TOF_ACE            = binsof(snp_type) intersect {SNP_NITCCI} && binsof(transaction_odering_framework) intersect {SMI_TOF_ACE};
            ignore_bins SNP_STSH_UNQ_SMI_TOF_ACE            = binsof(snp_type) intersect {SNP_STSH_UNQ} && binsof(transaction_odering_framework) intersect {SMI_TOF_ACE};
            ignore_bins SNP_STSH_SH_SMI_TOF_ACE            = binsof(snp_type) intersect {SNP_STSH_SH} && binsof(transaction_odering_framework) intersect {SMI_TOF_ACE};
            ignore_bins SNP_UNQ_STSH_SMI_TOF_ACE            = binsof(snp_type) intersect {SNP_UNQ_STSH} && binsof(transaction_odering_framework) intersect {SMI_TOF_ACE};
            ignore_bins SNP_INV_STSH_SMI_TOF_ACE            = binsof(snp_type) intersect {SNP_INV_STSH} && binsof(transaction_odering_framework) intersect {SMI_TOF_ACE};
	} //This is not possible
        <% } else { %>
    	 cmd_type_cross_transaction_odering_framework: cross snp_type, transaction_odering_framework;
        <% } %>

        <%if(obj.testBench == "chi_aiu") { %>   // coverpoint when smi_up = 'h3
    	 snp_type_cross_mpf3: cross snp_type, unique_precense_provider, isMpf3AiuID {
            illegal_bins SNP_CLN_DTR_MPF3      = binsof(snp_type) intersect {SNP_CLN_DTR} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
            illegal_bins SNP_NITC_MPF3         = binsof(snp_type) intersect {SNP_NITC} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
            illegal_bins SNP_VLD_DTR_MPF3      = binsof(snp_type) intersect {SNP_VLD_DTR} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
            illegal_bins SNP_INV_DTR_MPF3      = binsof(snp_type) intersect {SNP_INV_DTR} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
            illegal_bins SNP_NITCCI_MPF3       = binsof(snp_type) intersect {SNP_NITCCI} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
            illegal_bins SNP_NITCMI_MPF3       = binsof(snp_type) intersect {SNP_NITCMI} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
            illegal_bins SNP_NOSDINT_MPF3      = binsof(snp_type) intersect {SNP_NOSDINT} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 

            illegal_bins SNP_CLN_DTW_MPF3      = binsof(snp_type) intersect {SNP_CLN_DTW} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
            illegal_bins SNP_INV_MPF3          = binsof(snp_type) intersect {SNP_INV} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
            ignore_bins SNP_INV_DTW_MPF3      = binsof(snp_type) intersect {SNP_INV_DTW} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins SNP_INV_STSH_MPF3     = binsof(snp_type) intersect {SNP_INV_STSH} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
            illegal_bins SNP_UNQ_STSH_MPF3     = binsof(snp_type) intersect {SNP_UNQ_STSH} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
            illegal_bins SNP_STSH_SH_MPF3      = binsof(snp_type) intersect {SNP_STSH_SH} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
            illegal_bins SNP_STSH_UNQ_MPF3     = binsof(snp_type) intersect {SNP_STSH_UNQ} && binsof(unique_precense_provider) intersect{'h0,'h2}  ; 
        <% } %>

            ignore_bins SNP_DVM_MSG_MPF3      = binsof(snp_type) intersect {SNP_DVM_MSG}; 

            ignore_bins SNP_NOSDINT_MPF3_0      = binsof(snp_type) intersect {SNP_NOSDINT} && binsof(unique_precense_provider) intersect{'h1,'h3} && binsof(isMpf3AiuID) intersect{'h0}  ; 
            ignore_bins SNP_CLN_DTR_MPF3_0      = binsof(snp_type) intersect {SNP_CLN_DTR} && binsof(unique_precense_provider) intersect{'h1,'h3} && binsof(isMpf3AiuID) intersect{'h0}  ; 
            ignore_bins SNP_VLD_DTR_MPF3_0      = binsof(snp_type) intersect {SNP_VLD_DTR} && binsof(unique_precense_provider) intersect{'h1,'h3} && binsof(isMpf3AiuID) intersect{'h0}  ; 
            ignore_bins SNP_NITC_MPF3_0         = binsof(snp_type) intersect {SNP_NITC} && binsof(unique_precense_provider) intersect{'h1,'h3} && binsof(isMpf3AiuID) intersect{'h0}  ; 
         }
        <% } else { %>
    	 snp_type_cross_mpf3: cross snp_type, isMpf3AiuID iff (m_smi_seq.smi_up == 2'b11);
        <% } %>
       <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    	 snp_type_cross_quality_of_service: cross snp_type, quality_of_service;
         snp_inv_stsh_cross_stashnid: coverpoint isStashnidAiuID iff (m_smi_seq.smi_msg_type == SNP_INV_STSH);
         snp_unq_stsh_cross_stashnid: coverpoint isStashnidAiuID iff (m_smi_seq.smi_msg_type == SNP_UNQ_STSH);
         snp_stsh_sh_cross_stashnid: coverpoint isStashnidAiuID iff (m_smi_seq.smi_msg_type == SNP_STSH_SH);
         snp_stsh_unq_cross_stashnid: coverpoint isStashnidAiuID iff (m_smi_seq.smi_msg_type == SNP_STSH_UNQ);

	<% if(obj.Block =='chi_aiu') { %>
         snp_inv_stsh_cross_snarf_bit: coverpoint m_smi_seq.smi_cmstatus_snarf  iff (m_smi_seq.smi_msg_type == SNP_INV_STSH) {
            ignore_bins SNP_INV_STSH_SNARF         = {1};
          }
         snp_unq_stsh_cross_snarf_bit: coverpoint m_smi_seq.smi_cmstatus_snarf iff (m_smi_seq.smi_msg_type == SNP_UNQ_STSH) {
            ignore_bins SNP_UNQ_STSH_SNARF         = {1};
          }
         snp_stsh_sh_cross_snarf_bit: coverpoint m_smi_seq.smi_cmstatus_snarf iff (m_smi_seq.smi_msg_type == SNP_STSH_SH) {
            ignore_bins SNP_STSH_SH_SNARF         = {1};
          }
         snp_stsh_unq_cross_snarf_bit: coverpoint m_smi_seq.smi_cmstatus_snarf iff (m_smi_seq.smi_msg_type == SNP_STSH_UNQ) {
            ignore_bins SNP_STSH_UNQ_SNARF         = {1};
          }
        <% } else { %>
         snp_inv_stsh_cross_snarf_bit: coverpoint m_smi_seq.smi_cmstatus_snarf  iff (m_smi_seq.smi_msg_type == SNP_INV_STSH);
         snp_unq_stsh_cross_snarf_bit: coverpoint m_smi_seq.smi_cmstatus_snarf iff (m_smi_seq.smi_msg_type == SNP_UNQ_STSH);
         snp_stsh_sh_cross_snarf_bit: coverpoint m_smi_seq.smi_cmstatus_snarf iff (m_smi_seq.smi_msg_type == SNP_STSH_SH);
         snp_stsh_unq_cross_snarf_bit: coverpoint m_smi_seq.smi_cmstatus_snarf iff (m_smi_seq.smi_msg_type == SNP_STSH_UNQ);
        <% } %>
       <% } %>
	 <% } %>

        // SMI FIELDS FOR DII ONLY
	<% if(obj.Block =='dii') { %>

	 burst_type: coverpoint m_smi_seq.smi_mpf1_burst_type {
             bins incr_burst  = {1};
             <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
                 bins wrap_burst  = {2};
             <% } %>
         }

	 burst_size: coverpoint m_smi_seq.smi_mpf1_asize iff((m_smi_seq.smi_mpf1_burst_type == WRAP) || (m_smi_seq.smi_mpf1_burst_type == INCR)) {
             bins bytes_1   = {0};
             bins bytes_2   = {1};
             bins bytes_3   = {2};
             <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %> //sys_dii supports transactions only upto 32 bits
                 bins bytes_8   = {3};
                 bins bytes_16  = {4};
                 bins bytes_32  = {5};
                 bins bytes_64  = {6};
                 bins bytes_128 = {7};
             <% } %>
         }
         <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %> // The number of transactions in a single beat for sys_dii is always "1"
	    burst_length: coverpoint m_smi_seq.smi_mpf1_alength iff((m_smi_seq.smi_mpf1_burst_type == WRAP) || (m_smi_seq.smi_mpf1_burst_type == INCR));
         <% } %>
     //data_word: coverpoint m_smi_seq.smi_mpf1_dtr_long_dtw; DII supports only a maxium of 64 Bytes and does not support long DW
     //auxiliary_bits: coverpoint m_smi_seq.smi_ndp_aux;
         <% if (smiObj.WSMINDPPROT_EN) { %>
    	 ndp_protection: coverpoint m_smi_seq.smi_ndp_protection {
             bins none = {SMI_NDP_PROTECTION_NONE};
             bins parity = {SMI_NDP_PROTECTION_PARITY};
         }
         <% } %>
         //#Cover.DII.DTWreq.Return_buffer_id
         //#Cover.DII.STRreq.Return_buffer_id
    	 return_buffer_id: coverpoint m_smi_seq.smi_rbid {
        <% for(var i=0; i<obj.DiiInfo[obj.Id].cmpInfo.nWttCtrlEntries ;i++) { %>
            bins rbid_<%=i%> = {<%=i%>};
        <% } %>
        }

         // #Cover.DII.CMDreq.Dii_unit_id
         <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %> // The unitId is sys_dii is always "0". Single Unit
             unit_id: coverpoint m_smi_seq.smi_targ_ncore_unit_id iff (m_smi_seq.isCmdMsg()){
             bins dii_unit_id = {<%=obj.DiiInfo[obj.Id].FUnitId%>};
             }
         <% } %>
    	 interface_size: coverpoint m_smi_seq.smi_intfsize {
             bins native_intf_1_DW = {0};
             bins native_intf_2_DW = {1};
             bins native_intf_4_DW = {2};
         }
    <% } %>

        <%     if((obj.Block =='dmi') || (obj.Block =='dce')){ %>
         rb_rtype: coverpoint m_smi_seq.smi_rtype
         {
                 bins rb_reserved              = {0};
         }
         <% } %>

	<% if(obj.Block !='dii' && obj.Block !='aiu' && obj.Block !='dve' && obj.Block != 'dce') { %>
         address: coverpoint m_smi_seq.smi_addr;
         endianness: coverpoint m_smi_seq.smi_en{
               bins little_endian = {0};
        <%     if(obj.Block =='dmi'){ %>
                      illegal_bins big_endian = {1};
        <% } %>
         }

        <%     if(obj.Block !='dmi' && obj.Block !='dce'){ %>
    	 lock: coverpoint m_smi_seq.smi_lk {
              bins lock = {0};
         }
             <% if ((obj.Block != 'io_aiu') || (obj.Block == 'io_aiu') && ((obj.fnNativeInterface == "ACE") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E") )) { %>
//	         ecmd_type: coverpoint m_smi_seq.smi_ecmd_type;
	         msg_type: coverpoint cmd_type iff(m_smi_seq.isCmdMsg()) {
		 <%if(obj.fnNativeInterface != "ACE") { %>
		    ignore_bins ignoreACEOnly = {eCmdRdVld,eCmdRdCln,eCmdRdUnq,eCmdDvmMsg,eCmdWrBkFull,eCmdWrClnFull,eCmdWrEvict,eCmdWrBkPtl,eCmdWrClnPtl,eCmdPref,eCmdEvict,eCmdClnUnq,eCmdMkUnq,eCmdRdNShD};
		 <% } %>
             <% if((obj.Block =='chi_aiu')) { %>
                <% if((obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A')) { %>
		    ignore_bins CHI_A_Only = {eCmdWrAtm,eCmdRdAtm,eCmdWrStshFull,eCmdWrStshPtl,eCmdLdCchShd,eCmdLdCchUnq,eCmdRdNITCClnInv,eCmdRdNITCMkInv,eCmdClnShdPer,eCmdSwAtm,eCmdCompAtm};
	        <% } %>
                <% if((obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-B')) { %>
		    ignore_bins CHI_B_Only = {eCmdWrStshPtl,eCmdWrStshFull};
	        <% } %>
	     <% } %>

		 <%if(obj.fnNativeInterface != "ACELITE-E") { %>
		    ignore_bins ignoreACELiteEOnly = {eCmdWrAtm,eCmdRdAtm,eCmdWrStshFull,eCmdWrStshPtl,eCmdLdCchShd,eCmdLdCchUnq,eCmdRdNITCClnInv,eCmdRdNITCMkInv,eCmdClnShdPer,eCmdSwAtm,eCmdCompAtm};	     
		 <% } %>
		 }
             <% } %>
        <% } %>
        
         <%     if((obj.Block !='dmi') && (obj.Block == 'io_aiu') && (obj.fnNativeInterface == "ACELITE-E")) { %>
         mpf1_stash_valid: coverpoint m_smi_seq.smi_mpf1_stash_valid;
    	 stash_nid: coverpoint m_smi_seq.smi_mpf1_stash_nid { 
    	 <%	obj.AiuInfo.forEach(function(bundle) { %>
			<%if((bundle.fnNativeInterface == "CHI-B") || (bundle.fnNativeInterface == "CHI-A")|| (bundle.fnNativeInterface == "CHI-E")) { %>
			bins aiuid_<%=bundle.FUnitId%> = {<%=bundle.FUnitId%>};
			<% } %>
		<%})%>
		}
        <% } %>


        <% if(obj.Block =='dmi') { %>
        <% if(obj.DmiInfo[obj.Id].useAtomic ){ %>
    	 argument_vector: coverpoint m_smi_seq.smi_mpf1_argv{
    	     bins valid_bins[] = {[0:7]};
    	 }
        <% } %>
         <% } else if ((obj.Block != 'dce')  && (obj.Block == 'io_aiu') && (obj.fnNativeInterface == "ACELITE-E")) { %>
    	 // argument_vector: coverpoint m_smi_seq.smi_mpf1_argv;
    	 argument_vector: coverpoint m_smi_seq.smi_mpf1_stash_nid {
	    <% for (i=0; i<chiIds.length; i++) { %>
               bins dtr_tgt_id<%=chiIds[i]%> = {<%=chiIds[i]%>};
            <% } %>
	 }
        <% } %>

        <% if(obj.Block =='dmi'){ %>
    	 dtr_tgt_id: coverpoint m_smi_seq.smi_mpf1_dtr_tgt_id{
    	   bins  dtr_tgt_id[] = {[0:<%=obj.DmiInfo[obj.Id].nAius-1%>]};
    	 }
    	 rmsg_id: coverpoint m_smi_seq.smi_rmsg_id;
        <% } else if (obj.Block == 'dce')  { %>
    	 dtr_tgt_id: coverpoint m_smi_seq.smi_mpf1_dtr_tgt_id{
    	   bins  dtr_tgt_id[] = {[0:ncoreConfigInfo::NUM_AIUS]};
    	 }
    	 rmsg_id: coverpoint m_smi_seq.smi_rmsg_id;
        <% } else if ((obj.Block == 'io_aiu') && obj.useCache) {%>
    	 dtr_tgt_id: coverpoint m_smi_seq.smi_mpf1_dtr_tgt_id {
            <% for (i=0; i<cohIds.length; i++) { %>
               bins dtr_tgt_id<%=i%> = {<%=cohIds[i]%>};
            <% } %>
         }
    	 rmsg_id: coverpoint m_smi_seq.smi_rmsg_id;
        <% } %>

        <% if(obj.Block !='dmi' && obj.Block != 'dce'){ %>
       	 smi_cmstatus: coverpoint m_smi_seq.smi_cmstatus[7:6] {
             bins good_status = {2'b00};
             bins error_status = {2'b10};
         }

    	 smi_cmstatus_err: coverpoint m_smi_seq.smi_cmstatus_err;
    	 smi_cmstatus_err_payload: coverpoint m_smi_seq.smi_cmstatus_err_payload iff (m_smi_seq.smi_cmstatus_err){
            bins data = {3};
            bins addr = {4};
         <%if(obj.testBench != "chi_aiu" && obj.testBench != "io_aiu") { %>
            bins non_addr_non_data = {2};
            bins target_signaled = {5};
            bins timeout = {6};
            bins coherency = {7};
         <% } %>
         }
<%if(obj.testBench != "io_aiu") { %>
    	// smi_cmstatus_so: coverpoint m_smi_seq.smi_cmstatus_so;
    	// smi_cmstatus_ss:  coverpoint m_smi_seq.smi_cmstatus_ss;
    	// smi_cmstatus_sd: coverpoint m_smi_seq.smi_cmstatus_sd;
    	// smi_cmstatus_st: coverpoint m_smi_seq.smi_cmstatus_st;

         smi_cmstatus_state : coverpoint m_smi_seq.smi_cmstatus[3:1] {
           bins cmstatus_invalid =  {'h0};
           bins cmstatus_owner   =  {'h2};
           bins cmstatus_sharer  =  {'h3};
           bins cmstatus_unique  =  {'h4};
         }
<% } %>
    	 smi_cmstatus_snarf: coverpoint m_smi_seq.smi_cmstatus_snarf {
	    bins snarf0 = {0};
	    <%if(obj.fnNativeInterface == "ACELITE-E") { %>
	    bins snarf1 = {1};
            <% } %>						 
	 }
    	 smi_cmstatus_exok: coverpoint m_smi_seq.smi_cmstatus_exok;
<%/*if((obj.fnNativeInterface == "ACE") || ((obj.fnNativeInterface == "AXI4") && obj.useCache)) {*/ %>
<%/*if(!((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E"))) {*/%>
<%if((obj.fnNativeInterface == "ACE") || (obj.useCache)) { %>
    	 smi_cmstatus_rv: coverpoint m_smi_seq.smi_cmstatus_rv;
    	 smi_cmstatus_rs: coverpoint m_smi_seq.smi_cmstatus_rs;
    	 smi_cmstatus_dc: coverpoint m_smi_seq.smi_cmstatus_dc;
<% } else { %>
    	 smi_cmstatus_rv: coverpoint m_smi_seq.smi_cmstatus_rv {
	    bins rv0 = {0};
	 }
    	 smi_cmstatus_rs: coverpoint m_smi_seq.smi_cmstatus_rs {
	    bins rs0 = {0};
	 }
    	 smi_cmstatus_dc: coverpoint m_smi_seq.smi_cmstatus_dc {
	    bins dc0 = {0};
	 }
<% } %>
<%/*if(!((obj.fnNativeInterface == "ACE") || ((obj.fnNativeInterface == "AXI4") && obj.useCache))) {*/ %>
<%/*if(!((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E"))) {*/%>
<%if((obj.fnNativeInterface == "ACE") || (obj.useCache)) { %>
    	 smi_cmstatus_dt_aiu: coverpoint m_smi_seq.smi_cmstatus_dt_aiu;
    	 smi_cmstatus_dt_dmi: coverpoint m_smi_seq.smi_cmstatus_dt_dmi;
<% } else { %>
    	 smi_cmstatus_dt_aiu: coverpoint m_smi_seq.smi_cmstatus_dt_aiu {
	    bins dt_aiu0 = {0};
	 }
    	 smi_cmstatus_dt_dmi: coverpoint m_smi_seq.smi_cmstatus_dt_dmi {
	    bins dt_dmi0 = {0};
	 }

<% } %>
         <% if ((obj.fnNativeInterface == "ACE") ) { %>
    	      smi_conc_msg_class: coverpoint m_smi_seq.smi_conc_msg_class;
         <% } else if(obj.fnNativeInterface == "ACE-LITE"){ %>
    	      smi_conc_msg_class: coverpoint m_smi_seq.smi_conc_msg_class {
		 ignore_bins ignoreAcelite = {eConcMsgHntReq,eConcMsgHntRsp,eConcMsgMrdReq,eConcMsgMrdRsp,eConcMsgRbUseReq,eConcMsgUpdReq,eConcMsgUpdRsp,
					      eConcMsgRbUseRsp,eConcMsgRbReq,eConcMsgRbRsp,eConcMsgCmpRsp,eConcMsgCmeRsp,eConcMsgTreRsp,eConcMsgSnpReq,eConcMsgSysReq,eConcMsgSysRsp,eConcMsgSnpRsp,eConcMsgBAD};
	      }
         <% } else if(obj.fnNativeInterface == "ACELITE-E"){ %>
    	      smi_conc_msg_class: coverpoint m_smi_seq.smi_conc_msg_class {
		 ignore_bins ignoreAcelite = {eConcMsgHntReq,eConcMsgHntRsp,eConcMsgMrdReq,eConcMsgMrdRsp,eConcMsgRbUseReq,eConcMsgUpdReq,eConcMsgUpdRsp,
					      eConcMsgRbUseRsp,eConcMsgRbReq,eConcMsgRbRsp,eConcMsgCmpRsp,eConcMsgCmeRsp,eConcMsgTreRsp,eConcMsgBAD};
	      }
         <% } else { %>
    	      smi_conc_msg_class: coverpoint m_smi_seq.smi_conc_msg_class{
                bins eConcMsgCmdReq = {eConcMsgCmdReq};
          <% if (obj.NcMode) { %>
                bins eConcMsgNcCmdRsp = {eConcMsgNcCmdRsp};
          <% } else { %> //CONC-9169//9136
                bins eConcMsgCCmdRsp = {eConcMsgCCmdRsp}; 
          <% } %>
                bins eConcMsgStrReq = {eConcMsgStrReq};
                bins eConcMsgStrRsp = {eConcMsgStrRsp};
                bins eConcMsgDtrReq = {eConcMsgDtrReq};
                bins eConcMsgDtrRsp = {eConcMsgDtrRsp};
                bins eConcMsgDtwReq = {eConcMsgDtwReq};
                bins eConcMsgDtwRsp = {eConcMsgDtwRsp};
              }
         <% } %>
    	 // smi_unq_identifier: coverpoint m_smi_seq.smi_unq_identifier;
<%if(obj.testBench == "io_aiu" || obj.testBench == "chi_aiu") { %>
	 smi_steer: coverpoint m_smi_seq.smi_steer {
	    bins steer0 = {0};
	 }
<% } else { %>
	 smi_steer: coverpoint m_smi_seq.smi_steer;
<% } %>
<%if(obj.testBench == "io_aiu" || obj.testBench == "chi_aiu") { %>
    	 smi_msg_tier: coverpoint m_smi_seq.smi_msg_tier { 
	    bins tier0 = {0};
	 }
<% } else { %>

    	 smi_msg_tier: coverpoint m_smi_seq.smi_msg_tier;
<% } %>	    
   <%if(obj.DutInfo.eStarve && obj.DutInfo.eAge && (obj.AiuInfo[obj.Id].QosInfo && obj.AiuInfo[obj.Id].QosInfo.qosMap.length > 0)) { %>
;
        coverpoint_SnpReq_MsgQOS: coverpoint snp_req_msg.smi_msg_qos    	
   <% } else { %>
	smi_msg_qos: coverpoint m_smi_seq.smi_msg_qos {
	   bins qos0 = {0};
	}
   <% } %>


<%if(obj.testBench == "io_aiu") { %>
	<%if(obj.DutInfo.fnEnableQos) { %>			  
    	 smi_msg_pri: coverpoint m_smi_seq.smi_msg_pri;
        <% } %>
<% } else { %>
	<%if(obj.DutInfo.fnEnableQos) { %>			  
    	 smi_msg_pri: coverpoint m_smi_seq.smi_msg_pri {
		bins pri_0 = {'h0};
		bins pri_1 = {'h1};
		bins pri_2 = {'h2};
		bins pri_3 = {'h3};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
		bins pri_4 = {'h4};
		bins pri_5 = {'h5};
		bins pri_6 = {'h6};
		bins pri_7 = {'h7};
 	<% } else {%>
	 ignore_bins pri_4 = {'h4};
	 ignore_bins pri_5 = {'h5};
	 ignore_bins pri_6 = {'h6};
	 ignore_bins pri_7 = {'h7};
	<% } %>
	}
   <% } %>
<% } %>
    	 smi_ndp_len: coverpoint m_smi_seq.smi_ndp_len{
             bins w_CMD_REQ_NDP = {w_CMD_REQ_NDP};
             bins w_C_CMD_RSP_NDP = {w_C_CMD_RSP_NDP};
             bins w_NC_CMD_RSP_NDP = {w_NC_CMD_RSP_NDP};

         <% if ((obj.fnNativeInterface == "ACE") || (obj.fnNativeInterface == "ACELITE-E") ) { %>
	<%if(obj.fnNativeInterface == "ACE") { %>																
             bins w_UPD_REQ_NDP = {w_UPD_REQ_NDP};
             bins w_UPD_RSP_NDP = {w_UPD_RSP_NDP};
        <% } %>
             bins w_SNP_REQ_NDP = {w_SNP_REQ_NDP};
             bins w_SNP_RSP_NDP = {w_SNP_RSP_NDP};
         <% } %>

             bins w_STR_REQ_NDP = {w_STR_REQ_NDP};
             bins w_STR_RSP_NDP = {w_STR_RSP_NDP};
             bins w_DTR_REQ_NDP = {w_DTR_REQ_NDP};
             bins w_DTR_RSP_NDP = {w_DTR_RSP_NDP};
             bins w_DTW_REQ_NDP = {w_DTW_REQ_NDP};
             bins w_DTW_RSP_NDP = {w_DTW_RSP_NDP};
<%if(!obj.testBench == "io_aiu") { %>
             bins W_HNT_REQ_NDP = {W_HNT_REQ_NDP};
             bins W_HNT_RSP_NDP = {W_HNT_RSP_NDP};
             bins w_MRD_REQ_NDP = {w_MRD_REQ_NDP};
             bins w_MRD_RSP_NDP = {w_MRD_RSP_NDP};
             bins w_RB_REQ_NDP  = {w_RB_REQ_NDP};
             bins w_RB_RSP_NDP  = {w_RB_RSP_NDP};
             bins w_RBUSE_REQ_NDP = {w_RBUSE_REQ_NDP};
             bins w_RBUSE_RSP_NDP = {w_RBUSE_RSP_NDP};

<% } %>
        <%if(obj.testBench == "chi_aiu") { %>
             ignore_bins W_TRE_RSP_NDP = {W_TRE_RSP_NDP};
        <% } %>
        <% if ((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")){ %>
             ignore_bins W_TRE_RSP_NDP = {W_TRE_RSP_NDP};
        <% } %>
<%if((obj.testBench == "io_aiu") && obj.DutInfo.eAc && (obj.DutInfo.cmpInfo.nDvmMsgInFlight > 0) ) { %>
             bins w_CMP_RSP_NDP = {w_CMP_RSP_NDP};
<% } %>
         <% if (obj.fnNativeInterface == "ACE") { %>
             bins W_CME_RSP_NDP = {W_CME_RSP_NDP};
         <% } %>
        <% if ((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")){ %>
             ignore_bins W_CME_RSP_NDP = {W_CME_RSP_NDP};
         <% } %>


         }

    	 // smi_ndp: coverpoint m_smi_seq.smi_ndp;
    	 smi_msg_id: coverpoint m_smi_seq.smi_msg_id;
       <%if((obj.testBench == "chi_aiu") || (obj.testBench == "io_aiu")){ %>
    	 smi_msg_err: coverpoint m_smi_seq.smi_msg_err {
           bins smi_msg_err0 = {0};
         }
       <% } else { %>
    	 smi_msg_err: coverpoint m_smi_seq.smi_msg_err;
       <% } %>
    	 smi_dp_present: coverpoint m_smi_seq.smi_dp_present;
    	 smi_dp_valid: coverpoint m_smi_seq.smi_dp_valid;
	 smi_dp_ready: coverpoint m_smi_seq.smi_dp_ready;
	 smi_dp_last: coverpoint m_smi_seq.smi_dp_last;


          <% unpack = funitids_dce_dmi() %>

    	 smi_targ_id: coverpoint m_smi_seq.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]{
         <% for (var i = 0; i < funitids_dce_dmi().length; i++) { %>
            bins coverpoint_smi_targ_id_<%=i%> = {<%=unpack[i]%>};
         <% } %>
         }

    	 smi_src_id: coverpoint m_smi_seq.smi_src_id[WSMISRCID-1:WSMINCOREPORTID]{
         <% for (var i = 0; i < funitids_dce_dmi().length; i++) { %>
            bins coverpoint_smi_targ_id_<%=i%> = {<%=unpack[i]%>};
         <% } %>
         }

       	 smi_src_ncore_unit_id: coverpoint m_smi_seq.smi_src_ncore_unit_id{
         <% for (var i = 0; i < funitids_dce_dmi().length; i++) { %>
            bins coverpoint_smi_targ_id_<%=i%> = {<%=unpack[i]%>};
         <% } %>
         }

       	 smi_targ_ncore_unit_id: coverpoint m_smi_seq.smi_targ_ncore_unit_id{
         <% for (var i = 0; i < funitids_dce_dmi().length; i++) { %>
            bins coverpoint_smi_targ_ncore_unit_id_<%=i%> = {<%=unpack[i]%>};
         <% } %>
         }

    	 // smi_src_ncore_port_id: coverpoint m_smi_seq.smi_src_ncore_port_id;
    	 // smi_targ_ncore_port_id: coverpoint m_smi_seq.smi_targ_ncore_port_id;

        <% } %>
	 <% } %>

     <%     if(0 &&((obj.Block =='dmi') || (obj.Block =='dce'))) { %>
cross_of_mrdtype_and_smisize: cross m_smi_seq.smi_msg_type, access_size
{
        illegal_bins illegal_cmd_values = binsof(CMD_RD_NC, CMD_WR_NC_PTL, CMD_WR_NC_FULL);
	option.weight = 1;
}
<% } %>

<%     if(obj.Block =='dmi') { %>
         prim_secondary:coverpoint m_smi_seq.smi_prim{
           bins primary   = {1};
           bins secondary = {0};
         }
cross_of_dtwtype_and_smiprim: cross prim_secondary ,dtw_type
{
        ignore_bins ignore_sec_nodata   = binsof(dtw_type) intersect {DTW_NO_DATA} && binsof(prim_secondary) intersect {0};
        ignore_bins ignore_sec_clndata  = binsof(dtw_type) intersect {DTW_DATA_CLN} && binsof(prim_secondary) intersect {0};
        ignore_bins ignore_sec_ptldata  = binsof(dtw_type) intersect {DTW_DATA_PTL} && binsof(prim_secondary) intersect {0};
        option.weight = 1;
}
<% } %>

//cross_of_mrdtype_and_smiac: cross m_smi_seq.smi_msg_type, m_smi_seq.smi_ac
//{
//	option.weight = 1;
//}

// Crossing with msg_type to get per port coverage for DII
<%     if(obj.Block =='dii') { %>
// --------Str signals--------
// Cover.DII.STRreq.Return_buffer_id
//STR type pkts dont have visibility
//cross_of_strtype_and_visibility: cross str_type, visibility;
<% if (smiObj.WSMINDPPROT_EN) { %>
// Cover.DII.STRreq.Ndp_protection
cross_of_strtype_and_ndp_protection: cross str_type, ndp_protection; 
<% } %>

// --------Dtr signals--------
//#Cover.DII.DTRreq.Response_level
cross_of_dtrtype_and_response_level: cross dtr_type, response_level {
    ignore_bins IGNORE_DTR_RL_COHERENCY = binsof (response_level) intersect {SMI_RL_COHERENCY};
}
//#Cover.DII.DTRreq.Trace_me
cross_of_dtrtype_and_trace_me: cross dtr_type, trace_me;
//#Cover.DII.DTRreq.Data_word
// DII soesnt support long DW of data
//cross_of_dtrtype_and_data_word: cross dtr_type, data_word;
<% if (smiObj.WSMINDPPROT_EN) { %>
//#Cover.DII.DTRreq.Ndp_protection
cross_of_dtrtype_and_ndp_protection: cross dtr_type, ndp_protection;
<% } %>

// --------Dtw signals--------
//#Cover.DII.DTWreq.Response_level
cross_of_dtwtype_and_response_level: cross dtw_type, response_level;
//#Cover.DII.DTWreq.Trace_me
cross_of_dtwtype_and_trace_me: cross dtw_type, trace_me;
<% if (smiObj.WSMINDPPROT_EN) { %>
//#Cover.DII.DTRreq.Ndp_protection
cross_of_dtwtype_and_ndp_protection: cross dtw_type, ndp_protection;
<% } %>

// --------Cmd signals--------
//#Cover.DII.CMDreq.Visibility
cross_of_cmdtype_and_visibility: cross cmd_type, visibility {
    <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix == "sys_dii") { %>
        ignore_bins IGNORE_CMD_TYPE_VIS_0 = binsof (visibility) intersect {0};
    <% } %>
}
//<% if(obj.DiiInfo[obj.Id].strRtlNamePrefix != "sys_dii") { %>
    //#Cover.DII.CMDreq.Allocate
    cross_of_cmdtype_and_allocate: cross cmd_type, allocate;
    //#Cover.DII.CMDreq.Cacheable
    cross_of_cmdtype_and_cacheable: cross cmd_type, cacheable;
    //#Cover.DII.CMDreq.Mpf1.Alen
    cross_of_cmdtype_and_burst_length: cross cmd_type, burst_length;
//<% } %>
//#Cover.DII.CMDreq.Order
cross_of_cmdtype_and_order: cross cmd_type, order;
//#Cover.DII.CMDreq.Storage_type
cross_of_cmdtype_and_storage_type: cross cmd_type, storage_type {
    <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix == "sys_dii") { %>
        ignore_bins IGNORE_CMD_TYPE_ST_0 = binsof (storage_type) intersect {0};
    <% } %>
}
//#Cover.DII.CMDreq.Non_secure
cross_of_cmdtype_and_non_secure_access: cross cmd_type, non_secure_access;
//#Cover.DII.CMDreq.Privilege
cross_of_cmdtype_and_privilege: cross cmd_type, privilege;
//#Cover.DII.CMDreq.Response_level
cross_of_cmdtype_and_response_level: cross cmd_type, response_level {
    ignore_bins IGNORE_DTR_RL_COHERENCY = binsof (response_level) intersect {SMI_RL_COHERENCY};
}
//#Cover.DII.CMDreq.Trace_me
cross_of_cmdtype_and_trace_me: cross cmd_type, trace_me;
//#Cover.DII.CMDreq.Mpf1.Asize
cross_of_cmdtype_and_burst_size: cross cmd_type, burst_size;
//#Cover.DII.CMDreq.Mpf1.Burst_type
cross_of_cmdtype_and_burst_type: cross cmd_type, burst_type;
//#Cover.DII.CMDreq.Size
cross_of_cmdtype_and_access_size: cross cmd_type, access_size;
//#Cover.DII.CMDreq.Intfsize
cross_of_cmdtype_and_interface_size: cross cmd_type, interface_size;
//#Cover.DII.CMDreq.endian
cross_of_cmdtype_and_endianness: cross cmd_type, endianness;
//#Cover.DII.CMDreq.non_exclusive
cross_of_cmdtype_and_exclusive: cross cmd_type, exclusive;
//#Cover.DII.CMDreq.tof
cross_of_cmdtype_and_transaction_odering_framework : cross cmd_type,transaction_odering_framework;
//cross_all_possible_smi_attributes: cross cmd_type, storage_type, access_size, burst_type, burst_size, burst_length, interface_size, critical_data_beat;

cross_dii_cmd_type_st_vz_or: cross cmd_type, visibility, storage_type, order {
    ignore_bins IGNORE_ST_0_OR_ENDPOINT = binsof (storage_type) intersect {0} && binsof (order) intersect {3};
    <% if(obj.DiiInfo[obj.Id].strRtlNamePrefix == "sys_dii") { %>
        ignore_bins IGNORE_VIS_0_ST_0 = binsof (storage_type) intersect {0} || binsof (visibility) intersect {0};
    <% } %>
    <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
        ignore_bins IGNORE_VZ_1_ST_0_OR_NONE = binsof (visibility) intersect {1} && binsof (storage_type) intersect {0} && binsof (order) intersect {0};
        ignore_bins IGNORE_VZ_1_ST_0_OR_REQUEST = binsof (visibility) intersect {1} && binsof (storage_type) intersect {0} && binsof (order) intersect {2};
    <% } %>

}

cross_dii_access_size_n_mpf_size: cross access_size, burst_size;

<% if (smiObj.WSMINDPPROT_EN) { %>
//#Cover.DII.CMDreq.Ndp_protection
cross_of_cmdtype_and_ndp_protection: cross cmd_type, ndp_protection;
<% } %>

<% } %>

endgroup 

<% if(obj.Block =='dii') { %>
    toggle_coverage toggle_cg_qos_cmdtype;
    toggle_coverage toggle_cg_ndp_aux_cmdtype;
    //toggle_coverage toggle_cg_mpf2_stash_valid_cmdtype;
    //toggle_coverage toggle_cg_mpf2_stash_lpid_cmdtype;
    toggle_coverage toggle_cg_mpf2_flowid_cmdtype;
    //toggle_coverage toggle_cg_mpf2_dtr_msg_id_cmdtype;
    toggle_coverage toggle_cg_dp_user_dtwtype;
    toggle_coverage toggle_cg_dp_be_dtwtype;
    toggle_coverage toggle_cg_dp_data_dtwtype;
    toggle_coverage toggle_cg_dp_dbad_dtwtype;
    //toggle_coverage toggle_cg_data_word_dtwtype;
    //toggle_coverage toggle_cg_ndp_user_dtwtype;
<% } %>
//#Cover.DMI.Concerto.v3.0.DpToggleCov
<% if(obj.Block == 'dmi') { %>
    toggle_coverage toggle_cg_dtwtype_dp_data;
    toggle_coverage toggle_cg_dtwtype_dp_be;
    toggle_coverage toggle_cg_dtwtype_dp_dbad;
    toggle_coverage toggle_cg_dtwtype_dp_aux;
    toggle_coverage toggle_cg_dtrtype_dp_data;
    toggle_coverage toggle_cg_dtrtype_dp_dbad;
    toggle_coverage toggle_cg_dtrtype_dp_aux;

<% } %>

    function new(string name = "smi_coverage", uvm_component parent = null);
        super.new(name, parent);
        m_smi_seq = new();
        smi_transaction_type = new();
<%     if(obj.Block =='dii') { %>
        dp_dwid_dtrtype = new();
        dp_protection_dtrtype= new();
        dp_dwid_dtwtype = new();
        dp_protection_dtwtype= new();
        dii_smi_addr = new();
<% } %>
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_smi = new ("analysis_smi", this);
<% if(obj.Block =='dii') { %>
        toggle_cg_qos_cmdtype = new(WSMIQOS, "smi_qos");
        toggle_cg_ndp_aux_cmdtype = new(WSMINDPAUX, "smi_ndp_aux");
        //toggle_cg_mpf2_stash_valid_cmdtype = new(WSMISTASHVALID, "smi_mpf2_stash_valid");
        //toggle_cg_mpf2_stash_lpid_cmdtype = new(WSMISTASHLPID, "smi_mpf2_stash_valid");
        toggle_cg_mpf2_flowid_cmdtype = new(WSMIMPF2-1, "smi_mpf2_flowd");
        //toggle_cg_mpf2_dtr_msg_id_cmdtype = new(WSMIMSGID, "smi_mpf2_dtr_msgid");
        toggle_cg_dp_user_dtwtype = new(wSmiDPuser, "smi_dp_user");
        toggle_cg_dp_be_dtwtype = new(wSmiDPbe, "smi_dp_be");
        toggle_cg_dp_data_dtwtype = new(wSmiDPdata, "smi_dp_data");
        toggle_cg_dp_dbad_dtwtype = new(wSmiDPdbad, "smi_dp_dbad");
        //toggle_cg_data_word_dtwtype= new(WSMIMPF1, "smi_mpf1_dw");
        //toggle_cg_ndp_user_dtwtype = new(WSMINDPAUX, "smi_ndp_aux");
<% } %>
<% if(obj.Block == 'dmi') { %>
        toggle_cg_dtwtype_dp_data   = new(wSmiDPbe, "smi_dtw_dp_data");
        toggle_cg_dtwtype_dp_be     = new(wSmiDPbe, "smi_dtw_dp_be");
        toggle_cg_dtwtype_dp_dbad   = new(wSmiDPdbad, "smi_dtw_dp_dbad");
        toggle_cg_dtwtype_dp_aux    = new(wSmiDPconcuser, "smi_dtw_dp_concuser");
        toggle_cg_dtrtype_dp_data   = new(wSmiDPbe, "smi_dtr_dp_data");
        toggle_cg_dtrtype_dp_dbad   = new(wSmiDPdbad, "smi_dtr_dp_dbad");
        toggle_cg_dtrtype_dp_aux    = new(wSmiDPconcuser, "smi_dtr_dp_concuser");

<% } %>

    endfunction : build_phase

    extern virtual function void write_smi(smi_seq_item m_pkt);

endclass : smi_coverage

function void smi_coverage::write_smi(smi_seq_item m_pkt);
    smi_seq_item m_packet;
    time t_smi_vld_seen;
    int       find_smi_q[$];

    m_packet = new();
    $cast(m_packet,m_pkt);
    m_smi_seq.copy(m_packet);

   <% if(obj.Block =='chi_aiu') { %>

     if (m_smi_seq.smi_conc_msg_class == eConcMsgSnpReq) begin
         m_smi_snp_cov_seq = new();
         m_smi_snp_cov_seq.copy(m_smi_seq);
         m_smi_snp_seq.push_back(m_smi_snp_cov_seq);
         //smi_up   = m_smi_seq.smi_ndp[SNP_REQ_UP_MSB:SNP_REQ_UP_LSB];
         //m_smi_snp_seq.push_back(m_smi_seq);
      end

     if (m_smi_seq.smi_conc_msg_class == eConcMsgSnpRsp) begin
            find_smi_q = {};
            find_smi_q = m_smi_snp_seq.find_index with (item.smi_msg_id == m_smi_seq.smi_rmsg_id);
            if(find_smi_q.size() == 1) begin
                smi_snp_type = m_smi_snp_seq[find_smi_q[0]].smi_msg_type;
                rv_rs  = {m_smi_seq.smi_cmstatus[SMICMSTATUSSNPRSPRV],m_smi_seq.smi_cmstatus[SMICMSTATUSSNPRSPRS]};
                smi_up = m_smi_snp_seq[find_smi_q[0]].smi_ndp[SNP_REQ_UP_MSB:SNP_REQ_UP_LSB];
                m_smi_snp_seq.delete(find_smi_q[0]);
            end
     end

    <% } %>

    m_smi_seq.unpack_smi_seq_item();
    if(m_smi_seq.isCmdMsg()) begin
       $cast(cmd_type,m_smi_seq.smi_msg_type);
    end
   
//    cmd_type = m_smi_seq.smi_ecmd_type;
<% if(obj.Block =='aiu' || obj.Block =='chi_aiu') { %>
    // TODO put gaurd for data msg
    if (m_smi_seq.smi_dp_present) begin
        t_smi_vld_seen = (m_smi_seq.t_smi_ndp_valid < m_smi_seq.t_smi_dp_valid[0]) ? m_smi_seq.t_smi_ndp_valid : m_smi_seq.t_smi_dp_valid[0];
    end else begin
        t_smi_vld_seen = m_smi_seq.t_smi_ndp_valid;
    end
    vld_rdy_delay = ($time - t_smi_vld_seen)/10ns;
    if (m_smi_seq.smi_mpf3_intervention_unit_id == m_smi_seq.smi_targ_ncore_unit_id)
        isMpf3AiuID = 1;
    else
        isMpf3AiuID = 0;
    if (m_smi_seq.smi_mpf1_stash_nid == m_smi_seq.smi_targ_ncore_unit_id)
        isStashnidAiuID = 1;
    else
        isStashnidAiuID = 0;
    //if (m_smi_seq.smi_src_id == 1)
    if (m_smi_seq.smi_src_id[WSMISRCID-1:WSMINCOREPORTID] == <%=obj.Id%>)
        smi_msg_direction = 1; // msg generated by chi_aiu
    else 
        smi_msg_direction = 0; // msg received by chi_aiu

    smi_qos = m_smi_seq.smi_qos ;

<% } %>
   uvm_report_info("DCDEBUG",$sformatf("before sample isDtrReq:%0d cmstatus:b%b smi_cmstatus_err:%0d",m_smi_seq.isDtrMsg(),m_smi_seq.smi_cmstatus,m_smi_seq.smi_cmstatus_err),UVM_MEDIUM);
    smi_transaction_type.sample();
<% if(obj.Block =='dii') { %>
    //$display("dii src and trag is %0d and %0d", m_smi_seq.smi_src_ncore_unit_id, m_smi_seq.smi_targ_ncore_unit_id);
    // --------Cmd signals--------
    // #CoverToggle.DII.CMDreq.Quality_of_service
    if (m_smi_seq.isCmdMsg()) begin
        for (int i = 0; i < WSMIQOS; i++) begin
            toggle_cg_qos_cmdtype.field[i] = m_smi_seq.smi_qos[i];
        end
        toggle_cg_qos_cmdtype.sample();
    end
    //#CoverToggle.DII.CMDreq.Ndp_user
    if (m_smi_seq.isCmdMsg()) begin
        for (int i = 0; i < WSMINDPAUX; i++) begin
            toggle_cg_ndp_aux_cmdtype.field[i] = m_smi_seq.smi_ndp_aux[i];
        end
        toggle_cg_ndp_aux_cmdtype.sample();
    end
    /*if (m_smi_seq.isCmdMsg()) begin
        for (int i = 0; i < WSMISTASHVALID; i++) begin
            toggle_cg_mpf2_stash_valid_cmdtype.field[i] = m_smi_seq.smi_mpf2_stash_valid[i];
        end
        toggle_cg_mpf2_stash_valid_cmdtype.sample();
    end
    if (m_smi_seq.isCmdMsg()) begin
        for (int i = 0; i < WSMISTASHLPID; i++) begin
            toggle_cg_mpf2_stash_lpid_cmdtype.field[i] = m_smi_seq.smi_mpf2_stash_lpid[i];
        end
        toggle_cg_mpf2_stash_lpid_cmdtype.sample();
    end*/
    // DTR msg_id is set from the design and is not driven by the Test stimulus
    //if (m_smi_seq.isCmdMsg()) begin
    //    for (int i = 0; i < WSMIMSGID; i++) begin
    //        toggle_cg_mpf2_dtr_msg_id_cmdtype.field[i] = m_smi_seq.smi_mpf2_dtr_msg_id[i];
    //    end
    //    toggle_cg_mpf2_dtr_msg_id_cmdtype.sample();
    //end
    //#CoverToggle.DII.CMDreq.Mpf2
    if (m_smi_seq.isCmdMsg()) begin
        for (int i = 0; i < WSMIMPF2-1; i++) begin
            toggle_cg_mpf2_flowid_cmdtype.field[i] = m_smi_seq.smi_mpf2_flowid[i];
        end
        toggle_cg_mpf2_flowid_cmdtype.sample();
    end

    dii_smi_addr.sample();

    // --------Dtr signals--------
    //#Cover.DII.DTRreq.Double_word_id
    if (m_smi_seq.isDtrMsg()) begin
        foreach (m_smi_seq.smi_dp_dwid[i]) begin
            m_smi_dp_dwid = m_smi_seq.smi_dp_dwid[i];
            dp_dwid_dtrtype.sample();
        end
    end
    //#Cover.DII.DTRreq.Dp_protection
    if (m_smi_seq.isDtrMsg()) begin
        foreach (m_smi_seq.smi_dp_protection[i]) begin
            m_smi_dp_protection = m_smi_seq.smi_dp_protection[i];
            dp_protection_dtrtype.sample();
        end
    end

    // --------Dtw signals--------
    //#Cover.DII.DTWreq.Double_word_id
    if (m_smi_seq.isDtwMsg()) begin
        foreach (m_smi_seq.smi_dp_dwid[i]) begin
            m_smi_dp_dwid = m_smi_seq.smi_dp_dwid[i];
            dp_dwid_dtwtype.sample();
        end
    end
    //#Cover.DII.DTWreq.Dp_protection
    if (m_smi_seq.isDtwMsg()) begin
        foreach (m_smi_seq.smi_dp_protection[i]) begin
            m_smi_dp_protection = m_smi_seq.smi_dp_protection[i];
            dp_protection_dtwtype.sample();
        end
    end
    //#CoverToggle.DII.DTWreq.Ndp_user
    //if (m_smi_seq.isDtwMsg()) begin
    //    for (int j = 0; j < WSMINDPAUX; j++) begin
    //        toggle_cg_ndp_user_dtwtype.field[j] = m_smi_seq.smi_ndp_aux[j];
    //    end
    //    toggle_cg_ndp_user_dtwtype.sample();
    //end
    //#CoverToggle.DII.DTWreq.Dp_user
    if (m_smi_seq.isDtwMsg()) begin
        for (int i = 0; i < m_smi_seq.smi_dp_user.size(); i++) begin
            for (int j = 0; j < wSmiDPuser; j++) begin
                toggle_cg_dp_user_dtwtype.field[j] = m_smi_seq.smi_dp_user[i][j];
            end
            toggle_cg_dp_user_dtwtype.sample();
        end
    end
    //#CoverToggle.DII.DTWreq.Data_word
    // DII supports only 64 bytes and not a long DW
    //if (m_smi_seq.isDtwMsg()) begin
    //    for (int j = 0; j < WSMIMPF1; j++) begin
    //        toggle_cg_data_word_dtwtype.field[j] = m_smi_seq.smi_mpf1_dtr_long_dtw[j];
    //    end
    //    toggle_cg_data_word_dtwtype.sample();
    //end
    //#CoverToggle.DII.DTWreq.Dp_data
    if (m_smi_seq.isDtwMsg()) begin
        for (int i = 0; i < m_smi_seq.smi_dp_data.size(); i++) begin
            for (int j = 0; j < wSmiDPdata; j++) begin
                toggle_cg_dp_data_dtwtype.field[j] = m_smi_seq.smi_dp_data[i][j];
            end
            toggle_cg_dp_data_dtwtype.sample();
        end
    end
    //#CoverToggle.DII.DTWreq.Byte_enable
    if (m_smi_seq.isDtwMsg()) begin
        for (int i = 0; i < m_smi_seq.smi_dp_be.size(); i++) begin
            for (int j = 0; j < WSMIDPBE; j++) begin
                toggle_cg_dp_be_dtwtype.field[j] = m_smi_seq.smi_dp_be[i][j];
            end
            toggle_cg_dp_be_dtwtype.sample();
        end
    end
    //#CoverToggle.DII.DTWreq.Poison
    if (m_smi_seq.isDtwMsg()) begin
        for (int i = 0; i < m_smi_seq.smi_dp_dbad.size(); i++) begin
            for (int j = 0; j < WSMIDPDBAD; j++) begin
                toggle_cg_dp_dbad_dtwtype.field[j] = m_smi_seq.smi_dp_dbad[i][j];
            end
            toggle_cg_dp_dbad_dtwtype.sample();
        end
    end
<% } %>

<% if(obj.Block == 'dmi') { %>
    // #Cover.DMI.Concerto.v3.0.DtwReqData
    if(m_smi_seq.isDtwMsg()) begin
        for (int i=0; i < m_smi_seq.smi_dp_data.size(); i++) begin
            for (int j = 0; j < WSMIDPDATA; j++) begin
                toggle_cg_dtwtype_dp_data.field[j] = m_smi_seq.smi_dp_data[i][j];
            end
            toggle_cg_dtwtype_dp_data.sample();
        end
    end
    // #Cover.DMI.Concerto.v3.0.DtwReqBEtoggle
    if(m_smi_seq.isDtwMsg()) begin
        for (int i=0; i < m_smi_seq.smi_dp_be.size(); i++) begin
            for (int j = 0; j < WSMIDPBE; j++) begin
                toggle_cg_dtwtype_dp_be.field[j] = m_smi_seq.smi_dp_be[i][j];
            end
            toggle_cg_dtwtype_dp_be.sample();
        end
    end
    // #Cover.DMI.Concerto.v3.0.DtwReqDbadset
    if(m_smi_seq.isDtwMsg()) begin
        for (int i=0; i < m_smi_seq.smi_dp_dbad.size(); i++) begin
            for (int j = 0; j < WSMIDPDBAD; j++) begin
                toggle_cg_dtwtype_dp_dbad.field[j] = m_smi_seq.smi_dp_dbad[i][j];
            end
            toggle_cg_dtwtype_dp_dbad.sample();
        end
    end
    // #Cover.DMI.Concerto.v3.0.DtwReqAux
    if(m_smi_seq.isDtwMsg()) begin
        for (int i=0; i < m_smi_seq.smi_dp_concuser.size(); i++) begin
            for (int j=0; j < WSMIDPCONCUSER; j++) begin 
                toggle_cg_dtwtype_dp_aux.field[j] = m_smi_seq.smi_dp_concuser[i][j];
            end
            toggle_cg_dtwtype_dp_aux.sample();
        end
    end
    // #Cover.DMI.Concerto.v3.0.DtrReqData
    if(m_smi_seq.isDtrMsg()) begin
        for (int i=0; i < m_smi_seq.smi_dp_data.size(); i++) begin
            for (int j = 0; j < WSMIDPDATA; j++) begin
                toggle_cg_dtrtype_dp_data.field[j] = m_smi_seq.smi_dp_data[i][j];
            end
            toggle_cg_dtrtype_dp_data.sample();
        end
    end
    // #Cover.DMI.Concerto.v3.0.DtrReqDbadset
    if(m_smi_seq.isDtrMsg()) begin
        for (int i=0; i < m_smi_seq.smi_dp_dbad.size(); i++) begin
            for (int j = 0; j < WSMIDPDBAD; j++) begin
                toggle_cg_dtrtype_dp_dbad.field[j] = m_smi_seq.smi_dp_dbad[i][j];
            end
            toggle_cg_dtrtype_dp_dbad.sample();
        end
    end
    // #Cover.DMI.Concerto.v3.0.DtrReqAux
    if(m_smi_seq.isDtrMsg()) begin
        for (int i=0; i < m_smi_seq.smi_dp_concuser.size(); i++) begin
            for (int j=0; j < WSMIDPCONCUSER; j++) begin 
                toggle_cg_dtrtype_dp_aux.field[j] = m_smi_seq.smi_dp_concuser[i][j];
            end
            toggle_cg_dtrtype_dp_aux.sample();
        end
    end
<% } %>

endfunction : write_smi

<% if (obj.useResiliency) { %>
/**
 * Below class will be used to capture the resiliency coverage
 * where error testing had been done. To avoid ill-legal bins hit, 
 * override smi_coverage class with smi_resiliency_coverage class.
 */

//#Cover.IOAIU.Smi.UncorrectableErr
//#Cover.IOAIU.Smi.correctableErr
class smi_resiliency_coverage extends smi_coverage;

  `uvm_component_param_utils(smi_resiliency_coverage)

  // adding defines to ease the visulization of code
  `define X_of2(cp1, cp2) \
    cross_of_``cp1``_and_``cp2 : cross cp1, cp2;

  <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>

  `define X_with_hdr_ndp_error(cp1) \
    `X_of2(cp1, hdr_corr_error) \
    `X_of2(cp1, ndp_corr_error) \
    `X_of2(cp1, hdr_uncorr_error) \
    `X_of2(cp1, ndp_uncorr_error)

  `define X_with_dp_error(cp1) \
    `X_of2(cp1, dp_corr_error) \
    `X_of2(cp1, dp_uncorr_error)

  <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
  `define X_with_hdr_ndp_error(cp1) \
    `X_of2(cp1, hdr_parity_error) \
    `X_of2(cp1, ndp_parity_error)

  `define X_with_dp_error(cp1) \
    `X_of2(cp1, dp_parity_error)
  <% } %>

  smi_seq_item  m_smi_seq;
  eMsgCMD	 eCmdMsg;
  eMsgCCmdRsp	 eCmdRsp;
  eMsgNCCmdRsp	 eNcCmdRsp;
  eMsgSNP	 eSnpMsg;
  eMsgSnpRsp	 eSnpRsp;
  eMsgMRD	 eMrdMsg;
  eMsgMrdRsp	 eMrdRsp;
  eMsgSTR	 eStrMsg;
  eMsgStrRsp	 eStrRsp;
  eMsgDTR	 eDtrMsg;
  eMsgDtrRsp	 eDtrRsp;
  eMsgDTW	 eDtwMsg;
  eMsgDTWMrgMRD eDtwMrgMsg;
  eMsgDtwRsp	 eDtwRsp;
  eMsgDtwDbgReq  eDtwDbgMsg;
  eMsgDtwDbgRsp  eDtwDbgRsp;
  eMsgUPD	 eUpdMsg;
  eMsgUpdRsp	 eUpdRsp;
  eMsgRBReq	 eRbMsg;
  eMsgRBRsp	 eRbRsp;
  eMsgRBUsed	 eRbuMsg;
  eMsgRBUseRsp	 eRbuRsp;
  eMsgCmpRsp	 eCmpRsp;

  covergroup smi_transaction_resiliency;

  <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
    // correctable error
    ndp_corr_error   : coverpoint m_smi_seq.ndp_corr_error{
      bins injected = {[1:$]};
    }
    hdr_corr_error   : coverpoint m_smi_seq.hdr_corr_error{
      bins injected = {[1:$]};
    }
    <% if(obj.Block != 'dce') { %>
    dp_corr_error    : coverpoint m_smi_seq.dp_corr_error{
      bins injected = {[1:$]};
    }
    <% } %>

    // un-correctable error
    ndp_uncorr_error : coverpoint m_smi_seq.ndp_uncorr_error{
      bins injected = {[1:$]};
    }
    hdr_uncorr_error : coverpoint m_smi_seq.hdr_uncorr_error{
      bins injected = {[1:$]};
    }
    <% if(obj.Block != 'dce') { %>
    dp_uncorr_error  : coverpoint m_smi_seq.dp_uncorr_error{
      bins injected = {[1:$]};
    }
    <% } %>
  <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
     // un-correctable error
    ndp_parity_error : coverpoint m_smi_seq.ndp_parity_error{
      bins injected = {[1:$]};
    }
    hdr_parity_error : coverpoint m_smi_seq.hdr_parity_error{
      bins injected = {[1:$]};
    }
    <% if(obj.Block != 'dce') { %>
    dp_parity_error  : coverpoint m_smi_seq.dp_parity_error{
      bins injected = {[1:$]};
    }
    <% } %>
  <% } %>

  <% if ((obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") || (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity")) { %>

  // CmdReqMsg_type
	<% if((obj.Block =='dce') || (obj.Block =='dii') || (obj.Block =='dmi') || (obj.Block =='dve')) { %>
	  CmdReqMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins CmdReqMsg     = {[eCmdMsg.first():eCmdMsg.last()]};
    }
    `X_with_hdr_ndp_error(CmdReqMsg_type)
  <% } %>

  // C_CmdRspMsg_type
	<% if((obj.Block =='io_aiu') || (obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
	  C_CmdRspMsg_type	: coverpoint m_smi_seq.smi_msg_type {
      bins C_CmdRspMsg   = {[eCmdRsp.first():eCmdRsp.last()]};
    }
    `X_with_hdr_ndp_error(C_CmdRspMsg_type)
  <% } %>

  // NC_CmdRspMsg_type
	<% if((obj.Block =='io_aiu') || (obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
	  NC_CmdRspMsg_type	: coverpoint m_smi_seq.smi_msg_type {
      bins NC_CmdRspMsg  = {[eNcCmdRsp.first():eNcCmdRsp.last()]};
    }
    `X_with_hdr_ndp_error(NC_CmdRspMsg_type)
  <% } %>

  // SnpReqMsg_type
	<% if((obj.Block =='io_aiu') || (obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
	  SnpReqMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins SnpReqMsg     = {[eSnpMsg.first():eSnpMsg.last()]};	
    }
    `X_with_hdr_ndp_error(SnpReqMsg_type)
  <% } %>

  // SnpRspMsg_type
	<% if((obj.Block =='dce') || (obj.Block =='dve')) { %>
	  SnpRspMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins SnpRspMsg     = {[eSnpRsp.first():eSnpRsp.last()]};
    }
    `X_with_hdr_ndp_error(SnpRspMsg_type)
  <% } %>

  // MrdReqMsg_type
	<% if((obj.Block =='dmi')) { %>
	  MrdReqMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins MrdReqMsg     = {[eMrdMsg.first():eMrdMsg.last()]};
    }
    `X_with_hdr_ndp_error(MrdReqMsg_type)
  <% } %>

  // MrdRspMsg_type
	<% if((obj.Block =='dce')) { %>
	  MrdRspMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins MrdRspMsg     = {[eMrdRsp.first():eMrdRsp.last()]};
    }
    `X_with_hdr_ndp_error(MrdRspMsg_type)
  <% } %>

  // StrReqMsg_type
	<% if((obj.Block =='io_aiu') || (obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
	  StrReqMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins StrReqMsg     = {[eStrMsg.first():eStrMsg.last()]};
    }
    `X_with_hdr_ndp_error(StrReqMsg_type)
  <% } %>

  // StrRspMsg_type
	<% if((obj.Block =='dce') || (obj.Block =='dii') || (obj.Block =='dmi') || (obj.Block =='dve')) { %>
	  StrRspMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins StrRspMsg     = {[eStrRsp.first():eStrRsp.last()]};
    }
    `X_with_hdr_ndp_error(StrRspMsg_type)
  <% } %>

  // DtrReqMsg_type
  //#Cover.IOAIU.SMI.DtrReq.CMType
	<% if((obj.Block =='io_aiu') || (obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
	  DtrReqMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins DtrReqMsg     = {[eDtrMsg.first():eDtrMsg.last()]};
    }
    `X_with_hdr_ndp_error(DtrReqMsg_type)
    `X_with_dp_error(DtrReqMsg_type)
  <% } %>

  // DtrRspMsg_type
	<% if((obj.Block =='io_aiu') || (obj.Block =='aiu') || (obj.Block =='dii') || (obj.Block =='dmi')) { %>
	  DtrRspMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins DtrRspMsg     = {[eDtrRsp.first():eDtrRsp.last()]};
    }
    `X_with_hdr_ndp_error(DtrRspMsg_type)
  <% } %>

  // DtwReqMsg_type
  //#Cover.IOAIU.SMI.DtwReq.CMType
	<% if((obj.Block =='io_aiu') ||(obj.Block =='dii') || (obj.Block =='dmi') || (obj.Block =='dve')) { %>
	  DtwReqMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins DtwReqMsg     = {[eDtwMsg.first():eDtwMsg.last()]};
    }
    `X_with_hdr_ndp_error(DtwReqMsg_type)
    `X_with_dp_error(DtwReqMsg_type)
  <% } %>

 
    <% if((obj.Block != 'dce')) { %>
  // DtwDbgReqMsg_type
    <% if((obj.Block == 'dve')) { %>
    DtwDbgMsg_type : coverpoint m_smi_seq.smi_msg_type {
      bins DtwDbgReq     = {[eDtwDbgMsg.first():eDtwDbgMsg.last()]};
    }
    `X_with_hdr_ndp_error(DtwDbgMsg_type)
    <% } %>

  // DtwDbgRspMsg_type
    <% if((obj.Block != 'dve') && (obj.Block != 'dmi')) { %>
    DtwDbgRspMsg_type : coverpoint m_smi_seq.smi_msg_type {
      bins DtwDbgRsp     = {[eDtwDbgRsp.first():eDtwDbgRsp.last()]};
    }
    `X_with_hdr_ndp_error(DtwDbgRspMsg_type)
    <% }
     } %>

  // DtwRspMsg_type
	<% if((obj.Block =='io_aiu') || (obj.Block =='aiu') || (obj.Block =='chi_aiu')) { %>
	  DtwRspMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins DtwRspMsg     = {[eDtwRsp.first():eDtwRsp.last()]};
    }
    `X_with_hdr_ndp_error(DtwRspMsg_type)
  <% } %>

  // UpdReqMsg_type
 
	<% if((obj.Block =='dce')) { %>
	  UpdReqMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins UpdReqMsg     = {[eUpdMsg.first():eUpdMsg.last()]};
    }
    `X_with_hdr_ndp_error(UpdReqMsg_type)
  <% } %>

  // UpdRspMsg_type
  //#Cover.IOAIU.SMI.UpdRsp.CMType
	<% if((obj.Block =='io_aiu') || (obj.Block =='aiu') && (obj.fnNativeInterface != "ACELITE-E")) { %>
	  UpdRspMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins UpdRspMsg     = {[eUpdRsp.first():eUpdRsp.last()]};
    }
    `X_with_hdr_ndp_error(UpdRspMsg_type)
  <% } %>

  // RbReqMsg_type
	<% if((obj.Block =='dmi')) { %>
	  RbReqMsg_type     : coverpoint m_smi_seq.smi_msg_type {
      bins RbReqMsg      = {[eRbMsg.first():eRbMsg.last()]};
    }
    `X_with_hdr_ndp_error(RbReqMsg_type)
  <% } %>

  // RbRspMsg_type
	<% if((obj.Block =='dce')) { %>
	  RbRspMsg_type     : coverpoint m_smi_seq.smi_msg_type {
      bins RbRspMsg      = {[eRbRsp.first():eRbRsp.last()]};
    }
    `X_with_hdr_ndp_error(RbRspMsg_type)
  <% } %>

  // CmprspMsg_type
	<% if((obj.Block =='chi_aiu')) { %>
	  CmprspMsg_type    : coverpoint m_smi_seq.smi_msg_type {
      bins CmprspMsg     = {[eCmpRsp.first():eCmpRsp.last()]};
    }
    `X_with_hdr_ndp_error(CmprspMsg_type)
  <% } %>
  <% } %>

  endgroup

  function new(string name = "smi_resiliency_coverage", uvm_component parent = null);
      super.new(name, parent);
      m_smi_seq = new();
      smi_transaction_resiliency = new();
  endfunction : new

  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
  endfunction : build_phase

  virtual function void write_smi(smi_seq_item m_pkt);
      smi_seq_item m_packet;
      m_packet = new();
      $cast(m_packet,m_pkt);
      m_smi_seq.copy(m_packet);
      smi_transaction_resiliency.sample();
  endfunction : write_smi
endclass : smi_resiliency_coverage

<% } %>
