const fs = require('fs');
const path = require('path');
const buildSv = require('./buildSv.js');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);
const Chance = require('chance');
const { cleanLogs } = require('./utils.js');
const logger = require('./utils.js').logger;
const makeDir = require('./utils.js').makeDir;
const addSupportingParams = require('./addSupportingParams.js');
const parseConfluence = require('./params/scripts/parseConfluence.js');
let intrlvBitspool = [];
let mpAiuIntrlvBitspool = [];
const RANDOMIZER_HOME = `${process.env.WORK_TOP}/dv/scripts/randomizer`; // FIXME: Make this an env variable within randomizer
process.env.RANDOMIZER_HOME = RANDOMIZER_HOME;

const filepath = `${RANDOMIZER_HOME}/params/params.json`;

const genRandomSeed = () => {
        const min = 0;
        const max = 999999999;
        return Math.floor(Math.random() * (max - min + 1)) + min;
}

// const getIntrlvBits = (wAddr, size, chance, pool=null) => {
//     const numNewElements = Math.floor(Math.log2(size));
    
//     let excludeSet = new Set(pool || []);

//     const possibleNumbers = Array.from({length: wAddr - 6}, (_, i) => i + 6);
//     const availableNumbers = possibleNumbers.filter(num => !excludeSet.has(num));
//     const newArray = chance.pickset(availableNumbers, numNewElements);
    
//     if(pool) pool.push(...newArray);

//     return newArray.sort((a, b) => a - b);
// }

const getIntrlvBits = (wAddr, size, chance, pool=null) => {
    const numNewElements = Math.floor(Math.log2(size));
    const excludeSet = pool ? new Set(pool) : new Set();
    
    const possibleNumbers = Array.from(
        {length: wAddr - 6}, 
        (_, i) => i + 6
    ).filter(num => !excludeSet.has(num));

    if (possibleNumbers.length < numNewElements) {
        throw new Error(`Not enough available numbers (need ${numNewElements}, have ${possibleNumbers.length})`);
    }
    
    const newArray = chance.pickset(possibleNumbers, numNewElements);
    
    if(pool) pool.push(...newArray);
    
    return newArray.sort((a, b) => a - b);
};

function fixTclIndentation(tclCode) {
    const lines = tclCode.split('\n');
    let indentLevel = 0;
    let listIndentLevel = 0;
    const indentChar = '    '; // 4 spaces for indentation
    let inMultilineList = false;
  
    const fixedLines = lines.map((line, index) => {
      let originalIndent = line.match(/^\s*/)[0];
      line = line.trim();
      
      if (inMultilineList && !line.endsWith(']')) {
        return indentChar.repeat(indentLevel) + indentChar.repeat(listIndentLevel) + line;
      }
  
      if (line.startsWith('}') || (inMultilineList && line.endsWith(']'))) {
        indentLevel = Math.max(0, indentLevel - 1);
        inMultilineList = false;
      }
      
      let indentedLine = indentChar.repeat(indentLevel) + line;
      
      if (line.includes('[') && !line.includes(']') && line.endsWith('\\')) {
        inMultilineList = true;
        listIndentLevel = originalIndent.length / indentChar.length + 1;
      }
  
      if (line.endsWith('{')) {
        indentLevel++;
      }
      
      if (inMultilineList && index > 0 && !lines[index - 1].trim().startsWith('[')) {
        indentedLine = indentChar.repeat(indentLevel) + indentChar.repeat(listIndentLevel) + line;
      }
  
      return indentedLine;
    });
  
    return fixedLines.join('\n');
}

const saveRandomConfig = (seed, tclConfig, result) => {
    const configDir = path.resolve(`${process.env.MAESTRO_EXAMPLES}/../base_configs/`);
    const subDir = path.resolve(`${configDir}/hw_randomizer_config_${seed}`);
    const filePath = `${subDir}/hw_randomizer_config_${seed}.tcl`;
    const paramsPath = `${subDir}/config_params_${seed}.json`;

    if (!fs.existsSync(configDir)) {
        fs.mkdirSync(configDir, { recursive: true });
    }

    if (!fs.existsSync(subDir)) {
        fs.mkdirSync(subDir, { recursive: true });
    }

    const fixTcl = fixTclIndentation(tclConfig);

    fs.writeFileSync(filePath, fixTcl, 'utf8');
    logger(`\nAll parameters randomized. Dumping config_params_${seed}.json to location:\n${paramsPath}`, seed);
    fs.writeFileSync(paramsPath, JSON.stringify(result, null, 2), 'utf8');
    console.log('configfile has been successfully created.');
}

const constructTopLevelModule = (seed) => {
    return `
    import "DPI-C" function string getenv(input string env_name);

    module random();
        import params_pkg::*;
        params_class params;
        string config_path;
        int fd=0;

        initial begin
            config_path = {getenv("MAESTRO_EXAMPLES"), "/hw_randomizer_config_${seed}/random_params.json"};
            fd = $fopen(config_path, "w");
            params = new();
            while(!params.randomize());
            params.sample();
            $fwrite(fd, "{%s}", params.sprint("params"));
            $fclose(fd);
            $finish;
        end

    endmodule
    `;
}

const executeCommandAndSaveOutput = async (command, outputPath) => {
    const originalDir = process.cwd();
    try {
        process.chdir(outputPath);
        const { stdout, stderr } = await execPromise(command);
        const output = stdout + stderr;
        fs.writeFileSync(`${outputPath}/vcs.log`, output);
        if (output.includes("Error-") || output.includes("Compilation failed")) {
            throw new Error("VCS compilation failed");
        }
        return { success: true, output};
    } catch (error) {
        console.error(`Error executing command or writing to file: ${error.message}`);
        throw error;
    } finally {
        process.chdir(originalDir);
    }
}

