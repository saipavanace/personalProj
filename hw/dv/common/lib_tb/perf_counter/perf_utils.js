'use strict';
const jsonData = require('./event_list.json');

// obj pass by reference
function updateRetObj(obj) {
    // Return for now as we do not have perfCnt for giu
    if (obj.Block === 'giu') return;
    // console.log ('\x1b[43m Perf Monitor updateRetObj \x1b[m');
    obj.debuglistEventArr = debuglistEventPerfCntFunc(obj);
    obj.listEventArr = listEventPerfCntFunc(obj);

    var AgentInfoName = "AiuInfo";
    if (obj.DutInfo.Block === 'dce' || obj.DutInfo.Block === 'dve' || obj.DutInfo.Block === 'dmi' || obj.DutInfo.Block === 'dii') { AgentInfoName = "D" + obj.DutInfo.Block.match(/d[a-z]+/i)[0].slice(1) + "Info"; } // case dce0,dve1,dmi4 => D + ceInfo ,DveInfo,DmiInfo
    obj.AgentInfoName = AgentInfoName;
    obj.nPerfCounters = obj[AgentInfoName][obj.Id].nPerfCounters;
    obj.nLatencyCounters = obj[AgentInfoName][obj.Id].nLatencyCounters;

    // TMP fix
    obj.oldBlockId = ""; //init
    if (obj.testBench == 'io_aiu') {
        if (obj.AiuInfo[obj.Id].fnNativeInterface == "AXI4" || obj.AiuInfo[obj.Id].fnNativeInterface == "AXI5" || obj.AiuInfo[obj.Id].fnNativeInterface == "ACE-LITE" || obj.AiuInfo[obj.Id].fnNativeInterface == "ACELITE-E") {
            obj.oldBlockId = "ncaiu";
        }
        if (obj.AiuInfo[obj.Id].fnNativeInterface == "ACE" || obj.AiuInfo[obj.Id].fnNativeInterface == "ACE5") {
            obj.oldBlockId = "caiu";
        }

    }
    // end TMP fix
    obj.listEventStallName = [];
    if (obj.listEventArr.length) {
        obj.listEventStallName = [...obj.listEventArr.filter(e => e.type == "stall").map(e => e.name), ...[obj.listEventArr[0].name]]; // concat list event type= STALL & empty event  
    } else {
        obj.listEventArr.push({ evt_idx: 0, name: "Empty", itf_name: "empty", width: "0", type: "data" });  //TMP WAIT FIX FULLSYS 
    }
    // use MaxnPerfCounter in the array var size to avoid the error when nPerfCounters=0
    obj.MaxnPerfCounters = 8;
}

