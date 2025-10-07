//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

'use strict';
module.exports = function concerto_wrapper() {

    this.defineName('concerto_wrapper');
    this.useParamDefaults = true ;
    var TOP = require('./concerto_top.achl.js');

    var interfaces = require('./interfaces.js');
    var aiu_agent_param_map = require('../../aiu/src/aiu_agent_param_map.js');
    //var aiu_bridge_param_map = require('../../aiu/src/aiu_bridge_param_map.js');
    var ncb_param_map        = require('../../ncb/src/ncb_param_map.js');
    var dce_param_map = require('../../dce/src/dce_param_map.js');
    var dmi_param_map = require('../../dmi/src/dmi_param_map.js');
    var u = require("../../lib/src/utils.js").init(this);
    var _ = require("lodash");

    // Flags
    var flexNoC = false;
    var performance = false;

    // Module Variables
    var i, j;
    var instanceName;

    // Full System Variables
    var pinParams;
    var structures;
    var coh_modules = [];
    var module_clocks = [];
    var module_resets = [];

//    this.defineParam({name: "env", type:this.integer});



    u.param("env.clocks[]","int");

    var clocksParams = this.param.env.clocks;

    //------------------------------------------------------------
    // Top-level Parameters
    //------------------------------------------------------------

    require("./top_params.js").defineTopParams(this);

    // Determine if anyone uses DVMs.
    var someoneUsesDvms = 0;
    for(var i = 0; i< this.param.AiuInfo.length; i++) {
        if (this.param.AiuInfo[i].CmpInfo.nDvmMsgInFlight) {
            someoneUsesDvms = 1;
        }
        if (this.param.AiuInfo[i].CmpInfo.nDvmCmpInFlight) {
            someoneUsesDvms = 1;
        }
    }
    // if flexNoc params exist connect it
    if (!_.isEmpty(this.param.Pinlists)) {
        pinParams = u.getParam("Pinlists");
        structures = u.getParam("NocStructures");
        //throw(JSON.stringify(this.param.Pinlists))
        flexNoC = true;
        coh_modules = [];
        module_clocks = [];
        module_resets = [];

        // gather names of coh modules for portmap utility
        for (i=0; i<this.param.AiuInfo.length; i++) {
            for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
                instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;
                coh_modules.push(instanceName);
                if (module_clocks.indexOf(this.param.AiuInfo[i].clockPorts[j]) === -1) {
                    module_clocks.push(this.param.AiuInfo[i].clockPorts[j]);
                }
                if (module_resets.indexOf(this.param.AiuInfo[i].resetPorts[j]) === -1) {
                    module_resets.push(this.param.AiuInfo[i].resetPorts[j]);
                }
            }
        }
        for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
            for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
                instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;
                coh_modules.push(instanceName);
                if (module_clocks.indexOf(this.param.BridgeAiuInfo[i].clockPorts[j]) === -1) {
                    module_clocks.push(this.param.BridgeAiuInfo[i].clockPorts[j]);
                }
                if (module_resets.indexOf(this.param.BridgeAiuInfo[i].resetPorts[j]) === -1) {
                    module_resets.push(this.param.BridgeAiuInfo[i].resetPorts[j]);
                }
            }
        }
        for (i=0; i<this.param.DceInfo.nDces; i++) {
            instanceName = 'dce'+i;
            coh_modules.push(instanceName);
            if (module_clocks.indexOf(this.param.DceInfo.clockPorts[i]) === -1) {
                module_clocks.push(this.param.DceInfo.clockPorts[i]);
            }
            if (module_resets.indexOf(this.param.DceInfo.resetPorts[i]) === -1) {
                module_resets.push(this.param.DceInfo.resetPorts[i]);
            }
        }
        for (i=0; i<this.param.DmiInfo.length; i++) {
            for (j=0; j<this.param.DmiInfo[i].nDmis; j++) {
                instanceName = this.param.DmiInfo[i].strRtlNamePrefix + j;
                coh_modules.push(instanceName);
                if (module_clocks.indexOf(this.param.DmiInfo[i].clockPorts[j]) === -1) {
                    module_clocks.push(this.param.DmiInfo[i].clockPorts[j]);
                }
                if (module_resets.indexOf(this.param.DmiInfo[i].resetPorts[j]) === -1) {
                    module_resets.push(this.param.DmiInfo[i].resetPorts[j]);
                }
            }
        }
    }

    if (this.param.perf !== undefined) {
        performance = u.getParam('perf');
    }

    //------------------------------------------------------------
    // Add top level instance
    //------------------------------------------------------------

    // Use projectName for top level rtl name
    var topName;
    if (this.param.strProjectName) {
        topName = u.getParam('strProjectName');
    } else {
        topName = 'top';
    }
    var topLevelParams = {};
    topLevelParams['genFromRoot'] = 1;
    for (var param in this.param) {
        topLevelParams[param] = this.param[param];
    }
    this.instance ({ name: topName, moduleName: TOP, params: topLevelParams});

    //------------------------------------------------------------
    // Connect exported IRQ signals
    //------------------------------------------------------------
    u.signal('correctible_error_irq', 1);
    u.signal('uncorrectible_error_irq', 1);
    this.always(function () {
        correctible_error_irq = $topName$.correctible_error_irq;
        uncorrectible_error_irq = $topName$.uncorrectible_error_irq;
    });

    //------------------------------------------------------------
    // Export the AXI & ACE interfaces to the top level if not
    // Full System or is performance
    // If Full System use portmap utility and pinlists to
    // connect all ports from moment 1
    //------------------------------------------------------------
    var aiu_params;
    var agentIntf;
    var dmi_params;
    var AXI4;

    if (!flexNoC || performance) {

        // Export ACE interface to agent and export AXI bypass
        for (i=0; i<this.param.AiuInfo.length; i++) {
            for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
                aiu_params = aiu_agent_param_map(this,i);
                instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;

                // Ace Interface to Agent
                agentIntf = interfaces.getAiuAgentIntf(aiu_params);

                // Delete CD signals if ACE-LITE
                if (this.param.AiuInfo[i].fnNativeInterface === 'ACE-LITE' &&
                    (this.param.AiuInfo[i].CmpInfo.nDvmMsgInFlight ||
                     this.param.AiuInfo[i].CmpInfo.nDvmCmpInFlight)) {
                    delete agentIntf['cdready'];
                    delete agentIntf['cdvalid'];
                    delete agentIntf['cddata'];
                    delete agentIntf['cdlast'];
                }

                u.defineSignalsFromInterface(instanceName + "_ace_", agentIntf);
                u.addConnectionfromInterface(instanceName + "_ace_", topName + "." + instanceName + "_ace_", agentIntf);

                // if (this.param.svnoc) {
                    var sfiMasterIntf = interfaces.getSfiMasterIntfUsed(aiu_params);
                    var sfiSlaveIntf  = interfaces.getSfiSlaveIntfUsed(aiu_params);
                    u.defineSignalsFromInterface(instanceName + "_sfi_mst_", sfiMasterIntf);
                    u.defineSignalsFromInterface(instanceName + "_sfi_slv_", sfiSlaveIntf);
                    u.addConnectionfromInterface(topName + "." + instanceName+"_sfi_mst_", instanceName+"_sfi_mst_", sfiMasterIntf);
                    u.addConnectionfromInterface(instanceName+"_sfi_slv_", topName + "." + instanceName+"_sfi_slv_", sfiSlaveIntf);
                // }

                // OCP Interface
                if (!performance) {
                    var OCPPARAM = interfaces.defaultParamOCP( this.param);
                    var OCP = interfaces.getOCP( OCPPARAM );
                    u.defineSignalsFromInterface(instanceName + "_ocp_", OCP);
                    u.addConnectionfromInterface(instanceName + "_ocp_",  topName + "." + instanceName + "_ocp_", OCP);
                }

                // AXI4 Bypass Interface
                AXI4 = interfaces.Axi4( aiu_params , 0 );
                u.defineSignalsFromInterface(instanceName+"_axi_mst_", AXI4);
                u.addConnectionfromInterface( topName + "." + instanceName+"_axi_mst_", instanceName + "_axi_mst_", AXI4);
            }
        }

        // Export ACE-Lite interface
        for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
            for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
                aiu_params = ncb_param_map(this,i);
                instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;

                // AXI4 Interface to Agent
                agentIntf = interfaces.Axi4(aiu_params ,0 );
                u.defineSignalsFromInterface(instanceName + "_ace_", agentIntf);
                u.addConnectionfromInterface(instanceName + "_ace_", topName + "." + instanceName + "_ace_", agentIntf);

                // if (this.param.svnoc) {
                    var sfiMasterIntf = interfaces.getSfiMasterIntfUsed(aiu_params);
                    var sfiSlaveIntf  = interfaces.getSfiSlaveIntfUsed(aiu_params);
                    u.defineSignalsFromInterface(instanceName + "_sfi_mst_", sfiMasterIntf);
                    u.defineSignalsFromInterface(instanceName + "_sfi_slv_", sfiSlaveIntf);
                    u.addConnectionfromInterface(topName + "." + instanceName+"_sfi_mst_", instanceName+"_sfi_mst_", sfiMasterIntf);
                    u.addConnectionfromInterface(instanceName+"_sfi_slv_", topName + "." + instanceName+"_sfi_slv_", sfiSlaveIntf);
                // }

                // OCP Interface
                if (!performance) {
                    var OCPPARAM = interfaces.defaultParamOCP( this.param);
                    var OCP = interfaces.getOCP( OCPPARAM );
                    u.defineSignalsFromInterface(instanceName + "_ocp_", OCP);
                    u.addConnectionfromInterface(instanceName + "_ocp_",  topName + "." + instanceName + "_ocp_", OCP);
                }
            }
        }

        for (i = 0; i<this.param.DceInfo.nDces; i++) {
            var dce_params = dce_param_map(this);
            // if (!this.param.svnoc) {
            //     dce_params.wData = 128;
            // }
            // OCP Interface
            if (!performance) {
                var OCPPARAM = interfaces.defaultParamOCP( this.param);
                var OCP = interfaces.getOCP( OCPPARAM );
                var instanceName = 'dce' + i;
                u.defineSignalsFromInterface(instanceName+"_ocp_", OCP);
                u.addConnectionfromInterface(instanceName+"_ocp_",  topName + "." + instanceName + "_ocp_", OCP);
            }

            // if (this.param.svnoc) {
                var sfiMasterIntf = interfaces.getSfiMasterIntfUsed(dce_params);
                var sfiSlaveIntf  = interfaces.getSfiSlaveIntfUsed(dce_params);

                if (i !== 0 || someoneUsesDvms === 0) {
                    delete sfiMasterIntf.req_data;
                    delete sfiMasterIntf.req_be;
                    delete sfiMasterIntf.req_protbits;
                    delete sfiSlaveIntf.req_data;
                    delete sfiSlaveIntf.req_be;
                    delete sfiSlaveIntf.req_protbits;
                }

                u.defineSignalsFromInterface(instanceName + "_sfi_mst_", sfiMasterIntf);
                u.defineSignalsFromInterface(instanceName + "_sfi_slv_", sfiSlaveIntf);
                u.addConnectionfromInterface(topName + "." + instanceName+"_sfi_mst_", instanceName+"_sfi_mst_", sfiMasterIntf);
                u.addConnectionfromInterface(instanceName+"_sfi_slv_", topName + "." + instanceName+"_sfi_slv_", sfiSlaveIntf);
            // }
        }

        // Export AXI interface to memory
        for (i=0; i<this.param.DmiInfo.length; i++) {
            for (j=0; j<this.param.DmiInfo[i].nDmis; j++) {
                dmi_params = dmi_param_map(this, i );
                instanceName = this.param.DmiInfo[i].strRtlNamePrefix + j;

                u.defineSignalsFromInterface(instanceName + "_sfi_mst_", dmi_params.SFIMasterInterfaceResiliencyTop);
                u.defineSignalsFromInterface(instanceName + "_sfi_slv_", dmi_params.SFISlaveInterfaceResiliencyTop);
                u.addConnectionfromInterface(topName + "." + instanceName+"_sfi_mst_", instanceName+"_sfi_mst_", dmi_params.SFIMasterInterfaceResiliencyTop);
                u.addConnectionfromInterface(instanceName+"_sfi_slv_", topName + "." + instanceName+"_sfi_slv_", dmi_params.SFISlaveInterfaceResiliencyTop);

                // OCP Interface
                if (!performance) {
                    u.defineSignalsFromInterface(instanceName + "_ocp_", dmi_params.OCPSlaveInterface);
                    u.addConnectionfromInterface(instanceName + "_ocp_",  topName + "." + instanceName + "_ocp_", dmi_params.OCPSlaveInterface);
                }

                // AXI4 Interface to Memory
                u.defineSignalsFromInterface(instanceName + "_axi_mst_", dmi_params.AXI4MasterInterface);
                u.addConnectionfromInterface( topName + "." + instanceName + "_axi_mst_", instanceName + "_axi_mst_", dmi_params.AXI4MasterInterface);
            }
        }
    } else {
        // Export flexNoC inputs and outputs, and any other unconnected signal
        var getmap = require('./portmap.js');
        var pinlist = getmap.getPortMap(pinParams, structures, coh_modules);


        // remove clk and reset_n signals if they do not appear in clock lists
        var removeClk = true;
        var removeReset = true;
        for (i = 0; i<this.param.AiuInfo.length; i++) {
            for (j = 0; j<this.param.AiuInfo[i].nAius; j++) {
                if (this.param.AiuInfo[i].clockPorts[j] === 'clk') { removeClk = false; }
                if (this.param.AiuInfo[i].resetPorts[j] === 'reset_n') { removeReset = false; }
            }
        }
        for (i = 0; i<this.param.BridgeAiuInfo.length; i++) {
            for (j = 0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
                if (this.param.BridgeAiuInfo[i].clockPorts[j] === 'clk') { removeClk = false; }
                if (this.param.BridgeAiuInfo[i].resetPorts[j] === 'reset_n') { removeReset = false; }
            }
        }
        for (i = 0; i<this.param.DceInfo.nDces; i++) {
            if (this.param.DceInfo.clockPorts[i] === 'clk') { removeClk = false; }
            if (this.param.DceInfo.resetPorts[i] === 'reset_n') { removeReset = false; }
        }
        for (i = 0; i<this.param.DmiInfo.length; i++) {
            for (j = 0; j < this.param.DmiInfo[i].nDmis; j++) {
                if (this.param.DmiInfo[i].clockPorts[j] === 'clk') { removeClk = false; }
                if (this.param.DmiInfo[i].resetPorts[j] === 'reset_n') { removeReset = false; }
            }
        }

        if (removeClk) {
            u.input('clk', 0);
        }
        if (removeReset) {
            u.input('reset_n', 0);
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

        // remove cd signals from ace-lite with dvm
        for (i=0; i<this.param.AiuInfo.length; i++) {
            for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
                instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;
                if (this.param.AiuInfo[i].fnNativeInterface === 'ACE-LITE' &&
                    (this.param.AiuInfo[i].CmpInfo.nDvmMsgInFlight ||
                     this.param.AiuInfo[i].CmpInfo.nDvmCmpInFlight)) {
                    for (var struct in pinlist) {
                        for (var signal in pinlist[struct].outputs) {
                            if (struct.indexOf(instanceName) > -1 &&
                                (signal.indexOf("cdready") > -1 ||
                                 signal.indexOf("cdvalid") > -1 ||
                                 signal.indexOf("cddata") > -1 ||
                                 signal.indexOf("cdlast") > -1)) {
                                delete pinlist[struct].outputs[signal];
                            }
                        }
                        for (var signal in pinlist[struct].inputs) {
                            if (struct.indexOf(instanceName) > -1 &&
                                (signal.indexOf("cdready") > -1 ||
                                 signal.indexOf("cdvalid") > -1 ||
                                 signal.indexOf("cddata") > -1 ||
                                 signal.indexOf("cdlast") > -1)) {
                                delete pinlist[struct].inputs[signal];
                            }
                        }
                        for (var module in pinlist[struct].local) {
                            for (var signal in pinlist[struct].local[module]) {
                                if ((struct.indexOf(instanceName) > -1 ||
                                     module.indexOf(instanceName) > -1) &&
                                    (signal.indexOf("cdready") > -1 ||
                                     signal.indexOf("cdvalid") > -1 ||
                                     signal.indexOf("cddata") > -1 ||
                                     signal.indexOf("cdlast") > -1)) {
                                    //u.log("deleting " + signal);
                                    delete pinlist[struct].local[module][signal];
                                }
                            }
                        }
                        for (var module in pinlist[struct].internal) {
                            for (var signal in pinlist[struct].internal[module]) {
                                if ((struct.indexOf(instanceName) > -1 ||
                                     module.indexOf(instanceName) > -1) &&
                                    (signal.indexOf("cdready") > -1 ||
                                     signal.indexOf("cdvalid") > -1 ||
                                     signal.indexOf("cddata") > -1 ||
                                     signal.indexOf("cdlast") > -1)) {
                                    //u.log("deleting " + signal);
                                    delete pinlist[struct].internal[module][signal];
                                }
                            }
                        }
                    }
                }
            }
        }

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

            // remove resilience clock
            if (this.param.useResiliency) {
                    removeIRQ[instanceName].push('clk_check');
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
                aiuNo++;

                // remove resilience clock
                if (this.param.useResiliency) {
                    removeIRQ[instanceName].push('clk_check');
                }
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
                aiuNo++;

                // remove resilience clock
                if (this.param.useResiliency) {
                    removeIRQ[instanceName].push('clk_check');
                }
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

                // remove resilience clock
                if (this.param.useResiliency) {
                    removeIRQ[instanceName].push('clk_check');
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
        var removeHurry = {};
        for (i=0; i<this.param.AiuInfo.length; i++) {
            for (j=0; j<this.param.AiuInfo[i].nAius; j++) {
                instanceName = this.param.AiuInfo[i].strRtlNamePrefix + j;
                removeHurry[instanceName] = [];
                removeHurry[instanceName].push('sfi_mst_req_hurry');
                removeHurry[instanceName].push('sfi_slv_req_hurry');
            }
        }
        for (i=0; i<this.param.BridgeAiuInfo.length; i++) {
            for (j=0; j<this.param.BridgeAiuInfo[i].nAius; j++) {
                instanceName = this.param.BridgeAiuInfo[i].strRtlNamePrefix + j;
                removeHurry[instanceName] = [];
                removeHurry[instanceName].push('sfi_mst_req_hurry');
                removeHurry[instanceName].push('sfi_slv_req_hurry');
            }
        }
        for (i=0; i<this.param.DceInfo.nDces; i++) {
            instanceName = 'dce' + i;
            removeHurry[instanceName] = [];
            removeHurry[instanceName].push('sfi_mst_req_hurry');
            removeHurry[instanceName].push('sfi_slv_req_hurry');
        }
        for (i=0; i<this.param.DmiInfo.length; i++) {
            for (j=0; j<this.param.DmiInfo[i].nDmis; j++) {
                instanceName = this.param.DmiInfo[i].strRtlNamePrefix + j;
                removeHurry[instanceName] = [];
                removeHurry[instanceName].push('sfi_mst_req_hurry');
                removeHurry[instanceName].push('sfi_slv_req_hurry');
            }
        }
        for (var struct in pinlist) {
            for (var module in pinlist[struct].internal) {
                for (var signal in pinlist[struct].internal[module]) {
                    if (removeHurry[struct]) {
                        if (removeHurry[struct].indexOf(signal) > -1) {
                            //u.log('deleting ' + signal + ' from ' + struct + ' module: ' + module);
                            delete pinlist[struct].internal[module][signal];
                        }
                    }
                }
            }
            for (var module in pinlist[struct].local) {
                for (var signal in pinlist[struct].local[module]) {
                    if (removeHurry[struct]) {
                        if (removeHurry[struct].indexOf(signal) > -1) {
                            //u.log('deleting ' + signal + ' from ' + struct + ' module: ' + module);
                            delete pinlist[struct].local[module][signal];
                        }
                    }
                }
            }
        }

        var specialPinList = [];
        for (i = 0; i < clocksParams.length; i++) {
            this.param.env.structures.forEach(function (struct) {
                if (clocksParams[i].ti === struct.ti) {
                    if (clocksParams[i].clockSignalName) {
                        specialPinList.push({
                            signal: clocksParams[i].clockSignalName,
                            structure: struct.structure,
                            direction: 'input'
                        });
                    }
                    if (clocksParams[i].resetSignalName) {
                        specialPinList.push({
                            signal: clocksParams[i].resetSignalName,
                            structure: struct.structure,
                            direction: 'input'
                        });
                    }
                    if (clocksParams[i].hardResetSignalName) {
                        specialPinList.push({
                            signal: clocksParams[i].hardResetSignalName,
                            structure: struct.structure,
                            direction: 'input'
                        });
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

        // connect all unique signals
        this.always(function () {
            //!! uniqueInputSignals.forEach(function (signal)  {
            $topName$.$signal$ = $signal$;
            //!! });
            //!! uniqueOutputSignals.forEach(function (signal)  {
            $signal$ = $topName$.$signal$;
            //!! });
        });

        // export unconnected local signals
        this.always(function () {
            //!! for (var struct in pinlist) {
            //!!     for (var module in pinlist[struct].local) {
            //!!         for (var signal in pinlist[struct].local[module]) {
            //!!             var input = pinlist[struct].local[module][signal][0];
            //!!             if (input == '??') {
            //!!                 var tieFlag = 0;
            //!!                 for (var i = 0; i < this.param.DceInfo.nDces; i++) {
            //!!                     if (signal === 'coh_dce' + i + '_ctis_req_data' ||
            //!!                         signal === 'coh_dce' + i + '_ctis_req_be') {
            //!!                         tieFlag = 1;
            //!!                     }
            //!!                 }
            //!!                 if (!tieFlag) {
            $struct$_$signal$ = $topName$.$struct$_$signal$;
            //!!                 }
            //!!             }
            //!!         }
            //!!     }
            //!! }
        });

        // export unconnected internal signals
        this.always(function () {
            //!! for (var struct in pinlist) {
            //!!     for (var module in pinlist[struct].internal) {
            //!!         for (var signal in pinlist[struct].internal[module]) {
            //!!             var output = pinlist[struct].internal[module][signal][0];
            //!!             if (output == '??') {
            //!!                 var driveFlag = 0;
            //!!                 for (var i = 0; i < this.param.DceInfo.nDces; i++) {
            //!!                     if (signal === 'coh_dce' + i + '_ctim_req_data' ||
            //!!                         signal === 'coh_dce' + i + '_ctim_req_be') {
            //!!                         driveFlag = 1;
            //!!                     }
            //!!                 }
            //!!                 if (!driveFlag) {
            $topName$.$struct$_$signal$ = $struct$_$signal$;
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
            $struct$_$signal$ = $topName$.$struct$_$signal$;
            //!!         }
            //!!     }
            //!! }
        });

        // export inputs
        // clocks that are in the parameters are a special case
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
            //!!         if ((signal !== 'clk') && (signal !== 'reset_n') && !nameFlag) {
            $topName$.$struct$_$signal$ = $struct$_$signal$;
            //!!         }
            //!!     }
            //!! }
        });

        // Add clk_check connections if useResiliency is enabled
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
            this.always(function () {
                //!! checkClocks.forEach(function (clock) {
                $topName$.$clock$_check[0] = $clock$_check;
                //!! });
            });
        }
    }
};
//* eslint no-undef:0 *   /
