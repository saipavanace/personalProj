////////////////////////////////////////////////////////////////////////////////
//
// Generic Interface
//
////////////////////////////////////////////////////////////////////////////////

import uvm_pkg::*;

`include "uvm_macros.svh"
interface <%=obj.BlockId%>_generic_if (input clk, input rst_n);
<% var i; %>
<% var j; %>

<% if (obj.BlockId.indexOf('aiu') >= 0) { %>
<% var aiu_sizePhArray; %>
<% var aiu_userPlaceInt = []; %>
<% let isArray = Array.isArray(obj.AiuInfo[obj.Id].interfaces.userPlaceInt); %>
<% if (isArray) { %>
<%    aiu_sizePhArray  = obj.AiuInfo[obj.Id].interfaces.userPlaceInt.length; %>
<%    aiu_userPlaceInt = new Array(aiu_sizePhArray); %>
<%    for (var j=0; j<aiu_sizePhArray; j++) { %>
<%       aiu_userPlaceInt[j] = obj.AiuInfo[obj.Id].interfaces.userPlaceInt[j]; %>
<%    } %>
<% } else { %>
<%    aiu_sizePhArray = 1; %>
<%    aiu_userPlaceInt = new Array(1); %>
<%    aiu_userPlaceInt[0] = obj.AiuInfo[obj.Id].interfaces.userPlaceInt; %>
<% } %>
<% for (var idx=0; idx < aiu_sizePhArray; idx++) { 
     if (aiu_userPlaceInt[idx]._SKIP_ == false) { 
       if (aiu_userPlaceInt[idx].params.wIn > 0) {
          if (aiu_userPlaceInt[idx].synonymsOn == true) {
            for (i=0; i<aiu_userPlaceInt[idx].synonyms.in.length; i++) {
               if (aiu_userPlaceInt[idx].synonyms.in[i].width > 0) { %>
 bit [<%=aiu_userPlaceInt[idx].synonyms.in[i].width%>-1:0] <%=aiu_userPlaceInt[idx].name%><%=aiu_userPlaceInt[idx].synonyms.in[i].name%>;
<% } } %>
<% } else { %>
 bit [<%=aiu_userPlaceInt[idx].params.wIn%>-1:0] <%=aiu_userPlaceInt[idx].name%><%=aiu_userPlaceInt[idx].name%>in;
<% } %> 
 bit [<%=aiu_userPlaceInt[idx].params.wIn%>-1:0] <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_<%=aiu_userPlaceInt[idx].name%>in;
<% } %>
<%   if (aiu_userPlaceInt[idx].params.wOut > 0) { 
        if (aiu_userPlaceInt[idx].synonymsOn == true) {
           for (i=0; i<aiu_userPlaceInt[idx].synonyms.out.length; i++) {
              if (aiu_userPlaceInt[idx].synonyms.out[i].width > 0) { %>
 bit [<%=aiu_userPlaceInt[idx].synonyms.out[i].width%>-1:0] <%=aiu_userPlaceInt[idx].name%><%=aiu_userPlaceInt[idx].synonyms.out[i].name%>;
<% } } %>
<% } else { %>
 bit [<%=aiu_userPlaceInt[idx].params.wOut%>-1:0] <%=aiu_userPlaceInt[idx].name%><%=aiu_userPlaceInt[idx].name%>out;
<% } %>
 bit [<%=aiu_userPlaceInt[idx].params.wOut%>-1:0] <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_<%=aiu_userPlaceInt[idx].name%>out;
<% } } %>
<% } %>
<% if (typeof obj.AiuInfo[obj.Id].interfaces.memoryInt !== 'undefined') { %>
// MEMORY: name=<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%> Size=<%=obj.AiuInfo[obj.Id].interfaces.memoryInt.length%>
<%     for (i=0; i<obj.AiuInfo[obj.Id].interfaces.memoryInt.length; i++) { %>
<%         if (obj.AiuInfo[obj.Id].interfaces.memoryInt[i]._SKIP_ === false) { %>
<%            if (obj.AiuInfo[obj.Id].interfaces.memoryInt[i].params.wIn > 0) { %>
<%               if (obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonymsOn == true) { %>
<%                  for (j=0; j<obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.in.length; j++) { %>
<%                     if (typeof obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j] !== 'undefined') { %>
<%                        if (obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width > 1) {%>
             bit [<%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width%>-1:0] <%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].name%>;
<%                           } else if (obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width > 0) {%>
             bit                                                       <%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].name%>;
<%                           } %>
<%                       } }  %>
<%                    } else {
                         if (obj.AiuInfo[obj.Id].interfaces.memoryInt[i].params.wIn > 1) { %>
             bit [<%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].params.wIn%>-1:0] <%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].name%>in;
<%                       } else { %>
             bit                                                      <%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].name%>in;
<%                   } } %>
<%               } %>
<%            if (obj.AiuInfo[obj.Id].interfaces.memoryInt[i].params.wOut > 0) {
                 if (obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonymsOn == true) {
                     for (j=0; j<obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.out.length; j++) {
                        if (obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width > 1) {%>
             bit [<%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width%>-1:0] <%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].name%>;
<%                      } else if (obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width > 0) {%>
             bit                                                        <%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].name%>;
<%                   } } %>
<%               } else {
                    if (obj.AiuInfo[obj.Id].interfaces.memoryInt[i].params.wOut > 1) { %>
             bit [<%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].params.wIn%>-1:0] <%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].name%>out;
<%                  } else { %>
             bit                                                       <%=obj.AiuInfo[obj.Id].interfaces.memoryInt[i].name%>out;
<%         } } %>
<% } } %>
<% } } %>
<% } %>
<% if (obj.BlockId.indexOf("dii") >= 0) {
     if (obj.DiiInfo[obj.Id].interfaces.userPlaceInt._SKIP_ === false) {
       if (obj.DiiInfo[obj.Id].interfaces.userPlaceInt.params.wIn > 0) { 
          if (obj.DiiInfo[obj.Id].interfaces.userPlaceInt.synonymsOn == true) {
            for (i=0; i<obj.DiiInfo[obj.Id].interfaces.userPlaceInt.synonyms.in.length; i++) {
               if (obj.DiiInfo[obj.Id].interfaces.userPlaceInt.synonyms.in[i].width > 0) { %>
bit [<%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.synonyms.in[i].width%>-1:0] <%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.name%><%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.synonyms.in[i].name%>;
<% }  %>
<% } } else { %>
 bit [<%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.params.wIn%>-1:0] <%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.name%><%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.in%>;
<% } %>
 bit [<%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.params.wIn%>-1:0] in;
<% } %>
<%   if (obj.DiiInfo[obj.Id].interfaces.userPlaceInt.params.wOut > 0) { 
        if (obj.DiiInfo[obj.Id].interfaces.userPlaceInt.synonymsOn == true) {
           for (j=0; j<obj.DiiInfo[obj.Id].interfaces.userPlaceInt.synonyms.out.length; j++) {
              if (obj.DiiInfo[obj.Id].interfaces.userPlaceInt.synonyms.out[j].width > 0) { %>
 bit [<%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.synonyms.out[j].width%>-1:0] <%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.name%><%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.synonyms.out[j].name%>;
<% } %>
<% } } else { %>
 bit [<%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.params.wOut%>-1:0] <%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.name%><%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.out%>;
<% } %>
 bit  [<%=obj.DiiInfo[obj.Id].interfaces.userPlaceInt.params.wOut%>-1:0] out;
<% } } %>
<%   if (typeof obj.DiiInfo[obj.Id].interfaces.memoryInt !== 'undefined' ) { %>
<%   for (i=0; i<obj.DiiInfo[obj.Id].interfaces.memoryInt.length; i++) {
       if (obj.DiiInfo[obj.Id].interfaces.memoryInt[i]._SKIP_ === false) {
          if (obj.DiiInfo[obj.Id].interfaces.memoryInt[i].params.wIn > 0) {
            if (obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonymsOn == true) {
               for (j=0; j<obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in.length; j++) {
                   if (obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width > 1) {%>
             bit [<%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width%>-1:0] <%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].name%>;
<% } else if (obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width > 0) {%>
             bit                                                                             <%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].name%>;
<% } } %>
<% } else {
     if (obj.DiiInfo[obj.Id].interfaces.memoryInt[i].params.wIn > 1) { %>
              bit [<%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].params.wIn%>-1:0] <%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].name%>in;
<% } else { %>
              bit                                                                   <%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].name%>in;
<% } } %>
<% } %>
<% if (obj.DiiInfo[obj.Id].interfaces.memoryInt[i].params.wOut > 0)
      if (obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonymsOn == true) {
         for (j=0; j<obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out.length; j++)
             if (obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width > 1) {%>
             bit [<%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width%>-1:0] <%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].name%>;
<% } else if (obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width > 0) {%>
             bit                                                                              <%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].name%>;
<% } %>
<% } else {
     if (obj.DiiInfo[obj.Id].interfaces.memoryInt[i].params.wOut > 1) { %>
              bit [<%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].params.wIn%>-1:0] <%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].name%>out;
<% } else { %>
              bit                                                                   <%=obj.DiiInfo[obj.Id].interfaces.memoryInt[i].name%>out;
<% } } %>
<% } } %>
<% } %>
<% } %>
<% if (obj.BlockId.indexOf("dmi") >= 0) {
     if (obj.DmiInfo[obj.Id].interfaces.userPlaceInt._SKIP_ === false) {
        if (obj.DmiInfo[obj.Id].interfaces.userPlaceInt.params.wIn > 0) { 
           if (obj.DmiInfo[obj.Id].interfaces.userPlaceInt.synonymsOn == true) {
             for (i=0; i<obj.DmiInfo[obj.Id].interfaces.userPlaceInt.synonyms.in.length; i++) {
                if (obj.DmiInfo[obj.Id].interfaces.userPlaceInt.synonyms.in[i].width > 0) { %>
bit [<%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.synonyms.in[i].width%>-1:0] <%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.name%><%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.synonyms.in[i].name%>;
<% } } %>
<% } else { %>
 bit [<%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.params.wIn%>-1:0] <%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.name%><%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.in%>;
<% } %>
 bit [<%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.params.wIn%>-1:0] in;
<% } %>
<%   if (obj.DmiInfo[obj.Id].interfaces.userPlaceInt.params.wOut > 0) { 
        if (obj.DmiInfo[obj.Id].interfaces.userPlaceInt.synonymsOn == true) {
           for (i=0; i<obj.DmiInfo[obj.Id].interfaces.userPlaceInt.synonyms.out.length; i++) {
              if (obj.DmiInfo[obj.Id].interfaces.userPlaceInt.synonyms.out[i].width > 0) { %>
 bit [<%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.synonyms.out[i].width%>-1:0] <%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.name%><%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.synonyms.out[i].name%>;
<% } } %>
<% } else { %>
 bit [<%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.params.wOut%>-1:0] <%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.name%><%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.out%>;
<% } %>
 bit  [<%=obj.DmiInfo[obj.Id].interfaces.userPlaceInt.params.wOut%>-1:0] out;
<% } } %>
<%   if (typeof obj.DmiInfo[obj.Id].interfaces.memoryInt !== 'undefined' ) { %>
<%   for (i=0; i<obj.DmiInfo[obj.Id].interfaces.memoryInt.length; i++) {
       if (obj.DmiInfo[obj.Id].interfaces.memoryInt[i]._SKIP_ === false) {
          if (obj.DmiInfo[obj.Id].interfaces.memoryInt[i].params.wIn > 0) {
            if (obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonymsOn == true) {
               for (j=0; j<obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in.length; j++)
                   if (obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width > 1) {%>
             bit [<%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width%>-1:0] <%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].name%>;
<% } else if (obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width > 0) {%>
             bit                                                                             <%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].name%>;
<% } %>
<% } else {
     if (obj.DmiInfo[obj.Id].interfaces.memoryInt[i].params.wIn > 1) { %>
              bit [<%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].params.wIn%>-1:0] <%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].name%>in;
<% } else { %>
              bit                                                                   <%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].name%>in;
<% } } } %>
<% if (obj.DmiInfo[obj.Id].interfaces.memoryInt[i].params.wOut > 0)
        if (obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonymsOn == true) {
           for (j=0; j<obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out.length; j++)
               if (obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width > 1) {%>
             bit [<%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width%>-1:0] <%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].name%>;
<% } else if (obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width > 0) {%>
             bit                                                                              <%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].name%>;
<% } %>
<% } else {
     if (obj.DmiInfo[obj.Id].interfaces.memoryInt[i].params.wOut > 1) { %>
              bit [<%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].params.wIn%>-1:0] <%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].name%>out;
<% } else { %>
              bit                                                                   <%=obj.DmiInfo[obj.Id].interfaces.memoryInt[i].name%>out;
<% } } %>
<% } } %>
<% } } %>
<% if (obj.BlockId.indexOf("dce") >= 0) {%>
<%   if (typeof obj.DceInfo[obj.Id].interfaces.memoryInt !== 'undefined' ) { %>
<%   for (i=0; i<obj.DceInfo[obj.Id].interfaces.memoryInt.length; i++) {
       if (obj.DceInfo[obj.Id].interfaces.memoryInt[i]._SKIP_ === false) {
          if (obj.DceInfo[obj.Id].interfaces.memoryInt[i].params.wIn > 0) {
            if (obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonymsOn == true) {
               for (j=0; j<obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.in.length; j++)
                   if (obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width > 1) {%>
             bit [<%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width%>-1:0] <%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].name%>;
<% } else if (obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width > 0) {%>
             bit                                                                             <%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].name%>;
<% } %>
<% } else {
     if (obj.DceInfo[obj.Id].interfaces.memoryInt[i].params.wIn > 1) { %>
              bit [<%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].params.wIn%>-1:0] <%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].name%>in;
<% } else { %>
              bit                                                                   <%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].name%>in;
<% } } } %>
<% if (obj.DceInfo[obj.Id].interfaces.memoryInt[i].params.wOut > 0)
      if (obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonymsOn == true) {
         for (j=0; j<obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.out.length; j++)
             if (obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width > 1) {%>
             bit [<%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width%>-1:0] <%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].name%>;
<% } else if (obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width > 0) {%>
             bit                                                                              <%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].name%>;
<% } %>
<% } else {
     if (obj.DceInfo[obj.Id].interfaces.memoryInt[i].params.wOut > 1) { %>
              bit [<%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].params.wIn%>-1:0] <%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].name%>out;
<% } else { %>
              bit                                                                   <%=obj.DceInfo[obj.Id].interfaces.memoryInt[i].name%>out;
<% } } %>
<% } } %>
<% } } %>
<% if (obj.BlockId.indexOf("dve") >= 0) {%>
<%   if (typeof obj.DveInfo[obj.Id].interfaces.memoryInt !== 'undefined' ) { %>
<%   for (i=0; i<obj.DveInfo[obj.Id].interfaces.memoryInt.length; i++) {
       if (obj.DveInfo[obj.Id].interfaces.memoryInt[i]._SKIP_ === false) {
          if (obj.DveInfo[obj.Id].interfaces.memoryInt[i].params.wIn > 0) {
            if (obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonymsOn == true) {
               for (j=0; j<obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.in.length; j++)
                   if (obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width > 1) {%>
             bit [<%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width%>-1:0] <%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].name%>;
<% } else if (obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].width > 0) {%>
             bit                                                                             <%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.in[j].name%>;
<% } %>
<% } else {
     if (obj.DveInfo[obj.Id].interfaces.memoryInt[i].params.wIn > 1) { %>
              bit [<%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].params.wIn%>-1:0] <%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].name%>in;
<% } else { %>
              bit                                                                   <%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].name%>in;
<% } } } %>
<%   if (obj.DveInfo[obj.Id].interfaces.memoryInt[i].params.wOut > 0)
        if (obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonymsOn == true) {
           for (j=0; j<obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.out.length; j++)
               if (obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width > 1) {%>
             bit [<%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width%>-1:0] <%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].name%>;
<% } else if (obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].width > 0) {%>
             bit                                                                              <%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].name%><%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].synonyms.out[j].name%>;
<% } %>
<% } else {
     if (obj.DveInfo[obj.Id].interfaces.memoryInt[i].params.wOut > 1) { %>
              bit [<%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].params.wIn%>-1:0] <%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].name%>out;
<% } else { %>
              bit                                                                   <%=obj.DveInfo[obj.Id].interfaces.memoryInt[i].name%>out;
<% } } %>
<% } } %>
<% } } %>
endinterface //<%=obj.BlockId%>_generic_if (input clk, input rst_n);
