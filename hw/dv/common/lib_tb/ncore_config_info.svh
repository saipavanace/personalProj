//
//Static configuration information of Ncore system that
//is wrapped in SV static data structures. These structures
//are used by various DV components that require access to 
//configuration information
//

<%
//logicaId (CPU unit IDs ace L1 cache per CPU assumption)
const selectBits = [];
const agentSelectBitValue = [];
const logicalId2AgentIdMap = [];
const wSelectBits = [];
const wEndpoint = [];
const agentsAxiAddr = [];
const agentsSfiAddr = [];
var maxAxiAddrWidth = 0;
var maxAxiIdWidth = 0;
var minAxiAddrWidth = 1024;
var maxAxiDataWidth = 0;
var minAxiDataWidth = 1024;
const agentInfType = [];
const stashEnable  = [];
const owoEnable  = [];
const maxProcs       = [];

//Various agent ID's w.r.t bundles in configParams
const aiuIds = [];
const dceIds = [];
const dveIds = [];
const dmiIds = [];
const diiIds = [];
const giuIds = [];

const aiuNIds = [];
const dceNIds = [];
const dveNIds = [];
const dmiNIds = [];
const diiNIds = [];
const giuNIds = [];

const dmiUseAtomic = [];//atomic feature in each DMIs
const stashNids = [];
const stashNids_ace_aius = [];
const stashNids_target_ace_aius = [];
const stashNids_target_axi_aius = [];
const stashNids_target_chi_aius = [];
const stashNids_non_chi_aius = [];
const stashNids_forbidden = [];
let computedAxiInt;
const chiAiuIds = [];
const ioAiuIds  = [];
obj.AiuInfo.forEach(function(agent) {
    if(agent.fnNativeInterface.includes('CHI')) {
        chiAiuIds.push(agent.FUnitId);
    } else {
        ioAiuIds.push(agent.FUnitID);
    }
});

obj.AiuInfo.forEach(function(bundle, indx) {
    aiuIds.push(indx);
    aiuNIds.push(bundle.nUnitId);
    if (!bundle.fnNativeInterface.match("CHI")) {stashNids_forbidden.push(bundle.FUnitId);stashNids_non_chi_aius.push(bundle.FUnitId)} // add id which doesn't support stash snoop 
    if (bundle.fnNativeInterface.match("ACE") || bundle.fnNativeInterface.match("ACE5")) stashNids_ace_aius.push(bundle.FUnitId); // Add id of ACE AIUs which doesnt support stash snoop, but is a valid stash target
    if (bundle.fnNativeInterface.match(/\bACE\b(?!-)/g) || bundle.fnNativeInterface.match("ACE5")) stashNids_target_ace_aius.push(bundle.FUnitId); 
    //if (bundle.fnNativeInterface.match("ACELITE-E")) stashNids_ace_aius.push(bundle.FUnitId); // Add id of ACELITE-E AIUs which doesnt support stash snoop, but is a valid stash target
    if ((bundle.fnNativeInterface.match("AXI4") || bundle.fnNativeInterface.match("AXI5")) && (bundle.useCache)) stashNids_ace_aius.push(bundle.FUnitId); // Add id of AXI4 w ProxyCache AIUs which doesnt support stash snoop, but is a valid stash target
    if ((bundle.fnNativeInterface.match("AXI4") || bundle.fnNativeInterface.match("AXI5")) && (bundle.useCache)) stashNids_target_axi_aius.push(bundle.FUnitId); 
    if (bundle.fnNativeInterface.match("CHI")) stashNids_target_chi_aius.push(bundle.FUnitId); 
});

obj.DceInfo.forEach(function(bundle, indx) {
    dceIds.push(aiuIds.length + indx);
    dceNIds.push(bundle.nUnitId);
    stashNids_forbidden.push(bundle.FUnitId); 
});

obj.DmiInfo.forEach(function(bundle, indx) {
    dmiIds.push(aiuIds.length + dceIds.length + indx);
    dmiNIds.push(bundle.nUnitId);
    stashNids_forbidden.push(bundle.FUnitId); 
});

obj.DiiInfo.forEach(function(bundle, indx) {
      diiIds.push( aiuIds.length + dceIds.length + dmiIds.length + indx);
      diiNIds.push(bundle.nUnitId);
      stashNids_forbidden.push(bundle.FUnitId);
});

if (obj.GiuInfo && obj.GiuInfo.length > 0) {
obj.GiuInfo.forEach(function(bundle, indx) {
    giuIds.push(aiuIds.length + dceIds.length + dmiIds.length + diiIds.length + indx);
    giuNIds.push(bundle.nUnitId);
    stashNids_forbidden.push(bundle.FUnitId); 
});

obj.DveInfo.forEach(function(bundle, indx) {
    dveIds.push(aiuIds.length + dceIds.length + dmiIds.length + diiIds.length + giuIds.length + indx);
    stashNids_forbidden.push(bundle.FUnitId); 
    stashNids_forbidden.push(bundle.FUnitId+1); // dve is the last agent && add agent id doesn't exist
});

} else {

obj.DveInfo.forEach(function(bundle, indx) {
    dveIds.push(aiuIds.length + dceIds.length + dmiIds.length + diiIds.length + indx);
    stashNids_forbidden.push(bundle.FUnitId); 
    stashNids_forbidden.push(bundle.FUnitId+1); // dve is the last agent && add agent id doesn't exist
});

}

obj.DmiInfo.forEach(function(bundle, indx) {
    dmiUseAtomic.push(bundle.useAtomic); //useAtomic is ordered per NUnitID
});

chiAiuIds.forEach(function(bundle, indx) {
    stashNids.push(chiAiuIds[indx]);
});

function funitids() {
  const arr = [];

  obj.AiuInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });

  
  obj.DceInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });
  
  obj.DmiInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });
  
  obj.DiiInfo.forEach(function(bundle, indx) {
           arr.push(bundle.FUnitId);
  });

  obj.DveInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });

if (obj.GiuInfo && obj.GiuInfo.length > 0) {
  obj.GiuInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });
}

  return arr;
};

//TODO FIXME
var prtAbstract = function(b, s, l1, l2) {
  var tt = 0;
  var lg = 0;
  var nPorts = 1; //tied to 1 until we understand the implementation
  b.forEach(function(p, indx) {
    tt += 1;
    l1[lg] = [];
    l2[lg] = [];

    if (nPorts === 1) {
      l1[lg].push(s + indx);
      l2[lg].push(0);
    } else {
      for (let i = 0; i < nPorts; i++) {
        l1[lg].push(s + indx + i);
        l2[lg].push(i);
      }
    }
    lg++;
  });

  return tt;
};

//**************************************************************
//CONC-1022 
//Do not sort. element[0] of bits array is the LSB
//Example: Consider AIU port select bits 
// APF: 12,11 
//JSON: 11, 12 (reversed)
//Actual RTL must  make sure to capture GUI intent
// 12 11
// 0  0   AIU0
// 0  1   AIU1
// 1  0   AIU2
// 1  1   AIU3
//*************************************************************

let nLogaius = 0;
const nLogaiuQ = [];
const nLogaiuP = [];

let nLogdces = 0;
const nLogdceQ = [];
const nLogdceP = [];

let nLogdves = 0;
const nLogdveQ = [];
const nLogdveP = [];

let nLoggius = 0;
const nLoggiuQ = [];
const nLoggiuP = [];

let nLogdmis = 0;
const nLogdmiQ = [];
const nLogdmiP = [];

let nLogdiis = 0;
const nLogdiiQ = [];
const nLogdiiP = [];

let aiuBid = 0;
let dceBid = aiuIds.length;
let dmiBid = aiuIds.length + dceIds.length;
let diiBid = aiuIds.length + dceIds.length + dmiIds.length;
let giuBid = aiuIds.length + dceIds.length + dmiIds.length + diiIds.length;
let dveBid = aiuIds.length + dceIds.length + dmiIds.length + diiIds.length;
if (obj.GiuInfo && obj.GiuInfo.length > 0) {
  dveBid += giuIds.length;
}

nLogaius = prtAbstract(obj.AiuInfo, aiuBid, nLogaiuQ, nLogaiuP);
nLogdmis = prtAbstract(obj.DmiInfo, dmiBid, nLogdmiQ, nLogdmiP);
nLogdiis = prtAbstract(obj.DiiInfo, diiBid, nLogdiiQ, nLogdiiP);
if (obj.GiuInfo && obj.GiuInfo.length > 0) {
  nLoggius = prtAbstract(obj.GiuInfo, giuBid, nLoggiuQ, nLoggiuP);
}
nLogdces = obj.DceInfo.length;
nLogdves = 1;
nLogdveQ.push(dveBid);
nLogdveP.push(0);

const fillDceVal = function(a, c) {
  if (a == 0) {
    nLogdceQ.push(c);
    nLogdceP.push(0);
  } else {
    let i;
    for (i = 0; i < a; i++) 
      nLogdceQ.push(c + i);
      nLogdceP.push(i);
  }
};


fillDceVal(obj.DceInfo.length, dceBid);

function addrTransMgr(cohAgents, initSeed) {

    cohAgents.forEach(function(bundle, index, array) {
        
        //populate stashEnable
        if(bundle.fnNativeInterface === "CHI-B" || bundle.fnNativeInterface === "CHI-E") {
            stashEnable.push(1);
        } else {
            stashEnable.push(0);
        }

        //populate owoEnable
        if (bundle.orderedWriteObservation) {
            owoEnable.push(1);
        } else {
            owoEnable.push(0);
        }

        if((bundle.fnNativeInterface === "ACE") || (bundle.fnNativeInterface === "ACE5")) {
            agentInfType.push(0);

        } else if ((bundle.fnNativeInterface === "AXI4") || (bundle.fnNativeInterface === "AXI5")) {
            if(bundle.useCache) {
                agentInfType.push(5);
            } else {
                agentInfType.push(4);
            }

        } else if (bundle.fnNativeInterface === "CHI-A") {
            agentInfType.push(2);

        } else if (bundle.fnNativeInterface === "CHI-B") {
      agentInfType.push(3);

        } else if (bundle.fnNativeInterface === "CHI-E") {
      agentInfType.push(7);

  }else if(bundle.fnNativeInterface === "ACELITE-E") {
            agentInfType.push(6);

        } else if(bundle.fnNativeInterface === "ACE-LITE") {
            if (bundle.isBridgeInterface) {
                if (bundle.useCache)
                  agentInfType.push(5);
                else
                  agentInfType.push(1);
            } else {
                agentInfType.push(1);
            }
                 
        } else {
            console.log('Unexpeced interface type ' + bundle.fnNativeInterface);
            throw "Unexpected interface type";
        }
    
        wSelectBits.push(0);

        //Assigning ProcID's
        if ((bundle.fnNativeInterface === "CHI-A")||(bundle.fnNativeInterface === "CHI-B") || (bundle.fnNativeInterface === "CHI-E")) {
            maxProcs.push(bundle.nProcs);
        }

        if((bundle.fnNativeInterface === "ACE") || (bundle.fnNativeInterface === "ACE5")) {
            maxProcs.push(bundle.nProcs);
        }
    
        if ((bundle.fnNativeInterface === "CHI-A")||(bundle.fnNativeInterface === "CHI-B") || (bundle.fnNativeInterface === "CHI-E")) {
            agentsAxiAddr.push(bundle.interfaces.chiInt.params.wAddr);
            if(bundle.interfaces.chiInt.params.wAddr > maxAxiAddrWidth) 
                maxAxiAddrWidth = bundle.interfaces.chiInt.params.wAddr;
            if(bundle.interfaces.chiInt.params.wAddr < minAxiAddrWidth) 
                minAxiAddrWidth = bundle.interfaces.chiInt.params.wAddr;
            if(bundle.interfaces.chiInt.params.wData > maxAxiDataWidth) 
                maxAxiDataWidth = bundle.interfaces.chiInt.params.wData;
            if(bundle.interfaces.chiInt.params.wData < minAxiDataWidth) 
                minAxiDataWidth = bundle.interfaces.chiInt.params.wData;
        }
        else {
            if(Array.isArray(bundle.interfaces.axiInt)) {
            if(bundle.interfaces.axiInt[0].params.wAwId > maxAxiIdWidth) 
                maxAxiIdWidth = bundle.interfaces.axiInt[0].params.wAwId;
            agentsAxiAddr.push(bundle.interfaces.axiInt[0].params.wAddr);
            if(bundle.interfaces.axiInt[0].params.wAddr > maxAxiAddrWidth) 
                maxAxiAddrWidth = bundle.interfaces.axiInt[0].params.wAddr;
            if(bundle.interfaces.axiInt[0].params.wAddr < minAxiAddrWidth) 
                minAxiAddrWidth = bundle.interfaces.axiInt[0].params.wAddr;
            if(bundle.interfaces.axiInt[0].params.wData > maxAxiDataWidth) 
                maxAxiDataWidth = bundle.interfaces.axiInt[0].params.wData;
            if(bundle.interfaces.axiInt[0].params.wData < minAxiDataWidth) 
                minAxiDataWidth = bundle.interfaces.axiInt[0].params.wData;
            } else {
            if(bundle.interfaces.axiInt.params.wAwId > maxAxiIdWidth) 
                maxAxiIdWidth = bundle.interfaces.axiInt.params.wAwId;
            agentsAxiAddr.push(bundle.interfaces.axiInt.params.wAddr);
            if(bundle.interfaces.axiInt.params.wAddr > maxAxiAddrWidth) 
                maxAxiAddrWidth = bundle.interfaces.axiInt.params.wAddr;
            if(bundle.interfaces.axiInt.params.wAddr < minAxiAddrWidth) 
                minAxiAddrWidth = bundle.interfaces.axiInt.params.wAddr;
            if(bundle.interfaces.axiInt.params.wData > maxAxiDataWidth) 
                maxAxiDataWidth = bundle.interfaces.axiInt.params.wData;
            if(bundle.interfaces.axiInt.params.wData < minAxiDataWidth) 
                minAxiDataWidth = bundle.interfaces.axiInt.params.wData;
            }
  }
        agentsSfiAddr.push(obj.wSysAddr);
    });
}

const nMems = function() {
  if (!obj.useCsrProgrammedAddrRangeInfo)
    return obj.SysAddrRangeInfo.nSysAddrRanges;
  return 0;
};

const IGSV = [];
const intrlvGrp2SysAddrMap = [];
const intrlvGrpType        = [];
const memRegionBoundaries  = [];
let nMemGrps             = 0;

function dmiInfo() {
  let baseId = obj.AiuInfo.length + obj.DceInfo.length;

  if (!obj.useCsrProgrammedAddrRangeInfo) {
    obj.SysAddrRangeInfo.SysAddrRangeInfo.forEach(function(bundle) {
      const bound = {
          'startAddr': 0,
          'endAddr':   0
      };
      bound.startAddr = bundle.nBaseAddr.toString(16);
      bound.endAddr   = (parseInt(bundle.nBaseAddr.toString(10)) + bundle.nSizeBytes).toString(16);
      memRegionBoundaries.push(bound);
    });
  

    Object.keys(obj.SysAddrRangeInfo.MInterlvGrpAddrMapInfo).map(function(indx) {
      const arr = [];
      obj.SysAddrRangeInfo.MInterlvGrpAddrMapInfo[indx].forEach(function(val) {
        arr.push(val);
      });
      intrlvGrp2SysAddrMap.push(arr);
      intrlvGrpType.push('DMI');
      nMemGrps++;
    });

    Object.keys(obj.SysAddrRangeInfo.DIIAddrMapInfo).map(function(indx) {
      const arr = [];
      obj.SysAddrRangeInfo.DIIAddrMapInfo[indx].forEach(function(val) {
        arr.push(val);
      });
      intrlvGrp2SysAddrMap.push(arr);
      intrlvGrpType.push('DII');
      nMemGrps++;
    });

  } else {
    if (obj.DmiInfo.length == 1) {
      IGSV.push([1]);
    } else {
      obj.AiuInfo[0].InterleaveInfo.dmiIGSV.forEach(function(lp1) {
          const arr = [];
          lp1.IGV.forEach(function(lp2) {
              arr.push(lp2.DMIIDV.length);
          });
          IGSV.push(arr);
      });

      //grab dmi interleaving info

    }
  }
}

addrTransMgr(obj.AiuInfo, 0);
dmiInfo();

let ncti_master_found = 0;
if (obj.FULL_SYS_TB) {
    for(let pidx = 0 ; pidx < obj.ncti_agents.length; pidx++) { 
        if (obj.ncti_agents[pidx].is_master === 1 && ncti_master_found === 0) {
            ncti_master_found = 1;
            wSelectBits.push(0);
            agentsAxiAddr.push(maxAxiAddrWidth);
            agentsSfiAddr.push(obj.wSysAddr);
            agentInfType.push(3);
        }
    }
}

let nCaches = 0;          //Number of cacheing agents
const cache2funit_map = []; //Cache Id to Agent ID map
const sfSlices = [];

/*
function getCacheingAgents(p) {
        //CHI aiu does not contain cache, but connects to a native cpu which does.
  p.Caching_aiuInfo = p.AiuInfo.filter(
          function (unitInfo) { return (unitInfo.useCache || (unitInfo.fnNativeInterface == "CHI-A") || (unitInfo.fnNativeInterface == "CHI-B")); }
  );
    p.Caching_aiuInfo.sort(   //order by snoop filter
      function (a, b) { return (a.CmpInfo.idSnoopFilterSlice > b.CmpInfo.idSnoopFilterSlice) ? 1 : -1 ; }   
    );

    p.Caching_aiuInfo.forEach(function(bundle) {
            cache2funit_map[nCaches] = [];
            for(let i = 0; i < bundle.nAius; i++) {
                //cache2funit_map[nCaches].push((unitId + i));
                cache2funit_map[nCaches].push((bundle.FUnitId));
            }
            sfSlices[bundle.FUnitId] = bundle.CmpInfo.idSnoopFilterSlice;
            nCaches++;
    });
}
*/

function getCacheingAgents(p) {
  p.AiuInfo.forEach(function(bundle) {
    if (((bundle.fnNativeInterface === "CHI-A")||(bundle.fnNativeInterface === "CHI-B")||(bundle.fnNativeInterface === "CHI-E")||(bundle.fnNativeInterface === "ACE")||(bundle.fnNativeInterface === "ACE5")) || bundle.useCache || (bundle.orderedWriteObservation==true))
      nCaches++;
  });

 // p.AiuInfo.forEach(function(bundle) {
 //   if (((bundle.fnNativeInterface === "CHI-A")||(bundle.fnNativeInterface === "CHI-B")) || bundle.useCache)
 //     cache2funit_map.push(bundle.FUnitId);
 // });

  p.SnoopFilterInfo.forEach(function(SfObj, indx) {
    SfObj.SnoopFilterAssignment.slice().reverse().forEach(function(val) {
    cache2funit_map.push(val);
     });
  });
  
  //SfObj.SnoopFilterAssignment.slice().reverse().forEach(function(val) {
  
  p.AiuInfo.forEach(function(bundle) {
    if (((bundle.fnNativeInterface === "CHI-A")||(bundle.fnNativeInterface === "CHI-B")||(bundle.fnNativeInterface === "CHI-E")||(bundle.fnNativeInterface === "ACE")||(bundle.fnNativeInterface === "ACE5")) || bundle.useCache || (bundle.orderedWriteObservation==true)) {
      var tmpid = bundle.FUnitId;
      p.SnoopFilterInfo.forEach(function(SfObj, indx) {
        SfObj.SnoopFilterAssignment.forEach(function(val) {
      
          //Associating Funitid's to SnoopFilterSlices
          if (val == tmpid)
            sfSlices[tmpid] = indx;
        });
      });
    }
  });
}

//Method call
getCacheingAgents(obj);

var snpCreditsPerAiu = function() {
    const tmpArr = [];

    obj.AiuInfo.forEach(function(bundle, indx) {
        if((bundle.fnNativeInterface === "ACE") ||
           (bundle.fnNativeInterface === "ACE5") ||
           (bundle.fnNativeInterface === "CHI-A") ||
           (bundle.fnNativeInterface === "CHI-B") ||
           (bundle.fnNativeInterface === "CHI-E") ||
           (bundle.useCache))         {
            tmpArr.push(obj.DceInfo[0].nSnpsPerAiu);
        } else {
            tmpArr.push(0);
        }
    });

    return(tmpArr);

};

const mrdCreditsPerDmi = function() {
    const tmpArr = [];

    obj.DmiInfo.forEach(function(bundle, indx) {
        tmpArr.push(bundle.nMrdSkidBufSize);
    });
    return(tmpArr);
};

let numSF = 0; //Number of Snoop Filters
let numTagSF = 0; //Number of Tag Snoop Filters
const snoopFilters = [];

function extractSnoopFilterInfo(p) {
    numSF = p.length;
    
    p.forEach(function(bundle, indx, array) {
        const sfInfo = {
            filterType: '',
            nSets: 0,
            nWays: 0,
            tagFilterType: '',
            errorType: '',
            eccSplitFactor: '',
            repPolicy: ''
        };
        if(bundle.fnFilterType === "EXPLICITOWNER") {
            numTagSF++;
            sfInfo['filterType'] = "TAGFILTER";
            sfInfo['nSets'] = bundle.nSets;
            sfInfo['nWays'] = bundle.nWays;
            sfInfo['tagFilterType']  = bundle.fnFilterType;
            sfInfo['nVictimEntries'] = bundle.nVictimEntries;
            sfInfo['repPolicy'] = bundle.RepPolicy;

            if(bundle.TagFilterErrorInfo.fnErrDetectCorrect.match("SECDED")) {
                sfInfo['errorType']  = 'SECDED_ERR';
            } else if (bundle.TagFilterErrorInfo.fnErrDetectCorrect.match("PARITY")) {
                sfInfo['errorType']  = 'PARITY_ERR';
            } else {
                sfInfo['errorType']  = 'INV_ERR';
            }
            sfInfo['eccSplitFactor'] = bundle.nSnoopFilterEccSplitFactor;
        } else {
            sfInfo['filterType'] = "NULL";
            sfInfo['nSets'] = 0;
            sfInfo['nWays'] = 0;
            sfInfo['tagFilterType'] = '';
            sfInfo['nVictimEntries']= 0;
            sfInfo['errorType'] = 'INV_ERR';
            sfInfo['eccSplitFactor'] = 0;
            sfInfo['repPolicy'] = 'n/a';
        }
        snoopFilters.push(sfInfo);
    });
}

//Method Calls
extractSnoopFilterInfo(obj.SnoopFilterInfo);

//DVM capable agents
const dvmMsgAgents = [];
const dvmCmpAgents = [];
obj.AiuInfo.forEach(function(bundle, indx, array) {
    if((bundle.fnNativeInterface === "CHI-A")||(bundle.fnNativeInterface === "CHI-B")||(bundle.fnNativeInterface === "CHI-E")) {
        dvmMsgAgents.push(bundle.FUnitId);
        dvmCmpAgents.push(bundle.FUnitId);
    }
});


