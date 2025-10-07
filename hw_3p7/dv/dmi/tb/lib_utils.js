'use strict';

var fs=require('fs'),
    path=require('path');

var wCachelineOffset = 6;
const braces		= envelope.bind(null,"{","}");
const parens		= envelope.bind(null,"(",")");
const brackets		= envelope.bind(null,"[","]");

function log2ceil(n) { 
    return Math.ceil(Math.log2(n));
}

function log2floor(n) { 
    return Math.floor(Math.log2(n));
}

function deepCopy(o) {
    return JSON.parse(JSON.stringify( o ));
}

function writeJSON(file_name,param) {
    var param_text = JSON.stringify(param,null,2);
    var result = fs.writeFileSync(file_name,param_text,'utf8');    
}

function readJSON(file) {
	const text				= fs.readFileSync(file,'utf8');
	const jsonObj			= JSON.parse(text);
	return jsonObj;
}

function assertHeader (tab_string) {
    if (tab_string === undefined) {
       var tab_string = '';
    }
    var string = '';
    
    string = string + tab_string + '//////////////////////////////////////////////////////////////////////////\n';
    string = string + tab_string + '// Assertions\n';
    string = string + tab_string + '//////////////////////////////////////////////////////////////////////////\n';
    string = string + tab_string + '// synopsys translate_off  \n';
    string = string + tab_string + '// pragma synthesis_off \n';
    string = string + tab_string + '// coverage off \n';
    string = string + tab_string + '//////////////////////////////////////////////////////////////////////////\n';
    
    return string;
}

function assertFooter (tab_string) {
    if (tab_string === undefined) {
       var tab_string = '';
    }
    var string = '';

    string = string + tab_string + '//////////////////////////////////////////////////////////////////////////\n'; 
    string = string + tab_string + '// synopsys translate_on \n';
    string = string + tab_string + '// pragma synthesis_on \n';
    string = string + tab_string + '// coverage on \n';
    string = string + tab_string + '//////////////////////////////////////////////////////////////////////////\n';
    
    return string;
}

function getTraceStructDefault () {
    
    var example_default = {
        globals: {
            traceFile: 'tb_top.m_top_wrapper.trace_file',
            globalTimeStamp: 'tb_top.m_top_wrapper.global_counter',
            sampleTime: 1,
            traceOn: 'tb_top.m_top_wrapper.traceOn',
            closeTrace: 'tb_top.m_top_wrapper.closeTrace',
            globalClk: 'tb_top.m_top_wrapper.mainRegime_Cm_root_'
        }
    }

    return null;
}

function getTraceOnDefault () {
    return false;
}

function getDumpTraceDefault () {
    return "1'b1";
}

function tieOffNewInterface(a_name, an_interface, direction, values, indent) {
    var answer = "";
    var i = 0;
    var j = 0;
    var value = "";
    var signals = Object.keys(an_interface);
    signals.sort();

    for (i = 0; i < signals.length; i++) {
        if (an_interface[signals[i]].type === undefined) {
            answer = answer + tieOffNewInterface(a_name+signals[i],an_interface[signals[i]],direction,values,indent);
        } else {
            value = ""+an_interface[signals[i]].width+"'b0";
            if (((direction === 'master') && (an_interface[signals[i]].dir === 'm_out')) ||
                ((direction === 'slave') && (an_interface[signals[i]].dir === 'm_in'))) {
                if (an_interface[signals[i]].width > 0) {
                    for (j = 0; j < values.length; j++) {
                        if (a_name+signals[i] === values[j].signal) {
                            value = values[j].value;
                        }
                    }
                    answer = answer+indent+'assign '+a_name+signals[i]+' = '+value+';\n';
                }
            }
        }
    }
    return answer;
}

function compareNewInterfacesDiffer(interface1, interface2) {
    var i = 0;
    var mismatch = false;

    var signals1 = Object.keys(interface1);
    signals1.sort();
    var signals2 = Object.keys(interface2);
    signals2.sort();

    if (signals1.length === signals2.length) {
        for (i = 0; i < signals1.length; i++) {
            if (signals1[i] !== signals2[i]) {
                mismatch = true;
            } else {
                if ((interface1[signals1[i]].type === undefined) && (interface2[signals1[i]].type === undefined)) {
                    mismatch = mismatch || compareNewInterfacesDiffer(interface1[signals1[i]],interface2[signals1[i]]);
                } else if ((interface1[signals1[i]].type === undefined) || (interface2[signals1[i]].type === undefined)) {
                    mismatch = true;
                } else if ((interface1[signals1[i]].dir !== interface2[signals2[i]].dir) ||
                           (interface1[signals1[i]].width !== interface2[signals2[i]].width)) {
                    mismatch = true;
                }
            }
        }
    } else {
        mismatch = true;
    }
    return mismatch;
}

function findLocalInterfaceName(moduleName,instanceInterfaces,instanceName) {
    var i = 0;
    var name_hit = false;

    var local_name = "";

    for (i = 0; i < instanceInterfaces.length; i++) {
        if (instanceInterfaces[i].module === moduleName) {
            name_hit = true;
            local_name = instanceInterfaces[i].local;
        }
    }
    /* istanbul ignore if env ncore_3p0 */
    if (!name_hit) {
        console.log('ERROR: findLocalInterfaceName: no local name for interface '+moduleName+' on instance '+instanceName);
        console.log(moduleName);
        console.log(instanceInterfaces);
        throw "ERROR - findLocalInterfaceName";
    }
    return local_name
}

function createLocalInterfaceNames(interfaces,instanceInterfaces,instanceName) {
    var i = 0;
    var j = 0;
    var localInterfaceNames = {};

    var interface_names = Object.keys(interfaces);
    for (i = 0; i < interface_names.length; i++) {
        if (typeof interfaces[interface_names[i]] === 'object') {
            if (Array.isArray(interfaces[interface_names[i]])) {
                localInterfaceNames[interface_names[i]] = [];
                for (j = 0; j < interfaces[interface_names[i]].length; j++) {                    
                    if (interfaces[interface_names[i]][j]._SKIP_ === undefined) {
                        interfaces[interface_names[i]][j]._SKIP_ = false;
                    }
                    if (!interfaces[interface_names[i]][j]._SKIP_) {
                        if (interfaces[interface_names[i]][j].name === undefined) {
                            localInterfaceNames[interface_names[i]][j] = createLocalInterfaceNames(interfaces[interface_names[i]][j],instanceInterfaces,instanceName);
                        } else {
                            localInterfaceNames[interface_names[i]][j] = {};
                            localInterfaceNames[interface_names[i]][j].name = findLocalInterfaceName(interfaces[interface_names[i]][j].name,instanceInterfaces,instanceName);
                        }
                    }
                }
            } else {
                if (interfaces[interface_names[i]]._SKIP_ === undefined) {
                    interfaces[interface_names[i]]._SKIP_ = false;
                }
                if (!interfaces[interface_names[i]]._SKIP_) {
                    if (interfaces[interface_names[i]].name === undefined) {
                        localInterfaceNames[interface_names[i]] = createLocalInterfaceNames(interfaces[interface_names[i]],instanceInterfaces,instanceName);
                    } else {
                        localInterfaceNames[interface_names[i]] = {};
                        localInterfaceNames[interface_names[i]].name = findLocalInterfaceName(interfaces[interface_names[i]].name,instanceInterfaces,instanceName);
                    }
                }
            }
        }
    }
    return localInterfaceNames;
}


// Function to return the signal bundle object (with keys as signal names
// and values as their widths) from a new-style interface object
// constructors is an associative array/object of constructor functions with
// interface types ("InterfaceAXI", "InterfaceAPB") as keys
function getSignalsBundle( constructors, interfaceObj ) {
  const interfaceInst		= new constructors[ interfaceObj["interface"] ];
  return interfaceInst.getSignalsBundle( interfaceObj.params );
}


function synonymsToSignalsBundle( synonyms, direction ) {
	const result	= {};
	
	synonyms["in"].forEach( x => {
		result[x.name]		= direction === "master" ? -x.width : x.width;
	});

	synonyms["out"].forEach( x => {
		result[x.name]		= direction === "master" ? x.width : -x.width;
	});

	return result;
}


// Function to convert new-style interface to old-style interface (signalsBundle)
// constructors is an associative array/object of constructor functions with
// interface types ("InterfaceAXI", "InterfaceAPB") as keys
function newToOldStyleInterface( constructors, newStyleInterfaceObj ) {
	const signals					= (newStyleInterfaceObj["interface"] === "InterfaceGeneric") && newStyleInterfaceObj.synonymsOn && newStyleInterfaceObj.synonymsExpand ? 
									  synonymsToSignalsBundle( newStyleInterfaceObj.synonyms, newStyleInterfaceObj.direction ) : 
									  getSignalsBundle( constructors, newStyleInterfaceObj );

	const commonProps				= { name: newStyleInterfaceObj.name, signals };
	const interfaceSpecificProps	= (newStyleInterfaceObj["interface"] === "InterfaceAPB") ? { "path": newStyleInterfaceObj.path || []  } : 
									  {};
	return Object.assign({}, commonProps, interfaceSpecificProps);
}


// Function to flatten a signalsBundle ( object of signal names as keys, and their widths as values ) 
function flattenSignalsBundle(signals, prefix="") {
    const signalsFlat	= {};

	Object.entries(signals).forEach( ([key, value]) => {
		if(typeof value === 'object') {
			Object.entries(flattenSignalsBundle(value, key)).forEach( ([name, width]) => {
				signalsFlat[prefix+name]	= width;
			});

		} else {
			signalsFlat[prefix+key]			= value;

		}
	});

	return signalsFlat;
}


// Function to flatten an old-style nested interface object ({ name, signals })
// This returns an old-style interface by appending sub-interface prefixes to signal names 
function flattenInterface(intrface) {
	return { name: intrface.name, signals: flattenSignalsBundle(intrface.signals) };
}


function getPath(file_path) {
  if(path.isAbsolute(file_path)) {
    return file_path;
  } else if(file_path.match(/^\$/) != null) {
    var s_file_path = file_path.split('/');
    var env_var = s_file_path[0].split('$');
//  console.log(' env_var[0] ' + env_var[0] +' env_var[1] ' + env_var[1]);
    var r_path = s_file_path.splice(0,1);
    if(process.env[env_var[1]] == undefined ) {
      console.log( ' var $'+env_var[1]+' is undefined ');
      throw (' var $'+env_var[1]+' is undefined ');
    }
    var epath = process.env[env_var[1]];
    var j_path = s_file_path.join('/');
//  console.log(' epath ' + epath)
//  console.log(' s_file_path ' + s_file_path + ' env_var ' + env_var + ' r_path ' + r_path + 'j_path' + j_path);
    var pktpath = epath+'/'+j_path;
//  console.log(' pktpath ',pktpath);
    return pktpath;
  } else {
    throw (' file_path incorrect use either absolute or based on an env variable ');
  }
}

function getPathParam(file_path) {
  return require(path.resolve(getPath(file_path)));
}

function loadHierJason(param) {
    if ((param === null) || (param === undefined)) {
        if (param === null) {
            return null;
        } else {
            return undefined;
        }
    } else {
        var new_answer = [];
        var instance_flag = {status1 : "notFound"};
        var new_array = generateObjects(param, "noInstances", instance_flag, new_answer);
        if (!(new_array === undefined || new_array.length == 0)) {
            console.log(new_array);
            param = new_array;
        }

        if (typeof param === 'object') {
            if (Array.isArray(param)) {
                var i;
                var new_param = [];
                for (i = 0; i < param.length; i++) {
                    new_param[i] = loadHierJason(param[i]);
                }
                return new_param;
            } else {
                if (param['file_path'] === undefined) {
                    var new_param = {};
                    var param_keys = Object.keys(param);
                    var i;
                    for (i = 0; i < param_keys.length; i++) {
                        new_param[param_keys[i]] = loadHierJason(param[param_keys[i]]);
                    }
                    return new_param;
                } else {
                    var my_file_path = getPath(param['file_path']);
                    //              console.log(' data before path resolve '+my_file_path);
                    //              if(path.isAbsolute(param['file_path'])) { 
                    //              var data = require(path.resolve(param['file_path'])); }
                    //              else  {
                    //              console.log(' __dirname ' + process.cwd() + ' file_path ' + param['file_path']);
                    //              var data = path.resolve(process.cwd(), param['file_path']);
                    //              }
                    var data = require(path.resolve(my_file_path));
                    //              console.log(' data after path resolve '+JSON.stringify(param['file_path'])+' '+ JSON.stringify(data));
                    if (!Array.isArray(data)) { // You can't merge parameters if file_path points to an array
                        var new_param = JSON.parse(JSON.stringify(param));
                        delete new_param.file_path;
                        var new_data = Object.assign({},data,new_param); // values in param will override values in data (from file_path)
                        data = {};
                        data = new_data;
                    } else {
                        var param_keys = Object.keys(param);
                        if (param_keys.length > 1) {
                            console.log("WARNING - loadHierJason: 'file_path' points to an array and can't merge with an object.");
                            console.log(param);
                        }
                    }
                    return loadHierJason((data));
                }
            }
        } else {
            var new_param;
            new_param = JSON.parse(JSON.stringify(param));
            return new_param;
        }
    }
}

function hierGetParam(param,getParam) {
    var answer = getParam(param);
    if ((answer === null) || (answer === undefined)) {
        return answer;
    } else {
        return loadHierJason(answer);
    }
}

function getNthBit(value, n) {
    var blah = value;
    var foundbit = 0;
    for ( var bitpos = 0; blah >0; bitpos++) {
        if (blah % 2 === 1) {
            foundbit++
            if (foundbit === n) {
                return bitpos;
            }
        }
        blah = Math.floor(blah / 2);
    }
    return -1;
}

function countBits(value) {
    var blah = value;
    var numbits = 0;
    for ( var bitpos = 0; blah >0; bitpos++) {
        if (blah % 2 === 1) {
            numbits++
        }
        blah = Math.floor(blah / 2);
    }
    return numbits;
}

    /************************************************************
     * Given an interface object, defines all the input and 
     * output ports for the interface, where the interface is 
     * used as an master.
     *
     * @arg {string} prefix - the prefix to use for all port names.
     * @arg {object} intfDesc - the interface descriptor object
     *
     */
    function defineMasterPortsFromInterface (prefix, intfDesc, objLibPortFunction, excludeList) {
    
    if (typeof excludeList === 'undefined' || excludeList === null) {
        excludeList = [];
    }     
        
        for (var signal in intfDesc) {
            var width = intfDesc[signal];
            if (width == 0) {
                // Do nothing.
            } else if (excludeList.indexOf(signal) != -1) {
                // Do nothing.
            } else if (width > 0) {
                // This is master -> slave direction, so an output for masters.
                objLibPortFunction('output', prefix+signal, width);
            } else  if (width < 0) {
                // This is master -> slave direction, so an input for masters.
                objLibPortFunction('input', prefix+signal, (0-width));
            } else {
                //u.log("Utils Error:defineMasterPorts ("+this.m.address+"): Interface signal "+signal+" width "+width);
            }
        }
    };


    /************************************************************
     * Special function. 
     * Given an interface object, forces the same direction of all
     * signals within the interface, where the interface is 
     * used as a master.
     *
     * @arg {string} prefix - the prefix to use for all port names.
     * @arg {object} intfDesc - the interface descriptor object
     *
     */
    function forceMasterPortsFromInterface (prefix, intfDesc, objLibPortFunction, excludeList) {
    
    if (typeof excludeList === 'undefined' || excludeList === null) {
        excludeList = [];
    }     
        
        for (var signal in intfDesc) {
            var width = intfDesc[signal];
            if (width == 0) {
                // Do nothing.
            } else if (excludeList.indexOf(signal) != -1) {
                // Do nothing.
            } else {
                // This is master -> slave direction, so an output for masters.
                objLibPortFunction('output', prefix+signal, Math.abs(width));
            }
        }
    };

    /************************************************************
     * Special function. 
     * Given an interface object, forces the same direction of all
     * signals within the interface, where the interface is 
     * used as a slave.
     *
     * @arg {string} prefix - the prefix to use for all port names.
     * @arg {object} intfDesc - the interface descriptor object
     *
     */
function forceSlavePortsFromInterface (prefix, intfDesc, objLibPortFunction, excludeList) {
    
    if (typeof excludeList === 'undefined' || excludeList === null) {
        excludeList = [];
    }     
    for (var signal in intfDesc) {            var width = intfDesc[signal];
            if (width == 0) {
                // Do nothing.
            } else if (excludeList.indexOf(signal) != -1) {
                // Do nothing.
            } else {
                // This is master -> slave direction, so an input for slaves.
                objLibPortFunction('input', prefix+signal, Math.abs(width));
            }
        }
    };

    /************************************************************
     * Given an interface object, defines all the input and 
     * output ports for the interface, where the interface is 
     * used as a slave.
     *
     * @arg {string} prefix - the prefix to use for all port names.
     * @arg {object} intfDesc - the interface descriptor object
     *
     */
function defineSlavePortsFromInterface (prefix, intfDesc, objLibPortFunction, excludeList) {
    
    if (typeof excludeList === 'undefined' || excludeList === null) {
        excludeList = [];
    }     
    for (var signal in intfDesc) {            var width = intfDesc[signal];
            if (width == 0) {
                // Do nothing.
            } else if (excludeList.indexOf(signal) != -1) {
                // Do nothing.
            } else if (width > 0) {
                // This is master -> slave direction, so an input for slaves.
                objLibPortFunction('input', prefix+signal, width);
            } else  if (width < 0) {
                // This is master -> slave direction, so an output for slaves.
                objLibPortFunction('output', prefix+signal, (0-width));
            } else {
                //u.log("Utils Error:defineSlavePortsFromInterface ("+this.m.address+"): Interface signal "+signal+" width "+width);
            }
        }
    };

    function defineListPortsFromInterface (prefix, intfDesc, objLibPortFunction, excludeList) {
    
    if (typeof excludeList === 'undefined' || excludeList === null) {
        excludeList = [];
    }     
        
        for (var signal in intfDesc) {
            var width = intfDesc[signal];
            if (width == 0) {
                // Do nothing.
            } else if (excludeList.indexOf(signal) != -1) {
                // Do nothing.
            } else {
                objLibPortFunction('', prefix+signal, 1);
            }
        }
    };

    /************************************************************
     * Given an interface object, defines all the internal 
     * signals for an interface.
     *
     * @arg {string} prefix - the prefix to use for all signal names.
     * @arg {object} intfDesc - the interface descriptor object
     *
     */
    function string_defineSignalsFromInterface (prefix, intfDesc) {

        var result = '';
        for (var signal in intfDesc) {
            var width = intfDesc[signal];
            if (width == 0) {
                // Do nothing.
            } else if (width > 0) {
                //u.signal(prefix+signal, width);
                result += 'wire [' + (width-1) + ':0] ' + prefix + signal + ';\n';
            } else  if (width < 0) {
                //u.signal(prefix+signal, (0-width));
                result += 'wire [' + ((0-width)-1) + ':0] ' + prefix + signal + ';\n';
            } else {
                //u.log("Utils Error:defineSignals: Interface signal "+signal+" has zero width.");
            }
        }
        return result;
    };

    /************************************************************
     * Given an interface object, makes all the wire-level 
     * connections to connect two points.
     *
     * @arg {string} masterPrefix - the prefix to use for the 
     *                              master side of the connection.
     * @arg {string} slavePrefix - the prefix to use for the 
     *                             slave side of the connection.
     * @arg {object} intfDesc - the interface descriptor object
     *
     * Note:
     *   - If a prefix is of the for "module.prefix_", the 
     *     connection will be two/from the ports of a submodule.
     *
     */
function string_addConnectionfromInterface (masterPrefix, slavePrefix, intfDesc) {

    var result = '';
    for (var signal in intfDesc) {
        var width = intfDesc[signal];
        var wm1 = Math.abs(width) - 1;
        if (width == 0) {                                         
            // Do nothing.
        } else if (width == -1) {
            result += 'assign ' + masterPrefix + signal + ' = ' + slavePrefix + signal + ';\n';
        } else if (width == 1) {
            result += 'assign ' + slavePrefix + signal + ' = ' + masterPrefix + signal + ';\n';
        } else if (width < -1) {
            result += 'assign ' + masterPrefix + signal + '[' + wm1 + ':0] = ' + slavePrefix + signal + ';\n';
        } else if (width > 1) {
            result += 'assign ' + slavePrefix + signal + '[' + wm1 + ':0] = ' + masterPrefix + signal + ';\n';
        }
    }
    return result;
}



