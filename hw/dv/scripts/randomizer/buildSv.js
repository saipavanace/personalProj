const fs = require('fs');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);
const constraints = require('./params/config/constraints.js');
const RANDOMIZER_HOME = `${process.env.WORK_TOP}/dv/scripts/randomizer`;

const toSnakeCase = (str) => {
    return str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
}

const multipleUnits = ['chi', 'cioaiu', 'ncioaiu', 'dce', 'dve', 'dii', 'dmi', 'snoopFilter', 'nMIGS', 'nGroups'];

const insertConstraints = () => {
    let constraint_str = '';
    constraints.forEach((constraint) => {
        constraint_str += `    constraint ${constraint.name}{\n`;
        constraint_str += `        ${constraint.constraint}\n`;
        constraint_str += `    }\n`;
    });
    return constraint_str;
}

const populatePostRandomize = () => {
    let function_str = '';
    let i = 0;
    constraints.forEach((constraint) => {
        if (constraint.post_randomize) {
            function_str += `        function void post_randomize_func_${i}();\n`;
            function_str += `    ${constraint.post_randomize}`;
            function_str += `endfunction: post_randomize_func_${i}\n\n`;
            i+=1;
        }
    });
    return function_str;
}

const addPostRandomizeFunctions = () => {
    let post_randomize_str = '';
    let i = 0;
    constraints.forEach((constraint) => {
        if (constraint.post_randomize) {
            post_randomize_str += `post_randomize_func_${i}();\n`;
            i+=1;
        }
    });

    return post_randomize_str;
}

