//-------------------------------------------------------------------------------------------------- 
// AXI Parameters
//-------------------------------------------------------------------------------------------------- 
<%
var axiObj = {};

//Defaults
if((obj.Block === 'dmi') || (obj.Block === 'dii')) {
   axiObj.WAWID               = obj.wAwId; 
   axiObj.WARID               = obj.wArId; 
   axiObj.WAXID               = Math.max(axiObj.WAWID, axiObj.WARID); 
   axiObj.WAXADDR             = 40;
   axiObj.WXDATA              = obj.wData;
   axiObj.WCDDATA             = obj.wData;
} else if(obj.Block === 'io_aiu' || obj.Block === 'aceaiu' ) {
    //TODO modules with upstream axi should also specify in json
   axiObj.WAWID               = obj.wAwId; 
   axiObj.WARID               = obj.wArId; 
   axiObj.WAXID               = Math.max(axiObj.WAWID, axiObj.WARID); 
   axiObj.WAXADDR             = 40;
   axiObj.WXDATA              = obj.wData;
   axiObj.WCDDATA             = obj.wData;
} else {
    //TODO modules with upstream axi should also specify in json
   axiObj.WAXID               = 0; 
   axiObj.WAWID               = 0; 
   axiObj.WARID               = 0; 
   axiObj.WAXADDR             = 40;
   axiObj.WXDATA              = 128;
   axiObj.WCDDATA             = 128;
}

axiObj.WLOGXDATA           = Math.ceil(Math.log2(axiObj.WXDATA/8));
axiObj.WAWUSER             = 4;
axiObj.WWUSER              = 4; //FIXME: axiObj should be 0 in V1
axiObj.WBUSER              = 4; //FIXME: axiObj should be 0 in V1
axiObj.WARUSER             = 4;
axiObj.WRUSER              = 4; //FIXME: axiObj should be 0 in V1
axiObj.WUSEACECACHE        = 0;
axiObj.WUSEACEQOS          = 0; 
axiObj.WUSEACEREGION       = 0; 
axiObj.WUSEACEDOMAIN       = 0; 
axiObj.WUSEACEUNIQUE       = 0; 
axiObj.WUSEACEPROT         = 0; 
axiObj.WUSEACEUSER         = 0;
axiObj.CAXLEN              = 8; 
axiObj.CAXSIZE             = 3;
axiObj.CAXBURST            = 2;
axiObj.CAXLOCK             = 1;
axiObj.CAXCACHE            = 4;
axiObj.CAXPROT             = 3;
axiObj.CAXQOS              = 4;
axiObj.CAXREGION           = 4;
axiObj.CARSNOOP            = 4;
axiObj.CAWSNOOP            = 4; // Changed to 4 in ACE LITE E
axiObj.CACSNOOP            = 4;
axiObj.CAXDOMAIN           = 2;
axiObj.CAXBAR              = 2;
axiObj.CBRESP              = 2;
axiObj.CCRRESP             = 5;
axiObj.CRRESPPASSDIRTYBIT  = 2;
axiObj.CRRESPISSHAREDBIT   = 3;
axiObj.CCRRESPDATXFERBIT   = 0;
axiObj.CCRRESPERRBIT       = 1;
axiObj.CCRRESPPASSDIRTYBIT = 2;
axiObj.CCRRESPISSHAREDBIT  = 3;
axiObj.CCRRESPWASUNIQUEBIT = 4;

