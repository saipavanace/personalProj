'use strict';

const paramUtil = require('../../scripts/formatParamUtilities');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');

function formatFunc(obj, fullsys=0) {
    var retObj = paramUtil.extAllIntrlvAgents(obj);
    var isFound = 0;

    var diiId  = 0;
    retObj.diiInfo = [];
    retObj.DiiInfo.forEach(function(agent) {
	if ((agent.configuration == "0") && (isFound == 0)) {
	    agent.Id          = diiId;
	    retObj.Id         = diiId;
            retObj.DutInfo    = agent;
	    retObj.diiInfo.push(agent);
	    if (fullsys == 0) {
		isFound        = 1;
	    }
	}
	diiId++;
    });

//    if (retObj.diiInfo.length === 0) {
//        throw new Error('ERROR! Cannot find dii0 instance');
//    }

    retObj.testBench  = 'dii';
    retObj.Block   = "dii";
    retObj.BlockId = retObj.Block + retObj.Id;

    return retObj;
}

function unitFunc(unitParam, pkgParams) {
    var retObj = paramUtil.unitFuncKeepSmiArr(unitParam, pkgParams);
    perfCntUtil.updateRetObj(retObj);
    return retObj;
}

module.exports = {
    formatFunc,
    unitFunc
}