const createClass = (name, parent, children) => {
    const className = toSnakeCase(name);
    
    const appendChild = parent && parent.split("class")[0];

    let classCode = `class ${appendChild ?? ''}${className}_class;\n`;

    const appendParent = `${className}_`;
    let hasArray = false;
    
    children.forEach(child => {
        if (multipleUnits.includes(child)) {
            classCode += `    rand ${appendParent}${toSnakeCase(child)}_class ${child}[];\n`;
            hasArray = true;
        }else{
            classCode += `    rand ${appendParent}${toSnakeCase(child)}_class ${child};\n`;
        }
    });
    if (className == 'params') {
        classCode += `    rand int helper_nsets;\n`;
        classCode += `    //local const int unsigned MAX_UNITS = 32;\n`;
        classCode += `    constraint c_helper_constraint{\n`;
        classCode += `        helper_nsets inside {[16:1048576]};\n`;
        classCode += `        $countones(helper_nsets) == 1;\n`;
        classCode += `    }\n`;
        classCode += `
        // covergroup cg_crosses;
        //     option.per_instance = 1;
        //     cp_cross_large_stt: coverpoint (structural.nDces.values * dce[0].nAiuSnpCredits.values + ((structural.nCaius.values > 8) ? structural.nCaius.values : 8)) {
        //         bins large_stt = {[128:256]};
        //     }
        // endgroup: cg_crosses
        `;
    }

    if (className == 'structural') {
        classCode += `    rand int nChis;\n`;
        classCode += `    rand int nIoaius;\n`;
        classCode += `    rand int nAces;\n`;
        classCode += `    string chiFnNativeInterface[];\n`;
        classCode += `    string ioaiuFnNativeInterface[];\n`;
        classCode += `    constraint c_unit_count{\n`;
        classCode += `        (nIoaius >= nNcaius.values) && (nIoaius <= nCaius.values+nNcaius.values);\n`;
        classCode += `        nChis <= (nCaius.values) && (nChis >= 0);\n`;
        classCode += `        nCaius.values == (nChis + (nIoaius - nNcaius.values));\n`;
        classCode += `        nAces == nCaius.values -nChis;\n`;
        classCode += `    }\n\n`;
    }

    const nChild = children.length;

    classCode += `\n    function new();\n`;
    children.forEach(child => {
        if (!multipleUnits.includes(child)) {
            classCode += `        ${child} = new();\n`;
        } else if (multipleUnits.includes(child)) {
            switch(child) {
                case "chi": {
                    classCode += `        ${child} = new[MAX_AIU_UNITS];\n`;
                    break;
                }
                case "cioaiu": {
                    classCode += `        ${child} = new[MAX_AIU_UNITS];\n`;
                    break;
                }
                case "ncioaiu": {
                    classCode += `        ${child} = new[MAX_AIU_UNITS];\n`;
                    break;
                }
                case "snoopFilter": {
                    classCode += `        ${child} = new[MAX_D_UNITS];\n`;
                    break;
                }
                case "dce": {
                    classCode += `        ${child} = new[MAX_D_UNITS];\n`;
                    break;
                }
                case "dve": {
                    classCode += `        ${child} = new[1];\n`;
                    break;
                }
                case "dmi": {
                    classCode += `        ${child} = new[MAX_D_UNITS];\n`;
                    break;
                }
                case "dii": {
                    classCode += `        ${child} = new[MAX_D_UNITS];\n`;
                    break;
                }
                default: {
                    classCode += `        ${child} = new[MAX_D_UNITS];\n`;
                    break;
                }
            }
        }
    });
    if (className == 'params') {
        classCode += `//cg_crosses = new();`;
    }
    classCode += `    \nendfunction: new\n\n`;

    if (hasArray) {
        classCode += `    function string sprint(string handle);\n`;
        for (let i=0; i<nChild; i+=1) {
            if (multipleUnits.includes(children[i])) {
                classCode += `        string ${children[i]}_str = "";\n`;
            }
        }
        for (let i=0; i<nChild; i+=1) {
            if (multipleUnits.includes(children[i])) {
                classCode += `        foreach (${children[i]}[i]) begin\n`;
                classCode += `            if (i > 0) ${children[i]}_str = {${children[i]}_str, ", "};\n`;
                classCode += `            ${children[i]}_str = {${children[i]}_str, ${children[i]}[i].sprint("")};\n`;
                classCode += `        end\n`;
            }else {

            }
        }
        classCode += `        if(handle == "") begin\n`;
       
        classCode += `            return $sformatf("{`;
        for (let i=0; i<nChild; i+=1) {
            if (multipleUnits.includes(children[i])) {
                classCode += `\\"${children[i]}\\": [%s]`
            }else {
                classCode += `%s`
            }
            if (i != nChild-1) classCode += `,`;
        }
        classCode += `}",`;
        for (let i=0; i<nChild; i+=1) {
            if (multipleUnits.includes(children[i])) {
                classCode += `${children[i]}_str`
            }else {
                classCode += `${children[i]}.sprint("${children[i]}")`;
            }
            if (i != nChild-1) classCode += `,`;
        }
        classCode += `);\n`;
        classCode += `        end else begin\n`;
        classCode += `            return $sformatf("\\"%s\\":{`;
        for (let i=0; i<nChild; i+=1) {
            if (multipleUnits.includes(children[i])) {
                classCode += `\\"${children[i]}\\": [%s]`
            }else {
                classCode += `%s`
            }
            if (i != nChild-1) classCode += `,`;
        }
        classCode += `}", handle,`;
        for (let i=0; i<nChild; i+=1) {
            if (multipleUnits.includes(children[i])) {
                classCode += `${children[i]}_str`
            }else {
                classCode += `${children[i]}.sprint("${children[i]}")`;
            }
            if (i != nChild-1) classCode += `,`;
        }
        classCode += `);\n`;
        classCode += `        end\n`;
        classCode += `    endfunction\n\n`;
    }else{
        classCode += `    function string sprint(string handle);\n`;
        classCode += `        if(handle == "") begin\n`;
        classCode += `            return $sformatf("{`;
        for (let i=0; i<nChild; i+=1) {
            classCode += `%s`;
            if (i != nChild-1) classCode += `,`;
        }
        classCode += `}"${nChild>0?',':''} `;
        for (let i=0; i<nChild; i+=1) {
            classCode += `${children[i]}.sprint("${children[i]}")`;
            if (i != nChild-1) classCode += `,`;
        }
        classCode += `);\n`;
        classCode += `        end else begin\n`;
        classCode += `            return $sformatf("\\"%s\\": { `;
        for (let i=0; i<nChild; i+=1) {
            classCode += `%s`;
            if (i != nChild-1) classCode += `,`;
        }
        classCode += `}", handle${nChild>0?',':''} `;
        for (let i=0; i<nChild; i+=1) {
            classCode += `${children[i]}.sprint("${children[i]}")`;
            if (i != nChild-1) classCode += `,`;
        }
        classCode += `);\n`;
        classCode += `        end\n`;
        classCode += `    endfunction: sprint\n\n`;
    }

    classCode += `\n    function void sample();\n`;
    for (let i=0; i<nChild; i+=1) {
        if (multipleUnits.includes(children[i])) {
            classCode += `        foreach(${children[i]}[i])begin
                        ${children[i]}[i].sample();
                    end\n`;
        }else{
            classCode += `        ${children[i]}.sample();\n`;
        }
    }
    classCode += `\n    endfunction: sample\n`;
    
    if (className == 'params') {
        classCode += `\n    //================================================================\n`;
        classCode += `    //                       INSERT CONSTRAINTS                         \n`;
        classCode += `    //==================================================================\n\n`;
        classCode += insertConstraints();
        classCode += `    //=========================END CONSTRAINTS==========================\n\n`;
        classCode += `    //=========================STRUCTURAL CONSTRAINTS===================\n\n`;
        classCode += `    constraint c_structural{
            ncioaiu.size() == structural.nNcaius.values;
            cioaiu.size() == structural.nCaius.values - structural.nChis;
            chi.size() == structural.nChis;
            dve.size() == structural.nDves.values;
            dce.size() == structural.nDces.values;
            dmi.size() == structural.nDmis.values;
            dii.size() == structural.nDiis.values;
            snoopFilter.size() == structural.nSnoopFilters.values;

        }`;
        classCode += `    //=========================END STRUCTURAL CONSTRAINTS===============\n\n`;
        classCode += populatePostRandomize();
        classCode += `
        
        function void pre_randomize();
            foreach(dve[i]) begin
                dve[i] = new;
            end
            foreach(cioaiu[i]) begin
                cioaiu[i] = new;
            end
            foreach(ncioaiu[i]) begin
                ncioaiu[i] = new;
            end
            foreach(chi[i]) begin
                chi[i] = new;
            end
            foreach(dce[i]) begin
                dce[i] = new;
            end
            foreach(dmi[i]) begin
                dmi[i] = new;
            end
            foreach(dii[i]) begin
                dii[i] = new;
            end
            foreach(snoopFilter[i]) begin
                snoopFilter[i] = new;
            end
            foreach(nMIGS[i]) begin
                nMIGS[i] = new;
                foreach(nMIGS[i].nGroups[j]) begin
                    nMIGS[i].nGroups[j] = new;
                end 
            end
             
                
        endfunction: pre_randomize

        function void make_new();
            foreach(dve[i]) begin
                dve[i] = new;
            end
            foreach(cioaiu[i]) begin
                cioaiu[i] = new;
            end
            foreach(ncioaiu[i]) begin
                ncioaiu[i] = new;
            end
            foreach(chi[i]) begin
                chi[i] = new;
            end
            foreach(dce[i]) begin
                dce[i] = new;
            end
            foreach(dmi[i]) begin
                dmi[i] = new;
            end
            foreach(dii[i]) begin
                dii[i] = new;
            end
            foreach(snoopFilter[i]) begin
                snoopFilter[i] = new;
            end
            foreach(nMIGS[i]) begin
                nMIGS[i] = new;
                foreach(nMIGS[i].nGroups[j]) begin
                    nMIGS[i].nGroups[j] = new;
                end 
            end
             
        endfunction: make_new

        function void post_randomize();
            ${addPostRandomizeFunctions()}
        endfunction: post_randomize
        `;
    }
    classCode += `endclass: ${appendChild ?? ''}${className}_class\n\n`;
    
    return classCode;
}

