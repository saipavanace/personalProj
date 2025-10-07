//`define USE_VIP_SNPS
//`ifdef USE_VIP_SNPS
  `ifdef DISABLE_SNPS_AXI_SLAVES
  `undef USE_VIP_SNPS_AXI_SLAVES
  `endif
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_R-2021.03
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_S-2021.06
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vc-vip_vS-2021.12
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_S-2021.09-3-T-20211203
`ifdef VCS  
  `define SVT_VENDOR_LC vcs
  `define DESIGNWARE_INCDIR /engr/eda/tools/synopsys/vip_amba_svt_W-2025.03
  //`define DESIGNWARE_INCDIR /engr/eda/tools/synopsys/vip_amba_svt_U-2023.03
`else
  `define SVT_VENDOR_LC mti
  //`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_T-2022.03
  `define DESIGNWARE_INCDIR /engr/eda/tools/synopsys/vip_amba_svt_W-2025.03
`endif
  `define SVT_AMBA_INCLUDE_CHI_IN_AMBA_SYS_ENV
  //`define SVT_AMBA_EXCLUDE_AHB_IN_AMBA_SYS_ENV
  //`define SVT_AMBA_EXCLUDE_AXI_IN_AMBA_SYS_ENV
  //`define SVT_AMBA_EXCLUDE_APB_IN_AMBA_SYS_ENV
  //`define SVT_AMBA_EXCLUDE_AXI_IN_CHI_SYS_ENV
  //`define SVT_LOADER_UTIL_ENABLE_DWHOME_INCDIRS
  `define SVT_EXCLUDE_METHODOLOGY_PKG_INCLUDE
  //`define SVT_EXCLUDE_METHODOLOGY_PKG
  `define SVT_CHI_INCLUDE_USER_DEFINES
  `define PA_ENABLE
  `define SVT_CHI_TAGGED_ADDR_SPACE_ENABLE 
  `ifdef CHI_B2B_INTF
  `define SVT_CHI_MIN_TXREQFLITPEND_DELAY 1 
  `define SVT_CHI_MAX_TXREQFLITPEND_DELAY 1
  `define SVT_CHI_MIN_TXREQFLITV_DELAY    1
  `define SVT_CHI_MAX_TXREQFLITV_DELAY    1
  `define SVT_CHI_MIN_TXDATFLITPEND_DELAY 1 
  `define SVT_CHI_MAX_TXDATFLITPEND_DELAY 1 
  `define SVT_CHI_MIN_TXDATFLITV_DELAY     1
  `define SVT_CHI_MAX_TXDATFLITV_DELAY     1
  `define SVT_CHI_MIN_TXRSPFLITPEND_DELAY  1
  `define SVT_CHI_MAX_TXRSPFLITPEND_DELAY  1
   `endif

<%
//Embedded javascript code to figure number of blocks
   var pidx = 0;
   var chiaiu_idx = 0;
   var max_addr_width = 0;
   var max_req_flit_rsvdc_width = 0;
   var max_data_width = 0;
   var max_node_id_width = 0;
   var addr_width_arr = [];
   var data_width_arr = [];
%>

   <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
       <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       <% if (obj.testBench == "fsys") { %>
          <%
          data_width_arr.push(obj.AiuInfo[pidx].interfaces.chiInt.params.wData)
          addr_width_arr.push(obj.AiuInfo[pidx].interfaces.chiInt.params.wAddr)
          if(max_data_width<obj.AiuInfo[pidx].interfaces.chiInt.params.wData) {
            max_data_width = obj.AiuInfo[pidx].interfaces.chiInt.params.wData;
          }
          if(max_addr_width<obj.AiuInfo[pidx].interfaces.chiInt.params.wAddr) {
            max_addr_width = obj.AiuInfo[pidx].interfaces.chiInt.params.wAddr;
          }
          if(max_req_flit_rsvdc_width<obj.AiuInfo[pidx].interfaces.chiInt.params.REQ_RSVDC) {
            max_req_flit_rsvdc_width = obj.AiuInfo[pidx].interfaces.chiInt.params.REQ_RSVDC;
          }
          if(max_node_id_width<obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID) {
            max_node_id_width = obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID;
          }
          %>
          //Interface specific defines
          `define SVT_CHI_DAT_FLIT_MAX_DATA_WIDTH  <%=max_data_width%>
          `define SVT_CHI_MAX_ADDR_WIDTH <%=max_addr_width%>
          `define SVT_CHI_MAX_NODE_ID_WIDTH <%=max_node_id_width%>
          `define SVT_CHI_REQ_FLIT_MAX_RSVDC_WIDTH <%=max_req_flit_rsvdc_width%>
           
       <% } else { %>
         <% if (chiaiu_idx<1 && obj.testBench == "chi_aiu") { %>
          //Interface specific defines
          <%
          if(max_node_id_width<obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID) {
            max_node_id_width = obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID;
          }
          %>
          `define SVT_CHI_DAT_FLIT_MAX_DATA_WIDTH  <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wData%>
          `define SVT_CHI_MAX_ADDR_WIDTH <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wAddr%>
          `define SVT_CHI_MAX_NODE_ID_WIDTH <%=max_node_id_width%>
          `define SVT_CHI_REQ_FLIT_MAX_RSVDC_WIDTH <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC%>
         <% } %>
       <% } %>
       <% chiaiu_idx++; %>
     <% } %>
   <% } %>
   `define SVT_CHI_DAT_FLIT_MAX_RSVDC_WIDTH  0 


  `include "uvm_pkg.sv"

  `include "uvm_macros.svh"
  //`include "svt_chi_defines.svi"
   <%if(obj.testBench != "io_aiu"){%>
  `include "svt_chi_user_defines.svi"
   <%}%>
<% if (obj.testBench == "fsys" || obj.testBench == "io_aiu") { %>
  `define SVT_AXI_INCLUDE_USER_DEFINES
  `define SVT_AXI_ADDR_TAG_ATTRIBUTES_WIDTH 1
  `include "svt_axi_user_defines.svi"
   <%if(obj.testBench != "io_aiu"){%>
  `define SVT_APB_INCLUDE_USER_DEFINES
  <%}%>
  `include "svt_apb_user_defines.svi"
  //`include "svt_apb_if.svi"
<% } %>
  `include  "svt_amba.uvm.pkg"
  //`include  "svt_chi.uvm.pkg"
  /** Include the AMBA COMMON SVT UVM package */
  //`include "svt_amba_common.uvm.pkg"
   <%if(obj.testBench != "io_aiu"){%>
  `include "svt_chi_if.svi" //top-level CHI interface
   <%}%>
//`endif // USE_VIP_SNPS