const generateConfigFile = async (seed, isParamCovOn ,shouldParseConfluence=false) => {
    let l_seed = seed || genRandomSeed();
    intrlvBitspool = [];
    cleanLogs(l_seed);
    makeDir(`${process.env.MAESTRO_EXAMPLES}/../base_configs/hw_randomizer_config_${l_seed}/`);
    console.log(`Generating Random Parameters for seed: ${l_seed}`);
    logger(`Generating Random Parameters for seed: ${l_seed}`, l_seed);
    if (shouldParseConfluence) {
        await parseConfluence();
    }
    const chance = new Chance(l_seed);

    chance.mySeed = l_seed;


    try {
        const compileCmd = `vcs -sverilog -full64 -cm line -cm_name simv.vdb -q +vcs+lic+wait -debug_access+r ${process.env.WORK_TOP}/randomizer/params_pkg.sv ${process.env.WORK_TOP}/randomizer/random.sv`;
        //process.env.VCS_HOME = '/engr/eda/tools/synopsys/vcs_vV-2023.12-SP2-1/vcs/V-2023.12-SP2-1';
        compileStatus = await executeCommandAndSaveOutput(compileCmd, `${process.env.WORK_TOP}/randomizer/`);
        const simCmd = `./simv +ntb_random_seed=${l_seed} +config_name="hw_randomizer_config_${l_seed}"`;
        if(compileStatus.success) simStatus = await executeCommandAndSaveOutput(simCmd, `${process.env.WORK_TOP}/randomizer/`);
    } catch (error) {
        console.error('An error occurred:', error);
    }
    logger(`Successfully generated parameters`, l_seed);
    const crudeParams = JSON.parse(fs.readFileSync(`${process.env.MAESTRO_EXAMPLES}/hw_randomizer_config_${l_seed}/random_params.json`, 'utf8'));
    logger(`Adding parameters specific to randomizer`, l_seed);
    const params = addSupportingParams(crudeParams).params;

    console.log(`Randomized a config with seed: ${l_seed}`);

    logger("Starting config construction...", l_seed);

    ////////////////// Main TCL file construction /////////////////
    let tcl = '';

    // Phase 1
    // Create Project
    // Create Chip
    // Create Clock
    // Create Power
    // Create scripts for Synthesis
    tcl += genProject(params);
    tcl += genChip(params);
    tcl += genPower(params);
    tcl += genClocks(params);
    tcl += genSynthesisScripts(params);

    // PHASE 2
    // Create system
    // Create subsystem
    // Set Safety Params
    // Create sockets
    // Create memory map

    tcl += genSystem(params);
    tcl += genSubsystem(params);
    tcl += genSafety(params);
    tcl += genSockets(params, chance);
    tcl += genMemoryMap(params, chance);

    // PHASE 3: ARCHITECTURAL DESIGN
    // Create topology
    // Select coherent Template
    // Auto generate units
    // Set the node positions of the units in the topology
    // Generate topology for routing
    // Auto generate adapters
    // Auto generate the Control and Status Register (CSR) network

    tcl += genTopology(params);
    tcl += genMesh(params, chance);
    tcl += genSnoopFilters(params, chance);
    tcl += createInterleavingBits(params, chance);
    tcl += genNetwork(params);

    tcl += genPreMap(params, chance);
    // PHASE 4: REFINEMENT
    tcl += refineParams(params, chance);
    // PHASE 6: EXPORT
    tcl += genPostMap(params, chance);
    tcl += moveToFinalState(params);
    tcl += genCollateral(params);

    saveRandomConfig(l_seed, tcl, params);
}

const genProject = (params) => {
    const project = `
    # Project: ${params.randomizer.projectName}
    # Ncore Version: ${params.randomizer.ncoreVersion}
    # Randomizer Version: ${params.randomizer.randomizerVersion}

    # Create Project
    set designName ${params.randomizer.projectName}
    set fileName $designName.mpf
    if {[file exists $fileName] == 1} {
        puts "Renaming $fileName to \${fileName}.bak"
        file rename -force $fileName \${fileName}.bak
    }

    set project [create_project -name $designName  -license_token Arteris/Dev]
    `

    return project;
}

const genChip = (params) => {
    const chip = `\

        # Create Chip
        set chip [create_object -type chip -parent $project -name default_chip]`;

    return chip;
}

const genSynthesisScripts = (params) => {
    const synth = `\

        # Create Synthesis Scripts
        set synSettingsName project/default_chip/synthesisSettings
        set_attribute -object $synSettingsName -name clockUncertainty -value "15"
        set_attribute -object $synSettingsName -name rtlWrapperDir -value ""
        set_attribute -object $synSettingsName -name maxTransition -value "150"
        set_attribute -object $synSettingsName -name outputLoad -value "100000"
        
        set DCNXTSynSettingsName project/default_chip/synthesisSettings/DCNXT
        set_attribute -object $DCNXTSynSettingsName -name checkOnly -value "false"
        set_attribute -object $DCNXTSynSettingsName -name topoMode -value "true"
        #set_attribute -object $DCNXTSynSettingsName -name bottomUpSynthesis -value "true"
        set_attribute -object $DCNXTSynSettingsName -name compileCommand -value "compile_ultra -spg -no_boundary_optimization -gate_clock"
        
        set wiremodel project/default_chip/default_wire_model
        set_attribute -object $wiremodel -name propagationDelay -value 1000`

    return synth;
}

const genPower = (params) => {
    const power = `\

        # Create Power
        set pwrRegion [create_object -type power_region -parent $chip -name default_power_region]
        set_attribute -object $pwrRegion -name voltage -value 950
        
        set pwrDomain [create_object -type power_domain -parent $pwrRegion -name default_power_domain]
        set_attribute -object $pwrDomain -name gating -value always_on`;

    return power;
}

// FIXME How many clock regions can be there? Is there a parameter for it?
// FIXME Can we have mixed clock gating? Example, one has "always_on" and other has "external"
// FIXME Is power gating same as clock gating? Do we have separate parameters for it?
// FIXME external is not working

const genClocks = (params) => {
    // If there is a 512 data PCIe socket, then we need a second clock
    let has512bPcie = false;
    for(let i=0; i<params.structural.nNcaius.values; i+=1) {
        if (params.ncioaiu[i].fnNativeInterface.values.includes('PCIe') && params.ncioaiu[i].wData.values == 512) {
            has512bPcie = true;
        }
    }
    let clock = `\

        #Create Clocks
        set clkRegion1 [create_clock_region -name clkRegion1 -parent $chip -frequency 1GHz -power_region $pwrRegion]
        set clkDomain1 [create_clock_domain -name clkDomain1 -parent $clkRegion1 -gating ${params.system.gating.values} -power_domain $pwrDomain]
        set clocksubdomain [create_clock_subdomain -name std -parent $clkDomain1]
        `;
    if (has512bPcie) {
        clock += `
        set clkRegion2 [create_clock_region -name clkRegion2 -parent $chip -frequency 2GHz -power_region $pwrRegion]
        set clkDomain2 [create_clock_domain -name clkDomain2 -parent $clkRegion2 -gating ${params.system.gating.values} -power_domain $pwrDomain]
        set fastClock [create_clock_subdomain -name fast -parent $clkDomain2]
        `;
    }

    return clock;
}

