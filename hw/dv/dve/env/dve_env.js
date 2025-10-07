'use strict';

var paramUtil = require('../../scripts/formatParamUtilities.js');
var sfiPriv_imp = require('../../../tb/sub_sys/lib/sfipriv_calc.js');

function formatFunc(obj) {
    var retObj  = paramUtil.extAllIntrlvAgents(obj);
    
    retObj.Block = 'dve';
    retObj.DveInfo.Id = '0';
    retObj.Id = '0';
    retObj.BlockId = 'dve0';
    retObj.testBench = 'dve';
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
