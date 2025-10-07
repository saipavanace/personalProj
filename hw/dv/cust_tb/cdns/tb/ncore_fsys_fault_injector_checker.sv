/****************************************************************************************************************************
*                                                                                                                           *
* this module checkes uncorr error injection at full sys, 
* all fsys module signal forced to inject errror and mission fault is observed.
* Once mission fault check completes, Bist automatic/manual seq runs to clear fault
*                                                                                                                           *
* File    : fsys_fault_injector_checker.sv                                                                                  *
* Version : 0.1                                                                                                             *                                       
* Author  : Kruna Patel                                                                                                     *                                    
* Confluence page links  :                                                                                                  *
*                                                                                                                           *
*                                                                                                                           *                         
****************************************************************************************************************************/
  <%  
     var clocks = [];
  
     for(var clock=0; clock < obj.Clocks.length; clock++) {
      var clk_name = obj.Clocks[clock].name;
      var name_len = clk_name.length;
      var mod_name;
      if(clk_name[name_len-1] == '_') {  // remove if last character is '_'
          mod_name = clk_name.substr(0, name_len-1);
      } else {
          mod_name = clk_name;
      }
      clocks[clock] = mod_name;

      var cnt_multi = 17000; 
   }%>

`ifndef FSYS_FAULT_INJECTOR_CHECKER_SV
`define FSYS_FAULT_INJECTOR_CHECKER_SV

