'use strict';

const paramUtil = require('../../scripts/formatParamUtilities');
// const sfiPriv_imp = require('../../../tb/sub_sys/lib/sfipriv_calc');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');

function formatFunc(obj) {
    //    var retObj = _.cloneDeep(obj);
    var retObj = paramUtil.extAllIntrlvAgents(obj);
    //    var dummyObj = {};
    
    //    dummyObj.param = _.cloneDeep(retObj);
    //    dummyObj.log2ceil = function number(a) { return Math.ceil(Math.log2(a)); }
    //    retObj.sfipriv_calc = sfiPriv_imp(dummyObj, console);
    var ioaiuId = 0;
    retObj.IoAiuInfo = [];
    retObj.AiuInfo.forEach(function(agent) {
        if((agent.fnNativeInterface == 'AXI4') || (agent.fnNativeInterface == 'ACE') || (agent.fnNativeInterface == 'ACE5')
	   || (agent.fnNativeInterface == 'ACE-LITE') || (agent.fnNativeInterface == 'ACELITE-E') || (agent.fnNativeInterface == 'AXI5')) {
	    //	    agent.Id = ioaiuId;
	    if(obj.instanceMap && !obj.dontUseInstanceName)
		agent.BlockId = agent.strRtlNamePrefix;
	    agent.ioaiuId = ioaiuId;
	    ioaiuId++;
            retObj.IoAiuInfo.push(agent);
        }
    });

    //if (retObj.IoAiuInfo.length == 0) {
    //    throw new Error('ERROR! This configuration does not have any IOAIU!');
    //}
    retObj.wSecurityAttribute = 1; //for 3.1 Security is always on
    retObj.Block = 'io_aiu';
    retObj.BlockId = 'io_aiu0';
    retObj.testBench = 'io_aiu';
    retObj.DceIds = '{' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h' + retObj.DceInfo[0].FUnitId.toString(16);
    for(var i=1;i<retObj.DceInfo.length;i++) {
	retObj.DceIds += ',' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h' + retObj.DceInfo[i].FUnitId.toString(16);
    };
    retObj.DceIds += '}';
    return retObj;
}

function unitFunc(unitParam, pkgParams) {
    var retObj = paramUtil.unitFuncKeepSmiArr(unitParam, pkgParams);
    if (unitParam.wData == 512) {
        retObj.wData = 256;
    } else {
        retObj.wData = unitParam.wData;
    }
    retObj.dvHasQos      = unitParam.eAge && unitParam.eStarve && (unitParam.QosInfo.qosMap.length > 0);

//    var newAgent = translateIoAiu(retObj);
    findSfType(retObj);
    retObj.isDvmReceive = retObj.eAc;
    retObj.isDvmSend    = retObj.nDvmMsgInFlight > 0;
    if(retObj.useCache) {
	retObj.fnCacheStates   = "MOESI"; //DCTODO This is only for 3.0 when it's always MOESI
	retObj.usePartialFill  = 1;
    }
    retObj.fnCacheStates   = "MOESI"; //BINGJ: 3.0 ccp is using MOESI state model
    retObj.MaxCreditPerDCE = unitParam.Credits.MaxCreditPerDCE;
    retObj.MaxCreditPerDMI = unitParam.Credits.MaxCreditPerDMI;
    retObj.MaxCreditPerDII = unitParam.Credits.MaxCreditPerDII;
    retObj.wAddr           = unitParam.wAddr;
    retObj.AxIdProcSelectBits = unitParam.AxIdProcSelectBits;
    retObj.Block = 'io_aiu';
//    if(pkgParams.instanceMap)
//	retObj.BlockId = unitParam.strRtlNamePrefix;
    retObj.wAxData = retObj.wData;
    retObj.ODB = retObj.nOttDataBanks;
    retObj.ODDW = retObj.wAxData + (retObj.wAxData/8) + 1;
    retObj.CLO = !retObj.useCache ? 6 : unitParam.ccpParams.wCacheLineOffset;
    retObj.OCN = retobj.DutInfo.cmpInfo.nOttCtrlEntries;
    retObj.OLN = retObj.OCN;
    retObj.ODN = retObj.OLN * (1<<retObj.CLO)/(retObj.wAxData/8);
    retObj.ODM = ((retObj.ODN*retObj.ODDW/retObj.ODB)<1024*8) ? 0 : 1;
    perfCntUtil.updateRetObj(retObj);
    return retObj;
}

function findSfType(retObj) {
    var sfid, sftype;
    var wrevict = 0;
    retObj.sftype = "UNDEFINED";
    if(retObj.useCache) {
	retObj.SnoopFilterInfo.forEach(function(sf,i) {
	    if(sf.SnoopFilterAssignment.indexOf(retObj.FUnitId) > -1) {
		retObj.sfid = i;
		retObj.sftype = sf.fnFilterType;
	    }
	});					      
    }
}

function translateIoAiu(cluster,path,top_cluster) {
    var retCluster = {};
    switch(path) {
    case "isBridgeInterface" : {
	
    }
    case "DVMEnable" : {
	
    }
    case "isBridgeInterface" : {
	return 1;
    }
    case "isBridgeInterface" : {
	
    }
	
    default : {
	throw new Error("ERROR! parameter " + path + " does not have a mapping!");
    }
    }
    if(!isLeaf) {
	for(var key in cluster) {
	    retCluster = translateIoAiu(cluster[key], path + '.' + key, top_cluster);
	}
    }
}
module.exports = {
    formatFunc,
    unitFunc,
    translateIoAiu
}


