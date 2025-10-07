
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
//                           2) By default, Source Interface tpye is undefined. User needs to
//                              select proper Interface & Protocol type
//                              Current Valid Source Interface types
//                                   SYNOPSYS_ARM_VIP: If using Synopsys VIP.
//                                                     Supports ACE, ACELite & AXI4
//                                   OPEN_SRC_AXI:     If Using Open Source AXI VIP
//                                                     Supports only AXI4
//
//                           3)By default, ARM Protocol Type is NONE. User needs to specify
//                             proper ARM Protocol that is used
//                                    IS_AXI:      If non coherent  AXI Interface
//                                    IS_ACE_LITE: If IO coherent   ACE-Lite Interface
//                                    IS_ACE:      If Full coherent ACE Interface
//----------------------------------------------------------------------- 

typedef enum {UNDEFINED, SYNOPSYS_ARM_VIP, OPEN_SRC_AXI, 
              AXI, SFI_ACE_MODEL, CADENCE_ARM_VIP}  src_if_type_e;

typedef enum {NONE, IS_AXI, IS_ACE_LITE, IS_ACE, SFI_AXI,
              SFI_ACE_AXI_MODEL}  arm_protocol_e;

module connect_source2target_if #(
      parameter src_if_type_e  src_if_type  = UNDEFINED,
      parameter arm_protocol_e arm_protocol = NONE
     )
     (interface source_if,
      interface target_if
     );

      generate 
          if(src_if_type == SYNOPSYS_ARM_VIP) begin: G1
              if(arm_protocol == IS_ACE) begin: u_svt_ace
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
                  assign target_if.wack     = source_if.wack;

                  assign source_if.rid      = target_if.rid;
                  assign source_if.rdata    = target_if.rdata;
                  assign source_if.rresp    = target_if.rresp;
                  assign source_if.rlast    = target_if.rlast;
                  assign source_if.ruser    = target_if.ruser;
                  assign source_if.rvalid   = target_if.rvalid;
                  assign target_if.rready   = source_if.rready;
                  assign target_if.rack     = source_if.rack;

                  assign source_if.acvalid  = target_if.acvalid;
                  assign target_if.acready  = source_if.acready;
                  assign source_if.acaddr   = target_if.acaddr;
                  assign source_if.acsnoop  = target_if.acsnoop;
                  assign source_if.acprot   = target_if.acprot;

                  assign target_if.crvalid  = source_if.crvalid;
                  assign source_if.crready  = target_if.crready;
                  assign target_if.crresp   = source_if.crresp;

                  assign target_if.cdvalid  = source_if.cdvalid;
                  assign source_if.cdready  = target_if.cdready;
                  assign target_if.cddata   = source_if.cddata;
                  assign target_if.cdlast   = source_if.cdlast;
              end: u_svt_ace
              else if(arm_protocol == IS_ACE_LITE) begin: u_svt_ace_lite
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
                  assign target_if.awready  = source_if.awready;
                  assign target_if.awdomain = source_if.awdomain;
                  assign target_if.awsnoop  = source_if.awsnoop;
                  assign target_if.awatop   = source_if.awatop;
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
                  assign target_if.arready  = source_if.arready;
                  assign target_if.ardomain = source_if.ardomain;
                  assign target_if.arsnoop  = source_if.arsnoop;
                  assign target_if.arbar    = source_if.arbar;

                  //assign target_if.wid      = source_if.wid;
                  assign target_if.wdata    = source_if.wdata;
                  assign target_if.wstrb    = source_if.wstrb;
                  assign target_if.wlast    = source_if.wlast;
                  assign target_if.wuser    = source_if.wuser;
                  assign target_if.wvalid   = source_if.wvalid;
                  assign target_if.wready   = source_if.wready;

                  assign target_if.bid      = source_if.bid;
                  assign target_if.bresp    = source_if.bresp;
                  assign target_if.buser    = source_if.buser;
                  assign target_if.bvalid   = source_if.bvalid;
                  assign target_if.bready   = source_if.bready;

                  assign target_if.rid      = source_if.rid;
                  assign target_if.rdata    = source_if.rdata;
                  assign target_if.rresp    = source_if.rresp;
                  assign target_if.rlast    = source_if.rlast;
                  assign target_if.ruser    = source_if.ruser;
                  assign target_if.rvalid   = source_if.rvalid;
                  assign target_if.rready   = source_if.rready;
              end: u_svt_ace_lite
              else if(arm_protocol == IS_AXI) begin: u_svt_axi
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
                  assign target_if.awvalid  = source_if.awvalid;
                  assign target_if.awready  = source_if.awready;

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
                  assign target_if.arvalid  = source_if.arvalid;
                  assign target_if.arready  = source_if.arready;

                  assign target_if.wdata    = source_if.wdata;
                  assign target_if.wstrb    = source_if.wstrb;
                  assign target_if.wlast    = source_if.wlast;
                  assign target_if.wvalid   = source_if.wvalid;
                  assign target_if.wready   = source_if.wready;

                  assign target_if.bid      = source_if.bid;
                  assign target_if.bresp    = source_if.bresp;
                  assign target_if.bvalid   = source_if.bvalid;
                  assign target_if.bready   = source_if.bready;

                  assign target_if.rid      = source_if.rid;
                  assign target_if.rdata    = source_if.rdata;
                  assign target_if.rresp    = source_if.rresp;
                  assign target_if.rlast    = source_if.rlast;
                  assign target_if.rvalid   = source_if.rvalid;
                  assign target_if.rready   = source_if.rready;
              end: u_svt_axi
 
          end
          else if(src_if_type == OPEN_SRC_AXI) begin: G2
              if(arm_protocol == IS_AXI) begin: u_opensrc_axi
                  assign target_if.awid     = source_if.AXI_AWID;
                  assign target_if.awaddr   = source_if.AXI_AWADDR;
                  assign target_if.awlen    = source_if.AXI_AWLEN;
                  assign target_if.awsize   = source_if.AXI_AWSIZE;
                  assign target_if.awburst  = source_if.AXI_AWBURST;
                  assign target_if.awlock   = source_if.AXI_AWLOCK;
                  assign target_if.awcache  = source_if.AXI_AWCACHE;
                  assign target_if.awprot   = source_if.AXI_AWPROT;
                  assign target_if.awqos    = source_if.AXI_AWQOS;
                  assign target_if.awregion = source_if.AXI_AWREG;
                  assign target_if.awvalid  = source_if.AXI_AWVALID;
                  assign target_if.awready  = source_if.AXI_AWREADY;

                  assign target_if.arid     = source_if.AXI_ARID;
                  assign target_if.araddr   = source_if.AXI_ARADDR;
                  assign target_if.arlen    = source_if.AXI_ARLEN;
                  assign target_if.arsize   = source_if.AXI_ARSIZE;
                  assign target_if.arburst  = source_if.AXI_ARBURST;
                  assign target_if.arlock   = source_if.AXI_ARLOCK;
                  assign target_if.arcache  = source_if.AXI_ARCACHE;
                  assign target_if.arprot   = source_if.AXI_ARPROT;
                  assign target_if.arqos    = source_if.AXI_ARQOS;
                  assign target_if.arregion = source_if.AXI_ARREG;
                  assign target_if.arvalid  = source_if.AXI_ARVALID;
                  assign target_if.arready  = source_if.AXI_ARREADY;

                  //assign target_if.wid      = source_if.AXI_WID;
                  assign target_if.wdata    = source_if.AXI_WDATA;
                  assign target_if.wstrb    = source_if.AXI_WSTRB;
                  assign target_if.wlast    = source_if.AXI_WLAST;
                  assign target_if.wvalid   = source_if.AXI_WVALID;
                  assign target_if.wready   = source_if.AXI_WREADY;

                  assign target_if.bid      = source_if.AXI_BID;
                  assign target_if.bresp    = source_if.AXI_BRESP;
                  assign target_if.bvalid   = source_if.AXI_BVALID;
                  assign target_if.bready   = source_if.AXI_BREADY;

                  assign target_if.rid      = source_if.AXI_RID;
                  assign target_if.rdata    = source_if.AXI_RDATA;
                  assign target_if.rresp    = source_if.AXI_RRESP;
                  assign target_if.rlast    = source_if.AXI_RLAST;
                  assign target_if.rvalid   = source_if.AXI_RVALID;
                  assign target_if.rready   = source_if.AXI_RREADY;
              end: u_opensrc_axi
          end
          else if(src_if_type == AXI) begin: G3 // dmi behavioral model
              if(arm_protocol == SFI_AXI) begin: u_sfi_axi // memory
                  assign source_if.AXI_AWID     = target_if.awid;
                  assign source_if.AXI_AWADDR   = target_if.awaddr;
                  assign source_if.AXI_AWLEN    = target_if.awlen;
                  assign source_if.AXI_AWSIZE   = target_if.awsize;
                  assign source_if.AXI_AWBURST  = target_if.awburst;
                  assign source_if.AXI_AWLOCK   = target_if.awlock;
                  assign source_if.AXI_AWCACHE  = target_if.awcache;
                  assign source_if.AXI_AWPROT   = target_if.awprot;
                  assign source_if.AXI_AWQOS    = target_if.awqos;
                  assign source_if.AXI_AWREG    = target_if.awregion;
                  assign source_if.AXI_AWVALID  = target_if.awvalid;
                  assign target_if.awready      = source_if.AXI_AWREADY;

                  assign source_if.AXI_ARID     = target_if.arid;
                  assign source_if.AXI_ARADDR   = target_if.araddr;
                  assign source_if.AXI_ARLEN    = target_if.arlen;
                  assign source_if.AXI_ARSIZE   = target_if.arsize;
                  assign source_if.AXI_ARBURST  = target_if.arburst;
                  assign source_if.AXI_ARLOCK   = target_if.arlock;
                  assign source_if.AXI_ARCACHE  = target_if.arcache;
                  assign source_if.AXI_ARPROT   = target_if.arprot;
                  assign source_if.AXI_ARQOS    = target_if.arqos;
                  assign source_if.AXI_ARREG    = target_if.arregion;
                  assign source_if.AXI_ARVALID  = target_if.arvalid;
                  assign target_if.arready      = source_if.AXI_ARREADY;

                  //assign source_if.AXI_WID      = target_if.wid;
                  assign source_if.AXI_WDATA    = target_if.wdata;
                  assign source_if.AXI_WSTRB    = target_if.wstrb;
                  assign source_if.AXI_WLAST    = target_if.wlast;
                  assign source_if.AXI_WVALID   = target_if.wvalid;
                  assign target_if.wready       = source_if.AXI_WREADY;

                  assign target_if.bid          = source_if.AXI_BID;
                  assign target_if.bresp        = source_if.AXI_BRESP;
                  assign target_if.bvalid       = source_if.AXI_BVALID;
                  assign source_if.AXI_BREADY   = target_if.bready;

                  assign target_if.rid          = source_if.AXI_RID;
                  assign target_if.rdata        = source_if.AXI_RDATA;
                  assign target_if.rresp        = source_if.AXI_RRESP;
                  assign target_if.rlast        = source_if.AXI_RLAST;
                  assign target_if.rvalid       = source_if.AXI_RVALID;
                  assign source_if.AXI_RREADY   = target_if.rready;
              end: u_sfi_axi
          end
          else if(src_if_type == SFI_ACE_MODEL) begin: G4
              if(arm_protocol == IS_ACE) begin: u_sfi_ace_model
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
                  assign target_if.awready  = source_if.awready;
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
                  assign target_if.arready  = source_if.arready;
                  assign target_if.ardomain = source_if.ardomain;
                  assign target_if.arsnoop  = source_if.arsnoop;
                  assign target_if.arbar    = source_if.arbar;

                  //assign target_if.wid      = source_if.master_if[0].wid;
                  assign target_if.wdata    = source_if.wdata;
                  assign target_if.wstrb    = source_if.wstrb;
                  assign target_if.wlast    = source_if.wlast;
                  assign target_if.wuser    = source_if.wuser;
                  assign target_if.wvalid   = source_if.wvalid;
                  assign target_if.wready   = source_if.wready;

                  assign target_if.bid      = source_if.bid;
                  assign target_if.bresp    = source_if.bresp;
                  assign target_if.buser    = source_if.buser;
                  assign target_if.bvalid   = source_if.bvalid;
                  assign target_if.bready   = source_if.bready;
                  assign target_if.wack     = source_if.wack;

                  assign target_if.rid      = source_if.rid;
                  assign target_if.rdata    = source_if.rdata;
                  assign target_if.rresp    = source_if.rresp;
                  assign target_if.rlast    = source_if.rlast;
                  assign target_if.ruser    = source_if.ruser;
                  assign target_if.rvalid   = source_if.rvalid;
                  assign target_if.rready   = source_if.rready;
                  assign target_if.rack     = source_if.rack;

                  assign target_if.acvalid  = source_if.acvalid;
                  assign target_if.acready  = source_if.acready;
                  assign target_if.acaddr   = source_if.acaddr;
                  assign target_if.acsnoop  = source_if.acsnoop;
                  assign target_if.acprot   = source_if.acprot;

                  assign target_if.crvalid  = source_if.crvalid;
                  assign target_if.crready  = source_if.crready;
                  assign target_if.crresp   = source_if.crresp;

                  assign target_if.cdvalid  = source_if.cdvalid;
                  assign target_if.cdready  = source_if.cdready;
                  assign target_if.cddata   = source_if.cddata;
                  assign target_if.cdlast   = source_if.cdlast;
              end: u_sfi_ace_model
              if(arm_protocol == IS_AXI) begin: u_sfi_axi_model
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
                  assign target_if.awready  = source_if.awready;

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
                  assign target_if.arready  = source_if.arready;

                  assign target_if.wdata    = source_if.wdata;
                  assign target_if.wstrb    = source_if.wstrb;
                  assign target_if.wlast    = source_if.wlast;
                  assign target_if.wuser    = source_if.wuser;
                  assign target_if.wvalid   = source_if.wvalid;
                  assign target_if.wready   = source_if.wready;

                  assign target_if.bid      = source_if.bid;
                  assign target_if.bresp    = source_if.bresp;
                  assign target_if.buser    = source_if.buser;
                  assign target_if.bvalid   = source_if.bvalid;
                  assign target_if.bready   = source_if.bready;

                  assign target_if.rid      = source_if.rid;
                  assign target_if.rdata    = source_if.rdata;
                  assign target_if.rresp    = source_if.rresp;
                  assign target_if.rlast    = source_if.rlast;
                  assign target_if.ruser    = source_if.ruser;
                  assign target_if.rvalid   = source_if.rvalid;
                  assign target_if.rready   = source_if.rready;
              end: u_sfi_axi_model
              // Below will connect ACE VIP to SFI ACE
              if(arm_protocol == SFI_ACE_AXI_MODEL) begin: u_svt_ace_sfi
                  assign target_if.master_if[0].awid     = source_if.awid;
                  assign target_if.master_if[0].awaddr   = source_if.awaddr;
                  assign target_if.master_if[0].awlen    = source_if.awlen;
                  assign target_if.master_if[0].awsize   = source_if.awsize;
                  assign target_if.master_if[0].awburst  = source_if.awburst;
                  assign target_if.master_if[0].awlock   = source_if.awlock;
                  assign target_if.master_if[0].awcache  = source_if.awcache;
                  assign target_if.master_if[0].awprot   = source_if.awprot;
                  assign target_if.master_if[0].awqos    = source_if.awqos;
                  assign target_if.master_if[0].awregion = source_if.awregion;
                  assign target_if.master_if[0].awuser   = source_if.awuser;
                  assign target_if.master_if[0].awvalid  = source_if.awvalid;
                  assign target_if.master_if[0].awready  = source_if.awready;
                  assign target_if.master_if[0].awdomain = source_if.awdomain;
                  assign target_if.master_if[0].awsnoop  = source_if.awsnoop;
                  assign target_if.master_if[0].awbar    = source_if.awbar;
                  assign target_if.master_if[0].awunique = source_if.awunique;

                  assign target_if.master_if[0].arid     = source_if.arid;
                  assign target_if.master_if[0].araddr   = source_if.araddr;
                  assign target_if.master_if[0].arlen    = source_if.arlen;
                  assign target_if.master_if[0].arsize   = source_if.arsize;
                  assign target_if.master_if[0].arburst  = source_if.arburst;
                  assign target_if.master_if[0].arlock   = source_if.arlock;
                  assign target_if.master_if[0].arcache  = source_if.arcache;
                  assign target_if.master_if[0].arprot   = source_if.arprot;
                  assign target_if.master_if[0].arqos    = source_if.arqos;
                  assign target_if.master_if[0].arregion = source_if.arregion;
                  assign target_if.master_if[0].aruser   = source_if.aruser;
                  assign target_if.master_if[0].arvalid  = source_if.arvalid;
                  assign target_if.master_if[0].arready  = source_if.arready;
                  assign target_if.master_if[0].ardomain = source_if.ardomain;
                  assign target_if.master_if[0].arsnoop  = source_if.arsnoop;
                  assign target_if.master_if[0].arbar    = source_if.arbar;

                  assign target_if.master_if[0].wdata    = source_if.wdata;
                  assign target_if.master_if[0].wstrb    = source_if.wstrb;
                  assign target_if.master_if[0].wlast    = source_if.wlast;
                  assign target_if.master_if[0].wuser    = source_if.wuser;
                  assign target_if.master_if[0].wvalid   = source_if.wvalid;
                  assign target_if.master_if[0].wready   = source_if.wready;

                  assign target_if.master_if[0].bid      = source_if.bid;
                  assign target_if.master_if[0].bresp    = source_if.bresp;
                  assign target_if.master_if[0].buser    = source_if.buser;
                  assign target_if.master_if[0].bvalid   = source_if.bvalid;
                  assign target_if.master_if[0].bready   = source_if.bready;
                  assign target_if.master_if[0].wack     = source_if.wack;

                  assign target_if.master_if[0].rid      = source_if.rid;
                  assign target_if.master_if[0].rdata    = source_if.rdata;
                  assign target_if.master_if[0].rresp    = source_if.rresp;
                  assign target_if.master_if[0].rlast    = source_if.rlast;
                  assign target_if.master_if[0].ruser    = source_if.ruser;
                  assign target_if.master_if[0].rvalid   = source_if.rvalid;
                  assign target_if.master_if[0].rready   = source_if.rready;
                  assign target_if.master_if[0].rack     = source_if.rack;

                  assign target_if.master_if[0].acvalid  = source_if.acvalid;
                  assign target_if.master_if[0].acready  = source_if.acready;
                  assign target_if.master_if[0].acaddr   = source_if.acaddr;
                  assign target_if.master_if[0].acsnoop  = source_if.acsnoop;
                  assign target_if.master_if[0].acprot   = source_if.acprot;

                  assign target_if.master_if[0].crvalid  = source_if.crvalid;
                  assign target_if.master_if[0].crready  = source_if.crready;
                  assign target_if.master_if[0].crresp   = source_if.crresp;

                  assign target_if.master_if[0].cdvalid  = source_if.cdvalid;
                  assign target_if.master_if[0].cdready  = source_if.cdready;
                  assign target_if.master_if[0].cddata   = source_if.cddata;
                  assign target_if.master_if[0].cdlast   = source_if.cdlast;
              end: u_svt_ace_sfi
          end: G4
          else if(src_if_type == CADENCE_ARM_VIP) begin: G5
              if(arm_protocol == IS_ACE) begin: u_cdn_ace
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
                  assign target_if.awready  = source_if.awready;
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
                  assign target_if.arready  = source_if.arready;
                  assign target_if.ardomain = source_if.ardomain;
                  assign target_if.arsnoop  = source_if.arsnoop;
                  assign target_if.arbar    = source_if.arbar;

                  //assign target_if.wid      = source_if.wid;
                  assign target_if.wdata    = source_if.wdata;
                  assign target_if.wstrb    = source_if.wstrb;
                  assign target_if.wlast    = source_if.wlast;
                  assign target_if.wuser    = source_if.wuser;
                  assign target_if.wvalid   = source_if.wvalid;
                  assign target_if.wready   = source_if.wready;

                  assign target_if.bid      = source_if.bid;
                  assign target_if.bresp    = source_if.bresp;
                  assign target_if.buser    = source_if.buser;
                  assign target_if.bvalid   = source_if.bvalid;
                  assign target_if.bready   = source_if.bready;
