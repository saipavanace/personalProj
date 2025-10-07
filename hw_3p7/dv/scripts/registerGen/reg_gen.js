#!/usr/bin/env node

//////////////////////////////////////////////////////////////////////////////////
// Purpose: Create UVM register model                                           //
// Description: This script takes the xml file in IPXACT                        //
//              format which has the register description                       //
//              and constructs a reg model from it in UVM                       //
// Usage: node reg_gen.js -ipxact <path\to\ipxact2009|2014> -o <output_file>    //
// Author: Sai Pavan Yaraguti                                                   //
//////////////////////////////////////////////////////////////////////////////////

const fs = require('fs');
const path = require('path');
const parseXML = require('./parseXML'); // Assuming xmlParser.js is in the same directory

const getAccessType = (access, writeModifier = null, readAction = null) => {
    const validAccess = ['read-write', 'read-only', 'write-only', 'read-writeOnce', 'writeOnce'];
    const validWriteModifiers = [null, 'clear', 'set', 'modify', 'oneToClear', 'oneToSet', 'oneToToggle', 'zeroToClear', 'zeroToSet', 'zeroToToggle'];
    const validReadActions = [null, 'set', 'clear'];
  
    if (!validAccess.includes(access)) {
        throw new Error(`Invalid access type: ${access}`);
    }
    if (!validWriteModifiers.includes(writeModifier)) {
      throw new Error(`Invalid write modifier: ${writeModifier}`);
    }
    if (!validReadActions.includes(readAction)) {
      throw new Error(`Invalid read action: ${readAction}`);
    }
  
    if (access === 'read-writeOnce') {
        if (writeModifier === null && readAction === null) {
            return 'W1';
        }
        throw new Error(`Invalid combination for read-writeOnce: writeModifier=${writeModifier}, readAction=${readAction}`);
    }
    
    if (access === 'writeOnce') {
        if (writeModifier === null && readAction === null) {
            return 'W01';
        }
        throw new Error(`Invalid combination for writeonce: writeModifier=${writeModifier}, readAction=${readAction}`);
    }
  
    if (access === 'read-write') {
        if (writeModifier === null && readAction === null) return 'RW';
        if (writeModifier === null && readAction === 'set') return 'WRS';
        if (writeModifier === null && readAction === 'clear') return 'WRC';
        if (writeModifier === 'clear' && readAction === null) return 'WC';
        if (writeModifier === 'clear' && readAction === 'set') return 'WCRS';
        if (writeModifier === 'set' && readAction === null) return 'WS';
        if (writeModifier === 'set' && readAction === 'set') return 'WSRC';
        if (writeModifier === 'oneToClear' && readAction === null) return 'W1C';
        if (writeModifier === 'oneToClear' && readAction === 'set') return 'W1CRS';
        if (writeModifier === 'oneToSet' && readAction === null) return 'W1S';
        if (writeModifier === 'oneToSet' && readAction === 'clear') return 'W1SRC';
        if (writeModifier === 'oneToToggle' && readAction === null) return 'W1T';
        if (writeModifier === 'zeroToClear' && readAction === null) return 'W0C';
        if (writeModifier === 'zeroToClear' && readAction === 'set') return 'W0CRS';
        if (writeModifier === 'zeroToSet' && readAction === null) return 'W0S';
        if (writeModifier === 'zeroToSet' && readAction === 'clear') return 'W0SRC';
        if (writeModifier === 'zeroToToggle' && readAction === null) return 'W0T';
    }
  
    if (access === 'read-only') {
        if (writeModifier === null && readAction === null) return 'RO';
        if (writeModifier === null && readAction === 'set') return 'RS';
        if (writeModifier === null && readAction === 'clear') return 'RC';
    }
  
    if (access === 'write-only') {
        if (writeModifier === null && readAction === null) return 'WO';
        if (writeModifier === 'clear' && readAction === null) return 'W0C';
        if (writeModifier === 'set' && readAction === null) return 'W0S';
    }
  
    throw new Error(`Invalid combination: access=${access}, writeModifier=${writeModifier}, readAction=${readAction}`);
};

