
var paramUtil = require(process.env.WORK_TOP + '/dv/scripts/formatParamUtilities.js')
var _ = require('lodash');
var diiAgent = require(process.env.WORK_TOP + '/dv/dii/env/diiAgent.js');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');
module.exports = {
    formatFunc : formatFunc,
    unitFunc   : unitFunc
}

function formatFunc(obj) {
//    var retObj  = paramUtil.extAllIntrlvAgents(obj);
    var retObj  = diiAgent.formatFunc(obj);
    var isFound = 0;
    var diiId   = 0;

    retObj.DiiInfo.forEach(function(agent) {
	if (((obj.instanceName) ?
	     (agent.strRtlNamePrefix == obj.instanceName) :
	     (agent.configuration == 0) && (isFound == 0) )) {
	    agent.Id       = diiId;
	    retObj.DutInfo = agent;
  	    isFound        = 1;
	} else if (isFound == 0) {
	    diiId++;
	}
    });

    if (isFound == 0) {
        throw new Error('ERROR! Cannot find dii0 instance');
    }

    //which tb
//    retObj.isTopLevel = 1;
    retObj.testBench = "dii"

    //which unit
    retObj.Id      = diiId;
    retObj.Block   = "dii";
    retObj.BlockId = retObj.Block + retObj.Id;
    perfCntUtil.updateRetObj(retObj);
    return retObj;
}

function unitFunc(unitParams,pkgParams) {
    var retObj = diiAgent.unitFunc(unitParams,pkgParams);
    
    //which unit

    if(pkgParams.instanceName) {
	retObj.BlockId = pkgParams.instanceName;
    } else {
//	retObj.Id      = retobj.I
	retObj.Block   = "dii";
	retObj.BlockId = pkgParams.Block + retObj.Id;
    }
    console.log('diiBlockId ' + retObj.BlockId);


    return retObj;
}
