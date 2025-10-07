//=============================================================================
// Copyright(C) 2016 Arteris, Inc.
// All rights reserved.
//=============================================================================
// Top level module
//
// Module is called in 3 different instances
// DV Environment - !flexNoC && genFromRoot
// Moment 1 - !flexNoC && !genFromRoot
// Full System - flexNoC && genFromRoot
//
// Variables:
// flexNoC - if there is a pinlist attached
// genFromRoot - if this module is not at the top of the hier
//=============================================================================

'use strict';
module.exports = function concerto_top() {

    this.defineName('concerto_top');
    this.useParamDefaults = true;

    //=========================================================================
    // Modules
    //=========================================================================
    // var NOC                  = require('../../lib/src/pseudo_noc_v2.achl.js');
    var DCE                  = require('../../dce/src/dce.achl.js');
    var AIU                  = require('../../aiu/src/aiu.achl.js');
    var NCB                  = require('../../ncb/src/ncb.achl.js');
    var DMI                  = require('../../dmi/src/dmi_top.achl.js');
    var FSC                  = require('../../fsc/src/functional_safety_controller.achl.js');

    var interfaces           = require('./interfaces.js');
    // var pseudonoc_glb_param  = require('../../lib/src/pseudo_noc_param_map.js');
    var aiu_agent_param_map  = require('../../aiu/src/aiu_agent_param_map.js');
    //var aiu_bridge_param_map = require('../../aiu/src/aiu_bridge_param_map.js');
    var ncb_param_map        = require('../../ncb/src/ncb_param_map.js');
    var dce_param_map        = require('../../dce/src/dce_param_map.js');
    var dmi_param_map        = require('../../dmi/src/dmi_param_map.js');
    var u                    = require('../../lib/src/utils.js').init(this);
    var _                    = require('lodash');

    //=========================================================================
    // Variables
    //=========================================================================
    // Module Variables
    var i, j;
    var agentInfo;
    var instanceName;
    var aiu_params;
    var dce_params;
    var dmi_params;
    var modName;
    var agentIntf;
    var numAiuId = 0;
    var wSfiPriv;

    // Full System Variables
    var pinParams;
    var structures;
    var getmap;
    var allPins;
    var coh_modules = [];
    var maxInitWData = 0;
    var clocksParams;

    // Flags
    var flexNoC;
    var genFromRoot;

    //=========================================================================
    // Parameters Definitions and Validation
    //=========================================================================
    // Declares all paramDefault and param calls
    // Includes second section for parameter validation
    require("./top_params.js").defineTopParams(this);

    // Pick up sfiPriv from parameters.
    // var sfiPriv = this.param.Derived.sfiPriv;
    wSfiPriv = this.param.Derived.sfiPriv.width;

    // TODO: Unsure why this throw is here -Travis 6/20/16
    if (!(wSfiPriv > 4)) {
        throw 'wSfiPriv: ' + wSfiPriv;
    }
    clocksParams = this.param.env.clocks;
    genFromRoot = this.param.genFromRoot;

    // if Pinlists is populated set variables and params
    if (!_.isEmpty(this.param.Pinlists)) {
        pinParams = u.getParam("Pinlists");
        structures = u.getParam("NocStructures");
        getmap = require('./portmap.js');
        allPins = getmap.getAllPins(pinParams, structures, coh_modules);
        flexNoC = true;
    } else {
        flexNoC = false;
    }

    //=========================================================================
    // Derived Parameters
    //=========================================================================

    // Get maxInitWData
    for (i=0; i<this.param.AiuInfo.length; i++) {
        aiu_params = aiu_agent_param_map(this, i);
        maxInitWData = Math.max(maxInitWData, aiu_params.wMasterData);
    }

    for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
        aiu_params = ncb_param_map(this, i);
        maxInitWData = Math.max(maxInitWData, aiu_params.wMasterData);
    }

    for (i = 0; i < this.param.DmiInfo.length; i++) {
        dmi_params = dmi_param_map(this, i);
        maxInitWData = Math.max(maxInitWData, dmi_params.wSfiMasterData);
    }

    //=========================================================================
    // Instantiate AIUs
    //=========================================================================
    if ((this.param.UnitTest == "ALL" || this.param.UnitTest == "AIU")) {

        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Agent AIUs
        //
        var numAgentsToInstance = this.param.AiuInfo.length;
        if (this.param.UnitTest == "AIU" && this.param.AiuInfo.length > 0) {
            numAgentsToInstance = 1;
        }

        for (i=0; i<numAgentsToInstance; i++) {

            var numAiusToInstance = this.param.AiuInfo[i].nAius;
            if (this.param.UnitTest == "AIU") {
                numAiusToInstance = 1;
            }

            for (j=0; j<numAiusToInstance; j++) {
                aiu_params = aiu_agent_param_map(this, i, j);
                aiu_params.maxInitWData = maxInitWData;
                aiu_params.aiuId = numAiuId;
   	        numAiuId++;

                instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;
                coh_modules.push(instanceName);

                if (this.param.filter && !(this.param.filter === instanceName)) continue;

                if (flexNoC) {
                    if (typeof allPins.coh[instanceName] === "string") {
                        modName = allPins.coh[instanceName];
                    } else {
                        modName = instanceName;
                    }
                    this.instance ({ name: instanceName, moduleName: modName});

                } else {

                    // Export ACE interface
                    agentIntf = interfaces.getAiuAgentIntf(aiu_params);

                    // delete cd signals from bundle connection
                    if (this.param.AiuInfo[i].fnNativeInterface === 'ACE-LITE' &&
                        (this.param.AiuInfo[i].NativeInfo.DvmInfo.nDvmMsgInFlight ||
                         this.param.AiuInfo[i].NativeInfo.DvmInfo.nDvmCmpInFlight)) {
                        delete agentIntf['cdready'];
                        delete agentIntf['cdvalid'];
                        delete agentIntf['cddata'];
                        delete agentIntf['cdlast'];
                    }
                    u.defineSlavePortsFromInterface(instanceName+"_ace_", agentIntf);

                    u.addConnectionfromInterface(instanceName+"_ace_", instanceName+".ace_", agentIntf);

                    // Propagate memory signals for each AIU
                    var memoryName;
                    var numBanks = 2;
                    for (var z = 0; z < numBanks; z++) {
                        u.propagateMemorySignalsTopV2(
                            aiu_params['DataMem' + z + '_DataStructure'],
                            instanceName,
                            j,
                            0
                        );
                    }

                    this.instance ({ name: instanceName, moduleName: AIU, params: aiu_params });
                }
            }
        }

//      // tie ACE-Lite CD signals to 0 - to delete completely later
//      this.always (function () {
//          //!! for (var i=0; i<this.param.AiuInfo.length; i++) {
//          //!!     for (var j=0; j<this.param.AiuInfo[i].nAius; j++) {
//          //!!         aiu_params = aiu_agent_param_map(this, i);
//          //!!         instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;
//          //!!         if (this.param.AiuInfo[i].fnNativeInterface === 'ACE-LITE' &&
//          //!!               (this.param.AiuInfo[i].CmpInfo.nDvmMsgInFlight ||
//          //!!                this.param.AiuInfo[i].CmpInfo.nDvmCmpInFlight)) {
//          $instanceName$.ace_cdvalid = '0'.b(1);
//          $instanceName$.ace_cddata = '0'.b("aiu_params['wCdData']");
//          $instanceName$.ace_cdlast = '0'.b(1);
//          //!!         }
//          //!!     }
//          //!! }
//      });

        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Bridge AIUS
        //
        numAgentsToInstance = this.param.BridgeAiuInfo.length;
        if (this.param.UnitTest == "AIU" && this.param.BridgeAiuInfo.length > 0) {
            numAgentsToInstance = 1;
        }

        for (i=0; i<numAgentsToInstance; i++) {

            var numAiusToInstance = this.param.BridgeAiuInfo[i].nAius;
            if (this.param.UnitTest == "AIU") {
                numAiusToInstance = 1;
                // Adding all Agent AIUs to find new AIU ID start
                numAiuId = 0;
                for (j=0; j<this.param.AiuInfo.length; j++) {
                    numAiuId = numAiuId + this.param.AiuInfo[j].nAius;
                }
            }

            for (j=0; j<numAiusToInstance; j++) {
                aiu_params = ncb_param_map(this, i, j);
                aiu_params.maxInitWData = maxInitWData;
                aiu_params.aiuId = numAiuId;
	        numAiuId++;
                aiu_params.interleave_id = j ;
                instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;
                coh_modules.push(instanceName);

                if (this.param.filter && !(this.param.filter === instanceName)) continue;

                if (flexNoC) {
                    if (typeof allPins.coh[instanceName] === "string") {
                        modName = allPins.coh[instanceName];
                    } else {
                        modName = instanceName;
                    }
                    this.instance ({ name: instanceName, moduleName: modName});

                } else {
                    // Export ACE-Lite interfaces AXI signals
                    agentIntf = interfaces.Axi4(aiu_params,0);

                    if ((aiu_params.specification != "EXTERNAL") && (aiu_params.isBridgeInterface == 1)) { // If the interface is not exported/external, and it's a Bridge, AxLen is calculated
                        agentIntf.awlen = Math.min(this.log2ceil(4096/(agentIntf.wdata/8)), 8);
                        agentIntf.arlen = Math.min(this.log2ceil(4096/(agentIntf.wdata/8)), 8);
                    }
                    u.defineSlavePortsFromInterface(instanceName+"_ace_", agentIntf);
                    u.addConnectionfromInterface(instanceName+"_ace_", instanceName+".ace_", agentIntf);

                    // Propagate memory signals for each Bridge
                    var numBanks;
                    numBanks = 2;
                    for (var z = 0; z < numBanks; z++) {
                        u.propagateMemorySignalsTopV2(
                            aiu_params['DataMem' + z + '_DataStructure'],
                            instanceName,
                            j,
                            0
                        );
                    }

                    if (aiu_params.useIoCache) {
                        for (var bank = 0; bank < aiu_params.nTagBanks; bank++) {
                            u.propagateMemorySignalsTopV2(
                                aiu_params.tagStructures[bank],
                                instanceName,
                                j,
                                0
                            );
                            if ((aiu_params.nRPPorts === 2)
                                && (aiu_params.fnReplPolType !== 'RANDOM')
                                && (aiu_params.nWays > 1)) {
                                u.propagateMemorySignalsTopV2(
                                    aiu_params.rpStructures[bank],
                                    instanceName,
                                    j,
                                    0
                                );
                            }
                        }
                        for (var bank = 0; bank < aiu_params.nDataBanks; bank++) {
                            u.propagateMemorySignalsTopV2(
                                aiu_params.dataStructures[bank],
                                instanceName,
                                j,
                                0
                            );
                        }
                    }

                    this.instance ({ name: instanceName, moduleName: NCB, params: aiu_params });
                }
            }
        }

        // tie ACE-Lite signals to default values for Bridge Interfaces
        this.always (function () {
            //!! for (var i=0; i<this.param.BridgeAiuInfo.length; i++) {
            //!!     for (var j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
            //!!         instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;

            $instanceName$.ace_arsnoop[3, 0] = '0'.b(4);
            $instanceName$.ace_ardomain[1, 0] = '01'.b(2);
            $instanceName$.ace_arbar[1, 0] = '0'.b(2);

            $instanceName$.ace_awsnoop[2, 0] = '0'.b(3);
            $instanceName$.ace_awdomain[1, 0] = '01'.b(2);
            $instanceName$.ace_awbar[1, 0] = '0'.b(2);

            //!!     }
            //!! }
        });

    }

    //=========================================================================
    // Instantiate DCEs
    //=========================================================================
    if ((this.param.UnitTest == "ALL" || this.param.UnitTest == "DCE")) {

        for (i=0; i<this.param.DceInfo.nDces; i++) {
            dce_params = dce_param_map(this, i);

            instanceName = 'dce'+i;
            coh_modules.push(instanceName);

            if (this.param.filter && !(this.param.filter === instanceName)) continue;

            if (flexNoC) {
                if (typeof allPins.coh[instanceName] === "string") {
                    modName = allPins.coh[instanceName];
                } else {
                    modName = instanceName;
                }
                this.instance ({ name: instanceName, moduleName: modName});
            } else {
                // Propagate memory signals for the directory
                for (j = 0; j < dce_params.nSnoopFilterSlices; j++) {
                    var memoryName = 'filter' + j + '_';
                    if (dce_params['filter'+j+'_fnFilterType'] === "TAGFILTER") {
                        u.propagateMemorySignalsTopV2(
                            dce_params['filter'+j+'_SnpFilterDataStructure'],
                            instanceName,
                            i,
                            0
                        );
                    }
                }
                this.instance ({ name: instanceName, moduleName: DCE, params: dce_params});
            }
        }
    }

    //=========================================================================
    // Connect dce IRQ signals
    //=========================================================================
    u.output('correctible_error_irq', 1);
    u.output('uncorrectible_error_irq', 1);
    this.always(function () {
        //!!    var aiuNo = 0;
        //!!    for (i=0; i<this.param.AiuInfo.length; i++) {
        //!!        for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
        //!!            instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;
        dce0.aiu$aiuNo$_correctible_error_irq[0] = $instanceName$.IRQ_c;
        dce0.aiu$aiuNo$_uncorrectible_error_irq[0] = $instanceName$.IRQ_uc;
        //!!            aiuNo++;
        //!!        }
        //!!    }
        //!!    aiuNo = 0;
        //!!    for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
        //!!        for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
        //!!            instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;
        dce0.cbi$aiuNo$_correctible_error_irq[0] = $instanceName$.IRQ_c;
        dce0.cbi$aiuNo$_uncorrectible_error_irq[0] = $instanceName$.IRQ_uc;
        //!!            aiuNo++;
        //!!        }
        //!!    }
        //!!    for (i=0; i<this.param.DceInfo.nDces; i++) {
        //!!        instanceName = 'dce'+i;
        //!!        if (i > 0) {
        dce0.dce$i$_correctible_error_irq[0] = $instanceName$.correctible_error_irq;
        dce0.dce$i$_uncorrectible_error_irq[0] = $instanceName$.uncorrectible_error_irq;
        //!!        }
        //!!    }
        //!!    var dmiNo = 0;
        //!!    for (i=0; i<this.param.DmiInfo.length; i++) {
        //!!        for (j=0; j<this.param.DmiInfo[i].nDmis; j++) {
        //!!            instanceName = this.param.DmiInfo[i].strRtlNamePrefix + j;
        dce0.dmi$dmiNo$_correctible_error_irq[0] = $instanceName$.IRQ_c;
        dce0.dmi$dmiNo$_uncorrectible_error_irq[0] = $instanceName$.IRQ_uc;
        //!!            dmiNo++;
        //!!        }
        //!!    }

        // Top level outputs from dce0
        correctible_error_irq[0] = dce0.correctible_error_irq;
        uncorrectible_error_irq[0] = dce0.uncorrectible_error_irq;
    });

    //=========================================================================
    // Instantiate DMIs
    //=========================================================================
    if ((this.param.UnitTest == "ALL" ||  this.param.UnitTest == "DMI") ) {

        for (i=0; i<this.param.DmiInfo.length; i++) {
            for (j=0; j<this.param.DmiInfo[i].nDmis; j++) {
                dmi_params = dmi_param_map(this, i, j);
                instanceName = this.param.DmiInfo[i].strRtlNamePrefix + j;
                coh_modules.push(instanceName);

                if (this.param.filter && !(this.param.filter === instanceName)) continue;

                if (flexNoC) {
                    if (typeof allPins.coh[instanceName] === "string") {
                        modName = allPins.coh[instanceName];
                    } else {
                        modName = instanceName;
                    }
                    this.instance ({ name: instanceName, moduleName: modName});

                } else {

                    this.instance ({ name: instanceName, moduleName: DMI, params: dmi_params });

                    // Memory Connections
                    if (dmi_params.useRttDataEntries) {
                        u.propagateMemorySignalsTopV2(
                            dmi_params.rttDataStructure,
                            instanceName,
                            j,
                            0
                        );
                    }
                    if (dmi_params.useCmc) {
                        for (var bank = 0; bank < dmi_params.nTagBanks; bank++) {
                            u.propagateMemorySignalsTopV2(
                                dmi_params.tagStructures[bank],
                                instanceName,
                                j,
                                0
                            );
                            if ((dmi_params.nRPPorts === 2)
                                && (dmi_params.fnReplPolType !== 'RANDOM')
                                && (dmi_params.nWays > 1)) {
                                u.propagateMemorySignalsTopV2(
                                    dmi_params.rpStructures[bank],
                                    instanceName,
                                    j,
                                    0
                                );
                            }
                        }
                        for (var bank = 0; bank < dmi_params.nDataBanks; bank++) {
                            u.propagateMemorySignalsTopV2(
                                dmi_params.dataStructures[bank],
                                instanceName,
                                j,
                                0
                            );
                        }
                    }
                }
            }
        }
    }


    //=========================================================================
    // Instantiate Functional Saftey Controller
    //=========================================================================
    if (this.param.useResiliency) {
        // Instance
        var fscInstanceName = this.param.FscInfo.strRtlNamePrefix;

        // default wThreshWidth to 8
        // If we need to change this it should come down from the ACHL params
        var wThresWidth = 8;
        if (flexNoC) {
            this.instance ({
                name: fscInstanceName,
                moduleName: fscInstanceName
            });
        } else {
            if ((this.param.filter && (this.param.filter === 'functional_safety_controller')) || !this.param.filter) {
                var fsc_params = {
                    nUnits: coh_modules.length,
                    // for APB interface
                    wAddr: this.param.FscInfo.wSafetyCntrlCSRAddr,
                    wData: this.param.FscInfo.wSafetyCntrlCSRData,
                    wThresWidth: wThresWidth
                };
                this.instance ({
                    name: fscInstanceName,
                    moduleName: FSC,
                    params: fsc_params
                });
            }
        }

        if (!flexNoC && genFromRoot) {
            u.input('clk_check', 1);
        }

        if (flexNoC || (this.param.filter && (this.param.filter === 'functional_safety_controller')) || !this.param.filter) {
            // Fucntional Saftey Controller Connections
            coh_modules.forEach(function (module, index) {
                this.always(function () {
                    $fscInstanceName$.mission_fault_$index$ = $module$.mission_fault[0];
                    $fscInstanceName$.latent_fault_$index$ = $module$.latent_fault[0];
                    $module$.bist_next = $fscInstanceName$.bist_next_$index$[0];
                    $fscInstanceName$.bist_ack_$index$ = $module$.bist_next_ack[0];

                    // 2.2 added signals
                    $fscInstanceName$.cerr_over_thres_fault_$index$ = $module$.cerr_over_thres_fault[0];
                    $module$.cerr_threshold = $fscInstanceName$.cerr_threshold[7,0];
                    $module$.cerr_threshold_vld = $fscInstanceName$.cerr_threshold_vld_$index$[0];
                    $fscInstanceName$.cerr_threshold_ack_$index$ = $module$.cerr_threshold_ack[0];
                });
            }.bind(this));

            // APB interface
            var fscInterface = {
                paddr: this.param.FscInfo.wSafetyCntrlCSRAddr,
                psel: 1,
                penable: 1,
                pwrite: 1,
                pwdata: 1 * this.param.FscInfo.wSafetyCntrlCSRData,
                pready: -1,
                prdata: -1 * this.param.FscInfo.wSafetyCntrlCSRData,
                pslverr: -1
            };
            u.defineSlavePortsFromInterface(fscInstanceName + '_', fscInterface);
            u.addConnectionfromInterface(
                fscInstanceName + '_',
                fscInstanceName + '.',
                fscInterface);

            // mission/latent fault int signals
            u.output('mission_fault_int', 1);
            u.output('latent_fault_int', 1);
            this.always(function () {
                mission_fault_int = $fscInstanceName$.mission_fault_int;
                latent_fault_int = $fscInstanceName$.latent_fault_int;
            });

            // 2.2 added signals
            u.output('cerr_over_thres_int', 1);
            this.always(function () {
                cerr_over_thres_int = $fscInstanceName$.cerr_over_thres_int;
            });
        }
    }

    //=========================================================================
    // Make all sfi connections. Restrict to:
    // DV Modules
    // Moment 1
    //=========================================================================
    if (!flexNoC) {

        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Instantiate PseudoNoC
        // If genFromRoot if specified and sv_noc is not, this is the DV environment and the pseudo noc will be instantiated
        //
        //if (genFromRoot && !this.param.svnoc) {
            // var sfiparams = pseudonoc_glb_param(this);

            // // Calculate Transaction ID Widths for Pseudo-NoC
            // var masterTransIdWidths = [];
            // var masterTransIdWidth = 0;
            // var slaveTransIdWidths = [];
            // var slaveTransIdWidth = 0;
            // var numSfiMasters = 0;
            // var numSfiSlaves  = 0;

            // // Caclulate Address widths for Pseudo-NoC
            // var slaveAddrWidths = [];
            // var masterAddrWidths = [];

            // for (i = 0; i < u.getParam("AiuInfo").length; i++) {
            //     for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
            //         masterTransIdWidths[numSfiMasters] = this.param.AiuInfo[i].Derived.wSfiMasterTransId;
            //         slaveTransIdWidths[numSfiSlaves] = this.param.AiuInfo[i].Derived.wSfiSlaveTransId;
            //         masterTransIdWidth = Math.max(masterTransIdWidth, this.param.AiuInfo[i].Derived.wSfiMasterTransId);
            //         slaveTransIdWidth = Math.max(slaveTransIdWidth, this.param.AiuInfo[i].Derived.wSfiSlaveTransId);
            //         masterAddrWidths[numSfiMasters] = this.param.AiuInfo[i].Derived.wSfiAddr;
            //         slaveAddrWidths[numSfiSlaves] = this.param.AiuInfo[i].Derived.wSfiAddr;
            //         numSfiMasters++;
            //         numSfiSlaves++;
            //     }
            // }

            // for (i = 0; i < u.getParam("BridgeAiuInfo").length; i++) {
            //     for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
            //         masterTransIdWidths[numSfiMasters] = this.param.BridgeAiuInfo[i].Derived.wSfiMasterTransId;
            //         slaveTransIdWidths[numSfiSlaves] = this.param.BridgeAiuInfo[i].Derived.wSfiSlaveTransId;
            //         masterTransIdWidth = Math.max(masterTransIdWidth, this.param.BridgeAiuInfo[i].Derived.wSfiMasterTransId);
            //         slaveTransIdWidth = Math.max(slaveTransIdWidth, this.param.BridgeAiuInfo[i].Derived.wSfiSlaveTransId);
            //         masterAddrWidths[numSfiMasters] = this.param.BridgeAiuInfo[i].Derived.wSfiAddr;
            //         slaveAddrWidths[numSfiSlaves] = this.param.BridgeAiuInfo[i].Derived.wSfiAddr;
            //         numSfiMasters++;
            //         numSfiSlaves++;
            //     }
            // }
            // for (i = 0; i < u.getParam("DceInfo").nDces; i++) {
            //     masterTransIdWidths[numSfiMasters] = this.param.DceInfo.Derived.wSfiMasterTransId;
            //     slaveTransIdWidths[numSfiSlaves] = this.param.DceInfo.Derived.wSfiSlaveTransId;
            //     masterTransIdWidth = Math.max(masterTransIdWidth, this.param.DceInfo.Derived.wSfiMasterTransId);
            //     slaveTransIdWidth = Math.max(slaveTransIdWidth, this.param.DceInfo.Derived.wSfiSlaveTransId);
            //     masterAddrWidths[numSfiMasters] = this.param.DceInfo.Derived.wSfiAddr;
            //     slaveAddrWidths[numSfiSlaves] = this.param.DceInfo.Derived.wSfiAddr;
            //     numSfiMasters++;
            //     numSfiSlaves++;
            // }

            // for (i = 0; i < u.getParam("DmiInfo").length; i++) {
            //     for (j = 0; j < this.param.DmiInfo[i].nDmis; j++) {
            //         masterTransIdWidths[numSfiMasters] = this.param.DmiInfo[i].Derived.wSfiMasterTransId;
            //         slaveTransIdWidths[numSfiSlaves] = this.param.DmiInfo[i].Derived.wSfiSlaveTransId;
            //         masterTransIdWidth = Math.max(masterTransIdWidth, this.param.DmiInfo[i].Derived.wSfiMasterTransId);
            //         slaveTransIdWidth = Math.max(slaveTransIdWidth, this.param.DmiInfo[i].Derived.wSfiSlaveTransId);
            //         masterAddrWidths[numSfiMasters] = this.param.DmiInfo[i].Derived.wAxAddr;
            //         slaveAddrWidths[numSfiSlaves] = this.param.DmiInfo[i].Derived.wSfiAddr;
            //         numSfiMasters++;
            //         numSfiSlaves++;
            //     }
            // }
            //u.log("numSfiMasters = "+numSfiMasters);
            //u.log("numSfiSlaves = "+numSfiSlaves);
            // this.instance ({ name: 'noc', moduleName: NOC, params:{
            //     output_latency        : 1,
            //     input_latency         : 1,
            //     number_of_slaves      : numSfiMasters,
            //     number_of_masters     : numSfiSlaves,
            //     //sink_type             : 'VldAck',
            //     sink_type             : 'RdyVld',
            //     pipeline              : this.false,
            //     wSfiData              : sfiparams.wData,
            //     wSfiOpc               : 1 ,//sfiparams.wOpc
            //     wSfiBurstType         : 1 ,//sfiparams.wBurstType
            //     wSfiLength            : sfiparams.wLength ,
            //     wSfiAddr              : sfiparams.wAddr ,
            //     wSfiSlvId             : sfiparams.wSFISlvID ,
            //     wSfiReqSfiPriv        : wSfiPriv,
            //     wSfiQoS               : sfiparams.wSFIQoS ,
            //     wSfiUrgencyQoS        : sfiparams.wSFIQoS ,
            //     wSfiSecurity          : sfiparams.wSecurity ,
            //     wSfiPressQoS          : sfiparams.wSFIQoS ,
            //     wSfiHurryQoS          : sfiparams.wSFIQoS ,
            //     wSfiProtBitsPerByte   : sfiparams.wProtBitsPerByte ,
            //     wSfiRspStatus         : 1 ,//sfiparams.wStatus
            //     wSfiRspErrCode        : sfiparams.wErrCode ,
            //     wSfiRspSfiPriv        : sfiparams.wSFIRspSFIPriv,
            //     nSfiPendTransId       : Math.pow(2,Math.max.apply(null,slaveTransIdWidths)),
            //     wSfiMasterTransIds    : slaveTransIdWidths,
            //     wSfiSlaveTransIds     : masterTransIdWidths,
            //     wSfiSlaveAddrs        : slaveAddrWidths,
            //     wSfiMasterAddrs       : masterAddrWidths
            // }});
        //}

        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Connect Concerto Units to PseudoNoC
        //
        // running count for noc sfi slv number
        var sfi_slv_num = 0;

        // Agent AIUs
        for (i=0; i<this.param.AiuInfo.length; i++) {
            for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
                aiu_params    = aiu_agent_param_map(this, i);
                instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;

                if (this.param.filter && !(this.param.filter === instanceName)) continue;

                // SFI Interface
                var sfiMasterIntf = interfaces.getSfiMasterIntfUsed(aiu_params);
                if (this.param.useResiliency) {
                    sfiMasterIntf.req_sfipriv = aiu_params.sfiPriv.wSfiPrivWithResiliency;
                    sfiMasterIntf.req_protbits = aiu_params.wSfiProtBitsPerByte * (aiu_params.wSfiData / 8);
                }
                var sfiSlaveIntf = interfaces.getSfiSlaveIntfUsed(aiu_params);
                if (this.param.useResiliency) {
                    sfiSlaveIntf.req_sfipriv = aiu_params.sfiPriv.wSfiPrivWithResiliency;
                    sfiSlaveIntf.req_protbits = aiu_params.wSfiProtBitsPerByte * (aiu_params.wSfiData / 8);
                }

                if (genFromRoot && this.param.useResiliency) {
                    this.always(function () {
                        $instanceName$.clk_check = clk_check;
                    });
                }

                if (genFromRoot) {
                    // if (!this.param.svnoc) {
                    //     u.addConnectionfromInterface(instanceName+".sfi_mst_", "noc.sfi_slv"+sfi_slv_num+"_", sfiMasterIntf);
                    //     u.addConnectionfromInterface("noc.sfi_mst"+sfi_slv_num+"_",  instanceName+".sfi_slv_", sfiSlaveIntf);
                    // } else {
                        u.defineMasterPortsFromInterface(instanceName + "_sfi_mst_", sfiMasterIntf);
                        u.defineSlavePortsFromInterface(instanceName + "_sfi_slv_", sfiSlaveIntf);
                        u.addConnectionfromInterface(instanceName+".sfi_mst_", instanceName+"_sfi_mst_", sfiMasterIntf);
                        u.addConnectionfromInterface(instanceName+"_sfi_slv_", instanceName+".sfi_slv_", sfiSlaveIntf);
                    // }
                } else {
                    u.defineSignalsFromInterface(instanceName + "_sfi_mst_", sfiMasterIntf);
                    u.defineSignalsFromInterface(instanceName + "_sfi_slv_", sfiSlaveIntf);
                    u.addConnectionfromInterface(instanceName+".sfi_mst_", instanceName+"_sfi_mst_", sfiMasterIntf);
                    u.addConnectionfromInterface(instanceName+"_sfi_slv_",  instanceName+".sfi_slv_", sfiSlaveIntf);
                }
                sfi_slv_num++;

                // OCP Interface
                var OCPPARAM = interfaces.defaultParamOCP(this.param);
                var OCP = interfaces.getOCP(OCPPARAM);
                u.defineSlavePortsFromInterface(instanceName+"_ocp_", OCP);
                u.addConnectionfromInterface(instanceName+"_ocp_",  instanceName+".ocp_", OCP);

                // AXI Bypass Interface
                var axi4Intf = interfaces.Axi4( aiu_params ,0);
                if (aiu_params.specification != "EXTERNAL") { // If the interface is not exported/external, AxLen is calculated
                    axi4Intf.awlen = Math.min(this.log2ceil(4096/(axi4Intf.wdata/8)), 8);
                    axi4Intf.arlen = Math.min(this.log2ceil(4096/(axi4Intf.wdata/8)), 8);
                }
                u.defineMasterPortsFromInterface(instanceName+"_axi_mst_", axi4Intf);
                u.addConnectionfromInterface(instanceName+".axi_mst_", instanceName+"_axi_mst_", axi4Intf);
            }
        }

        // Bridge AIUs
        for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
            for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
                aiu_params    = ncb_param_map(this, i);
                instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;

                if (this.param.filter && !(this.param.filter === instanceName)) continue;

                // SFI Interface
                sfiMasterIntf = interfaces.getSfiMasterIntfUsed(aiu_params);
                if (this.param.useResiliency) {
                    sfiMasterIntf.req_sfipriv = aiu_params.sfiPriv.wSfiPrivWithResiliency;
                    sfiMasterIntf.req_protbits = aiu_params.wSfiProtBitsPerByte * (aiu_params.wSfiData / 8);
                }
                sfiSlaveIntf = interfaces.getSfiSlaveIntfUsed(aiu_params);
                if (this.param.useResiliency) {
                    sfiSlaveIntf.req_sfipriv = aiu_params.sfiPriv.wSfiPrivWithResiliency;
                    sfiSlaveIntf.req_protbits = aiu_params.wSfiProtBitsPerByte * (aiu_params.wSfiData / 8);
                }

                if (genFromRoot && this.param.useResiliency) {
                    this.always(function () {
                        $instanceName$.clk_check = clk_check;
                    });
                }

                if (genFromRoot) {
                    // if (!this.param.svnoc) {
                    //     u.addConnectionfromInterface(instanceName+".sfi_mst_", "noc.sfi_slv"+sfi_slv_num+"_", sfiMasterIntf);
                    //     u.addConnectionfromInterface("noc.sfi_mst"+sfi_slv_num+"_",  instanceName+".sfi_slv_", sfiSlaveIntf);
                    // } else {
                        u.defineMasterPortsFromInterface(instanceName + "_sfi_mst_", sfiMasterIntf);
                        u.defineSlavePortsFromInterface(instanceName + "_sfi_slv_", sfiSlaveIntf);
                        u.addConnectionfromInterface(instanceName+".sfi_mst_", instanceName+"_sfi_mst_", sfiMasterIntf);
                        u.addConnectionfromInterface(instanceName+"_sfi_slv_", instanceName+".sfi_slv_", sfiSlaveIntf);
                    // }
                } else {
                    u.defineSignalsFromInterface(instanceName + "_sfi_mst_", sfiMasterIntf);
                    u.defineSignalsFromInterface(instanceName + "_sfi_slv_", sfiSlaveIntf);
                    u.addConnectionfromInterface(instanceName+".sfi_mst_", instanceName+"_sfi_mst_", sfiMasterIntf);
                    u.addConnectionfromInterface(instanceName+"_sfi_slv_",  instanceName+".sfi_slv_", sfiSlaveIntf);
                }
                sfi_slv_num++;

                // OCP Interface
                var OCPPARAM = interfaces.defaultParamOCP(this.param);
                var OCP = interfaces.getOCP(OCPPARAM);
                u.defineSlavePortsFromInterface(instanceName+"_ocp_", OCP);
                u.addConnectionfromInterface(instanceName+"_ocp_",  instanceName+".ocp_", OCP);
            }
        }

        for (i = 0; i<this.param.DceInfo.nDces; i++) {
            // Pseudo noc variety of dce; use wData of 128 only when DV Environment
            dce_params = dce_param_map(this, i);

            // SFI Interface
            sfiMasterIntf = interfaces.getSfiMasterIntfUsed(dce_params);
            if (this.param.useResiliency) {
                sfiMasterIntf.req_sfipriv = dce_params.sfiPriv.wSfiPrivWithResiliency;
                sfiMasterIntf.req_protbits = dce_params.wSfiProtBitsPerByte * (dce_params.wSfiData / 8);
            }
            sfiSlaveIntf = interfaces.getSfiSlaveIntfUsed(dce_params);
            if (this.param.useResiliency) {
                sfiSlaveIntf.req_sfipriv = dce_params.sfiPriv.wSfiPrivWithResiliency;
                sfiSlaveIntf.req_protbits = dce_params.wSfiProtBitsPerByte * (dce_params.wSfiData / 8);
            }
            instanceName = "dce" + i;

            if (this.param.filter && !(this.param.filter === instanceName)) continue;

            // if (i !== 0 || someoneUsesDvms === 0) {
            //     delete sfiMasterIntf.req_data;
            //     delete sfiMasterIntf.req_be;
            //     delete sfiMasterIntf.req_protbits;
            //     delete sfiSlaveIntf.req_data;
            //     delete sfiSlaveIntf.req_be;
            //     delete sfiSlaveIntf.req_protbits;

                // if (genFromRoot && !this.param.svnoc) {
                //     u.signal('sfi_mst'+sfi_slv_num+'_req_data', 128);
                //     u.signal('sfi_mst'+sfi_slv_num+'_req_be', 16);
                //     this.always(function () {
                //         sfi_mst$sfi_slv_num$_req_data[127,0] = noc.sfi_mst$sfi_slv_num$_req_data;
                //         sfi_mst$sfi_slv_num$_req_be[15,0] = noc.sfi_mst$sfi_slv_num$_req_be;
                //         noc.sfi_slv$sfi_slv_num$_req_data[127,0] = '0'.b(128);
                //         noc.sfi_slv$sfi_slv_num$_req_be[15,0] = '0'.b(16);
                //     });
                // }
            // }

            if (genFromRoot && this.param.useResiliency) {
                this.always(function () {
                    $instanceName$.clk_check = clk_check;
                });
            }

            // SFI Interface
            if (genFromRoot) {
                // if (!this.param.svnoc) {
                //     u.addConnectionfromInterface(instanceName+".sfi_mst_", "noc.sfi_slv"+sfi_slv_num+"_", sfiMasterIntf);
                //     u.addConnectionfromInterface("noc.sfi_mst"+sfi_slv_num+"_",  instanceName+".sfi_slv_", sfiSlaveIntf);
                // } else {
                    u.defineMasterPortsFromInterface(instanceName + "_sfi_mst_", sfiMasterIntf);
                    u.defineSlavePortsFromInterface(instanceName + "_sfi_slv_", sfiSlaveIntf);
                    u.addConnectionfromInterface(instanceName+".sfi_mst_", instanceName+"_sfi_mst_", sfiMasterIntf);
                    u.addConnectionfromInterface(instanceName+"_sfi_slv_",  instanceName+".sfi_slv_", sfiSlaveIntf);
                // }
            } else {
                u.defineSignalsFromInterface(instanceName + "_sfi_mst_", sfiMasterIntf);
                u.defineSignalsFromInterface(instanceName + "_sfi_slv_", sfiSlaveIntf);
                u.addConnectionfromInterface(instanceName+".sfi_mst_", instanceName+"_sfi_mst_", sfiMasterIntf);
                u.addConnectionfromInterface(instanceName+"_sfi_slv_",  instanceName+".sfi_slv_", sfiSlaveIntf);
            }
            sfi_slv_num++;

            // OCP Interface
            var OCPPARAM = interfaces.defaultParamOCP(this.param);

            if (i == 0) {
                OCPPARAM.wOCPAddr = OCPPARAM.wOCPAddr + 1;
            }

            var OCP = interfaces.getOCP(OCPPARAM);
            u.defineSlavePortsFromInterface(instanceName+"_ocp_", OCP);
            u.addConnectionfromInterface(instanceName+"_ocp_",  instanceName+".ocp_", OCP);
        }

        // DMIs
        for (i = 0; i < this.param.DmiInfo.length; i++) {
            for (j=0; j<this.param.DmiInfo[i].nDmis; j++) {
                dmi_params = dmi_param_map(this, i);
                instanceName = this.param.DmiInfo[i].strRtlNamePrefix + j;

                if (this.param.filter && !(this.param.filter === instanceName)) continue;

                if (genFromRoot && this.param.useResiliency) {
                    this.always(function () {
                        $instanceName$.clk_check = clk_check;
                    });
                }

                if (genFromRoot) {
                    u.defineMasterPortsFromInterface(instanceName + "_sfi_mst_", dmi_params.SFIMasterInterfaceResiliencyTop);
                    u.defineSlavePortsFromInterface(instanceName + "_sfi_slv_", dmi_params.SFISlaveInterfaceResiliencyTop);
                } else {
                    u.defineSignalsFromInterface(instanceName + "_sfi_mst_", dmi_params.SFIMasterInterfaceResiliencyTop);
                    u.defineSignalsFromInterface(instanceName + "_sfi_slv_", dmi_params.SFISlaveInterfaceResiliencyTop);
                }
                u.addConnectionfromInterface(instanceName+".sfi_mst_", instanceName+"_sfi_mst_", dmi_params.SFIMasterInterfaceResiliencyTop);
                u.addConnectionfromInterface(instanceName+"_sfi_slv_",  instanceName+".sfi_slv_", dmi_params.SFISlaveInterfaceResiliencyTop);
                sfi_slv_num++;

                u.defineSlavePortsFromInterface(instanceName+"_ocp_", dmi_params.OCPSlaveInterface);
                u.addConnectionfromInterface(instanceName+"_ocp_",  instanceName+".ocp_", dmi_params.OCPSlaveInterface);

                u.defineMasterPortsFromInterface(instanceName+"_axi_mst_", dmi_params.AXI4MasterInterface);
                u.addConnectionfromInterface(instanceName + ".axi_mst_", instanceName+"_axi_mst_", dmi_params.AXI4MasterInterface);
            }
        }

    } else {
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Instantiate flexNoC and make all connections from pin
        // matching
        //
        var pinlist = getmap.getPortMap(pinParams, structures, coh_modules);
        for (i in pinlist) {
            var module_name = i;
            if (structures.indexOf(module_name) > -1) {
                this.instance (
                    { name: module_name, moduleName: module_name }
                );
            }
        }

        // remove ace-lite signals from all bridges
        for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
            for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
                instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;
                for (var struct in pinlist) {
                    for (var signal in pinlist[struct].outputs) {
                        if (struct.indexOf(instanceName) > -1 &&
                            (signal.indexOf("arbar") > -1 ||
                             signal.indexOf("ardomain") > -1 ||
                             signal.indexOf("arsnoop") > -1 ||
                             signal.indexOf("awbar") > -1 ||
                             signal.indexOf("awdomain") > -1 ||
                             signal.indexOf("awsnoop") > -1)) {
                            //u.log("deleting " + signal);
                            delete pinlist[struct].outputs[signal];
                        }
                    }
                    for (var signal in pinlist[struct].inputs) {
                        if (struct.indexOf(instanceName) > -1 &&
                            (signal.indexOf("arbar") > -1 ||
                             signal.indexOf("ardomain") > -1 ||
                             signal.indexOf("arsnoop") > -1 ||
                             signal.indexOf("awbar") > -1 ||
                             signal.indexOf("awdomain") > -1 ||
                             signal.indexOf("awsnoop") > -1)) {
                            //u.log("deleting " + signal);
                            delete pinlist[struct].inputs[signal];
                        }
                    }
                    for (var module in pinlist[struct].local) {
                        for (var signal in pinlist[struct].local[module]) {
                            if ((struct.indexOf(instanceName) > -1 ||
                                 module.indexOf(instanceName) > -1) &&
                                (signal.indexOf("arbar") > -1 ||
                                 signal.indexOf("ardomain") > -1 ||
                                 signal.indexOf("arsnoop") > -1 ||
                                 signal.indexOf("awbar") > -1 ||
                                 signal.indexOf("awdomain") > -1 ||
                                 signal.indexOf("awsnoop") > -1)) {
                                //u.log("deleting " + signal);
                                delete pinlist[struct].local[module][signal];
                            }
                        }
                    }
                    for (var module in pinlist[struct].internal) {
                        for (var signal in pinlist[struct].internal[module]) {
                            if ((struct.indexOf(instanceName) > -1 ||
                                 module.indexOf(instanceName) > -1) &&
                                (signal.indexOf("arbar") > -1 ||
                                 signal.indexOf("ardomain") > -1 ||
                                 signal.indexOf("arsnoop") > -1 ||
                                 signal.indexOf("awbar") > -1 ||
                                 signal.indexOf("awdomain") > -1 ||
                                 signal.indexOf("awsnoop") > -1)) {
                                //u.log("deleting " + signal);
                                delete pinlist[struct].internal[module][signal];
                            }
                        }
                    }
                }
            }
        }

