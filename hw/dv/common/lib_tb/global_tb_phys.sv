
`define U_CHIP tb_top.dut

`define ASSERT_ERROR(I, M) $root.tb_top.assert_error(``I``, ``M``);
 
`define INNERSHAREABLE_START_ADDR  64'h0
`define INNERSHAREABLE_END_ADDR    64'hffffffffffff
`define OUTERSHAREABLE_START_ADDR  64'h1000000000000
`define OUTERSHAREABLE_END_ADDR    64'h1ffffffffffff
`define SYSTEMSHAREABLE_START_ADDR 64'h2000000000000
`define SYSTEMSHAREABLE_END_ADDR   64'h3ffffffffffff
`define NONSHAREABLE_START_ADDR    64'h4000000000000
`define NONSHAREABLE_END_ADDR      64'h4ffffffffffff
