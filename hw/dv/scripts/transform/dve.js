'use strict';

const common   = require('./common.js');

/*
 CAUTION: This function mutates original DV object.
  - Please do not overwrite parameters
  - Please review DV JSON to check for parameter and minimize duplication 
*/

function transform(dieObj, obj, baseDieName, idx) {
  common.transform(dieObj, obj);

  obj.Block = 'dve';
  if(dieObj.testBench === 'fsys'){
    obj.BlockId = obj.Block + idx;
  }
}

module.exports = transform;