// AXI-LITE-E signal widths
axiObj.WAWATOP             = 6;
axiObj.WARVMIDEXT          = 4;
axiObj.WACVMIDEXT          = 4;
axiObj.WAWSTASHNID         = 11;
axiObj.WAWSTASHLPID        = 5;
axiObj.WRPOISON            = (axiObj.WXDATA < 64) ? 1 : axiObj.WXDATA/64;
axiObj.WWPOISON            = (axiObj.WXDATA < 64) ? 1 : axiObj.WXDATA/64;
axiObj.WCDPOISON           = (axiObj.WXDATA < 64) ? 1 : axiObj.WXDATA/64;
axiObj.WRDATACHK           = axiObj.WXDATA/8;
axiObj.WWDATACHK           = axiObj.WXDATA/8;
axiObj.WCDDATACHK          = axiObj.WXDATA/8;
axiObj.WARLOOP             = 8;
axiObj.WAWLOOP             = 8;
axiObj.WRLOOP              = 8;
axiObj.WBLOOP              = 8;
axiObj.WAXMMUSID           = 32;
axiObj.WAXMMUSSID          = 20;
axiObj.WARNSAID            = 4;
axiObj.WAWNSAID            = 4;
axiObj.WCRNSAID            = 4;


if((obj.Block === "aiu") || (obj.Block === "io_aiu") || (obj.Block === "aceaiu") ){
   if(obj.AiuInfo[obj.Id].interfaces.axiInt.length > 1) {
   execAxiWidths(obj.AiuInfo[obj.Id].interfaces.axiInt[0].params, obj.AiuInfo[obj.Id]);
   } else {
   execAxiWidths(obj.AiuInfo[obj.Id].interfaces.axiInt.params, obj.AiuInfo[obj.Id]);
   }
} else if(obj.Block === "dce") {
  if(obj.AiuInfo.length >0){
   if(obj.AiuInfo[0].interfaces.axiInt.length > 1) {
   execAxiWidths(obj.AiuInfo[0].interfaces.axiInt[0].params);
   } else {
   execAxiWidths(obj.AiuInfo[0].interfaces.axiInt.params);
   }
  } else {
    execAxiWidths(obj.BridgeAiuInfo[0].interfaces.axiInt.params);
  }
} else if(obj.Block === "dmi") {
    execAxiWidths(obj.DmiInfo[obj.Id].interfaces.axiInt.params, obj.DmiInfo[obj.Id]);
} else if(obj.Block === "dii") {
    execAxiWidths(obj.DiiInfo[obj.Id].interfaces.axiInt.params, obj.DiiInfo[obj.Id]);
} else if(obj.Block === "ncti") {
    execAxiWidths(obj.ncti_agents[obj.Id].interfaces.axiInt.params, obj.ncti_agents[obj.Id]);
} else {
    console.log("Unexpected obj.Block type passed: " + obj.Block);
    throw('err');
}


