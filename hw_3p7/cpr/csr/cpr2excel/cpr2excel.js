'use strict';

const fs = require('fs');
const path = require('path');

const XLSX = require('xlsx');

const fileExt = "csr.cpr";

var   finalSheetMap = {};

const createFirstEntryRegisterData = (register) => {
    const entry = {
        register:    register.name,
        address:     register.addressOffset,
        field:       '',
        bitOffset:   '',
        width:       '',
        access:      '',
        resetValue:  '',
        description: register.description
    };

    return entry;
}

const createFieldData = (field) => {
    const entry = {
        register:    '',
        address:     '',
        field:       field.name,
        bitOffset:   field.bitOffset,
        width:       field.bitWidth,
        access:      field.access,
        resetValue:  field.reset,
        description: field.description
    };
    
    return entry;

}

const readRegister = (register, fromReference = false) => {
    const tempList = [];
    if(!fromReference){
        tempList.push(createFirstEntryRegisterData(register));
    }

    if("fields" in register && register.fields instanceof Array){
        register.fields.forEach(field =>{
            tempList.push(createFieldData(field));
        });
    }

    if ("reference" in register.fields){ // parse references todo(ahmed): override descriptions for relevant fields
        const referenceReg = readReference(register.fields.reference);
        tempList.push(...readRegister(referenceReg, true));
    }
    
    return tempList;
}

const readReference = (refVal) => {
    //example: "$HW_NCR_CSR/errCSR.json#xCESAR"
    const curPath = refVal.split("/")[1];
    const file = curPath.split("#")[0];
    const register = curPath.split("#")[1];
    const fullPath = path.join(currentDir, file);
    const data = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
    var res = null;
    data.forEach(reg => {
        if(reg.name == register){
            res = reg;
        }
    });

    return res;
}

const readFiles = (srcDir) => {
    const tempList = {};
    const srcFiles = fs.readdirSync(srcDir);
    srcFiles.forEach(srcFile => {
        if (srcFile.includes(fileExt)){
            const fullPath = path.join(srcDir, srcFile);
            const data = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
            tempList[data.name] = [];
            //below JSON access may need to be modified based on changes to CPR structure
            data.csr.spaceBlock[0].registers.forEach(register => {
                tempList[data.name].push(...readRegister(register, false));
            });
        }
    });

    return tempList;
}

const currentDir = path.dirname(__filename) + "/../";
finalSheetMap = readFiles(currentDir);

const workbook = XLSX.utils.book_new();
Object.keys(finalSheetMap).forEach(type => {
    //sheet per block
    const worksheet = XLSX.utils.json_to_sheet(finalSheetMap[type]);
    XLSX.utils.book_append_sheet(workbook, worksheet, type);
});

XLSX.writeFile(workbook, 'csr2cpr.xlsx');