const createLeafNodeClass = (name, parent, data, weight) => {
    const requiredParams = ['nCaius','nNcaius','nDces','nDves','nDmis', 'nDiis', 'fnNativeInterface', 'wData', 'multicycleODSram', 'nCMDSkidBufArb', 'nCMDSkidBufSize', 'atomicTransactions', 'checkType'];
    const className = toSnakeCase(name);
    const append = parent && parent.split("class")[0];

    let classCode = `class ${append}${className}_class;\n`;

    if (data.type && data.values) {
        classCode += `    rand `;
        switch (data.type) {
            case 'int':
                classCode += `int values;\n`;
                if (data.values.length == 1 && (typeof data.values[0] === 'string') && data.values[0].includes(":")){
                    const [min, max] = data.values[0].split(':').map(Number);
                    classCode += `    constraint c_values {\n        values inside {[32'd${min}:32'd${max}]};\n    }\n`;
                    classCode += `    // ${name} \n`;
                    if (requiredParams.includes(name)) {
                        classCode += `    covergroup cg_values;
                            option.per_instance = 1;
                            cp_valid_values: coverpoint values {
                                ${((max-min) > 64)? `bins valid_values[64] =  {[32'd${min}:32'd${max}]};` : `bins valid_values[${max-min+1}] =  {[32'd${min}:32'd${max}]};`}
                            }
                        endgroup: cg_values\n`;
                    }
                }else if(data.values.length>0){
                    classCode += `    constraint c_values {\n        values inside {${data.values.join(', ')}};\n    }\n`;
                    // classCode += `    constraint c_values {\n        values inside {${data.values.map(v => v.replace(/-/g, '_')).join(', ')}};\n    }\n`;

                    classCode += `    // ${name} \n`;
                    if (requiredParams.includes(name)) {
                        classCode += `    covergroup cg_values;
                            option.per_instance = 1;
                            cp_valid_values: coverpoint values {
                                bins valid_values[] =  {${data.values.join(', ')}};
                            }
                        endgroup: cg_values\n`;
                    }
                }
                if (weight && Object.keys(weight.archWeights).length > 0) {
                    classCode += `    constraint c_values_dist {\n`;
                    classCode += `        values dist {\n`;
                    const wLength = Object.keys(weight.archWeights).length;
                    for (let i=0; i<wLength; i+=1) {
                        const val = Object.keys(weight.archWeights)[i];
                        if (val.includes(":")) {
                            classCode += `            ${val} :/ ${weight.archWeights[val]}`;
                        }else {
                            classCode += `            ${val} := ${weight.archWeights[val]}`;
                        }
                        classCode += (i != wLength -1) ? `,\n` : `\n`;
                    }
                    classCode += `        };\n`;
                    classCode += `    }\n\n`;
                }
                break;
            case 'hex':
                classCode += `int unsigned values;\n`;
                if (data.values.length == 1 && (typeof data.values[0] === 'string') && data.values[0].includes(":")){
                    const [min, max] = data.values[0].split(':').map(value => parseInt(value, 16));
                    classCode += `    constraint c_values {\n        values inside {[32'd${min}:32'd${max}]};\n    }\n`;
                    classCode += `    // ${name} \n`;
                    if (requiredParams.includes(name)) {
                        classCode += `    covergroup cg_values;
                            option.per_instance = 1;
                            cp_valid_values: coverpoint values {
                                ${((max-min) > 64)? `bins valid_values[64] =  {[32'd${min}:32'd${max}]};` : `bins valid_values[${max-min+1}] =  {[32'd${min}:32'd${max}]};`}
                            }
                        endgroup: cg_values\n`;
                    }
                }else if(data.values.length>0){
                    classCode += `    constraint c_values {\n        values inside {${data.values.join(', ')}};\n    }\n`;
                    classCode += `    // ${name} \n`;
                    if (requiredParams.includes(name)) {
                        classCode += `    covergroup cg_values;
                            option.per_instance = 1;
                            cp_valid_values: coverpoint values {
                                bins valid_values[] =  {${data.values.join(', ')}};
                            }
                        endgroup: cg_values\n`;
                    }
                }
                break;
            case 'longint':
                classCode += `longint unsigned values;\n`;
                if (data.values.length == 1 && (typeof data.values[0] === 'string') && data.values[0].includes(":")){
                    const [min, max] = data.values[0].split(':').map(Number);
                    classCode += `    constraint c_values {\n        values inside {[64'd${min}:64'd${max}]};\n    }\n`;
                    classCode += `    // ${name} \n`;
                    if (requiredParams.includes(name)) {
                        classCode += `    covergroup cg_values;
                            option.per_instance = 1;
                            cp_valid_values: coverpoint values {
                                ${((max-min) > 64)? `bins valid_values[64] =  {[64'd${min}:64'd${max}]};` : `bins valid_values[${max-min+1}] =  {[64'd${min}:64'd${max}]};`}
                            }
                        endgroup: cg_values\n`;
                    }
                }else if(data.values.length>0){
                    classCode += `    constraint c_values {\n        values inside {${data.values.join(', ')}};\n    }\n`;
                    classCode += `    // ${name} \n`;
                    if (requiredParams.includes(name)) {
                        classCode += `    covergroup cg_values;
                            option.per_instance = 1;
                            cp_valid_values: coverpoint values {
                                bins valid_values[] =  {${data.values.join(', ')}};
                            }
                        endgroup: cg_values\n`;
                    }
                }
                break;
            case 'string':
            case 'enum':
            case 'Enum':
                if (Array.isArray(data.values)) {
                    // const validValues = data.values; //.map(v => `"${v}"`);
                    // const length = validValues.length;
                    //classCode += `    bit[${Math.ceil(Math.log2(length))-1}:0] choice;\n`
                    classCode += `    value_e values;\n`;
                    classCode += `    constraint c_values {\n        values inside {${data.values.map(v => v.replace(/-/g, '_'))}};\n    }\n`;
                    classCode += `    // ${name} \n`;
                    if (requiredParams.includes(name)) {
                        classCode += `    covergroup cg_values;
                            option.per_instance = 1;
                            cp_valid_values: coverpoint values {
                                bins valid_values[] =  {${data.values.map(v => v.replace(/-/g, '_'))}};
                            }
                        endgroup: cg_values\n\n`;
                    }
                    // classCode += `    function void post_randomize();\n`;
                    // classCode += `        if (choice >= ${length}) choice = ${length-1};\n`;
                    // classCode += `        values = validValues[choice];\n`;
                    // classCode += `    endfunction\n`;
                }
                break; 
            case 'boolean':
                classCode += `bit choice;\n`;
                classCode += `    string values;\n\n`;
                classCode += `    // ${name} \n`;
                if (requiredParams.includes(name)) {
                    classCode += `    covergroup cg_values;
                        option.per_instance = 1;
                        cp_valid_values: coverpoint choice {
                            bins valid_values[] =  {[0:1]};
                        }
                    endgroup: cg_values\n\n`;
                }
                
                classCode += `    function void post_randomize();\n`;
                classCode += `        values = choice ? "true" : "false";\n`;
                classCode += `    endfunction\n`;
                break;
            default:
                console.warn(`Unhandled type: ${data.type} for ${name}`);
                classCode += `/* Unhandled type: ${data.type} */\n`;
                break;
        }
    } else {
        console.warn(`Missing type or values for ${name}`);
        classCode += `    /* Missing type or values */\n`;
    }

    classCode += `
                    function void sample();
                        ${(data.type && (data.values.length>0) && requiredParams.includes(name))?"cg_values.sample();":""}
                    endfunction: sample
                `;
            
    classCode += `\n    function new();
        ${(data.type && (data.values.length>0) && requiredParams.includes(name))?"cg_values = new();":""}
    endfunction: new\n\n`;

    if (data.type && data.values) {
        classCode += `    function string sprint(string handle);\n`;
        classCode += `        if(handle == "") begin\n`;
        classCode += `            return $sformatf("{ \\"values\\": %p }", values);\n`;
        classCode += `        end else begin\n`;
        classCode += `            if(type(values) == type(string))begin\n`;
        classCode += `                return $sformatf("\\"%s\\": { \\"values\\": %0p }", handle, values);\n`;
        classCode += `            end else begin\n`;
        classCode += `                return $sformatf("\\"%s\\": { \\"values\\": \\"%0p\\" }", handle, values);\n`;
        classCode += `            end\n`;
        classCode += `        end\n`;
        classCode += `    endfunction\n\n`;
    }
    classCode += `endclass: ${append}${className}_class\n\n`;
    
    return classCode;
}