const hasBitsIndx = function(SecSubRow) {
  let idx = 0 ;
  let base_idx = 0;
  let bval;
  const hasBitsq = [];
  const bit_array = Array.from(SecSubRow.replace("'h",""));
  //JS can't handle > 32bit strip into array and parse per nibble
  for(let itr= bit_array.length-1; itr >=0; itr--) {
    base_idx = (bit_array.length-itr-1) * 4;
    let nibble = parseInt(bit_array[itr],16);
    idx =0;
    while(nibble > 0 ){
      bval = nibble & 1;
      if(bval == 1){
        hasBitsq.push(base_idx+idx);
      }
      idx+=1;
      nibble = nibble >>> 1;
    }
  }
  return hasBitsq;
};

//Abstrached Mehod for reading any General selection algorithm table
const getSelectionInfo = function(bundle, num_entries, strName) {
    //console.log('primbits ' + bundle.PriSubDiagAddrBits.length);
    return({
        'nEntries' : num_entries,
        'nResorcs' : bundle.PriSubDiagAddrBits.length,
        'primBits' : bundle.PriSubDiagAddrBits,
        'hashBits' : Object.keys(bundle.SecSubRows).map(function(indx) {
                         return hasBitsIndx(bundle.SecSubRows[indx]);
                     }),
        'strInfo'  : strName
    });
};

//If there is no setSelection for that agent then to avoid messing up
//logical Id count this method is called
const emptySelection = function(strName) {
    return({
        'nEntries' : 0,
        'nResorcs' : 0,
        'primBits' : [],
        'hashBits' : [],
        'strInfo'  : strName
    });
};

const getAiuIntvFunc = function(bundle) {
   return({
          'primBits' : [].concat(bundle.aPrimaryBits),
          'secBits'  : [].concat(bundle.aSecondaryBits)
          });
};
const getAiuIGbitsFunc = function(bundle) {
    return({
           'fUnitIds'             : [].concat(bundle.fUnitIds),
           'aPrimaryAiuPortBits'  : [].concat(bundle.aPrimaryAiuPortBits)//.reverse()
           });
 };

const aiuPortSel = [];
const dcePortSel = [];
const dmiPortSel = [];
const diiPortSel = [];

let baseCount = 0;
obj.AiuInfo.forEach(function(bundle, indx) {
    const str = "AIU" + baseCount;
    aiuPortSel.push(emptySelection(str));
    aiuPortSel[aiuPortSel.length - 1].nEntries = 1;
});

baseCount = 0;
obj.DceInfo.forEach(function(bundle, indx) {
  dcePortSel.push(getSelectionInfo(bundle.InterleaveInfo.dceSelectInfo, obj.DceInfo.length, "DCE"));
});

baseCount = 0;
obj.DmiInfo.forEach(function(bundle, indx) {
    const str = "DMI" + baseCount;
    dmiPortSel.push(emptySelection(str));
    dmiPortSel[dmiPortSel.length - 1].nEntries = 1;
});

baseCount = 0;
obj.DiiInfo.forEach(function(bundle, indx) {
    const str = "DII" + baseCount;
    diiPortSel.push(emptySelection(str));
    diiPortSel[diiPortSel.length - 1].nEntries = 1;
});

//CBI cache index selection
const cbiCache = [];
obj.AiuInfo.forEach(function(bundle, indx) {
        if(bundle.useCache) {
            cbiCache.push(getSelectionInfo(bundle.ccpParams,
                                           bundle.ccpParams.nSets, 
                                           ("CBI" + indx)));
        } else {
            cbiCache.push(emptySelection("CBI" + indx));
        }
});

//SF index selection
const sfCache = [];
obj.SnoopFilterInfo.forEach(function(bundle, indx) {
    if(bundle.fnFilterType === "EXPLICITOWNER") {
        sfCache.push(getSelectionInfo(bundle.SetSelectInfo, bundle.nSets, 
                                          ("SF" + indx)));
    } else {
        sfCache.push(emptySelection("SF" + indx));
    }
});

//CMC cache index selection
const cmcCache = [];
obj.DmiInfo.forEach(function(bundle, indx) {
        if(bundle.useCmc) {
            cmcCache.push(getSelectionInfo(bundle.ccpParams,
                                           bundle.ccpParams.nSets, 
                                           ("CMC" + indx)));
        } else {
            cmcCache.push(emptySelection("CMC" + indx));
        }
});

//Dmis with CMC
const dmisWithCmc = function() {
    const arr = [];
    obj.DmiInfo.forEach(function(bundle, indx, array) {
        arr.push(bundle.useCmc);
    });
    return(arr);
};

//Dmis with CMC and Scratch Pad memory
const dmisWithCmcSp = function() {
    const arr = [];
    obj.DmiInfo.forEach(function(bundle, indx, array) {
        arr.push(bundle.useCmc & bundle.ccpParams.useScratchpad);
    });
    return(arr);
};

//Dmis with CMC and Way Partitioning
const dmisWithCmcWp = function() {
    const arr = [];
    obj.DmiInfo.forEach(function(bundle, indx, array) {
        arr.push(bundle.useCmc & bundle.useWayPartitioning);
    });
    return(arr);
};

//Dmis with AE
const dmisWithAe = function() {
    const arr = [];
    obj.DmiInfo.forEach(function(bundle, indx, array) {
        arr.push(bundle.useAtomic);
    });
    return(arr);
};

//Dmis CMS Sets
const dmiCmcSet = function() {
    const arr = [];
    obj.DmiInfo.forEach(function(bundle, indx, array) {
        if(bundle.useCmc) { arr.push(bundle.ccpParams.nSets); }
        else              { arr.push(bundle.useCmc); }
    });
    return(arr);
};

//Dmis CMS Ways
const dmiCmcWays = function() {
    const arr = [];
    obj.DmiInfo.forEach(function(bundle, indx, array) {
        if(bundle.useCmc) { arr.push(bundle.ccpParams.nWays); }
        else              { arr.push(bundle.useCmc); }
    });
    return(arr);
};

//Dmis CMS Partition Registers
const dmiCmcWPRegs = function() {
    const arr = [];
    obj.DmiInfo.forEach(function(bundle, indx, array) {
        if(bundle.useCmc & bundle.useWayPartitioning) { arr.push(bundle.nWayPartitioningRegisters); }
        else                                          { arr.push(bundle.useCmc & bundle.useWayPartitioning); }
    });
    return(arr);
};


const dmiIntrlvGrp = function(i) {
    const arr = [];
    obj.DmiInfo.forEach(function(bundle) {
       obj.AiuInfo[0].InterleaveInfo.dmiIGSV[i].IGV.forEach(function(lp1,indx) {
           lp1.DMIIDV.forEach(function(lp2) {
               if(bundle.nUnitId == lp2) {arr.push(indx);}
           });
       });
    });
    return(arr);
};


//Diis have endpoint size
obj.DiiInfo.forEach(function(bundle, indx) {
    wEndpoint.push(bundle.wLargestEndpoint);
});

let total_sf_ways = 0;
let max_sf_set_idx = 0;

obj.SnoopFilterInfo.forEach(function(bundle) {
    if(bundle.fnFilterType === "EXPLICITOWNER") {
        total_sf_ways += bundle.nWays;
        if (bundle.SetSelectInfo.PriSubDiagAddrBits.length > max_sf_set_idx) {
      max_sf_set_idx = bundle.SetSelectInfo.PriSubDiagAddrBits.length;
        }
    }
});

const mp_aiu_intv_func = [];

obj.AiuInfo.forEach(function(bundle) {
    if((bundle.fnNativeInterface == 'AXI4') || (bundle.fnNativeInterface == 'AXI5') || (bundle.fnNativeInterface == 'ACE') || (bundle.fnNativeInterface == 'ACE5') || (bundle.fnNativeInterface == 'ACE-LITE') || (bundle.fnNativeInterface == 'ACELITE-E')) {
        mp_aiu_intv_func[bundle.nUnitId] = getAiuIntvFunc(bundle.aNcaiuIntvFunc);
    } else {
        mp_aiu_intv_func[bundle.nUnitId] =   {
        'primBits' : [],
        'secBits'  : []
        };
    }
 });

const aiu_ig_bits_func = [];

obj.initiatorGroups.forEach(function(bundle,idx) {
    aiu_ig_bits_func[idx] = getAiuIGbitsFunc(bundle);
  });

const assemble_sp_address = function(wifv,func,wAddr){
  let res;
  if(func+1 <= wifv.length){
    let pBits = wifv[func].PrimaryBits.slice().sort(function(a,b) {return a-b});
    for(let i=0; i<pBits.length;i++){
      if(i == 0){
        res="full_addr["+(pBits[0]-1)+":0]};"
      }
      else{
        if(pBits[i] != pBits[i-1]+1){
          res="full_addr["+(pBits[i]-1)+" : " + (pBits[i-1]+1)+" ]," + res;
        }
      }
    }
    if(wAddr-1 != pBits[pBits.length-1]){
      res = "sp_intrlv_addr = {"+pBits.length +"'h0 , "+"full_addr["+(wAddr-1)+":"+ (pBits[pBits.length-1]+1)+"]," + res;
    }
    else{
      res = "sp_intrlv_addr = {"+res;
    }
    }
    else {  res = "sp_intrlv_addr = full_addr;";}
  return res;
}

const assemble_full_address = function(wifv,func,wAddr){
  let trail_pos;
  let sel_pos = 1;
  let res;
  if(func+1 <= wifv.length){
    let pBits = wifv[func].PrimaryBits.slice().sort(function(a,b) {return a-b});
    res= "dmi_sel[0],"+"sp_intrlv_addr["+(pBits[0]-1)+":0]};";
    trail_pos = pBits[0];
    for(let i=1; i<pBits.length;i++){
      let distance = (pBits[i] - pBits[i-1] - 1);
      if(distance == 0){
        if(trail_pos==0) { trail_pos = pBits[i-1]; }
        res = "dmi_sel["+sel_pos+"]," + res;
      }
      else{
        res = "dmi_sel["+sel_pos+"],sp_intrlv_addr[" + (trail_pos+distance-1) + ":" + trail_pos + "]," + res;
        trail_pos = trail_pos +distance;
      }
      sel_pos +=1;
    }
    if( (wAddr-pBits.length) > trail_pos) {
      let distance = wAddr - pBits.length - trail_pos;
      res = "full_addr = {sp_intrlv_addr[" + (trail_pos+distance-1) + ":" + trail_pos + "]," + res;
    }
    else{ res =  "full_addr = {"+res; }
  }
  else {  res = "full_addr = sp_intrlv_addr;";}
  return res;
}
const getDmiIgsvData = function(igsv){
  let res ="";
  if(!obj.DmiInfo[0].InterleaveInfo.dmiIGSV.length==0){
    for(let i=0; i < obj.DmiInfo[0].InterleaveInfo.dmiIGSV.length;i++){
      if(!obj.DmiInfo[0].InterleaveInfo.dmiIGSV[i].IGV.length==0){
      res+="'{";
      for(let j=0; j<obj.DmiInfo[0].InterleaveInfo.dmiIGSV[i].IGV.length;j++){
        res += "'{" + obj.DmiInfo[0].InterleaveInfo.dmiIGSV[i].IGV[j].DMIIDV;
        if(j== obj.DmiInfo[0].InterleaveInfo.dmiIGSV[i].IGV.length-1) res+="}";
        else res+="},";
      }
      if(i== obj.DmiInfo[0].InterleaveInfo.dmiIGSV.length-1) res+="}";
      else res+="},";
      }
    }
  }
  return res;
}
%> 

//Concerto v1 support
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Class : memregions_per_ig
// Description : Static class to have local scope
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
class ncoreConfigInfo;

    <% if (obj.FULL_SYS_TB) { 
        ncti_master_found = 0;
        for(let pidx = 0 ; pidx < obj.ncti_agents.length; pidx++) { 
            if (obj.ncti_agents[pidx].is_master === 1 && ncti_master_found === 0) { 
                ncti_master_found = 1; 
                %>
                parameter int NUM_AIUS = <%=obj.AiuInfo.length + 1%>;
            <% } %>
        <% } %>
        <% if (ncti_master_found === 0) { 
            %>
            parameter int NUM_AIUS = <%=obj.AiuInfo.length%>;
        <% } %>
    <% } else 
    { %>
        parameter int NUM_AIUS = <%=obj.AiuInfo.length%>;
    <% } %>
  
    <%
    let numIoMaster=0; 
    let numChiMaster=0; 
    if(obj.testBench != "io_aiu"){
    for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
        if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
            for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
                numIoMaster++;
            }
        } else {
            numChiMaster++;
        }
    }}else{
      numIoMaster=1;
    }
    %>
    
    parameter int NUM_IO_MASTERS    = <%=numIoMaster%>;
    parameter int NUM_CHI_MASTERS    = <%=numChiMaster%>;
    parameter int NUM_COH_VISB_AIUS = <%=obj.AiuInfo.length%>;
    parameter int NUM_DMIS          = <%=obj.DmiInfo.length%>;
    parameter int NUM_DIIS          = <%=obj.DiiInfo.length%>; //not going to process sys_dii
    parameter int NUM_DCES          = <%=obj.DceInfo.length%>;
    parameter int NUM_DVES          = <%=obj.DveInfo.length%>;
    <%if (obj.GiuInfo && obj.GiuInfo.length > 0) {%>
    parameter int NUM_GIUS          = <%=obj.GiuInfo.length%>;
    parameter int NUM_AGENTS        = NUM_AIUS + NUM_DCES + NUM_DVES + NUM_DMIS + NUM_DIIS + NUM_GIUS;
    <%} else {%>
    parameter int NUM_AGENTS        = NUM_AIUS + NUM_DCES + NUM_DVES + NUM_DMIS + NUM_DIIS;
    <%}%>
    parameter int ADDR_WIDTH        = <%=maxAxiAddrWidth%>;
    parameter int AXID_WIDTH        = <%=maxAxiIdWidth%>;
    parameter int MIN_ADDR_WIDTH    = <%=minAxiAddrWidth%>;
    parameter int DATA_WIDTH        = <%=maxAxiDataWidth%>;
    parameter int NUM_CACHES        = <%=nCaches%>;
    parameter int NUM_SF            = <%=numSF%>;
    parameter int NUM_TAG_SF        = <%=numTagSF%>;
    parameter int W_SEC_ADDR        = ADDR_WIDTH + <%=obj.wSecurityAttribute%>;
    parameter int EN_SEC            = <%=obj.wSecurityAttribute%>;
    parameter int NGPRA             = <%=obj.AiuInfo[0].nGPRA%>;
    
    //dce snoopfilter parameters.
    parameter int WSFWAYVEC         = <%=total_sf_ways%>;
    parameter int WSFSETIDX         = <%=max_sf_set_idx%>;

    //Excludes Cache offset, critical word bits
    parameter int MAX_BEATS_CACHELINE    = <%=Math.floor(Math.pow(2, obj.wCacheLineOffset) / (minAxiDataWidth / 8))%>;
    parameter int MAX_BYTES_BEAT         = <%=Math.floor(minAxiDataWidth / 8)%>;

    parameter int WCACHE_OFFSET          = <%=obj.wCacheLineOffset%>;
    parameter int WCACHE_TAG             = ADDR_WIDTH - WCACHE_OFFSET;
    parameter int WCRITICAL_WORD         = <%=obj.wCacheLineOffset - Math.floor(Math.log2(minAxiDataWidth / 8))%>;
    parameter int WCACHE_BURST_OFFSET    = <%=Math.floor(Math.log2(minAxiDataWidth / 8))%>;

    parameter int MEM_REGIONS            = <%=nMems()%>;
    parameter int EN_RUN_TIME_MEM_MAP    = <%=obj.useCsrProgrammedAddrRangeInfo%>;
    parameter int NUM_PROCS_IN_SYS       = <% var prcCnt = 0; maxProcs.forEach(function(val, indx) { prcCnt = prcCnt + val }); %> <%=prcCnt%>;
    parameter int MAX_PROCS              = <% var num_procs = 0; obj.AiuInfo.forEach(function(bundle) { if (bundle.nProcs > num_procs) { num_procs = bundle.nProcs;}}); %> <%=num_procs%>;    
    parameter int TAGGED_MON_PER_DCE     = <%=obj.DceInfo[0].nTaggedMonitors%>;


    // Interleaving 
    parameter int MAX_IG = 2; // interleaver group
    parameter int MAX_IF = 2; // interleave function 
    
    //Max Memregion Prefix width
