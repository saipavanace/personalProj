
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract:
 * Defines an interface that provides access to a internal signal of DUT .This
 */

`ifndef GUARD_CHI_AIU_CSR_PROBE_IF_SV
`define GUARD_CHI_AIU_CSR_PROBE_IF_SV

interface chi_aiu_csr_probe_if (input clk, input resetn);

  logic IRQ_C;
  logic IRQ_UC;

  logic QOSSR_EventStatus;

<% if(obj.useResiliency) { %>
  logic fault_mission_fault;
  logic fault_latent_fault;
  logic [9:0]  cerr_threshold;
  logic [15:0] cerr_counter;
  logic        cerr_over_thres_fault;
<% } %>

  logic uesr_errvld;
  logic uesar_errvld_en;
  logic uesar_errvld;
  logic uesr_err_cnt;
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();

  uvm_event ev_crd_cov_<%=obj.BlockId%> = ev_pool.get("ev_crd_cov_<%=obj.BlockId%>");
  uvm_event boundary_addr_cov_<%=obj.BlockId%> = ev_pool.get("boundary_addr_cov_<%=obj.BlockId%>");
<% if(obj.useResiliency) { %>
  uvm_event ev_cerr_thres_<%=obj.BlockId%> = ev_pool.get("ev_cerr_thres_<%=obj.BlockId%>");
<% } %>

    int dce_credit_state[<%=obj.nDCEs%>];
    int dmi_credit_state[<%=obj.nDMIs%>];
    int dii_credit_state[<%=obj.nDIIs%>];

    <% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
    int gpra<%=i%>_sizeofig;
    <%}%>
 
assign u_csr_probe_if.QOSSR_EventStatus = tb_top.dut.unit.chi_aiu_csr.CAIUQOSSR_EventStatus_out;

assign uesr_errvld = tb_top.dut.unit.chi_aiu_csr.CAIUUESR_ErrVld_out;
assign uesar_errvld_en = tb_top.dut.unit.chi_aiu_csr.CAIUUESR_ErrVld_wr;
assign uesar_errvld = tb_top.dut.unit.chi_aiu_csr.CAIUUESR_ErrVld_in;
assign uesr_err_cnt = tb_top.dut.unit.chi_aiu_csr.chi_aiu_csr_gen.CAIUUEDR_TransErrDetEn_out;

<% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
     assign gpra<%=i%>_sizeofig = tb_top.dut.unit.ncore3_addr_map.u_gpra<%=i%>_compare_address.HUT ? 0 : tb_top.dut.unit.ncore3_addr_map.u_gpra<%=i%>_compare_address.SizeOfIG[3:0]; 
<%}%>



<%for (var j=0; j< obj.nDCEs; j++){%> 
assign dce_credit_state[<%=j%>] = tb_top.dut.unit.chi_aiu_csr.CAIUCCR<%=j%>_DCECounterState_out; 
<%}%>

<%for (var j=0; j< obj.nDMIs; j++){%> 
assign dmi_credit_state[<%=j%>] = tb_top.dut.unit.chi_aiu_csr.CAIUCCR<%=j%>_DMICounterState_out; 
<%}%>

<%for (var j=0; j< obj.nDIIs; j++){%> 
assign dii_credit_state[<%=j%>] = tb_top.dut.unit.chi_aiu_csr.CAIUCCR<%=j%>_DIICounterState_out; 
<%}%>

always @ (*) begin
<% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
   uvm_config_db#(int)::set(null,"*","gpra<%=i%>_sizeofig",(gpra<%=i%>_sizeofig+1));
   boundary_addr_cov_<%=obj.BlockId%>.trigger();
<%}%>
end

always @ (*) begin

<%for (var j=0; j< obj.nDCEs; j++){%> 
   uvm_config_db#(int)::set(null,"*","check_dce_crd_state_<%=j%>",dce_credit_state[<%=j%>]);
<%}%>

<%for (var j=0; j< obj.nDMIs; j++){%> 
   uvm_config_db#(int)::set(null,"*","check_dmi_crd_state_<%=j%>",dmi_credit_state[<%=j%>]);
<%}%>

<%for (var j=0; j< obj.nDIIs; j++){%> 
   uvm_config_db#(int)::set(null,"*","check_dii_crd_state_<%=j%>",dii_credit_state[<%=j%>]);
<%}%>

ev_crd_cov_<%=obj.BlockId%>.trigger();

end

<% if(obj.useResiliency) { %>
always @ (*) begin

   uvm_config_db#(int)::set(null,"*","<%=obj.BlockId%>_corr_err_threshold",cerr_threshold);

   uvm_config_db#(int)::set(null,"*","<%=obj.BlockId%>_corr_err_over_thres_fault",cerr_over_thres_fault);

   uvm_config_db#(int)::set(null,"*","<%=obj.BlockId%>_corr_err_counter",cerr_counter);

   ev_cerr_thres_<%=obj.BlockId%>.trigger();

end
<%}%>

property assert_uncorrErrInjWhileSoftwareWriteHappens;                                                
   @(posedge clk) disable iff (~resetn) ((!uesr_errvld & uesar_errvld_en & !uesar_errvld & uesr_err_cnt) |=> !uesr_errvld); 
endproperty
assertuncorrErrInjWhileSoftwareWriteHappens : assert property (assert_uncorrErrInjWhileSoftwareWriteHappens) else 
                                             `uvm_error("CHI-AIU_CSR_PROBE_IF",$sformatf(" CAIUUESR_ErrVld bit not cleared  "));

endinterface

`endif // GUARD_CHI_AIU_CSR_PROBE_IF_SV
