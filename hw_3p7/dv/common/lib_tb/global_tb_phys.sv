
<%
var blocks = [];

var arrUniquify = function(arr) {
    if( arr.constructor !== Array) {
        console.log(typeof(arr));
        throw 'Functions expects array';
    }
    var u = {}; var mArr = [];
    arr.forEach(function(e, i, array) {
        if(!u[e.BlockId]) {
            mArr.push(e);
            u[e.BlockId] = true;
        }
    });
    return(mArr);
};

if(obj.CUSTOMER_ENV) {
    obj.WrapperInfo.forEach(function(e, i ,array) {
        blocks.push(e);

        if(i === obj.WrapperInfo.length -1) {
            blocks = arrUniquify(blocks);
        }
    });
}

%>

<% if(obj.CUSTOMER_ENV) { %>
`define U_CHIP <%=obj.strProjectName%>
<% } else { %>
`define U_CHIP tb_top.dut
<% } %>



<% if(obj.CUSTOMER_ENV) {

    blocks.forEach(function(e, idx, array) {
        var cap = e.BlockId.toUpperCase();
	if(e.block == "aiu") {
	   var block_name = "unit";
	} else {
	   var block_name = e.block + "_unit";
	}				    
%>

`define <%=cap%> <%=obj.strProjectName%>.<%=e.rtlPrefix%>.<%=block_name%>
`define <%=cap%>_wrapper <%=obj.strProjectName%>.<%=e.rtlPrefix%>
<%
});
%>

<% } else { %>
    `define ASSERT_ERROR(I, M) $root.tb_top.assert_error(``I``, ``M``);
<% } %>
 
`define INNERSHAREABLE_START_ADDR  64'h0
`define INNERSHAREABLE_END_ADDR    64'hffffffffffff
`define OUTERSHAREABLE_START_ADDR  64'h1000000000000
`define OUTERSHAREABLE_END_ADDR    64'h1ffffffffffff
`define SYSTEMSHAREABLE_START_ADDR 64'h2000000000000
`define SYSTEMSHAREABLE_END_ADDR   64'h3ffffffffffff
`define NONSHAREABLE_START_ADDR    64'h4000000000000
`define NONSHAREABLE_END_ADDR      64'h4ffffffffffff
