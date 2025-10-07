

module fsys_config1 (
input 		clk,
input 		reset_n,
input [ 6 : 0]	chiaiuMyId,
input [ 6 : 0]	ioaiuMyId,
input [ 6 : 0]	dmiMyId,
input [ 6 : 0]	diiMyId,
output 		awready,
input 		awvalid,
input [ 11 : 0]	awid,
input [ 31 : 0]	awaddr,
input [ 7 : 0]	awlen,
input [ 2 : 0]	awsize,
input [ 1 : 0]	awburst,
input 		awlock,
input [ 3 : 0]	awcache,
input [ 2 : 0]	awprot,
input [ 3 : 0]	awqos,
input [ 11 : 0]	awuser,
input [ 1 : 0]	awdomain,
input [ 2 : 0]	awsnoop,
input [ 1 : 0]	awbar,
output 		wready,
input 		wvalid,
input [ 127 : 0]	wdata,
input [ 15 : 0]	wstrb,
input 		wlast,
input 		bready,
output 		bvalid,
output [ 11 : 0]	bid,
output [ 1 : 0]	bresp,
output 		arready,
input 		arvalid,
input [ 11 : 0]	arid,
input [ 31 : 0]	araddr,
input [ 7 : 0]	arlen,
input [ 2 : 0]	arsize,
input [ 1 : 0]	arburst,
input 		arlock,
input [ 3 : 0]	arcache,
input [ 2 : 0]	arprot,
input [ 3 : 0]	arqos,
input [ 11 : 0]	aruser,
input [ 1 : 0]	ardomain,
input [ 3 : 0]	arsnoop,
input [ 1 : 0]	arbar,
input 		rready,
output 		rvalid,
output [ 11 : 0]	rid,
output [ 127 : 0]	rdata,
output [ 1 : 0]	rresp,
output 		rlast,
output [ 11 : 0]	ruser,
input RXREQFLITPEND,
input RXREQFLITV,
output RXREQLCRDV,
input RXRSPFLITPEND,
input RXRSPFLITV,
output RXRSPLCRDV,
input RXDATFLITPEND,
input RXDATFLITV,
output RXDATLCRDV,
input [ 120 : 0]RXREQFLIT,
input [ 47 : 0]RXRSPFLIT,
input [ 200 : 0]RXDATFLIT,
output TXSNPFLITPEND,
output TXSNPFLITV,
input TXSNPLCRDV,
output TXRSPFLITPEND,
output TXRSPFLITV,
input TXRSPLCRDV,
output TXDATFLITPEND,
output TXDATFLITV,
input TXDATLCRDV,
output [ 84 : 0]TXSNPFLIT,
output [ 47 : 0]TXRSPFLIT,
output [ 200 : 0]TXDATFLIT,
input RXLINKACTIVEREQ,
output RXLINKACTIVEACK,
output TXLINKACTIVEREQ,
input TXLINKACTIVEACK,
output dmi_axi_mst_awvalid,
input dmi_axi_mst_awready,
output [ 31 : 0]dmi_axi_mst_awaddr,
output [ 1 : 0]dmi_axi_mst_awburst,
output [ 7 : 0]dmi_axi_mst_awlen,
output dmi_axi_mst_awlock,
output [ 2 : 0]dmi_axi_mst_awprot,
output [ 3 : 0]dmi_axi_mst_awqos,
output [ 3 : 0]dmi_axi_mst_awregion,
output [ 2 : 0]dmi_axi_mst_awsize,
output [ 3 : 0]dmi_axi_mst_awuser,
output [ 3 : 0]dmi_axi_mst_awcache,
output [ 4 : 0]dmi_axi_mst_awid,
output dmi_axi_mst_wvalid,
input dmi_axi_mst_wready,
output dmi_axi_mst_wlast,
output [127 : 0]dmi_axi_mst_wdata,
output [ 15 : 0]dmi_axi_mst_wstrb,
input dmi_axi_mst_bvalid,
output dmi_axi_mst_bready,
input [ 1 : 0]dmi_axi_mst_bresp,
input [ 4 : 0]dmi_axi_mst_bid,
output dmi_axi_mst_arvalid,
input dmi_axi_mst_arready,
output [ 31 : 0]dmi_axi_mst_araddr,
output [ 1 : 0]dmi_axi_mst_arburst,
output [ 7 : 0]dmi_axi_mst_arlen,
output dmi_axi_mst_arlock,
output [ 2 : 0]dmi_axi_mst_arprot,
output [ 3 : 0]dmi_axi_mst_arqos,
output [ 2 : 0]dmi_axi_mst_arsize,
output [ 3 : 0]dmi_axi_mst_aruser,
output [ 4 : 0]dmi_axi_mst_arid,
input dmi_axi_mst_rvalid,
output dmi_axi_mst_rready,
input dmi_axi_mst_rlast,
input [ 1 : 0]dmi_axi_mst_rresp,
input [ 127 : 0]dmi_axi_mst_rdata,
input [ 1 : 0]dmi_axi_mst_rid,
output dii_axi_mst_awvalid,
input  dii_axi_mst_awready,
output [ 31 : 0]dii_axi_mst_awaddr,
output [  1 : 0]dii_axi_mst_awburst,
output [  7 : 0]dii_axi_mst_awlen,
output          dii_axi_mst_awlock,
output [  2 : 0]dii_axi_mst_awprot,
output [  3 : 0]dii_axi_mst_awqos,
output [  3 : 0]dii_axi_mst_awregion,
output [  2 : 0]dii_axi_mst_awsize,
output [  3 : 0]dii_axi_mst_awuser,
output [  3 : 0]dii_axi_mst_awcache,
output [  4 : 0]dii_axi_mst_awid,
output dii_axi_mst_wvalid,
input dii_axi_mst_wready,
output dii_axi_mst_wlast,
output [127 : 0]dii_axi_mst_wdata,
output [ 31 : 0]dii_axi_mst_wstrb,
input dii_axi_mst_bvalid,
output dii_axi_mst_bready,
input [ 1 : 0]dii_axi_mst_bresp,
input [ 4 : 0]dii_axi_mst_bid,
output dii_axi_mst_arvalid,
input dii_axi_mst_arready,
output [ 31 : 0]dii_axi_mst_araddr,
output [ 1 : 0]dii_axi_mst_arburst,
output [ 7 : 0]dii_axi_mst_arlen,
output dii_axi_mst_arlock,
output [ 2 : 0]dii_axi_mst_arprot,
output [ 3 : 0]dii_axi_mst_arqos,
output [ 2 : 0]dii_axi_mst_arsize,
output [ 3 : 0]dii_axi_mst_aruser,
output [ 4 : 0]dii_axi_mst_arid,
input dii_axi_mst_rvalid,
output dii_axi_mst_rready,
input dii_axi_mst_rlast,
input [ 1 : 0]dii_axi_mst_rresp,
input [ 127 : 0]dii_axi_mst_rdata,
input [ 1 : 0]dii_axi_mst_rid
);



wire  	        io_smi_nd_msg0_tx_ndp_valid;
wire 	        io_smi_nd_msg0_tx_ndp_ready;
wire  [ 7 : 0]	io_smi_nd_msg0_tx_ndp_pbits;
wire  	        io_smi_nd_msg0_tx_ndp_dp_present;
wire  [ 9 : 0]	io_smi_nd_msg0_tx_ndp_target_id;
wire  [ 9 : 0]	io_smi_nd_msg0_tx_ndp_initiator_id;
wire  [ 9 : 0]	io_smi_nd_msg0_tx_ndp_message_id;
wire  [ 7 : 0]	io_smi_nd_msg0_tx_ndp_cm_type;
wire  [ 7 : 0]	io_smi_nd_msg0_tx_ndp_h_prot;
wire  [ 2 : 0]	io_smi_nd_msg0_tx_ndp_t_tier;
wire  [ 2 : 0]	io_smi_nd_msg0_tx_ndp_steering;
wire  [ 2 : 0]	io_smi_nd_msg0_tx_ndp_priority;
wire  [ 2 : 0]	io_smi_nd_msg0_tx_ndp_ql;
wire  [102 : 0]	io_smi_nd_msg0_tx_ndp_body;
wire        	io_smi_nd_msg1_tx_ndp_valid;
wire        	io_smi_nd_msg1_tx_ndp_ready;
wire  [ 7 : 0]	io_smi_nd_msg1_tx_ndp_pbits;
wire  	        io_smi_nd_msg1_tx_ndp_dp_present;
wire  [ 9 : 0]	io_smi_nd_msg1_tx_ndp_target_id;
wire  [ 9 : 0]	io_smi_nd_msg1_tx_ndp_initiator_id;
wire  [ 9 : 0]	io_smi_nd_msg1_tx_ndp_message_id;
wire  [ 7 : 0]	io_smi_nd_msg1_tx_ndp_cm_type;
wire  [ 7 : 0]	io_smi_nd_msg1_tx_ndp_h_prot;
wire  [ 2 : 0]	io_smi_nd_msg1_tx_ndp_t_tier;
wire  [ 2 : 0]	io_smi_nd_msg1_tx_ndp_steering;
wire  [ 2 : 0]	io_smi_nd_msg1_tx_ndp_priority;
wire  [ 2 : 0]	io_smi_nd_msg1_tx_ndp_ql;
wire  [ 102 :0] io_smi_nd_msg1_tx_ndp_body;
wire  	        io_smi_nd_msg2_tx_ndp_valid;
wire 	        io_smi_nd_msg2_tx_ndp_ready;
wire  [ 7 : 0]	io_smi_nd_msg2_tx_ndp_pbits;
wire  	        io_smi_nd_msg2_tx_ndp_dp_present;
wire  [ 2 : 0]	io_smi_nd_msg2_tx_ndp_cdwid;
wire  [ 9 : 0]	io_smi_nd_msg2_tx_ndp_target_id;
wire  [ 9 : 0]	io_smi_nd_msg2_tx_ndp_initiator_id;
wire  [ 9 : 0]	io_smi_nd_msg2_tx_ndp_message_id;
wire  [ 7 : 0]	io_smi_nd_msg2_tx_ndp_cm_type;
wire  [ 7 : 0]	io_smi_nd_msg2_tx_ndp_h_prot;
wire  [ 2 : 0]	io_smi_nd_msg2_tx_ndp_t_tier;
wire  [ 2 : 0]	io_smi_nd_msg2_tx_ndp_steering;
wire  [ 2 : 0]	io_smi_nd_msg2_tx_ndp_priority;
wire  [ 2 : 0]	io_smi_nd_msg2_tx_ndp_ql;
wire  [102 : 0]	io_smi_nd_msg2_tx_ndp_body;
wire        	io_smi_nd_msg2_tx_dp_valid;
wire 	        io_smi_nd_msg2_tx_dp_ready;
wire  	        io_smi_nd_msg2_tx_dp_last;
wire [ 127 : 0] io_smi_nd_msg2_tx_dp_data;
wire  [ 23 : 0] io_smi_nd_msg2_tx_dp_aux;
wire 	        io_smi_nd_msg0_rx_ndp_valid;
wire  	        io_smi_nd_msg0_rx_ndp_ready;
wire [ 7 : 0]	io_smi_nd_msg0_rx_ndp_pbits;
wire 	        io_smi_nd_msg0_rx_ndp_dp_present;
wire [ 9 : 0]	io_smi_nd_msg0_rx_ndp_target_id;
wire [ 9 : 0]	io_smi_nd_msg0_rx_ndp_initiator_id;
wire [ 9 : 0]	io_smi_nd_msg0_rx_ndp_message_id;
wire [ 7 : 0]	io_smi_nd_msg0_rx_ndp_cm_type;
wire [ 7 : 0]	io_smi_nd_msg0_rx_ndp_h_prot;
wire [ 2 : 0]	io_smi_nd_msg0_rx_ndp_t_tier;
wire [ 2 : 0]	io_smi_nd_msg0_rx_ndp_steering;
wire [ 2 : 0]	io_smi_nd_msg0_rx_ndp_priority;
wire [ 2 : 0]	io_smi_nd_msg0_rx_ndp_ql;
wire [ 102 : 0] io_smi_nd_msg0_rx_ndp_body;
wire 	        io_smi_nd_msg1_rx_ndp_valid;
wire         	io_smi_nd_msg1_rx_ndp_ready;
wire [ 7 : 0]	io_smi_nd_msg1_rx_ndp_pbits;
wire 	        io_smi_nd_msg1_rx_ndp_dp_present;
wire [ 9 : 0]	io_smi_nd_msg1_rx_ndp_target_id;
wire [ 9 : 0]	io_smi_nd_msg1_rx_ndp_initiator_id;
wire [ 9 : 0]	io_smi_nd_msg1_rx_ndp_message_id;
wire [ 7 : 0]	io_smi_nd_msg1_rx_ndp_cm_type;
wire [ 7 : 0]	io_smi_nd_msg1_rx_ndp_h_prot;
wire [ 2 : 0]	io_smi_nd_msg1_rx_ndp_t_tier;
wire [ 2 : 0]	io_smi_nd_msg1_rx_ndp_steering;
wire [ 2 : 0]	io_smi_nd_msg1_rx_ndp_priority;
wire [ 2 : 0]	io_smi_nd_msg1_rx_ndp_ql;
wire [102 : 0]	io_smi_nd_msg1_rx_ndp_body;
wire       	    io_smi_nd_msg2_rx_ndp_valid;
wire  	        io_smi_nd_msg2_rx_ndp_ready;
wire [ 7 : 0]	io_smi_nd_msg2_rx_ndp_pbits;
wire 	        io_smi_nd_msg2_rx_ndp_dp_present;
wire [ 2 : 0]	io_smi_nd_msg2_rx_ndp_cdwid;
wire [ 9 : 0]	io_smi_nd_msg2_rx_ndp_target_id;
wire [ 9 : 0]	io_smi_nd_msg2_rx_ndp_initiator_id;
wire [ 9 : 0]	io_smi_nd_msg2_rx_ndp_message_id;
wire [ 7 : 0]	io_smi_nd_msg2_rx_ndp_cm_type;
wire [ 7 : 0]	io_smi_nd_msg2_rx_ndp_h_prot;
wire [ 2 : 0]	io_smi_nd_msg2_rx_ndp_t_tier;
wire [ 2 : 0]	io_smi_nd_msg2_rx_ndp_steering;
wire [ 2 : 0]	io_smi_nd_msg2_rx_ndp_priority;
wire [ 2 : 0]	io_smi_nd_msg2_rx_ndp_ql;
wire [102 : 0]	io_smi_nd_msg2_rx_ndp_body;
wire        	io_smi_nd_msg2_rx_dp_valid;
wire  	        io_smi_nd_msg2_rx_dp_ready;
wire 	        io_smi_nd_msg2_rx_dp_last;
wire [ 127 : 0] io_smi_nd_msg2_rx_dp_data;
wire [ 16 : 0]	io_smi_nd_msg2_rx_dp_aux;

