//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------
"use strict";

module.exports.defineTopParams = function(m) {

    var u = require("../../lib/src/utils.js").init(m);  
    var i;
    var numBanks;
    var memoryName;



    // Concerto Constants 
    //  NOTE:  Concerto Concstnats are NOT in configuration files.

    //------------------------------------------------------------
    // Concerto Top-level Parameters 
    //------------------------------------------------------------

    // Optional top-level parameters
    u.paramDefault("Pinlists", "object", {} );
    u.paramDefault("NocStructures", "object", {});
    u.paramDefault("UnitTest", "string", "ALL");
    u.paramDefault("isCCPunit", "int", 0 );
    u.paramDefault("assertOn", "boolean", 0);
    u.paramDefault("perf", "boolean", 0);
    u.paramDefault("svnoc", "boolean", 0);
    u.paramDefault("generateRtl.structures[]", "string", "");
    u.paramDefault("generateRtl.targetLanguage", "string", "");
    u.paramDefault("generateRtl.simulator", "string", "");
    u.paramDefault("generateRtl.timescale", "string", "");
    u.paramDefault("generateRtl.exportVerification", "boolean", 0);
    u.paramDefault('genFromRoot', "boolean", 0);
    u.paramDefault('filter', "string", "");

    // Table 2: Concerto Top-Level Configuration Parameters
    u.param("verSysParams", "int", 1, 1);
    u.param("strProjectName", "string");      // CHECK
    u.param("wCacheLineOffset", "int", 6, 6);
    u.param("wSecurityAttribute", "int", 0, 1);
    u.param("useResiliency", "int", 0, 1);
    u.param("wPriorityLevel", "int", 0, 3);
    u.param("env.clocks[]", "int");

    u.param('FscInfo', 'object');

    // TODO: Validate the number of each Agent;

    // Note:  nAgents, nBridges, nSnoopFilters, nMemRegions are in the 
    // CSPS, but are not explicitly list here because they are derived 
    // from the size of the respective arrays.

    function addSelectInfo(prefix) {
        u.defineSelectParams(prefix);
//        u.param(prefix+".nSelectBits"   , "int"); // TODO: Validate
//        u.param(prefix+".SelectBits[]"  , "int"); // TODO: Validate
//        u.param(prefix+".HashBits[]"    , "int"); // TODO: Validate
//        u.param(prefix+".SelectTable[]" , "int"); // TODO: Validate

    }

    //------------------------------------------------------------
    // AIU Parameters
    //------------------------------------------------------------
    for (var type in {"AiuInfo":0,"BridgeAiuInfo":0}){

        // Table 3: AIU Top-Level Configuration Parameters
        u.param(type+"[].strRtlNamePrefix"                       , "string");
        u.param(type+"[].nAius"                                  , "int",     1, 2);  // (ACE Only) //TODO: 1 for ACE
        u.param(type+"[].fnNativeInterface"                      , "string",  ["ACE", "ACE-LITE"]);

        // From Decaf - not in Param Spec
        u.param(type+"[].specification"                          , "string");
        u.param(type+"[].clockPort"                              , "string");
        u.param(type+"[].resetPort"                              , "string");

        // Table 27: Selection Algorithm
        u.param(type+"[].fnAiuSelect"                            , "string",  ["TABLE"]); // (ACE Only)
        addSelectInfo(type+"[].AiuSelectInfo");

        // Table 5/7: ACE/ACE-Lite AIU Native Interface Configuration Parameters
        u.param(type+"[].NativeInfo.nProcs"                      , "int",     1, 4); // (ACE Only)
//        u.param(type+"[].NativeInfo.strAwidProcMask"             , "string"); // TODO: Change
        u.param(type+"[].NativeInfo.szAgentCacheLine"            , "int",     64, 64); // ACE Only
        u.param(type+"[].NativeInfo.szMaxCoherentRead"           , "int",     64, 4096);
        u.param(type+"[].NativeInfo.szMaxCoherentWrite"          , "int",     64, 4096);
        u.param(type+"[].NativeInfo.useSharerPromotion"          , "boolean");// ACE Only
        u.param(type+"[].NativeInfo.useWriteEvict"               , "boolean");// ACE only
        u.param(type+"[].NativeInfo.useBarriers"                 , "boolean");
        u.param(type+"[].NativeInfo.useDvm"                      , "boolean");
        u.param(type+"[].NativeInfo.isBridgeInterface"           , "boolean"); // ACE-Lite Only
        u.param(type+"[].NativeInfo.useIoCache"                  , "boolean"); //ACE-Lite Only
        u.param(type+"[].NativeInfo.useTransOrdering"            , "boolean"); //ACE-Lite Only
        addSelectInfo(type+"[].NativeInfo.AxIdProcSelectInfo");

        // Table 6/9: ACE/ACE-Lite AIU Signal Interface Configuration Parameters
        u.param(type+"[].NativeInfo.SignalInfo.wAxId"            , "int",  4, 12);
        u.param(type+"[].NativeInfo.SignalInfo.wAxAddr"          , "int", 32, 48);
        u.param(type+"[].NativeInfo.SignalInfo.wXData"           , "int", [64, 128, 256]);
        u.param(type+"[].NativeInfo.SignalInfo.wCdData"          , "int", 0, 128);  // ACE Only
        u.param(type+"[].NativeInfo.SignalInfo.wAwUser"          , "int", 0, 12);
        u.param(type+"[].NativeInfo.SignalInfo.wArUser"          , "int", 0, 12);
        u.param(type+"[].NativeInfo.SignalInfo.wWUser"           , "int", 0, 0);
        u.param(type+"[].NativeInfo.SignalInfo.wBUser"           , "int", 0, 0);
        u.param(type+"[].NativeInfo.SignalInfo.wRUser"           , "int", 0, 0);

        u.param(type+"[].NativeInfo.SignalInfo.useAceRegionPort" , "boolean");
        u.param(type+"[].NativeInfo.SignalInfo.useAceUniquePort" , "boolean");
        u.param(type+"[].NativeInfo.SignalInfo.useAceQosPort"    , "boolean");

        u.param(type+"[].NativeInfo.SignalInfo.useAceCache"      , "boolean");
        u.param(type+"[].NativeInfo.SignalInfo.useAceProt"       , "boolean");
        u.param(type+"[].NativeInfo.SignalInfo.useAceQos"        , "boolean");
        u.param(type+"[].NativeInfo.SignalInfo.useAceRegion"     , "boolean");
        u.param(type+"[].NativeInfo.SignalInfo.useAceDomain"     , "boolean");
        u.param(type+"[].NativeInfo.SignalInfo.useAceUnique"     , "boolean"); // ACE Only

        // Table 10: AIU Messaging Protocol Parameters
        u.param(type+"[].CmpInfo.nOttCtrlEntries"                                   , "int", 16, 64);
        u.param(type+"[].CmpInfo.nOttDataEntries"                                   , "int", 4, 64);
        u.param(type+"[].CmpInfo.nOttStrbEntries"                                   , "int");
        u.param(type+"[].CmpInfo.nCmdInFlight"                                      , "int", 1, 16);
        u.param(type+"[].CmpInfo.nDtrInFlight"                                      , "int", 0, 16);
        u.param(type+"[].CmpInfo.nUpdInFlight"                                      , "int"); // TODO: DO we need this?
        u.param(type+"[].CmpInfo.nDvmMsgInFlight"                                   , "int", 0, 1);
        u.param(type+"[].CmpInfo.nDvmCmpInFlight"                                   , "int", 0, 1);
        u.param(type+"[].CmpInfo.nDtrSlaveIds"                                      , "int", 1, 16);
        u.param(type+"[].CmpInfo.idSnoopFilterSlice"                                , "int", 0, 1);
        u.param(type+"[].CmpInfo.OttDataErrorInfo.fnErrDetectCorrect"               , "string");

        // Table 11: AIU SFI Configuration Parameters
        u.param(type+"[].SfiInfo.wMasterData"                                       , "int");
        u.param(type+"[].SfiInfo.wSlaveData"                                        , "int");

        // These are calculated SFI parameters and are not in the Arch specification.
        u.param(type+"[].Derived.wSfiAddr"                                          , "int");
        u.param(type+"[].Derived.wSfiSlvId"                                         , "int");
        u.param(type+"[].Derived.wProtBitsPerByte"                                  , "int");
        u.param(type+"[].Derived.wSfiData"                                          , "int");
        u.param(type+"[].Derived.wSfiSlaveTransId"                                  , "int");
        u.param(type+"[].Derived.wSfiMasterTransId"                                 , "int");
        u.param(type+"[].Derived.nSysCohWindowPrefix"                               , "int");
        u.param(type+"[].Derived.nPendingTransactions"                              , "int");

        // Derived SfiPriv
//        module.exports.defineSfiPrivParams(m,type+"[].Derived.");

        numBanks = 2;
        for (var z = 0; z < numBanks; z++) {
            declareMemoryParamsTop(type+'[].DataMem' + z);
        }

    }   // aiuType

    // useBypassPipeStage is only in Agent AIU's
    u.param("AiuInfo[].Derived.useBypassPipeStage", "int");

    //------------------------------------------------------------
    // Snoop Filter Parameters
    //------------------------------------------------------------

    // Table 12: Snoop Filter Top-Level Configuration Parameters
    u.param("SnoopFilterInfo[].strRtlNamePrefix"                                    , "string");
    u.param("SnoopFilterInfo[].fnFilterType"                                        , "string");
//    for (i...)
//if (SnoopFilterInfo[i].fnFilterType == "TAGFILTER") {
//    // Table 14: Tag Filter Segment Configuration Parameters
//    u.param("SnoopFilterInfo[i].StorageInfo. fnTagFilterType"                                     , "string");
//    u.param("SnoopFilterInfo[i].StorageInfo.nSets"                                   , "int");
//    u.param("SnoopFilterInfo[i].StorageInfo.nWays"                                   , "int");
//    u.param("SnoopFilterInfo[i].StorageInfo.fnSetSelect"                             , "string", ["TABLE"]);
//
//}
//}

    // Table 14: Tag Filter Segment Configuration Parameters
    u.param("SnoopFilterInfo[].StorageInfo.fnTagFilterType"                                     , "string");
    u.param("SnoopFilterInfo[].StorageInfo.nSets"                                   , "int", 1, 1048576);
    u.param("SnoopFilterInfo[].StorageInfo.nWays"                                   , "int", 1, 16);
    u.param("SnoopFilterInfo[].StorageInfo.fnSetSelect"                             , "string", ["TABLE"]);

    // Table 27: Selection Algorithm
    addSelectInfo("SnoopFilterInfo[].StorageInfo.SetSelectInfo");

    // Table 30: Error Detection & Correction Parameters
    u.param("SnoopFilterInfo[].StorageInfo.TagFilterErrorInfo.fnErrDetectCorrect"   , "string");

    // Table 15: Snoop Filte Messaging Protocol Configuration Parameters
    u.param("SnoopFilterInfo[].CmpInfo.nSnpInFlight"                                , "int", 1);
    u.param("SnoopFilterInfo[].CmpInfo.useMemHints"                                 , "boolean");

    var snoopFilterCount = 0;
    for (var snoopNum = 0; snoopNum < m.param.SnoopFilterInfo.length; snoopNum++) {
        if (m.param.SnoopFilterInfo[snoopNum].fnFilterType === "TAGFILTER") {
            snoopFilterCount++;
        }
    }
    if (snoopFilterCount === m.param.SnoopFilterInfo.length) {
        if (snoopFilterCount > 0) {
            declareMemoryParamsTop('SnoopFilterInfo[].TagMem');
        }
    } else {
        for (var snoopNum = 0; snoopNum < m.param.SnoopFilterInfo.length; snoopNum++) {
            if (m.param.SnoopFilterInfo[snoopNum].fnFilterType == "TAGFILTER") {
                declareMemoryParamsTop('SnoopFilterInfo[' + snoopNum + '].TagMem');
            }
        }
    }
 
    //------------------------------------------------------------
    // DCE Info
    //------------------------------------------------------------

    // Table 16: DCE Top-Level Configuration Parameters
    u.param("DceInfo.nDces"                                                         , "int", 1, 2);
    u.param("DceInfo.fnDceSelect"                                                   , "string", ["TABLE"]);

    // From DeCAF
    u.param("DceInfo.clockPort"                                                   , "string");
    u.param("DceInfo.resetPort"                                                   , "string");
    

    // Table 27: Selection Algorithm
    addSelectInfo("DceInfo.DceSelectInfo");

    // Table 17: DCE Messaging Protocol Configuration Parameters
    u.param("DceInfo.CmpInfo.nAttCtrlEntries"                                       , "int", 16, 64);
    u.param("DceInfo.CmpInfo.nUpdSlaveIds"                                          , "int", 0, 32);
    u.param("DceInfo.CmpInfo.nTaggedMonitors"                                       , "int");

    // Table 18: DCE DVM Message Transaction Configuration Parameters
    u.param("DceInfo.DvmInfo.nDvmSnpInFlight"                                       , "int", 0, 1);
    u.param("DceInfo.DvmInfo.nDvmRepInFlight"                                       , "int", 0, 1);
    u.param("DceInfo.DvmInfo.nDtfEntries"                                           , "int", 0, 16);

    // These are calculated SFI parameters and are not in the Arch specification.
    u.param("DceInfo.Derived.wSfiAddr"                                              , "int");
    u.param("DceInfo.Derived.wSfiSlvId"                                             , "int");   
    u.param("DceInfo.Derived.wProtBitsPerByte"                                      , "int");
    u.param("DceInfo.Derived.wSfiData"                                              , "int");
    u.param("DceInfo.Derived.wSfiSlaveTransId"                                      , "int");
    u.param("DceInfo.Derived.wSfiMasterTransId"                                     , "int");
    u.param("DceInfo.Derived.nAttSkidEntries"                                     , "int");

    // Derived SfiPriv

    //------------------------------------------------------------
    // Memory Region Info
    //------------------------------------------------------------

    // Table 19:: Memory Region Top-Level Parameters
    // Removed from 2.0
    // u.param("MemRegionInfo[].strRtlNamePrefix"                                      , "string");
    // u.param("MemRegionInfo[].wRegionAddr"                                           , "int", 12, 48);
    // u.param("MemRegionInfo[].nRegionPrefix"                                         , "int", 0); // TODO: Check Max

    // Table 20: Memory Region Messaging Protocol Configuration Parameters
    // Removed from 2.0
    //u.param("MemRegionInfo[].CmpInfo.nMrdInFlight"                                  , "int",1 ,16);

    //------------------------------------------------------------
    // DMI Top-Level Parameters
    //------------------------------------------------------------

    // Table 21: DMI Top-Level Configuration Parameters
    u.param("DmiInfo[].strRtlNamePrefix"                                      , "string");
    u.param("DmiInfo[].nDmis"                                                       , "int", 1, 2);
    u.param("DmiInfo[].fnNativeInterface"                                           , "string");
    u.param("DmiInfo[].fnDmiSelect"                                                 , "string", ["TABLE"]);

    // From Decaf - not in Param Spec
    u.param("DmiInfo[].specification"                                         , "string");
    u.param("DmiInfo[].clockPort"                                         , "string");
    u.param("DmiInfo[].resetPort"                                         , "string");

    // Table 27: Selection Algorithm
    addSelectInfo("DmiInfo[].DmiSelectInfo");

    // Memory Region Parameters
    u.param("DmiInfo[].MemRegionInfo.nSizeBytes", "int");
    u.param("DmiInfo[].MemRegionInfo.nBaseAddr", "int");
    u.param("DmiInfo[].MemRegionInfo.usePackedAddr", "int", 0, 1);

    // Table 23: DMI SFI Interface Configuration Parameters
    u.param("DmiInfo[].SfiInfo.wMasterData"                                         , "int");
    u.param("DmiInfo[].SfiInfo.wSlaveData"                                          , "int");

    // Table 24: DMI Messaging Protocol Configuration Parameters
    u.param("DmiInfo[].CmpInfo.nMrdInFlight"                                        , "int", 1 ,16);
    u.param("DmiInfo[].CmpInfo.nHttCtrlEntries"                                     , "int", 0, 64);
    u.param("DmiInfo[].CmpInfo.nRttCtrlEntries"                                     , "int", 4, 64);
    u.param("DmiInfo[].CmpInfo.useRttDataEntries"                                   , "boolean");
    u.param("DmiInfo[].CmpInfo.useSharedHttRtt"                                     , "boolean");
    u.param("DmiInfo[].CmpInfo.useMemRspIntrlv"                                     , "boolean");
    u.param("DmiInfo[].CmpInfo.nWttCtrlEntries"                                     , "int", 4, 64);
    u.param("DmiInfo[].CmpInfo.nDtrInFlight"                                        , "int", 1, 16);
    u.param("DmiInfo[].CmpInfo.nHntSlaveIds"                                        , "int", 0, 16);
    u.param("DmiInfo[].CmpInfo.nDtwSlaveIds"                                        , "int");

    // Table 30: Error Detection & Correction Parameters
    u.param("DmiInfo[].CmpInfo.HttDataErrorInfo.fnErrDetectCorrect"                 , "string");

    // Table 30: Error Detection & Correction Parameters
    u.param("DmiInfo[].CmpInfo.RttDataErrorInfo.fnErrDetectCorrect"                 , "string");

    // Table 25: DMI AXI Native Interface Configuration Parameters
    // Table 26: DMI AXI Signal Interface Configuration Parameters
    u.param("DmiInfo[].NativeInfo.SignalInfo.wXData"                                , "int");

    // These are derived by software and are not in the Arch specification.
    u.param("DmiInfo[].Derived.wSfiAddr"                                              , "int");
    u.param("DmiInfo[].Derived.wSfiSlvId"                                             , "int");   
    u.param("DmiInfo[].Derived.wProtBitsPerByte"                                      , "int");
    u.param("DmiInfo[].Derived.wSfiData"                                              , "int");
    u.param("DmiInfo[].Derived.wSfiSlaveTransId"                                      , "int");
    u.param("DmiInfo[].Derived.wSfiMasterTransId"                                     , "int");
    u.param("DmiInfo[].Derived.wArId"                                                 , "int");
    u.param("DmiInfo[].Derived.wAwId"                                                 , "int");
    u.param("DmiInfo[].Derived.wAxAddr"                                               , "int");
    u.param("DmiInfo[].Derived.wXData"                                                , "int");
    u.param("DmiInfo[].Derived.wAwUser"                                               , "int");
    u.param("DmiInfo[].Derived.wArUser"                                               , "int");
    u.param("DmiInfo[].Derived.wWUser"                                                , "int");
    u.param("DmiInfo[].Derived.wBUser"                                                , "int");
    u.param("DmiInfo[].Derived.wRUser"                                                , "int");

    u.param("DmiInfo[].Derived.useAceRegionPort"                         , "int");
    u.param("DmiInfo[].Derived.useAceUniquePort"                          , "int");
    u.param("DmiInfo[].Derived.useAceQosPort"                           , "int");

    u.param("DmiInfo[].Derived.useAceCache"                                           , "boolean");
    u.param("DmiInfo[].Derived.useAceProt"                                            , "boolean");
    u.param("DmiInfo[].Derived.useAceQos"                                             , "boolean");
    u.param("DmiInfo[].Derived.useAceRegion"                                          , "boolean");
    u.param("DmiInfo[].Derived.useAceUser"                                            , "boolean");
    u.param("DmiInfo[].Derived.useAceDomain"                                          , "boolean");
    u.param("DmiInfo[].Derived.useAceUnique"                                          , "boolean");

    var nRttBuffersCount = 0;
    for (var dmiNum = 0; dmiNum < m.param.DmiInfo.length; dmiNum++) {
        if (m.param.DmiInfo[dmiNum].CmpInfo.useRttDataEntries) {
            nRttBuffersCount++;
        }
    }
    if (nRttBuffersCount === m.param.DmiInfo.length) {
        if (nRttBuffersCount > 0) {
            declareMemoryParamsTop('DmiInfo[].RttDataMem');
        }
    } else {
        for (var dmiNum = 0; dmiNum < m.param.DmiInfo.length; dmiNum++) {
            if (m.param.DmiInfo[dmiNum].CmpInfo.useRttDataEntries) {
                declareMemoryParamsTop('DmiInfo[' + dmiNum + '].RttDataMem');
            }
        }
    }

    var nHttBuffersCount = 0;
    for (var dmiNum = 0; dmiNum < m.param.DmiInfo.length; dmiNum++) {
        if (m.param.DmiInfo[dmiNum].CmpInfo.nHttCtrlEntries > 0) {
            nHttBuffersCount++;
        }
    }
    if (nHttBuffersCount === m.param.DmiInfo.length) {
        if (nHttBuffersCount > 0) {
            declareMemoryParamsTop('DmiInfo[].HttDataMem');
        }
    } else {
        for (var dmiNum = 0; dmiNum < m.param.DmiInfo.length; dmiNum++) {
            if (m.param.DmiInfo[dmiNum].CmpInfo.nHttCtrlEntries > 0) {
                declareMemoryParamsTop('DmiInfo[' + dmiNum + '].HttDataMem');
            }
        }
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // For each Bridge, only expect IoCache 
    // elements if useIoCache is true.
    var useIoCacheCount = 0;
    for (var bridgeNum = 0; bridgeNum < m.param.BridgeAiuInfo.length; bridgeNum++) {
        if (m.param.BridgeAiuInfo[bridgeNum].NativeInfo.useIoCache === 1) {
            useIoCacheCount++;
        }
    }
    if (useIoCacheCount === m.param.BridgeAiuInfo.length) {
        if (useIoCacheCount > 0) {
            declareIoCacheParams('');
        }
    } else {
        for (var bridgeNum = 0; bridgeNum < m.param.BridgeAiuInfo.length; bridgeNum++) {
            if (m.param.BridgeAiuInfo[bridgeNum].NativeInfo.useIoCache == 1) {
                declareIoCacheParams(bridgeNum);
            }
        }
    }

    function declareIoCacheParams(bridgeNum) {
        u.param("BridgeAiuInfo[" + bridgeNum + "].NativeInfo.IoCacheInfo.nSets"           , "int", 1, 1024); // ACE Only
        u.param("BridgeAiuInfo[" + bridgeNum + "].NativeInfo.IoCacheInfo.nWays"           , "int", 1, 16); // ACE Only
        u.param("BridgeAiuInfo[" + bridgeNum + "].NativeInfo.IoCacheInfo.fnSetSelect"     , "string", ["TABLE"]); // ACE Only
        u.param("BridgeAiuInfo[" + bridgeNum + "].NativeInfo.IoCacheInfo.nUttCtrlEntries" , "int"); // ACE Only
        u.param("BridgeAiuInfo[" + bridgeNum + "].NativeInfo.IoCacheInfo.nCttCtrlEntries" , "int", 4, 64); // ACE Only
        // Table 27: Selection Algorithm
        addSelectInfo("BridgeAiuInfo[" + bridgeNum + "].NativeInfo.IoCacheInfo.SetSelectInfo");

        // Table 30: Error Detection & Correction Parameters
        u.param("BridgeAiuInfo[" + bridgeNum + "].NativeInfo.IoCacheInfo.IoTagErrorInfo.fnErrDetectCorrect"  , "string");

        // Table 30: Error Detection & Correction Parameters
        u.param("BridgeAiuInfo[" + bridgeNum + "].NativeInfo.IoCacheInfo.IoDataErrorInfo.fnErrDetectCorrect" , "string");
        if (bridgeNum) {
            numBanks = Math.pow(2, m.param.wCacheLineOffset) * 8 / m.param.BridgeAiuInfo[bridgeNum].SfiInfo.wMasterData;
        } else {
            numBanks = Math.pow(2, m.param.wCacheLineOffset) * 8 / m.param.BridgeAiuInfo[0].SfiInfo.wMasterData;
        }
        //u.log ('Num Banks is ' + numBanks);
        for (var z = 0; z < numBanks; z++) {
            declareMemoryParamsTop('BridgeAiuInfo[' + bridgeNum + '].NativeInfo.IoCacheInfo.DataMem' + z);
        }
        declareMemoryParamsTop('BridgeAiuInfo[' + bridgeNum + '].NativeInfo.IoCacheInfo.TagMem');
    }


    // Derived SfiPriv
//    module.exports.defineSfiPrivParams(m,"DmiInfo[].Derived.");

    module.exports.defineSfiPrivParams(m,"Derived.");

    function declareMemoryParamsTop(memoryName) {
        //u.log("declareMemoryParamsTop");
        u.param(memoryName + '.rtlPrefixString', 'string');
        u.param(memoryName + '.memoryType', 'string');
        u.param(memoryName + '.signals[].name', 'string');
        u.param(memoryName + '.signals[].width', 'int');
        u.param(memoryName + '.signals[].direction', 'string');
    }

    //============================================================
    // Parameter Validation
    //============================================================
    function isPowerOfTwo(x) {
        return !(x == 0) && !(x & (x - 1));
    }

    function validateSelectInfo(thing) {

// TODO: Delete these obsolete TABLE select checks, and add checks for newer-style GENERAL select.

        if (thing.nRsrcIdxBits !== thing.PriSubDiagAddrBits.length) {
// TODO: Uncomment            u.paramError("SelectBits[] length doesn't match nSelectBits:\n"+JSON.stringify(thing, null, 4));
        }
        if ((thing.nRsrcIdxBits !== Object.keys(thing.SecSubRows).length) & (Object.keys(thing.SecSubRows).length != 0)) {
            u.paramError("HashBits[] length doesn't match nSelectBits");
        }
        var overLap = 0;
        for(let s of thing.PriSubDiagAddrBits) {
        //    for(let h of thing.SecSubRows[s]) {
            for(var z=0 ; z<thing.SecSubRows.length; z++) { h = thing.SecSubRows["z"] ;
                for(let k of h ) {
                    if (s==k) {
                            overLap = 1;
                    }
                }
            }
        }
        if (overLap) {
            u.paramError("A bit in DiagBits[] is also in SecBits[]");
        }
    }


    //========================================
    // Check Number of Agents
    //
//    if ((m.param.AiuInfo.length + m.param.BridgeAiuInfo.length) > 6){
//        u.paramError("There cannot be more than 6 Agents.");
//    }

 //   if (m.param.BridgeAiuInfo.length > 4){
 //       u.paramError("There cannot be more than 4 Bridge Agents.");
 //   }

 //   if (m.param.SnoopFilterInfo.length > 6){
 //       u.paramError("There cannot be more than 6 Snoop Filters.");
 //   }

 //   if (m.param.MemRegionInfo.length > 6){
 //       u.paramError("There cannot be more than 6 Memory Regions.");
 //   }

    //========================================
    // Check top-level Array Sizes
    //
//    if (m.param.MemRegionInfo.length !== m.param.DmiInfo.length){
//        u.paramError("Memory Array length & DMI Array Length must be the same size.");
//    }

//    if (m.param.SnoopFilterInfo.length !== m.param.DceInfo.length){
//        u.paramError("Snoop Filter Array length & DCE Array Length must be the same size.");
//    }

    var totalNumProcs = 0;

    //========================================
    // Agent Interface Checks
    //
    for (var aiu = 0; aiu < m.param.AiuInfo.length; aiu++){
        var agentInfo = m.param.AiuInfo[aiu];
        totalNumProcs = totalNumProcs + agentInfo.NativeInfo.nProcs;

        validateSelectInfo(agentInfo.AiuSelectInfo);

        if (agentInfo.isBridgeInterface){
            u.paramError("Agent Interfaces cannot be bridges.");
        }

        if (agentInfo.useIoCache){
            u.paramError("Agent Interfaces cannot have IO Caches.");
        }

        if (agentInfo.fnNativeInterface == "ACE") {
            if (agentInfo.NativeInfo.szMaxCoherentRead != 64) {
                u.paramError("Agent Interfaces must have szMaxCoherentRead = 64");
            }

            if (agentInfo.NativeInfo.szMaxCoherentWrite != 64) {
                u.paramError("Agent Interfaces must have szMaxCoherentWrite = 64");
            }

            if (agentInfo.NativeInfo.SignalInfo.wXData != agentInfo.NativeInfo.SignalInfo.wCdData) {
                u.paramError("Agent RData & WData width must match CdData width.");
            }

        }
        if ([64, 128, 256].indexOf(agentInfo.NativeInfo.SignalInfo.wXData) == -1) {
            u.paramError("Agent Data Width must be 64, 128, or 256.");
        }


        if (agentInfo.fnNativeInterface == "ACE" ) {
            if (agentInfo.CmpInfo.nOttDataEntries < 4) {
                u.paramError("For ACE Interfaces, nOttDataEntries must be at least 4.");
            }
            if (agentInfo.NativeInfo.AxIdProcSelectInfo) {
            //    validateSelectInfo(agentInfo.NativeInfo.AxIdProcSelectInfo);
            }
        } else {
            if (agentInfo.CmpInfo.nOttDataEntries > 0) {
                if (agentInfo.CmpInfo.nOttDataEntries != agentInfo.CmpInfo.nOttCtrlEntries) {
                    u.paramError("For ACE-Lite Interfaces, nOttDataEntries must equal nOttCtrlEntries.");
                }
            }
        }

        if (agentInfo.CmpInfo.nOttStrbEntries != agentInfo.CmpInfo.nOttStrbEntries) {
            u.paramError("nOttStrbEntries must equal nOttCtrlEntries.");
        }

        if ((agentInfo.fnNativeInterface == "ACE" ) | (agentInfo.NativeInfo.useIoCache)) {
            if ((agentInfo.CmpInfo.nDtrInFlight < 1) | (agentInfo.CmpInfo.nDtrInFlight < 1)) {
                u.paramError("nDtrInFlight must be within 1..16.");
            }
        } else {
            if (agentInfo.CmpInfo.nDtrInFlight != 0) {
                u.paramError("nDtrInFlight must be 0.");
            }
        }

        if (agentInfo.CmpInfo.nDtrSlaveIds > agentInfo.CmpInfo.nOttDataEntries) {
            u.paramError("nDtrSlaveIds must greater than nOttDataEntries.");
        }

        if (agentInfo.SfiInfo.wMasterData != agentInfo.NativeInfo.SignalInfo.wXData) {
            u.paramError("wMasterData & RData/WData width must match.");
        }

        if (agentInfo.SfiInfo.wSlaveData != agentInfo.NativeInfo.SignalInfo.wXData) {
            u.paramError("wSlaveData & RData/WData width must match.");
        }


        // // Table 11: AIU SFI Configuration Parameters
        // u.param(type+"[].SfiInfo.wMasterData"                                       , "int");
        // u.param(type+"[].SfiInfo.wSlaveData"                                        , "int");
        // 
        // // These are calculated SFI parameters and are not in the Arch specification.
        // u.param(type+"[].Derived.wSfiAddr"                                          , "int");
        // u.param(type+"[].Derived.wSfiSlvId"                                         , "int");
        // u.param(type+"[].Derived.wProtBitsPerByte"                                  , "int");
        // u.param(type+"[].Derived.wSfiData"                                          , "int");
        // u.param(type+"[].Derived.wSfiSlaveTransId"                                  , "int");
        // u.param(type+"[].Derived.wSfiMasterTransId"                                 , "int");
        // 
        // // Derived SfiPriv
        // module.exports.defineSfiPrivParams(m,type+"[].Derived.");

    }   // aiuType



    //========================================
    // Bridge Parameters
    //
    for (var aiu = 0; aiu < m.param.BridgeAiuInfo.length; aiu++){
        var bridgeInfo = m.param.BridgeAiuInfo[aiu];
        totalNumProcs = totalNumProcs + bridgeInfo.NativeInfo.nProcs;

        validateSelectInfo(bridgeInfo.AiuSelectInfo);

        if (!bridgeInfo.NativeInfo.isBridgeInterface){
            u.paramError("Bridge Interfaces must be bridges.");
        }

        if (!isPowerOfTwo( bridgeInfo.NativeInfo.szMaxCoherentRead)) {
            u.paramError("Bridge Interfaces must have szMaxCoherentRead be a power of 2.");
        }

        if (bridgeInfo.NativeInfo.szMaxCoherentWrite != bridgeInfo.NativeInfo.szMaxCoherentRead) {
            u.paramError("Bridge Interfaces must have szMaxCoherentWrite = szMaxCoherentRead");
        }

        //========================================
        // IO Cache
        //
        
        if (bridgeInfo.NativeInfo.useIoCache) {
            if (!isPowerOfTwo( bridgeInfo.NativeInfo.IoCacheInfo.CacheInfo.nSets)) {
                u.paramError("IO Caches must have nSets be a power of 2.");
            }

            //        validateSelectInfo(bridgeInfo.NativeInfo.IoCacheInfo.CacheInfo.SetSelectInfo);
            if (bridgeInfo.NativeInfo.IoCacheInfo.CacheInfo.SetSelectInfo.nRsrcIdxBits !== bridgeInfo.NativeInfo.IoCacheInfo.CacheInfo.SetSelectInfo.PriSubDiagAddrBits.length) {
                u.paramError("IOC PriSubDiagAddrBits[] length doesn't match nRsrcIdxBits");
            }
            if ((bridgeInfo.NativeInfo.IoCacheInfo.CacheInfo.SetSelectInfo.nRsrcIdxBits !== Object.keys(bridgeInfo.NativeInfo.IoCacheInfo.CacheInfo.SetSelectInfo.SecSubRows).length)) {
                u.paramError("IOC SecSubRows[] length doesn't match nRsrcIdxBits");
            }

            if (bridgeInfo.NativeInfo.IoCacheInfo.CacheInfo.nSets == 1) {

            } else {

                if (!isPowerOfTwo( bridgeInfo.NativeInfo.IoCacheInfo.CacheInfo.nSets)) {
                    u.paramError("IO Caches must have nWays be a power of 2 if nWays > 1.");
                }

                if (bridgeInfo.NativeInfo.IoCacheInfo.CacheInfo.nWays > 8) {
                    u.paramError("IO Cache nWays must not be larger than 8 if nSets > 1.");
                }
                
            }

//            if (bridgeInfo.NativeInfo.IoCacheInfo.nCttCtrlEntries != bridgeInfo.CmpInfo.nOttCtrlEntries) {
//                u.paramError("IO Cache nCttCtrlEntries must match nOttCtrlEntries.");
//            }
// TODO: ^^ Re-enable this, after SW forces it to be true.

            if (bridgeInfo.NativeInfo.IoCacheInfo.nUttCtrlEntries > bridgeInfo.CmpInfo.nOttCtrlEntries) {
                u.paramError("IO Cache nUttCtrlEntries must be smaller than or equal to nOttCtrlEntries.");
            }

        } // useIoCache

        if ([64, 128, 256].indexOf(bridgeInfo.NativeInfo.SignalInfo.wXData) == -1) {
            u.paramError("Bridge Data Width must be 64, 128, or 256.");
        }

//        if (agentInfo.NativeInfo.SignalInfo.wXData != agentInfo.NativeInfo.SignalInfo.wCdData) {
//            u.paramError("Bridge RData & WData width must match CdData width.");
//        }

        if (bridgeInfo.fnNativeInterface == "ACE" ) {
            if (bridgeInfo.CmpInfo.nOttDataEntries < 4) {
                u.paramError("For ACE Interfaces, nOttDataEntries must be at least 4.");
            }
        } else {
            if (bridgeInfo.CmpInfo.nOttDataEntries > 0) {
                if (bridgeInfo.CmpInfo.nOttDataEntries != bridgeInfo.CmpInfo.nOttCtrlEntries) {
                    u.paramError("For ACE-Lite Interfaces, nOttDataEntries must equal nOttCtrlEntries.");
                }
            }
        }

        if (bridgeInfo.CmpInfo.nOttStrbEntries != bridgeInfo.CmpInfo.nOttStrbEntries) {
            u.paramError("nOttStrbEntries must equal nOttCtrlEntries.");
        }

        if ((bridgeInfo.fnNativeInterface == "ACE" ) | (bridgeInfo.NativeInfo.useIoCache)) {
            if ((bridgeInfo.CmpInfo.nDtrInFlight < 1) | (bridgeInfo.CmpInfo.nDtrInFlight < 1)) {
                u.paramError("nDtrInFlight must be within 1..16.");
            }
        } else {
//            if (bridgeInfo.CmpInfo.nDtrInFlight != 0) {
//                u.paramError("nDtrInFlight must be 0.");
//            }
        }

        if (bridgeInfo.CmpInfo.nDtrSlaveIds > bridgeInfo.CmpInfo.nOttDataEntries) {
            u.paramError("nDtrSlaveIds must greater than nOttDataEntries.");
        }

        if (bridgeInfo.SfiInfo.wMasterData != bridgeInfo.NativeInfo.SignalInfo.wXData) {
            u.paramError("wMasterData & RData/WData width must match.");
        }

        if (bridgeInfo.SfiInfo.wSlaveData != bridgeInfo.NativeInfo.SignalInfo.wXData) {
            u.paramError("wSlaveData & RData/WData width must match.");
        }


    } // bridgeInfo[]

    //========================================
    // Snoop filter checks
    //
    for (var i = 0; i < m.param.SnoopFilterInfo.length; i++){
        var info = m.param.SnoopFilterInfo[i];

        if (info.fnFilterType == "TAGFILTER") {
            if (!isPowerOfTwo( info.StorageInfo.nSets)) {
                u.paramError("Snoop Filters must have nSets be a power of 2.");
            }


            if (info.StorageInfo.nSets == 1) {
                
            } else {
                
//                if ([6, 8, 12, 16].indexOf(info.StorageInfo.nWays) == -1) {
//                    u.paramError("Snoop Filters nWays must be one of [6, 8, 12, 16] if nSets > 1.");
//                 }

            }

            validateSelectInfo(info.StorageInfo.SetSelectInfo);

            var bitsForDceSelect = m.log2ceil(m.param.DceInfo);
            var bitsForSetSelect = m.log2ceil(info.StorageInfo.nSets);
            
            if ((bitsForSetSelect + bitsForDceSelect) != info.StorageInfo.SetSelectInfo.nSelectBits) {
//                u.paramError("nSelectBits must be log2(nSets) + log2(nDces)");
            }



        }

    } // SnoopFilter[]

    //========================================
    // DCE Checks
    //

    if (m.param.DceInfo.fnDceSelect === 'TABLE') {
        validateSelectInfo(m.param.DceInfo.DceSelectInfo);
    } else {
        // TODO: Validate the 'GENERAL' Selection parameters
    }


    if (m.param.DceInfo.nTaggedMonitors > totalNumProcs) {
        u.paramError("nTaggedMonitors cannot be greater than the total number of processors in the system.");
    }


    //========================================
    // Memory Region Checks
    //
    for (var i = 0; i < m.param.DmiInfo.length; i++){
        var info = m.param.DmiInfo[i];

        if (info.CmpInfo.nMrdInFlight > m.param.DceInfo.CmpInfo.nAttCtrlEntries) {
            u.paramError("nMrdInFlight cannot be larger than nAttCtrlEntries.");
        }

        var dmiInfo = info ;//m.param.DmiInfo[i];

        if (dmiInfo.fnDmiSelect === 'TABLE') {
            validateSelectInfo(dmiInfo.DmiSelectInfo);
        } else {
            // TODO: Validate the 'GENERAL' Selection parameters
        }

        if ([64, 128, 256].indexOf(dmiInfo.SfiInfo.wMasterData) == -1) {
            u.paramError("DMI wMasterData must be 64, 128, or 256.");
        }

        if (!isPowerOfTwo( dmiInfo.SfiInfo.wMasterData)) {
            u.paramError("DMI wMasterData must be a power of 2.");
        }

        if (dmiInfo.SfiInfo.wMasterData != dmiInfo.SfiInfo.wSlaveData) {
            u.paramError("DMI wMasterData & wSlaveData must be the same.");
        }

        if (dmiInfo.CmpInfo.nDtwSlaveIds != dmiInfo.CmpInfo.nWttCtrlEntries) {
            u.paramError("DMI nDtwSlaveIds & nWttCtrlEntries must be the same.");
        }

    } // MemRegionInfo[]
};

module.exports.defineSfiPrivParams = function(m, pfx) {

    var u = m.u;//require("../../lib/src/utils.js").init(m);  

    var prefix = pfx;
    if (prefix === undefined) {
        prefix = "";
    }

    var i;

    u.param(prefix+"wSfiPriv", "int");

    var strWidth = 0;
    var fields = ["msgType", "ST", "SD", "SO", "SS", "ErrResult", "AceExOkay",
                  "aiuTransId", "aiuId", "aiuProcId", "aceLock", 
                  "aceCache", "aceProt", "aceQoS", "aceRegion", 
                  "aceUser", "aceDomain", "aceUnique", "dataOffset"];

    for (i=0; i<fields.length; i++) {
        u.param(prefix+"sfiPriv."+fields[i]+".lsb", "int");
        u.param(prefix+"sfiPriv."+fields[i]+".msb", "int");
        u.param(prefix+"sfiPriv."+fields[i]+".width", "int");
    }
    u.param(prefix+"sfiPriv.width", "int");

};

//* eslint no-undef:0 *   /