const traverseJSON = (obj, weights, path, classes, classNames) => {
    const children = [];
    for (let key in obj) {
        if (typeof obj[key] === 'object' && obj[key] !== null && !Array.isArray(obj[key])) {
            if (obj[key].type && obj[key].values) {
                const parentClassName = `${toSnakeCase(path[path.length - 1])}_class`;
                classes.push(createLeafNodeClass(key, parentClassName, obj[key], weights[key]));
                children.push(key);
                classNames.add(`${toSnakeCase(key)}_class`);
            } else {
                children.push(key);
                traverseJSON(obj[key], weights[key], [...path, key], classes, classNames);
            }
        }
    }
    const className = path[path.length - 1];
    const parentClassName = path.length > 1 ? `${toSnakeCase(path[path.length - 2])}_class` : null;
    classes.push(createClass(className, parentClassName, children));
    classNames.add(`${toSnakeCase(className)}_class`);
}

const defineTypedefs = () => {
    return `
        typedef enum {
            CHI_B = 0,
            CHI_E = 1,
            ACE = 2,
            ACE5 = 3,
            AXI4 = 4,
            AXI5 = 5,
            ACE_Lite = 6,
            ACE5_Lite = 7,
            PCIe_ACE_Lite = 8,
            PCIe_AXI4 = 9,
            PCIe_AXI5 = 10,
            TwoCtrlOneDataTemplate = 11,
            ThreeCtrlOneDataTemplate = 12,
            FourCtrlOneDataTemplate = 13,
            NONE = 14,
            PARITY = 15,
            SECDED = 16,
            always_on = 17,
            external = 18,
            ODD_PARITY_BYTE_ALL = 19,
            RANDOM = 20,
            NRU = 21,
            SRRIP = 22,
            pLRU = 23,
            PLRU = 24
        } value_e;
    `;
}