const genSystem = (params) => {
    const system = `\

    # Create System
    set system [create_object -type system -parent $chip -name default_system]`;
    
    return system;
}

// FIXME: What is ARTERIS_COHERENT below?

const genSubsystem = (params) => {
    const subsys = `\

    # Create Subsystem
    set subsystem [create_object -type subsystem -parent $system -name default_subsystem]
    set_attribute -object $subsystem -name subsystemType -value ARTERIS_COHERENT
    `;

    return subsys;
}

// FIXME: The safety param below is missing in the parameter spec

const genSafety = (params) => {

    // const type = params.safety.type;
    const type = "ASIL_B"; // FIXME: Once this parameter is available in the spec, replace this

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
    const safety = `\
        set config [get_objects -type safety_configuration -parent $subsystem ]
        set safetyconfig [lindex $config 0]
        set_attribute -object $safetyconfig -name safetyConfig -value ${type}
        `;
    
    return safety;
}

const genSockets = (params, chance) => {
    return genAPBPort(params)
    +genDVMVersion(params)
    +genDCEs(params)
    +genCHIs(params)
    +genIOAIUs(params, chance)
    +genDMIs(params)
    +genDIIs(params);
}


const genIOAIUs = (params, chance) => {
    let ioaiuSockets = '';
    let socketFunction = "";
    let cardinality = "1";
    let nPcieAxi4 = 0;
    let nPcieAxi5 = 0;
    let nPcieAceLite = 0;

    const nIOs = params.cioaiu.length + params.ncioaiu.length;

    for (let i=0; i<nIOs; i++) {
        let hasAtomic = false;
        let hasRdDisable = false;
        let hasExclusives = false;
        if (i >= params.cioaiu.length) {
            unit = params.ncioaiu[i-params.cioaiu.length];
            hasExclusives = true;
        }else {
            unit = params.cioaiu[i];
        }
        // const unit = params.ioaiu[i];
        let protocol = unit.fnNativeInterface.values;
        // protocol = protocol.replace(/_/g, "-");
        let isPcie = protocol.includes('PCIe');
        let nPorts = unit.nNativeInterfacePorts.values;
        if (nPorts > 1) {
            socketFunction = "MULTI_INITIATOR";
            cardinality = nPorts;
        } else {
            socketFunction = "INITIATOR";
        }
        if (protocol == 'ACE5_Lite' || protocol == 'AXI5') {
            hasAtomic = true;
        }
        if (protocol == 'ACE5_Lite' || protocol == 'AXI5' || protocol == 'ACE_Lite' || protocol == 'AXI4') {
            hasRdDisable = true;
            if (socketFunction == 'MULTI_INITIATOR') {
                //hasRdDisable = false;
            }
        }
        // FIXME: Add fnDisableRdInterleave. It is missing in the confluence itself looks like or I need to add condition on when it is applicable
        if (isPcie) {
            let socSuffix = ''
            if (protocol == 'PCIe_ACE_Lite') {
                if (nPcieAceLite == 0) {
                    socSuffix = '_socket';
                }else{
                    socSuffix = `_socket_${nPcieAceLite-1}`;
                }
                nPcieAceLite+=1;
            }else if (protocol == 'PCIe_AXI4') {
                if (nPcieAxi4 == 0) {
                    socSuffix = '_socket';
                }else{
                    socSuffix = `_socket_${nPcieAxi4-1}`;
                }
                nPcieAxi4+=1;
            }else if (protocol == 'PCIe_AXI5') {
                if (nPcieAxi5 == 0) {
                    socSuffix = '_socket';
                }else{
                    socSuffix = `_socket_${nPcieAxi5-1}`;
                }
                nPcieAxi5+=1;
            }

            let choice = protocol.replace(/_/g,'-').replace('-','_');
            ioaiuSockets += `run_task -name create_socket_from_template -choice ${choice}
            set ioaiu_${i}_pcie $subsystem/${protocol.replace(/-/g,'_')}${socSuffix}
            update_object -name $sk -type domain -bind $clocksubdomain

            set vals [list \\
                fnCsrAccess ${unit.fnCsrAccess.values} \\
                params/wArId ${unit.wArId.values} \\
                params/wAwId ${unit.wAwId.values} \\
                params/wAddr ${unit.wAddr.values} \\
                params/wData ${unit.wData.values} \\
                params/wAwUser ${unit.wAwUser.values} \\
                params/wArUser ${unit.wArUser.values} \\
            ]
            #set ioaiu_${i}_pcie_unit \$topology/${protocol.replace('-','_')}${socSuffix}
            #set_attribute -object $ioaiu_${i}_pcie_unit -name ImplementationParameters/multicycleODSRAM -value ${unit.multicycleODSram.values}
            #set_attribute -object $ioaiu_${i}_pcie -name ImplementationParameters/multicycleODSRAM -value ${unit.multicycleODSram.values}
            set_attribute -object $ioaiu_${i}_pcie -value_list $vals
            `;
        }else{
            ioaiuSockets += `\

            # Create IOAIU
            set sk [create_object -type socket -parent $subsystem -name ioaiu_${i}]
            update_object -name $sk -type domain -bind $clocksubdomain
            set vals [list \\
                socketFunction ${socketFunction} \\
                protocolType ${protocol.replace(/_/g, '-')} \\
                fnCsrAccess ${unit.fnCsrAccess.values} \\
                hasEventInInt ${unit.useEventInInt.values} \\
                hasEventOutInt ${unit.useEventOutInt.values} \\${socketFunction == "MULTI_INITIATOR"? ("\n    cardinality "+ nPorts + " \\") : ""}
                params/wArId ${unit.wArId.values} \\
                params/wAwId ${unit.wAwId.values} \\
                params/wAddr ${unit.wAddr.values} \\
                params/wData ${unit.wData.values} \\
                params/wAwUser ${unit.wAwUser.values} \\
                params/wArUser ${unit.wArUser.values} \\${(protocol == "ACE5-Lite") ? ("\n                params/enableDVM true" + "\\") : ("")}
            ]
            set_attribute -object $sk -value_list $vals
            ${hasAtomic ? (`set_attribute -object $sk -name params/atomicTransactions -value ${unit.atomicTransactions.values}`) : ("")}
            ${hasRdDisable ? (`set_attribute -object $sk -name fnDisableRdInterleave -value ${unit.fnDisableRdInterleave.values == 1 ? "true" : "false"}`) : ("")}
            
            #set_attribute -object $sk -name exclusivesSupported -value false
            `;
        }
        
        // FIXME. use noDVM parameter along with eAC parameter
        // FIXME. fnDisableRdInterleave is not boolean in param spec. That would be the recommendation since maestro takes true and false
        
    }
    return ioaiuSockets;
}

