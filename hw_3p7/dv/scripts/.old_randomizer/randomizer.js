const fs = require('fs');
const path = require('path');
const constraints = require('./constraints.js');
const elaborate = require('./elaborate.js');
const utils = require('./utils.js');
const format = utils.stripIndent;

const filepath = `${process.env.WORK_TOP}/dv/scripts/randomizer/params.json`;
let nChis = 0;
let nIoaius = 0;
let nDiis = 0;
let nDmis = 0;
let params = [];
let nGpra = 0;
let dceInterleaveBits = "";
let enableResilience = "";
let enableUnitDuplication = "";
let nSnoopFilters = 0;
let nCNUnits = 0;
let nCaius = 0;
let nNCaius = 0;
let meshSize = [];

function generateConfigFile(seed) {
    try {
        const data = fs.readFileSync(filepath, 'utf8');
        // reset all values
        params = [];
        dceInterleaveBits = "";
        enableResilience = "";
        enableUnitDuplication = "";
        nSnoopFilters = 0;
        nCNUnits = 0;
        nCaius = 0;
        nNCaius = 0;
        meshSize = [];
        params = JSON.parse(data);
        elaborate(params, seed);
        nSnoopFilters = parseInt(params.system.nSnoopFilters);
        for (let i = 0; i < params.sockets.ioaiu.items.length; i++) {
            if (params.sockets.ioaiu.items[i].protocol == 'ACE') {
                nCaius += 1;
            }
        }
        nCaius += params.sockets.chi.items.length;
        nNCaius = (params.sockets.chi.items.length + params.sockets.ioaiu.items.length) - (nCaius);
        nChis = params.sockets.chi.count;
        nIoaius = params.sockets.ioaiu.count;
        nDiis = params.sockets.dii.count;
        nDmis = params.sockets.dmi.count;

        // FIXME: DCE count is updated to match DMI and hence we cannot use DCE count directly below. This needs to be fixed
        nCNUnits = params.sockets.chi.count + params.sockets.ioaiu.count + params.sockets.dii.count + params.sockets.dce.count + params.sockets.dmi.count + 2;
        meshSize = utils.getClosestFactors(nCNUnits);
        constraints.forEach((constraint) => {
            constraint.action(params);
        });

        console.log('Generating a random config with seed: ' + (seed));
        const tclConfig = generateConfigTcl(seed);

        const configDir = path.resolve(`${process.env.MAESTRO_EXAMPLES}/../base_configs/`);
        const subDir = path.resolve(`${configDir}/hw_randomizer_config_${seed}`);
        const filePath = `${subDir}/hw_randomizer_config_${seed}.tcl`;
        const paramsPath = `${subDir}/config_params_${seed}.json`;

        // Check if configDir exists, if not create it
        if (!fs.existsSync(configDir)) {
            fs.mkdirSync(configDir, { recursive: true });
        }

        // Check if subDir exists, if not create it
        if (!fs.existsSync(subDir)) {
            fs.mkdirSync(subDir, { recursive: true });
        }

        fs.writeFileSync(filePath, tclConfig, 'utf8');
        fs.writeFileSync(paramsPath, JSON.stringify(params, null, 2), 'utf8');
        console.log('configfile has been successfully created.');
    } catch (err) {
        console.error('Error reading files:', err);
    }
}

function generateConfigTcl(seed) {
    let tcl = '';

    // Phase 1
    // Create Project
    // Create Chip
    // Create Clock
    // Create Power
    // Create scripts for Synthesis
    tcl += genProject(seed);
    tcl += genChip(seed);
    tcl += genPower(seed);
    tcl += genClocks(seed);
    tcl += genSynthesisScripts(seed);

    // PHASE 2
    // Create system
    // Create subsystem
    // Set Safety Params
    // Create sockets
    // Create memory map

    tcl += genSystem(seed);
    tcl += genSubsystem(seed);
    tcl += genSafety(seed);
    tcl += genSockets(seed);
    tcl += genMemoryMap(seed);

    // PHASE 3: ARCHITECTURAL DESIGN
    // Create topology
    // Select coherent Template
    // Auto generate units
    // Set the node positions of the units in the topology
    // Generate topology for routing
    // Auto generate adapters
    // Auto generate the Control and Status Register (CSR) network

    tcl += genTopology(seed);
    tcl += genMesh(seed);
    tcl += genSnoopFilters(seed);
    tcl += genNetwork(seed);

    // Generate PreMap Params
    tcl += genPreMap();

    tcl += genPostMap(seed);
    tcl += moveToFinalState(seed);
    tcl += genCollateral(seed);

    return tcl;
    // return genHeaders() 
    // + genSynthesisScripts()
    // + genClocks()
    // + genSafety()
    // + genSockets()
    // +genSystemSettings()
    // // +genInitiatorGroups(params);
    // +genMemoryMap()
    // // +genFooter()
    // // +genConnectivity()
    // +genNetwork();
    // // +genPacketizers();

    // return tcl;
}

