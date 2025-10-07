//-------------------------------------------------------------------------------------------------- 
// AXI Parameters
//-------------------------------------------------------------------------------------------------- 

<%if(obj.Block == "dmi" || obj.Block == "io_aiu" || obj.Block == "aceaiu" ) { %> 
// Change below to use WARID and WAWID
// This needs to be defined in build_tb_env
typedef bit [<%=obj.BlockId%>_MGC_WARID-1:0]       <%=obj.BlockId%>_MGC_axi_arid_t;
typedef bit [<%=obj.BlockId%>_MGC_WAWID-1:0]       <%=obj.BlockId%>_MGC_axi_awid_t;
<% } else { %>    
typedef bit [<%=obj.BlockId%>_MGC_WAXID-1:0]       <%=obj.BlockId%>_MGC_axi_arid_t;
typedef bit [<%=obj.BlockId%>_MGC_WAXID-1:0]       <%=obj.BlockId%>_MGC_axi_awid_t;
<% } %>
typedef bit [<%=obj.BlockId%>_MGC_WAXADDR-1:0]     <%=obj.BlockId%>_MGC_axi_axaddr_t;
typedef bit [<%=obj.BlockId%>_MGC_WAXADDR-1+<%=obj.wSecurityAttribute%>:0] <%=obj.BlockId%>_MGC_axi_axaddr_security_t;
typedef bit [<%=obj.BlockId%>_MGC_WXDATA-1:0]      <%=obj.BlockId%>_MGC_axi_xdata_t;
typedef bit [<%=obj.BlockId%>_MGC_WXDATA/8-1:0]    <%=obj.BlockId%>_MGC_axi_xstrb_t;
typedef bit [<%=obj.BlockId%>_MGC_WAWUSER-1:0]     <%=obj.BlockId%>_MGC_axi_awuser_t;
typedef bit [<%=obj.BlockId%>_MGC_WARUSER-1:0]     <%=obj.BlockId%>_MGC_axi_aruser_t;
typedef bit [<%=obj.BlockId%>_MGC_WWUSER-1:0]      <%=obj.BlockId%>_MGC_axi_wuser_t;
typedef bit [<%=obj.BlockId%>_MGC_WRUSER-1:0]      <%=obj.BlockId%>_MGC_axi_ruser_t;
typedef bit [<%=obj.BlockId%>_MGC_WBUSER-1:0]      <%=obj.BlockId%>_MGC_axi_buser_t;
typedef bit [<%=obj.BlockId%>_MGC_WCDDATA-1:0]     <%=obj.BlockId%>_MGC_axi_cddata_t;
typedef bit [<%=obj.BlockId%>_MGC_CAXLEN-1:0]      <%=obj.BlockId%>_MGC_axi_axlen_t;
typedef bit [<%=obj.BlockId%>_MGC_CAXSIZE-1:0]     <%=obj.BlockId%>_MGC_axi_axsize_t;
typedef bit [<%=obj.BlockId%>_MGC_CAXBURST-1:0]    <%=obj.BlockId%>_MGC_axi_axburst_t;
typedef bit [<%=obj.BlockId%>_MGC_CAXLOCK-1:0]     <%=obj.BlockId%>_MGC_axi_axlock_t;
typedef bit [<%=obj.BlockId%>_MGC_CAXCACHE-1:0]    <%=obj.BlockId%>_MGC_axi_axcache_t;
typedef bit [<%=obj.BlockId%>_MGC_CAXPROT-1:0]     <%=obj.BlockId%>_MGC_axi_axprot_t;
typedef bit [<%=obj.BlockId%>_MGC_CAXQOS-1:0]      <%=obj.BlockId%>_MGC_axi_axqos_t;
typedef bit [<%=obj.BlockId%>_MGC_CAXREGION-1:0]   <%=obj.BlockId%>_MGC_axi_axregion_t;
typedef bit [<%=obj.BlockId%>_MGC_CARSNOOP-1:0]    <%=obj.BlockId%>_MGC_axi_arsnoop_t;
typedef bit [<%=obj.BlockId%>_MGC_CAWSNOOP-1:0]    <%=obj.BlockId%>_MGC_axi_awsnoop_t;
typedef bit [<%=obj.BlockId%>_MGC_CACSNOOP-1:0]    <%=obj.BlockId%>_MGC_axi_acsnoop_t;
typedef bit [<%=obj.BlockId%>_MGC_CAXDOMAIN-1:0]   <%=obj.BlockId%>_MGC_axi_axdomain_t;
typedef bit [<%=obj.BlockId%>_MGC_CAXBAR-1:0]      <%=obj.BlockId%>_MGC_axi_axbar_t;
typedef bit [<%=obj.BlockId%>_MGC_CRRESP-1:0]      <%=obj.BlockId%>_MGC_axi_rresp_t;
typedef bit [<%=obj.BlockId%>_MGC_CBRESP-1:0]      <%=obj.BlockId%>_MGC_axi_bresp_t;
typedef bit [<%=obj.BlockId%>_MGC_CCRRESP-1:0]     <%=obj.BlockId%>_MGC_axi_crresp_t;
parameter <%=obj.BlockId%>_MGC_SYS_nSysCacheline   = <%=Math.pow(2, obj.wCacheLineOffset)%>;
parameter <%=obj.BlockId%>_MGC_SYS_wSysCacheline   = <%=obj.wCacheLineOffset%>;
parameter <%=obj.BlockId%>_MGC_BARRIER_AXID        = 2**(<%=obj.BlockId%>_MGC_WAXID-1) - 1;
parameter <%=obj.BlockId%>_MGC_DVM_ARID_1          = <%=obj.BlockId%>_MGC_BARRIER_AXID - 1;
parameter <%=obj.BlockId%>_MGC_DVM_ARID_2          = <%=obj.BlockId%>_MGC_BARRIER_AXID - 2;
parameter <%=obj.BlockId%>_MGC_DVM_ARID_3          = <%=obj.BlockId%>_MGC_BARRIER_AXID - 3;
<%if(obj.Block == "aiu" || obj.Block === 'io_aiu' || obj.Block === 'aceaiu') { %> 
// Change below to use WARID and WAWID
// This needs to be defined in build_tb_env
typedef logic [<%=obj.BlockId%>_MGC_WARID-1:0]            <%=obj.BlockId%>_MGC_axi_arid_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WAWID-1:0]            <%=obj.BlockId%>_MGC_axi_awid_logic_t;
<% } else { %>    
typedef logic [<%=obj.BlockId%>_MGC_WAXID-1:0]            <%=obj.BlockId%>_MGC_axi_arid_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WAXID-1:0]            <%=obj.BlockId%>_MGC_axi_awid_logic_t;
<% } %>
typedef logic [<%=obj.BlockId%>_MGC_WAXADDR-1:0]          <%=obj.BlockId%>_MGC_axi_axaddr_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WXDATA-1:0]           <%=obj.BlockId%>_MGC_axi_xdata_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WXDATA/8-1:0]         <%=obj.BlockId%>_MGC_axi_xstrb_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WAWUSER-1:0]          <%=obj.BlockId%>_MGC_axi_awuser_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WARUSER-1:0]          <%=obj.BlockId%>_MGC_axi_aruser_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WWUSER-1:0]           <%=obj.BlockId%>_MGC_axi_wuser_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WRUSER-1:0]           <%=obj.BlockId%>_MGC_axi_ruser_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WBUSER-1:0]           <%=obj.BlockId%>_MGC_axi_buser_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WCDDATA-1:0]          <%=obj.BlockId%>_MGC_axi_cddata_logic_t;