const genCHIs = (params) => {
    let chiSockets = '';

    const nChis = params.chi.length;

    for (let i=0; i<nChis; i++) {
        const unit = params.chi[i];
        chiSockets += `\

        # Create CHIs
        set sk [create_object -type socket -parent $subsystem -name chi_${i}]
        set vals [list \\
            socketFunction INITIATOR \\
            protocolType ${unit.fnNativeInterface.values.replace(/_/g, "-")} \\
            fnCsrAccess ${unit.fnCsrAccess.values} \\
            hasEventInInt ${unit.useEventInInt.values} \\
            hasEventOutInt ${unit.useEventOutInt.values} \\
            params/wData ${unit.wData.values} \\
            params/NodeID_Width ${unit.nodeID_Width.values} \\
            params/wAddr ${unit.wAddr.values} \\
            params/REQ_RSVDC ${unit.req_rsvdc.values} \\
            params/enPoison ${unit.enPoison.values} \\
            params/checkType ${unit.checkType.values} \\
        ]
        set_attribute -object $sk -value_list $vals
        update_object -name $sk -type domain -bind $clocksubdomain
        `;
    };

    return chiSockets;
}

// FIXME: For IOAIU, DMI and DII, I removed the wSize, wRegion values. Add it back once the confluence page is updated

const genDMIs = (params) => {
    let dmiSockets = '';
    const nDmis = params.dmi.length;
    for (let i=0; i<nDmis; i++) {
        const unit = params.dmi[i];
        dmiSockets += `\

            # Create DMIs
            set sk [create_object -type socket -parent $subsystem -name dmi_${i}]
            update_object -name $sk -type domain -bind $clocksubdomain
            set vals [list \\
                socketFunction MEMORY \\
                protocolType AXI4 \\
                params/wArId ${unit.wArId.values} \\
                params/wAwId ${unit.wAwId.values} \\
                params/wAddr ${unit.wAddr.values} \\
                params/wData ${unit.wData.values} \\
                params/wAwUser ${unit.wAwUser.values} \\
                params/wArUser ${unit.wArUser.values} \\
            ]
            set_attribute -object $sk -value_list $vals`;
    }
    return dmiSockets;
}

const genDIIs = (params) => {
    let diiSocket = '';

    const nDiis = params.dii.length;

    for(let i=0; i<nDiis; i++) {
        const unit = params.dii[i];
        diiSocket += `\

            # Create DIIs
            set sk [create_object -type socket -parent $subsystem -name dii_${i}]
            update_object -name $sk -type domain -bind $clocksubdomain
            set vals [list \\
                socketFunction PERIPHERAL \\
                protocolType AXI4 \\
                params/wArId ${unit.wArId.values} \\
                params/wAwId ${unit.wAwId.values} \\
                params/wAddr ${unit.wAddr.values} \\
                params/wData ${unit.wData.values} \\
                params/wAwUser ${unit.wAwUser.values} \\
                params/wArUser ${unit.wArUser.values} \\
            ]
            set_attribute -object $sk -value_list $vals`;
    }

    return diiSocket;
}

const genAPBPort = (params) => {
    const apb = `\

        # Generate APB Debug port
        set sk [create_object -type socket -parent $subsystem -name apb_debug]
        update_object -name $sk -type domain -bind $clocksubdomain
        set_attribute -object $sk -name socketFunction -value EXTERNAL_DEBUG
    `;

    return apb;
}

const genDCEs = (params) => {
    const dce = `\

        # Set DCE Count
        set ncoreSettingsName project/default_chip/default_system/default_subsystem/NcoreSettings
        set_attribute -object $ncoreSettingsName -name dceCount -value ${params.dce.length}`;

    return dce;
}

// FIXME: Understand how this parameter is dependent on noDVM parameter
// FIXME: Inconsistency between how Maestro GUI defines this parameter and how the spec defines it
const genDVMVersion = (params) => {
    const dvm = `\
        # Set DVM Version
        set ncoreSettingsName project/default_chip/default_system/default_subsystem/NcoreSettings
        set_attribute -object $ncoreSettingsName -name dvmVersionSupport -value DVM_v8`;

    return dvm;
}
    
const genPostMap = (params, chance) => {
    let postmap = '';
    // FIXME: should the procsel bits be from ArId or AwId?
    for (let i=0; i< params.cioaiu.length; i+=1) {
        postmap += `set_attribute -object $caiu${i+params.chi.length} -name AxIdProcSelectBits -value_list [list ${getProcIdBits(params.cioaiu[i].wArId.values, params.cioaiu[i].wAwId.values, params.cioaiu[i].nProcessors.values, chance).join(' ')}]\n`;
    }

    postmap += `\
    set postmapMpf       \${designName}.mpf
    save_project -file $postmapMpf
    puts "Design mpf created in $postmapMpf"
    `;
    return postmap;
}