const genProject = (seed) => {
    const proj = format(`\

        # Project: ${params.project_name}
        # Ncore Version: ${params.ncore_version}
        # Randomizer Version: ${params.randomizer_version}

        # Create Project
        set designName ${params.project_name}
        set fileName $designName.mpf
        if {[file exists $fileName] == 1} {
            puts "Renaming $fileName to \${fileName}.bak"
            file rename -force $fileName \${fileName}.bak
        }

        set project [create_project -name $designName  -license_token Arteris/Dev]`
    );

    return proj;
}

const genChip = (seed) => {
    const chip = format(`\

        # Create Chip
        set chip [create_object -type chip -parent $project -name default_chip]`
    );

    return chip;
}

const genSynthesisScripts = (seed) => {
    const synth = format(`\

        # Create Synthesis Scripts
        set synSettingsName project/default_chip/synthesisSettings
        set_attribute -object $synSettingsName -name clockUncertainty -value "15"
        set_attribute -object $synSettingsName -name rtlWrapperDir -value ""
        set_attribute -object $synSettingsName -name maxTransition -value "150"
        set_attribute -object $synSettingsName -name outputLoad -value "100000"
        
        set DCNXTSynSettingsName project/default_chip/synthesisSettings/DCNXT
        set_attribute -object $DCNXTSynSettingsName -name checkOnly -value "false"
        set_attribute -object $DCNXTSynSettingsName -name topoMode -value "true"
        set_attribute -object $DCNXTSynSettingsName -name techNode -value "CUSTOM"
        set_attribute -object $DCNXTSynSettingsName -name bottomUpSynthesis -value "true"
        set_attribute -object $DCNXTSynSettingsName -name gateArea -value "1"
        set_attribute -object $DCNXTSynSettingsName -name gatePropagationDelay -value "10"
        set_attribute -object $DCNXTSynSettingsName -name wirePropagationDelay -value "1000"
        set_attribute -object $DCNXTSynSettingsName -name maxWireDensity -value "1000"
        set_attribute -object $DCNXTSynSettingsName -name incrementalOpt -value "true"
        set_attribute -object $DCNXTSynSettingsName -name ulvtPercentage -value "0"
        set_attribute -object $DCNXTSynSettingsName -name compileCommand -value "compile_ultra -spg -no_boundary_optimization -gate_clock"
        
        set wiremodel project/default_chip/default_wire_model
        set_attribute -object $wiremodel -name propagationDelay -value 1000`
    )

    return synth;
}

const genPower = (seed) => {
    const power = format(`\

        # Create Power
        set pwrRegion [create_object -type power_region -parent $chip -name default_power_region]
        set_attribute -object $pwrRegion -name voltage -value 950
        
        set pwrDomain [create_object -type power_domain -parent $pwrRegion -name default_power_domain]
        set_attribute -object $pwrDomain -name gating -value always_on`
    );

    return power;
}

const genClocks = (seed) => {
    const clock = format(`\

        #Create Clocks
        set clkRegion [create_object -type clock_region -parent $chip -name default_clock_region]
        update_object -name $clkRegion -type powerRegion -bind project/default_chip/default_power_region
        set_attribute -object $clkRegion -name frequency -value ${params.clock.frequency}
        set_attribute -object $clkRegion -name unitClockGating -value false

        set clkDomain [create_object -type clock_domain -parent $clkRegion -name clock_domain1]
        update_object -name $clkDomain -type powerDomain -bind project/default_chip/default_power_region/default_power_domain
        set_attribute -object $clkDomain -name gating -value always_on

        set clkSubDomain [create_object -type clock_subdomain -parent $clkDomain -name clock_sub_domain1]
        set clkDomain [create_object -type clock_domain -parent $clkRegion -name clock_domain2]
        update_object -name $clkDomain -type powerDomain -bind project/default_chip/default_power_region/default_power_domain
        set_attribute -object $clkDomain -name gating -value always_on

        set clkSubDomain [create_object -type clock_subdomain -parent $clkDomain -name clock_sub_domain2]
        
        set clocksubdomain project/default_chip/default_clock_region/clock_domain1/clock_sub_domain1
        
        `
    );

return clock;
}

const genSystem = (seed) => {
    const system = format(`\

    # Create System
    set system [create_object -type system -parent $chip -name default_system]`
    );
    return system;
}

const genSubsystem = (seed) => {
    const subsys = format(`\

    # Create Subsystem
    set subsystem [create_object -type subsystem -parent $system -name default_subsystem]
    set_attribute -object $subsystem -name subsystemType -value ARTERIS_COHERENT
    `
    );

    return subsys;
}

const genSafety = (seed) => {

    const type = params.safety.type;
    if (type == 'ASIL_D' || type == 'ASIL_B') {
        enableResilience = "true";
        enableUnitDuplication = "true";
    } else if (type == 'NO_ASIL') {
        enableResilience = "false";
        enableUnitDuplication = "false";
    } else if (type == 'ASIL_A') {
        enableResilience = "true";
        enableUnitDuplication = "false";
    }
    const safety = format(`\
        set config [get_objects -type safety_configuration -parent $subsystem ]
        set safetyconfig [lindex $config 0]
        set_attribute -object $safetyconfig -name safetyConfig -value ${type}`
    );
    
    return safety;
}

const genSockets = (seed) => {
    return genAPBPort(seed)
    +genDVMVersion(seed)
    +genDCEs(seed)
    +genCHIs(seed)
    +genIOAIUs(seed)
    +genDMIs(seed)
    +genDIIs(seed);
}

