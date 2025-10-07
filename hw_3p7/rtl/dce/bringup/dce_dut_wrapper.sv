module dce_dut (

  input logic    clk,
  input logic    rst_n,
  sfi_if.slave   slave_if,
  sfi_if.master  master_if

);

//
// DCE input signals
//
logic dce__sfi_mst_req_rdy;
logic [63:0] dce__sfi_mst_rsp_data;
logic [2:0] dce__sfi_mst_rsp_errcode;
logic dce__sfi_mst_rsp_last;
logic [7:0] dce__sfi_mst_rsp_protbits;
logic [19:0] dce__sfi_mst_rsp_sfipriv;
logic dce__sfi_mst_rsp_status;
logic [7:0] dce__sfi_mst_rsp_transid;
logic dce__sfi_mst_rsp_vld;

logic [39:0] dce__sfi_slv_req_addr;
logic [7:0] dce__sfi_slv_req_be;
logic dce__sfi_slv_req_burst_type;
logic [63:0] dce__sfi_slv_req_data;
logic [2:0] dce__sfi_slv_req_hurry;
logic dce__sfi_slv_req_last;
logic [5:0] dce__sfi_slv_req_length;
logic dce__sfi_slv_req_opc;
logic [2:0] dce__sfi_slv_req_press;
logic [7:0] dce__sfi_slv_req_protbits;
logic [2:0] dce__sfi_slv_req_security;
logic [19:0] dce__sfi_slv_req_sfipriv;
logic [2:0] dce__sfi_slv_req_sfislvid;
logic [7:0] dce__sfi_slv_req_transid;
logic [2:0] dce__sfi_slv_req_urgency;
logic dce__sfi_slv_req_vld;
logic dce__sfi_slv_rsp_rdy;

//
// DCE output signals
//
logic [39:0] dce__sfi_mst_req_addr;
logic [7:0] dce__sfi_mst_req_be;
logic dce__sfi_mst_req_burst_type;
logic [63:0] dce__sfi_mst_req_data;
logic [2:0] dce__sfi_mst_req_hurry;
logic dce__sfi_mst_req_last;
logic [5:0] dce__sfi_mst_req_length;
logic dce__sfi_mst_req_opc;
logic [2:0] dce__sfi_mst_req_press;
logic [7:0] dce__sfi_mst_req_protbits;
logic [2:0] dce__sfi_mst_req_security;
logic [19:0] dce__sfi_mst_req_sfipriv;
logic [2:0] dce__sfi_mst_req_sfislvid;
logic [7:0] dce__sfi_mst_req_transid;
logic [2:0] dce__sfi_mst_req_urgency;
logic dce__sfi_mst_req_vld;
logic dce__sfi_mst_rsp_rdy;

logic dce__sfi_slv_req_rdy;
logic [63:0] dce__sfi_slv_rsp_data;
logic [2:0] dce__sfi_slv_rsp_errcode;
logic dce__sfi_slv_rsp_last;
logic [7:0] dce__sfi_slv_rsp_protbits;
logic [19:0] dce__sfi_slv_rsp_sfipriv;
logic dce__sfi_slv_rsp_status;
logic [7:0] dce__sfi_slv_rsp_transid;
logic dce__sfi_slv_rsp_vld;


