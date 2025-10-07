//
//Static configuration information of Ncore system that
//is wrapped in SV static data structures. These structures
//are used by various DV components that require access to 
//configuration information
//

<%
//logicaId (CPU unit IDs ace L1 cache per CPU assumption)
var nLogicalIds = 0;
var logicalIds = [];
var selectBits = [];
var agentSelectBitValue = [];
var logicalId2AgentIdMap = [];
var wSelectBits = [];
var wEndpoint = [];
var agentsAxiAddr = [];
var agentsSfiAddr = [];
var maxAxiAddrWidth = 0;
var maxAxiDataWidth = 0;
var minAxiDataWidth = 1024;
var agentInfType = [];
var maxProcs       = [];

//Various agent ID's w.r.t bundles in configParams
var aiuIds = [];
var dceIds = [];
var dveIds = [];
var dmiIds = [];
var diiIds = [];

obj.AiuInfo.forEach(function(bundle, indx) {
    aiuIds.push(indx);
});

obj.DceInfo.forEach(function(bundle, indx) {
    dceIds.push(aiuIds.length + indx);
});

obj.DveInfo.forEach(function(bundle, indx) {
    dveIds.push( aiuIds.length + dceIds.length + indx);
});

obj.DmiInfo.forEach(function(bundle, indx) {
    dmiIds.push( aiuIds.length + dceIds.length + dveIds.length + indx);
});

obj.DiiInfo.forEach(function(bundle, indx) {
    diiIds.push( aiuIds.length + dceIds.length + dveIds.length + dmiIds.length + indx);
});

function funitids() {
  var arr = [];

  obj.AiuInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });
  
  obj.DceInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });
  
  obj.DveInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });
  
  obj.DmiInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });
  
  obj.DiiInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });

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
      for (var i = 0; i < nPorts; i++) {
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

var nLogaius = 0;
var nLogaiuQ = [];
var nLogaiuP = [];

var nLogdces = 0;
var nLogdceQ = [];
var nLogdceP = [];

var nLogdves = 0;
var nLogdveQ = [];
var nLogdveP = [];

var nLogdmis = 0;
var nLogdmiQ = [];
var nLogdmiP = [];

var nLogdiis = 0;
var nLogdiiQ = [];
var nLogdiiP = [];

var aiuBid = 0;
var dceBid = aiuIds.length;
var dveBid = aiuIds.length + dceIds.length;
var dmiBid = aiuIds.length + dceIds.length + dveIds.length;
var diiBid = aiuIds.length + dceIds.length + dveIds.length + dmiIds.length;

nLogaius = prtAbstract(obj.AiuInfo, aiuBid, nLogaiuQ, nLogaiuP);
nLogdmis = prtAbstract(obj.DmiInfo, dmiBid, nLogdmiQ, nLogdmiP);
nLogdiis = prtAbstract(obj.DiiInfo, diiBid, nLogdiiQ, nLogdiiP);
nLogdces = obj.DceSelectInfo.nDces;
nLogdves = 1;
nLogdveQ.push(dveBid);
nLogdveP.push(0);

var fillDceVal = function(a, c) {
  if (a == 0) {
    nLogdceQ.push(c);
    nLogdceP.push(0);
  } else {
    for (var i = 0; i < a; i++) 
      nLogdceQ.push(c + i);
      nLogdceP.push(i);
  }
};

fillDceVal(obj.DceSelectInfo.nDces, dceBid);

function addrTransMgr(cohAgents, initSeed) {

    cohAgents.forEach(function(bundle, index, array) {

        if(bundle.fnNativeInterface === "ACE") {
            agentInfType.push(0);

        } else if((bundle.fnNativeInterface === "AXI4")||(bundle.fnNativeInterface === "AXI5")) {
            if(bundle.useCache) {
                agentInfType.push(5);
            } else {
                agentInfType.push(3);
            }

        } else if((bundle.fnNativeInterface === "CHI-A")||(bundle.fnNativeInterface === "CHI-B")||(bundle.fnNativeInterface === "CHI-E")) {
            agentInfType.push(2);

        } else if(bundle.fnNativeInterface === "ACELITE-E") {
            agentInfType.push(6);

        } else if(bundle.fnNativeInterface === "ACE-LITE") {
            if (bundle.isBridgeInterface) {
                if (bundle.useCache)
                  agentInfType.push(5);
                else
                  agentInfType.push(4);
            } else {
                agentInfType.push(1);
            }
                 
        } else {
            throw "Unexpected interface type";
        }
    
        wSelectBits.push(0);

        //Assigning ProcID's
        if ((bundle.fnNativeInterface === "CHI-A")||(bundle.fnNativeInterface === "CHI-B")||(bundle.fnNativeInterface === "CHI-E")) {
            maxProcs.push(bundle.nProcs);
        }

        if(bundle.fnNativeInterface === "ACE") {
            maxProcs.push(bundle.nProcs);
        }
    
        agentsAxiAddr.push(bundle.wAddr);
        if(bundle.wAddr > maxAxiAddrWidth) 
          maxAxiAddrWidth = bundle.wAddr;
        if(bundle.wData > maxAxiDataWidth) 
          maxAxiDataWidth = bundle.wData;
        if(bundle.wData < minAxiDataWidth) 
          minAxiDataWidth = bundle.wData;

        agentsSfiAddr.push(obj.wSysAddr);
    });
}

var nMems = function() {
  if (!obj.useCsrProgrammedAddrRangeInfo)
    return obj.SysAddrRangeInfo.nSysAddrRanges;
  return 0;
};

var IGSV = [];
var intrlvGrp2SysAddrMap = [];
var intrlvGrpType        = [];
var memRegionBoundaries  = [];
var nMemGrps             = 0;

function dmiInfo() {
  var baseId = obj.AiuInfo.length + obj.DceInfo.length;

  if (!obj.useCsrProgrammedAddrRangeInfo) {
    obj.SysAddrRangeInfo.SysAddrRangeInfo.forEach(function(bundle) {
      var bound = {
          'startAddr': 0,
          'endAddr':   0
      };
      bound.startAddr = bundle.nBaseAddr.toString(16);
      bound.endAddr   = (parseInt(bundle.nBaseAddr.toString(10)) + bundle.nSizeBytes).toString(16);
      memRegionBoundaries.push(bound);
    });
  

    Object.keys(obj.SysAddrRangeInfo.MInterlvGrpAddrMapInfo).map(function(indx) {
      var arr = [];
      obj.SysAddrRangeInfo.MInterlvGrpAddrMapInfo[indx].forEach(function(val) {
        arr.push(val);
      });
      intrlvGrp2SysAddrMap.push(arr);
      intrlvGrpType.push('DMI');
      nMemGrps++;
    });

    Object.keys(obj.SysAddrRangeInfo.DIIAddrMapInfo).map(function(indx) {
      var arr = [];
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
          var arr = [];
          lp1.IGV.forEach(function(lp2) {
              arr.push(lp2.DMIIDV.length);
          });
          IGSV.push(arr);
      });
    }
  }
}

