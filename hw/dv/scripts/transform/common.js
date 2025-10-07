'use strict';

const fs = require('fs');
const path =require('path');
/*
 CAUTION: This function mutates original DV object.
  - Please do not overwrite parameters
  - Please review DV JSON to check for parameter and minimize duplication 
*/

function transform(dieObj, obj) {
  obj.BlockId = obj.strRtlNamePrefix;
  obj.Id = obj.nUnitId;
  obj.nSmiTx = obj.smiPortParams.tx.length;
  obj.nSmiRx = obj.smiPortParams.rx.length;
  obj.wCacheLineOffset = dieObj.system.concertocparams.wCacheLine;
  obj.wSecurityAttribute = dieObj.system.TrustZoneEnable ? 1 : 0;

  obj.SlvId = obj.nUnitId; // This must be cleaned

  if (dieObj.instanceMap) {
    obj.moduleName = dieObj.instanceMap[obj.strRtlNamePrefix];
  }

  obj.chiAiuIds = [];
  obj.ioAiuIds  = [];

  dieObj.IoaiuInfo.forEach(function(agent) {
    obj.ioAiuIds.push(agent.FUnitId);
  });
  
  dieObj.ChiaiuInfo.forEach(function(agent) {
    obj.chiAiuIds.push(agent.FUnitId);
  });

  dieObj.Clocks.forEach(function(clk) {
    if(clk.name === obj.unitClk[0])
        obj.clkPeriodPs = clk.params.period;
    });
}

function readJSON(file) {
	const text				= fs.readFileSync(path.resolve(file),'utf8');
	const jsonObj			= JSON.parse(text);
	return jsonObj;
}

module.exports = {
  transform,
  readJSON
}