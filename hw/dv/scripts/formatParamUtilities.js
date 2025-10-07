const _ = require('lodash');
var slvId = 0;

function extAllIntrlvAgents(config) {
    var retObj = _.cloneDeep(config);
    var FUnitId = 0;
    slvId = 0;

    function setupUnits(blockName) {
        var infoName = blockName[0].toUpperCase() + blockName.substring(1) + "Info";  //e.g. AiuInfo
        var countName = "n" + blockName.toUpperCase() + "s";  //e.g. nAIUs 
//        var sharerCountName = "n" + blockName[0].toUpperCase() + blockName.substring(1) + "s";  //e.g. nAius 
        var sharerCountName = "";  //e.g. nAius 
        //console.log(infoName + "\t" + countName + "\t" + sharerCountName);

        //elaborate where similar instances share a memory region 
        retObj[infoName] = extIntrlvAgents(config[infoName], sharerCountName);

        //set vars for each unit of this type
        retObj[countName] = 0;
        retObj[infoName].forEach(function(unit, index) {
            retObj.nUnits ++; //count of units in config
            retObj[countName]++;
        if(config.instanceMap && !config.dontUseInstanceName)
        unit.moduleName = config.instanceMap[unit.strRtlNamePrefix];
            unit.Block = blockName;                              
            unit.Id    = index;                                  
        if(config.instanceMap && !config.dontUseInstanceName)
        unit.BlockId = unit.strRtlNamePrefix;
        unit.nSmiTx = unit.smiPortParams.tx.length;  
            unit.nSmiRx = unit.smiPortParams.rx.length;  
        retObj.Clocks.forEach(function(clk,i) {
        if(clk.name == unit.unitClk[0])
            unit.clkPeriodPs = clk.params.period;
        });
        if(unit.clkPeriodPs === undefined)
        throw new Error("ERROR! clk " + unit.unitClk[0] + " not found!");

        });

    }

    //----------------------------------------------------------------------------------
   //

    retObj.AiuInfo.sort(   //order by snoop filter
        function (a, b) { return (a.nUnitId > b.nUnitId) ? 1 : -1 ; }   
    );

    retObj.DceInfo.sort(   //order by snoop filter
        function (a, b) { return (a.nUnitId > b.nUnitId) ? 1 : -1 ; }   
    );

    retObj.DmiInfo.sort(   //order by snoop filter
        function (a, b) { return (a.nUnitId > b.nUnitId) ? 1 : -1 ; }   
    );
    retObj.DiiInfo.sort(   //order by snoop filter
        function (a, b) { return (a.nUnitId > b.nUnitId) ? 1 : -1 ; }   
    );

    if ( retObj.GiuInfo && retObj.GiuInfo.length > 0 ) {
        retObj.GiuInfo.sort(   //order by snoop filter
            function ( a, b ) { return ( a.nUnitId > b.nUnitId ) ? 1 : -1 }
        )
    }

    retObj.DveInfo.sort(   //order by snoop filter
        function (a, b) { return (a.nUnitId > b.nUnitId) ? 1 : -1 ; }   
    );

    retObj.chiAiuIds = [];
    retObj.ioAiuIds  = [];
    retObj.AiuInfo.forEach(function(agent) {
        if((agent.fnNativeInterface == 'AXI4') || (agent.fnNativeInterface == 'ACE') || agent.fnNativeInterface == 'ACE5'
           || (agent.fnNativeInterface == 'ACE-LITE') || (agent.fnNativeInterface == 'ACELITE-E') || (agent.fnNativeInterface == 'AXI5')) {
            retObj.ioAiuIds.push(agent.FUnitId);
        }
        if((agent.fnNativeInterface === 'CHI-A') || (agent.fnNativeInterface === 'CHI-B')|| (agent.fnNativeInterface === 'CHI-E')) {
            retObj.chiAiuIds.push(agent.FUnitId);
        }
    });


    //elaborate all units (and count them)
    retObj.nUnits = 0;  // count of all units in system
    retObj.nMEMregions = retObj.DmiInfo.length;  //calculation depends on structure before expanding the DmiInfo  TODO v3.0 dmi can have multiple regions
    retObj.blockNames = [ 'aiu', 'dce', 'dmi', 'dii', 'dve' ];
    if ( retObj.GiuInfo && retObj.GiuInfo.length > 0 ) {
        retObj.blockNames.push( 'giu' )
    }
    retObj.blockNames.forEach( setupUnits );
    retObj.nAIUs = retObj.AiuInfo.length;
    retObj.nCHIs = retObj.AiuInfo.filter(unit => unit.fnNativeInterface.includes("CHI")).length;
    retObj.nIOAIUs = retObj.nAIUs - retObj.nCHIs;
    //elaborate csrs

    //elaborate ace
    var sysAceObj = topLevelParams(retObj);
    retObj['useSysAce'] = sysAceObj.isSysAce;
    retObj['useSysAceCache'] = sysAceObj.isSysAceCache;
    retObj['useSysAceProt'] =  sysAceObj.isSysAceProt;
    retObj['useSysAceQos'] = sysAceObj.isSysAceQos;
    retObj['useSysAceRegion'] = sysAceObj.isSysAceRegion;
    retObj['wSysAceUser'] = sysAceObj.wSysAceUser;
    retObj['useSysAceUser'] = sysAceObj.isSysAceUser;
    retObj['useSysAceDomain'] = sysAceObj.isSysAceDomain;
    retObj['useSysAceUnique'] = sysAceObj.isSysAceUnique;
    retObj['wSysAddr'] = sysAceObj.wSysAddr;

    return retObj;
}

const countChiAius = (aiuInfo) => {
    let cnt = 0;
    aiuInfo.forEach(unit => {
        if (unit.fnNativeInterface.includes("CHI")) cnt++;
    })
    return cnt;
}


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
function extIntrlvAgents(config, key, configObj) {
    var idx = 0;
    var agentObj = {};
    var agentArr = [];

    config.forEach(function(agent, index, array) {
        //console.log('name agent[key]' + agent.strRtlNamePrefix + ' ' + agent[key] + ' ' + key);
        if(agent[key] > 1) {

            for(idx = 0; idx < agent[key]; idx++) {
                agentObj = _.cloneDeep(agent);
                agentObj.logicalId = index;
                //      agentObj.strRtlNamePrefix = agent.strRtlNamePrefix + index
                agentObj.strRtlNamePrefix = agent.strRtlNamePrefix
                    // if((typeof(configObj) !== 'undefined') && (configObj.bridgeAiu)) {
                    //     agentObj.logicalId += configObj.startLogicalId;
                    // }
                    agentObj.interleavedAgent = (idx == 0) ? 0 : 1
                    //                if(idx == 0) { agentObj.interleavedAgent = 0; }
                    //                else { agentObj.interleavedAgent = 1; }
                    agentObj.aiu_index = idx;
                agentObj.SlvId = slvId;
                slvId++;
                agentArr.push(agentObj);
            }
        } else {
            agentObj = _.cloneDeep(agent);
            agentObj.logicalId = index;
            // if((typeof(configObj) !== 'undefined') && (configObj.bridgeAiu)) {
            //     agentObj.logicalId += configObj.startLogicalId;
            // }
            agentObj.interleavedAgent = 0;
            agentObj.SlvId = slvId;
            slvId++;
            agentArr.push(agentObj);
        }  

    });

    //console.log('count + %d', agentArr.length);
    return(agentArr);
}

function topLevelParams(config) {
    var topParamsObj = {};

    topParamsObj.isSysAce = 0;
    topParamsObj.isSysAceCache = 0;
    topParamsObj.isSysAceProt = 0;
    topParamsObj.isSysAceQos = 0;
    topParamsObj.isSysAceRegion = 0;
    topParamsObj.isSysAceDomain = 0;
    topParamsObj.isSysAceUnique = 0;
    topParamsObj.wSysAceUser = 0;
    topParamsObj.isSysAceUser = 0;
//    topParamsObj.wSysAddr     = config['AiuInfo'][0].wAddr;
    topParamsObj.wSysAddr     = config.wSysAddr;

    for(var indx = 0; indx < config['AiuInfo'].length; indx++) {
        if(config['AiuInfo'][indx].fnNativeInterface === 'ACE' || config['AiuInfo'][indx].fnNativeInterface === 'ACE5') {
            topParamsObj.isSysAce = 1;
        if (Array.isArray(config['AiuInfo'][indx].interfaces.axiInt)) {
            if(config['AiuInfo'][indx].interfaces.axiInt[0].params.useAceCache) {
                topParamsObj.isSysAceCache = 1;
            }

            if(config['AiuInfo'][indx].interfaces.axiInt[0].params.wProt > 0) {
                topParamsObj.isSysAceProt = 1;
            }

            if(config['AiuInfo'][indx].interfaces.axiInt[0].params.wQos > 0) {
                topParamsObj.isSysAceQos = 1;
            }

            if(config['AiuInfo'][indx].interfaces.axiInt[0].params.wRegion > 0) {
                topParamsObj.isSysAceRegion = 1;
            }
            if(config['AiuInfo'][indx].interfaces.axiInt[0].params.useAceDomain) {
                topParamsObj.isSysAceDomain = 1;
            }
            if(config['AiuInfo'][indx].interfaces.axiInt[0].params.useAceUnique) {
                topParamsObj.isSysAceUnique = 1;
            }
        } else {
            if(config['AiuInfo'][indx].interfaces.axiInt.params.useAceCache) {
                topParamsObj.isSysAceCache = 1;
            }

            if(config['AiuInfo'][indx].interfaces.axiInt.params.wProt > 0) {
                topParamsObj.isSysAceProt = 1;
            }

            if(config['AiuInfo'][indx].interfaces.axiInt.params.wQos > 0) {
                topParamsObj.isSysAceQos = 1;
            }

            if(config['AiuInfo'][indx].interfaces.axiInt.params.wRegion > 0) {
                topParamsObj.isSysAceRegion = 1;
            }
            if(config['AiuInfo'][indx].interfaces.axiInt.params.useAceDomain) {
                topParamsObj.isSysAceDomain = 1;
            }
            if(config['AiuInfo'][indx].interfaces.axiInt.params.useAceUnique) {
                topParamsObj.isSysAceUnique = 1;
            }
        }
        }
    }
    topParamsObj.wSysAceUser = aceUserMaxWidth(config);
    topParamsObj.isSysAceUser = isAceUser(topParamsObj.wSysAceUser);


    return(topParamsObj);
}

function aceUserMaxWidth(config) {
    var maxAgentWidth    = 0;
    var agentInfoParams  = config['AiuInfo'];

    //Iterate through agentAiuIno object
      maxAgentWidth  = _aceUserMaxWidth(agentInfoParams);

    return(maxAgentWidth);
}
function _aceUserMaxWidth(unitObj) {
    var maxWidth  = 0;

    for(var indx = 0; indx < unitObj.length; indx++) {
    if(unitObj[indx].fnNativeInterface == 'InterfaceAXI'){
        if(maxWidth < unitObj[indx].interfaces.axiInt[0].params.wAwUser) {
            maxWidth = unitObj[indx].interfaces.axiInt[0].params.wAwUser; 
        }

        if(maxWidth < unitObj[indx].interfaces.axiInt[0].params.wArUser) {
            maxWidth = unitObj[indx].interfaces.axiInt[0].params.wArUser; 
        }

        if(maxWidth < unitObj[indx].interfaces.axiInt[0].params.wWUser) {
            maxWidth = unitObj[indx].interfaces.axiInt[0].params.wWUser; 
        }

        if(maxWidth < unitObj[indx].interfaces.axiInt[0].params.wBUser) {
            maxWidth = unitObj[indx].interfaces.axiInt[0].params.wBUser; 
        }
        if(maxWidth < unitObj[indx].interfaces.axiInt[0].params.wRUser) {
            maxWidth = unitObj[indx].interfaces.axiInt[0].params.wRUser; 
        }
    }
    }
    return(maxWidth);
}
function isAceUser(value) {
    if(value) { return(1); }
    else      { return(0); }
}


function unitFuncKeepSmiArr(unitParam, pkgParams) {
    //flatten this unit vars into root
    var tempUnitParam = _.cloneDeep(pkgParams);
    tempUnitParam['smiPortParams']       = unitParam['smiPortParams'];
    tempUnitParam['interfaces']          = unitParam['interfaces'];
    tempUnitParam['CsrInfo']             = unitParam['CsrInfo'];
    tempUnitParam['concParams']          = unitParam['concParams'];

    node_traverse(unitParam, 'root', function(hier, child_obj) {
        for(var prop in child_obj) {
            tempUnitParam[prop] = child_obj[prop];
        }
    });

    //elaborate smi widths 
    tempUnitParam.smiObj = extractSmiWidths(tempUnitParam);  
    checkParams(tempUnitParam, tempUnitParam.unitRtlParams);
    tempUnitParam.smiMsgObj = extractSmiMsgFields(tempUnitParam.smiObj);  


    //DCNOTES if BlockId is defined here, the name of the generated files 
    //will be strRtlNamePrefix_*.v
    //if it is not, it will take the "name" field of its dvPkg.json (e.g. ioaiu)
    //for dv/ioaiu/env/dvPkg.json
    //console.log('dontUseInstanceName = ' + pkgParams.dontUseInstanceName); //clearing
//    if(pkgParams.instanceMap && !pkgParams.dontUseInstanceName)
    if(pkgParams.instanceMap && !pkgParams.dontUseInstanceName)
    tempUnitParam.BlockId = unitParam.strRtlNamePrefix;

    return tempUnitParam;
}


