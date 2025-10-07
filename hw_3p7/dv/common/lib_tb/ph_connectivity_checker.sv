/****************************************************************************************************************************
*                                                                                                                           *
* Placeholder connectivity checker for Ncore 3.0 placeholder conectivity check                                              *                       
* This modue only checks the connectivity for additional generic port signals                                               *
* Since the FUNITs may inserter fops between units' ports and placeholder ports                                             *
* checking is done by forcing inputs at uint and outputs at placeholder, and check inputs at placeholder and outputs at     *
* units a few cycles later                                                                                                  *
*                                                                                                                           *
* File    : pl_connectivity_checker.sv                                                                                      *
* Version : 0.1                                                                                                             *                                       
* Author  : Chien chen                                                                                                      *
* Confluence page links  :                                                                                                  *
*                                                                                                                           *
*                                                                                                                           *                         
/***************************************************************************************************************************/

`ifndef PH_CONNECTIVITY_CHECKER_SV
`define PH_CONNECTIVITY_CHECKER_SV

<% if (obj.useResiliency) { %>

module ph_connectivity_checker(input tb_clk, input tb_rstn);
// Testbench <%=obj.testBench%>

<% if (obj.testBench === "fsys") {  %>
 //console.log("bench is fsys"); %>
<% var hier_path_dut = ['tb_top.dut']; %>

<% var aiu_sizePhArray = []; %>
<% var aiu_userPlaceInt = []; %>
<% for (var i=0; i<obj.AiuInfo.length; i++) { %>
     //console.log("looping through aiuinfo length i=%d", i); %>
<%    let isArray = Array.isArray(obj.AiuInfo[i].interfaces.userPlaceInt); %>
<%    if (isArray) { %>
<%       aiu_sizePhArray[i] = obj.AiuInfo[i].interfaces.userPlaceInt.length; %>
<%       aiu_userPlaceInt[i] = new Array(aiu_sizePhArray); %>
         //console.log("isArray is set i=%d aiu_sizePhArray[%d]=%d", i, i, aiu_sizePhArray[i]); %>
<%       for (var j=0; j<aiu_sizePhArray[i]; j++) { %>
             //console.log("loop through aiu_sizePhArray i=%d j=%d", i, j); %>
<%          aiu_userPlaceInt[i][j] = obj.AiuInfo[i].interfaces.userPlaceInt[j]; %>
<%       } %>
<%    } else { %>
          //console.log("isArray is not set i=%d", i); %>
<%       aiu_sizePhArray[i] = 1; %>
<%       aiu_userPlaceInt[i] = new Array(1); %>
<%       aiu_userPlaceInt[i][0] = obj.AiuInfo[i].interfaces.userPlaceInt; %>
<%    } %>
<% } %>

//inject_uncorrectable_error
//fsc_inject_correctable_err
// Check AIUs
<% for (var i = 0; i<obj.AiuInfo.length; i++) { %>
       //console.log("NXT looping through aiuinfo length i=%d", i); %>
<%    for (var idx=0; idx < aiu_sizePhArray[i]; idx++) { %>
       //console.log("NXT looping through aiuinfo length idx=%d", idx); %>
<%    if (aiu_userPlaceInt[i][idx]._SKIP_ == false) { %>
<%    if (aiu_userPlaceInt[i][idx].params.wIn > 0) { %>
      initial begin : <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=idx%>_PH_IN_CHECK
      if(!($test$plusargs("fsc_inject_correctable_err") || $test$plusargs("inject_uncorrectable_error")))begin 
<%    if (aiu_userPlaceInt[i][idx].synonymsOn == true) { %>
      <% for (var j=0; j<aiu_userPlaceInt[i][idx].synonyms.in.length; j++) { %>
      <% if (aiu_userPlaceInt[i][idx].synonyms.in[j].width > 1) { %>
          bit [<%=aiu_userPlaceInt[i][idx].synonyms.in[j].width%>-1:0] <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%>;
      <% } else { %>
          bit <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%>;
      <% } } %>
      <% } else { %>
      <% if (aiu_userPlaceInt[i][idx].params.wIn > 1) { %>
          bit [<%=aiu_userPlaceInt[i][idx].params.wIn%>-1:0] <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>;
      <% } else { %>
          bit                                                              <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>;
      <% } }  %>
      wait( tb_rstn === 1'b1 );  // do not support reset during tests
      forever begin: <%=obj.AiuInfo[i].strRtlNamePrefix%>_PH_IN_CHECK_LOOP
<%    if (aiu_userPlaceInt[i][idx].synonymsOn == true) { %>
      <% for (var j=0; j < aiu_userPlaceInt[i][idx].synonyms.in.length; j++) { %>
          std::randomize( <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%> );
          force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%><%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%> = <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%>;
      <% } %>
      <% } else { %>
          std::randomize( <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%> );
          force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%><%=aiu_userPlaceInt[i][idx].name%> = <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>;
      <% } %>
        repeat (10) @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);

<%    if (aiu_userPlaceInt[i][idx].synonymsOn == true) { %>

         //console.log("aiu_userPlaceInt synonymsOn is true"); %>
      <% for (var j=0; j < aiu_userPlaceInt[i][idx].synonyms.in.length; j++) { %>
//          assert(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%><%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%> == <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%>);
            //console.log("i:%d idx:%d j:%d length:%d", i, idx, j, aiu_userPlaceInt[i][idx].synonyms.in.length); %>
          assert(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%if (obj.AiuInfo[i].fnNativeInterface.indexOf("CHI") >= 0) {%>unit.u_chiPlaceholder<%} else {%>ioaiu_core_wrapper.ioaiu_core<%=idx%>.pph<%}%>.<%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%> == <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%>);
      <% if (obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          //assert(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%if (obj.AiuInfo[i].fnNativeInterface.indexOf("CHI") >= 0) {%>dup_unit<%=idx%>.u_chiPlaceholder<%} else {%>dup_unit<%=idx%>.pph<%}%>.<%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%> == <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%>);
          assert(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%if (obj.AiuInfo[i].fnNativeInterface.indexOf("CHI") >= 0) {%>dup_unit.u_chiPlaceholder<%} else {%>dup_unit.ioaiu_core0.pph<%}%>.<%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%> == <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.in[j].name%>);
      <% } } %>
      <% } else { %>
//          assert(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[idx].name%><%=aiu_userPlaceInt[idx].name%> == <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[idx].name%>);
          assert(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%if (obj.AiuInfo[i].fnNativeInterface.indexOf("CHI") >= 0) {%>unit.u_chiPlaceholder<%} else {%>ioaiu_core_wrapper.ioaiu_core<%=idx%>.pph<%}%>.<%=aiu_userPlaceInt[i][idx].name%> == <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>);
      <% if (obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          assert(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%if (obj.AiuInfo[i].fnNativeInterface.indexOf("CHI") >= 0) {%>dup_unit<%=idx%>.u_chiPlaceholder<%} else {%>dup_unit<%=idx%>.pph<%}%>.<%=aiu_userPlaceInt[i][idx].name%> == <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>);
      <% } } %>
        @(posedge  <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
      end : <%=obj.AiuInfo[i].strRtlNamePrefix%>_PH_IN_CHECK_LOOP
     end
   end : <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=idx%>_PH_IN_CHECK
<% } %>

<%    if (aiu_userPlaceInt[i][idx].params.wOut > 0) { %>
      initial begin : <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=idx%>_PH_OUT_CHECK
      if(!($test$plusargs("fsc_inject_correctable_err") || $test$plusargs("inject_uncorrectable_error")))begin 
<%    if (aiu_userPlaceInt[i][idx].synonymsOn == true) { %>
      <% for (var j=0; j<aiu_userPlaceInt[i][idx].synonyms.out.length; j++) { %>
      <% if (aiu_userPlaceInt[i][idx].synonyms.out[j].width > 1) { %>
          bit [<%=aiu_userPlaceInt[i][idx].synonyms.out[j].width%>-1:0] <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%>;
          bit [<%=aiu_userPlaceInt[i][idx].synonyms.out[j].width%>-1:0] <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%>_dup;
      <% } else { %>
          bit <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%>;
          bit <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%>_dup;
      <% } } %>
      <% } else { %>
      <% if (aiu_userPlaceInt[i][idx].params.wOut > 1) { %>
          bit [<%=aiu_userPlaceInt[i][idx].width%>-1:0] <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>;
          bit [<%=aiu_userPlaceInt[i][idx].width%>-1:0] <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>_dup;
      <% } else { %>
          bit <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>;
          bit <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>_dup;
      <% } } %>
      wait( tb_rstn === 1'b1 );  // do not support reset during tests
      forever begin: <%=obj.AiuInfo[i].strRtlNamePrefix%>_PH_OUT_CHECK_LOOP
<%    if (aiu_userPlaceInt[i][idx].synonymsOn == true) { %>
      <% for (var j=0; j < aiu_userPlaceInt[i][idx].synonyms.out.length; j++) { %>
          std::randomize( <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%> );
          force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%if (obj.AiuInfo[i].fnNativeInterface.indexOf("CHI") >= 0) {%>unit.u_chiPlaceholder<%} else {%>ioaiu_core_wrapper.ioaiu_core<%=idx%>.pph<%}%>.<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%> = <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%>;
        <% if (obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          repeat(<%= obj.AiuInfo[i].ResilienceInfo.nResiliencyDelay %>) @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
          <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%>_dup = <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%>;
          force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%if (obj.AiuInfo[i].fnNativeInterface.indexOf("CHI") >= 0) {%>dup_unit.u_chiPlaceholder<%} else {%>dup_unit.ioaiu_core0.pph<%}%>.<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%> = <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%>_dup;
        <% } %>
      <% } %>
      <% } else { %>
          std::randomize( <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%> );
          force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%if (obj.AiuInfo[i].fnNativeInterface.indexOf("CHI") >= 0) {%>unit.u_chiPlaceholder<%} else {%>ioaiu_core_wrapper.ioaiu_core<%=idx%>.pph<%}%>.<%=aiu_userPlaceInt[i][idx].name%> = <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>;
        <% if (obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          repeat(<%= obj.AiuInfo[i].ResilienceInfo.nResiliencyDelay %>) @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
          <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>_dup = <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>;
          force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%if (obj.AiuInfo[i].fnNativeInterface.indexOf("CHI") >= 0) {%>dup_unit<%=idx%>.u_chiPlaceholder<%} else {%>dup_unit<%=idx%>.pph<%}%>.<%=aiu_userPlaceInt[i][idx].name%> = <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>_dup;
        <% } %>
      <% } %>
      repeat (10) @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
<%    if (aiu_userPlaceInt[i][idx].synonymsOn == true) { %>
      <% for (var j=0; j < aiu_userPlaceInt[i][idx].synonyms.out.length; j++) { %>
          assert(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%><%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%> == <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%>);
      <% if (obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) { %>
//          assert(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%if (obj.AiuInfo[i].fnNativeInterface.indexOf("CHI") >= 0) {%>dup_unit<%=idx%>.u_chiPlaceholder<%} else {%>dup_unit<%=idx%>.pph<%}%>.<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%> == <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].synonyms.out[j].name%>);
      <% } } %>
      <% } else { %>     
          assert(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%><%=aiu_userPlaceInt[i][idx].name%> == <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[i][idx].name%>);
      <% if (obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) { %>
//          assert(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%if (obj.AiuInfo[i].fnNativeInterface.indexOf("CHI") >= 0) {%>dup_unit<%=idx%>.u_chiPlaceholder<%} else {%>dup_unit.<%=idx%>pph<%}%>.<%=aiu_userPlaceInt[idx].name%> == <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=aiu_userPlaceInt[idx].name%>);
      <% } } %>
        @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
      end : <%=obj.AiuInfo[i].strRtlNamePrefix%>_PH_OUT_CHECK_LOOP
     end
   end : <%=obj.AiuInfo[i].strRtlNamePrefix%>_<%=idx%>_PH_OUT_CHECK
<% } %>
<% } %>
<% } %>
<% } %>

// Check DMIs
<% for (var i = 0; i<obj.DmiInfo.length; i++) { %>
<%    if (obj.DmiInfo[i].interfaces.userPlaceInt._SKIP_ == false) { %>
<%    if (obj.DmiInfo[i].interfaces.userPlaceInt.params.wIn > 0) { %>
      initial begin : <%=obj.DmiInfo[i].strRtlNamePrefix%>_PH_IN_CHECK
      if(!($test$plusargs("fsc_inject_correctable_err") || $test$plusargs("inject_uncorrectable_error")))begin 
<%    if (obj.DmiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j<obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in.length; j++) { %>
      <% if (obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].width > 1) { %>
          bit [<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].width%>-1:0] <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>;
      <% } else { %>
          bit <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>;
      <% } } %>
      <% } else { %>
      <% if (obj.DmiInfo[i].interfaces.userPlaceInt.params.wIn > 1) { %>
          bit [<%=obj.DmiInfo[i].interfaces.userPlaceInt.width%>-1:0] <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>;
      <% } else { %>
          bit <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>;
      <% } } %>
      wait( tb_rstn === 1'b1 );  // do not support reset during tests
      forever begin: <%=obj.DmiInfo[i].strRtlNamePrefix%>_PH_IN_CHECK_LOOP
<%    if (obj.DmiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j < obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in.length; j++) { %>
          std::randomize( <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%> );
          force <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%><%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%> = <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>;
      <% } %>
      <% } else { %>
          std::randomize( <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%> );
          force <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%><%=obj.DmiInfo[i].interfaces.userPlaceInt.name%> = <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>;
      <% } %>
         repeat (10) @(posedge <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
<%    if (obj.DmiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j < obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in.length; j++) { %>
          assert(<%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%><%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%> == <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>);
          assert(<%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.dmi_unit.u_axiPlaceholder.<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%> == <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>);
      <% if (obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          assert(<%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%> == <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>);
      <% } } %>
      <% } else {  %>
          assert(<%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%><%=obj.DmiInfo[i].interfaces.userPlaceInt.name%> == <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>);
          assert(<%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.dmi_unit.u_axiPlaceholder.<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%> == <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>);
      <% if (obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          assert(<%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%> == <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>);
      <% } } %>
        @(posedge <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
      end : <%=obj.DmiInfo[i].strRtlNamePrefix%>_PH_IN_CHECK_LOOP
    end
   end : <%=obj.DmiInfo[i].strRtlNamePrefix%>_PH_IN_CHECK
<% } %>

<%    if (obj.DmiInfo[i].interfaces.userPlaceInt.params.wOut > 0) { %>
         initial begin : <%=obj.DmiInfo[i].strRtlNamePrefix%>_PH_OUT_CHECK
      if(!($test$plusargs("fsc_inject_correctable_err") || $test$plusargs("inject_uncorrectable_error")))begin 
<%    if (obj.DmiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j<obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out.length; j++) { %>
      <% if (obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].width > 1) { %>
          bit [<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].width%>-1:0] <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>;
          bit [<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].width%>-1:0] <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>_dup;
      <% } else { %>
          bit <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>;
          bit <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>_dup;
      <% } } %>
      <% } else { %>
      <% if (obj.DmiInfo[i].interfaces.userPlaceInt.params.wOut > 1) { %>
          bit [<%=obj.DmiInfo[i].interfaces.userPlaceInt.width%>-1:0] <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>;
          bit [<%=obj.DmiInfo[i].interfaces.userPlaceInt.width%>-1:0] <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>_dup;
      <% } else { %>
          bit                                                         <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>;
          bit                                                         <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>_dup;
      <% } } %>
      wait( tb_rstn === 1'b1);
      forever begin : <%=obj.DmiInfo[i].strRtlNamePrefix%>_PH_OUT_CHECK_LOOP
<%    if (obj.DmiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j < obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out.length; j++) { %>
          std::randomize( <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%> );
          force <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.dmi_unit.u_axiPlaceholder.<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%> = <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>;
        <%if (obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          repeat(<%= obj.DmiInfo[i].ResilienceInfo.nResiliencyDelay %>) @(posedge <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
          <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>_dup = <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>;
          force <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%> = <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>_dup;
        <% } %>
      <% } %>
      <% } else { %>
          std::randomize( <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%> );
          force <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.dmi_unit.u_axiPlaceholder.<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%> = <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>;
        <%if (obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          repeat(<%= obj.DmiInfo[i].ResilienceInfo.nResiliencyDelay %>) @(posedge <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
          <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>_dup = <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>;
          force <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%> = <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>_dup;
        <% } %>
      <% } %>
         repeat (10) @(posedge <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
<%    if (obj.DmiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j < obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out.length; j++) { %>
         assert(<%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%><%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%> == <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>);
      <%if (obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
//         assert(<%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=DmiInfo[i].interfaces.userPlaceInt.synonyms.out[0].name%> == <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>);
      <% } } %>
      <% } else { %>
         assert(<%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%><%=obj.DmiInfo[i].interfaces.userPlaceInt.name%> == <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>);
      <%if (obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
//         assert(<%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=DmiInfo[i].interfaces.userPlaceInt.synonyms.out[0].name%> == <%=obj.DmiInfo[i].strRtlNamePrefix%>_<%=obj.DmiInfo[i].interfaces.userPlaceInt.name%>);
      <% } } %>
         @(posedge <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
      end : <%=obj.DmiInfo[i].strRtlNamePrefix%>_PH_OUT_CHECK_LOOP
    end
   end : <%=obj.DmiInfo[i].strRtlNamePrefix%>_PH_OUT_CHECK
<% } %>
<% } %>
<% } %>

// Check DIIs
<% for (var i = 0; i<obj.DiiInfo.length; i++) { %>
<%    if (obj.DiiInfo[i].interfaces.userPlaceInt._SKIP_ == false) { %>
<%    if (obj.DiiInfo[i].interfaces.userPlaceInt.params.wIn > 0) { %>
      initial begin : <%=obj.DiiInfo[i].strRtlNamePrefix%>_PH_IN_CHECK
      if(!($test$plusargs("fsc_inject_correctable_err") || $test$plusargs("inject_uncorrectable_error")))begin 
<%    if (obj.DiiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j<obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in.length; j++) { %>
      <% if (obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].width > 1) { %>
          bit [<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].width%>-1:0] <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>;
      <% } else { %>
          bit <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>;
      <% } } %>
      <% } else { %>
      <% if (obj.DiiInfo[i].interfaces.userPlaceInt.params.wIn > 1) { %>
          bit [<%=obj.DiiInfo[i].interfaces.userPlaceInt.width%>-1:0] <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>;
      <% } else { %>
          bit <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>;
      <% } } %>
      wait( tb_rstn === 1'b1 );  // do not support reset during tests
      forever begin: <%=obj.DiiInfo[i].strRtlNamePrefix%>_PH_IN_CHECK_LOOP
<%    if (obj.DiiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j < obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in.length; j++) { %>
          std::randomize( <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%> );
          force <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%><%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%> = <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>;
      <% } %>
      <% } else { %>
          std::randomize( <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%> );
          force <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%><%=obj.DiiInfo[i].interfaces.userPlaceInt.name%> = <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>;
      <% } %>
         repeat (10) @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
<%    if (obj.DiiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j < obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in.length; j++) { %>
          assert(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%><%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%> == <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>);
          assert(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.u_dii_unit.u_axiPlaceholder.<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%> == <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>);
      <% if (obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          assert(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%> == <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.in[j].name%>);
      <% } } %>
      <% } else { %>
          assert(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%><%=obj.DiiInfo[i].interfaces.userPlaceInt.name%> == <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>);
          assert(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.u_dii_unit.u_axiPlaceholder.<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%> == <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>);
      <% if (obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          assert(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%> == <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>);
      <% } } %>
        @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
        end : <%=obj.DiiInfo[i].strRtlNamePrefix%>_PH_IN_CHECK_LOOP
      end
   end : <%=obj.DiiInfo[i].strRtlNamePrefix%>_PH_IN_CHECK