addrTransMgr(obj.AiuInfo, 0);
dmiInfo();

var ncti_master_found = 0;
if (obj.FULL_SYS_TB) {
    for(var pidx = 0 ; pidx < obj.ncti_agents.length; pidx++) { 
        if (obj.ncti_agents[pidx].is_master === 1 && ncti_master_found === 0) {
            ncti_master_found = 1;
            wSelectBits.push(0);
            agentsAxiAddr.push(maxAxiAddrWidth);
            agentsSfiAddr.push(obj.wSysAddr);
            agentInfType.push(3);
        }
    }
}

var nCaches = 0;          //Number of cacheing agents
var cache2funit_map = []; //Cache Id to Agent ID map
var sfSlices = [];

function getCacheingAgents(p) {
  p.AiuInfo.forEach(function(bundle) {
    if ((bundle.fnNativeInterface === "CHI-A") || (bundle.fnNativeInterface === "CHI-B") || (bundle.fnNativeInterface === "CHI-E") || bundle.useCache)
      nCaches++;
  });

  p.SnoopFilterInfo.forEach(function(SfObj, indx) {
  	SfObj.SnoopFilterAssignment.slice().reverse().forEach(function(val) {
		cache2funit_map.push(val);
     });
  });
  
  //SfObj.SnoopFilterAssignment.slice().reverse().forEach(function(val) {
  
  p.AiuInfo.forEach(function(bundle) {
    if ((bundle.fnNativeInterface === "CHI-A") || (bundle.fnNativeInterface === "CHI-B") || (bundle.fnNativeInterface === "CHI-E") || bundle.useCache) {
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
    var tmpArr = [];

    obj.AiuInfo.forEach(function(bundle, indx) {
        if((bundle.fnNativeInterface === "ACE") ||
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

var mrdCreditsPerDmi = function() {
    var tmpArr = [];

    obj.DmiInfo.forEach(function(bundle, indx) {
        tmpArr.push(bundle.nMrdSkidBufSize);
    });
    return(tmpArr);
};

var numSF = 0; //Number of Snoop Filters
var numTagSF = 0; //Number of Tag Snoop Filters
var snoopFilters = [];

function extractSnoopFilterInfo(p) {
    numSF = p.length;
    
    p.forEach(function(bundle, indx, array) {
        var sfInfo = {
            filterType: '',
            nSets: 0,
            nWays: 0,
            tagFilterType: '',
            errorType: '',
            eccSplitFactor: ''
        };
        if(bundle.fnFilterType === "EXPLICITOWNER") {
            numTagSF++;
            sfInfo['filterType'] = "TAGFILTER";
            sfInfo['nSets'] = bundle.nSets;
            sfInfo['nWays'] = bundle.nWays;
            sfInfo['tagFilterType']  = bundle.fnFilterType;
            sfInfo['nVictimEntries'] = bundle.nVictimEntries;

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
        }
        snoopFilters.push(sfInfo);
    });
}

//Method Calls
extractSnoopFilterInfo(obj.SnoopFilterInfo);

//DVM capable agents
var dvmMsgAgents = [];
var dvmCmpAgents = [];
obj.AiuInfo.forEach(function(bundle, indx, array) {
    if((bundle.fnNativeInterface === "CHI-A") || (bundle.fnNativeInterface === "CHI-B") || (bundle.fnNativeInterface === "CHI-E")) {
        dvmMsgAgents.push(bundle.FUnitId);
        dvmCmpAgents.push(bundle.FUnitId);
    }
});

//Abstrached Mehod for reading any General selection algorithm table
var getSelectionInfo = function(bundle, num_entries, strName) {
    //console.log(strName);
    return({
        'nEntries' : num_entries,
        'nResorcs' : num_entries,
        'primBits' : bundle.PriSubDiagAddrBits,
        'hashBits' : Object.keys(bundle.SecSubRows).map(function(indx) {
                         return bundle.SecSubRows[indx];
                     }),
        'strInfo'  : strName
    });
};

//If there is no setSelection for that agent then to avoid messing up
//logical Id count this method is called
var emptySelection = function(strName) {
    return({
        'nEntries' : 0,
        'nResorcs' : 0,
        'primBits' : [],
        'hashBits' : [],
        'strInfo'  : strName
    });
};


var aiuPortSel = [];
var dcePortSel = [];
var dmiPortSel = [];
var diiPortSel = [];
var baseCount;

baseCount = 0;
obj.AiuInfo.forEach(function(bundle, indx) {
    var str = "AIU" + baseCount;
    aiuPortSel.push(emptySelection(str));
    aiuPortSel[aiuPortSel.length - 1].nEntries = 1;
});

baseCount = 0;
dcePortSel.push(getSelectionInfo(obj.DceSelectInfo, obj.DceInfo.length, "DCE"));

baseCount = 0;
obj.DmiInfo.forEach(function(bundle, indx) {
    var str = "DMI" + baseCount;
    dmiPortSel.push(emptySelection(str));
    dmiPortSel[dmiPortSel.length - 1].nEntries = 1;
});

baseCount = 0;
obj.DiiInfo.forEach(function(bundle, indx) {
    var str = "DII" + baseCount;
    diiPortSel.push(emptySelection(str));
    diiPortSel[diiPortSel.length - 1].nEntries = 1;
});

//CBI cache index selection
var cbiCache = [];
obj.AiuInfo.forEach(function(bundle, indx) {
    if(!bundle.interleavedAgent) {
        if(bundle.useCache) {
            cbiCache.push(getSelectionInfo(bundle.ccpParams,
                                           bundle.ccpParams.nSets, 
                                           ("CBI" + indx)));
        } else {
            cbiCache.push(emptySelection("CBI" + indx));
        }
    }
});

//SF index selection
var sfCache = [];
obj.SnoopFilterInfo.forEach(function(bundle, indx) {
    if(bundle.fnFilterType === "EXPLICITOWNER") {
        sfCache.push(getSelectionInfo(bundle.SetSelectInfo, bundle.nSets, 
                                          ("SF" + indx)));
    } else {
        sfCache.push(emptySelection("SF" + indx));
    }
});

//CMC cache index selection
var cmcCache = [];
obj.DmiInfo.forEach(function(bundle, indx) {
    if(!bundle.interleavedAgent) {
        if(bundle.useCmc) {
            cmcCache.push(getSelectionInfo(bundle.ccpParams,
                                           bundle.ccpParams.nSets, 
                                           ("CMC" + indx)));
        } else {
            cmcCache.push(emptySelection("CMC" + indx));
        }
    }
});

//Dmis with CMC
var dmisWithCmc = function() {
    var arr = [];
    obj.DmiInfo.forEach(function(bundle, indx, array) {
        arr.push(bundle.useCmc);
    });
    return(arr);
};


//Diis have endpoint size
obj.DiiInfo.forEach(function(bundle, indx) {
    wEndpoint.push(bundle.wLargestEndpoint);
});

var total_sf_ways = 0;
var max_sf_set_idx = 0;

obj.SnoopFilterInfo.forEach(function(bundle) {
    if(bundle.fnFilterType === "EXPLICITOWNER") {
        total_sf_ways += bundle.nWays;
        if (bundle.SetSelectInfo.PriSubDiagAddrBits.length > max_sf_set_idx) {
			max_sf_set_idx = bundle.SetSelectInfo.PriSubDiagAddrBits.length;
        }
    }
});

%> 

//Concerto v1 support
//Static class to have local scope
class addrMgrConst;

    <% if (obj.FULL_SYS_TB) { 
        var ncti_master_found = 0;
        for(var pidx = 0 ; pidx < obj.ncti_agents.length; pidx++) { 
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
    parameter int NUM_COH_VISB_AIUS = <%=obj.AiuInfo.length%>;
    parameter int NUM_DMIS          = <%=obj.DmiInfo.length%>;
    parameter int NUM_DIIS          = <%=obj.DiiInfo.length%>;
    parameter int NUM_DCES          = <%=obj.DceInfo.length%>;
    parameter int NUM_DVES          = <%=obj.DveInfo.length%>;
    parameter int NUM_AGENTS        = NUM_AIUS + NUM_DCES + NUM_DVES + NUM_DMIS + NUM_DIIS;
    parameter int ADDR_WIDTH        = <%=maxAxiAddrWidth%>;
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
    parameter int TAGGED_MON_PER_DCE     = <%=obj.DceInfo[0].nTaggedMonitors%>;

    // NRS Base Address
    parameter bit [63:0]   NRS_REGION_BASE    = <%=obj.AiuInfo[0].CsrInfo.csrBaseAddress.replace("0x","'h")%> << 20;
    parameter int 	   NRS_REGION_SIZE    = (<%=obj.AiuInfo[0].nrri%>+1) << 20;
       
    // Boot Region Address
    parameter int unsigned BOOT_REGION_BASE_L = <%=obj.AiuInfo[0].BootInfo.regionBlr.replace("0x","'h")%>;
    parameter int unsigned BOOT_REGION_BASE_H = <%=obj.AiuInfo[0].BootInfo.regionBhr.replace("0x","'h")%>;
    parameter bit [63:0]   BOOT_REGION_BASE   = (((BOOT_REGION_BASE_H)<<32)|BOOT_REGION_BASE_L)<<12;
    parameter int          BOOT_REGION_SIZE   = 2**(<%=obj.AiuInfo[0].BootInfo.regionSize%>+12);

    //Max Memregion Prefix width
<% 
var wPrefix = [];
for(var i=0; i < obj.AiuInfo.length; i++) {
    wPrefix.push((agentsAxiAddr[i] - agentsSfiAddr[i]));
}
%>
    parameter MAX_PREFIX = <%=Math.max.apply(null, wPrefix)%>;

    parameter bit[ADDR_WIDTH-1:0] CONCERTO_MIN_ADDRESS_MAP = 0;
    parameter bit[ADDR_WIDTH-1:0] CONCERTO_MAX_ADDRESS_MAP = 65535;

    typedef int intq[$];
    typedef int int2dq[$][$];

    typedef enum bit [2:0] {
        ACE_IX, ACE_SC, ACE_SD, ACE_UC, ACE_UD
    } aceState_t;

    typedef enum int {
        ACE_AIU, ACE_LITE_AIU, CHI_AIU, 
        AXI_BAIU, ACE_LITE_BAIU, IO_CACHE_BAIU, ACE_LITE_E_BAIU
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

    typedef struct packed {
        bit [63:0] start_addr;
        bit [63:0] end_addr;
    } memregion_boundaries_t;

    typedef enum {
      AIU, DCE, DMI, DII, DVE
    } ncore_unit_type_t;

    typedef enum {
      COH, IOCOH, NONCOH, NRS, BOOT
    } addr_format_t;

    typedef struct {
      ncore_unit_type_t utype;
      int nig;
      int nassoc_memregions;
    } igs_info_t;

    typedef struct {
        ncore_unit_type_t unit;
        bit [4:0]  mig_nunitid;
        bit [4:0]  size;
        bit [31:0] low_addr;
        bit [7:0]  upp_addr;
    } sys_addr_csr_t;
    typedef sys_addr_csr_t sys_addrq[$];

    //Below data strutures must be indexed using LogicalID's
    //Use get_logical_uinfo() method to retrive cache_id, Column index 
    const static int logical2aiu_map[<%=nLogaius%>][$] = '{<% for(var i = 0; i < nLogaius; i++) { %> '{<%=nLogaiuQ[i]%>}<%if(i < nLogaius-1) { %>,<% } } %> };
    const static int logical2aiu_prt[<%=nLogaius%>][$] = '{<% for(var i = 0; i < nLogaius; i++) { %> '{<%=nLogaiuP[i]%>}<%if(i < nLogaius-1) { %>,<% } } %> };
    const static int logical2dce_map[<%=nLogdces%>][$] = '{<% for(var i = 0; i < nLogdces; i++) { %> '{<%=nLogdceQ[i]%>}<%if(i < nLogdces-1) { %>,<% } } %> };
    const static int logical2dce_prt[<%=nLogdces%>][$] = '{<% for(var i = 0; i < nLogdces; i++) { %> '{<%=nLogdceP[i]%>}<%if(i < nLogdces-1) { %>,<% } } %> };
    const static int logical2dve_map[<%=nLogdves%>][$] = '{<% for(var i = 0; i < nLogdves; i++) { %> '{<%=nLogdveQ[i]%>}<%if(i < nLogdves-1) { %>,<% } } %> };
    const static int logical2dve_prt[<%=nLogdves%>][$] = '{<% for(var i = 0; i < nLogdves; i++) { %> '{<%=nLogdveP[i]%>}<%if(i < nLogdves-1) { %>,<% } } %> };
    //Non-const and 2-D queues because can be run-time programable
    static int logical2dmi_map[$][$] = '{<% for(var i = 0; i < nLogdmis; i++) { %> '{<%=nLogdmiQ[i]%>}<%if(i < nLogdmis-1) { %>,<% } } %> };
    static int logical2dmi_prt[$][$] = '{<% for(var i = 0; i < nLogdmis; i++) { %> '{<%=nLogdmiP[i]%>}<%if(i < nLogdmis-1) { %>,<% } } %> };
    static int logical2dii_map[$][$] = '{<% for(var i = 0; i < nLogdiis; i++) { %> '{<%=nLogdiiQ[i]%>}<%if(i < nLogdiis-1) { %>,<% } } %> };
    static int logical2dii_prt[$][$] = '{<% for(var i = 0; i < nLogdiis; i++) { %> '{<%=nLogdiiP[i]%>}<%if(i < nLogdiis-1) { %>,<% } } %> };


    //Below data strutures must be indexed using CacheID's
    //Use get_cacheid() method to retrive cache_id, Column index 
    const static int cache2funit_map[<%=nCaches%>][$] = '{<% for(var i = 0; i < nCaches; i++) { %> '{<%=cache2funit_map[i]%>}<%if(i < nCaches-1) { %>,<% } } %> };
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
    static int intrlvgrp_vector[<%=IGSV.length%>][$] = '{<% for(var i = 0; i < IGSV.length; i++) { %> '{<%=IGSV[i]%>}<%if(i < IGSV.length - 1) { %>,<% } } %> };
    static int picked_dmi_igs = 0;
    static int intrlvgrp2mem_map[$][$] = '{<% for(var i = 0; i < nMemGrps; i++) { %> '{<%=intrlvGrp2SysAddrMap[i]%>}<%if(i < nMemGrps-1) { %>,<% } } %> };
    static ncore_unit_type_t intrlvgrp_if[$] = '{<%=intrlvGrpType%>};

    //Below data structures must be access using AgentID
    const static int select_bits_width[NUM_AIUS] = '{<%=wSelectBits%>};
    const static int agent_aceaddr_width[NUM_AIUS] = '{<%=agentsAxiAddr%>};
    const static int agent_sfiaddr_width[NUM_AIUS] = '{<%=agentsSfiAddr%>};
    const static int inf[NUM_AIUS] = '{<%=agentInfType%>};

    //Below D.S accessed w.r.t dmi_id
    const static int dmis_with_cmc[NUM_DMIS]  = '{<%=dmisWithCmc()%>};

    //Below D.S accessed w.r.t dii_id
    const static int diiIds[$] = '{<% for(var i = 0; i < diiIds.length; i++) { %><%=diiIds[i]%><%if(i < diiIds.length-1) { %>,<% } } %> };
    const static int wEndpoint[$] = '{<% for(var i = 0; i < wEndpoint.length; i++) { %><%=wEndpoint[i]%><%if(i < wEndpoint.length-1) { %>,<% } } %> };

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
    const static int funit_ids[<%=funitids().length%>] = {<%=funitids()%>};

    //Snoop Filters Information
    static sf_info_t snoop_filters_info[$] = '{