const genIOAIUs = (seed) => {
    let ioaiuSockets = '';
    let socketFunction = "";
    let cardinality = "1";

    const nIOs = params.sockets.ioaiu.count;
    for (let i=0; i<nIOs; i++) {
        let protocol = params.sockets.ioaiu.items[i].protocol;
        if (protocol == 'MP_IOAIU') {
            protocol = "AXI4";
            socketFunction = "MULTI_INITIATOR";
            cardinality = params.sockets.ioaiu.items[i].nCores;
        } else {
            socketFunction = "INITIATOR";
        }
        ioaiuSockets += format(`\

            # Create IOAIU
            set sk [create_object -type socket -parent $subsystem -name ioaiu_${i}]
            update_object -name $sk -type domain -bind $clocksubdomain
            set vals [list \\
                socketFunction ${socketFunction} \\
                protocolType ${protocol} \\
                fnCsrAccess ${params.sockets.ioaiu.items[i].hasCsrAccess} \\
                hasEventInInt ${params.sockets.ioaiu.items[i].hasEventInInt} \\
                hasEventOutInt ${params.sockets.ioaiu.items[i].hasEventOutInt} \\${socketFunction == "MULTI_INITIATOR"? ("\n    cardinality "+ cardinality + " \\") : ""}
                fnDisableRdInterleave ${params.sockets.ioaiu.items[i].disableRdInterleave} \\
                params/wArId ${params.sockets.ioaiu.items[i].wArId} \\
                params/wAwId ${params.sockets.ioaiu.items[i].wAwId} \\
                params/wAddr ${params.system.wAddr} \\
                params/wData ${params.sockets.ioaiu.items[i].wData} \\
                params/wAwUser ${params.sockets.ioaiu.items[i].wAwUser} \\
                params/wArUser ${params.sockets.ioaiu.items[i].wArUser} \\${(params.sockets.ioaiu.items[i].protocol == "ACE5-Lite") ? ("\n                params/enableDVM " + params.sockets.ioaiu.items[i].enableDvm + "\\") : ("")}
                params/wSize ${params.sockets.ioaiu.items[i].wSize} \\
                params/wRegion ${params.sockets.ioaiu.items[i].wRegion} \\
            ]
            set_attribute -object $sk -value_list $vals
            `
        );
        // ioaiuSockets += format(`\
        //     set values [list 9 ]
        //     set_attribute -object $ncunit -name aPrimaryBits -value_list $values
        // `);
    }
    return ioaiuSockets;
}

const genCHIs = (seed) => {
    let chiSockets = '';

    for (let i=0; i<nChis; i++) {
        chiSockets += format(`\

        # Create CHIs
        set sk [create_object -type socket -parent $subsystem -name chi_${i}]
        set vals [list \\
            socketFunction INITIATOR \\
            protocolType ${params.sockets.chi.items[i].protocol} \\
            fnCsrAccess ${params.sockets.chi.items[i].hasCsrAccess} \\
            hasEventInInt ${params.sockets.chi.items[i].hasEventInInt} \\
            hasEventOutInt ${params.sockets.chi.items[i].hasEventOutInt} \\
            params/wData ${params.sockets.chi.items[i].wData} \\
            params/NodeID_Width ${params.sockets.chi.items[i].wNodeId} \\
            params/wAddr ${params.system.wAddr} \\
            params/REQ_RSVDC ${params.sockets.chi.items[i].wReqRsvdc} \\
            params/enPoison ${params.sockets.chi.items[i].enPoison} \\
        ]
        set_attribute -object $sk -value_list $vals
        update_object -name $sk -type domain -bind $clocksubdomain
        `
        );
    };

    return chiSockets;
}

const genDMIs = (seed) => {
    let dmiSockets = '';

    for (let i=0; i<nDmis; i++) {
        dmiSockets = dmiSockets + format(`\

            # Create DMIs
            set sk [create_object -type socket -parent $subsystem -name dmi_${i}]
            update_object -name $sk -type domain -bind $clocksubdomain
            set vals [list \\
                socketFunction MEMORY \\
                protocolType AXI4 \\
                params/wArId ${params.sockets.dmi.items[i].wArId} \\
                params/wAwId ${params.sockets.dmi.items[i].wAwId} \\
                params/wAddr ${params.system.wAddr} \\
                params/wData ${params.sockets.dmi.items[i].wData} \\
                params/wAwUser ${params.sockets.dmi.items[i].wAwUser} \\
                params/wArUser ${params.sockets.dmi.items[i].wArUser} \\
                params/wSize ${params.sockets.dmi.items[i].wSize} \\
                params/wRegion ${params.sockets.dmi.items[i].wRegion} \\
            ]
            set_attribute -object $sk -value_list $vals`
        );
    }
    return dmiSockets;
}

