//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------
"use strict";

/**
 * Concerto Constants
 * 
 * All units see these.
 */
var defineTopConstants = function(m) {
    m.constants = {};
    m.constants.wAddrMin     =	32;
    m.constants.wAddrMax     =	48;
    m.constants.wGlobalAddr  =	63;
    m.constants.wMsgType     =	5;
    m.constants.wSnpResult   =	4;
    m.constants.wTransResult =	2;
}

/**
 * Concerto Top-level parameters.
 * 
 * All units see these.
 */
var defineToplevelParams = function(m) {
    var u = require("./utils.js");
    u.init(m);

    // u.param("wCacheLineOffset",  "int", 6, 6);
    // u.param("nAgentAius",        "int", 1, 2);
    // u.param("nBridgeAius",       "int", 0, 2);
    // u.param("nMemRegions",       "int", 1, 2);
    // u.param("wSecurityAttribute","int", 0, 1);
}

/**
 * AIU Parameters
 * 
 * This is the set of parameters that are unique for each AIU.
 */
var defineAiuParams = function (m, prefix) {
    var p = m.param;
    var u = require("./utils.js");
    u.init(m);

    // The following parameters are used in the definition of other parameters.
    // Even though they haven't been defined yet, the values should be available.
    var wAddrMin        = m.constants.wAddrMin;
    var wAddrMax        = m.constants.wAddrMax;
    var wXData          = p[prefix+"wXData"];                                                                                                      
    var nOttCtrlEntries = p[prefix+"nOttCtrlEntries"];                                                                                    
    var nOttDataEntries = p[prefix+"nOttDataEntries"];                                                                                    

    // AIU Top-Level Parameters
    // u.param(prefix+"NativeInterfaceName", "string"                         );
    // u.param(prefix+"fnNativeInterface",   "string"                         );

    // SignalInfo Parameters
    // u.param(prefix+"wAxId",               "int", 4,        12              );
    // u.param(prefix+"wAxAddr",             "int", wAddrMin, wAddrMax        );
    // u.param(prefix+"wXData",              "int", 64,       256             );
    // u.param(prefix+"wAwUser",             "int", 0,        12              );
    // u.param(prefix+"wWUser",              "int", 0,        12              );
    // u.param(prefix+"wBUser",              "int", 0,        12              );
    // u.param(prefix+"wArUser",             "int", 0,        12              );
    // u.param(prefix+"wRUser",              "int", 0,        12              );
    // u.param(prefix+"useAceCache",         "bit", 0,        0               );
    // u.param(prefix+"useAceProt",          "bit", 0,        0               );
    // u.param(prefix+"useAceQos",           "bit", 0,        0               );
    // u.param(prefix+"useAceRegion",        "bit", 0,        0               );
    // u.param(prefix+"useAceDomain",        "bit", 0,        0               );

    // Messaging Protocol Parameters
    // u.param(prefix+"nOttCtrlEntries",     "int", 16,       48              );
    // u.param(prefix+"nOttDataEntries",     "int", 0,        nOttCtrlEntries );
    // u.param(prefix+"nOttStrbEntries",     "int", 0,        nOttDataEntries );
    // u.param(prefix+"nCmdInFlight",        "int", 2,        8               );
    // u.param(prefix+"nDvmInFlight",        "int", 1,        1               );
    // u.param(prefix+"nDtrInFlight",        "int", 1,        8               );
    // u.param(prefix+"nDtrInProcess",       "int", 1,        8               );
    // u.param(prefix+"idSnoopFilterSlice",  "int"                            ); /// TODO: Range

    // SFI Interface Parameters
    // u.param(prefix+"wSfiMasterData",      "int", wXData,   wXData          );
    // u.param(prefix+"wSfiSlaveData",       "int", wXData,   wXData          );
    
    // The following parameters exist only for ACE (not ACE-Lite)
    if (p[prefix+"fnNativeInterface"] == "ACE") {                                                                                         
        // u.param(prefix+"nProcs",             "int", 1,       4      );
        // u.param(prefix+"szAgentCacheline",   "int", 64,      64     );
        // u.param(prefix+"szMaxCoherentRead",  "int", 64,      64     );
        // u.param(prefix+"szMaxCoherentWrite", "int", 64,      64     );
        // u.param(prefix+"useSharerPromotion", "bit"                  );
        // u.param(prefix+"useWriteEvict",      "bit", 0,       0      );
        // u.param(prefix+"useBarriers",        "bit", 0,       0      );
        // u.param(prefix+"useDvm",             "bit"                  );

        // u.param(prefix+"useAceUnique",       "bit", 0,       0      );
        // u.param(prefix+"wCdData",            "int", wXData,  wXData );
    }                                                                                                                                       
    
    // The following parameters exist only for ACE-LITE (not ACE)
    if (p[prefix+"fnNativeInterface"] == "ACE_LITE") {                                                                                    
        // u.param(prefix+"isBridgeInterface",  "bit"           );
        // u.param(prefix+"szMaxCoherentRead",  "int", 16, 4096 );
        // u.param(prefix+"szMaxCoherentWrite", "int", 16, 4096 );
        // u.param(prefix+"useBarriers",        "bit"           );
        // u.param(prefix+"useDvm",             "bit"           );
        // u.param(prefix+"useIoCache",         "bit"           );
        // u.param(prefix+"nSetsIoCache",       "int", 1,  1024 );   
        
        if (p[prefix+"nSetsIoCache" == 1]) {
            // u.param(prefix+"nWaysIoCache",       "int", 1,  16   );
        } else {
            // u.param(prefix+"nWaysIoCache",       "int", [1,2,4,8] );
        }

        // TODO:  nSets * nWays must be <= 256
    }                                                                                                                                       
}

