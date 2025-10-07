//------------------------------------------------------------------------------
// getSFI()
//
// Returns an SFI interface definition.  The calling ACHL module is expectd to
// pass a set of width parameters, so that this function can query its
// parameters and return an appropriately parameterized SFI interface.
//
// This function expects the following parameters:
//  * wSfiAddr
//  * wSfiLength
//  * wSfiSlvId
//  * wSfiTransId
//  * wSfiReqSfiPriv
//  * wSfiRspSfiPriv
//  * wSfiData
//  * wSfiProtBitsPerByte
//  * wSfiQoS
//
// TODO: Check to ensure that expected the parameters are present
// TODO: Add useAce* parameters
//------------------------------------------------------------------------------
'use strict';
var u = require("../../lib/src/utils.js").init(this);
this.u = u;
exports.getSFI = function(p){

   var SFI = exports.getSFIReqPort(p);
   var SFI_RSP  =  exports.getSFIRspPort(p);

   for (var key in SFI_RSP )
   {
       SFI[key] = SFI_RSP[key];
   }

    return SFI;
};

exports.getSFIReqPort = function(p){

    var SFI = {
        // Request Signals
        req_rdy        : -1                                       ,
        req_vld        : 1                                        ,
        req_last       : 1                                        ,
        req_opc        : 1                                        ,
        req_bursttype  : 1                                        ,
        req_length     : p.wSfiLength                             ,
        req_addr       : p.wSfiAddr                               ,
        req_sfislvid   : p.wSfiSlvId                              ,
        req_sfipriv    : p.wSfiReqSfiPriv                         ,
        req_transid    : p.wSfiTransId                            ,
        /*! if (p.wSfiUrgency > 0) { */
        req_urgency    : p.wSfiUrgency                            ,
        /*! } */
        /*! if (p.wSfiSecurity > 0) { */
        req_security   : p.wSfiSecurity                           ,
        /*! } */
        req_be         : p.wSfiData/8                             ,
        req_data       : p.wSfiData                               ,
        req_protbits   : p.wSfiProtBitsPerByte*(p.wSfiData/8)     ,
        // QoS Sideband
        /*! if (p.wSfiPressure > 0) { */
        req_press      : p.wSfiPressure                           ,
        /*! } */
        /*! if (p.wSfiHurry > 0) { */
        req_hurry      : p.wSfiHurry                              ,
        /*! } */
    };

    return SFI;
};

exports.getSFIRspPort = function(p){

    var SFI = {

        // Response Signals
        rsp_rdy        : 1                                        ,
        rsp_vld        : -1                                       ,
        rsp_last       : -1                                       ,
        rsp_status     : -1                                       ,
        rsp_errcode    : -3                                       ,
        rsp_transid    : 0-(p.wSfiTransId)                        ,
        rsp_sfipriv    : 0-(p.wSfiRspSfiPriv)                     ,
        rsp_data       : 0-(p.wSfiData)                           ,
        rsp_protbits   : 0-(p.wSfiProtBitsPerByte*(p.wSfiData/8)) ,
      
    };

    return SFI;
};







