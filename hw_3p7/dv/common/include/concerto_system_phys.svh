
//Defines
`ifdef SV_FLEXNOC
    `define AIU0             u_chip.aiu0
    `define DCE0             u_chip.dce 
    `define DMI0             u_chip.dmi 
`else
    `define AIU0             u_chip.coh.aiu0
    `define DCE0             u_chip.coh.dce 
    `define DMI0             u_chip.coh.dmi 
`endif

//`define AIU1             top__top.top__top__coh.top__top__coh__aiu1
//`define AIU2             top__top.top__top__coh.top__top__coh__aiu2
//`define AIU3             top__top.top__top__coh.top__top__coh__aiu3

