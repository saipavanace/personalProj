var _ = require('lodash');
var ccpAgent = require(process.env.WORK_TOP + '/dv/ccp/env/ccpAgent.js');
module.exports = {
    formatFunc       : formatFunc,
    unitFunc         : unitFunc
}

function formatFunc(obj) {
    var retObj = ccpAgent.formatFunc(obj);
    retObj.DmiCcpInfo = [];
    retObj.DmiInfo.forEach(function(agent) {
            retObj.DmiCcpInfo.push(agent);
    });
    retObj.DutInfo = retObj.DmiCcpInfo[0].ccpParams;
    retObj.Block = 'dmi';
   if(obj.instanceName) {
        retObj.BlockId    = obj.instanceName;
        retObj.moduleName = obj.instanceMap[obj.instanceName];
    } else if(obj.instanceMap && (obj.dontUseInstanceName === undefined)) {
        retObj.BlockId    = obj.DutInfo.strRtlNamePrefix;
        retObj.moduleName = obj.instanceMap[obj.instanceName];
    } else {
        retObj.BlockId = 'ccp0';
        retObj.moduleName = 'fsys_hw_config_54_ccp_top_a';
   }

    return retObj;
}
function unitFunc(unitParam, pkgParams) {
    var retObj = ccpAgent.unitFunc(unitParam,pkgParams); 
    if(pkgParams.instanceName)
        retObj.BlockId = pkgParams.instanceName;
    else
        retObj.BlockId = 'ccp0';
    retObj.testbench = 'ccp';
    return retObj;
}