const genDIIs = (seed) => {
    let diiSocket = '';

    for(let i=0; i<nDiis; i++) {
        diiSocket += format(`\

            # Create DIIs
            set sk [create_object -type socket -parent $subsystem -name dii_${i}]
            update_object -name $sk -type domain -bind $clocksubdomain
            set vals [list \\
                socketFunction PERIPHERAL \\
                protocolType AXI4 \\
                params/wArId ${params.sockets.dii.items[i].wArId} \\
                params/wAwId ${params.sockets.dii.items[i].wAwId} \\
                params/wAddr ${params.system.wAddr} \\
                params/wData ${params.sockets.dii.items[i].wData} \\
                params/wAwUser ${params.sockets.dii.items[i].wAwUser} \\
                params/wArUser ${params.sockets.dii.items[i].wArUser} \\
                params/wSize ${params.sockets.dii.items[i].wSize} \\
                params/wRegion ${params.sockets.dii.items[i].wRegion} \\
            ]
            set_attribute -object $sk -value_list $vals`
        );
    }

    return diiSocket;
}

const genAPBPort = (seed) => {
    const apb = format(`\

        # Generate APB Debug port
        set sk [create_object -type socket -parent $subsystem -name apb_debug]
        update_object -name $sk -type domain -bind $clocksubdomain
        set_attribute -object $sk -name socketFunction -value EXTERNAL_DEBUG
    `);

    return apb;
}

const genDCEs = (seed) => {
    const dce = format(`\

        # Set DCE Count
        set_attribute -object $ncoreSettingsName -name dceCount -value ${params.sockets.dce.count}`
    );

    return dce;
}

const genDVMVersion = (seed) => {
    const dvm = format(`\

        # Set DVM Version
        set ncoreSettingsName project/default_chip/default_system/default_subsystem/NcoreSettings
        set_attribute -object $ncoreSettingsName -name dvmVersionSupport -value ${params.system.dvmVersion}`
    );
    return dvm;
}

function genInitiatorGroups(params) {
    let unit_name = [''];
    let initiatorGrpIntrlvBits = '7';
    let nMaxGroups = 0;
    let nGroups = 0;
    if (params.system.enInitiatorGroups === 'true') {
        switch(params.system.groups) {
            case 'chi': {
                nMaxGroups = utils.closestLowerPowerOf2(params.sockets.chi.count)-1;
                break;
            }
            case 'ioaiu': {
                nMaxGroups = utils.closestLowerPowerOf2(params.sockets.ioaiu.count)-1;
                break;
            }
            default: {
                nMaxGroups = utils.closestLowerPowerOf2(params.sockets.chi.count+params.sockets.ioaiu.count)-1;
                break;
            }
        }
        if (nMaxGroups > 0) nGroups = utils.getRandomValue(`[1:${nMaxGroups}]`, seed++);
        unit_name[0] = 'chi_0';
        unit_name[1] = 'chi_1';
    } else {
        return '';
    }
    return `\
    set initiatorGroup [create_object -type initiator_group -parent $memoryMap -name initiator_group]
    set sockets [list \\
        $subsystem/${unit_name[0]} \\
        $subsystem/${unit_name[1]} \\
    ]
    update_object -name $initiatorGroup -value_list $sockets -type initiators
    set values [list ${initiatorGrpIntrlvBits}]
    set_attribute -object $initiatorGroup -name interleavingBits -value_list $values
    
    `
}

