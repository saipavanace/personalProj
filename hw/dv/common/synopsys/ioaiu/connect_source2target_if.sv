
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

package wrapper_pkg_<%=obj.BlockId%>;
typedef enum {NONE, IS_AXI, IS_ACE_LITE, IS_ACE, IS_ACE_LITE_E
              }  arm_protocol_e;
endpackage

import wrapper_pkg_<%=obj.BlockId%>::*;

<%
let computedAxiInt;
let axiIntIsArray = false;
for(var pidx=0; pidx<obj.nAIUs; pidx++) {
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI") && obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId) {
for(var i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) {
if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
    computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
}else{
    computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
}
}}}
%>

<% if (obj.testBench !== "fsys") { %>
module <%=obj.BlockId%>_connect_source2target_if #(
      parameter wrapper_pkg_<%=obj.BlockId%>::arm_protocol_e arm_protocol = wrapper_pkg_<%=obj.BlockId%>::NONE
     )
     (interface source_if,
      interface target_if
     );
      genvar i;
      generate 
              if(arm_protocol == wrapper_pkg_<%=obj.BlockId%>::IS_ACE) begin: u_svt_ace
                  assign target_if.awid     = source_if.awid;
                  assign target_if.awaddr   = source_if.awaddr;
                  assign target_if.awlen    = source_if.awlen;
                  assign target_if.awsize   = source_if.awsize;
                  assign target_if.awburst  = source_if.awburst;
                  assign target_if.awlock   = source_if.awlock;
                  assign target_if.awcache  = source_if.awcache;
                  assign target_if.awprot   = source_if.awprot;
                  assign target_if.awqos    = source_if.awqos;
                  assign target_if.awregion = source_if.awregion;
                  assign target_if.awuser   = source_if.awuser;
                  assign target_if.awvalid  = source_if.awvalid;
                  assign source_if.awready  = target_if.awready;
                  assign target_if.awdomain = source_if.awdomain;
                  assign target_if.awsnoop  = source_if.awsnoop;
                  assign target_if.awbar    = source_if.awbar;
                  assign target_if.awunique = source_if.awunique;
                  assign target_if.awtrace = source_if.awtrace;

                  assign target_if.arid     = source_if.arid;
                  assign target_if.araddr   = source_if.araddr;
                  assign target_if.arlen    = source_if.arlen;
                  assign target_if.arsize   = source_if.arsize;
                  assign target_if.arburst  = source_if.arburst;
                  assign target_if.arlock   = source_if.arlock;
                  assign target_if.arcache  = source_if.arcache;
                  assign target_if.arprot   = source_if.arprot;
                  assign target_if.arqos    = source_if.arqos;
                  assign target_if.arregion = source_if.arregion;
                  assign target_if.aruser   = source_if.aruser;
                  assign target_if.arvalid  = source_if.arvalid;
                  assign source_if.arready  = target_if.arready;
                  assign target_if.ardomain = source_if.ardomain;
                  assign target_if.arsnoop  = source_if.arsnoop;
                  assign target_if.arbar    = source_if.arbar;
                  assign target_if.artrace    = source_if.artrace;
                  assign target_if.arvmidext    = source_if.arvmidext;

                  //assign target_if.wid      = source_if.wid;
                  assign target_if.wdata    = source_if.wdata;
                  assign target_if.wstrb    = source_if.wstrb;
                  assign target_if.wlast    = source_if.wlast;
                  assign target_if.wuser    = source_if.wuser;
                  assign target_if.wvalid   = source_if.wvalid;
                  assign source_if.wready   = target_if.wready;
                  assign source_if.wtrace   = target_if.wtrace;

                  assign source_if.bid      = target_if.bid;
                  assign source_if.bresp    = target_if.bresp;
                  assign source_if.buser    = target_if.buser;
                  assign source_if.btrace    = target_if.btrace;
                  assign source_if.bvalid   = target_if.bvalid;
                  assign target_if.bready   = source_if.bready;
                  assign target_if.wack     = source_if.wack; //<---full_sys

                  assign source_if.rid      = target_if.rid;
                  assign source_if.rdata    = target_if.rdata;
                  assign source_if.rresp    = target_if.rresp;
                  assign source_if.rlast    = target_if.rlast;
                  assign source_if.rtrace    = target_if.rtrace;
                  assign source_if.ruser    = target_if.ruser; //<---full_sys
                  assign source_if.rvalid   = target_if.rvalid;
                  assign target_if.rready   = source_if.rready;
                  assign target_if.rack     = source_if.rack; //<---full_sys

                  assign source_if.acvalid  = target_if.acvalid;
                  assign target_if.acready  = source_if.acready;
                  assign source_if.acaddr   = target_if.acaddr;
                  assign source_if.actrace  = target_if.actrace;
                  assign source_if.acsnoop  = target_if.acsnoop;
                  assign source_if.acprot   = target_if.acprot;
                  assign source_if.acvmidext = target_if.acvmidext;

                  assign target_if.crvalid  = source_if.crvalid;
                  assign source_if.crready  = target_if.crready;
                  assign target_if.crresp   = source_if.crresp;
                  assign target_if.crtrace   = source_if.crtrace;

                  assign target_if.cdvalid  = source_if.cdvalid;
                  assign source_if.cdready  = target_if.cdready;
                  assign target_if.cddata   = source_if.cddata;
                  assign target_if.cdlast   = source_if.cdlast;

            <%for(var pidx = 0; pidx < obj.nAIUs; pidx++) {%>
                 <%if(obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId){%>                  
                 <%if(computedAxiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                   assign target_if.awvalid_chk      = source_if.awvalidchk;                 
                   assign source_if.awreadychk      = target_if.awready_chk;
                   assign target_if.awid_chk         = source_if.awidchk;   
                   assign target_if.awaddr_chk       = source_if.awaddrchk; 
                   assign target_if.awlen_chk        = source_if.awlenchk;  
                   assign target_if.awctl_chk0       = source_if.awctlchk0;
                   assign target_if.awctl_chk1       = source_if.awctlchk1;
                   assign target_if.awctl_chk2       = ($test$plusargs("ace_parity_chk_conc16918_wa") && (!$test$plusargs("ace_parity_chk_err_inj_aw_chk2")))? (($countones(source_if.awdomain) + $countones(source_if.awsnoop)+ $countones(source_if.awbar)+$countones(source_if.awunique))%2)? 0 :1 :(($countones(source_if.awdomain) + $countones(source_if.awsnoop)+ $countones(source_if.awbar)+$countones(source_if.awunique))%2)? 1:0;//source_if.awctlchk2;
                   assign target_if.awuser_chk       = source_if.awuserchk;
                   assign target_if.awtrace_chk       = source_if.awtracechk;

                   assign target_if.arvalid_chk    = source_if.arvalidchk;
                   assign source_if.arreadychk    = target_if.arready_chk;
                   assign target_if.arid_chk       = source_if.aridchk;  
                   assign target_if.araddr_chk     = source_if.araddrchk;
                   assign target_if.arlen_chk      = source_if.arlenchk;
                   assign target_if.aruser_chk      = source_if.aruserchk;
                   assign target_if.artrace_chk      = source_if.artracechk;
                   assign target_if.arctl_chk0     = source_if.arctlchk0;
                   assign target_if.arctl_chk1     = source_if.arctlchk1;
                   assign target_if.arctl_chk2     = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_ar_chk2")))? (($countones(source_if.ardomain) + $countones(source_if.arsnoop)+ $countones(source_if.arbar))%2)? 0 :1 :$urandom;//source_if.arctlchk2;
                   assign target_if.arctl_chk3     = source_if.arctlchk3;

                   assign source_if.rvalidchk    = target_if.rvalid_chk;
                   assign target_if.rready_chk    = source_if.rreadychk;
                   assign source_if.ridchk       = target_if.rid_chk;  
                   assign source_if.rdatachk     = target_if.rdata_chk; 
                   assign source_if.rrespchk     = target_if.rresp_chk; 
                   assign source_if.rlastchk     = target_if.rlast_chk;
                   assign source_if.ruserchk     = target_if.ruser_chk;
                   assign source_if.rtracechk     = target_if.rtrace_chk;
                   assign target_if.rack_chk     = source_if.rackchk; //
                   //assign source_if.rdatachk  = target_if.rdatachk;
                   //assign target_if.wdatachk = source_if.wdatachk;
                   assign target_if.wvalid_chk   = source_if.wvalidchk;
                   assign source_if.wreadychk   = target_if.wready_chk;
                   assign target_if.wdata_chk    = source_if.wdatachk; 
                   assign target_if.wstrb_chk    = source_if.wstrbchk; 
                   assign target_if.wlast_chk    = source_if.wlastchk; 
                   assign target_if.wack_chk    = source_if.wackchk;
                   for(i=0;i<$bits(target_if.wuser_chk);i++)begin
                   assign target_if.wuser_chk[i]    = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_w_user")))? ~^ source_if.wuser[i*8 +: 8] : source_if.wuserchk[i];//source_if.wuserchk; 
                   end
                   assign target_if.wtrace_chk    = source_if.wtracechk; 
                   
                   assign source_if.bvalidchk    = target_if.bvalid_chk;
                   assign target_if.bready_chk    = source_if.breadychk;
                   assign source_if.bidchk       = target_if.bid_chk;  
                   assign source_if.brespchk     = target_if.bresp_chk;
                   assign source_if.buserchk     = target_if.buser_chk;
                   assign source_if.btracechk     = target_if.btrace_chk;

                   assign target_if.acready_chk   = source_if.acreadychk;
                   assign source_if.acvalidchk   = target_if.acvalid_chk;
                   assign source_if.acaddrchk    = target_if.acaddr_chk; 
                   assign source_if.acctlchk     = target_if.acctl_chk;  
                   assign source_if.actracechk   = target_if.actrace_chk;
                   assign source_if.acvmidextchk = target_if.acvmidext_chk;
                   

                   assign source_if.crreadychk  = target_if.crready_chk;
                   assign target_if.crvalid_chk  = source_if.crvalidchk;
                   assign target_if.crresp_chk   = source_if.crrespchk;
                   assign target_if.crtrace_chk  = source_if.crtracechk;
                   //assign target_if.crnsaid_chk  = source_if.crnsaidchk;
                  for( i=0;i<$bits(target_if.cddata_chk);i++)begin
                  assign target_if.cddata_chk[i]  = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_cd_data"))) ? ~^ source_if.cddata[i*8 +: 8] : source_if.cddatachk[i];//source_if.cddatachk 
                  end
                  assign source_if.cdreadychk  = target_if.cdready_chk;
                  assign target_if.cdvalid_chk  = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_cd_valid"))) ? source_if.cdvalidchk : 1;
                  assign target_if.cdlast_chk   = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_cd_last"))) ? ~ source_if.cdlast : source_if.cdlastchk;//source_if.cdlastchk
                  //assign target_if.cdtrace_chk = source_if.cdtracechk; 
                 // assign target_if.cdpoison_chk = source_if.cdpoisonchk;
                   <%}%>
                   <%}%>
                <%}%>
              end: u_svt_ace
	      else if(arm_protocol == wrapper_pkg_<%=obj.BlockId%>::IS_ACE_LITE) begin: u_svt_ace_lite
                  assign target_if.awid     = source_if.awid;
                  assign target_if.awaddr   = source_if.awaddr;
                  assign target_if.awlen    = source_if.awlen;
                  assign target_if.awsize   = source_if.awsize;
                  assign target_if.awburst  = source_if.awburst;
                  assign target_if.awlock   = source_if.awlock;
                  assign target_if.awcache  = source_if.awcache;
                  assign target_if.awprot   = source_if.awprot;
                  assign target_if.awqos    = source_if.awqos;
                  assign target_if.awregion = source_if.awregion;
                  assign target_if.awuser   = source_if.awuser;
                  assign target_if.awvalid  = source_if.awvalid;
                  assign source_if.awready  = target_if.awready;
                  assign target_if.awdomain = source_if.awdomain;
                  assign target_if.awsnoop  = source_if.awsnoop;
                  assign target_if.awbar    = source_if.awbar;
                  assign target_if.awunique = source_if.awunique;

                  assign target_if.arid     = source_if.arid;
                  assign target_if.araddr   = source_if.araddr;
                  assign target_if.arlen    = source_if.arlen;
                  assign target_if.arsize   = source_if.arsize;
                  assign target_if.arburst  = source_if.arburst;
                  assign target_if.arlock   = source_if.arlock;
                  assign target_if.arcache  = source_if.arcache;
                  assign target_if.arprot   = source_if.arprot;
                  assign target_if.arqos    = source_if.arqos;
                  assign target_if.arregion = source_if.arregion;
                  assign target_if.aruser   = source_if.aruser;
                  assign target_if.arvalid  = source_if.arvalid;
                  assign source_if.arready  = target_if.arready;
                  assign target_if.ardomain = source_if.ardomain;
                  assign target_if.arsnoop  = source_if.arsnoop;
                  assign target_if.arbar    = source_if.arbar;

                  //assign target_if.wid      = source_if.wid;
                  assign target_if.wdata    = source_if.wdata;
                  assign target_if.wstrb    = source_if.wstrb;
                  assign target_if.wlast    = source_if.wlast;
                  assign target_if.wuser    = source_if.wuser;
                  assign target_if.wvalid   = source_if.wvalid;
                  assign source_if.wready   = target_if.wready;

                  assign source_if.bid      = target_if.bid;
                  assign source_if.bresp    = target_if.bresp;
                  assign source_if.buser    = target_if.buser;
                  assign source_if.bvalid   = target_if.bvalid;
                  assign target_if.bready   = source_if.bready;

                  assign source_if.rid      = target_if.rid;
                  assign source_if.rdata    = target_if.rdata;
                  assign source_if.rresp    = target_if.rresp;
                  assign source_if.rlast    = target_if.rlast;
                  assign source_if.ruser    = target_if.ruser; //<---full_sys
                  assign source_if.rvalid   = target_if.rvalid;
                  assign target_if.rready   = source_if.rready;

                  assign source_if.acvalid  = target_if.acvalid;
                  assign target_if.acready  = source_if.acready;
                  assign source_if.acaddr   = target_if.acaddr;
                  assign source_if.acsnoop  = target_if.acsnoop;
                  assign source_if.acprot   = target_if.acprot;
                  assign source_if.actrace   = target_if.actrace;
                  assign source_if.acvmidext   = target_if.acvmidext;


                  assign target_if.crvalid  = source_if.crvalid;
                  assign source_if.crready  = target_if.crready;
                  assign target_if.crresp   = source_if.crresp;
                  assign target_if.crtrace   = source_if.crtrace;

               <%for(var pidx = 0; pidx < obj.nAIUs; pidx++) {%>
                   <%if(obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId){%>
                   <%if(computedAxiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
               
                   assign target_if.awvalid_chk      = source_if.awvalidchk;
                   assign source_if.awreadychk      = target_if.awready_chk;
                   assign target_if.awid_chk         = source_if.awidchk;   
                   assign target_if.awaddr_chk       = source_if.awaddrchk; 
                   assign target_if.awlen_chk        = source_if.awlenchk;
                   assign target_if.awctl_chk0       = source_if.awctlchk0;
                   assign target_if.awctl_chk1       = source_if.awctlchk1;

                   assign target_if.arvalid_chk    = source_if.arvalidchk;
                   assign source_if.arreadychk    = target_if.arready_chk;
                   assign target_if.arid_chk       = source_if.aridchk;  
                   assign target_if.araddr_chk     = source_if.araddrchk;
                   assign target_if.arlen_chk      = source_if.arlenchk;
                   assign target_if.arctl_chk0     = source_if.arctlchk0;
                   assign target_if.arctl_chk1     = source_if.arctlchk1;

                   assign source_if.rvalidchk    = target_if.rvalid_chk;
                   assign target_if.rready_chk    = source_if.rreadychk;
                   assign source_if.ridchk       = target_if.rid_chk;  
                   assign source_if.rdatachk     = target_if.rdata_chk; 
                   assign source_if.rrespchk     = target_if.rresp_chk; 
                   assign source_if.rlastchk     = target_if.rlast_chk;
                   //assign source_if.rdatachk  = target_if.rdatachk;
                   //assign target_if.wdatachk = source_if.wdatachk;
                   assign target_if.wvalid_chk   = source_if.wvalidchk;
                   assign source_if.wreadychk   = target_if.wready_chk;
                   assign target_if.wdata_chk    = source_if.wdatachk; 
                   assign target_if.wstrb_chk    = source_if.wstrbchk; 
                   assign target_if.wlast_chk    = source_if.wlastchk;

                   assign source_if.bvalidchk    = target_if.bvalid_chk;
                   assign target_if.bready_chk    = source_if.breadychk;
                   assign source_if.bidchk       = target_if.bid_chk;  
                   assign source_if.brespchk     = target_if.bresp_chk;

                   assign source_if.crreadychk  = target_if.crready_chk; 
                   assign target_if.crvalid_chk  = source_if.crvalidchk; 
                   assign target_if.crresp_chk   = source_if.crrespchk; 


                  <%}%>
                  <%}%>
              <%}%>
              end: u_svt_ace_lite
              else if(arm_protocol == wrapper_pkg_<%=obj.BlockId%>::IS_AXI) begin: u_svt_axi
                  assign target_if.awid     = source_if.awid;
                  assign target_if.awaddr   = source_if.awaddr;
                  assign target_if.awlen    = source_if.awlen;
                  assign target_if.awsize   = source_if.awsize;
                  assign target_if.awburst  = source_if.awburst;
                  assign target_if.awlock   = source_if.awlock;
                  assign target_if.awcache  = source_if.awcache;
                  assign target_if.awprot   = source_if.awprot;
                  assign target_if.awqos    = source_if.awqos;
                  assign target_if.awregion = source_if.awregion;
                  assign target_if.awuser   = source_if.awuser;
                  assign target_if.awvalid  = source_if.awvalid;
                  assign source_if.awready  = target_if.awready;
                  assign target_if.awatop   = source_if.awatop;
                  assign target_if.awtrace   = source_if.awtrace;

                  assign target_if.arid     = source_if.arid;
                  assign target_if.araddr   = source_if.araddr;
                  assign target_if.arlen    = source_if.arlen;
                  assign target_if.arsize   = source_if.arsize;
                  assign target_if.arburst  = source_if.arburst;
                  assign target_if.arlock   = source_if.arlock;
                  assign target_if.arcache  = source_if.arcache;
                  assign target_if.arprot   = source_if.arprot;
                  assign target_if.arqos    = source_if.arqos;
                  assign target_if.arregion = source_if.arregion;
                  assign target_if.aruser   = source_if.aruser;
                  assign target_if.arvalid  = source_if.arvalid;
                  assign source_if.arready  = target_if.arready;
                  assign target_if.arvmidext  = source_if.arvmidext;
                  assign target_if.artrace   = source_if.artrace;


                  assign target_if.wdata    = source_if.wdata;
                  assign target_if.wstrb    = source_if.wstrb;
                  assign target_if.wlast    = source_if.wlast;
                  assign target_if.wvalid   = source_if.wvalid;
                  assign source_if.wready   = target_if.wready;
                  assign target_if.wuser    = source_if.wuser;
                  assign target_if.wtrace   = source_if.wtrace;

                  assign source_if.bid      = target_if.bid;
                  assign source_if.bresp    = target_if.bresp;
                  assign source_if.bvalid   = target_if.bvalid;
                  assign target_if.bready   = source_if.bready;
                  assign source_if.btrace   = target_if.btrace;
                  assign source_if.buser    = target_if.buser;

                  assign source_if.rid      = target_if.rid;
                  assign source_if.rdata    = target_if.rdata;
                  assign source_if.rresp    = target_if.rresp;
                  assign source_if.rlast    = target_if.rlast;
                  assign source_if.rvalid   = target_if.rvalid;
                  assign target_if.rready   = source_if.rready;
                  assign source_if.rtrace   = target_if.rtrace;
                  assign source_if.ruser    = target_if.ruser;
            <%for(var pidx = 0; pidx < obj.nAIUs; pidx++) {%>
                   <%if(obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId){%>
                   <%if(computedAxiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
               
                   assign target_if.awvalid_chk      = source_if.awvalidchk;
                   assign source_if.awreadychk      = target_if.awready_chk;
                   assign target_if.awid_chk         = source_if.awidchk;   
                   assign target_if.awaddr_chk       = source_if.awaddrchk; 
                   assign target_if.awlen_chk        = source_if.awlenchk;
                   assign target_if.awctl_chk0       = source_if.awctlchk0;  
                   assign target_if.awctl_chk1       = source_if.awctlchk1;
                   assign target_if.awctl_chk3       = source_if.awctlchk3;
                   assign target_if.awuser_chk       = source_if.awuserchk;
                   assign target_if.awtrace_chk      = source_if.awtracechk;

                   assign target_if.arvalid_chk    = source_if.arvalidchk;            
                   assign source_if.arreadychk    = target_if.arready_chk;
                   assign target_if.arid_chk       = source_if.aridchk;  
                   assign target_if.araddr_chk     = source_if.araddrchk;
                   assign target_if.arlen_chk      = source_if.arlenchk;
                   assign target_if.arctl_chk0     = source_if.arctlchk0;
                   assign target_if.arctl_chk1     = source_if.arctlchk1;
                   assign target_if.arctl_chk3       = source_if.arctlchk3;
                   assign target_if.aruser_chk       = source_if.aruserchk;
                  assign target_if.artrace_chk   = source_if.artracechk;


                   assign source_if.rvalidchk    = target_if.rvalid_chk;
                   assign target_if.rready_chk    = source_if.rreadychk;
                   assign source_if.ridchk       = target_if.rid_chk;  
                   assign source_if.rdatachk     = target_if.rdata_chk; 
                   assign source_if.rrespchk     = target_if.rresp_chk; 
                   assign source_if.rlastchk     = target_if.rlast_chk;
                   assign source_if.ruserchk     = target_if.ruser_chk;
                  // assign source_if.rdatachk  = target_if.rdatachk;
                   //assign target_if.wdatachk = source_if.wdatachk;
                   assign target_if.wvalid_chk   = source_if.wvalidchk;
                   assign source_if.wreadychk   = target_if.wready_chk;
                   assign target_if.wdata_chk    = source_if.wdatachk; 
                   assign target_if.wstrb_chk    = source_if.wstrbchk; 
                   assign target_if.wlast_chk    = source_if.wlastchk;
                   for(i=0;i<$bits(target_if.wuser_chk);i++)begin
                   assign target_if.wuser_chk[i]    = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_w_user")))? ~^ source_if.wuser[i*8 +: 8] : source_if.wuserchk[i];//source_if.wuserchk; 
                   end
                   assign target_if.wtrace_chk      = source_if.wtracechk;

                   assign source_if.bvalidchk    = target_if.bvalid_chk;
                   assign target_if.bready_chk    = source_if.breadychk;
                   assign source_if.bidchk       = target_if.bid_chk;  
                   assign source_if.brespchk     = target_if.bresp_chk; 
                   assign source_if.buserchk     = target_if.buser_chk;
                  
                  <%}%>
                  <%}%>
                <%}%>
              end: u_svt_axi
              else if(arm_protocol == wrapper_pkg_<%=obj.BlockId%>::IS_ACE_LITE_E) begin: u_svt_ace_lite_e
                  assign target_if.awid     = source_if.awid;
                  assign target_if.awaddr   = source_if.awaddr;
                  assign target_if.awlen    = source_if.awlen;
                  assign target_if.awsize   = source_if.awsize;
                  assign target_if.awburst  = source_if.awburst;
                  assign target_if.awlock   = source_if.awlock;
                  assign target_if.awcache  = source_if.awcache;
                  assign target_if.awprot   = source_if.awprot;
                  assign target_if.awqos    = source_if.awqos;
                  assign target_if.awregion = source_if.awregion;
                  assign target_if.awuser   = source_if.awuser;
                  assign target_if.awvalid  = source_if.awvalid;
                  assign source_if.awready  = target_if.awready;
                  assign target_if.awdomain = source_if.awdomain;
                  assign target_if.awsnoop  = source_if.awsnoop;
                  assign target_if.awbar    = source_if.awbar;
                  assign target_if.awunique = source_if.awunique;
                  assign target_if.awatop        = source_if.awatop;
                  assign target_if.awstashnid    = source_if.awstashnid;
                  assign target_if.awstashniden  = source_if.awstashnid_en;
                  assign target_if.awstashlpid   = source_if.awstashlpid;
                  assign target_if.awstashlpiden = source_if.awstashlpid_en;
                  assign target_if.awloop        = source_if.awloop;
                  //assign target_if.awnsaid       = source_if.awnsaid; 
                  assign target_if.awtrace       = source_if.awtrace;

                  assign target_if.arid     = source_if.arid;
                  assign target_if.araddr   = source_if.araddr;
                  assign target_if.arlen    = source_if.arlen;
                  assign target_if.arsize   = source_if.arsize;
                  assign target_if.arburst  = source_if.arburst;
                  assign target_if.arlock   = source_if.arlock;
                  assign target_if.arcache  = source_if.arcache;
                  assign target_if.arprot   = source_if.arprot;
                  assign target_if.arqos    = source_if.arqos;
                  assign target_if.arregion = source_if.arregion;
                  assign target_if.aruser   = source_if.aruser;
                  assign target_if.arvalid  = source_if.arvalid;
                  assign source_if.arready  = target_if.arready;
                  assign target_if.ardomain = source_if.ardomain;
                  assign target_if.arsnoop  = source_if.arsnoop;
                  assign target_if.arbar    = source_if.arbar;
                  assign target_if.artrace       = source_if.artrace;
                  assign target_if.arvmidext     = source_if.arvmidext;

                  //assign target_if.wid      = source_if.wid;
                  assign target_if.wdata    = source_if.wdata;
                  assign target_if.wstrb    = source_if.wstrb;
                  assign target_if.wlast    = source_if.wlast;
                  assign target_if.wuser    = source_if.wuser;
                  assign target_if.wvalid   = source_if.wvalid;
                  assign source_if.wready   = target_if.wready;
                  assign target_if.wtrace   = source_if.wtrace;

                  assign source_if.bid      = target_if.bid;
                  assign source_if.bresp    = target_if.bresp;
                  assign source_if.buser    = target_if.buser;
                  assign source_if.bvalid   = target_if.bvalid;
                  assign target_if.bready   = source_if.bready;
                  assign source_if.btrace   = target_if.btrace;

                  assign source_if.rid      = target_if.rid;
                  assign source_if.rdata    = target_if.rdata;
                  assign source_if.rresp    = target_if.rresp;
                  assign source_if.rlast    = target_if.rlast;
                  assign source_if.ruser    = target_if.ruser; //<---full_sys
                  assign source_if.rvalid   = target_if.rvalid;
                  assign target_if.rready   = source_if.rready;
                  assign source_if.rtrace   = target_if.rtrace;

                  assign source_if.acvalid  = target_if.acvalid;
                  assign target_if.acready  = source_if.acready;
                  assign source_if.acaddr   = target_if.acaddr;
                  assign source_if.acsnoop  = target_if.acsnoop;
                  assign source_if.acprot   = target_if.acprot;
                  assign source_if.actrace  = target_if.actrace;
                  assign source_if.acvmidext  = target_if.acvmidext;

                  assign target_if.crvalid  = source_if.crvalid;
                  assign source_if.crready  = target_if.crready;
                  assign target_if.crresp   = source_if.crresp;
                  assign target_if.crtrace   = source_if.crtrace;
             <%for(var pidx = 0; pidx < obj.nAIUs; pidx++) {%>
                   <%if(obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId){%>
                   <%if(computedAxiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                 
                   assign target_if.awvalid_chk      = source_if.awvalidchk;
                   assign source_if.awreadychk      = target_if.awready_chk;
                   assign target_if.awid_chk         = source_if.awidchk;   
                   assign target_if.awaddr_chk       = source_if.awaddrchk; 
                   assign target_if.awlen_chk        = source_if.awlenchk;
                   assign target_if.awtrace_chk      = source_if.awtracechk;
                   assign target_if.awctl_chk0       = source_if.awctlchk0;
                   assign target_if.awctl_chk1       = source_if.awctlchk1;
                   assign target_if.awctl_chk2       = source_if.awctlchk2;
                   assign target_if.awctl_chk3       = source_if.awctlchk3;
                   assign target_if.awuser_chk         = source_if.awuserchk;   
                  assign target_if.awstashnid_chk    = source_if.awstashnidchk;
                  assign target_if.awstashlpid_chk    = source_if.awstashlpidchk;
              
                   //assign target_if.awstashnid_chk   = 0;  
                   //assign target_if.awstashlpid_chk  = 0;

                   assign target_if.arvalid_chk    = source_if.arvalidchk;
                   assign source_if.arreadychk    = target_if.arready_chk;
                   assign target_if.arid_chk       = source_if.aridchk;   
                   assign target_if.araddr_chk     = source_if.araddrchk; 
                   assign target_if.arlen_chk      = source_if.arlenchk;
                   assign target_if.aruser_chk     = source_if.aruserchk;
                   assign target_if.artrace_chk    = source_if.artracechk;
                   assign target_if.arctl_chk0     = source_if.arctlchk0;
                   assign target_if.arctl_chk1     = source_if.arctlchk1;
                   assign target_if.arctl_chk2     = source_if.arctlchk2;
                   assign target_if.arctl_chk3     = source_if.arctlchk3;

                   assign source_if.rvalidchk    = target_if.rvalid_chk;
                   assign target_if.rready_chk    = source_if.rreadychk;
                   assign source_if.ridchk       = target_if.rid_chk;  
                   assign source_if.rdatachk     = target_if.rdata_chk; 
                   assign source_if.rrespchk     = target_if.rresp_chk; 
                   assign source_if.rlastchk     = target_if.rlast_chk; 
                   assign source_if.rtracechk    = target_if.rtrace_chk;
                   assign source_if.ruserchk     = target_if.ruser_chk;
                   //assign source_if.rdatachk  = target_if.rdatachk;
                   //assign target_if.wdatachk = source_if.wdatachk;
                   
                  
                   assign target_if.wvalid_chk   = source_if.wvalidchk;
                   assign source_if.wreadychk   = target_if.wready_chk;
                   assign target_if.wdata_chk    = source_if.wdatachk; 
                   assign target_if.wstrb_chk    = source_if.wstrbchk; 
                   assign target_if.wlast_chk    = source_if.wlastchk; 
                   assign target_if.wtrace_chk   = source_if.wtracechk; 
                   for(i=0;i<$bits(target_if.wuser_chk);i++)begin
                   assign target_if.wuser_chk[i]    = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_w_user")))? ~^ source_if.wuser[i*8 +: 8] : source_if.wuserchk[i];//source_if.wuserchk; 
                   end 

                   assign source_if.bvalidchk    = target_if.bvalid_chk;
                   assign target_if.bready_chk    = source_if.breadychk;
                   assign source_if.bidchk       = target_if.bid_chk;  
                   assign source_if.brespchk     = target_if.bresp_chk; 
                   assign source_if.btracechk    = target_if.btrace_chk;
                   assign source_if.buserchk     = target_if.buser_chk;

                   assign source_if.crreadychk  = target_if.crready_chk;
                   assign target_if.crvalid_chk  = source_if.crvalidchk;
                   assign target_if.crresp_chk   = source_if.crrespchk; 
                   assign target_if.crtrace_chk  =  source_if.crtracechk ;

                    assign target_if.acready_chk   = source_if.acreadychk;
assign source_if.acvalidchk   = target_if.acvalid_chk;
assign source_if.acaddrchk    = target_if.acaddr_chk; 
assign source_if.acctlchk     = target_if.acctl_chk;  
assign source_if.actracechk   = target_if.actrace_chk;
assign source_if.acvmidextchk = target_if.acvmidext_chk;

                   
                   

                  // assign target_if.cddata_chk     = source_if.cddatachk; 
                 /// assign source_if.cdreadychk  = target_if.cdready_chk;
                 // assign target_if.cdvalid_chk  = source_if.cdvalidchk;
                 // assign target_if.cdlast_chk   = source_if.cdlastchk;
                 
                  <%}%>
                  <%}%>
                <%}%>

              end: u_svt_ace_lite_e
      endgenerate