<% } %>

<%    if (obj.DiiInfo[i].interfaces.userPlaceInt.params.wOut > 0) { %>
         initial begin : <%=obj.DiiInfo[i].strRtlNamePrefix%>_PH_OUT_CHECK
      if(!($test$plusargs("fsc_inject_correctable_err") || $test$plusargs("inject_uncorrectable_error")))begin 
<%    if (obj.DiiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j<obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out.length; j++) { %>
      <% if (obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].width > 1) { %>
          bit [<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].width%>-1:0] <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>;
          bit [<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].width%>-1:0] <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>_dup;
      <% } else { %>
          bit <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>;
          bit <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>_dup;
      <% } } %>
      <% } else {%>
      <% if (obj.DiiInfo[i].interfaces.userPlaceInt.params.wOut > 1) { %>
          bit [<%=obj.DiiInfo[i].interfaces.userPlaceInt.width%>-1:0] <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>;
          bit [<%=obj.DiiInfo[i].interfaces.userPlaceInt.width%>-1:0] <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>_dup;
      <% } else { %>
          bit <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>;
          bit <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>_dup;
      <% } } %>
      wait( tb_rstn === 1'b1);
      forever begin : <%=obj.DiiInfo[i].strRtlNamePrefix%>_PH_OUT_CHECK_LOOP
<%    if (obj.DiiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j < obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out.length; j++) { %>
          std::randomize( <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%> );
          force <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.u_dii_unit.u_axiPlaceholder.<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%> = <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>;
        <% if (obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          repeat(<%= obj.DiiInfo[i].ResilienceInfo.nResiliencyDelay %>) @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
          <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>_dup = <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>;
          force <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%> = <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>_dup;
        <% } %>
      <% } %>
      <% } else { %>
          std::randomize( <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%> );
          force <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.u_dii_unit.u_axiPlaceholder.<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%> = <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>;
        <% if (obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
          repeat(<%= obj.DiiInfo[i].ResilienceInfo.nResiliencyDelay %>) @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
          <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>_dup = <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>;
          force <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%> = <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>_dup;
        <% } %>
      <% } %>
         repeat (10) @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);