const genMemoryMap = (seed) => {
    const intrlv_bits = [];
    dceInterleaveBits = utils.getInterleavingBits(params.system.wAddr, params.sockets.dce.count, seed);
    let memory = format(`\

        # Create Memory Map
        set memoryMap [create_object -type memory_map -parent $subsystem -name default_memory_map]
        set values [list ${dceInterleaveBits} ]
        set_attribute -object $memoryMap -name dceInterleavingBits -value_list $values

        set memorySet [create_object -type memory_set -parent $memoryMap -name default_memory_set]
        set dMemGrp [create_object -type dynamic_memory_group -parent $memorySet -name default_dynamic_memory_group]
        set sockets [list`
    );
        for(let i=0; i<nDmis; i++){
            memory = memory + ` $subsystem/dmi_${i}`;
        }
        memory = memory + ']';
        switch (Math.log2(nDmis)) {
            case 0: {
                intrlv_bits[0] = '0';
                intrlv_bits[1] = '0';
                intrlv_bits[2] = '0';
                intrlv_bits[3] = '0';
                break;
            }
            case 1: {
                intrlv_bits[0] = utils.getRandomValue(`[6:${params.system.wAddr-1}]`, seed++);
                intrlv_bits[1] = '0';
                intrlv_bits[2] = '0';
                intrlv_bits[3] = '0';
                break;
            }
            case 2: {
                let temp = 0;
                intrlv_bits[0] = utils.getRandomValue(`[6:${params.system.wAddr-1}]`, seed++);
                do {
                    temp = utils.getRandomValue(`[6:${params.system.wAddr-1}]`, seed++);
                } while(intrlv_bits.includes(temp));
                intrlv_bits[1] = temp;
                intrlv_bits[2] = '0';
                intrlv_bits[3] = '0';
                break;
            }
            case 3: {
                let temp = 0;
                intrlv_bits[0] = utils.getRandomValue(`[6:${params.system.wAddr-1}]`, seed++);
                do {
                    temp = utils.getRandomValue(`[6:${params.system.wAddr-1}]`, seed++);
                } while(intrlv_bits.includes(temp));
                intrlv_bits[1] = temp;
                do {
                    temp = utils.getRandomValue(`[6:${params.system.wAddr-1}]`, seed++);
                } while(intrlv_bits.includes(temp));
                intrlv_bits[2] = temp;
                intrlv_bits[3] = '0';
                break;
            }
            default: {
                let temp = 0;
                intrlv_bits[0] = utils.getRandomValue(`[6:${params.system.wAddr-1}]`, seed++);
                do {
                    temp = utils.getRandomValue(`[6:${params.system.wAddr-1}]`, seed++);
                } while(intrlv_bits.includes(temp));
                intrlv_bits[1] = temp;
                do {
                    temp = utils.getRandomValue(`[6:${params.system.wAddr-1}]`, seed++);
                } while(intrlv_bits.includes(temp));
                intrlv_bits[2] = temp;
                do {
                    temp = utils.getRandomValue(`[6:${params.system.wAddr-1}]`, seed++);
                } while(intrlv_bits.includes(temp));
                intrlv_bits[3] = temp;
                break;
            }
        }
        for (let i=0; i<2; i++) {
            memory += format(`\
        
                update_object -name $dMemGrp -value_list $sockets -type physicalChannels
                set memInterleaveFunc [create_object -type memory_interleave_function -parent $memoryMap -name default_2way_interleaving_function_${i}]
                set vals [list \\
                    primaryInterleavingBitOne ${intrlv_bits[0]} \\
                    primaryInterleavingBitTwo ${intrlv_bits[1]} \\
                    primaryInterleavingBitThree ${intrlv_bits[2]} \\
                    primaryInterleavingBitFour ${intrlv_bits[3]} \\
                ]
                set_attribute -object $memInterleaveFunc -value_list $vals`
            );
        }
    memory += format(`
        set configRegion [create_object -type configuration_region -parent $memoryMap -name default_configuration_region]
        set_attribute -object $configRegion -name memoryBase -value 780140544
        set_attribute -object $configRegion -name memorySize -value 1024
        
        set bootRegion [create_object -type boot_region -parent $memoryMap -name default_boot_region]
        set region project/default_chip/default_system/default_subsystem/default_memory_map/default_boot_region
        update_object -name $region -type physicalChannel -bind project/default_chip/default_system/default_subsystem/dii_0
        set_attribute -object $bootRegion -name memoryBase -value 0
        set_attribute -object $bootRegion -name memorySize -value 16

        #set usecase [get_objects -type use_case -parent project/default_chip/default_system/default_subsystem]
        #set_custom_attribute -name disableAutoFlowCreation -value true -object project/default_chip/default_system/default_subsystem
        `
    );
    return memory;
}

function genConnectivity() {
    let connect = '';
    for (let i=0; i< params.sockets.chi.count; i++) {
        for (let j=0; j<params.sockets.dmi.count; j++) {
            connect = connect + `\
            set flow [create_object -type flow -parent project/default_chip/default_system/default_subsystem/default -name flow_default_chi_${i}_to_dmi_${j}]
            update_object -name $flow -type source -bind project/default_chip/default_system/default_subsystem/chi_${i}
            update_object -name $flow -type destination -bind project/default_chip/default_system/default_subsystem/dmi_${j}
            `
        }
        for (let j=0; j<params.sockets.dii.count; j++) {
            connect = connect + `\
            set flow [create_object -type flow -parent project/default_chip/default_system/default_subsystem/default -name flow_default_chi_${i}_to_dii_${j}]
            update_object -name $flow -type source -bind project/default_chip/default_system/default_subsystem/chi_${i}
            update_object -name $flow -type destination -bind project/default_chip/default_system/default_subsystem/dii_${j}
            `
        }
    }
    for (let i=0; i< params.sockets.ioaiu.count; i++) {
        for (let j=0; j<params.sockets.dmi.count; j++) {
            connect = connect + `\
            set flow [create_object -type flow -parent project/default_chip/default_system/default_subsystem/default -name flow_default_ioaiu_${i}_to_dmi_${j}]
            update_object -name $flow -type source -bind project/default_chip/default_system/default_subsystem/ioaiu_${i}
            update_object -name $flow -type destination -bind project/default_chip/default_system/default_subsystem/dmi_${j}
            `
        }
        for (let j=0; j<params.sockets.dii.count; j++) {
            connect = connect + `\
            set flow [create_object -type flow -parent project/default_chip/default_system/default_subsystem/default -name flow_default_ioaiu_${i}_to_dii_${j}]
            update_object -name $flow -type source -bind project/default_chip/default_system/default_subsystem/ioaiu_${i}
            update_object -name $flow -type destination -bind project/default_chip/default_system/default_subsystem/dii_${j}
            `
        }
    }

    return connect;
}

const genTopology = (seed) => {
    const topology = format(`\
        #Create the topology
        set topology [create_object -type topology -name "topology" -parent $subsystem]

        #Select Template
        set_attribute -object $topology -name coherentTemplate -value ${params.system.network}

        set clocksubdomain project/default_chip/default_clock_region/clock_domain1/clock_sub_domain1
        run_generator -name "interface_units" -topology $topology -clock $clocksubdomain
    `);

    return topology;
}

