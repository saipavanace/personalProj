<% var aiu_axiInt;

if(obj.interfaces.axiInt.length > 1) {
   aiu_axiInt = obj.interfaces.axiInt[0];
} else {
   aiu_axiInt = obj.interfaces.axiInt;
}
%>
<%function generateRegPath(regName) {
    if(obj.nNativeInterfacePorts > 1) {
        return 'm_regs.'+obj.strRtlNamePrefix+'_0.'+regName;
    } else {
        return 'm_regs.'+obj.strRtlNamePrefix+'.'+regName;
    }
}%>

`undef LABEL
`undef LABEL_ERROR
`define LABEL $sformatf("IOAIU%0d SCB",m_req_aiu_id)
`define LABEL_ERROR $sformatf("IOAIU%0d SCB ERROR",m_req_aiu_id)
typedef bit[<%=obj.wData%>-1:0]   ncbu_scb_data_size_t;
typedef smi_dp_dwid_t dp_dwid_t[];
typedef enum bit [2:0] {MNTOP_FLUSH_ALL, MNTOP_FLUSH_BY_INDEX, MNTOP_FLUSH_BY_ADDR, MNTOP_FLUSH_BY_ADDR_RANGE,MNTOP_FLUSH_BY_INDEX_RANGE,MNTOP_DEBUG_READ, MNTOP_DEBUG_WRITE} mntop_cmd_t;
//-----------------------------------------------------------------------
// IOAIU Scoreboard Transaction Class
//-----------------------------------------------------------------------

<%
    var aiuid, sfid, sftype, sftftype;
    var wrevict = 0;
    var wData = 0;
    if(obj.Id < obj.AiuInfo.length){
        aiuid  = obj.Id;
        var ifType = obj.AiuInfo[aiuid].fnNativeInterface;
        if (((ifType === "ACE-LITE") || (ifType === "AXI4") || (ifType === "AXI5") || (ifType === "ACELITE-E") || (ifType === "ACE") || (ifType === "ACE5")) && !obj.useCache) {
            sftype   = "UNDEFINED";
            sftftype = "UNDEFINED";
            wrevict  = 0;
        }else{
            sfid     = obj.sfid;
            sftype   = obj.sftype;
            if(sftype != "NULL"){
                sftftype = obj.SnoopFilterInfo[sfid].fnFilterType;
            }
           wrevict  = obj.useWriteEvict;
        }		    
    }else{
        aiuid  = obj.Id - obj.AiuInfo.length;
        if (obj.BridgeAiuInfo[aiuid].fnNativeInterface === "ACE-LITE" && !obj.BridgeAiuInfo[aiuid].NativeInfo.useCache) {
            sftype   = "UNDEFINED";
            sftftype = "UNDEFINED";
        } else {
            sfid     = obj.sfid;
            sftype   = obj.SnoopFilterInfo[sfid].fnFilterType;
            if(sftype != "NULL"){
                sftftype = obj.SnoopFilterInfo[sfid].fnFilterType;
            }
        }
        wrevict = "0";	  	
    }
    function getBaseLog(x, y) {
        return Math.log(y) / Math.log(x);
    }

   if (obj.AiuInfo[obj.Id].wData == 512) {
       wData = 256;
       } else {
           wData =  obj.AiuInfo[obj.Id].wData;
           }
   var IntfSize = (getBaseLog(2, (wData/64)));
   obj.intfDWs = wData/64;
   var wRotateIndx = obj.wCacheLineOffset- 3;
%> 
 
/* 
 Author : David Clarino
 Date   : 1/24/2018
*/
import <%=obj.BlockId%>_axi_agent_pkg::*;
import <%=obj.BlockId%>_smi_agent_pkg::*;
import <%=obj.BlockId%>_event_agent_pkg::*;

//strictRespMode: no AxID dependency & only addr dependency
typedef enum bit[1:0]  {Rsvd_0, Rsvd_1, pcieOrderMode, strictReqMode} TransOrderMode_e;

typedef enum {INACTIVE, ALLOCATED, DEALLOCATED} ott_status_e;

typedef enum {UCE, UDP, INV} owo_wr_state_e;

bit [<%=smiObj.WSMINCOREUNITID%>-1:0] dce_funit_id [<%=obj.AiuInfo[obj.Id].nAiuConnectedDces%>-1:0];

typedef struct packed {
    bit[1:0]    policy;
    bit         writeID;
    bit         readID;
} gpra_order_t;

class ioaiu_scb_txn;
    // Unique ID per txn to track them in log
    bit owo = <%if (obj.orderedWriteObservation == true) {%> 1 <%} else {%> 0 <%}%>;
    bit owo_512b = <%if ((obj.orderedWriteObservation == true) && (obj.AiuInfo[obj.Id].wData == 512)) {%> 1 <%} else {%> 0 <%}%>;
    int tb_txnid;
    int core_id;
    int dest_id;
    smi_msg_id_bit_t exp_smi_msg_id;
    static bit[3:0] mismatch_mem_attr[axi_axaddr_t];
    bit mismatch_mem_attr_flag; 
    static int rresp_mismatch_count; 
    // Native agent channel packets
    ace_read_addr_pkt_t                                 m_ace_read_addr_pkt;
    ace_read_addr_pkt_t                                 m_owo_native_rd_addr_pkt; //only possible for 512b OWO
    ace_read_addr_pkt_t                                 m_ace_read_addr_pkt2;
    ace_write_addr_pkt_t                                m_ace_write_addr_pkt;
    ace_write_addr_pkt_t                                m_owo_native_wr_addr_pkt; //only possible for 512b OWO
    ace_read_data_pkt_t                                 m_ace_read_data_pkt;
    ace_read_data_pkt_t                                 m_ace_read_data_pkt2;
    ace_write_data_pkt_t                                m_ace_write_data_pkt;
    ace_write_data_pkt_t                                m_owo_native_wr_data_pkt; //only possible for 512b OWO
    ace_write_resp_pkt_t                                m_ace_write_resp_pkt;
    ace_snoop_addr_pkt_t                                m_ace_snoop_addr_pkt;
    ace_snoop_resp_pkt_t                                m_ace_snoop_resp_pkt;
    ace_snoop_data_pkt_t                                m_ace_snoop_data_pkt;
       
    static int                                          upd_req_counter;

    // SMI agent member messages
    smi_seq_item                                        m_sys_req_pktq[$];
    smi_seq_item                                        m_sys_rsp_pktq[$];
    smi_seq_item                                        m_cmd_req_pkt;
    smi_seq_item                                        m_2nd_cmd_req_pkt;
    smi_seq_item                                        m_cmp_rsp_pkt;
    smi_seq_item                                        m_cmd_rsp_pkt;
    smi_seq_item                                        m_2nd_cmd_rsp_pkt;
    smi_seq_item                                        m_str_req_pkt;
    smi_seq_item                                        m_2nd_str_req_pkt;
    smi_seq_item                                        m_str_rsp_pkt;
    smi_seq_item                                        m_2nd_str_rsp_pkt;
    smi_seq_item                                        m_dtr_req_pkt;
    smi_seq_item                                        m_dtr_req_for_dtw_hndbk_pkt;
    smi_seq_item                                        m_dtr_rsp_pkt;
    smi_seq_item                                        m_dtw_req_pkt;
    smi_seq_item                                        m_dtw_rsp_pkt;
    smi_seq_item                                        m_snp_req_pkt;
    smi_seq_item                                        m_snp_rsp_pkt;
    smi_seq_item                                        m_upd_req_pkt;
    smi_seq_item                                        m_upd_rsp_pkt;
    
    // SMI agent expected messages
    smi_seq_item                                        exp_sys_req_pktq[$];
    smi_seq_item                                        exp_SysReq_evt_pktq[$];
    smi_seq_item                                        exp_sys_rsp_pktq[$];
    smi_seq_item                                        exp_cmd_req_pkt;
    smi_seq_item                                        exp_2nd_cmd_req_pkt;
    smi_seq_item                                        exp_cmp_rsp_pkt;
    smi_seq_item                                        exp_cmd_rsp_pkt;
    smi_seq_item                                        exp_2nd_cmd_rsp_pkt;
    smi_seq_item                                        exp_str_req_pkt;
    smi_seq_item                                        exp_2nd_str_req_pkt;
    smi_seq_item                                        exp_str_rsp_pkt;
    smi_seq_item                                        exp_2nd_str_rsp_pkt;
    smi_seq_item                                        exp_dtr_req_pkt;
    smi_seq_item                                        exp_dtr_req_for_dtw_hndbk_pkt;
    smi_seq_item                                        exp_dtr_rsp_pkt;
    smi_seq_item                                        exp_dtw_req_pkt;
    smi_seq_item                                        exp_dtw_rsp_pkt;
    smi_seq_item                                        exp_snp_req_pkt;
    smi_seq_item                                        exp_snp_rsp_pkt;
    smi_seq_item                                        exp_upd_req_pkt;
    smi_seq_item                                        exp_upd_rsp_pkt;// ??
    smi_seq_item                                        exp_sender_sys_req_pkt;
    smi_seq_item                                        exp_reciever_sys_req_pkt;
    smi_seq_item                                        exp_reciever_sys_rsp_pkt;
    smi_seq_item                                        exp_sender_sys_rsp_pkt;
    event_pkt                                           evt_req_pkt;
    event_pkt                                           evt_ack_pkt;
    event_pkt                                           evt_req_rcv;
    event_pkt                                           evt_ack_rcv;

    // Enum because ACE/ACE-LITE command types are based on a combination of axsnoop, axdomain and axbar
    ace_command_types_enum_t m_ace_cmd_type;

    parameter CACHELINE_SIZE    = ((SYS_nSysCacheline*8)/wSmiDPdata);
    parameter DATA_WIDTH        = <%=obj.wData%>;
    parameter LINE_INDEX_LOW  = $clog2(DATA_WIDTH/8);   
    parameter LOGWDATA = $clog2(DATA_WIDTH/8);
    parameter NUM_BEATS_CACHELINE = <%=((Math.pow(2,obj.wCacheLineOffset) * 8) / obj.wData)%>;

    parameter LINE_INDEX_HIGH = LINE_INDEX_LOW + $clog2(CACHELINE_SIZE) - 1;
    <%if(obj.testBench == "fsys"|| obj.testBench == "emu") { %>
        concerto_register_map_pkg::ral_sys_ncore m_regs;
    <%}else{%>
        ral_sys_ncore m_regs;
    <%}%>   

    bit pcieOrderMode_en = <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%> 0; <%}else{%> 1; <%}%>   
    TransOrderMode_e transOrderMode;
    TransOrderMode_e transOrderMode_rd, transOrderMode_wr;
    ott_status_e     m_ott_status;
    owo_wr_state_e   m_owo_wr_state;
    int 	     m_ott_id;
    gpra_order_t     gpra_order;//BING: FIXME! need to get the correct value based on the addr
    trace_trigger_utils m_trace_trigger;
    addr_trans_mgr   m_addr_mgr;
    TRIG_TCTRLR_t    tctrlr[<%=obj.nTraceRegisters%>];
    TRIG_TBALR_t     tbalr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    TRIG_TBAHR_t     tbahr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    TRIG_TOPCR0_t    topcr0[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    TRIG_TOPCR1_t    topcr1[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    TRIG_TUBR_t      tubr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    TRIG_TUBMR_t     tubmr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    // Transaction type;
    bit isRead;
    bit isWrite;
    bit isUpdate;
    bit isSnoop;
    bit isMntOp;
    bit isDVM;
    bit isDVMSnoop;

    bit isAtomic;
    bit isCoherentAtomic;
    bit isStash;
    bit isSysCoAttachSeq;
    bit isSysCoAttachErr;
    bit isSysCoDetachSeq;

    // Partial write/read indicator
    bit isPartialWrite = 0;
    bit isPartialRead = 0;

    int ioaiu_cctrlr_phase = 0;   // Use by CONC-8404

    // Bit to read json file to indicate if this IO AIU (when it has a proxy cache) is in a PV CV (no need to send UPDREQ if this is true)
    bit is_pv_coarse_vec;
    string temp_sftf_type;
    int sf_vec[$][$];

    //awlen, arlen used in ioaiu_coverage for coverage collection 
    int awlen;                   
    int arlen;                   
    // To let IO$ know what type of packet this is
    string addr_collison;
    // Multiline status bits
    bit                  isMultiLineMaster;
    bit                  isMultiAccess;
    int                  total_cacheline_count;
    int                  multiline_order;
    bit                  multiline_ready_to_delete;
    ace_read_addr_pkt_t  m_multiline_starting_read_addr_pkt;
    ace_write_addr_pkt_t m_multiline_starting_write_addr_pkt;
    ace_write_data_pkt_t m_multiline_starting_write_data_pkt;
    int                  m_multiline_tracking_id;

    // IO cache status bits
    bit                                   isIoCacheEvict;
     
    // IO cache enable & able to allocate 
    bit csr_ccp_lookupen; // enalbe proxy cache
    bit csr_ccp_allocen; // able to allocate a cacheline
    bit csr_ccp_updatedis; // disable UPDreq on proxyCache evictions

    bit csr_use_eviction_qos = 0; //reset value
    int csr_eviction_qos = 'hf; //reset value

    // Error indicators
    bit                                   hasFatlErr;
    bit                                   isSMICMDRespErr;
    bit                                   isSMISTRReqAddrErr;
    bit                                   isSMISTRReqDataErr;
    bit                                   isSMISTRReqTransportErr;
    bit                                   isSMIDTWrspErr;
    bit                                   isSMIDTRReqErr;
    int                                     mntop_index;
    int                                     mntop_way;
    int                                     mntop_word;
    int                                     mntop_Dataword;
    axi_axaddr_t mntop_addr; 
    bit                                     mntop_security;
    bit                                     mntop_ArrayId;// 0: TagArray, 1: DataArray
    mntop_cmd_t                             m_mntop_cmd_type;
    bit[14:0]                               opcode_for_evict;
        
    <%if((obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5") || ((obj.fnNativeInterface === "ACELITE-E") && (obj.eAc == 1) && !obj.interfaces.eventRequestInInt._SKIP_)) { %>
    bit sysEventSender = 1;
    <%}else{%>
    bit sysEventSender = 0;
    <%}%>   
    <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.eAc == 1)) || (obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5")){ %>
    bit sysCohSender = 1;
    <%}else{%>
    bit sysCohSender = 0;
    <%}%>   

    <%if(obj.useCache){%> 
        bit                                   m_iocache_allocate;    
        bit                                   isIoCacheTagPipelineSeen;
        bit                                   isIoCacheTagPipelineNeeded;
        bit                                   isIoCacheDataPipelineSeen;
        bit                                   isIoCacheEvictNeeded;
        bit                                   isWriteBackNotNeeded;
        bit                                   isIoCacheEvictDataRcvd;
        bit                                   isCCPReadHitDataNeeded;
        bit                                   isCCPReadHitDataRcvd;
        bit                                   isCCPWriteHitDataRcvd;
        bit                                   isCCPFillCtrlSeen;
        bit                                   isCCPFillDataSeen;
        bit                                   isCCPCancelSeen;
        bit                                   isCCPCancelExpected;
        bit                                   isCCPCancelB2B;
        ncbu_scb_data_size_t                  m_io_cache_data[];
        ncbu_scb_data_size_t                  m_ccp_exp_data[];
        ccpCacheLine                          m_ccp_cacheline;
        bit                                   m_io_cache_dat_err[];
        bit                                   m_io_cache_only_data_err_found;
        // I dont believe AIU can receive the packet below
        bit                                   is_ccp_hit;
        bit                                   is_write_hit_upgrade;
        bit                                   is_write_hit_upgrade_with_fetch;    //DCTODO CLNUPCHK
        bit                                   is_write_hit_upgrade_with_merge;    //DCTODO CLNUPCHK

        bit                                     isSnpHitEvict;
        bit                                     isFakeHit;

        bit                                     hasTagUpdate = 0;
        smi_msg_user_logic_t                    dvm_msg_ids[smi_msg_user_logic_t];
        ace_command_types_enum_t m_ace_cmd_type_io_cache;

        // CCP packets
        ccp_wr_data_pkt_t   m_ccp_wr_data_pkt;
        ccp_ctrl_pkt_t      m_ccp_ctrl_pkt;
        ccp_fillctrl_pkt_t  m_ccp_fillctrl_pkt_t;
        ccp_filldata_pkt_t  m_ccp_filldata_pkt;
        ccp_rd_rsp_pkt_t    m_ccp_rd_rsp_pkt;
        ccp_evict_pkt_t     m_ccp_evict_pkt;
        int                 ccp_index;
        int                 ccp_way;
        axi_axaddr_t ccp_addr;
	ccp_cachestate_enum_t CCPcurrentstate;
	ccp_cachestate_enum_t CCPnextstate;
	ccp_cachestate_enum_t ccp_state_on_DTRreq;
    <%}%>

    // If we hit an address dependancy, then this bit is set to indicate that this transaction is sleeping 
    bit isAddrBlocked;
    bit isSleeping;
    bit wasSleeping;

    // Is fill required
    bit dropDtrData = 0;
    bit isFillCtrlRcvd;
    bit isFillDataRcvd;
    bit isFillDataReqd;
    bit isFillReqd;
    bit isFillDoneEarlyRcvd;

    // If we hit an axid dependancy, then this bit is set to indicate that this transaction is sleeping 
    bit isAceCmdReqBlocked;
    bit wasAceCmdReqBlocked;

    // Other AIU information
    smi_src_id_logic_t      m_req_aiu_id;
    smi_src_id_logic_t   home_dce_unit_id; 
    smi_src_id_logic_t   home_dmi_unit_id; 

    // Address related. Might change
    int                                     memRegion;
    int                                     memRegionPrefix;

    // If a request's address is not in a legally defined memory region, then this bit is set
    bit                                     addrNotInMemRegion;
    bit                                     illegalNSAccess; //this bit is set if txn NS=1 and hits a region with NSX=0. Does not apply to DVM ops
    bit                                     illDIIAccess; 
    bit                                     addrInCSRRegion;
    bit                                     isSelfIDRegAccess;
    bit                                     mem_regions_overlap;
    bit                                     dtrreq_cmstatus_err;
    bit			                    dtrreq_cmstatus_add_err;
    bit                                     dtwrsp_cmstatus_add_err;
    bit                                     dtwrsp_cmstatus_slv_err;
    bit                                     dtwrsp_cmstatus_err;
    bit                                     predict_ott_data_error;
    bit                                     tagged_decerr; //CONC-12072 set this bit when one of the multiline_order is decerr
    bit					    data_check_needed;
    bit					    check_rresp_on_dtrreq;
    bit                                     dtrreq_cmstatus_err_expcted;
    bit                                     ignore_poisoned;
    bit [WXDATA -1:0]                   error_data_q[$];
    bit					    illegalCSRAccess;
    <%if(obj.testBench == "fsys") { %>
    static bit k_decode_err_illegal_acc_format_test_unsupported_size;
    <%}%>   

    // SFI address
    smi_addr_t m_sfi_addr; 
    int          m_id;
    bit m_security;
    axi_axqos_t  m_axi_qos;
    axi_axcache_t m_axcache;
    int         m_user;
    // Errors
    bit[1:0]                                     m_axi_resp_expected[];
    bit                                          m_smi_data_be[];
    bit                                          m_snp_addr_err_expected;
    bit no_pending_cmd_req; //to check if any pending CMD req for the same AXID. CONC-5371
    int nSMISysReqExpd;
    int nSMISysReqSent;
    int nSMISysRspRcvd;
    int isSenderEventReq;
    int isSenderSysReqNeeded;
    int isSenderSysReqSent;
    int isSenderEventAckNeeded;
    int isSenderEventAckRcvd;
    int isSenderSysRspRcvd;
    int isRecieverSysReqRcvd;
    int isRecieverEventReqNeeded;
    int isRecieverEventReqSent;
    int isRecieverEventAckNeeded;
    int isRecieverEventAckSent;
    int isRecieverSysRspNeeded;
    int isRecieverSysRspSent;
    axi_xdata_t                      wr_ccp_data[];


    //----------------------------------------------------------------------- 
    // Status bits of the transaction
    //----------------------------------------------------------------------- 

    //SMI
    // *Needed = This message type needs to be seen for this scb txn. This is set up earlier in the state machine when you can predict that this type of message will be seen
    // *Sent = Message seen in TX direction
    // *Recd = Message seen in RX direction
    // *AllDTR = When multiple DTRReq as expected to be received. We never expect multiple in Ncore 3.0
    // *DataDropped = When Snoop data is received but it is not forwarded by the AIU. Not relevant to IO AIU
    bit isSMICMDReqNeeded;
    bit isSMICMDReqSent;
    bit isSMICMDRespRecd;
    bit isSMICMPRespRecd;
    bit is2ndSMICMDReqNeeded;
    bit is2ndSMICMDReqSent;
    bit is2ndSMICMDRespRecd;
    bit isSMISTRReqNotNeeded; // For error cases
    bit isSMISTRReqRecd;
    bit isSMISTRRespSent;
    bit is2ndSMISTRReqNeeded;
    bit is2ndSMISTRReqRecd;
    bit is2ndSMISTRRespSent;
    bit isSMIDTRReqRecd;
    bit isSMIDTRRespSent;
    bit isSMIDTRReqNeeded;
    bit isSMIAllDTRReqRecd;
    bit isSMIAllDTRRespSent;
    bit isSMIDTWReqSent;
    bit isSMIDTWRespRecd;
    bit isSMIDTWReqNeeded;
    bit isSMISNPReqRecd;
    bit isSMISNPRespNeeded;
    bit isSMISNPRespSent;
    bit isSMISNPDTRReqSent;
    bit isSMISNPDTRRespRecd;
    bit isSMISNPDTRReqNeeded;
    bit isSMISNPDataDropped;
    bit isSMIUPDReqSent;
    bit isSMIUPDRespRecd;
    bit isSMIUPDReqNeeded;
    bit isSMIDTRReqDty = 0;
    bit isSMIDTRReqDtrDatVisErr = 0;

    //ACE
    // NoRack v/s Rack: IO AIU will never see a RACK/WACK and so can be removed 
    bit isACEReadAddressRecd;
    bit isACEReadAddressDVMRecd;
    bit isACEReadAddressDVMNeeded;
    bit isACEWriteAddressRecd;
    bit isACEReadDataNeeded;
    bit isACEReadDataSent;
    bit isACERlastRecd;
    bit isACEReadDataSentNoRack;
    bit isACEReadData0SentNoRack;
    bit isACEWriteDataRecd;
    bit isACEWriteDataNeeded;
    bit isACEWriteRespSent;
    bit isACEWriteRespSentNoWack;
    bit isACESnoopReqSent;
    bit isACESnoopRespRecd;
    bit isACESnoopDataNeeded;
    bit isACESnoopDataRecd;

    bit[3:0] WU_DT_PD_IS;
    // DVM will be supported only in the snoop direction for an ACE-LITE. Some signals below are not required
    bit isACEReadDataDVMMultiPartSent;
    bit isACEReadDataDVMMultiPartSentNoRack;
    bit isACESnoopReqDVMMultiPartFirstPartSent;
    bit isACESnoopRespDVMMultiPartFirstPartRecd;

 
    // For coverage
    bit isSnoopReqAiuIDSameAsThisReqAiuId;
    string orderOfPkts;

    //Bit indicating if its a coherent or non-coherent request
    bit isCoherent;

    //Bit indicating if its a multi-part DVM message
    bit isDVMMultiPart;

    //Bit indicating if its a DVM Sync message
    bit isDVMSync;

    bit is_dvm;

    //same address with differ secure bit flag ott str
    bit ott_addr_diffsecurity_bit;
      
    //same address with differ secure bit flag stt str
    bit stt_addr_diffsecurity_bit;
    bit dtr_req_dbad_high;

    //ott entry time stamps
    time t_ott_alloc;
    time t_ott_dealloc;
    longint unsigned ott_alloc_cc;
    // AIU double bit errors enabled
    bit aiu_double_bit_errors_enabled = 0;
    // AIU no detEn
    bit aiu_nodetEn_err_inj = 0;
    //Transaction time stamps
    longint unsigned natv_intf_cc;
    time t_creation;
    time t_latest_update;
    time t_axi4_req_addr_sent;
    time t_axi4_req_resp_recd;
    time t_ace_read_recd;
    time t_ace_read_dvm_multipart_recd;
    time t_ace_read_data_sent;
    time t_ace_read_data_dvm_multipart_sent;
    time t_ace_write_recd;
    time t_ace_write_resp_sent;
    time t_ace_write_data_recd;
    time t_ace_snoop_sent;
    time t_ace_snoop_dvm_first_part_sent;
    time t_ace_snoop_resp_recd;
    time t_ace_snoop_resp_dvm_first_part_recd;
    time t_ace_snoop_data_recd;
    time t_sfi_cmd_req;
    time t_2nd_sfi_cmd_req;
    time t_sfi_cmd_rsp;
    time t_sfi_cmp_rsp;
    time t_2nd_sfi_cmd_rsp;
    time t_sfi_str_req;
    time t_2nd_sfi_str_req;
    time t_sfi_str_rsp;
    time t_2nd_sfi_str_rsp;
    time t_sfi_dtw_req;
    time t_sfi_dtw_rsp;
    time t_sfi_dtr_req;
    time t_sfi_dtr_req_perbeat[];
    time t_sfi_dtr_rsp;
    time t_sfi_snp_req;
    time t_sfi_snp_rsp;
    time t_sfi_upd_req;
    time t_sfi_upd_rsp;
    time t_sfi_evt_req;
    time t_sfi_sys_req_rcv;
    time t_sfi_sys_rsp_rcv;
    time t_sfi_evt_req_rcv;
    time t_sfi_evt_ack_rcv;
    time t_sfi_sys_req;
    time t_sfi_sys_rsp;
    time t_sfi_evt_ack;
    time t_io_cache_pkt;
    time t_io_cache_data_pkt;
    time t_ccp_ctrl_pkt;
    time t_ccp_ctrl_creation;
    time t_ccp_last_lookup;
    time t_ccp_fill_data_pkt;
    time t_ccp_fill_ctrl_pkt;
    time t_ccp_read_rsp_pkt;
    time t_ccp_write_data_pkt;
    time t_ccp_evict_pkt;
    time t_addr_block_start_time;
    time t_addr_block_end_time;
    time t_early_rd_rsp_rcvd;
    time t_early_wr_rsp_rcvd;

    time t_early_str_rsp_rcvd;

    time t_sfi_dtw_req_perbeat[];
    time t_strreq_cmstatus_err;
    time t_dtwrsp_cmstatus_err;

    int dec_err_type;

    //New data types imported from SnpScb for DVM Snoops
    smi_seq_item              smi_act[string];
    smi_seq_item              smi_exp[string];
    time                      smi_act_time[string];
    bit                       smi_flags[string];
    bit                       smi_exp_flags[string];
    string txn_type;

    ace_snoop_addr_pkt_t      m_ace_snoop_addr_pkt0_act;
    ace_snoop_addr_pkt_t      m_ace_snoop_addr_pkt1_act;
    ace_snoop_addr_pkt_t      m_ace_snoop_addr_pkt0_exp;
    ace_snoop_addr_pkt_t      m_ace_snoop_addr_pkt1_exp;
 
    ace_snoop_resp_pkt_t      m_ace_snoop_resp_pkt0_act;
    ace_snoop_resp_pkt_t      m_ace_snoop_resp_pkt1_act;

    // For coverage purposes


    // billc: note that trace_core_id is not currently used and might be removed
    function new(string name = "ioaiu_scb_txn",smi_src_id_logic_t req_aiu_id, bit csr_ccp_lookupen=0, bit csr_ccp_allocen=0, bit csr_ccp_updatedis=0, bit [addrMgrConst::W_SEC_ADDR - 1 : 0] addr = -1, int trace_core_id = 0 );
        this.m_req_aiu_id = req_aiu_id;
       
        temp_sftf_type = "<%=sftftype%>";
        if($test$plusargs("mem_regions_overlap")) begin // For Addr Region Overlap test, where access results in error
            mem_regions_overlap = 1;
        end
        if(($test$plusargs("connectivity_testing") && (addr != -1) && addr_trans_mgr::check_unmapped_add(addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) ) begin // For Addr Region Overlap test, where access results in error
            addrNotInMemRegion = 1;
            mem_regions_overlap = 1;
        end
        if($test$plusargs("no_credit_check")) begin
            addrNotInMemRegion = 1;
            mem_regions_overlap = 1;
        end
        if ($test$plusargs("double_bit_error_test") || $test$plusargs("double_bit_err_task") || $test$plusargs("aiu_noerrdetEn") /* || $test$plusargs("iocache_double_bit_data_error_test")*/) begin
            aiu_double_bit_errors_enabled = 1;
        end
        else begin
            aiu_double_bit_errors_enabled = 0;
        end
        if ($test$plusargs("aiu_noerrdetEn") ) begin
            aiu_nodetEn_err_inj = 1;
        end
        else begin
            aiu_nodetEn_err_inj = 0;
        end
        <%if(obj.useCache){%>
            this.csr_ccp_lookupen=csr_ccp_lookupen;
            this.csr_ccp_allocen =csr_ccp_allocen;
            this.csr_ccp_updatedis =csr_ccp_updatedis;
        <%}%>    

        foreach(tctrlr[idx]) begin
            if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", $sformatf("tctrlr_%0d",idx), tctrlr[idx])) begin
                <%if(aiu_axiInt.params.eTrace > 0){%>
                    tctrlr[idx] = 32'h1;
                <%}else{%>
                    tctrlr[idx] = 32'h0;
                <%}%>
            end
        end
        foreach(tbalr[idx]) begin
            if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", $sformatf("tbalr_%0d",idx), tbalr[idx])) begin
                    tbalr[idx] = 32'h0;
            end
        end
        foreach(tbahr[idx]) begin
            if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", $sformatf("tbahr_%0d",idx), tbahr[idx])) begin
                    tbahr[idx] = 32'h0;
            end
        end
        foreach(topcr0[idx]) begin
            if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", $sformatf("topcr0_%0d",idx), topcr0[idx])) begin
                    topcr0[idx] = 32'h0;
            end
        end
        foreach(topcr1[idx]) begin
            if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", $sformatf("topcr1_%0d",idx), topcr1[idx])) begin
                    topcr1[idx] = 32'h0;
            end
        end
        foreach(tubr[idx]) begin
            if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", $sformatf("tubr_%0d",idx), tubr[idx])) begin
                    tubr[idx] = 32'h0;
            end
        end
        foreach(tubmr[idx]) begin
            if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", $sformatf("tubmr_%0d",idx), tubmr[idx])) begin
                    tubmr[idx] = 32'h0;
            end
        end

        m_addr_mgr = addr_trans_mgr::get_instance();

        //`uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $psprintf("wData:<%=wData%> obj.wData:<%=obj.wData%>") ,UVM_LOW);
    endfunction : new
    extern function void check_snoop_address(int ac_addr, int ac_datawidth);
    extern function bit matchSmi(smi_seq_item m_pkt);
    extern function bit matchNS(smi_seq_item m_pkt);
    extern function bit matchAddr(smi_seq_item m_pkt);
    extern function bit matchAux(smi_seq_item m_pkt);
    extern function bit higherPriorityThan(ioaiu_scb_txn pkt);
    extern function bit matchQos(smi_seq_item pktA);
    extern function bit matchAceLock();
    extern function bit matchHomeDceUnitId(smi_seq_item m_pkt);
    extern function bit matchHomeDmiUnitId(smi_seq_item m_pkt);
    <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
   `ifndef VCS
    extern function bit matchCmdType(eMsgCMD);
   `else // `ifndef VCS
    extern function bit matchCmdType(eMsgCMD cmd_type);
   `endif // `ifndef VCS ... `else ... 
    <% } else {%>
    extern function bit matchCmdType(eMsgCMD);
    <% } %>
    extern function bit matchSnpDtrReq(smi_seq_item m_pkt);
    extern function bit matchNativeTxnTypeToSMICmdType();
    extern function bit matchDtwToTxn(smi_seq_item m_pkt);
    extern function bit matchDtwToCmd(smi_seq_item m_pkt);
    extern function bit matchCmdToTxn(smi_seq_item m_pkt);
    extern function bit match_ReadDataRespToAtomicTxn(ace_read_data_pkt_t m_pkt);
    extern function bit match_ReadDataRespToDvmMsg(ace_read_data_pkt_t m_pkt);
    extern function bit match_ReadDataRespToDvmCmpl(ace_read_data_pkt_t m_pkt);
    extern function bit match_ReadDataRespToErrorScenarios(ace_read_data_pkt_t m_pkt);
    extern function bit match_ReadDataRespToRead(ace_read_data_pkt_t m_pkt);
    extern function smi_dp_data_bit_t getExpDVMDtwData();
    extern function smi_addr_t getExpDVMCmdReqAddr();
    extern function smi_order_t getExpCmdOR();
    extern function smi_tm_t getExpTM(bit is_dvm=0);
    extern function bit matchDtrToTxn(smi_seq_item m_pkt);
    extern function bit matchSnpToDtwTargId(smi_seq_item m_pkt);
    extern function bit matchSysReq(smi_seq_item m_pkt);
    extern function int calcStrResult();
    extern function bit isInAddressSpace(smi_seq_item m_pkt);   
    extern function int mapAddrToTarg(smi_seq_item m_pkt);
    extern function int mapAddrToDestId(smi_seq_item m_pkt);   
    <%if(obj.useCache){%>
        extern function bit noAllocateNotFinished();
        extern function bit allocateNotFinished();
        extern function bit hitNotFinished();
        extern function bit evictNotFinished();
        extern function bit isWriteHit();
        extern function bit predictTagUpdate();
        extern function ccp_ctrl_pkt_t getExpCcpCtrl(ccp_ctrl_pkt_t m_pkt, ccpCacheLine cl);
        extern function void checkExpCcpCtrl(ccp_ctrl_pkt_t m_pkt, ccpCacheLine cl, string s = "");
    <%}%>   
    <%if(obj.useCache || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
        extern function void check_snp_dtr_type(int id);
        extern function void check_snp_dtr_attr(int id);
    <%}%>

    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
    	extern function void check_rresp_for_ace();   
    <%}%>
    extern function void check_dtw_type(output eMsgDTW dtw_type, output eMsgDTWMrgMRD dtw_mrg_mrd_type);
    extern function void check_dtw_fields(input eMsgDTW dtw_type, input eMsgDTWMrgMRD dtw_mrg_mrd_type);
    extern function void check_dtw_num_beats();
    extern function void check_dtw_beats();
    extern function void check_dtw_txn(smi_seq_item m_pkt,string id = "");
    extern function smi_seq_item axiToSmiData();
    extern function bit checkSnpDtrData(string id="");
    extern function bit checkSnpResp(string id = "");
    extern function bit isStrRspEligibleForIssue();
    extern function void check_smi_cmd_attr();
    extern function smi_msg_type_bit_t mapAceSnpToSNPreq (axi_acsnoop_t acsnoop);
    extern function void compare_smi_axi_data();   //SMI packet doesn't come until all the beats are there
    extern function smi_seq_item getExpCmdReq(smi_seq_item m_pkt);
    extern function void getExpCmdRsp();
    extern function void getExpDtrRsp();
    extern function void getExpDtwRsp();
    extern function void getExpStrRsp();
    extern function void getExpSnpRsp(bit [7:0] cmstatus );
    extern function void checkExpSnpRsp(bit [4:0] exp_snp_result);
    extern function void getExpRDataFromDtr();
    extern function int getSmiSize();
    extern function int predict_smi_size(smi_addr_t addr);
    extern function int getTransactionId();
    extern function eMsgCMD getCmdType();
    extern function bit getAceLock();
   extern function dp_dwid_t getExpDWID(axi_axaddr_t addr, int NativeIntfDWs, int axlen=0, int use_wrap_logic=0, int crit_dw_pos = -1);
    function void setup_ace_multi_part_dvm_read_req(ace_read_addr_pkt_t m_pkt);
        isACEReadAddressDVMRecd = 1;
        m_ace_read_addr_pkt2 = m_pkt;
    endfunction : setup_ace_multi_part_dvm_read_req

    function void setup_sys_evt_req(event_pkt evt_pkt);
        t_latest_update   = $time;
        t_sfi_evt_req     = t_latest_update;
       exp_sender_sys_req_pkt = smi_seq_item::type_id::create("exp_sender_sys_req_pkt");
       exp_sender_sys_req_pkt.construct_sysreq(
            .smi_targ_ncore_unit_id (addrMgrConst::funit_ids[addrMgrConst::dve_ids[0]]),
            .smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
            .smi_msg_type           (eSysReq),
            //.smi_msg_id             ((sysCohSender && sysEventSender) ? 'h1 : 'h0),
            .smi_msg_id             ( 'h0),
            .smi_msg_tier           ('h0),
            .smi_steer              ('h0 ),
            .smi_msg_pri            ('h0 ),
            .smi_msg_qos            ('h0 ),
            .smi_tm                 ('h0 ),
            .smi_rmsg_id            ('h0 ),
            .smi_msg_err            ('h0 ),
            .smi_cmstatus           ('h0 ),
            .smi_sysreq_op          (SMI_SYSREQ_EVENT),
            .smi_ndp_aux            ('h0)
		    );
        evt_req_pkt = new();
        evt_req_pkt.copy(evt_pkt);
	isSenderSysReqNeeded = 1;
	isSenderEventReq = 1;
	isSenderSysReqSent = 0;
        isSenderEventAckNeeded=0;
        isSenderEventAckRcvd=0;
        isSenderSysRspRcvd=0;
         //`uvm_info("IOAIU_SCB_Event", $psprintf("Expected SYsreq by IOAIU:%0s", exp_sender_sys_req_pkt.convert2string()) ,UVM_LOW);
    endfunction :setup_sys_evt_req

    function void check_sys_evt_req(smi_seq_item evtreq_item);
        t_latest_update   = $time;
        t_sfi_sys_req     = t_latest_update;
       if (!exp_sender_sys_req_pkt.compare(evtreq_item)) begin 
       `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", "check_sys_evt_req::EvtReq fields mismatching above!");
       end
       isSenderSysReqSent = 1;
    endfunction : check_sys_evt_req

    function void setup_sys_evt_rsp(smi_seq_item m_pkt);
    exp_sender_sys_rsp_pkt = smi_seq_item::type_id::create("exp_sender_sys_rsp_pkt");
    exp_sender_sys_rsp_pkt.construct_sysrsp(
                           .smi_targ_ncore_unit_id (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                           .smi_src_ncore_unit_id  (addrMgrConst::funit_ids[addrMgrConst::dve_ids[0]]),
                           .smi_msg_type           (SYS_RSP),
                           .smi_msg_id             ('h0),
                           .smi_msg_tier           ('h0),
                           .smi_steer              ('h0),
                           .smi_msg_pri            ('0),
                           .smi_msg_qos            ('0),
                           .smi_tm                 ('h0),
                           .smi_rmsg_id            (m_pkt.smi_msg_id),
                           .smi_msg_err            ('h0),
                           .smi_cmstatus           (m_pkt.smi_cmstatus),
                           .smi_ndp_aux            ('h0)
                        );
        isSenderEventAckNeeded = 1;
    endfunction :setup_sys_evt_rsp

    function void check_sys_evt_rsp(smi_seq_item evtrsp_item);
        t_latest_update   = $time;
        t_sfi_sys_rsp     = t_latest_update;
       if (!exp_sender_sys_rsp_pkt.compare(evtrsp_item)) begin 
       `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", "check_sys_evt_rsp::EvtRsp fields mismatching above!");
       end
       isSenderSysRspRcvd = 1;
    endfunction : check_sys_evt_rsp

    function void setup_evt_ack(event_pkt evt_pkt);
        evt_ack_pkt = new();
        evt_ack_pkt.copy(evt_pkt);
        isSenderEventAckRcvd=1;
        t_latest_update   = $time;
        t_sfi_evt_ack     = t_latest_update;
    endfunction : setup_evt_ack

    function void setup_rcv_sys_req(smi_seq_item sys_req);
        t_latest_update   = $time;
        t_sfi_sys_req_rcv     = t_latest_update;
        exp_reciever_sys_req_pkt = smi_seq_item::type_id::create("exp_reciever_sys_req_pkt");
        exp_reciever_sys_req_pkt.copy(sys_req);
       
	isRecieverSysReqRcvd = 1;
        <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false) { %>
        //If EventOut interface exists
	isRecieverEventReqNeeded = 1;
        <%}%>
	isRecieverEventReqSent = 0;
        isRecieverEventAckNeeded=0;
        isRecieverEventAckSent=0;
        isRecieverSysRspNeeded=0;
        isRecieverSysRspSent=0;

    endfunction :setup_rcv_sys_req

    function void setup_rcv_evt_req(event_pkt evt_pkt);
        evt_req_rcv = new();
        evt_req_rcv.copy(evt_pkt);
	isRecieverEventReqSent = 1;
        isRecieverEventAckNeeded=1;
        t_latest_update   = $time;
        t_sfi_evt_req_rcv = t_latest_update;
    endfunction :setup_rcv_evt_req

    function void setup_rcv_evt_ack(event_pkt evt_pkt);
        evt_ack_rcv = new();
        evt_ack_rcv.copy(evt_pkt);
        isRecieverEventAckSent=1;
        isRecieverSysRspNeeded=1;
        t_latest_update   = $time;
        t_sfi_evt_ack_rcv = t_latest_update;
    endfunction :setup_rcv_evt_ack


    function void setup_exp_rcv_sys_rsp(smi_seq_item m_pkt);
       exp_reciever_sys_rsp_pkt = smi_seq_item::type_id::create("exp_reciever_sys_rsp_pkt");
       exp_reciever_sys_rsp_pkt.construct_sysrsp(
                           .smi_targ_ncore_unit_id (m_pkt.smi_src_ncore_unit_id),
                           .smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                           .smi_msg_type           (SYS_RSP),
                           .smi_msg_id             ('h0),
                           .smi_msg_tier           ('h0),
                           .smi_steer              ('h0),
                           .smi_msg_pri            ('0),
                           .smi_msg_qos            ('0),
                           .smi_tm                 ('h0),
                           .smi_rmsg_id            (m_pkt.smi_msg_id),
                           .smi_msg_err            ('h0),
                           .smi_cmstatus           (m_pkt.smi_cmstatus),
                           .smi_ndp_aux            ('h0)
                        );
        <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == true) { %>
        //EventOut interface does not exist
        isRecieverSysRspNeeded=1;
        <%}%>
    endfunction :setup_exp_rcv_sys_rsp
    function void check_sys_rcv_sys_rsp (smi_seq_item m_pkt);
        exp_reciever_sys_rsp_pkt.compare(m_pkt);
        isRecieverSysRspSent=1;
        t_latest_update   = $time;
        t_sfi_sys_rsp_rcv = t_latest_update;
    endfunction :check_sys_rcv_sys_rsp


    function void setup_sysco(eSysCoFSM state);
    	smi_seq_item exp_sys_req_pkt;
    	t_creation = $time;

	if (state == CONNECT)
    	    isSysCoAttachSeq = 1;
        else if (state == DETACH)
    	    isSysCoDetachSeq = 1;

	exp_sys_req_pktq = {};
	exp_sys_rsp_pktq = {};

        <%if((obj.orderedWriteObservation == true) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.useCache)){%>
            foreach(CONNECTED_DCE_FUNIT_IDS[i])begin
                dce_funit_id[i] = CONNECTED_DCE_FUNIT_IDS[i];
            end
            `ifdef VCS
	    //foreach (addrMgrConst::dce_ids[i]) begin : foreach_dce_ids
	    foreach (dce_funit_id[i]) begin : foreach_dce_ids
                //`uvm_info("IOAIU::SCB::DBG",$sformatf("#%0d dce_id is %0h", i, dce_funit_id[i]), UVM_NONE)
            `else // `ifndef VCS
            foreach (CONNECTED_DCE_FUNIT_IDS[i]) begin : foreach_dce_ids
            `endif  // `ifdef VCS
        	    exp_sys_req_pkt = smi_seq_item::type_id::create("exp_sys_req_pkt");
			    exp_sys_req_pkt.construct_sysmsg(
                    .smi_targ_ncore_unit_id (CONNECTED_DCE_FUNIT_IDS[i]),
                    .smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                    .smi_msg_type           (eSysReq),
                    .smi_msg_id             ((sysCohSender && sysEventSender) ? 'h1 : 'h0),
                    .smi_msg_tier           ('h0),
                    .smi_steer              ('h0 ),
                    .smi_msg_pri            ('h0 ),
                    .smi_msg_qos            ('h0 ),
                    .smi_rmsg_id            ('h0 ),
                    .smi_msg_err            ('h0 ),
                    .smi_cmstatus           ('h0 ),
                    .smi_sysreq_op          ((state == CONNECT) ? SMI_SYSREQ_ATTACH : SMI_SYSREQ_DETACH),
                    .smi_ndp_aux            ('h0)
			    );
			    exp_sys_req_pktq.push_back(exp_sys_req_pkt);
		    end : foreach_dce_ids
        <%}%>
	
	<%if(((obj.fnNativeInterface === "ACELITE-E") && (obj.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5")){%>
		foreach (addrMgrConst::dve_ids[i]) begin : foreach_dve_ids

        	exp_sys_req_pkt = smi_seq_item::type_id::create("exp_sys_req_pkt");
			
			exp_sys_req_pkt.construct_sysmsg(
        		.smi_targ_ncore_unit_id (addrMgrConst::funit_ids[addrMgrConst::dve_ids[i]]),
        		.smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
        		.smi_msg_type           (eSysReq),
        		.smi_msg_id             ((sysCohSender && sysEventSender) ? 'h1 : 'h0),
        		.smi_msg_tier           ('h0),
        		.smi_steer              ('h0 ),
        		.smi_msg_pri            ('h0 ),
        		.smi_msg_qos            ('h0 ),
        		.smi_rmsg_id            ('h0 ),
        		.smi_msg_err            ('h0 ),
        		.smi_cmstatus           ('h0 ),
        		.smi_sysreq_op          ((state == CONNECT) ? SMI_SYSREQ_ATTACH : SMI_SYSREQ_DETACH),
        		.smi_ndp_aux            ('h0)
			);

			exp_sys_req_pktq.push_back(exp_sys_req_pkt);
		end : foreach_dve_ids
	<%}%>
	
		nSMISysReqExpd = exp_sys_req_pktq.size();
		nSMISysReqSent = 0;
		nSMISysRspRcvd = 0;
		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> fn:setup_sysco: number of SysReqs predicted for %0p: %0d",  tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, state, exp_sys_req_pktq.size()),UVM_LOW)
    endfunction : setup_sysco
    
    function void check_sysreq(smi_seq_item sysreq_item);
    	int idxq[$];
    	smi_seq_item exp_sys_rsp_pkt;
    	
    	t_latest_update = $time;
		idxq = {};
    	idxq = exp_sys_req_pktq.find_index with (item.smi_targ_ncore_unit_id == sysreq_item.smi_targ_ncore_unit_id);
		if (idxq.size() == 0) begin 
			`uvm_error("<%=obj.strrtlnameprefix%> scb", $psprintf("sysreq.smi_targ_ncore_unit_id:0x%0h does not match any of the expected", sysreq_item.smi_targ_ncore_unit_id))
		end else if (idxq.size() > 1) begin
			`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("SysReq.smi_targ_ncore_unit_id:0x%0h has more than one match in expected SysReqs", sysreq_item.smi_targ_ncore_unit_id))
		end else begin
               //#Check.IOAIU.SMI.SysReq.CMStatus
               //#Check.IOAIU.SMI.SysReq.CMType
               //#Check.IOAIU.SMI.SysReq.MsgID
               //#Check.IOAIU.SMI.SysReq.RMsgID
               //#Check.IOAIU.SMI.SysReq.Steering
               //#Check.IOAIU.SMI.SysReq.TTier
               //#Check.IOAIU.SMI.SysReq.TargetID
               //#Check.IOAIU.SMI.SysReq.Timestamp
               //#Check.IOAIU.SMI.SysReq.priority
               //#Check.IOAIU.SMI.SysReq.InitiatorID               

                   exp_sys_req_pktq[idxq[0]].smi_msg_id=sysreq_item.smi_msg_id;      
			if (!exp_sys_req_pktq[idxq[0]].compare(sysreq_item)) begin 
         		`uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", "SysReq fields mismatching above!");
			end 
	
			nSMISysReqSent += 1;
			m_sys_req_pktq.push_back(sysreq_item);
			exp_sys_req_pktq.delete(idxq[0]);

            //expect sysrsp 
        	exp_sys_rsp_pkt = smi_seq_item::type_id::create("exp_sys_rsp_pkt");
    		exp_sys_rsp_pkt.construct_sysrsp(
        		.smi_targ_ncore_unit_id (<%=obj.AiuInfo[obj.Id].FUnitId%>),
        		.smi_src_ncore_unit_id  (sysreq_item.smi_targ_ncore_unit_id),
        		.smi_msg_type           (eSysRsp),
       			.smi_msg_id             ('h0),
        		.smi_msg_tier           ('h0),
       			.smi_steer              ('h0),
        		.smi_msg_pri            ('h0),
        		.smi_msg_qos            ('h0),
        		.smi_tm                 ('h0),
        		.smi_rmsg_id            (sysreq_item.smi_msg_id),
        		.smi_msg_err            ('h0),
                .smi_cmstatus           ( sysreq_item.smi_sysreq_op == SMI_SYSREQ_ATTACH && $test$plusargs("attach_sys_rsp_error") ? 'h43 :
                                          sysreq_item.smi_sysreq_op == SMI_SYSREQ_DETACH && $test$plusargs("detach_sys_rsp_error") ? 'h43 :
                                         'h3),
       			.smi_ndp_aux            ('h0)
    		);
			exp_sys_rsp_pktq.push_back(exp_sys_rsp_pkt);

		end

    endfunction : check_sysreq
    
    function void check_sysrsp(smi_seq_item sysrsp_item);
    	int idxq[$];
    	
    	t_latest_update = $time;

		idxq = {};
    	idxq = exp_sys_rsp_pktq.find_index with (item.smi_src_ncore_unit_id == sysrsp_item.smi_src_ncore_unit_id);
		if (idxq.size() == 0) begin 
			`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("SysRsp.smi_src_ncore_unit_id:0x%0h does not match any of the expected", sysrsp_item.smi_targ_ncore_unit_id))
		end else if (idxq.size() > 1) begin
			`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("SysRsp.smi_src_ncore_unit_id:0x%0h has more than one match in expected SysReqs", sysrsp_item.smi_targ_ncore_unit_id))
		end else begin
			if (exp_sys_rsp_pktq[idxq[0]].smi_cmstatus[7:6] == 'b01)
				exp_sys_rsp_pktq[idxq[0]].smi_cmstatus[2:0] = sysrsp_item.smi_cmstatus[2:0];
			
			//this is needed since after attach-error since state-machine attempts to attach again by default, we want the attach successfully to complete for test to end. So on 2nd iteration of attach, system_bfm sends back no error on rsp
			if ($test$plusargs("attach_sys_rsp_error"))
				exp_sys_rsp_pktq[idxq[0]].smi_cmstatus = sysrsp_item.smi_cmstatus;

                        //#Check.IOAIU.SMI.SysRSP.Aux
                        //#Check.IOAIU.SMI.SysRSP.CMType
                        //#Check.IOAIU.SMI.SysRSP.RMsgID
                        //#Check.IOAIU.SMI.SysRSP.Steering
                        //#Check.IOAIU.SMI.SysRSP.TTier
                        //#Check.IOAIU.SMI.SysRSP.TargetID
                        //#Check.IOAIU.SMI.SysRSP.priority
                        //#Check.IOAIU.SMI.SysRSP.InitiatorID                        
                        exp_sys_rsp_pktq[idxq[0]].smi_msg_id=sysrsp_item.smi_msg_id;      
				
			if (!exp_sys_rsp_pktq[idxq[0]].compare(sysrsp_item)) begin 
         		`uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", "SysRsp fields mismatching above!");
			end 
			nSMISysRspRcvd += 1;
			m_sys_rsp_pktq.push_back(sysrsp_item);
			exp_sys_rsp_pktq.delete(idxq[0]);
		end
    endfunction : check_sysrsp
   
    function void setup_ace_read_req(ace_read_addr_pkt_t m_pkt, longint unsigned cycle_count);
        int  fnmem_region_idx;
        longint m_start_addr             = (m_pkt.araddr/(DATA_WIDTH/8)) * (DATA_WIDTH/8);
        int     m_arlen_tmp              = 0;
        int     m_num_bytes              = 2 ** m_pkt.arsize;
        int     m_burst_length           = m_pkt.arlen + 1;
        int     m_beats_in_a_cacheline   = SYS_nSysCacheline*8/DATA_WIDTH;
        longint m_aligned_addr           = (m_pkt.araddr/(m_num_bytes)) * m_num_bytes; 
        bit     m_aligned                = (m_aligned_addr === m_start_addr);
        int     m_dtsize                 = m_num_bytes * m_burst_length;
        longint m_lower_wrapped_boundary = (m_start_addr/m_dtsize) * m_dtsize; 
        longint m_upper_wrapped_boundary = m_lower_wrapped_boundary + m_dtsize; 
        total_cacheline_count            = 1;
        arlen                            = m_pkt.arlen;

        natv_intf_cc = cycle_count;

        for (int i = 0; i < m_burst_length - 1; i++) begin : for_m_burst_length
            if (m_aligned) begin
                m_start_addr = m_start_addr + m_num_bytes;
                if (m_pkt.arburst === AXIWRAP) begin
                    if (m_start_addr >= m_upper_wrapped_boundary) begin
                        m_start_addr = m_lower_wrapped_boundary;
                    end
                end
            end
            else begin
                m_start_addr = m_aligned_addr + m_num_bytes; 
                m_aligned    = 1;
            end
            if (m_start_addr[SYS_wSysCacheline-1:0] === '0 &&
                (m_start_addr[WAXADDR-1:SYS_wSysCacheline] !== m_pkt.araddr[WAXADDR-1:SYS_wSysCacheline] || (m_pkt.arburst === AXIWRAP && total_cacheline_count > 1))
            ) begin
                total_cacheline_count++;
            end
            if (total_cacheline_count === 1) begin
                m_arlen_tmp++;
            end
        end : for_m_burst_length
        m_ace_read_addr_pkt = new();
        m_ace_read_addr_pkt.copy(m_pkt);
        isAtomic = 0;
        isStash  = 0;
        isRead               = 1;
        isACEReadAddressRecd = 1;
        // Tying off these signals just like a real Bridge AIU does
        <%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")){%> 
            if(addrMgrConst::get_addr_gprar_nc(m_ace_read_addr_pkt.araddr)) begin
                $cast(m_ace_read_addr_pkt.ardomain,0);
            end
            m_ace_read_addr_pkt.arsnoop  = 0;
        <%}%>
        setup_ace_cmd_type();
        setup_gpra_order(m_ace_read_addr_pkt.araddr); 

        if(m_ace_cmd_type inside {DVMMSG, DVMCMPL}) begin
	    dest_id = DVE_FUNIT_IDS[0];
            isDVM = 1;
            mem_regions_overlap = 0;
            addrNotInMemRegion  = 0;
        end else
            dest_id = addrMgrConst::map_addr2dmi_or_dii(m_pkt.araddr,fnmem_region_idx);
        //if({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_read_addr_pkt.araddr} == <%=obj.wAddr%><%=obj.CsrInfo.csrBaseAddress.replace("0x", "'h")%>F_F000 && !(m_ace_cmd_type == DVMMSG)) begin
        <% if(obj.wAddr==aiu_axiInt.params.wAddr) { %>
        if((m_ace_read_addr_pkt.araddr >= addrMgrConst::NRS_REGION_BASE) &&
        	(m_ace_read_addr_pkt.araddr < (addrMgrConst::NRS_REGION_BASE+addrMgrConst::NRS_REGION_SIZE))
        <% } else { %>
        if(({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_read_addr_pkt.araddr} >= addrMgrConst::NRS_REGION_BASE) &&
        	({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_read_addr_pkt.araddr} < (addrMgrConst::NRS_REGION_BASE+addrMgrConst::NRS_REGION_SIZE))
        <% } %>
        	&& !(m_ace_cmd_type == DVMMSG) //dvms do not lookup address-map
          ) begin

			//Only the XAIU Identification Register does not warrant a SMI CMDreq, all other register do need it. 
			//Refer CONC-10448 Arch comment, This is self register hit.
			
			`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN", $psprintf("XAIUIDR Self Identification Register address:0x%0h", <%=generateRegPath('XAIUIDR.get_address()')%>),UVM_LOW)
			`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN", $psprintf("XAIUIDR Fabric Unit Identification Register address:0x%0h", <%=generateRegPath('XAIUFUIDR.get_address()')%>),UVM_LOW)
			//if (m_ace_read_addr_pkt.araddr[11:0] == <%=generateRegPath('XAIUIDR.get_address()[11:0]')%>) begin 
  <% if(obj.wAddr==aiu_axiInt.params.wAddr) { %>
    <%if(obj.testBench == "fsys") { %>
        	if(m_ace_read_addr_pkt.araddr == {addrMgrConst::NRS_REGION_BASE[51:20],20'hF_F000}) begin
    <%}else{%>
        	if(m_ace_read_addr_pkt.araddr == <%=obj.wAddr%><%=obj.CsrInfo.csrBaseAddress.replace("0x", "'h")%>F_F000) begin
    <%}%>   
  <% } else { %>
    <%if(obj.testBench == "fsys") { %>
        	if({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_read_addr_pkt.araddr} == {addrMgrConst::NRS_REGION_BASE[51:20],20'hF_F000}) begin
    <%}else{%>
        	if({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_read_addr_pkt.araddr} == <%=obj.wAddr%><%=obj.CsrInfo.csrBaseAddress.replace("0x", "'h")%>F_F000) begin
    <%}%>   
  <% } %>
            	isSMICMDReqNeeded    = 0;
            	isSelfIDRegAccess  	 = 1;
				`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN", $psprintf("CSR access to XAIUIDR Self Identification Register- terminates within IOAIU without going to bus"),UVM_LOW)
			end else begin
            	isSMICMDReqNeeded    = 1;
				`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN", $psprintf("CSR access but not to XAIUIDR Self Identification Register- needs to be mastered to bus as SMI CMDReq"),UVM_LOW)
            end

            addrNotInMemRegion   = 0; // FSYS we are in CSR DII memregion
            addrInCSRRegion      = 1;
        end else if((fnmem_region_idx == -1) && (dest_id == -1) && !(m_ace_cmd_type inside {DVMMSG})) begin
            isSMICMDReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;
  	    isSMISTRReqNotNeeded = 1;	   
            addrNotInMemRegion   = 1;
  
        end else begin
            <%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache){%> 
                   isSMICMDReqNeeded    = (csr_ccp_lookupen)? 0 : 1;
                    isSMISTRReqNotNeeded = (csr_ccp_lookupen)? 1 : 0;
                  <%}else{%>   
                 isSMICMDReqNeeded    =  1; 
                 isSMISTRReqNotNeeded = 0; 
            <%}%>
	    end

        if(mem_regions_overlap || addrNotInMemRegion) begin // For Addr Region Overlap test // FSYS need STR req when external CSR access 
            isSMICMDReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;
            isSMISTRReqNotNeeded = 1;
        end
        if($test$plusargs("connectivity_testing") && addr_trans_mgr::check_unmapped_add(m_ace_read_addr_pkt.araddr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type) && !(m_ace_cmd_type inside {DVMMSG, DVMCMPL})) begin
            addrNotInMemRegion   = 1;      
        end
        if($test$plusargs("no_credit_check") && !(m_ace_cmd_type inside {DVMMSG, DVMCMPL})) begin
            addrNotInMemRegion   = 1;      
        end
        <%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache){%> 
            if (csr_ccp_lookupen) begin
                //Setup tag and index
                ccp_addr   = shift_addr(m_ace_read_addr_pkt.araddr);
                ccp_index = addrMgrConst::get_set_index(m_ace_read_addr_pkt.araddr,<%=obj.FUnitId%>);
            end
        <%}%>

	    m_axi_qos = m_ace_read_addr_pkt.arqos;
        m_axcache = m_ace_read_addr_pkt.arcache;
        t_creation           = $time;
        t_latest_update      = $time;
        t_ace_read_recd      = $time;
        m_sfi_addr           = m_ace_read_addr_pkt.araddr;
        m_id                 = m_ace_read_addr_pkt.arid;

        <%if(aiu_axiInt.params.wArUser > 0){%>
            m_user               = m_ace_read_addr_pkt.aruser;
        <%}%>

        <%if(obj.wSecurityAttribute > 0){%>
            m_security = m_ace_read_addr_pkt.arprot[1];
        <%}else{%>    
            m_security = 0;
        <%}%>

        if(!(m_ace_cmd_type ==  RDCLN  ||
             m_ace_cmd_type ==  RDSHRD ||
             m_ace_cmd_type ==  CLNUNQ ||
             m_ace_cmd_type ==  RDNOSNP
            ) &&
            m_ace_read_addr_pkt.arlock == EXCLUSIVE
        )
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU scoreboard receives arlock = %b with m_ace_cmd_type = %s which is unexpected", m_pkt.arlock, m_ace_cmd_type.name())) //write transaction should be normal access. No exclusive access.
        if (m_ace_cmd_type == DVMCMPL)
            isSMICMDReqNeeded    = 0;

        isACEReadDataNeeded = 1;

        <%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
			isCoherent = (addrMgrConst::get_addr_gprar_nc(m_sfi_addr) == 1) ? 0 : 1;
        	<%if(obj.useCache) { %> 
        		isIoCacheTagPipelineNeeded = (this.csr_ccp_lookupen);
        	<%}%>
	    <%}else{%>    
			isCoherent = (m_ace_read_addr_pkt.ardomain inside {NONSHRBL, SYSTEM}) ? 0 : 1;
        <%}%>

        if ((m_ace_cmd_type === RDONCE || m_ace_cmd_type === RDNOSNP) &&
            total_cacheline_count > 1) begin
            isMultiLineMaster                  = 0;
            isMultiAccess                      = 1;
            multiline_order                    = 0;
            m_multiline_starting_read_addr_pkt = m_pkt;
            m_ace_read_addr_pkt.arlen          = m_arlen_tmp;
        end
       if(((!addrNotInMemRegion)&&((m_ace_cmd_type != DVMMSG) && (m_ace_cmd_type != DVMCMPL)) && addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DII 
       && (isCoherent || !(m_ace_cmd_type inside {RDNOSNP,CLNINVL,CLNSHRD,MKINVL,CLNSHRDPERSIST})))
<%if(!obj.eAc && ((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E"))){ %> || ((m_ace_cmd_type == DVMMSG) && (m_ace_cmd_type == DVMCMPL))<%}%> ) begin
            isSMICMDReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;	       
            illDIIAccess    = 1;
            isSMISTRReqNotNeeded = 1;

	        multiline_ready_to_delete = (isMultiAccess) ? 1 : 0;
	    end 
      //Setup Partial Read or Full Read

        if(SYS_nSysCacheline > (m_num_bytes*(m_ace_read_addr_pkt.arlen+1))) begin 
            isPartialRead = 1'b1;
        end else if (SYS_nSysCacheline == (m_num_bytes*(m_ace_read_addr_pkt.arlen+1))) begin
            isPartialRead = 1'b0;
        end else begin
            `uvm_error("IO-$-SCB", "Unable to determine whether the read is full/partial")
        end
        if((m_ace_cmd_type == DVMMSG)) begin
            if(m_ace_read_addr_pkt.araddr[0] == 1) begin
                isDVMMultiPart = 1;
                isACEReadAddressDVMNeeded = 1;
            end
            if(m_ace_read_addr_pkt.araddr[14:12] == 3'b100) begin// DVM Message Type : Synchronization - 3'b100
                isDVMSync = 1;
            end
        end
  <% if(obj.wAddr==aiu_axiInt.params.wAddr) { %>
    <%if(obj.testBench == "fsys") { %>
        if(m_ace_read_addr_pkt.araddr != {addrMgrConst::NRS_REGION_BASE[51:20],20'hF_F000})  
    <%}else{%>
        if(m_ace_read_addr_pkt.araddr != <%=obj.wAddr%><%=obj.CsrInfo.csrBaseAddress.replace("0x","'h")%>F_F000)  
    <%}%>   
  <% } else { %>
    <%if(obj.testBench == "fsys") { %>
        if({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_read_addr_pkt.araddr} != {addrMgrConst::NRS_REGION_BASE[51:20],20'hF_F000})  
    <%}else{%>
        if({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_read_addr_pkt.araddr} != <%=obj.wAddr%><%=obj.CsrInfo.csrBaseAddress.replace("0x","'h")%>F_F000)  
    <%}%>   
  <% } %>
            setup_dce_dmi_id_for_req();

      if (addrInCSRRegion) begin 
                 if ((<%=obj.AiuInfo[obj.Id].fnCsrAccess %> == 0) || //config supports CSR access
                     (m_ace_read_addr_pkt.araddr[1:0] != 0) || //32-bit/4B size-aligned
                     (((m_ace_read_addr_pkt.arlen+1)*(2**m_ace_read_addr_pkt.arsize)) != 4) || //4B transfer
                     (m_ace_read_addr_pkt.arcache[1] != 0)) //EndpointOrder/Device txn
                illegalCSRAccess = 1;
      end
	
    <%if(obj.testBench == "fsys") { %>
	if (k_decode_err_illegal_acc_format_test_unsupported_size==1) begin
	    illegalCSRAccess = 1;
        end
    <%}%>   
        
        ///New 3.4 security feature, refer to Section 9.7 Ncore Security Extension in IOAIU uArch spec
        //Access to CSR region never assert illegalNSAccess
		if ((m_security == 1) && (addrMgrConst::get_addr_gprar_nsx(m_sfi_addr) == 0) && !isDVM && !addrInCSRRegion && (m_ace_cmd_type != BARRIER)) begin 
			illegalNSAccess      = 1;
		end
        <%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
        //New 3.4 security feature, refer to Section 9.5 A transaction with a dii destination will return a decode error and not be sent to the dii if this bit is not set.                
	    if ((!addrNotInMemRegion) && (addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DII) && (addrMgrConst::get_addr_gprar_nc(m_sfi_addr) == 0) ) begin 
                illDIIAccess=1;
            end
        <%}%>
        if(illegalNSAccess      == 1 || illDIIAccess==1 || addrNotInMemRegion || illegalCSRAccess == 1 ) begin
            isSMICMDReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;
            isSMISTRReqNotNeeded = 1;
        end
        m_axi_resp_expected = new[m_ace_read_addr_pkt.arlen+1];
        foreach (m_axi_resp_expected[i]) begin
        	//#Check.IOAIU.illegalNSAccess_Read_DECERR
               //#Check.IOAIU.IllegaIOpToDII.DECERR  
              //#Check.IOAIU.illDIIAccess.DECERR
            if (illDIIAccess 
            	|| mem_regions_overlap 
            	|| illegalNSAccess
		|| illegalCSRAccess
               ) begin
	        if( <%if(!(obj.eAc && ( (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")))){ %>((m_ace_cmd_type == DVMMSG) && (m_ace_cmd_type == DVMCMPL)) <%} else  {%> 0 <%}%>) 
                    m_axi_resp_expected[i] = SLVERR;
	        else
	    	    m_axi_resp_expected[i] = DECERR;	
            end
            else if (addrNotInMemRegion && !addrInCSRRegion && !(m_ace_cmd_type == DVMMSG)) begin
                m_axi_resp_expected[i] = DECERR;
            end
         end
        m_ott_status = INACTIVE;
        m_ott_id     = -1;

    endfunction : setup_ace_read_req

    function void setup_ace_read_multiline_txn(ace_read_addr_pkt_t m_pkt, int count, int tmp_total_cacheline_count, int m_tracking_id);
        int no_of_bytes;
        int fnmem_region_idx;
        longint m_start_addr             = m_pkt.araddr;
        int     m_num_bytes              = 2 ** m_pkt.arsize;
        int     m_burst_length           = m_pkt.arlen + 1;
        int     m_beats_in_a_cacheline   = SYS_nSysCacheline*8/DATA_WIDTH;
        longint m_aligned_addr           = (m_start_addr/(m_num_bytes * m_beats_in_a_cacheline)) * m_num_bytes * m_beats_in_a_cacheline; // Cacheline aligned address
        bit     m_aligned                = 1;//(m_aligned_addr === m_start_addr);
        int     m_dtsize                 = m_num_bytes * m_burst_length;
        longint m_lower_wrapped_boundary = (m_start_addr/m_dtsize) * m_dtsize; 
        longint m_upper_wrapped_boundary = m_lower_wrapped_boundary + m_dtsize; 
        
        if (m_aligned) begin
            m_start_addr = m_aligned_addr + count * m_num_bytes * m_beats_in_a_cacheline; // Move to cacheline offset at "count"
            if (m_pkt.arburst === AXIWRAP) begin
                if (m_start_addr >= m_upper_wrapped_boundary) begin
                    m_start_addr = m_lower_wrapped_boundary + (m_start_addr - m_upper_wrapped_boundary);
                end
            end
            if((m_start_addr>>12) != (m_pkt.araddr>>12)) // check for 4K boundary
                m_start_addr = {m_pkt.araddr>>12,m_start_addr[11:0]};
        end
        m_ace_read_addr_pkt = new();
        m_ace_read_addr_pkt.copy(m_pkt);
	    m_axi_qos = m_ace_read_addr_pkt.arqos;
        m_axcache = m_ace_read_addr_pkt.arcache;
        if (count < tmp_total_cacheline_count - 1) begin
            m_ace_read_addr_pkt.arlen  = m_beats_in_a_cacheline - 1;
            isMultiLineMaster          = 0;
        end
        else begin
            longint m_tmp_addrA = (((m_ace_read_addr_pkt.araddr + (1 << SYS_wSysCacheline)) >> SYS_wSysCacheline) << SYS_wSysCacheline) ;
            int tmp_a = (m_ace_read_addr_pkt.arlen+1) - ($ceil(((int'(m_tmp_addrA)) - (int'(m_ace_read_addr_pkt.araddr >> LOGWDATA << LOGWDATA))) / 2**(int'(m_ace_read_addr_pkt.arsize))));
            m_ace_read_addr_pkt.arlen = tmp_a % m_beats_in_a_cacheline;
            isMultiLineMaster         = 1;
            if (m_ace_read_addr_pkt.arlen === 0) begin
                m_ace_read_addr_pkt.arlen = m_beats_in_a_cacheline - 1;
            end
            else begin
                m_ace_read_addr_pkt.arlen -= 1;
            end
        end
        m_ace_read_addr_pkt.araddr         = m_start_addr;
        m_multiline_tracking_id            = m_tracking_id;
        m_multiline_starting_read_addr_pkt = m_pkt;
        m_sfi_addr                         = m_ace_read_addr_pkt.araddr;
        m_id                               = m_ace_read_addr_pkt.arid;
        <%if(aiu_axiInt.params.wArUser > 0){%>
            m_user               = m_ace_read_addr_pkt.aruser;
        <%}%>
        <%if(obj.wSecurityAttribute > 0){%>                                             
            m_security = m_ace_read_addr_pkt.arprot[1];
        <%}else{%>
            m_security = 0;
        <%}%>

        isRead                             = 1;
        isACEReadAddressRecd               = 1;
        dest_id = addrMgrConst::map_addr2dmi_or_dii(m_pkt.araddr,fnmem_region_idx);

  <% if(obj.wAddr==aiu_axiInt.params.wAddr) { %>
        if((m_ace_read_addr_pkt.araddr >= addrMgrConst::NRS_REGION_BASE) &&
            (m_ace_read_addr_pkt.araddr < (addrMgrConst::NRS_REGION_BASE+addrMgrConst::NRS_REGION_SIZE))) begin
    <%if(obj.testBench == "fsys") { %>
            if(m_ace_read_addr_pkt.araddr == {addrMgrConst::NRS_REGION_BASE[51:20],20'hF_F000}) begin
    <%}else{%>
            if(m_ace_read_addr_pkt.araddr == <%=obj.wAddr%><%=obj.CsrInfo.csrBaseAddress.replace("0x","'h")%>F_F000) begin
    <%}%>   
  <% } else { %>
        if(({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_read_addr_pkt.araddr} >= addrMgrConst::NRS_REGION_BASE) &&
            ({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_read_addr_pkt.araddr} < (addrMgrConst::NRS_REGION_BASE+addrMgrConst::NRS_REGION_SIZE))) begin
    <%if(obj.testBench == "fsys") { %>
            if({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_read_addr_pkt.araddr} == {addrMgrConst::NRS_REGION_BASE[51:20],20'hF_F000}) begin
    <%}else{%>
            if({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_read_addr_pkt.araddr} == <%=obj.wAddr%><%=obj.CsrInfo.csrBaseAddress.replace("0x","'h")%>F_F000) begin
    <%}%>   
  <% } %>

            	isSMICMDReqNeeded = 0;
                isSMISTRReqNotNeeded = 1;
            	isSelfIDRegAccess = 1;
		`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN", $psprintf("CSR WR access to XAIUIDR Self Identification Register- terminates within IOAIU without going to bus"),UVM_LOW)
	    end else begin
            	isSMICMDReqNeeded = 1;
		`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN", $psprintf("CSR WR access but not to XAIUIDR Self Identification Register- needs to be mastered to bus as SMI CMDReq"),UVM_LOW)
            end

            addrNotInMemRegion   = 0;
            addrInCSRRegion      = 1;
        end else if(((fnmem_region_idx == -1) && (dest_id == -1)) || ($test$plusargs("connectivity_testing") && addr_trans_mgr::check_unmapped_add(m_ace_read_addr_pkt.araddr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type))) begin
            isSMICMDReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;
            isSMISTRReqNotNeeded = 1;
            addrNotInMemRegion   = 1;
        end else if($test$plusargs("no_credit_check")) begin
            isSMICMDReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;
            isSMISTRReqNotNeeded = 1;
            addrNotInMemRegion   = 1;
        end else begin
            <%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache){%> 
                isSMICMDReqNeeded    = (csr_ccp_lookupen)? 0 : 1;
                isSMISTRReqNotNeeded    = (csr_ccp_lookupen)? 1 : 0;
            <%}else{%>   
                isSMICMDReqNeeded    = 1;
            <%}%>
        end
        if(mem_regions_overlap|| addrNotInMemRegion) begin // For Addr Region Overlap test
            isSMICMDReqNeeded    = 0;
        end

        <%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %> 
            // Tying off these signals just like a real Bridge AIU does
            if(csr_ccp_lookupen) begin
                //Setup tag and index
                ccp_addr   = shift_addr(m_ace_read_addr_pkt.araddr);
                ccp_index = addrMgrConst::get_set_index(m_ace_read_addr_pkt.araddr,<%=obj.FUnitId%>);
            end 
        <%}%>  

        <%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
            if (addrMgrConst::get_addr_gprar_nc(m_ace_read_addr_pkt.araddr)) begin:_noncoh_mode
            $cast(m_ace_read_addr_pkt.ardomain,0);
            end:_noncoh_mode
            m_ace_read_addr_pkt.arsnoop  = 0;
        <%}%>

        setup_ace_cmd_type();
        setup_gpra_order(m_ace_read_addr_pkt.araddr);
        t_creation                         = $time + count*1ps;
        t_latest_update                    = $time;
        t_ace_read_recd                    = $time + count*1ps;

        <%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
		isCoherent = (addrMgrConst::get_addr_gprar_nc(m_sfi_addr) == 1) ? 0 : 1;
        	<%if(obj.useCache) { %> 
        		isIoCacheTagPipelineNeeded = (this.csr_ccp_lookupen);
        	<%}%>
	    <%}else{%>    
		isCoherent = (m_ace_read_addr_pkt.ardomain inside {NONSHRBL, SYSTEM}) ? 0 : 1;
        <%}%>
       
       	isACEReadDataNeeded   = 1;
        isDVM                 = 0;
        isDVMMultiPart        = 0;
        isMultiAccess         = 1;
        multiline_order       = count;
        total_cacheline_count = tmp_total_cacheline_count;
       
        if(!addrNotInMemRegion && addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DII && (isCoherent || m_ace_cmd_type != RDNOSNP)) begin
            isSMICMDReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;
            isSMISTRReqNotNeeded = 1;
            illDIIAccess    = 1;
            isSMIUPDReqNeeded    = 0;
            is2ndSMICMDReqNeeded = 0; 
            is2ndSMISTRReqNeeded = 0;
	        multiline_ready_to_delete = (isMultiAccess) ? 1 : 0;
        end


        if (addrInCSRRegion) begin 
                 if ((<%=obj.AiuInfo[obj.Id].fnCsrAccess %> == 0) || //config supports CSR access
                     (m_ace_read_addr_pkt.araddr[1:0] != 0) || //32-bit/4B size-aligned
                     (((m_ace_read_addr_pkt.arlen+1)*(2**m_ace_read_addr_pkt.arsize)) != 4) || //4B transfer
                     (m_ace_read_addr_pkt.arcache[1] != 0)) //EndpointOrder/Device txn
                illegalCSRAccess = 1;
      end

    <%if(obj.testBench == "fsys") { %>
	if (k_decode_err_illegal_acc_format_test_unsupported_size==1) begin
	    illegalCSRAccess = 1;
        end
    <%}%>   
	
          ///New 3.4 security feature, refer to Section 9.7 Ncore Security Extension in IOAIU uArch spec
		if ((m_security == 1) && (addrMgrConst::get_addr_gprar_nsx(m_sfi_addr) == 0) && !isDVM && !addrInCSRRegion) begin 
			illegalNSAccess      = 1;
		end

        <%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
        //New 3.4 security feature, refer to Section 9.5 A transaction with a dii destination will return a decode error and not be sent to the dii if this bit is not set.                
	    if ((!addrNotInMemRegion) && (addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DII) && (addrMgrConst::get_addr_gprar_nc(m_sfi_addr) == 0) ) begin 
                illDIIAccess=1;
            end
        <%}%>
        if(illegalNSAccess      == 1 || illDIIAccess==1 || addrNotInMemRegion || illegalCSRAccess == 1 ) begin
            isSMICMDReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;
            isSMISTRReqNotNeeded = 1;
	        multiline_ready_to_delete = (isMultiAccess) ? 1 : 0;
        end
        setup_dce_dmi_id_for_req();
        
        m_axi_resp_expected = new[m_ace_read_addr_pkt.arlen+1];
        foreach (m_axi_resp_expected[i]) begin : foreach_error_expected
            //#Check.IOAIU.IllegaIOpToDII.DECERR  #Check.IOAIU.illDIIAccess.DECERR
            if (illDIIAccess || mem_regions_overlap || illegalNSAccess || illegalCSRAccess ) begin
	if( <%if(!(obj.eAc && ( (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")))){ %>((m_ace_cmd_type == DVMMSG) && (m_ace_cmd_type == DVMCMPL)) <%} else  {%> 0 <%}%>) 
                m_axi_resp_expected[i] = SLVERR;
	else
		m_axi_resp_expected[i] = DECERR;	
            end
            else if (addrNotInMemRegion) begin
                m_axi_resp_expected[i] = DECERR;
            end
        end : foreach_error_expected
        
        //Setup Read is Partial/Full
        no_of_bytes = 2 ** m_pkt.arsize;
        if(SYS_nSysCacheline > (no_of_bytes*(m_ace_read_addr_pkt.arlen+1))) begin 
            isPartialRead = 1'b1;
        end else if (SYS_nSysCacheline == (no_of_bytes*(m_ace_read_addr_pkt.arlen+1))) begin
            isPartialRead = 1'b0;
        end else begin
            `uvm_error("IO-$-SCB", "Unable to determine whether the read is full/partial")
        end
        m_ott_status = INACTIVE;
        m_ott_id     = -1;

    endfunction : setup_ace_read_multiline_txn

    function void setup_ace_write_req(ace_write_addr_pkt_t m_pkt, longint unsigned cycle_count);
        int no_of_bytes;
        int  fnmem_region_idx;
        string temp_sftype                                               = "<%=sftype%>";
        longint m_start_addr             = (m_pkt.awaddr/(DATA_WIDTH/8)) * (DATA_WIDTH/8);
        int                                     m_awlen_tmp              = 0;
        int                                     m_num_bytes              = 2 ** m_pkt.awsize;
        int                                     m_burst_length           = m_pkt.awlen + 1;
        int                                     m_beats_in_a_cacheline   = SYS_nSysCacheline*8/DATA_WIDTH;
        longint m_aligned_addr           = (m_start_addr/(m_num_bytes)) * m_num_bytes; 
        bit                                     m_aligned                = (m_aligned_addr === m_start_addr);
        int                                     m_dtsize                 = m_num_bytes * m_burst_length;
        longint m_lower_wrapped_boundary = (m_start_addr/m_dtsize) * m_dtsize; 
        longint m_upper_wrapped_boundary = m_lower_wrapped_boundary + m_dtsize; 
        total_cacheline_count                                            = 1;
        awlen                                                            = m_pkt.awlen;

        natv_intf_cc = cycle_count;
        for (int i = 0; i < m_burst_length - 1; i++) begin : for_m_burst_length
            if (m_aligned) begin
                m_start_addr = m_start_addr + m_num_bytes;
                if (m_pkt.awburst === AXIWRAP) begin
                    if (m_start_addr >= m_upper_wrapped_boundary) begin
                        m_start_addr = m_lower_wrapped_boundary;
                    end
                end
            end
            else begin
                m_start_addr = m_aligned_addr + m_num_bytes; 
                m_aligned    = 1;
            end
            if (m_start_addr[SYS_wSysCacheline-1:0] === '0 &&
                (m_start_addr[WAXADDR-1:SYS_wSysCacheline] !== m_pkt.awaddr[WAXADDR-1:SYS_wSysCacheline] || (m_pkt.awburst === AXIWRAP && total_cacheline_count > 1)) 
            ) begin
                total_cacheline_count++;
            end
            if (total_cacheline_count === 1) begin
                m_awlen_tmp++;
            end
        end : for_m_burst_length
 
        m_ace_write_addr_pkt      = new();
        m_ace_write_addr_pkt.copy(m_pkt);
	    m_axi_qos = m_ace_write_addr_pkt.awqos;
        m_axcache = m_ace_write_addr_pkt.awcache;
        isACEWriteAddressRecd = 1;
        isSMIDTRReqNeeded     = 0;
        m_sfi_addr            = m_ace_write_addr_pkt.awaddr;
        m_id                  = m_ace_write_addr_pkt.awid;
        <%if(aiu_axiInt.params.wAwUser > 0){%>
            m_user               = m_ace_write_addr_pkt.awuser;
        <%}%>
        <%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache){%> 
            if (csr_ccp_lookupen) begin
                //Setup tag and index
                ccp_addr   = shift_addr(m_ace_write_addr_pkt.awaddr);
                ccp_index = addrMgrConst::get_set_index(m_ace_write_addr_pkt.awaddr,<%=obj.FUnitId%>);
            end
        <%}%>

        <%if(obj.wSecurityAttribute > 0){%>
            m_security = m_ace_write_addr_pkt.awprot[1];
        <%}else{%>    
            m_security = 0;
        <%}%>

        t_creation            = $time;
        t_latest_update       = $time;
        t_ace_write_recd      = $time;
        isWrite               = 1;
        setup_ace_cmd_type();
        setup_gpra_order(m_ace_write_addr_pkt.awaddr);
        if((m_ace_cmd_type !=  WRNOSNP) &&
            m_pkt.awlock == EXCLUSIVE
        )
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU scoreboard receives awlock = %b which is unexpected", m_pkt.awlock)) //write transaction should be normal access. No exclusive access.

        <%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
			isCoherent = (addrMgrConst::get_addr_gprar_nc(m_sfi_addr) == 1) ? 0 : 1;
        	<%if(obj.useCache) { %> 
        		isIoCacheTagPipelineNeeded = (this.csr_ccp_lookupen);
        	<%}%>
	    <%}else{%>    
			isCoherent = (m_ace_write_addr_pkt.awdomain inside {NONSHRBL, SYSTEM}) ? 0 : 1;
        <%}%>

        if (m_ace_cmd_type === EVCT   ||
            m_ace_cmd_type === WREVCT ||
            m_ace_cmd_type === WRCLN  ||
            m_ace_cmd_type === WRBK
        ) begin
            isUpdate = 1;
            isWrite  = 0;
            isAtomic = 0;
            isStash = 0;
        end
        else if(m_ace_cmd_type === ATMLD      ||
                m_ace_cmd_type === ATMSTR     ||
                m_ace_cmd_type === ATMSWAP    ||
                m_ace_cmd_type === ATMCOMPARE) begin
            isUpdate = 0;
            isWrite  = 1;
	        isAtomic = 1;
	        isStash  = 0;
            if(<%if (obj.fnNativeInterface != "AXI5")  {%>m_ace_write_addr_pkt.awdomain inside {'b00, 'b11} <%} else {%>addrMgrConst::get_addr_gprar_nc(m_sfi_addr) == 1 <%}%>)
                isCoherentAtomic = 0;
            else
                isCoherentAtomic = 1;
       
            if((m_ace_cmd_type == ATMLD) || (m_ace_cmd_type === ATMSTR) || (m_ace_cmd_type === ATMSWAP)) begin
                if(!((m_dtsize == 1) || (m_dtsize == 2) || (m_dtsize == 4) || (m_dtsize == 8))) begin
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("awsize/awlen combination of ATMLD/ATMSTR/ATMSWAP is wrong. AWSIZE = %0d, AWLEN = %0d", m_ace_write_addr_pkt.awsize, m_ace_write_addr_pkt.awlen))
                end
            end
            if(m_ace_cmd_type == ATMCOMPARE) begin
                if(!((m_dtsize == 2) || (m_dtsize == 4) || (m_dtsize == 8) || (m_dtsize == 16) || (m_dtsize == 32))) begin
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("awsize/awlen combination of ATMCOMPARE is wrong. AWSIZE = %0d, AWLEN = %0d", m_ace_write_addr_pkt.awsize, m_ace_write_addr_pkt.awlen))
                end
            end
	    end
        else if (m_ace_cmd_type === WRUNQPTLSTASH ||
		 m_ace_cmd_type === WRUNQFULLSTASH ||
		 m_ace_cmd_type === STASHONCESHARED ||
		 m_ace_cmd_type === STASHONCEUNQ ||
		 m_ace_cmd_type === STASHTRANS ) begin
            isUpdate = 0;
            isWrite  = 1;
	        isAtomic = 0;
	        isStash  = 1;
	    end
	    else begin
            isWrite = 1;
	    end
       
        if (m_ace_cmd_type === EVCT 
        ) begin
            isACEWriteDataNeeded = 0;
        end
        else begin
            if(m_ace_cmd_type != STASHONCESHARED &&
            m_ace_cmd_type != STASHTRANS &&	   
            m_ace_cmd_type != STASHONCEUNQ) begin
                isACEWriteDataNeeded = 1;
            end else begin
                isACEWriteDataNeeded = 0;
            end
        end
    
        if (isUpdate) begin : if_isUpdate
            if (m_ace_cmd_type === WRCLN ||
                (m_ace_cmd_type === WRBK &&
                 m_pkt.awdomain == NONSHRBL)||
                (m_ace_cmd_type == WREVCT && //CONC-6603
                 m_pkt.awdomain == NONSHRBL)) begin
                isSMIUPDReqNeeded = 0;
            end
            else begin
                isSMIUPDReqNeeded = 1;
            end
////            if ((m_ace_cmd_type === EVCT) ||
 //               (m_ace_cmd_type === WREVCT &&
 //                m_pkt.awdomain === NONSHRBL)
 //               ) begin
 //               isSMIDTWReqNeeded = 0;
 //           end
 //           else begin
 //               isSMIDTWReqNeeded = 1;
 //           end
            if(m_ace_cmd_type == EVCT) begin
                isSMICMDReqNeeded = 0;
                isSMISTRReqNotNeeded = 1;
            end else begin
                isSMICMDReqNeeded = 1;
            end
            if(m_pkt.awburst == AXIINCR || m_pkt.awburst == AXIWRAP) begin
	        isPartialWrite = ((m_pkt.awlen + 1) < m_beats_in_a_cacheline) ? 1 : 0;
            end else begin
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("TB ERROR: Invalid awburst type. ACE does not support AxBurst as FIXED. AwId is 0x%h", m_pkt.awid))
            end
        end : if_isUpdate

        if(isAtomic) begin
            if(m_ace_cmd_type != ATMSTR) begin
                isACEReadDataNeeded = 1;
            end
        end
       
        dest_id = addrMgrConst::map_addr2dmi_or_dii(m_pkt.awaddr,fnmem_region_idx);
  <% if(obj.wAddr==aiu_axiInt.params.wAddr) { %>
        if((m_ace_write_addr_pkt.awaddr >= addrMgrConst::NRS_REGION_BASE) &&
        	(m_ace_write_addr_pkt.awaddr < (addrMgrConst::NRS_REGION_BASE+addrMgrConst::NRS_REGION_SIZE))
          ) begin
    <%if(obj.testBench == "fsys") { %>
        	if(m_ace_write_addr_pkt.awaddr == {addrMgrConst::NRS_REGION_BASE[51:20],20'hF_F000}) begin
    <%}else{%>
        	if(m_ace_write_addr_pkt.awaddr == <%=obj.wAddr%><%=obj.CsrInfo.csrBaseAddress.replace("0x", "'h")%>F_F000) begin
    <%}%>   
  <% } else { %>
        if(({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_write_addr_pkt.awaddr} >= addrMgrConst::NRS_REGION_BASE) &&
        	({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_write_addr_pkt.awaddr} < (addrMgrConst::NRS_REGION_BASE+addrMgrConst::NRS_REGION_SIZE))
          ) begin
    <%if(obj.testBench == "fsys") { %>
        	if({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_write_addr_pkt.awaddr} == {addrMgrConst::NRS_REGION_BASE[51:20],20'hF_F000}) begin
    <%}else{%>
        	if({<%=obj.wAddr-aiu_axiInt.params.wAddr%>'h0,m_ace_write_addr_pkt.awaddr} == <%=obj.wAddr%><%=obj.CsrInfo.csrBaseAddress.replace("0x", "'h")%>F_F000) begin
    <%}%>   
  <% } %>
            	isSMICMDReqNeeded    = 0;
            	isSelfIDRegAccess  	 = 1;
				`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN", $psprintf("CSR RD access to XAIUIDR Self Identification Register- terminates within IOAIU without going to bus"),UVM_LOW)
			end else begin
            	isSMICMDReqNeeded    = 1;
				`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN", $psprintf("CSR RD access but not to XAIUIDR Self Identification Register- needs to be mastered to bus as SMI CMDReq"),UVM_LOW)
            end

            addrNotInMemRegion   = 0; // FSYS we are in CSR DII memregion
            addrInCSRRegion      = 1;

        end else if(((fnmem_region_idx == -1) && (dest_id == -1)) || ($test$plusargs("connectivity_testing") && addr_trans_mgr::check_unmapped_add(m_ace_write_addr_pkt.awaddr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)))begin
            isSMICMDReqNeeded = 0;
            isSMISTRReqNotNeeded = 1;
            addrNotInMemRegion = 1;
        end else if($test$plusargs("no_credit_check")) begin
            isSMICMDReqNeeded = 0;
            isSMISTRReqNotNeeded = 1;
            addrNotInMemRegion = 1;
        end else begin
            if (isWrite && !isAtomic) begin
                <%if(obj.useCache){%> 
                    isSMICMDReqNeeded = csr_ccp_lookupen ? 0 : 1;
                    isSMISTRReqNotNeeded = csr_ccp_lookupen ? 1 : 0;
                <%}else{%>
                    isSMICMDReqNeeded    = 1;
                    isSMISTRReqNotNeeded = 0;
                <%}%>
	            isPartialWrite = ((m_pkt.awlen + 1) < m_beats_in_a_cacheline) ? 1 : 0;
            end
            else if(isAtomic) begin
                //isSMIDTWReqNeeded = 1;  
                isSMICMDReqNeeded = 1; 
                is2ndSMICMDReqNeeded = isCoherentAtomic ? 1 : 0; 
                is2ndSMISTRReqNeeded = isCoherentAtomic ? 1 : 0; 
                if(m_ace_cmd_type == ATMSTR)
                    isSMIDTRReqNeeded = 0;
                else
                    isSMIDTRReqNeeded = 1;
            end     
        end
        if($test$plusargs("connectivity_testing") && addr_trans_mgr::check_unmapped_add(m_ace_write_addr_pkt.awaddr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type))begin
            isSMICMDReqNeeded    = 0;
            isSMIDTWReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;
            isSMISTRReqNotNeeded = 1;
        end

        if($test$plusargs("no_credit_check")) begin
            isSMICMDReqNeeded    = 0;
            isSMIDTWReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;
            isSMISTRReqNotNeeded = 1;
        end

        if ((m_ace_cmd_type === WRUNQ ||
	     m_ace_cmd_type === WRNOSNP) &&
            total_cacheline_count > 1
        ) begin
            isMultiLineMaster                   = 0;
            isMultiAccess                       = 1;
            multiline_order                     = 0;
            m_multiline_starting_write_addr_pkt = m_pkt;
            m_ace_write_addr_pkt.awlen          = m_awlen_tmp;
        end
         if(((!addrNotInMemRegion) && addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DII && (isCoherent || !(m_ace_cmd_type inside {WRNOSNP,WREVCT,WRBK,WRCLN})))
<%if(!obj.eAc && ((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E"))){ %> || ((m_ace_cmd_type == DVMMSG) && (m_ace_cmd_type == DVMCMPL))<%}%>) begin
            isSMICMDReqNeeded    = 0;
            isSMIDTWReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;
            is2ndSMICMDReqNeeded = 0;
            isSMIUPDReqNeeded    = 0;
            is2ndSMISTRReqNeeded = 0;
            illDIIAccess    = 1;
	    multiline_ready_to_delete = (isMultiAccess) ? 1 : 0;
        end
        if(mem_regions_overlap || addrNotInMemRegion) begin // For Addr Region Overlap test
            isSMICMDReqNeeded    = 0;
            isSMIDTWReqNeeded    = 0;
            isSMIDTRReqNeeded    = 0;
            is2ndSMICMDReqNeeded = 0;
            is2ndSMISTRReqNeeded = 0;
            isSMIUPDReqNeeded    = 0;
	    multiline_ready_to_delete = (isMultiAccess) ? 1 : 0;
        end
    <%if(obj.testBench == "fsys") { %>
        if(m_start_addr != {addrMgrConst::NRS_REGION_BASE[51:20],20'hF_F000}) 
    <%}else{%>
        if(m_start_addr != <%=obj.wAddr%><%=obj.CsrInfo.csrBaseAddress.replace("0x","'h")%>F_F000) 
    <%}%>   
            setup_dce_dmi_id_for_req();

         if (addrInCSRRegion) begin 
                 if ((<%=obj.AiuInfo[obj.Id].fnCsrAccess %> == 0) || //config supports CSR access
                     (m_ace_write_addr_pkt.awaddr[1:0] != 0) || //32-bit/4B size-aligned
                     (((m_ace_write_addr_pkt.awlen+1)*(2**m_ace_write_addr_pkt.awsize)) != 4) || //4B transfer
                     (m_ace_write_addr_pkt.awcache[1] != 0)) //EndpointOrder/Device txn
                illegalCSRAccess = 1;
      end
    <%if(obj.testBench == "fsys") { %>
	if (k_decode_err_illegal_acc_format_test_unsupported_size==1) begin
	    illegalCSRAccess = 1;
        end
    <%}%>   
        
        ///New 3.4 security feature, refer to Section 9.7 Ncore Security Extension in IOAIU uArch spec
		if ((m_security == 1) && (addrMgrConst::get_addr_gprar_nsx(m_sfi_addr) == 0) && !isDVM && !addrInCSRRegion && (m_ace_cmd_type != BARRIER)) begin 
			illegalNSAccess      = 1;
		end
        <%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
        //New 3.4 security feature, refer to Section 9.5 A transaction with a dii destination will return a decode error and not be sent to the dii if this bit is not set.                
	    if ((!addrNotInMemRegion) && (addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DII) && (addrMgrConst::get_addr_gprar_nc(m_sfi_addr) == 0) ) begin 
                illDIIAccess=1;
            end
        <%}%>
        if(illegalNSAccess      == 1 || illDIIAccess==1 || addrNotInMemRegion || illegalCSRAccess == 1) begin
            isSMICMDReqNeeded    = 0;
            isSMIDTWReqNeeded    = 0;
            isSMISTRReqNotNeeded = 1;

            //applies to atomics
            is2ndSMICMDReqNeeded  = 0;
            is2ndSMISTRReqNeeded  = 0;
            isSMIDTRReqNeeded     = 0;
        end
        if(isAtomic) begin	
       m_axi_resp_expected = new[int'($ceil((m_ace_write_addr_pkt.awlen + 1) / 2.0))];        
        end else begin
         m_axi_resp_expected = new[1];
        end
        foreach (m_axi_resp_expected[i]) begin
            //#Check.IOAIU.IllegaIOpToDII.DECERR 
            // #Check.IOAIU.illDIIAccess.DECERR
            //#Check.IOAIU.IllegalCSRaccess.DECERR
            //#Check.IOAIU.IllegalSecurityAccess.DECERR
            //#Check.IOAIU.MultipleAddrhit.DECERR
            //#Check.IOAIU.NoAddresshit.DECERR
            if(illDIIAccess || mem_regions_overlap || illegalNSAccess || illegalCSRAccess ) begin
	if( <%if(!(obj.eAc && ( (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")))){ %>((m_ace_cmd_type == DVMMSG) && (m_ace_cmd_type == DVMCMPL)) <%} else  {%> 0 <%}%>) 
                m_axi_resp_expected[i] = SLVERR;
	else
		m_axi_resp_expected[i] = DECERR;	
            end
            else if (addrNotInMemRegion) begin
                m_axi_resp_expected[i] = DECERR;
            end
        end
        m_ott_status = INACTIVE;
        m_ott_id     = -1;
    
        if (isCoherent) m_owo_wr_state = INV;
        else m_owo_wr_state = UCE;

    endfunction : setup_ace_write_req

    function void setup_ace_write_multiline_txn(ace_write_addr_pkt_t m_pkt, int count, int tmp_total_cacheline_count, int m_tracking_id);
        int  fnmem_region_idx;
        longint m_start_addr             = m_pkt.awaddr;
        int                                     m_num_bytes              = 2 ** m_pkt.awsize;
        int                                     m_burst_length           = m_pkt.awlen + 1;
        int                                     m_beats_in_a_cacheline   = SYS_nSysCacheline*8/DATA_WIDTH;
        longint m_aligned_addr           = (m_start_addr/(m_num_bytes * m_beats_in_a_cacheline)) * m_num_bytes * m_beats_in_a_cacheline; 
        bit                                     m_aligned                = 1;//(m_aligned_addr === m_start_addr);
        int                                     m_dtsize                 = m_num_bytes * m_burst_length;
        longint m_lower_wrapped_boundary = (m_start_addr/m_dtsize) * m_dtsize; 
        longint m_upper_wrapped_boundary = m_lower_wrapped_boundary + m_dtsize; 
        
        if (m_aligned) begin
            m_start_addr = m_aligned_addr + count * m_num_bytes * m_beats_in_a_cacheline;
            if (m_pkt.awburst === AXIWRAP) begin
                if (m_start_addr >= m_upper_wrapped_boundary) begin
                    m_start_addr = m_lower_wrapped_boundary + (m_start_addr - m_upper_wrapped_boundary);
                    //uvm_report_info ("CHIRAG WR DEBUG 1", $sformatf ("start address 0x%0x", m_start_addr), UVM_NONE);
                end
            end
            if((m_start_addr>>12) != (m_pkt.awaddr>>12)) // check for 4K boundary
                m_start_addr = {m_pkt.awaddr>>12,m_start_addr[11:0]};
        end

        m_ace_write_addr_pkt = new();
        m_ace_write_addr_pkt.copy(m_pkt);
	    m_axi_qos = m_ace_write_addr_pkt.awqos;
        m_axcache = m_ace_write_addr_pkt.awcache;
        if (count < tmp_total_cacheline_count - 1) begin
            m_ace_write_addr_pkt.awlen = m_beats_in_a_cacheline - 1;
            isMultiLineMaster          = 0;
        end
        else begin
            longint m_tmp_addrA = (((m_ace_write_addr_pkt.awaddr + (1 << SYS_wSysCacheline)) >> SYS_wSysCacheline) << SYS_wSysCacheline) ;
            int tmp_a = (m_ace_write_addr_pkt.awlen+1) - ($ceil(((int'(m_tmp_addrA)) - (int'(m_ace_write_addr_pkt.awaddr >> LOGWDATA << LOGWDATA))) / 2**(int'(m_ace_write_addr_pkt.awsize))));
            m_ace_write_addr_pkt.awlen = tmp_a % m_beats_in_a_cacheline;
            isMultiLineMaster          = 1;
            if (m_ace_write_addr_pkt.awlen === 0) begin
                m_ace_write_addr_pkt.awlen = m_beats_in_a_cacheline - 1;
            end
            else begin
                m_ace_write_addr_pkt.awlen -= 1;
            end
            //uvm_report_info("CHIRAG DEBUG", $sformatf("Address 0x%0x len 0x%0x tmp_a 0x%0x", m_ace_write_addr_pkt.awaddr, m_ace_write_addr_pkt.awlen, tmp_a), UVM_NONE);
        end
        m_ace_write_addr_pkt.awaddr         = m_start_addr;
        m_multiline_tracking_id             = m_tracking_id;
        m_multiline_starting_write_addr_pkt = m_pkt;
        m_sfi_addr                          = m_ace_write_addr_pkt.awaddr;
        m_id                                = m_ace_write_addr_pkt.awid;
        <%if(aiu_axiInt.params.wAwUser > 0){%>
            m_user               = m_ace_write_addr_pkt.awuser;
        <%}%>

        <%if(obj.wSecurityAttribute > 0){%>
            m_security = m_ace_write_addr_pkt.awprot[1];
        <%}else{%>    
            m_security = 0;
        <%}%>

        isWrite                             = 1;
        isACEWriteAddressRecd               = 1;
        isACEWriteDataNeeded                = 1;
        <%if(obj.useCache) { %> 
                isSMICMDReqNeeded    = (csr_ccp_lookupen)? 0 : 1;
                isSMISTRReqNotNeeded = csr_ccp_lookupen ? 1 : 0;
                           //Setup tag and index
            ccp_addr   = shift_addr(m_ace_write_addr_pkt.awaddr);
            ccp_index = addrMgrConst::get_set_index(m_ace_write_addr_pkt.awaddr,<%=obj.FUnitId%>);
        <%}else{%>    
            isSMICMDReqNeeded                   = 1;
        <%}%>
        isSMIUPDReqNeeded                   = 0;
        isSMIDTRReqNeeded                   = 0;
        t_creation                          = $time + count*1ps;
        t_latest_update                     = $time;
        t_ace_write_recd                    = $time + count*1ps;
        setup_ace_cmd_type();
        setup_gpra_order(m_ace_write_addr_pkt.awaddr);
        isUpdate              = 0;
        
        <%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
			isCoherent = (addrMgrConst::get_addr_gprar_nc(m_sfi_addr) == 1) ? 0 : 1;
        	<%if(obj.useCache) { %> 
        		isIoCacheTagPipelineNeeded = (this.csr_ccp_lookupen);
        	<%}%>
	    <%}else{%>    
			isCoherent = (m_ace_write_addr_pkt.awdomain inside {NONSHRBL, SYSTEM}) ? 0 : 1;
        <%}%>

        isMultiAccess         = 1;
        multiline_order       = count;
        total_cacheline_count = tmp_total_cacheline_count; 
        setup_dce_dmi_id_for_req();
        m_axi_resp_expected = new[1];
        dest_id = addrMgrConst::map_addr2dmi_or_dii(m_pkt.awaddr,fnmem_region_idx);
        if(((fnmem_region_idx == -1) && (dest_id == -1)) || ($test$plusargs("connectivity_testing") && addr_trans_mgr::check_unmapped_add(m_ace_write_addr_pkt.awaddr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)))begin
            isSMICMDReqNeeded = 0;
            isSMIDTWReqNeeded = 0;
            isSMISTRReqNotNeeded = 1;
            addrNotInMemRegion = 1;
        end
        if($test$plusargs("no_credit_check")) begin
            isSMICMDReqNeeded = 0;
            isSMIDTWReqNeeded = 0;
            isSMISTRReqNotNeeded = 1;
            addrNotInMemRegion = 1;
        end
        if(((!addrNotInMemRegion) && addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DII && (isCoherent || m_ace_cmd_type != WRNOSNP))) begin
                isSMICMDReqNeeded    = 0;
                isSMIDTWReqNeeded    = 0;
                illDIIAccess    = 1;
	        multiline_ready_to_delete = (isMultiAccess) ? 1 : 0;
        end
        if(mem_regions_overlap || addrNotInMemRegion) begin // For Addr Region Overlap test
            isSMICMDReqNeeded    = 0;
            isSMIDTWReqNeeded    = 0;
            multiline_ready_to_delete = (isMultiAccess) ? 1 : 0;
        end

        if (addrInCSRRegion) begin 
                 if ((<%=obj.AiuInfo[obj.Id].fnCsrAccess %> == 0) || //config supports CSR access
                     (m_ace_write_addr_pkt.awaddr[1:0] != 0) || //32-bit/4B size-aligned
                     (((m_ace_write_addr_pkt.awlen+1)*(2**m_ace_write_addr_pkt.awsize)) != 4) || //4B transfer
                     (m_ace_write_addr_pkt.awcache[1] != 0)) //EndpointOrder/Device txn
                illegalCSRAccess = 1;
      end
    <%if(obj.testBench == "fsys") { %>
	if (k_decode_err_illegal_acc_format_test_unsupported_size==1) begin
	    illegalCSRAccess = 1;
        end
    <%}%>   
        
        ///New 3.4 security feature, refer to Section 9.7 Ncore Security Extension in IOAIU uArch spec
		if ((m_security == 1) && (addrMgrConst::get_addr_gprar_nsx(m_sfi_addr) == 0) && !isDVM && !addrInCSRRegion) begin 
			illegalNSAccess      = 1;
		end
        <%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
        //New 3.4 security feature, refer to Section 9.5 A transaction with a dii destination will return a decode error and not be sent to the dii if this bit is not set.                
	    if ((!addrNotInMemRegion) && (addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DII) && (addrMgrConst::get_addr_gprar_nc(m_sfi_addr) == 0) ) begin 
                illDIIAccess=1;
            end
        <%}%>
        if(illegalNSAccess      == 1 || illDIIAccess==1 || addrNotInMemRegion || illegalCSRAccess == 1) begin
            isSMICMDReqNeeded    = 0;
            isSMIDTWReqNeeded    = 0;
            isSMISTRReqNotNeeded = 1;
	        multiline_ready_to_delete = (isMultiAccess) ? 1 : 0;
	end
       	
        foreach (m_axi_resp_expected[i]) begin
            //#Check.IOAIU.IllegaIOpToDII.DECERR  #Check.IOAIU.illDIIAccess.DECERR #Check.IOAIU.illegalNSAccess_Write_DECERR
            if(illDIIAccess || mem_regions_overlap || illegalNSAccess || illegalCSRAccess ) begin
	if( <%if(!(obj.eAc && ( (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")))){ %>((m_ace_cmd_type == DVMMSG) && (m_ace_cmd_type == DVMCMPL)) <%} else  {%> 0 <%}%>) 
                m_axi_resp_expected[i] = SLVERR;
	else
		m_axi_resp_expected[i] = DECERR;	
            end
            else if (addrNotInMemRegion) begin
                m_axi_resp_expected[i] = DECERR;
            end
        end
        m_ott_status = INACTIVE;
        m_ott_id     = -1;
        
        if (isCoherent) m_owo_wr_state = INV;
        else m_owo_wr_state = UCE;
    endfunction : setup_ace_write_multiline_txn
    //#Check.IOAIU.OTTUnCorrectableErr.RResp_SLVERR 
       function void predict_ott_error_rresp();

         foreach (m_ace_read_data_pkt.rresp_per_beat[i]) begin
         if(m_ace_read_data_pkt.rdata[i] inside {error_data_q} && m_ace_read_data_pkt.rdata[i] != 0)
         m_axi_resp_expected[i] = SLVERR;
        end
        
        endfunction: predict_ott_error_rresp
       
         function void predict_excops_rresp();

        	axi_bresp_enum_t exp_rresp;
            foreach (m_ace_read_data_pkt.rresp_per_beat[i]) begin:_loop_through_each_beat_
				exp_rresp = axi_bresp_enum_t'(m_axi_resp_expected[i][1:0]);
                       
				//assumption is rresp was already predicted due to error scenarios.
    			if (!(exp_rresp inside {DECERR, SLVERR})) begin: _no_error_

					if (!(m_ace_cmd_type inside {RDNOSNP, RDCLN, RDSHRD, CLNUNQ}) || (m_ace_read_addr_pkt.arlock != EXCLUSIVE))
						return;

					if (m_ace_cmd_type == RDNOSNP && !isSMIDTRReqRecd)
						return;

					if (m_ace_cmd_type == RDNOSNP) begin: _noncoh_read_exc_
						if(m_dtr_req_pkt.smi_cmstatus_exok == 1) begin
							m_axi_resp_expected[i] = EXOKAY;
						end
					end: _noncoh_read_exc_
					else begin: _coh_read_exc
						if (!isSMISTRReqRecd)
        					`uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $psprintf("IOAIU_UID:%0d RResp is returned before an STRreq is received for an coherent exclusive transaction", tb_txnid))

						if(m_str_req_pkt.smi_cmstatus_exok == 1) begin
							m_axi_resp_expected[i] = EXOKAY;
						end
					end: _coh_read_exc
                end: _no_error_
            end:_loop_through_each_beat_
	
        endfunction : predict_excops_rresp
        //#Check.IOAIU.DECERR
        //#Check.IOAIU.SLVERR
	function void check_rresp();
   	axi_bresp_enum_t actual_rresp;
    	axi_bresp_enum_t exp_rresp;
        if((isAtomic && m_ace_cmd_type inside{ATMLD,ATMSWAP,ATMCOMPARE}) && isSMIDTWReqNeeded)begin
          if(!isSMIDTWReqSent)begin
          `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> RResp send before the DTWReq", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))
          end
        end

  		foreach (m_ace_read_data_pkt.rresp_per_beat[i]) begin
        	actual_rresp = axi_bresp_enum_t'(m_ace_read_data_pkt.rresp_per_beat[i][1:0]);
        	exp_rresp 	 = axi_bresp_enum_t'(m_axi_resp_expected[i][1:0]);

    <%if(obj.testBench == "fsys") { %>
			if (actual_rresp != m_axi_resp_expected[i] && k_decode_err_illegal_acc_format_test_unsupported_size==0)
    <%} else {%>   
			if (actual_rresp != m_axi_resp_expected[i])
    <%} %>   
                if($test$plusargs("address_error_test_ott")) begin
                   rresp_mismatch_count++;
                   if(rresp_mismatch_count > 1) begin
                      `uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("rresp_mismatch_count=%0d",rresp_mismatch_count),UVM_LOW)
                      `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> RResp Mismatch for Beat:%0d Expected:%0p Actual:%0p", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, i, exp_rresp, actual_rresp))
                   end
                end
                else begin
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> RResp Mismatch for Beat:%0d Expected:%0p Actual:%0p", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, i, exp_rresp, actual_rresp))
                end
             <% if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5") { %>
       		//#Check.IOAIU.ACE.RRESP
                if (actual_rresp[i] inside {DECERR,SLVERR} && m_ace_read_data_pkt.rresp_per_beat[i][3:2] != 0) begin
       		`uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $psprintf("IOAIU_UID:%0d For ACE interface RResp[3:2] should be zero if rresp inside %0p", tb_txnid, i,actual_rresp))
       		end
      	     <%}%>
	end

     
	endfunction: check_rresp
	
	function void check_num_rdata_beats();

            // Check to see if Clean/Make read address channel requests have only one beat of read response on read data channel
            if (m_ace_cmd_type inside {CLNUNQ, MKUNQ, CLNSHRD, CLNSHRDPERSIST, CLNINVL, MKINVL, DVMMSG, DVMCMPL}) begin
                if (m_ace_read_data_pkt.rdata.size() !== 1) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d ACE read data response should be only 1 beat for cmd_type:%0p but it was %0d", tb_txnid, m_ace_cmd_type, m_ace_read_data_pkt.rdata.size()), UVM_NONE);
                end
	    end 
            else if (isAtomic) begin 
	        if(m_ace_read_data_pkt.rdata.size() !== int'($ceil((m_ace_write_addr_pkt.awlen + 1)/2.0))) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d ACE read data response should be %0d beat(s) for cmd_type:%0p but it was %0d", tb_txnid, $ceil((m_ace_write_addr_pkt.awlen + 1)/2.0), m_ace_cmd_type, m_ace_read_data_pkt.rdata.size()), UVM_NONE);
                end 
	    end 
            else begin 
                //each split of a 512b owo is just one beat since it is a full cacheline
                if (owo_512b) begin 
                    if (m_ace_read_data_pkt.rdata.size() != 1)
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d read data response should be always one beat for every split txn in owo_512b, but %0d beats are seen", tb_txnid, m_ace_read_data_pkt.rdata.size()));
                end
                else begin  
                    if (m_ace_read_data_pkt.rdata.size() !== int'((m_ace_read_addr_pkt.arlen + 1))) begin
                       `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d read data response num_beats:%0d native read txn arlen:%0d", tb_txnid, m_ace_read_data_pkt.rdata.size(), m_ace_read_addr_pkt.arlen));
                    end
                end
	    end 

	<%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %> 
        	if (csr_ccp_lookupen && csr_ccp_allocen) begin
        		if (is_ccp_hit && isCCPReadHitDataRcvd) begin     
                	if (m_ace_read_data_pkt.rdata.size() !== m_io_cache_data.size()) begin
                            print_me();
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> AXI4 read data beats should match cache hit read data beats (AXI4:%s CCP_RDRSP:%p)",  tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ace_read_data_pkt.sprint_pkt(), m_io_cache_data), UVM_NONE);
                    end
                end
            end
    <%}%>
					

	endfunction: check_num_rdata_beats


	function void check_rdata();
       
       	bit data_check_needed;

        if ((m_ace_cmd_type inside { CLNUNQ, MKUNQ, CLNSHRD, CLNSHRDPERSIST, CLNINVL, MKINVL, DVMMSG, DVMCMPL}) == 0) begin
    		foreach (m_ace_read_data_pkt.rresp_per_beat[i]) begin
        		if(m_ace_read_data_pkt.rresp_per_beat[i] inside {OKAY,EXOKAY}) begin
               		data_check_needed = 1;
            	end
        	end
        end
              	
        if(data_check_needed == 0 || $test$plusargs("write_address_error_test_ott"))
        	return;

    	<%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %> 
        	if (csr_ccp_lookupen && is_ccp_hit && isCCPReadHitDataRcvd) begin: _proxycache_enabled_ccp_hit 
                	foreach (m_io_cache_data[i]) begin
                    	if (m_ace_read_data_pkt.rdata[i] !== m_io_cache_data[i]) begin
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> AXI4 Read data packet for IO cache hit has wrong read data (Expected:0x%0x Actual: 0x%0x beat:0x%0x) %p", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_io_cache_data[i], m_ace_read_data_pkt.rdata[i], i, m_io_cache_data), UVM_NONE);
                        end
                    end
			end: _proxycache_enabled_ccp_hit
			else begin: _not_proxycache_enabled_ccp_hit
        <% } %>
				if (isSMIDTRReqNeeded) begin 
					if (isSMIDTRReqRecd) //in cases where complete DTRReq pkt is not yet received by scb, check the nativeInterface RdData when DTRReq packet comes in. 
						compare_smi_axi_data();
				end else begin 
        			<%if(obj.testBench == "fsys") { %>
						//if((isSMICMDReqNeeded==1) || (isSMICMDReqSent==1) || (is_ccp_hit==1) || (addrInCSRRegion==0)) 
			    		if(addrInCSRRegion==0 && addrNotInMemRegion==0) 
					<%}%> 
                			uvm_report_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> No data checks for this transaction?", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>));
				end

    	<%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %> 
			end: _not_proxycache_enabled_ccp_hit
        <% } %>

	endfunction: check_rdata


    function void setup_ace_read_data(ace_read_data_pkt_t m_pkt);

    	//Setup appropriate flags, and packet assignment
        if(isDVMMultiPart && isACEReadDataSent) begin
	        isACEReadDataDVMMultiPartSent = 1;
            t_ace_read_data_dvm_multipart_sent = $time;
            m_ace_read_data_pkt2 = m_pkt;
        end
        else begin
            m_ace_read_data_pkt = new();
            m_ace_read_data_pkt.copy(m_pkt);
            isACEReadDataSent    = 1;
            t_ace_read_data_sent = $time;
        end
        t_latest_update      = $time;

        if(predict_ott_data_error == 1)
			predict_ott_error_rresp();

	
<% if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5") { %>
		//rd_data/rresp is sent on nativeInterface as soon as the critical beat is received from DTRreq, hence it is possible that all DTRreq beats are not received by the time RdData/RResp is sent.
		//Hence rresp is checked both at rddata/rresp as well as DTRreq, if and when both packets are available. 
		if (!isSMIDTRReqNeeded || isSMIDTRReqRecd)
			check_rresp_for_ace();
<%}%>
		
	if (!isSMIDTRReqNeeded || isSMIDTRReqRecd) begin
  		predict_excops_rresp();
		check_rresp();
	end else begin 
		check_rresp_on_dtrreq =1;
	end



		check_num_rdata_beats();
		check_rdata();


    endfunction : setup_ace_read_data

    function void setup_ace_write_data(ace_write_data_pkt_t m_pkt);
        bit [DATA_WIDTH-1:0] data[];
        bit [DATA_WIDTH/8-1:0] strb[];
        int size = m_ace_write_addr_pkt.awsize;
        int len = m_ace_write_addr_pkt.awlen;
        smi_addr_t addr = m_ace_write_addr_pkt.awaddr; 
        m_ace_write_data_pkt = new();
        m_ace_write_data_pkt.copy(m_pkt);
        isACEWriteDataRecd    = 1;
        t_latest_update       = $time;
        t_ace_write_data_recd = $time;
        isPartialWrite        = 0;

        `uvm_info("<%strRtlNamePrefix%> SCB TXN", $sformatf("IOAIU_UID:%0d WrData: %s", tb_txnid, m_ace_write_data_pkt.sprint_pkt()), UVM_LOW);

        if (m_ace_write_data_pkt.wdata.size() !== ((SYS_nSysCacheline*8)/DATA_WIDTH)) begin
            isPartialWrite = 1;
        end
        else begin
            foreach (m_ace_write_data_pkt.wstrb[i]) begin
                if ($countones(m_ace_write_data_pkt.wstrb[i]) != (DATA_WIDTH/8)) begin
                    isPartialWrite = 1;
                    break;
                end
            end
        end
    endfunction : setup_ace_write_data

    function void setup_ace_write_resp(ace_write_resp_pkt_t m_pkt);
        m_ace_write_resp_pkt = new();
        m_ace_write_resp_pkt.copy(m_pkt);
        isACEWriteRespSent    = 1;
        t_latest_update       = $time;
        t_ace_write_resp_sent = $time;
              
        if((dtwrsp_cmstatus_err || hasFatlErr || dtrreq_cmstatus_err) && is2ndSMICMDReqNeeded && !is2ndSMICMDReqSent) begin
        is2ndSMICMDReqNeeded = 0;
        end
        
		if (isSMICMDReqNeeded && !isSMISTRReqRecd && !dtwrsp_cmstatus_err && !hasFatlErr && !dtrreq_cmstatus_err && !tagged_decerr)
        	`uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> nativeInterface WrResp cannot be sent before the write transaction reaches point of visibility ie STRReq is received", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))

		predict_excops_bresp();
        if(m_ace_write_addr_pkt.awlock == EXCLUSIVE && !(m_ace_write_resp_pkt.bresp[1:0] inside {DECERR,SLVERR}) && isMultiAccess)
        begin
           uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("MultiAccess Exclusive 128B transaction"), UVM_HIGH);
        end else
        check_bresp();

//      RTL Team says Bresp seems to be held waiting for strRsp to be queued (internally), so we can never have a strict timing dependency between BResp and STRrsp
//        if (is2ndSMICMDReqSent && !is2ndSMISTRRespSent) begin 
//        	`uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> nativeInterface WrResp cannot be sent before the 2nd STRresp is sent", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))
//        end
//        
    endfunction : setup_ace_write_resp

   //#Check.IOAIU.DECERR
   //#Check.IOAIU.SLVERR
   function void check_bresp();
   		axi_bresp_enum_t actual_bresp;
          	axi_bresp_enum_t exp_bresp;

        	actual_bresp = axi_bresp_enum_t'(m_ace_write_resp_pkt.bresp[1:0]);
        	exp_bresp 	 = axi_bresp_enum_t'(m_axi_resp_expected[0][1:0]);
                //commenting wrong if condition CONC-11268
                //if(m_ace_write_addr_pkt.awlock != EXCLUSIVE )    // CONC-10646, proper checks for exclusive already in scoreboard, so ignoring here
                //begin
	        if(!((dtwrsp_cmstatus_err==1 || dtrreq_cmstatus_err==1 || dtr_req_dbad_high == 1) && (isAtomic && m_ace_cmd_type inside{ATMLD,ATMSWAP,ATMCOMPARE}))) begin //CONC-11655 RTL was not Propagating error Correctly for atomic txn // CONC-16994 for Atomics Bresp is dont care for ATMLD/ATMCOMP/ATMSWAP with dtwrsp,dtreq error
 		  if(actual_bresp != exp_bresp)
            	 `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> BResp Mismatch for Expected:%0p Actual:%0p", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, exp_bresp, actual_bresp))
                end
                //end
     endfunction: check_bresp 

     function void predict_excops_bresp();
    	axi_bresp_enum_t exp_bresp = axi_bresp_enum_t'(m_axi_resp_expected[0][1:0]);

		//assumption is bresp was already predicted due to error scenarios.
    	if (exp_bresp inside {DECERR, SLVERR})
    		return;

		//exclusive response on write channel can only be due to non-coherent exclusive write.
		if (m_ace_write_addr_pkt.awlock != EXCLUSIVE || m_ace_cmd_type != WRNOSNP)
			return;

		//TODO: Need Arch resolution in CONC-10749
		if (isSMIDTWRespRecd == 0) begin
        	`uvm_warning("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Exclusive non-coherent write transaction has not received DTWResp to predict the result of exclusive access, this is possible due to IO Cache hits, current RTL sends EXOKAY", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))
        	foreach (m_axi_resp_expected[i])
        		m_axi_resp_expected[i] = EXOKAY;
        	return;
		end 

        foreach (m_axi_resp_expected[i]) begin
			if (m_dtw_rsp_pkt.smi_cmstatus_exok == 1) 
        		m_axi_resp_expected[i] = EXOKAY;
			else 
        		m_axi_resp_expected[i] = OKAY;
		end
     endfunction : predict_excops_bresp

    function void setup_ace_snoop_addr(ace_snoop_addr_pkt_t m_pkt);
        axi_axaddr_t exp_acaddr;
        m_ace_snoop_addr_pkt = new();
        m_ace_snoop_addr_pkt.copy(m_pkt);
        isACESnoopReqSent = 1;
        t_ace_snoop_sent  = $time;
        t_latest_update   = $time;

        if (m_ace_snoop_addr_pkt.acsnoop == ACE_DVM_CMPL) begin
            if (m_ace_snoop_addr_pkt.acaddr != 0)
	        `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("IOAIU_UID:%0d ACE Snoop Addr for DVMCMPL is not 0 but 0x%0x", tb_txnid, m_ace_snoop_addr_pkt.acaddr));
        end 
        <% if(obj.fnNativeInterface == "ACE"|| obj.fnNativeInterface == "ACE5") { %>
        else begin 
            if(m_ace_snoop_addr_pkt.acaddr[$clog2(<%=obj.wCdData%>/8)-1:0] != 0) begin
	        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("IOAIU_UID:%0d ACE Snoop Addr is not aligned to Snoop data bus width. ACE CD Channel Data width is %0d, ACADDR is 0x%0x", tb_txnid, <%=obj.wCdData%>, m_ace_snoop_addr_pkt.acaddr));
            end
            if((<%=obj.wCdData%>/64) >= (2**m_snp_req_pkt.smi_intfsize)) begin
                exp_acaddr = m_snp_req_pkt.smi_addr[<%=obj.wAddr%>-1:$clog2(<%=obj.wCdData%>/8)]<<$clog2(<%=obj.wCdData%>/8);
            end else begin
                exp_acaddr = (m_snp_req_pkt.smi_addr>>(3+m_snp_req_pkt.smi_intfsize))<<(3+m_snp_req_pkt.smi_intfsize);
            end
            if(exp_acaddr != m_ace_snoop_addr_pkt.acaddr) begin
    	        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("IOAIU_UID:%0d ACE Snoop Addr doesn't match the expectation. Expect ACADDR is 0x%0x, Real ACADDR is 0x%0x", tb_txnid, exp_acaddr, m_ace_snoop_addr_pkt.acaddr));
            end
        end
        <% } %>
    endfunction : setup_ace_snoop_addr

    function void setup_ace_snoop_resp(ace_snoop_resp_pkt_t m_pkt);
        m_ace_snoop_resp_pkt = new();
        m_ace_snoop_resp_pkt.copy(m_pkt);
        isACESnoopRespRecd    = 1;
        WU_DT_PD_IS = { m_pkt.crresp[CCRRESPWASUNIQUEBIT],
                        m_pkt.crresp[CCRRESPDATXFERBIT],
                        m_pkt.crresp[CCRRESPPASSDIRTYBIT],
                        m_pkt.crresp[CCRRESPISSHAREDBIT]};
        t_ace_snoop_resp_recd = $time;
        if(m_ace_cmd_type != DVMMSG)
            setup_sfi_snoop_data_expected();
        t_latest_update       = $time;
    endfunction : setup_ace_snoop_resp

    function void setup_ace_snoop_data(ace_snoop_data_pkt_t m_pkt);
        m_ace_snoop_data_pkt = new();
        m_ace_snoop_data_pkt.copy(m_pkt);
        isACESnoopDataRecd    = 1;
        t_latest_update       = $time;
        t_ace_snoop_data_recd = $time;
    endfunction : setup_ace_snoop_data

    extern  function void setup_cmd_req(smi_seq_item m_pkt);
    extern  function void setup_snp_req(smi_seq_item m_pkt);   
    extern  function void setup_upd_req(smi_seq_item m_pkt);      
    extern  function void add_cmd_resp(smi_seq_item m_pkt);      
    extern  function void add_cmp_resp(smi_seq_item m_pkt);      
    extern  function void add_upd_resp(smi_seq_item m_pkt);      
    extern  function void add_str_req(smi_seq_item m_pkt);      
    extern  function void add_str_resp(smi_seq_item m_pkt);      
    extern  function void add_dtr_req(smi_seq_item m_pkt);      
    extern  function void add_dtr_resp(smi_seq_item m_pkt);      
    extern  function void add_dtw_req(smi_seq_item m_pkt,string id = "");      
    extern  function void add_dtw_resp(smi_seq_item m_pkt);
    extern  function void add_snp_dtr_req(smi_seq_item m_pkt);   
    extern  function void add_snp_dtr_resp(smi_seq_item m_pkt);   
    extern  function void add_snp_resp(smi_seq_item m_pkt);  
    extern  function int  isComplete();

    <%if(obj.useCache){%> 
        extern  function bit  isWriteHitFull();   
        function void setup_io_cache_evict(ccp_ctrl_pkt_t m_pkt, axi_axqos_t qos = 0, ace_read_addr_pkt_t read_addr_pkt=null, ace_write_addr_pkt_t write_addr_pkt=null);
            string temp_sftype       = "<%=sftype%>";
            m_ccp_ctrl_pkt           = m_pkt;
            t_creation               = $time;
            t_latest_update          = $time;
            t_ccp_ctrl_pkt           = $time;
            m_sfi_addr               = m_ccp_ctrl_pkt.evictaddr;
            ccp_addr                 = shift_addr(m_ccp_ctrl_pkt.evictaddr);
            m_axi_qos                = qos;
            ccp_index                = addrMgrConst::get_set_index(m_ccp_ctrl_pkt.evictaddr,<%=obj.FUnitId%>);
            m_security               = m_ccp_ctrl_pkt.evictsecurity;
            isIoCacheTagPipelineSeen = 1;
            isIoCacheEvict           = 1;
	    isCoherent = (addrMgrConst::get_addr_gprar_nc(m_sfi_addr) == 1) ? 0 : 1;

            //if (read_addr_pkt != null) begin
            //    m_axcache = read_addr_pkt.arcache;
            //        opcode_for_evict = {read_addr_pkt.ardomain, read_addr_pkt.arsnoop};
            //    <%if(aiu_axiInt.params.wArUser > 0){%>
            //        m_user               = read_addr_pkt.aruser;
            //    <%}%>
            //end else if(write_addr_pkt != null) begin
            //        opcode_for_evict = {write_addr_pkt.awatop, write_addr_pkt.awdomain, write_addr_pkt.awsnoop};
            //    m_axcache = write_addr_pkt.awcache;
            //    <%if(aiu_axiInt.params.wAwUser > 0){%>
            //        m_user               = write_addr_pkt.awuser;
            //    <%}%>
            //end

            m_ott_status = INACTIVE;
            m_ott_id     = -1;
            
			//#Check.IOAIU.WritebackOnlyForDirty
            //#Check.IOAIU.UPDReqForSCSDUCUD
            if (m_ccp_ctrl_pkt.evictstate != IX) begin 
                isIoCacheEvictNeeded = 1;
                isSMIUPDReqNeeded = (csr_ccp_updatedis == 0 && isCoherent) ? 1 : 0;
                if (m_ccp_ctrl_pkt.evictstate inside {SD,UD}) begin 
                    isSMICMDReqNeeded = 1;
                    isSMISTRReqNotNeeded = 0;
                    isSMIDTWReqNeeded = 1;
                end
            	setup_dce_dmi_id_for_req();
            end 

            //#Check.IOAIU.CCPCtrlPkt.PortSelEvict
            if (m_ccp_ctrl_pkt.rsp_evict_sel != 1 && !m_ccp_ctrl_pkt.isMntOp)
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> ccp_top.ctrl_op_port_sel_p2 should be 1 for CCP Eviction", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))
			
        endfunction : setup_io_cache_evict

        function void setup_io_cache_evict_data(ccp_evict_pkt_t m_pkt);
            m_ccp_evict_pkt      = m_pkt;
            t_latest_update      = $time;
            t_ccp_evict_pkt      = $time;
            m_io_cache_data      = new[m_pkt.data.size()];
            m_io_cache_data      = m_pkt.data;
            m_smi_data_be        = new[m_pkt.data.size()];
            m_io_cache_dat_err   = new[m_pkt.data.size()];

            isIoCacheDataPipelineSeen = 1;
            isIoCacheEvictDataRcvd = 1;
            foreach (m_smi_data_be[i]) begin
                if (m_pkt.poison[i] === 1 && isSMIDTWReqNeeded === 1) begin
                    m_io_cache_dat_err[i]          = 1;
                    m_io_cache_only_data_err_found = 1;
                end
                else begin
                    m_io_cache_only_data_err_found = 0;
                end
                m_smi_data_be[i]               = 1;// CONC-6860, only DBAD is sufficient , no need for BE to be 0
            end
        //#Check.IOAIU.CCPEvict.ByteEn
        if(m_io_cache_data.size() > 0)begin
           //`uvm_info("CHECK  BYTEEN","DATA.SIZE>0",UVM_LOW) 
            for (int i = 1; i < m_io_cache_data.size(); i++) begin
               foreach(m_pkt.byten[i][j])begin
                  if(m_pkt.byten[i][j]!=1'b1)begin
                     `uvm_error("<%=obj.strRtlNamePrefix%> SCB",$sformatf("cache_evict_byteen: Exp:%0d Act:%0b",1,m_pkt.byten[i][j]))
                  end
               end
            end
        end
        endfunction : setup_io_cache_evict_data

        function void setup_io_cache_snoop(ccp_ctrl_pkt_t m_pkt);
            m_ccp_ctrl_pkt        = m_pkt;
            t_latest_update       = $time;
            t_ccp_ctrl_pkt        = $time;
            isIoCacheTagPipelineSeen = 1;
            if(!isSnpHitEvict && !m_pkt.nackuce) begin
                setup_sfi_snoop_data_expected_for_iocache();
                check_snoop_state_change();
            end
            if (m_pkt.nackuce) begin
                m_snp_addr_err_expected = 1;
                m_io_cache_only_data_err_found = 0;
            end

            //#Check.IOAIU.CCPCtrlPkt.PortSelSnoopData
            if (m_ccp_ctrl_pkt.rsp_evict_sel == 0)
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> ccp_top.ctrl_op_port_sel_p2 should be 1 for CCP SnoopData", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))

        endfunction : setup_io_cache_snoop

        function void setup_io_cache_snoop_data(ccp_evict_pkt_t m_pkt);
            m_ccp_evict_pkt           = m_pkt;
            m_io_cache_data           = new[m_pkt.data.size()];
            m_smi_data_be             = new[m_pkt.data.size()];
            m_io_cache_dat_err        = new[m_pkt.data.size()];
            m_io_cache_data           = m_pkt.data;
            t_ccp_evict_pkt           = $time;
            isIoCacheDataPipelineSeen = 1;
            // #Check.IOAIU.CCPSnoop.ByteEn
            foreach (m_smi_data_be[i]) begin
                if (m_pkt.poison[i] === 1 && (isSMIDTWReqNeeded === 1 || isSMISNPDTRReqNeeded === 1)) begin
                    m_io_cache_dat_err[i]          = 1;
                    m_io_cache_only_data_err_found = 1;
                end
                else begin
                    m_io_cache_dat_err[i]          = 0;
                end
                m_smi_data_be[i]               = 1;// CONC-6860, only DBAD is sufficient , no need for BE to be 0
            end
            // #Check.IOAIU.CCPSnoop.ByteEn
            if(m_io_cache_data.size() > 0)begin
               //`uvm_info("CHECK  BYTEEN","DATA.SIZE>0",UVM_LOW) 
                for (int i = 1; i < m_io_cache_data.size(); i++) begin
                   foreach(m_pkt.byten[i][j])begin
                      if(m_pkt.byten[i][j]!=1'b1)begin
                         `uvm_error("<%=obj.strRtlNamePrefix%> SCB",$sformatf("cache_snoop_byteen: Exp:%0d Act:%0b",1,m_pkt.byten[i][j]))
                      end
                   end
                end
            end

        endfunction : setup_io_cache_snoop_data

        function void setup_io_cache_read(ccp_ctrl_pkt_t m_pkt);
            m_ccp_ctrl_pkt           = m_pkt;
            t_latest_update          = $time;
            t_ccp_ctrl_pkt           = $time;
            isIoCacheTagPipelineSeen = 1;
            m_ace_cmd_type_io_cache  = m_ace_cmd_type;
        
            if(is_ccp_hit) begin
                ccp_way   = onehot_to_binary(m_pkt.hitwayn);
                //#Check.IOAIU.CCPCtrlPkt.PortSelCacheHit
                if( m_pkt.rd_data & m_pkt.rsp_evict_sel) begin
                   print_me();
                  `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Cache hit, ccp_top.ctrl_op_port_sel_p2 should be Set zero to route output data to read response port", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))
                end
            end
            
            if(wasSleeping)
                wasSleeping=0;	       

            if((addrNotInMemRegion && !addrInCSRRegion) || 
            	(addrInCSRRegion && isSelfIDRegAccess) ||
            	illDIIAccess || 
            	mem_regions_overlap) begin
            	isSMICMDReqNeeded = 0;
            end else begin
            	if(m_ccp_ctrl_pkt.alloc && !m_pkt.nackuce) begin
                    ccp_way   = m_pkt.wayn;
                    isFillReqd = 1'b1;
                    isFillDataReqd = 1'b1;
                    isSMICMDReqNeeded = 1;
                     isSMISTRReqNotNeeded = 0;
            	end else if((m_ccp_ctrl_pkt.alloc == 0 || m_pkt.nackuce) && (is_ccp_hit == 0)) begin
                    isSMICMDReqNeeded = 1;
                      isSMISTRReqNotNeeded = 0;
            	end
            end

            if(m_pkt.rd_data & !m_pkt.rsp_evict_sel) begin
                isCCPReadHitDataNeeded = 1;	       
            end
            else begin
                isCCPReadHitDataNeeded = 0;
            end
        
            if (m_pkt.nackuce) begin
                m_io_cache_only_data_err_found = 0;
                isSMISTRReqNotNeeded = 0;
            end
            m_io_cache_only_data_err_found = 0;
            
        endfunction : setup_io_cache_read

        function void setup_io_cache_read_data(ccp_rd_rsp_pkt_t m_pkt);
            axi_xdata_t          cpy_sfi_data[];
            bit                  cpy_poison[];
            axi_xdata_t          ccp_data[];
            bit                  ccp_poison[];
            axi_axaddr_t         addr;
            bit [$clog2(CACHELINE_SIZE)-1:0] sfi_data_beat;
            bit [$clog2(CACHELINE_SIZE)-1:0] data_beat;
            int no_of_bytes;
            int burst_length;
            string sprint_pkt;
            longint m_lower_wrapped_boundary;
            longint m_upper_wrapped_boundary;
            longint m_start_addr;	       
            longint cacheline_scratch = CACHELINE_SIZE; 
            int data_size;

            m_ccp_rd_rsp_pkt          = m_pkt;
            t_latest_update           = $time;
            t_ccp_read_rsp_pkt        = $time;
            isIoCacheDataPipelineSeen = 1;
            isCCPReadHitDataRcvd      = 1;

            no_of_bytes               = (DATA_WIDTH/8);
            burst_length              = m_ace_read_addr_pkt.arlen+1;

            if(m_ace_read_addr_pkt.arburst == 'h2 && !isMultiAccess) begin : if_arburst_2
                addr                      = m_sfi_addr;
                data_size                 = CACHELINE_SIZE;
                sfi_data_beat        = addr[LINE_INDEX_HIGH:LINE_INDEX_LOW];
                cpy_sfi_data         = new[data_size];
                cpy_poison           = new[data_size];

                for(int i=0; i<data_size;i++) begin
                    cpy_sfi_data[sfi_data_beat] = m_pkt.data[i];
                    cpy_poison[sfi_data_beat]   = m_pkt.poison[i];
                    sfi_data_beat               = sfi_data_beat + 1'b1;
                end
                ccp_data    = cpy_sfi_data;
                ccp_poison  = cpy_poison;

                //Caclulate the Wrap address based on the AXI spec
                m_start_addr             = ((addr/(DATA_WIDTH/8)) * (DATA_WIDTH/8));
                m_lower_wrapped_boundary = ((addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length)); 
                m_upper_wrapped_boundary = m_lower_wrapped_boundary + (no_of_bytes * burst_length); 

                //Update the cacheline data
                data_beat          = addr[LINE_INDEX_HIGH:LINE_INDEX_LOW];
                m_io_cache_data    = new[burst_length];
                m_io_cache_dat_err = new[m_io_cache_data.size()];

                for(int i=0; i<burst_length;i++) begin : for_burst_length
                    if((m_ace_read_addr_pkt.arburst == 'h2) && (m_start_addr >= m_upper_wrapped_boundary) ) begin
                        data_beat = m_lower_wrapped_boundary[LINE_INDEX_HIGH:LINE_INDEX_LOW];
                    end 
                    
                    if((m_ace_read_addr_pkt.arburst == 'h2) && (m_start_addr >= m_upper_wrapped_boundary) ) begin
                        m_start_addr = m_lower_wrapped_boundary;
                    end else begin
                        m_start_addr = m_start_addr + no_of_bytes;
                    end
                    m_io_cache_data[i]    =  ccp_data[data_beat];
                    m_io_cache_dat_err[i] = ccp_poison[data_beat];
                    data_beat = data_beat +  1'b1;
                end : for_burst_length
            end : if_arburst_2
            else begin
                m_io_cache_data = new[m_pkt.data.size()];
                m_io_cache_data = m_pkt.data;

                if (m_ccp_ctrl_pkt.currstate != IX) begin
                    m_io_cache_dat_err = new[m_io_cache_data.size()];
                    foreach (m_io_cache_dat_err[i]) begin
                        m_io_cache_dat_err[i] = m_pkt.poison[i];
                    end
                end
            end

            if((m_ace_read_addr_pkt.arlen+1) != m_io_cache_data.size()) begin
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("m_iocache_data %p",m_io_cache_data),UVM_NONE)
                print_me();
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Mismatch is Arlen size and data received from CCP"))
            end

            foreach (m_io_cache_dat_err[i]) begin
                if (m_io_cache_dat_err[i]) begin
                    if (m_axi_resp_expected[i] < SLVERR) begin
                        m_axi_resp_expected[i]        = SLVERR;
                        m_io_cache_only_data_err_found = 1;
                    end
                end
            end
            m_io_cache_only_data_err_found = 0;

           //#Check.IOAIU.CCPRdRsp.ByteEn
           if(m_io_cache_data.size() > 0)begin
               for (int i = 1; i < m_io_cache_data.size(); i++) begin
                  foreach(m_pkt.byten[i][j])begin
                      if(m_pkt.byten[i][j]!=1'b1)begin
                          `uvm_error("<%=obj.strRtlNamePrefix%> SCB",$sformatf("RRDRSP_byteen: Exp:%0d Act:%0d",1,m_pkt.byten[i][j]))
                      end
                  end
               end
            end
        endfunction : setup_io_cache_read_data

        function void setup_io_cache_fill_data(ccp_filldata_pkt_t m_pkt);
            m_ccp_filldata_pkt  = m_pkt;
            wr_ccp_data            = m_pkt.data;
            t_latest_update     = $time;
            t_ccp_fill_data_pkt = $time;
            isCCPFillDataSeen   = 1'b1;
            
            //#Check.IOAIU.CCPFillDataPkt.FillDataAddr
            //TODO: IOAIU Team to implement

            //#Check.IOAIU.CCPFillDataPkt.FillDataWay
            //TODO:IOAIU Team to implement
            
            //#Check.IOAIU.CCPFillDataPkt.FillDataID
            //TODO:IOAIU Team to implement
        endfunction : setup_io_cache_fill_data

        function void setup_io_cache_fill_ctrl(ccp_fillctrl_pkt_t m_pkt);
            m_ccp_fillctrl_pkt_t = m_pkt;
            t_latest_update      = $time;
            t_ccp_fill_ctrl_pkt  = $time;
            isCCPFillCtrlSeen    = 1'b1;

                //check the fill ctrl state
                //#Check.IOAIU.STRreq.CMStatusErr.FillReqdToInvalidate
                if(isSMISTRReqAddrErr  || isSMISTRReqDataErr || isSMISTRReqTransportErr 
                    || isSMICMDRespErr || isSMIDTWrspErr || isSMIDTRReqDtrDatVisErr ) begin
                    if (m_ccp_fillctrl_pkt_t.state != IX ) begin
                        print_me();
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB","Illegal State commit to CCP on a Fill")
                    end
                end else begin
                    check_fill_ctrl_state();
                end

                //#Check.IOAIU.CCPFillCtrlPkt.FillWay
                //TODO: For IOAIU Team


        endfunction : setup_io_cache_fill_ctrl

        function void setup_io_cache_write(ccp_ctrl_pkt_t m_pkt);
            ccp_cachestate_enum_t  m_ccp_cache_state;
            m_ccp_ctrl_pkt           = m_pkt;
            t_latest_update          = $time;
            t_ccp_ctrl_pkt           = $time;
            isIoCacheTagPipelineSeen = 1;
            m_ace_cmd_type_io_cache  = m_ace_cmd_type;

            if(wasSleeping)
                wasSleeping=0;	       

			//coh-writes FillReqd == 1 if UD, SC, SD, IX
			//coh-writes FillReqd == 0 if UC
			//non-coh writes FillReqd = 1 if UC, SC, IX
			//non-coh writes FillReqd = 0 if UC, UD
            if(!addrNotInMemRegion && ((m_ccp_ctrl_pkt.alloc && !m_pkt.nackuce) || is_write_hit_upgrade)) begin
                if((is_write_hit_upgrade_with_fetch == 0) && is_write_hit_upgrade == 1) 
                    isFillReqd = 1'b0;
                else begin	       
                    isFillReqd = 1'b1;
                    isFillDataReqd = 1'b1;
                end
                
                if(is_write_hit_upgrade || m_pkt.write_hit) begin
                    ccp_way   = onehot_to_binary(m_pkt.hitwayn);
                end else begin
                    ccp_way   = m_pkt.wayn;
                end
            end


            if (!is_ccp_hit) begin
                if(!addrNotInMemRegion && !illDIIAccess) begin
                    isSMICMDReqNeeded = 1;
                     isSMISTRReqNotNeeded = 0;
                     //moved expectation to STRreq
                    //if (m_iocache_allocate === 0) begin
                    //    isSMIDTWReqNeeded = 1;
                    //end
                end
            end


            // --- Below code to predict CMDreq/DTWreq applies to non-coherent writes to proxy-cache ---//
			if(!is_ccp_hit && addrMgrConst::get_addr_gprar_nc(m_ace_write_addr_pkt.awaddr)) begin 
				case(isPartialWrite)
					0: begin 
							case(m_iocache_allocate)
								0: begin 
                						isSMICMDReqNeeded	= 1;
                						//isSMIDTWReqNeeded   = 1;
							   	   end
								1: begin 
                						isSMICMDReqNeeded	= 0;
                						//isSMIDTWReqNeeded   = 0;
							   	   end
						    endcase
					   end

					1: begin
							isSMICMDReqNeeded	= 1;
                			//isSMIDTWReqNeeded   = 1;
						end
				endcase
			end
            // ---------------------------------------------------------------------------------------//

            if(mem_regions_overlap || addrNotInMemRegion) begin // For Addr Region Overlap test
                isSMICMDReqNeeded    = 0;
                isSMIDTRReqNeeded = 0;
                isSMIDTWReqNeeded = 0;
                isFillReqd        = 0;
                isFillDataReqd    = 0;
            end
    
            //CONC-8377
            if(m_pkt.nackuce) begin
                is_ccp_hit = 0;
            end

            if (m_pkt.nackuce) begin
                m_io_cache_only_data_err_found = 0;
            end
            //#Check.IOAIU.DataUncorrectableErr.RResp_SLVERR
            foreach (m_io_cache_dat_err[i]) begin
                if (m_io_cache_dat_err[i]) begin
                        m_axi_resp_expected[i] = SLVERR;
                        m_io_cache_only_data_err_found = 1;
                end
            end
            m_io_cache_only_data_err_found = 0;
        endfunction : setup_io_cache_write

        function void setup_io_cache_write_data(ccp_wr_data_pkt_t m_pkt);
            m_ccp_wr_data_pkt         = m_pkt;
            t_latest_update           = $time;
            t_ccp_write_data_pkt      = $time;
            isCCPWriteHitDataRcvd     = 1'b1;
            isIoCacheDataPipelineSeen = 1'b1;
        endfunction : setup_io_cache_write_data

        function void setup_sfi_snoop_data_expected_for_iocache();
            case (m_snp_req_pkt.smi_msg_type)
                //Changed on 08/10/2016 due to v1.6 feature enhancements.
                SNP_CLN_DTR : begin
                    if(is_ccp_hit) begin				 
                        case (m_ccp_ctrl_pkt.currstate)
                            SD : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UC : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UD : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            SC : begin
				if((m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> && m_snp_req_pkt.smi_up == SMI_UP_PERMISSION) || (m_snp_req_pkt.smi_up == SMI_UP_PRESENCE))
                                	isSMISNPDTRReqNeeded = 1;
                            end
                        endcase
                    end
                end
                SNP_NOSDINT : begin
                    if(is_ccp_hit) begin				 
                        case (m_ccp_ctrl_pkt.currstate)
                            SD : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UC : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UD : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            SC : begin
				if((m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> && m_snp_req_pkt.smi_up == SMI_UP_PERMISSION) || (m_snp_req_pkt.smi_up == SMI_UP_PRESENCE))
                                	isSMISNPDTRReqNeeded = 1;
                            end
                        endcase
                    end
                end
                SNP_VLD_DTR : begin 
                    if(is_ccp_hit) begin				 
                        case (m_ccp_ctrl_pkt.currstate)
                            SD : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UC : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UD : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            SC : begin
				if((m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> && m_snp_req_pkt.smi_up == SMI_UP_PERMISSION) || (m_snp_req_pkt.smi_up == SMI_UP_PRESENCE))
                                	isSMISNPDTRReqNeeded = 1;
                            end
                        endcase
                    end
                end
                SNP_INV_DTR : begin  //SHP:Need to add a case for SC and mpf3 match and DTW if UP_PERMISSION
                    if(is_ccp_hit) begin				 
                        case (m_ccp_ctrl_pkt.currstate)
                            SD : begin
				if((m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> && m_snp_req_pkt.smi_up == SMI_UP_PERMISSION))
                                	isSMIDTWReqNeeded = 1;
				else if (m_snp_req_pkt.smi_up == SMI_UP_PRESENCE)
                                	isSMISNPDTRReqNeeded = 1;
                            end
                            SC : begin
				if((m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> && m_snp_req_pkt.smi_up == SMI_UP_PERMISSION))
                                	isSMIDTWReqNeeded = 1;
				else if (m_snp_req_pkt.smi_up == SMI_UP_PRESENCE)
                                	isSMISNPDTRReqNeeded = 1;
                            end
                            UC : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UD : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                        endcase
                    end
                end
                SNP_NITC : begin
                    if(is_ccp_hit) begin				 
                        case (m_ccp_ctrl_pkt.currstate)
                            SD : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UC : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UD : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            SC : begin
				if((m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> && m_snp_req_pkt.smi_up == SMI_UP_PERMISSION) || m_snp_req_pkt.smi_up == SMI_UP_PRESENCE)
                                	isSMISNPDTRReqNeeded = 1;
                            end
                        endcase
                    end
                end
                SNP_NITCCI : begin
                    if(is_ccp_hit) begin				 
                        case (m_ccp_ctrl_pkt.currstate)
                            SD : begin
                                isSMIDTWReqNeeded = 1;
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UC : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UD : begin
                                isSMIDTWReqNeeded = 1;
                                isSMISNPDTRReqNeeded = 1;
                            end
                            SC : begin
				if((m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> && m_snp_req_pkt.smi_up == SMI_UP_PERMISSION) || m_snp_req_pkt.smi_up == SMI_UP_PRESENCE)
                                	isSMISNPDTRReqNeeded = 1;
                            end
                        endcase
                    end
                end
                SNP_NITCMI : begin
                    if(is_ccp_hit) begin				 
                        case (m_ccp_ctrl_pkt.currstate)
                            SD : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UC : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            UD : begin
                                isSMISNPDTRReqNeeded = 1;
                            end
                            SC : begin
				if((m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> && m_snp_req_pkt.smi_up == SMI_UP_PERMISSION) || m_snp_req_pkt.smi_up == SMI_UP_PRESENCE)
                                	isSMISNPDTRReqNeeded = 1;
                            end
                        endcase
                    end
                end
                SNP_CLN_DTW,SNP_STSH_SH : begin
                    if(is_ccp_hit) begin				 
                        case (m_ccp_ctrl_pkt.currstate)
                            SD : begin
                                isSMIDTWReqNeeded = 1;
                            end
                            UD : begin
                                isSMIDTWReqNeeded = 1;
                            end
                        endcase
                    end
                end
                SNP_INV_DTW,SNP_STSH_UNQ,SNP_UNQ_STSH : begin
                    if(is_ccp_hit) begin				 
                        case (m_ccp_ctrl_pkt.currstate)
                            SD : begin
                                isSMIDTWReqNeeded = 1;
                            end
                            UD : begin
                                isSMIDTWReqNeeded = 1;
                            end
                        endcase
                    end
                end
                SNP_INV,SNP_INV_STSH     : begin 
                    if (is_ccp_hit) begin
                        isSMISNPDataDropped = 1;
                    end
                end
            endcase
        endfunction : setup_sfi_snoop_data_expected_for_iocache

	
	function void check_snoop_state_change();
        string spkt;
        bit legal;
		ccp_cachestate_enum_t exp_state;
		eMsgSNP snp_type;					 
        //As per Bridge Architecture Spec v0.7 updated on 1/21/2017
	if(is_ccp_hit || (is_write_hit_upgrade_with_fetch && is_write_hit_upgrade)) begin
		case (m_snp_req_pkt.smi_msg_type)
            eSnpClnDtr     : begin 
		case(m_ccp_ctrl_pkt.currstate)				 
		   IX : exp_state = IX;
		   SC : exp_state = SC;
		   SD : exp_state = SD;
		   UC : exp_state = SC;
		   UD : exp_state = SD;
		endcase				 
            end
            eSnpNoSDInt : begin
		case(m_ccp_ctrl_pkt.currstate)				 
		   IX : exp_state = IX;
		   SC : exp_state = SC;
		   SD : exp_state = SD;
		   UC : exp_state = SC;
		   UD : exp_state = SD;
		endcase				 
            end
            eSnpVldDtr : begin 
		case(m_ccp_ctrl_pkt.currstate)				 
		   IX : exp_state = IX;
		   SC : exp_state = SC;
		   SD : exp_state = SC;
		   UC : exp_state = SC;
		   UD : exp_state = SC;
		endcase				 
            end
            eSnpInvDtr : begin 
		exp_state = IX;	 
            end
            eSnpNITC : begin 
		case(m_ccp_ctrl_pkt.currstate)				 
		   IX : exp_state = IX;
		   SC : exp_state = SC;
		   SD : exp_state = SD;
		   UC : exp_state = UC;
		   UD : exp_state = UD;
		endcase				 
            end
            eSnpNITCCI : begin 
		exp_state = IX;
            end
            eSnpNITCMI : begin 
		exp_state = IX;
            end
            eSnpClnDtw : begin 
		case(m_ccp_ctrl_pkt.currstate)				 
		   IX : exp_state = IX;
		   SC : exp_state = SC;
		   SD : exp_state = SC;
		   UC : exp_state = UC;
		   UD : exp_state = UC;
		endcase				 
            end
            eSnpStshShd : begin 
		case(m_ccp_ctrl_pkt.currstate)				 
		   IX : exp_state = IX;
		   SC : exp_state = SC;
		   SD : exp_state = SD;
		   UC : exp_state = SC;
		   UD : exp_state = SD;
		endcase				 
            end
            eSnpInvDtw,eSnpUnqStsh,eSnpStshUnq : begin 
		exp_state = IX;
            end
            eSnpInv,eSnpInvStsh : begin 
		exp_state = IX;
            end
	    default : begin
		uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Did not expect MsgType:0x%0x for <%=obj.fnCacheStates%> model: %s",m_snp_req_pkt.smi_msg_type,m_snp_req_pkt.convert2string()));
		uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Did not expect MsgType:0x%0x for <%=obj.fnCacheStates%> model",m_snp_req_pkt.smi_msg_type));
	    end
        endcase
        //#Check.IOAIU.CCPCtrlPkt.TagStateUp_State
        if((m_ccp_ctrl_pkt.tagstateup && (exp_state != m_ccp_ctrl_pkt.state))) begin
            print_me();
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Illegal State commit for <%=obj.fnCacheStates%> to CCP on an update. Exp:%s Act:%s",exp_state.name(),m_ccp_ctrl_pkt.state.name()),UVM_NONE)
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Illegal State commit for <%=obj.fnCacheStates%> to CCP on an update. Exp:%s Act:%s",exp_state.name(),m_ccp_ctrl_pkt.state.name()))
        end
	end else begin // if (is_ccp_hit || (is_write_hit_upgrade_with_fetch && is_write_hit_upgrade))
	end
    
	endfunction : check_snoop_state_change

    //#Check.IOAIU.CCPFillCtrlPkt.State
    function void check_fill_ctrl_state();
        string spkt;
        bit legal;
	    ccp_cachestate_enum_t exp_state;
	    eMsgDTR dtr_type;	 
	    eMsgDTW dtw_type;
	    eMsgCMD cmd_type;
        legal = 0;
						
		//NC Full Write that misses in cache will establish a line in CCP as UD without going on Concerto, so no SMI CMDreq
		//Refer 3.4 specs NcoreProxyCacheupdateArchitectureSpecification.pdf
		//TABLE 4 NON-COHERENT CACHE LOOKUP ACTIONS
		if (!isPartialWrite && isWrite && !is_ccp_hit && addrMgrConst::get_addr_gprar_nc(m_sfi_addr)) begin :_NC_FullWrite_AllocatingMiss
			exp_state = UD;
		end : _NC_FullWrite_AllocatingMiss
		else begin: _not_NC_FullWrite_AllocatingMiss
			//As per Bridge Architecture Spec v0.7 updated on 1/21/2017
			$cast(cmd_type, m_cmd_req_pkt.smi_msg_type);
			case (m_cmd_req_pkt.smi_msg_type)
				eCmdRdVld     : begin 
					case (m_dtr_req_pkt.smi_msg_type)
					  eDtrDataShrCln : begin
						  exp_state = SC;
					  end		
					  eDtrDataShrDty : begin
						  exp_state = SD;		
					  end		
					  eDtrDataUnqCln : begin
						  exp_state = UC;		
					  end		
					  eDtrDataUnqDty : begin
						  exp_state = UD;		
					  end		
					  default : begin
						  $cast(dtr_type, m_dtr_req_pkt.smi_msg_type);
						  uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Illegal Dtr type %s for <%=obj.fnCacheStates%> model for Cmd Type %s",dtr_type.name(),cmd_type.name()));
					  end		
					endcase
				end
				eCmdRdUnq : begin
					$cast(dtr_type, m_dtr_req_pkt.smi_msg_type);
					case (m_dtr_req_pkt.smi_msg_type)
					  eDtrDataUnqCln : begin
						  exp_state = UD;		
					  end		
					  eDtrDataUnqDty : begin
						  exp_state = UD;		
					  end		
					  default : begin
						  uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Illegal Dtr type %s for <%=obj.fnCacheStates%> model for Cmd type %s",dtr_type.name(),cmd_type.name()));
					  end		
					endcase
				end
				eCmdMkUnq : begin 
					exp_state = UD;
				end
				eCmdRdNC : begin
					exp_state = UC;
				end
				eCmdWrNCFull: begin 
					exp_state = UD;
				end
				default : begin
					uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Did not expect MsgType:0x%0x for <%=obj.fnCacheStates%> model: %s",m_snp_req_pkt.smi_msg_type,m_snp_req_pkt.convert2string()));
					uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Did not expect MsgType:0x%0x for <%=obj.fnCacheStates%> model",cmd_type.name()));
				end
			endcase
		end :_not_NC_FullWrite_AllocatingMiss

        if(exp_state != m_ccp_fillctrl_pkt_t.state) begin
            print_me();
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Illegal State for <%=obj.fnCacheStates%> commit to CCP on a Fill. Exp:%s Act:%s Cmd:%s Dtr:%s",exp_state.name(),m_ccp_fillctrl_pkt_t.state.name(),cmd_type.name(),dtr_type.name()),UVM_NONE)
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Illegal State for <%=obj.fnCacheStates%> commit to CCP on a Fill. Exp:%s Act:%s Cmd:%s Dtr:%s",exp_state.name(),m_ccp_fillctrl_pkt_t.state.name(),cmd_type.name(),dtr_type.name()))
        end
    endfunction : check_fill_ctrl_state

    //useCache == 1
    <% } %>

    function void setup_sfi_snoop_data_expected();

        case (m_snp_req_pkt.smi_msg_type)
            SNP_NITC    : begin
                case(WU_DT_PD_IS)
                    4'b0100: begin
                        if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE) begin
                            isSMISNPDTRReqNeeded = 1;
                        end
                    end
                    4'b1100, 4'b1101, 4'b0101: begin
                        isSMISNPDTRReqNeeded = 1;
                    end
                    4'b0110, 4'b1110, 4'b0111, 4'b1111: begin
                        isSMISNPDTRReqNeeded = 1;
                        isSMIDTWReqNeeded = 1;
                    end
                endcase
		        if (WU_DT_PD_IS == 4'b0100 && //DataXfer is set
                    m_snp_req_pkt.smi_up == SMI_UP_PERMISSION && //UP=11
            		m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> //match
            	   )
            		isSMISNPDTRReqNeeded = 1;
                end
                SNP_NITCCI, SNP_NITCMI  : begin
                    case(WU_DT_PD_IS)
                        4'b0110, 4'b1110: begin
                            isSMISNPDTRReqNeeded = 1;
                            isSMIDTWReqNeeded = 1;
                        end
                    endcase
		        if(!(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION && m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>))) begin
        		isSMISNPDataDropped = 1;
            	isSMISNPDTRReqNeeded = 0;
    		end
            end
            SNP_CLN_DTR : begin
                case(WU_DT_PD_IS)
                    4'b0100: begin
                        if(m_snp_req_pkt.smi_up inside {SMI_UP_PRESENCE}) begin
                            isSMISNPDTRReqNeeded = 1;
                        end
                    end
                    4'b1100, 4'b0101, 4'b1101: begin
                        isSMISNPDTRReqNeeded = 1;
                    end
                    4'b0110, 4'b1110, 4'b0111, 4'b1111: begin
                        isSMISNPDTRReqNeeded = 1;
                        isSMIDTWReqNeeded = 1;
                    end
                endcase
				if (WU_DT_PD_IS == 4'b0100 && //DataXfer is set
					m_snp_req_pkt.smi_up == SMI_UP_PERMISSION && //UP=11
            		m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> //match
            	   )
            		isSMISNPDTRReqNeeded = 1;
            end
            SNP_VLD_DTR : begin 
                case(WU_DT_PD_IS)
                    4'b0100: begin
                        if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE) begin
                            isSMISNPDTRReqNeeded = 1;
                        end
                    end
                    4'b1100, 4'b0101, 4'b1101, 4'b0110, 4'b1110, 4'b0111, 4'b1111: begin
                        isSMISNPDTRReqNeeded = 1;
                    end
                endcase
		if (WU_DT_PD_IS == 4'b0100 && //DataXfer is set
			m_snp_req_pkt.smi_up == SMI_UP_PERMISSION && //UP=11
            		m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> //match
            	   )
            		isSMISNPDTRReqNeeded = 1;
            end
            SNP_INV_DTR : begin
                case(WU_DT_PD_IS)
                    4'b0000: begin
                        isSMISNPDTRReqNeeded = 0;
                        isSMIDTWReqNeeded = 0;
                    end
                    4'b0100,4'b0110: begin
                        if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE) begin
                            isSMISNPDTRReqNeeded = 1;
                        end else if(m_snp_req_pkt.smi_up == SMI_UP_PERMISSION && m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>) begin
                            isSMISNPDTRReqNeeded = 0;
                            isSMIDTWReqNeeded = 1;
                        end else begin
                            isSMISNPDTRReqNeeded = 0;
                            isSMIDTWReqNeeded = 0;
                        end
                    end
                    4'b1100, 4'b1110: begin
                        isSMISNPDTRReqNeeded = 1;
                        isSMIDTWReqNeeded = 0;
                    end
                endcase

            end
                
            SNP_NOSDINT : begin
                case(WU_DT_PD_IS)
                    4'b0100: begin
                        if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE) begin
                            isSMISNPDTRReqNeeded = 1;
                        end
                    end
                    4'b1100, 4'b0101, 4'b1101: begin
                        isSMISNPDTRReqNeeded = 1;
                    end
                    4'b0110: begin
                        if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE) begin
                            isSMISNPDTRReqNeeded = 1;
                        end else begin
                            isSMISNPDTRReqNeeded = 1;
                            isSMIDTWReqNeeded = 1;
                        end
                    end
                    4'b1110: begin
                        isSMISNPDTRReqNeeded = 1;
                    end
                    4'b0111, 4'b1111: begin
                        isSMISNPDTRReqNeeded = 1;
                        isSMIDTWReqNeeded = 1;
                    end
                endcase
		if (WU_DT_PD_IS == 4'b0100 && //DataXfer is set
			m_snp_req_pkt.smi_up == SMI_UP_PERMISSION && //UP=11
            		m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%> //match
            	   )
            		isSMISNPDTRReqNeeded = 1;
            end
            SNP_CLN_DTW : begin
                case(WU_DT_PD_IS)
                    4'b0110, 4'b1110, 4'b0111, 4'b1111: begin
                        isSMIDTWReqNeeded = 1;
                    end
                endcase
            end
            //CONC-7381
            /* SNP_STSH_SH : begin */
            /*     case(WU_DT_PD_IS) */
            /*         4'b0110, 4'b1110, 4'b0111, 4'b1111: begin */
            /*             /1* if(m_snp_req_pkt.smi_ca && *1/ */
            /*             /1*    m_snp_req_pkt.smi_ac) begin *1/ */
            /*                 isSMIDTWReqNeeded = 1; */
            /*             /1* end *1/ */
            /*         end */
            /*     endcase */
            /* end */
            SNP_RECALL,
            SNP_UNQ_STSH,
            SNP_INV_DTW : begin
                if(WU_DT_PD_IS == 4'b0110 ||
                   WU_DT_PD_IS == 4'b1110 ) begin
                    isSMIDTWReqNeeded = 1;
                end
            end
            SNP_STSH_SH,
            SNP_STSH_UNQ : begin
                if(WU_DT_PD_IS == 4'b0110 ||
                   WU_DT_PD_IS == 4'b1110 ) begin
                   /* if(m_snp_req_pkt.smi_ca && */
                   /*    m_snp_req_pkt.smi_ac) begin */
                        isSMIDTWReqNeeded = 1;
                    /* end */
                end
            end
            SNP_INV,
            SNP_INV_STSH : begin
                if (m_ace_snoop_resp_pkt.crresp[CCRRESPDATXFERBIT]) begin
                    isSMISNPDataDropped = 1;
                end
            end
        endcase
    endfunction : setup_sfi_snoop_data_expected

    function void print_me(bit isPendingTxn = 0, bit isErrorTxn = 0, bit isCompTxn = 0, bit isDbgTxn = 0);
       eMsgCMD cmd_type;
       eMsgDTR dtr_type;
       eMsgDTW dtw_type;
       eMsgDTWMrgMRD dtwMrgMrd_type;
       eMsgSNP snp_type;
       string header = "";
       string txn_type = "";
       string report_str = "";
       int print_me_q[$];
       string sorted_time[] = new [smi_act_time.size()];
       int index = 0;


       if (isCompTxn) begin
          header = "COMPLETED TXN";
       end
       if (isDbgTxn) begin
          header = "DEBUG TXN";
       end
       if (isPendingTxn) begin
          header = "IOAIU PENDING TXN";
       end
       if (isErrorTxn) begin
          header = "FAILED TXN";
       end
       
       report_str = $sformatf("<%=obj.strRtlNamePrefix%> %0s <%=obj.fnNativeInterface%> %0s %0s", (owo == 1) ? "OWO_<%=obj.AiuInfo[obj.Id].wData%>b" : "", (<%=obj.useCache%> == 1) ? "w/ proxyCache" : "", (isRead || isWrite) ? $sformatf("ott_alloc_cycles:%0d", (ott_alloc_cc - natv_intf_cc)) : "");

       if(isSysCoAttachSeq) begin
	  		report_str = $sformatf("%0s IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> SYSCO ATTACH nSMISysReqExpd:%0d nSMISysReqSent:%0d nSMISysRspRcvd:%0d", report_str, tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, nSMISysReqExpd, nSMISysReqSent, nSMISysRspRcvd);
       end
       if(isSysCoDetachSeq) begin
	  		report_str = $sformatf("%0s IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> SYSCO DETACH (AttachErr:%0d) nSMISysReqExpd:%0d nSMISysReqSent:%0d nSMISysRspRcvd:%0d", report_str,tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,  isSysCoAttachErr, nSMISysReqExpd, nSMISysReqSent, nSMISysRspRcvd);
       end
       if(isAtomic) begin
	  report_str = $sformatf("%0s IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> ATOMIC AtomicType:%0s", report_str, tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ace_cmd_type.name());
       end
       else if(isStash) begin
	  report_str = $sformatf("%0s IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> STASHING StashType:%0s isWrite:%0d", report_str, tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ace_cmd_type.name(),isWrite);
       end
       else if(isWrite || isUpdate) begin
	  report_str = $sformatf("%0s IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> WRITE isPartial:%b", report_str,tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, isPartialWrite);
          if (owo == 1) 
                report_str = $sformatf("%0s owo_wr_state:%p", report_str, m_owo_wr_state);
       end
       else if(isRead) begin
          if (isDVM) begin
	    report_str = $sformatf("%0s IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> DVM", report_str,tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>);
          end else begin
	    report_str = $sformatf("%0s IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> READ isPartial:%0b", report_str, tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, isPartialRead);
          end
       end
       else if(isSnoop) begin
	  report_str = $sformatf("%0s IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> SNOOP", report_str,tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>);
       end
       else if(isIoCacheEvict) begin
	  report_str = $sformatf("%0s IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> EVICT", report_str,tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>);
       end
       else if (isDVMSnoop) begin
           report_str = $sformatf("%s IOAIU_UID:%0d %0sSnoop CreationTime:%0t LatestUpd:%0t",report_str, tb_txnid, smi_flags["ACEReadAddr"] ? "DVMSYNC":"DVM", t_creation, t_latest_update);
     
           foreach(smi_flags[txn]) begin
               report_str = $sformatf("%s %s:%0d",report_str,txn,smi_flags[txn]);
           end
           foreach(smi_exp_flags[txn]) begin
               report_str = $sformatf("%s exp_%s:%0d",report_str,txn,smi_exp_flags[txn]);
           end
           `uvm_info(header,$sformatf("%s",report_str),UVM_NONE);

           foreach (smi_act_time[i]) begin
             sorted_time[index++] = i;
           end
     
           // Sort the array
           sorted_time.sort() with (smi_act_time[item]);

           foreach(sorted_time[txn]) begin
            if (smi_act[sorted_time[txn]] != null) begin
               uvm_report_info(header,$sformatf("%0t: %s %s:",smi_act_time[sorted_time[txn]],sorted_time[txn],smi_act[sorted_time[txn]].convert2string()),UVM_NONE);
            end 
           //if(smi_act["SMISnpReqDvm1"]) begin
           //    uvm_report_info(header,$sformatf("%0t: %s: %s",smi_act_time["SMISnpReqDvm1"],"SMISnpReqDvm1",smi_act["SMISnpReqDvm1"].convert2string()),UVM_NONE);
           //end
           //if(smi_act["SMISnpReqDvm2"]) begin
           //    uvm_report_info(header,$sformatf("%0t: %s: %s",smi_act_time["SMISnpReqDvm2"],"SMISnpReqDvm2",smi_act["SMISnpReqDvm2"].convert2string()),UVM_NONE);
           //end
           else if(smi_flags["ACESnpReqDvm1"] && sorted_time[txn] == "ACESnpReqDvm1") begin
               uvm_report_info(header,$sformatf("%0t: %s: %s",smi_act_time["ACESnpReqDvm1"],"ACESnpReqDvm1",m_ace_snoop_addr_pkt0_act.sprint_pkt()),UVM_NONE);
           end
           else if(smi_flags["ACESnpReqDvm2"] && sorted_time[txn] == "ACESnpReqDvm2") begin
               uvm_report_info(header,$sformatf("%0t: %s: %s",smi_act_time["ACESnpReqDvm2"],"ACESnpReqDvm2",m_ace_snoop_addr_pkt1_act.sprint_pkt()),UVM_NONE);
           end
           else if(smi_flags["ACESnpRspDvm1"] && sorted_time[txn] == "ACESnpRspDvm1") begin
               uvm_report_info(header,$sformatf("%0t: %s: %s",smi_act_time["ACESnpRspDvm1"],"ACESnpRspDvm1",m_ace_snoop_resp_pkt0_act.sprint_pkt()),UVM_NONE);
           end
           else if(smi_flags["ACESnpRspDvm2"] && sorted_time[txn] == "ACESnpRspDvm2") begin
               uvm_report_info(header,$sformatf("%0t: %s: %s",smi_act_time["ACESnpRspDvm2"],"ACESnpRspDvm2",m_ace_snoop_resp_pkt1_act.sprint_pkt()),UVM_NONE);
           end
           else if(smi_flags["ACEReadAddr"] && sorted_time[txn] == "ACEReadAddr")
               uvm_report_info(header,$sformatf("%0t: %s: %s",smi_act_time["ACEReadAddr"],"ACEReadAddr",m_ace_read_addr_pkt.sprint_pkt()),UVM_NONE);
           else if(smi_flags["ACEReadData"] && sorted_time[txn] == "ACEReadData")
               uvm_report_info(header,$sformatf("%0t: %s: %s",smi_act_time["ACEReadData"],"ACEReadData",m_ace_read_data_pkt.sprint_pkt()),UVM_NONE);
           //if(smi_act["SMISnpRsp"]) begin
           //    uvm_report_info(header,$sformatf("%0t: %s: %s",smi_act_time["SMISnpRspDvm"],"SMISnpRspDvm",smi_act["SMISnpRsp"].convert2string()),UVM_NONE);
           //end
           end
           return;
       end

       if (!isSysCoAttachSeq && !isSysCoDetachSeq) begin
			report_str = $sformatf("%s, hasDTRReqErr:%0d, hasDTWRspErr:%0d %0s, hasFatlErr:%0d %0s, illegalNSAccess:%0d,illegalCSRAccess:%0d,illDIIAccess:%0d isAddrBlocked:%0d, MemRegionsOverlap:%0d addrNotInMemRegion:%0d addrInCSRRegion:%0d %0s  isCoherent:%0d CMDReqNeeded:%0d",report_str, dtrreq_cmstatus_err, dtwrsp_cmstatus_err, (dtwrsp_cmstatus_err ? $psprintf("(%0t AddrErr:%0d)", t_dtwrsp_cmstatus_err, dtwrsp_cmstatus_add_err) : ""), hasFatlErr, (hasFatlErr ? $psprintf("(%0t Err:%0d)", t_strreq_cmstatus_err, isSMISTRReqAddrErr) : ""), illegalNSAccess,illegalCSRAccess,illDIIAccess, isAddrBlocked, mem_regions_overlap, addrNotInMemRegion, addrInCSRRegion, (addrInCSRRegion ? $psprintf("(SelfIDRegAccess:%0d)", isSelfIDRegAccess) : ""),  isCoherent, isSMICMDReqNeeded);
     
      if(!$test$plusargs("unmapped_add_access")) begin
		report_str = $sformatf("%s home_unit_id:%0d (%0s), transOrderMode:%s, gpra_order:0b%b, tctrlr[0]:0x%x",report_str, home_dmi_unit_id, ((addrMgrConst::get_unit_type(home_dmi_unit_id) == addrMgrConst::DII) ? "DII" : (addrMgrConst::get_addr_gprar_nc(m_sfi_addr) ? "Non-Coh DMI" : "Coh DMI")), transOrderMode.name, gpra_order, tctrlr[0]);
       end
     end

       if(isAtomic || isStash || isWrite || isUpdate) begin
	  report_str = $sformatf("%s Addr:0x%0x Prot:0x%0x AxID:0x%0x AxLen:0x%0x AxDomain:0x%0x AxLock:0x%0x ACEWriteRespSent:%0d",
				 report_str, m_ace_write_addr_pkt.awaddr, m_ace_write_addr_pkt.awprot[1], 
				 m_ace_write_addr_pkt.awid, m_ace_write_addr_pkt.awlen, m_ace_write_addr_pkt.awdomain, m_ace_write_addr_pkt.awlock, isACEWriteRespSent);

          <% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
          report_str = $sformatf("%s AWUNIQUE:0x%0x", report_str, m_ace_write_addr_pkt.awunique);
          <% } %>
       end
       else if(isRead) begin
	  report_str = $sformatf("%s DCE:0x%0x Addr:0x%0x Security:0x%0x AxID:0x%0x AxLen:0x%0x AxDomain:0x%0x AxLock:0x%0x",
				 report_str, home_dce_unit_id, m_ace_read_addr_pkt.araddr, m_ace_read_addr_pkt.arprot[1], 
				 m_ace_read_addr_pkt.arid, m_ace_read_addr_pkt.arlen, m_ace_read_addr_pkt.ardomain, m_ace_read_addr_pkt.arlock);
       end
       else if(isSnoop) begin
	  report_str = $sformatf("%s Addr:0x%0x",report_str,m_sfi_addr);
       end
       else if(isMntOp) begin
	  report_str = $sformatf("MNTOP m_mntop_cmd_type:%s mntop_addr:%0h mntop_security:%0h, mnt_op_index:%0h mntop_way:%0d",m_mntop_cmd_type.name(),mntop_addr,mntop_security,mntop_index,mntop_way);	  
       end
       
       report_str = $sformatf("%s CreationTime:%0t LatestUpd:%0t", report_str, t_creation, t_latest_update);

       if (!isSysCoAttachSeq && !isSysCoDetachSeq) begin
           report_str = $sformatf("%s Qos:%0h",report_str,m_axi_qos);
       end
       
       if(isACEWriteDataNeeded) begin
	  report_str = $sformatf("%s ACEWriteDataNeeded:%0d ACEWriteDataRecd:%0d",report_str,isACEWriteDataNeeded, isACEWriteDataRecd);
       end

       if(isACEReadDataNeeded) begin
	  report_str = $sformatf("%s ACEReadDataNeeded:%0d ACEReadDataSentNoRack:%0d ACEReadDataSent:%0d",report_str,isACEReadDataNeeded, isACEReadDataSentNoRack, isACEReadDataSent);
       end

       //report_str = $sformatf("%s isSMISTRReqNotNeeded:%0d",report_str, isSMISTRReqNotNeeded);

       if(isSMICMDReqNeeded) begin
	  report_str = $sformatf("%s SMICmdReqNeeded:%0d SMICmdReqSent:%0d",report_str,isSMICMDReqNeeded, isSMICMDReqSent);
	  if(isSMICMDReqSent) begin
	     report_str = $sformatf("%s SMICMDRespRecd:%0d SMIStrReqRecd:%0d",report_str,isSMICMDRespRecd,isSMISTRReqRecd);
	     if(isSMISTRReqRecd)
	       report_str = $sformatf("%s SMISTRRespSent:%0d",report_str,isSMISTRRespSent);
	  end
       end
       if(m_ace_cmd_type == DVMMSG) begin
	  report_str =$sformatf(" %s isDVMSync:%0d isDVMMultiPart:%0d isACEReadDataDVMMultiPartSent:%0d SMICMPRespRecd:%0d",report_str,isDVMSync,isDVMMultiPart, isACEReadDataDVMMultiPartSent, isSMICMPRespRecd);
          if (isDVMSync) 
	    report_str =$sformatf(" %s ACESnoopReqSent:%0b ACESnoopRespRecd:%0b",report_str, isACESnoopReqSent, isACESnoopRespRecd);
       end
       
       if(is2ndSMICMDReqNeeded) begin
	  report_str = $sformatf("%s 2ndSMICmdReqNeeded:%0d 2ndSMICmdReqSent:%0d",report_str,is2ndSMICMDReqNeeded, is2ndSMICMDReqSent);
	  if(is2ndSMICMDReqSent) begin
	     report_str = $sformatf("%s 2ndSMICmdRespRecd:%0d 2ndSMISTRReqNeeded:%0d 2ndSMISTRReqRecd:%0d",report_str,is2ndSMICMDRespRecd,is2ndSMISTRReqNeeded, is2ndSMISTRReqRecd);
	     if(is2ndSMISTRReqRecd)
	       report_str = $sformatf("%s 2ndSMISTRRespSent:%0d",report_str,is2ndSMISTRRespSent);
	  end
       end

       if(isMultiAccess) begin
	  report_str = $sformatf("%s MultiLine:%0b MultiLineMaster:%0b MultiLineOrder:%0d MultiLineTotal:%0d MultiLineID:%0d MultiLineReadyToDel:%0d tagged_decerr:%0d", report_str, isMultiAccess, isMultiLineMaster, multiline_order, total_cacheline_count, m_multiline_tracking_id, multiline_ready_to_delete, tagged_decerr);
       end

       if(isSnoop) begin
	  report_str = $sformatf("%s SMISnoopReqRecd:%0d SMISnoopResSent:%0d",report_str,isSMISNPReqRecd, isSMISNPRespSent);
	  <%if(obj.useCache) { %>
	  report_str = $sformatf("%s isSnpHitEvict:%0d",report_str,isSnpHitEvict);
	  <% } %>
       end

       if(isSMIDTRReqNeeded) begin
	  report_str = $sformatf("%s SMIDTRReqNeeded:%0d SMIDTRReqRecd:%0d",report_str,isSMIDTRReqNeeded, isSMIDTRReqRecd);
	  if(isSMIDTRReqRecd)
	    report_str = $sformatf("%s SMIDTRRespSent:%0d",report_str,isSMIDTRRespSent);
       end

       if(isSMIUPDReqNeeded) begin
	  report_str = $sformatf("%s SMIUPDReqNeeded:%0d SMIUPDReqSent:%0d",report_str,isSMIUPDReqNeeded, isSMIUPDReqSent);
	  if(isSMIUPDReqSent)
	    report_str = $sformatf("%s SMIUPDRespRecd:%0d",report_str,isSMIUPDRespRecd);
       end

       if(isSMIDTWReqNeeded) begin
	  report_str = $sformatf("%s SMIDTWReqNeeded:%0d SMIDTWReqSent:%0d",report_str,isSMIDTWReqNeeded, isSMIDTWReqSent);
	  if(isSMIDTWReqSent)
	    report_str = $sformatf("%s SMIDTWRespRecd:%0d",report_str,isSMIDTWRespRecd);
       end

       if(isSMISNPDTRReqNeeded) begin
	  report_str = $sformatf("%s SMISNPDTRReqNeeded:%0d SMISNPDTRReqSent:%0d",report_str,isSMISNPDTRReqNeeded, isSMISNPDTRReqSent);
	  if(isSMISNPDTRReqSent)
	    report_str = $sformatf("%s SMISNPDTRRespRecd:%0d",report_str,isSMISNPDTRRespRecd);
       end
       if(isSenderEventReq) begin
	  report_str = $sformatf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> isSenderEventReq:%0d isSenderSysReqNeeded:%0d", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,isSenderEventReq,isSenderSysReqNeeded);
	  if(isSenderSysReqSent)
	    report_str = $sformatf("%s isSenderSysReqSent:%0d isSenderSysRspRcvd:%0d",report_str,isSenderSysReqSent,isSenderSysRspRcvd);
	  if(isSenderEventAckNeeded)
	    report_str = $sformatf("%s isSenderEventAckNeeded:%0d isSenderEventAckRcvd:%0d",report_str,isSenderEventAckNeeded,isSenderEventAckRcvd);
       end

        if(isRecieverSysReqRcvd) begin
	  report_str = $sformatf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> isRecieverSysReqRcvd:%0d isRecieverEventReqNeeded:%0d",tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,isRecieverSysReqRcvd,isRecieverEventReqNeeded);
	  if(isRecieverEventReqSent)
	    report_str = $sformatf("%s isRecieverEventReqSent:%0d isRecieverEventAckNeeded:%0d isRecieverEventAckSent:%0d",report_str,isRecieverEventReqSent,isRecieverEventAckNeeded,isRecieverEventAckSent);
	  if(isRecieverSysRspNeeded)
	    report_str = $sformatf("%s isRecieverSysRspNeeded:%0d isRecieverSysRspSent:%0d",report_str,isRecieverSysRspNeeded,isRecieverSysRspSent);
       end

  <%if(obj.useCache) { %>
         if (m_ccp_ctrl_pkt) begin
             CCPcurrentstate = m_ccp_ctrl_pkt.currstate;
             if (m_ccp_ctrl_pkt.tagstateup) begin				
       	        CCPnextstate =m_ccp_ctrl_pkt.state;
       	     end else if (m_ccp_fillctrl_pkt_t) begin
       	        CCPnextstate = m_ccp_fillctrl_pkt_t.state;
       	     end else begin
       	        CCPnextstate = CCPcurrentstate;
       	     end
	  end else begin
             CCPcurrentstate = IX;
       	     CCPnextstate = IX;
          end
  	  if(!isSysCoAttachSeq && !isSysCoDetachSeq && !isMntOp) begin

    		report_str = $sformatf("%s lookupEn:%0d allocEn:%0d isIoCacheTagPipelineNeeded:%0b,  isIoCacheTagPipelineSeen:%0b, isIoCacheDataPipelineSeen:%0d, isCCPFillCtrlSeen:%0d, isCCPFillDataSeen:%0d, isCCPCancelSeen:%0d, isAddrBlocked:%0d, Index:0x%0h, Way:0x%0d CCP_Addr:0x%0x is_write_hit_upgrade:%0d is_ccp_hit:%0d, curr_st:%0s, next_st:%0s m_iocache_allocate:%0d dropDtrData:%0h isFillReqd:%0h isFillDataReqd:%0h isCCPReadHitDataRcvd:%0d",report_str, csr_ccp_lookupen, csr_ccp_allocen, isIoCacheTagPipelineNeeded, isIoCacheTagPipelineSeen, isIoCacheDataPipelineSeen, isCCPFillCtrlSeen, isCCPFillDataSeen,  isCCPCancelSeen, isAddrBlocked, ccp_index, ccp_way, ccp_addr, is_write_hit_upgrade, is_ccp_hit,CCPcurrentstate.name(),CCPnextstate.name(), m_iocache_allocate, dropDtrData, isFillReqd, isFillDataReqd, isCCPReadHitDataRcvd);
		end
  <% } %>       

	print_me_q = {t_ace_write_recd, t_ace_read_recd, t_ace_write_data_recd, t_ace_write_resp_sent, t_ace_read_data_sent, t_ace_read_data_dvm_multipart_sent, t_ace_snoop_sent, t_ace_snoop_resp_recd, t_ace_snoop_data_recd, t_sfi_snp_req, t_sfi_snp_rsp, t_sfi_cmd_req, t_2nd_sfi_cmd_req, t_sfi_cmp_rsp, t_sfi_cmd_rsp, t_2nd_sfi_cmd_rsp, t_sfi_str_req, t_2nd_sfi_str_req, t_sfi_str_rsp, t_2nd_sfi_str_rsp, t_sfi_dtr_req, t_sfi_dtr_rsp, t_sfi_dtw_req, t_sfi_dtw_rsp, t_sfi_upd_req, t_sfi_upd_rsp, t_ccp_ctrl_pkt, t_ccp_evict_pkt, t_ccp_fill_ctrl_pkt, t_ccp_fill_data_pkt, t_ccp_read_rsp_pkt, t_ccp_write_data_pkt,t_sfi_evt_req,t_sfi_sys_req,t_sfi_sys_rsp,t_sfi_evt_ack,t_sfi_sys_req_rcv,t_sfi_evt_req_rcv,t_sfi_evt_ack_rcv,t_sfi_sys_rsp_rcv};

	print_me_q.sort();

       report_str = $sformatf("%s OTT_ID:%0d (%0s)", report_str, m_ott_id, m_ott_status);
       uvm_report_info(header, report_str, UVM_NONE);

   foreach (print_me_q[idx]) begin

        do begin
        if (print_me_q[idx]==print_me_q[idx+1])print_me_q.pop_front();
        end while ((print_me_q.size()>1) && print_me_q[idx]==print_me_q[idx+1]);

       if (isMultiAccess) begin
        if((isWrite) && (print_me_q[idx] == t_ace_write_recd)) begin
            if (owo_512b)
                uvm_report_info(header, $sformatf("%t: NativeWrReq: %s", t_ace_write_recd, m_owo_native_wr_addr_pkt.sprint_pkt()), UVM_NONE);
            uvm_report_info(header, $sformatf("%t: OrigWrReq: %s", t_ace_write_recd, m_multiline_starting_write_addr_pkt.sprint_pkt()), UVM_NONE);
        end else if((isRead) && (print_me_q[idx] == t_ace_read_recd)) begin 
            if (owo_512b)
                uvm_report_info(header, $sformatf("%t: NativeRdReq: %s", t_ace_read_recd, m_owo_native_rd_addr_pkt.sprint_pkt()), UVM_NONE);
	    uvm_report_info(header, $sformatf("%t: OrigRdReq: %s", t_ace_read_recd, m_multiline_starting_read_addr_pkt.sprint_pkt()), UVM_NONE);
        end
       end
       if ((isACEWriteAddressRecd) && (print_me_q[idx] == t_ace_write_recd)) begin
          uvm_report_info(header, $sformatf("%t: ACEWrReq: %s", t_ace_write_recd, m_ace_write_addr_pkt.sprint_pkt()), UVM_NONE);
       end
       if ((isACEWriteDataRecd) && (print_me_q[idx] == t_ace_write_data_recd)) begin
           if (m_owo_native_wr_data_pkt != null) begin 
                uvm_report_info(header, $sformatf("%t: NativeWrData: %s", t_ace_write_data_recd, m_owo_native_wr_data_pkt.sprint_pkt()), UVM_NONE);
            end
          uvm_report_info(header, $sformatf("%t: WrData: %s", t_ace_write_data_recd, m_ace_write_data_pkt.sprint_pkt()), UVM_NONE);
       end
       if ((isACEWriteRespSent) && (print_me_q[idx] == t_ace_write_resp_sent)) begin
          uvm_report_info(header, $sformatf("%t: ACEWrResp: %s", t_ace_write_resp_sent, m_ace_write_resp_pkt.sprint_pkt()), UVM_NONE);
       end

       if ((isACEReadAddressRecd) && (print_me_q[idx] == t_ace_read_recd)) begin
          uvm_report_info(header, $sformatf("%t: ACERdReq: %s", t_ace_read_recd, m_ace_read_addr_pkt.sprint_pkt()), UVM_NONE);
       end
       if ((isACEReadAddressDVMRecd) && (print_me_q[idx] == t_ace_read_recd)) begin
          uvm_report_info(header, $sformatf("%t: ACERdReqDVM2: %s", t_ace_read_recd, m_ace_read_addr_pkt2.sprint_pkt()), UVM_NONE);
       end

       if ((isACEReadDataSent) && (print_me_q[idx] == t_ace_read_data_sent)) begin
          uvm_report_info(header, $sformatf("%t: ACERdData: %s", t_ace_read_data_sent, m_ace_read_data_pkt.sprint_pkt()), UVM_NONE);
       end
       if ((isACEReadDataDVMMultiPartSent)  && (print_me_q[idx] == t_ace_read_data_dvm_multipart_sent)) begin
          uvm_report_info(header, $sformatf("%t: ACERdDataDVM2: %s", t_ace_read_data_dvm_multipart_sent, m_ace_read_data_pkt2.sprint_pkt()), UVM_NONE);
       end

       if ((isACESnoopReqSent) && (print_me_q[idx] == t_ace_snoop_sent)) begin
          uvm_report_info(header, $sformatf("%t: ACESnoopAddr: %s", t_ace_snoop_sent, m_ace_snoop_addr_pkt.sprint_pkt()), UVM_NONE);
       end

       if ((isACESnoopRespRecd) && (print_me_q[idx] == t_ace_snoop_resp_recd)) begin
          uvm_report_info(header, $sformatf("%t: ACESnoopResp: %s", t_ace_snoop_resp_recd, m_ace_snoop_resp_pkt.sprint_pkt()), UVM_NONE);
       end

       if ((isACESnoopDataRecd) && (print_me_q[idx] == t_ace_snoop_data_recd)) begin
          uvm_report_info(header, $sformatf("%t: ACESnoopData: %s", t_ace_snoop_data_recd, m_ace_snoop_data_pkt.sprint_pkt()), UVM_NONE);
       end

       if ((isSMISNPReqRecd) && (print_me_q[idx] == t_sfi_snp_req)) begin
	  $cast(snp_type,m_snp_req_pkt.smi_msg_type);
	       
          uvm_report_info(header, $sformatf("%t: SNPReq: %s SnpType:%s RBID:0x%h", t_sfi_snp_req, m_snp_req_pkt.convert2string(),snp_type.name(),m_snp_req_pkt.smi_rbid), UVM_NONE);
       end
       if ((isSMISNPRespSent) && (print_me_q[idx] == t_sfi_snp_rsp)) begin
          uvm_report_info(header, $sformatf("%t: SNPRsp: %s", t_sfi_snp_rsp, m_snp_rsp_pkt.convert2string()), UVM_NONE);
       end

       if ((isSMICMDReqSent) && (print_me_q[idx] == t_sfi_cmd_req)) begin
	  $cast(cmd_type, m_cmd_req_pkt.smi_msg_type);
          uvm_report_info(header, $sformatf("%t: CMDReq: %s CmdType:%0s", t_sfi_cmd_req, m_cmd_req_pkt.convert2string(),cmd_type.name()), UVM_NONE);
       end
       if ((is2ndSMICMDReqSent) && (print_me_q[idx] == t_2nd_sfi_cmd_req)) begin
	  $cast(cmd_type, m_2nd_cmd_req_pkt.smi_msg_type);
          uvm_report_info(header, $sformatf("%t: 2nd CMDReq: %s CmdType:%0s", t_2nd_sfi_cmd_req, m_2nd_cmd_req_pkt.convert2string(),cmd_type.name()), UVM_NONE);
       end
       if ((isSMICMPRespRecd) && (print_me_q[idx] == t_sfi_cmp_rsp)) begin
          uvm_report_info(header, $sformatf("%t: CMPRsp: %s", t_sfi_cmp_rsp, m_cmp_rsp_pkt.convert2string()), UVM_NONE);
       end

       if ((isSMICMDRespRecd) && (print_me_q[idx] == t_sfi_cmd_rsp)) begin
          uvm_report_info(header, $sformatf("%t: CMDRsp: %s", t_sfi_cmd_rsp, m_cmd_rsp_pkt.convert2string()), UVM_NONE);
       end
       if ((is2ndSMICMDRespRecd) && (print_me_q[idx] == t_2nd_sfi_cmd_rsp)) begin
          uvm_report_info(header, $sformatf("%t: 2nd CMDRsp: %s", t_2nd_sfi_cmd_rsp, m_2nd_cmd_rsp_pkt.convert2string()), UVM_NONE);
       end
       if ((isSMISTRReqRecd) && (print_me_q[idx] == t_sfi_str_req)) begin
          uvm_report_info(header, $sformatf("%t: STRReq: %s", t_sfi_str_req, m_str_req_pkt.convert2string()), UVM_NONE);
       end
       if ((is2ndSMISTRReqRecd) && (print_me_q[idx] == t_2nd_sfi_str_req)) begin
          uvm_report_info(header, $sformatf("%t: 2nd STRReq: %s", t_2nd_sfi_str_req, m_2nd_str_req_pkt.convert2string()), UVM_NONE);
       end
       if ((isSMISTRRespSent) && (print_me_q[idx] == t_sfi_str_rsp)) begin
          uvm_report_info(header, $sformatf("%t: STRRsp: %s", t_sfi_str_rsp, m_str_rsp_pkt.convert2string()), UVM_NONE);
       end
       if ((is2ndSMISTRRespSent) && (print_me_q[idx] == t_2nd_sfi_str_rsp)) begin
          uvm_report_info(header, $sformatf("%t: 2nd STRRsp: %s", t_2nd_sfi_str_rsp, m_2nd_str_rsp_pkt.convert2string()), UVM_NONE);
       end
       if ((isSMIDTRReqRecd) && (print_me_q[idx] == t_sfi_dtr_req)) begin
	  $cast(dtr_type, m_dtr_req_pkt.smi_msg_type);
          uvm_report_info(header, $sformatf("%t: DTRReq %s %s", t_sfi_dtr_req, m_dtr_req_pkt.convert2string(), dtr_type.name()), UVM_NONE);
       end
       if ((isSMIDTRRespSent) && (print_me_q[idx] == t_sfi_dtr_rsp)) begin
          uvm_report_info(header, $sformatf("%t: DTRRsp %s", t_sfi_dtr_rsp, m_dtr_rsp_pkt.convert2string()), UVM_NONE);
       end
       if ((isSMIDTWReqSent) && (print_me_q[idx] == t_sfi_dtw_req)) begin
          if ((m_dtw_req_pkt.smi_msg_type >= dtw_type.first) && (m_dtw_req_pkt.smi_msg_type <= dtw_type.last)) begin
             $cast(dtw_type, m_dtw_req_pkt.smi_msg_type);
             uvm_report_info(header, $sformatf("%t: DTWReq: %s %s", t_sfi_dtw_req, m_dtw_req_pkt.convert2string(), dtw_type.name()), UVM_NONE);
          end else begin
             $cast(dtwMrgMrd_type, m_dtw_req_pkt.smi_msg_type);
             uvm_report_info(header, $sformatf("%t: DTWReq: %s %s", t_sfi_dtw_req, m_dtw_req_pkt.convert2string(), dtwMrgMrd_type.name()), UVM_NONE);
          end
       end
       if ((isSMIDTWRespRecd) && (print_me_q[idx] == t_sfi_dtw_rsp)) begin
          uvm_report_info(header, $sformatf("%t: DTWRsp: %s", t_sfi_dtw_rsp, m_dtw_rsp_pkt.convert2string()), UVM_NONE);
       end
       if ((isSMIUPDReqSent) && (print_me_q[idx] == t_sfi_upd_req)) begin
          uvm_report_info(header, $sformatf("%t: UPDReq: %s", t_sfi_upd_req, m_upd_req_pkt.convert2string()), UVM_NONE);
       end
       if ((isSMIUPDRespRecd) && (print_me_q[idx] == t_sfi_upd_rsp)) begin
          uvm_report_info(header, $sformatf("%t: UPDRsp: %s", t_sfi_upd_rsp, m_upd_rsp_pkt.convert2string()), UVM_NONE);
       end
  
       if ((isSMISNPDTRReqSent) && (print_me_q[idx] == t_sfi_dtr_req)) begin
	  $cast(dtr_type, m_dtr_req_pkt.smi_msg_type);
          uvm_report_info(header, $sformatf("%t: SNPDTRReq : %s %s", t_sfi_dtr_req, m_dtr_req_pkt.convert2string(), dtr_type.name()), UVM_NONE);
       end
       if ((isSMISNPDTRRespRecd) && (print_me_q[idx] == t_sfi_dtr_rsp)) begin
          uvm_report_info(header, $sformatf("%t: SNPDTRRsp : %s", t_sfi_dtr_rsp, m_dtr_rsp_pkt.convert2string()), UVM_NONE);
       end
       if ((isSenderSysReqNeeded) && (print_me_q[idx] == t_sfi_evt_req)) begin
          uvm_report_info(header, $sformatf("%t: SENDER_EVTREQ : %s", t_sfi_evt_req, evt_req_pkt.convert2string()), UVM_NONE);
       end
       if ((isSenderSysReqSent) && (print_me_q[idx] == t_sfi_sys_req)) begin
          uvm_report_info(header, $sformatf("%t: SENDER_SYSREQ : %s", t_sfi_sys_req, exp_sender_sys_req_pkt.convert2string()), UVM_NONE);
       end
       if ((isSenderSysRspRcvd) && (print_me_q[idx] == t_sfi_sys_rsp)) begin
          uvm_report_info(header, $sformatf("%t: SENDER_SYSRSP : %s", t_sfi_sys_rsp, exp_sender_sys_rsp_pkt.convert2string()), UVM_NONE);
       end
       if ((isSenderEventAckRcvd) && (print_me_q[idx] == t_sfi_evt_ack)) begin
          uvm_report_info(header, $sformatf("%t: SENDER_EVTACK : %s", t_sfi_evt_ack, evt_ack_pkt.convert2string()), UVM_NONE);
       end
       if ((isRecieverSysReqRcvd) && (print_me_q[idx] == t_sfi_sys_req_rcv)) begin
          uvm_report_info(header, $sformatf("%t: RECIEVER_SYSREQ  : %s", t_sfi_sys_req_rcv,  exp_reciever_sys_req_pkt.convert2string()), UVM_NONE);
       end
       if ((isRecieverEventReqSent) && (print_me_q[idx] == t_sfi_evt_req_rcv)) begin
          uvm_report_info(header, $sformatf("%t: RECIEVER_EVTREQ : %s", t_sfi_evt_req_rcv, evt_req_rcv.convert2string()), UVM_NONE);
       end
       if ((isRecieverEventAckSent) && (print_me_q[idx] == t_sfi_evt_ack_rcv)) begin
          uvm_report_info(header, $sformatf("%t: RECIEVER_EVTACK  : %s", t_sfi_evt_ack_rcv, evt_ack_rcv.convert2string()), UVM_NONE);
       end
       if ((isRecieverSysRspSent) && (print_me_q[idx] == t_sfi_sys_rsp_rcv)) begin
          uvm_report_info(header, $sformatf("%t: RECIEVER_SYSRSP : %s", t_sfi_sys_rsp_rcv,  exp_reciever_sys_rsp_pkt.convert2string()), UVM_NONE);
       end

<%if(obj.useCache) { %> 
       if ((isIoCacheTagPipelineSeen) && (print_me_q[idx] == t_ccp_ctrl_pkt)) begin
	  uvm_report_info(header, $sformatf("%t: CCPCtrlPkt: %s", t_ccp_ctrl_pkt, m_ccp_ctrl_pkt.sprint_pkt()), UVM_NONE);
       end

       if ((isIoCacheDataPipelineSeen && (isIoCacheEvict || isSnoop)) && (print_me_q[idx] == t_ccp_evict_pkt)) begin
          uvm_report_info(header, $sformatf("%t: CCPSnoopRspPkt: %s", t_ccp_evict_pkt, m_ccp_evict_pkt.sprint_pkt()), UVM_NONE);
       end
			      
       if ((isCCPFillCtrlSeen) && (print_me_q[idx] == t_ccp_fill_ctrl_pkt)) begin
	  uvm_report_info(header, $sformatf("%t: CCPFillCtrlPkt: %s", t_ccp_fill_ctrl_pkt, m_ccp_fillctrl_pkt_t.sprint_pkt()), UVM_NONE);
       end

       if ((isCCPFillDataSeen) && (print_me_q[idx] == t_ccp_fill_data_pkt)) begin
	  uvm_report_info(header, $sformatf("%t: CCPFillDataPkt: %s", t_ccp_fill_data_pkt, m_ccp_filldata_pkt.sprint_pkt()), UVM_NONE);
       end

       if ((isCCPReadHitDataRcvd) && (print_me_q[idx] == t_ccp_read_rsp_pkt)) begin
          uvm_report_info(header, $sformatf("%t: CCPReadRspPkt: %s", t_ccp_read_rsp_pkt, m_ccp_rd_rsp_pkt.sprint_pkt()), UVM_NONE);
       end

       if ((isCCPWriteHitDataRcvd) && (print_me_q[idx] == t_ccp_write_data_pkt)) begin
	  uvm_report_info(header, $sformatf("%t: CCPWriteDataPkt: %s", t_ccp_write_data_pkt, m_ccp_wr_data_pkt.sprint_pkt()), UVM_NONE);
       end
<% } %>
   end 
    endfunction : print_me

    //----------------------------------------------------------------------- 
    // Function to decode Ace command type from Ace address channel packet 
    //----------------------------------------------------------------------- 

    function void setup_ace_cmd_type();
        if (isRead) begin : if_isRead
            case({ m_ace_read_addr_pkt.ardomain, m_ace_read_addr_pkt.arsnoop})
                'b00_0000, 'b11_0000: m_ace_cmd_type = RDNOSNP;
                'b01_0000, 'b10_0000: m_ace_cmd_type = RDONCE;
                'b01_0001, 'b10_0001: m_ace_cmd_type = RDSHRD;
                'b01_0010, 'b10_0010: m_ace_cmd_type = RDCLN;
                'b01_0011, 'b10_0011: m_ace_cmd_type = RDNOTSHRDDIR;
                'b01_0111, 'b10_0111: m_ace_cmd_type = RDUNQ;
                'b01_1011, 'b10_1011: m_ace_cmd_type = CLNUNQ;
                'b01_1100, 'b10_1100: m_ace_cmd_type = MKUNQ;
                'b00_1000, 'b01_1000,
                'b10_1000             : m_ace_cmd_type = CLNSHRD;
                'b00_1001, 'b01_1001,
                'b10_1001             : m_ace_cmd_type = CLNINVL;
                'b00_1101, 'b01_1101,
                'b10_1101             : m_ace_cmd_type = MKINVL;
                 'b01_1110, 'b10_1110: m_ace_cmd_type = DVMCMPL;
                'b01_1111, 'b10_1111: m_ace_cmd_type = DVMMSG;
                'b00_1010, 'b01_1010,
                'b10_1010             : m_ace_cmd_type = CLNSHRDPERSIST;
	        'b01_0101, 'b10_0101: m_ace_cmd_type = RDONCEMAKEINVLD;
	        'b01_0100, 'b10_0100: m_ace_cmd_type = RDONCECLNINVLD;

                default             : uvm_report_error($sformatf("<%=obj.strRtlNamePrefix%> SCB ERROR", m_req_aiu_id), $sformatf("Undefined read address channel snoop type: ID:\
                                                                                   0x%0x Addr:0x%0x Bar:0x%0x Domain:0x%0x Snoop:0x%0x"
                                                                               , m_ace_read_addr_pkt.arid, m_ace_read_addr_pkt.araddr, m_ace_read_addr_pkt.arbar, m_ace_read_addr_pkt.ardomain, m_ace_read_addr_pkt.arsnoop),UVM_NONE);
            endcase
	   m_ace_read_addr_pkt.arcmdtype = m_ace_cmd_type;
        end : if_isRead
        else if (isWrite || isUpdate) begin :is_Write_or_Update
	    if(m_ace_write_addr_pkt.awatop !== 0) begin
               case(m_ace_write_addr_pkt.awatop[5:3])
		 'b010,'b011 : m_ace_cmd_type = ATMSTR;
		 'b100,'b101 : m_ace_cmd_type = ATMLD;
		 'b110       : begin
		    case(m_ace_write_addr_pkt.awatop[2:0])
		      'b000       : m_ace_cmd_type = ATMSWAP;		 
		      'b001       : m_ace_cmd_type = ATMCOMPARE;
                      default             : uvm_report_error($sformatf("<%=obj.strRtlNamePrefix%> SCB ERROR", m_req_aiu_id), $sformatf("Undefined AWATOP 0x%0b Addr:0x%0x", m_ace_write_addr_pkt.awatop,m_ace_write_addr_pkt.awaddr),UVM_NONE);
		    endcase // case (m_ace_write_addr_pkt.awatop[2:0])
		 end
                 default             : uvm_report_error($sformatf("<%=obj.strRtlNamePrefix%> SCB ERROR", m_req_aiu_id), $sformatf("Undefined AWATOP 0x%0b Addr:0x%0x", m_ace_write_addr_pkt.awatop,m_ace_write_addr_pkt.awaddr),UVM_NONE);
	       endcase
	    end else begin
               <%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
                if (addrMgrConst::get_addr_gprar_nc(m_ace_write_addr_pkt.awaddr)) begin 
               m_ace_cmd_type = WRNOSNP;
                end else begin 
               m_ace_cmd_type = WRUNQ;
               end
               <% } else { %>
               case({m_ace_write_addr_pkt.awsnoop,  m_ace_write_addr_pkt.awdomain}) 
		 'b0_000_00,  'b0_000_11       : m_ace_cmd_type = WRNOSNP;
                 'b0_000_01,  'b0_000_10       : m_ace_cmd_type = WRUNQ;
                 'b0_001_01,  'b0_001_10       : m_ace_cmd_type = WRLNUNQ;
                 'b0_010_00,  'b0_010_01,
		 'b0_010_10                      : m_ace_cmd_type = WRCLN;
                 'b0_011_00,  'b0_011_01,
		 'b0_011_10                      : m_ace_cmd_type = WRBK;
                 'b0_100_01,  'b0_100_10       : m_ace_cmd_type = EVCT;
                 'b0_101_00,  'b0_101_01,
		 'b0_101_10                      : m_ace_cmd_type = WREVCT;
                 'b0_000_00,  'b0_000_01,
                 'b0_000_10,  'b0_000_11       : m_ace_cmd_type = BARRIER;
                 'b1_000_01,  'b1_000_10       : m_ace_cmd_type = WRUNQPTLSTASH;
                 'b1_001_01,  'b1_001_10       : m_ace_cmd_type = WRUNQFULLSTASH;
                 'b1_100_01,  'b1_100_10       : m_ace_cmd_type = STASHONCESHARED;
                 'b1_101_01,  'b1_101_10       : m_ace_cmd_type = STASHONCEUNQ;
                 'b1_110_00,  'b1_110_01,
		 'b1_110_10,  'b1_110_11       : m_ace_cmd_type = STASHTRANS;
                 default           : uvm_report_error($sformatf("<%=obj.strRtlNamePrefix%> SCB ERROR", m_req_aiu_id), $sformatf("Undefined write address channel snoop type: Act:0x%b ID:0x%0x Addr:0x%0x snoop:%0b  Domain:%0b AtoP:%0b",
												       {m_ace_write_addr_pkt.awsnoop,  m_ace_write_addr_pkt.awdomain},
												       m_ace_write_addr_pkt.awid, m_ace_write_addr_pkt.awaddr, m_ace_write_addr_pkt.awsnoop,  m_ace_write_addr_pkt.awdomain, m_ace_write_addr_pkt.awatop),UVM_NONE);
               endcase // case ({m_ace_write_addr_pkt.awbar[0], m_ace_write_addr_pkt.awdomain, m_ace_write_addr_pkt.awsnoop})
               <%}%>
	    end // else: !if(m_ace_write_addr_pkt.awatop !== 0)
               m_ace_write_addr_pkt.awcmdtype = m_ace_cmd_type;
        end : is_Write_or_Update
        else begin
            uvm_report_error($sformatf("<%=obj.strRtlNamePrefix%> SCB ERROR", m_req_aiu_id), $sformatf("SCB Error: Should not reach setup_ace_cmd_type if type is not isRead/isWrite"),UVM_NONE);
        end
        if(isRead) begin
            uvm_report_info(`LABEL, $sformatf("Read address channel snoop type: %0s Act:0x%b ID:0x%0x Addr:0x%0x  Domain:0x%0x Snoop:0x%0x", m_ace_cmd_type, {m_ace_read_addr_pkt.arsnoop,  m_ace_read_addr_pkt.ardomain}, m_ace_read_addr_pkt.arid, m_ace_read_addr_pkt.araddr,  m_ace_read_addr_pkt.ardomain, m_ace_read_addr_pkt.arsnoop),UVM_MEDIUM);
        end else if (isWrite || isUpdate) begin
            uvm_report_info(`LABEL, $sformatf("Write address channel snoop type: %0s Act:0x%b ID:0x%0x Addr:0x%0x  Domain:0x%0x Snoop:0x%0x AtoP:%0b", m_ace_cmd_type, {m_ace_write_addr_pkt.awsnoop,  m_ace_write_addr_pkt.awdomain}, m_ace_write_addr_pkt.awid, m_ace_write_addr_pkt.awaddr,  m_ace_write_addr_pkt.awdomain, m_ace_write_addr_pkt.awsnoop, m_ace_write_addr_pkt.awatop),UVM_MEDIUM);
        end
    endfunction : setup_ace_cmd_type 

    //----------------------------------------------------------------------- 
    // Function to get the order field for this address 
    //----------------------------------------------------------------------- 

    function void setup_gpra_order(axi_axaddr_t addr);
        int transOrderMode_tmp;
        if(isRead || isDVM) begin
		   transOrderMode = transOrderMode_rd;
        end else begin
		   transOrderMode = transOrderMode_wr;
        end
    	pcieOrderMode_en = (transOrderMode == pcieOrderMode) ? 1 : 0;
    	
    	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
		if (pcieOrderMode_en == 1)
			`uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("ACE interface should always be programmed with strictReqMode"))
    	<%}%>

<%if(obj.NO_ADDR_MGR) { %>	
        gpra_order = 0;
<% } else { %>
        if($value$plusargs("gpra_order=%b", gpra_order)) return;
        else begin
            gpra_order = addrMgrConst::get_addr_memorder(addr);
            uvm_report_info($sformatf("<%=obj.strRtlNamePrefix%> SCB TXN"), $sformatf("Got gpra_order from addr manager. gpra_order: %p, get_addr_memorder:%0x for addr:%0x", gpra_order, addrMgrConst::get_addr_memorder(addr), addr), UVM_DEBUG); 
        end 
<% } %>
    endfunction : setup_gpra_order

    //----------------------------------------------------------------------- 
    // Function to calculate DCE and DMI unit ID for this address 
    //----------------------------------------------------------------------- 

    function void setup_dce_dmi_id_for_req();
<%if(obj.NO_ADDR_MGR) { %>	
	home_dce_unit_id = <%=obj.DceInfo[0].FUnitId%>;
        // #Check.AIU.ErrorReservedMemory
        home_dmi_unit_id = <%=obj.DmiInfo[0].FUnitId%>;
<% } else { %>
        
   		//DVM will always go to DVE
		home_dce_unit_id = (isDVM) ? DVE_FUNIT_IDS[0] : addrMgrConst::map_addr2dce(m_sfi_addr);
        // #Check.AIU.ErrorReservedMemory
        home_dmi_unit_id = (isDVM) ? DVE_FUNIT_IDS[0] : addrMgrConst::map_addr2dmi_or_dii(m_sfi_addr, memRegion);
        
        if (home_dmi_unit_id == -1)
          `uvm_fatal($sformatf("NCBU%0d SCB", m_req_aiu_id), "Illegal DMI-ID")

<% } %>
    endfunction : setup_dce_dmi_id_for_req

    function axi_axaddr_t shift_addr(input axi_axaddr_t in_addr);
        axi_axaddr_t out_addr;
        out_addr = in_addr[WAXADDR - 1:SYS_wSysCacheline];
        return out_addr;
    endfunction : shift_addr

<%if(obj.useCache) { %>
function int onehot_to_binary(bit [N_WAY-1:0] in_word);
    int position;
    
    position = -1;
    for(int i=0; i<$size(in_word); i++) begin
        if(in_word[i] == 1) begin
            position = i;
            break;
        end
    end

    return position;
endfunction : onehot_to_binary
<% } %>

    function void setup_dvm_snp_req(smi_seq_item snp_req);
    		
        isDVMSnoop            = 1;
        //If a DVM snoop is issued in multiple portions, each portion is uniquely numbered in order. 
        //MPF3 carries the ordinal identifier for the portion of a given DVMOp snoop.0: Portion 1; 1: Portion 2; etc.
        if(snp_req.smi_mpf3_dvmop_portion == 0) begin //Portion 1
            if(snp_req.smi_addr[13:11] == 'b100) //AMBA Table C12-9
               txn_type	= "DVMSYNC";
            else
               txn_type    = "DVM";
            
            if(snp_req.smi_addr[4] == 'b0)
               smi_flags["single_part_dvm"] = 1;
            else
               smi_flags["single_part_dvm"] = 0;

            smi_act["SMISnpReq"]         = snp_req;
            smi_act["SMISnpReqDvm1"]     = snp_req;

            smi_flags["SMISnpReqDvm1"]   = 1;
                                                               
            t_creation                     = $time;
            t_latest_update                = $time;
            smi_act_time["SMISnpReqDvm1"]  = $time;

            smi_exp_flags["SMISnpReq"]     = 1; 
            smi_exp_flags["SMISnpReqDvm2"] = 1;
        end
        else begin //!if(snp_req.smi_mpf3_dvmop_portion == 0) //Portion 2
           smi_act["SMISnpReqDvm2"]       = snp_req;
           smi_flags["SMISnpReqDvm2"]     = 1;

           t_latest_update                = $time;
           smi_act_time["SMISnpReqDvm2"]  = $time;

           smi_exp_flags["SMISnpReq"]     = 0;
           smi_exp_flags["SMISnpReqDvm2"] = 0;

           smi_exp_flags["ACESnpReq"]      = 1;
           smi_exp_flags["ACESnpReqDvm1"]  = 1;
        end

        if((smi_flags["SMISnpReqDvm1"] == 1) && (smi_flags["SMISnpReqDvm2"] == 1)) begin
    
            m_ace_snoop_addr_pkt0_exp = new();
            m_ace_snoop_addr_pkt0_exp.acaddr = concerto_dvm_snp_to_ace_dvm_snp(0);
            //#Check.IOAIU.DVMSnooper.SMISnp_ACVmidExt_Mapping
            m_ace_snoop_addr_pkt0_exp.acvmid = smi_act["SMISnpReqDvm1"].smi_mpf1_vmid_ext[3:0];
            m_ace_snoop_addr_pkt0_exp.acsnoop = 'b1111; //Setting SnpType to DVMMSG
            
            m_ace_snoop_addr_pkt1_exp = new();
            m_ace_snoop_addr_pkt1_exp.acaddr = concerto_dvm_snp_to_ace_dvm_snp(1);
            //#Check.IOAIU.DVMSnooper.SMISnp_ACVmidExt_Mapping
            m_ace_snoop_addr_pkt1_exp.acvmid = smi_act["SMISnpReqDvm1"].smi_mpf1_vmid_ext[7:4];
            m_ace_snoop_addr_pkt1_exp.acsnoop = 'b1111; //Setting SnpType to DVMMSG
            
            //#Check.IOAIU.ACE.ACTRACE
            <%if(aiu_axiInt.params.eTrace > 0) { %>
            m_ace_snoop_addr_pkt0_exp.actrace = snp_req.smi_tm;
            m_ace_snoop_addr_pkt1_exp.actrace = snp_req.smi_tm;
            <% } %>
        end
    
    endfunction : setup_dvm_snp_req
    
    //Check.IOAIU.AXI.AC.AddrTranslation
    // CCMP TABLE 7-24 Format of two DVM SNPreq messages
    // IHI0022H_c_amba_axi_protocol_spec.pdf D13.3.5 
    function smi_addr_t concerto_dvm_snp_to_ace_dvm_snp(int snp_no);
        smi_addr_t ret_acsnp_addr = 0; //this is actually ac snoop address
        //#Check.IOAIU.DVMSnooper.SMISnp_ACAddr_Mapping
    
        if(snp_no == 0) begin
            ret_acsnp_addr[0]     = smi_act["SMISnpReqDvm1"].smi_addr[4];             //Single/Two parts
            ret_acsnp_addr[3:2]   = smi_act["SMISnpReqDvm1"].smi_addr[39:38];         //Staged Invalidation
            ret_acsnp_addr[4]     = smi_act["SMISnpReqDvm1"].smi_addr[40];            //Leaf Entry Invalidation
            ret_acsnp_addr[5]     = smi_act["SMISnpReqDvm1"].smi_addr[6];             //ASID bits Valid
            ret_acsnp_addr[6]     = smi_act["SMISnpReqDvm1"].smi_addr[5];             //VMID bits Valid
            ret_acsnp_addr[7]     = smi_act["SMISnpReqDvm1"].smi_mpf3_range;          //Range
            ret_acsnp_addr[9:8]   = smi_act["SMISnpReqDvm1"].smi_addr[8:7];           //Security
            ret_acsnp_addr[11:10] = smi_act["SMISnpReqDvm1"].smi_addr[10:9];          //Guest/Hypervisor
            ret_acsnp_addr[14:12] = smi_act["SMISnpReqDvm1"].smi_addr[13:11];         //DVMOp Type
            ret_acsnp_addr[15]    = txn_type == "DVMSYNC" ? 1 : 0;                    //Completion Bit (Set only for DVM Op Sync)
            ret_acsnp_addr[23:16] = smi_act["SMISnpReqDvm1"].smi_addr[29:22];         //ASID[7:0] or Vritual Index VA[19:12]
            ret_acsnp_addr[31:24] = smi_act["SMISnpReqDvm1"].smi_addr[21:14];         //VMID[7:0] or Vritual Index VA[27:20]
            ret_acsnp_addr[39:32] = smi_act["SMISnpReqDvm1"].smi_addr[37:30];         //ASID[15:8]
            ret_acsnp_addr[43:40] = smi_flags["single_part_dvm"] == 1 ?
                                   smi_act["SMISnpReqDvm1"].smi_mpf1_vmid_ext[7:4]:
                                   {smi_act["SMISnpReqDvm1"].smi_addr[43:41],
                                    smi_act["SMISnpReqDvm2"].smi_addr[43]} ;         //if one part snoop: VMID[15:12]. if two part snoop: VA[48:45]
            ret_acsnp_addr[47:44] = smi_act["SMISnpReqDvm2"].smi_mpf1_vmid_ext[3:0];  //VA[56:53]
        end 
        else begin
            //smi_mpf3_num=5'{MPF3[5:4],MPF3[3:1]}//MPF3[0] = snoop number //(snpreq0 :0, snpreq1 :1)
            //ret_acsnp_addr[2:0]=smi_mpf3_num[2:0],ret_acsnp_addr[5:4]=smi_mpf3_num[4:3]
            ret_acsnp_addr[0]     = smi_act["SMISnpReqDvm2"].smi_mpf3_num[0];     //NUM[0]
            ret_acsnp_addr[1]     = smi_act["SMISnpReqDvm2"].smi_mpf3_num[1];     //NUM[1]
            ret_acsnp_addr[2]     = smi_act["SMISnpReqDvm2"].smi_mpf3_num[2];     //NUM[2]
            ret_acsnp_addr[4]     = smi_act["SMISnpReqDvm2"].smi_mpf3_num[3];     //NUM[3]/VA[4]
            ret_acsnp_addr[5]     = smi_act["SMISnpReqDvm2"].smi_mpf3_num[4];     //NUM[4]/VA[5]
            ret_acsnp_addr[7:6]   = smi_act["SMISnpReqDvm2"].smi_addr[5:4];         //Scale[1:0]/VA[7:6]/PA[7:6]
            ret_acsnp_addr[9:8]   = smi_act["SMISnpReqDvm2"].smi_addr[7:6];         //TTL[1:0]/VA[9:8]/PA[9:8]
            ret_acsnp_addr[11:10] = smi_act["SMISnpReqDvm2"].smi_addr[9:8];         //TG[1:0]/VA[11:10]/PA[11:10]
            ret_acsnp_addr[39:12] = smi_act["SMISnpReqDvm2"].smi_addr[37:10];       //VA[39:12]/PA[39:12]

            if (smi_act["SMISnpReqDvm1"].smi_addr[13:11] == 3'b010) begin            //DVM MSG Type PICI (Physical Instruction Cache Invalidate)
                ret_acsnp_addr[40]    = smi_act["SMISnpReqDvm2"].smi_addr[38];       //PA[40]
                ret_acsnp_addr[44:41] = smi_act["SMISnpReqDvm2"].smi_addr[42:39];    //PA[44:41]
                ret_acsnp_addr[45]    = smi_act["SMISnpReqDvm2"].smi_addr[43];       //PA[45]
                ret_acsnp_addr[46]    = smi_act["SMISnpReqDvm2"].smi_addr[44];       //PA[46]
                ret_acsnp_addr[47]    = smi_act["SMISnpReqDvm2"].smi_addr[45];       //PA[47]
            end else begin
                //<%//if(aiu_axiInt.params.wAddr>40) {%>         //CONC-12977 extra layer of constraint, already added in system_bfm_seq :: ACADDR[3] is SBZ when wAddr < 41 for 2nd AC Snoop DVM Req as per ARM Spec IHI 0022H.c Table D13-6
                ret_acsnp_addr[3]     = smi_act["SMISnpReqDvm2"].smi_addr[38];       //VA[40]
                //<%//} else {%>
                //ret_acsnp_addr[3]     = 1'b0;
                //<%//}%>
                ret_acsnp_addr[43:40] = smi_act["SMISnpReqDvm2"].smi_addr[42:39];    //VA[44:41]
                ret_acsnp_addr[44]    = smi_act["SMISnpReqDvm2"].smi_addr[44];       //VA[49]
                ret_acsnp_addr[46]    = smi_act["SMISnpReqDvm2"].smi_addr[45];       //VA[51]
                ret_acsnp_addr[45]    = smi_act["SMISnpReqDvm1"].smi_addr[44];       //VA[50]
                ret_acsnp_addr[47]    = smi_act["SMISnpReqDvm1"].smi_addr[45];       //VA[52]
            end
        end 
    
        return ret_acsnp_addr;
    endfunction : concerto_dvm_snp_to_ace_dvm_snp
    
    function bit matchSMISnpReq(smi_seq_item m_pkt);
        bit retvalue = smi_exp_flags["SMISnpReq"];
        case(txn_type)
            "DVM","DVMSYNC" : return ((m_pkt.smi_msg_type != SNP_DVM_MSG) || (m_pkt.smi_mpf3_dvmop_portion == 0)) ? 0 :
                           (((smi_exp_flags["SMISnpReqDvm2"]) ? (smi_act["SMISnpReqDvm1"].smi_mpf2_dvmop_id  == m_pkt.smi_mpf2_dvmop_id) : 0));
            default : return 0;
        endcase
    endfunction : matchSMISnpReq

    function bit matchACESnpReq(ace_snoop_addr_pkt_t m_pkt);
        case(txn_type)
	      "DVM","DVMSYNC" : begin
	        if (smi_exp_flags["ACESnpReq"] == 0) begin
		        return 0;
	        end else begin 
		        // if PICI type DVM, addr bit[40] is don't care and needs to be ignored in 1st snoop
		        if (smi_act["SMISnpReqDvm1"].smi_addr[13:11] == 3'b010) begin
		            m_ace_snoop_addr_pkt0_exp.acaddr[40] = m_pkt.acaddr[40];
		        end
       		    return
                      ((smi_exp_flags["ACESnpReqDvm1"] && (m_pkt.acaddr == m_ace_snoop_addr_pkt0_exp.acaddr)) ||
                       (smi_exp_flags["ACESnpReqDvm2"] && (m_pkt.acaddr == m_ace_snoop_addr_pkt1_exp.acaddr)));
	        end
	      end
       	  default : return 0;
      endcase
	endfunction : matchACESnpReq

    function void setup_ace_dvm_snp_req(ace_snoop_addr_pkt_t m_pkt);

        if(smi_flags["ACESnpReqDvm1"] != 1) begin
	        m_ace_snoop_addr_pkt0_act       = m_pkt;
            if (!m_ace_snoop_addr_pkt0_exp.do_compare_pkts(m_ace_snoop_addr_pkt0_act)) begin
                `uvm_error("ioaiu_scb_txn compare ERROR", $psprintf("IOAIU_UID:%0d ACESnpReqDvm1 Packet Mismatch Expected : %0s , Received: %0s", tb_txnid, m_ace_snoop_addr_pkt0_exp.sprint_pkt(), m_ace_snoop_addr_pkt0_act.sprint_pkt()))
            end
	        smi_flags["ACESnpReqDvm1"]      = 1;
	        t_latest_update                 = $time;
	        smi_act_time["ACESnpReqDvm1"]   = $time;
	        smi_exp_flags["ACESnpReqDvm1"]  = 0;
	        smi_exp_flags["ACESnpRsp"]      = 1;
	        smi_exp_flags["ACESnpRspDvm1"]  = 1;
            if(smi_flags["single_part_dvm"]) begin
                if(txn_type == "DVMSYNC") begin
	                smi_exp_flags["ACEReadAddr"] = 1;
                end
	            smi_exp_flags["ACESnpReq"]      = 0;
            end
            else begin
	            smi_exp_flags["ACESnpReq"]      = 1;
	            smi_exp_flags["ACESnpReqDvm2"]  = 1;
            end
        end
        else begin
	        m_ace_snoop_addr_pkt1_act       = m_pkt;
            if (!m_ace_snoop_addr_pkt1_exp.do_compare_pkts(m_ace_snoop_addr_pkt1_act))begin
                `uvm_error("ioaiu_scb_txn compare ERROR", $psprintf("IOAIU_UID:%0d ACESnpReqDvm2 Packet Mismatch Expected : %0s , Received: %0s", tb_txnid, m_ace_snoop_addr_pkt1_exp.sprint_pkt(), m_ace_snoop_addr_pkt1_act.sprint_pkt()))
            end
	        smi_flags["ACESnpReqDvm2"]      = 1;
	        t_latest_update                 = $time;
	        smi_act_time["ACESnpReqDvm2"]   = $time;
	        smi_exp_flags["ACESnpReq"]      = 0;
	        smi_exp_flags["ACESnpReqDvm2"]  = 0;
	        smi_exp_flags["ACESnpRspDvm2"]  = 1;
	        smi_exp_flags["ACESnpRsp"]      = 1;
            if(txn_type == "DVMSYNC") begin
	            smi_exp_flags["ACEReadAddr"] = 1;
            end
        end
//      matchExp();
    endfunction : setup_ace_dvm_snp_req

    function bit matchACESnpRsp(ace_snoop_resp_pkt_t m_pkt);
        bit retvalue = smi_exp_flags["ACESnpRsp"];
        case(txn_type)
        "DVM","DVMSYNC" : return retvalue  && 
                          ((smi_flags["ACESnpReqDvm1"] && !smi_flags["SMISnpRspDvm1"]) ||
	 		              (smi_flags["ACESnpReqDvm2"] && !smi_flags["SMISnpRspDvm2"])) ;
        default : return 0;
        endcase 
    endfunction : matchACESnpRsp

    function void setup_ace_dvm_snp_rsp(ace_snoop_resp_pkt_t m_pkt);
        if(smi_flags["ACESnpReqDvm1"] && !smi_flags["ACESnpRspDvm1"]) begin
	        m_ace_snoop_resp_pkt0_act       = m_pkt;
	        smi_flags["ACESnpRspDvm1"]      = 1;
	        t_latest_update                 = $time;
	        smi_act_time["ACESnpRspDvm1"]   = $time;
  
	        smi_exp_flags["ACESnpRspDvm1"]  = 0;
	        if(smi_flags["ACESnpRspDvm2"])
	            smi_exp_flags["ACESnpRsp"]   = 0;
            if(smi_flags["single_part_dvm"]) begin
               if(txn_type != "DVMSYNC") begin
                smi_exp_flags["SMISnpRsp"]  = 1;
               end
                smi_exp_flags["ACESnpRsp"] = 0;
            end
        end
        else if(smi_flags["ACESnpReqDvm1"] && smi_flags["ACESnpRspDvm1"] && 
	        smi_flags["ACESnpReqDvm2"] && !smi_flags["ACESnpRspDvm2"]) begin
	        m_ace_snoop_resp_pkt1_act       = m_pkt;
	        smi_flags["ACESnpRspDvm2"]      = 1;
	        t_latest_update                 = $time;
	        smi_act_time["ACESnpRspDvm2"]   = $time;
	  													
	        smi_exp_flags["ACESnpRspDvm2"]  = 0;
	        if(smi_flags["ACESnpRspDvm1"])
	            smi_exp_flags["ACESnpRsp"]   = 0;
	      
            if(txn_type != "DVMSYNC")
	            smi_exp_flags["SMISnpRsp"]   = 1;
        end
    endfunction : setup_ace_dvm_snp_rsp

    function bit matchSMISnpRsp(smi_seq_item m_pkt);
        bit retvalue = smi_exp_flags["SMISnpRsp"];
        case(txn_type)
        "DVM","DVMSYNC" : return retvalue && 
                          (smi_act["SMISnpReqDvm1"].smi_msg_id == m_pkt.smi_rmsg_id);
        default : return 0;
        endcase // case (txn_type)
    endfunction : matchSMISnpRsp

    function void setup_smi_dvm_snp_rsp(smi_seq_item snp_rsp);
       smi_act["SMISnpRsp"]         = snp_rsp;
       smi_act["SMISnpRspDvm"]      = snp_rsp;
       smi_flags["SMISnpRspDvm"]    = 1;
 
       t_latest_update              = $time;
       smi_act_time["SMISnpRspDvm"] = $time;
 
       smi_exp_flags["SMISnpRspDvm"] = 0;
       smi_exp_flags["SMISnpRsp"]    = 0;
       if(smi_act["SMISnpReqDvm1"].smi_tm != snp_rsp.smi_tm) begin
         uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("DVM SnpRsp has TM field mismatch. Exp: %b, Real: %b. SnpRsp:%s", smi_act["SMISnpReqDvm1"].smi_tm, snp_rsp.smi_tm, snp_rsp.convert2string),UVM_NONE);
       end
    endfunction : setup_smi_dvm_snp_rsp

    function bit matchACEReadAddr(ace_read_addr_pkt_t m_pkt);
        bit retvalue = smi_exp_flags["ACEReadAddr"];
        case(txn_type)
        "DVMSYNC" : return retvalue && ((m_pkt.arbar[0] == 0) && ((m_pkt.ardomain == 2'b01) || (m_pkt.ardomain == 2'b10)) && ((m_pkt.arsnoop == 'b1110) || (m_pkt.arsnoop == 'b1111)));//This is a DVM Completion AMBA4 C3-7
        default : return 0;
        endcase
    endfunction : matchACEReadAddr

    function void setup_ace_dvm_cmp_read_addr(ace_read_addr_pkt_t m_pkt);
        m_ace_read_addr_pkt               = m_pkt;
        smi_flags["ACEReadAddr"]          = 1;
        t_latest_update                   = $time;
        t_ace_read_recd                   = $time;
        smi_act_time["ACEReadAddr"]       = $time;
        smi_exp_flags["ACEReadAddr"]      = 0;
        smi_exp_flags["ACEReadResp"]      = 1;
        smi_exp_flags["ACEReadData"]      = 1;
        //FIXME move to setup_ace_dvm_cmp_resp
        if(txn_type == "DVMSYNC")
	        smi_exp_flags["SMISnpRsp"]        = 1;
        m_ace_cmd_type                    = DVMCMPL;
    endfunction : setup_ace_dvm_cmp_read_addr
 
    function void setup_ace_dvm_cmp_resp(ace_read_data_pkt_t m_pkt);
       m_ace_read_data_pkt               = m_pkt;
       smi_flags["ACEReadResp"]          = 1;
       smi_flags["ACEReadData"]          = 1;
       t_latest_update                   = $time;
       smi_act_time["ACEReadResp"]       = $time;
       smi_act_time["ACEReadData"]       = $time;
       smi_exp_flags["ACEReadResp"]      = 0;
       smi_exp_flags["ACEReadData"]      = 0;
       smi_exp_flags["ACEReadDataAck"]   = 1;
       isACEReadDataSentNoRack           = 1;
    endfunction : setup_ace_dvm_cmp_resp

    //#Check.IOAIU.AXI.AXItoConcertoTranslation
    //#Check.IOAIU.AXI.CONC.DvmSingleSnoopFlow
    function bit matchACEReadData(ace_read_data_pkt_t m_pkt);
        bit retvalue = smi_exp_flags["ACEReadData"];
        case(txn_type)
        "DVMSYNC" : return retvalue && (smi_flags["ACEReadAddr"]) && (m_pkt.rid == m_ace_read_addr_pkt.arid);//This is a DVM Completion AMBA4 C3-7
        default : return 0;
        endcase
    endfunction : matchACEReadData

endclass : ioaiu_scb_txn

function bit ioaiu_scb_txn::matchSmi(smi_seq_item m_pkt);
	//DCTODO
	if(m_pkt.isCmdMsg()) begin : if_isCmdMsg
	   if(isSMICMDReqSent) begin
	       return ((m_cmd_req_pkt.smi_msg_id === m_pkt.smi_msg_id) && (m_cmd_req_pkt.smi_src_id === m_pkt.smi_src_id));
	   end 
           else begin
	       if(isWrite) begin
	           //DCTODO item.m_ace_write_addr_pkt.awprot[1]      === m_pkt.cmd_req.req_security &&
	           return m_ace_write_addr_pkt.awaddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  === m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)];
	       end else if(isRead) begin
//DCTODO           item.m_ace_read_addr_pkt.arprot[1]      === m_pkt.cmd_req.req_security && 
                  return m_ace_read_addr_pkt.araddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  === m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)];
	       end
	   end
	end : if_isCmdMsg
	else if(m_pkt.isDtrMsg()) begin
	   if(m_pkt.smi_src_id === <%=obj.Id%>)
	       return ((m_cmd_req_pkt.smi_msg_id === m_pkt.smi_msg_id) && (m_cmd_req_pkt.smi_src_id === m_pkt.smi_src_id));
	   else
	       return ((m_snp_req_pkt.smi_msg_id === m_pkt.smi_msg_id) && (m_cmd_req_pkt.smi_src_id === m_pkt.smi_src_id));
	end
	else if(m_pkt.isStrMsg()) begin
	    return ((m_cmd_req_pkt.smi_msg_id === m_pkt.smi_msg_id) && (m_cmd_req_pkt.smi_src_id === m_pkt.smi_src_id));
	end
	else if(m_pkt.isDtwMsg()) begin
	    return 1;
	end

	return 0;
endfunction : matchSmi

function bit ioaiu_scb_txn::matchNS(smi_seq_item m_pkt);
<%if(obj.wSecurityAttribute > 0) { %>
   return m_security == m_pkt.smi_ns;
<% } else { %>
   return 1 ;
<% } %>
endfunction : matchNS

function bit ioaiu_scb_txn::matchAddr(smi_seq_item m_pkt);
    if (m_sfi_addr  == m_pkt.smi_addr)
        return 1;
    else 
        return 0;
endfunction: matchAddr

function bit ioaiu_scb_txn::matchAux(smi_seq_item m_pkt);
   return m_user == m_pkt.smi_ndp_aux;
endfunction : matchAux

function bit ioaiu_scb_txn::higherPriorityThan(ioaiu_scb_txn pkt);
   int retVal = 0;
   if(isWrite && pkt.isWrite) begin
      retVal = (m_ace_write_addr_pkt.awqos > pkt.m_ace_write_addr_pkt.awqos) ? 1 : 0;
   end
   else if(isWrite && pkt.isRead) begin
      retVal = 0;
   end 
   else if(isRead && pkt.isWrite) begin
      retVal = 0;
   end
   else if(isRead && pkt.isRead) begin
      retVal = (m_ace_read_addr_pkt.arqos > pkt.m_ace_read_addr_pkt.arqos) ? 1 : 0;
   end
   return retVal;
endfunction : higherPriorityThan
      
function bit ioaiu_scb_txn::matchQos(smi_seq_item pktA);
   int retval = 0;
   <%if(obj.eStarve && obj.eAge && (obj.AiuInfo[obj.Id].QosInfo.qosMap.length > 0)) { %>
     if($test$plusargs("disable_qos_check")) begin
        retval = 1;
     end
     else if(isRead) begin
//	retval = (pktA.smi_qos == addrMgrConst::qos_mapping(m_ace_read_addr_pkt.arqos)) ? 1 : 0;
	retval = (pktA.smi_qos == m_ace_read_addr_pkt.arqos) ? 1 : 0;
      end
      else if(isWrite) begin
	retval = (pktA.smi_qos == m_ace_write_addr_pkt.awqos) ? 1 : 0;
//	retval = (pktA.smi_qos == addrMgrConst::qos_mapping(m_ace_write_addr_pkt.awqos)) ? 1 : 0;
      end
   <% } else { %>
      retval = 1;
   <% } %>
   retval = 1;
   return retval;
endfunction : matchQos
      
function bit ioaiu_scb_txn::matchDtwToCmd(smi_seq_item m_pkt);
   //#Check.IOAIU.SMI.DTWReq.MessageID
   case(m_pkt.smi_msg_type)
     eCmdRdNC, eCmdWrNCFull,eCmdWrNCPtl : begin
       if(isIoCacheEvict) begin
	  return (m_cmd_req_pkt.smi_msg_id === m_pkt.smi_msg_id ) &&
	    (m_cmd_req_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]);
       end
       else begin
	  return (m_cmd_req_pkt.smi_msg_id === m_pkt.smi_msg_id ) &&
	    (m_cmd_req_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]);
       end
	
     end
     default : begin
       return (m_cmd_req_pkt.smi_msg_id === m_pkt.smi_msg_id ) &&
	 (m_cmd_req_pkt.smi_dest_id == m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]);
     end
   endcase // case (m_pkt.smi_msg_type)
endfunction : matchDtwToCmd
      
function bit ioaiu_scb_txn::matchDtwToTxn(smi_seq_item m_pkt);
   bit ret_val = 0;
//#Check.IOAIU.CONC.DTWReq.Expected
//#Check.IOAIU.SMI.DTWReq.MatchID
//#Check.IOAIU.CONC.StashDTWDTW   
//#Check.IOAIU.SMI.DtwReq.RBID
   
   ret_val = (isStrRspEligibleForIssue() === 0);
   ret_val = ret_val && isSMIDTWReqNeeded && !isSMIDTWReqSent;
   
   if(isWrite) begin
      ret_val = ret_val && (((isSMICMDReqSent) ? matchDtwToCmd(m_pkt) : 0) &&
                            (isACEWriteDataRecd ||
                             (isMultiAccess &&
                              !isMultiLineMaster                  === 0)) &&
                            isSMICMDReqSent && isSMISTRReqRecd && 
                            (is2ndSMICMDReqNeeded ? (is2ndSMICMDReqSent && is2ndSMISTRReqRecd) : 1) &&
                            (m_pkt.smi_targ_ncore_unit_id != DVE_FUNIT_IDS[0]) &&
                            isSMIDTWReqNeeded && !isSMIDTWReqSent);
   end
   else if(isUpdate) begin
       ret_val = ret_val &&
//                 (((isSMICMDReqSent) ? (m_cmd_req_pkt.smi_msg_id === m_pkt.smi_msg_id ) && 
                 (((isSMICMDReqSent) ? matchDtwToCmd(m_pkt) : 0) &&
                  (m_pkt.smi_targ_ncore_unit_id != DVE_FUNIT_IDS[0]) &&
                 isACEWriteDataRecd && isSMICMDReqSent && isSMISTRReqRecd);
   end
   else if(isRead) begin
      if(m_ace_cmd_type == DVMMSG) begin
	 ret_val = ret_val && isSMISTRReqRecd && !isSMISTRRespSent &&
		   ((isACEReadAddressDVMNeeded) ?  isACEReadAddressDVMRecd : 1) &&
		   /* ((isDVMMultiPart) ? m_ace_read_addr_pkt2.araddr == m_pkt.smi_dp_data[0] : */
		   /* (isSMISTRReqRecd) ? m_str_req_pkt.smi_rbid == m_pkt.smi_rbid : 0); */
                   (m_pkt.smi_targ_ncore_unit_id == DVE_FUNIT_IDS[0]) &&
		   (isSMISTRReqRecd) ? m_str_req_pkt.smi_rbid == m_pkt.smi_rbid : 0;
      end
      else begin	     
          ret_val = ret_val &&
                (((isSMICMDReqSent) ? matchDtwToCmd(m_pkt): 0) &&
                isSMICMDReqSent && isSMISTRReqRecd && isSMIDTRReqRecd // For a read, will only send DTW after DTR is received
                 );
     end
      
<%if(obj.useCache) { %>
   end else if(isSnoop) begin
//   uvm_report_info("DCDEBUG",$sformatf("matchSnoop ret_val:%0h, m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]:%0h == m_snp_req_pkt.smi_dest_id:%0h = %0d",ret_val,m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID],m_snp_req_pkt.smi_dest_id, (m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == m_snp_req_pkt.smi_dest_id)),UVM_MEDIUM);
	  //#Check.IOAIU.SMI.DTWReq.SNPId
          ret_val = ret_val && (matchSnpToDtwTargId(m_pkt) &&
			    (m_snp_req_pkt.smi_rbid == m_pkt.smi_rbid) &&
                            isIoCacheDataPipelineSeen);
   end
   else if(isIoCacheEvict) begin
      ret_val = ret_val && (((isSMICMDReqSent) ? matchDtwToCmd(m_pkt) : 0) &&
			    ((isSMISTRReqRecd) ? m_str_req_pkt.smi_rbid === m_pkt.smi_rbid : 0) &&
                            isIoCacheEvictDataRcvd && isIoCacheTagPipelineSeen &&
                            isSMISTRReqRecd);
<% } %>
<%if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5") { %>
   end else if(isSnoop) begin
      ret_val = ret_val && (matchSnpToDtwTargId(m_pkt) &&
			    (m_snp_req_pkt.smi_rbid == m_pkt.smi_rbid));
<% } %>
   end else begin
      ret_val = 0;
   end
   return ret_val;
endfunction : matchDtwToTxn

function int ioaiu_scb_txn::getSmiSize();
   int axlen,axsize,nearest_pow_2;
   int axaddr;
   int cacheline_beats;
   int remaining_beats_in_cacheline;
   int axburst;
   int axcache;
   bit axlock;
   int axid;

   cacheline_beats = SYS_nSysCacheline/(<%=obj.wData%>/8);
   
   if(isRead) begin
      axlen = m_ace_read_addr_pkt.arlen;
      axsize = m_ace_read_addr_pkt.arsize;
      axaddr = m_ace_read_addr_pkt.araddr;
      axburst = m_ace_read_addr_pkt.arburst;
      axcache = m_ace_read_addr_pkt.arcache;
      axlock = m_ace_read_addr_pkt.arlock;
      axid = m_ace_read_addr_pkt.arid;
   end
   else if(isWrite || isUpdate) begin
      axlen = m_ace_write_addr_pkt.awlen;
      axsize = m_ace_write_addr_pkt.awsize;
      axaddr = m_ace_write_addr_pkt.awaddr;
      axburst = m_ace_write_addr_pkt.awburst;
      axcache = m_ace_write_addr_pkt.awcache; 
      axlock = m_ace_write_addr_pkt.awlock;
      axid = m_ace_write_addr_pkt.awid;
   end
   else if (isIoCacheEvict) begin 
  	  return $clog2(SYS_nSysCacheline); //evictions are always full cacheline  
	end else begin
      print_me(0, 1);
      `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR","ERROR! SmiSize not defined for transaction above!")
  	  `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("getSmiSize() : isRead %0d, isWrite %0d, isUpdate %0d", isRead, isWrite, isUpdate),UVM_NONE)
   end
   
    remaining_beats_in_cacheline = cacheline_beats - (axaddr[5:0]/ (<%=obj.wData%>/8));

    if (axsize > remaining_beats_in_cacheline * (<%=obj.wData%> / 8) ) begin
        nearest_pow_2 = 2 ** $clog2(remaining_beats_in_cacheline * (<%=obj.wData%> / 8));
      /*  `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("IOAIU_UID:%0d fn:getSmiSize cacheline_beats:%0d remaining_beats_in_cacheline:%0d axsize:%0d nearest_pow_2:%0d", tb_txnid,cacheline_beats, remaining_beats_in_cacheline, axsize, nearest_pow_2))
    end 
    else if (req_data_crosses_cacheline_midpoint) begin 
        nearest_pow_2 = 2 ** axsize; */
    end else begin
        nearest_pow_2 = 2 ** $clog2((axlen + 1) * (2**axsize));
    end

    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $psprintf("IOAIU_UID:%0d fn:getSmiSize cacheline_beats:%0d remaining_beats_in_cacheline:%0d axsize:%0d nearest_pow_2:%0d", tb_txnid,cacheline_beats, remaining_beats_in_cacheline, axsize, nearest_pow_2), UVM_LOW)
    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $psprintf("UID:%0d fn:getSmiSize cacheline_beats:%0d remaining_beats_in_cacheline:%0d nearest_pow_2:%0d", cacheline_beats, remaining_beats_in_cacheline, nearest_pow_2),UVM_LOW)
    //CONC-11680
    // If a txn is INCR, is not exclusive, modifiable, address bits [4:0] is non-zero, 
    // and smi_size is normally going to be 5, it will be made into 6 
    // FIXME : get this documented - SAI
    // CONC-11704 - all multilines will be converted to INCR
    if (axaddr[4:0] != 5'd0 && !axlock && (axburst == INCR || isMultiAccess) && axlen != 0 && !isAtomic) begin
        if(nearest_pow_2 == 32) nearest_pow_2 = 64;
        //`uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $psprintf("IOAIU_UID:%0d fn:getSmiSize final nearest_pow_2:%0d", tb_txnid,nearest_pow_2),UVM_LOW)
    end
    
    case (nearest_pow_2)
        1  : return 3'b000;
        2  : return 3'b001;
        4  : return 3'b010;
        8  : return 3'b011;
        16 : return 3'b100;
        32 : return 3'b101;
        64 : return 3'b110;
        default : begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("ERROR! Problem in calculating SmiSize axlen:%0d axsize:%0d",axlen,axsize))
        end
    endcase // case ((axlen + 1) * (2**axsize))
endfunction : getSmiSize
      
function int ioaiu_scb_txn::getTransactionId();
   //DCTODO
   return 0;
endfunction : getTransactionId

function eMsgCMD ioaiu_scb_txn::getCmdType();
   //DCTODO
   $cast(getCmdType,m_cmd_req_pkt.smi_msg_type);
endfunction : getCmdType

function bit ioaiu_scb_txn::matchHomeDmiUnitId(smi_seq_item m_pkt);
//            if (m_ott_q[m_tmp_qA[0]].home_dmi_unit_id !== m_ott_q[m_tmp_qA[0]].m_dtw_req_pkt.dtw_req.home_dmi_unit_id) begin
   return 1;
endfunction : matchHomeDmiUnitId

function bit ioaiu_scb_txn::matchHomeDceUnitId(smi_seq_item m_pkt);
//m_ott_q[m_tmp_qA[0]].home_dce_unit_id !== m_ott_q[m_tmp_qA[0]].m_sfi_cmd_req_pkt.cmd_req.home_dce_unit_id
   //match TgtId of DCE 
//   return home_dce_unit_id !== m_cmd_req_pkt.cmd_req.home_dce_unit_id
<%if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5") { %>
    smi_targ_id_bit_t exp_targ_id;
    exp_targ_id = (addrMgrConst::map_addr2dce(m_pkt.smi_addr)  << WSMINCOREPORTID) | m_pkt.smi_targ_id[WSMINCOREPORTID-1:0];
    if(exp_targ_id == m_pkt.smi_targ_id) return 1;
    else return 0;
<% } else { %>
   return 1;
<% } %>
endfunction : matchHomeDceUnitId

function bit ioaiu_scb_txn::matchCmdType(eMsgCMD cmd_type);
   if (is2ndSMICMDReqSent)
    return (m_2nd_cmd_req_pkt.smi_msg_type == cmd_type);
   else 
    return (m_cmd_req_pkt.smi_msg_type == cmd_type);
endfunction : matchCmdType

function bit ioaiu_scb_txn::matchNativeTxnTypeToSMICmdType();
   //#Check.IOAIU.SMI.CMDReq.CmdType
  case (m_ace_cmd_type)
    RDONCE          : return matchCmdType(eCmdRdNITC);
    RDNOSNP         : return matchCmdType(eCmdRdNC);
    RDSHRD          : return matchCmdType(eCmdRdVld);
    RDCLN           : return matchCmdType(eCmdRdCln);
    RDNOTSHRDDIR    : return matchCmdType(eCmdRdNShD);
    RDUNQ           : return matchCmdType(eCmdRdUnq);
    CLNUNQ          : return matchCmdType(eCmdClnUnq);
    MKUNQ           : return matchCmdType(eCmdMkUnq);
    CLNSHRD         : return matchCmdType(eCmdClnVld);
    CLNINVL         : return matchCmdType(eCmdClnInv);
    MKINVL          : return matchCmdType(eCmdMkInv);
    DVMMSG          : return matchCmdType(eCmdDvmMsg);
    //WRUNQ           : return (isPartialWrite) ? matchCmdType(eCmdWrUnqPtl)   : matchCmdType(eCmdWrUnqFull);
    WRUNQ           : return (owo ? (is2ndSMICMDReqSent ? (isPartialWrite ? matchCmdType(eCmdWrNCPtl) : matchCmdType(eCmdWrNCFull)) : matchCmdType(eCmdClnUnq)) : (isPartialWrite ? matchCmdType(eCmdWrUnqPtl) : matchCmdType(eCmdWrUnqFull)));
    //WRLNUNQ         : return matchCmdType(eCmdWrUnqFull);
    WRLNUNQ           : return (owo ? (is2ndSMICMDReqSent ? matchCmdType(eCmdWrNCFull) : matchCmdType(eCmdClnUnq)) : matchCmdType(eCmdWrUnqFull));
    WRNOSNP         : return (isPartialWrite) ? matchCmdType(eCmdWrNCPtl) : matchCmdType(eCmdWrNCFull);
    WRCLN           : return (isPartialWrite) ? matchCmdType(eCmdWrNCPtl) : matchCmdType(eCmdWrNCFull);
    WRBK            : return (isPartialWrite) ? matchCmdType(eCmdWrNCPtl) : matchCmdType(eCmdWrNCFull);
    EVCT            : return matchCmdType(eCmdWrNCFull);
    WREVCT          : return matchCmdType(eCmdWrNCFull);
    ATMLD           : return matchCmdType(eCmdRdAtm);
    ATMSTR          : return matchCmdType(eCmdWrAtm);
    ATMSWAP         : return matchCmdType(eCmdSwAtm);
    ATMCOMPARE      : return matchCmdType(eCmdCompAtm);
    WRUNQPTLSTASH   : return matchCmdType(eCmdWrStshPtl);
    WRUNQFULLSTASH  : return matchCmdType(eCmdWrStshFull);
    STASHONCEUNQ    : return matchCmdType(eCmdLdCchUnq);
    STASHONCESHARED : return matchCmdType(eCmdLdCchShd);
    CLNSHRDPERSIST  : return matchCmdType(eCmdClnShdPer);
    RDONCEMAKEINVLD : return matchCmdType(eCmdRdNITCMkInv);
    RDONCECLNINVLD  : return matchCmdType(eCmdRdNITCClnInv);
    STASHTRANS      : uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", "STASHTRANS not implemented!");
  endcase // case (m_ace_cmd_type)
endfunction : matchNativeTxnTypeToSMICmdType

function bit ioaiu_scb_txn::matchAceLock();
//   return (m_ace_read_addr_pkt.arlock == m_cmd_req_pkt.smi_lk);
   return 1;
endfunction : matchAceLock

function bit ioaiu_scb_txn::getAceLock();
//   return m_cmd_req_pkt.smi_lk;
   return 0;
endfunction : getAceLock

function void ioaiu_scb_txn::setup_cmd_req(smi_seq_item m_pkt);
   //DCTODO
   eMsgCMD cmd_type;
   
   t_latest_update    = $time;
   if(!isSMICMDReqSent) begin
    isSMICMDReqSent     = 1;
    m_cmd_req_pkt       = m_pkt;
    t_sfi_cmd_req       = t_latest_update;
   end 
   else begin
    is2ndSMICMDReqSent  = 1;
    m_2nd_cmd_req_pkt   = m_pkt;
    t_2nd_sfi_cmd_req   = t_latest_update;

    is2ndSMISTRReqNeeded  = 1;
   end
   $cast(cmd_type, m_pkt.smi_msg_type);
   
//   m_req_aiu_trans_id = m_sfi_cmd_req_pkt.cmd_req.req_aiu_trans_id;
   //#Check.IOAIU.SMI.CMDReq.CMType
   case(cmd_type)
     eCmdClnUnq,eCmdClnVld,
     eCmdClnInv,eCmdClnShdPer       : begin
      //isSMIDTWReqNeeded = 0;
      isSMIDTRReqNeeded = 0; // DCTODO This is because ST is 0
     end
     eCmdMkInv,eCmdMkUnq         : begin
      //isSMIDTWReqNeeded = 0;
      isSMIDTRReqNeeded = 0; // DCTODO This is because ST is 0
     end
     eCmdWrUnqFull,eCmdWrUnqPtl,
     eCmdWrNCPtl,  eCmdWrNCFull  : begin
      //isSMIDTWReqNeeded = 1;
      isSMIDTRReqNeeded = 0; // DCTODO This is because ST is 0
     end
     eCmdRdUnq,eCmdRdNITC,
     eCmdRdNITCClnInv,eCmdRdNITCMkInv,
     eCmdRdNC, eCmdRdVld,
     eCmdRdCln,eCmdRdNShD        : begin
      //isSMIDTWReqNeeded = 0;
      isSMIDTRReqNeeded = 1; // DCTODO This is because ST is 0
     end
     
   endcase // case (cmd_type)

   getExpCmdRsp();
   check_smi_cmd_attr();
endfunction : setup_cmd_req

function void ioaiu_scb_txn::setup_snp_req(smi_seq_item m_pkt);
        int  fnmem_region_idx;
        
        m_snp_req_pkt  = m_pkt; 
        isSnoop            = 1;
        t_creation         = $time;
        t_latest_update    = $time;
        t_sfi_snp_req      = t_latest_update;
        isSMISNPReqRecd    = 1;
        isCoherent         = 0; //snoops are always coherent
        m_sfi_addr         = m_snp_req_pkt.smi_addr;
        
        dest_id = addrMgrConst::map_addr2dmi_or_dii(m_snp_req_pkt.smi_addr,fnmem_region_idx);

        <%if(obj.useCache) { %> 
        ccp_addr   = shift_addr(m_snp_req_pkt.smi_addr);
        ccp_index = addrMgrConst::get_set_index(m_snp_req_pkt.smi_addr,<%=obj.FUnitId%>);
        isIoCacheTagPipelineNeeded = (this.csr_ccp_lookupen);
        <%}%>
        <% if (obj.wSecurityAttribute > 0) { %>                                             
	m_security = m_snp_req_pkt.smi_ns;
        <% }else{%>    
        m_security = 0;
        <%}%>
	m_id = {m_snp_req_pkt.smi_src_id,m_snp_req_pkt.smi_msg_id};
        if (m_req_aiu_id === <%=obj.Id%>) begin
            isSnoopReqAiuIDSameAsThisReqAiuId = 1;
        end
        if(m_snp_req_pkt.smi_msg_type != SNP_DVM_MSG) begin
	    setup_dce_dmi_id_for_req();
        end
        if (addrMgrConst::get_addr_gprar_nc(m_sfi_addr)==1) begin
         if(!($test$plusargs("en_address_aliasing") || $test$plusargs("inject_smi_uncorr_error")))
         uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","Unexpected snoop request recieved from non coherent address region",UVM_NONE);
        end else begin
         isCoherent         = 1;//snoops are always coherent
        end
        if(m_snp_req_pkt.smi_msg_type == SNP_DVM_MSG) begin
            if((m_snp_req_pkt.smi_addr[3] == 1'b0) && (m_snp_req_pkt.smi_addr[13:11] == 3'b100)) // DVM Message Type : Synchronization - 3'b100
                isDVMSync = 1;
        end
endfunction : setup_snp_req

function void ioaiu_scb_txn::setup_upd_req(smi_seq_item m_pkt);
                  
            m_upd_req_pkt = smi_seq_item::type_id::create("m_upd_req_pkt");
            //CONC-11353
            <%if(obj.nNativeInterfacePorts > 1){ %>
            exp_smi_msg_id[WSMIMSGID-1:WSMIMSGID-<%=Math.log2(obj.nNativeInterfacePorts)%>]=core_id; 
            exp_smi_msg_id[WSMIMSGID-1-<%=Math.log2(obj.nNativeInterfacePorts)%>:0]=(m_ott_status==ALLOCATED) ? m_ott_id:-1;
            <% } else {%>
            exp_smi_msg_id[WSMIMSGID-1:WSMIMSGID-1]=0; 
            exp_smi_msg_id[WSMIMSGID-2:0]=(m_ott_status==ALLOCATED) ? m_ott_id:-1;
            <%}%>

            if (isSMIUPDReqNeeded == 1) begin 
	        m_upd_req_pkt.construct_updmsg(
                        .smi_targ_ncore_unit_id(addrMgrConst::map_addr2dce(m_sfi_addr)),
			.smi_src_ncore_unit_id(<%=obj.AiuInfo[obj.Id].FUnitId%>),
			.smi_msg_type(eUpdInv),
			//.smi_msg_id(m_pkt.smi_msg_id),
			.smi_msg_id(exp_smi_msg_id),
			.smi_msg_tier('h0),
			.smi_steer('h0),
			.smi_msg_pri(addrMgrConst::qos_mapping(csr_use_eviction_qos ? csr_eviction_qos : m_axi_qos)),
		  	.smi_msg_qos('h0), //this is part of header. driven by legato. so ignore. 
			.smi_msg_err('h0),
    			.smi_tm(m_pkt.smi_tm),
			.smi_cmstatus('h0),
			.smi_addr(m_sfi_addr),
			.smi_ns(m_security),
			.smi_qos(csr_use_eviction_qos ? csr_eviction_qos : m_axi_qos)
		);
            end 
    // #Check.IOAIU.SMI.UpdReq.Addr
    // #Check.IOAIU.SMI.UpdReq.CMStatus
    // #Check.IOAIU.SMI.UpdReq.CMType
    // #Check.IOAIU.SMI.UpdReq.NS
    // #Check.IOAIU.SMI.UpdReq.QOS
    // #Check.IOAIU.SMI.UpdReq.TargetID
    // #Check.IOAIU.SMI.UpdReq.priority
    //#Check.IOAIU.SMI.UpdReq.InitiatorID 

    if(!m_upd_req_pkt.compare(m_pkt)) begin
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> UPDreq fields mismatching above!", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>));
    end
    else begin
         upd_req_counter++;
    end

   m_upd_req_pkt            = m_pkt;
   t_latest_update          = $time;
   t_sfi_upd_req            = t_latest_update;
   isSMIUPDReqSent          = 1;
endfunction : setup_upd_req

function void ioaiu_scb_txn::add_cmp_resp(smi_seq_item m_pkt);
   t_latest_update   = $time;
   isSMICMPRespRecd    = 1;
   m_cmp_rsp_pkt       = m_pkt;
   t_sfi_cmp_rsp       = t_latest_update;

   //#Check.IOAIU.CMPrsp.CMStatusAddrErr_SLVERR   
   if (m_cmp_rsp_pkt.smi_cmstatus_err === 1) begin //CONC-6972
       foreach (m_axi_resp_expected[i]) begin
           m_axi_resp_expected[i] = SLVERR;
       end
   end

  //#Check.IOAIU.CMPrsp.CMStatusAddrErr
  if(m_cmp_rsp_pkt.smi_cmstatus_err === 1 && ((m_cmp_rsp_pkt.smi_cmstatus_err_payload != 7'b000_0100))) begin
  `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> CMPrsp.CMStatusErr should be AddressError", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>));
  end
   
endfunction : add_cmp_resp
      
function void ioaiu_scb_txn::add_cmd_resp(smi_seq_item m_pkt);
   t_latest_update   = $time;
   if(!isSMICMDRespRecd) begin 
      isSMICMDRespRecd    = 1;
      m_cmd_rsp_pkt       = m_pkt;
      t_sfi_cmd_rsp       = t_latest_update;
  
      if(!exp_cmd_rsp_pkt.compare(m_cmd_rsp_pkt)) begin
      	 uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Exp CMDRsp:%s",exp_cmd_rsp_pkt.convert2string()), UVM_NONE);
      	 uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Act CMDRsp:%s",m_cmd_rsp_pkt.convert2string()), UVM_NONE);
         uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","CMDRsp Fields mismatching above!",UVM_NONE);
      end
   end 
   else begin
      is2ndSMICMDRespRecd = 1;
      m_2nd_cmd_rsp_pkt   = m_pkt;
      t_2nd_sfi_cmd_rsp   = t_latest_update;
  
      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Exp 2nd_CMDRsp:%s",exp_2nd_cmd_rsp_pkt.convert2string()), UVM_LOW);
      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Act 2nd_CMDRsp:%s",m_2nd_cmd_rsp_pkt.convert2string()), UVM_LOW);
      if(!exp_2nd_cmd_rsp_pkt.compare(m_2nd_cmd_rsp_pkt)) begin
         uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR","2nd_CMDRsp Fields mismatching above!", UVM_NONE);
         uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","2nd_CMDRsp Fields mismatching above!",UVM_NONE);
      end
   end
   isSMICMDRespErr   = 0;

endfunction : add_cmd_resp

function void ioaiu_scb_txn::add_upd_resp(smi_seq_item m_pkt);
        m_upd_rsp_pkt = m_pkt; 
        isSMIUPDRespRecd  = 1;
        t_latest_update   = $time;
        t_sfi_upd_rsp     = t_latest_update;

endfunction : add_upd_resp

function void ioaiu_scb_txn::add_str_req(smi_seq_item m_pkt);
       // #Check.AIU.DataCorruption.STRreqError
	t_latest_update   = $time;

    if(!isSMISTRReqRecd) begin
    	isSMISTRReqRecd = 1;
        m_str_req_pkt   = m_pkt;
        t_sfi_str_req   = t_latest_update;
    end
    else begin
    	is2ndSMISTRReqRecd = 1;
        m_2nd_str_req_pkt  = m_pkt;
        t_2nd_sfi_str_req  = t_latest_update;
    end

    if (is2ndSMISTRReqRecd) begin: _2nd_STRreq_
        if (isWrite && (m_ace_cmd_type != EVCT))
            isSMIDTWReqNeeded = 1;
    end: _2nd_STRreq_
    else begin : _1st_STRreq_
        //OWO Write- On STRreq of CMO, transition the line to UCE state  
        if (owo && isCoherent && isWrite) begin 
            //m_owo_wr_state = UCE;
        end 
        else if (isAtomic && !isCoherentAtomic) begin 
	    isSMIDTWReqNeeded = 1;
        end else if(m_ace_cmd_type == WRUNQFULLSTASH ) begin 
	    if(m_pkt.smi_cmstatus_snarf && m_ace_write_addr_pkt.awstashniden) begin
	        isSMISNPDTRReqNeeded = 1;
	   	isSMIDTWReqNeeded = 0;
	    end else begin
	   	isSMISNPDTRReqNeeded = 0;
	   	isSMIDTWReqNeeded = 1;
	    end 
        end
        else if(m_ace_cmd_type == WRUNQPTLSTASH ) begin 
		isSMISNPDTRReqNeeded = 0;
		isSMIDTWReqNeeded = 1;
        end
        else if (m_ace_cmd_type inside {DVMMSG, WREVCT, WRCLN, WRBK, WRLNUNQ, WRNOSNP}) begin 
	    isSMIDTWReqNeeded = 1;
        end else if (m_ace_cmd_type == WRUNQ) begin 
            <%if(obj.useCache){%> 
                if (m_ccp_ctrl_pkt != null) begin : _ccp_lookup_en_ 
                    //send data downstream only if not allocating in cache
                    //CONC-16428 
                    if (m_ccp_ctrl_pkt.currstate == IX && (!m_ccp_ctrl_pkt.alloc || m_ccp_ctrl_pkt.nackuce )) begin   
	                isSMIDTWReqNeeded = 1;
                    end
                end: _ccp_lookup_en_
                else begin : _ccp_lookup_dis_
                    isSMIDTWReqNeeded = 1;
                end: _ccp_lookup_dis_
            <%} else {%>
	        isSMIDTWReqNeeded = 1;
            <%}%>
        end
    end:  _1st_STRreq_

    //Error scenarios
    if (m_pkt.smi_cmstatus_err === 1 && (m_pkt.smi_cmstatus_err_payload === 7'b000_0100)) begin 
        isSMISTRReqAddrErr = 1;
 	hasFatlErr		   = 1;
        //#Check.IOAIU.STRreq.CMStatusErr.DTRReqNotNeeded
  	isSMIDTRReqNeeded = 0;
	isSMIDTWReqNeeded = 0;
        //#Check.IOAIU.STRreq.CMStatusErr.FillDataReqdSettoZero
        isFillDataReqd    = 0;
        foreach (m_axi_resp_expected[i])
	    m_axi_resp_expected[i] = DECERR;
    end else if (m_pkt.smi_cmstatus_err === 1 && (m_pkt.smi_cmstatus_err_payload === 7'b000_0011)) begin 
 	isSMISTRReqDataErr = 1;
 	hasFatlErr	   = 1;
        //#Check.IOAIU.STRreq.CMStatusErr.DTRReqNotNeeded
  	isSMIDTRReqNeeded = 0;
	isSMIDTWReqNeeded = 0;
        //#Check.IOAIU.STRreq.CMStatusErr.FillDataReqdSettoZero
	isFillDataReqd    = 0;
        if(!(isMultiAccess ==  1 && isWrite)) begin
	    foreach (m_axi_resp_expected[i])
                if(!( m_axi_resp_expected[i] == DECERR))
		    m_axi_resp_expected[i] = SLVERR;
            end
    end else if(m_pkt.smi_cmstatus_err === 1) begin
       //#Check.IOAIU.STRreq.CMStatusErr
       `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> STRreq.CMStatusErr should be AddressError and DataError", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>));
    end

    //If coherent part of atomic gets an STRreq.Error. The non-coherent phase of atomic is not initiated.
    if (m_str_req_pkt !== null) begin
    	if (m_str_req_pkt.smi_cmstatus_err === 1 && ((isAtomic && isSMISTRReqRecd === 1 && is2ndSMISTRReqRecd ===0 && isCoherentAtomic === 1) || (owo && is2ndSMICMDReqNeeded))) begin
            is2ndSMICMDReqNeeded = 0;
            is2ndSMISTRReqNeeded = 0;
            isSMIDTWReqNeeded = 0;  
	    isSMIDTRReqNeeded = 0;
        end
    end

    //#Check.IOAIU.STRreq.CMStatusErr.SrcId
    //TODO: need to check about writeback phase of coherent write in IOAIUp
    if (m_2nd_str_req_pkt !== null) begin
        //#Check.IOAIU.Atomic.STRreq.CMStatusErr
	if (m_2nd_str_req_pkt.smi_cmstatus_err === 1)
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> STRreq.CMStatusErr is not expected on STRreq from DMI", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>));
    end

endfunction : add_str_req

function void ioaiu_scb_txn::add_str_resp(smi_seq_item m_pkt);
   t_latest_update   = $time;
   if(!is2ndSMISTRReqNeeded) begin
      isSMISTRRespSent    = 1;
      m_str_rsp_pkt       = m_pkt;
      t_sfi_str_rsp       = t_latest_update;
   end 
   else begin
    if(isSMISTRReqRecd && !isSMISTRRespSent && !is2ndSMISTRReqRecd) begin
        isSMISTRRespSent    = 1;
        m_str_rsp_pkt       = m_pkt;
        t_sfi_str_rsp       = t_latest_update;
    end
    else if(is2ndSMISTRReqRecd && isSMISTRRespSent) begin 
        is2ndSMISTRRespSent = 1;
        m_2nd_str_rsp_pkt   = m_pkt;
        t_2nd_sfi_str_rsp   = t_latest_update;
    end
    else if(isSMISTRReqRecd && is2ndSMISTRReqRecd && !isSMISTRRespSent) begin
       if(m_pkt.smi_rsp_unq_identifier == m_str_req_pkt.smi_unq_identifier) begin
        isSMISTRRespSent    = 1;
        m_str_rsp_pkt       = m_pkt;
        t_sfi_str_rsp       = t_latest_update;
       end
       else begin
        is2ndSMISTRRespSent = 1;
        m_2nd_str_rsp_pkt   = m_pkt;
        t_2nd_sfi_str_rsp   = t_latest_update;
      end
    end
   end
   if(isAtomic && isCoherentAtomic) begin
       if(isSMISTRRespSent && (m_str_rsp_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] != home_dce_unit_id)) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d Coherent Atomic transaction: The target id for STR resp to DCE is wrong. exp = %h, act = %h", home_dce_unit_id, m_str_rsp_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID], tb_txnid))
       end
       if(is2ndSMISTRRespSent && (m_2nd_str_rsp_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] != home_dmi_unit_id)) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d Coherent Atomic transaction: The target id for STR resp to DMI is wrong. exp = %h, act = %h", home_dmi_unit_id, m_2nd_str_rsp_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID], tb_txnid))
       end
       if (isSMISTRRespSent && is2ndSMISTRRespSent) begin
            if(t_sfi_str_rsp < t_2nd_sfi_str_rsp)
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d Coherent Atomic transaction: RTL sends STR resp to DCE earlier than sends STR resp to DMI",  tb_txnid))
       end
   end

   //#Check.IOAIU.OWO.Write_STRrsp
   //#Check.IOAIU.Write_STRrsp
   //IOAIU should issue a STRrsp to DMI/DII only after the DTWrsp is received.
   //IOAIU should issue a STRrsp to DMI/DII only after the DTRreq is received
   //for AtmLd, AtmComp, AtmSwp.
   if (     isWrite //covers both writes and atomics 
        && (addrMgrConst::get_unit_type(m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]) inside {addrMgrConst::DMI, addrMgrConst::DII}) //STRrsp to DII/DMI
        && (   (isSMIDTWReqNeeded && !isSMIDTWRespRecd)  //all cases where DTWreq is needed but DTWrsp was not received.
            || (isSMIDTRReqNeeded && !isSMIDTRReqRecd))  //applies to AtmLd, AtmComp, AtmSwp
      ) begin
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> STRrsp prematurely sent before DTWResp was received for the Write Transaction",  tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))
   end

   //if (isCoherentAtomic) begin 
   //   `uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> isSMISTRRespSent:%0d is2ndSMISTRRespSent:%0d",  tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, isSMISTRRespSent, is2ndSMISTRRespSent), UVM_LOW);
   // end 

  if (isDVMSync && (!isACESnoopReqSent || !isACESnoopRespRecd)) begin
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> STRrsp prematurely sent before AC channel handshake is complete isACESnoopReqSent:%0b isACESnoopRespRecd:%0b",  tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, isACESnoopReqSent, isACESnoopRespRecd))
   end 

   getExpStrRsp();
   if(!is2ndSMISTRRespSent) begin
      if(!exp_str_rsp_pkt.compare(m_str_rsp_pkt)) begin
      	 uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Exp STRRsp:%s",exp_str_rsp_pkt.convert2string()), UVM_NONE);
      	 uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Act STRRsp:%s",m_str_rsp_pkt.convert2string()), UVM_NONE);
         uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","STRRsp Fields mismatching above!",UVM_NONE);
      end
   end else begin
      exp_2nd_str_rsp_pkt.smi_cmstatus = m_2nd_str_rsp_pkt.smi_cmstatus;
      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Exp 2ndSTRRsp:%s",exp_2nd_str_rsp_pkt.convert2string()), UVM_LOW);
      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Act 2ndSTRRsp:%s",m_2nd_str_rsp_pkt.convert2string()), UVM_LOW);
      if(!exp_2nd_str_rsp_pkt.compare(m_2nd_str_rsp_pkt)) begin
         uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR","2ndSTRRsp Fields mismatching above!", UVM_NONE);
         uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","2ndSTRRsp Fields mismatching above!",UVM_NONE);
      end
   end
endfunction : add_str_resp

function void ioaiu_scb_txn::getExpStrRsp();
     if(!is2ndSMISTRReqRecd) begin
        exp_str_rsp_pkt = smi_seq_item::type_id::create("exp_str_rsp_pkt");
        //Check.IOAIU.SMI.StrRsp.CMStatus
        //#Check.IOAIU.SMI.StrRsp.CMType
        //#Check.IOAIU.SMI.StrRsp.InitiatorID
        //#Check.IOAIU.SMI.StrRsp.Priority
        //#Check.IOAIU.SMI.StrRsp.RMsgID
        //#Check.IOAIU.SMI.StrRsp.TargetID
        //#Check.IOAIU.SMI.StrRsp.CMStatus
        exp_str_rsp_pkt.construct_strrsp(
                                        .smi_targ_ncore_unit_id (m_str_req_pkt.smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_msg_type           (eStrRsp),
                                        .smi_msg_id             (core_id << (WSMIMSGID- $clog2(<%=obj.nNativeInterfacePorts%>))),
                                        .smi_msg_tier           ('h0),
                                        .smi_steer              ('h0),
                                        .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%> ? m_str_req_pkt.smi_msg_pri : 'h0),
                                        .smi_msg_qos            ('0),
                                        .smi_tm                 (m_str_req_pkt.smi_tm),
                                        .smi_rmsg_id            (m_str_req_pkt.smi_msg_id),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0)
                                        );
     end else begin
        exp_2nd_str_rsp_pkt = smi_seq_item::type_id::create("exp_2nd_str_rsp_pkt");
        exp_2nd_str_rsp_pkt.construct_strrsp(
                                        .smi_targ_ncore_unit_id (m_2nd_str_req_pkt.smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_msg_type           (eStrRsp),
                                        .smi_msg_id             (core_id << (WSMIMSGID- $clog2(<%=obj.nNativeInterfacePorts%>))),
                                        .smi_msg_tier           ('h0),
                                        .smi_steer              ('h0),
                                        .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%> ? m_2nd_str_req_pkt.smi_msg_pri : 'h0),
                                        .smi_msg_qos            ('0),
                                        .smi_tm                 (m_2nd_str_req_pkt.smi_tm),
                                        .smi_rmsg_id            (m_2nd_str_req_pkt.smi_msg_id),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0)
                                        );
     end
endfunction : getExpStrRsp

function void ioaiu_scb_txn::add_dtr_req(smi_seq_item m_pkt);
    smi_dp_data_bit_t 	dtr_req_data [];
    smi_dp_be_t         dtr_req_be [];
    int num_bytes    = (isRead) ? 2 ** m_ace_read_addr_pkt.arsize : 2 ** m_ace_write_addr_pkt.awsize;
    int burst_length = (isRead) ? (m_ace_read_addr_pkt.arlen + 1) : (m_ace_write_addr_pkt.awlen + 1);
    int dt_size      = num_bytes * burst_length;
    longint start_addr     = (isRead) ? ((m_ace_read_addr_pkt.araddr/(DATA_WIDTH/8)) * ( DATA_WIDTH/8)) : ((m_ace_write_addr_pkt.awaddr/(DATA_WIDTH/8)) * ( DATA_WIDTH/8));
    longint lower_boundary = (start_addr/(dt_size)) * dt_size;
    longint upper_boundary = lower_boundary + dt_size;
    int     beat_count         = 0;

    m_dtr_req_pkt = m_pkt;
    isSMIDTRReqRecd = 1;
    dtr_req_dbad_high = 0;
    
    if ((m_pkt.smi_msg_type == DTR_DATA_SHR_DTY) || (m_pkt.smi_msg_type == DTR_DATA_UNQ_DTY)) begin
        isSMIDTRReqDty = 1;
    end
    t_latest_update = $time;

    t_sfi_dtr_req = t_latest_update;
    dtr_req_data  = new [m_pkt.smi_dp_data.size()];
    dtr_req_be    = new [m_pkt.smi_dp_be.size()];
        
    m_dtr_req_for_dtw_hndbk_pkt = new();
    m_dtr_req_for_dtw_hndbk_pkt.copy(m_dtr_req_pkt);
    m_smi_data_be = new[m_pkt.smi_dp_data.size()];
    
    foreach (m_smi_data_be[i])
    	m_smi_data_be[i] = 1;
    foreach (m_dtr_req_for_dtw_hndbk_pkt.smi_dp_be[i]) begin
    	if (m_dtr_req_for_dtw_hndbk_pkt.smi_dp_be[i] !== '1) 
            m_smi_data_be[i] = 0;
    end
        
    // Re-aligning DTR beats if it hits wacky_wrap case
    // 10_27_23 HS notes: Discussed with EricT and this realignment of DTRreq beats is
    // needed when IOAIU asks for and gets a full cacheline (CMDreq.Size=6), even though nativeInterface requested for less than a cacheline, 
    // in case of WRAP where the lower_boundary < start_addr
    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> wacky_wrap_case -- addr:0x%0h lower_boundary:0x%0h start_addr:0x%0h", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,  m_ace_read_addr_pkt.araddr,lower_boundary, start_addr), UVM_LOW);
    
    if ((isRead == 1) && 
        (isMultiAccess == 0) && 
        (m_ace_read_addr_pkt.arburst == AXIWRAP) && 
        (dt_size < SYS_nSysCacheline) && 
        (m_cmd_req_pkt.smi_size == 6) &&
        (lower_boundary < start_addr)
        ) begin: _wacky_wrap_case
        int j = 0;

        for (int i = 1; i < m_ace_read_addr_pkt.arlen+1; i++) begin 
            start_addr = start_addr + num_bytes;
            if (start_addr >= upper_boundary && beat_count === 0) begin
                beat_count = m_ace_read_addr_pkt.arlen + 1 - i;
            end
        end
            
        //`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> wacky_wrap_case -- number of beats to copy over %0d",  tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, beat_count), UVM_LOW);
        
        // Re-shuffling DTRReq data beats
        for (int i = m_ace_read_addr_pkt.arlen + 1 - beat_count; i < m_ace_read_addr_pkt.arlen + 1; i++) begin
            m_dtr_req_pkt.smi_dp_data[i] = m_dtr_req_pkt.smi_dp_data[m_dtr_req_pkt.smi_dp_data.size() - beat_count + j];
            m_dtr_req_pkt.smi_dp_dbad[i] = m_dtr_req_pkt.smi_dp_dbad[m_dtr_req_pkt.smi_dp_dbad.size() - beat_count + j];
            m_dtr_req_pkt.smi_dp_be[i] 	 = m_dtr_req_pkt.smi_dp_be[m_dtr_req_pkt.smi_dp_be.size() - beat_count + j];
            m_dtr_req_pkt.smi_dp_dwid[i] = m_dtr_req_pkt.smi_dp_dwid[m_dtr_req_pkt.smi_dp_be.size() - beat_count + j];
            j++;
        end
        	
        //`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> wacky_wrap_case ActPkt:%0s Realigned Pkt:%0s",tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_dtr_req_for_dtw_hndbk_pkt.convert2string(), m_dtr_req_pkt.convert2string()), UVM_LOW);
    end: _wacky_wrap_case

        //#Check.IOAIU.DTRreqCMStatusError
	if (m_dtr_req_pkt.smi_cmstatus_err) begin
		dtrreq_cmstatus_err = 1;
        if ((m_dtr_req_pkt.smi_cmstatus_err_payload inside {7'b000_0100}) == 1) begin
        	dtrreq_cmstatus_add_err = 1;
		end
		if ((m_dtr_req_pkt.smi_cmstatus_err_payload inside {7'b000_0011, 7'b000_0100}) == 0) begin
            print_me(0,1);
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("DTRReq.CMStatus.Err is seen, but DTRReq.CMStatus.Err_Payload is not inside {7'b000_0011, 7'b000_0100}"));
		end
	end
		 
	foreach(m_dtr_req_pkt.smi_dp_dbad[i]) begin
		if (|m_dtr_req_pkt.smi_dp_dbad[i] == 1'b1) begin
            dtr_req_dbad_high = 1;
		end
	end
        //#Check.IOAIU.NonCohAtomic.Error
	foreach (m_axi_resp_expected[i]) begin : foreach_error_expected
		if (dtrreq_cmstatus_add_err	== 1 || m_axi_resp_expected[i] == DECERR ) begin
              //#Check.IOAIU.DTRREQ.DECERR
              m_axi_resp_expected[i] = DECERR; //default case
		end else begin
               //#Check.IOAIU.DTRREQ.SLVERR
	        if (dtr_req_dbad_high == 1'b1 && isPartialWrite == 1 && m_dtr_req_pkt.smi_cmstatus_err === 0 && !( m_axi_resp_expected[i] inside {SLVERR,DECERR})) begin
                m_axi_resp_expected[i] = OKAY; //The poison bit is carried over into the new merged line, CONC-7552
            end else if (i==0 && m_dtr_req_pkt.smi_cmstatus_err === 1 && m_dtr_req_pkt.smi_cmstatus_err_payload === 7'b000_0011 && !(m_axi_resp_expected[i] == DECERR )) begin //DataError asserted on CMStatus applies to 1st beat only
                m_axi_resp_expected[i] = SLVERR;
                end
                if(isRead || isAtomic) begin
	            if ((|m_dtr_req_pkt.smi_dp_dbad[i] == 1'b1 || (dtr_req_dbad_high==1 && owo_512b && (m_ace_read_addr_pkt.araddr[SYS_wSysCacheline-1:0] < 32 && isPartialRead==0 ) ) ) &&  !(m_axi_resp_expected[i] == DECERR   ) )  //Dbad/Poison asserted on any beat identified as SLVERR
                m_axi_resp_expected[i] = SLVERR;
                end else begin
                if(dtr_req_dbad_high == 1 && isPartialWrite == 0 &&  !( m_axi_resp_expected[i] == DECERR))
                 m_axi_resp_expected[i] = SLVERR;
                end
		end
    end : foreach_error_expected

	if(check_rresp_on_dtrreq == 1) begin
  		predict_excops_rresp();
<% if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5") { %>
		//rd_data/rresp is sent on nativeInterface as soon as the critical beat is received from DTRreq, hence it is possible that all DTRreq beats are not received by the time RdData/RResp is sent.
		//Hence rresp is checked at rddata/rresp as well as DTRreq, if and when both packets are available. 
		check_rresp_for_ace();
<%}%>
        check_rresp();	
		check_num_rdata_beats();
		check_rdata();
    end        
  		
	getExpDtrRsp();
            
endfunction : add_dtr_req

function void ioaiu_scb_txn::add_dtr_resp(smi_seq_item m_pkt);
   m_dtr_rsp_pkt = m_pkt;
   isSMIAllDTRRespSent = 1;
   isSMIDTRRespSent = 1;
   t_latest_update  = $time;
   t_sfi_dtr_rsp = t_latest_update;
   //print_me();

if (!($test$plusargs("dtr_rsp_err_inj"))) begin
   exp_dtr_rsp_pkt.smi_msg_id = m_pkt.smi_msg_id;

   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Exp DTRRsp:%s",exp_dtr_rsp_pkt.convert2string()), UVM_MEDIUM);
   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Act DTRRsp:%s",m_dtr_rsp_pkt.convert2string()), UVM_MEDIUM);
   if(!exp_dtr_rsp_pkt.compare(m_dtr_rsp_pkt)) begin
      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR","DTRRsp Fields mismatching above!", UVM_NONE);
      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","DTRRsp Fields mismatching above!",UVM_NONE);
   end
 end
endfunction : add_dtr_resp

function void ioaiu_scb_txn::add_dtw_req(smi_seq_item m_pkt,string id = "");
        m_dtw_req_pkt = m_pkt; 
        isSMIDTWReqSent   = 1;
        t_latest_update   = $time;
        t_sfi_dtw_req     = t_latest_update;
 //#Check.IOAIU.OTTUnCorrectableErr.DtwReqCMStatus.DataErr
 //#Check.IOAIU.DataUncorrectableErr.DtwReq_DataErr
 //#Check.IOAIU.DTWreq.CMStatusDataError
  //#Check.IOAIU.DTWreq.CMStatusDataErrorScenario
 <%if(obj.assertOn && obj.testBench =="io_aiu"){%>
 <%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) { %>  
 if($test$plusargs("write_address_error_test_ott") <% if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITY") { %> ||
$test$plusargs("ccp_snp_sram_data_addr_err") <% } %>) begin
 if(!( m_dtw_req_pkt.smi_cmstatus_err === 1 && (m_dtw_req_pkt.smi_cmstatus_err_payload === 7'b000_0011))) begin
  uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR","DTWReq should be data error for ott sram address error test", UVM_NONE);
 end
 //#Check.IOAIU.SMI.DtwReq.DBad
 foreach(m_dtw_req_pkt.smi_dp_dbad[i]) begin
 if (!(|m_dtw_req_pkt.smi_dp_dbad[i] == 1'b1)) begin
 uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR","smi dp dbad should be 1 for ott sram address error test", UVM_NONE);          
 end
 end
 end
 <% } %>
 <% } %>
 check_dtw_txn(m_pkt,id);

endfunction : add_dtw_req

function void ioaiu_scb_txn::add_dtw_resp(smi_seq_item m_pkt);
   m_dtw_rsp_pkt = m_pkt; 
   isSMIDTWRespRecd  = 1;
   t_latest_update   = $time;
   t_sfi_dtw_rsp     = t_latest_update;
   if (m_dtw_rsp_pkt !== null) begin
       if (m_dtw_rsp_pkt.smi_cmstatus_err === 1 && (m_dtw_rsp_pkt.smi_cmstatus_err_payload === 7'b000_0100)) begin
           //#Check.IOAIU.DTWrspCMStatusAddrErr.BRespDECERR
           dtwrsp_cmstatus_add_err =1;
           foreach (m_axi_resp_expected[i]) begin
               m_axi_resp_expected[i] = DECERR;
           end
           dtwrsp_cmstatus_err = 1;
       end else if (m_dtw_rsp_pkt.smi_cmstatus_err === 1 && (m_dtw_rsp_pkt.smi_cmstatus_err_payload === 7'b000_0011) &&  m_axi_resp_expected[0] != DECERR) begin //All other cmstatus errors except address error will be reported as SLVERR, CONC-6671.
           //#Check.IOAIU.DTWrspCMStatusDataErr.BRespSLVERR
           foreach (m_axi_resp_expected[i]) begin
               m_axi_resp_expected[i] = SLVERR;
           end
           dtwrsp_cmstatus_err = 1; 
           dtwrsp_cmstatus_slv_err = 1;
       end else if(m_dtw_rsp_pkt.smi_cmstatus_err === 1) begin
        //#Check.IOAIU.DTWrspCMStatusError
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR","Only CMStatus.Address/DataError is possible on DTWrsp", UVM_NONE);
       end
       
   end
   
   // Copy CMSTATUS from Act to Exp, as it is input to IOAIU and we are unable to predict
   exp_dtw_rsp_pkt.smi_cmstatus = m_dtw_rsp_pkt.smi_cmstatus;
   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Exp DTWRsp:%s",exp_dtw_rsp_pkt.convert2string()), UVM_LOW);
   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Act DTWRsp:%s",m_dtw_rsp_pkt.convert2string()), UVM_LOW);
   if(!exp_dtw_rsp_pkt.compare(m_dtw_rsp_pkt)) begin
      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR","DTWRsp Fields mismatching above!", UVM_NONE);
      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","DTWRsp Fields mismatching above!",UVM_NONE);
   end
endfunction : add_dtw_resp

function void ioaiu_scb_txn::add_snp_dtr_req(smi_seq_item m_pkt);
   m_dtr_req_pkt = m_pkt;
   isSMISNPDTRReqSent = 1;
   t_latest_update    = $time;
   t_sfi_dtr_req = t_latest_update;
   getExpDtrRsp();
  
   //#Check.IOAIU.DataUncorrectableErr.DtrReq_DataErr
  //#Check.IOAIU.OutgoingDTRreq.CMStatusErr
   <%if(obj.assertOn && obj.testBench =="io_aiu"){%>
   <% if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITY") { %>
   if(($test$plusargs("ccp_snp_sram_data_addr_err")) && !(m_dtr_req_pkt.smi_cmstatus_err_payload === 7'b000_0011)) begin
   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","DTRreq snp Cmstatus should be 7'b000_0011 in case of sram address error injection", UVM_NONE);
   end
   <% }%>
   <% }%>
  
endfunction : add_snp_dtr_req

function void ioaiu_scb_txn::add_snp_dtr_resp(smi_seq_item m_pkt);
   m_dtr_rsp_pkt = m_pkt;
   isSMISNPDTRRespRecd = 1;
   t_latest_update     = $time;
   t_sfi_dtr_rsp = t_latest_update;

   exp_dtr_rsp_pkt.smi_msg_id = m_pkt.smi_msg_id;
   exp_dtr_rsp_pkt.smi_tm = m_pkt.smi_tm;
   exp_dtr_rsp_pkt.smi_msg_pri = m_pkt.smi_msg_pri;

   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Exp DTRRsp:%s",exp_dtr_rsp_pkt.convert2string()), UVM_MEDIUM);
   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Act DTRRsp:%s",m_dtr_rsp_pkt.convert2string()), UVM_MEDIUM);
   if(!exp_dtr_rsp_pkt.compare(m_dtr_rsp_pkt)) begin
      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR","DTRRsp Fields mismatching above!", UVM_NONE);
      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","DTRRsp Fields mismatching above!",UVM_NONE);
   end
endfunction : add_snp_dtr_resp

function void ioaiu_scb_txn::add_snp_resp(smi_seq_item m_pkt);
   m_snp_rsp_pkt = m_pkt;
   isSMISNPRespSent  = 1;
   t_latest_update   = $time;
   t_sfi_snp_rsp     = t_latest_update;
    //#Check.IOAIU.TagUncorrectableErr.SNP_AddrErr
    //#Check.IOAIU.SNPrsp.CMStatusAddressError
    <%if(obj.assertOn && obj.testBench =="io_aiu"){%>
   <% if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITY") { %>
   if($test$plusargs("ccp_snp_sram_data_addr_err")) begin
   if(!( m_snp_rsp_pkt.smi_cmstatus_err === 1 && (m_snp_rsp_pkt.smi_cmstatus_err_payload === 7'b000_00100) && !isSMISNPDTRReqNeeded && !isSMIDTWReqNeeded)) begin
   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR","SNPrsp should be address error for ott sram address error test", UVM_NONE);
   end
   end
   <% } %>
   <% } %>

   //#Check.IOAIU.OWO.SNPrsp.CMStatus
   if (owo && m_snp_rsp_pkt.smi_cmstatus != 0) begin
	    `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> OWO - SNPrsp.CMStatus should be 'h0", tb_txnid,<%if(obj.nNativeInterfacePorts > 1){ %> core_id,<%}%>));
  end

endfunction : add_snp_resp

function bit ioaiu_scb_txn::isInAddressSpace(smi_seq_item m_pkt);
   return (m_pkt.smi_addr & ('1 << <%=obj.wAddr%>)) === 0;
endfunction : isInAddressSpace

<%if(obj.useCache) { %>
function bit ioaiu_scb_txn::predictTagUpdate();
   if(isSnoop) begin
   end
   else if(isWrite) begin
   end
endfunction : predictTagUpdate

function bit ioaiu_scb_txn::isWriteHitFull();
   return ((is_ccp_hit || (is_write_hit_upgrade && !isPartialWrite)) &&
	   ((isIoCacheTagPipelineSeen) ? 
		((m_ccp_ctrl_pkt.currstate === UD) ||
		 (m_ccp_ctrl_pkt.currstate === UC) ||
		 (is_write_hit_upgrade && !isPartialWrite && (m_ccp_ctrl_pkt.currstate === SC)) ||
		 (m_ccp_ctrl_pkt.currstate === SD))
	     	    : 0)
	   );
endfunction : isWriteHitFull
<% } %>      

function int ioaiu_scb_txn::isComplete();
   //#Check.IOAIU.CONC.AllRsps
   //#Check.IOAIU.CONC.LegalConcTXN
   if(isRead) begin
          if(
      		(isSMICMDReqNeeded ? isSMISTRRespSent && isSMICMDRespRecd : 1) &&
	 		((isACEReadDataNeeded) ? (!isMultiLineMaster && isMultiAccess) || isACEReadDataSent   : 1)         &&
	 		((isDVMSync) ? isACESnoopReqSent && isACESnoopRespRecd : 1)         &&
	 		((isSMIDTRReqNeeded)   ? isSMIAllDTRRespSent && isSMIDTRRespSent : 1) &&
	 		((m_ace_cmd_type == DVMMSG) ? isSMICMPRespRecd && ((isDVMMultiPart) ? isACEReadDataDVMMultiPartSent : 1) : 1)
     	<%if(obj.useCache) { %> 
      && 
      ((csr_ccp_lookupen)? (// ccp_enable
       (isIoCacheTagPipelineSeen || (isCCPCancelSeen ) || (illDIIAccess) || (mem_regions_overlap) || hasFatlErr || addrNotInMemRegion || (illegalNSAccess) || (illegalCSRAccess)) && 
       ((isCCPReadHitDataNeeded) ? isCCPReadHitDataRcvd : 1)
       ):1) // ccp_disable
	<% } %>		       
	 ) begin
	 return 1;		
      end
   end	
   else if(isAtomic) begin
    // `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("isSMICMDReqNeeded:%0d isSMIUPDReqNeeded:%0d isACEWriteDataNeeded:%0d isACEReadDataNeeded:%0d isSMIDTWReqNeeded:%0d isSMIDTRReqNeeded:%0d is2ndSMICMDReqNeeded:%0d  is2ndSMISTRReqNeeded:%0d", isSMICMDReqNeeded, isSMIUPDReqNeeded, isACEWriteDataNeeded, isACEReadDataNeeded, isSMIDTWReqNeeded, isSMIDTRReqNeeded, is2ndSMICMDReqNeeded, is2ndSMISTRReqNeeded),UVM_NONE)
      if(<%if(obj.useCache) { %>
      ((csr_ccp_lookupen && csr_ccp_allocen)? (// ccp_enable
	 ((isWriteHitFull() && is_write_hit_upgrade_with_fetch) ? isFillDataRcvd && isIoCacheTagPipelineSeen : 1) 
       ):1)  &&// ccp_disable
	<% } %>			
	 ((isSMICMDReqNeeded)    ? isSMISTRRespSent && isSMICMDRespRecd     : 1)         &&
	 ((isSMIUPDReqNeeded)    ? isSMIUPDRespRecd     : 1)         &&
	 ((isACEWriteDataNeeded) ? (!isMultiLineMaster && isMultiAccess) || isACEWriteRespSent   : 1)         &&
	 ((isACEReadDataNeeded) ? (!isMultiLineMaster && isMultiAccess) || isACEReadDataSent   : 1)         &&
	 ((isSMIDTWReqNeeded)    ? isSMIDTWRespRecd  : 1)            &&
	 ((isSMIDTRReqNeeded)   ? isSMIAllDTRRespSent && isSMIDTRRespSent: 1) &&
         ((is2ndSMICMDReqNeeded) ?  is2ndSMICMDReqSent && is2ndSMICMDRespRecd : 1) &&
         ((is2ndSMISTRReqNeeded) ?  is2ndSMISTRRespSent && is2ndSMISTRReqRecd : 1)) begin
	 return 1;		
      end
   end				
   else if(isWrite) begin
    if(<%if(obj.useCache) { %>
      (csr_ccp_lookupen ? (// ccp_enable
	((m_ccp_ctrl_pkt) ? ((m_ccp_ctrl_pkt.wr_data)? ((m_ccp_wr_data_pkt)? 1:0) :1) :1 )&& ((isWriteHitFull() && is_write_hit_upgrade_with_fetch && !(hasFatlErr           )) ? (isFillDataReqd ? isFillDataRcvd : 1) &&  isIoCacheTagPipelineSeen : 1)  &&
	 //(isIoCacheTagPipelineSeen || illegalNSAccess || illDIIAccess || illegalCSRAccess || illDIIAccess || addrNotInMemRegion || mem_regions_overlap || (dtrreq_cmstatus_err == 1 || dtr_req_dbad_high == 1 || dtwrsp_cmstatus_err || (hasFatlErr == 1 && isACEWriteRespSent) <%if(obj.useCache) { %> || m_io_cache_tag_err || ccp_tag_err_in_multiline_txn <% } %>)) 
	  isACEWriteRespSent
	  //Ignore FillReqd if txn gets tagged with FatlErr && !SMICMDReqSent
          //#Check.IOAIU.DTRreq.CMStatusAddrErr.Ignore.FillReqd 
	  && ((isFillReqd && !(dtrreq_cmstatus_err == 1 || dtr_req_dbad_high == 1 || dtwrsp_cmstatus_err == 1 || (!isSMICMDReqSent && hasFatlErr))) ? (isFillDataRcvd || (isSMISTRReqDataErr || isSMISTRReqAddrErr)): 1) //CONC-9223 STRreq.CMStatus.AddrErr will see FillCtrl to invalidate line, but not FillData
      ):1) // ccp_disable
      &&
	<% } %>			
	 ((isSMICMDReqNeeded ) ? (isSMICMDReqSent ? (isSMISTRRespSent && isSMICMDRespRecd) : (dtrreq_cmstatus_err || dtwrsp_cmstatus_err || hasFatlErr || tagged_decerr)) : 1)  &&
	 ((isSMIUPDReqNeeded)    ? isSMIUPDRespRecd     : 1)         &&
	  isACEWriteRespSent                                         &&
	 ((isSMISNPDTRReqNeeded) ? isSMISNPDTRRespRecd  : 1)            &&
	 ((isSMIDTWReqNeeded ) ? (isSMIDTWReqSent ? (isSMICMDReqSent && isSMICMDRespRecd && isSMISTRReqRecd && isSMISTRRespSent && isSMIDTWRespRecd) : (dtrreq_cmstatus_err || dtr_req_dbad_high || dtwrsp_cmstatus_err || hasFatlErr || tagged_decerr)) : 1)            &&
	 ((isSMIDTRReqNeeded)    ? isSMIAllDTRRespSent && isSMIDTRRespSent: 1) && 
         ((is2ndSMICMDReqNeeded) ?  (is2ndSMICMDReqSent && is2ndSMICMDRespRecd && is2ndSMISTRRespSent && is2ndSMISTRReqRecd): 1) //owo
         ) begin
	 return 1;		
      end
   end				
   else if(isSnoop) begin
//      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","Snoop isComplete not implemented");
      if(isSMISNPRespSent &&
<%if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface === "ACELITE-E" || obj.fnNativeInterface === "ACE-LITE") && obj.eAc==1)) { %>
         isACESnoopReqSent && isACESnoopRespRecd &&
         ((isACESnoopDataNeeded) ? isACESnoopDataRecd : 1) &&
<% } %>
	 ((isSMISNPDTRReqNeeded) ? isSMISNPDTRRespRecd     : 1)         &&
	 ((isSMIDTWReqNeeded)    ? isSMIDTWRespRecd  : 1)) begin

	 return 1;		
      end
      //DCTODO IOCCHK
   end
   else if (isDVMSnoop) begin
    case(txn_type)
	"DVM" : begin
            if(smi_flags["single_part_dvm"]) begin
	        return (smi_flags["ACESnpReqDvm1"] &&
		        smi_flags["ACESnpRspDvm1"] &&
		        smi_flags["SMISnpReqDvm1"] && smi_flags["SMISnpReqDvm2"] &&
		        smi_flags["SMISnpRspDvm"]);
            end else begin
	        return (smi_flags["ACESnpReqDvm1"] && smi_flags["ACESnpReqDvm2"] &&
		        smi_flags["ACESnpRspDvm1"] && smi_flags["ACESnpRspDvm2"] &&
		        smi_flags["SMISnpReqDvm1"] && smi_flags["SMISnpReqDvm2"] &&
		        smi_flags["SMISnpRspDvm"]);
            end
	end
	"DVMSYNC" : begin
            if(smi_flags["single_part_dvm"]) begin
	        return (smi_flags["ACESnpReqDvm1"] &&
		        smi_flags["ACESnpRspDvm1"] &&
		        smi_flags["SMISnpReqDvm1"] && smi_flags["SMISnpReqDvm2"] &&
		        smi_flags["ACEReadAddr"]   && smi_flags["ACEReadData"]   && smi_flags["ACEReadDataAck"]   &&
		        smi_flags["SMISnpRspDvm"]);
            end else begin
	        return (smi_flags["ACESnpReqDvm1"] && smi_flags["ACESnpReqDvm2"] &&
		        smi_flags["ACESnpRspDvm1"] && smi_flags["ACESnpRspDvm2"] &&
		        smi_flags["SMISnpReqDvm1"] && smi_flags["SMISnpReqDvm2"] &&
		        smi_flags["ACEReadAddr"]   && smi_flags["ACEReadData"]   && smi_flags["ACEReadDataAck"]   &&
		        smi_flags["SMISnpRspDvm"]);
            end
	end
	//default : return super.isComplete();
      endcase;
   end
   else if(isUpdate) begin
      if(((isSMICMDReqNeeded)    ? isSMISTRRespSent && isSMICMDRespRecd     : 1)         &&
         ((isSMIUPDReqNeeded)    ? isSMIUPDRespRecd     : 1)         &&
         ((isACEWriteDataNeeded) ? isACEWriteDataRecd   : 1)         &&
         ((isACEWriteAddressRecd)? isACEWriteRespSent   : 1)         &&
         ((isSMIDTWReqNeeded)    ? isSMIDTWRespRecd     : 1)) begin
         return 1;
      end
   end
   else if(isIoCacheEvict) begin
      if(((isSMICMDReqNeeded)  ? isSMISTRRespSent && isSMICMDRespRecd     : 1)         &&
	 ((isSMIUPDReqNeeded)    ? isSMIUPDRespRecd     : 1)         &&
	 ((isSMIDTWReqNeeded)    ? isSMIDTWRespRecd  : 1)) begin
	 return 1;		
      end
   end
   else if(isSenderEventReq) begin
      if(($test$plusargs("event_sys_rsp_timeout_error")? 1 : (isSenderSysReqNeeded ? (isSenderSysReqSent &&  isSenderSysRspRcvd) :1))   &&
	  ((isSenderEventAckNeeded)    ? isSenderEventAckRcvd     : 1)       
	 ) begin
	 return 1;		
      end
   end
   else if(isRecieverSysReqRcvd) begin
      if(((isRecieverEventReqNeeded)  ? isRecieverEventReqSent  : 1)        &&
	 ((isRecieverEventAckNeeded)  ? isRecieverEventAckSent  : 1)        && 
	 ((isRecieverSysRspNeeded)    ? isRecieverSysRspSent    : 1)         
	 ) begin
	 return 1;		
      end
   end
   return 0; 				
endfunction : isComplete
      
function bit ioaiu_scb_txn::isStrRspEligibleForIssue();
    //#Check.IOAIU.CONC.Completion
    //DCTODO Make this more detailed			
    bit is_eligible;					
    if(isRead) begin
       if(m_ace_cmd_type == DVMMSG) begin
	  return (((isSMIDTWReqNeeded) ? isSMIDTWReqSent && isSMIDTWRespRecd : 1) &&
		  /* ((isDVMSync) ? isACESnoopReqSent && isACESnoopRespRecd : 1) && ///RTL can't guarentee the order due to Bkpr*/
		  isSMICMPRespRecd
		  );
	  
       end
       else begin
	  return (((isSMIDTRReqNeeded) ? isSMIAllDTRReqRecd : 1) && isSMISTRReqRecd);
       end
       
    end
    else if(isWrite) begin
        if(isAtomic && isCoherentAtomic) begin
            return (((isSMIDTWReqNeeded) ? isSMIDTWRespRecd : 1) && ((is2ndSMISTRReqNeeded) ? is2ndSMISTRReqRecd : 1));
        end
        else begin
	    return ((owo && isCoherent && !isSMISTRRespSent) ? (isSMICMDReqSent && isSMICMDRespRecd && isSMISTRReqRecd) : (((isSMIDTWReqNeeded) ? isSMIDTWRespRecd : 1) && isSMISTRReqRecd));
        end
    end
    else if(isUpdate) begin
        return (((isSMIDTWReqNeeded) ? isSMIDTWRespRecd : 1) && isSMISTRReqRecd);
    end
    else if(isIoCacheEvict) begin
		return (((csr_ccp_updatedis || !isCoherent) ? 1 : isSMIUPDRespRecd) && (isSMIDTWReqNeeded ? isSMIDTWRespRecd : 1) && isSMISTRReqRecd);
    end
   return 0;
endfunction :isStrRspEligibleForIssue

function void ioaiu_scb_txn::compare_smi_axi_data();
   string s;
   smi_seq_item exp_pkt = new();
   if(isRead) begin
       uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("AXI RD Data %s",m_ace_read_data_pkt.sprint_pkt()),UVM_HIGH);

      //CONC-8377
      if (!predict_ott_data_error)
      	getExpRDataFromDtr();

   end
   else if(isWrite || isUpdate) begin
       //#Check.IOAIU.SMI.DTWReq.Data
       //#Check.IOAIU.SMI.DtwReq.cmstatus
       foreach(m_ace_write_data_pkt.wdata[i]) begin
	  if((m_ace_write_data_pkt.wdata[i] != m_dtw_req_pkt.smi_dp_data[i]) && m_dtw_req_pkt.smi_cmstatus !==  8'b1000_0011) begin
		uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("AXI WR Data %s",m_ace_write_data_pkt.sprint_pkt()),UVM_HIGH);
	        print_me();
		uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("AXI WR DATA %0d does not match SMI DP Beat %0d. Exp:0x%0h Act 0x%0h. AXI WR DATA:%s DTWReq:%s",i,i,m_ace_write_data_pkt.wdata[i],m_dtw_req_pkt.smi_dp_data[i],m_ace_write_data_pkt.sprint_pkt(),m_dtw_req_pkt.convert2string()));			
          end
       end
   end
<%if(obj.useCache) { %>
   else if(isIoCacheEvict) begin
      foreach(m_io_cache_data[i]) begin
	 if(m_dtw_req_pkt.smi_dp_data[i] != m_io_cache_data[i]) begin
	    s = "ERROR! IoCacheEvict DTW Data mismatch with CCPEvict Pkt";
	    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s Beat %0d Exp:0x%0h Act 0x%0h",s,i,m_dtw_req_pkt.smi_dp_data[i],m_io_cache_data[i]),UVM_NONE);
	    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s",s),UVM_NONE);
	 end
      end
      
   end
   else if(isSnoop) begin
      if(isSMISNPDTRReqSent && isSMISNPDTRReqNeeded) begin
	 foreach(m_io_cache_data[i]) begin
	    if(m_dtr_req_pkt.smi_dp_data[i] != m_io_cache_data[i]) begin
	       s = "ERROR! Snoop DTR Data mismatch with evict data Pkt";
	       uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s Beat %0d Exp:0x%0h Act 0x%0h",s,i,m_dtr_req_pkt.smi_dp_data[i],m_io_cache_data[i]),UVM_NONE);
	       uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s",s),UVM_NONE);
	    end
	 end
	 
      end

      if(isSMIDTWReqSent && isSMIDTWReqNeeded) begin
	 foreach(m_io_cache_data[i]) begin
	    if(m_dtw_req_pkt.smi_dp_data[i] != m_io_cache_data[i]) begin
	       s = "ERROR! Snoop DTW Data mismatch with evict data Pkt";
	       uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s Beat %0d Exp:0x%0h Act 0x%0h",s,i,m_dtw_req_pkt.smi_dp_data[i],m_io_cache_data[i]),UVM_NONE);
	       uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s",s),UVM_NONE);
	    end
	 end
      end
   end
<% } %>
   else begin
      print_me();
      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("unknown TXN type is comparing SMI Data to ACE Data!"),UVM_NONE);
   end // else: !if(isSnoop)
endfunction : compare_smi_axi_data

<%if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5") { %>
function void ioaiu_scb_txn::check_rresp_for_ace();
    //Check RRESP IsShared/PassDirty
    if(m_ace_cmd_type == RDNOSNP ||
       m_ace_cmd_type == DVMMSG  ||
       m_ace_cmd_type == DVMCMPL) begin : if_certain_cmd_types
        if(m_ace_read_data_pkt != null && m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT] != 0) begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response PassDirty field is wrong. Expected value is %b, actual value is %b.", 0, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT]), UVM_NONE);
        end
        if(m_ace_read_data_pkt != null && m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT] != 0) begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response IsShared field is wrong. Expected value is %b, actual value is %b.", 0, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT]), UVM_NONE);
        end
    end : if_certain_cmd_types
    else begin : if_not_certain_cmd_types
        if(isSMIDTRReqNeeded == 0) begin : not_needed //CONC-6925
            if( !isSMISTRReqNotNeeded) begin
                if(m_str_req_pkt.smi_cmstatus_state == 'b100 || m_str_req_pkt.smi_cmstatus_state == 'b000) begin
                    if(m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT] != 0) begin
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response PassDirty field is wrong(data less transaction). State in StrReq.cmstatus is %b, Expected value is %b, actual value is %b.", m_str_req_pkt.smi_cmstatus_state, 0, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT]), UVM_NONE);
                    end
                    if(m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT] != 0) begin
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response IsShared field is wrong(data less transaction). State in StrReq.cmstatus is %b, Expected value is %b, actual value is %b.", m_str_req_pkt.smi_cmstatus_state, 0, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT]), UVM_NONE);
                    end
                end
                else if(m_str_req_pkt.smi_cmstatus_state == 'b010 || m_str_req_pkt.smi_cmstatus_state == 'b011) begin
                    if(m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT] != 0) begin
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response PassDirty field is wrong(data less transaction). State in StrReq.cmstatus is %b, Expected value is %b, actual value is %b.", m_str_req_pkt.smi_cmstatus_state, 0, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT]), UVM_NONE);
                    end
                    if(m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT] != 1) begin
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response IsShared field is wrong(data less transaction). state in StrReq.cmstatus is %b, Expected value is %b, actual value is %b.", m_str_req_pkt.smi_cmstatus_state, 1, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT]), UVM_NONE);
                    end
                end else begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("DCE sends illegal state in StrReq Cmstatus(data less transaction). State in StrReq.cmstatus is %b. Legal state value is 'b000/'b100/'b010/'b011", m_str_req_pkt.smi_cmstatus_state), UVM_NONE);
                end
            end
        end : not_needed
        else begin : needed
            if(isSMIDTRReqRecd == 0) begin
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU hasn't received needed DtrReq to check ACE Rresp. ARID is 0x%h", m_ace_read_data_pkt.rid), UVM_NONE);
            end else begin : req_recd
                eMsgDTR DtrReq_type;
                $cast(DtrReq_type, m_dtr_req_pkt.smi_msg_type);
                //PassDirty
                if(m_dtr_req_pkt.smi_msg_type == DTR_DATA_INV     ||
                   m_dtr_req_pkt.smi_msg_type == DTR_DATA_UNQ_CLN ||
                   m_dtr_req_pkt.smi_msg_type == DTR_DATA_SHR_CLN ) begin
                    if(m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT] != 0) begin
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response PassDirty field is wrong. Expected value is %b, actual value is %b. BID is 0x%h. DtrReq type: %s ", 0, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT], m_ace_read_data_pkt.rid, DtrReq_type.name()), UVM_NONE);
                    end
                end else begin
                    if(m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT] != 1'b1) begin
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response PassDirty field is wrong. Expected value is %b, actual value is %b. BID is 0x%h. DtrReq type: %s ", 1, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT], m_ace_read_data_pkt.rid, DtrReq_type.name()), UVM_NONE);
                    end
                end
                //IsShared
                if(m_dtr_req_pkt.smi_msg_type == DTR_DATA_INV     ||
                   m_dtr_req_pkt.smi_msg_type == DTR_DATA_UNQ_CLN ||
                   m_dtr_req_pkt.smi_msg_type == DTR_DATA_UNQ_DTY ) begin
                    if(m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT] != 0) begin
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response IsShared field is wrong. Expected value is %b, actual value is %b. BID is 0x%h. DtrReq type: %s ", 0, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT], m_ace_read_data_pkt.rid, DtrReq_type.name()), UVM_NONE);
                    end
                end else begin
                    if(m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT] != 1'b1) begin
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response IsShared field is wrong. Expected value is %b, actual value is %b. BID is 0x%h. DtrReq type: %s ", 1, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT], m_ace_read_data_pkt.rid, DtrReq_type.name()), UVM_NONE);
                    end
                end
            end : req_recd
        end : needed
    end : if_not_certain_cmd_types
	
	if(m_ace_cmd_type inside {RDUNQ, CLNUNQ, MKUNQ, CLNINVL, MKINVL} && m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT] != 0)
    	`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d ace_cmdtype:%0p should have RResp.Shared Bit deasserted. Check ARM IHI 0022E spec C3.2.1 Read response signaling", tb_txnid, m_ace_cmd_type));

	if(m_ace_cmd_type inside {RDONCE, RDCLN, CLNUNQ, MKUNQ, CLNSHRD, CLNINVL, MKINVL} && m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT] != 0)
    	`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d ace_cmdtype:%0p should have RResp.PassDirty Bit deasserted. Check ARM IHI 0022E C3.2.1 Read response signaling", tb_txnid, m_ace_cmd_type));

    for(int idx = 1; idx < m_ace_read_data_pkt.rresp_per_beat.size(); idx++) begin
        if(m_ace_read_data_pkt.rresp_per_beat[idx][CRRESPPASSDIRTYBIT] != m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT]) begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response PassDirty field is not constant within burst. beat index: %d, Expected value is %b, actual value is %b.", idx, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT], m_ace_read_data_pkt.rresp_per_beat[idx][CRRESPPASSDIRTYBIT]), UVM_NONE);
        end
        if(m_ace_read_data_pkt.rresp_per_beat[idx][CRRESPISSHAREDBIT] != m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT]) begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response IsShared field is not constant within burst. beat index: %d, Expected value is %b, actual value is %b.", idx, m_ace_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT], m_ace_read_data_pkt.rresp_per_beat[idx][CRRESPISSHAREDBIT]), UVM_NONE);
        end
    end
endfunction : check_rresp_for_ace
<% } %>

function void ioaiu_scb_txn::getExpRDataFromDtr();
   int no_of_bytes,beat_counter;
   smi_dp_data_bit_t exp_cl_data [];
   smi_dp_be_t       exp_cl_be [];

   axi_xdata_logic_t exp_rdata [];
   int 	   arsize;
   int m_dtsize,m_smi_num_bytes,m_num_bytes,m_wrap_beat_upper,m_wrap_beat_lower,m_smi_wrap_beat_upper,m_smi_wrap_beat_lower;
   longint m_start_addr;
   int 	   is_wrap;

   longint m_lower_wrapped_boundary;
   longint m_upper_wrapped_boundary;

   longint m_smi_lower_wrapped_boundary;
   longint m_smi_upper_wrapped_boundary;

   
   longint smi_offset               = (m_sfi_addr % SYS_nSysCacheline);
   int     smi_beat_offset          = (smi_offset /(DATA_WIDTH / 8));
   longint m_cl_addr                = (m_sfi_addr / SYS_nSysCacheline) * SYS_nSysCacheline;
   int 	   m_beats_in_a_cacheline   = SYS_nSysCacheline*8/DATA_WIDTH;

   int count_beats = 0;

	
   
   if((m_ace_cmd_type === ATMLD) ||
      (m_ace_cmd_type === ATMSWAP)) begin
      m_num_bytes = (m_ace_write_addr_pkt.awlen + 1) * (2 ** m_ace_write_addr_pkt.awsize);
      is_wrap     = (m_ace_write_addr_pkt.awburst === AXIWRAP) ? 1 : 0;
   end
   else if (m_ace_cmd_type === ATMCOMPARE) begin
      m_num_bytes = (m_ace_write_addr_pkt.awlen + 1) * (2 ** m_ace_write_addr_pkt.awsize) / 2;
      is_wrap     = (m_ace_write_addr_pkt.awburst === AXIWRAP) ? 1 : 0;
   end
   else begin
      m_num_bytes = (m_ace_read_addr_pkt.arlen + 1) * (2 ** m_ace_read_addr_pkt.arsize);
      is_wrap     = (m_ace_read_addr_pkt.arburst === AXIWRAP) ? 1 : 0;
   end

   //#Check.IOAIU.SMI.DTRReq.smi_size
   m_smi_num_bytes = 2**m_cmd_req_pkt.smi_size;

   m_start_addr             = (m_sfi_addr/(DATA_WIDTH/8)) * (DATA_WIDTH/8);
   m_lower_wrapped_boundary = (m_start_addr/m_num_bytes) * m_num_bytes; 
   m_upper_wrapped_boundary = m_lower_wrapped_boundary + m_num_bytes; 
   if(m_cl_addr == 'h0) begin  // FIX for when addr=0 (starting boot address)
      m_wrap_beat_lower        = m_lower_wrapped_boundary / (DATA_WIDTH/8);
      m_wrap_beat_upper        = (m_upper_wrapped_boundary - 1) / (DATA_WIDTH/8);   
   end
   else begin
      m_wrap_beat_lower        = (m_lower_wrapped_boundary % m_cl_addr) / (DATA_WIDTH/8);
      m_wrap_beat_upper        = ((m_upper_wrapped_boundary - 1)% m_cl_addr) / (DATA_WIDTH/8);   
   end

   m_smi_lower_wrapped_boundary = (m_start_addr/m_smi_num_bytes) * m_smi_num_bytes; 
   m_smi_upper_wrapped_boundary = m_smi_lower_wrapped_boundary + m_smi_num_bytes; 
   if(m_cl_addr == 'h0) begin  // FIX for when addr=0 (starting boot address)
      m_smi_wrap_beat_lower        = m_smi_lower_wrapped_boundary / (DATA_WIDTH/8);
      m_smi_wrap_beat_upper        = (m_smi_upper_wrapped_boundary - 1) / (DATA_WIDTH/8);   
   end
   else begin
      m_smi_wrap_beat_lower        = (m_smi_lower_wrapped_boundary % m_cl_addr) / (DATA_WIDTH/8);
      m_smi_wrap_beat_upper        = ((m_smi_upper_wrapped_boundary - 1)% m_cl_addr) / (DATA_WIDTH/8);   
   end
   
   exp_cl_data = new[(SYS_nSysCacheline / (DATA_WIDTH / 8))];
   exp_cl_be   = new[(SYS_nSysCacheline / (DATA_WIDTH / 8))];

   beat_counter = smi_beat_offset;
   
   //`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG", $sformatf("IOAIU_UID:%0d addr:0x%0h DATA_WIDTH:%0d smi_offset:0x%0h smi_beat_offset:%0d start_addr:0x%0h",  tb_txnid, m_sfi_addr, DATA_WIDTH, smi_offset, smi_beat_offset, m_start_addr), UVM_LOW);
   
    //Reconstruct cacheline
   foreach (m_dtr_req_pkt.smi_dp_data[i]) begin
        exp_cl_data[beat_counter] = m_dtr_req_pkt.smi_dp_data[i];
        exp_cl_be[beat_counter]   = m_dtr_req_pkt.smi_dp_be[i];
        //`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG", $sformatf("IOAIU_UID:%0d dtr_idx:%0d beat_counter:%0d exp_cl_be[%0d]=%0p exp_cl_data[%0d]=%0p", tb_txnid,i, beat_counter, beat_counter, exp_cl_be[beat_counter], beat_counter, exp_cl_data[beat_counter]), UVM_LOW);
        
        beat_counter++;
        if (!isMultiAccess && is_wrap && (beat_counter > m_wrap_beat_upper)) begin
            beat_counter = m_wrap_beat_lower;
        end
        count_beats++;
	
		// In some cases the DMI is sending more beats than what are requested
		// This is okay since the IOAIU is expected to ignore the beats that is not necessary
		// Below code is to handle the case. Once we get the beat that we need, stop the loop
        if((count_beats > m_ace_read_addr_pkt.arlen)) break;
   end

   //`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> addr:0x%0h DATA_WIDTH:%0d smi_offset:0x%0h smi_beat_offset:%0d start_addr:0x%0h",  tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_sfi_addr, DATA_WIDTH, smi_offset, smi_beat_offset, m_start_addr), UVM_LOW);

    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> lower_wrap_boundary:0x%0h upper_wrap_boundary:0x%0h wrap_beat_lower:0x%0h wrap_beat_upper:0x%0h", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_lower_wrapped_boundary, m_upper_wrapped_boundary, m_wrap_beat_lower, m_wrap_beat_upper), UVM_LOW);
    
    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> smi_lower_wrap_boundary:0x%0h smi_upper_wrap_boundary:0x%0h smi_wrap_beat_lower:0x%0h smi_wrap_beat_upper:0x%0h", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_smi_lower_wrapped_boundary, m_smi_upper_wrapped_boundary, m_smi_wrap_beat_lower, m_smi_wrap_beat_upper), UVM_LOW);

   // foreach(exp_cl_data[i]) begin
   //     `uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> i:%0d exp_cl_be:%0p exp_cl_data:%0p", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, i, exp_cl_be[i], exp_cl_data[i]), UVM_LOW);
   // end

    //foreach (m_dtr_req_pkt.smi_dp_data[i]) begin
    //    `uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> i:%0d smi_dp_dwid:%0p smi_dp_be:%0p smi_dp_data:%0p",tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, i,  m_dtr_req_pkt.smi_dp_dwid[i], m_dtr_req_pkt.smi_dp_be[i], m_dtr_req_pkt.smi_dp_data[i]), UVM_LOW);
    //end
   
    if((m_ace_cmd_type === ATMLD) ||
      (m_ace_cmd_type === ATMSWAP) ||
      (m_ace_cmd_type === ATMCOMPARE)) begin
      exp_rdata    = new[m_ace_write_addr_pkt.awlen + 1];
   end
   else begin
       if (owo_512b) begin 
      exp_rdata    = new[1];
       end else begin 
      exp_rdata    = new[m_ace_read_addr_pkt.arlen + 1];
       end
   end
   beat_counter = smi_beat_offset;

   if (owo_512b) begin 
        foreach (exp_cl_data[i]) begin 
            if (i==0)
                exp_rdata[0][255:0]   = exp_cl_data[i];
            if (i==1)
                exp_rdata[0][511:256] = exp_cl_data[i];
        end 

        foreach (m_ace_read_data_pkt.rdata[i]) begin 
            if (m_ace_read_data_pkt.rdata[i] != exp_rdata[i]) begin
		 `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("IOAIU_UID:%0d AXI RD DATA 0x%0h does not match Exp Data 0x%0h", tb_txnid, m_ace_read_data_pkt.rdata[i],exp_rdata[i]));
            end
        end 
      
    end else begin 

	   foreach (exp_rdata[i]) begin
			exp_rdata[i] = exp_cl_data[beat_counter];

        		//uvm_report_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> beat_counter:%0d", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, beat_counter), UVM_LOW);
			if((m_ace_read_data_pkt.rdata[i] != exp_rdata[i])) begin
				print_me(0,1,0,0);
				uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> AXI RD DATA %0d does not match SMI DP Beat %0d. ADDR:0x%0h AXIRD:0x%0h SMIDP 0x%0h. AXI RD DATA:%s \nDTRReq:%s \nexp_data:%p exp_cl_data:%p \nsmi_beat_offset:%0d, m_wrap_beat_lower:%0d, m_wrap_beat_upper:%0d, m_upper_wrapped_boundary:0x%0h, m_lower_wrapped_boundary:0x%0h is_wrap:%0d smi_num_bytes:%0d m_cl_addr:0x%0h", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, i,i,m_sfi_addr, m_ace_read_data_pkt.rdata[i],exp_rdata[i],m_ace_read_data_pkt.sprint_pkt(),m_dtr_req_pkt.convert2string(), exp_rdata, exp_cl_data,smi_beat_offset,m_smi_wrap_beat_lower,m_smi_wrap_beat_upper,m_smi_upper_wrapped_boundary,m_smi_lower_wrapped_boundary,is_wrap, m_smi_num_bytes, m_cl_addr),UVM_NONE);
//		 uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("AXI RD DATA %0d does not match SMI DP Beat %0d. AXIRD:0x%0h SMIDP 0x%0h. AXI RD DATA:%s DTRReq:%s",i,i,m_ace_read_data_pkt.rdata[i],exp_rdata[i],m_ace_read_data_pkt.sprint_pkt(),m_dtr_req_pkt.convert2string()),UVM_NONE);
			end
			beat_counter++;
			if (!isMultiAccess && is_wrap && (beat_counter > m_wrap_beat_upper)) begin
				beat_counter = m_wrap_beat_lower;
			end
		end
    end
endfunction : getExpRDataFromDtr


function smi_seq_item ioaiu_scb_txn::getExpCmdReq(smi_seq_item m_pkt);
    //DCTODO create cmd 
    //#Check.IOAIU.SMI.CMDReq.TargIDRdNoSnoop

    smi_seq_item exp_pkt;
    int axlen, fnmem_region_idx, axcache;
    axi_axlock_enum_t axlock;
    axi_axburst_t axburst;
    bit accurate_smi_size;
    exp_pkt = new();
    exp_pkt.copy(m_pkt);
    exp_pkt.smi_ndp = 0;
    exp_pkt.smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB] = m_pkt.smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB];
    exp_pkt.smi_ndp[CMD_REQ_MPF2_MSB:CMD_REQ_MPF2_LSB] = m_pkt.smi_ndp[CMD_REQ_MPF2_MSB:CMD_REQ_MPF2_LSB];
    //#Check.IOAIU.SMI.CMDReq.TargetID
    exp_pkt.smi_targ_id = mapAddrToTarg(exp_pkt);
    exp_pkt.smi_dest_id = mapAddrToDestId(exp_pkt);
    <% if(obj.testBench == 'io_aiu') { %>
    //CONC-11353
    <%if(obj.nNativeInterfacePorts > 1){ %>
    exp_smi_msg_id[WSMIMSGID-1:WSMIMSGID-<%=Math.log2(obj.nNativeInterfacePorts)%>]=core_id; 
    exp_smi_msg_id[WSMIMSGID-1-<%=Math.log2(obj.nNativeInterfacePorts)%>:0]=(m_ott_status==ALLOCATED) ? m_ott_id:-1;
    exp_pkt.smi_msg_id = exp_smi_msg_id;
    //uvm_report_info("<%=obj.strRtlNamePrefix%> Multicore Exp smi_msg_id",$sformatf("core%0d:core_ID msb %0d lsb %0d , ott_ID msb %0d lsb %0d", this.core_id,WSMIMSGID-1,WSMIMSGID-<%=Math.log2(obj.nNativeInterfacePorts)%>, WSMIMSGID-1-<%=Math.log2(obj.nNativeInterfacePorts)%>,0),UVM_NONE);
    <% } else {%>
    exp_smi_msg_id[WSMIMSGID-1:WSMIMSGID-1]=0; 
    exp_smi_msg_id[WSMIMSGID-2:0]=(m_ott_status==ALLOCATED) ? m_ott_id:-1;
    exp_pkt.smi_msg_id = exp_smi_msg_id;
    //uvm_report_info("<%=obj.strRtlNamePrefix%> single core Exp smi_msg_id",$sformatf("core%0d:core_ID msb %0d lsb %0d , ott_ID msb %0d lsb %0d", this.core_id,WSMIMSGID-1,WSMIMSGID-1, WSMIMSGID-2,0),UVM_NONE);
    <%}%>
    <%}%>
    //#Check.IOAIU.OWO.CMDreq.CMO_Qos
    //TODO:CONC-17413 may be future implementation, but not currently. 
    //if (owo && isWrite && (exp_pkt.smi_msg_type == eCmdClnUnq)) begin 
    //  exp_pkt.smi_qos = (addrMgrConst::get_highest_qos() != 0) ? 'hf : 'h0;
    //end else begin
      // Common for all type of NativeIntf
      //#Check.IOAIU.SMI.CMDReq.QoS
      exp_pkt.smi_qos = csr_use_eviction_qos ? csr_eviction_qos : m_axi_qos;
   //end

    //#Check.IOAIU.SMI.CMDReq.Priority
    exp_pkt.smi_msg_pri = addrMgrConst::qos_mapping(exp_pkt.smi_qos);
    //#Check.IOAIU.SMI.CMDReq.EN
    exp_pkt.smi_en = 1'b0; // Little Endian for all
    exp_pkt.smi_lk = 2'b00;// Line Locking Future use only
    //#Check.IOAIU.SMI.RL
    //#Check.IOAIU.SMI.CMDReq.RL
    //#Check.IOAIU.OWO.CMDreq.RL
    exp_pkt.smi_rl = 2'b01;// Response Level : 1 for CmdReq
    //#Check.IOAIU.SMI.CMDReq.IntfSize
    exp_pkt.smi_intfsize = $clog2(<%=obj.intfDWs%>);

    uvm_config_db#(int)::get(uvm_root::get(), "*", "ioaiu_cctrlr_phase", ioaiu_cctrlr_phase);
    //#Check.IOAIU.SMI.CMDReq.TM
    //#Check.IOAIU.CmdReq.TM
    if (!isIoCacheEvict) begin
        exp_pkt.smi_tm = getExpTM(isDVM);
    end
    
    //#Check.IOAIU.SMI.CMDReq.TOF
    <%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || obj.orderedWriteObservation == true) { %> 
        exp_pkt.smi_tof = SMI_TOF_ACE;
    <%}else{%>
        exp_pkt.smi_tof = SMI_TOF_AXI;
        if(isRead) begin		       
            if(m_ace_read_addr_pkt.arcache == 4'b0100 || m_ace_read_addr_pkt.arcache == 4'b0101 ||
                m_ace_read_addr_pkt.arcache == 4'b1000 || m_ace_read_addr_pkt.arcache == 4'b1001 ||
                m_ace_read_addr_pkt.arcache == 4'b1100 || m_ace_read_addr_pkt.arcache == 4'b1101 ) begin
                print_me();					     
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Illegal value of ArCACHE! 'b%0b for packet",m_ace_read_addr_pkt.arcache),UVM_NONE);
            end
        end
        else if(isWrite) begin
            if(m_ace_write_addr_pkt.awcache == 4'b0100 || m_ace_write_addr_pkt.awcache == 4'b0101 ||
                m_ace_write_addr_pkt.awcache == 4'b1000 || m_ace_write_addr_pkt.awcache == 4'b1001 ||
                m_ace_write_addr_pkt.awcache == 4'b1100 || m_ace_write_addr_pkt.awcache == 4'b1101 ) begin
                print_me();					     
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Illegal value of AwCACHE! 'b%0b for packet",m_ace_write_addr_pkt.awcache),UVM_NONE);
            end
        end
    <%}%>
    //#Check.IOAIU.AXI.AXItoConcertoTranslation
    //#Check.IOAIU.SMI.CMDReq.Translation
    //#Check.IOAIU.SMI.CMDReq.AC
    //#Check.IOAIU.SMI.CMDReq.CA
    //#Check.IOAIU.SMI.CMDReq.CH
    //#Check.IOAIU.SMI.CMDReq.NS
    //#Check.IOAIU.SMI.CMDReq.PR
    //#Check.IOAIU.SMI.CMDReq.OR
    //#Check.IOAIU.SMI.CMDReq.ST
    //#Check.IOAIU.SMI.CMDReq.VZ
    <%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
        // This is based on "TABLE 4-8. AXI-4 AxCACHE[3:0] to Concerto C attribute translation." in Ncore3SysArch which is overriden by "Table 4.16" in CCMP Spec as below
        <%if (obj.useCache) { %> 
             if (csr_ccp_lookupen) begin: _cmdReq_proxy_enabled
                if(isRead) begin		       
                    exp_pkt.smi_vz= (m_ace_read_addr_pkt.arcache==0 || m_ace_read_addr_pkt.arcache==2);
                    //exp_pkt.smi_ac = m_ace_read_addr_pkt.arcache[2];
                    exp_pkt.smi_ac = (m_ccp_ctrl_pkt) ? ((m_ccp_ctrl_pkt.alloc==1 && (m_ccp_ctrl_pkt.currstate == IX)) ? 0 : m_ace_read_addr_pkt.arcache[2]) : m_ace_read_addr_pkt.arcache[2]; //CONC-10578 if a Read is allocated into cache, the outgoing SMI will have AC=0
                    exp_pkt.smi_ca = (m_ace_read_addr_pkt.arcache[1] && (m_ace_read_addr_pkt.arcache[2] || m_ace_read_addr_pkt.arcache[3]));//CONC-4083     exp_pkt.smi_ca = (m_ace_read_addr_pkt.              arcache[3:2] ==  'b00) ? 0 : 1;
                    exp_pkt.smi_ch = 1;
                    exp_pkt.smi_st = !m_ace_read_addr_pkt.arcache[1];
                    exp_pkt.smi_ns = <%if(obj.wSecurityAttribute > 0){%>m_ace_read_addr_pkt.arprot[1]<%}else{%>0<%}%>;
                    exp_pkt.smi_pr = m_ace_read_addr_pkt.arprot[0];
                    exp_pkt.smi_order = getExpCmdOR();
                end
                else if(isWrite) begin
                    exp_pkt.smi_vz= (m_ace_write_addr_pkt.awcache==0 || m_ace_write_addr_pkt.awcache==2);
                    //exp_pkt.smi_ac = is_write_hit_upgrade ? 1 : m_ace_write_addr_pkt.awcache[3]; // CONC-7018
                    exp_pkt.smi_ac = (m_ccp_ctrl_pkt) ? ((m_ccp_ctrl_pkt.alloc==1 || (m_ccp_ctrl_pkt.currstate != IX)) ? 0 : m_ace_write_addr_pkt.awcache[3]) :m_ace_write_addr_pkt.awcache[3]; //CONC-10578 if a Write is allocated into cache, the outgoing SMI will have AC=m_ace_write_addr_pkt.awcache[3]
                    exp_pkt.smi_ca = (m_ace_write_addr_pkt.awcache[1] && (m_ace_write_addr_pkt.awcache[2] || m_ace_write_addr_pkt.awcache[3]));
                    exp_pkt.smi_ch = 1;
                    exp_pkt.smi_st = !m_ace_write_addr_pkt.awcache[1];
                    exp_pkt.smi_ns = <%if(obj.wSecurityAttribute > 0){%>m_ace_write_addr_pkt.awprot[1]<%}else{%>0<%}%>;
                    exp_pkt.smi_pr = m_ace_write_addr_pkt.awprot[0];
                    exp_pkt.smi_order = getExpCmdOR(); 
                end
                else if(isIoCacheEvict) begin //CONC-9232
                        dest_id = addrMgrConst::map_addr2dmi_or_dii(exp_pkt.smi_addr,fnmem_region_idx);
	                exp_pkt.smi_vz = (addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DMI) ? 0 : 1; //CONC-15247 vz should be 1 for a cache eviction to DII
	                exp_pkt.smi_ac = 1;
                end 
            end: _cmdReq_proxy_enabled else begin:_cmdReq_proxy_disabled 
        <%}%>
        // This is based on "TABLE 4-8. AXI-4 AxCACHE[3:0] to Concerto C attribute translation." in Ncore3SysArch which is overriden by "Table 4.16" in CCMP Spec as below
        if(isRead) begin
            exp_pkt.smi_vz = ((m_ace_read_addr_pkt.arcache==0 || m_ace_read_addr_pkt.arcache==2)) ? 1 : 0;
            exp_pkt.smi_ac = m_ace_read_addr_pkt.arcache[2];
            exp_pkt.smi_ca = m_ace_read_addr_pkt.arcache[1] && (m_ace_read_addr_pkt.arcache[2]|| m_ace_read_addr_pkt.arcache[3]);
            exp_pkt.smi_ch = 0;
            exp_pkt.smi_st = !m_ace_read_addr_pkt.arcache[1];
            exp_pkt.smi_ns = <%if(obj.wSecurityAttribute > 0){%>m_ace_read_addr_pkt.arprot[1]<%}else{%>0<%}%>;
            exp_pkt.smi_pr = m_ace_read_addr_pkt.arprot[0];
            
            exp_pkt.smi_order = getExpCmdOR();
        end
        else if(isWrite) begin
            //#Check.IOAIU.OWO.CMDreq.VZ
            exp_pkt.smi_vz = ((m_ace_write_addr_pkt.awcache==0 || m_ace_write_addr_pkt.awcache==2) || owo) ? 1 : 0;
            exp_pkt.smi_ac = m_ace_write_addr_pkt.awcache[3];
            exp_pkt.smi_ca = m_ace_write_addr_pkt.awcache[1] && (m_ace_write_addr_pkt.awcache[2] || m_ace_write_addr_pkt.awcache[3]);
            exp_pkt.smi_ch = 0;
            exp_pkt.smi_st = !m_ace_write_addr_pkt.awcache[1];
            exp_pkt.smi_ns = <%if(obj.wSecurityAttribute > 0){%>m_ace_write_addr_pkt.awprot[1]<%}else{%>0<%}%>;
            exp_pkt.smi_pr = m_ace_write_addr_pkt.awprot[0];
            exp_pkt.smi_order = getExpCmdOR();
        end
        <%if (obj.useCache) { %> 
            end :_cmdReq_proxy_disabled
        <%}%>
    <%}else if(obj.fnNativeInterface === "ACE-LITE" || obj.fnNativeInterface === "ACELITE-E" || obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5") { %>
        if(isRead) begin
            exp_pkt.smi_vz = (m_ace_read_addr_pkt.arcache==0 || m_ace_read_addr_pkt.arcache==2) ? 1 : 0;
            exp_pkt.smi_ac = m_ace_read_addr_pkt.arcache[2];
            exp_pkt.smi_ca = (m_ace_read_addr_pkt.arcache[1] && (m_ace_read_addr_pkt.arcache[2] || m_ace_read_addr_pkt.arcache[3]));
            exp_pkt.smi_ch = exp_pkt.smi_ca;
            exp_pkt.smi_st = !m_ace_read_addr_pkt.arcache[1];
            exp_pkt.smi_ns = <%if(obj.wSecurityAttribute > 0){%>m_ace_read_addr_pkt.arprot[1]<%}else{%>0<%}%>;
            exp_pkt.smi_pr = m_ace_read_addr_pkt.arprot[0];
                exp_pkt.smi_order = getExpCmdOR(); 
        end
        else if(isWrite) begin
            //#Check.IOAIU.OWO.CMDreq.VZ
            exp_pkt.smi_vz = (m_ace_write_addr_pkt.awcache==0 || m_ace_write_addr_pkt.awcache==2 || owo) ? 1 : 0;
            exp_pkt.smi_ac = m_ace_write_addr_pkt.awcache[3];
            exp_pkt.smi_ca = m_ace_write_addr_pkt.awcache[1] && (m_ace_write_addr_pkt.awcache[2] || m_ace_write_addr_pkt.awcache[3]);
            exp_pkt.smi_ch = exp_pkt.smi_ca; 
            exp_pkt.smi_st = !m_ace_write_addr_pkt.awcache[1];
            exp_pkt.smi_ns = <%if(obj.wSecurityAttribute > 0){%>m_ace_write_addr_pkt.awprot[1]<%}else{%>0<%}%>;
            exp_pkt.smi_pr = m_ace_write_addr_pkt.awprot[0];
            
            exp_pkt.smi_order = getExpCmdOR();
        end
    <%}%>
    //#Check.IOAIU.SMI.CMDReq.smi_size
    //#Check.IOAIU.SMI.CMDReq.Size
    //#Check.IOAIU.BurstRead
    //#Check.IOAIU.BurstReadInterleave
    //#Check.IOAIU.BurstWrite
    //#Check.IOAIU.BurstWriteInterleave
    exp_pkt.smi_size = 3'b110; //always access 64 bytes
    //#Check.IOAIU.SMI.CMDReq.DId
    if (isRead && !isDVM) begin
        dest_id = addrMgrConst::map_addr2dmi_or_dii(m_ace_read_addr_pkt.araddr,fnmem_region_idx);
    end else if (isWrite) begin
        dest_id = addrMgrConst::map_addr2dmi_or_dii(m_ace_write_addr_pkt.awaddr,fnmem_region_idx);
    end

    //CONC-11224 All txns to DII (excluding those allocating in cache) will
    //have the smi_size equal to size of the data
    <%if(obj.useCache){%>
        if (csr_ccp_allocen && m_ccp_ctrl_pkt.alloc) begin
            exp_pkt.smi_size = 3'b110; //always access 64 bytes
        end 
        else if (addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DMI) begin
            exp_pkt.smi_size = 3'b110;
        end
        else if (addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DII) begin
            exp_pkt.smi_size = getSmiSize();
        end
    <%} else {%>
        if (m_ace_cmd_type inside {ATMSTR, ATMLD, ATMSWAP, ATMCOMPARE}) begin
            exp_pkt.smi_size = getSmiSize();
        end else if (addrMgrConst::get_unit_type(exp_pkt.smi_dest_id) == addrMgrConst::DII) begin 
            exp_pkt.smi_size = getSmiSize();
        end else if (addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DMI) begin
            exp_pkt.smi_size = 3'b110;
        end 
    <%}%>

    //CONC-10831 RTL send the correct size in the case for all exclusives going to the DMI or DII.
    if ((isRead && m_ace_read_addr_pkt.arlock == EXCLUSIVE) ||
	(isWrite && m_ace_write_addr_pkt.awlock == EXCLUSIVE)) begin
        exp_pkt.smi_size = getSmiSize();
    end

    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG", $psprintf("IOAIU_UID:%0d 3 exp_pkt.smi_size:%0d", tb_txnid, exp_pkt.smi_size),UVM_LOW)

    //CONC-11485,CONC-11550
    //Very specific case, if the initiator is 64bit and axlen > 0,then if addr[5:4] = 01 then smi_size will be 6. 
    //smi_size must increase by 1 if the INCR transaction crosses the Concerto WRAP boundary.
    axlen   = isRead ? m_ace_read_addr_pkt.arlen   : (isWrite ? m_ace_write_addr_pkt.awlen : 0);
    axburst = isRead ? m_ace_read_addr_pkt.arburst : (isWrite ? m_ace_write_addr_pkt.awburst : AXIFIXED);
    axlock  = isRead ? m_ace_read_addr_pkt.arlock  : (isWrite ? m_ace_write_addr_pkt.awlock : NORMAL);
    axcache  = isRead ? m_ace_read_addr_pkt.arcache  : (isWrite ? m_ace_write_addr_pkt.awcache : 0);
        
    if ((axlen != 0) && (axburst == AXIINCR || isMultiAccess) && (axlock == NORMAL) && !isAtomic) begin
        if ((<%=obj.wData%> == 64) && (exp_pkt.smi_addr[5:4] == 'b01)) begin
            exp_pkt.smi_size = 6;
        end else if ((|exp_pkt.smi_addr[4:0] == 1) && (exp_pkt.smi_size == 5)) begin
            exp_pkt.smi_size = 6;
        end else if ((|exp_pkt.smi_addr[3:0] == 1) && (exp_pkt.smi_size == 4)) begin
            exp_pkt.smi_size = 5;
        end
    end

    exp_pkt.smi_size = 0;
    exp_pkt.smi_size = predict_smi_size(exp_pkt.smi_addr);
    
    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB TXN DBG", $psprintf("IOAIU_UID:%0d 4 exp_pkt.smi_size:%0d", tb_txnid, exp_pkt.smi_size),UVM_LOW)

    //#Check.IOAIU.SMI.CMDReq.MPF1
    case(exp_pkt.smi_msg_type)
        eCmdWrStshPtl, eCmdWrStshFull, eCmdLdCchShd, eCmdLdCchUnq: begin
            exp_pkt.smi_mpf1_stash_valid = m_ace_write_addr_pkt.awstashniden;
            exp_pkt.smi_mpf1_stash_nid   = m_ace_write_addr_pkt.awstashnid[<%=obj.wFUnitId%>-1:0];
        end
        eCmdRdAtm, eCmdWrAtm, eCmdCompAtm, eCmdSwAtm: begin
            exp_pkt.smi_mpf1_argv = m_ace_write_addr_pkt.awatop;                                              
        end
        eCmdRdNC, eCmdWrNCPtl, eCmdWrNCFull: begin
            if(isRead) begin
                exp_pkt.smi_mpf1_burst_type = m_ace_read_addr_pkt.arburst[1:0];
                exp_pkt.smi_mpf1_asize = m_ace_read_addr_pkt.arsize[2:0];
                exp_pkt.smi_mpf1_alength = m_ace_read_addr_pkt.arlen[2:0];
            end
            if(isWrite || isUpdate) begin
                //CONC-11704 overrides CONC-11224 and now all multiline transactions are INCRs 
                exp_pkt.smi_mpf1_burst_type = m_ace_write_addr_pkt.awburst[1:0];
                exp_pkt.smi_mpf1_asize = m_ace_write_addr_pkt.awsize[2:0];
                exp_pkt.smi_mpf1_alength = m_ace_write_addr_pkt.awlen[2:0];
            end
            if (isMultiAccess) begin
                exp_pkt.smi_mpf1_burst_type = AXIINCR;
            end
        end
        <% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
        eCmdWrUnqPtl, eCmdWrUnqFull: begin
            exp_pkt.smi_mpf1_awunique = m_ace_write_addr_pkt.awunique;
        end
        <% } %>
        default: begin
            exp_pkt.smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB] = m_pkt.smi_ndp[CMD_REQ_MPF1_MSB:CMD_REQ_MPF1_LSB];
        end
    endcase

    //#Check.IOAIU.SMI.CMDReq.MPF2
	if(isIoCacheEvict) begin: _iocache_evict_
    	exp_pkt.smi_mpf2_flowid_valid = 1'b1;
        exp_pkt.smi_mpf2_flowid = m_id;
	end: _iocache_evict_
	else begin: _not_iocache_evict_
		case(exp_pkt.smi_msg_type)
			eCmdWrStshPtl, eCmdWrStshFull, eCmdLdCchShd, eCmdLdCchUnq: begin
				exp_pkt.smi_mpf2_stash_valid = m_ace_write_addr_pkt.awstashlpiden;
				exp_pkt.smi_mpf2_stash_lpid = m_ace_write_addr_pkt.awstashlpid;
			end
			eCmdRdNC: begin
					exp_pkt.smi_mpf2_flowid_valid = 1'b1;
					exp_pkt.smi_mpf2_flowid = m_ace_read_addr_pkt.arid;
			end
			eCmdWrNCPtl, eCmdWrNCFull: begin
					exp_pkt.smi_mpf2_flowid_valid = 1'b1;
					exp_pkt.smi_mpf2_flowid = m_ace_write_addr_pkt.awid;
			end
			default: begin
				exp_pkt.smi_mpf2_flowid_valid = isRead ? (m_ace_read_addr_pkt.arlock == EXCLUSIVE) : (m_ace_write_addr_pkt.awlock == EXCLUSIVE);
                                <% if(obj.AiuInfo[obj.Id].nProcs ==1) {%> 
                                    exp_pkt.smi_mpf2_flowid = 0;
                                  <% } else {%>
                                    if (<%=AxIdProcSelectBits.length%> != $clog2(<%=obj.AiuInfo[obj.Id].nProcs%>))
                                      `uvm_error("<%=obj.strRtlNamePrefix%> SCB_TXN ERROR", $sformatf(" AxIdProcSelectBits.length and nProcs should be equa"))
			            if(isRead) begin
			              <% for(var i = 0; i < AxIdProcSelectBits.length; i++) { %>
			                exp_pkt.smi_mpf2_flowid[<%=i%>] = m_ace_read_addr_pkt.arid[<%=obj.AxIdProcSelectBits[i]%>];
			              <% } %>
			            end else begin
			              <% for(var i = 0; i < AxIdProcSelectBits.length; i++) { %>
			                exp_pkt.smi_mpf2_flowid[<%=i%>] = m_ace_write_addr_pkt.awid[<%=obj.AxIdProcSelectBits[i]%>];
			              <% } %>
			            end
			            <% } %>
			    end
		endcase
	end: _not_iocache_evict_
    //#Check.IOAIU.SMI.CMDReq.Aux
    if(isRead) begin
        //ArUser
        <%if(aiu_axiInt.params.wArUser > 0) { %>
        exp_pkt.smi_ndp_aux = m_ace_read_addr_pkt.aruser;
        <% } %>
    end
    if(isWrite || isUpdate) begin
        //AwUser
        <%if(aiu_axiInt.params.wAwUser > 0) { %>
        exp_pkt.smi_ndp_aux = m_ace_write_addr_pkt.awuser;
        <% } %>
    end
    //#Check.IOAIU.SMI.CMDReq.LK
    if(isRead) begin
        exp_pkt.smi_es = (m_ace_read_addr_pkt.arlock == EXCLUSIVE);
    end
    if(isWrite) begin
        exp_pkt.smi_es = (m_ace_write_addr_pkt.awlock == EXCLUSIVE);
    end
    if(isUpdate) begin
        /* if(m_ace_cmd_type == WREVCT) begin */
        /*     exp_pkt.smi_ca = 1; //CONC-6603 */
        /* end else begin */
        /*     exp_pkt.smi_ca = |m_ace_write_addr_pkt.awcache[3:2]; */
        /* end */
        exp_pkt.smi_ca = |m_ace_write_addr_pkt.awcache[3:2]; //CONC-7018
    end
    if((m_ace_cmd_type === ATMSTR) || (m_ace_cmd_type === ATMLD) || (m_ace_cmd_type === ATMSWAP) || (m_ace_cmd_type === ATMCOMPARE)) begin
        if(isCoherentAtomic) begin
            if(is2ndSMICMDReqSent) begin
                exp_pkt.smi_ch = 1'b0;
            end else begin
                exp_pkt.smi_ch = 1'b1;
            end
        end else begin
            exp_pkt.smi_ch = 1'b0;
        end     
        exp_pkt.smi_vz = 1'b0;
        exp_pkt.smi_ca = 1'b1;
        exp_pkt.smi_ac = 1'b1;
        exp_pkt.smi_st = 1'b0;
        exp_pkt.smi_es = 1'b0;
    end
    //#Check.IOAIU.SMI.CMDReq.ES
    case(exp_pkt.smi_msg_type)
        eCmdWrClnFull: begin
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
                    
        end
        eCmdWrBkFull: begin
                    exp_pkt.smi_vz = 1'b0;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
                   
        end
        eCmdWrEvict: begin
                    exp_pkt.smi_vz = 1'b0;
                    exp_pkt.smi_ac = 1'b1; //CONC-6603
                    exp_pkt.smi_ca = 1'b1; //CONC-6603
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
                   
        end
        eCmdEvict: begin
                    exp_pkt.smi_vz = 1'b0;
                    //CONC-6483 exp_pkt.smi_ac = 1'b0;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
                    
        end
        eCmdWrNCPtl,
        eCmdWrNCFull: begin
                    exp_pkt.smi_ch = 1'b0;
                    exp_pkt.smi_es = (m_ace_write_addr_pkt && m_ace_write_addr_pkt.awlock == EXCLUSIVE) ? 1'b1 : 1'b0;
                    exp_pkt.smi_vz = exp_pkt.smi_es ? 1 : exp_pkt.smi_vz;
                    exp_pkt.smi_ca = exp_pkt.smi_es ? 0 : exp_pkt.smi_ca;
                    exp_pkt.smi_ac = exp_pkt.smi_es ? 0 : exp_pkt.smi_ac;
        end
        eCmdRdNC: begin
                    exp_pkt.smi_ch = 1'b0;
                    exp_pkt.smi_es = (m_ace_read_addr_pkt.arlock == EXCLUSIVE) ? 1'b1 : 1'b0;
                    exp_pkt.smi_vz = exp_pkt.smi_es ? 1 : exp_pkt.smi_vz;
                    exp_pkt.smi_ca = exp_pkt.smi_es ? 0 : exp_pkt.smi_ca;
                    exp_pkt.smi_ac = exp_pkt.smi_es ? 0 : exp_pkt.smi_ac;
        end
        eCmdWrUnqPtl, eCmdWrUnqFull: begin
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_ch = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
		end
        eCmdRdNITC: begin
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_ch = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
        end
        eCmdRdVld,
        eCmdRdCln: begin
                    exp_pkt.smi_vz = 1'b0;
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                     
                    if(isRead) begin
                    exp_pkt.smi_es = (m_ace_read_addr_pkt.arlock == EXCLUSIVE) ? 1'b1 : 1'b0;
                    end
                    if(isWrite) begin
                    exp_pkt.smi_es = (m_ace_write_addr_pkt.awlock == EXCLUSIVE) ? 1'b1 : 1'b0;
end
        end
        eCmdRdNShD: begin
                    exp_pkt.smi_vz = 1'b0;
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    
        end
        eCmdRdUnq: begin
					if (isWrite) begin
						exp_pkt.smi_vz = m_ace_write_addr_pkt.awcache==0 || m_ace_write_addr_pkt.awcache==2;
					end else begin
                    	exp_pkt.smi_vz = 1'b0;
					end
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
		end
        eCmdMkUnq: begin
                    exp_pkt.smi_vz = 1'b0;
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
        end
        eCmdClnUnq: begin
                    exp_pkt.smi_vz = 1'b1; //JIRA: CONC-6451*/
                    //SAI : clean unique is a CMO and according to CONC-7391 smi_rl should be 2 when vz is '1'
                    //#Check.IOAIU.SMI.CMDReq.RL
                    //#Check.IOAIU.OWO.CMDreq.RL
                    exp_pkt.smi_rl = 2'b10;
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = isRead ? ((m_ace_read_addr_pkt.arlock == EXCLUSIVE) ? 1'b1 : 1'b0) : 1'b0;
        end
        eCmdClnVld,
        eCmdClnInv,
        eCmdMkInv: begin
                    exp_pkt.smi_vz = 1'b1;
                    //SAI make invalid is a CMO and according to CONC-7391 smi_rl should be 2 when vz is '1'
                    exp_pkt.smi_rl = 2'b10;
                    exp_pkt.smi_es = 1'b0;
                    
        end
        eCmdDvmMsg: begin
                    exp_pkt.smi_vz = 1'b0;
                    exp_pkt.smi_ac = 1'b0;
                    exp_pkt.smi_ca = 1'b0;
                    exp_pkt.smi_ch = 1'b0;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
                    
        end
        eCmdClnShdPer: begin
                    exp_pkt.smi_vz = 1'b1;
                    //SAI : clean shared persist is a CMO and according to CONC-7391 smi_rl should be 2 when vz is '1'
                    exp_pkt.smi_rl = 2'b10;
                    exp_pkt.smi_es = 1'b0;
                    
        end
        eCmdRdNITCClnInv: begin
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_ch = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
        end
        eCmdRdNITCMkInv: begin
                    exp_pkt.smi_ac = 1'b0;
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_ch = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
        end
        eCmdWrAtm,
        eCmdRdAtm,
        eCmdSwAtm,
        eCmdCompAtm: begin
                    if(isCoherentAtomic) begin
                        if(is2ndSMICMDReqSent) begin
                            exp_pkt.smi_ch = 1'b0;
                        end else begin
                            exp_pkt.smi_ch = 1'b1;
                        end
                    end else begin
                        exp_pkt.smi_ch = 1'b0;
                    end     
                    exp_pkt.smi_vz = 1'b0;
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_ac = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
        end
        eCmdWrStshPtl: begin
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_ch = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
		end
        eCmdWrStshFull: begin
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_ch = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
        end
        eCmdLdCchShd: begin
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_ch = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
		end
        eCmdLdCchUnq: begin
                    exp_pkt.smi_ca = 1'b1;
                    exp_pkt.smi_ch = 1'b1;
                    exp_pkt.smi_st = 1'b0;
                    exp_pkt.smi_es = 1'b0;
                   
        end
    endcase

   return exp_pkt;								   
endfunction : getExpCmdReq

function void ioaiu_scb_txn::check_smi_cmd_attr();
   axi_axlock_enum_t axlock;
   bit[3:0] temp_axcache;
   axi_axaddr_t  axaddr;
   bit [3:0] axcache;
   axlock  = isRead ? m_ace_read_addr_pkt.arlock  : (isWrite ? m_ace_write_addr_pkt.awlock : NORMAL);
   axcache = isRead ? m_ace_read_addr_pkt.arcache  : (isWrite ? m_ace_write_addr_pkt.awcache:4'b0000); 
   axaddr =  isRead ? m_ace_read_addr_pkt.araddr  : (isWrite ? m_ace_write_addr_pkt.awaddr:0);
   if(axaddr>0)begin
   if(mismatch_mem_attr.exists(axaddr[WAXADDR-1:SYS_wSysCacheline]))begin
     temp_axcache = mismatch_mem_attr[axaddr[WAXADDR-1:SYS_wSysCacheline]]; 
     if((temp_axcache[3:2] == 2'b00 && axcache[3:2] != 2'b00) || (temp_axcache[3:2] != 2'b00 && axcache[3:2] == 2'b00))begin
       mismatch_mem_attr_flag = 1'b1; 
     end
   end
   mismatch_mem_attr[axaddr[WAXADDR-1:SYS_wSysCacheline]] = axcache;
   end
    if(is2ndSMICMDReqSent) begin: _2nd_cmdreq_
        exp_2nd_cmd_req_pkt = getExpCmdReq(m_2nd_cmd_req_pkt);

        //smi_ch is a deprecated field in ncore
        exp_2nd_cmd_req_pkt.smi_ch = m_2nd_cmd_req_pkt.smi_ch;
       
        //OR is dont care for transactions going to DCE/DMI/DVE - Refer to PCIe Ordering Spec Rev4.20 page 15: Transaction Issue
        if (addrMgrConst::get_unit_type(m_2nd_cmd_req_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]) != addrMgrConst::DII)
            exp_2nd_cmd_req_pkt.smi_order = m_2nd_cmd_req_pkt.smi_order;

        //uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("2nd Exp CMDReq:%s",exp_2nd_cmd_req_pkt.convert2string()), UVM_MEDIUM);
        //uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("2nd Act CMDReq:%s",m_2nd_cmd_req_pkt.convert2string()), UVM_MEDIUM);
        if(!isStash && !axlock) begin
        exp_2nd_cmd_req_pkt.smi_mpf2_flowid_valid = m_2nd_cmd_req_pkt.smi_mpf2_flowid_valid;
        exp_2nd_cmd_req_pkt.smi_mpf2_flowid = m_2nd_cmd_req_pkt.smi_mpf2_flowid;
        end
        
        // CONC-8404, CONC-11461
        if ((!exp_2nd_cmd_req_pkt.compare(m_2nd_cmd_req_pkt)) &&
            (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2)))) begin
            if(!(exp_2nd_cmd_req_pkt.s == "CMDreq.VZ field mismatched" && mismatch_mem_attr_flag == 1'b1)) //remove after smi.VZ fix
           `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("2nd CMDReq:%0s!",exp_2nd_cmd_req_pkt.s));
        end
        
   end: _2nd_cmdreq_
   else begin: _1st_cmdreq_
        exp_cmd_req_pkt = getExpCmdReq(m_cmd_req_pkt);								  
        exp_cmd_req_pkt.smi_ch = m_cmd_req_pkt.smi_ch;
        
        //OR is dont care for transactions going to DCE/DMI/DVE - Refer to PCIe Ordering Spec Rev4.20 page 15: Transaction Issue
        if (addrMgrConst::get_unit_type(m_cmd_req_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]) != addrMgrConst::DII)
        	exp_cmd_req_pkt.smi_order = m_cmd_req_pkt.smi_order;

           //uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Exp CMDReq:%s",exp_cmd_req_pkt.convert2string()), UVM_MEDIUM);
         if(!isStash && !axlock) begin
           exp_cmd_req_pkt.smi_mpf2_flowid_valid =m_cmd_req_pkt.smi_mpf2_flowid_valid;
         end
        // CONC-8404, CONC-11461
        if ((!exp_cmd_req_pkt.compare(m_cmd_req_pkt)) &&
            (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2)))) begin
            if(!(exp_cmd_req_pkt.s == "CMDreq.VZ field mismatched" && mismatch_mem_attr_flag == 1'b1)) //remove after smi.VZ fix
	          `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> CMDreq:%0s", tb_txnid,<%if(obj.nNativeInterfacePorts > 1){ %> core_id,<%}%>exp_cmd_req_pkt.s));
        end
   
    end: _1st_cmdreq_

endfunction : check_smi_cmd_attr
function void ioaiu_scb_txn::getExpCmdRsp();
      
   if(!is2ndSMICMDReqSent) begin 
        exp_cmd_rsp_pkt = smi_seq_item::type_id::create("exp_cmd_rsp_pkt");
       
        //why are there 2 different constructs for C and NC?
        exp_cmd_rsp_pkt.construct_ccmdrsp(
                                        .smi_targ_ncore_unit_id (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_src_ncore_unit_id  (m_cmd_req_pkt.smi_targ_ncore_unit_id),
                                        .smi_msg_type           ((addrMgrConst::get_unit_type(m_cmd_req_pkt.smi_targ_ncore_unit_id)==addrMgrConst::DCE) ? eCCmdRsp : eNCCmdRsp),
                                        .smi_msg_id             (core_id << (WSMIMSGID- $clog2(<%=obj.nNativeInterfacePorts%>))),
                                        .smi_msg_tier           ('h0),
                                        .smi_steer              ('h0),
                                        .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%> ? m_cmd_req_pkt.smi_msg_pri : 'h0),
                                        .smi_msg_qos            ('0),
                                        .smi_tm                 (m_cmd_req_pkt.smi_tm),
                                        .smi_rmsg_id            (m_cmd_req_pkt.smi_msg_id),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0)
                                        );
   end else begin
        exp_2nd_cmd_rsp_pkt = smi_seq_item::type_id::create("exp_2nd_cmd_rsp_pkt");
       
        //why are there 2 different constructs for C and NC?
        exp_2nd_cmd_rsp_pkt.construct_ccmdrsp(
                                        .smi_targ_ncore_unit_id (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_src_ncore_unit_id  (m_2nd_cmd_req_pkt.smi_targ_ncore_unit_id),
                                        .smi_msg_type           ((addrMgrConst::get_unit_type(m_2nd_cmd_req_pkt.smi_targ_ncore_unit_id)==addrMgrConst::DCE) ? eCCmdRsp : eNCCmdRsp),
                                        .smi_msg_id             (core_id << (WSMIMSGID- $clog2(<%=obj.nNativeInterfacePorts%>))),
                                        .smi_msg_tier           ('h0),
                                        .smi_steer              ('h0),
                                        .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%> ? m_2nd_cmd_req_pkt.smi_msg_pri : 'h0),
                                        .smi_msg_qos            ('0),
                                        .smi_tm                 (m_2nd_cmd_req_pkt.smi_tm),
                                        .smi_rmsg_id            (m_2nd_cmd_req_pkt.smi_msg_id),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0)
                                        );
   end
endfunction : getExpCmdRsp

function void ioaiu_scb_txn::getExpDtrRsp();
   exp_dtr_rsp_pkt = smi_seq_item::type_id::create("exp_dtr_rsp_pkt");
   //#Check.IOAIU.SMI.DtrRsp.CMStatus
   //#Check.IOAIU.SMI.DtrRsp.CMType
   //#Check.IOAIU.SMI.DtrRsp.priority
   //#Check.IOAIU.SMI.DtrRsp.RMsgID
   //#Check.IOAIU.SMI.DtrRsp.TargetID
   //#Check.IOAIU.SMI.DtrRsp.priority
   //#Check.IOAIU.SMI.DtrRsp.InitiatorID
   exp_dtr_rsp_pkt.construct_dtrrsp(
                                   .smi_targ_ncore_unit_id (m_dtr_req_pkt.smi_src_ncore_unit_id),
                                   .smi_src_ncore_unit_id  (m_dtr_req_pkt.smi_targ_ncore_unit_id),
                                   .smi_msg_type           (eDtrRsp),
                                   .smi_msg_id             (core_id << (WSMIMSGID- $clog2(<%=obj.nNativeInterfacePorts%>))),
                                   .smi_msg_tier           ('h0),
                                   .smi_steer              ('h0),
                                   .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%>? m_dtr_req_pkt.smi_msg_pri : 'h0),
                                   .smi_msg_qos            ('0),
                                   .smi_tm                 (m_dtr_req_pkt.smi_tm),
                                   .smi_rmsg_id            (m_dtr_req_pkt.smi_msg_id),
                                   .smi_msg_err            ('h0),
                                   .smi_cmstatus           ('h0)
                                   );
endfunction : getExpDtrRsp

function bit ioaiu_scb_txn::matchSnpDtrReq(smi_seq_item m_pkt);
   //#Check.IOAIU.SMI.SNPDTRReq.Id
   //#Check.IOAIU.SMI.DTRReq.StashMPF2ID
    //#Check.IOAIU.SMI.DtrReq.MPF1
   return (isSnoop && 
	   (m_snp_req_pkt.smi_mpf1_dtr_tgt_id   == (m_pkt.smi_targ_id >> <%=obj.wFPortId%>)) &&
	   (m_snp_req_pkt.smi_mpf2_dtr_msg_id   == m_pkt.smi_rmsg_id) &&
           !isSMISNPDTRReqSent                                        &&
           isSMISNPDTRReqNeeded) ||
	  (isWrite && (m_ace_cmd_type == WRUNQFULLSTASH ) && isSMISTRReqRecd && !isSMISNPDTRReqSent &&
	   (m_str_req_pkt.smi_mpf1_stash_nid   == (m_pkt.smi_targ_id >> <%=obj.wFPortId%>)) &&
	   (m_str_req_pkt.smi_mpf2   == m_pkt.smi_rmsg_id) &&
	   m_str_req_pkt.smi_cmstatus_snarf && m_ace_write_addr_pkt.awstashniden);
endfunction : matchSnpDtrReq
      
function bit ioaiu_scb_txn::matchSnpToDtwTargId(smi_seq_item m_pkt);
   return (m_pkt.isDtwMsg()) ? 
     (m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == m_snp_req_pkt.smi_dest_id) 
     : 0;
endfunction : matchSnpToDtwTargId

function bit ioaiu_scb_txn::matchSysReq(smi_seq_item m_pkt);
endfunction : matchSysReq
function bit ioaiu_scb_txn::matchDtrToTxn(smi_seq_item m_pkt);
   bit match;	

   match = !isSMISTRRespSent && 
           (isRead || isAtomic
             <%if(obj.useCache) { %> 
             || ((csr_ccp_lookupen)? //ccp_enable
                 (isWrite && isIoCacheTagPipelineSeen && (m_iocache_allocate || isWriteHit()))
                 :0) //ccp_disable
    		 <% } %>)
			&& isSMICMDReqSent 
			&& !isSMIAllDTRReqRecd 
			&& isSMIDTRReqNeeded 
			&& (m_cmd_req_pkt.smi_unq_identifier === m_pkt.smi_rsp_unq_identifier) 
			&& !isDVMSync
            && ((isSMICMDRespRecd && !isSMICMDRespErr) || !isSMICMDRespRecd);

    return match;
endfunction : matchDtrToTxn

function int ioaiu_scb_txn::mapAddrToDestId(smi_seq_item m_pkt);
   //#Check.IOAIU.SMI.CMDReq.DId
   int fnmem_region_idx;
   if(m_pkt.smi_msg_type == eCmdDvmMsg)
     return m_pkt.smi_dest_id;
   else
     return addrMgrConst::map_addr2dmi_or_dii(m_pkt.smi_addr,fnmem_region_idx);
//   return (addrMgrConst::map_addr2dmi_or_dii(m_pkt.smi_addr,fnmem_region_idx) << WSMINCOREPORTID) | m_pkt.smi_dest_id[WSMINCOREPORTID-1:0];
endfunction : mapAddrToDestId

//#Check.IOAIU.SMI.CMDReq.DCETargID
//#Check.IOAIU.SMI.CMDReq.TargID
//#Cov.IOAIU.SMI.CMDReq.TargIDWrNoSnoop
//#Check.IOAIU.SMI.CMDReq.WritebackTargID
function int ioaiu_scb_txn::mapAddrToTarg(smi_seq_item m_pkt);
   int val;

   if((m_pkt.smi_msg_type == eCmdWrNCFull) ||
      (m_pkt.smi_msg_type == eCmdWrNCPtl) ||
      (m_pkt.smi_msg_type == eCmdWrBkFull) ||
      (m_pkt.smi_msg_type == eCmdWrClnFull) ||
      (m_pkt.smi_msg_type == eCmdWrEvict) ||
<% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
      (m_pkt.smi_msg_type == eCmdEvict) ||
<% } %>
      (((m_pkt.smi_msg_type == eCmdClnVld) ||
        (m_pkt.smi_msg_type == eCmdClnInv) ||
        (m_pkt.smi_msg_type == eCmdClnShdPer) ||
        (m_pkt.smi_msg_type == eCmdMkInv)) &&
        (m_ace_read_addr_pkt.ardomain == '0))||
        (m_pkt.smi_msg_type == eCmdRdNC)) begin
      //#Check.IOAIU.SMI.CMDReq.TargIDWrNoSnoop
      //#Check.IOAIU.SMI.CMDReq.TargIDAtm
      //#Check.IOAIU.SMI.CMDReq.TargID
      val = ((mapAddrToDestId(m_pkt) << WSMINCOREPORTID) | m_pkt.smi_targ_id[WSMINCOREPORTID-1:0]);
   end // if ((m_pkt.smi_msg_type == eCmdWrNCFull) ||...
   else if(m_pkt.smi_msg_type == eCmdDvmMsg) begin
//      val = ((addrMgrConst::get_dve_funitid(0)  << WSMINCOREPORTID) | m_pkt.smi_targ_id[WSMINCOREPORTID-1:0]);
      val = (DVE_FUNIT_IDS[0]  << WSMINCOREPORTID) | m_pkt.smi_targ_id[WSMINCOREPORTID-1:0];
   end else begin
      //#Check.IOAIU.SMI.CMDReq.DCETargID
      val = ((addrMgrConst::map_addr2dce(m_pkt.smi_addr)  << WSMINCOREPORTID) | m_pkt.smi_targ_id[WSMINCOREPORTID-1:0]);
   end

   //targID prediction for Atomic Txns
   if(m_pkt.smi_msg_type inside { eCmdCompAtm,eCmdSwAtm, eCmdRdAtm, eCmdWrAtm})
    begin
       if(isCoherentAtomic==0) begin
          val = ((mapAddrToDestId(m_pkt) << WSMINCOREPORTID) | m_pkt.smi_targ_id[WSMINCOREPORTID-1:0]);
       end else if(isCoherentAtomic==1) begin
          if (!is2ndSMICMDReqSent ) begin //1st cmd sent
             val = ((addrMgrConst::map_addr2dce(m_pkt.smi_addr)  << WSMINCOREPORTID) | m_pkt.smi_targ_id[WSMINCOREPORTID-1:0]);
          end else begin 
             val = ((mapAddrToDestId(m_pkt) << WSMINCOREPORTID) | m_pkt.smi_targ_id[WSMINCOREPORTID-1:0]);
          end   
       end
    end    

   if(val != m_pkt.smi_targ_id) begin
	uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("TargID in CmdReq is Wrong. Expect TargId is 0x%0h, Real TargId is 0x%0h. %s",val, m_pkt.smi_targ_id, m_pkt.convert2string()),UVM_NONE);
    end
   return val;
endfunction : mapAddrToTarg

function smi_dp_data_bit_t ioaiu_scb_txn::getExpDVMDtwData();

    smi_dp_data_bit_t exp_dw = '0;

    //NCore 3.6 Mapping updates
    //#Check.IOAIU.DVMMaster.DTWReqMapping
    if(isDVMMultiPart) begin
        exp_dw[2:0]       =                                      m_ace_read_addr_pkt2.araddr[2:0];                                   //NUM[2:0] only for DVMv8.4 i.e. ACE-LiteE with DVM Enabled
        exp_dw[3]         =                                      m_ace_read_addr_pkt2.araddr[4];                                     //NUM[3]/PA[4]/VA[4]
        exp_dw[5:4]       =                                      m_ace_read_addr_pkt2.araddr[7:6];                                   //Scale[1:0]/VA[7:6]/PA[7:6]
        exp_dw[7:6]       =                                      m_ace_read_addr_pkt2.araddr[9:8];                                   //TTL[1:0]/VA[9:8]/PA[9:8]
        exp_dw[9:8]       =                                      m_ace_read_addr_pkt2.araddr[11:10];                                 //TG[1:0]/VA[11:10]/PA[11:10]
        exp_dw[37:10]     =                                      m_ace_read_addr_pkt2.araddr[39:12];                                 //VA[39:12]/PA[39:12]
        if (m_ace_read_addr_pkt.araddr[14:12] == 3'b010) begin //DVM MSG Type PICI (Physical Instruction Cache Invalidate)
            exp_dw[38]    =                                      m_ace_read_addr_pkt2.araddr[40];                                    //PA[40]
            exp_dw[41:39] = <%if(aiu_axiInt.params.wAddr>40) {%> m_ace_read_addr_pkt2.araddr[43:41]         <%} else {%> 3'b0<%}%>;  //PA[43:41]
            exp_dw[42]    = <%if(aiu_axiInt.params.wAddr>44) {%> m_ace_read_addr_pkt2.araddr[44]            <%} else {%> 1'b0<%}%>;  //PA[44]
            exp_dw[46:43] = <%if(aiu_axiInt.params.wAddr>44) {%> {1'b0, m_ace_read_addr_pkt2.araddr[47:45]} <%} else {%> 4'b0<%}%>;  //PA[48:45]
        end else begin
            exp_dw[38] =                                         m_ace_read_addr_pkt2.araddr[3];                                     //VA[40]
            exp_dw[42:39] = <%if(aiu_axiInt.params.wAddr>40) {%> m_ace_read_addr_pkt2.araddr[43:40] <%} else {%> 4'b0<%}%>;          //VA[44:41]
            exp_dw[46:43] = <%if(aiu_axiInt.params.wAddr>40) {%> m_ace_read_addr_pkt.araddr[43:40]  <%} else {%> 4'b0<%}%>;          //VA[48:45]
        end
        exp_dw[50:47]     = <%if(aiu_axiInt.params.wAddr>44) {%> m_ace_read_addr_pkt2.araddr[47:44] <%} else {%> 4'b0<%}%>;          //VA[52:49]
        exp_dw[54:51]     = <%if(aiu_axiInt.params.wAddr>44) {%> m_ace_read_addr_pkt.araddr[47:44]  <%} else {%> 4'b0<%}%>;          //VA[56:53]
        exp_dw[55]        = m_ace_read_addr_pkt2.araddr[5];                                                                          //NUM[4]/PA[5]/VA[5]
        exp_dw[59:56]     = m_ace_read_addr_pkt.arvmid[3:0];                                                                         //VMID[11:8]
        exp_dw[63:60]     = m_ace_read_addr_pkt2.arvmid[3:0];                                                                        //VMID[15:12] for two-part DVM
    end else begin                                                                                                                   //From CCMP Spec 7.3.2 "single part DVM message the DTWreq is sent with zero as data payload"
        exp_dw[63:60] = <%if(aiu_axiInt.params.wAddr>40) {%> m_ace_read_addr_pkt.araddr[43:40] <%} else {%> 4'b0<%}%>;               //VMID[15:12] for one-part DVM
    end
    return exp_dw;
endfunction : getExpDVMDtwData

function smi_addr_t ioaiu_scb_txn::getExpDVMCmdReqAddr();
    smi_addr_t exp_addr = '0;
    //#Check.IOAIU.DVMMaster.CMDReqMapping
    exp_addr[4]     = m_ace_read_addr_pkt.araddr[0];        //Va Valid
    exp_addr[5]     = m_ace_read_addr_pkt.araddr[6];        //VMID Valid
    exp_addr[6]     = m_ace_read_addr_pkt.araddr[5];        //ASID Valid
    exp_addr[8:7]   = m_ace_read_addr_pkt.araddr[9:8];      //Security
    exp_addr[10:9]  = m_ace_read_addr_pkt.araddr[11:10];    //Exception Level
    exp_addr[13:11] = m_ace_read_addr_pkt.araddr[14:12];    //DVMOp Type
    exp_addr[21:14] = m_ace_read_addr_pkt.araddr[31:24];    //VMID[7:0] or Virtual Index[27:20]
    exp_addr[37:22] = <%if(aiu_axiInt.params.wAddr>=40) {%> {m_ace_read_addr_pkt.araddr[39:32],m_ace_read_addr_pkt.araddr[23:16]} <%} else {%> {8'h0,m_ace_read_addr_pkt.araddr[23:16]}<%}%>; //ASID or Virtual Index[19:12]
    exp_addr[39:38] = m_ace_read_addr_pkt.araddr[3:2];      //Staged Invalidation
    exp_addr[40]    = m_ace_read_addr_pkt.araddr[4];        //Leaf Entry Invalidation
    exp_addr[41]    = m_ace_read_addr_pkt.araddr[7];        //Range Ncore3.6 New DVM v8.4 Mapping update
    return exp_addr;
endfunction : getExpDVMCmdReqAddr

function smi_order_t ioaiu_scb_txn::getExpCmdOR();

    smi_order_t exp_smi_order;

//#Check.IOAIU.OWO.CMDreq.OR
    if (owo && isWrite) begin 
        exp_smi_order = (m_axcache[1] == 1) ? 2'b01 : 2'b11;
    end
//#Check.IOAIU.CMDReq.OR_pcieOrderMode
    else if(pcieOrderMode_en) begin
        casex({isRead,m_axcache,gpra_order})
            9'b?_000?_????: exp_smi_order = 2'b11;//Endpoint/Request Order for Device Reads and Writes

            9'b1_??1?_10?0: exp_smi_order = 2'b10;//Relaxed Order, ArID order
            9'b1_??1?_01??: exp_smi_order = 2'b01;//CONC-9674 policy=01 write ordered
            9'b1_??1?_00??: exp_smi_order = 2'b11;//Policy=00(Reserved) should behave as 11(Endpoint/Request order)
            9'b1_??1?_11??: exp_smi_order = 2'b11;//Endpoint/Request Order
            9'b1_??1?_10?1: exp_smi_order = 2'b00;//ReadID=1, Relaxed Order, No ArID dependency

            9'b0_??1?_100?: exp_smi_order = 2'b10;//Relaxed Order, AwID order
            9'b0_??1?_01??: exp_smi_order = 2'b01;//CONC-9674 policy=01 write ordered
            9'b0_??1?_00??: exp_smi_order = 2'b11;//policy=00 should behave as 11
            9'b0_??1?_11??: exp_smi_order = 2'b11;//Endpoint/Request Order
            9'b0_??1?_101?: exp_smi_order = 2'b00;//WriteID=1, Relaxed Order, No AwID dependency
            default: exp_smi_order = 2'b00;
        endcase
    end
    else begin //strictReqMode

    	//#Check.IOAIU.CMDReq.OR_strictReqMode
        if(isRead) begin
            exp_smi_order = (m_ace_cmd_type inside {CLNSHRD, CLNINVL, MKINVL, CLNSHRDPERSIST}) ? 'b00 : (m_ace_read_addr_pkt.arcache[1] ? 2'b10 : 2'b11);
        end else if(isWrite) begin
            exp_smi_order = m_ace_write_addr_pkt.awcache[1] ? 2'b10 : 2'b11;
        end else begin
            exp_smi_order  = 2'b00;
    
    end
end //strictReqMode
    return exp_smi_order;
endfunction : getExpCmdOR

function smi_tm_t ioaiu_scb_txn::getExpTM(bit is_dvm=0);
    smi_tm_t exp_tm;
    bit hut;
    bit[4:0] hui;
    bit dmi_hit;
    bit dii_hit;
    bit native_trace_signal;
    bit [14:0] opcode;
    axi_axcache_t mem_attr;
    bit[31:0] native_user_bits;

    if(isSnoop) begin
        exp_tm = m_snp_req_pkt.smi_tm;
    end else begin : not_Snoop
        assert(!tctrlr[0].memattr_match_en || ( tctrlr[0].ar || tctrlr[0].aw));
        mem_attr = m_axcache;
        native_user_bits = m_user;//BING FIXME: need to handle the case if no user bits in master intf
        if (ioaiu_cctrlr_phase==2) begin
            native_trace_signal =0;
        end else begin
            if(isACEReadAddressRecd) begin
                <%if(aiu_axiInt.params.eTrace > 0) { %>
                native_trace_signal =  m_ace_read_addr_pkt.artrace;
                <% } %>
            end else begin
                <%if(aiu_axiInt.params.eTrace > 0) { %>
                native_trace_signal = m_ace_write_addr_pkt.awtrace;
                <% } %>
            end
        end
        
		//for AXI w/ or w/o proxyCache, 
        if (!isIoCacheEvict) begin
            <% if(obj.useCache) {%>
                opcode = m_ace_cmd_type_io_cache;
            <% } else { %>
                if (m_ace_read_addr_pkt != null)
        	        opcode = {m_ace_read_addr_pkt.ardomain, m_ace_read_addr_pkt.arsnoop};
                else if (m_ace_write_addr_pkt != null)
        	        opcode = {m_ace_write_addr_pkt.awatop, m_ace_write_addr_pkt.awdomain, m_ace_write_addr_pkt.awsnoop};
                else  
			        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("ERROR! fn:getExpTM Both m_ace_read_addr_pkt and m_ace_write_addr_pkt are null"))
		    <% } %>	
        end else begin
            opcode = opcode_for_evict;
        end
        

        if(m_addr_mgr.get_memregion_info(m_sfi_addr, hut, hui)) begin
            dmi_hit = ~hut;
            dii_hit = hut;
        end
    <%if(obj.testBench == "fsys") { %>
        if (!uvm_config_db#(trace_trigger_utils)::get(null, $sformatf("uvm_test_top.m_concerto_env.<%=obj.strRtlNamePrefix%>_env.m_env[%0d]",this.core_id), "m_trace_trigger", m_trace_trigger)) begin
            //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Not Getting m_concerto_env.<%=obj.strRtlNamePrefix%>_env.m_env[%0d].m_trace_trigger", this.core_id),UVM_LOW)
    <%} else {%> 
        if (!uvm_config_db#(trace_trigger_utils)::get(null, $sformatf("mp_env.m_env[%0d]",this.core_id), "m_trace_trigger", m_trace_trigger)) begin
    <%}%>   
         exp_tm = 0;  // could not find trace_trigger_utils in uvm_config_db, so cannot predit exp_tm

          <%if(obj.fnNativeInterface === "ACELITE-E" && aiu_axiInt.params.eTrace > 0){%>
          if(native_trace_signal)
          exp_tm = 1;
          <%}%>
         
        end else begin
            //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Getting m_concerto_env.<%=obj.strRtlNamePrefix%>_env.m_env[%0d].m_trace_trigger", this.core_id),UVM_LOW)
          exp_tm = m_trace_trigger.gen_expected_traceme(native_trace_signal,
                                                      m_sfi_addr, //addr
                                                      isACEReadAddressRecd, //ar
                                                      isACEWriteAddressRecd, //aw
                                                      dii_hit, //dii_hit
                                                      dmi_hit, //dmi_hit
                                                      hui, //hui
                                                      mem_attr,
                                                      opcode,
                                                      native_user_bits,
                                                      1'b0, // is_chi is false for ioaiu
                                                      is_dvm
                                                    );
        end
    end : not_Snoop

    return exp_tm;
endfunction : getExpTM

function bit ioaiu_scb_txn::matchCmdToTxn(smi_seq_item m_pkt);
    //#Check.IOAIU.SMI.CMDReq.MatchTXN
    eMsgCMD cmd_type;
    bit basic_match =    ((isWrite || isUpdate) ? isACEWriteDataRecd : 1)
                     && !(addrInCSRRegion && isSelfIDRegAccess)
                     && matchAux(m_pkt)
                     && matchNS(m_pkt)
                     && matchAddr(m_pkt);

    bit basic_match_rd =    isRead && !isACEReadDataSent 
                     && isSMICMDReqNeeded && !isSMICMDReqSent 
                     && !(addrInCSRRegion && isSelfIDRegAccess)
                     && matchAux(m_pkt)
                     && matchNS(m_pkt)
                     && matchAddr(m_pkt);


    $cast(cmd_type, m_pkt.smi_msg_type);
    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG",$sformatf("UID:%0d basic_match:%0b basic_match_rd:%0d cmd_type:%0p", tb_txnid, basic_match,basic_match_rd, cmd_type), UVM_LOW);

    case(cmd_type)
  <%if(obj.fnNativeInterface == "AXI5" || obj.fnNativeInterface == "ACELITE-E"){%>
    eCmdWrAtm,eCmdRdAtm,eCmdSwAtm,eCmdCompAtm : begin
       if(isCoherentAtomic) 
	return ( ((is2ndSMICMDReqNeeded && !is2ndSMICMDReqSent && isSMICMDReqSent)||
                (isSMICMDReqNeeded && !isSMICMDReqSent)) &&
		((isACEWriteAddressRecd && matchNS(m_pkt) && !addrNotInMemRegion &&
		m_ace_write_addr_pkt.awaddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]) ));
       else
	return (isSMICMDReqNeeded && !isSMICMDReqSent &&
		((isACEWriteAddressRecd && matchNS(m_pkt) && !addrNotInMemRegion &&
		m_ace_write_addr_pkt.awaddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]) ));
    end
   <%}%>
    eCmdClnUnq: begin
                    return (isCoherent &&
                            basic_match &&
                            ((isRead && (m_ace_cmd_type == CLNUNQ) && isSMICMDReqNeeded && !isSMICMDReqSent) ||
                             (isWrite && owo && (m_owo_wr_state == INV) && isSMICMDReqNeeded && !isSMICMDReqSent)
                            ));
                end

    eCmdWrNCPtl: begin
                    bit dbg = (   isPartialWrite && basic_match &&
                               ((!isCoherent && isSMICMDReqNeeded && !isSMICMDReqSent) ||
                                ( isCoherent && ((owo && (m_owo_wr_state == UDP) && isSMICMDReqSent && is2ndSMICMDReqNeeded && !is2ndSMICMDReqSent) || 
                                                 (!owo && (m_ace_cmd_type inside {WRBK, WRCLN}) && isSMICMDReqNeeded && !isSMICMDReqSent)))));

//                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG",$sformatf("UID:%0d dbg:%0b", tb_txnid, dbg), UVM_LOW);
                    return (   isPartialWrite && basic_match &&
                               ((!isCoherent && isSMICMDReqNeeded && !isSMICMDReqSent) ||
                                ( isCoherent && ((owo && (m_owo_wr_state == UDP) && isSMICMDReqSent && is2ndSMICMDReqNeeded && !is2ndSMICMDReqSent) || 
                                                 (!owo && (m_ace_cmd_type inside {WRBK, WRCLN}) && isSMICMDReqNeeded && !isSMICMDReqSent)))));
                 end

   eCmdWrNCFull : begin
                     bit dbg = (  (isWrite || isUpdate <%if(obj.useCache) {%> || isIoCacheEvict <%}%>) && !isPartialWrite && basic_match &&
                              ((!isCoherent && isSMICMDReqNeeded && !isSMICMDReqSent) ||
                               (isCoherent && ((owo && (m_owo_wr_state == UDP) && isSMICMDReqSent && is2ndSMICMDReqNeeded && !is2ndSMICMDReqSent) ||
                                               (!owo && (<%if(obj.useCache){%>isIoCacheEvict ||<%}%> (m_ace_cmd_type inside {WRBK, WRCLN, WREVCT})) && isSMICMDReqNeeded && !isSMICMDReqSent)))));

                    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG",$sformatf("UID:%0d dbg:%0b", tb_txnid, dbg), UVM_LOW);
                    return (  (isWrite || isUpdate <%if(obj.useCache) {%> || isIoCacheEvict <%}%>) && !isPartialWrite && basic_match &&
                              ((!isCoherent && isSMICMDReqNeeded && !isSMICMDReqSent) ||
                               (isCoherent && ((owo && (m_owo_wr_state == UDP) && isSMICMDReqSent && is2ndSMICMDReqNeeded && !is2ndSMICMDReqSent) ||
                                               (!owo && (<%if(obj.useCache){%>isIoCacheEvict ||<%}%> (m_ace_cmd_type inside {WRBK, WRCLN, WREVCT})) && isSMICMDReqNeeded && !isSMICMDReqSent)))));
                  end

   eCmdRdNC : begin
                return (!isCoherent 
                        && basic_match_rd
                        <%if(obj.useCache) { %> 
                        && (csr_ccp_lookupen ? (isIoCacheTagPipelineSeen && (m_ccp_ctrl_pkt.currstate == IX)) : 1)
                        <%} else {%>
                        <%}%>
                        );
              end
   
    eCmdRdUnq: begin
                return (isCoherent 
                    && basic_match 
                    && isSMICMDReqNeeded && !isSMICMDReqSent 
                    <%if(obj.useCache) { %> 
                    && isPartialWrite
                    && (csr_ccp_lookupen ? (isIoCacheTagPipelineSeen && ((m_ccp_ctrl_pkt.alloc && (m_ccp_ctrl_pkt.currstate == IX)) || (m_ccp_ctrl_pkt.currstate inside {SC, SD}))) : 0)
                    <%} else {%>
                    <%}%>
                );
        end
 
    eCmdMkUnq : begin
                return (isCoherent 
                    && basic_match 
                    && isSMICMDReqNeeded && !isSMICMDReqSent
                    <%if(obj.useCache) { %> 
                    && isWrite 
                    && !isPartialWrite
                    && (csr_ccp_lookupen ? (isIoCacheTagPipelineSeen && ((m_ccp_ctrl_pkt.alloc && (m_ccp_ctrl_pkt.currstate == IX)) || (m_ccp_ctrl_pkt.currstate inside {SC, SD}))) : 0)
                    <%} else {%>
                    &&   isRead
                    <%}%>
                        );
                end


<%if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  {%> 
   eCmdRdNITC : begin
   return (isCoherent && isRead &&  isACEReadAddressRecd && !isACEReadDataSent && matchNS(m_pkt)  &&
	     (m_ace_read_addr_pkt.araddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]) && !isAddrBlocked && !isSMICMDReqSent && !(addrInCSRRegion && isSelfIDRegAccess) && isSMICMDReqNeeded);
   end
   eCmdWrUnqPtl: begin
   return (!owo && isSMICMDReqNeeded && !isSMICMDReqSent &&
		(((isWrite && isACEWriteDataRecd && 
		   //#Check.IOAIU.SMI.CMDReq.HProt
		   isACEWriteAddressRecd && matchAux(m_pkt) && matchNS(m_pkt) && !(addrInCSRRegion && isSelfIDRegAccess) &&
		m_ace_write_addr_pkt.awaddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  === m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]) 
		 <%if(obj.useCache) { %> && ((csr_ccp_lookupen)? ( //ccp_enable
             ((isIoCacheTagPipelineSeen && !m_iocache_allocate && !isAddrBlocked && !is_ccp_hit) )
             ):1) //ccp_disable
           <% }%>)
		 || (isIoCacheEvict && matchNS(m_pkt) &&
		(m_sfi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  === m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]))));
   end 
   eCmdWrUnqFull : begin
   return (!owo && ((isCoherent && isWrite && isACEWriteAddressRecd && isACEWriteDataRecd  && 
	      !isACEWriteRespSent && matchNS(m_pkt) &&
	      (m_ace_write_addr_pkt.awaddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]) 
	      && !isAddrBlocked && !isSMICMDReqSent && !(addrInCSRRegion && isSelfIDRegAccess) && isSMICMDReqNeeded ) || (isSMICMDReqNeeded && !isSMICMDReqSent && isIoCacheEvict && matchNS(m_pkt) && (m_sfi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  === m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]))));
      
   end 
  // eCmdRdNC : begin
  // return (!isCoherent && isRead &&  isACEReadAddressRecd && !isACEReadDataSent && matchNS(m_pkt)  &&
  //           (m_ace_read_addr_pkt.araddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]) && !isAddrBlocked && !isSMICMDReqSent && !(addrInCSRRegion && isSelfIDRegAccess) && isSMICMDReqNeeded);
  // end
   eCmdRdNITC,eCmdRdNITCMkInv,eCmdRdNITCClnInv,eCmdRdVld,eCmdRdCln,eCmdMkInv,eCmdClnInv,eCmdClnVld,eCmdRdNShD,eCmdClnShdPer : begin
      return (isRead && isACEReadAddressRecd && matchNS(m_pkt) && 
	     (m_ace_read_addr_pkt.araddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)])							              // CONC-8377 && !isAddrBlocked && !isSMICMDReqSent && !addrNotInMemRegion && isSMICMDReqNeeded);
	      && !isAddrBlocked && !isSMICMDReqSent && !(addrInCSRRegion && isSelfIDRegAccess) && isSMICMDReqNeeded);
   end
  //  eCmdWrNCPtl: begin
  // return ((!isCoherent && isWrite && isACEWriteAddressRecd && isACEWriteDataRecd  && 
  //            !isACEWriteRespSent && matchNS(m_pkt) &&
  //            (m_ace_write_addr_pkt.awaddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]) 
  //            && !isAddrBlocked && !isSMICMDReqSent && !(addrInCSRRegion && isSelfIDRegAccess) && isSMICMDReqNeeded) || (isSMICMDReqNeeded && !isSMICMDReqSent && isIoCacheEvict && matchNS(m_pkt) && (m_sfi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  === m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)])));
  // end 
  // eCmdWrNCFull : begin return ((!isCoherent && isWrite && isACEWriteAddressRecd && isACEWriteDataRecd  && 
  //            !isACEWriteRespSent && matchNS(m_pkt) &&
  //            (m_ace_write_addr_pkt.awaddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]) 
  //            && !isAddrBlocked && !isSMICMDReqSent && !(addrInCSRRegion && isSelfIDRegAccess) && isSMICMDReqNeeded) || (isSMICMDReqNeeded && !isSMICMDReqSent && isIoCacheEvict && matchNS(m_pkt) && (m_sfi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  === m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)])));
  //    
  // end
<%if(obj.useCache) { %> 
   eCmdRdVld: begin
   return (isCoherent && isRead && isACEReadAddressRecd && !isACEReadDataSent && matchNS(m_pkt)  &&
	     (m_ace_read_addr_pkt.araddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)])  && ((csr_ccp_lookupen)?(isIoCacheTagPipelineSeen  && !is_ccp_hit):1) && !isAddrBlocked && !isSMICMDReqSent && !(addrInCSRRegion && isSelfIDRegAccess) && isSMICMDReqNeeded);
   end
 //  eCmdRdUnq: begin
 //  return (isCoherent && isPartialWrite && isACEWriteAddressRecd && isACEWriteDataRecd &&  
 //             !isACEWriteRespSent && matchNS(m_pkt) &&
 //             (m_ace_write_addr_pkt.awaddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]) 
 //             && !isAddrBlocked && !isSMICMDReqSent && !(addrInCSRRegion && isSelfIDRegAccess) && isSMICMDReqNeeded && 
 //            (csr_ccp_lookupen ? (isIoCacheTagPipelineSeen && ((m_ccp_ctrl_pkt.alloc && (m_ccp_ctrl_pkt.currstate == IX)) || (m_ccp_ctrl_pkt.currstate inside {SC, SD}))) : 1));
 //  end

//   eCmdMkUnq : begin
//   return (isCoherent && isWrite && !isPartialWrite && isACEWriteAddressRecd && isACEWriteDataRecd &&  
//	      !isACEWriteRespSent && matchNS(m_pkt) &&
//	      (m_ace_write_addr_pkt.awaddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]) 
//	      && !isAddrBlocked && !isSMICMDReqSent && !(addrInCSRRegion && isSelfIDRegAccess) && isSMICMDReqNeeded && 
//             (csr_ccp_lookupen ? (isIoCacheTagPipelineSeen && ((m_ccp_ctrl_pkt.alloc && (m_ccp_ctrl_pkt.currstate == IX)) || (m_ccp_ctrl_pkt.currstate inside {SC, SD}))) : 1));
//   end 
    <%}%>
    <%} else {%>
   //Non AXI4 configs
   eCmdWrUnqFull: begin 
                    return (isCoherent && isWrite && !isPartialWrite && !owo && basic_match && isSMICMDReqNeeded && !isSMICMDReqSent);
                  end

   eCmdWrUnqPtl: begin 
                    return (isCoherent && isPartialWrite && !owo && basic_match && isSMICMDReqNeeded && !isSMICMDReqSent);
                  end
   //eCmdWrNCFull: begin
   //                 return (   (isWrite || isUpdate) && !isPartialWrite && basic_match &&
   //                            ((!isCoherent && isSMICMDReqNeeded && !isSMICMDReqSent) ||
   //                             ( isCoherent && ((owo && isSMICMDReqSent && is2ndSMICMDReqNeeded && !is2ndSMICMDReqSent) ||
   //                                              (!owo && (m_ace_cmd_type inside {WRBK, WRCLN, WREVCT}) && isSMICMDReqNeeded && !isSMICMDReqSent)))));
   //              end
   //eCmdWrNCPtl: begin
   //                 return (   isPartialWrite && basic_match &&
   //                            ((!isCoherent && isSMICMDReqNeeded && !isSMICMDReqSent) ||
   //                             ( isCoherent && owo && isSMICMDReqSent && is2ndSMICMDReqNeeded && !is2ndSMICMDReqSent)));
   //              end


   eCmdWrStshFull,eCmdWrStshPtl,eCmdLdCchShd,eCmdLdCchUnq : begin
	return ( isSMICMDReqNeeded /*|| (dtwrsp_cmstatus_err && (m_pkt.t_smi_ndp_valid >= t_dtwrsp_cmstatus_err))*/ &&
	        !isSMICMDReqSent &&
		((((isWrite || isUpdate) &&
		   (((cmd_type == eCmdWrUnqPtl) || (cmd_type == eCmdWrUnqFull) || (cmd_type == eCmdWrNCPtl) || (cmd_type == eCmdWrNCFull)) ? isACEWriteDataRecd : 1 ) && 
           //#Check.IOAIU.SMI.CMDReq.HProt
		   isACEWriteAddressRecd && matchAux(m_pkt) && matchNS(m_pkt) && !(addrInCSRRegion && isSelfIDRegAccess) &&
		m_ace_write_addr_pkt.awaddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  === m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)]) 
		 )
		));
      

   end
eCmdRdNITC,eCmdRdNITCMkInv,eCmdRdNITCClnInv,eCmdRdVld,eCmdRdCln,eCmdMkInv,eCmdClnInv,eCmdClnVld,eCmdRdNShD,eCmdClnShdPer : begin
      return (isRead && isACEReadAddressRecd && matchNS(m_pkt) && 
	     (m_ace_read_addr_pkt.araddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  == m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)])							              // CONC-8377 && !isAddrBlocked && !isSMICMDReqSent && !addrNotInMemRegion && isSMICMDReqNeeded);
	      && !isAddrBlocked && !isSMICMDReqSent && !(addrInCSRRegion && isSelfIDRegAccess) && isSMICMDReqNeeded);
   end
   eCmdDvmMsg : begin
      return isSMICMDReqNeeded && !isSMICMDReqSent && (m_ace_cmd_type == DVMMSG) && (m_pkt.smi_addr == getExpDVMCmdReqAddr);
   end
	<% } %>								   
   default : begin
      return 0;
   end
     
   endcase // case (cmd_type)
endfunction : matchCmdToTxn

//Match nativeInterface ReadData/Resp packet to an outstanding Atomic Txn
function bit ioaiu_scb_txn::match_ReadDataRespToAtomicTxn(ace_read_data_pkt_t m_pkt);
	
	if (isAtomic && (m_ace_cmd_type != ATMSTR)) begin //All Atomics except ATMSTR will return Data
		if (isACEWriteAddressRecd && 
			 !isACEReadDataSent &&
                          isACEReadDataSentNoRack &&
			 (isSMICMDReqNeeded ? isSMICMDReqSent : 1) &&  
			 (isSMIDTRReqNeeded ? isSMIDTRReqRecd : 1) &&
			(m_ace_write_addr_pkt.awid == m_pkt.rid))
			return 1;
	end 

	return 0;
endfunction : match_ReadDataRespToAtomicTxn

//Match nativeInterface ReadData/Resp packet to an outstanding DVMMSG Txn
function bit ioaiu_scb_txn::match_ReadDataRespToDvmMsg(ace_read_data_pkt_t m_pkt);

        if (isRead && 
            (m_ace_cmd_type == DVMMSG) &&
	     isSMIDTWRespRecd && //CONC-13932 //#Check.IOAIU.DVMOrdering.DTWRsp->RdResp
	     ((isDVMMultiPart && isACEReadDataSent) ? !isACEReadDataDVMMultiPartSent : !isACEReadDataSent) &&
             (m_ace_read_addr_pkt.arid == m_pkt.rid)) begin
                //uvm_report_info("<%=obj.strRtlNamePrefix%> SCB DBG",$sformatf("TXNID:%0d fn:match_ReadDataRespToDvmMsg matches DVMMsg", tb_txnid),UVM_NONE);
		return 1;
        end        

	return 0;
endfunction : match_ReadDataRespToDvmMsg


function bit ioaiu_scb_txn::match_ReadDataRespToDvmCmpl(ace_read_data_pkt_t m_pkt);
    
    if (isDVMSnoop && 
        isACEReadDataSentNoRack &&
        !isACEReadDataSent &&
        (txn_type == "DVMSYNC") &&
        (m_ace_read_addr_pkt.arid == m_pkt.rid)) begin 
        //uvm_report_info("<%=obj.strRtlNamePrefix%> SCB DBG",$sformatf("TXNID:%0d fn:match_ReadDataRespToDvmCmpl matches DVMComplete", tb_txnid),UVM_NONE);
        return 1;
    end 
    return 0;

endfunction : match_ReadDataRespToDvmCmpl

function bit ioaiu_scb_txn::match_ReadDataRespToErrorScenarios(ace_read_data_pkt_t m_pkt);
    if (  isRead &&
         (m_ace_read_addr_pkt.arid == m_pkt.rid) &&
          isACEReadDataSentNoRack &&
     	 !isACEReadDataSent &&
         (
          illegalNSAccess ||
	  illegalCSRAccess ||
          illDIIAccess ||
          addrNotInMemRegion ||
          mem_regions_overlap ||
          (addrInCSRRegion && isSelfIDRegAccess)) //It never gets to SMI
        ) begin
        //`uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG",$sformatf("TXNID:%0d fn:match_ReadDataRespToErrorScenarios matches", tb_txnid),UVM_NONE);
        return 1;
    end
    return 0;
endfunction: match_ReadDataRespToErrorScenarios

function bit ioaiu_scb_txn::match_ReadDataRespToRead(ace_read_data_pkt_t m_pkt);
    if (  isRead &&
         !isDVM  &&
         (m_ace_read_addr_pkt.arid == m_pkt.rid) &&
          isACEReadDataSentNoRack &&
     	 !isACEReadDataSent &&
         (isMultiAccess ? isMultiLineMaster : 1) &&
         <%if(obj.useCache) { %> 
         (csr_ccp_lookupen ? isIoCacheTagPipelineSeen : 1) && 
        <%}%>
        //Here we cannot qualify with SMIDTRReqRecd since SMI DTRreq is not
        //captured by scb until rlast is received and there are cases where
        //once a beat is received on SMI it is immediately forwarded to
        //nativeInterface
         ((isSMICMDReqSent && (isSMIDTRReqNeeded ? 1 : isSMISTRReqRecd)) <%if(obj.useCache) {%> || is_ccp_hit <%}%>) //either ccp_hit or SMI activity
        ) begin
        //`uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG",$sformatf("TXNID:%0d fn:match_ReadDataRespToRead matches", tb_txnid),UVM_NONE);
        return 1;
    end
    return 0;
endfunction: match_ReadDataRespToRead




function int ioaiu_scb_txn::calcStrResult();
   bit [4:0] str_result;
   eMsgCMD cmd_type;
   $cast(cmd_type,m_cmd_req_pkt.smi_msg_type);
   
   //DCTODO calculate more than just ST
   case(cmd_type)
     eCmdRdNC, eCmdRdNITC, eCmdRdVld, eCmdRdCln, eCmdRdUnq : begin
	return 1;
     end
     eCmdClnVld, eCmdClnUnq, eCmdClnInv : begin
	return 0;
     end
     eCmdRdAtm,eCmdSwAtm, eCmdCompAtm : begin
	return 1;
     end
     default : begin
	return 0;
     end 
   endcase // case (m_cmd_req_pkt)
endfunction : calcStrResult

<%if(obj.useCache) { %>
function ccp_ctrl_pkt_t ioaiu_scb_txn::getExpCcpCtrl(ccp_ctrl_pkt_t m_pkt, ccpCacheLine cl);
    ccp_ctrl_pkt_t exp_pkt;
    ccp_cachestate_enum_t final_state;		       
    exp_pkt = new();
    exp_pkt.copy(m_pkt);
    
    //#Check.IOAIU.CCPCtrlPkt.CurrState
    if(cl !== null)
        final_state = cl.state;
    else
        final_state = IX;

    if(!m_pkt.lookup_p2 && !m_pkt.nackuce  && !m_pkt.nack && !m_pkt.cancel) begin:_vld_ccp_ctrl_pkt
        //#Check.IOAIU.CCPCtrlPkt.TagStateUpdate
        exp_pkt.tagstateup = hasTagUpdate;


      	if(isWrite) begin
	    if (isCoherent) begin
	        case(final_state)
	   	    UD,UC : exp_pkt.wr_data = 1; 
	   	    SD,SC : exp_pkt.wr_data = 0;
		endcase
	    end 
	    else begin 
	        if (final_state != IX) 
		    exp_pkt.wr_data = 1;
	    end
      	end

        //#Check.IOAIU.CCPCtrlPkt.RPUpdate
        if (!isSnoop) begin
            <%if(obj.AiuInfo[obj.Id].ccpParams.RepPolicy == "NRU") {%>
	        exp_pkt.rp_update = ((m_pkt.currstate != IX) || (($countones(m_pkt.currnruvec | (1 << m_pkt.wayn)) == <%=obj.nWays%>) && m_pkt.alloc)) ? 1 : 0;
            <%} else if (obj.AiuInfo[obj.Id].ccpParams.RepPolicy == "PLRU") {%> 
	        exp_pkt.rp_update = ((m_pkt.currstate != IX) || m_pkt.alloc) ? 1 : 0;
            <%}%>
	end else begin 
	    exp_pkt.rp_update = 0;
	end

        //#Check.IOAIU.CCPCtrlPkt.SetIndex
        exp_pkt.setindex = ccp_index; 
    
    end:_vld_ccp_ctrl_pkt

    return exp_pkt;
endfunction : getExpCcpCtrl

function void ioaiu_scb_txn::checkExpCcpCtrl(ccp_ctrl_pkt_t m_pkt, ccpCacheLine cl, string s = "");
   ccp_ctrl_pkt_t exp_pkt;

   exp_pkt = getExpCcpCtrl(m_pkt,cl);
   
   <%if(obj.AiuInfo[obj.Id].ccpParams.RepPolicy == "RANDOM") {%>
    //If RepPolicy == RANDOM, rp_update is a don't care
    exp_pkt.rp_update = m_pkt.rp_update;
   <%}%>

   if(!exp_pkt.do_compare_pkts(m_pkt)) begin
	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Fields mismatch for CCP Ctrl for %0s",m_pkt.sprint_pkt()),UVM_NONE);
        print_me();
	uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Above Fields mismatch for CCP Ctrl for %0s",s),UVM_NONE);
   end
endfunction : checkExpCcpCtrl
<% } %>

<%if(obj.useCache || (obj.fnNativeInterface == "ACELITE-E")) { %>   		     
function smi_seq_item ioaiu_scb_txn::axiToSmiData();

   int smi_dw_intfsize = <%if(obj.useCache){%>(csr_ccp_lookupen && csr_ccp_allocen)? (2 ** m_snp_req_pkt.smi_intfsize) : (2 ** m_str_req_pkt.smi_intfsize) <%} else {%> (2 ** m_str_req_pkt.smi_intfsize) <%}%>; // 1=64b,2=128b,4=256b	     
   int data_size =  <%if(obj.useCache){%> (csr_ccp_lookupen && csr_ccp_allocen)? m_io_cache_data.size() : m_ace_write_data_pkt.wdata.size() <%} else {%> m_ace_write_data_pkt.wdata.size() <%}%>;
   int intfDWs = <%=obj.intfDWs%>; // 0=1=64b,1=2=128b,2=4=256b
   bit lt = (intfDWs <= smi_dw_intfsize); // NativeIntfsize less_than requester's
   int indx,idx1,idx2,indx1,indx2,indx22;
   int ratio = (lt ? (smi_dw_intfsize/intfDWs) : (intfDWs/smi_dw_intfsize));
   bit [<%=wRotateIndx-1%>:0] offset = 0;
   // CONC-6978 using CCP addr instead of SnpReq.Addr //smi_addr_t intfSize_aligned_address, smi_addr = (<%if(obj.useCache){%>m_snp_req_pkt.smi_addr<%} else {%>m_cmd_req_pkt.smi_addr<%}%>);
   smi_addr_t intfSize_aligned_address, smi_addr = (<%if(obj.useCache){%>(csr_ccp_lookupen && csr_ccp_allocen)? m_ccp_ctrl_pkt.addr:m_cmd_req_pkt.smi_addr<%} else {%>m_cmd_req_pkt.smi_addr<%}%>);
   smi_seq_item exp_dtr;

   exp_dtr = new();		       
   exp_dtr.copy(m_dtr_req_pkt);
   //#Check.IOAIU.SMI.DtrReq.InitiatorID
   //#Check.IOAIU.SMI.DtrReq.TargetID		       
   // for DWID for lt=0 case
   if(!lt) begin
       idx1 = smi_addr[<%=obj.wCacheLineOffset-1%> : <%=IntfSize+3%>];              //  i loop
       case($clog2(ratio)) 
       1: idx2 = smi_addr[<%=IntfSize+3-1%>  -:1];//  j loop
       2: idx2 = smi_addr[<%=IntfSize+3-1%>  -:2];//  j loop
       endcase
   end else begin
       idx1 = smi_addr[<%=obj.wCacheLineOffset-1%>:<%=IntfSize+3%>];
   end
   //smi addr based on case
   smi_addr = (lt ? (smi_addr >> <%=IntfSize+3%>) : (smi_addr >> (<%=IntfSize+3%> - $clog2(ratio))) ) ;
   offset = smi_addr % ratio;

   if(lt) begin : is_lt
       //Dest Pkt -> SMI
       foreach(exp_dtr.smi_dp_data[i]) begin
          exp_dtr.smi_dp_data[((i + offset) % data_size)] = <%if(obj.useCache){%>(csr_ccp_lookupen && csr_ccp_allocen)? m_io_cache_data[i]:m_ace_write_data_pkt.wdata<%}else{%>m_ace_write_data_pkt.wdata<%}%>[i];
          indx = ( idx1 + i) % data_size;
          //intfDWs
          //#Check.IOAIU.SMI.DtrReq.DBad
          for (int j=0;j<intfDWs;j++) begin
              exp_dtr.smi_dp_dwid[((i + offset) % data_size)][j*WSMIDPDWIDPERDW+:WSMIDPDWIDPERDW]=  indx*intfDWs + j;
              <%if(obj.useCache){%> 
              exp_dtr.smi_dp_dbad[((i + offset) % data_size)][j*WSMIDPDBADPERDW+: WSMIDPDBADPERDW] = m_io_cache_dat_err[indx]; 
              <%}%>
          end
       end       
   end : is_lt
   else begin : else_not_lt
       foreach(exp_dtr.smi_dp_data[i]) begin : foreach_smi_dp_data
           for (int j =0 ; j< ratio; j++) begin
                  int j2 = (j+offset)%ratio;
                  bit [<%=wRotateIndx-1%>:0] i2 = (i+((j+offset)>=ratio ? 1 :0))%data_size;
               if(smi_dw_intfsize == 1) begin
                  exp_dtr.smi_dp_data[i][64*j+:64] = <%if(obj.useCache){%>(csr_ccp_lookupen && csr_ccp_allocen)? m_io_cache_data[i2][64*(j2)+:64]:m_ace_write_data_pkt.wdata<%}else{%>m_ace_write_data_pkt.wdata<%}%>[i2][64*(j2)+:64];
               end else if (smi_dw_intfsize == 2) begin
                  exp_dtr.smi_dp_data[i][128*j+:128] = <%if(obj.useCache){%>(csr_ccp_lookupen && csr_ccp_allocen)? m_io_cache_data[i2][128*(j2)+:128]:m_ace_write_data_pkt.wdata<%}else{%>m_ace_write_data_pkt.wdata<%}%>[i2][128*(j2)+:128];
               end else begin
	           uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("NativeIntf size(%0d) > SnpReq.IntfSize(%0d) and SnpReq.Intfsize other than 1 and 2 :%0d",intfDWs, smi_dw_intfsize, smi_dw_intfsize),UVM_NONE);
               end
           end		       
           //intfDWs
           indx1 = ((idx1+i)%data_size); // 0 1 ,  1 0 
           for(int j=0; j<ratio; j++) begin
               indx2 = ((indx1*ratio) + idx2 + j)%(ratio * data_size); // 0 1/ 1 2; 2 3/ 3 0
               indx22 = ((i*ratio) + idx2 + j)%(ratio * data_size); 
               for(int k=0; k<smi_dw_intfsize;k++) begin
                   exp_dtr.smi_dp_dwid[i][((j*smi_dw_intfsize)+k)*WSMIDPDWIDPERDW+:WSMIDPDWIDPERDW] = indx2*smi_dw_intfsize+k;// 2->4,5
                   <%if(obj.useCache){%> 
                   exp_dtr.smi_dp_dbad[i][((j*smi_dw_intfsize)+k)*WSMIDPDBADPERDW+:WSMIDPDBADPERDW] = m_io_cache_dat_err[indx22>><%=IntfSize%>]; 
                   <%}%>
               end
           end
       end : foreach_smi_dp_data
   end : else_not_lt
   return exp_dtr;
endfunction : axiToSmiData
<% } else { %>
function smi_seq_item ioaiu_scb_txn::axiToSmiData();
<% var beatsInACacheline = (Math.pow(2,obj.wCacheLineOffset) * 8) / obj.wData;
   var dwsInABeat        = obj.wData / 64;
   var dwsInACacheline = (Math.pow(2,obj.wCacheLineOffset) * 8) / 64;
  %>
   int axi_data[];
   int dws_arr_b4[],dws_arr_af[];
   int dest_data[];
   int smi_data[];
   int ac_cl_offset;
   int cdw_offset,cl_offset,offset,rdw_offset,rec_beat_offset,send_beat_offset,cdw_shift;
   int smi_intfsize;
   longint dw[<%=dwsInACacheline%>];
   longint cdw[<%=dwsInACacheline%>];
   longint rdw[<%=dwsInACacheline%>];
   int be[<%=dwsInACacheline%>];

   smi_addr_t intfSize_aligned_address, smi_addr;
   smi_seq_item exp_dtr;
   smi_seq_item s_pkt, r_pkt;

   exp_dtr = new();
   exp_dtr.copy(m_dtr_req_pkt);
   //#Check.IOAIU.SMI.DTWReq.IntfSize
<%if(obj.useCache) { %>
   //calculate offset
   smi_intfsize = m_snp_req_pkt.smi_intfsize;
   smi_addr     = m_snp_req_pkt.smi_addr;	     
   //05/20 can skip the intfDtws step because native wdata always = to smi wdata. We only need to rotate the words

<% } else {%>
  //#Check.IOAIU.SMI.SNPReq.IntfSize
    if(isSnoop) begin
       smi_intfsize = m_snp_req_pkt.smi_intfsize;
       smi_addr     = m_snp_req_pkt.smi_addr;
    end else begin
       smi_intfsize = m_str_req_pkt.smi_intfsize;
       smi_addr     = m_cmd_req_pkt.smi_addr;
    end
<% } %>
    <% for(var i = 0; i < beatsInACacheline; i++) {
	  for(var j = 0; j < dwsInABeat; j++) { %>
        <%if(obj.useCache) { %>	
             if (csr_ccp_lookupen && csr_ccp_allocen) begin:_ccp_enable<%=i%>_<%=j%>			     
             dw[<%=((i * dwsInABeat) + j)%>] = m_io_cache_data[<%=i%>][<%=((64 * (j + 1)) -1)%>:<%=(64 * j)%>];
             end:_ccp_enable<%=i%>_<%=j%> else begin:_ccp_disable<%=i%>_<%=j%>
	     <% } %>		     
		    if(isSnoop)
                       dw[<%=((i * dwsInABeat) + j)%>] = m_ace_snoop_data_pkt.cddata[<%=i%>][<%=((64 * (j + 1)) -1)%>:<%=(64 * j)%>];
                    else
                       dw[<%=((i * dwsInABeat) + j)%>] = m_ace_write_data_pkt.wdata[<%=i%>][<%=((64 * (j + 1)) -1)%>:<%=(64 * j)%>];
        <%if(obj.useCache) { %>	
             end:_ccp_disable<%=i%>
	    <% } %>		     
    <%   } 
      } %>
   if(isSnoop)
   //BingJ: In ACE, if SNP_REQ smi_intfsize is larger than the CD data width,
   //ACADDR will align to the SNP_REQ smi_intfsize
        ac_cl_offset  = m_ace_snoop_addr_pkt.acaddr % (2 ** <%=obj.wCacheLineOffset%>);
   cl_offset  = smi_addr % (2 ** <%=obj.wCacheLineOffset%>);
   if(isSnoop)
        cdw_offset = ac_cl_offset >> 3;
   else
        cdw_offset = cl_offset >> 3;
   cdw_shift  = (cdw_offset / <%=dwsInABeat%>) * <%=dwsInABeat%>;
   
   for(int i = 0; i < <%=dwsInACacheline%>; i++) begin
      cdw[(i + cdw_shift) %<%=dwsInACacheline%>] = dw[i];
   end
   rdw_offset = (2 ** smi_intfsize) * (cl_offset >> (smi_intfsize + 3));
   for(int i = 0; i < <%=dwsInACacheline%>; i++) begin
      rdw[i] = cdw[(i + rdw_offset) % <%=dwsInACacheline%>];
   end
  <% for(var i = 0; i < beatsInACacheline; i++) {
	 var s = 'exp_dtr.smi_dp_data[' + i + '] = {'
	 for(var j = dwsInABeat - 1; j >= 0; j--) {
	   s += 'rdw[' + ((i * dwsInABeat) + j) + ']' + ((j == 0) ? '' : ',');
	 }
	 s += '};'; %>
	 <%=s%>;
 <% } %>
    //#Check.IOAIU.SMI.DtrReq.DWID
<% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
     if(isSnoop) begin
        exp_dtr.smi_dp_dwid = getExpDWID(m_snp_req_pkt.smi_addr, <%=obj.wCdData%>/SYS_nSysCacheline, 0, 0, ((m_snp_req_pkt.smi_addr[<%=obj.wCacheLineOffset%>-1:0]>>3)/(2**m_snp_req_pkt.smi_intfsize) * (2**m_snp_req_pkt.smi_intfsize)));
    end else begin
        exp_dtr.smi_dp_dwid = getExpDWID(m_cmd_req_pkt.smi_addr, <%=obj.wData%>/SYS_nSysCacheline, 0, 0, ((m_cmd_req_pkt.smi_addr[<%=obj.wCacheLineOffset%>-1:0]>>3)/(2**m_str_req_pkt.smi_intfsize) * (2**m_str_req_pkt.smi_intfsize)));
    end
<% } %>
    return exp_dtr;
endfunction : axiToSmiData
<% } %>

function void ioaiu_scb_txn::check_dtw_txn(smi_seq_item m_pkt, string id = "");
   eMsgDTW dtw_type;
   eMsgDTWMrgMRD dtw_mrg_mrd_type;
   check_dtw_type(dtw_type, dtw_mrg_mrd_type);
   check_dtw_fields(dtw_type, dtw_mrg_mrd_type);
   check_dtw_num_beats();
   check_dtw_beats();
   getExpDtwRsp();
endfunction : check_dtw_txn

function void ioaiu_scb_txn::check_dtw_fields(input eMsgDTW dtw_type, input eMsgDTWMrgMRD dtw_mrg_mrd_type);
   //#Check.IOAIU.SMI.DtwReq.TargetID
   //#Check.IOAIU.SMI.DtwReq.target_id
   if ((m_dtw_req_pkt.smi_targ_id >> WSMINCOREPORTID) != dest_id) begin
	   `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("UID:%0d DtwReq TargId is incorrect Act:%0d Exp:%0d", tb_txnid, m_dtw_req_pkt.smi_targ_id >> WSMINCOREPORTID, dest_id));
   end

   //#Check.IOAIU.SMI.DtwReq.RL
    if (dtw_mrg_mrd_type inside {eDtwMrgMRDInv,eDtwMrgMRDSCln,eDtwMrgMRDSDty,eDtwMrgMRDUCln,eDtwMrgMRDUDty}) begin
       if (m_dtw_req_pkt.smi_rl != 2'b11)
	        `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("UID:%0d DtwReq.RL is incorrect Act:%0d Exp:2'b11 for DTWMrgMRD requests", tb_txnid, m_dtw_req_pkt.smi_rl));
    end else if (dtw_type inside {eDtwNoData, eDtwDataCln , eDtwDataPtl, eDtwDataDty}) begin
       if (m_dtw_req_pkt.smi_rl != 2'b10) 
         `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("UID:%0d DtwReq.RL is incorrect Act:%0d Exp:2'b10 for DTWDataCln/DTWDataPtl/DTWDataDty requests", tb_txnid, m_dtw_req_pkt.smi_rl));
    end else begin 
	      `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("UID:%0d DtwReq.RL:%0d but no expectation set", tb_txnid, m_dtw_req_pkt.smi_rl));
    end

    //#Check.IOAIU.SMI.DtwReq.IntfSize
    //ConcertoCProtocolArch_3.7_0.55
    //4.8.4.4 IntfSize. It needs to be checked only for DTWMrgMRD req
    if(m_ace_cmd_type == WRUNQPTLSTASH && m_str_req_pkt.smi_cmstatus_snarf && (m_dtw_req_pkt.smi_intfsize != m_str_req_pkt.smi_intfsize)) begin
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Outgoing DtwReq.IntfSize != StrReq.IntfSize. Exp:0x%0h, Actual:0x%0h", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_str_req_pkt.smi_intfsize, m_dtw_req_pkt.smi_intfsize));
    end

    //#Check.IOAIU.SMI.DtwReq.Primary
    if (m_cmd_req_pkt != null) begin 
      if (m_dtw_req_pkt.smi_prim != 1)
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> DtwReq.Primary should be set since the DTWreq was originated due to Write/Atomic transaction", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>));
    end else if (m_snp_req_pkt != null) begin 
      if (m_dtw_req_pkt.smi_prim != 0)
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> DtwReq.Primary should be un-set since the DTWreq was originated due to Snoop transaction", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>));
    end else begin
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> DTWreq was originated neither due to Write/Atomic/Snoop transaction , not possible. Investigate!", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>));
    end
    

    //#Check.IOAIU.SMI.DtwReq.TM
    if (m_dtw_req_pkt.smi_prim == 1) begin 
        if (m_cmd_req_pkt.smi_tm !== m_dtw_req_pkt.smi_tm) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> DTW request has TM field wrong (Expected: 0x%0x Actual: 0x%0x)", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_cmd_req_pkt.smi_tm, m_dtw_req_pkt.smi_tm));
        end
    end else begin 
        if (m_snp_req_pkt.smi_tm !== m_dtw_req_pkt.smi_tm) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> DTW request has TM field wrong (Expected: 0x%0x Actual: 0x%0x)",  tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_snp_req_pkt.smi_tm, m_dtw_req_pkt.smi_tm));
        end
    end
    
    //#Check.IOAIU.SMI.DtwReq.MPF2
    if (m_dtw_req_pkt.smi_prim == 1) begin: _primary_ 
      if (isStash && m_str_req_pkt.smi_cmstatus_snarf) begin 
        if (m_dtw_req_pkt.smi_mpf2 !== m_str_req_pkt.smi_mpf2) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> DTW request has MPF2 field wrong (Expected: 0x%0x Actual: 0x%0x)",  tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_str_req_pkt.smi_mpf2, m_dtw_req_pkt.smi_mpf2));
        end
      end else begin 
        if (m_dtw_req_pkt.smi_mpf2 !== m_cmd_req_pkt.smi_msg_id) begin
            //CONC-17300
            //`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> DTW request has MPF2 field wrong (Expected: 0x%0x Actual: 0x%0x)",  tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_cmd_req_pkt.smi_msg_id, m_dtw_req_pkt.smi_mpf2));
        end
      end
    end: _primary_ 
    else begin: _secondary_ 
      if (dtw_mrg_mrd_type inside {eDtwMrgMRDInv,eDtwMrgMRDSCln,eDtwMrgMRDSDty,eDtwMrgMRDUCln,eDtwMrgMRDUDty}) begin
        if (m_dtw_req_pkt.smi_mpf2 !== m_snp_req_pkt.smi_mpf2) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> DTW request has MPF2 field wrong (Expected: 0x%0x Actual: 0x%0x)",  tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_snp_req_pkt.smi_mpf2, m_dtw_req_pkt.smi_mpf2));
        end
      end else if (dtw_type inside {eDtwNoData, eDtwDataCln , eDtwDataPtl, eDtwDataDty}) begin
        //dont care
      end
    end: _secondary_
        
//    //#Check.IOAIU.SMI.DtwReq.TM
//    // This nasty nested if conditions below can be consolidated into one. For now too hectic to write it cleanly :(
//    if (isSnoop && (m_dtw_req_pkt.smi_tm == m_snp_req_pkt.smi_tm)) begin
//        // This is valid
//    end else if (!isSnoop && (m_dtw_req_pkt.smi_tm == m_cmd_req_pkt.smi_tm) ) begin
//        // This is valid
//    end else begin
//            //-------------------------------------------------------------
//            // Notes::  Code added for CONC-8404
//            //  When user is running with "+ioaiu_cctrlr_mod" parm, until
//            //  simulation enters in phase-3 (meaning ioaiu_cctrlr_phase=3..  
//            //  the TM-bit will not be checked.
//            if (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2))) begin 
//                //#Check.IOAIU.TTRI.TM_compare
//                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Outgoing DtwReq has TM field mismatch. Exp: %b, Real: %b. DtwReq: %s", getExpTM, m_dtw_req_pkt.smi_tm, m_dtw_req_pkt.convert2string),UVM_NONE);
//            end
//    end
endfunction : check_dtw_fields

//*******************************Check on DTWReq num_valid_beats*******************************//
function void ioaiu_scb_txn::check_dtw_num_beats();
    int                   exp_num_beats;
    int                   act_num_beats;
    act_num_beats = m_dtw_req_pkt.smi_dp_be.size();

    if (isSnoop || isIoCacheEvict || (isUpdate==1 && isPartialWrite==0)) begin:_snoop
          exp_num_beats = NUM_BEATS_CACHELINE;
    end:_snoop
    else if (m_ace_cmd_type == DVMMSG) begin : _dvmmsg_
          exp_num_beats = 1;
    end : _dvmmsg_
    else if (isWrite || (isUpdate==1 && isPartialWrite==1)) begin: _wr_
          exp_num_beats = $ceil((real'(2**m_cmd_req_pkt.smi_size)*8) / <%=obj.wData%>);
    end: _wr_
    else begin: _default_
          exp_num_beats = 0; //we should never get here
    end: _default_

    //#Check.IOAIU.SMI.DtwReq.NumBeats
    if (act_num_beats !== exp_num_beats) begin
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Outgoing AIU->NOC DTW request for cmdtype:%0s has incorrect data beats (Expected: 0x%0x Actual: 0x%0x)", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ace_cmd_type, exp_num_beats, act_num_beats));
    end else begin
       //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Outgoing AIU->NOC DTW request for cmdtype:%0s has %0d data beats", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ace_cmd_type, act_num_beats), UVM_LOW)
    end
endfunction : check_dtw_num_beats
//*****************************************************************************//

function void ioaiu_scb_txn::check_dtw_beats();
    
    int                   m_tmp_qA[$];
    dp_dwid_t             exp_dwid;
    bit                   uncorr_err;
    string s = "";
    smi_seq_item          dtwreq_pkt;
    m_tmp_qA = {};

    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> check_dtw_beats:m_pkt %s",tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)

    if(isWrite) begin
         //#Check.IOAIU.SMI.DtwReq.BE
         //#Check.IOAIU.SMI.DtwReq.cmstatus
         foreach(m_dtw_req_pkt.smi_dp_be[idx]) begin
            if(m_dtw_req_pkt.smi_dp_be[idx] != m_ace_write_data_pkt.wstrb[idx] && (!$test$plusargs("write_address_error_test_ott") && m_dtw_req_pkt.smi_cmstatus !==  8'b1000_0011 && m_dtw_req_pkt.smi_dp_dbad[idx] == 0)) begin
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Outgoing AIU->NOC DTW request has byteenable value wrong (Expected: 0x%0x Actual: 0x%0x)", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ace_write_data_pkt.wstrb[idx], m_dtw_req_pkt.smi_dp_be[idx]));
            end
         end
         //#Check.IOAIU.SMI.DtwReq.DataProt
         foreach(m_dtw_req_pkt.smi_dp_data[idx]) begin
             if((m_dtw_req_pkt.smi_dp_data[idx] & m_dtw_req_pkt.smi_dp_be[idx]) != (m_ace_write_data_pkt.wdata[idx] & m_ace_write_data_pkt.wstrb[idx]) && (!$test$plusargs("write_address_error_test_ott") && m_dtw_req_pkt.smi_cmstatus !==  8'b1000_0011 && m_dtw_req_pkt.smi_dp_dbad[idx] == 0)) begin
                 `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Outgoing AIU->NOC DTW request has data value wrong (Expected: 0x%0x Actual: 0x%0x)", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ace_write_data_pkt.wdata[idx], m_dtw_req_pkt.smi_dp_data[idx]));
             end
         end
         //DWID
         //#Check.IOAIU.SMI.DtwReq.Dwid
         if (m_ace_cmd_type inside {ATMLD, ATMSTR, ATMSWAP, ATMCOMPARE} )
             exp_dwid = getExpDWID(m_ace_write_addr_pkt.awaddr,  <%=obj.wData%>/SYS_nSysCacheline, m_ace_write_addr_pkt.awlen, 0);
         else
             exp_dwid = getExpDWID(m_ace_write_addr_pkt.awaddr,  <%=obj.wData%>/SYS_nSysCacheline, m_ace_write_addr_pkt.awlen,m_ace_write_addr_pkt.awburst==2);
         foreach(m_dtw_req_pkt.smi_dp_dwid[idx]) begin
             if(m_dtw_req_pkt.smi_dp_dwid[idx] != exp_dwid[idx] && (!$test$plusargs("write_address_error_test_ott") && m_dtw_req_pkt.smi_cmstatus !==  8'b1000_0011 && m_dtw_req_pkt.smi_dp_dbad[idx] == 0)) begin
                 `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Outgoing AIU->NOC DTW request has DWID value wrong (Expected: 0x%0x Actual: 0x%0x)", tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, exp_dwid[idx], m_dtw_req_pkt.smi_dp_dwid[idx]));
             end
         end
     end//}isWrite
	
     if(isUpdate) begin //{isUpdate
          if (m_ace_cmd_type inside {WRCLN,WRBK,WREVCT})
          begin
              //#Check.IOAIU.SMI.DtwReq.DBad
              foreach(m_dtw_req_pkt.smi_dp_be[idx]) begin
                  if((m_dtw_req_pkt.smi_dp_be[idx] != m_ace_write_data_pkt.wstrb[idx]) && (m_dtw_req_pkt.smi_dp_dbad[idx] !== '1)) begin
                      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
                      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC DTW request has byte enable value wrong (Expected: 0x%0x Actual: 0x%0x)", m_ace_write_data_pkt.wstrb[idx], m_dtw_req_pkt.smi_dp_be[idx]), UVM_NONE);
                  end
              end
              foreach(m_dtw_req_pkt.smi_dp_data[idx]) begin
                  if(((m_dtw_req_pkt.smi_dp_data[idx] & m_dtw_req_pkt.smi_dp_be[idx]) != (m_ace_write_data_pkt.wdata[idx] & m_ace_write_data_pkt.wstrb[idx])) && m_dtw_req_pkt.smi_dp_dbad[idx] !== '1) begin
                      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
                      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC DTW request has data value wrong (Expected: 0x%0x Actual: 0x%0x)", m_ace_write_data_pkt.wdata[idx], m_dtw_req_pkt.smi_dp_data[idx]), UVM_NONE);
                  end
              end
              //DWID
              exp_dwid = getExpDWID(m_ace_write_addr_pkt.awaddr,  <%=obj.wData%>/SYS_nSysCacheline, m_ace_write_addr_pkt.awlen, m_ace_write_addr_pkt.awburst==2);
              foreach(m_dtw_req_pkt.smi_dp_dwid[idx]) begin
                  if(m_dtw_req_pkt.smi_dp_dwid[idx] != exp_dwid[idx]) begin
                      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
                      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC DTW request has DWID value wrong (Expected: 0x%0x Actual: 0x%0x)", exp_dwid[idx], m_dtw_req_pkt.smi_dp_dwid[idx]), UVM_NONE);
                  end
              end
          end
      end//}isUpdate

      //ACE DVM check
      if(m_ace_cmd_type == DVMMSG) begin
           if(m_dtw_req_pkt.smi_dp_data.size != 1) begin
               uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
               uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC DTW request Data size is wrong (Expected: 0x%0x Actual: 0x%0x)", 1, m_dtw_req_pkt.smi_dp_data.size), UVM_NONE);
           end
           if(m_dtw_req_pkt.smi_dp_data[0] != getExpDVMDtwData()) begin
               uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
               uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC DTW request has Data mismatch (Expected: 0x%0x Actual: 0x%0x)", getExpDVMDtwData(), m_dtw_req_pkt.smi_dp_data[0]), UVM_NONE);
           end
           if(m_dtw_req_pkt.smi_dp_be[0] != '1) begin
               uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
               uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC DTW request has BE mismatch (Expected: 0x%0x Actual: 0x%0x)", {wSmiDPbe{1'b1}}, m_dtw_req_pkt.smi_dp_be[0]), UVM_NONE);
           end
      end

      if (isSnoop) begin //{
<%if(obj.useCache) { %> 
           // If its a IO cache hit, check data
           if (!is_ccp_hit) begin     
               print_me();
               uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing SMI DTW packet being sent even though this was not a IO-$ hit"), UVM_NONE);
           end
           else begin
               if (m_dtw_req_pkt.smi_dp_data.size() !== m_io_cache_data.size()) begin
                   print_me();
                   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI DTW data size is not the same as data size in IO cache (ACE:%p SMI:%p)", m_dtw_req_pkt, m_io_cache_data), UVM_NONE);
               end
               // #Check.IOAIU.SMI.DtwReq.priority
               if (m_snp_req_pkt.smi_msg_pri !== m_dtw_req_pkt.smi_msg_pri) begin

                   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
                   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC DTW request has PRI field wrong (Expected: 0x%0x Actual: 0x%0x)", m_snp_req_pkt.smi_msg_pri, m_dtw_req_pkt.smi_msg_pri), UVM_NONE);
               end
               if (addrMgrConst::qos_mapping(m_snp_req_pkt.smi_qos) !== m_dtw_req_pkt.smi_msg_pri) begin

                   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
                   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC DTW request has PRI field wrong , based on SnpReq.QoS:0x%0x,(Expected: 0x%0x Actual: 0x%0x)",m_snp_req_pkt.smi_qos, addrMgrConst::qos_mapping(m_snp_req_pkt.smi_qos), m_dtw_req_pkt.smi_msg_pri), UVM_NONE);
               end
               //DCTODO DATACHK
               foreach (m_io_cache_data[i]) begin
                   if (m_dtw_req_pkt.smi_dp_data[i] !== m_io_cache_data[i] && !m_io_cache_dat_err[i]/* && !aiu_double_bit_errors_enabled*/ && m_dtw_req_pkt.smi_dp_be[i] !== '0) begin
                       print_me();
                       uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing SMI DTWReq data packet for IO cache hit has wrong data (Expected:%p Actual: %p beat:0x%0x)", m_io_cache_data[i], m_dtw_req_pkt.smi_dp_data[i],i), UVM_NONE);
                   end
	       end

               foreach (m_smi_data_be[i]) begin
                   if (m_dtw_req_pkt.smi_dp_be[i] !== '1) begin
                       print_me();
                       uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
                       uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("req_be for DtwReq Message with error beat:0x%0x Expected: 0x%0x Actual: 0x%0x", i, '1, m_dtw_req_pkt.smi_dp_be[i]), UVM_NONE);
                   end 
                   // Each CCP data read beat  with poison bit set, it should have corresponding DBAD asserted
                   if (m_io_cache_dat_err[i] === 1 && m_dtw_req_pkt.smi_dp_dbad[i] !== '1) begin
                       print_me();
                       uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI DTW smi_dp_dbad not set smi_dp_dbad[%0d]:%0h,even as poison bit for corresponding beat was set in CCP", i, m_dtw_req_pkt.smi_dp_dbad[i]), UVM_NONE);
                   end
                   if (m_io_cache_dat_err[i] === 0 && m_dtw_req_pkt.smi_dp_dbad[i] !== '0) begin
                       print_me();
                       uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI DTW smi_dp_dbad set smi_dp_dbad[%0d]:%0h,even as poison bit for corresponding beat was not set in CCP", i, m_dtw_req_pkt.smi_dp_dbad[i]), UVM_NONE);
                   end
               end
               // CONC-6860 -> Waived off the CMSTATUS as correct DBAD is there
               //// CONC-6721 :  For the error in first beat the cmstatus should be Data Error
               //if(m_ott_q[m_tmp_qA[0]].m_io_cache_dat_err[0] === 1 && m_ott_q[m_tmp_qA[0]].m_dtw_req_pkt.smi_cmstatus !== 8'h83) begin
               //    m_ott_q[m_tmp_qA[0]].print_me();
               //    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI DTW expected CMSTATUS : Data Error ('h83) as CCP read first beat had poison bit set"), UVM_NONE);
               //end

            end
    <% } else { %>
    <%if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5") { %>
            //#Check.IOAIU.SMI.CMDReq.CMStatus
            if (isACESnoopRespRecd && m_ace_snoop_resp_pkt.crresp[CCRRESPERRBIT] === 1) begin
              if (m_dtw_req_pkt.smi_cmstatus !== 8'b1000_0011) begin
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Expected to send cmstatus = 8'b1000_0011 (data error) in DTW_REQ for ACE snoop crresp error, Received smi_cmstatus = %0b",m_dtw_req_pkt.smi_cmstatus))
              end
            end 
                   
            foreach(m_dtw_req_pkt.smi_dp_be[idx]) begin
                if(m_dtw_req_pkt.smi_dp_be[idx] != '1) begin
                    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC SNP DTW request has byte enable value wrong (Expected: 0x%0x Actual: 0x%0x)", '1, m_dtw_req_pkt.smi_dp_be[idx]), UVM_NONE);
                end
            end
            foreach(m_dtw_req_pkt.smi_dp_data[idx]) begin
                if(m_dtw_req_pkt.smi_dp_data[idx] != m_ace_snoop_data_pkt.cddata[idx]) begin
                    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC SNP DTW request has data value wrong (Expected: 0x%0x Actual: 0x%0x)", m_ace_snoop_data_pkt.cddata[idx], m_dtw_req_pkt.smi_dp_data[idx]), UVM_NONE);
                end
            end
            //DWID
            exp_dwid = getExpDWID(m_ace_snoop_addr_pkt.acaddr, <%=obj.wCdData%>/SYS_nSysCacheline);
            foreach(m_dtw_req_pkt.smi_dp_dwid[idx]) begin
                if(m_dtw_req_pkt.smi_dp_dwid[idx] != exp_dwid[idx]) begin
                    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_dtw_req_pkt.convert2string()), UVM_NONE);
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC SNP DTW request has DWID value wrong (Expected: 0x%0x Actual: 0x%0x)", exp_dwid[idx], m_dtw_req_pkt.smi_dp_dwid[idx]), UVM_NONE);
                end
            end
        <% } %>
    <% } %> 
      end//}
      else if (isWrite || isAtomic || isUpdate) begin // {
           //Checking DTWreq burst field now that we have a ACE write match
           if (isACEWriteDataRecd && !aiu_nodetEn_err_inj ) begin
               <%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) {%>
               foreach (m_dtw_req_pkt.smi_dp_dbad[i]) begin //CONC -9826 
                  if ($test$plusargs("ccp_single_bit_ott_direct_error_test") && (m_dtw_req_pkt.smi_dp_dbad[i] !== '0) || m_dtw_req_pkt.smi_cmstatus !==  8'b1000_0011) 
                  begin
                      uncorr_err =1 ;
                  end
               end
               <%}%> 
               
               <%if(obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED") {%>
              if(aiu_double_bit_errors_enabled)
                   foreach (m_dtw_req_pkt.smi_dp_dbad[i]) begin //CONC -9826 
                      if ((m_dtw_req_pkt.smi_dp_dbad[i] !== '0) || m_dtw_req_pkt.smi_cmstatus !==  8'b1000_0011) begin
                          uncorr_err =1 ;
                      end
                   end
              <%}%>
                   
              if(!uncorr_err) begin
	          compare_smi_axi_data();
              end 

           end 
           else begin
	   end
       end //}
       else if (isRead && !aiu_nodetEn_err_inj ) begin //{

       end // if (isRead && !aiu_nodetEn_err_inj )//}

<%if(obj.useCache) { %> 
       if (isIoCacheEvict) begin

           if ((m_dtw_req_pkt.smi_dp_data.size() * WXDATA) !== (8 * SYS_nSysCacheline)) begin
               uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("req_length for IO cache evict should be full cacheline (Expected:0x%0x Actual:0x%0x)", 8 * SYS_nSysCacheline, (WXDATA * m_dtw_req_pkt.smi_dp_data.size())), UVM_NONE);
           end
           if (m_dtw_req_pkt.smi_dp_data.size() !== m_io_cache_data.size()) begin
               print_me();
               uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing SMI DTW packet for IO cache evict has wrong DTW data size. (Expected:0x%0x Actual: 0x%0x)", m_io_cache_data.size(), m_dtw_req_pkt.smi_dp_data.size()), UVM_NONE);
           end
           //#Check.IOAIU.DTW.EvictData
           foreach (m_io_cache_data[i]) begin
               if ((m_dtw_req_pkt.smi_dp_data[i] !== m_io_cache_data[i]) && !m_io_cache_dat_err[i]) begin
                   print_me();
                   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing SMI DTW packet for IO cache evict has wrong DTW data (Expected:0x%0x Actual: 0x%0x beat:0x%0x)", m_io_cache_data[i], m_dtw_req_pkt.smi_dp_data[i],i), UVM_NONE);
               end
           end
           //#Check.IOAIU.DTW.EvictDataBe
           if (m_smi_data_be.size() !== m_dtw_req_pkt.smi_dp_data.size()) begin
               print_me();
               uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI DTW expected byte enable size mismatches number of beats in DTWReq (expected be size: %0d Actual DTWReq beats size: %0d)", m_smi_data_be.size(), m_dtw_req_pkt.smi_dp_data.size()), UVM_NONE);
           end
           // #Check.AIU.DataCorruption.OutgoingDTWreqFromEmbeddedMemoryWithErrorDeassertsByteenable
           foreach (m_smi_data_be[i]) begin
               if (m_smi_data_be[i] === 1 && m_dtw_req_pkt.smi_dp_be[i] !== '1 && !aiu_double_bit_errors_enabled) begin
                   print_me();
                   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI DTW expected byte enable should be '1, but it is 0x%0x", m_dtw_req_pkt.smi_dp_be[i]), UVM_NONE);
               end
               // #Check.AIU.DTWReqAfterError
               if (m_smi_data_be[i] === 0 && m_dtw_req_pkt.smi_dp_be[i] !== '0) begin
                   print_me();
                   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI DTW expected byte enable should be '0, but it is 0x%0x",m_dtw_req_pkt.smi_dp_be[i]), UVM_NONE);
               end
               // Each CCP data read beat  with poison bit set, it should have corresponding DBAD asserted
               if (m_io_cache_dat_err[i] === 1 && m_dtw_req_pkt.smi_dp_dbad[i] !== '1) begin
                   print_me();
                   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI DTW smi_dp_dbad not set smi_dp_dbad[%0d]:%0h,even as poison bit for corresponding beat was set in CCP", i, m_dtw_req_pkt.smi_dp_dbad[i]), UVM_NONE);
               end
               if (m_io_cache_dat_err[i] === 0 && m_dtw_req_pkt.smi_dp_dbad[i] !== '0) begin
                   print_me();
                   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI DTW smi_dp_dbad set smi_dp_dbad[%0d]:%0h,even as poison bit for corresponding beat was not set in CCP", i, m_dtw_req_pkt.smi_dp_dbad[i]), UVM_NONE);
               end
           end
                // CONC-6860 -> Waived off the CMSTATUS as correct DBAD is there
                //// CONC-6721 :  For the error in first beat the cmstatus should be Data Error
                //if(m_ott_q[m_tmp_qA[0]].m_io_cache_dat_err[0] === 1 && m_ott_q[m_tmp_qA[0]].m_dtw_req_pkt.smi_cmstatus !== 8'h83) begin
                //    m_ott_q[m_tmp_qA[0]].print_me();
                //    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI DTW expected CMSTATUS : Data Error ('h83) as CCP read first beat had poison bit set"), UVM_NONE
     end
<% } %>
     //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> check_dtw_beats:num_valid_beats:%0d",tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,act_num_beats), UVM_LOW)
endfunction : check_dtw_beats

//*******************************Check on DTWReq_Types*******************************//
function void ioaiu_scb_txn::check_dtw_type(output eMsgDTW dtw_type, output eMsgDTWMrgMRD dtw_mrg_mrd_type);
    //#Check.IOAIU.SMI.DTWReq.MsgType
    //#Check.IOAIU.SMI.DtwReq.CMType     
   //`uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("m_ace_cmd_type %s", m_ace_cmd_type.name()),UVM_LOW);


   if(m_ace_cmd_type == WRUNQPTLSTASH && m_str_req_pkt.smi_cmstatus_snarf ) begin
      dtw_mrg_mrd_type = eDtwMrgMRDUDty; 
   end else begin 
      dtw_mrg_mrd_type = 0; 
   end

   if(m_ace_cmd_type == DVMMSG) begin
      dtw_type=eDtwDataDty;
   end
   else if (isAtomic || isStash || isWrite || isUpdate) begin
       if(m_ace_cmd_type inside {WRLNUNQ,WRUNQ,WRNOSNP}) begin
           if(isPartialWrite)   dtw_type=eDtwDataPtl;
           else if(!isPartialWrite)  dtw_type=eDtwDataDty;
       end
       else if(m_ace_cmd_type inside {WRCLN,WRBK} ) begin
           if(isPartialWrite)   dtw_type=eDtwDataPtl;
           else if(!isPartialWrite)  dtw_type=eDtwDataDty;
       end
       else if(m_ace_cmd_type == WREVCT) begin
          dtw_type=eDtwDataCln;
       end
       else if(m_ace_cmd_type == WRUNQFULLSTASH ) begin
         dtw_type=eDtwDataDty;
       end
       else if(m_ace_cmd_type == WRUNQPTLSTASH && !m_str_req_pkt.smi_cmstatus_snarf) begin//CONC-16367
          if(isPartialWrite)   dtw_type=eDtwDataPtl;
          else if(!isPartialWrite)  dtw_type=eDtwDataDty;
       end
       else if(m_ace_cmd_type inside {ATMSTR,ATMSWAP,ATMLD,ATMCOMPARE}) begin
          dtw_type=eDtwDataPtl;
       end else begin 
          dtw_type=0;
       end
   end
   else if (isIoCacheEvict) begin
         dtw_type = eDtwDataDty;
   end   
<% if( obj.useCache && (obj.fnNativeInterface == "AXI4"||obj.fnNativeInterface == "AXI5")) { %>
   else if(isSnoop) begin
         dtw_type = eDtwDataDty;
   end
<% } %>
<% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
   else if(isSnoop) begin
       case(m_snp_req_pkt.smi_msg_type)
           SNP_NITC, SNP_NITCCI, SNP_NITCMI, SNP_CLN_DTR, SNP_NOSDINT, SNP_CLN_DTW, SNP_STSH_SH: begin
               dtw_type = eDtwDataDty;
           end
           SNP_INV_DTW, SNP_UNQ_STSH, SNP_STSH_UNQ: begin
               dtw_type = eDtwDataDty;
           end
           SNP_INV_DTR: begin 
             if(m_ace_snoop_resp_pkt.crresp[CCRRESPPASSDIRTYBIT])
                 dtw_type = eDtwDataDty;
             else
                dtw_type = eDtwDataCln;
           end
           default:begin
              dtw_type = 0;
           end
       endcase
  end
<% } %>
  else begin 
      dtw_type = 0;
  end

    if(dtw_mrg_mrd_type != 0) begin
       if(m_dtw_req_pkt.smi_msg_type != dtw_mrg_mrd_type) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("IOAIU_UID:%0d Unexpected DTWreq_type:0x%h seen, Expected:%0p", tb_txnid ,m_dtw_req_pkt.smi_msg_type, dtw_mrg_mrd_type));       
       end     
    end
    else if(dtw_type != 0) begin
      if(m_dtw_req_pkt.smi_msg_type != dtw_type) begin// default check on all txns
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("IOAIU_UID:%0d Unexpected DTWreq_type:0x%0h seen, Expected:%0p", tb_txnid ,m_dtw_req_pkt.smi_msg_type, dtw_type));       
      end
    end else begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR",$sformatf("IOAIU_UID:%0d DTWreq expectation not set", tb_txnid));       
    end
  endfunction : check_dtw_type
//*****************************************************************************//

function void ioaiu_scb_txn::getExpDtwRsp();
   exp_dtw_rsp_pkt = smi_seq_item::type_id::create("exp_dtw_rsp_pkt");
   //#Check.IOAIU.SMI.DTWReq.Primary
   //#Check.IOAIU.SMI.DtwRsp.CMType
   //#Check.IOAIU.SMI.DtwRsp.targetID 
   //#Check.IOAIU.SMI.DtwRsp.priority
   //#Check.IOAIU.SMI.DtwRsp.cmstatus
   //#Check.IOAIU.SMI.DtwRsp.RMsgID
   //#Check.IOAIU.SMI.DtwRsp.InitiatorID

   exp_dtw_rsp_pkt.construct_dtwrsp(
                                   .smi_targ_ncore_unit_id (m_dtw_req_pkt.smi_src_ncore_unit_id),
                                   .smi_src_ncore_unit_id  (m_dtw_req_pkt.smi_targ_ncore_unit_id),
                                   .smi_msg_type           (eDtwRsp),
                                   .smi_msg_id             (core_id << (WSMIMSGID- $clog2(<%=obj.nNativeInterfacePorts%>))),
                                   .smi_msg_tier           ('h0),
                                   .smi_steer              ('h0),
                                   .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%>? m_dtw_req_pkt.smi_msg_pri : 'h0),
                                   .smi_msg_qos            ('0),
                                   .smi_tm                 (m_dtw_req_pkt.smi_tm),
                                   .smi_rmsg_id            (m_dtw_req_pkt.smi_msg_id),
                                   .smi_msg_err            ('h0),
                                   .smi_cmstatus           ('h0),
                                   .smi_rl                 ('h0)
                                   );
endfunction : getExpDtwRsp
 		       
function dp_dwid_t ioaiu_scb_txn::getExpDWID(axi_axaddr_t addr, int NativeIntfDWs, int axlen=0, int use_wrap_logic=0, int crit_dw_pos = -1);
    int critical_dw_ps;
    dp_dwid_t exp_dwid;
    localparam BWL = <%=obj.wCacheLineOffset%>-$clog2(<%=obj.wData%>/8);

    bit[2:0] current_dwid_3bit;
    int total_number_of_beats;
    bit[BWL-1:0] current_dwid;
    bit[7:0] current_addr;
    bit[2:0] two_wrapped_dwid;
    bit[2:0] four_wrapped_dwid;
    bit extra_beat;
    int current_beat=0;
    
    if(crit_dw_pos == -1)
        critical_dw_ps = (addr[<%=obj.wCacheLineOffset%>-1:0]>>3)/NativeIntfDWs * NativeIntfDWs;
    else
        critical_dw_ps = crit_dw_pos;
    total_number_of_beats = ((SYS_nSysCacheline*8) * (int'((axlen+1)*<%=obj.wData%> / (SYS_nSysCacheline*8))) + SYS_nSysCacheline*8) / <%=obj.wData%>;
 
    `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("addr:0x%0h NativeIntfDWs:%0d axlen:%0d use_wrap_logic:%0d crit_dw_pos:%0d BWL:%0d critical_dw_ps:%0d total_number_of_beats:%0d",addr, NativeIntfDWs, axlen, use_wrap_logic, crit_dw_pos, BWL, critical_dw_ps, total_number_of_beats), UVM_LOW);
    
    if(!use_wrap_logic) begin
        exp_dwid = new[SYS_nSysCacheline*8/(NativeIntfDWs*64)];
        foreach(exp_dwid[i]) begin
            for (int j=0;j<NativeIntfDWs;j++) begin
                exp_dwid[i][j*WSMIDPDWIDPERDW+:WSMIDPDWIDPERDW]=  (critical_dw_ps + i*NativeIntfDWs + j)%8;
            end
        end
        return exp_dwid;
    end
    exp_dwid = new[total_number_of_beats];    
     
    repeat(total_number_of_beats) begin
        current_dwid = current_beat + addr[5 -: BWL];
        current_dwid_3bit = {current_dwid,{(3-BWL){1'b0}}};
        current_addr = {current_beat,{BWL{1'b0}}} + {1'b0,addr[5:0]};
        two_wrapped_dwid = current_addr[6:3] - 2;
        four_wrapped_dwid = current_addr[6:3] - 4;
        case(<%=obj.wData%>)
            'd64 : begin
                extra_beat = (awlen ==3 ) ? (current_beat >= 4) : (current_beat >= 2);
                if (awlen == 3) begin
                    if(extra_beat) begin
                        exp_dwid[current_beat] = {3{~addr[5]}};
                    end else if (addr[5] == 0) begin
                        exp_dwid[current_beat] = (current_addr[5]) ? four_wrapped_dwid : current_dwid_3bit;
                    end else begin
                        exp_dwid[current_beat] = (current_addr[6]) ? four_wrapped_dwid : current_dwid_3bit;
                    end
                end else if (awlen == 1) begin
                    if (extra_beat)
                        exp_dwid[current_beat] = {3{~addr[5]}};
                    else if(addr[5:4] == 0)
                        exp_dwid[current_beat] = (current_addr[5:4] == 2'b01) ? two_wrapped_dwid : current_dwid_3bit;
                    else if(addr[5:4] == 1)
                        exp_dwid[current_beat] = (current_addr[5:4] == 2'b10) ? two_wrapped_dwid : current_dwid_3bit;
                    else if(addr[5:4] == 2)
                        exp_dwid[current_beat] = (current_addr[5:4] == 2'b11) ? two_wrapped_dwid : current_dwid_3bit;
                    else begin
                        exp_dwid[current_beat] = (current_addr[6]) ? two_wrapped_dwid : current_dwid_3bit;
                    end
                end else begin
                    exp_dwid[current_beat] = current_dwid_3bit;
                end
            end
            'd128 : begin
                extra_beat = (current_beat >= 2);
                if (axlen == 1) begin // 2 beats
                    if(addr[5:4] == 0) begin
                        exp_dwid[current_beat] = {current_dwid_3bit + 3'b001, current_dwid_3bit};
                    end else if (addr[5:4] == 1) begin
                        if(extra_beat) begin
                            exp_dwid[current_beat] = 6'b111111;
                        end else begin
                            exp_dwid[current_beat] =  (current_beat == 1) ? {current_dwid_3bit - 3'b011 , current_dwid_3bit - 3'b100} : {current_dwid_3bit + 3'b001,current_dwid_3bit};
                        end
                    end else if (addr[5:4] == 2) begin
                        exp_dwid[current_beat] = {current_dwid_3bit + 3'b001, current_dwid_3bit};
                    end else begin
                        if(extra_beat) begin
                            exp_dwid[current_beat] = 6'b000000;
                        end else begin
                            exp_dwid[current_beat] =  (current_beat == 1) ? {current_dwid_3bit - 3'b011 , current_dwid_3bit - 3'b100} : {current_dwid_3bit + 3'b001,current_dwid_3bit};
                        end
                    end
                end else begin 
                    exp_dwid[current_beat] = {current_dwid_3bit + 3'b001, current_dwid_3bit};
                end
            end
            'd256 : begin
                exp_dwid[current_beat] = {current_dwid_3bit + 3'b011, current_dwid_3bit + 3'b010, current_dwid_3bit + 3'b001, current_dwid_3bit};
            end
            default : begin
                // add uvm error for unhandled datawidth
            end
        endcase
        current_beat++;
    end 

    return exp_dwid;
endfunction : getExpDWID;

function void ioaiu_scb_txn::checkExpSnpRsp(bit [4:0] exp_snp_result);
   bit[7:0] cmstatus = {2'b0,exp_snp_result,1'b0};

   if(m_snp_addr_err_expected) cmstatus = 8'b10000100; //(Address Error)
   //#Check.IOAIU.SMI.SNPRsp.CMStatus
   getExpSnpRsp(cmstatus);

   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Exp SNPRsp:%s",exp_snp_rsp_pkt.convert2string()), UVM_LOW);
   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Act SNPRsp:%s",m_snp_rsp_pkt.convert2string()), UVM_LOW);
   if(!exp_snp_rsp_pkt.compare(m_snp_rsp_pkt)) begin
      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR","SNPRsp Fields mismatching above!", UVM_NONE);
      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","SNPRsp Fields mismatching above!",UVM_NONE);
   end
endfunction : checkExpSnpRsp

function void ioaiu_scb_txn::getExpSnpRsp(bit [7:0] cmstatus);
   exp_snp_rsp_pkt = smi_seq_item::type_id::create("exp_snp_rsp_pkt");
//#Check.IOAIU.SMI.SNPRsp.MPF1
   exp_snp_rsp_pkt.construct_snprsp(
                                   .smi_targ_ncore_unit_id (m_snp_req_pkt.smi_src_ncore_unit_id),
                                   .smi_src_ncore_unit_id  (m_snp_req_pkt.smi_targ_ncore_unit_id),
                                   .smi_msg_type           (eSnpRsp),
                                   .smi_msg_id             (core_id << (WSMIMSGID- $clog2(<%=obj.nNativeInterfacePorts%>))),
                                   .smi_msg_tier           ('h0),
                                   .smi_steer              ('h0),
                                   .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%>? m_snp_req_pkt.smi_msg_pri : 'h0),
                                   .smi_msg_qos            ('0),
                                   .smi_tm                 (m_snp_req_pkt.smi_tm),
                                   .smi_rmsg_id            (m_snp_req_pkt.smi_msg_id),
                                   .smi_msg_err            ('h0),
                                   .smi_cmstatus           (cmstatus),//SNPrsp: CMStatus[7,6]: Err; CMStatus[5:0] = RV, RS, DC, DT[1:0], Snarf; DT[1]: Data transfer to an AIU; DT[0]: Data transfer to DMI.
                                   .smi_cmstatus_rv        (cmstatus[5]),
                                   .smi_cmstatus_rs        (cmstatus[4]),
                                   .smi_cmstatus_dc        (cmstatus[3]),
                                   .smi_cmstatus_dt_aiu    (cmstatus[2]),
                                   .smi_cmstatus_dt_dmi    (cmstatus[1]),
                                   .smi_cmstatus_snarf     (cmstatus[0]),
                                   .smi_mpf1_dtr_msg_id    ('h0),
                                   .smi_intfsize           ('h<%=Math.log2(obj.wData/64)%>)
                                   );
endfunction : getExpSnpRsp

function bit ioaiu_scb_txn::checkSnpDtrData(string id = "");
   //#Check.IOAIU.SMI.SNPDTRReq.Data
  smi_seq_item exp_data;
  exp_data = axiToSmiData();
  //#Check.IOAIU.SMI.DtrReq.BE
  //#Check.IOAIU.SMI.DtrReq.DataProt
  foreach(m_dtr_req_pkt.smi_dp_data[i]) begin
    if(m_dtr_req_pkt.smi_dp_dbad[i] == 0)begin
     if(m_dtr_req_pkt.smi_dp_data[i] !== exp_data.smi_dp_data[i]) begin
	 uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Data mismatch for beat[%0d] for %s exp:0x%0h act:0x%0h exp_dtr:%0s act_dtr:0x%0h",i,id,exp_data.smi_dp_data[i],m_dtr_req_pkt.smi_dp_data[i],exp_data.convert2string(),m_dtr_req_pkt.convert2string(),),UVM_NONE);
	 uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Data mismatch for beat[%0d] for %s exp:0x%0h act:0x%0h",i,id,exp_data.smi_dp_data[i],m_dtr_req_pkt.smi_dp_data[i],),UVM_NONE);
     end
     if(m_dtr_req_pkt.smi_dp_be[i] !== (exp_data.smi_dp_be[i])) begin
	 uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Byte Enable mismatch for beat[%0d] for %s exp:0x%0h act:0x%0h exp_dtr:%0s act_dtr:0x%0h",i,id,exp_data.smi_dp_be[i],m_dtr_req_pkt.smi_dp_be[i],exp_data.convert2string(),m_dtr_req_pkt.convert2string(),),UVM_NONE);
	 uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Byte Enable mismatch for beat[%0d] for %s exp:0x%0h act:0x%0h",i,id,exp_data.smi_dp_be[i],m_dtr_req_pkt.smi_dp_be[i],),UVM_NONE);
     end
     // #Check.IOAIU.SMI.DtrReq.DWID
     // DCDEBUG Uncomment for DWID checks		     
     if(m_dtr_req_pkt.smi_dp_dwid[i] !== exp_data.smi_dp_dwid[i]) begin
	 uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Dwid mismatch for beat[%0d] for %s exp:0x%0h act:0x%0h exp_dtr:%p act_dtr:0x%p",i,id,exp_data.smi_dp_dwid[i],m_dtr_req_pkt.smi_dp_dwid[i],exp_data.smi_dp_dwid,m_dtr_req_pkt.smi_dp_dwid),UVM_NONE);
	 uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Dwid mismatch for beat[%0d] for %s exp:0x%0h act:0x%0h",i,id,exp_data.smi_dp_dwid[i],m_dtr_req_pkt.smi_dp_dwid[i],),UVM_NONE);
     end
     <% if(obj.useCache) { %>
     <%}%>
    end
  end


endfunction : checkSnpDtrData

function bit ioaiu_scb_txn::checkSnpResp(string id = "");
    smi_seq_item exp_snp_resp;
    eMsgSNP snp_type;
    exp_snp_resp = new();
    exp_snp_resp.copy(m_snp_rsp_pkt);
    exp_snp_resp.unpack_smi_seq_item;
    exp_snp_resp.smi_cmstatus_rv = 0;
    exp_snp_resp.smi_cmstatus_rs = 0;
    exp_snp_resp.smi_cmstatus_dc = 0;
    exp_snp_resp.smi_cmstatus_dt_aiu = 0;
    exp_snp_resp.smi_cmstatus_dt_dmi = 0;
    exp_snp_resp.smi_cmstatus_snarf  = 0;
    $cast(snp_type, m_snp_req_pkt.smi_msg_type);
    //#Check.IOAIU.SMI.SnpRsp.Cmstatus
    //#Check.IOAIU.SMI.SnpRsp.CMType
    case(m_snp_req_pkt.smi_msg_type)
        SNP_NITC   : begin
            case(WU_DT_PD_IS)
                //CONC-6925
                /* 4'b0001: begin */
                /*     exp_snp_resp.smi_cmstatus_rv = 1; */
                /*     exp_snp_resp.smi_cmstatus_rs = 1; */
                /* end */
                4'b0001, 4'b1001: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                end
                4'b0100: begin
                    if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
                m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>)) begin
                      exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    end
                end
                4'b1100: begin
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                end
                4'b1101, 4'b0101: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                end
                4'b0110, 4'b1110: begin
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                end
                4'b0111, 4'b1111: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_rs = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                end
            endcase
            // if(!(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
            //     m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>))) begin
            //             exp_snp_resp.smi_cmstatus_rv = 0;
            //             exp_snp_resp.smi_cmstatus_rs = 0;
            //         exp_snp_resp.smi_cmstatus_dc = 0;
            //             exp_snp_resp.smi_cmstatus_dt_aiu = 0;
            //             exp_snp_resp.smi_cmstatus_dt_dmi = 0;
                    
                // end
        end
        SNP_NITCCI, SNP_NITCMI : begin
            case(WU_DT_PD_IS)
                4'b0110, 4'b1110: begin
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                end
            endcase
            if(!(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
                m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>))) begin
                        exp_snp_resp.smi_cmstatus_rv = 0;
                        exp_snp_resp.smi_cmstatus_rs = 0;
                        exp_snp_resp.smi_cmstatus_dc = 0;
                        exp_snp_resp.smi_cmstatus_dt_aiu = 0;
                end
            end
        SNP_CLN_DTR : begin
            case(WU_DT_PD_IS)
                4'b0001, 4'b1001: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_rs = 1;
                end
                4'b0100: begin
                    if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
                	m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>)) begin
                        exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    end
                end
                4'b1100: begin
                    exp_snp_resp.smi_cmstatus_dc = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                end
                4'b0101, 4'b1101: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                end
                4'b0110: begin
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                end
                4'b1110: begin
                    exp_snp_resp.smi_cmstatus_dc = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                end
                4'b0111, 4'b1111: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_rs = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                end
            endcase
		// if(!(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
     	// 	m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>))) begin
        //             exp_snp_resp.smi_cmstatus_rv = 0;
        //             exp_snp_resp.smi_cmstatus_rs = 0;
    	// 	    exp_snp_resp.smi_cmstatus_dc = 0;
        //             exp_snp_resp.smi_cmstatus_dt_aiu = 0;
        //             exp_snp_resp.smi_cmstatus_dt_dmi = 0;
        		
    	// 	end
        end
        SNP_VLD_DTR : begin
            case(WU_DT_PD_IS)
                4'b0001, 4'b1001: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_rs = 1;
                end
                4'b0100: begin
                    if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
                	m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>)) begin
                        exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    end
                end
                4'b1100: begin
                    exp_snp_resp.smi_cmstatus_dc = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                end
                4'b0101, 4'b1101: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                end
                4'b0110, 4'b1110: begin
                    exp_snp_resp.smi_cmstatus_dc = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                end
                4'b0111, 4'b1111: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_rs = 1;
                    exp_snp_resp.smi_cmstatus_dc = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                end
            endcase
		// if(!(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
     	// 	m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>))) begin
        //             exp_snp_resp.smi_cmstatus_rv = 0;
        //             exp_snp_resp.smi_cmstatus_rs = 0;
    	// 	    exp_snp_resp.smi_cmstatus_dc = 0;
        //             exp_snp_resp.smi_cmstatus_dt_aiu = 0;
        //             exp_snp_resp.smi_cmstatus_dt_dmi = 0;
        		
    	// 	end
        end
        SNP_INV_DTR: begin
            if(WU_DT_PD_IS == 4'b1100 ||
               WU_DT_PD_IS == 4'b1110 ||
               (WU_DT_PD_IS == 4'b0100 &&
                m_snp_req_pkt.smi_up == SMI_UP_PRESENCE)) begin
                exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                exp_snp_resp.smi_cmstatus_dc     = 1;
            end
            if(WU_DT_PD_IS == 4'b0100 &&
		        m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
            	m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>) begin
                exp_snp_resp.smi_cmstatus_dt_aiu = 0;
                exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                exp_snp_resp.smi_cmstatus_dc     = 0;

	        end
            if(WU_DT_PD_IS == 4'b0110) begin
                if (m_snp_req_pkt.smi_up == SMI_UP_PRESENCE) begin
                    exp_snp_resp.smi_cmstatus_rv = 0;
                    exp_snp_resp.smi_cmstatus_rs = 0;
                    exp_snp_resp.smi_cmstatus_dc = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    exp_snp_resp.smi_cmstatus_dt_dmi = 0;
                end else if(m_snp_req_pkt.smi_up == SMI_UP_PERMISSION && m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>) begin
                    exp_snp_resp.smi_cmstatus_rv = 0;
                    exp_snp_resp.smi_cmstatus_rs = 0;
                    exp_snp_resp.smi_cmstatus_dc = 0;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 0;
                    exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                end
	        end
            
		// if(!(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
     	// 	m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>))) begin
        //             exp_snp_resp.smi_cmstatus_rv = 0;
        //             exp_snp_resp.smi_cmstatus_rs = 0;
    	// 	    exp_snp_resp.smi_cmstatus_dc = 0;
        //             exp_snp_resp.smi_cmstatus_dt_aiu = 0;
        //             exp_snp_resp.smi_cmstatus_dt_dmi = 0;
        		
    	// 	end
        end
        SNP_NOSDINT : begin
            case(WU_DT_PD_IS)
                4'b0001, 4'b1001: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_rs = 1;
                end
                4'b0100: begin
                    if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
                	m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>)) begin
                        exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    end
                end
                4'b1100: begin
                    exp_snp_resp.smi_cmstatus_dc = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                end
                4'b0101, 4'b1101: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                end
                4'b0110: begin
                    if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE) begin
                        exp_snp_resp.smi_cmstatus_dc = 1;
                        exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    end else begin
                        exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                        exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                    end
                end
                4'b1110: begin
                    exp_snp_resp.smi_cmstatus_dc = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                end
                4'b0111, 4'b1111: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_rs = 1;
                    exp_snp_resp.smi_cmstatus_dt_aiu = 1;
                    exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                end
            endcase
		// if(!(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
     	// 	m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>))) begin
        //             exp_snp_resp.smi_cmstatus_rv = 0;
        //             exp_snp_resp.smi_cmstatus_rs = 0;
    	// 	    exp_snp_resp.smi_cmstatus_dc = 0;
        //             exp_snp_resp.smi_cmstatus_dt_aiu = 0;
        //             exp_snp_resp.smi_cmstatus_dt_dmi = 0;
        		
    	// 	end
        end
        SNP_CLN_DTW : begin
            case(WU_DT_PD_IS)
                //CONC-6925
                /* 4'b0001: begin */
                /*     exp_snp_resp.smi_cmstatus_rv = 1; */
                /*     exp_snp_resp.smi_cmstatus_rs = 1; */
                /* end */
                4'b0001, 4'b1001, 4'b0101, 4'b1101: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                end
                4'b0110, 4'b1110: begin
                    exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                end
                4'b0111, 4'b1111: begin
                    exp_snp_resp.smi_cmstatus_rv = 1;
                    exp_snp_resp.smi_cmstatus_rs = 1;
                    exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                end
            endcase
        end
        //CONC-7381 - removing snp stash shared here
        /* SNP_STSH_SH : begin */
        /*     case(WU_DT_PD_IS) */
        /*         4'b0001: begin */
        /*             exp_snp_resp.smi_cmstatus_rv = 1; */
        /*         end */
        /*         4'b1001, 4'b0101, 4'b1101: begin */
        /*             exp_snp_resp.smi_cmstatus_rv = 1; */
        /*         end */
        /*         4'b0110, 4'b1110: begin */
        /*             /1* if(m_snp_req_pkt.smi_ca && *1/ */
        /*             /1*    m_snp_req_pkt.smi_ac) begin *1/ */
        /*                 exp_snp_resp.smi_cmstatus_dt_dmi = 1; */
        /*             /1* end *1/ */
        /*         end */
        /*         4'b0111, 4'b1111: begin */
        /*             /1* if(m_snp_req_pkt.smi_ca && *1/ */
        /*             /1*    m_snp_req_pkt.smi_ac) begin *1/ */
        /*                 exp_snp_resp.smi_cmstatus_rv = 1; */
        /*                 exp_snp_resp.smi_cmstatus_rs = 1; */
        /*                 exp_snp_resp.smi_cmstatus_dt_dmi = 1; */
        /*             /1* end *1/ */
        /*         end */
        /*     endcase */
        /* end */
        SNP_INV_DTW,
        SNP_UNQ_STSH : begin
            if(WU_DT_PD_IS == 4'b1110 ||
               WU_DT_PD_IS == 4'b0110 ) begin
                exp_snp_resp.smi_cmstatus_dt_dmi = 1;
            end
        end
        SNP_STSH_SH,
        SNP_STSH_UNQ : begin
            if(WU_DT_PD_IS == 4'b1110 ||
               WU_DT_PD_IS == 4'b0110 ) begin
               /* if(m_snp_req_pkt.smi_ca && */
               /*    m_snp_req_pkt.smi_ac) begin */
                    exp_snp_resp.smi_cmstatus_dt_dmi = 1;
                /* end */
            end
        end
    endcase
    exp_snp_resp.pack_smi_seq_item;
    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Exp SNPResp:%s",exp_snp_resp.convert2string()), UVM_MEDIUM);
    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Act SNPResp:%s",m_snp_rsp_pkt.convert2string()), UVM_MEDIUM);
    

	if (isACESnoopRespRecd && 
               (isSMIDTWReqNeeded == 0 && 
                isSMISNPDTRReqNeeded == 0) && 
                m_ace_snoop_resp_pkt.crresp[CCRRESPERRBIT] === 1 &&
                m_ace_snoop_resp_pkt.crresp[CCRRESPDATXFERBIT] == 0 &&
                m_snp_req_pkt.smi_msg_type != SNP_DVM_MSG) 
            begin
                if (exp_snp_resp.smi_cmstatus !== 8'b1000_0100) begin
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB_TXN ERROR", $sformatf("Expected to send cmstatus = 8'b1000_0100 (address error) in SNP_RSP for ACE snoop crresp error, Received smi_cmstatus = %0b",exp_snp_resp.smi_cmstatus))
                end
            end else if (isACESnoopRespRecd && 
                        (isSMIDTWReqNeeded || 
                         isSMISNPDTRReqNeeded) && 
                         m_ace_snoop_resp_pkt.crresp[CCRRESPERRBIT] === 1    &&
                         m_ace_snoop_resp_pkt.crresp[CCRRESPDATXFERBIT] == 0 && 
                         m_snp_req_pkt.smi_msg_type != SNP_DVM_MSG) 
            begin
                if (exp_snp_resp.smi_cmstatus[7:6] !== 2'b00) begin
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB_TXN ERROR", $sformatf("Expected Not to send error in SNP_RSP cmstatus for ACE snoop crresp error when AIU forward DTRreq/DTWreq, Received smi_cmstatus = %0b",exp_snp_resp.smi_cmstatus))
                end
            end


	if(!exp_snp_resp.compare(m_snp_rsp_pkt)) begin
	    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("#%s, SNP cmd_type = %s, WU_DT_PD_IS = 4''b%b,SNPResp Fields mismatching above!", id, snp_type.name(), WU_DT_PD_IS), UVM_NONE);
	    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","SNPResp Fields mismatching above!",UVM_NONE);
    end
endfunction : checkSnpResp

<% if(obj.useCache ||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
      
function void ioaiu_scb_txn::check_snp_dtr_type(int id);
   eMsgDTR exp_dtr_type,act_dtr_type;
   eMsgSNP snp_type;
   smi_tof_enum_t tof_cast;
   string s;
   bit 	  no_dtr_expected = 0;

//#Check.IOAIU.SMI.SNPDTRReq.DTRType
//#Check.IOAIU.SMI.DtrReq.CMType 
<% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
    case(m_snp_req_pkt.smi_msg_type)
        SNP_NITC   : begin
            if(m_snp_req_pkt.smi_tof == SMI_TOF_CHI ||
               m_snp_req_pkt.smi_tof == SMI_TOF_AXI) begin
                case(WU_DT_PD_IS)
                    4'b0000, 4'b1000, 4'b0001, 4'b1001: begin
                        no_dtr_expected = 1;
                    end
                    4'b0100: begin
                    	if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
                		m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>)) begin
                            exp_dtr_type = eDtrDataInv;
                        end else
                            no_dtr_expected = 1;
                    end
                    4'b1100, 4'b1101, 4'b0101: begin
                        exp_dtr_type = eDtrDataInv;
                    end
                    4'b0110, 4'b1110, 4'b0111, 4'b1111: begin
                        exp_dtr_type = eDtrDataInv;
                    end
                endcase
            end else if(m_snp_req_pkt.smi_tof == SMI_TOF_ACE) begin
                case(WU_DT_PD_IS)
                    4'b0000, 4'b1000, 4'b0001, 4'b1001: begin
                        no_dtr_expected = 1;
                    end
                    4'b0100: begin
                    	if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
                		m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>)) begin
                            exp_dtr_type = eDtrDataShrCln;
                        end else
                            no_dtr_expected = 1;
                    end
                    4'b1100, 4'b1101: begin
                        exp_dtr_type = eDtrDataInv;
                    end
                    4'b0101,4'b0110, 4'b1110, 4'b0111, 4'b1111: begin
                        exp_dtr_type = eDtrDataShrCln;
                    end
                endcase
            end
        end
        SNP_NITCCI, SNP_NITCMI : begin
            case(WU_DT_PD_IS)
                4'b0110, 4'b1110: begin
                    exp_dtr_type = eDtrDataInv;
                end
            endcase
        end
        SNP_CLN_DTR : begin
            case(WU_DT_PD_IS)
                4'b0100: begin
                    	if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
                		m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>)) begin
                        exp_dtr_type = eDtrDataShrCln;
                    end else
                        no_dtr_expected = 1;
                end
                4'b1100, 4'b1110: begin
                    exp_dtr_type = eDtrDataUnqCln;
                end
                4'b0101, 4'b1101, 4'b0110, 4'b0111, 4'b1111: begin
                    exp_dtr_type = eDtrDataShrCln;
                end
            endcase
        end
        SNP_VLD_DTR : begin
            case(WU_DT_PD_IS)
                4'b0100: begin
                    if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
                	m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>)) begin
                        exp_dtr_type = eDtrDataShrCln;
                    end else
                        no_dtr_expected = 1;
                end
                4'b1100: begin
                    exp_dtr_type = eDtrDataUnqCln;
                end
                4'b0101, 4'b1101: begin
                    exp_dtr_type = eDtrDataShrCln;
                end
                4'b0110: begin
                    if(m_snp_req_pkt.smi_up != SMI_UP_PRESENCE) begin
                        exp_dtr_type = eDtrDataShrDty;
                    end else
                        exp_dtr_type = eDtrDataUnqDty;
                end
                4'b1110: begin
                    exp_dtr_type = eDtrDataUnqDty;
                end
                4'b0111, 4'b1111: begin
                    exp_dtr_type = eDtrDataShrDty;
                end
            endcase
        end
        SNP_INV_DTR: begin
            if(WU_DT_PD_IS == 4'b1100 ||
               WU_DT_PD_IS == 4'b0100) begin
                exp_dtr_type = eDtrDataUnqCln;
            end else if (WU_DT_PD_IS == 4'b0110 ||
                         WU_DT_PD_IS == 4'b1110) begin
                exp_dtr_type = eDtrDataUnqDty;
            end else
                no_dtr_expected = 1;
            if(WU_DT_PD_IS == 4'b0100 &&
                    m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
                    m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>) begin 
                        no_dtr_expected = 1;
            end

        end
        SNP_NOSDINT : begin
            case(WU_DT_PD_IS)
                4'b0100: begin
                    if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
                	m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>)) begin
                        exp_dtr_type = eDtrDataShrCln;
                    end else
                        no_dtr_expected = 1;
                end
                4'b1100: begin
                    exp_dtr_type = eDtrDataUnqCln;
                end
                4'b0101, 4'b1101: begin
                    exp_dtr_type = eDtrDataShrCln;
                end
                4'b0110: begin
                    if(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE) begin
                        exp_dtr_type = eDtrDataUnqDty;
                    end else
                        exp_dtr_type = eDtrDataShrCln;
                end
                4'b1110: begin
                    exp_dtr_type = eDtrDataUnqDty;
                end
                4'b0111, 4'b1111: begin
                    exp_dtr_type = eDtrDataShrCln;
                end
            endcase
        end
        SNP_CLN_DTW,
        SNP_STSH_SH,
        SNP_UNQ_STSH,
        SNP_STSH_UNQ,
        SNP_INV_DTW: begin
            no_dtr_expected = 1;
        end
    endcase
    // if(!(m_snp_req_pkt.smi_up == SMI_UP_PRESENCE || (m_snp_req_pkt.smi_up == SMI_UP_PERMISSION &&
    //  m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.FUnitId%>))) begin
    // 	no_dtr_expected = 1;
    // end
   if(no_dtr_expected) begin
	s = $sformatf("Did not expect DTR for OutstTxn");
	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s #%0d because WU_DT_PD_IS = 4'b%b, UP = %p, AIU_ID(MPF3) = %h",s,id, WU_DT_PD_IS, m_snp_req_pkt.smi_up, m_snp_req_pkt.smi_mpf3_intervention_unit_id),UVM_NONE);
	uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",s,UVM_NONE);
   end
   $cast(act_dtr_type,m_dtr_req_pkt.smi_msg_type);
   if(act_dtr_type !== exp_dtr_type) begin
	$cast(snp_type,m_snp_req_pkt.smi_msg_type);
	s = $sformatf("DTR Type is wrong for OutstTxn");
	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s #%0d WU_DT_PD_IS = 4'b%b SNPType:%s, expDTRType:%s actDTRType:%s",s,id, WU_DT_PD_IS,snp_type.name(),exp_dtr_type.name(),act_dtr_type.name()),UVM_NONE);
	uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",s,UVM_NONE);
   end
<% } else if((fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %>
   bit [WSMINCOREUNITID-1:0] snp_req_mpf3 = m_snp_req_pkt.smi_mpf3_intervention_unit_id;
   bit [WSMIUP-1:0] snp_req_up = m_snp_req_pkt.smi_up;
   case(m_snp_req_pkt.smi_msg_type) 					      
	SNP_CLN_DTR : begin
	   case(m_ccp_ctrl_pkt.currstate)
		SD : exp_dtr_type = eDtrDataShrCln;
		SC : begin
			if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE))
				exp_dtr_type = eDtrDataShrCln;
			else
		   		no_dtr_expected = 1;			      
		     end	
		UC : exp_dtr_type = eDtrDataShrCln;
		UD : exp_dtr_type = eDtrDataShrCln;
		default : begin
		   no_dtr_expected = 1;			      
		end
	   endcase
	end
	SNP_NOSDINT : begin
	   case(m_ccp_ctrl_pkt.currstate)
		SD : exp_dtr_type = eDtrDataShrCln;
		SC : begin
			if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE))
				exp_dtr_type = eDtrDataShrCln;
			else
		   		no_dtr_expected = 1;			      
		     end	
		UC : exp_dtr_type = eDtrDataShrCln;
		UD : exp_dtr_type = eDtrDataShrCln;
		default : begin
		   no_dtr_expected = 1;
		end
	   endcase				      
	end
	SNP_VLD_DTR : begin
	   case(m_ccp_ctrl_pkt.currstate)
		SD : exp_dtr_type = eDtrDataShrDty;
		SC : begin
			if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE))
				exp_dtr_type = eDtrDataShrCln;
			else
		   		no_dtr_expected = 1;			      
		     end	
		UC : exp_dtr_type = eDtrDataShrCln;
		UD : exp_dtr_type = eDtrDataShrDty;
		default : begin
		   no_dtr_expected = 1;
		end
	   endcase				      
	end
	SNP_INV_DTR : begin
	   case(m_ccp_ctrl_pkt.currstate)
		SD : begin
			if(snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION)
		   		no_dtr_expected = 1;			      
			else if(snp_req_up == SMI_UP_PRESENCE)
				exp_dtr_type = eDtrDataUnqDty;
			else
				exp_dtr_type = eDtrDataUnqDty;
		     end	
		SC : begin
			if(snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION)
		   		no_dtr_expected = 1;			      
			else if(snp_req_up == SMI_UP_PRESENCE)
				exp_dtr_type = eDtrDataUnqCln;
			else
		   		no_dtr_expected = 1;			      
		     end	
		UC : exp_dtr_type = eDtrDataUnqCln;
		UD : exp_dtr_type = eDtrDataUnqDty;
		default : begin
		   no_dtr_expected = 1;
		end
	   endcase				      
	end
	SNP_CLN_DTR : begin
	   case(m_ccp_ctrl_pkt.currstate)
		SD : exp_dtr_type = eDtrDataInv;
		UC : exp_dtr_type = eDtrDataInv;
		UD : exp_dtr_type = eDtrDataInv;
		default : begin
		   no_dtr_expected = 1;
		end
	   endcase				      
	end
	SNP_NITC : begin
	   case(m_ccp_ctrl_pkt.currstate)
		SD : begin
		  //m_snp_req_pkt.smi_tof
		  if(m_snp_req_pkt.smi_tof == SMI_TOF_CHI) begin
		    exp_dtr_type = eDtrDataInv;
	          end
		  else if((m_snp_req_pkt.smi_tof == SMI_TOF_ACE) ||
			  (m_snp_req_pkt.smi_tof == SMI_TOF_AXI)) begin
		    exp_dtr_type = eDtrDataShrCln;
		  end
		  else begin
		    $cast(tof_cast, m_snp_req_pkt.smi_tof);
		    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("ERROR! Illegal TOF Value %s",tof_cast.name()),UVM_NONE);
		  end
		end
		SC : begin
			if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE)) begin
		  		if(m_snp_req_pkt.smi_tof == SMI_TOF_CHI) begin
		    			exp_dtr_type = eDtrDataInv;
	          		end
		  		else if((m_snp_req_pkt.smi_tof == SMI_TOF_ACE) ||
			  	(m_snp_req_pkt.smi_tof == SMI_TOF_AXI)) begin
		    			exp_dtr_type = eDtrDataShrCln;
		  		end
		  		else begin
		    			$cast(tof_cast, m_snp_req_pkt.smi_tof);
		    			uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("ERROR! Illegal TOF Value %s",tof_cast.name()),UVM_NONE);
		  		end
			end
			else
		   		no_dtr_expected = 1;
		end
		UC : exp_dtr_type = eDtrDataInv;
		UD : exp_dtr_type = eDtrDataInv;
		default : begin
		   no_dtr_expected = 1;
		end
	   endcase				      
	end
	SNP_NITCCI : begin
	   case(m_ccp_ctrl_pkt.currstate)
		SD : exp_dtr_type = eDtrDataInv;
		SC : begin
			if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE))
				exp_dtr_type = eDtrDataInv;
			else
		   		no_dtr_expected = 1;			      
		     end	
		UC : exp_dtr_type = eDtrDataInv;
		UD : exp_dtr_type = eDtrDataInv;
		default : begin
		   no_dtr_expected = 1;
		end
	   endcase				      
	end
	SNP_NITCMI : begin
	   case(m_ccp_ctrl_pkt.currstate)
		SD : exp_dtr_type = eDtrDataInv;
		SC : begin
			if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE))
				exp_dtr_type = eDtrDataInv;
			else
		   		no_dtr_expected = 1;			      
		     end	
		UC : exp_dtr_type = eDtrDataInv;
		UD : exp_dtr_type = eDtrDataInv;
		default : begin
		   no_dtr_expected = 1;
		end
	   endcase				      
	end
	default : begin
	   no_dtr_expected = 1;
	end
				      
   endcase				      
   if(no_dtr_expected) begin
	s = $sformatf("Did not expect DTR for OutstTxn");
	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s #%0d because it is in state %s",s,id,m_ccp_ctrl_pkt.currstate.name()),UVM_NONE);
	uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",s,UVM_NONE);
   end
   $cast(act_dtr_type,m_dtr_req_pkt.smi_msg_type);
   if(act_dtr_type !== exp_dtr_type) begin
	$cast(snp_type,m_snp_req_pkt.smi_msg_type);
	s = $sformatf("Did not expect DTR Type for OutstTxn");
	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s #%0d state:%s SNPType:%s, expDTRType:%s actDTRType:%s",s,id,m_ccp_ctrl_pkt.currstate.name(),snp_type.name(),exp_dtr_type.name(),act_dtr_type.name()),UVM_NONE);
	uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",s,UVM_NONE);
   end
					      
<% } %>
endfunction : check_snp_dtr_type

function void ioaiu_scb_txn::check_snp_dtr_attr(int id);
   string s;

   //  DtrReq Pri should match with the SnpReq pri bits
   //#Check.IOAIU.SMI.DtrReq.Priority
   if(m_dtr_req_pkt.smi_msg_pri !== m_snp_req_pkt.smi_msg_pri) begin // smi_qos
      s = $sformatf("DTR Pri is wrong for OutstTxn");
      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s #%0d SNPReq.Pri:%d, expDTRReq.Pri:%d actDTRReq.Pri:%d",s,id, m_snp_req_pkt.smi_msg_pri,m_snp_req_pkt.smi_msg_pri,m_dtr_req_pkt.smi_msg_pri),UVM_NONE);
      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf(" DTR Req Pri mismatch expDTRReq.Pri:%d actDTRReq.Pri:%d",m_snp_req_pkt.smi_msg_pri,m_dtr_req_pkt.smi_msg_pri), UVM_NONE);
   end
   if(m_dtr_req_pkt.smi_msg_pri !== addrMgrConst::qos_mapping(m_snp_req_pkt.smi_qos)) begin // smi_qos
      s = $sformatf("DTR Pri is not as per DTR Qos for OutstTxn");
      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s #%0d DtrReq.QoS:%d, expDTRReq.Pri:%d actDTRReq.Pri:%d",s,id, m_dtr_req_pkt.smi_qos,addrMgrConst::qos_mapping(m_snp_req_pkt.smi_qos),m_dtr_req_pkt.smi_msg_pri),UVM_NONE);
      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf(" DTR Req QoS and Pri mismatch DtrReq.QoS:%0d expDTRReq.Pri:%d actDTRReq.Pri:%d",m_dtr_req_pkt.smi_qos,addrMgrConst::qos_mapping(m_snp_req_pkt.smi_qos),m_dtr_req_pkt.smi_msg_pri), UVM_NONE);
   end

   //  DtrReq Pri should match with the SnpReq pri bits
   //#Check.IOAIU.SMI.DtrReq.RMsgID
   if(m_dtr_req_pkt.smi_rmsg_id !== m_snp_req_pkt.smi_mpf2_dtr_msg_id) begin // smi_rmsg_id
      s = $sformatf("DTR RMsgId is wrong for OutstTxn");
      uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s #%0d SNPReq.Mpf2:%d, expDTRReq.RmsgId:%d actDTRReq.RmsgId:%d",s,id, m_snp_req_pkt.smi_mpf2_dtr_msg_id,m_snp_req_pkt.smi_mpf2_dtr_msg_id,m_dtr_req_pkt.smi_rmsg_id),UVM_NONE);
      uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf(" DTR Req RMsgId mismatch expDTRReq.RMsgId:%d actDTRReq.RMsgId:%d",m_snp_req_pkt.smi_rmsg_id,m_dtr_req_pkt.smi_rmsg_id), UVM_NONE);
   end
endfunction : check_snp_dtr_attr
<% } %>

<% if(obj.useCache) { %>
      
function bit ioaiu_scb_txn::isWriteHit();
//   return (m_iocache_allocate === 1 && isWrite === 1 && is_ccp_hit === 1) || is_write_hit_upgrade;
   return (is_ccp_hit === 1) || is_write_hit_upgrade;
endfunction : isWriteHit

function bit ioaiu_scb_txn::noAllocateNotFinished();
	return !hasFatlErr && ((m_iocache_allocate == 0 && is_ccp_hit == 0 &&
		 is_write_hit_upgrade == 0 &&
                 (isRead|isWrite) && (isIoCacheEvict == 0) && 
                 (isFillReqd == 0)) ?
                ((isSMISTRReqNotNeeded==0 ? isSMISTRReqRecd==0 : 0)  ||
                 (isSMIDTRReqNeeded==1 ? isSMIDTRReqRecd == 0 : 0)    ||
                 (isSMIDTWReqNeeded==1 ? isSMIDTWRespRecd == 0 : 0)   
                 )
                : 0);	       
endfunction : noAllocateNotFinished

function bit ioaiu_scb_txn::allocateNotFinished();
	return !hasFatlErr && (((m_iocache_allocate || is_write_hit_upgrade) && isFillReqd) ? 
                ((isFillCtrlRcvd == 0) || (isFillDataRcvd==0)): 0);
endfunction : allocateNotFinished

function bit ioaiu_scb_txn::evictNotFinished();
	return !hasFatlErr && ((isIoCacheEvict ==1) &&
                ((isSMIUPDReqNeeded==1 ? isSMIUPDRespRecd == 0 : 0)  || 
                 (isSMIDTWReqNeeded==1 ? isSMIDTWRespRecd == 0 : 0))
                );
endfunction : evictNotFinished

function bit ioaiu_scb_txn::hitNotFinished();		       
	return !hasFatlErr && (((isRead|isWrite) && is_ccp_hit && (m_ccp_ctrl_pkt.nack || m_ccp_ctrl_pkt.cancel)) ? 
                (isRead && isCCPReadHitDataRcvd==0) || 
                (isWrite && isACEWriteDataRecd==0) : 0);
endfunction : hitNotFinished
		       
<% } %>					

function smi_msg_type_bit_t ioaiu_scb_txn::mapAceSnpToSNPreq (axi_acsnoop_t acsnoop);
    case(acsnoop)
        ACE_READ_ONCE                : $cast(mapAceSnpToSNPreq, eSnpNITC);
        ACE_READ_SHARED              : $cast(mapAceSnpToSNPreq, eSnpVldDtr);
        ACE_READ_CLEAN               : $cast(mapAceSnpToSNPreq, eSnpClnDtr);
        ACE_READ_NOT_SHARED_DIRTY    : $cast(mapAceSnpToSNPreq, eSnpNoSDInt);
        ACE_READ_UNIQUE              : $cast(mapAceSnpToSNPreq, eSnpInvDtr);
        ACE_CLEAN_SHARED             : $cast(mapAceSnpToSNPreq, eSnpClnDtw);
        ACE_CLEAN_INVALID            : $cast(mapAceSnpToSNPreq, eSnpInvDtw);
        ACE_MAKE_INVALID             : $cast(mapAceSnpToSNPreq, eSnpInv);
    endcase
endfunction : mapAceSnpToSNPreq

// CONC-8911: checking snoop address formatting
function void ioaiu_scb_txn::check_snoop_address(int ac_addr, int ac_datawidth);
    int addr_mask, sender_intf_size, receiver_intf_size;

    sender_intf_size   = (2**m_snp_req_pkt.smi_intfsize)*8;
    receiver_intf_size = ac_datawidth/8;
    addr_mask          = ~((2**((sender_intf_size > receiver_intf_size) ? $clog2(sender_intf_size) : $clog2(receiver_intf_size)))-1);

    if((ac_addr & addr_mask) !== (m_snp_req_pkt.smi_addr & addr_mask)) begin
       `uvm_error("SNP-ADDR-CHECK", $psprintf("[addr: (smi: 0x%08h) != (0x%08h :ace)] [intfsize: (smi: %4d) :: (%4d :ace)] [addr_mask: 0x%08h] [snptype: 0x%4h]", m_snp_req_pkt.smi_addr, ac_addr, sender_intf_size, receiver_intf_size, addr_mask[31:0], m_snp_req_pkt.smi_msg_type));
    end
    else begin
       `uvm_info("SNP-ADDR-CHECK", $psprintf("[addr: (smi: 0x%08h) == (0x%08h :ace)] [intfsize: (smi: %4d) :: (%4d :ace)] [addr_mask: 0x%08h] [snptype: 0x%4h]", m_snp_req_pkt.smi_addr, ac_addr, sender_intf_size, receiver_intf_size, addr_mask[31:0], m_snp_req_pkt.smi_msg_type), UVM_HIGH);
    end
endfunction: check_snoop_address

function int ioaiu_scb_txn::predict_smi_size(smi_addr_t addr);
  int smi_size;
  bit isExclusive = ((isRead && m_ace_read_addr_pkt.arlock == EXCLUSIVE) || (isWrite && m_ace_write_addr_pkt.awlock == EXCLUSIVE)) ? 1 : 0;
  int axlen  = isRead ? m_ace_read_addr_pkt.arlen  : ((isWrite || isUpdate) ? m_ace_write_addr_pkt.awlen : 0);
  int axsize = isRead ? m_ace_read_addr_pkt.arsize : ((isWrite|| isUpdate) ? m_ace_write_addr_pkt.awsize : 0);
  axi_axburst_t axburst = isRead ? m_ace_read_addr_pkt.arburst : ((isWrite || isUpdate) ? m_ace_write_addr_pkt.awburst : AXIFIXED);

  <%if(obj.useCache){%>
  if (csr_ccp_allocen && m_ccp_ctrl_pkt.alloc) begin
      smi_size = $clog2(SYS_nSysCacheline); //always access 64B on cache allocation
  end else if (isIoCacheEvict) begin
      smi_size = $clog2(SYS_nSysCacheline); //always evict full cacheline 64B
  end
  else if (isMntOp) begin
  <%} else {%>
  if (isMntOp) begin 
  <%}%>
    smi_size = $clog2(SYS_nSysCacheline); //maintenance op will flush full cacheline 64B
  end else if (isDVM) begin
    smi_size = $clog2(SYS_nSysCacheline); //full cacheline 64B for DvmOp
  end else if (isAtomic || isExclusive) begin 
    smi_size = $clog2((axlen + 1) * (2**axsize));
  end else if (addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DMI) begin 
    smi_size = $clog2(SYS_nSysCacheline); //always read/write full cacheline to DMI
  end else if (addrMgrConst::get_unit_type(dest_id) == addrMgrConst::DII) begin 
    smi_size = $clog2((axlen + 1) * (2**axsize));
    if ((axlen > 0) && (axburst == AXIINCR || isMultiAccess)) begin
        if ((<%=obj.wData%> == 64) && (addr[5:4] == 'b01)) begin
            smi_size = 6;
        end else if ((|addr[4:0] == 1) && (smi_size == 5)) begin
            smi_size = 6;
        end else if ((|addr[3:0] == 1) && (smi_size == 4)) begin
            smi_size = 5;
        end
    end
  end

  return smi_size;

endfunction:predict_smi_size