const genMemoryMap = (params,chance) => {
    const intrlv_bits = getIntrlvBits(params.dii[0].wAddr.values, params.structural.nDces.values, chance, intrlvBitspool);
    let has2Dmis = false;
    let has4Dmis = false;
    let has8Dmis = false;
    let has16Dmis = false;
    let intlvrBitsFor2Dmis = [];
    let intlvrBitsFor4Dmis = [];
    let intlvrBitsFor8Dmis = [];
    let intlvrBitsFor16Dmis = [];

    params.nMIGS.forEach((val,index) => {

        const group = params.nMIGS[index].nGroups;
        // FIXME: Check with the code below im using the same interleaving bits for 2 sets, where I can keep them different?
        for(let i=0; i<group.length; i+=1){
            if (group[i].values == 2) {
                intlvrBitsFor2Dmis = getIntrlvBits(params.dii[0].wAddr.values, 2, chance);
                has2Dmis = true;
            }else if (group[i].values == 4){
                intlvrBitsFor4Dmis = getIntrlvBits(params.dii[0].wAddr.values, 4, chance);
                has4Dmis = true;
            }else if (group[i].values == 8) {
                intlvrBitsFor8Dmis = getIntrlvBits(params.dii[0].wAddr.values, 8, chance);
                has8Dmis = true;
            }else if (group[i].values ==16) {
                intlvrBitsFor16Dmis = getIntrlvBits(params.dii[0].wAddr.values, 16, chance);
                has16Dmis = true;
            }
        }
    });
    let memory = `\

        set memoryMap [create_object -type memory_map -parent $subsystem -name default_memory_map]
        `
    if (params.structural.nDces.values > 1) {
        memory += `
        set values [list ${intrlv_bits.join(' ')} ]
        set_attribute -object $memoryMap -name dceInterleavingBits -value_list $values
        `
    }
    
    let i=0;

    params.nMIGS.forEach((val, index) => {
        let dmiCount = 0;
        memory += `
            #Create the memory groups under memorySet${i}
            set memorySet${i} [create_object -type memory_set -parent $memoryMap -name "memorySet${i}"]
        `
        const group = params.nMIGS[index].nGroups;
        for (let j=0; j<group.length; j+=1) {
            memory += `
                set memoryGroup${i}${j} [create_object -type dynamic_memory_group -parent $memorySet${i} -name "mg${j}"]
            `;
        }
        for (let j=0; j<group.length; j+=1) {
            memory += `
                #Assign DMI sockets to the memory group${i}${j}
                update_object -name $memoryGroup${i}${j} -value_list [list`
            for (let k=0; k < group[j].values; k+=1) {
                memory += ` $subsystem/dmi_${dmiCount}`;
                dmiCount+=1;
            }
            memory += `] -type physicalChannels
            `;
        }

        i+=1;
    });

    if (has2Dmis) {
        memory += `
            # Create 2-way interleaving functions
            set twoWayIntFunc [create_object -type memory_interleave_function -name "twowayif" -parent $memoryMap]
            set_attribute -object $twoWayIntFunc -name primaryInterleavingBitOne -value ${intlvrBitsFor2Dmis[0]}
        `;
    }
    if (has4Dmis) {
        memory += `
        # Create 4-way interleaving functions
        set fourWayIntFunc [create_object -type memory_interleave_function -name "fourwayif" -parent $memoryMap]
        set_attribute -object $fourWayIntFunc -name primaryInterleavingBitOne -value ${intlvrBitsFor4Dmis[0]}
        set_attribute -object $fourWayIntFunc -name primaryInterleavingBitTwo -value ${intlvrBitsFor4Dmis[1]}
    `;
    }
    if (has8Dmis) {
        memory += `
        # Create 8-way interleaving functions
        set eightWayIntFunc [create_object -type memory_interleave_function -name "eightwayif" -parent $memoryMap]
        set_attribute -object $eightWayIntFunc -name primaryInterleavingBitOne -value ${intlvrBitsFor8Dmis[0]}
        set_attribute -object $eightWayIntFunc -name primaryInterleavingBitTwo -value ${intlvrBitsFor8Dmis[1]}
        set_attribute -object $eightWayIntFunc -name primaryInterleavingBitThree -value ${intlvrBitsFor8Dmis[2]}
    `;
    }
    if (has16Dmis) {
        memory += `
        # Create 16-way interleaving functions
        set maxWayIntFunc [create_object -type memory_interleave_function -name "maxwayif" -parent $memoryMap]
        set_attribute -object $maxWayIntFunc -name primaryInterleavingBitOne -value ${intlvrBitsFor16Dmis[0]}
        set_attribute -object $maxWayIntFunc -name primaryInterleavingBitTwo -value ${intlvrBitsFor16Dmis[1]}
        set_attribute -object $maxWayIntFunc -name primaryInterleavingBitThree -value ${intlvrBitsFor16Dmis[2]}
        set_attribute -object $maxWayIntFunc -name primaryInterleavingBitFour -value ${intlvrBitsFor16Dmis[3]}
    `;
    }
    
    memory += `
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
        `;
    return memory;
}

const genTopology = (params) => {
    let topology = `\
        #Create the topology
        set topology [create_object -type topology -name "topology" -parent $subsystem]

        #Select Template
        set_attribute -object $topology -name coherentTemplate -value ${params.system.coherentTemplate.values}

        #set clocksubdomain project/default_chip/default_clock_region/clock_domain1/clock_sub_domain1
        run_generator -name "interface_units" -topology $topology -clock $clocksubdomain\n`;

    // This is hardcoded in genSafety function. Need to fix once the parameter is available FIXME
    // topology += `run_generator -topology $topology -name "resiliency" -clock $clocksubdomain -params [list enableResilience true enableDuplication true]
    // run_generator -topology $topology -name "csr" -clock $clocksubdomain
    // run_generator -topology $topology -name "interrupt" -clock $clocksubdomain\n`

    
    return topology;
}

const findFactors = (input, chance) => {
    if (input < 1) {
      return [0, 0]; // Handle edge case for inputs less than 1
    }
    
    const factor1 = chance.integer({ min: 1, max: input });
    const maxFactor2 = Math.floor(input / factor1);
    const factor2 = chance.integer({ min: 1, max: maxFactor2 });
    
    return [factor1-1, factor2-1];
}

let [meshX, meshY] = [0,0];

