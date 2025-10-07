
var paramUtil  = require(process.env.WORK_TOP + '/dv/scripts/formatParamUtilities.js')
var ioaiuAgent = require(process.env.WORK_TOP + '/dv/ioaiu/env/ioaiuAgent.js');
var _ = require('lodash');
const perfCntUtil = require(process.env.WORK_TOP + '/dv/common/lib_tb/perf_counter/perf_utils.js');

module.exports = {
    formatFunc       : formatFunc,
    unitFunc         : unitFunc,
    nSizeBytesToSize : nSizeBytesToSize,
    getSetAddrMap    : getSetAddrMap
}

function formatFunc(obj) {
//    var retObj = paramUtil.extAllIntrlvAgents(obj);
    var retObj = ioaiuAgent.formatFunc(obj);

    var newAiuInfo = [];
    var dutAgent;
    //Take First IOAIU you find
    var isFound = 0;
    retObj.AiuInfo.forEach(function(agent,i) {
	if(((agent.fnNativeInterface == 'AXI4') || (agent.fnNativeInterface == "ACE") || (agent.fnNativeInterface == "ACE5") ||
	    (agent.fnNativeInterface == "ACE-LITE") || (agent.fnNativeInterface == "ACELITE-E") || (agent.fnNativeInterface == "AXI5"))
	   && ((obj.instanceName) ? (agent.strRtlNamePrefix == obj.instanceName) : (isFound == 0))) {
	    retObj.DutInfo = agent;
	    isFound = 1;
	}
    });
    
    if((retObj.DutInfo.fnNativeInterface == 'ACE') || (retObj.DutInfo.fnNativeInterface == 'ACE5'))
        retObj.useAceUniquePort = 1;
 
    retObj.DveIds = '{' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
    for(var i = retObj.DveInfo.length - 1; i >= 0; i--) {
        for(var j = 0; j<retObj.DveInfo.length; j++) {
            if(retObj.DveInfo[j].nUnitId == i)
                retObj.DveIds += retObj.DveInfo[j].FUnitId.toString(16);
        }
        if(i != 0)
            retObj.DveIds += ',' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
    }
    retObj.DveIds += '}';
    // retObj.DceIds = '{' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h' + retObj.DceInfo[0].FUnitId.toString(16);
    // for(var i=1;i<retObj.DceInfo.length;i++) {
	// retObj.DceIds += ',' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h' + retObj.DceInfo[i].FUnitId.toString(16);
    // };
    // retObj.DceIds += '}';
    retObj.DceIds = '{' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
    for(var i = retObj.DceInfo.length - 1; i >= 0; i--) {
        for(var j = 0; j<retObj.DceInfo.length; j++) {
            if(retObj.DceInfo[j].nUnitId == i)
                retObj.DceIds += retObj.DceInfo[j].FUnitId.toString(16);
        }
        if(i != 0)
            retObj.DceIds += ',' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
    }
    retObj.DceIds += '}';
    // retObj.DmiIds = '{' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h' + retObj.DmiInfo[0].FUnitId.toString(16);
    // for(var i=1;i<retObj.DmiInfo.length;i++) {
	// retObj.DmiIds += ',' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h' + retObj.DmiInfo[i].FUnitId.toString(16);
    // };
    // retObj.DmiIds += '}';
    retObj.DmiIds = '{' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
    for(var i = retObj.DmiInfo.length - 1; i >= 0; i--) {
        for(var j = 0; j<retObj.DmiInfo.length; j++) {
            if(retObj.DmiInfo[j].nUnitId == i) 
                retObj.DmiIds += retObj.DmiInfo[j].FUnitId.toString(16);
        }
        if(i != 0)
            retObj.DmiIds += ',' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
    }
    retObj.DmiIds += '}';
//    retObj.DiiIds = '{' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h' + retObj.DiiInfo[0].FUnitId.toString(16);
//    for(var i=1;i<retObj.DiiInfo.length;i++) {
//	retObj.DiiIds += ',' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h' + retObj.DiiInfo[i].FUnitId.toString(16);
//    };
//    retObj.DiiIds += '}';
    retObj.DiiIds = '{' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
    for(var i = retObj.DiiInfo.length - 1; i >= 0; i--) {
        for(var j = 0; j<retObj.DiiInfo.length; j++) {
            if(retObj.DiiInfo[j].nUnitId == i) 
                retObj.DiiIds += retObj.DiiInfo[j].FUnitId.toString(16);
        }
        if(i != 0)
            retObj.DiiIds += ',' + retObj.Widths.Concerto.Ndp.Header.wFUnitId + '\'h';
    }
    retObj.DiiIds += '}';
    getSetAddrMap(retObj);
    if(retObj.DutInfo === undefined)
	throw new Error("ERROR! This configuration does not have any IOAIU!");
    retObj.wSecurityAttribute = 1;
    retObj.Block = 'ioaiu';
    retObj.Id = retObj.DutInfo.Id;
//    if(obj.instanceName) {

    if(obj.instanceName) {
	retObj.BlockId    = obj.instanceName;
	retObj.moduleName = obj.instanceMap[obj.instanceName];
    } else if(obj.instanceMap && (obj.dontUseInstanceName === undefined)) {
	retObj.BlockId    = obj.DutInfo.strRtlNamePrefix;
	retObj.moduleName = obj.instanceMap[obj.instanceName];
    } else {
	retObj.BlockId = 'ioaiu0';
	retObj.moduleName = 'ioaiu_top_0';
    }

//    retObj.isTopLevel = 1;
    retObj.testBench = 'io_aiu';

    for(var i = retObj.DutInfo.nSmiTx - 1; i >= 0; i--) {
        if(retObj.DutInfo.smiPortParams.tx[i].params.fnMsgClass.includes("cmd_req_")) {
            retObj.cmdReqIntf = retObj.DutInfo.smiPortParams.tx[i].name;
            retObj.cmdReqIntf_tx_index = i;
        }
    }
    for(var i = retObj.DutInfo.nSmiTx - 1; i >= 0; i--) {
        if(retObj.DutInfo.smiPortParams.rx[i].params.fnMsgClass.includes("cmd_rsp_")) {
            retObj.cmdRspIntf = retObj.DutInfo.smiPortParams.rx[i].name;
            retObj.cmdRspIntf_rx_index = i;
        }
    }
    perfCntUtil.updateRetObj(retObj);
    return retObj;
}