wire           chi_smi_nd_msg0_tx_ndp_valid;
wire           chi_smi_nd_msg0_tx_ndp_ready;
wire  [ 7 : 0] chi_smi_nd_msg0_tx_ndp_pbits;
wire           chi_smi_nd_msg0_tx_ndp_dp_present;
wire  [ 9 : 0] chi_smi_nd_msg0_tx_ndp_target_id;
wire  [ 9 : 0] chi_smi_nd_msg0_tx_ndp_initiator_id;
wire  [ 9 : 0] chi_smi_nd_msg0_tx_ndp_transaction_id;
wire  [ 7 : 0] chi_smi_nd_msg0_tx_ndp_cm_type;
wire  [ 7 : 0] chi_smi_nd_msg0_tx_ndp_h_prot;
wire  [ 2 : 0] chi_smi_nd_msg0_tx_ndp_t_tier;
wire  [ 2 : 0] chi_smi_nd_msg0_tx_ndp_steering;
wire  [ 2 : 0] chi_smi_nd_msg0_tx_ndp_priority;
wire  [ 2 : 0] chi_smi_nd_msg0_tx_ndp_ql;
wire  [ 99 : 0]chi_smi_nd_msg0_tx_ndp_body;
wire           chi_smi_nd_msg1_tx_ndp_valid;
wire           chi_smi_nd_msg1_tx_ndp_ready;
wire  [ 7 : 0] chi_smi_nd_msg1_tx_ndp_pbits;
wire           chi_smi_nd_msg1_tx_ndp_dp_present;
wire  [ 9 : 0] chi_smi_nd_msg1_tx_ndp_target_id;
wire  [ 9 : 0] chi_smi_nd_msg1_tx_ndp_initiator_id;
wire  [ 9 : 0] chi_smi_nd_msg1_tx_ndp_transaction_id;
wire  [ 7 : 0] chi_smi_nd_msg1_tx_ndp_cm_type;
wire  [ 7 : 0] chi_smi_nd_msg1_tx_ndp_h_prot;
wire  [ 2 : 0] chi_smi_nd_msg1_tx_ndp_t_tier;
wire  [ 2 : 0] chi_smi_nd_msg1_tx_ndp_steering;
wire  [ 2 : 0] chi_smi_nd_msg1_tx_ndp_priority;
wire  [ 2 : 0] chi_smi_nd_msg1_tx_ndp_ql;
wire  [ 99 : 0]chi_smi_nd_msg1_tx_ndp_body;
wire           chi_smi_nd_msg2_tx_ndp_valid;
wire           chi_smi_nd_msg2_tx_ndp_ready;
wire  [ 7 : 0] chi_smi_nd_msg2_tx_ndp_pbits;
wire           chi_smi_nd_msg2_tx_ndp_dp_present;
wire  [ 2 : 0] chi_smi_nd_msg2_tx_ndp_cdwid;
wire  [ 9 : 0] chi_smi_nd_msg2_tx_ndp_target_id;
wire  [ 9 : 0] chi_smi_nd_msg2_tx_ndp_initiator_id;
wire  [ 9 : 0] chi_smi_nd_msg2_tx_ndp_transaction_id;
wire  [ 7 : 0] chi_smi_nd_msg2_tx_ndp_cm_type;
wire  [ 7 : 0] chi_smi_nd_msg2_tx_ndp_h_prot;
wire  [ 2 : 0] chi_smi_nd_msg2_tx_ndp_t_tier;
wire  [ 2 : 0] chi_smi_nd_msg2_tx_ndp_steering;
wire  [ 2 : 0] chi_smi_nd_msg2_tx_ndp_priority;
wire  [ 2 : 0] chi_smi_nd_msg2_tx_ndp_ql;
wire  [ 31 : 0]chi_smi_nd_msg2_tx_ndp_body;
wire           chi_smi_nd_msg2_tx_dp_valid;
wire           chi_smi_nd_msg2_tx_dp_ready;
wire           chi_smi_nd_msg2_tx_dp_last;
wire  [127 : 0]chi_smi_nd_msg2_tx_dp_data;
wire  [ 32 : 0]chi_smi_nd_msg2_tx_dp_aux;
wire           chi_smi_nd_msg0_rx_ndp_valid;
wire           chi_smi_nd_msg0_rx_ndp_ready;
wire [ 7 : 0]  chi_smi_nd_msg0_rx_ndp_pbits;
wire           chi_smi_nd_msg0_rx_ndp_dp_present;
wire [ 9 : 0]  chi_smi_nd_msg0_rx_ndp_target_id;
wire [ 9 : 0]  chi_smi_nd_msg0_rx_ndp_initiator_id;
wire [ 9 : 0]  chi_smi_nd_msg0_rx_ndp_transaction_id;
wire [ 7 : 0]  chi_smi_nd_msg0_rx_ndp_cm_type;
wire [ 7 : 0]  chi_smi_nd_msg0_rx_ndp_h_prot;
wire [ 2 : 0]  chi_smi_nd_msg0_rx_ndp_t_tier;
wire [ 2 : 0]  chi_smi_nd_msg0_rx_ndp_steering;
wire [ 2 : 0]  chi_smi_nd_msg0_rx_ndp_priority;
wire [ 2 : 0]  chi_smi_nd_msg0_rx_ndp_ql;
wire [ 99 : 0] chi_smi_nd_msg0_rx_ndp_body;
wire           chi_smi_nd_msg1_rx_ndp_valid;
wire           chi_smi_nd_msg1_rx_ndp_ready;
wire [ 7 : 0]  chi_smi_nd_msg1_rx_ndp_pbits;
wire           chi_smi_nd_msg1_rx_ndp_dp_present;
wire [ 9 : 0]  chi_smi_nd_msg1_rx_ndp_target_id;
wire [ 9 : 0]  chi_smi_nd_msg1_rx_ndp_initiator_id;
wire [ 9 : 0]  chi_smi_nd_msg1_rx_ndp_transaction_id;
wire [ 7 : 0]  chi_smi_nd_msg1_rx_ndp_cm_type;
wire [ 7 : 0]  chi_smi_nd_msg1_rx_ndp_h_prot;
wire [ 2 : 0]  chi_smi_nd_msg1_rx_ndp_t_tier;
wire [ 2 : 0]  chi_smi_nd_msg1_rx_ndp_steering;
wire [ 2 : 0]  chi_smi_nd_msg1_rx_ndp_priority;
wire [ 2 : 0]  chi_smi_nd_msg1_rx_ndp_ql;
wire [ 99 : 0] chi_smi_nd_msg1_rx_ndp_body;
wire           chi_smi_nd_msg2_rx_ndp_valid;
wire           chi_smi_nd_msg2_rx_ndp_ready;
wire [ 7 : 0]  chi_smi_nd_msg2_rx_ndp_pbits;
wire           chi_smi_nd_msg2_rx_ndp_dp_present;
wire [ 2 : 0]  chi_smi_nd_msg2_rx_ndp_cdwid;
wire [ 9 : 0]  chi_smi_nd_msg2_rx_ndp_target_id;
wire [ 9 : 0]  chi_smi_nd_msg2_rx_ndp_initiator_id;
wire [ 9 : 0]  chi_smi_nd_msg2_rx_ndp_transaction_id;
wire [ 7 : 0]  chi_smi_nd_msg2_rx_ndp_cm_type;
wire [ 7 : 0]  chi_smi_nd_msg2_rx_ndp_h_prot;
wire [ 2 : 0]  chi_smi_nd_msg2_rx_ndp_t_tier;
wire [ 2 : 0]  chi_smi_nd_msg2_rx_ndp_steering;
wire [ 2 : 0]  chi_smi_nd_msg2_rx_ndp_priority;
wire [ 2 : 0]  chi_smi_nd_msg2_rx_ndp_ql;
wire [ 99 : 0] chi_smi_nd_msg2_rx_ndp_body;
wire           chi_smi_nd_msg2_rx_dp_valid;
wire           chi_smi_nd_msg2_rx_dp_ready;
wire           chi_smi_nd_msg2_rx_dp_last;
wire [ 127 : 0]chi_smi_nd_msg2_rx_dp_data;
wire [ 32 : 0] chi_smi_nd_msg2_rx_dp_aux;


wire            dmi_smi_msg0_tx_ndp_valid;
wire            dmi_smi_msg0_tx_ndp_ready;
wire  [ 7 : 0]  dmi_smi_msg0_tx_ndp_pbits;
wire            dmi_smi_msg0_tx_ndp_dp_present;
wire  [ 9 : 0]  dmi_smi_msg0_tx_ndp_target_id;
wire  [ 9 : 0]  dmi_smi_msg0_tx_ndp_initiator_id;
wire  [ 9 : 0]  dmi_smi_msg0_tx_ndp_transaction_id;
wire  [ 7 : 0]  dmi_smi_msg0_tx_ndp_cm_type;
wire  [ 7 : 0]  dmi_smi_msg0_tx_ndp_h_prot;
wire  [ 2 : 0]  dmi_smi_msg0_tx_ndp_t_tier;
wire  [ 2 : 0]  dmi_smi_msg0_tx_ndp_steering;
wire  [ 2 : 0]  dmi_smi_msg0_tx_ndp_priority;
wire  [ 2 : 0]  dmi_smi_msg0_tx_ndp_ql;
reg  [119 : 0] dmi_smi_msg0_tx_ndp_body;
wire            dmi_smi_msg1_tx_ndp_valid;
wire            dmi_smi_msg1_tx_ndp_ready;
wire  [ 7 : 0]  dmi_smi_msg1_tx_ndp_pbits;
wire            dmi_smi_msg1_tx_ndp_dp_present;
wire  [ 9 : 0]  dmi_smi_msg1_tx_ndp_target_id;
wire  [ 9 : 0]  dmi_smi_msg1_tx_ndp_initiator_id;
wire  [ 9 : 0]  dmi_smi_msg1_tx_ndp_transaction_id;
wire  [ 7 : 0]  dmi_smi_msg1_tx_ndp_cm_type;
wire  [ 7 : 0]  dmi_smi_msg1_tx_ndp_h_prot;
wire  [ 2 : 0]  dmi_smi_msg1_tx_ndp_t_tier;
wire  [ 2 : 0]  dmi_smi_msg1_tx_ndp_steering;
wire  [ 2 : 0]  dmi_smi_msg1_tx_ndp_priority;
wire  [ 2 : 0]  dmi_smi_msg1_tx_ndp_ql;
reg  [119 : 0] dmi_smi_msg1_tx_ndp_body;
wire            dmi_smi_msg2_tx_ndp_valid;
wire            dmi_smi_msg2_tx_ndp_ready;
wire  [ 7 : 0]  dmi_smi_msg2_tx_ndp_pbits;
wire            dmi_smi_msg2_tx_ndp_dp_present;
wire  [ 9 : 0]  dmi_smi_msg2_tx_ndp_target_id;
wire  [ 9 : 0]  dmi_smi_msg2_tx_ndp_initiator_id;
wire  [ 9 : 0]  dmi_smi_msg2_tx_ndp_transaction_id;
wire  [ 7 : 0]  dmi_smi_msg2_tx_ndp_cm_type;
wire  [ 7 : 0]  dmi_smi_msg2_tx_ndp_h_prot;
wire  [ 2 : 0]  dmi_smi_msg2_tx_ndp_t_tier;
wire  [ 2 : 0]  dmi_smi_msg2_tx_ndp_steering;
wire  [ 2 : 0]  dmi_smi_msg2_tx_ndp_priority;
wire  [ 2 : 0]  dmi_smi_msg2_tx_ndp_ql;
reg  [119 : 0] dmi_smi_msg2_tx_ndp_body;
wire            dmi_smi_msg0_rx_ndp_valid;
wire            dmi_smi_msg0_rx_ndp_ready;
wire [ 7 : 0]   dmi_smi_msg0_rx_ndp_pbits;
wire            dmi_smi_msg0_rx_ndp_dp_present;
reg [ 9 : 0]   dmi_smi_msg0_rx_ndp_target_id;
reg [ 9 : 0]   dmi_smi_msg0_rx_ndp_initiator_id;
wire [ 9 : 0]   dmi_smi_msg0_rx_ndp_transaction_id;
wire [ 7 : 0]   dmi_smi_msg0_rx_ndp_cm_type;
wire [ 7 : 0]   dmi_smi_msg0_rx_ndp_h_prot;
wire [ 2 : 0]   dmi_smi_msg0_rx_ndp_t_tier;
wire [ 2 : 0]   dmi_smi_msg0_rx_ndp_steering;
wire [ 2 : 0]   dmi_smi_msg0_rx_ndp_priority;
wire [ 2 : 0]   dmi_smi_msg0_rx_ndp_ql;
reg [ 119 : 0] dmi_smi_msg0_rx_ndp_body;
wire            dmi_smi_msg1_rx_ndp_valid;
wire            dmi_smi_msg1_rx_ndp_ready;
wire [ 7 : 0]   dmi_smi_msg1_rx_ndp_pbits;
wire            dmi_smi_msg1_rx_ndp_dp_present;
reg [ 9 : 0]   dmi_smi_msg1_rx_ndp_target_id;
reg  [ 9 : 0]   dmi_smi_msg1_rx_ndp_initiator_id;
wire  [ 9 : 0]   dmi_smi_msg1_rx_ndp_transaction_id;
wire [ 7 : 0]   dmi_smi_msg1_rx_ndp_cm_type;
wire [ 7 : 0]   dmi_smi_msg1_rx_ndp_h_prot;
wire [ 2 : 0]   dmi_smi_msg1_rx_ndp_t_tier;
wire [ 2 : 0]   dmi_smi_msg1_rx_ndp_steering;
wire [ 2 : 0]   dmi_smi_msg1_rx_ndp_priority;
wire [ 2 : 0]   dmi_smi_msg1_rx_ndp_ql;
reg  [ 119 : 0] dmi_smi_msg1_rx_ndp_body;
wire            dmi_smi_msg2_rx_ndp_valid;
wire            dmi_smi_msg2_rx_ndp_ready;
wire [ 7 : 0]   dmi_smi_msg2_rx_ndp_pbits;
wire            dmi_smi_msg2_rx_ndp_dp_present;
reg  [ 9 : 0]   dmi_smi_msg2_rx_ndp_target_id;
reg  [ 9 : 0]   dmi_smi_msg2_rx_ndp_initiator_id;
wire [ 9 : 0]   dmi_smi_msg2_rx_ndp_transaction_id;
wire [ 7 : 0]   dmi_smi_msg2_rx_ndp_cm_type;
wire [ 7 : 0]   dmi_smi_msg2_rx_ndp_h_prot;
wire [ 2 : 0]   dmi_smi_msg2_rx_ndp_t_tier;
wire [ 2 : 0]   dmi_smi_msg2_rx_ndp_steering;
wire [ 2 : 0]   dmi_smi_msg2_rx_ndp_priority;
wire [ 2 : 0]   dmi_smi_msg2_rx_ndp_ql;
reg  [ 119 : 0] dmi_smi_msg2_rx_ndp_body;
wire            dmi_smi_msg3_tx_ndp_valid;
wire            dmi_smi_msg3_tx_ndp_ready;
wire  [ 7 : 0]  dmi_smi_msg3_tx_ndp_pbits;
wire            dmi_smi_msg3_tx_ndp_dp_present;
wire  [ 5 : 0]  dmi_smi_msg3_tx_ndp_cdwid;
wire  [ 9 : 0]  dmi_smi_msg3_tx_ndp_target_id;
wire  [ 9 : 0]  dmi_smi_msg3_tx_ndp_initiator_id;
wire  [ 9 : 0]  dmi_smi_msg3_tx_ndp_transaction_id;
wire  [ 7 : 0]  dmi_smi_msg3_tx_ndp_cm_type;
wire  [ 7 : 0]  dmi_smi_msg3_tx_ndp_h_prot;
wire  [ 2 : 0]  dmi_smi_msg3_tx_ndp_t_tier;
wire  [ 2 : 0]  dmi_smi_msg3_tx_ndp_steering;
wire  [ 2 : 0]  dmi_smi_msg3_tx_ndp_priority;
wire  [ 2 : 0]  dmi_smi_msg3_tx_ndp_ql;
reg   [ 119 : 0]dmi_smi_msg3_tx_ndp_body;
wire            dmi_smi_msg3_tx_dp_valid;
wire            dmi_smi_msg3_tx_dp_ready;
wire            dmi_smi_msg3_tx_dp_last;
wire  [ 127 : 0]dmi_smi_msg3_tx_dp_data;
wire  [ 27 : 0] dmi_smi_msg3_tx_dp_aux;
wire            dmi_smi_msg3_rx_ndp_valid;
wire            dmi_smi_msg3_rx_ndp_ready;
wire [ 7 : 0]   dmi_smi_msg3_rx_ndp_pbits;
wire            dmi_smi_msg3_rx_ndp_dp_present;
wire [ 5 : 0]   dmi_smi_msg3_rx_ndp_cdwid;
reg  [ 9 : 0]   dmi_smi_msg3_rx_ndp_target_id;
reg  [ 9 : 0]   dmi_smi_msg3_rx_ndp_initiator_id;
wire [ 9 : 0]   dmi_smi_msg3_rx_ndp_transaction_id;
wire [ 7 : 0]   dmi_smi_msg3_rx_ndp_cm_type;
wire [ 7 : 0]   dmi_smi_msg3_rx_ndp_h_prot;
wire [ 2 : 0]   dmi_smi_msg3_rx_ndp_t_tier;
wire [ 2 : 0]   dmi_smi_msg3_rx_ndp_steering;
wire [ 2 : 0]   dmi_smi_msg3_rx_ndp_priority;
wire [ 2 : 0]   dmi_smi_msg3_rx_ndp_ql;
reg  [ 119 : 0] dmi_smi_msg3_rx_ndp_body;
wire            dmi_smi_msg3_rx_dp_valid;
wire            dmi_smi_msg3_rx_dp_ready;
wire            dmi_smi_msg3_rx_dp_last;
wire [ 127 : 0] dmi_smi_msg3_rx_dp_data;
wire [ 27 : 0]  dmi_smi_msg3_rx_dp_aux;