function execAxiWidths(blkSigInfo, blkInfo) {


    if((obj.Block === "dmi") || (obj.Block === "dii")) {
        axiObj.WAWID   = blkSigInfo.wAwId;
        axiObj.WARID   = blkSigInfo.wArId;

        axiObj.WAXID   = Math.max(axiObj.WAWID, axiObj.WARID);
        axiObj.WXDATA  = blkSigInfo.wData;
        axiObj.WLOGXDATA     = Math.ceil(Math.log2(axiObj.WXDATA/8));
        //ANIKET: Don't really need this for DMI 
        axiObj.WCDDATA = blkSigInfo.wData; 
        axiObj.WAXADDR       = blkSigInfo.wAddr;
    } else if(obj.Block === "io_aiu") {
        axiObj.WAWID   = blkSigInfo.wAwId;
        axiObj.WARID   = blkSigInfo.wArId;

        axiObj.WAXID   = Math.max(axiObj.WAWID, axiObj.WARID);
        axiObj.WXDATA  = blkSigInfo.wData;
        axiObj.WLOGXDATA     = Math.ceil(Math.log2(axiObj.WXDATA/8));
        //ANIKET: Don't really need this for DMI 
        axiObj.WCDDATA = blkSigInfo.wData; 
        axiObj.WAXADDR       = blkSigInfo.wAddr;
    } else if(obj.Block === "ncti") {
        axiObj.WAWID   = blkSigInfo.wAwId;
        axiObj.WARID   = blkSigInfo.wArId;

        axiObj.WAXID   = Math.max(axiObj.WAWID, axiObj.WARID);
        if(blkInfo.interfaces.axiInt.length > 1) {
        axiObj.WXDATA  = blkInfo.interfaces.axiInt[0].params.wData;
        } else {
        axiObj.WXDATA  = blkInfo.interfaces.axiInt.params.wData;
        }
        axiObj.WAXADDR       = blkSigInfo.wAddr;
        axiObj.WLOGXDATA     = Math.ceil(Math.log2(axiObj.WXDATA/8));
        
    } else {
        axiObj.WAXID         = Math.max(axiObj.WAWID, axiObj.WARID); 
        axiObj.WARID         = blkSigInfo.wArId; 	 
        axiObj.WAWID         = blkSigInfo.wAwId; 	 
        axiObj.WXDATA        = blkSigInfo.wData;
        axiObj.WLOGXDATA     = Math.ceil(Math.log2(axiObj.WXDATA/8));
        axiObj.WAXADDR       = blkSigInfo.wAddr;
    }
    if((obj.Block === 'aiu') || (obj.Block === 'io_aiu')) {
        if(((blkInfo.fnNativeInterface === 'ACELITE-E') || (blkInfo.fnNativeInterface === 'ACE-LITE') || (blkInfo.fnNativeInterface === 'AXI4') || (blkInfo.fnNativeInterface === 'AXI5'))){
            axiObj.WCDDATA       = blkSigInfo.wData;
        } else {
            axiObj.WCDDATA   = blkSigInfo.wCdData;
        }
        if(blkInfo.fnNativeInterface === 'ACE5'||blkInfo.fnNativeInterface === 'ACE') {
            axiObj.CRRESP              = 4;
        } else {
            axiObj.CRRESP              = 2;
        }
    } else {
        axiObj.CRRESP              = 2;
    }
    axiObj.WAWUSER       = blkSigInfo.wAwUser;
    axiObj.WWUSER        = blkSigInfo.wWUser;
    axiObj.WBUSER        = blkSigInfo.wBUser;
    axiObj.WARUSER       = blkSigInfo.wArUser;
    axiObj.WRUSER        = blkSigInfo.wRUser;
    if((obj.Block === 'dmi')) {
    axiObj.WUSEACECACHE  = 1;
    } else {
    axiObj.WUSEACECACHE  = blkSigInfo.useAceCache  ? 1 : 0;
    }
    axiObj.WUSEACEPROT   = blkSigInfo.wProt   ? 1 : 0; 
    axiObj.WUSEACEQOS    = blkSigInfo.wQos    ? 1 : 0;
    axiObj.WUSEACEREGION = blkSigInfo.wRegion ? 1 : 0; 
    axiObj.WUSEACEDOMAIN = blkSigInfo.useAceDomain ? 1 : 0; 
    axiObj.WUSEACEUNIQUE = blkSigInfo.eUnique ? 1 : 0; 
    axiObj.WUSEACEUSER   = (blkSigInfo.wArUser + blkSigInfo.wAwUser)>0 ? 1: 0;
}

%>

