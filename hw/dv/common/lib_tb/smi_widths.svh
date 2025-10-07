//
// SMI Parameters Widths
//


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
    parameter <%=key%> = <%=smifieldval%>;
    parameter <%=key + '_EN'%> = <%=smifielden%>;

<% } %>


<% for (var key in obj.smiMsgObj) { %>
    parameter <%=key%> = <%=obj.smiMsgObj[key]%>;
<% } %>
