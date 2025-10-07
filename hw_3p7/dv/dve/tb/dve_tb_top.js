
var paramUtil = require('../../scripts/formatParamUtilities');
var sfiPriv_imp = require('../../../tb/sub_sys/lib/sfipriv_calc.js');
var csrJson = require('../../common/lib_tb/csr.json');
var dve_agent = require('../env/dve_agent.js');
var _ = require('lodash');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');

function formatFunc(obj) {
    var retObj = paramUtil.extAllIntrlvAgents(obj);
    var isFound = 0;
    retObj.DveInfo.forEach(function(dve,i) {
	if((obj.instanceName) ? (dve.strRtlNamePrefix == obj.instanceName) : (isFound == 0)) {
        retObj.DutInfo = dve;
        retObj.Id =i;
	    isFound = 1;
	}
    });
// ADD BlockId & fnNativeInterface to be able to run perf_cnt_test 
if(obj.instanceName) {
    retObj.BlockId    = obj.instanceName;
    retObj.moduleName = obj.instanceMap[obj.instanceName];
    } else if(obj.instanceMap && (obj.dontUseInstanceName === undefined)) {
    retObj.BlockId    = obj.DutInfo.strRtlNamePrefix;
    retObj.moduleName = obj.instanceMap[obj.instanceName];
    } else {
    retObj.BlockId = 'dve0';
    retObj.moduleName = 'dve_top_0';
    }

    retObj.CsrDef = csrJson;
    retObj.Block = 'dve';
    retObj.DveInfo.Id = '0';
    retObj.BlockId = 'dve0';
    retObj.isTopLevel = 1;
    retObj.testBench = 'dve';
    if (isFound) {perfCntUtil.updateRetObj(retObj);}
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