typedef logic [<%=obj.BlockId%>_MGC_CAXLEN-1:0]           <%=obj.BlockId%>_MGC_axi_axlen_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CAXSIZE-1:0]          <%=obj.BlockId%>_MGC_axi_axsize_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CAXBURST-1:0]         <%=obj.BlockId%>_MGC_axi_axburst_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CAXLOCK-1:0]          <%=obj.BlockId%>_MGC_axi_axlock_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CAXCACHE-1:0]         <%=obj.BlockId%>_MGC_axi_axcache_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CAXPROT-1:0]          <%=obj.BlockId%>_MGC_axi_axprot_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CAXQOS-1:0]           <%=obj.BlockId%>_MGC_axi_axqos_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CAXREGION-1:0]        <%=obj.BlockId%>_MGC_axi_axregion_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CARSNOOP-1:0]         <%=obj.BlockId%>_MGC_axi_arsnoop_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CAWSNOOP-1:0]         <%=obj.BlockId%>_MGC_axi_awsnoop_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CACSNOOP-1:0]         <%=obj.BlockId%>_MGC_axi_acsnoop_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CAXDOMAIN-1:0]        <%=obj.BlockId%>_MGC_axi_axdomain_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CAXBAR-1:0]           <%=obj.BlockId%>_MGC_axi_axbar_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CRRESP-1:0]           <%=obj.BlockId%>_MGC_axi_rresp_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CBRESP-1:0]           <%=obj.BlockId%>_MGC_axi_bresp_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_CCRRESP-1:0]          <%=obj.BlockId%>_MGC_axi_crresp_logic_t;

