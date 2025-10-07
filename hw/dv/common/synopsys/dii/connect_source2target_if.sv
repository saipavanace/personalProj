
//--------------------------------------------------------------------------------------------
// connect_source2target_if: This file is used to connect our In-House BFM's
//                           interface signals to the other Commertial vip's
//                           For Ex, Synopsys ACE VIP 
//                           The module's only goal is to connect any In-House
//                           interface to Driver interface so that all higher
//                           layer blocks can subscribe to Monitor (target interface).
//                           Provided both are different copies of same physical interface
//                           FIXME: Check if I need to connect slave_if as well?
//--------------------------------------------------------------------------------------------
//                           ***** USAGE Requirements *****
//                           1) For these connections to be made, this file should 
//                              be included inside the top level TB module. 
//
//                           2) By default, ARM Protocol Type is NONE. User needs to specify
//                             proper ARM Protocol that is used
//                                    IS_AXI:      If non coherent  AXI Interface
//                                    IS_ACE_LITE: If IO coherent   ACE-Lite Interface
//                                    IS_ACE:      If Full coherent ACE Interface
//                                    IS_ACE_LITE_E: If IO coherent   ACE-Lite-E Interface
//----------------------------------------------------------------------- 

`ifdef USE_VIP_SNPS
package wrapper_pkg_<%=obj.BlockId%>;
typedef enum {NONE, IS_AXI, IS_ACE_LITE, IS_ACE, IS_ACE_LITE_E
              }  arm_protocol_e;
endpackage

import wrapper_pkg_<%=obj.BlockId%>::*;

<% if (obj.testBench == "fsys" || obj.testBench == "dii") { %>
<% if (obj.testBench == "fsys") { %>
`ifdef USE_VIP_SNPS_AXI_SLAVES
<% } %>
//module <%=obj.BlockId%>_connect_source2target_mst_if (interface source_if, interface target_if);
module <%=obj.BlockId%>_connect_source2target_slv_if (<%=obj.BlockId%>_axi_if source_if, svt_axi_slave_if target_if);
<% 
var dii_range = [];

for(var j = 0; j < obj.DiiInfo.length; j++) { 
  if((obj.DiiInfo[j].fnNativeInterface == 'CHI-A')||(obj.DiiInfo[j].fnNativeInterface == 'CHI-B')) {
  // 
  } else { 
  dii_range.push(j); //8,9,10,11...etc
 } }

var digit_loc=0;
var BlockId_arr = [];
BlockId_arr = obj.BlockId.split('');

for(var j = BlockId_arr.length-1; j>=0; j--) { 
  if(BlockId_arr[j] === '0' || BlockId_arr[j] === '1' || BlockId_arr[j] === '2'|| BlockId_arr[j] === '3'|| BlockId_arr[j] === '4'|| BlockId_arr[j] === '5'|| BlockId_arr[j] === '6'|| BlockId_arr[j] === '7'|| BlockId_arr[j] === '8'|| BlockId_arr[j] === '9') {
   digit_loc = digit_loc + 1;
  } else {
   break;
  }
}
var idx = obj.BlockId.slice(0-digit_loc);
if (obj.testBench == "fsys" ) { 
  var pidx = dii_range[idx]; //extract by index
} else if (obj.testBench == "dii") {
  if (idx == "sys_dii") {
    var pidx =  0;
  } else {
    var pidx = obj.Id;
  }
}
var dii_prefix = obj.DiiInfo[pidx].strRtlNamePrefix;
var dii_prefix_underscore_splitArr = [];
dii_prefix_underscore_splitArr = dii_prefix.split("_");
var dii_prefix_underscore_cnt = dii_prefix_underscore_splitArr.length;
console.log("fsys:connect_source2target_if: idx="+idx+",  pidx="+pidx+", fnNativeInterface="+obj.DiiInfo[pidx].fnNativeInterface+", digit_loc="+digit_loc+", dii_prefix="+dii_prefix);