<%    if (obj.DiiInfo[i].interfaces.userPlaceInt.synonymsOn == true) { %>
      <% for (var j=0; j < obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out.length; j++) { %>
         assert(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%><%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%> == <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>);
      <%if (obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
//         assert(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=DiiInfo[i].interfaces.userPlaceInt.synonyms.out[0].name%> == <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.synonyms.out[j].name%>);
      <% } } %>
      <% } else { %>
         assert(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%><%=obj.DiiInfo[i].interfaces.userPlaceInt.name%> == <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>);
      <%if (obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication) { %>
//         assert(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.dup_unit.u_axiPlaceholder.<%=DiiInfo[i].interfaces.userPlaceInt.synonyms.out[0].name%> == <%=obj.DiiInfo[i].strRtlNamePrefix%>_<%=obj.DiiInfo[i].interfaces.userPlaceInt.name%>);
      <% } } %>
         @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
      end : <%=obj.DiiInfo[i].strRtlNamePrefix%>_PH_OUT_CHECK_LOOP
    end
   end : <%=obj.DiiInfo[i].strRtlNamePrefix%>_PH_OUT_CHECK
<% } %>
<% } %>
<% } %>

endmodule : ph_connectivity_checker
<% } %>
<% } %>
`endif //  `ifndef PH_CONNECTIVITY_CHECKER_SV