/**
 * DCE Select Parameters
 *
 */
var defineDceSelectParams = function(m) {
    var p = m.param;
    var u = require("./utils.js");
    u.init(m);


    // u.param("nDces",               "int",    1,  2               );
    // u.param("dceSelectMask",       "string"                      );
    // u.param("dceHashMask",         "string"                      );
}

/** 
 * DCE Configuration Parameters
 *
 * Note that all DCEs are parameterized the same.
 */
var defineDceConfigurationParams = function(m) {
    var p = m.param;
    var u = require("./utils.js");
    u.init(m);

    var nAttCtrlEntries = p["dce_nAttCtrlEntries"];                                                                                  

    // u.param("dce_nAttCtrlEntries", "int",    16, 48              ); // TODO: Range
    // u.param("dce_nSnpInFlight",    "int",    1,  nAttCtrlEntries );
    // u.param("dce_nMrdInFlight",    "int",    1,  8               );
    // u.param("dce_nTaggedMonitors", "int"                         ); //TODO: To sum(nProcs)
    // u.param("dce_useMemHints",     "bit"                         );
    // u.param("dce_useCsrMemHints",  "bit"                         );

    // u.param("dce_nDvmSnpInFlight", "int",    1,  1               );
    // u.param("dce_nDvmRepInFlight", "int",    1,  1               );
    // u.param("dce_nDtfEntries",     "int",    0,  8               ); //TODO: To sum(nProcs)

    
    //------------------------------------------------------------
    // Snoop Filters
    //------------------------------------------------------------
    // u.param("nSnoopFilterSlices",  "int",    1,  2               ); 

    for (var i = 0; i<p.nSnoopFilterSlices; i++) {                                                                                             
        // u.param("slice"+i+"_sliceName",            "string"        );
        // u.param("slice"+i+"_fnSliceType",          "string", ["NULL", "TAGFILTER"] );

        if (p["slice"+i+"_fnSliceType"] == "TAGFILTER") {
            // u.param("slice"+i+"_useOwnerPointer",      "bit"           );
            // u.param("slice"+i+"_usePresenceVector",    "bit"           );
            // u.param("slice"+i+"_useImplicitOwnerVld",  "bit"           );
            // u.param("slice"+i+"_nSetsFilter",          "int",   1, 1048576 ); // TODO: Powerof2

            if (p["slice"+i+"_nSetsFilter" == 1]) {
                // u.param("slice"+i+"_nWaysFilter",          "int",   1, 16  );
            } else {
                // u.param("slice"+i+"_nWaysFilter",          "int",   [6, 8, 12, 16]  );
            }

            // u.param("slice"+i+"_setSelectMask",        "string"        );
            // u.param("slice"+i+"_setHashMask",          "string"        );
        }
    }                                                                                                                                          
}

/**
 * Mem region & DMI Parameters.  
 *  
 * Note that all the DMIs in a memory region are 
 * parameterized the same.
 */