let signalArr = [];
for(var port=0; port<obj.ariaObj.PortList.length; port++) {
  var finalInstName =''; 
  var finalInstNameArr = [] ; 
  var fullRTLSignalArr = [] ; 
  var fullRTLSignal = obj.ariaObj.PortList[port].rtlSignal; 
  fullRTLSignalArr = fullRTLSignal.split("_");
  //var finalInstName    = fullRTLSignal.split("_")[0];

  var fullDVSignal     = obj.ariaObj.PortList[port].dvSignal; 
  var fullSignalName   = fullDVSignal.split(".")[1]; 

   for(var temp=0; temp<dii_prefix_underscore_cnt; temp++) {
    var str_temp;
    var underscore = '_';
    finalInstNameArr.push(fullRTLSignalArr[temp]);
    str_temp = finalInstNameArr[temp];
    //console.log("fsys:connect_source2target_if str_temp="+str_temp);
    if(temp==0) {
      if(dii_prefix_underscore_cnt>1) {
        finalInstName = str_temp.concat(underscore);
      } else {
        finalInstName = str_temp;
      }
    }
    else if(temp<(dii_prefix_underscore_cnt-1)) {
      finalInstName = finalInstName.concat(str_temp);
      finalInstName = finalInstName.concat(underscore);
    } else {
      finalInstName = finalInstName.concat(str_temp);
    }
  }

  var obj1 = {};
  if(finalInstName === dii_prefix && fullSignalName !==undefined ) {
  obj1.instName   = finalInstName; 
  obj1.signalName = fullSignalName.split("[")[0];
  }
  signalArr.push(obj1); 
  //console.log("fsys:connect_source2target_if signalArr="+JSON.stringify(signalArr) );
  }
  var drive_zero_to_snps_if_awid_msb = (obj.DiiInfo[pidx].interfaces.axiInt.params.wAwId<obj.DiiInfo[pidx].interfaces.axiInt.params.wArId)?1:0;
  var snps_if_awid_msb = obj.DiiInfo[pidx].interfaces.axiInt.params.wAwId;
  var snps_if_arid_msb = obj.DiiInfo[pidx].interfaces.axiInt.params.wArId;

  var drive_zero_to_snps_if_arid_msb = (obj.DiiInfo[pidx].interfaces.axiInt.params.wArId<obj.DiiInfo[pidx].interfaces.axiInt.params.wAwId)?1:0;