// return a list of Event used by perf monitor env
function listEventPerfCntFunc(obj) {
    var listEventArr = [];
    var listEventArr_agent = [];
    var listEventArr_ext = [];
    var agentStr = "";  //cf event_list.json = chi,ace,ncaiu,dmi,dii,dce,dve
    var extStr = ""; // cf event_list_.json = smc or proxy;
    var huntAgent = 1;

    if (obj.DutInfo.Block === 'dmi') { agentStr = "dmi"; huntAgent = 0; }
    if (huntAgent && obj.DutInfo.Block === 'dii') { agentStr = "dii"; huntAgent = 0; }
    if (huntAgent && obj.DutInfo.Block === 'dce') { agentStr = "dce"; huntAgent = 0; }
    if (huntAgent && obj.DutInfo.Block === 'dve') { agentStr = "dve"; huntAgent = 0; }
    if (huntAgent && (obj.DutInfo.BlockId.includes("ncaiu") || obj.DutInfo.BlockId.includes("ioaiu") || obj.AiuInfo[obj.Id].fnNativeInterface == "AXI4" || obj.AiuInfo[obj.Id].fnNativeInterface == "AXI5" || obj.AiuInfo[obj.Id].fnNativeInterface == "ACE-LITE" || obj.AiuInfo[obj.Id].fnNativeInterface == "ACELITE-E")) {
        agentStr = "ncaiu"; huntAgent = 0;
    }
    if (huntAgent) {
        if ((obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E')) {
            agentStr = "chi"; huntAgent = 0;
        }
    }
    if (huntAgent) {
        if (obj.AiuInfo[obj.Id].fnNativeInterface == "ACE" || obj.AiuInfo[obj.Id].fnNativeInterface == "ACE5") {
            agentStr = "ace"; huntAgent = 0;
        }
    }
    if (huntAgent && ((obj.testBench != "fsys") && (obj.testBench != "emu"))) {
        throw new Error(`!!! Can't find the Type of AGENT you don't passed the blockID to the obj or Update common/lib_tb/perf_counter/perf_utils.j !!!`);
    }
    if (obj.useCache) { extStr = "proxy"; }
    if (obj.useCmc) { extStr = "smc"; }

    // extract list of object from the JSON file
    listEventArr_agent = jsonData[agentStr];
    listEventArr_ext = jsonData[extStr].map(item => { // update evt_idx
        var clone_item = Object.assign({}, item); // need clone to modify a int (Node bug???)
        clone_item.evt_idx = item.evt_idx + listEventArr_agent.length - 1;
        return clone_item;
    });
    listEventArr = [...listEventArr_agent, ...listEventArr_ext]; //concat

    if (agentStr == "chi" || agentStr == "ace" || agentStr == "ncaiu") {
        // console.log ('abdelaziz obj.id: ', obj.Id);
        //console.log ('abdelaziz smi:', obj.AiuInfo[obj.Id].smiPortParams.tx);
        //console.log ('abdelaziz agentStr:', agentStr);
        if (obj.AiuInfo[obj.Id].smiPortParams.tx.length < 4) {
            listEventArr[4] = { "evt_idx": 4, "name": "Reserved_4" };
        }
        if (obj.AiuInfo[obj.Id].smiPortParams.rx.length < 4) {
            listEventArr[8] = { "evt_idx": 8, "name": "Reserved_8" };
        }
    }
    if (agentStr == "dii") {
        if (obj.DiiInfo[obj.Id].smiPortParams.tx.length < 4) {
            listEventArr[4] = { "evt_idx": 4, "name": "Reserved_4" };
        }
        if (obj.DiiInfo[obj.Id].smiPortParams.rx.length < 4) {
            listEventArr[8] = { "evt_idx": 8, "name": "Reserved_8" };
        }
    }
    if (agentStr == "dce") {
        if (obj.DceInfo[obj.Id].smiPortParams.tx.length < 4) {
            listEventArr[4] = { "evt_idx": 4, "name": "Reserved_4" };
        }
        if (obj.DceInfo[obj.Id].smiPortParams.rx.length < 4) {
            listEventArr[8] = { "evt_idx": 8, "name": "Reserved_8" };
        }
    }
    if (agentStr == "dve") {
        if (obj.DveInfo[obj.Id].smiPortParams.tx.length < 4) {
            listEventArr[4] = { "evt_idx": 4, "name": "Reserved_4" };
        }
        if (obj.DveInfo[obj.Id].smiPortParams.rx.length < 4) {
            listEventArr[8] = { "evt_idx": 8, "name": "Reserved_8" };
        }
    }
    if (agentStr == "dmi") {

        if (obj.DmiInfo[obj.Id].smiPortParams.tx.length < 5) {
            listEventArr[14] = { "evt_idx": 14, "name": "Reserved_14" };
        }
        if (obj.DmiInfo[obj.Id].smiPortParams.rx.length < 5) {
            listEventArr[15] = { "evt_idx": 15, "name": "Reserved_15" };
        }
    }
    return listEventArr;

}
// function use to try some case
function debuglistEventPerfCntFunc(obj) {
    var listEventArr = []; // list of String Name of each event depending of the Agent property (obj)

    listEventArr.push({ name: "Event1", itf_name: "event" },
        { name: "Event2" });
    if (obj.DutInfo.BlockId.includes("chi")) {
        listEventArr.push({ name: "ZiedEvent" });
    }
    listEventArr.push({ name: "LastEvent" });
    return listEventArr;
}

module.exports = {
    updateRetObj
}
