//
// SMI Parameters Widths
//
<% if (obj.testBench == "emu" ) { %>

<% if (1 == 0) { %>
<% } %>

<%
//print smi params
for (var key in obj.smiObj) { 
    var smifieldval = obj.smiObj[key]; 
    var smifielden = 1;
    // Check only parameters who start with W (for widths)
    if (
        (key.substring(0,1) == "W")
        && (!obj.smiObj[key])  
    ) { 
        smifieldval = 0;
        smifielden  = 0;
    }
%>
    parameter <%=obj.BlockId%>_probe_<%=key%> = <%=smifieldval%>;
    parameter <%=obj.BlockId%>_probe_<%=key + '_EN'%> = <%=smifielden%>;

<% } %>


<% for (var key in obj.smiMsgObj) { %>
    parameter <%=obj.BlockId%>_probe_<%=key%> = <%=obj.smiMsgObj[key]%>;
<% } %>
<% } %>
