'use strict';

const paramUtil = require('../../scripts/formatParamUtilities');
const csrJson   = require('../../common/lib_tb/csr.json');
const chiAgent  = require(process.env.WORK_TOP + '/dv/chi_aiu/env/chiAiuEnv.js');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');

module.exports = {
    formatFunc       : formatFunc,
    unitFunc         : unitFunc,
    nSizeBytesToSize : nSizeBytesToSize,
    getSetAddrMap    : getSetAddrMap
}

function formatFunc(obj) {
//    var retObj = paramUtil.extAllIntrlvAgents(obj);
    var retObj = chiAgent.formatFunc(obj);
    // Take First CHI-AIU you find
    var isFound = 0;
    retObj.AiuInfo.forEach(function(agent, idx) {
        if(((agent.fnNativeInterface === 'CHI-A') || (agent.fnNativeInterface === 'CHI-B') || (agent.fnNativeInterface === 'CHI-E'))
	    && ((obj.instanceName) ? (agent.strRtlNamePrefix == obj.instanceName) : (isFound == 0))) {
            retObj.DutInfo = agent;
            retObj.Id = idx;
            isFound = 1;
        }
    });

    if (retObj.DutInfo === undefined) {
        throw new Error('ERROR! This configuration does not have any CHI-AIU!');
    }
    
    retObj.CsrDef = csrJson;
    if(obj.instanceName) {
	retObj.BlockId    = obj.instanceName;
	retObj.moduleName = obj.instanceMap[obj.instanceName];
    } else if(obj.instanceMap && (obj.dontUseInstanceName === undefined)) {
	retObj.BlockId    = obj.DutInfo.strRtlNamePrefix;
	retObj.moduleName = obj.instanceMap[obj.instanceName];
    } else {
	retObj.BlockId = 'chi_aiu0';
	retObj.moduleName = 'chiaiu0';
    }
    retObj.Block = 'chi_aiu';
    retObj.testBench = 'chi_aiu';
    retObj.useQos = retObj.DutInfo.interfaces.chiInt.params.wQos;
    getSetAddrMap(retObj);
 //   perfCntUtil.updateRetObj(retObj);
    return retObj;
}

function getSetAddrMap(obj) {
    obj.AddrMap = [];
    var mem_id = 0;
    var random_size = 0;
    var random_addr = 0;
//    obj.SysAddrRangeInfo.SysAddrRangeInfo.forEach(function(addr_map,mem_id) {
//	var tempObj = {
//	    "HUT"      : 0, //set 0 for DMI
//	    "BaseAddr" : addr_map.nBaseAddr,
//	    "Size"     : addr_map.nSizeBytes,
//	};
//	obj.AddrMap.push(tempObj);
//    });
//    for(var ig_id in obj.SysAddrRangeInfo.MInterlvGrpAddrMapInfo) {
//	obj.SysAddrRangeInfo.MInterlvGrpAddrMapInfo[ig_id].forEach(function(gp_id) {
//	    obj.AddrMap[gp_id].HUI  = ig_id;
//	    obj.AddrMap[gp_id].HUT  = 0; //set 0 for DMI
//	    obj.AddrMap[gp_id].Size = nSizeBytesToSize(obj.AddrMap[gp_id].Size,obj.DmiInfo[ig_id].nDmis); //set 0 for DMI
//	});
//    }
//    for(var ig_id in obj.SysAddrRangeInfo.DIIAddrMapInfo) {
//	obj.SysAddrRangeInfo.DIIAddrMapInfo[ig_id].forEach(function(gp_id) {
//	    obj.AddrMap[gp_id].HUI  = ig_id;
//	    obj.AddrMap[gp_id].HUT  = 1; //set 0 for DII
//	    obj.AddrMap[gp_id].Size = nSizeBytesToSize(obj.AddrMap[gp_id].Size,11); //set 0 for DMI
//	});
//    }

    for(var ig_id=0; ig_id<obj.DutInfo.nGPRA; ig_id++){
	var tempObj = {
	    "HUT"      : 0, //set 0 for DMI
	    "BaseAddr" : 0, //addr_map.nBaseAddr,
	    "Size"     : 0, //addr_map.nSizeBytes,
	};
        random_size = Math.floor(Math.random() * 1000000000);
	obj.AddrMap.push(tempObj);
	obj.AddrMap[ig_id].HUI 		= ig_id;
	obj.AddrMap[ig_id].HUT 		= Math.floor(Math.random() * 2); //0: DMI, 1: DII
	obj.AddrMap[ig_id].BaseAddr 	= random_addr;
	obj.AddrMap[ig_id].Size		= nSizeBytesToSize(random_size, (obj.AddrMap[ig_id].HUT ? obj.DutInfo.nDiis : obj.DutInfo.nDmis));
	random_addr = obj.AddrMap[ig_id].Size + 1;
    }
	
    /*    obj.SysAddrRangeInfo.forEach(function(addr_range, i) {
	obj.AddrMap = {
	};
    });
*/
}
function nSizeBytesToSize(nSizeBytes,ig_size) {
    return Math.ceil(Math.log2(nSizeBytes / ig_size)) - 12; // NCore3SysArch 4.5.2.13.1.1
}
function unitFunc(unitParam, pkgParams) {
    var retObj = chiAgent.unitFunc(unitParam,pkgParams);
    if(pkgParams.instanceName)
	retObj.BlockId = pkgParams.instanceName;
    else
    retObj.BlockId = 'chi_aiu0';
 //   perfCntUtil.updateRetObj(retObj);
    return retObj;
}