//------------------------------------------------------------------------------
// defaultParamSFI
//
// This is a default set of width parameters which may be used for the call to getSFI().
// If the calling ACHL module doesn't want any width customization
// it may choose to use this struct instead of creating a custom one of its own.
//------------------------------------------------------------------------------
exports.defaultParamSFI = function(paramGlobal, direction){

    var defaultSFI = {
        wSfiAddr            : paramGlobal.wSfiAddr,
        wSfiLength          : paramGlobal.wSfiLength,

        wSfiData            : paramGlobal.wSfiData,
        wSfiSlvId           : paramGlobal.wSfiSlvID,
        wSfiTransId         : paramGlobal.wSfiMstTransID,  // TODO: What if slave?
        wSfiReqSfiPriv      : paramGlobal.wSfiPriv, //wSFIPriv_MsgType+paramGlobal.wSFIPriv_AIUTransID+paramGlobal.wSFIPriv_AIUID+paramGlobal.wSFIPriv_AceProcID+paramGlobal.wSFIPriv_AceLock+paramGlobal.wSFIPriv_AceProt,
        wSfiRspSfiPriv      : 4, //paramGlobal.wSFIPriv_MsgType+paramGlobal.wSFIPriv_AIUTransID+paramGlobal.wSFIPriv_AIUID+paramGlobal.wSFIPriv_AceProcID+paramGlobal.wSFIPriv_AceLock+paramGlobal.wSFIPriv_AceProt,
        wSfiProtBitsPerByte : paramGlobal.wSfiProtBitsPerByte,
        wSfiQoS             : paramGlobal.wSFIQoS,  // TODO: Delete this line.
        wSfiHurry           : paramGlobal.wSfiHurry,  
        wSfiPressure        : paramGlobal.wSfiPressure,
        wSfiUrgency         : paramGlobal.wSfiUrgency, 
        wSfiSecurity        : paramGlobal.wSfiSecurity
    };

    if (direction == "slave") {
        defaultSFI.wSfiTransId = paramGlobal.wSfiSlvTransID;
    }

    if (defaultSFI.wSfiSlvId           == undefined) {defaultSFI.wSfiSlvId            = paramGlobal.wSFISlvID};
    if (defaultSFI.wSfiAddr            == undefined) {defaultSFI.wSfiAddr             = paramGlobal.wAddr};
    if (defaultSFI.wSfiLength          == undefined) {defaultSFI.wSfiLength           = paramGlobal.wLength};
    if (defaultSFI.wSfiData            == undefined) {defaultSFI.wSfiData             = paramGlobal.wData};
    if (defaultSFI.wSfiTransId         == undefined) {defaultSFI.wSfiTransId          = paramGlobal.wTransID};
    if (defaultSFI.wSfiSecurity        == undefined) {defaultSFI.wSfiSecurity         = paramGlobal.wSecurity};
    if (defaultSFI.wSfiProtBitsPerByte == undefined) {defaultSFI.wSfiProtBitsPerByte  = paramGlobal.wProtBitsPerByte};

    if (defaultSFI.wSfiUrgency         == undefined) {defaultSFI.wSfiUrgency          = paramGlobal.wSFIQoS};
    if (defaultSFI.wSfiHurry           == undefined) {defaultSFI.wSfiHurry            = paramGlobal.wSFIQoS};
    if (defaultSFI.wSfiPressure        == undefined) {defaultSFI.wSfiPressure         = paramGlobal.wSFIQoS};

    return defaultSFI;
};

//------------------------------------------------------------------------------
// getSFIMasterFromParameters()
//
// Returns the SFI master interface definition based on the Concerto units' 
// common parameter set.
//
//------------------------------------------------------------------------------
exports.getSfiIntfParams = function(p, direction){

    if (p.wSfiPriv == undefined) {
        u.logError("SFI ERROR: No param.wSfiPriv");
    }

    var param = {
        wSfiAddr            : p.wSfiAddr,
        wSfiLength          : p.wSfiLength,

        wSfiData            : p.wSfiData,
        wSfiSlvId           : p.wSfiSlvID,
        wSfiTransId         : p.wSfiMstTransID, 
//        wSfiReqSfiPriv      : p.wSFIPriv_MsgType+p.wSFIPriv_AIUTransID+p.wSFIPriv_AIUID+p.wSFIPriv_AceProcID+p.wSFIPriv_AceLock+p.wSFIPriv_AceProt,
        wSfiReqSfiPriv      : p.wSfiPriv,
        wSfiRspSfiPriv      : 4, // TODO: This shouldn't be constant.
        wSfiProtBitsPerByte : p.wSfiProtBitsPerByte,
    //    wSfiQoS             : p.wSFIQoS,  // TODO: Delete this line.
        wSfiHurry           : p.wSfiHurry,  
        wSfiPressure        : p.wSfiPressure,
        wSfiUrgency         : p.wSfiUrgency, 
        wSfiSecurity        : p.wSfiSecurity
    };

    if (direction == "slave") {
        param.wSfiTransId = p.wSfiSlvTransID;
        // For DCE
        if (param.wSfiTransId         == undefined) {param.wSfiTransId          = p.wSlvTransID};
    }

    if (param.wSfiSlvId           == undefined) {param.wSfiSlvId            = p.wSFISlvID};
    if (param.wSfiAddr            == undefined) {param.wSfiAddr             = p.wAddr};
    if (param.wSfiLength          == undefined) {param.wSfiLength           = p.wLength};
    if (param.wSfiData            == undefined) {param.wSfiData             = p.wData};

    // For DCE
    if (param.wSfiTransId         == undefined) {param.wSfiTransId          = p.wMstTransID};
    if (param.wSfiTransId         == undefined) {param.wSfiTransId          = p.wTransID};

    if (param.wSfiSecurity        == undefined) {param.wSfiSecurity         = p.wSecurity};
    if (param.wSfiProtBitsPerByte == undefined) {param.wSfiProtBitsPerByte  = p.wProtBitsPerByte};

    if (param.wSfiUrgency         == undefined) {param.wSfiUrgency          = p.wSFIQoS};
    if (param.wSfiHurry           == undefined) {param.wSfiHurry            = p.wSFIQoS};
    if (param.wSfiPressure        == undefined) {param.wSfiPressure         = p.wSFIQoS};

    return param;

};

