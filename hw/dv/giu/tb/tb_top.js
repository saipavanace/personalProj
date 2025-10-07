'use strict';

const paramUtil = require('../../scripts/formatParamUtilities.js');
const giu_env  = require('../env/giu_env.js');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');

module.exports = {
    formatFunc       : formatFunc,
    unitFunc         : unitFunc
}

function formatFunc(obj) {
   var retObj = paramUtil.extAllIntrlvAgents(obj);
    // var retObj = giu_env.formatFunc(obj);
    // Take First GIU you find
    var isFound = 0;
    retObj.GiuInfo.forEach(function(giu, idx) {
        if(((obj.instanceName) ? (giu.strRtlNamePrefix == obj.instanceName) : (isFound == 0))) {
            retObj.DutInfo = giu;
            retObj.Id = idx;
            isFound = 1;
        }
    });

    if (retObj.DutInfo === undefined) {
        throw new Error('ERROR! This configuration does not have any GIU!');
    }
    
    if(obj.instanceName) {
        retObj.BlockId    = obj.instanceName;
        retObj.moduleName = obj.instanceMap[obj.instanceName];
    } else if(obj.instanceMap && (obj.dontUseInstanceName === undefined)) {
        retObj.BlockId    = obj.DutInfo.strRtlNamePrefix;
        retObj.moduleName = obj.instanceMap[obj.instanceName];
    } else {
        retObj.BlockId = 'giu0';
        retObj.moduleName = 'giu0';
    }
    retObj.Block = 'giu';
    retObj.testBench = 'giu';
 //   perfCntUtil.updateRetObj(retObj);
    return retObj;
}

function unitFunc(unitParam, pkgParams) {
    var retObj = giu_env.unitFunc(unitParam,pkgParams);
    if(pkgParams.instanceName)
        retObj.BlockId = pkgParams.instanceName;
    else
        retObj.BlockId = 'giu0';
 //   perfCntUtil.updateRetObj(retObj);
    return retObj;
}