endmodule:  <%=obj.BlockId%>_connect_source2target_if
<% } %>



<% if (obj.testBench == "fsys") { %>
module <%=obj.BlockId%>_connect_source2target_mst_if (interface source_if, interface target_if);
<% 
var ioaiu_range = [];
var ace_if_cnt=0;
var axi_acelite_if_cnt = 0;
var ace_lite_if_cnt=0;

for(var j = 0; j < obj.AiuInfo.length; j++) { 
  if((obj.AiuInfo[j].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[j].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[j].fnNativeInterface == 'CHI-E')) {
  // 
  } else { 
  ioaiu_range.push(j); //8,9,10,11...etc
  if(obj.AiuInfo[j].fnNativeInterface == 'ACE' || obj.AiuInfo[j].fnNativeInterface == 'ACE5') {
    ace_if_cnt = ace_if_cnt + 1;
  }
  if((obj.AiuInfo[j].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[j].fnNativeInterface == 'ACELITE-E')||(obj.AiuInfo[j].fnNativeInterface == 'AXI4')||(obj.AiuInfo[j].fnNativeInterface == 'AXI5')) {
    axi_acelite_if_cnt = axi_acelite_if_cnt + 1;
  }
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
var pidx = ioaiu_range[idx]; //extract by index

let signalArr = [];
var ace_lite_idx;
var ioaiu_prefix = obj.AiuInfo[pidx].strRtlNamePrefix;
var ioaiu_prefix_underscore_splitArr = [];
ioaiu_prefix_underscore_splitArr = ioaiu_prefix.split("_");
var ioaiu_prefix_underscore_cnt = ioaiu_prefix_underscore_splitArr.length;
//console.log("fsys:connect_source2target_if ioaiu_prefix_underscore_cnt="+ioaiu_prefix_underscore_cnt);
for(var port=0; port<obj.ariaObj.PortList.length; port++) {
  var finalInstName =''; 
  var finalInstNameArr = [] ; 
  var fullRTLSignalArr = [] ; 
  var fullRTLSignal = obj.ariaObj.PortList[port].rtlSignal; 
  fullRTLSignalArr = fullRTLSignal.split("_");
  //var finalInstName    = fullRTLSignal.split("_")[0];

  var fullDVSignal     = obj.ariaObj.PortList[port].dvSignal; 
  var fullSignalName   = fullDVSignal.split(".")[1]; 

  for(var temp=0; temp<ioaiu_prefix_underscore_cnt; temp++) {
    var str_temp;
    var underscore = '_';
    finalInstNameArr.push(fullRTLSignalArr[temp]);
    str_temp = finalInstNameArr[temp];
    //console.log("fsys:connect_source2target_if str_temp="+str_temp);
    if(temp==0) {
      if(ioaiu_prefix_underscore_cnt>1) {
        finalInstName = str_temp.concat(underscore);
      } else {
        finalInstName = str_temp;
      }
    }
    else if(temp<(ioaiu_prefix_underscore_cnt-1)) {
      finalInstName = finalInstName.concat(str_temp);
      finalInstName = finalInstName.concat(underscore);
    } else {
      finalInstName = finalInstName.concat(str_temp);
    }
  }

  ace_lite_idx = idx - ace_if_cnt;

  var obj1 = {};
  if(finalInstName === ioaiu_prefix && fullSignalName !==undefined) {
  obj1.instName   = finalInstName; 
  obj1.signalName = fullSignalName.split("[")[0];
  }
  signalArr.push(obj1); 
  //console.log("fsys:connect_source2target_if signalArr="+JSON.stringify(signalArr) );
  //console.log("fsys:connect_source2target_if fullRTLSignal="+fullRTLSignal+", finalInstName="+finalInstName+", fullDVSignal="+fullDVSignal+", fullSignalName="+fullSignalName);
  }
console.log("fsys:connect_source2target_if: idx="+idx+",  pidx="+pidx+",  ace_if_cnt="+ace_if_cnt+",  axi_acelite_if_cnt="+axi_acelite_if_cnt+", fnNativeInterface="+obj.AiuInfo[pidx].fnNativeInterface+", digit_loc="+digit_loc+", ioaiu_prefix="+ioaiu_prefix);
%>
wire [4:0]async_adapter_err;
wire [2:0]async_adapter_err_snp_chnl;
wire awready_err;
wire wready_err; 
wire bvalid_err;
wire arready_err;
wire rvalid_err;
wire acvalid_err;
wire cdready_err;
wire crready_err;
    genvar i;
  //-----------------------------------------------------------------------
  // AXI Interface Write Address Channel Signals
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "awid" ) ) { %>         assign target_if.awid     = source_if.awid; <% } %>
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
  <% if( signalArr.find(x => x.signalName === "awatop") ) { %>        assign target_if.awatop        = source_if.awatop; <% } %>
  <% if( signalArr.find(x => x.signalName === "awstashnid") ) { %>    assign target_if.awstashnid    = source_if.awstashnid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awstashlpid") ) { %>   assign target_if.awstashlpid   = source_if.awstashlpid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awloop") ) { %>        assign target_if.awloop        = 0; ////source_if.awloop;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awnsaid") ) { %>       assign target_if.awnsaid       = 0; //source_if.awnsaid; <% } %>  
  <% if( signalArr.find(x => x.signalName === "awstashniden") ) { %>  assign target_if.awstashniden  = source_if.awstashnid_en;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awstashlpiden") ) { %> assign target_if.awstashlpiden = source_if.awstashlpid_en;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awtrace") ) { %>       assign target_if.awtrace       = source_if.awtrace;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awvalid_chk") ) { %>      assign target_if.awvalid_chk      = source_if.awvalidchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awready_chk") ) { %>      assign source_if.awreadychk      = ($test$plusargs("axi5_parity_chk_conc17350"))? (($countones(target_if.awready)%2==0)?1:0) :target_if.awready_chk;  <% } %>
  assign async_adapter_err = ($test$plusargs("axi5_parity_chk_conc17350"))? {
  rvalid_err,
  arready_err,
  bvalid_err,
  wready_err,
  awready_err
  } : 0;
  <% if( signalArr.find(x => x.signalName === "rvalid_chk") ) { %>  assign rvalid_err    = (($countones(target_if.rvalid) + $countones(target_if.rvalid_chk))%2==0)?1:0 ; <% } %>
  <% if( signalArr.find(x => x.signalName === "arready_chk") ) { %> assign  arready_err  =  (($countones(target_if.arready) + $countones(target_if.arready_chk))%2==0)?1:0 ; <% } %>
  <% if( signalArr.find(x => x.signalName === "bvalid_chk") ) { %>  assign  bvalid_err   = (($countones(target_if.bvalid) + $countones(target_if.bvalid_chk))%2==0)?1:0 ; <% } %>
  <% if( signalArr.find(x => x.signalName === "wready_chk") ) { %>  assign  wready_err   = (($countones(target_if.wready) + $countones(target_if.wready_chk))%2==0)?1:0 ; <% } %>
  <% if( signalArr.find(x => x.signalName === "awready_chk") ) { %> assign  awready_err  =  (($countones(target_if.awready) + $countones(target_if.awready_chk))%2==0)?1:0; <% } %>
