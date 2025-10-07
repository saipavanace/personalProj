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
    if((obj.AiuInfo[idx].fnNativeInterface == 'AXI4' || obj.AiuInfo[idx].fnNativeInterface == 'AXI5' )) {
      axiaiu_idx += obj.AiuInfo[idx].nNativeInterfacePorts;
    } else if((obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')){
      aceliteeaiu_idx += obj.AiuInfo[idx].nNativeInterfacePorts;
    } else if((obj.AiuInfo[idx].fnNativeInterface == 'ACE'|| obj.AiuInfo[idx].fnNativeInterface == 'ACE5' )){
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
    retObj.smiObj = extractSmiWidths(obj);  
    retObj.smiMsgObj = extractSmiMsgFields(retObj.smiObj); 
    retObj.isTopLevel = 1;
    retObj.SNPS_PERF = 0;
    retObj.DISABLE_CDN_AXI5  = 0;
    retObj.testBench = 'cust_tb';
    retObj.enInternalCode = process.env.ENABLE_INTERNAL_CODE; //(process.env.MAESTRO_SERVER_DEBUG_MODE).toLowerCase() === 'true';
    //retObj.enInternalCode = (process.env.MAESTRO_SERVER_DEBUG_MODE ?? 'false').toLowerCase() === 'true';
    return retObj;
}

function extractSmiWidths(config) {

    let smiObj = {};

    //sys toplevel params
    smiObj.WSEC                   = config.wSecurityAttribute;
    smiObj.CACHELINESIZE          = Math.pow(2, config.wCacheLineOffset);
    smiObj.WNUNITID               = config.wNUnitId;

    //Physical Layer
    smiObj.WSMINDPLEN             = config.Widths.Physical.wNdpLen;   
    smiObj.WSMINDP                = config.Widths.Physical.wNdpBody;    //TODO: ndp body has sizeof largest ndp ?== cmd  
    smiObj.WSMIDPPRESENT          = config.Widths.Physical.wDpPresent;
    
    //Transport Layer
    smiObj.WSMIMSGERR             = config.Widths.Transport.wMsgErr  //exists only from legato towards DUT


    //Concerto Layer
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //NDP Header
    smiObj.WSMINCOREUNITID        = config.Widths.Concerto.Ndp.Header.wFUnitId ;
    smiObj.WSMINCOREPORTID        = config.Widths.Concerto.Ndp.Header.wFPortId ;
    smiObj.WSMITGTID              = smiObj.WSMINCOREUNITID + smiObj.WSMINCOREPORTID ;
    smiObj.WSMISRCID              = smiObj.WSMINCOREUNITID + smiObj.WSMINCOREPORTID ;
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

    let smiMsgObj      = {};

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
    smiMsgObj.SYS_REQ_NDP_PROT_LSB = ((smiObj.WSMISYSREQOP == 0) ? smiMsgObj.SYS_REQ_OP_LSB : smiMsgObj.SYS_REQ_OP_MSB + 1);
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


module.exports = {
    formatFunc
}