//------------------------------------------------------------------------------
// getSfiMasterIntfUsed
// getSfiMSlaveIntfUsed
//
// Returns the SFI master interface definition of only cuurently used signals
// in Concerto
//
//------------------------------------------------------------------------------
exports.getSfiMasterIntfUsed = function(p){
    var SFIIntf = exports.getSfiMasterIntf(p);
    // rsp data and protbits are never used
    delete SFIIntf['rsp_data'];
    delete SFIIntf['rsp_protbits'];
    return SFIIntf;
};

exports.getSfiSlaveIntfUsed = function(p){
    var SFIIntf = exports.getSfiSlaveIntf(p);
    // rsp data and protbits are never used
    delete SFIIntf['rsp_data'];
    delete SFIIntf['rsp_protbits'];

    // Slave request is never used
    delete SFIIntf['req_sfislvid'];
    return SFIIntf;
};

//------------------------------------------------------------------------------
// getSFIMasterFromParameters()
//
// Returns the SFI master interface definition based on the Concerto units' 
// common parameter set.
//
//------------------------------------------------------------------------------
exports.getSfiMasterIntf = function(p){

    var SFI = exports.getSfiIntfParams(p, "master");
    return exports.getSFI(SFI);

};
exports.getSfiMasterReqIntf = function(p){

    var SFI = exports.getSfiIntfParams(p, "master");
    return exports.getSFIReqPort(SFI);

};
exports.getSfiMasterRspIntf = function(p){

    var SFI = exports.getSfiIntfParams(p, "master");
    return exports.getSFIRspPort(SFI);

};


//------------------------------------------------------------------------------
// getSFIMasterFromParameters()
//
// Returns the SFI master interface definition based on the Concerto units' 
// common parameter set.
//
//------------------------------------------------------------------------------
exports.getSfiSlaveIntf = function(p){

    var SFI = exports.getSfiIntfParams(p, "slave");
    return exports.getSFI(SFI);

};

exports.getSfiSlaveReqIntf = function(p){

    var SFI = exports.getSfiIntfParams(p, "slave");
    return exports.getSFIReqPort(SFI);

};
exports.getSfiSlaveRspIntf = function(p){

    var SFI = exports.getSfiIntfParams(p, "slave");
    return exports.getSFIRspPort(SFI);

};
//------------------------------------------------------------------------------
// getOCP
//
// This function expects the following parameters:
//  * wOCPAddr
//  * wOCPData
//
//------------------------------------------------------------------------------

exports.getOCP = function(p) {
    var OCP = {

        // Request Signals
        MCmd:           3,
        MAddr:          p.wOCPAddr,
        MData:          p.wOCPData >> (2-p.nOcpAddrOffset),
        SCmdAccept:     -1,

        // Response Signals
        SResp:          -2,
        SData:          0-(p.wOCPData >> (2-p.nOcpAddrOffset)),
        MRespAccept:    1

    };
    return OCP;
};

//------------------------------------------------------------------------------
// defaultParamOCP
//
// This is a default set of width parameters which may be used for the call to getOCP().
// If the calling ACHL module doesn't want any width customization
// it may choose to use this struct instead of creating a custom one of its own.
//------------------------------------------------------------------------------
exports.defaultParamOCP = function(paramGlobal){

    var CSRPARAM = require("../../top/src/csr.js");

    var defaultOCP = {
        wOCPAddr:           CSRPARAM.wCsrRegNum + CSRPARAM.wCsrRegOffset,
        wOCPData:           CSRPARAM.wCsrData,
        nOcpAddrOffset:     0
    };

    return defaultOCP;
};

