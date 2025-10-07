//-------------------------------------------------------------------------------------------------- 
// APB Parameters
//-------------------------------------------------------------------------------------------------- 

<% if(obj.testBench=="emu"){ %>
// This needs to be defined in build_tb_env
typedef bit [<%=obj.BlockId%>_harness_WPADDR-1:0]           <%=obj.BlockId%>_harness_apb_paddr_t;
typedef bit [<%=obj.BlockId%>_harness_WPWRITE-1:0]          <%=obj.BlockId%>_harness_apb_pwrite_t;
typedef bit [<%=obj.BlockId%>_harness_WPSEL-1:0]            <%=obj.BlockId%>_harness_apb_psel_t;
typedef bit [<%=obj.BlockId%>_harness_WPENABLE-1:0]         <%=obj.BlockId%>_harness_apb_penable_t;
typedef bit [<%=obj.BlockId%>_harness_WPRDATA-1:0]          <%=obj.BlockId%>_harness_apb_prdata_t;
typedef bit [<%=obj.BlockId%>_harness_WPWDATA-1:0]          <%=obj.BlockId%>_harness_apb_pwdata_t;
typedef bit [<%=obj.BlockId%>_harness_WPREADY-1:0]          <%=obj.BlockId%>_harness_apb_pready_t;
typedef bit [<%=obj.BlockId%>_harness_WPSLVERR-1:0]         <%=obj.BlockId%>_harness_apb_pslverr_t;

// This needs to be defined in build_tb_env
typedef logic [<%=obj.BlockId%>_harness_WPADDR-1:0]         <%=obj.BlockId%>_harness_apb_paddr_logic_t;
typedef logic [<%=obj.BlockId%>_harness_WPWRITE-1:0]        <%=obj.BlockId%>_harness_apb_pwrite_logic_t;
typedef logic [<%=obj.BlockId%>_harness_WPSEL-1:0]          <%=obj.BlockId%>_harness_apb_psel_logic_t;
typedef logic [<%=obj.BlockId%>_harness_WPENABLE-1:0]       <%=obj.BlockId%>_harness_apb_penable_logic_t;
typedef logic [<%=obj.BlockId%>_harness_WPRDATA-1:0]        <%=obj.BlockId%>_harness_apb_prdata_logic_t;
typedef logic [<%=obj.BlockId%>_harness_WPWDATA-1:0]        <%=obj.BlockId%>_harness_apb_pwdata_logic_t;
typedef logic [<%=obj.BlockId%>_harness_WPREADY-1:0]        <%=obj.BlockId%>_harness_apb_pready_logic_t;
typedef logic [<%=obj.BlockId%>_harness_WPSLVERR-1:0]       <%=obj.BlockId%>_harness_apb_pslverr_logic_t;

//--------------------------------------------------------------------------------------------------
// Enums Functions for APB packets that have predefined types 
//-------------------------------------------------------------------------------------------------- 
<% } %>
