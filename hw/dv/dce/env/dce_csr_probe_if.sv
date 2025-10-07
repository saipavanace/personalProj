
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract:
 * Defines an interface that provides access to a internal signal of DUT .This
 */

`ifndef GUARD_DCE_CSR_PROBE_IF_SV
`define GUARD_DCE_CSR_PROBE_IF_SV

<% 
   var use_memHints = 0;
   obj.SnoopFilterInfo.forEach( function(snoop) {
	use_memHints = use_memHints | snoop.CmpInfo.useMemHints;					 
   })
%>  

interface dce_csr_probe_if (input clk, input resetn);

  logic IRQ_C;
  logic IRQ_UC;
  <% var i = 0;
     obj.SnoopFilterInfo.forEach( function(snoop) {
	 if(snoop.fnFilterType == "TAGFILTER") {
		  %>
  logic [31:0] single_bit_count<%=i%>;
  logic [31:0] double_bit_count<%=i%>;							
			    
    <%    i++;
	}					  
      }); %>

  logic [31:0]  DCEUSFER_SfEn;
  logic [127:0] DCEUCASER_CaSnpEn;
  logic [127:0] DCEUCASAR_CaSnpActv;
  logic [127:0] CSADSAR_DvmSnpActv;
  logic [7:0]   DCEUCECR_ErrThreshold;
	
  logic [31:0]  DCEUMRHER_MrHntEn;
  bit 	        int_clk;
