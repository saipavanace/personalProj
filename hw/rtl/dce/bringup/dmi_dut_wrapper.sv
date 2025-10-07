module dmi_dut (

  sfi_if.slave       sfi_slave_if,
  sfi_if.master      sfi_master_if,

  sfi_axi_if.master  sfi_axi_master_if,  // AXI Channels: AR out, R in, AW out, W out, B in

  input logic        clk,
  input logic        rst_n

);

//
// DMI input signals

  logic dmi__axi_mst_arready;
  logic dmi__axi_mst_awready;
  logic [3:0] dmi__axi_mst_bid;
  logic [1:0] dmi__axi_mst_bresp;
  logic [3:0] dmi__axi_mst_buser;
  logic dmi__axi_mst_bvalid;
  logic [63:0] dmi__axi_mst_rdata;
  logic [3:0] dmi__axi_mst_rid;
  logic dmi__axi_mst_rlast;
  logic [1:0] dmi__axi_mst_rresp;
  logic [3:0] dmi__axi_mst_ruser;
  logic dmi__axi_mst_rvalid;
  logic dmi__axi_mst_wready;
  logic dmi__sfi_mst_req_rdy;
  logic [63:0] dmi__sfi_mst_rsp_data;
  logic [2:0] dmi__sfi_mst_rsp_errcode;
  logic dmi__sfi_mst_rsp_last;
  logic [7:0] dmi__sfi_mst_rsp_protbits;
  logic [19:0] dmi__sfi_mst_rsp_sfipriv;
  logic dmi__sfi_mst_rsp_status;
  logic [7:0] dmi__sfi_mst_rsp_transid;
  logic dmi__sfi_mst_rsp_vld;
  logic [39:0] dmi__sfi_slv_req_addr;
  logic [7:0] dmi__sfi_slv_req_be;
  logic [1:0] dmi__sfi_slv_req_burst_type;
  logic [63:0] dmi__sfi_slv_req_data;
  logic [2:0] dmi__sfi_slv_req_hurry;
  logic dmi__sfi_slv_req_last;
  logic [5:0] dmi__sfi_slv_req_length;
  logic dmi__sfi_slv_req_opc;
  logic [2:0] dmi__sfi_slv_req_press;
  logic [7:0] dmi__sfi_slv_req_protbits;
  logic [2:0] dmi__sfi_slv_req_security;
  logic [19:0] dmi__sfi_slv_req_sfipriv;
  logic [2:0] dmi__sfi_slv_req_sfislvid;
  logic [7:0] dmi__sfi_slv_req_transid;
  logic [2:0] dmi__sfi_slv_req_urgency;
  logic dmi__sfi_slv_req_vld;
  logic dmi__sfi_slv_rsp_rdy;

//
// DMI output signals
//
  logic [39:0] dmi__axi_mst_araddr;
  logic [1:0] dmi__axi_mst_arburst;
  logic [3:0] dmi__axi_mst_arcache;
  logic [3:0] dmi__axi_mst_arid;
  logic [7:0] dmi__axi_mst_arlen;
  logic dmi__axi_mst_arlock;
  logic [2:0] dmi__axi_mst_arprot;
  logic [3:0] dmi__axi_mst_arqos;
  logic [3:0] dmi__axi_mst_arregion;
  logic [2:0] dmi__axi_mst_arsize;
  logic [3:0] dmi__axi_mst_aruser;
  logic dmi__axi_mst_arvalid;
  logic [39:0] dmi__axi_mst_awaddr;
  logic [1:0] dmi__axi_mst_awburst;
  logic [3:0] dmi__axi_mst_awcache;
  logic [3:0] dmi__axi_mst_awid;
  logic [7:0] dmi__axi_mst_awlen;
  logic dmi__axi_mst_awlock;
  logic [2:0] dmi__axi_mst_awprot;
  logic [3:0] dmi__axi_mst_awqos;
  logic [3:0] dmi__axi_mst_awregion;
  logic [2:0] dmi__axi_mst_awsize;
  logic [3:0] dmi__axi_mst_awuser;
  logic dmi__axi_mst_awvalid;
  logic dmi__axi_mst_bready;
  logic dmi__axi_mst_rready;
  logic [63:0] dmi__axi_mst_wdata;
  logic dmi__axi_mst_wlast;
  logic [7:0] dmi__axi_mst_wstrb;
  logic [3:0] dmi__axi_mst_wuser;
  logic dmi__axi_mst_wvalid;
  logic [39:0] dmi__sfi_mst_req_addr;
  logic [7:0] dmi__sfi_mst_req_be;
  logic dmi__sfi_mst_req_burst_type;
  logic [63:0] dmi__sfi_mst_req_data;
  logic [2:0] dmi__sfi_mst_req_hurry;
  logic dmi__sfi_mst_req_last;
  logic [5:0] dmi__sfi_mst_req_length;
  logic dmi__sfi_mst_req_opc;
  logic [2:0] dmi__sfi_mst_req_press;
  logic [7:0] dmi__sfi_mst_req_protbits;
  logic [2:0] dmi__sfi_mst_req_security;
  logic [19:0] dmi__sfi_mst_req_sfipriv;
  logic [2:0] dmi__sfi_mst_req_sfislvid;
  logic [7:0] dmi__sfi_mst_req_transid;
  logic [2:0] dmi__sfi_mst_req_urgency;
  logic dmi__sfi_mst_req_vld;
  logic dmi__sfi_mst_rsp_rdy;
  logic dmi__sfi_slv_req_rdy;
  logic [63:0] dmi__sfi_slv_rsp_data;
  logic [2:0] dmi__sfi_slv_rsp_errcode;
  logic dmi__sfi_slv_rsp_last;
  logic [7:0] dmi__sfi_slv_rsp_protbits;
  logic [19:0] dmi__sfi_slv_rsp_sfipriv;
  logic dmi__sfi_slv_rsp_status;
  logic [7:0] dmi__sfi_slv_rsp_transid;
  logic dmi__sfi_slv_rsp_vld;