<% snoopFilters.forEach(function(b, i, array) { %>
        '{"<%=b.filterType%>", <%=b.nSets%>, <%=b.nWays%>, "<%=b.tagFilterType%>", <%=b.nVictimEntries%>, <%=b.errorType%>, <%=b.eccSplitFactor%>}<% if(i !== snoopFilters.length -1) { %>,<% } }); %>
                                              };

    const static selection_data_t aiu_port_sel[$] = '{
<% aiuPortSel.forEach(function(bundle, i, array) { %>
        '{<%=bundle.nEntries%>, <%=bundle.nResorcs%>, '{<%=bundle.primBits%>}, '{<%bundle.hashBits.forEach(function(val, _i){%>'{<%=val%>}<%if(_i !==bundle.hashBits.length - 1) {%>,<% } });%>}, "<%=bundle.strInfo%>"}<%if(i !== aiuPortSel.length-1) {%>,<%} });%>
                                                        };
    const static selection_data_t dce_port_sel[1] = '{
<% dcePortSel.forEach(function(bundle, i, array) { %>
        '{<%=bundle.nEntries%>, <%=bundle.nResorcs%>, '{<%=bundle.primBits%>}, '{<%bundle.hashBits.forEach(function(val, _i){%>'{<%=val%>}<%if(_i !==bundle.hashBits.length - 1) {%>,<% } });%>}, "<%=bundle.strInfo%>"}<%if(i !== dcePortSel.length-1) {%>,<%} });%>
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

    const static int snp_credits_inflight[NUM_COH_VISB_AIUS] = '{<%=snpCreditsPerAiu()%>};
    const static int mrd_credits_inflight[NUM_DMIS] = '{<%=mrdCreditsPerDmi()%>};
    const static int dvm_msg_capb_agents[$] = '{<%=dvmMsgAgents%>};
    const static int dvm_snp_capb_agents[$] = '{<%=dvmCmpAgents%>};

    ////////////////
    //Methods to access above data structures
    ////////////////

    static function ncore_unit_type_t get_unit_type(int iid);
      int q[$];

      q = aiu_ids.find(x) with (x == iid);
      if (q.size())
        return AIU;

      q = dce_ids.find(x) with (x == iid);
      if (q.size())
        return DCE;

      q = dmi_ids.find(x) with (x == iid);
      if (q.size())
        return DMI;

      q = dii_ids.find(x) with (x == iid);
      if (q.size())
        return DII;

      q = dve_ids.find(x) with (x == iid);
      if (q.size())
        return DVE;


      `uvm_fatal("ADDR MGR", $psprintf("Unexpected agnetid:%0d", iid))
      return AIU;
    endfunction: get_unit_type

    //Note: Method returns -1 if agent is not a cacheing agent
    static function int get_cache_id(input int agent_id, bit fail_on_err = 1'b1);
        int cache_id = -1;

// HS: Delete below code eventually. Just commented out for timebeing for reference.
//        if((agent_id > NUM_AIUS) && (fail_on_err)) begin
//            `uvm_fatal("ADDR MGR", $psprintf("Unexpected Agent Id %0d; Total number of Agents %0d", 
//            agent_id, NUM_AIUS));
//        end

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

    
    //Method returns agentId's associated to caching-agentID specified
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

    static function int get_snoopfilter_id(input int agent_id);
        int sf_id = -1;

        if (funit2sf_slice.exists(agent_id))
        	sf_id = funit2sf_slice[agent_id];
        
        `uvm_info("ADDR MGR", $psprintf("Snoop filter slice is %0d for funit_id %0d", agent_id, sf_id), UVM_HIGH)
       
        return(sf_id);        

    endfunction: get_snoopfilter_id

    static function int get_sfid_assoc2cacheid(input int cache_id);
        int sf_id, funit_idq[$], funit_id;

        funit_idq = get_agent_ids_assoc2cacheid(cache_id);
        funit_id = funit_idq[0];

        sf_id = get_snoopfilter_id(funit_id);
        return(sf_id);
    endfunction: get_sfid_assoc2cacheid;
    
    //Method returns number of Caching agents acssociated with this SF
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

    //Method retruns agentID's associated to the Snoop Filter
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

    //Method returns relative bit-index of caching agent witn in snoop filter slice
    //ex: if cacheing agents {0, 3, 5} are monitored by SF 2 then
    //bit[0] represents cacheing agent 0
    //bit[1] represents cacheing agent 3
    //bit[2] represents cacheing agent 5
    //HS:Needs update
//    static function int rel_indx_within_sf(int sf_id, int cache_id);
//        int count;
//
//        count = 0;
//        for(int i = 0; i < NUM_CACHES; i++) begin
//            if((funit2sf_slice[i] == sf_id) && (i == cache_id))
//                break;
//            else if(funit2sf_slice[i] == sf_id)
//                count++;
//        end
//
//        return(count);
//    endfunction: rel_indx_within_sf
    
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

    //Returns coarse vector representation of that filter.
    //Returns a arrary of arrays with all caching agents representation  
    static function int2dq get_coarse_vec_rep(int sf_id);
        int rel_sfid;
        int2dq coarse_ds;

        `uvm_fatal("NCORE_CONFIG",
            "This method should not be called anymore in Ncore-v3.0")

        return(coarse_ds);
    endfunction: get_coarse_vec_rep

    //Retrurns default value -1 //logical id local ncore unit type
    static function void get_logical_uinfo(
        input  int agent_id,
        output int cache_id,
        output int col_indx,
        output ncore_unit_type_t utype);

        int tmp_indx, tmp_id;
        utype = get_unit_type(agent_id);
        tmp_id = 0;
        cache_id = -1;

        if (utype == AIU) begin 
            foreach(logical2aiu_map[ridx]) begin
                tmp_indx = 0;
                for(int i = 0; i < logical2aiu_map[ridx].size(); i++) begin
                     if(logical2aiu_map[ridx][i] == agent_id) begin
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
                     if(logical2dce_map[ridx][i] == agent_id) begin
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
                     if(logical2dmi_map[ridx][i] == agent_id) begin
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
                     if(logical2dii_map[ridx][i] == agent_id) begin
                         cache_id = ridx;
                         col_indx = tmp_indx;
                     end
                     else 
                         tmp_indx++;
                end
            end
        end

    endfunction: get_logical_uinfo

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


    static function int get_logical_id(int agent_id);
      int lid, cid;
      ncore_unit_type_t utype;

      get_logical_uinfo(agent_id, lid, cid, utype);
      return lid;
    endfunction: get_logical_id

    static function int get_addr_width(int agent_id);
        return(ADDR_WIDTH); 
    endfunction: get_addr_width

    static function int get_sfi_addr_width(int agent_id);
        return(agent_sfiaddr_width[agent_id]);
    endfunction: get_sfi_addr_width

    static function interface_t get_native_interface(int agent_id);
        interface_t agent_inf;

        if(!$cast(agent_inf, inf[agent_id]))
            `uvm_fatal("ADDR MGR", "Cast failed")

		`uvm_info("addr mgr", $psprintf("agent_id:%0d agent_int:%0s", agent_id, agent_inf.name()), UVM_HIGH)

        return(agent_inf);
    endfunction: get_native_interface

    //Snoop Filter Methods
    static function void get_sf_sel_bits(int sf_slice, ref int bit_q[$]);
        if(snoop_filters_info[sf_slice].filter_type != "TAGFILTER")
            `uvm_fatal("ADDR MGR", $psprintf("snoop Filter ID slice %0s is a NULL Filter",
            sf_slice))
       
        //bit_q = snoop_filters_info[sf_slice].sel_bits;
    endfunction: get_sf_sel_bits

    static function void get_sf_hash_bits(int sf_slice, ref int bit_q[$]);
        if(snoop_filters_info[sf_slice].filter_type != "TAGFILTER")
            `uvm_fatal("ADDR MGR", $psprintf("snoop Filter ID slice %0s is a NULL Filter",
            sf_slice))
       
        //bit_q = snoop_filters_info[sf_slice].hash_bits;
    endfunction: get_sf_hash_bits

//    static function bit [WSFSETIDX-1:0] get_sf_set_index(int sf_id, bit [ADDR_WIDTH-1 : 0] addr);



//	endfunction: get_sf_set_index

    static function int get_idx_from_id(intq idsq, bit h_l);
       int indx = idsq[0];
       for (int i=1; i<idsq.size(); i++) begin
	  if ( ((h_l == 1) && (idsq[i] > indx)) ||
	       ((h_l == 0) && (idsq[i] < indx)) ) indx = idsq[i];
       end
       return indx;
    endfunction : get_idx_from_id
       
    static function int get_sys_dii_idx();
       return get_idx_from_id(dii_ids, 1);
    endfunction : get_sys_dii_idx
       
    static function int get_max_procs(int req_agent);
        int cache_id;
        int max_ids;

        if(get_native_interface(req_agent) == ACE_AIU ||
           get_native_interface(req_agent) == CHI_AIU) begin
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

    static function int get_total_intrlv_grps();
      return intrlvgrp_if.size();
    endfunction: get_total_intrlv_grps

    static function sys_addrq get_memregions_assoc_ig(int ig_id);
      sys_addr_csr_t csrq[$];
      `ASSERT(ig_id < intrlvgrp_if.size());

	  //`uvm_info("addr mgr dbg", $psprintf("fn:get_memregions_assoc_ig -- > intrlvgrp2mem_map.size:%0d for ig:%0d", intrlvgrp2mem_map[ig_id].size(), ig_id), UVM_LOW)
      foreach (intrlvgrp2mem_map[ig_id][idx]) begin
         int tmpv;
         sys_addr_csr_t csr;
         
         tmpv = intrlvgrp2mem_map[ig_id][idx];
         if (intrlvgrp_if[ig_id] == DMI) begin
           bit [63:0] mig_sz;
           int nmig;

           mig_sz = memregion_boundaries[tmpv].end_addr -
                        memregion_boundaries[tmpv].start_addr;
           nmig   = intrlvgrp_vector[picked_dmi_igs][ig_id];
           `ASSERT(mig_sz % intrlvgrp_vector[picked_dmi_igs][ig_id] == 0);
           csr.unit = DMI;
           csr.mig_nunitid = ig_id;
           csr.size = $clog2(mig_sz / nmig) - 12;
		   //`uvm_info("addr mgr dbg", $psprintf("fn:get_memregios_assoc_ig -- > ig_id:%0d mig_sz:%0d nmig:%0d size:%0d", ig_id, mig_sz, nmig, csr.size), UVM_LOW)
         end else begin
           csr.unit = DII;
           csr.mig_nunitid = ig_id - intrlvgrp_vector[picked_dmi_igs].size();
           `ASSERT(csr.mig_nunitid >= 0);
           csr.size = $clog2((
               memregion_boundaries[tmpv].end_addr -
               memregion_boundaries[tmpv].start_addr) >> 12);
         end

         csr.low_addr = memregion_boundaries[tmpv].start_addr >> 12;
         csr.upp_addr = memregion_boundaries[tmpv].start_addr >> 44;
         csrq.push_back(csr);
      end
      return csrq;
    endfunction: get_memregions_assoc_ig

    static function sys_addrq get_all_gpra();
      sys_addr_csr_t csrq[$];

      for (int ig = 0; ig < get_total_intrlv_grps(); ++ig) begin
        sys_addr_csr_t tmpq[$];

        tmpq = get_memregions_assoc_ig(ig);
		//`uvm_info("addr mgr dbg", $psprintf("fn:get_all_gpra -- > ig:%0d tmpq.size:%0d", ig, tmpq.size()), UVM_LOW)
        foreach (tmpq[i])
          csrq.push_back(tmpq[i]);

	void'(csrq.pop_back());//dont supply sys DII
      end
      return csrq;
    endfunction: get_all_gpra

    //Method: map address to DMI or DII
    //Reurns FUnitId associated with DMI or DII
    static function int map_addr2dmi_or_dii(
        input bit [ADDR_WIDTH-1:0] addr,
        output int fnmem_region_idx);

      int intrlv_grp_idx;
 
      intrlv_grp_idx   = -1;
      fnmem_region_idx = -1;

      if(addr[ADDR_WIDTH-1:19]=='0) //boot region
      begin
$display(" tagert id %x, funitid %x", get_target_agentid(addr, DMI, 0), funit_ids[get_target_agentid(addr, DMI, 0)]);
      	return funit_ids[get_target_agentid(addr, DMI, 0)];
      end

      foreach (memregion_boundaries[idx]) begin
        if (addr >= memregion_boundaries[idx].start_addr &&
            addr <  memregion_boundaries[idx].end_addr) begin

          if (fnmem_region_idx == -1)
            fnmem_region_idx = idx;
          else
            `ASSERT(0, $psprintf("Address:0x%0h maps to multiple memory regions", addr));
        end
      end

      //Error Senario
      //if (fnmem_region_idx == -1) //re-enable after added csr region RS
      //  `ASSERT(0, $psprintf("Address:0x%0h not mapped to existing memory regions", addr));

      foreach (intrlvgrp2mem_map[idx]) begin
        foreach (intrlvgrp2mem_map[idx,ridx]) begin
          if (fnmem_region_idx == intrlvgrp2mem_map[idx][ridx])
            intrlv_grp_idx = idx;
        end
      end

      if (intrlv_grp_idx == -1) begin
	 // not found. Check boot region and NRS region
	 // Check if the address maps into Boot region
	 if ( (addr >= BOOT_REGION_BASE) && (addr <  (BOOT_REGION_BASE + BOOT_REGION_SIZE)) ) begin
	    int funit_id;
	    if (<%=obj.AiuInfo[0].BootInfo.regionHut%> == 0) begin
               funit_id = funit_ids[dmi_ids[<%=obj.AiuInfo[0].BootInfo.regionHui%>]];
            end else begin // for DII
               funit_id = funit_ids[dii_ids[<%=obj.AiuInfo[0].BootInfo.regionHui%>]];
            end
            `uvm_info($sformatf("%m"), $sformatf("BOOT REGION DMI FunitID=%0h", funit_id), UVM_HIGH)
            return funit_id;
	 end else if ( (addr >= NRS_REGION_BASE) &&
		       (addr <  (NRS_REGION_BASE + NRS_REGION_SIZE)) ) begin
	    // NRS region and should go to system Configuration DII
            `uvm_info($sformatf("%m"), $sformatf("BOOT REGION DII FunitID=%0h", diiIds[get_sys_dii_idx()]), UVM_HIGH)
            return diiIds[get_sys_dii_idx()];
	 end

        `uvm_info($sformatf("%m"), $sformatf("ADDR=%p does not map int boot region [B=%0h S=%0h (DVJS=%0d] or NRS region [%0h-", addr, BOOT_REGION_BASE, BOOT_REGION_SIZE, <%=obj.AiuInfo[0].BootInfo.regionSize%>, NRS_REGION_BASE), UVM_HIGH)
        `ASSERT(0, $psprintf("None of the targets are mapped to DMI or DII, Address:0x%0h", addr));
      end // if (intrlv_grp_idx == -1)
       
      if (intrlvgrp_if[intrlv_grp_idx] == DMI) begin
         return funit_ids[get_target_agentid(addr, DMI, intrlv_grp_idx)];

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

    static function int get_target_agentid(
      bit [ADDR_WIDTH - 1 : 0] addr,
      ncore_unit_type_t utype,
      int ig);

      bit [ADDR_WIDTH - 1 : 0] portid;
      portid = 0;

      if (utype == DMI) begin
        foreach (dmi_port_sel[ig].pri_bits[idx]) begin
          portid[idx] = addr[dmi_port_sel[ig].pri_bits[idx]];
          foreach (dmi_port_sel[ig].sec_bits[idx,cidx])
            portid[idx] = portid[idx] ^ 
                          addr[dmi_port_sel[ig].sec_bits[idx][cidx]];
        end
        return logical2dmi_map[ig][portid];
      end else begin
        foreach (dii_port_sel[ig].pri_bits[idx]) begin
          portid[idx] = addr[dii_port_sel[ig].pri_bits[idx]];
          foreach (dii_port_sel[ig].sec_bits[idx,cidx])
            portid[idx] = portid[idx] ^ 
                          addr[dii_port_sel[ig].sec_bits[idx][cidx]];
        end
        return logical2dii_map[ig][portid];
      end

      return -1;
   endfunction: get_target_agentid

    //Method: map address to DCE
    //Reurns FUnitID associated with DCE
    static function int map_addr2dce(
        bit [ADDR_WIDTH-1:0] addr);

      int dceid;
      dceid = -1;
      `ASSERT(dce_ids.size() > 0);
      if (dce_ids.size() == 1 || addr[ADDR_WIDTH-1:19]=='0) //or boot region 
        return get_dce_funitid(0);

      foreach (dce_port_sel[0].pri_bits[idx]) begin
        dceid[idx] = addr[dce_port_sel[0].pri_bits[idx]];
        foreach (dce_port_sel[0].sec_bits[idx,cidx])
          dceid[idx] = dceid[idx] ^ 
                           addr[dce_port_sel[0].sec_bits[idx][cidx]];
      end

      return get_dce_funitid(dceid);
    endfunction: map_addr2dce

    static function bit tagged_monitors_exist();
        bit status;
        if(TAGGED_MON_PER_DCE > 0) 
            status = 1'b1;
        else
            status = 1'b0;
        return(status);
    endfunction: tagged_monitors_exist

    static function intq get_dvm_snp_agents();
        intq tmpq;

        foreach(dvm_snp_capb_agents[idx]) begin
            tmpq.push_back(dvm_snp_capb_agents[idx]);
        end
        return(tmpq);
    endfunction: get_dvm_snp_agents

    static function intq get_dvm_msg_agents();
        intq tmpq;

        foreach(dvm_msg_capb_agents[idx]) begin
            tmpq.push_back(dvm_msg_capb_agents[idx]);
        end
        return(tmpq);
    endfunction: get_dvm_msg_agents

    static function int get_snp_credits4agent(int agent_id);
        return(snp_credits_inflight[agent_id]);
    endfunction: get_snp_credits4agent

    static function int get_mrd_credits4agent(int dmi_id);
        int agent_id = dmi_id - NUM_COH_VISB_AIUS - NUM_DCES;
        return(mrd_credits_inflight[agent_id]);
    endfunction: get_mrd_credits4agent

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

    static function bit[ADDR_WIDTH-1:0] get_set_index(
        bit[ADDR_WIDTH-1:0] addr,
        int agent_id,
        int sf_id = 0);
  
        int lid, cid;
        ncore_unit_type_t utype;
        bit [W_SEC_ADDR -1:0] val;
        sel_bits_t bit_idxs;

        get_logical_uinfo(agent_id, lid, cid, utype);

        if (utype == AIU) begin
          `ASSERT(cbi_set_sel[lid].num_entries != 0);
          bit_idxs.pri_bits = new[cbi_set_sel[lid].num_pri_bits];
          bit_idxs.sec_bits = new[cbi_set_sel[lid].num_pri_bits];

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
          bit_idxs.pri_bits = new[cmc_set_sel[lid].num_pri_bits];
          bit_idxs.sec_bits = new[cmc_set_sel[lid].num_pri_bits];

          foreach (cmc_set_sel[lid].pri_bits[i]) begin
            bit_idxs.pri_bits[i] = cmc_set_sel[lid].pri_bits[i];

            if (cmc_set_sel[lid].sec_bits[i].size() > 0) begin
              bit_idxs.sec_bits[i] = new[cmc_set_sel[lid].sec_bits[i].size()];
              foreach (cmc_set_sel[lid].sec_bits[i,j])
                bit_idxs.sec_bits[i][j] = cmc_set_sel[lid].sec_bits[i][j];
            end
          end          
        end else begin
          `ASSERT(0, "Not yet implemented");
        end

        foreach (bit_idxs.pri_bits[i]) begin
          val[i] = addr[bit_idxs.pri_bits[i]];
          foreach (bit_idxs.sec_bits[i,j]) begin
            val[i] = val[i] ^ addr[bit_idxs.sec_bits[i][j]];
          end
        end

        return (val);
    endfunction: get_set_index


//---------------------------------------------------------------------------------
//address and alignment helper functions
//---------------------------------------------------------------------------------

//aligned address (msbs)
static function bit [W_SEC_ADDR -1: 0] aligned_addr(bit [W_SEC_ADDR -1: 0] addr, int shift);
    bit [W_SEC_ADDR -1: 0] mask = '1;
    return (addr & (mask << shift));
endfunction : aligned_addr

//bytes by which address is size_bytes unaligned.  (lsbs)
static function bit [W_SEC_ADDR -1: 0] addr_offset(bit [W_SEC_ADDR -1: 0] addr, int shift);
    bit [W_SEC_ADDR -1: 0] mask = '1;
    return (addr & ~(mask << shift));
endfunction : addr_offset                               

//address of the beginning of the cacheline which cmd is in
static function bit [W_SEC_ADDR -1: 0] cache_addr(bit [W_SEC_ADDR -1: 0] addr);
    return   aligned_addr(addr, WCACHE_OFFSET);
endfunction : cache_addr

//address of beginning of endpoint which cmd is in
static function bit [W_SEC_ADDR -1: 0] endpoint_addr(bit [W_SEC_ADDR -1: 0] addr, int unit_id);
    int dii_index[$] = diiIds.find_first_index with (item == unit_id);
    return aligned_addr(addr, wEndpoint[dii_index[0]]);
endfunction : endpoint_addr


////address of beginning of region which cmd is in
//// <0 iff invalid
//static function int region_addr(smi_seq_item cmd);    
//    int targ_id;                                                                                                         
    
//    //check inputs
//    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))

//    targ_id = addrMgrConst::map_addr2dmi(cmd.addr, cmd.smi_src_ncore_unit_id, region_addr); //sets the var 'region' by ref
//    if( targ_id < 0 )  region_addr = targ_id; //invalid target => invalid region
//    if( targ_id != cmd.smi_targ_ncore_unit_id )                                                                           
//        `uvm_error($sformatf("%m"), $sformatf("msg to region in a different unit: in unit %p\nmsg: %p", targ_id, cmd))   
//endfunction : region_addr

static function int agentid_assoc2funitid(int funitid);
  int q[$];

  q = funit_ids.find_index(x) with (x == funitid);

  if (q.size() == 0)
    `uvm_error("NCORE_CONFIG_INFO", $psprintf(
        "FunitId: %0d does not match with any value in config", funitid))

  if (q.size() > 1)
    `uvm_error("NCORE_CONFIG_INFO", $psprintf(
        "Multiple mathces for FunitId: %0d CONFIGURATION ERROR", funitid))

  return q[0];
endfunction: agentid_assoc2funitid

static function int get_aiu_funitid(int aiu_index);
  return funit_ids[aiu_index]; 
endfunction: get_aiu_funitid

static function int get_dce_funitid(int dce_index);
  return funit_ids[aiu_ids.size() + dce_index];
endfunction: get_dce_funitid

static function int get_dve_funitid(int dve_index);
  return funit_ids[aiu_ids.size() + dce_ids.size() + dve_index];
endfunction: get_dve_funitid

static function int get_dmi_funitid(int dmi_index);
  int index = aiu_ids.size() + dce_ids.size() + dve_ids.size() + dmi_index;
  return funit_ids[index];
endfunction: get_dmi_funitid
//DCDEBUG
static function int get_dii_funitid(int dii_index);
  int index = aiu_ids.size() + dce_ids.size() + dve_ids.size() +
              dmi_ids.size() + dii_index;
  return funit_ids[index];
endfunction: get_dii_funitid
endclass: addrMgrConst

