//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

'use strict';

//module.exports = function get_iocacheinfo(m, u) {
module.exports = function get_iocacheinfo(m, t) {


    var u = require("../../lib/src/utils.js").init(t);

//    var p = m.param;

  //  var nSets = 32; // coming from top level params.
  //  var nWays = 8;
  //  var nCttCtrlEntries = 8;
    var IoCacheInfo = {} ;
   // var nUttCtrlEntries = 4;
    IoCacheInfo['wCachestateBits'] = 2;  // 00 - IX 01 SC 10 UD 
    if(m.nWays > 1){ 
    IoCacheInfo['wNRUBit'] = 1; }
    else{
    IoCacheInfo['wNRUBit'] = 0; }
   
   
    // 0 for now. Will enable once Errinfo is considered 
   // var m.wSfiAddr = 32; // for now assume as entire address to be worked with
    //var szAgentCacheLine = 256;
  //  var wBlockIDBits =    Math.max(1,m.log2ceil(szAgentCacheLine/8)); // this indicates number of bits to subrated from address for cache block
     //IoCacheInfo['wIndexBits'] =  Math.max(1,t.log2ceil(m.nSets));
     IoCacheInfo['wIndexBits'] =    m.SetSelectInfo.nSelectBits ;//Math.max(1,t.log2ceil(m.nSets));
     IoCacheInfo['wCachelineAddr'] = m.wSfiAddr - m.wCacheLineOffset ;
     IoCacheInfo['wCompareAddr'] = IoCacheInfo.wCachelineAddr + m.wSfiSecurity ;
     IoCacheInfo['wTagBits']   = m.wSfiAddr - IoCacheInfo.wIndexBits - m.wCacheLineOffset + m.wSfiSecurity - m.AiuSelectInfo.nSelectBits;
     IoCacheInfo['wTagEntrywithoutEcc'] =IoCacheInfo.wTagBits + IoCacheInfo.wCachestateBits + IoCacheInfo.wNRUBit ; 

    // Get the width of error encoding fields
    if ((m.fnErrDetectCorrect_tagmem == 'SECDED64BITS') || (m.fnErrDetectCorrect_tagmem == 'SECDED128BITS')) {
        var tagmem_block_widths = [];
        tagmem_block_widths = u.getEvenBlockWidths( m.fnErrDetectCorrect_tagmem , IoCacheInfo.wTagEntrywithoutEcc , 0 );
        IoCacheInfo['wErrInfo']     = u.getErrorEncodingWidth(m.fnErrDetectCorrect_tagmem,  IoCacheInfo.wTagEntrywithoutEcc, tagmem_block_widths);
    } else {
        IoCacheInfo['wErrInfo']     = u.getErrorEncodingWidth(m.fnErrDetectCorrect_tagmem,  IoCacheInfo.wTagEntrywithoutEcc);
    }

    if ((m.fnErrDetectCorrect_datamem == 'SECDED64BITS') || (m.fnErrDetectCorrect_datamem == 'SECDED128BITS')) {
        var datamem_block_widths = [];
        datamem_block_widths = u.getEvenBlockWidths( m.fnErrDetectCorrect_datamem , m.wSfiData , 1 );
        IoCacheInfo['wDataErrInfo'] = u.getErrorEncodingWidth(m.fnErrDetectCorrect_datamem, m.wSfiData+1, datamem_block_widths); // poison
    } else {
        IoCacheInfo['wDataErrInfo'] = u.getErrorEncodingWidth(m.fnErrDetectCorrect_datamem, m.wSfiData+1); // poison
    }

     IoCacheInfo['wCttCtrlEntries']  =  Math.max(1,t.log2ceil(m.nCttCtrlEntries));
     IoCacheInfo['wUttCtrlEntries']  =  Math.max(1,t.log2ceil(m.nUttCtrlEntries));
     IoCacheInfo['wTransId']  =  Math.max(1,t.log2ceil(m.nUttCtrlEntries+m.nCttCtrlEntries));
     IoCacheInfo['SizeSystemCacheline']  =  Math.pow(2,m.wCacheLineOffset);

     IoCacheInfo['wWays'] =  t.log2ceil(m.nWays); // Math.max(1,t.log2ceil(m.nWays));
      IoCacheInfo ['nBeats'] = Math.pow(2,m.wCacheLineOffset) * 8 / m.wSfiData ; 
      IoCacheInfo ['wBeats'] = Math.max(1,t.log2ceil(IoCacheInfo.nBeats));

     IoCacheInfo ['wCachePipeLineAddr'] = IoCacheInfo.wCachelineAddr + IoCacheInfo.wBeats ;
     IoCacheInfo ['wSfiIgnoreBits'] = m.wSfiAddr - IoCacheInfo.wCachePipeLineAddr ;
     IoCacheInfo ['wReplayFifo'] = m.wSfiAddr - IoCacheInfo.wSfiIgnoreBits + m.wSfiSecurity + m.wSfiUrgency +  m.wSfiPriv + m.wSfiMstTransID + 1 /*valid*/ + 1 /*allocate*/ + IoCacheInfo.wBeats;
     IoCacheInfo ['wLookUpSnoopSelMux'] = m.wSfiAddr - IoCacheInfo.wSfiIgnoreBits + m.wSfiSecurity + m.wSfiUrgency +  m.wSfiPriv + m.wSfiMstTransID +1 /*allocate*/ + IoCacheInfo.wBeats ;
      IoCacheInfo['wTagPipe'] = 5 /* pipe op bits */ + IoCacheInfo.wLookUpSnoopSelMux + IoCacheInfo.wCttCtrlEntries +2 ;
     
      IoCacheInfo ['wCttCmdtype'] = 2 ;
      IoCacheInfo['wCttAddr'] =  IoCacheInfo.wCachelineAddr  + 
                                 IoCacheInfo.wBeats          +
                                 m.wSfiSecurity              ;
        
      IoCacheInfo['wCttEntry'] =  IoCacheInfo.wCttAddr + 
                                  IoCacheInfo.wWays           +  // width of ways
                                  IoCacheInfo.wCttCmdtype     + 
                                       1                      +  // NS
                                       1                      +  // CATV 
                                       1                      ;  // VLD
      
      //IoCacheInfo['nSttCtrlEntries']  = m.nDCEs * m.nSnpInFlight ;
      IoCacheInfo['nSttCtrlEntries']  = Math.max(2, m.nDCEs * m.nSnpInFlight);
      IoCacheInfo['wSttCtrlEntries'] =  Math.max(1,t.log2ceil(IoCacheInfo.nSttCtrlEntries));
       

     // Now we generate the tagvector 
     var     TagVecArray = {};
     var bit = -1;
    for (var i=0; i<m.nWays; i++) {
        TagVecArray[i] = {};
        TagVecArray[i].Tag = {};
        TagVecArray[i].StateBits = {};
        TagVecArray[i].NRU = {};
        TagVecArray[i].ErrInfo = {};
        TagVecArray[i].Tag.lsb  = bit + 1;
        bit = bit +   IoCacheInfo.wTagBits;
        TagVecArray[i].Tag.msb = bit;
        TagVecArray[i].StateBits.lsb = bit +1;
        bit = bit + IoCacheInfo.wCachestateBits;
        TagVecArray[i].StateBits.msb =  bit; 
        TagVecArray[i].NRU.lsb = bit +1; 
        bit = bit + IoCacheInfo.wNRUBit;
        TagVecArray[i].NRU.msb = bit; 
        TagVecArray[i].ErrInfo.lsb = bit+1; 
        bit = bit + IoCacheInfo.wErrInfo;
        TagVecArray[i].ErrInfo.msb = bit; 
    }
    TagVecArray.wTagVec = bit + 1;
 

 var     TagVecArrayNoEcc = {};
 var bit = -1;

  for (var i=0; i<m.nWays; i++) {
        TagVecArrayNoEcc[i] = {};
        TagVecArrayNoEcc[i].Tag = {};
        TagVecArrayNoEcc[i].StateBits = {};
        TagVecArrayNoEcc[i].NRU = {};
        TagVecArrayNoEcc[i].ErrInfo = {};
        TagVecArrayNoEcc[i].Tag.lsb  = bit + 1;
        bit = bit +   IoCacheInfo.wTagBits;
        TagVecArrayNoEcc[i].Tag.msb = bit;
        TagVecArrayNoEcc[i].StateBits.lsb = bit +1;
        bit = bit + IoCacheInfo.wCachestateBits;
        TagVecArrayNoEcc[i].StateBits.msb =  bit; 
        TagVecArrayNoEcc[i].NRU.lsb = bit +1; 
        bit = bit + IoCacheInfo.wNRUBit;
        TagVecArrayNoEcc[i].NRU.msb = bit; 
        TagVecArrayNoEcc[i].ErrInfo.lsb = bit+1; 
        bit = bit + 0 /* IoCacheInfo.wErrInfo*/;
        TagVecArrayNoEcc[i].ErrInfo.msb = bit; 
    }
    TagVecArrayNoEcc.wTagVec = bit + 1;
 






    IoCacheInfo['TagInfo'] = TagVecArray ; 
    IoCacheInfo['TagInfoNoEcc'] = TagVecArrayNoEcc ; 

  
    IoCacheInfo['wSfiMstPkt'] = // Width except for unit_id, which is assigned after the mux
          m.wSfiAddr         //sfi_mst_req_addr,
        + m.wSfiData/8       //sfi_mst_req_be,
        + 1                           //sfi_mst_req_bursttype,
        + m.wSfiData         //sfi_mst_req_data,
        + m.wSfiHurry        //sfi_mst_req_hurry,
        + m.wSfiLength       //sfi_mst_req_length,
        + 1                           //sfi_mst_req_opc,
        + m.wSfiPressure     //sfi_mst_req_press,
        + m.wSfiData*m.wSfiProtBitsPerByte/8       //sfi_mst_req_protbits,
        + m.wSfiSecurity     //sfi_mst_req_security,
        + m.wSfiPriv         //sfi_mst_req_sfipriv,
        + m.wSfiSlvID        //sfi_mst_req_sfislvid,
        + m.wSfiMstTransID   //sfi_mst_req_transid,
        + m.wSfiUrgency;     //sfi_mst_req_urgency

    IoCacheInfo['wSfiSlvReqPkt'] = // Width except for unit_id, which is assigned after the mux
        1
        + 1                           //sfi_mst_req_bursttype,
        + m.wSfiLength       //sfi_mst_req_length,
        +  m.wSfiAddr         //sfi_mst_req_addr,
        + m.wSfiSlvID        //sfi_mst_req_sfislvid,
        + m.wSfiSlvTransID  //sfi_mst_req_transid,
        + m.wSfiPriv         //sfi_mst_req_sfipriv,
        + m.wSfiUrgency;     //sfi_mst_req_urgency
        + m.wSfiSecurity     //sfi_mst_req_security,
        + m.wSfiPressure     //sfi_mst_req_press,
        + m.wSfiHurry        //sfi_mst_req_hurry,
        + m.wSfiData/8       //sfi_mst_req_be,
        + m.wSfiData         //sfi_mst_req_data,
        + m.wSfiData*m.wSfiProtBitsPerByte/8     ;  //sfi_mst_req_protbits,


     


 IoCacheInfo['wSfiSlvPkt'] =
          m.wSfiSlvTransID   // sfi_slv_rsp_transid
        + 4                           // sfi_slv_rsp_sfipriv
        + 1                           // sfi_slv_rsp_status
        + m.wSfiErrCode;     // sfi_slv_rsp_errcode


    IoCacheInfo["TagPipeLength"] =  3 ;
    IoCacheInfo["LookupCV"] =  '101' ;
    IoCacheInfo["SnoopCV"] =  '101' ;
    IoCacheInfo["FillCV"] =  '001' ;
    IoCacheInfo["MntOpCV"] =  '111' ;
    IoCacheInfo["ReadCV"] =  '100' ;
    IoCacheInfo["RMWCV"] =  '101' ;
    IoCacheInfo["wStreqFifo"] = m.wSfiPriv + m.wSfiMstTransID + m.wSfiSecurity +2 /*read_hit,write_hit,write_miss_alloc*/+1 /*uncorr error */;

    IoCacheInfo ["nIOCWrDatBufEntries"] = 4 ;
    IoCacheInfo ["nIOCRdDatBufEntries"] = 4 ;

     IoCacheInfo['wIOCWrDatBufEntries']  =  Math.max(1,t.log2ceil(IoCacheInfo.nIOCWrDatBufEntries));
    IoCacheInfo ["wIOCRdDatBufEntries"] =  Math.max(1,t.log2ceil(IoCacheInfo.nIOCRdDatBufEntries));
    IoCacheInfo ['CmdQueOpCodes'] = { "width" :  2    ,
                                      "Read"  :  "00" ,
                                      "RMW"   :  "01" ,
                                      "EvMW"  :  "10" ,
                                      "RMWInv":  "11"  } ;

    IoCacheInfo ['DataReadDestId'] = { "width" : 2  ,
                                       "STT"  : "00",
                                       "OTT"  : "01",
                                       "UTT"  : "10" };
    
   
    IoCacheInfo['wDestEntryId']   = Math.max(IoCacheInfo.wUttCtrlEntries,IoCacheInfo.wCttCtrlEntries,IoCacheInfo.wSttCtrlEntries);

    IoCacheInfo["DataPipeLength"] =  3 ;
    
    IoCacheInfo ['wCmdOpQue'] = IoCacheInfo.CmdQueOpCodes.width +
                                IoCacheInfo.wBeats              +
                                IoCacheInfo.DataReadDestId.width +
                                IoCacheInfo.wDestEntryId         +
                                IoCacheInfo.wIndexBits           +
                                IoCacheInfo.wWays                +
                                IoCacheInfo.wBeats               +
                                1 /*flag for first cache allocation */;

    IoCacheInfo ['wRdBuffCmd'] = IoCacheInfo.DataReadDestId.width +
       IoCacheInfo.wBeats +
       IoCacheInfo.wDestEntryId +
       IoCacheInfo.wIOCRdDatBufEntries +
       IoCacheInfo.wBeats
        ;

    IoCacheInfo ['wDtrReqBundle'] = 1+1+1+ m.wSfiData + IoCacheInfo.wCttCtrlEntries +1 ;
    IoCacheInfo ['wSnpReqBundle'] = 1+1+1+ m.wSfiData + IoCacheInfo.wSttCtrlEntries +1;
    IoCacheInfo ['wUttReqBundle'] = 1+1+1+ m.wSfiData + IoCacheInfo.wUttCtrlEntries +1;
    IoCacheInfo ['wDataPipe']   = IoCacheInfo.wCmdOpQue + IoCacheInfo.wIOCRdDatBufEntries + 1 ;

 return IoCacheInfo ;



//    for (var i=0; i<p.BridgeAiuInfo.length; i++) {
//
//        agentInfo       = p.BridgeAiuInfo[i];
//        maxOttEntries   = Math.max(maxOttEntries, agentInfo.CmpInfo.nOttCtrlEntries);
//        maxUser         = Math.max(maxUser, agentInfo.NativeInfo.SignalInfo.wAwUser);
//        maxUser         = Math.max(maxUser, agentInfo.NativeInfo.SignalInfo.wArUser);
//
//        if (agentInfo.NativeInfo.SignalInfo.useAceCache)      { useAceCache   = true; }
//        if (agentInfo.NativeInfo.SignalInfo.useAceProt)       { useAceProt    = true; }
//        if (agentInfo.NativeInfo.SignalInfo.useAceQos)        { useAceQos     = true; }
//        if (agentInfo.NativeInfo.SignalInfo.useAceRegion)     { useAceRegion  = true; }
//        if (agentInfo.NativeInfo.SignalInfo.useAceUser)       { useAceUser    = true; }
//        if (agentInfo.NativeInfo.SignalInfo.useAceDomain)     { useAceDomain  = true; }
//        if (agentInfo.NativeInfo.SignalInfo.useAceUnique)     { useAceUnique  = true; }
//
//        // TODO:  Increment numCachingAgents if there's an IOCache
//        // if (...) {
//        //   numCachingAgents++;
//        // }
//    }
//
////    u.log("maxOttEntries: "+ maxOttEntries);
////    u.log("maxUser: "+ maxUser);
////    u.log("maxNProcs: "+ maxNProcs);
//
//
//    // Fill in all the widths for the SfiPriv structure.
//    var stWidth = Math.max(1, m.log2ceil(numCachingAgents+1));
//
//    var sfiPriv = {
//        msgType:    { width : 5                                    }, 
//        
//        // STRreq fields                                      
//        ST:         { width : stWidth                              }, // log2 the number of Caching AIUs
//        SD:         { width : 1                                    },
//        SO:         { width : 1                                    },
//        SS:         { width : 1                                    },
//        ErrResult:  { width : 2                                    },
//        AceExOkay:  { width : 1                                    },
//        
//        // CMDreq fields                                      
//        aiuTransId: { width : m.log2ceil(maxOttEntries)            }, // log2 Max Ott Entries
//        aiuId:      { width : Math.max(1, m.log2ceil(numAgents))   }, // log2 #Agents
//        aiuProcId:  { width : m.log2ceil(maxNProcs)                }, // log2 max #procs
//        aceLock:    { width : (haveAceInterfaces    ? 1 : 0)       }, // 1 if any interfaces are ACE
//        aceCache:   { width : (useAceUnique         ? 4 : 0)       }, 
//        aceProt:    { width : (useAceProt           ? 3 : 0)       }, 
//        aceQoS:     { width : (useAceQos            ? 4 : 0)       },
//        aceRegion:  { width : (useAceRegion         ? 4 : 0)       }, 
//        aceUser:    { width : (useAceUser           ? maxUser : 0) }, // Max Agent User
//        aceDomain:  { width : (useAceDomain         ? 2 : 0)       }, 
//        aceUnique:  { width : (useAceUnique         ? 1 : 0)       }
//    }
//
//    // Check against the parameter space.  This also sets the widths to be the 
//    // value from the config file if there's a mismatch.
//    // TODO: There's no reason for this to be in the parameter space any more, but it's 
//    // there for legacy reason.  We should delete it as soon as possible.
//
////    var checkwidths = function(paramObject, paramName, sfiPrivName) {
////        if (paramObject[paramName] != sfiPriv[sfiPrivName].width) {
////            u.log ("SfiPriv Parameterization Error: "+sfiPrivName+" is "+paramObject[paramName]+" instead of "+sfiPriv[sfiPrivName].width);
////            sfiPriv[sfiPrivName].width = paramObject[paramName];
////        }
////    }
////
////    for (var i=0; i<p.AiuInfo.length; i++) {
////
////        var paramObject = p.AiuInfo[i].sfiParameters;
////        checkwidths(paramObject, "wSfiPrivAiuTransId", "aiuTransId");
////        checkwidths(paramObject, "wSfiPrivAiuId",      "aiuId");
////        checkwidths(paramObject, "wSfiPrivAiuProcId",  "aiuProcId");
////        checkwidths(paramObject, "wSfiPrivAceLock",    "aceLock");
////        checkwidths(paramObject, "wSfiPrivAceQos",     "aceQoS");
////        checkwidths(paramObject, "wSfiPrivAceRegion",  "aceRegion");
////        checkwidths(paramObject, "wSfiPrivAceUser",    "aceUser");
////        checkwidths(paramObject, "wSfiPrivAceDomain",  "aceDomain");
////        checkwidths(paramObject, "wSfiPrivAceUnique",  "aceUnique");
////    }
////
////    for (var i=0; i<p.BridgeAiuInfo.length; i++) {
////
////        var paramObject = p.BridgeAiuInfo[i].sfiParameters;
////        checkwidths(paramObject, "wSfiPrivAiuTransId", "aiuTransId");
////        checkwidths(paramObject, "wSfiPrivAiuId",      "aiuId");
////        checkwidths(paramObject, "wSfiPrivAiuProcId",  "aiuProcId");
////        checkwidths(paramObject, "wSfiPrivAceLock",    "aceLock");
////        checkwidths(paramObject, "wSfiPrivAceQos",     "aceQoS");
////        checkwidths(paramObject, "wSfiPrivAceRegion",  "aceRegion");
////        checkwidths(paramObject, "wSfiPrivAceUser",    "aceUser");
////        checkwidths(paramObject, "wSfiPrivAceDomain",  "aceDomain");
////        checkwidths(paramObject, "wSfiPrivAceUnique",  "aceUnique");
////
////    }
//
//
//    // Fill in all the LSB & MSB bits for the SfiPriv structure.
//    var strWidth = 0;
//    var fields = ["msgType", "ST", "SD", "SO", "SS", "ErrResult", "AceExOkay"];
//
//    for (i=0; i<fields.length; i++) {
//        sfiPriv[fields[i]].lsb = strWidth;
//        strWidth += sfiPriv[fields[i]].width;
//        sfiPriv[fields[i]].msb = strWidth-1;
//    }
//
//    var cmdWidth = 0;
//    var fields = ["msgType", "aiuTransId", "aiuId", "aiuProcId", "aceLock", 
//                  "aceCache", "aceProt", "aceQoS", "aceRegion", 
//                  "aceUser", "aceDomain", "aceUnique"];
//
//    for (i=0; i<fields.length; i++) {
//        sfiPriv[fields[i]].lsb = cmdWidth;
//        cmdWidth += sfiPriv[fields[i]].width;
//        sfiPriv[fields[i]].msb = cmdWidth-1;
//    }
//
//    // The Actual SfiPriv width is the max of the width needed 
//    // for CMDreq messages and STRreq messages.
//    var wSfiPriv = Math.max(cmdWidth, strWidth);
//
//    sfiPriv.width = wSfiPriv;
//
//    // u.log("SFIPriv:"+JSON.stringify(sfiPriv));
//
//    return sfiPriv;
//
};
//* eslint no-undef:0 *   /
