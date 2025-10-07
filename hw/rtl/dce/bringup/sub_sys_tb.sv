////////////////////////////////////////////////////////////////////////////////
//
// Concerto Subsystem top-level testbench
//
////////////////////////////////////////////////////////////////////////////////
module sub_sys_tb;

  `timescale 1ns / 1ps

  import uvm_pkg::*;

  logic CLK;
  logic CLKn;
  logic RESETn;

  //----------------------------------------------------------------------------
  // Interfaces
  //----------------------------------------------------------------------------
  sfi_ace_if   aiu_sfi_ace_master_if [CON::SYS_nSysAIUs] (CLK, RESETn); // ACE channels: AC out, CR in, CD in
                                                                        // AXI Channels: AR in, R out, AW in, W in, B out

  sfi_axi_if   aiu_sfi_axi_slave_if [CON::SYS_nSysAIUs]  (CLK, RESETn); // AXI Channels: AR out, R in, AW out, W out, B in

  //----------------------------------------------------------------------------
  // DUT
  //----------------------------------------------------------------------------
  sub_sys dut (

    .aiu_sfi_ace_slave_if  ( aiu_sfi_ace_master_if  ),

    .aiu_sfi_axi_master_if ( aiu_sfi_axi_slave_if   ),

    .clk                   ( CLK                    ),
    .rst_n                 ( RESETn                 )
  );

  assign CLKn = ~CLK;

  //----------------------------------------------------------------------------
  // Virtual interface wrapping and run_test()
  //----------------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual sfi_if)::set(.cntxt( null ), 
                                        .inst_name( "uvm_test_top" ),
                                        .field_name( "dce_sfi_master_vif" ),
                                        .value( dut.sfi_slave_if[CON::SYS_nSysAIUs]  ));  // DCE sfi_master_if
    uvm_config_db#(virtual sfi_if)::set(.cntxt( null ), 
                                        .inst_name( "uvm_test_top" ),
                                        .field_name( "dce_sfi_slave_vif" ),
                                        .value( dut.sfi_master_if[CON::SYS_nSysAIUs]  )); // DCE sfi_slave_if
   run_test();
   $finish;
  end

  //----------------------------------------------------------------------------
  // Test
  //----------------------------------------------------------------------------
  initial begin
    CON::sfi_req_packet_t      req_pkt;
    CON::ace_read_addr_struct  ar_pkt;
    CON::MsgType_t             msg_type;
    CON::eMsgACErd             ace_rd_msg;

    $vcdpluson;

    fork
      aiu_sfi_axi_slave_if[0].async_reset_slave_channels();
      aiu_sfi_axi_slave_if[1].async_reset_slave_channels();
      aiu_sfi_axi_slave_if[2].async_reset_slave_channels();
      aiu_sfi_axi_slave_if[3].async_reset_slave_channels();
      aiu_sfi_ace_master_if[0].async_reset_master_channels();
      aiu_sfi_ace_master_if[1].async_reset_master_channels();
      aiu_sfi_ace_master_if[2].async_reset_master_channels();
      aiu_sfi_ace_master_if[3].async_reset_master_channels();
    join

    @(posedge RESETn);
    #1us

    req_pkt.req_addr = 32'h12345678;
    req_pkt.req_transId = 1;
    req_pkt.req_sfiPriv[CON::SFI_PRIV_MSG_TYPE_MSB:CON::SFI_PRIV_MSG_TYPE_LSB] = CON::CMD_RD_CPY;

    ar_pkt.arid     = req_pkt.req_transId;
    ar_pkt.araddr   = req_pkt.req_addr;
    ar_pkt.arregion = '0;
    ar_pkt.arlen    = '0;     // 1 transfer //TODO: BURST support
    ar_pkt.arsize   = 3'b011; // 8-byte per transfer //TODO: replace this with a parameter
    ar_pkt.arburst  = 2'b01;  // INCR //TODO: replace this with a parameter
    //ar_pkt.arlock   = CON::axi_axlock_enum_t(2'b0);
    //ar_pkt.arcache  = CON::axi_arcache_enum_t(4'b0);
    ar_pkt.arlock   = '0;
    ar_pkt.arcache  = '0;
    ar_pkt.arprot   = '0;
    ar_pkt.arqos    = '0;

    msg_type = req_pkt.req_sfiPriv[CON::SFI_PRIV_MSG_TYPE_MSB:CON::SFI_PRIV_MSG_TYPE_LSB];
    void'(CON::mapCMDreqToAceReads(CON::eMsgCMD'(msg_type), ace_rd_msg));

    //ar_pkt.ardomain = CON::axi_axdomain_enum_t'(2'b01);
    ar_pkt.arsnoop  = ace_rd_msg; //CON::ACE_READ_ONCE;
    //ar_pkt.arbar[0] = 1'b0;
    ar_pkt.arbar = '0;

    ar_pkt.aruser = '0;

    aiu_sfi_ace_master_if[0].drive_ace_master_read_addr_channel(ar_pkt);

    fork 
      aiu_sfi_ace_master_if[0].drive_master_acready();
      aiu_sfi_ace_master_if[1].drive_master_acready();
      aiu_sfi_ace_master_if[2].drive_master_acready();
      aiu_sfi_ace_master_if[3].drive_master_acready();
      aiu_sfi_ace_master_if[0].drive_master_rready();
      aiu_sfi_ace_master_if[1].drive_master_rready();
      aiu_sfi_ace_master_if[2].drive_master_rready();
      aiu_sfi_ace_master_if[3].drive_master_rready();
    join

    //#2us
    //$finish;
  end

  always@(posedge CLK or negedge RESETn) begin
    if (~RESETn) begin
      aiu_sfi_ace_master_if[0].crvalid <= 1'b0;
      aiu_sfi_ace_master_if[1].crvalid <= 1'b0;
      aiu_sfi_ace_master_if[2].crvalid <= 1'b0;
      aiu_sfi_ace_master_if[3].crvalid <= 1'b0;
      aiu_sfi_ace_master_if[0].rack    <= 1'b0;
      aiu_sfi_ace_master_if[1].rack    <= 1'b0;
      aiu_sfi_ace_master_if[2].rack    <= 1'b0;
      aiu_sfi_ace_master_if[3].rack    <= 1'b0;
    end else begin 
      aiu_sfi_ace_master_if[0].crvalid <= aiu_sfi_ace_master_if[0].acvalid;
      aiu_sfi_ace_master_if[1].crvalid <= aiu_sfi_ace_master_if[1].acvalid;
      aiu_sfi_ace_master_if[2].crvalid <= aiu_sfi_ace_master_if[2].acvalid;
      aiu_sfi_ace_master_if[3].crvalid <= aiu_sfi_ace_master_if[3].acvalid;
      aiu_sfi_ace_master_if[0].rack    <= aiu_sfi_ace_master_if[0].rvalid & aiu_sfi_ace_master_if[0].rready;
      aiu_sfi_ace_master_if[1].rack    <= aiu_sfi_ace_master_if[1].rvalid & aiu_sfi_ace_master_if[1].rready;
      aiu_sfi_ace_master_if[2].rack    <= aiu_sfi_ace_master_if[2].rvalid & aiu_sfi_ace_master_if[2].rready;
      aiu_sfi_ace_master_if[3].rack    <= aiu_sfi_ace_master_if[3].rvalid & aiu_sfi_ace_master_if[3].rready;
    end
  end

  //----------------------------------------------------------------------------
  // Clock and reset
  //----------------------------------------------------------------------------
  initial begin
    CLK = 0;
    RESETn = 1;
    #100ns
    RESETn = 0;
    repeat(8) begin
      #10ns CLK = ~CLK;
    end
    RESETn = 1;
    forever begin
      #10ns CLK = ~CLK;
    end
  end

endmodule: sub_sys_tb
