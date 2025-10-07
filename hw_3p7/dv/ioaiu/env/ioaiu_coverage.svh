<% if (obj.nNativeInterfacePorts > 1) { 
    var coreIntvBits  = obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits;
    var dceSelectBits = obj.AiuInfo[obj.Id].InterleaveInfo.dceSelectInfo.PriSubDiagAddrBits;
    var mapping;

    //Following logic implements the AIU Core & DCE interleaving logic for software credit covergroups
    //The logic is translated from the AIU-DCE connectivity optimization Table 23 in Ncore Connectivity Arch Spec Rev0.89 
    if (dceSelectBits.length == 1) {  //2 DCE & 2/4 Cores
      if (dceSelectBits[0] == coreIntvBits[0]) {        //LSB Matching
          mapping = [[0,2],[1,3]];
      } else if (dceSelectBits[0] == coreIntvBits[1]) { //MSB Matching
          mapping = [[0,1],[2,3]];
      } else {                                          //Complete Crossbar
          mapping = [[0,1,2,3],[0,1,2,3]];
      }
    } else if ((dceSelectBits.length == 2) && (coreIntvBits == 1)) { //4 DCE & 2 Cores
      if (dceSelectBits[0] == coreIntvBits[0]) {        //LSB matching
          mapping = [[0],[1],[0],[1]];
      } else if (dceSelectBits[1] == coreIntvBits[0]) { //MSB matching
          mapping = [[0],[0],[1],[1]];
      } else {                                          //Complete Crossbar
          mapping = [[0,1],[0,1],[0,1],[0,1]];
      }
    } else if (dceSelectBits.length == 2) {  //4 DCE & 4 Cores
      if ((dceSelectBits[0] == coreIntvBits[0]) && (dceSelectBits[1] == coreIntvBits[1])) {        //1to1 connectivity
          mapping = [[0],[1],[2],[3]];
      } else if ((dceSelectBits[0] == coreIntvBits[0]) || (dceSelectBits[1] == coreIntvBits[0])) { //LSB matching
          mapping = [[0,2],[1,3],[0,2],[1,3]];
      } else if ((dceSelectBits[0] == coreIntvBits[1]) || (dceSelectBits[1] == coreIntvBits[1])) { //MSB matching
          mapping = [[0,1],[0,1],[2,3],[2,3]];
      } else {                                                                                     //Complete Crossbar
          mapping = [[0,1,2,3],[0,1,2,3],[0,1,2,3],[0,1,2,3]];
      }
    }
        
}%>
typedef struct{
	bit[1:0] sysreq_event_opcode;
	bit event_receiver_enable;
	bit sysreq_event;
	bit [7:0] cm_status;
	bit timeout_err_det_en;
	bit timeout_err_int_en;
	bit [3:0] uesr_err_type;
	bit err_valid;
	bit irq_uc;
	int timeout_threshold;
}sysreq_pkt_t;   // This is temporary - Can be deleted after sysreq events feature delivery

typedef class ioaiu_scoreboard;
class ioaiu_coverage;
    <%
    var cohIds = [];
   
    obj.AiuInfo.forEach(function(bundle, indx) {
	     if((bundle.BlockId != obj.BlockId) &&
	         ((bundle.fnNativeInterface == "ACE") ||
	         (bundle.fnNativeInterface == "CHI") ||
	         (bundle.fnNativeInterface == "CHI-A") ||
	         (bundle.fnNativeInterface == "CHI-B") ||
	         ((bundle.fnNativeInterface == "AXI4" || bundle.fnNativeInterface == "AXI5") && bundle.useCache))) {
	             cohIds.push(indx);
	         }
        });
      var aiu_axiInt;

   if(obj.interfaces.axiInt.length > 1) {
   aiu_axiInt = obj.interfaces.axiInt[0];
   } else {
   aiu_axiInt = obj.interfaces.axiInt;
   }
   
   var DVM_intf = {"ACE":"ace"};
   if (obj.eAc == 1 && obj.fnNativeInterface == "ACELITE-E") DVM_intf["ACELITE-E"]= "ace5_lite";
  %>
    // AXI4 read addr chnl signals
    //bit 		       arid_matched = 0;
    //bit 		       araddr_matched = 0;
	sysreq_pkt_t 		sysreq_pkt;
    int 		            m_dtsize;
    longint             m_aligned_addr;
    bit                 arWeirdWrap = 0;
    bit                 isCoherent;
    axi_axsize_t        arsize;
    axi_axburst_enum_t  arburst;
    axi_axlen_t         arlen;
    axi_axlock_enum_t   arlock; 
    axi_arcache_enum_t  arcache;
    axi_axprot_t        arprot;
    axi_axqos_t         arqos;
    ace_command_types_enum_t awcmdtype;

    ioaiu_scoreboard    scb;
   
    // AXI4 write addr chnl signals
    enum integer {usual=0, partial=1, full=2, multiple=3, weird=4} wrCachelineAccess, rdCachelineAccess;
    //bit 		       awid_matched = 0;
    //bit 		       awaddr_matched = 0;
    bit                 awWeirdWrap = 0;
    axi_axsize_t        awsize;
    axi_axburst_enum_t  awburst;
    axi_axlen_t         awlen;
    axi_axlock_enum_t   awlock;
    axi_awstashnid_t    awstashnid;
    bit                 awstashniden;
    axi_awstashlpid_t   awstashlpid;
    bit                 awstashlpiden;
    axi_awsnoop_t       awsnoop;
    axi_awcache_enum_t  awcache;
    randc axi_axprot_t  awprot;
    randc axi_axqos_t   awqos;
    axi_xstrb_t         wstrb;
    axi_xdata_t         beat_num;
    axi_axlen_t         total_beat;

    // ACE Read Address Channel
    axi_axaddr_t        araddr;
    bit[1:0]            ardomain;
    bit[3:0]            arsnoop;

   //trace signal
    bit		        artrace; 
    bit	   	        awtrace;
    bit			rtrace; 		
    bit	           	wtrace;
    bit 		btrace;   
    bit                 smi_tm;

  // ACE Write Address Channel
    axi_axaddr_t        awaddr;
    bit[1:0]            awdomain;
    bit                 awunique;
    bit[5:0]            awatop;

    // ACE Read Resp Channel
    bit[3:0]            rresp;
    axi_xdata_t         rdata[];
    bit[1:0]            rsp_ardomain;
    bit[3:0]            rsp_arsnoop;

    // ACE Write Resp Channel
    bit[1:0]            bresp;
    bit[1:0]            rsp_awdomain;
    bit[3:0]            rsp_awsnoop;

    // ACE Read ack
    bit                 rack;

    // ACE Write ack
    bit                 wack;

    // ACE Snoop Address Channel
    axi_axaddr_t        acaddr;
    axi_acsnoop_t       acsnoop;
    axi_axprot_t        acprot;

    // ACE Snoop Response Channel
    axi_crresp_t        crresp;
    axi_crresp_t        ace_crresp;
    axi_acsnoop_t       acsnoop_rsp;

    // ACE Snoop Data Channel
    bit                 cdlast;
    int                 snoop_dtr_req_type;
    axi_cddata_t        cddata[];
    axi_cddata_t        cddata_beat;
   
   //Decerr Error type 
   bit                 ismultiline;
   bit                 isDtwResperr;
   bit                 isDtrReqerr;
   bit                 isStrReqerr;
   bit[1:0]            err_resp;
   errtype             Dec_Error_Type;
   errtype             Slv_Error_Type;
   txn_type            Txn_type;

   //DTWrsp cmstatus error
   bit[6:0] drwrsp_cmstatus_err;
   cmdreq_type          cmdtype;
   smi_seq_item         m_dtw_rsp_pkt;

   //DTRrsp cmstatus error
   bit[6:0] dtrreq_cmstatus_err;
   bit[<%=((Math.pow(2,obj.wCacheLineOffset) * 8) / obj.wData)%>:0] dbad; 
   bit isPartial;
   smi_seq_item          m_dtr_req_pkt;
//Snoop DTRReq cmstatus error
   bit[6:0]                 snoop_dtrreq_cmstatus_err;

   //#Cover.IOAIU.DTWreq.CMStatusDataError_CmdType
   bit[6:0] drwreq_cmstatus_err;
   smi_seq_item         m_dtw_req_pkt;
   bit                  dtwreq_dbad;

   //#Cover.IOAIU.STRreq.CMStatusError.Address.Data
   bit[7:0] 		strreq_cmtatus_err;
   txn_type 		strreq_type;
   smi_seq_item		m_str_req_pkt;

   //#Cover.IOAIU.CMPrsp.CMStatusAddrErr.DVMSync_DVMnonSync
   bit[6:0] 		 cmprsp_cmstatus_add_err;
   smi_seq_item          m_cmp_rsp_pkt;
   txn_type              cmprsp_txn_type;

   //#Cover.IOAIU.SNPrsp.CMStatusAddrErr.DVMSync_DVMnonSync
   bit[6:0] 		 snprsp_cmstatus_add_err;
   smi_seq_item          m_snp_rsp_pkt;
   txn_type              snprsp_txn_type;

   //#Cover.IOAIU.IllegaIOpToDII.DECERR
    bit[1:0]            illop_bresp;
    bit[1:0]            illop_awdomain;
    bit[3:0]            illop_awsnoop;
    bit[3:0]            illop_rresp;
    bit[1:0]            illop_ardomain;
    bit[3:0]            illop_arsnoop;
    bit                 ill_op_to_dii;
     
  //Data Correctable Error
   bit[3:0]             cesr_err_type;
   bit[2:0]             cesr_err_info;
   bit                  cesr_errrcountoverflow;
   bit[7:0]             cesr_counter;
  //interface parity
  bit [3:0]            intf_per_err_type;
  bit [4:0]            intf_per_err_info;
  bit                  intf_per_err_vld;
  bit[5:0]              intf_per_sgl;
  //#Cover.IOAIU.UESR.ErrType_ErrInfo
   bit[3:0]            data_tag_ott_uesr_err_type;
   bit[2:0]            data_tag_ott_uesr_err_info;
   bit            snoop_dtrreq_uesr_err_info;

   bit[3:0]            decode_uesr_err_type;
   bit[3:0]	       decode_uesr_err_info;

   bit[3:0]            software_uesr_err_type;
   bit[3:0]	       software_uesr_err_info;
   
   //#Cover.IOAIU.WrongTargetId
   bit[3:0]            wrong_target_id_uesr_err_type;
   bit[2:0]            wrong_target_id_uesr_err_info;

   mission_fault_causes mission_fault_with_err; 
   bit                  mission_fault;
   bit                  thres_fault; 
   bit                  trans_det_en;
   bit                  time_out_deten;
   bit                  proterr_det_en;
   bit                  mem_det_en;

   //#Cover.IOAIU.SMIProtectionType
   bit[3:0]            smi_prot_uesr_err_type;
   bit[2:0]            smi_prot_uesr_err_info;
   bit[3:0]            smi_prot_cesr_err_type;
   bit[2:0]            smi_prot_cesr_err_info;
   smi_prot_cmd_types  smi_prot_cmd_types;

// Sysco time out 
   bit[3:0]             sysco_time_out_uesr_err_type;
   bit[2:0]             sysco_time_out_uesr_err_info;

//normal timeoput 
   bit[3:0]             normal_time_out_uesr_err_type;
   bit[2:0]             normal_time_out_uesr_err_info;

// sys_time_out
   bit[3:0]             sys_event_time_out_uesr_err_type;
   bit[2:0]             sys_event_time_out_uesr_err_info;

 //#Cover.IOAIU.UESR.ErrType_ErrInfo

    ioaiu_scb_txn       m_scb_txn;
    eMsgSNP             snp_type;

    bit                 EventStatus;
    bit [2:0]             starv_cnt;

// coverage CONC-12507

    bit[1:0] crresp_err_dtxfer;
    bit[1:0] cmstatus_dt_aiu_dmi;

//mptop
    int mnt_opcode;

    // CCP
    <%if(obj.useCache) {%>
		bit [3:0] tag_bank;
		bit       read_hit;
		bit       read_miss_allocate;
		bit       write_hit;
		bit       write_miss_allocate;
		bit       snoop_hit;
		bit       write_hit_upgrade;
		int       alloc_ways;
		bit       sd_hit_partial_upgrade;
		bit       snoop_hit_evict;
                bit       b2b_same_addr;
                bit       b2b_same_index;

		ccp_ctrl_pkt_t         m_pkt;
		ccp_cachestate_enum_t  state;
		ccp_cachestate_enum_t  ccp_current_state;
		ccp_cachestate_enum_t  ccp_next_state;
		bit [<%=obj.nWays-1%>:0] way_<%=obj.nWays%>;
		bit [<%=obj.nWays-1%>:0] pending_way_<%=obj.nWays%>;

		ccp_ctrlfill_security_t security;
		ccp_cache_evict_vld_t   evictvld;

		bit                    fill_way_1;
		bit                    fill_way_2;
		bit [1:0]              fill_way_4;
		bit [2:0]              fill_way_8;
		bit [3:0]              fill_way_16;
		ccp_ctrlfill_security_t fill_security;
		ccp_cachestate_enum_t   fill_state;

		bit nacknoalloc;
		// evict channel
		bit  evict_valid;
		ccp_cache_evict_cancel_t evict_cancel;
                //target

                bit        ccp_LookupEn;
                bit        ccp_AllocEn;
                bit        ccp_disableupd;

	<%}%>

        enum integer {DII=0,DMI=1} tgt_type;
    smi_msg_type_bit_t msg_type;
    <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
        enum integer {CmdRdNC=0,CmdWrNCFull=1,CmdWrNCPtl=2,CmdRdNITC=3,CmdRdVld=4,CmdWrUnqPtl=5,CmdRdUnq=6,CmdWrUnqFull=7,CmdMkUnq=8,CmdRdAtm=9,CmdWrAtm=10,CmdSwAtm=11,CmdCompAtm=12,NoMsg=13} Cmd_Req;
        axi_awcache_enum_t  awcache_axi4;
        axi_arcache_enum_t  arcache_axi4;
        <%if(obj.useCache) {%>
            ccp_cachestate_enum_t CCPnextstate;
            ccp_cachestate_enum_t CCPcurrentstate;
        <%}else{%>
            enum integer{nextst_IX = 3'h0} CCPnextstate;
            enum integer{currst_IX = 3'h0} CCPcurrentstate;
        <%}%>
        bit isEvict;
    <%}%>
    bit rdnitc;
    bit rdvld;
    bit rdcln;
    bit rdunq;
    bit clnunq;
    bit clnvld;
    bit clninv;
    bit mkinv;
    bit dvmmsg;
    bit wrunqptl;
    bit wrunqfull;
    bit wrncfull;

    bit dtr_data_inv;
    bit dtr_data_shr_cln;
    bit dtr_data_shr_dty;
    bit dtr_data_unq_cln;
    bit dtr_data_unq_dty;

    bit araddr_collision;
    bit awaddr_collision;
    bit arid_collision;
    bit awid_collision;
    bit axaddr_collision;
    bit axid_collision;
   
    bit cmstatus_err;
    //security feature
    bit nsx;
    bit[1:0] resp;
    //Exclusive
    int tansfer_size_excl_rd;
    int tansfer_size_excl_wr;
    int excl_size_wr,excl_size_rd;
    //conectivity interface
    bit [<%=obj.nDCEs-1%>:0] AiuDce_connectivity_vec;
    bit [<%=obj.nDMIs-1%>:0] AiuDmi_connectivity_vec;
    bit [<%=obj.nDIIs-1%>:0] AiuDii_connectivity_vec;
    

    smi_seq_item          str_req_msg;
    bit stash_target_identified;

    //CCMP SnpReq
    <% if(obj.nSttCtrlEntries > 0) { %>
        smi_seq_item        snp_req_msg;
        smi_seq_item        snp_rsp_msg;
        smi_seq_item        snp_req_msg_q[$];
    <%}%>

    <%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.useCache)) { %>
        bit                   rv;
        bit                   rs;
        bit                   dc;
        bit       [1:0]       dt;
        bit       [1:0]       up;
        bit                   match;

        smi_msg_type_bit_t    smi_snp_type;
        eMsgSNP               smi_snp_msg;
        //smi_seq_item          smi_snp_item;
        //static smi_seq_item   smi_snp_req_q[$];

        smi_msg_type_bit_t    smi_dtr_type;
        smi_msg_type_bit_t    smi_dtw_type;
    <%}%>
    // Events Coverage related variables
    
    <% for(var i = 0; i < obj.nDCEs; i++) { %>
    bit [5:0] DCE_CCR<%=i%>_Val;
    bit [2:0] DCE_CCR<%=i%>_state;
    <% } %>

    <% for(var i = 0; i < obj.nDMIs; i++) { %>
    bit [5:0] DMI_CCR<%=i%>_Val;
    bit [2:0] DMI_CCR<%=i%>_state;
    <% } %>

    <% for(var i = 0; i < obj.nDIIs; i++) {
      if(obj.DiiInfo[i].strRtlNamePrefix != "sys_dii") { %>
    bit [5:0] DII_CCR<%=i%>_Val;
    bit [2:0] DII_CCR<%=i%>_state;
    <%}
    } %>
    
    <%if(obj.nNativeInterfacePorts == 1){%>
        bit rd_resp_interleaved;

        function void rd_interleaved();
            rd_resp_interleaved = 1;
        endfunction : rd_interleaved
    <%}%>
   function void collect_parity_err(int err_type,int err_info,int err_valid,int fault,int per_sgnl);
   intf_per_err_type = err_type;
   intf_per_err_info = err_info;
   intf_per_err_vld = err_valid;
   mission_fault = fault;
   intf_per_sgl = per_sgnl;
   parity_error_covergroup.sample();
    endfunction
   covergroup parity_error_covergroup;

         cp_error_vld: coverpoint intf_per_err_vld; 


         cp_error_type: coverpoint  intf_per_err_type iff(intf_per_err_vld){

                bins err_type = {4'hD};
               
                }
        cp_error_info: coverpoint  intf_per_err_info iff(intf_per_err_vld){

                bins err_info_aw = {5'b00001}; 
                bins err_info_ar = {5'b00000}; 
		bins err_info_w =  {5'b00010};
                bins err_info_b =  {5'b00100};
                bins err_info_r = {5'b00011};
                <%if (obj.fnNativeInterface != "AXI5") {%>
                bins err_info_ac = {5'b00111};
                bins err_info_cr = {5'b00101};
                <%}%>
                <%if (obj.fnNativeInterface == "ACE5") {%>
                bins err_info_cd = {5'b00110};
                bins err_info_rack = {5'b01000};
                bins err_info_wack = {5'b01001};
                <%}%>
               }
      <% if(obj.useResiliency) { %> 
       cp_mission_fault : coverpoint mission_fault {
                         bins mission_fault = {1};
          }
       <%}%>
       cp_intf_per_sgnl:coverpoint intf_per_sgl {
                                       
				       bins awvalid_chk = {0}; 
                                       bins awid_chk = {1};
                                       bins awaddr_chk={2};
				       bins awlen_chk={3};
				       bins awctl_chk0={4};
				       bins awctl_chk1={5};
                                       <%if (obj.fnNativeInterface != "AXI5") {%>
				       bins awctl_chk2={6};
                                       <%}%>
                                       <%if (obj.fnNativeInterface != "ACE5") {%>
				       bins awctl_chk3={7};
                                       <%}%>
                                       bins awuser_chk={8};                                       
                                       <%if ((obj.fnNativeInterface == "ACELITE-E")){%>
                                       bins awstashnid_chk={10};
                                       bins awstashlpid_chk={11};
                                       <%}%>
                                       
                                       <%if ((obj.fnNativeInterface == "ACELITE-E")){%>    //eTrace will be enabled only for ACE5-Lite and ACE5-LiteDVM interfaces and not any other.(spec v 1.0.6-table:7-69) CONC-17255
                                       bins crtrace_chk={29};
				       bins wtrace_chk={27};
				       bins artrace_chk={21};
                                       bins awtrace_chk={9};
                                       <%}%>
				       bins arvalid_chk={12};
				       bins arid_chk={13};
				       bins araddr_chk={14};
				       bins arlen_chk={15};
				       bins arctl_chk0={16};
				       bins arctl_chk1={17};
                                       <%if (obj.fnNativeInterface != "AXI5") {%>
				       bins arctl_chk2={18};
                                       <%}%>
				       bins arctl_chk3={19};
                                       bins aruser_chk={20};
                                      
				       bins wvalid_chk={22};
				       bins wdata_chk={23};
				       bins wstrb_chk={24};
				       bins wlast_chk={25};
                                       bins wuser_chk={26};

                                       <%if (obj.fnNativeInterface != "AXI5") {%>
                                       bins crresp_chk={28};
                                       bins crvalid_chk={35};
                                       bins acready_chk = {32};
                                       <%}%>

                                       bins bready_chk = {30};
                                       bins rready_chk = {31};

                                       <%if (obj.fnNativeInterface == "ACE5") {%>
                                       bins cdlast_chk={38};
                                       bins cddata_chk={37};
                                       bins cdvalid_chk={36};

                                       bins rack_chk={33};
                                       bins wack_chk={34};
                                       <%}%>
                                       

} 
  
  cross_parity_err_vld: cross cp_error_type,cp_error_info,cp_intf_per_sgnl<% if(obj.useResiliency) {%>
                                     ,cp_mission_fault
                                     <%}%> iff(intf_per_err_vld) {

                                      ignore_bins aw_typ_X_err_info = binsof(cp_intf_per_sgnl) intersect {[0:5],8,9<%if (obj.fnNativeInterface != "AXI5") {%>,6<%}%><%if (obj.fnNativeInterface != "ACE5") {%>,7<%}%><%if ((obj.fnNativeInterface == "ACELITE-E")){%>,10,11<%}%>} && binsof(cp_error_info) intersect {5'b00000,5'b00010,5'b00100,5'b00011<%if (obj.fnNativeInterface != "AXI5") {%>,5'b00111,5'b00101<%}%><%if (obj.fnNativeInterface == "ACE5") {%>,5'b00110,5'b01000,5'b01001<%}%>};
				      ignore_bins ar_typ_X_err_info = binsof(cp_intf_per_sgnl) intersect {[12:17],[19:21]<%if (obj.fnNativeInterface != "AXI5") {%>,18<%}%>} && binsof(cp_error_info) intersect {5'b00001,5'b00010,5'b00100,5'b00011<%if (obj.fnNativeInterface != "AXI5") {%>,5'b00111,5'b00101<%}%><%if (obj.fnNativeInterface == "ACE5") {%>,5'b00110,5'b01000,5'b01001<%}%>};
                                      
				      ignore_bins w_typ_X_err_info = binsof(cp_intf_per_sgnl) intersect {[22:27]} && binsof(cp_error_info) intersect {5'b00001,5'b00000,5'b00100,5'b00011<%if (obj.fnNativeInterface != "AXI5") {%>,5'b00111,5'b00101<%}%><%if (obj.fnNativeInterface == "ACE5") {%>,5'b00110,5'b01000,5'b01001<%}%>};

                                       <%if (obj.fnNativeInterface != "AXI5") {%>
                                      ignore_bins cr_typ_X_err_info = binsof(cp_intf_per_sgnl) intersect {28,29,35} && binsof(cp_error_info) intersect {5'b00001,5'b00000,5'b00010,5'b00100,5'b00011,5'b00111<%if (obj.fnNativeInterface == "ACE5") {%>,5'b00110,5'b01000,5'b01001<%}%>};
                                      ignore_bins ac_typ_X_err_info = binsof(cp_intf_per_sgnl) intersect {32} && binsof(cp_error_info) intersect {5'b00001,5'b00000,5'b00010,5'b00101,5'b00100,5'b00011<%if (obj.fnNativeInterface == "ACE5") {%>,5'b00110,5'b01000,5'b01001<%}%>};
                                      <%}%>
                                      
                                      ignore_bins b_typ_X_err_info = binsof(cp_intf_per_sgnl) intersect {30} && binsof(cp_error_info) intersect {5'b00001,5'b00000,5'b00010,5'b00011<%if (obj.fnNativeInterface != "AXI5") {%>,5'b00111,5'b00101<%}%><%if (obj.fnNativeInterface == "ACE5") {%>,5'b00110,5'b01000,5'b01001<%}%>};
                                      ignore_bins r_typ_X_err_info = binsof(cp_intf_per_sgnl) intersect {31} && binsof(cp_error_info) intersect {5'b00001,5'b00000,5'b00010,5'b00100<%if (obj.fnNativeInterface != "AXI5") {%>,5'b00111,5'b00101<%}%><%if (obj.fnNativeInterface == "ACE5") {%>,5'b00110,5'b01000,5'b01001<%}%>};
                                      <%if (obj.fnNativeInterface == "ACE5") {%>

                                      ignore_bins cd_typ_X_err_info = binsof(cp_intf_per_sgnl) intersect {36,37,38} && binsof(cp_error_info) intersect {5'b00001,5'b00000,5'b00010,5'b00101,5'b00100,5'b00011,5'b00111,5'b01000,5'b01001};
                                      ignore_bins rack_typ_X_err_info = binsof(cp_intf_per_sgnl) intersect {33} && binsof(cp_error_info) intersect {5'b00001,5'b00000,5'b00010,5'b00101,5'b00100,5'b00011,5'b00111,5'b00110,5'b01001};
                                      ignore_bins wack_typ_X_err_info = binsof(cp_intf_per_sgnl) intersect {34} && binsof(cp_error_info) intersect {5'b00001,5'b00000,5'b00010,5'b00101,5'b00100,5'b00011,5'b00111,5'b00110,5'b01000};
                                       <%}%>
  } 
      <% if(obj.useResiliency) {%>
      cross_parity_no_err_vld: cross cp_intf_per_sgnl,cp_mission_fault;
      //#Cover.IOAIU.ErrVld.mission_fault
      cross_parity_errvld_fault: cross cp_error_vld,cp_mission_fault;
      <%}%>
   endgroup
  //#Cover.IOAIU.DecErrr.Type
  <%for(let port=0; port< obj.nNativeInterfacePorts; port+=1) {%>
  covergroup dec_error_covergroup_core<%=port%>;

  dec_error_type: coverpoint Dec_Error_Type {

  bins errtype_addrNotInMemRegion = {addrNotInMemRegion};
  bins errtype_addrHitInMultipleRegion = {addrHitInMultipleRegion};
  bins errtype_illegalCoherentDIIAccess = {illDIIAccess};
  bins errtype_illegalNSAccess = {illegalNSAccess};
  bins dtwrsp_cmstatus_addr_err = {dtwrsp_cmstatus_addr_err};
  bins strreq_cmstatus_addr_err = {strreq_cmstatus_addr_err};
  bins dtrreq_cmstatus_addr_err = {dtrreq_cmstatus_addr_err};
  bins normal_scenario          = {no_error};

   } 

  txn_type: coverpoint Txn_type {
  bins coh_write = {coh_write};
  bins noncoh_write = {noncoh_write};
  bins coh_read    = {coh_read};
  bins noncoh_read = {noncoh_read};
   
  <%if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
  bins isUpdate = {isUpdate};
  <% } %>

  <%if ((obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5")) {%>
  bins coh_atomic  = {coh_atomic};
  bins noncoh_atomic = {noncoh_atomic};
  <% } %>
  }

  error_resp : coverpoint err_resp{
   bins decerr = {3};
  }
  atm_aw_cmdtype: coverpoint awcmdtype{
   bins atm_load = {ATMLD};
   bins atm_cmp  = {ATMCOMPARE};
   bins atm_swap = {ATMSWAP};
   bins atm_str  = {ATMSTR};
  } 
  dtwrsp_cmstatus_error_type: coverpoint isDtwResperr {

  bins dtwrsp_cmstatus_addr_no_err = {0};
  bins dtwrsp_cmstatus_addr_err = {1};

   } 
  strreq_cmstatus_error_type: coverpoint isStrReqerr {

  bins strreq_cmstatus_addr_no_err = {0};
  bins strreq_cmstatus_addr_err = {1};

   }
  dtrreq_cmstatus_error_type: coverpoint isDtrReqerr {

  bins dtrreq_cmstatus_addr_no_err = {0};
  bins dtrreq_cmstatus_addr_err = {1};

   }


 is_multiline: coverpoint ismultiline{
  bins ismultiline_0 = {0};
  bins ismultiline_1 = {1};
  }

 atm_type_dtwrsp_x_dtrreq_decerr_rsp: cross atm_aw_cmdtype,error_resp,dtwrsp_cmstatus_error_type,dtrreq_cmstatus_error_type{
ignore_bins atm_str_x_dtrreq = binsof(atm_aw_cmdtype) intersect {ATMSTR} &&
                                 binsof (dtrreq_cmstatus_error_type) intersect {1};
 }
 atm_type_strreq_decerr_rsp: cross atm_aw_cmdtype,error_resp,strreq_cmstatus_error_type;

 dec_error_covergroup_core: cross dec_error_type,is_multiline,error_resp,txn_type  {
           ignore_bins ignored_normal_txn = binsof(dec_error_type.normal_scenario);
	  <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5") { %>
           ignore_bins ignored_multiline_atomic_txn =  binsof(txn_type) intersect {noncoh_atomic,coh_atomic} && binsof(is_multiline) intersect {1} ;
	   <% } %>
	  <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
           ignore_bins ignored_multiline_dvm_txn =  binsof(txn_type) intersect {dvm} && binsof(is_multiline) intersect {1} ;
           ignore_bins ignored_multiline_is_update_txn =  binsof(txn_type) intersect {isUpdate} && binsof(is_multiline) intersect {1} ;
           ignore_bins ignored_dvm_addr_err=  binsof(dec_error_type) intersect {illegalNSAccess,addrNotInMemRegion,addrHitInMultipleRegion} &&  binsof(txn_type) intersect {dvm} ;
          ignore_bins ignored_isupdate_NSAccess =  binsof(dec_error_type) intersect {illegalNSAccess} &&  binsof(txn_type) intersect {isUpdate} ;
	   <% } %>
           illegal_bins strreq_noncoh_txn=  binsof(dec_error_type) intersect {strreq_cmstatus_addr_err} &&  binsof(txn_type) intersect {noncoh_read,noncoh_write<%if ((obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5")) {%>,noncoh_atomic<%}%><%if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) {%>,isUpdate,dvm<%}%>} ;
           illegal_bins illegalcoherentDIIAccess_noncoh_txn=  binsof(dec_error_type) intersect {illDIIAccess} &&  binsof(txn_type) intersect {noncoh_read,noncoh_write} ;
	  <%if((obj.fnNativeInterface == "ACELITE-E") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") ) { %>
           ignore_bins read_multiline_txn= binsof(is_multiline) intersect {1} &&  binsof(txn_type) intersect {coh_read,coh_write};
	   <% } %>
           illegal_bins dtwrsp_read_txn=  binsof(dec_error_type) intersect {dtwrsp_cmstatus_addr_err} &&  binsof(txn_type) intersect {coh_read,noncoh_read} ;
	   <%if(!obj.useCache) { %> 
           illegal_bins dtrreq_write_txn=  binsof(dec_error_type) intersect {dtrreq_cmstatus_addr_err} &&  binsof(txn_type) intersect {coh_write,noncoh_write<%if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) {%>,isUpdate,dvm<%}%>} ;
	   <%} else { %>
            illegal_bins dtrreq_write_txn=  binsof(dec_error_type) intersect {dtrreq_cmstatus_addr_err} &&  binsof(txn_type) intersect {noncoh_write} ;
	   <% } %>
	
              } 

 endgroup 

  //#Cover.IOAIU.SLVERR.Type

  covergroup slv_error_covergroup_core<%=port%>;

  slv_error_type: coverpoint Slv_Error_Type {

 <%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") && obj.assertOn) {%>
  bins errtype_data_uncorrectable_error= {dataUncorrectableError};
 <% } else { %>
  ignore_bins errtype_data_uncorrectable_error= {dataUncorrectableError};
 <% } %>
  bins dtwrsp_cmstatus_data_err = {dtwrsp_cmstatus_data_err};
  bins strreq_cmstatus_data_err = {strreq_cmstatus_data_err};
  bins dtrreq_cmstatus_data_err = {dtrreq_cmstatus_data_err};
  bins normal_scenario          = {no_error};

   } 

  txn_type: coverpoint Txn_type {
  bins coh_write = {coh_write};
  bins noncoh_write = {noncoh_write};
  bins coh_read    = {coh_read};
  bins noncoh_read = {noncoh_read};
  <%if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") ) {%>
  bins dvm_txn     = {dvm};
  <% } %>
  
  <%if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
  bins isUpdate = {isUpdate};
  <% } %>

  <%if ((obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5")) {%>
  bins coh_atomic  = {coh_atomic};
  bins noncoh_atomic = {noncoh_atomic};
  <% } %>
  }
  atm_aw_cmdtype: coverpoint awcmdtype{
   bins atm_load = {ATMLD};
   bins atm_cmp  = {ATMCOMPARE};
   bins atm_swap = {ATMSWAP};
   bins atm_str  = {ATMSTR};
  }
  dtwrsp_cmstatus_error_type: coverpoint isDtwResperr {

  bins dtwrsp_cmstatus_data_no_err = {0};
  bins dtwrsp_cmstatus_data_err = {1};

   } 
  strreq_cmstatus_error_type: coverpoint isStrReqerr {

  bins strreq_cmstatus_data_no_err = {0};
  bins strreq_cmstatus_data_err = {1};

   }
  dtrreq_cmstatus_error_type: coverpoint isDtrReqerr {

  bins dtrreq_cmstatus_data_no_err = {0};
  bins dtrreq_cmstatus_data_err = {1};

   }

  error_resp : coverpoint err_resp{
   bins slverr = {2};
  }

  is_multiline: coverpoint ismultiline{
  bins ismultiline_0 = {0};
  bins ismultiline_1 = {1};
  }
 atm_type_dtwrsp_x_dtrreq_slverr_rsp: cross atm_aw_cmdtype,error_resp,dtwrsp_cmstatus_error_type,dtrreq_cmstatus_error_type{
  ignore_bins atm_str_x_dtrreq = binsof(atm_aw_cmdtype) intersect {ATMSTR} &&
                                 binsof (dtrreq_cmstatus_error_type) intersect {1};
 }  
 
 atm_type_strreq_slverr_rsp: cross atm_aw_cmdtype,error_resp,strreq_cmstatus_error_type;

 slv_error_covergroup_core: cross slv_error_type,is_multiline,error_resp,txn_type  {
           ignore_bins ignored_normal_txn = binsof(slv_error_type.normal_scenario);
	  <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5") { %>
           ignore_bins ignored_multiline_atomic_txn =  binsof(txn_type) intersect {noncoh_atomic,coh_atomic} && binsof(is_multiline) intersect {1} ;
           ignore_bins ignored_atomic_txn=  binsof(slv_error_type) intersect {dataUncorrectableError} &&  binsof(txn_type) intersect {noncoh_atomic,coh_atomic} ;
	   <% } %>
	  <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
           ignore_bins ignored_multiline_dvm_txn =  binsof(txn_type) intersect {dvm} && binsof(is_multiline) intersect {1} ;
           ignore_bins ignored_multiline_is_update_txn =  binsof(txn_type) intersect {isUpdate} && binsof(is_multiline) intersect {1} ;
           ignore_bins ignored_dvm_iupdate_txn=  binsof(slv_error_type) intersect {dataUncorrectableError} &&  binsof(txn_type) intersect {dvm,isUpdate} ;
	   <% } %>
           ignore_bins ignored_write_txn=  binsof(slv_error_type) intersect {dataUncorrectableError} &&  binsof(txn_type) intersect {coh_write,noncoh_write} ;
           illegal_bins strreq_noncoh_txn=  binsof(slv_error_type) intersect {strreq_cmstatus_data_err} &&  binsof(txn_type) intersect {noncoh_read,noncoh_write<%if ((obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5")) {%>,noncoh_atomic<%}%><%if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) {%>,isUpdate,dvm<%}%>} ;
   <%if (((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) {%> 
	   <% } %>
	  <%if((obj.fnNativeInterface == "ACELITE-E") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") ) { %>
           ignore_bins read_multiline_txn= binsof(is_multiline) intersect {1} &&  binsof(txn_type) intersect {coh_read,coh_write};
	   <% } %>
           illegal_bins dtwrsp_read_txn=  binsof(slv_error_type) intersect {dtwrsp_cmstatus_data_err} &&  binsof(txn_type) intersect {coh_read,noncoh_read} ;
	   <%if(!obj.useCache) { %> 
           illegal_bins dtrreq_write_txn=  binsof(slv_error_type) intersect {dtrreq_cmstatus_data_err} &&  binsof(txn_type) intersect {coh_write,noncoh_write<%if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) {%>,isUpdate,dvm<%}%>} ;
	   <%} else { %>
            illegal_bins dtrreq_write_txn=  binsof(slv_error_type) intersect {dtrreq_cmstatus_data_err} &&  binsof(txn_type) intersect {noncoh_write} ;
	   <% } %>

              } 

 endgroup 

 
 //#Cover.IOAIU.DTWrsp.CMStatusError
 covergroup dtwrsp_cmstatus_err_covergroup_core<%=port%>;

   drwrsp_cmstatus_error: coverpoint drwrsp_cmstatus_err {
   bins dtw_rsp_with_add_err ={7'b000_0100};
   bins dtw_rsp_with_data_err ={7'b000_0011};
   }

  is_multiline_txn: coverpoint ismultiline{
  bins ismultiline_0 = {0};
  bins ismultiline_1 = {1};
  }
  
  is_cmd_type: coverpoint cmdtype{
  bins is_write          = {is_write};
  <%if(obj.useCache) { %> 
  bins is_IoCacheEvict   = {is_IoCacheEvict};
  <% } %>
  }

dtwrsp_cmstatus_err_covergroup_core: cross drwrsp_cmstatus_error, is_multiline_txn,is_cmd_type;

endgroup

//#Cover.IOAIU.DTRreq.CMStatusError.DBad

covergroup dtreq_cmstatus_err_covergroup_core<%=port%>;
  
 dtrreq_cmstatus_error: coverpoint dtrreq_cmstatus_err {
   bins dtr_req_with_add_err ={7'b000_0100};
   bins dtr_req_with_data_err ={7'b000_0011};
   }
 
 is_multiline_txn: coverpoint ismultiline{
  bins ismultiline_0 = {0};
  bins ismultiline_1 = {1};
  }

 is_dtreq_cmd_type: coverpoint cmdtype{
 bins is_read = {is_read};
 <%if(obj.useCache) {%>
 bins is_write = {is_write};
 <% } %>

 }

 is_dp_dbad: coverpoint dbad{

 <%if(((Math.pow(2,obj.wCacheLineOffset) * 8) / obj.wData) == 2 || ((Math.pow(2,obj.wCacheLineOffset) * 8) / obj.wData) == 4) {%>
  <%for(let i = 0; i< Math.pow(2,(Math.pow(2,obj.wCacheLineOffset) * 8) / obj.wData); i++) {%>
  bins dbad_<%=i%> = {<%=i%>};
 <% } %>
 <% } else if(((Math.pow(2,obj.wCacheLineOffset) * 8) / obj.wData) == 8) { %> 
  bins dbad_all_zero          = {8'b00000000};
  bins dbad_all_one           = {8'b11111111};
  wildcard bins dbad_0        = {8'b???????1};
  wildcard bins dbad_1        = {8'b??????1?};
  wildcard bins dbad_2        = {8'b?????1??};
  wildcard bins dbad_3        = {8'b????1???};
  wildcard bins dbad_4        = {8'b???1????};
  wildcard bins dbad_5        = {8'b??1?????};
  wildcard bins dbad_6        = {8'b?1??????};
  wildcard bins dbad_7        = {8'b1???????};

 <% } %>
}

 is_partial: coverpoint isPartial{
 bins is_partial_0 ={0};
 bins is_partial_1 ={1};
 }

dtrreq_cmstatus_err_covergroup_core: cross is_partial, is_dp_dbad, is_dtreq_cmd_type, is_multiline_txn, dtrreq_cmstatus_error{
           illegal_bins fullcache_write_txn=   binsof(is_partial) intersect {0} &&  binsof(is_dtreq_cmd_type) intersect {is_write};
} 


endgroup

<%if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.useCache) {%>
//#Cover.IOAIU.OutgoingDTRreq.CMStatusErr
covergroup snoop_dtrreq_cmstatus_err_covergroup_core<%=port%>;
  
 snopp_dtrreq_cmstatus_error: coverpoint snoop_dtrreq_cmstatus_err {
   bins snoop_dtr_req_with_data_err ={7'b000_0011};
   }
 
endgroup
 <% } %>

//#Cover.IOAIU.DTWreq.CMStatusDataError_CmdType
//#Cover.IOAIU.DTWreq.DBad_CmdType
             <%if(((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")|| (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.useCache) {%>
covergroup dtwreq_cmstatus_err_covergroup_core<%=port%>;

   drwreq_cmstatus_error: coverpoint drwreq_cmstatus_err {
   bins dtw_req_with_data_err ={7'b000_0011};
   }
  
  is_cmd_type: coverpoint cmdtype{
<%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") && obj.assertOn && !obj.useCache) {%>
  bins is_write          = {is_write};
  <% } %>
  <%if(obj.useCache) { %> 
  bins is_IoCacheEvict   = {is_IoCacheEvict};
  <% } %>
 <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.useCache) { %>
  bins is_snoop          = {is_snoop};
  <% } %>
  }

  dbad: coverpoint dtwreq_dbad{
  bins dtwreq_dbad_1         = {1};
  }

dtwreq_cmstatus_err_covergroup_core: cross drwreq_cmstatus_error,is_cmd_type;
dtwreq_dbad_cross : cross dbad,is_cmd_type;

endgroup
  <% } %>

//#Cover.IOAIU.STRreq.CMStatusError.Address.Data
covergroup strreq_cmstatus_err_covergroup_core<%=port%>;

strreq_err_type: coverpoint strreq_cmtatus_err {

bins strreq_with_addr = {7'b000_0100};
bins strreq_with_data = {7'b000_0011};

}

is_multiline_wr_rd: coverpoint ismultiline {
  bins ismultiline_0 = {'h0};
 <%if(!(obj.fnNativeInterface === "ACELITE-E" || obj.fnNativeInterface === "ACE-LITE" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) { %>
  bins ismultiline_1 = {'h1};
<% } %>
 }

strreq_txn_type: coverpoint strreq_type{

 bins coh_write = {coh_write};
 
 bins coh_read    = {coh_read};

 <%if ((obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5")) {%>
 bins coh_atomic  = {coh_atomic};
 
 <% } else { %>
 illegal_bins coh_atomic  = {coh_atomic};
 
 <% } %>
 }

strreq_cmstatus_err_cross: cross strreq_err_type,is_multiline_wr_rd,strreq_txn_type{
	  <%if((obj.fnNativeInterface == "ACELITE-E") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") ) { %>
           illegal_bins read_multiline_txn=   binsof(is_multiline_wr_rd) intersect {1} &&  binsof(strreq_txn_type) intersect {coh_read};
	   <% } %>
	  <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5") { %>
           ignore_bins ignored_multiline_atomic_txn =  binsof(strreq_txn_type) intersect {coh_atomic} && binsof(is_multiline_wr_rd) intersect {1} ;
	   <% } %>
}

endgroup

<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
 //#Cover.IOAIU.CMPrsp.CMStatusAddrErr.DVMSync_DVMnonSync
 covergroup cmprsp_cmstatus_err_covergroup_core<%=port%>;

   cmprsp_cmstatus_error: coverpoint cmprsp_cmstatus_add_err {
   bins cmp_rsp_with_add_err ={7'b000_0100};
   }

  is_multiline_txn: coverpoint ismultiline{
  bins ismultiline_0 = {0};
  }
  
  is_txn_type: coverpoint cmprsp_txn_type {
  bins dvm_sync = {Dvmsync};
  bins dvm_nonsync = {Dvmsync_nonsync};
   }

cmprsp_cmstatus_err_covergroup_core: cross cmprsp_cmstatus_error,is_multiline_txn,is_txn_type;

endgroup
<% } %>

 <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
 //#Cover.IOAIU.SNPrsp.CMStatusAddrErr.DVMSync_DVMnonSync
 covergroup snprsp_cmstatus_err_covergroup_core<%=port%>;

   snprsp_cmstatus_error: coverpoint snprsp_cmstatus_add_err {
   bins snp_rsp_with_add_err ={7'b000_0100};
   }
  
  is_txn_type: coverpoint snprsp_txn_type {
  bins dvm_nonsync = {Dvmsync_nonsync};
   }

 snprsp_cmstatus_err_covergroup_core: cross snprsp_cmstatus_error,is_txn_type;

 endgroup
 <% } %>


 //#Cover.IOAIU.UESR.ErrType_ErrInfo
 covergroup uncorrectable_error_covergroup_core<%=port%>;

 data_tag_ott_uesr_error_type: coverpoint data_tag_ott_uesr_err_type{
 <%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") && obj.assertOn) {%>
 bins ott_uesr_err_type_0000    = {0};
 <% } else { %>
 illegal_bins ott_uesr_err_type_0000    = {0};
 <% } %>

 <%if(((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) && obj.assertOn) {%>
 bins data_tag_user_err_type_0001  = {1};
 <%} else {%>
 illegal_bins data_tag_user_err_type_0001  = {1};
 <% } %>
 <%if(!(((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")|| (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) && obj.assertOn)) {%>
 bins no_data_tag_user_err_type_0111  = {15};
 <% } %>
 }

 data_tag_ott_user_error_info: coverpoint data_tag_ott_uesr_err_info{
 <%if(((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") || (obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY")) && obj.assertOn) {%>
 bins ott_tag_error_info_000  = {0};
<% } else {%>
  illegal_bins ott_tag_error_info_000  = {0};
<% } %>
<%if((obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY") && obj.assertOn) {%>
 bins data_error_info_001      = {1};
<%} else {%>
 illegal_bins data_error_info_001      = {1};
<% } %>
 <%if(!(((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")|| (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) && obj.assertOn)) {%>
 bins no_data_tag_ott_err = {7};
 <% } %>
 }
        <%if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" ) {%>
 snoop_dtrreq_user_error_info: coverpoint snoop_dtrreq_uesr_err_info{
 bins non_secure_transfer = {0} ;
 bins secure_transfer = {1} ;
 }
 <% } %>
//#Cover.IOAIU.IllegalCSRaccess.DECERR
//#Cover.IOAIU.IllegalSecurityAccess.DECERR
//#Cover.IOAIU.MultipleAddrhit.DECERR
//#Cover.IOAIU.NoAddresshit.DECERR
 decode_user_error_info: coverpoint decode_uesr_err_info{
  	    bins no_addr_hit               = {'h0};
            bins multiple_addr_hit         = {'h1};
<%if(obj.AiuInfo[obj.Id].fnCsrAccess  == 1) {%>
            bins illegal_csr               = {'h2};
 <% } %>
            bins illegal_dii               = {'h3};
            bins illegal_security_access   = {'h4};
 }

 decode_user_error_type: coverpoint decode_uesr_err_type{
 	   bins decode_error_type = {'h7};
 }

 software_user_error_info: coverpoint software_uesr_err_info{
            bins unconn_dmi                = {'h2};
            bins unconn_dii                = {'h3};
            bins unconn_dce                = {'h5};
            bins no_crds_confg             = {'h1};
 }
//#Cover.IOAIU.Software.Errortype.Errorinfo
 software_user_error_type: coverpoint software_uesr_err_type{
 	   bins decode_error_type = {'hc};
 }

//#Cover.IOAIU.WrongTargetId
 wrong_target_id_error_type: coverpoint wrong_target_id_uesr_err_type{
	  bins wrong_target_id_err_type = {'h8};
 }

 wrong_target_id_error_info: coverpoint wrong_target_id_uesr_err_info{
	  bins wrong_target_id_err_info = {0};
 }

//#Cover.IOAIU.SMIProtectionType
//#Cover.IOAIU.UnCorrectableTransportErr
//#Cover.IOAIU.CorrectableTransportErr
<% if(obj.useResiliency) { %>
 port_corr_err_thres_fault: coverpoint thres_fault {
          bins port_corr_err_thres_fault = {1}; 
 }
 <%}%>
<% if(obj.useResiliency) { %>

 port_uncorr_err_mission_fault: coverpoint mission_fault {
          bins port_uncorr_err_mission_fault = {1}; 
 } 
 <%}%>
 smi_prot_uncorr_error_type: coverpoint smi_prot_uesr_err_type{
	  bins smi_prot_uesr_err_type = {'h8};
 }
 smi_prot_uncorr_error_info: coverpoint smi_prot_uesr_err_info{
	  bins smi_prot_uesr_err_info = {1};
 }
 smi_prot_corr_error_type: coverpoint smi_prot_cesr_err_type{
	  bins smi_prot_cesr_err_type = {'h8};
 }
 smi_prot_corr_error_info: coverpoint smi_prot_cesr_err_info{
	  bins smi_prot_cesr_err_info = {0};
 }

// Sysco timeout coverpoint
 <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) && obj.useCache)) { %>
 
 sysco_time_out_error_type: coverpoint sysco_time_out_uesr_err_type{
	  <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) && obj.useCache)) { %>
          bins sysco_time_out_err_type           = {'hB};
          <%}%> 

          <%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) && obj.useCache)) { %>
          bins sysco_event_time_out_err_type     = {'hA};
          <%}%>
 }
 <%}%> 

sysco_time_out_error_info: coverpoint sysco_time_out_uesr_err_info{

          <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) && obj.useCache)) { %>
	  bins protocol_timeout  = {0};
	   <%} else {%>
	  bins no_time_out_uesr_err_info  = {7};
	  ignore_bins protocol_timeout  = {0};
	   <% } %>
 }

// Sys_event timeout coverpoint 
  <%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) && obj.useCache)) { %> 
 sys_event_time_out_error_type: coverpoint sys_event_time_out_uesr_err_type{ 
          
          bins sys_event_time_out_uesr_err_type     = {'hA};
          
           }
<%}%>

<%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) && obj.useCache)) { %>
sys_event_time_out_error_info: coverpoint sys_event_time_out_uesr_err_info{
           
           bins sys_event_time_out_uesr_err_info     = {'h1}; 
           
           }
<%}%>


// normal timeout coverpoint
 normal_time_out_error_type: coverpoint normal_time_out_uesr_err_type{
          bins erro_type                = {'h9};
 } 

 normal_time_out_error_info_cmd_type: coverpoint normal_time_out_uesr_err_info[1:0]{
          bins cmd_type_read            = {'h0};
          bins cmd_type_write           = {'h1};
          bins cmd_type_cmo_dataless    = {'h2};
          <%if(obj.eAc && ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")  || (obj.fnNativeInterface == "ACELITE-E"))) { %>
          bins cmd_type_dvm             = {'h3};
          <% } else { %>
          ignore_bins cmd_type_dvm       = {'h3};
          <%}%>

          }
 normal_time_out_error_security_attr: coverpoint normal_time_out_uesr_err_info[2]{
          bins security_attribute_0      = {'h0};
          bins security_attribute_1     =  {'h1};

          }

 
uncorrectabel_data_error : cross data_tag_ott_uesr_error_type,data_tag_ott_user_error_info{
<%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") || (obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY")) {%>
illegal_bins  ill_ott_error_info_001 = binsof(data_tag_ott_user_error_info) intersect {1} &&  binsof(data_tag_ott_uesr_error_type) intersect {0} ;
<% } %>
}
decode_error : cross decode_user_error_type, decode_user_error_info;
software_error: cross software_user_error_info,software_user_error_type;
//#Cover.IOAIU.WrongTargetId
wrong_target_id_err : cross wrong_target_id_error_type, wrong_target_id_error_info;
//#Cover.IOAIU.SMIProtectionType
<%if((obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") || (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity")) {%>
smi_prot_uncorr_err_cross : cross smi_prot_uncorr_error_type, smi_prot_uncorr_error_info, smi_prot_cmd_types<% if(obj.useResiliency) { %>,port_uncorr_err_mission_fault<%}%> iff(intf_per_err_vld);
<% } %>
<%if(obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") {%>
smi_prot_corr_err_cross : cross smi_prot_corr_error_type, smi_prot_corr_error_info, smi_prot_cmd_types<% if(obj.useResiliency){ %>,port_corr_err_thres_fault<%}%> iff(intf_per_err_vld);
<% } %>

normal_time_out_error : cross normal_time_out_error_type,normal_time_out_error_info_cmd_type; 

<%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) && obj.useCache)) { %>
sys_event_time_out_error : cross sys_event_time_out_error_type,sys_event_time_out_error_info;
<%}%>

<%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) && obj.useCache)) { %>
sysco_time_out_error : cross sysco_time_out_error_type,sysco_time_out_error_info{ 
 
ignore_bins ignore_protocol_timeout  = binsof(sysco_time_out_error_info) intersect {1} && binsof(sysco_time_out_error_type) intersect {'hB} ;
ignore_bins ignore_interface_timeout = binsof(sysco_time_out_error_info) intersect {0} && binsof(sysco_time_out_error_type) intersect {'hA} ;

}
<% } %>
 endgroup

<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" ) { %>
//#Cover.IOAIU.IllegaIOpToDII.DECERR
covergroup crresp_cmstatus_covergroup_core<%=port%>;

 op_crresp_errbit: coverpoint crresp_err_dtxfer[1] {
                       bins op_to_crresp_err          = {'h1};
                         }

 op_crresp_dtxferbit: coverpoint crresp_err_dtxfer[0] {
                      
                       bins op_to_crresp_dtxfer       = {'h1};
                         }

 op_cmstatus_dt_aiu: coverpoint cmstatus_dt_aiu_dmi [1] {
                        bins  dt_aiu_0       = {'h0};
                        bins  dt_aiu_1       = {'h1};
	               }

 op_cmstatus_dt_dmi: coverpoint cmstatus_dt_aiu_dmi [0] {
                        bins dt_dmi_0        = {'h0};
                        bins dt_dmi_1 	     = {'h1};
                      }  

  op_crresp_errbit_x_op_crresp_dtxferbit_X_op_cmstatus_dt_aiu_x_op_cmstatus_dt_dmi : cross op_crresp_errbit,op_crresp_dtxferbit,op_cmstatus_dt_aiu,op_cmstatus_dt_dmi {
                      ignore_bins cmstatus_dt_aiu_dmi_00 = ((binsof (op_crresp_errbit)) && (binsof (op_crresp_dtxferbit)) && (binsof (op_cmstatus_dt_aiu) intersect {0}) && (binsof (op_cmstatus_dt_dmi) intersect {'h0})) ;
                       
                    } 

endgroup
<% } %> 


//#Cover.IOAIU.IllegaIOpToDII.DECERR
covergroup illop_to_dii_covergroup_core<%=port%>;

 ill_op_to_dii: coverpoint ill_op_to_dii {
                       bins ill_op_to_dii           = {'h1};
                         }
 <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E") { %>
 ill_op_write_domain: coverpoint illop_awdomain {
                       bins wdomain_01              = {'h1};
                       bins wdomain_10              = {'h2};
	            }
 <%}%>
 ill_op_bresp: coverpoint illop_bresp{
                       bins bdecerr 	            = {'h3};
                      } 



ill_op_wsnoop:  coverpoint illop_awsnoop {
                        bins Wunq                                           = {'h0};
 <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>       
			bins WLunq  		                            = {'h1};
			bins Wcln   		                            = {'h2};
			bins Wbck   		                            = {'h3};
			bins Evct  		                            = {'h4};
			bins Wrevct 		                            = {'h5};
<%}%>

<%if(obj.fnNativeInterface == "ACE-LITE") { %>

			bins Wlunq  		                            = {'h1};
 <%}%>
			
<%if(obj.fnNativeInterface == "ACELITE-E") { %>
			bins Wunq_ATMSTR_LD_SWAP_COMPARE          	    = {'h0};
			bins WLunq  		  			    = {'h1};
                        bins Wrunqtlstash	    			    = {'h8};
                        bins Stashonceshared        			    = {'hc};
			bins Stashonceunq           			    = {'hD};
			<%}%>
                  }


 <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E") { %>
 ill_op_rdomain:  coverpoint illop_ardomain {
                       bins rdomain_01 = {'h1};
                       bins rdomain_10 = {'h2};
	            } 
<%}%>


ill_op_rsnoop: coverpoint illop_arsnoop {
                    bins Rdonc                                              = {'h0};
<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
		     bins Rdhsrd  	    				     = {'h1};
		     bins Rdcln   	     			  	     = {'h2};
		     bins Rdnsd             				     = {'h3};
	             bins Rdunq             				     = {'h7};
		     bins Clshrd             				     = {'h8}; 
		     bins Clnivld           				     = {'h9}; 
		     bins Clunq 	    				     = {'hB}; 
		     bins Mkunq   	    			             = {'hC}; 
                     bins Mkinvld 	                                     = {'hD};
<%}%>

<%if(obj.fnNativeInterface == "ACE-LITE") { %>
			bins Clnshrd        	 			     = {'h8};
			bins Clninvld       	 			     = {'h9};
			bins Mkinvld        				     = {'hD};
<%}%>

<%if(obj.fnNativeInterface == "ACELITE-E") { %>
			bins Clnshrd         	 			     = {'h8};
			bins Clninvld        	 			     = {'h9};
			bins Mkinvld             			     = {'hD};
			bins ClnShrdPrst          			     = {'hA};
			bins Rdoncmkinvl         			     = {'h5};
<%}%>
}

 ill_op_rresp: coverpoint illop_rresp{
                       bins rdecerr = {'h3};
                      }
<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E") { %>
 ill_op_write : cross ill_op_to_dii, ill_op_write_domain, ill_op_bresp,ill_op_wsnoop;
 ill_op_read  : cross ill_op_to_dii, ill_op_rdomain, ill_op_rresp,ill_op_rsnoop;
 <%} else {%>
 ill_op_write : cross ill_op_to_dii, ill_op_bresp,ill_op_wsnoop;
 ill_op_read  : cross ill_op_to_dii, ill_op_rresp,ill_op_rsnoop;
  <%}%>

endgroup

<%}%>

<%if(((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED") || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED")|| (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED"))) {%>
//#Cover.IOAIU.CorrectableErr.CESR
 covergroup correctable_error_covergroup_core0;

 correctable_error_type: coverpoint  cesr_err_type{

 <%if(obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED") {%>
 bins ott_uesr_err_type_0000    = {0};
 <% } else { %>
 illegal_bins ott_uesr_err_type_0000    = {0};
 <% } %>

 <%if((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED") || (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" )) {%>
 bins data_tag_user_err_type_0001  = {1};
 <%} else {%>
 illegal_bins data_tag_user_err_type_0001  = {1};
 <% } %>

 }
 correctable_error_info: coverpoint  cesr_err_info{

 <%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED") || (obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED")) {%>
 bins ott_tag_error_info_000  = {0};
 <% } else {%>
  illegal_bins ott_tag_error_info_000  = {0};
 <% } %>
 <%if((obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED")) {%>
 bins data_error_info_001      = {1};
 <%} else {%>
 illegal_bins data_error_info_001      = {1};
 <% } %>

 }

errcountoverflow: coverpoint cesr_errrcountoverflow{
                  bins overflow_0 = {0};
                  bins overflow_1 = {1}; 
}

errcounter: coverpoint cesr_counter{
                  bins errcount_255              = {255};
                  bins errcount_0_to_100         = {[0:100]}; 
                  bins errcount_101_to_200       = {[101:200]}; 
                  bins errcount_201_to_254       = {[201:254]}; 
}

correctabel_data_error : cross  correctable_error_info, correctable_error_type,errcounter,errcountoverflow{
<%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") || (obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY")) {%>
illegal_bins  ill_ott_error_info_001 = binsof(correctable_error_info) intersect {1} &&  binsof(correctable_error_type) intersect {0} ;
<% } %>
}
endgroup
<%}%>

   
    ////////////////////////////////////////
	// COVERGROUPS FOR READ ADDRESS CHANNEL
   	////////////////////////////////////////
	
    <%for(let port=0; port< obj.nNativeInterfacePorts; port+=1) {%>
    covergroup <%if((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%} else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%>ace_lite_e<%}%>_rd_addr_chnl_core<%=port%>;
                <%if(!(obj.nNativeInterfacePorts > 1)){ %>
                `COVER_POINT_RA_BURST_LENGTH
                <%}%>
                `COVER_POINT_RA_BURST_SIZE
                `COVER_POINT_RA_BURST_TYPE
                `COVER_POINT_RA_CACHELINE_ACCESS
                `COVER_POINT_RA_WEIRD_WRAP
                `CROSS_RA_BURST_TYPE_CACHELINE_ACCESS
               <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
               `ifndef VCS
                `CROSS_RA_BURST_LENGTH_SIZE_TYPE
               `else // `ifndef VCS
                <%if(!(obj.nNativeInterfacePorts > 1)){ %>
                `CROSS_RA_BURST_LENGTH_SIZE_TYPE
                <%}%>
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                `CROSS_RA_BURST_LENGTH_SIZE_TYPE
               <% } %>
                //`COVER_POINT_RA_ARID_MATCH
                //`COVER_POINT_RA_ARADDR_MATCH
                coverpoint_arlock: coverpoint arlock {
                    bins NORMAL = {NORMAL};
                    bins EXCLUSIVE = {EXCLUSIVE};
                }
                <%if(obj.nNativeInterfacePorts > 1){ %>
                    //multiport-CONC-10715
                burst_length: coverpoint arlen { 
                  <%if( (1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1 >= 15) {%>
                    bins wrap_maxarlen[] = {1,3,7,15} iff(arburst==AXIWRAP); <%} 
                  else if( (1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1 >= 7) {%>
                    bins wrap_maxarlen[] = {1,3,7} iff(arburst==AXIWRAP); <%}
                  else if( (1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1 >= 3) {%>
                    bins wrap_maxarlen[] = {1,3} iff(arburst==AXIWRAP); <%}
                  else if( (1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1 >= 1) {%>
                    bins wrap_maxarlen[]   = {1} iff(arburst==AXIWRAP); <%}%>

                  <%if(((1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1)>=255) {%>
                    bins incr_arlen[] = {[0:255]} iff(arburst==AXIINCR); 
                  <% } else {%>
                    bins incr_arlen[] = {[0:<%=((1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1)%>]} iff(arburst==AXIINCR); 
                  <% } %>
                }    
                <%}%>
                //#Cov.IOAIU.arcache
                cp_arcache: coverpoint arcache {
                    bins b_0000 = {0};
                    bins b_0001 = {1};
                    bins b_0010 = {2};
                    bins b_0011 = {3};
                  <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
                  `ifndef VCS
                    bins b_0100 = {4};
                    bins b_0101 = {5};
                  `endif // `ifndef VCS
                  <% } else {%>
                    bins b_0100 = {4};
                    bins b_0101 = {5};
                  <%}%>
                    bins b_0110 = {6};
                    bins b_0111 = {7};
                  <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
                  `ifndef VCS
                    bins b_1000 = {8};
                    bins b_1001 = {9};
                  `endif // `ifndef VCS
                  <% } else {%>
                    bins b_1000 = {8};
                    bins b_1001 = {9};
                  <%}%>
                    bins b_1010 = {10};
                    bins b_1011 = {11};
                  <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
                  `ifndef VCS
                    bins b_1100 = {12};
                    bins b_1101 = {13};
                  `endif // `ifndef VCS
                  <% } else {%>
                    bins b_1100 = {12};
                    bins b_1101 = {13};
                  <%}%>
                    bins b_1110 = {14};
                    bins b_1111 = {15};
                }
                cp_rd_narrow_length: coverpoint arlen {
                    bins arlen_0 = {0};
                }
              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                cp_cachelinetxn_arlen: coverpoint arlen {
                    bins allowed_arlen[] = {((SYS_nSysCacheline*8/(WXDATA)) - 1)};//Table C3-11 Cache line size transaction constraints burst_len={1,2,4,8,16}
                }
                cp_rdonce_arlen: coverpoint arlen {
                    bins allowed_rdonce_incr_arlen[] = {[0:((SYS_nSysCacheline*8/(WXDATA)) - 1)]} iff(arburst==AXIINCR);//https://arterisip.atlassian.net/browse/CONC-11571
                    bins allowed_rdonce_wrap_arlen[] = {((SYS_nSysCacheline*8/(WXDATA)) - 1)} iff(arburst==AXIWRAP);
                }
                //#Cov.IOAIU.ardomain
                cp_ardomain: coverpoint ardomain {
                    bins non_shareable = {0};
                    bins inner_shareable = {1};
                    bins outer_shareable = {2};
                    bins system_shareable = {3};
                }
              <%}%>
                cp_tgt_type: coverpoint tgt_type {
                    bins dii_tgt = {DII};
                    bins dmi_tgt = {DMI};
                } 

                //#Cov.IOAIU.araddr_type
                cp_araddr_type: coverpoint araddr[<%=(Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8)-1)):5%>:0] {
                    <%if(Math.ceil(Math.log2(obj.wData/8)) > 6) { %>wildcard <%}%>bins cache_align = {'b<%for(var i = (Math.ceil(Math.log2(obj.wData/8))); i > 6; i--) { %>?<%}%>000000};
                    <%for(var i = Math.ceil(Math.log2(obj.wData/8)); i >=0; i--){%>
                        //wildcard bins size_<%=i%>_align ={'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > i){%>?<%}else{%>0<%}}%>}  iff (arsize == <%=i%>);<%}%>
                    <%for(var i = Math.ceil(Math.log2(obj.wData/8)); i >0; i--){%>
                        wildcard bins size_<%=i%>_unalign ={<%for(var k = i; k > 0; k--){%>'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(k==j){%>1<%}else{%>?<%}}if(k>1){%>,<%}}%>}  iff (arsize == <%=i%>);<%}%>

                    <%for(var i = Math.ceil(Math.log2(obj.wData/8)); i >=0; i--){%>
                    <%for(var k = 0; k<Math.ceil((obj.wData/8)/(Math.pow(2,i))); k++){%>
                        wildcard bins size_<%=i%>_align_with_B<%=(k*(Math.pow(2,i))).toString(16).padStart((2),'0')%> ={'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > Math.ceil(Math.log2(obj.wData/8))){%>?<%}else{if(j > i){%><%=k.toString(2).padStart((j-i),'0')%><%j=i+1;}else{%>0<%}}}%>}  iff (arsize == <%=i%>);<%}}%>
                }


                cp_araddr_type_wide: coverpoint araddr[<%=(Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8)-1)):5%>:0] {
                <%for(var i = Math.ceil(Math.log2(obj.wData/8)); i >=Math.ceil(Math.log2(obj.wData/8)); i--){
                    if (Math.ceil(64/(Math.pow(2,i)))< 8){%>
                    bins size_<%=i%>_align_offset_<%=(0).toString(16).padStart((2),'0')%>_<%=((Math.ceil(64/(Math.pow(2,i))))*(Math.pow(2,i))).toString(16).padStart((2),'0')%>={<%for(var m = 0; m<Math.ceil(64/(Math.pow(2,i))); m++){%>'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > i){%><%=m.toString(2).padStart((j-i),'0')%><%j=i+1;}else{%>0<%}}if(m!=((Math.ceil(64/(Math.pow(2,i))))-1)){%>,<%}}%>} iff (awsize == <%=i%>);
                   <%}else{
                    for(var k = 0; k<Math.ceil(64/(Math.pow(2,i))); k=k+8){%>
                    bins size_<%=i%>_align_offset_<%=(k*(Math.pow(2,i))).toString(16).padStart((2),'0')%>_<%=((k+7)*(Math.pow(2,i))).toString(16).padStart((2),'0')%>={<%for(var m = 0; m<8; m++){%>'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > i){%><%=(k+m).toString(2).padStart((j-i),'0')%><%j=i+1;}else{%>0<%}}if(m!=7){%>,<%}}%>} iff (arsize == <%=i%>); <%}
                   }}%>           
              }
                 
 

                cp_araddr_type_narrow: coverpoint araddr[<%=(Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8)-1)):5%>:0] {
                <%for(var i = Math.ceil(Math.log2(obj.wData/8))-1; i >=0; i--){
                    if (Math.ceil(64/(Math.pow(2,i)))< 8){%>
                    bins size_<%=i%>_align_offset_<%=(0).toString(16).padStart((2),'0')%>_<%=((Math.ceil(64/(Math.pow(2,i))))*(Math.pow(2,i))).toString(16).padStart((2),'0')%>={<%for(var m = 0; m<Math.ceil(64/(Math.pow(2,i))); m++){%>'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > i){%><%=m.toString(2).padStart((j-i),'0')%><%j=i+1;}else{%>0<%}}if(m!=((Math.ceil(64/(Math.pow(2,i))))-1)){%>,<%}}%>} iff (awsize == <%=i%>);
                    <%}else{
                    for(var k = 0; k<Math.ceil(64/(Math.pow(2,i))); k=k+8){%>
                    bins size_<%=i%>_align_offset_<%=(k*(Math.pow(2,i))).toString(16).padStart((2),'0')%>_<%=((k+7)*(Math.pow(2,i))).toString(16).padStart((2),'0')%> ={<%for(var m = 0; m<8; m++){%>'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > i){%><%=(k+m).toString(2).padStart((j-i),'0')%><%j=i+1;}else{%>0<%}}if(m!=7){%>,<%}}%>} iff (arsize == <%=i%>); <%}
                }}%>           
              }



              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                cp_araddr_type_align:coverpoint araddr[<%=(Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8)-1)):5%>:0]{
                <%if(Math.ceil(Math.log2(obj.wData/8)) > 6) { %>wildcard <%}%>bins cache_align = {'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8))); j > 6; j--) { %>?<%}%>000000} ; 
                        wildcard bins buswidth_align ={'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > Math.ceil(Math.log2(obj.wData/8))){%>?<%}else{%>0<%}}%>}  ;
                }        
              <%}%>
             //A7.2.4 Exclusive access restrictions
            //The number of bytes to be transferred in an exclusive access burst must be a power of 2, that is, 1, 2, 4, 8, 16,32, 64, or 128 bytes
                cp_tansfer_size_excl:coverpoint tansfer_size_excl_rd{
                   bins excl_transfer_size[] = {1,2,4,8,16,32,64,128}iff(arlock==1) ;
                }
                cp_araddr_type_narrow_excl:coverpoint araddr[6:0]{
                  <%for(var i = Math.ceil(Math.log2(obj.wData/8))-1; i >=0; i--){%>
                        wildcard bins size_<%=i%>_align ={'b<%for(var j = 6; j > 0; j--) { if(j > i){%>?<%}else{%>0<%}}%>}  iff (excl_size_rd == <%=i%>);<%}%>
                }
                cp_araddr_type_wide_excl:coverpoint araddr[6:0]{
                  <%for(var i = 6; i >=Math.ceil(Math.log2(obj.wData/8)); i--){%>
                        wildcard bins size_<%=i%>_align ={'b<%for(var j = 6; j > 0; j--) { if(j > i){%>?<%}else{%>0<%}}%>}  iff (excl_size_rd == <%=i%> && arburst==AXIINCR );<%}%>
                  <%for(var i = 6; i >=Math.ceil(Math.log2((obj.wData/8)*2)); i--){%>
                        wildcard bins size_<%=i%>_align_wrap ={'b<%for(var j = 6; j > 0; j--) { if(j > i){%>?<%}else{%>0<%}}%>}  iff (excl_size_rd == <%=i%> && arburst==AXIWRAP );<%}%>
                }
                //#Cov.IOAIU.arcache X 
                arcache_x_rd_transfer: cross cp_arcache, burst_length{
                 <%if(!(obj.nNativeInterfacePorts > 1)){ %>
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                        ignore_bins ignored_arlen_arcache =  binsof(cp_arcache) intersect{'b0000,'b0001} && ! binsof(burst_length.wrap_arlen) intersect{[1:(SYS_nSysCacheline*8/(WXDATA)-1)]} ;//CONC_11492 -single core ignores
                     <% } else {%>
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                        ignore_bins ignored_arlen_arcache =  binsof(cp_arcache) intersect{'b0000,'b0001} && ! binsof(burst_length.wrap_maxarlen) intersect{[1:(SYS_nSysCacheline*8/(WXDATA)-1)]} ; //CONC_11492 -multicore core ignores
                     <%}%>

                        } 
                //Removed crosses which covered in below cross of cache,addrtype and narrow
                //CONC-10970
                cx_transfersize_exclusive: cross coverpoint_arlock,cp_tansfer_size_excl{
                	ignore_bins ignored_normal_txn  = binsof(coverpoint_arlock.NORMAL);  
                }
                cx_NarrowTxn_Noncoh_exclusive: cross coverpoint_arlock,cp_araddr_type_narrow_excl iff(arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0){
                	ignore_bins ignored_normal_txn  = binsof(coverpoint_arlock.NORMAL);  
                }
                //////////////////Coherent-Wide Reads,Cacheline Size Reads////////////////////////////

                
              <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
              //#Cover.IOAIU.DVMMessage 
              cp_ardomain_dvmMsg : coverpoint ardomain{
               bins ardomain_dvmmsg[]= {'b01,'b10} iff ( arsnoop == 4'b1110  );
              }
              //#Cover.IOAIU.DVMComplete
              cp_ardomain_dvmCmpl : coverpoint ardomain {
              bins ardomain_dvmcmpl[]= {'b01,'b10} iff ( arsnoop == 4'b1111  );
              }
              <%}%>
                //#Cover.IOAIU.CohNormalTxns.wr_devnonbuf
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                //burst type covered in cp burst_length refer COVER_POINT_RA_BURST_LENGTH 
                //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                //cx_coh_devnonbuf_wide_txn      : cross cp_araddr_type_wide,burst_length iff(arcache=='b0000 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1){
                //}
              <%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-12 ReadOnce and WriteUnique transaction constraints- axcache[1]=1 i.e. must be modifiable
              <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" ||obj.fnNativeInterface == "ACELITE-E") { %>
                //Table C3-12 ReadOnce and WriteUnique transaction constraints- axcache[1]=1 i.e. must be modifiable
                //#Cover.IOAIU.CohExcTxns.nr_devnonbuf
                //Table C3-11 Cache line size transaction constraints- axcache[1]=1 i.e. must be modifiable
                //#Cover.IOAIU.CohCleanShared.devnonbuf
                //#Cover.IOAIU.CohCleanInvalid.devnonbuf
                //#Cover.IOAIU.CohMakeInvalid.devnonbuf
              <%}%>
                //#Cover.IOAIU.CohNormalTxns.wr_devbuf
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                //cx_coh_devbuf_wide_txn         : cross cp_araddr_type_wide,burst_length iff(arcache=='b0001 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1){
                //}
              <%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-12 ReadOnce and WriteUnique transaction constraints- axcache[1]=1 i.e. must be modifiable
              <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" ||obj.fnNativeInterface == "ACELITE-E") { %>
                //Table C3-12 ReadOnce and WriteUnique transaction constraints- device must be modifiable
                //#Cover.IOAIU.CohExcTxns.wr_devbuf
                //Table C3-11 Cache line size transaction constraints- device must be modifiable
                //#Cover.IOAIU.CohCleanShared.devbuf
                //#Cover.IOAIU.CohCleanInvalid.devbuf
                //#Cover.IOAIU.CohMakeInvalid.devbuf
                <%}%>
                //#Cover.IOAIU.CohNormalTxns.wr_ncnornonbuf
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                cx_coh_norncnonbuf_wide_txn    : cross cp_araddr_type_wide,burst_length iff(arcache=='b0010 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-12 ReadOnce and WriteUnique transaction constraints : Must be Inner Shareable or Outer Shareable.
                cx_coh_ncnonbuf_rdonce_wr           : cross cp_araddr_type_wide ,cp_rdonce_arlen , cp_ardomain iff (arcache == 'b0010 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
              }<%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //Table C3-12 ReadOnce and WriteUnique transaction constraints : Must be Inner Shareable or Outer Shareable.
                //#Cover.IOAIU.CohCleanShared.ncnornonbuf
                cx_coh_ncnonbuf_clnshrd        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0010  && ardomain inside {'b10, 'b01} && arsnoop == 'b1000 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline) ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohCleanInvalid.ncnornonbuf
                cx_coh_ncnonbuf_clninvld        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b0010  && ardomain inside {'b10, 'b01} && arsnoop == 'b1001 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline) ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohMakeInvalid.ncnornonbuf
                cx_coh_ncnonbuf_mkinvld        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b0010  && ardomain inside {'b10, 'b01} && arsnoop == 'b1101 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline) ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.CohCleanSharedPersist.ncnornonbuf
                //#Cover.IOAIU.CohCleanSharedPersist.norncbuf
                cx_coh_ncnonbuf_clnshrdpersist        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b0010  && ardomain inside {'b10, 'b01} && arsnoop == 'b1010 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline) ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohRdonceCleanInvalid.ncnornonbuf
                //#Cover.IOAIU.CohRdonceCleanInvalid.wtwalloc
                cx_coh_ncnonbuf_rdonceclninvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0010  && ardomain inside {'b10, 'b01} && arsnoop == 'b0100 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline) ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } //#Cover.IOAIU.CohRdonceMakeInvalid.ncnornonbuf
                cx_coh_ncnonbuf_rdoncemkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0010  && ardomain inside {'b10, 'b01} && arsnoop == 'b0101 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline) ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } <%}%>
                //#Cover.IOAIU.CohNormalTxns.wr_norncbuf
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                cx_coh_norncbuf_wide_txn       : cross cp_araddr_type_wide,burst_length iff(arcache=='b0011 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-12 ReadOnce and WriteUnique transaction constraints : Must be Inner Shareable or Outer Shareable.
                cx_coh_ncbuf_rdonce_wr              : cross cp_araddr_type_wide , cp_rdonce_arlen , cp_ardomain iff (arcache == 'b0011 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
              <%if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohCleanShared.ncnonbuf
                cx_coh_ncbuf_clnshrd        : cross cp_araddr_type_align  ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0011  && ardomain inside {'b10, 'b01} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohCleanInvalid.ncnonbuf
                cx_coh_ncbuf_clninvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0011  && ardomain inside {'b10, 'b01} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohMakeInvalid.ncnonbuf
                cx_coh_ncbuf_mkinvld        : cross cp_araddr_type_align  ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0011  && ardomain inside {'b10, 'b01} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.CohCleanSharedPersist.ncnonbuf
                cx_coh_ncbuf_clnshrdpersist        : cross cp_araddr_type_align  ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0011  && ardomain inside {'b10,'b01} && arsnoop == 'b1010  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
              <%if(obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohRdonceCleanInvalid.norncbuf
                cx_coh_ncbuf_rdonceclninvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0011  && ardomain inside {'b10, 'b01} && arsnoop == 'b0100  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } //#Cover.IOAIU.CohRdonceMakeInvalid.norncbuf
                cx_coh_ncbuf_rdoncemkinvld        : cross cp_araddr_type_align  ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0011  && ardomain inside {'b10, 'b01} && arsnoop == 'b0101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } <%}%> 
                //#Cover.IOAIU.CohNormalTxns.wr_wtralloc
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                cx_coh_wtralloc_wide_txn       : cross cp_araddr_type_wide,burst_length iff(arcache=='b0110 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-12 ReadOnce and WriteUnique transaction constraints : Must be Inner Shareable or Outer Shareable.
                cx_coh_wtralloc_rdonce_wr       : cross cp_araddr_type_wide , cp_rdonce_arlen , cp_ardomain iff (arcache == 'b0110 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohCleanShared.wtralloc
                cx_coh_wtralloc_clnshrd        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b0110  && ardomain inside {'b10, 'b01} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohCLeanInvalid.wtralloc
                cx_coh_wtralloc_clninvld        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b0110  && ardomain inside {'b10, 'b01} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohMakeInvalid.wtralloc
                cx_coh_wtralloc_mkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0110  && ardomain inside {'b10, 'b01} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.CohCleanSharedPersist.wtralloc
                cx_coh_wtralloc_clnshrdpersist        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b0110  && ardomain inside {'b10, 'b01} && arsnoop == 'b1010  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohRdonceCLeanInvalid.wtralloc
                cx_coh_wtralloc_rdonceclninvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0110  && ardomain inside {'b10, 'b01} && arsnoop == 'b0100  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } //#Cover.IOAIU.CohRdonceMakeInvalid.wtralloc
                cx_coh_wtralloc_rdoncemkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0110  && ardomain inside {'b10,'b01} && arsnoop == 'b0101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } <%}%>
                //#Cover.IOAIU.CohNormalTxns.wr_wtwalloc
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                cx_coh_wtwalloc_wide_txn       : cross cp_araddr_type_wide,burst_length iff(arcache=='b1010 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-12 ReadOnce and WriteUnique transaction constraints : Must be Inner Shareable or Outer Shareable.
                cx_coh_wtwalloc_rdonce_wr       : cross cp_araddr_type_wide , cp_rdonce_arlen , cp_ardomain iff (arcache == 'b1010 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohCleanShared.wtwalloc
                cx_coh_wtwalloc_clnshrd        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1010  && ardomain inside {'b10, 'b01} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohCLeanInvalid.wtwalloc
                cx_coh_wtwalloc_clninvld        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1010  && ardomain inside {'b10, 'b01} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohMakeInvalid.wtwalloc
                cx_coh_wtwalloc_mkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b1010  && ardomain inside {'b10, 'b01} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.CohCleanSharedPersist.wtwalloc
                cx_coh_wtwalloc_clnshrdpersist        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1010  && ardomain inside {'b10, 'b01} && arsnoop == 'b1010  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohRdonceCLeanInvalid.wtwalloc
                cx_coh_wtwalloc_rdonceclninvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b1010  && ardomain inside {'b10,'b01} && arsnoop == 'b0100  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } //#Cover.IOAIU.CohRdonceMakeInvalid.wtwalloc
                cx_coh_wtwalloc_rdoncemkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b1010  && ardomain inside {'b10,'b01} && arsnoop == 'b0101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } <%}%>
                //#Cover.IOAIU.CohNormalTxns.wr_wtrwalloc
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                cx_coh_wtrwalloc_wide_txn      : cross cp_araddr_type_wide,burst_length iff(arcache=='b1110 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_wtrwalloc_rdonce_wr         : cross cp_araddr_type_wide , cp_rdonce_arlen , cp_ardomain iff (arcache == 'b1110 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohCleanShared.wtrwalloc
                cx_coh_wtrwalloc_clnshrd        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1110  && ardomain inside {'b10, 'b01} && arsnoop == 'b1000  && ((arlen+1) *( 2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohCleanInvalid.wtrwalloc
                cx_coh_wtrwalloc_clninvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b1110  && ardomain inside {'b10, 'b01} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohMakeInvalid.wtrwalloc
                cx_coh_wtrwalloc_mkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b1110  && ardomain inside {'b10, 'b01} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.CohCleanSharedPersist.wtrwalloc
                cx_coh_wtrwalloc_clnshrdpersist        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1110  && ardomain inside {'b10, 'b01} && arsnoop == 'b1010  && ((arlen+1) *( 2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" ) { %>
                //#Cover.IOAIU.CohRdonceCleanInvalid.wtrwalloc
                cx_coh_wtrwalloc_rdonceclninvld        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1110  && ardomain inside {'b10, 'b01} && arsnoop == 'b0100  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } //#Cover.IOAIU.CohRdonceMakeInvalid.wtrwalloc
                cx_coh_wtrwalloc_rdoncemkinvld        : cross cp_araddr_type_align , cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1110  && ardomain inside {'b10, 'b01} && arsnoop == 'b0101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } <%}%>
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                //#Cover.IOAIU.CohNormalTxns.wr_wbralloc
                cx_coh_wbralloc_wide_txn       : cross cp_araddr_type_wide,burst_length iff(arcache=='b0111 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_wbralloc_rdonce_wr       : cross cp_araddr_type_wide , cp_rdonce_arlen , cp_ardomain iff (arcache == 'b0111 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
              <%if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohCleanShared.wbralloc
                cx_coh_wbralloc_clnshrd        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0111  && ardomain inside {'b10, 'b01} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohCleanInvalid.wbralloc
                cx_coh_wbralloc_clninvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0111  && ardomain inside {'b10, 'b01} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohMakeInvalid.wbralloc
                cx_coh_wbralloc_mkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0111  && ardomain inside {'b10, 'b01} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.CohCleanSharedPersist.wbralloc
                cx_coh_wbralloc_clnshrdpersist        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0111  && ardomain inside {'b10, 'b01} && arsnoop == 'b1010  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohRdonceCleanInvalid.wbralloc
                cx_coh_wbralloc_Rdonceclninvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0111  && ardomain inside {'b10, 'b01} && arsnoop == 'b0100  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } //#Cover.IOAIU.CohRdonceMakeInvalid.wbralloc
                cx_coh_wbralloc_Rdoncemkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b0111  && ardomain inside {'b10, 'b01} && arsnoop == 'b0101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } <%}%>
                //#Cover.IOAIU.CohNormalTxns.wr_wbwalloc
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                cx_coh_wbwalloc_wide_txn       : cross cp_araddr_type_wide,burst_length iff(arcache=='b1011 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_wbwalloc_rdonce_wr       : cross cp_araddr_type_wide , cp_rdonce_arlen , cp_ardomain iff (arcache == 'b1011 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohCleanShared.wbwalloc
                cx_coh_wbwalloc_clnshrd        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1011  && ardomain inside {'b10, 'b01} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohCleanInvalid.wbwalloc
                cx_coh_wbwalloc_clninvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1011  && ardomain inside {'b10, 'b01} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohMakeInvalid.wbwalloc
                cx_coh_wbwalloc_mkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1011  && ardomain inside {'b10, 'b01} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.CohCleanSharedPersist.wbwalloc
                cx_coh_wbwalloc_clnshrdpersist        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1011  && ardomain inside {'b10, 'b01} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E") { %>
                ////AXI_ACE_Update_v3.0 ,8.shareability domain signaling- design make use of outer shareable for all inner shareable domains
                //#Cover.IOAIU.CohRdonceCleanInvalid.wbwalloc
                cx_coh_wbwalloc_Rdonceclninvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1011  && ardomain inside {'b10, 'b01} && arsnoop == 'b0100  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } //#Cover.IOAIU.CohRdonceMakeInvalid.wbwalloc
                cx_coh_wbwalloc_Rdoncemkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type,cp_ardomain iff (arcache == 'b1011  && ardomain inside {'b10, 'b01} && arsnoop == 'b0101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } <%}%>
                //#Cover.IOAIU.CohNormalTxns.wr_wbrwalloc
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                cx_coh_wbrwalloc_wide_txn      : cross cp_araddr_type_wide,burst_length iff(arcache=='b1111 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_wbrwalloc_rdonce_wr      : cross cp_araddr_type_wide , cp_rdonce_arlen , cp_ardomain iff (arcache == 'b1111 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
              <%if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.CohCleanShared.wbrwalloc
                cx_coh_wbrwalloc_clnshrd        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b1111  && ardomain inside {'b10, 'b01} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohCleanInvalid.wbrwalloc
                cx_coh_wbrwalloc_clninvld       : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b1111  && ardomain inside {'b10, 'b01} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } //#Cover.IOAIU.CohMakeInvalid.wbrwalloc
                cx_coh_wbrwalloc_mkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b1111  && ardomain inside {'b10, 'b01} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.CohCleanSharedPersist.wbrwalloc
                cx_coh_wbrwalloc_clnshrdpersist        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b1111  && ardomain inside {'b10,'b01} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E") { %>
                //AXI_ACE_Update_v3.0 ,8.shareability domain signaling- design make use of outer shareable for all inner shareable domains
                //#Cover.IOAIU.CohRdonceCleanInvalid.wbrwalloc
                cx_coh_wbrwalloc_rdonceclninvld       : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b1111  && ardomain inside {'b10, 'b01} && arsnoop == 'b0100  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } //#Cover.IOAIU.CohRdonceMakeInvalid.wbrwalloc
                cx_coh_wbrwalloc_rdoncemkinvld        : cross cp_araddr_type_align ,cp_cachelinetxn_arlen,burst_type, cp_ardomain iff (arcache == 'b1111  && ardomain inside {'b10, 'b01} && arsnoop == 'b0101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,1,3};  
                } <%}%>
                <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.ReadCleanNormal
                cx_readclean_normal : cross cp_araddr_type_align , cp_ardomain, cp_cachelinetxn_arlen,burst_type,cp_arcache iff(arlock==0 && arsnoop=='b0010 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                ignore_bins ignore_cache_dmitgt= binsof(cp_arcache) intersect {'b0000,'b0001} ;// CONC-11546
                	ignore_bins invalid_arcache  = binsof(cp_ardomain)intersect {0,3};  
                }
               //#Cover.IOAIU.ReadSharedNormal
                cx_readshared_normal : cross cp_araddr_type_align , cp_ardomain, cp_cachelinetxn_arlen,burst_type,cp_arcache iff(arlock==0 && arsnoop=='b0001 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                ignore_bins ignore_cache_dmitgt= binsof(cp_arcache) intersect {'b0000,'b0001} ;// CONC-11546
                	ignore_bins invalid_arcache  = binsof(cp_ardomain)intersect {0,3};  
                }
               //#Cover.IOAIU.ReadNotSharedDirtyNormal
                cx_readnotshareddirty_normal : cross cp_araddr_type_align , cp_ardomain, cp_cachelinetxn_arlen,burst_type,cp_arcache iff(arlock==0 && arsnoop=='b0011&& ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                ignore_bins ignore_cache_dmitgt= binsof(cp_arcache) intersect {'b0000,'b0001} ;// CONC-11546
                	ignore_bins invalid_arcache  = binsof(cp_ardomain)intersect {0,3};  
                }
               //#Cover.IOAIU.ReadUniqueNormal
                cx_readunique_normal : cross cp_araddr_type_align , cp_ardomain, cp_cachelinetxn_arlen,burst_type,cp_arcache iff(arlock==0 && arsnoop=='b0111 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                ignore_bins ignore_cache_dmitgt= binsof(cp_arcache) intersect {'b0000,'b0001} ;// CONC-11546
                	ignore_bins invalid_arcache  = binsof(cp_ardomain)intersect {0,3};  
                }
               //#Cover.IOAIU.CleanUniqueNormal
                cx_cleanunique_normal : cross cp_araddr_type_align , cp_ardomain, cp_cachelinetxn_arlen,burst_type,cp_arcache iff(arlock==0 && arsnoop=='b1011 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                ignore_bins ignore_cache_dmitgt= binsof(cp_arcache) intersect {'b0000,'b0001} ;// CONC-11546
                	ignore_bins invalid_arcache  = binsof(cp_ardomain)intersect {0,3};  
                }
               //#Cover.IOAIU.MakeUniqueNormal
                cx_makeunique_normal : cross cp_araddr_type_align , cp_ardomain, cp_cachelinetxn_arlen,burst_type,cp_arcache iff(arlock==0 && arsnoop=='b1100 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                ignore_bins ignore_cache_dmitgt= binsof(cp_arcache) intersect {'b0000,'b0001} ;// CONC-11546
                	ignore_bins invalid_arcache  = binsof(cp_ardomain)intersect {0,3};  
                }
               //#Cover.IOAIU.ReadCleanExclusive
               //#Cover.IOAIU.ReadCleanExcl
                cx_readclean_exclusive : cross cp_araddr_type_align , cp_ardomain, cp_cachelinetxn_arlen,burst_type,cp_arcache iff(arlock==1 && arsnoop=='b0010 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                ignore_bins ignore_invalid_cache= !binsof(cp_arcache) intersect {'b0010,'b0011} ;// CONC-11546
                	ignore_bins invalid_ardomain  = binsof(cp_ardomain)intersect {0,3};  
                }
               //#Cover.IOAIU.ReadSharedExclusive
               //#Cover.IOAIU.ReadSharedExcl
                cx_readshared_exclusive : cross cp_araddr_type_align , cp_ardomain, cp_cachelinetxn_arlen,burst_type,cp_arcache iff(arlock==1 && arsnoop=='b0001 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                ignore_bins ignore_invalid_cache= !binsof(cp_arcache) intersect {'b0010,'b0011} ;// CONC-11546
                	ignore_bins invalid_ardomain  = binsof(cp_ardomain)intersect {0,3};  
                }
               //#Cover.IOAIU.CleanUniqueExclusive
                //#Cover.IOAIU.CleanUniqueExcl
                cx_cleanunique_exclusive : cross cp_araddr_type_align , cp_ardomain, cp_cachelinetxn_arlen,burst_type,cp_arcache iff(arlock==1 && arsnoop=='b1011 && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                ignore_bins ignore_invalid_cache= !binsof(cp_arcache) intersect {'b0010,'b0011} ;// CONC-11546
                	ignore_bins invalid_ardomain  = binsof(cp_ardomain)intersect {0,3};  
                }

                <%}%>
                //////////////////////////Noncoherent- Narrow Reads, Cacheline Size Reads////////////////////////////////////////////////

                //#Cover.IOAIU.CohNormalTxns.nr_devnonbuf
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                //cx_coh_devnonbuf_narrow_txn      : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type iff(arcache=='b0000 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1) {
                //	ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                // }
              <%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-12 ReadOnce and WriteUnique transaction constraints- axcache[1]=1 i.e. must be modifiable
              <%}%> 
                //#Cover.IOAIU.CohNormalTxns.nr_devbuf
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                //cx_coh_devbuf_narrow_txn         : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type iff(arcache=='b0001 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1) {
                //ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                //}
              <%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-12 ReadOnce and WriteUnique transaction constraints- axcache[1]=1 i.e. must be modifiable
              <%}%>
                //#Cover.IOAIU.CohNormalTxns.nr_ncnornonbuf
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                cx_coh_norncnonbuf_narrow_txn    : cross cp_araddr_type_narrow,burst_type iff(arcache=='b0010 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_ncnonbuf_nr      : cross cp_araddr_type_narrow,burst_type, cp_ardomain iff (arcache == 'b0010 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
                //#Cover.IOAIU.CohNormalTxns.nr_norncbuf
              <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))) { %>
                cx_coh_norncbuf_narrow_txn       : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type iff(arcache=='b0011 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_ncbuf_nr      : cross cp_araddr_type_narrow ,burst_type,cp_ardomain iff (arcache == 'b0011 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
                //#Cover.IOAIU.CohNormalTxns.nr_wtralloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_coh_wtralloc_narrow_txn       : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type iff(arcache=='b0110 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_wtralloc_nr      : cross cp_araddr_type_narrow ,burst_type, cp_ardomain iff (arcache == 'b0110 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
                //#Cover.IOAIU.CohNormalTxns.nr_wtwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_coh_wtwalloc_narrow_txn       : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type iff(arcache=='b1010 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_wtwalloc_nr      : cross cp_araddr_type_narrow ,burst_type, cp_ardomain iff (arcache == 'b1010 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
                //#Cover.IOAIU.CohNormalTxns.nr_wtrwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_coh_wtrwalloc_narrow_txn      : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type iff(arcache=='b1110 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_wtrwalloc_nr      : cross cp_araddr_type_narrow ,burst_type, cp_ardomain iff (arcache == 'b1110 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
                //#Cover.IOAIU.CohNormalTxns.nr_wbralloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_coh_wbralloc_narrow_txn       : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type iff(arcache=='b0111 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E"|| obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_wbralloc_nr      : cross cp_araddr_type_narrow ,burst_type, cp_ardomain iff (arcache == 'b0111 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
                //#Cover.IOAIU.CohNormalTxns.nr_wbwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_coh_wbwalloc_narrow_txn       : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type iff(arcache=='b1011 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_wbwalloc_nr      : cross cp_araddr_type_narrow ,burst_type, cp_ardomain iff (arcache == 'b1011 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
                //#Cover.IOAIU.CohNormalTxns.nr_wbrwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_coh_wbrwalloc_narrow_txn      : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type iff(arcache=='b1111 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E" ||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_coh_wbrwalloc_nr      : cross cp_araddr_type_narrow,burst_type, cp_ardomain iff (arcache == 'b1111 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && ardomain inside {'b10, 'b01} && arsnoop == 0 && arlock == 0){
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {0,3};  
                } <%}%> 
                //////////////////////////Noncoherent- Wide Reads////////////////////////////////////////////////

                //burst type covered in cp burst_length refer COVER_POINT_RA_BURST_LENGTH 
                //#Cover.IOAIU.NonCohNormalTxns.wr_devnonbuf
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_devnonbuf_wide_txn      : cross cp_araddr_type_wide,burst_length,cp_tgt_type iff(arcache=='b0000 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                cx_noncoh_devnonbuf_wr      : cross cp_araddr_type_wide,burst_length,cp_ardomain,cp_tgt_type iff(arcache=='b0000 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11} && arsnoop == 0 && arlock == 0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {0,1,2};  
                } <%}%>
                //#Cover.IOAIU.NonCohExcTxns.wr_devnonbuf
                //exclusive address is transfer size aligned
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_devnonbuf_wide_txn_excl      : cross cp_araddr_type_wide_excl,cp_tgt_type iff(arcache=='b0000 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==1){
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_devnonbuf_wr_excl      : cross cp_araddr_type_wide_excl,cp_ardomain,cp_tgt_type iff(arcache=='b0000 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11}&& arsnoop == 0 && arlock == 1){
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {0,1,2};  
                } <%}%>
                //#Cover.IOAIU.NonCohNormalTxns.wr_devbuf
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_devbuf_wide_txn         : cross cp_araddr_type_wide,burst_length,cp_tgt_type iff(arcache=='b0001 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                cx_noncoh_devbuf_wr         : cross cp_araddr_type_wide,burst_length,cp_ardomain,cp_tgt_type iff(arcache=='b0001 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11}&& arsnoop == 0 && arlock == 0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {0,1,2};  
                } <%}%>
                //#Cover.IOAIU.NonCohExcTxns.wr_devbuf  
                //exclusive address is transfer size aligned
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_devbuf_wide_txn_excl         : cross cp_araddr_type_wide_excl,cp_tgt_type iff(arcache=='b0001 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==1){
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_devbuf_wr_excl         : cross cp_araddr_type_wide_excl,cp_ardomain,cp_tgt_type iff(arcache=='b0001 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11}&& arsnoop == 0 && arlock == 1){
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {0,1,2};  
                } <%}%>
                //#Cover.IOAIU.NonCohNormalTxns.wr_ncnornonbuf
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_norncnonbuf_wide_txn    : cross cp_araddr_type_wide,burst_length,cp_tgt_type iff(arcache=='b0010 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_ncnonbuf_wr    : cross cp_araddr_type_wide,burst_length,cp_ardomain,cp_tgt_type iff(arcache=='b0010 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11}&& arsnoop == 0 && arlock == 0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                } <%}%>
                //#Cover.IOAIU.NonCohExcTxns.wr_ncnornonbuf
                //exclusive address is transfer size aligned
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_norncnonbuf_wide_txn_excl    : cross cp_araddr_type_wide_excl,cp_tgt_type iff(arcache=='b0010 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==1){
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_ncnonbuf_wr_excl    : cross cp_araddr_type_wide_excl,cp_ardomain,cp_tgt_type iff(arcache=='b0010 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11}&& arsnoop == 0 && arlock == 1){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                } <%}%> 
                //#Cover.IOAIU.NonCohNormalTxns.wr_norncbuf
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_norncbuf_wide_txn       : cross cp_araddr_type_wide,burst_length,cp_tgt_type iff(arcache=='b0011 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_ncbuf_wr    : cross cp_araddr_type_wide,burst_length,cp_ardomain,cp_tgt_type iff(arcache=='b0011 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11}&& arsnoop == 0 && arlock == 0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                } <%}%> 
                //#Cover.IOAIU.NonCohExcTxns.wr_norncbuf
                //exclusive address is transfer size aligned
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_norncbuf_wide_txn_excl       : cross cp_araddr_type_wide_excl,cp_tgt_type iff(arcache=='b0011 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==1){
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_ncbuf_wr_excl    : cross cp_araddr_type_wide_excl,cp_ardomain,cp_tgt_type iff(arcache=='b0011 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11} && arsnoop == 0 && arlock == 1){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                } <%}%> 
                //#Cover.IOAIU.NonCohNormalTxns.wr_wtralloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wtralloc_wide_txn       : cross cp_araddr_type_wide,burst_length iff(arcache=='b0110 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                cx_noncoh_wtralloc_wr    : cross cp_araddr_type_wide,burst_length,cp_ardomain,cp_tgt_type iff(arcache=='b0110 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11} && arsnoop == 0 && arlock == 0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%> 
                //#Cover.IOAIU.NonCohNormalTxns.wr_wtwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wtwalloc_wide_txn       : cross cp_araddr_type_wide,burst_length iff(arcache=='b1010 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                cx_noncoh_wtwalloc_wr    : cross cp_araddr_type_wide,burst_length,cp_ardomain,cp_tgt_type iff(arcache=='b1010 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11} && arsnoop == 0 && arlock == 0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%> 
                //#Cover.IOAIU.NonCohNormalTxns.wr_wtrwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wtrwalloc_wide_txn      : cross cp_araddr_type_wide,burst_length,cp_tgt_type iff(arcache=='b1110 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                cx_noncoh_wtrwalloc_wr    : cross cp_araddr_type_wide,burst_length,cp_ardomain,cp_tgt_type iff(arcache=='b1110 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11} && arsnoop == 0 && arlock == 0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%> 
                //#Cover.IOAIU.NonCohNormalTxns.wr_wbralloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wbralloc_wide_txn       : cross cp_araddr_type_wide,burst_length,cp_tgt_type iff(arcache=='b0111 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                cx_noncoh_wbralloc_wr    : cross cp_araddr_type_wide,burst_length,cp_ardomain,cp_tgt_type iff(arcache=='b0111 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11} && arsnoop == 0 && arlock == 0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%> 
                //#Cover.IOAIU.NonCohNormalTxns.wr_wbwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wbwalloc_wide_txn       : cross cp_araddr_type_wide,burst_length,cp_tgt_type iff(arcache=='b1011 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_wbwalloc_wr    : cross cp_araddr_type_wide,burst_length,cp_ardomain,cp_tgt_type iff(arcache=='b1011 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11} && arsnoop == 0 && arlock == 0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%> 
                //#Cover.IOAIU.NonCohNormalTxns.wr_wbrwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wbrwalloc_wide_txn      : cross cp_araddr_type_wide,burst_length,cp_tgt_type iff(arcache=='b1111 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_wbrwalloc_wr    : cross cp_araddr_type_wide,burst_length,cp_ardomain,cp_tgt_type iff(arcache=='b1111 && arsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && ardomain inside {'b00, 'b11} && arsnoop == 0 && arlock == 0){
                ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%> 

                //////////////////////////Noncoherent- Narrow Reads, Cacheline Size Reads////////////////////////////////////////////////
                //#Cover.IOAIU.NonCohNormalTxns.nr_devnonbuf
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_devnonbuf_narrow_txn      : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_tgt_type iff(arcache=='b0000 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0) {
                    ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
 ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                cx_noncoh_devnonbuf_nr      : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b0000 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==0 && ardomain inside {'b00,'b11} && arsnoop==0) {
                 ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {0,1,2};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
                //#Cover.IOAIU.NonCohExcTxns.nr_devnonbuf
                //exclusive address is transfer size aligned
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_devnonbuf_narrow_txn_excl      : cross cp_araddr_type_narrow_excl,burst_type,cp_tgt_type iff(arcache=='b0000 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==1) {
                   ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
  ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                cx_noncoh_devnonbuf_nr_excl      : cross cp_araddr_type_narrow_excl,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b0000 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==1 && ardomain inside {'b00,'b11} && arsnoop==0) {
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {0,1,2};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //Table C3-11 Cache line size transaction constraints - cache line transactions must be modifiable
                //#Cover.IOAIU.NonCohCleanShared.devnonbuf
                //#Cover.IOAIU.NonCohCleanInvalid.devnonbuf
                //#Cover.IOAIU.NonCohMakeInvalid.devnonbuf
               <%}%> 
                //#Cover.IOAIU.NonCohNormalTxns.nr_devbuf
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_devbuf_narrow_txn         : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_tgt_type iff(arcache=='b0001 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0) {
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                cx_noncoh_devbuf_nr         : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_ardomain, cp_tgt_type iff(arcache=='b0001 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==0 && ardomain inside {'b00,'b11} && arsnoop==0) {
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {0,1,2};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
                //#Cover.IOAIU.NonCohExcTxns.nr_devbuf
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_devbuf_narrow_txn_excl         : cross cp_araddr_type_narrow_excl,burst_type,cp_tgt_type iff(arcache=='b0001 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==1) {
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                cx_noncoh_devbuf_nr_excl         : cross cp_araddr_type_narrow_excl,burst_type,cp_ardomain, cp_tgt_type iff(arcache=='b0001 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==1 && ardomain inside {'b00,'b11} && arsnoop==0) {
                ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {0,1,2};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //Table C3-11 Cache line size transaction constraints - cache line transactions must be modifiable
                //#Cover.IOAIU.NonCohCleanShared.devbuf
                //#Cover.IOAIU.NonCohCleanInvalid.devbuf
                //#Cover.IOAIU.NonCohMakeInvalid.devbuf
                 <%}%>
                //#Cover.IOAIU.NonCohNormalTxns.nr_ncnornonbuf
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_norncnonbuf_narrow_txn    : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_tgt_type iff(arcache=='b0010 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_ncnonbuf_nr     : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b0010 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==0 && ardomain inside {'b00,'b11} && arsnoop==0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
                //#Cover.IOAIU.NonCohExcTxns.nr_ncnornonbuf
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_norncnonbuf_narrow_txn_excl    : cross cp_araddr_type_narrow_excl,burst_type,cp_tgt_type iff(arcache=='b0010 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==1) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_ncnonbuf_nr_excl    : cross cp_araddr_type_narrow_excl,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b0010 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==1 && ardomain inside {'b00,'b11} && arsnoop==0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.NonCohCleanShared.ncnornonbuf
                cx_noncoh_ncnonbuf_clnshrd        : cross cp_araddr_type_align ,cp_ardomain,cp_tgt_type iff (arcache == 'b0010  && ardomain inside {'b00} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {3};  
                }//#Cover.IOAIU.NonCohCleanInvalid.ncnornonbuf
                cx_noncoh_ncnonbuf_clninvld        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b0010  && ardomain inside {'b00} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {3};  
                }//#Cover.IOAIU.NonCohMakeInvalid.ncnornonbuf
                cx_noncoh_ncnonbuf_mkinvld        : cross cp_araddr_type_align ,cp_ardomain,cp_tgt_type iff (arcache == 'b0010  && ardomain inside {'b00} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.NonCohCleanSharedPersist.ncnornonbuf
                cx_noncoh_ncnonbuf_clnshrdpersist        : cross cp_araddr_type_align ,cp_ardomain,cp_tgt_type iff (arcache == 'b0010  && ardomain inside {'b00, 'b11} && arsnoop == 'b1010  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                        }
                 //AXI_ACE_Update_v3.0 RdonceCleanInvalid and RdonceMakeinvalid supported for the Inner or Outer Shareable domain       
                <%}%>
                //#Cover.IOAIU.NonCohNormalTxns.nr_norncbuf
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_norncbuf_narrow_txn       : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_tgt_type iff(arcache=='b0011 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_ncbuf_nr     : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b0011 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==0 && ardomain inside {'b00,'b11} && arsnoop==0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
                //#Cover.IOAIU.NonCohExcTxns.nr_norncbuf
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_norncbuf_narrow_txn_excl       : cross cp_araddr_type_narrow_excl,burst_type,cp_tgt_type iff(arcache=='b0011 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==1) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_ncbuf_nr_excl     : cross cp_araddr_type_narrow_excl,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b0011 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==1 && ardomain inside {'b00,'b11}&& arsnoop==0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //#Cover.IOAIU.NonCohCleanShared.norncbuf
                cx_noncoh_ncbuf_clnshrd        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b0011  && ardomain inside {'b00} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {3};  
                }//#Cover.IOAIU.NonCohCleanInvalid.norncbuf
                cx_noncoh_ncbuf_clninvld        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b0011  && ardomain inside {'b00} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {3};  
                }//#Cover.IOAIU.NonCohMakeInvalid.norncbuf
                cx_noncoh_ncbuf_mkinvld        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b0011  && ardomain inside {'b00} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2};  
                	ignore_bins ignore_noncoh_domain  = binsof(cp_ardomain)intersect {3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.NonCohCleanSharedPersist.norncbuf
                cx_noncoh_ncbuf_clnshrdpersist        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b0011  && ardomain inside {'b00, 'b11} && arsnoop == 'b1010  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                        }
                 //AXI_ACE_Update_v3.0 RdonceCleanInvalid and RdonceMakeinvalid supported for the Inner or Outer Shareable domain       
                <%}%>
                //#Cover.IOAIU.NonCohNormalTxns.nr_wtralloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wtralloc_narrow_txn       : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_tgt_type iff(arcache=='b0110 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_wtralloc_nr     : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b0110 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==0 && ardomain inside {'b00,'b11}&& arsnoop==0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations
                //#Cover.IOAIU.NonCohCleanShared.wtralloc
                cx_noncoh_wtralloc_clnshrd        : cross cp_araddr_type_align, cp_ardomain,cp_tgt_type iff (arcache == 'b0110  && ardomain inside {'b00, 'b11} && arsnoop == 'b1000  && ((arlen+1) *( 2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohCleanInvalid.wtralloc
                cx_noncoh_wtralloc_clninvld        : cross cp_araddr_type_align, cp_ardomain,cp_tgt_type iff (arcache == 'b0110  && ardomain inside {'b00, 'b11} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) ==SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohMakeInvalid.wtralloc
                cx_noncoh_wtralloc_mkinvld        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b0110  && ardomain inside {'b00, 'b11} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.NonCohCleanSharedPersist.wtralloc
                cx_noncoh_wtralloc_clnshrdpersist        : cross cp_araddr_type_align, cp_ardomain,cp_tgt_type iff (arcache == 'b0110  && ardomain inside {'b00, 'b11} && arsnoop == 'b1010  && ((arlen+1) *( 2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                        }
                 //AXI_ACE_Update_v3.0 RdonceCleanInvalid and RdonceMakeinvalid supported for the Inner or Outer Shareable domain       
                <%}%>
                //#Cover.IOAIU.NonCohNormalTxns.nr_wtwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wtwalloc_narrow_txn       : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_tgt_type iff(arcache=='b1010 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_wtwalloc_nr     : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b1010 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==0 && ardomain inside {'b00,'b11}&& arsnoop==0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations
                //#Cover.IOAIU.NonCohCleanShared.wtwalloc
                cx_noncoh_wtwalloc_clnshrd        : cross cp_araddr_type_align, cp_ardomain,cp_tgt_type iff (arcache == 'b1010  && ardomain inside {'b00, 'b11} && arsnoop == 'b1000  && ((arlen+1) *( 2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohCleanInvalid.wtwalloc
                cx_noncoh_wtwalloc_clninvld        : cross cp_araddr_type_align, cp_ardomain,cp_tgt_type iff (arcache == 'b1010  && ardomain inside {'b00, 'b11} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) ==SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohMakeInvalid.wtwalloc
                cx_noncoh_wtwalloc_mkinvld        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b1010  && ardomain inside {'b00, 'b11} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                //#Cover.IOAIU.NonCohCleanSharedPersist.wtwalloc
                cx_noncoh_wtwalloc_clnshrdpersist        : cross cp_araddr_type_align, cp_ardomain,cp_tgt_type iff (arcache == 'b1010  && ardomain inside {'b00, 'b11} && arsnoop == 'b1010  && ((arlen+1) *( 2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                        }
                 //AXI_ACE_Update_v3.0 RdonceCleanInvalid and RdonceMakeinvalid supported for the Inner or Outer Shareable domain       
                <%}%>
                //#Cover.IOAIU.NonCohNormalTxns.nr_wtrwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wtrwalloc_narrow_txn      : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_tgt_type iff(arcache=='b1110 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_wtrwalloc_nr     : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b1110 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==0 && ardomain inside {'b00,'b11}&& arsnoop==0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};   
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations
                //#Cover.IOAIU.NonCohCleanShared.wtrwalloc
                cx_noncoh_wtrwalloc_clnshrd        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b1110  && ardomain inside {'b00, 'b11} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) ==SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohCleanInvalid.wtrwalloc
                cx_noncoh_wtrwalloc_clninvld       : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b1110  && ardomain inside {'b00, 'b11} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohMakeInvalid.wtrwalloc
                cx_noncoh_wtrwalloc_mkinvld        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b1110  && ardomain inside {'b00, 'b11} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                 //AXI_ACE_Update_v3.0 RdonceCleanInvalid and RdonceMakeinvalid supported for the Inner or Outer Shareable domain       
                //#Cover.IOAIU.NonCohCleanSharedPersist.wtrwalloc
                cx_noncoh_wtrwalloc_clnshrdpersist        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b1110  && ardomain inside {'b00, 'b11} && arsnoop == 'b1010  && ((arlen+1) * (2**arsize) ==SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                        }
                <%}%>
                //#Cover.IOAIU.NonCohNormalTxns.nr_wbralloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wbralloc_narrow_txn       : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_tgt_type iff(arcache=='b0111 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_wbralloc_nr     : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b0111 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==0 && ardomain inside {'b00,'b11}&& arsnoop==0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations
                //#Cover.IOAIU.NonCohCleanShared.wbralloc
                cx_noncoh_wbralloc_clnshrd        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b0111  && ardomain inside {'b00, 'b11} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohCleanInvalid.wbralloc
                cx_noncoh_wbralloc_clninvld        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b0111  && ardomain inside {'b00, 'b11} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohMakeInvalid.wbralloc
                cx_noncoh_wbralloc_mkinvld        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b0111  && ardomain inside {'b00, 'b11} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                 //AXI_ACE_Update_v3.0 RdonceCleanInvalid and RdonceMakeinvalid supported for the Inner or Outer Shareable domain       
                //#Cover.IOAIU.NonCohCleanSharedPersist.wbralloc
                cx_noncoh_wbralloc_clnshrdpersist        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b0111  && ardomain inside {'b00, 'b11} && arsnoop == 'b1010  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                        }
                <%}%>
                //#Cover.IOAIU.NonCohNormalTxns.nr_wbwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wbwalloc_narrow_txn       : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_tgt_type iff(arcache=='b1011 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_wbwalloc_nr     : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b1011 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==0 && ardomain inside {'b00,'b11}&& arsnoop==0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations
                //#Cover.IOAIU.NonCohCleanShared.wbwalloc
                cx_noncoh_wbwalloc_clnshrd        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b1011  && ardomain inside {'b00, 'b11} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohCleanInvalid.wbwalloc
                cx_noncoh_wbwalloc_clninvld        : cross cp_araddr_type_align ,cp_ardomain,cp_tgt_type iff (arcache == 'b1011  && ardomain inside {'b00, 'b11} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohMakeInvalid.wbwalloc
                cx_noncoh_wbwalloc_mkinvld        : cross cp_araddr_type_align ,cp_ardomain,cp_tgt_type iff (arcache == 'b1011  && ardomain inside {'b00, 'b11} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                 //AXI_ACE_Update_v3.0 RdonceCleanInvalid and RdonceMakeinvalid supported for the Inner or Outer Shareable domain       
                //#Cover.IOAIU.NonCohCleanSharedPersist.wbwalloc
                cx_noncoh_wbwalloc_clnshrdpersist        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b1011  && ardomain inside {'b00, 'b11} && arsnoop == 'b1010  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                        }
                <%}%>
                //#Cover.IOAIU.NonCohNormalTxns.nr_wbrwalloc
              <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                cx_noncoh_wbrwalloc_narrow_txn      : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_tgt_type iff(arcache=='b1111 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && arlock==0) {
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
              }<%} else if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                cx_noncoh_wbrwalloc_nr     : cross cp_araddr_type_narrow,cp_rd_narrow_length,burst_type,cp_ardomain,cp_tgt_type iff(arcache=='b1111 && arlen==0 && arsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && arlock==0 && ardomain inside {'b00,'b11}&& arsnoop==0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                    ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                } <%}%>
              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") { %>
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations
                //#Cover.IOAIU.NonCohCleanShared.wbrwalloc
                cx_noncoh_wbrwalloc_clnshrd        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b1111  && ardomain inside {'b00, 'b11} && arsnoop == 'b1000  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohCleanInvalid.wbrwalloc
                cx_noncoh_wbrwalloc_clninvld        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b1111  && ardomain inside {'b00, 'b11} && arsnoop == 'b1001  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                }//#Cover.IOAIU.NonCohMakeInvalid.wbrwalloc
                cx_noncoh_wbrwalloc_mkinvld        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b1111  && ardomain inside {'b00, 'b11} && arsnoop == 'b1101  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                } <%}%>
              <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                 //AXI_ACE_Update_v3.0 RdonceCleanInvalid and RdonceMakeinvalid supported for the Inner or Outer Shareable domain       
                //#Cover.IOAIU.NonCohCleanSharedPersist.wbrwalloc
                cx_noncoh_wbrwalloc_clnshrdpersist        : cross cp_araddr_type_align , cp_ardomain,cp_tgt_type iff (arcache == 'b1111  && ardomain inside {'b00, 'b11} && arsnoop == 'b1010  && ((arlen+1) * (2**arsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_coh_domain  = binsof(cp_ardomain)intersect {1,2,3};  
                        }
                <%}%>

        endgroup // 
    covergroup <%if((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%}else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%>ace_lite_e<%}%>_rd_excl_resp_core<%=port%>;
                //#Cover.IOAIU.ExcRead.RResp
                cp_rresp: coverpoint rresp{
                    bins ok = {0} iff(arlock==1);
                    bins exok = {1} iff (arlock==1);
                }
        endgroup // 
        //#Check.IOAIU.axid_collision	Not found
        //#Stimulus.IOAIU.axid_collision
        covergroup axi_awaddr_collisions_core<%=port%>;
            awaddr_collision : coverpoint awaddr_collision {
                bins hit = {1};
            }
        endgroup // axi_xaddr_collisions
           	
        covergroup axi_araddr_collisions_core<%=port%>;
            araddr_collision : coverpoint araddr_collision {
                bins hit = {1};
            }
        endgroup // axi_xaddr_collisions
        covergroup axi_awid_collisions_core<%=port%>;
            awid_collision : coverpoint awid_collision {
                bins hit = {1};
            }
        endgroup // axi_xid_collisions
        covergroup axi_arid_collisions_core<%=port%>;
            arid_collision : coverpoint arid_collision {
                bins hit = {1};
            }
        endgroup // axi_xid_collisions

        covergroup axi_awaraddr_collisions_core<%=port%>;
            axaddr_collision : coverpoint axaddr_collision {
                bins hit = {1};
            }
        endgroup // axi
        covergroup axi_aridawid_collisions_core<%=port%>;
            axid_collision : coverpoint axid_collision {
                bins hit = {1};
            }
        endgroup // axi_aridawid_collisions

        //#Cov.IOAIU.NarrowTransfer
        covergroup ioaiu_narrow_transfer_core<%=port%>;
            coverpoint_rd_narrow_size: coverpoint arsize {
                bins arsize[] = {[0:$clog2(WXDATA/8)]} iff (arburst == AXIINCR);
            }
            coverpoint_rd_narrow_length: coverpoint arlen {
                bins arlen_0 = {0};
            }
            cross_rd_narrow_transfer: cross coverpoint_rd_narrow_size, coverpoint_rd_narrow_length;
        endgroup //ioaiu_narrow_transfer
        // DATA INTEGRITY CHECK
        covergroup axi_data_integrity_check_core<%=port%>;
            //#Stimulus.IOAIU.axaddr
            <%if(obj.wData == 256) { %>
                cp_aligned_addr_256bit: coverpoint awaddr[5]  {
                    bins value_0   = {0};
                    bins value_1   = {1};
                }
                    <%}%> 
                    <%if(obj.wData == 128) { %>
                cp_aligned_addr_128bit: coverpoint awaddr[5:4]  {
                    bins value_0   = {0};
                    bins value_1   = {1};
                    bins value_2   = {2};
                    bins value_3   = {3};
                }
                    <%}%> 
                    <%if(obj.wData == 64) { %>
                cp_aligned_addr_64bit: coverpoint awaddr[5:3]  {
                    bins value_0   = {0};
                    bins value_1   = {1};
                    bins value_2   = {2};
                    bins value_3   = {3};
                    bins value_4   = {4};
                    bins value_5   = {5};
                    bins value_6   = {6};
                    bins value_7   = {7};
                }
            <%}%> 
            //#Stimulus.IOAIU.axlen
            cp_burst_length_allowed: coverpoint awlen {
                    bins len_2  = {1};
                    bins len_4  = {3};
                    bins len_8  = {7};
                    bins len_16 = {15};
            }
            //#Stimulus.IOAIU.axburst
            cp_burst_type_allowed: coverpoint awburst{
                    //bins incr  = {1};
                    bins wrap  = {2};
            }
            
            <%if(obj.wData == 256) { %>
                cross_aligned_addr256bit_x_burst_length_x_burst_type:   cross cp_aligned_addr_256bit, cp_burst_length_allowed, cp_burst_type_allowed  {
                    ignore_bins ignored_burst_length  = binsof(cp_aligned_addr_256bit) && binsof(cp_burst_length_allowed) intersect {3,7,15};
                }
            <%}%>  
            <%if(obj.wData == 128) { %>
                cross_aligned_addr128bit_x_burst_length_x_burst_type:   cross cp_aligned_addr_128bit, cp_burst_length_allowed, cp_burst_type_allowed  {
                    ignore_bins ignored_burst_length  = binsof(cp_aligned_addr_128bit) && binsof(cp_burst_length_allowed) intersect {1,7,15};
                }  
            <%}%> 
            <%if(obj.wData == 64) { %>
                cross_aligned_addr64bit_x_burst_length_x_burst_type:   cross cp_aligned_addr_64bit, cp_burst_length_allowed, cp_burst_type_allowed  {
                    ignore_bins ignored_burst_length  = binsof(cp_aligned_addr_64bit) && binsof(cp_burst_length_allowed) intersect {1,3};
                } 
            <%}%>
        endgroup

        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
            //ACE
            //READ CHANNELS
            covergroup ace_rd_addr_chnl_signals_core<%=port%>;
                //#Cov.IOAIU.ardomain
                cp_ardomain: coverpoint ardomain {
                    bins non_shareable = {0};
                    bins inner_shareable = {1};
                    bins outer_shareable = {2};
                    bins system_shareable = {3};
                }
                //#Cov.IOAIU.arsnoop //covered in ace_rd_addr_chnl_core
                //#Cov.IOAIU.arcache
                cp_arcache: coverpoint arcache {
                }
                //#Cov.IOAIU.arprot
                cp_arprot: coverpoint arprot {
                }
                //#Cov.IOAIU.arqos
                //#Stimulus.IOAIU.Qos
                <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>
                cp_arqos: coverpoint arqos {
                }
                <%}%>  
                //#Cov.IOAIU.arlock_normal
                cp_arlock_normal: coverpoint arlock {
                    bins NORMAL = {0};
                }
                //#Cov.IOAIU.arlock_exclusive
                cp_arlock_exclusive: coverpoint arlock {
                    bins EXCLUSIVE = {1};
                }
                //#Cov.IOAIU.arlen_allowed
                cp_arlen_allowed: coverpoint arlen{
                    bins len_1  = {0};
                    bins len_2  = {1};
                    bins len_4  = {3};
                    bins len_8  = {7};
                    bins len_16 = {15};
                }
                //#Cov.IOAIU.arburst_allowed
                cp_arburst_allowed: coverpoint arburst{
                    bins incr  = {1};
                    bins wrap  = {2};
                }
                //#Cov.IOAIU.arcache_modifiable
                cp_arcache_modifiable: coverpoint arcache[1]{
                    bins modifiable = {1};
                }

                 //#Cov.IOAIU.READNOSNOOP
                cp_READNOSNOOP: coverpoint { ardomain,arsnoop} {
                    bins READNOSNOOP       = {6'b000000,6'b110000};
                }
                //#Cov.IOAIU.READONCE
                cp_READONCE: coverpoint { ardomain,arsnoop} {
                    bins READONCE          = {6'b010000,6'b100000};
                }
                //#Cov.IOAIU.READSHARED
                cp_READSHARED: coverpoint { ardomain,arsnoop} {
                    bins READSHARED        = {6'b010001,6'b100001};
                }
                //#Cov.IOAIU.READCLEAN
                cp_READCLEAN: coverpoint { ardomain,arsnoop} {
                    bins READCLEAN         = {6'b010010,6'b100010};
                }
                //#Cov.IOAIU.READNOTSHAREDIRTY
                cp_READNOTSHAREDIRTY: coverpoint { ardomain,arsnoop} {
                    bins READNOTSHAREDIRTY = {6'b010011,6'b100011};
                }
                //#Cov.IOAIU.READUNIQUE
                cp_READUNIQUE: coverpoint { ardomain,arsnoop} {
                    bins READUNIQUE        = {6'b010111,6'b100111};
                }
                //#Cov.IOAIU.CLEANUNIQUE
                cp_CLEANUNIQUE: coverpoint { ardomain,arsnoop} {
                    bins CLEANUNIQUE       = {6'b011011,6'b101011};
                }
                //#Cov.IOAIU.MAKEUNIQUE
                cp_MAKEUNIQUE: coverpoint { ardomain,arsnoop} {
                    bins MAKEUNIQUE        = {6'b011100,6'b101100};
                }
                //#Cov.IOAIU.CLEANSHARED
                cp_CLEANSHARED: coverpoint { ardomain,arsnoop} {
                    bins CLEANSHARED       = {6'b001000,6'b011000,6'b101000};
                }
                //#Cov.IOAIU.CLEANINVALID
                cp_CLEANINVALID: coverpoint { ardomain,arsnoop} {
                    bins CLEANINVALID      = {6'b001001,6'b011001,6'b101001};
                }
                //#Cov.IOAIU.MAKEINVALID
                cp_MAKEINVALID: coverpoint { ardomain,arsnoop} {
                    bins MAKEINVALID       = {6'b001101,6'b011101,6'b101101};
                }
                //#Cov.IOAIU.BARRIER - not supported
                //#Cov.IOAIU.DVMCOMPLETE
                cp_DVMCOMPLETE: coverpoint { ardomain,arsnoop} {
                    bins DVMCOMPLETE       = {6'b011110,6'b101110};
                }
                //#Cov.IOAIU.DVMMESSAGE
                cp_DVMMESSAGE: coverpoint { ardomain,arsnoop} {
                    bins DVMMESSAGE        = {6'b011111,6'b101111};
                }
                
                cp_dvm_completion: coverpoint araddr[15] {
                    bins not_required                     = {0};
                    bins required                         = {1};
                }
                cp_dvm_messege_type: coverpoint araddr[14:12] {
                    bins tlb_invld                        = {0};
                    bins branch_pred_invld                = {1};
                    bins physical_inst_cache_invld        = {2};
                    bins virtual_inst_cache_invld         = {3};
                    bins synchronization                  = {4};
                    bins reserved_0                       = {5};
                    bins hint                             = {6};
                    bins reserved_1                       = {7};
                }
                cp_dvm_exception_level: coverpoint araddr[11:10] {
                    bins hypervisor_and_all_guest_os      = {0};
                    bins el3                              = {1};
                    bins guest_os                         = {2};
                    bins hypervisor                       = {3};
                }
                cp_dvm_security: coverpoint araddr[9:8] {
                    bins secure_and_nonsecure             = {0};
                    bins nonsecure_addr_secure_context    = {1};
                    bins secure_only                      = {2};
                    bins nonsecure_only                   = {3};
                }
                cp_dvm_SBZ_range: coverpoint araddr[7] {
                    bins not_include_addr_range_info      = {0};
                    bins include_addr_range_info          = {1};
                }
                cp_dvm_vmid_valid: coverpoint araddr[6] {
                    bins not_include_addr_range_info      = {0};
                    bins include_addr_range_info          = {1};
                }
                cp_dvm_asid_valid: coverpoint araddr[5] {
                    bins not_include_addr_range_info      = {0};
                    bins include_addr_range_info          = {1};
                }
                cp_dvm_leaf: coverpoint araddr[4] {
                    bins not_include_addr_range_info      = {0};
                    bins include_addr_range_info          = {1};
                }
                cp_dvm_stage: coverpoint araddr[3:2] {
                    bins stage1_and_stage2_invld          = {0};
                    bins stage1_only_invld                = {1};
                    bins stage2_only_invld                = {2};
                    bins reserved                         = {3};
                }
                cp_dvm_addr: coverpoint araddr[1] {
                    bins one_part                         = {0};
                    bins two_part                         = {1};
                }

                //cp_dvm_secure_tlb_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                //    bins completion_not_required          = {11'b00010100000};
                //    bins completion_required              = {11'b00010100001};
                //}
                //cp_dvm_secure_tlb_invld_va: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                //    bins completion_not_required          = {11'b00010100010};
                //    bins completion_required              = {11'b00010100011};
                //}
                //cp_dvm_secure_tlb_invld_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                //    bins completion_not_required          = {11'b00010100100};
                //    bins completion_required              = {11'b00010100101};
                //}
                //cp_dvm_secure_tlb_invld_va_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                //    bins completion_not_required          = {11'b00010100110};
                //    bins completion_required              = {11'b00010100111};
                //}
                //cp_dvm_all_os_tlb_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                //    bins completion_not_required          = {11'b00010100000};
                //    bins completion_required              = {11'b00010100001};
                //}
                //cp_dvm_guest_os_tlb_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                //    bins completion_not_required          = {11'b00010111000};
                //    bins completion_required              = {11'b00010111001};
                //}
                //cp_dvm_guest_os_tlb_invld_va: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                //    bins completion_not_required          = {11'b00010111010};
                //    bins completion_required              = {11'b00010111011};
                //}
                //cp_dvm_guest_os_tlb_invld_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                //    bins completion_not_required          = {11'b00010111100};
                //    bins completion_required              = {11'b00010111101};
                //}
                //cp_dvm_guest_os_tlb_invld_va_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                //    bins completion_not_required          = {11'b00010111110};
                //    bins completion_required              = {11'b00010111111};
                //}
                //cp_dvm_hvisor_tlb_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                //    bins completion_not_required          = {11'b00011110000};
                //    bins completion_required              = {11'b00011110001};
                //}
                //cp_dvm_hvisor_tlb_invld_va: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                //    bins completion_not_required          = {11'b00011110010};
                //    bins completion_required              = {11'b00011110011};
                //}
                //cp_dvm_branch_predictor_tlb_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                //    bins invld_all          = {10'b00100000000};
                //}
                //cp_dvm_branch_predictor_tlb_invld_va: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                //    bins invld_va          = {10'b00100000001};
                //}
                //cp_dvm_hvisor_all_guest_os_secure_nonsecure_vic_invld: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {10'b0110000001};
                //}
                //cp_dvm_hvisor_all_guest_os_nonsecure_vic_invld: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {10'b0110011001};
                //}
                //cp_dvm_guest_os_secure_invld_va_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {10'b0111010011};
                //}
                //cp_dvm_guest_os_nonsecure_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {10'b0111011100};
                //}
                //cp_dvm_guest_os_nonsecure_invld_va_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {10'b0111011111};
                //}
                //cp_dvm_hvisor_invld_va: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {10'b0111111001};
                //}
                //cp_dvm_secure_pic_invld_all: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {8'b01010000};
                //}
                //cp_dvm_secure_pic_invld_all_: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {8'b01010001};
                //}
                //cp_dvm_nonsecure_pic_invld_pa_w_o_vi: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {8'b01010111};
                //}
                //cp_dvm_nonsecure_pic_invld_pa_w_vi: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {8'b01011000};
                //}
                //cp_dvm_nonsecure_pic_invld_all: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {8'b01011001};
                //}
                //cp_dvm_nonsecure_pic_invld_pa_w_o_vi_: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                //    bins invld          = {8'b01011111};
                //}

                //#Cov.IOAIU.arcache_x_ardoamin //covered in ace_rd_addr_chnl_core

                // len
                //#Cov.IOAIU.arlen_allowed_x_ace_reads
                cp_arlen_allowed_x_READCLEAN:              cross cp_arlen_allowed , cp_READCLEAN{
                ignore_bins illegal_arlen_allowed_x_cacheline = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};
                }
                cp_arlen_allowed_x_READNOTSHAREDIRTY:      cross cp_arlen_allowed , cp_READNOTSHAREDIRTY{
                ignore_bins illegal_arlen_allowed_x_cacheline = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};
                }
                cp_arlen_allowed_x_READSHARED:             cross cp_arlen_allowed , cp_READSHARED{
                ignore_bins illegal_arlen_allowed_x_cacheline = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};
                }
                cp_arlen_allowed_x_READUNIQUE:             cross cp_arlen_allowed , cp_READUNIQUE{
                ignore_bins illegal_arlen_allowed_x_cacheline = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};
                }
                cp_arlen_allowed_x_CLEANUNIQUE:            cross cp_arlen_allowed , cp_CLEANUNIQUE{
                ignore_bins illegal_arlen_allowed_x_cacheline = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};
                }
                cp_arlen_allowed_x_MAKEUNIQUE:             cross cp_arlen_allowed , cp_MAKEUNIQUE{
                ignore_bins illegal_arlen_allowed_x_cacheline = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};
                }
                cp_arlen_allowed_x_CLEANSHARED:            cross cp_arlen_allowed , cp_CLEANSHARED{
                ignore_bins illegal_arlen_allowed_x_cacheline = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};
                }
                cp_arlen_allowed_x_CLEANINVALID:           cross cp_arlen_allowed , cp_CLEANINVALID{
                ignore_bins illegal_arlen_allowed_x_cacheline = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};
                }
                cp_arlen_allowed_x_MAKEINVALID:            cross cp_arlen_allowed , cp_MAKEINVALID{
                ignore_bins illegal_arlen_allowed_x_cacheline = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};
                }

                //#Cov.IOAIU.arburst_allowed_x_ace_reads
                cp_arburst_allowed_x_READCLEAN:            cross cp_arburst_allowed , cp_READCLEAN;
                cp_arburst_allowed_x_READNOTSHAREDIRTY:    cross cp_arburst_allowed , cp_READNOTSHAREDIRTY;
                cp_arburst_allowed_x_READSHARED:           cross cp_arburst_allowed , cp_READSHARED;
                cp_arburst_allowed_x_READUNIQUE:           cross cp_arburst_allowed , cp_READUNIQUE;
                cp_arburst_allowed_x_CLEANUNIQUE:          cross cp_arburst_allowed , cp_CLEANUNIQUE;
                cp_arburst_allowed_x_MAKEUNIQUE:           cross cp_arburst_allowed , cp_MAKEUNIQUE;
                cp_arburst_allowed_x_CLEANSHARED:          cross cp_arburst_allowed , cp_CLEANSHARED;
                cp_arburst_allowed_x_CLEANINVALID:         cross cp_arburst_allowed , cp_CLEANINVALID;
                cp_arburst_allowed_x_MAKEINVALID:          cross cp_arburst_allowed , cp_MAKEINVALID;
                cp_arburst_allowed_x_READONCE:             cross cp_arburst_allowed , cp_READONCE;

                // cache_modifiable
                //#Cov.IOAIU.arcache_modifiable_x_ace_reads
                cp_arcache_modifiable_x_READCLEAN:         cross cp_arcache_modifiable , cp_READCLEAN;
                cp_arcache_modifiable_x_READNOTSHAREDIRTY: cross cp_arcache_modifiable , cp_READNOTSHAREDIRTY;
                cp_arcache_modifiable_x_READSHARED:        cross cp_arcache_modifiable , cp_READSHARED;
                cp_arcache_modifiable_x_READUNIQUE:        cross cp_arcache_modifiable , cp_READUNIQUE;
                cp_arcache_modifiable_x_CLEANUNIQUE:       cross cp_arcache_modifiable , cp_CLEANUNIQUE;
                cp_arcache_modifiable_x_MAKEUNIQUE:        cross cp_arcache_modifiable , cp_MAKEUNIQUE;
                cp_arcache_modifiable_x_CLEANSHARED:       cross cp_arcache_modifiable , cp_CLEANSHARED;
                cp_arcache_modifiable_x_CLEANINVALID:      cross cp_arcache_modifiable , cp_CLEANINVALID;
                cp_arcache_modifiable_x_MAKEINVALID:       cross cp_arcache_modifiable , cp_MAKEINVALID;
                cp_arcache_modifiable_x_READONCE:          cross cp_arcache_modifiable , cp_READONCE;

                //#Cov.IOAIU.arlock_normal_x_ace_reads
                cp_arlock_normal_x_READCLEAN:              cross cp_arlock_normal , cp_READCLEAN;
                cp_arlock_normal_x_READNOTSHAREDIRTY:      cross cp_arlock_normal , cp_READNOTSHAREDIRTY;
                cp_arlock_normal_x_READSHARED:             cross cp_arlock_normal , cp_READSHARED;
                cp_arlock_normal_x_READUNIQUE:             cross cp_arlock_normal , cp_READUNIQUE;
                cp_arlock_normal_x_CLEANUNIQUE:            cross cp_arlock_normal , cp_CLEANUNIQUE;
                cp_arlock_normal_x_MAKEUNIQUE:             cross cp_arlock_normal , cp_MAKEUNIQUE;
                cp_arlock_normal_x_CLEANSHARED:            cross cp_arlock_normal , cp_CLEANSHARED;
                cp_arlock_normal_x_CLEANINVALID:           cross cp_arlock_normal , cp_CLEANINVALID;
                cp_arlock_normal_x_MAKEINVALID:            cross cp_arlock_normal , cp_MAKEINVALID;
                cp_arlock_normal_x_READONCE:               cross cp_arlock_normal , cp_READONCE;

                //#Cov.IOAIU.arlock_exclusive_x_ace_reads
                cp_arlock_exclusive_x_READCLEAN:           cross cp_arlock_exclusive , cp_READCLEAN;
                cp_arlock_exclusive_x_READSHARED:          cross cp_arlock_exclusive , cp_READSHARED;
                cp_arlock_exclusive_x_CLEANUNIQUE:         cross cp_arlock_exclusive , cp_CLEANUNIQUE;

                //#Cov.IOAIU.arprot_x_ace_reads
                cp_arprot_x_READCLEAN:                     cross cp_arprot , cp_READCLEAN;
                cp_arprot_x_READNOTSHAREDIRTY:             cross cp_arprot , cp_READNOTSHAREDIRTY;
                cp_arprot_x_READSHARED:                    cross cp_arprot , cp_READSHARED;
                cp_arprot_x_READUNIQUE:                    cross cp_arprot , cp_READUNIQUE;
                cp_arprot_x_CLEANUNIQUE:                   cross cp_arprot , cp_CLEANUNIQUE;
                cp_arprot_x_MAKEUNIQUE:                    cross cp_arprot , cp_MAKEUNIQUE;
                cp_arprot_x_CLEANSHARED:                   cross cp_arprot , cp_CLEANSHARED;
                cp_arprot_x_CLEANINVALID:                  cross cp_arprot , cp_CLEANINVALID;
                cp_arprot_x_MAKEINVALID:                   cross cp_arprot , cp_MAKEINVALID;
                cp_arprot_x_READONCE:                      cross cp_arprot , cp_READONCE;

                //#Cov.IOAIU.arqos_x_ace_reads
                <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>
                cp_arqos_x_READCLEAN:                      cross cp_arqos , cp_READCLEAN;
                cp_arqos_x_READNOTSHAREDIRTY:              cross cp_arqos , cp_READNOTSHAREDIRTY;
                cp_arqos_x_READSHARED:                     cross cp_arqos , cp_READSHARED;
                cp_arqos_x_READUNIQUE:                     cross cp_arqos , cp_READUNIQUE;
                cp_arqos_x_CLEANUNIQUE:                    cross cp_arqos , cp_CLEANUNIQUE;
                cp_arqos_x_MAKEUNIQUE:                     cross cp_arqos , cp_MAKEUNIQUE;
                cp_arqos_x_CLEANSHARED:                    cross cp_arqos , cp_CLEANSHARED;
                cp_arqos_x_CLEANINVALID:                   cross cp_arqos , cp_CLEANINVALID;
                cp_arqos_x_MAKEINVALID:                    cross cp_arqos , cp_MAKEINVALID;
                cp_arqos_x_READONCE:                       cross cp_arqos , cp_READONCE;
                <%}%>  

                cp_DVMCOMPLETE_x_dvm_completion                                    : cross cp_DVMCOMPLETE , cp_dvm_completion;
                cp_DVMCOMPLETE_x_dvm_messege_type                                  : cross cp_DVMCOMPLETE , cp_dvm_messege_type;
                cp_DVMCOMPLETE_x_dvm_exception_level                               : cross cp_DVMCOMPLETE , cp_dvm_exception_level;
                cp_DVMCOMPLETE_x_dvm_security                                      : cross cp_DVMCOMPLETE , cp_dvm_security;
                cp_DVMCOMPLETE_x_dvm_SBZ_range                                     : cross cp_DVMCOMPLETE , cp_dvm_SBZ_range;
                cp_DVMCOMPLETE_x_dvm_vmid_valid                                    : cross cp_DVMCOMPLETE , cp_dvm_vmid_valid;
                cp_DVMCOMPLETE_x_dvm_asid_valid                                    : cross cp_DVMCOMPLETE , cp_dvm_asid_valid;
                cp_DVMCOMPLETE_x_dvm_leaf                                          : cross cp_DVMCOMPLETE , cp_dvm_leaf;
                cp_DVMCOMPLETE_x_dvm_stage                                         : cross cp_DVMCOMPLETE , cp_dvm_stage;
                cp_DVMCOMPLETE_x_dvm_addr                                          : cross cp_DVMCOMPLETE , cp_dvm_addr;

                //cp_DVMCOMPLETE_x_dvm_secure_tlb_invld_all                          : cross cp_DVMCOMPLETE , cp_dvm_secure_tlb_invld_all;
                //cp_DVMCOMPLETE_x_dvm_secure_tlb_invld_va                           : cross cp_DVMCOMPLETE , cp_dvm_secure_tlb_invld_va;
                //cp_DVMCOMPLETE_x_dvm_secure_tlb_invld_asid                         : cross cp_DVMCOMPLETE , cp_dvm_secure_tlb_invld_asid;
                //cp_DVMCOMPLETE_x_dvm_secure_tlb_invld_va_asid                      : cross cp_DVMCOMPLETE , cp_dvm_secure_tlb_invld_va_asid;
                //cp_DVMCOMPLETE_x_dvm_all_os_tlb_invld_all                          : cross cp_DVMCOMPLETE , cp_dvm_all_os_tlb_invld_all;
                //cp_DVMCOMPLETE_x_dvm_guest_os_tlb_invld_all                        : cross cp_DVMCOMPLETE , cp_dvm_guest_os_tlb_invld_all;
                //cp_DVMCOMPLETE_x_dvm_guest_os_tlb_invld_va                         : cross cp_DVMCOMPLETE , cp_dvm_guest_os_tlb_invld_va;
                //cp_DVMCOMPLETE_x_dvm_guest_os_tlb_invld_asid                       : cross cp_DVMCOMPLETE , cp_dvm_guest_os_tlb_invld_asid;
                //cp_DVMCOMPLETE_x_dvm_guest_os_tlb_invld_va_asid                    : cross cp_DVMCOMPLETE , cp_dvm_guest_os_tlb_invld_va_asid;
                //cp_DVMCOMPLETE_x_dvm_hvisor_tlb_invld_all                          : cross cp_DVMCOMPLETE , cp_dvm_hvisor_tlb_invld_all;
                //cp_DVMCOMPLETE_x_dvm_hvisor_tlb_invld_va                           : cross cp_DVMCOMPLETE , cp_dvm_hvisor_tlb_invld_va;
                //cp_DVMCOMPLETE_x_dvm_branch_predictor_tlb_invld_all                : cross cp_DVMCOMPLETE , cp_dvm_branch_predictor_tlb_invld_all;
                //cp_DVMCOMPLETE_x_dvm_branch_predictor_tlb_invld_va                 : cross cp_DVMCOMPLETE , cp_dvm_branch_predictor_tlb_invld_va;
                //cp_DVMCOMPLETE_x_dvm_hvisor_all_guest_os_secure_nonsecure_vic_invld: cross cp_DVMCOMPLETE , cp_dvm_hvisor_all_guest_os_secure_nonsecure_vic_invld;
                //cp_DVMCOMPLETE_x_dvm_hvisor_all_guest_os_nonsecure_vic_invld       : cross cp_DVMCOMPLETE , cp_dvm_hvisor_all_guest_os_nonsecure_vic_invld;
                //cp_DVMCOMPLETE_x_dvm_guest_os_secure_invld_va_asid                 : cross cp_DVMCOMPLETE , cp_dvm_guest_os_secure_invld_va_asid;
                //cp_DVMCOMPLETE_x_dvm_guest_os_nonsecure_invld_all                  : cross cp_DVMCOMPLETE , cp_dvm_guest_os_nonsecure_invld_all;
                //cp_DVMCOMPLETE_x_dvm_guest_os_nonsecure_invld_va_asid              : cross cp_DVMCOMPLETE , cp_dvm_guest_os_nonsecure_invld_va_asid;
                //cp_DVMCOMPLETE_x_dvm_hvisor_invld_va                               : cross cp_DVMCOMPLETE , cp_dvm_hvisor_invld_va;
                //cp_DVMCOMPLETE_x_dvm_secure_pic_invld_all                          : cross cp_DVMCOMPLETE , cp_dvm_secure_pic_invld_all;
                //cp_DVMCOMPLETE_x_dvm_secure_pic_invld_all_                         : cross cp_DVMCOMPLETE , cp_dvm_secure_pic_invld_all_;
                //cp_DVMCOMPLETE_x_dvm_nonsecure_pic_invld_pa_w_o_vi                 : cross cp_DVMCOMPLETE , cp_dvm_nonsecure_pic_invld_pa_w_o_vi;
                //cp_DVMCOMPLETE_x_dvm_nonsecure_pic_invld_pa_w_vi                   : cross cp_DVMCOMPLETE , cp_dvm_nonsecure_pic_invld_pa_w_vi;
                //cp_DVMCOMPLETE_x_dvm_nonsecure_pic_invld_all                       : cross cp_DVMCOMPLETE , cp_dvm_nonsecure_pic_invld_all;
                //cp_DVMCOMPLETE_x_dvm_nonsecure_pic_invld_pa_w_o_vi_                : cross cp_DVMCOMPLETE , cp_dvm_nonsecure_pic_invld_pa_w_o_vi_;

                cp_DVMMESSEGE_x_dvm_completion                                    : cross cp_DVMMESSAGE , cp_dvm_completion;
                cp_DVMMESSEGE_x_dvm_messege_type                                  : cross cp_DVMMESSAGE , cp_dvm_messege_type;
                cp_DVMMESSEGE_x_dvm_exception_level                               : cross cp_DVMMESSAGE , cp_dvm_exception_level;
                cp_DVMMESSEGE_x_dvm_security                                      : cross cp_DVMMESSAGE , cp_dvm_security;
                cp_DVMMESSEGE_x_dvm_SBZ_range                                     : cross cp_DVMMESSAGE , cp_dvm_SBZ_range;
                cp_DVMMESSEGE_x_dvm_vmid_valid                                    : cross cp_DVMMESSAGE , cp_dvm_vmid_valid;
                cp_DVMMESSEGE_x_dvm_asid_valid                                    : cross cp_DVMMESSAGE , cp_dvm_asid_valid;
                cp_DVMMESSEGE_x_dvm_leaf                                          : cross cp_DVMMESSAGE , cp_dvm_leaf;
                cp_DVMMESSEGE_x_dvm_stage                                         : cross cp_DVMMESSAGE , cp_dvm_stage;
                cp_DVMMESSEGE_x_dvm_addr                                          : cross cp_DVMMESSAGE , cp_dvm_addr;

                //cp_DVMMESSEGE_x_dvm_secure_tlb_invld_all                          : cross cp_DVMMESSAGE , cp_dvm_secure_tlb_invld_all;
                //cp_DVMMESSEGE_x_dvm_secure_tlb_invld_va                           : cross cp_DVMMESSAGE , cp_dvm_secure_tlb_invld_va;
                //cp_DVMMESSEGE_x_dvm_secure_tlb_invld_asid                         : cross cp_DVMMESSAGE , cp_dvm_secure_tlb_invld_asid;
                //cp_DVMMESSEGE_x_dvm_secure_tlb_invld_va_asid                      : cross cp_DVMMESSAGE , cp_dvm_secure_tlb_invld_va_asid;
                //cp_DVMMESSEGE_x_dvm_all_os_tlb_invld_all                          : cross cp_DVMMESSAGE , cp_dvm_all_os_tlb_invld_all;
                //cp_DVMMESSEGE_x_dvm_guest_os_tlb_invld_all                        : cross cp_DVMMESSAGE , cp_dvm_guest_os_tlb_invld_all;
                //cp_DVMMESSEGE_x_dvm_guest_os_tlb_invld_va                         : cross cp_DVMMESSAGE , cp_dvm_guest_os_tlb_invld_va;
                //cp_DVMMESSEGE_x_dvm_guest_os_tlb_invld_asid                       : cross cp_DVMMESSAGE , cp_dvm_guest_os_tlb_invld_asid;
                //cp_DVMMESSEGE_x_dvm_guest_os_tlb_invld_va_asid                    : cross cp_DVMMESSAGE , cp_dvm_guest_os_tlb_invld_va_asid;
                //cp_DVMMESSEGE_x_dvm_hvisor_tlb_invld_all                          : cross cp_DVMMESSAGE , cp_dvm_hvisor_tlb_invld_all;
                //cp_DVMMESSEGE_x_dvm_hvisor_tlb_invld_va                           : cross cp_DVMMESSAGE , cp_dvm_hvisor_tlb_invld_va;
                //cp_DVMMESSEGE_x_dvm_branch_predictor_tlb_invld_all                : cross cp_DVMMESSAGE , cp_dvm_branch_predictor_tlb_invld_all;
                //cp_DVMMESSEGE_x_dvm_branch_predictor_tlb_invld_va                 : cross cp_DVMMESSAGE , cp_dvm_branch_predictor_tlb_invld_va;
                //cp_DVMMESSEGE_x_dvm_hvisor_all_guest_os_secure_nonsecure_vic_invld: cross cp_DVMMESSAGE , cp_dvm_hvisor_all_guest_os_secure_nonsecure_vic_invld;
                //cp_DVMMESSEGE_x_dvm_hvisor_all_guest_os_nonsecure_vic_invld       : cross cp_DVMMESSAGE , cp_dvm_hvisor_all_guest_os_nonsecure_vic_invld;
                //cp_DVMMESSEGE_x_dvm_guest_os_secure_invld_va_asid                 : cross cp_DVMMESSAGE , cp_dvm_guest_os_secure_invld_va_asid;
                //cp_DVMMESSEGE_x_dvm_guest_os_nonsecure_invld_all                  : cross cp_DVMMESSAGE , cp_dvm_guest_os_nonsecure_invld_all;
                //cp_DVMMESSEGE_x_dvm_guest_os_nonsecure_invld_va_asid              : cross cp_DVMMESSAGE , cp_dvm_guest_os_nonsecure_invld_va_asid;
                //cp_DVMMESSEGE_x_dvm_hvisor_invld_va                               : cross cp_DVMMESSAGE , cp_dvm_hvisor_invld_va;
                //cp_DVMMESSEGE_x_dvm_secure_pic_invld_all                          : cross cp_DVMMESSAGE , cp_dvm_secure_pic_invld_all;
                //cp_DVMMESSEGE_x_dvm_secure_pic_invld_all_                         : cross cp_DVMMESSAGE , cp_dvm_secure_pic_invld_all_;
                //cp_DVMMESSEGE_x_dvm_nonsecure_pic_invld_pa_w_o_vi                 : cross cp_DVMMESSAGE , cp_dvm_nonsecure_pic_invld_pa_w_o_vi;
                //cp_DVMMESSEGE_x_dvm_nonsecure_pic_invld_pa_w_vi                   : cross cp_DVMMESSAGE , cp_dvm_nonsecure_pic_invld_pa_w_vi;
                //cp_DVMMESSEGE_x_dvm_nonsecure_pic_invld_all                       : cross cp_DVMMESSAGE , cp_dvm_nonsecure_pic_invld_all;
                //cp_DVMMESSEGE_x_dvm_nonsecure_pic_invld_pa_w_o_vi_                : cross cp_DVMMESSAGE , cp_dvm_nonsecure_pic_invld_pa_w_o_vi_;
            endgroup //ace_rd_addr_chnl_signals

            covergroup ace_rd_resp_channel_core<%=port%>;
                //#Cov.IOAIU.rresp_1_0
                cp_rresp_1_0: coverpoint rresp[1:0]{
                    bins ok = {0};
                    bins exok = {1};
                    bins slverr = {2};
                    bins decerr = {3};
                }
                //#Cov.IOAIU.rresp_3_2
                cp_rresp_3_2: coverpoint rresp[3:2]{
                    bins bin_0_0 = {0};
                    bins bin_0_1 = {1};
                    bins bin_1_0 = {2};
                    bins bin_1_1 = {3};
                }
                //#Cov.IOAIU.PassDirty
                cp_PassDirty: coverpoint rresp[2]{
                    bins zero = {0};
                    bins one = {1};
                }
                //#Cov.IOAIU.IsShared
                cp_IsShared: coverpoint rresp[3]{
                    bins zero = {0};
                    bins one = {1};
                }
                //#Cov.IOAIU.READNOSNOOP
                cp_READNOSNOOP: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins READNOSNOOP       = {6'b000000,6'b110000};
                }
                //#Cov.IOAIU.READONCE
                cp_READONCE: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins READONCE          = {6'b010000,6'b100000};
                }
                //#Cov.IOAIU.READSHARED
                cp_READSHARED: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins READSHARED        = {6'b010001,6'b100001};
                }
                //#Cov.IOAIU.READCLEAN
                cp_READCLEAN: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins READCLEAN         = {6'b010010,6'b100010};
                }
                //#Cov.IOAIU.READNOTSHAREDIRTY
                cp_READNOTSHAREDIRTY: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins READNOTSHAREDIRTY = {6'b010011,6'b100011};
                }
                //#Cov.IOAIU.READUNIQUE
                cp_READUNIQUE: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins READUNIQUE        = {6'b010111,6'b100111};
                }
                //#Cov.IOAIU.CLEANUNIQUE
                cp_CLEANUNIQUE: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins CLEANUNIQUE       = {6'b011011,6'b101011};
                }
                //#Cov.IOAIU.MAKEUNIQUE
                cp_MAKEUNIQUE: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins MAKEUNIQUE        = {6'b011100,6'b101100};
                }
                //#Cov.IOAIU.CLEANSHARED
                cp_CLEANSHARED: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins CLEANSHARED       = {6'b001000,6'b011000,6'b101000};
                }
                //#Cov.IOAIU.CLEANINVALID
                cp_CLEANINVALID: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins CLEANINVALID      = {6'b001001,6'b011001,6'b101001};
                }
                //#Cov.IOAIU.MAKEINVALID
                cp_MAKEINVALID: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins MAKEINVALID       = {6'b001101,6'b011101,6'b101101};
                }
                //#Cov.IOAIU.BARRIER-not supported
                //#Cov.IOAIU.DVMCOMPLETE
                cp_DVMCOMPLETE: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins DVMCOMPLETE       = {6'b011110,6'b101110};
                }
                //#Cov.IOAIU.DVMMESSAGE
                cp_DVMMESSAGE: coverpoint { rsp_ardomain,rsp_arsnoop} {
                    bins DVMMESSAGE        = {6'b011111,6'b101111};
                }
                //#Cov.IOAIU.rresp_3_2_x_ace_reads
                cp_rresp_3_2_x_READNOSNOOP:            cross cp_rresp_3_2 , cp_READNOSNOOP{
                    ignore_bins illegal_rresp_3_2_x_READNOSNOOP_0_1        = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_READNOSNOOP_1_0        = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_READNOSNOOP_1_1        = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_READCLEAN:            cross cp_rresp_3_2 , cp_READCLEAN{
                    ignore_bins illegal_rresp_3_2_x_READCLEAN_0_1          = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_READCLEAN_1_1          = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_READNOTSHAREDIRTY:    cross cp_rresp_3_2 , cp_READNOTSHAREDIRTY{
                    ignore_bins illegal_rresp_3_2_x_READNOTSHAREDIRTY_1_1  = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_READSHARED:           cross cp_rresp_3_2 , cp_READSHARED;
                cp_rresp_3_2_x_READUNIQUE:           cross cp_rresp_3_2 , cp_READUNIQUE{
                    ignore_bins illegal_rresp_3_2_x_READUNIQUE_1_0         = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_READUNIQUE_1_1         = binsof (cp_rresp_3_2.bin_1_1);}
                //cp_rresp_3_2_x_CLEANUNIQUE:          cross cp_rresp_3_2 , cp_CLEANUNIQUE{
                //    ignore_bins illegal_rresp_3_2_x_CLEANUNIQUE_0_1        = binsof (cp_rresp_3_2.bin_0_1);
                //    ignore_bins illegal_rresp_3_2_x_CLEANUNIQUE_1_0        = binsof (cp_rresp_3_2.bin_1_0);
                //    ignore_bins illegal_rresp_3_2_x_CLEANUNIQUE_1_1        = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_MAKEUNIQUE:           cross cp_rresp_3_2 , cp_MAKEUNIQUE{
                    ignore_bins illegal_rresp_3_2_x_MAKEUNIQUE_0_1         = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_MAKEUNIQUE_1_0         = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_MAKEUNIQUE_1_1         = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_CLEANSHARED:          cross cp_rresp_3_2 , cp_CLEANSHARED{
                    ignore_bins illegal_rresp_3_2_x_CLEANSHARED_0_1        = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_CLEANSHARED_1_1        = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_CLEANINVALID:         cross cp_rresp_3_2 , cp_CLEANINVALID{
                    ignore_bins illegal_rresp_3_2_x_CLEANINVALID_0_1       = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_CLEANINVALID_1_0       = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_CLEANINVALID_1_1       = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_MAKEINVALID:          cross cp_rresp_3_2 , cp_MAKEINVALID{
                    ignore_bins illegal_rresp_3_2_x_MAKEINVALID_0_1        = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_MAKEINVALID_1_0        = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_MAKEINVALID_1_1        = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_READONCE:             cross cp_rresp_3_2 , cp_READONCE{
                    ignore_bins illegal_rresp_3_2_x_READONCE_0_1           = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_READONCE_1_1           = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_DVMCOMPLETE:          cross cp_rresp_3_2 , cp_DVMCOMPLETE{
                    ignore_bins illegal_rresp_3_2_x_DVMCOMPLETE_0_1        = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_DVMCOMPLETE_1_0        = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_DVMCOMPLETE_1_1        = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_DVMMESSAGE:           cross cp_rresp_3_2 , cp_DVMMESSAGE{
                    ignore_bins illegal_rresp_3_2_x_DVMMESSAGE_0_1         = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_DVMMESSAGE_1_0         = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_DVMMESSAGE_1_1         = binsof (cp_rresp_3_2.bin_1_1);}

                //#Cov.IOAIU.rresp_1_0_x_ace_reads -Barrier not supported

            endgroup // ace_rd_resp_channel

            covergroup ace_rd_ack_core<%=port%>;
                //#Cov.IOAIU.rack
                cp_rack: coverpoint rack{
                    bins one = {1};
                }
            endgroup // ace_rd_ack

            //WRITE CHANNELS

            covergroup ace_wr_addr_chnl_signals_core<%=port%>;
                //#Cov.IOAIU.awdomain
                //#Stimulus.IOAIU.axdomain
                cp_awdomain: coverpoint awdomain {
                    bins non_shareable = {0};
                    bins inner_shareable = {1};
                    bins outer_shareable = {2};
                    bins system_shareable = {3};
                    //type_option.weight = 0;
                }
                //#Cov.IOAIU.awsnoop //covered in ace_wr_addr_chnl_core
                //#Cov.IOAIU.awbar //not supported
                //#Cov.IOAIU.awunique
                cp_awunique: coverpoint awunique {
                    bins zero = {0};
                    bins one = {1};
                }
                //#Cov.IOAIU.awlen_allowed
                cp_awlen_allowed: coverpoint awlen{
                    bins len_1  = {0};
                    bins len_2  = {1};
                    bins len_4  = {3};
                    bins len_8  = {7};
                    bins len_16 = {15};
                }
                //#Cov.IOAIU.awcache
                //#Stimulus.IOAIU.axcache
                cp_awcache: coverpoint awcache {
                }
                //#Cov.IOAIU.awcache_modifiable
                cp_awcache_modifiable: coverpoint awcache[1]{
                    bins modifiable = {1};
                }
                //#Cov.IOAIU.awprot
                //#Stimulus.IOAIU.axprot
                cp_awprot: coverpoint awprot {
                }
                //#Cov.IOAIU.awqos
                //#Stimulus.IOAIU.axqos
                <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>
                cp_awqos: coverpoint awqos {
                }
                <% } %>
                //#Cov.IOAIU.awlock_normal
                //#Stimulus.IOAIU.axlock
                cp_awlock_normal: coverpoint awlock {
                    bins NORMAL = {0};
                }
                //#Cov.IOAIU.awlock_exclusive
                cp_awlock_exclusive: coverpoint awlock {
                    bins EXCLUSIVE = {1};
                }
                //#Cov.IOAIU.awburst_allowed
                cp_awburst_allowed: coverpoint awburst{
                    bins incr  = {1};
                    bins wrap  = {2};
                }

                //#Cov.IOAIU.WRITENOSNOOP
                cp_WRITENOSNOOP: coverpoint {awdomain,awsnoop} {
                    bins WRITENOSNOOP      = {6'b000000,6'b110000};
                }
                //#Cov.IOAIU.WRITEUNIQUE
                cp_WRITEUNIQUE: coverpoint {awdomain,awsnoop} {
                    bins WRITEUNIQUE       = {6'b010000,6'b100000};
                }
                //#Cov.IOAIU.WRITELINEUNIQUE
                cp_WRITELINEUNIQUE: coverpoint {awdomain,awsnoop} {
                    bins WRITELINEUNIQUE   = {6'b010001,6'b100001};
                }
                //#Cov.IOAIU.WRITECLEAN
                cp_WRITECLEAN: coverpoint {awdomain,awsnoop} {
                    bins WRITECLEAN        = {6'b000010,6'b010010,6'b100010};
                }
                //#Cov.IOAIU.WRITEBACK
                cp_WRITEBACK: coverpoint {awdomain,awsnoop} {
                    bins WRITEBACK         = {6'b000011,6'b010011,6'b100011};
                }
                //#Cov.IOAIU.EVICT
                cp_EVICT: coverpoint {awdomain,awsnoop} {
                    bins EVICT             = {6'b000100,6'b010100,6'b100100};
                }
                //#Cov.IOAIU.WRITEEVICT
                cp_WRITEEVICT: coverpoint {awdomain,awsnoop} {
                    bins WRITEEVICT        = {6'b000101,6'b010101,6'b100101};
                }
                //#Cov.IOAIU.BARRIER -not supported 

                //#Cov.IOAIU.awcache_x_awdoamin -covered in ace_rd_addr_chnl_core

                //#Cov.IOAIU.awunique_x_writes
                cp_awunique_x_WRITENOSNOOP:                cross cp_awunique , cp_WRITENOSNOOP;
                cp_awunique_x_WRITEUNIQUE:                 cross cp_awunique , cp_WRITEUNIQUE;
                cp_awunique_x_WRITELINEUNIQUE:             cross cp_awunique , cp_WRITELINEUNIQUE;
                cp_awunique_x_WRITEEVICT:                  cross cp_awunique , cp_WRITEEVICT{
                    ignore_bins illegal_awunique_x_WRITECLEAN_0           = binsof (cp_awunique.zero);}
                cp_awunique_x_EVICT:                       cross cp_awunique , cp_EVICT;
                cp_awunique_x_WRITEBACK:                   cross cp_awunique , cp_WRITEBACK;
                cp_awunique_x_WRITECLEAN:                  cross cp_awunique , cp_WRITECLEAN{
                    ignore_bins illegal_awunique_x_WRITECLEAN_1           = binsof (cp_awunique.one);}

                //#Cov.IOAIU.awlen_allowed_x_writes
                cp_awlen_allowed_x_WRITELINEUNIQUE:        cross cp_awlen_allowed , cp_WRITELINEUNIQUE;
                cp_awlen_allowed_x_WRITEEVICT:             cross cp_awlen_allowed , cp_WRITEEVICT;
                cp_awlen_allowed_x_EVICT:                  cross cp_awlen_allowed , cp_EVICT;

                //#Cov.IOAIU.awburst_allowed_x_writes
                cp_awburst_allowed_x_WRITELINEUNIQUE:      cross cp_awburst_allowed , cp_WRITELINEUNIQUE;
                cp_awburst_allowed_x_WRITEEVICT:           cross cp_awburst_allowed , cp_WRITEEVICT;
                cp_awburst_allowed_x_EVICT:                cross cp_awburst_allowed , cp_EVICT;
                cp_awburst_allowed_x_WRITEUNIQUE:          cross cp_awburst_allowed , cp_WRITEUNIQUE;

                //#Cov.IOAIU.awcache_modifiable_x_writes
                cp_awcache_modifiable_x_WRITELINEUNIQUE:   cross cp_awcache_modifiable , cp_WRITELINEUNIQUE;
                cp_awcache_modifiable_x_WRITEEVICT:        cross cp_awcache_modifiable , cp_WRITEEVICT;
                cp_awcache_modifiable_x_EVICT:             cross cp_awcache_modifiable , cp_EVICT;
                cp_awcache_modifiable_x_WRITEUNIQUE:       cross cp_awcache_modifiable , cp_WRITEUNIQUE;

                //#Cov.IOAIU.awlock_normal_x_writes
                cp_awlock_normal_x_WRITELINEUNIQUE:        cross cp_awlock_normal , cp_WRITELINEUNIQUE;
                cp_awlock_normal_x_WRITEEVICT:             cross cp_awlock_normal , cp_WRITEEVICT;
                cp_awlock_normal_x_EVICT:                  cross cp_awlock_normal , cp_EVICT;
                cp_awlock_normal_x_WRITEUNIQUE:            cross cp_awlock_normal , cp_WRITEUNIQUE;

                //#Cov.IOAIU.awprot_x_writes
                cp_awprot_x_WRITELINEUNIQUE:               cross cp_awprot , cp_WRITELINEUNIQUE;
                cp_awprot_x_WRITEEVICT:                    cross cp_awprot , cp_WRITEEVICT;
                cp_awprot_x_EVICT:                         cross cp_awprot , cp_EVICT;
                cp_awprot_x_WRITEUNIQUE:                   cross cp_awprot , cp_WRITEUNIQUE;

                //#Cov.IOAIU.awqos_x_writes
                <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>
                cp_awqos_x_WRITELINEUNIQUE:                cross cp_awqos , cp_WRITELINEUNIQUE;
                cp_awqos_x_WRITEEVICT:                     cross cp_awqos , cp_WRITEEVICT;
                cp_awqos_x_EVICT:                          cross cp_awqos , cp_EVICT;
                cp_awqos_x_WRITEUNIQUE:                    cross cp_awqos , cp_WRITEUNIQUE;
                <% } %>

            endgroup //ace_wr_addr_chnl_signals

            covergroup ace_wr_resp_channel_core<%=port%>;
                //#Cov.IOAIU.bresp
                cp_bresp: coverpoint bresp{
                    bins ok = {0};
                    bins exok = {1};
                    bins slverr = {2};
                    bins decerr = {3};
                    //ace-5//bresp 3-bit wide//
                    //bins transfault = {5};//TODO
                }
                //#Cov.IOAIU.WRITENOSNOOP
                cp_WRITENOSNOOP: coverpoint {rsp_awdomain,rsp_awsnoop} {
                    bins WRITENOSNOOP      = {6'b000000,6'b110000};
                }
                //#Cov.IOAIU.WRITEUNIQUE
                cp_WRITEUNIQUE: coverpoint {rsp_awdomain,rsp_awsnoop} {
                    bins WRITEUNIQUE       = {6'b010000,6'b100000};
                }
                //#Cov.IOAIU.WRITELINEUNIQUE
                cp_WRITELINEUNIQUE: coverpoint {rsp_awdomain,rsp_awsnoop} {
                    bins WRITELINEUNIQUE   = {6'b010001,6'b100001};
                }
                //#Cov.IOAIU.WRITECLEAN
                cp_WRITECLEAN: coverpoint {rsp_awdomain,rsp_awsnoop} {
                    bins WRITECLEAN        = {6'b000010,6'b010010,6'b100010};
                }
                //#Cov.IOAIU.WRITEBACK
                cp_WRITEBACK: coverpoint {rsp_awdomain,rsp_awsnoop} {
                    bins WRITEBACK         = {6'b000011,6'b010011,6'b100011};
                }
                //#Cov.IOAIU.EVICT
                cp_EVICT: coverpoint {rsp_awdomain,rsp_awsnoop} {
                    bins EVICT             = {6'b000100,6'b010100,6'b100100};
                }
                //#Cov.IOAIU.WRITEEVICT
                cp_WRITEEVICT: coverpoint {rsp_awdomain,rsp_awsnoop} {
                    bins WRITEEVICT        = {6'b000101,6'b010101,6'b100101};
                }
                //#Cov.IOAIU.BARRIER -not supported

                //#Cov.IOAIU.bresp_x_ace_writes
                //EVICT bresp = 00 // no limitation for other writes

                cp_bresp_x_EVICT:                       cross cp_bresp , cp_EVICT{
                    ignore_bins illegal_bresp_x_EVICT_0_1                  = binsof (cp_bresp.exok);
                    ignore_bins illegal_bresp_x_EVICT_1_0                  = binsof (cp_bresp.slverr);
                    ignore_bins illegal_bresp_x_EVICT_1_1                  = binsof (cp_bresp.decerr);}

                cp_bresp_x_WRITENOSNOOP:                cross cp_bresp , cp_WRITENOSNOOP;
                cp_bresp_x_WRITEUNIQUE:                 cross cp_bresp , cp_WRITEUNIQUE{
                    ignore_bins illegal_bresp_x_WRITEUNIQUE_0_1            = binsof (cp_bresp.exok);}
                cp_bresp_x_WRITELINEUNIQUE:             cross cp_bresp , cp_WRITELINEUNIQUE{
                    ignore_bins illegal_bresp_x_WRITELINEUNIQUE_0_1        = binsof (cp_bresp.exok);}
                cp_bresp_x_WRITEBACK:                   cross cp_bresp , cp_WRITEBACK{
                    ignore_bins illegal_bresp_x_WRITEBACK_0_1              = binsof (cp_bresp.exok);}
                cp_bresp_x_WRITECLEAN:                  cross cp_bresp , cp_WRITECLEAN{
                    ignore_bins illegal_bresp_x_WRITECLEAN_0_1             = binsof (cp_bresp.exok);}
                cp_bresp_x_WRITEEVICT:                  cross cp_bresp , cp_WRITEEVICT{
                    ignore_bins illegal_bresp_x_WRITEEVICT_0_1             = binsof (cp_bresp.exok);}

            endgroup // ace_wr_resp_channel

            covergroup ace_wr_ack_core<%=port%>;
                //#Cov.IOAIU.wack
                cp_wack: coverpoint wack{
                    bins one = {1};
                }
            endgroup // ace_wr_ack
        <%}%>

         // COVERAAGE WRITE STROBE PER BEAT FOR ALL CACHELINE ACCESS
        // #Cov.IOAIU.nativeInterface.WriteDataStrobes
         covergroup wr_data_channel_<%=obj.wData/8%>B_core<%=port%> with function sample (bit multi_access, bit full_cacheline, int n_beats);
  
             cp_access_type: coverpoint multi_access {
               bins multi_line  = {1};
               bins single_line = {0};
             }

             cp_tgt_type: coverpoint tgt_type {
                 bins dii_tgt = {DII};
                 bins dmi_tgt = {DMI};
             } 
             cp_cacheline: coverpoint full_cacheline {
               bins full = {1};
               bins partial = {0};
              }

             cp_strobe_asserted:  coverpoint wstrb  {
                bins wstrb_none     = {<%=obj.wData/8%>'d0};
                bins wstrb_full     = {<%=obj.wData/8%>'d2**(<%=obj.wData%>/8) -1};
                bins wstrb_partial  = {[1 : <%=obj.wData/8%>'d2**(<%=obj.wData%>/8) -2]};
              }

             cp_beat_num: coverpoint beat_num {
                 bins first_beat  = {0};
                 bins middle_beat = {[1:((SYS_nSysCacheline/(<%=obj.wData/8%>)) -2)]};
                 bins last_beat   = {(SYS_nSysCacheline/(<%=obj.wData/8%>))-1};
             }

             cp_cmdtype: coverpoint {awdomain,awsnoop} {
             <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                 bins WRITENOSNOOP      = {6'b000000,6'b110000};
                 bins WRITEUNIQUE       = {6'b010000,6'b100000};
             <% } else if (obj.fnNativeInterface == "ACE-LITE") { %>
                 bins WRITENOSNOOP      = {6'b000000,6'b110000};
                 bins WRITEUNIQUE       = {6'b010000,6'b100000};
                 bins WRITELINEUNIQUE   = {6'b010001,6'b100001};
             <% } else if (obj.fnNativeInterface == "ACELITE-E") { %>
                 bins WRITENOSNOOP      = {6'b000000,6'b110000};
                 bins WRITEUNIQUE       = {6'b010000,6'b100000};
                 bins WRITELINEUNIQUE   = {6'b010001,6'b100001};
                 bins WRUNQPTLSTASH      = {6'b011000,  6'b101000};
                 bins WRUNQFULLSTASH     = {6'b011001,  6'b101001};
             <% } else if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                 bins WRITENOSNOOP      = {6'b000000,6'b110000};
                 bins WRITEUNIQUE       = {6'b010000,6'b100000};
                 bins WRITELINEUNIQUE   = {6'b010001,6'b100001};
                 bins WRITECLEAN        = {6'b000010,6'b010010,6'b100010};
                 bins WRITEBACK         = {6'b000011,6'b010011,6'b100011};
                 bins WRITEEVICT        = {6'b000101,6'b010101,6'b100101};
             <%}%>
             }

             cx_wrnosnoop_every_wrdata_beat: cross cp_strobe_asserted, cp_beat_num, cp_access_type, cp_cacheline iff ({awdomain,awsnoop} inside {6'b000000,6'b110000}) {
                //there would not be a last beat if the line is partial
                ignore_bins last_beat_if_partial = binsof(cp_beat_num.last_beat) && binsof(cp_cacheline.partial);
             }
             
             cx_wrunq_every_wrdata_beat: cross cp_strobe_asserted, cp_beat_num, cp_access_type, cp_cacheline iff ({awdomain,awsnoop} inside {6'b010000,6'b100000}) {
                //there would not be a last beat if the line is partial
                ignore_bins last_beat_if_partial = binsof(cp_beat_num.last_beat) && binsof(cp_cacheline.partial);
             }

             <% if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) {%>
             cx_wrlineunq_every_wrdata_beat: cross cp_strobe_asserted, cp_beat_num, cp_access_type, cp_cacheline iff ({awdomain,awsnoop} inside {6'b010001,6'b100001} && !$test$plusargs("wt_illegal_op_addr")) {
                               illegal_bins wrlnunq_always_a_full_cacheline = binsof(cp_strobe_asserted.wstrb_none) || binsof(cp_strobe_asserted.wstrb_partial) || binsof(cp_cacheline.partial) || binsof(cp_access_type.multi_line);
             }
             <%}%>

               //WRLINEUNQ can only be a full_cacheline access with all wstrbs asserted
               //illegal_bins = cp_cmdtype.WRITELINEUNIQUE && (binsof(strobe_asserted) intersect {wstrb_none, wstrb_partial} || binsof(cacheline_access) intersect {WritePartial, WriteMultiple});
              
               //illegal_bins = binsof(strobe_asserted) intersect {wstrb_none, wstrb_partial} && cacheline_access.WriteFull;

             <% if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) {%>
             cx_wrevct_every_wrdata_beat: cross cp_strobe_asserted, cp_beat_num, cp_access_type, cp_cacheline iff ({awdomain,awsnoop} inside {6'b000101,6'b010101,6'b100101} && !$test$plusargs("wt_illegal_op_addr")) {
                               illegal_bins wrevct_always_a_full_cacheline = binsof(cp_strobe_asserted.wstrb_none) || binsof(cp_strobe_asserted.wstrb_partial) || binsof(cp_cacheline.partial) || binsof(cp_access_type.multi_line);
             }
	
	     cx_wrcln_every_wrdata_beat: cross cp_strobe_asserted, cp_beat_num, cp_access_type, cp_cacheline iff ({awdomain,awsnoop} inside {6'b000010,6'b010010,6'b100010}) {
                //there would not be a last beat if the line is partial
                ignore_bins last_beat_if_partial = binsof(cp_beat_num.last_beat) && binsof(cp_cacheline.partial);
                ignore_bins multi_line		 = binsof(cp_access_type.multi_line);
             }
			 
	     cx_wrbck_every_wrdata_beat: cross cp_strobe_asserted, cp_beat_num, cp_access_type, cp_cacheline iff ({awdomain,awsnoop} inside {6'b000011,6'b010011,6'b100011}) {
                //there would not be a last beat if the line is partial
                ignore_bins last_beat_if_partial = binsof(cp_beat_num.last_beat) && binsof(cp_cacheline.partial);
                ignore_bins multi_line		 = binsof(cp_access_type.multi_line);
             }
//CONC-14270 
             cx_wrcln_wrdata_beat_noncoh_dmi: cross cp_strobe_asserted, cp_beat_num, cp_access_type, cp_tgt_type ,cp_cacheline iff ({awdomain,awsnoop} inside {6'b000010}) {
                ignore_bins last_beat_if_partial = binsof(cp_beat_num.last_beat) && binsof(cp_cacheline.partial);
                ignore_bins multi_line		 = binsof(cp_access_type.multi_line);
                ignore_bins ignore_wrcln_dii_tgt = binsof(cp_tgt_type) intersect {DII};             
               }
			 
             cx_wrcln_wrdata_beat_noncoh_dii: cross cp_strobe_asserted, cp_beat_num, cp_access_type, cp_tgt_type ,cp_cacheline iff ({awdomain,awsnoop} inside {6'b000010}) {
                ignore_bins last_beat_if_partial = binsof(cp_beat_num.last_beat) && binsof(cp_cacheline.partial);
                ignore_bins multi_line		 = binsof(cp_access_type.multi_line);
                ignore_bins ignore_wrcln_dmi_tgt = binsof(cp_tgt_type) intersect {DMI};             
             }
			 
	     cx_wrbck_wrdata_beat_noncoh_dmi: cross cp_strobe_asserted, cp_beat_num, cp_access_type,cp_tgt_type , cp_cacheline iff ({awdomain,awsnoop} inside {6'b000011}) {
                ignore_bins last_beat_if_partial = binsof(cp_beat_num.last_beat) && binsof(cp_cacheline.partial);
                ignore_bins multi_line		 = binsof(cp_access_type.multi_line);
                ignore_bins ignore_wrbck_dii_tgt = binsof(cp_tgt_type) intersect {DII};             
             }

	     cx_wrbck_wrdata_beat_noncoh_dii: cross cp_strobe_asserted, cp_beat_num, cp_access_type,cp_tgt_type , cp_cacheline iff ({awdomain,awsnoop} inside {6'b000011}) {
                ignore_bins last_beat_if_partial = binsof(cp_beat_num.last_beat) && binsof(cp_cacheline.partial);
                ignore_bins multi_line		 = binsof(cp_access_type.multi_line);
                ignore_bins ignore_wrbck_dmi_tgt = binsof(cp_tgt_type) intersect {DMI};             
             }

             <%}%>

             <% if ((obj.fnNativeInterface == "ACELITE-E")) {%>
             cx_wrunqptlstsh_every_wrdata_beat: cross cp_strobe_asserted, cp_beat_num, cp_access_type, cp_cacheline iff ({awdomain,awsnoop} inside {6'b011000, 6'b101000}) {
                //there would not be a last beat if the line is partial
                ignore_bins last_beat_if_partial = binsof(cp_beat_num.last_beat) && binsof(cp_cacheline.partial);
                ignore_bins multi_line		 = binsof(cp_access_type.multi_line);
             }
             cx_wrunqfullstsh_every_wrdata_beat: cross cp_strobe_asserted, cp_beat_num, cp_access_type, cp_cacheline iff ({awdomain,awsnoop} inside {6'b011001, 6'b101001}) {
                               illegal_bins wrunqfullstsh_always_a_full_cacheline = binsof(cp_strobe_asserted.wstrb_none) || binsof(cp_strobe_asserted.wstrb_partial) || binsof(cp_cacheline.partial) || binsof(cp_access_type.multi_line);
             }
             <%}%>

        endgroup : wr_data_channel_<%=obj.wData/8%>B_core<%=port%>

        <%if(obj.fnNativeInterface == "ACE-LITE") { %>
            //ACE-LITE
            //READ CHANNELS
            covergroup ace_lite_rd_addr_chnl_signals_core<%=port%>;
                //#Cov.IOAIU.ardomain
                cp_ardomain: coverpoint ardomain {
                    bins non_shareable = {0};
                    bins inner_shareable = {1};
                    bins outer_shareable = {2};
                    bins system_shareable = {3};
                    //type_option.weight = 0;
                    //option weight = 0;
                }
                //#Cov.IOAIU.arsnoop -covered in  ace_lite_rd_addr_chnl_core
                //#Cov.IOAIU.arbar //Not supported
                //#Cov.IOAIU.arcache
                cp_arcache: coverpoint arcache {
                }
                //#Cov.IOAIU.arprot
                cp_arprot: coverpoint arprot {
                }
                //#Cov.IOAIU.arqos
                <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>
                cp_arqos: coverpoint arqos {
                }
                <%}%>  
                //#Cov.IOAIU.arlock_normal
                cp_arlock_normal: coverpoint arlock {
                    bins NORMAL = {0};
                }
                //#Cov.IOAIU.arlock_exclusive
                cp_arlock_exclusive: coverpoint arlock {
                    bins EXCLUSIVE = {1};
                }
                //#Cov.IOAIU.arlen_allowed
                cp_arlen_allowed: coverpoint arlen{
                    bins len_1  = {0};
                    bins len_2  = {1};
                    bins len_4  = {3};
                    bins len_8  = {7};
                    bins len_16 = {15};
                }
                //#Cov.IOAIU.arburst_allowed
                cp_arburst_allowed: coverpoint arburst{
                    bins incr  = {1};
                    bins wrap  = {2};
                }
                //#Cov.IOAIU.arcache_modifiable
                cp_arcache_modifiable: coverpoint arcache[1]{
                    bins modifiable = {1};
                }

                //#Cov.IOAIU.READNOSNOOP
                cp_READNOSNOOP: coverpoint {ardomain,arsnoop} {
                    bins READNOSNOOP       = {6'b000000,6'b110000};
                }
                //#Cov.IOAIU.READONCE
                cp_READONCE: coverpoint {ardomain,arsnoop} {
                    bins READONCE          = {6'b010000,6'b100000};
                }
                //#Cov.IOAIU.CLEANSHARED
                cp_CLEANSHARED: coverpoint {ardomain,arsnoop} {
                    bins CLEANSHARED       = {6'b001000,6'b011000,6'b101000};
                }
                //#Cov.IOAIU.CLEANINVALID
                cp_CLEANINVALID: coverpoint {ardomain,arsnoop} {
                    bins CLEANINVALID      = {6'b001001,6'b011001,6'b101001};
                }
                //#Cov.IOAIU.MAKEINVALID
                cp_MAKEINVALID: coverpoint {ardomain,arsnoop} {
                    bins MAKEINVALID       = {6'b001101,6'b011101,6'b101101};
                }
                //#Cov.IOAIU.BARRIER -not supported

                <%if(obj.enableDVM) { %>
                    //#Cov.IOAIU.DVMCOMPLETE
                    cp_DVMCOMPLETE: coverpoint {ardomain,arsnoop} {
                        bins DVMCOMPLETE       = {6'b011110,6'b101110};
                    }
                    //#Cov.IOAIU.DVMMESSAGE
                    cp_DVMMESSAGE: coverpoint {ardomain,arsnoop} {
                        bins DVMMESSAGE        = {6'b011111,6'b101111};
                    }

                    cp_dvm_completion: coverpoint araddr[15] {
                        bins not_required                     = {0};
                        bins required                         = {1};
                    }
                    cp_dvm_messege_type: coverpoint araddr[14:12] {
                        bins tlb_invld                        = {0};
                        bins branch_pred_invld                = {1};
                        bins physical_inst_cache_invld        = {2};
                        bins virtual_inst_cache_invld         = {3};
                        bins synchronization                  = {4};
                        bins reserved_0                       = {5};
                        bins hint                             = {6};
                        bins reserved_1                       = {7};
                    }
                    cp_dvm_exception_level: coverpoint araddr[11:10] {
                        bins hypervisor_and_all_guest_os      = {0};
                        bins el3                              = {1};
                        bins guest_os                         = {2};
                        bins hypervisor                       = {3};
                    }
                    cp_dvm_security: coverpoint araddr[9:8] {
                        bins secure_and_nonsecure             = {0};
                        bins nonsecure_addr_secure_context    = {1};
                        bins secure_only                      = {2};
                        bins nonsecure_only                   = {3};
                    }
                    cp_dvm_SBZ_range: coverpoint araddr[7] {
                        bins not_include_addr_range_info      = {0};
                        bins include_addr_range_info          = {1};
                    }
                    cp_dvm_vmid_valid: coverpoint araddr[6] {
                        bins not_include_addr_range_info      = {0};
                        bins include_addr_range_info          = {1};
                    }
                    cp_dvm_asid_valid: coverpoint araddr[5] {
                        bins not_include_addr_range_info      = {0};
                        bins include_addr_range_info          = {1};
                    }
                    cp_dvm_leaf: coverpoint araddr[4] {
                        bins not_include_addr_range_info      = {0};
                        bins include_addr_range_info          = {1};
                    }
                    cp_dvm_stage: coverpoint araddr[3:2] {
                        bins stage1_and_stage2_invld          = {0};
                        bins stage1_only_invld                = {1};
                        bins stage2_only_invld                = {2};
                        bins reserved                         = {3};
                    }
                    cp_dvm_addr: coverpoint araddr[1] {
                        bins one_part                         = {0};
                        bins two_part                         = {1};
                    }

                    //cp_dvm_secure_tlb_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                    //    bins completion_not_required          = {11'b00010100000};
                    //    bins completion_required              = {11'b00010100001};
                    //}
                    //cp_dvm_secure_tlb_invld_va: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                    //    bins completion_not_required          = {11'b00010100010};
                    //    bins completion_required              = {11'b00010100011};
                    //}
                    //cp_dvm_secure_tlb_invld_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                    //    bins completion_not_required          = {11'b00010100100};
                    //    bins completion_required              = {11'b00010100101};
                    //}
                    //cp_dvm_secure_tlb_invld_va_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                    //    bins completion_not_required          = {11'b00010100110};
                    //    bins completion_required              = {11'b00010100111};
                    //}
                    //cp_dvm_all_os_tlb_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                    //    bins completion_not_required          = {11'b00010100000};
                    //    bins completion_required              = {11'b00010100001};
                    //}
                    //cp_dvm_guest_os_tlb_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                    //    bins completion_not_required          = {11'b00010111000};
                    //    bins completion_required              = {11'b00010111001};
                    //}
                    //cp_dvm_guest_os_tlb_invld_va: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                    //    bins completion_not_required          = {11'b00010111010};
                    //    bins completion_required              = {11'b00010111011};
                    //}
                    //cp_dvm_guest_os_tlb_invld_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                    //    bins completion_not_required          = {11'b00010111100};
                    //    bins completion_required              = {11'b00010111101};
                    //}
                    //cp_dvm_guest_os_tlb_invld_va_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                    //    bins completion_not_required          = {11'b00010111110};
                    //    bins completion_required              = {11'b00010111111};
                    //}
                    //cp_dvm_hvisor_tlb_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                    //    bins completion_not_required          = {11'b00011110000};
                    //    bins completion_required              = {11'b00011110001};
                    //}
                    //cp_dvm_hvisor_tlb_invld_va: coverpoint {araddr[14:8],araddr[6:5],araddr[0],araddr[15]} {
                    //    bins completion_not_required          = {11'b00011110010};
                    //    bins completion_required              = {11'b00011110011};
                    //}
                    //cp_dvm_branch_predictor_tlb_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                    //    bins invld_all          = {10'b00100000000};
                    //}
                    //cp_dvm_branch_predictor_tlb_invld_va: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                    //    bins invld_va          = {10'b00100000001};
                    //}
                    //cp_dvm_hvisor_all_guest_os_secure_nonsecure_vic_invld: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {10'b0110000001};
                    //}
                    //cp_dvm_hvisor_all_guest_os_nonsecure_vic_invld: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {10'b0110011001};
                    //}
                    //cp_dvm_guest_os_secure_invld_va_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {10'b0111010011};
                    //}
                    //cp_dvm_guest_os_nonsecure_invld_all: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {10'b0111011100};
                    //}
                    //cp_dvm_guest_os_nonsecure_invld_va_asid: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {10'b0111011111};
                    //}
                    //cp_dvm_hvisor_invld_va: coverpoint {araddr[14:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {10'b0111111001};
                    //}
                    //cp_dvm_secure_pic_invld_all: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {8'b01010000};
                    //}
                    //cp_dvm_secure_pic_invld_all_: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {8'b01010001};
                    //}
                    //cp_dvm_nonsecure_pic_invld_pa_w_o_vi: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {8'b01010111};
                    //}
                    //cp_dvm_nonsecure_pic_invld_pa_w_vi: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {8'b01011000};
                    //}
                    //cp_dvm_nonsecure_pic_invld_all: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {8'b01011001};
                    //}
                    //cp_dvm_nonsecure_pic_invld_pa_w_o_vi_: coverpoint {araddr[14:12],araddr[9:8],araddr[6:5],araddr[0]} {
                    //    bins invld          = {8'b01011111};
                    //}
                <%}%>

                //#Cov.IOAIU.arcache_x_ardoamin
                cp_arcache_x_ardomain:                     cross cp_arcache , cp_ardomain {
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations
                    ignore_bins cp_arcache_X_cp_ardomain_system = binsof (cp_ardomain) intersect{SYSTEM}  && binsof (cp_arcache) intersect {WWBRALLOC, WWTWALLOC, WWBWALLOC, WWTRWALLOC, WWBRWALLOC, WWTNALLOC}; 
                    ignore_bins cp_arcache_X_cp_ardomain = binsof (cp_ardomain) intersect{INNRSHRBL,OUTRSHRBL,NONSHRBL}  && binsof (cp_arcache) intersect { WDEVNONBUF, WDEVBUF}; 
                }

                // len
                //#Cov.IOAIU.arlen_allowed_x_ace_reads
                cp_arlen_allowed_x_CLEANSHARED:            cross cp_arlen_allowed , cp_CLEANSHARED {
                    ignore_bins illegal_arlen_allowed_x_CLEANSHARED = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};}
                cp_arlen_allowed_x_CLEANINVALID:           cross cp_arlen_allowed , cp_CLEANINVALID {
                    ignore_bins illegal_arlen_allowed_x_CLEANINVALID = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};}
                cp_arlen_allowed_x_MAKEINVALID:            cross cp_arlen_allowed , cp_MAKEINVALID {
                    ignore_bins illegal_arlen_allowed_x_MAKEINVALID = !binsof (cp_arlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};}

                //#Cov.IOAIU.arburst_allowed_x_ace_reads
                cp_arburst_allowed_x_CLEANSHARED:          cross cp_arburst_allowed , cp_CLEANSHARED;
                cp_arburst_allowed_x_CLEANINVALID:         cross cp_arburst_allowed , cp_CLEANINVALID;
                cp_arburst_allowed_x_MAKEINVALID:          cross cp_arburst_allowed , cp_MAKEINVALID;
                cp_arburst_allowed_x_READONCE:             cross cp_arburst_allowed , cp_READONCE;

                // cache_modifiable
                //#Cov.IOAIU.arcache_modifiable_x_ace_reads
                cp_arcache_modifiable_x_CLEANSHARED:       cross cp_arcache_modifiable , cp_CLEANSHARED;
                cp_arcache_modifiable_x_CLEANINVALID:      cross cp_arcache_modifiable , cp_CLEANINVALID;
                cp_arcache_modifiable_x_MAKEINVALID:       cross cp_arcache_modifiable , cp_MAKEINVALID;
                cp_arcache_modifiable_x_READONCE:          cross cp_arcache_modifiable , cp_READONCE;

                //#Cov.IOAIU.arlock_normal_x_ace_reads
                cp_arlock_normal_x_CLEANSHARED:            cross cp_arlock_normal , cp_CLEANSHARED;
                cp_arlock_normal_x_CLEANINVALID:           cross cp_arlock_normal , cp_CLEANINVALID;
                cp_arlock_normal_x_MAKEINVALID:            cross cp_arlock_normal , cp_MAKEINVALID;
                cp_arlock_normal_x_READONCE:               cross cp_arlock_normal , cp_READONCE;

                //#Cov.IOAIU.arlock_exclusive_x_ace_reads

                //#Cov.IOAIU.arprot_x_ace_reads
                cp_arprot_x_CLEANSHARED:                   cross cp_arprot , cp_CLEANSHARED;
                cp_arprot_x_CLEANINVALID:                  cross cp_arprot , cp_CLEANINVALID;
                cp_arprot_x_MAKEINVALID:                   cross cp_arprot , cp_MAKEINVALID;
                cp_arprot_x_READONCE:                      cross cp_arprot , cp_READONCE;

                //#Cov.IOAIU.arqos_x_ace_reads
                <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>
                cp_arqos_x_CLEANSHARED:                    cross cp_arqos , cp_CLEANSHARED;
                cp_arqos_x_CLEANINVALID:                   cross cp_arqos , cp_CLEANINVALID;
                cp_arqos_x_MAKEINVALID:                    cross cp_arqos , cp_MAKEINVALID;
                cp_arqos_x_READONCE:                       cross cp_arqos , cp_READONCE;
                <%}%>  

                <%if(obj.enableDVM) { %>
                    cp_DVMCOMPLETE_x_dvm_completion                                    : cross cp_DVMCOMPLETE , cp_dvm_completion;
                    cp_DVMCOMPLETE_x_dvm_messege_type                                  : cross cp_DVMCOMPLETE , cp_dvm_messege_type;
                    cp_DVMCOMPLETE_x_dvm_exception_level                               : cross cp_DVMCOMPLETE , cp_dvm_exception_level;
                    cp_DVMCOMPLETE_x_dvm_security                                      : cross cp_DVMCOMPLETE , cp_dvm_security;
                    cp_DVMCOMPLETE_x_dvm_SBZ_range                                     : cross cp_DVMCOMPLETE , cp_dvm_SBZ_range;
                    cp_DVMCOMPLETE_x_dvm_vmid_valid                                    : cross cp_DVMCOMPLETE , cp_dvm_vmid_valid;
                    cp_DVMCOMPLETE_x_dvm_asid_valid                                    : cross cp_DVMCOMPLETE , cp_dvm_asid_valid;
                    cp_DVMCOMPLETE_x_dvm_leaf                                          : cross cp_DVMCOMPLETE , cp_dvm_leaf;
                    cp_DVMCOMPLETE_x_dvm_stage                                         : cross cp_DVMCOMPLETE , cp_dvm_stage;
                    cp_DVMCOMPLETE_x_dvm_addr                                          : cross cp_DVMCOMPLETE , cp_dvm_addr;

                    //cp_DVMCOMPLETE_x_dvm_secure_tlb_invld_all                          : cross cp_DVMCOMPLETE , cp_dvm_secure_tlb_invld_all;
                    //cp_DVMCOMPLETE_x_dvm_secure_tlb_invld_va                           : cross cp_DVMCOMPLETE , cp_dvm_secure_tlb_invld_va;
                    //cp_DVMCOMPLETE_x_dvm_secure_tlb_invld_asid                         : cross cp_DVMCOMPLETE , cp_dvm_secure_tlb_invld_asid;
                    //cp_DVMCOMPLETE_x_dvm_secure_tlb_invld_va_asid                      : cross cp_DVMCOMPLETE , cp_dvm_secure_tlb_invld_va_asid;
                    //cp_DVMCOMPLETE_x_dvm_all_os_tlb_invld_all                          : cross cp_DVMCOMPLETE , cp_dvm_all_os_tlb_invld_all;
                    //cp_DVMCOMPLETE_x_dvm_guest_os_tlb_invld_all                        : cross cp_DVMCOMPLETE , cp_dvm_guest_os_tlb_invld_all;
                    //cp_DVMCOMPLETE_x_dvm_guest_os_tlb_invld_va                         : cross cp_DVMCOMPLETE , cp_dvm_guest_os_tlb_invld_va;
                    //cp_DVMCOMPLETE_x_dvm_guest_os_tlb_invld_asid                       : cross cp_DVMCOMPLETE , cp_dvm_guest_os_tlb_invld_asid;
                    //cp_DVMCOMPLETE_x_dvm_guest_os_tlb_invld_va_asid                    : cross cp_DVMCOMPLETE , cp_dvm_guest_os_tlb_invld_va_asid;
                    //cp_DVMCOMPLETE_x_dvm_hvisor_tlb_invld_all                          : cross cp_DVMCOMPLETE , cp_dvm_hvisor_tlb_invld_all;
                    //cp_DVMCOMPLETE_x_dvm_hvisor_tlb_invld_va                           : cross cp_DVMCOMPLETE , cp_dvm_hvisor_tlb_invld_va;
                    //cp_DVMCOMPLETE_x_dvm_branch_predictor_tlb_invld_all                : cross cp_DVMCOMPLETE , cp_dvm_branch_predictor_tlb_invld_all;
                    //cp_DVMCOMPLETE_x_dvm_branch_predictor_tlb_invld_va                 : cross cp_DVMCOMPLETE , cp_dvm_branch_predictor_tlb_invld_va;
                    //cp_DVMCOMPLETE_x_dvm_hvisor_all_guest_os_secure_nonsecure_vic_invld: cross cp_DVMCOMPLETE , cp_dvm_hvisor_all_guest_os_secure_nonsecure_vic_invld;
                    //cp_DVMCOMPLETE_x_dvm_hvisor_all_guest_os_nonsecure_vic_invld       : cross cp_DVMCOMPLETE , cp_dvm_hvisor_all_guest_os_nonsecure_vic_invld;
                    //cp_DVMCOMPLETE_x_dvm_guest_os_secure_invld_va_asid                 : cross cp_DVMCOMPLETE , cp_dvm_guest_os_secure_invld_va_asid;
                    //cp_DVMCOMPLETE_x_dvm_guest_os_nonsecure_invld_all                  : cross cp_DVMCOMPLETE , cp_dvm_guest_os_nonsecure_invld_all;
                    //cp_DVMCOMPLETE_x_dvm_guest_os_nonsecure_invld_va_asid              : cross cp_DVMCOMPLETE , cp_dvm_guest_os_nonsecure_invld_va_asid;
                    //cp_DVMCOMPLETE_x_dvm_hvisor_invld_va                               : cross cp_DVMCOMPLETE , cp_dvm_hvisor_invld_va;
                    //cp_DVMCOMPLETE_x_dvm_secure_pic_invld_all                          : cross cp_DVMCOMPLETE , cp_dvm_secure_pic_invld_all;
                    //cp_DVMCOMPLETE_x_dvm_secure_pic_invld_all_                         : cross cp_DVMCOMPLETE , cp_dvm_secure_pic_invld_all_;
                    //cp_DVMCOMPLETE_x_dvm_nonsecure_pic_invld_pa_w_o_vi                 : cross cp_DVMCOMPLETE , cp_dvm_nonsecure_pic_invld_pa_w_o_vi;
                    //cp_DVMCOMPLETE_x_dvm_nonsecure_pic_invld_pa_w_vi                   : cross cp_DVMCOMPLETE , cp_dvm_nonsecure_pic_invld_pa_w_vi;
                    //cp_DVMCOMPLETE_x_dvm_nonsecure_pic_invld_all                       : cross cp_DVMCOMPLETE , cp_dvm_nonsecure_pic_invld_all;
                    //cp_DVMCOMPLETE_x_dvm_nonsecure_pic_invld_pa_w_o_vi_                : cross cp_DVMCOMPLETE , cp_dvm_nonsecure_pic_invld_pa_w_o_vi_;

                    cp_DVMMESSEGE_x_dvm_completion                                    : cross cp_DVMMESSAGE , cp_dvm_completion;
                    cp_DVMMESSEGE_x_dvm_messege_type                                  : cross cp_DVMMESSAGE , cp_dvm_messege_type;
                    cp_DVMMESSEGE_x_dvm_exception_level                               : cross cp_DVMMESSAGE , cp_dvm_exception_level;
                    cp_DVMMESSEGE_x_dvm_security                                      : cross cp_DVMMESSAGE , cp_dvm_security;
                    cp_DVMMESSEGE_x_dvm_SBZ_range                                     : cross cp_DVMMESSAGE , cp_dvm_SBZ_range;
                    cp_DVMMESSEGE_x_dvm_vmid_valid                                    : cross cp_DVMMESSAGE , cp_dvm_vmid_valid;
                    cp_DVMMESSEGE_x_dvm_asid_valid                                    : cross cp_DVMMESSAGE , cp_dvm_asid_valid;
                    cp_DVMMESSEGE_x_dvm_leaf                                          : cross cp_DVMMESSAGE , cp_dvm_leaf;
                    cp_DVMMESSEGE_x_dvm_stage                                         : cross cp_DVMMESSAGE , cp_dvm_stage;
                    cp_DVMMESSEGE_x_dvm_addr                                          : cross cp_DVMMESSAGE , cp_dvm_addr;

                    //cp_DVMMESSEGE_x_dvm_secure_tlb_invld_all                          : cross cp_DVMMESSAGE , cp_dvm_secure_tlb_invld_all;
                    //cp_DVMMESSEGE_x_dvm_secure_tlb_invld_va                           : cross cp_DVMMESSAGE , cp_dvm_secure_tlb_invld_va;
                    //cp_DVMMESSEGE_x_dvm_secure_tlb_invld_asid                         : cross cp_DVMMESSAGE , cp_dvm_secure_tlb_invld_asid;
                    //cp_DVMMESSEGE_x_dvm_secure_tlb_invld_va_asid                      : cross cp_DVMMESSAGE , cp_dvm_secure_tlb_invld_va_asid;
                    //cp_DVMMESSEGE_x_dvm_all_os_tlb_invld_all                          : cross cp_DVMMESSAGE , cp_dvm_all_os_tlb_invld_all;
                    //cp_DVMMESSEGE_x_dvm_guest_os_tlb_invld_all                        : cross cp_DVMMESSAGE , cp_dvm_guest_os_tlb_invld_all;
                    //cp_DVMMESSEGE_x_dvm_guest_os_tlb_invld_va                         : cross cp_DVMMESSAGE , cp_dvm_guest_os_tlb_invld_va;
                    //cp_DVMMESSEGE_x_dvm_guest_os_tlb_invld_asid                       : cross cp_DVMMESSAGE , cp_dvm_guest_os_tlb_invld_asid;
                    //cp_DVMMESSEGE_x_dvm_guest_os_tlb_invld_va_asid                    : cross cp_DVMMESSAGE , cp_dvm_guest_os_tlb_invld_va_asid;
                    //cp_DVMMESSEGE_x_dvm_hvisor_tlb_invld_all                          : cross cp_DVMMESSAGE , cp_dvm_hvisor_tlb_invld_all;
                    //cp_DVMMESSEGE_x_dvm_hvisor_tlb_invld_va                           : cross cp_DVMMESSAGE , cp_dvm_hvisor_tlb_invld_va;
                    //cp_DVMMESSEGE_x_dvm_branch_predictor_tlb_invld_all                : cross cp_DVMMESSAGE , cp_dvm_branch_predictor_tlb_invld_all;
                    //cp_DVMMESSEGE_x_dvm_branch_predictor_tlb_invld_va                 : cross cp_DVMMESSAGE , cp_dvm_branch_predictor_tlb_invld_va;
                    //cp_DVMMESSEGE_x_dvm_hvisor_all_guest_os_secure_nonsecure_vic_invld: cross cp_DVMMESSAGE , cp_dvm_hvisor_all_guest_os_secure_nonsecure_vic_invld;
                    //cp_DVMMESSEGE_x_dvm_hvisor_all_guest_os_nonsecure_vic_invld       : cross cp_DVMMESSAGE , cp_dvm_hvisor_all_guest_os_nonsecure_vic_invld;
                    //cp_DVMMESSEGE_x_dvm_guest_os_secure_invld_va_asid                 : cross cp_DVMMESSAGE , cp_dvm_guest_os_secure_invld_va_asid;
                    //cp_DVMMESSEGE_x_dvm_guest_os_nonsecure_invld_all                  : cross cp_DVMMESSAGE , cp_dvm_guest_os_nonsecure_invld_all;
                    //cp_DVMMESSEGE_x_dvm_guest_os_nonsecure_invld_va_asid              : cross cp_DVMMESSAGE , cp_dvm_guest_os_nonsecure_invld_va_asid;
                    //cp_DVMMESSEGE_x_dvm_hvisor_invld_va                               : cross cp_DVMMESSAGE , cp_dvm_hvisor_invld_va;
                    //cp_DVMMESSEGE_x_dvm_secure_pic_invld_all                          : cross cp_DVMMESSAGE , cp_dvm_secure_pic_invld_all;
                    //cp_DVMMESSEGE_x_dvm_secure_pic_invld_all_                         : cross cp_DVMMESSAGE , cp_dvm_secure_pic_invld_all_;
                    //cp_DVMMESSEGE_x_dvm_nonsecure_pic_invld_pa_w_o_vi                 : cross cp_DVMMESSAGE , cp_dvm_nonsecure_pic_invld_pa_w_o_vi;
                    //cp_DVMMESSEGE_x_dvm_nonsecure_pic_invld_pa_w_vi                   : cross cp_DVMMESSAGE , cp_dvm_nonsecure_pic_invld_pa_w_vi;
                    //cp_DVMMESSEGE_x_dvm_nonsecure_pic_invld_all                       : cross cp_DVMMESSAGE , cp_dvm_nonsecure_pic_invld_all;
                    //cp_DVMMESSEGE_x_dvm_nonsecure_pic_invld_pa_w_o_vi_                : cross cp_DVMMESSAGE , cp_dvm_nonsecure_pic_invld_pa_w_o_vi_;
                <%}%>
            endgroup //ace_lite_rd_addr_chnl_signals

            covergroup ace_lite_rd_resp_channel_core<%=port%>;
                //#Cov.IOAIU.rresp_1_0
                cp_rresp_1_0: coverpoint rresp[1:0]{
                    bins ok = {0};
                    bins exok = {1};
                    bins slverr = {2};
                    bins decerr = {3};
                }
                //#Cov.IOAIU.rresp_3_2
                cp_rresp_3_2: coverpoint rresp[3:2]{
                    bins bin_0_0 = {0};
                    bins bin_0_1 = {1};
                    bins bin_1_0 = {2};
                    bins bin_1_1 = {3};
                    //Table C3-16 IsShared and PassDirty permitted responses
                    ignore_bins illegal_0_1 = {1};
                    ignore_bins illegal_1_0 = {2};
                    ignore_bins illegal_1_1 = {3};
                }
                //#Cov.IOAIU.PassDirty
                cp_PassDirty: coverpoint rresp[2]{
                    bins zero = {0};
                    bins one = {1};
                    ignore_bins illegal_one = {1};
                }
                //#Cov.IOAIU.IsShared
                cp_IsShared: coverpoint rresp[3]{
                    bins zero = {0};
                    bins one = {1};
                    ignore_bins illegal_one = {1};
                }
                //#Cov.IOAIU.READNOSNOOP
                cp_READNOSNOOP: coverpoint {rsp_ardomain,rsp_arsnoop} {
                    bins READNOSNOOP       = {6'b000000,6'b110000};
                }
                //#Cov.IOAIU.READONCE
                cp_READONCE: coverpoint {rsp_ardomain,rsp_arsnoop} {
                    bins READONCE          = {6'b010000,6'b100000};
                }
                //#Cov.IOAIU.CLEANSHARED
                cp_CLEANSHARED: coverpoint {rsp_ardomain,rsp_arsnoop} {
                    bins CLEANSHARED       = {6'b001000,6'b011000,6'b101000};
                }
                //#Cov.IOAIU.CLEANINVALID
                cp_CLEANINVALID: coverpoint {rsp_ardomain,rsp_arsnoop} {
                    bins CLEANINVALID      = {6'b001001,6'b011001,6'b101001};
                }
                //#Cov.IOAIU.MAKEINVALID
                cp_MAKEINVALID: coverpoint {rsp_ardomain,rsp_arsnoop} {
                    bins MAKEINVALID       = {6'b001101,6'b011101,6'b101101};
                }
                //#Cov.IOAIU.BARRIER -not supported
                <%if(obj.enableDVM) { %>
                    //#Cov.IOAIU.DVMCOMPLETE
                    cp_DVMCOMPLETE: coverpoint {rsp_ardomain,rsp_arsnoop} {
                        bins DVMCOMPLETE       = {6'b011110,6'b101110};
                    }
                    //#Cov.IOAIU.DVMMESSAGE
                    cp_DVMMESSAGE: coverpoint {rsp_ardomain,rsp_arsnoop} {
                        bins DVMMESSAGE        = {6'b011111,6'b101111};
                    }
                <%}%>
                //#Cov.IOAIU.rresp_3_2_x_ace_reads
                cp_rresp_3_2_x_READNOSNOOP:            cross cp_rresp_3_2 , cp_READNOSNOOP{
                    ignore_bins illegal_rresp_3_2_x_READNOSNOOP_0_1        = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_READNOSNOOP_1_0        = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_READNOSNOOP_1_1        = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_CLEANSHARED:          cross cp_rresp_3_2 , cp_CLEANSHARED{
                    ignore_bins illegal_rresp_3_2_x_CLEANSHARED_0_1        = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_CLEANSHARED_1_0        = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_CLEANSHARED_1_1        = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_CLEANINVALID:         cross cp_rresp_3_2 , cp_CLEANINVALID{
                    ignore_bins illegal_rresp_3_2_x_CLEANINVALID_0_1       = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_CLEANINVALID_1_0       = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_CLEANINVALID_1_1       = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_MAKEINVALID:          cross cp_rresp_3_2 , cp_MAKEINVALID{
                    ignore_bins illegal_rresp_3_2_x_MAKEINVALID_0_1        = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_MAKEINVALID_1_0        = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_MAKEINVALID_1_1        = binsof (cp_rresp_3_2.bin_1_1);}
                cp_rresp_3_2_x_READONCE:             cross cp_rresp_3_2 , cp_READONCE{
                    ignore_bins illegal_rresp_3_2_x_READONCE_0_1           = binsof (cp_rresp_3_2.bin_0_1);
                    ignore_bins illegal_rresp_3_2_x_READONCE_1_0           = binsof (cp_rresp_3_2.bin_1_0);
                    ignore_bins illegal_rresp_3_2_x_READONCE_1_1           = binsof (cp_rresp_3_2.bin_1_1);}
                <%if(obj.enableDVM) { %>
                    cp_rresp_3_2_x_DVMCOMPLETE:          cross cp_rresp_3_2 , cp_DVMCOMPLETE{
                        ignore_bins illegal_rresp_3_2_x_DVMCOMPLETE_0_1        = binsof (cp_rresp_3_2.bin_0_1);
                        ignore_bins illegal_rresp_3_2_x_DVMCOMPLETE_1_0        = binsof (cp_rresp_3_2.bin_1_0);
                        ignore_bins illegal_rresp_3_2_x_DVMCOMPLETE_1_1        = binsof (cp_rresp_3_2.bin_1_1);}
                    cp_rresp_3_2_x_DVMMESSAGE:           cross cp_rresp_3_2 , cp_DVMMESSAGE{
                        ignore_bins illegal_rresp_3_2_x_DVMMESSAGE_0_1         = binsof (cp_rresp_3_2.bin_0_1);
                        ignore_bins illegal_rresp_3_2_x_DVMMESSAGE_1_0         = binsof (cp_rresp_3_2.bin_1_0);
                        ignore_bins illegal_rresp_3_2_x_DVMMESSAGE_1_1         = binsof (cp_rresp_3_2.bin_1_1);}
                <%}%>

                //#Cov.IOAIU.rresp_1_0_x_ace_reads -not supported

            endgroup // ace_lite_rd_resp_channel

            covergroup ace_lite_rd_ack_core<%=port%>;
                //#Cov.IOAIU.rack
                cp_rack: coverpoint rack{
                    bins one = {1};
                }
            endgroup // ace_lite_rd_ack

            //WRITE CHANNELS

            covergroup ace_lite_wr_addr_chnl_signals_core<%=port%>;
                //#Cov.IOAIU.awdomain
                cp_awdomain: coverpoint awdomain {
                    bins non_shareable = {0};
                    bins inner_shareable = {1};
                    bins outer_shareable = {2};
                    bins system_shareable = {3};
                    //type_option.weight = 0;
                }
                //#Cov.IOAIU.awsnoop// ace_lite_wr_addr_chnl_core
                //#Cov.IOAIU.awbar //not supported
                //#Cov.IOAIU.awunique
                cp_awunique: coverpoint awunique {
                    bins zero = {0};
                    bins one = {1};
                }
                //#Cov.IOAIU.awlen_allowed
                cp_awlen_allowed: coverpoint awlen{
                    bins len_1  = {0};
                    bins len_2  = {1};
                    bins len_4  = {3};
                    bins len_8  = {7};
                    bins len_16 = {15};
                }
                //#Cov.IOAIU.awcache
                cp_awcache: coverpoint awcache {
                }
                //#Cov.IOAIU.awcache_modifiable
                cp_awcache_modifiable: coverpoint awcache[1]{
                    bins modifiable = {1};
                }
                //#Cov.IOAIU.awprot
                cp_awprot: coverpoint awprot {
                }
                //#Cov.IOAIU.awqos
                <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>
                cp_awqos: coverpoint awqos {
                }
                <% } %>
                //#Cov.IOAIU.awlock_normal
                cp_awlock_normal: coverpoint awlock {
                    bins NORMAL = {0};
                }
                //#Cov.IOAIU.awlock_exclusive
                cp_awlock_exclusive: coverpoint awlock {
                    bins EXCLUSIVE = {1};
                }
                //#Cov.IOAIU.awburst_allowed
                cp_awburst_allowed: coverpoint awburst{
                    bins incr  = {1};
                    bins wrap  = {2};
                }
                //#Stimulus.IOAIU.axsnoop

                //#Cov.IOAIU.WRITENOSNOOP
                cp_WRITENOSNOOP: coverpoint {awdomain,awsnoop} {
                    bins WRITENOSNOOP      = {6'b000000,6'b110000};
                }
                //#Cov.IOAIU.WRITEUNIQUE
                cp_WRITEUNIQUE: coverpoint {awdomain,awsnoop} {
                    bins WRITEUNIQUE       = {6'b010000,6'b100000};
                }
                //#Cov.IOAIU.WRITELINEUNIQUE
                cp_WRITELINEUNIQUE: coverpoint {awdomain,awsnoop} {
                    bins WRITELINEUNIQUE   = {6'b010001,6'b100001};
                }
                //#Cov.IOAIU.BARRIER -not supported

                //#Cov.IOAIU.awcache_x_awdoamin
                cp_awcache_x_awdomain:                     cross cp_awcache , cp_awdomain {
                //Table C3-3 AxCACHE and AxDOMAIN signal combinations
                    ignore_bins cp_awcache_X_cp_awdomain_system = binsof (cp_awdomain) intersect{SYSTEM}  && binsof (cp_awcache) intersect {WWBRALLOC, WWTWALLOC, WWBWALLOC, WWTRWALLOC, WWBRWALLOC, WWTNALLOC}; 
                    ignore_bins cp_awcache_X_cp_awdomain = binsof (cp_awdomain) intersect{INNRSHRBL,OUTRSHRBL,NONSHRBL}  && binsof (cp_awcache) intersect { WDEVNONBUF, WDEVBUF}; 
                }

                //#Cov.IOAIU.awunique_x_writes
                cp_awunique_x_WRITENOSNOOP:                cross cp_awunique , cp_WRITENOSNOOP;
                cp_awunique_x_WRITEUNIQUE:                 cross cp_awunique , cp_WRITEUNIQUE;
                cp_awunique_x_WRITELINEUNIQUE:             cross cp_awunique , cp_WRITELINEUNIQUE;

                //#Cov.IOAIU.awlen_allowed_x_writes
                cp_awlen_allowed_x_WRITELINEUNIQUE:        cross cp_awlen_allowed , cp_WRITELINEUNIQUE {
                    ignore_bins illegal_awlen_allowed_x_WRITELINEUNIQUE = !binsof (cp_awlen_allowed) intersect {((SYS_nSysCacheline*8/WXDATA) - 1)};}

                //#Cov.IOAIU.awburst_allowed_x_writes
                cp_awburst_allowed_x_WRITELINEUNIQUE:      cross cp_awburst_allowed , cp_WRITELINEUNIQUE;
                cp_awburst_allowed_x_WRITEUNIQUE:          cross cp_awburst_allowed , cp_WRITEUNIQUE;

                //#Cov.IOAIU.awcache_modifiable_x_writes
                cp_awcache_modifiable_x_WRITELINEUNIQUE:   cross cp_awcache_modifiable , cp_WRITELINEUNIQUE;
                cp_awcache_modifiable_x_WRITEUNIQUE:       cross cp_awcache_modifiable , cp_WRITEUNIQUE;

                //#Cov.IOAIU.awlock_normal_x_writes
                cp_awlock_normal_x_WRITELINEUNIQUE:        cross cp_awlock_normal , cp_WRITELINEUNIQUE;
                cp_awlock_normal_x_WRITEUNIQUE:            cross cp_awlock_normal , cp_WRITEUNIQUE;

                //#Cov.IOAIU.awprot_x_writes
                cp_awprot_x_WRITELINEUNIQUE:               cross cp_awprot , cp_WRITELINEUNIQUE;
                cp_awprot_x_WRITEUNIQUE:                   cross cp_awprot , cp_WRITEUNIQUE;

                //#Cov.IOAIU.awqos_x_writes
                <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>
                cp_awqos_x_WRITELINEUNIQUE:                cross cp_awqos , cp_WRITELINEUNIQUE;
                cp_awqos_x_WRITEUNIQUE:                    cross cp_awqos , cp_WRITEUNIQUE;
                <% } %>

            endgroup //ace_lite_wr_addr_chnl_signals

            covergroup ace_lite_wr_resp_channel_core<%=port%>;
                //#Cov.IOAIU.bresp
                cp_bresp: coverpoint bresp{
                    bins ok = {0};
                    bins exok = {1};
                    bins slverr = {2};
                    bins decerr = {3};
                    //ace-5//bresp 3-bit wide//
                    //bins transfault = {5};//TODO
                }
                //#Cov.IOAIU.WRITENOSNOOP
                cp_WRITENOSNOOP: coverpoint {rsp_awdomain,rsp_awsnoop} {
                    bins WRITENOSNOOP      = {6'b000000,6'b110000};
                }
                //#Cov.IOAIU.WRITEUNIQUE
                cp_WRITEUNIQUE: coverpoint {rsp_awdomain,rsp_awsnoop} {
                    bins WRITEUNIQUE       = {6'b010000,6'b100000};
                }
                //#Cov.IOAIU.WRITELINEUNIQUE
                cp_WRITELINEUNIQUE: coverpoint {rsp_awdomain,rsp_awsnoop} {
                    bins WRITELINEUNIQUE   = {6'b010001,6'b100001};
                }
                //#Cov.IOAIU.BARRIER //not supported

                //#Cov.IOAIU.bresp_x_ace_writes
                //EVICT bresp = 00 // no limitation for other writes

                cp_bresp_x_WRITENOSNOOP:                cross cp_bresp , cp_WRITENOSNOOP;
                cp_bresp_x_WRITEUNIQUE:                 cross cp_bresp , cp_WRITEUNIQUE{
                    ignore_bins illegal_bresp_x_WRITEUNIQUE_0_1            = binsof (cp_bresp.exok);}
                cp_bresp_x_WRITELINEUNIQUE:             cross cp_bresp , cp_WRITELINEUNIQUE{
                    ignore_bins illegal_bresp_x_WRITELINEUNIQUE_0_1        = binsof (cp_bresp.exok);}

            endgroup // ace_lite_wr_resp_channel

            covergroup ace_lite_wr_ack_core<%=port%>;
                //#Cov.IOAIU.wack
                cp_wack: coverpoint wack{
                    bins one = {1};
                }
            endgroup // ace_lite_wr_ack
        <%}%>


        ////////////////////////////////////////
        // COVERGROUPS FOR WRITE ADDRESS CHANNEL
        ////////////////////////////////////////

        //Cov.IOAIU.AW.ARLEN, Cov.IOAIU.AW.ARSIZE, Cov.IOAIU.AW.ARBRUST
        //Cov.IOAIU.AW.AXIReadPartial, Cov.IOAIU.AW.ReadFull, Cov.IOAIU.AW.ReadMultiple
        //Cov.IOAIU.AXIWrite.MultiLineWrap, Cov.IOAIU.AXIWrite.SingleLineWrap, Cov.IOAIU.AXIWrite.LineWrap
        //Cov.IOAIU.AW.AXIWrite_MatchAWID, Cov.IOAIU.AR.AXIWrite_MatchAddrInOtt (To be implemented)
        // #Cov.IOAIU.AXI.AccessTypes
        covergroup <%if ((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%}else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%>ace_lite_e<%}%>_wr_addr_chnl_core<%=port%>;
                   <%if(!(obj.nNativeInterfacePorts > 1)){ %>
                       `COVER_POINT_WA_BURST_LENGTH
                   <%}%>
                   `COVER_POINT_WA_BURST_SIZE
                   `COVER_POINT_WA_BURST_TYPE
                   `COVER_POINT_WA_CACHELINE_ACCESS
                   `COVER_POINT_WA_WEIRD_WRAP
                   `CROSS_WA_BURST_TYPE_CACHELINE_ACCESS
                   <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
                   `ifndef VCS
                   `CROSS_WA_BURST_LENGTH_SIZE_TYPE  
                   `else // `ifndef VCS
                   <%if(!(obj.nNativeInterfacePorts > 1)){ %>
                   `CROSS_WA_BURST_LENGTH_SIZE_TYPE  
                   <%}%>
                   `endif // `ifndef VCS ... `else ... 
                   <% } else {%>
                   `CROSS_WA_BURST_LENGTH_SIZE_TYPE  
                   <%}%>
                   //`COVER_POINT_WA_AWID_MATCH
                   //`COVER_POINT_WA_AWADDR_MATCH
                    coverpoint_awlock: coverpoint awlock {
                        bins NORMAL = {NORMAL};
                        bins EXCLUSIVE = {EXCLUSIVE};
                    }
                   <%if(obj.nNativeInterfacePorts > 1){ %>
                    //multiport-CONC-10715
                    burst_length: coverpoint awlen {
                       <%if( (1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1 >= 15) {%>
                         bins wrap_maxawlen[] = {1,3,7,15} iff(awburst==AXIWRAP); <%} 
                       else if( (1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1 >= 7) {%>
                         bins wrap_maxawlen[] = {1,3,7} iff(awburst==AXIWRAP); <%}
                       else if( (1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1 >= 3) {%>
                         bins wrap_maxawlen[] = {1,3} iff(arburst==AXIWRAP); <%}
                       else if( (1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1 >= 1) {%>
                         bins wrap_maxawlen[]   = {1} iff(awburst==AXIWRAP); <%} %>

                       <%if(((1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1)>=255) {%>
                         bins incr_awlen[] = {[0:255]} iff(awburst==AXIINCR);
                       <% } else {%>
                         bins incr_awlen[] = {[0:<%=((1<<(obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[0]))/(obj.wData/8)-1)%>]} iff(awburst==AXIINCR);
                       <%}%>
                    }
                    <%}%>
                    //#Cov.IOAIU.awcache
                    cp_awcache: coverpoint awcache {
                       bins b_0000 = {0};
                       bins b_0001 = {1};
                       bins b_0010 = {2};
                       bins b_0011 = {3};
                  <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
                  `ifndef VCS
                       bins b_0100 = {4};
                       bins b_0101 = {5};
                  `endif // `ifndef VCS
                  <% } else {%>
                       bins b_0100 = {4};
                       bins b_0101 = {5};
                  <%}%>
                       bins b_0110 = {6};
                       bins b_0111 = {7};
                  <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
                  `ifndef VCS
                       bins b_1000 = {8};
                       bins b_1001 = {9};
                  `endif // `ifndef VCS
                  <% } else {%>
                       bins b_1000 = {8};
                       bins b_1001 = {9};
                  <%}%>
                       bins b_1010 = {10};
                       bins b_1011 = {11};
                  <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
                  `ifndef VCS
                       bins b_1100 = {12};
                       bins b_1101 = {13};
                  `endif // `ifndef VCS
                  <% } else {%>
                       bins b_1100 = {12};
                       bins b_1101 = {13};
                  <%}%>
                       bins b_1110 = {14};
                       bins b_1111 = {15};
                    }
                    <% if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACELITE-E"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                    cp_cachelinetxn_awlen: coverpoint awlen {
                        bins allowed_awlen[] = {((SYS_nSysCacheline*8/(WXDATA)) - 1)};//Table C3-11 Cache line size transaction constraints burst_len={1,2,4,8,16}
                    }
                   cp_wrunq_awlen: coverpoint awlen {
                       bins allowed_wrunq_incr_awlen[] = {[0:((SYS_nSysCacheline*8/(WXDATA)) - 1)]} iff(awburst==AXIINCR);//https://arterisip.atlassian.net/browse/CONC-11571
                       bins allowed_wrunq_wrap_awlen[] = {((SYS_nSysCacheline*8/(WXDATA)) - 1)} iff(awburst==AXIWRAP);
                   }
                    //#Cov.IOAIU.awdomain
                    cp_awdomain: coverpoint awdomain {
                        bins non_shareable = {0};
                        bins inner_shareable = {1};
                        bins outer_shareable = {2};
                        bins system_shareable = {3};
                    }
                    <%}%>
                    cp_tgt_type: coverpoint tgt_type {
                        bins dii_tgt = {DII};
                        bins dmi_tgt = {DMI};
                    } 
                    //#Cov.IOAIU.NarrowTransfer
                    cp_wr_narrow_length: coverpoint awlen {
                        bins awlen_0 = {0};
                    }
                    cross_wr_narrow_transfer: cross cp_wr_narrow_length, burst_size, burst_type{
                        ignore_bins wrap_awlen_0        = binsof (burst_type.wrap_burst);
                    }

                    //#Cov.IOAIU.awaddr_type
                    //#Stimulus.IOAIU.axsize
            
                    cp_awaddr_type: coverpoint awaddr[<%=(Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8)-1)):5%>:0] {
                            <%if(Math.ceil(Math.log2(obj.wData/8)) > 6) { %>wildcard <%}%>bins cache_align = {'b<%for(var i = (Math.ceil(Math.log2(obj.wData/8))); i > 6; i--) { %>?<%}%>000000};
                        <%for(var i = Math.ceil(Math.log2(obj.wData/8)); i >=0; i--){%>
                            //wildcard bins size_<%=i%>_align ={'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > i){%>?<%}else{%>0<%}}%>}  iff (awsize == <%=i%>);<%}%>
                        <%for(var i = Math.ceil(Math.log2(obj.wData/8)); i >0; i--){%>
                            wildcard bins size_<%=i%>_unalign ={<%for(var k = i; k > 0; k--){%>'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(k==j){%>1<%}else{%>?<%}}if(k>1){%>,<%}}%>}  iff (awsize == <%=i%>);<%}%>
                        <%for(var i = Math.ceil(Math.log2(obj.wData/8)); i >=0; i--){%>
                        <%for(var k = 0; k<Math.ceil((obj.wData/8)/(Math.pow(2,i))); k++){%>
                            wildcard bins size_<%=i%>_align_with_B<%=(k*(Math.pow(2,i))).toString(16).padStart((2),'0')%> ={'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > Math.ceil(Math.log2(obj.wData/8))){%>?<%}else{if(j > i){%><%=k.toString(2).padStart((j-i),'0')%><%j=i+1;}else{%>0<%}}}%>}  iff (awsize == <%=i%>);<%}}%>
                    }
                    //#Cov.IOAIU.awaddr_type
                    cp_awaddr_type_narrow:coverpoint awaddr[<%=(Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8)-1)):5%>:0] {                    <%for(var i = Math.ceil(Math.log2(obj.wData/8))-1; i >=0; i--){
                        if (Math.ceil(64/(Math.pow(2,i)))< 8){%>
                        bins size_<%=i%>_align_offset_<%=(0).toString(16).padStart((2),'0')%>_<%=((Math.ceil(64/(Math.pow(2,i))))*(Math.pow(2,i))).toString(16).padStart((2),'0')%>={<%for(var m = 0; m<Math.ceil(64/(Math.pow(2,i))); m++){%>'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > i){%><%=m.toString(2).padStart((j-i),'0')%><%j=i+1;}else{%>0<%}}if(m!=((Math.ceil(64/(Math.pow(2,i))))-1)){%>,<%}}%>} iff (awsize == <%=i%>);
                        <%}else{
                        for(var k = 0; k<Math.ceil(64/(Math.pow(2,i))); k=k+8){%>
                        bins size_<%=i%>_align_offset_<%=(k*(Math.pow(2,i))).toString(16).padStart((2),'0')%>_<%=((k+7)*(Math.pow(2,i))).toString(16).padStart((2),'0')%> ={<%for(var m = 0; m<8; m++){%>'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > i){%><%=(k+m).toString(2).padStart((j-i),'0')%><%j=i+1;}else{%>0<%}}if(m!=7){%>,<%}}%>} iff (awsize == <%=i%>); <%}
                       }}%>               
                    }

                    cp_awaddr_type_wide: coverpoint awaddr[<%=(Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8)-1)):5%>:0] {
                    <%for(var i = Math.ceil(Math.log2(obj.wData/8)); i >=Math.ceil(Math.log2(obj.wData/8)); i--){
                        if (Math.ceil(64/(Math.pow(2,i)))< 8){%>
                        bins size_<%=i%>_align_offset_<%=(0).toString(16).padStart((2),'0')%>_<%=((Math.ceil(64/(Math.pow(2,i))))*(Math.pow(2,i))).toString(16).padStart((2),'0')%>={<%for(var m = 0; m<Math.ceil(64/(Math.pow(2,i))); m++){%>'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > i){%><%=m.toString(2).padStart((j-i),'0')%><%j=i+1;}else{%>0<%}}if(m!=((Math.ceil(64/(Math.pow(2,i))))-1)){%>,<%}}%>} iff (awsize == <%=i%>);
                        <%}else{
                        for(var k = 0; k<Math.ceil(64/(Math.pow(2,i))); k=k+8){%>
                        bins size_<%=i%>_align_offset_<%=(k*(Math.pow(2,i))).toString(16).padStart((2),'0')%>_<%=((k+7)*(Math.pow(2,i))).toString(16).padStart((2),'0')%> ={<%for(var m = 0; m<8; m++){%>'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > i){%><%=(k+m).toString(2).padStart((j-i),'0')%><%j=i+1;}else{%>0<%}}if(m!=7){%>,<%}}%>} iff (awsize == <%=i%>); <% }
                        }}%>               
                  }  

              <%if(obj.fnNativeInterface == "ACE-LITE"|| obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    cp_awaddr_type_align:coverpoint awaddr[<%=(Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8)-1)):5%>:0]{
                <%if(Math.ceil(Math.log2(obj.wData/8)) > 6) { %>wildcard <%}%>bins cache_align = {'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8))); j > 6; j--) { %>?<%}%>000000} ; 
                        wildcard bins buswidth_align ={'b<%for(var j = (Math.ceil(Math.log2(obj.wData/8)) > 6)?(Math.ceil(Math.log2(obj.wData/8))):6; j > 0; j--) { if(j > Math.ceil(Math.log2(obj.wData/8))){%>?<%}else{%>0<%}}%>}  ;
                }
              <%}%>
                    cp_tansfer_size_excl: coverpoint tansfer_size_excl_wr{
                       bins excl_transfer_size[] = {1,2,4,8,16,32,64,128}iff(awlock==1) ;
                    }
                    cp_awaddr_type_narrow_excl:coverpoint awaddr[6:0]{
                      <%for(var i = Math.ceil(Math.log2(obj.wData/8))-1; i >=0; i--){%>
                            wildcard bins size_<%=i%>_align ={'b<%for(var j = 6; j > 0; j--) { if(j > i){%>?<%}else{%>0<%}}%>}  iff (excl_size_wr == <%=i%>);<%}%>
                    }
                    cp_awaddr_type_wide_excl:coverpoint awaddr[6:0]{
                      <%for(var i = 6; i >=Math.ceil(Math.log2(obj.wData/8)); i--){%>
                            wildcard bins size_<%=i%>_align ={'b<%for(var j = 6; j > 0; j--) { if(j > i){%>?<%}else{%>0<%}}%>}  iff (excl_size_wr == <%=i%> && awburst==AXIINCR);<%}%>
                      <%for(var i = 6; i >=Math.ceil(Math.log2((obj.wData/8)*2)); i--){%>
                            wildcard bins size_<%=i%>_align_wrap ={'b<%for(var j = 6; j > 0; j--) { if(j > i){%>?<%}else{%>0<%}}%>}  iff (excl_size_wr == <%=i%> && awburst==AXIWRAP);<%}%>
                    }
                    //#Cov.IOAIU.awcache X 
                    awcache_x_cross_wr_narrow_transfer: cross cp_awcache, cross_wr_narrow_transfer;

                    awcache_x_wr_transfer:cross cp_awcache,burst_length {
                     <%if(!(obj.nNativeInterfacePorts > 1)){ %>
                        ignore_bins ignored_awlen_awcache =  binsof(cp_awcache) intersect{'b0000,'b0001} && ! binsof(burst_length.wrap_awlen) intersect{[1:(SYS_nSysCacheline*8/(WXDATA)-1)]} ;//CONC_11492 -single core ignores
                     <% } else {%>
                        ignore_bins ignored_awlen_awcache =  binsof(cp_awcache) intersect{'b0000,'b0001} && ! binsof(burst_length.wrap_maxawlen) intersect{[1:(SYS_nSysCacheline*8/(WXDATA)-1)]} ; //CONC_11492 -multicore core ignores
                     <%}%>

                        } 
                        //removed cross that not reuired since covered in below cross of addr type,narrow and cache
                    //CONC-10970
                    cx_transfersize_exclusive: cross coverpoint_awlock,cp_tansfer_size_excl{
                    	ignore_bins ignored_normal_txn  = binsof(coverpoint_awlock.NORMAL);  
                    }
                    cx_NarrowTxn_Noncoh_exclusive: cross coverpoint_awlock,cp_awaddr_type_narrow_excl iff(awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0){
                    	ignore_bins ignored_normal_txn  = binsof(coverpoint_awlock.NORMAL);  
                    }

                    /////////////Coherent- Wide Write, Cache line size Write//////////////////

                    //burst type covered in cp -burst_length refer COVER_POINT_WA_BURST_LENGTH

                    //#Cover.IOAIU.CohNormalTxns.ww_devnonbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                    //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                    //cx_coh_devnonbuf_wide_txn      : cross cp_awaddr_type_wide,burst_length iff(awcache=='b0000 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1){
                    //}
                    <%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACELITE-E"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                    //Table C3-11 Cache line size transaction constraints -device must be modifiable
                    <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    // cx_coh_devnonbuf_writeclean_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b0000 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {10, 01} && awsnoop == 'b010 && awlock == 0 ){
                    // }// CONC-11546
                    // cx_coh_devnonbuf_writeback_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b0000 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {10, 01} && awsnoop == 'b011 && awlock == 0 ){
                    // }//CONC-11546
                    <%}%>

                    //#Cover.IOAIU.CohNormalTxns.ww_devbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                    //cx_coh_devbuf_wide_txn         : cross cp_awaddr_type_wide,burst_length iff(awcache=='b0001 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1){
                    //}
                    <%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACELITE-E"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                    //Table C3-11 Cache line size transaction constraints -device must be modifiable
                    <%} else if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //AXI_ACE_Update_v3.0 WriteUniqueFullStash, StashOnceShared and StashOnceUnique transactions are subject to the cache line size 
                    //AXI_ACE_Update_v3.0 WriteUniqueFullStash, StashOnceShared and StashOnceUnique AxLOCK and AxBAR must be all zeros 
                    <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     //cx_coh_devbuf_writeclean_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b0001 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {10, 01} && awsnoop == 'b010 && awlock == 0 ){
                     //}// CONC-11546
                     //cx_coh_devbuf_writeback_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b0001 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {10, 01} && awsnoop == 'b011 && awlock == 0 ){
                     //}// CONC-11546
                    <%}%>
                    //#Cover.IOAIU.CohNormalTxns.ww_ncnornonbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_norncnonbuf_wide_txn : cross cp_awaddr_type_wide,burst_length iff(awcache=='b0010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_ncnonbuf_wrunq_ww  : cross cp_awaddr_type_wide , cp_wrunq_awlen, cp_awdomain iff (awcache == 'b0010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_ncnonbuf_wlunq_ww  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    } <%}%>  
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_ncnornonbuf_writeclean_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b0010 && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                     cx_coh_ncnornonbuf_writeback_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b0010 && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                    <%}%>
                    <%if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.ncnornonbuf
                    cx_coh_ncnornonbuf_StashOnceShared  : cross cp_awaddr_type_align ,cp_awdomain ,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0010  && awdomain inside {'b10, 'b01} && awsnoop == 'b1100 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_ncnornonbuf_StashOnceUnique  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0010  && awdomain inside {'b10, 'b01} && awsnoop == 'b1101 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_ncnornonbuf_WriteUniqueFullStash  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0010  && awdomain inside {'b10, 'b01} && awsnoop == 'b1001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_ncnornonbuf_WriteUniquePtlStash  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0010  && awdomain inside {'b10, 'b01} && awsnoop == 'b1000 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                     <%}%>
                    //#Cover.IOAIU.CohNormalTxns.ww_norncbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_norncbuf_wide_txn : cross cp_awaddr_type_wide,burst_length iff(awcache=='b0011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_ncbuf_wrunq_ww  : cross cp_awaddr_type_wide , cp_wrunq_awlen, cp_awdomain iff (awcache == 'b0011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop =='b0000 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_ncbuf_wlunq_ww : cross cp_awaddr_type_align , cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop =='b0001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    } <%}%>   
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_norncbuf_writeclean_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b0011 && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                     cx_coh_norncbuf_writeback_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b0011  && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                    <%}%>
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.ww_norncbuf
                    //#Cover.IOAIU.CohNormalTxnsStash.norncbuf
                    cx_coh_norncbuf_StashOnceShared  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0011  && awdomain inside {'b10, 'b01} && awsnoop == 'b1100 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_norncbuf_StashOnceUnique  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0011  && awdomain inside {'b10, 'b01} && awsnoop == 'b1101 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_norncbuf_WriteUniqueFullStash  : cross cp_awaddr_type_align, cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0011  && awdomain inside {'b10, 'b01} && awsnoop == 'b1001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_norncbuf_WriteUniquePtlStash  : cross cp_awaddr_type_align, cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0011  && awdomain inside {'b10, 'b01} && awsnoop == 'b1000 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                     <%}%> 
                    //#Cover.IOAIU.CohNormalTxns.ww_wtralloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wtralloc_wide_txn : cross cp_awaddr_type_wide,burst_length iff(awcache=='b0110 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wtralloc_wrunq_ww : cross cp_awaddr_type_wide ,cp_wrunq_awlen, cp_awdomain iff (awcache == 'b0110 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wtralloc_wlunq_ww : cross cp_awaddr_type_align ,  cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0110 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    } <%}%>
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.ww_wtralloc
                    cx_coh_wtralloc_StashOnceShared  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0110  && awdomain inside {'b10, 'b01} && awsnoop == 'b1100 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wtralloc_StashOnceUnique  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0110  && awdomain inside {'b10, 'b01} && awsnoop == 'b1101 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wtralloc_WriteUniqueFullStash  : cross cp_awaddr_type_align , cp_awdomain ,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0110  && awdomain inside {'b10, 'b01} && awsnoop == 'b1001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wtralloc_WriteUniquePtlStash  : cross cp_awaddr_type_align , cp_awdomain ,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0110   && awdomain inside {'b10, 'b01} && awsnoop == 'b1000 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                     <%}%>
                    //#Cover.IOAIU.CohNormalTxns.ww_wtwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wtwalloc_wide_txn : cross cp_awaddr_type_wide,burst_length iff(awcache=='b1010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wtwalloc_wrunq_ww : cross cp_awaddr_type_wide ,cp_wrunq_awlen, cp_awdomain iff (awcache == 'b1010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wtwalloc_wlunq_ww : cross cp_awaddr_type_align ,  cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    } <%}%>
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_wtwalloc_writeclean_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b1010  && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                     cx_coh_wtwalloc_writeback_widetxn  : cross cp_awaddr_type_wide, burst_type, cp_awdomain iff (awcache == 'b1010  && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                    <%}%>
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.ww_wtwalloc
                    //#Cover.IOAIU.CohNormalTxnsStash.wtwalloc
                    cx_coh_wtwalloc_StashOnceShared  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1010  && awdomain inside {'b10, 'b01} && awsnoop == 'b1100 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wtwalloc_StashOnceUnique  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1010  && awdomain inside {'b10, 'b01} && awsnoop == 'b1101 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wtwalloc_WriteUniqueFullStash  : cross cp_awaddr_type_align, cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1010  && awdomain inside {'b10, 'b01} && awsnoop == 'b1001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wtwalloc_WriteUniquePtlStash  : cross cp_awaddr_type_align, cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1010   && awdomain inside {'b10, 'b01} && awsnoop == 'b1000 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                          // #Cover.IOAIU.CohNormalTxnsAtomics.ww_wtwalloc
                        cx_coh_wtwalloc_atmstr  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1010  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b01 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wtwalloc_atmld  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1010  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b10 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wtwalloc_atmswap  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1010  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110000 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wtwalloc_atmcomp  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1010  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110001 ){ //trxn is align to half buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }


                     <%}%>
                    //#Cover.IOAIU.CohNormalTxns.ww_wtrwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wtrwalloc_wide_txn : cross cp_awaddr_type_wide,burst_length iff(awcache=='b1110 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wtrwalloc_wrunq_ww : cross cp_awaddr_type_wide , cp_wrunq_awlen, cp_awdomain iff (awcache == 'b1110 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wtrwalloc_wlunq_ww : cross cp_awaddr_type_align ,  cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1110 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_wtrwalloc_writeclean_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b1110  && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                     cx_coh_wtrwalloc_writeback_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b1110 && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                    <%}%>
                    <%if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.ww_wtrwalloc
                    cx_coh_wtrwalloc_StashOnceShared  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1110  && awdomain inside {'b10, 'b01} && awsnoop == 'b1100 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wtrwalloc_StashOnceUnique  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1110  && awdomain inside {'b10, 'b01} && awsnoop == 'b1101 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wtrwalloc_WriteUniqueFullStash  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1110  && awdomain inside {'b10, 'b01} && awsnoop == 'b1001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wtrwalloc_WriteUniquePtlStash  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1110  && awdomain inside {'b10, 'b01} && awsnoop == 'b1000 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                          // #Cover.IOAIU.CohNormalTxnsAtomics.ww_wtrwalloc
                        cx_coh_wtrwalloc_atmstr  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1110  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b01 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wtrwalloc_atmld  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1110  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b10 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wtrwalloc_atmswap  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1110  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110000 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wtrwalloc_atmcomp  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1110  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110001 ){ //trxn is align to half buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }

                     <%}%>
                    //#Cover.IOAIU.CohNormalTxns.ww_wbralloc
                    //#Cover.IOAIU.CohNormalTxnsStash.wbralloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wbralloc_wide_txn : cross cp_awaddr_type_wide,burst_length iff(awcache=='b0111 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wbralloc_wrunq_ww : cross cp_awaddr_type_wide , cp_wrunq_awlen , cp_awdomain iff (awcache == 'b0111 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbralloc_wlunq_ww       : cross cp_awaddr_type_align , cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0111 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_wbralloc_writeclean_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b0111  && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                     cx_coh_wbralloc_writeback_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b0111 && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                    <%}%>
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.ww_wbralloc
                    cx_coh_wbralloc_StashOnceShared  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0111  && awdomain inside {'b10, 'b01} && awsnoop == 'b1100 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wbralloc_StashOnceUnique  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0111  && awdomain inside {'b10, 'b01} && awsnoop == 'b1101 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wbralloc_WriteUniqueFullStash  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0111  && awdomain inside {'b10, 'b01} && awsnoop == 'b1001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wbralloc_WriteUniquePtlStash  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b0111  && awdomain inside {'b10, 'b01} && awsnoop == 'b1000 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                         // #Cover.IOAIU.CohNormalTxnsAtomics.ww_wbralloc
                        cx_coh_wbralloc_atmstr  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b0111  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b01 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbralloc_atmld  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b0111  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b10 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbralloc_atmswap  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b0111  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110000 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbralloc_atmcomp  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b0111  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110001 ){ //trxn is align to half buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }

                     <%}%>
                    //#Cover.IOAIU.CohNormalTxns.ww_wbwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wbwalloc_wide_txn       : cross cp_awaddr_type_wide,burst_length iff(awcache=='b1011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE" ||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wbwalloc_wrunq_ww       : cross cp_awaddr_type_wide ,cp_wrunq_awlen , cp_awdomain iff (awcache == 'b1011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbwalloc_wlunq_ww       : cross cp_awaddr_type_align , cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_wbwalloc_writeclean_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b1011  && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                     cx_coh_wbwalloc_writeback_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b1011  && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                    <%}%>
                    <%if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.ww_wbwalloc
                    cx_coh_wbwalloc_StashOnceShared  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1011  && awdomain inside {'b10, 'b01} && awsnoop == 'b1100 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wbwalloc_StashOnceUnique  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1011  && awdomain inside {'b10, 'b01} && awsnoop == 'b1101 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wbwalloc_WriteUniqueFullStash  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1011  && awdomain inside {'b10, 'b01} && awsnoop == 'b1001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wbwalloc_WriteUniquePtlStash  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1011  && awdomain inside {'b10, 'b01} && awsnoop == 'b1000 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                         // #Cover.IOAIU.CohNormalTxnsAtomics.ww_wbwalloc
                        cx_coh_wbwalloc_atmstr  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1011  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b01 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbwalloc_atmld  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1011  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b10 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbwalloc_atmswap  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1011  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110000 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbwalloc_atmcomp  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1011  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110001 ){ //trxn is align to half buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                     <%}%>
                    //#Cover.IOAIU.CohNormalTxns.ww_wbrwalloc
                    //#Cover.IOAIU.CohNormalTxnsStash.wbrwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wbrwalloc_wide_txn      : cross cp_awaddr_type_wide,burst_length iff(awcache=='b1111 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wbrwalloc_wrunq_ww      : cross cp_awaddr_type_wide , cp_wrunq_awlen , cp_awdomain iff (awcache == 'b1111 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbrwalloc_wlunq_ww      : cross cp_awaddr_type_align , cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1111 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b0001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_wbrwalloc_writeclean_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b1111  && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                     cx_coh_wbrwalloc_writeback_widetxn  : cross cp_awaddr_type_wide , burst_type, cp_awdomain iff (awcache == 'b1111  && awsize == <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                     }
                    <%}%>
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.ww_wbrwalloc
                    cx_coh_wbrwalloc_StashOnceShared  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1111  && awdomain inside {'b10, 'b01} && awsnoop == 'b1100 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wbrwalloc_StashOnceUnique  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1111  && awdomain inside {'b10, 'b01} && awsnoop == 'b1101 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wbrwalloc_WriteUniqueFullStash  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1111  && awdomain inside {'b10, 'b01} && awsnoop == 'b1001 && awlock == 0 && ((awlen+1) * (2**awsize) == SYS_nSysCacheline)){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                    cx_coh_wbrwalloc_WriteUniquePtlStash  : cross cp_awaddr_type_align ,cp_awdomain,burst_type,cp_cachelinetxn_awlen iff (awcache == 'b1111  && awdomain inside {'b10, 'b01} && awsnoop == 'b1000 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        }
                       // #Cover.IOAIU.CohNormalTxnsAtomics.ww_wbrwalloc
                        cx_coh_wbrwalloc_atmstr  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1111  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b01 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbrwalloc_atmld  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1111  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b10 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbrwalloc_atmswap  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1111  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110000 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }
                    cx_coh_wbrwalloc_atmcomp  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1111  && awdomain inside {'b10, 'b01} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110001 ){ //trxn is align to half buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,3};  
                    }

                    
                     <%}%>


                    /////////////Coherent- Narrow Write////////////

                    //#Cover.IOAIU.CohNormalTxns.nw_devnonbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                    //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                    //cx_coh_devnonbuf_narrow_txn      : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type iff(awcache=='b0000 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1){
            //ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    //}
                    <%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    //Table C3-11 Cache line size transaction constraints -device must be modifiable
                    <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    // cx_coh_devnonbuf_writeclean_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0000  && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {10, 01} && awsnoop == 'b010 && awlock == 0 ){
                    // ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                    // }
                    // cx_coh_devnonbuf_writeback_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0000  && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {10, 01} && awsnoop == 'b011 && awlock == 0 ){
                    // ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                    // }
                    <%}%>
                    //#Cover.IOAIU.CohNormalTxns.nw_devbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                    //cx_coh_devbuf_narrow_txn         : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type iff(awcache=='b0001 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1){
            //ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    //}
                    <%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    //Table C3-11 Cache line size transaction constraints -device must be modifiable
                    <%}%>
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    // cx_coh_devbuf_writeclean_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0001 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {10, 01} && awsnoop == 'b010 && awlock == 0 ){
                    // ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                    // }
                    // cx_coh_devbuf_writeback_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0001  && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {10, 01} && awsnoop == 'b011 && awlock == 0 ){
                    // ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                    // }
                    <%}%>
                    //#Cover.IOAIU.CohNormalTxns.nw_ncnornonbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_norncnonbuf_narrow_txn    : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type iff(awcache=='b0010 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_ncnonbuf_nw      : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0010 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 0 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.nw_ncnornonbuf
                    
                     <%}%> 
                    //#Cover.IOAIU.CohNormalTxns.nw_norncbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_norncbuf_narrow_txn       : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type iff(awcache=='b0011 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_ncbuf_nw      : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0011 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 0 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_norncbuf_writeclean_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0011 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }
                     cx_coh_norncbuf_writeback_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0011 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }
                    <%}%>
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.nw_norncbuf
                    
                    <%}%> 
                    //#Cover.IOAIU.CohNormalTxns.nw_wtralloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wtralloc_narrow_txn       : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type iff(awcache=='b0110 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wtralloc_nw      : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0110 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 0 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%> 
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.nw_wtralloc
                    
                     <%}%> 
                    //#Cover.IOAIU.CohNormalTxns.nw_wtwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wtwalloc_narrow_txn       : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type iff(awcache=='b1010 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wtwalloc_nw      : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1010 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 0 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_wtwalloc_writeclean_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1010 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }
                     cx_coh_wtwalloc_writeback_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1010  && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }
                    <%}%>
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.nw_wtwalloc
                    
                     <%}%> 
                    //#Cover.IOAIU.CohNormalTxns.nw_wtrwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wtrwalloc_narrow_txn      : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type iff(awcache=='b1110 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wtrwalloc_nw      : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1110 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 0 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_wtrwalloc_writeclean_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1110 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }
                     cx_coh_wtrwalloc_writeback_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1110  && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }
                    <%}%>
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.nw_wtrwalloc
                    
                     <%}%> 
                    //#Cover.IOAIU.CohNormalTxns.nw_wbralloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wbralloc_narrow_txn       : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type iff(awcache=='b0111 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE" ||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wbralloc_nw      : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0111 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 0 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_wbralloc_writeclean_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0111 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }
                     cx_coh_wbralloc_writeback_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b0111  && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }
                    <%}%>
                    <%if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.nw_wbralloc
                    
                     <%}%> 
                    //#Cover.IOAIU.CohNormalTxns.nw_wbwalloc
                    //#Cover.IOAIU.CohNormalTxnsStash.wbwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wbwalloc_narrow_txn       : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type iff(awcache=='b1011 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wbwalloc_nw      : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1011 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 0 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_wbwalloc_writeclean_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1011 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }
                     cx_coh_wbwalloc_writeback_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1011 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }

                    <%}%>
                    <%if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.nw_wbwalloc
                   
                     <%}%> 
                    //#Cover.IOAIU.CohNormalTxns.nw_wbrwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_coh_wbrwalloc_narrow_txn      : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type iff(awcache=='b1111 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==1 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_coh_wbrwalloc_nw      : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1111 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 0 && awlock == 0){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%>  
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_coh_wbrwalloc_writeclean_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1111 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b010 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }
                     cx_coh_wbrwalloc_writeback_narrowtxn  : cross cp_awaddr_type_narrow , burst_type, cp_awdomain iff (awcache == 'b1111 && awlen==0 && awsize < <%=Math.ceil(Math.log2(obj.wData/8))%>  && awdomain inside {'b10, 'b01} && awsnoop == 'b011 && awlock == 0 ){
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {0,3};  
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                     }

                    <%}%>
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.CohNormalTxnsStash.nw_wbrwalloc
                    
                     <%}%> 

                    /////////////Noncoherent- Wide Write,, Cacheline Size Writes////////////

                    //burst type covered in cp -burst_length refer COVER_POINT_WA_BURST_LENGTH
                    //#Cover.IOAIU.NonCohNormalTxns.ww_devnonbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_devnonbuf_wide_txn      : cross cp_awaddr_type_wide,burst_length,cp_tgt_type iff(awcache=='b0000 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                        ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
  }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_devnonbuf_ww      : cross cp_awaddr_type_wide,burst_length,cp_awdomain,cp_tgt_type iff(awcache=='b0000 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 0 && awsnoop == 0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                        ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
                  	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,1,2};  
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    //Table C3-13 WriteBack and WriteClean transaction constraint- awcache- modifiable
                    <%}%>
                    //#Cover.IOAIU.NonCohExcTxns.ww_devnonbuf
                    //exclusive address is transfer size aligned
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_devnonbuf_wide_txn_excl : cross cp_awaddr_type_wide_excl,cp_tgt_type iff(awcache=='b0000 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==1){
                    ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
 }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                    cx_noncoh_devnonbuf_ww_excl      : cross cp_awaddr_type_wide_excl,cp_awdomain,cp_tgt_type iff(awcache=='b0000 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 1 && awsnoop == 0){
                 ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,1,2};  
                    }<%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.ww_devbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_devbuf_wide_txn         : cross cp_awaddr_type_wide,burst_length,cp_tgt_type iff(awcache=='b0001 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                        ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
 }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_devbuf_ww         : cross cp_awaddr_type_wide,burst_length,cp_awdomain,cp_tgt_type iff(awcache=='b0001 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 0 && awsnoop == 0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                        ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
	                ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,1,2};  
                    }<%}%> 
                     <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    //Table C3-13 WriteBack and WriteClean transaction constraint- awcache- modifiable
                    <%}%>
                    //#Cover.IOAIU.NonCohExcTxns.ww_devbuf
                    //exclusive address is transfer size aligned
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_devbuf_wide_txn_excl    : cross cp_awaddr_type_wide_excl,cp_tgt_type iff(awcache=='b0001 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==1){
                    ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
 }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_devbuf_ww_excl         : cross cp_awaddr_type_wide_excl,cp_awdomain,cp_tgt_type iff(awcache=='b0001 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 1 && awsnoop == 0){
                 ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,1,2};  
                    }<%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.ww_ncnornonbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_norncnonbuf_wide_txn    : cross cp_awaddr_type_wide,burst_length,cp_tgt_type iff(awcache=='b0010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_ncnonbuf_ww    : cross cp_awaddr_type_wide,burst_length,cp_awdomain,cp_tgt_type iff(awcache=='b0010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 0 && awsnoop == 0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2};  
                    }<%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_ncnornonbuf_writeclean_widetxn : cross cp_awaddr_type_wide ,  burst_type , cp_tgt_type iff(awcache=='b0010 &&  awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                     }
                     cx_noncoh_ncnornonbuf_writeback_widetxn :  cross cp_awaddr_type_wide ,  burst_type , cp_tgt_type iff(awcache=='b0010 &&  awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                     }
                    <%}%>
                    //#Cover.IOAIU.NonCohExcTxns.ww_ncnornonbuf
                    //exclusive address is transfer size aligned
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_norncnonbuf_wide_txn_excl    : cross cp_awaddr_type_wide_excl,cp_tgt_type iff(awcache=='b0010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==1){
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_ncnonbuf_ww_excl    : cross cp_awaddr_type_wide_excl,cp_awdomain,cp_tgt_type iff(awcache=='b0010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 1 && awsnoop == 0){
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2};  
                    }<%}%>
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.NonCohNormalTxnsStash.ww_ncnornonbuf
                    
                    <%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.ww_norncbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_norncbuf_wide_txn       : cross cp_awaddr_type_wide,burst_length,cp_tgt_type iff(awcache=='b0011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_ncbuf_ww    : cross cp_awaddr_type_wide,burst_length,cp_awdomain,cp_tgt_type iff(awcache=='b0011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 0 && awsnoop == 0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2};  
                    }<%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_norncbuf_writeclean_widetxn : cross cp_awaddr_type_wide , burst_type , cp_tgt_type iff(awcache=='b0011 &&  awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                     }
                     cx_noncoh_norncbuf_writeback_widetxn :  cross cp_awaddr_type_wide ,  burst_type , cp_tgt_type iff(awcache=='b0011 &&  awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                     }
                    <%}%>
                    //#Cover.IOAIU.NonCohExcTxns.ww_norncbuf
                    //exclusive address is transfer size aligned
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_norncbuf_wide_txn_excl       : cross cp_awaddr_type_wide_excl,cp_tgt_type iff(awcache=='b0011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==1){
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_ncbuf_ww_excl    : cross cp_awaddr_type_wide_excl,cp_awdomain,cp_tgt_type iff(awcache=='b0011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 1 && awsnoop == 0){
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2};  
                    }<%}%> 
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.NonCohNormalTxnsStash.ww_norncbuf
                    
                    <%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.ww_wtralloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wtralloc_wide_txn       : cross cp_awaddr_type_wide,burst_length,cp_tgt_type iff(awcache=='b0110 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                    cx_noncoh_wtralloc_ww    : cross cp_awaddr_type_wide,burst_length,cp_awdomain,cp_tgt_type iff(awcache=='b0110 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 0 && awsnoop == 0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    } <%}%> 
                    //#Cover.IOAIU.NonCohNormalTxns.ww_wtwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wtwalloc_wide_txn       : cross cp_awaddr_type_wide,burst_length,cp_tgt_type iff(awcache=='b1010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                    cx_noncoh_wtwalloc_ww    : cross cp_awaddr_type_wide,burst_length,cp_awdomain,cp_tgt_type iff(awcache=='b1010 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 0 && awsnoop == 0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    } <%}%>  
                     <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_wtwalloc_writeclean_widetxn : cross cp_awaddr_type_wide ,  burst_type , cp_tgt_type iff(awcache=='b1010  && awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                     }
                     cx_noncoh_wtwalloc_writeback_widetxn :  cross cp_awaddr_type_wide , burst_type , cp_tgt_type iff(awcache=='b1010  && awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                     }
                    <%}%>
                    <%if(obj.fnNativeInterface == "ACELITE-E") {%>
                    
                    //#Cover.IOAIU.NonCohNormalTxnsAtomics.ww_wtwalloc
                    //
                    cx_noncoh_wtwalloc_atmstr  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1010  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b01 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wtwalloc_atmld  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1010  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b10 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wtwalloc_atmswap  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1010  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110000 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wtwalloc_atmcomp  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1010  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110001 ){ //trxn is align to half buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    <%}%>
                    
                    //#Cover.IOAIU.NonCohNormalTxns.ww_wtrwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wtrwalloc_wide_txn      : cross cp_awaddr_type_wide,burst_length,cp_tgt_type iff(awcache=='b1110 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_wtrwalloc_ww    : cross cp_awaddr_type_wide,burst_length,cp_awdomain,cp_tgt_type iff(awcache=='b1110 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 0 && awsnoop == 0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    } <%}%>  
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_wtrwalloc_writeclean_widetxn : cross cp_awaddr_type_wide , burst_type , cp_tgt_type iff(awcache=='b1110  && awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                     }
                     cx_noncoh_wtrwalloc_writeback_widetxn :  cross cp_awaddr_type_wide ,  burst_type , cp_tgt_type iff(awcache=='b1110 && awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                     }
                    <%}%>
                    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.NonCohNormalTxnsStash.ww_wtrwalloc
                    //#Cover.IOAIU.NonCohNormalTxnsAtomics.ww_wtrwalloc
                    //#Cover.IOAIU.CohNormalTxnsStash.wtrwalloc
                    cx_noncoh_wtrwalloc_atmstr  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1110  && awdomain inside {'b00} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b01 ){ 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wtrwalloc_atmld  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1110  && awdomain inside {'b00} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b10 ){ 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wtrwalloc_atmswap  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1110  && awdomain inside {'b00} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110000 ){ 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wtrwalloc_atmcomp  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1110  && awdomain inside {'b00} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110001 ){ 
                	ignore_bins ignore_noncoh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                     <%}%> 
                    //#Cover.IOAIU.NonCohNormalTxns.ww_wbralloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wbralloc_wide_txn       : cross cp_awaddr_type_wide,burst_length,cp_tgt_type iff(awcache=='b0111 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_wbralloc_ww    : cross cp_awaddr_type_wide,burst_length,cp_awdomain,cp_tgt_type iff(awcache=='b0111 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 0 && awsnoop == 0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_wbralloc_writeclean_widetxn : cross cp_awaddr_type_wide ,  burst_type , cp_tgt_type iff(awcache=='b0111  && awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                     }
                     cx_noncoh_wbralloc_writeback_widetxn :  cross cp_awaddr_type_wide ,  burst_type , cp_tgt_type iff(awcache=='b0111  && awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                     }
                    <%}%>
                     <%if(obj.fnNativeInterface == "ACELITE-E") {%>
                    
                    //#Cover.IOAIU.NonCohNormalTxnsAtomics.ww_wbralloc
                    //
                    cx_noncoh_wbralloc_atmstr  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b0111  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b01 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wbralloc_atmld  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b0111  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b10 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wbralloc_atmswap  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b0111  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110000 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wbralloc_atmcomp  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b0111  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110001 ){ //trxn is align to half buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    <%}%> 
                     
                    //#Cover.IOAIU.NonCohNormalTxns.ww_wbwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wbwalloc_wide_txn       : cross cp_awaddr_type_wide,burst_length,cp_tgt_type iff(awcache=='b1011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_wbwalloc_ww    : cross cp_awaddr_type_wide,burst_length,cp_awdomain,cp_tgt_type iff(awcache=='b1011 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 0 && awsnoop == 0 && awsnoop == 0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }<%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_wbwalloc_writeclean_widetxn : cross cp_awaddr_type_wide , burst_type , cp_tgt_type iff(awcache=='b1011  && awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                     }
                     cx_noncoh_wbwalloc_writeback_widetxn :  cross cp_awaddr_type_wide ,  burst_type , cp_tgt_type iff(awcache=='b1011  && awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                     }
                    <%}%>
                    <%if(obj.fnNativeInterface == "ACELITE-E") {%>
                    
                    //#Cover.IOAIU.NonCohNormalTxnsAtomics.ww_wbwalloc
                    //
                    cx_noncoh_wbwalloc_atmstr  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1011  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b01 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wbwalloc_atmld  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1011  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b10 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wbwalloc_atmswap  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1011  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110000 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wbwalloc_atmcomp  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1011  && awdomain inside {'b00,'b11} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110001 ){ //trxn is align to half buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    <%}%> 
                     
                    //#Cover.IOAIU.NonCohNormalTxns.ww_wbrwalloc
                    //
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wbrwalloc_wide_txn      : cross cp_awaddr_type_wide,burst_length,cp_tgt_type iff(awcache=='b1111 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_wbrwalloc_ww    : cross cp_awaddr_type_wide,burst_length,cp_awdomain,cp_tgt_type iff(awcache=='b1111 && awsize==<%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain inside {'b00, 'b11} && awlock == 0 && awsnoop == 0){
                        ignore_bins  cross_4KB_boundary = binsof(burst_length) intersect {[(4096/<%=obj.wData/8%>-1) : 255]};
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }<%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_wbrwalloc_writeclean_widetxn : cross cp_awaddr_type_wide ,  burst_type , cp_tgt_type iff(awcache=='b1111  && awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                     }
                     cx_noncoh_wbrwalloc_writeback_widetxn :  cross cp_awaddr_type_wide ,  burst_type , cp_tgt_type iff(awcache=='b1111  && awsize== <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                     }
                    <%}%>
                    <%if(obj.fnNativeInterface == "ACELITE-E") {%>
                    //#Cover.IOAIU.NonCohNormalTxnsStash.ww_wbrwalloc
                    
                    //#Cover.IOAIU.NonCohNormalTxnsAtomics.ww_wbrwalloc
                    //
                    cx_noncoh_wbrwalloc_atmstr  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1111  && awdomain inside {'b00} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b01 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wbrwalloc_atmld  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1111  && awdomain inside {'b00} && awsnoop == 'b0000 && awlock == 0 && awatop[5:4]=='b10 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wbrwalloc_atmswap  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1111  && awdomain inside {'b00} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110000 ){ //trxn is align to buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    cx_noncoh_wbrwalloc_atmcomp  : cross cp_awaddr_type_align ,cp_awdomain iff (awcache == 'b1111  && awdomain inside {'b00} && awsnoop == 'b0000 && awlock == 0 && awatop== 6'b110001 ){ //trxn is align to half buswidth
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                    }
                    <%}%> 

                    /////////////Cacheline size Write////////////

                   //#Cover.IOAIU.EvictNormal

                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                   cx_Evict_normal : cross cp_awaddr_type_align , cp_awdomain,burst_type,cp_awcache,cp_cachelinetxn_awlen iff(awlock==0 && awdomain inside {'b10, 'b01}  && awsnoop=='b100 &&  ((awlen+1) * (2**awsize) == SYS_nSysCacheline)) {
                   ignore_bins ignore_awdomain  = binsof(cp_awdomain)intersect {'b00,'b11};             
                    }<%}%> 

                    //#Cover.IOAIU.WriteEvictNormal

                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                   cx_WriteEvict_normal : cross cp_awaddr_type_align , cp_awdomain,burst_type,cp_awcache,cp_cachelinetxn_awlen iff(awlock==0 && awdomain inside {'b00,'b10, 'b01}  && awsnoop=='b101 &&  ((awlen+1) * (2**awsize) == SYS_nSysCacheline)) {
                   ignore_bins ignore_awdomain  = binsof(cp_awdomain)intersect {'b11};
                    }<%}%> 

                    /////////////Noncoherent- Narrow Write////////////

                    //#Cover.IOAIU.NonCohNormalTxns.nw_devnonbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_devnonbuf_narrow_txn      : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_tgt_type iff(awcache=='b0000 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                         ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
  ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                    cx_noncoh_devnonbuf_nw      : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b0000 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==0 && awdomain inside {'b00,'b11} && awsnoop==0) {
                 ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,1,2};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst);  
                    }<%}%>  
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    //Table C3-13 WriteBack and WriteClean transaction constraint
                    <%}%>
                    //#Cover.IOAIU.NonCohExcTxns.nw_devnonbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_devnonbuf_narrow_txn_excl  : cross cp_awaddr_type_narrow_excl,burst_type,cp_tgt_type iff(awcache=='b0000 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==1){
                          ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
 ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_devnonbuf_nw_excl      : cross cp_awaddr_type_narrow_excl,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b0000 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==1 && awdomain inside {'b00,'b11} && awsnoop==0) {
                       ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
  ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst);  
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,1,2};  
                    }<%}%>
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    //#Cover.IOAIU.NonCohNormalTxns.nw_devbuf
                    cx_noncoh_devbuf_narrow_txn         : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_tgt_type iff(awcache=='b0001 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                         ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
  ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_devbuf_nw         : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_awdomain, cp_tgt_type iff(awcache=='b0001 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==0 && awdomain inside {'b00,'b11}) {
                 ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,1,2};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    //Table C3-13 WriteBack and WriteClean transaction constraint
                    <%}%>
                    //#Cover.IOAIU.NonCohExcTxns.nw_devbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_devbuf_narrow_txn_excl         : cross cp_awaddr_type_narrow_excl,burst_type,cp_tgt_type iff(awcache=='b0001 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==1){
                         ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
  ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_devbuf_nw_excl         : cross cp_awaddr_type_narrow_excl,burst_type,cp_awdomain, cp_tgt_type iff(awcache=='b0001 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==1 && awdomain inside {'b00,'b11} && awsnoop == 0) {
                         ignore_bins ignore_dmi_tgt=binsof(cp_tgt_type)intersect {DMI};// CONC-11546
  ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {0,1,2};  
                    }<%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.nw_ncnornonbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_norncnonbuf_narrow_txn    : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_tgt_type iff(awcache=='b0010 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_ncnonbuf_nw     : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b0010 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==0 && awdomain inside {'b00,'b11} && awsnoop == 0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0,} 
                    }<%}%> 
                     <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_ncnornonbuf_writeclean_Narrowtxn : cross cp_awaddr_type_narrow ,  burst_type , cp_tgt_type iff(awcache=='b0010 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                     cx_noncoh_ncnornonbuf_writeback_Narrowtxn : cross cp_awaddr_type_narrow ,  burst_type , cp_tgt_type iff(awcache=='b0010  && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                    <%}%>
                    //#Cover.IOAIU.NonCohExcTxns.nw_ncnornonbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_norncnonbuf_narrow_txn_excl    : cross cp_awaddr_type_narrow_excl,burst_type,cp_tgt_type iff(awcache=='b0010 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==1){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_ncnonbuf_nw_excl    : cross cp_awaddr_type_narrow_excl,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b0010 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==1 && awdomain inside {'b00,'b11} && awsnoop == 0) {
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2};  
                    }<%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.nw_norncbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_norncbuf_narrow_txn       : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_tgt_type iff(awcache=='b0011 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_ncbuf_nw     : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b0011 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==0 && awdomain inside {'b00,'b11} && awsnoop == 0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_norncbuf_writeclean_Narrowtxn : cross cp_awaddr_type_narrow ,  burst_type , cp_tgt_type iff(awcache=='b0011 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                     cx_noncoh_norncbuf_writeback_Narrowtxn : cross cp_awaddr_type_narrow , burst_type , cp_tgt_type iff(awcache=='b0011 &&  awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                    <%}%>
                    //#Cover.IOAIU.NonCohExcTxns.nw_norncbuf
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_norncbuf_narrow_txn_excl       : cross cp_awaddr_type_narrow_excl,burst_type,cp_tgt_type iff(awcache=='b0011 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==1){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_ncbuf_nw_excl     : cross cp_awaddr_type_narrow_excl,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b0011 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==1 && awdomain inside {'b00,'b11} && awsnoop == 0) {
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2};  
                    } <%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.nw_wtralloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wtralloc_narrow_txn       : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_tgt_type iff(awcache=='b0110 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                    cx_noncoh_wtralloc_nw     : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b0110 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==0 && awdomain inside {'b00,'b11} && awsnoop == 0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.nw_wtwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wtwalloc_narrow_txn       : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_tgt_type iff(awcache=='b1010 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    //Table C3-3 AxCACHE and AxDOMAIN signal combinations 
                    cx_noncoh_wtwalloc_nw     : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b1010 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==0 && awdomain inside {'b00,'b11} && awsnoop == 0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_wtwalloc_writeclean_Narrowtxn : cross cp_awaddr_type_narrow ,  burst_type , cp_tgt_type iff(awcache=='b1010 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                     cx_noncoh_wtwalloc_writeback_Narrowtxn : cross cp_awaddr_type_narrow ,  burst_type , cp_tgt_type iff(awcache=='b1010 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                    <%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.nw_wtrwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wtrwalloc_narrow_txn      : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_tgt_type iff(awcache=='b1110 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_wtrwalloc_nw     : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b1110 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==0 && awdomain inside {'b00,'b11} && awsnoop == 0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_wtrwalloc_writeclean_Narrowtxn : cross cp_awaddr_type_narrow , burst_type , cp_tgt_type iff(awcache=='b1110 &&  awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                     cx_noncoh_wtrwalloc_writeback_Narrowtxn : cross cp_awaddr_type_narrow ,  burst_type , cp_tgt_type iff(awcache=='b1110 &&  awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                    <%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.nw_wbralloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wbralloc_narrow_txn       : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_tgt_type iff(awcache=='b0111 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_wbralloc_nw     : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b0111 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==0 && awdomain inside {'b00,'b11} && awsnoop == 0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%> 
                     <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_wbralloc_writeclean_Narrowtxn : cross cp_awaddr_type_narrow ,  burst_type , cp_tgt_type iff(awcache=='b0111 &&  awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                     cx_noncoh_wbralloc_writeback_Narrowtxn : cross cp_awaddr_type_narrow ,  burst_type , cp_tgt_type iff(awcache=='b0111 &&  awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                    <%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.nw_wbwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wbwalloc_narrow_txn       : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_tgt_type iff(awcache=='b1011 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_wbwalloc_nw     : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b1011 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==0 && awdomain inside {'b00,'b11} && awsnoop == 0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%> 
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_wbwalloc_writeclean_Narrowtxn : cross cp_awaddr_type_narrow ,  burst_type , cp_tgt_type iff(awcache=='b1011 &&  awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                     cx_noncoh_wbwalloc_writeback_Narrowtxn : cross cp_awaddr_type_narrow ,  burst_type , cp_tgt_type iff(awcache=='b1011 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                    <%}%>
                    //#Cover.IOAIU.NonCohNormalTxns.nw_wbrwalloc
                    <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                    cx_noncoh_wbrwalloc_narrow_txn      : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_tgt_type iff(awcache=='b1111 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && isCoherent==0 && awlock==0){
                          ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    }<%} else if(obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACELITE-E") {%>
                    cx_noncoh_wbrwalloc_nw     : cross cp_awaddr_type_narrow,cp_wr_narrow_length,burst_type,cp_awdomain,cp_tgt_type iff(awcache=='b1111 && awlen==0 && awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awlock==0 && awdomain inside {'b00,'b11} && awsnoop == 0) {
                	ignore_bins ignore_coh_domain  = binsof(cp_awdomain)intersect {1,2,3};  
                        ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //arlen=0, 
                    } <%}%>
                     <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                     cx_noncoh_wbrwalloc_writeclean_Narrowtxn : cross cp_awaddr_type_narrow , burst_type , cp_tgt_type iff(awcache=='b1111 &&  awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b010  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                     cx_noncoh_wbrwalloc_writeback_Narrowtxn : cross cp_awaddr_type_narrow ,  burst_type , cp_tgt_type iff(awcache=='b1111 &&  awsize< <%=Math.ceil(Math.log2(obj.wData/8))%> && awdomain==0 && awsnoop == 'b011  && awlock==0){
                         ignore_bins ignored_burst_type  = binsof(burst_type.wrap_burst); //awlen=0, 
                     }
                    <%}%>
        endgroup 
        covergroup <%if ((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%}else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%>ace_lite_e<%}%>_wr_excl_resp_core<%=port%>;
                //#Cover.IOAIU.ExcWrite.BResp
                cp_bresp: coverpoint bresp{
                    bins ok = {0} iff(awlock==1);
                    bins exok = {1} iff (awlock==1);
                }
        endgroup

        <%if(obj.nNativeInterfacePorts == 1){%>
            //#Cover.IOAIU.InterleaveAddr
            covergroup rd_interleave_cg;
                cp_rd_resp_interleaved_when_enabled : coverpoint rd_resp_interleaved {
                    bins interleaved = {1};
                }
            endgroup : rd_interleave_cg
        <%}%>

        <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5") { %>
            //#Cov.IOAIU.AXI.ATOP
            //#Cov.IOAIU.AXI.AWATOP
            //#Cov.IOAIU.ATOMIC
            <%var nativeinterface;
                if(obj.fnNativeInterface == "ACELITE-E")
                   nativeinterface = "ACELITE_E";
                else
                   nativeinterface = "AXI5";
            %>
            covergroup <%=nativeinterface%>_atm_core<%=port%>;
             
                <%=nativeinterface%>_atop : coverpoint m_scb_txn.m_ace_write_addr_pkt.awatop {
                    //	bins atmstr = {'b010???, 'b011???};
                    //	bins atmld = {'b110???, 'b111???};
                    bins atmstr = {'b010000, 'b010001, 'b010010, 'b010011, 'b010100, 'b010101, 'b010110, 'b010111,
                            'b011000, 'b011001, 'b011010, 'b011011, 'b011100, 'b011101, 'b011110, 'b011111};
                    bins atmld  = {'b100000, 'b100001, 'b100010, 'b100011, 'b100100, 'b100101, 'b100110, 'b100111,
                            'b101000, 'b101001, 'b101010, 'b101011, 'b101100, 'b101101, 'b101110, 'b101111};
                    bins atmswap = {'b110000};
                    bins atmcomp = {'b110001};
                }

                <%=nativeinterface%>_awcache : coverpoint m_scb_txn.m_ace_write_addr_pkt.awcache {
                    ignore_bins awcache_ig = {4'b0000, 4'b0001, 4'b0010, 4'b0011};
                }
                
    <%=nativeinterface%>_awaddr  : coverpoint m_scb_txn.m_ace_write_addr_pkt.awaddr[5:0] {
                bins align_size1_chnk_0_7   = {[6'h00:6'h07]};
    		bins align_size1_chnk_8_15  = {[6'h08:6'h0F]};
    		bins align_size1_chnk_16_23 = {[6'h10:6'h17]};
    		bins align_size1_chnk_24_31 = {[6'h18:6'h1F]};
    		bins align_size1_chnk_32_39 = {[6'h20:6'h27]};
    		bins align_size1_chnk_40_47 = {[6'h28:6'h2F]};
   		bins align_size1_chnk_48_55 = {[6'h30:6'h37]};
    		bins align_size1_chnk_56_63 = {[6'h38:6'h3F]};
 		bins align_size2_0_14  = {6'h00, 6'h02, 6'h04, 6'h06, 6'h08, 6'h0A, 6'h0C, 6'h0E, 6'h10, 6'h12, 6'h14, 6'h16, 6'h18, 6'h1A, 6'h1C};
    		bins align_size2_16_30 = {6'h20, 6'h22, 6'h24, 6'h26, 6'h28, 6'h2A, 6'h2C, 6'h2E, 6'h30, 6'h32, 6'h34, 6'h36, 6'h38, 6'h3A, 6'h3C};
    		bins align_size2_32_46 = {6'h10, 6'h12, 6'h14, 6'h16, 6'h18, 6'h1A, 6'h1C, 6'h1E};
    		bins align_size2_48_62 = {6'h30, 6'h32, 6'h34, 6'h36, 6'h38, 6'h3A, 6'h3C, 6'h3E};
    		bins align_size4_0_28  = {6'h00, 6'h04, 6'h08, 6'h0C, 6'h10, 6'h14, 6'h18, 6'h1C};
   		bins align_size4_32_60 = {6'h20, 6'h24, 6'h28, 6'h2C, 6'h30, 6'h34, 6'h38, 6'h3C};
    		bins align_size8_all = {6'h00, 6'h08, 6'h10, 6'h18, 6'h20, 6'h28, 6'h30, 6'h38};
    		bins align_size16_all = {6'h00, 6'h10, 6'h20, 6'h30};
   }
                


              <%=nativeinterface%>_awsize : coverpoint m_scb_txn.m_ace_write_addr_pkt.awsize {
              
                 <% for (var i = 0; i <= Math.log2(obj.wData / 8) ; i++) { %> 
              
                   bins awsize<%=i%> = {<%=i%>};
             <% } %>
             }               
   
               <%=nativeinterface%>_awlen : coverpoint m_scb_txn.m_ace_write_addr_pkt.awlen {
              
               <% for (let i = 0; i <= Math.floor(31/(obj.wData / 8)); i++) { %>
              
               bins awlen<%= i%> = {<%= i%>};
               <% } %>
              } 
                                                         
              <%=nativeinterface%>_awburst : coverpoint m_scb_txn.m_ace_write_addr_pkt.awburst{
                    bins awburst_incr = {1};
                    bins awburst_wrap = {2};
               } 
                // /#Cover.IOAIU.CohNormalTxnsAtomics.ww_wbrwalloc
                //#Cover.IOAIU.CohNormalTxnsAtomics.ww_wtrwalloc
                cross_atop_awcache : cross <%=nativeinterface%>_atop, <%=nativeinterface%>_awcache;
<%=nativeinterface%>_cross_atop_non_comp_awlen_awsize_awaddr_awburst : cross <%=nativeinterface%>_atop, <%=nativeinterface%>_awlen, <%=nativeinterface%>_awsize, <%=nativeinterface%>_awaddr, <%=nativeinterface%>_awburst {

    // Ignore atomic compare
    ignore_bins non_atomic_ops = binsof(<%=nativeinterface%>_atop) intersect {'b110001}; // atmcomp

    ignore_bins wrap_with_atomic = binsof(<%=nativeinterface%>_atop) intersect {'b010000, 'b010001, 'b010010, 'b010011, 'b010100, 'b010101, 'b010110, 'b010111,
        'b011000, 'b011001, 'b011010, 'b011011, 'b011100, 'b011101, 'b011110, 'b011111,
        'b100000, 'b100001, 'b100010, 'b100011, 'b100100, 'b100101, 'b100110, 'b100111,
        'b101000, 'b101001, 'b101010, 'b101011, 'b101100, 'b101101, 'b101110, 'b101111,
        'b110000} &&
          binsof(<%=nativeinterface%>_awburst) intersect {2}; // wrap

    
   
     
    
    //------------------------------------------------------------------------------
    ignore_bins awlen_2_4_5_6_8to31 = binsof(<%=nativeinterface%>_awlen) intersect {2,4,5,6,[8:31]};
    ignore_bins awsize4_5_6_7 = binsof(<%=nativeinterface%>_awsize) intersect {4,5,6,7}; 
    ignore_bins awlen1_awsize3 = binsof(<%=nativeinterface%>_awlen) intersect {1} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {3};
    ignore_bins awlen3_awsize2_3 = binsof(<%=nativeinterface%>_awlen) intersect {3} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {2,3};
    ignore_bins awlen7_awsize1_2_3 = binsof(<%=nativeinterface%>_awlen) intersect {7} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {1,2,3};
    <%if(obj.wData == 16){%>
    ignore_bins awlen1_3_awsize0 = binsof(<%=nativeinterface%>_awlen) intersect {1,3} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {0}; //awsize==1
    <%}%>
    <%if(obj.wData == 32){%>
    ignore_bins awlen1_awsize0_1 = binsof(<%=nativeinterface%>_awlen) intersect {1} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {0,1}; //awsize==2
    <%}%>
    //------------------------------------------------------------------------------
   

    ignore_bins addr_align_awsize1 = binsof(<%=nativeinterface%>_awsize) intersect {1} &&
                                     binsof(<%=nativeinterface%>_awaddr) intersect {[6'h01:6'h3F]}; // addr[0] != 0

    ignore_bins addr_align_awsize2 = binsof(<%=nativeinterface%>_awsize) intersect {2} &&
                                     binsof(<%=nativeinterface%>_awaddr) intersect {[6'h01:6'h3F]} with (<%=nativeinterface%>_awaddr % 4 != 0);

    ignore_bins addr_align_awsize3 = binsof(<%=nativeinterface%>_awsize) intersect {3} &&
                                     binsof(<%=nativeinterface%>_awaddr) intersect {[6'h01:6'h3F]} with (<%=nativeinterface%>_awaddr % 8 != 0);

    ignore_bins addr_align_awsize4 = binsof(<%=nativeinterface%>_awsize) intersect {4} &&
                                     binsof(<%=nativeinterface%>_awaddr) intersect {[6'h01:6'h3F]} with (<%=nativeinterface%>_awaddr % 16 != 0);

    ignore_bins addr_align_awsize5 = binsof(<%=nativeinterface%>_awsize) intersect {5} &&
                                     binsof(<%=nativeinterface%>_awaddr) intersect {[6'h01:6'h3F]} with (<%=nativeinterface%>_awaddr % 32 != 0);

    ignore_bins invalid_awsize_atomic = binsof(<%=nativeinterface%>_atop) intersect {'b01????, 'b10????, 'b110000} &&
                                        binsof(<%=nativeinterface%>_awsize) intersect {4, 5}; // Invalid AWSIZE for atomic

    
}

 cross <%=nativeinterface%>_atop, <%=nativeinterface%>_awsize, <%=nativeinterface%>_awaddr, 
      <%=nativeinterface%>_awburst, <%=nativeinterface%>_awlen 
{
    // Exclude non-compare atomic operations
    ignore_bins ignore_non_comp = binsof(<%=nativeinterface%>_atop) intersect {
        'b010000, 'b010001, 'b010010, 'b010011, 'b010100, 'b010101, 'b010110, 'b010111,
        'b011000, 'b011001, 'b011010, 'b011011, 'b011100, 'b011101, 'b011110, 'b011111,
        'b100000, 'b100001, 'b100010, 'b100011, 'b100100, 'b100101, 'b100110, 'b100111,
        'b101000, 'b101001, 'b101010, 'b101011, 'b101100, 'b101101, 'b101110, 'b101111,
        'b110000 };
    
    
    
    
    //-------------------------------------------------------------------------------
    ignore_bins awsize6_7 = binsof(<%=nativeinterface%>_awsize) intersect {6,7};
    ignore_bins awlen_2_4_5_6_8to14_16to30 = binsof(<%=nativeinterface%>_awlen) intersect {2,4,5,6,[8:14],[16:30]};
    ignore_bins awlen0_awsize0 = binsof(<%=nativeinterface%>_awlen) intersect {0} &&
                                 binsof(<%=nativeinterface%>_awsize) intersect {0}; 
    ignore_bins awlen31_awsize1_2_3_4_5 = binsof(<%=nativeinterface%>_awlen) intersect {31} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {1,2,3,4,5};
    ignore_bins awlen15_awsize2_3_4_5 = binsof(<%=nativeinterface%>_awlen) intersect {15} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {2,3,4,5};
    ignore_bins awlen7_awsize3_4_5 = binsof(<%=nativeinterface%>_awlen) intersect {7} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {3,4,5};
    ignore_bins awlen3_awsize4_5 = binsof(<%=nativeinterface%>_awlen) intersect {3} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {4,5};
    ignore_bins awlen1_awsize5 = binsof(<%=nativeinterface%>_awlen) intersect {1} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {5};
    <%if(obj.wData == 32){%>
    ignore_bins awlen1_3_7_awsize1 = binsof(<%=nativeinterface%>_awlen) intersect {1,3,7} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {1}; //awsize==2
    <%}%>
    <%if(obj.wData == 64){%>
    ignore_bins awlen1_3_awsize1_2 = binsof(<%=nativeinterface%>_awlen) intersect {1,3} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {1,2}; //awsize==3
    <%}%>
    <%if(obj.wData == 128){%>
    ignore_bins awlen1_awsize1_2_3 = binsof(<%=nativeinterface%>_awlen) intersect {1} &&
                                       binsof(<%=nativeinterface%>_awsize) intersect {1,2,3}; //awsize==4
    <%}%>
     ignore_bins awsize3_wrap_addr =binsof(<%=nativeinterface%>_awlen) intersect {0} &&
                                    binsof(<%=nativeinterface%>_awburst) intersect {2} &&
                                    binsof(<%=nativeinterface%>_awsize) intersect {3} &&
                                    binsof(<%=nativeinterface%>_awaddr) intersect {6'h00, 6'h10, 6'h20, 6'h30,6'h08,6'h18,6'h28,6'h38};
    ignore_bins awsize4_wrap_addr =binsof(<%=nativeinterface%>_awlen) intersect {0} &&
                                    binsof(<%=nativeinterface%>_awburst) intersect {2} &&
                                    binsof(<%=nativeinterface%>_awsize) intersect {4} &&
                                    binsof(<%=nativeinterface%>_awaddr) intersect {6'h00, 6'h10, 6'h20, 6'h30};
    ignore_bins awsize2_wrap_addr =binsof(<%=nativeinterface%>_awlen) intersect {0} &&
                                    binsof(<%=nativeinterface%>_awburst) intersect {2} &&
                                    binsof(<%=nativeinterface%>_awsize) intersect {2} &&
                                    binsof(<%=nativeinterface%>_awaddr) intersect {6'h00, 6'h10, 6'h20, 6'h30,6'h08,6'h18,6'h28,6'h38,6'h24,6'h2c,6'h34,6'h3c};
    ignore_bins awsize1_wrap_addr =binsof(<%=nativeinterface%>_awlen) intersect {0} &&
                                    binsof(<%=nativeinterface%>_awburst) intersect {2} &&
                                    binsof(<%=nativeinterface%>_awsize) intersect {1} &&
                                    binsof(<%=nativeinterface%>_awaddr) intersect {6'h00, 6'h10, 6'h20, 6'h30,6'h08,6'h18,6'h28,6'h38,6'h24,6'h2c,6'h34,6'h3c,6'h32,6'h02,6'h04,6'h06,6'h08,6'h0a,6'h0c,6'h0e,6'h12,6'h14,6'h16,6'h1a,6'h1c,6'h22,6'h26,6'h28,6'h2a,6'h2e,6'h36,6'h3a,6'h3e,6'h1e};
                                    
         
                                    
 
    //---------------------------------------------------------------------------------

    // AWADDR misalignment with respect to AWSIZE
    /*ignore_bins misaligned_size2 = 
        binsof(<%=nativeinterface%>_awsize) intersect {1} && 
        binsof(<%=nativeinterface%>_awaddr) intersect {[6'h00:6'h3F]} with (<%=nativeinterface%>_awaddr % 1 != 0); */ // always aligned

    ignore_bins misaligned_size4 = 
        binsof(<%=nativeinterface%>_awsize) intersect {2} && 
        binsof(<%=nativeinterface%>_awaddr) intersect {[6'h00:6'h3F]} with (<%=nativeinterface%>_awaddr % 2 != 0);

    ignore_bins misaligned_size8 = 
        binsof(<%=nativeinterface%>_awsize) intersect {3} && 
        binsof(<%=nativeinterface%>_awaddr) intersect {[6'h00:6'h3F]} with (<%=nativeinterface%>_awaddr % 4 != 0);

    ignore_bins misaligned_size16 = 
        binsof(<%=nativeinterface%>_awsize) intersect {4} && 
        binsof(<%=nativeinterface%>_awaddr) intersect {[6'h00:6'h3F]} with (<%=nativeinterface%>_awaddr % 8 != 0);

    ignore_bins misaligned_size32 = 
        binsof(<%=nativeinterface%>_awsize) intersect {5} && 
        binsof(<%=nativeinterface%>_awaddr) intersect {[6'h00:6'h3F]} with (<%=nativeinterface%>_awaddr % 16 != 0);
}
                
 endgroup // <%=nativeinterface%>_atm


            //#Cover.IOAIU.SMI.StrReq.cmstatus.Snarf
            //#Cover.IOAIU.SMI.CMDReq.MPF1.StashNId
            //#Cover.IOAIU.SMI.CMDReq.MPF1.Valid
            <% if(obj.fnNativeInterface == "ACELITE-E"){%>
            covergroup ace_lite_e_cover_stashvalid<%=port%>;

                cp_stash_types: coverpoint m_scb_txn.m_ace_write_addr_pkt.awsnoop {
                    bins WriteUniquePtlStash    = {4'b1000};
                    bins WriteUniqueFullStash   = {4'b1001};
                    bins StashOnceShared        = {4'b1100};
                    bins StashOnceUnique        = {4'b1101};
                }

                cp_stash_target: coverpoint stash_target_identified {
                 
                        bins target_identified = {1};

                        bins target_not_identified = {0};
                }
                
                cp_stash_result:coverpoint m_scb_txn.m_str_req_pkt.smi_cmstatus_snarf{
                        bins stash_accepted = {1};

                        bins stash_rejected = {0};
                }

            cross_stash: cross cp_stash_types,cp_stash_target,cp_stash_result{
                    ignore_bins stashAccept_illegal = binsof(cp_stash_target) intersect {0} && binsof(cp_stash_result) intersect {1};
                }

            endgroup //ace_lite_e_cover_stashvalid

            covergroup ace_lite_e_stash_core<%=port%>;
                //#Cov.IOAIU.AXI.STASHNIDLPID
                stashnid: coverpoint awstashnid {
                    bins stashnid_zero = {0};
                    /* bins stashnid_none_zero[] = {[1:$]}; */
                    //TODO: check whether sys is able to handle: nid is not in chiAiu range
                    <%if (obj.chiAiuIds.length > 0) { %>
                        bins stashnid_chi_aiu[] = {<%=obj.chiAiuIds%>};
                    <%}else{%>
                        bins stashnid_chi_aiu0 = {0};
                    <%}%>
                }
                stashnidEn: coverpoint awstashniden;
                stashlpid: coverpoint awstashlpid;
                stashlpidEn: coverpoint awstashlpiden;
                stashnidXstashnidEn: cross stashnid, stashnidEn {
                    //TODO: need to chagne to ignore_bins
                    ignore_bins stashnid_illegal = binsof(stashnidEn) intersect {0} && binsof(stashnid) intersect {[1:$]};
                }
                stashlpidXstashlpidEn: cross stashlpid, stashlpidEn {
                    ignore_bins stashlpid_illegal = binsof(stashlpidEn) intersect {0} && binsof(stashlpid) intersect {[1:$]};
                }
                stashType: coverpoint awsnoop {
                    bins WriteUniquePtlStash    = {4'b1000};
                    bins WriteUniqueFullStash   = {4'b1001};
                    bins StashOnceShared        = {4'b1100};
                    bins StashOnceUnique        = {4'b1101};
                    //bins StashTranslation       = {4'b1110};
                }
                stashnidEnXstashpidEnXstashType: cross stashlpidEn, stashnidEn, stashType {
                    //ignore_bins not_valid_StashTransEn = (binsof(stashnidEn) intersect {1}  ||
                    //binsof(stashlpidEn) intersect {1} )&&
                    //binsof(stashType.StashTranslation);
                }
                    //#Cov.IOAIU.awdomain
                    cp_awdomain: coverpoint awdomain {
                        bins non_shareable = {0};
                        bins inner_shareable = {1};
                        bins outer_shareable = {2};
                        bins system_shareable = {3};
                    }

                    awdomain_x_stashType: cross cp_awdomain, stashType{
                    // Does not support non-shareable (CONC-11465 & CONC-11474)
                    ignore_bins illegal_awdomain_x_StashOnceShared_nonshr   = binsof (cp_awdomain.non_shareable) && binsof (stashType.StashOnceShared);
                    ignore_bins illegal_awdomain_x_StashOnceUnique_nonshr   = binsof (cp_awdomain.non_shareable) && binsof (stashType.StashOnceUnique);
                    ignore_bins illegal_awdomain_x_WriteUniquePtlStash_nonshr   = binsof (cp_awdomain.non_shareable) && binsof (stashType.WriteUniquePtlStash);
                    ignore_bins illegal_awdomain_x_WriteUniquePtlStash_sysshr   =  binsof (cp_awdomain.system_shareable) && binsof (stashType.WriteUniquePtlStash);
                    ignore_bins illegal_awdomain_x_WriteUniqueFullStash_nonshr   = binsof (cp_awdomain.non_shareable) && binsof (stashType.WriteUniqueFullStash);
                    ignore_bins illegal_awdomain_x_WriteUniqueFullStash_sysshr   = binsof (cp_awdomain.system_shareable) && binsof (stashType.WriteUniqueFullStash);
                    ignore_bins illegal_awdomain_x_StashOnceShared_sysshr   = binsof (cp_awdomain.system_shareable) && binsof (stashType.StashOnceShared);
                    ignore_bins illegal_awdomain_x_StashOnceUnique_sysshr   = binsof (cp_awdomain.system_shareable) && binsof (stashType.StashOnceUnique);}
            endgroup //ace_lite_e_stash

            covergroup ace_lite_e_deallocating_txns_and_pcmos_core<%=port%>;
                //#Cov.IOAIU.READONCECLEANINVALID
                cp_READONCECLEANINVALID: coverpoint m_scb_txn.m_ace_read_addr_pkt.arsnoop {
                    bins READONCECLEANINVALID         = {4'b0100};
                }
                //#Cov.IOAIU.READONCEMAKEINVALID
                cp_READONCEMAKEINVALID: coverpoint m_scb_txn.m_ace_read_addr_pkt.arsnoop {
                    bins READONCEMAKEINVALID         = {4'b0101};
                }
                //#Cov.IOAIU.CLEANSHAREDPERSIST
                cp_CLEANSHAREDPERSIST: coverpoint m_scb_txn.m_ace_read_addr_pkt.arsnoop {
                    bins CLEANSHAREDPERSIST         = {4'b1010};
                }
            endgroup //ace_lite_e_deallocating_txns_and_pcmos
        <%}%>
        <%}%>

        <%if(obj.eAc && ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E"))) { %>
            covergroup ace_snoop_address_channel_core<%=port%>;
                    //#Cov.IOAIU.acsnoop
                coverpoint_acsnoop: coverpoint acsnoop {
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                        bins rdonce 		= {4'b0000};
                        bins rdshrd 		= {4'b0001};
                        bins rdcln  		= {4'b0010};
                        bins rdnotshrddir 	= {4'b0011};
                        bins rdunq  		= {4'b0111};
                        bins clnshrd		= {4'b1000};
                        bins clninvl		= {4'b1001};
                        bins mkinvl 		= {4'b1101};
                        bins dvmcmpl		= {4'b1110};
                    <%}%>
                    <%if(obj.nDvmSnpInFlight > 0){%>
                        bins dvmmsg = {4'b1111};
                    <%}%>
                }
                <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    //#Cov.IOAIU.acprot
                    coverpoint_secure: coverpoint acprot[1]{
                        bins zero = {0};
                        bins one = {1};
                    }
                    cross_acsnoop_acprot: cross coverpoint_acsnoop, coverpoint_secure;
                <%}%>
                //cp_dvm_secure_tlb_invld_all: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0],acaddr[15]} {
                //    bins completion_not_required          = {11'b00010100000};
                //    bins completion_required              = {11'b00010100001};
                //}
                //cp_dvm_secure_tlb_invld_va: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0],acaddr[15]} {
                //    bins completion_not_required          = {11'b00010100010};
                //    bins completion_required              = {11'b00010100011};
                //}
                //cp_dvm_secure_tlb_invld_asid: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0],acaddr[15]} {
                //    bins completion_not_required          = {11'b00010100100};
                //    bins completion_required              = {11'b00010100101};
                //}
                //cp_dvm_secure_tlb_invld_va_asid: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0],acaddr[15]} {
                //    bins completion_not_required          = {11'b00010100110};
                //    bins completion_required              = {11'b00010100111};
                //}
                //cp_dvm_all_os_tlb_invld_all: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0],acaddr[15]} {
                //    bins completion_not_required          = {11'b00010100000};
                //    bins completion_required              = {11'b00010100001};
                //}
                //cp_dvm_guest_os_tlb_invld_all: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0],acaddr[15]} {
                //    bins completion_not_required          = {11'b00010111000};
                //    bins completion_required              = {11'b00010111001};
                //}
                //cp_dvm_guest_os_tlb_invld_va: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0],acaddr[15]} {
                //    bins completion_not_required          = {11'b00010111010};
                //    bins completion_required              = {11'b00010111011};
                //}
                //cp_dvm_guest_os_tlb_invld_asid: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0],acaddr[15]} {
                //    bins completion_not_required          = {11'b00010111100};
                //    bins completion_required              = {11'b00010111101};
                //}
                //cp_dvm_guest_os_tlb_invld_va_asid: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0],acaddr[15]} {
                //    bins completion_not_required          = {11'b00010111110};
                //    bins completion_required              = {11'b00010111111};
                //}
                //cp_dvm_hvisor_tlb_invld_all: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0],acaddr[15]} {
                //    bins completion_not_required          = {11'b00011110000};
                //    bins completion_required              = {11'b00011110001};
                //}
                //cp_dvm_hvisor_tlb_invld_va: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0],acaddr[15]} {
                //    bins completion_not_required          = {11'b00011110010};
                //    bins completion_required              = {11'b00011110011};
                //}
                //cp_dvm_branch_predictor_tlb_invld_all: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0]} {
                //    bins invld_all          = {10'b00100000000};
                //}
                //cp_dvm_branch_predictor_tlb_invld_va: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0]} {
                //    bins invld_va          = {10'b00100000001};
                //}
                //cp_dvm_hvisor_all_guest_os_secure_nonsecure_vic_invld: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {10'b0110000001};
                //}
                //cp_dvm_hvisor_all_guest_os_nonsecure_vic_invld: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {10'b0110011001};
                //}
                //cp_dvm_guest_os_secure_invld_va_asid: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {10'b0111010011};
                //}
                //cp_dvm_guest_os_nonsecure_invld_all: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {10'b0111011100};
                //}
                //cp_dvm_guest_os_nonsecure_invld_va_asid: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {10'b0111011111};
                //}
                //cp_dvm_hvisor_invld_va: coverpoint {acaddr[14:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {10'b0111111001};
                //}
                //cp_dvm_secure_pic_invld_all: coverpoint {acaddr[14:12],acaddr[9:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {8'b01010000};
                //}
                //cp_dvm_secure_pic_invld_all_: coverpoint {acaddr[14:12],acaddr[9:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {8'b01010001};
                //}
                //cp_dvm_nonsecure_pic_invld_pa_w_o_vi: coverpoint {acaddr[14:12],acaddr[9:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {8'b01010111};
                //}
                //cp_dvm_nonsecure_pic_invld_pa_w_vi: coverpoint {acaddr[14:12],acaddr[9:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {8'b01011000};
                //}
                //cp_dvm_nonsecure_pic_invld_all: coverpoint {acaddr[14:12],acaddr[9:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {8'b01011001};
                //}
                //cp_dvm_nonsecure_pic_invld_pa_w_o_vi_: coverpoint {acaddr[14:12],acaddr[9:8],acaddr[6:5],acaddr[0]} {
                //    bins invld          = {8'b01011111};
                //}
                //#Cover.IOAIU.DVMSnooper.DVMSnpTypes
                //#Cover.IOAIU.DVMSnooper.nonSyncDVM
                //#Cover.IOAIU.DVMSnooper.SyncDVM
                cp_dvm_messege_type: coverpoint acaddr[14:12] {
                    bins synchronization                  = {4};
                }
                    //#Cov.IOAIU.acaddr
                <%for(var i = 0; i < obj.wAddr; i++) { %>
                    coverpoint_acaddr_<%=i%>: coverpoint acaddr[<%=i%>]{
                        bins zero = {0};
                        bins one  = {1};
                    }
                <%}%>
            endgroup  // ace_snoop_address_channel
        <%}%>
        <%if(obj.eAc && ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E"))) { %>
            covergroup ace_snoop_response_channel_core<%=port%>;
                //#Cov.IOAIU.crresp
                coverpoint_DataTransfer: coverpoint crresp[0]{
                        bins zero = {0};
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
                        bins one = {1};
                    <%}%>
                }
                coverpoint_Error: coverpoint crresp[1]{
                        bins zero = {0};
                        bins one = {1};
                }
                coverpoint_PassDirty: coverpoint crresp[2]{
                        bins zero = {0};
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
                        bins one = {1};
                    <%}%>
                }
                coverpoint_IsShared: coverpoint crresp[3]{
                        bins zero = {0};
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
                        bins one = {1};
                    <%}%>
                }
                coverpoint_WasUnique: coverpoint crresp[4]{
                        bins zero = {0};
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
                        bins one = {1};
                    <%}%>
                }

                <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
                cp_PassDirty_DataTransfer: coverpoint {crresp[2],crresp[0]} {
                    ignore_bins illegal_crresp_PassDirty_DataTransfer_1_0        = {2'b10};
                } 
                <%}%>
            endgroup // ace_snoop_response_channel

            covergroup ace_snoop_response_channel_with_req_core<%=port%>;
                cp_acsnoop: coverpoint acsnoop_rsp {
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
                        bins rdonce             = {4'b0000};
                        bins rdshrd             = {4'b0001};
                        bins rdcln              = {4'b0010};
                        bins rdnotshrddir       = {4'b0011};
                        bins rdunq              = {4'b0111};
                        bins clnshrd            = {4'b1000};
                        bins clninvl            = {4'b1001};
                        bins mkinvl             = {4'b1101};
                    <%}%>
                    <%if((obj.eAc == 1 && ((obj.fnNativeInterface == "ACELITE-E"))) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")){%>
                        bins dvmmsg  = {4'b1111};
                        bins dvmcmpl = {4'b1110};
                    <%}%>
                }
                 <%if (obj.eAc == 1 && ((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E"))) {%>
                //#Cov.IOAIU.crresp
                cp_DataTransfer: coverpoint crresp[0]{
                        bins zero = {0};
                }
                cp_Error: coverpoint crresp[1]{
                        bins zero = {0};
                        bins one = {1};
                }
                cp_PassDirty: coverpoint crresp[2]{
                        bins zero = {0};
                }
                cp_IsShared: coverpoint crresp[3]{
                        bins zero = {0};
                }
                cp_WasUnique: coverpoint crresp[4]{
                        bins zero = {0};
                } 
                <%}else if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                  //#Cov.IOAIU.crresp
                cp_DataTransfer: coverpoint crresp[0]{
                        bins zero = {0};
                        bins one = {1};
                }
                cp_Error: coverpoint crresp[1]{
                        bins zero = {0};
                        bins one = {1};
                }
                cp_PassDirty: coverpoint crresp[2]{
                        bins zero = {0};
                        bins one = {1};
                }
                cp_IsShared: coverpoint crresp[3]{
                        bins zero = {0};
                        bins one = {1};
                }
                cp_WasUnique: coverpoint crresp[4]{
                        bins zero = {0};
                        bins one = {1};
                }

                cp_PassDirty_DataTransfer: coverpoint {crresp[2],crresp[0]} {
                    ignore_bins illegal_crresp_PassDirty_DataTransfer_1_0        = {2'b10};
                 }
                <%}%>

                //#Cov.IOAIU.crresp_x_acsnoop
                cp_IsShared_x_PassDirty_x_DataTransfer_x_WasUnique_x_acsnoop:  cross cp_IsShared, cp_PassDirty, cp_DataTransfer, cp_WasUnique, cp_acsnoop{
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
                    ignore_bins illegal_crresp_PassDirty_DataTransfer_1_0   = binsof (cp_PassDirty.one) && binsof (cp_DataTransfer.zero);

                    ignore_bins illegal_IsShared_x_acsnoop_rdunq        = binsof (cp_IsShared.one) && binsof (cp_acsnoop.rdunq);
                    ignore_bins illegal_IsShared_x_acsnoop_clninvl      = binsof (cp_IsShared.one) && binsof (cp_acsnoop.clninvl);
                    ignore_bins illegal_IsShared_x_acsnoop_mkinvl       = binsof (cp_IsShared.one) && binsof (cp_acsnoop.mkinvl);
                    ignore_bins illegal_DvmMsg_resp = (binsof (cp_DataTransfer.one) || binsof (cp_PassDirty.one) || binsof (cp_IsShared.one) || binsof (cp_WasUnique.one)) && (binsof (cp_acsnoop.dvmmsg) || binsof (cp_acsnoop.dvmcmpl));//C12.3.4
                    <%}%>
                
                    }

                cp_Error_x_acsnoop:  cross cp_Error, cp_acsnoop{
                    ignore_bins illegal_crresp_Error_acsnoop_dvmcmpl   = binsof (cp_Error) && binsof (cp_acsnoop.dvmcmpl);
                    //ignore_bins illegal_crresp_Error_acsnoop_dvmmsg   = binsof (cp_Error) && binsof (cp_acsnoop.dvmmsg);
                    }
                
            endgroup // ace_snoop_response_channel_with_req

        
            covergroup ace_snoop_data_core<%=port%>;
                //#Cov.IOAIU.cddata
                <%for(var i = 0; i < obj.wData; i++) { %>
                    coverpoint_cddata_<%=i%>: coverpoint cddata_beat[<%=i%>]{
                        bins zero = {0};
                        bins one  = {1};
                    }
                <%}%>
                coverpoint_cdlast: coverpoint cdlast{
                    bins zero = {0};
                    bins one  = {1};
                }
            endgroup // ace_snoop_data
        <%}%>

        <%if (obj.fnNativeInterface == "ACELITE-E" || obj.useCache) {%>
            covergroup ccp_snoop_dtr_req_type_core<%=port%>;
                coverpoint_snoop_dtr_req_type: coverpoint snoop_dtr_req_type {
                    <%if(obj.fnNativeInterface == "ACELITE-E") { %>							    
                        bins writestash = {1};
                    <%}%>
                    <%if(obj.useCache) { %>
                        bins snp = {2};
                    <% } %>
                }
            endgroup // ccp_snoop_hit_evict
        <%}%>

        //#Cover.IOAIU.Security
        covergroup cg_security_feature_core<%=port%>; // 7.6 Security based on GPRs 
            cp_rw: coverpoint {m_scb_txn.isRead && !m_scb_txn.isDVM, m_scb_txn.isWrite} {
                bins Read  = {2'b10};
                bins Write = {2'b01};
                bins noRW  = default;
            }
            cp_ns: coverpoint m_scb_txn.m_security {
                bins NS_0  = {0};
                bins NS_1  = {1};
            }
            cp_nsx: coverpoint nsx {
                bins NSX_0  = {0};
                bins NSX_1  = {1};
            }
            cp_resp:coverpoint resp{
                    bins ok = {0};
                    bins exok = {1};
                    bins slverr = {2};
                    bins decerr = {3};
            }
            //#Cover.IOAIU.Security.Read
            //#Cover.IOAIU.Security.Write
            cx_NS_X_NSX: cross cp_rw,cp_nsx,cp_ns,cp_resp {
            option.cross_auto_bin_max = 0;
                    bins write_NS_0_NSX_0 = binsof(cp_rw.Write) && binsof(cp_ns.NS_0) &&  binsof(cp_nsx.NSX_0) &&  binsof(cp_resp.ok);
                    bins write_NS_0_NSX_1 = binsof(cp_rw.Write) && binsof(cp_ns.NS_0) &&  binsof(cp_nsx.NSX_1) &&  binsof(cp_resp.ok);
                    bins write_NS_1_NSX_0 = binsof(cp_rw.Write) && binsof(cp_ns.NS_1) &&  binsof(cp_nsx.NSX_0) &&  binsof(cp_resp.decerr);
                    bins write_NS_1_NSX_1 = binsof(cp_rw.Write) && binsof(cp_ns.NS_1) &&  binsof(cp_nsx.NSX_1) &&  binsof(cp_resp.ok);
                    bins read_NS_0_NSX_0  = binsof(cp_rw.Read) && binsof(cp_ns.NS_0) &&  binsof(cp_nsx.NSX_0) &&  binsof(cp_resp.ok);
                    bins read_NS_0_NSX_1  = binsof(cp_rw.Read) && binsof(cp_ns.NS_0) &&  binsof(cp_nsx.NSX_1) &&  binsof(cp_resp.ok);
                    bins read_NS_1_NSX_0  = binsof(cp_rw.Read) && binsof(cp_ns.NS_1) &&  binsof(cp_nsx.NSX_0) &&  binsof(cp_resp.decerr);
                    bins read_NS_1_NSX_1  = binsof(cp_rw.Read) && binsof(cp_ns.NS_1) &&  binsof(cp_nsx.NSX_1) &&  binsof(cp_resp.ok);
            }
        endgroup
        <%if (obj.orderedWriteObservation == true) {%>
        <%if((obj.fnNativeInterface == "ACE-LITE") ) { %>
        covergroup cg_PCIe_owo_feature<%=port%>;  
            cp_isCoherent: coverpoint m_scb_txn.isCoherent { 
                    bins coh = {1}; 
                    bins noncoh = {0}; 
                }
            cp_rw: coverpoint {m_scb_txn.isRead,m_scb_txn.isWrite} {
                    bins Read  = {2'b10};
                    bins Write = {2'b01};
                }
            cp_tgt_type: coverpoint tgt_type {
                    bins dii_tgt = {DII};
                    bins dmi_tgt = {DMI};
                }    
            
            cp_awdomain: coverpoint awdomain {
                    bins outer_shareable = {2};
                    bins system_shareable = {3};
                    //type_option.weight = 0;
                }
            cp_ardomain: coverpoint ardomain {
                    bins outer_shareable = {2};
                    bins system_shareable = {3};
                    //type_option.weight = 0;
                }    
            cp_awcache: coverpoint awcache {
                    bins wr_devnonbuf = {4'b0000};
                    bins wr_ncnonbuf  = {4'b0010};
                    bins wr_wtnalloc  = {4'b0110};
                    bins wr_wbwalloc  = {4'b1011};
                }    
             cp_arcache: coverpoint arcache {
                   bins rd_devnonbuf = {4'b0000};
                   bins rd_ncnonbuf  = {4'b0010};
                   bins rd_wtnalloc  = {4'b0110};
                   bins rd_wbralloc  = {4'b0111};
                }
                
             cx_PCIe_RD: cross cp_rw,cp_isCoherent,cp_tgt_type,cp_ardomain,cp_arcache {
                   option.cross_auto_bin_max = 0;
                   bins noncoh_dii_system_devnonbuf = binsof(cp_rw.Read) && binsof(cp_isCoherent.noncoh) && binsof(cp_tgt_type.dii_tgt) &&  binsof(cp_ardomain.system_shareable) &&  binsof(cp_arcache.rd_devnonbuf) ;

                   bins noncoh_dmi_system_ncnonbuf = binsof(cp_rw.Read) && binsof(cp_isCoherent.noncoh) && binsof(cp_tgt_type.dmi_tgt) &&  binsof(cp_ardomain.system_shareable) &&  binsof(cp_arcache.rd_ncnonbuf);

                   bins coh_dmi_outer_wtnalloc = binsof(cp_rw.Read) && binsof(cp_isCoherent.coh) && binsof(cp_tgt_type.dmi_tgt) &&  binsof(cp_ardomain.outer_shareable) &&  binsof(cp_arcache.rd_wtnalloc) ;

                   bins coh_dmi_outer_wbralloc = binsof(cp_rw.Read) && binsof(cp_isCoherent.coh) && binsof(cp_tgt_type.dmi_tgt) &&  binsof(cp_ardomain.outer_shareable) &&  binsof(cp_arcache.rd_wbralloc);
                } 

             cx_PCIe_WR: cross cp_rw,cp_isCoherent,cp_tgt_type,cp_awdomain,cp_awcache {
                   option.cross_auto_bin_max = 0;
                   bins noncoh_dii_system_devnonbuf = binsof(cp_rw.Write) && binsof(cp_isCoherent.noncoh) && binsof(cp_tgt_type.dii_tgt) &&  binsof(cp_awdomain.system_shareable) &&  binsof(cp_awcache.wr_devnonbuf);

                   bins noncoh_dmi_system_ncnonbuf = binsof(cp_rw.Write) && binsof(cp_isCoherent.noncoh) && binsof(cp_tgt_type.dmi_tgt) &&  binsof(cp_awdomain.system_shareable) &&  binsof(cp_awcache.wr_ncnonbuf);

                   bins coh_dmi_outer_wtnalloc = binsof(cp_rw.Write) && binsof(cp_isCoherent.coh) && binsof(cp_tgt_type.dmi_tgt) &&  binsof(cp_awdomain.outer_shareable) &&  binsof(cp_awcache.wr_wtnalloc);

                   bins coh_dmi_outer_wbwalloc = binsof(cp_rw.Write) && binsof(cp_isCoherent.coh) && binsof(cp_tgt_type.dmi_tgt) &&  binsof(cp_awdomain.outer_shareable) &&  binsof(cp_awcache.wr_wbwalloc);
                } 

        endgroup
	<%}%>
	<%}%>
        <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
            //#Cover.IOAIU.ProxyCache
            covergroup ccp_coh_noncoh_ops_cg_core<%=port%>; // Proxy Cache with coh, noncoherent transitions
                cp_rw: coverpoint {m_scb_txn.isRead,m_scb_txn.isWrite} {
                        bins Read  = {2'b10};
                        bins Write = {2'b01};
                }
                cp_isPartialWrite: coverpoint m_scb_txn.isPartialWrite {
                    bins PtlWr   = {1};
                    bins FullWr  =  {0};
                }
                cp_isPartialRead: coverpoint m_scb_txn.isPartialRead {
                    bins PtlRd   = {1};
                    bins FullRr  =  {0};
                }
                cp_awcache: coverpoint awcache_axi4 {
                    bins na_awcache_0000 = {4'b0000};
                    bins na_awcache_0001 = {4'b0001};
                    bins na_awcache_0010 = {4'b0010};
                    bins na_awcache_0011 = {4'b0011};
                    bins al_awcache_1010 = {4'b1010};
                    bins al_awcache_1011 = {4'b1011};
                    bins al_awcache_1110 = {4'b1110};
                    bins al_awcache_1111 = {4'b1111};
                }
                cp_arcache: coverpoint arcache_axi4 {
                    bins na_arcache_0000 = {4'b0000};
                    bins na_arcache_0001 = {4'b0001};
                    bins na_arcache_0010 = {4'b0010};
                    bins na_arcache_0011 = {4'b0011};
                    bins al_arcache_0110 = {4'b0110};
                    bins al_arcache_0111 = {4'b0111};
                    bins al_arcache_1110 = {4'b1110};
                    bins al_arcache_1111 = {4'b1111};
                }
                cp_isCoherent: coverpoint m_scb_txn.isCoherent { 
                    bins coh = {1}; 
                    bins noncoh = {0}; 
                }
                <%if(obj.useCache) {%>
                cp_isEvict: coverpoint isEvict { 
                    bins Evict = {1}; 
                }
                <%}%>
                cp_next_state: coverpoint  CCPnextstate {
                    <%if(obj.useCache) {%>
                            bins next_state_IX = {IX};
                            bins next_state_SC = {SC};
                            bins next_state_SD = {SD};
                            bins next_state_UC = {UC};
                            bins next_state_UD = {UD};
                    <%}else {%>
                            bins next_state_IX = {nextst_IX};
                    <%}%>
                }
                cp_current_state: coverpoint  CCPcurrentstate {
                    <%if(obj.useCache) {%>
                        bins curr_state_IX = {IX};
                        bins curr_state_SC = {SC};
                        bins curr_state_SD = {SD};
                        bins curr_state_UC = {UC};
                        bins curr_state_UD = {UD};
                    <%}else {%>
                        bins curr_state_IX = {currst_IX};
                    <%}%>
                }
                //#Cover.IOAIU.CCPCtrlPkt.b2bAlloc_same_addr
                //#Cover.IOAIU.CCPCtrlPkt.b2bAlloc_same_index
                <%if(obj.useCache) {%>
                    cp_allocate: coverpoint m_scb_txn.m_iocache_allocate {//alloc from smi iff ccp alloc else its 0
                        bins al = {1};
                        bins na = {0};
                    } 
                <%}%>
                cp_tgt_type: coverpoint tgt_type {
                    bins dii_tgt = {DII};
                    bins dmi_tgt = {DMI};
                } 
                cp_cmd_type: coverpoint Cmd_Req {
                    <%if(obj.useCache) {%>
                    bins CmdRdNC     = {CmdRdNC};
                    bins CmdWrNCPtl  = {CmdWrNCPtl};
                    bins CmdWrNCFull = {CmdWrNCFull};
                        bins CmdRdNITC   = {CmdRdNITC}; 
                        bins CmdRdVld    = {CmdRdVld};
                        bins CmdWrUnqPtl = {CmdWrUnqPtl};
                        bins CmdRdUnq    = {CmdRdUnq};
                        bins CmdWrUnqFull= {CmdWrUnqFull};
                        bins CmdMkUnq    = {CmdMkUnq};
                        bins CmdNOMsg    = {NoMsg};
                    <%}else {%>
                        bins CmdRdNITC   = {CmdRdNITC}; 
                        bins CmdWrUnqPtl = {CmdWrUnqPtl};
                        bins CmdWrUnqFull= {CmdWrUnqFull};
                        bins CmdRdNC     = {CmdRdNC};
                        bins CmdWrNCPtl  = {CmdWrNCPtl};
                        bins CmdWrNCFull = {CmdWrNCFull};
                        bins CmdSwAtm    = {CmdSwAtm};
                        bins CmdCompAtm  = {CmdCompAtm};
                    <%}%>
                } 
                <%if(obj.useCache) {%>
                cx_evict_coh_noncoh: cross cp_isEvict,cp_isCoherent,cp_tgt_type {
                    ignore_bins coh_dii = binsof(cp_isCoherent) intersect {1} && binsof(cp_tgt_type) intersect {DII}; 
                }
                <%}%>
                //#Cover.IOAIU.NonCohPtlRead
                cx_noncoh_ptl_read_dmi_tgt: cross cp_rw,cp_arcache,cp_isPartialRead,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent,cp_tgt_type {
                    ignore_bins cohops = binsof(cp_isCoherent) intersect {1}; 
                    ignore_bins wr_txn = binsof(cp_rw) intersect {1};
                    ignore_bins FullRd=  binsof(cp_isPartialRead) intersect {0} ;
                    ignore_bins dii_tgt = binsof(cp_tgt_type) intersect {DII};
                    ignore_bins illegal_txn_dmi_tgt = binsof(cp_tgt_type) intersect {DMI} && binsof(cp_arcache) intersect {4'b0000,4'b0001} ; //CONC-11546
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdRdNC};
                        ignore_bins retain_currstate_IX =  binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins illegal_ConcMsg_hit = binsof(cp_current_state) intersect {SC,SD,UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins retain_currstate_SC =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {SC};
                        ignore_bins retain_currstate_SD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {SD};
                        ignore_bins retain_currstate_UC =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UC};
                        ignore_bins retain_currstate_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //since This probably will never happen in a real system to hit noncoh SC/SD so adding ignore for now
                        ignore_bins currstate_SC_UD =  binsof(cp_current_state) intersect {SC,SD} ;//CONC-10915 added address alias test 
                    <%}else{%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {currst_IX}  && !binsof(cp_cmd_type) intersect {CmdRdNC};
                        ignore_bins retain_currstate_IX =  binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                    <%}%>
                }
                cx_noncoh_ptl_read_dii_tgt: cross cp_rw,cp_arcache,cp_isPartialRead,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent,cp_tgt_type  {  
                    ignore_bins cohops = binsof(cp_isCoherent) intersect {1}; 
                    ignore_bins wr_txn = binsof(cp_rw) intersect {1}  ;
                    ignore_bins FullRd=  binsof(cp_isPartialRead) intersect {0} ;
                    ignore_bins dmi_tgt = binsof(cp_tgt_type) intersect {DMI};
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdRdNC};
                        ignore_bins retain_currstate_IX =  binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins illegal_ConcMsg_hit = binsof(cp_current_state) intersect {SC,SD,UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins retain_currstate_SC =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {SC};
                        ignore_bins retain_currstate_SD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {SD};
                        ignore_bins retain_currstate_UC =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UC};
                        ignore_bins retain_currstate_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //since This probably will never happen in a real system to hit noncoh SC/SD so adding ignore for now
                        ignore_bins currstate_SC_UD =  binsof(cp_current_state) intersect {SC,SD} ;//CONC-10915 added address alias test
                    <%}else{%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {currst_IX}  && !binsof(cp_cmd_type) intersect {CmdRdNC};
                        ignore_bins retain_currstate_IX =  binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                    <%}%>
                }
                //#Cover.IOAIU.CohReadPtl
                cx_coh_ptl_read: cross cp_rw,cp_arcache,cp_isPartialRead,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent{  
                    ignore_bins noncohops = binsof(cp_isCoherent) intersect {0}; 
                    ignore_bins wr_txn = binsof(cp_rw) intersect {1}  ;
                    ignore_bins FullRd=  binsof(cp_isPartialRead) intersect {0} ;
                    ignore_bins illegal_txn_dmi_tgt = binsof(cp_arcache) intersect {4'b0000,4'b0001} ; //CONC-11546
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdRdNITC};
                        ignore_bins illegal_ConcMsg_miss_AL = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {SC,SD,UC,UD}  && !binsof(cp_cmd_type) intersect {CmdRdVld};
                        ignore_bins retain_currstate_IX_NA =  binsof(cp_arcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins retain_currstate_IX_AL =  binsof(cp_arcache) intersect {4'b0110,4'b0111,4'b1110,4'b1111} && binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {IX};
                        ignore_bins illegal_ConcMsg_hit = binsof(cp_current_state) intersect {SC,SD,UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins retain_currstate_SC =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {SC};
                        ignore_bins retain_currstate_SD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {SD};
                        ignore_bins retain_currstate_UC =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UC};
                        ignore_bins retain_currstate_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                        //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                        ignore_bins coh_nonmodifiable_access=  binsof(cp_arcache) intersect {4'b0000,4'b0001};
                    <%}else{%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {currst_IX} && binsof(cp_next_state) intersect {nextst_IX}  && !binsof(cp_cmd_type) intersect {CmdRdNITC};
                        ignore_bins retain_currstate_IX_NA =  binsof(cp_arcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                        //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                        //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                        ignore_bins coh_nonmodifiable_access=  binsof(cp_arcache) intersect {4'b0000,4'b0001};
                    <%}%>
                }
                //#Cover.IOAIU.NonCohFullRead
                cx_noncoh_full_read_dmi_tgt: cross cp_rw,cp_arcache,cp_isPartialRead,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent,cp_tgt_type  {  
                    ignore_bins cohops = binsof(cp_isCoherent) intersect {1}; 
                    ignore_bins wr_txn = binsof(cp_rw) intersect {1}  ;
                    ignore_bins PtlRd=  binsof(cp_isPartialRead) intersect {1} ;
                    ignore_bins dii_tgt = binsof(cp_tgt_type) intersect {DII};
                    ignore_bins illegal_txn_dmi_tgt = binsof(cp_tgt_type) intersect {DMI} && binsof(cp_arcache) intersect {4'b0000,4'b0001} ; //CONC-11546
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdRdNC};
                        ignore_bins retain_currstate_IX_NA =  binsof(cp_arcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins retain_currstate_IX_AL =  binsof(cp_arcache) intersect {4'b0110,4'b0111,4'b1110,4'b1111} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {UC};
                        ignore_bins illegal_ConcMsg_hit = binsof(cp_current_state) intersect {SC,SD,UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins retain_currstate_SC =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {SC};
                        ignore_bins retain_currstate_SD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {SD};
                        ignore_bins retain_currstate_UC =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UC};
                        ignore_bins retain_currstate_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //since This probably will never happen in a real system to hit noncoh SC/SD so adding ignore for now
                        ignore_bins currstate_SC_UD =  binsof(cp_current_state) intersect {SC,SD} ;//CONC-10915 added address alias test
                    <%} else{%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {currst_IX}  && !binsof(cp_cmd_type) intersect {CmdRdNC};
                        ignore_bins retain_currstate_IX_NA =  binsof(cp_arcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                    <%}%>
                }
                cx_noncoh_full_read_dii_tgt: cross cp_rw,cp_arcache,cp_isPartialRead,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent,cp_tgt_type {  
                    ignore_bins cohops = binsof(cp_isCoherent) intersect {1}; 
                    ignore_bins wr_txn = binsof(cp_rw) intersect {1}  ;
                    ignore_bins PtlRd=  binsof(cp_isPartialRead) intersect {1} ;
                    ignore_bins dmi_tgt = binsof(cp_tgt_type) intersect {DMI};
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdRdNC};
                        ignore_bins retain_currstate_IX_NA =  binsof(cp_arcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins retain_currstate_IX_AL =  binsof(cp_arcache) intersect {4'b0110,4'b0111,4'b1110,4'b1111} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {UC};
                        ignore_bins illegal_ConcMsg_hit = binsof(cp_current_state) intersect {SC,SD,UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins retain_currstate_SC =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {SC};
                        ignore_bins retain_currstate_SD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {SD};
                        ignore_bins retain_currstate_UC =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UC};
                        ignore_bins retain_currstate_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //since This probably will never happen in a real system to hit noncoh SC/SD so adding ignore for now
                        ignore_bins currstate_SC_UD =  binsof(cp_current_state) intersect {SC,SD} ;//CONC-10915 added address alias test
                    <%}else{%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {currst_IX}  && !binsof(cp_cmd_type) intersect {CmdRdNC};
                        ignore_bins retain_currstate_IX_NA =  binsof(cp_arcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                    <%}%>
                }
                //#Cover.IOAIU.CohReadFull
                cx_coh_full_read: cross cp_rw,cp_arcache,cp_isPartialRead,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent {  
                    ignore_bins noncohops = binsof(cp_isCoherent) intersect {0}; 
                    ignore_bins wr_txn = binsof(cp_rw) intersect {1}  ;
                    ignore_bins PtlRd=  binsof(cp_isPartialRead) intersect {1} ;
                    ignore_bins illegal_txn_dmi_tgt =  binsof(cp_arcache) intersect {4'b0000,4'b0001} ; //CONC-11546
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdRdNITC};
                        ignore_bins retain_currstate_IX_NA =  binsof(cp_arcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins illegal_ConcMsg_miss_AL = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {SC,SD,UC,UD}  && !binsof(cp_cmd_type) intersect {CmdRdVld};
                        ignore_bins retain_currstate_IX_AL =  binsof(cp_arcache) intersect {4'b0110,4'b0111,4'b1110,4'b1111} && binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {IX};
                        ignore_bins illegal_ConcMsg_hit = binsof(cp_current_state) intersect {SC,SD,UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins retain_currstate_SC =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {SC};
                        ignore_bins retain_currstate_SD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {SD};
                        ignore_bins retain_currstate_UC =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UC};
                        ignore_bins retain_currstate_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                        //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                        ignore_bins coh_nonmodifiable_access=  binsof(cp_arcache) intersect {4'b0000,4'b0001};
                    <%} else {%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {currst_IX} && binsof(cp_next_state) intersect {nextst_IX}  && !binsof(cp_cmd_type) intersect {CmdRdNITC};
                        ignore_bins retain_currstate_IX_NA =  binsof(cp_arcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                        //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                        //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                        ignore_bins coh_nonmodifiable_access=  binsof(cp_arcache) intersect {4'b0000,4'b0001};
                    <%}%>
                }
                //#Cover.IOAIU.NonCohPtlWrite
                cx_noncoh_ptl_write_dmi_tgt: cross cp_rw,cp_awcache,cp_isPartialWrite,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent,cp_tgt_type  {  
                    ignore_bins cohops = binsof(cp_isCoherent) intersect {1}; 
                    ignore_bins rd_txn = binsof(cp_rw) intersect {2}  ;
                    ignore_bins FullWr=  binsof(cp_isPartialWrite) intersect {0} ;
                    ignore_bins dii_tgt = binsof(cp_tgt_type) intersect {DII};
                    ignore_bins illegal_txn_dmi_tgt = binsof(cp_tgt_type) intersect {DMI} && binsof(cp_awcache) intersect {4'b0000,4'b0001} ; //CONC-11546
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdWrNCPtl};
                        ignore_bins retain_currstate_IX =  binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins illegal_ConcMsg_hit = binsof(cp_current_state) intersect {SC,SD,UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins change_currstate_SC_UD =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_SD_UD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UC_UD =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UD_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //since This probably will never happen in a real system to hit noncoh SC/SD so adding ignore for now
                        ignore_bins currstate_SC_UD =  binsof(cp_current_state) intersect {SC,SD} ;//CONC-10915 added address alias test
                    <%}else {%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {currst_IX}  && !binsof(cp_cmd_type) intersect {CmdWrNCPtl};
                        ignore_bins retain_currstate_IX =  binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                    <%}%>
                }
                cx_noncoh_ptl_write_dii_tgt: cross cp_rw,cp_awcache,cp_isPartialWrite,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent,cp_tgt_type{  
                    ignore_bins cohops = binsof(cp_isCoherent) intersect {1}; 
                    ignore_bins rd_txn = binsof(cp_rw) intersect {2}  ;
                    ignore_bins FullWr=  binsof(cp_isPartialWrite) intersect {0} ;
                    ignore_bins dmi_tgt = binsof(cp_tgt_type) intersect {DMI};
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdWrNCPtl};
                        ignore_bins retain_currstate_IX =  binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins illegal_ConcMsg_hit = binsof(cp_current_state) intersect {SC,SD,UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins change_currstate_SC_UD =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_SD_UD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UC_UD =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UD_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //since This probably will never happen in a real system to hit noncoh SC/SD so adding ignore for now
                        ignore_bins currstate_SC_UD =  binsof(cp_current_state) intersect {SC,SD} ;//CONC-10915 added address alias test
                    <%}else{%>
                        ignore_bins illegal_ConcMsg_miss = binsof(cp_current_state) intersect {currst_IX}  && !binsof(cp_cmd_type) intersect {CmdWrNCPtl};
                        ignore_bins retain_currstate_IX =  binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                    <%}%>
                }
                //#Cover.IOAIU.CohWritePtl
                cx_coh_ptl_write: cross cp_rw,cp_awcache,cp_isPartialWrite,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent {  
                    ignore_bins noncohops = binsof(cp_isCoherent) intersect {0}; 
                    ignore_bins rd_txn = binsof(cp_rw) intersect {2}  ;
                    ignore_bins FullRd=  binsof(cp_isPartialWrite) intersect {0} ;
                    ignore_bins illegal_txn_dmi_tgt =  binsof(cp_awcache) intersect {4'b0000,4'b0001} ; //CONC-11546
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdWrUnqPtl};
                        ignore_bins retain_currstate_IX =  binsof(cp_awcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins illegal_ConcMsg_miss_AL = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {UD}  && !binsof(cp_cmd_type) intersect {CmdRdUnq};
                        ignore_bins change_currstate_IX_UD =  binsof(cp_awcache) intersect {4'b1010,4'b1011,4'b1110,4'b1111} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {UD};

                        ignore_bins illegal_ConcMsg_hit_1 = binsof(cp_current_state) intersect {SC,SD} && !binsof(cp_cmd_type) intersect {CmdRdUnq};
                        ignore_bins illegal_ConcMsg_hit_2 = binsof(cp_current_state) intersect {UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins change_currstate_SC_UD =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_SD_UD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UC_UD =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UD_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                        //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                        ignore_bins coh_nonmodifiable_access=  binsof(cp_awcache) intersect {4'b0000,4'b0001};
                    <%}else{%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {currst_IX} && binsof(cp_next_state) intersect {nextst_IX}  && !binsof(cp_cmd_type) intersect {CmdWrUnqPtl};
                        ignore_bins retain_currstate_IX =  binsof(cp_awcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                        //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                        //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                        ignore_bins coh_nonmodifiable_access=  binsof(cp_awcache) intersect {4'b0000,4'b0001};
                    <%}%>
                }
                //#Cover.IOAIU.NonCohFullWrite
                cx_noncoh_full_write_dmi_tgt: cross cp_rw,cp_awcache,cp_isPartialWrite,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent,cp_tgt_type{  
                    ignore_bins cohops = binsof(cp_isCoherent) intersect {1}; 
                    ignore_bins rd_txn = binsof(cp_rw) intersect {2}  ;
                    ignore_bins PtlWr=  binsof(cp_isPartialWrite) intersect {1} ;
                    ignore_bins dii_tgt = binsof(cp_tgt_type) intersect {DII};
                    ignore_bins illegal_txn_dmi_tgt = binsof(cp_tgt_type) intersect {DMI} && binsof(cp_awcache) intersect {4'b0000,4'b0001} ; //CONC-11546
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdWrNCFull};
                        ignore_bins retain_currstate_IX =  binsof(cp_awcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins illegal_ConcMsg_miss_AL = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {UD}  && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins illegal_ConcMsg_hit = binsof(cp_current_state) intersect {SC,SD,UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins change_currstate_IX_UD =  binsof(cp_awcache) intersect {4'b1010,4'b1011,4'b1110,4'b1111} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_SC_UD =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_SD_UD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UC_UD =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UD_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //since This probably will never happen in a real system to hit noncoh SC/SD so adding ignore for now
                        ignore_bins currstate_SC_UD =  binsof(cp_current_state) intersect {SC,SD} ;//CONC-10915 added address alias test
                    <%}else{%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {currst_IX} && binsof(cp_next_state) intersect {nextst_IX}  && !binsof(cp_cmd_type) intersect {CmdWrNCFull};
                        ignore_bins retain_currstate_IX =  binsof(cp_awcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                    <%}%>
                }
                cx_noncoh_full_write_dii_tgt: cross cp_rw,cp_awcache,cp_isPartialWrite,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent,cp_tgt_type  {  
                    ignore_bins cohops = binsof(cp_isCoherent) intersect {1}; 
                    ignore_bins rd_txn = binsof(cp_rw) intersect {2}  ;
                    ignore_bins PtlWr=  binsof(cp_isPartialWrite) intersect {1} ;
                    ignore_bins dmi_tgt = binsof(cp_tgt_type) intersect {DMI};
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdWrNCFull};
                        ignore_bins retain_currstate_IX =  binsof(cp_awcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins illegal_ConcMsg_miss_AL = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {UD}  && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins illegal_ConcMsg_hit = binsof(cp_current_state) intersect {SC,SD,UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins change_currstate_IX_UD =  binsof(cp_awcache) intersect {4'b1010,4'b1011,4'b1110,4'b1111} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_SC_UD =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_SD_UD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UC_UD =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UD_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //since This probably will never happen in a real system to hit noncoh SC/SD so adding ignore for now
                        ignore_bins currstate_SC_UD =  binsof(cp_current_state) intersect {SC,SD} ;//CONC-10915 added address alias test
                    <%}else{%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {currst_IX} && binsof(cp_next_state) intersect {nextst_IX}  && !binsof(cp_cmd_type) intersect {CmdWrNCFull};
                        ignore_bins retain_currstate_IX =  binsof(cp_awcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                    <%}%>
                }
                //#Cover.IOAIU.CohWriteFull
                cx_coh_full_write: cross cp_rw,cp_awcache,cp_isPartialWrite,cp_current_state,cp_next_state,cp_cmd_type,cp_isCoherent{  
                    ignore_bins noncohops = binsof(cp_isCoherent) intersect {0}; 
                    ignore_bins rd_txn = binsof(cp_rw) intersect {2}  ;
                    ignore_bins PtlRd=  binsof(cp_isPartialWrite) intersect {1} ;
                    ignore_bins illegal_txn_dmi_tgt =  binsof(cp_awcache) intersect {4'b0000,4'b0001} ; //CONC-11546
                    <%if(obj.useCache) {%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {IX}  && !binsof(cp_cmd_type) intersect {CmdWrUnqFull};
                        ignore_bins retain_currstate_IX =  binsof(cp_awcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {IX};
                        ignore_bins illegal_ConcMsg_miss_AL = binsof(cp_current_state) intersect {IX} && binsof(cp_next_state) intersect {UD}  && !binsof(cp_cmd_type) intersect {CmdMkUnq};
                        ignore_bins change_currstate_IX_UD =  binsof(cp_awcache) intersect {4'b1010,4'b1011,4'b1110,4'b1111} && binsof(cp_current_state) intersect {IX} && !binsof(cp_next_state) intersect {UD};

                        ignore_bins illegal_ConcMsg_hit_1 = binsof(cp_current_state) intersect {SC,SD} && !binsof(cp_cmd_type) intersect {CmdMkUnq};
                        ignore_bins illegal_ConcMsg_hit_2 = binsof(cp_current_state) intersect {UC,UD} && !binsof(cp_cmd_type) intersect {NoMsg};
                        ignore_bins change_currstate_SC_UD =  binsof(cp_current_state) intersect {SC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_SD_UD =  binsof(cp_current_state) intersect {SD} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UC_UD =  binsof(cp_current_state) intersect {UC} && !binsof(cp_next_state) intersect {UD};
                        ignore_bins change_currstate_UD_UD =  binsof(cp_current_state) intersect {UD} && !binsof(cp_next_state) intersect {UD};
                        //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                        //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                        ignore_bins coh_nonmodifiable_access=  binsof(cp_awcache) intersect {4'b0000,4'b0001};
                    <%}else{%>
                        ignore_bins illegal_ConcMsg_miss_NA = binsof(cp_current_state) intersect {currst_IX} && binsof(cp_next_state) intersect {nextst_IX}  && !binsof(cp_cmd_type) intersect {CmdWrUnqFull};
                        ignore_bins retain_currstate_IX =  binsof(cp_awcache) intersect {4'b0000,4'b0001,4'b0010,4'b0011} && binsof(cp_current_state) intersect {currst_IX} && !binsof(cp_next_state) intersect {nextst_IX};
                        //https://arterisip.atlassian.net/browse/CONC-6965?focusedCommentId=508042
                        //Any thing that hits a coherent configured GPRA must not be device/non-modifiable accesses
                        ignore_bins coh_nonmodifiable_access=  binsof(cp_awcache) intersect {4'b0000,4'b0001};
                    <%}%>
                }
            endgroup//ccp_coh_noncoh_ops_cg
        <%}%>
        <%if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" ) {%>
        //#Cover.IOAIU.SMI.SNPReq.CMType
        //#Cover.IOAIU.SMI.SnpRsp.CMType
        //#Cover.IOAIU.SMI.SnpRsp.Cmstatus
            covergroup ace_snprsp_core<%=port%>;

                cp_SnpReq_SnpNITC: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpNITC      = {SNP_NITC};
                }
                cp_SnpRsp_SnpNITCdtr :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                  bins rv_1_rs_1_dc_0_dtaiu_0_dtdmi_0 = {'b11000};
                  bins rv_1_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b10000};
                  bins rv_0_rs_0_dc_0_dtaiu_1_dtdmi_0 = {'b00010};
                  bins rv_1_rs_1_dc_0_dtaiu_1_dtdmi_0 = {'b11010};
                  bins rv_1_rs_0_dc_0_dtaiu_1_dtdmi_0 = {'b10010};
                  bins rv_0_rs_0_dc_0_dtaiu_1_dtdmi_1 = {'b00011};
                  bins rv_1_rs_1_dc_0_dtaiu_1_dtdmi_1 = {'b11011};
                  bins rv_1_rs_0_dc_0_dtaiu_1_dtdmi_1 = {'b10011};
                }
                cx_SnpRsp_SnpNITCdtr:cross cp_SnpReq_SnpNITC,cp_SnpRsp_SnpNITCdtr {
                }
                cp_SnpReq_SnpNITCCIDtr: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpNITCCI      = {SNP_NITCCI};
                }
                cp_snprsp_snpnitccidtr :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                  bins rv_0_rs_0_dc_0_dtaiu_1_dtdmi_0 = {'b00010};
                  bins rv_0_rs_0_dc_0_dtaiu_1_dtdmi_1 = {'b00011};
                }
                cx_snprsp_snpnitccidtr:cross cp_SnpReq_SnpNITCCIDtr,cp_snprsp_snpnitccidtr {
                }
                cp_SnpReq_SnpNITCMIDtr: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpNITCMI      = {SNP_NITCMI};
                }
                cp_snprsp_snpnitcmidtr :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                  bins rv_0_rs_0_dc_0_dtaiu_1_dtdmi_0 = {'b00010};
                  bins rv_0_rs_0_dc_0_dtaiu_1_dtdmi_1 = {'b00011};
                }
                cx_snprsp_snpnitcmidtr:cross cp_SnpReq_SnpNITCMIDtr,cp_snprsp_snpnitcmidtr {
                }
                cp_SnpReq_SnpCLNDtr: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpCLNDtr      = {SNP_CLN_DTR};
                }
                cp_snprsp_snpclndtr :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                  bins rv_1_rs_1_dc_0_dtaiu_0_dtdmi_0 = {'b11000};
                  bins rv_0_rs_0_dc_1_dtaiu_1_dtdmi_0 = {'b00110};
                  bins rv_0_rs_0_dc_0_dtaiu_1_dtdmi_0 = {'b00010};
                  bins rv_1_rs_1_dc_0_dtaiu_1_dtdmi_0 = {'b11010};
                  bins rv_1_rs_0_dc_0_dtaiu_1_dtdmi_0 = {'b10010};
                  bins rv_0_rs_0_dc_0_dtaiu_1_dtdmi_1 = {'b00011};
                  bins rv_0_rs_0_dc_1_dtaiu_1_dtdmi_1 = {'b00111};
                  bins rv_1_rs_1_dc_0_dtaiu_1_dtdmi_1 = {'b11011};
                }
                cx_snprsp_snpclncdtr:cross cp_SnpReq_SnpCLNDtr,cp_snprsp_snpclndtr {
                }



                cp_SnpReq_SnpVldDtr: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpVldDtr      = {SNP_VLD_DTR};
                }
                cp_SnpRsp_SnpVldDtr :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                  bins rv_1_rs_1_dc_0_dtaiu_0_dtdmi_0 = {'b11000};
                  bins rv_0_rs_0_dc_0_dtaiu_1_dtdmi_0 = {'b00010};
                  bins rv_1_rs_1_dc_0_dtaiu_1_dtdmi_0 = {'b11010};
                  bins rv_1_rs_0_dc_0_dtaiu_1_dtdmi_1 = {'b10011};
                  bins rv_0_rs_0_dc_1_dtaiu_1_dtdmi_0 = {'b00110};
                  bins rv_1_rs_0_dc_0_dtaiu_1_dtdmi_0 = {'b10010};
                  bins rv_1_rs_1_dc_1_dtaiu_0_dtdmi_0 = {'b11100};
                  bins rv_0_rs_0_dc_1_dtaiu_1_dtdmi_1 = {'b00111};
                }
                cx_SnpRsp_SnpVldDtr:cross cp_SnpReq_SnpVldDtr,cp_SnpRsp_SnpVldDtr {
                }
                cp_SnpReq_SnpInvDtr: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpInvDtr      = {SNP_INV_DTR};
                }
                cp_SnpRsp_SnpInvDtr :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_1 = {'b00001};
                  bins rv_0_rs_0_dc_1_dtaiu_1_dtdmi_0 = {'b00110};
                  bins rv_0_rs_0_dc_1_dtaiu_1_dtdmi_1 = {'b00111};
                }
                cx_SnpRsp_SnpInvDtr:cross cp_SnpReq_SnpInvDtr,cp_SnpRsp_SnpInvDtr {
                }
                cp_SnpReq_SnpNoSDInt: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpNoSDInt      = {SNP_NOSDINT};
                }
                cp_SnpRsp_SnpNoSDInt :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                  bins rv_1_rs_1_dc_0_dtaiu_0_dtdmi_0 = {'b11000};
                  bins rv_0_rs_0_dc_0_dtaiu_1_dtdmi_0 = {'b00010};
                  bins rv_1_rs_1_dc_0_dtaiu_1_dtdmi_0 = {'b11010};
                  bins rv_0_rs_0_dc_1_dtaiu_1_dtdmi_0 = {'b00110};
                  bins rv_1_rs_0_dc_0_dtaiu_1_dtdmi_0 = {'b10010};
                  bins rv_0_rs_0_dc_1_dtaiu_1_dtdmi_1 = {'b00111};
                  bins rv_0_rs_0_dc_0_dtaiu_1_dtdmi_1 = {'b00011};
                  bins rv_1_rs_0_dc_1_dtaiu_1_dtdmi_1 = {'b11011};
                }
                cx_SnpRsp_SnpNoSDInt:cross cp_SnpReq_SnpNoSDInt,cp_SnpRsp_SnpNoSDInt {
                }
                  cp_SnpReq_SnpInvDtw: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpInvDtw      = {SNP_INV_DTW};
                }

                cp_SnpRsp_SnpInvDtw :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_1 = {'b00001};
                }
                cx_SnpRsp_SnpInvDtw:cross cp_SnpReq_SnpInvDtw,cp_SnpRsp_SnpInvDtw {
                }
                cp_SnpReq_SnpInv: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpInv      = {SNP_INV};
                }

                cp_SnpRsp_SnpInv :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                }
                cx_SnpRsp_SnpInv:cross cp_SnpReq_SnpInv,cp_SnpRsp_SnpInv {
                }
                cp_SnpReq_SnpInvStsh: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpInvStsh      = {SNP_INV_STSH};
                }

                cp_SnpRsp_SnpInvStsh :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                }
                cx_SnpRsp_SnpInvStsh:cross cp_SnpReq_SnpInvStsh,cp_SnpRsp_SnpInvStsh {
                }
                cp_SnpReq_SnpUnqStsh: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpUnqStsh      = {SNP_UNQ_STSH};
                }

                cp_SnpRsp_SnpUnqStsh :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                }
                cx_SnpRsp_SnpUnqStsh:cross cp_SnpReq_SnpUnqStsh,cp_SnpRsp_SnpUnqStsh {
                }
                 cp_SnpReq_SnpStshShd: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpStshShd      = {SNP_STSH_SH};
                }

                cp_SnpRsp_SnpStshShd :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_1 = {'b00001};
                }
                cx_SnpRsp_SnpStshShd:cross cp_SnpReq_SnpStshShd,cp_SnpRsp_SnpStshShd {
                }
                cp_SnpReq_SnpStshUnq: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                  bins SnpReqMsgType_SnpStshUnq      = {SNP_STSH_UNQ};
                }

                cp_SnpRsp_SnpStshUnq :coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_0 = {'b00000};
                  bins rv_0_rs_0_dc_0_dtaiu_0_dtdmi_1 = {'b00001};
                }
                cx_SnpRsp_SnpStshUnq:cross cp_SnpReq_SnpStshUnq,cp_SnpRsp_SnpStshUnq {
                }

            endgroup//ace_snprsp_core
        <%}%>

        <%if(obj.useCache) {%>
            covergroup ccp_state_snprsp_core<%=port%>;// ConcertoCProtocolArch_0_90_NoCB.pdf  p.457-459 Proxy Cache Responses to CCMP snoop->Updated wrt Proxy Cache Update ARCH-3.4
                coverpoint_SnpReq_msgType: coverpoint m_scb_txn.m_snp_req_pkt.smi_msg_type {
                    bins SnpReqMsgType_SnpClnDtr    = {SNP_CLN_DTR};
                    bins SnpReqMsgType_SnpNITC      = {SNP_NITC};
                    bins SnpReqMsgType_SnpVldDtr    = {SNP_VLD_DTR};
                    bins SnpReqMsgType_SnpInvDtr    = {SNP_INV_DTR};
                    bins SnpReqMsgType_SnpInvDtw    = {SNP_INV_DTW};
                    bins SnpReqMsgType_SnpInv       = {SNP_INV};
                    bins SnpReqMsgType_SnpClnDtw    = {SNP_CLN_DTW};
                    bins SnpReqMsgType_SnpNoSDInt   = {SNP_NOSDINT};
                    bins SnpReqMsgType_SnpInvStsh   = {SNP_INV_STSH};
                    bins SnpReqMsgType_SnpUnqStsh   = {SNP_UNQ_STSH};
                    bins SnpReqMsgType_SnpStshShd   = {SNP_STSH_SH};
                    bins SnpReqMsgType_SnpStshUnq   = {SNP_STSH_UNQ};
                    bins SnpReqMsgType_SnpNITCCI    = {SNP_NITCCI};
                    bins SnpReqMsgType_SnpNITCMI    = {SNP_NITCMI};
                    bins SnpReq_Ignore =default; 	
                } 
                coverpoint_SnpRsp_cmstatus: coverpoint m_scb_txn.m_snp_rsp_pkt.smi_cmstatus[5:1] {
                        bins SnpRspCmStatus_RV_RS_DC_DTAiu_DTDmi[] = {'b00000, 'b11000, 'b11010, 'b10010, 'b11110, 'b00110, 'b00001, 'b00011, 'b00010, 'b11001, 'b10001, 'b10000};
                    	bins SnpRsp_Ignore =default; 	
                    }
                snp_ccp_next_state: coverpoint ccp_next_state {
                    bins IX = {IX};
                    bins SC = {SC};
                    bins SD = {SD};
                    bins UC = {UC};
                    bins UD = {UD};
                }
                snp_ccp_current_state: coverpoint ccp_current_state {
                    bins IX = {IX};
                    bins SC = {SC};
                    bins SD = {SD};
                    bins UC = {UC};
                    bins UD = {UD};
                }
                cross_IOC_SnpRespTypeXccpStatesXcmstatus:  cross coverpoint_SnpReq_msgType,snp_ccp_current_state,snp_ccp_next_state,coverpoint_SnpRsp_cmstatus {
                    // reminder: CMSTATUS bit : RV | RS | DC | DTr | DTw
                    // ConcertoCProtocolArch_0_90_NoCB.pdf  p.457-459 Proxy Cache Responses to CCMP snoops
                    //#Cov.IOAIU.CCP.SnpClnDtr
                    ignore_bins SnpClnDtr_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpClnDtr) 
                                    && ( (!binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&  (!binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {SC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11010, 5'b11000})
                                    &&  (!binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {SD}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b10010})
                                    &&  (!binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {SC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11010})
                                    &&  (!binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {SD}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b10010})
                                        );					
                        //#Cov.IOAIU.CCP.SnpNoSDInt
                        ignore_bins SnpNoSDInt_illegal =  binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNoSDInt)               
                                    && ((!binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    && (!binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {SC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11000, 5'b11010})
                                    && (!binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {SD}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b10010})
                                    && (!binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {SC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11010})
                                    && (!binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {SD}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b10010})
                                        );
                        //#Cov.IOAIU.CCP.SnpVldDtr
                        ignore_bins SnpVldDtr_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpVldDtr)               
                                    && ((!binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&  (!binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {SC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11000, 5'b11010})
                                    &&  (!binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {SC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11110})
                                    &&  (!binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {SC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11110})
                                    &&  (!binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {SC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11110})
                                    );
                        //#Cov.IOAIU.CCP.SnpInvDtr
                        ignore_bins SnpInvDtr_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpInvDtr)               
                                        && ((!binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                        && (!binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00110,5'b00001})
                                        && (!binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00110,5'b00001})
                                        && (!binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00110})
                                        && (!binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00110})										
                                        );
                        //#Cov.IOAIU.CCP.SnpNITC
                        ignore_bins SnpNITC_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNITC)               
                                        && (( !binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                        && (!binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {SC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11000, 5'b11010})
                                        && (!binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {SD}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b10010})
                                        && (!binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {UC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b10010})
                                        && (!binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {UD}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b10010})						 
                                        ); 
                        //#Cov.IOAIU.CCP.SnpNITCCI
                        ignore_bins SnpNITCCI_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNITCCI)               
                                        && ((!binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                        && (!binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000,5'b00010})
                                        && (!binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00011})
                                        && (!binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00010})
                                        && (!binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00011})
                                        );
                        //#Cov.IOAIU.CCP.SnpNITCMI
                        ignore_bins SnpNITCMI_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNITCMI)               
                                        && ((!binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                        && (!binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000,5'b00010})
                                        && (!binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00010})
                                        && (!binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00010})
                                        && (!binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00010})
                                        );
                        //#Cov.IOAIU.CCP.SnpClnDtw
                        ignore_bins SnpClnDtw_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpClnDtw) 
                                        &&(( !binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                        &&( !binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {SC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11000})
                                        &&( !binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {SC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11001})
                                        &&( !binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {UC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b10000})
                                        &&( !binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {UC}
                                        || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b10001})
                                        );
                        //#Cov.IOAIU.CCP.SnpInvDtw
                        ignore_bins SnpInvDtw_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpInvDtw)               
                                    &&(( !binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&( !binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&( !binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00001})
                                    &&( !binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&( !binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00001})
                                    );
                        //#Cov.IOAIU.CCP.SnpUnqStsh
                        ignore_bins SnpUnqStsh_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpUnqStsh)               
                                    && (( !binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&( !binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&( !binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00001})
                                    &&( !binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&( !binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00001})	
                                    );
                        //#Cov.IOAIU.CCP.SnpStshUnq
                        ignore_bins SnpStshUnq_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpStshUnq)               
                                    &&(( !binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&( !binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&( !binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00001})
                                    &&( !binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&( !binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00001})
                                    );
                        //#Cov.IOAIU.CCP.SnpInv
                        ignore_bins SnpInv_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpInv)               
                                    && ( !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000}
                                    );
                        //#Cov.IOAIU.CCP.SnpInvStsh
                        ignore_bins SnpInvStsh_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpInvStsh)               
                                    &&( !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000}	
                                    );
                        //#Cov.IOAIU.CCP.SnpStshShd
                        ignore_bins SnpStshShd_illegal = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpStshShd) 
                                    &&(( !binsof(snp_ccp_current_state) intersect {IX} || !binsof(snp_ccp_next_state) intersect {IX}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000})
                                    &&( !binsof(snp_ccp_current_state) intersect {SC} || !binsof(snp_ccp_next_state) intersect {SC}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11000})
                                    &&( !binsof(snp_ccp_current_state) intersect {SD} || !binsof(snp_ccp_next_state) intersect {SD}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b10001})
                                    &&( !binsof(snp_ccp_current_state) intersect {UC} || !binsof(snp_ccp_next_state) intersect {SC}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b11000})
                                    &&( !binsof(snp_ccp_current_state) intersect {UD} || !binsof(snp_ccp_next_state) intersect {SD}
                                    || !binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b10001})
                                    );
                }
            endgroup

            covergroup ccp_state_cmdreq_core<%=port%>; // cf ConcertoCPRotocolArch_0_90_NoCB.pdf p457 Proxy Cache state transitions as a function of issued CCMP commands
                // Cove use only cross case
                rw: coverpoint {m_scb_txn.isRead,m_scb_txn.isWrite} {
                    bins Read  = {2'b10};
                    bins Write = {2'b01};
                    bins noRW  = default;
                }
            
                cmd_type: coverpoint  m_scb_txn.m_cmd_req_pkt.smi_msg_type {
                    bins CmdRdNITC = {eCmdRdNITC};
                    bins CmdRdVld  = {eCmdRdVld};
                    bins CmdRdUnq  = {eCmdRdUnq};
                    bins CmdMkUnq  = {eCmdMkUnq};
                    bins CmdIgnore = default;
                }
                dtr_type: coverpoint  m_scb_txn.m_dtr_req_pkt.smi_msg_type {
                bins DtrDataInv  = {eDtrDataInv};
                bins DtrDataSCln = {eDtrDataShrCln};
                bins DtrDataSDty = {eDtrDataShrDty};
                bins DtrDataUCln = {eDtrDataUnqCln};
                bins DtrDataUDty = {eDtrDataUnqDty};
                bins DtrIgnore = default;
                }
                isPartialWrite: coverpoint m_scb_txn.isPartialWrite {
                    bins PtlWr   = {1};
                    bins NoPtlWr = {0};
                }
               <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
               `ifndef VCS
                ccp_current_state: coverpoint ccp_current_state {
               `else // `ifndef VCS
                ccp_current_state_vcs: coverpoint ccp_current_state {
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                ccp_current_state: coverpoint ccp_current_state {
               <% } %>
                bins IX = {IX};
                bins SC = {SC};
                bins SD = {SD};
                bins UC = {UC};
                bins UD = {UD};
                }
                ccp_next_state: coverpoint ccp_next_state {
                bins IX = {IX};
                bins SC = {SC};
                bins SD = {SD};
                bins UC = {UC};
                bins UD = {UD};
                }
                // cf ConcertoCPRotocolArch_0_90_NoCB.pdf p457 Proxy Cache state transitions as a function of issued CCMP commands
               <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
               `ifndef VCS
                cross_IOC_cmdreqXccpStatesXdtrType: cross rw,cmd_type,isPartialWrite,ccp_current_state,dtr_type,ccp_next_state {
               `else // `ifndef VCS
                cross_IOC_cmdreqXccpStatesXdtrType: cross rw,cmd_type,isPartialWrite,ccp_current_state_vcs,dtr_type,ccp_next_state {
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                cross_IOC_cmdreqXccpStatesXdtrType: cross rw,cmd_type,isPartialWrite,ccp_current_state,dtr_type,ccp_next_state {
               <% } %>
                    option.cross_auto_bin_max = 0;
                    //#Cov.IOAIU.CCP.CmdRdNITC
                    bins CmdRdNITC_IX_DtrDataInv_IX = binsof(rw.Read) && binsof(cmd_type.CmdRdNITC) 
                                                    && binsof(ccp_current_state.IX) && binsof(dtr_type.DtrDataInv) && binsof(ccp_next_state.IX); 
                    //#Cov.IOAIU.CCP.CmdRdVld
                    bins CmdRdVld_IX_DtrDataSCln_SC = binsof(rw.Read) && binsof(cmd_type.CmdRdVld) 
                                                    && binsof(ccp_current_state.IX) && binsof(dtr_type.DtrDataSCln) && binsof(ccp_next_state.SC); 
                    bins CmdRdVld_IX_DtrDataSDty_SD = binsof(rw.Read) && binsof(cmd_type.CmdRdVld)  
                                                    && binsof(ccp_current_state.IX) && binsof(dtr_type.DtrDataSDty) && binsof(ccp_next_state.SD); 
                    bins CmdRdVld_IX_DtrDataUCln_UC = binsof(rw.Read) && binsof(cmd_type.CmdRdVld)  
                                                    && binsof(ccp_current_state.IX) && binsof(dtr_type.DtrDataUCln) && binsof(ccp_next_state.UC); 
                    bins CmdRdVld_IX_DtrDataUDty_UD = binsof(rw.Read) && binsof(cmd_type.CmdRdVld)  
                                                    && binsof(ccp_current_state.IX) && binsof(dtr_type.DtrDataUDty) && binsof(ccp_next_state.UD); 
                    //#Cov.IOAIU.CCP.CmdRdUnq.Read
                    //TMP REMOVE WAIT CONC-9081//bins CmdRdUnq_IX_DtrDataUCln_UC_Rd = binsof(rw.Read) && binsof(cmd_type.CmdRdUnq)  
                    //TMP REMOVE WAIT CONC-9081//                                && binsof(ccp_current_state.IX) && binsof(dtr_type.DtrDataUCln) && binsof(ccp_next_state.UC); 
                    //TMP REMOVE WAIT CONC-9081//bins CmdRdUnq_IX_DtrDataUDty_UD_Rd = binsof(rw.Read) && binsof(cmd_type.CmdRdUnq) 
                    //TMP REMOVE WAIT CONC-9081//                                && binsof(ccp_current_state.IX) && binsof(dtr_type.DtrDataUDty) && binsof(ccp_next_state.UD); 
                    //#Cov.IOAIU.CCP.CmdRdUnq.Write
                    bins CmdRdUnq_IX_DtrDataU_UD_Wr = binsof(rw.Write) && binsof(cmd_type.CmdRdUnq) && binsof(isPartialWrite.PtlWr) 
                                                    && binsof(ccp_current_state.IX) && (binsof(dtr_type.DtrDataUDty) || binsof(dtr_type.DtrDataUCln) ) && binsof(ccp_next_state.UD); 
                    bins CmdRdUnq_SC_DtrDataU_UD_Wr = binsof(rw.Write) && binsof(cmd_type.CmdRdUnq) && binsof(isPartialWrite.PtlWr) 
                                                    && binsof(ccp_current_state.SC) && (binsof(dtr_type.DtrDataUDty) || binsof(dtr_type.DtrDataUCln) ) && binsof(ccp_next_state.UD); 
                    bins CmdRdUnq_SD_DtrDataU_UD_wr = binsof(rw.Write) && binsof(cmd_type.CmdRdUnq) && binsof(isPartialWrite.PtlWr) 
                                                    && binsof(ccp_current_state.SD) && (binsof(dtr_type.DtrDataUDty) || binsof(dtr_type.DtrDataUCln) ) && binsof(ccp_next_state.UD); 
                    //#Cov.IOAIU.CCP.CmdMkUnq
                    bins CmdMkUnq_IX_UD = binsof(rw.Write) && binsof(cmd_type.CmdMkUnq) 
                                                    && binsof(ccp_current_state.IX) && binsof(ccp_next_state.UD); 
                    bins CmdMkUnq_SC_UD = binsof(rw.Write) && binsof(cmd_type.CmdMkUnq) 
                                                    && binsof(ccp_current_state.SC) && binsof(ccp_next_state.UD); 
                    bins CmdMkUnq_SD_UD = binsof(rw.Write) && binsof(cmd_type.CmdMkUnq) 
                                                    && binsof(ccp_current_state.SD) && binsof(ccp_next_state.UD); 
                }
                drop_dtr_data: coverpoint m_scb_txn.dropDtrData{
                    bins drop_0 = {0};
                    bins drop_1 = {1};
                }
                ccp_state_on_dtr_req: coverpoint m_scb_txn.ccp_state_on_DTRreq{
                    bins IX = {IX};
                    bins SC = {SC};
                    bins SD = {SD};
                    ignore_bins Ignore_UC_UD = {UC,UD};
                }
               <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
               `ifndef VCS
                drop_dtr_data_x_ccp_state_on_dtr_req: cross drop_dtr_data, ccp_state_on_dtr_req iff {m_scb_txn.isPartialWrite ==1 && ccp_current_state == SD}{
               `else // `ifndef VCS
                drop_dtr_data_x_ccp_state_on_dtr_req: cross drop_dtr_data, ccp_state_on_dtr_req iff (m_scb_txn.isPartialWrite ==1 && ccp_current_state == SD){
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                drop_dtr_data_x_ccp_state_on_dtr_req: cross drop_dtr_data, ccp_state_on_dtr_req iff {m_scb_txn.isPartialWrite ==1 && ccp_current_state == SD}{
               <% } %>
                    ignore_bins Ignore_drop_0 = binsof(drop_dtr_data.drop_0) && (binsof(ccp_state_on_dtr_req.SC) ||  binsof(ccp_state_on_dtr_req.SD));
                    ignore_bins Ignore_drop_1 = binsof(drop_dtr_data.drop_1) && (binsof(ccp_state_on_dtr_req.IX));
                }
            endgroup

            covergroup ccp_state_Nativereq_to_cmdreq_core<%=port%>; // cf ConcertoCPRotocolArch_0_90_NoCB.pdf p456 CCMP CMDreq generated in response to Native request transaction
                // Cove use only cross case
                rw: coverpoint {m_scb_txn.isRead,m_scb_txn.isWrite} {
                    bins Read  = {2'b10};
                    bins Write = {2'b01};
                    bins noRW  = default;
                }
                allocate: coverpoint m_scb_txn.m_iocache_allocate {
                    bins al = {1};
                    bins na = {0};
                }
                cmd_type: coverpoint  m_scb_txn.m_cmd_req_pkt.smi_msg_type {
                    bins CmdRdNITC = {eCmdRdNITC};
                    bins CmdRdVld  = {eCmdRdVld};
                    bins CmdRdUnq  = {eCmdRdUnq};
                    bins CmdWrUnqPtl   = {eCmdWrUnqPtl};
                    bins CmdWrUnqFull  = {eCmdWrUnqFull};
                    bins CmdMkUnq  = {eCmdMkUnq};
                    bins CmdIgnore = default;
                }
                isPartialWrite: coverpoint m_scb_txn.isPartialWrite {
                    bins PtlWr   = {1};
                    bins NoPtlWr = {0};
                }
                ccp_current_state: coverpoint ccp_current_state {
                    bins IX = {IX};
                    bins SC = {SC};
                    bins SD = {SD};
                    bins UC = {UC};
                    bins UD = {UD};
                }
                ccp_next_state: coverpoint ccp_next_state {
                    bins IX = {IX};
                    bins SC = {SC};
                    bins SD = {SD};
                    bins UC = {UC};
                    bins UD = {UD};
                }
                aRcache: coverpoint  m_scb_txn.m_ace_read_addr_pkt.arcache[2] {
                    bins Ralloc ={1};
                    bins noRalloc = {0};
                }
                aWcache: coverpoint  m_scb_txn.m_ace_write_addr_pkt.awcache[3] {
                    bins Walloc = {1};
                    bins noWalloc = {0};
                }
                cmd_alloc: coverpoint  m_scb_txn.m_cmd_req_pkt.smi_msg_type {
                    bins CmdNoAlloc[] = {eCmdRdNITC,eCmdWrUnqPtl,eCmdWrUnqFull};
                    bins CmdAlloc[]  = {eCmdRdVld,eCmdRdUnq,eCmdMkUnq};
                    bins CmdDontCareAlloc[] = {eCmdMkUnq,0};
                    bins CmdIgnore = default;
                }
                //#Cov.IOAIU.CCP.aRcache
                cross_IOC_axi4XaRcacheXcmdAlloc: cross rw,aRcache,cmd_alloc {
                    ignore_bins ReadIgnore = binsof(rw.Read) && (binsof(cmd_alloc.CmdNoAlloc) intersect {eCmdWrUnqPtl,eCmdWrUnqFull} || binsof(cmd_alloc.CmdAlloc) intersect {eCmdRdUnq,eCmdMkUnq} || binsof(cmd_alloc.CmdDontCareAlloc) intersect {eCmdMkUnq});
                    ignore_bins WriteIgnore = binsof(rw.Write);
                    ignore_bins RallocIgnore = binsof(rw.Read) && binsof(aRcache.Ralloc) && (binsof(cmd_alloc.CmdNoAlloc) || binsof(cmd_alloc.CmdAlloc) intersect {eCmdRdUnq,eCmdMkUnq} || binsof(cmd_alloc.CmdDontCareAlloc) intersect {eCmdMkUnq});
                    ignore_bins noRallocIgnore = binsof(rw.Read) && binsof(aRcache.noRalloc) && binsof(cmd_alloc.CmdAlloc);
                }
                //#Cov.IOAIU.CCP.aWcache
                cross_IOC_axi4XaWcacheXcmdAlloc: cross rw,aWcache,cmd_alloc {
                    ignore_bins ReadIgnore = binsof(rw.Read);
                    ignore_bins WriteIgnore = binsof(rw.Write) && (binsof(cmd_alloc.CmdNoAlloc) intersect {eCmdRdNITC} || binsof(cmd_alloc.CmdAlloc) intersect {eCmdRdVld});
                    ignore_bins WallocIgnore = binsof(rw.Write) && binsof(aWcache.Walloc) && (binsof(cmd_alloc.CmdNoAlloc) || binsof(cmd_alloc.CmdAlloc) intersect {eCmdRdVld});
                }
                // cf ConcertoCPRotocolArch_0_90_NoCB.pdf p456 CCMP CMDreq generated in response to Native request transaction	
                cross_IOC_axi4XcmdreqXccpStates: cross rw,cmd_type,allocate,isPartialWrite,ccp_current_state,ccp_next_state {
                    option.cross_auto_bin_max = 0;
                    //#Cov.IOAIU.CCP.Read
                    bins Read_CmdRdNITC_IX_IX = binsof(rw.Read) && binsof(cmd_type.CmdRdNITC) && binsof(allocate.na) 
                                            && binsof(ccp_current_state.IX) && binsof(ccp_next_state.IX); 
                    bins Read_CmdRdVld_IX_SC = binsof(rw.Read) && binsof(cmd_type.CmdRdVld) && binsof(allocate.al) 
                                            && binsof(ccp_current_state.IX) && binsof(ccp_next_state.SC); 
                    bins Read_CmdRdVld_IX_SD = binsof(rw.Read) && binsof(cmd_type.CmdRdVld) && binsof(allocate.al) 
                                            && binsof(ccp_current_state.IX) && binsof(ccp_next_state.SD); 
                    bins Read_CmdRdVld_IX_UC = binsof(rw.Read) && binsof(cmd_type.CmdRdVld) && binsof(allocate.al) 
                                            && binsof(ccp_current_state.IX) && binsof(ccp_next_state.UC); 
                    bins Read_CmdRdVld_IX_UD = binsof(rw.Read) && binsof(cmd_type.CmdRdVld) && binsof(allocate.al) 
                                            && binsof(ccp_current_state.IX) && binsof(ccp_next_state.UD); 
                    //#Cov.IOAIU.CCP.Write.Ptl
                    bins Write_CmdWrUnqPtl_IX_IX = binsof(rw.Write) && binsof(isPartialWrite.PtlWr) && binsof(cmd_type.CmdWrUnqPtl) && binsof(allocate.na) 
                                        && binsof(ccp_current_state.IX) && binsof(ccp_next_state.IX); 
                    bins Write_CmdRdUnq_IX_UD = binsof(rw.Write) && binsof(isPartialWrite.PtlWr) && binsof(cmd_type.CmdRdUnq) && binsof(allocate.al) 
                                        && binsof(ccp_current_state.IX) && binsof(ccp_next_state.UD); 
                    bins Write_CmdRdUnq_SC_UD = binsof(rw.Write) && binsof(isPartialWrite.PtlWr) && binsof(cmd_type.CmdRdUnq) 
                                        && binsof(ccp_current_state.SC) && binsof(ccp_next_state.UD); 
                    bins Write_CmdRdUnq_SD_UD = binsof(rw.Write) && binsof(isPartialWrite.PtlWr) && binsof(cmd_type.CmdRdUnq) 
                                        && binsof(ccp_current_state.SD) && binsof(ccp_next_state.UD); 
                    //#Cov.IOAIU.CCP.Write.Full
                    bins Write_CmdWrUnqFull_IX_IX = binsof(rw.Write) && binsof(isPartialWrite.NoPtlWr) && binsof(cmd_type.CmdWrUnqFull) && binsof(allocate.na) 
                                && binsof(ccp_current_state.IX) && binsof(ccp_next_state.IX); 				  
                    bins Write_CmdMkUnq_IX_UD = binsof(rw.Write) && binsof(isPartialWrite.NoPtlWr) && binsof(cmd_type.CmdMkUnq) && binsof(allocate.al) 
                                && binsof(ccp_current_state.IX) && binsof(ccp_next_state.UD); 				  
                    bins Write_CmdMkUnq_SC_UD = binsof(rw.Write) && binsof(isPartialWrite.NoPtlWr) && binsof(cmd_type.CmdMkUnq)  
                                && binsof(ccp_current_state.SC) && binsof(ccp_next_state.UD); 				  
                    bins Write_CmdMkUnq_SD_UD = binsof(rw.Write) && binsof(isPartialWrite.NoPtlWr) && binsof(cmd_type.CmdMkUnq)  
                                && binsof(ccp_current_state.SD) && binsof(ccp_next_state.UD); 				  
                }
                cross_IOC_axi4XccpStates_hit: cross rw,isPartialWrite,ccp_current_state,ccp_next_state {
                    option.cross_auto_bin_max = 0;
                    //#Cov.IOAIU.CCP.Read.Hit
                    bins Read_SC = binsof(rw.Read)  && binsof(isPartialWrite.NoPtlWr) 
                                            && binsof(ccp_current_state.SC) && binsof(ccp_next_state.SC); 
                    bins Read_SD = binsof(rw.Read)  && binsof(isPartialWrite.NoPtlWr)
                                            && binsof(ccp_current_state.SD) && binsof(ccp_next_state.SD); 
                    bins Read_UC = binsof(rw.Read)  && binsof(isPartialWrite.NoPtlWr)
                                            && binsof(ccp_current_state.UC) && binsof(ccp_next_state.UC); 
                    bins Read_UD = binsof(rw.Read)  && binsof(isPartialWrite.NoPtlWr)
                                            && binsof(ccp_current_state.UD) && binsof(ccp_next_state.UD); 
                    //#Cov.IOAIU.CCP.Write.Ptl.Hit
                    bins Write_Ptl_UC_UD = binsof(rw.Write) && binsof(isPartialWrite.PtlWr)  
                                    && binsof(ccp_current_state.UC) && binsof(ccp_next_state.UD); 
                    bins Write_Ptl_UD_UD = binsof(rw.Write) && binsof(isPartialWrite.PtlWr)  
                                    && binsof(ccp_current_state.UD) && binsof(ccp_next_state.UD);
                    //#Cov.IOAIU.CCP.Write.Full.Hit
                    bins Write_Full_UD = binsof(rw.Write) && binsof(isPartialWrite.NoPtlWr)  
                                && binsof(ccp_current_state.UD) && binsof(ccp_next_state.UD); 				  
                    bins Write_Full_UC_UD = binsof(rw.Write) && binsof(isPartialWrite.NoPtlWr)  
                                && binsof(ccp_current_state.UC) && binsof(ccp_next_state.UD); 				  

                }
            endgroup

            covergroup ccp_snp_type_state_core<%=port%>;
                cl_state: coverpoint m_scb_txn.m_ccp_ctrl_pkt.currstate;
                snp_type: coverpoint snp_type {
                    <%if(((obj.fnNativeInterface == "ACE-LITE") || 
                        (obj.fnNativeInterface == "ACELITE-E")) && 
                        obj.eAc && (obj.nDvmSnpInFlight > 0)) { %>
                        ignore_bins ignore = {eSnpRecall};
                    <%}else{%>
                        ignore_bins ignore = {eSnpRecall,eSnpDvmMsg};
                    <%}%>	     
                }
                cl_state_snp_type: cross cl_state, snp_type;
            endgroup // ccp_snp_type_state
                
            covergroup ccp_snoop_hit_evict_core<%=port%>;
                coverpoint_snoop_hit_evict: coverpoint snoop_hit_evict {
                    bins hit = {1};
                    ignore_bins ignore = {0};
                }
            endgroup // ccp_snoop_hit_evict
            covergroup ccp_sd_partial_upgrade_core<%=port%>; 
                coverpoint_sd_partial_fill_hit: coverpoint sd_hit_partial_upgrade{
                    bins hit = {1};
                    ignore_bins ignore = {0};
                }
            endgroup  // ccp_sd_partial

            covergroup ccp_ctrl_pkt_bank_1_core<%=port%>; 
                coverpoint_one_bank: coverpoint tag_bank{
                    bins zero = {0};
                    ignore_bins ignore = {[1:15]};
                }
            endgroup  // ccp_ctrl_pkt_bank_1

            covergroup ccp_ctrl_pkt_bank_2_core<%=port%>;
                coverpoint_two_bank: coverpoint tag_bank{
                    bins zero = {0};
                    bins one = {1};
                    ignore_bins ignore = {[2:15]};
                }
            endgroup // ccp_ctrl_pkt_bank_2

            covergroup ccp_ctrl_pkt_bank_4_core<%=port%>;
                coverpoint_four_bank: coverpoint tag_bank{
                    bins zero = {0};
                    bins one = {1};
                    bins two = {2};
                    bins three = {3};
                    ignore_bins ignore = {[4:15]};
                }
            endgroup // ccp_ctrl_pkt_bank_4

            covergroup ccp_ctrl_pkt_bank_8_core<%=port%>;
                coverpoint_eight_bank: coverpoint tag_bank{
                    bins zero = {0};
                    bins one = {1};
                    bins two = {2};
                    bins three = {3};
                    bins four = {4};
                    bins five = {5};
                    bins six = {6};
                    bins seven = {7};
                    ignore_bins ignore = {[8:15]};
                }
            endgroup // ccp_ctrl_pkt_bank_8

            covergroup ccp_ctrl_pkt_bank_16_core<%=port%>;
                coverpoint_sixteen_bank: coverpoint tag_bank;
            endgroup // ccp_ctrl_pkt_bank_16

            //All coverage related to ccp_ctrl_pkt go into this covergroup
            covergroup ccp_ctrl_pkt_core<%=port%>;
                read_miss_allocate	: coverpoint read_miss_allocate;
                write_miss_allocate	: coverpoint write_miss_allocate;
                read_hit		: coverpoint read_hit;
                write_hit		: coverpoint write_hit;
                write_hit_upgrade	: coverpoint write_hit_upgrade;
                
                //#Cover.IOAIU.CCPCtrlPkt.NoAllocate
                nacknoalloc: coverpoint m_pkt.nacknoalloc;     

                //#Cover.IOAIU.CCPCtrlPkt.Nack
                nack: coverpoint m_pkt.nack;     
                
                //#Cover.IOAIU.CCPCtrlPkt.tagUnCorrectableErr
                nack_uce: coverpoint m_pkt.nackuce;     

                //#Cover.IOAIU.CCPCtrlPkt.tagCorrectableErr
                nack_ce: coverpoint m_pkt.nackce;     

                //#Cover.IOAIU.CCPCtrlPkt.AllocMissWay
                alloc_way: coverpoint alloc_ways iff (m_pkt.alloc == 1 && m_pkt.currstate == IX) {
                    <%for(let i = 0; i < obj.nWays; i++) {%>
                        bins way_<%=i%> = {<%=i%>};
                    <%}%>
                }
                
                //#Cover.IOAIU.CCPCtrlPkt.HitWay
                hit_way: coverpoint scb.onehot_to_binay(m_pkt.hitwayn) iff (m_pkt.currstate != IX) {
                    <%for(let i = 0; i < obj.nWays; i++) {%>
                        bins way_<%=i%> = {<%=i%>};
                    <%}%>
                }

                //#Cover.IOAIU.CCPCtrlPkt.EvictWay
                evict_way: coverpoint m_pkt.wayn iff (m_pkt.evictvld == 1) {
                    <%for(let i = 0; i < obj.nWays; i++) {%>
                        bins way_<%=i%> = {<%=i%>};
                    <%}%>
                }
                
                //#Cover.IOAIU.CCPCtrlPkt.b2bAlloc_same_addr
                b2b_alloc_txns_same_addr: coverpoint m_pkt.b2b_same_addr;

                //#Cover.IOAIU.CCPCtrlPkt.b2bAlloc_same_index
                b2b_alloc_txns_same_index: coverpoint m_pkt.b2b_same_index;

            endgroup : ccp_ctrl_pkt_core<%=port%>

            //#Cov.IOAIU.CCP.FillState
            covergroup ccp_fill_ctrl_pkt_misc_core<%=port%>;
                state: coverpoint fill_state{
                    bins SC = {SC};
                    bins SD = {SD};
                    bins UC = {UC};
                    bins UD = {UD};
                }
                security: coverpoint fill_security;
            endgroup

            covergroup ccp_fill_ctrl_pkt_way_1_core<%=port%>;
                coverpoint_way_1: coverpoint fill_way_1;
            endgroup

            covergroup ccp_fill_ctrl_pkt_way_2_core<%=port%>;
                coverpoint_way_2: coverpoint fill_way_2{
                bins way0 = {1'b0};
                bins way1 = {1'b1};
                }
            endgroup

            covergroup ccp_fill_ctrl_pkt_way_4_core<%=port%>;
                coverpoint_way_4: coverpoint fill_way_4{
                    bins way0 = {2'b00};
                    bins way1 = {2'b01};
                    bins way2 = {2'b10};
                    bins way3 = {2'b11};
                }
            endgroup

            covergroup ccp_fill_ctrl_pkt_way_8_core<%=port%>;
                coverpoint_way_8: coverpoint fill_way_8{
                    bins way0 = {3'b000};
                    bins way1 = {3'b001};
                    bins way2 = {3'b010};
                    bins way3 = {3'b011};
                    bins way4 = {3'b100};
                    bins way5 = {3'b101};
                    bins way6 = {3'b110};
                    bins way7 = {3'b111};
                }
            endgroup

            covergroup ccp_fill_ctrl_pkt_way_16_core<%=port%>;
                coverpoint_way_16: coverpoint fill_way_16{
                    bins way0 = {4'b0000};
                    bins way1 = {4'b0001};
                    bins way2 = {4'b0010};
                    bins way3 = {4'b0011};
                    bins way4 = {4'b0100};
                    bins way5 = {4'b0101};
                    bins way6 = {4'b0110};
                    bins way7 = {4'b0111};
                    bins way8 = {4'b1000};
                    bins way9 = {4'b1001};
                    bins way10 = {4'b1010};
                    bins way11 = {4'b1011};
                    bins way12 = {4'b1100};
                    bins way13 = {4'b1101};
                    bins way14 = {4'b1110};
                    bins way15 = {4'b1111};
                }
            endgroup

            covergroup ccp_evict_pkt_core<%=port%>;
                coverpoint_evict_valid: coverpoint evict_valid{
                bins evict_valid = {1};
                }
            endgroup
        <%}%>


        /*<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
            covergroup shar_prom_owner_txfr_core<%=port%>;
                //snoop req
                //#Cover.IOAIU.SP_OT.smi_SnpReq_types
                snp_cln_dtr :coverpoint smi_snp_type {
                    bins snp_cln_dtr    = {SNP_CLN_DTR};
                }
                snp_nosd_int:coverpoint smi_snp_type {
                    bins snp_nosd_int   = {SNP_NOSDINT};
                }
                snp_vld_dtr :coverpoint smi_snp_type {
                    bins snp_vld_dtr    = {SNP_VLD_DTR};
                }
                snp_inv_dtr :coverpoint smi_snp_type {
                    bins snp_inv_dtr    = {SNP_INV_DTR};
                }
                snp_nitc    :coverpoint smi_snp_type {
                    bins snp_nitc       = {SNP_NITC};
                }
                snp_nitc_ci :coverpoint smi_snp_type {
                    bins snp_nitc_ci    = {SNP_NITCCI};
                }
                snp_nitc_mi :coverpoint smi_snp_type {
                    bins snp_nitc_mi    = {SNP_NITCMI};
                }
                snp_cln_dtw :coverpoint smi_snp_type {
                    bins snp_cln_dtw    = {SNP_CLN_DTW};
                }
                snp_inv_dtw :coverpoint smi_snp_type {
                    bins snp_inv_dtw    = {SNP_INV_DTW};
                }
                snp_unq_stsh:coverpoint smi_snp_type {
                    bins snp_unq_stsh   = {SNP_UNQ_STSH};
                }
                snp_stsh_unq:coverpoint smi_snp_type {
                bins snp_stsh_unq   = {SNP_STSH_UNQ};
                }
                snp_inv     :coverpoint smi_snp_type {
                bins snp_inv        = {SNP_INV};
                }
                snp_inv_stsh:coverpoint smi_snp_type {
                bins snp_inv_stsh   = {SNP_INV_STSH};
                }
                snp_stsh_shd:coverpoint smi_snp_type {
                bins snp_stsh_shd   = {SNP_STSH_SH};
                }
                //#Cover.IOAIU.SP_OT.smi_MPF3_values
                mpf3_match   : coverpoint match;
                //#Cover.IOAIU.SP_OT.smi_UP_values
                smi_snp_up      : coverpoint up{
                            ignore_bins up_00 = {0};
                            ignore_bins up_10 = {2};
                        }
                //cross snoop req
                snp_cln_dtr_x_match_x_up : cross snp_cln_dtr , mpf3_match, smi_snp_up;
                snp_nosd_int_x_match_x_up: cross snp_nosd_int, mpf3_match, smi_snp_up;
                snp_vld_dtr_x_match_x_up : cross snp_vld_dtr , mpf3_match, smi_snp_up;
                snp_inv_dtr_x_match_x_up : cross snp_inv_dtr , mpf3_match, smi_snp_up;
                snp_nitc_x_match_x_up    : cross snp_nitc    , mpf3_match, smi_snp_up;
                snp_nitc_ci_x_match_x_up : cross snp_nitc_ci , mpf3_match, smi_snp_up;
                snp_nitc_mi_x_match_x_up : cross snp_nitc_mi , mpf3_match, smi_snp_up;
                snp_cln_dtw_x_match_x_up : cross snp_cln_dtw , mpf3_match, smi_snp_up;
                snp_inv_dtw_x_match_x_up : cross snp_inv_dtw , mpf3_match, smi_snp_up;
                snp_unq_stsh_x_match_x_up: cross snp_unq_stsh, mpf3_match, smi_snp_up;
                snp_stsh_unq_x_match_x_up: cross snp_stsh_unq, mpf3_match, smi_snp_up;
                snp_inv_x_match_x_up     : cross snp_inv     , mpf3_match, smi_snp_up;
                snp_inv_stsh_x_match_x_up: cross snp_inv_stsh, mpf3_match, smi_snp_up;
                snp_stsh_shd_x_match_x_up: cross snp_stsh_shd, mpf3_match, smi_snp_up;

                //snoop rsp
                //#Cov.IOAIU.SP_OT.ACE_crresp
                ace_cr_DT: coverpoint ace_crresp[0]{
                        bins zero = {0};
                        bins one = {1};
                }
                ace_cr_ER: coverpoint ace_crresp[1]{
                        bins zero = {0};
                        bins one = {1};
                }
                ace_cr_PD: coverpoint ace_crresp[2]{
                        bins zero = {0};
                        bins one = {1};
                }
                ace_cr_IS: coverpoint ace_crresp[3]{
                        bins zero = {0};
                        bins one = {1};
                }
                ace_cr_WU: coverpoint ace_crresp[4]{
                        bins zero = {0};
                        bins one = {1};
                }
                ace_cr_PD_DT: coverpoint {ace_crresp[2],ace_crresp[0]} {
                    ignore_bins illegal_crresp_PD_1_DT_0        = {2'b10};
                } 
                //snp_req x crresp
                snp_cln_dtr_x_crresp : cross snp_cln_dtr , ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                }
                snp_nosd_int_x_crresp: cross snp_nosd_int, ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                }
                snp_vld_dtr_x_crresp : cross snp_vld_dtr , ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                }
                snp_inv_dtr_x_crresp : cross snp_inv_dtr , ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                    ignore_bins crresp_IS1            = binsof(ace_cr_IS.one);
                }
                snp_nitc_x_crresp    : cross snp_nitc    , ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                }
                snp_nitc_ci_x_crresp : cross snp_nitc_ci , ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                }
                snp_nitc_mi_x_crresp : cross snp_nitc_mi , ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                }
                snp_cln_dtw_x_crresp : cross snp_cln_dtw , ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                }
                snp_inv_dtw_x_crresp : cross snp_inv_dtw , ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                    ignore_bins crresp_IS1            = binsof(ace_cr_IS.one);
                }
                snp_unq_stsh_x_crresp: cross snp_unq_stsh, ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                }
                snp_stsh_unq_x_crresp: cross snp_stsh_unq, ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                }
                snp_inv_x_crresp     : cross snp_inv     , ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                    ignore_bins crresp_IS1            = binsof(ace_cr_IS.one);
                }
                snp_inv_stsh_x_crresp: cross snp_inv_stsh, ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                }
                snp_stsh_shd_x_crresp: cross snp_stsh_shd, ace_cr_WU, ace_cr_IS, ace_cr_PD, ace_cr_DT{
                    ignore_bins crresp_PD1_DT0        = binsof(ace_cr_PD.one) && binsof(ace_cr_DT.zero);
                }

                //#Cover.IOAIU.SP_OT.SnpRsp_cmstatus
                snp_dt      : coverpoint dt;
                snp_dc      : coverpoint dc;
                snp_rs      : coverpoint rs;
                snp_rv      : coverpoint rv;
                //cross snoop rsp
                cx_dc_dt_rs_rv: cross snp_dc, snp_dt, snp_rs, snp_rv;

                //#Cover.IOAIU.SP_OT.dtr_type
                dtr_type: coverpoint smi_dtr_type {
                            bins no_dtr         = {0};
                            bins dtr_data_inv   = {DTR_DATA_INV};
                            bins dtr_data_s_cln = {DTR_DATA_SHR_CLN};
                            bins dtr_data_s_dty = {DTR_DATA_SHR_DTY};
                            bins dtr_data_u_cln = {DTR_DATA_UNQ_CLN};
                            bins dtr_data_u_dty = {DTR_DATA_UNQ_DTY};
                        } 

                //#Cover.IOAIU.SP_OT.dtw_type
                dtw_type: coverpoint smi_dtw_type {
                            bins no_dtw         = {0};
                            bins dtw_data_cln   = {DTW_DATA_CLN};
                            bins dtw_data_dty   = {DTW_DATA_DTY};
                        } 

                //snp_req, crresp, cmstatus  // here ccresp bits-> {WU,DT,PD,IS}
                snp_cln_dtr_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_CLN_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0001_smi_11000_NoDtr_NoDtw = {SNP_CLN_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_CLN_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00010_DtrSC_NoDtw = {SNP_CLN_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0101_smi_10010_DtrSC_NoDtw = {SNP_CLN_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00011_DtrSC_DtwDD = {SNP_CLN_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==3 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0111_smi_11011_DtrSC_DtwDD = {SNP_CLN_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==3 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_CLN_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1001_smi_11000_NoDtr_NoDtw = {SNP_CLN_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00110_DtrUC_NoDtw = {SNP_CLN_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_UNQ_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1101_smi_10010_DtrSC_NoDtw = {SNP_CLN_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00111_DtrUC_DtwDD = {SNP_CLN_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==3 && smi_dtr_type==DTR_DATA_UNQ_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1111_smi_11011_DtrSC_DtwDD = {SNP_CLN_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==3 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_nosd_int_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_NOSDINT} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0001_smi_11000_NoDtr_NoDtw = {SNP_NOSDINT} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_NOSDINT} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00010_DtrSC_NoDtw = {SNP_NOSDINT} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0101_smi_10010_DtrSC_NoDtw = {SNP_NOSDINT} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00011_DtrSC_DtwDD = {SNP_NOSDINT} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==3 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00110_DtrUD_NoDtw = {SNP_NOSDINT} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_UNQ_DTY && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0111_smi_11011_DtrSC_DtwDD = {SNP_NOSDINT} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==3 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_NOSDINT} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1001_smi_11000_NoDtr_NoDtw = {SNP_NOSDINT} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00110_DtrUC_NoDtw = {SNP_NOSDINT} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_UNQ_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1101_smi_10010_DtrSC_NoDtw = {SNP_NOSDINT} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00110_DtrUD_NoDtw = {SNP_NOSDINT} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_UNQ_DTY && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1111_smi_11011_DtrSC_DtwDD = {SNP_NOSDINT} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==3 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_vld_dtr_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0001_smi_11000_NoDtr_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00010_DtrSC_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0101_smi_10010_DtrSC_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00110_DtrUD_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_UNQ_DTY && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00110_DtrSD_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_SHR_DTY && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0111_smi_11110_DtrSD_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_SHR_DTY && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1001_smi_11000_NoDtr_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00110_DtrUC_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_UNQ_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1101_smi_10010_DtrSC_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00110_DtrUD_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_UNQ_DTY && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1111_smi_11110_DtrSD_NoDtw = {SNP_VLD_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_SHR_DTY && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_inv_dtr_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_INV_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_INV_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00001_NoDtr_DtwDC = {SNP_INV_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_CLN);
                    bins crresp_0100_smi_00110_DtrUC_NoDtw = {SNP_INV_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_UNQ_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00001_NoDtr_DtwDD = {SNP_INV_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00110_DtrUD_NoDtw = {SNP_INV_DTR} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_UNQ_DTY && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_INV_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00110_DtrUC_NoDtw = {SNP_INV_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_UNQ_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00110_DtrUD_NoDtw = {SNP_INV_DTR} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==1 && dt==2 && smi_dtr_type==DTR_DATA_UNQ_DTY && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_nitc_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0001_smi_10000_NoDtr_NoDtw = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0001_smi_11000_NoDtr_NoDtw = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00010_DtrIX_NoDtw = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==2 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00010_DtrSC_NoDtw = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0101_smi_10010_DtrIX_NoDtw = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==2 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0101_smi_10010_DtrSC_NoDtw = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00011_DtrIX_DtwDD = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==3 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00011_DtrSC_DtwDD = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==3 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0111_smi_11011_DtrIX_DtwDD = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==3 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0111_smi_11011_DtrSC_DtwDD = {SNP_NITC} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==3 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_NITC} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1001_smi_10000_NoDtr_NoDtw = {SNP_NITC} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1001_smi_11000_NoDtr_NoDtw = {SNP_NITC} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00010_DtrIX_NoDtw = {SNP_NITC} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==2 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1101_smi_10010_DtrIX_NoDtw = {SNP_NITC} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==2 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1101_smi_10010_DtrSC_NoDtw = {SNP_NITC} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==2 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00011_DtrIX_DtwDD = {SNP_NITC} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==3 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00011_DtrSC_DtwDD = {SNP_NITC} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==3 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1111_smi_11011_DtrIX_DtwDD = {SNP_NITC} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==3 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1111_smi_11011_DtrSC_DtwDD = {SNP_NITC} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==3 && smi_dtr_type==DTR_DATA_SHR_CLN && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_nitc_ci_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_NITCCI} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_NITCCI} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00001_NoDtr_DtwDD = {SNP_NITCCI} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00011_DtrIX_DtwDD = {SNP_NITCCI} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==3 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_NITCCI} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00000_NoDtr_NoDtw = {SNP_NITCCI} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00001_NoDtr_DtwDD = {SNP_NITCCI} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00011_DtrIX_DtwDD = {SNP_NITCCI} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==3 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_nitc_mi_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_NITCMI} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_NITCMI} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00001_NoDtr_DtwDD = {SNP_NITCMI} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00011_DtrIX_DtwDD = {SNP_NITCMI} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==3 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_NITCMI} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00000_NoDtr_NoDtw = {SNP_NITCMI} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00001_NoDtr_DtwDD = {SNP_NITCMI} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00011_DtrIX_DtwDD = {SNP_NITCMI} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==3 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_cln_dtw_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_CLN_DTW} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0001_smi_10000_NoDtr_NoDtw = {SNP_CLN_DTW} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0001_smi_11000_NoDtr_NoDtw = {SNP_CLN_DTW} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_CLN_DTW} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0101_smi_10000_NoDtr_NoDtw = {SNP_CLN_DTW} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00001_NoDtr_DtwDD = {SNP_CLN_DTW} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0111_smi_11001_NoDtr_DtwDD = {SNP_CLN_DTW} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_CLN_DTW} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1001_smi_10000_NoDtr_NoDtw = {SNP_CLN_DTW} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1001_smi_11000_NoDtr_NoDtw = {SNP_CLN_DTW} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00000_NoDtr_NoDtw = {SNP_CLN_DTW} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1101_smi_10000_NoDtr_NoDtw = {SNP_CLN_DTW} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==1 && rv==1 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00001_NoDtr_DtwDD = {SNP_CLN_DTW} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1111_smi_11001_NoDtr_DtwDD = {SNP_CLN_DTW} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==1 && rv==1 && rs==1 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_inv_dtw_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_INV_DTW} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_INV_DTW} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00001_NoDtr_DtwDD = {SNP_INV_DTW} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_INV_DTW} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00000_NoDtr_NoDtw = {SNP_INV_DTW} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00001_NoDtr_DtwDD = {SNP_INV_DTW} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_unq_stsh_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_UNQ_STSH} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00001_NoDtr_DtwDD = {SNP_UNQ_STSH} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_UNQ_STSH} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00001_NoDtr_DtwDD = {SNP_UNQ_STSH} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_stsh_unq_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_STSH_UNQ} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_STSH_UNQ} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00001_NoDtr_DtwDD = {SNP_STSH_UNQ} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_STSH_UNQ} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00000_NoDtr_NoDtw = {SNP_STSH_UNQ} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00001_NoDtr_DtwDD = {SNP_STSH_UNQ} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_inv_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_INV} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_INV} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_INV} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00000_NoDtr_NoDtw = {SNP_INV} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_inv_stsh_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_INV_STSH} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_INV_STSH} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_INV_STSH} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00000_NoDtr_NoDtw = {SNP_INV_STSH} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                }
                snp_stsh_shd_rsps: coverpoint smi_snp_type{
                    bins crresp_0000_smi_00000_NoDtr_NoDtw = {SNP_STSH_SH} iff(ace_crresp[4]==0 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0100_smi_00000_NoDtr_NoDtw = {SNP_STSH_SH} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_0110_smi_00001_NoDtr_DtwDD = {SNP_STSH_SH} iff(ace_crresp[4]==0 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1000_smi_00000_NoDtr_NoDtw = {SNP_STSH_SH} iff(ace_crresp[4]==1 && ace_crresp[0]==0 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1100_smi_00000_NoDtr_NoDtw = {SNP_STSH_SH} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==0 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==0 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                    bins crresp_1110_smi_00001_NoDtr_DtwDD = {SNP_STSH_SH} iff(ace_crresp[4]==1 && ace_crresp[0]==1 && ace_crresp[2]==1 && ace_crresp[3]==0 && rv==0 && rs==0 && dc==0 && dt==1 && smi_dtr_type==0 && smi_dtw_type==DTW_DATA_DTY);
                }


                //cross snoop req & rsp

                //TODO : add ignore for mpf3_match & up field here
                //snp_cln_dtr_req_x_rsp : cross snp_cln_dtr_x_match_x_up , snp_cln_dtr_rsps {
                //  ignore_bins up3_match0 = binsof(up=3 & match=0......);
                //}

                snp_cln_dtr_req_x_rsp : cross snp_cln_dtr_x_match_x_up , snp_cln_dtr_rsps ;
                snp_nosd_int_req_x_rsp: cross snp_nosd_int_x_match_x_up, snp_nosd_int_rsps;
                snp_vld_dtr_req_x_rsp : cross snp_vld_dtr_x_match_x_up , snp_vld_dtr_rsps ;
                snp_inv_dtr_req_x_rsp : cross snp_inv_dtr_x_match_x_up , snp_inv_dtr_rsps ;
                snp_nitc_req_x_rsp    : cross snp_nitc_x_match_x_up    , snp_nitc_rsps    ;
                snp_nitc_ci_req_x_rsp : cross snp_nitc_ci_x_match_x_up , snp_nitc_ci_rsps ;
                snp_nitc_mi_req_x_rsp : cross snp_nitc_mi_x_match_x_up , snp_nitc_mi_rsps ;
                snp_cln_dtw_req_x_rsp : cross snp_cln_dtw_x_match_x_up , snp_cln_dtw_rsps ;
                snp_inv_dtw_req_x_rsp : cross snp_inv_dtw_x_match_x_up , snp_inv_dtw_rsps ;
                snp_unq_stsh_req_x_rsp: cross snp_unq_stsh_x_match_x_up, snp_unq_stsh_rsps;
                snp_stsh_unq_req_x_rsp: cross snp_stsh_unq_x_match_x_up, snp_stsh_unq_rsps;
                snp_inv_req_x_rsp     : cross snp_inv_x_match_x_up     , snp_inv_rsps     ;
                snp_inv_stsh_req_x_rsp: cross snp_inv_stsh_x_match_x_up, snp_inv_stsh_rsps;
                snp_stsh_shd_req_x_rsp: cross snp_stsh_shd_x_match_x_up, snp_stsh_shd_rsps;


            endgroup 
        <%}%>*/


    <%}%>
   
    /////data_integrity_wr_rd        
    //conectivity interface
    covergroup connectivity;
        dmi_connectivity_vec : coverpoint AiuDmi_connectivity_vec {
            bins all_disconnected_vec  = {'d0};
            bins all_connected_vec     = {'d<%=(2**obj.nDMIs-1)%>};
            bins random_connected_vec  = default;
		}
        dii_connectivity_vec : coverpoint AiuDii_connectivity_vec {
            bins all_disconnected_vec  = {'d0};
            bins all_connected_vec     = {'d<%=(2**obj.nDIIs-1)%>};
            bins random_connected_vec  = default;
		} 
        dce_connectivity_vec : coverpoint AiuDce_connectivity_vec {
            bins all_disconnected_vec  = {'d0};
            bins all_connected_vec     = {'d<%=(2**obj.nDCEs-1)%>};
            bins random_connected_vec  = default;
		}
    endgroup

	<%if (Object.keys(DVM_intf).includes(obj.fnNativeInterface)) {%>
        covergroup DVM_master_part1_<%=DVM_intf[obj.fnNativeInterface]%>;
            cp_dvm_op_type: coverpoint araddr[14:12] {
                bins tlb_invld                        = {0};
                bins branch_pred_invld                = {1};
                bins physical_inst_cache_invld        = {2};
                bins virtual_inst_cache_invld         = {3};
                bins synchronization                  = {4};
                ignore_bins reserved_0                = {5};
                bins hint                             = {6};
                ignore_bins reserved_1                = {7};
            }
            cp_dvm_msg_parts: coverpoint araddr[0] {
                bins one_part  = {0};
                bins two_parts = {1};
            }
            cx_dvm_op_type_x_parts: cross cp_dvm_op_type, cp_dvm_msg_parts {
                ignore_bins synchronization_x_two_parts = cx_dvm_op_type_x_parts with (cp_dvm_op_type == {4} && cp_dvm_msg_parts == {1});
            }
        endgroup //DVM_master_part1_<%=DVM_intf[obj.fnNativeInterface]%>

        covergroup DVM_master_part2_<%=DVM_intf[obj.fnNativeInterface]%>;
            <% if (obj.DVMVersionSupport >= 132) { /*DVMVersionSupport  = 132 -> DVM v8.4  */ %> 
            cp_dvm_NUM: coverpoint {araddr[5:4],araddr[2:0]} {
            }
            <% }else { %>
            cp_dvm_NUM: coverpoint {araddr[5:4]} {
            }
            <% } %>
            cp_dvm_SCALE: coverpoint araddr[7:6] {
            <% if (obj.DVMVersionSupport < 132) {%> 
                ignore_bins range_bit_10  = {2};
                ignore_bins range_bit_11  = {3};
            <% } %>
            }
            cp_dvm_TTL: coverpoint araddr[9:8] {
            <% if (obj.DVMVersionSupport < 132) { /*DVMVersionSupport  = 132 -> DVM v8.4  */ %> 
                ignore_bins dvm_TTL_01  = {1};
            <% } %>
            }
            cp_dvm_VA_PA_47_44: coverpoint {araddr[47:44]} {
            <%if(obj.AiuInfo[obj.Id].wAddr>44) { %>
              wildcard bins dvm_VA_PA_44 = {4'b???1}; 
              wildcard bins dvm_VA_PA_45 = {4'b??1?}; 
              wildcard bins dvm_VA_PA_46 = {4'b?1??}; 
              wildcard bins dvm_VA_PA_47 = {4'b1???}; 
              <%}else{%>
              bins dvm_VA_PA_47_44={0};
            <% } %>
            }
            cp_dvm_VA_PA_43_40: coverpoint {araddr[43:40]} {
            <%if(obj.AiuInfo[obj.Id].wAddr>40) { %>
              wildcard bins dvm_VA_PA_40 = {4'b???1}; 
              wildcard bins dvm_VA_PA_41 = {4'b??1?}; 
              wildcard bins dvm_VA_PA_42 = {4'b?1??}; 
              wildcard bins dvm_VA_PA_43 = {4'b1???}; 
              <%}else{%>
              bins dvm_VA_PA_44_40={0};
            <% } %>
            }
            cp_dvm_VA_PA_39_12: coverpoint {araddr[39:12]} {
            <%if(obj.AiuInfo[obj.Id].wAddr<40) { %>
              <%for(var i = (obj.AiuInfo[obj.Id].wAddr-12); i >0; i--){%>
                   wildcard bins dvm_VA_PA_<%=i%> ={'b<%for(var j =(obj.AiuInfo[obj.Id].wAddr-12); j > 0; j--) { if(j==i){%>1<%}else{%>?<%}}%>} ;
            <% } %>
              <%}else{%>
              <%for(var i = 28; i >0; i--){%>
                   wildcard bins dvm_VA_PA_<%=i%> ={'b<%for(var j =28; j > 0; j--) { if(j==i){%>1<%}else{%>?<%}}%>} ;
            <% } %>
            <% } %>

            }
            cp_dvm_VA_PA_11_10: coverpoint {araddr[11:10]} {
              wildcard bins dvm_VA_PA_10 = {2'b?1}; 
              wildcard bins dvm_VA_PA_11 = {2'b1?}; 
            }
            <% if (obj.DVMVersionSupport >= 132) { /*DVMVersionSupport  = 132 -> DVM v8.4  */ %> 
            cp_dvm_VA_PA_9_8: coverpoint {araddr[9:8]} {
              wildcard bins dvm_VA_PA_8 = {2'b?1}; 
              wildcard bins dvm_VA_PA_9 = {2'b1?}; 
            }
            cp_dvm_VA_PA_7_6: coverpoint {araddr[7:6]} {
              wildcard bins dvm_VA_PA_6 = {2'b?1}; 
              wildcard bins dvm_VA_PA_7 = {2'b1?}; 
            }
            cp_dvm_VA_PA_5_4: coverpoint {araddr[5:4]} {
              wildcard bins dvm_VA_PA_4 = {2'b?1}; 
              wildcard bins dvm_VA_PA_5 = {2'b1?}; 
            }
            <% } %>
            cp_dvm_VA_PA_3: coverpoint {araddr[3]} {
                bins dvm_VA_PA_3_zero  = {0};
                bins dvm_VA_PA_3_one  = {1};
            }
        endgroup //DVM_master_part2_<%=DVM_intf[obj.fnNativeInterface]%>

        covergroup DVM_snooper_part1_<%=DVM_intf[obj.fnNativeInterface]%>;
            cp_dvm_op_type: coverpoint acaddr[14:12] {
                bins tlb_invld                        = {0};
                bins branch_pred_invld                = {1};
                bins physical_inst_cache_invld        = {2};
                bins virtual_inst_cache_invld         = {3};
                bins synchronization                  = {4};
                ignore_bins reserved_0                = {5};
                bins hint                             = {6};
                ignore_bins reserved_1                = {7};
            }
            cp_dvm_msg_parts: coverpoint acaddr[0] {
                bins one_part  = {0};
                bins two_parts = {1};
            }
            cx_dvm_op_type_x_parts: cross cp_dvm_op_type, cp_dvm_msg_parts {
                ignore_bins synchronization_x_two_parts = cx_dvm_op_type_x_parts with (cp_dvm_op_type == {4} && cp_dvm_msg_parts == {1});
            }
        endgroup //DVM_snooper_part1_<%=DVM_intf[obj.fnNativeInterface]%>

        covergroup DVM_snooper_part2_<%=DVM_intf[obj.fnNativeInterface]%>;
            <% if (obj.DVMVersionSupport >= 132) {   //DVMVersionSupport = 132 -> DVM v8.4 %>
            cp_dvm_NUM: coverpoint {acaddr[5:4],acaddr[2:0]} {
            }
            <% } else { %>
            cp_dvm_NUM: coverpoint acaddr[5:4] {
            }
            <% } %>
             cp_dvm_SCALE: coverpoint acaddr[7:6] {
            <% if (obj.DVMVersionSupport < 132) {%> 
                ignore_bins range_bit_10  = {2};
                ignore_bins range_bit_11  = {3};
            <% } %>
            }
            cp_dvm_TTL: coverpoint acaddr[9:8] {
            <% if (obj.DVMVersionSupport < 132) { /*DVMVersionSupport  = 132 -> DVM v8.4  */ %> 
                ignore_bins dvm_TTL_01  = {1};
            <% } %>
            }

            cp_dvm_VA_PA_47_44: coverpoint {acaddr[47:44]} {
            <%if(obj.AiuInfo[obj.Id].wAddr>44) { %>
              wildcard bins dvm_VA_PA_44 = {4'b???1}; 
              wildcard bins dvm_VA_PA_45 = {4'b??1?}; 
              wildcard bins dvm_VA_PA_46 = {4'b?1??}; 
              wildcard bins dvm_VA_PA_47 = {4'b1???}; 
              <%}else{%>
              bins dvm_VA_PA_47_44={0};
            <% } %>
            }
            cp_dvm_VA_PA_43_40: coverpoint {acaddr[43:40]} {
            <%if(obj.AiuInfo[obj.Id].wAddr>40) { %>
              wildcard bins dvm_VA_PA_40 = {4'b???1}; 
              wildcard bins dvm_VA_PA_41 = {4'b??1?}; 
              wildcard bins dvm_VA_PA_42 = {4'b?1??}; 
              wildcard bins dvm_VA_PA_43 = {4'b1???}; 
              <%}else{%>
              bins dvm_VA_PA_43_40={0};
            <% } %>
            }
            cp_dvm_VA_PA_39_12: coverpoint {acaddr[39:12]} {
            <%if(obj.AiuInfo[obj.Id].wAddr<40) { %>
              <%for(var i = (obj.AiuInfo[obj.Id].wAddr-12); i >0; i--){%>
                   wildcard bins dvm_VA_PA_<%=i%> ={'b<%for(var j =(obj.AiuInfo[obj.Id].wAddr-12); j > 0; j--) { if(j==i){%>1<%}else{%>?<%}}%>} ;
            <% } %>
              <%}else{%>
              <%for(var i = 28; i >0; i--){%>
                   wildcard bins dvm_VA_PA_<%=i%> ={'b<%for(var j =28; j > 0; j--) { if(j==i){%>1<%}else{%>?<%}}%>} ;
            <% } %>
            <% } %>

            }
            cp_dvm_VA_PA_11_10: coverpoint {acaddr[11:10]} {
              wildcard bins dvm_VA_PA_10 = {2'b?1}; 
              wildcard bins dvm_VA_PA_11 = {2'b1?}; 
            }
            <% if (obj.DVMVersionSupport >= 132) { /*DVMVersionSupport  = 132 -> DVM v8.4  */ %> 
            cp_dvm_VA_PA_9_8: coverpoint {acaddr[9:8]} {
              wildcard bins dvm_VA_PA_8 = {2'b?1}; 
              wildcard bins dvm_VA_PA_9 = {2'b1?}; 
            }
            cp_dvm_VA_PA_7_6: coverpoint {acaddr[7:6]} {
              wildcard bins dvm_VA_PA_6 = {2'b?1}; 
              wildcard bins dvm_VA_PA_7 = {2'b1?}; 
            }
            cp_dvm_VA_PA_5_4: coverpoint {acaddr[5:4]} {
              wildcard bins dvm_VA_PA_4 = {2'b?1}; 
              wildcard bins dvm_VA_PA_5 = {2'b1?}; 
            }
            <% } %>
            cp_dvm_VA_PA_3: coverpoint {acaddr[3]} {
                bins dvm_VA_PA_3_zero  = {0};
                bins dvm_VA_PA_3_one  = {1};
             }   
        endgroup //DVM_snooper_part2_<%=obj.fnNativeInterface%>
	<%}%>

	// #Cover.IOAIU.AXI.TXNTypes
	// #Cov.IOAIU.SMI.DTRReq.Types
	// #Cov.IOAIU.SMI.RspCmStatusError
	// #Cov.IOAIU.RdTypes
	covergroup smi_pkt;
		<%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")){ %>
			coverpoint_rdnitc: coverpoint rdnitc;
			<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
				coverpoint_rdvld: coverpoint rdvld;
				coverpoint_rdcln: coverpoint rdcln;
				coverpoint_rdunq: coverpoint rdunq;
				coverpoint_clnunq: coverpoint clnunq;
				coverpoint_dtr_data_shr_cln: coverpoint dtr_data_shr_cln; 
				coverpoint_dtr_data_shr_dty: coverpoint dtr_data_shr_dty;
				coverpoint_dtr_data_unq_cln: coverpoint dtr_data_unq_cln;
				coverpoint_dvmmsg: coverpoint dvmmsg;
			<%}%>
			<%if(obj.fnNativeInterface != "ACE-LITE") { %>
			coverpoint_dtr_data_unq_dty: coverpoint dtr_data_unq_dty;	//CCMP Protocol, 4.7.2 Possible DTRReq per Read CMDreqs (Table 4-38)
			<%}%>
			coverpoint_clnvld: coverpoint clnvld;
			coverpoint_clninv: coverpoint clninv;
			coverpoint_mkinv: coverpoint mkinv;
			coverpoint_wrunqptl: coverpoint wrunqptl;
			coverpoint_wrunqfull: coverpoint wrunqfull;
			coverpoint_wrncfull: coverpoint wrncfull;
			coverpoint_dtr_data_inv:  coverpoint dtr_data_inv;
			coverpoint_cmstatus_err: coverpoint cmstatus_err;
		<%}%>
   	endgroup

   	covergroup smi_StrReq_pkt;
		<%if(obj.fnNativeInterface == "ACELITE-E") { %>
       		//#Cov.IOAIU.SMI.STRReq.Snarf
       		coverpoint_strReq_snarf: coverpoint str_req_msg.smi_cmstatus_snarf {
				bins stashInviteDecline     = {0};
				bins stashInviteAccept      = {1};
    		}	 

            //#Cov.IOAIU.SMI.STRReq.MPF1
            coverpoint_StrReq_MPF1_stashNID: coverpoint str_req_msg.smi_mpf1 {
                <%if(obj.chiAiuIds.length > 0){ %>
                    bins strReqMPF1StashNID[] = {<%=obj.chiAiuIds%>};
                <%}else{%>
                    bins strReqMPF1StashNID = {0};
                <%}%>
            }

            cross_StrReq_MPF1_StashNID: cross coverpoint_StrReq_MPF1_stashNID, coverpoint_strReq_snarf {
                ignore_bins strReq_MPF1_Stash_invalid = binsof(coverpoint_strReq_snarf.stashInviteDecline);
            }
	    <%}%>

       	//#Cov.IOAIU.SMI.STRReq.IntfSize
       	coverpoint_STRReq_IntfSize: coverpoint str_req_msg.smi_intfsize {
           bins strReqIntfSize[] = {[0:2]};
        }	

        //#Cover.IOAIU.SMI.StrReq.cmstatus
        coverpoint_StrReq_cmstatus_state: coverpoint str_req_msg.smi_cmstatus[3:1]{
           bins State_Invalid = {3'b000};
           bins State_Owner = {3'b010};
           bins State_Sharer = {3'b011};
           bins State_Unique = {3'b100};
         }
   	endgroup //smi_StrReq_pkt

	<%if(obj.nSttCtrlEntries > 0) { %>
    	//#Cov.IOAIU.SMI.SNPReq.Attrs
		covergroup smi_snoop_pkt;
        	coverpoint_SnpReq_msgType: coverpoint snp_req_msg.smi_msg_type {
				<%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) && obj.useCache)) { %>
					bins SnpReqMsgType_SnpClnDtr    = {SNP_CLN_DTR};
					bins SnpReqMsgType_SnpNITC      = {SNP_NITC};
					bins SnpReqMsgType_SnpVldDtr    = {SNP_VLD_DTR};
					bins SnpReqMsgType_SnpInvDtr    = {SNP_INV_DTR};
					bins SnpReqMsgType_SnpInvDtw    = {SNP_INV_DTW};
					bins SnpReqMsgType_SnpInv       = {SNP_INV};
					bins SnpReqMsgType_SnpClnDtw    = {SNP_CLN_DTW};
					bins SnpReqMsgType_SnpNoSDInt   = {SNP_NOSDINT};
					bins SnpReqMsgType_SnpInvStsh   = {SNP_INV_STSH};
					bins SnpReqMsgType_SnpUnqStsh   = {SNP_UNQ_STSH};
					bins SnpReqMsgType_SnpStshShd   = {SNP_STSH_SH};
					bins SnpReqMsgType_SnpStshUnq   = {SNP_STSH_UNQ};
					bins SnpReqMsgType_SnpNITCCI    = {SNP_NITCCI};
					bins SnpReqMsgType_SnpNITCMI    = {SNP_NITCMI};
				<%}%>
				bins SnpReqMsgType_SnpDvmMsg    = {SNP_DVM_MSG};

				<%if(!(((obj.fnNativeInterface == "ACE-LITE") || 
						(obj.fnNativeInterface == "ACELITE-E")) && 
						obj.eAc && (obj.nDvmSnpInFlight > 0))) { %>
					ignore_bins noDVMSnpMsg = {SNP_DVM_MSG};
				<%}%>
				//ignore_bins SnpRecallMsg = {SNP_RECALL};
        	}
        	//#Cov.IOAIU.SMI.SNP.AddrOffset
        	coverpoint_SnpReq_AddrOffset: coverpoint (snp_req_msg.smi_addr%64) {
				<%for(var i = 0; i < Math.pow(2,obj.wCacheLineOffset); i += (obj.wData / 8)) { %>
					bins addrOffset<%=i%> = {[<%=i%>:<%=i + (obj.wData/8) - 1%>]};
				<%}%>
        	}

			CrossSnpReqTypeXAddrOffset: cross coverpoint_SnpReq_msgType, coverpoint_SnpReq_AddrOffset {
				ignore_bins SnpRsp_addr_DVM = binsof (coverpoint_SnpReq_msgType.SnpReqMsgType_SnpDvmMsg);
			}
			<%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((obj.fnNativeInterface.includes("AXI")) && obj.useCache)) { %>
				//#Cover.IOAIU.SMI.SNPReq.IntfSize
				coverpoint_SnpReq_IntfSize: coverpoint snp_req_msg.smi_intfsize {
					bins snpReqIntfSize[] = {[0:2]};
				}

				//#Cover.IOAIU.SMI.SNPReq.UP
				coverpoint_SnpReq_UP: coverpoint snp_req_msg.smi_up{
                                ignore_bins ignore_value = { SMI_UP_NONE,SMI_UP_PROVIDER};
                                }
			<%}%>
			coverage_SnpReq_srcId: coverpoint snp_req_msg.smi_src_ncore_unit_id {
				bins src_dve = {DVE_FUNIT_IDS[0]};
				bins src_dce[] = {DCE_FUNIT_IDS};

				<% if(obj.useCache == 1) {%>
					ignore_bins src_dve_invalid = {DVE_FUNIT_IDS[0]};
				<%}%>
			}
                        //#Cover.IOAIU.SMI.SNPReq.PR
			coverpoint_SnpReq_PR: coverpoint snp_req_msg.smi_pr;
                        //#Cover.IOAIU.SMI.SNPReq.QoS
			<%if(obj.eStarve && obj.eAge && (obj.AiuInfo[obj.Id].QosInfo && obj.AiuInfo[obj.Id].QosInfo.qosMap.length > 0)) { %>
				coverpoint_SnpReq_MsgQOS: coverpoint snp_req_msg.smi_msg_qos;
				coverpoint_SnpReq_QOS:    coverpoint snp_req_msg.smi_qos;
			<%}else{%>
				coverpoint_SnpReq_MsgQOS: coverpoint snp_req_msg.smi_msg_qos {
					bins qos0 = {0};
				}
				coverpoint_SnpReq_QOS:    coverpoint snp_req_msg.smi_qos {
					bins qos0 = {0};
				}
   			<%}%>
			<%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((obj.fnNativeInterface.includes("AXI")) && obj.useCache)) { %>
				//#Cover.IOAIU.SMI.SNPReq.TOF
                                coverpoint_SnpReq_TOF: coverpoint snp_req_msg.smi_tof{
					//bins SnpReqTOF_CONC_C = {SMI_TOF_CONC_C};
					bins SnpReqTOF_CHI    = {SMI_TOF_CHI};
					bins SnpReqTOF_ACE    = {SMI_TOF_ACE};
					//bins SnpReqTOF_AXI    = {SMI_TOF_AXI};
					//bins SnpReqTOF_PCIE   = {SMI_TOF_PCIE};
				}
                                //#Cover.IOAIU.SMI.SNPReq.VZ
				coverpoint_SnpReq_VZ: coverpoint snp_req_msg.smi_vz;
                                //#Cover.IOAIU.SMI.SNPReq.AC
				coverpoint_SnpReq_AC: coverpoint snp_req_msg.smi_ac;
                                //#Cover.IOAIU.SMI.SNPReq.NS
				coverpoint_SnpReq_NS: coverpoint snp_req_msg.smi_ns;
			<%}%>
                        //#Cover.IOAIU.SMI.SNPReq.MPF1
                        //#Cover.IOAIU.SMI.SNPReq.MPF2
                        //#Cover.IOAIU.SMI.SNPReq.MPF3
			<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
				coverpoint_SnpReq_mpf1_stash_nid: coverpoint snp_req_msg.smi_mpf1_stash_nid;
				coverpoint_SnpReq_mpf1_stash_valid: coverpoint snp_req_msg.smi_mpf1_stash_valid;
				coverpoint_SnpReq_mpf2_stash_lpid: coverpoint snp_req_msg.smi_mpf2_stash_lpid;
				coverpoint_SnpReq_mpf2_stash_valid: coverpoint snp_req_msg.smi_mpf2_stash_valid;
				coverpoint_SnpReq_mpf3_DVMOpPortion: coverpoint snp_req_msg.smi_mpf3_dvmop_portion{
                                 bins  funit_ID = {[0:15]};
                                }
			<%}%>

			<%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface.includes("AXI") && obj.useCache)) { %>
				coverpoint_SnpReq_mpf1_DtrTgtID: coverpoint snp_req_msg.smi_mpf1_dtr_tgt_id iff (!(snp_req_msg.smi_msg_type inside{SNP_INV_STSH,SNP_UNQ_STSH,SNP_STSH_SH,SNP_STSH_UNQ})){ 
					<%for(var i = 0; i < cohIds.length; i++) { %>
						bins dtr_tgt_id<%=i%> = {<%=cohIds[i]%>};
					<%}%>
				}
				coverpoint_SnpReq_mpf2_DtrMsgID: coverpoint snp_req_msg.smi_mpf2_dtr_msg_id;
			<%}%>
			/*coverpoint_SnpRsp_cmstatus: coverpoint snp_rsp_msg.smi_cmstatus[5:1] {
				bins SnpRspCmStatus_RV_RS_DC_DTAiu_DTDmi[] = {[0:$]};

				// wildcard ignore_bins SnpRsp_RV_0_RS_1_invalid      = {5'b01???};
				// wildcard ignore_bins SnpRsp_DC_1_DTAiu_0_invalid   = {5'b??10?};
				// ignore_bins SnpRsp_IOAIU_invalid                   = {5'b10011, 5'b10110, 5'b10111,5'b11111};
			}*/

		
        	/*crossSnpReqTypeXSnpRspCmstatus: cross coverpoint_SnpReq_msgType, coverpoint_SnpRsp_cmstatus {
				<%if(obj.useCache) {%>
					ignore_bins SnpTypeCmstatus_SnpClDtr_invalid   = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpClnDtr) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b11000, 5'b10010, 5'b11010};

					ignore_bins SnpTypeCmstatus_SnpNoSDInt_invalid = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNoSDInt) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b11000, 5'b10010, 5'b11010};

					ignore_bins SnpTypeCmstatus_SnpVldDtr_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpVldDtr) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b11000, 5'b10010, 5'b11010};

					ignore_bins SnpTypeCmstatus_SnpInvDtr_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpInvDtr) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00110};

					ignore_bins SnpTypeCmstatus_SnpNITC_invalid    = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNITC) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b11000, 5'b10010};

					ignore_bins SnpTypeCmstatus_SnpNITCCI_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNITCCI) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00011, 5'b00010};

					ignore_bins SnpTypeCmstatus_SnpNITCMI_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNITCMI) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00010};

					ignore_bins SnpTypeCmstatus_SnpClnDtw_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpClnDtw) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b11000, 5'b11001, 5'b10000, 5'b10001};

					ignore_bins SnpTypeCmstatus_SnpInvDtw_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpInvDtw) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00001};

					ignore_bins SnpTypeCmstatus_SnpInv_invalid     = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpInv) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000};

					ignore_bins SnpTypeCmstatus_SnpCmd_stsh        = binsof(coverpoint_SnpReq_msgType) intersect {SNP_INV_STSH, SNP_UNQ_STSH, SNP_STSH_SH, SNP_STSH_UNQ};
				<%}%>

				<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
					ignore_bins SnpTypeCmstatus_SnpClDtr_invalid   = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpClnDtr) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b11000, 5'b00010, 5'b00110, 5'b10010, 5'b00011, 5'b00111, 5'b11011};

					ignore_bins SnpTypeCmstatus_SnpNoSDInt_invalid = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNoSDInt) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b11000, 5'b00010, 5'b00110, 5'b10010, 5'b00011, 5'b11011};

					ignore_bins SnpTypeCmstatus_SnpVldDtr_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpVldDtr) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b11000, 5'b00010, 5'b00110, 5'b10010, 5'b11110};

					ignore_bins SnpTypeCmstatus_SnpInvDtr_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpInvDtr) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00110};

					ignore_bins SnpTypeCmstatus_SnpNITC_invalid    = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNITC) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b11000, 5'b10000, 5'b00010, 5'b10010, 5'b00011, 5'b11011};

					ignore_bins SnpTypeCmstatus_SnpNITCCI_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNITCCI) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00011};

					ignore_bins SnpTypeCmstatus_SnpNITCMI_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpNITCMI) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00011};

					ignore_bins SnpTypeCmstatus_SnpClnDtw_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpClnDtw) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b11000, 5'b10000, 5'b00001, 5'b11001};

					ignore_bins SnpTypeCmstatus_SnpInvDtw_invalid  = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpInvDtw) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00001};

					ignore_bins SnpTypeCmstatus_SnpInv_invalid     = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpInv) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000};

					ignore_bins SnpTypeCmstatus_SnpInvStsh_invalid = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpInvStsh) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000};

					ignore_bins SnpTypeCmstatus_SnpUnqStsh_invalid = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpUnqStsh) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00001};

					ignore_bins SnpTypeCmstatus_SnpStshUnq_invalid = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpStshUnq) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00001};

					ignore_bins SnpTypeCmstatus_SnpStshShd_invalid = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpStshShd) &&
																	!binsof(coverpoint_SnpRsp_cmstatus) intersect {5'b00000, 5'b00001};
				<%}%>
            	ignore_bins SnpTypeCmstatus_SnpCmd_DVM         = binsof(coverpoint_SnpReq_msgType.SnpReqMsgType_SnpDvmMsg);
        	}*/
    	endgroup //smi_snoop_pkt
	<%}%> 

	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
		covergroup sys_req_events_cg;
			option.per_instance 		= 1;
			cp_sysreq_event_opcode 		: coverpoint sysreq_pkt.sysreq_event_opcode{
				bins event_opcode  		= {3};
			}
			cp_timeout_threshold   		: coverpoint sysreq_pkt.timeout_threshold{
				bins valid_bins[]  		= {[1:3]};
			}
			cp_event_receiver_enable	: coverpoint sysreq_pkt.event_receiver_enable{
				bins enable				= {1};
			}
			cp_event_receiver_disable	: coverpoint sysreq_pkt.event_receiver_enable{
				bins dis				= {0};
			}
			cp_sysreq_event				: coverpoint sysreq_pkt.sysreq_event{
				bins sysreq_received	= {1};
			}
			cp_sysrsp_event_cmstatus	: coverpoint sysreq_pkt.cm_status{
				bins good_operation		= {3};
				bins unit_busy			= {1};
			}
			cp_sysrsp_event_cmstatus_dis: coverpoint sysreq_pkt.cm_status{
				bins receiving_disable	= {0};
			}
			cp_timeout_err_det_en		: coverpoint sysreq_pkt.timeout_err_det_en{
				bins timeout_enable		= {1};
				bins timeout_disable	= {0};
			}	
			cp_sysrsp_cmstatus_timeout 	: coverpoint sysreq_pkt.cm_status iff(sysreq_pkt.timeout_err_det_en == 1){
        		bins timeout_cmstatus 	= {'h40};
			}	
			cp_timeout_err_int_en		: coverpoint sysreq_pkt.timeout_err_int_en{
				bins timeout_int_en		= {1};
				bins timeout_int_dis	= {0};
			}
			cp_uc_int_occurred			: coverpoint sysreq_pkt.irq_uc iff(sysreq_pkt.timeout_err_int_en == 1){
				bins irq_occurred		= {1};
				bins no_irq				= {0};
			}
			cp_err_valid				: coverpoint sysreq_pkt.err_valid{
				bins valid				= {1};
				bins invalid			= {0};
			}
			cp_uesr_err_type			: coverpoint sysreq_pkt.uesr_err_type iff(sysreq_pkt.err_valid == 1 && sysreq_pkt.timeout_err_det_en == 1){
				bins uesr_err_type		= {'hA};
			}
			cross_all_sysreq_operations : cross cp_sysreq_event_opcode, cp_timeout_threshold, cp_event_receiver_enable, cp_sysreq_event, cp_sysrsp_event_cmstatus;
		endgroup : sys_req_events_cg
	<%}else if(((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache == 1)){%>
		covergroup sys_req_events_cg;
			option.per_instance 		= 1;
			cp_sysreq_event_opcode 		: coverpoint sysreq_pkt.sysreq_event_opcode{
				bins event_opcode  		= {3};
			}
			cp_timeout_threshold   		: coverpoint sysreq_pkt.timeout_threshold{
				bins valid_bins[]  		= {[1:3]};
			}
			cp_event_receiver_enable	: coverpoint sysreq_pkt.event_receiver_enable{
				bins enable				= {1};
			}
			cp_event_receiver_disable	: coverpoint sysreq_pkt.event_receiver_enable{
				bins dis				= {0};
			}
			cp_sysreq_event				: coverpoint sysreq_pkt.sysreq_event{
				bins sysreq_received	= {1};
			}
			cp_sysrsp_event_cmstatus	: coverpoint sysreq_pkt.cm_status{
				bins good_operation		= {3};
			}
			cp_sysrsp_event_cmstatus_dis: coverpoint sysreq_pkt.cm_status{
				bins receiving_disable	= {0};
			}
			cp_timeout_err_det_en		: coverpoint sysreq_pkt.timeout_err_det_en{
				bins timeout_enable		= {1};
				bins timeout_disable	= {0};
			}	
			cp_timeout_err_int_en		: coverpoint sysreq_pkt.timeout_err_int_en{
				bins timeout_int_en		= {1};
				bins timeout_int_dis	= {0};
			}
			cp_err_valid				: coverpoint sysreq_pkt.err_valid{
				bins valid				= {1};
				bins invalid			= {0};
			}
			cross_all_sysreq_operations : cross cp_sysreq_event_opcode, cp_timeout_threshold, cp_event_receiver_enable, cp_sysreq_event, cp_sysrsp_event_cmstatus;
		endgroup : sys_req_events_cg
    <%}%>
    
    //Covergrou for Software Credit Management Credit Limit Register - Counter States & Credit Limit Values
    <% for(var multiPortCoreId = 0; multiPortCoreId < obj.nNativeInterfacePorts; multiPortCoreId++) { %>
    covergroup io_crd_cg_val_<%=multiPortCoreId%>;


        <% for(var i = 0; i < obj.nDCEs; i++) { %>
        cp_dce_ccr<%=i%>: coverpoint DCE_CCR<%=i%>_Val {
            bins dce_ccr_val_0           = {'d0};
            bins dce_ccr_val_1           = {'d1};
            bins dce_ccr_val_2           = {'d2};
            bins dce_ccr_val_3           = {'d3};
            bins dce_ccr_val_4           = {'d4};
            bins dce_ccr_val_5           = {'d5};
            bins dce_ccr_val_6           = {'d6};
            bins dce_ccr_val_7           = {'d7};
            bins dce_ccr_val_8           = {'d8};
            bins dce_ccr_val_9           = {'d9};
            bins dce_ccr_val_10           = {'d10};
            bins dce_ccr_val_11           = {'d11};
            bins dce_ccr_val_12           = {'d12};
            bins dce_ccr_val_13           = {'d13};
            bins dce_ccr_val_14           = {'d14};
            bins dce_ccr_val_15           = {'d15};
            bins dce_ccr_val_16           = {'d16};
            bins dce_ccr_val_17           = {'d17};
            bins dce_ccr_val_18           = {'d18};
            bins dce_ccr_val_19           = {'d19};
            bins dce_ccr_val_20           = {'d20};
            bins dce_ccr_val_21           = {'d21};
            bins dce_ccr_val_22           = {'d22};
            bins dce_ccr_val_23           = {'d23};
            bins dce_ccr_val_24           = {'d24};
            bins dce_ccr_val_25           = {'d25};
            bins dce_ccr_val_26           = {'d26};
            bins dce_ccr_val_27           = {'d27};
            bins dce_ccr_val_28           = {'d28};
            bins dce_ccr_val_29           = {'d29};
            bins dce_ccr_val_30           = {'d30};
            bins dce_ccr_val_31           = {'d31};
        }
        <% } %>

        <% for(var i = 0; i < obj.nDMIs; i++) { %>
        cp_dmi_ccr<%=i%>: coverpoint DMI_CCR<%=i%>_Val {
            bins dmi_ccr_val_0           = {'d0};
            bins dmi_ccr_val_1           = {'d1};
            bins dmi_ccr_val_2           = {'d2};
            bins dmi_ccr_val_3           = {'d3};
            bins dmi_ccr_val_4           = {'d4};
            bins dmi_ccr_val_5           = {'d5};
            bins dmi_ccr_val_6           = {'d6};
            bins dmi_ccr_val_7           = {'d7};
            bins dmi_ccr_val_8           = {'d8};
            bins dmi_ccr_val_9           = {'d9};
            bins dmi_ccr_val_10           = {'d10};
            bins dmi_ccr_val_11           = {'d11};
            bins dmi_ccr_val_12           = {'d12};
            bins dmi_ccr_val_13           = {'d13};
            bins dmi_ccr_val_14           = {'d14};
            bins dmi_ccr_val_15           = {'d15};
            bins dmi_ccr_val_16           = {'d16};
            bins dmi_ccr_val_17           = {'d17};
            bins dmi_ccr_val_18           = {'d18};
            bins dmi_ccr_val_19           = {'d19};
            bins dmi_ccr_val_20           = {'d20};
            bins dmi_ccr_val_21           = {'d21};
            bins dmi_ccr_val_22           = {'d22};
            bins dmi_ccr_val_23           = {'d23};
            bins dmi_ccr_val_24           = {'d24};
            bins dmi_ccr_val_25           = {'d25};
            bins dmi_ccr_val_26           = {'d26};
            bins dmi_ccr_val_27           = {'d27};
            bins dmi_ccr_val_28           = {'d28};
            bins dmi_ccr_val_29           = {'d29};
            bins dmi_ccr_val_30           = {'d30};
            bins dmi_ccr_val_31           = {'d31};
        }
        <% } %>

        <% for(var i = 0; i < obj.nDIIs; i++) {
          if(obj.DiiInfo[i].strRtlNamePrefix != "sys_dii") { %>
        cp_dii_ccr<%=i%>: coverpoint DII_CCR<%=i%>_Val {
            bins dii_ccr_val_0           = {'d0};
            bins dii_ccr_val_1           = {'d1};
            bins dii_ccr_val_2           = {'d2};
            bins dii_ccr_val_3           = {'d3};
            bins dii_ccr_val_4           = {'d4};
            bins dii_ccr_val_5           = {'d5};
            bins dii_ccr_val_6           = {'d6};
            bins dii_ccr_val_7           = {'d7};
            bins dii_ccr_val_8           = {'d8};
            bins dii_ccr_val_9           = {'d9};
            bins dii_ccr_val_10           = {'d10};
            bins dii_ccr_val_11           = {'d11};
            bins dii_ccr_val_12           = {'d12};
            bins dii_ccr_val_13           = {'d13};
            bins dii_ccr_val_14           = {'d14};
            bins dii_ccr_val_15           = {'d15};
            bins dii_ccr_val_16           = {'d16};
            bins dii_ccr_val_17           = {'d17};
            bins dii_ccr_val_18           = {'d18};
            bins dii_ccr_val_19           = {'d19};
            bins dii_ccr_val_20           = {'d20};
            bins dii_ccr_val_21           = {'d21};
            bins dii_ccr_val_22           = {'d22};
            bins dii_ccr_val_23           = {'d23};
            bins dii_ccr_val_24           = {'d24};
            bins dii_ccr_val_25           = {'d25};
            bins dii_ccr_val_26           = {'d26};
            bins dii_ccr_val_27           = {'d27};
            bins dii_ccr_val_28           = {'d28};
            bins dii_ccr_val_29           = {'d29};
            bins dii_ccr_val_30           = {'d30};
            bins dii_ccr_val_31           = {'d31};
        }
        <% }
        } %>

    endgroup : io_crd_cg_val_<%=multiPortCoreId%>

    covergroup io_crd_cg_state_<%=multiPortCoreId%>;

        <% for(var i = 0; i < obj.nDCEs; i++) { %>
        //Only for multiported IOAIU certain cores connect to certain DCEs
        //Following logic is for Core0,1 connecting to DCE0 & Core2,3 to DCE1
        <% var print = false;
             if (obj.nNativeInterfacePorts > 1 && obj.nDCEs > 1) {
               if (mapping[i].includes(multiPortCoreId)) {
                 print = true
               }
             } else print = true;
             if (print) {%>
        cp_dce_ccr_state<%=i%>: coverpoint DCE_CCR<%=i%>_state {
            bins dce_ccr_normal          = {'d0};
            bins dce_ccr_empty           = {'d1};
            bins dce_ccr_negative        = {'d2};
            bins dce_ccr_full            = {'d4};
        }
        <% } %>
        <% } %>
        <% for(var i = 0; i < obj.nDMIs; i++) { %>
        cp_dmi_ccr_state<%=i%>: coverpoint DMI_CCR<%=i%>_state {
            bins dmi_ccr_normal          = {'d0};
            bins dmi_ccr_empty           = {'d1};
            bins dmi_ccr_negative        = {'d2};
            bins dmi_ccr_full            = {'d4};
        }
        <% } %>
        <% for(var i = 0; i < obj.nDIIs; i++) {
          if(obj.DiiInfo[i].strRtlNamePrefix != "sys_dii") { %>
        cp_dii_ccr_state<%=i%>: coverpoint DII_CCR<%=i%>_state {
            bins dii_ccr_normal          = {'d0};
            bins dii_ccr_empty           = {'d1};
            bins dii_ccr_negative        = {'d2};
            bins dii_ccr_full            = {'d4};
        }
        <% }
        } %>

    endgroup : io_crd_cg_state_<%=multiPortCoreId%>
    <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>

        covergroup starvation_eventstatus_<%=multiPortCoreId%>;
           starvation_bit : coverpoint EventStatus{
                bins in_starvation  ={'d1};
                }
           starvation_cnt : coverpoint starv_cnt{
                bins starv_bins_1_5 = {[1:5]};
                bins starv_bins_6_10 = {[6:10]};
               ignore_bins ignore_starv_bins_11_15 = {[11:15]};
                }

        endgroup:starvation_eventstatus_<%=multiPortCoreId%>
    <%}%>


    <%}%>

        //#Cover.IOAIU.LookupEn_AllocEn_UpdateDis    
    <%if(obj.useCache) { %>
         <% for(var multiPortCoreId = 0; multiPortCoreId < obj.nNativeInterfacePorts; multiPortCoreId++) { %>
         covergroup ccp_control_reg_core<%=multiPortCoreId%>;
         //add bins
          ccp_lookup_bit : coverpoint ccp_LookupEn{
                 bins LookupEn_0 = {0};
                 bins LookupEn_1 = {1};
         }
          ccp_alloc_bit : coverpoint ccp_AllocEn{
                 bins AllocEn_0 = {0};
                 bins AllocEn_1 = {1};
         }
         ccp_update_bit : coverpoint ccp_disableupd{
                 bins UpdateDis_0 = {0};
                 bins UpdateDis_1 = {1};
         }
         cx_LookupEn_AllocEn_UpdateDis: cross ccp_LookupEn,ccp_AllocEn,ccp_disableupd  {
                 ignore_bins LookupEn_0=  binsof(ccp_LookupEn) intersect {0};
         } 
         endgroup : ccp_control_reg_core<%=multiPortCoreId%>
         <%}%>
    <%}%>
      <%if((obj.testBench =="io_aiu") && (obj.useResiliency)){%>
        covergroup mission_fault_causes_cg;
       // wrong target id error coverpoint 
          wrong_tgt_id_on_cp : coverpoint mission_fault_with_err{ 

                 bins cmdrsp_wrtgtid = {CMDrsp_wrong_tgt_id};
                 bins dtrreq_wrtgtid = {DTRreq_wrong_tgt_id};
                 bins dtrrsp_wrtgtid = {DTRrsp_wrong_tgt_id};
                 bins dtwrsp_wrtgtid = {DTWrsp_wrong_tgt_id};
                 bins snpreq_wrtgtid = {SNPreq_wrong_tgt_id};
                 bins updrsp_wrtgtid = {UPDrsp_wrong_tgt_id};
                 bins sysreq_wrtgtid = {SYSreq_wrong_tgt_id};
                 bins sysrsp_wrtgtid = {SYSrsp_wrong_tgt_id}; 
          }

       // time_out error coverpoint
          time_out_error_cp : coverpoint mission_fault_with_err{ 

	         <%if(obj.eAc && ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E"))) { %>
                 bins dvm_time_out          = {dvm_time_out};
                 <%}%>
                 bins STRreq_time_out       = {STRreq_time_out};
                 <%if(((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) && obj.useCache){ %>    
                 bins CCP_eviction_time_out = {CCP_eviction_time_out};
                 <%}%>
                 bins CMDrsp_time_out       = {CMDrsp_time_out};
                 <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){ %>
                 bins sys_event_timeout     = {sys_event_timeout};
                 <%}%>
	         <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) && obj.useCache)) { %>
		 bins sys_req_timeout       = {sys_req_timeout};
                 <%}%>
          }

       // sys event error 
	  <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) && obj.useCache)) { %>
          sysevent_error_cg : coverpoint mission_fault_with_err{ 

                 bins sysevent_error = {sysevent_error};       
          }
          <%}%>

          <%if(((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")|| (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) && obj.assertOn) {%>
          mem_det_en_cp: coverpoint mission_fault_with_err{
                 <%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") && obj.assertOn) {%>
                 bins ott_error_out          = {ott_err};
                 <% } %>
                 <%if((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") && obj.assertOn) {%>
		 bins tag_error_out          = {tag_err};
                 <% } %>
                 <%if((obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY") && obj.assertOn) {%>
                 bins data_error_out         = {data_err};
                 <% } %>
         }
         <% } %>


          mission_fault_cp : coverpoint mission_fault{
                 bins mission_fault = {1};
          }

          transport_det_en_cp : coverpoint trans_det_en {
                 bins transport_det_en_0 = {0};
                 bins transport_det_en_1 = {1};
          }
          
          time_out_det_en_cp : coverpoint time_out_deten {
                 bins time_out_det_en_0  = {0};
                 bins time_out_det_en_1  = {1};
          }

          prot_err_det_en_cp : coverpoint proterr_det_en {
                 bins prot_err_det_en_0  = {0};
                 bins prot_err_det_en_1  = {1};
          }

          mem_det_en : coverpoint mem_det_en{
                 bins mem_det_en_0 = {0};
                 bins mem_det_en_1 = {1};
          }

       //================== cross===============================
          wrong_tgt_id_on_cp_X_mission_fault_cp_X_transport_det_en_cp: cross wrong_tgt_id_on_cp,mission_fault_cp,transport_det_en_cp;

          time_out_error_cp_X_mission_fault_X_time_out_det_en: cross time_out_error_cp,mission_fault_cp,time_out_det_en_cp;

	  <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) && obj.useCache)) { %>
          sysevent_error_cg_X_mission_fault_cp_X_prot_err_det_en_cp: cross sysevent_error_cg,mission_fault_cp,prot_err_det_en_cp;
          <%}%>

          <%if(((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")|| (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) && obj.assertOn) {%>
          mem_error_cp_X_mission_fault_X_mem_det_en: cross mem_det_en,mission_fault_cp,mem_det_en_cp;
          <%}%>

          
        endgroup : mission_fault_causes_cg 
      <%}%>

	//#Cover.IOAIU.ARTRACE .Cmdreq
	////#Cover.IOAIU.AWTRACE .Cmdreq
	
      <%if(aiu_axiInt.params.eTrace > 0) { %>
        covergroup trace_cap_cg;
          cp_artrace         : coverpoint artrace{
		 bins ar_high={1};
		 bins ar_low ={0};
	  }
					  
          cp_rtrace          : coverpoint rtrace{
		 bins r_high={1};
		 bins r_low ={0};
          }

	  cp_wtrace          : coverpoint wtrace{
		 bins w_high={1};
		 bins w_low ={0};
	  }

          cp_awtrace         : coverpoint awtrace{
		 bins aw_high={1};
		 bins aw_low ={0};
	  }
	 					
          cp_btrace	     : coverpoint btrace{
		 bins b_high={1};
		 bins b_low ={0};
	  }

          cp_tm              : coverpoint smi_tm{
		 bins tm_high={1};
		 bins tm_low ={0};
          }

       //================== cross===============================

	  Read_X_TM: cross cp_artrace,cp_tm; 

          Write_X_TM: cross cp_awtrace,cp_tm,cp_wtrace,cp_btrace; 


        endgroup : trace_cap_cg	
        <%}%>

        //#Cover.IOAIU.MaintOp.XAIUPCMCROpCodes
        <%if(obj.useCache){%>        
        covergroup mntop_cg;

          mntop_cp : coverpoint mnt_opcode{
		bins initialize_entry    = {0};
		bins flush_all_entry     = {4};
		bins flush_entry_set_way = {5};
		bins flush_entry_addr    = {6};
		bins flush_addr_range    = {7};
		bins flush_setway_range  = {8};
		bins debug_read_entry    = {12};
		bins debug_write_entry   = {14};
          }

        endgroup:mntop_cg
        <%}%> 



	extern function void collect_scb_txn(ioaiu_scb_txn txn, int core_id);
    <%if(obj.nNativeInterfacePorts == 1){%>
        extern function void sample_rd_interleaved();
    <%}%>
	extern function void collect_axi_araddr(ioaiu_scb_txn txn, int core_id);
	extern function void collect_axi_awaddr(ioaiu_scb_txn txn, int core_id);
	extern function void collect_data_integrity_awaddr(ioaiu_scb_txn txn, int core_id);
        extern function void collect_dec_err_bresp(ioaiu_scb_txn txn,ace_write_resp_pkt_t resp_pkt,int core_id);
        extern function void collect_dec_err_rresp(ioaiu_scb_txn txn, ace_read_data_pkt_t resp_pkt, int core_id);
        extern function void collect_slv_err_bresp(ioaiu_scb_txn txn,ace_write_resp_pkt_t resp_pkt,int core_id);
        extern function void collect_slv_err_rresp(ioaiu_scb_txn txn, axi_rresp_t rresp, int core_id);
        extern function void collect_dtw_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);
        extern function void collect_dtr_req_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);
	extern function void  collect_correctable_error(int err_info,  int err_type, int counter, int errrcountoverflow, int core_id);
	extern function void collect_dtw_req_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);
	extern function void collect_str_req_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);	
    <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>
        extern function void Starvation_EachCore_EventStatus(int core_id, int starvation_count,bit starv_evt_status);
    <%}%>
	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>	
	extern function void collect_cmp_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);
        extern function void collect_snp_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);
	<% } %>

	// #Cover.IOAIU.UESR.ErrType_ErrInfo
        extern function void  collect_uncorrectable_error(int core_id);
    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACE-LITE" ||obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI4"||obj.fnNativeInterface == "AXI5") { %>
        extern function void collect_axi_rresp(ace_read_data_pkt_t txn, ace_read_addr_pkt_t addr_txn, int core_id);
        extern function void collect_axi_bresp(ace_write_resp_pkt_t txn, ace_write_addr_pkt_t addr_txn, int core_id);
    <%}%>

         extern function void collect_ill_op_rsnoop(ioaiu_scb_txn txn, ace_read_data_pkt_t resp_pkt, ace_read_addr_pkt_t addr_txn, int core_id);
	 extern function void collect_ill_op_wsnoop(ioaiu_scb_txn txn, ace_write_resp_pkt_t resp_pkt, ace_write_addr_pkt_t addr_txn, int core_id);

      <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
         extern function void collect_crresp_cmstatus(bit[1:0] pkt_crresp_err_dtxf, bit[1:0] pkt_cmstatus_dt_aiu_dmi, int core_id);
      <%}%>

	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5")&& obj.useCache == 1)){%>
		extern function void collect_sys_req_events(sysreq_pkt_t txn);
	<%}%>

	<%if(obj.eAc && ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E"))) { %>
		extern function void collect_ace_snoop_addr(ace_snoop_addr_pkt_t m_pkt, int core_id);
		extern function void collect_ace_snoop_resp(ace_snoop_resp_pkt_t m_pkt,ioaiu_scb_txn txn, int core_id);
		extern function void collect_ace_snoop_resp_with_req(ace_snoop_resp_pkt_t m_pkt, ace_snoop_addr_pkt_t m_pkt_addr,ioaiu_scb_txn txn, int core_id);
		extern function void collect_ace_snoop_data(ace_snoop_data_pkt_t m_pkt, int core_id);
	<% } %>

	<%if(obj.useCache) {%>
		extern function void collect_ncbu_ccp_ctrl_chnl_bnk(ccp_ctrl_pkt_t mpkt, int bnk_num, int ways, int core_id);
		extern function void collect_ncbu_ccp_fill_ctrl_chnl(ccp_fillctrl_pkt_t mpkt, int ways, int core_id);
		extern function void collect_ncbu_ccp_evict_chnl(ccp_evict_pkt_t mpkt, int core_id);
	<%}%>

   	extern function void collect_ioaiu_smi_port(smi_seq_item m_pkt);
    <%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.useCache)) { %>
    //sharer_promotion & owner_transfer
        extern function void collect_shar_prom_ownr_txfr(ioaiu_scb_txn txn, int core_id);
    <%}%>
  
    extern function void collect_ccr_val(int core_id, int dceCreditLimit[<%=obj.nDCEs%>], int dmiCreditLimit[<%=obj.nDMIs%>], int diiCreditLimit[<%=obj.nDIIs%>]);
    <%if(obj.testBench =="io_aiu"){%>
    extern function void collect_ccr_state(int core_id);
    <%}%>

      <%if((obj.testBench =="io_aiu") && (obj.useResiliency)){%>
   	extern function void collect_mission_fault_causes(bit fault_mission_fault, bit transport_det_en, bit time_out_det_en, bit prot_err_det_en,bit mem_err_det_en);
      <%}%>
	
      <%if(aiu_axiInt.params.eTrace > 0) { %>
	extern function void collect_trace_cap(ioaiu_scb_txn txn);
      <%}%> 

   	extern function new();
        extern task collect_connectivity ();
	extern function void collect_ccp_control_reg(bit LookupEn ,bit AllocEn,bit disable_upd,int core_id);
       
        // Interfaces
        virtual <%=obj.BlockId%>_connectivity_if connectivity_if;

        <%if((obj.useResiliency || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") && ((obj.testBench != "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t")) || obj.testBench =="io_aiu") { %>
        virtual <%=obj.BlockId%>_probe_if u_csr_probe_if[<%=obj.DutInfo.nNativeInterfacePorts%>];
        <%}%> 

        extern function void collect_mnt_opcode(int mntop_opcode);

endclass // ioaiu_coverage

<%if(obj.nNativeInterfacePorts == 1){%>
    function void ioaiu_coverage::sample_rd_interleaved();
        rd_interleave_cg.sample();
    endfunction : sample_rd_interleaved
<%}%>

function void ioaiu_coverage::collect_scb_txn(ioaiu_scb_txn txn, int core_id);
        int orig_dtsize;

	m_scb_txn = txn;
	<%if(obj.useCache) { %>
		// compute the CTRL (OP and Fill) CCP packet to extract the next_state
	    if (m_scb_txn.m_ccp_ctrl_pkt) begin:op_ctrl_pkt
			ccp_current_state = m_scb_txn.m_ccp_ctrl_pkt.currstate;
            if (m_scb_txn.m_ccp_ctrl_pkt.tagstateup) begin				
			  ccp_next_state = m_scb_txn.m_ccp_ctrl_pkt.state;
			end else if (m_scb_txn.m_ccp_fillctrl_pkt_t) begin
				ccp_next_state = m_scb_txn.m_ccp_fillctrl_pkt_t.state;
		    end else begin
			ccp_next_state = ccp_current_state;
		    end
		end:op_ctrl_pkt
		
		if (m_scb_txn.m_dtr_req_pkt == null) begin
			//create a dummy dtr to avoid "bad handle error" in case of CmdMkUnq without DTR but DTR in the cross cover 
			  smi_seq_item dummy_dtr_req_pkt = new();
			  dummy_dtr_req_pkt.smi_msg_type = 0;
			  m_scb_txn.m_dtr_req_pkt = dummy_dtr_req_pkt;
			end
			
		if (m_scb_txn.m_cmd_req_pkt) begin:_with_cmdreq
		    if(m_scb_txn.m_cmd_req_pkt.isCmdMsg())  begin
                case(core_id)
                    <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                        <%=i%>: begin
			                ccp_state_cmdreq_core<%=i%>.sample();
                        end
                    <%}%>
                endcase
		    end 
		end:_with_cmdreq else begin: _without_cmd_req
			//create dummy cmdreq packet to avoid "bad handle error" in case of CMDREQ pkt in the cross cover.
			smi_seq_item dummy_cmd_req_pkt = new();
			dummy_cmd_req_pkt.smi_msg_type = 0;
		    m_scb_txn.m_cmd_req_pkt = dummy_cmd_req_pkt;
		end: _without_cmd_req

		if (!m_scb_txn.m_ace_read_addr_pkt) begin
			//create dummy read_addr axi4 packet to avoid "bad handle error" in the cross cover
			ace_read_addr_pkt_t dummy_read_addr = new();
			dummy_read_addr.arcache = axi_arcache_enum_t'(0);
			m_scb_txn.m_ace_read_addr_pkt = dummy_read_addr;
		end

		if (!m_scb_txn.m_ace_write_addr_pkt) begin
			//create dummy write_addr axi4 packet to avoid "bad handle error" in the cross cover
			ace_write_addr_pkt_t dummy_write_addr = new();
			dummy_write_addr.awcache = axi_awcache_enum_t'(0);
			m_scb_txn.m_ace_write_addr_pkt = dummy_write_addr;
		end
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
		            ccp_state_Nativereq_to_cmdreq_core<%=i%>.sample();
                end
            <%}%>
        endcase
		
   		//#Cov.IOAIU.SNPReq.SnpTypeState
   		if(m_scb_txn.isSnoop && m_scb_txn.csr_ccp_lookupen && m_scb_txn.csr_ccp_allocen) begin
      		$cast(snp_type,m_scb_txn.m_snp_req_pkt.smi_msg_type);
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                        ccp_snp_type_state_core<%=i%>.sample();
			            ccp_state_snprsp_core<%=i%>.sample();
                    end
                <%}%>
            endcase
      		
   		end
	<%}%>
	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
   		if(m_scb_txn.isSnoop ) begin
                case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
			 ace_snprsp_core<%=i%>.sample();
                    end
                <%}%>
                endcase
                end

	<%}%>
	<%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                if(!($test$plusargs("unmapped_add_access") || $test$plusargs("random_gpra_secure"))) begin
	        if((addrMgrConst::get_unit_type(m_scb_txn.home_dmi_unit_id) == addrMgrConst::DII)) tgt_type=DII; 
                else tgt_type=DMI;
	        if(m_scb_txn.m_cmd_req_pkt ) begin 
	           if(  m_scb_txn.isCoherent==0  ) begin 
                      if(m_scb_txn.m_cmd_req_pkt.isCmdMsg()==1) begin
                         if(m_scb_txn.isIoCacheEvict==1) begin
                            isEvict=1;
                            Cmd_Req=CmdWrNCFull;
                            if(m_scb_txn.m_cmd_req_pkt.smi_msg_type !=eCmdWrNCFull)
                            `uvm_error("IOAIU_COV",$psprintf("Unexpected concerto msg,noncoherent evict %p", m_scb_txn.m_cmd_req_pkt.smi_msg_type))
                         end else begin
                            isEvict=0;
                            case(m_scb_txn.m_cmd_req_pkt.smi_msg_type)  
                               eCmdRdNC: Cmd_Req=CmdRdNC; 
                               eCmdWrNCFull: Cmd_Req=CmdWrNCFull;
                               eCmdWrNCPtl:Cmd_Req=CmdWrNCPtl;
                               eCmdRdAtm:Cmd_Req=CmdRdAtm;
                               eCmdWrAtm:Cmd_Req=CmdWrAtm;
                               eCmdSwAtm:Cmd_Req=CmdSwAtm;
                               eCmdCompAtm:Cmd_Req=CmdCompAtm; 
                               default:`uvm_error("IOAIU_COV",$psprintf("Unexpected concerto msg for noncoherent address %p", m_scb_txn.m_cmd_req_pkt.smi_msg_type))
                            endcase
                         end
                      end else Cmd_Req=NoMsg; 
                    end
	           if( m_scb_txn.isCoherent==1  ) begin 
                      if(m_scb_txn.m_cmd_req_pkt.isCmdMsg()==1) begin
                         if(m_scb_txn.isIoCacheEvict==1) begin
                            isEvict=1;
                            Cmd_Req=CmdWrNCFull;
                            if(m_scb_txn.m_cmd_req_pkt.smi_msg_type !=eCmdWrNCFull)
                            `uvm_error("IOAIU_COV",$psprintf("Unexpected concerto msg,coherent evict %p", m_scb_txn.m_cmd_req_pkt.smi_msg_type))
                         end else begin
                            if(!(m_scb_txn.owo && m_scb_txn.m_2nd_cmd_req_pkt == null)) begin
                            isEvict=0;
			    if (m_scb_txn.owo && m_scb_txn.isWrite && m_scb_txn.isCoherent) msg_type = m_scb_txn.m_2nd_cmd_req_pkt.smi_msg_type;
			    else msg_type = m_scb_txn.m_cmd_req_pkt.smi_msg_type;
                        
                            case(msg_type)//same
                               eCmdRdNITC:    Cmd_Req=CmdRdNITC; 
                               eCmdRdVld:     Cmd_Req=CmdRdVld;
                               eCmdWrUnqPtl:  Cmd_Req=CmdWrUnqPtl;
                               eCmdRdUnq:     Cmd_Req=CmdRdUnq;
                               eCmdWrUnqFull: Cmd_Req=CmdWrUnqFull;
                               eCmdMkUnq:     Cmd_Req=CmdMkUnq;
                               eCmdRdNC:      Cmd_Req=CmdRdNC;
                               eCmdWrNCFull:  Cmd_Req=CmdWrNCFull; //owo
                               eCmdWrNCPtl:   Cmd_Req=CmdWrNCPtl; //owo
                               eCmdRdAtm:     Cmd_Req=CmdRdAtm;
                               eCmdWrAtm:     Cmd_Req=CmdWrAtm;
                               eCmdSwAtm:     Cmd_Req=CmdSwAtm;
                               eCmdCompAtm:   Cmd_Req=CmdCompAtm;
                               default:`uvm_error("IOAIU_COV",$psprintf("Unexpected concerto msg for coherent address %p", m_scb_txn.m_cmd_req_pkt.smi_msg_type))
                            endcase
                        end
                       end
                      end else Cmd_Req=NoMsg; 
                    end
                end else begin
		    //create dummy cmdreq packet to avoid "bad handle error" in case of CMDREQ pkt in the cross cover.
		    smi_seq_item dummy_cmd_req_pkt = new();
		    dummy_cmd_req_pkt.smi_msg_type = 0;
		    m_scb_txn.m_cmd_req_pkt = dummy_cmd_req_pkt;
                end
                
                if(m_scb_txn.m_ace_write_addr_pkt==null);
                else awcache_axi4=m_scb_txn.m_ace_write_addr_pkt.awcache;
                if(m_scb_txn.m_ace_read_addr_pkt==null);
                else arcache_axi4=m_scb_txn.m_ace_read_addr_pkt.arcache;
	<%if(obj.useCache) { %>
	        if (m_scb_txn.m_ccp_ctrl_pkt) begin
	    	    CCPcurrentstate = m_scb_txn.m_ccp_ctrl_pkt.currstate;
                    if (m_scb_txn.m_ccp_ctrl_pkt.tagstateup) begin				
	    	       CCPnextstate = m_scb_txn.m_ccp_ctrl_pkt.state;
	    	    end else if (m_scb_txn.m_ccp_fillctrl_pkt_t) begin
	    	       CCPnextstate = m_scb_txn.m_ccp_fillctrl_pkt_t.state;
	    	    end else begin
	    	    CCPnextstate = CCPcurrentstate;
	            end
		end else begin
                    CCPnextstate=IX;
                    CCPcurrentstate=IX;
                end
	<%} else {%>
                    CCPnextstate=nextst_IX;
                    CCPcurrentstate=currst_IX;
	<%}%>
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
		            ccp_coh_noncoh_ops_cg_core<%=i%>.sample();
                end
            <%}%>
        endcase
                end
	<%}%>
	 <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5") { %>
         <%var nativeinterface;
                if(obj.fnNativeInterface == "ACELITE-E")
                   nativeinterface = "ACELITE_E";
                else
                   nativeinterface = "AXI5";
            %>
    	if(m_scb_txn.isWrite && m_scb_txn.isAtomic) begin 					     
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
        	             <%=nativeinterface%>_atm_core<%=i%>.sample();
                    end
                <%}%>
            endcase
        end
     <%if(obj.fnNativeInterface == "ACELITE-E"){%>
        if(m_scb_txn.isRead) begin
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                        ace_lite_e_deallocating_txns_and_pcmos_core<%=i%>.sample();
                    end
                <%}%>
            endcase
        end
        if(m_scb_txn.isStash) begin
            if (m_scb_txn.m_cmd_req_pkt)begin
                stash_target_identified= (m_scb_txn.m_cmd_req_pkt.smi_mpf1_stash_valid 
                     && (addrMgrConst::is_stash_enable(addrMgrConst::agentid_assoc2funitid(m_scb_txn.m_cmd_req_pkt.smi_mpf1_stash_nid))));
            end
            if (m_scb_txn.m_str_req_pkt == null) begin
              smi_seq_item dummy_str_req_pkt = new();
              dummy_str_req_pkt.smi_cmstatus_snarf = 0;
              m_scb_txn.m_str_req_pkt = dummy_str_req_pkt;
            end
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                         ace_lite_e_cover_stashvalid<%=i%>.sample();
                    end
                <%}%>
            endcase
        end
	<%}%>
   	<%}%>
        if(m_scb_txn.isWrite && m_scb_txn.m_ace_write_resp_pkt==null) $display($time,"collect_scb_txn: ace address %0h and txn_id %0h",m_scb_txn.m_ace_write_addr_pkt.awaddr,m_scb_txn.m_ace_write_addr_pkt.awid);
        if(m_scb_txn.isWrite) resp=m_scb_txn.m_ace_write_resp_pkt.bresp;
        else if(m_scb_txn.isRead) resp=m_scb_txn.m_ace_read_data_pkt.rresp[1:0];
	    nsx=addrMgrConst::get_addr_gprar_nsx(m_scb_txn.m_sfi_addr);
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
                    cg_security_feature_core<%=i%>.sample();
                end
            <%}%>
        endcase
	<%if(obj.fnNativeInterface == "ACELITE-E") { %>
	<%}%>
        //#Cover.IOAIU.Wstrb
	
        if(m_scb_txn.m_ace_write_addr_pkt != null) begin
	   awsize= m_scb_txn.m_ace_write_addr_pkt.awsize;
           awlen=m_scb_txn.m_ace_write_addr_pkt.awlen;
           awburst=axi_axburst_enum_t'(m_scb_txn.m_ace_write_addr_pkt.awburst);
	   m_aligned_addr 	= (m_scb_txn.m_ace_write_addr_pkt.awaddr/(2 ** awsize)) * (2 ** awsize);
           //if(m_scb_txn.isMultiAccess==0) begin
           //   awlen=m_scb_txn.m_ace_write_addr_pkt.awlen;
           //   awburst=axi_axburst_enum_t'(m_scb_txn.m_ace_write_addr_pkt.awburst);
           //end
           awdomain=m_scb_txn.m_ace_write_addr_pkt.awdomain;
           awsnoop=m_scb_txn.m_ace_write_addr_pkt.awsnoop;
      	   //uvm_report_info("DEBUG",$sformatf("not isMultiAccess total_beat %0d",total_beat),UVM_LOW);
        end         
        //if(m_scb_txn.isMultiAccess==1 && m_scb_txn.m_multiline_starting_write_addr_pkt !=null) begin
        //   awlen=m_scb_txn.m_multiline_starting_write_addr_pkt.awlen;
        //   awburst=axi_axburst_enum_t'(m_scb_txn.m_multiline_starting_write_addr_pkt.awburst);
      	//   //uvm_report_info("DEBUG",$sformatf("isMultiAccess total_beat %0d",total_beat),UVM_LOW);
        //end
	m_dtsize       	= (awlen + 1) * (2 ** awsize);
        if (m_scb_txn.isMultiAccess)
		wrCachelineAccess = multiple;
	else if(SYS_nSysCacheline == m_dtsize && (awburst == AXIWRAP || (awburst == AXIINCR && (m_aligned_addr % SYS_nSysCacheline) == 0))) 
		wrCachelineAccess = full;
	else 
		wrCachelineAccess = partial;

        total_beat=(SYS_nSysCacheline/(<%=obj.wData/8%>));

        if(m_scb_txn.m_ace_write_data_pkt != null) begin
           //for(int j=0 ; j < total_beat; j++) 
           for(int j=0 ; j < m_scb_txn.m_ace_write_data_pkt.wstrb.size(); j++) 
           begin
               wstrb = m_scb_txn.m_ace_write_data_pkt.wstrb[j];
               beat_num = j;
      	       //uvm_report_info("DEBUG",$sformatf("wrstb %0h, beat number %0h wrCachelineAccess %0s",wstrb,beat_num,wrCachelineAccess),UVM_LOW);
               case(core_id)
               <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                   <%=i%>: begin
                       wr_data_channel_<%=obj.wData/8%>B_core<%=i%>.sample(m_scb_txn.isMultiAccess, (m_dtsize == SYS_nSysCacheline), m_scb_txn.m_ace_write_data_pkt.wstrb.size());
                   end
               <%}%>
               endcase
           end
        end
        <%if (obj.orderedWriteObservation == true) {%>
        <%if((obj.fnNativeInterface == "ACE-LITE") ) { %>
                if(m_scb_txn.m_ace_write_addr_pkt !=null)begin
               
                    awcache=m_scb_txn.m_ace_write_addr_pkt.awcache;
                    awdomain=m_scb_txn.m_ace_write_addr_pkt.awdomain;
                end
                if(m_scb_txn.m_ace_read_addr_pkt !=null)begin
               
                    arcache=m_scb_txn.m_ace_read_addr_pkt.arcache;
                    ardomain=m_scb_txn.m_ace_read_addr_pkt.ardomain;
                end                

                case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
			 cg_PCIe_owo_feature<%=i%>.sample();
                    end
                <%}%>
                endcase
	<%}%>
   	<%}%>


endfunction // collect_scb_txn

function void ioaiu_coverage::collect_correctable_error(int err_info,  int err_type, int counter, int errrcountoverflow, int core_id);
cesr_err_info          = err_info;
cesr_err_type          = err_type;
cesr_counter           = counter;
cesr_errrcountoverflow = errrcountoverflow;

<%if(((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED") || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED")|| (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED"))) {%>
 correctable_error_covergroup_core0.sample();
<%}%>

endfunction

function void ioaiu_coverage::collect_mnt_opcode(int mntop_opcode);
     
	mnt_opcode = mntop_opcode;
        <%if(obj.useCache){%>    
	mntop_cg.sample();
	<%}%>

endfunction : collect_mnt_opcode

function void ioaiu_coverage::collect_uncorrectable_error(int core_id);
uvm_config_db#(int)::get(null,"*","ioaiu_fault_mission_fault",mission_fault);
uvm_config_db#(int)::get(null,"*","ioaiu_smi_prot_uesr_err_vld",intf_per_err_vld);
uvm_config_db#(int)::get(null,"*","ioaiu_fault_thres_fault",thres_fault);
//#Cover.IOAIU.UESR.ErrType_ErrInfo 
if(!uvm_config_db#(int)::get(null,"*","ioaiu_data_user_err_info",data_tag_ott_uesr_err_info))begin
data_tag_ott_uesr_err_info = 7;
end
if(!uvm_config_db#(int)::get(null,"*","ioaiu_data_user_err_type",data_tag_ott_uesr_err_type))begin
data_tag_ott_uesr_err_type = 15;
end
uvm_config_db#(int)::get(null,"*","ioaiu_snoop_user_err_info",snoop_dtrreq_uesr_err_info);

//#Cover.IOAIU.Decode.User.Errtype_Errinfo
uvm_config_db#(int)::get(null,"*","ioaiu_decode_uesr_err_type",decode_uesr_err_type);
if(!uvm_config_db#(int)::get(null,"*","ioaiu_decode_uesr_err_type",decode_uesr_err_type))begin
decode_uesr_err_type = 15;
end
uvm_config_db#(int)::get(null,"*","ioaiu_decode_uesr_err_info",decode_uesr_err_info);
if(!uvm_config_db#(int)::get(null,"*","ioaiu_decode_uesr_err_info",decode_uesr_err_info))begin
decode_uesr_err_info = 15;
end

//#Cover.IOAIU.Software.User.Errtype_Errinfo
uvm_config_db#(int)::get(null,"*","ioaiu_software_uesr_err_type",software_uesr_err_type);
if(!uvm_config_db#(int)::get(null,"*","ioaiu_software_uesr_err_type",software_uesr_err_type))begin
software_uesr_err_type = 15;
end
uvm_config_db#(int)::get(null,"*","ioaiu_software_uesr_err_info",software_uesr_err_info);
if(!uvm_config_db#(int)::get(null,"*","ioaiu_software_uesr_err_info",software_uesr_err_info))begin
software_uesr_err_info = 15;
end



//#Cover.IOAIU.WrongTargetId
uvm_config_db#(int)::get(null,"*","ioaiu_wrong_target_id_uesr_err_type",wrong_target_id_uesr_err_type);
if(!uvm_config_db#(int)::get(null,"*","ioaiu_wrong_target_id_uesr_err_info",wrong_target_id_uesr_err_info))begin
wrong_target_id_uesr_err_info = 7;
end

//#Cover.IOAIU.SMIProtectionType
uvm_config_db#(int)::get(null,"*","ioaiu_smi_prot_uesr_err_type",smi_prot_uesr_err_type);
if(!uvm_config_db#(int)::get(null,"*","ioaiu_smi_prot_uesr_err_info",smi_prot_uesr_err_info))begin
smi_prot_uesr_err_info = 7;
end
uvm_config_db#(int)::get(null,"*","ioaiu_smi_prot_cesr_err_type",smi_prot_cesr_err_type);
if(!uvm_config_db#(int)::get(null,"*","ioaiu_smi_prot_cesr_err_info",smi_prot_cesr_err_info))begin
smi_prot_cesr_err_info = 7;
end
`ifndef VCS
if(uvm_config_db#(int)::get(null,"*","ioaiu_smi_prot_err_msg_type",int'(smi_prot_cmd_types)))begin
`else // `ifndef VCS
if(uvm_config_db#(int)::get(null,"*","ioaiu_smi_prot_err_msg_type",smi_prot_cmd_types))begin
`endif // `ifndef VCS ... `else ... 

	if (smi_prot_cmd_types == eConcMsgStrReq)
	smi_prot_cmd_types = is_StrReq;
	else if (smi_prot_cmd_types == eConcMsgSnpReq)
	smi_prot_cmd_types = is_SnpReq;
	else if (smi_prot_cmd_types == eConcMsgSysReq)
	smi_prot_cmd_types = is_SysReq;
	else if (smi_prot_cmd_types == eConcMsgSysRsp)
	smi_prot_cmd_types = is_SysRsp;
	else if (smi_prot_cmd_types == eConcMsgCCmdRsp)
	smi_prot_cmd_types = is_CCmdRsp;
	else if (smi_prot_cmd_types == eConcMsgNcCmdRsp)
	smi_prot_cmd_types = is_NcCmdRsp;
	else if (smi_prot_cmd_types == eConcMsgDtrRsp)
	smi_prot_cmd_types = is_DtrRsp;
	else if (smi_prot_cmd_types == eConcMsgDtwRsp)
	smi_prot_cmd_types = is_DtwRsp;
	else if (smi_prot_cmd_types == eConcMsgDtwDbgRsp)
	smi_prot_cmd_types = is_DtwDbgRsp;
	else if (smi_prot_cmd_types == eConcMsgDtrReq)
	smi_prot_cmd_types = is_DtrReq;
	else if (smi_prot_cmd_types == eConcMsgCmpRsp)
	smi_prot_cmd_types = is_CmpRsp;
	else if (smi_prot_cmd_types == eConcMsgUpdRsp)
	smi_prot_cmd_types = is_UpdRsp;
	else smi_prot_cmd_types = is_bad_smi_prot_cmd_type;
end
//#Cover.IOAIU.Sysco Timeout.User.Errtype_Errinfo
uvm_config_db#(int)::get(null,"*","ioaiu_sysco_time_out_uesr_err_type",sysco_time_out_uesr_err_type);
if(!uvm_config_db#(int)::get(null,"*","ioaiu_sysco_time_out_uesr_err_info",sysco_time_out_uesr_err_info))begin
sysco_time_out_uesr_err_info = 7;
end

//#Cover.IOAIU.Normal Timeout.User.Errtype_Errinfo
uvm_config_db#(int)::get(null,"*","ioaiu_normal_time_out_uesr_err_type",normal_time_out_uesr_err_type);
if(!uvm_config_db#(int)::get(null,"*","ioaiu_normal_time_out_uesr_err_info",normal_time_out_uesr_err_info))begin
//normal_time_out_uesr_err_info = 7;
end

//#Cover.IOAIU.Sysco Timeout.User.Errtype_Errinfo
uvm_config_db#(int)::get(null,"*","ioaiu_sys_event_time_out_err_type",sys_event_time_out_uesr_err_type);
if(!uvm_config_db#(int)::get(null,"*","ioaiu_sys_event_time_out_err_info",sys_event_time_out_uesr_err_info))begin
sys_event_time_out_uesr_err_info = 7;
end

  case(core_id)
  <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
  <%=i%>: begin 
  uncorrectable_error_covergroup_core<%=i%>.sample();
  end
  <%}%>
  endcase

endfunction

<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
function void ioaiu_coverage::collect_cmp_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);

               m_scb_txn      		= txn;
               m_cmp_rsp_pkt  		= m_pkt;
               ismultiline              = m_scb_txn.isMultiAccess;
               cmprsp_cmstatus_add_err  = m_cmp_rsp_pkt.smi_cmstatus_err_payload;
    
              if(txn.m_ace_cmd_type == DVMMSG) begin
              if(txn.isDVMSync)
              cmprsp_txn_type = Dvmsync;
              else
              cmprsp_txn_type = Dvmsync_nonsync;
              end
              
              case(core_id)
              <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
              <%=i%>: begin 
              cmprsp_cmstatus_err_covergroup_core<%=i%>.sample();
              end
              <%}%>
       	      endcase

endfunction
<% } %>

<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>

function void ioaiu_coverage::collect_snp_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);

               m_snp_rsp_pkt  		= m_pkt;
               snprsp_cmstatus_add_err  = m_snp_rsp_pkt.smi_cmstatus_err_payload;
    
              if(txn.txn_type == "DVMSYNC" )
              snprsp_txn_type = Dvmsync;
              else
              snprsp_txn_type = Dvmsync_nonsync;
             
              
              case(core_id)
              <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
              <%=i%>: begin 
              snprsp_cmstatus_err_covergroup_core<%=i%>.sample();
              end
              <%}%>
       	      endcase

endfunction

<% } %>

function void ioaiu_coverage::collect_dtw_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);
                 
               m_scb_txn      		= txn;
               m_dtw_rsp_pkt  		= m_pkt;
               ismultiline              = m_scb_txn.isMultiAccess;
               drwrsp_cmstatus_err      = m_dtw_rsp_pkt.smi_cmstatus_err_payload;
    
              if(m_scb_txn.isWrite)
              cmdtype  = is_write;
              else if(m_scb_txn.isIoCacheEvict)
              cmdtype  = is_IoCacheEvict; 
              
              case(core_id)
              <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
              <%=i%>: begin 
              dtwrsp_cmstatus_err_covergroup_core<%=i%>.sample();
              end
              <%}%>
       	      endcase

endfunction
//#Cover.IOAIU.DTRreq.CMStatusError.DBad
function void ioaiu_coverage::collect_dtr_req_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);
                 
               m_scb_txn      		= txn;
               m_dtr_req_pkt  		= m_pkt;
               ismultiline              = m_scb_txn.isMultiAccess;
               dtrreq_cmstatus_err      = m_dtr_req_pkt.smi_cmstatus_err_payload;
               foreach(m_dtr_req_pkt.smi_dp_dbad[i]) begin
               if(m_dtr_req_pkt.smi_dp_dbad[i] != 0)
                dbad[i]                     = 1;
               end 
              
              if(m_scb_txn.isWrite) begin
              cmdtype  = is_write;
              isPartial                = m_scb_txn.isPartialWrite;
              end else if(m_scb_txn.isRead) begin
              isPartial                = m_scb_txn.isPartialRead;
              cmdtype  = is_read;
              end 
              
              case(core_id)
              <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
              <%=i%>: begin 
              dtreq_cmstatus_err_covergroup_core<%=i%>.sample();
              end
              <%}%>
       	      endcase

endfunction

function void ioaiu_coverage::collect_dtw_req_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);
                 
               m_scb_txn      		= txn;
               m_dtw_req_pkt  		= m_pkt;
               drwreq_cmstatus_err      = m_dtw_req_pkt.smi_cmstatus_err_payload;
               foreach(m_dtw_req_pkt.smi_dp_dbad[i]) begin
               if(m_dtw_req_pkt.smi_dp_dbad[i] != 0)
               dtwreq_dbad                     = 1;
               end 
    
              if(m_scb_txn.isSnoop)
              cmdtype  = is_snoop;
              else if(m_scb_txn.isWrite)
              cmdtype  = is_write;
              else if(m_scb_txn.isIoCacheEvict)
              cmdtype  = is_IoCacheEvict;
 
             <%if(((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")|| (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.useCache) {%>
              case(core_id)
              <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
              <%=i%>: begin 
              dtwreq_cmstatus_err_covergroup_core<%=i%>.sample();
              end
              <%}%>
       	      endcase
              <%}%>

endfunction

//#Cover.IOAIU.STRreq.CMStatusError.Address.Data.
function void ioaiu_coverage::collect_str_req_cmstatus_err(ioaiu_scb_txn txn,smi_seq_item m_pkt, int core_id);
                 
               
	      m_scb_txn      		= txn;
              m_str_req_pkt  		= m_pkt;
              ismultiline               = m_scb_txn.isMultiAccess;
              strreq_cmtatus_err        = m_str_req_pkt.smi_cmstatus_err_payload;
               
              if(m_scb_txn.isAtomic && m_scb_txn.isCoherent)
	      strreq_type	=	coh_atomic;
	      else if(m_scb_txn.isWrite && m_scb_txn.isCoherent)
	      strreq_type	=	coh_write;
	      else if(m_scb_txn.isRead && m_scb_txn.isCoherent)
	      strreq_type	=	coh_read;
              
              case(core_id)
              <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
              <%=i%>: begin 
              strreq_cmstatus_err_covergroup_core<%=i%>.sample();
              end
              <%}%>
       	      endcase
endfunction

function void ioaiu_coverage::collect_dec_err_rresp(ioaiu_scb_txn txn, ace_read_data_pkt_t resp_pkt, int core_id);

               m_scb_txn = txn;

               ismultiline =  m_scb_txn.isMultiAccess;

               err_resp   =  resp_pkt.rresp;

               
               if(m_scb_txn.illegalNSAccess) 
			     Dec_Error_Type = illegalNSAccess;
               else if(m_scb_txn.addrNotInMemRegion)
                             Dec_Error_Type = addrNotInMemRegion;
               else if(m_scb_txn.mem_regions_overlap)
                             Dec_Error_Type = addrHitInMultipleRegion; 
               else if(m_scb_txn.dtwrsp_cmstatus_add_err)
                             Dec_Error_Type = dtwrsp_cmstatus_addr_err;
               else if(m_scb_txn.dtrreq_cmstatus_add_err)
                             Dec_Error_Type = dtrreq_cmstatus_addr_err;
               else if(m_scb_txn.hasFatlErr) 
                             Dec_Error_Type = strreq_cmstatus_addr_err;
               else if(m_scb_txn.illDIIAccess)
			     Dec_Error_Type = illDIIAccess;
               else 
                             Dec_Error_Type = no_error;

               if(m_scb_txn.dtwrsp_cmstatus_add_err) isDtwResperr=1;
               else isDtwResperr=0;
               if(m_scb_txn.dtrreq_cmstatus_add_err) isDtrReqerr=1;
               else isDtrReqerr=0;
               if(m_scb_txn.hasFatlErr) isStrReqerr=1;
               else isStrReqerr=0;
               

                if(m_scb_txn.isAtomic && m_scb_txn.isCoherent)
                             Txn_type = coh_atomic;
                else if(m_scb_txn.isAtomic && !m_scb_txn.isCoherent)
                             Txn_type = noncoh_atomic;
                else if(m_scb_txn.isUpdate)
 			    Txn_type = isUpdate;
		else if(m_scb_txn.isDVM)
 			    Txn_type = dvm;  
                else if(m_scb_txn.isCoherent)
                             Txn_type = coh_read;
                else if(!m_scb_txn.isCoherent)
                            Txn_type = noncoh_read;

              if(m_scb_txn.m_ace_write_addr_pkt !=null) awcmdtype   = m_scb_txn.m_ace_write_addr_pkt.awcmdtype;
            case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
             <%=i%>: begin 
            dec_error_covergroup_core<%=i%>.sample();
	   
            end
              <%}%>
       	    endcase
 

                
endfunction


function void ioaiu_coverage::collect_slv_err_rresp(ioaiu_scb_txn txn, axi_rresp_t rresp, int core_id);

               m_scb_txn = txn;

               ismultiline =  m_scb_txn.isMultiAccess;

               err_resp   = rresp;

               
               if(m_scb_txn.predict_ott_data_error) 
			     Slv_Error_Type = dataUncorrectableError;
               else if(m_scb_txn.dtwrsp_cmstatus_slv_err)
                             Slv_Error_Type = dtwrsp_cmstatus_data_err;
               else if(m_scb_txn.dtrreq_cmstatus_err && err_resp ==2)
                             Slv_Error_Type = dtrreq_cmstatus_data_err;
               else if(m_scb_txn.hasFatlErr && err_resp ==2) 
                             Slv_Error_Type = strreq_cmstatus_data_err;
               else 
                             Slv_Error_Type = no_error;

               if(m_scb_txn.dtwrsp_cmstatus_slv_err) isDtwResperr=1;
               else isDtwResperr=0;
               if(m_scb_txn.dtrreq_cmstatus_err && err_resp ==2) isDtrReqerr=1;
               else isDtrReqerr=0;
               if(m_scb_txn.hasFatlErr && err_resp ==2) isStrReqerr=1;
               else isStrReqerr=0;
               

                if(m_scb_txn.isAtomic && m_scb_txn.isCoherent)
                             Txn_type = coh_atomic;
                else if(m_scb_txn.isAtomic && !m_scb_txn.isCoherent)
                             Txn_type = noncoh_atomic;
                else if(m_scb_txn.isUpdate)
 			    Txn_type = isUpdate;
		else if(m_scb_txn.isDVM)
 			    Txn_type = dvm;  
                else if(m_scb_txn.isCoherent)
                             Txn_type = coh_read;
                else if(!m_scb_txn.isCoherent)
                            Txn_type = noncoh_read;

              if(m_scb_txn.m_ace_write_addr_pkt !=null) awcmdtype   = m_scb_txn.m_ace_write_addr_pkt.awcmdtype;
            case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
             <%=i%>: begin 
            slv_error_covergroup_core<%=i%>.sample();
	   
            end
              <%}%>
       	    endcase
 

                
endfunction

<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" ) { %>
//#Cover.check.cmstatus.with.crresp_errbit_datatransferbit
  function void ioaiu_coverage::collect_crresp_cmstatus(bit[1:0] pkt_crresp_err_dtxf, bit[1:0] pkt_cmstatus_dt_aiu_dmi,int core_id);
    crresp_err_dtxfer    = pkt_crresp_err_dtxf;
    cmstatus_dt_aiu_dmi  = pkt_cmstatus_dt_aiu_dmi;
     case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
             <%=i%>: begin  
                crresp_cmstatus_covergroup_core<%=i%>.sample();
            end
            <%}%>

     endcase

  endfunction
  <%}%>


//#Cover.IOAIU.IllegaIOpToDII.DECERR
function void ioaiu_coverage::collect_ill_op_rsnoop(ioaiu_scb_txn txn, ace_read_data_pkt_t resp_pkt, ace_read_addr_pkt_t addr_txn, int core_id);
illop_rresp = resp_pkt.rresp;
if(addr_txn != null) begin
illop_ardomain = addr_txn.ardomain;
illop_arsnoop = addr_txn.arsnoop;
end
ill_op_to_dii = txn.illDIIAccess;

 case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
             <%=i%>: begin 
            illop_to_dii_covergroup_core<%=i%>.sample(); 
            end
            <%}%>
 endcase

endfunction
//#Cover.IOAIU.IllegaIOpToDII.DECERR
function void ioaiu_coverage::collect_ill_op_wsnoop(ioaiu_scb_txn txn, ace_write_resp_pkt_t resp_pkt, ace_write_addr_pkt_t addr_txn, int core_id);
illop_bresp = resp_pkt.bresp;
illop_awdomain = addr_txn.awdomain;;
illop_awsnoop = addr_txn.awsnoop;
ill_op_to_dii = txn.illDIIAccess;

 case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
             <%=i%>: begin 
            illop_to_dii_covergroup_core<%=i%>.sample(); 
            end
            <%}%>
 endcase

endfunction

function void ioaiu_coverage::collect_dec_err_bresp(ioaiu_scb_txn txn, ace_write_resp_pkt_t resp_pkt, int core_id);

               m_scb_txn = txn;

               ismultiline =  m_scb_txn.isMultiAccess;

               err_resp   =  resp_pkt.bresp;

               if(m_scb_txn.addrNotInMemRegion)
                             Dec_Error_Type = addrNotInMemRegion;
               else if(m_scb_txn.mem_regions_overlap)
                             Dec_Error_Type = addrHitInMultipleRegion;
               else if(m_scb_txn.illegalNSAccess) 
			     Dec_Error_Type = illegalNSAccess;
               else if(m_scb_txn.illDIIAccess) 
                             Dec_Error_Type = illDIIAccess; 
               else if(m_scb_txn.dtwrsp_cmstatus_add_err)
                             Dec_Error_Type = dtwrsp_cmstatus_addr_err;
                else if(m_scb_txn.dtrreq_cmstatus_add_err)
                             Dec_Error_Type = dtrreq_cmstatus_addr_err;
               else if(m_scb_txn.hasFatlErr) 
                             Dec_Error_Type = strreq_cmstatus_addr_err;
               else 
                             Dec_Error_Type = no_error;

               

                if(m_scb_txn.isAtomic && m_scb_txn.isCoherent)
                             Txn_type = coh_atomic;
                else if(m_scb_txn.isAtomic && !m_scb_txn.isCoherent)
                             Txn_type = noncoh_atomic;
                else if(m_scb_txn.isUpdate)
 			    Txn_type = isUpdate;
                else if(m_scb_txn.isCoherent)
                             Txn_type = coh_write;
                else if(!m_scb_txn.isCoherent)
                            Txn_type = noncoh_write;
              if(m_scb_txn.m_ace_write_addr_pkt !=null) awcmdtype   = m_scb_txn.m_ace_write_addr_pkt.awcmdtype;

            case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
             <%=i%>: begin 
            dec_error_covergroup_core<%=i%>.sample();
            end
              <%}%>
       	    endcase
 

                
endfunction


function void ioaiu_coverage::collect_slv_err_bresp(ioaiu_scb_txn txn, ace_write_resp_pkt_t resp_pkt, int core_id);

               m_scb_txn = txn;

               ismultiline =  m_scb_txn.isMultiAccess;

               err_resp   =  resp_pkt.bresp;

               if(m_scb_txn.predict_ott_data_error)
                             Slv_Error_Type = dataUncorrectableError;
               else if(m_scb_txn.dtwrsp_cmstatus_slv_err)
                             Slv_Error_Type = dtwrsp_cmstatus_data_err;
                else if(m_scb_txn.dtrreq_cmstatus_err && err_resp ==2)
                             Slv_Error_Type = dtrreq_cmstatus_data_err;
               else if(m_scb_txn.hasFatlErr && err_resp ==2) 
                             Slv_Error_Type = strreq_cmstatus_data_err;
               else 
                             Slv_Error_Type = no_error;

               

                if(m_scb_txn.isAtomic && m_scb_txn.isCoherent)
                             Txn_type = coh_atomic;
                else if(m_scb_txn.isAtomic && !m_scb_txn.isCoherent)
                             Txn_type = noncoh_atomic;
                else if(m_scb_txn.isUpdate)
 			    Txn_type = isUpdate;
                else if(m_scb_txn.isCoherent)
                             Txn_type = coh_write;
                else if(!m_scb_txn.isCoherent)
                            Txn_type = noncoh_write;
            if(m_scb_txn.m_ace_write_addr_pkt !=null) awcmdtype   = m_scb_txn.m_ace_write_addr_pkt.awcmdtype;
            case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
             <%=i%>: begin 
            slv_error_covergroup_core<%=i%>.sample();
            end
              <%}%>
       	    endcase
 

                
endfunction


function void ioaiu_coverage::collect_axi_araddr(ioaiu_scb_txn txn, int core_id);
   	int orig_dtsize;
	arsize         = txn.m_ace_read_addr_pkt.arsize;
	arcache         = txn.m_ace_read_addr_pkt.arcache;
        arlen           = (txn.isMultiAccess) ? txn.m_multiline_starting_read_addr_pkt.arlen :txn.m_ace_read_addr_pkt.arlen;
	arburst        = (txn.isMultiAccess) ? axi_axburst_enum_t'(txn.m_multiline_starting_read_addr_pkt.arburst) :axi_axburst_enum_t'(txn.m_ace_read_addr_pkt.arburst);
		//arburst        = axi_axburst_enum_t'(txn.m_ace_read_addr_pkt.arburst);
	m_dtsize       = (arlen + 1) * (2 ** arsize);
    //#Cover.IOAIU.addressAlignment
    
	m_aligned_addr = (txn.m_ace_read_addr_pkt.araddr/(2 ** arsize)) * (2 ** arsize);
	arlock = txn.m_ace_read_addr_pkt.arlock;
        araddr = txn.m_ace_read_addr_pkt.araddr;
	isCoherent = txn.isCoherent;
   
	if(txn.isMultiAccess)
		rdCachelineAccess = multiple;
	else if (SYS_nSysCacheline == m_dtsize && (arburst == AXIWRAP || (arburst == AXIINCR && (m_aligned_addr % SYS_nSysCacheline) == 0))) 
		rdCachelineAccess = full;
	else
		rdCachelineAccess = partial; 
	//   if      (arburst == AXIWRAP && txn.m_ace_read_addr_pkt.araddr % SYS_nSysCacheline != 0 && m_dtsize % SYS_nSysCacheline == 0 && m_dtsize > SYS_nSysCacheline) arWeirdWrap = 1;
	if (txn.isMultiAccess) begin
		orig_dtsize    = (txn.m_multiline_starting_read_addr_pkt.arlen + 1) * (2 **txn.m_multiline_starting_read_addr_pkt.arsize);
		if(orig_dtsize > SYS_nSysCacheline) 
			arWeirdWrap = 1;
	end
        tansfer_size_excl_rd=( (arlen+1) * (2**arsize));
        excl_size_rd=$clog2(tansfer_size_excl_rd);
        if(!$test$plusargs("unmapped_add_access")) begin
	if((addrMgrConst::get_unit_type(txn.home_dmi_unit_id) == addrMgrConst::DII)) tgt_type=DII; 
        else tgt_type=DMI;
        end
	
    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "ACELITE-E") { %>
        araddr = txn.m_ace_read_addr_pkt.araddr;
        ardomain = txn.m_ace_read_addr_pkt.ardomain;
        arsnoop = txn.m_ace_read_addr_pkt.arsnoop;
        arprot = txn.m_ace_read_addr_pkt.arprot;
        arcache = txn.m_ace_read_addr_pkt.arcache;
        arqos = txn.m_ace_read_addr_pkt.arqos;
        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                        ace_rd_addr_chnl_signals_core<%=i%>.sample();
                    end
                <%}%>
            endcase
        <%} %>
        <%if(obj.fnNativeInterface == "ACE-LITE") { %>
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                        ace_lite_rd_addr_chnl_signals_core<%=i%>.sample();
                    end
                <%}%>
            endcase
        <%} %>
    <%} %>
    case(core_id)
        <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
            <%=i%>: begin
                ioaiu_narrow_transfer_core<%=i%>.sample();
                <%if ((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%}else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")|| (obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%>ace_lite_e<%} %>_rd_addr_chnl_core<%=i%>.sample();
            end
        <%}%>
    endcase
endfunction // collect_axi_araddr

function void ioaiu_coverage::collect_axi_awaddr(ioaiu_scb_txn txn, int core_id);
	int orig_dtsize;
	
	awsize         	= txn.m_ace_write_addr_pkt.awsize;
    awlen           = (txn.isMultiAccess) ? txn.m_multiline_starting_write_addr_pkt.awlen :txn.m_ace_write_addr_pkt.awlen;
	awburst        	= (txn.isMultiAccess) ? axi_axburst_enum_t'(txn.m_multiline_starting_write_addr_pkt.awburst) :axi_axburst_enum_t'(txn.m_ace_write_addr_pkt.awburst);
	m_dtsize       	= (awlen + 1) * (2 ** awsize);
	m_aligned_addr 	= (txn.m_ace_write_addr_pkt.awaddr/(2 ** awsize)) * (2 ** awsize);
	awlock 			= txn.m_ace_write_addr_pkt.awlock;
	awsnoop 		= txn.m_ace_write_addr_pkt.awsnoop;
	awdomain		= txn.m_ace_write_addr_pkt.awdomain;
        awprot                  = txn.m_ace_write_addr_pkt.awprot;
        awqos                   = txn.m_ace_write_addr_pkt.awqos;
	awunique		= txn.m_ace_write_addr_pkt.awunique;
	awaddr 			= txn.m_ace_write_addr_pkt.awaddr;
	awcache 		= txn.m_ace_write_addr_pkt.awcache;
	isCoherent              = txn.isCoherent;

	if (txn.isMultiAccess)
		wrCachelineAccess = multiple;
	else if(SYS_nSysCacheline == m_dtsize && (awburst == AXIWRAP || (awburst == AXIINCR && (m_aligned_addr % SYS_nSysCacheline) == 0))) 
		wrCachelineAccess = full;
	else 
		wrCachelineAccess = partial;
   	//$display("ioaiu_coverage :: awburst: %d, awaddr: %d, awsize: %d, SYS_nSysCacheline: %d, m_dtsize: %d, awlen: %d", awburst, txn.m_ace_write_addr_pkt.awaddr, awsize, SYS_nSysCacheline, m_dtsize, awlen); 
	//   if      ((awburst == AXIWRAP) && ((txn.m_ace_write_addr_pkt.awaddr % SYS_nSysCacheline) != 0) && ((m_dtsize % SYS_nSysCacheline) == 0) && (m_dtsize > SYS_nSysCacheline)) awWeirdWrap = 1;
   	if(txn.isMultiAccess) begin
      	orig_dtsize    = (txn.m_multiline_starting_write_addr_pkt.awlen + 1) * (2 **txn.m_multiline_starting_write_addr_pkt.awsize);
      	uvm_report_info("DCDEBUG",$sformatf("multiline wrap orig_dtsize:%0d",orig_dtsize),UVM_MEDIUM);
      	if (orig_dtsize > SYS_nSysCacheline) 
		  	awWeirdWrap = 1;
   	end
        tansfer_size_excl_wr=( (awlen+1) * (2**awsize));
        excl_size_wr=$clog2(tansfer_size_excl_wr);
        if(!$test$plusargs("unmapped_add_access")) begin
	if((addrMgrConst::get_unit_type(txn.home_dmi_unit_id) == addrMgrConst::DII)) tgt_type=DII; 
        else tgt_type=DMI;
        end
   
	//$display("ioaiu_coverage :: awWeirdWrap: %d", awWeirdWrap);
	//if (txn.isAwidMatch) awid_matched = 1;
	//if (txn.isAwAddrMatch) awaddr_matched = 1;

	<%if(obj.fnNativeInterface == "ACELITE-E") { %>
		awstashnid   = txn.m_ace_write_addr_pkt.awstashnid;
		awstashniden = txn.m_ace_write_addr_pkt.awstashniden;
		awstashlpid   = txn.m_ace_write_addr_pkt.awstashlpid;
		awstashlpiden = txn.m_ace_write_addr_pkt.awstashlpiden;
		awatop = txn.m_ace_write_addr_pkt.awatop;
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
		            ace_lite_e_stash_core<%=i%>.sample();
                end
            <%}%>
        endcase
	<%}%>
    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
                    ace_wr_addr_chnl_signals_core<%=i%>.sample();
                end
            <%}%>
        endcase
    <%}%>
    <%if(obj.fnNativeInterface == "ACE-LITE") { %>
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
                    ace_lite_wr_addr_chnl_signals_core<%=i%>.sample();
                end
            <%}%>
        endcase
    <%}%>
    case(core_id)
        <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
            <%=i%>: begin
	            <%if ((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%}else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%>ace_lite_e<%}%>_wr_addr_chnl_core<%=i%>.sample();
            end
        <%}%>
    endcase
endfunction // collect_axi_awaddr

function void ioaiu_coverage::collect_data_integrity_awaddr(ioaiu_scb_txn txn, int core_id);
	int orig_dtsize;
	
	awsize         	= txn.m_ace_write_addr_pkt.awsize;
    awlen           = (txn.isMultiAccess) ? txn.m_multiline_starting_write_addr_pkt.awlen :txn.m_ace_write_addr_pkt.awlen;
	awburst        	= (txn.isMultiAccess) ? axi_axburst_enum_t'(txn.m_multiline_starting_write_addr_pkt.awburst) :axi_axburst_enum_t'(txn.m_ace_write_addr_pkt.awburst);
	awaddr        	= txn.m_ace_write_addr_pkt.awaddr;
	m_dtsize       	= (awlen + 1) * (2 ** awsize);
	m_aligned_addr 	= (txn.m_ace_write_addr_pkt.awaddr/(2 ** awsize)) * (2 ** awsize);
	awlock 			= txn.m_ace_write_addr_pkt.awlock;
	awsnoop 		= txn.m_ace_write_addr_pkt.awsnoop;
	awdomain		= txn.m_ace_write_addr_pkt.awdomain;
	awunique		= txn.m_ace_write_addr_pkt.awunique;

	if (txn.isMultiAccess)
		wrCachelineAccess = multiple;
	else if(SYS_nSysCacheline == m_dtsize && (awburst == AXIWRAP || (awburst == AXIINCR && (m_aligned_addr % SYS_nSysCacheline) == 0))) 
		wrCachelineAccess = full;
	else 
		wrCachelineAccess = partial;
		
   	if(txn.isMultiAccess) begin
      	orig_dtsize    = (txn.m_multiline_starting_write_addr_pkt.awlen + 1) * (2 **txn.m_multiline_starting_write_addr_pkt.awsize);
      	uvm_report_info("DCDEBUG",$sformatf("multiline wrap orig_dtsize:%0d",orig_dtsize),UVM_MEDIUM);
      	if (orig_dtsize > SYS_nSysCacheline) 
		  	awWeirdWrap = 1;
   	end

    case(core_id)
        <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
            <%=i%>: begin
                axi_data_integrity_check_core<%=i%>.sample();
            end
        <%}%>
    endcase
   
endfunction // collect_data_integrity_awaddr

<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache == 1)){%>
	function void ioaiu_coverage::collect_sys_req_events(sysreq_pkt_t txn);
		sysreq_pkt = txn;
		sys_req_events_cg.sample();
	endfunction : collect_sys_req_events
<%}%>

<%if(obj.eAc && ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E"))) { %>
	function void ioaiu_coverage::collect_ace_snoop_addr(ace_snoop_addr_pkt_t m_pkt, int core_id);
		acsnoop = m_pkt.acsnoop;
		acaddr = m_pkt.acaddr;
		acprot = m_pkt.acprot;
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
		            ace_snoop_address_channel_core<%=i%>.sample(); 
                end
            <%}%>
        endcase
	endfunction // collect_ace_snoop_addr

	function void ioaiu_coverage::collect_ace_snoop_resp(ace_snoop_resp_pkt_t m_pkt, ioaiu_scb_txn txn, int core_id);
           
	       if(m_pkt!= null) crresp = m_pkt.crresp;
               else if (txn.m_ace_snoop_resp_pkt0_act != null) crresp = txn.m_ace_snoop_resp_pkt0_act.crresp;
               else if (txn.m_ace_snoop_resp_pkt1_act != null) crresp = txn.m_ace_snoop_resp_pkt1_act.crresp;
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
		            ace_snoop_response_channel_core<%=i%>.sample(); 
                end
            <%}%>
        endcase
	endfunction // collect_ace_snoop_resp

	function void ioaiu_coverage::collect_ace_snoop_resp_with_req(ace_snoop_resp_pkt_t m_pkt, ace_snoop_addr_pkt_t m_pkt_addr,ioaiu_scb_txn txn, int core_id);
		if(m_pkt!=null) crresp = m_pkt.crresp;
                else if (txn.m_ace_snoop_resp_pkt0_act != null) crresp = txn.m_ace_snoop_resp_pkt0_act.crresp;
                else if (txn.m_ace_snoop_resp_pkt1_act != null) crresp = txn.m_ace_snoop_resp_pkt1_act.crresp;

		if(m_pkt_addr != null) acsnoop_rsp = m_pkt_addr.acsnoop;
                else if ((txn != null) && (txn.txn_type inside {"DVM","DVMSYNC"}))
                   acsnoop_rsp = 4'b1111;
               
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
		            ace_snoop_response_channel_with_req_core<%=i%>.sample();
                end
            <%}%>
        endcase 
	endfunction // collect_ace_snoop_resp_with_req

	function void ioaiu_coverage::collect_ace_snoop_data(ace_snoop_data_pkt_t m_pkt, int core_id);
		cdlast = m_pkt.cdlast;
		cddata = m_pkt.cddata;
        foreach(cddata[i]) begin
            cddata_beat = cddata[i];
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                        ace_snoop_data_core<%=i%>.sample();
                    end
                <%}%>
            endcase
        end 
	endfunction // collect_ace_snoop_data
<%}%>

<%if(obj.useCache) {%>
	function void ioaiu_coverage::collect_ncbu_ccp_ctrl_chnl_bnk(ccp_ctrl_pkt_t mpkt, int bnk_num, int ways, int core_id);
		tag_bank = mpkt.bnk;
		read_hit = mpkt.read_hit;
		read_miss_allocate = mpkt.read_miss_allocate;
		write_miss_allocate = mpkt.write_miss_allocate;
		write_hit = mpkt.write_hit;
		snoop_hit = mpkt.snoop_hit;
		write_hit_upgrade = mpkt.write_hit_upgrade;
		state =  mpkt.state;
		security = mpkt.security;
		evictvld = mpkt.evictvld;
		alloc_ways = mpkt.wayn;
		nacknoalloc = mpkt.nacknoalloc;
		m_pkt = new();
		m_pkt.copy(mpkt);
		way_<%=obj.nWays%> = mpkt.wayn;
		pending_way_<%=obj.nWays%> = mpkt.waypbusy_vec;
		    
		<%switch(obj.nTagBanks) { 
			case 1 : { %>
                case(core_id)
                    <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                        <%=i%>: begin
                            ccp_ctrl_pkt_bank_1_core<%=i%>.sample();
                        end
                    <%}%>
                endcase
            <% break;} 
			case 2 : { %>
                case(core_id)
                    <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                        <%=i%>: begin
                            ccp_ctrl_pkt_bank_2_core<%=i%>.sample();
                        end
                    <%}%>
                endcase
            <% break;} 
			case 4 : { %>
                case(core_id)
                    <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                        <%=i%>: begin
                            ccp_ctrl_pkt_bank_4_core<%=i%>.sample();
                        end
                    <%}%>
                endcase
            <% break;} 
			case 8 : { %>
                case(core_id)
                    <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                        <%=i%>: begin
                            ccp_ctrl_pkt_bank_8_core<%=i%>.sample();
                        end
                    <%}%>
                endcase
            <% break;} 
			case 16 : { %>
                case(core_id)
                    <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                        <%=i%>: begin
                            ccp_ctrl_pkt_bank_16_core<%=i%>.sample();
                        end
                    <%}%>
                endcase
            <% break;} 
			default : { %> `uvm_error("FUNC_CVG", $sformatf("Illegal bank count = %d", <%=obj.nTagBanks%>)) <% } 
		}; %>
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
                    ccp_ctrl_pkt_core<%=i%>.sample();
                end
            <%}%>
        endcase
		
	endfunction // collect_ncbu_ccp_ctrl_chnl_bnk

	function void ioaiu_coverage::collect_ncbu_ccp_fill_ctrl_chnl(ccp_fillctrl_pkt_t mpkt, int ways, int core_id);
		fill_security = mpkt.security;
		fill_state = mpkt.state;
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
		            ccp_fill_ctrl_pkt_misc_core<%=i%>.sample();
                end
            <%}%>
        endcase
	endfunction // collect_ncbu_ccp_fill_ctrl_chnl

	function void ioaiu_coverage::collect_ncbu_ccp_evict_chnl(ccp_evict_pkt_t mpkt, int core_id);
		evict_valid = 1;
		evict_cancel = mpkt.datacancel;
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
		            ccp_evict_pkt_core<%=i%>.sample();
                end
            <%}%>
        endcase
	endfunction // collect_ncbu_ccp_evict_chnl
<%}%>

function void ioaiu_coverage::collect_ioaiu_smi_port(smi_seq_item m_pkt);
	int          tmp_q[$];
	rdnitc = (m_pkt.smi_msg_type == eCmdRdNITC) && m_pkt.isCmdMsg() ? 1 : 0;
	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
		rdvld = (m_pkt.smi_msg_type == eCmdRdVld) && m_pkt.isCmdMsg() ? 1 : 0;
		rdcln  = (m_pkt.smi_msg_type == eCmdRdCln) && m_pkt.isCmdMsg() ? 1 : 0;
		rdunq  = (m_pkt.smi_msg_type == eCmdRdUnq) && m_pkt.isCmdMsg() ? 1 : 0;
		dvmmsg = (m_pkt.smi_msg_type == eCmdDvmMsg) && m_pkt.isCmdMsg() ? 1 : 0;
	<% } %>

	clnunq 		= (m_pkt.smi_msg_type == eCmdClnUnq) && m_pkt.isCmdMsg() ? 1 : 0;
	clnvld 		= (m_pkt.smi_msg_type == eCmdClnVld) && m_pkt.isCmdMsg() ? 1 : 0;
	clninv 		= (m_pkt.smi_msg_type == eCmdClnInv) && m_pkt.isCmdMsg() ? 1 : 0;
	mkinv 		= (m_pkt.smi_msg_type == eCmdMkInv) && m_pkt.isCmdMsg() ? 1 : 0;
	wrunqptl 	= (m_pkt.smi_msg_type == eCmdWrUnqPtl) && m_pkt.isCmdMsg() ? 1 : 0;
	wrunqfull 	= (m_pkt.smi_msg_type ==  eCmdWrUnqFull) && m_pkt.isCmdMsg() ? 1 : 0;
	wrncfull 	= (m_pkt.smi_msg_type == eCmdWrNCFull) && m_pkt.isCmdMsg() ? 1 : 0;

	dtr_data_inv = (m_pkt.smi_msg_type == DTR_DATA_INV) && 
					m_pkt.isDtrMsg() ? 1 : 0;
	dtr_data_shr_cln = (m_pkt.smi_msg_type == DTR_DATA_SHR_CLN) && 
					m_pkt.isDtrMsg() ? 1 : 0;
	dtr_data_shr_dty = (m_pkt.smi_msg_type == DTR_DATA_SHR_DTY) && 
					m_pkt.isDtrMsg() ? 1 : 0;
	dtr_data_unq_cln = (m_pkt.smi_msg_type == DTR_DATA_UNQ_CLN) && 
					m_pkt.isDtrMsg() ? 1 : 0;
	dtr_data_unq_dty = (m_pkt.smi_msg_type == DTR_DATA_UNQ_DTY) && 
					m_pkt.isDtrMsg() ? 1 : 0;

	cmstatus_err = m_pkt.smi_cmstatus_err;
   	//#Cov.IOAIU.SMI.CMDReq.TargIDWrNoSnoop
   	//#Cov.IOAIU.SMI.STRReq.CmStatusState
   
	smi_pkt.sample();
	if(m_pkt.isStrMsg()) begin
		str_req_msg = m_pkt;
		smi_StrReq_pkt.sample();
	end

	<% if(obj.nSttCtrlEntries > 0) { %>
		if(m_pkt.isSnpMsg()) begin
			smi_seq_item tmp_item = new();
			tmp_item.copy(m_pkt);
			snp_req_msg_q.push_back(tmp_item);
		end

		if(m_pkt.isSnpRspMsg()) begin
			smi_seq_item tmp_snp_req;
			snp_rsp_msg = m_pkt;
			tmp_q = {};
			tmp_q = snp_req_msg_q.find_index with (item.smi_msg_id == snp_rsp_msg.smi_rmsg_id);
			snp_req_msg = snp_req_msg_q[tmp_q[0]];
			snp_req_msg_q.delete(tmp_q[0]);
			smi_snoop_pkt.sample(); // don't cover smi snoop in case of error test
		end
	<%}%>
endfunction // collect_ioaiu_smi_port

//#Cover.IOAIU.v3.4.SCM.CreditLimitBin
function void ioaiu_coverage::collect_ccr_val(int core_id, int dceCreditLimit[<%=obj.nDCEs%>], int dmiCreditLimit[<%=obj.nDMIs%>], int diiCreditLimit[<%=obj.nDIIs%>]);

    <%for (var j=0; j< obj.nDCEs; j++){%>
        DCE_CCR<%=j%>_Val = dceCreditLimit[<%=j%>]; 
    <%}%>
    <%for (var j=0; j< obj.nDMIs; j++){%>
        DMI_CCR<%=j%>_Val = dmiCreditLimit[<%=j%>]; 
    <%}%>
    <%for (var j=0; j< obj.nDIIs; j++){
      if(obj.DiiInfo[j].strRtlNamePrefix != "sys_dii") { %>
        DII_CCR<%=j%>_Val = diiCreditLimit[<%=j%>];
    <%}
    }%>
    
    case(core_id)
    <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
        <%=i%>: begin
                io_crd_cg_val_<%=i%>.sample();
                end
    <%}%>
    endcase
endfunction // collect_ccr_val

<%if(obj.testBench =="io_aiu"){%>
//#Cover.IOAIU.v3.4.SCM.CounterStateBin
function void ioaiu_coverage::collect_ccr_state(int core_id);

    case(core_id)
    <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
    <%=i%>: begin
            <%for (var j=0; j< obj.nDCEs; j++){
               var print = false;
               if (obj.nNativeInterfacePorts > 1 && obj.nDCEs > 1) {
                 if (mapping[j].includes(i)) {
                   print = true
                 }
               } else print = true;
               if (print) {%>
                //uvm_config_db#(int)::get(null,"*","check_dce<%=j%>_crd_state_<%=i%>",DCE_CCR<%=j%>_state);
            DCE_CCR<%=j%>_state = u_csr_probe_if[<%=i%>].XAIUCCR<%=j%>_DCECounterState_<%=i%>;
            <%}%>
            <%}%>
            <%for (var j=0; j< obj.nDMIs; j++){%>
                //uvm_config_db#(int)::get(null,"*","check_dmi<%=j%>_crd_state_<%=i%>",DMI_CCR<%=j%>_state);
            DMI_CCR<%=j%>_state = u_csr_probe_if[<%=i%>].XAIUCCR<%=j%>_DMICounterState_<%=i%>;
            <%}%>
            <%for (var j=0; j< obj.nDIIs; j++){
              if(obj.DiiInfo[j].strRtlNamePrefix != "sys_dii") { %>
                //uvm_config_db#(int)::get(null,"*","check_dii<%=j%>_crd_state_<%=i%>",DII_CCR<%=j%>_state);
            DII_CCR<%=j%>_state = u_csr_probe_if[<%=i%>].XAIUCCR<%=j%>_DIICounterState_<%=i%>;
            <%}
            }%>
                io_crd_cg_state_<%=i%>.sample();
            end
    <%}%>
    endcase
    
    //case(core_id)
    //<%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
    //    <%=i%>: begin
    //            io_crd_cg_state_<%=i%>.sample();
    //            end
    //<%}%>
    //endcase
endfunction // collect_ccr_state
//#Cover.IOAIU.Starvation.EachCore_EventStatus
//#Cover.IOAIU.Starvation.EachCore_EventStatusCount

<%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>
function void ioaiu_coverage::Starvation_EachCore_EventStatus(int core_id,int starvation_count,bit starv_evt_status);

case(core_id)
<%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>

 <%=i%>:begin
	
	EventStatus=starv_evt_status;
        starv_cnt=starvation_count;
 
 	starvation_eventstatus_<%=i%>.sample();
	
 	end

 <%}%>

 endcase

endfunction:Starvation_EachCore_EventStatus 
<%}%>
<%}%>


// Instantiate the covergroups
function ioaiu_coverage::new();
    <%if (!obj.fnDisableRdInterleave && obj.nNativeInterfacePorts == 1) {%>
        rd_interleave_cg = new();
    <%}%>
    <%for(let port=0; port< obj.nNativeInterfacePorts; port+=1) {%>
	    axi_awaddr_collisions_core<%=port%> 	= new();
        axi_araddr_collisions_core<%=port%> 	= new();   
        axi_awid_collisions_core<%=port%>   	= new();
        axi_arid_collisions_core<%=port%>   	= new();   
        axi_awaraddr_collisions_core<%=port%> = new();   
        axi_aridawid_collisions_core<%=port%> = new();
        axi_data_integrity_check_core<%=port%> = new();
        //Addr CH
        <%if ((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%}else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")|| (obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%> ace_lite_e<%}%>_rd_addr_chnl_core<%=port%> 		= new();
        <%if ((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%} else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")|| (obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%> ace_lite_e<%}%>_wr_addr_chnl_core<%=port%> 		= new();
        //Resp CH
        <%if ((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%} else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%> ace_lite_e<%}%>_rd_excl_resp_core<%=port%> 		= new();
        <%if ((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%}else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%> ace_lite_e<%}%>_wr_excl_resp_core<%=port%> 		= new();
        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
            ace_rd_addr_chnl_signals_core<%=port%>	= new();
            ace_rd_resp_channel_core<%=port%> 		= new();
            ace_wr_addr_chnl_signals_core<%=port%>	= new();
            ace_wr_resp_channel_core<%=port%> 		= new();
        <%} %>
        <%if(obj.fnNativeInterface == "ACE-LITE") { %>
            ace_lite_rd_addr_chnl_signals_core<%=port%>	= new();
            ace_lite_rd_resp_channel_core<%=port%> 	= new();
            ace_lite_wr_addr_chnl_signals_core<%=port%>	= new();
            ace_lite_wr_resp_channel_core<%=port%> 	= new();
        <%} %>

          wr_data_channel_<%=obj.wData/8%>B_core<%=port%> = new();

        <%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.eAc && ((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")))) { %>
                ace_snoop_address_channel_core<%=port%> = new();
                ace_snoop_response_channel_core<%=port%> = new();
                ace_snoop_response_channel_with_req_core<%=port%> = new();
            <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                ace_snoop_data_core<%=port%> = new();
            <% } %>
        <%}%>
        ioaiu_narrow_transfer_core<%=port%> = new();
        <%if (obj.fnNativeInterface == "ACELITE-E" || obj.useCache) {%>
            ccp_snoop_dtr_req_type_core<%=port%> = new();
        <%}%>
        <%if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.useCache) {%>
            snoop_dtrreq_cmstatus_err_covergroup_core<%=port%> = new();
        <%}%>
        cg_security_feature_core<%=port%> = new();
        <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")){%>
            ccp_coh_noncoh_ops_cg_core<%=port%> = new();
        <%}%>
        <%if (obj.orderedWriteObservation == true) {%>
        <%if((obj.fnNativeInterface == "ACE-LITE") ) { %>
            cg_PCIe_owo_feature<%=port%> = new();
        <%}%>
        <%}%>
        <%if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" ) {%>
            ace_snprsp_core<%=port%> = new();
        <%}%>
        <%if(obj.useCache) {%>
            ccp_state_Nativereq_to_cmdreq_core<%=port%> = new();
            ccp_state_cmdreq_core<%=port%> =new();
            ccp_state_snprsp_core<%=port%> = new();
            ccp_snp_type_state_core<%=port%> = new();
            <%if(obj.fnCacheStates = "MOESI") { %>
                ccp_sd_partial_upgrade_core<%=port%> = new();
            <%}%>
            ccp_snoop_hit_evict_core<%=port%> = new();
            <%switch(obj.nTagBanks) { 
                case 1 : { %>   ccp_ctrl_pkt_bank_1_core<%=port%> = new();   <% break;} 
                case 2 : { %>   ccp_ctrl_pkt_bank_2_core<%=port%> = new();   <% break;} 
                case 4 : { %>   ccp_ctrl_pkt_bank_4_core<%=port%> = new();   <% break;} 
                case 8 : { %>   ccp_ctrl_pkt_bank_8_core<%=port%> = new();   <% break;} 
                case 16 : { %>   ccp_ctrl_pkt_bank_16_core<%=port%> = new();   <% break;} 
                default : { %> `uvm_error("FUNC_CVG", $sformatf("Illegal bank count = %d", <%=obj.nTagBanks%>)) <% break;}
            };%>

            ccp_ctrl_pkt_core<%=port%> = new();
            <%if(obj.nWays < 2 || obj.nWays > 16){%>
                `uvm_error("FUNC_CVG", $sformatf("Illegal way = %d", <%=obj.nWays%>))
            <%}%>

            ccp_fill_ctrl_pkt_misc_core<%=port%> = new();
            ccp_evict_pkt_core<%=port%> = new();
            ccp_control_reg_core<%=port%> = new();
        <%}%>
         <%if(obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5") { %>
             <%var nativeinterface;
                if(obj.fnNativeInterface == "ACELITE-E")
                   nativeinterface = "ACELITE_E";
                else
                   nativeinterface = "AXI5";
            %>
             <%=nativeinterface%>_atm_core<%=port%> = new();
          <%if(obj.fnNativeInterface == "ACELITE-E"){%>
            ace_lite_e_stash_core<%=port%> = new();
            ace_lite_e_deallocating_txns_and_pcmos_core<%=port%> = new();
            ace_lite_e_cover_stashvalid<%=port%> = new();
          <%}%>
        <%}%>
        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
            //shar_prom_owner_txfr_core<%=port%> = new();
        <%}%>
        io_crd_cg_val_<%=port%> = new();
        io_crd_cg_state_<%=port%> = new();
       <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>
        starvation_eventstatus_<%=port%> = new();
       <%}%>
    <%}%>
	
    connectivity                = new();

    <%if (Object.keys(DVM_intf).includes(obj.fnNativeInterface)) {%>
        DVM_master_part1_<%=DVM_intf[obj.fnNativeInterface]%>  = new();
        DVM_master_part2_<%=DVM_intf[obj.fnNativeInterface]%>  = new();
        DVM_snooper_part1_<%=DVM_intf[obj.fnNativeInterface]%> = new();
        DVM_snooper_part2_<%=DVM_intf[obj.fnNativeInterface]%> = new();
    <%}%>


    <%for(let port=0; port< obj.nNativeInterfacePorts; port+=1) {%>
    dec_error_covergroup_core<%=port%>             = new();
    slv_error_covergroup_core<%=port%>             = new();
    illop_to_dii_covergroup_core<%=port%>          = new();
   <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" ) { %>
    crresp_cmstatus_covergroup_core<%=port%>          = new();
   <% } %>    
    uncorrectable_error_covergroup_core<%=port%>    = new();
    dtwrsp_cmstatus_err_covergroup_core<%=port%>   = new();
    dtreq_cmstatus_err_covergroup_core<%=port%>    = new();

    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
    cmprsp_cmstatus_err_covergroup_core<%=port%>   = new();
    snprsp_cmstatus_err_covergroup_core<%=port%>   = new(); 
    <% } %>
    strreq_cmstatus_err_covergroup_core<%=port%>   = new();
             <%if(((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")|| (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.useCache) {%>
    dtwreq_cmstatus_err_covergroup_core<%=port%>   = new();   
    <% } %>
    //u_csr_probe_if[<%=port%>]                      = new();
    <%}%>
    <%if(((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED") || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED")|| (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED"))) {%>
    correctable_error_covergroup_core0     = new();
    <%}%>

    if (!uvm_config_db#(virtual <%=obj.BlockId%>_connectivity_if)::get(null, "", "<%=obj.BlockId%>_connectivity_if", connectivity_if)) begin
        `uvm_fatal("Connectivity interface error", "virtual interface must be set for connectivity_if");
    end
    <%if((obj.useResiliency || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") && ((obj.testBench != "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t")) || obj.testBench =="io_aiu") { %>
        <%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i++){%>
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_probe_if)::get(.cntxt( uvm_root::get() ),
                                            .inst_name( "" ),
                                            .field_name( "u_csr_probe_if<%=i%>" ),
                                            .value( u_csr_probe_if[<%=i%>] )))begin
                                                `uvm_fatal("CSR Probe Interface error", "virtual interface must be set for u_csr_probe_if<%=i%>");
                                            end
        <%}%>
    <%}%>
    
	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache == 1)){%>
		sys_req_events_cg = new();
	<%}%>
	

	smi_pkt = new();
	smi_StrReq_pkt = new();
	<%if(obj.nSttCtrlEntries > 0) { %>
    	smi_snoop_pkt = new();
	<%}%>

        <%if((obj.testBench =="io_aiu") && (obj.useResiliency)){%> 
        mission_fault_causes_cg = new();
        <%}%>

  	<%if(aiu_axiInt.params.eTrace > 0) { %>
	trace_cap_cg=new();
        <%}%>
        <%if(obj.useCache){%>
        mntop_cg = new(); 
         <%}%>
	parity_error_covergroup = new();
endfunction  : new

//#Cover.IOAIU.v3.4.Connectivity.UnconnectedDCEbin
//#Cover.IOAIU.v3.4.Connectivity.UnconnectedDMIbin
//#Cover.IOAIU.v3.4.Connectivity.UnconnectedDIIbin
task ioaiu_coverage::collect_connectivity ();
forever @(connectivity_if.ott_busy == 1)
begin
  AiuDce_connectivity_vec = connectivity_if.AiuDce_connectivity_vec;
  AiuDmi_connectivity_vec = connectivity_if.AiuDmi_connectivity_vec;
  AiuDii_connectivity_vec = connectivity_if.AiuDii_connectivity_vec;
  connectivity.sample();
end
endtask //collect_connectivity

<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"||obj.fnNativeInterface == "ACE-LITE" ||obj.fnNativeInterface == "ACELITE-E"||obj.fnNativeInterface == "AXI4"||obj.fnNativeInterface == "AXI5") { %>
    function void ioaiu_coverage::collect_axi_rresp(ace_read_data_pkt_t txn, ace_read_addr_pkt_t addr_txn, int core_id);
        rresp = txn.rresp;
        rdata = txn.rdata;
        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.fnNativeInterface == "ACE-LITE") { %>
        rsp_ardomain = addr_txn.ardomain;
        rsp_arsnoop = addr_txn.arsnoop;
        <%} %>
        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                        ace_rd_resp_channel_core<%=i%>.sample();
                    end
                <%}%>
            endcase
        <%} %>
        <%if(obj.fnNativeInterface == "ACE-LITE") { %>
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                        ace_lite_rd_resp_channel_core<%=i%>.sample();
                    end
                <%}%>
            endcase
        <%} %>
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
                    <%if ((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%}else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%>ace_lite_e<%} %>_rd_excl_resp_core<%=i%>.sample();
                end
            <%}%>
        endcase    
    endfunction: collect_axi_rresp

    function void ioaiu_coverage::collect_axi_bresp(ace_write_resp_pkt_t txn, ace_write_addr_pkt_t addr_txn, int core_id);
        
        bresp = txn.bresp;
        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.fnNativeInterface == "ACE-LITE") { %>
        rsp_awdomain = addr_txn.awdomain;
        rsp_awsnoop = addr_txn.awsnoop;
        <%}%>

        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                        ace_wr_resp_channel_core<%=i%>.sample();
                    end
                <%}%>
            endcase
        <%}%>
        <%if(obj.fnNativeInterface == "ACE-LITE") { %>
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                        ace_lite_wr_resp_channel_core<%=i%>.sample();
                    end
                <%}%>
            endcase
        <%} %>
        case(core_id)
            <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                <%=i%>: begin
                    <%if ((obj.fnNativeInterface == "AXI4")) {%>axi4<%} else if ((obj.fnNativeInterface == "AXI5")) {%>axi5<%} else if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) {%>ace<%} else if((obj.fnNativeInterface == "ACE-LITE")) {%>ace_lite<%} else if((obj.fnNativeInterface == "ACELITE-E")) {%>ace_lite_e<%} %>_wr_excl_resp_core<%=i%>.sample();
                end
            <%}%>
        endcase    
    endfunction: collect_axi_bresp
<%}%>
<%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.useCache)) { %>
    function void ioaiu_coverage::collect_shar_prom_ownr_txfr(ioaiu_scb_txn txn, int core_id);
        if (txn.m_snp_req_pkt != null) begin
            if (txn.m_dtr_req_pkt == null) begin
                smi_seq_item dummy_dtr_req_pkt = new();
                dummy_dtr_req_pkt.smi_msg_type = 0;
                txn.m_dtr_req_pkt = dummy_dtr_req_pkt;
            end
            if (txn.m_dtw_req_pkt == null) begin
                smi_seq_item dummy_dtw_req_pkt = new();
                dummy_dtw_req_pkt.smi_msg_type = 0;
                txn.m_dtw_req_pkt = dummy_dtw_req_pkt;
            end
            smi_snp_type = txn.m_snp_req_pkt.smi_msg_type;
            smi_dtr_type = txn.m_dtr_req_pkt.smi_msg_type;
            smi_dtw_type = txn.m_dtw_req_pkt.smi_msg_type;

            up     = txn.m_snp_req_pkt.smi_ndp[SNP_REQ_UP_MSB:SNP_REQ_UP_LSB];
            match = (txn.m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>)?1:0;

            dt[0]  = txn.m_snp_rsp_pkt.smi_cmstatus[SMICMSTATUSSNPRSPDTDMI];
            dt[1]  = txn.m_snp_rsp_pkt.smi_cmstatus[SMICMSTATUSSNPRSPDTAIU];
            dc     = txn.m_snp_rsp_pkt.smi_cmstatus[SMICMSTATUSSNPRSPDC];
            rs     = txn.m_snp_rsp_pkt.smi_cmstatus[SMICMSTATUSSNPRSPRS];
            rv     = txn.m_snp_rsp_pkt.smi_cmstatus[SMICMSTATUSSNPRSPRV];
<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
            ace_crresp     = txn.m_ace_snoop_resp_pkt.crresp;
<%}%>
            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                       //shar_prom_owner_txfr_core<%=i%>.sample();
                    end
                <%}%>
            endcase
            `uvm_info("get_name()",$sformatf("shar_prom_owner_txfr.sample() up=%b mpf3_match=%b rv=%b rs=%b dc=%b dt=%b ",up, match, rv, rs, dc, dt),UVM_DEBUG)
        end
    endfunction : collect_shar_prom_ownr_txfr
<%}%>
//#Cover.IOAIU.LookupEn_AllocEn_UpdateDis
   function void ioaiu_coverage::collect_ccp_control_reg(bit LookupEn ,bit AllocEn,bit disable_upd,int core_id);
   //add variable 
<%if(obj.useCache) { %>
    ccp_LookupEn = LookupEn;
    ccp_AllocEn = AllocEn;
    ccp_disableupd = disable_upd;

            case(core_id)
                <%for(let i=0; i< obj.nNativeInterfacePorts; i+= 1){%>
                    <%=i%>: begin
                       ccp_control_reg_core<%=i%>.sample();
                    end
                <%}%>
            endcase
<%}%>
   endfunction
 <%if((obj.testBench =="io_aiu") && (obj.useResiliency)){%>
   function void ioaiu_coverage::collect_mission_fault_causes(bit fault_mission_fault, bit transport_det_en, bit time_out_det_en, bit prot_err_det_en,bit mem_err_det_en);
 
     mission_fault  = fault_mission_fault; 
     trans_det_en   = transport_det_en;
     time_out_deten = time_out_det_en;
     proterr_det_en = prot_err_det_en;
     mem_det_en     = mem_err_det_en; 

     if ($test$plusargs("wrong_cmdrsp_target_id"))
       mission_fault_with_err = CMDrsp_wrong_tgt_id;
     else if ($test$plusargs("wrong_dtrreq_target_id"))
       mission_fault_with_err = DTRreq_wrong_tgt_id;
     else if ($test$plusargs("wrong_dtrrsp_target_id"))
       mission_fault_with_err = DTRrsp_wrong_tgt_id;
     else if ($test$plusargs("wrong_dtwrsp_target_id"))
       mission_fault_with_err = DTWrsp_wrong_tgt_id;
     else if ($test$plusargs("wrong_snpreq_target_id"))
       mission_fault_with_err = SNPreq_wrong_tgt_id;
     else if ($test$plusargs("wrong_updrsp_target_id"))
       mission_fault_with_err = UPDrsp_wrong_tgt_id;
     else if ($test$plusargs("wrong_sysreq_target_id"))
       mission_fault_with_err = SYSreq_wrong_tgt_id;
     else if ($test$plusargs("wrong_sysrsp_target_id"))
       mission_fault_with_err = SYSrsp_wrong_tgt_id;
     else if ($test$plusargs("dvm_time_out_test"))
            mission_fault_with_err = dvm_time_out;  
     else if ($test$plusargs("STRreq_time_out_test"))
            mission_fault_with_err = STRreq_time_out;  
     else if ($test$plusargs("CCP_eviction_time_out_test"))
            mission_fault_with_err = CCP_eviction_time_out;  
     else if ($test$plusargs("CMDrsp_time_out_test"))
            mission_fault_with_err = CMDrsp_time_out;  
     else if ($test$plusargs("enable_ev_timeout"))
            mission_fault_with_err = sys_event_timeout;
     else if ($test$plusargs("timeout_attach_sys_rsp_error") || $test$plusargs("timeout_detach_sys_rsp_error"))
            mission_fault_with_err = sys_req_timeout;
     else if ($test$plusargs("enable_attach_error") || $test$plusargs("enable_detach_error"))  
            mission_fault_with_err = sysevent_error;
     else if($test$plusargs("address_error_test_tag") ||  $test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test")) 
            mission_fault_with_err = tag_err;
     else if(($test$plusargs("address_error_test_data") ||$test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test")))
            mission_fault_with_err = data_err;
     else if($test$plusargs("address_error_test_ott") || $test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test"))
            mission_fault_with_err = ott_err;

          
     mission_fault_causes_cg.sample(); 

   endfunction :collect_mission_fault_causes


 <%}%>

 <%if(aiu_axiInt.params.eTrace > 0) { %>
   function void ioaiu_coverage::collect_trace_cap (ioaiu_scb_txn txn);

     if(txn.m_ace_read_addr_pkt != null) 
     artrace = txn.m_ace_read_addr_pkt.artrace;
     
     if(txn.m_ace_read_data_pkt != null) 
     rtrace = txn.m_ace_read_data_pkt.rtrace; 

     if(txn.m_ace_write_data_pkt != null)
     wtrace = txn.m_ace_write_data_pkt.wtrace ;
	
     if(txn.m_ace_write_addr_pkt != null)
     awtrace = txn.m_ace_write_addr_pkt.awtrace;
	
     if(txn.m_ace_write_resp_pkt != null)
     btrace = txn.m_ace_write_resp_pkt.btrace;
		
     if(txn.m_cmd_req_pkt != null)
     smi_tm = txn.m_cmd_req_pkt.smi_tm;
	 
     trace_cap_cg.sample();

   endfunction :collect_trace_cap
 <%}%>