const genMesh = (params, chance) => {
    
    const maxNodeSize = 25 //FIXME: Need to have a parameter for this
    
    let mesh = '';
    [meshX, meshY] = findFactors(maxNodeSize, chance);

    // Node position for CAIUs
    mesh += `\
        set caius [get_objects -parent $chip -type caiu]
    `;
    for (let i=0; i< params.structural.nCaius.values; i++) {
        mesh += `\
            set caiu${i} [lindex $caius ${i}]
            set_node_position -object $caiu${i} -x ${chance.integer({ min: 0, max: meshX })} -y ${chance.integer({ min: 0, max: meshY })}
        `;
    }

    // Node position for NCAIUs
    mesh += `\
        set ncaius [get_objects -parent $chip -type ncaiu]
    `;
    for (let i=0; i< params.structural.nNcaius.values; i++) {
        mesh += `\
        set ncaiu${i} [lindex $ncaius ${i}]
        set_node_position -object $ncaiu${i} -x ${chance.integer({ min: 0, max: meshX })} -y ${chance.integer({ min: 0, max: meshY })}
        `;
    }

    // Node position for DIIs
    mesh += `\
        set diis [get_objects -parent $chip -type dii]
    `;

    for (let i=0; i<params.structural.nDiis.values; i++) {
        mesh += `\
            set dii${i} [lindex $diis ${i}]
            set_node_position -object $dii${i} -x ${chance.integer({ min: 0, max: meshX })} -y ${chance.integer({ min: 0, max: meshY })}
        `;
    }

    // Node position for Sys DII
    mesh += `\
        set sys_dii   [get_objects -parent $chip -type dii -subtype configDii]
        set_node_position -object $sys_dii -x ${chance.integer({ min: 0, max: meshX })} -y ${chance.integer({ min: 0, max: meshY })}
    `;

    // Node position for DMI
    mesh += `\
        set dmis [get_objects -parent $chip -type dmi]
    `;

    for(let i=0; i<params.structural.nDmis.values; i++) {
        mesh += `\
            set dmi${i} [lindex $dmis ${i}]
            set_node_position -object $dmi${i} -x ${chance.integer({ min: 0, max: meshX })} -y ${chance.integer({ min: 0, max: meshY })}
        `;
    }

    // Node position for DCEs
    mesh += `\
        set dces [get_objects -parent $chip -type dce]
    `;

    for(let i=0; i<params.structural.nDces.values; i++) {
        mesh += `\
            set dce${i} [lindex $dces ${i}]
            set_node_position -object $dce${i} -x ${chance.integer({ min: 0, max: meshX })} -y ${chance.integer({ min: 0, max: meshY })}
        `;
    }

    // Node position for DVE
    mesh += `\
        set dves [get_objects -parent $chip -type dve]
        set dve0 [lindex $dves 0]
        set_node_position -object $dve0 -x ${chance.integer({ min: 0, max: meshX })} -y ${chance.integer({ min: 0, max: meshY })}
    `;

    return mesh;
}

function associateSFWithUnits(nSfs, nUnits, chance) {
    const associations = [];
    const availableUnits = Array.from({ length: nUnits }, (_, i) => i);
    
    for (let sf = 0; sf < nSfs; sf++) {
      const unitCount = chance.integer({ min: 1, max: Math.max(1, availableUnits.length - (nSfs - sf - 1)) });
      for (let i = 0; i < unitCount; i++) {
        if (availableUnits.length > 0) {
          const randomIndex = chance.integer({ min: 0, max: availableUnits.length - 1 });
          const selectedUnit = availableUnits.splice(randomIndex, 1)[0];
          associations.push([selectedUnit, sf]);
        }
      }
    }
    
    while (availableUnits.length > 0) {
      const randomSf = chance.integer({ min: 0, max: nSfs - 1 });
      const randomUnit = availableUnits.pop();
      associations.push([randomUnit, randomSf]);
    }

    associations.sort((a, b) => {
        if (a[0] !== b[0]) {
        return a[0] - b[0];
        }
        return a[1] - b[1];
    });
    
    return associations;
}

const genSnoopFilters = (params, chance) => {
    let io_id=0;
    let filter = '';
    let nPcieAceLite = 0;
    let nPcieAxi4 = 0;
    let nPcieAxi5 = 0;
    let socSuffix = '';
    let protocol = '';

    for (let i=0; i<params.structural.nNcaius.values; i+=1) {
        protocol = params.ncioaiu[i].fnNativeInterface.values.replace("_", "-");
        if (params.ncioaiu[i].fnNativeInterface.values == "AXI4" || params.ncioaiu[i].fnNativeInterface.values == "AXI5") {
            filter += `
            set_attribute -object $ncaiu${i} -name hasProxyCache -value ${params.ncioaiu[i].hasProxyCache.values}
            `;
        }
        if (protocol == 'PCIe_ACE-Lite') {
            if (nPcieAceLite == 0) {
                socSuffix = '_socket';
            }else{
                socSuffix = `_socket_${nPcieAceLite-1}`;
            }
            filter += `set_attribute -object $topology/${protocol.replace('-','_')}${socSuffix} -name ImplementationParameters/multicycleODSRAM -value true\n`
            nPcieAceLite+=1;
        }else if (protocol == 'PCIe_AXI4') {
            if (nPcieAxi4 == 0) {
                socSuffix = '_socket';
            }else{
                socSuffix = `_socket_${nPcieAxi4-1}`;
            }
            filter += `set_attribute -object $topology/${protocol.replace('-','_')}${socSuffix} -name ImplementationParameters/multicycleODSRAM -value true\n`
            nPcieAxi4+=1;
        }else if (protocol == 'PCIe_AXI5') {
            if (nPcieAxi5 == 0) {
                socSuffix = '_socket';
            }else{
                socSuffix = `_socket_${nPcieAxi5-1}`;
            }
            filter += `set_attribute -object $topology/${protocol.replace('-','_')}${socSuffix} -name ImplementationParameters/multicycleODSRAM -value true\n`
            nPcieAxi5+=1;
        }
    }
    // TODO: Constraints:
    // * Number of sets should be atleast the number of DCEs. Right now hardcoded.
    // * Number of set select bits should be number of sets/number of DCEs - need to fix this
    for (let i=0; i<params.structural.nSnoopFilters.values; i++) {
        const intlvr_bits = getIntrlvBits(params.dii[0].wAddr.values, (params.snoopFilter[i].nSets.values/params.structural.nDces.values), chance, intrlvBitspool);
        filter += `\
        set sf${i} [create_object -type snoop_filter -parent $topology -name "sf${i}"]

        set vals [list \\
            nSets ${params.snoopFilter[i].nSets.values} \\
            nWays ${params.snoopFilter[i].nWays.values} \\
            nVictimEntries ${params.snoopFilter[i].nVictimEntries.values} \\
            replPolicy ${params.snoopFilter[i].cacheReplPolicy.values} \\
        ]

        set_attribute -object $sf${i} -value_list $vals

        set values [list ${intlvr_bits.join(' ')} ]
        set_attribute -object $sf${i} -name aPrimaryBits -value_list $values
        set_attribute -object $sf${i} -name aSecondaryBits  -value_list [list  ${Array(intlvr_bits.length).fill(0).join(' ')}]
        `;
    }

    let unitsWithSnoopFilter = parseInt(params.structural.nCaius.values);
    for (let i=0; i< params.structural.nNcaius.values; i+=1) {
        if((params.ncioaiu[i].fnNativeInterface.values == "AXI4" && params.ncioaiu[i].hasProxyCache.values == "true")
            || (params.ncioaiu[i].fnNativeInterface.values == "AXI5" && params.ncioaiu[i].hasProxyCache.values == "true")
            || (params.ncioaiu[i].fnNativeInterface.values.includes("PCIe"))) {
                unitsWithSnoopFilter+=1;
            }
    }

    const associations = associateSFWithUnits(params.structural.nSnoopFilters.values, unitsWithSnoopFilter, chance);

    let sfCounter=0;

    for (let i=0; i<params.structural.nCaius.values; i+=1) {
        filter += `
        update_object -name $caiu${associations[i][0]} -type snoopFilter -bind $sf${associations[i][1]}
        `
    }
    for (let i=0; i<params.structural.nNcaius.values; i+=1) {
        if((params.ncioaiu[i].fnNativeInterface.values == "AXI4" && params.ncioaiu[i].hasProxyCache.values == "true")
            || (params.ncioaiu[i].fnNativeInterface.values == "AXI5" && params.ncioaiu[i].hasProxyCache.values == "true")
            || (params.ncioaiu[i].fnNativeInterface.values.includes("PCIe"))) {
            filter += `
            update_object -name $ncaiu${i} -type snoopFilter -bind $sf${associations[sfCounter+parseInt(params.structural.nCaius.values)][1]}
            `;
            sfCounter+=1;
        }
        
    }
    // associations.forEach((association) => {
    //     filter += `
    //     update_object -name $caiu${association[0]} -type snoopFilter -bind $sf${association[1]}
    //     `   
    //     i+=1;
    // });
    
    return filter;
}