//                  assign target_if.wack     = source_if.wack;

                  assign target_if.rid      = source_if.rid;
                  assign target_if.rdata    = source_if.rdata;
                  assign target_if.rresp    = source_if.rresp;
                  assign target_if.rlast    = source_if.rlast;
                  assign target_if.ruser    = source_if.ruser;
                  assign target_if.rvalid   = source_if.rvalid;
                  assign target_if.rready   = source_if.rready;
//                  assign target_if.rack     = source_if.rack;

                  assign target_if.acvalid  = source_if.acvalid;
                  assign target_if.acready  = source_if.acready;
                  assign target_if.acaddr   = source_if.acaddr;
                  assign target_if.acsnoop  = source_if.acsnoop;
                  assign target_if.acprot   = source_if.acprot;

                  assign target_if.crvalid  = source_if.crvalid;
                  assign target_if.crready  = source_if.crready;
                  assign target_if.crresp   = source_if.crresp;

                  assign target_if.cdvalid  = source_if.cdvalid;
                  assign target_if.cdready  = source_if.cdready;
                  assign target_if.cddata   = source_if.cddata;
                  assign target_if.cdlast   = source_if.cdlast;
              end: u_cdn_ace
              else if(arm_protocol == IS_ACE_LITE) begin: u_cdn_ace_lite
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
                  assign target_if.awready  = source_if.awready;
                  assign target_if.awdomain = source_if.awdomain;
                  assign target_if.awsnoop  = source_if.awsnoop;
                  assign target_if.awbar    = source_if.awbar;
             //     <% if (!obj.CUSTOMER_ENV) { %>
             //     //TODO: does not exist in Cadence AceLite interface
             // <% } %>
                  //assign target_if.awunique = source_if.awunique;

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
                  assign target_if.arready  = source_if.arready;
                  assign target_if.ardomain = source_if.ardomain;
                  assign target_if.arsnoop  = source_if.arsnoop;
                  assign target_if.arbar    = source_if.arbar;

                  //assign target_if.wid      = source_if.wid;
                  assign target_if.wdata    = source_if.wdata;
                  assign target_if.wstrb    = source_if.wstrb;
                  assign target_if.wlast    = source_if.wlast;
                  assign target_if.wuser    = source_if.wuser;
                  assign target_if.wvalid   = source_if.wvalid;
                  assign target_if.wready   = source_if.wready;

                  assign target_if.bid      = source_if.bid;
                  assign target_if.bresp    = source_if.bresp;
                  assign target_if.buser    = source_if.buser;
                  assign target_if.bvalid   = source_if.bvalid;
                  assign target_if.bready   = source_if.bready;

                  assign target_if.rid      = source_if.rid;
                  assign target_if.rdata    = source_if.rdata;
                  assign target_if.rresp    = source_if.rresp;
                  assign target_if.rlast    = source_if.rlast;
                  assign target_if.ruser    = source_if.ruser;
                  assign target_if.rvalid   = source_if.rvalid;
                  assign target_if.rready   = source_if.rready;
              end: u_cdn_ace_lite
              else if(arm_protocol == IS_AXI) begin: u_cdn_axi
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
                  assign target_if.awvalid  = source_if.awvalid;
                  assign target_if.awready  = source_if.awready;

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
                  assign target_if.arvalid  = source_if.arvalid;
                  assign target_if.arready  = source_if.arready;

                  assign target_if.wdata    = source_if.wdata;
                  assign target_if.wstrb    = source_if.wstrb;
                  assign target_if.wlast    = source_if.wlast;
                  assign target_if.wvalid   = source_if.wvalid;
                  assign target_if.wready   = source_if.wready;

                  assign target_if.bid      = source_if.bid;
                  assign target_if.bresp    = source_if.bresp;
                  assign target_if.bvalid   = source_if.bvalid;
                  assign target_if.bready   = source_if.bready;

                  assign target_if.rid      = source_if.rid;
                  assign target_if.rdata    = source_if.rdata;
                  assign target_if.rresp    = source_if.rresp;
                  assign target_if.rlast    = source_if.rlast;
                  assign target_if.rvalid   = source_if.rvalid;
                  assign target_if.rready   = source_if.rready;
              end: u_cdn_axi
          end: G5
      endgenerate
endmodule: connect_source2target_if

