
var paramUtil = require(process.env.WORK_TOP + '/dv/scripts/formatParamUtilities.js')
var dmiAgent  = require(process.env.WORK_TOP + '/dv/dmi/env/dmiAgent.js');
var _ = require('lodash');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');
const lib_util = require(process.env.WORK_TOP + '/dv/dmi/tb/lib_utils.js');
var fs = require("fs");

function formatFunc(obj) {
//    var retObj = paramUtil.extAllIntrlvAgents(obj);
    var retObj = dmiAgent.formatFunc(obj);
    var dummyObj = {};

    retObj.testBench = "dmi";
//    retObj.Id = "0";
//    retObj.Block = "dmi";
//    retObj.BlockId = "dmi0";
    var isFound = 0;
    retObj.DmiInfo.forEach(function(agent,i) {
	if(((obj.instanceName) ? (agent.strRtlNamePrefix == obj.instanceName) : (isFound == 0))) {
        retObj.DutInfo = agent;
        retObj.Id = i;
	    isFound = 1;
	}
    });
    retObj.useCmc = retObj.DutInfo.useCmc;
    
    var rtl_path=obj.ConfDirectory+"/rtl/"
    var top_dmi_module_name = obj.instanceMap[obj.instanceName];
    var fucntional_unit_module_name = "dmi_unit";
    var fault_checker_module_name = "u_dmi_fault_checker";

    var dmi_top_attributes=lib_util.readJSON(rtl_path+top_dmi_module_name+".attr");

    for (els in dmi_top_attributes.attributes.instances){
        if (dmi_top_attributes.attributes.instances[els].name == fucntional_unit_module_name){
            var dmi_unit_attributes=lib_util.readJSON(rtl_path+dmi_top_attributes.attributes.instances[els].module+".attr");
        }
    }

    for (els in dmi_top_attributes.attributes.instances){
        if (dmi_top_attributes.attributes.instances[els].name == fault_checker_module_name){
            var dmi_fault_checker_attributes=lib_util.readJSON(rtl_path+dmi_top_attributes.attributes.instances[els].module+".attr");
        }
    }

    retObj.dmi_unit_attributes = dmi_unit_attributes;
    retObj.dmi_fault_checker_attributes = dmi_fault_checker_attributes;
    // ADD BlockId & fnNativeInterface to be able to run perf_cnt_test 
    if(obj.instanceName) {
        retObj.BlockId    = obj.instanceName;
        retObj.moduleName = obj.instanceMap[obj.instanceName];
        } else if(obj.instanceMap && (obj.dontUseInstanceName === undefined)) {
        retObj.BlockId    = obj.DutInfo.strRtlNamePrefix;
        retObj.moduleName = obj.instanceMap[obj.instanceName];
        } else {
        retObj.BlockId = 'dmi0';
        retObj.moduleName = 'dmi_top_0';
        }
    if (isFound) {perfCntUtil.updateRetObj(retObj);}
    return retObj;
}
function unitFunc(unitParam, pkgParams) {
    //    var retObj = paramUtil.unitFuncKeepSmiArr(unitParam, pkgParams);
    var retObj = dmiAgent.unitFunc(unitParam, pkgParams);
    retObj.BlockId = retObj.Block + retObj.Id;
    return retObj;
}

module.exports = {
    formatFunc : formatFunc,
    unitFunc   : unitFunc
}

