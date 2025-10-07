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
<%const chipletObj = obj.lib.getAllChipletRefs();%>

  <%  
     var clocks = [];
  
     for(var clock=0; clock < chipletObj[0].Clocks.length; clock++) {
      var clk_name = chipletObj[0].Clocks[clock].name;
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

<% if (chipletObj[0].useResiliency) { %>
module fsys_fault_injector_checker(

  <% for(var clock=0; clock < clocks.length; clock++) { %>
     <% if (chipletObj[0].Clocks[clock].name.includes("_check") == false){ %>
        input <%=chipletObj[0].Clocks[clock].name%>clk,
     <% } %>  
  <% } %>
  input tb_rstn);
  import uvm_pkg::*;
  `include "uvm_macros.svh"


   <% var hier_path_dut = ['ncore_system_tb_top.u_chip']; %>
   
   //Inject uncorr error at fullsys.
   initial begin
     bit [31:0] fsc_loop_cnt  = <%=chipletObj[0].AiuInfo.length+
                                   chipletObj[0].DceInfo.length+
                                   chipletObj[0].DmiInfo.length+
                                   chipletObj[0].DveInfo.length+
                                   chipletObj[0].DiiInfo.length%>;


     uvm_config_db#(bit [31:0])::set(uvm_root::get(),"","fsc_loop_cnt",fsc_loop_cnt);

     if ($test$plusargs("inject_uncorrectable_error")) begin
       @(posedge tb_rstn);
	   <%if(1 == 0){%>
		  // FIXME: The below code can be optimized to remove the if condition by using a function - Sai
	   <%}%>
       <% for (var i = 0; i<chipletObj[0].DceInfo.length; i++) { %>
           //DCE<%=i%>
           repeat(<%=cnt_multi%>)@(posedge <%=chipletObj[0].DceInfo[i].unitClk[0]%>clk);
		   <%if(chipletObj[0].DceInfo[i].hierPath && chipletObj[0].DceInfo[i].hierPath !== ''){%>
    	       	force   <%=hier_path_dut%>.<%=chipletObj[0].DceInfo[i].instancePath%>.u_dce_fault_checker.func_0_fault_in = 1'b1;
	           	@(posedge <%=chipletObj[0].DceInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=chipletObj[0].DceInfo[i].instancePath%>.u_dce_fault_checker.func_0_fault_in;
		   <%}else{%>
    	       	force   <%=hier_path_dut%>.<%=chipletObj[0].DceInfo[i].strRtlNamePrefix%>.u_dce_fault_checker.func_0_fault_in = 1'b1;
	           	@(posedge <%=chipletObj[0].DceInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=chipletObj[0].DceInfo[i].strRtlNamePrefix%>.u_dce_fault_checker.func_0_fault_in;
		   <%}%>
           repeat(20)@(posedge <%=chipletObj[0].DceInfo[i].unitClk[0]%>clk);
       <% } %>

       <% for (var i = 0; i<chipletObj[0].DmiInfo.length; i++) { %>
           //DMI<%=i%>
           repeat(<%=cnt_multi%>)@(posedge <%=chipletObj[0].DmiInfo[i].unitClk[0]%>clk);

		   <%if(chipletObj[0].DmiInfo[i].hierPath  && chipletObj[0].DmiInfo[i].hierPath !== ''){%>
           		force   <%=hier_path_dut%>.<%=chipletObj[0].DmiInfo[i].instancePath%>.u_dmi_fault_checker.func_0_fault_in = 1'b1;
	            @(posedge <%=chipletObj[0].DmiInfo[i].unitClk[0]%>clk);
     	        release <%=hier_path_dut%>.<%=chipletObj[0].DmiInfo[i].instancePath%>.u_dmi_fault_checker.func_0_fault_in;
		   <%}else{%>
           		force   <%=hier_path_dut%>.<%=chipletObj[0].DmiInfo[i].strRtlNamePrefix%>.u_dmi_fault_checker.func_0_fault_in = 1'b1;
	            @(posedge <%=chipletObj[0].DmiInfo[i].unitClk[0]%>clk);
     	        release <%=hier_path_dut%>.<%=chipletObj[0].DmiInfo[i].strRtlNamePrefix%>.u_dmi_fault_checker.func_0_fault_in;
		   <%}%>
           repeat(20)@(posedge <%=chipletObj[0].DmiInfo[i].unitClk[0]%>clk);
       <% } %>



       <% for (var i = 0; i<chipletObj[0].DveInfo.length; i++) { %>
           //DVE<%=i%>
           repeat(<%=cnt_multi%>)@(posedge <%=chipletObj[0].DveInfo[i].unitClk[0]%>clk);

		   <%if(chipletObj[0].DveInfo[i].hierPath && chipletObj[0].DveInfo[i].hierPath !== ''){%>
    	       	force   <%=hier_path_dut%>.<%=chipletObj[0].DveInfo[i].instancePath%>.u_fault_checker.func_0_fault_in = 1'b1;
	           	@(posedge <%=chipletObj[0].DveInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=chipletObj[0].DveInfo[i].instancePath%>.u_fault_checker.func_0_fault_in;
		   <%}else{%>
    	       	force   <%=hier_path_dut%>.<%=chipletObj[0].DveInfo[i].strRtlNamePrefix%>.u_fault_checker.func_0_fault_in = 1'b1;
	           	@(posedge <%=chipletObj[0].DveInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=chipletObj[0].DveInfo[i].strRtlNamePrefix%>.u_fault_checker.func_0_fault_in;
		   <%}%>
           repeat(20)@(posedge <%=chipletObj[0].DveInfo[i].unitClk[0]%>clk);
       <% } %>




       <% for (var i = 0; i<chipletObj[0].DiiInfo.length; i++) { %>
           //DII<%=i%>  
           repeat(<%=cnt_multi%>)@(posedge <%=chipletObj[0].DiiInfo[i].unitClk[0]%>clk);

		   <%if(chipletObj[0].DiiInfo[i].hierPath && chipletObj[0].DiiInfo[i].hierPath !== ''){%>
           		force   <%=hier_path_dut%>.<%=chipletObj[0].DiiInfo[i].instancePath%>.u_dii_fault_checker.func_0_fault_in = 1'b1;
           		@(posedge <%=chipletObj[0].DiiInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=chipletObj[0].DiiInfo[i].instancePath%>.u_dii_fault_checker.func_0_fault_in;
		   <%}else{%>
           		force   <%=hier_path_dut%>.<%=chipletObj[0].DiiInfo[i].strRtlNamePrefix%>.u_dii_fault_checker.func_0_fault_in = 1'b1;
           		@(posedge <%=chipletObj[0].DiiInfo[i].unitClk[0]%>clk);
           		release <%=hier_path_dut%>.<%=chipletObj[0].DiiInfo[i].strRtlNamePrefix%>.u_dii_fault_checker.func_0_fault_in;
		   <%}%>
           repeat(20)@(posedge <%=chipletObj[0].DiiInfo[i].unitClk[0]%>clk);
       <% } %>

       <% for (var i = 0; i<(chipletObj[0].AiuInfo.length); i++) { %>
       <% if ((chipletObj[0].AiuInfo[i].fnNativeInterface == "CHI-B")||(chipletObj[0].AiuInfo[i].fnNativeInterface == "CHI-E") ) { %>
           //CHi<%=i%>
	   repeat(<%=cnt_multi%>)@(posedge <%=chipletObj[0].AiuInfo[i].nativeClk%>clk);
           <%if(chipletObj[0].AiuInfo[i].hierPath && chipletObj[0].AiuInfo[i].hierPath !== ''){%>
                force   <%=hier_path_dut%>.<%=chipletObj[0].AiuInfo[i].instancePath%>.u_chi_aiu_fault_checker.func_0_fault_in = 1'b1;
                @(posedge <%=chipletObj[0].AiuInfo[i].nativeClk%>clk);
                release <%=hier_path_dut%>.<%=chipletObj[0].AiuInfo[i].instancePath%>.u_chi_aiu_fault_checker.func_0_fault_in;
           <%} else {%>
                force   <%=hier_path_dut%>.<%=chipletObj[0].AiuInfo[i].strRtlNamePrefix%>.u_chi_aiu_fault_checker.func_0_fault_in = 1'b1;
                @(posedge <%=chipletObj[0].AiuInfo[i].nativeClk%>clk);
                release <%=hier_path_dut%>.<%=chipletObj[0].AiuInfo[i].strRtlNamePrefix%>.u_chi_aiu_fault_checker.func_0_fault_in;
           <%}%>
           repeat(20)@(posedge <%=chipletObj[0].AiuInfo[i].nativeClk%>clk);
         <% } else {%>
	   //IO<%=i%>
           repeat(<%=cnt_multi%>)@(posedge <%=chipletObj[0].AiuInfo[i].nativeClk%>clk);
            <%if(chipletObj[0].AiuInfo[i].hierPath && chipletObj[0].AiuInfo[i].hierPath !== ''){%>
                force   <%=hier_path_dut%>.<%=chipletObj[0].AiuInfo[i].instancePath%>.dup_checker.func_0_fault_in = 1'b1;
                @(posedge <%=chipletObj[0].AiuInfo[i].nativeClk%>clk);
                release <%=hier_path_dut%>.<%=chipletObj[0].AiuInfo[i].instancePath%>.dup_checker.func_0_fault_in;
            <%}else{%>
                force   <%=hier_path_dut%>.<%=chipletObj[0].AiuInfo[i].strRtlNamePrefix%>.dup_checker.func_0_fault_in = 1'b1;
                @(posedge <%=chipletObj[0].AiuInfo[i].nativeClk%>clk);
                release <%=hier_path_dut%>.<%=chipletObj[0].AiuInfo[i].strRtlNamePrefix%>.dup_checker.func_0_fault_in;
            <%}%>
            repeat(20)@(posedge <%=chipletObj[0].AiuInfo[i].nativeClk%>clk);
         <% } %>
       <% } %>
     end
   end
   
 endmodule: fsys_fault_injector_checker

<% } %>
`endif
