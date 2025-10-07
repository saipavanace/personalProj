var paramUtil = require('../../scripts/formatParamUtilities.js');
var sfiPriv_imp = require('../../../tb/sub_sys/lib/sfipriv_calc.js');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');
  
var _ = require('lodash');

function formatFunc(obj) {
    var retObj  = paramUtil.extAllIntrlvAgents(obj);
    var dummyObj = {};
    
    retObj.Block = 'dve';
    retObj.DveInfo.Id = '0';
    retObj.Id = '0';
    retObj.BlockId = 'dve0';
    retObj.testBench = 'dve';
    perfCntUtil.updateRetObj(retObj);
    return retObj;
}

function unitFunc(unitParam, pkgParams) {
    var retObj = paramUtil.unitFuncKeepSmiArr(unitParam, pkgParams);
    perfCntUtil.updateRetObj(retObj);
    return retObj;
}

module.exports = {
    formatFunc : formatFunc,
    unitFunc   : unitFunc
}
