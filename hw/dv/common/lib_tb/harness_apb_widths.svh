//-------------------------------------------------------------------------------------------------- 
// APB Parameters
//-------------------------------------------------------------------------------------------------- 

<% if(obj.testBench=="emu"){ %>
<%
var apbObj = {};

//Defaults
apbObj.wpaddr              = obj.DceInfo[0].interfaces.apbInt.params.wAddr;
apbObj.wpwrite             = 1;
apbObj.wpsel               = 1;
apbObj.wpenable            = 1;
apbObj.wprdata             = obj.DceInfo[0].interfaces.apbInt.params.wData;
apbObj.wpwdata             = obj.DceInfo[0].interfaces.apbInt.params.wData;
apbObj.wpready             = 1;
apbObj.wpslverr            = obj.DceInfo[0].interfaces.apbInt.params.wPSlverr;


%>

parameter  <%=obj.BlockId%>_harness_WPADDR              = <%=apbObj.wpaddr%>;
parameter  <%=obj.BlockId%>_harness_WPWRITE             = <%=apbObj.wpwrite%>;
parameter  <%=obj.BlockId%>_harness_WPSEL               = <%=apbObj.wpsel%>;
parameter  <%=obj.BlockId%>_harness_WPENABLE            = <%=apbObj.wpenable%>;
parameter  <%=obj.BlockId%>_harness_WPRDATA             = <%=apbObj.wprdata%>;
parameter  <%=obj.BlockId%>_harness_WPWDATA             = <%=apbObj.wpwdata%>;
parameter  <%=obj.BlockId%>_harness_WPREADY             = <%=apbObj.wpready%>;
parameter  <%=obj.BlockId%>_harness_WPSLVERR            = <%=apbObj.wpslverr%>;

<% } %>
