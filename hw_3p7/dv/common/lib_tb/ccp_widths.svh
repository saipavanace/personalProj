//
// CCP Parameters Widths


parameter CACHELINE_SIZE     = <%= Math.pow(2,obj.wCacheLineOffset)%>; 
parameter CACHELINE_OFFSET   = <%= obj.wCacheLineOffset%>; 
parameter WCCPDATA_IF        = <%=obj.wData+1%> ; 
parameter WCCPDATA           = <%=obj.wData%> ; 
parameter WLOGCCPDATA        = <%= Math.log2(obj.wData/8)%>;
parameter WCCPBEAT           = $clog2(CACHELINE_SIZE*8/WCCPDATA); 
//parameter WCCPADDR           = <%=obj.wSysAddr%>;
parameter WCCPADDR           = <%=obj.wAddr%>;
parameter WCCPBYTEEN         = <%= obj.wData/8%>;
parameter WCCPDINID          = 2;
parameter WCCPDINCANCELID    = 2;

<% if((obj.Block === "aiu") || (obj.Block === "io_aiu")){%>
parameter WCCPFILLID         = <%=Math.ceil(Math.log2(obj.nOttCtrlEntries))%>;
parameter WCCPFILLDONEID     = <%=Math.ceil(Math.log2(obj.nOttCtrlEntries))%>;
<% } else if(obj.Block === "dmi") { %>
parameter WCCPFILLID         = <%=Math.ceil(Math.log2(obj.nRttCtrlEntries))%>;
parameter WCCPFILLDONEID     = <%=Math.ceil(Math.log2(obj.nRttCtrlEntries))%>;
<%} %>

parameter WCCPOUTIDVEC       = 4;
parameter WCCPARRAYSEL       = 1;


<% if((obj.useCache && obj.Block == "io_aiu") || (obj.Block === "dmi" && obj.useCmc == 1)) { %>
parameter N_DATA_BANK        =  <%= obj.nDataBanks %>; 
parameter N_TAG_BANK         =  <%= obj.nTagBanks %>; 
parameter N_WAY              =  <%= obj.nWays %>; 
parameter WCCPBANK           =  <%= obj.nTagBanks %>;
parameter WCCPBANKBIT        =  <%= obj.nTagBanks %>;
<% } else { %>
parameter N_DATA_BANK        =  2; 
parameter N_TAG_BANK         =  1; 
parameter N_WAY              =  4; 
parameter WCCPBANK           =  1;
parameter WCCPBANKBIT        =  1;
<% } %>
parameter WCCPOPTYPE         = 4;
parameter WCCPBUSRTLN        = $clog2(CACHELINE_SIZE*8/WCCPDATA);
parameter WCCPWAYS           = $clog2(N_WAY);
parameter WCCPOPID           = 2;
parameter WCCPOPDOUTID       = 2;
parameter WCCPOPDINID        = 2;
<%if(obj.fnCacheStates == "MOESI") { %>
parameter WCCPCACHESTATE     = 3;
<% } else { %>
parameter WCCPCACHESTATE     = 2;
<% } %>
parameter WCCPSECURITY       = 1;
parameter WCCPPOISION        = 1;

parameter BURSTLN            = <%=Math.pow(2,obj.wCacheLineOffset)*8/obj.wData%> ;
parameter WCSRDATA           = 32; 
parameter WCSROP             = 4; 
parameter WCSRWAY            = 6; 
parameter WCSRENTRY          = 20; 
parameter WCSRWORD           = 6; 

parameter WLOGCACHE          = $clog2(CACHELINE_SIZE);
parameter LINE_INDEX_LOW     = <%= Math.log2(obj.wData/8)%>;
parameter LINE_INDEX_HIGH    = <%=Math.log2(Math.pow(2,obj.wCacheLineOffset)*8/obj.wData)%>+<%= Math.log2(obj.wData/8)%> - 1;

<% if(obj.Block === "dmi") { %>
parameter  agent_id = <%=obj.DmiInfo[obj.Id].FUnitId%>;
<% } else { %>
parameter  agent_id = <%=obj.AiuInfo[obj.Id].FUnitId%>; //<%= obj.Id%>;
<% } %>
parameter WSMIMSG        = 8;
