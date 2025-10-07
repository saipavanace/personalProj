'use strict';

const paramUtil = require(process.env.WORK_TOP + '/dv/scripts/formatParamUtilities.js');

function formatFunc(obj, fullsys=0) {
    var retObj = paramUtil.extAllIntrlvAgents(obj);
    var isFound = 0;

    var giuId  = 0;
    retObj.giuInfo = [];
    retObj.GiuInfo.forEach(function(agent) {
    if ((agent.configuration == "0") && (isFound == 0)) {
        agent.Id          = giuId;
        retObj.Id         = giuId;
            retObj.DutInfo    = agent;
        retObj.giuInfo.push(agent);
        if (fullsys == 0) {
            isFound        = 1;
        }
    }
    giuId++;
    });

    retObj.testBench  = 'giu';
    retObj.Block   = "giu";
    retObj.BlockId = retObj.Block + retObj.Id;

    return retObj;
}

function unitFunc(unitParam, pkgParams) {
    var retObj = paramUtil.unitFuncKeepSmiArr(unitParam, pkgParams);
    return retObj;
}

module.exports = {
    formatFunc : formatFunc,
    unitFunc   : unitFunc
}