function getSetAddrMap(obj) {
    obj.AddrMap = [];
    var mem_id = 0;
    obj.maxBaseAddr = 0;
/*
    obj.SysAddrRangeInfo.SysAddrRangeInfo.forEach(function(addr_map,mem_id) {
	var tempObj = {
	    "HUT"      : 0, //set 0 for DMI
	    "BaseAddr" : addr_map.nBaseAddr,
	    "Size"     : addr_map.nSizeBytes,
	};
	if((addr_map.nBaseAddr + addr_map.nSizeBytes) > obj.maxBaseAddr)
	    obj.maxBaseAddr = addr_map.nBaseAddr + addr_map.nSizeBytes;
	obj.AddrMap.push(tempObj);
    });
    for(var ig_id in obj.SysAddrRangeInfo.MInterlvGrpAddrMapInfo) {
	obj.SysAddrRangeInfo.MInterlvGrpAddrMapInfo[ig_id].forEach(function(gp_id) {
	    obj.AddrMap[gp_id].HUI  = ig_id;
	    obj.AddrMap[gp_id].HUT  = 0; //set 0 for DMI
	    obj.AddrMap[gp_id].Size = nSizeBytesToSize(obj.AddrMap[gp_id].Size,obj.DmiInfo[ig_id].nDmis); //set 0 for DMI
	});
    }
    for(var ig_id in obj.SysAddrRangeInfo.DIIAddrMapInfo) {
	obj.SysAddrRangeInfo.DIIAddrMapInfo[ig_id].forEach(function(gp_id) {
	    obj.AddrMap[gp_id].HUI  = ig_id;
	    obj.AddrMap[gp_id].HUT  = 1; //set 0 for DII
	    obj.AddrMap[gp_id].Size = nSizeBytesToSize(obj.AddrMap[gp_id].Size,11); //set 0 for DMI
	});
    }
  if(((obj.maxBaseAddr & 0xfffff) != 0) || (obj.maxBaseAddr < 0x100000))
	obj.maxBaseAddr = obj.maxBaseAddr + 0x100000;
*/
}
function nSizeBytesToSize(nSizeBytes,ig_size) {
    return Math.ceil(Math.log2(nSizeBytes / ig_size)) - 12; // NCore3SysArch 4.5.2.13.1.1
}
function unitFunc(unitParam, pkgParams) {
    var retObj = ioaiuAgent.unitFunc(unitParam, pkgParams);

    if(pkgParams.instanceName)
	retObj.BlockId = pkgParams.instanceName;
    else
	retObj.BlockId = 'ioaiu0';
    return retObj;
}
