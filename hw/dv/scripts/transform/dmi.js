'use strict';

const common = require('./common.js');
const path = require('path');

/*
 CAUTION: This function mutates original DV object.
  - Please do not overwrite parameters
  - Please review DV JSON to check for parameter and minimize duplication 
*/

function transform(dieObj, obj, baseDieName, idx) {
  obj.wData = obj.interfaces.axiInt.params.wData; // => Access this parameter as obj.DutInfo.wData in your .sv file
  obj.wAwId = obj.interfaces.axiInt.params.wAwId;
  obj.wArId = obj.interfaces.axiInt.params.wArId;
  // obj.wAddr = obj.interfaces.axiInt.params.wAddr;
  obj.wAwUser = obj.interfaces.axiInt.params.wAwUser;
  obj.wWUser = obj.interfaces.axiInt.params.wWUser;
  obj.wBUser = obj.interfaces.axiInt.params.wBUser;
  obj.wArUser = obj.interfaces.axiInt.params.wArUser;
  obj.wRUser = obj.interfaces.axiInt.params.wRUser;

  obj.nDataBanks = obj.ccpParams.nDataBanks;
  obj.nTagBanks = obj.ccpParams.nTagBanks;
  obj.nWays = obj.ccpParams.nWays;
  obj.nSets = obj.ccpParams.nSets;
  obj.RepPolicy = obj.ccpParams.RepPolicy;

  common.transform(dieObj, obj);
  obj.Block = 'dmi';
  if (dieObj.testBench === 'fsys') {
    obj.BlockId = obj.Block + idx;
  }

  if (dieObj.testBench !== 'cust_tb') {
    const diePrefix = baseDieName.trim.length > 0 ? `${baseDieName}_` : '';
    // TODO: Handle multi-die case
    const top_dmi_module_name = dieObj.instanceMap[obj.strRtlNamePrefix];
    const functional_unit_module_name = `${diePrefix}dmi_unit`;
    const fault_checker_module_name = `${diePrefix}u_dmi_fault_checker`;
    const dmi_top_attributes = common.readJSON(path.join(dieObj.ConfDirectory, 'rtl', `${top_dmi_module_name}.attr`));
    for (const els in dmi_top_attributes.attributes.instances) {
      if (dmi_top_attributes.attributes.instances[els].name === functional_unit_module_name) {
        obj.dmi_unit_attributes = common.readJSON(path.join(dieObj.ConfDirectory, 'rtl', `${dmi_top_attributes.attributes.instances[els].module}.attr`));
        break;
      }
    }

    for (const els in dmi_top_attributes.attributes.instances) {
      if (dmi_top_attributes.attributes.instances[els].name === fault_checker_module_name) {
        obj.dmi_fault_checker_attributes = common.readJSON(path.join(dieObj.ConfDirectory, 'rtl', `${dmi_top_attributes.attributes.instances[els].module}.attr`));
        break;
      }
    }
  }
}

module.exports = transform;