<% if (obj.useResiliency) { %>
module fsys_fault_injector_checker(

   <% for(var clock=0; clock < clocks.length; clock++) { %>
   <% if (obj.Clocks[clock].name.includes("_check") == false){ %>
  input <%=obj.Clocks[clock].name%>clk,
  <% } %>  
   <% } %>
  input tb_rstn);
  import uvm_pkg::*;
  `include "uvm_macros.svh"


   <% var hier_path_dut = ['tb_top.u_chip']; %>
   
   //Inject uncorr error at fullsys.
   initial begin
     bit [31:0] fsc_loop_cnt  = <%=obj.AiuInfo.length+
                                   obj.DceInfo.length+
                                   obj.DmiInfo.length+
                                   obj.DveInfo.length+
                                   obj.DiiInfo.length%>;


     uvm_config_db#(bit [31:0])::set(uvm_root::get(),"","fsc_loop_cnt",fsc_loop_cnt);

     if ($test$plusargs("inject_uncorrectable_error")) begin
       @(posedge tb_rstn);
	   <%if(1 == 0){%>
		  // FIXME: The below code can be optimized to remove the if condition by using a function - Sai
	   <%}%>
       <% for (var i = 0; i<obj.DceInfo.length; i++) { %>
           //DCE<%=i%>
           repeat(<%=cnt_multi%>)@(posedge <%=obj.DceInfo[i].unitClk[0]%>clk);
		   <%if(obj.DceInfo[i].hierPath && obj.DceInfo[i].hierPath !== ''){%>
    	       	force   <%=hier_path_dut%>.<%=obj.DceInfo[i].hierPath%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.u_dce_fault_checker.func_0_fault_in = 1'b1;
	           	@(posedge <%=obj.DceInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=obj.DceInfo[i].hierPath%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.u_dce_fault_checker.func_0_fault_in;
		   <%}else{%>
    	       	force   <%=hier_path_dut%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.u_dce_fault_checker.func_0_fault_in = 1'b1;
	           	@(posedge <%=obj.DceInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.u_dce_fault_checker.func_0_fault_in;
		   <%}%>
           repeat(20)@(posedge <%=obj.DceInfo[i].unitClk[0]%>clk);
       <% } %>

       <% for (var i = 0; i<obj.DmiInfo.length; i++) { %>
           //DMI<%=i%>
           repeat(<%=cnt_multi%>)@(posedge <%=obj.DmiInfo[i].unitClk[0]%>clk);

		   <%if(obj.DmiInfo[i].hierPath  && obj.DmiInfo[i].hierPath !== ''){%>
           		force   <%=hier_path_dut%>.<%=obj.DmiInfo[i].hierPath%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.u_dmi_fault_checker.func_0_fault_in = 1'b1;
	            @(posedge <%=obj.DmiInfo[i].unitClk[0]%>clk);
     	        release <%=hier_path_dut%>.<%=obj.DmiInfo[i].hierPath%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.u_dmi_fault_checker.func_0_fault_in;
		   <%}else{%>
           		force   <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.u_dmi_fault_checker.func_0_fault_in = 1'b1;
	            @(posedge <%=obj.DmiInfo[i].unitClk[0]%>clk);
     	        release <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.u_dmi_fault_checker.func_0_fault_in;
		   <%}%>
           repeat(20)@(posedge <%=obj.DmiInfo[i].unitClk[0]%>clk);
       <% } %>



       <% for (var i = 0; i<obj.DveInfo.length; i++) { %>
           //DVE<%=i%>
           repeat(<%=cnt_multi%>)@(posedge <%=obj.DveInfo[i].unitClk[0]%>clk);

		   <%if(obj.DveInfo[i].hierPath && obj.DveInfo[i].hierPath !== ''){%>
    	       	force   <%=hier_path_dut%>.<%=obj.DveInfo[i].hierPath%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.u_fault_checker.func_0_fault_in = 1'b1;
	           	@(posedge <%=obj.DveInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=obj.DveInfo[i].hierPath%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.u_fault_checker.func_0_fault_in;
		   <%}else{%>
    	       	force   <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.u_fault_checker.func_0_fault_in = 1'b1;
	           	@(posedge <%=obj.DveInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.u_fault_checker.func_0_fault_in;
		   <%}%>
           repeat(20)@(posedge <%=obj.DveInfo[i].unitClk[0]%>clk);
       <% } %>




       <% for (var i = 0; i<obj.DiiInfo.length; i++) { %>
           //DII<%=i%>  
           repeat(<%=cnt_multi%>)@(posedge <%=obj.DiiInfo[i].unitClk[0]%>clk);

		   <%if(obj.DiiInfo[i].hierPath && obj.DiiInfo[i].hierPath !== ''){%>
           		force   <%=hier_path_dut%>.<%=obj.DiiInfo[i].hierPath%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.u_dii_fault_checker.func_0_fault_in = 1'b1;
           		@(posedge <%=obj.DiiInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=obj.DiiInfo[i].hierPath%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.u_dii_fault_checker.func_0_fault_in;
		   <%}else{%>
           		force   <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.u_dii_fault_checker.func_0_fault_in = 1'b1;
           		@(posedge <%=obj.DiiInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.u_dii_fault_checker.func_0_fault_in;
		   <%}%>
           repeat(20)@(posedge <%=obj.DiiInfo[i].unitClk[0]%>clk);
       <% } %>

       <% for (var i = 0; i<(obj.AiuInfo.length); i++) { %>
       <% if ((obj.AiuInfo[i].fnNativeInterface == "CHI-A") || (obj.AiuInfo[i].fnNativeInterface == "CHI-B")||(obj.AiuInfo[i].fnNativeInterface == "CHI-E") ) { %>
           //CHi<%=i%>
	   	   repeat(<%=cnt_multi%>)@(posedge <%=obj.AiuInfo[i].nativeClk%>clk);
           <%if(obj.AiuInfo[i].hierPath && obj.AiuInfo[i].hierPath !== ''){%>
                force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].hierPath%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.u_chi_aiu_fault_checker.func_0_fault_in = 1'b1;
                @(posedge <%=obj.AiuInfo[i].nativeClk%>clk);
                release <%=hier_path_dut%>.<%=obj.AiuInfo[i].hierPath%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.u_chi_aiu_fault_checker.func_0_fault_in;
           <%} else {%>
                force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.u_chi_aiu_fault_checker.func_0_fault_in = 1'b1;
                @(posedge <%=obj.AiuInfo[i].nativeClk%>clk);
                release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.u_chi_aiu_fault_checker.func_0_fault_in;
           <%}%>
           repeat(20)@(posedge <%=obj.AiuInfo[i].nativeClk%>clk);
         <% } else {%>
	   //IO<%=i%>
           repeat(<%=cnt_multi%>)@(posedge <%=obj.AiuInfo[i].nativeClk%>clk);
            <%if(obj.AiuInfo[i].hierPath && obj.AiuInfo[i].hierPath !== ''){%>
                force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].hierPath%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_checker.func_0_fault_in = 1'b1;
                @(posedge <%=obj.AiuInfo[i].nativeClk%>clk);
                release <%=hier_path_dut%>.<%=obj.AiuInfo[i].hierPath%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_checker.func_0_fault_in;
            <%}else{%>
                force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_checker.func_0_fault_in = 1'b1;
                @(posedge <%=obj.AiuInfo[i].nativeClk%>clk);
                release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_checker.func_0_fault_in;
            <%}%>
            repeat(20)@(posedge <%=obj.AiuInfo[i].nativeClk%>clk);
         <% } %>
       <% } %>
     end
   end
   
 endmodule: fsys_fault_injector_checker

<% } %>
`endif