<% 
var wPrefix = [];
for(let i=0; i < obj.AiuInfo.length; i++) {
    wPrefix.push((agentsAxiAddr[i] - agentsSfiAddr[i]));
}
%>
    parameter MAX_PREFIX = <%=Math.max.apply(null, wPrefix)%>;

    parameter bit[ADDR_WIDTH-1:0] CONCERTO_MIN_ADDRESS_MAP = 0;
    parameter bit[ADDR_WIDTH-1:0] CONCERTO_MAX_ADDRESS_MAP = 65535;

    typedef struct {
    bit [W_SEC_ADDR-1:0] page_start_addr;
    bit [W_SEC_ADDR-1:0] start_addr;
    bit [W_SEC_ADDR-1:0] flag_addr;
    int len_64B_bus;
    int len_32B_bus;
    int size_64B_bus;
    int size_32B_bus;
    } buffer_info_t;

    static int general_global_var[string];

    typedef int intq[$];
    typedef int int2dq[$][$];
    static int nmig;

    typedef enum bit [2:0] {
        ACE_IX, ACE_SC, ACE_SD, ACE_UC, ACE_UD
    } aceState_t;

    typedef enum int {
        ACE_AIU, ACE_LITE_AIU, CHI_A_AIU, CHI_B_AIU, 
        AXI_AIU, IO_CACHE_AIU, ACE_LITE_E_AIU, CHI_E_AIU
    } interface_t;

    typedef enum int {
        INV_ERR, SECDED_ERR, PARITY_ERR
    } sf_error_type_t;

    typedef struct {
        string filter_type;
        int num_sets;
        int num_ways;
        string tag_sf_type;
        int victim_entries;
        sf_error_type_t error_type;
        int ecc_split_factor;
        string rep_policy;
    } sf_info_t;

    typedef struct {
        int num_entries;
        int num_pri_bits;
        int pri_bits[$];
        int sec_bits[$][$];
        string unit_desp;
    } selection_data_t;

    typedef struct {
      int pri_bits[];
      int sec_bits[][];
    } sel_bits_t;

    typedef struct {
      int pri_bits[$];
      int sec_bits[$][$];
    } dmisel_bits_t;

    typedef struct {
      int pri_bits[$];
      int sec_bits[$];
    } aiu_intv_bits_t;

    typedef struct {
      int fUnitIds[$];
      int aPrimaryAiuPortBits[$];
    } aiu_ig_bits_t;

    typedef struct {
      int fUnitId;
      int ConnectedfUnitIds[$];
    } unit_connected_ids_t;

    typedef struct packed {
        bit [63:0] start_addr;
        bit [63:0] end_addr;
    } memregion_boundaries_t;

    typedef enum {
<%if (obj.GiuInfo && obj.GiuInfo.length > 0) {%>
      AIU, DCE, DMI, DII, DVE, GIU
<%} else {%>
      AIU, DCE, DMI, DII, DVE
<%}%>
    } ncore_unit_type_t;

    typedef enum {
      COH, IOCOH, NONCOH, NRS, BOOT, BOOTCOH, BOOTNONCOH
    } addr_format_t;

    typedef enum {ANY, COH_DMI, NONCOH_DMI, NONCOH_DII} mem_type;

    typedef struct packed {
      bit [1:0] policy;  // bit [4:3]
      bit writeid;       // bit 2
      bit readid;        // bit 1
    } mem_order_t;

    typedef struct {
      ncore_unit_type_t utype;
      int nig;
      int nassoc_memregions;
    } igs_info_t;

    typedef struct {
        ncore_unit_type_t unit;
        bit [4:0]  mig_nunitid;
        bit [5:0]  size;
        bit [31:0] low_addr;
        bit [7:0]  upp_addr;
        bit nc;  // noncoherent GPRAR
        bit [1:0] nsx; // security GPRAR
        mem_order_t order;       
    } sys_addr_csr_t;
    typedef sys_addr_csr_t sys_addrq[$];

    typedef bit[W_SEC_ADDR-1:0] addrq[$];
       
    typedef struct {
        bit [63:0] start_addr;
        bit [63:0] end_addr;
        int        size;
        bit [4:0]  hui;
        ncore_unit_type_t hut;
        int UnitIds[$];
    } memregion_info_t;

  static   bit [31:0] dce_credit_zero;
  static   bit [31:0] dmi_credit_zero;
  static   bit [31:0] dii_credit_zero;
  static memregion_info_t memregions_info[$];
  //SANJEEV: For CONC-14089
  const static bit[<%=obj.nDMIs%>-1:0] dce_dmi_connectivity_vec[<%=obj.nDCEs%>] = '{<% for(let i = 0; i < obj.nDCEs; i++) { %> {<<{<%=obj.nDMIs%>'h<%=obj.DceInfo[i].hexDceDmiVec%>}} <%if(i < obj.nDCEs-1) { %>,<% } } %> };

  //Below data strutures must be indexed using LogicalID's
  //Use get_logical_uinfo() method to retrive cache_id, Column index 
  const static int logical2aiu_map[<%=nLogaius%>][$] = '{<% for(let i = 0; i < nLogaius; i++) { %> '{<%=nLogaiuQ[i]%>}<%if(i < nLogaius-1) { %>,<% } } %> };
  const static int logical2aiu_prt[<%=nLogaius%>][$] = '{<% for(let i = 0; i < nLogaius; i++) { %> '{<%=nLogaiuP[i]%>}<%if(i < nLogaius-1) { %>,<% } } %> };
  const static int logical2dce_map[<%=nLogdces%>][$] = '{<% for(let i = 0; i < nLogdces; i++) { %> '{<%=nLogdceQ[i]%>}<%if(i < nLogdces-1) { %>,<% } } %> };
  const static int logical2dce_prt[<%=nLogdces%>][$] = '{<% for(let i = 0; i < nLogdces; i++) { %> '{<%=nLogdceP[i]%>}<%if(i < nLogdces-1) { %>,<% } } %> };
  const static int logical2dve_map[<%=nLogdves%>][$] = '{<% for(let i = 0; i < nLogdves; i++) { %> '{<%=nLogdveQ[i]%>}<%if(i < nLogdves-1) { %>,<% } } %> };
  const static int logical2dve_prt[<%=nLogdves%>][$] = '{<% for(let i = 0; i < nLogdves; i++) { %> '{<%=nLogdveP[i]%>}<%if(i < nLogdves-1) { %>,<% } } %> };
  <%if (obj.GiuInfo && obj.GiuInfo.length > 0) {%>
  const static int logical2giu_map[<%=nLoggius%>][$] = '{<% for(let i = 0; i < nLoggius; i++) { %> '{<%=nLoggiuQ[i]%>}<%if(i < nLoggius-1) { %>,<% } } %> };
  const static int logical2giu_prt[<%=nLoggius%>][$] = '{<% for(let i = 0; i < nLoggius; i++) { %> '{<%=nLoggiuP[i]%>}<%if(i < nLoggius-1) { %>,<% } } %> };
  <%}%>
  //Non-const and 2-D queues because can be run-time programable
  static int logical2dmi_map[$][$] = '{<% for(let i = 0; i < nLogdmis; i++) { %> '{<%=nLogdmiQ[i]%>}<%if(i < nLogdmis-1) { %>,<% } } %> };
  static int logical2dmi_prt[$][$] = '{<% for(let i = 0; i < nLogdmis; i++) { %> '{<%=nLogdmiP[i]%>}<%if(i < nLogdmis-1) { %>,<% } } %> };
  static int logical2dii_map[$][$] = '{<% for(let i = 0; i < nLogdiis; i++) { %> '{<%=nLogdiiQ[i]%>}<%if(i < nLogdiis-1) { %>,<% } } %> };
  static int logical2dii_prt[$][$] = '{<% for(let i = 0; i < nLogdiis; i++) { %> '{<%=nLogdiiP[i]%>}<%if(i < nLogdiis-1) { %>,<% } } %> };


  //Below data strutures must be indexed using CacheID's
  //Use get_cacheid() method to retrive cache_id, Column index 
  const static int cache2funit_map[<%=nCaches%>][$] = '{<% for(let i = 0; i < nCaches; i++) { %> '{<%=cache2funit_map[i]%>}<%if(i < nCaches-1) { %>,<% } } %> };
  const static int funit2sf_slice[int]     = '{
      <% sfSlices.forEach(function(value, key) {%>
          <%=key%>: <%=value%>,
      <%});%>
      default:-1
  };
  
  //Below data structure must be accessed using CacheID but
  //cacheID's associted to ACE-agents are only valid
  <% if(maxProcs.length === 0) { %>
    const static int proc_ids_per_cpu[1] = '{0};
  <% } else { %>
    const static int proc_ids_per_cpu[<%=maxProcs.length%>] = '{<%=maxProcs%>};
  <% } %>

  //Below data structures must be indexed using IntrlvGroupId i.e. logical_id
  //Non-const and 2-D queues because can be run-time programable
  static int intrlvgrp_vector[<%=IGSV.length%>][$] = '{<% for(let i = 0; i < IGSV.length; i++) { %> '{<%=IGSV[i]%>}<%if(i < IGSV.length - 1) { %>,<% } } %> };
  static int picked_dmi_igs = 0;
  static int picked_dmi_if[int];  //[2] = MIG2AIFId [3] = MIG3AIFId //[4]=MIG4AIFId //[8] = MIG8AIFId  ...
  static int intrlvgrp2mem_map[$][$] = '{<% for(let i = 0; i < nMemGrps; i++) { %> '{<%=intrlvGrp2SysAddrMap[i]%>}<%if(i < nMemGrps-1) { %>,<% } } %> }; 
  static mem_order_t intrlvgrp2mem_order[$][$] = '{<% for(let i = 0; i < nMemGrps; i++) { %> '{<%=intrlvGrp2SysAddrMap[i]%>}<%if(i < nMemGrps-1) { %>,<% } } %> };
  static bit         intrlvgrp2noncoh[$][$];
  static bit [1:0]   intrlvgrp2security[$][$];
  static ncore_unit_type_t intrlvgrp_if[$] = '{<%=intrlvGrpType%>};

  // NRS Base Address
  static bit [63:0]   NRS_REGION_BASE    = <%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20;
  static bit [63:0]   NRS_REGION_BASE_COPY    = <%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20;
  static int        NRS_REGION_SIZE    = (<%=obj.AiuInfo[0].nrri%>+1) << 20;
  static bit [63:0]   NEW_NRS_REGION_BASE_PER_AIU[<%=obj.AiuInfo.length%>]    = '{ <% for(var x=0; x<obj.AiuInfo.length; x=x+1) { %> <%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20 <%if (x < obj.AiuInfo.length-1) { %> , <% } %> <% } %> };
  static bit program_nrs_base=0;
     
  // Boot Region Address
  <% if(obj.testBench == "emu") { %>
    parameter int unsigned BOOT_REGION_BASE_L = 'h400; //<%=obj.AiuInfo[0].BootInfo.regionBlr.replace("0x","'h")%>;
  <%} else {%>
    parameter int unsigned BOOT_REGION_BASE_L = <%=obj.AiuInfo[0].BootInfo.regionBlr.replace("0x","'h")%>;
  <% } %>
  parameter int unsigned BOOT_REGION_BASE_H = <%=obj.AiuInfo[0].BootInfo.regionBhr.replace("0x","'h")%>;
  parameter bit [63:0]   BOOT_REGION_BASE   = (((BOOT_REGION_BASE_H)<<32)|BOOT_REGION_BASE_L)<<12;
  <% if (obj.AiuInfo[0].BootInfo.regionHut == 0) { %>
  static    int          BOOT_REGION_SIZE   = 2**(<%=obj.AiuInfo[0].BootInfo.regionSize%>+12+$clog2(intrlvgrp_vector[picked_dmi_igs][<%=obj.AiuInfo[0].BootInfo.regionHui%>]));
  <% } else { %>
  static    int          BOOT_REGION_SIZE   = 2**(<%=obj.AiuInfo[0].BootInfo.regionSize%>+12);
  <% } %>

  //Below data structures must be access using AgentID
  const static int select_bits_width[NUM_AIUS] = '{<%=wSelectBits%>};
  const static int agent_aceaddr_width[NUM_AIUS] = '{<%=agentsAxiAddr%>};
  const static int agent_sfiaddr_width[NUM_AIUS] = '{<%=agentsSfiAddr%>};
  const static int inf[NUM_AIUS] = '{<%=agentInfType%>};
  const static int stash_enable[NUM_AIUS] = '{<%=stashEnable%>};
  const static int owo_enable[NUM_AIUS] = '{<%=owoEnable%>};

  //Below D.S accessed w.r.t dmi_id
  const static int dmis_with_cmc[NUM_DMIS]  = '{<%=dmisWithCmc()%>};
  const static int dmis_with_cmcsp[NUM_DMIS]  = '{<%=dmisWithCmcSp()%>};
  const static int dmis_with_cmcwp[NUM_DMIS]  = '{<%=dmisWithCmcWp()%>};
  const static int dmis_with_ae[NUM_DMIS]  = '{<%=dmisWithAe()%>};
  const static int dmi_CmcSet[NUM_DMIS]  = '{<%=dmiCmcSet()%>};
  const static int dmi_CmcWays[NUM_DMIS]  = '{<%=dmiCmcWays()%>};
  const static int dmi_CmcWPReg[NUM_DMIS]  = '{<%=dmiCmcWPRegs()%>};
  const static int dmi_intrlvgrp[<%=IGSV.length%>][NUM_DMIS] = '{<% for(let i=0; i<IGSV.length ;i++) {%> '{<%=dmiIntrlvGrp(i)%>}<%if(i < IGSV.length - 1) { %>,<% } } %>};

  const static dmisel_bits_t dmi_sel_bits[MAX_IF][17] = '{ 
                                                 '{ // Idx=0 in MAX_IF: Max Interleave Function options
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{<% if(obj.AiuInfo[0].InterleaveInfo.dmi2WIFV.length > 0) {%> '{<%=obj.AiuInfo[0].InterleaveInfo.dmi2WIFV[0].PrimaryBits[0]%>},'{'{<%=obj.AiuInfo[0].InterleaveInfo.dmi2WIFV[0].SecondaryBits[0]%>}}<%} else {%> '{},'{}<%}%>},
                                                 '{<% if(obj.AiuInfo[0].InterleaveInfo.dmi3WIFV.length > 0) {%> '{<%=obj.AiuInfo[0].InterleaveInfo.dmi3WIFV[0].PrimaryBits[1]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi3WIFV[0].PrimaryBits[0]%>},'{'{<%=obj.AiuInfo[0].InterleaveInfo.dmi3WIFV[0].SecondaryBits[1]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi3WIFV[0].SecondaryBits[0]%>}}<%} else {%> '{},'{}<%}%> },
                                                 '{<% if(obj.AiuInfo[0].InterleaveInfo.dmi4WIFV.length > 0) {%> '{<%=obj.AiuInfo[0].InterleaveInfo.dmi4WIFV[0].PrimaryBits[1]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi4WIFV[0].PrimaryBits[0]%>},'{'{<%=obj.AiuInfo[0].InterleaveInfo.dmi4WIFV[0].SecondaryBits[1]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi4WIFV[0].SecondaryBits[0]%>}}<%} else {%> '{},'{}<%}%> },
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{<% if(obj.AiuInfo[0].InterleaveInfo.dmi8WIFV.length > 0) {%> '{<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[0].PrimaryBits[2]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[0].PrimaryBits[1]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[0].PrimaryBits[0]%>},'{'{<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[0].SecondaryBits[2]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[0].SecondaryBits[1]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[0].SecondaryBits[0]%>}}<%} else {%> '{},'{}<%}%> },
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{<% if(obj.AiuInfo[0].InterleaveInfo.dmi16WIFV.length > 0) {%> '{<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].PrimaryBits[3]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].PrimaryBits[2]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].PrimaryBits[1]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].PrimaryBits[0]%>},'{'{<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].SecondaryBits[3]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].SecondaryBits[2]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].SecondaryBits[1]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].SecondaryBits[0]%>}}<%} else {%> '{},'{}<%}%> }
                                                 },
                                                  // Idx=1 in MAX_IF
                                                 '{
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{<% if(obj.AiuInfo[0].InterleaveInfo.dmi2WIFV.length > 1) {%> '{<%=obj.AiuInfo[0].InterleaveInfo.dmi2WIFV[1].PrimaryBits[0]%>},'{'{<%=obj.AiuInfo[0].InterleaveInfo.dmi2WIFV[1].SecondaryBits[0]%>}}<%} else {%> '{},'{}<%}%>},
                                                 '{<% if(obj.AiuInfo[0].InterleaveInfo.dmi3WIFV.length > 1) {%> '{<%=obj.AiuInfo[0].InterleaveInfo.dmi3WIFV[1].PrimaryBits[1]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi3WIFV[1].PrimaryBits[0]%>},'{'{<%=obj.AiuInfo[0].InterleaveInfo.dmi3WIFV[1].SecondaryBits[1]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi3WIFV[1].SecondaryBits[0]%>}}<%} else {%> '{},'{}<%}%> },
                                                 '{<% if(obj.AiuInfo[0].InterleaveInfo.dmi4WIFV.length > 1) {%> '{<%=obj.AiuInfo[0].InterleaveInfo.dmi4WIFV[1].PrimaryBits[1]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi4WIFV[1].PrimaryBits[0]%>},'{'{<%=obj.AiuInfo[0].InterleaveInfo.dmi4WIFV[1].SecondaryBits[1]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi4WIFV[1].SecondaryBits[0]%>}}<%} else {%> '{},'{}<%}%> },
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{<% if(obj.AiuInfo[0].InterleaveInfo.dmi8WIFV.length > 1) {%> '{<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[1].PrimaryBits[2]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[1].PrimaryBits[1]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[1].PrimaryBits[0]%>},'{'{<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[1].SecondaryBits[2]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[1].SecondaryBits[1]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV[1].SecondaryBits[0]%>}}<%} else {%> '{},'{}<%}%> },
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{'{},'{}},
                                                 '{<% if(obj.AiuInfo[0].InterleaveInfo.dmi16WIFV.length > 1) {%> '{<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[1].PrimaryBits[3]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[1].PrimaryBits[2]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[1].PrimaryBits[1]%>,<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[1].PrimaryBits[0]%>},'{'{<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[1].SecondaryBits[3]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[1].SecondaryBits[2]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[1].SecondaryBits[1]%>},'{<%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[1].SecondaryBits[0]%>}}<%} else {%> '{},'{}<%}%> }
                                                 }
                                                 };
                                                
  //Below D.S accessed w.r.t dii_id
  const static int diiIds[$] = '{<% for(let i = 0; i < diiIds.length; i++) { %><%=diiIds[i]%><%if(i < diiIds.length-1) { %>,<% } } %> };
  const static int wEndpoint[$] = '{<% for(let i = 0; i < wEndpoint.length; i++) { %><%=wEndpoint[i]%><%if(i < wEndpoint.length-1) { %>,<% } } %> };

  //Non-const and 2-D queues because can be run-time programable
  static memregion_boundaries_t memregion_boundaries[$] = '{
      <% memRegionBoundaries.forEach(function(bundle, indx, array) { %>
        '{64'h<%=bundle.startAddr%>, 64'h<%=bundle.endAddr%>}<%if(indx !== memRegionBoundaries.length-1){%>,<%}%>
      <% }); %>
                                                             };
  const static int aiu_ids[<%=aiuIds.length%>] = {<%=aiuIds%>};
  const static int dce_ids[<%=dceIds.length%>] = {<%=dceIds%>};
  const static int dmi_ids[<%=dmiIds.length%>] = {<%=dmiIds%>};
  const static int dii_ids[<%=diiIds.length%>] = {<%=diiIds%>};
  const static int dve_ids[<%=dveIds.length%>] = {<%=dveIds%>};
  <%if (obj.GiuInfo && obj.GiuInfo.length > 0) {%>
  const static int giu_ids[<%=giuIds.length%>] = {<%=giuIds%>};
  <%}%>
  const static int funit_ids[<%=funitids().length%>] = {<%=funitids()%>};
  const static int aiu_nids[<%=aiuIds.length%>] = {<%=aiuNIds%>};
  const static int dce_nids[<%=dceIds.length%>] = {<%=dceNIds%>};
  const static int dmi_nids[<%=dmiIds.length%>] = {<%=dmiNIds%>};
  const static int dii_nids[<%=diiIds.length%>] = {<%=diiNIds%>};
  const static int dmiUseAtomic[<%=dmiUseAtomic.length%>] = {<%=dmiUseAtomic%>};
  <%if(stashNids.length > 0) { %>   
    const static int stash_nids [<%=stashNids.length%>] = {<%=stashNids%>};
  <% } else { %>
    const static int stash_nids [] = {};
   <% } %>
    const static int stash_nids_forbidden [<%=stashNids_forbidden.length%>] = {<%=stashNids_forbidden%>};
    <%if(stashNids_non_chi_aius.length > 0){%>
    const static int stash_nids_non_chi_aius [<%=stashNids_non_chi_aius.length%>] = {<%=stashNids_non_chi_aius%>};
    <%} else {%>
    const static int stash_nids_non_chi_aius [] = {};
    <%}%>
   <%if(stashNids_ace_aius.length > 0) { %>
      const static int stash_nids_ace_aius [<%=stashNids_ace_aius.length%>] = {<%=stashNids_ace_aius%>};
   <% } else { %>
      const static int stash_nids_ace_aius [] = {};
   <% } %>
   <%if(stashNids_target_ace_aius.length > 0) { %>
      const static int stash_nids_target_ace_aius [<%=stashNids_target_ace_aius.length%>] = {<%=stashNids_target_ace_aius%>};
   <% } else { %>
      const static int stash_nids_target_ace_aius [] = {};
   <% } %>
   <%if(stashNids_target_axi_aius.length > 0) { %>
      const static int stash_nids_target_axi_aius [<%=stashNids_target_axi_aius.length%>] = {<%=stashNids_target_axi_aius%>};
   <% } else { %>
      const static int stash_nids_target_axi_aius [] = {};
   <% } %>
   <%if(stashNids_target_chi_aius.length > 0) { %>
      const static int stash_nids_target_chi_aius [<%=stashNids_target_chi_aius.length%>] = {<%=stashNids_target_chi_aius%>};
   <% } else { %>
      const static int stash_nids_target_chi_aius [] = {};
   <% } %>
    static bit [W_SEC_ADDR -1: 0] user_addrq[][$];
    static bit [W_SEC_ADDR -1: 0] tmp_user_addrq[][$]; // For the user to modify/update/make changes as he wishes

  static bit [ADDR_WIDTH-1-WCACHE_OFFSET: 0] atomic_addrq[$]; //used for constraints in io_subsys_axi_master_transaction file
    
  //Refer A4.5 Mismatched Memory Attributes. 
    //Below addrq are needed to add constraints on addresses to prevent mismatched memory attributes. 
    //See more details in CONC-15264 
    static bit [W_SEC_ADDR-1:0] axcache_cacheable_addrq[int][$];	
    static bit [W_SEC_ADDR-1:0] split_cacheable_addrq[$];	
  
    //Snoop Filters Information
  static sf_info_t snoop_filters_info[$] = '{
      <% snoopFilters.forEach(function(b, i, array) { %>
        '{"<%=b.filterType%>", <%=b.nSets%>, <%=b.nWays%>, "<%=b.tagFilterType%>", <%=b.nVictimEntries%>, <%=b.errorType%>, <%=b.eccSplitFactor%>, "<%=b.repPolicy%>"}<% if(i !== snoopFilters.length -1) { %>,<% } }); %>
                                              };

  const static selection_data_t aiu_port_sel[$] = '{
      <% aiuPortSel.forEach(function(bundle, i, array) { %>
        '{<%=bundle.nEntries%>, <%=bundle.nResorcs%>, '{<%=bundle.primBits%>}, '{<%bundle.hashBits.forEach(function(val, _i){%>'{<%=val%>}<%if(_i !==bundle.hashBits.length - 1) {%>,<% } });%>}, "<%=bundle.strInfo%>"}<%if(i !== aiuPortSel.length-1) {%>,<%} });%>
                                                        };
  const static selection_data_t dce_port_sel[$] = '{
      <% dcePortSel.forEach(function(bundle, i, array) { %>
        '{<%=bundle.nEntries%>, <%=bundle.nResorcs%>, '{<%bundle.primBits.forEach(function(val, _i){%><%=val%><%if(_i !==bundle.primBits.length - 1) {%>,<% } });%>}, '{<%bundle.hashBits.forEach(function(val, _i){%>'{<%=val%>}<%if(_i !==bundle.hashBits.length - 1) {%>,<% } });%>}, "<%=bundle.strInfo%>"}<%if(i !== dcePortSel.length-1) {%>,<%} });%>
                                                        };
  <% if (obj.useCsrProgrammedAddrRangeInfo) { %>
    static selection_data_t dmi_port_sel[$];
    static selection_data_t dii_port_sel[$];
  <% } else { %>
    static selection_data_t dmi_port_sel[$] = '{
  <% dmiPortSel.forEach(function(bundle, i, array) { %>
        '{<%=bundle.nEntries%>, <%=bundle.nResorcs%>, '{<%=bundle.primBits%>}, '{<%bundle.hashBits.forEach(function(val, _i){%>'{<%=val%>}<%if(_i !==bundle.hashBits.length - 1) {%>,<% } });%>}, "<%=bundle.strInfo%>"}<%if(i !== dmiPortSel.length-1) {%>,<%} });%>
                                                        };
  static selection_data_t dii_port_sel[$] = '{
      <% diiPortSel.forEach(function(bundle, i, array) { %>
        '{<%=bundle.nEntries%>, <%=bundle.nResorcs%>, '{<%=bundle.primBits%>}, '{<%bundle.hashBits.forEach(function(val, _i){%>'{<%=val%>}<%if(_i !==bundle.hashBits.length - 1) {%>,<% } });%>}, "<%=bundle.strInfo%>"}<%if(i !== diiPortSel.length-1) {%>,<%} });%>
                                                        };
  <% } %>

<% 
const ioaiu_ccp_PriSubDiagAddrBits = [];
const ioaiu_ccp_DataBankSelBits = [];
obj.AiuInfo.forEach(function(bundle, indx) {
     if((bundle.fnNativeInterface != "CHI-B") && (bundle.fnNativeInterface != "CHI-E")) {
        if(bundle.useCache) {
            ioaiu_ccp_PriSubDiagAddrBits.push(bundle.ccpParams.PriSubDiagAddrBits);
            ioaiu_ccp_DataBankSelBits.push(bundle.ccpParams.DataBankSelBits);
        } else {
            ioaiu_ccp_PriSubDiagAddrBits.push([]);
            ioaiu_ccp_DataBankSelBits.push([]);
     }}
}); %>

    const static int ioaiu_ccp_PriSubDiagAddrBits[$][$] = '{
<% ioaiu_ccp_PriSubDiagAddrBits.forEach(function(bundle, indx) { %>
    '{<%=bundle%>}  <%if(indx <ioaiu_ccp_PriSubDiagAddrBits.length - 1) {%>,<% } %>
<% }); %>
    };

    const static int ioaiu_ccp_DataBankSelBits[$][$] = '{
<% ioaiu_ccp_DataBankSelBits.forEach(function(bundle, indx) { %>
    '{<%=bundle%>}  <%if(indx <ioaiu_ccp_DataBankSelBits.length - 1) {%>,<% } %>
<% }); %>
    };

  const static selection_data_t cbi_set_sel[$] = '{
      <% cbiCache.forEach(function(bundle, i, array) { %>
        '{<%=bundle.nEntries%>, <%=bundle.nResorcs%>, '{<%=bundle.primBits%>}, '{<%bundle.hashBits.forEach(function(val, _i){%>'{<%=val%>}<%if(_i !==bundle.hashBits.length - 1) {%>,<% } });%>}, "<%=bundle.strInfo%>"}<%if(i !== cbiCache.length-1) {%>,<%} });%>
                                                        };
  const static selection_data_t sf_set_sel[$] = '{
      <% sfCache.forEach(function(bundle, i, array) { %>
        '{<%=bundle.nEntries%>, <%=bundle.nResorcs%>, '{<%=bundle.primBits%>}, '{<%bundle.hashBits.forEach(function(val, _i){%>'{<%=val%>}<%if(_i !==bundle.hashBits.length - 1) {%>,<% } });%>}, "<%=bundle.strInfo%>"}<%if(i !== sfCache.length-1) {%>,<%} });%>
                                                        };
  const static selection_data_t cmc_set_sel[$] = '{
      <% cmcCache.forEach(function(bundle, i, array) { %>
        '{<%=bundle.nEntries%>, <%=bundle.nResorcs%>, '{<%=bundle.primBits%>}, '{<%bundle.hashBits.forEach(function(val, _i){%>'{<%=val%>}<%if(_i !==bundle.hashBits.length - 1) {%>,<% } });%>}, "<%=bundle.strInfo%>"}<%if(i !== cmcCache.length-1) {%>,<%} });%>
                                                        };
      <% var max_val = 0; cmcCache.forEach(function(bundle,i,array){ if(Math.max.apply(Math, bundle.primBits) > max_val) max_val = Math.max.apply(Math, bundle.primBits);});%>
  const static int MIN = <%=max_val%>;

  const static int snp_credits_inflight[NUM_COH_VISB_AIUS] = '{<%=snpCreditsPerAiu()%>};
  const static int mrd_credits_inflight[NUM_DMIS] = '{<%=mrdCreditsPerDmi()%>};
  const static int dvm_msg_capb_agents[$] = '{<%=dvmMsgAgents%>};
  const static int dvm_snp_capb_agents[$] = '{<%=dvmCmpAgents%>};
  
  static bit [(W_SEC_ADDR-1):0] dii_memory_domain_start_addr[$]; 
  static bit [(W_SEC_ADDR-1):0] dii_memory_domain_end_addr[$]; 
  static bit [(W_SEC_ADDR-1):0] dmi_memory_domain_start_addr[$]; 
  static bit [(W_SEC_ADDR-1):0] dmi_memory_domain_end_addr[$]; 
  static bit [(W_SEC_ADDR-1):0] dmi_memory_coh_domain_start_addr[$]; 
  static bit [(W_SEC_ADDR-1):0] dmi_memory_coh_domain_end_addr[$]; 
  static bit [(W_SEC_ADDR-1):0] dmi_memory_noncoh_domain_start_addr[$]; 
  static bit [(W_SEC_ADDR-1):0] dmi_memory_noncoh_domain_end_addr[$]; 

  static bit [(ADDR_WIDTH-1):0] dmi_memory_noncoh_noncacheable_domain_start_addr[$]; 
  static bit [(ADDR_WIDTH-1):0] dmi_memory_noncoh_noncacheable_domain_end_addr[$]; 
  static bit [(ADDR_WIDTH-1):0] dmi_memory_noncoh_cacheable_domain_start_addr[$]; 
  static bit [(ADDR_WIDTH-1):0] dmi_memory_noncoh_cacheable_domain_end_addr[$]; 

  const static aiu_intv_bits_t mp_aiu_intv_bits[$] = '{<%mp_aiu_intv_func.forEach(function(bundle, i) { %>
                                                      '{'{<%=bundle.primBits%>}, '{<%=bundle.secBits%>} } <%if(i !== mp_aiu_intv_func.length-1) {%>,<%} });%>
                                                       };

  const static aiu_ig_bits_t aiu_ig_bits[$] = '{<%aiu_ig_bits_func.forEach(function(bundle, i) { %>
                                               '{'{<%=bundle.fUnitIds%>}, '{<%=bundle.aPrimaryAiuPortBits%>} } <%if(i !== aiu_ig_bits_func.length-1) {%>,<%} });%>
                                               };

  parameter int nb_aiu_ig_bits = <%=aiu_ig_bits_func.length%>;

  const static aiu_intv_bits_t dce_intv_bits[$] = '{<% dcePortSel.forEach(function(bundle, i, array) { %>
                                                  '{ '{<%bundle.primBits.forEach(function(val, _i){%><%=val%><%if(_i !==bundle.primBits.length - 1) {%>,<% } });%>}, '{}} <%if(i !== dcePortSel.length-1) {%>,<%} });%>
                                                  };         
