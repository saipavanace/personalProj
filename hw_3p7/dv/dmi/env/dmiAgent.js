'use strict';

var paramUtil = require('../../scripts/formatParamUtilities.js')
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');

function formatFunc(obj) {
    var retObj = paramUtil.extAllIntrlvAgents(obj);
    retObj.wMsgType = obj.Widths.Concerto.Ndp.Header.wXData;
    retObj.DmiInfo.forEach(function(dmi) {
        retObj.wXData   = dmi.interfaces.axiInt.params.wXData;

	if(obj.instanceMap && !obj.dontUseInstanceName)
	    dmi.BlockId = dmi.strRtlNamePrefix;
        retObj.wCcpAddr = obj.wSysAddr;
	retObj.nRttCtrlEntries = dmi.cmpInfo.nRttCtrlEntries;

    });
    retObj.testBench = 'dmi';
    return retObj;
}

function unitFunc(unitParam, pkgParams) {
    var retObj = paramUtil.unitFuncKeepSmiArr(unitParam, pkgParams);
    retObj.wData = unitParam.wData;
    retObj.wAddr = unitParam.wAddr;
    perfCntUtil.updateRetObj(retObj);
    return retObj;
}

module.exports = {
    formatFunc,
    unitFunc
}