var defineMemRegionParams = function(m) {
    var p = m.param;
    var u = require("./utils.js");
    u.init(m);

    var wAddrMax        = m.constants.wAddrMax;

    for (var i = 0; i<p.nMemRegions; i++) {                                                                                                    
        var wSfiData = p["dmi"+i+"_wSfiMasterData"];                                                                                           

        // u.param("memregion"+i+"_RegionName",    "string"                    );
        // u.param("memregion"+i+"_wRegionAddr",   "int",   12,       wAddrMax );
        // u.param("memregion"+i+"_nRegionPrefix", "int",   0,        wAddrMax );
        // u.param("memregion"+i+"_nDmis",         "int",   0,        wAddrMax );  //TODO: Fix Range

        // DMI Select
        // u.param("memregion"+i+"_dmiSelectMask", "string"                    );
        // u.param("memregion"+i+"_dmiHashMask",   "string"                    );

        // DMI Parameters
        // u.param("dmi"+i+"_fnNativeInterface",   "string"                    );

        // SFI Parameters
        // u.param("dmi"+i+"_wSfiMasterData",      "int",   64,       256      );
        // u.param("dmi"+i+"_wSfiSlaveData",       "int",   wSfiData, wSfiData );

        // DMI Message Protocol Parameters
        // u.param("dmi"+i+"_nHttCtrlEntries",     "int",   0,        16       );
        // u.param("dmi"+i+"_nRttCtrlEntries",     "int",   4,        16       );
        // u.param("dmi"+i+"_nWttCtrlEntries",     "int",   4,        16       );
        // u.param("dmi"+i+"_nDtrInFlight",        "int",   1,        16       );
        // u.param("dmi"+i+"_nHntSlaveIds",        "int",   1,        16       );
        // u.param("dmi"+i+"_nDtwSlaveIds",        "int"                       );

        // DMI Signal Info
        // u.param("dmi"+i+"_wAxData",             "int",   wSfiData, wSfiData );        
    }
}


/**
* Define SFI Parameters
*
*/
var defineSfiParams = function(m) {
    var p = m.param;
    var u = require("./utils.js");
    u.init(m);

    // u.param("wOpc",               "int");
    // u.param("wBurstType",         "int");
    // u.param("wAddr",              "int");
    // u.param("wLength",            "int");
    // u.param("wData",              "int");
    // u.param("wProtBitsPerByte",   "int");
    // u.param("wSFIQoS",            "int");
    // u.param("wSFISlvID",          "int");
    // u.param("wTransID",           "int");
    // u.param("wMstTransID",        "int");
    // u.param("wSlvTransID",        "int");
    // u.param("wSFIPriv_MsgType",   "int");
    // u.param("wSFIPriv_AIUTransID","int");
    // u.param("wSFIPriv_AIUID",     "int");
    // u.param("wSFIPriv_AceProcID", "int");
    // u.param("wSFIPriv_AceLock",   "int");
    // u.param("wSFIPriv_AceProt",   "int");
    // u.param("wSFIPriv_AceCache",  "int");
    // u.param("wSFIPriv_AceQos",    "int");
    // u.param("wSFIPriv_AceRegion", "int");
    // u.param("wSFIPriv_AceUser",   "int");
    // u.param("wSFIPriv_AceDomain", "int");
    // u.param("wSFIPriv_AceUnique", "int");
    // u.param("wSFIPriv_Pad",       "int");
    // u.param("wSecurity",          "int");
    // u.param("wStatus",            "int");
    // u.param("wErrCode",           "int");
    // u.param("wSFIRspSFIPriv",     "int");
}


/**
 * Add Concerto Top-level parameters.
 * 
 * * Note: This is up-to-date with v0.3 of the Concerto System 
 *   Parameter Specification.
 */
exports.defineParamsForUnit = function (m, whoami) {
    var p = m.param;

    defineTopConstants(m);
    defineToplevelParams(m)

    if (whoami=="TOP" || whoami == "COH") {

        for (var i = 0; i<(p.nAgentAius + p.nBridgeAius); i++) {
            defineAiuParams(m,"aiu"+i+"_");
        }                                                                                                                                           
        
        defineDceSelectParams(m);
        defineDceConfigurationParams(m);
        defineMemRegionParams(m);
    }

    if (whoami=="AIU") {
        defineAiuParams(m,"");
        defineDceSelectParams(m);
        defineSfiParams(m);
    }

}
//* eslint no-undef:0 *   /