<% 
const UnitConnectivityMap   = [];
const ConnectivityMapConcat = [];
const AiuDceConnectivityMap = [];
const AiuDmiConnectivityMap = [];
const AiuDiiConnectivityMap = [];
const DceAiuConnectivityMap = [];
const DceDmiConnectivityMap = [];
for (let i = 0; i < (obj.AiuInfo.length + obj.DceInfo.length); i++) { 

    if (i < obj.AiuInfo.length) {
        AiuDceConnectivityMap.push([i,obj.ConnectivityMap.aiuDceMap[i]]);
        AiuDmiConnectivityMap.push([i,obj.ConnectivityMap.aiuDmiMap[i]]);
        AiuDiiConnectivityMap.push([i,obj.ConnectivityMap.aiuDiiMap[i]]);

        if (Array.isArray(obj.ConnectivityMap.aiuDceMap[i])) {
            ConnectivityMapConcat[i] = obj.ConnectivityMap.aiuDceMap[i];
        }
        if (Array.isArray(obj.ConnectivityMap.aiuDmiMap[i])) {
            ConnectivityMapConcat[i] = ConnectivityMapConcat[i].concat(obj.ConnectivityMap.aiuDmiMap[i]);
        }
        if (Array.isArray(obj.ConnectivityMap.aiuDiiMap[i])) {
            ConnectivityMapConcat[i] = ConnectivityMapConcat[i].concat(obj.ConnectivityMap.aiuDiiMap[i]);
        }
    
        UnitConnectivityMap.push([i,ConnectivityMapConcat[i]]);

    } else {
        var j = i-obj.AiuInfo.length;
        UnitConnectivityMap.push([i,obj.ConnectivityMap.dceAiuMap[i].concat(obj.ConnectivityMap.dceDmiMap[i])]);
        DceAiuConnectivityMap.push([j,obj.ConnectivityMap.dceAiuMap[i]]);
        DceDmiConnectivityMap.push([j,obj.ConnectivityMap.dceDmiMap[i]]);
    }
}
console.table(UnitConnectivityMap);
console.table(ConnectivityMapConcat);
console.table(AiuDceConnectivityMap);
console.table(AiuDmiConnectivityMap);
console.table(AiuDiiConnectivityMap);
console.table(DceAiuConnectivityMap);
console.table(DceDmiConnectivityMap);
%>  

const static unit_connected_ids_t aiu_dce_connected_dce_dmi_dii_ids[$] = '{<%UnitConnectivityMap.forEach(function(bundle,i) { %>
                                                         '{ <%=bundle[0]%>, '{<%=bundle[1]%>} } <%if(i !== UnitConnectivityMap.length-1) {%>,<%} });%>
                                                         };

const static unit_connected_ids_t aiu_connected_dce_ids[$] = '{<%AiuDceConnectivityMap.forEach(function(bundle,i) { %>
                                                            '{ <%=bundle[0]%>, '{<%=bundle[1]%>} }  <%if(i !== AiuDceConnectivityMap.length-1) {%>,<%} });%>
                                                            };
const static unit_connected_ids_t aiu_connected_dmi_ids[$] = '{<%AiuDmiConnectivityMap.forEach(function(bundle,i) { %>
                                                            '{ <%=bundle[0]%>, '{<%=bundle[1]%>} }  <%if(i !== AiuDmiConnectivityMap.length-1) {%>,<%} });%>
                                                            };
const static unit_connected_ids_t aiu_connected_dii_ids[$] = '{<%AiuDiiConnectivityMap.forEach(function(bundle,i) { %>
                                                            '{ <%=bundle[0]%>, '{<%=bundle[1]%>} }  <%if(i !== AiuDiiConnectivityMap.length-1) {%>,<%} });%>
                                                            };
const static unit_connected_ids_t dce_connected_aiu_ids[$] = '{<%DceAiuConnectivityMap.forEach(function(bundle,i) { %>
                                                            '{ <%=bundle[0]%>, '{<%=bundle[1]%>} }  <%if(i !== DceAiuConnectivityMap.length-1) {%>,<%} });%>
                                                            };
const static unit_connected_ids_t dce_connected_dmi_ids[$] = '{<%DceDmiConnectivityMap.forEach(function(bundle,i) { %>
                                                            '{ <%=bundle[0]%>, '{<%=bundle[1]%>} }  <%if(i !== DceDmiConnectivityMap.length-1) {%>,<%} });%>
                                                            };
<%for( let i=0; i< obj.DmiInfo.length; i++){  if (obj.DmiInfo[i].useCmc && obj.DmiInfo[i].ccpParams.useScratchpad && i==0) { %>
const static int dmi_igsv[$][$][$]= '{ <%=getDmiIgsvData(obj.DmiInfo[0].InterleaveInfo.dmiIGSV)%> }; <% } }%>

<%var dmi_width=1;  if(obj.nDMIs > 0){ dmi_width = obj.nDMIs;}%>
static int DMI_MIF_way[<%=dmi_width%>], DMI_MIF_function[<%=dmi_width%>], DMI_MIG_set[<%=dmi_width%>];

<% if (numIoMaster > 0 && obj.testBench != "io_aiu") { %>
//Scratchpad CSR programmed variables1416
const static string io_subsys_nativeif_a[NUM_IO_MASTERS]
            = '{
<% let ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(ioaiu_cntr<(numIoMaster-1)) { %>    
     "<%=obj.AiuInfo[pidx].fnNativeInterface%>",
<% } else { %>    
     "<%=obj.AiuInfo[pidx].fnNativeInterface%>"
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};
/*const static int io_subsys_useCache_en[NUM_IO_MASTERS]
            = '{
<%
    ioaiu_cntr = 0;
    for (let pidx = 0; pidx < obj.nAIUs; pidx++) {
        if (!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
        for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
%>
    <%= obj.AiuInfo[pidx].useCache %><% if (ioaiu_cntr < (numIoMaster - 1)) { %>,<% } %>
<%
            ioaiu_cntr++;
        }}
    }
%>
};*/


<%let io_owo_enable;%>
const static bit io_subsys_owo_en[NUM_IO_MASTERS]
            = '{
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
io_owo_enable = (obj.AiuInfo[pidx].orderedWriteObservation==false)? 0 : 1;
//io_owo_enable = (obj.AiuInfo[pidx].assertOn == 0) && ((((obj.AiuInfo[pidx].fnNativeInterface === "AXI4") && (obj.AiuInfo[pidx].useCache==0)) || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) ? 1 : 0);
if(ioaiu_cntr<(numIoMaster-1)) { %>    
     <%=io_owo_enable%>,
<% } else { %>    
     <%=io_owo_enable%>
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};

<%let io_multiport;%>
const static bit io_multiport[NUM_IO_MASTERS]
            = '{
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
io_multiport = (obj.AiuInfo[pidx].nNativeInterfacePorts>1)? 1: 0;
if(ioaiu_cntr<(numIoMaster-1)) { %>    
     <%=io_multiport%>,
<% } else { %>    
     <%=io_multiport%>
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};


<%let intf_parity_chk_enable;%>
const static bit io_subsys_intf_parity_chk_en[NUM_IO_MASTERS]
            = '{
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
     computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
}else{
     computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
}
intf_parity_chk_enable = (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")? 1 : 0; 
if(ioaiu_cntr<(numIoMaster-1)) { %>    
     <%=intf_parity_chk_enable%>,
<% } else { %>    
     <%=intf_parity_chk_enable%>
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};


<%var wdata;%>
const static int io_subsys_wdata_a[NUM_IO_MASTERS]
            = '{
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
wdata = obj.AiuInfo[pidx].wData;
if(ioaiu_cntr<(numIoMaster-1)) { %>    
     <%=wdata%>,
<% } else { %>    
     <%=wdata%>
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};

<%var dvm_enable;%>
const static bit io_subsys_dvm_enable_a[NUM_IO_MASTERS]
            = {
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
    computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
}else{
    computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
}
    if((obj.AiuInfo[pidx].fnNativeInterface.match("ACE") || obj.AiuInfo[pidx].fnNativeInterface.match("ACE5")) && computedAxiInt.params.eAc == 1) {
        dvm_enable=1;
    } else dvm_enable=0;
if(ioaiu_cntr<(numIoMaster-1)) { %>    
     <%=dvm_enable%>,
<% } else { %>    
     <%=dvm_enable%>
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};

<%var atomic_enable;%>
const static bit io_subsys_atomic_enable_a[NUM_IO_MASTERS]
            = {
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
    computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
}else{
    computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
}
    if((obj.AiuInfo[pidx].fnNativeInterface.match("ACELITE-E") && (computedAxiInt.params.atomicTransactions==true)) || (obj.AiuInfo[pidx].fnNativeInterface.match("AXI5") && (computedAxiInt.params.atomicTransactions==true))) {
        atomic_enable=1;
    } else atomic_enable=0;
if(ioaiu_cntr<(numIoMaster-1)) { %>    
     <%=atomic_enable%>,
<% } else { %>    
     <%=atomic_enable%>
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};

const static int num_outstanding_xacts[NUM_IO_MASTERS]
            = {
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(ioaiu_cntr<(numIoMaster-1)) { %>    
<%=obj.AiuInfo[pidx].cmpInfo.nOttCtrlEntries%>,
<% } else { %>    
<%=obj.AiuInfo[pidx].cmpInfo.nOttCtrlEntries%>
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};

const static int io_subsys_funitid_a[NUM_IO_MASTERS]
            = {
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(ioaiu_cntr<(numIoMaster-1)) { %>    
     <%=obj.AiuInfo[pidx].FUnitId%>,
<% } else { %>    
     <%=obj.AiuInfo[pidx].FUnitId%>
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};
    
const static string io_subsys_instname_a[NUM_IO_MASTERS]
           = '{
        <% ioaiu_cntr=0; 
        for(let pidx=0; pidx<obj.nAIUs; pidx++) {  
        if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { 
            if ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4" || obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && obj.AiuInfo[pidx].nNativeInterfacePorts > 1) {
                for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
                    if(ioaiu_cntr<(numIoMaster-1)) { %>    
                "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_c<%=i%>",
                    <% } else { %>    
                "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_c<%=i%>"
                    <% }  
                ioaiu_cntr = ioaiu_cntr + 1;
                }
            } else {
                if(ioaiu_cntr<(numIoMaster-1)) { %>    
                "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>",
                <% } else { %>    
                "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"
                <% }  
                ioaiu_cntr = ioaiu_cntr + 1;
            }}} %>
        };
       <% 
    const nOttSize = [];
    let num_ioc=0;
    const ioc_set_idx_w=[];
    const ioc_mstr_idx=[];
    let ioc_num_mstr=0;
    const ioc_nWay=[];
    ioaiu_cntr=0; 
    for(let pidx=0; pidx<obj.nAIUs; pidx++) {  
        if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { 
        nOttSize.push(obj.AiuInfo[pidx].cmpInfo.nOttCtrlEntries);
        if ((obj.AiuInfo[pidx].fnNativeInterface.match("AXI4") || obj.AiuInfo[pidx].fnNativeInterface.match("AXI5")) && obj.AiuInfo[pidx].useCache==1 ) {
           for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
               ioc_set_idx_w.push(obj.AiuInfo[pidx].ccpParams.PriSubDiagAddrBits.length);
               ioc_nWay.push(obj.AiuInfo[pidx].ccpParams.nWays);
               ioc_mstr_idx.push(ioc_num_mstr);
               num_ioc=num_ioc+1;
               ioc_num_mstr=ioc_num_mstr+1;
           }
        } else {
        ioc_num_mstr=ioc_num_mstr+1;
        }
     } }
     
    %>
    parameter int MAX_IOAIU_OTT_SIZE = <%=Math.max.apply(null, nOttSize)%>;
    parameter int NUM_IOC = <%=num_ioc%>;
    static int ioc_set_idx_w[] = {<%=ioc_set_idx_w%>};
    static int ioc_mstr_idx[] = {<%=ioc_mstr_idx%>};
    static int ioc_nWay[] = {<%=ioc_nWay%>};
    parameter int SYS_wSysCacheline = <%=obj.wCacheLineOffset%>;
<%}%>

<% if (numIoMaster > 0 && obj.testBench == "io_aiu") { %>
//Scratchpad CSR programmed variables1540
const static string io_subsys_nativeif_a[NUM_IO_MASTERS]
            = '{
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI") && obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(ioaiu_cntr<(numIoMaster)) { %>    
     "<%=obj.AiuInfo[pidx].fnNativeInterface%>"
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};

<%let io_owo_enable;%>
const static bit io_subsys_owo_en[NUM_IO_MASTERS]
            = '{
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI") && obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
io_owo_enable = (obj.AiuInfo[pidx].orderedWriteObservation==false)? 0 : 1;
//io_owo_enable = (obj.AiuInfo[pidx].assertOn == 0) && ((((obj.AiuInfo[pidx].fnNativeInterface === "AXI4") && (obj.AiuInfo[pidx].useCache==0)) || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) ? 1 : 0);
if(ioaiu_cntr<(numIoMaster)) { %>    
     <%=io_owo_enable%>
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};

<%var dvm_enable;%>
const static bit io_subsys_dvm_enable_a[NUM_IO_MASTERS]
            = {
<% ioaiu_cntr=0;
let computedAxiInt;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI") && obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
    computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
}else{
    computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
}
    if((obj.AiuInfo[pidx].fnNativeInterface.match("ACE") || obj.AiuInfo[pidx].fnNativeInterface.match("ACE5")) && computedAxiInt.params.eAc == 1) {
        dvm_enable=1;
    } else dvm_enable=0;
if(ioaiu_cntr<(numIoMaster)) { %>    
     <%=dvm_enable%>
<% }    
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};

<%var atomic_enable;%>
const static bit io_subsys_atomic_enable_a[NUM_IO_MASTERS]
            = {
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI") && obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
    computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
}else{
    computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
}
    if((obj.AiuInfo[pidx].fnNativeInterface.match("ACELITE-E") && (computedAxiInt.params.atomicTransactions==true)) || (obj.AiuInfo[pidx].fnNativeInterface.match("AXI5") && (computedAxiInt.params.atomicTransactions==true))) {
        atomic_enable=1;
    } else atomic_enable=0;
if(ioaiu_cntr<(numIoMaster)) { %>    
     <%=atomic_enable%>
<% }   
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};
const static int num_outstanding_xacts[NUM_IO_MASTERS]
            = {
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")&& obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(ioaiu_cntr<(numIoMaster)) { %>    
<%=obj.AiuInfo[pidx].cmpInfo.nOttCtrlEntries%>
<% }    
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};

const static int io_subsys_funitid_a[NUM_IO_MASTERS]
            = {
<% ioaiu_cntr=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")&& obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId) {
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(ioaiu_cntr<(numIoMaster)) { %>    
     <%=obj.AiuInfo[pidx].FUnitId%>

<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};
    
const static string io_subsys_instname_a[NUM_IO_MASTERS]
           = '{
        <% ioaiu_cntr=0; 
        for(let pidx=0; pidx<obj.nAIUs; pidx++) {  
        if((!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) && obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId) { 
            if ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4" || obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && obj.AiuInfo[pidx].nNativeInterfacePorts > 1) {
                for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
                    if(ioaiu_cntr<(numIoMaster)) { %>    
                "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_c<%=i%>"
                    <% }  
                ioaiu_cntr = ioaiu_cntr + 1;
                }
            } else {
                if(ioaiu_cntr<(numIoMaster)) { %>    
                "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"
                 <% }  
                ioaiu_cntr = ioaiu_cntr + 1;
            }}} %>
        };
       <% 
    const nOttSize = [];
    let num_ioc=0;
    const ioc_set_idx_w=[];
    const ioc_mstr_idx=[];
    let ioc_num_mstr=0;
    const ioc_nWay=[];
    ioaiu_cntr=0; 
    for(let pidx=0; pidx<obj.nAIUs; pidx++) {  
        if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI") && obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId) { 
        nOttSize.push(obj.AiuInfo[pidx].cmpInfo.nOttCtrlEntries);
        if ((obj.AiuInfo[pidx].fnNativeInterface.match("AXI4") || obj.AiuInfo[pidx].fnNativeInterface.match("AXI5")) && obj.AiuInfo[pidx].useCache==1 ) {
           for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
               ioc_set_idx_w.push(obj.AiuInfo[pidx].ccpParams.PriSubDiagAddrBits.length);
               ioc_nWay.push(obj.AiuInfo[pidx].ccpParams.nWays);
               ioc_mstr_idx.push(ioc_num_mstr);
               num_ioc=num_ioc+1;
               ioc_num_mstr=ioc_num_mstr+1;
           }
        } else {
        ioc_num_mstr=ioc_num_mstr+1;
        }
     } }
     
    %>
    parameter int MAX_IOAIU_OTT_SIZE = <%=Math.max.apply(null, nOttSize)%>;
    parameter int NUM_IOC = <%=num_ioc%>;
    static int ioc_set_idx_w[] = {<%=ioc_set_idx_w%>};
    static int ioc_mstr_idx[] = {<%=ioc_mstr_idx%>};
    static int ioc_nWay[] = {<%=ioc_nWay%>};
    parameter int SYS_wSysCacheline = <%=obj.wCacheLineOffset%>;

<%}%>



////////////////
//Methods to access above data structures
////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_addr_as_per_new_nrs 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit [63:0] set_addr_as_per_new_nrs(input bit [63:0] addr);
    addr = {NRS_REGION_BASE[51:20],addr[19:0]};
    return addr;
endfunction : set_addr_as_per_new_nrs

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_addr_as_per_old_nrs
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit [63:0] set_addr_as_per_old_nrs(input bit [63:0] addr);
    addr = {NRS_REGION_BASE_COPY[51:20],addr[19:0]};
    return addr;
endfunction : set_addr_as_per_old_nrs

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_unit_type 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function ncore_unit_type_t get_unit_type(int funitid);
        int q[$], p[$];

     p = funit_ids.find_index(x) with (x == funitid);
    if (p.size() == 0)
            `uvm_error("NCORE_CONFIG_INFO", $psprintf("fn:get_unit_type FunitId: %0d does not match with any value in config CONFIGURATION ERROR", funitid))

      if (p.size() > 1)
             `uvm_error("NCORE_CONFIG_INFO", $psprintf("fn:get_unit_type Multiple mathces for FunitId: %0d CONFIGURATION ERROR", funitid))
            
          q = aiu_ids.find(x) with (x == p[0]);
          if (q.size())
            return AIU;

          q = dce_ids.find(x) with (x == p[0]);
          if (q.size())
            return DCE;

          q = dmi_ids.find(x) with (x == p[0]);
          if (q.size())
            return DMI;

          q = dii_ids.find(x) with (x == p[0]);
          if (q.size())
            return DII;

          q = dve_ids.find(x) with (x == p[0]);
          if (q.size())
            return DVE;
<%if (obj.GiuInfo && obj.GiuInfo.length >0) {%>
          q = giu_ids.find(x) with (x == p[0]);
          if (q.size())
            return GIU;
<%}%>
          `uvm_fatal("NCORE_CONFIG_INFO", $psprintf("fn:get_unit_type Unexpected funitid:0x%0h", funitid))
          return AIU;
   
endfunction: get_unit_type

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_cache_id
// Description : Note: Method returns -1 if agent is not a cacheing agent
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_cache_id(input int agent_id, bit fail_on_err = 1'b1);
    int cache_id = -1;

    foreach(cache2funit_map[ridx]) begin
        for(int i = 0; i < cache2funit_map[ridx].size(); i++) begin
            if(cache2funit_map[ridx][i] == agent_id) begin
                `uvm_info("ADDR MGR", $psprintf("agent %0d is a cacheing agent with id %0d", agent_id, ridx), UVM_HIGH)
                cache_id = ridx;
            end
        end
    end

    return(cache_id);
