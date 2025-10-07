

<%

/*NOTE: Every change int this file must be ported to 
 * $WORK_TOP/dv/common/checker/src/sfi_priv.h
 * Changing only at one place will cause pseudo system tests to fail
 */

var topObj = {};
var cohAIUs = 0;
var aiuMaxProcs = 0;
var dceDtfSkidBufferSize = 0;
var i;
var maxUser = 0;

for (i = 0; i < obj.AiuInfo.length; i++) {
    if(obj.AiuInfo[i].fnNativeInterface === "ACE" && (!obj.AiuInfo[i].interleavedAgent)) {
        cohAIUs++;
    }
    maxUser = Math.max(maxUser, obj.AiuInfo[i].NativeInfo.SignalInfo.wAwUser);
    maxUser = Math.max(maxUser, obj.AiuInfo[i].NativeInfo.SignalInfo.wArUser);
}
for (i = 0; i < obj.AiuInfo.length; i++) {
    if(obj.AiuInfo[i].fnNativeInterface === "ACE" && (!obj.AiuInfo[i].interleavedAgent)) {
        aiuMaxProcs = Math.max(aiuMaxProcs, obj.AiuInfo[i].NativeInfo.nProcs);
    }
}
for (i = 0; i < obj.AiuInfo.length; i++) {
    if(obj.AiuInfo[i].fnNativeInterface === "ACE" && (!obj.AiuInfo[i].interleavedAgent)) {
        dceDtfSkidBufferSize = dceDtfSkidBufferSize + obj.AiuInfo[i].NativeInfo.DvmInfo.nDvmMsgInFlight;
    }
}

topObj.SYS_nSysCohAIUs     = cohAIUs; //Boon: was obj.nAIUs;
topObj.SYS_nSysAIUs        = obj.nAIUs;
//topObj.SYS_nSysAIUs        = obj.nAIUs + obj.nCBIs;
topObj.SYS_nSysAIUMaxProcs = aiuMaxProcs; //Boon: was obj.nAIUs;
topObj.SYS_nSysDCEs        = obj.nDCEs;
topObj.SYS_nSysDMIs        = obj.nDMIs;
topObj.SYS_nSysUnits       = obj.nAIUs + obj.nDCEs + obj.nDMIs;

topObj.wNumCachingAius = Math.ceil(Math.log(topObj.SYS_nSysCohAIUs + 1)/Math.LN2);

//topObj.SYS_wSysAddress     = obj.DceInfo[0].wSfiAddr;
//this is widest wAxAddr for agents DCTODO
//topObj.SYS_wSysAddress     = obj.DceInfo[0].wSfiAddr;
topObj.SYS_wSysAddress     = obj.AiuInfo[1].NativeInfo.SignalInfo.wAxAddr;
topObj.SYS_wSysCacheline   = obj.wCacheLineOffset;
topObj.SYS_nSysCacheline   = Math.pow(2, obj.wCacheLineOffset);
topObj.SYS_wSysDataBus     = obj.AiuInfo[1].NativeInfo.SignalInfo.wXData;

topObj.SYS_wSysMsgType     = 5;

topObj.DCE_nATTSkidEntries  = obj.DceInfo[0].CmpInfo.nAttSkidEntries;
topObj.DCE_nATTEntries      = obj.DceInfo[0].CmpInfo.nAttCtrlEntries;
topObj.DCE_nUpdSlaveIds     = obj.DceInfo[0].CmpInfo.nUpdSlaveIds;

// FIXME:  topObj only gets nSnpInFlight for Filter 0. It shuld reflect ALL filters.
//topObj.DCE_nSNPInflight     = obj.SnoopFilterInfo[0].CmpInfo.nSnpInFlight;

//topObj.DCE_nMRDInflight     = obj.DmiInfo[0].CmpInfo.nMrdInFlight;
topObj.DCE_nMRDInflight     = obj.DmiInfo[0].nMrdSkidBufSize;
topObj.DCE_nDTFSkidBufferSize = dceDtfSkidBufferSize;

