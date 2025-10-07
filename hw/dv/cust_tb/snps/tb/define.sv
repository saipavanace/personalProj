//Defines
//RTL hierarchy
<%const chipletObj = obj.lib.getAllChipletRefs();%>

`define U_CHIP ncore_system_tb_top.u_chip

<% 
    //Embedded javascript code to figure out
    //number of blocks
    var _child_m = [];
    var rtlDefine = [];
    var _child_hier = [];
    var _child_instpath = [];

    //JS logic for strRtlPrefix support 
    //for Signal naming

    for(var idx = 0; idx < chipletObj[0].DceInfo.nDces; idx++) {
        _child_m.push('dce' + idx);
        rtlDefine.push('dce' + idx);
    }

calAgentAiuStrRtlPrefix(chipletObj[0].AiuInfo, 0);
calDmiStrRtlPrefix();
calDiiStrRtlPrefix();
calDceStrRtlPrefix();
calDveStrRtlPrefix();

    function calAgentAiuStrRtlPrefix(agentList, initSeed) {
        var curAiuIndx = 0;

       agentList.forEach(function(bundle, indx, array) {
            var strRtlPrefix = '';
            var hierPath = '';
            var instancePath = '';

            strRtlPrefix = bundle.strRtlNamePrefix;
            if(bundle.hierPath && bundle.hierPath!=='') {
              hierPath = bundle.hierPath;
              instancePath = bundle.instancePath;
            }
            _child_m.push(strRtlPrefix);
            _child_hier.push(hierPath);
            _child_instpath.push(instancePath);
            rtlDefine.push('aiu' + (indx + initSeed));

            if(curAiuIndx === bundle.nAius -1) {
                curAiuIndx = 0;
            } else { 
                curAiuIndx++;
            }
        });
    }

    function calDmiStrRtlPrefix() {
        var curDmiIndx = 0;

        chipletObj[0].DmiInfo.forEach(function(bundle, indx, array) {
            var strRtlPrefix = '';
            var hierPath = '';
            var instancePath = '';
            strRtlPrefix = bundle.strRtlNamePrefix;
            if(bundle.hierPath && bundle.hierPath!=='') {
              hierPath = bundle.hierPath;
              instancePath = bundle.instancePath;
            }
            _child_m.push(strRtlPrefix);
            _child_hier.push(hierPath);
            _child_instpath.push(instancePath);
            rtlDefine.push('dmi' + indx);
            if(curDmiIndx === bundle.nDmis -1) {
                curDmiIndx = 0;
            } else { 
                curDmiIndx++;
            }
        });
    }
    function calDiiStrRtlPrefix() {
        var curDiiIndx = 0;

        chipletObj[0].DiiInfo.forEach(function(bundle, indx, array) {
            var strRtlPrefix = '';
            var hierPath = '';
            var instancePath = '';
            strRtlPrefix = bundle.strRtlNamePrefix;
            if(bundle.hierPath && bundle.hierPath!=='') {
              hierPath = bundle.hierPath;
              instancePath = bundle.instancePath;
            }
            _child_m.push(strRtlPrefix);
            _child_hier.push(hierPath);
            _child_instpath.push(instancePath);
            rtlDefine.push('dii' + indx);

            if(curDiiIndx === bundle.nDiis -1) {
                curDiiIndx = 0;
            } else { 
                curDiiIndx++;
            }
        });
    }
    function calDceStrRtlPrefix() {
        var curDceIndx = 0;

        chipletObj[0].DceInfo.forEach(function(bundle, indx, array) {
            var strRtlPrefix = '';
            var hierPath = '';
            var instancePath = '';
            strRtlPrefix = bundle.strRtlNamePrefix;
            if(bundle.hierPath && bundle.hierPath!=='') {
              hierPath = bundle.hierPath;
              instancePath = bundle.instancePath;
            }
            _child_m.push(strRtlPrefix);
            _child_hier.push(hierPath);
            _child_instpath.push(instancePath);
            rtlDefine.push('dce' + indx);
            if(curDceIndx === bundle.nDces -1) {
                curDceIndx = 0;
            } else { 
                curDceIndx++;
            }
        });
    }
    function calDveStrRtlPrefix() {
        var curDveIndx = 0;
        chipletObj[0].DveInfo.forEach(function(bundle, indx, array) {
            var strRtlPrefix = '';
            var hierPath = '';
            var instancePath = '';

            strRtlPrefix = bundle.strRtlNamePrefix;
            if(bundle.hierPath && bundle.hierPath!=='') {
              hierPath = bundle.hierPath;
              instancePath = bundle.instancePath;
            }
            _child_m.push(strRtlPrefix);
            _child_hier.push(hierPath);
            _child_instpath.push(instancePath);
            rtlDefine.push('dve' + indx);

            if(curDveIndx === bundle.nDves -1) {
                curDveIndx = 0;
            } else { 
                curDveIndx++;
            }
        });
    }
%>

<% for(var pidx  in _child_m) { %>
<%     var cap = rtlDefine[pidx].toUpperCase(); 
       var blockName =  cap.split(/[0-9]+/); %>
<% if(blockName[0] === 'AIU'){ %>
<% if(pidx == 0) { %>
<% if (_child_hier[pidx] !== '') {%>
`define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_instpath[pidx]%>
<%}else{%>
`define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>
<%}%>

<% }else { %>
<% if (_child_hier[pidx] !== '') {%>
`define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_instpath[pidx]%>
<%}else{%>
`define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>
<%}%>

<% } %>
`define <%=cap%>_wrapper    ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>      //<%=_child_m[pidx]%>
<%} else if(blockName[0] === 'DCE') {%>
<% if (_child_hier[pidx] !== '') {%>
   `define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_instpath[pidx]%>
<%}else{%>
   `define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>
<%}%>

<% if (_child_hier[pidx] !== '') {%>
   `define <%=cap%>_wrapper    ncore_system_tb_top.u_chip.<%=_child_instpath[pidx]%>
<%}else{%>
   `define <%=cap%>_wrapper    ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>          //<%=_child_m[pidx]%>
<%}%>
<%} else if(blockName[0] === 'DMI') {%>
<% if (_child_hier[pidx] !== '') {%>
   `define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_instpath[pidx]%>
<%}else{%>
   `define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>
<%}%>

//`define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>.dmi_unit.dmi //<%=_child_m[pidx]%>
`define <%=cap%>_wrapper    ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>          //<%=_child_m[pidx]%>
<%} else if(blockName[0] === 'DII') {%>
<% if (_child_hier[pidx] !== '') {%>
`define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_instpath[pidx]%>
<%}else{%>
`define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>
<%}%>

<% if (_child_hier[pidx] !== '') {%>
   `define <%=cap%>_wrapper    ncore_system_tb_top.u_chip.<%=_child_instpath[pidx]%>
<%}else{%>
   `define <%=cap%>_wrapper    ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>          //<%=_child_m[pidx]%>
<%}%>
<%} else if(blockName[0] === 'DVE') {%>
<% if (_child_hier[pidx] !== '') {%>
`define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_instpath[pidx]%>
<%}else{%>
`define <%=cap%>            ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>
<%}%>

`define <%=cap%>_wrapper    ncore_system_tb_top.u_chip.<%=_child_m[pidx]%>          //<%=_child_m[pidx]%>
<% } %>
<% } %>