const genMesh = (seed) => {
    // Set node positions for each unit
    let mesh = '';
    let coords = [0 , 0];
    let meshX = 0;
    let meshY = 0;
    // Node position for CAIUs
    mesh += format(`\
        set caius [get_objects -parent $chip -type caiu]
    `);
    for (let i=0; i< nCaius; i++) {
        // if (i == params.sockets.chi.count) {}
        mesh += format(`\
            set caiu${i} [lindex $caius ${i}]
            set_node_position -object $caiu${i} -x ${meshX} -y ${meshY}
        `);
        meshX++;
        if (meshX > meshSize[0]) {
            meshX = 0;
            meshY++;
        }
    }

    // Node position for NCAIUs
    mesh += format(`\
        set ncaius [get_objects -parent $chip -type ncaiu]
    `);
    for (let i=0; i< nNCaius; i++) {
        // coords = utils.getXYPosition(coords[0], coords[1], meshSize);
        mesh += format(`\
        set ncaiu${i} [lindex $ncaius ${i}]
        set_node_position -object $ncaiu${i} -x ${meshX} -y ${meshY}
        `);
        meshX++;
        if (meshX > meshSize[0]) {
            meshX = 0;
            meshY++;
        }
    }

    // Node position for DIIs
    mesh += format(`\
        set diis [get_objects -parent $chip -type dii]
    `);

    for (let i=0; i<params.sockets.dii.count; i++) {
        // coords = utils.getXYPosition(coords[0], coords[1], meshSize);
        mesh += format(`\
            set dii${i} [lindex $diis ${i}]
            set_node_position -object $dii${i} -x ${meshX} -y ${meshY}
        `);
        meshX++;
        if (meshX > meshSize[0]) {
            meshX = 0;
            meshY++;
        }
    }

    // Node position for Sys DII
    // coords = utils.getXYPosition(coords[0], coords[1], meshSize);
    mesh += format(`\
        set sys_dii   [get_objects -parent $chip -type dii -subtype configDii]
        set_node_position -object $sys_dii -x ${meshX} -y ${meshY}    
    `);

    meshX++;
    if (meshX > meshSize[0]) {
        meshX = 0;
        meshY++;
    }

    // Node position for DMI
    mesh += format(`\
        set dmis [get_objects -parent $chip -type dmi]
    `);

    for(let i=0; i<params.sockets.dmi.count; i++) {
        // coords = utils.getXYPosition(coords[0], coords[1], meshSize);
        mesh += format(`\
            set dmi${i} [lindex $dmis ${i}]
            set_node_position -object $dmi${i} -x ${meshX} -y ${meshY}
        `);
        meshX++;
        if (meshX > meshSize[0]) {
            meshX = 0;
            meshY++;
        }
    }

    // Node position for DCEs
    mesh += format(`\
        set dces [get_objects -parent $chip -type dce]
    `);

    for(let i=0; i<params.sockets.dce.count; i++) {
        // coords = utils.getXYPosition(coords[0], coords[1], meshSize);
        mesh += format(`\
            set dce${i} [lindex $dces ${i}]
            set_node_position -object $dce${i} -x ${meshX} -y ${meshY}
        `);
        meshX++;
        if (meshX > meshSize[0]) {
            meshX = 0;
            meshY++;
        }
    }

    // Node position for DVE
    // coords = utils.getXYPosition(coords[0], coords[1], meshSize);
    mesh += format(`\
        set dves [get_objects -parent $chip -type dve]
        set dve0 [lindex $dves 0]
        set_node_position -object $dve0 -x ${meshX} -y ${meshY}
    `);
    meshX++;
    if (meshX > meshSize[0]) {
        meshX = 0;
        meshY++;
    }

    return mesh;
}

const genSnoopFilters = (seed) => {
    let io_id=0;
    // TODO: Constraints:
    // * Number of sets should be atleast the number of DCEs. Right now hardcoded.
    // * Number of set select bits should be number of sets/number of DCEs - need to fix this
    let filter = '';
    for (let i=0; i<nSnoopFilters; i++) {
        filter += format(`\
        set sf${i} [create_object -type snoop_filter -parent $topology -name "sf${i}"]

        set vals [list \\
            nSets ${16*params.sockets.dce.count} \\
            nWays 4 \\
            nVictimEntries 2 \\
            replPolicy RANDOM \\
        ]

        set_attribute -object $sf${i} -value_list $vals

        set values [list ${utils.getInterleavingBits(params.system.wAddr, 16, seed, dceInterleaveBits)} ]
        set_attribute -object $sf${i} -name aPrimaryBits -value_list $values
        set_attribute -object $sf0 -name aSecondaryBits  -value_list [list  ${utils.getLog2Zeros(16)}]
        `);
    }
    // FIXME: Increase the number of snoop filters and pick randomly and assign it to Coherent agents
    for(let i=0; i<nCaius; i++) {
        filter += format(`\
        update_object -name $caiu${i} -type snoopFilter -bind $sf${parseInt(utils.getRandomValue("[1:"+nSnoopFilters+"]", seed++))-1}     
        `);
    }
    // FIXME: Need to support proxy cache and bind it to a snoop filter
    // FIXME: After above, we need to support Multiport IOAIU (since this can only be proxy cache AXI4)
    // FIXME: After above, do these:
    // set values [list 9 ]
    // set_attribute -object $ncunit -name aPrimaryBits -value_list $values
    // set ncunit project/default_chip/default_system/default_subsystem/topology/ioaiu_2_sk_0/ioaiu_2
    // set vals [list \
    //     hasProxyCache true \
    //     nTagBanks 1 \
    //     nDataBanks 1 \
    //     cacheReplPolicy RANDOM \
    //     nOttCtrlEntries 32 \
    //     nPerfCounters 4 \
    //     nLatencyCounters 16 \
    //     dataTiming ONE_CYCLE_WITH_PIPELINE \
    // ]
    // set_attribute -object $ncunit -value_list $vals
    for(let i=0; i<params.sockets.ioaiu.count; i++) {
        if(params.sockets.ioaiu.items[i].protocol == 'AXI4') {
            filter += format(`\
            set_attribute -object $ncaiu${io_id} -name hasProxyCache -value false
            `);
        }
        if(params.sockets.ioaiu.items[i].protocol !== 'ACE') {
            io_id++;
        }
    }
    
    return filter;
}

