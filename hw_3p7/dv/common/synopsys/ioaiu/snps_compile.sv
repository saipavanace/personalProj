`ifdef USE_VIP_SNPS
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_R-2021.03
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_S-2021.06
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vc-vip_vS-2021.12
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_S-2021.09-3-T-20211203
  `define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_W-2025.03
  `define SVT_VENDOR_LC mti
  `define SVT_AXI_INCLUDE_USER_DEFINES
  `define SVT_AXI_ADDR_TAG_ATTRIBUTES_WIDTH 1
  //`define PA_ENABLE
  `include "svt_axi_user_defines.svi"

  `include "uvm_pkg.sv"
  `include "uvm_macros.svh"
  `include "svt_axi.uvm.pkg"
`endif // USE_VIP_SNPS
