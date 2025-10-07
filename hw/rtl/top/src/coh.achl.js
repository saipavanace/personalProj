//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

'use strict';


module.exports = function coh() {

    var u                   = require("../../lib/src/utils.js").init(this);
    var interfaces          = require('./interfaces.js');

    var DCE                 = require('../../dce/src/dce.achl.js');
    var AIU                 = require('../../aiu/src/aiu.achl.js');
    var DMI                 = require('../../dmi/src/dmi.achl.js');

//    var aiu_agent_param_map = require('../../aiu/src/aiu_agent_param_map.js');
//    var aiu_bridge_param_map = require('../../aiu/src/aiu_bridge_param_map.js');
    var aiu_agent_param_map = require('../../aiu/src/aiu_agent_param_map.js');
    var aiu_bridge_param_map = require('../../aiu/src/aiu_bridge_param_map.js');
//    var dce_param_map       = require('../../dce/src/dce_param_map.js'); 
    var dce_param_map       = require('../../dce/src/dce_param_map.js'); 
//    var dmi_param_map       = require('../../dmi/src/dmi_param_map.js'); 
    var dmi_param_map       = require('../../dmi/src/dmi_param_map.js'); 

    require("./top_params.js").defineTopParams(this);

    //------------------------------------------------------------
    // Create parameterized definitions of all our interfaces
    //
    // TODO: Use parameters here instead of constants.  Even
    //       better would be if we were allowed to pass around
    //       the parameterized interface definitions.
    //------------------------------------------------------------
    // Can optionally pass your own struct here instead of using the system default.

    // Can optionally pass your own struct here instead of using the system default.
//    var ACE      = interfaces.getACE(     interfaces.defaultParamACE(  this.param) );
//    var ACE_LITE = interfaces.getACELite( interfaces.defaultParamAXI4( this.param) );
//
    // If don't want all the system-wide default widths, can pass in
    //  your own struct here instead of the defautlParamsSFI() one.
    
    var sfiparams = aiu_agent_param_map(this,0); 


    //------------------------------------------------------------
    // Calculate SFIPriv Widths
    //------------------------------------------------------------

    // TODO: Remove this, since it's in the utils library.

    var wSfiPriv = this.param.Derived.sfiPriv.width;
//    var sfiPriv = require("./sfipriv_calc.js")(this, u);
//    var wSfiPriv = sfiPriv.width;
    
    //------------------------------------------------------------
    // Derived Parameters
    //------------------------------------------------------------
    var nCachingAgents = 0;
    var nDvmCapAius= 0;
    var dvmMap = [];
    var aceAiuMask = [];
    var aiuIdFromCacheId = [];
    var cacheIdFromAiuId = [];
    for (var i=0; i<this.param.AiuInfo.length; i++) {

        var agentInfo = this.param.AiuInfo[i];
        var j         = i;
        aceAiuMask[j] = 0;
        dvmMap[j]     = (agentInfo.NativeInfo.useDvm ? 1 : 0);
        if(agentInfo.NativeInfo.useDvm ){ nDvmCapAius = nDvmCapAius +1 ;}
        cacheIdFromAiuId[j] = undefined;

        if (agentInfo.fnNativeInterface == "ACE") {
            aceAiuMask[j] = 1;
            cacheIdFromAiuId[j] = nCachingAgents;
            aiuIdFromCacheId[nCachingAgents] = j;
            nCachingAgents++;
        }
    }

    for (var i=0; i<this.param.BridgeAiuInfo.length; i++) {
        var agentInfo       = this.param.BridgeAiuInfo[i];
        var j               = this.param.AiuInfo.length + i;
        aceAiuMask[j]       = 0;
        cacheIdFromAiuId[j] = undefined;
        dvmMap[j]           = (agentInfo.NativeInfo.useDvm ? 1 : 0);
    }
    
    //------------------------------------------------------------
    // Instantiate & Connect Bridge AIUs
    //------------------------------------------------------------
    var aiuId = 0;

    for (var i=0; i<this.param.AiuInfo.length; i++) {

        // Get parameterization
        var aiu_params      = aiu_agent_param_map(this,i);
        aiu_params.aiuId    = aiuId;
        aiu_params.nDvmCapAius = nDvmCapAius ;
        aiuId++;
        
        // Add Instance
        this.instance ({ name: 'aiu' + i, moduleName: AIU, params: aiu_params });

        // Export Agent interface to be connected to the top level.
        var agentIntf = interfaces.getAiuAgentIntf(aiu_params);

        u.addConnectionfromInterface("aiu" + i + "_ace_", "aiu" + i + ".ace_", agentIntf);

        // Export the SFI interfaces to be connected to the Noc.
        var sfiMasterIntf = interfaces.getSfiMasterIntf(aiu_params);
        var sfiSlaveIntf = interfaces.getSfiSlaveIntf(aiu_params);

        u.addConnectionfromInterface("aiu" + i + ".sfi_mst_", "aiu" + i + "_sfi_mst_", sfiMasterIntf);
        u.addConnectionfromInterface("aiu" + i + "_sfi_slv_", "aiu" + i + ".sfi_slv_", sfiSlaveIntf);

        // Export the AXI Bypass Interface
//        var axi4Intf = interfaces.getAXI4( interfaces.defaultParamAXI4( aiu_params) );
        var axi4Intf = interfaces.Axi4( aiu_params );
        u.addConnectionfromInterface("aiu" + i + ".axi_mst_", "aiu" + i + "_axi_mst_", axi4Intf);

    }

    // Drive each AIU's AIUID signal
    this.wSfiPriv_aiuId = sfiPriv.aiuId.width;
    this.always(function () {
        /*! for (var i=0; i<this.param.AiuInfo.length; i++) {  */
        aiu$i$.myAiuId = '"i"'.d("this.wSfiPriv_aiuId");
        /*! }                                                       */
    });


    //------------------------------------------------------------
    // Instantiate & Connect Bridge AIUs
    //------------------------------------------------------------
    for (var i=0; i<this.param.BridgeAiuInfo.length; i++) {

        // Get parameterization
        var aiu_params      = aiu_bridge_param_map(this,i);
        aiu_params.aiuId    = aiuId;
        aiu_params.nDvmCapAius = 1 ;
        aiuId++;
        
        // Add Instance
        this.instance ({ name: 'cbi' + i, moduleName: AIU, params: aiu_params });

        // Export Agent interface to be connected to the top level.
        var agentIntf;
        agentIntf = interfaces.Acelite( aiu_params );

        u.addConnectionfromInterface("cbi" + i + "_ace_", "cbi" + i + ".ace_", agentIntf);

        // Export the SFI interfaces to be connected to the Noc.
        var sfiMasterIntf = interfaces.getSfiMasterIntf(aiu_params);
        var sfiSlaveIntf = interfaces.getSfiSlaveIntf(aiu_params);

        u.addConnectionfromInterface("cbi" + i + ".sfi_mst_", "cbi" + i + "_sfi_mst_", sfiMasterIntf);
        u.addConnectionfromInterface("cbi" + i + "_sfi_slv_", "cbi" + i + ".sfi_slv_", sfiSlaveIntf);

    }

    // Drive each AIU's AIUID signal
    this.always(function () {
        /*! for (var i=0; i<this.param.BridgeAiuInfo.length; i++) {  */
        /*!   var j=i + this.param.AiuInfo.length;              */
        cbi$i$.myAiuId = '"i"'.d("this.wSfiPriv_aiuId");
        /*! }                                                        */
    });

 
    //------------------------------------------------------------
    // Instantiate & Connect DCEs
    //------------------------------------------------------------
    var dce_params      = dce_param_map(this);

    dce_params.nCachingAgents   = nCachingAgents;
    dce_params.dvmMap           = dvmMap;
    dce_params.aceAiuMask       = aceAiuMask;
    dce_params.aiuIdFromCacheId = aiuIdFromCacheId;
    dce_params.cacheIdFromAiuId = cacheIdFromAiuId;

    this.instance ({ name: 'dce', moduleName: DCE, params: dce_params});

    var sfiMasterIntf = interfaces.getSfiMasterIntf(dce_params);
    var sfiSlaveIntf = interfaces.getSfiSlaveIntf(dce_params);

    u.addConnectionfromInterface("dce.sfi_mst_", "dce_sfi_mst_", sfiMasterIntf);  // DCE SFI Master
    u.addConnectionfromInterface("dce_sfi_slv_",  "dce.sfi_slv_", sfiSlaveIntf); // DCE SFI Slave

    //------------------------------------------------------------
    // Instantiate & Connect DMIs
    //------------------------------------------------------------
    var dmi_params = dmi_param_map(this, 0 );

    this.instance ({ name: 'dmi', moduleName: DMI, params: dmi_params });

    var AXI4 = interfaces.Axi4( dmi_params );

    u.addConnectionfromInterface("dmi.axi_mst_", "dmi_axi_mst_", AXI4);  // AXI Master to Memory

    var sfiMasterIntf = interfaces.getSfiMasterIntf(dmi_params);
    var sfiSlaveIntf = interfaces.getSfiSlaveIntf(dmi_params);

    var OCPPARAM = interfaces.defaultParamOCP( this.param);
    var OCP = interfaces.getOCP( OCPPARAM );

    u.addConnectionfromInterface("dmi.sfi_mst_", "dmi_sfi_mst_", sfiMasterIntf);   // DMI SFI Master
    u.addConnectionfromInterface("dmi_sfi_slv_",  "dmi.sfi_slv_", sfiSlaveIntf);  // DMI SFI Slave

    u.addConnectionfromInterface("dmi_ocp_",  "dmi.ocp_", OCP);  // DMI OCP Slave

   };

//* eslint no-undef:0 *   /