function aiuOttMemoryParams(aiu) {
    var wMasterData = aiu.SfiInfo.wMasterData;
    var errorInfo = aiu.CmpInfo.OttDataErrorInfo.fnErrDetectCorrect;
    var nOttDataEntries = aiu.CmpInfo.nOttDataEntries;

    var dataWidth = wMasterData + 1 + wMasterData / 8;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ECC Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var blockWidths;
    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(errorInfo, dataWidth - 1, 1);
    } else {
        blockWidths = getEvenBlockWidths(errorInfo, dataWidth - 1, 1);
    }
    var eccIndexes = getEccIndexes(blockWidths, 0, errorInfo);
    memEccBlocks = eccIndexes.memEccBlocks;
    eccOnlyBlocks = eccIndexes.eccOnlyBlocks;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, blockWidths);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depths
    //
    var memDepth = nOttDataEntries * (Math.pow(2, wCachelineOffset) * 8 / wMasterData) / 2;
    return {
        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function bridgeOttMemoryParams(aiu) {
    var wMasterData = aiu.SfiInfo.wMasterData;
    var errorInfo = aiu.CmpInfo.OttDataErrorInfo.fnErrDetectCorrect;
    var nOttDataEntries = aiu.CmpInfo.nOttDataEntries;
    var memWidth;
    var dataWidth;
    var memEccBlocks = [];
    var eccOnlyBlocks = [];

    if (aiu.NativeInfo.useIoCache) {
        dataWidth = wMasterData + 1;
        var strobeWidth = wMasterData / 8;

        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // ECC Calculations
        //
        var datBlockWidths;
        var strobeBlockWidths;
        if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
            datBlockWidths  = getEvenBlockWidths(errorInfo, dataWidth - 1,  1);
            strobeBlockWidths = getEvenBlockWidths(errorInfo, strobeWidth,   0);
        } else {
            datBlockWidths = [dataWidth];
            strobeBlockWidths = [strobeWidth];
        }
        var datEccIndexes = getEccIndexes(datBlockWidths, 0, errorInfo);
        memEccBlocks = datEccIndexes.memEccBlocks;
        eccOnlyBlocks = datEccIndexes.eccOnlyBlocks;
        var strobeEccIndexes = getEccIndexes(
            strobeBlockWidths,
            dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, datBlockWidths),
            errorInfo
        );
        memEccBlocks = memEccBlocks.concat(strobeEccIndexes.memEccBlocks);
        eccOnlyBlocks = eccOnlyBlocks.concat(strobeEccIndexes.eccOnlyBlocks);

        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Width with Error Bits
        //
        memWidth = dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, datBlockWidths) +
            strobeWidth + getErrorEncodingWidth(errorInfo, strobeWidth, strobeBlockWidths);
    } else {
        dataWidth = wMasterData + 1 + wMasterData / 8;

        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // ECC Calculations
        //
        var blockWidths;
        if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
            blockWidths = getEvenBlockWidths(errorInfo, dataWidth - 1, 1);
        } else {
            blockWidths = [dataWidth];
        }
        var eccIndexes = getEccIndexes(blockWidths, 0, errorInfo);
        memEccBlocks = eccIndexes.memEccBlocks;
        eccOnlyBlocks = eccIndexes.eccOnlyBlocks;

        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Width with Error Bits
        //
        memWidth = dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, blockWidths);
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = nOttDataEntries * (Math.pow(2, wCachelineOffset) * 8 / wMasterData) / 2;

    return {
        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function bridgeIoCacheTagMemoryParams(params, aiu) {
    var errorInfo =  aiu.NativeInfo.IoCacheInfo.CacheInfo.IoTagErrorInfo.fnErrDetectCorrect;
    var nSetSelectBits = aiu.NativeInfo.IoCacheInfo.CacheInfo.SetSelectInfo.nRsrcIdxBits;
    var nPortSelectBits = aiu.AiuSelectInfo.nRsrcIdxBits;
    var wSecurity = params.wSecurityAttribute;
    var wSfiAddr = aiu.Derived.wSfiAddr;
    var nWays = aiu.NativeInfo.IoCacheInfo.CacheInfo.nWays;
    var nSets = aiu.NativeInfo.IoCacheInfo.CacheInfo.nSets;
    var nTagBanks = aiu.NativeInfo.IoCacheInfo.CacheInfo.nTagBanks;
    var repPolicy = aiu.NativeInfo.IoCacheInfo.CacheInfo.fnReplPolType;
    var nRPPorts = aiu.NativeInfo.IoCacheInfo.CacheInfo.nReplPolMemPorts;
    var nStateBits = 2;

    var dataWidth = wSfiAddr
        - nSetSelectBits
        - wCachelineOffset
        + wSecurity
        - nPortSelectBits
        + nStateBits
        // Only add when replacement policy is NRU
        + (((nWays > 1) && (repPolicy !== 'RANDOM') && (nRPPorts === 1)) ? 1 : 0);


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ECC Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];

    var blockWidths;
    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(errorInfo, dataWidth, 0);
    } else {
        blockWidths = [dataWidth];
    }
    var wayStart = 0;
    for (var way = 0; way < nWays; way++) {
        var eccIndexes = getEccIndexes(blockWidths, wayStart, errorInfo);
        memEccBlocks = memEccBlocks.concat(eccIndexes.memEccBlocks);
        eccOnlyBlocks = eccOnlyBlocks.concat(eccIndexes.eccOnlyBlocks);
        wayStart += dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, blockWidths);
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = (dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, blockWidths)) * nWays;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = nSets / nTagBanks;

    return {
        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function bridgeIoCacheRPMemoryParams(aiu) {
    var nWays = aiu.NativeInfo.IoCacheInfo.CacheInfo.nWays;
    var nSets = aiu.NativeInfo.IoCacheInfo.CacheInfo.nSets;
    var nTagBanks = aiu.NativeInfo.IoCacheInfo.CacheInfo.nTagBanks;

    var memWidth = nWays;
    var eccIndexes = getSingleBlockIndexes(memWidth);
    var eccOnlyBlocks = eccIndexes.eccOnlyBlocks;
    var memEccBlocks = eccIndexes.memEccBlocks;
    var memDepth = nSets / nTagBanks;

    return {
        widthWithoutEcc: memWidth,
        blockWidths: [memWidth],
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function bridgeIoCacheDataMemoryParams(aiu) {
    var wErrorStatusBit = 1;
    var wMasterData = aiu.SfiInfo.wMasterData;
    var errorInfo = aiu.NativeInfo.IoCacheInfo.CacheInfo.IoDataErrorInfo.fnErrDetectCorrect;
    var nSets = aiu.NativeInfo.IoCacheInfo.CacheInfo.nSets;
    var nWays = aiu.NativeInfo.IoCacheInfo.CacheInfo.nWays;
    var nBeats = Math.pow(2, wCachelineOffset) * 8 / wMasterData;
    //var nDataBeatsPerBank = aiu.NativeInfo.IoCacheInfo.CacheInfo.nDataBeatsPerBank;
    var nDataBeatsPerBank = 1;
    var nDataBanks = aiu.NativeInfo.IoCacheInfo.CacheInfo.nDataBanks;

    var dataWidth = (wMasterData * nDataBeatsPerBank) + wErrorStatusBit;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Ecc Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var blockWidths;
    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(errorInfo, wMasterData, 1);
    } else {
        blockWidths = [dataWidth];
    }
    var eccIndexes = getEccIndexes(blockWidths, 0, errorInfo);
    memEccBlocks = eccIndexes.memEccBlocks;
    eccOnlyBlocks = eccIndexes.eccOnlyBlocks;


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, blockWidths);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = (nSets * nWays * nBeats) / (nDataBanks * nDataBeatsPerBank);

    return {
        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function llcCacheTagMemoryParams(params, moreParams = {"sramAddressProtection" : 0} ) {

    if (moreParams.sramAddressProtection) { } else { moreParams.sramAddressProtection = 0 };

    var dataWidth = params.wSfiAddr
        - params.nSetSelectBits
        - params.wCacheLineOffset
        + params.wSecurity
        - params.nPortSelectBits
        + params.nStateBits
        // Only add when replacement policy is NRU
        + (((params.nWays > 1) && (params.repPolicy !== 'RANDOM') && (params.nRPPorts === 1)) ? 1 : 0);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = params.nSets / params.nTagBanks;

    var memDepthWidth = log2ceil(memDepth);
    var sramAddressProtectionWidth = moreParams.sramAddressProtection ? memDepthWidth : 0;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ECC Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];

    var blockWidths;
    if ((params.errorInfo === 'SECDED64BITS') || (params.errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(params.errorInfo, sramAddressProtectionWidth + dataWidth, 0);
    } else {
        blockWidths = [sramAddressProtectionWidth + dataWidth];
    }
    var wayStart = 0;
    for (var way = 0; way < params.nWays; way++) {
        var eccIndexes = getEccIndexes(blockWidths, wayStart, params.errorInfo, sramAddressProtectionWidth); //CONC-8236
        memEccBlocks = memEccBlocks.concat(eccIndexes.memEccBlocks);
        eccOnlyBlocks = eccOnlyBlocks.concat(eccIndexes.eccOnlyBlocks);
        wayStart += dataWidth + getErrorEncodingWidth(params.errorInfo, sramAddressProtectionWidth + dataWidth, blockWidths);
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = (dataWidth + getErrorEncodingWidth(params.errorInfo, sramAddressProtectionWidth + dataWidth, blockWidths)) * params.nWays;

    return {
        depthWidth: memDepthWidth,
        sramAddressProtectionWidth: sramAddressProtectionWidth,

        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function llcCacheRPMemoryParams(params) {
    var memWidth = params.nWays;
    var eccIndexes = getSingleBlockIndexes(memWidth);
    var eccOnlyBlocks = eccIndexes.eccOnlyBlocks;
    var memEccBlocks = eccIndexes.memEccBlocks;
    var memDepth = params.nSets / params.nTagBanks;

    return {
        widthWithoutEcc: memWidth,
        blockWidths: [memWidth],
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function llcCacheDataMemoryParams(params, moreParams = {"sramAddressProtection" : 0} ) {

    if (moreParams.sramAddressProtection) { } else { moreParams.sramAddressProtection = 0 };

    var nBeats    = Math.pow(2, params.wCacheLineOffset) * 8 / params.wMasterData;
    var dataWidth = (params.wMasterData * params.nDataBeatsPerBank) + params.wErrorStatusBit;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = (params.nSets * params.nWays * nBeats) / (params.nDataBanks * params.nDataBeatsPerBank);

    var memDepthWidth = log2ceil(memDepth);
    var sramAddressProtectionWidth = moreParams.sramAddressProtection ? memDepthWidth : 0;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Ecc Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var blockWidths;
    if ((params.errorInfo === 'SECDED64BITS') || (params.errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(params.errorInfo, sramAddressProtectionWidth + params.wMasterData, 1);
    } else {
        blockWidths = [sramAddressProtectionWidth + dataWidth];
    }
    var eccIndexes = getEccIndexes(blockWidths, 0, params.errorInfo, sramAddressProtectionWidth); //CONC-8236
    memEccBlocks = eccIndexes.memEccBlocks;
    eccOnlyBlocks = eccIndexes.eccOnlyBlocks;


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = dataWidth + getErrorEncodingWidth(params.errorInfo, sramAddressProtectionWidth + dataWidth, blockWidths);

    return {
        depthWidth: memDepthWidth,
        sramAddressProtectionWidth: sramAddressProtectionWidth,

        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function snoopFilterMemoryParams(params, filter, idx0) {
    var wSfiAddr = params.DceInfo.Derived.wSfiAddr;
    var nSetSelectBits = filter.StorageInfo.SetSelectInfo.nRsrcIdxBits;
    //var nPortSelectBits = params.DceInfo.DceSelectInfo.nRsrcIdxBits;
    var wSecurityAttribute = params.wSecurityAttribute;
    var nWays = filter.StorageInfo.nWays;
    var nSets = filter.StorageInfo.nSets;
    var errorInfo =  filter.StorageInfo.TagFilterErrorInfo.fnErrDetectCorrect;
    var nPrimaryDiagonalPortSelectBits = params.DceInfo.DceSelectInfo.PriSubDiagAddrBits.length;
    var nDces = params.DceInfo.nDces;
    var removedPortBits = nPrimaryDiagonalPortSelectBits - Math.ceil(Math.log2(Math.pow(2, nPrimaryDiagonalPortSelectBits) / nDces));

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Tag Width
    //
    var wTagBits = wSfiAddr
        - nSetSelectBits
        //- nPortSelectBits
        - removedPortBits
        - wCachelineOffset
        + wSecurityAttribute;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Data Width Calculations
    //
    var dataWidth;
    var coarseNumCacheAgents = 0;
    var numCacheAgents = 0;
    params.AgentAiuInfo.forEach(function (aiu) {
        if (aiu.CmpInfo.idSnoopFilterSlice === idx0) {
            numCacheAgents += 1;
            coarseNumCacheAgents = Math.max(coarseNumCacheAgents, (aiu.CmpInfo.idAgentGroup + 1));
        }
    });
    params.BridgeAiuInfo.forEach(function (aiu) {
        if (aiu.CmpInfo.idSnoopFilterSlice === idx0) {
            numCacheAgents += 1;
            coarseNumCacheAgents = Math.max(coarseNumCacheAgents, (aiu.CmpInfo.idAgentGroup + 1));
        }
    });

    if (filter.StorageInfo.fnTagFilterType === 'PRESENCEVECTOR') {
        dataWidth = wTagBits + coarseNumCacheAgents;
    } else {
        var wCacheIds;
        if (filter.StorageInfo.fnTagFilterType === 'EXPLICITOWNER') {
            wCacheIds = Math.ceil(Math.log2(numCacheAgents + 1));
        } else {
            wCacheIds = Math.ceil(Math.log2(numCacheAgents));
        }
        dataWidth = wTagBits + coarseNumCacheAgents + wCacheIds;
    }

    // New width is filter.StorageInfo.nSnoopFilterEccSplitFactor * dataWidth
    var newDataWidth = filter.StorageInfo.nSnoopFilterEccSplitFactor * dataWidth;

    // New nWays is nWays / filter.StorageInfo.nSnoopFilterEccSplitFactor
    var newNWays = nWays / filter.StorageInfo.nSnoopFilterEccSplitFactor;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ECC Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var wayStart = 0;
    for (var way = 0; way < newNWays; way++) {
        var eccIndexes = getEccIndexes([newDataWidth], wayStart, errorInfo);
        memEccBlocks = memEccBlocks.concat(eccIndexes.memEccBlocks);
        eccOnlyBlocks = eccOnlyBlocks.concat(eccIndexes.eccOnlyBlocks);
        wayStart += newDataWidth + getErrorEncodingWidth(errorInfo, newDataWidth);
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = (newDataWidth + getErrorEncodingWidth(errorInfo, newDataWidth)) * newNWays;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = nSets;

    return {
        widthWithoutEcc: dataWidth,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function dmiRttMemoryParams(dmi) {
    var wErrorStatusBit = 1;
    var wMasterData = dmi.SfiInfo.wMasterData;
    var nRttCtrlEntries = dmi.CmpInfo.nRttCtrlEntries;
    var nBeats = Math.pow(2, wCachelineOffset) * 8 / wMasterData;
    var errorInfo = dmi.CmpInfo.RttDataErrorInfo.fnErrDetectCorrect;

    var dataWidth = wMasterData + wErrorStatusBit;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ECC Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var blockWidths;
    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(errorInfo, wMasterData, 1);
    } else {
        blockWidths = [dataWidth];
    }
    var eccIndexes = getEccIndexes(blockWidths, 0, errorInfo)
    memEccBlocks = eccIndexes.memEccBlocks;
    eccOnlyBlocks = eccIndexes.eccOnlyBlocks;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, blockWidths);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = nRttCtrlEntries * nBeats;

    return {
        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
}
}

function dmiCMCTagMemoryParams(params, dmi) {
    var errorInfo =  dmi.CmcInfo.CacheInfo.CmcTagErrorInfo.fnErrDetectCorrect;
    var nSetSelectBits = dmi.CmcInfo.CacheInfo.SetSelectInfo.nRsrcIdxBits;
    //var nPortSelectBits = dmi.DmiSelectInfo.nRsrcIdxBits;
    var wSecurity = params.wSecurityAttribute;
    var wAxAddr = dmi.Derived.wAxAddr;
    var nWays = dmi.CmcInfo.CacheInfo.nWays;
    var nSets = dmi.CmcInfo.CacheInfo.nSets;
    var nTagBanks = dmi.CmcInfo.CacheInfo.nTagBanks;
    var nPrimaryDiagonalPortSelectBits = dmi.DmiSelectInfo.PriSubDiagAddrBits.length;
    var nDmis = dmi.nDmis;
    var removedPortBits = nPrimaryDiagonalPortSelectBits - Math.ceil(Math.log2(Math.pow(2, nPrimaryDiagonalPortSelectBits) / nDmis));
    var repPolicy = dmi.CmcInfo.CacheInfo.fnReplPolType;
    var nRPPorts = dmi.CmcInfo.CacheInfo.nReplPolMemPorts;
    var nStateBits = 2;

    var dataWidth = wAxAddr
        - nSetSelectBits
        - wCachelineOffset
        + wSecurity
        //- nPortSelectBits
        - removedPortBits
        + nStateBits
        // Only add when replacement policy is NRU
        + (((nWays > 1) && (repPolicy !== 'RANDOM') && (nRPPorts === 1)) ? 1 : 0);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ECC Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var blockWidths;
    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(errorInfo, dataWidth, 0);
    } else {
        blockWidths = [dataWidth];
    }
    var wayStart = 0;
    for (var way = 0; way < nWays; way++) {
        var eccIndexes = getEccIndexes(blockWidths, wayStart, errorInfo);
        memEccBlocks = memEccBlocks.concat(eccIndexes.memEccBlocks);
        eccOnlyBlocks = eccOnlyBlocks.concat(eccIndexes.eccOnlyBlocks);
        wayStart += dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, blockWidths);
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = (dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, blockWidths)) * nWays;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = nSets / nTagBanks;

    return {
        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function dmiCMCRPMemoryParams(dmi) {
    var nWays = dmi.CmcInfo.CacheInfo.nWays;
    var nSets = dmi.CmcInfo.CacheInfo.nSets;
    var nTagBanks = dmi.CmcInfo.CacheInfo.nTagBanks;

    var memWidth = nWays;
    var eccIndexes = getSingleBlockIndexes(memWidth);
    var eccOnlyBlocks = eccIndexes.eccOnlyBlocks;
    var memEccBlocks = eccIndexes.memEccBlocks;
    var memDepth = nSets / nTagBanks;

    return {
        widthWithoutEcc: memWidth,
        blockWidths: [memWidth],
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function dmiCMCDataMemoryParams(dmi) {
    var wErrorStatusBit = 1;
    var wMasterData = dmi.SfiInfo.wMasterData;
    var errorInfo = dmi.CmcInfo.CacheInfo.CmcDataErrorInfo.fnErrDetectCorrect;
    var nSets = dmi.CmcInfo.CacheInfo.nSets;
    var nWays = dmi.CmcInfo.CacheInfo.nWays;
    var nBeats = Math.pow(2, wCachelineOffset) * 8 / wMasterData;
    //var nDataBeatsPerBank = dmi.CmcInfo.CacheInfo.nDataBeatsPerBank;
    var nDataBeatsPerBank = 1;
    var nDataBanks = dmi.CmcInfo.CacheInfo.nDataBanks;

    var dataWidth = (wMasterData * nDataBeatsPerBank) + wErrorStatusBit;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ECC Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var blockWidths;
    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(errorInfo, wMasterData, 1);
    } else {
        blockWidths = [dataWidth];
    }
    var eccIndexes = getEccIndexes(blockWidths, 0, errorInfo);
    memEccBlocks = eccIndexes.memEccBlocks;
    eccOnlyBlocks = eccIndexes.eccOnlyBlocks;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, blockWidths);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = (nSets * nWays * nBeats) / (nDataBanks * nDataBeatsPerBank);

    return {
        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

/************************************************************
 * Returns the number of bits required for error encoding.
 *
 * @arg {string} fnErrDetectCorrect - error encoding type.
 * @arg {Number} width - data width before encoding.
 * @return {Number} - The number of bits required for the error code.
 */
function getErrorEncodingWidth(fnErrDetectCorrect, width, blockWidths) {
    //u.log("EncodingWidth ... "+fnErrDetectCorrect+", "+width);
    var errWidth = 0;
    var resolution;

    if (fnErrDetectCorrect === 'PARITYENTRY') {
        errWidth = 1;
    } else if (fnErrDetectCorrect === 'PARITY16BITS') {
        errWidth = Math.ceil(width / 16);
    } else if (fnErrDetectCorrect === 'PARITY8BITS') {
        errWidth = Math.ceil(width / 8);
    } else if (fnErrDetectCorrect === 'SECDED') {
        if (width === 1) {
            errWidth = 3;
        } else if (width === 2) {
            errWidth = 4;
        } else {
            errWidth = Math.ceil(Math.log2(width + Math.ceil(Math.log2(width)) + 1)) + 1;
        }
        if (width <= 2) {
            throw new Error('SECDED Entry is not supported if data width <= 2.: ');
        }
    } else if (fnErrDetectCorrect === 'SECDED64BITS') {
        resolution = 64;
    } else if (fnErrDetectCorrect === 'SECDED128BITS') {
        resolution = 128;
    }

    var numInst;
    var wInstData;
    var inst;
    if (fnErrDetectCorrect === 'SECDED64BITS' ||
        fnErrDetectCorrect === 'SECDED128BITS') {
        if (blockWidths) {
            numInst = blockWidths.length;
            for (inst = 0; inst < numInst; inst++) {
                wInstData = blockWidths[inst];
                if (wInstData === 1) {
                    errWidth += 3;
                } else if (wInstData === 2) {
                    errWidth += 4;
                } else {
                    errWidth += Math.ceil(Math.log2(wInstData + Math.ceil(Math.log2(wInstData)) + 1)) + 1;
                }
            }
        } else {
            numInst = Math.ceil(width / resolution);
            for (inst = 0; inst < numInst; inst++) {
                if ((resolution * (inst + 1)) > width) {
                    wInstData = width % resolution;
                } else {
                    wInstData = resolution;
                }
                if (wInstData === 1) {
                    errWidth += 3;
                } else if (wInstData === 2) {
                    errWidth += 4;
                } else {
                    errWidth += Math.ceil(Math.log2(wInstData + Math.ceil(Math.log2(wInstData)) + 1)) + 1;
                }
            }
        }
    }

    return errWidth;
}

/************************************************************
 * Returns a vector of block widths that are as close as possible
 *
 * @arg {string} fnErrDetectCorrect - error encoding type.
 * @arg {Number} width - data width before encoding.
 * @arg {Number} extraBits - extra number of bits to be added to the first element
 * @return [{Number1},{Number2}...] - The vector of block widths.
 */
function getEvenBlockWidths(fnErrDetectCorrect, width, extraBits) {
    var idealNumBlock;
    if (fnErrDetectCorrect === 'SECDED64BITS') {
        idealNumBlock = Math.ceil(width / 64);
    } else if (fnErrDetectCorrect === 'SECDED128BITS') {
        idealNumBlock = Math.ceil(width / 128);
    } else {
        idealNumBlock = 1;
    }

    var evenBlockWidths = [];
    var tempWidth = width;

    for (var i = 0; i < idealNumBlock; i++) {

        if (fnErrDetectCorrect === 'SECDED64BITS') {
            if (i === 0) {
                if (tempWidth < 64) {
                    evenBlockWidths[i] = tempWidth + extraBits;
                } else {
                    evenBlockWidths[i] = 64 + extraBits;
                }
            } else {
                if (tempWidth < 64) {
                    evenBlockWidths[i] = tempWidth;
                } else {
                    evenBlockWidths[i] = 64;
                }
            }
            tempWidth = tempWidth - 64;
        } else if (fnErrDetectCorrect === 'SECDED128BITS') {
            if (i === 0) {
                if (tempWidth < 128) {
                    evenBlockWidths[i] = tempWidth + extraBits;
                } else {
                    evenBlockWidths[i] = 128 + extraBits;
                }
            } else {
                if (tempWidth < 128) {
                    evenBlockWidths[i] = tempWidth;
                } else {
                    evenBlockWidths[i] = 128;
                }
            }
            tempWidth = tempWidth - 128;
        } else {
            if (i === 0) {
                evenBlockWidths[i] = tempWidth + extraBits;
            } else {
                evenBlockWidths[i] = tempWidth;
            }
            tempWidth = 0;
        }

    }

    return evenBlockWidths;
}

//------------------------------------------------------------
// getEccIndexes()
// takes an array of block widths and returns an array of
// arrays that contain the data bits for each ecc logical
// block as it would appear in memory.
//------------------------------------------------------------
function getEccIndexes(blockWidths, startIndex, errorInfo, sramAddressProtectionWidth = 0) { //CONC-8236
    var index;
    if (startIndex) {
        index = startIndex;
    } else {
        index = 0;
    }
    var blockIndex = [];
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var block;
    var bit;

    // create array
    for (block = 0; block < blockWidths.length; block++) {
        memEccBlocks[block] = [];
        eccOnlyBlocks[block] = [];
        blockIndex[block] = 0;
    }

    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS') || (errorInfo === 'SECDED')) {
        // parity bit
        for (block = 0; block < blockWidths.length; block++) {
            eccOnlyBlocks[block][blockIndex[block]] = index;
            memEccBlocks[block][blockIndex[block]++] = index++;
        }

        // error bits
        for (block = 0; block < blockWidths.length; block++) {
            for (bit = 0; bit < getErrorEncodingWidth('SECDED', blockWidths[block]) - 1; bit++) {
                eccOnlyBlocks[block][blockIndex[block]] = index;
                memEccBlocks[block][blockIndex[block]++] = index++;
            }
        }
    } else {
        // parity bits
        for (block = 0; block < blockWidths.length; block++) {
            for (bit = 0; bit < getErrorEncodingWidth(errorInfo, blockWidths[block]) - 1; bit++) {
                eccOnlyBlocks[block][blockIndex[block]] = index;
                memEccBlocks[block][blockIndex[block]++] = index++;
            }
        }
    }

    // data bits
    for (block = 0; block < blockWidths.length; block++) {
        for (bit = 0; bit < blockWidths[block] - sramAddressProtectionWidth; bit++) { //CONC-8236
            memEccBlocks[block][blockIndex[block]++] = index++;
        }
    }

    return {
        memEccBlocks: memEccBlocks,
        eccOnlyBlocks: eccOnlyBlocks
    }
}


function getSingleBlockIndexes(width) {
    var memEccBlocks = [];
    memEccBlocks[0] = [];
    for (var bit = 0; bit < width; bit++) {
        memEccBlocks[0][bit] = bit;
    }
    var eccOnlyBlocks = [];
    eccOnlyBlocks[0] = [];
    return {
        memEccBlocks: memEccBlocks,
        eccOnlyBlocks: eccOnlyBlocks
    }
}

function getMemoryControlSignals(memoryType, memoryParams, ports, bitEnable) {
    var result;
    if (ports === 'sp') {
        result = {
            int_data_in: memoryParams.width,
            int_address: Math.max(1, Math.ceil(Math.log2(memoryParams.depth))),
            int_chip_en: 1,
            int_write_en: 1,
            int_data_out: -1 * memoryParams.width
        }

        if (bitEnable) {
            result.int_write_en_mask = memoryParams.width;
        }
    } else if (ports === 'tp') {
        result = {
            int_data_in: memoryParams.width,
            int_address_write: Math.max(1, Math.ceil(Math.log2(memoryParams.depth))),
            int_address_read: Math.max(1, Math.ceil(Math.log2(memoryParams.depth))),
            int_chip_en_write: 1,
            int_chip_en_read: 1,
            int_data_out: -1 * memoryParams.width
        }
        if (bitEnable) {
            result.int_write_en_mask = memoryParams.width;
        }
    }
    return result;
}

function createMemoryDataStructure(memoryStructure, memoryCalculatedParams, memoryPorts, bitEnable, modulePrefix, identifier, moduleIndex) {
    var dataStructure = {};
    // Create default prefix
    var defaultPrefix = modulePrefix + identifier;
    if (memoryStructure) {
        // Add control signals and their widths to the data structure
        var memoryControlSignals = getMemoryControlSignals(
            memoryStructure.MemType,
            memoryCalculatedParams,
            memoryPorts, // 'tp',
            bitEnable // moduleParams.NativeInfo.useIoCache //bitEnable
        );

        dataStructure.controlSignals = memoryControlSignals;
        // Memory Calculations
        dataStructure.widthWithoutEcc = memoryCalculatedParams.widthWithoutEcc;
        dataStructure.width = memoryCalculatedParams.width;
        dataStructure.depth = memoryCalculatedParams.depth;
        dataStructure.blockWidths = memoryCalculatedParams.blockWidths;
        // Add test signals
        if ((!memoryStructure.rtlPrefixString) || memoryStructure.MemType === 'NONE') {
            // set name to default name
            // If the memory type is none, set the rtlStringPrefix so a default value
            // this is because the created memory uses this default name for all
            // memories accross ports
            dataStructure.rtlPrefixString = defaultPrefix;
            dataStructure.memoryType = memoryStructure.MemType;
            // if rtlPrefixString is 0 or memoryType is none, delete signals
            dataStructure.nSignals = 0;
            dataStructure.signals = {};
        } else {
            // set name to default name
            dataStructure.rtlPrefixString = memoryStructure.rtlPrefixString;
            dataStructure.modulePrefix = modulePrefix + moduleIndex;
            dataStructure.memoryType = memoryStructure.MemType;

            var signals = {};
            dataStructure.nSignals = memoryStructure.Signals.length;
            for (var i = 0; i < dataStructure.nSignals; i++) {
                if (memoryStructure.Signals[i].Direction === 'IN') {
                    signals[memoryStructure.Signals[i].Name] = 0 - memoryStructure.Signals[i].Width;
                } else {
                    signals[memoryStructure.Signals[i].Name] = memoryStructure.Signals[i].Width;
                }
            }
            dataStructure.signals = signals;
        }
    } else {
        throw 'createMemoryDataStructure: memoryStructure is not valid; default prefix is ' + defaultPrefix;
    }
    return dataStructure;
}

function testSymbolIndex(ecc_width,index) {
    var bit_pos = ecc_width-1;
    var base;
    var local_index = index;
    var bit_set_even = new Boolean(true);
    var only_one_1 = new Boolean;
    var bits_set = new Array(ecc_width-2);
    var number_ones = 0;
    for (bit_pos = ecc_width-1; bit_pos >= 0; bit_pos--) {
        bits_set[bit_pos] = false;
        base = Math.pow(2,bit_pos);
        if (local_index >= base) {
            local_index = local_index - base;
            bit_set_even = !bit_set_even;
            bits_set[bit_pos] = true;
            number_ones++;
        }
    }
    if (number_ones == 1) {
        only_one_1 = true;
    } else {
        only_one_1 = false;
    }
    return {only_one_1:only_one_1,bit_set_even:bit_set_even,bits_set:bits_set}
}

function getEccWidth(data_width) {
    var ecc_width = 3;
    while ((Math.pow(2,(ecc_width-1))-data_width-ecc_width) < 0) {
        ecc_width = ecc_width + 1;
    }
    return ecc_width;
}

function ParamDefaultGet(u, name, type, def, min, max) {
    u.paramDefault(name, type, def, min, max);
    var value = u.getParam(name);
    return value;
}

function concMsgGen(obj, name, body, hParams, bParams, mParams, dir) {
    var msgBody = new obj.userLib[body];
    var msgHdr  = new obj.userLib['ConcMsgHdr'];
    var hdrSignals = {};
    var dpOrder = [];
    var dpSignal = [];
    var bodySignals = {};
    var signals = {};
    var bodyOrder = [];
    var msgArray = msgBody.getPacketArray(bParams);
    if(dir === 'rx') {
        hdrSignals = msgHdr.exclude('steering', 'priority', 't_tier', 'ql');
    } else if(dir === 'tx') {
    } else {
        throw Error('Direction must be "tx" or "rx".');
    };

    hdrSignals = msgHdr.getPacketObj(hParams);
    bodySignals= msgBody.getPacketObj(bParams);

    for (var i = 0 ; i < msgArray.length; i++) {
        if (msgArray[i]['width'] != 0) {
            if (msgArray[i]['payload'] == 1) {
                dpOrder.push(msgArray[i]['name'])
            } else {
                bodyOrder.push(msgArray[i]['name'])
            };            
        };
    };

    if(mParams['dpPresent'] == 1) {
        signals['last'] = 1;
    };
    var msgName = name;
    var muxParams = mParams;
    for(var key in bodySignals) signals[key] = bodySignals[key];
    for(var key in hdrSignals)  signals[key] = hdrSignals[key];
    signals['valid'] = 1;
    signals['ready'] =-1;
    return {name: msgName, params: muxParams, order: bodyOrder, dpOrder: dpOrder, signals: signals};
}

function smiPortGen(obj, pParams, sParams, dir) {
    var smiIntf = new obj.userLib['InterfaceSMI'];
    var name = pParams['name'];
    var dpSignals = {};
    var ndpSignals = {};
    var signalBundle ={};
    if(sParams['nSmiDPvc'] == 0) {
        pParams['params']['dpPresent'] = 0;
        pParams['params']['wData'] = 0;
    } else {
        pParams['params']['dpPresent'] = 1;
        pParams['params']['wData'] = sParams['wSmiDPdata'];
    };

    signalBundle = smiIntf.getSignalsBundle(sParams);
    for(var signal in signalBundle['dp_']) {
        dpSignals['dp_'+signal] = signalBundle['dp_'][signal];
    };
    for (var signal in signalBundle['ndp_']) {
        ndpSignals['ndp_'+signal] = signalBundle['ndp_'][signal];
    };
    return {name: name, params: pParams['params'], signals: ndpSignals, dpSignals: dpSignals}
}

function regNameIfNoHit(names,request_name) {
    var answer = true;
    var i = 0;
    while ((i < names.length) && answer) {
        if (names[i] === request_name) {
            answer = false;
        }
        i++;
    }
    if (answer === true) {
        names.push(request_name);
    }
    return answer;
}

function getUniqName(names,request_name) {
    var answer = '';
    var suffix = '';
    var count = 0;
    answer = request_name;
    while (!regNameIfNoHit(names,answer)) {
        suffix = count+'_';
        answer = request_name+suffix;
        count++;
    }
    return answer;
}

// Function to create a factory object that
// 1. Generates unique names (using get)
// 2. Validates and stores a requested name (using set) if unique
function createUniqNameFactory() {
	const names	= [];			// This is a private array that stores names filled up by regNameIfNoHit()

	return {
		set: request_name => regNameIfNoHit(names, request_name),	// set is now a function that takes a single param: request_name
		get: request_name => getUniqName(names, request_name)		// get is now a function that takes a single param: request_name
	};
}

function compareInterfaces(interface1, interface2) {
    var i = 0;
    var mismatch = 0;

    var signals1 = Object.keys(interface1.signals);
    signals1.sort();
    var signals2 = Object.keys(interface2.signals);
    signals2.sort();

    if (signals1.length === signals2.length) {
        for (i = 0; i < signals1.length; i++) {
            if (signals1[i] === signals2[i]) {
                if (interface1.signals[signals1[i]] !== interface2.signals[signals1[i]]) {
                    mismatch = 1;
                }
            } else {
                mismatch = 1;
            }
        }
    } else {
        mismatch = 1;
    }
    return mismatch
}

function getAsyncFifoWtCtlInterface(depth,async,exposeValids,addState,exposeNextValids) {
    var answer = {};
    var i = 0;
    var prot_signals = {};
    var prot_name = "";
    var prot_keys = [];

    answer['in_valid'] = -1;
    answer['in_reset'] = -1;
    answer['in_ready'] = 1;
    answer['write_sel'] = depth;
    if (async) {
        answer['write_ptr'] =  log2ceil(depth)+1;
        answer['read_ptr']  = -(log2ceil(depth)+1);
    } else {
        answer['write_ptr'] =  depth+1;
        answer['read_ptr']  = -(depth+1);
    }
    if (exposeValids === 'yes') {
        answer['valids'] = depth;
    }
    if (exposeNextValids === 'yes') {
        answer['next_valids'] = depth;
    }
    if (addState > 0) {
        answer['in_state'] = -addState;
        answer['out_state'] = addState;
    }
    return answer;
}

function getAsyncInterface(width,depth,async) {
    var answer = {};

    answer['read_sel'] = -depth;
    answer['data']     = width;
    if (async) {
        answer['write_ptr'] =  log2ceil(depth)+1;
        answer['read_ptr']  = -(log2ceil(depth)+1);
    } else {
        answer['write_ptr'] =  depth+1;
        answer['read_ptr']  = -(depth+1);
    } 
   return answer;
}

function getAsyncCrInterface(maxTime,minPkts) {
    var answer = {};

    answer['credit'] = 1;
    answer['credit_rtrn'] = -1;
    if ((maxTime > 0) && (minPkts > 1)) {
        answer['credit_cnt'] =  1;
    }
    return answer;
}

function getAsyncFifoRdCtlInterface(depth,async,addState) {
    var answer = {};
    var i = 0;
    var prot_signals = {};
    var prot_name = "";
    var prot_keys = [];

    answer['out_valid'] = 1;
    answer['out_reset'] = -1;
    answer['out_ready'] = -1;
    answer['read_sel'] = depth;
    if (async) {
        answer['write_ptr'] = -(log2ceil(depth)+1);
        answer['read_ptr']  =  log2ceil(depth)+1;
    } else {
        answer['write_ptr'] = -(depth+1);
        answer['read_ptr']  =  depth+1;
    }
    if (addState > 0) {
        answer['in_state'] = -addState;
        answer['out_state'] = addState;
    }
    return answer;
}

function getAsyncFifoRegDpInterface(width,depth) {
    var answer = {};

    answer['write_sel'] = -depth;
    answer['read_sel'] = -depth;
    answer['in_data'] = -width;
    answer['out_data'] = width;
    return answer;
}


function ccpRpMemoryParams(dmi) {
    var nWays     = dmi.ccpParams.nWays;
    var nSets     = dmi.ccpParams.nSets;
    var nTagBanks = dmi.ccpParams.nTagBanks;

    var memWidth = nWays;
    var eccIndexes = getSingleBlockIndexes(memWidth);
    var eccOnlyBlocks = eccIndexes.eccOnlyBlocks;
    var memEccBlocks = eccIndexes.memEccBlocks;
    var memDepth = nSets / nTagBanks;

    return {
        widthWithoutEcc: memWidth,
        blockWidths: [memWidth],
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}


function ccpTagMemoryParams(dmi, moreParams = {"sramAddressProtection" : 0}) {
    var errorInfo =  dmi.ccpParams.TagErrInfo;
    var nSetSelectBits = dmi.ccpParams.PriSubDiagAddrBits.length;
    //var nPortSelectBits = dmi.DmiSelectInfo.nRsrcIdxBits;
    var wSecurity = dmi.ccpParams.wSecurity;
    var wAxAddr = dmi.ccpParams.wAddr;
    var nWays = dmi.ccpParams.nWays;
    var nSets = dmi.ccpParams.nSets;
    var nTagBanks = dmi.ccpParams.nTagBanks;
    var nPrimaryDiagonalPortSelectBits = dmi.ccpParams.PriSubDiagAddrBits.length;
    var repPolicy = dmi.ccpParams.RepPolicy;
    var nRPPorts = dmi.ccpParams.nRPPorts;
    var nStateBits = dmi.ccpParams.wStateBits;

    if (moreParams.sramAddressProtection) { } else { moreParams.sramAddressProtection = 0 };

    var dataWidth = wAxAddr
        - nSetSelectBits
        - wCachelineOffset
        + wSecurity
        + nStateBits
        // Only add when replacement policy is NRU
        + (((nWays > 1) && (repPolicy !== 'RANDOM') && (nRPPorts === 1)) ? 1 : 0);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = nSets / nTagBanks;

    var memDepthWidth = log2ceil(memDepth);
    var sramAddressProtectionWidth = moreParams.sramAddressProtection ? memDepthWidth : 0;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ECC Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var blockWidths;
    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(errorInfo, sramAddressProtectionWidth + dataWidth, 0);
    } else {
        blockWidths = [sramAddressProtectionWidth + dataWidth];
    }
    var wayStart = 0;
    for (var way = 0; way < nWays; way++) {
        var eccIndexes = getEccIndexes(blockWidths, wayStart, errorInfo, sramAddressProtectionWidth); //CONC-8236
        memEccBlocks = memEccBlocks.concat(eccIndexes.memEccBlocks);
        eccOnlyBlocks = eccOnlyBlocks.concat(eccIndexes.eccOnlyBlocks);
        wayStart += dataWidth + getErrorEncodingWidth(errorInfo, sramAddressProtectionWidth + dataWidth, blockWidths);
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = (dataWidth + getErrorEncodingWidth(errorInfo, sramAddressProtectionWidth + dataWidth, blockWidths)) * nWays;

    return {
        depthWidth: memDepthWidth,
        sramAddressProtectionWidth: sramAddressProtectionWidth,

        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function ccpDataMemoryParams(dmi, moreParams = {"sramAddressProtection" : 0}) {
    var wErrorStatusBit = 1;
    var wMasterData = dmi.ccpParams.wData;
    var errorInfo = dmi.ccpParams.DataErrInfo;;
    var nSets = dmi.ccpParams.nSets;
    var nWays = dmi.ccpParams.nWays;
    var nBeats = Math.pow(2, wCachelineOffset) * 8 / wMasterData;
    //var nDataBeatsPerBank = dmi.CmcInfo.CacheInfo.nDataBeatsPerBank;
    var nDataBeatsPerBank = dmi.ccpParams.nBeatsPerBank;
    var nDataBanks = dmi.ccpParams.nDataBanks;
    var dataWidth = (wMasterData * nDataBeatsPerBank) + wErrorStatusBit;

    if (moreParams.sramAddressProtection) { } else { moreParams.sramAddressProtection = 0 };

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = (nSets * nWays * nBeats) / (nDataBanks * nDataBeatsPerBank);

    var memDepthWidth = log2ceil(memDepth);
    var sramAddressProtectionWidth = moreParams.sramAddressProtection ? memDepthWidth : 0;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ECC Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var blockWidths;
    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(errorInfo, sramAddressProtectionWidth + wMasterData * nDataBeatsPerBank, 1);
    } else {
        blockWidths = [sramAddressProtectionWidth + dataWidth];
    }
    var eccIndexes = getEccIndexes(blockWidths, 0, errorInfo, sramAddressProtectionWidth); //CONC-8236
    memEccBlocks = eccIndexes.memEccBlocks;
    eccOnlyBlocks = eccIndexes.eccOnlyBlocks;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = dataWidth + getErrorEncodingWidth(errorInfo, sramAddressProtectionWidth + dataWidth, blockWidths);

    return {
        depthWidth: memDepthWidth,
        sramAddressProtectionWidth: sramAddressProtectionWidth,

        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function IOAIUccpDataMemoryParams(dmi, moreParams = {"sramAddressProtection" : 0}) {
    var wErrorStatusBit = dmi.ccpParams.wPoison;
    var wMasterData = dmi.ccpParams.wData;
    var errorInfo = dmi.ccpParams.DataErrInfo;;
    var nSets = dmi.ccpParams.nSets;
    var nWays = dmi.ccpParams.nWays;
    var nBeats = Math.pow(2, wCachelineOffset) * 8 / wMasterData;
    //var nDataBeatsPerBank = dmi.CmcInfo.CacheInfo.nDataBeatsPerBank;
    var nDataBeatsPerBank = dmi.ccpParams.nBeatsPerBank;
    var nDataBanks = dmi.ccpParams.nDataBanks;
    var dataWidth = (wMasterData * nDataBeatsPerBank) + wErrorStatusBit;

    if (moreParams.sramAddressProtection) { } else { moreParams.sramAddressProtection = 0 };

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = (nSets * nWays * nBeats) / (nDataBanks * nDataBeatsPerBank);

    var memDepthWidth = log2ceil(memDepth);
    var sramAddressProtectionWidth = moreParams.sramAddressProtection ? memDepthWidth : 0;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ECC Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var blockWidths;
    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(errorInfo, sramAddressProtectionWidth + wMasterData * nDataBeatsPerBank, 1);
    } else {
        blockWidths = [sramAddressProtectionWidth + dataWidth];
    }
    var eccIndexes = getEccIndexes(blockWidths, 0, errorInfo, sramAddressProtectionWidth); //CONC-8236
    memEccBlocks = eccIndexes.memEccBlocks;
    eccOnlyBlocks = eccIndexes.eccOnlyBlocks;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = dataWidth + getErrorEncodingWidth(errorInfo, sramAddressProtectionWidth + dataWidth, blockWidths);

    return {
        depthWidth: memDepthWidth,
        sramAddressProtectionWidth: sramAddressProtectionWidth,

        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

function dataBufferMemoryParams(width, nSets, nBeats, nBanks, errorInfo, moreParams = {"sramAddressProtection" : 0}) {

    if (moreParams.sramAddressProtection) { } else { moreParams.sramAddressProtection = 0 };

    var dataWidth = width;

    var memDepth = nBeats * nSets / nBanks;

    var memDepthWidth = log2ceil(memDepth);
    var sramAddressProtectionWidth = moreParams.sramAddressProtection ? memDepthWidth : 0;

    // ECC Calculations

    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var blockWidths = [sramAddressProtectionWidth + dataWidth];
    var eccIndexes = getEccIndexes(blockWidths, 0, errorInfo, sramAddressProtectionWidth); //CONC-8236

    memEccBlocks = eccIndexes.memEccBlocks;
    eccOnlyBlocks = eccIndexes.eccOnlyBlocks;

    var memWidth = dataWidth + getErrorEncodingWidth(errorInfo, sramAddressProtectionWidth + dataWidth, blockWidths);

    return {
        depthWidth: memDepthWidth,
        sramAddressProtectionWidth: sramAddressProtectionWidth,

        widthWithoutEcc: dataWidth,
        blockWidths: blockWidths,
        width: memWidth,
        depth: memDepth,
        eccOnlyBlocks: eccOnlyBlocks,
        eccBlocks: memEccBlocks
    }
}

// Constructor function that creates the CSR REG data-structure 
function CreateRegCSR(name,addressOffset,fields,description="",addRsvd=false,csrDescription="", regOpEn=false, tzMode="secure") {

    this.name                       = name;
    this.addressOffset              = addressOffset;
	this.description				= description;
	this.csrDescription				= csrDescription;
	this.regOpEn					= regOpEn;
	this.tzMode						= tzMode;

	const fieldsCopy				= []
    fields.forEach( function(fld) {
        fieldsCopy.push( new CreateFieldCSR(fld.name,fld.bitOffset,fld.bitWidth,fld.access,fld.hardware,fld.reset,fld.linkOp,fld.opOrder,fld.scope,fld.description) );
    });

	// Sort fields in ascending order of bitsOffsets
    fieldsCopy.sort(function(a,b) {
        return a.bitOffset - b.bitOffset;
    });

	if(!addRsvd) {
		this.fields					= fieldsCopy;
	} else {
		let nextOffset				= 0;
		let id						= 0;
		this.fields                 = [];
		fieldsCopy.forEach( function(fld) {
			if(nextOffset !== fld.bitOffset) {
				this.fields.push( new CreateFieldCSR("Rsvd_Gen_"+id,nextOffset,fld.bitOffset-nextOffset,"RO","RO",0,"NULL","NULL","All","Reserved field "+id) );
				id						= id+1;
			}
			this.fields.push(fld);
			nextOffset					= fld.bitOffset+fld.bitWidth;
		},this);

		if(nextOffset < 32) {
			this.fields.push( new CreateFieldCSR("Rsvd_Gen_"+id,nextOffset,32-nextOffset,"RO","RO",0,"NULL","NULL","All","Reserved field "+id) );
		}
	}
}


// Constructor function that creates the CSR REG data-structure 
function CreateFieldCSR(name,bitOffset,bitWidth,access,hardware,reset,linkOp,opOrder,scope,description) {

    this.name                       = name;
    this.bitOffset                  = bitOffset;
    this.bitWidth                   = bitWidth;
    this.access                     = access;
    this.hardware                   = hardware;
    this.reset                      = reset;
    this.linkOp                     = linkOp;
    this.opOrder                    = opOrder;
    this.scope                      = scope;
    this.description                = description;
}


// Function to merge properties of two objects:
// Copies properties of b to a and returns a
function mergeObjects(a,b) {
    Object.keys(b).forEach( 
            function(key) {
                a[key]  = b[key];
            }
    )
    return a;
}


// Function to generate an object from an array
// of properties and an array of values
function keysAndValuesToObject(a,b) {
	if(b.length != a.length) {
		throw("Error: Lengths of passed arrays a and b are unequal. (sym_lib_utils.js keysAndValuesToObject())");
	}
	return a.reduce( (obj,v,i) => Object.assign(obj, {[v]:b[i]}), {} );
}


// Constructor function that creates the CSR-spaceBlock data-structure 
function CreateSpaceBlock(baseAddress,registers) {

    this.baseAddress				= baseAddress;
	this.registers					= [];
	registers.forEach( reg => {this.registers.push(reg);});
}


// Constructor function that creates the CSR data-structure 
function CreateCSR(name,addressWidth,width,spaceBlock) {

    this.name                       = name;
    this.addressWidth               = addressWidth;
    this.width                      = width;
    this.spaceBlock                 = spaceBlock;
}


// Constructor function that creates the CSR REG Object = CSR REG data-structure + methods 
function CreateRegCSRObj(register,width) {

    this.name                       = register.name;
    this.addressOffset              = register.addressOffset;
    this.fields                     = register.fields;
	this.regOpEn					= register.regOpEn;
	this.tzMode						= register.tzMode;
    this.width                      = width;


    // Calculate the sum of all field widths in the reg:
    this.sumOfFldWidths         = function() {
        var sum                 = 0;
        for(var fld of this.fields) {
            sum                 = sum + parseInt(fld.bitWidth);
        }
        return sum;
    }


    // Calculate the sum of all field widths excluding fields that are Read-Only 
    // i.e. when hardware and access fields are both "RO":
    this.numOfFlops         = function() {
        var sum                 = 0;
        for(var fld of this.fields) {
			var fHwAcc			= fld.hardware;
			var fSwAcc			= fld.access;
			var RO				= (fHwAcc == "RO") && (fSwAcc == "RO");
            sum                 = sum + ( RO ? 0 : parseInt(fld.bitWidth));
        }
        return sum;
    }


    // Function that parses the register specified in the CSR data-structure and returns
    // an array packed with all valid wire slices in MSB..LSB order with any reserverd or 
    // invalid fields removed:
    this.packRegBits            = function (wire) {
        var unpkdPos            = 0;
        var fldVctr             = [];
    
        // Sort all fields in reg based on property - bitOffset in ascending order:
        var numFields           = this.fields.length;
        this.fields.sort(function(a,b) {
            return a.bitOffset - b.bitOffset;
        });

        // Parse all fields in reg
        for(var f=0; f<numFields; f++) {
            //console.log("Parsing field ="+this.fields[f].name+", unpkdPos = "+unpkdPos+", bitOffset = "+this.fields[f].bitOffset+"\n");
            var fWidth          = parseInt(this.fields[f].bitWidth);
			var fHwAcc			= this.fields[f].hardware;
			var fSwAcc			= this.fields[f].access;
			var RO				= (fHwAcc == "RO") && (fSwAcc == "RO");
            if(fWidth && !RO) {
                unpkdPos        = this.fields[f].bitOffset;
				var wireSlice	= (fWidth==1) ? wire+"["+unpkdPos+"]" : wire+"["+(unpkdPos+fWidth-1)+":"+unpkdPos+"]";
                fldVctr.push(wireSlice);
            }
        }
        return fldVctr.reverse();
    }


    // Function that parses the register specified in the CSR data-structure and returns
    // an array of the input wire slices in MSB..LSB order, with the right number of
    // zeros for bits where no field is defined in the register 
    this.unpackRegBits          = function (wire) {
        var pkdPos              = 0;
        var unpkdPos            = 0;
        var fldVctr             = [];
    
        // Sort all fields in reg based on property - bitOffset in ascending order:
        this.fields.sort(function(a,b) {
            return a.bitOffset - b.bitOffset;
        });

        // Parse all fields in reg
        for(var fld of this.fields) {
            //console.log("Parsing field ="+fld.name+", unpkdPos = "+unpkdPos+", bitOffset = "+fld.bitOffset+"\n");
            var fWidth          = parseInt(fld.bitWidth);
			var fReset			= parseInt(fld.reset);
			var fHwAcc			= fld.hardware;
			var fSwAcc			= fld.access;
			var fName			= fld.name;
			var RO				= (fHwAcc == "RO") && (fSwAcc == "RO");
			var rsvd			= fName.startsWith("Rsvd");
			var nFlops			= this.numOfFlops();

            if(fWidth) {
				var wireSlice	= RO ? (this.name+"_"+fld.name+"_out") : VlogSignal(nFlops, wire).slice( pkdPos+fWidth-1, pkdPos ).toString();
				var zeroSlice	= (fld.bitOffset - unpkdPos).toString()+"'h0";

                if(unpkdPos == fld.bitOffset) {
                  fldVctr.push(wireSlice);
                } else if(unpkdPos < fld.bitOffset){
                  fldVctr.push(zeroSlice);
                  fldVctr.push(wireSlice);
                  unpkdPos        = fld.bitOffset;
                } else {
                    console.log("Error: Sort Error in function unpackRegBits() for REG = "+this.name+", unpkdPos = "+unpkdPos+", bitOffset = "+fld.bitOffset+"\n");
                    throw "ERROR - unpackRegBits()";
                    return ["Error"]
                }
                unpkdPos        = unpkdPos + fWidth;
                pkdPos          = RO ? pkdPos : pkdPos+fWidth;
            }
        }
        if(unpkdPos < this.width) {
            fldVctr.push((this.width - unpkdPos).toString()+"'h0");
        }
        return fldVctr.reverse();
    }


    // Function that parses the register specified and returns the upper and lower indices
    // corresponding to the packed format:
    this.getPackedFmtIndex      = function (index) {
        var pkdIndex            = -1;
        var pkdUI               = -1;
        var pkdLI               = -1;
        var unpkdUI             = -1;
        var unpkdLI             = -1;
    
        // Sort all fields in reg based on property - bitOffset in ascending order:
        var numFields           = this.fields.length;
        this.fields.sort(function(a,b) {
            return a.bitOffset - b.bitOffset;
        });

        // Parse all fields in reg
        for(var f=0; f<numFields; f++) {
            //console.log("Parsing field ="+this.fields[f].name+", unpkdPos = "+unpkdPos+", bitOffset = "+this.fields[f].bitOffset+"\n");
            var fWidth          = parseInt(this.fields[f].bitWidth);
			var fHwAcc			= this.fields[f].hardware;
			var fSwAcc			= this.fields[f].access;
			var RO				= (fHwAcc == "RO") && (fSwAcc == "RO");
            if(fWidth && !RO) {
                pkdLI           = pkdLI + 1;
                pkdUI           = pkdLI + fWidth - 1;
                unpkdLI         = this.fields[f].bitOffset;
                unpkdUI         = this.fields[f].bitOffset + fWidth - 1;
                if((unpkdUI >= index) && (index >= unpkdLI)) {
                    pkdIndex    = (index - unpkdLI) + pkdLI;
                    break;
                }
                pkdLI           = pkdUI;
            }
        }
        return pkdIndex;
    }
        

    // Function that parses the register specified in the CSR data-structure and returns
    // a Write-mask based-on which side is accessing - access = "sw" or "hw" 
    this.getRegWriteMask        = function (access) {
        var mask                = 0;
        var pkdPos              = 0;
    
        // Sort all fields in reg based on property - bitOffset in ascending order:
        var numFields           = this.fields.length;
        this.fields.sort(function(a,b) {
            return a.bitOffset - b.bitOffset;
        });

        // Parse all fields in reg
        // Avoid using bit manipulation operator such as << to avoid overflow beyond 2^32
        // This function would still overflow beyond 2^64 - 1
        for(var f=0; f<numFields; f++) {
            var fld             = this.fields[f];
            var fWidth          = parseInt(fld.bitWidth);
            if(fWidth) {
                if(access == "sw") {
                    //if(["WO","RW","W1C"].includes(fld.access)) {
                    if((fld.access!="RO") || (fld.hardware!="RO")) {
                        mask    = fld.access==="RO" ? mask : mask + ((Math.pow(2,fWidth)-1) * Math.pow(2,pkdPos));
						pkdPos  = pkdPos + fWidth;
                    }
                } else if(access == "hw") {
                    if(["WO","RW"].includes(fld.hardware)) {
                        mask    = mask + ((Math.pow(2,fWidth)-1) * Math.pow(2,pkdPos));
						pkdPos  = pkdPos + fWidth;
                    }
                } else if(access.toLowerCase() == "w1c") {
                    if(fld.access==="W1C") {
                        mask    = mask + ((Math.pow(2,fWidth)-1) * Math.pow(2,pkdPos));
						pkdPos  = pkdPos + fWidth;
                    } else if((fld.access!="RO") || (fld.hardware!="RO")) {
						pkdPos  = pkdPos + fWidth;
                    }
                }
            }
        }
        return mask;
    }


    // Function that parses the register specified in the CSR data-structure and returns
    // an array packed with all valid wire slices in MSB..LSB order with any reserverd or 
    // invalid fields removed:
    this.regFlds                = function (suffix) {
        var regFldsOut          = [];
    
        // Sort all fields in reg based on property - bitOffset in ascending order:
        var numFields           = this.fields.length;
        this.fields.sort(function(a,b) {
            return a.bitOffset - b.bitOffset;
        });

        // Parse all fields in reg
        for(var f=0; f<numFields; f++) {
            var fWidth          = parseInt(this.fields[f].bitWidth);
            if(fWidth) {
                regFldsOut.push(this.name+"_"+this.fields[f].name+suffix);
            }
        }
        return regFldsOut.reverse();
    }


    // Function that parses the register specified in the CSR data-structure and returns
    // an array packed with all valid wire slices in MSB..LSB order with any reserverd or 
    // invalid fields removed:
    this.regFldsHwIn            = function(suffix,maskNotPack) {
        var regFlds             = [];
    
        // Sort all fields in reg based on property - bitOffset in ascending order:
        var numFields           = this.fields.length;
        this.fields.sort(function(a,b) {
            return a.bitOffset - b.bitOffset;
        });

        // Parse all fields in reg
        for(var f=0; f<numFields; f++) {
            var fWidth          = parseInt(this.fields[f].bitWidth);
            if(fWidth > 0)  {
                if(this.fields[f].hardware in {"WO":0,"RW":0}) {
                    regFlds.push(this.name+"_"+this.fields[f].name+suffix);
                } else if (maskNotPack) {
                    regFlds.push(fWidth+"'h0");
                }
            }
        }
        return regFlds.reverse();
    }


	// Function to parse reset fields of the register and generate a
	// packed reset-value i.e. assuming flops are inferred only for
	// bits that are valid.
	this.getRstValPkd			= function(nonRO="NONRO") {
    
        // Avoid using bit manipulation operators such as << to avoid overflow beyond 2^32
        // This function would still overflow beyond 2^64 - 1
        // Use Math.pow(2,x) instead
    
        // Sort all fields in reg based on property - bitOffset in ascending order
        var numFields           = this.fields.length;
        this.fields.sort(function(a,b) {
            return a.bitOffset - b.bitOffset;
        });

        // Cumulatively add reset values shifted by their packed positions
        var pkdPos				= 0;
        var rstVal				= 0;
        for(var f=0; f<numFields; f++) {
            var fWidth          = parseInt(this.fields[f].bitWidth);
			var fReset			= parseInt(this.fields[f].reset);
			var fHwAcc			= this.fields[f].hardware;
			var fSwAcc			= this.fields[f].access;
			var RO				= (fHwAcc == "RO") && (fSwAcc == "RO");
			if(nonRO == "NONRO") {
				if(fWidth && !RO) {
					rstVal			+= parseInt(this.fields[f].reset) * Math.pow(2,pkdPos);
            	    pkdPos			+= fWidth;
            	}
			} else if(nonRO == "RO") { // RO only
				if(fWidth && RO) {
					rstVal			+= parseInt(this.fields[f].reset) * Math.pow(2,pkdPos);
            	    pkdPos			+= fWidth;
            	}
			} else {
				throw("Error: Invalid argument passed to getRstValPkd() method - nonRO="+nonRO);
			}
        }
        return rstVal;
	}


	// Function to parse reset fields of the register and generate an
	// unpacked reset-value.
	this.getRstValUnpkd			= function() {
		
        // Avoid using bit manipulation operators such as << to avoid overflow beyond 2^32
        // This function would still overflow beyond 2^64 - 1
        // Use Math.pow(2,x) instead
        
        // Get an array of reset values shifted by unpacked positions or bitOffsets
        var rstValues			= this.fields.map( function(fld) {
			return fld.bitWidth ? parseInt(fld.reset) * Math.pow(2,fld.bitOffset) : 0;
		});
	
		// Sum the above array
        var rstVal				= rstValues.reduce( function(acc,fld) {
			return acc + fld; 
		});

        return rstVal;
	}


	this.getHWPortName			= function (type) {
		return [this.name, type].join("_");
	}


}


// Constructor function that creates the CSR Objects 
function CreateCSRObj(CSR) {


    this.name                           = CSR.name;
    this.addressWidth                   = CSR.addressWidth;
    this.width                          = CSR.width;
    this.spaceBlock                     = [];
    for(var sb in CSR.spaceBlock) {
        this.spaceBlock[sb]             = {};
        this.spaceBlock[sb].baseAddress = CSR.spaceBlock[sb].baseAddress;
        this.spaceBlock[sb].registers   = [];
        for(var r in CSR.spaceBlock[sb].registers) {
            this.spaceBlock[sb].registers[r]    = new CreateRegCSRObj(CSR.spaceBlock[sb].registers[r],CSR.width);
        }
    }


    // Function to create and return CSR data-structure:
    this.getCSR                 = function () {
        var newSpaceBlock                      = [];
        for(var sb in this.spaceBlock) {
            newSpaceBlock[sb]                  = {};
            newSpaceBlock[sb].baseAddress      = this.spaceBlock[sb].baseAddress;
            newSpaceBlock[sb].registers        = [];
            for(var r in this.spaceBlock[sb].registers) {
                newSpaceBlock[sb].registers[r] = new CreateRegCSR(this.spaceBlock[sb].registers[r].name,this.spaceBlock[sb].registers[r].addressOffset,this.spaceBlock[sb].registers[r].fields);
            }
        }
        var CSR                 = new CreateCSR(this.name,this.addressWidth,this.width,newSpaceBlock);
        return CSR;
    }


	// Function to return port names of HW ports - ports that modules instantiating APB_CSR
	// can directly access (HW-side) to read or update register bits
	// Pattern: REG-Name+"_"+FIELD-Name+"_"+TYPE ("in","out","wr")
	this.getHWPortName			= function (regName,fieldName,type) {
		return fieldName==="" ? [regName, type].join("_") : [regName, fieldName, type].join("_");
	}


    // Function that parses the CSR data-structure and returns an object of fields and 
    // their widths, for only those fields that read-able from the HW-side.
    this.getRegFldsOut			= function () {

        const regFldsOut					= {};

		this.spaceBlock.forEach( function (sb) {
			sb.registers.forEach( function (reg) {
				reg.fields.forEach( function (field) {
					const fWidth			= parseInt(field.bitWidth);
					const fRsvd				= field.name.startsWith("Rsvd");
	
					if( fWidth && !fRsvd && ["RO","RW"].includes(field.hardware) ) {
						const key			= this.getHWPortName(reg.name, field.name, "out");
						regFldsOut[key]		= fWidth;
					}

				}.bind(this));
			}.bind(this));
		}.bind(this));

        return regFldsOut;
    }
    
    
    // Function that parses the CSR data-structure and returns an object of fields and 
    // their widths, for only those fields that are write-able from the HW-side.
    this.getRegFldsIn				= function () {

        const regFldsIn						= {};

		this.spaceBlock.forEach( function (sb) {
			sb.registers.forEach( function (reg) {
				reg.fields.forEach( function (field) {
					const fWidth			= parseInt(field.bitWidth);
					const RO				= (field.hardware == "RO") && (field.access == "RO") && !field.name.startsWith("Rsvd");

					// Include *_in signals for Read-only, WO, and RW fields
					if(fWidth && (["WO","RW"].includes(field.hardware) || RO)) {
						const key			= this.getHWPortName(reg.name, field.name, "in");
						regFldsIn[key]		= fWidth;
					}

					// Include *_wr signals for all WO and RO fields
					if(fWidth && ["WO","RW"].includes(field.hardware)) {
						const key			= this.getHWPortName(reg.name, field.name, "wr");
						regFldsIn[key]		= 1;
					}
				}.bind(this));

			}.bind(this));
		}.bind(this));


        return regFldsIn;
    }


	// Function that parses the CSR data-structure and returns an object of output ports and their
	// widths. This includes hardware-access ports, TrustZone ports, and Register-operation-enable ports.
	this.getHWPortsOut			= function (params=null) {
		
        const HWPortsOut					= {};

		this.spaceBlock.forEach( function (sb) {
			sb.registers.forEach( function (reg) {

				// Generate software-write ports per register	
				if(params && params.enSwWritePorts) {
					const key				= reg.getHWPortName("sw_wr");
					HWPortsOut[key]			= 1;
				}

				// Generate software-read ports per register	
				if(params && params.enSwReadPorts) {
					const key				= reg.getHWPortName("sw_rd");
					HWPortsOut[key]			= 1;
				}

				// Generate hardware-access "out" ports per register per field
				reg.fields.forEach( function (field) {
					const fWidth			= parseInt(field.bitWidth);
					const fRsvd				= field.name.startsWith("Rsvd");

					// Generate hardware-access ports per register per field	
					if( fWidth && !fRsvd && ["RO","RW"].includes(field.hardware) ) {
						const key			= this.getHWPortName(reg.name, field.name, "out");
						HWPortsOut[key]		= fWidth;
					}

					// Generate software-write data ports per register per field	
					if( fWidth && !fRsvd && params && params.enSwWritePorts ) {
						const key			= this.getHWPortName(reg.name, field.name, "sw_wdata");
						HWPortsOut[key]		= fWidth;
					}

				}.bind(this));
			}.bind(this));
		}.bind(this));

        return HWPortsOut;
	}
    

    // Function that parses the CSR data-structure and returns an object of input ports 
    // and their widths. This includes hardware-access ports, TrustZone ports, and 
    // Register-operation-enable ports.
    this.getHWPortsIn				= function (params=null) {

        const HWPortsIn						= {};

		this.spaceBlock.forEach( function (sb) {
			sb.registers.forEach( function (reg) {
				if(reg.regOpEn) {
					const secureWrite		= reg.getHWPortName("wr_en");
					const secureRead		= reg.getHWPortName("rd_en");
					HWPortsIn[secureWrite]	= 1;
					HWPortsIn[secureRead]	= 1;
				}

				if(reg.tzMode && (reg.tzMode === "programmable")) {
					const key				= reg.getHWPortName("tz");
					HWPortsIn[key]			= 1;
				}

				reg.fields.forEach( function (field) {
					const fWidth			= parseInt(field.bitWidth);
					const RO				= (field.hardware == "RO") && (field.access == "RO") && !field.name.startsWith("Rsvd");

					// Include *_in signals for Read-only, WO, and RW fields
					if(fWidth && (["WO","RW"].includes(field.hardware) || RO)) {
						const key			= this.getHWPortName(reg.name, field.name, "in");
						HWPortsIn[key]		= fWidth;
					}

					// Include *_wr signals for all WO and RO fields
					if(fWidth && ["WO","RW"].includes(field.hardware)) {
						const key			= this.getHWPortName(reg.name, field.name, "wr");
						HWPortsIn[key]		= 1;
					}
				}.bind(this));

			}.bind(this));
		}.bind(this));


        return HWPortsIn;
    }


    // Function that parses the CSR data-structure and returns an object of keys as port-names
    // and values as the same port-names. The port names do not include interfaces.
    this.getHWPorts             = function (params=null) {
    
        //var regFldsIn           = this.getRegFldsIn(params);
        //var regFldsOut          = this.getRegFldsOut();

		const HWPortsIn			= this.getHWPortsIn(params);
		const HWPortsOut		= this.getHWPortsOut(params);

        var csrHwPorts          = {};
    
        for(var port in HWPortsIn) {
          csrHwPorts[port]      = port;
        } 
        for(var port in HWPortsOut) {
          csrHwPorts[port]      = port;
        }
       
        return csrHwPorts;
    }
}


function getHWPortName(regName,fieldName,type) {
	return fieldName==="" ? [regName, type].join("_") : [regName, fieldName, type].join("_");
}


// Class definitions for generating Verilog expressions
// class VlogExpr
// VlogExpr constructor function
function VlogExpr(width, expr, lastOp) {
	if(!(this instanceof VlogExpr)) return new VlogExpr(width,expr, lastOp); // To handle calling without 'new'

	this._width			= width;
	this._expr			= expr;
	this._lastOp		= lastOp;
}


// Define getter for property width on VlogExpr instances
Object.defineProperty(VlogExpr.prototype, "width", {
	get () {
		return this._width;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property width on VlogExpr instances
Object.defineProperty(VlogExpr.prototype, "expr", {
	get () {
		return this._expr;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Override default string represenation for objects of type VlogExpr
VlogExpr.prototype.toString					= function() {	
	return this._expr;
}


// Method to return replicated expression
VlogExpr.prototype.replicate				= function(n) {
	const width			= n*this._width;
	const expr			= n === 1 ? this._expr : "{"+n+"{"+this._expr+"}}"; 
	return new VlogExpr(width, expr, null); 
}


VlogExpr.prototype.unaryOp					= function(op) {
	const operations	= {
		"!": "negation",
		"~": "complement",
		"|": "redOR",
		"&": "redAND",
		"^": "redXOR"
	};

	if(!(op in operations))
		throw new Error("Unrecognized unary operation: "+op+" attempted on expression "+this._expr);

	if(!this._width)
		throw new Error("Unary operation "+op+" for expression "+this+" with width = 0 cannot be performed");  

	const expr			= !this._lastOp ? op + this._expr : op + envelope("(",")",this._expr);
	const width			= op === "~" ? this._width : 1;

	return new VlogExpr(width, expr, op);
}


VlogExpr.prototype.binaryOp					= function(op, expr) {
	const operations	= { 
		"|": "bitwiseOR", 
		"&": "bitwiseAND",
		"^": "bitwiseXOR" 
	};

	if(!(op in operations))
		throw new Error("Unrecognized binary operation: "+op+" attempted on expressions "+this._expr+" and "+expr._expr);

	if(!this._width)
		throw new Error("Binary operation "+op+" for expression "+this+" with width = 0 cannot be performed");  

	if(!expr._width)
		throw new Error("Binary operation "+op+" for expression "+expr+" with width = 0 cannot be performed");  

	if(this._width != expr._width)
		throw new Error("Binary operations on expressions: "+this+" and "+expr+" must be of the same width. Widths: "+this._width+", "+expr._width);  

	const joined		= [this, expr].map(x => !x._lastOp || (x._lastOp === op) ? x._expr : envelope("(", ")", x._expr)).join(" "+op+" ");
	const width			= this._width;

	return new VlogExpr(width, joined, op);
}


// Method to return a conditional expression with ? and : operator. The condition 
// argument is assumed to be single-bit, expr argument is the expression selected
// when condition is true, and the expression on which this is called is considered 
// the default expression or the expression when condition is false 
// Usage: defaultExpression.ternaryOp(condition, expression)
VlogExpr.prototype.ternaryOp				= function (condition, expr) {
	if(condition._width != 1)
		throw new Error("Width of condition passed to ternaryOp must be one. Condition = "+condition._expr+" , width = "+condition._width);

	if(this._width !== expr._width)
		throw new Error("Widths of expressions on either side of : in a conditional must be of same width. Expr (left) = "+JSON.stringify(expr)+", Expr (right) = "+JSON.stringify(this));

	const leftExpr		= !expr._lastOp ? expr._expr : envelope("(",")",expr._expr);
	const rightExpr		= this._expr;	// Conditional operators have the least precedence hence no need to check if parentheses are required
	const ternaryExpr	= condition._expr + " ? " + leftExpr + " : " + rightExpr;
	const width			= this._width;
	
	return new VlogExpr(width, ternaryExpr, "?");
}


// Method to return a chain of conditional expressions
// Usage: defaultExpresion.conditional({condition: condition1, expr: expr1}, {condition: condition2, expr: expr2}, ... )
// The above will build an expression like this: condition1 ? expr1 : condition2 ? expr2 : ... defaultExpression.
// If the function is called without any arguments, it returns just the default (this) expression
VlogExpr.prototype.conditional				= function (...branches) {
	return branches.reduceRight( (defaultExpr, branch) => defaultExpr.ternaryOp(branch.condition, branch.expr), this );
}


VlogExpr.prototype.bitwiseAND				= function (...exprs) {
	const nonZeroExprs	= [this, ...exprs].filter(x => x._width);

	if(nonZeroExprs.length === 0)
		throw new Error("Expressions to be bitwise-ANDed all had zero-width: "+JSON.stringify(exprs));

	return nonZeroExprs.slice(1).reduce((result, expr) => result.binaryOp("&",expr), nonZeroExprs[0]);
}


VlogExpr.prototype.bitwiseOR				= function (...exprs) {
	const nonZeroExprs	= [this, ...exprs].filter(x => x._width);

	if(nonZeroExprs.length === 0)
		throw new Error("Expressions to be bitwise-ORed all had zero-width: "+JSON.stringify(exprs));

	return nonZeroExprs.slice(1).reduce((result, expr) => result.binaryOp("|",expr), nonZeroExprs[0]);
}


VlogExpr.prototype.cmp						= function (op, expr) {
	if(expr.width !== this._width)
		throw new Error("Compare width mismatch for "+this._expr+" ("+this._width+") and "+expr._expr+" ("+expr.width+")");

	const cmpExpr			= [this._expr, expr._expr].join(" "+op+" ");
	return new VlogExpr(1, cmpExpr, op);
}


VlogExpr.prototype.cat						= function (...exprs) {
	const nonZeroExprs						= [this, ...exprs].filter(x => x._width);

	if(nonZeroExprs.length === 0)
		throw new Error("Expressions to be concatenated all had zero-width: "+JSON.stringify(exprs));

	if(nonZeroExprs.length === 1)
		return nonZeroExprs[0];	

	const expr								= nonZeroExprs.map(x => x._expr).join(", ");
	const sumOfWidths						= nonZeroExprs.reduce((total, x) => total+x._width, 0);
	const braces							= envelope.bind(null, "{", "}");

	return new VlogExpr(sumOfWidths, braces(expr), null);
}


VlogExpr.prototype.pad						= function (value, type, n) {
	if(n < 0)
		throw new Error("Cannot pad negative number of ones or zeros. n = "+n+", pad value = "+value);

	const padConstant	= value===0 ? VlogConst(n, 0) : VlogConst(1, 1).replicate(n);
	return type==="upper" ? padConstant.cat(this) : this.cat(padConstant);
}


VlogExpr.prototype.pad0						= function (n) {
	return this.pad(0,"upper",n);
}


VlogExpr.prototype.pad1						= function (n) {
	return this.pad(1,"upper",n);
}


VlogExpr.prototype.pad0Lower				= function (n) {
	return this.pad(0,"lower",n);
}


VlogExpr.prototype.assign					= function (rhs, opts) {

	const { widthCorrect, indent, assign }						= opts || { widthCorrect: {rhsType: "", lhsType: ""}, indent: {tabs: 2}, assign: {op: "=", type: "continuous"} };

	const rhsFixed			= !widthCorrect || !widthCorrect.rhsType	? rhs : 
							  widthCorrect.rhsType === "pad0"			? rhs.pad0(this._width - rhs._width) :
							  widthCorrect.rhsType === "pad1"			? rhs.pad0(this._width - rhs._width) :
							  widthCorrect.rhsType === "pad0Lower"		? rhs.pad0Lower(this._width - rhs._width) :
							  widthCorrect.rhsType === "pad1Lower"		? rhs.pad0Lower(this._width - rhs._width) :
							  widthCorrect.rhsType === "trunc"			? rhs.trunc(this._width) :
							  rhs;

	const lhsFixed			= !widthCorrect || !widthCorrect.lhsType	? this :
							  widthCorrect.rhsType === "trunc"			? this.trunc(rhs._width) :
							  this;

	if(lhsFixed._width !== rhsFixed._width)
		throw new Error("Number of bits on the right-hand-side experssion ("+rhsFixed._width+" bits) does not match that on the left-hand-side expression ("+lhsFixed._width+" bits)");

	const tabs				= !indent ? 2 : indent.tabs || 2;
	const assignOp			= !assign ? "=" : assign.op || "=";

	return !assign || (assign.type === "continuous") ? "assign "+this._expr+"\t".repeat(tabs)+assignOp+" "+rhsFixed._expr+";" : this._expr+"\t".repeat(tabs)+assignOp+" "+rhsFixed._expr+";";
}


// class VlogConst extends VlogExpr
// VlogConst constructor function
function VlogConst(width, value) {
	if(!(this instanceof VlogExpr)) 
		return new VlogConst(width, value);  // To handle calling without 'new' keyword

	const expr								= width+"'d"+value;
	VlogExpr.call(this, width, expr, null);		// Initialize this by calling superclass constructor
	this._value			= value;
}

// Subclass VlogConst extends superclass VlogExpr
VlogConst.prototype						= Object.create(VlogExpr.prototype);
VlogConst.prototype.constructor			= VlogConst;


// Override default string method for VlogConst objects
VlogConst.prototype.toString		= function (base) {
	const format					= base===16 ? "'h" : base===2 ? "'b" : "'d";	
	return this._width.toString(10) + format + this._value.toString(base);
}


// class VlogSignal extends VlogExpr
// VlogSignal constructor function
function VlogSignal(width, name, options) {
	if(!(this instanceof VlogSignal)) 
		return new VlogSignal(width, name, options);  // To handle calling without 'new' keyword

	const opts			= options || {};
	this._name			= name;
	this._end			= opts.end || 0;
	this._start			= this._end + width - 1;
	const useName		= opts.useName === undefined ? true : opts.useName;
	const expr			= useName ? name : this._start===this._end ? name+"["+this._start+"]" : name+"["+this._start+":"+this._end+"]";

	if(width < 0)
		throw new Error("Width of a VlogSignal cannot not be negative. Signal name: "+name+", width: "+width+", end"+this._end);

	VlogExpr.call(this, width, expr, null);		// Initialize this by calling superclass constructor
}


// Subclass VlogSignal extends superclass VlogExpr
VlogSignal.prototype						= Object.create(VlogExpr.prototype);
VlogSignal.prototype.constructor			= VlogSignal;


// Define getter for property start on VlogSignal instances
Object.defineProperty(VlogSignal.prototype, "start", {
	get () {
		return this._start;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property end on VlogSignal instances
Object.defineProperty(VlogSignal.prototype, "end", {
	get () {
		return this._end;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property end on VlogSignal instances
Object.defineProperty(VlogSignal.prototype, "name", {
	get () {
		return this._name;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Methods in subclass VlogSignal only
// Method to return a bit-slice of a signal
VlogSignal.prototype.slice					= function (start, end) {

	// Todo: Add offset option, default to zero
	
	if(start < end)
		throw new Error("Slice attempt on signal "+this._expr+" failed. Start index "+start+" < End index "+end);

	if(start > this._start)
		throw new Error("Bit access out of bounds for signal "+this._expr+". Start index "+start+", but highest bit = "+this._start+", width = "+this._width);

	if(end < this._end)
		throw new Error("Bit access out of bounds for signal "+this._expr+". End index "+end+", but lowest bit = "+this._end+", width = "+this._width);

	const width			= start-end+1;
	return (start === this._start) && (end === this._end) ? this : new VlogSignal(width, this._name, { useName: false, end });
}


VlogSignal.prototype.lower				= function (width, end) {
	const endFixed		= end || this._end;
	const start			= endFixed+width-1;
	return this.slice(start, endFixed);
}


VlogSignal.prototype.upper				= function (width, start) {
	const startFixed	= start || this._start;
	const end			= startFixed-width+1;
	return this.slice(startFixed, end);
}


// Method to truncate a signal to n bits
VlogSignal.prototype.trunc					= function (n) {
	return this.lower(n);
}


// Same as slice method above except start, end are 
VlogSignal.prototype.sliceX					= function ({ start, end, noOffset }) {
	return noOffset ? this.slice(start, end) : this.slice(start+this._end, end+this._end);
}


// Method to access bit i
VlogSignal.prototype.bit					= function(i) {
	return this.slice(i,i);
}


// Method to access MSB (most significant bit)
VlogSignal.prototype.msb					= function() {
	return this.slice(this._start, this._start);
}


// Method to access MSB (most significant bit)
VlogSignal.prototype.lsb					= function() {
	return this.slice(this._end, this._end);
}


VlogSignal.prototype.declare				= function (type) {
	if(this._width == 0)
		return "";

	const slice			= "["+this._start+":"+this._end+"]";
	const parts			= this._width == 1 ? [ type, this._expr] : [ type, slice, this._expr ];
	return parts.join(" ")+";";
}


// class VlogPort extends VlogSignal
// VlogPort constructor function
function VlogPort(absWidth, name, direction) {
	if(!(this instanceof VlogPort)) return new VlogPort(width, name);  // To handle calling without 'new' keyword
	VlogSignal.call(this, absWidth, name);		// Initialize this by calling superclass constructor

	this.direction		= direction;
}

// Subclass VlogPort extends superclass VlogSignal
VlogPort.prototype						= Object.create(VlogSignal.prototype);
VlogPort.prototype.constructor			= VlogPort;


// Function to convert a signal bundle (signal names as keys, widths as values) to
// a VlogSignal bundle (signal names as keys, VlogSignals as objects). If 'name'
// prefix is specified, then the names of signals will include the prefix.
function getVlogBundle({name="", signals}, options={}) {
	const result						= {};

	Object.entries(signals).forEach( function ([key, value]) {
	  if(typeof value === 'number') {
		const absWidth					= Math.abs(value);
		const direction					= value < 0 ? "in" : "out";
		result[key]						= options.useFactories ? vlogPort(absWidth, name+key, direction) : new VlogPort(absWidth, name+key, direction);

	  } else if(typeof value === 'object') {
		result[key]						= getVlogBundle({ name: name+key, signals: value }, options);

	  } else {
		throw new Error("Illegal type for value in signals, key = "+key);

	  }
	});

	return result;
}


// Function to declare all signals in a Vlog signal bundle / VlogBundle
function declareVlogBundle({type, tabs}, vlogBundle) {
	const tabsFixed		= tabs || 0;
	const typeFixed		= type || "wire";
	const glue			= "\n"+"\t".repeat(tabsFixed);	// Glue that goes between declare statements

	return	Object.values(vlogBundle)			// Get all VlogPort objects
			.filter(x => x._width)				// Filter out ones with zero width
			.map(x => x.declare(typeFixed))		// generate declare statement for each
			.join(glue);						// Join with glue for indentation
}


// class VlogArray
function VlogArray(width, name, length) {
	if(!(this instanceof VlogArray)) 
		return new VlogArray(width, name, length);  // To handle calling without 'new' keyword

	if(length <= 0)
		throw new Error("Length of a VlogArray must be positive. Signal name: "+name+", length = "+length);

	if(width < 0)
		throw new Error("Width of a VlogArray cannot not be negative. Signal name: "+name);

	this._width			= width;
	this._name			= name;
	this._length		= length;
}


// Define getter for property length on VlogArray instances
Object.defineProperty(VlogArray.prototype, "length", {
	get () {
		return this._length;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


VlogArray.prototype.idx					= function (expr) {
  if(typeof expr === 'number') {
	const i				= expr;
	if((i >= this._length) || (i < 0))
		throw new Error("Index out of bounds in idx() for VlogArray "+this._name+", index(i) = "+i);
	
	return VlogSignal(this._width, this._name+"["+i+"]");

  } else if(VlogExpr.prototype.isPrototypeOf(expr)) {
	if(Math.pow(2,expr.width) < this._length)
		throw new Error("Length of VlogArray "+this._name+" is greater than max value of expr  = "+expr);

  }

  return VlogSignal(this._width, this._name+"["+expr+"]");
}


VlogArray.prototype[Symbol.iterator]		= function* () {
	for(let i=0; i<this._length; i++) {
		yield new VlogSignal(this._width, this._name+"["+i+"]");
	}
}


VlogArray.prototype.entries				= function* () {
	for(let i=0; i<this._length; i++) {
		yield [ i, new VlogSignal(this._width, this._name+"["+i+"]") ];
	}
}


VlogArray.prototype.values				= function () {
	const result			= [];
	for(let i=0; i<this._length; i++) {
		result.push( new VlogSignal(this._width, this._name+"["+i+"]") );
	}
	return result;
}


VlogArray.prototype.toString				= function() {	
	return this._name;
}


VlogArray.prototype.declare				= function (type) {
	if(this._width == 0) return "";

	const typeFixed		= type || "wire";

	const bitSlice		= "["+(this._width-1)+":0]";
	const arraySlice	= "["+(this._length-1)+":0]";
	const parts			= this._width == 1 ? [ typeFixed, this._name ] : [ typeFixed, bitSlice, this._name ];
	return parts.join(" ")+arraySlice+";";
}


// class VlogPkdArray
function VlogPkdArray(name, arrayInfo, options={}) {
	if(!(this instanceof VlogPkdArray)) 
		return new VlogPkdArray(name, arrayInfo, options);  // To handle calling without 'new' keyword

	if(arrayInfo.length <= 0)
		throw new Error("Length of a VlogPkdArray must be positive. Signal name: "+name+", length = "+arrayInfo.length);


	// Initialize struct
	this._core			= new PkdArray( arrayInfo, { endian: options.endian, unpack: false, end: options.end } );

	// Call parent class constructor
	VlogSignal.call(this, this._core.width, name, { end: options.end, useName: options.useName } );
}


// Subclass VlogPkdArray extends superclass VlogSignal 
VlogPkdArray.prototype						= Object.create(VlogSignal.prototype);
VlogPkdArray.prototype.constructor			= VlogPkdArray;


// Define getter for property length on VlogPkdArray instances
Object.defineProperty(VlogPkdArray.prototype, "length", {
	get () {
		return this._core.length;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Method to return the nth slice of N equal width slices on this signal
VlogPkdArray.prototype.idx					= function (i) {
	const slice							= this._core.slice(i);
	const packType						= this._core.packType;
	const opts							= { end: slice.end, useName: false };

	if(!packType)
		return new VlogSignal(slice.width, this.name, opts);

	const packEndian					= this._core.packEndian;
	const value							= this._core.idx(i);
	const packOpts						= {...opts, endian: packEndian};

	return packType === "struct" ? new VlogPkdStruct(this.name, value, packOpts) : new VlogPkdArray(this.name, value, packOpts);
}


VlogPkdArray.prototype.entries				= function* () {
	for(let i=0; i<this._core.length; i++)
		yield [ i, this.idx(i) ];
}


VlogPkdArray.prototype.values				= function* () {
	for(let i=0; i<this._core.length; i++)
		yield this.idx(i);
}


VlogPkdArray.prototype[Symbol.iterator]		= VlogPkdArray.prototype.values;


// Function to convert a VlogSignal to a VlogPkdArray with 'length' chunks
function vlogSignal2PkdArray(length, signal) {

  try {
	const totalWidth	= signal.width;
	if(length <=0 )					throw new Error("Length of packed array cannot be zero or negative");	
	if(totalWidth % length != 0)	throw new Error("Signal width = "+totalWidth+" is not divisible by length of packed array = "+length);
	var width			= signal.width / length;

  } catch (err) {
	throw new Error("Attempt to pack signal "+signal+" failed with error: "+err);

  }

  const arrayInfo		= { width, length };
  const options			= { endian: "little" };
  return new VlogPkdArray(signal.name, arrayInfo, options);
}


// class VlogPkdStruct
function VlogPkdStruct(name, structDef, options={}) {
	if(!(this instanceof VlogPkdStruct))
		return new VlogPkdStruct(name, structDef, options);  // To handle calling without 'new' keyword

	// Initialize PkdStruct instance
	this._core						= new PkdStruct(structDef, { endian: options.endian, unpack: false, end: options.end });

	// Call superclass constructor
	VlogSignal.call(this, this._core.width, name, { end: options.end, useName: options.useName });
}


// Subclass VlogPkdStruct extends superclass VlogSignal 
VlogPkdStruct.prototype					= Object.create(VlogSignal.prototype);
VlogPkdStruct.prototype.constructor		= VlogPkdStruct;


// Function that returns a signal slice using field key to lookup
VlogPkdStruct.prototype.get						= function (key) {
	if(!this._core.has(key))
		throw new Error("Struct member "+key+" does not exist in VlogPkdStruct instance "+this.name);

	const slice							= this._core.slice(key);
	const packType						= this._core.packType(key);
	const opts							= { end: slice.end, useName: false };

	if(!packType)
		return new VlogSignal(slice.width, this.name, opts);

	const packEndian					= this._core.packEndian(key);
	const value							= this._core.get(key);
	const packOpts						= {...opts, endian: packEndian};

	return packType === "struct" ? new VlogPkdStruct(this.name, value, packOpts) : new VlogPkdArray(this.name, value, packOpts);
}


VlogPkdStruct.prototype.keys					= function () {
	return this._core.keys();
}


VlogPkdStruct.prototype[Symbol.iterator]		= function* () {
	for( const [key, value, slice, packType, packEndian] of this._core.entries() ) {
		const opts			= { useName: false, end: slice.end };
		yield	packType === "struct"	? new VlogPkdStruct(this.name, value, {...opts, endian: packEndian}) :
				packType === "array"	? new VlogPkdArray(this.name, value, {...opts, endian: packEndian}) :
				new VlogSignal(slice.width, this.name, opts);
	}
}


// Function to convert a VlogSignal to a VlogPkdArray with 'length' chunks
function vlogSignal2PkdStruct(struct, endian, signal) {
  const sumOfFieldWidths				= struct.reduce( (total, [name, width]) => total+width, 0 );
  
  if(signal.width !== sumOfFieldWidths)
  	throw new Error("Signal or net width = "+signal.width+" is not equal to sum of field widths = "+sumOfFieldWidths);

  return new VlogPkdStruct(signal.name, struct, { end: signal.end, endian });
}


// Returns the width of a slice object ({ start, end })
function widthOfSlice(slice) {
	return !slice ? 0 : slice.start - slice.end + 1;
}


// Function to find log2ceil of a BigInt number
// (Math functions do not work on BigInt)
function log2ceilBigInt(p) {
	if(p < 1)
		throw new Error("Cannot find  log2 of value less than 1, p = "+p);

	let x			= typeof p === 'bigInt' ? p - BigInt(1) : BigInt(p) - BigInt(1);
	let result		= 0;

	while(x) {
		x			= x >> BigInt(1);
		result		= result + 1;
	}

	return BigInt(result);
}


// Function to find log2ceil of a BigInt number
// (Math functions do not work on BigInt)
function log2floorBigInt(p) {
	if(p < 1)
		throw new Error("Cannot find  log2 of value less than 1, p = "+p);

	let x			= typeof p === 'bigInt' ? p : BigInt(p);
	let result		= -1;

	while(x) {
		x			= x >> BigInt(1);
		result		= result + 1;
	}

	return BigInt(result);
}


// Generate an n-bit binary bit test pattern:
function* binBitTestPattern (n, options={}) {
	const nBig			= BigInt(n);
	const big1			= BigInt(1);
	const mask			= (big1 << nBig) - big1;

	let shift			= big1 << log2ceilBigInt(nBig);
	let pattern			= (big1 << shift) - big1;

	if(options.includeAllOnes)
		yield pattern & mask;

	shift				= shift >> big1;
	pattern				= (pattern >> shift) ^ pattern;

	while(shift) {
		yield pattern & mask;
		shift			= shift >> big1;
		pattern			= (pattern >> shift) ^ pattern;
	}
}


// Return verilog expression generator
function vlogGen(options = {}) {

	const usePrototypes	= options.usePrototypes || false;

	// Vlog Helper functions (procedural)
	const vlogHelper		= {
		cat: function (exprObjs, endian="big") {
			if(usePrototypes)
				return VlogExpr.prototype.cat.call(...exprObjs);

			if(!Array.isArray(exprObjs))
				throw new Error("Expressions or signals to be concatenated must be in an array");

			let	newWidth				= 0;
			const nonZeroExprs			= [];
			
			exprObjs.forEach( function (exprObj) {
			  if(exprObj.width) {
				newWidth				+= exprObj.width;
				nonZeroExprs.push(exprObj.expr);
			  }
			});
		
			if(!nonZeroExprs.length)
				throw new Error("Expressions to be concatenated all had zero-width: "+JSON.stringify(exprObjs));
		
			const newExpr				= nonZeroExprs.length === 1 ? nonZeroExprs[0] : 
										  endian === "little"		? braces( nonZeroExprs.reverse().join(", ") ) :
										  braces( nonZeroExprs.join(", ") );
			return vlogExpr(newWidth, newExpr);
		},
		
		
		bitwise: function (op, exprObjs) {
			if(exprObjs.length === 0)
				throw new Error("Number of expressions passed to bitwise must be non-zero");
		
			if(!Array.isArray(exprObjs))
				throw new Error("Expressions or signals for bitwise() must be in an array");

			if(usePrototypes)
				return VlogExpr.prototype.bitwise.call(exprObjs[0], op, exprObjs.slice(1));

			const operations		= { 
				"|": "bitwiseOR", 
				"&": "bitwiseAND",
				"^": "bitwiseXOR" 
			};
		
			if(!(op in operations))
				throw new Error("Unrecognized operator: "+op+" attempted on expressions: "+exprObjs.map(x => x.expr)+". Only bitwise binary operations supported by bitwise()");
		
		
			const firstExpr			= exprObjs[0];

			if(exprObjs.length === 1)
				return firstExpr;

			const exprs				= [ !firstExpr.lastOp || (firstExpr.lastOp === op) ? firstExpr.expr : parens(firstExpr.expr) ];	
		
			for(let i=1; i<exprObjs.length; i++) {
				if(!exprObjs[i].width)
					throw new Error("Binary operation "+op+" for expression "+exprObjs[i].expr+" with width = 0 cannot be performed");  
		
				if(firstExpr.width !== exprObjs[i].width)
					throw new Error("Binary operation on expression "+exprObjs[i].expr+" must be of the same width as the first expression: "+firstExpr.expr+". Widths: "+firstExpr.width+", "+exprObjs[i].width);
			
				const exprBraced	= !exprObjs[i].lastOp || (exprObjs[i].lastOp === op) ? exprObjs[i].expr : parens(exprObjs[i].expr);
				exprs.push( exprBraced );	
			}
		
			const newExpr			= exprs.join(" "+op+" ");
			const newWidth			= firstExpr.width;
			
			return vlogExpr(newWidth, newExpr, op);
		},

	
		arith: function (op, exprObjs) {
			if(exprObjs.length === 0)
				throw new Error("Number of expressions passed to bitwise must be non-zero");
		
			if(!Array.isArray(exprObjs))
				throw new Error("Expressions or signals for bitwise() must be in an array");

			const operations		= {
				"+": "ADD",
				"-": "SUB"
			};

			if(!(op in operations))
				throw new Error("Unrecognized operator: "+op+" attempted on expressions: "+exprObjs.map(x => x.expr)+". Only bitwise binary operations supported by bitwise()");
		
		
			const firstExpr			= exprObjs[0];

			if(exprObjs.length === 1)
				return firstExpr;

			const exprs				= [ !firstExpr.lastOp || (firstExpr.lastOp === op) ? firstExpr.expr : parens(firstExpr.expr) ];
			let maxWidth			= firstExpr.width;
		
			for(let i=1; i<exprObjs.length; i++) {
				if(!exprObjs[i].width)
					throw new Error("Arithemetic operation "+op+" for expression "+exprObjs[i].expr+" with width = 0 cannot be performed");  
		
				if(Math.abs(firstExpr.width - exprObjs[i].width) > 1)
					throw new Error("Arithemetic operation on expression "+exprObjs[i].expr+" must be either the same width, one greater, or one lesser width as the first expression: "+firstExpr.expr+". Widths: "+firstExpr.width+", "+exprObjs[i].width);
			
				const exprBraced	= !exprObjs[i].lastOp || (exprObjs[i].lastOp === op) ? exprObjs[i].expr : parens(exprObjs[i].expr);
				exprs.push( exprBraced );	

				if(maxWidth < exprObjs[i].width)
					maxWidth		= exprObjs[i].width;
			}
		
			const newExpr			= exprs.join(" "+op+" ");
			const newWidth			= maxWidth;
			
			return vlogExpr(newWidth, newExpr, op);
		},


		cmp: function (op, lhs, rhs) {
			if(usePrototypes)
				return VlogExpr.prototype.cmp(lhs, op, rhs);

			const operations		= { 
				"==": "equals", 
				">": "greaterThan",
				"<": "lessThan",
				">=": "greaterThanOrEqualTo",
				"<=": "lessThanOrEqualTo" 
			};
		
			if(!(op in operations))
				throw new Error("Unrecognized comparison operation: "+op+" attempted on expressions: "+lhs.expr+" and "+rhs.expr);
	
			if(lhs.width !== rhs.width)
				throw new Error("Widths of expressions on either side of compare operator: "+op+" are unequal. LHS width = "+lhs.width+", RHS width = "+rhs.width);

			const lhsBraced			= !lhs.lastOp ? lhs.expr : parens(lhs.expr);
			const rhsBraced			= !rhs.lastOp ? rhs.expr : parens(rhs.expr);
			const newExpr			= [lhsBraced, rhsBraced].join(" "+op+" ");
			const newWidth			= 1;
			
			return vlogExpr(newWidth, newExpr, op);
		},


		// Method to return a conditional expression with ? and : operator. The condition 
		// argument is assumed to be single-bit, expr argument is the expression selected
		// when condition is true, and the expression on which this is called is considered 
		// the default expression or the expression when condition is false 
		// Usage: defaultExpression.ternaryOp(condition, expression)
		ternaryOp: function (defaultExpr, condition, expr) {
			if(condition.width != 1)
				throw new Error("Width of condition passed to ternaryOp must be one. Condition = "+condition.expr+" , width = "+condition.width);
		
			if(defaultExpr.width !== expr.width)
				throw new Error("Widths of expressions on either side of : in a conditional must be of same width. Expr (left) = "+JSON.stringify(expr)+", Expr (right) = "+JSON.stringify(defaultExpr));
		
			const leftExpr		= !expr.lastOp ? expr.expr : envelope("(",")",expr.expr);
			const rightExpr		= defaultExpr.expr;	// Conditional operators have the least precedence hence no need to check if parentheses are required
			const ternaryExpr	= condition.expr + " ? " + leftExpr + " : " + rightExpr;
			const width			= defaultExpr.width;
			
			return vlogExpr(width, ternaryExpr, "?");
		},


		assign: function (rhs, lhs, options) {
			const opts			= options || {};
			const extend		= opts.extend || false;
			const tabs			= opts.tabs || 2;					// tabs between lhs and == operator
			const op			= opts.op || "=";					// Blocking vs. Non-blocking
			const type			= opts.type || "continuous";		// continuous vs. procedural
			
			if(lhs.width < rhs.width)
				throw new Error("LHS expression width ("+lhs.width+") is less than RHS expression width ("+rhs.width+")");

			if(!extend && (lhs.width > rhs.width))
				throw new Error("LHS expression width ("+lhs.width+") is greater than RHS expression width ("+rhs.width+")");

			const rhsExtended	= extend ? rhs.pad0(lhs.width - rhs.width) : rhs;
			const common		= lhs.expr+"\t".repeat(tabs)+op;	// common string;
			const parts			= type === "procedural" ? [common, rhsExtended.expr] : ["assign", common, rhsExtended.expr];
			return parts.join(" ")+";";
		},


		oneHot2Bin:	function (signal) {
			if(signal.width === 0)
				throw new Error("Cannot convert zero-width signal to binary");

			const newWidth			= log2ceil(signal.width);
			const patterns			= [...binBitTestPattern(signal.width)].map( p => vlogConst(signal.width, p, {radix: 16}) );
			const resultBits		= patterns.map( p => signal.bitwise("&",p).unaryOp("|") );
			return vlogHelper.cat(resultBits);
		},


		bin2OneHot: function (signal, truncWidth) {
			if(signal.width === 0)
				throw new Error("Cannot convert zero-width signal to one-hot");

			if(signal.width > 30)
				throw new Error("bin2OneHot() does not support signal widths greater than 30 bits");
		
			const maxOutWidth		= 1 << signal.width;
			const newWidth			= truncWidth || maxOutWidth;

			if(newWidth > maxOutWidth)
				throw new Error("Truncate-width ("+truncWidth+") is greater than max output signal width ("+newWidth+")");

			const resultBits		= [];
			
			for(let i=0; i<newWidth; i++) {
				const cmpConst		= vlogConst(signal.width, i);
				const minterm		= signal.cmp("==", cmpConst);
				resultBits.push(minterm);
			}

			return vlogHelper.cat(resultBits, "little");

			// Alternate implementation for shorter expression
			//if(signal.width > 3) {
			//	const minterms			= [];
			//	const patterns			= [...binBitTestPattern(newWidth)].reverse();

			//	for(let i=0; i<signal.width; i++) {
			//		const p				= vlogConst(newWidth, patterns[i], {radix: 16});
			//		const maxterm0		= signal.bit(i).unaryOp("~").replicate(newWidth).bitwise("&", p);
			//		const maxterm1		= signal.bit(i).replicate(newWidth).bitwise("&", p.complement());
			//		minterms.push(maxterm0);
			//		minterms.push(maxterm1);
			//	}

			//	return vlogHelper.bitwise("|",minterms).unaryOp("~");
			//}
		},

	
		simpleThermo: function (signal, priority="lsb") {
			const width				= signal.width;
			if(width === 0)
				throw new Error("Cannot convert zero-width signal to thermomemter-encoded signal");

			// Define function to compute ith bit of the thermometer-encoded signal
			const thermoBit			= priority === "lsb" ? i => signal.lower(i+1).unaryOp("|") : i => signal.upper(width-i).unaryOp("|");

			// Map each of "width" bits to a thermoBit
			const resultBits		= range(width).map(thermoBit);

			return vlogHelper.cat(resultBits, "little");
		},

		
		thermo: function (signal, priority="lsb") {
			// LSB first thermo encoding: ~{ x[n-1]|x[n-2]...|x[1]|x[0], x[n-2]|x[n-3]...|x[1]|x[0], ..., x[2]|x[1]|x[0], x[1]|x[0], x[0], 0 }
			const width				= signal.width;
			if(width === 0)
				throw new Error("Cannot convert zero-width signal to thermomemter-encoded signal");

			// Define function to compute ith bit of the thermometer-encoded signal
			const thermoBit			= priority === "lsb" ? i => signal.lower(i+1).unaryOp("|").unaryOp("~") : i => signal.upper(width-1-i).unaryOp("|").unaryOp("~");

			// Map each of "width" bits to a thermoBit
			const allBitsExceptLSB	= range(width-1).map(thermoBit);
			const resultBits		= priority === "lsb" ? [ vlogConst(1,1) ].concat( allBitsExceptLSB ) : allBitsExceptLSB.concat( vlogConst(1,1) );

			return vlogHelper.cat(resultBits, "little");
		},

		
		oneHotSelMux: function (sel, inputs) {
			if(sel.width < inputs.length)
				throw new Error("Width of the one-hot select input = "+sel.width+" is less than the number of mux inputs = "+inputs.length);

			const minterms			= [];

			for( let i=0; i<inputs.length; i++) {
				const mask			= sel.bit(i).replicate(inputs[i].width);
				const minterm		= mask.bitwise( "&", inputs[i] );
				minterms.push(minterm);
			}
	
			return vlogHelper.bitwise( "|", minterms );
		}

	};
	
	
	// Function to convert a signal bundle (signal names as keys, widths as values) to
	// a VlogSignal bundle (signal names as keys, VlogSignals as objects). If 'name'
	// prefix is specified, then the names of signals will include the prefix.
	function getVlogBundle({name="", signals}) {
		const result						= {};
	
		Object.entries(signals).forEach( function ([key, value]) {
		  if(typeof value === 'number') {
			const absWidth					= Math.abs(value);
			const direction					= value < 0 ? "in" : "out";
			result[key]						= usePrototypes ? new VlogPort(absWidth, name+key, direction) : vlogPort(absWidth, name+key, direction);
	
		  } else if(typeof value === 'object') {
			result[key]						= getVlogBundle({ name: name+key, signals: value }, options);
	
		  } else {
			throw new Error("Illegal type for value in signals, key = "+key);
	
		  }
		});
	
		return result;
	}
	
	
	// Function to declare all signals in a Vlog signal bundle / VlogBundle
	function declareVlogBundle(options, bundle) {
		const opts			= options || {};
		const tabsFixed		= opts.tabs || 0;
		const typeFixed		= opts.type || "wire";
		const glue			= "\n"+"\t".repeat(tabsFixed);	// Glue that goes between declare statements
	
		return	Object.values(bundle)			// Get all VlogPort objects
				.filter(x => x.width)				// Filter out ones with zero width
				.map(x => x.declare(typeFixed, tabsFixed))		// generate declare statement for each
				.join(glue);						// Join with glue for indentation
	}


	// Function to convert vlogSignal to a vlogPkdArray object
	function vlogSignal2PkdArray(length, signal) {
		try {
			const totalWidth		= signal.width;
			if(length <=0 )					throw new Error("Length of packed array cannot be zero or negative");	
			if(totalWidth % length != 0)	throw new Error("Signal width = "+totalWidth+" is not divisible by length of packed array = "+length);
			var width				= signal.width / length;

		} catch (err) {
			throw new Error("Attempt to pack signal "+signal+" failed with error: "+err);

		}

		return vlogPkdArray({width, length}, signal.name, options);
	}

	
	// Factory function to return vlogExpr
	function vlogExpr(width, expr, lastOp) {
		if(usePrototypes)
			return new VlogExpr(width, expr, lastOp);
	
		let that					= { width, expr, lastOp };
		
		function replicate(n) {
			const newExpr			= n === 1 ? that.expr : braces( n + braces(that.expr) );
			const newWidth			= n * width;
			return vlogExpr(newWidth, newExpr);
		}
	
		
		function unaryOp(op) {
			const operations		= {
				"!": "negation",
				"~": "complement",
				"|": "redOR",
				"&": "redAND",
				"^": "redXOR"
			};
	
			if(!(op in operations))
				throw new Error("Unrecognized unary operation: "+op+" attempted on expression "+that.expr);
	
			const newExpr			= !lastOp ? op + that.expr : op + parens(that.expr);
			const newWidth			= op === "~" ? width : 1;
			return vlogExpr(newWidth, newExpr, op);
		};
	
	
		function bitwise(op, ...exprObjs) {
			const allExprs			= [that, ...exprObjs];
			return vlogHelper.bitwise(op, allExprs);
		}

		function cmp(op, rhs) {
			return vlogHelper.cmp(op, that, rhs);
		}	

	
		function ternaryOp(condition, exprObj) {	
			return vlogHelper.ternaryOp(that, condition, exprObj);
		}	


		//// Method to return a chain of conditional expressions
		//// Usage: defaultExpresion.ternaryChain(ifThens), where ifThens is an array of objects with keys 'condition' and 'branch':
		// [{condition: condition1, branch: branch1}, {condition: condition2, branch: branch2}, ... ]
		//// The above will build an expression like this: condition1 ? branch1 : condition2 ? branch2 : ... defaultExpression.
		//// If the function is called with an empty array, it returns just the default (this) expression
		function ternaryChain (ifThens) {
			return ifThens.reduceRight( (defaultExpr, ifThen) => vlogHelper.ternaryOp(defaultExpr, ifThen.condition, ifThen.branch), that );
		}
	
	
		function cat(...exprObjs) {
			const allExprs			= [that, ...exprObjs];
			return vlogHelper.cat(allExprs, "big");
		}
	
	
		function pad (value, type, n) {
			if(n < 0)
				throw new Error("Cannot pad negative number of ones or zeros. n = "+n+", pad value = "+value);
		
			const padConstant	= value===0 ? vlogConst(n, 0) : vlogConst(1, 1).replicate(n);
			return type==="upper" ? padConstant.cat(that) : that.cat(padConstant);
		}
	
	
		function pad0(n) {
			return pad(0,"upper",n);
		}
	
	
		function pad0Lower(n) {
			return pad(0,"lower",n);
		}

	
		function pad1(n) {
			return pad(1,"upper",n);
		}
	
	
		function pad1Lower(n) {
			return pad(1,"lower",n);
		}

	
		function extend0(toWidth) {
			return pad(0,"upper",toWidth-that.width);
		}


		function assign(lhs, options) {
			return vlogHelper.assign(that, lhs, options);
		}
	
	
		function toString() {	
			return that.expr;
		}
	
	
		return Object.assign( that, {
			replicate,
			unaryOp,
			bitwise,
			cmp,
			ternaryOp,
			ternaryChain,
			cat,
			pad0,
			pad1,
			pad0Lower,
			extend0,
			pad1Lower,
			assign,
			toString
		});
	}
	
	
	// Factory functions to return verilog constant objects
	function vlogConst(width, value, options={}) {
		if(usePrototypes)
			return new VlogConst(width, value);

		const bigValue		= typeof value === "bigInt" ? value : BigInt(value);	
		const minBits		= bigValue < 1 ? BigInt(0) : log2floorBigInt(bigValue) + BigInt(1);
		const radix			= options.radix || 10;
	
		if(![10,16,2].includes(radix))
			throw new Error("Unsupported radix = "+radix);

		if(width < minBits)
			throw new Error("Specified width of constant = "+width+" is less than the minimum number of bits required ("+minBits+") to represent value = "+value); 
	
		const format		= radix===10 ? "'d" : radix===16 ? "'h" : "'b";	
		const expr			= width + format + bigValue.toString(radix);
		let that			= vlogExpr(width, expr);
		that.value			= bigValue;


		function complement() {
			const big1		= BigInt(1);
			const mask		= (big1 << BigInt(that.width)) - big1;
			const newValue	= ~that.value & mask;
			return vlogConst(that.width, newValue, { radix });
		}
	
	
		function lShift(n, truncWidth) {
			const newWidth			= truncWidth || ( typeof n === 'number' ? n+that.width : (1 << n.width)+that.width-1 );

			if(newWidth > 30)
				throw new Error("Max shift amount for constant of width = "+that.width+" must be less than "+(31-that.width));

			if(typeof n === 'number') {
				const newValue		= that.value << n;
				const mask			= (1 << newWidth) - 1;
				return vlogConst(newWidth, newValue & mask, { radix });
			}

			const big1				= BigInt(1);
			const minterms			= [];
			const maxShift			= big1 << BigInt(n.width);
			const truncMask			= (big1 << BigInt(newWidth)) - big1;
			
			for(let i=0; i<maxShift; i++) {
				const maskValue		= (that.value << BigInt(i)) & truncMask;

				if(maskValue) {
					const mask		= vlogConst(newWidth, maskValue, {radix: 16});
					const cmpConst	= vlogConst(n.width, i);
					const minterm	= n.cmp("==",cmpConst).replicate(newWidth).bitwise("&", mask);
					minterms.push(minterm);
				}
			}

			return vlogHelper.bitwise("|", minterms);
		}


		function rShift(n, truncWidth) {
			return 0;
		}	
	
	
		return Object.assign( that, {
			complement,
			lShift,
			rShift
		});
	}
	
	
	function vlogSignal(width, name, options={}) {
		if(usePrototypes)
			return new VlogSignal(width, name, options);
	
		const end					= options.end || 0;
		const start					= end + width - 1;
		const useName				= options.useName === undefined ? true : options.useName;
		const expr					= useName ? name : start===end ? name+brackets(start) : name+brackets(start+":"+end);
	
		let that					= vlogExpr(width, expr);
		that.name					= name;
		that.start					= start;
		that.end					= end;
	
	
		function slice(newStart, newEnd) {
			if(newStart < newEnd)
				throw new Error("Slice attempt on signal "+that.expr+" failed. Start index "+newStart+" < End index "+newEnd);
	
			if(newStart > that.start)
				throw new Error("Bit access out of bounds for signal "+that.expr+". Start index "+newStart+", but highest bit = "+that.start+", width = "+that.width);
	
			if(newEnd < that.end)
				throw new Error("Bit access out of bounds for signal "+that.expr+". End index "+newEnd+", but lowest bit = "+that.end+", width = "+that.width);
	
			const newWidth			= newStart-newEnd+1;
			const newUseName		= useName && (newStart === that.start) && (newEnd === that.end);
			return vlogSignal(newWidth, that.name, { useName: newUseName, end: newEnd });
		}
	
	
		function upper(newWidth, newStart) {	
			const startFixed		= newStart === undefined ? that.start : newStart;
			const newEnd			= startFixed - newWidth + 1;
			return that.slice(startFixed, newEnd);
		}
	
	
		function lower(newWidth, newEnd) {
			const endFixed			= newEnd === undefined ? that.end : newEnd;
			const newStart			= endFixed + newWidth - 1;
			return that.slice(newStart, endFixed);
		}
	
		
		function trunc(n) {
			return that.lower(n);
		}
	

		// Relative slice. Returns slice or part-select relative to end index	
		function slicer(sliceObj) {
			const newStart			= sliceObj.start + that.end;
			const newEnd			= sliceObj.end + that.end;
			return that.slice(newStart, newEnd);	
		}
	
	
		function bit(i) {
			return that.slice(i,i);
		}
	
	
		// Returns bit relative to the end index
		function bitr(i) {
			return that.slice(i+that.end, i+that.end);
		}
	
	
		function msb() {
			return that.slice(that.start, that.start);
		}
	
	
		function lsb() {
			return that.slice(that.end, that.end);
		}
	
	
		function split( wChunk ) {		// Returns chunks in little endian order: LSB chunk occupies index 0 of array
			if(wChunk<1)
				throw new Error("Width of chunk = "+wChunk+" must be greater than zero");

			const result			= [];
			let	total				= that.width;

			while(total >= wChunk) {
				const lsb			= that.width - total + that.end;
				result.push( that.lower(wChunk, lsb) );
				total				= total - wChunk;
			}

			return total ? result.concat( that.upper(total) ) : result;
		}
	
	
		function declare(type="wire") {
			if(that.width == 0)
				return "";
	
			const sliceExpr			= brackets(that.start+":"+that.end);
			const parts				= that.width === 1 ? [type, that.name] : [type, sliceExpr, that.name];
			return parts.join(" ")+";"
		}


		function lShift(n, options) {
			if(n < 0)
				return rShift(-n, options);

			//const newWidth		= truncWidth === undefined ? (n+that.width) : truncWidth;
			//if(newWidth < 1)
			//	throw new Error(" Truncate-width = "+newWidth+" must be at least one");

			const opts			= options || {};
			const extendWidth	= opts.extendWidth || 0;
			const signExtend	= opts.signExtend || false;
			const newWidth		= that.width + extendWidth;

			const padLoWidth	= Math.min(newWidth, n);
			const sliceWidth	= newWidth > (that.width+padLoWidth) ? that.width : newWidth > padLoWidth ? newWidth - padLoWidth : 0;
			const padHiWidth	= newWidth > (sliceWidth+padLoWidth) ? newWidth - sliceWidth - padLoWidth : 0;

			const padLoBits		= vlogConst(padLoWidth,0);
			const padHiBits		= signExtend ? that.msb().replicate(padHiWidth) : vlogConst(padHiWidth,0);

			const result		= sliceWidth ? [ padHiBits, that.lower(sliceWidth), padLoBits ] : [ padLoBits ];
			return vlogHelper.cat(result)
		}


		function rShift(n, options) {
			if(n < 0)
				return lShift(-n, options);

			//const newWidth		= truncWidth === undefined ? that.width : truncWidth;
			//if(newWidth < 1)
			//	throw new Error(" Truncate-width = "+newWidth+" must be at least one");

			const opts			= options || {};
			const extendWidth	= opts.extendWidth || 0;
			const signExtend	= opts.signExtend || false;
			const newWidth		= that.width + extendWidth;

			const sliceWidth	= n > that.width ? 0 : Math.min(that.width - n, newWidth);
			const sliceLsb		= n+that.end;
			const padHiWidth	= newWidth > sliceWidth ? newWidth - sliceWidth : 0; 
			const padHiBits		= signExtend ? that.msb().replicate(padHiWidth) : vlogConst(padHiWidth,0);

			const result		= sliceWidth ? [ padHiBits, that.lower(sliceWidth, sliceLsb) ] : [ padHiBits ];
			return vlogHelper.cat(result);
		}


		function shift(op, n, extendWidth) {
			if(typeof n !== 'number')
				throw new Error("Variable shift is not supported");

			const lut			= {
				"<<":	{ signExtend: false, shiftFn: lShift },
				">>":	{ signExtend: false, shiftFn: rShift },
				"<<<":	{ signExtend: true, shiftFn: lShift },
				">>>":	{ signExtend: true, shiftFn: rShift }
			};

			if(!(op in lut))
				throw new Error(op+" is not a valid shift operator");

			return lut[op].shiftFn( n, { extendWidth, signExtend: lut[op].signExtend } );
		}


		function toPkdArray(arrayDef, options) {
			const opts				= options || {};
			const endian			= opts.endian;
			const end				= that.end;
			return vlogPkdArray(arrayDef, that.name, { end, endian, useName: false });
		}


		function toPkdStruct(structDef, options) {
			const opts				= options || {};
			const endian			= opts.endian;
			const end				= that.end;
			return vlogPkdStruct(structDef, that.name, { end, endian, useName: false });
		}


		return Object.assign( that, {
			slice,
			upper,
			lower,
			trunc,
			slicer,
			bit,
			bitr,
			msb,
			lsb,
			split,
			shift,
			toPkdArray,
			toPkdStruct,
			declare
		});
	}
	
	
	function vlogPkdStruct(structDef, name, options={}) {
		if(usePrototypes)
			return new VlogPkdStruct(name, structDef, options);
	
		// Initialize core to instance of PkdStruct. Setting unpack to false prevents core from converting
		// value of a packed struct member to an instance of PkdStruct or PkdArray.
		const core					= new PkdStruct( structDef, { endian: options.endian, unpack: false, end: options.end });
		let that					= vlogSignal(core.width, name, { end: options.end, useName: options.useName });
	
	
		// Function to access struct members by name. Returns a vlogPkdStruct instance if 
		// packType = "array", vlogPkdArray instance if packType = "struct", and vlogSignal
		// instance otherwise
		function get(key) {
			// Retrieve value from core which is a structDef, if packType = "struct", an arrayDef, 
			// if packType = "array", and undefined otherwise.
			if(!core.has(key))
				throw new Error("Struct member "+key+" does not exist in vlogPkdStruct "+that.name);
	
			const slice				= core.slice(key);
			const packType			= core.packType(key);
			const opts				= { end: slice.end, useName: false };
	
			if(!packType)
				return vlogSignal(slice.width, that.name, opts);
	
			const packEndian		= core.packEndian(key);
			const value				= core.get(key);
			const packOpts			= {...opts, endian: packEndian};
	
			return packType === "struct" ? vlogPkdStruct(value, that.name, packOpts) : vlogPkdArray(value, that.name, packOpts);
		}
	
	
		// Returns iterator to iterate over struct members in the same order as they appear
		// in original structDef.
		function* entries() {
			for( const [key, value, slice, packType, packEndian] of core.entries() ) {
				const opts			= { useName: false, end: slice.end };
				const vlogObj		= packType === "struct"	? vlogPkdStruct(value, that.name, {...opts, endian: packEndian}) :
									  packType === "array"	? vlogPkdArray(value, that.name, {...opts, endian: packEndian}) :
									  vlogSignal(slice.width, that.name, opts);
				yield [ key, vlogObj ];
			}
		}
	
	
		// Returns iterator to iterate over struct members in the same order as they appear
		// in original structDef.
		function* values() {
			for( const [key, value, slice, packType, packEndian] of core.entries() ) {
				const opts			= { useName: false, end: slice.end };
				yield	packType === "struct"	? vlogPkdStruct(value, that.name, {...opts, endian: packEndian}) :
						packType === "array"	? vlogPkdArray(value, that.name, {...opts, endian: packEndian}) :
						vlogSignal(slice.width, that.name, opts);
			}
		}
	
	
		// Returns iterator to iterate over keys/names of all struct members
		function keys() {
			return core.keys();
		}
	
	
		return Object.assign( that, {
			get,
			keys,
			values,
			entries,
			[Symbol.iterator]: values
		});
	}
	
	
	function vlogPkdArray(arrayDef, name, options={}) {
		if(usePrototypes)
			return new VlogPkdArray(name, arrayDef, options);
	
		
		// Initialize core to instance of PkdStruct. Setting unpack to false prevents core from converting
		// value of a packed struct member to an instance of PkdStruct or PkdArray.
		const core					= new PkdArray(arrayDef, { endian: options.endian, unpack: false, end: options.end });
		let that					= vlogSignal(core.width, name, { end: options.end, useName: options.useName });
	
		
		function idx(i) {
			const slice				= core.slice(i);
			const packType			= core.packType;
			const opts				= { end: slice.end, useName: false };
	
			if(!packType)
				return that.slicer(slice);
	
			const packEndian		= core.packEndian;
			const value				= core.idx(i);
			const packOpts			= {...opts, endian: packEndian};
	
			return packType === "struct" ? vlogPkdStruct(value, that.name, packOpts) : vlogPkdArray(value, that.name, packOpts);
		}
	
	
		// Returns iterator to iterate over array elements in increasing index order
		function* entries() {
			for(let i=0; i<core.length; i++)
				yield [ i, that.idx(i) ];
		}
	
	
		// Returns iterator to iterate over array elements in increasing index order
		function* values() {
			for(let i=0; i<core.length; i++)
				yield that.idx(i);
		}
	
	
		return Object.assign( that, {
			idx,
			entries,
			values,
			[Symbol.iterator]: values
		});
	}
	

	// Factory function to create a vlogArray (array of vlogSignals)
	function vlogArray(arrayDef, name, options={}) {
		if(usePrototypes)
			return new VlogArray(arrayDef.width, name, arrayDef.length);

		const width					= !arrayDef.packType ? arrayDef.width : pkdWidth(arrayDef.packType, arrayDef.value);
		const lengths				= Array.isArray(arrayDef.length) ? arrayDef.length : [ arrayDef.length ];

		let that					= {};
		that.name					= name;
		that.length					= Array.isArray(arrayDef.length) ? arrayDef.length[0] : arrayDef.length;
		that.width					= width;
		
		
		// Return vlog object at index i
		function idx(i) {
			if(i >= that.length)
				throw new Error("Array index out of bounds for vlogArray "+that.name);

			const name				= that.name+"_"+i;
			const nestedLengths		= lengths.slice(1);

			if(nestedLengths.length > 0) {
				const nestedArrayDef		= { ...arrayDef, length: nestedLengths };
				return vlogArray(nestedArrayDef, name);
			}				
	
			const packType			= arrayDef.packType || "";
			
			if(!packType)
				return vlogSignal(arrayDef.width, name);
		
			const value				= arrayDef.value;
			const packEndian		= arrayDef.endian;
		
			if(packType === "struct")
				return vlogPkdStruct(value, name, { endian: packEndian });

			if(packType === "array")
				return vlogPkdArray(value, name, { endian: packEndian });

			throw new Error("Unsupported packType = "+packType);
		}
	

		function toString() {	
			return that.name;
		}
	

		function declare(type="wire", tabs=0) {
			if(width == 0)
				return "";

			const indices			= lengths.map( x => range(x) );
			const statements		= [];

			cross(...indices).forEach( function (x) {
				const name			= [that.name, ...x].join("_");
				const parts			= width === 1 ? [type, name] : [type, "["+(width-1)+":0]", name];
				statements.push( parts.join(" ")+";" );
			});

			const glue			= "\n"+"\t".repeat(tabs);	// Glue that goes between declare statements
			return statements.join(glue);
		}
	
	
		// Returns iterator to iterate over array elements in increasing index order
		function* entries() {
			for(let i=0; i<that.length; i++)
				yield [ i, that.idx(i) ];
		}
	
	
		// Returns iterator to iterate over array elements in increasing index order
		function* values() {
			for(let i=0; i<that.length; i++)
				yield that.idx(i);
		}
	
	
		return Object.assign( that, {
			idx,
			toString,
			declare,
			[Symbol.iterator]: values
		});
	}

	
	// Factory function to create a vlogPort object by extending vlogSignal
	// with a property 'direction'
	function vlogPort(width, name, direction) {
		if(usePrototypes)
			return new VlogPort(width, name, direction);
	
		if(width < 0)
			throw new Error("Width of a vlogPort object cannot be negative");		
	
		let that					= vlogSignal(width, name);
		that.direction				= direction;
	
		return that;
	}

	
	return {
		vlogHelper,
		getVlogBundle,
		declareVlogBundle,
		vlogSignal2PkdArray,
		vlogExpr,
		vlogSignal,
		vlogConst,
		vlogArray,
		vlogPkdArray,
		vlogPkdStruct
	};
}


// Verilog expression parsing utilities
// Function to Parse Verilog constant literal
function parseVlogConst (x) {
	const literal				= x.toString();
	const widthMatch			= new RegExp(/(?<width>\d+)/);
	const radixMatch			= new RegExp(/(?<radix>[hdb])/);
	const signMatch				= new RegExp(/(?<sign>-)/);
	const valueMatch			= new RegExp(/(?<value>[\da-fA-F]+)/);

	const widthAndRadix			= widthMatch.source + "?" + "'" + radixMatch.source;
	const fullRegex				= "^" + parens(widthAndRadix) + "?" + signMatch.source + "?" + valueMatch.source + "$";
	const matches				= literal.match( fullRegex );

	if(!matches) return {};

	const width					= matches.groups.width && parseInt(matches.groups.width);
	const radix					= matches.groups.radix === "h" ? 16 : matches.groups.radix === "b" ? 2 : 10;
	const sign					= matches.groups.sign || "+";
	const serialValue			= radix === 16 ? "0x"+matches.groups.value : radix === 2 ? "0b"+matches.groups.value : matches.groups.value;
	
	try {
		var value				= sign === "-" ? -BigInt(serialValue) : BigInt(serialValue);
	} catch(err) {
		return {};
	}
	
	return { width, radix, value };
}


// Function to generate a Verilog constant literal
// Inverse of the parseVlogConst() function above
function genVlogConst ({ width, radix, value }) {
	const base					= radix === 16 ? "h" : radix === 10 ? "d" : "b";
	const valueString			= value.toString(radix);
	return width + "'" + base + valueString;
}


// Class to perform operations on slice objects { start, end } pair
// Constructor
function Slice({ start, end, width }) {
	if(!(this instanceof Slice))
		return new Slice({ start, end, width });  // To handle calling without 'new' keyword

	this._start			= start === undefined ? end + width - 1 : start;
	this._end			= end === undefined ? start - width + 1 : end;
}


// Define getter for property length on Slice instances
Object.defineProperty( Slice.prototype, "start", {
	get () {
		return this._start;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property length on Slice instances
Object.defineProperty( Slice.prototype, "end", {
	get () {
		return this._end;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property length on Slice instances
Object.defineProperty( Slice.prototype, "width", {
	get () {
		return this._start - this._end + 1;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Method to shift a slice object by 'offset' bits
Slice.prototype.shift				= function ( offset ) {
	return new Slice({ start: this.start+offset, end: this.end+offset });
}


// Method to convert a little endian slice to a big-endian slice and vice-versa
Slice.prototype.switchEndian		= function ( size ) {
	const end			= size - this.width - this.end;
	const start			= size - this.end - 1;

	return new Slice({ start, end });
}


// Method to convert a little endian slice to a big-endian slice and vice-versa
Slice.prototype.expand				= function ( hold, width ) {
	const start			= hold === "end" ? this._start + width : this._start;
	const end			= hold === "start" ? this._end - width : this._end;

	return new Slice({ start, end });
}


// Method to return the intersection of this slice with another slice
// In terms of sets, A intersection B, i.e. bits common in both slices A and B
Slice.prototype.intersect			= function (slice) {

  // If none of the bits overlap return undefined
  if((this._start < slice._end) || (slice._start < this._end))	
		return undefined;

  const [ start, end ]				= [ Math.min(this._start, slice._start), Math.max(this._end, slice._end) ];

  return new Slice({ start, end });

}


// Method to determine if two slices have the same set of bits
Slice.prototype.equal				= function (slice) {
  return (this._start===slice._start) && (this._end===slice._end);
}


// Method to return an array of slices after removing some bits (slices) in this slice
// Equivalent to set-difference / relative complement = A - B
Slice.prototype.exclude				= function (...slices) {
	if(slices.length === 0)
		return [ this ];

	if(slices.length === 1) {
		const slice		= this.intersect(slices[0]);		// Overlapping / Intersecting bits in slices[0] and this

		return	!slice						? [ this ] :															// No overlapping bits
				this.equal(slice)			? [] :																	// All bits overlap
				slice._start==this._start	? [ new Slice({ "start":this._start-slice.width, "end":this._end }) ] :	// start bits of both slices are aligned
				slice._end==this._end		? [ new Slice({ "start":this._start, "end":this._end+slice.width }) ] : // end bits of both slices are aligned
				[ new Slice({ "start":this._start, "end":slice._start+1 }), new Slice({ "start":slice._end-1, "end": this._end }) ]; // slice inside this
	}

	// Each iteration, a slice to be excluded is applied on every slice 
	// in the results array. This leads to an array of array in each iteration
	// and is hence flattened
	return slices.reduce( function (results, slice) {
		const leftOvers				= results.map( result => result.exclude(slice) ); // Exclude slice from each result in results array
		return [].concat(...leftOvers);					// Flatten array / remove nested arrays and return
	}, [ this ] );	// Initialize the results parameter to this ( no bits are removed before iterating )
}


// Packed structures
// Class PkdArray definition

// Constructor
function PkdArray( arrayInfo, options ) {
	if(!(this instanceof PkdArray))
		return new PkdArray( arrayInfo, options );  // To handle calling without 'new' keyword

	// Set defaults for parameters 
	const arrInfo		= arrayInfo || {};
	const opts			= options || {};

	this._endian		= opts.endian || "little";
	this._unpack		= opts.unpack === undefined ? true : opts.unpack;

	this._packType		= arrInfo.packType || "";
	this._value			= arrInfo.value;
	this._valueWidth	= arrInfo.width === undefined ? pkdWidth(arrInfo.packType, arrInfo.value) : Math.abs(arrInfo.width);
	this._packEndian	= arrInfo.endian ? arrInfo.endian : arrInfo.packType && (arrInfo.packType === "struct") ? "big" : this._endian;
	this._length		= arrInfo.length || 0;
	this._nonPkdValues	= arrInfo.nonPkdValues || [];		// Array used only when packType is empty or undefined

	// Checks
	if(!this._valueWidth)
	  throw new Error("Property width was undefined or zero in parameter value in PkdArray()");

	// Set start and end of the PkdStruct instance
	// Determine which of the two to hold and let the other vary as entries as added
	const total			= this._valueWidth*this._length;		// Width of array
	let start, end;

	if(("start" in opts) && ("end" in opts)) {
		this._hold		= this._endian === "big" ? "start" : "end";
		[ start, end ]	= this._endian === "big" ? [ opts.start, opts.start-total+1 ] : [ opts.end+total-1, opts.end ];

	} else if("start" in opts) {
		this._hold		= "start";
		[ start, end ]	= [ opts.start, opts.start-total+1 ];

	} else {
		this._hold		= "end";
		end				= opts.end || 0;
		start			= this._end+total-1;
	}

	this._slice			= new Slice({ start, end });
}


// Define getter for property length on PkdArray instances
Object.defineProperty( PkdArray.prototype, "length", {
	get () {
		return this._length;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property start on PkdArray instances
Object.defineProperty( PkdArray.prototype, "start", {
	get () {
		return this._slice.start;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property end on PkdArray instances
Object.defineProperty( PkdArray.prototype, "end", {
	get () {
		return this._slice.end;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property width on PkdArray instances (Total width of all entries)
Object.defineProperty( PkdArray.prototype, "width", {
	get () {
		return this._valueWidth * this._length;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property valueWidth on PkdArray instances (Total width of all entries)
Object.defineProperty( PkdArray.prototype, "valueWidth", {
	get () {
		return this._valueWidth;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property packType on PkdArray instances (Total width of all entries)
Object.defineProperty( PkdArray.prototype, "packType", {
	get () {
		return this._packType;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property packEndian on PkdArray instances (Total width of all entries)
Object.defineProperty( PkdArray.prototype, "packEndian", {
	get () {
		return this._packEndian;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


PkdArray.prototype.slice			= function ( index ) {
	if((index >= this._length) || (index < 0))
		throw new Error("Access to PkdArray instance is out of bounds. Index = "+index+", Array length = "+this._length);

	const indexActual	= this._endian === "big" ? this._length - index - 1 : index;
	const end			= indexActual * this._valueWidth;
	const start			= this._valueWidth + end - 1;
	const slice			= { start, end };						// This is the slice assuming zero offset

	return (new Slice(slice)).shift(this._slice.end);
};


PkdArray.prototype.idx				= function ( index ) {
	if((index >= this._length) || (index < 0))
		throw new Error("Access to PkdArray instance is out of bounds. Index = "+index+", Array length = "+this._length);

	if(!this._packType)
		return this._nonPkdValues[index];
		
	if( !this._unpack )
		return this._value;

	const indexActual	= this._endian === "big" ? this._length - index - 1 : index;
	const newStart		= this._slice.end + (this._valueWidth * (indexActual+1)) - 1;
	const newEnd		= this._slice.end + (this._valueWidth * indexActual);
	const options		= { start: newStart, end: newEnd, endian: this._packEndian };

	if( this._packType === "array" )
		return new PkdArray(this._value, options);

	if( this._packType === "struct" )
		return new PkdStruct(this._value, options);

	throw new Error("Invalid PackType = "+this._packType+" for value in Pkdarray instance");
};


// Function to calculate the width of a nested packed object
function pkdWidth (packType, struct) {	
	if(packType === "array") {
	  if(struct.width === undefined)
		return struct.packType === "struct" ? pkdWidth("struct", struct.value) * struct.length : pkdWidth("array", struct.value) * struct.length;

	  return Math.abs(struct.width) * struct.length;
	}

	// Else assume struct
	let result			= 0;
	
	for(let i=0; i<struct.length; i++)
		result			+= struct[i].width ? Math.abs(struct[i].width) : struct[i].packType === "struct" ? pkdWidth("struct", struct[i].value) : pkdWidth("array", struct[i].value);	

	return result;
}


// Class PkdStruct definition
// A PkdStruct is an ordered map with an associated width for each entry.
// This is implemented as a wrapper (composition) built 
// on top of a built-in JS data-structure, Map.
// This data-structure is useful to represent data such as fields in a register, signals 
// concatenated onto a FIFO bus, opcodes in an instruction, fields in a packet, etc.

// Constructor
function PkdStruct( struct, options ) {
	if(!(this instanceof PkdStruct))
		return new PkdStruct( struct, options );  // To handle calling without 'new' keyword

	// Set default for arguments
	const opts			= options || {};
	this._endian		= opts.endian || "big";
	this._unpack		= opts.unpack === undefined ? true : opts.unpack;

	// Set start and end of the PkdStruct instance
	// Determine which of the two to hold and let the other vary as entries as added	
	// When both start and end are specified only one of the two is copied depending on endianness 
	// and the other is computer and set during initialization of _core
	let start, end;

	if(("start" in opts) && ("end" in opts)) {
		this._hold							= this._endian === "big" ? "start" : "end";
		[ start, end ]						= this._endian === "big" ? [ opts.start, opts.start+1 ] : [ opts.end-1, opts.end ];

	} else if("start" in opts) {
		this._hold							= "start";
		[ start, end ]					 	= [ opts.start, opts.start+1 ];

	} else {
		this._hold							= "end";
		end									= opts.end || 0;
		start								= end - 1;
	}

	this._slice			= new Slice({ start, end });
	this._last			= null;						// Store last value passed to this._core.set()
	this._cache			= {};						// Cache last value returned by this._core.get()
	this._initCore(struct || []);					// Initialize core data-structure, an ordered map
}


PkdStruct.prototype._initCore		= function (struct) {
	this._core			= new Map();

	for( let i=0; i<struct.length; i++) {
		const packType					= struct[i].packType || "";

		if(packType) {
			const packEndian			= struct[i].endian || (packType === "array" ? "little" : this._endian);
			this.setPacked( struct[i].name, struct[i].value, packType, packEndian );

		} else {
			this.setWidth( struct[i].name, struct[i].width, struct[i].value );

		}
	}
}


// Define getter for property length on PkdStruct instances
Object.defineProperty( PkdStruct.prototype, "length", {
	get () {
		return this._core.size;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property start on PkdStruct instances
Object.defineProperty( PkdStruct.prototype, "start", {
	get () {
		return this._slice.start;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property end on PkdStruct instances
Object.defineProperty( PkdStruct.prototype, "end", {
	get () {
		return this._slice.end;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


// Define getter for property width on PkdStruct instances (Total width of all entries)
Object.defineProperty( PkdStruct.prototype, "width", {
	get () {
		return this._slice.width;
	},
	enumerable: false,
	configurable: false,
	writeable: false
});


PkdStruct.prototype.setWidth		= function (key, width, value) {
	
	// Expand slice of this instance by width
	this._slice			= this._slice.expand(this._hold, width);

	// Determine end index assuming little endian and this._slice.end is set to 0
	const end			= !this._last							? 0 :
						  this._unpack && this._last.packType	? this._last.value.width + this._last.end :
						  this._last.width + this._last.end;
	const mapEntry		= { end, width, value, packType: "", packEndian: "" };

	this._last			= mapEntry;
	this._core.set(key, mapEntry);

	return this._core.size;
}


PkdStruct.prototype.setPacked		= function (key, value, packType, packEndian) {

	// Unpack value (arrayDef or StructDef) to a packed object if unpack = true
	const options		= this._hold === "end" ? { endian: packEndian, end: this._slice.start+1 } : { endian: packEndian, start: this._slice.end-1 };
	const valueStored	= !this._unpack ? value : packType==="struct" ? new PkdStruct(value, options) : new PkdArray(value, options);
	
	// Expand slice of this instance by width of the packed array
	const width			= this._unpack ? valueStored.width : pkdWidth(packType, value);
	this._slice			= this._slice.expand(this._hold, width);

	// Determine end index assuming little endian and this._end is set to 0
	const end			= !this._last							? 0 :
						  this._unpack && this._last.packType	? this._last.value.width + this._last.end :
						  this._last.width + this._last.end;
	const mapEntry		= this._unpack ? { end, value: valueStored, packType, packEndian } : { end, value: valueStored, packType, packEndian, width };

	this._last			= mapEntry;
	this._core.set(key, mapEntry);

	return this._core.size;
}


PkdStruct.prototype.clear			= function () {
	this._core.clear();
	this._last			= null;
	this._cache			= {};
	
	let [ start, end ]	= this._hold === "start" ? [ this._slice.start, this._slice.start+1 ] : [ this._slice.end-1, this._slice.end ];
	this._slice			= new Slice({ start, end });
}


PkdStruct.prototype._getCached		= function (key) {
	if(key in this._cache)
		return this._cache[key];

	const entry			= this._core.get(key);
	this._cache			= {};
	this._cache[key]	= entry;

	return entry;
}


PkdStruct.prototype.get				= function (key) {
	const entry			= this._getCached(key) || {};
	return entry.value;
}


PkdStruct.prototype.packType		= function (key) {
	const entry			= this._getCached(key) || {};
	return entry.packType;
}


PkdStruct.prototype.packEndian		= function (key) {
	const entry			= this._getCached(key) || {};
	return entry.packEndian;
}


PkdStruct.prototype.has				= function (key) {
	return this._core.has(key);
}


PkdStruct.prototype.slice			= function (key) {
	const entry			= this._getCached(key);

	if(!entry)
		return undefined;

	return this._sliceByEntry(entry);
}


PkdStruct.prototype.slices			= function* () {
	for( const entry of this._core.values() )
		yield this._sliceByEntry(entry);
}


PkdStruct.prototype._sliceByEntry	= function (entry) {
	const end			= entry.end;
	const width			= entry.packType && this._unpack ? entry.value.width : entry.width;
	const start			= width + end - 1;
	const slice			= { start, end };						// This is the slice assuming zero offset and little endianness

	return this._endian === "little" ? (new Slice(slice)).shift(this._slice.end) : (new Slice(slice)).switchEndian(this.width).shift(this._slice.end);
}


PkdStruct.prototype.valueWidth			= function (key) {
	const entry			= this._getCached(key);

	if(!entry)
		return 0;

	return entry.packType && this._unpack ? entry.value.width : entry.width;
}


PkdStruct.prototype.keys				= function () {
	return this._core.keys();
}


PkdStruct.prototype.values				= function* () {
	for( const entry of this._core.values() )
		yield entry.value;
}


PkdStruct.prototype.entries				= function* () {
	for( const [ key, entry ] of this._core )
		yield [ key, entry.value, this._sliceByEntry(entry), entry.packType, entry.packEndian ];
}


PkdStruct.prototype[Symbol.iterator]	= function* () {
	for( const [ key, entry ] of this._core )
		yield [ key, entry.value, this._sliceByEntry(entry) ];
}


// Function to envelope an expression (string) with braces
function envelope(lBrace,rBrace,expr) {
	return lBrace+expr+rBrace;
}


// Function that generates an array ( of numbers) of length = argument 'size'
// starting from argument 'start' and in steps of argument 'step'
function range(size,start=0,step=1) {
	return [...Array(size).keys()].map(i => i*step + start);
}


// Function that clubs elements with the same index together into a single array
// Returns a 2D array with as many rows as the length of the individual arrays
// and as many columns as the number of input arrays.
function zip(...arrays) {
	const len	= Math.min(...arrays.map(array => array.length));	// Shortest array length
	return	range(len)
			.map(function (i) {
				// For each index, concatenate the corresponding elements at
				// that index in each array.
				return arrays.reduce((result,array) => result.concat(array[i]),[]);
			});
}


// Function that clubs elements with the same index together into a single array with
// as many elements as the number of arguments.
// An argument can be either an array or an iterator
// Returns an iterator object whose next() method returns the mentioned array as value
function* izip(...args) {
	// Convert any arrays in the arguments to iterators
	const iterators			= args.map( x => Array.isArray(x) ? x.values() : x );

	let done				= false;
	
	while(!done) {
		let result			= [];
		for ( let i=0; i < iterators.length; i++ ) {
		  const nextObj		= iterators[i].next();
		  const value		= nextObj.value;
		  done				= nextObj.done;

		  if(done)
			break;

		  result.push(value);
		}

		if(!done)
		  yield result;
	}
}


// Function that returns an iterator to fetch elements of an
// array in reverse order
function* reversed(x) {
	for ( let i=x.length-1; i>=0; i-- )
		yield x[i];
}


// Function that performs a cross product of all input arrays
// If the input arrays are of length p,q,r..., the output array
// is a 2D array with p X q X r X ... rows and as many columns as
// the number of input arrays.
function cross(...arrays) {
	if(arrays.length===1)
		return arrays[0].map(i => [i]);

	// Append elements from first array to cross of remaining arrays recursively
	return arrays[0].reduce(function(result,i) {
		const arraysXi			= cross(...arrays.slice(1)).map(array => [i,...array]);
		return result.concat(arraysXi);
	},[]);
}


// Function that returns a copy of the original array but with duplicate
// elements removed. When the optional second argument function, fn, is 
// specified, the resulting array will have only those elements for which
// the function returns unique values.
function uniquify(a, fn = x => x) {
	const seen			= {};
	const result		= [];

	for(let i=0; i<a.length; i++) {
		const value		= fn( a[i] );

		if(!seen[value]) {
			result.push(a[i]);
			seen[value]	= true;
		}
	}

	return result;
}


// Function that generates a cumulative sum of numbers in an array
function accumulate(array) {
	return range(array.length).map( i => array.slice(0,i+1).reduce((result,x) => result+x, 0) );
}


// Function to return the last element of an array
function lastEntry(array) {
	return array.length === 0 ? null : array[array.length - 1];
}


// Returns the last element for which fn(x) returns true, where 
// x is an element of the array. If the second argument in the 
// the function call is skipped, the function simply returns
// the last element in the array
function findLast( array, fn=x => true ) {
	for( let i=array.length-1; i>-1; i--) {
	  if( fn(array[i]) )
		return array[i];
	}
	return undefined;
}


// Functional Programming utilities:

// Function for partial application of a set of arguments to an
// input function
function partial(fn,...initArgs) {
	return (...restArgs) => fn(...initArgs,...restArgs);
}


// General currying function
function curry(fn) {
	function curriedFn(...initArgs) {
		if((initArgs.length>=fn.length) || (initArgs.length==0)) {
			return fn(...initArgs);
		} else {
			function g(...restArgs) {
				return (initArgs.length+restArgs.length >= fn.length) ? fn(...initArgs,...restArgs) : curriedFn(...initArgs,...restArgs);
			}
			return g;
		}
	}
	return curriedFn;
}


// Function to flip the first two arguments of a function
// This is typically used in tandem with the curry function
function flip(fn) {
	return (a,b,...restArgs) => fn(b,a,...restArgs);
}


// Function to create a composed function from a given set of functions
// If f = compose( f1, f2, f3 ), then f(x) is same as calling f1(f2(f3(x)))
function compose(...fns) {
	return x => fns.reduceRight((res,f) => f(res),x);
}


// Function that creates a composed function by piping a set of functions
// If f = compose( f1, f2, f3 ), then f(x) is same as calling f3(f2(f1(x)))
function pipe(...fns) {
	return x => fns.reduce((res,f) => f(res),x);
}


// Function to memoize (cache results) of an input function
// Input function must be a pure function
function memoize(fn) {
	let cache				= {};

	return function (...args) {
		const key			= JSON.stringify(args);
		if(key in cache)
			return cache[key];

		const result		= fn(...args);
		cache[key]			= result;
		return result;
	}	
}


// Tree parsing utilities
// This function returns an object with useful methods/functions to parse a tree data-structure. A tree 
// is composed of nodes. The node object or tree is defined as having the folloing structure:
// tree/root = 
// { 
//   value: an object,
//	 children[]: An array of nodes. Empty for leaf nodes
// }
function createTreeParser (root) {
	// Function that returns an iterator that returns node values
	// by traversing the tree in depth-first order
	function* traverse(root) {
		if(root) {
			yield root;
	
			for(let i=0; i<root.children.length; i++)
				for( const node of traverse(root.children[i]) )
					yield node;
		}
	}


	function* values() {
		for(const node of traverse(root))
			yield node.value;
	}


	function forEach(fn) {
		for(const node of traverse(root))
			fn(node.value);
	}


	function findNode(root, fn) {
		for(const node of traverse(root))
			if(fn(node))
				return node;
	}


	function find(root, fn) {
		for(const value of values())
			if(fn(value))
				return value;
	}


	function findPath(root, fn) {
		const result		= [];

		if(root) {
			if(fn(root.value))
				return [root.value];

			result.push(root.value);

			for(const node of root.children) {
				const path	= findPath(node, fn);
				if(path.length)
					return result.concat(path);
			}
	
			result.pop(); // Comment this to return undefined if path not found
		}

		return result;	// Comment this to return undefined if path not found
	}


	return {
		find				: find.bind(null, root),
		findPath			: findPath.bind(null, root),
		findNode			: findNode.bind(null, root),
		forEach, 
		[Symbol.iterator]	: values
	};
}


function generateObjects(param_array, key, flag, param_result)
{
    Object.keys(param_array).forEach(function(obj_key)
    {
        if (obj_key === key )
        {
            flag.status1 = "found";
            var instance_count = param_array[obj_key];
            delete param_array[obj_key];                              //Delete NoInstances property
            for (var i=0; i < instance_count; i++)
            {
                var copyToPushObj=(JSON.stringify(param_array)).replace(/#/g, i);
                param_result.push(JSON.parse(copyToPushObj));
            }
        }
        
        else if (typeof param_array[obj_key] === "object")
        {
          if (!Array.isArray(param_array[obj_key]))
            {   
                if (!(JSON.stringify(param_array)).match(/#/g))
                { 
                    //console.log("not array if loop"); 
                    //console.log(param_array); 
                    param_result.push(param_array);
                }
                else 
                {
                    generateObjects(param_array[obj_key], key, flag, param_result);
                }
            }
        }
    });
    if (flag.status1 === "found")
    {
        return param_result;
    }
    else 
    {
        return param_result = [];
    }
}


// Function that parses the input array signals, and deletes any
// signals of illegal width:
function removeIllegalWidthSignals(signals) {

    var sigOuts             = [];
    var numSignals          = signals.length;

    for(var s=0; s<numSignals; s++) {
        var regxMatches;
        if(signals[s].match(/^\s*-?\d+'[hb]-?[a-f0-9A-F]+\s*$/)) {     // Remove constants such as 0'h0
            regxMatches     = signals[s].match(/\s*(-?\d+)'[hb]-?[a-f0-9A-F]+\s*/);
            var sizeOfK     = JSON.parse(regxMatches[1]);
            if(sizeOfK > 0) {
              sigOuts.push(signals[s]);
            }
        } else if(signals[s].match(/^\s*\w+\[-?\d+\:-?\d+\]\s*$/)) {  // Remove signals such as fldX[-1:0] 
            regxMatches     = signals[s].match(/\s*\w+\[(-?\d+)\:(-?\d+)\]\s*/);
            var upper_index = JSON.parse(regxMatches[1]);
            var lower_index = JSON.parse(regxMatches[2]);
            if(upper_index >= lower_index) {
              sigOuts.push(signals[s]);
            }
        } else if(signals[s].match(/^\s*\w+\[-?\d+\]\s*$/)){     // Check for negative indices in signals with only one index
            regxMatches     = signals[s].match(/\s*\w+\[(-?\d+)\]\s*/);
            var index       = JSON.parse(regxMatches[1]);
            if(index >= 0) {
              sigOuts.push(signals[s]);
            }
        } else if(signals[s].match(/^\s*\w+\s*$/)){     // Always push signals with no indices
            sigOuts.push(signals[s]);
        } else {
            console.log("Error: Undefined signal = "+signals[s]+" detected in function removeIllegalWidthSignals() in signals array = \n"+signals+"\n");
            throw "ERROR - removeIllegalWidthSignals";
        }
    }

    return sigOuts;
}


// Function that parses the input array signals, and deletes any
// signals of illegal width, and returns a Verilog concatenated 
// vector string removing double-quotes and replacing [ and ] with { and } resp.:
function getVlogConcatSignals(signals) {

    var vlogConcatSignals   = "";
    var legalSignals        = removeIllegalWidthSignals(signals);

    vlogConcatSignals       = JSON.stringify(legalSignals);             // Stringify the whole array.
    vlogConcatSignals       = vlogConcatSignals.replace(/"/g,"");       // Remove double-quotes.
    vlogConcatSignals       = vlogConcatSignals.replace(/^\s*\[/g,"{"); // Replace leading  '[' by '{'
    vlogConcatSignals       = vlogConcatSignals.replace(/\]\s*$/g,"}"); // Replace trailing ']' by '}'

    return vlogConcatSignals;
}


// Function to create a muxOrTree with a select input and different condition-expressions
// as inputs
function genMuxOrTree(width,select,inputExpressions) {
	const n						= inputExpressions.length;
	if(n===0) {
		return width+"'h0";
	} else if(n===1) {
		return inputExpressions[0];
	} else {
		const selWidth			= log2ceil(n);
		const selectCompares	= range(n).map(i => "("+select+" == "+selWidth+"'h"+i.toString(16)+")",this);
		const inputsBraced		= inputExpressions.map(expression => "("+expression+")");
		const minterms			= zip(selectCompares,inputsBraced).map(([sel,inp]) => "("+sel+" & "+inp+")");
		return minterms.join(" | ");
	}
}


// CSR-related functions
// Function to lookup module name of a given instance in an instanceMap
function instance2Module(instanceMap,instance) {
	return Object.keys(instanceMap).find(module => instanceMap[module].includes(instance));
}


// Functin to get attrFiles from module names
function module2Attr(path,module) {
	return path+"/"+module+".attr";
}


// Function to scour attr files for the csr object and return it
// (Returns undefined if csr object isn't found)
function attr2Csr(attrFile) {
	return readJSON(attrFile).attributes.csr;
}


function attr2NodeId(attrFile) {
	const attributes		= readJSON(attrFile).attributes;
	return attributes.nodeId === undefined ? attributes.id : attributes.nodeId;
}


// Function to convert a spaceblock to register-address map i.e. a dictionary
// object with register names as keys and full addresses as values
function sb2RegAddrMap(base,sb) {
	return sb.registers.reduce(function(result,reg) {
		return Object.assign(result,{[reg.name]: base+sb.baseAddress+reg.addressOffset});
	},{});
}


// Function to create a single CSR from multiple CSRs. This function concatenates spaceBlocks
// inside all the CSR objects, and modifies their base-Addresses such that it returns a single
// address-map with unique addresses for all the registers
// Arguments:
// csrs - Array of CSRs in the same order as baseAddresses or object with ids as keys value as csrs
// addressWidth - Address width of merged CSR. Optional.
// width - Width of registers in the CSR. Optional. Defaults to 32.
// baseAddresses - Address offset of each CSR in the merged address space 
// (in the same order as csrs). Optional.
function mergeCsr(addrMap, csrMap, width=32) {
	const blockIds				= addrMap.blockIds;
	const offsets				= addrMap.baseAddresses("bigInt");
	const numBlocks				= blockIds.length;

	if(numBlocks===0)
		return null;

	// Aggregate spaceblocks in every CSR and modify their baseAddresses
	const allSpaceBlocks		= [];

	//for( const [ id, value ] of lookup ) {
	for( let i=0; i<numBlocks; i++) {
		if(!(blockIds[i] in csrMap))
			throw new Error("No CSR found for ID = "+blockIds[i]+" in csrMap");

		const spaceBlocks		= csrMap[blockIds[i]].spaceBlock;
		const numSpaceBlks		= spaceBlocks.length;

		for(let j=0; j<numSpaceBlks; j++) {
			const baseAddress					= offsets[i] + BigInt( spaceBlocks[j].baseAddress ); 
			const modifiedSpaceBlock			= { ...spaceBlocks[j], baseAddress: Number(baseAddress) };
			allSpaceBlocks.push(modifiedSpaceBlock);
		}
	}

	// Sort spaceBlocks in ascending order of their baseAddresses
	allSpaceBlocks.sort( (x,y) => x.baseAddress - y.baseAddress );

	return { addressWidth: addrMap.addressWidth, width, spaceBlock: allSpaceBlocks };
}


// Function to create an address map object with data + behavior
// An address map can be created with 
// 1. fullSize			= Size of the entire address-space as a power of 2.
// 2. sizes				= Array of sizes of address-regions in powers of 2.
// 3. Optionally can specify offsets and blockIds
// blockIds				= Array of IDs of blocks in corresponding address-regions.
// offsets				= Array of numbers (start offsets of each region)
function createConfigAddressMap(fullSize, sizes, options={}) {

	// Local helper functions
	// Function to generate a mask value from the size of 
	// an address-space allocated to a block
	function size2Mask(size) {
		const delta					= fullSize - size;
		const nOnes					= (BigInt(1) << BigInt(delta)) - BigInt(1);		// All ones for lowest delta bits
		const mask					= nOnes << BigInt(size);						// Shift all ones to uppermost delta bits
		return mask;
	}


	// Function to compute address-offsets given only sizes of the block
	// The function computes offsets by accumulating sizes and rounding-off
	// the offsets to the nearest power of 2 (aligned-offsets)
	function accumulateSizes(maxOffset, sizes) {
		const result				= [];
		let offset					= BigInt(0);

		try{
		  sizes.forEach( function (size) {
			if(offset >= maxOffset)
				throw new Error("Accumulated offset = "+offset+" exceeds or has reached max-address of the address map = "+maxOffset);

			const sizePow2			= BigInt(1) << BigInt(size);
			const mask				= size2Mask(size);
			const unaligned			= offset & ~mask;
			const alignedOffset		= unaligned ? (offset & mask) + sizePow2 : offset;
			result.push(alignedOffset);
			offset					= alignedOffset + sizePow2;
		  });
		
		} catch(err) {
		  throw new Error("Computing offsets by accumulating sizes failed. "+err+". Sizes = "+sizes+" (powers of 2), full-size = "+fullSize+", computed offsets = "+result);	
	
		}

		return result;
	}


	// Function that converts baseAddress (Verilog constant) to an offset (bigInt)
	function convBaseAddrToOffset( x ) {
		const result				= parseVlogConst(x).value;
		
		if(result >= maxOffset)
			throw new Error("BaseAddress "+result+", is outside the max-address range of 0 to "+(maxOffset-BigInt(1))+", fullSize = "+fullSize);

		return result;
	}


	// Function properties
	// Returns a list of baseAddresses. Each baseAddress is a Verilog constant literal string
	function baseAddressesFunc( width=12, radix=16 ) {
		if(width < fullSize)
			throw new Error("Address-Bus-Width = "+width+" bits are not sufficient to address the entire address-space of size = "+fullSize);

		const value2BaseAddress		= value => genVlogConst({  width, radix, value: value.offset  });
		return [...core.values()].map( value2BaseAddress );
	}

	
	// Returns a list of baseMasks. Each baseMask is a Verilog constant literal string
	function baseMasksFunc( width=12, radix=16 ) {
		if(width < fullSize)
			throw new Error("Address-Bus-Width = "+width+" bits are not sufficient to address the entire address-space of size = "+fullSize);

		const value2Size			= value => value.size;
		const mask2VlogConst		= mask	=> genVlogConst({ width, radix, value: mask });
		const value2BaseMask		= compose( mask2VlogConst, size2Mask, value2Size );
		return [...core.values()].map( value2BaseMask );
	}


	// Function to merge an object/associtive-array of CSRs
	function mergeCSR(csrMap) {
		const addressBlocks			= [];

		// Aggregate address-blocks in every CSR, while modifying their baseAddresses
		for( const [ key, value ] of core ) {
			if(!csrMap[key]) 
				throw new Error("No CSR found for ID = "+key+" in csrMap");
		
			csrMap[key].spaceBlock.forEach( addrBlock => {
				const baseAddress					= value.offset + BigInt( addrBlock.baseAddress );
				const name							= !addrBlock.name ? key : key+"_"+addrBlock.name;
				const modifiedAddrBlock				= Object.assign({}, addrBlock, { name, baseAddress: Number(baseAddress) });
				addressBlocks.push( modifiedAddrBlock );
			});
		};

		// Sort addressBlocks in ascending order of their baseAddresses
		addressBlocks.sort( (x,y) => x.baseAddress - y.baseAddress );

		return addressBlocks.length === 0 ? null : { addressWidth: fullSize, width:32, spaceBlock: addressBlocks };
	}


	// Converts state to a JSON object, that can be used to create a new copy
	// of the address map object
	function toJSON() {
		return {
			fullSize,
			"sizes"					: [...core.values()].map( value => value.size ),
			"offsets"				: [...core.values()].map( value => Number(value.offset) ),
			"blockIds"				: [...core.keys()]
		};
	}


	// Function to protect the .get() method of core Map data-structure
    function  safeGet(id) {
		if(!core.has(id))
			throw new Error("Block ID = "+id+" not found in address map.");

		return core.get(id);	
	}


	// Compute private local data	
	const maxOffset					= BigInt(1) << BigInt(fullSize);
	const numBlocks					= sizes.length;
	const blockIds					= options.blockIds || range( numBlocks );
	const offsets					= options.offsets			? options.offsets.map(BigInt)						:
									  options.baseAddresses		? options.baseAddresses.map( convBaseAddrToOffset ) :
									  accumulateSizes(maxOffset, sizes);

	// Initialize core (Map data-structure)
	const core						= new Map();

	for( let i=0; i < numBlocks; i++) {
		const key					= blockIds[i];
		const value					= { size: sizes[i], offset: offsets[i] };
		core.set(key, value);
	};

	// Create return object with data-properties and function-properties
	const dataProps					= { fullSize };
	const funcProps					= {
			mergeCSR,
			toJSON,
			baseAddresses			: baseAddressesFunc,
			baseMasks				: baseMasksFunc,
			blockIds				: () => [...core.keys()],
			sizes					: () => [...core.values()].map( value => value.size ),
			size					: id => safeGet(id).size
	};

	return Object.assign( {}, dataProps, funcProps );
}


// Function to create an address map from base-masks instead
// of from sizes.
// baseMasks			= Array of Verilog string constant literals (mask for each region)
function createConfigAddressMapFromMasks(fullSize, masks, options) {

	// Function to compute the size (in bits) of an address-space 
	// allocated to a block given the address-mask
	function mask2Size(mask) {
		const bigOne				= BigInt(1);
		const fullMask				= (bigOne << BigInt(fullSize)) - bigOne;
		let invMask					= ~mask & fullMask;
		let size					= 0;
	
		while(invMask & bigOne) {
			size					+= 1;
			invMask					= invMask >> BigInt(1);
		}

		return size;
	}


	// Composed helper functions
	const vlogMask2Size				= compose( mask2Size, x => x.value, parseVlogConst );  // if f = compose(f1, f2, f3), then f(x) = f1( f2( f3(x) ) ) 
	const sizes						= baseMasks.map( vlogMask2Size );	// This converts an array of baseMasks to their equivalent sizes
	return createConfigAddressMap(fullSize, sizes, options);
}


// JSON structure to describe a state machine
// ==========================================
// "enums" field is an array of unique string, each string represents a state, and the first element in the "enums" array is the initial state.
// "trans" field is an array of object, each object represents a state transition function encoded as from:<state> to:<state> cond: [array of <boolean expression>].
// var fsm = 
// {
//     enums: ['IDLE', 'SEND_DTW', 'WAIT_DTWRSP', 'DEALLOC'],
//     trans: [
//         {from: 'IDLE',         to: 'SEND_DTW',    cond: ['utt_init & evicted_cache_isDirty']},
//         {from: 'IDLE',         to: 'DEALLOC',     cond: ['utt_init & ~evicted_cache_isDirty']},
//         {from: 'SEND_DTW',     to: 'WAIT_DTWRSP', cond: ['all_dtws_sent', 'dtwupd_rsp_rcvd']},
//         {from: 'WAIT_DTWRSP',  to: 'IDLE',        cond: ['dtwupd_rsp_rcvd']},
//         {from: 'DEALLOC',      to: 'IDLE',        cond: ['']},
//     ],
//     onehot: 'yes',
//     prefix: 'sym_',
//     sverilog: 'yes'
// }
//
// Function that parses the state machine description JSON structure to generate combinatorial Verilog RTL code.
//
function string_genStateMachine (fsm) {

    var onehot;
    var sverilog;
    var nState;
    var wState;
    var nTrans;
    var nCond;
    var str_state = fsm.prefix + 'state';
    var str_nxt_state = fsm.prefix + 'nxt_state';
    var str_enum = fsm.prefix + 'enum_';
    var str_trans_from_array = [];
    var str_trans_to_array = [];
    var str_trans_cond_array = [];
    var str_cond;
    var result = '';
    var i;
    var j;

    onehot = (fsm.onehot === 'yes') ? true : false;
    sverilog = (fsm.sverilog === 'yes') ? true : false;
    nState = fsm.enums.length;
    wState = onehot ? nState : Math.ceil(Math.log(nState)/Math.LN2);
    nTrans = fsm.trans.length;
    //
    // build string for wire declaration for state and nxt_state enums and decodes
    //
    for (i=0; i < nState; i++) {
        j = onehot ? 1 << i : i;
        result += 'wire ['+ (wState-1) + ':0] ' + str_enum + fsm.enums[i] + ' = ' + wState + "'d" + j + ';\n';
    }
    result += 'wire ['+ (wState-1) + ':0] ' + str_state + ';\n';
    result += 'reg  ['+ (wState-1) + ':0] ' + str_nxt_state + ';\n';
    for (i=0; i < nState; i++) {
        result += 'wire '+ str_state + '_is_' + fsm.enums[i] + ' = ';
        if (onehot) {
            result += str_state + '[' + i + ']' + ';\n';
        } else {
            result += '(' + str_state + ' == ' + str_enum + fsm.enums[i] + ')' + ';\n';
        }
    }
    for (i=0; i < nState; i++) {
        result += 'wire '+ str_nxt_state + '_is_' + fsm.enums[i] + ' = ';
        if (onehot) {
            result += str_nxt_state + '[' + i + ']' + ';\n';
        } else {
            result += '(' + str_nxt_state + ' == ' + str_enum + fsm.enums[i] + ')' + ';\n';
        }
    }
    result += "\n";
    //
    // build string for wire declaration for state transitions
    //
    for (i=0; i < nTrans; i++) {
        str_trans_from_array.push(fsm.trans[i].from);
        str_trans_to_array.push(fsm.trans[i].to);
        str_cond = '';
        nCond = fsm.trans[i].cond.length;
        for (j=0; j < nCond; j++) {
            str_cond += '(' + fsm.trans[i].cond[j] + ')';
            str_cond += (j == nCond - 1) ? '' : ' | ';
        }
        str_trans_cond_array.push(str_cond);
    }
    for (i=0; i < nTrans; i++) {
        result += 'wire trans__' + str_trans_from_array[i] + '__' + str_trans_to_array[i] + ' = ' + 
                  str_state + '_is_' + str_trans_from_array[i] + ' & ' + 
                  (str_trans_cond_array[i] === "()" ? "1'b1" : str_trans_cond_array[i]) + ';\n';
    }
    result += "\n";
    //
    // build string for state transition case statements
    //
    result += sverilog ? "always_comb\n" : "always @(*)\n";
    result += "case (1'b1)\n"
    for (i=0; i < nTrans; i++) {
        result += "    trans__" + str_trans_from_array[i] + "__" + str_trans_to_array[i] + " : " + str_nxt_state + " = " + str_enum + str_trans_to_array[i] + ";\n";
    }
    result += "    default " + str_nxt_state + " = " + str_state + ";\n";
    result += "endcase"
    return result;
};

function getRdyVldPipeCtlInterface(width,depth,pipeForward,pipeBackward,circular,simplePipe,exposeValids,protectionStyle,protectionInterface,clkGateOn,exposePointers,exposeEmpty,exposeFull,addState) {
    var answer = {};
    var i = 0;
    var prot_signals = {};
    var prot_name = "";
    var prot_keys = [];

    if (depth > 0) {
        if (clkGateOn) {
            answer['gated_clk'] = -1;
        } else {
            answer['clk'] = -1;
        }
        answer['reset_n'] = -1;
        answer['dp_clk_en'] = depth;
        if (!pipeForward && !simplePipe) {
            answer['bypass'] = 1;
        }
        
        if (circular && (depth > 1)) {
            answer['rd_mux_sel'] = depth;
            if (exposeEmpty && !simplePipe) answer['pipe_empty'] = 1;
            if (exposeFull && !simplePipe) answer['pipe_full'] = 1;
            if (exposePointers && !simplePipe) {
                answer['rd_ptr'] = depth;
                answer['wt_ptr'] = depth;
            }
            if ((addState > 0)  && !simplePipe) {
                answer['in_state'] = -addState;
                answer['out_state'] = addState;
            }
        } else if (!simplePipe) {
            if (depth > 1) {
                answer['wr_mux_sel'] = depth-1;
            }
        }

        
        if (exposeValids) {
            answer['valids'] = depth;
        }

        if (protectionStyle !== "") {
            prot_name = protectionInterface.name;
            prot_signals = protectionInterface.signals;
            prot_keys = Object.keys(protectionInterface.signals);
            for (i = 0; i < prot_keys.length; i++) {
                answer[prot_name+prot_keys[i]] = prot_signals[prot_keys[i]];
            }
        }
    }
    answer['in_valid'] = -1;
    answer['in_ready'] = 1;
    answer['out_valid'] = 1;
    answer['out_ready'] = -1;
    answer['empty'] = 1;

    return answer;
}

function getRdyVldPipeDpInterface(width,depth,pipeForward,pipeBackward,circular,simplePipe,exposeGuts,clkGateOn) {
    var answer = {};
    
    if (depth > 0) {
        if (clkGateOn) {
            answer['gated_clk'] = -1;
        } else {
            answer['clk'] = -1;
        }
        answer['reset_n'] = -1;
        answer['dp_clk_en'] = -depth;

        if (!pipeForward && !simplePipe) {
            answer['bypass'] = -1;
        }

        if (circular && (depth > 1)) {
            answer['rd_mux_sel'] = -depth;
        } else if (!simplePipe) {
            if (depth > 1) {
                answer['wr_mux_sel'] = -(depth-1);
            }
        }

        if (exposeGuts && (depth > 0)) {
            answer['guts'] = width*depth;
        }
    }
    answer['in_data'] = -width;
    answer['out_data'] = width;

    return answer;
}

function generateCTLInterface(atuParameters,userLib) {
    if(atuParameters.interfaces == null || atuParameters.interfaces == undefined) {
	console.log('ERROR: : generateCTLInterface No interfaces parameter in ATU Parameter Object');
        throw "ERROR - generateCTLInterface";
    }
    
    var ctlInterfaceObject;
    var initiator;
    
    if(atuParameters.interfaces.axiInterface != undefined) {
	if(atuParameters.interfaces.axiInterface.direction == 'slave') {
//	    console.log("Generating CTL Interface For AXI Init");
	    ctlInterfaceObject = generateCTLInterfaceFromAxiI(atuParameters,userLib);
	} else {
//	    console.log("Generating CTL Interface For AXI Targ");	    
	    ctlInterfaceObject = generateCTLInterfaceFromAxiT(atuParameters,userLib);
	}	    
    } else if (atuParameters.interfaces.apbInterface != undefined) {
	if(atuParameters.interfaces.apbInterface.direction == 'slave') {
//	    console.log("Generating CTL Interface For APB Init");	    
	    ctlInterfaceObject = generateCTLInterfaceFromApbI(atuParameters,userLib);
	} else {
//	    console.log("Generating CTL Interface For APB Targ");	    
	    ctlInterfaceObject = generateCTLInterfaceFromApbT(atuParameters,userLib);
	}	    
    } else if (atuParameters.interfaces.ctlReqInterface != undefined) {
	if(atuParameters.interfaces.ctlReqInterface.direction == 'slave') {
//	    console.log("Generating CTL Interface For CTL Init");	    
	    ctlInterfaceObject = generateCTLInterfaceFromCtlI(atuParameters,userLib);
	} else {
//	    console.log("Generating CTL Interface For CTL Targ");	    
	    ctlInterfaceObject = generateCTLInterfaceFromCtlT(atuParameters,userLib);
	}
    }
        
    return ctlInterfaceObject;
}

function generateCTLInterfaceFromAxiI(atuParameters,userLib) {
    // Grab needed widths from the packet.
    var atpReqParams					  = userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpReqInterface.params);
    var atpReqPktParams                   = userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpReqInterface.pktDef.params);
    var axiParams                         = userLib.symLib.symLoadHierJason(atuParameters.interfaces.axiInterface.params);
	
    var linkPktReqFunc                    = new userLib[atuParameters.interfaces.atpReqInterface.pktDef.packet];
    var linkPktReq                        = linkPktReqFunc.getPacketArray(atpReqPktParams);

	// Packet field width params needed to compute a sub-set of CTL signal width params
	var reqPkt							  = new userLib.symLib.symCsr.PktArrayQuery(atpReqParams.wBus, linkPktReq);
    var wMaxBurstSize                     = reqPkt.hWidth('H_txn_hdr_maxbsize');
    var wPktDPErr                         = reqPkt.dWidth('C_err');

    // Grab AXI Interface. 
    var axiInterface                      = {};
    var axiInterfaceFunc                  = new userLib["InterfaceAXI"];
    axiInterface.signals                  = axiInterfaceFunc.getSignalsBundle(axiParams);
    var axiInterfaceName                  = atuParameters.interfaces.axiInterface.name;

    // Set common layer name.      
    var ctlReqInterfaceName               = 'ctl_req_';
    var ctlRespInterfaceName              = 'ctl_resp_';
    
    // Add userMap entries for user, len bits.
    const wAxiDataB                       = (axiParams.wData)/8;
    const logwAxiDataB                    = Math.log2(wAxiDataB);
    const padSource                       = logwAxiDataB===0 ? [] : [logwAxiDataB+"'h0"];
    const sourceLen                       = ["ax_len"].concat(padSource).join(",");

	function atomicToLockMapping( wLock, name ) {
		return  wLock === 2 ? ["1'h0", name+"[1]", name+"[1]", name+"[0]", "4'h0"].join(",")	:
				wLock === 1 ? ["3'h0", name, "4'h0"].join(",")	:
				"3'h0,1'h0,4'h0";
	}

    const userMapN2C                      = atuParameters.nativeToCommon.map(function(x) {
                                                                const source            = x.source.replace(/[{}]/,"");
                                                                const destination       = x.destination;
                                                                const sChannel          = ("sChannel" in x) ? "sel"+x.sChannel : "default";
                                                                return {source, destination, sChannel};
                                                          });
	const atomicToLock					  = atomicToLockMapping.bind(null, atuParameters.interfaces.axiInterface.params.wLock);
    var userMapReq                        = [
                                                                { destination: ctlReqInterfaceName+"len", source: sourceLen, sChannel: "default" },
                                                                { destination: ctlReqInterfaceName+"txn_maxBurstSize", source: wMaxBurstSize+"'d"+logwAxiDataB, sChannel: "sel0" },
                                                                { destination: ctlReqInterfaceName+"txn_maxBurstSize", source: wMaxBurstSize+"'d"+logwAxiDataB, sChannel: "sel1" },
                                                                { destination: ctlReqInterfaceName+"txn_atomic", source: atomicToLock("ar_lock"), sChannel: "sel1" },
                                                                { destination: ctlReqInterfaceName+"txn_atomic", source: atomicToLock("aw_lock"), sChannel: "sel0" },
                                                                { destination: ctlReqInterfaceName+"txn_atomic", source: atomicToLock("ax_lock"), sChannel: "default" },
																{ destination: ctlReqInterfaceName+"dp_err", source: wPktDPErr+"'d0", sChannel: "default" }
                                                          ].concat(userMapN2C);

    var userMapRsp                        = [];

    const axi2Ctl                         = new userLib.AXI2CTL(axiInterface.signals,axiInterfaceName,userMapReq,userMapRsp);

    var ctlInterfaceObject = {};

    ctlInterfaceObject.ctlReqInterface   = axi2Ctl.ctlReqInterface("master",ctlReqInterfaceName);
    ctlInterfaceObject.ctlRespInterface  = axi2Ctl.ctlRespInterface("slave",ctlRespInterfaceName);
    
    return ctlInterfaceObject;
}

function generateCTLInterfaceFromApbI(atuParameters,userLib) {
    // Grab needed widths from the packet.
    var apbParams                         = userLib.symLib.symLoadHierJason(atuParameters.interfaces.apbInterface.params);
    var atpReqParams					  = userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpReqInterface.params);
    var atpReqPktParams                   = userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpReqInterface.pktDef.params);
    var atpRespParams                     = userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpRespInterface.params);
    var atpRespPktParams                  = userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpRespInterface.pktDef.params);

    var linkPktReqFunc                    = new userLib[atuParameters.interfaces.atpReqInterface.pktDef.packet];
    var linkPktReq                        = linkPktReqFunc.getPacketArray(atpReqPktParams);
	var reqPkt							  = new userLib.symLib.symCsr.PktArrayQuery(atpReqParams.wBus, linkPktReq);
	var wDataReq						  = reqPkt.dWidth("F_data");

    var linkPktRespFunc                   = new userLib[atuParameters.interfaces.atpRespInterface.pktDef.packet];
    var linkPktResp                       = linkPktRespFunc.getPacketArray(atpRespPktParams);
	var respPkt							  = new userLib.symLib.symCsr.PktArrayQuery(atpRespParams.wBus, linkPktResp);

    // APB Interface
    var apbInterface                      = {};
    var apbInterfaceFunc                  = new userLib[atuParameters.interfaces.apbInterface.interface];
    apbInterface.signals				  = apbInterfaceFunc.getSignalsBundle(apbParams);
    var apbInterface	              	  = apbInterface.signals;
   
    var nApbSlv                           = Math.abs(apbInterface['psel']);
    var wApbAddr                          = Math.abs(apbInterface['paddr']);
    var wApbData                          = Math.abs(apbInterface['pwdata']);
    var wApbSlvErr                        = Math.abs(apbInterface['pslverr']);
    var wApbStrb                          = Math.abs(apbInterface['pstrb']);
    var wApbProt                          = Math.abs(apbInterface['pprot']);

	// Determine width-adaption ratio
	var widthAdaptionRatio				  = wDataReq === 0 ? 1 : Math.ceil( wApbData/wDataReq );
 
    // CTL params derived from APB/ATP params
    var ctl_req_params = {
        "nCtlFlow" : 1,
        "nCtlPayload" : 1,
        "wCtlType": reqPkt.hWidth("H_msg_type"),
        "wCtlMsgTypeAttr": reqPkt.hWidth("H_msg_type_attr"),
        "wCtlId": reqPkt.hWidth("H_msg_id"),
        "wCtlAddr": wApbAddr,
        "wCtlLen": reqPkt.hWidth("H_msg_len"),
        "wCtlQos": reqPkt.hWidth("H_qos"),
        "wCtlProt": wApbProt,
        "wCtlUser": reqPkt.hWidth("H_msg_user"),
        "wCtlErr": reqPkt.hWidth("H_msg_err"),
        "wCtlBurstType": reqPkt.hWidth("H_txn_hdr_btype"),
        "wCtlBurstSize": reqPkt.hWidth("H_txn_hdr_bsize"),
        "wCtlMaxBurstSize": reqPkt.hWidth("H_txn_hdr_maxbsize"),
        "wCtlRegion": 0,
        "wCtlAttr": reqPkt.hWidth("H_txn_hdr_memattr"),
        "wCtlAtomic": reqPkt.hWidth("H_txn_hdr_atomic"),
        "wCtlOrderingModel": reqPkt.hWidth("H_ordering_model"),
        "wCtlOrderingId": reqPkt.hWidth("H_ordering_id"),
        "wCtlChannelId": reqPkt.hWidth("H_chl_id"),
        "wCtlReqTxnHdr": reqPkt.hWidth("H_txn_hdr"),
        "wCtlData": wApbData,
        "wCtlDataBe": wApbStrb,
        "wCtlDataUser": 0, //widthAdaptionRatio * reqPkt.dWidth("F_user"),
        "wCtlDataErr": 0 //reqPkt.dWidth("C_err") 
    }

   // CTL params derived from APB/ATP params
   var ctl_resp_params = {
        "nCtlFlow" : 1,
        "nCtlPayload" : 1,
        "wCtlOrderingId": reqPkt.hWidth("H_ordering_id"),
        "wCtlTargId" : respPkt.hWidth("H_tid"),
        "wCtlSrcId" : respPkt.hWidth("H_sid"),
        "wCtlId": reqPkt.hWidth("H_msg_id"),
	"wCtlType" : reqPkt.hWidth("H_msg_type"),
	"wCtlUser": respPkt.hWidth("H_msg_user"),
        "wCtlRespStatus": reqPkt.hWidth("H_txn_resp"),
        "wCtlErr": respPkt.hWidth("H_msg_err"),
        "wCtlRespTxnHdr": respPkt.hWidth("H_txn_resp"),
        "wCtlData": wApbData,
        "wCtlDataId": reqPkt.hWidth("H_msg_id"),	
        "wCtlDataBe": 0,
        "wCtlProt": 0 //TODO based on protection
   }

    var ctlInterfaceObject = {};
    
    ctlInterfaceObject.ctlReqInterface   = {
                                            "name"      : "ctl_req_",
                                            "params"    : ctl_req_params,
                                            "direction" : "slave",
                                            "interface" : "InterfaceCTL"
    };
    
    ctlInterfaceObject.ctlRespInterface  = {
                                            "name"      : "ctl_resp_",
                                            "params"    : ctl_resp_params,
                                            "direction" : "master",
                                            "interface" : "InterfaceCTL"
    };
    
    return ctlInterfaceObject;
}

function generateCTLInterfaceFromCtlI(atuParameters,userLib) {
    // SMI params derived from AXI/ATP params
    // Grab needed widths from the packet.
    
    const reqPacket                 = new userLib[atuParameters.interfaces.atpReqInterface.pktDef.packet];
    const reqPacketArray            = reqPacket.getPacketArray(atuParameters.interfaces.atpReqInterface.pktDef.packet);

    var smiReq_params               = userLib.smiLib.pktField2SmiParamTable.pktDef2SmiParams(reqPacketArray);

    const respPacket                = new userLib[atuParameters.interfaces.atpRespInterface.pktDef.packet];
    const respPacketArray           = respPacket.getPacketArray(atuParameters.interfaces.atpRespInterface.pktDef.packet);

    var smiResp_params              = userLib.smiLib.pktField2SmiParamTable.pktDef2SmiParams(respPacketArray); 
    smiResp_params.wSmiDPid         = smiReq_params.wSmiId;
    smiResp_params.wSmiRoute        = 0;

    var wCtlId = smiReq_params.wSmiId;

    var ctlIntReqParams = {};
    var ctlIntRespParams = {};

    if(smiReq_params.wSmiMsgQos == undefined) {
      smiReq_params.wSmiMsgQos = 0;
    }

    if(smiReq_params.wSmiQos == undefined) {
      smiReq_params.wSmiQos = 0;
    }

    if(smiReq_params.wSmiMsgSec == undefined) {
      smiReq_params.wSmiMsgSec = 0;
    }

    if(smiReq_params.wSmiSec == undefined) {
      smiReq_params.wSmiSec = 0;
    }

    ctlIntReqParams.nCtlFlow            = smiReq_params.nSmiVC;
    ctlIntReqParams.nCtlPayload         = smiReq_params.nSmiPayload;
    ctlIntReqParams.wCtlSrcId           = smiReq_params.wSmiSid;
    ctlIntReqParams.wCtlTargId          = 0; //smiReq_params.wSmiTid;
    ctlIntReqParams.wCtlVNid            = smiReq_params.wSmiVNid;
    ctlIntReqParams.wCtlSteer           = smiReq_params.wSmiSteer;
    ctlIntReqParams.wCtlNDP             = smiReq_params.wSmiNDP;
    ctlIntReqParams.wCtlNDPLen          = smiReq_params.wSmiNDPLen;
    ctlIntReqParams.wCtlMultiLabel      = smiReq_params.wSmiMultiLabel;
    ctlIntReqParams.wCtlMultiMask       = smiReq_params.wSmiMultiMask;
    ctlIntReqParams.wCtlPressure        = smiReq_params.wSmiPressure;
    ctlIntReqParams.wCtlPoison          = smiReq_params.wSmiPoison;
    ctlIntReqParams.wCtlType            = smiReq_params.wSmiType;
    ctlIntReqParams.wCtlMsgTypeAttr     = smiReq_params.wSmiTypeAttr;
    ctlIntReqParams.wCtlId              = smiReq_params.wSmiId;
    ctlIntReqParams.wCtlAddr            = smiReq_params.wSmiAddr;
    ctlIntReqParams.wCtlLen             = smiReq_params.wSmiLen;
    ctlIntReqParams.wCtlQos             = smiReq_params.wSmiQos + smiReq_params.wSmiMsgQos;
    ctlIntReqParams.wCtlProt            = smiReq_params.wSmiSec + smiReq_params.wSmiMsgSec;
    ctlIntReqParams.wCtlSecFail         = smiReq_params.wSmiProtFail;
    ctlIntReqParams.wCtlSeqnum          = smiReq_params.wSmiSeqnum;
    ctlIntReqParams.wCtlUser            = smiReq_params.wSmiUser;
    ctlIntReqParams.wCtlErr             = smiReq_params.wSmiErr;
    ctlIntReqParams.wCtlBurstType       = smiReq_params.wSmiTxnHdrBtype;
    ctlIntReqParams.wCtlBurstSize       = smiReq_params.wSmiTxnHdrBsize;
    ctlIntReqParams.wCtlMaxBurstSize    = smiReq_params.wSmiTxnHdrMaxBsize;
    ctlIntReqParams.wCtlRegion          = smiReq_params.wSmiTxnHdrRegion;
    ctlIntReqParams.wCtlAttr            = smiReq_params.wSmiTxnHdrMemAttr;
    ctlIntReqParams.wCtlAtomic          = smiReq_params.wSmiTxnHdrAtomic;
    ctlIntReqParams.wCtlOrderingModel   = smiReq_params.wSmiOrderingModel;
    ctlIntReqParams.wCtlOrderingId      = smiReq_params.wSmiOrderingId;
    ctlIntReqParams.wCtlChannelId       = smiReq_params.wSmiChlId;
    ctlIntReqParams.wCtlData            = smiReq_params.wSmiDPdata;
    ctlIntReqParams.wCtlDataBe          = smiReq_params.wSmiDPbe;
    ctlIntReqParams.wCtlDataUser        = smiReq_params.wSmiDPuser;
    ctlIntReqParams.wCtlDataErr         = smiReq_params.wSmiDPErr;
    ctlIntReqParams.wCtlDataResp        = smiReq_params.wSmiDPresp;
    ctlIntReqParams.wCtlDataId          = smiReq_params.wSmiDPid;
    ctlIntReqParams.wCtlDataOrderingId  = smiReq_params.wSmiOrderingId;
    ctlIntReqParams.wCtlDataChannelId   = smiReq_params.wSmiChannelId;

    ctlIntRespParams.nCtlFlow           = smiResp_params.nSmiVC;
    ctlIntRespParams.nCtlPayload        = smiResp_params.nSmiPayload;
    ctlIntRespParams.wCtlSrcId          = smiResp_params.wSmiSid;
    ctlIntRespParams.wCtlTargId         = smiResp_params.wSmiTid;
    ctlIntRespParams.wCtlVNid           = smiResp_params.wSmiVNid;
    ctlIntRespParams.wCtlSteer          = smiResp_params.wSmiSteer;
    ctlIntRespParams.wCtlNDP            = smiResp_params.wSmiNDP;
    ctlIntRespParams.wCtlNDPLen         = smiResp_params.wSmiNDPLen;
    ctlIntRespParams.wCtlMultiLabel     = smiResp_params.wSmiMultiLabel;
    ctlIntRespParams.wCtlMultiMask      = smiResp_params.wSmiMultiMask;
    ctlIntRespParams.wCtlPressure       = smiResp_params.wSmiPressure;
    ctlIntRespParams.wCtlPoison         = smiResp_params.wSmiPoison;
    ctlIntRespParams.wCtlType           = smiResp_params.wSmiType;
    ctlIntRespParams.wCtlMsgTypeAttr    = smiResp_params.wSmiTypeAttr;
    ctlIntRespParams.wCtlId             = smiResp_params.wSmiId;
    ctlIntRespParams.wCtlAddr           = smiResp_params.wSmiAddr;
    ctlIntRespParams.wCtlLen            = smiResp_params.wSmiLen;
    ctlIntRespParams.wCtlQos            = 0; //smiResp_params.wSmiPri + smiResp_params.wSmiTier + smiResp_params.wSmiMsgQos + smiResp_params.wSmiQos;
    ctlIntRespParams.wCtlProt           = 0; //smiResp_params.wSmiSec + smiResp_params.wSmiMsgSec;
    ctlIntRespParams.wCtlSecFail        = smiResp_params.wSmiProtFail;
    ctlIntRespParams.wCtlSeqnum         = smiResp_params.wSmiSeqnum;
    ctlIntRespParams.wCtlUser           = smiResp_params.wSmiUser;
    ctlIntRespParams.wCtlErr            = smiResp_params.wSmiErr;
    ctlIntRespParams.wCtlBurstType      = smiResp_params.wSmiTxnHdrBtype;
    ctlIntRespParams.wCtlBurstSize      = smiResp_params.wSmiTxnHdrBsize;
    ctlIntRespParams.wCtlRegion         = smiResp_params.wSmiTxnHdrRegion;
    ctlIntRespParams.wCtlAttr           = smiResp_params.wSmiTxnHdrMemAttr;
    ctlIntRespParams.wCtlAtomic         = smiResp_params.wSmiTxnHdrAtomic;
    ctlIntRespParams.wCtlOrderingModel  = smiResp_params.wSmiOrderingModel;
    ctlIntRespParams.wCtlOrderingId     = smiResp_params.wSmiOrderingId;
    ctlIntRespParams.wCtlChannelId      = smiResp_params.wSmiChlId;
    ctlIntRespParams.wCtlData           = smiResp_params.wSmiDPdata;
    ctlIntRespParams.wCtlDataBe         = smiResp_params.wSmiDPbe;
    ctlIntRespParams.wCtlDataUser       = smiResp_params.wSmiDPuser;
    ctlIntRespParams.wCtlDataErr        = smiResp_params.wSmiDPErr;
    ctlIntRespParams.wCtlDataResp       = smiResp_params.wSmiDPresp;
    ctlIntRespParams.wCtlDataId         = smiResp_params.wSmiDPid;
    ctlIntRespParams.wCtlDataOrderingId = smiResp_params.wSmiOrderingId;
    ctlIntRespParams.wCtlDataChannelId  = smiResp_params.wSmiChannelId;

     var ctlInterfaceObject = {};
    
    ctlInterfaceObject.ctlReqInterface   = {
                                            "name"      : "ctl_req_",
                                            "params"    : ctlIntReqParams,
                                            "direction" : "master",
                                            "interface" : "InterfaceCTL"
    };
    
    ctlInterfaceObject.ctlRespInterface  = {
                                            "name"      : "ctl_resp_",
                                            "params"    : ctlIntRespParams,
                                            "direction" : "slave",
                                            "interface" : "InterfaceCTL"
    };
    
    return ctlInterfaceObject;   
}

function generateCTLInterfaceFromAxiT(atuParameters,userLib) {
    var atpReqParams					= userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpReqInterface.params);
    var atpReqPktParams                 = userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpReqInterface.pktDef.params);
    var axiParams                       = userLib.symLib.symLoadHierJason(atuParameters.interfaces.axiInterface.params);
    
    // Grab needed widths from the packet.
    var linkPktReqFunc                  = new userLib[atuParameters.interfaces.atpReqInterface.pktDef.packet];
    var linkPktReq                      = linkPktReqFunc.getPacketArray(atpReqPktParams);

	// Packet field width params needed to compute a sub-set of CTL signal width params
	var reqPkt							= new userLib.symLib.symCsr.PktArrayQuery(atpReqParams.wBus, linkPktReq);
	var wSrcId							= reqPkt.hWidth('H_sid');
	var wH_msg_len						= reqPkt.hWidth('H_msg_len');
    
     // Set common layer name.      
    var ctlReqInterfaceName             = 'ctl_req_';
    var ctlRespInterfaceName            = 'ctl_resp_';

    // Grab AXI Interface. 
    var axiInterface                    = {};
    var axiInterfaceFunc                = new userLib["InterfaceAXI"];
    axiInterface.signals                = axiInterfaceFunc.getSignalsBundle(axiParams);
    var axiInterfaceName                = atuParameters.interfaces.axiInterface.name;    
 

   // ID width mismatch handling
   const deltaWidthId                   = atuParameters.interfaces.axiInterface.params.wArId - atuParameters.interfaces.axiInterface.params.wAwId;
   const sourceRId						= deltaWidthId < 0 ? Math.abs(deltaWidthId)+"'h0,r_id" : "r_id";
   const sourceBId                      = deltaWidthId > 0 ? Math.abs(deltaWidthId)+"'h0,b_id" : "b_id";

    const slice							= "["+(wH_msg_len-1)+":0]"; // Only the MSB position is used to determine length of ctl_req_len. CTL2AXI lib is not used for mapping between ax_len and ctl_req_len in the native layer
    const userMapC2N			= atuParameters.commonToNative.map(function(x) {
									const source		= x.source.replace(/[{}]/,"");
									const destination	= x.destination;
									const sChannel		= (sChannel in x) ? "sel"+x.sChannel : "default";
									return {source, destination, sChannel};
								  });
    var userMapReq			= [
								  {source: ctlReqInterfaceName+"len"+slice, destination: "ax_len", sChannel: "default"}
                              ].concat(userMapC2N);
   
	var userMapRspForReadInterleaving		= !atuParameters.readInterleaveSupported ? [] : [{source: "1'h1", destination: ctlRespInterfaceName+"dp_dummy", sChannel: "sel1"}];
    var userMapRsp			= [
								{source: sourceBId, destination: ctlRespInterfaceName+"dp_id", sChannel: "sel0"},
								{source: sourceBId, destination: ctlRespInterfaceName+"dp_txn_ordering_id", sChannel: "sel0"},
								{source: sourceRId, destination: ctlRespInterfaceName+"dp_id", sChannel: "sel1"},
								{source: sourceRId, destination: ctlRespInterfaceName+"dp_txn_ordering_id", sChannel: "sel1"}
                              ].concat(userMapRspForReadInterleaving); 
    const ctl2Axi			= new userLib.CTL2AXI(axiInterface.signals,axiInterfaceName,userMapRsp,userMapReq);

    var ctlInterfaceObject = {};

    ctlInterfaceObject.ctlReqInterface   = ctl2Axi.ctlReqInterface("master",ctlReqInterfaceName);
    ctlInterfaceObject.ctlRespInterface  = ctl2Axi.ctlRespInterface("slave",ctlRespInterfaceName);

    ctlInterfaceObject.ctlReqInterface.params.wCtlSrcId = wSrcId;
    
    return ctlInterfaceObject;    
}

function generateCTLInterfaceFromApbT(atuParameters,userLib) {
    var apbParams                         = userLib.symLib.symLoadHierJason(atuParameters.interfaces.apbInterface.params);
    var atpReqParams					  = userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpReqInterface.params);
    var atpReqPktParams                   = userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpReqInterface.pktDef.params);
    var atpRespParams                     = userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpRespInterface.params);
    var atpRespPktParams                  = userLib.symLib.symLoadHierJason(atuParameters.interfaces.atpRespInterface.pktDef.params);
    
    // Grab needed widths from the packet.
    var linkPktReqFunc          = new userLib[atuParameters.interfaces.atpReqInterface.pktDef.packet];
    var linkPktRespFunc         = new userLib[atuParameters.interfaces.atpRespInterface.pktDef.packet];
    var linkPktReq              = linkPktReqFunc.getPacketArray(atpReqPktParams);
	var reqPkt					= new userLib.symLib.symCsr.PktArrayQuery(atpReqParams.wBus, linkPktReq);
	var wDataReq				= reqPkt.dWidth("F_data");

    var linkPktResp             = linkPktRespFunc.getPacketArray(atpRespPktParams);
	var respPkt					= new userLib.symLib.symCsr.PktArrayQuery(atpRespParams.wBus, linkPktResp);

    // APB Interface
    var apbInterface            = {};
    var apbInterfaceFunc        = new userLib[atuParameters.interfaces.apbInterface.interface];
    apbInterface.signals		= apbInterfaceFunc.getSignalsBundle(apbParams);
    var apbInterface	        = apbInterface.signals;

    var wApbData                = Math.abs(apbInterface['pwdata']);

	// Determine width-adaption ratio
	var widthAdaptionRatio		= wDataReq === 0 ? 1 : Math.ceil( wApbData/wDataReq );
 
    var ctl_req_params = {
        "nCtlFlow": 1,
        "nCtlPayload" : 1,
        "wCtlType": reqPkt.hWidth("H_msg_type"),
        "wCtlMsgTypeAttr": reqPkt.hWidth("H_msg_type_attr"),
        "wCtlId": reqPkt.hWidth("H_msg_id"),
        "wCtlSrcId": reqPkt.hWidth("H_sid"),
        "wCtlAddr": apbInterface['paddr'],
        "wCtlLen": reqPkt.hWidth("H_msg_len"),
        "wCtlQos": reqPkt.hWidth("H_qos"),
        "wCtlProt": apbInterface['pprot'],
        "wCtlUser": reqPkt.hWidth("H_msg_user"),
        "wCtlErr": reqPkt.hWidth("H_msg_err"),
        "wCtlBurstType": reqPkt.hWidth("H_txn_hdr_btype"),
        "wCtlBurstSize": reqPkt.hWidth("H_txn_hdr_bsize"),
        "wCtlMaxBurstSize": reqPkt.hWidth("H_txn_hdr_maxbsize"),
        "wCtlRegion": reqPkt.hWidth("H_txn_hdr_region"),
        "wCtlAttr": reqPkt.hWidth("H_txn_hdr_memattr"),
        "wCtlAtomic": reqPkt.hWidth("H_txn_hdr_atomic"),
        "wCtlOrderingModel": reqPkt.hWidth("H_ordering_model"),
        "wCtlOrderingId": reqPkt.hWidth("H_ordering_id"),
        "wCtlChannelId": reqPkt.hWidth("H_chl_id"),
        "wCtlTxnHdr": reqPkt.hWidth("H_txn_hdr"),
        "wCtlData": apbInterface['pwdata'],
        "wCtlDataBe": apbInterface['pstrb'],
        "wCtlDataUser": widthAdaptionRatio * reqPkt.dWidth("F_user"),
        "wCtlDataProt": 0, //TODO based on protection
        "wCtlDataErr": reqPkt.dWidth("C_err") 
    }

    var ctl_resp_params = {
        "nCtlFlow": 1,
        "nCtlPayload" : 1,
        "wCtlType": 2,
        "wCtlId": respPkt.hWidth("H_msg_id"),
        "wCtlSrcId": respPkt.hWidth("H_sid"),
        "wCtlDataId": respPkt.hWidth("H_msg_id"),
        "wCtlUser": respPkt.hWidth("H_msg_user"),
        "wCtlOrderingId": reqPkt.hWidth("H_ordering_id"),
        "wCtlChannelId": reqPkt.hWidth("H_chl_id"),
        "wCtlErr": respPkt.hWidth("H_msg_err"),
        "wCtlRespTxnHdr": respPkt.hWidth("H_txn_resp"),
        "wCtlData": apbInterface['pwdata'],
        "wCtlDataBe": apbInterface['pstrb'],
        "wCtlDataResp": respPkt.dWidth("C_resp"),
        "wCtlDataOrderingId": respPkt.hWidth("H_ordering_id"),
        "wCtlDataChannelId": respPkt.hWidth("H_chl_id"),
        "wCtlDataProt": 0 //TODO based on protection
    }

    var ctlInterfaceObject = {};
    
    ctlInterfaceObject.ctlReqInterface   = {
                                            "name"      : "ctl_req_",
                                            "params"    : ctl_req_params,
                                            "direction" : "master",
                                            "interface" : "InterfaceCTL"
    };
    
    ctlInterfaceObject.ctlRespInterface  = {
                                            "name"      : "ctl_resp_",
                                            "params"    : ctl_resp_params,
                                            "direction" : "slave",
                                            "interface" : "InterfaceCTL"
    };
    
    return ctlInterfaceObject;	
}

function generateCTLInterfaceFromCtlT(atuParameters,userLib) {

    const reqPacket          = new userLib[atuParameters.interfaces.atpReqInterface.pktDef.packet];
    const reqPacketArray     = reqPacket.getPacketArray(atuParameters.interfaces.atpReqInterface.pktDef.packet).filter(x => !["H_route","H_steer"].includes(x.name));
    var smiReqParams         = userLib.smiLib.pktField2SmiParamTable.pktDef2SmiParams(reqPacketArray);

    const respPacket         = new userLib[atuParameters.interfaces.atpRespInterface.pktDef.packet];
    const respPacketArray    = respPacket.getPacketArray(atuParameters.interfaces.atpRespInterface.pktDef.packet);
    var smiRespParams        = userLib.smiLib.pktField2SmiParamTable.pktDef2SmiParams(respPacketArray);
    smiRespParams.wSmiDPid   = smiRespParams.wSmiId;
    smiRespParams.wSmiRoute  = 0;
    
   var ctlIntReqParams = {};
   var ctlIntRespParams = {};

   if(smiReqParams.wSmiMsgQos == undefined) {
     smiReqParams.wSmiMsgQos = 0;
   }

   if(smiReqParams.wSmiQos == undefined) {
     smiReqParams.wSmiQos = 0;
   }

   if(smiReqParams.wSmiMsgSec == undefined) {
     smiReqParams.wSmiMsgSec = 0;
   }

   if(smiReqParams.wSmiSec == undefined) {
     smiReqParams.wSmiSec = 0;
   }
    
   ctlIntReqParams.nCtlFlow            = smiReqParams.nSmiVC;
   ctlIntReqParams.nCtlPayload         = smiReqParams.nSmiPayload;
   ctlIntReqParams.wCtlSrcId           = smiReqParams.wSmiSid;
   ctlIntReqParams.wCtlTargId          = 0; //smiReq_params.wSmiTid;
   ctlIntReqParams.wCtlVNid            = smiReqParams.wSmiVNid;
   ctlIntReqParams.wCtlSteer           = smiReqParams.wSmiSteer;
   ctlIntReqParams.wCtlNDP             = smiReqParams.wSmiNDP;
   ctlIntReqParams.wCtlNDPLen          = smiReqParams.wSmiNDPLen;
   ctlIntReqParams.wCtlMultiLabel      = smiReqParams.wSmiMultiLabel;
   ctlIntReqParams.wCtlMultiMask       = smiReqParams.wSmiMultiMask;
   ctlIntReqParams.wCtlPressure        = smiReqParams.wSmiPressure;
   ctlIntReqParams.wCtlPoison          = smiReqParams.wSmiPoison;
   ctlIntReqParams.wCtlType            = smiReqParams.wSmiType;
   ctlIntReqParams.wCtlMsgTypeAttr     = smiReqParams.wSmiTypeAttr;
   ctlIntReqParams.wCtlId              = smiReqParams.wSmiId;
   ctlIntReqParams.wCtlAddr            = smiReqParams.wSmiAddr;
   ctlIntReqParams.wCtlLen             = smiReqParams.wSmiLen;
   ctlIntReqParams.wCtlQos             = smiReqParams.wSmiQos + smiReqParams.wSmiMsgQos;
   ctlIntReqParams.wCtlProt            = smiReqParams.wSmiSec + smiReqParams.wSmiMsgSec;
   ctlIntReqParams.wCtlSecFail         = smiReqParams.wSmiProtFail;
   ctlIntReqParams.wCtlSeqnum          = smiReqParams.wSmiSeqnum;
   ctlIntReqParams.wCtlUser            = smiReqParams.wSmiUser;
   ctlIntReqParams.wCtlErr             = smiReqParams.wSmiErr;
   ctlIntReqParams.wCtlBurstType       = smiReqParams.wSmiTxnHdrBtype;
   ctlIntReqParams.wCtlBurstSize       = smiReqParams.wSmiTxnHdrBsize;
   ctlIntReqParams.wCtlMaxBurstSize    = smiReqParams.wSmiTxnHdrMaxBsize;
   ctlIntReqParams.wCtlRegion          = smiReqParams.wSmiTxnHdrRegion;
   ctlIntReqParams.wCtlAttr            = smiReqParams.wSmiTxnHdrMemAttr;
   ctlIntReqParams.wCtlAtomic          = smiReqParams.wSmiTxnHdrAtomic;
   ctlIntReqParams.wCtlOrderingModel   = smiReqParams.wSmiOrderingModel;
   ctlIntReqParams.wCtlOrderingId      = smiReqParams.wSmiOrderingId;
   ctlIntReqParams.wCtlChannelId       = smiReqParams.wSmiChlId;
   ctlIntReqParams.wCtlData            = smiReqParams.wSmiDPdata;
   ctlIntReqParams.wCtlDataBe          = smiReqParams.wSmiDPbe;
   ctlIntReqParams.wCtlDataUser        = smiReqParams.wSmiDPuser;
   ctlIntReqParams.wCtlDataErr         = smiReqParams.wSmiDPErr;
   ctlIntReqParams.wCtlDataResp        = smiReqParams.wSmiDPresp;
   ctlIntReqParams.wCtlDataId          = smiReqParams.wSmiDPid;
   ctlIntReqParams.wCtlDataOrderingId  = smiReqParams.wSmiOrderingId;
   ctlIntReqParams.wCtlDataChannelId   = smiReqParams.wSmiChannelId;

   ctlIntRespParams.nCtlFlow           = smiRespParams.nSmiVC;
   ctlIntRespParams.nCtlPayload        = smiRespParams.nSmiPayload;
   ctlIntRespParams.wCtlSrcId          = smiRespParams.wSmiSid;
   ctlIntRespParams.wCtlTargId         = smiRespParams.wSmiTid;
   ctlIntRespParams.wCtlVNid           = smiRespParams.wSmiVNid;
   ctlIntRespParams.wCtlSteer          = smiRespParams.wSmiSteer;
   ctlIntRespParams.wCtlNDP            = smiRespParams.wSmiNDP;
   ctlIntRespParams.wCtlNDPLen         = smiRespParams.wSmiNDPLen;
   ctlIntRespParams.wCtlMultiLabel     = smiRespParams.wSmiMultiLabel;
   ctlIntRespParams.wCtlMultiMask      = smiRespParams.wSmiMultiMask;
   ctlIntRespParams.wCtlPressure       = smiRespParams.wSmiPressure;
   ctlIntRespParams.wCtlPoison         = smiRespParams.wSmiPoison;
   ctlIntRespParams.wCtlType           = smiRespParams.wSmiType;
   ctlIntRespParams.wCtlMsgTypeAttr    = smiRespParams.wSmiTypeAttr;
   ctlIntRespParams.wCtlId             = smiRespParams.wSmiId;
   ctlIntRespParams.wCtlAddr           = smiRespParams.wSmiAddr;
   ctlIntRespParams.wCtlLen            = smiRespParams.wSmiLen;
   ctlIntRespParams.wCtlQos            = 0; //smiResp_params.wSmiPri + smiResp_params.wSmiTier + smiResp_params.wSmiMsgQos + smiResp_params.wSmiQos;
   ctlIntRespParams.wCtlProt           = 0; //smiResp_params.wSmiSec + smiResp_params.wSmiMsgSec;
   ctlIntRespParams.wCtlSecFail        = smiRespParams.wSmiProtFail;
   ctlIntRespParams.wCtlSeqnum         = smiRespParams.wSmiSeqnum;
   ctlIntRespParams.wCtlUser           = smiRespParams.wSmiUser;
   ctlIntRespParams.wCtlErr            = smiRespParams.wSmiErr;
   ctlIntRespParams.wCtlBurstType      = smiRespParams.wSmiTxnHdrBtype;
   ctlIntRespParams.wCtlBurstSize      = smiRespParams.wSmiTxnHdrBsize;
   ctlIntRespParams.wCtlMaxBurstSize   = smiRespParams.wSmiTxnHdrMaxBsize;
   ctlIntRespParams.wCtlRegion         = smiRespParams.wSmiTxnHdrRegion;
   ctlIntRespParams.wCtlAttr           = smiRespParams.wSmiTxnHdrMemAttr;
   ctlIntRespParams.wCtlAtomic         = smiRespParams.wSmiTxnHdrAtomic;
   ctlIntRespParams.wCtlOrderingModel  = smiRespParams.wSmiOrderingModel;
   ctlIntRespParams.wCtlOrderingId     = smiRespParams.wSmiOrderingId;
   ctlIntRespParams.wCtlChannelId      = smiRespParams.wSmiChlId;
   ctlIntRespParams.wCtlData           = smiRespParams.wSmiDPdata;
   ctlIntRespParams.wCtlDataBe         = smiRespParams.wSmiDPbe;
   ctlIntRespParams.wCtlDataUser       = smiRespParams.wSmiDPuser;
   ctlIntRespParams.wCtlDataErr        = smiRespParams.wSmiDPErr;
   ctlIntRespParams.wCtlDataResp       = smiRespParams.wSmiDPresp;
   ctlIntRespParams.wCtlDataId         = smiRespParams.wSmiDPid;
   ctlIntRespParams.wCtlDataOrderingId = smiRespParams.wSmiOrderingId;
   ctlIntRespParams.wCtlDataChannelId  = smiRespParams.wSmiChannelId;
    
   var ctlInterfaceObject = {};
    
   ctlInterfaceObject.ctlReqInterface   = {
                                            "name"      : "ctl_req_",
                                            "params"    : ctlIntReqParams,
                                            "direction" : "master",
                                            "interface" : "InterfaceCTL"
   };
    
   ctlInterfaceObject.ctlRespInterface  = {
                                            "name"      : "ctl_resp_",
                                            "params"    : ctlIntRespParams,
                                            "direction" : "slave",
                                            "interface" : "InterfaceCTL"
   };
    
   return ctlInterfaceObject;  
}


// Function to return CSR defintions of registers whose names match those
// in the "registers" array.
function matchRegisterNames(names, registers, prefix) {
	const result		= []; 

	// Loop through both arrays and extract matching register names
	registers.forEach( reg => {
	  names.forEach( name => {
		if( prefix+name === reg.name )
		  result.push( Object.assign({}, reg, {name}) );	// Store register names without unit-prefix
	  });
	});

	return result;	
}


// Function that returns Ncore trace_trigger block CSR register definitions
function genTraceTriggerRegisters( csrRegisters, prefix, params ) {
	const unitSet			= [ "TCTRLR", "TBALR", "TBAHR", "TOPCR0", "TOPCR1", "TUBR", "TUBMR" ];
	const names				= [];

	for(let i=0; i<params.nTraceRegisters; i++) {
	  unitSet.forEach( name => {
		names.push(name+i);
	  });
	}

	return matchRegisterNames( names, csrRegisters, prefix );
}


// Function that returns Ncore trace_capture block CSR register definitions
function genTraceCaptureRegisters( csrRegisters, prefix ) {
	return matchRegisterNames( ["CCTRLR"], csrRegisters, prefix );
}


// Function that returns Ncore trace_accumulator block CSR register definitions
function genTraceAccumulatorRegisters( csrRegisters, prefix ) {
	const names				= [ "TASCR", "TADHR", "TADSTR" ];

	// Duplicate TADxR register 16 times
	for(let i=0; i<16; i++) {
		names.push("TAD"+i+"R");
	}

	return matchRegisterNames( names, csrRegisters, prefix );
}


// Function that returns Ncore PMON block CSR register definitions
function genNcorePmonRegisters( csrRegisters, prefix, params ) {
	const names				= []; 

	// Duplicate CNTVR and CNTSR registers
	// Duplicate BCNTFR and BCNTMR registers for BW
	for(let i=0; i<params.nPerfCounters; i++) {
		names.push("CNTCR"+i);
		names.push("CNTVR"+i);
		names.push("CNTSR"+i);
		names.push("BCNTFR"+i);
		names.push("BCNTMR"+i);
	}
	names.push("MCNTCR");
	names.push("LCNTCR");

	return matchRegisterNames( names, csrRegisters, prefix );
}


// Function that returns Ncore 3.4 CCR (Credit control) registers
function genNcoreCCRRegisters( csrRegisters, prefix, params ) {
	const names				= []; 

	// Duplicate CCR registers
	for(let i=0; i<params.nCCR; i++) {
		names.push("CCR"+i);
	}

	return matchRegisterNames( names, csrRegisters, prefix );
}


// Returns an object with methods to generate CSR-interfaces (new-style, old-style, bundle)
function createCSRInterfaceGenerator(registers, options={}) {

	function inputs() {		// inputs to an apb_csr block or inputs on a master interface
		const result		= [];
	
		registers.forEach( register => {
		  register.fields.forEach( field => {
			const fWidth			= parseInt(field.bitWidth);
			const RO				= !options.skipROResetInputs && (field.hardware == "RO") && (field.access == "RO") && !field.name.startsWith("Rsvd");

			if( fWidth && (["WO","RW"].includes(field.hardware) || RO) ) {  //RO, but non-Rsvd, fields require *in pins to allow setting of reset values
				result.push({
					name: getHWPortName(register.name, field.name, "in"),
					width: field.bitWidth
				});
			}

			if( fWidth && ["WO","RW"].includes(field.hardware) ) {
				result.push({
					name: getHWPortName(register.name, field.name, "wr"),
					width: 1
				});
			}
		  });
		});

		return result;
	}

	
	function outputs() {		// outputs from an apb_csr block or outputs on a master interface
		const result		= [];
	
		registers.forEach( register => {
		  register.fields.forEach( field => {
			const fWidth			= parseInt(field.bitWidth);
			const fRsvd				= field.name.startsWith("Rsvd");

			if( fWidth && !fRsvd && ["RO","RW"].includes(field.hardware) ) {
				result.push({
					name: getHWPortName(register.name, field.name, "out"),
					width: field.bitWidth
				});
			}
		  });
		});

		return result;
	}
	
	
	function synonymsGeneric(direction) {
		const ins			= direction === "slave" ? inputs() : outputs();
		const outs			= direction === "slave" ? outputs() : inputs();
		return { "in": ins, "out": outs };
	}


	function interfaceGeneric(direction, name="") {
		const synonyms		= synonymsGeneric(direction);
		return { synonyms, name, "_SKIP_": false, "interface": "InterfaceGeneric", direction, synonymsOn: true, synonymsExpand: true };
	}


	function signalBundle( direction ) {
		const result		= {};

		inputs().forEach( input => {
			result[input.name]			= direction === "slave" ? -input.width : input.width;
		});

		outputs().forEach( output => {
			result[output.name]			= direction === "slave" ? output.width : -output.width;
		});
	
		return result;
	}


	return { synonymsGeneric, interfaceGeneric, signalBundle, inputs, outputs };
}


// Returns absolute width of a signal in a bundle and zero if undefined
function signalWidthInBundle(bundle, name) {
	return Math.abs(bundle[name]) || 0;
}


// Returns an object with methods to compute names and widths of
// signals or ports in a CSR-interface
function queryCsrInterfacePorts( csrInterfaceOldStyle, direction ) {

  // Returns the name (string) of a signal or port in the interface
  function name(type, register, field) {
	return csrInterfaceOldStyle.name + getHWPortName(register, field, type);
  }


  // Returns the absolute width of a signal or port in the interface
  function width(type, register, field) {
	return signalWidthInBundle(csrInterfaceOldStyle.signals, getHWPortName( register, field, type ));
  }


  // Returns the direction (input or output) of a signal or port in the interface
  function direction(type, register, field) {
    var portName  = getHWPortName(register, field, type);
	
    if( csrInterfaceOldStyle.signals[portName] < 0 )
       return direction === "master" ? "input" : "output";

    return direction === "master" ? "output" : "input"; 
  }


  // Returns an object with a port or signal's properties {name, width, direction}
  function port(type, register, field) {
	return { name: name(register, field, type), width: width(register, field, type), direction: direction(register, field, type) };
  }


  return { name, width, direction, port };
}
 

// Function that returns a promise to convert an IPXACT XML to a CSR JSON object
function ipxact2csr (xml) {

	const xml2js					= require('xml2js');


	function ipxactRegField2CsrRegField (field) {
		const accessLUT				= {
			"read-only"		: "RO",
			"read-write"	: "RW",
			"write-only"	: "WO"
		};
		const name					= field.name[0];
		const bitOffset				= parseInt(field.bitOffset[0]);
		const bitWidth				= parseInt(field.bitWidth[0]);
		const access				= accessLUT[field.access[0]];
		if(!access)
			throw new Error("Unrecognized access: "+field.access[0]+" for register field "+name);
		const description			= field.description[0];
		const reset					= parseInt(field.resets[0].reset[0].value[0]);
		return { name, bitOffset, bitWidth, access, description, reset };
	}
	
	
	function ipxactReg2CsrReg (reg) {
		const name					= reg.name[0];
		const csrDescription		= reg.description[0];
		const addressOffset			= parseInt(reg.addressOffset[0]);
		const fields				= reg.field.map(ipxactRegField2CsrRegField);
		return { name, csrDescription, addressOffset, fields };
	}
	
	
	function addrBlock2SpaceBlock(addrBlock) {
		const name					= addrBlock.name[0];
		const baseAddress			= parseInt(addrBlock.baseAddress[0]);
		const registers				= addrBlock.register.map(ipxactReg2CsrReg);
		return { name, baseAddress, registers };
	}


	function removeIpxactPrefix (name) {
	  return name.replace("ipxact:","");
	}


	const parser				= new xml2js.Parser({ tagNameProcessors: [removeIpxactPrefix] });

	return parser.parseStringPromise(xml).then( json => {
		const addressBlocks			= json.component.memoryMaps[0].memoryMap[0].addressBlock;
		const spaceBlock			= addressBlocks.map( addrBlock2SpaceBlock );
		const csr					= { spaceBlock };
		return csr;
	});
}


// Function that returns an expression (string) for generating a stall event and the 
// width of the same event, for a given SMI interface
function genSmiStallEvent( smiInterface ) {
	const valid		= smiInterface.dpSignals["dp_valid"] ? smiInterface.name+"dp_valid" : smiInterface.name+"ndp_msg_valid";
	const ready		= smiInterface.dpSignals["dp_ready"] ? smiInterface.name+"dp_ready" : smiInterface.name+"ndp_msg_ready";
	return { expr: valid+" & "+ "~"+ready, width: 1 };
}

function oldStyleToNewStyleGenericInterface( direction, oldStyleInterface ) {
  var synonyms = [];

  //{ "funit_id": 5, "user": 3 }. Object.keys( ) returns ["user", "funit_id"] ["funit_id", "user"]
  Object.keys(oldStyleInterface.signals).sort().forEach( key => {
    synonyms.push({ name: key, width: oldStyleInterface.signals[key] });
  });

  return {
    name: oldStyleInterface.name,
    direction,
    "interface": "InterfaceGeneric",
    synonymsOn: true,
    synonymsExpand: true,
    synonyms: { "in": [], "out": synonyms } };
  }

function genFilterAttrInterfaces(table){ 
	var result = [];
	for (var i = 0; i < table.length; i++){	   
            result.push( oldStyleToNewStyleGenericInterface("slave", { name: table[i].name, signals: table[i].signals }) );	   
	}
	return result;
}


function generateBwEvtMapping(table){
var evtMap = [];

table.forEach( x => {
evtMap.push( x.eventIndex );
});
return evtMap;
}


// Function to assign two old-style interfaces / interface-bundles with names
// If widths are different on either sides of the assignment operator, the rhs
// is either extended or truncated
function assignOldStyleInterfaces( srcIntf, dstIntf ) {
  var vlogSignal    = vlogGen().vlogSignal;  // Library to extend or truncate signals
  var srcIntfFlat   = flattenInterface(srcIntf);
  var dstIntfFlat   = flattenInterface(dstIntf);
  var result = [];

  // Assign inputs on dst interface
  Object.keys(dstIntfFlat.signals).sort().forEach( key => {
    if(dstIntfFlat.signals[key] > 0) {
      var srcWidth        = Math.abs( srcIntfFlat.signals[key] || 0 );
      var dstWidth        = Math.abs( dstIntfFlat.signals[key] || 0 );
      var srcSignal		  = vlogSignal( srcWidth, srcIntfFlat.name+key );
      var srcAdjusted     = dstWidth > srcWidth ? srcSignal.extend0( dstWidth ) : srcSignal.trunc( dstWidth );  // Adjust src width if not equal to that of dst
      result.push({ src: srcAdjusted.expr, dst: dstIntfFlat.name+key });
    }
  });

  // Assign inputs on src interface
  Object.keys(srcIntfFlat.signals).sort().forEach( key => {
    if(srcIntfFlat.signals[key] < 0) {
      var srcWidth        = Math.abs( srcIntfFlat.signals[key] || 0 );
      var dstWidth        = Math.abs( dstIntfFlat.signals[key] || 0 );
      var srcSignal		  = vlogSignal( dstWidth, dstIntfFlat.name+key );
      var srcAdjusted     = srcWidth > dstWidth ? srcSignal.extend0( srcWidth ) : srcSignal.trunc( srcWidth );  // Adjust src width if not equal to that of dst
      result.push({ src: srcAdjusted.expr, dst: srcIntfFlat.name+key });
    }
  });

  return result;
}


// Functions to fix/modify attributes of specific Ncore registers

// This function accepts a CCR (Credit control register) CSR definition and returns 
// a new CCR register with properties of certain field-attributes modified. The function
// doesn't mutate the original CCR register object passed as a param.
function fixCCRRegister( register, params ) {
  var regMatch                  = register.name.match(/^[CX]AIUCCR(?<n>\d+)$/);
  var n                         = parseInt( regMatch.groups.n ); // index or number of the CCR register
  var modifiedFields            = [];

  register.fields.forEach( field => {
    var fieldMatch              = field.name.match(/^(?<type>DCE|DMI|DII)(CreditLimit|CounterState)$/);
    var modifiedField           = !fieldMatch || (n < params.nUnits[fieldMatch.groups.type]) ? field : Object.assign({}, field, {access: "RO", hardware: "RO"});
    modifiedFields.push( modifiedField );
  });

  return Object.assign({}, register, {fields: modifiedFields});
}


// This function accepts a NRSAR (NRS attribute register) CSR definition and returns a
// new NRSAR register with properties of certain field-attributes modified. The function
// doesn't mutate the original NRSAR register object passed as a param.
function fixNRSARRegister( register, params ) {
  var modifiedFields            = [];

  register.fields.forEach( field => {
    var modifiedField           = field;

    if( /^NRSAR$/.test(field.name) ) {
      modifiedField             = params.fnCsrAccess ? Object.assign({}, field, {access: "RO"}) : Object.assign({}, field, {access: "RW"});
    }

    modifiedFields.push( modifiedField );
  });

  return Object.assign({}, register, {fields: modifiedFields});
}

function vlogStr2IntArray ( vlogStr ) {
  var hexStr = vlogStr.substr(2, vlogStr.length-2);
  var hex = parseInt(hexStr, 16);
  var binStr = hex.toString(2);
  var arr = [];
  for (var i = binStr.length-1; i >= 0; i--) {
    if ((binStr.slice(i, i+1)) === '1') {
        arr.push(binStr.length-1-i)
    }
  }
  return arr;
}

function convertSecSubRowsToOld ( mySecSubRows ) {
    if (Array.isArray(mySecSubRows)) {
        var oldSecSubRows = {};
        for (var i=0; i < mySecSubRows.length; i++) {
            oldSecSubRows[i] = vlogStr2IntArray(mySecSubRows[i]);
        }
      return oldSecSubRows;
    } else {
      return mySecSubRows;
    }
}

module.exports = {
    generateCTLInterface : generateCTLInterface,
	genTraceTriggerRegisters: genTraceTriggerRegisters,
	genTraceCaptureRegisters: genTraceCaptureRegisters,
	genTraceAccumulatorRegisters: genTraceAccumulatorRegisters,
	genNcorePmonRegisters: genNcorePmonRegisters,
	genNcoreCCRRegisters: genNcoreCCRRegisters,
	genSmiStallEvent: genSmiStallEvent,
 	genFilterAttrInterfaces : genFilterAttrInterfaces, 
	generateBwEvtMapping : generateBwEvtMapping,
	oldStyleToNewStyleGenericInterface: oldStyleToNewStyleGenericInterface,
    smiPortGen: smiPortGen,
    concMsgGen: concMsgGen,
    log2ceil : log2ceil,
    convertSecSubRowsToOld : convertSecSubRowsToOld,
    writeJSON: writeJSON,
    readJSON: readJSON,
    deepCopy : deepCopy,
    assertHeader: assertHeader,
    assertFooter: assertFooter,
    getNthBit : getNthBit,
    countBits : countBits,

    tieOffNewInterface : tieOffNewInterface,
    compareNewInterfacesDiffer : compareNewInterfacesDiffer,
    createLocalInterfaceNames : createLocalInterfaceNames,
	getSignalsBundle: getSignalsBundle,
	newToOldStyleInterface: newToOldStyleInterface,
    getPath : getPath,
    getPathParam : getPathParam,
    hierGetParam : hierGetParam,
    loadHierJason : loadHierJason,

    string_addConnectionfromInterface : string_addConnectionfromInterface,
    defineMasterPortsFromInterface : defineMasterPortsFromInterface,
    forceMasterPortsFromInterface : forceMasterPortsFromInterface,
    forceSlavePortsFromInterface : forceSlavePortsFromInterface,
    defineSlavePortsFromInterface : defineSlavePortsFromInterface,
    defineListPortsFromInterface : defineListPortsFromInterface,
    string_defineSignalsFromInterface : string_defineSignalsFromInterface,

    regNameIfNoHit : regNameIfNoHit,
    getUniqName : getUniqName,
	createUniqNameFactory : createUniqNameFactory,
    compareInterfaces : compareInterfaces,

    getAsyncInterface : getAsyncInterface,
    getAsyncCrInterface : getAsyncCrInterface,
    getAsyncFifoRdCtlInterface : getAsyncFifoRdCtlInterface,
    getAsyncFifoRegDpInterface : getAsyncFifoRegDpInterface,
    getAsyncFifoWtCtlInterface : getAsyncFifoWtCtlInterface,

    getRdyVldPipeCtlInterface : getRdyVldPipeCtlInterface,
    getRdyVldPipeDpInterface : getRdyVldPipeDpInterface,

    CreateCSRObj: CreateCSRObj,
    CreateCSR: CreateCSR,
    CreateSpaceBlock: CreateSpaceBlock,
    CreateRegCSRObj: CreateRegCSRObj,
    CreateRegCSR: CreateRegCSR,
    CreateFieldCSR: CreateFieldCSR,
	getHWPortName: getHWPortName,
	createCSRInterfaceGenerator: createCSRInterfaceGenerator,
    queryCsrInterfacePorts: queryCsrInterfacePorts,
    signalWidthInBundle: signalWidthInBundle,
    mergeObjects: mergeObjects,
	keysAndValuesToObject: keysAndValuesToObject,
	range: range,
	zip: zip,
	izip: izip,
	reversed: reversed,
	cross: cross,
	uniquify: uniquify,
	accumulate: accumulate,
	lastEntry: lastEntry,
	findLast: findLast,
	partial: partial,
	curry: curry,
	flip: flip,
	compose: compose,
	pipe: pipe,
	memoize: memoize,
	envelope: envelope,
	createTreeParser: createTreeParser,
    removeIllegalWidthSignals: removeIllegalWidthSignals,
    getVlogConcatSignals: getVlogConcatSignals,
    genMuxOrTree: genMuxOrTree,
    instance2Module: instance2Module,
    module2Attr: module2Attr,
    attr2Csr: attr2Csr,
    attr2NodeId: attr2NodeId,
    mergeCsr: mergeCsr,
	createConfigAddressMap: createConfigAddressMap,
	createConfigAddressMapFromMasks: createConfigAddressMapFromMasks,
    sb2RegAddrMap: sb2RegAddrMap,
	VlogSignal: VlogSignal,
	VlogArray: VlogArray,
	VlogPkdArray: VlogPkdArray,
	vlogSignal2PkdArray: vlogSignal2PkdArray,
	vlogSignal2PkdStruct: vlogSignal2PkdStruct,
	VlogPkdStruct: VlogPkdStruct,
	VlogConst: VlogConst,
	getVlogBundle: getVlogBundle,
	declareVlogBundle: declareVlogBundle,
	vlogGen,
    widthOfSlice: widthOfSlice,
    parseVlogConst: parseVlogConst,
	Slice: Slice,
	PkdArray: PkdArray,
	PkdStruct: PkdStruct,
	pkdWidth: pkdWidth,
	flattenInterface: flattenInterface,
	flattenSignalsBundle: flattenSignalsBundle,
    assignOldStyleInterfaces: assignOldStyleInterfaces,

    dataBufferMemoryParams : dataBufferMemoryParams,
    aiuOttMemoryParams: aiuOttMemoryParams,
    bridgeOttMemoryParams: bridgeOttMemoryParams,
    llcCacheTagMemoryParams  : llcCacheTagMemoryParams,
    llcCacheDataMemoryParams : llcCacheDataMemoryParams,
    llcCacheRPMemoryParams   : llcCacheRPMemoryParams,
    bridgeIoCacheTagMemoryParams: bridgeIoCacheTagMemoryParams,
    bridgeIoCacheDataMemoryParams: bridgeIoCacheDataMemoryParams,
    bridgeIoCacheRPMemoryParams: bridgeIoCacheRPMemoryParams,
    snoopFilterMemoryParams: snoopFilterMemoryParams,
    dmiRttMemoryParams: dmiRttMemoryParams,
    dmiCMCTagMemoryParams: dmiCMCTagMemoryParams,
    dmiCMCRPMemoryParams: dmiCMCRPMemoryParams,
    dmiCMCDataMemoryParams: dmiCMCDataMemoryParams,
    ccpTagMemoryParams: ccpTagMemoryParams,
    ccpRpMemoryParams: ccpRpMemoryParams,
    ccpDataMemoryParams: ccpDataMemoryParams,
    IOAIUccpDataMemoryParams: IOAIUccpDataMemoryParams,
    getErrorEncodingWidth: getErrorEncodingWidth,
    getEvenBlockWidths: getEvenBlockWidths,
    getMemoryControlSignals: getMemoryControlSignals,
    createMemoryDataStructure: createMemoryDataStructure,
    testSymbolIndex: testSymbolIndex,
    getEccWidth: getEccWidth,
    ParamDefaultGet: ParamDefaultGet,
    getEvenBlockWidths : getEvenBlockWidths,
    getEccIndexes:getEccIndexes,
    string_genStateMachine: string_genStateMachine,
    ipxact2csr: ipxact2csr,
    getTraceStructDefault: getTraceStructDefault,
    getTraceOnDefault: getTraceOnDefault,
    getDumpTraceDefault: getDumpTraceDefault,
    fixCCRRegister: fixCCRRegister,
    fixNRSARRegister: fixNRSARRegister
};
