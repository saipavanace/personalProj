
//Dummmy CHI RTL to simulate CHI behavior
module rtl_top(
  input  logic                  reset,
  input  logic                  clock,
  output logic                  tx_s_active,
  input  logic                  rx_s_active,
  output logic                  tx_link_active_req,
  input  logic                  tx_link_active_ack,
  input  logic                  rx_link_active_req,
  output logic                  rx_link_active_ack,
  input  logic                  rx_req_flit_pend,
  input  logic                  rx_req_flitv,
  input  logic [117-1: 0]       rx_req_flit,
  output logic                  rx_req_lcrdv,
  input  logic                  rx_rsp_flit_pend,
  input  logic                  rx_rsp_flitv,
  input  logic [44: 0]          rx_rsp_flit,
  output logic                  rx_rsp_lcrdv,
  input  logic                  rx_dat_flit_pend,
  input  logic                  rx_dat_flitv,
  input  logic [190-1: 0]       rx_dat_flit,
  output logic                  rx_dat_lcrdv,
  output logic                  tx_rsp_flit_pend,
  output logic                  tx_rsp_flitv,
  output logic [44: 0]          tx_rsp_flit,
  input  logic                  tx_rsp_lcrdv,
  output logic                  tx_dat_flit_pend,
  output logic                  tx_dat_flitv,
  output logic [190-1: 0]       tx_dat_flit,
  input  logic                  tx_dat_lcrdv,
  output logic                  tx_snp_flit_pend,
  output logic                  tx_snp_flitv,
  output logic [64: 0]          tx_snp_flit,
  input  logic                  tx_snp_lcrdv
);

always @(posedge clock) begin

  if (!reset) begin
    tx_s_active <= 'h0;
    tx_link_active_req <= 'h0;
    rx_link_active_ack <= 'h0;
    rx_req_lcrdv <= 'h0;
    rx_rsp_lcrdv <= 'h0;
    rx_dat_lcrdv <= 'h0;
    tx_rsp_flit_pend <= 'h0;
    tx_rsp_flitv <= 'h0;
    tx_rsp_flit <= 'h0;
    tx_dat_flit_pend <= 'h0;
    tx_dat_flitv <= 'h0;
    tx_dat_flit <= 'h0;
    tx_snp_flit_pend <= 'h0;
    tx_snp_flitv <= 'h0;
    tx_snp_flit <= 'h0;
  end
end

endmodule: rtl_top
