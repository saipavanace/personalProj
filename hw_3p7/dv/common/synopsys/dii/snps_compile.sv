`ifdef USE_VIP_SNPS
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_R-2021.03
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_S-2021.06
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vc-vip_vS-2021.12
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_T-2022.09
  //`define DESIGNWARE_INCDIR /engr/eda/tools/synopsys/vip_amba_svt_U-2023.03
    `define DESIGNWARE_INCDIR /engr/eda/tools/synopsys/vip_amba_svt_W-2025.03
  `define SVT_VENDOR_LC mti
  `define SVT_AXI_INCLUDE_USER_DEFINES
  `define SVT_APB_INCLUDE_USER_DEFINES
  `define SVT_AXI_ADDR_TAG_ATTRIBUTES_WIDTH 1
 //------------------------------------------
// includes for VIP
//--------------------------------------------
`include "uvm_pkg.sv"
// Include the AXI SVT UVM package 
`include "svt_amba.uvm.pkg"
`include "svt_axi_if.svi"
`include "svt_axi_user_defines.svi"
`include "svt_apb_user_defines.svi"
  `endif // USE_VIP_SNPS
