//////////////////////////TB_  mem_wrapper_if ////////////////////////
//DUT interfaces
//////////////////////////////////////////////////////////////////

`ifndef mem_wrapper_if
 `define mem_wrapper_if

import uvm_pkt::*;
`include "uvm_macros.svh"

<% { %>
<% var i, j, k; %>

<% for (i=0; i<obj.AiuInfo.length; i++) { %>
interface <%=obj.AiuInfo[i].strRtlNamePrefix>_mem_wrapper_if (input clk, input rst_n);
<% if (typeof obj.AiuInfo[i].interfaces.memoryInt !== 'undefined') { %>
<%    for (i=j; j<obj.AiuInfo[i].interfaces.memoryInt.length; j++) { %>
<%       if (obj.AiuInfo[i].interfaces.memoryInt[j]._SKIP === false) { %>
<%          if (obj.AiuInfo[i].interfaces.memoryInt[j].params.wIn > 0) { %>
<%             if (obj.AiuInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%               for (k=0; k<obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.in.length; k++) { %>
<%                  if (obj.AiuInfo[i].interfaces.memoryInt[j].sysnonyms.in[k].width > 1) {%>
         logic [<%=obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.in[k].width%>-1:0] <%=obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.in[k].name%>;
<%                  } else if (obj.AiuInfo[i].interfaces.memoryInt[i].sysnonyms.in[k].width > 0) { %>
         logic                                                                        <%=obj.AiuInfo[i].interfaces.memoryInt[j].synonyms.in[k].name%>;
<% } }  %>
<% } else { %>
<%             if (obj.AiuInfo[i].interfaces.memoryInt[j].wIn > 1) { %>
         logic [<%=obj.AiuInfo[i].interfaces.memoryInt[j].wIn%>-1:0] <%=obj.AiuInfo[i].interfaces.memoryInt[j].name%>;
<% } else { %>
         logic                                                       <%=obj.AiuInfo[i].interfaces.memoryInt[j].name%>;
<% } } %>
<% } } %>
<% } } %>
endinterface : <%=obj.AiuInfo[i].strRtlNamePrefix>_mem_wrapper_if
<% } %>

<% for (i=0; i<obj.DmiInfo.length; i++) { %>
interface <%=obj.DmiInfo[i].strRtlNamePrefix>_mem_wrapper_if (input clk, input rst_n);
<% if (typeof obj.DmiInfo[i].interfaces.memoryInt !== 'undefined') { %>
<%    for (i=j; j<obj.DmiInfo[i].interfaces.memoryInt.length; j++) { %>
<%       if (obj.DmiInfo[i].interfaces.memoryInt[j]._SKIP === false) { %>
<%          if (obj.DmiInfo[i].interfaces.memoryInt[j].params.wIn > 0) { %>
<%             if (obj.DmiInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%               for (k=0; k<obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.in.length; k++) { %>
<%                  if (obj.DmiInfo[i].interfaces.memoryInt[j].sysnonyms.in[k].width > 1) {%>
         logic [<%=obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.in[k].width%>-1:0] <%=obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.in[k].name%>;
<%                  } else if (obj.DmiInfo[i].interfaces.memoryInt[i].sysnonyms.in[k].width > 0) { %>
         logic                                                                        <%=obj.DmiInfo[i].interfaces.memoryInt[j].synonyms.in[k].name%>;
<% } }  %>
<% } else { %>
<%             if (obj.DmiInfo[i].interfaces.memoryInt[j].wIn > 1) { %>
         logic [<%=obj.DmiInfo[i].interfaces.memoryInt[j].wIn%>-1:0] <%=obj.DmiInfo[i].interfaces.memoryInt[j].name%>;
<% } else { %>
         logic                                                       <%=obj.DmiInfo[i].interfaces.memoryInt[j].name%>;
<% } } %>
<% } } %>
<% } } %>
endinterface : <%=obj.DmiInfo[i].strRtlNamePrefix>_mem_wrapper_if
<% } %>

<% for (i=0; i<obj.DceInfo.length; i++) { %>
interface <%=obj.DceInfo[i].strRtlNamePrefix>_mem_wrapper_if (input clk, input rst_n);
<% if (typeof obj.DceInfo[i].interfaces.memoryInt !== 'undefined') { %>
<%    for (i=j; j<obj.DceInfo[i].interfaces.memoryInt.length; j++) { %>
<%       if (obj.DceInfo[i].interfaces.memoryInt[j]._SKIP === false) { %>
<%          if (obj.DceInfo[i].interfaces.memoryInt[j].params.wIn > 0) { %>
<%             if (obj.DceInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%               for (k=0; k<obj.DceInfo[i].interfaces.memoryInt[j].synonyms.in.length; k++) { %>
<%                  if (obj.DceInfo[i].interfaces.memoryInt[j].sysnonyms.in[k].width > 1) {%>
         logic [<%=obj.DceInfo[i].interfaces.memoryInt[j].synonyms.in[k].width%>-1:0] <%=obj.DceInfo[i].interfaces.memoryInt[j].synonyms.in[k].name%>;
<%                  } else if (obj.DceInfo[i].interfaces.memoryInt[i].sysnonyms.in[k].width > 0) { %>
         logic                                                                        <%=obj.DceInfo[i].interfaces.memoryInt[j].synonyms.in[k].name%>;
<% } }  %>
<% } else { %>
<%             if (obj.DceInfo[i].interfaces.memoryInt[j].wIn > 1) { %>
         logic [<%=obj.DceInfo[i].interfaces.memoryInt[j].wIn%>-1:0] <%=obj.DceInfo[i].interfaces.memoryInt[j].name%>;
<% } else { %>
         logic                                                       <%=obj.DceInfo[i].interfaces.memoryInt[j].name%>;
<% } } %>
<% } } %>
<% } } %>
endinterface : <%=obj.DceInfo[i].strRtlNamePrefix>_mem_wrapper_if
<% } %>

<% for (i=0; i<obj.DveInfo.length; i++) { %>
interface <%=obj.DveInfo[i].strRtlNamePrefix>_mem_wrapper_if (input clk, input rst_n);
<% if (typeof obj.DveInfo[i].interfaces.memoryInt !== 'undefined') { %>
<%    for (i=j; j<obj.DveInfo[i].interfaces.memoryInt.length; j++) { %>
<%       if (obj.DveInfo[i].interfaces.memoryInt[j]._SKIP === false) { %>
<%          if (obj.DveInfo[i].interfaces.memoryInt[j].params.wIn > 0) { %>
<%             if (obj.DveInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%               for (k=0; k<obj.DveInfo[i].interfaces.memoryInt[j].synonyms.in.length; k++) { %>
<%                  if (obj.DveInfo[i].interfaces.memoryInt[j].sysnonyms.in[k].width > 1) {%>
         logic [<%=obj.DveInfo[i].interfaces.memoryInt[j].synonyms.in[k].width%>-1:0] <%=obj.DveInfo[i].interfaces.memoryInt[j].synonyms.in[k].name%>;
<%                  } else if (obj.DveInfo[i].interfaces.memoryInt[i].sysnonyms.in[k].width > 0) { %>
         logic                                                                        <%=obj.DveInfo[i].interfaces.memoryInt[j].synonyms.in[k].name%>;
<% } }  %>
<% } else { %>
<%             if (obj.DveInfo[i].interfaces.memoryInt[j].wIn > 1) { %>
         logic [<%=obj.DveInfo[i].interfaces.memoryInt[j].wIn%>-1:0] <%=obj.DveInfo[i].interfaces.memoryInt[j].name%>;
<% } else { %>
         logic                                                       <%=obj.DveInfo[i].interfaces.memoryInt[j].name%>;
<% } } %>
<% } } %>
<% } } %>
endinterface : <%=obj.DveInfo[i].strRtlNamePrefix>_mem_wrapper_if
<% } %>

<% for (i=0; i<obj.DiiInfo.length; i++) { %>
interface <%=obj.DiiInfo[i].strRtlNamePrefix>_mem_wrapper_if (input clk, input rst_n);
<% if (typeof obj.DiiInfo[i].interfaces.memoryInt !== 'undefined') { %>
<%    for (i=j; j<obj.DiiInfo[i].interfaces.memoryInt.length; j++) { %>
<%       if (obj.DiiInfo[i].interfaces.memoryInt[j]._SKIP === false) { %>
<%          if (obj.DiiInfo[i].interfaces.memoryInt[j].params.wIn > 0) { %>
<%             if (obj.DiiInfo[i].interfaces.memoryInt[j].synonymsOn === true) { %>
<%               for (k=0; k<obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.in.length; k++) { %>
<%                  if (obj.DiiInfo[i].interfaces.memoryInt[j].sysnonyms.in[k].width > 1) {%>
         logic [<%=obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.in[k].width%>-1:0] <%=obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.in[k].name%>;
<%                  } else if (obj.DiiInfo[i].interfaces.memoryInt[i].sysnonyms.in[k].width > 0) { %>
         logic                                                                        <%=obj.DiiInfo[i].interfaces.memoryInt[j].synonyms.in[k].name%>;
<% } }  %>
<% } else { %>
<%             if (obj.DiiInfo[i].interfaces.memoryInt[j].wIn > 1) { %>
         logic [<%=obj.DiiInfo[i].interfaces.memoryInt[j].wIn%>-1:0] <%=obj.DiiInfo[i].interfaces.memoryInt[j].name%>;
<% } else { %>
         logic                                                       <%=obj.DiiInfo[i].interfaces.memoryInt[j].name%>;
<% } } %>
<% } } %>
<% } } %>
endinterface : <%=obj.DiiInfo[i].strRtlNamePrefix>_mem_wrapper_if
<% } %>

<% } %>
`endif