function node_traverse(node, hier, action) {
    var _child = {};

    for(var mem in node) {
        if(typeof(node[mem]) == 'object') {

            if(Object.keys(_child).length != 0 ) {
                _child = guardedBundle(hier, _child);
                action(hier, _child);
                _child = {};
            }
            hier = hier + '/' + mem;
            //console.log('1 ' + hier);
            node_traverse(node[mem], hier, action);

            var _arr = hier.split('/');
            if(_arr.length > 1)
                _arr.pop();

            hier = _arr.join('/');          
            //console.log('2 ' + hier);
        }
        else
            _child[mem] = node[mem];
    }
    //if(hier.match('CON')) {
    //    console.log(_child);
    //    throw 'err';
    // }
    if(Object.keys(_child).length != 0) {
        _child = guardedBundle(hier, _child);
        action(hier, _child);
    }
}
function guardedBundle(hier, bundle) {

    var searchExp = /(ifdef|ifndef)\s(\S+)\s/g;
    var exit = false;
    var retEmptyObj = false;
    var emptyObj = {};
    var matchList = [];

    do {
        matchList = searchExp.exec(hier);

        if(matchList === null) {
            exit = true;
        } else if(matchList[1] === 'ifdef') {
            if(!exists(matchList[2], cli.defines)) {
                retEmptyObj = true;
                exit = true;
            }
        } else if(matchList[1] === 'ifndef') {
            if(!not_exists(matchList[2], cli.defines)) {
                retEmptyObj = true;
                exit = true;
            }
        } else {
            console.log(matchList);
            throw 'Unexpected loop entered';
        }
    } while((exit === false)&&(matchList !== null));

    if(retEmptyObj) { return(emptyObj); }
    else { return(bundle); }
};


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//same interface widths across entire system
function extractSmiWidths(config) {

    smiObj = {};

    //sys toplevel params
    smiObj.WSEC                   = config.wSecurityAttribute;
    smiObj.CACHELINESIZE          = Math.pow(2, config.wCacheLineOffset);
    smiObj.WNUNITID               = config.wNUnitId;

    //Physical Layer
    smiObj.WSMINDPLEN             = config.Widths.Physical.wNdpLen;   
    smiObj.WSMINDP                = config.Widths.Physical.wNdpBody;    //TODO: ndp body has sizeof largest ndp ?== cmd  
    smiObj.WSMIDPPRESENT          = config.Widths.Physical.wDpPresent;
    
    //Transport Layer
    smiObj.WSMIMSGERR             = config.Widths.Transport.wMsgErr;  //exists only from legato towards DUT


    //Concerto Layer
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //NDP Header
    smiObj.WSMINCOREUNITID        = config.Widths.Concerto.Ndp.Header.wFUnitId ;
    smiObj.WSMINCOREPORTID = config.Widths.Concerto.Ndp.Header.wFPortId;
    // add wLinkId and wChipletId for 3.8.  These will be 0 for single chip designs.
    smiObj.WSMINCORELINKID        = config.Widths.Concerto.Ndp.Header.wLinkId;
    smiObj.WSMINCORECHIPLETID     = config.Widths.Concerto.Ndp.Header.wChipletId;
    smiObj.WSMITGTID              = smiObj.WSMINCOREUNITID + smiObj.WSMINCOREPORTID + smiObj.WSMINCORELINKID + smiObj.WSMINCORECHIPLETID;
    smiObj.WSMISRCID              = smiObj.WSMINCOREUNITID + smiObj.WSMINCOREPORTID + smiObj.WSMINCORELINKID + smiObj.WSMINCORECHIPLETID;
    smiObj.WSMIMSGTYPE            = config.Widths.Concerto.Ndp.Header.wCmType     ;
    smiObj.WSMIMSGID              = config.Widths.Concerto.Ndp.Header.wMsgId      ;
    smiObj.WSMIMSGUSER            = config.Widths.Concerto.Ndp.Header.wHProt     //presently only h_prot is encoded in header user field ;
    smiObj.WSMIHPROT              = config.Widths.Concerto.Ndp.Header.wHProt      ;
    smiObj.WSMIMSGTIER            = config.Widths.Concerto.Ndp.Header.wTTier      ;
    smiObj.WSMISTEER              = config.Widths.Concerto.Ndp.Header.wSteering   ;
    smiObj.WSMIMSGPRI             = config.Widths.Concerto.Ndp.Header.wPriority   ;
    smiObj.WSMIMSGQOS             = config.Widths.Concerto.Ndp.Header.wQl         ;

    //DV only constructs
    smiObj.WSMICONCMSGCLASS       = 6; 
    smiObj.WSMIUNQIDENTIFIER      = smiObj.WSMINCOREUNITID + smiObj.WSMINCOREPORTID + smiObj.WSMIMSGID + smiObj.WSMICONCMSGCLASS;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //NDP Body
    //specify all possible fields in payloads; smi packing fn will select which exist in a given req type 
    smiObj.WSMICMSTATUS           = config.Widths.Concerto.Ndp.Body.wCmStatus ;
    smiObj.WSMIADDR               = config.Widths.Concerto.Ndp.Body.wAddr    ;
    smiObj.WSMIVZ                 = config.Widths.Concerto.Ndp.Body.wVZ      ;
    smiObj.WSMIAC                 = config.Widths.Concerto.Ndp.Body.wAC      ;
    smiObj.WSMICA                 = config.Widths.Concerto.Ndp.Body.wCA      ;
    smiObj.WSMICH                 = config.Widths.Concerto.Ndp.Body.wCH      ;
    smiObj.WSMIST                 = config.Widths.Concerto.Ndp.Body.wST      ;
    smiObj.WSMIEN                 = config.Widths.Concerto.Ndp.Body.wEN      ;
    smiObj.WSMIES                 = config.Widths.Concerto.Ndp.Body.wES      ;
    smiObj.WSMINS                 = config.Widths.Concerto.Ndp.Body.wNS      ;
    smiObj.WSMIPR                 = config.Widths.Concerto.Ndp.Body.wPR      ;
    smiObj.WSMIMW                 = config.Widths.Concerto.Ndp.Body.wMW      ;
    smiObj.WSMIUP                 = config.Widths.Concerto.Ndp.Body.wUP      ;
    smiObj.WSMIORDER              = config.Widths.Concerto.Ndp.Body.wOR      ;
    smiObj.WSMILK                 = config.Widths.Concerto.Ndp.Body.wLK      ;
    smiObj.WSMIRL                 = config.Widths.Concerto.Ndp.Body.wRL      ;
    smiObj.WSMITM                 = config.Widths.Concerto.Ndp.Body.wTM ;
    smiObj.WSMIPRIMARY            = config.Widths.Concerto.Ndp.Body.wPrimary ;
    smiObj.WSMIMBR                = config.Widths.Concerto.Ndp.Body.wMergeBufferReserved ;
    smiObj.WSMIMPF1               = config.Widths.Concerto.Ndp.Body.wMpf1    ;
    smiObj.WSMIMPF2               = config.Widths.Concerto.Ndp.Body.wMpf2    ;
    smiObj.WSMIMPF3               = config.Widths.Concerto.Ndp.Body.wMpf3    ;
    smiObj.WSMISIZE               = config.Widths.Concerto.Ndp.Body.wSize    ;
    smiObj.WSMIINTFSIZE           = config.Widths.Concerto.Ndp.Body.wIntfSize ;
    smiObj.WSMIDESTID             = config.Widths.Concerto.Ndp.Body.wDId     ;
    smiObj.WSMIRBID               = config.Widths.Concerto.Ndp.Body.wRBId ;
    smiObj.WSMIRTYPE              = config.Widths.Concerto.Ndp.Body.wRType ;
    smiObj.WSMIRBGEN              = config.Widths.Concerto.Ndp.Body.wRBGen;
    smiObj.WSMITOF                = config.Widths.Concerto.Ndp.Body.wTof     ;
    smiObj.WSMIQOS                = config.Widths.Concerto.Ndp.Body.wQos     ;
    smiObj.WSMINDPAUX             = config.Widths.Concerto.Ndp.Body.wNdpAux  ;
    smiObj.WSMINDPPROT            = config.Widths.Concerto.Ndp.Body.wNdpProt ;
    smiObj.WSMISYSREQOP           = config.Widths.Concerto.Ndp.Body.wSysReqOp ;
    smiObj.WSMIREQUESTORID        = config.Widths.Concerto.Ndp.Body.wRequestorId ;

    //  NDP body multipurpose field encodings.

    // encodings in cmstatus.  bit positions as well as widths
    smiObj.WSMICMSTATUSERR        = config.Widths.Concerto.Ndp.Body.CmStatus.wErr;  
    smiObj.WSMICMSTATUSERRPAYLOAD = smiObj.WSMICMSTATUS - smiObj.WSMICMSTATUSERR;
    //
    smiObj.SMICMSTATUSERRBIT      = config.Widths.Concerto.Ndp.Body.CmStatus.Err;
    //err == 1 : error
        //TODO? err type field [6]
        //errtype == 1 : concerto err
            //CMStatus[5:0] = Concerto C Reported Error Codes.
            //TODO? test the err codes?  encoding see csymlayers
        //errtype == 0 : transport err
            smiObj.WSMICMSTATUSST         = config.Widths.Concerto.Ndp.Body.CmStatus.wST ;
            smiObj.WSMICMSTATUSSD         = config.Widths.Concerto.Ndp.Body.CmStatus.wSD ;
            smiObj.WSMICMSTATUSSS         = config.Widths.Concerto.Ndp.Body.CmStatus.wSS ;
            smiObj.WSMICMSTATUSSO         = config.Widths.Concerto.Ndp.Body.CmStatus.wSO ;
            //
            smiObj.SMICMSTATUSSTRREQST    = config.Widths.Concerto.Ndp.Body.CmStatus.StrReqST ;
            smiObj.SMICMSTATUSSTRREQSD    = config.Widths.Concerto.Ndp.Body.CmStatus.StrReqSD ;
            smiObj.SMICMSTATUSSTRREQSS    = config.Widths.Concerto.Ndp.Body.CmStatus.StrReqSS ;
            smiObj.SMICMSTATUSSTRREQSO    = config.Widths.Concerto.Ndp.Body.CmStatus.StrReqSO ;
    //err == 0 : success
        //cmd type == snprsp
            smiObj.WSMICMSTATUSSNARF      = config.Widths.Concerto.Ndp.Body.CmStatus.wSnarf ;
            smiObj.WSMICMSTATUSDTDMI      = config.Widths.Concerto.Ndp.Body.CmStatus.wDTDMI ;
            smiObj.WSMICMSTATUSDTAIU      = config.Widths.Concerto.Ndp.Body.CmStatus.wDTAIU ;
            smiObj.WSMICMSTATUSDC         = config.Widths.Concerto.Ndp.Body.CmStatus.wDC ;
            smiObj.WSMICMSTATUSRS         = config.Widths.Concerto.Ndp.Body.CmStatus.wRS ;
            smiObj.WSMICMSTATUSRV         = config.Widths.Concerto.Ndp.Body.CmStatus.wRV ;
            //
            smiObj.SMICMSTATUSSNPRSPSNARF = config.Widths.Concerto.Ndp.Body.CmStatus.SnpRspSnarf ;
            smiObj.SMICMSTATUSSNPRSPDTDMI = config.Widths.Concerto.Ndp.Body.CmStatus.SnpRspDTDMI ;
            smiObj.SMICMSTATUSSNPRSPDTAIU = config.Widths.Concerto.Ndp.Body.CmStatus.SnpRspDTAIU ;
            smiObj.SMICMSTATUSSNPRSPDC    = config.Widths.Concerto.Ndp.Body.CmStatus.SnpRspDC ;
            smiObj.SMICMSTATUSSNPRSPRS    = config.Widths.Concerto.Ndp.Body.CmStatus.SnpRspRS ;
            smiObj.SMICMSTATUSSNPRSPRV    = config.Widths.Concerto.Ndp.Body.CmStatus.SnpRspRV ;
        //cmd type == strreq for rd
            //CMStatus[3:0] = Widths.Concerto.Ndp.Body.CmStatus.SO, SS, SD, ST , same as in err case ;
        //cmd type == strreq for stash
            //smiObj.WSMICMSTATUSSNARF      = config.Widths.Concerto.Ndp.Body.CmStatus.Snarf;    //duplicate ;
            //
            smiObj.SMICMSTATUSSTRREQSNARF = config.Widths.Concerto.Ndp.Body.CmStatus.StrReqSnarf ;
        //cmd type == strreq for clnunq
            smiObj.WSMICMSTATUSEXOK       = config.Widths.Concerto.Ndp.Body.CmStatus.wExOK ;
            //
            smiObj.SMICMSTATUSSTRREQEXOK  = config.Widths.Concerto.Ndp.Body.CmStatus.StrReqExOK ;


    // mpf1 encoding

    smiObj.WSMISTASHVALID         = config.Widths.Concerto.Ndp.Body.Mpf1.wStashValid ;
    smiObj.WSMISTASHNID           = config.Widths.Concerto.Ndp.Body.Mpf1.wStashNId ;  

    smiObj.WSMIARGV               = config.Widths.Concerto.Ndp.Body.Mpf1.wArgV ;
    smiObj.WSMIBURSTTYPE          = config.Widths.Concerto.Ndp.Body.Mpf1.wBurstType ;
    smiObj.WSMIASIZE              = config.Widths.Concerto.Ndp.Body.Mpf1.wASize ;
    smiObj.WSMIALENGTH            = config.Widths.Concerto.Ndp.Body.Mpf1.wALength ;


    // mpf2 encoding

    smiObj.WSMISTASHLPIDVALID     = config.Widths.Concerto.Ndp.Body.Mpf2.wStashLPIdValid ;
    smiObj.WSMISTASHLPID          = config.Widths.Concerto.Ndp.Body.Mpf2.wStashLPId ; 
    
    smiObj.WSMIFLOWIDVALID        = config.Widths.Concerto.Ndp.Body.Mpf2.wStashLPIdValid ;
    smiObj.WSMIFLOWID             = config.Widths.Concerto.Ndp.Body.Mpf2.wFlowId ;


    //mpf3 has only 1 encoding


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //DP Data for this unit
    smiObj.WSMIDPDATA          = config.Widths.Concerto.Dp.Data.wDpData ;    //flattened from this unit
    //DP Aux (= SMI DP User)
    smiObj.WSMIDPBEPERDW       = config.Widths.Concerto.Dp.Aux.wBePerDW; 
    smiObj.WSMIDPPROTPERDW     = config.Widths.Concerto.Dp.Aux.wProtPerDW;
    smiObj.WSMIDPDWIDPERDW     = config.Widths.Concerto.Dp.Aux.wDWIdPerDW;
    smiObj.WSMIDPDBADPERDW     = config.Widths.Concerto.Dp.Aux.wDBadPerDW;
    smiObj.WSMIDPCONCUSERPERDW = config.Widths.Concerto.Dp.Aux.wDpAux;
    smiObj.WSMIDPUSERPERDW     = smiObj.WSMIDPBEPERDW + smiObj.WSMIDPPROTPERDW + smiObj.WSMIDPDWIDPERDW + smiObj.WSMIDPDBADPERDW + smiObj.WSMIDPCONCUSERPERDW ;     //sum of its fields 
    //per beat       
    smiObj.WSMIDPBE            = smiObj.WSMIDPBEPERDW * Math.ceil(smiObj.WSMIDPDATA / 64);
    smiObj.WSMIDPPROT          = smiObj.WSMIDPPROTPERDW * Math.ceil(smiObj.WSMIDPDATA / 64);    
    smiObj.WSMIDPDWID          = smiObj.WSMIDPDWIDPERDW * Math.ceil(smiObj.WSMIDPDATA / 64);      
    smiObj.WSMIDPDBAD          = smiObj.WSMIDPDBADPERDW * Math.ceil(smiObj.WSMIDPDATA / 64);
    smiObj.WSMIDPCONCUSER      = smiObj.WSMIDPCONCUSERPERDW * Math.ceil(smiObj.WSMIDPDATA / 64);
    smiObj.WSMIDPUSER          = smiObj.WSMIDPUSERPERDW * Math.ceil(smiObj.WSMIDPDATA / 64);

    return smiObj ;

}