//------------------------------------------------------------------------------
// getAXI4
//
// Returns an AXI4 interface definition.  The calling ACHL module is expectd to
// pass in a struct of signal widths, so that this function can return an
// appropriately parameterized AXI4 interface.
//
// This function expects the following parameters:
//  * wAceAxId
//  * wAceAxAddr
//  * wAceXData
//  * wAceAwUser
//  * wAceWUser
//  * wAceBUser
//  * wAceArUser
//  * wAceRUser
//
// TODO: Check to ensure that expected the parameters are present
// TODO: Add useAce* parameters
//------------------------------------------------------------------------------
exports.Axi4 = function(params, id) {
    var u = this.u;
    /*! var u = this.u; */

    var unitisDmi = 0 ;
    if (id== undefined) {
        unitisDmi = 1
    } else
    {
         unitisDmi = id ;
    }


    var AXI4 = {};


    // Write Address Signals
    AXI4.awready  = -1;
    AXI4.awvalid  = 1;
    AXI4.awaddr   = u.getParamFromObject(params, 'wAxAddr');
    AXI4.awburst  = 2;
    AXI4.awlen    = 8;
    AXI4.awlock   = 1;
    AXI4.awprot   = 3;
    AXI4.awqos    = (u.getParamFromObject(params, 'useAceQosPort') == 1) ? 4 : 0;
    AXI4.awregion = (u.getParamFromObject(params, 'useAceRegionPort') == 1) ? 4 : 0;
    AXI4.awsize   = 3;
    AXI4.awuser   = u.getParamFromObject(params, 'wAwUser');
    AXI4.awcache  = 4;

    // Write Data Signals
    AXI4.wready   = -1;
    AXI4.wvalid   = 1;
    AXI4.wdata    = u.getParamFromObject(params, 'wAxData');
    AXI4.wuser    = u.getParamFromObject(params, 'wWUser');
    AXI4.wlast    = 1;
    AXI4.wstrb    = u.getParamFromObject(params, 'wAxData')/8;

    // Write Response Signals
    AXI4.bready   = 1;
    AXI4.bvalid   = -1;
    AXI4.bresp    = -2;
    AXI4.buser    = 0-u.getParamFromObject(params, 'wBUser');

    // Read Address Signals
    AXI4.arready  = -1;
    AXI4.arvalid  = 1;
    AXI4.araddr   = u.getParamFromObject(params, 'wAxAddr');
    AXI4.arburst  = 2;
    AXI4.arcache  = 4;
    AXI4.arlen    = 8;
    AXI4.arlock   = 1;
    AXI4.arprot   = 3;
    AXI4.arqos    = (u.getParamFromObject(params, 'useAceQosPort') == 1) ? 4 : 0;
    AXI4.arregion = (u.getParamFromObject(params, 'useAceRegionPort') == 1) ? 4 : 0;
    AXI4.arsize   = 3;
    AXI4.aruser   = u.getParamFromObject(params, 'wArUser');

    // Read Data
    AXI4.rready   = 1;
    AXI4.rvalid   = -1;
    AXI4.rresp    = -2;
    AXI4.rdata    = 0-u.getParamFromObject(params, 'wAxData');
    AXI4.ruser    = 0-u.getParamFromObject(params, 'wRUser');
    AXI4.rlast    = -1;

    //if (params.wAwId != undefined) {
    if (unitisDmi) {
	AXI4.bid      = 0-u.getParamFromObject(params, 'wAwId');
	AXI4.awid     = u.getParamFromObject(params, 'wAwId');

	AXI4.rid      = 0-u.getParamFromObject(params, 'wArId');
	AXI4.arid     = u.getParamFromObject(params, 'wArId');

    } else {
	AXI4.bid      = 0-u.getParamFromObject(params, 'wAxId');
	AXI4.awid     = u.getParamFromObject(params, 'wAxId');

	AXI4.rid      = 0-u.getParamFromObject(params, 'wAxId');
	AXI4.arid     = u.getParamFromObject(params, 'wAxId');
    }

    return AXI4;

};

