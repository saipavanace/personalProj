
//
// CCP Parameters Widths

<% if(obj.testBench=="emu"){ %>

parameter <%=obj.BlockId%>_harness_ccp_CACHELINE_SIZE     = <%= Math.pow(2,obj.wCacheLineOffset)%>; 
parameter <%=obj.BlockId%>_harness_ccp_CACHELINE_OFFSET   = <%= obj.wCacheLineOffset%>; 
parameter <%=obj.BlockId%>_harness_ccp_WCCPDATA_IF        = <%=obj.DutInfo.wData+1%> ; 
parameter <%=obj.BlockId%>_harness_ccp_WCCPDATA           = <%=obj.DutInfo.wData%> ; 
parameter <%=obj.BlockId%>_harness_ccp_WLOGCCPDATA        = <%= Math.log2(obj.DutInfo.wData/8)%>;
parameter <%=obj.BlockId%>_harness_ccp_WCCPBEAT           = $clog2(<%=obj.BlockId%>_harness_ccp_CACHELINE_SIZE*8/<%=obj.BlockId%>_harness_ccp_WCCPDATA); 
//parameter WCCPADDR           = <%=obj.wSysAddr%>;
parameter <%=obj.BlockId%>_harness_ccp_WCCPADDR           = <%=obj.wAddr%>;
parameter <%=obj.BlockId%>_harness_ccp_WCCPBYTEEN         = <%= obj.DutInfo.wData/8%>;
parameter <%=obj.BlockId%>_harness_ccp_WCCPDINID          = 2;
parameter <%=obj.BlockId%>_harness_ccp_WCCPDINCANCELID    = 2;

<% if((obj.Block === "aiu") || (obj.Block === "io_aiu")){%>
parameter <%=obj.BlockId%>_harness_ccp_WCCPFILLID         = <%=Math.ceil(Math.log2(obj.DutInfo.cmpInfo.nOttCtrlEntries))%>;
parameter <%=obj.BlockId%>_harness_ccp_WCCPFILLDONEID     = <%=Math.ceil(Math.log2(obj.DutInfo.cmpInfo.nOttCtrlEntries))%>;
<% } else if(obj.Block === "dmi") { %>
parameter <%=obj.BlockId%>_harness_ccp_WCCPFILLID         = <%=Math.ceil(Math.log2(obj.DutInfo.cmpInfo.nRttCtrlEntries))%>;
parameter <%=obj.BlockId%>_harness_ccp_WCCPFILLDONEID     = <%=Math.ceil(Math.log2(obj.DutInfo.cmpInfo.nRttCtrlEntries))%>;
<%} %>

parameter <%=obj.BlockId%>_harness_ccp_WCCPOUTIDVEC       = 4;
parameter <%=obj.BlockId%>_harness_ccp_WCCPARRAYSEL       = 1;

<% if((obj.useCache && obj.Block == "io_aiu") || (obj.Block === "dmi" && obj.useCmc == 1)) { %>
parameter <%=obj.BlockId%>_harness_ccp_N_DATA_BANK        =  <%= obj.DutInfo.nDataBanks %>; 
parameter <%=obj.BlockId%>_harness_ccp_N_TAG_BANK         =  <%= obj.DutInfo.nTagBanks %>; 
parameter <%=obj.BlockId%>_harness_ccp_N_WAY              =  <%= obj.DutInfo.nWays %>; 
parameter <%=obj.BlockId%>_harness_ccp_WCCPBANK           =  <%= obj.DutInfo.nTagBanks %>;
parameter <%=obj.BlockId%>_harness_ccp_WCCPBANKBIT        =  <%= obj.DutInfo.nTagBanks %>;
<% } else { %>
parameter <%=obj.BlockId%>_harness_ccp_N_DATA_BANK        =  2; 
parameter <%=obj.BlockId%>_harness_ccp_N_TAG_BANK         =  1; 
parameter <%=obj.BlockId%>_harness_ccp_N_WAY              =  4; 
parameter <%=obj.BlockId%>_harness_ccp_WCCPBANK           =  1;
parameter <%=obj.BlockId%>_harness_ccp_WCCPBANKBIT        =  1;
<% } %>
parameter <%=obj.BlockId%>_harness_ccp_WCCPOPTYPE         = 4;
parameter <%=obj.BlockId%>_harness_ccp_WCCPBUSRTLN        = $clog2(<%=obj.BlockId%>_harness_ccp_CACHELINE_SIZE*8/<%=obj.BlockId%>_harness_ccp_WCCPDATA);
parameter <%=obj.BlockId%>_harness_ccp_WCCPWAYS           = $clog2(<%=obj.BlockId%>_harness_ccp_N_WAY);
parameter <%=obj.BlockId%>_harness_ccp_WCCPOPID           = 2;
parameter <%=obj.BlockId%>_harness_ccp_WCCPOPDOUTID       = 2;
parameter <%=obj.BlockId%>_harness_ccp_WCCPOPDINID        = 2;
<%if(obj.DutInfo.fnCacheStates == "MOESI") { %>
parameter <%=obj.BlockId%>_harness_ccp_WCCPCACHESTATE     = 3;
<% } else { %>
parameter <%=obj.BlockId%>_harness_ccp_WCCPCACHESTATE     = 2;
<% } %>
parameter <%=obj.BlockId%>_harness_ccp_WCCPSECURITY       = 1;
parameter <%=obj.BlockId%>_harness_ccp_WCCPPOISION        = 1;

parameter <%=obj.BlockId%>_harness_ccp_BURSTLN            = <%=Math.pow(2,obj.wCacheLineOffset)*8/obj.DutInfo.wData%> ;
parameter <%=obj.BlockId%>_harness_ccp_WCSRDATA           = 32; 
parameter <%=obj.BlockId%>_harness_ccp_WCSROP             = 4; 
parameter <%=obj.BlockId%>_harness_ccp_WCSRWAY            = 6; 
parameter <%=obj.BlockId%>_harness_ccp_WCSRENTRY          = 20; 
parameter <%=obj.BlockId%>_harness_ccp_WCSRWORD           = 6; 

parameter <%=obj.BlockId%>_harness_ccp_WLOGCACHE          = $clog2(<%=obj.BlockId%>_harness_ccp_CACHELINE_SIZE);
parameter <%=obj.BlockId%>_harness_ccp_LINE_INDEX_LOW     = <%= Math.log2(obj.DutInfo.wData/8)%>;
parameter <%=obj.BlockId%>_harness_ccp_LINE_INDEX_HIGH    = <%=Math.log2(Math.pow(2,obj.wCacheLineOffset)*8/obj.DutInfo.wData)%>+<%= Math.log2(obj.DutInfo.wData/8)%> - 1;

<% if(obj.Block === "dmi") { %>
parameter  <%=obj.BlockId%>_harness_ccp_agent_id = <%=obj.DmiInfo[obj.Id].FUnitId%>;
<% } else { %>
parameter  <%=obj.BlockId%>_harness_ccp_agent_id = <%= obj.Id%>;
<% } %>
parameter <%=obj.BlockId%>_harness_ccp_WSMIMSG        = 8;
/* <%=JSON.stringify(obj,null,' ')%> */

<% } %>