const getProcIdBits = (wArId, wAwId, size, chance) => {
    let arraySize = Math.floor(Math.log2(size));

    if (arraySize == 0) arraySize = 1;
    
    const uniqueSet = new Set();

    let wAxId = (wArId > wAwId) ? wAwId-1 : wArId-1;
    
    while (uniqueSet.size < arraySize) {
        const randomValue = chance.integer({ min: 0, max: wAxId });
        uniqueSet.add(randomValue);
    }
    
    const result = Array.from(uniqueSet).sort((a, b) => b - a);
    
    return result;
}

const createInterleavingBits = (params, chance) => {
    let intlvr = '';
    mpAiuIntrlvBitspool = []; // Reset the array
    
    for (let i=0; i<params.ncioaiu.length; i+=1){
        let tempIntlvrBits = [];
        if (params.ncioaiu[i].nNativeInterfacePorts.values > 1) {
            tempIntlvrBits = getIntrlvBits(params.dii[0].wAddr.values, params.ncioaiu[i].nNativeInterfacePorts.values, chance);
            intlvr += `
            set_attribute -object $ncaiu${i} -name aPrimaryBits -value_list [list ${tempIntlvrBits.join(' ')}]
            `;
        }
        mpAiuIntrlvBitspool[i] = tempIntlvrBits; // Store without modifying
    }
    return intlvr;
}

const genNetwork = (seed) => {
    // FIXME: what is datawidth below for a DN network? Is it independent of CHI or IOAIU?
    const net = `
    #set defaultGroup $topology/default_group

    # set clock for the group
    #update_object -name $defaultGroup -type preferredCSRDomain -bind $clocksubdomain

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
      
        set route_params [list type mesh name $nam meshx ${meshX+1} meshy ${meshY+1} network $net dataWidth $dataWidth]
        run_generator -name "regular_topology" -topology $topology -clock $clocksubdomain -params $route_params
    }
    create_configuration_units      -topology $topology -clock $clocksubdomain
    connect_request_csr_network     -topology $topology -clock $clocksubdomain
    connect_response_csr_network    -topology $topology -clock $clocksubdomain
    run_generator -name "adapters"  -topology $topology -clock $clocksubdomain
    run_generator -name "interrupt" -topology $topology -clock $clocksubdomain
    run_generator -topology $topology -name power

    set resilienceParams [list enableResilience true enableDuplication true ]
    run_generator -topology $topology -name "resiliency" -params $resilienceParams -clock $clocksubdomain
    `;
    return net;
}

const genPreMap = (params, chance) => {
    let premap ='';
    //premap += genAtus(params, chance);
    premap += genSystemParams(params, chance);
    premap += genCaiuPremap(params, chance);
    premap += genNcaiuPremap(params, chance);
    premap += genDcePremap(params, chance);
    premap += genDmiPremap(params, chance);
    premap += genDiiPremap(params, chance);
    return premap;
}

const genSystemParams = (params, chance) => {
    let sysparam = '';
    sysparam += `
        set_attribute -object $topology -name nDvmCmdCredits -value ${params.dve[0].nDvmCmdCredits.values}
        set_attribute -object $topology -name nGPRA -value ${params.system.nGPRA.values}
        set_attribute -object $topology -name qosEnabled -value ${params.system.qosEnabled.values}
        set_attribute -object $topology -name qosEventThreshold -value ${params.system.qosEventThreshold.values}
    `;
    return sysparam;
}

// FIXME: Need to randomize nNativeCredits and make sure nOtt entries is atleast greater than nNativeCredits

const genCaiuPremap = (params, chance) => {
    let caiupremap = '';
    const nChis = params.chi.length;
    for (let i=0; i<params.structural.nCaius.values; i++) {
        if (i < params.chi.length){
            caiupremap += `
            set_attribute -object $caiu${i} -name nNativeCredits        -value ${params.chi[i].nNativeCredits.values}
            set_attribute -object $caiu${i} -name nOttCtrlEntries       -value ${params.chi[i].nOttCtrlEntries.values}
            set_attribute -object $caiu${i} -name nStshSnpCredits       -value ${params.chi[i].nStashSnpCredits.values}
            set_attribute -object $caiu${i} -name nProcessors           -value ${params.chi[i].nProcessors.values}
            #set_attribute -object $caiu${i} -name nPerfCounters         -value ${params.chi[i].nPerfCounters.values}
            #set_attribute -object $caiu${i} -name nLatencyCounters      -value ${params.chi[i].nLatencyCounters.values}
            `;
        } else {
            caiupremap += `
            set_attribute -object $caiu${i} -name nOttCtrlEntries       -value ${params.cioaiu[i-nChis].nOttCtrlEntries.values}
            set_attribute -object $caiu${i} -name nProcessors           -value ${params.cioaiu[i-nChis].nProcessors.values}
            #set_attribute -object $caiu${i} -name nPerfCounters         -value ${params.cioaiu[i-nChis].nPerfCounters.values}
            #set_attribute -object $caiu${i} -name nLatencyCounters      -value ${params.cioaiu[i-nChis].nLatencyCounters.values}
            `;
        }
    }
    return caiupremap;
}

