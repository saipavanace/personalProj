'use strict';

const common   = require('./common.js');

/*
 CAUTION: This function mutates original DV object.
  - Please do not overwrite parameters
  - Please review DV JSON to check for parameter and minimize duplication 
*/

function transform(dieObj, obj, baseDieName, idx) {
  common.transform(dieObj, obj);
  obj.Block = 'dii';
  
  if(dieObj.testBench === 'fsys'){
    obj.BlockId = obj.Block + idx;
  }

  obj.wData = obj.interfaces.axiInt.params.wData; // => Access this parameter as obj.DutInfo.wData in your .sv file
  obj.wAwId = obj.interfaces.axiInt.params.wAwId;
  obj.wArId = obj.interfaces.axiInt.params.wArId;
  // obj.wAddr = obj.interfaces.axiInt.params.wAddr;
  obj.wAwUser = obj.interfaces.axiInt.params.wAwUser;
  obj.wWUser = obj.interfaces.axiInt.params.wWUser;
  obj.wBUser = obj.interfaces.axiInt.params.wBUser;
  obj.wArUser = obj.interfaces.axiInt.params.wArUser;
  obj.wRUser = obj.interfaces.axiInt.params.wRUser;
}

module.exports = transform;