//------------------------------------------------------------------------------
// defaultParamAXI4
//
// This is a default set of width parameters which may be used for the call to getOCP().
// If the calling ACHL module doesn't want any width customization
// it may choose to use this struct instead of creating a custom one of its own.
//------------------------------------------------------------------------------
exports.defaultParamAXI4 = function(paramGlobal){

    var defaultAXI4 = {
        
        wAxAddr:            u.getParamFromObject(paramGlobal, 'wAxAddr'),
        wAxData:            u.getParamFromObject(paramGlobal, 'wAxData'),
        wArUser:            u.getParamFromObject(paramGlobal, 'wArUser'),
        wAwUser:            u.getParamFromObject(paramGlobal, 'wAwUser'),
        wRUser:             u.getParamFromObject(paramGlobal, 'wRUser'),
        wWUser:             u.getParamFromObject(paramGlobal, 'wWUser'),
        wBUser:             u.getParamFromObject(paramGlobal, 'wBUser'),
        wAwId:              u.getParamFromObject(paramGlobal, 'wAwId'),
        wArId:              u.getParamFromObject(paramGlobal, 'wArId'),
        useAceQosPort:      u.getParamFromObject(paramGlobal, 'useAceQosPort'),
        useAceRegionPort:   u.getParamFromObject(paramGlobal, 'useAceRegionPort')

    };

    return defaultAXI4;
};

//------------------------------------------------------------------------------
// getACELite
//
// Returns an ACELite interface definition.  The calling ACHL module is expected to
// pass in itself (this), so that this function can query it's parameters and
// return an appropriately parameterized ACELite interface.
//
// This function calls getAXI4() to get an AXI4 interface, and then adds to it
// to create an ACELite interface;
//
// This function expects the following parameters in addition to those from getAXI4.
//  * None
//
// TODO: Check to ensure that expected the parameters are present
// TODO: Add useAce* parameters
//------------------------------------------------------------------------------
exports.AceLite = function(params) {
    var u = this.u;
    /*! var u = this.u; */
    var ACE_LITE = exports.Axi4(params,0);

    // Additional Read Address Signals
    ACE_LITE.arsnoop  = 4;
    ACE_LITE.ardomain = 2;
    ACE_LITE.arbar    = 2;

    // Additional Write Address Signals
    ACE_LITE.awdomain = 2;
    ACE_LITE.awsnoop  = 3;
    ACE_LITE.awbar    = 2;

    // Additional Read Response Signals
    // ACE_LITE.rresp    = -4; // Leave at -2

    var isSnoopNeeded = 0;
    if(params.fnNativeInterface == 'ACE') {isSnoopNeeded = 1;}
    if(params.fnNativeInterface == 'ACE-LITE' && ( params.nDvmMsgInFlight || params.nDvmCmpInFlight || params.useIoCache )) {var isSnoopNeeded = 1;}
  //  if (params.isSnoopNeeded != undefined) {
  //      // Inside of AIU we may need to force a snoop interface to the IoCache.
  //      // So there is a local param 'isSnoopNeeded' which is derived for that purpose.
  //      isSnoopNeeded = u.getParamFromObject(params, 'isSnoopNeeded');
  //  } else {
  //      // But at the top level this internal snoop interface might not need to be present.
  //      // And the isSnoopNeeded param will definitely NOT exist at that level.
  //      isSnoopNeeded = 0;
  //  }
    if (u.getParamFromObject(params, 'nDvmMsgInFlight') ||
            u.getParamFromObject(params, 'nDvmCmpInFlight') ||
            isSnoopNeeded) {
        // Snoop Address channel
        ACE_LITE.acready  = 1;
        ACE_LITE.acvalid  = -1;
        ACE_LITE.acaddr   = 0-u.getParamFromObject(params, 'wAxAddr');
        ACE_LITE.acprot   = -3;
        ACE_LITE.acsnoop  = -4;

        // Snoop Response channel
        ACE_LITE.crready  = -1;
        ACE_LITE.crvalid  = 1;
        ACE_LITE.crresp   = 5;

        // Snoop Data channel
        ACE_LITE.cdready  = -1;
        ACE_LITE.cdvalid  = 1;
        ACE_LITE.cddata   = u.getParamFromObject(params, 'wCdData');
        ACE_LITE.cdlast   = 1;
    }

    return ACE_LITE;

};