// AXI-LITE-E signal types
typedef logic [<%=obj.BlockId%>_MGC_WAWATOP-1:0]          <%=obj.BlockId%>_MGC_axi_awatop_t;
typedef logic [<%=obj.BlockId%>_MGC_WARVMIDEXT-1:0]       <%=obj.BlockId%>_MGC_axi_arvmidext_t;
typedef logic [<%=obj.BlockId%>_MGC_WACVMIDEXT-1:0]       <%=obj.BlockId%>_MGC_axi_acvmidext_t;
typedef logic [<%=obj.BlockId%>_MGC_WAWSTASHNID-1:0]      <%=obj.BlockId%>_MGC_axi_awstashnid_t;
typedef logic [<%=obj.BlockId%>_MGC_WAWSTASHLPID-1:0]     <%=obj.BlockId%>_MGC_axi_awstashlpid_t;
typedef logic [<%=obj.BlockId%>_MGC_WRPOISON-1:0]         <%=obj.BlockId%>_MGC_axi_rpoison_t;
typedef logic [<%=obj.BlockId%>_MGC_WWPOISON-1:0]         <%=obj.BlockId%>_MGC_axi_wpoison_t;
typedef logic [<%=obj.BlockId%>_MGC_WCDPOISON-1:0]        <%=obj.BlockId%>_MGC_axi_cdpoison_t;
typedef logic [<%=obj.BlockId%>_MGC_WRDATACHK-1:0]        <%=obj.BlockId%>_MGC_axi_rdatachk_t;
typedef logic [<%=obj.BlockId%>_MGC_WWDATACHK-1:0]        <%=obj.BlockId%>_MGC_axi_wdatachk_t;
typedef logic [<%=obj.BlockId%>_MGC_WCDDATACHK-1:0]       <%=obj.BlockId%>_MGC_axi_cddatachk_t;
typedef logic [<%=obj.BlockId%>_MGC_WARLOOP-1:0]          <%=obj.BlockId%>_MGC_axi_arloop_t;
typedef logic [<%=obj.BlockId%>_MGC_WAWLOOP-1:0]          <%=obj.BlockId%>_MGC_axi_awloop_t;
typedef logic [<%=obj.BlockId%>_MGC_WRLOOP-1:0]           <%=obj.BlockId%>_MGC_axi_rloop_t;
typedef logic [<%=obj.BlockId%>_MGC_WBLOOP-1:0]           <%=obj.BlockId%>_MGC_axi_bloop_t;
typedef logic [<%=obj.BlockId%>_MGC_WAXMMUSID-1:0]        <%=obj.BlockId%>_MGC_axi_axmmusid_t;
typedef logic [<%=obj.BlockId%>_MGC_WAXMMUSSID-1:0]       <%=obj.BlockId%>_MGC_axi_axmmussid_t;
typedef logic [<%=obj.BlockId%>_MGC_WARNSAID-1:0]         <%=obj.BlockId%>_MGC_axi_arnsaid_t;
typedef logic [<%=obj.BlockId%>_MGC_WAWNSAID-1:0]         <%=obj.BlockId%>_MGC_axi_awnsaid_t;
typedef logic [<%=obj.BlockId%>_MGC_WCRNSAID-1:0]         <%=obj.BlockId%>_MGC_axi_crnsaid_t;

typedef logic [<%=obj.BlockId%>_MGC_WAWATOP-1:0]          <%=obj.BlockId%>_MGC_axi_awatop_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WARVMIDEXT-1:0]       <%=obj.BlockId%>_MGC_axi_arvmidext_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WACVMIDEXT-1:0]       <%=obj.BlockId%>_MGC_axi_acvmidext_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WAWSTASHNID-1:0]      <%=obj.BlockId%>_MGC_axi_awstashnid_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WAWSTASHLPID-1:0]     <%=obj.BlockId%>_MGC_axi_awstashlpid_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WRPOISON-1:0]         <%=obj.BlockId%>_MGC_axi_rpoison_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WWPOISON-1:0]         <%=obj.BlockId%>_MGC_axi_wpoison_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WCDPOISON-1:0]        <%=obj.BlockId%>_MGC_axi_cdpoison_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WRDATACHK-1:0]        <%=obj.BlockId%>_MGC_axi_rdatachk_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WWDATACHK-1:0]        <%=obj.BlockId%>_MGC_axi_wdatachk_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WCDDATACHK-1:0]       <%=obj.BlockId%>_MGC_axi_cddatachk_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WARLOOP-1:0]          <%=obj.BlockId%>_MGC_axi_arloop_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WAWLOOP-1:0]          <%=obj.BlockId%>_MGC_axi_awloop_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WRLOOP-1:0]           <%=obj.BlockId%>_MGC_axi_rloop_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WBLOOP-1:0]           <%=obj.BlockId%>_MGC_axi_bloop_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WAXMMUSID-1:0]        <%=obj.BlockId%>_MGC_axi_axmmusid_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WAXMMUSSID-1:0]       <%=obj.BlockId%>_MGC_axi_axmmussid_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WARNSAID-1:0]         <%=obj.BlockId%>_MGC_axi_arnsaid_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WAWNSAID-1:0]         <%=obj.BlockId%>_MGC_axi_awnsaid_logic_t;
typedef logic [<%=obj.BlockId%>_MGC_WCRNSAID-1:0]         <%=obj.BlockId%>_MGC_axi_crnsaid_logic_t;

