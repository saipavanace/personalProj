'use strict';

const common = require('./common.js');

/*
 CAUTION: This function mutates original DV object.
  - Please do not overwrite parameters
  - Please review DV JSON to check for parameter and minimize duplication 
*/

function transform(dieObj, obj, baseDieName, idx) {

  common.transform(dieObj, obj);
  obj.Block = 'io_aiu';

  if (dieObj.testBench === 'fsys') {
    obj.BlockId = 'ioaiu' + idx;
  }

  let paramsObj;
  if (obj.interfaces.axiInt.length > 1) {
    paramsObj = obj.interfaces.axiInt[0].params;
  } else {
    paramsObj = obj.interfaces.axiInt.params;
  }

  if (paramsObj.wData == 512){
    obj.wData = 256;
  }
  else{
    obj.wData = paramsObj.wData;
  }
  
  obj.wCdData = paramsObj.wCdData;
  obj.wAwId = paramsObj.wAwId;
  obj.wArId = paramsObj.wArId;
  obj.wAddr = paramsObj.wAddr;
  obj.wAwUser = paramsObj.wAwUser;
  obj.wWUser = paramsObj.wWUser;
  obj.wBUser = paramsObj.wBUser;
  obj.wArUser = paramsObj.wArUser;
  obj.wRUser = paramsObj.wRUser;
  obj.eAc = paramsObj.eAc;
  obj.eStarve = paramsObj.eStarve;
  obj.eAge = paramsObj.eAge;
  obj.wQos = paramsObj.wQos;
  obj.wRegion = paramsObj.wRegion;

  obj.nDataBanks = obj.ccpParams.nDataBanks;
  obj.nTagBanks = obj.ccpParams.nTagBanks;
  obj.nWays = obj.ccpParams.nWays;
  obj.nSets = obj.ccpParams.nSets;
  obj.RepPolicy = obj.ccpParams.RepPolicy;

  obj.fnCacheStates = "MOESI"; //TODO This must be cleaned up in the code

  for (let i = obj.nSmiTx - 1; i >= 0; i--) {
    if (obj.smiPortParams.tx[i].params.fnMsgClass.includes("cmd_req_")) {
      obj.cmdReqIntf = obj.smiPortParams.tx[i].name;
      obj.cmdReqIntf_tx_index = i;
    }
  }
  for (let i = obj.nSmiTx - 1; i >= 0; i--) {
    if (obj.smiPortParams.rx[i].params.fnMsgClass.includes("cmd_rsp_")) {
      obj.cmdRspIntf = obj.smiPortParams.rx[i].name;
      obj.cmdRspIntf_rx_index = i;
    }
  }

  obj.sftype = 'UNDEFINED';
  dieObj.SnoopFilterInfo.forEach(function (sf, i) {
    if (sf.SnoopFilterAssignment.indexOf(obj.FUnitId) !== -1) {
      obj.sfid = i;
      obj.sftype = sf.fnFilterType;
    }
  });

  obj.DceIds = '{' + dieObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
  for(var i = dieObj.DceInfo.length - 1; i >= 0; i--) {
    for(var j = 0; j<dieObj.DceInfo.length; j++) {
      if(dieObj.DceInfo[j].nUnitId == i)
        obj.DceIds += dieObj.DceInfo[j].FUnitId.toString(16);
    }
    if(i != 0)
      obj.DceIds += ',' + dieObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
  }
  obj.DceIds += '}';

  obj.DmiIds = '{' + dieObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
  for(var i = dieObj.DmiInfo.length - 1; i >= 0; i--) {
    for(var j = 0; j<dieObj.DmiInfo.length; j++) {
      if(dieObj.DmiInfo[j].nUnitId == i) 
        obj.DmiIds += dieObj.DmiInfo[j].FUnitId.toString(16);
    }
    if(i != 0)
      obj.DmiIds += ',' + dieObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
  }
  obj.DmiIds += '}';

  obj.DiiIds = '{' + dieObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
  for(var i = dieObj.DiiInfo.length - 1; i >= 0; i--) {
    for(var j = 0; j<dieObj.DiiInfo.length; j++) {
      if(dieObj.DiiInfo[j].nUnitId == i) 
        obj.DiiIds += dieObj.DiiInfo[j].FUnitId.toString(16);
      }
    if(i != 0)
      obj.DiiIds += ',' + dieObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
  }
  obj.DiiIds += '}';

  const DveIds = (dieObj.DveInfo.map(o => o.FUnitId.toString(16))).join(` ,${dieObj.Widths.Concerto.Ndp.Header.wFUnitId}'h`);
  obj.DveIds = `{${dieObj.Widths.Concerto.Ndp.Header.wFUnitId}'h${DveIds}}`;

  obj.ioaiuId = idx;
}

module.exports = transform;
