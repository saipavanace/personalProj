//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

'use strict';

module.exports = {
    //------------------------------
    // Concerto System Parameters
    //------------------------------
    "wCacheLineOffset"           : 6,  // E
    "nAgentAius"                 : 4,  // E
    "nBridgeAius"                : 0,  // E
    "nMemRegions"                : 1,  // E
    "nSnoopFilterSlices"         : 1, // E
    "wSecurityAttribute"         : 1, // E

    "aiu0_NativeInterfaceName"   : "Interface 0", //E
    "aiu0_fnNativeInterface"     : "ACE", //E 
    "aiu0_szAgentCacheline"      : 64,    //E     
    "aiu0_szMaxCoherentRead"     : 64,    //E
    "aiu0_szMaxCoherentWrite"    : 64,  //E
    "aiu0_useSharerPromotion"    : "1", //E
    "aiu0_useWriteEvict"         : true, //E
    "aiu0_useBarriers"           : "1",  //E
    "aiu0_useDvm"                : "1",  //E
    "aiu0_nProcs"                : 2,  // E
    "aiu0_wAxId"                 : 6,  //E
    "aiu0_wAxAddr"               : 40,  //E
    "aiu0_wXData"                : 64, //E
    "aiu0_wCdData"               : 64, //E
    "aiu0_wAwUser"               : 0,  //E
    "aiu0_wWUser"                : 0,  //E
    "aiu0_wBUser"                : 0, //E
    "aiu0_wArUser"               : 0,  //E
    "aiu0_wRUser"                : 0,  //E
    "aiu0_useAceCache"           : "0", //E
    "aiu0_useAceProt"            : "0", //E
    "aiu0_useAceQos"             : "0", //E
    "aiu0_useAceRegion"          : "0", //E
    "aiu0_useAceDomain"          : "0", //E
    "aiu0_useAceUnique"          : "0", //E
    "aiu0_nOttCtrlEntries"       : 4,  //E
    "aiu0_nOttDataEntries"       : 4,    //E
    "aiu0_nOttStrbEntries"       : 4,    //E
    "aiu0_nCmdInFlight"          : 2,  //E
    "aiu0_nDvmInFlight"          : 1, //NC
    "aiu0_nDtrInFlight"          : 1,  //E
    "aiu0_nDtrInProcess"         : 1, 
    "aiu0_idSnoopFilterSlice"    : 0, //E
    "aiu0_wSfiMasterData"        : 64, //NC
    "aiu0_wSfiSlaveData"         : 64, //NC

    "aiu1_NativeInterfaceName"   : "Interface 2",
    "aiu1_fnNativeInterface"     : "ACE",
    "aiu1_szAgentCacheline"      : 64,
    "aiu1_szMaxCoherentRead"     : 64,
    "aiu1_szMaxCoherentWrite"    : 64,
    "aiu1_useSharerPromotion"    : "1",
    "aiu1_useWriteEvict"         : true,
    "aiu1_useBarriers"           : "1",
    "aiu1_useDvm"                : "1",
    "aiu1_nProcs"                : 2,
    "aiu1_wAxId"                 : 6,
    "aiu1_wAxAddr"               : 40,
    "aiu1_wXData"                : 64,
    "aiu1_wCdData"               : 64,
    "aiu1_wAwUser"               : 0,
    "aiu1_wWUser"                : 0,
    "aiu1_wBUser"                : 0,
    "aiu1_wArUser"               : 0, 
    "aiu1_wRUser"                : 0,
    "aiu1_useAceCache"           : "0",
    "aiu1_useAceProt"            : "0",
    "aiu1_useAceQos"             : "0",
    "aiu1_useAceRegion"          : "0",
    "aiu1_useAceDomain"          : "0",
    "aiu1_useAceUnique"          : "0",
    "aiu1_nOttCtrlEntries"       : 4,
    "aiu1_nOttDataEntries"       : 4,
    "aiu1_nOttStrbEntries"       : 4,
    "aiu1_nCmdInFlight"          : 2,
    "aiu1_nDvmInFlight"          : 1,
    "aiu1_nDtrInFlight"          : 1,
    "aiu1_nDtrInProcess"         : 1,
    "aiu1_idSnoopFilterSlice"    : 0,
    "aiu1_wSfiMasterData"        : 64,
    "aiu1_wSfiSlaveData"         : 64,

    "aiu2_NativeInterfaceName"   : "Interface 2",
    "aiu2_fnNativeInterface"     : "ACE",
    "aiu2_szAgentCacheline"      : 64,
    "aiu2_szMaxCoherentRead"     : 64,
    "aiu2_szMaxCoherentWrite"    : 64,
    "aiu2_useSharerPromotion"    : "1",
    "aiu2_useWriteEvict"         : true,
    "aiu2_useBarriers"           : "1",
    "aiu2_useDvm"                : "1",
    "aiu2_nProcs"                : 2,
    "aiu2_wAxId"                 : 6,
    "aiu2_wAxAddr"               : 40,
    "aiu2_wXData"                : 64,
    "aiu2_wCdData"               : 64,
    "aiu2_wAwUser"               : 0,
    "aiu2_wWUser"                : 0,
    "aiu2_wBUser"                : 0,
    "aiu2_wArUser"               : 0, 
    "aiu2_wRUser"                : 0,
    "aiu2_useAceCache"           : "0",
    "aiu2_useAceProt"            : "0",
    "aiu2_useAceQos"             : "0",
    "aiu2_useAceRegion"          : "0",
    "aiu2_useAceDomain"          : "0",
    "aiu2_useAceUnique"          : "0",
    "aiu2_nOttCtrlEntries"       : 4,
    "aiu2_nOttDataEntries"       : 4,
    "aiu2_nOttStrbEntries"       : 4,
    "aiu2_nCmdInFlight"          : 2,
    "aiu2_nDvmInFlight"          : 1,
    "aiu2_nDtrInFlight"          : 1,
    "aiu2_nDtrInProcess"         : 1,
    "aiu2_idSnoopFilterSlice"    : 0,
    "aiu2_wSfiMasterData"        : 64,
    "aiu2_wSfiSlaveData"         : 64,
 
    "aiu3_NativeInterfaceName"   : "Interface 2",
    "aiu3_fnNativeInterface"     : "ACE",
    "aiu3_szAgentCacheline"      : 64,
    "aiu3_szMaxCoherentRead"     : 64,
    "aiu3_szMaxCoherentWrite"    : 64,
    "aiu3_useSharerPromotion"    : "1",
    "aiu3_useWriteEvict"         : true,
    "aiu3_useBarriers"           : "1",
    "aiu3_useDvm"                : "1",
    "aiu3_nProcs"                : 2,
    "aiu3_wAxId"                 : 6,
    "aiu3_wAxAddr"               : 40,
    "aiu3_wXData"                : 64,
    "aiu3_wCdData"               : 64,
    "aiu3_wAwUser"               : 0,
    "aiu3_wWUser"                : 0,
    "aiu3_wBUser"                : 0,
    "aiu3_wArUser"               : 0, 
    "aiu3_wRUser"                : 0,
    "aiu3_useAceCache"           : "0",
    "aiu3_useAceProt"            : "0",
    "aiu3_useAceQos"             : "0",
    "aiu3_useAceRegion"          : "0",
    "aiu3_useAceDomain"          : "0",
    "aiu3_useAceUnique"          : "0",
    "aiu3_nOttCtrlEntries"       : 4,
    "aiu3_nOttDataEntries"       : 4,
    "aiu3_nOttStrbEntries"       : 4,
    "aiu3_nCmdInFlight"          : 2,
    "aiu3_nDvmInFlight"          : 1,
    "aiu3_nDtrInFlight"          : 1,
    "aiu3_nDtrInProcess"         : 1,
    "aiu3_idSnoopFilterSlice"    : 0,
    "aiu3_wSfiMasterData"        : 64,
    "aiu3_wSfiSlaveData"         : 64,

    "nDces"                      : 1, // E
    "dceSelectMask"              : "10", //E
    "dceHashMask"                : "100", //E

    "dce_nAttCtrlEntries": 8 , //E
    "dce_nSnpInFlight": 8, //E
    "dce_nMrdInFlight": 8, //E
    "dce_nTaggedMonitors": 0, //E
    "dce_useMemHints": 0, //E
    "dce_useCsrMemHints": 0, //E
    "dce_nDvmSnpInFlight": 1, //E
    "dce_nDvmRepInFlight": 1, //E

    "dce_nAttSkidEntries": 32,  
    
    "dce_nDtfSkidEntries": 4,
    
    "dce_wSfiSlaveTransId": 5,
    "dce_wSnoopingAiuId": 2,
    "dce_wSnpMsgId": 6,
    "dce_wStrMsgId": 6,
    "dce_wHntMsgId": 6,
    "dce_wMrdMsgId": 6,
    "dce_wDvmSnpTransId": 0,
    "dce_wDvmRepTransId": 0,
    "dce_wSfiMasterTransId": 9,

  // DCE Parameters
    "wDCE_MstTransID": 10 ,  //NC
    "wDCE_SlvTransID": 10,   //NC
   //folowing can be commmented out once we fix testbench
    "nATTSkidEntries": 8,    //NC
    "nATTEntries": 8,        //NC
    "nSBEntries": 32,        //NC
    "useMemHints": 0,        //NC
    "useCsrMemHints": 0,     //NC    


   
    "slice0_sliceName"           : "slice0",    //NC
    "slice0_fnSliceType"         : "TAGFILTER", //NC
    "slice0_useOwnerPointer"     : "1",        //NC
    "slice0_usePresenceVector"   : "1",        //NC
    "slice0_useImplicitOwnerVld" : "1",        //NC
    "slice0_nSetsFilter"         : 128,        //NC
    "slice0_nWaysFilter"         : 8,        //NC    
    "slice0_setSelectMask"       : "0400",    //NC
    "slice0_setHashMask"         : "0800",    //NC

    "memregion0_RegionName"      : "Region 0", //NC 
    "memregion0_wRegionAddr"     : 16,         //NC        
    "memregion0_nRegionPrefix"   : 1,        //NC
    "memregion0_nDmis"           : 1,        //NC
    "memregion0_dmiSelectMask"   : "000010",    //NC
    "memregion0_dmiHashMask"     : "0000100",    //NC

    "dmi0_fnNativeInterface"     : "Mem Interface 0",
    "dmi0_wSfiMasterData"        : 128,
    "dmi0_wSfiSlaveData"         : 128,
    "dmi0_nHttCtrlEntries"       : 16,     
    "dmi0_nRttCtrlEntries"       : 16,     
    "dmi0_nWttCtrlEntries"       : 16,     
    "dmi0_nDtrInFlight"          : 16,     
    "dmi0_nHntSlaveIds"          : 16,     
    "dmi0_nDtwSlaveIds"          : 16,        
    "dmi0_wAxData"               : 128,



    // SFI Parameters
    "wOpc": 1,
    "wBurstType": 1,
    "wAddr": 40,
    "wLength": 6,
    "wData": 128,
    "wProtBitsPerByte": 1,
    "wSFIQoS": 3,
    "wSFISlvID": 3,
    "wTransID": 10,
    "wMstTransID": 10,
    "wSlvTransID": 10,
    "wSFIPriv_MsgType": 5,
    "wSFIPriv_AIUTransID": 6,
    "wSFIPriv_AIUID": 3,
    "wSFIPriv_AceProcID": 2,
    "wSFIPriv_AceLock": 1,
    "wSFIPriv_AceProt": 3,
    "wSFIPriv_AceCache": 4,
    "wSFIPriv_AceQos": 4,
    "wSFIPriv_AceRegion": 4,
    "wSFIPriv_AceUser": 0,
    "wSFIPriv_AceDomain": 2,
    "wSFIPriv_AceUnique": 1,
    "wSFIPriv_Pad": 0,
    "wSecurity": 3,
    "wStatus": 1,
    "wErrCode": 3,
    "wSFIRspSFIPriv": 4,

    // System Parameters
    "nAIUs": 4,
    "nIOAIUs": 0,
    "nDCEs": 1,
    "nDMIs": 1,
    "dbg_singleTrans" : 0,

      // AIU Parameters
    "wAIU_MstTransID": 10,
    "wAIU_SlvTransID": 10,

    // DMI Parameters
    "wDMI_MstTransID": 10,
    "wDMI_SlvTransID": 10,
    "nHTTSkidEntries": 8,

    //------------------------------
    // Derived Parameters
    //------------------------------
    "nSlvs": 6,
    "nMsts": 6
};