parameter int WREQOPCODE    = 10;
parameter WAXID               = <%=axiObj.WAXID%>;
parameter WAWID               = <%=axiObj.WAWID%>;
parameter WARID               = <%=axiObj.WARID%>;
parameter WAXADDR             = <%=axiObj.WAXADDR%>;
parameter WXDATA              = <%=axiObj.WXDATA%>;
parameter WCDDATA             = <%=axiObj.WCDDATA%>;
parameter WLOGXDATA           = <%=axiObj.WLOGXDATA%>;
parameter WAWUSER             = <%=axiObj.WAWUSER%>;
parameter WWUSER              = <%=axiObj.WWUSER%>;
parameter WBUSER              = <%=axiObj.WBUSER%>;
parameter WARUSER             = <%=axiObj.WARUSER%>;
parameter WRUSER              = <%=axiObj.WRUSER%>;
parameter WUSEACECACHE        = <%=axiObj.WUSEACECACHE%>;
parameter WUSEACEQOS          = <%=axiObj.WUSEACEQOS%>;
parameter WUSEACEREGION       = <%=axiObj.WUSEACEREGION%>;
parameter WUSEACEDOMAIN       = <%=axiObj.WUSEACEDOMAIN%>;
parameter WUSEACEUNIQUE       = <%=axiObj.WUSEACEUNIQUE%>;
parameter WUSEACEPROT         = <%=axiObj.WUSEACEPROT%>;
parameter WUSEACEUSER         = <%=axiObj.WUSEACEUSER%>;
parameter CAXLEN              = <%=axiObj.CAXLEN%>;
parameter CAXSIZE             = <%=axiObj.CAXSIZE%>;
parameter CAXBURST            = <%=axiObj.CAXBURST%>;
parameter CAXLOCK             = <%=axiObj.CAXLOCK%>;
parameter CAXCACHE            = <%=axiObj.CAXCACHE%>;
parameter CAXPROT             = <%=axiObj.CAXPROT%>;
parameter CAXQOS              = <%=axiObj.CAXQOS%>;
parameter CAXREGION           = <%=axiObj.CAXREGION%>;
parameter CARSNOOP            = <%=axiObj.CARSNOOP%>;
parameter CAWSNOOP            = <%=axiObj.CAWSNOOP%>;
parameter CACSNOOP            = <%=axiObj.CACSNOOP%>;
parameter CAXDOMAIN           = <%=axiObj.CAXDOMAIN%>;
parameter CAXBAR              = <%=axiObj.CAXBAR%>;
parameter CBRESP              = <%=axiObj.CBRESP%>;
parameter CRRESP              = <%=axiObj.CRRESP%>;
parameter CCRRESP             = <%=axiObj.CCRRESP%>;
parameter CRRESPPASSDIRTYBIT  = <%=axiObj.CRRESPPASSDIRTYBIT%>;
parameter CRRESPISSHAREDBIT   = <%=axiObj.CRRESPISSHAREDBIT%>;
parameter CCRRESPDATXFERBIT   = <%=axiObj.CCRRESPDATXFERBIT%>;
parameter CCRRESPERRBIT       = <%=axiObj.CCRRESPERRBIT%>;
parameter CCRRESPPASSDIRTYBIT = <%=axiObj.CCRRESPPASSDIRTYBIT%>;
parameter CCRRESPISSHAREDBIT  = <%=axiObj.CCRRESPISSHAREDBIT%>;
parameter CCRRESPWASUNIQUEBIT = <%=axiObj.CCRRESPWASUNIQUEBIT%>;

// AXI-LITE-E signal types
parameter WAWATOP             = <%=axiObj.WAWATOP%>;
parameter WARVMIDEXT          = <%=axiObj.WARVMIDEXT%>;
parameter WACVMIDEXT          = <%=axiObj.WACVMIDEXT%>;
parameter WAWSTASHNID         = <%=axiObj.WAWSTASHNID%>;
parameter WAWSTASHLPID        = <%=axiObj.WAWSTASHLPID%>; 
parameter WRPOISON            = <%=axiObj.WRPOISON%>;
parameter WWPOISON            = <%=axiObj.WWPOISON%>;
parameter WCDPOISON           = <%=axiObj.WCDPOISON%>;
parameter WRDATACHK           = <%=axiObj.WRDATACHK%>;
parameter WWDATACHK           = <%=axiObj.WWDATACHK%>;
parameter WCDDATACHK          = <%=axiObj.WCDDATACHK%>;
parameter WARLOOP             = <%=axiObj.WARLOOP%>;
parameter WAWLOOP             = <%=axiObj.WAWLOOP%>;
parameter WRLOOP              = <%=axiObj.WRLOOP%>;
parameter WBLOOP              = <%=axiObj.WBLOOP%>;
parameter WAXMMUSID           = <%=axiObj.WAXMMUSID%>;
parameter WAXMMUSSID          = <%=axiObj.WAXMMUSSID%>;
parameter WARNSAID            = <%=axiObj.WARNSAID%>;
parameter WAWNSAID            = <%=axiObj.WAWNSAID%>;
parameter WCRNSAID            = <%=axiObj.WCRNSAID%>;