const extractBits = (resetValue, initialBit, bitWidth) => {
    let resetInt = parseInt(resetValue, 16);
    if(bitWidth == 32) return resetValue;
    let mask = ((1 << bitWidth) - 1) << initialBit;
    let extracted = (resetInt & mask) >>> initialBit;

    // Convert back to hex and ensure at least one digit
    return extracted.toString(16).padStart(1, '0');
}

const generateUVMRegisterModel = (xmlFile, output, ncoreModelName='ral_sys_ncore', ncoreFileName='ncore_system_register_map.sv', fscModelName='ral_sys_resiliency', fscFileName='ncore_fsc_system_register_map.sv') => {
    let regModel = '';
    let ncoreRegModel = '';
    let fscRegModel = '';
    let success = false;
    let proj = 'ncore';

    let data = null;

    try {
        data = fs.readFileSync(xmlFile, 'utf8');
    } catch (error) {
        console.error('Error reading file:', error.message);
        return;
    }

    const xml = parseXML(data);
    const is_2014 = xml.attributes["xsi:schemaLocation"].includes("IPXACT");
    const is_2009 = xml.attributes["xsi:schemaLocation"].includes("SPIRIT");
    const identifier = is_2014 ? "ipxact":"spirit";

    if (!is_2009 && !is_2014) {
        console.error("Only IPXACT 2009 and 2014 are supported currently. Unsupported IPXACT recognized");
    }
    console.log(`\n IPXACT version ${is_2014?"2014":"2009"} detected\n`);
    console.log("--------------------------------------------------------------------------");
    console.log("Generating register map using reg_gen script. Copyright Arteris, Inc. 2024");
    console.log("--------------------------------------------------------------------------\n");
    
    const memoryMapsElement = xml.children.find((child) => child.name === `${identifier}:memoryMaps`);
    if (!memoryMapsElement) {
        console.error(`Could not find ${identifier}:memoryMaps element`);
        return;
    }

    const memoryMaps = memoryMapsElement.children.filter(child => child.name === `${identifier}:memoryMap`);

    // Headers
    ncoreRegModel += `/////////////////////////////////////////////////////////////////\n`;
    ncoreRegModel += `// Generated using reg_gen. Copyright Arteris, Inc. 2024       //\n`;
    ncoreRegModel += `/////////////////////////////////////////////////////////////////\n\n`;
    ncoreRegModel += `\`ifndef RAL_${proj.toUpperCase()}\n`;
    ncoreRegModel += `\`define RAL_${proj.toUpperCase()}\n\n`;
    ncoreRegModel += `import uvm_pkg::*;\n\n`;

    if (memoryMaps.length > 1) {
        fscRegModel += `/////////////////////////////////////////////////////////////////\n`;
        fscRegModel += `// Generated using reg_gen. Copyright Arteris, Inc. 2024       //\n`;
        fscRegModel += `/////////////////////////////////////////////////////////////////\n\n`;
        fscRegModel += `\`ifndef RAL_${proj.toUpperCase()}_FSC\n`;
        fscRegModel += `\`define RAL_${proj.toUpperCase()}_FSC\n\n`;
        fscRegModel += `import uvm_pkg::*;\n\n`;
    }
    
    for (let i = 0; i < memoryMaps.length; i += 1) {
        const mapNameElement = memoryMaps[i].children.find(child => child.name === `${identifier}:name`);
        const mapName = mapNameElement ? mapNameElement.text : '';
        const addrBlocks = memoryMaps[i].children.filter(child => child.name === `${identifier}:addressBlock`);
        
        addrBlocks.forEach((addrBlock) => {
            const registers = addrBlock.children.filter(child => child.name === `${identifier}:register`);
            const blockNameElement = addrBlock.children.find(child => child.name === `${identifier}:name`);
            const blockName = blockNameElement ? blockNameElement.text : '';
            const baseAddressElement = addrBlock.children.find(child => child.name === `${identifier}:baseAddress`);
            let baseAddress = null;
            if (is_2014) {
                baseAddress = baseAddressElement ? baseAddressElement.text : '';
            }else{
                baseAddress = baseAddressElement ? baseAddressElement.text.replace("0x","'h") : '';
            }
            const addrWidthElement = addrBlock.children.find(child => child.name === `${identifier}:width`);
            const addrWidth = addrWidthElement ? addrWidthElement.text : '';

            registers.forEach((register) => {
                const regNameElement = register.children.find(child => child.name === `${identifier}:name`);
                const regName = regNameElement ? regNameElement.text : '';
                const regSizeElement = register.children.find(child => child.name === `${identifier}:size`);
                const regSize = regSizeElement ? regSizeElement.text : '';
                
                regModel += `class ral_${mapName}_${blockName}_${regName} extends uvm_reg;\n`;
                regModel += `    \`uvm_object_utils(ral_${mapName}_${blockName}_${regName})\n\n`;
                
                const fields = register.children.filter(child => child.name === `${identifier}:field`);

                let resetsElement = null;
                if (is_2009) {
                    resetsElement = register.children.find(child => child.name === `${identifier}:reset`);
                }

                let regResetValue = is_2014 ? null : resetsElement.children[0].text.split("0x")[1];
                let hasReset = (regResetValue && resetsElement) ? 1 : 0;
                let bitCount = 0;

                fields.forEach((field) => {
                    const fieldNameElement = field.children.find(child => child.name === `${identifier}:name`);
                    const fieldName = fieldNameElement ? fieldNameElement.text : '';
                    regModel += `    rand uvm_reg_field ${fieldName};\n`;
                });
                regModel += `\n    function new(string name = "ral_${mapName}_${blockName}_${regName}");\n`;
                regModel += `        super.new(name, ${regSize}, build_coverage(UVM_NO_COVERAGE));\n`
                regModel += `    endfunction: new\n\n`
                
                regModel += `    virtual function void build();\n`;
                fields.forEach((field) => {
                    const fieldNameElement = field.children.find(child => child.name === `${identifier}:name`);
                    const fieldName = fieldNameElement ? fieldNameElement.text : '';
                    const bitWidthElement = field.children.find(child => child.name === `${identifier}:bitWidth`);
                    const bitOffsetElement = field.children.find(child => child.name === `${identifier}:bitOffset`);

                    let bitWidth = null;
                    let bitOffset = null;
                    if(is_2014){
                        bitWidth = bitWidthElement ? parseInt(bitWidthElement.text.replace(/'h/, ''), 16) : 0;
                        bitOffset = bitOffsetElement ? parseInt(bitOffsetElement.text.replace(/'h/, ''), 16) : 0;
                    }else{
                        bitWidth = bitWidthElement ? parseInt(bitWidthElement.text) : 0;
                        bitOffset = bitOffsetElement ? parseInt(bitOffsetElement.text) : 0;
                    }
                    const volatileElement = field.children.find(child => child.name === `${identifier}:volatile`);
                    const volatile = volatileElement && volatileElement.text === 'true' ? 1 : 0;
                    let resetValue = 0;
                    if (is_2014) {
                        resetsElement = field.children.find(child => child.name === `${identifier}:resets`);
                        let resetValue = null;
                        if (resetsElement) {
                            let resetChild = resetsElement.children.find(child => child.name === `${identifier}:reset`);
                            if (resetChild && resetChild.children) {
                                let valueChild = resetChild.children.find(child => child.name === `${identifier}:value`);
                                resetValue = valueChild ? valueChild.text : null;
                            }
                        }

                        // let hasReset = (resetsElement && resetValue) ? 1 : 0;

                    }else{
                        resetValue = `'h${extractBits(regResetValue, parseInt(bitCount), bitWidth)}`;
                    }
                    
                    const isRand = 0;
                    const accessible = (((bitOffset % 8) == 0 ) && (((bitOffset+bitWidth) % 8) == 0)) ? 1 : 0;
                    const modifiedWriteValueElement = field.children.find(child => child.name === `${identifier}:modifiedWriteValue`);
                    const modifiedWriteValue = modifiedWriteValueElement ? modifiedWriteValueElement.text : null;
                    const accessElement = field.children.find(child => child.name === `${identifier}:access`);
                    const access = getAccessType(accessElement ? accessElement.text : '', modifiedWriteValue);
                    
                    regModel += `        this.${fieldName} = uvm_reg_field::type_id::create("${fieldName}",,get_full_name());\n`;
                    regModel += `        this.${fieldName}.configure(this, ${bitWidth}, ${bitOffset}, "${access}", ${volatile}, ${bitWidth}${resetValue || '0'}, ${hasReset}, ${isRand}, ${accessible});\n`;
                    bitCount += parseInt(bitWidth);
                });
                regModel += `    endfunction: build\n\n`;
                regModel += `endclass:ral_${mapName}_${blockName}_${regName}\n\n`;
            });

            regModel += `class ral_${mapName}_${blockName} extends uvm_reg_block;\n`;
            regModel += `    \`uvm_object_utils(ral_${mapName}_${blockName})\n\n`;
            registers.forEach((register) => {
                const regNameElement = register.children.find(child => child.name === `${identifier}:name`);
                const regName = regNameElement ? regNameElement.text : '';
                regModel += `    rand ral_${mapName}_${blockName}_${regName} ${regName};\n`;
            });
            regModel += `\n    function new (string name = "ral_${mapName}_${blockName}");\n`;
            regModel += `        super.new(name, UVM_NO_COVERAGE);\n`;
            regModel += `    endfunction: new\n\n`;

            regModel += `    virtual function void build();\n`;
            regModel += `        this.default_map = create_map("ral_${mapName}_${blockName}", ${baseAddress}, ${addrWidth/8}, UVM_LITTLE_ENDIAN, 0);\n`;
            registers.forEach((register) => {
                const regNameElement = register.children.find(child => child.name === `${identifier}:name`);
                const regName = regNameElement ? regNameElement.text : '';
                let access = 'RO';
                const fields = register.children.filter(child => child.name === `${identifier}:field`);
                //FIXME: Need to understand the below logic more
                for (let i=0; i<fields.length; i+= 1) {
                    const fieldAccessElement = fields[i].children.find(child => child.name === `${identifier}:access`);
                    if (fieldAccessElement && fieldAccessElement.text != 'read-only') {
                        access = 'RW';
                        break;
                    }
                }
                
                const regOffsetElement = register.children.find(child => child.name === `${identifier}:addressOffset`);
                let regOffset = null;
                if(is_2014) {
                    regOffset = regOffsetElement ? regOffsetElement.text : '';
                }else{
                    regOffset = regOffsetElement ? regOffsetElement.text.replace("0x","'h") : '';
                }
        
                regModel += `        this.${regName} = ral_${mapName}_${blockName}_${regName}::type_id::create("${regName}", , get_full_name());\n`;
                regModel += `        this.${regName}.configure(this, null, "");\n`;
                regModel += `        this.${regName}.build();\n`;
                regModel += `        this.default_map.add_reg(this.${regName}, \`UVM_REG_ADDR_WIDTH${regOffset}, "${access}", 0);\n\n`;

            });
            regModel += `    endfunction: build\n\n`;
            regModel += `endclass: ral_${mapName}_${blockName}\n\n`;
        });
        if (mapName === 'resiliency') {
            fscRegModel += regModel;
        }else {
            ncoreRegModel += regModel;
        }
        regModel = '';
    }
    ncoreRegModel += `class ${ncoreModelName} extends uvm_reg_block;\n`;
    ncoreRegModel += `    \`uvm_object_utils(${ncoreModelName})\n\n`;
    if (memoryMaps.length > 1) {
        fscRegModel += `class ${fscModelName} extends uvm_reg_block;\n`;
        fscRegModel += `    \`uvm_object_utils(${fscModelName})\n\n`;
    }
    regModel = '';
    let addrWidth = 0;
    for (let i=0; i<memoryMaps.length; i+=1) {
        const mapNameElement = memoryMaps[i].children.find(child => child.name === `${identifier}:name`);
        const mapName = mapNameElement ? mapNameElement.text : '';
        const addrBlocks = memoryMaps[i].children.filter(child => child.name === `${identifier}:addressBlock`);
        addrBlocks.forEach((addrBlock) =>{
            const blockNameElement = addrBlock.children.find(child => child.name === `${identifier}:name`);
            const blockName = blockNameElement ? blockNameElement.text : '';
            const addrWidthElement = addrBlock.children.find(child => child.name === `${identifier}:width`);
            addrWidth = addrWidthElement ? addrWidthElement.text : '0';
            regModel += `    ral_${mapName}_${blockName} ${blockName};\n`;
        });
        if (mapName === 'resiliency') {
            fscRegModel += regModel;
        }else {
            ncoreRegModel += regModel;
        }
        regModel = '';
    }

    ncoreRegModel += `    function new(string name = "${ncoreModelName}");\n`;
    ncoreRegModel += `        super.new(name);\n`;
    ncoreRegModel += `    endfunction: new\n\n`;

    ncoreRegModel += `    function void build();\n`;
    ncoreRegModel += `        this.default_map = create_map("${ncoreModelName}", 0, ${addrWidth/8}, UVM_LITTLE_ENDIAN, 0);\n`;

    if (memoryMaps.length > 1) {
        fscRegModel += `    function new(string name = "${fscModelName}");\n`;
        fscRegModel += `        super.new(name);\n`;
        fscRegModel += `    endfunction: new\n\n`;

        fscRegModel += `    function void build();\n`;
        fscRegModel += `        this.default_map = create_map("${fscModelName}", 0, ${addrWidth/8}, UVM_LITTLE_ENDIAN, 0);\n`;
    }

    regModel = '';
    for (let i=0; i<memoryMaps.length; i+=1) {
        const mapNameElement = memoryMaps[i].children.find(child => child.name === `${identifier}:name`);
        const mapName = mapNameElement ? mapNameElement.text : '';
        const addrBlocks = memoryMaps[i].children.filter(child => child.name === `${identifier}:addressBlock`);
        addrBlocks.forEach((addrBlock) =>{
            const blockNameElement = addrBlock.children.find(child => child.name === `${identifier}:name`);
            const blockName = blockNameElement ? blockNameElement.text : '';
            const baseAddressElement = addrBlock.children.find(child => child.name === `${identifier}:baseAddress`);
            let baseAddress = null;
            if(is_2014) {
                baseAddress = baseAddressElement ? baseAddressElement.text : '';
            }else{
                baseAddress = baseAddressElement ? baseAddressElement.text.replace("0x","'h") : '';
            }
            const addrWidthElement = addrBlock.children.find(child => child.name === `${identifier}:width`);
            addrWidth = addrWidthElement ? addrWidthElement.text : '0';
            regModel += `        this.${blockName} = ral_${mapName}_${blockName}::type_id::create("${blockName}", , get_full_name());\n`;
            regModel += `        this.${blockName}.configure(this, "");\n`;
            regModel += `        this.${blockName}.build();\n`;
            regModel += `        this.default_map.add_submap(this.${blockName}.default_map, \`UVM_REG_ADDR_WIDTH${baseAddress});\n\n`;
        });
        if (mapName === 'resiliency') {
            fscRegModel += regModel;
        }else {
            ncoreRegModel += regModel;
        }
        regModel = '';
    }
    ncoreRegModel += `    endfunction: build\n\n`;
    ncoreRegModel += `endclass: ${ncoreModelName}\n`;

    ncoreRegModel += `\`endif`;

    if (memoryMaps.length > 1) {
        fscRegModel += `    endfunction: build\n\n`;
        fscRegModel += `endclass: ${fscModelName}\n`;

        fscRegModel += `\`endif`;
    }

    const ncoreOutput = path.join(output, ncoreFileName);
    const fscOutput = path.join(output, fscFileName);

    try {
        fs.writeFileSync(ncoreOutput, ncoreRegModel);
        console.log(`UVM register model generated at: ${ncoreOutput}`);
    }catch(error) {
        console.error(`Could not write to ${ncoreFileName} file:`, err);
        return;
    }

    if (memoryMaps.length > 1) {
        fs.writeFileSync(fscOutput, fscRegModel, (err) => {
            if (err) {
                console.error(`Could not write the ${fscFileName} file:`, err);
                return;
            }
            console.log(`UVM register model generated at: ${fscOutput}`);
        });
    }

    success = true;
    return success;
}

function printUsage() {
    console.log("Usage: node reg_gen.js -ipxact <path\\to\\ipxact2009|2014> [options]");
    console.log("Options:");
    console.log("  -ipxact <path>               Path to the IP-XACT file (2009 or 2014 version)");
    console.log("  -o <path>                    Path where output files should be dumped (default: ./)")
    console.log("  -ncoreFileName <name>        Name for the ncore output file (default: ncore_system_register_map.sv)");
    console.log("  -fscFileName <name>          Name for the fsc output file (default: ncore_fsc_system_register_map.sv)");
    console.log("  -ncoreModelName <name>       Name for the ncore model (default: ral_sys_ncore)");
    console.log("  -fscModelName <name>         Name for the fsc model (default: ral_sys_resiliency)");
    console.log("  -h, -help, --help, --h       Display this help message");
}

function parseCommandLineArgs(args) {
    let outputFilePath = process.cwd();
    let ncoreFileName = 'ncore_system_register_map.sv';
    let fscFileName = 'ncore_fsc_system_register_map.sv';
    let ncoreModelName = 'ral_sys_ncore';
    let fscModelName = 'ral_sys_resiliency';
    if (args.includes('-h') || args.includes('-help') || args.includes('--h') || args.includes('--help')) {
        printUsage();
        process.exit(0);
    }

    if (args.length === 0 || args.indexOf('-ipxact') === -1 || args[args.indexOf('-ipxact') + 1] === undefined) {
        console.error("Error: Invalid arguments");
        printUsage();
        process.exit(1);
    }

    let xmlFile = args[args.indexOf('-ipxact') + 1];
    
    if (args.indexOf('-o') !== -1 && args[args.indexOf('-o') + 1] !== undefined) {
        outputFilePath = args[args.indexOf('-o') + 1];
    }
    if (args.indexOf('-ncoreFileName') !== -1 && args[args.indexOf('-ncoreFileName') + 1] !== undefined) {
        ncoreFileName = args[args.indexOf('-ncoreFileName') + 1];
    }
    if (args.indexOf('-fscFileName') !== -1 && args[args.indexOf('-fscFileName') + 1] !== undefined) {
        fscFileName = args[args.indexOf('-fscFileName') + 1];
    }
    if (args.indexOf('-ncoreModelName') !== -1 && args[args.indexOf('-ncoreModelName') + 1] !== undefined) {
        ncoreModelName = args[args.indexOf('-ncoreModelName') + 1];
    }
    if (args.indexOf('-fscModelName') !== -1 && args[args.indexOf('-fscModelName') + 1] !== undefined) {
        fscModelName = args[args.indexOf('-fscModelName') + 1];
    }
    return { xmlFile, outputFilePath, ncoreModelName, ncoreFileName, fscModelName, fscFileName };
}

if (require.main === module) {
    const { xmlFile, outputFilePath, ncoreModelName, ncoreFileName, fscModelName, fscFileName } = parseCommandLineArgs(process.argv.slice(2));
    generateUVMRegisterModel(xmlFile, outputFilePath, ncoreModelName, ncoreFileName, fscModelName, fscFileName);
} else {
    module.exports = generateUVMRegisterModel;
}