//------------------------------------------------------------------------------
// getACE
//
// Returns an ACE interface definition.  The calling ACHL module is expected to
// pass in itself (this), so that this function can query it's parameters and
// return an appropriately parameterized ACE interface.
//
// This function calls getACELite() to get an AXI4 interface, and then adds to it
// to create an ACE interface;
//
// This function expects the following parameters in addition to those from getACELite.
//  * wAceCdData
//
// TODO: Check to ensure that expected the parameters are present
// TODO: Add useAce* parameters
//------------------------------------------------------------------------------
exports.Ace = function(params) {
    var u = this.u;
    /*! var u = this.u; */
    var ACE = exports.AceLite(params);

    // Additional Read Response Signals
    ACE.rresp    = -4;

    // Additional Write Address Signals
    ACE.awunique = (u.getParamFromObject(params, 'useAceUniquePort') == 1) ? 1 : 0;

    // Snoop Address channel
    ACE.acready  = 1;
    ACE.acvalid  = -1;
    ACE.acaddr   = 0-u.getParamFromObject(params, 'wAxAddr');
    ACE.acprot   = -3;
    ACE.acsnoop  = -4;

    // Snoop Response channel
    ACE.crready  = -1;
    ACE.crvalid  = 1;
    ACE.crresp   = 5;

    // Snoop Data channel
    ACE.cdready  = -1;
    ACE.cdvalid  = 1;
    ACE.cddata   = u.getParamFromObject(params, 'wCdData');
    ACE.cdlast   = 1;


    // Acknowledge Signals
    ACE.rack     = 1;
    ACE.wack     = 1;

    return ACE;

};


//------------------------------------------------------------------------------
// getAiuAgentIntf
//
// This returns the Interface Descriptos for an agent AIU Interface.  It expects 
// the AIU parameterization (from aiu_agent_param_map.js).
//------------------------------------------------------------------------------
exports.getAiuAgentIntf = function(p){
    var u = this.u;
    /*! var u = this.u; */

//    var params = {
//        wAceAxId            : u.getParamFromObject(p,'wAxId'),
//        wAceAxAddr          : u.getParamFromObject(p,'wAxAddr'),
//        wAceXData           : u.getParamFromObject(p,'wXData'), //128,
//        wAceCdData          : u.getParamFromObject(p,'wCdData'), //128,
//        wAceAwUser          : 4, //u.getParamFromObject(p,'wAwUser'), //4,//u.getParamFromObject(p,'wAwUser'),
//        wAceWUser           : 4, //u.getParamFromObject(p,'wWUser'), //4,//u.getParamFromObject(p,'wAwUser'),
//        wAceBUser           : 4, //u.getParamFromObject(p,'wBUser'), //4,//u.getParamFromObject(p,'wBUser'),
//        wAceArUser          : 4, //u.getParamFromObject(p,'wArUser'), //4,//u.getParamFromObject(p,'wArUser'),
//        wAceRUser           : 4, //u.getParamFromObject(p,'wRUser') //4//u.getParamFromObject(p,'wRUser')
//    };
//
    if (u.getParamFromObject(p,'fnNativeInterface') == 'ACE') {
        return exports.Ace( p );
    } else {
        return exports.AceLite( p );
    }

};


//------------------------------------------------------------------------------
// sfiReqPayloadConcat()
//
// This concatenates together the payload portions of the request half of an
// SFI interface, so that it can be connected to the pseudonoc.
//------------------------------------------------------------------------------
exports.sfiReqPayloadConcat = function(intfDesc, prefix) {

    // Add .startsWith() and endsWith() to the string class
    if (typeof String.prototype.startsWith != 'function') {
        String.prototype.startsWith = function (str){
            return this.slice(0, str.length) == str;
        };
    }

    if (typeof String.prototype.endsWith != 'function') {
        String.prototype.endsWith = function (str){
            return this.slice(-str.length) == str;
        };
    }

    // Get all the signals from the SFI definition and sort them. (So that
    // we don't have concat/unconcat errors because of inconcsistent ordering.
    var i = 0;
    var sigs = [];
    for (var signal in intfDesc ) {
        sigs[i]=signal.toString();
        i++;
    }
    sigs = sigs.sort();

    // Build the ACHL commands to do the concatenation.
    var out = "[";
    var numsigs = sigs.length;
    for (i = 0; i < numsigs; i++) {
        signal = sigs[i];

        if (signal.startsWith("req_")) {
            if (signal.endsWith("rdy")){ }
            else if (signal.endsWith("vld")){ }
            else if (signal.endsWith("last")){ }
            else {
                if (out != "[") { out += ","; }
                out += prefix+signal;
            }
        }
    }
    out += "].concat";
    return out;
};
