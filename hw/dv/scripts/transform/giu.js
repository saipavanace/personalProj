'use strict';

const common   = require('./common.js');

/*
 CAUTION: This function mutates original DV object.
  - Please do not overwrite parameters
  - Please review DV JSON to check for parameter and minimize duplication 
*/

function transform(dieObj, obj, baseDieName, idx) {
  obj.Block = 'giu';
  common.transform(dieObj, obj);
}

module.exports = transform;