%>

  //-----------------------------------------------------------------------
  // AXI Interface Write Address Channel Signals
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "awid" ) ) { %>          
      <% if(drive_zero_to_snps_if_awid_msb==1) { %>
                                                                      assign target_if.awid[<%=snps_if_awid_msb-1%>:0]     = source_if.awid[<%=snps_if_awid_msb-1%>:0]; 
                                                                      assign target_if.awid[<%=snps_if_arid_msb-1%>:<%=snps_if_awid_msb%>]     = 0; 
      <% } else {%>
                                                                      assign target_if.awid     = source_if.awid; 
      <% } %>
  <% } %>
  <% if( signalArr.find(x => x.signalName === "awaddr") ) { %>        assign target_if.awaddr   = source_if.awaddr;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awlen") ) { %>         assign target_if.awlen    = source_if.awlen;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awsize") ) { %>        assign target_if.awsize   = source_if.awsize;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awburst") ) { %>       assign target_if.awburst  = source_if.awburst;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awlock") ) { %>        assign target_if.awlock   = source_if.awlock;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awcache") ) { %>       assign target_if.awcache  = source_if.awcache;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awprot") ) { %>        assign target_if.awprot   = source_if.awprot;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awqos") ) { %>         assign target_if.awqos    = source_if.awqos;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awregion") ) { %>      assign target_if.awregion = source_if.awregion;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awuser") ) { %>        assign target_if.awuser   = source_if.awuser;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awvalid") ) { %>       assign target_if.awvalid  = source_if.awvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awready") ) { %>       assign source_if.awready  = target_if.awready;  <% } %>
  // AXI ACE Extension of Write Address Channel Signals
  <% if( signalArr.find(x => x.signalName === "awdomain") ) { %>      assign target_if.awdomain = source_if.awdomain;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awsnoop") ) { %>       assign target_if.awsnoop  = source_if.awsnoop;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awbar") ) { %>         assign target_if.awbar    = source_if.awbar;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awunique") ) { %>      assign target_if.awunique = source_if.awunique;  <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "awatop") ) { %>        assign target_if.awatop        = 0; ////source_if.awatop; <% } %>
  <% if( signalArr.find(x => x.signalName === "awstashnid") ) { %>    assign target_if.awstashnid    = 0; //source_if.awstashnid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awstashlpid") ) { %>   assign target_if.awstashlpid   = 0; //source_if.awstashlpid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awloop") ) { %>        assign target_if.awloop        = 0; ////source_if.awloop;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awnsaid") ) { %>       //assign target_if.awnsaid       = 0; //source_if.awnsaid; <% } %>  
  <% if( signalArr.find(x => x.signalName === "awstashniden") ) { %>  //assign target_if.awstashniden  = 0; //source_if.awstashnid_en;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awstashlpiden") ) { %> //assign target_if.awstashlpiden = 0; //source_if.awstashlpid_en;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awtrace") ) { %>       assign target_if.awtrace       = source_if.awtrace;  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Read Address Channel Signals
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "arid") ) { %>          
      <% if(drive_zero_to_snps_if_arid_msb==1) { %>
                                                                      assign target_if.arid[<%=snps_if_arid_msb-1%>:0]     = source_if.arid[<%=snps_if_arid_msb-1%>:0];  
                                                                      assign target_if.arid[<%=snps_if_awid_msb-1%>:<%=snps_if_arid_msb%>]     = 0;  
      <% } else {%>
                                                                      assign target_if.arid     = source_if.arid;  
      <% } %>
  <% } %>
  <% if( signalArr.find(x => x.signalName === "araddr") ) { %>        assign target_if.araddr   = source_if.araddr;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arlen") ) { %>         assign target_if.arlen    = source_if.arlen;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arsize") ) { %>        assign target_if.arsize   = source_if.arsize;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arburst") ) { %>       assign target_if.arburst  = source_if.arburst;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arlock") ) { %>        assign target_if.arlock   = source_if.arlock;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arcache") ) { %>       assign target_if.arcache  = source_if.arcache;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arprot") ) { %>        assign target_if.arprot   = source_if.arprot;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arqos") ) { %>         assign target_if.arqos    = source_if.arqos;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arregion") ) { %>      assign target_if.arregion = source_if.arregion;  <% } %>
  <% if( signalArr.find(x => x.signalName === "aruser") ) { %>        assign target_if.aruser   = source_if.aruser;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arvalid") ) { %>       assign target_if.arvalid  = source_if.arvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arready") ) { %>       assign source_if.arready  = target_if.arready;  <% } %>
  // AXI ACE Extension of Read Address Channel 
  <% if( signalArr.find(x => x.signalName === "ardomain") ) { %>      assign target_if.ardomain = source_if.ardomain;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arsnoop") ) { %>       assign target_if.arsnoop  = source_if.arsnoop;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arbar") ) { %>         assign target_if.arbar    = source_if.arbar;  <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "arvmid") ) { %>        //assign target_if.arvmid     = source_if.arvmidext;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arloop") ) { %>        assign target_if.arloop     = source_if.arloop;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arnsaid") ) { %>       //assign target_if.arnsaid    = 0;  //source_if.arnsaid; <% } %>  
  <% if( signalArr.find(x => x.signalName === "artrace") ) { %>       assign target_if.artrace    = source_if.artrace;  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Read Response Channel Signals
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "rid") ) { %>           assign source_if.rid      = target_if.rid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "rdata") ) { %>         assign source_if.rdata    = target_if.rdata;  <% } %>
  <% if( signalArr.find(x => x.signalName === "rresp") ) { %>         assign source_if.rresp    = target_if.rresp;  <% } %>
  <% if( signalArr.find(x => x.signalName === "rlast") ) { %>         assign source_if.rlast    = target_if.rlast;  <% } %>
  <% if( signalArr.find(x => x.signalName === "ruser") ) { %>         assign source_if.ruser    = target_if.ruser;  <% } %> 
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "rpoison") ) { %>       assign source_if.rpoison   = target_if.rpoison;  <% } %>  
  <% if( signalArr.find(x => x.signalName === "rdatachk") ) { %>      assign source_if.rdatachk  = target_if.rdatachk;  <% } %>    
  <% if( signalArr.find(x => x.signalName === "rloop") ) { %>         assign source_if.rloop     = target_if.rloop;  <% } %>    
  <% if( signalArr.find(x => x.signalName === "rtrace") ) { %>        assign source_if.rtrace    = target_if.rtrace;  <% } %>    
  <% if( signalArr.find(x => x.signalName === "rvalid") ) { %>        assign source_if.rvalid    = target_if.rvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "rready") ) { %>        assign target_if.rready    = source_if.rready;  <% } %> 
  // AXI ACE Extension of Read Data Channel
  <% if( signalArr.find(x => x.signalName === "rack") ) { %>          assign target_if.rack     = source_if.rack;  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Write Channel Signals
  //-----------------------------------------------------------------------
  //wid : This is no longer used in AXI4 (only used in AXI3) Adding for legacy purposes
  //<% if( signalArr.find(x => x.signalName === "wid") ) { %>         assign target_if.wid      = source_if.master_if[0].wid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wdata") ) { %>         assign target_if.wdata    = source_if.wdata;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wstrb") ) { %>         assign target_if.wstrb    = source_if.wstrb;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wlast") ) { %>         assign target_if.wlast    = source_if.wlast;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wuser") ) { %>         assign target_if.wuser    = source_if.wuser;  <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "wpoison") ) { %>       assign target_if.wpoison  = source_if.wpoison;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wdatachk") ) { %>      assign target_if.wdatachk = source_if.wdatachk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wtrace") ) { %>        assign target_if.wtrace   = source_if.wtrace;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wvalid") ) { %>        assign target_if.wvalid   = source_if.wvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wready") ) { %>        assign source_if.wready   = target_if.wready;  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Write Response Channel Signals
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "bid") ) { %>           assign source_if.bid      = target_if.bid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "bresp") ) { %>         assign source_if.bresp    = target_if.bresp;  <% } %>
  <% if( signalArr.find(x => x.signalName === "buser") ) { %>         assign source_if.buser    = target_if.buser;  <% } %>
  <% if( signalArr.find(x => x.signalName === "bvalid") ) { %>        assign source_if.bvalid   = target_if.bvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "bready") ) { %>        assign target_if.bready   = source_if.bready;  <% } %>
  // AXI ACE Extension of Write Response Channel 
  <% if( signalArr.find(x => x.signalName === "wack") ) { %>          assign target_if.wack     = source_if.wack;  <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "bloop") ) { %>         assign source_if.bloop    = target_if.bloop;  <% } %>
  <% if( signalArr.find(x => x.signalName === "btrace") ) { %>        assign source_if.btrace   = target_if.btrace;  <% } %>
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Address Channel Signals 
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "acvalid") ) { %>       assign source_if.acvalid  = target_if.acvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acready") ) { %>       assign target_if.acready  = 0; //source_if.acready;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acaddr") ) { %>        assign source_if.acaddr   = target_if.acaddr;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acsnoop") ) { %>       assign source_if.acsnoop  = target_if.acsnoop;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acprot") ) { %>        assign source_if.acprot   = target_if.acprot;  <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "acvmid") ) { %>        //assign target_if.acvmid        = source_if.acvmidext;  <% } %>
  <% if( signalArr.find(x => x.signalName === "actrace") ) { %>       assign source_if.actrace       = target_if.actrace;  <% } %>
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Response Channel Signals
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "crvalid") ) { %>       assign target_if.crvalid  = source_if.crvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "crready") ) { %>       assign source_if.crready  = target_if.crready;  <% } %>
  <% if( signalArr.find(x => x.signalName === "crresp") ) { %>        assign target_if.crresp   = source_if.crresp;  <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "crnsaid") ) { %>       //assign target_if.crnsaid  = 0 ; //source_if.crnsaid; <% } %>
  <% if( signalArr.find(x => x.signalName === "crtrace") ) { %>       assign target_if.crtrace  = source_if.crtrace;  <% } %>
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Data Channel Signals
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "cdvalid") ) { %>       assign target_if.cdvalid  = source_if.cdvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "cdready") ) { %>       assign source_if.cdready  = target_if.cdready;  <% } %>
  <% if( signalArr.find(x => x.signalName === "cddata") ) { %>        assign target_if.cddata   = source_if.cddata;  <% } %>
  <% if( signalArr.find(x => x.signalName === "cdlast") ) { %>        assign target_if.cdlast   = source_if.cdlast;  <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "cddatachk") ) { %>     assign target_if.cddatachk     = source_if.cddatachk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "cdpoison") ) { %>      assign target_if.cdpoison      = source_if.cdpoison;  <% } %>
  <% if( signalArr.find(x => x.signalName === "cdtrace") ) { %>       assign target_if.cdtrace       = source_if.cdtrace;  <% } %>
  //<% if( signalArr.find(x => x.signalName === "syscoreq") ) { %>    assign target_if.syscoreq      = source_if.syscoreq;  <% } %>
  //<% if( signalArr.find(x => x.signalName === "syscoack") ) { %>    assign source_if.syscoack      = target_if.syscoack;  <% } %>
