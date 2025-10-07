//import ConcertoPkg::*;

module sub_sys (

  sfi_ace_if.slave   aiu_sfi_ace_slave_if  [CON::SYS_nSysAIUs], // ACE channels: AC out, CR in, CD in
                                                                // AXI Channels: AR in, R out, AW in, W in, B out

  sfi_axi_if.master  aiu_sfi_axi_master_if [CON::SYS_nSysAIUs], // AXI Channels: AR out, R in, AW out, W out, B in

  input logic        clk,
  input logic        rst_n
);

  localparam nSfiSlaves  = CON::SYS_nSysAIUs + 1 + 1; // AIUs, DCE, DMI
  localparam nSfiMasters = CON::SYS_nSysAIUs + 1 + 1; // AIUs, DCE, DMI

  sfi_if      sfi_master_if [nSfiSlaves]  (clk, rst_n);
  sfi_if      sfi_slave_if  [nSfiMasters] (clk, rst_n);
  sfi_axi_if  dmi_sfi_axi_if       (clk, rst_n); 


//req_aiu_dut u_aiu0 (
  aiu_dut u_aiu0 (

    .sfi_ace_slave_if  ( aiu_sfi_ace_slave_if[0]  ),

    .sfi_axi_master_if ( aiu_sfi_axi_master_if[0] ),

    .sfi_master_if     ( sfi_master_if[0]         ),
    .sfi_slave_if      ( sfi_slave_if[0]          ),

    .clk               ( clk                      ),
    .rst_n             ( rst_n                    )
  );

  snp_aiu_dut u_aiu1 (

    .sfi_ace_slave_if  ( aiu_sfi_ace_slave_if[1]  ),

    .sfi_axi_master_if ( aiu_sfi_axi_master_if[1] ),

    .sfi_master_if     ( sfi_master_if[1]         ),
    .sfi_slave_if      ( sfi_slave_if[1]          ),

    .clk               ( clk                      ),
    .rst_n             ( rst_n                    )
  );

  snp_aiu_dut u_aiu2 (

    .sfi_ace_slave_if  ( aiu_sfi_ace_slave_if[2]  ),

    .sfi_axi_master_if ( aiu_sfi_axi_master_if[2] ),

    .sfi_master_if     ( sfi_master_if[2]         ),
    .sfi_slave_if      ( sfi_slave_if[2]          ),

    .clk               ( clk                      ),
    .rst_n             ( rst_n                    )
  );

  snp_aiu_dut u_aiu3 (

    .sfi_ace_slave_if  ( aiu_sfi_ace_slave_if[3]  ),

    .sfi_axi_master_if ( aiu_sfi_axi_master_if[3] ),

    .sfi_master_if     ( sfi_master_if[3]         ),
    .sfi_slave_if      ( sfi_slave_if[3]          ),

    .clk               ( clk                      ),
    .rst_n             ( rst_n                    )
  );


  dce_dut u_dce (

    .slave_if          ( sfi_slave_if[4]          ),
    .master_if         ( sfi_master_if[4]         ),

    .clk               ( clk                      ),
    .rst_n             ( rst_n                    )
  );


  dmi_dut u_dmi (

    .sfi_slave_if      ( sfi_slave_if[5]          ),
    .sfi_master_if     ( sfi_master_if[5]         ),

    .sfi_axi_master_if ( dmi_sfi_axi_if           ),

    .clk               ( clk                      ),
    .rst_n             ( rst_n                    )
  );


  sfi_axi_mem u_mem (

    .sfi_axi_slave_if ( dmi_sfi_axi_if           ),

    .clk              ( clk                      ),
    .rst_n            ( rst_n                    )
  );


  dv_sfi_xbar_top #(

    .nSLV ( nSfiMasters ),
    .nMAS ( nSfiSlaves  )

  ) u_sfi_xbar (

  .sfi_slave_if            ( sfi_master_if      ),
  .sfi_master_if           ( sfi_slave_if       ),

  .clk                     ( clk                ),
  .rst_n                   ( rst_n              )
  );

endmodule