top__top__coh__dce dce (
    .sfi_mst_req_rdy(dce__sfi_mst_req_rdy),
    .sfi_mst_req_vld(dce__sfi_mst_req_vld),
    .sfi_mst_req_last(dce__sfi_mst_req_last),
    .sfi_mst_req_opc(dce__sfi_mst_req_opc),
    .sfi_mst_req_burst_type(dce__sfi_mst_req_burst_type),
    .sfi_mst_req_length(dce__sfi_mst_req_length),
    .sfi_mst_req_addr(dce__sfi_mst_req_addr),
    .sfi_mst_req_sfislvid(dce__sfi_mst_req_sfislvid),
    .sfi_mst_req_sfipriv(dce__sfi_mst_req_sfipriv),
    .sfi_mst_req_transid(dce__sfi_mst_req_transid),
    .sfi_mst_req_urgency(dce__sfi_mst_req_urgency),
    .sfi_mst_req_security(dce__sfi_mst_req_security),
    .sfi_mst_req_be(dce__sfi_mst_req_be),
    .sfi_mst_req_data(dce__sfi_mst_req_data),
    .sfi_mst_req_protbits(dce__sfi_mst_req_protbits),
    .sfi_mst_rsp_rdy(dce__sfi_mst_rsp_rdy),
    .sfi_mst_rsp_vld(dce__sfi_mst_rsp_vld),
    .sfi_mst_rsp_last(dce__sfi_mst_rsp_last),
    .sfi_mst_rsp_status(dce__sfi_mst_rsp_status),
    .sfi_mst_rsp_errcode(dce__sfi_mst_rsp_errcode),
    .sfi_mst_rsp_transid(dce__sfi_mst_rsp_transid),
    .sfi_mst_rsp_sfipriv(dce__sfi_mst_rsp_sfipriv),
    .sfi_mst_rsp_data(dce__sfi_mst_rsp_data),
    .sfi_mst_rsp_protbits(dce__sfi_mst_rsp_protbits),
    .sfi_mst_req_press(dce__sfi_mst_req_press),
    .sfi_mst_req_hurry(dce__sfi_mst_req_hurry),
    .sfi_slv_req_rdy(dce__sfi_slv_req_rdy),
    .sfi_slv_req_vld(dce__sfi_slv_req_vld),
    .sfi_slv_req_last(dce__sfi_slv_req_last),
    .sfi_slv_req_opc(dce__sfi_slv_req_opc),
    .sfi_slv_req_burst_type(dce__sfi_slv_req_burst_type),
    .sfi_slv_req_length(dce__sfi_slv_req_length),
    .sfi_slv_req_addr(dce__sfi_slv_req_addr),
    .sfi_slv_req_sfislvid(dce__sfi_slv_req_sfislvid),
    .sfi_slv_req_sfipriv(dce__sfi_slv_req_sfipriv),
    .sfi_slv_req_transid(dce__sfi_slv_req_transid),
    .sfi_slv_req_urgency(dce__sfi_slv_req_urgency),
    .sfi_slv_req_security(dce__sfi_slv_req_security),
    .sfi_slv_req_be(dce__sfi_slv_req_be),
    .sfi_slv_req_data(dce__sfi_slv_req_data),
    .sfi_slv_req_protbits(dce__sfi_slv_req_protbits),
    .sfi_slv_rsp_rdy(dce__sfi_slv_rsp_rdy),
    .sfi_slv_rsp_vld(dce__sfi_slv_rsp_vld),
    .sfi_slv_rsp_last(dce__sfi_slv_rsp_last),
    .sfi_slv_rsp_status(dce__sfi_slv_rsp_status),
    .sfi_slv_rsp_errcode(dce__sfi_slv_rsp_errcode),
    .sfi_slv_rsp_transid(dce__sfi_slv_rsp_transid),
    .sfi_slv_rsp_sfipriv(dce__sfi_slv_rsp_sfipriv),
    .sfi_slv_rsp_data(dce__sfi_slv_rsp_data),
    .sfi_slv_rsp_protbits(dce__sfi_slv_rsp_protbits),
    .sfi_slv_req_press(dce__sfi_slv_req_press),
    .sfi_slv_req_hurry(dce__sfi_slv_req_hurry),
    .clk(clk),
    .reset_n(rst_n)
);

  //
  // DUT input signals
  //
  assign dce__sfi_mst_req_rdy          = master_if.req_rdy;
  assign dce__sfi_mst_rsp_data         = master_if.rsp_data;
  assign dce__sfi_mst_rsp_errcode      = master_if.rsp_errCode;
  assign dce__sfi_mst_rsp_last         = master_if.rsp_last;
  assign dce__sfi_mst_rsp_protbits     = master_if.rsp_protBits;
  assign dce__sfi_mst_rsp_sfipriv      = master_if.rsp_sfiPriv;
  assign dce__sfi_mst_rsp_status       = master_if.rsp_status;
  assign dce__sfi_mst_rsp_transid      = master_if.rsp_transId;
  assign dce__sfi_mst_rsp_vld          = master_if.rsp_vld;
  assign dce__sfi_slv_req_addr         = slave_if.req_addr;
  assign dce__sfi_slv_req_be           = slave_if.req_be;
  assign dce__sfi_slv_req_burst_type   = slave_if.req_burst;
  assign dce__sfi_slv_req_data         = slave_if.req_data;
  assign dce__sfi_slv_req_hurry        = slave_if.req_hurry;
  assign dce__sfi_slv_req_last         = slave_if.req_last;
  assign dce__sfi_slv_req_length       = slave_if.req_length;
  assign dce__sfi_slv_req_opc          = slave_if.req_opc;
  assign dce__sfi_slv_req_press        = slave_if.req_press;
  assign dce__sfi_slv_req_protbits     = slave_if.req_protBits;
  assign dce__sfi_slv_req_security     = slave_if.req_security;
  assign dce__sfi_slv_req_sfipriv      = slave_if.req_sfiPriv;
  assign dce__sfi_slv_req_sfislvid     = slave_if.req_sfiSlvId;
  assign dce__sfi_slv_req_transid      = slave_if.req_transId;
  assign dce__sfi_slv_req_urgency      = slave_if.req_urgency;
  assign dce__sfi_slv_req_vld          = slave_if.req_vld;
  assign dce__sfi_slv_rsp_rdy          = slave_if.rsp_rdy;

  //
  // DUT output signals
  //
    assign master_if.req_addr       = dce__sfi_mst_req_addr;
    assign master_if.req_be         = dce__sfi_mst_req_be;
    assign master_if.req_burst      = dce__sfi_mst_req_burst_type;
    assign master_if.req_data       = dce__sfi_mst_req_data;
    assign master_if.req_hurry      = dce__sfi_mst_req_hurry;
    assign master_if.req_last       = dce__sfi_mst_req_last;
    assign master_if.req_length     = dce__sfi_mst_req_length;
    assign master_if.req_opc        = dce__sfi_mst_req_opc;
    assign master_if.req_press      = dce__sfi_mst_req_press;
    assign master_if.req_protBits   = dce__sfi_mst_req_protbits;
    assign master_if.req_security   = dce__sfi_mst_req_security;
    assign master_if.req_sfiPriv    = dce__sfi_mst_req_sfipriv;
    assign master_if.req_sfiSlvId   = dce__sfi_mst_req_sfislvid;
    assign master_if.req_transId    = dce__sfi_mst_req_transid;
    assign master_if.req_urgency    = dce__sfi_mst_req_urgency;
    assign master_if.req_vld        = dce__sfi_mst_req_vld;
    assign master_if.rsp_rdy        = dce__sfi_mst_rsp_rdy;
    assign slave_if.req_rdy         = dce__sfi_slv_req_rdy;
    assign slave_if.rsp_data        = dce__sfi_slv_rsp_data;
    assign slave_if.rsp_errCode     = dce__sfi_slv_rsp_errcode;
    assign slave_if.rsp_last        = dce__sfi_slv_rsp_last;
    assign slave_if.rsp_protBits    = dce__sfi_slv_rsp_protbits;
    assign slave_if.rsp_sfiPriv     = dce__sfi_slv_rsp_sfipriv;
    assign slave_if.rsp_status      = dce__sfi_slv_rsp_status;
    assign slave_if.rsp_transId     = dce__sfi_slv_rsp_transid;
    assign slave_if.rsp_vld         = dce__sfi_slv_rsp_vld;

endmodule : dce_dut
