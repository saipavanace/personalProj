'use strict';

const paramUtil = require('../../../scripts/formatParamUtilities.js');
const _ = require('lodash');

function Reformat_axiInt(obj) {
  var retObj = _.cloneDeep(obj);
  var chiaiu_idx = 0;
  var ioaiu_idx  = 0;
  var axiaiu_idx  = 0;
  var aceliteeaiu_idx = 0;
  var aceaiu_idx  = 0;
  
  retObj.AllIoaiuInfo = [];
  for(var idx = 0; idx < retObj.AiuInfo.length; ++idx){    
    if((retObj.AiuInfo[idx].fnNativeInterface !== 'CHI-B') && (retObj.AiuInfo[idx].fnNativeInterface !== 'CHI-E') && (retObj.AiuInfo[idx].nNativeInterfacePorts == 1)){
      retObj.AiuInfo[idx].interfaces.axiInt = [obj.AiuInfo[idx].interfaces.axiInt];
    }
    if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-E')) {
      chiaiu_idx++;
    } else {
      ioaiu_idx += obj.AiuInfo[idx].nNativeInterfacePorts;
      for (var i = 0; i < obj.AiuInfo[idx].nNativeInterfacePorts; i++) {
        var ioaiu_obj = {aiuinfo_idx:idx,subio_idx:i};
        retObj.AllIoaiuInfo.push(ioaiu_obj);
      }
    }
    if((obj.AiuInfo[idx].fnNativeInterface == 'AXI4'|| obj.AiuInfo[idx].fnNativeInterface == 'AXI5' )) {
      axiaiu_idx += obj.AiuInfo[idx].nNativeInterfacePorts;
    } else if((obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')){
      aceliteeaiu_idx += obj.AiuInfo[idx].nNativeInterfacePorts;
    } else if((obj.AiuInfo[idx].fnNativeInterface == 'ACE' || obj.AiuInfo[idx].fnNativeInterface == 'ACE5' )){
      aceaiu_idx += obj.AiuInfo[idx].nNativeInterfacePorts;
    }    
  }
  retObj.chiaiu_nb       = chiaiu_idx;
  retObj.ioaiu_nb        = ioaiu_idx;
  retObj.axiaiu_nb       = axiaiu_idx;
  retObj.aceliteeaiu_nb  = aceliteeaiu_idx;
  retObj.aceaiu_nb       = aceaiu_idx;    
  return retObj;
}

function formatFunc(obj) {
    var format_obj = Reformat_axiInt(obj);
    var retObj = paramUtil.extAllIntrlvAgents(format_obj);
//    var retObj = paramUtil.extAllIntrlvAgents(obj);
    retObj.isTopLevel = 1;
    retObj.SNPS_PERF = 0;
    retObj.DISABLE_CDN_AXI5  = 0;
    retObj.testBench = 'cust_tb';
    return retObj;
}


module.exports = {
    formatFunc
}

