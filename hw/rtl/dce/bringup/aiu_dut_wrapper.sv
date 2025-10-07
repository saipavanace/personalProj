module aiu_dut (

  input logic        clk,
  input logic        rst_n,
  /////////////////////////////////////////////////////////////////////////////////////////
  sfi_ace_if.slave   sfi_ace_slave_if,   // ACE channels: AC out, CR in, CD in
                                         // AXI Channels: AR in, R out, AW in, W in, B out
  /////////////////////////////////////////////////////////////////////////////////////////
  sfi_axi_if.master  sfi_axi_master_if,  // AXI Channels: AR out, R in, AW out, W out, B in
  /////////////////////////////////////////////////////////////////////////////////////////
  sfi_if.master      sfi_master_if,
  sfi_if.slave       sfi_slave_if

);

//
// AIU Input Signals
//
  logic aiu__ace_acready;
  logic [39:0] aiu__ace_araddr;
  logic [1:0] aiu__ace_arbar;
  logic [1:0] aiu__ace_arburst;
  logic [3:0] aiu__ace_arcache;
  logic [1:0] aiu__ace_ardomain;
  logic [3:0] aiu__ace_arid;
  logic [7:0] aiu__ace_arlen;
  logic aiu__ace_arlock;
  logic [2:0] aiu__ace_arprot;
  logic [3:0] aiu__ace_arqos;
  logic [3:0] aiu__ace_arregion;
  logic [2:0] aiu__ace_arsize;
  logic [3:0] aiu__ace_arsnoop;
  logic [3:0] aiu__ace_aruser;
  logic aiu__ace_arvalid;
  logic [39:0] aiu__ace_awaddr;
  logic [1:0] aiu__ace_awbar;
  logic [1:0] aiu__ace_awburst;
  logic [3:0] aiu__ace_awcache;
  logic [1:0] aiu__ace_awdomain;
  logic [3:0] aiu__ace_awid;
  logic [7:0] aiu__ace_awlen;
  logic aiu__ace_awlock;
  logic [2:0] aiu__ace_awprot;
  logic [3:0] aiu__ace_awqos;
  logic [3:0] aiu__ace_awregion;
  logic [2:0] aiu__ace_awsize;
  logic [2:0] aiu__ace_awsnoop;
  logic aiu__ace_awunique;
  logic [3:0] aiu__ace_awuser;
  logic aiu__ace_awvalid;
  logic aiu__ace_bready;
  logic [63:0] aiu__ace_cddata;
  logic aiu__ace_cdlast;
  logic aiu__ace_cdvalid;
  logic [4:0] aiu__ace_crresp;
  logic aiu__ace_crvalid;
  logic aiu__ace_rack;
  logic aiu__ace_rready;
  logic aiu__ace_wack;
  logic [63:0] aiu__ace_wdata;
  logic aiu__ace_wlast;
  logic [7:0] aiu__ace_wstrb;
  logic [3:0] aiu__ace_wuser;
  logic aiu__ace_wvalid;
  logic aiu__sfi_mst_req_rdy;
  logic [63:0] aiu__sfi_mst_rsp_data;
  logic [2:0] aiu__sfi_mst_rsp_errcode;
  logic aiu__sfi_mst_rsp_last;
  logic [7:0] aiu__sfi_mst_rsp_protbits;
  logic [19:0] aiu__sfi_mst_rsp_sfipriv;
  logic aiu__sfi_mst_rsp_status;
  logic [7:0] aiu__sfi_mst_rsp_transid;
  logic aiu__sfi_mst_rsp_vld;
  logic [39:0] aiu__sfi_slv_req_addr;
  logic [7:0] aiu__sfi_slv_req_be;
  logic aiu__sfi_slv_req_burst_type;
  logic [63:0] aiu__sfi_slv_req_data;
  logic [2:0] aiu__sfi_slv_req_hurry;
  logic aiu__sfi_slv_req_last;
  logic [5:0] aiu__sfi_slv_req_length;
  logic aiu__sfi_slv_req_opc;
  logic [2:0] aiu__sfi_slv_req_press;
  logic [7:0] aiu__sfi_slv_req_protbits;
  logic [2:0] aiu__sfi_slv_req_security;
  logic [19:0] aiu__sfi_slv_req_sfipriv;
  logic [2:0] aiu__sfi_slv_req_sfislvid;
  logic [7:0] aiu__sfi_slv_req_transid;
  logic [2:0] aiu__sfi_slv_req_urgency;
  logic aiu__sfi_slv_req_vld;
  logic aiu__sfi_slv_rsp_rdy;

