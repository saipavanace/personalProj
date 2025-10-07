'use strict';

/*
 CAUTION: This function mutates original DV object.
  - Please do not overwrite parameters
  - Please review DV JSON to check for parameter and minimize duplication 
*/

function transform(dieObj, obj, baseDieName, idx) {

  obj.Block = 'apb_debug';
  obj.BlockId = 'apb_debug';
  obj.Id = idx;
}

module.exports = transform;