class dmi_reg extends uvm_sequence_item;

   <% var dmi_csr_params = obj.CsrDef %>
   <% var reg_base_addr = dmi_csr_params.wCsrRegOffset * Math.pow(2,dmi_csr_params.wCsrRegNum); %>
			   
  `uvm_object_utils(dmi_reg)

   string        reg_name[string];
   int           reg_addr[string];
   bit [31:0] 	 reg_reset[string];
   string        reg_access[string];
   int           reg_lsb[string];
   int           reg_msb[string];
   string        reg_rsvd[string];
   bit           reg_hasalias[string];
   string        reg_aliasname[string];
   string        reg_alias[string];   
   function new(string name = "dmi_reg");
      super.new(name);
      <% for(var reg_name in dmi_csr_params.CsrInfo) { %>
	<% if( dmi_csr_params.CsrInfo[reg_name].PageLo == "0xC0" ) { %>	
       //only add DCE registers
        reg_name["<%=reg_name%>"] = "<%=reg_name%>";
	reg_addr["<%=reg_name%>"] = <%=(dmi_csr_params.wCsrData)%>'h<%=((parseInt(dmi_csr_params.CsrInfo[reg_name].RegNumLo) + (parseInt(dmi_csr_params.CsrInfo[reg_name].PageLo) << dmi_csr_params.wCsrRegNum)) << dmi_csr_params.wCsrRegOffset).toString(16) %>;

	reg_reset["<%=reg_name%>"]  = <%if(/.[xX]{2,}/.test(dmi_csr_params.CsrInfo[reg_name].Reset)) { %> <%=dmi_csr_params.wCsrData%>'hDEADBEEF <% } else if((reg_name == "CMIUIDR_ImplVer") || (reg_name == "CMIUIDR_CmiId")) { %> 0 <%} else {%> <%=parseInt(dmi_csr_params.CsrInfo[reg_name].Reset)%> <% }%>;
	reg_access["<%=reg_name%>"] = "<%=dmi_csr_params.CsrInfo[reg_name].Access%>" ;
	reg_lsb["<%=reg_name%>"] = <%=dmi_csr_params.CsrInfo[reg_name].LSB%>;
	reg_msb["<%=reg_name%>"] = <%=dmi_csr_params.CsrInfo[reg_name].MSB%>;
	reg_rsvd["<%=reg_name%>"] = <%if(reg_name == /.*_Rsvd/) { %> "RSVD" <% } else { %> "NOTRSVD" <% } %>; //DC_DEBUG look at this later
	reg_hasalias["<%=reg_name%>"] = <%if (dmi_csr_params.CsrInfo[reg_name].Alias != 'None') { %> 1 <% } else { %> 0 <% } %>  ; //DC_DEBUG Change this when Satya does
	reg_aliasname["<%=reg_name%>"] = <%if (dmi_csr_params.CsrInfo[reg_name].Alias != 'None') { %> "<%=dmi_csr_params.CsrInfo[reg_name].Alias%>" <% } else { %> "NaN" <% } %> ;
	reg_alias["<%=reg_name%>"] = <%if (dmi_csr_params.CsrInfo[reg_name].Alias != 'None') { %> "<%=dmi_csr_params.CsrInfo[reg_name].Alias%>" <% } else { %> "NaN" <% } %> ;	   
      <% } %>
      <% } %>
   endfunction :new 
endclass:dmi_reg 