<% if( 
signalArr.find(x => x.signalName === "acvalid_chk") && 
signalArr.find(x => x.signalName === "crready_chk") && 
signalArr.find(x => x.signalName === "cdready_chk")  
) { %>
  assign async_adapter_err_snp_chnl = ($test$plusargs("axi5_parity_chk_conc17350"))? {
  crready_err,
  cdready_err,
  acvalid_err
  } : 0;
  <% if( signalArr.find(x => x.signalName === "crready_chk") ) { %>  assign crready_err  = (($countones(target_if.crready) + $countones(target_if.crready_chk))%2==0)?1:0 ; <% }  %>
  <% if( signalArr.find(x => x.signalName === "cdready_chk") ) { %>  assign cdready_err  = (($countones(target_if.cdready) + $countones(target_if.cdready_chk))%2==0)?1:0 ;  <% }  %>
  <% if( signalArr.find(x => x.signalName === "acvalid_chk") ) { %>  assign acvalid_err  = (($countones(target_if.acvalid) + $countones(target_if.acvalid_chk))%2==0)?1:0 ;<% } %>
<% } else { %>
assign async_adapter_err_snp_chnl = 0;
<% }  %>

  <% if( signalArr.find(x => x.signalName === "awid_chk") ) { %>         assign target_if.awid_chk         = source_if.awidchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awaddr_chk") ) { %>       assign target_if.awaddr_chk       = source_if.awaddrchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awlen_chk") ) { %>        assign target_if.awlen_chk        = source_if.awlenchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awctl_chk0") ) { %>       assign target_if.awctl_chk0       = source_if.awctlchk0;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awctl_chk1") ) { %>       assign target_if.awctl_chk1       = source_if.awctlchk1;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awctl_chk2") ) { %>       assign target_if.awctl_chk2       = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_aw_chk2"))) ? (($countones(source_if.awdomain) + $countones(source_if.awsnoop)+ $countones(source_if.awbar)+$countones(source_if.awunique))%2)? 0 :1 :(($countones(source_if.awdomain) + $countones(source_if.awsnoop)+ $countones(source_if.awbar)+$countones(source_if.awunique))%2)? 1 : 0 ;//source_if.awctlchk2;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awctl_chk3") ) { %>       assign target_if.awctl_chk3       = source_if.awctlchk3;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awstashnid_chk") ) { %>   assign target_if.awstashnid_chk   = source_if.awstashnidchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awstashlpid_chk") ) { %>  assign target_if.awstashlpid_chk  = source_if.awstashlpidchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awtrace_chk") ) { %>      assign target_if.awtrace_chk      = source_if.awtracechk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "awuser_chk") ) { %>      assign target_if.awuser_chk      = source_if.awuserchk;  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Read Address Channel Signals
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "arid") ) { %>          assign target_if.arid     = source_if.arid;  <% } %>
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
  <% if( signalArr.find(x => x.signalName === "arvmidext") ) { %>        assign target_if.arvmidext     = source_if.arvmidext;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arloop") ) { %>        assign target_if.arloop     = source_if.arloop;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arnsaid") ) { %>       assign target_if.arnsaid    = 0;  //source_if.arnsaid; <% } %>  
  <% if( signalArr.find(x => x.signalName === "artrace") ) { %>       assign target_if.artrace    = source_if.artrace;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arvalid_chk") ) { %>       assign target_if.arvalid_chk    = source_if.arvalidchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arready_chk") ) { %>       assign source_if.arreadychk    = ($test$plusargs("axi5_parity_chk_conc17350"))? (($countones(target_if.arready)%2==0)?1:0) :target_if.arready_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arid_chk") ) { %>          assign target_if.arid_chk       = source_if.aridchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "araddr_chk") ) { %>        assign target_if.araddr_chk     = source_if.araddrchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arlen_chk") ) { %>         assign target_if.arlen_chk      = source_if.arlenchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arctl_chk0") ) { %>        assign target_if.arctl_chk0     = source_if.arctlchk0;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arctl_chk1") ) { %>        assign target_if.arctl_chk1     = source_if.arctlchk1;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arctl_chk3") ) { %>        assign target_if.arctl_chk3     = source_if.arctlchk3;  <% } %>
  <% if( signalArr.find(x => x.signalName === "arctl_chk2") ) { %>        assign target_if.arctl_chk2     = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_ar_chk2")))? (($countones(source_if.ardomain) + $countones(source_if.arsnoop)+ $countones(source_if.arbar))%2)? 0 :1 :(($countones(source_if.ardomain) + $countones(source_if.arsnoop)+ $countones(source_if.arbar))%2) ? 1 : 0 ;//source_if.arctlchk2;  <% } %>
  <% if( signalArr.find(x => x.signalName === "artrace_chk") ) { %>       assign target_if.artrace_chk    = source_if.artracechk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "aruser_chk") ) { %>       assign target_if.aruser_chk    = source_if.aruserchk;  <% } %>
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
  <% if( signalArr.find(x => x.signalName === "rvalid_chk") ) { %>        assign source_if.rvalidchk    = ($test$plusargs("axi5_parity_chk_conc17350"))? (($countones(target_if.rvalid)%2==0)?1:0) :target_if.rvalid_chk;  <% } %> 
  <% if( signalArr.find(x => x.signalName === "rready_chk") ) { %>        assign target_if.rready_chk    = source_if.rreadychk;  <% } %> 
  <% if( signalArr.find(x => x.signalName === "rid_chk") ) { %>           assign source_if.ridchk       = target_if.rid_chk;  <% } %> 
  <% if( signalArr.find(x => x.signalName === "rdata_chk") ) { %>         assign source_if.rdatachk     = target_if.rdata_chk;  <% } %> 
  <% if( signalArr.find(x => x.signalName === "rresp_chk") ) { %>         assign source_if.rrespchk     = target_if.rresp_chk;  <% } %> 
  <% if( signalArr.find(x => x.signalName === "rlast_chk") ) { %>         assign source_if.rlastchk     = target_if.rlast_chk;  <% } %> 
  <% if( signalArr.find(x => x.signalName === "rtrace_chk") ) { %>        assign source_if.rtracechk    = target_if.rtrace_chk;  <% } %> 
  <% if( signalArr.find(x => x.signalName === "ruser_chk") ) { %>         assign source_if.ruserchk    = target_if.ruser_chk;  <% } %> 
  // AXI ACE Extension of Read Data Channel
  <% if( signalArr.find(x => x.signalName === "rack") ) { %>          assign target_if.rack     = source_if.rack;  <% } %>
  <% if( signalArr.find(x => x.signalName === "rack_chk") ) { %>          assign target_if.rack_chk     = source_if.rackchk;  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Write Channel Signals
  //-----------------------------------------------------------------------
  //wid : This is no longer used in AXI4 (only used in AXI3) Adding for legacy purposes
  //<% if( signalArr.find(x => x.signalName === "wid") ) { %>         assign target_if.wid      = source_if.master_if[0].wid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wdata") ) { %>         assign target_if.wdata    = source_if.wdata;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wstrb") ) { %>         assign target_if.wstrb    = source_if.wstrb;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wlast") ) { %>         assign target_if.wlast    = source_if.wlast;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wuser") ) { %>         assign target_if.wuser    = source_if.wuser;   <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "wpoison") ) { %>       assign target_if.wpoison  = source_if.wpoison;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wdatachk") ) { %>      assign target_if.wdatachk = source_if.wdatachk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wtrace") ) { %>        assign target_if.wtrace   = source_if.wtrace;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wvalid") ) { %>        assign target_if.wvalid   = source_if.wvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wready") ) { %>        assign source_if.wready   = target_if.wready;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wvalid_chk") ) { %>    assign target_if.wvalid_chk   = source_if.wvalidchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wready_chk") ) { %>    assign source_if.wreadychk   = ($test$plusargs("axi5_parity_chk_conc17350"))? (($countones(target_if.wready)%2==0)?1:0) :target_if.wready_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wdata_chk") ) { %>     assign target_if.wdata_chk    = source_if.wdatachk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wstrb_chk") ) { %>     assign target_if.wstrb_chk    = source_if.wstrbchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wlast_chk") ) { %>     assign target_if.wlast_chk    = source_if.wlastchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wtrace_chk") ) { %>    assign target_if.wtrace_chk   = source_if.wtracechk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wuser_chk") ) { %>   
  generate
    for(i=0;i<$bits(target_if.wuser_chk);i++)begin
      assign target_if.wuser_chk[i]    = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_w_user")))? ~^ source_if.wuser[i*8 +: 8] : source_if.wuserchk[i];
    end
  endgenerate
  //assign target_if.wuser_chk    = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_w_user")))? ~^ source_if.wuser : source_if.wuserchk;
  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Write Response Channel Signals
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "bid") ) { %>           assign source_if.bid      = target_if.bid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "bresp") ) { %>         assign source_if.bresp    = target_if.bresp;  <% } %>
  <% if( signalArr.find(x => x.signalName === "buser") ) { %>         assign source_if.buser    = target_if.buser;  <% } %>
  <% if( signalArr.find(x => x.signalName === "bvalid") ) { %>        assign source_if.bvalid   = target_if.bvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "bready") ) { %>        assign target_if.bready   = source_if.bready;  <% } %>
  // AXI ACE Extension of Write Response Channel 
  <% if( signalArr.find(x => x.signalName === "wack_chk") ) { %>      assign target_if.wack_chk   = source_if.wackchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "wack") ) { %>          assign target_if.wack     = source_if.wack;  <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "bloop") ) { %>         assign source_if.bloop    = target_if.bloop;  <% } %>
                                                                      assign source_if.bcomp    = 0;  
  <% if( signalArr.find(x => x.signalName === "btrace") ) { %>        assign source_if.btrace   = target_if.btrace;  <% } %>
  <% if( signalArr.find(x => x.signalName === "bvalid_chk") ) { %>    assign source_if.bvalidchk    = ($test$plusargs("axi5_parity_chk_conc17350"))? (($countones(target_if.bvalid)%2==0)?1:0) :target_if.bvalid_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "bready_chk") ) { %>    assign target_if.bready_chk    = source_if.breadychk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "bid_chk") ) { %>       assign source_if.bidchk       = target_if.bid_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "bresp_chk") ) { %>     assign source_if.brespchk     = target_if.bresp_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "btrace_chk") ) { %>    assign source_if.btracechk    = target_if.btrace_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "buser_chk") ) { %>         assign source_if.buserchk    = target_if.buser_chk;  <% } %>
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Address Channel Signals 
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "acvalid") ) { %>       assign source_if.acvalid  = target_if.acvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acready") ) { %>       assign target_if.acready  = source_if.acready;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acaddr") ) { %>        assign source_if.acaddr   = target_if.acaddr;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acsnoop") ) { %>       assign source_if.acsnoop  = target_if.acsnoop;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acprot") ) { %>        assign source_if.acprot   = target_if.acprot;  <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "acvmidext") ) { %>        assign source_if.acvmidext        = target_if.acvmidext;  <% } %>
  <% if( signalArr.find(x => x.signalName === "actrace") ) { %>       assign source_if.actrace       = target_if.actrace;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acready_chk") ) { %>   assign target_if.acready_chk   = source_if.acreadychk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acvalid_chk") ) { %>   assign source_if.acvalidchk   = ($test$plusargs("axi5_parity_chk_conc17350"))? (($countones(target_if.acvalid)%2==0)?1:0) :target_if.acvalid_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acaddr_chk") ) { %>    assign source_if.acaddrchk    = target_if.acaddr_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acctl_chk") ) { %>     assign source_if.acctlchk     = target_if.acctl_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "actrace_chk") ) { %>   assign source_if.actracechk   = target_if.actrace_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "acvmidext_chk") ) { %>   assign source_if.acvmidextchk   = target_if.acvmidext_chk;  <% } %>
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Response Channel Signals
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "crvalid") ) { %>       assign target_if.crvalid  = source_if.crvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "crready") ) { %>       assign source_if.crready  = target_if.crready;  <% } %>
  <% if( signalArr.find(x => x.signalName === "crresp") ) { %>        assign target_if.crresp   = source_if.crresp;  <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "crnsaid") ) { %>       assign target_if.crnsaid  = 0 ; //source_if.crnsaid; <% } %>
  <% if( signalArr.find(x => x.signalName === "crtrace") ) { %>       assign target_if.crtrace  = source_if.crtrace;  <% } %>
  <% if( signalArr.find(x => x.signalName === "crready_chk") ) { %>   assign source_if.crreadychk  = ($test$plusargs("axi5_parity_chk_conc17350"))? (($countones(target_if.crready)%2==0)?1:0) :target_if.crready_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "crvalid_chk") ) { %>   assign target_if.crvalid_chk  = source_if.crvalidchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "crresp_chk") ) { %>    assign target_if.crresp_chk   = source_if.crrespchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "crtrace_chk") ) { %>   assign target_if.crtrace_chk  = source_if.crtracechk;  <% } %>
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Data Channel Signals
  //-----------------------------------------------------------------------
  <% if( signalArr.find(x => x.signalName === "cdvalid") ) { %>       assign target_if.cdvalid  = source_if.cdvalid;  <% } %>
  <% if( signalArr.find(x => x.signalName === "cdvalid_chk") ) { %>   assign target_if.cdvalid_chk  = source_if.cdvalidchk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "cdready") ) { %>       assign source_if.cdready  = target_if.cdready;  <% } %>
  <% if( signalArr.find(x => x.signalName === "cdready_chk") ) { %>   assign source_if.cdreadychk  = ($test$plusargs("axi5_parity_chk_conc17350"))? (($countones(target_if.cdready)%2==0)?1:0) :target_if.cdready_chk;  <% } %>
  <% if( signalArr.find(x => x.signalName === "cddata") ) { %>        assign target_if.cddata   = source_if.cddata;  <% } %>
  <% if( signalArr.find(x => x.signalName === "cdlast") ) { %>        assign target_if.cdlast   = source_if.cdlast;  <% } %>
  <% if( signalArr.find(x => x.signalName === "cdlast_chk") ) { %>    assign target_if.cdlast_chk   = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_cd_last"))) ? ~ source_if.cdlast : source_if.cdlastchk;  <% } %>
  // ACE-LITE-E signals
  <% if( signalArr.find(x => x.signalName === "cddata_chk") ) { %>
  //assign target_if.cddata_chk  =  source_if.cddatachk;
                                                                 generate
                                                                    for( i=0;i<$bits(target_if.cddata_chk);i++)begin
                                                                        assign target_if.cddata_chk[i]  = ($test$plusargs("ace_parity_chk_conc16918_wa")&& (!$test$plusargs("ace_parity_chk_err_inj_cd_data"))) ? ~^ source_if.cddata[i*8 +: 8] : source_if.cddatachk[i];//source_if.cddatachk 
                                                                    end
                                                                 endgenerate
  <% } %>
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
  <% if( !signalArr.find(x => x.signalName === "awnsaid") ) { %>       assign target_if.awnsaid       = 0;  //source_if.awnsaid; <% } %>  
  <% if( !signalArr.find(x => x.signalName === "awstashniden") ) { %>  assign target_if.awstashniden  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awstashlpiden") ) { %> assign target_if.awstashlpiden =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awtrace") ) { %>       assign target_if.awtrace       =  0;  <% } %>
  //Parity Chk signals
  <% if( !signalArr.find(x => x.signalName === "awvalid_chk") ) { %>      assign target_if.awvalid_chk      = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awid_chk") ) { %>         assign target_if.awid_chk         = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awaddr_chk") ) { %>       assign target_if.awaddr_chk       = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awlen_chk") ) { %>        assign target_if.awlen_chk        = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awctl_chk0") ) { %>       assign target_if.awctl_chk0       = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awctl_chk1") ) { %>       assign target_if.awctl_chk1       = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awctl_chk2") ) { %>       assign target_if.awctl_chk2       = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awctl_chk3") ) { %>       assign target_if.awctl_chk3       = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awstashnid_chk") ) { %>   assign target_if.awstashnid_chk   = 0;//source_if.awstashnidchk;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awstashlpid_chk") ) { %>  assign target_if.awstashlpid_chk  = 0;//source_if.awstashlpidchk;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "awtrace_chk") ) { %>      assign target_if.awtrace_chk      = 0;  <% } %>
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
  <% if( !signalArr.find(x => x.signalName === "arvmidext") ) { %>        assign target_if.arvmidext     =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arloop") ) { %>        assign target_if.arloop     =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "arnsaid") ) { %>       assign target_if.arnsaid    = 0;  //source_if.arnsaid; <% } %>  
  <% if( !signalArr.find(x => x.signalName === "artrace") ) { %>       assign target_if.artrace    =  0;  <% } %>

  //Parity Chk signals
  <% if( !signalArr.find(x => x.signalName === "arvalid_chk") ) { %>       assign target_if.arvalid_chk    =0;   <% } %>
  <% if( !signalArr.find(x => x.signalName === "arid_chk") ) { %>          assign target_if.arid_chk       =0;   <% } %>
  <% if( !signalArr.find(x => x.signalName === "araddr_chk") ) { %>        assign target_if.araddr_chk     =0;   <% } %>
  <% if( !signalArr.find(x => x.signalName === "arlen_chk") ) { %>         assign target_if.arlen_chk      =0;   <% } %>
  <% if( !signalArr.find(x => x.signalName === "arctl_chk0") ) { %>        assign target_if.arctl_chk0     =0;   <% } %>
  <% if( !signalArr.find(x => x.signalName === "arctl_chk1") ) { %>        assign target_if.arctl_chk1     =0;   <% } %>
  <% if( !signalArr.find(x => x.signalName === "arctl_chk2") ) { %>        assign target_if.arctl_chk2     =0;   <% } %>
  <% if( !signalArr.find(x => x.signalName === "artrace_chk") ) { %>       assign target_if.artrace_chk    =0;   <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Read Response Channel Signals
  //-----------------------------------------------------------------------
  // ACE-LITE-E signals
  <% if( !signalArr.find(x => x.signalName === "rready") ) { %>        assign target_if.rready    =  0;  <% } %> 
  // AXI ACE Extension of Read Data Channel
  <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') { %>
  <% if( !signalArr.find(x => x.signalName === "rack") ) { %>          assign target_if.rack     =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "rack_chk") ) { %>          assign target_if.rack_chk     =  0;  <% } %>
  <% } %>
  //Parity Chk signals
  <% if( !signalArr.find(x => x.signalName === "rready_chk") ) { %>        assign target_if.rready_chk    = 0;  <% } %> 
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
  //ACE5-Parity Chk signals
  <% if( !signalArr.find(x => x.signalName === "wvalid_chk") ) { %>    assign target_if.wvalid_chk   = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "wdata_chk") ) { %>     assign target_if.wdata_chk    = 0; <% } %>
  <% if( !signalArr.find(x => x.signalName === "wstrb_chk") ) { %>     assign target_if.wstrb_chk    = 0; <% } %>
  <% if( !signalArr.find(x => x.signalName === "wlast_chk") ) { %>     assign target_if.wlast_chk    = 0; <% } %>
  <% if( !signalArr.find(x => x.signalName === "wtrace_chk") ) { %>    assign target_if.wtrace_chk   = 0;  <% } %>
  //-----------------------------------------------------------------------
  // AXI Interface Write Response Channel Signals
  //-----------------------------------------------------------------------
  <% if( !signalArr.find(x => x.signalName === "bready") ) { %>        assign target_if.bready   =  0;  <% } %>
  // AXI ACE Extension of Write Response Channel 
  <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') { %>
  <% if( !signalArr.find(x => x.signalName === "wack") ) { %>          assign target_if.wack     =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "wack_chk") ) { %>          assign target_if.wack_chk     =  0;  <% } %>
  <% } %>
  //ACE5-Parity Chk signals
  <% if( !signalArr.find(x => x.signalName === "bready_chk") ) { %>    assign target_if.bready_chk    = 0;  <% } %>
  // ACE-LITE-E signals
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Address Channel Signals 
  //-----------------------------------------------------------------------
  <% if( !signalArr.find(x => x.signalName === "acready") ) { %>       assign target_if.acready  =  0;  <% } %>
  // ACE-LITE-E signals
  <% if( !signalArr.find(x => x.signalName === "acvmidext") ) { %>        assign target_if.acvmidext        =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "actrace") ) { %>       assign source_if.actrace       =  0;  <% } %>
  //ACE5-Parity Chk signals
  <% if( !signalArr.find(x => x.signalName === "acready_chk") ) { %>   assign target_if.acready_chk   = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "actrace_chk") ) { %>   assign source_if.actracechk   = 0;  <% } %>
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Response Channel Signals
  //-----------------------------------------------------------------------
  <% if( !signalArr.find(x => x.signalName === "crvalid") ) { %>       assign target_if.crvalid  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "crresp") ) { %>        assign target_if.crresp   =  0;  <% } %>
  // ACE-LITE-E signals
  <% if( !signalArr.find(x => x.signalName === "crnsaid") ) { %>       assign target_if.crnsaid  = 0 ; //source_if.crnsaid; <% } %>
  <% if( !signalArr.find(x => x.signalName === "crtrace") ) { %>       assign target_if.crtrace  =  0;  <% } %>
  //ACE5-Parity Chk signals
  <% if( !signalArr.find(x => x.signalName === "crvalid_chk") ) { %>   assign target_if.crvalid_chk  = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "crresp_chk") ) { %>    assign target_if.crresp_chk   = 0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "crtrace_chk") ) { %>   assign target_if.crtrace_chk  = 0;  <% } %>
  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Data Channel Signals
  //-----------------------------------------------------------------------
  <% if( !signalArr.find(x => x.signalName === "cdvalid") ) { %>       assign target_if.cdvalid  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "cdvalid_chk") ) { %>   assign target_if.cdvalid_chk  =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "cddata") ) { %>        assign target_if.cddata   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "cdlast") ) { %>        assign target_if.cdlast   =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "cdlast_chk") ) { %>     assign target_if.cdlast_chk   =  0;  <% } %>
  // ACE-LITE-E signals
  <% if( !signalArr.find(x => x.signalName === "cddata_chk") ) { %>     assign target_if.cddata_chk     =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "cdpoison") ) { %>      assign target_if.cdpoison      =  0;  <% } %>
  <% if( !signalArr.find(x => x.signalName === "cdtrace") ) { %>       assign target_if.cdtrace       =  0;  <% } %>
  //ACE5-Parity Chk signals
  //<% if( !signalArr.find(x => x.signalName === "syscoreq") ) { %>    assign target_if.syscoreq      =  0;  <% } %>
endmodule:  <%=obj.BlockId%>_connect_source2target_mst_if
<% } %>