top__top__coh__dmi dmi (
    .axi_mst_awready(dmi__axi_mst_awready),
    .axi_mst_awvalid(dmi__axi_mst_awvalid),
    .axi_mst_awid(dmi__axi_mst_awid),
    .axi_mst_awaddr(dmi__axi_mst_awaddr),
    .axi_mst_awburst(dmi__axi_mst_awburst),
    .axi_mst_awcache(dmi__axi_mst_awcache),
    .axi_mst_awlen(dmi__axi_mst_awlen),
    .axi_mst_awlock(dmi__axi_mst_awlock),
    .axi_mst_awprot(dmi__axi_mst_awprot),
    .axi_mst_awqos(dmi__axi_mst_awqos),
    .axi_mst_awregion(dmi__axi_mst_awregion),
    .axi_mst_awsize(dmi__axi_mst_awsize),
    .axi_mst_awuser(dmi__axi_mst_awuser),
    .axi_mst_wready(dmi__axi_mst_wready),
    .axi_mst_wvalid(dmi__axi_mst_wvalid),
    .axi_mst_wdata(dmi__axi_mst_wdata),
    .axi_mst_wuser(dmi__axi_mst_wuser),
    .axi_mst_wlast(dmi__axi_mst_wlast),
    .axi_mst_wstrb(dmi__axi_mst_wstrb),
    .axi_mst_bready(dmi__axi_mst_bready),
    .axi_mst_bvalid(dmi__axi_mst_bvalid),
    .axi_mst_bid(dmi__axi_mst_bid),
    .axi_mst_bresp(dmi__axi_mst_bresp),
    .axi_mst_buser(dmi__axi_mst_buser),
    .axi_mst_arready(dmi__axi_mst_arready),
    .axi_mst_arvalid(dmi__axi_mst_arvalid),
    .axi_mst_araddr(dmi__axi_mst_araddr),
    .axi_mst_arburst(dmi__axi_mst_arburst),
    .axi_mst_arcache(dmi__axi_mst_arcache),
    .axi_mst_arid(dmi__axi_mst_arid),
    .axi_mst_arlen(dmi__axi_mst_arlen),
    .axi_mst_arlock(dmi__axi_mst_arlock),
    .axi_mst_arprot(dmi__axi_mst_arprot),
    .axi_mst_arqos(dmi__axi_mst_arqos),
    .axi_mst_arregion(dmi__axi_mst_arregion),
    .axi_mst_arsize(dmi__axi_mst_arsize),
    .axi_mst_aruser(dmi__axi_mst_aruser),
    .axi_mst_rready(dmi__axi_mst_rready),
    .axi_mst_rvalid(dmi__axi_mst_rvalid),
    .axi_mst_rid(dmi__axi_mst_rid),
    .axi_mst_rresp(dmi__axi_mst_rresp),
    .axi_mst_rdata(dmi__axi_mst_rdata),
    .axi_mst_ruser(dmi__axi_mst_ruser),
    .axi_mst_rlast(dmi__axi_mst_rlast),
    .sfi_mst_req_rdy(dmi__sfi_mst_req_rdy),
    .sfi_mst_req_vld(dmi__sfi_mst_req_vld),
    .sfi_mst_req_last(dmi__sfi_mst_req_last),
    .sfi_mst_req_opc(dmi__sfi_mst_req_opc),
    .sfi_mst_req_burst_type(dmi__sfi_mst_req_burst_type),
    .sfi_mst_req_length(dmi__sfi_mst_req_length),
    .sfi_mst_req_addr(dmi__sfi_mst_req_addr),
    .sfi_mst_req_sfislvid(dmi__sfi_mst_req_sfislvid),
    .sfi_mst_req_sfipriv(dmi__sfi_mst_req_sfipriv),
    .sfi_mst_req_transid(dmi__sfi_mst_req_transid),
    .sfi_mst_req_urgency(dmi__sfi_mst_req_urgency),
    .sfi_mst_req_security(dmi__sfi_mst_req_security),
    .sfi_mst_req_be(dmi__sfi_mst_req_be),
    .sfi_mst_req_data(dmi__sfi_mst_req_data),
    .sfi_mst_req_protbits(dmi__sfi_mst_req_protbits),
    .sfi_mst_rsp_rdy(dmi__sfi_mst_rsp_rdy),
    .sfi_mst_rsp_vld(dmi__sfi_mst_rsp_vld),
    .sfi_mst_rsp_last(dmi__sfi_mst_rsp_last),
    .sfi_mst_rsp_status(dmi__sfi_mst_rsp_status),
    .sfi_mst_rsp_errcode(dmi__sfi_mst_rsp_errcode),
    .sfi_mst_rsp_transid(dmi__sfi_mst_rsp_transid),
    .sfi_mst_rsp_sfipriv(dmi__sfi_mst_rsp_sfipriv),
    .sfi_mst_rsp_data(dmi__sfi_mst_rsp_data),
    .sfi_mst_rsp_protbits(dmi__sfi_mst_rsp_protbits),
    .sfi_mst_req_press(dmi__sfi_mst_req_press),
    .sfi_mst_req_hurry(dmi__sfi_mst_req_hurry),
    .sfi_slv_req_rdy(dmi__sfi_slv_req_rdy),
    .sfi_slv_req_vld(dmi__sfi_slv_req_vld),
    .sfi_slv_req_last(dmi__sfi_slv_req_last),
    .sfi_slv_req_opc(dmi__sfi_slv_req_opc),
    .sfi_slv_req_burst_type(dmi__sfi_slv_req_burst_type),
    .sfi_slv_req_length(dmi__sfi_slv_req_length),
    .sfi_slv_req_addr(dmi__sfi_slv_req_addr),
    .sfi_slv_req_sfislvid(dmi__sfi_slv_req_sfislvid),
    .sfi_slv_req_sfipriv(dmi__sfi_slv_req_sfipriv),
    .sfi_slv_req_transid(dmi__sfi_slv_req_transid),
    .sfi_slv_req_urgency(dmi__sfi_slv_req_urgency),
    .sfi_slv_req_security(dmi__sfi_slv_req_security),
    .sfi_slv_req_be(dmi__sfi_slv_req_be),
    .sfi_slv_req_data(dmi__sfi_slv_req_data),
    .sfi_slv_req_protbits(dmi__sfi_slv_req_protbits),
    .sfi_slv_rsp_rdy(dmi__sfi_slv_rsp_rdy),
    .sfi_slv_rsp_vld(dmi__sfi_slv_rsp_vld),
    .sfi_slv_rsp_last(dmi__sfi_slv_rsp_last),
    .sfi_slv_rsp_status(dmi__sfi_slv_rsp_status),
    .sfi_slv_rsp_errcode(dmi__sfi_slv_rsp_errcode),
    .sfi_slv_rsp_transid(dmi__sfi_slv_rsp_transid),
    .sfi_slv_rsp_sfipriv(dmi__sfi_slv_rsp_sfipriv),
    .sfi_slv_rsp_data(dmi__sfi_slv_rsp_data),
    .sfi_slv_rsp_protbits(dmi__sfi_slv_rsp_protbits),
    .sfi_slv_req_press(dmi__sfi_slv_req_press),
    .sfi_slv_req_hurry(dmi__sfi_slv_req_hurry),
    .clk(clk),
    .reset_n(rst_n)
);

  //
  // DMI input signals
  //
    assign dmi__axi_mst_arready             = sfi_axi_master_if.arready;
    assign dmi__axi_mst_awready             = sfi_axi_master_if.awready;
    assign dmi__axi_mst_bid                 = sfi_axi_master_if.bid;
    assign dmi__axi_mst_bresp               = sfi_axi_master_if.bresp;
    assign dmi__axi_mst_buser               = sfi_axi_master_if.buser;
    assign dmi__axi_mst_bvalid              = sfi_axi_master_if.bvalid;
    assign dmi__axi_mst_rdata               = sfi_axi_master_if.rdata;
    assign dmi__axi_mst_rid                 = sfi_axi_master_if.rid;
    assign dmi__axi_mst_rlast               = sfi_axi_master_if.rlast;
    assign dmi__axi_mst_rresp               = sfi_axi_master_if.rresp;
    assign dmi__axi_mst_ruser               = sfi_axi_master_if.ruser;
    assign dmi__axi_mst_rvalid              = sfi_axi_master_if.rvalid;
    assign dmi__axi_mst_wready              = sfi_axi_master_if.wready;

    assign dmi__sfi_mst_req_rdy          = sfi_master_if.req_rdy;
    assign dmi__sfi_mst_rsp_data         = sfi_master_if.rsp_data;
    assign dmi__sfi_mst_rsp_errcode      = sfi_master_if.rsp_errCode;
    assign dmi__sfi_mst_rsp_last         = sfi_master_if.rsp_last;
    assign dmi__sfi_mst_rsp_protbits     = sfi_master_if.rsp_protBits;
    assign dmi__sfi_mst_rsp_sfipriv      = sfi_master_if.rsp_sfiPriv;
    assign dmi__sfi_mst_rsp_status       = sfi_master_if.rsp_status;
    assign dmi__sfi_mst_rsp_transid      = sfi_master_if.rsp_transId;
    assign dmi__sfi_mst_rsp_vld          = sfi_master_if.rsp_vld;
    assign dmi__sfi_slv_req_addr         = sfi_slave_if.req_addr;
    assign dmi__sfi_slv_req_be           = sfi_slave_if.req_be;
    assign dmi__sfi_slv_req_burst_type   = sfi_slave_if.req_burst;
    assign dmi__sfi_slv_req_data         = sfi_slave_if.req_data;
    assign dmi__sfi_slv_req_hurry        = sfi_slave_if.req_hurry;
    assign dmi__sfi_slv_req_last         = sfi_slave_if.req_last;
    assign dmi__sfi_slv_req_length       = sfi_slave_if.req_length;
    assign dmi__sfi_slv_req_opc          = sfi_slave_if.req_opc;
    assign dmi__sfi_slv_req_press        = sfi_slave_if.req_press;
    assign dmi__sfi_slv_req_protbits     = sfi_slave_if.req_protBits;
    assign dmi__sfi_slv_req_security     = sfi_slave_if.req_security;
    assign dmi__sfi_slv_req_sfipriv      = sfi_slave_if.req_sfiPriv;
    assign dmi__sfi_slv_req_sfislvid     = sfi_slave_if.req_sfiSlvId;
    assign dmi__sfi_slv_req_transid      = sfi_slave_if.req_transId;
    assign dmi__sfi_slv_req_urgency      = sfi_slave_if.req_urgency;
    assign dmi__sfi_slv_req_vld          = sfi_slave_if.req_vld;
    assign dmi__sfi_slv_rsp_rdy          = sfi_slave_if.rsp_rdy;

  //
  // DMI output signals
  //
    assign sfi_axi_master_if.araddr   = dmi__axi_mst_araddr;
    assign sfi_axi_master_if.arburst  = dmi__axi_mst_arburst;
    assign sfi_axi_master_if.arcache  = dmi__axi_mst_arcache;
    assign sfi_axi_master_if.arid     = dmi__axi_mst_arid;
    assign sfi_axi_master_if.arlen    = dmi__axi_mst_arlen;
    assign sfi_axi_master_if.arlock   = dmi__axi_mst_arlock;
    assign sfi_axi_master_if.arprot   = dmi__axi_mst_arprot;
    assign sfi_axi_master_if.arqos    = dmi__axi_mst_arqos;
    assign sfi_axi_master_if.arregion = dmi__axi_mst_arregion;
    assign sfi_axi_master_if.arsize   = dmi__axi_mst_arsize;
    assign sfi_axi_master_if.aruser   = dmi__axi_mst_aruser;
    assign sfi_axi_master_if.arvalid  = dmi__axi_mst_arvalid;
    assign sfi_axi_master_if.awaddr   = dmi__axi_mst_awaddr;
    assign sfi_axi_master_if.awburst  = dmi__axi_mst_awburst;
    assign sfi_axi_master_if.awcache  = dmi__axi_mst_awcache;
    assign sfi_axi_master_if.awid     = dmi__axi_mst_awid;
    assign sfi_axi_master_if.awlen    = dmi__axi_mst_awlen;
    assign sfi_axi_master_if.awlock   = dmi__axi_mst_awlock;
    assign sfi_axi_master_if.awprot   = dmi__axi_mst_awprot;
    assign sfi_axi_master_if.awqos    = dmi__axi_mst_awqos;
    assign sfi_axi_master_if.awregion = dmi__axi_mst_awregion;
    assign sfi_axi_master_if.awsize   = dmi__axi_mst_awsize;
    assign sfi_axi_master_if.awuser   = dmi__axi_mst_awuser;
    assign sfi_axi_master_if.awvalid  = dmi__axi_mst_awvalid;
    assign sfi_axi_master_if.bready   = dmi__axi_mst_bready;
    assign sfi_axi_master_if.rready   = dmi__axi_mst_rready;
    assign sfi_axi_master_if.wdata    = dmi__axi_mst_wdata;
    assign sfi_axi_master_if.wlast    = dmi__axi_mst_wlast;
    assign sfi_axi_master_if.wstrb    = dmi__axi_mst_wstrb;
    assign sfi_axi_master_if.wuser    = dmi__axi_mst_wuser;
    assign sfi_axi_master_if.wvalid   = dmi__axi_mst_wvalid;

    assign sfi_master_if.req_addr       = dmi__sfi_mst_req_addr;
    assign sfi_master_if.req_be         = dmi__sfi_mst_req_be;
    assign sfi_master_if.req_burst      = dmi__sfi_mst_req_burst_type;
    assign sfi_master_if.req_data       = dmi__sfi_mst_req_data;
    assign sfi_master_if.req_hurry      = dmi__sfi_mst_req_hurry;
    assign sfi_master_if.req_last       = dmi__sfi_mst_req_last;
    assign sfi_master_if.req_length     = dmi__sfi_mst_req_length;
    assign sfi_master_if.req_opc        = dmi__sfi_mst_req_opc;
    assign sfi_master_if.req_press      = dmi__sfi_mst_req_press;
    assign sfi_master_if.req_protBits   = dmi__sfi_mst_req_protbits;
    assign sfi_master_if.req_security   = dmi__sfi_mst_req_security;
    assign sfi_master_if.req_sfiPriv    = dmi__sfi_mst_req_sfipriv;
    assign sfi_master_if.req_sfiSlvId   = dmi__sfi_mst_req_sfislvid;
    assign sfi_master_if.req_transId    = dmi__sfi_mst_req_transid;
    assign sfi_master_if.req_urgency    = dmi__sfi_mst_req_urgency;
    assign sfi_master_if.req_vld        = dmi__sfi_mst_req_vld;
    assign sfi_master_if.rsp_rdy        = dmi__sfi_mst_rsp_rdy;

    assign sfi_slave_if.req_rdy         = dmi__sfi_slv_req_rdy;
    assign sfi_slave_if.rsp_data        = dmi__sfi_slv_rsp_data;
    assign sfi_slave_if.rsp_errCode     = dmi__sfi_slv_rsp_errcode;
    assign sfi_slave_if.rsp_last        = dmi__sfi_slv_rsp_last;
    assign sfi_slave_if.rsp_protBits    = dmi__sfi_slv_rsp_protbits;
    assign sfi_slave_if.rsp_sfiPriv     = dmi__sfi_slv_rsp_sfipriv;
    assign sfi_slave_if.rsp_status      = dmi__sfi_slv_rsp_status;
    assign sfi_slave_if.rsp_transId     = dmi__sfi_slv_rsp_transid;
    assign sfi_slave_if.rsp_vld         = dmi__sfi_slv_rsp_vld;

endmodule
