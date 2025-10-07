//-------------------------------------------------------------------------------------------------- 
// AXI Parameters
//--------------------------------------------------------------------------------------------------

<% if (obj.testBench == "emu" ) { %>
 
<%
var axiObj = {};

//Defaults

if((obj.Block === 'dmi') || (obj.Block === 'dii')) {
   axiObj.WAWID               = obj.DutInfo.wAwId; 
   axiObj.WARID               = obj.DutInfo.wArId; 
   axiObj.WAXID               = Math.max(axiObj.WAWID, axiObj.WARID); 
   axiObj.WAXADDR             = 40;
   axiObj.WXDATA              = obj.DutInfo.wData;
   axiObj.WCDDATA             = obj.DutInfo.wData;
} else if(obj.Block === 'io_aiu' || obj.Block === 'aceaiu' ) {
    //TODO modules with upstream axi should also specify in json
   axiObj.WAWID               = obj.DutInfo.wAwId; 
   axiObj.WARID               = obj.DutInfo.wArId; 
   axiObj.WAXID               = Math.max(axiObj.WAWID, axiObj.WARID); 
   axiObj.WAXADDR             = 40;
   axiObj.WXDATA              = obj.DutInfo.wData;
   axiObj.WCDDATA             = obj.DutInfo.wData;
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
        //ANIKET: Don't really need this for DMI 
        axiObj.WCDDATA = blkSigInfo.wData; 
        axiObj.WAXADDR       = blkSigInfo.wAddr;
    } else if(obj.Block === "io_aiu") {
        axiObj.WAWID   = blkSigInfo.wAwId;
        axiObj.WARID   = blkSigInfo.wArId;

        axiObj.WAXID   = Math.max(axiObj.WAWID, axiObj.WARID);
        axiObj.WXDATA  = blkSigInfo.wData;
        //ANIKET: Don't really need this for DMI 
        axiObj.WCDDATA = blkSigInfo.wData; 
        axiObj.WAXADDR       = blkSigInfo.wAddr;
    } else if(obj.Block === "ncti") {
        axiObj.WAWID   = blkSigInfo.wAwId;
        axiObj.WARID   = blkSigInfo.wArId;

        axiObj.WAXID   = Math.max(axiObj.WAWID, axiObj.WARID);
        axiObj.WXDATA  = blkInfo.interfaces.axiInt.params.wData;
        axiObj.WAXADDR       = blkSigInfo.wAddr;
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
        if(blkInfo.fnNativeInterface === 'ACE') {
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
    axiObj.WUSEACEUNIQUE = blkSigInfo.useAceUnique ? 1 : 0; 
    axiObj.WUSEACEUSER   = (blkSigInfo.wArUser + blkSigInfo.wAwUser)>0 ? 1: 0;
}

%>
parameter <%=obj.BlockId%>_probe_WAXID               = <%=axiObj.WAXID%>;
parameter  <%=obj.BlockId%>_probe_WAWID               = <%=axiObj.WAWID%>;
parameter  <%=obj.BlockId%>_probe_WARID               = <%=axiObj.WARID%>;
parameter  <%=obj.BlockId%>_probe_WAXADDR             = <%=axiObj.WAXADDR%>;
parameter  <%=obj.BlockId%>_probe_WXDATA              = <%=axiObj.WXDATA%>;
parameter  <%=obj.BlockId%>_probe_WCDDATA             = <%=axiObj.WCDDATA%>;
parameter  <%=obj.BlockId%>_probe_WLOGXDATA           = <%=axiObj.WLOGXDATA%>;
parameter  <%=obj.BlockId%>_probe_WAWUSER             = <%=axiObj.WAWUSER%>;
parameter  <%=obj.BlockId%>_probe_WWUSER              = <%=axiObj.WWUSER%>;
parameter  <%=obj.BlockId%>_probe_WBUSER              = <%=axiObj.WBUSER%>;
parameter  <%=obj.BlockId%>_probe_WARUSER             = <%=axiObj.WARUSER%>;
parameter  <%=obj.BlockId%>_probe_WRUSER              = <%=axiObj.WRUSER%>;
parameter  <%=obj.BlockId%>_probe_WUSEACECACHE        = <%=axiObj.WUSEACECACHE%>;
parameter  <%=obj.BlockId%>_probe_WUSEACEQOS          = <%=axiObj.WUSEACEQOS%>;
parameter  <%=obj.BlockId%>_probe_WUSEACEREGION       = <%=axiObj.WUSEACEREGION%>;
parameter  <%=obj.BlockId%>_probe_WUSEACEDOMAIN       = <%=axiObj.WUSEACEDOMAIN%>;
parameter  <%=obj.BlockId%>_probe_WUSEACEUNIQUE       = <%=axiObj.WUSEACEUNIQUE%>;
parameter  <%=obj.BlockId%>_probe_WUSEACEPROT         = <%=axiObj.WUSEACEPROT%>;
parameter  <%=obj.BlockId%>_probe_WUSEACEUSER         = <%=axiObj.WUSEACEUSER%>;
parameter  <%=obj.BlockId%>_probe_CAXLEN              = <%=axiObj.CAXLEN%>;
parameter  <%=obj.BlockId%>_probe_CAXSIZE             = <%=axiObj.CAXSIZE%>;
parameter  <%=obj.BlockId%>_probe_CAXBURST            = <%=axiObj.CAXBURST%>;
parameter  <%=obj.BlockId%>_probe_CAXLOCK             = <%=axiObj.CAXLOCK%>;
parameter  <%=obj.BlockId%>_probe_CAXCACHE            = <%=axiObj.CAXCACHE%>;
parameter  <%=obj.BlockId%>_probe_CAXPROT             = <%=axiObj.CAXPROT%>;
parameter  <%=obj.BlockId%>_probe_CAXQOS              = <%=axiObj.CAXQOS%>;
parameter  <%=obj.BlockId%>_probe_CAXREGION           = <%=axiObj.CAXREGION%>;
parameter  <%=obj.BlockId%>_probe_CARSNOOP            = <%=axiObj.CARSNOOP%>;
parameter  <%=obj.BlockId%>_probe_CAWSNOOP            = <%=axiObj.CAWSNOOP%>;
parameter  <%=obj.BlockId%>_probe_CACSNOOP            = <%=axiObj.CACSNOOP%>;
parameter  <%=obj.BlockId%>_probe_CAXDOMAIN           = <%=axiObj.CAXDOMAIN%>;
parameter  <%=obj.BlockId%>_probe_CAXBAR              = <%=axiObj.CAXBAR%>;
parameter  <%=obj.BlockId%>_probe_CBRESP              = <%=axiObj.CBRESP%>;
parameter  <%=obj.BlockId%>_probe_CRRESP              = <%=axiObj.CRRESP%>;
parameter  <%=obj.BlockId%>_probe_CCRRESP             = <%=axiObj.CCRRESP%>;
parameter  <%=obj.BlockId%>_probe_CRRESPPASSDIRTYBIT  = <%=axiObj.CRRESPPASSDIRTYBIT%>;
parameter  <%=obj.BlockId%>_probe_CRRESPISSHAREDBIT   = <%=axiObj.CRRESPISSHAREDBIT%>;
parameter  <%=obj.BlockId%>_probe_CCRRESPDATXFERBIT   = <%=axiObj.CCRRESPDATXFERBIT%>;
parameter  <%=obj.BlockId%>_probe_CCRRESPERRBIT       = <%=axiObj.CCRRESPERRBIT%>;
parameter  <%=obj.BlockId%>_probe_CCRRESPPASSDIRTYBIT = <%=axiObj.CCRRESPPASSDIRTYBIT%>;
parameter  <%=obj.BlockId%>_probe_CCRRESPISSHAREDBIT  = <%=axiObj.CCRRESPISSHAREDBIT%>;
parameter  <%=obj.BlockId%>_probe_CCRRESPWASUNIQUEBIT = <%=axiObj.CCRRESPWASUNIQUEBIT%>;

// AXI-LITE-E signal types
parameter  <%=obj.BlockId%>_probe_WAWATOP             = <%=axiObj.WAWATOP%>;
parameter  <%=obj.BlockId%>_probe_WARVMIDEXT          = <%=axiObj.WARVMIDEXT%>;
parameter  <%=obj.BlockId%>_probe_WACVMIDEXT          = <%=axiObj.WACVMIDEXT%>;
parameter  <%=obj.BlockId%>_probe_WAWSTASHNID         = <%=axiObj.WAWSTASHNID%>;
parameter  <%=obj.BlockId%>_probe_WAWSTASHLPID        = <%=axiObj.WAWSTASHLPID%>; 
parameter  <%=obj.BlockId%>_probe_WRPOISON            = <%=axiObj.WRPOISON%>;
parameter  <%=obj.BlockId%>_probe_WWPOISON            = <%=axiObj.WWPOISON%>;
parameter  <%=obj.BlockId%>_probe_WCDPOISON           = <%=axiObj.WCDPOISON%>;
parameter  <%=obj.BlockId%>_probe_WRDATACHK           = <%=axiObj.WRDATACHK%>;
parameter  <%=obj.BlockId%>_probe_WWDATACHK           = <%=axiObj.WWDATACHK%>;
parameter  <%=obj.BlockId%>_probe_WCDDATACHK          = <%=axiObj.WCDDATACHK%>;
parameter  <%=obj.BlockId%>_probe_WARLOOP             = <%=axiObj.WARLOOP%>;
parameter  <%=obj.BlockId%>_probe_WAWLOOP             = <%=axiObj.WAWLOOP%>;
parameter  <%=obj.BlockId%>_probe_WRLOOP              = <%=axiObj.WRLOOP%>;
parameter  <%=obj.BlockId%>_probe_WBLOOP              = <%=axiObj.WBLOOP%>;
parameter  <%=obj.BlockId%>_probe_WAXMMUSID           = <%=axiObj.WAXMMUSID%>;
parameter  <%=obj.BlockId%>_probe_WAXMMUSSID          = <%=axiObj.WAXMMUSSID%>;
parameter  <%=obj.BlockId%>_probe_WARNSAID            = <%=axiObj.WARNSAID%>;
parameter  <%=obj.BlockId%>_probe_WAWNSAID            = <%=axiObj.WAWNSAID%>;
parameter  <%=obj.BlockId%>_probe_WCRNSAID            = <%=axiObj.WCRNSAID%>;


   /*
    <%=JSON.stringify(obj,null,' ')%>
    */


<% } %>