const generateSystemVerilog = (params, weights) => {
    const classes = [];
    const classNames = new Set();
    
    traverseJSON(params.ncoreParams.architecture, weights.ncoreParams.architecture, ['params'], classes, classNames);
    
    const packageCode = `package params_pkg;
                            ${defineTypedefs()}
                            parameter int MAX_AIU_UNITS=32;
                            parameter int MAX_D_UNITS=16;
                            
                            ${classes.join('')}
                        endpackage: params_pkg
                        `;
    
    return packageCode;
}

const refineParams = (obj) => {
    if (typeof obj !== 'object' || obj === null) {
      return obj;
    }
  
    if (Array.isArray(obj)) {
      return obj.map(refineParams);
    }
  
    if ('type' in obj && 'architectureValidValues' in obj) {
        let cleanedValues = obj.architectureValidValues;
        if (Array.isArray(cleanedValues)) {
          cleanedValues = cleanedValues.map(value => {
            if (typeof value === 'string') {
              return value.replace(/^["']|["']$/g, '').replace(/\\"/g, '"');
            }
            return value;
          });
        }
        return {
          type: obj.type,
          values: cleanedValues
        };
      }
  
    const result = {};
    for (const [key, value] of Object.entries(obj)) {
      result[key] = refineParams(value);
    }
  
    return result;
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

// const executeCommandAndSaveOutput = async (command, outputPath) => {
//     const originalDir = process.cwd();
//     try {
//         process.chdir(outputPath);
//         const { stdout, stderr } = await execPromise(command);
//         const output = stdout + stderr;
//         await fs.writeFile(`${outputPath}/vcs.log`, output);
//         if (output.includes("Error-") || output.includes("Compilation failed")) {
//             throw new Error("VCS compilation failed");
//         }
//         return { success: true, output};
//     } catch (error) {
//         console.error(`Error executing command or writing to file: ${error.message}`);
//         throw error;
//     } finally {
//         process.chdir(originalDir);
//     }
// }

const addParams = (obj, weightObj) => {
    obj.ncoreParams.architecture["nMIGS"] = {
        "nGroups": {
            "type":"int",
            "values": [
                "1:16"
            ]
        }
    }
    weightObj.ncoreParams.architecture["nMIGS"] = {
        "nGroups": {
            "architectureValidValues": {
                "0": "1:32"
            },
            "archWeights": {},
            "releaseValidValues": {
            "0": "1:32"
            },
            "releaseWeights": {}
        }
    }
    
    return obj;
}

const buildSvModel = (outputPath) => {
    const paramsFilePath = `${RANDOMIZER_HOME}/params/params.json`;
    const weightsFilePath = `${RANDOMIZER_HOME}/params/config/weights.json`;
    // const transDirPath = `${process.env.MAESTRO_EXAMPLES}/hw_randomizer_config_${seed}/transient`;
    // const tempParamCovDir = `${process.env.WORK_TOP}/transient`;
    const params = JSON.parse(fs.readFileSync(paramsFilePath, 'utf8'));
    const weights = JSON.parse(fs.readFileSync(weightsFilePath, 'utf8'));
    const refinedParams = refineParams(params);
    const addedParams = addParams(refinedParams, weights);

    // let compileStatus = null;
    // let simStatus = null;
    
    const systemVerilogCode = generateSystemVerilog(refinedParams, weights);
    // const topLevelModule = constructTopLevelModule(seed);
    console.log("SystemVerilog code has been generated in params_pkg.sv at path: "+outputPath);

    try {
        fs.mkdirSync(outputPath, { recursive: true });
        // if (isParamCovOn) {
        //     await fs.mkdir(tempParamCovDir, { recursive: true });
        // }
    } catch (error) {
        console.error(`Error creating directory: ${error.message}`);
    }

    fs.writeFileSync(`${outputPath}/params_pkg.sv`, systemVerilogCode);
    // if (isParamCovOn) {
    //     await fs.writeFile(`${tempParamCovDir}/params_pkg.sv`, systemVerilogCode);
    // }
    // await fs.writeFile(`${transDirPath}/random.sv`, topLevelModule);
    // try {
    //     const compileCmd = `vcs -sverilog -full64 -cm line -cm_name simv.vdb -q +vcs+lic+wait -debug_access+r ${transDirPath}/params_pkg.sv ${transDirPath}/random.sv`;
    //     process.env.VCS_HOME = '/engr/eda/tools/synopsys/vcs_vV-2023.12-SP2-1/vcs/V-2023.12-SP2-1';
    //     compileStatus = await executeCommandAndSaveOutput(compileCmd, transDirPath);
    //     const simCmd = `./simv +ntb_random_seed=${seed}`;
    //     if(compileStatus.success) simStatus = await executeCommandAndSaveOutput(simCmd, transDirPath);
    // } catch (error) {
    //     console.error('An error occurred:', error);
    // } finally {
    //     try {
    //         if(compileStatus && simStatus) {
    //             await fs.rm(transDirPath, { recursive: true, force: true });
    //             console.log(`Directory deleted successfully: ${transDirPath}`);
    //         }else{
    //             console.log("Saving the transient directory as compile or simulation failed. Check ",`${process.env.MAESTRO_EXAMPLES}/hw_randomizer_config_${seed}/`," for more details");
    //         }
    //         return JSON.parse(await fs.readFile(`${process.env.MAESTRO_EXAMPLES}/hw_randomizer_config_${seed}/random_params.json`, 'utf8'));
    //     } catch (error) {
    //         console.error(`Error deleting directory: ${error.message}`);
    //     }
    // }
};

module.exports = buildSvModel;