<% for(var att_no = 0 ; att_no < obj.DceInfo.CmpInfo.nAttCtrlEntries ; att_no++) { %>
   bit att<%=att_no%>_maint_collision;									   
<% } %> 
<% for(var att_no = 0 ; att_no < obj.DceInfo.CmpInfo.nAttCtrlEntries ; att_no++) { %>
   assign att<%=att_no%>_maint_collision = (((dut.dce_unit.dirm__maint_req_address == (~(<%=obj.wSfiAddress%>'h3f) & dut.dce_unit.atm.att<%=att_no%>_addr)) && (dut.dce_unit.dirm__maint_req_valid)));
<% } %> 

  assign DCEUSFER_SfEn = dce_top_tb.dut.dce_unit.csr_array.o_DCEUSFER_SfEn;
  assign DCEUCASER_CaSnpEn = {dce_top_tb.dut.dce_unit.csr_array.o_DCEUCASER_CaSnpEn_3,
                              dce_top_tb.dut.dce_unit.csr_array.o_DCEUCASER_CaSnpEn_2,
                              dce_top_tb.dut.dce_unit.csr_array.o_DCEUCASER_CaSnpEn_1,
                              dce_top_tb.dut.dce_unit.csr_array.o_DCEUCASER_CaSnpEn_0};
  assign DCEUCASAR_CaSnpActv = {dce_top_tb.dut.dce_unit.atm__DCEUCASAR_CaSnpActv_3,
                              dce_top_tb.dut.dce_unit.atm__DCEUCASAR_CaSnpActv_2,
                              dce_top_tb.dut.dce_unit.atm__DCEUCASAR_CaSnpActv_1,
                              dce_top_tb.dut.dce_unit.atm__DCEUCASAR_CaSnpActv_0};
<%  var has_dvm = 0;
    obj.AiuInfo.forEach(function(agent) {
      has_dvm += agent.NativeInfo.DvmInfo.nDvmCmpInflight;
    }); %>
  <% if(has_dvm) { %>     
  assign CSADSAR_DvmSnpActv = {dce_top_tb.dut.dce_unit.CSADSAR_DvmSnpActv_3,
                              dce_top_tb.dut.dce_unit.CSADSAR_DvmSnpActv_2,
                              dce_top_tb.dut.dce_unit.CSADSAR_DvmSnpActv_1,
                              dce_top_tb.dut.dce_unit.CSADSAR_DvmSnpActv_0};
  <% } %>
			      
  assign DCEUMRHER_MrHntEn = dce_top_tb.dut.dce_unit.csr_array.o_DCEUMRHER_MrHntEn;
  assign DCEUCESR_ErrOvf = dce_top_tb.dut.dce_unit.DCEUCESR_ErrOvf;
  assign csr_array__o_DCEUCESR_ErrVld_en = dce_top_tb.dut.dce_unit.csr_array__o_DCEUCESR_ErrVld_en;
  assign DCEUCESR_ErrVld = dce_top_tb.dut.dce_unit.DCEUCESR_ErrVld;	
  assign DCEUCESR_ErrCount = dce_top_tb.dut.dce_unit.DCEUCESR_ErrCount;
  assign DCEUCECR_ErrThreshold = dce_top_tb.dut.dce_unit.DCEUCECR_ErrThreshold;
  assign DCEUCECR_ErrDetEn = dce_top_tb.dut.dce_unit.DCEUCECR_ErrDetEn;       
  assign DCEUCECR_ErrIntEn = dce_top_tb.dut.dce_unit.DCEUCECR_ErrIntEn;       
  assign int_clk = clk;
	
`ifdef DUT_IS_DCE3
  assign IRQ_C  = 0;
  assign IRQ_UC = 0;
`elsif DUT_IS_DCE2
  assign IRQ_C  = 0;
  assign IRQ_UC = 0;
`elsif DUT_IS_DCE1
  assign IRQ_C  = 0;
  assign IRQ_UC = 0;
`else
  //DCE0
  assign IRQ_C  = dut.dce_unit.dce0_correctible_error_irq;   
  assign IRQ_UC = dut.dce_unit.dce0_uncorrectible_error_irq;
`endif

   <% var i = 0;
      obj.SnoopFilterInfo.forEach( function(snoop) {
	 if(snoop.fnFilterType == "TAGFILTER") {
		  %>
//  assign single_bit_count<%=i%> = dut.dce_unit.dirm.<%=snoop.strRtlNamePrefix%>_mem.mem.internal_mem_inst.SINGLE_ERROR_COUNT[31:0];
//  assign double_bit_count<%=i%> = dut.dce_unit.dirm.<%=snoop.strRtlNamePrefix%>_mem.mem.internal_mem_inst.DOUBLE_ERROR_COUNT[31:0];
    <%    i++;
             }
      }); %>
`ifdef ASSERT_ON
//anippuleti (07/18/16) below assertion in wrong and some signals are not valid
//commenting it out since we a have directed test and check to erfiy this functionality
//assert_w1c_override_overflow:
//  assert property(@(posedge clk)
//    ((DCEUCESR_ErrCount == DCEUCECR_ErrThreshold) && (DCEUCESR_ErrOvf == 0) && (csr_array__o_DCEUCESR_ErrVld_en) && (DCEUCECR_ErrDetEn)) |=> DCEUCESR_ErrOvf)
//    else $fatal("Ovf bit is not set when a w1c arrives on the same cycle as ErrOvf is supposed to be set");

//assert_count_no_incr_on_vld:
//  assert property(@(posedge clk)
//    (!(csr_array__o_DCEUCESR_ErrVld_en) && DCEUCESR_ErrVld) |=> ($stable(DCEUCESR_ErrCount)))
//    else $fatal("ErrCount toggles when ErrVld bit is set");
`endif
/*<% for(var att_no = 0 ; att_no < obj.DceInfo.CmpInfo.nAttCtrlEntries ; att_no++) { %>
   sequence maint_active_no_sleep_att<%=att_no%>; 
	@(posedge clk) (((dut.dce_unit.dirm__maint_req_address == (~(<%=obj.wSfiAddress%>'h3f) & dut.dce_unit.atm.att<%=att_no%>_addr)) && (dut.dce_unit.dirm__maint_req_valid)) ##1 ~dut.dce_unit.atm.att<%=att_no%>_sleeping);
   endsequence
   cover_maint_active_no_sleep_att<%=att_no%> : cover property (maint_active_no_sleep_att<%=att_no%>);
   assert_maint_active_no_sleep_att<%=att_no%> : assert property (@(posedge clk)
	(((dut.dce_unit.dirm__maint_req_address == (~(<%=obj.wSfiAddress%>'h3f) & dut.dce_unit.atm.att<%=att_no%>_addr)) && (dut.dce_unit.dirm__maint_req_valid)) |=> ~dut.dce_unit.atm.att<%=att_no%>_sleeping))
	   else $fatal($sformatf("maintenance for maint_req_addres = 0x%0h has error with collision with att entry", dut.dce_unit.dirm__maint_req_address));
<% } %>  */
//	@(posedge clk) (((dut.dce_unit.dirm__maint_req_address == (~(<%=obj.wSfiAddress%>'h3f) & dut.dce_unit.atm.att<%=att_no%>_addr)) && (dut.dce_unit.dirm__maint_req_valid)) ##1 ~dut.dce_unit.atm.att<%=att_no%>_sleeping);
/*
 Model SNPActv registers
 */
	 

<% var skip_no = -1;
   obj.AiuInfo.forEach(function(agent, agent_no) { %>
<% if((agent.fnNativeInterface == "ACE") && ((skip_no == -1) || (agent_no > skip_no))) { 
	if(agent.nAius > 1)
	   skip_no = agent_no + agent.nAius - 1; %>
//assert_dirucasar_casnpactv<%=agent.strRtlNamePrefix%> :
// assert property(@(posedge clk)
//   ((dut.dce_unit.atm.aiu<%=agent_no%>_snp_credit_count > 0) |=> dut.dce_unit.atm__DCEUCASAR_CaSnpActv_0[<%=agent_no%>]))
//       else $fatal($sformatf("DCEUCASAR_CaSnpActv mismatch for Agent<%=agent_no%>"));
//assert_n_dirucasar_casnpactv<%=agent.strRtlNamePrefix%> :
// assert property(@(posedge clk)
//   ((dut.dce_unit.atm.aiu<%=agent_no%>_snp_credit_count == 0) |=> ~dut.dce_unit.atm__DCEUCASAR_CaSnpActv_0[<%=agent_no%>]))
//       else $fatal($sformatf("DCEUCASAR_CaSnpActv mismatch for Agent<%=agent_no%>"));

<% } %>
<% });%>


<% skip_no = -1
   obj.BridgeAiuInfo.forEach(function(bridge, bridge_no) { 
   if((bridge.NativeInfo.useIoCache) && ((skip_no == -1) || (bridge_no > skip_no))) {
	if(bridge.nAius > 1)
	   skip_no = bridge_no + bridge.nAius - 1; 
        %>	 
//assert_dirucasar_casnpactvBridge<%=bridge.strRtlNamePrefix%> :
// assert property(@(posedge clk)
//   ((dut.dce_unit.atm.aiu<%=bridge_no + AiuInfo.length%>_snp_credit_count > 0) |=> dut.dce_unit.atm__DCEUCASAR_CaSnpActv_3[<%=bridge_no%>]))
//       else $fatal($sformatf("DCEUCASAR_CaSnpActv mismatch for Bridge<%=bridge_no%>"));
//assert_n_dirucasar_casnpactvBridge<%=bridge.strRtlNamePrefix%> :
// assert property(@(posedge clk)
//   ((dut.dce_unit.atm.aiu<%=bridge_no + AiuInfo.length%>_snp_credit_count == 0) |=> ~dut.dce_unit.atm__DCEUCASAR_CaSnpActv_3[<%=bridge_no%>]))
//       else $fatal($sformatf("DCEUCASAR_CaSnpActv mismatch for Bridge<%=bridge_no%>"));
//
<%    }
   });%>
<% var skip_no = -1;
   obj.AiuInfo.forEach(function(agent, agent_no) { %>
<% if((agent.NativeInfo.DvmInfo.nDvmCmpInFlight == 1) && (agent_no < skip_no)) {
       if(agent.nAius > 1)
	 skip_no = agent_no + agent.nAius - 1;%>	
assert_csadsar_dvmsnpactv<%=agent.strRtlNamePrefix%> :
 assert property(@(posedge clk)
   ((dut.dce_unit.dvm.snp_sent & dut.dce_unit.dvm.dest_aiu_vec_sel[<%=agent_no%>]) |=> dut.dce_unit.CSADSAR_DvmSnpActv_0[<%=agent_no%>]))
       else $fatal($sformatf("CSADSAR_DvmSnpActv mismatch for Agent<%=agent_no%>"));
<% } %>
<% });%>
<%  var has_mem = 0;
obj.SnoopFilterInfo.forEach(function(snoop) {
   has_mem += (snoop.fnFilterType == "TAGFILTER");
}); %>

<% if(has_mem) { %>
//assert_dirusfmar_mntopactv :
// assert property(@(negedge clk)
//   ((dut.dce_unit.dirm.p0_maint_valid | dut.dce_unit.dirm.p1_maint_valid | dut.dce_unit.dirm.p2_maint_valid | dut.dce_unit.dirm.p3_maint_valid | dut.dce_unit.dirm.p4_maint_valid | dut.dce_unit.dirm.p5_maint_valid | dut.dce_unit.dirm.att_mntop_active | dut.dce_unit.dirm.mem_init_in_progress) |-> dut.dce_unit.csr_array__i_DCEUSFMAR_MntOpActv))
//	else $fatal($sformatf("DCEUSFMAR_MntOpActv"));
<% } %>

//#Cov.DCE.ErrIntDisEnUnCorrErrs
ErrIntDisEnUnCorrErrs : assert property(
   @(negedge clk) ((DCEUCECR_ErrIntEn == 0) |-> (IRQ_UC == 0)))
  else $fatal("ERROR! dce0_uncorrectible_error_irq fired while DCEUCECR_ErrIntEn was inactive!");


//#Cov.DCE.SFDisWithHintsEnabled
<%if(use_memHints) { 
      obj.SnoopFilterInfo.forEach( function(snoop, i) {
	obj.DmiInfo.forEach( function(dmi, j) {
	 var memregion = dmi.MemRegionInfo;				       
	 if(snoop.fnFilterType == "TAGFILTER") {
	    var sf_mask = Math.pow(2,i);
	    var mem_mask = Math.pow(2,j);					
   %>
property sf<%=i%>_dis_with_hnt_en<%=j%>;
  @(negedge clk) (((DCEUSFER_SfEn & <%=sf_mask%>) == 0) && ((DCEUMRHER_MrHntEn & <%=mem_mask%>) == 1));
endproperty : sf<%=i%>_dis_with_hnt_en<%=j%>
cover property (sf<%=i%>_dis_with_hnt_en<%=j%>);
   <%   
	}
       });
     });
  }
   %>
	 
endinterface

`endif // GUARD_DCE_CSR_PROBE_IF_SV