//      // remove cd signals from ace-lite with dvm
//      for (i=0; i<this.param.AiuInfo.length; i++) {
//          for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
//              instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;
//              if (this.param.AiuInfo[i].fnNativeInterface === 'ACE-LITE' &&
//                  (this.param.AiuInfo[i].CmpInfo.nDvmMsgInFlight ||
//                   this.param.AiuInfo[i].CmpInfo.nDvmCmpInFlight)) {
//                  for (var struct in pinlist) {
//                      for (var signal in pinlist[struct].outputs) {
//                          if (struct.indexOf(instanceName) > -1 &&
//                              (signal.indexOf("cdready") > -1 ||
//                               signal.indexOf("cdvalid") > -1 ||
//                               signal.indexOf("cddata") > -1 ||
//                               signal.indexOf("cdlast") > -1)) {
//                              delete pinlist[struct].outputs[signal];
//                          }
//                      }
//                      for (var signal in pinlist[struct].inputs) {
//                          if (struct.indexOf(instanceName) > -1 &&
//                              (signal.indexOf("cdready") > -1 ||
//                               signal.indexOf("cdvalid") > -1 ||
//                               signal.indexOf("cddata") > -1 ||
//                               signal.indexOf("cdlast") > -1)) {
//                              delete pinlist[struct].inputs[signal];
//                          }
//                      }
//                      for (var module in pinlist[struct].local) {
//                          for (var signal in pinlist[struct].local[module]) {
//                              if ((struct.indexOf(instanceName) > -1 ||
//                                   module.indexOf(instanceName) > -1) &&
//                                  (signal.indexOf("cdready") > -1 ||
//                                   signal.indexOf("cdvalid") > -1 ||
//                                   signal.indexOf("cddata") > -1 ||
//                                   signal.indexOf("cdlast") > -1)) {
//                                  //u.log("deleting " + signal);
//                                  delete pinlist[struct].local[module][signal];
//                              }
//                          }
//                      }
//                      for (var module in pinlist[struct].internal) {
//                          for (var signal in pinlist[struct].internal[module]) {
//                              if ((struct.indexOf(instanceName) > -1 ||
//                                   module.indexOf(instanceName) > -1) &&
//                                  (signal.indexOf("cdready") > -1 ||
//                                   signal.indexOf("cdvalid") > -1 ||
//                                   signal.indexOf("cddata") > -1 ||
//                                   signal.indexOf("cdlast") > -1)) {
//                                  //u.log("deleting " + signal);
//                                  delete pinlist[struct].internal[module][signal];
//                              }
//                          }
//                      }
//                  }
//              }
//          }
//      }

        var removeIRQ = {};
        for (i=0; i<this.param.DceInfo.nDces; i++) {
            instanceName = 'dce'+i;
            removeIRQ[instanceName] = [];
            if (i === 0) {
                removeIRQ[instanceName].push('correctible_error_irq');
                removeIRQ[instanceName].push('uncorrectible_error_irq');
            } else {
                removeIRQ['dce0'].push('dce' + i + '_correctible_error_irq');
                removeIRQ['dce0'].push('dce' + i + '_uncorrectible_error_irq');
                removeIRQ[instanceName].push('correctible_error_irq');
                removeIRQ[instanceName].push('uncorrectible_error_irq');
            }
        }
        var aiuNo = 0;
        for (i=0; i<this.param.AiuInfo.length; i++) {
            for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
                instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;
                removeIRQ[instanceName] = [];
                removeIRQ['dce0'].push('aiu' + aiuNo + '_correctible_error_irq');
                removeIRQ['dce0'].push('aiu' + aiuNo + '_uncorrectible_error_irq');
                removeIRQ[instanceName].push('IRQ_c');
                removeIRQ[instanceName].push('IRQ_uc');

                if (this.param.useResiliency) {
                    // remove resilience clock
                    removeIRQ[instanceName].push('clk_check');

                    // Remove FSC signals as well
                    removeIRQ[instanceName].push('mission_fault');
                    removeIRQ[instanceName].push('latent_fault');
                    removeIRQ[instanceName].push('bist_next')
                    removeIRQ[instanceName].push('bist_next_ack');

                    // 2.2 added signals
                    removeIRQ[instanceName].push('cerr_over_thres_fault');
                    removeIRQ[instanceName].push('cerr_threshold');
                    removeIRQ[instanceName].push('cerr_threshold_vld');
                    removeIRQ[instanceName].push('cerr_threshold_ack');
                }

                aiuNo++;
            }
        }
        aiuNo = 0;
        for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
            for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
                instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;
                removeIRQ[instanceName] = [];
                removeIRQ['dce0'].push('cbi' + aiuNo + '_correctible_error_irq');
                removeIRQ['dce0'].push('cbi' + aiuNo + '_uncorrectible_error_irq');
                removeIRQ[instanceName].push('IRQ_c');
                removeIRQ[instanceName].push('IRQ_uc');


                if (this.param.useResiliency) {
                    // remove resilience clock
                    removeIRQ[instanceName].push('clk_check');

                    // Remove FSC signals as well
                    removeIRQ[instanceName].push('mission_fault');
                    removeIRQ[instanceName].push('latent_fault');
                    removeIRQ[instanceName].push('bist_next')
                    removeIRQ[instanceName].push('bist_next_ack');

                    // 2.2 added signals
                    removeIRQ[instanceName].push('cerr_over_thres_fault');
                    removeIRQ[instanceName].push('cerr_threshold');
                    removeIRQ[instanceName].push('cerr_threshold_vld');
                    removeIRQ[instanceName].push('cerr_threshold_ack');
                }

                aiuNo++;
            }
        }

        for (var dceIndex=0; dceIndex<this.param.DceInfo.nDces; dceIndex++) {
            instanceName = 'dce' + dceIndex;
            if (this.param.useResiliency) {
                    // remove resilience clock
                    removeIRQ[instanceName].push('clk_check');

                    // Remove FSC signals
                    removeIRQ[instanceName].push('mission_fault');
                    removeIRQ[instanceName].push('latent_fault');
                    removeIRQ[instanceName].push('bist_next')
                    removeIRQ[instanceName].push('bist_next_ack');

                    // 2.2 added signals
                    removeIRQ[instanceName].push('cerr_over_thres_fault');
                    removeIRQ[instanceName].push('cerr_threshold');
                    removeIRQ[instanceName].push('cerr_threshold_vld');
                    removeIRQ[instanceName].push('cerr_threshold_ack');
            }
        }

        var dmiNo = 0;
        for (i=0; i<this.param.DmiInfo.length; i++) {
            for (j=0; j<this.param.DmiInfo[i].nDmis; j++) {
                instanceName = this.param.DmiInfo[i].strRtlNamePrefix + j;
                removeIRQ[instanceName] = [];
                removeIRQ['dce0'].push('dmi' + dmiNo + '_correctible_error_irq');
                removeIRQ['dce0'].push('dmi' + dmiNo + '_uncorrectible_error_irq');
                removeIRQ[instanceName].push('IRQ_c');
                removeIRQ[instanceName].push('IRQ_uc');

                if (this.param.useResiliency) {
                    // remove resilience clock
                    removeIRQ[instanceName].push('clk_check');

                    // Remove FSC signals as well
                    removeIRQ[instanceName].push('mission_fault');
                    removeIRQ[instanceName].push('latent_fault');
                    removeIRQ[instanceName].push('bist_next')
                    removeIRQ[instanceName].push('bist_next_ack');

                    // 2.2 added signals
                    removeIRQ[instanceName].push('cerr_over_thres_fault');
                    removeIRQ[instanceName].push('cerr_threshold');
                    removeIRQ[instanceName].push('cerr_threshold_vld');
                    removeIRQ[instanceName].push('cerr_threshold_ack');
                }

                dmiNo++;
            }
        }

        // Remove all irq signals
        for (var struct in pinlist) {
            for (var signal in pinlist[struct].outputs) {
                if (removeIRQ[struct]) {
                    if (removeIRQ[struct].indexOf(signal) > -1) {
                        //u.log('deleting ' + signal + ' from ' + struct);
                        delete pinlist[struct].outputs[signal];
                    }
                }
            }
            for (var signal in pinlist[struct].inputs) {
                if (removeIRQ[struct]) {
                    if (removeIRQ[struct].indexOf(signal) > -1) {
                        //u.log('deleting ' + signal + ' from ' + struct);
                        delete pinlist[struct].inputs[signal];
                    }
                }
            }
            for (var module in pinlist[struct].internal) {
                for (var signal in pinlist[struct].internal[module]) {
                    if (removeIRQ[module]) {
                        if (removeIRQ[module].indexOf(signal) > -1) {
                            //u.log('deleting ' + signal + ' from ' + struct + ' module: ' + module);
                            delete pinlist[struct].internal[module][signal];
                        }
                    }
                }
            }
            for (var module in pinlist[struct].local) {
                for (var signal in pinlist[struct].local[module]) {
                    if (removeIRQ[module]) {
                        if (removeIRQ[module].indexOf(signal) > -1) {
                            //u.log('deleting ' + signal + ' from ' + struct + ' module: ' + module);
                            delete pinlist[struct].local[module][signal];
                        }
                    }
                }
            }
        }

        // Remove all hurry signals
        var tieSignals = {};
        for (i=0; i<this.param.AiuInfo.length; i++) {
            for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
                instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;
                tieSignals[instanceName] = [];
                tieSignals[instanceName].push('sfi_mst_req_hurry');
                tieSignals[instanceName].push('sfi_slv_req_hurry');
                //tieSignals[instanceName].push('sfi_mst_rsp_data');
                //tieSignals[instanceName].push('sfi_slv_rsp_data');
                //tieSignals[instanceName].push('sfi_mst_rsp_protbits');
                //tieSignals[instanceName].push('sfi_slv_req_protbits');
                //tieSignals[instanceName].push('sfi_slv_req_sfislvid');
            }
        }
        for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
            for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
                instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;
                tieSignals[instanceName] = [];
                tieSignals[instanceName].push('sfi_mst_req_hurry');
                tieSignals[instanceName].push('sfi_slv_req_hurry');
                //tieSignals[instanceName].push('sfi_mst_rsp_data');
                //tieSignals[instanceName].push('sfi_slv_rsp_data');
                //tieSignals[instanceName].push('sfi_mst_rsp_protbits');
                //tieSignals[instanceName].push('sfi_slv_req_protbits');
                //tieSignals[instanceName].push('sfi_slv_req_sfislvid');
            }
        }
        for (i=0; i<this.param.DceInfo.nDces; i++) {
            instanceName = 'dce' + i;
            tieSignals[instanceName] = [];
            tieSignals[instanceName].push('sfi_mst_req_hurry');
            tieSignals[instanceName].push('sfi_slv_req_hurry');
            //tieSignals[instanceName].push('sfi_mst_rsp_data');
            //tieSignals[instanceName].push('sfi_slv_rsp_data');
            //tieSignals[instanceName].push('sfi_mst_rsp_protbits');
            //tieSignals[instanceName].push('sfi_slv_req_protbits');
            //tieSignals[instanceName].push('sfi_slv_req_sfislvid');
        }
        for (i=0; i<this.param.DmiInfo.length; i++) {
            for (j=0; j<this.param.DmiInfo[i].nDmis; j++) {
                instanceName = this.param.DmiInfo[i].strRtlNamePrefix + j;
                tieSignals[instanceName] = [];
                tieSignals[instanceName].push('sfi_mst_req_hurry');
                tieSignals[instanceName].push('sfi_slv_req_hurry');
                //tieSignals[instanceName].push('sfi_mst_rsp_data');
                //tieSignals[instanceName].push('sfi_slv_rsp_data');
                //tieSignals[instanceName].push('sfi_mst_rsp_protbits');
                //tieSignals[instanceName].push('sfi_slv_req_protbits');
                //tieSignals[instanceName].push('sfi_slv_req_sfislvid');
            }
        }

        var specialPinList = [];
        // remove clk and reset_n signals if they do not appear in clock lists
        var removeClk = true;
        var removeReset = true;
        for (i = 0; i < clocksParams.length; i++) {
            this.param.env.structures.forEach(function (struct) {
                if (clocksParams[i].ti === struct.ti) {
                    if (clocksParams[i].clockSignalName) {
                        specialPinList.push({
                            signal: clocksParams[i].clockSignalName,
                            structure: struct.structure,
                            direction: 'input'
                        });
                        if (clocksParams[i].clockSignalName === 'clk') {
                            removeClk = false;
                        }
                    }
                    if (clocksParams[i].rootClock) {
                        specialPinList.push({
                            signal: clocksParams[i].rootClock,
                            structure: struct.structure,
                            direction: 'input'
                        });
                        if (clocksParams[i].clockSignalName === 'clk') {
                            removeClk = false;
                        }
                    }
                    if (clocksParams[i].resetSignalName) {
                        specialPinList.push({
                            signal: clocksParams[i].resetSignalName,
                            structure: struct.structure,
                            direction: 'input'
                        });
                        if (clocksParams[i].resetSignalName === 'reset_n') {
                            removeReset = false;
                        }
                    }
                    if (clocksParams[i].hardResetSignalName) {
                        specialPinList.push({
                            signal: clocksParams[i].hardResetSignalName,
                            structure: struct.structure,
                            direction: 'input'
                        });
                        if (clocksParams[i].hardResetSignalName === 'reset_n') {
                            removeReset = false;
                        }
                    }
                    if (clocksParams[i].enableSignalName) {
                        specialPinList.push({
                            signal: clocksParams[i].enableSignalName,
                            structure: struct.structure,
                            direction: 'input'
                        });
                    }
                    if (clocksParams[i].testModeSignalName) {
                        specialPinList.push({
                            signal: clocksParams[i].testModeSignalName,
                            structure: struct.structure,
                            direction: 'input'
                        });
                    }
                    if (clocksParams[i].powerRegion && clocksParams[i].powerRegion.type !== 'ALWAYS_ON') {
                        var region = clocksParams[i].powerRegion;
                        specialPinList.push({
                            signal: region.name + '_IdleReq',
                            structure: struct.structure,
                            direction: 'input'
                        });
                        specialPinList.push({
                            signal: region.name + '_Idle',
                            structure: struct.structure,
                            direction: 'output'
                        });
                        specialPinList.push({
                            signal: region.name + '_IdleAck',
                            structure: struct.structure,
                            direction: 'output'
                        });
                    }
                }
            });
        }

        if (removeClk) {
            u.input('clk', 0);
        }
        if (removeReset) {
            u.input('reset_n', 0);
        }

        var uniqueInputSignals = [];
        var uniqueOutputSignals = [];
        specialPinList.forEach(function (obj) {
            if (obj.direction === 'input') {
                if (uniqueInputSignals.indexOf(obj.signal) < 0) {
                    uniqueInputSignals.push(obj.signal);
                }
            } else if (obj.direction === 'output') {
                if (uniqueOutputSignals.indexOf(obj.signal) < 0) {
                    uniqueOutputSignals.push(obj.signal);
                }
            }
        });
        uniqueInputSignals.forEach(function (signal)  {
            if ((signal !== 'clk') && (signal !== 'reset_n')) {
                u.input(signal, 1);
            }
        });
        uniqueOutputSignals.forEach(function (signal)  {
            u.output(signal, 1);
        });

        //
        // Define all inputs, outputs, and internal signals
        //
        for (var struct in pinlist) {
            for (var module in pinlist[struct].local) {
                for (var signal in pinlist[struct].local[module]) {
                    var input = pinlist[struct].local[module][signal][0];
                    var width = Math.abs(pinlist[struct].local[module][signal][1]);
                    if (input === '??') {
                        var tieFlag = 0;
                        if (tieSignals[struct] && tieSignals[struct].indexOf(signal) > -1) tieFlag = 1;
                        if (tieFlag) {
                            u.signal(struct + '_' + signal, width);
                        } else {
                            u.output(struct + '_' + signal, width);
                        }
                    }
                }
            }

            for (var module in pinlist[struct].internal) {
                for (var signal in pinlist[struct].internal[module]) {
                    var output = pinlist[struct].internal[module][signal][0];
                    var width = Math.abs(pinlist[struct].internal[module][signal][1]);
                    if (output === '??') {
                        var driveFlag = 0;
                        if (tieSignals[struct] && tieSignals[struct].indexOf(signal) > -1) driveFlag = 1;
                        if (!driveFlag) {
                            u.input(struct + '_' + signal, width);
                        }
                    }
                }
            }

            for (var signal in pinlist[struct].outputs) {
                var width = Math.abs(pinlist[struct].outputs[signal]);
                var nameFlag = false;
                specialPinList.forEach(function (obj) {
                    if (obj.signal === signal &&
                        obj.structure === struct) {
                        nameFlag = true;
                    }
                });
                if (!nameFlag) {
                    u.output(struct + '_' + signal, width);
                }
            }


            for (var signal in pinlist[struct].inputs) {
                var width = Math.abs(pinlist[struct].inputs[signal]);
                var nameFlag = false;
                specialPinList.forEach(function (obj) {
                    if (obj.signal === signal &&
                        obj.structure === struct) {
                        nameFlag = true;
                    }
                });
                if ((signal !== 'clk') && (signal !== 'reset_n') && !(nameFlag)) {
                    u.input(struct + '_' + signal, width);
                }
            }
        }

        // connections from flexNoC to Concerto
        // export outputs from modules that don't have a connection
        this.always(function () {
            //!! for (var struct in pinlist) {
            //!!     for (var module in pinlist[struct].local) {
            //!!         for (var signal in pinlist[struct].local[module]) {
            //!!             var input = pinlist[struct].local[module][signal][0];
            //!!             var width_index = Math.abs(pinlist[struct].local[module][signal][1])-1;
            //!!             if (input != '??') {
            $module$.$input$[$width_index$,0] = $struct$.$signal$;
            //!!             } else {
            $struct$_$signal$[$width_index$,0] = $struct$.$signal$;
            //!!             }
            //!!         }
            //!!     }
            //!! }
        });

        // connections from Concerto to flexNoC
        // export inputs to modules that don't have a connection
        this.always(function () {
            //!! for (var struct in pinlist) {
            //!!     for (var module in pinlist[struct].internal) {
            //!!         for (var signal in pinlist[struct].internal[module]) {
            //!!             var output = pinlist[struct].internal[module][signal][0];
            //!!             var width_index = Math.abs(pinlist[struct].internal[module][signal][1])-1;
            //!!             if (output != '??') {
            $struct$.$signal$[$width_index$,0] = $module$.$output$;
            //!!             } else {
            //!!                 var driveFlag = 0;
            //!!                 if (tieSignals[struct] && tieSignals[struct].indexOf(signal) > -1) driveFlag = 1;
            //!!                 if (driveFlag) {
            $struct$.$signal$[$width_index$,0] = '0'.b("width_index + 1");
            //!!                 } else {
            $struct$.$signal$[$width_index$,0] = $struct$_$signal$;
            //!!                 }
            //!!             }
            //!!         }
            //!!     }
            //!! }
        });

        // export outputs
        this.always(function () {
            //!! for (var struct in pinlist) {
            //!!     for (var signal in pinlist[struct].outputs) {
            //!!         var nameFlag = false;
            //!!         specialPinList.forEach(function (obj) {
            //!!             if (obj.signal === signal &&
            //!!                 obj.structure === struct) {
            //!!                 nameFlag = true;
            //!!             }
            //!!         });
            //!!         if (!nameFlag) {
            //!!             var width_index = Math.abs(pinlist[struct].outputs[signal])-1;
            $struct$_$signal$[$width_index$,0] = $struct$.$signal$;
            //!!         }
            //!!     }
            //!! }
        });

        // export inputs
        this.always(function () {
            //!! for (var struct in pinlist) {
            //!!     for (var signal in pinlist[struct].inputs) {
            //!!         var nameFlag = false;
            //!!         specialPinList.forEach(function (obj) {
            //!!             if (obj.signal === signal &&
            //!!                 obj.structure === struct) {
            //!!                 nameFlag = true;
            //!!             }
            //!!         });
            //!!         if (signal !== 'clk' && signal !== 'reset_n' && !nameFlag) {
            //!!             var width_index = Math.abs(pinlist[struct].inputs[signal])-1;
            $struct$.$signal$[$width_index$,0] = $struct$_$signal$;
            //!!         }
            //!!     }
            //!! }
        });

        var resetSyncList = {};
        for (i = 0; i < clocksParams.length; i++) {
            var resetSignalName = clocksParams[i].resetSignalName;
            if (clocksParams[i].resetDeassertion === 'Deassertion resynchronized in each clock manager') {
                var rootClock = clocksParams[i].rootClock;
                var clockSignalName = clocksParams[i].clockSignalName;
                if (!resetSyncList[resetSignalName]) {
                    resetSyncList[resetSignalName] = {};
                }
                if (!resetSyncList[resetSignalName][rootClock]) {
                    resetSyncList[resetSignalName][rootClock] = {
                        clocks: []
                    }
                    if (clocksParams[i].testModeSignalName) {
                        resetSyncList[resetSignalName][rootClock].testMode = clocksParams[i].testModeSignalName;
                    }
                }
                if (resetSyncList[resetSignalName][rootClock].clocks.indexOf(clockSignalName) < 0) {
                    resetSyncList[resetSignalName][rootClock].clocks.push(clockSignalName);
                }
            }
        }
        var rootClockList = {};
        for (var reset in resetSyncList) {
            for (var rootClock in resetSyncList[reset]) {
                var testModeSignalName = resetSyncList[reset][rootClock].testMode;

                var instanceName = reset + '_' +
                    rootClock + '_synchronizer';
                var synchronizedResetName = reset + '_' +
                    rootClock + '_sync';

                this.instance({
                    name: instanceName,
                    moduleName: 'reset_synchronizer'
                });

                u.signal(synchronizedResetName, 1);
                this.always(function () {
                    $instanceName$.clk = $rootClock$[0];
                    $instanceName$.reset_n = $reset$[0];
                    //!! if (testModeSignalName) {
                    $instanceName$.test_mode = $testModeSignalName$[0];
                    //!! }
                    $synchronizedResetName$ = $instanceName$.reset_sync[0];
                });
                resetSyncList[reset][rootClock].clocks.forEach(function (clock) {
                    if (!rootClockList[clock]) {
                        rootClockList[clock] = rootClock;
                    }
                });
            }
        }

        // Special outputs and inputs
        // for each structure attach PM region output signals
        this.always(function () {
            //!! for (var struct in pinlist) {
            //!!     if (structures.indexOf(struct) > -1) {
            //!!         for (var signal in pinlist[struct].outputs) {
            //!!             var nameFlag = false;
            //!!             specialPinList.forEach(function (obj) {
            //!!                 if (obj.signal === signal &&
            //!!                     obj.structure === struct) {
            //!!                     nameFlag = true;
            //!!                 }
            //!!             });
            //!!             if (nameFlag) {
            $signal$ = $struct$.$signal$[0];
            //!!             }
            //!!         }
            //!!     }
            //!! }
        });

        // for each structure attach clocks, resets, testMode signals, and PM region input signals
        this.always(function () {
            //!! for (var struct in pinlist) {
            //!!     if (structures.indexOf(struct) > -1) {
            //!!         for (var signal in pinlist[struct].inputs) {
            //!!             var nameFlag = false;
            //!!             specialPinList.forEach(function (obj) {
            //!!                 if (obj.signal === signal &&
            //!!                     obj.structure === struct) {
            //!!                     nameFlag = true;
            //!!                 }
            //!!             });
            //!!             if (nameFlag) {
            $struct$.$signal$[0] = $signal$;
            //!!             }
            //!!         }
            //!!     }
            //!! }
        });

        // for each coh module attach clocks according to params
        this.always(function () {
            //!! var i, j;
            //!! for (i=0; i<this.param.AiuInfo.length; i++) {
            //!!     for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
            //!!         var instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;
            //!!         var clkName = this.param.AiuInfo[i].clockPorts[j];
            //!!         var resetName = this.param.AiuInfo[i].resetPorts[j];
            $instanceName$.clk[0] = $clkName$;
            //!!         if (rootClockList[clkName]) {
            //!!             var rootClockName = rootClockList[clkName];
            $instanceName$.reset_n[0] = $resetName$_$rootClockName$_sync;
            //!!         } else {
            $instanceName$.reset_n[0] = $resetName$;
            //!!         }
            //!!     }
            //!! }
            //!! for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
            //!!     for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
            //!!         var instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;
            //!!         var clkName = this.param.BridgeAiuInfo[i].clockPorts[j];
            //!!         var resetName = this.param.BridgeAiuInfo[i].resetPorts[j];
            $instanceName$.clk[0] = $clkName$;
            //!!         if (rootClockList[clkName]) {
            //!!             var rootClockName = rootClockList[clkName];
            $instanceName$.reset_n[0] = $resetName$_$rootClockName$_sync;
            //!!         } else {
            $instanceName$.reset_n[0] = $resetName$;
            //!!         }
            //!!     }
            //!! }
            //!! for (i=0; i<this.param.DceInfo.nDces; i++) {
            //!!     var clkName = this.param.DceInfo.clockPorts[i];
            //!!     var resetName = this.param.DceInfo.resetPorts[i];
            dce$i$.clk[0] = $clkName$;
            //!!     if (rootClockList[clkName]) {
            //!!         var rootClockName = rootClockList[clkName];
            dce$i$.reset_n[0] = $resetName$_$rootClockName$_sync;
            //!!     } else {
            dce$i$.reset_n[0] = $resetName$;
            //!!     }
            //!! }
            //!! for (i=0; i<this.param.DmiInfo.length; i++) {
            //!!     for (var j=0; j<this.param.DmiInfo[i].nDmis; j++) {
            //!!         var instanceName = this.param.DmiInfo[i].strRtlNamePrefix + j;
            //!!         var clkName = this.param.DmiInfo[i].clockPorts[j];
            //!!         var resetName = this.param.DmiInfo[i].resetPorts[j];
            $instanceName$.clk[0] = $clkName$;
            //!!         if (rootClockList[clkName]) {
            //!!             var rootClockName = rootClockList[clkName];
            $instanceName$.reset_n[0] = $resetName$_$rootClockName$_sync;
            //!!         } else {
            $instanceName$.reset_n[0] = $resetName$;
            //!!         }
            //!!     }
            //!! }
            //!! if (this.param.useResiliency) {
            //!!     var instanceName = this.param.FscInfo.strRtlNamePrefix;
            //!!     var clkName = this.param.FscInfo.clockPorts[0];
            //!!     var resetName = this.param.FscInfo.resetPorts[0];
            $instanceName$.clk[0] = $clkName$;
            //!!     if (rootClockList[clkName]) {
            //!!         var rootClockName = rootClockList[clkName];
            $instanceName$.reset_n[0] = $resetName$_$rootClockName$_sync;
            //!!         } else {
            $instanceName$.reset_n[0] = $resetName$;
            //!!     }
            //!! }
        });

        if (this.param.useResiliency) {
            var checkClocks = [];
            var clkName;
            for (i=0; i<this.param.AiuInfo.length; i++) {
                for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
                    clkName = this.param.AiuInfo[i].clockPorts[j];
                    if (checkClocks.indexOf(clkName) === -1) {
                        checkClocks.push(clkName);
                    }
                }
            }
            for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
                for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
                    clkName = this.param.BridgeAiuInfo[i].clockPorts[j];
                    if (checkClocks.indexOf(clkName) === -1) {
                        checkClocks.push(clkName);
                    }
                }
            }
            for (i=0; i<this.param.DceInfo.nDces; i++) {
                clkName = this.param.DceInfo.clockPorts[i];
                if (checkClocks.indexOf(clkName) === -1) {
                    checkClocks.push(clkName);
                }
            }
            for (i=0; i<this.param.DmiInfo.length; i++) {
                for (var j=0; j<this.param.DmiInfo[i].nDmis; j++) {
                    clkName = this.param.DmiInfo[i].clockPorts[j];
                    if (checkClocks.indexOf(clkName) === -1) {
                        checkClocks.push(clkName);
                    }
                }
            }

            checkClocks.forEach(function (clock) {
                u.input(clock + '_check');
            });

            for (i=0; i<this.param.AiuInfo.length; i++) {
                for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
                    var instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;
                    var clkName = this.param.AiuInfo[i].clockPorts[j];
                    this.always(function () {
                        $instanceName$.clk_check[0] = $clkName$_check;
                    });
                }
            }
            for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
                for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
                    var instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;
                    var clkName = this.param.BridgeAiuInfo[i].clockPorts[j];
                    this.always(function () {
                        $instanceName$.clk_check[0] = $clkName$_check;
                    });
                }
            }
            for (i=0; i<this.param.DceInfo.nDces; i++) {
                var instanceName = 'dce' + i;
                var clkName = this.param.DceInfo.clockPorts[i];
                this.always(function () {
                    $instanceName$.clk_check[0] = $clkName$_check;
                });
            }
            for (i=0; i<this.param.DmiInfo.length; i++) {
                for (var j=0; j<this.param.DmiInfo[i].nDmis; j++) {
                    var instanceName = this.param.DmiInfo[i].strRtlNamePrefix + j;
                    var clkName = this.param.DmiInfo[i].clockPorts[j];
                    this.always(function () {
                        $instanceName$.clk_check[0] = $clkName$_check;
                    });
                }
            }
        }
    }
};


//* eslint no-undef:0 *   /
