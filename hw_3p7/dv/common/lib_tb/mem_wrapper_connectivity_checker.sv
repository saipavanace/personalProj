`ifndef MEM_WRAPPER_CONNECTIVITY_CHECKER_SV
 `define MEM_WRAPPER_CONNECTIVITY_CHECKER_SV

module mem_wrapper_connectivity_checker(input tb_clk, input tb_rstn);
       
<% if ((obj.testBench === "fsys") || (obj.testBench === "emu")) { %>

<% if (obj.testBench === "fsys") { %>
   initial begin : connectivity_checker
       wait(tb_rstn === 1'b1);
<% var hier_path_dut = ['tb_top.dut']; %>
<% } %>
<% if (obj.testBench === "emu") { %>
<% var hier_path_dut = ['ncore_hdl_top.dut']; %>
<% } %>

<% var i, j, k; %>
<%   var dut_in_sgnls      = [];
     var dut_in_width      = [];
     var dut_out_sgnls     = [];
     var dut_out_width     = [];
     var aiu_in_inst_name  = [];
     var aiu_in_inst_path  = [];
     var aiu_out_inst_name = [];
     var aiu_out_inst_path = [];
     var wrpr_in_inst      = [];
     var wrpr_in_sgnls     = [];
     var wrpr_in_width     = [];
     var wrpr_out_inst     = [];
     var wrpr_out_sgnls    = [];
     var wrpr_out_width    = [];
%>

<% if (obj.testBench != "emu") { %>
  fork : AIU_CHECK
<% } %>
<% for (i=0; i<obj.AiuInfo.length; i++) { %>
<%   if (typeof obj.AiuInfo[i].interfaces.memoryInt !== 'undefined') { %>
<%   for (j=0; j<obj.AiuInfo[i].interfaces.memoryInt.length; j++) { %>
<%      if (obj.AiuInfo[i].interfaces.memoryInt[j]._SKIP_ === false ) { %>
<%         if (obj.AiuInfo[i].interfaces.memoryInt[j].params.wIn > 0) { %>
<%           if (obj.AiuInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%              for (k=0; k<obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.in.length; k++) { %>
<%                if (typeof obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.in[k] !== 'undefined') { %>
<%                  if (obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.in[k].width > 0) { %>
<%                  if(obj.AiuInfo[i].hierPath && obj.AiuInfo[i].hierPath !== ''){%>
<%                  aiu_in_inst_name.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.AiuInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_in_inst_name.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_in_sgnls.push(obj.AiuInfo[i].interfaces.memoryInt[j].name.concat(obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.in[k].name)); %>
<%                  dut_in_width.push(obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.in[k].width); %>
<%                  wrpr_in_inst.push(obj.AiuInfo[i].interfaces.memoryInt[j].name.substring(0, obj.AiuInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_out_sgnls.push(obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.in[k].name); %>
<%                  wrpr_out_width.push(obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.in[k].width); %>
<%           } } } } else { %>
<%                  if(obj.AiuInfo[i].hierPath && obj.AiuInfo[i].hierPath !== ''){%>
<%                  aiu_in_inst_name.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.AiuInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_in_inst_name.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_in_sgnls.push(obj.AiuInfo[i].interfaces.memoryInt[j].name); %>
<%                  dut_in_width.push(obj.AiuInfo[i].interfaces.memoryInt[j].params.wIn); %>
<%                  wrpr_in_inst.push(obj.AiuInfo[i].interfaces.memoryInt[j].name.substring(0, obj.AiuInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_out_sgnls.push(obj.AiuInfo[i].interfaces.memoryInt[j].name.concat('in')); %>
<%                  wrpr_out_width.push(obj.AiuInfo[i].interfaces.memoryInt[j].params.wIn) %>
<% } } %>
<%         if (obj.AiuInfo[i].interfaces.memoryInt[j].params.wOut > 0) { %>
<%           if (obj.AiuInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%              for (k=0; k<obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.out.length; k++) { %>
<%                if (typeof obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.out[k] !== 'undefined') { %>
<%                  if (obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.out[k].width > 0) { %>
<%                  if(obj.AiuInfo[i].hierPath && obj.AiuInfo[i].hierPath !== ''){%>
<%                  aiu_out_inst_name.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.AiuInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_out_inst_name.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_out_width.push(obj.AiuInfo[i].interfaces.memoryInt[j].name.concat(obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.out[k].width)); %>
<%                  if(obj.AiuInfo[i].hierPath && obj.AiuInfo[i].hierPath !== ''){%>
<%                  } else {%>
<%                  } %>
<%                  dut_out_sgnls.push(obj.AiuInfo[i].interfaces.memoryInt[j].name.concat(obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.out[k].name)); %>
<%                  wrpr_out_inst.push(obj.AiuInfo[i].interfaces.memoryInt[j].name.substring(0, obj.AiuInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_in_sgnls.push(obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.out[k].name); %>
<%                  wrpr_in_width.push(obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.out[k].width); %>
<%           } } } } else { %>
<%                  if(obj.AiuInfo[i].hierPath && obj.AiuInfo[i].hierPath !== ''){%>
<%                  aiu_out_inst_name.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.AiuInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_out_inst_name.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.AiuInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_out_width.push(obj.AiuInfo[i].interfaces.memoryInt[j].params.wOut)%>
<%                  dut_out_sgnls.push(obj.AiuInfo[i].interfaces.memoryInt[j].name); %>
<%                  wrpr_out_inst.push(obj.AiuInfo[i].interfaces.memoryInt[j].name.substring(0, obj.AiuInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_in_sgnls.push(obj.AiuInfo[i].interfaces.memoryInt[j].name.concat('in')); %>
<%                  wrpr_in_width.push(obj.AiuInfo[i].interfaces.memoryInt[j].params.wOut); %>
<% } } %>
<% } } %>
<% } } %>
<% for (i=0; i<obj.DmiInfo.length; i++) { %>
<%   if (typeof obj.DmiInfo[i].interfaces.memoryInt !== 'undefined') { %>
<%   for (j=0; j<obj.DmiInfo[i].interfaces.memoryInt.length; j++) { %>
<%      if (obj.DmiInfo[i].interfaces.memoryInt[j]._SKIP_ === false ) { %>
<%         if (obj.DmiInfo[i].interfaces.memoryInt[j].params.wIn > 0) { %>
<%           if (obj.DmiInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%              for (k=0; k<obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.in.length; k++) { %>
<%                if (typeof obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.in[k] !== 'undefined') { %>
<%                  if (obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.in[k].width > 0) { %>
<%                  if(obj.DmiInfo[i].hierPath && obj.DmiInfo[i].hierPath !== ''){%>
<%                  aiu_in_inst_name.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DmiInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_in_inst_name.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_in_sgnls.push(obj.DmiInfo[i].interfaces.memoryInt[j].name.concat(obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.in[k].name)); %>
<%                  dut_in_width.push(obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.in[k].width); %>
<%                  wrpr_in_inst.push(obj.DmiInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DmiInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_out_sgnls.push(obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.in[k].name); %>
<%                  wrpr_out_width.push(obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.in[k].width); %>
<%           } } } } else { %>
<%                  if(obj.DmiInfo[i].hierPath && obj.DmiInfo[i].hierPath !== ''){%>
<%                  aiu_in_inst_name.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DmiInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_in_inst_name.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_in_sgnls.push(obj.DmiInfo[i].interfaces.memoryInt[j].name); %>
<%                  dut_in_width.push(obj.DmiInfo[i].interfaces.memoryInt[j].params.wIn); %>
<%                  wrpr_in_inst.push(obj.DmiInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DmiInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_out_sgnls.push(obj.DmiInfo[i].interfaces.memoryInt[j].name.concat('in')); %>
<%                  wrpr_out_width.push(obj.DmiInfo[i].interfaces.memoryInt[j].params.wIn); %>
<% } } %>
<%         if (obj.DmiInfo[i].interfaces.memoryInt[j].params.wOut > 0) { %>
<%           if (obj.DmiInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%              for (k=0; k<obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.out.length; k++) { %>
<%                if (typeof obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.out[k] !== 'undefined') { %>
<%                  if (obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.out[k].width > 0) { %>
<%                  if(obj.DmiInfo[i].hierPath && obj.DmiInfo[i].hierPath !== ''){%>
<%                  aiu_out_inst_name.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DmiInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_out_inst_name.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_out_sgnls.push(obj.DmiInfo[i].interfaces.memoryInt[j].name.concat(obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.out[k].name)); %>
<%                  dut_out_width.push(obj.DmiInfo[i].interfaces.memoryInt[j].name.concat(obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.out[k].width)); %>
<%                  wrpr_out_inst.push(obj.DmiInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DmiInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_in_sgnls.push(obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.out[k].name); %>
<%                  wrpr_in_width.push(obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.out[k].width); %>
<%           } } } } else { %>
<%                  if(obj.DmiInfo[i].hierPath && obj.DmiInfo[i].hierPath !== ''){%>
<%                  aiu_out_inst_name.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DmiInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_out_inst_name.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DmiInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_out_sgnls.push(obj.DmiInfo[i].interfaces.memoryInt[j].name); %>
<%                  dut_out_width.push(obj.DmiInfo[i].interfaces.memoryInt[j].params.wOut); %>
<%                  wrpr_out_inst.push(obj.DmiInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DmiInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_in_sgnls.push(obj.DmiInfo[i].interfaces.memoryInt[j].name.concat('out')); %>
<%                  wrpr_in_width.push(obj.DmiInfo[i].interfaces.memoryInt[j].params.wOut); %>
<% } } %>
<% } } %>
<% } } %>
<% for (i=0; i<obj.DceInfo.length; i++) { %>
<%   if (typeof obj.DceInfo[i].interfaces.memoryInt !== 'undefined') { %>
<%   for (j=0; j<obj.DceInfo[i].interfaces.memoryInt.length; j++) { %>
<%      if (obj.DceInfo[i].interfaces.memoryInt[j]._SKIP_ === false ) { %>
<%         if (obj.DceInfo[i].interfaces.memoryInt[j].params.wIn > 0) { %>
<%           if (obj.DceInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%              for (k=0; k<obj.DceInfo[i].interfaces.memoryInt[j].synonyms.in.length; k++) { %>
<%                if (typeof obj.DceInfo[i].interfaces.memoryInt[j].synonyms.in[k] !== 'undefined') { %>
<%                  if (obj.DceInfo[i].interfaces.memoryInt[j].synonyms.in[k].width > 0) { %>
<%                  if(obj.DceInfo[i].hierPath && obj.DceInfo[i].hierPath !== ''){%>
<%                  aiu_in_inst_name.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DceInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_in_inst_name.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_in_sgnls.push(obj.DceInfo[i].interfaces.memoryInt[j].name.concat(obj.DceInfo[i].interfaces.memoryInt[j].synonyms.in[k].name)); %>
<%                  dut_in_width.push(obj.DceInfo[i].interfaces.memoryInt[j].synonyms.in[k].width); %>
<%                  wrpr_in_inst.push(obj.DceInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DceInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_out_width.push(obj.DceInfo[i].interfaces.memoryInt[j].synonyms.in[k].width); %>
<%                  wrpr_out_sgnls.push(obj.DceInfo[i].interfaces.memoryInt[j].synonyms.in[k].name); %>
<%           } } } } else { %>
<%                  if(obj.DceInfo[i].hierPath && obj.DceInfo[i].hierPath !== ''){%>
<%                  aiu_in_inst_name.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DceInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_in_inst_name.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_in_sgnls.push(obj.DceInfo[i].interfaces.memoryInt[j].name); %>
<%                  dut_in_width.push(obj.DceInfo[i].interfaces.memoryInt[j].params.wIn); %>
<%                  wrpr_in_inst.push(obj.DceInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DceInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_out_sgnls.push(obj.DceInfo[i].interfaces.memoryInt[j].name.concat('in')); %>
<%                  wrpr_out_width.push(obj.DceInfo[i].interfaces.memoryInt[j].params.wIn); %>
<% } %>
<% } %>
<%         if (obj.DceInfo[i].interfaces.memoryInt[j].params.wOut > 0) { %>
<%           if (obj.DceInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%              for (k=0; k<obj.DceInfo[i].interfaces.memoryInt[j].synonyms.out.length; k++) { %>
<%                if (typeof obj.DceInfo[i].interfaces.memoryInt[j].synonyms.out[k] !== 'undefined') { %>
<%                  if (obj.DceInfo[i].interfaces.memoryInt[j].synonyms.out[k].width > 0) { %>
<%                  if(obj.DceInfo[i].hierPath && obj.DceInfo[i].hierPath !== ''){%>
<%                  aiu_out_inst_name.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DceInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_out_inst_name.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_out_sgnls.push(obj.DceInfo[i].interfaces.memoryInt[j].name.concat(obj.DceInfo[i].interfaces.memoryInt[j].synonyms.out[k].name)); %>
<%                  dut_out_width.push(obj.DceInfo[i].interfaces.memoryInt[j].name.concat(obj.DceInfo[i].interfaces.memoryInt[j].synonyms.out[k].width)); %>
<%                  wrpr_out_inst.push(obj.DceInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DceInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_in_sgnls.push(obj.DceInfo[i].interfaces.memoryInt[j].synonyms.out[k].name); %>
<%                  wrpr_in_width.push(obj.DceInfo[i].interfaces.memoryInt[j].synonyms.out[k].width); %>
<%           } } } } else { %>
<%                  if(obj.DceInfo[i].hierPath && obj.DceInfo[i].hierPath !== ''){%>
<%                  aiu_out_inst_name.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DceInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_out_inst_name.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DceInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_out_sgnls.push(obj.DceInfo[i].interfaces.memoryInt[j].name); %>
<%                  dut_out_width.push(obj.DceInfo[i].interfaces.memoryInt[j].params.wOut); %>
<%                  wrpr_out_inst.push(obj.DceInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DceInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_in_sgnls.push(obj.DceInfo[i].interfaces.memoryInt[j].name.concat('out')); %>
<%                  wrpr_in_width.push(obj.DceInfo[i].interfaces.memoryInt[j].params.wOut); %>
<% } %>
<% } %>
<% } } %>
<% } } %>
<% for (i=0; i<obj.DveInfo.length; i++) { %>
<%   if (typeof obj.DveInfo[i].interfaces.memoryInt !== 'undefined') { %>
<%   for (j=0; j<obj.DveInfo[i].interfaces.memoryInt.length; j++) { %>
<%      if (obj.DveInfo[i].interfaces.memoryInt[j]._SKIP_ === false ) { %>
<%         if (obj.DveInfo[i].interfaces.memoryInt[j].params.wIn > 0) { %>
<%           if (obj.DveInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%              for (k=0; k<obj.DveInfo[i].interfaces.memoryInt[j].synonyms.in.length; k++) { %>
<%                if (typeof obj.DveInfo[i].interfaces.memoryInt[j].synonyms.in[k] !== 'undefined') { %>
<%                  if (obj.DveInfo[i].interfaces.memoryInt[j].synonyms.in[k].width > 0) { %>
<%                  if(obj.DveInfo[i].hierPath && obj.DveInfo[i].hierPath !== ''){%>
<%                  aiu_in_inst_name.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DveInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_in_inst_name.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_in_sgnls.push(obj.DveInfo[i].interfaces.memoryInt[j].name.concat(obj.DveInfo[i].interfaces.memoryInt[j].synonyms.in[k].name)); %>
<%                  dut_in_width.push(obj.DveInfo[i].interfaces.memoryInt[j].synonyms.in[k].width); %>
<%                  wrpr_in_inst.push(obj.DveInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DveInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_out_sgnls.push(obj.DveInfo[i].interfaces.memoryInt[j].synonyms.in[k].name); %>
<%                  wrpr_out_width.push(obj.DveInfo[i].interfaces.memoryInt[j].synonyms.in[k].width); %>
<%           } } } } else { %>
<%                  if(obj.DveInfo[i].hierPath && obj.DveInfo[i].hierPath !== ''){%>
<%                  aiu_in_inst_name.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DveInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_in_inst_name.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_in_sgnls.push(obj.DveInfo[i].interfaces.memoryInt[j].name); %>
<%                  dut_in_width.push(obj.DveInfo[i].interfaces.memoryInt[j].params.wIn); %>
<%                  wrpr_in_inst.push(obj.DveInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DveInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_out_sgnls.push(obj.DveInfo[i].interfaces.memoryInt[j].name.concat('in')); %>
<%                  wrpr_out_width.push(obj.DveInfo[i].interfaces.memoryInt[j].params.wIn); %>
<% } } %>
<%         if (obj.DveInfo[i].interfaces.memoryInt[j].params.wOut > 0) { %>
<%           if (obj.DveInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%              for (k=0; k<obj.DveInfo[i].interfaces.memoryInt[j].synonyms.out.length; k++) { %>
<%                if (typeof obj.DveInfo[i].interfaces.memoryInt[j].synonyms.out[k] !== 'undefined') { %>
<%                  if (obj.DveInfo[i].interfaces.memoryInt[j].synonyms.out[k].width > 0) { %>
<%                  if(obj.DveInfo[i].hierPath && obj.DveInfo[i].hierPath !== ''){%>
<%                  aiu_out_inst_name.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DveInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_out_inst_name.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_out_sgnls.push(obj.DveInfo[i].interfaces.memoryInt[j].name.concat(obj.DveInfo[i].interfaces.memoryInt[j].synonyms.out[k].name)); %>
<%                  dut_out_width.push(obj.DveInfo[i].interfaces.memoryInt[j].name.concat(obj.DveInfo[i].interfaces.memoryInt[j].synonyms.out[k].width)); %>
<%                  wrpr_out_inst.push(obj.DveInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DveInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_in_sgnls.push(obj.DveInfo[i].interfaces.memoryInt[j].synonyms.out[k].name); %>
<%                  wrpr_in_width.push(obj.DveInfo[i].interfaces.memoryInt[j].synonyms.out[k].width); %>
<%           } } } } else { %>
<%                  if(obj.DveInfo[i].hierPath && obj.DveInfo[i].hierPath !== ''){%>
<%                  aiu_out_inst_name.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DveInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_out_inst_name.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DveInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  dut_out_sgnls.push(obj.DveInfo[i].interfaces.memoryInt[j].name); %>
<%                  dut_out_width.push(obj.DveInfo[i].interfaces.memoryInt[j].params.wOut); %>
<%                  wrpr_out_inst.push(obj.DveInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DveInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_in_sgnls.push(obj.DveInfo[i].interfaces.memoryInt[j].name.concat('out')); %>
<%                  wrpr_in_width.push(obj.DveInfo[i].interfaces.memoryInt[j].params.wOut); %>
<% } } %>
<% } } %>
<% } } %>
<% for (i=0; i<obj.DiiInfo.length; i++) { %>
<%   if (typeof obj.DiiInfo[i].interfaces.memoryInt !== 'undefined') { %>
<%   for (j=0; j<obj.DiiInfo[i].interfaces.memoryInt.length; j++) { %>
<%      if (obj.DiiInfo[i].interfaces.memoryInt[j]._SKIP_ === false ) { %>
<%         if (obj.DiiInfo[i].interfaces.memoryInt[j].params.wIn > 0) { %>
<%           if (obj.DiiInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%              for (k=0; k<obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.in.length; k++) { %>
<%                if (typeof obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.in[k] !== 'undefined') { %>
<%                  if (obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.in[k].width > 0) { %>
<%                  dut_in_sgnls.push(obj.DiiInfo[i].interfaces.memoryInt[j].name.concat(obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.in[k].name)); %>
<%                  dut_in_width.push(obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.in[k].width); %>
<%                  if(obj.DiiInfo[i].hierPath && obj.DiiInfo[i].hierPath !== ''){%>
<%                  aiu_in_inst_name.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DiiInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_in_inst_name.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  wrpr_in_inst.push(obj.DiiInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DiiInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_out_sgnls.push(obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.in[k].name); %>
<%                  wrpr_out_width.push(obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.in[k].width); %>
<%           } } } } else { %>
<%                  dut_in_sgnls.push(obj.DiiInfo[i].interfaces.memoryInt[j].name); %>
<%                  dut_in_width.push(obj.DiiInfo[i].interfaces.memoryInt[j].params.wIn); %>
<%                  if(obj.DiiInfo[i].hierPath && obj.DiiInfo[i].hierPath !== ''){%>
<%                  aiu_in_inst_name.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DiiInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_in_inst_name.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  aiu_in_inst_path.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  wrpr_in_inst.push(obj.DiiInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DiiInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_out_sgnls.push(obj.DiiInfo[i].interfaces.memoryInt[j].name.concat('in')); %>
<%                  wrpr_out_width.push(obj.DiiInfo[i].interfaces.memoryInt[j].params.wIn); %>
<% } } %>
<%         if (obj.DiiInfo[i].interfaces.memoryInt[j].params.wOut > 0) { %>
<%           if (obj.DiiInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%              for (k=0; k<obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.out.length; k++) { %>
<%                if (typeof obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.out[k] !== 'undefined') { %>
<%                  if (obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.out[k].width > 0) { %>
<%                  dut_out_sgnls.push(obj.DiiInfo[i].interfaces.memoryInt[j].name.concat(obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.out[k].name)); %>
<%                  dut_out_width.push(obj.DiiInfo[i].interfaces.memoryInt[j].name.concat(obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.out[k].width)); %>
<%                  if(obj.DiiInfo[i].hierPath && obj.DiiInfo[i].hierPath !== ''){%>
<%                  aiu_out_inst_name.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DiiInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_out_inst_name.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  wrpr_out_inst.push(obj.DiiInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DiiInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_in_sgnls.push(obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.out[k].name); %>
<%                  wrpr_in_width.push(obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.out[k].width); %>
<%           } } } } else { %>
<%                  dut_out_sgnls.push(obj.DiiInfo[i].interfaces.memoryInt[j].name); %>
<%                  dut_out_width.push(obj.DiiInfo[i].interfaces.memoryInt[j].params.wOut); %>
<%                  if(obj.DiiInfo[i].hierPath && obj.DiiInfo[i].hierPath !== ''){%>
<%                  aiu_out_inst_name.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DiiInfo[i].instancePath); %>
<%                  } else {%>
<%                  aiu_out_inst_name.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  aiu_out_inst_path.push(obj.DiiInfo[i].strRtlNamePrefix); %>
<%                  } %>
<%                  wrpr_out_inst.push(obj.DiiInfo[i].interfaces.memoryInt[j].name.substring(0, obj.DiiInfo[i].interfaces.memoryInt[j].name.length-1)); %>
<%                  wrpr_in_sgnls.push(obj.DiiInfo[i].interfaces.memoryInt[j].name.concat('out')); %>
<%                  wrpr_in_width.push(obj.DiiInfo[i].interfaces.memoryInt[j].params.wOut); %>
<% } } %>
<% } } %>
<% } } %>

<% if (obj.testBench == "fsys") { %>
<%   if (typeof dut_in_sgnls !== 'undifined') { %>
<%     for (i=0; i<dut_in_sgnls.length; i++) { %>
         begin : <%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%>_check
<%       if (dut_in_width[i] > 1) { %>
            logic [<%=dut_in_width[i]%>-1:0] <%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%>;
<% }     else { %>
            logic <%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%>;
<% } %>
           repeat (10) begin
               std::randomize(<%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%>);
               force <%=hier_path_dut%>.<%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%> = <%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%>;
               repeat (10) @(posedge tb_clk);
               assert(<%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%> === <%=hier_path_dut%>.<%=aiu_in_inst_path[i]%>.<%=wrpr_in_inst[i]%>.<%=wrpr_out_sgnls[i]%>);
           end
        end : <%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%>_check
<% } } %>
<%   if (typeof dut_out_sgnls !== 'undefined') { %>
<%     for (i=0; i<dut_out_sgnls.length; i++) { %>
       begin : <%=aiu_out_inst_name[i]%>_<%=dut_out_sgnls[i]%>_check
<%       if (dut_out_width[i] > 1) { %>
            logic [<%=dut_out_width[i]%>-1:0] <%=aiu_out_inst_name[i]%>_<%=dut_out_sgnls[i]%>;
<% }     else { %>
            logic <%=aiu_out_inst_name[i]%>_<%=dut_out_sgnls[i]%>;
<% } %>
           repeat (10) begin
              std::randomize(<%=aiu_out_inst_name[i]%>_<%=dut_out_sgnls[i]%>);
              force <%=hier_path_dut%>.<%=aiu_out_inst_name[i]%>.<%=wrpr_out_inst[i]%>.<%=wrpr_in_sgnls[i]%> = <%=aiu_out_inst_name[i]%>_<%=dut_out_sgnls[i]%>;
              repeat (10) @(posedge tb_clk);
              assert(<%=hier_path_dut%>.<%=aiu_out_inst_path[i]%>.<%=wrpr_out_inst[i]%>.<%=wrpr_in_sgnls[i]%> == <%=hier_path_dut%>.<%=aiu_out_inst_name[i]%>_<%=dut_out_sgnls[i]%>);
           end
        end   : <%=aiu_out_inst_name[i]%>_<%=dut_out_sgnls[i]%>_check
<% } } } %>
<% if (obj.testBench == "emu") { %>
<%   if (typeof dut_in_sgnls !== 'undifined') { %>
<%     for (i=0; i<dut_in_sgnls.length; i++) { %>
<%       if (dut_in_width[i] > 1) { %>
            logic [<%=dut_in_width[i]%>-1:0] <%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%>;
            assign <%=hier_path_dut%>.<%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%> = {{<%=dut_in_width[i]%> - 1}{1'b0}}; //<%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%>;
<% }     else { %>
            logic <%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%>;
            assign <%=hier_path_dut%>.<%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%> = 1'b0; //<%=aiu_in_inst_name[i]%>_<%=dut_in_sgnls[i]%>;
<% } %>
<% } } %>
<%   if (typeof dut_out_sgnls !== 'undefined') { %>
<%     for (i=0; i<dut_out_sgnls.length; i++) { %>
<%       if (dut_out_width[i] > 1) { %>
            logic [<%=dut_out_width[i]%>-1:0] <%=aiu_out_inst_name[i]%>_<%=dut_out_sgnls[i]%>;
            assign <%=hier_path_dut%>.<%=aiu_out_inst_name[i]%>.<%=wrpr_out_inst[i]%>.<%=wrpr_in_sgnls[i]%> = {{<%=dut_out_width[i]%> - 1}{1'b0}}; //<%=aiu_out_inst_name[i]%>_<%=dut_out_sgnls[i]%>;
<% }     else { %>
            logic <%=aiu_out_inst_name[i]%>_<%=dut_out_sgnls[i]%>;
            assign <%=hier_path_dut%>.<%=aiu_out_inst_name[i]%>.<%=wrpr_out_inst[i]%>.<%=wrpr_in_sgnls[i]%> = 1'b0; //<%=aiu_out_inst_name[i]%>_<%=dut_out_sgnls[i]%>;
<% } %>
<% } } %>
<% } %>
<% if (obj.testBench != "emu") { %>
join
end : connectivity_checker
<% } %>
<% } %>
endmodule : mem_wrapper_connectivity_checker

`endif //MEM_WRAPPER_CONNECTIVITY_CHECKER_SV