const genNcaiuPremap = (params, chance) => {
    let ncaiupremap = '';
    for (let i=0; i<params.ncioaiu.length; i+=1) {
        ncaiupremap += `
        set_attribute -object $ncaiu${i} -name nOttCtrlEntries  -value ${params.ncioaiu[i].nOttCtrlEntries.values}
        `;
    }
    return ncaiupremap;
}

const genDcePremap = (params, chance) => {
    let dcepremap = '';
    for (let i=0; i<params.dce.length; i++) {
        dcepremap += `
        set_attribute -object $dce${i} -name nAttCtrlEntries    -value ${params.dce[i].nAttCtrlEntries.values}
        set_attribute -object $dce${i} -name nDceRbCredits      -value ${params.dce[i].nDceRbCredits.values}
        set_attribute -object $dce${i} -name nAiuSnpCredits     -value ${params.dce[i].nAiuSnpCredits.values}
        set_attribute -object $dce${i} -name nCMDSkidBufSize    -value ${params.dce[i].nCMDSkidBufSize.values}
        set_attribute -object $dce${i} -name nCMDSkidBufArb     -value ${params.dce[i].nCMDSkidBufArb.values}
        `;
    }

    return dcepremap;
}

const genDmiPremap = (params, chance) => {
    let dmipremap = '';
    for (let i=0; i<params.dmi.length; i++) {
        dmipremap += `
        set_attribute -object $dmi${i} -name nDmiRbCredits      -value ${params.dmi[i].nDmiRbCredits.values}
        set_attribute -object $dmi${i} -name nRttCtrlEntries    -value ${params.dmi[i].nRttCtrlEntries.values}
        set_attribute -object $dmi${i} -name nWttCtrlEntries    -value ${params.dmi[i].nWttCtrlEntries.values}
        set_attribute -object $dmi${i} -name nCMDSkidBufSize    -value ${params.dmi[i].nCMDSkidBufSize.values}
        set_attribute -object $dmi${i} -name nCMDSkidBufArb     -value ${params.dmi[i].nCMDSkidBufArb.values}
        set_attribute -object $dmi${i} -name nMrdSkidBufSize    -value ${params.dmi[i].nMrdSkidBufSize.values}
        set_attribute -object $dmi${i} -name nMrdSkidBufArb     -value ${params.dmi[i].nMrdSkidBufArb.values}

        set_attribute -object $dmi${i} -name hasSysMemCache -value ${params.dmi[i].hasSysMemCache.values}
        `;
        if (params.dmi[i].hasSysMemCache == 'true') {
            dmipremap += `
            set_attribute -object $dmi${i} -name nTagBanks -value ${params.dmi[i].nTagBanks.values}
            set_attribute -object $dmi${i} -name nDataBanks -value ${params.dmi[i].nDataBanks.values}
            set_attribute -object $dmi${i} -name cacheReplPolicy -value ${params.dmi[i].cacheReplPolicy.values}
            `
        }
    }

    return dmipremap;
}

const genDiiPremap = (params, chance) => {
    let diipremap = '';
    for (let i=0; i<params.dii.length; i++) {
        diipremap += `
        set_attribute -object $dii${i} -name nDiiRbCredits      -value ${params.dii[i].nDiiRbCredits.values}
        set_attribute -object $dii${i} -name nRttCtrlEntries    -value ${params.dii[i].nRttCtrlEntries.values}
        set_attribute -object $dii${i} -name nWttCtrlEntries    -value ${params.dii[i].nWttCtrlEntries.values}
        set_attribute -object $dii${i} -name nCMDSkidBufSize    -value ${params.dii[i].nCMDSkidBufSize.values}
        set_attribute -object $dii${i} -name nCMDSkidBufArb     -value ${params.dii[i].nCMDSkidBufArb.values}
        `
    }

    // SysDII params
    // FIXME: We need a separate param for sys_dii below as of now just using the dii0 value for sys_dii as well
    diipremap += `
    set_attribute -object $topology/sys_dii -name nCMDSkidBufSize -value ${params.dii[0].nCMDSkidBufSize.values}
    set_attribute -object $topology/sys_dii -name nCMDSkidBufArb -value ${params.dii[0].nCMDSkidBufArb.values}
    `

    return diipremap;
}

const refineParams = (params, chance) => {
    let refine = '';
    for (let i=0; i<params.structural.nNcaius.values; i+=1) {
        if ((params.ncioaiu[i].fnNativeInterface.values == "AXI4" && params.ncioaiu[i].hasProxyCache.values == 'true')
            || params.ncioaiu[i].fnNativeInterface.values == "AXI5" && params.ncioaiu[i].hasProxyCache.values == 'true') {
            
            const PriSubDiagAddrBits = getIntrlvBits(
                params.dii[0].wAddr.values, 
                (params.ncioaiu[i].nSets.values/params.ncioaiu[i].nNativeInterfacePorts.values), 
                chance,
                mpAiuIntrlvBitspool[i]
            );
            
            refine += `
                set_attribute -object $ncaiu${i} -name Cache/nSets -value ${params.ncioaiu[i].nSets.values}
                set_attribute -object $ncaiu${i} -name Cache/nWays -value ${params.ncioaiu[i].nWays.values}
                set_attribute -object $ncaiu${i} -name Cache/SelectInfo/PriSubDiagAddrBits -value_list [list ${PriSubDiagAddrBits.join(' ')}]
                set_attribute -object $ncaiu${i} -name Cache/SelectInfo/SecSubRows -value_list [list ${Array(PriSubDiagAddrBits.length).fill(0).join(' ')}]
            `;
        }
    }
    return refine;
}

const moveToFinalState = (params) => {
    let state = '';

    state += `\
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
    `;

    return state;
}

const genCollateral = (params) => {
    let collateral = '';
    collateral += `\
    file mkdir ./json
    set intermediateJson ./json/top.level.json

    export_design -format flat -file $intermediateJson
    puts "Intermediate Json created $intermediateJson"

    #GENERATE RTL
    #----------------------------------------------------------------------
    set today [exec date +%Y_%m_%d]

    set outputFileName "\${designName}_\${today}.tgz"
    puts "$outputFileName"

    gen_collateral -file $outputFileName

    #if {[delete_custom_attribute -object $project -name engVerId] != 1} {
    #    puts "Error: custom attribute engVerId supposed to be deleted"
    #}
    exec tar xvf $outputFileName
    exit
    `;
    return collateral;
}

module.exports = generateConfigFile;