endfunction: get_cache_id;

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_cache_id_as_string
// Description : Note: Method returns -1 if agent is not a cacheing agent
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function string get_cache_id_as_string(input int agent_id, bit fail_on_err = 1'b1);
    int cache_id = get_cache_id(agent_id, fail_on_err);
    string cache_id_str = (cache_id >= 0) ? $psprintf("0x%02h", cache_id) : " -- ";

    return(cache_id_str);
endfunction: get_cache_id_as_string;

    
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_agent_ids_assoc2cacheid
// Description : Method returns agentIds associated to caching-agentID specified 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function intq get_agent_ids_assoc2cacheid(input int cache_id);
    int tmpq[$];

  //  HS: Commented out code that did not work. stays for reference. delete eventually.
  //  foreach(cache2funit_map[cache_id,idx]) begin
  //      tmpq.push_back(cache2funit_map[cache_id][idx]);
  //  end
    
    for(int i = 0; i < cache2funit_map[cache_id].size(); i++) begin
        tmpq.push_back(cache2funit_map[cache_id][i]);
    end

    if(tmpq.size() == 0)
        `uvm_fatal("ADDR MGR", $psprintf("Unexpected Cache-Id %0d; Total number of Cache-Is %0d", cache_id, NUM_CACHES));
    if(tmpq.size() != 1) begin
        foreach(tmpq[idx]) begin
            `uvm_info("DBG", $psprintf("id:%0d val:%0d",idx, tmpq[idx]), UVM_LOW)
           end 
       `uvm_fatal("ADDR MGR", $psprintf("Multiple AIU agents - %0d tracked by same cache_id-%0d not expected in Ncore3.0. Total number of Cache-Is %0d", tmpq.size(), cache_id, NUM_CACHES));
    end
    return(tmpq);
endfunction: get_agent_ids_assoc2cacheid

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_snoopfilter_id
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_snoopfilter_id(input int agent_id);
    int sf_id = -1;

    if (funit2sf_slice.exists(agent_id))
        sf_id = funit2sf_slice[agent_id];
    
    `uvm_info("ADDR MGR", $psprintf("Snoop filter slice is %0d for funit_id %0d", agent_id, sf_id), UVM_DEBUG)
   
    return(sf_id);        

endfunction: get_snoopfilter_id

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_sfid_assoc2cacheid
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_sfid_assoc2cacheid(input int cache_id);
    int sf_id, funit_idq[$], funit_id;

    funit_idq = get_agent_ids_assoc2cacheid(cache_id);
    funit_id = funit_idq[0];

    sf_id = get_snoopfilter_id(funit_id);
    return(sf_id);
endfunction: get_sfid_assoc2cacheid;
    
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_sf_assoc_num_cache_agents
// Description : Method returns number of caching agents associated with this SF
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_sf_assoc_num_cache_agents(int id);
    int count; 

    if(id >= NUM_SF) 
        `uvm_fatal("ADDR MGR", $psprintf("SF ID passed (%0d) is >= total SF (%0d)", id, NUM_SF))

    count = 0;
    foreach(funit2sf_slice[i]) begin
         if(funit2sf_slice[i] == id)
             count++;
    end
    if(!count)
        `uvm_fatal("ADDR MGR", $psprintf("SF ID (%0d) not associated with any cacheing agents(%0d)", id, count))
     
    return(count);
endfunction: get_sf_assoc_num_cache_agents

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_sf_assoc_cache_agents
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function intq get_sf_assoc_cache_agents(int id);
    int tmpq[$];
    int cache_id;

    //Sanity check
    void'(get_sf_assoc_num_cache_agents(id));
    foreach(funit2sf_slice[i]) begin
         if(funit2sf_slice[i] == id) begin
             cache_id = get_cache_id(i);
             tmpq.push_back(cache_id);
         end
    end

    return(tmpq);
endfunction: get_sf_assoc_cache_agents

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_sf_assoc_agents
// Description : Method returns agentIDs associated to the SF
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function intq get_sf_assoc_agents(int id);
   int tmpq1[$], tmpq2[$], tmpq3[$];
   string s;

   tmpq1 = get_sf_assoc_cache_agents(id);

   //$sformat(s, "sfid:%0d assoc cacheing agent Ids:", id);
   //foreach(tmpq1[idx])
   //    $sformat(s, "%s %0d", s, tmpq1[idx]);
  
   //$sformat(s, "%s assoc agent Ids:", s);
   foreach(tmpq1[idx]) begin
       tmpq2 = get_agent_ids_assoc2cacheid(tmpq1[idx]);
       foreach(tmpq2[ridx]) begin
           //$sformat(s, "%s %0d", s, tmpq2[ridx]);
           tmpq3.push_back(tmpq2[ridx]);
       end
   end

   //`uvm_info("addr mgr", s, UVM_HIGH)
   if(tmpq3.size() == 0)
        `uvm_fatal("ADDR MGR", $psprintf("None of the agents associated to sfid:%0d", id))

   return(tmpq3);
endfunction: get_sf_assoc_agents

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : cacheid_assoc_with_sfid 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit cacheid_assoc_with_sfid(int sf_id, int cache_id);
    bit exists = 1'b1;
    int funit_id, funit_idq[$];

    funit_idq = get_agent_ids_assoc2cacheid(cache_id);
    funit_id = funit_idq[0];

    if(funit2sf_slice[funit_id] == sf_id)
        exists = 1'b1;
    else 
        exists = 1'b0;
    return(exists);
endfunction: cacheid_assoc_with_sfid

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : rel_indx_within_sf 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int rel_indx_within_sf(int sf_id, int cache_id);
    int count = 0;
    int funit_id, funit_idq[$];

    
    for(int i = 0; i < NUM_CACHES; i++) begin
        funit_idq = get_agent_ids_assoc2cacheid(i);
        funit_id = funit_idq[0];
        if((funit2sf_slice[funit_id] == sf_id) && (i == cache_id))
            break;
        else if(funit2sf_slice[funit_id] == sf_id)
            count++;
    end

    return(count);
endfunction: rel_indx_within_sf

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_sf_set_index
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit [WSFSETIDX-1:0] get_sf_set_index(int sf_id, bit [ADDR_WIDTH - 1:0] addr);
    bit [WSFSETIDX-1:0] set_index;
    bit result;
    string stat;

    foreach (sf_set_sel[sf_id].pri_bits[idx]) begin
        result = addr[sf_set_sel[sf_id].pri_bits[idx]];
        stat   = $psprintf("[%-35s] {addr: 0x%016h} [idx: %2d / %2d] (primaryBit[%2d] >> result: [%1b])", "addrMgr-SfSetIdx", addr, idx, sf_set_sel[sf_id].pri_bits.size(), sf_set_sel[sf_id].pri_bits[idx], result);
        if(sf_set_sel[sf_id].sec_bits.size() == 1) begin
            result = result ^ (^(addr & sf_set_sel[sf_id].sec_bits[idx][0]));
            stat   = $psprintf("%s >> (secBits: 0x%016h -> %1b :: result[%1b])", stat, sf_set_sel[sf_id].sec_bits[idx][0], (^(addr & sf_set_sel[sf_id].sec_bits[idx][0])), result);
        end
        else if(sf_set_sel[sf_id].sec_bits[idx].size() > 1) begin
           `uvm_fatal("ADDR_MGR", $psprintf("Observed more than one secondary vector per primary bit for address hashing! (idx(%1d) :: %s[%1d])", idx, sf_set_sel[sf_id].unit_desp, sf_set_sel[sf_id].pri_bits[idx]));
        end
        set_index[idx] = result;
       `uvm_info("ADDR_MGR", $psprintf("%s >> (setIdxNow: 0x%08h)", stat, set_index), UVM_DEBUG);
    end

    return(set_index);
endfunction: get_sf_set_index

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_logical_uinfo
// Description : Returns default value -1. logial id local ncore unit type
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function void get_logical_uinfo(
    input  int agent_id,//this is the FUnitId
    output int cache_id,
    output int col_indx,
    output ncore_unit_type_t utype);

    int tmp_indx, tmp_id, agent_idx;
    utype = get_unit_type(agent_id);
    tmp_id = 0;
    cache_id = -1;

    foreach(funit_ids[idx]) begin
           if(funit_ids[idx] == agent_id) begin
              agent_idx = idx;
           end
    end

    if (utype == AIU) begin 
        foreach(logical2aiu_map[ridx]) begin
            tmp_indx = 0;
            for(int i = 0; i < logical2aiu_map[ridx].size(); i++) begin
                 if(logical2aiu_map[ridx][i] == agent_idx) begin
                     cache_id = ridx;
                     col_indx = tmp_indx;
                 end
                 else 
                     tmp_indx++;
            end
        end

    end else if (utype == DCE) begin
        foreach(logical2dce_map[ridx]) begin
            tmp_indx = 0;
            for(int i = 0; i < logical2dce_map[ridx].size(); i++) begin
                 if(logical2dce_map[ridx][i] == agent_idx) begin
                     cache_id = ridx;
                     col_indx = tmp_indx;
                 end
                 else 
                     tmp_indx++;
            end
        end

    end else if (utype == DMI) begin
        foreach(logical2dmi_map[ridx]) begin
            tmp_indx = 0;
            for(int i = 0; i < logical2dmi_map[ridx].size(); i++) begin
                 if(logical2dmi_map[ridx][i] == agent_idx) begin
                     cache_id = ridx;
                     col_indx = tmp_indx;
                 end
                 else 
                     tmp_indx++;
            end
        end

    end else if (utype == DII) begin
        foreach(logical2dii_map[ridx]) begin
            tmp_indx = 0;
            for(int i = 0; i < logical2dii_map[ridx].size(); i++) begin
                 if(logical2dii_map[ridx][i] == agent_idx) begin
                     cache_id = ridx;
                     col_indx = tmp_indx;
                 end
                 else 
                     tmp_indx++;
            end
        end
    end

endfunction: get_logical_uinfo

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_agent_selbits_value
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_agent_selbits_value(int agent_id);
      int cache_id, col_indx;
      ncore_unit_type_t utype;

      get_logical_uinfo(agent_id, cache_id, col_indx, utype);
      if (utype == AIU)
        return logical2aiu_prt[cache_id][col_indx];
      
      if (utype == DCE)
        return logical2dce_prt[cache_id][col_indx];

      if (utype == DMI)
        return logical2dmi_prt[cache_id][col_indx];

      `ASSERT(0, "this line shouldn't be executed");
      return 0;
endfunction: get_agent_selbits_value


////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_logical_id
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_logical_id(int agent_id);
  int lid, cid;
  ncore_unit_type_t utype;

  get_logical_uinfo(agent_id, lid, cid, utype);
  return lid;
endfunction: get_logical_id

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_sfi_addr_width
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_sfi_addr_width(int agent_id);
    return(agent_sfiaddr_width[agent_id]);
endfunction: get_sfi_addr_width

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : is_stash_enable
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit is_stash_enable(int agent_id);

    if (stash_enable[agent_id])
        return 1;
    else 
        return 0;

endfunction: is_stash_enable
    
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : is_owo_enable
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit is_owo_enable(int agent_id);

    if (owo_enable[agent_id])
        return 1;
    else 
        return 0;

endfunction: is_owo_enable

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_native_interface
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function interface_t get_native_interface(int agent_id);
    interface_t agent_inf;

    if(!$cast(agent_inf, inf[agent_id]))
        `uvm_fatal("ADDR MGR", "Cast failed")

    `uvm_info("addr mgr", $psprintf("agent_id:%0d agent_int:%0s", agent_id, agent_inf.name()), UVM_DEBUG)

    return(agent_inf);
endfunction: get_native_interface

//Snoop Filter Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_sf_sel_bits
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function void get_sf_sel_bits(int sf_slice, ref int bit_q[$]);
    if(snoop_filters_info[sf_slice].filter_type != "TAGFILTER")
        `uvm_fatal("ADDR MGR", $psprintf("snoop Filter ID slice %0s is a NULL Filter",
        sf_slice))
   
    //bit_q = snoop_filters_info[sf_slice].sel_bits;
endfunction: get_sf_sel_bits

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_sf_hash_bits
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function void get_sf_hash_bits(int sf_slice, ref int bit_q[$]);
    if(snoop_filters_info[sf_slice].filter_type != "TAGFILTER")
        `uvm_fatal("ADDR MGR", $psprintf("snoop Filter ID slice %0s is a NULL Filter",
        sf_slice))
   
    //bit_q = snoop_filters_info[sf_slice].hash_bits;
endfunction: get_sf_hash_bits

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_idx_from_nid
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_idx_from_nid(intq idsq, int nid);
   for (int i=0; i<idsq.size(); i++) begin
  if (idsq[i] == nid)
    return i;
   end
endfunction : get_idx_from_nid
       
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_sys_dii_idx
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_sys_dii_idx();
   int nid = dii_nids[0];
   for (int i=1; i<<%=diiIds.length%>; i++)
 if (nid < dii_nids[i])
   nid = i;
   return nid;
endfunction : get_sys_dii_idx
       
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_max_procs
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_max_procs(int req_agent);
    int cache_id;
    int max_ids;

    if(get_native_interface(req_agent) == ACE_AIU ||
       get_native_interface(req_agent) == CHI_A_AIU ||
       get_native_interface(req_agent) == CHI_B_AIU || get_native_interface(req_agent) == CHI_E_AIU) begin
        cache_id = get_cache_id(req_agent);
        max_ids  = proc_ids_per_cpu[cache_id];
    end else begin
        `uvm_fatal("ADDR MGR",
            {$psprintf("TbError: agent_id:%0d native interface:%0s",
             req_agent, get_native_interface(req_agent)), 
             " Only ace agents can have proc_id's"})
    end

    if(max_ids == 0) 
        `uvm_fatal("ADDR MGR",  "ProcId's can't be 0")
    return(max_ids);
endfunction: get_max_procs

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_total_intrlv_grps
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_total_intrlv_grps();
  return intrlvgrp_if.size();
endfunction: get_total_intrlv_grps

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : log2
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int log2 (longint i); 
  if (i <= 1)
     return 0;
  else
     return log2(i/2) + 1;
endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_memregions_assoc_ig
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function sys_addrq get_memregions_assoc_ig(int ig_id);
   int dmi_target_order;
   int dii_target_order;

  sys_addr_csr_t csrq[$];
  `ASSERT(ig_id < intrlvgrp_if.size());

  //`uvm_info("addr mgr dbg", $psprintf("fn:get_memregions_assoc_ig -- > intrlvgrp2mem_map.size:%0d for ig:%0d", intrlvgrp2mem_map[ig_id].size(), ig_id), UVM_LOW)
  foreach (intrlvgrp2mem_map[ig_id][idx]) begin
     int tmpv;
     sys_addr_csr_t csr;
     int bit_width;
     
     tmpv = intrlvgrp2mem_map[ig_id][idx];
     if (intrlvgrp_if[ig_id] == DMI) begin
       bit [63:0] mig_sz;

       mig_sz = memregion_boundaries[tmpv].end_addr -
                    memregion_boundaries[tmpv].start_addr;
       nmig   = intrlvgrp_vector[picked_dmi_igs][ig_id];
       `ASSERT(mig_sz % intrlvgrp_vector[picked_dmi_igs][ig_id] == 0);
       csr.unit = DMI;
       csr.mig_nunitid = ig_id;
       csr.size = $clog2(mig_sz / nmig) - 12;
       bit_width = log2(nmig * (2 ** (csr.size+12)));
       //`uvm_info("addr mgr dbg", $psprintf("fn:get_memregios_assoc_ig -- > ig_id:%0d mig_sz:%0d nmig:%0d size:%0d, #bits=%0d", ig_id, mig_sz, nmig, csr.size, bit_width), UVM_LOW)
       `ASSERT(bit_width <= 52);
     end else begin
       csr.unit = DII;
       csr.mig_nunitid = ig_id - intrlvgrp_vector[picked_dmi_igs].size();
       `ASSERT(csr.mig_nunitid >= 0);
       csr.size = $clog2((
           memregion_boundaries[tmpv].end_addr -
           memregion_boundaries[tmpv].start_addr) >> 12);
       bit_width = csr.size+12; // For DII size of IG is always 1
         `ASSERT(bit_width <= 52);
     end
     `ASSERT(csr.size <= 40);
     
     csr.order = intrlvgrp2mem_order[ig_id][idx];
     csr.low_addr = memregion_boundaries[tmpv].start_addr >> 12;
     csr.upp_addr = memregion_boundaries[tmpv].start_addr >> 44;
      //#Stimulus.FSYS.dii_noncoh_txn  
     //#Stimulus.FSYS.GPRAR.NC_zero
     //#Stimulus.FSYS.GPRAR.NC_one
     csr.nc = intrlvgrp2noncoh[ig_id][idx]; 
     csr.nsx = intrlvgrp2security[ig_id][idx]; 
     csrq.push_back(csr);
  end

  return csrq;
endfunction: get_memregions_assoc_ig

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_all_gpra
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function sys_addrq get_all_gpra();
  sys_addr_csr_t csrq[$];

  for (int ig = 0; ig < get_total_intrlv_grps(); ++ig) begin
    sys_addr_csr_t tmpq[$];

    tmpq = get_memregions_assoc_ig(ig);
    //`uvm_info("addr mgr dbg", $psprintf("fn:get_all_gpra -- > ig:%0d tmpq.size:%0d", ig, tmpq.size()), UVM_LOW)
    foreach (tmpq[i])
      csrq.push_back(tmpq[i]);
  end

  return csrq;
endfunction: get_all_gpra

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_addr_memorder
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_addr_memorder(
    input bit [ADDR_WIDTH-1:0] addr);

  int intrlv_grp_idx;
  bit [ADDR_WIDTH-1 : 0] low_addr;
  bit [ADDR_WIDTH-1 : 0] upp_addr;       
  sys_addr_csr_t csrq[$];
  int ig_size;
   
  foreach(intrlvgrp2mem_map[intrlv_grp_idx]) begin
      csrq = ncoreConfigInfo::get_memregions_assoc_ig(intrlv_grp_idx);
      if(intrlv_grp_idx >= intrlvgrp_vector[picked_dmi_igs].size()) begin
    ig_size = 1;
      end else begin
     ig_size = intrlvgrp_vector[picked_dmi_igs][intrlv_grp_idx];
  end
      foreach (csrq[j]) begin
          low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
          upp_addr = low_addr + ig_size*(1<<(csrq[j].size+12)) - 1;
     
          //`uvm_info("ADDR MGR DBG", $sformatf("get_addr_memorder - checking addr 0x%0h in csrq[%0d] (size=%0d) of ig %0d: low_addr=0x%0h - upp_addr=0x%0h", addr, j, ig_size, intrlv_grp_idx, low_addr, upp_addr), UVM_NONE)
          if((addr >= low_addr)&&(addr <= upp_addr)) begin
              //`uvm_info("ADDR MGR DBG", $sformatf("get_addr_memorder - Found addr 0x%0h in csrq[%0d] of ig %0d: order=0x%0h", addr, j, intrlv_grp_idx, csrq[j].order), UVM_NONE)
          return csrq[j].order;
          end
      end
  end // foreach (intrlvgrp_vector[picked_dmi_igs][intrlv_grp_idx])
   
  // return 0 for boot region or CSR addresses
  //`uvm_info("ADDR MGR DBG", $sformatf("get_addr_memorder - addr 0x%0h not found in any csrq", addr), UVM_NONE)
  return 0;
   
endfunction: get_addr_memorder

static function bit memorder_policy_is3(bit [ADDR_WIDTH-1:0] addr);
       int mo = ncoreConfigInfo::get_addr_memorder(addr);
       return (mo[3:2] == 2'b11); // policy==3
endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_addr_gprar_nc
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_addr_gprar_nc(
    input bit [ADDR_WIDTH-1:0] addr);

  int intrlv_grp_idx;
  bit [ADDR_WIDTH-1 : 0] low_addr;
  bit [ADDR_WIDTH-1 : 0] upp_addr;       
  sys_addr_csr_t csrq[$];
  int ig_size;
  
  // if BOOT or CSR region
  if ((addr inside {[BOOT_REGION_BASE : (BOOT_REGION_BASE + BOOT_REGION_SIZE)]}) || (addr inside {[NRS_REGION_BASE : (NRS_REGION_BASE + NRS_REGION_SIZE)]})) begin
      return 1; // return nc
  end 
  foreach(intrlvgrp2mem_map[intrlv_grp_idx]) begin
      csrq = ncoreConfigInfo::get_memregions_assoc_ig(intrlv_grp_idx);
      if(intrlv_grp_idx >= intrlvgrp_vector[picked_dmi_igs].size()) begin
    ig_size = 1;
      end else begin
     ig_size = intrlvgrp_vector[picked_dmi_igs][intrlv_grp_idx];
  end
      foreach (csrq[j]) begin
          low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
          upp_addr = low_addr + ig_size*(1<<(csrq[j].size+12)) - 1;
     
          if((addr >= low_addr)&&(addr <= upp_addr)) begin
          return csrq[j].nc;
          end
      end
  end // foreach (intrlvgrp_vector[picked_dmi_igs][intrlv_grp_idx])
   
  // return 0 coherent by default
  return 0;
   
endfunction: get_addr_gprar_nc
    
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_addr_gprar_nsx
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_addr_gprar_nsx(
    input bit [ADDR_WIDTH-1:0] addr);

  int intrlv_grp_idx;
  bit [ADDR_WIDTH-1 : 0] low_addr;
  bit [ADDR_WIDTH-1 : 0] upp_addr;       
  sys_addr_csr_t csrq[$];
  int ig_size;
    
  foreach(intrlvgrp2mem_map[intrlv_grp_idx]) begin
      csrq = ncoreConfigInfo::get_memregions_assoc_ig(intrlv_grp_idx);
      if(intrlv_grp_idx >= intrlvgrp_vector[picked_dmi_igs].size()) begin
            ig_size = 1;
        end else begin
             ig_size = intrlvgrp_vector[picked_dmi_igs][intrlv_grp_idx];
          end
          foreach (csrq[j]) begin
            low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
              upp_addr = low_addr + ig_size*(1<<(csrq[j].size+12)) - 1;
     
              if((addr >= low_addr)&&(addr <= upp_addr)) begin
                  return csrq[j].nsx;
              end
          end
    end // foreach (intrlvgrp_vector[picked_dmi_igs][intrlv_grp_idx])
   
  // return 0 coherent by default
  return 0;
   
endfunction: get_addr_gprar_nsx

static function int get_addr_gprar_writeid(
    input bit [ADDR_WIDTH-1:0] addr);

  int intrlv_grp_idx;
  bit [ADDR_WIDTH-1 : 0] low_addr;
  bit [ADDR_WIDTH-1 : 0] upp_addr;       
  sys_addr_csr_t csrq[$];
  int ig_size;
    
  foreach(intrlvgrp2mem_map[intrlv_grp_idx]) begin
      csrq = ncoreConfigInfo::get_memregions_assoc_ig(intrlv_grp_idx);
      if(intrlv_grp_idx >= intrlvgrp_vector[picked_dmi_igs].size()) begin
            ig_size = 1;
        end else begin
             ig_size = intrlvgrp_vector[picked_dmi_igs][intrlv_grp_idx];
          end
          foreach (csrq[j]) begin
            low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
              upp_addr = low_addr + ig_size*(1<<(csrq[j].size+12)) - 1;
     
              if((addr >= low_addr)&&(addr <= upp_addr)) begin
	         if(csrq[j].order.writeid == 1'b0 && csrq[j].order.readid == 1'b0)
                   return 1;
		 else
		   return 0;
              end
          end
    end // foreach (intrlvgrp_vector[picked_dmi_igs][intrlv_grp_idx])
   
   
endfunction 

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : map_addr2dmi_or_dii
// Description : map addr to DMI or DII
//               FUnitId associated with DMI or DII
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int map_addr2dmi_or_dii(
    input bit [ADDR_WIDTH-1:0] addr,
    output int fnmem_region_idx);

  int intrlv_grp_idx;

  intrlv_grp_idx   = -1;
  fnmem_region_idx = -1;

  `uvm_info($sformatf("%m"), $sformatf("ADDR2DMI_DII: got addr=%p", addr), UVM_HIGH)

  // check CSR region first as it has highest priority
  if ( (addr >= NRS_REGION_BASE) &&
           (addr <  (NRS_REGION_BASE + NRS_REGION_SIZE)) ) begin
    // NRS region and should go to system Configuration DII
        `uvm_info($sformatf("%m"), $sformatf("NRS REGION DII FunitID=%0h", funit_ids[diiIds[get_sys_dii_idx()]]), UVM_HIGH)
        return funit_ids[diiIds[get_sys_dii_idx()]];
  end

  foreach (memregion_boundaries[idx]) begin
    if (addr >= memregion_boundaries[idx].start_addr &&
        addr <  memregion_boundaries[idx].end_addr) begin

      if (fnmem_region_idx == -1)
        fnmem_region_idx = idx;
      else if (!$test$plusargs("mem_regions_overlap"))
        `ASSERT(0, $psprintf("Address:0x%0h maps to multiple memory regions", addr));
    end
  end

    foreach (intrlvgrp2mem_map[idx,ridx]) begin
        // `uvm_info("addr mgr dbg", $psprintf("fn:map_addr2dmi_or_dii -- > idx:%0d ridx:%0d intrlvgrp2mem_map[idx][ridx]:%0d", idx, ridx, intrlvgrp2mem_map[idx][ridx]), UVM_LOW)
      if (fnmem_region_idx == intrlvgrp2mem_map[idx][ridx])
        intrlv_grp_idx = idx;
    end

    // `uvm_info("addr mgr dbg", $psprintf("fn:map_addr2dmi_or_dii -- > fnmem_region_idx :%0d intrlv_grp_idx: %0d", fnmem_region_idx, intrlv_grp_idx), UVM_LOW)
    `uvm_info($sformatf("%m"), $sformatf("map_addr2dmi_or_dii got interlv_grp_idx=%0d", intrlv_grp_idx), UVM_HIGH)

    if (intrlv_grp_idx == -1) begin
     // not found. Check boot region and NRS region
     // Check if the address maps into Boot region
     if ( (addr >= BOOT_REGION_BASE) && (addr <  (BOOT_REGION_BASE + BOOT_REGION_SIZE)) ) begin
        int funit_id;
        if (<%=obj.AiuInfo[0].BootInfo.regionHut%> == 0) begin
               return get_target_agentid(addr, DMI, <%=obj.AiuInfo[0].BootInfo.regionHui%>);
            end else begin // for DII
               funit_id = funit_ids[dii_ids[get_idx_from_nid(dii_nids, <%=obj.AiuInfo[0].BootInfo.regionHui%>)]];
               `uvm_info($sformatf("%m"), $sformatf("BOOT REGION DII FunitID=%0h (DII id offset=%0d)",
                            funit_id, get_idx_from_nid(dii_nids,<%=obj.AiuInfo[0].BootInfo.regionHui%>)), UVM_HIGH)
            end
            return funit_id;
    end

    `uvm_info($sformatf("%m"), $sformatf("ADDR=%p does not map int boot region [B=%0h S=%0h (DVJS=%0d] or NRS region [%0h-",
                         addr, BOOT_REGION_BASE, BOOT_REGION_SIZE, <%=obj.AiuInfo[0].BootInfo.regionSize%>, NRS_REGION_BASE), UVM_HIGH)
    if (!$test$plusargs("unmapped_add_access") && (!$test$plusargs("pick_boundary_addr")))
      `ASSERT(0, $psprintf("None of the targets are mapped to DMI or DII, Address:0x%0h", addr));
    end // if (intrlv_grp_idx == -1)
       
    if (intrlvgrp_if[intrlv_grp_idx] == DMI) begin
      return get_target_agentid(addr, DMI, intrlv_grp_idx);

    end else if (intrlvgrp_if[intrlv_grp_idx] == DII) begin
      int dii_fst_ig_idx;
      foreach (intrlvgrp_if[idx]) begin
        if (intrlvgrp_if[idx] == DII) begin
          dii_fst_ig_idx = idx;
          break;
        end
      end
      `ASSERT(dii_fst_ig_idx <= intrlv_grp_idx);
      return funit_ids[get_target_agentid(addr, DII, intrlv_grp_idx - dii_fst_ig_idx)];
    end

    return -1;
endfunction: map_addr2dmi_or_dii
    
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : is_dii_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int is_dii_addr(bit [ADDR_WIDTH - 1 : 0] addr);
    automatic int fnmem_region_idx, dest_id;

    dest_id = map_addr2dmi_or_dii(addr, fnmem_region_idx);
    if(get_unit_type(dest_id) == DII) is_dii_addr = 1;
    else is_dii_addr = 0;

    `uvm_info($sformatf("%m"), $sformatf("is_dii_addr got addr:0x%0x, unit_type:%s", addr, is_dii_addr? "DII": "DMI"), UVM_HIGH)
endfunction: is_dii_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : is_dmi_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int is_dmi_addr(bit [ADDR_WIDTH - 1 : 0] addr);
    automatic int fnmem_region_idx, dest_id;

    dest_id = map_addr2dmi_or_dii(addr, fnmem_region_idx);
    if(get_unit_type(dest_id) == DMI) is_dmi_addr = 1;
    else is_dmi_addr = 0;

    `uvm_info($sformatf("%m"), $sformatf("is_dmi_addr got addr:0x%0x, unit_type:%s", addr, is_dmi_addr? "DMI": "DII"), UVM_HIGH)
endfunction: is_dmi_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : is_dce_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int is_dce_addr(bit [ADDR_WIDTH - 1 : 0] addr);
      is_dce_addr =  get_addr_gprar_nc(addr) ? 0 : 1;
endfunction: is_dce_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : check_addr_crd_zero
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int check_addr_crd_zero(bit [ADDR_WIDTH - 1 : 0] addr, bit snpattr);
bit [6-1 : 0] intlv_addr_bits_concat;
bit [6-1 : 0] intlv_dmi_addr_bits_concat;
bit [6-1 : 0] intlv_dii_addr_bits_concat; 
    if(is_dmi_addr(addr) == 1) begin
            extract_intlv_bits_in_addr(ncoreConfigInfo::dce_intv_bits[0].pri_bits, addr, intlv_addr_bits_concat);
            extract_dmi_intlv_bits_in_addr(addr, intlv_dmi_addr_bits_concat);
        if(dmi_credit_zero != 0) begin
            if(snpattr == 1) begin
                if(snpattr == 1 && (dce_credit_zero[intlv_addr_bits_concat] == 1)) begin
                    return 1;
                end else begin
                    return 0;
                end 
            end else if (dmi_credit_zero[intlv_dmi_addr_bits_concat] == 1)begin
             return 1;
            end 
        end else if(dce_credit_zero != 0) begin
            if(snpattr == 1 && (dce_credit_zero[intlv_addr_bits_concat] == 1)) begin
                return 1;
            end else begin
                return 0;
            end 
        end else begin
             return 0;
        end 
    end else if(is_dii_addr(addr) == 1) begin
         extract_dii_intlv_bits_in_addr(addr, intlv_dii_addr_bits_concat);
         if(dii_credit_zero != 0 && (dii_credit_zero[intlv_dii_addr_bits_concat] == 1)) begin
             return 1;
         end else begin
             return 0;
         end 
    end else begin
       return 0;
    end
endfunction: check_addr_crd_zero

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_target_agentid
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_target_agentid(
  bit [ADDR_WIDTH - 1 : 0] addr,
  ncore_unit_type_t utype,
  int ig);

  string s;
  int nDmis_per_ig;
  dmisel_bits_t dmi_intrlvsel;
  bit [ADDR_WIDTH - 1 : 0] portid;
  int dmi_id;
  portid = 0;

  if (utype == DMI) begin
        nDmis_per_ig = intrlvgrp_vector[picked_dmi_igs][ig];
    dmi_intrlvsel = dmi_sel_bits[picked_dmi_if[nDmis_per_ig]][nDmis_per_ig]; 
    //`uvm_info("addr mgr dbg", $psprintf("fn:get_target_agentid -- >ig:%0d nDmis_per_ig:%0d", ig, intrlvgrp_vector[picked_dmi_igs][ig]), UVM_HIGH)
    case(nDmis_per_ig) 
        1: begin
                for(int i = 0; i < intrlvgrp_vector[picked_dmi_igs].size(); i++) begin
                    if (i != ig) begin
                        dmi_id += intrlvgrp_vector[picked_dmi_igs][i];
                    end else begin
                        break;
                    end 
                end
           end
        2: begin //DMI 2-way interleaving 
            
                //************************************************************************
                // code to extract dmi_id based on primary and secondary bits of address
                //************************************************************************
                dmi_id = 0;
                if (dmi_intrlvsel.pri_bits.size() > 0) begin
                    for(int i=0; i < intrlvgrp_vector[picked_dmi_igs].size(); i++) begin
                        if (i != ig) begin
                            dmi_id += intrlvgrp_vector[picked_dmi_igs][i];
                        end else begin
                            //if (dmi_intrlvsel.sec_bits.size() > 0) begin
                            //    dmi_id += addr[dmi_intrlvsel.pri_bits[0]] ^ addr[dmi_intrlvsel.sec_bits[0][0]];
                            //end else begin
                                dmi_id += addr[dmi_intrlvsel.pri_bits[0]];
                            //end
                            break;
                        end 
                    end
                end else begin
                    `uvm_error("NCORE_CONFIG_INFO", $psprintf("PrimaryBits not defined for 2-way interleaving: PriBits_size:%0d", dmi_intrlvsel.pri_bits.size()))
                end
                //************************************************************************

                //`uvm_info("NCORE CONFIG INFO DBG", $psprintf("dmi_id - %0d", dmi_id), UVM_LOW)

           end
            3: begin
                  //TODO: Do this later
            end
            4: begin//DMI 4 way interleaving
         //************************************************************************
                // code to extract dmi_id based on primary and secondary bits of address
                //************************************************************************
                dmi_id = 0;
                if (dmi_intrlvsel.pri_bits.size() > 0) begin
                    for(int i=0; i < intrlvgrp_vector[picked_dmi_igs].size(); i++) begin
                        if (i != ig) begin
                            dmi_id += intrlvgrp_vector[picked_dmi_igs][i];
                        end else begin
                            //if (dmi_intrlvsel.sec_bits.size() > 0) begin //need more work. 
                            //    dmi_id += addr[dmi_intrlvsel.pri_bits[0]] ^ addr[dmi_intrlvsel.sec_bits[0][0]];
                            //    dmi_id += (addr[dmi_intrlvsel.pri_bits[1]]*2) ^ addr[dmi_intrlvsel.sec_bits[0][0]];
                            //    dmi_id += (addr[dmi_intrlvsel.pri_bits[2]]*4) ^ addr[dmi_intrlvsel.sec_bits[0][0]];
                            //end else begin
                                dmi_id += addr[dmi_intrlvsel.pri_bits[1]];
                                dmi_id += (addr[dmi_intrlvsel.pri_bits[0]]*2);
                            //end
                            break;
                        end 
                    end
                end else begin
                    `uvm_error("NCORE_CONFIG_INFO", $psprintf("PrimaryBits not defined for 4-way interleaving: PriBits_size:%0d", dmi_intrlvsel.pri_bits.size()))
                end
        end 
            8: begin//DMI 8 way interleaving
            
                //************************************************************************
                // code to extract dmi_id based on primary and secondary bits of address
                //************************************************************************
                dmi_id = 0;
                if (dmi_intrlvsel.pri_bits.size() > 0) begin
                    for(int i=0; i < intrlvgrp_vector[picked_dmi_igs].size(); i++) begin
                        if (i != ig) begin
                            dmi_id += intrlvgrp_vector[picked_dmi_igs][i];
                        end else begin
                            //if (dmi_intrlvsel.sec_bits.size() > 0) begin //need more work. 
                            //    dmi_id += addr[dmi_intrlvsel.pri_bits[0]] ^ addr[dmi_intrlvsel.sec_bits[0][0]];
                               //    dmi_id += (addr[dmi_intrlvsel.pri_bits[1]]*2) ^ addr[dmi_intrlvsel.sec_bits[0][0]];
                            //    dmi_id += (addr[dmi_intrlvsel.pri_bits[2]]*4) ^ addr[dmi_intrlvsel.sec_bits[0][0]];
                            //end else begin
                                dmi_id += addr[dmi_intrlvsel.pri_bits[2]];
                                dmi_id += (addr[dmi_intrlvsel.pri_bits[1]]*2);
                                dmi_id += (addr[dmi_intrlvsel.pri_bits[0]]*4);
                            //end
                            break;
                        end 
                    end
                end else begin
                    `uvm_error("NCORE_CONFIG_INFO", $psprintf("PrimaryBits not defined for 8-way interleaving: PriBits_size:%0d", dmi_intrlvsel.pri_bits.size()))
                end
                //************************************************************************

                //`uvm_info("NCORE CONFIG INFO DBG", $psprintf("dmi_id - %0d", dmi_id), UVM_LOW)
        end
            16: begin//DMI 16 way interleaving
            
                //************************************************************************
                // code to extract dmi_id based on primary and secondary bits of address
                //************************************************************************
                dmi_id = 0;
                if (dmi_intrlvsel.pri_bits.size() > 0) begin
                    for(int i=0; i < intrlvgrp_vector[picked_dmi_igs].size(); i++) begin
                        if (i != ig) begin
                            dmi_id += intrlvgrp_vector[picked_dmi_igs][i];
                        end else begin
                            //if (dmi_intrlvsel.sec_bits.size() > 0) begin //need more work. 
                            //    dmi_id += addr[dmi_intrlvsel.pri_bits[0]] ^ addr[dmi_intrlvsel.sec_bits[0][0]];
                            //    dmi_id += (addr[dmi_intrlvsel.pri_bits[1]]*2) ^ addr[dmi_intrlvsel.sec_bits[0][0]];
                            //    dmi_id += (addr[dmi_intrlvsel.pri_bits[2]]*4) ^ addr[dmi_intrlvsel.sec_bits[0][0]];
                            //    dmi_id += (addr[dmi_intrlvsel.pri_bits[3]]*8) ^ addr[dmi_intrlvsel.sec_bits[0][0]];
                            //end else begin
                                dmi_id += addr[dmi_intrlvsel.pri_bits[3]];
                                dmi_id += (addr[dmi_intrlvsel.pri_bits[2]]*2);
                                dmi_id += (addr[dmi_intrlvsel.pri_bits[1]]*4);
                                dmi_id += (addr[dmi_intrlvsel.pri_bits[0]]*8);
                            //end
                            break;
                        end 
                    end
                end else begin
                    `uvm_error("NCORE_CONFIG_INFO", $psprintf("PrimaryBits not defined for 16-way interleaving: PriBits_size:%0d", dmi_intrlvsel.pri_bits.size()))
                end
                //************************************************************************

                //`uvm_info("NCORE CONFIG INFO DBG", $psprintf("dmi_id - %0d", dmi_id), UVM_LOW)
        end
    endcase 

   // `uvm_info("addr mgr dbg", $psprintf("fn:get_target_agentid -- >ig:%0d nDmis_per_ig:%0d dmi_id:0x%0h dmi_funitid:0x%0h", ig, intrlvgrp_vector[picked_dmi_igs][ig], dmi_id, get_dmi_funitid(dmi_id)), UVM_LOW)
    return(get_dmi_funitid(dmi_id));
    //        foreach (dmi_port_sel[ig].pri_bits[idx]) begin
    //          portid[idx] = addr[dmi_port_sel[ig].pri_bits[idx]];
    //          foreach (dmi_port_sel[ig].sec_bits[idx,cidx])
    //            portid[idx] = portid[idx] ^ addr[dmi_port_sel[ig].sec_bits[idx][cidx]];
    //        end
    //          `uvm_info("addr mgr dbg", $psprintf("fn:get_target_agentid -- > ig :%0d portid: %0d logical2dmi_map[ig][portid]: %0d", ig, portid, logical2dmi_map[ig][portid]), UVM_LOW)
    //        return logical2dmi_map[ig][portid];
  end else begin
    foreach (dii_port_sel[ig].pri_bits[idx]) begin
      portid[idx] = addr[dii_port_sel[ig].pri_bits[idx]];
      foreach (dii_port_sel[ig].sec_bits[idx,cidx])
        portid[idx] = portid[idx] ^ 
                          addr[dii_port_sel[ig].sec_bits[idx][cidx]];
    end
    //  foreach(dii_nids[i])
    //      if(dii_nids[i]==ig) //ig is using at NUnitds
    return logical2dii_map[ig][portid];
  end

  return -1;
endfunction: get_target_agentid
  
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : map_addr2dce
// Description : map address to DCE. Returns FUnitID associated with DCE
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int map_addr2dce(
    bit [ADDR_WIDTH-1:0] addr);

  int dceid = 0;
  `ASSERT(<%=dceIds.length%> > 0);
  if (<%=dceIds.length%> == 1 || (addr inside {[BOOT_REGION_BASE : (BOOT_REGION_BASE + BOOT_REGION_SIZE)]})) //or boot region 
    return get_dce_funitid(0);

  foreach (dce_port_sel[0].pri_bits[idx]) begin
    //$display("dce prim bit %d", dce_port_sel[0].pri_bits[idx]);
     dceid[idx] = addr[dce_port_sel[0].pri_bits[idx]];
    //foreach (dce_port_sel[0].sec_bits[idx,cidx]) no need to support for sec bit per Khaleel
    //  dceid = dceid[idx] ^ addr[dce_port_sel[0].sec_bits[idx][cidx]];
  end
  return get_dce_funitid(dceid);
endfunction: map_addr2dce

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : tagged_monitors_exist
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit tagged_monitors_exist();
    bit status;
    if(TAGGED_MON_PER_DCE > 0) 
        status = 1'b1;
    else
        status = 1'b0;
    return(status);
endfunction: tagged_monitors_exist

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_dvm_snp_agents
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function intq get_dvm_snp_agents();
    intq tmpq;

    foreach(dvm_snp_capb_agents[idx]) begin
        tmpq.push_back(dvm_snp_capb_agents[idx]);
    end
    return(tmpq);
endfunction: get_dvm_snp_agents

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_dvm_msg_agents
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function intq get_dvm_msg_agents();
    intq tmpq;

    foreach(dvm_msg_capb_agents[idx]) begin
        tmpq.push_back(dvm_msg_capb_agents[idx]);
    end
    return(tmpq);
endfunction: get_dvm_msg_agents

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_snp_credits4agent
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_snp_credits4agent(int agent_id);
    return(snp_credits_inflight[agent_id]);
endfunction: get_snp_credits4agent

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_mrd_credits4agent
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_mrd_credits4agent(int dmi_id);
    int agent_id = dmi_id - NUM_COH_VISB_AIUS - NUM_DCES;
    return(mrd_credits_inflight[agent_id]);
endfunction: get_mrd_credits4agent

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : dmi_has_cmc
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit dmi_has_cmc(int dmi_id);
    int indexq[$];

    indexq = dmi_ids.find_index(x) with (x == dmi_id);
    if(indexq.size() == 0) begin
        `uvm_fatal("ADDR MGR", $psprintf("Illegal, dmi_id:%0d is worng", dmi_id))
    end else if(indexq.size() > 1) begin
        `uvm_fatal("ADDR MGR", $psprintf("Multiple matches for dmi_id:%0d", dmi_id))
    end
    return(dmis_with_cmc[indexq[0]]);
endfunction: dmi_has_cmc

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_set_index
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit[ADDR_WIDTH-1:0] get_set_index(
    bit[ADDR_WIDTH-1:0] addr,
    int agent_id,//this is the FUnitId
    int sf_id = 0);

    int lid, cid;
    ncore_unit_type_t utype;
    bit [W_SEC_ADDR -1:0] val;
    sel_bits_t bit_idxs;

    get_logical_uinfo(agent_id, lid, cid, utype);
    
    if (utype == AIU) begin
      `ASSERT(cbi_set_sel[lid].num_entries != 0);
      bit_idxs.pri_bits = new[cbi_set_sel[lid].pri_bits.size()];
      bit_idxs.sec_bits = new[cbi_set_sel[lid].pri_bits.size()];

      foreach (cbi_set_sel[lid].pri_bits[i]) begin
        bit_idxs.pri_bits[i] = cbi_set_sel[lid].pri_bits[i];

        if (cbi_set_sel[lid].sec_bits[i].size() > 0) begin
          bit_idxs.sec_bits[i] = new[cbi_set_sel[lid].sec_bits[i].size()];
          foreach (cbi_set_sel[lid].sec_bits[i,j])
            bit_idxs.sec_bits[i][j] = cbi_set_sel[lid].sec_bits[i][j];
        end
      end
    end else if (utype == DMI) begin
      `ASSERT(cmc_set_sel[lid].num_entries != 0);
      bit_idxs.pri_bits = new[cmc_set_sel[lid].pri_bits.size()];
      bit_idxs.sec_bits = new[cmc_set_sel[lid].pri_bits.size()];
      foreach (cmc_set_sel[lid].pri_bits[i]) begin
        bit_idxs.pri_bits[i] = cmc_set_sel[lid].pri_bits[i];
        if (cmc_set_sel[lid].sec_bits[i].size() > 0) begin
          bit_idxs.sec_bits[i] = new[cmc_set_sel[lid].sec_bits[i].size()];
          foreach (cmc_set_sel[lid].sec_bits[i][j]) begin
            bit_idxs.sec_bits[i][j] = cmc_set_sel[lid].sec_bits[i][j];
          end
        end
      end          
    end else begin
      `ASSERT(0, "Not yet implemented");
    end

    //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_set_index - addr: 0x%0h, agent_id: %0d, utype: %s, lid: %0d", addr, agent_id, utype, lid), UVM_LOW)
    //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_set_index - pri_bits: %0p", bit_idxs.pri_bits), UVM_LOW)
    //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_set_index - sec_bits: %0p", bit_idxs.sec_bits), UVM_LOW)

    // align address to cacheline
    addr[WCACHE_OFFSET-1:0] = 'h0;
    foreach (bit_idxs.pri_bits[i]) begin
      val[i] = addr[bit_idxs.pri_bits[i]];
      foreach (bit_idxs.sec_bits[i][j]) begin
        if(bit_idxs.sec_bits[i][j]>0)begin
          val[i] = val[i] ^ addr[bit_idxs.sec_bits[i][j]];
        end
      end
    end
    
    //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_set_index - val: 0x%0h", val), UVM_LOW)

    //`uvm_info("ADDR MGR", $sformatf("get_set_index - addr: 0x%0h, agent_id: %0d, utype: %s, lid: %0d, val: 0x%0h", addr, agent_id, utype, lid, val), UVM_HIGH)

    return (val);
endfunction: get_set_index

//---------------------------------------------------------------------------------
//address and alignment helper functions
//---------------------------------------------------------------------------------

//aligned address (msbs)
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : aligned_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit [W_SEC_ADDR -1: 0] aligned_addr(bit [W_SEC_ADDR -1: 0] addr, int shift);
    bit [W_SEC_ADDR -1: 0] mask = '1;
    return (addr & (mask << shift));
endfunction : aligned_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : addr_offset
// Description : bytes by which address is size_bytes unaligned.  (lsbs)
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit [W_SEC_ADDR -1: 0] addr_offset(bit [W_SEC_ADDR -1: 0] addr, int shift);
    bit [W_SEC_ADDR -1: 0] mask = '1;
    return (addr & ~(mask << shift));
endfunction : addr_offset                               

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : cache_addr
// Description : address of the beginning of the cacheline which cmd is in
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit [W_SEC_ADDR -1: 0] cache_addr(bit [W_SEC_ADDR -1: 0] addr);
    return   aligned_addr(addr, WCACHE_OFFSET);
endfunction : cache_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : endpoint_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit [W_SEC_ADDR -1: 0] endpoint_addr(bit [W_SEC_ADDR -1: 0] addr, int unit_id);
    int dii_index[$] = diiIds.find_first_index with (item == unit_id);
    return aligned_addr(addr, wEndpoint[dii_index[0]]);
endfunction : endpoint_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : agentid_assoc2funitid
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int agentid_assoc2funitid(int funitid);
int p[$], q[$];

    p = funit_ids.find_index(x) with (x == funitid);

      <% if(obj.testBench != "io_aiu" ) { %>
      if (p.size() == 0)
        `uvm_error("NCORE_CONFIG_INFO", $psprintf("FunitId: %0d does not match with any value in config", funitid))
        <%}%>

    if (p.size() > 1)
        `uvm_error("NCORE_CONFIG_INFO", $psprintf("Multiple mathces for FunitId: %0d CONFIGURATION ERROR", funitid))

    q = aiu_ids.find_index(x) with (x == p[0]);
    if (q.size() > 1)
        `uvm_error("NCORE_CONFIG_INFO", $psprintf("fn:agentid_assoc2funitid CONFIGURATION ERROR", funitid))
    if (q.size() == 1)
        return q[0];

    q = dce_ids.find_index(x) with (x == p[0]);
    if (q.size() > 1)
        `uvm_error("NCORE_CONFIG_INFO", $psprintf("fn:agentid_assoc2funitid CONFIGURATION ERROR", funitid))
    if (q.size() == 1)
        return q[0];
    
    q = dmi_ids.find_index(x) with (x == p[0]);
    if (q.size() > 1)
        `uvm_error("NCORE_CONFIG_INFO", $psprintf("fn:agentid_assoc2funitid CONFIGURATION ERROR", funitid))
    if (q.size() == 1)
        return q[0];

    q = dii_ids.find_index(x) with (x == p[0]);
    if (q.size() > 1)
        `uvm_error("NCORE_CONFIG_INFO", $psprintf("fn:agentid_assoc2funitid CONFIGURATION ERROR", funitid))
    if (q.size() == 1)
        return q[0];

    q = dve_ids.find_index(x) with (x == p[0]);
    if (q.size() > 1)
        `uvm_error("NCORE_CONFIG_INFO", $psprintf("fn:agentid_assoc2funitid CONFIGURATION ERROR", funitid))
    if (q.size() == 1)
        return q[0];

<%if (obj.GiuInfo && obj.GiuInfo.length >0) {%>
    q = giu_ids.find_index(x) with (x == p[0]);
    if (q.size() > 1)
        `uvm_error("NCORE_CONFIG_INFO", $psprintf("fn:agentid_assoc2funitid CONFIGURATION ERROR", funitid))
    if (q.size() == 1)
        return q[0];
<%}%>

    `uvm_error("NCORE_CONFIG_INFO", $psprintf("fn:agentid_assoc2funitid Unexpected funit_id CONFIGURATION ERROR", funitid))
  
endfunction: agentid_assoc2funitid

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_aiu_funitid
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_aiu_funitid(int aiu_index);
  return funit_ids[aiu_index]; 
endfunction: get_aiu_funitid

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_dce_funitid
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_dce_funitid(int dce_index);
  return funit_ids[<%=aiuIds.length%> + dce_index];
endfunction: get_dce_funitid

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_dve_funitid
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_dve_funitid(int dve_index);
  int index = <%=aiuIds.length%> + <%=dceIds.length%> + <%=dmiIds.length%> + <%=diiIds.length%> + dve_index;
  return funit_ids[index];
endfunction: get_dve_funitid

<%if (obj.GiuInfo && obj.GiuInfo.length > 0) {%>
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_giu_funitid
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_giu_funitid(int giu_index);
  int index = <%=aiuIds.length%> + <%=dceIds.length%> + <%=dmiIds.length%> + <%=diiIds.length%> + <%=dveIds.length%> + giu_index;
  return funit_ids[index];
endfunction: get_giu_funitid
<%}%>

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_dmi_funitid
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_dmi_funitid(int dmi_index);
  int index = <%=aiuIds.length%> + <%=dceIds.length%> + dmi_index;
  return funit_ids[index];
endfunction: get_dmi_funitid

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_dii_funitid
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_dii_funitid(int dii_index);
  int index = <%=aiuIds.length%> + <%=dceIds.length%> + <%=dmiIds.length%> + dii_index;
  return funit_ids[index];
endfunction: get_dii_funitid

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : qos_mapping
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit [<%=obj.AiuInfo[0].concParams.hdrParams.wPriority%>-1:0] qos_mapping(int qos);
    <%/*if(obj.AiuInfo[0].fnEnableQos){*/%>
    <%if(obj.AiuInfo[0].QosInfo && (obj.AiuInfo[0].QosInfo.qosMap.length > 0)){%>
        int qos_array[<%=obj.AiuInfo[0].QosInfo.qosMap.length%>];
    <%obj.AiuInfo[0].QosInfo.qosMap.forEach(function(val, idx){ %>
    <%if(val != "16'h0000"){%>   
      qos_array[<%=idx%>] = <%=val%>;
    <%}%>
    <%});%>
          foreach(qos_array[i])
        if(qos_array[i][qos])
            return(i);
    <%}else{%>
    qos_mapping='0;
    <%}%>
endfunction//qos_mapping

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_highest_qos
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit [<%=obj.AiuInfo[0].concParams.cmdReqParams.wQos%>-1:0] get_highest_qos();
    <%if(obj.AiuInfo[0].QosInfo && (obj.AiuInfo[0].QosInfo.qosMap.length > 0)){%>
        <%obj.AiuInfo[0].QosInfo.qosMap.forEach(function(val, idx){ %>
              <%if (idx == 0){ %>
                  int highest_qos_val = <%=val%>;
                  int i = 2**<%=obj.AiuInfo[0].concParams.cmdReqParams.wQos%> - 1;
                while (i >= 0) begin
                    if (highest_qos_val[i] == 1) begin
                        return i;
                    end 
                    i--;
                end
                return 'h0;
            <%}%>
        <%});%>
    <%}else{%>
        return 'h0;
    <%}%>

endfunction: get_highest_qos

static int aiu_unconnected_units_table[0:ncoreConfigInfo::NUM_AIUS-1][$];
static int aiu2aiu_connected_table[0:ncoreConfigInfo::NUM_AIUS-1][$];

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : create_connectivity_unconnected_matrix
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function void create_connectivity_unconnected_matrix(output int unconnected_table[ncoreConfigInfo::NUM_AIUS][$]);

    static int unit_ig[$];
    static int unit_ig_bits[$];
    static int unit_idx_within_ig[$];
    static int other_ig_with_common_bits[ncoreConfigInfo::NUM_AIUS][ncoreConfigInfo::nb_aiu_ig_bits+1][$];
    static int common_bits_within_ig[ncoreConfigInfo::NUM_AIUS][ncoreConfigInfo::nb_aiu_ig_bits+1][$];
  
    for(int aiu_id=0 ; aiu_id<ncoreConfigInfo::NUM_AIUS ; aiu_id++) begin
      unit_ig = ncoreConfigInfo::aiu_ig_bits.find_index with (aiu_id inside {item.fUnitIds});
      unit_ig_bits = ncoreConfigInfo::aiu_ig_bits[unit_ig[0]].aPrimaryAiuPortBits;
      unit_idx_within_ig = ncoreConfigInfo::aiu_ig_bits[unit_ig[0]].fUnitIds.find_index with (item == aiu_id);
  
      if(! ncoreConfigInfo::aiu_ig_bits[unit_ig[0]].aPrimaryAiuPortBits.size()) begin
        continue;
      end
  
      // Add to unconnected table all other AIUs of the same group
      foreach(ncoreConfigInfo::aiu_ig_bits[unit_ig[0]].fUnitIds[id]) begin
        if(ncoreConfigInfo::aiu_ig_bits[unit_ig[0]].fUnitIds[id] != aiu_id)
          unconnected_table[aiu_id].push_back(ncoreConfigInfo::aiu_ig_bits[unit_ig[0]].fUnitIds[id]);
      end 
  
      // Identify identical bits with each other AIU Interleaving groups
      for (int i=0; i<ncoreConfigInfo::aiu_ig_bits.size();i++) begin
        if(i == unit_ig[0]) continue;
        if(! ncoreConfigInfo::aiu_ig_bits[i].aPrimaryAiuPortBits.size()) continue;
  
        foreach(ncoreConfigInfo::aiu_ig_bits[unit_ig[0]].aPrimaryAiuPortBits[j]) begin
          //AIU
          foreach(ncoreConfigInfo::aiu_ig_bits[i].aPrimaryAiuPortBits[k]) begin
            if(ncoreConfigInfo::aiu_ig_bits[unit_ig[0]].aPrimaryAiuPortBits[j] == ncoreConfigInfo::aiu_ig_bits[i].aPrimaryAiuPortBits[k]) begin
              other_ig_with_common_bits[aiu_id][i].push_back(k);
              common_bits_within_ig[aiu_id][i].push_back(j);
            end
          end 
  
        end 
      end 
  
      // Identify identical bits with DCE Interleaving group
      foreach(ncoreConfigInfo::aiu_ig_bits[unit_ig[0]].aPrimaryAiuPortBits[i]) begin
        foreach(ncoreConfigInfo::dce_intv_bits[0].pri_bits[j]) begin
          if(ncoreConfigInfo::aiu_ig_bits[unit_ig[0]].aPrimaryAiuPortBits[i] == ncoreConfigInfo::dce_intv_bits[0].pri_bits[j]) begin
            other_ig_with_common_bits[aiu_id][ncoreConfigInfo::nb_aiu_ig_bits].push_back(j);
            common_bits_within_ig[aiu_id][ncoreConfigInfo::nb_aiu_ig_bits].push_back(i);
          end
        end 
      end 
  
      // Add to unconnected table AIUs of other Interleaving group with common intlv bits
      foreach(other_ig_with_common_bits[aiu_id][i]) begin
        int nb_possible_values ;
        if(i < ncoreConfigInfo::nb_aiu_ig_bits) begin
          nb_possible_values = 2**ncoreConfigInfo::aiu_ig_bits[i].aPrimaryAiuPortBits.size();
        end else begin
          nb_possible_values = 2**ncoreConfigInfo::dce_intv_bits[0].pri_bits.size();
        end
        if( ! other_ig_with_common_bits[aiu_id][i].size()) continue;
   
        for(int possible_id=0 ; possible_id < nb_possible_values ; possible_id++) begin
          bit match = 1;
          for(int j=0 ; j < other_ig_with_common_bits[aiu_id][i].size() ; j++) begin
            //all bits in common need to have the same value in the position indexes of the AIU within each interleaving group to be connected
            if(possible_id[other_ig_with_common_bits[aiu_id][i][j]] != unit_idx_within_ig[0][common_bits_within_ig[aiu_id][i][j]]) begin
              match = 0;
              break;
            end
          end
          if(!match) begin
            if(i < ncoreConfigInfo::nb_aiu_ig_bits) begin
              unconnected_table[aiu_id].push_back(ncoreConfigInfo::aiu_ig_bits[i].fUnitIds[possible_id]);
            end else begin
              unconnected_table[aiu_id].push_back(ncoreConfigInfo::dce_ids[possible_id]);
            end
          end
        end
  
      end 
  
    end
  
    `uvm_info("Connectivity Interleaving feature", $sformatf("Below Connectivity unconnected fUnitIDs by AIU matrix"),UVM_NONE)
    foreach(unconnected_table[e]) begin 
      `uvm_info("Connectivity Interleaving feature", $sformatf("Connectivity table [%0d] = %0p ", e, unconnected_table[e]),UVM_NONE)
    end

    //#Stimulus.IOAIU.v3.4.Connectivity.AiutoAiuOptimization
    `uvm_info("Connectivity Interleaving feature", $sformatf("Below AIUtoAIU Connected fUnitIDs matrix"),UVM_NONE)
    foreach(aiu2aiu_connected_table[e]) begin
        foreach(ncoreConfigInfo::aiu_ids[id]) begin
            if( ! (ncoreConfigInfo::aiu_ids[id] inside {unconnected_table[e]})  && ncoreConfigInfo::aiu_ids[id] != e) begin
                aiu2aiu_connected_table[e].push_back(ncoreConfigInfo::aiu_ids[id]);
            end
        end
      `uvm_info("Connectivity Interleaving feature", $sformatf("AIUtoAIU Connectivity table [%0d] = %0p ", e, aiu2aiu_connected_table[e]),UVM_NONE)
    end
    aiu_unconnected_units_table = unconnected_table; 
  
  endfunction : create_connectivity_unconnected_matrix
  
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : check_unmapped_add
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit check_unmapped_add( bit [ADDR_WIDTH - 1 : 0] addr, int agent_id, output bit [2:0] unit_unconnected,
                                  input bit test_connectivity_test = 1'b0,
                                        bit try_to_gen_addr = 1'b1
                                        <% if(obj.testBench == "chi_aiu" || obj.testBench == "io_aiu" ) { %>,
                                        bit [<%=obj.nDCEs%>-1:0] AiuDce_connectivity_vec =  {<<{<%=obj.nDCEs%>'h<%=obj.AiuInfo[obj.Id].hexAiuDceVec%>}}, //'
                                        bit [<%=obj.nDMIs%>-1:0] AiuDmi_connectivity_vec =  {<<{<%=obj.nDMIs%>'h<%=obj.AiuInfo[obj.Id].hexAiuDmiVec%>}}, //'
                                        bit [<%=obj.nDIIs%>-1:0] AiuDii_connectivity_vec =  {<<{<%=obj.nDIIs%>'h<%=obj.AiuInfo[obj.Id].hexAiuDiiVec%>}} //'
                                        <%}%>
                                        ); 

    int fnmem_region_idx = 0;
    int FUnitId = 0;
    bit addr2dmi_or_dii_n = 0;
    bit dmi_unconnected = 0;
    bit dii_unconnected = 0;
    bit dce_unconnected = 0;
    bit boot_region_hit = 0;
    bit no_address_hit  = 0;
    bit multiple_address_hit  = 0;
    bit unit_id_is_not_aiu = 0;
    bit unit_id_is_dce = 0;
    bit unit_id_is_dmi = 0;
    bit unit_id_is_dii = 0;

    bit [<%=obj.nDMIs%>-1:0] DceDmi_connectivity_vec;

    <% if(obj.testBench != "chi_aiu" && obj.testBench != "io_aiu" ) { %>
    bit [<%=obj.nDCEs%>-1:0] AiuDce_connectivity_vec; 
    bit [<%=obj.nDMIs%>-1:0] AiuDmi_connectivity_vec; 
    bit [<%=obj.nDIIs%>-1:0] AiuDii_connectivity_vec; 

    case(agent_id) 
    <%for(let pidx = 0; pidx < obj.AiuInfo.length; pidx++) {%> 
        <%=pidx%> : begin
            AiuDce_connectivity_vec = {<<{<%=obj.nDCEs%>'h<%=obj.AiuInfo[pidx].hexAiuDceVec%>}};//'
            AiuDmi_connectivity_vec = {<<{<%=obj.nDMIs%>'h<%=obj.AiuInfo[pidx].hexAiuDmiVec%>}};//'
            AiuDii_connectivity_vec = {<<{<%=obj.nDIIs%>'h<%=obj.AiuInfo[pidx].hexAiuDiiVec%>}};//'
        end
    <%}%> 
        default : begin
            AiuDce_connectivity_vec = 0;
            AiuDmi_connectivity_vec = 0;
            AiuDii_connectivity_vec = 0;
            unit_id_is_not_aiu = 1;
            if(agent_id inside {ncoreConfigInfo::dce_ids}) begin 
               unit_id_is_dce     = 1;
               case(agent_id)
               <%for(let pidx = 0; pidx < obj.DceInfo.length; pidx++) {%> 
               ncoreConfigInfo::dce_ids[<%=pidx%>] : begin
                  DceDmi_connectivity_vec = {<<{<%=obj.nDMIs%>'h<%=obj.DceInfo[pidx].hexDceDmiVec%>}};//'
               end
               <%}%> 
               endcase
            end
            if(agent_id inside {ncoreConfigInfo::dmi_ids}) unit_id_is_dmi     = 1;
            if(agent_id inside {ncoreConfigInfo::dii_ids}) unit_id_is_dii     = 1;

        end
    endcase
    <% }%>

    unit_unconnected = 0;

    check_unmapped_add = 1'b1;
    //Check all memory regions
    foreach(memregion_boundaries[idx]) begin
      if ((addr inside {[memregion_boundaries[idx].start_addr[ADDR_WIDTH - 1 : 0] : memregion_boundaries[idx].end_addr[ADDR_WIDTH - 1 : 0]-1]})) begin
        check_unmapped_add = 1'b0;
        break;
      end
    end
    
    //Check BOOT memory region
    if (check_is_boot_region_addr(addr)) begin
        check_unmapped_add = 1'b0;
        boot_region_hit = 1;
    end

    if(check_unmapped_add) begin
        no_address_hit = 1;
        `uvm_info("Connectivity Interleaving feature", $sformatf("AIU%0d : Addr %h is not mapped to any memory region", agent_id, addr),UVM_LOW+1)
    end
    
    multiple_address_hit = check_multimapped_add(addr);

    if(!boot_region_hit && !check_unmapped_add && !multiple_address_hit) begin

        `uvm_info("Connectivity Interleaving feature", $sformatf("AIU%0d : Addr %0h, Before connectivity check %b", agent_id, addr, check_unmapped_add),UVM_LOW+1)

        FUnitId = ncoreConfigInfo::map_addr2dmi_or_dii(addr,fnmem_region_idx);
        `uvm_info("Connectivity Interleaving feature", $sformatf("Addr %0h is mapped to FunitID %0d",addr, FUnitId),UVM_LOW+2)

        if(FUnitId == -1) begin
            `uvm_error("Connectivity Interleaving feature", $sformatf("Addr %h is not mapped to any memory region but this error should not pop up as unmapped addr already checked just before", addr))

        end else if(unit_id_is_not_aiu && (unit_id_is_dmi || unit_id_is_dii)) begin
            if(FUnitId != agent_id) 
                check_unmapped_add = 1;
            else begin
                check_unmapped_add = 0;
            end

        end else begin
            if (unit_id_is_dce) begin
               if( FUnitId inside {ncoreConfigInfo::dmi_ids}) begin
                   foreach (ncoreConfigInfo::dmi_ids[i]) begin
                        if (ncoreConfigInfo::dmi_ids[i] == FUnitId)
                          check_unmapped_add = ~DceDmi_connectivity_vec[i];
                     end
               end
            end else begin
               check_unmapped_add = check_dmi_dii_is_unconnected(FUnitId, agent_id, addr2dmi_or_dii_n,AiuDmi_connectivity_vec,AiuDii_connectivity_vec);
               if(check_unmapped_add && addr2dmi_or_dii_n) 
                   dmi_unconnected = 1;
               else if(check_unmapped_add && !addr2dmi_or_dii_n) 
                   dii_unconnected = 1;
            end
            `uvm_info("Connectivity Interleaving feature", $sformatf("AIU%0d : Addr %0h, After check_dmi_dii_is_unconnected check %b", agent_id, addr, check_unmapped_add),UVM_LOW+1)
        end
        
        if(!check_unmapped_add && addr2dmi_or_dii_n && !unit_id_is_not_aiu) begin
            check_unmapped_add = check_dce_is_unconnected(addr, agent_id, AiuDce_connectivity_vec, aiu_unconnected_units_table,test_connectivity_test);
            if(check_unmapped_add)
                dce_unconnected = 1;
            `uvm_info("Connectivity Interleaving feature", $sformatf("AIU%0d : Addr %0h, After check_dce_is_unconnected check %b", agent_id, addr, check_unmapped_add),UVM_LOW+1)
        end

        if(check_unmapped_add && !test_connectivity_test && !try_to_gen_addr) begin
            $stacktrace;
            `uvm_error("Connectivity Interleaving feature", $sformatf("AIU%0d : Address %0h seen is expected to be connected to all targeted units when test is not connectivity_test (error cases)", agent_id, addr))
        end
    end

    // Static table from DV JSON param that indicates if connectivity are existing between :
    // AIU <-> DMI/DII/DCE  && DCE <-> AIU/DMI
    //aiu_dce_connected_dce_dmi_dii_ids[] 
 

    //In Error Specification : If multiple of these errors are reported for the same transaction, then reporting order of priority is from top to bottom as below
    //#Check.IOAIU.v3.4.Connectivity.ErrorPriority
    if(no_address_hit)
        unit_unconnected = 'b000;
    else if(multiple_address_hit)
        unit_unconnected = 'b001;
    else if ($test$plusargs("unsupported_atomic_txn_to_dii") || $test$plusargs("illegal_dii_access_check")) begin
        unit_unconnected = 'b011;
<% if(obj.testBench != "chi_aiu") { %>
        check_unmapped_add = 1;
<%} else {%>
        if (!addr2dmi_or_dii_n) check_unmapped_add = 1;
<%}%>
    end else if(dmi_unconnected)
        unit_unconnected = 'b010;
    else if(dii_unconnected)
        unit_unconnected = 'b011;
    else if(dce_unconnected)
        unit_unconnected = 'b101;
    else 
        unit_unconnected = 'b111;

endfunction: check_unmapped_add

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : check_is_boot_region_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit check_is_boot_region_addr(bit [W_SEC_ADDR - 1 : 0] addr); 
    check_is_boot_region_addr = 1'b0;
    if ((addr inside {[BOOT_REGION_BASE : (BOOT_REGION_BASE + BOOT_REGION_SIZE)]}) || (addr inside {[NRS_REGION_BASE : (NRS_REGION_BASE + NRS_REGION_SIZE)]})) begin
        check_is_boot_region_addr = 1'b1;
    end
endfunction: check_is_boot_region_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : check_dmi_dii_is_unconnected
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit check_dmi_dii_is_unconnected( int FUnitId, int agent_id, output bit dmi_or_dii_n,
                                          input bit [<%=obj.nDMIs%>-1:0] AiuDmi_connectivity_vec,
                                                bit [<%=obj.nDIIs%>-1:0] AiuDii_connectivity_vec);
  string unit_type = "";
  dmi_or_dii_n = 1;

  if( FUnitId inside {ncoreConfigInfo::dmi_ids}) begin
    unit_type = "DMI";
    foreach (ncoreConfigInfo::dmi_ids[i]) begin
      if (ncoreConfigInfo::dmi_ids[i] == FUnitId) begin
        `uvm_info("Connectivity Interleaving feature", $sformatf("Find DMI FUnitId=%0d AIU%0d_DMI bit %0d value %0b, Full tieoff vec=%0b", FUnitId, agent_id, i, AiuDmi_connectivity_vec[i],AiuDmi_connectivity_vec),UVM_LOW+2)
        return ~AiuDmi_connectivity_vec[i];
      end
    end

  end else if( FUnitId inside {ncoreConfigInfo::dii_ids}) begin
    unit_type = "DII";
    foreach (ncoreConfigInfo::dii_ids[i]) begin
      if (ncoreConfigInfo::dii_ids[i] == FUnitId) begin
        dmi_or_dii_n = 0;
        `uvm_info("Connectivity Interleaving feature", $sformatf("Find DII FUnitId=%0d AIU%0d_DII bit %0d value %0b, Full tieoff vec=%0b", FUnitId, agent_id, i, AiuDii_connectivity_vec[i],AiuDii_connectivity_vec),UVM_LOW+2)
        return ~AiuDii_connectivity_vec[i];
      end
    end
  end

  `uvm_info("Connectivity Interleaving feature", $sformatf("FunitID %0d is %0s", FUnitId, unit_type),UVM_LOW+2)
  return 0;
  
endfunction : check_dmi_dii_is_unconnected

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : check_dmi_is_unconnected
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit check_dmi_is_unconnected(bit [W_SEC_ADDR - 1 : 0] addr); //This function is for DCE

        int fnmem_region_idx = 0;
        int FUnitId = 0;
        bit [<%=obj.nDMIs%>-1:0] DceDmi_connectivity_vec = 'h<%=obj.DceInfo[0].hexDceDmiVec%>;

    DceDmi_connectivity_vec = {<<{DceDmi_connectivity_vec}};
        FUnitId = ncoreConfigInfo::map_addr2dmi_or_dii(addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0],fnmem_region_idx);

    if( FUnitId inside {ncoreConfigInfo::dmi_ids}) begin
              foreach (ncoreConfigInfo::dmi_ids[i]) begin
                if (ncoreConfigInfo::dmi_ids[i] == FUnitId)
                      return ~DceDmi_connectivity_vec[i];
            end
          end

endfunction: check_dmi_is_unconnected
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : check_dce_is_unconnected
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit check_dce_is_unconnected( bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr, int agent_id,
                                      input bit [<%=obj.nDCEs%>-1:0] AiuDce_connectivity_vec,
                                            int aiu_unconnected_units_table[0:ncoreConfigInfo::NUM_AIUS-1][$],
                                            bit test_connectivity_test);
  bit [6-1 : 0] intlv_addr_bits_concat; // Up to 64 Way Interleaving => 2^6

  bit dce_is_unconnected_from_vec;
  bit dce_is_unconnected_from_intlv_bits;

  int aiu_unit_ig[$], aiu_unit_ig_bits[$];

  aiu_unit_ig.delete();
  aiu_unit_ig = ncoreConfigInfo::aiu_ig_bits.find_index with (agent_id inside {item.fUnitIds});
  aiu_unit_ig_bits = ncoreConfigInfo::aiu_ig_bits[aiu_unit_ig[0]].aPrimaryAiuPortBits;

  ////////////////////////////////////////////////////
  // First check if DCE is connected using HexAIUDCEvec
  ////////////////////////////////////////////////////
  extract_intlv_bits_in_addr(ncoreConfigInfo::dce_intv_bits[0].pri_bits, addr, intlv_addr_bits_concat);
  dce_is_unconnected_from_vec = ~AiuDce_connectivity_vec[intlv_addr_bits_concat];
  `uvm_info("Connectivity Interleaving feature", $sformatf("AIU%0d, DCE%0d is_unconnected_from_vec = %0d (DceVec = %0b), interleave addr bits %p  @=%0x ('b%0b) ", agent_id,intlv_addr_bits_concat,dce_is_unconnected_from_vec,AiuDce_connectivity_vec,ncoreConfigInfo::dce_intv_bits[0].pri_bits,addr,addr),UVM_LOW+2)

  ////////////////////////////////////////////////////
  // Second check if DCE is connected using from AIU/DCE Address interleaving bits
  ////////////////////////////////////////////////////
  `uvm_info("Connectivity Interleaving feature", $sformatf("DCE primary interleave addr bits %p and CAIU%0d primary interleave addr bits %p ", 
  ncoreConfigInfo::dce_intv_bits[0].pri_bits, agent_id, aiu_unit_ig_bits),UVM_LOW+3)

  if(ncoreConfigInfo::dce_ids[intlv_addr_bits_concat] inside {aiu_unconnected_units_table[agent_id]}) begin
    dce_is_unconnected_from_intlv_bits = 1;
     foreach(aiu_unconnected_units_table[e]) begin 
    `uvm_info("Connectivity Interleaving feature", $sformatf("Connectivity table [%0d] = %0p ", e, aiu_unconnected_units_table[e]),UVM_LOW+2)
      end

  end
`uvm_info("Connectivity Interleaving feature", $sformatf("AIU%0d, DCE%0d is unconnected_from_intlv_bits = %0d  from AIU%0d by  interleave addr bits %p  @=%0x ('b%0b) ", agent_id,  intlv_addr_bits_concat,dce_is_unconnected_from_intlv_bits,agent_id,ncoreConfigInfo::dce_intv_bits[0].pri_bits,addr,addr),UVM_LOW+2) 
   `uvm_info("Connectivity Interleaving feature", $sformatf("AIU%0d Addr=0x%0h, DCE_ids = %p  dce_ids[intlv_addr_bits_concat] = %0d ", agent_id, addr, ncoreConfigInfo::dce_ids, ncoreConfigInfo::dce_ids[intlv_addr_bits_concat]),UVM_LOW+2) 
   `uvm_info("Connectivity Interleaving feature", $sformatf("AIU%0d Addr=0x%0h, aiu_unconnected_units_table[AIU%0d] = %p", agent_id, addr, agent_id , aiu_unconnected_units_table[agent_id]),UVM_LOW+2) 
  //////////////////////////////////////////////////////

  if(!test_connectivity_test || $test$plusargs("connectivity_dce_cross_check")) begin
    `uvm_info("Connectivity Interleaving feature", $sformatf("AIU%0d Addr=0x%0h, check_dce_is_unconnected dce_cross_check from_vec = %0d , from_intlv_bits = %0d", agent_id, addr, dce_is_unconnected_from_vec, dce_is_unconnected_from_intlv_bits),UVM_LOW+2)
    return dce_is_unconnected_from_vec || dce_is_unconnected_from_intlv_bits; 

  end else begin
    `uvm_info("Connectivity Interleaving feature", $sformatf("AIU%0d Addr=0x%0h, check_dce_is_unconnected = %0d", agent_id, addr, dce_is_unconnected_from_vec),UVM_LOW+2)
    return dce_is_unconnected_from_vec; 
  end

endfunction : check_dce_is_unconnected
  
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : extract_intlv_bits_in_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
 static function void extract_intlv_bits_in_addr(int intlv_bits_q[$], bit [ncoreConfigInfo::W_SEC_ADDR - 1  :0] addr, output bit  [6-1 : 0] intlv_addr_bits_concat);

  intlv_addr_bits_concat = 0;
  for( int i=0; i < intlv_bits_q.size() ;i++) begin 
    intlv_addr_bits_concat[i] = addr[intlv_bits_q[i]]; //Concat each inlv bit position
  end
  `uvm_info("Connectivity Interleaving feature", $sformatf("Address bits extraction {%0p} from @ %0h = 'b%b ('d%0d)", intlv_bits_q, addr, intlv_addr_bits_concat, intlv_addr_bits_concat),UVM_LOW+3)

endfunction : extract_intlv_bits_in_addr
  
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : extract_dmi_intlv_bits_in_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
 static function void extract_dmi_intlv_bits_in_addr(bit [ncoreConfigInfo::W_SEC_ADDR - 1  :0] addr, output bit  [6-1 : 0] intlv_dmi_addr_bits_concat);

      automatic int fnmem_region_idx, dest_id;
      intlv_dmi_addr_bits_concat = 0;

      dest_id = map_addr2dmi_or_dii(addr, fnmem_region_idx);

       foreach (ncoreConfigInfo::dmi_ids[i]) begin
         if (dmi_ids[i] == dest_id) begin
               intlv_dmi_addr_bits_concat = i;
         end
      end
  `uvm_info("credit management feature", $sformatf("DMI Address bits extraction {%0p} from @ %0h = 'b%b ('d%0d)", dmi_ids, addr, intlv_dmi_addr_bits_concat, intlv_dmi_addr_bits_concat),UVM_LOW+3)

endfunction : extract_dmi_intlv_bits_in_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : extract_dii_intlv_bits_in_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
 static function void extract_dii_intlv_bits_in_addr(bit [ncoreConfigInfo::W_SEC_ADDR - 1  :0] addr, output bit  [6-1 : 0] intlv_dii_addr_bits_concat);

      automatic int fnmem_region_idx, dest_id;
      intlv_dii_addr_bits_concat = 0;

      dest_id = map_addr2dmi_or_dii(addr, fnmem_region_idx);

       foreach (ncoreConfigInfo::dii_ids[i]) begin
         if (dii_ids[i] == dest_id) begin
               intlv_dii_addr_bits_concat = i;
         end
      end
  `uvm_info("credit management feature", $sformatf("DII Address bits extraction {%0p} from @ %0h = 'b%b ('d%0d)", dii_ids, addr, intlv_dii_addr_bits_concat, intlv_dii_addr_bits_concat),UVM_LOW+3)

endfunction : extract_dii_intlv_bits_in_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : check_multimapped_add
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit check_multimapped_add(bit [W_SEC_ADDR - 1 : 0] addr);

    int fnmem_region_idx = -1;

    check_multimapped_add = 1'b0;

    foreach (memregion_boundaries[idx]) begin
        if (addr >= memregion_boundaries[idx].start_addr && addr <  memregion_boundaries[idx].end_addr) begin
            if (fnmem_region_idx == -1) begin
                fnmem_region_idx = idx;
            end else begin
                check_multimapped_add = 1'b1;
            end
        end
    end

endfunction: check_multimapped_add

   //This function are used for dmi performance test to warmup the cache 

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_dmi_index_bits
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit [ncoreConfigInfo::ADDR_WIDTH-1:0] set_dmi_index_bits(
    bit [ADDR_WIDTH-1:0] m_addr,
    bit [19:0] desired_index=0,                 //Fixed since the CSR is 20 Bits
    int agent_id);
    
    bit [ADDR_WIDTH-1:0] desired_addr;
    int matchq1[$];
    int local_id, col_idx;
    string s;

    matchq1 = dmi_ids.find(x) with(x == agent_id);
    if(!(matchq1.size() > 0)) begin
        $sformat(s, "%s TbError, Passed agentid:%0d is netither CBI nor DMI", s, agent_id);
        `uvm_fatal("ADDR MGR", s)
    end
    if(matchq1.size()) begin
       // if(get_native_interface(agent_id) != IO_CACHE) begin
       //     $sformat(s, "%s TbError, Method get_cache_set_select_index() must be be called", s);
       //     $sformat(s, "%s only for agents with proxy_cache BridgeAiu:%0d does not has proxy cache",
       //              s, agent_id);
       //     `uvm_fatal("ADDR MGR", s); 
       // end
       //  get_logical_id(agent_id, local_id, col_idx);
      //  local_id = local_id - get_first_bridgeaiu_logical_id();
        local_id = 0;
        desired_addr = m_addr;
        foreach(cmc_set_sel[local_id].sec_bits[i,j]) begin
            desired_addr[cmc_set_sel[local_id].sec_bits[i][j]] = 0;
        end
        
        foreach(cmc_set_sel[local_id].pri_bits[i]) begin
            desired_addr[cmc_set_sel[local_id].pri_bits[i]] = desired_index[i];
        end

    end
      
    //`uvm_info("ADDR-MGR", $psprintf("Addr:%0h, Index:%0d",desired_addr,desired_index),UVM_MEDIUM);
    return desired_addr;
endfunction: set_dmi_index_bits

    //Don't touch the Secondary and Primary bits and then set the appropirate tag
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_dmi_tag_bits
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static  function bit [ncoreConfigInfo::ADDR_WIDTH-1:0] set_dmi_tag_bits(
    bit [ADDR_WIDTH-1:0] m_addr,
    bit [31:0] desired_tag=0,                 
    int agent_id);
    
    bit [ADDR_WIDTH-1:0] desired_addr;
    int matchq1[$],flatq[$],findq[$];
    int local_id, col_idx;
    string s;
    bit [31:0] cnt; 

    matchq1 = dmi_ids.find(x) with(x == agent_id);
    if(!(matchq1.size() > 0)) begin
        $sformat(s, "%s TbError, Passed agentid:%0d is netither CBI nor DMI", s, agent_id);
        `uvm_fatal("ADDR MGR", s)
    end
    if(matchq1.size()) begin
       // if(get_native_interface(agent_id) != IO_CACHE) begin
       //   $sformat(s, "%s TbError, Method get_cache_set_select_index() must be be called", s);
       //   $sformat(s, "%s only for agents with proxy_cache BridgeAiu:%0d does not has proxy cache",
       //            s, agent_id);
       //   `uvm_fatal("ADDR MGR", s); 
       // end
       // get_logical_id(agent_id, local_id, col_idx);
       // local_id = local_id - get_first_bridgeaiu_logical_id();
        local_id = 0;

        foreach(cmc_set_sel[local_id].sec_bits[i,j]) begin
            flatq.push_back(cmc_set_sel[local_id].sec_bits[i][j]);
        end

        foreach(cmc_set_sel[local_id].pri_bits[i]) begin
            flatq.push_back(cmc_set_sel[local_id].pri_bits[i]);
        end
        
        cnt=0;
        for(int i = <%=obj.wCacheLineOffset%>; i<$size(desired_addr);i++) begin
            findq = flatq.find_index() with(item==i);
            if(findq.size()==0) begin 
                m_addr[i] = desired_tag[cnt];
                cnt++;
            end
        end
    end
    
    desired_addr = m_addr;
   // `uvm_info("ADDR-MGR", $psprintf("Addr:%0h, Tag:%0d",desired_addr,desired_tag),UVM_HIGH);
    return desired_addr;
endfunction: set_dmi_tag_bits

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : update_addr_for_core
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] update_addr_for_core(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,int agentid, int core_id=0);
    int primary_bits[$] = ncoreConfigInfo::mp_aiu_intv_bits[agentid].pri_bits;
    if (primary_bits.size()) primary_bits.sort();
    update_addr_for_core = addr;
    foreach (primary_bits[j]) begin
      update_addr_for_core[primary_bits[j]]=core_id[j];
    end
endfunction: update_addr_for_core

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_addr_core_id
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function int get_addr_core_id(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr, int agentid);
    int primary_bits[$] = ncoreConfigInfo::mp_aiu_intv_bits[agentid].pri_bits;
    int core_id = 0;
    if (primary_bits.size()) primary_bits.sort();
    foreach (primary_bits[j]) begin
      core_id[j] = addr[primary_bits[j]];
    end
    return core_id;
endfunction: get_addr_core_id

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : check_addr_for_core
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit check_addr_for_core(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,int agentid, int core_id=0);
    int primary_bits[$] = ncoreConfigInfo::mp_aiu_intv_bits[agentid].pri_bits;
   if (primary_bits.size()) primary_bits.sort();
    check_addr_for_core = 1;
    foreach (primary_bits[j]) begin
      if (addr[primary_bits[j]] != core_id[j]) return 0;
    end
endfunction: check_addr_for_core
    
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_dmi_spad_intrlv_info
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function set_dmi_spad_intrlv_info(int set, way, func, unitID);
  //Programmed values for Interleave group set, way and function |  MIGR and MIFSR register suffix
  DMI_MIG_set[unitID] = set;
  DMI_MIF_way[unitID] = way;
  DMI_MIF_function[unitID] = func;

  if($test$plusargs("print_spad_debug"))begin
    `uvm_info("NCORE_SPAD_DEBUG",$sformatf("Setting UnitId:%0d with Set:%0d Way:%0d Function:%0d", unitID, DMI_MIG_set[unitID], DMI_MIF_way[unitID], DMI_MIF_function[unitID]),UVM_MEDIUM);
  end
endfunction: set_dmi_spad_intrlv_info

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_spad_intrlv_rmvd_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit[ADDR_WIDTH-1:0] gen_spad_intrlv_rmvd_addr( bit[ADDR_WIDTH-1:0] full_addr, int unitID=0);
  bit [ADDR_WIDTH-1:0] sp_intrlv_addr;
  int way = DMI_MIF_way[unitID];
  int func = DMI_MIF_function[unitID];
  //Remove the interleave bits to generate a scratchpad translated address. 
  //You still need to deduct scratchpad base address from this output to get your SP offset address
  case(unitID) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) { %>
     <%=sidx%> : begin
                  case({way,func})
                    <%if (obj.DmiInfo[sidx].useCmc && obj.DmiInfo[sidx].ccpParams.useScratchpad) { %>
                    { 32'd2,32'd0}  : <%=assemble_sp_address(obj.DmiInfo[sidx].InterleaveInfo.dmi2WIFV, 0, obj.DmiInfo[sidx].wAddr)%>
                    { 32'd2,32'd1}  : <%=assemble_sp_address(obj.DmiInfo[sidx].InterleaveInfo.dmi2WIFV, 1, obj.DmiInfo[sidx].wAddr)%>
                    { 32'd3,32'd0}  : <%=assemble_sp_address(obj.DmiInfo[sidx].InterleaveInfo.dmi3WIFV, 0, obj.DmiInfo[sidx].wAddr)%>
                    { 32'd3,32'd1}  : <%=assemble_sp_address(obj.DmiInfo[sidx].InterleaveInfo.dmi3WIFV, 1, obj.DmiInfo[sidx].wAddr)%>
                    { 32'd4,32'd0}  : <%=assemble_sp_address(obj.DmiInfo[sidx].InterleaveInfo.dmi4WIFV, 0, obj.DmiInfo[sidx].wAddr)%>
                    { 32'd4,32'd1}  : <%=assemble_sp_address(obj.DmiInfo[sidx].InterleaveInfo.dmi4WIFV, 1, obj.DmiInfo[sidx].wAddr)%>
                    { 32'd8,32'd0}  : <%=assemble_sp_address(obj.DmiInfo[sidx].InterleaveInfo.dmi8WIFV, 0, obj.DmiInfo[sidx].wAddr)%>
                    { 32'd8,32'd1}  : <%=assemble_sp_address(obj.DmiInfo[sidx].InterleaveInfo.dmi8WIFV, 1, obj.DmiInfo[sidx].wAddr)%>
                    {32'd16,32'd0}  : <%=assemble_sp_address(obj.DmiInfo[sidx].InterleaveInfo.dmi16WIFV,0, obj.DmiInfo[sidx].wAddr)%>
                    {32'd16,32'd1}  : <%=assemble_sp_address(obj.DmiInfo[sidx].InterleaveInfo.dmi16WIFV,1, obj.DmiInfo[sidx].wAddr)%> <%}%>
                    default : sp_intrlv_addr = full_addr; 
                  endcase
         end   
      <%} %>
  endcase
  if($test$plusargs("print_spad_debug"))begin
    `uvm_info("NCORE_SPAD_DEBUG",$sformatf("-intrlv_rmvd-dmi%0d-[%0d,%0d,%0d]- Addr | out:%0h in:%0h", unitID, DMI_MIG_set[unitID], DMI_MIF_way[unitID], DMI_MIF_function[unitID], full_addr, sp_intrlv_addr),UVM_MEDIUM);
  end
  return(sp_intrlv_addr);
endfunction: gen_spad_intrlv_rmvd_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_full_cache_addr_from_spad_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
static function bit[ADDR_WIDTH-1:0] gen_full_cache_addr_from_spad_addr(bit[ADDR_WIDTH-1:0] sp_intrlv_addr, int unitID=0);
  bit [ADDR_WIDTH-1:0] full_addr;
  int way = DMI_MIF_way[unitID];
  int func = DMI_MIF_function[unitID];
  int set = DMI_MIG_set[unitID];
  bit [3:0] dmi_sel;
  <%for( let i=0; i< obj.DmiInfo.length; i++){  if (obj.DmiInfo[i].useCmc && obj.DmiInfo[i].ccpParams.useScratchpad && i==0) { %>
  foreach(dmi_igsv[set][igv])begin
    foreach(dmi_igsv[set][igv][iidv])begin
      if(dmi_igsv[set][igv][iidv] == unitID) begin
        dmi_sel = iidv;
        break;
      end
    end
  end<% } } %>
  //Generate full address from a scratchpad address with interleave bits removed
  case({way,func})
  <%for( let i=0; i< obj.DmiInfo.length; i++){
    if (obj.DmiInfo[i].useCmc && obj.DmiInfo[i].ccpParams.useScratchpad && i==0) { %>
    { 32'd2,32'd0}  : <%=assemble_full_address(obj.DmiInfo[i].InterleaveInfo.dmi2WIFV, 0, obj.DmiInfo[i].wAddr)%>
    { 32'd2,32'd1}  : <%=assemble_full_address(obj.DmiInfo[i].InterleaveInfo.dmi2WIFV, 1, obj.DmiInfo[i].wAddr)%>
    { 32'd3,32'd0}  : <%=assemble_full_address(obj.DmiInfo[i].InterleaveInfo.dmi3WIFV, 0, obj.DmiInfo[i].wAddr)%>
    { 32'd3,32'd1}  : <%=assemble_full_address(obj.DmiInfo[i].InterleaveInfo.dmi3WIFV, 1, obj.DmiInfo[i].wAddr)%>
    { 32'd4,32'd0}  : <%=assemble_full_address(obj.DmiInfo[i].InterleaveInfo.dmi4WIFV, 0, obj.DmiInfo[i].wAddr)%>
    { 32'd4,32'd1}  : <%=assemble_full_address(obj.DmiInfo[i].InterleaveInfo.dmi4WIFV, 1, obj.DmiInfo[i].wAddr)%>
    { 32'd8,32'd0}  : <%=assemble_full_address(obj.DmiInfo[i].InterleaveInfo.dmi8WIFV, 0, obj.DmiInfo[i].wAddr)%>
    { 32'd8,32'd1}  : <%=assemble_full_address(obj.DmiInfo[i].InterleaveInfo.dmi8WIFV, 1, obj.DmiInfo[i].wAddr)%>
    { 32'd16,32'd0}  : <%=assemble_full_address(obj.DmiInfo[i].InterleaveInfo.dmi16WIFV,0, obj.DmiInfo[i].wAddr)%>
    { 32'd16,32'd1}  : <%=assemble_full_address(obj.DmiInfo[i].InterleaveInfo.dmi16WIFV,1, obj.DmiInfo[i].wAddr)%> <%}}%>
    default : full_addr = sp_intrlv_addr; 
  endcase 
  if($test$plusargs("print_spad_debug"))begin
    `uvm_info("NCORE_SPAD_DEBUG",$sformatf("-full-dmi%0d-[%0d,%0d,%0d]- Addr | out:%0h in:%0h", unitID, DMI_MIG_set[unitID], DMI_MIF_way[unitID], DMI_MIF_function[unitID], full_addr, sp_intrlv_addr),UVM_MEDIUM);
  end
  return(full_addr);
endfunction: gen_full_cache_addr_from_spad_addr

endclass: ncoreConfigInfo
