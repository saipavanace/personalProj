//
// SMI Parameters Widths
//
<%const chipletObj = obj.lib.getAllChipletRefs();%>

<%
//print smi params
for (var key in chipletObj[0].smiObj) { 
    var smifieldval = chipletObj[0].smiObj[key]; 
    var smifielden = 1;
    // Check only parameters who start with W (for widths)
    if (
        (key.substring(0,1) == "W")
        && (!chipletObj[0].smiObj[key])  
    ) { 
        smifieldval = 0;
        smifielden  = 0;
    }
%>
    parameter <%=key%> = <%=smifieldval%>;
    parameter <%=key + '_EN'%> = <%=smifielden%>;

<% } %>


<% for (var key in chipletObj[0].smiMsgObj) { %>
    parameter <%=key%> = <%=chipletObj[0].smiMsgObj[key]%>;
<% } %>