//
// AIU Output Signals
//
  logic [39:0] aiu__ace_acaddr;
  logic [2:0] aiu__ace_acprot;
  logic [3:0] aiu__ace_acsnoop;
  logic aiu__ace_acvalid;
  logic aiu__ace_arready;
  logic aiu__ace_awready;
  logic [3:0] aiu__ace_bid;
  logic [1:0] aiu__ace_bresp;
  logic [3:0] aiu__ace_buser;
  logic aiu__ace_bvalid;
  logic aiu__ace_cdready;
  logic aiu__ace_crready;
  logic [63:0] aiu__ace_rdata;
  logic [3:0] aiu__ace_rid;
  logic aiu__ace_rlast;
  logic [3:0] aiu__ace_rresp;
  logic [3:0] aiu__ace_ruser;
  logic aiu__ace_rvalid;
  logic aiu__ace_wready;
  logic [39:0] aiu__sfi_mst_req_addr;
  logic [7:0] aiu__sfi_mst_req_be;
  logic aiu__sfi_mst_req_burst_type;
  logic [63:0] aiu__sfi_mst_req_data;
  logic [2:0] aiu__sfi_mst_req_hurry;
  logic aiu__sfi_mst_req_last;
  logic [5:0] aiu__sfi_mst_req_length;
  logic aiu__sfi_mst_req_opc;
  logic [2:0] aiu__sfi_mst_req_press;
  logic [7:0] aiu__sfi_mst_req_protbits;
  logic [2:0] aiu__sfi_mst_req_security;
  logic [19:0] aiu__sfi_mst_req_sfipriv;
  logic [2:0] aiu__sfi_mst_req_sfislvid;
  logic [7:0] aiu__sfi_mst_req_transid;
  logic [2:0] aiu__sfi_mst_req_urgency;
  logic aiu__sfi_mst_req_vld;
  logic aiu__sfi_mst_rsp_rdy;
  logic aiu__sfi_slv_req_rdy;
  logic [63:0] aiu__sfi_slv_rsp_data;
  logic [2:0] aiu__sfi_slv_rsp_errcode;
  logic aiu__sfi_slv_rsp_last;
  logic [7:0] aiu__sfi_slv_rsp_protbits;
  logic [19:0] aiu__sfi_slv_rsp_sfipriv;
  logic aiu__sfi_slv_rsp_status;
  logic [7:0] aiu__sfi_slv_rsp_transid;
  logic aiu__sfi_slv_rsp_vld;