// DII
wire dii_smi_nd_msg0_tx_ndp_valid;
wire dii_smi_nd_msg0_tx_ndp_ready;
wire [ 7 : 0] dii_smi_nd_msg0_tx_ndp_pbits;
wire dii_smi_nd_msg0_tx_ndp_dp_present;
wire[ 9 : 0] dii_smi_nd_msg0_tx_ndp_target_id;
wire[ 9 : 0] dii_smi_nd_msg0_tx_ndp_initiator_id;
wire[ 9 : 0] dii_smi_nd_msg0_tx_ndp_transaction_id;
wire [ 7 : 0] dii_smi_nd_msg0_tx_ndp_cm_type;
wire [ 7 : 0] dii_smi_nd_msg0_tx_ndp_h_prot;
wire [ 2 : 0] dii_smi_nd_msg0_tx_ndp_t_tier;
wire [ 2 : 0] dii_smi_nd_msg0_tx_ndp_steering;
wire [ 2 : 0] dii_smi_nd_msg0_tx_ndp_priority;
wire [ 2 : 0] dii_smi_nd_msg0_tx_ndp_ql;
reg [ 119 : 0] dii_smi_nd_msg0_tx_ndp_body;
wire dii_smi_nd_msg1_tx_ndp_valid;
wire dii_smi_nd_msg1_tx_ndp_ready;
wire [ 7 : 0] dii_smi_nd_msg1_tx_ndp_pbits;
wire dii_smi_nd_msg1_tx_ndp_dp_present;
wire[ 9 : 0] dii_smi_nd_msg1_tx_ndp_target_id;
wire[ 9 : 0] dii_smi_nd_msg1_tx_ndp_initiator_id;
wire[ 9 : 0] dii_smi_nd_msg1_tx_ndp_transaction_id;
wire [ 7 : 0] dii_smi_nd_msg1_tx_ndp_cm_type;
wire [ 7 : 0] dii_smi_nd_msg1_tx_ndp_h_prot;
wire [ 2 : 0] dii_smi_nd_msg1_tx_ndp_t_tier;
wire [ 2 : 0] dii_smi_nd_msg1_tx_ndp_steering;
wire [ 2 : 0] dii_smi_nd_msg1_tx_ndp_priority;
wire [ 2 : 0] dii_smi_nd_msg1_tx_ndp_ql;
reg [ 119 : 0] dii_smi_nd_msg1_tx_ndp_body;
wire dii_smi_nd_msg0_rx_ndp_valid;
wire dii_smi_nd_msg0_rx_ndp_ready;
wire [ 7 : 0] dii_smi_nd_msg0_rx_ndp_pbits;
wire dii_smi_nd_msg0_rx_ndp_dp_present;
reg [ 9 : 0] dii_smi_nd_msg0_rx_ndp_target_id;
reg [ 9 : 0] dii_smi_nd_msg0_rx_ndp_initiator_id;
wire[ 9 : 0] dii_smi_nd_msg0_rx_ndp_transaction_id;
wire [ 7 : 0] dii_smi_nd_msg0_rx_ndp_cm_type;
wire [ 7 : 0] dii_smi_nd_msg0_rx_ndp_h_prot;
wire [ 2 : 0] dii_smi_nd_msg0_rx_ndp_t_tier;
wire [ 2 : 0] dii_smi_nd_msg0_rx_ndp_steering;
wire [ 2 : 0] dii_smi_nd_msg0_rx_ndp_priority;
wire [ 2 : 0] dii_smi_nd_msg0_rx_ndp_ql;
reg [ 119 : 0] dii_smi_nd_msg0_rx_ndp_body;
wire dii_smi_nd_msg1_rx_ndp_valid;
wire dii_smi_nd_msg1_rx_ndp_ready;
wire [ 7 : 0] dii_smi_nd_msg1_rx_ndp_pbits;
wire dii_smi_nd_msg1_rx_ndp_dp_present;
reg [ 9 : 0] dii_smi_nd_msg1_rx_ndp_target_id;
reg [ 9 : 0] dii_smi_nd_msg1_rx_ndp_initiator_id;
wire[ 9 : 0] dii_smi_nd_msg1_rx_ndp_transaction_id;
wire [ 7 : 0] dii_smi_nd_msg1_rx_ndp_cm_type;
wire [ 7 : 0] dii_smi_nd_msg1_rx_ndp_h_prot;
wire [ 2 : 0] dii_smi_nd_msg1_rx_ndp_t_tier;
wire [ 2 : 0] dii_smi_nd_msg1_rx_ndp_steering;
wire [ 2 : 0] dii_smi_nd_msg1_rx_ndp_priority;
wire [ 2 : 0] dii_smi_nd_msg1_rx_ndp_ql;
reg [ 119 : 0] dii_smi_nd_msg1_rx_ndp_body;
wire dii_smi_nd_msg2_tx_ndp_valid;
wire dii_smi_nd_msg2_tx_ndp_ready;
wire [ 7 : 0] dii_smi_nd_msg2_tx_ndp_pbits;
wire dii_smi_nd_msg2_tx_ndp_dp_present;
wire [ 2 : 0] dii_smi_nd_msg2_tx_ndp_cdwid;
wire[ 9 : 0] dii_smi_nd_msg2_tx_ndp_target_id;
wire[ 9 : 0] dii_smi_nd_msg2_tx_ndp_initiator_id;
wire[ 9 : 0] dii_smi_nd_msg2_tx_ndp_transaction_id;
wire [ 7 : 0] dii_smi_nd_msg2_tx_ndp_cm_type;
wire [ 7 : 0] dii_smi_nd_msg2_tx_ndp_h_prot;
wire [ 2 : 0] dii_smi_nd_msg2_tx_ndp_t_tier;
wire [ 2 : 0] dii_smi_nd_msg2_tx_ndp_steering;
wire [ 2 : 0] dii_smi_nd_msg2_tx_ndp_priority;
wire [ 2 : 0] dii_smi_nd_msg2_tx_ndp_ql;
reg [ 119 : 0] dii_smi_nd_msg2_tx_ndp_body;
wire dii_smi_nd_msg2_tx_dp_valid;
wire dii_smi_nd_msg2_tx_dp_ready;
wire dii_smi_nd_msg2_tx_dp_last;
wire [ 127 : 0] dii_smi_nd_msg2_tx_dp_data;
wire [ 23 : 0] dii_smi_nd_msg2_tx_dp_aux;
wire dii_smi_nd_msg2_rx_ndp_valid;
wire dii_smi_nd_msg2_rx_ndp_ready;
wire [ 7 : 0] dii_smi_nd_msg2_rx_ndp_pbits;
wire dii_smi_nd_msg2_rx_ndp_dp_present;
wire [ 2 : 0] dii_smi_nd_msg2_rx_ndp_cdwid;
reg [ 9 : 0] dii_smi_nd_msg2_rx_ndp_target_id;
reg [ 9 : 0] dii_smi_nd_msg2_rx_ndp_initiator_id;
wire[ 9 : 0] dii_smi_nd_msg2_rx_ndp_transaction_id;
wire [ 7 : 0] dii_smi_nd_msg2_rx_ndp_cm_type;
wire [ 7 : 0] dii_smi_nd_msg2_rx_ndp_h_prot;
wire [ 2 : 0] dii_smi_nd_msg2_rx_ndp_t_tier;
wire [ 2 : 0] dii_smi_nd_msg2_rx_ndp_steering;
wire [ 2 : 0] dii_smi_nd_msg2_rx_ndp_priority;
wire [ 2 : 0] dii_smi_nd_msg2_rx_ndp_ql;
reg [ 119 : 0] dii_smi_nd_msg2_rx_ndp_body;
wire dii_smi_nd_msg2_rx_dp_valid;
wire dii_smi_nd_msg2_rx_dp_ready;
wire dii_smi_nd_msg2_rx_dp_last;
wire [ 127 : 0] dii_smi_nd_msg2_rx_dp_data;
wire [ 23 : 0] dii_smi_nd_msg2_rx_dp_aux;

   initial
      begin
       dmi_smi_msg0_rx_ndp_body = 'b0;
       dmi_smi_msg1_rx_ndp_body = 'b0;
       dmi_smi_msg2_rx_ndp_body = 'b0;
       dmi_smi_msg3_rx_ndp_body = 'b0;
       dmi_smi_msg0_rx_ndp_target_id =  'b0;
       dmi_smi_msg0_rx_ndp_initiator_id = 'b0;
       dmi_smi_msg1_rx_ndp_target_id =  'b0;
       dmi_smi_msg1_rx_ndp_initiator_id = 'b0;
       dmi_smi_msg2_rx_ndp_target_id =  'b0;
       dmi_smi_msg2_rx_ndp_initiator_id = 'b0;
       dmi_smi_msg3_rx_ndp_target_id =  'b0;
       dmi_smi_msg3_rx_ndp_initiator_id = 'b0;

       // DII
       dii_smi_nd_msg0_rx_ndp_body = 'b0;
       dii_smi_nd_msg1_rx_ndp_body = 'b0;
       dii_smi_nd_msg2_rx_ndp_body = 'b0;
       dii_smi_nd_msg0_rx_ndp_target_id = 'b0;
       dii_smi_nd_msg0_rx_ndp_initiator_id = 'b0;
       dii_smi_nd_msg1_rx_ndp_target_id = 'b0;
       dii_smi_nd_msg1_rx_ndp_initiator_id = 'b0;
       dii_smi_nd_msg2_rx_ndp_target_id = 'b0;
       dii_smi_nd_msg2_rx_ndp_initiator_id = 'b0;
      end

