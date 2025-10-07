'use strict';

var paramUtil = require('../../scripts/formatParamUtilities.js');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');

function formatFunc(obj) {
    var retObj = paramUtil.extAllIntrlvAgents(obj);   
    retObj.Block = 'dce';
//    retObj.DceInfo.Id = '0';
//    retObj.BlockId = 'dce0';
//    retObj.testBench = 'dce';
    return retObj;
}

function unitFunc(unitParam, pkgParams) {
    var retObj = paramUtil.unitFuncKeepSmiArr(unitParam, pkgParams);
    perfCntUtil.updateRetObj(retObj);
    return retObj;
}

module.exports = {
    formatFunc: formatFunc,
    unitFunc: unitFunc
};
