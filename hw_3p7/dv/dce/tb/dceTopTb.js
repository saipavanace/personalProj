
var paramUtil = require(process.env.WORK_TOP +
                        '/dv/scripts/formatParamUtilities.js')
var sfiPriv_imp = require(process.env.WORK_TOP +
                          '/tb/sub_sys/lib/sfipriv_calc.js');
var dceAgent = require(process.env.WORK_TOP + '/dv/dce/env/dceAgent.js');
var _ = require('lodash');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');

module.exports = {
    formatFunc    : formatFunc,
    unitFunc      : unitFunc
    //getSetAddrMap : getSetAddrMap
}

function formatFunc(obj) {
    var retObj = paramUtil.extAllIntrlvAgents(obj);
    var isFound = 0;
    retObj.DceInfo.forEach(function(dce,i) {
	if((obj.instanceName) ? (dce.strRtlNamePrefix == obj.instanceName) : (isFound == 0)) {
        retObj.DutInfo = dce;
        retObj.Id = i;
	    isFound = 1;
	}
    });


//    retObj.DutInfo = retObj.DceInfo[0];

    retObj.Block = 'dce';
//    retObj.Id = '0';
//    retObj.BlockId = 'dce0';
    retObj.testBench = 'dce';
//    getSetAddrMap(retObj);
    if(obj.instanceName) {
	retObj.BlockId    = obj.instanceName;
	retObj.moduleName = obj.instanceMap[obj.instanceName];
    } else if(obj.instanceMap && (obj.dontUseInstanceName === undefined)) {
	retObj.BlockId    = obj.DutInfo.strRtlNamePrefix;
	retObj.moduleName = obj.instanceMap[obj.DutInfo.strRtlNamePrefix];
    } else {
	retObj.BlockId = 'dce0';
	retObj.moduleName = 'dce_0';
    }
    if(isFound) {
        perfCntUtil.updateRetObj(retObj);
    }
     return retObj;
}

function unitFunc(unitParam, pkgParams) {
//    var retObj = paramUtil.unitFuncKeepSmiArr(unitParam, pkgParams);
    var retObj = dceAgent.unitFunc(unitParam, pkgParams);
    if(pkgParams.instanceName)
	retObj.BlockId = pkgParams.instanceName;
    else
	retObj.BlockId = 'dce0';
    return retObj;
}

//function getSetAddrMap(obj) {
//    obj.AddrMap = [];
//    var mem_id = 0;
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
//	    obj.AddrMap[gp_id].HUT  = 1; //set 1 for DII
//	    obj.AddrMap[gp_id].Size = nSizeBytesToSize(obj.AddrMap[gp_id].Size,11); //set 0 for DMI
//	});
//	}
//}

function nSizeBytesToSize(nSizeBytes,ig_size) {
    return Math.ceil(Math.log2(nSizeBytes / ig_size)) - 12; // NCore3SysArch 4.5.2.13.1.1
}