const genNetwork = (seed) => {
    // FIXME: what is datawidth below for a DN network? Is it independent of CHI or IOAIU?
    const net = format(`\
    set defaultGroup $topology/default_group

    # set clock for the group
    update_object -name $defaultGroup -type preferredCSRDomain -bind $clocksubdomain

    set datawidth 128

    # Access all the networks under the chip
    set networks [get_objects -parent $chip -type network]

    foreach net $networks {
        # Skip mesh generation if it is CSR network
        set request  [query_object -object $net -type "csr_request"]
        set response [query_object -object $net -type "csr_response"]
        if {$request == "true" || $response == "true"} {
          continue
        }
      
        set_context -name $net
        set pos [string last "/" $net]
        set nam [string range $net $pos+1 end]
      
        # Generate the mesh only on Data network and Non-data networks
        # Create the mesh generator. Assign the datawidth which is needed for the data network. 
        set dataWidth 0
        if {$nam == "dn"} {
          set dataWidth $datawidth
        }
      
        set route_params [list type mesh name $nam meshx ${meshSize[0]+1} meshy ${meshSize[1]+1} network $net dataWidth $dataWidth]
        run_generator -name "regular_topology" -topology $topology -clock $clocksubdomain -params $route_params

        run_generator -topology $topology -name "csr" -clock $clocksubdomain
        run_generator -topology $topology -name "adapters" -clock $clocksubdomain
        run_generator -topology $topology -name "interrupt" -clock $clocksubdomain

        set resilienceParams [list enableResilience ${enableResilience} enableDuplication ${enableUnitDuplication} ]
        run_generator -topology $topology -name "resiliency" -params $resilienceParams -clock $clocksubdomain
      }
    `);
    return net;
}

const genPreMap = (seed) => {
    let premap ='';
    premap += genAtus();
    premap += genSystemParams();
    premap += genCaiuPremap();
    premap += genNcaiuPremap();
    premap += genDcePremap();
    premap += genDmiPremap();
    premap += genDiiPremap();
    return premap;
}

const genAtus = (seed) => {
    let atu = '';
    atu += format(`\
    set objects [get_objects -type atu -parent $chip]
    set axiAtus [list]
    set apbAtus [list]
    foreach atu $objects {
        set sk [get_objects -parent $atu -type socket]
        set func [get_parameter -object $sk -name socketFunction]
        if {[string compare $func "CONFIGURATION"] == 0} {
            lappend apbAtus $atu
        } elseif {[string compare $func "CONFIG_INTERFACE"] == 0} {
            lappend axiAtus $atu
        }
    }
    `);
    return atu;
}

const genSystemParams = (seed) => {
    let sysparam = '';
    sysparam += format(`\
        set_attribute -object $topology -name nDvmCmdCredits -value 2
        set_attribute -object $topology -name nGPRA -value ${params.system.nGpra}
    `);
    return sysparam;
}

// FIXME: Need to randomize nNativeCredits and make sure nOtt entries is atleast greater than nNativeCredits

const genCaiuPremap = (seed) => {
    let caiupremap = '';
    for (let i=0; i<nCaius; i++) {
        if (i < params.sockets.chi.items.length){
            caiupremap += format(`\
            set_attribute -object $caiu${i} -name nNativeCredits        -value 15
            set_attribute -object $caiu${i} -name nOttCtrlEntries       -value ${params.sockets.chi.items[i].nOtt}
            set_attribute -object $caiu${i} -name nStshSnpCredits       -value 2
            set_attribute -object $caiu${i} -name nProcessors           -value ${params.sockets.chi.items[i].nProcs}
            set_attribute -object $caiu${i} -name nPerfCounters         -value ${params.sockets.chi.items[i].nPerfCounters}
            set_attribute -object $caiu${i} -name nLatencyCounters      -value ${params.sockets.chi.items[i].nLatencyCounters}
            `);
        } else {
            caiupremap += format(`\
            set_attribute -object $caiu${i} -name nNativeCredits        -value 15
            set_attribute -object $caiu${i} -name nOttCtrlEntries       -value ${params.sockets.ioaiu.items[i-nChis].nOtt}
            set_attribute -object $caiu${i} -name nStshSnpCredits       -value 2
            set_attribute -object $caiu${i} -name nProcessors           -value ${params.sockets.ioaiu.items[i-nChis].nProcs}
            set_attribute -object $caiu${i} -name nPerfCounters         -value ${params.sockets.ioaiu.items[i-nChis].nPerfCounters}
            set_attribute -object $caiu${i} -name nLatencyCounters      -value ${params.sockets.ioaiu.items[i-nChis].nLatencyCounters}
            `);
        }
    }
    return caiupremap;
}

