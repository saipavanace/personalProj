'use strict';

const paramUtil = require('../../scripts/formatParamUtilities.js');
const csrJson = require('../../common/lib_tb/csr.json');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');

function formatFunc(obj, fullsys = 0) {
    var retObj  = paramUtil.extAllIntrlvAgents(obj);
    var isFound = false;
    
    retObj.chiAiu = [];
    var aiu_id = 0;
    retObj.AiuInfo.forEach(function(agent) {
        if( ((agent.fnNativeInterface === 'CHI-A') || (agent.fnNativeInterface === 'CHI-B') || (agent.fnNativeInterface === 'CHI-E')) && !isFound) {
	    agent.Id = aiu_id;
	    if(obj.instanceMap && !obj.dontUseInstanceName)
		agent.BlockId = agent.strRtlNamePrefix;
            retObj.chiAiu.push(agent);
            if(fullsys === 0) {
        isFound = true;
            }   
        }
	   aiu_id++;
    });

    if (retObj.chiAiu.length > 0) {
 //       throw new Error('ERROR! This configuration does not have any CHI AIU!');
        retObj.DutInfo = retObj.chiAiu[0];
        retObj.useQos = retObj.chiAiu[0].interfaces.chiInt.params.wQos;
        retObj.Id    = retObj.chiAiu[0].Id;
    } else {
        retObj.Id    = 0; // TMP to avoid error when  cfg with ACE only case ( why chi.js is running when there is none chi ?)
    };
    retObj.CsrDef = csrJson;
    retObj.Block = "chi_aiu";
    if(obj.instanceName) {
        retObj.BlockId    = obj.instanceName;
        retObj.moduleName = obj.instanceMap[obj.instanceName];
        } else if(obj.instanceMap && (obj.dontUseInstanceName === undefined)) {
        retObj.BlockId    = obj.DutInfo.strRtlNamePrefix;
        retObj.moduleName = obj.instanceMap[obj.instanceName];
        } else {
        retObj.BlockId = 'chi_aiu0';
        retObj.moduleName = 'chiaiu0';
        }    
    perfCntUtil.updateRetObj(retObj);
    return retObj;
}

function unitFunc(unitParam, pkgParams) {
    var retObj = paramUtil.unitFuncKeepSmiArr(unitParam, pkgParams);
    retObj.Block = "chi_aiu";
    perfCntUtil.updateRetObj(retObj);
    return retObj;
}

module.exports = {
    formatFunc,
    unitFunc
};
