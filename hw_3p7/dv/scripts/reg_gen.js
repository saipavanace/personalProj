#!/usr/bin/env node

////////////////////////////////////////////////////////////
// Purpose: Create UVM register model                     //
// Description: This script takes the xml file in IPXACT  //
//              format which has the register description //
//              and constructs a reg model from it in UVM //
// Usage:                                                 //
// Author: Sai Pavan Yaraguti                             //
////////////////////////////////////////////////////////////

const fs = require('fs');
const xml2js = require('xml2js');

const getAccessType = (access, writeModifier, readAction=null) => {
    //FIXME: readAction is not yet supported. Refer to ralgen userguide for more information on this
    if (access === 'read-only') {
        return "RO";
    }else if (access === 'read-write') {
        if (!writeModifier) {
            return "RW";
        }else{
            switch(writeModifier){
                case 'oneToClear': return "W1C";
                case 'oneToSet': return "W1S";
                case 'onetoToggle': return "W1T";
                case 'zeroToClear': return "W0C";
                case 'zeroToSet': return "W0S";
                case 'zeroToToggle': return "W0T";
                case 'clear': return "WC";
                case 'set': return "WS";
                case 'modify': {
                    console.log("ERROR 'modify' is not supported");
                    process.exit(1);
                }
                default: {
                    console.log("ERROR unrecognized modifiedWriteValue detected");
                    process.exit(1);
                }
            }
        }
    }else if (access === 'write-only') {
        if (!writeModifier) {
            return "WO";
        }else{
            switch(writeModifier){
                case 'clear': return "WOC";
                case 'set': return "WOS";
                default: {
                    console.log("ERROR unrecognized modifiedWriteValue detected");
                    process.exit(1);
                }
            }
        }
    }else if (access === 'read-writeOnce') {
        return "W1";
    }else if (access === 'writeOnce') {
        return "WO1";
    }else{
        console.log("FATAL: Unsupported Access type detected in the IPXACT: "+access);
        process.exit(1);
    }
}