const genNcaiuPremap = (seed) => {
    let ncaiupremap = '';
    for (let i=(nCaius-nChis); i<nNCaius; i++) {
        ncaiupremap += format(`\
        set_attribute -object $ncaiu${i} -name nOttCtrlEntries  -value ${params.sockets.ioaiu.items[i].nOtt}
        `);
    }
    return ncaiupremap;
}

const genDcePremap = (seed) => {
    let dcepremap = '';
    for (let i=0; i<params.sockets.dce.count; i++) {
        dcepremap += format(`\
        set_attribute -object $dce${i} -name nAttCtrlEntries    -value ${params.sockets.dce.items[i].nAttCtrlEntries}
        set_attribute -object $dce${i} -name nDceRbCredits      -value 2
        set_attribute -object $dce${i} -name nAiuSnpCredits     -value 2
        set_attribute -object $dce${i} -name nCMDSkidBufSize    -value 320
        set_attribute -object $dce${i} -name nCMDSkidBufArb     -value 64
        `);
    }

    return dcepremap;
}

const genDmiPremap = (seed) => {
    let dmipremap = '';
    for (let i=0; i<params.sockets.dmi.count; i++) {
        dmipremap += format(`\
        set_attribute -object $dmi${i} -name nDmiRbCredits      -value 16
        set_attribute -object $dmi${i} -name nRttCtrlEntries    -value 48
        set_attribute -object $dmi${i} -name nWttCtrlEntries    -value 32
        set_attribute -object $dmi${i} -name nCMDSkidBufSize    -value 8
        set_attribute -object $dmi${i} -name nCMDSkidBufArb     -value 4
        set_attribute -object $dmi${i} -name nMrdSkidBufSize    -value 320
        set_attribute -object $dmi${i} -name nMrdSkidBufArb     -value 64

        set_attribute -object $dmi${i} -name hasSysMemCache -value ${params.sockets.dmi.items[i].hasSmc}
        `);
        if (params.sockets.dmi.items[i].hasSmc == 'true') {
            dmipremap += format(`\
            set_attribute -object $dmi${i} -name nTagBanks -value 2
            set_attribute -object $dmi${i} -name nDataBanks -value 4
            set_attribute -object $dmi${i} -name cacheReplPolicy -value ${params.sockets.dmi.items[i].cacheReplPolicy}
            `)
        }
    }

    return dmipremap;
}

const genDiiPremap = (seed) => {
    let diipremap = '';
    for (let i=0; i<params.sockets.dii.count; i++) {
        diipremap += format(`\
        set_attribute -object $dii0 -name nDiiRbCredits      -value 16
        set_attribute -object $dii0 -name nRttCtrlEntries    -value 32
        set_attribute -object $dii0 -name nWttCtrlEntries    -value 16
        set_attribute -object $dii0 -name nCMDSkidBufSize    -value 320
        set_attribute -object $dii0 -name nCMDSkidBufArb     -value 64
        `);
    }

    return diipremap;
}

const genPostMap = (seed) => {
    let postmap = '';
    postmap += format(`\
    set postmapMpf       \${designName}.mpf
    save_project -file $postmapMpf
    puts "Design mpf created in $postmapMpf"
    `);
    return postmap;
}

const moveToFinalState = (seed) => {
    let state = '';

    state += format(`\
        proc move_to_state {desiredState dir} {
            set state [get_current_state]
            while {$state != $desiredState} {
                run_task -name move_to_next_state
                set state [get_current_state]
                puts "Transitioning at $state"
                if {$state == "Export/Export"} {
                    return 0;
                }
            }
            return 1
        }

        set desiredState "Export/Export"
        move_to_state $desiredState 1 ; # move forward
    `);

    return state;
}

const genCollateral = (seed) => {
    let collateral = '';
    collateral += format(`\
    file mkdir ./json
    set intermediateJson ./json/top.level.json

    export_design -format flat -file $intermediateJson
    puts "Intermediate Json created $intermediateJson"

    #GENERATE RTL
    #----------------------------------------------------------------------
    set today [clock format [clock seconds] -format "%Y_%m_%d"]

    set outputFileName "\${designName}_\${today}.tgz"
    puts "$outputFileName"

    gen_collateral -file $outputFileName

    #if {[delete_custom_attribute -object $project -name engVerId] != 1} {
    #    puts "Error: custom attribute engVerId supposed to be deleted"
    #}
    exec tar xvf $outputFileName
    exit
    `);
    return collateral;
}

module.exports = {
    generateConfigFile: generateConfigFile
};