////////////////////////////////////////////////////////////////////////
/////
//Tieoffs
/////
////////////////////////////////////////////////////////////////////////
  //Temporary try
  <% if( signalArr.find(x => x.signalName === "acvalid") ) { %>       //assign source_if.acwakeup  = 0; assign source_if.actrace  = 0; <% } %>

  //-----------------------------------------------------------------------
  // AXI Interface Write Address Channel Signals
  //-----------------------------------------------------------------------
  <% if( !signalArr.find(x => x.signalName === "awid" ) ) { %>         assign target_if.awid     =  0; <% } %>
  <% if( !signalArr.find(x => x.signalName === "awaddr") ) { %>        assign target_if.awaddr   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awlen") ) { %>         assign target_if.awlen    =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awsize") ) { %>        assign target_if.awsize   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awburst") ) { %>       assign target_if.awburst  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awlock") ) { %>        assign target_if.awlock   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awcache") ) { %>       assign target_if.awcache  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awprot") ) { %>        assign target_if.awprot   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awqos") ) { %>         assign target_if.awqos    =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awregion") ) { %>      assign target_if.awregion =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awuser") ) { %>        assign target_if.awuser   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awvalid") ) { %>       assign target_if.awvalid  =  0;  <% } %>
  // AXI ACE Extension of Write Address Channel Signals
  <% if( !signalArr.find(x => x.signalName === "awdomain") ) { %>      assign target_if.awdomain =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awsnoop") ) { %>       assign target_if.awsnoop  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awbar") ) { %>         assign target_if.awbar    =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awunique") ) { %>      assign target_if.awunique =  0;  <% } %>
  // ACE-LITE-E signals
  <% if( !signalArr.find(x => x.signalName === "awatop") ) { %>        assign target_if.awatop        =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awstashnid") ) { %>    assign target_if.awstashnid    =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awstashlpid") ) { %>   assign target_if.awstashlpid   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awloop") ) { %>        assign target_if.awloop        =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awnsaid") ) { %>       //assign target_if.awnsaid       = 0;  //source_if.awnsaid; <% } %>  
  <% if( !signalArr.find(x => x.signalName === "awstashniden") ) { %>  //assign target_if.awstashniden  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awstashlpiden") ) { %> //assign target_if.awstashlpiden =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awtrace") ) { %>       assign target_if.awtrace       =  0;  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Read Address Channel Signals
  //-----------------------------------------------------------------------
  <% if( !signalArr.find(x => x.signalName === "arid") ) { %>          assign target_if.arid     =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "araddr") ) { %>        assign target_if.araddr   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arlen") ) { %>         assign target_if.arlen    =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arsize") ) { %>        assign target_if.arsize   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arburst") ) { %>       assign target_if.arburst  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arlock") ) { %>        assign target_if.arlock   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arcache") ) { %>       assign target_if.arcache  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arprot") ) { %>        assign target_if.arprot   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arqos") ) { %>         assign target_if.arqos    =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arregion") ) { %>      assign target_if.arregion =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "aruser") ) { %>        assign target_if.aruser   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arvalid") ) { %>       assign target_if.arvalid  =  0;  <% } %>
  // AXI ACE Extension of Read Address Channel 
  <% if( !signalArr.find(x => x.signalName === "ardomain") ) { %>      assign target_if.ardomain =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arsnoop") ) { %>       assign target_if.arsnoop  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arbar") ) { %>         assign target_if.arbar    =  0;  <% } %>
  // ACE-LITE-E signals
  <% if( !signalArr.find(x => x.signalName === "arvmid") ) { %>        //assign target_if.arvmid     =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arloop") ) { %>        assign target_if.arloop     =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arnsaid") ) { %>       //assign target_if.arnsaid    = 0;  //source_if.arnsaid; <% } %>  
  <% if( !signalArr.find(x => x.signalName === "artrace") ) { %>       assign target_if.artrace    =  0;  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Read Response Channel Signals
  //-----------------------------------------------------------------------
  // ACE-LITE-E signals
  <% if( !signalArr.find(x => x.signalName === "rready") ) { %>        assign target_if.rready    =  0;  <% } %> 
  // AXI ACE Extension of Read Data Channel
  <% if(obj.DiiInfo[pidx].fnNativeInterface == 'ACE') { %>
  <% if( !signalArr.find(x => x.signalName === "rack") ) { %>          assign target_if.rack     =  0;  <% } %>
  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Write Channel Signals
  //-----------------------------------------------------------------------
  //wid : This is no longer used in AXI4 (only used in AXI3) Adding for legacy purposes
  //<% if( !signalArr.find(x => x.signalName === "wid") ) { %>         assign target_if.wid      =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "wdata") ) { %>         assign target_if.wdata    =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "wstrb") ) { %>         assign target_if.wstrb    =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "wlast") ) { %>         assign target_if.wlast    =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "wuser") ) { %>         assign target_if.wuser    =  0;  <% } %>
  // ACE-LITE-E signals
  <% if( !signalArr.find(x => x.signalName === "wpoison") ) { %>       assign target_if.wpoison  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "wdatachk") ) { %>      assign target_if.wdatachk =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "wtrace") ) { %>        assign target_if.wtrace   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "wvalid") ) { %>        assign target_if.wvalid   =  0;  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Write Response Channel Signals
  //-----------------------------------------------------------------------
  <% if( !signalArr.find(x => x.signalName === "bready") ) { %>        assign target_if.bready   =  0;  <% } %>
  // AXI ACE Extension of Write Response Channel 
  <% if(obj.DiiInfo[pidx].fnNativeInterface == 'ACE') { %>
  <% if( !signalArr.find(x => x.signalName === "wack") ) { %>          assign target_if.wack     =  0;  <% } %>
  <% } %>
  // ACE-LITE-E signals
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Address Channel Signals 
  //-----------------------------------------------------------------------
  <% if( !signalArr.find(x => x.signalName === "acready") ) { %>       assign target_if.acready  =  0;  <% } %>
  // ACE-LITE-E signals
  <% if( !signalArr.find(x => x.signalName === "acvmid") ) { %>        //assign target_if.acvmid        =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "actrace") ) { %>       assign source_if.actrace       =  0;  <% } %>
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Response Channel Signals
  //-----------------------------------------------------------------------
  <% if( !signalArr.find(x => x.signalName === "crvalid") ) { %>       assign target_if.crvalid  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "crresp") ) { %>        assign target_if.crresp   =  0;  <% } %>
  // ACE-LITE-E signals
  <% if( !signalArr.find(x => x.signalName === "crnsaid") ) { %>       //assign target_if.crnsaid  = 0 ; //source_if.crnsaid; <% } %>
  <% if( !signalArr.find(x => x.signalName === "crtrace") ) { %>       assign target_if.crtrace  =  0;  <% } %>
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Data Channel Signals
  //-----------------------------------------------------------------------
  <% if( !signalArr.find(x => x.signalName === "cdvalid") ) { %>       assign target_if.cdvalid  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "cddata") ) { %>        assign target_if.cddata   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "cdlast") ) { %>        assign target_if.cdlast   =  0;  <% } %>
  // ACE-LITE-E signals
  <% if( !signalArr.find(x => x.signalName === "cddatachk") ) { %>     assign target_if.cddatachk     =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "cdpoison") ) { %>      assign target_if.cdpoison      =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "cdtrace") ) { %>       assign target_if.cdtrace       =  0;  <% } %>
  //<% if( !signalArr.find(x => x.signalName === "syscoreq") ) { %>    assign target_if.syscoreq      =  0;  <% } %>
endmodule:  <%=obj.BlockId%>_connect_source2target_slv_if
<% if (obj.testBench == "fsys") { %>
`endif // `ifdef USE_VIP_SNPS_AXI_SLAVES
<% } %>
<% } %>
`endif // `ifdef USE_VIP_SNPS