function extractSmiMsgFields(smiObj) {

    var smiMsgObj      = {};

    // Creating Concerto message fields

    // CmdReq
    smiMsgObj.W_CMD_REQ_NDP                  = 0;
    smiMsgObj.CMD_REQ_TM_LSB        = 0;
    smiMsgObj.CMD_REQ_TM_MSB        = smiMsgObj.CMD_REQ_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMITM ;
    smiMsgObj.CMD_REQ_CMSTATUS_LSB  = ((smiObj.WSMITM == 0) ? smiMsgObj.CMD_REQ_TM_LSB : smiMsgObj.CMD_REQ_TM_MSB + 1);
    smiMsgObj.CMD_REQ_CMSTATUS_MSB  = smiMsgObj.CMD_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS - ((smiObj.WSMICMSTATUS > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.CMD_REQ_ADDR_LSB      = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.CMD_REQ_CMSTATUS_LSB: smiMsgObj.CMD_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.CMD_REQ_ADDR_MSB      = smiMsgObj.CMD_REQ_ADDR_LSB + smiObj.WSMIADDR - ((smiObj.WSMIADDR > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIADDR ;
    smiMsgObj.CMD_REQ_VZ_LSB        = ((smiObj.WSMIADDR == 0) ? smiMsgObj.CMD_REQ_ADDR_LSB : smiMsgObj.CMD_REQ_ADDR_MSB + 1);
    smiMsgObj.CMD_REQ_VZ_MSB        = smiMsgObj.CMD_REQ_VZ_LSB + smiObj.WSMIVZ - ((smiObj.WSMIVZ > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIVZ ;
    smiMsgObj.CMD_REQ_CA_LSB        = ((smiObj.WSMIVZ == 0) ? smiMsgObj.CMD_REQ_VZ_LSB : smiMsgObj.CMD_REQ_VZ_MSB + 1);
    smiMsgObj.CMD_REQ_CA_MSB        = smiMsgObj.CMD_REQ_CA_LSB + smiObj.WSMICA - ((smiObj.WSMICA > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMICA ;
    smiMsgObj.CMD_REQ_AC_LSB        = ((smiObj.WSMICA == 0) ? smiMsgObj.CMD_REQ_CA_LSB : smiMsgObj.CMD_REQ_CA_MSB + 1);
    smiMsgObj.CMD_REQ_AC_MSB        = smiMsgObj.CMD_REQ_AC_LSB + smiObj.WSMIAC - ((smiObj.WSMIAC > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIAC ;
    smiMsgObj.CMD_REQ_CH_LSB        = ((smiObj.WSMIAC == 0) ? smiMsgObj.CMD_REQ_AC_LSB : smiMsgObj.CMD_REQ_AC_MSB + 1);
    smiMsgObj.CMD_REQ_CH_MSB        = smiMsgObj.CMD_REQ_CH_LSB + smiObj.WSMICH - ((smiObj.WSMICH > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMICH ;
    smiMsgObj.CMD_REQ_ST_LSB        = ((smiObj.WSMICH == 0) ? smiMsgObj.CMD_REQ_CH_LSB : smiMsgObj.CMD_REQ_CH_MSB + 1);
    smiMsgObj.CMD_REQ_ST_MSB        = smiMsgObj.CMD_REQ_ST_LSB + smiObj.WSMIST - ((smiObj.WSMIST > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIST ;
    smiMsgObj.CMD_REQ_EN_LSB        = ((smiObj.WSMIST == 0) ? smiMsgObj.CMD_REQ_ST_LSB : smiMsgObj.CMD_REQ_ST_MSB + 1);
    smiMsgObj.CMD_REQ_EN_MSB        = smiMsgObj.CMD_REQ_EN_LSB + smiObj.WSMIEN - ((smiObj.WSMIEN > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIEN ;
    smiMsgObj.CMD_REQ_ES_LSB        = ((smiObj.WSMIEN == 0) ? smiMsgObj.CMD_REQ_EN_LSB : smiMsgObj.CMD_REQ_EN_MSB + 1);
    smiMsgObj.CMD_REQ_ES_MSB        = smiMsgObj.CMD_REQ_ES_LSB + smiObj.WSMIES - ((smiObj.WSMIES > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIES ;
    smiMsgObj.CMD_REQ_NS_LSB        = ((smiObj.WSMIES == 0) ? smiMsgObj.CMD_REQ_ES_LSB : smiMsgObj.CMD_REQ_ES_MSB + 1);
    smiMsgObj.CMD_REQ_NS_MSB        = smiMsgObj.CMD_REQ_NS_LSB + smiObj.WSMINS - ((smiObj.WSMINS > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMINS ;
    smiMsgObj.CMD_REQ_PR_LSB        = ((smiObj.WSMINS == 0) ? smiMsgObj.CMD_REQ_NS_LSB : smiMsgObj.CMD_REQ_NS_MSB + 1);
    smiMsgObj.CMD_REQ_PR_MSB        = smiMsgObj.CMD_REQ_PR_LSB + smiObj.WSMIPR - ((smiObj.WSMIPR > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIPR ;
    smiMsgObj.CMD_REQ_OR_LSB        = ((smiObj.WSMIPR == 0) ? smiMsgObj.CMD_REQ_PR_LSB : smiMsgObj.CMD_REQ_PR_MSB + 1);
    smiMsgObj.CMD_REQ_OR_MSB        = smiMsgObj.CMD_REQ_OR_LSB + smiObj.WSMIORDER - ((smiObj.WSMIORDER > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIORDER ;
    smiMsgObj.CMD_REQ_LK_LSB        = ((smiObj.WSMIORDER == 0) ? smiMsgObj.CMD_REQ_OR_LSB : smiMsgObj.CMD_REQ_OR_MSB + 1);
    smiMsgObj.CMD_REQ_LK_MSB        = smiMsgObj.CMD_REQ_LK_LSB + smiObj.WSMILK - ((smiObj.WSMILK > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMILK ;
    smiMsgObj.CMD_REQ_RL_LSB        = ((smiObj.WSMILK == 0) ? smiMsgObj.CMD_REQ_LK_LSB : smiMsgObj.CMD_REQ_LK_MSB + 1);
    smiMsgObj.CMD_REQ_RL_MSB        = smiMsgObj.CMD_REQ_RL_LSB + smiObj.WSMIRL - ((smiObj.WSMIRL > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIRL ;
    smiMsgObj.CMD_REQ_MPF1_LSB      = ((smiObj.WSMIRL == 0) ? smiMsgObj.CMD_REQ_RL_LSB : smiMsgObj.CMD_REQ_RL_MSB + 1);
    smiMsgObj.CMD_REQ_MPF1_MSB      = smiMsgObj.CMD_REQ_MPF1_LSB + smiObj.WSMIMPF1 - ((smiObj.WSMIMPF1 > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIMPF1 ;
    smiMsgObj.CMD_REQ_MPF2_LSB      = ((smiObj.WSMIMPF1 == 0) ? smiMsgObj.CMD_REQ_MPF1_LSB : smiMsgObj.CMD_REQ_MPF1_MSB + 1);
    smiMsgObj.CMD_REQ_MPF2_MSB      = smiMsgObj.CMD_REQ_MPF2_LSB + smiObj.WSMIMPF2 - ((smiObj.WSMIMPF2 > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIMPF2 ;
    smiMsgObj.CMD_REQ_SIZE_LSB      = ((smiObj.WSMIMPF2 == 0) ? smiMsgObj.CMD_REQ_MPF2_LSB : smiMsgObj.CMD_REQ_MPF2_MSB + 1);
    smiMsgObj.CMD_REQ_SIZE_MSB      = smiMsgObj.CMD_REQ_SIZE_LSB + smiObj.WSMISIZE - ((smiObj.WSMISIZE > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMISIZE ;
    smiMsgObj.CMD_REQ_INTF_SIZE_LSB = ((smiObj.WSMISIZE == 0) ? smiMsgObj.CMD_REQ_SIZE_LSB : smiMsgObj.CMD_REQ_SIZE_MSB + 1);
    smiMsgObj.CMD_REQ_INTF_SIZE_MSB = smiMsgObj.CMD_REQ_INTF_SIZE_LSB + smiObj.WSMIINTFSIZE - ((smiObj.WSMIINTFSIZE > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP             += smiObj.WSMIINTFSIZE ;
    smiMsgObj.CMD_REQ_DEST_ID_LSB   = ((smiObj.WSMIINTFSIZE == 0) ? smiMsgObj.CMD_REQ_INTF_SIZE_LSB : smiMsgObj.CMD_REQ_INTF_SIZE_MSB + 1);
    smiMsgObj.CMD_REQ_DEST_ID_MSB   = smiMsgObj.CMD_REQ_DEST_ID_LSB + smiObj.WSMIDESTID - ((smiObj.WSMIDESTID > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP             += smiObj.WSMIDESTID ;
    smiMsgObj.CMD_REQ_TOF_LSB       = ((smiObj.WSMIDESTID == 0) ? smiMsgObj.CMD_REQ_DEST_ID_LSB : smiMsgObj.CMD_REQ_DEST_ID_MSB + 1);
    smiMsgObj.CMD_REQ_TOF_MSB       = smiMsgObj.CMD_REQ_TOF_LSB + smiObj.WSMITOF - ((smiObj.WSMITOF > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMITOF ;
    smiMsgObj.CMD_REQ_QOS_LSB       = ((smiObj.WSMITOF == 0) ? smiMsgObj.CMD_REQ_TOF_LSB : smiMsgObj.CMD_REQ_TOF_MSB + 1);
    smiMsgObj.CMD_REQ_QOS_MSB       = smiMsgObj.CMD_REQ_QOS_LSB + smiObj.WSMIQOS - ((smiObj.WSMIQOS > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP         += smiObj.WSMIQOS ;
    smiMsgObj.CMD_REQ_NDP_AUX_LSB   = ((smiObj.WSMIQOS == 0) ? smiMsgObj.CMD_REQ_QOS_LSB : smiMsgObj.CMD_REQ_QOS_MSB + 1);
    smiMsgObj.CMD_REQ_NDP_AUX_MSB   = smiMsgObj.CMD_REQ_NDP_AUX_LSB + smiObj.WSMINDPAUX - ((smiObj.WSMINDPAUX > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP             += smiObj.WSMINDPAUX ;
    smiMsgObj.CMD_REQ_NDP_PROT_LSB  = ((smiObj.WSMINDPAUX == 0) ? smiMsgObj.CMD_REQ_NDP_AUX_LSB : smiMsgObj.CMD_REQ_NDP_AUX_MSB + 1);
    smiMsgObj.CMD_REQ_NDP_PROT_MSB  = smiMsgObj.CMD_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_CMD_REQ_NDP             += smiObj.WSMINDPPROT ;

    //SnpReq
    smiMsgObj.W_SNP_REQ_NDP                  = 0;
    smiMsgObj.SNP_REQ_TM_LSB        = 0;
    smiMsgObj.SNP_REQ_TM_MSB        = smiMsgObj.SNP_REQ_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMITM ;
    smiMsgObj.SNP_REQ_CMSTATUS_LSB  = ((smiObj.WSMITM == 0) ? smiMsgObj.SNP_REQ_TM_LSB : smiMsgObj.SNP_REQ_TM_MSB + 1);
    smiMsgObj.SNP_REQ_CMSTATUS_MSB  = smiMsgObj.SNP_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS - ((smiObj.WSMICMSTATUS > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.SNP_REQ_ADDR_LSB      = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.SNP_REQ_CMSTATUS_LSB: smiMsgObj.SNP_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.SNP_REQ_ADDR_MSB      = smiMsgObj.SNP_REQ_ADDR_LSB + smiObj.WSMIADDR - ((smiObj.WSMIADDR > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMIADDR ;
    smiMsgObj.SNP_REQ_VZ_LSB        = ((smiObj.WSMIADDR == 0) ? smiMsgObj.SNP_REQ_ADDR_LSB : smiMsgObj.SNP_REQ_ADDR_MSB + 1);
    smiMsgObj.SNP_REQ_VZ_MSB        = smiMsgObj.SNP_REQ_VZ_LSB + smiObj.WSMIVZ - ((smiObj.WSMIVZ > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMIVZ ;
    smiMsgObj.SNP_REQ_CA_LSB        = ((smiObj.WSMIVZ == 0) ? smiMsgObj.SNP_REQ_VZ_LSB : smiMsgObj.SNP_REQ_VZ_MSB + 1);
    smiMsgObj.SNP_REQ_CA_MSB        = smiMsgObj.SNP_REQ_CA_LSB + smiObj.WSMICA - ((smiObj.WSMICA > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMICA ;
    smiMsgObj.SNP_REQ_AC_LSB        = ((smiObj.WSMICA == 0) ? smiMsgObj.SNP_REQ_CA_LSB : smiMsgObj.SNP_REQ_CA_MSB + 1);
    smiMsgObj.SNP_REQ_AC_MSB        = smiMsgObj.SNP_REQ_AC_LSB + smiObj.WSMIAC - ((smiObj.WSMIAC > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMIAC ;
    smiMsgObj.SNP_REQ_NS_LSB        = ((smiObj.WSMIAC == 0) ? smiMsgObj.SNP_REQ_AC_LSB : smiMsgObj.SNP_REQ_AC_MSB + 1);
    smiMsgObj.SNP_REQ_NS_MSB        = smiMsgObj.SNP_REQ_NS_LSB + smiObj.WSMINS - ((smiObj.WSMINS > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMINS ;
    smiMsgObj.SNP_REQ_PR_LSB        = ((smiObj.WSMINS == 0) ? smiMsgObj.SNP_REQ_NS_LSB : smiMsgObj.SNP_REQ_NS_MSB + 1);
    smiMsgObj.SNP_REQ_PR_MSB        = smiMsgObj.SNP_REQ_PR_LSB + smiObj.WSMIPR - ((smiObj.WSMIPR > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMIPR ;
    smiMsgObj.SNP_REQ_UP_LSB        = ((smiObj.WSMIPR == 0) ? smiMsgObj.SNP_REQ_PR_LSB : smiMsgObj.SNP_REQ_PR_MSB + 1);
    smiMsgObj.SNP_REQ_UP_MSB        = smiMsgObj.SNP_REQ_UP_LSB + smiObj.WSMIUP - ((smiObj.WSMIUP > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMIUP ;
    smiMsgObj.SNP_REQ_RL_LSB        = ((smiObj.WSMIUP == 0) ? smiMsgObj.SNP_REQ_UP_LSB : smiMsgObj.SNP_REQ_UP_MSB + 1);
    smiMsgObj.SNP_REQ_RL_MSB        = smiMsgObj.SNP_REQ_RL_LSB + smiObj.WSMIRL - ((smiObj.WSMIRL > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMIRL ;
    smiMsgObj.SNP_REQ_MPF1_LSB      = ((smiObj.WSMIRL == 0) ? smiMsgObj.SNP_REQ_RL_LSB : smiMsgObj.SNP_REQ_RL_MSB + 1);
    smiMsgObj.SNP_REQ_MPF1_MSB      = smiMsgObj.SNP_REQ_MPF1_LSB + smiObj.WSMIMPF1 - ((smiObj.WSMIMPF1 > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMIMPF1 ;
    smiMsgObj.SNP_REQ_MPF2_LSB      = ((smiObj.WSMIMPF1 == 0) ? smiMsgObj.SNP_REQ_MPF1_LSB : smiMsgObj.SNP_REQ_MPF1_MSB + 1);
    smiMsgObj.SNP_REQ_MPF2_MSB      = smiMsgObj.SNP_REQ_MPF2_LSB + smiObj.WSMIMPF2 - ((smiObj.WSMIMPF2 > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMIMPF2 ;
    smiMsgObj.SNP_REQ_MPF3_LSB      = ((smiObj.WSMIMPF2 == 0) ? smiMsgObj.SNP_REQ_MPF2_LSB : smiMsgObj.SNP_REQ_MPF2_MSB + 1);
    smiMsgObj.SNP_REQ_MPF3_MSB      = smiMsgObj.SNP_REQ_MPF3_LSB + smiObj.WSMIMPF3 - ((smiObj.WSMIMPF3 > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMIMPF3 ;
    smiMsgObj.SNP_REQ_INTF_SIZE_LSB = ((smiObj.WSMIMPF3 == 0) ? smiMsgObj.SNP_REQ_MPF3_LSB : smiMsgObj.SNP_REQ_MPF3_MSB + 1);
    smiMsgObj.SNP_REQ_INTF_SIZE_MSB = smiMsgObj.SNP_REQ_INTF_SIZE_LSB + smiObj.WSMIINTFSIZE - ((smiObj.WSMIINTFSIZE > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP             += smiObj.WSMIINTFSIZE ;
    smiMsgObj.SNP_REQ_DEST_ID_LSB   = ((smiObj.WSMIINTFSIZE == 0) ? smiMsgObj.SNP_REQ_INTF_SIZE_LSB : smiMsgObj.SNP_REQ_INTF_SIZE_MSB + 1);
    smiMsgObj.SNP_REQ_DEST_ID_MSB   = smiMsgObj.SNP_REQ_DEST_ID_LSB + smiObj.WSMIDESTID - ((smiObj.WSMIDESTID > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP             += smiObj.WSMIDESTID ;
    smiMsgObj.SNP_REQ_TOF_LSB       = ((smiObj.WSMIDEST_ID == 0) ? smiMsgObj.SNP_REQ_DEST_ID_LSB : smiMsgObj.SNP_REQ_DEST_ID_MSB + 1);
    smiMsgObj.SNP_REQ_TOF_MSB       = smiMsgObj.SNP_REQ_TOF_LSB + smiObj.WSMITOF - ((smiObj.WSMITOF > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMITOF ;
    smiMsgObj.SNP_REQ_QOS_LSB       = ((smiObj.WSMITOF == 0) ? smiMsgObj.SNP_REQ_TOF_LSB : smiMsgObj.SNP_REQ_TOF_MSB + 1);
    smiMsgObj.SNP_REQ_QOS_MSB       = smiMsgObj.SNP_REQ_QOS_LSB + smiObj.WSMIQOS - ((smiObj.WSMIQOS > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMIQOS ;
    smiMsgObj.SNP_REQ_RBID_LSB      = ((smiObj.WSMIQOS == 0) ? smiMsgObj.SNP_REQ_QOS_LSB : smiMsgObj.SNP_REQ_QOS_MSB + 1);
    smiMsgObj.SNP_REQ_RBID_MSB      = smiMsgObj.SNP_REQ_RBID_LSB + smiObj.WSMIRBID - ((smiObj.WSMIRBID > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMIRBID ;
    smiMsgObj.SNP_REQ_NDP_AUX_LSB   = ((smiObj.WSMIRBID == 0) ? smiMsgObj.SNP_REQ_RBID_LSB : smiMsgObj.SNP_REQ_RBID_MSB + 1);
    smiMsgObj.SNP_REQ_NDP_AUX_MSB   = smiMsgObj.SNP_REQ_NDP_AUX_LSB + 0; //smiObj.WSMINDPAUX - ((smiObj.WSMINDPAUX > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += 0; //smiObj.WSMINDPAUX ;
    smiMsgObj.SNP_REQ_NDP_PROT_LSB  = smiMsgObj.SNP_REQ_NDP_AUX_LSB; //((smiObj.WSMINDPAUX == 0) ? smiMsgObj.SNP_REQ_NDP_AUX_LSB : smiMsgObj.SNP_REQ_NDP_AUX_MSB + 1);
    smiMsgObj.SNP_REQ_NDP_PROT_MSB  = smiMsgObj.SNP_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_SNP_REQ_NDP         += smiObj.WSMINDPPROT ;

    //HntReq
    smiMsgObj.W_HNT_REQ_NDP                  = 0;
    smiMsgObj.HNT_REQ_CMSTATUS_LSB = 0;
    smiMsgObj.HNT_REQ_CMSTATUS_MSB = smiMsgObj.HNT_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS - ((smiObj.WSMICMSTATUS > 0) ? 1 : 0);
    smiMsgObj.W_HNT_REQ_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.HNT_REQ_ADDR_LSB     = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.HNT_REQ_CMSTATUS_LSB: smiMsgObj.HNT_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.HNT_REQ_ADDR_MSB     = smiMsgObj.HNT_REQ_ADDR_LSB + smiObj.WSMIADDR - ((smiObj.WSMIADDR > 0) ? 1 : 0);
    smiMsgObj.W_HNT_REQ_NDP         += smiObj.WSMIADDR ;
    smiMsgObj.HNT_REQ_AC_LSB       = ((smiObj.WSMIADDR == 0) ? smiMsgObj.HNT_REQ_ADDR_LSB : smiMsgObj.HNT_REQ_ADDR_MSB + 1);
    smiMsgObj.HNT_REQ_AC_MSB       = smiMsgObj.HNT_REQ_AC_LSB + smiObj.WSMIAC - ((smiObj.WSMIAC > 0) ? 1 : 0);
    smiMsgObj.W_HNT_REQ_NDP         += smiObj.WSMIAC ;
    smiMsgObj.HNT_REQ_NS_LSB       = ((smiObj.WSMIAC == 0) ? smiMsgObj.HNT_REQ_AC_LSB : smiMsgObj.HNT_REQ_AC_MSB + 1);
    smiMsgObj.HNT_REQ_NS_MSB       = smiMsgObj.HNT_REQ_NS_LSB + smiObj.WSMINS - ((smiObj.WSMINS > 0) ? 1 : 0);
    smiMsgObj.W_HNT_REQ_NDP         += smiObj.WSMINS ;
    smiMsgObj.HNT_REQ_NDP_AUX_LSB  = ((smiObj.WSMINS == 0) ? smiMsgObj.HNT_REQ_NS_LSB : smiMsgObj.HNT_REQ_NS_MSB + 1);
    smiMsgObj.HNT_REQ_NDP_AUX_MSB  = smiMsgObj.HNT_REQ_NDP_AUX_LSB + smiObj.WSMINDPAUX - ((smiObj.WSMINDPAUX > 0) ? 1 : 0);
    smiMsgObj.W_HNT_REQ_NDP         += smiObj.WSMINDPAUX ;
    smiMsgObj.HNT_REQ_NDP_PROT_LSB = ((smiObj.WSMINDPAUX == 0) ? smiMsgObj.HNT_REQ_NDP_AUX_LSB : smiMsgObj.HNT_REQ_NDP_AUX_MSB + 1);
    smiMsgObj.HNT_REQ_NDP_PROT_MSB = smiMsgObj.HNT_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_HNT_REQ_NDP         += smiObj.WSMINDPPROT ;

    //MrdReq
    smiMsgObj.W_MRD_REQ_NDP                  = 0;
    smiMsgObj.MRD_REQ_TM_LSB        = 0;
    smiMsgObj.MRD_REQ_TM_MSB        = smiMsgObj.MRD_REQ_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMITM ;
    smiMsgObj.MRD_REQ_CMSTATUS_LSB  = ((smiObj.WSMITM == 0) ? smiMsgObj.MRD_REQ_TM_LSB : smiMsgObj.MRD_REQ_TM_MSB + 1);
    smiMsgObj.MRD_REQ_CMSTATUS_MSB  = smiMsgObj.MRD_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS - ((smiObj.WSMICMSTATUS > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.MRD_REQ_ADDR_LSB      = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.MRD_REQ_CMSTATUS_LSB: smiMsgObj.MRD_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.MRD_REQ_ADDR_MSB      = smiMsgObj.MRD_REQ_ADDR_LSB + smiObj.WSMIADDR - ((smiObj.WSMIADDR > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMIADDR ;
    smiMsgObj.MRD_REQ_AC_LSB        = ((smiObj.WSMIADDR == 0) ? smiMsgObj.MRD_REQ_ADDR_LSB : smiMsgObj.MRD_REQ_ADDR_MSB + 1);
    smiMsgObj.MRD_REQ_AC_MSB        = smiMsgObj.MRD_REQ_AC_LSB + smiObj.WSMIAC - ((smiObj.WSMIAC > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMIAC ;
    smiMsgObj.MRD_REQ_NS_LSB        = ((smiObj.WSMIAC == 0) ? smiMsgObj.MRD_REQ_AC_LSB : smiMsgObj.MRD_REQ_AC_MSB + 1);
    smiMsgObj.MRD_REQ_NS_MSB        = smiMsgObj.MRD_REQ_NS_LSB + smiObj.WSMINS - ((smiObj.WSMINS > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMINS ;
    smiMsgObj.MRD_REQ_PR_LSB        = ((smiObj.WSMINS == 0) ? smiMsgObj.MRD_REQ_NS_LSB : smiMsgObj.MRD_REQ_NS_MSB + 1);
    smiMsgObj.MRD_REQ_PR_MSB        = smiMsgObj.MRD_REQ_PR_LSB + smiObj.WSMIPR - ((smiObj.WSMIPR > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMIPR ;
    smiMsgObj.MRD_REQ_RL_LSB        = ((smiObj.WSMIPR == 0) ? smiMsgObj.MRD_REQ_PR_LSB : smiMsgObj.MRD_REQ_PR_MSB + 1);
    smiMsgObj.MRD_REQ_RL_MSB        = smiMsgObj.MRD_REQ_RL_LSB + smiObj.WSMIRL - ((smiObj.WSMIRL > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMIRL ;
    smiMsgObj.MRD_REQ_MPF1_LSB      = ((smiObj.WSMIRL == 0) ? smiMsgObj.MRD_REQ_RL_LSB : smiMsgObj.MRD_REQ_RL_MSB + 1);
    smiMsgObj.MRD_REQ_MPF1_MSB      = smiMsgObj.MRD_REQ_MPF1_LSB + smiObj.WSMIMPF1 - ((smiObj.WSMIMPF1 > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMIMPF1 ;
    smiMsgObj.MRD_REQ_MPF2_LSB      = ((smiObj.WSMIMPF1 == 0) ? smiMsgObj.MRD_REQ_MPF1_LSB : smiMsgObj.MRD_REQ_MPF1_MSB + 1);
    smiMsgObj.MRD_REQ_MPF2_MSB      = smiMsgObj.MRD_REQ_MPF2_LSB + smiObj.WSMIMPF2 - ((smiObj.WSMIMPF2 > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMIMPF2 ;
    smiMsgObj.MRD_REQ_SIZE_LSB      = ((smiObj.WSMIMPF2 == 0) ? smiMsgObj.MRD_REQ_MPF2_LSB : smiMsgObj.MRD_REQ_MPF2_MSB + 1);
    smiMsgObj.MRD_REQ_SIZE_MSB      = smiMsgObj.MRD_REQ_SIZE_LSB + smiObj.WSMISIZE - ((smiObj.WSMISIZE > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMISIZE ;
    smiMsgObj.MRD_REQ_INTF_SIZE_LSB = ((smiObj.WSMISIZE == 0) ? smiMsgObj.MRD_REQ_SIZE_LSB : smiMsgObj.MRD_REQ_SIZE_MSB + 1);
    smiMsgObj.MRD_REQ_INTF_SIZE_MSB = smiMsgObj.MRD_REQ_INTF_SIZE_LSB + smiObj.WSMIINTFSIZE - ((smiObj.WSMIINTFSIZE > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMIINTFSIZE ;
    smiMsgObj.MRD_REQ_QOS_LSB       = ((smiObj.WSMIINTFSIZE == 0) ? smiMsgObj.MRD_REQ_INTF_SIZE_LSB : smiMsgObj.MRD_REQ_INTF_SIZE_MSB + 1);
    smiMsgObj.MRD_REQ_QOS_MSB       = smiMsgObj.MRD_REQ_QOS_LSB + smiObj.WSMIQOS - ((smiObj.WSMIQOS > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMIQOS ;
    smiMsgObj.MRD_REQ_NDP_AUX_LSB   = ((smiObj.WSMIQOS == 0) ? smiMsgObj.MRD_REQ_QOS_LSB : smiMsgObj.MRD_REQ_QOS_MSB + 1);
    smiMsgObj.MRD_REQ_NDP_AUX_MSB   = smiMsgObj.MRD_REQ_NDP_AUX_LSB + smiObj.WSMINDPAUX - ((smiObj.WSMINDPAUX > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMINDPAUX ;
    smiMsgObj.MRD_REQ_NDP_PROT_LSB  = ((smiObj.WSMINDPAUX == 0) ? smiMsgObj.MRD_REQ_NDP_AUX_LSB : smiMsgObj.MRD_REQ_NDP_AUX_MSB + 1);
    smiMsgObj.MRD_REQ_NDP_PROT_MSB  = smiMsgObj.MRD_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_MRD_REQ_NDP         += smiObj.WSMINDPPROT ;

    //StrReq
    smiMsgObj.W_STR_REQ_NDP                  = 0;
    smiMsgObj.STR_REQ_TM_LSB        = 0;
    smiMsgObj.STR_REQ_TM_MSB        = smiMsgObj.STR_REQ_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_STR_REQ_NDP         += smiObj.WSMITM ;
    smiMsgObj.STR_REQ_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.STR_REQ_TM_LSB : smiMsgObj.STR_REQ_TM_MSB + 1);
    smiMsgObj.STR_REQ_RMSGID_MSB    = smiMsgObj.STR_REQ_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_STR_REQ_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.STR_REQ_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.STR_REQ_RMSGID_LSB : smiMsgObj.STR_REQ_RMSGID_MSB + 1);
    smiMsgObj.STR_REQ_CMSTATUS_MSB  = smiMsgObj.STR_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_STR_REQ_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.STR_REQ_RBID_LSB      = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.STR_REQ_CMSTATUS_LSB : smiMsgObj.STR_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.STR_REQ_RBID_MSB      = smiMsgObj.STR_REQ_RBID_LSB + smiObj.WSMIRBID - ((smiObj.WSMIRBID > 0) ? 1 : 0);
    smiMsgObj.W_STR_REQ_NDP         += smiObj.WSMIRBID ;
    smiMsgObj.STR_REQ_MPF1_LSB      = ((smiObj.WSMIRBID == 0) ? smiMsgObj.STR_REQ_RBID_LSB : smiMsgObj.STR_REQ_RBID_MSB + 1);
    smiMsgObj.STR_REQ_MPF1_MSB      = smiMsgObj.STR_REQ_MPF1_LSB + smiObj.WSMIMPF1 - ((smiObj.WSMIMPF1 > 0) ? 1 : 0);
    smiMsgObj.W_STR_REQ_NDP         += smiObj.WSMIMPF1 ;
    smiMsgObj.STR_REQ_MPF2_LSB      = ((smiObj.WSMIMPF1 == 0) ? smiMsgObj.STR_REQ_MPF1_LSB : smiMsgObj.STR_REQ_MPF1_MSB + 1);
    smiMsgObj.STR_REQ_MPF2_MSB      = smiMsgObj.STR_REQ_MPF2_LSB + smiObj.WSMIMPF2 - ((smiObj.WSMIMPF2 > 0) ? 1 : 0);
    smiMsgObj.W_STR_REQ_NDP         += smiObj.WSMIMPF2 ;
    smiMsgObj.STR_REQ_INTF_SIZE_LSB = ((smiObj.WSMIMPF2 == 0) ? smiMsgObj.STR_REQ_MPF2_LSB : smiMsgObj.STR_REQ_MPF2_MSB + 1);
    smiMsgObj.STR_REQ_INTF_SIZE_MSB = smiMsgObj.STR_REQ_INTF_SIZE_LSB + smiObj.WSMIINTFSIZE - ((smiObj.WSMIINTFSIZE > 0) ? 1 : 0);
    smiMsgObj.W_STR_REQ_NDP         += smiObj.WSMIINTFSIZE ;
    smiMsgObj.STR_REQ_NDP_PROT_LSB  = ((smiObj.WSMIINTFSIZE == 0) ? smiMsgObj.STR_REQ_INTF_SIZE_LSB : smiMsgObj.STR_REQ_INTF_SIZE_MSB + 1);
    smiMsgObj.STR_REQ_NDP_PROT_MSB  = smiMsgObj.STR_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_STR_REQ_NDP         += smiObj.WSMINDPPROT ;

    //DtrReq - NDM
    smiMsgObj.W_DTR_REQ_NDP                  = 0;
    smiMsgObj.DTR_REQ_TM_LSB        = 0;
    smiMsgObj.DTR_REQ_TM_MSB        = smiMsgObj.DTR_REQ_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_DTR_REQ_NDP         += smiObj.WSMITM ;
    smiMsgObj.DTR_REQ_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.DTR_REQ_TM_LSB : smiMsgObj.DTR_REQ_TM_MSB + 1);
    smiMsgObj.DTR_REQ_RMSGID_MSB    = smiMsgObj.DTR_REQ_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_DTR_REQ_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.DTR_REQ_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.DTR_REQ_RMSGID_LSB : smiMsgObj.DTR_REQ_RMSGID_MSB + 1);
    smiMsgObj.DTR_REQ_CMSTATUS_MSB  = smiMsgObj.DTR_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_DTR_REQ_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.DTR_REQ_RL_LSB       = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.DTR_REQ_CMSTATUS_LSB : smiMsgObj.DTR_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.DTR_REQ_RL_MSB       = smiMsgObj.DTR_REQ_RL_LSB + smiObj.WSMIRL - ((smiObj.WSMIRL > 0) ? 1 : 0);
    smiMsgObj.W_DTR_REQ_NDP         += smiObj.WSMIRL ;
    smiMsgObj.DTR_REQ_MPF1_LSB     = ((smiObj.WSMIRL == 0) ? smiMsgObj.DTR_REQ_RL_LSB : smiMsgObj.DTR_REQ_RL_MSB + 1);
    smiMsgObj.DTR_REQ_MPF1_MSB     = smiMsgObj.DTR_REQ_MPF1_LSB + smiObj.WSMIMPF1 - ((smiObj.WSMIMPF1 > 0) ? 1 : 0);
    smiMsgObj.W_DTR_REQ_NDP         += smiObj.WSMIMPF1 ;
    smiMsgObj.DTR_REQ_NDP_AUX_LSB  = ((smiObj.WSMIMPF1 == 0) ? smiMsgObj.DTR_REQ_MPF1_LSB : smiMsgObj.DTR_REQ_MPF1_MSB + 1);
    smiMsgObj.DTR_REQ_NDP_AUX_MSB  = smiMsgObj.DTR_REQ_NDP_AUX_LSB + 0; //smiObj.WSMINDPAUX - ((smiObj.WSMINDPAUX > 0) ? 1 : 0);
    smiMsgObj.W_DTR_REQ_NDP         += 0; //smiObj.WSMINDPAUX ;
    smiMsgObj.DTR_REQ_NDP_PROT_LSB = smiMsgObj.DTR_REQ_NDP_AUX_LSB; //((smiObj.WSMINDPAUX == 0) ? smiMsgObj.DTR_REQ_NDP_AUX_LSB : smiMsgObj.DTR_REQ_NDP_AUX_MSB + 1);
    smiMsgObj.DTR_REQ_NDP_PROT_MSB = smiMsgObj.DTR_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_DTR_REQ_NDP         += smiObj.WSMINDPPROT ;
    //Smi_seq_item packs the dp per DW

    //DtwReq - NDM
    smiMsgObj.W_DTW_REQ_NDP                  = 0;
    smiMsgObj.DTW_REQ_TM_LSB        = 0;
    smiMsgObj.DTW_REQ_TM_MSB        = smiMsgObj.DTW_REQ_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_DTW_REQ_NDP         += smiObj.WSMITM ;
    smiMsgObj.DTW_REQ_RBID_LSB      = ((smiObj.WSMITM == 0) ? smiMsgObj.DTW_REQ_TM_LSB : smiMsgObj.DTW_REQ_TM_MSB + 1);
    smiMsgObj.DTW_REQ_RBID_MSB      = smiMsgObj.DTW_REQ_RBID_LSB + smiObj.WSMIRBID - ((smiObj.WSMIRBID > 0) ? 1 : 0);
    smiMsgObj.W_DTW_REQ_NDP         += smiObj.WSMIRBID ;
    smiMsgObj.DTW_REQ_CMSTATUS_LSB  = ((smiObj.WSMIRBID == 0) ? smiMsgObj.DTW_REQ_RBID_LSB : smiMsgObj.DTW_REQ_RBID_MSB + 1);
    smiMsgObj.DTW_REQ_CMSTATUS_MSB  = smiMsgObj.DTW_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_DTW_REQ_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.DTW_REQ_RL_LSB        = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.DTW_REQ_CMSTATUS_LSB : smiMsgObj.DTW_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.DTW_REQ_RL_MSB        = smiMsgObj.DTW_REQ_RL_LSB + smiObj.WSMIRL - ((smiObj.WSMIRL > 0) ? 1 : 0);
    smiMsgObj.W_DTW_REQ_NDP         += smiObj.WSMIRL ;
    smiMsgObj.DTW_REQ_PRIMARY_LSB   = ((smiObj.WSMIRL == 0) ? smiMsgObj.DTW_REQ_RL_LSB : smiMsgObj.DTW_REQ_RL_MSB + 1);
    smiMsgObj.DTW_REQ_PRIMARY_MSB   = smiMsgObj.DTW_REQ_PRIMARY_LSB + smiObj.WSMIPRIMARY - ((smiObj.WSMIPRIMARY > 0) ? 1 : 0);
    smiMsgObj.W_DTW_REQ_NDP         += smiObj.WSMIPRIMARY ;
    smiMsgObj.DTW_REQ_MPF1_LSB      = ((smiObj.WSMIPRIMARY == 0) ? smiMsgObj.DTW_REQ_PRIMARY_LSB : smiMsgObj.DTW_REQ_PRIMARY_MSB + 1);
    smiMsgObj.DTW_REQ_MPF1_MSB      = smiMsgObj.DTW_REQ_MPF1_LSB + smiObj.WSMIMPF1 - ((smiObj.WSMIMPF1 > 0) ? 1 : 0);
    smiMsgObj.W_DTW_REQ_NDP         += smiObj.WSMIMPF1 ;
    smiMsgObj.DTW_REQ_MPF2_LSB      = ((smiObj.WSMIMPF1 == 0) ? smiMsgObj.DTW_REQ_MPF1_LSB : smiMsgObj.DTW_REQ_MPF1_MSB + 1);
    smiMsgObj.DTW_REQ_MPF2_MSB      = smiMsgObj.DTW_REQ_MPF2_LSB + smiObj.WSMIMPF2 - ((smiObj.WSMIMPF2 > 0) ? 1 : 0);
    smiMsgObj.W_DTW_REQ_NDP         += smiObj.WSMIMPF2 ;
    smiMsgObj.DTW_REQ_INTF_SIZE_LSB = ((smiObj.WSMIMPF2 == 0) ? smiMsgObj.DTW_REQ_MPF2_LSB : smiMsgObj.DTW_REQ_MPF2_MSB + 1);
    smiMsgObj.DTW_REQ_INTF_SIZE_MSB = smiMsgObj.DTW_REQ_INTF_SIZE_LSB + smiObj.WSMIINTFSIZE - ((smiObj.WSMIINTFSIZE > 0) ? 1 : 0);
    smiMsgObj.W_DTW_REQ_NDP         += smiObj.WSMIINTFSIZE ;
    smiMsgObj.DTW_REQ_NDP_AUX_LSB   = ((smiObj.WSMIINTFSIZE == 0) ? smiMsgObj.DTW_REQ_INTF_SIZE_LSB : smiMsgObj.DTW_REQ_INTF_SIZE_MSB + 1);
    smiMsgObj.DTW_REQ_NDP_AUX_MSB   = smiMsgObj.DTW_REQ_NDP_AUX_LSB + 0; //smiObj.WSMINDPAUX - ((smiObj.WSMINDPAUX > 0) ? 1 : 0);
    smiMsgObj.W_DTW_REQ_NDP             += 0; //smiObj.WSMINDPAUX ;
    smiMsgObj.DTW_REQ_NDP_PROT_LSB  = smiMsgObj.DTW_REQ_NDP_AUX_LSB; //((smiObj.WSMINDPAUX == 0) ? smiMsgObj.DTW_REQ_NDP_AUX_LSB : smiMsgObj.DTW_REQ_NDP_AUX_MSB + 1);
    smiMsgObj.DTW_REQ_NDP_PROT_MSB  = smiMsgObj.DTW_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_DTW_REQ_NDP         += smiObj.WSMINDPPROT ;
    //Smi_seq_item packs the dp per DW
    
    //DtwDbg - NDM
    smiMsgObj.W_DTW_DBG_REQ_NDP                      =0;
    smiMsgObj.DTW_DBG_REQ_TM_LSB        = 0;
    smiMsgObj.DTW_DBG_REQ_TM_MSB        = smiMsgObj.DTW_DBG_REQ_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_DTW_DBG_REQ_NDP         += smiObj.WSMITM ;
    smiMsgObj.DTW_DBG_REQ_CMSTATUS_LSB  = ((smiObj.WSMITM == 0) ? smiMsgObj.DTW_DBG_REQ_TM_LSB : smiMsgObj.DTW_DBG_REQ_TM_MSB + 1);
    smiMsgObj.DTW_DBG_REQ_CMSTATUS_MSB  = smiMsgObj.DTW_DBG_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_DTW_DBG_REQ_NDP     += smiObj.WSMICMSTATUS ;
    smiMsgObj.DTW_DBG_REQ_RL_LSB        = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.DTW_DBG_REQ_CMSTATUS_LSB : smiMsgObj.DTW_DBG_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.DTW_DBG_REQ_RL_MSB        = smiMsgObj.DTW_DBG_REQ_RL_LSB + smiObj.WSMIRL - ((smiObj.WSMIRL > 0) ? 1 : 0);
    smiMsgObj.W_DTW_DBG_REQ_NDP     += smiObj.WSMIRL ;
    smiMsgObj.DTW_DBG_REQ_NDP_PROT_LSB  = ((smiObj.WSMIRL == 0) ? smiMsgObj.DTW_DBG_REQ_RL_LSB : smiMsgObj.DTW_DBG_REQ_RL_MSB + 1);
    smiMsgObj.DTW_DBG_REQ_NDP_PROT_MSB  = smiMsgObj.DTW_DBG_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_DTW_DBG_REQ_NDP     += smiObj.WSMINDPPROT ;
    //Smi_seq_item packs the dp per DW

    //UpdReq
    smiMsgObj.W_UPD_REQ_NDP                  = 0;
    smiMsgObj.UPD_REQ_TM_LSB        = 0;
    smiMsgObj.UPD_REQ_TM_MSB        = smiMsgObj.UPD_REQ_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_UPD_REQ_NDP         += smiObj.WSMITM ;
    smiMsgObj.UPD_REQ_CMSTATUS_LSB = ((smiObj.WSMITM == 0) ? smiMsgObj.UPD_REQ_TM_LSB : smiMsgObj.UPD_REQ_TM_MSB + 1);
    smiMsgObj.UPD_REQ_CMSTATUS_MSB = smiMsgObj.UPD_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS - ((smiObj.WSMICMSTATUS > 0) ? 1 : 0);
    smiMsgObj.W_UPD_REQ_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.UPD_REQ_ADDR_LSB     = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.UPD_REQ_CMSTATUS_LSB: smiMsgObj.UPD_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.UPD_REQ_ADDR_MSB     = smiMsgObj.UPD_REQ_ADDR_LSB + smiObj.WSMIADDR - ((smiObj.WSMIADDR > 0) ? 1 : 0);
    smiMsgObj.W_UPD_REQ_NDP         += smiObj.WSMIADDR ;
    smiMsgObj.UPD_REQ_NS_LSB       = ((smiObj.WSMIADDR == 0) ? smiMsgObj.UPD_REQ_ADDR_LSB : smiMsgObj.UPD_REQ_ADDR_MSB + 1);
    smiMsgObj.UPD_REQ_NS_MSB       = smiMsgObj.UPD_REQ_NS_LSB + smiObj.WSMINS - ((smiObj.WSMINS > 0) ? 1 : 0);
    smiMsgObj.W_UPD_REQ_NDP         += smiObj.WSMINS ;
    smiMsgObj.UPD_REQ_QOS_LSB      = ((smiObj.WSMINS == 0) ? smiMsgObj.UPD_REQ_NS_LSB : smiMsgObj.UPD_REQ_NS_MSB + 1);
    smiMsgObj.UPD_REQ_QOS_MSB      = smiMsgObj.UPD_REQ_QOS_LSB + smiObj.WSMIQOS - ((smiObj.WSMIQOS > 0) ? 1 : 0);
    smiMsgObj.W_UPD_REQ_NDP         += smiObj.WSMIQOS ;
    smiMsgObj.UPD_REQ_NDP_PROT_LSB = ((smiObj.WSMIQOS == 0) ? smiMsgObj.UPD_REQ_QOS_LSB : smiMsgObj.UPD_REQ_QOS_MSB + 1);
    smiMsgObj.UPD_REQ_NDP_PROT_MSB = smiMsgObj.UPD_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_UPD_REQ_NDP         += smiObj.WSMINDPPROT ;

    //RBReq
    smiMsgObj.W_RB_REQ_NDP                   = 0;
    smiMsgObj.RB_REQ_TM_LSB        = 0;
    smiMsgObj.RB_REQ_TM_MSB        = smiMsgObj.RB_REQ_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMITM ;
    smiMsgObj.RB_REQ_RBID_LSB      = ((smiObj.WSMITM == 0) ? smiMsgObj.RB_REQ_TM_LSB : smiMsgObj.RB_REQ_TM_MSB + 1);
    smiMsgObj.RB_REQ_RBID_MSB      = smiMsgObj.RB_REQ_RBID_LSB + smiObj.WSMIRBID - ((smiObj.WSMIRBID > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMIRBID ;
    smiMsgObj.RB_REQ_CMSTATUS_LSB  = ((smiObj.WSMIRBID == 0) ? smiMsgObj.RB_REQ_RBID_LSB : smiMsgObj.RB_REQ_RBID_MSB + 1);
    smiMsgObj.RB_REQ_CMSTATUS_MSB  = smiMsgObj.RB_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMICMSTATUS ;
    smiMsgObj.RB_REQ_RTYPE_LSB     = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.RB_REQ_CMSTATUS_LSB : smiMsgObj.RB_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.RB_REQ_RTYPE_MSB     = smiMsgObj.RB_REQ_RTYPE_LSB + smiObj.WSMIRTYPE- ((smiObj.WSMIRTYPE > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMIRTYPE ;
    smiMsgObj.RB_REQ_ADDR_LSB      = ((smiObj.WSMIRTYPE == 0) ? smiMsgObj.RB_REQ_RTYPE_LSB : smiMsgObj.RB_REQ_RTYPE_MSB + 1);
    smiMsgObj.RB_REQ_ADDR_MSB      = smiMsgObj.RB_REQ_ADDR_LSB + smiObj.WSMIADDR - ((smiObj.WSMIADDR > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMIADDR ;
    smiMsgObj.RB_REQ_SIZE_LSB      = ((smiObj.WSMIADDR == 0) ? smiMsgObj.RB_REQ_ADDR_LSB : smiMsgObj.RB_REQ_ADDR_MSB + 1);
    smiMsgObj.RB_REQ_SIZE_MSB      = smiMsgObj.RB_REQ_SIZE_LSB + smiObj.WSMISIZE - ((smiObj.WSMISIZE > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMISIZE ;
    smiMsgObj.RB_REQ_VZ_LSB        = ((smiObj.WSMISIZE == 0) ? smiMsgObj.RB_REQ_SIZE_LSB : smiMsgObj.RB_REQ_SIZE_MSB + 1);
    smiMsgObj.RB_REQ_VZ_MSB        = smiMsgObj.RB_REQ_VZ_LSB + smiObj.WSMIVZ - ((smiObj.WSMIVZ > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMIVZ ;
    smiMsgObj.RB_REQ_CA_LSB        = ((smiObj.WSMIVZ == 0) ? smiMsgObj.RB_REQ_VZ_LSB : smiMsgObj.RB_REQ_VZ_MSB + 1);
    smiMsgObj.RB_REQ_CA_MSB        = smiMsgObj.RB_REQ_CA_LSB + smiObj.WSMICA - ((smiObj.WSMICA > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMICA ;
    smiMsgObj.RB_REQ_AC_LSB        = ((smiObj.WSMICA == 0) ? smiMsgObj.RB_REQ_CA_LSB : smiMsgObj.RB_REQ_CA_MSB + 1);
    smiMsgObj.RB_REQ_AC_MSB        = smiMsgObj.RB_REQ_AC_LSB + smiObj.WSMIAC - ((smiObj.WSMIAC > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMIAC ;
    smiMsgObj.RB_REQ_NS_LSB        = ((smiObj.WSMIAC == 0) ? smiMsgObj.RB_REQ_AC_LSB : smiMsgObj.RB_REQ_AC_MSB + 1);
    smiMsgObj.RB_REQ_NS_MSB        = smiMsgObj.RB_REQ_NS_LSB + smiObj.WSMINS - ((smiObj.WSMINS > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMINS ;
    smiMsgObj.RB_REQ_PR_LSB        = ((smiObj.WSMINS == 0) ? smiMsgObj.RB_REQ_NS_LSB : smiMsgObj.RB_REQ_NS_MSB + 1);
    smiMsgObj.RB_REQ_PR_MSB        = smiMsgObj.RB_REQ_PR_LSB + smiObj.WSMIPR - ((smiObj.WSMIPR > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMIPR ;
    smiMsgObj.RB_REQ_MW_LSB        = ((smiObj.WSMIPR == 0) ? smiMsgObj.RB_REQ_PR_LSB : smiMsgObj.RB_REQ_PR_MSB + 1);
    smiMsgObj.RB_REQ_MW_MSB        = smiMsgObj.RB_REQ_MW_LSB + smiObj.WSMIMW - ((smiObj.WSMIMW > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMIMW ;
    smiMsgObj.RB_REQ_RL_LSB        = ((smiObj.WSMIMW == 0) ? smiMsgObj.RB_REQ_MW_LSB : smiMsgObj.RB_REQ_MW_MSB + 1);
    smiMsgObj.RB_REQ_RL_MSB        = smiMsgObj.RB_REQ_RL_LSB + smiObj.WSMIRL - ((smiObj.WSMIRL > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMIRL ;
    smiMsgObj.RB_REQ_MPF1_LSB      = ((smiObj.WSMIRL == 0) ? smiMsgObj.RB_REQ_RL_LSB : smiMsgObj.RB_REQ_RL_MSB + 1);
    smiMsgObj.RB_REQ_MPF1_MSB      = smiMsgObj.RB_REQ_MPF1_LSB + smiObj.WSMIMPF1 - ((smiObj.WSMIMPF1 > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMIMPF1 ;
    smiMsgObj.RB_REQ_TOF_LSB       = ((smiObj.WSMIMPF1 == 0) ? smiMsgObj.RB_REQ_MPF1_LSB : smiMsgObj.RB_REQ_MPF1_MSB + 1);
    smiMsgObj.RB_REQ_TOF_MSB       = smiMsgObj.RB_REQ_TOF_LSB + smiObj.WSMITOF - ((smiObj.WSMITOF > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMITOF ;
    smiMsgObj.RB_REQ_QOS_LSB       = ((smiObj.WSMITOF == 0) ? smiMsgObj.RB_REQ_TOF_LSB : smiMsgObj.RB_REQ_TOF_MSB + 1);
    smiMsgObj.RB_REQ_QOS_MSB       = smiMsgObj.RB_REQ_QOS_LSB + smiObj.WSMIQOS - ((smiObj.WSMIQOS > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMIQOS ;
    smiMsgObj.RB_REQ_NDP_AUX_LSB   = ((smiObj.WSMIQOS == 0) ? smiMsgObj.RB_REQ_QOS_LSB : smiMsgObj.RB_REQ_QOS_MSB + 1);
    smiMsgObj.RB_REQ_NDP_AUX_MSB   = smiMsgObj.RB_REQ_NDP_AUX_LSB + smiObj.WSMINDPAUX - ((smiObj.WSMINDPAUX > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMINDPAUX ;
    smiMsgObj.RB_REQ_NDP_PROT_LSB  = ((smiObj.WSMINDPAUX == 0) ? smiMsgObj.RB_REQ_NDP_AUX_LSB : smiMsgObj.RB_REQ_NDP_AUX_MSB + 1);
    smiMsgObj.RB_REQ_NDP_PROT_MSB  = smiMsgObj.RB_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_RB_REQ_NDP          += smiObj.WSMINDPPROT ;

    //RBUseReq
    smiMsgObj.W_RBUSE_REQ_NDP                = 0;
    smiMsgObj.RBUSE_REQ_TM_LSB        = 0;
    smiMsgObj.RBUSE_REQ_TM_MSB        = smiMsgObj.RBUSE_REQ_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_RBUSE_REQ_NDP       += smiObj.WSMITM ;
    smiMsgObj.RBUSE_REQ_RBID_LSB      = ((smiObj.WSMITM == 0) ? smiMsgObj.RBUSE_REQ_TM_LSB : smiMsgObj.RBUSE_REQ_TM_MSB + 1);
    smiMsgObj.RBUSE_REQ_RBID_MSB      = smiMsgObj.RBUSE_REQ_RBID_LSB + smiObj.WSMIRBID - ((smiObj.WSMIRBID > 0) ? 1 : 0);
    smiMsgObj.W_RBUSE_REQ_NDP       += smiObj.WSMIRBID ;
    smiMsgObj.RBUSE_REQ_CMSTATUS_LSB  = ((smiObj.WSMIRBID == 0) ? smiMsgObj.RBUSE_REQ_RBID_LSB : smiMsgObj.RBUSE_REQ_RBID_MSB + 1);
    smiMsgObj.RBUSE_REQ_CMSTATUS_MSB  = smiMsgObj.RBUSE_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_RBUSE_REQ_NDP       += smiObj.WSMICMSTATUS ;
    smiMsgObj.RBUSE_REQ_RL_LSB        = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.RBUSE_REQ_CMSTATUS_LSB : smiMsgObj.RBUSE_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.RBUSE_REQ_RL_MSB        = smiMsgObj.RBUSE_REQ_RL_LSB + smiObj.WSMIRL  - ((smiObj.WSMIRL  > 0) ? 1 : 0);
    smiMsgObj.W_RBUSE_REQ_NDP       += smiObj.WSMIRL ;
    smiMsgObj.RBUSE_REQ_NDP_PROT_LSB  = ((smiObj.WSMIRL == 0) ? smiMsgObj.RBUSE_REQ_RL_LSB : smiMsgObj.RBUSE_REQ_RL_MSB + 1);
    smiMsgObj.RBUSE_REQ_NDP_PROT_MSB  = smiMsgObj.RBUSE_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_RBUSE_REQ_NDP       += smiObj.WSMINDPPROT ;

    //C_CMDResp
    smiMsgObj.W_C_CMD_RSP_NDP                = 0;
    smiMsgObj.C_CMD_RSP_TM_LSB        = 0;
    smiMsgObj.C_CMD_RSP_TM_MSB        = smiMsgObj.C_CMD_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_C_CMD_RSP_NDP                += smiObj.WSMITM ;
    smiMsgObj.C_CMD_RSP_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.C_CMD_RSP_TM_LSB : smiMsgObj.C_CMD_RSP_TM_MSB + 1);
    smiMsgObj.C_CMD_RSP_RMSGID_MSB    = smiMsgObj.C_CMD_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_C_CMD_RSP_NDP           += smiObj.WSMIMSGID ;
    smiMsgObj.C_CMD_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.C_CMD_RSP_RMSGID_LSB : smiMsgObj.C_CMD_RSP_RMSGID_MSB + 1);
    smiMsgObj.C_CMD_RSP_CMSTATUS_MSB  = smiMsgObj.C_CMD_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_C_CMD_RSP_NDP       += smiObj.WSMICMSTATUS ;
    smiMsgObj.C_CMD_RSP_NDP_PROT_LSB  = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.C_CMD_RSP_CMSTATUS_LSB : smiMsgObj.C_CMD_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.C_CMD_RSP_NDP_PROT_MSB  = smiMsgObj.C_CMD_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_C_CMD_RSP_NDP       += smiObj.WSMINDPPROT ;

    //NC_CMDResp
    smiMsgObj.W_NC_CMD_RSP_NDP               = 0;
    smiMsgObj.NC_CMD_RSP_TM_LSB       = 0;
    smiMsgObj.NC_CMD_RSP_TM_MSB       = smiMsgObj.NC_CMD_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_NC_CMD_RSP_NDP               += smiObj.WSMITM ;
    smiMsgObj.NC_CMD_RSP_RMSGID_LSB   = ((smiObj.WSMITM == 0) ? smiMsgObj.NC_CMD_RSP_TM_LSB : smiMsgObj.NC_CMD_RSP_TM_MSB + 1);
    smiMsgObj.NC_CMD_RSP_RMSGID_MSB   = smiMsgObj.NC_CMD_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_NC_CMD_RSP_NDP           += smiObj.WSMIMSGID ;
    smiMsgObj.NC_CMD_RSP_CMSTATUS_LSB = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.NC_CMD_RSP_RMSGID_LSB : smiMsgObj.NC_CMD_RSP_RMSGID_MSB + 1);
    smiMsgObj.NC_CMD_RSP_CMSTATUS_MSB = smiMsgObj.NC_CMD_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_NC_CMD_RSP_NDP           += smiObj.WSMICMSTATUS ;
    smiMsgObj.NC_CMD_RSP_NDP_PROT_LSB = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.NC_CMD_RSP_CMSTATUS_LSB : smiMsgObj.NC_CMD_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.NC_CMD_RSP_NDP_PROT_MSB = smiMsgObj.NC_CMD_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_NC_CMD_RSP_NDP       += smiObj.WSMINDPPROT ;

    //SNPResp
    smiMsgObj.W_SNP_RSP_NDP                 =0;
    smiMsgObj.SNP_RSP_TM_LSB        = 0;
    smiMsgObj.SNP_RSP_TM_MSB        = smiMsgObj.SNP_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_SNP_RSP_NDP         += smiObj.WSMITM ;
    smiMsgObj.SNP_RSP_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.SNP_RSP_TM_LSB : smiMsgObj.SNP_RSP_TM_MSB + 1);
    smiMsgObj.SNP_RSP_RMSGID_MSB    = smiMsgObj.SNP_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_SNP_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.SNP_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.SNP_RSP_RMSGID_LSB : smiMsgObj.SNP_RSP_RMSGID_MSB + 1);
    smiMsgObj.SNP_RSP_CMSTATUS_MSB  = smiMsgObj.SNP_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_SNP_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.SNP_RSP_MPF1_LSB      = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.SNP_RSP_CMSTATUS_LSB : smiMsgObj.SNP_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.SNP_RSP_MPF1_MSB      = smiMsgObj.SNP_RSP_MPF1_LSB + smiObj.WSMIMPF1 - ((smiObj.WSMIMPF1 > 0) ? 1 : 0);
    smiMsgObj.W_SNP_RSP_NDP         += smiObj.WSMIMPF1 ;
    smiMsgObj.SNP_RSP_INTF_SIZE_LSB = ((smiObj.WSMIMPF1== 0) ? smiMsgObj.SNP_RSP_MPF1_LSB : smiMsgObj.SNP_RSP_MPF1_MSB + 1);
    smiMsgObj.SNP_RSP_INTF_SIZE_MSB = smiMsgObj.SNP_RSP_INTF_SIZE_LSB + smiObj.WSMIINTFSIZE - ((smiObj.WSMIINTFSIZE > 0) ? 1 : 0);
    smiMsgObj.W_SNP_RSP_NDP         += smiObj.WSMIINTFSIZE ;
    smiMsgObj.SNP_RSP_NDP_PROT_LSB  = ((smiObj.WSMIINTFSIZE == 0) ? smiMsgObj.SNP_RSP_INTF_SIZE_LSB : smiMsgObj.SNP_RSP_INTF_SIZE_MSB + 1);
    smiMsgObj.SNP_RSP_NDP_PROT_MSB  = smiMsgObj.SNP_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_SNP_RSP_NDP         += smiObj.WSMINDPPROT ;

    //DTWResp
    smiMsgObj.W_DTW_RSP_NDP                 = 0;
    smiMsgObj.DTW_RSP_TM_LSB        = 0;
    smiMsgObj.DTW_RSP_TM_MSB        = smiMsgObj.DTW_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_DTW_RSP_NDP         += smiObj.WSMITM ;
    smiMsgObj.DTW_RSP_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.DTW_RSP_TM_LSB : smiMsgObj.DTW_RSP_TM_MSB + 1);
    smiMsgObj.DTW_RSP_RMSGID_MSB    = smiMsgObj.DTW_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_DTW_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.DTW_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.DTW_RSP_RMSGID_LSB : smiMsgObj.DTW_RSP_RMSGID_MSB + 1);
    smiMsgObj.DTW_RSP_CMSTATUS_MSB  = smiMsgObj.DTW_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_DTW_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.DTW_RSP_RL_LSB        = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.DTW_RSP_CMSTATUS_LSB : smiMsgObj.DTW_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.DTW_RSP_RL_MSB        = smiMsgObj.DTW_RSP_RL_LSB + smiObj.WSMIRL - ((smiObj.WSMIRL > 0) ? 1 : 0);
    smiMsgObj.W_DTW_RSP_NDP         += smiObj.WSMIRL ;
    smiMsgObj.DTW_RSP_NDP_PROT_LSB  = ((smiObj.WSMIRL == 0) ? smiMsgObj.DTW_RSP_RL_LSB : smiMsgObj.DTW_RSP_RL_MSB + 1);
    smiMsgObj.DTW_RSP_NDP_PROT_MSB  = smiMsgObj.DTW_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_DTW_RSP_NDP         += smiObj.WSMINDPPROT ;

    //DTWDbgResp
    smiMsgObj.W_DTW_DBG_RSP_NDP                  =0;
    smiMsgObj.DTW_DBG_RSP_TM_LSB        = 0;
    smiMsgObj.DTW_DBG_RSP_TM_MSB        = smiMsgObj.DTW_DBG_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_DTW_DBG_RSP_NDP         += smiObj.WSMITM ;
    smiMsgObj.DTW_DBG_RSP_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.DTW_DBG_RSP_TM_LSB : smiMsgObj.DTW_DBG_RSP_TM_MSB + 1);
    smiMsgObj.DTW_DBG_RSP_RMSGID_MSB    = smiMsgObj.DTW_DBG_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_DTW_DBG_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.DTW_DBG_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.DTW_DBG_RSP_RMSGID_LSB : smiMsgObj.DTW_DBG_RSP_RMSGID_MSB + 1);
    smiMsgObj.DTW_DBG_RSP_CMSTATUS_MSB  = smiMsgObj.DTW_DBG_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_DTW_DBG_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.DTW_DBG_RSP_RL_LSB        = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.DTW_DBG_RSP_CMSTATUS_LSB : smiMsgObj.DTW_DBG_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.DTW_DBG_RSP_RL_MSB        = smiMsgObj.DTW_DBG_RSP_RL_LSB + smiObj.WSMIRL - ((smiObj.WSMIRL > 0) ? 1 : 0);
    smiMsgObj.W_DTW_DBG_RSP_NDP         += smiObj.WSMIRL ;
    smiMsgObj.DTW_DBG_RSP_NDP_PROT_LSB  = ((smiObj.WSMIRL == 0) ? smiMsgObj.DTW_DBG_RSP_RL_LSB : smiMsgObj.DTW_DBG_RSP_RL_MSB + 1);
    smiMsgObj.DTW_DBG_RSP_NDP_PROT_MSB  = smiMsgObj.DTW_DBG_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_DTW_DBG_RSP_NDP         += smiObj.WSMINDPPROT ;

    //DTRResp
    smiMsgObj.W_DTR_RSP_NDP                  =0;
    smiMsgObj.DTR_RSP_TM_LSB        = 0;
    smiMsgObj.DTR_RSP_TM_MSB        = smiMsgObj.DTR_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_DTR_RSP_NDP         += smiObj.WSMITM ;
    smiMsgObj.DTR_RSP_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.DTR_RSP_TM_LSB : smiMsgObj.DTR_RSP_TM_MSB + 1);
    smiMsgObj.DTR_RSP_RMSGID_MSB    = smiMsgObj.DTR_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_DTR_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.DTR_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.DTR_RSP_RMSGID_LSB : smiMsgObj.DTR_RSP_RMSGID_MSB + 1);
    smiMsgObj.DTR_RSP_CMSTATUS_MSB  = smiMsgObj.DTR_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_DTR_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.DTR_RSP_NDP_PROT_LSB  = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.DTR_RSP_CMSTATUS_LSB : smiMsgObj.DTR_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.DTR_RSP_NDP_PROT_MSB  = smiMsgObj.DTR_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_DTR_RSP_NDP         += smiObj.WSMINDPPROT ;

    //HNTResp
    smiMsgObj.W_HNT_RSP_NDP                  =0;
    smiMsgObj.HNT_RSP_RMSGID_LSB    = 0;
    smiMsgObj.HNT_RSP_RMSGID_MSB    = smiMsgObj.HNT_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_HNT_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.HNT_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.HNT_RSP_RMSGID_LSB : smiMsgObj.HNT_RSP_RMSGID_MSB + 1);
    smiMsgObj.HNT_RSP_CMSTATUS_MSB  = smiMsgObj.HNT_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_HNT_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.HNT_RSP_NDP_PROT_LSB  = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.HNT_RSP_CMSTATUS_LSB : smiMsgObj.HNT_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.HNT_RSP_NDP_PROT_MSB  = smiMsgObj.HNT_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_HNT_RSP_NDP         += smiObj.WSMINDPPROT ;

    //MRDResp
    smiMsgObj.W_MRD_RSP_NDP                  =0;
    smiMsgObj.MRD_RSP_TM_LSB        = 0;
    smiMsgObj.MRD_RSP_TM_MSB        = smiMsgObj.MRD_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_MRD_RSP_NDP         += smiObj.WSMITM ;
    smiMsgObj.MRD_RSP_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.MRD_RSP_TM_LSB : smiMsgObj.MRD_RSP_TM_MSB + 1);
    smiMsgObj.MRD_RSP_RMSGID_MSB    = smiMsgObj.MRD_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_MRD_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.MRD_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.MRD_RSP_RMSGID_LSB : smiMsgObj.MRD_RSP_RMSGID_MSB + 1);
    smiMsgObj.MRD_RSP_CMSTATUS_MSB  = smiMsgObj.MRD_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_MRD_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.MRD_RSP_NDP_PROT_LSB  = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.MRD_RSP_CMSTATUS_LSB : smiMsgObj.MRD_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.MRD_RSP_NDP_PROT_MSB  = smiMsgObj.MRD_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_MRD_RSP_NDP         += smiObj.WSMINDPPROT ;

    //STRResp
    smiMsgObj.W_STR_RSP_NDP                  =0;
    smiMsgObj.STR_RSP_TM_LSB        = 0;
    smiMsgObj.STR_RSP_TM_MSB        = smiMsgObj.STR_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_STR_RSP_NDP         += smiObj.WSMITM ;
    smiMsgObj.STR_RSP_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.STR_RSP_TM_LSB : smiMsgObj.STR_RSP_TM_MSB + 1);
    smiMsgObj.STR_RSP_RMSGID_MSB    = smiMsgObj.STR_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_STR_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.STR_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.STR_RSP_RMSGID_LSB : smiMsgObj.STR_RSP_RMSGID_MSB + 1);
    smiMsgObj.STR_RSP_CMSTATUS_MSB  = smiMsgObj.STR_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_STR_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.STR_RSP_NDP_PROT_LSB  = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.STR_RSP_CMSTATUS_LSB : smiMsgObj.STR_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.STR_RSP_NDP_PROT_MSB  = smiMsgObj.STR_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_STR_RSP_NDP         += smiObj.WSMINDPPROT ;

    //UPDResp
    smiMsgObj.W_UPD_RSP_NDP                  =0;
    smiMsgObj.UPD_RSP_TM_LSB        = 0;
    smiMsgObj.UPD_RSP_TM_MSB        = smiMsgObj.UPD_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_UPD_RSP_NDP         += smiObj.WSMITM ;
    smiMsgObj.UPD_RSP_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.UPD_RSP_TM_LSB : smiMsgObj.UPD_RSP_TM_MSB + 1);
    smiMsgObj.UPD_RSP_RMSGID_MSB    = smiMsgObj.UPD_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_UPD_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.UPD_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.UPD_RSP_RMSGID_LSB : smiMsgObj.UPD_RSP_RMSGID_MSB + 1);
    smiMsgObj.UPD_RSP_CMSTATUS_MSB  = smiMsgObj.UPD_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_UPD_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.UPD_RSP_NDP_PROT_LSB  = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.UPD_RSP_CMSTATUS_LSB : smiMsgObj.UPD_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.UPD_RSP_NDP_PROT_MSB  = smiMsgObj.UPD_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_UPD_RSP_NDP         += smiObj.WSMINDPPROT ;

    //RBResp
    smiMsgObj.W_RB_RSP_NDP            = 0;
    smiMsgObj.RB_RSP_TM_LSB           = 0;
    smiMsgObj.RB_RSP_TM_MSB           = smiMsgObj.RB_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_RB_RSP_NDP           += smiObj.WSMITM ;
    smiMsgObj.RB_RSP_RBID_LSB         = ((smiObj.WSMITM == 0) ? smiMsgObj.RB_RSP_TM_LSB : smiMsgObj.RB_RSP_TM_MSB + 1);
    smiMsgObj.RB_RSP_RBID_MSB         = smiMsgObj.RB_RSP_RBID_LSB + smiObj.WSMIRBID - ((smiObj.WSMIRBID > 0) ? 1 : 0);
    smiMsgObj.W_RB_RSP_NDP           += smiObj.WSMIRBID ;
    smiMsgObj.RB_RSP_CMSTATUS_LSB     = ((smiObj.WSMIRBID == 0) ? smiMsgObj.RB_RSP_RBID_LSB : smiMsgObj.RB_RSP_RBID_MSB + 1);
    smiMsgObj.RB_RSP_CMSTATUS_MSB     = smiMsgObj.RB_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_RB_RSP_NDP           += smiObj.WSMICMSTATUS ;
    smiMsgObj.RB_RSP_NDP_PROT_LSB     = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.RB_RSP_CMSTATUS_LSB : smiMsgObj.RB_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.RB_RSP_NDP_PROT_MSB     = smiMsgObj.RB_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_RB_RSP_NDP           += smiObj.WSMINDPPROT ;

    //RBUSEResp
    smiMsgObj.W_RBUSE_RSP_NDP                        =0;
    smiMsgObj.RBUSE_RSP_TM_LSB        = 0;
    smiMsgObj.RBUSE_RSP_TM_MSB        = smiMsgObj.RBUSE_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_RBUSE_RSP_NDP           += smiObj.WSMITM ;
    smiMsgObj.RBUSE_RSP_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.RBUSE_RSP_TM_LSB : smiMsgObj.RBUSE_RSP_TM_MSB + 1);
    smiMsgObj.RBUSE_RSP_RMSGID_MSB    = smiMsgObj.RBUSE_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_RBUSE_RSP_NDP           += smiObj.WSMIMSGID ;
    smiMsgObj.RBUSE_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.RBUSE_RSP_RMSGID_LSB : smiMsgObj.RBUSE_RSP_RMSGID_MSB + 1);
    smiMsgObj.RBUSE_RSP_CMSTATUS_MSB  = smiMsgObj.RBUSE_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_RBUSE_RSP_NDP           += smiObj.WSMICMSTATUS ;
    smiMsgObj.RBUSE_RSP_NDP_PROT_LSB  = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.RBUSE_RSP_CMSTATUS_LSB : smiMsgObj.RBUSE_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.RBUSE_RSP_NDP_PROT_MSB  = smiMsgObj.RBUSE_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_RBUSE_RSP_NDP           += smiObj.WSMINDPPROT ;

    //CMPResp
    smiMsgObj.W_CMP_RSP_NDP         = 0; 
    smiMsgObj.CMP_RSP_TM_LSB        = 0;
    smiMsgObj.CMP_RSP_TM_MSB        = smiMsgObj.CMP_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_CMP_RSP_NDP         += smiObj.WSMITM ;
    smiMsgObj.CMP_RSP_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.CMP_RSP_TM_LSB : smiMsgObj.CMP_RSP_TM_MSB + 1);
    smiMsgObj.CMP_RSP_RMSGID_MSB    = smiMsgObj.CMP_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_CMP_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.CMP_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.CMP_RSP_RMSGID_LSB : smiMsgObj.CMP_RSP_RMSGID_MSB + 1);
    smiMsgObj.CMP_RSP_CMSTATUS_MSB  = smiMsgObj.CMP_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_CMP_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.CMP_RSP_NDP_PROT_LSB  = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.CMP_RSP_CMSTATUS_LSB : smiMsgObj.CMP_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.CMP_RSP_NDP_PROT_MSB  = smiMsgObj.CMP_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_CMP_RSP_NDP         += smiObj.WSMINDPPROT ;

    //CMEResp
    smiMsgObj.W_CME_RSP_NDP          = 0; 
    smiMsgObj.CME_RSP_RMSGID_LSB    = 0;
    smiMsgObj.CME_RSP_RMSGID_MSB    = smiMsgObj.CME_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_CME_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.CME_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.CME_RSP_RMSGID_LSB : smiMsgObj.CME_RSP_RMSGID_MSB + 1);
    smiMsgObj.CME_RSP_CMSTATUS_MSB  = smiMsgObj.CME_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_CME_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.CME_RSP_ECMDTYPE_LSB = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.CME_RSP_CMSTATUS_LSB : smiMsgObj.CME_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.CME_RSP_ECMDTYPE_MSB = smiMsgObj.CME_RSP_ECMDTYPE_LSB + smiObj.WSMIMSGTYPE - ((smiObj.WSMIMSGTYPE > 0) ? 1 : 0);
    smiMsgObj.W_CME_RSP_NDP         += smiObj.WSMIMSGTYPE ;
    smiMsgObj.CME_RSP_NDP_PROT_LSB       = ((smiObj.WSMIECMDTYPE == 0) ? smiMsgObj.CME_RSP_ECMDTYPE_LSB : smiMsgObj.CME_RSP_ECMDTYPE_MSB + 1);
    smiMsgObj.CME_RSP_NDP_PROT_MSB       = smiMsgObj.CME_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_CME_RSP_NDP             += smiObj.WSMINDPPROT ;

    //TREResp
    smiMsgObj.W_TRE_RSP_NDP          = 0; 
    smiMsgObj.TRE_RSP_RMSGID_LSB    = 0;
    smiMsgObj.TRE_RSP_RMSGID_MSB    = smiMsgObj.TRE_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_TRE_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.TRE_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.TRE_RSP_RMSGID_LSB : smiMsgObj.TRE_RSP_RMSGID_MSB + 1);
    smiMsgObj.TRE_RSP_CMSTATUS_MSB  = smiMsgObj.TRE_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_TRE_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.TRE_RSP_ECMDTYPE_LSB  = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.TRE_RSP_CMSTATUS_LSB : smiMsgObj.TRE_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.TRE_RSP_ECMDTYPE_MSB  = smiMsgObj.TRE_RSP_ECMDTYPE_LSB + smiObj.WSMIMSGTYPE - ((smiObj.WSMIMSGTYPE > 0) ? 1 : 0);
    smiMsgObj.W_TRE_RSP_NDP         += smiObj.WSMIMSGTYPE ;
    smiMsgObj.TRE_RSP_NDP_PROT_LSB  = ((smiObj.WSMIECMDTYPE == 0) ? smiMsgObj.TRE_RSP_ECMDTYPE_LSB : smiMsgObj.TRE_RSP_ECMDTYPE_MSB + 1);
    smiMsgObj.TRE_RSP_NDP_PROT_MSB  = smiMsgObj.TRE_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_TRE_RSP_NDP         += smiObj.WSMINDPPROT ;

    //SYSReq
    smiMsgObj.W_SYS_REQ_NDP          = 0; 
    smiMsgObj.SYS_REQ_TM_LSB        = 0;
    smiMsgObj.SYS_REQ_TM_MSB        = smiMsgObj.SYS_REQ_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_SYS_REQ_NDP         += smiObj.WSMITM ;
    smiMsgObj.SYS_REQ_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.SYS_REQ_TM_LSB : smiMsgObj.SYS_REQ_TM_MSB + 1);
    smiMsgObj.SYS_REQ_RMSGID_MSB    = smiMsgObj.SYS_REQ_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_SYS_REQ_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.SYS_REQ_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.SYS_REQ_RMSGID_LSB : smiMsgObj.SYS_REQ_RMSGID_MSB + 1);
    smiMsgObj.SYS_REQ_CMSTATUS_MSB  = smiMsgObj.SYS_REQ_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_SYS_REQ_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.SYS_REQ_OP_LSB        = ((smiObj.WSMICMSTATUS == 0) ? smiMsgObj.SYS_REQ_CMSTATUS_LSB : smiMsgObj.SYS_REQ_CMSTATUS_MSB + 1);
    smiMsgObj.SYS_REQ_OP_MSB        = smiMsgObj.SYS_REQ_OP_LSB + smiObj.WSMISYSREQOP - ((smiObj.WSMISYSREQOP > 0) ? 1 : 0);
    smiMsgObj.W_SYS_REQ_NDP         += smiObj.WSMISYSREQOP ;
    smiMsgObj.SYS_REQ_REQUESTORID_LSB        = ((smiObj.WSMISYSREQOP == 0) ? smiMsgObj.SYS_REQ_OP_LSB : smiMsgObj.SYS_REQ_OP_MSB + 1);
    smiMsgObj.SYS_REQ_REQUESTORID_MSB        = smiMsgObj.SYS_REQ_REQUESTORID_LSB + smiObj.WSMIREQUESTORID - ((smiObj.WSMIREQUESTORID > 0) ? 1 : 0);
    smiMsgObj.W_SYS_REQ_NDP         += smiObj.WSMIREQUESTORID;
    smiMsgObj.SYS_REQ_NDP_PROT_LSB = ((smiObj.WSMISYSREQUESTORID == 0) ? smiMsgObj.SYS_REQ_REQUESTORID_LSB : smiMsgObj.SYS_REQ_REQUESTORID_MSB + 1);
    smiMsgObj.SYS_REQ_NDP_PROT_MSB = smiMsgObj.SYS_REQ_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_SYS_REQ_NDP         += smiObj.WSMINDPPROT ;

    //SYSRsp
    smiMsgObj.W_SYS_RSP_NDP              = 0; 
    smiMsgObj.SYS_RSP_TM_LSB        = 0;
    smiMsgObj.SYS_RSP_TM_MSB        = smiMsgObj.SYS_RSP_TM_LSB + smiObj.WSMITM - ((smiObj.WSMITM > 0) ? 1 : 0);
    smiMsgObj.W_SYS_RSP_NDP         += smiObj.WSMITM ;
    smiMsgObj.SYS_RSP_RMSGID_LSB    = ((smiObj.WSMITM == 0) ? smiMsgObj.SYS_RSP_TM_LSB : smiMsgObj.SYS_RSP_TM_MSB + 1);
    smiMsgObj.SYS_RSP_RMSGID_MSB    = smiMsgObj.SYS_RSP_RMSGID_LSB + smiObj.WSMIMSGID - ((smiObj.WSMIMSGID > 0) ? 1 : 0);
    smiMsgObj.W_SYS_RSP_NDP         += smiObj.WSMIMSGID ;
    smiMsgObj.SYS_RSP_CMSTATUS_LSB  = ((smiObj.WSMIMSGID == 0) ? smiMsgObj.SYS_RSP_RMSGID_LSB : smiMsgObj.SYS_RSP_RMSGID_MSB + 1);
    smiMsgObj.SYS_RSP_CMSTATUS_MSB  = smiMsgObj.SYS_RSP_CMSTATUS_LSB + smiObj.WSMICMSTATUS  - ((smiObj.WSMICMSTATUS  > 0) ? 1 : 0);
    smiMsgObj.W_SYS_RSP_NDP         += smiObj.WSMICMSTATUS ;
    smiMsgObj.SYS_RSP_NDP_PROT_LSB  = ((smiObj.WCMSTATUS == 0) ? smiMsgObj.SYS_RSP_CMSTATUS_LSB : smiMsgObj.SYS_RSP_CMSTATUS_MSB + 1);
    smiMsgObj.SYS_RSP_NDP_PROT_MSB  = smiMsgObj.SYS_RSP_NDP_PROT_LSB + smiObj.WSMINDPPROT - ((smiObj.WSMINDPPROT > 0) ? 1 : 0);
    smiMsgObj.W_TRE_RSP_NDP         += smiObj.WSMINDPPROT ;


    return smiMsgObj ;

}



//------------------------------------------------------------------------
//------------------------------------------------------------------------

//check this unit's rtl params against dv system params
// precondition: already extracted dv params.
function checkParams(config, rtlConfig){

    if(rtlConfig == undefined) {   
       // console.log("ERROR: checkParams: no rtl config obj specified.  \nPoint to the rtl "); clearing
    }
    else {

    //TODO reenable these checks 
    ////-- check smi widths  
    //    // for each port in rtl format
    //    var directions = ['tx','rx'];
    //    var flag = 0;
    //    for(i in directions) {
    //        for(var j = 0; j < rtlConfig.smiPortParams.directions[i].length; j++) {
    //            var portname = "rtlConfig.smiPortParams." + directions[i] + "[" + j + "]";

    //            var paramsobj = rtlConfig.smiPortParams.directions[i];

    //            //extract smi widths
    //            var smiObj = extractSmiWidthsRtl(rtlConfig, paramsobj);       
        
    //            //compare to DV reference
    //            for(paramname in smiObj) { //loop on param names (keys not values)
    //                if(typeof smiObj[paramname] !== undefined){
    //                    if(smiObj[paramname] != config.smiObj[paramname]){
    //                        console.log("\nERROR: smi widths: " + portname + ": " + paramname + 
    //                                "\t rtl width = " + smiObj[paramname]+ 
    //                                "\t dv width = " + config.smiObj[paramname]);
    //                        flag = 1;
    //                    }
    //                }
    //            }
    //        }
    //    }
    //    if(flag != 0) {
    //        throw new Error("\nsmi_widths: width checks failed, see above");        
    //    }
        
        
        //-- checks for other params...

    }
}

////------------------------------------------------------------------------------------
////parse RTL params format
//function extractSmiWidthsRtl(config, paramsobj, ifsobj){

//    var smiObj      = {};

//    //generating params for checks only.  
//    //coverage: low hanging fruit.

//    smiObj.WSMISTEER              = ifsobj.ndp_steering;
//    smiObj.WSMISRCID              = ifsobj.ndp_initiator_id;
//    smiObj.WSMITGTID              = ifsobj.ndp_target_id;
//    // smiObj.WSMINCOREUNITID        = Math.ceil(Math.log2(config.nUnits)) ;
//    // smiObj.WSMINCOREPORTID        = Math.ceil(Math.log2(unit.nSmiTx + unit.nSmiRx)); 
//    smiObj.WSMIMSGTIER            = ifsobj.ndp_t_tier; 
//    smiObj.WSMIMSGQOS             = ifsobj.ndp_ql;
//    smiObj.WSMIMSGPRI             = ifsobj.ndp_priority;
//    smiObj.WSMIMSGTYPE            = ifsobj.ndp_cm_type;
//    smiObj.WSMINDPLEN             = ifsobj.ndp_pbits;
//    smiObj.WSMINDP                = ifsobj.ndp_body;
//    smiObj.WSMIDPPRESENT          = ifsobj.ndp_dp_present;
//    // FIXME: TODO: hard wiring for now
//    //smiObj.WSMIMSGID              = ifsobj.ndp_message_id;
//    //smiObj.WSMIMSGID              = 10;
//    // smiObj.WSMIMSGUSER            = 3;  //const from spec
//    // smiObj.WSMIMSGERR             = 0;  //TODO to be implemented
//    smiObj.WSMIADDR               = config.wAddr; 

//    smiObj.CACHELINESIZE          = Math.pow(2, config.wCacheLineOffset);
            

//    return nullclean(smiObj);

//}

//-----------------------------------------------------------------------------------------
function nullclean(paramsObj){
    //modify in place but also return a ref
    for(key in paramsObj) 
        if(!paramsObj[key])
            paramsObj[key] = 0;
    return paramsObj;
}

module.exports = {
    extAllIntrlvAgents,
    extIntrlvAgents,
    node_traverse,
    unitFuncKeepSmiArr,
};