//topObj.SFI_PRIV_MSG_TYPE_LSB       = obj.sfipriv_calc.msgType.lsb;
//topObj.SFI_PRIV_MSG_TYPE_MSB       = obj.sfipriv_calc.msgType.msb;
//topObj.SFI_PRIV_MSG_TYPE_WIDTH     = obj.sfipriv_calc.msgType.width;
//
////v2.0 additions
//topObj.SFI_PRIV_MSG_ATTR_LSB     = obj.sfipriv_calc.msgAttr.lsb;
//topObj.SFI_PRIV_MSG_ATTR_MSB     = obj.sfipriv_calc.msgAttr.msb;
//topObj.SFI_PRIV_MSG_ATTR_WIDTH   = obj.sfipriv_calc.msgAttr.width;
//
//topObj.SFI_PRIV_REQ_TRANS_ID_LSB   = obj.sfipriv_calc.aiuTransId.lsb;
//topObj.SFI_PRIV_REQ_TRANS_ID_MSB   = obj.sfipriv_calc.aiuTransId.msb;
//topObj.SFI_PRIV_REQ_TRANS_ID_WIDTH = obj.sfipriv_calc.aiuTransId.width;
//
//topObj.SFI_PRIV_REQ_AIU_ID_LSB     = obj.sfipriv_calc.aiuId.lsb;
//topObj.SFI_PRIV_REQ_AIU_ID_MSB     = obj.sfipriv_calc.aiuId.msb
//topObj.SFI_PRIV_REQ_AIU_ID_WIDTH   = obj.sfipriv_calc.aiuId.width;
//
//topObj.SFI_PRIV_REQ_AIU_PROCID_LSB   = obj.sfipriv_calc.aiuProcId.width ? obj.sfipriv_calc.aiuProcId.lsb : 0;
//topObj.SFI_PRIV_REQ_AIU_PROCID_MSB   = obj.sfipriv_calc.aiuProcId.width ? obj.sfipriv_calc.aiuProcId.msb : 0;
//topObj.SFI_PRIV_REQ_AIU_PROCID_WIDTH = obj.sfipriv_calc.aiuProcId.width ? obj.sfipriv_calc.aiuProcId.width : 1;
//
//topObj.SFI_PRIV_REQ_ACE_LOCK_LSB   = obj.sfipriv_calc.aceLock.width ? obj.sfipriv_calc.aceLock.lsb : 0;
//topObj.SFI_PRIV_REQ_ACE_LOCK_MSB   = obj.sfipriv_calc.aceLock.width ? obj.sfipriv_calc.aceLock.msb : 0;
//topObj.SFI_PRIV_REQ_ACE_LOCK_WIDTH = obj.sfipriv_calc.aceLock.width ? obj.sfipriv_calc.aceLock.width : 1;
//
////AceCache
//topObj.SFI_PRIV_REQ_ACE_CACHE_LSB   = obj.sfipriv_calc.aceCache.width ? obj.sfipriv_calc.aceCache.lsb : 0;
//topObj.SFI_PRIV_REQ_ACE_CACHE_MSB   = obj.sfipriv_calc.aceCache.width ? obj.sfipriv_calc.aceCache.msb : 0;
//topObj.SFI_PRIV_REQ_ACE_CACHE_WIDTH = obj.sfipriv_calc.aceCache.width ? obj.sfipriv_calc.aceCache.width : 1;
//
////AceProt
//topObj.SFI_PRIV_REQ_ACE_PROT_LSB   = obj.sfipriv_calc.aceProt.width ? obj.sfipriv_calc.aceProt.lsb : 0;
//topObj.SFI_PRIV_REQ_ACE_PROT_MSB   = obj.sfipriv_calc.aceProt.width ? obj.sfipriv_calc.aceProt.msb : 0;
//topObj.SFI_PRIV_REQ_ACE_PROT_WIDTH = obj.sfipriv_calc.aceProt.width ? obj.sfipriv_calc.aceProt.width : 1;
//
////AceQos
//topObj.SFI_PRIV_REQ_ACE_QOS_LSB    = obj.sfipriv_calc.aceQoS.width ? obj.sfipriv_calc.aceQoS.lsb : 0;
//topObj.SFI_PRIV_REQ_ACE_QOS_MSB    = obj.sfipriv_calc.aceQoS.width ? obj.sfipriv_calc.aceQoS.msb : 0;
//topObj.SFI_PRIV_REQ_ACE_QOS_WIDTH  = obj.sfipriv_calc.aceQoS.width ? obj.sfipriv_calc.aceQoS.width : 1;
//
////AceRegion
//topObj.SFI_PRIV_REQ_ACE_REGION_LSB   = obj.sfipriv_calc.aceRegion.width ? obj.sfipriv_calc.aceRegion.lsb : 0;
//topObj.SFI_PRIV_REQ_ACE_REGION_MSB   = obj.sfipriv_calc.aceRegion.width ? obj.sfipriv_calc.aceRegion.msb : 0;
//topObj.SFI_PRIV_REQ_ACE_REGION_WIDTH = obj.sfipriv_calc.aceRegion.width ? obj.sfipriv_calc.aceRegion.width : 1;
//
////AceDomain
//topObj.SFI_PRIV_REQ_ACE_DOMAIN_LSB   = obj.sfipriv_calc.aceDomain.width ? obj.sfipriv_calc.aceDomain.lsb : 0;
//topObj.SFI_PRIV_REQ_ACE_DOMAIN_MSB   = obj.sfipriv_calc.aceDomain.width ? obj.sfipriv_calc.aceDomain.msb : 0;
//topObj.SFI_PRIV_REQ_ACE_DOMAIN_WIDTH = obj.sfipriv_calc.aceDomain.width ? obj.sfipriv_calc.aceDomain.width : 1;
//
////AceUser
//topObj.SFI_PRIV_REQ_ACE_USER_LSB     = maxUser ? ((topObj.SFI_PRIV_REQ_ACE_DOMAIN_MSB > 0) ? topObj.SFI_PRIV_REQ_ACE_DOMAIN_MSB + 1 :
//                                               ((topObj.SFI_PRIV_REQ_ACE_REGION_MSB > 0) ? topObj.SFI_PRIV_REQ_ACE_REGION_MSB + 1 :
//                                               ((topObj.SFI_PRIV_REQ_ACE_QOS_MSB > 0)    ? topObj.SFI_PRIV_REQ_ACE_QOS_MSB + 1    :
//                                               ((topObj.SFI_PRIV_REQ_ACE_PROT_MSB > 0)   ? topObj.SFI_PRIV_REQ_ACE_PROT_MSB + 1   :
//                                               ((topObj.SFI_PRIV_REQ_ACE_CACHE_MSB > 0)  ? topObj.SFI_PRIV_REQ_ACE_CACHE_MSB + 1  :
//                                               ((topObj.SFI_PRIV_REQ_ACE_LOCK_MSB > 0)   ? topObj.SFI_PRIV_REQ_ACE_LOCK_MSB + 1   :
//                                               ((topObj.SFI_PRIV_REQ_AIU_PROCID_MSB > 0) ? topObj.SFI_PRIV_REQ_AIU_PROCID_MSB + 1 :
//                                                 topObj.SFI_PRIV_REQ_AIU_ID_MSB + 1))))))) : 0;
//topObj.SFI_PRIV_REQ_ACE_USER_MSB     = maxUser ? (topObj.SFI_PRIV_REQ_ACE_USER_LSB + maxUser - 1) : 0;
//topObj.SFI_PRIV_REQ_ACE_USER_WIDTH   = maxUser ? maxUser : 1;
//
////AceUnique
//
//topObj.SFI_PRIV_REQ_ACE_UNIQUE_LSB   = obj.sfipriv_calc.aceUnique.width ? obj.sfipriv_calc.aceUnique.lsb : 0;
//topObj.SFI_PRIV_REQ_ACE_UNIQUE_MSB   = obj.sfipriv_calc.aceUnique.width ? obj.sfipriv_calc.aceUnique.msb : 0;
//topObj.SFI_PRIV_REQ_ACE_UNIQUE_WIDTH = obj.sfipriv_calc.aceUnique.width ? obj.sfipriv_calc.aceUnique.width : 1;
//
//    
//topObj.SFI_PRIV_COHER_RESULT_LSB   = obj.sfipriv_calc.ST.lsb;
//topObj.SFI_PRIV_COHER_RESULT_MSB   = obj.sfipriv_calc.SO.msb;
//topObj.SFI_PRIV_COHER_RESULT_WIDTH = obj.sfipriv_calc.ST.width + obj.sfipriv_calc.SD.width
//                                   obj.sfipriv_calc.SO.width + obj.sfipriv_calc.SS.width;
//
//topObj.SFI_PRIV_SNOOP_RESULT_LSB   = 0;
//topObj.SFI_PRIV_SNOOP_RESULT_MSB   = 3;
//
//topObj.SFI_PRIV_TRANS_RESULT_LSB   = 0;
//topObj.SFI_PRIV_TRANS_RESULT_MSB   = 1;
//
//topObj.SFI_ADDR_REQ_TRANS_ID_LSB   = obj.wCacheLineOffset;
//topObj.SFI_ADDR_REQ_TRANS_ID_MSB   = topObj.SFI_ADDR_REQ_TRANS_ID_LSB + obj.sfipriv_calc.aiuTransId.width - 1;
//topObj.SFI_ADDR_REQ_TRANS_ID_WIDTH = obj.sfipriv_calc.aiuTransId.width;
//
//topObj.SFI_ADDR_REQ_AIU_ID_LSB     = topObj.SFI_ADDR_REQ_TRANS_ID_MSB + 1;
//topObj.SFI_ADDR_REQ_AIU_ID_MSB     = topObj.SFI_ADDR_REQ_AIU_ID_LSB   + obj.sfipriv_calc.aiuId.width - 1;
//topObj.SFI_ADDR_REQ_AIU_ID_WIDTH   = obj.sfipriv_calc.aiuId.width;
//
//topObj.SMI_ADDR_DVM_SYNC_BIT       = 13;
//topObj.SMI_ADDR_DVM_MULTIPART_BIT  = 12;
//
//topObj.SFI_PRIV_STR_ERR_RESULT_LSB   = obj.sfipriv_calc.ErrResult.lsb;
//topObj.SFI_PRIV_STR_ERR_RESULT_MSB   = obj.sfipriv_calc.ErrResult.msb;
//topObj.SFI_PRIV_STR_ERR_RESULT_WIDTH = obj.sfipriv_calc.ErrResult.width;
//
//topObj.SFI_PRIV_STR_ACE_EXOKAY_LSB   = obj.sfipriv_calc.AceExOkay.lsb;
//topObj.SFI_PRIV_STR_ACE_EXOKAY_MSB   = obj.sfipriv_calc.AceExOkay.msb;
//topObj.SFI_PRIV_STR_ACE_EXOKAY_WIDTH = obj.sfipriv_calc.AceExOkay.width;
//
////DTR offset
//topObj.SFI_PRIV_OFFSET_LSB       = obj.sfipriv_calc.offset.lsb;
//topObj.SFI_PRIV_OFFSET_MSB       = obj.sfipriv_calc.offset.msb;
//topObj.SFI_PRIV_OFFSET_WIDTH     = obj.sfipriv_calc.offset.width;
//topObj.SFI_PRIV_DTR_ERR_RESULT_LSB   = obj.sfiPriv.ErrResult.lsb;
//topObj.SFI_PRIV_DTR_ERR_RESULT_MSB   = obj.sfiPriv.ErrResult.msb;
//topObj.SFI_PRIV_DTR_ERR_RESULT_WIDTH = obj.sfiPriv.ErrResult.width;
//
//topObj.nHttSkidEntries = 4; // Aniket: topObj is hardcoded for v1
//
//
////v2.0 additions
//if(obj.useResiliency) {
//topObj.SFI_PRIV_ALLOC_MSB          = obj.sfiPriv.wSfiPrivWithResiliency;
//topObj.SFI_PRIV_ALLOC_LSB          = obj.sfiPriv.wSfiPrivWithResiliency;
//} else {
//topObj.SFI_PRIV_ALLOC_MSB          = obj.sfiPriv.width;
//topObj.SFI_PRIV_ALLOC_LSB          = obj.sfiPriv.width;
//}
//topObj.SFI_PRIV_ALLOC_WIDTH        = 1;
//if(obj.useResiliency) {
//topObj.SFI_PRIV_VIS_MSB            = obj.sfiPriv.wSfiPrivWithResiliency+1;
//topObj.SFI_PRIV_VIS_LSB            = obj.sfiPriv.wSfiPrivWithResiliency+1;
//} else {
//topObj.SFI_PRIV_VIS_MSB            = obj.sfiPriv.width+1;
//topObj.SFI_PRIV_VIS_LSB            = obj.sfiPriv.width+1;
//
//}
//topObj.SFI_PRIV_VIS_WIDTH          = 1;
//
//
//topObj.SFI_PRIV_MSG_ATTR_LSB       = obj.sfiPriv.msgAttr.lsb;
//topObj.SFI_PRIV_MSG_ATTR_MSB       = obj.sfiPriv.msgAttr.msb;
//topObj.SFI_PRIV_MSG_ATTR_WIDTH     = obj.sfiPriv.msgAttr.width;
//
//if (obj.useResiliency == 1) {
//    topObj.SFI_PRIV_PARITY_LSB     = obj.sfipriv_calc.width - 1 - obj.sfipriv_calc.wSfiPrivParity;
//    topObj.SFI_PRIV_PARITY_MSB     = obj.sfipriv_calc.width - 1;
//    topObj.SFI_PRIV_PARITY_WIDTH   = obj.sfipriv_calc.wSfiPrivParity;
//}

%>


<% for (var key in topObj) { %>
localparam int <%=key%> = <%=topObj[key]%>;
<% } %>