//top__aiu aiu (
top__top__coh__aiu0 aiu (
    .sfi_slv_req_rdy(aiu__sfi_slv_req_rdy),
    .sfi_slv_req_vld(aiu__sfi_slv_req_vld),
    .sfi_slv_req_last(aiu__sfi_slv_req_last),
    .sfi_slv_req_opc(aiu__sfi_slv_req_opc),
    .sfi_slv_req_burst_type(aiu__sfi_slv_req_burst_type),
    .sfi_slv_req_length(aiu__sfi_slv_req_length),
    .sfi_slv_req_addr(aiu__sfi_slv_req_addr),
    .sfi_slv_req_sfislvid(aiu__sfi_slv_req_sfislvid),
    .sfi_slv_req_sfipriv(aiu__sfi_slv_req_sfipriv),
    .sfi_slv_req_transid(aiu__sfi_slv_req_transid),
    .sfi_slv_req_urgency(aiu__sfi_slv_req_urgency),
    .sfi_slv_req_security(aiu__sfi_slv_req_security),
    .sfi_slv_req_be(aiu__sfi_slv_req_be),
    .sfi_slv_req_data(aiu__sfi_slv_req_data),
    .sfi_slv_req_protbits(aiu__sfi_slv_req_protbits),
    .sfi_slv_rsp_rdy(aiu__sfi_slv_rsp_rdy),
    .sfi_slv_rsp_vld(aiu__sfi_slv_rsp_vld),
    .sfi_slv_rsp_last(aiu__sfi_slv_rsp_last),
    .sfi_slv_rsp_status(aiu__sfi_slv_rsp_status),
    .sfi_slv_rsp_errcode(aiu__sfi_slv_rsp_errcode),
    .sfi_slv_rsp_transid(aiu__sfi_slv_rsp_transid),
    .sfi_slv_rsp_sfipriv(aiu__sfi_slv_rsp_sfipriv),
    .sfi_slv_rsp_data(aiu__sfi_slv_rsp_data),
    .sfi_slv_rsp_protbits(aiu__sfi_slv_rsp_protbits),
    .sfi_slv_req_press(aiu__sfi_slv_req_press),
    .sfi_slv_req_hurry(aiu__sfi_slv_req_hurry),
    .sfi_mst_req_rdy(aiu__sfi_mst_req_rdy),
    .sfi_mst_req_vld(aiu__sfi_mst_req_vld),
    .sfi_mst_req_last(aiu__sfi_mst_req_last),
    .sfi_mst_req_opc(aiu__sfi_mst_req_opc),
    .sfi_mst_req_burst_type(aiu__sfi_mst_req_burst_type),
    .sfi_mst_req_length(aiu__sfi_mst_req_length),
    .sfi_mst_req_addr(aiu__sfi_mst_req_addr),
    .sfi_mst_req_sfislvid(aiu__sfi_mst_req_sfislvid),
    .sfi_mst_req_sfipriv(aiu__sfi_mst_req_sfipriv),
    .sfi_mst_req_transid(aiu__sfi_mst_req_transid),
    .sfi_mst_req_urgency(aiu__sfi_mst_req_urgency),
    .sfi_mst_req_security(aiu__sfi_mst_req_security),
    .sfi_mst_req_be(aiu__sfi_mst_req_be),
    .sfi_mst_req_data(aiu__sfi_mst_req_data),
    .sfi_mst_req_protbits(aiu__sfi_mst_req_protbits),
    .sfi_mst_rsp_rdy(aiu__sfi_mst_rsp_rdy),
    .sfi_mst_rsp_vld(aiu__sfi_mst_rsp_vld),
    .sfi_mst_rsp_last(aiu__sfi_mst_rsp_last),
    .sfi_mst_rsp_status(aiu__sfi_mst_rsp_status),
    .sfi_mst_rsp_errcode(aiu__sfi_mst_rsp_errcode),
    .sfi_mst_rsp_transid(aiu__sfi_mst_rsp_transid),
    .sfi_mst_rsp_sfipriv(aiu__sfi_mst_rsp_sfipriv),
    .sfi_mst_rsp_data(aiu__sfi_mst_rsp_data),
    .sfi_mst_rsp_protbits(aiu__sfi_mst_rsp_protbits),
    .sfi_mst_req_press(aiu__sfi_mst_req_press),
    .sfi_mst_req_hurry(aiu__sfi_mst_req_hurry),
    .ace_awready(aiu__ace_awready),
    .ace_awvalid(aiu__ace_awvalid),
    .ace_awid(aiu__ace_awid),
    .ace_awaddr(aiu__ace_awaddr),
    .ace_awburst(aiu__ace_awburst),
    .ace_awcache(aiu__ace_awcache),
    .ace_awlen(aiu__ace_awlen),
    .ace_awlock(aiu__ace_awlock),
    .ace_awprot(aiu__ace_awprot),
    .ace_awqos(aiu__ace_awqos),
    .ace_awregion(aiu__ace_awregion),
    .ace_awsize(aiu__ace_awsize),
    .ace_awuser(aiu__ace_awuser),
    .ace_wready(aiu__ace_wready),
    .ace_wvalid(aiu__ace_wvalid),
    .ace_wdata(aiu__ace_wdata),
    .ace_wuser(aiu__ace_wuser),
    .ace_wlast(aiu__ace_wlast),
    .ace_wstrb(aiu__ace_wstrb),
    .ace_bready(aiu__ace_bready),
    .ace_bvalid(aiu__ace_bvalid),
    .ace_bid(aiu__ace_bid),
    .ace_bresp(aiu__ace_bresp),
    .ace_buser(aiu__ace_buser),
    .ace_arready(aiu__ace_arready),
    .ace_arvalid(aiu__ace_arvalid),
    .ace_araddr(aiu__ace_araddr),
    .ace_arburst(aiu__ace_arburst),
    .ace_arcache(aiu__ace_arcache),
    .ace_arid(aiu__ace_arid),
    .ace_arlen(aiu__ace_arlen),
    .ace_arlock(aiu__ace_arlock),
    .ace_arprot(aiu__ace_arprot),
    .ace_arqos(aiu__ace_arqos),
    .ace_arregion(aiu__ace_arregion),
    .ace_arsize(aiu__ace_arsize),
    .ace_aruser(aiu__ace_aruser),
    .ace_rready(aiu__ace_rready),
    .ace_rvalid(aiu__ace_rvalid),
    .ace_rid(aiu__ace_rid),
    .ace_rresp(aiu__ace_rresp),
    .ace_rdata(aiu__ace_rdata),
    .ace_ruser(aiu__ace_ruser),
    .ace_rlast(aiu__ace_rlast),
    .ace_arsnoop(aiu__ace_arsnoop),
    .ace_ardomain(aiu__ace_ardomain),
    .ace_arbar(aiu__ace_arbar),
    .ace_awdomain(aiu__ace_awdomain),
    .ace_awsnoop(aiu__ace_awsnoop),
    .ace_awunique(aiu__ace_awunique),
    .ace_awbar(aiu__ace_awbar),
    .ace_acready(aiu__ace_acready),
    .ace_acvalid(aiu__ace_acvalid),
    .ace_acaddr(aiu__ace_acaddr),
    .ace_acprot(aiu__ace_acprot),
    .ace_acsnoop(aiu__ace_acsnoop),
    .ace_crready(aiu__ace_crready),
    .ace_crvalid(aiu__ace_crvalid),
    .ace_crresp(aiu__ace_crresp),
    .ace_cdready(aiu__ace_cdready),
    .ace_cdvalid(aiu__ace_cdvalid),
    .ace_cddata(aiu__ace_cddata),
    .ace_cdlast(aiu__ace_cdlast),
    .ace_rack(aiu__ace_rack),
    .ace_wack(aiu__ace_wack),
    .clk(clk),
    .reset_n(rst_n)
);

  //
  // DUT input signals
  //
    assign aiu__sfi_mst_req_rdy          = sfi_master_if.req_rdy;
    assign aiu__sfi_mst_rsp_data         = sfi_master_if.rsp_data;
    assign aiu__sfi_mst_rsp_errcode      = sfi_master_if.rsp_errCode;
    assign aiu__sfi_mst_rsp_last         = sfi_master_if.rsp_last;
    assign aiu__sfi_mst_rsp_protbits     = sfi_master_if.rsp_protBits;
    assign aiu__sfi_mst_rsp_sfipriv      = sfi_master_if.rsp_sfiPriv;
    assign aiu__sfi_mst_rsp_status       = sfi_master_if.rsp_status;
    assign aiu__sfi_mst_rsp_transid      = sfi_master_if.rsp_transId;
    assign aiu__sfi_mst_rsp_vld          = sfi_master_if.rsp_vld;
    assign aiu__sfi_slv_req_addr         = sfi_slave_if.req_addr;
    assign aiu__sfi_slv_req_be           = sfi_slave_if.req_be;
    assign aiu__sfi_slv_req_burst_type   = sfi_slave_if.req_burst;
    assign aiu__sfi_slv_req_data         = sfi_slave_if.req_data;
    assign aiu__sfi_slv_req_hurry        = sfi_slave_if.req_hurry;
    assign aiu__sfi_slv_req_last         = sfi_slave_if.req_last;
    assign aiu__sfi_slv_req_length       = sfi_slave_if.req_length;
    assign aiu__sfi_slv_req_opc          = sfi_slave_if.req_opc;
    assign aiu__sfi_slv_req_press        = sfi_slave_if.req_press;
    assign aiu__sfi_slv_req_protbits     = sfi_slave_if.req_protBits;
    assign aiu__sfi_slv_req_security     = sfi_slave_if.req_security;
    assign aiu__sfi_slv_req_sfipriv      = sfi_slave_if.req_sfiPriv;
    assign aiu__sfi_slv_req_sfislvid     = sfi_slave_if.req_sfiSlvId;
    assign aiu__sfi_slv_req_transid      = sfi_slave_if.req_transId;
    assign aiu__sfi_slv_req_urgency      = sfi_slave_if.req_urgency;
    assign aiu__sfi_slv_req_vld          = sfi_slave_if.req_vld;
    assign aiu__sfi_slv_rsp_rdy          = sfi_slave_if.rsp_rdy;

    assign aiu__ace_acready = sfi_ace_slave_if.acready;
    assign aiu__ace_araddr = sfi_ace_slave_if.araddr;
    assign aiu__ace_arbar = sfi_ace_slave_if.arbar;
    assign aiu__ace_arburst = sfi_ace_slave_if.arburst;
    assign aiu__ace_arcache = sfi_ace_slave_if.arcache;
    assign aiu__ace_ardomain = sfi_ace_slave_if.ardomain;
    assign aiu__ace_arid = sfi_ace_slave_if.arid;
    assign aiu__ace_arlen = sfi_ace_slave_if.arlen;
    assign aiu__ace_arlock = sfi_ace_slave_if.arlock;
    assign aiu__ace_arprot = sfi_ace_slave_if.arprot;
    assign aiu__ace_arqos = sfi_ace_slave_if.arqos;
    assign aiu__ace_arregion = sfi_ace_slave_if.arregion;
    assign aiu__ace_arsize = sfi_ace_slave_if.arsize;
    assign aiu__ace_arsnoop = sfi_ace_slave_if.arsnoop;
    assign aiu__ace_aruser = sfi_ace_slave_if.aruser;
    assign aiu__ace_arvalid = sfi_ace_slave_if.arvalid;
    assign aiu__ace_awaddr = sfi_ace_slave_if.awaddr;
    assign aiu__ace_awbar = sfi_ace_slave_if.awbar;
    assign aiu__ace_awburst = sfi_ace_slave_if.awburst;
    assign aiu__ace_awcache = sfi_ace_slave_if.awcache;
    assign aiu__ace_awdomain = sfi_ace_slave_if.awdomain;
    assign aiu__ace_awid = sfi_ace_slave_if.awid;
    assign aiu__ace_awlen = sfi_ace_slave_if.awlen;
    assign aiu__ace_awlock = sfi_ace_slave_if.awlock;
    assign aiu__ace_awprot = sfi_ace_slave_if.awprot;
    assign aiu__ace_awqos = sfi_ace_slave_if.awqos;
    assign aiu__ace_awregion = sfi_ace_slave_if.awregion;
    assign aiu__ace_awsize = sfi_ace_slave_if.awsize;
    assign aiu__ace_awsnoop = sfi_ace_slave_if.awsnoop;
    assign aiu__ace_awunique = sfi_ace_slave_if.awunique;
    assign aiu__ace_awuser = sfi_ace_slave_if.awuser;
    assign aiu__ace_awvalid = sfi_ace_slave_if.awvalid;
    assign aiu__ace_bready = sfi_ace_slave_if.bready;
    assign aiu__ace_cddata = sfi_ace_slave_if.cddata;
    assign aiu__ace_cdlast = sfi_ace_slave_if.cdlast;
    assign aiu__ace_cdvalid = sfi_ace_slave_if.cdvalid;
    assign aiu__ace_crresp = sfi_ace_slave_if.crresp;
    assign aiu__ace_crvalid = sfi_ace_slave_if.crvalid;
    assign aiu__ace_rack = sfi_ace_slave_if.rack;
    assign aiu__ace_rready = sfi_ace_slave_if.rready;
    assign aiu__ace_wack = sfi_ace_slave_if.wack;
    assign aiu__ace_wdata = sfi_ace_slave_if.wdata;
    assign aiu__ace_wlast = sfi_ace_slave_if.wlast;
    assign aiu__ace_wstrb = sfi_ace_slave_if.wstrb;
    assign aiu__ace_wuser = sfi_ace_slave_if.wuser;
    assign aiu__ace_wvalid = sfi_ace_slave_if.wvalid;
  //
  // DUT output signals
  //
    assign sfi_master_if.req_addr       = aiu__sfi_mst_req_addr;
    assign sfi_master_if.req_be         = aiu__sfi_mst_req_be;
    assign sfi_master_if.req_burst      = aiu__sfi_mst_req_burst_type;
    assign sfi_master_if.req_data       = aiu__sfi_mst_req_data;
    assign sfi_master_if.req_hurry      = aiu__sfi_mst_req_hurry;
    assign sfi_master_if.req_last       = aiu__sfi_mst_req_last;
    assign sfi_master_if.req_length     = aiu__sfi_mst_req_length;
    assign sfi_master_if.req_opc        = aiu__sfi_mst_req_opc;
    assign sfi_master_if.req_press      = aiu__sfi_mst_req_press;
    assign sfi_master_if.req_protBits   = aiu__sfi_mst_req_protbits;
    assign sfi_master_if.req_security   = aiu__sfi_mst_req_security;
    assign sfi_master_if.req_sfiPriv    = aiu__sfi_mst_req_sfipriv;
    assign sfi_master_if.req_sfiSlvId   = 3'h4; //DCE unit id //aiu__sfi_mst_req_sfislvid;
    assign sfi_master_if.req_transId    = aiu__sfi_mst_req_transid;
    assign sfi_master_if.req_urgency    = aiu__sfi_mst_req_urgency;
    assign sfi_master_if.req_vld        = aiu__sfi_mst_req_vld;
    assign sfi_master_if.rsp_rdy        = aiu__sfi_mst_rsp_rdy;
    assign sfi_slave_if.req_rdy         = aiu__sfi_slv_req_rdy;
    assign sfi_slave_if.rsp_data        = aiu__sfi_slv_rsp_data;
    assign sfi_slave_if.rsp_errCode     = aiu__sfi_slv_rsp_errcode;
    assign sfi_slave_if.rsp_last        = aiu__sfi_slv_rsp_last;
    assign sfi_slave_if.rsp_protBits    = aiu__sfi_slv_rsp_protbits;
    assign sfi_slave_if.rsp_sfiPriv     = {18'b0, aiu__sfi_slv_rsp_sfipriv[1:0]}; //aiu__sfi_slv_rsp_sfipriv;
    assign sfi_slave_if.rsp_status      = aiu__sfi_slv_rsp_status;
    assign sfi_slave_if.rsp_transId     = aiu__sfi_slv_rsp_transid;
    assign sfi_slave_if.rsp_vld         = aiu__sfi_slv_rsp_vld;

    assign sfi_ace_slave_if.acaddr = aiu__ace_acaddr;
    assign sfi_ace_slave_if.acprot = aiu__ace_acprot;
    assign sfi_ace_slave_if.acsnoop = aiu__ace_acsnoop;
    assign sfi_ace_slave_if.acvalid = aiu__ace_acvalid;
    assign sfi_ace_slave_if.arready = aiu__ace_arready;
    assign sfi_ace_slave_if.awready = aiu__ace_awready;
    assign sfi_ace_slave_if.bid = aiu__ace_bid;
    assign sfi_ace_slave_if.bresp = aiu__ace_bresp;
    assign sfi_ace_slave_if.buser = aiu__ace_buser;
    assign sfi_ace_slave_if.bvalid = aiu__ace_bvalid;
    assign sfi_ace_slave_if.cdready = aiu__ace_cdready;
    assign sfi_ace_slave_if.crready = aiu__ace_crready;
    assign sfi_ace_slave_if.rdata = aiu__ace_rdata;
    assign sfi_ace_slave_if.rid = aiu__ace_rid;
    assign sfi_ace_slave_if.rlast = aiu__ace_rlast;
    assign sfi_ace_slave_if.rresp = aiu__ace_rresp;
    assign sfi_ace_slave_if.ruser = aiu__ace_ruser;
    assign sfi_ace_slave_if.rvalid = aiu__ace_rvalid;
    assign sfi_ace_slave_if.wready = aiu__ace_wready;

endmodule