const generateUVMRegisterModel = (xmlFile, output, modelName, proj) => {
    const parser = new xml2js.Parser();
    let regModel = '';
    // Read xmlFile Input
    fs.readFile(xmlFile, (err, data) => {
        if (err) {
            console.error("Could not read the XML file:", err);
            return;
        }

        // Parse the xmlFile
        parser.parseString(data, (err, result) => {
            if (err) {
              console.error("Could not parse the XML file:", err);
              return;
            }

            // Headers
            regModel += `/////////////////////////////////////////////////////////////////\n`;
            regModel += `// Generated using reg_gen. Copyright Arteris, Inc. 2024       //\n`;
            regModel += `/////////////////////////////////////////////////////////////////\n\n`;
            regModel += `\`ifndef RAL_${proj.toUpperCase()}\n`;
            regModel += `\`define RAL_${proj.toUpperCase()}\n\n`;
            regModel += `import uvm_pkg::*;\n\n`;

            // declare fields in a register block
    
            const ipxact = result['ipxact:component'];
            const memoryMaps = ipxact['ipxact:memoryMaps'][0]['ipxact:memoryMap'];

            for (let i=0; i<memoryMaps.length; i+=1) {
                const mapName = memoryMaps[i]['ipxact:name'][0];
                const addrBlocks = memoryMaps[i]['ipxact:addressBlock'];
                addrBlocks.forEach((addrBlock) =>{
                    const registers = addrBlock['ipxact:register'];
                    const blockName = addrBlock['ipxact:name'];
                    const baseAddress = addrBlock['ipxact:baseAddress'];
                    const addrWidth = addrBlock['ipxact:width'];
                    registers.forEach((register) => {
                        const regName = register['ipxact:name'];
                        const regSize = register['ipxact:size'];
                        regModel += `class ral_${mapName}_${blockName}_${regName} extends uvm_reg;\n`;
                        regModel += `    \`uvm_object_utils(ral_${mapName}_${blockName}_${regName})\n\n`;
                        
                        const fields = register['ipxact:field'];
                        fields.forEach((field) => {
                            regModel += `    rand uvm_reg_field ${field['ipxact:name']};\n`;
                        });
                        regModel += `\n    function new(string name = "ral_${mapName}_${blockName}_${regName}");\n`;
                        regModel += `        super.new(name, ${regSize}, build_coverage(UVM_NO_COVERAGE));\n`
                        regModel += `    endfunction: new\n\n`
                        
                        regModel += `    virtual function void build();\n`;
                        fields.forEach((field) => {
                            const fieldName = field['ipxact:name'];
                            const bitWidth = parseInt(field['ipxact:bitWidth'][0].replace(/'h/, ''), 16);
                            const bitOffset = parseInt(field['ipxact:bitOffset'][0].replace(/'h/, ''), 16);
                            const volatile = field['ipxact:volatile'][0] === 'true' ? 1 : 0;
                            const resets = field['ipxact:resets'][0];
                            const resetValue = resets['ipxact:reset'][0]['ipxact:value'][0];
                            const hasReset = (resets && resetValue) ? 1 : 0;
                            const isRand = 0;
                            const accessible = (((bitOffset % 8) == 0 ) && (((bitOffset+bitWidth) % 8) == 0)) ? 1 : 0;
                            const modifiedWriteValue = field['ipxact:modifiedWriteValue'] ? field['ipxact:modifiedWriteValue'][0] : null;
                            const access = getAccessType(field['ipxact:access'][0], modifiedWriteValue);
                            
                            regModel += `        this.${fieldName} = uvm_reg_field::type_id::create("${fieldName}",,get_full_name());\n`;
                            regModel += `        this.${fieldName}.configure(this, ${bitWidth}, ${bitOffset}, "${access}", ${volatile}, ${bitWidth}${resetValue}, ${hasReset}, ${isRand}, ${accessible});\n`;
                        });
                        regModel += `    endfunction: build\n\n`;
                        regModel += `endclass:ral_${mapName}_${blockName}_${regName}\n\n`;
                    });

                    regModel += `class ral_${mapName}_${blockName} extends uvm_reg_block;\n`;
                    regModel += `    \`uvm_object_utils(ral_${mapName}_${blockName})\n\n`;
                    registers.forEach((register) => {
                        const regName = register['ipxact:name'];
                        regModel += `    rand ral_${mapName}_${blockName}_${regName} ${regName};\n`;
                    });
                    regModel += `\n    function new (string name = "ral_${mapName}_${blockName}");\n`;
                    regModel += `        super.new(name, UVM_NO_COVERAGE);\n`;
                    regModel += `    endfunction: new\n\n`;

                    regModel += `    virtual function void build();\n`;
                    regModel += `        this.default_map = create_map("ral_${mapName}_${blockName}", ${baseAddress}, ${addrWidth/8}, UVM_LITTLE_ENDIAN, 0);\n`;
                    registers.forEach((register) => {
                        const regName = register['ipxact:name'];
                        let access = 'RO';
                        const fields = register['ipxact:field'];
                        //FIXME: Need to understand the below logic more
                        for (let i=0; i<fields.length; i+= 1) {
                            if (fields[i]['ipxact:access'][0] != 'read-only') {
                                access = 'RW';
                                break;
                            }
                        }
                        
                        const regOffset = register['ipxact:addressOffset'][0];
                
                        regModel += `        this.${regName} = ral_${mapName}_${blockName}_${regName}::type_id::create("${regName}", , get_full_name());\n`;
                        regModel += `        this.${regName}.configure(this, null, "");\n`;
                        regModel += `        this.${regName}.build();\n`;
                        regModel += `        this.default_map.add_reg(this.${regName}, \`UVM_REG_ADDR_WIDTH${regOffset}, "${access}", 0);\n\n`;

                    });
                    regModel += `    endfunction: build\n\n`;
                    regModel += `endclass: ral_${mapName}_${blockName}\n\n`;
                });
            }
            regModel += `class ral_sys_ncore extends uvm_reg_block;\n`;
            regModel += `    \`uvm_object_utils(ral_sys_ncore)\n\n`;
            let addrWidth = 0;
            for (let i=0; i<memoryMaps.length; i+=1) {
                const mapName = memoryMaps[i]['ipxact:name'][0];
                const addrBlocks = memoryMaps[i]['ipxact:addressBlock'];
                addrBlocks.forEach((addrBlock) =>{
                    const blockName = addrBlock['ipxact:name'];
                    addrWidth = addrBlock['ipxact:width'];
                    regModel += `    ral_${mapName}_${blockName} ${blockName};\n`;
                });
            }
            regModel += `    function new(string name = "ral_sys_ncore");\n`;
            regModel += `        super.new(name);\n`;
            regModel += `    endfunction: new\n\n`;

            regModel += `    function void build();\n`; // ipxact:width
            regModel += `        this.default_map = create_map("ral_sys_ncore", 0, ${addrWidth/8}, UVM_LITTLE_ENDIAN, 0);\n`;
            for (let i=0; i<memoryMaps.length; i+=1) {
                const mapName = memoryMaps[i]['ipxact:name'][0];
                const addrBlocks = memoryMaps[i]['ipxact:addressBlock'];
                addrBlocks.forEach((addrBlock) =>{
                    const blockName = addrBlock['ipxact:name'];
                    const baseAddress = addrBlock['ipxact:baseAddress'];
                    addrWidth = addrBlock['ipxact:width'];
                    regModel += `        this.${blockName} = ral_${mapName}_${blockName}::type_id::create("${blockName}", , get_full_name());\n`;
                    regModel += `        this.${blockName}.configure(this, "");\n`;
                    regModel += `        this.${blockName}.build();\n`;
                    regModel += `        this.default_map.add_submap(this.${blockName}.default_map, \`UVM_REG_ADDR_WIDTH${baseAddress});\n\n`;
                    
                });
            }
            regModel += `    endfunction: build\n\n`;
            regModel += `endclass: ral_sys_ncore\n`;

            regModel += `\`endif`;
        });
        fs.writeFile(output, regModel, (err) => {
            if (err) {
              console.error("Could not write the output file:", err);
              return;
            }
            console.log("UVM register model generated successfully.");
        });
    });
}

// Check command line arguments
const args = process.argv.slice(2);
let xmlFile = '';
let outputFile = '';
let modelName = 'ral_sys_ncore';
const project = 'ncore';

if (args.length === 0 || args.indexOf('-o') === -1 || args[args.indexOf('-o') + 1] === undefined
    || args.indexOf('-ipxact') === -1 || args[args.indexOf('-ipxact') + 1] === undefined) {
    console.error("Usage: node script.js -ipxact <inputfile> -o <output_file>");
    process.exit(1);
} else {
    outputFile = args[args.indexOf('-o') + 1];
    xmlFile = args[args.indexOf('-ipxact') + 1];
}

// Call the function with the input XML file and the output SystemVerilog file
generateUVMRegisterModel(xmlFile, outputFile, modelName, project);