aiu_top u_chi_0 (
         .clk(clk),
         .reset_n(reset_n),
         .smi_nd_msg0_tx_ndp_valid(chi_smi_nd_msg0_tx_ndp_valid),
         .smi_nd_msg0_tx_ndp_ready(chi_smi_nd_msg0_tx_ndp_ready),
         .smi_nd_msg0_tx_ndp_pbits(chi_smi_nd_msg0_tx_ndp_pbits),
         .smi_nd_msg0_tx_ndp_dp_present(chi_smi_nd_msg0_tx_ndp_dp_present),
         .smi_nd_msg0_tx_ndp_target_id(chi_smi_nd_msg0_tx_ndp_target_id),
         .smi_nd_msg0_tx_ndp_initiator_id(chi_smi_nd_msg0_tx_ndp_initiator_id),
         .smi_nd_msg0_tx_ndp_transaction_id(chi_smi_nd_msg0_tx_ndp_transaction_id),
         .smi_nd_msg0_tx_ndp_cm_type(chi_smi_nd_msg0_tx_ndp_cm_type),
         .smi_nd_msg0_tx_ndp_h_prot(chi_smi_nd_msg0_tx_ndp_h_prot),
         .smi_nd_msg0_tx_ndp_t_tier(chi_smi_nd_msg0_tx_ndp_t_tier),
         .smi_nd_msg0_tx_ndp_steering(chi_smi_nd_msg0_tx_ndp_steering),
         .smi_nd_msg0_tx_ndp_priority(chi_smi_nd_msg0_tx_ndp_priority),
         .smi_nd_msg0_tx_ndp_ql(chi_smi_nd_msg0_tx_ndp_ql),
         .smi_nd_msg0_tx_ndp_body(chi_smi_nd_msg0_tx_ndp_body),
         .smi_nd_msg1_tx_ndp_valid(chi_smi_nd_msg1_tx_ndp_valid),
         .smi_nd_msg1_tx_ndp_ready(chi_smi_nd_msg1_tx_ndp_ready),
         .smi_nd_msg1_tx_ndp_pbits(chi_smi_nd_msg1_tx_ndp_pbits),
         .smi_nd_msg1_tx_ndp_dp_present(chi_smi_nd_msg1_tx_ndp_dp_present),
         .smi_nd_msg1_tx_ndp_target_id(chi_smi_nd_msg1_tx_ndp_target_id),
         .smi_nd_msg1_tx_ndp_initiator_id(chi_smi_nd_msg1_tx_ndp_initiator_id),
         .smi_nd_msg1_tx_ndp_transaction_id(chi_smi_nd_msg1_tx_ndp_transaction_id),
         .smi_nd_msg1_tx_ndp_cm_type(chi_smi_nd_msg1_tx_ndp_cm_type),
         .smi_nd_msg1_tx_ndp_h_prot(chi_smi_nd_msg1_tx_ndp_h_prot),
         .smi_nd_msg1_tx_ndp_t_tier(chi_smi_nd_msg1_tx_ndp_t_tier),
         .smi_nd_msg1_tx_ndp_steering(chi_smi_nd_msg1_tx_ndp_steering),
         .smi_nd_msg1_tx_ndp_priority(chi_smi_nd_msg1_tx_ndp_priority),
         .smi_nd_msg1_tx_ndp_ql(chi_smi_nd_msg1_tx_ndp_ql),
         .smi_nd_msg1_tx_ndp_body(chi_smi_nd_msg1_tx_ndp_body),
         .smi_nd_msg2_tx_ndp_valid(chi_smi_nd_msg2_tx_ndp_valid),
         .smi_nd_msg2_tx_ndp_ready(chi_smi_nd_msg2_tx_ndp_ready),
         .smi_nd_msg2_tx_ndp_pbits(chi_smi_nd_msg2_tx_ndp_pbits),
         .smi_nd_msg2_tx_ndp_dp_present(chi_smi_nd_msg2_tx_ndp_dp_present),
         .smi_nd_msg2_tx_ndp_cdwid(chi_smi_nd_msg2_tx_ndp_cdwid),
         .smi_nd_msg2_tx_ndp_target_id(chi_smi_nd_msg2_tx_ndp_target_id),
         .smi_nd_msg2_tx_ndp_initiator_id(chi_smi_nd_msg2_tx_ndp_initiator_id),
         .smi_nd_msg2_tx_ndp_transaction_id(chi_smi_nd_msg2_tx_ndp_transaction_id),
         .smi_nd_msg2_tx_ndp_cm_type(chi_smi_nd_msg2_tx_ndp_cm_type),
         .smi_nd_msg2_tx_ndp_h_prot(chi_smi_nd_msg2_tx_ndp_h_prot),
         .smi_nd_msg2_tx_ndp_t_tier(chi_smi_nd_msg2_tx_ndp_t_tier),
         .smi_nd_msg2_tx_ndp_steering(chi_smi_nd_msg2_tx_ndp_steering),
         .smi_nd_msg2_tx_ndp_priority(chi_smi_nd_msg2_tx_ndp_priority),
         .smi_nd_msg2_tx_ndp_ql(chi_smi_nd_msg2_tx_ndp_ql),
         .smi_nd_msg2_tx_ndp_body(chi_smi_nd_msg2_tx_ndp_body),
         .smi_nd_msg2_tx_dp_valid(chi_smi_nd_msg2_tx_dp_valid),
         .smi_nd_msg2_tx_dp_ready(chi_smi_nd_msg2_tx_dp_ready),
         .smi_nd_msg2_tx_dp_last(chi_smi_nd_msg2_tx_dp_last),
         .smi_nd_msg2_tx_dp_data(chi_smi_nd_msg2_tx_dp_data),
         .smi_nd_msg2_tx_dp_aux(chi_smi_nd_msg2_tx_dp_aux),
         .smi_nd_msg0_rx_ndp_valid(chi_smi_nd_msg0_rx_ndp_valid),
         .smi_nd_msg0_rx_ndp_ready(chi_smi_nd_msg0_rx_ndp_ready),
         .smi_nd_msg0_rx_ndp_pbits({'b0,chi_smi_nd_msg0_rx_ndp_pbits[6:0]}),
         .smi_nd_msg0_rx_ndp_dp_present(chi_smi_nd_msg0_rx_ndp_dp_present),
         .smi_nd_msg0_rx_ndp_target_id({'b0,chi_smi_nd_msg0_rx_ndp_target_id[3:0]}),
         .smi_nd_msg0_rx_ndp_initiator_id({'b0,chi_smi_nd_msg0_rx_ndp_initiator_id[3:0]}),
         .smi_nd_msg0_rx_ndp_transaction_id({'b0,chi_smi_nd_msg0_rx_ndp_transaction_id[7:0]}),
         .smi_nd_msg0_rx_ndp_cm_type(chi_smi_nd_msg0_rx_ndp_cm_type),
         .smi_nd_msg0_rx_ndp_h_prot   ('b0),
         .smi_nd_msg0_rx_ndp_t_tier   ('b0),
         .smi_nd_msg0_rx_ndp_steering ('b0),
         .smi_nd_msg0_rx_ndp_priority ('b0),
         .smi_nd_msg0_rx_ndp_ql       ('b0),
         .smi_nd_msg0_rx_ndp_body(chi_smi_nd_msg0_rx_ndp_body),
         .smi_nd_msg1_rx_ndp_valid(chi_smi_nd_msg1_rx_ndp_valid),
         .smi_nd_msg1_rx_ndp_ready(chi_smi_nd_msg1_rx_ndp_ready),
         .smi_nd_msg1_rx_ndp_pbits({'b0,chi_smi_nd_msg1_rx_ndp_pbits[6:0]}),
         .smi_nd_msg1_rx_ndp_dp_present(chi_smi_nd_msg1_rx_ndp_dp_present),
         .smi_nd_msg1_rx_ndp_target_id({'b0,chi_smi_nd_msg1_rx_ndp_target_id[2:0]}),
         .smi_nd_msg1_rx_ndp_initiator_id({'b0,chi_smi_nd_msg1_rx_ndp_initiator_id[2:0]}),
         .smi_nd_msg1_rx_ndp_transaction_id({'b0,chi_smi_nd_msg1_rx_ndp_transaction_id[7:0]}),
         .smi_nd_msg1_rx_ndp_cm_type(chi_smi_nd_msg1_rx_ndp_cm_type),
         .smi_nd_msg1_rx_ndp_h_prot   ('b0 ),
         .smi_nd_msg1_rx_ndp_t_tier   ('b0 ),
         .smi_nd_msg1_rx_ndp_steering ('b0 ),
         .smi_nd_msg1_rx_ndp_priority ('b0 ),
         .smi_nd_msg1_rx_ndp_ql       ('b0 ),
         .smi_nd_msg1_rx_ndp_body(chi_smi_nd_msg1_rx_ndp_body),
         .smi_nd_msg2_rx_ndp_valid(chi_smi_nd_msg2_rx_ndp_valid),
         .smi_nd_msg2_rx_ndp_ready(chi_smi_nd_msg2_rx_ndp_ready),
         .smi_nd_msg2_rx_ndp_pbits({'b0,chi_smi_nd_msg2_rx_ndp_pbits[6:0]}),
         .smi_nd_msg2_rx_ndp_dp_present(chi_smi_nd_msg2_rx_ndp_dp_present),
         .smi_nd_msg2_rx_ndp_cdwid(chi_smi_nd_msg2_rx_ndp_cdwid),
         .smi_nd_msg2_rx_ndp_target_id({'b0,chi_smi_nd_msg2_rx_ndp_target_id[2:0]}),
         .smi_nd_msg2_rx_ndp_initiator_id({'b0,chi_smi_nd_msg2_rx_ndp_initiator_id[2:0]}),
         .smi_nd_msg2_rx_ndp_transaction_id({'b0,chi_smi_nd_msg2_rx_ndp_transaction_id[7:0]}),
         .smi_nd_msg2_rx_ndp_cm_type(chi_smi_nd_msg2_rx_ndp_cm_type   ),
         .smi_nd_msg2_rx_ndp_h_prot  ('b0),
         .smi_nd_msg2_rx_ndp_t_tier  ('b0),
         .smi_nd_msg2_rx_ndp_steering('b0),
         .smi_nd_msg2_rx_ndp_priority('b0),
         .smi_nd_msg2_rx_ndp_ql      ('b0),
         .smi_nd_msg2_rx_ndp_body({'b0,chi_smi_nd_msg2_rx_ndp_body[95:0]}),
         .smi_nd_msg2_rx_dp_valid(chi_smi_nd_msg2_rx_dp_valid),
         .smi_nd_msg2_rx_dp_ready(chi_smi_nd_msg2_rx_dp_ready),
         .smi_nd_msg2_rx_dp_last(chi_smi_nd_msg2_rx_dp_last),
         .smi_nd_msg2_rx_dp_data(chi_smi_nd_msg2_rx_dp_data),
         .smi_nd_msg2_rx_dp_aux({'b0,chi_smi_nd_msg2_rx_dp_aux[23:0]}),
         .RXREQFLITPEND(RXREQFLITPEND),
         .RXREQFLITV(RXREQFLITV),
         .RXREQLCRDV(RXREQLCRDV),
         .RXRSPFLITPEND(RXRSPFLITPEND),
         .RXRSPFLITV(RXRSPFLITV),
         .RXRSPLCRDV(RXRSPLCRDV),
         .RXDATFLITPEND(RXDATFLITPEND),
         .RXDATFLITV(RXDATFLITV),
         .RXDATLCRDV(RXDATLCRDV),
         .RXREQFLIT(RXREQFLIT),
         .RXRSPFLIT(RXRSPFLIT),
         .RXDATFLIT(RXDATFLIT),
         .TXSNPFLITPEND(TXSNPFLITPEND),
         .TXSNPFLITV(TXSNPFLITV),
         .TXSNPLCRDV(TXSNPLCRDV),
         .TXRSPFLITPEND(TXRSPFLITPEND),
         .TXRSPFLITV(TXRSPFLITV),
         .TXRSPLCRDV(TXRSPLCRDV),
         .TXDATFLITPEND(TXDATFLITPEND),
         .TXDATFLITV(TXDATFLITV),
         .TXDATLCRDV(TXDATLCRDV),
         .TXSNPFLIT(TXSNPFLIT),
         .TXRSPFLIT(TXRSPFLIT),
         .TXDATFLIT(TXDATFLIT),
         .RXLINKACTIVEREQ(RXLINKACTIVEREQ),
         .RXLINKACTIVEACK(RXLINKACTIVEACK),
         .TXLINKACTIVEREQ(TXLINKACTIVEREQ),
         .TXLINKACTIVEACK(TXLINKACTIVEACK)
         );


ioaiu_top u_ioaiu_0(
         .clk(clk),
         .reset_n(reset_n),
         .MyId(ioaiuMyId),
         .awready(awready),
         .awvalid(awvalid),
         .awid(awid),
         .awaddr(awaddr),
         .awlen(awlen),
         .awsize(awsize),
         .awburst(awburst),
         .awlock(awlock),
         .awcache(awcache),
         .awprot(awprot),
         .awqos(awqos),
         .awuser(awuser),
         //.awdomain(awdomain),
         //.awsnoop(awsnoop),
         //.awbar(awbar),
         .wready(wready),
         .wvalid(wvalid),
         .wdata(wdata),
         .wstrb(wstrb),
         .wlast(wlast),
         .bready(bready),
         .bvalid(bvalid),
         .bid(bid),
         .bresp(bresp),
         .arready(arready),
         .arvalid(arvalid),
         .arid(arid),
         .araddr(araddr),
         .arlen(arlen),
         .arsize(arsize),
         .arburst(arburst),
         .arlock(arlock),
         .arcache(arcache),
         .arprot(arprot),
         .arqos(arqos),
         .aruser(aruser),
         //.ardomain(ardomain),
         //.arsnoop(arsnoop),
         //.arbar(arbar),
         .rready(rready),
         .rvalid(rvalid),
         .rid(rid),
         .rdata(rdata),
         .rresp(rresp),
         .rlast(rlast),
         .ruser(ruser),
         .smi_tx0_ndp_msg_valid(io_smi_nd_msg0_tx_ndp_valid),
         .smi_tx0_ndp_msg_ready(io_smi_nd_msg0_tx_ndp_ready),
         .smi_tx0_ndp_ndp_len(io_smi_nd_msg0_tx_ndp_pbits),
         .smi_tx0_ndp_dp_present(io_smi_nd_msg0_tx_ndp_dp_present),
         .smi_tx0_ndp_targ_id(io_smi_nd_msg0_tx_ndp_target_id),
         //.smi_tx0_ndp_initiator_id(io_smi_nd_msg0_tx_ndp_initiator_id),
         .smi_tx0_ndp_msg_id(io_smi_nd_msg0_tx_ndp_message_id),
         .smi_tx0_ndp_msg_type(io_smi_nd_msg0_tx_ndp_cm_type),
         .smi_tx0_ndp_msg_user(io_smi_nd_msg0_tx_ndp_h_prot),
         .smi_tx0_ndp_msg_tier(io_smi_nd_msg0_tx_ndp_t_tier),
         .smi_tx0_ndp_steer(io_smi_nd_msg0_tx_ndp_steering),
         .smi_tx0_ndp_msg_pri(io_smi_nd_msg0_tx_ndp_priority),
         .smi_tx0_ndp_msg_qos(io_smi_nd_msg0_tx_ndp_ql),
         .smi_tx0_ndp_ndp(io_smi_nd_msg0_tx_ndp_body),
         .smi_tx1_ndp_msg_valid(io_smi_nd_msg1_tx_ndp_valid),
         .smi_tx1_ndp_msg_ready(io_smi_nd_msg1_tx_ndp_ready),
         .smi_tx1_ndp_ndp_len(io_smi_nd_msg1_tx_ndp_pbits),
         .smi_tx1_ndp_dp_present(io_smi_nd_msg1_tx_ndp_dp_present),
         .smi_tx1_ndp_targ_id(io_smi_nd_msg1_tx_ndp_target_id),
         //.smi_tx1_ndp_initiator_id(io_smi_nd_msg1_tx_ndp_initiator_id),
         .smi_tx1_ndp_msg_id(io_smi_nd_msg1_tx_ndp_message_id),
         .smi_tx1_ndp_msg_type(io_smi_nd_msg1_tx_ndp_cm_type),
         .smi_tx1_ndp_msg_user(io_smi_nd_msg1_tx_ndp_h_prot),
         .smi_tx1_ndp_msg_tier(io_smi_nd_msg1_tx_ndp_t_tier),
         .smi_tx1_ndp_steer(io_smi_nd_msg1_tx_ndp_steering),
         .smi_tx1_ndp_msg_pri(io_smi_nd_msg1_tx_ndp_priority),
         .smi_tx1_ndp_msg_qos(io_smi_nd_msg1_tx_ndp_ql),
         .smi_tx1_ndp_ndp(io_smi_nd_msg1_tx_ndp_body),
         .smi_tx2_ndp_msg_valid(io_smi_nd_msg2_tx_ndp_valid),
         .smi_tx2_ndp_msg_ready(io_smi_nd_msg2_tx_ndp_ready),
         .smi_tx2_ndp_ndp_len(io_smi_nd_msg2_tx_ndp_pbits),
         .smi_tx2_ndp_dp_present(io_smi_nd_msg2_tx_ndp_dp_present),
         .smi_tx2_ndp_src_id(io_smi_nd_msg2_tx_ndp_cdwid),
         .smi_tx2_ndp_targ_id(io_smi_nd_msg2_tx_ndp_target_id),
         //.smi_tx2_ndp_initiator_id(io_smi_nd_msg2_tx_ndp_initiator_id),
         .smi_tx2_ndp_msg_id(io_smi_nd_msg2_tx_ndp_message_id),
         .smi_tx2_ndp_msg_type(io_smi_nd_msg2_tx_ndp_cm_type),
         .smi_tx2_ndp_msg_user(io_smi_nd_msg2_tx_ndp_h_prot),
         .smi_tx2_ndp_msg_tier(io_smi_nd_msg2_tx_ndp_t_tier),
         .smi_tx2_ndp_steer(io_smi_nd_msg2_tx_ndp_steering),
         .smi_tx2_ndp_msg_pri(io_smi_nd_msg2_tx_ndp_priority),
         .smi_tx2_ndp_msg_qos(io_smi_nd_msg2_tx_ndp_ql),
         .smi_tx2_ndp_ndp(io_smi_nd_msg2_tx_ndp_body),
         .smi_tx2_dp_valid(io_smi_nd_msg2_tx_dp_valid),
         .smi_tx2_dp_ready(io_smi_nd_msg2_tx_dp_ready),
         .smi_tx2_dp_last(io_smi_nd_msg2_tx_dp_last),
         .smi_tx2_dp_data(io_smi_nd_msg2_tx_dp_data),
         .smi_tx2_dp_user(io_smi_nd_msg2_tx_dp_aux),
         .smi_rx0_ndp_msg_valid(io_smi_nd_msg0_rx_ndp_valid),
         .smi_rx0_ndp_msg_ready(io_smi_nd_msg0_rx_ndp_ready),
         .smi_rx0_ndp_ndp_len(io_smi_nd_msg0_rx_ndp_pbits),
         .smi_rx0_ndp_dp_present(io_smi_nd_msg0_rx_ndp_dp_present),
         .smi_rx0_ndp_targ_id(io_smi_nd_msg0_rx_ndp_target_id),
         //.smi_rx0_ndp_initiator_id(io_smi_nd_msg0_rx_ndp_initiator_id),
         .smi_rx0_ndp_msg_id(io_smi_nd_msg0_rx_ndp_message_id),
         .smi_rx0_ndp_msg_type(io_smi_nd_msg0_rx_ndp_cm_type),
         .smi_rx0_ndp_msg_user(io_smi_nd_msg0_rx_ndp_h_prot),
         .smi_rx0_ndp_msg_tier(io_smi_nd_msg0_rx_ndp_t_tier),
         .smi_rx0_ndp_steer(io_smi_nd_msg0_rx_ndp_steering),
         .smi_rx0_ndp_msg_pri(io_smi_nd_msg0_rx_ndp_priority),
         .smi_rx0_ndp_msg_qos(io_smi_nd_msg0_rx_ndp_ql),
         .smi_rx0_ndp_ndp(io_smi_nd_msg0_rx_ndp_body),
         .smi_rx1_ndp_msg_valid(io_smi_nd_msg1_rx_ndp_valid),
         .smi_rx1_ndp_msg_ready(io_smi_nd_msg1_rx_ndp_ready),
         .smi_rx1_ndp_ndp_len(io_smi_nd_msg1_rx_ndp_pbits),
         .smi_rx1_ndp_dp_present(io_smi_nd_msg1_rx_ndp_dp_present),
         .smi_rx1_ndp_targ_id(io_smi_nd_msg1_rx_ndp_target_id),
         //.smi_rx1_ndp_initiator_id(io_smi_nd_msg1_rx_ndp_initiator_id),
         .smi_rx1_ndp_msg_id(io_smi_nd_msg1_rx_ndp_message_id),
         .smi_rx1_ndp_msg_type(io_smi_nd_msg1_rx_ndp_cm_type),
         .smi_rx1_ndp_msg_user(io_smi_nd_msg1_rx_ndp_h_prot),
         .smi_rx1_ndp_msg_tier(io_smi_nd_msg1_rx_ndp_t_tier),
         .smi_rx1_ndp_steer(io_smi_nd_msg1_rx_ndp_steering),
         .smi_rx1_ndp_msg_pri(io_smi_nd_msg1_rx_ndp_priority),
         .smi_rx1_ndp_msg_qos(io_smi_nd_msg1_rx_ndp_ql),
         .smi_rx1_ndp_ndp(io_smi_nd_msg1_rx_ndp_body),
         .smi_rx2_ndp_msg_valid(io_smi_nd_msg2_rx_ndp_valid),
         .smi_rx2_ndp_msg_ready(io_smi_nd_msg2_rx_ndp_ready),
         .smi_rx2_ndp_ndp_len(io_smi_nd_msg2_rx_ndp_pbits),
         .smi_rx2_ndp_dp_present(io_smi_nd_msg2_rx_ndp_dp_present),
         .smi_rx2_ndp_src_id(io_smi_nd_msg2_rx_ndp_cdwid),
         .smi_rx2_ndp_targ_id(io_smi_nd_msg2_rx_ndp_target_id),
         .smi_rx2_ndp_msg_id(io_smi_nd_msg2_rx_ndp_message_id),
         .smi_rx2_ndp_msg_type(io_smi_nd_msg2_rx_ndp_cm_type),
         .smi_rx2_ndp_msg_user(io_smi_nd_msg2_rx_ndp_h_prot),
         .smi_rx2_ndp_msg_tier(io_smi_nd_msg2_rx_ndp_t_tier),
         .smi_rx2_ndp_steer(io_smi_nd_msg2_rx_ndp_steering),
         .smi_rx2_ndp_msg_pri(io_smi_nd_msg2_rx_ndp_priority),
         .smi_rx2_ndp_msg_qos(io_smi_nd_msg2_rx_ndp_ql),
         .smi_rx2_ndp_ndp(io_smi_nd_msg2_rx_ndp_body),
         .smi_rx2_dp_valid(io_smi_nd_msg2_rx_dp_valid),
         .smi_rx2_dp_ready(io_smi_nd_msg2_rx_dp_ready),
         .smi_rx2_dp_last(io_smi_nd_msg2_rx_dp_last),
         .smi_rx2_dp_data(io_smi_nd_msg2_rx_dp_data),
         .smi_rx2_dp_user(io_smi_nd_msg2_rx_dp_aux)
         //.smi_rx2_ndp_initiator_id(io_smi_nd_msg2_rx_ndp_initiator_id)
);

dmi u_dmi_0 (
     .axi_mst_awprot         (dmi_axi_mst_awprot          ) ,
     .axi_mst_arprot         (dmi_axi_mst_arprot          ) ,
                                             
     .axi_mst_awready        (dmi_axi_mst_awread          ) ,
     .axi_mst_awvalid        (dmi_axi_mst_awvalid         ) ,
     .axi_mst_awid           (dmi_axi_mst_awid            ) ,
     .axi_mst_awaddr         (dmi_axi_mst_awaddr          ) ,
     .axi_mst_awburst        (dmi_axi_mst_awburst         ) ,
     .axi_mst_awlen          (dmi_axi_mst_awlen           ) ,
     .axi_mst_awlock         (dmi_axi_mst_awlock          ) ,
     .axi_mst_awsize         (dmi_axi_mst_awsize          ) ,
     .axi_mst_wready         (dmi_axi_mst_wready          ) ,
     .axi_mst_wvalid         (dmi_axi_mst_wvalid          ) ,
     .axi_mst_wdata          (dmi_axi_mst_wdata           ) ,
     .axi_mst_wlast          (dmi_axi_mst_wlast           ) ,
     .axi_mst_wstrb          (dmi_axi_mst_wstrb           ) ,
     .axi_mst_bready         (dmi_axi_mst_bready          ) ,
     .axi_mst_bvalid         (dmi_axi_mst_bvalid          ) ,
     .axi_mst_bid            (dmi_axi_mst_bid             ) ,
     .axi_mst_bresp          (dmi_axi_mst_bresp           ) ,
     .axi_mst_arready        (dmi_axi_mst_arready         ) ,
     .axi_mst_arvalid        (dmi_axi_mst_arvalid         ) ,
     .axi_mst_araddr         (dmi_axi_mst_araddr          ) ,
     .axi_mst_arburst        (dmi_axi_mst_arburst          ) ,
     .axi_mst_arid           (dmi_axi_mst_arid            ) ,
     .axi_mst_arlen          (dmi_axi_mst_arlen           ) ,
     .axi_mst_arlock         (dmi_axi_mst_arlock          ) ,
     .axi_mst_arsize         (dmi_axi_mst_arsize          ) ,
     .axi_mst_rid            (dmi_axi_mst_rid             ) ,
     .axi_mst_rresp          (dmi_axi_mst_rresp           ) ,
     .axi_mst_rready         (dmi_axi_mst_rready          ) ,
     .axi_mst_rvalid         (dmi_axi_mst_rvalid          ) ,
     .axi_mst_rdata          (dmi_axi_mst_rdata           ) ,
     .axi_mst_rlast          (dmi_axi_mst_rlast           ) ,
     .smi_tx0_ndp_msg_valid  (dmi_smi_msg0_tx_ndp_valid         ) ,
     .smi_tx0_ndp_msg_ready  (dmi_smi_msg0_tx_ndp_ready          ) ,
     .smi_tx0_ndp_ndp_len    (dmi_smi_msg0_tx_ndp_pbits         ) ,
     .smi_tx0_ndp_dp_present (dmi_smi_msg0_tx_ndp_dp_present    ) ,
     .smi_tx0_ndp_targ_id    (dmi_smi_msg0_tx_ndp_target_id     ) ,
     .smi_tx0_ndp_src_id     (dmi_smi_msg0_tx_ndp_initiator_id  ) ,
     .smi_tx0_ndp_msg_id     (dmi_smi_msg0_tx_ndp_transaction_id) ,
     .smi_tx0_ndp_msg_type   (dmi_smi_msg0_tx_ndp_cm_type       ) ,
     .smi_tx0_ndp_msg_user   (dmi_smi_msg0_tx_ndp_h_prot        ) ,
     .smi_tx0_ndp_msg_tier   (dmi_smi_msg0_tx_ndp_t_tier        ) ,
     .smi_tx0_ndp_steer      (dmi_smi_msg0_tx_ndp_steering      ) ,
     .smi_tx0_ndp_msg_pri    (dmi_smi_msg0_tx_ndp_priority      ) ,
     .smi_tx0_ndp_msg_qos    (dmi_smi_msg0_tx_ndp_ql            ) ,
     .smi_tx0_ndp_ndp        (dmi_smi_msg0_tx_ndp_body          ) ,
     .smi_tx1_ndp_msg_valid  (dmi_smi_msg1_tx_ndp_valid         ) ,
     .smi_tx1_ndp_msg_ready  (dmi_smi_msg1_tx_ndp_ready          ) ,
     .smi_tx1_ndp_ndp_len    (dmi_smi_msg1_tx_ndp_pbits         ) ,
     .smi_tx1_ndp_dp_present (dmi_smi_msg1_tx_ndp_dp_present    ) ,
     .smi_tx1_ndp_targ_id    (dmi_smi_msg1_tx_ndp_target_id     ) ,
     .smi_tx1_ndp_src_id     (dmi_smi_msg1_tx_ndp_initiator_id  ) ,
     .smi_tx1_ndp_msg_id     (dmi_smi_msg1_tx_ndp_transaction_id) ,
     .smi_tx1_ndp_msg_type   (dmi_smi_msg1_tx_ndp_cm_type       ) ,
     .smi_tx1_ndp_msg_user   (dmi_smi_msg1_tx_ndp_h_prot        ) ,
     .smi_tx1_ndp_msg_tier   (dmi_smi_msg1_tx_ndp_t_tier        ) ,
     .smi_tx1_ndp_steer      (dmi_smi_msg1_tx_ndp_steering      ) ,
     .smi_tx1_ndp_msg_pri    (dmi_smi_msg1_tx_ndp_priority      ) ,
     .smi_tx1_ndp_msg_qos    (dmi_smi_msg1_tx_ndp_ql            ) ,
     .smi_tx1_ndp_ndp        (dmi_smi_msg1_tx_ndp_body          ) ,
     .smi_tx2_ndp_msg_valid  (dmi_smi_msg2_tx_ndp_valid         ) ,
     .smi_tx2_ndp_msg_ready  (dmi_smi_msg2_tx_ndp_ready          ) ,
     .smi_tx2_ndp_ndp_len    (dmi_smi_msg2_tx_ndp_pbits         ) ,
     .smi_tx2_ndp_dp_present (dmi_smi_msg2_tx_ndp_dp_present    ) ,
     .smi_tx2_ndp_targ_id    (dmi_smi_msg2_tx_ndp_target_id     ) ,
     .smi_tx2_ndp_src_id     (dmi_smi_msg2_tx_ndp_initiator_id  ) ,
     .smi_tx2_ndp_msg_id     (dmi_smi_msg2_tx_ndp_transaction_id) ,
     .smi_tx2_ndp_msg_type   (dmi_smi_msg2_tx_ndp_cm_type       ) ,
     .smi_tx2_ndp_msg_user   (dmi_smi_msg2_tx_ndp_h_prot        ) ,
     .smi_tx2_ndp_msg_tier   (dmi_smi_msg2_tx_ndp_t_tier        ) ,
     .smi_tx2_ndp_steer      (dmi_smi_msg2_tx_ndp_steering      ) ,
     .smi_tx2_ndp_msg_pri    (dmi_smi_msg2_tx_ndp_priority      ) ,
     .smi_tx2_ndp_msg_qos    (dmi_smi_msg2_tx_ndp_ql            ) ,
     .smi_tx2_ndp_ndp        (dmi_smi_msg2_tx_ndp_body          ) ,
     .smi_rx0_ndp_msg_valid  (dmi_smi_msg0_rx_ndp_valid         ) ,
     .smi_rx0_ndp_msg_ready  (dmi_smi_msg0_rx_ndp_ready         ) ,
     .smi_rx0_ndp_ndp_len    ({'b0,dmi_smi_msg0_rx_ndp_pbits[6:0]}) ,
     .smi_rx0_ndp_dp_present (dmi_smi_msg0_rx_ndp_dp_present    ) ,
     .smi_rx0_ndp_targ_id    ({'b0,dmi_smi_msg0_rx_ndp_target_id[3:0]}) ,
     .smi_rx0_ndp_src_id     ({'b0,dmi_smi_msg0_rx_ndp_initiator_id[3:0]}) ,
     .smi_rx0_ndp_msg_id     ({'b0,dmi_smi_msg0_rx_ndp_transaction_id[7:0]}) ,
     .smi_rx0_ndp_msg_type   (dmi_smi_msg0_rx_ndp_cm_type       ) ,
     .smi_rx0_ndp_msg_user   ('b0        ) ,
     .smi_rx0_ndp_msg_tier   ('b0      ) ,
     .smi_rx0_ndp_steer      ('b0      ) ,
     .smi_rx0_ndp_msg_pri    ('b0      ) ,
     .smi_rx0_ndp_msg_qos    ('b0       ) ,
     .smi_rx0_ndp_ndp        (dmi_smi_msg0_rx_ndp_body          ) ,
     .smi_rx1_ndp_msg_valid  (dmi_smi_msg1_rx_ndp_valid         ) ,
     .smi_rx1_ndp_msg_ready  (dmi_smi_msg1_rx_ndp_ready         ) ,
     .smi_rx1_ndp_ndp_len    ({'b0,dmi_smi_msg1_rx_ndp_pbits[6:0]}) ,
     .smi_rx1_ndp_dp_present (dmi_smi_msg1_rx_ndp_dp_present    ) ,
     .smi_rx1_ndp_targ_id    ({'b0,dmi_smi_msg1_rx_ndp_target_id[2:0]}     ) ,
     .smi_rx1_ndp_src_id     ({'b0,dmi_smi_msg1_rx_ndp_initiator_id[2:0]}  ) ,
     .smi_rx1_ndp_msg_id     ({'b0,dmi_smi_msg1_rx_ndp_transaction_id[7:0]}) ,
     .smi_rx1_ndp_msg_type   (dmi_smi_msg1_rx_ndp_cm_type       ) ,
     .smi_rx1_ndp_msg_user   ('b0     ) ,
     .smi_rx1_ndp_msg_tier   ('b0     ) ,
     .smi_rx1_ndp_steer      ('b0     ) ,
     .smi_rx1_ndp_msg_pri    ('b0     ) ,
     .smi_rx1_ndp_msg_qos    ('b0     ) ,
     .smi_rx1_ndp_ndp        (dmi_smi_msg1_rx_ndp_body          ) ,
     .smi_rx2_ndp_msg_valid  (dmi_smi_msg2_rx_ndp_valid         ) ,
     .smi_rx2_ndp_msg_ready  (dmi_smi_msg2_rx_ndp_ready         ) ,
     .smi_rx2_ndp_ndp_len    ({'b0,dmi_smi_msg2_rx_ndp_pbits[6:0]}   ) ,
     .smi_rx2_ndp_dp_present (dmi_smi_msg2_rx_ndp_dp_present    ) ,
     .smi_rx2_ndp_targ_id    ({'b0,dmi_smi_msg2_rx_ndp_target_id[3:0]}     ) ,
     .smi_rx2_ndp_src_id     ({'b0,dmi_smi_msg2_rx_ndp_initiator_id[3:0]}  ) ,
     .smi_rx2_ndp_msg_id     ({'b0,dmi_smi_msg2_rx_ndp_transaction_id[7:0]}) ,
     .smi_rx2_ndp_msg_type   (dmi_smi_msg2_rx_ndp_cm_type       ) ,
     .smi_rx2_ndp_msg_user   ('b0     ) ,
     .smi_rx2_ndp_msg_tier   ('b0     ) ,
     .smi_rx2_ndp_steer      ('b0     ) ,
     .smi_rx2_ndp_msg_pri    ('b0     ) ,
     .smi_rx2_ndp_msg_qos    ('b0     ) ,
     .smi_rx2_ndp_ndp        (dmi_smi_msg2_rx_ndp_body          ) ,
     .smi_tx3_ndp_msg_valid  (dmi_smi_msg3_tx_ndp_valid         ) ,
     .smi_tx3_ndp_msg_ready  (dmi_smi_msg3_tx_ndp_ready         ) ,
     .smi_tx3_ndp_ndp_len    (dmi_smi_msg3_tx_ndp_pbits         ) ,
     .smi_tx3_ndp_dp_present (dmi_smi_msg3_tx_ndp_dp_present    ) ,
     .smi_tx3_ndp_targ_id    (dmi_smi_msg3_tx_ndp_target_id     ) ,
     .smi_tx3_ndp_src_id     (dmi_smi_msg3_tx_ndp_initiator_id  ) ,
     .smi_tx3_ndp_msg_id     (dmi_smi_msg3_tx_ndp_transaction_id) ,
     .smi_tx3_ndp_msg_type   (dmi_smi_msg3_tx_ndp_cm_type       ) ,
     .smi_tx3_ndp_msg_user   (dmi_smi_msg3_tx_ndp_h_prot        ) ,
     .smi_tx3_ndp_msg_tier   (dmi_smi_msg3_tx_ndp_t_tier        ) ,
     .smi_tx3_ndp_steer      (dmi_smi_msg3_tx_ndp_steering      ) ,
     .smi_tx3_ndp_msg_pri    (dmi_smi_msg3_tx_ndp_priority      ) ,
     .smi_tx3_ndp_msg_qos    (dmi_smi_msg3_tx_ndp_ql            ) ,
     .smi_tx3_ndp_ndp        (dmi_smi_msg3_tx_ndp_body          ) ,
     .smi_tx3_dp_valid       (dmi_smi_msg3_tx_dp_valid          ) ,
     .smi_tx3_dp_ready       (dmi_smi_msg3_tx_dp_ready          ) ,
     .smi_tx3_dp_last        (dmi_smi_msg3_tx_dp_last           ) ,
     .smi_tx3_dp_data        (dmi_smi_msg3_tx_dp_data           ) ,
     .smi_tx3_dp_user        (dmi_smi_msg3_tx_dp_aux            ) ,
     .smi_rx3_ndp_msg_valid  (dmi_smi_msg3_rx_ndp_valid         ) ,
     .smi_rx3_ndp_msg_ready  (dmi_smi_msg3_rx_ndp_ready         ) ,
     .smi_rx3_ndp_ndp_len    ({'b0,dmi_smi_msg3_rx_ndp_pbits[6:0]}         ) ,
     .smi_rx3_ndp_dp_present (dmi_smi_msg3_rx_ndp_dp_present) ,
     .smi_rx3_ndp_targ_id    ({'b0,dmi_smi_msg3_rx_ndp_target_id[2:0]}     ) ,
     .smi_rx3_ndp_src_id     ({'b0,dmi_smi_msg3_rx_ndp_initiator_id[2:0]}  ) ,
     .smi_rx3_ndp_msg_id     ({'b0,dmi_smi_msg3_rx_ndp_transaction_id[7:0]}) ,
     .smi_rx3_ndp_msg_type   (dmi_smi_msg3_rx_ndp_cm_type       ) ,
     .smi_rx3_ndp_msg_user   ('b0      ) ,
     .smi_rx3_ndp_msg_tier   ('b0      ) ,
     .smi_rx3_ndp_steer      ('b0      ) ,
     .smi_rx3_ndp_msg_pri    ('b0      ) ,
     .smi_rx3_ndp_msg_qos    ('b0      ) ,
     .smi_rx3_ndp_ndp        (dmi_smi_msg3_rx_ndp_body          ) ,
     .smi_rx3_dp_valid       (dmi_smi_msg3_rx_dp_valid          ) ,
     .smi_rx3_dp_ready       (dmi_smi_msg3_rx_dp_ready          ) ,
     .smi_rx3_dp_last        (dmi_smi_msg3_rx_dp_last           ) ,
     .smi_rx3_dp_data        (dmi_smi_msg3_rx_dp_data           ) ,
     .smi_rx3_dp_user        (dmi_smi_msg3_rx_dp_aux            ) ,
     .      MyId                   ( dmiMyId    ) , 
     .clk(clk),
     .reset_n(reset_n)
);    

//dii_top_dii u_dii_0();
dii_top u_dii_0(
    .clk(clk),
    .reset_n(reset_n),
    .MyId(diiMyId),
    .smi_nd_msg0_tx_ndp_valid(dii_smi_nd_msg0_tx_ndp_valid),
    .smi_nd_msg0_tx_ndp_ready(dii_smi_nd_msg0_tx_ndp_ready),
    .smi_nd_msg0_tx_ndp_pbits(dii_smi_nd_msg0_tx_ndp_pbits),
    .smi_nd_msg0_tx_ndp_dp_present(dii_smi_nd_msg0_tx_ndp_dp_present),
    .smi_nd_msg0_tx_ndp_target_id(dii_smi_nd_msg0_tx_ndp_target_id),
    .smi_nd_msg0_tx_ndp_initiator_id(dii_smi_nd_msg0_tx_ndp_initiator_id),
    .smi_nd_msg0_tx_ndp_transaction_id(dii_smi_nd_msg0_tx_ndp_transaction_id),
    .smi_nd_msg0_tx_ndp_cm_type(dii_smi_nd_msg0_tx_ndp_cm_type),
    .smi_nd_msg0_tx_ndp_h_prot(dii_smi_nd_msg0_tx_ndp_h_prot),
    .smi_nd_msg0_tx_ndp_t_tier(dii_smi_nd_msg0_tx_ndp_t_tier),
    .smi_nd_msg0_tx_ndp_steering(dii_smi_nd_msg0_tx_ndp_steering),
    .smi_nd_msg0_tx_ndp_priority(dii_smi_nd_msg0_tx_ndp_priority),
    .smi_nd_msg0_tx_ndp_ql(dii_smi_nd_msg0_tx_ndp_ql),
    .smi_nd_msg0_tx_ndp_body(dii_smi_nd_msg0_tx_ndp_body),
    .smi_nd_msg1_tx_ndp_valid(dii_smi_nd_msg1_tx_ndp_valid),
    .smi_nd_msg1_tx_ndp_ready(dii_smi_nd_msg1_tx_ndp_ready),
    .smi_nd_msg1_tx_ndp_pbits(dii_smi_nd_msg1_tx_ndp_pbits),
    .smi_nd_msg1_tx_ndp_dp_present(dii_smi_nd_msg1_tx_ndp_dp_present),
    .smi_nd_msg1_tx_ndp_target_id(dii_smi_nd_msg1_tx_ndp_target_id),
    .smi_nd_msg1_tx_ndp_initiator_id(dii_smi_nd_msg1_tx_ndp_initiator_id),
    .smi_nd_msg1_tx_ndp_transaction_id(dii_smi_nd_msg1_tx_ndp_transaction_id),
    .smi_nd_msg1_tx_ndp_cm_type(dii_smi_nd_msg1_tx_ndp_cm_type),
    .smi_nd_msg1_tx_ndp_h_prot(dii_smi_nd_msg1_tx_ndp_h_prot),
    .smi_nd_msg1_tx_ndp_t_tier(dii_smi_nd_msg1_tx_ndp_t_tier),
    .smi_nd_msg1_tx_ndp_steering(dii_smi_nd_msg1_tx_ndp_steering),
    .smi_nd_msg1_tx_ndp_priority(dii_smi_nd_msg1_tx_ndp_priority),
    .smi_nd_msg1_tx_ndp_ql(dii_smi_nd_msg1_tx_ndp_ql),
    .smi_nd_msg1_tx_ndp_body(dii_smi_nd_msg1_tx_ndp_body),
    .smi_nd_msg0_rx_ndp_valid(dii_smi_nd_msg0_rx_ndp_valid),
    .smi_nd_msg0_rx_ndp_ready(dii_smi_nd_msg0_rx_ndp_ready),
    .smi_nd_msg0_rx_ndp_pbits(dii_smi_nd_msg0_rx_ndp_pbits),
    .smi_nd_msg0_rx_ndp_dp_present(dii_smi_nd_msg0_rx_ndp_dp_present),
    .smi_nd_msg0_rx_ndp_target_id(dii_smi_nd_msg0_rx_ndp_target_id),
    .smi_nd_msg0_rx_ndp_initiator_id(dii_smi_nd_msg0_rx_ndp_initiator_id),
    .smi_nd_msg0_rx_ndp_transaction_id(dii_smi_nd_msg0_rx_ndp_transaction_id),
    .smi_nd_msg0_rx_ndp_cm_type(dii_smi_nd_msg0_rx_ndp_cm_type),
    .smi_nd_msg0_rx_ndp_h_prot(dii_smi_nd_msg0_rx_ndp_h_prot),
    .smi_nd_msg0_rx_ndp_t_tier(dii_smi_nd_msg0_rx_ndp_t_tier),
    .smi_nd_msg0_rx_ndp_steering(dii_smi_nd_msg0_rx_ndp_steering),
    .smi_nd_msg0_rx_ndp_priority(dii_smi_nd_msg0_rx_ndp_priority),
    .smi_nd_msg0_rx_ndp_ql(dii_smi_nd_msg0_rx_ndp_ql),
    .smi_nd_msg0_rx_ndp_body(dii_smi_nd_msg0_rx_ndp_body),
    .smi_nd_msg1_rx_ndp_valid(dii_smi_nd_msg1_rx_ndp_valid),
    .smi_nd_msg1_rx_ndp_ready(dii_smi_nd_msg1_rx_ndp_ready),
    .smi_nd_msg1_rx_ndp_pbits(dii_smi_nd_msg1_rx_ndp_pbits),
    .smi_nd_msg1_rx_ndp_dp_present(dii_smi_nd_msg1_rx_ndp_dp_present),
    .smi_nd_msg1_rx_ndp_target_id(dii_smi_nd_msg1_rx_ndp_target_id),
    .smi_nd_msg1_rx_ndp_initiator_id(dii_smi_nd_msg1_rx_ndp_initiator_id),
    .smi_nd_msg1_rx_ndp_transaction_id(dii_smi_nd_msg1_rx_ndp_transaction_id),
    .smi_nd_msg1_rx_ndp_cm_type(dii_smi_nd_msg1_rx_ndp_cm_type),
    .smi_nd_msg1_rx_ndp_h_prot(dii_smi_nd_msg1_rx_ndp_h_prot),
    .smi_nd_msg1_rx_ndp_t_tier(dii_smi_nd_msg1_rx_ndp_t_tier),
    .smi_nd_msg1_rx_ndp_steering(dii_smi_nd_msg1_rx_ndp_steering),
    .smi_nd_msg1_rx_ndp_priority(dii_smi_nd_msg1_rx_ndp_priority),
    .smi_nd_msg1_rx_ndp_ql(dii_smi_nd_msg1_rx_ndp_ql),
    .smi_nd_msg1_rx_ndp_body(dii_smi_nd_msg1_rx_ndp_body),
    .smi_nd_msg2_tx_ndp_valid(dii_smi_nd_msg2_tx_ndp_valid),
    .smi_nd_msg2_tx_ndp_ready(dii_smi_nd_msg2_tx_ndp_ready),
    .smi_nd_msg2_tx_ndp_pbits(dii_smi_nd_msg2_tx_ndp_pbits),
    .smi_nd_msg2_tx_ndp_dp_present(dii_smi_nd_msg2_tx_ndp_dp_present),
    .smi_nd_msg2_tx_ndp_cdwid(dii_smi_nd_msg2_tx_ndp_cdwid),
    .smi_nd_msg2_tx_ndp_target_id(dii_smi_nd_msg2_tx_ndp_target_id),
    .smi_nd_msg2_tx_ndp_initiator_id(dii_smi_nd_msg2_tx_ndp_initiator_id),
    .smi_nd_msg2_tx_ndp_transaction_id(dii_smi_nd_msg2_tx_ndp_transaction_id),
    .smi_nd_msg2_tx_ndp_cm_type(dii_smi_nd_msg2_tx_ndp_cm_type),
    .smi_nd_msg2_tx_ndp_h_prot(dii_smi_nd_msg2_tx_ndp_h_prot),
    .smi_nd_msg2_tx_ndp_t_tier(dii_smi_nd_msg2_tx_ndp_t_tier),
    .smi_nd_msg2_tx_ndp_steering(dii_smi_nd_msg2_tx_ndp_steering),
    .smi_nd_msg2_tx_ndp_priority(dii_smi_nd_msg2_tx_ndp_priority),
    .smi_nd_msg2_tx_ndp_ql(dii_smi_nd_msg2_tx_ndp_ql),
    .smi_nd_msg2_tx_ndp_body(dii_smi_nd_msg2_tx_ndp_body),
    .smi_nd_msg2_tx_dp_valid(dii_smi_nd_msg2_tx_dp_valid),
    .smi_nd_msg2_tx_dp_ready(dii_smi_nd_msg2_tx_dp_ready),
    .smi_nd_msg2_tx_dp_last(dii_smi_nd_msg2_tx_dp_last),
    .smi_nd_msg2_tx_dp_data(dii_smi_nd_msg2_tx_dp_data),
    .smi_nd_msg2_tx_dp_aux(dii_smi_nd_msg2_tx_dp_aux),
    .smi_nd_msg2_rx_ndp_valid(dii_smi_nd_msg2_rx_ndp_valid),
    .smi_nd_msg2_rx_ndp_ready(dii_smi_nd_msg2_rx_ndp_ready),
    .smi_nd_msg2_rx_ndp_pbits(dii_smi_nd_msg2_rx_ndp_pbits),
    .smi_nd_msg2_rx_ndp_dp_present(dii_smi_nd_msg2_rx_ndp_dp_present),
    .smi_nd_msg2_rx_ndp_cdwid(dii_smi_nd_msg2_rx_ndp_cdwid),
    .smi_nd_msg2_rx_ndp_target_id(dii_smi_nd_msg2_rx_ndp_target_id),
    .smi_nd_msg2_rx_ndp_initiator_id(dii_smi_nd_msg2_rx_ndp_initiator_id),
    .smi_nd_msg2_rx_ndp_transaction_id(dii_smi_nd_msg2_rx_ndp_transaction_id),
    .smi_nd_msg2_rx_ndp_cm_type(dii_smi_nd_msg2_rx_ndp_cm_type),
    .smi_nd_msg2_rx_ndp_h_prot(dii_smi_nd_msg2_rx_ndp_h_prot),
    .smi_nd_msg2_rx_ndp_t_tier(dii_smi_nd_msg2_rx_ndp_t_tier),
    .smi_nd_msg2_rx_ndp_steering(dii_smi_nd_msg2_rx_ndp_steering),
    .smi_nd_msg2_rx_ndp_priority(dii_smi_nd_msg2_rx_ndp_priority),
    .smi_nd_msg2_rx_ndp_ql(dii_smi_nd_msg2_rx_ndp_ql),
    .smi_nd_msg2_rx_ndp_body(dii_smi_nd_msg2_rx_ndp_body),
    .smi_nd_msg2_rx_dp_valid(dii_smi_nd_msg2_rx_dp_valid),
    .smi_nd_msg2_rx_dp_ready(dii_smi_nd_msg2_rx_dp_ready),
    .smi_nd_msg2_rx_dp_last(dii_smi_nd_msg2_rx_dp_last),
    .smi_nd_msg2_rx_dp_data(dii_smi_nd_msg2_rx_dp_data),
    .smi_nd_msg2_rx_dp_aux(dii_smi_nd_msg2_rx_dp_aux),
    .axi_mst_awvalid(dii_axi_mst_awvalid),
    .axi_mst_awready(dii_axi_mst_awready),
    .axi_mst_awaddr(dii_axi_mst_awaddr),
    .axi_mst_awburst(dii_axi_mst_awburst),
    .axi_mst_awlen(dii_axi_mst_awlen),
    .axi_mst_awlock(dii_axi_mst_awlock),
    .axi_mst_awprot(dii_axi_mst_awprot),
    .axi_mst_awqos(dii_axi_mst_awqos),
    .axi_mst_awsize(dii_axi_mst_awsize),
    .axi_mst_awuser(dii_axi_mst_awuser),
    .axi_mst_awid(dii_axi_mst_awid),
    .axi_mst_wvalid(dii_axi_mst_wvalid),
    .axi_mst_wready(dii_axi_mst_wready),
    .axi_mst_wlast(dii_axi_mst_wlast),
    .axi_mst_wdata(dii_axi_mst_wdata),
    .axi_mst_wuser(dii_axi_mst_wuser),
    .axi_mst_wstrb(dii_axi_mst_wstrb),
    .axi_mst_wid(dii_axi_mst_wid),
    .axi_mst_bvalid(dii_axi_mst_bvalid),
    .axi_mst_bready(dii_axi_mst_bready),
    .axi_mst_bresp(dii_axi_mst_bresp),
    .axi_mst_buser(dii_axi_mst_buser),
    .axi_mst_bid(dii_axi_mst_bid),
    .axi_mst_arvalid(dii_axi_mst_arvalid),
    .axi_mst_arready(dii_axi_mst_arready),
    .axi_mst_araddr(dii_axi_mst_araddr),
    .axi_mst_arburst(dii_axi_mst_arburst),
    .axi_mst_arlen(dii_axi_mst_arlen),
    .axi_mst_arlock(dii_axi_mst_arlock),
    .axi_mst_arprot(dii_axi_mst_arprot),
    .axi_mst_arqos(dii_axi_mst_arqos),
    .axi_mst_arsize(dii_axi_mst_arsize),
    .axi_mst_aruser(dii_axi_mst_aruser),
    .axi_mst_arid(dii_axi_mst_arid),
    .axi_mst_rvalid(dii_axi_mst_rvalid),
    .axi_mst_rready(dii_axi_mst_rready),
    .axi_mst_rlast(dii_axi_mst_rlast),
    .axi_mst_rresp(dii_axi_mst_rresp),
    .axi_mst_rdata(dii_axi_mst_rdata),
    .axi_mst_ruser(dii_axi_mst_ruser),
    .axi_mst_rid(dii_axi_mst_rid)
);

top_wrapper legato (
 .a_clk(clk),
 .a_reset_n(reset_n),
 .ismi0_valid(chi_smi_nd_msg0_tx_ndp_valid),
 .ismi0_ready(chi_smi_nd_msg0_tx_ndp_ready),
 .ismi0_targ_id(chi_smi_nd_msg0_tx_ndp_target_id),
 .ismi0_src_id(chi_smi_nd_msg0_tx_ndp_initiator_id),
 .ismi0_tier(chi_smi_nd_msg0_tx_ndp_t_tier),
 .ismi0_dp_present(chi_smi_nd_msg0_tx_ndp_dp_present),
 .ismi0_ndp_len(chi_smi_nd_msg0_tx_ndp_pbits),
 .ismi0_ndp({'b0,chi_smi_nd_msg0_tx_ndp_body}),
 .ismi0_msg_type(chi_smi_nd_msg0_tx_ndp_cm_type),
 .ismi0_msg_id(chi_smi_nd_msg0_tx_ndp_transaction_id),
 .ismi0_deassert_ready('b0),
 .ismi7_valid(chi_smi_nd_msg1_tx_ndp_valid),
 .ismi7_ready(chi_smi_nd_msg1_tx_ndp_ready),
 .ismi7_targ_id('b11),
 .ismi7_src_id(chi_smi_nd_msg1_tx_ndp_initiator_id),
 .ismi7_tier(chi_smi_nd_msg1_tx_ndp_t_tier),
 .ismi7_dp_present(chi_smi_nd_msg1_tx_ndp_dp_present),
 .ismi7_ndp_len(chi_smi_nd_msg1_tx_ndp_pbits),
 .ismi7_ndp({'b0,chi_smi_nd_msg1_tx_ndp_body}),
 .ismi7_msg_type(chi_smi_nd_msg1_tx_ndp_cm_type),
 .ismi7_msg_id(chi_smi_nd_msg1_tx_ndp_transaction_id),
 .ismi7_deassert_ready('b0),
 .ismi12_valid(chi_smi_nd_msg2_tx_ndp_valid),
 .ismi12_ready(chi_smi_nd_msg2_tx_ndp_ready),
 .ismi12_targ_id(chi_smi_nd_msg2_tx_ndp_target_id),
 .ismi12_src_id(chi_smi_nd_msg2_tx_ndp_initiator_id),
 .ismi12_tier(chi_smi_nd_msg2_tx_ndp_t_tier),
 .ismi12_dp_present(chi_smi_nd_msg2_tx_ndp_dp_present),
 .ismi12_ndp_len(chi_smi_nd_msg2_tx_ndp_h_prot),
 .ismi12_ndp({'b0,chi_smi_nd_msg2_tx_ndp_body}),
 .ismi12_msg_type(chi_smi_nd_msg2_tx_ndp_cm_type),
 .ismi12_msg_id(chi_smi_nd_msg2_tx_ndp_transaction_id),
 .ismi12_deassert_ready('b0),
 .ismi12_dp_valid(chi_smi_nd_msg2_tx_dp_valid),
 .ismi12_dp_ready(chi_smi_nd_msg2_tx_dp_ready),
 .ismi12_dp_last(chi_smi_nd_msg2_tx_dp_last),
 .ismi12_dp_data(chi_smi_nd_msg2_tx_dp_data),
 .ismi12_dp_user(chi_smi_nd_msg2_tx_dp_aux),
 .ismi1_valid(io_smi_nd_msg0_tx_ndp_valid),
 .ismi1_ready(io_smi_nd_msg0_tx_ndp_ready),
 .ismi1_targ_id(io_smi_nd_msg0_tx_ndp_target_id),
 .ismi1_src_id(io_smi_nd_msg0_tx_ndp_initiator_id),
 .ismi1_tier(io_smi_nd_msg0_tx_ndp_t_tier),
 .ismi1_dp_present(io_smi_nd_msg0_tx_ndp_dp_present),
 .ismi1_ndp_len(io_smi_nd_msg0_tx_ndp_pbits),
 .ismi1_ndp({'b0,io_smi_nd_msg0_tx_ndp_body}),
 .ismi1_msg_type(io_smi_nd_msg0_tx_ndp_cm_type),
 .ismi1_msg_id(io_smi_nd_msg0_tx_ndp_message_id),
 .ismi1_deassert_ready('b0),
 .ismi8_valid(io_smi_nd_msg1_tx_ndp_valid),
 .ismi8_ready(io_smi_nd_msg1_tx_ndp_ready),
 .ismi8_targ_id(io_smi_nd_msg1_tx_ndp_target_id),
 .ismi8_src_id(io_smi_nd_msg1_tx_ndp_initiator_id),
 .ismi8_tier(io_smi_nd_msg1_tx_ndp_t_tier),
 .ismi8_dp_present(io_smi_nd_msg1_tx_ndp_dp_present),
 .ismi8_ndp_len(io_smi_nd_msg1_tx_ndp_pbits),
 .ismi8_ndp({'b0,io_smi_nd_msg1_tx_ndp_body}),
 .ismi8_msg_type(io_smi_nd_msg1_tx_ndp_cm_type),
 .ismi8_msg_id(io_smi_nd_msg1_tx_ndp_message_id),
 .ismi8_deassert_ready('b0),
 .ismi13_valid(io_smi_nd_msg2_tx_ndp_valid),
 .ismi13_ready(io_smi_nd_msg2_tx_ndp_ready),
 .ismi13_targ_id(io_smi_nd_msg2_tx_ndp_target_id),
 .ismi13_src_id(io_smi_nd_msg2_tx_ndp_initiator_id),
 .ismi13_tier(io_smi_nd_msg2_tx_ndp_t_tier),
 .ismi13_dp_present(io_smi_nd_msg2_tx_ndp_dp_present),
 .ismi13_ndp_len(io_smi_nd_msg2_tx_ndp_h_prot),
 .ismi13_ndp({'b0,io_smi_nd_msg2_tx_ndp_body}),
 .ismi13_msg_type(io_smi_nd_msg2_tx_ndp_cm_type),
 .ismi13_msg_id(io_smi_nd_msg2_tx_ndp_message_id),
 .ismi13_deassert_ready('b0),
 .ismi13_dp_valid(io_smi_nd_msg2_tx_dp_valid),
 .ismi13_dp_ready(io_smi_nd_msg2_tx_dp_ready),
 .ismi13_dp_last(io_smi_nd_msg2_tx_dp_last),
 .ismi13_dp_data(io_smi_nd_msg2_tx_dp_data),
 .ismi13_dp_user(io_smi_nd_msg2_tx_dp_aux),
 .ismi4_valid(dmi_smi_msg0_tx_ndp_valid),
 .ismi4_ready(dmi_smi_msg0_tx_ndp_ready),
 .ismi4_targ_id(dmi_smi_msg0_tx_ndp_target_id),
 .ismi4_src_id(dmi_smi_msg0_tx_ndp_initiator_id[9:2]),
 .ismi4_tier(dmi_smi_msg0_tx_ndp_t_tier),
 .ismi4_dp_present(dmi_smi_msg0_tx_ndp_dp_present),
 .ismi4_ndp_len(dmi_smi_msg0_tx_ndp_pbits),
 .ismi4_ndp({'b0,dmi_smi_msg0_tx_ndp_body}),
 .ismi4_msg_type(dmi_smi_msg0_tx_ndp_cm_type),
 .ismi4_msg_id(dmi_smi_msg0_tx_ndp_transaction_id),
 .ismi4_deassert_ready('b0),
 .ismi10_valid(dmi_smi_msg1_tx_ndp_valid),
 .ismi10_ready(dmi_smi_msg1_tx_ndp_ready),
 .ismi10_targ_id(dmi_smi_msg1_tx_ndp_target_id),
 .ismi10_src_id(dmi_smi_msg1_tx_ndp_initiator_id[9:2]),
 .ismi10_tier(dmi_smi_msg1_tx_ndp_t_tier),
 .ismi10_dp_present(dmi_smi_msg1_tx_ndp_dp_present),
 .ismi10_ndp_len(dmi_smi_msg1_tx_ndp_pbits),
 .ismi10_ndp({'b0,dmi_smi_msg1_tx_ndp_body}),
 .ismi10_msg_type(dmi_smi_msg1_tx_ndp_cm_type),
 .ismi10_msg_id(dmi_smi_msg1_tx_ndp_transaction_id),
 .ismi10_deassert_ready('b0),
 .ismi5_valid(dmi_smi_msg2_tx_ndp_valid),
 .ismi5_ready(dmi_smi_msg2_tx_ndp_ready),
 .ismi5_targ_id(dmi_smi_msg2_tx_ndp_target_id),
 .ismi5_src_id(dmi_smi_msg2_tx_ndp_initiator_id[9:3]),
 .ismi5_tier(dmi_smi_msg2_tx_ndp_t_tier),
 .ismi5_dp_present(dmi_smi_msg2_tx_ndp_dp_present),
 .ismi5_ndp_len(dmi_smi_msg2_tx_ndp_pbits),
 .ismi5_ndp({'b0,dmi_smi_msg2_tx_ndp_body}),
 .ismi5_msg_type(dmi_smi_msg2_tx_ndp_cm_type),
 .ismi5_msg_id(dmi_smi_msg2_tx_ndp_transaction_id),
 .ismi5_deassert_ready('b0),
 .ismi14_valid(dmi_smi_msg3_tx_ndp_valid),
 .ismi14_ready(dmi_smi_msg3_tx_ndp_ready),
 .ismi14_targ_id(dmi_smi_msg3_tx_ndp_target_id),
 .ismi14_src_id(dmi_smi_msg3_tx_ndp_initiator_id[9:3]),
 .ismi14_tier(dmi_smi_msg3_tx_ndp_t_tier),
 .ismi14_dp_present(dmi_smi_msg3_tx_ndp_dp_present),
 .ismi14_ndp_len(dmi_smi_msg3_tx_ndp_h_prot),
 .ismi14_ndp({'b0,dmi_smi_msg3_tx_ndp_body}),
 .ismi14_msg_type(dmi_smi_msg3_tx_ndp_cm_type),
 .ismi14_msg_id(dmi_smi_msg3_tx_ndp_transaction_id),
 .ismi14_deassert_ready('b0),
 .ismi14_dp_valid(dmi_smi_msg3_tx_dp_valid),
 .ismi14_dp_ready(dmi_smi_msg3_tx_dp_ready),
 .ismi14_dp_last(dmi_smi_msg3_tx_dp_last),
 .ismi14_dp_data(dmi_smi_msg3_tx_dp_data),
 .ismi14_dp_user(dmi_smi_msg3_tx_dp_aux),
 .ismi6_valid(dii_smi_nd_msg0_tx_ndp_valid),
 .ismi6_ready(dii_smi_nd_msg0_tx_ndp_ready),
 .ismi6_targ_id(dii_smi_nd_msg0_tx_ndp_target_id),
 .ismi6_src_id(dii_smi_nd_msg0_tx_ndp_initiator_id[9:2]),
 .ismi6_tier(dii_smi_nd_msg0_tx_ndp_t_tier),
 .ismi6_dp_present(dii_smi_nd_msg0_tx_ndp_dp_present),
 .ismi6_ndp_len(dii_smi_nd_msg0_tx_ndp_pbits),
 .ismi6_ndp({'b0,dii_smi_nd_msg0_tx_ndp_body}),
 .ismi6_msg_type(dii_smi_nd_msg0_tx_ndp_cm_type),
 .ismi6_msg_id(dii_smi_nd_msg0_tx_ndp_transaction_id),
 .ismi6_deassert_ready('b0),
 .ismi11_valid(dii_smi_nd_msg1_tx_ndp_valid),
 .ismi11_ready(dii_smi_nd_msg1_tx_ndp_ready),
 .ismi11_targ_id(dii_smi_nd_msg1_tx_ndp_target_id),
 .ismi11_src_id(dii_smi_nd_msg1_tx_ndp_initiator_id[9:2]),
 .ismi11_tier(dii_smi_nd_msg1_tx_ndp_t_tier),
 .ismi11_dp_present(dii_smi_nd_msg1_tx_ndp_dp_present),
 .ismi11_ndp_len(dii_smi_nd_msg1_tx_ndp_pbits),
 .ismi11_ndp({'b0,dii_smi_nd_msg1_tx_ndp_body}),
 .ismi11_msg_type(dii_smi_nd_msg1_tx_ndp_cm_type),
 .ismi11_msg_id(dii_smi_nd_msg1_tx_ndp_transaction_id),
 .ismi11_deassert_ready('b0),
 .ismi15_valid(dii_smi_nd_msg2_tx_ndp_valid),
 .ismi15_ready(dii_smi_nd_msg2_tx_ndp_ready),
 .ismi15_targ_id(dii_smi_nd_msg2_tx_ndp_target_id),
 .ismi15_src_id(dii_smi_nd_msg2_tx_ndp_initiator_id[9:3]),
 .ismi15_tier(dii_smi_nd_msg2_tx_ndp_t_tier),
 .ismi15_dp_present(dii_smi_nd_msg2_tx_ndp_dp_present),
 .ismi15_ndp_len(dii_smi_nd_msg2_tx_ndp_h_prot),
 .ismi15_ndp({'b0,dii_smi_nd_msg2_tx_ndp_body}),
 .ismi15_msg_type(dii_smi_nd_msg2_tx_ndp_cm_type),
 .ismi15_msg_id(dii_smi_nd_msg2_tx_ndp_transaction_id),
 .ismi15_deassert_ready('b0),
 .ismi15_dp_valid(dii_smi_nd_msg2_tx_dp_valid),
 .ismi15_dp_ready(dii_smi_nd_msg2_tx_dp_ready),
 .ismi15_dp_last(dii_smi_nd_msg2_tx_dp_last),
 .ismi15_dp_data(dii_smi_nd_msg2_tx_dp_data),
 .ismi15_dp_user(dii_smi_nd_msg2_tx_dp_aux),
 .ismi2_valid('b0),
 .ismi3_valid('b0),
 .ismi9_valid('b0),
 .osmi0_valid(chi_smi_nd_msg0_rx_ndp_valid),
 .osmi0_ready(chi_smi_nd_msg0_rx_ndp_ready),
 .osmi0_targ_id(chi_smi_nd_msg0_rx_ndp_target_id),
 .osmi0_src_id(chi_smi_nd_msg0_rx_ndp_initiator_id),
 .osmi0_tier(chi_smi_nd_msg0_rx_ndp_t_tier),
 .osmi0_dp_present(chi_smi_nd_msg0_rx_ndp_dp_present),
 .osmi0_ndp_len(chi_smi_nd_msg0_rx_ndp_pbits),
 .osmi0_ndp(chi_smi_nd_msg0_rx_ndp_body),
 .osmi0_msg_type(chi_smi_nd_msg0_rx_ndp_cm_type),
 .osmi0_msg_id(chi_smi_nd_msg0_rx_ndp_transaction_id),
 .osmi7_valid(chi_smi_nd_msg1_rx_ndp_valid),
 .osmi7_ready(chi_smi_nd_msg1_rx_ndp_ready),
 .osmi7_targ_id(chi_smi_nd_msg1_rx_ndp_target_id),
 .osmi7_src_id(chi_smi_nd_msg1_rx_ndp_initiator_id),
 .osmi7_tier(chi_smi_nd_msg1_rx_ndp_t_tier),
 .osmi7_dp_present(chi_smi_nd_msg1_rx_ndp_dp_present),
 .osmi7_ndp_len(chi_smi_nd_msg1_rx_ndp_pbits),
 .osmi7_ndp(chi_smi_nd_msg1_rx_ndp_body),
 .osmi7_msg_type(chi_smi_nd_msg1_rx_ndp_cm_type),
 .osmi7_msg_id(chi_smi_nd_msg1_rx_ndp_transaction_id),
 .osmi12_valid(chi_smi_nd_msg2_rx_ndp_valid),
 .osmi12_ready(chi_smi_nd_msg2_rx_ndp_ready),
 .osmi12_targ_id(chi_smi_nd_msg2_rx_ndp_target_id),
 .osmi12_src_id(chi_smi_nd_msg2_rx_ndp_initiator_id),
 .osmi12_tier(chi_smi_nd_msg2_rx_ndp_t_tier),
 .osmi12_dp_present(chi_smi_nd_msg2_rx_ndp_dp_present),
 .osmi12_ndp_len(chi_smi_nd_msg2_rx_ndp_pbits),
 .osmi12_ndp(chi_smi_nd_msg2_rx_ndp_body),
 .osmi12_msg_type(chi_smi_nd_msg2_rx_ndp_cm_type),
 .osmi12_msg_id(chi_smi_nd_msg2_rx_ndp_transaction_id),
 .osmi12_dp_valid(chi_smi_nd_msg2_rx_dp_valid),
 .osmi12_dp_ready(chi_smi_nd_msg2_rx_dp_ready),
 .osmi12_dp_last(chi_smi_nd_msg2_rx_dp_last),
 .osmi12_dp_data(chi_smi_nd_msg2_rx_dp_data),
 .osmi12_dp_user(chi_smi_nd_msg2_rx_dp_aux),
 .osmi1_valid(io_smi_nd_msg0_rx_ndp_valid),
 .osmi1_ready(io_smi_nd_msg0_rx_ndp_ready),
 .osmi1_targ_id(io_smi_nd_msg0_rx_ndp_target_id),
 .osmi1_src_id(io_smi_nd_msg0_rx_ndp_initiator_id),
 .osmi1_tier(io_smi_nd_msg0_rx_ndp_t_tier),
 .osmi1_dp_present(io_smi_nd_msg0_rx_ndp_dp_present),
 .osmi1_ndp_len(io_smi_nd_msg0_rx_ndp_pbits),
 .osmi1_ndp(io_smi_nd_msg0_rx_ndp_body),
 .osmi1_msg_type(io_smi_nd_msg0_rx_ndp_cm_type),
 .osmi1_msg_id(io_smi_nd_msg0_rx_ndp_message_id),
 .osmi8_valid(io_smi_nd_msg1_rx_ndp_valid),
 .osmi8_ready(io_smi_nd_msg1_rx_ndp_ready),
 .osmi8_targ_id(io_smi_nd_msg1_rx_ndp_target_id),
 .osmi8_src_id(io_smi_nd_msg1_rx_ndp_initiator_id),
 .osmi8_tier(io_smi_nd_msg1_rx_ndp_t_tier),
 .osmi8_dp_present(io_smi_nd_msg1_rx_ndp_dp_present),
 .osmi8_ndp_len(io_smi_nd_msg1_rx_ndp_pbits),
 .osmi8_ndp(io_smi_nd_msg1_rx_ndp_body),
 .osmi8_msg_type(io_smi_nd_msg1_rx_ndp_cm_type),
 .osmi8_msg_id(io_smi_nd_msg1_rx_ndp_message_id),
 .osmi13_valid(io_smi_nd_msg2_rx_ndp_valid),
 .osmi13_ready(io_smi_nd_msg2_rx_ndp_ready),
 .osmi13_targ_id(io_smi_nd_msg2_rx_ndp_target_id),
 .osmi13_src_id(io_smi_nd_msg2_rx_ndp_initiator_id),
 .osmi13_tier(io_smi_nd_msg2_rx_ndp_t_tier),
 .osmi13_dp_present(io_smi_nd_msg2_rx_ndp_dp_present),
 .osmi13_ndp_len(io_smi_nd_msg2_rx_ndp_pbits),
 .osmi13_ndp(io_smi_nd_msg2_rx_ndp_body),
 .osmi13_msg_type(io_smi_nd_msg2_rx_ndp_cm_type),
 .osmi13_msg_id(io_smi_nd_msg2_rx_ndp_message_id),
 .osmi13_dp_valid(io_smi_nd_msg2_rx_dp_valid),
 .osmi13_dp_ready(io_smi_nd_msg2_rx_dp_ready),
 .osmi13_dp_last(io_smi_nd_msg2_rx_dp_last),
 .osmi13_dp_data(io_smi_nd_msg2_rx_dp_data),
 .osmi13_dp_user(io_smi_nd_msg2_rx_dp_aux),
 .osmi4_valid(dmi_smi_msg0_rx_ndp_valid),
 .osmi4_ready(dmi_smi_msg0_rx_ndp_ready),
 .osmi4_targ_id(dmi_smi_msg0_rx_ndp_target_id),
 .osmi4_src_id(dmi_smi_msg0_rx_ndp_initiator_id),
 .osmi4_tier(dmi_smi_msg0_rx_ndp_t_tier),
 .osmi4_dp_present(dmi_smi_msg0_rx_ndp_dp_present),
 .osmi4_ndp_len(dmi_smi_msg0_rx_ndp_pbits),
 .osmi4_ndp(dmi_smi_msg0_rx_ndp_body),
 .osmi4_msg_type(dmi_smi_msg0_rx_ndp_cm_type),
 .osmi4_msg_id(dmi_smi_msg0_rx_ndp_transaction_id),
 .osmi10_valid(dmi_smi_msg1_rx_ndp_valid),
 .osmi10_ready(dmi_smi_msg1_rx_ndp_ready),
 .osmi10_targ_id(dmi_smi_msg1_rx_ndp_target_id),
 .osmi10_src_id(dmi_smi_msg1_rx_ndp_initiator_id),
 .osmi10_tier(dmi_smi_msg1_rx_ndp_t_tier),
 .osmi10_dp_present(dmi_smi_msg1_rx_ndp_dp_present),
 .osmi10_ndp_len(dmi_smi_msg1_rx_ndp_pbits),
 .osmi10_ndp(dmi_smi_msg1_rx_ndp_body),
 .osmi10_msg_type(dmi_smi_msg1_rx_ndp_cm_type),
 .osmi10_msg_id(dmi_smi_msg1_rx_ndp_transaction_id),
 .osmi5_valid(dmi_smi_msg2_rx_ndp_valid),
 .osmi5_ready(dmi_smi_msg2_rx_ndp_ready),
 .osmi5_targ_id(dmi_smi_msg2_rx_ndp_target_id),
 .osmi5_src_id(dmi_smi_msg2_rx_ndp_initiator_id),
 .osmi5_tier(dmi_smi_msg2_rx_ndp_t_tier),
 .osmi5_dp_present(dmi_smi_msg2_rx_ndp_dp_present),
 .osmi5_ndp_len(dmi_smi_msg2_rx_ndp_pbits),
 .osmi5_ndp(dmi_smi_msg2_rx_ndp_body),
 .osmi5_msg_type(dmi_smi_msg2_rx_ndp_cm_type),
 .osmi5_msg_id(dmi_smi_msg2_rx_ndp_transaction_id),
 .osmi14_valid(dmi_smi_msg3_rx_ndp_valid),
 .osmi14_ready(dmi_smi_msg3_rx_ndp_ready),
 .osmi14_targ_id(dmi_smi_msg3_rx_ndp_target_id),
 .osmi14_src_id(dmi_smi_msg3_rx_ndp_initiator_id),
 .osmi14_tier(dmi_smi_msg3_rx_ndp_t_tier),
 .osmi14_dp_present(dmi_smi_msg3_rx_ndp_dp_present),
 .osmi14_ndp_len(dmi_smi_msg3_rx_ndp_pbits),
 .osmi14_ndp(dmi_smi_msg3_rx_ndp_body),
 .osmi14_msg_type(dmi_smi_msg3_rx_ndp_cm_type),
 .osmi14_msg_id(dmi_smi_msg3_rx_ndp_transaction_id),
 .osmi14_dp_valid(dmi_smi_msg3_rx_dp_valid),
 .osmi14_dp_ready(dmi_smi_msg3_rx_dp_ready),
 .osmi14_dp_last(dmi_smi_msg3_rx_dp_last),
 .osmi14_dp_data(dmi_smi_msg3_rx_dp_data),
 .osmi14_dp_user(dmi_smi_msg3_rx_dp_aux),
 .osmi6_valid(dii_smi_nd_msg0_rx_ndp_valid),
 .osmi6_ready(dii_smi_nd_msg0_rx_ndp_ready),
 .osmi6_targ_id(dii_smi_nd_msg0_rx_ndp_target_id),
 .osmi6_src_id(dii_smi_nd_msg0_rx_ndp_initiator_id),
 .osmi6_tier(dii_smi_nd_msg0_rx_ndp_t_tier),
 .osmi6_dp_present(dii_smi_nd_msg0_rx_ndp_dp_present),
 .osmi6_ndp_len(dii_smi_nd_msg0_rx_ndp_pbits),
 .osmi6_ndp(dii_smi_nd_msg0_rx_ndp_body),
 .osmi6_msg_type(dii_smi_nd_msg0_rx_ndp_cm_type),
 .osmi6_msg_id(dii_smi_nd_msg0_rx_ndp_transaction_id),
 .osmi11_valid(dii_smi_nd_msg1_rx_ndp_valid),
 .osmi11_ready(dii_smi_nd_msg1_rx_ndp_ready),
 .osmi11_targ_id(dii_smi_nd_msg1_rx_ndp_target_id),
 .osmi11_src_id(dii_smi_nd_msg1_rx_ndp_initiator_id),
 .osmi11_tier(dii_smi_nd_msg1_rx_ndp_t_tier),
 .osmi11_dp_present(dii_smi_nd_msg1_rx_ndp_dp_present),
 .osmi11_ndp_len(dii_smi_nd_msg1_rx_ndp_pbits),
 .osmi11_ndp(dii_smi_nd_msg1_rx_ndp_body),
 .osmi11_msg_type(dii_smi_nd_msg1_rx_ndp_cm_type),
 .osmi11_msg_id(dii_smi_nd_msg1_rx_ndp_transaction_id),
 .osmi15_valid(dii_smi_nd_msg2_rx_ndp_valid),
 .osmi15_ready(dii_smi_nd_msg2_rx_ndp_ready),
 .osmi15_targ_id(dii_smi_nd_msg2_rx_ndp_target_id),
 .osmi15_src_id(dii_smi_nd_msg2_rx_ndp_initiator_id),
 .osmi15_tier(dii_smi_nd_msg2_rx_ndp_t_tier),
 .osmi15_dp_present(dii_smi_nd_msg2_rx_ndp_dp_present),
 .osmi15_ndp_len(dii_smi_nd_msg2_rx_ndp_pbits),
 .osmi15_ndp(dii_smi_nd_msg2_rx_ndp_body),
 .osmi15_msg_type(dii_smi_nd_msg2_rx_ndp_cm_type),
 .osmi15_msg_id(dii_smi_nd_msg2_rx_ndp_transaction_id),
 .osmi15_dp_valid(dii_smi_nd_msg2_rx_dp_valid),
 .osmi15_dp_ready(dii_smi_nd_msg2_rx_dp_ready),
 .osmi15_dp_last(dii_smi_nd_msg2_rx_dp_last),
 .osmi15_dp_data(dii_smi_nd_msg2_rx_dp_data),
 .osmi15_dp_user(dii_smi_nd_msg2_rx_dp_aux),
 .osmi2_ready('b0),
 .osmi3_ready('b0),
 .osmi6_ready('b0),
 .osmi9_ready('b0),
 .osmi15_ready('b1),
 .osmi15_dp_ready('b1)
);

endmodule
