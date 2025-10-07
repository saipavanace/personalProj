<%
//Embedded javascript code to figure number of blocks
   var _blkid = [];
   var _blkidpkg = [];
   var _blktype = [];
   var _blkports_suffix =[];
   var _blk_nCore = [];
   var _blk   = [{}];
   var pidx = 0;
   var ridx = 0;
   var _idx = 0;
   var chiaiu_idx = 0;
   var ioaiu_idx = 0;
   var ioaiu_mpu_idx = 0;
   obj.nAIUs_mpu =0; 
   var numChiAiu = 0; // Number of CHI AIUs
   var numIoAiu = 0; // Number of IO AIUs
   
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'chiaiu' + chiaiu_idx +"_0";
       _blkidpkg[_idx] = 'chiaiu' + chiaiu_idx;
       _blktype[_idx]   = 'chiaiu';
       _blk_nCore[pidx] = 1;
       chiaiu_idx++;
       obj.nAIUs_mpu++;
       numChiAiu++ ;
       _idx++;
       } else {
       for (var port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkidpkg[_idx] = 'ioaiu' + ioaiu_idx;
        _blkid[_idx] = 'ioaiu' + ioaiu_idx +"_"+port_idx;
        _blkports_suffix[_idx] = "_" + port_idx;
        _blktype[_idx]   = 'ioaiu';
        _blk_nCore[pidx] = obj.AiuInfo[pidx].nNativeInterfacePorts;
         _idx++;
        obj.nAIUs_mpu++;
        }
         ioaiu_idx++;
         numIoAiu++ ;
       }
   }

   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu;
       _blkid[ridx] = 'dce' + pidx;
       _blkidpkg[ridx] = 'dce' + pidx;
       _blktype[ridx]   = 'dce';
       _blk[ridx]   = obj.DceInfo[pidx];
   }
 for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu + obj.nDCEs;
       _blkid[ridx] = 'dmi' + pidx;
       _blkidpkg[ridx] = 'dmi' + pidx;
       _blktype[ridx]   = 'dmi';
       _blk[ridx]   = obj.DmiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu + obj.nDCEs + obj.nDMIs;
       _blkid[ridx] = 'dii' + pidx;
       _blkidpkg[ridx] = 'dii' + pidx;
       _blk[ridx]   = 'dii';
       _blk[ridx]   = obj.DiiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _blkid[ridx] = 'dve' + pidx;
       _blkidpkg[ridx] = 'dve' + pidx;
       _blktype[ridx]   = 'dve';
       _blk[ridx]   = obj.DveInfo[pidx];
   }
   var nALLs = ridx+1; 
%>
class concerto_fsc_tasks extends uvm_component; 

  `uvm_component_utils(concerto_fsc_tasks)
  static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
  static uvm_event fsc_test_done = ev_pool.get("fsc_test_done");
  static uvm_event fsys_fsc_main_task_done= ev_pool.get("fsys_fsc_main_task_done");
  static uvm_event fsys_fsc_misc_task_done= ev_pool.get("fsys_fsc_misc_task_done");
  static uvm_event csr_init_done = ev_pool.get("csr_init_done");
  static uvm_event ev_sim_done   = ev_pool.get("sim_done");
  static uvm_event ev_fsc_bist_start   = ev_pool.get("ev_fsc_bist_start");
   //set env 
   concerto_test_cfg test_cfg;
   concerto_env_cfg m_concerto_env_cfg;  
   concerto_env     m_concerto_env;
   concerto_register_map_pkg::ral_sys_ncore  m_regs;


<% var unit_dup = obj.AiuInfo[0].ResilienceInfo.enableUnitDuplication; %>
<% if(obj.useResiliency == 1) { %>
   uvm_reg_bit_bash_seq reg_bit_bash_seq;
   uvm_reg_hw_reset_seq reg_hw_reset_seq;
   uvm_event mission_fault_detected;
   uvm_event latent_fault_detected;
   uvm_event cerr_over_thresh_fault_detected;
   uvm_event injectSingleErr;
   bit uncorr_err_inj_test_start_indication;
   bit corr_err_inj_test_start_indication;
   logic [31:0] FSCERRR;
   logic [31:0] SCLFX0_latent_fault;
   logic [31:0] SCLFX1_latent_fault;
   logic [31:0] SCLFX2_latent_fault;
   logic [31:0] SCLFX3_latent_fault;
   logic [31:0] SCLFX4_latent_fault;
   logic [31:0] SCMFX0_mission_fault;
   logic [31:0] SCMFX1_mission_fault;
   logic [31:0] SCMFX2_mission_fault;
   logic [31:0] SCMFX3_mission_fault;
   logic [31:0] SCMFX4_mission_fault;
   logic [31:0] SCCETHF0;
   logic [31:0] SCCETHF1;
   logic [31:0] SCCETHF2;
   logic [31:0] SCCETHF3;
   logic [31:0] SCCETHF4;
   bit   [31:0] fcov_SCBISTCR;
   bit   [31:0] fcov_SCBISTAR;
   bit   [31:0] fcov_SCLF0   ;
   bit   [31:0] fcov_SCLF1   ;
   bit   [31:0] fcov_SCLF2   ;
   bit   [31:0] fcov_SCLF3   ;
   bit   [31:0] fcov_SCLF4   ;
   bit   [31:0] fcov_SCMF0   ;
   bit   [31:0] fcov_SCMF1   ;
   bit   [31:0] fcov_SCMF2   ;
   bit   [31:0] fcov_SCMF3   ;
   bit   [31:0] fcov_SCMF4   ;
   bit   [31:0] fcov_SCCETHF0;
   bit   [31:0] fcov_SCCETHF1;
   bit   [31:0] fcov_SCCETHF2;
   bit   [31:0] fcov_SCCETHF3;
   bit   [31:0] fcov_SCCETHF4;
`ifdef FSYS_COVER_ON
`ifdef FSYS_COV_INCL_FSC_BINS
covergroup cg_fsc_regs;
        bist_auto :coverpoint fcov_SCBISTCR{
            bins bist_auto   = {3}; 
        }
        bist_manual :coverpoint fcov_SCBISTCR{
            bins bist_manual = {1}; 
        }
        SCBISTCR_reg :coverpoint fcov_SCBISTCR{
            bins bit_0_bist_start = {1}; 
            bins bit_1_bist_mode  = {[2:3]}; 
        }
// #Cover.FSYS.FSC_full_reset_error_Step1
// #Cover.FSYS.FSC_functional_error_Step2
// #Cover.FSYS.FSC_duplicate_error_Step3
// #Cover.FSYS.FSC_both_error_Step4 
// #Cover.FSYS.FSC_timeout_test_error_Step5
// #Cover.FSYS.FSC_final_error_Step6
// #Cover.FSYS.FSC_unit_timeout_error_Step5
        SCBISTAR_reg :coverpoint fcov_SCBISTAR{
            bins bit_0_step_1_bist_full_reset_done           = {1}; 
            bins bit_1_step_2_bist_func_comp_tree_force_done = {[2:3]}; 
            bins bit_2_step_3_bist_dup_comp_tree_force_done  = {[4:7]}; 
            bins bit_3_step_4_bist_both_comp_tree_force_done = {[8:15]}; 
            bins bit_4_step_5_bist_timeout_test_error        = {[16:31]}; 
            bins bit_5_step_6_bist_final_full_reset_done     = {[32:63]}; 
            bins bit_10_step_5_bist_timeout_test_error        = {[1024:2047]}; 
        }
<% if(unit_dup) { %>
// #Cover.FSYS.FSC_SCLFX 
        SCLF0_reg :coverpoint fcov_SCLF0{
       <% var chiaiu_idx=0;
       for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
            bins bit_<%=chiaiu_idx%>_chiaiu_SCLF0           = {[<%=(Math.pow(2, chiaiu_idx))%>:<%=(Math.pow(2, chiaiu_idx+1))-1%>]}; 
       <% chiaiu_idx = chiaiu_idx+1; } } %>
        }
        SCLF1_reg :coverpoint fcov_SCLF1{
       <% var ioaiu_idx=0;
       for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
            bins bit_<%=ioaiu_idx%>_ioaiu_SCLF1           = {[<%=(Math.pow(2, ioaiu_idx))%>:<%=(Math.pow(2, ioaiu_idx+1))-1%>]}; 
       <% ioaiu_idx = ioaiu_idx+1; } } %>
        }
        SCLF2_reg :coverpoint fcov_SCLF2{
       <% var dmi_idx=0;
       for (var i = 0; i<(obj.DmiInfo.length ); i++) { %>
            bins bit_<%=dmi_idx%>_dmi_SCLF2           = {[<%=(Math.pow(2, dmi_idx))%>:<%=(Math.pow(2, dmi_idx+1))-1%>]}; 
       <% dmi_idx= dmi_idx+1; }  %>
        }
        SCLF3_reg :coverpoint fcov_SCLF3{
       <% var dii_idx=0;
       for (var i = 0; i<(obj.DiiInfo.length ); i++) { %>
            bins bit_<%=dii_idx%>_dii_SCLF3           = {[<%=(Math.pow(2, dii_idx))%>:<%=(Math.pow(2, dii_idx+1))-1%>]}; 
       <% dii_idx= dii_idx+1; }  %>
        }
        SCLF4_reg :coverpoint fcov_SCLF4{
       <% var gen_idx=0;
       for (var i = 0; i<(obj.DceInfo.length ); i++) { %>
            bins bit_<%=gen_idx%>_dce_SCLF4           = {[<%=(Math.pow(2, gen_idx))%>:<%=(Math.pow(2, gen_idx+1))-1%>]}; 
       <% gen_idx= gen_idx+1; }  %>

       <% var gen_idx=31;
       for (var i = 0; i<(obj.DveInfo.length ); i++) { %>
            bins bit_<%=gen_idx%>_dve_SCLF4           = {[<%=(Math.pow(2, gen_idx))%>:<%=(Math.pow(2, gen_idx+1))-1%>]}; 
       <% gen_idx= gen_idx+1; }  %>

        }
<% } %>
// #Cover.FSYS.FSC_SCMFX
        SCMF0_reg :coverpoint fcov_SCMF0{
       <% var chiaiu_idx=0;
       for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
            bins bit_<%=chiaiu_idx%>_chiaiu_SCMF0           = {[<%=(Math.pow(2, chiaiu_idx))%>:<%=(Math.pow(2, chiaiu_idx+1))-1%>]}; 
       <% chiaiu_idx = chiaiu_idx+1; } } %>
        }
        SCMF1_reg :coverpoint fcov_SCMF1{
       <% var ioaiu_idx=0;
       for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
            bins bit_<%=ioaiu_idx%>_ioaiu_SCMF1           = {[<%=(Math.pow(2, ioaiu_idx))%>:<%=(Math.pow(2, ioaiu_idx+1))-1%>]}; 
       <% ioaiu_idx = ioaiu_idx+1; } } %>
        }
        SCMF2_reg :coverpoint fcov_SCMF2{
       <% var dmi_idx=0;
       for (var i = 0; i<(obj.DmiInfo.length ); i++) { %>
            bins bit_<%=dmi_idx%>_dmi_SCMF2           = {[<%=(Math.pow(2, dmi_idx))%>:<%=(Math.pow(2, dmi_idx+1))-1%>]}; 
       <% dmi_idx= dmi_idx+1; }  %>
        }
        SCMF3_reg :coverpoint fcov_SCMF3{
       <% var dii_idx=0;
       for (var i = 0; i<(obj.DiiInfo.length ); i++) { %>
            bins bit_<%=dii_idx%>_dii_SCMF3           = {[<%=(Math.pow(2, dii_idx))%>:<%=(Math.pow(2, dii_idx+1))-1%>]}; 
       <% dii_idx= dii_idx+1; }  %>
        }
        SCMF4_reg :coverpoint fcov_SCMF4{
       <% var gen_idx=0;
       for (var i = 0; i<(obj.DceInfo.length ); i++) { %>
            bins bit_<%=gen_idx%>_dce_SCMF4           = {[<%=(Math.pow(2, gen_idx))%>:<%=(Math.pow(2, gen_idx+1))-1%>]}; 
       <% gen_idx= gen_idx+1; }  %>

       <% var gen_idx=31;
       for (var i = 0; i<(obj.DveInfo.length ); i++) { %>
            bins bit_<%=gen_idx%>_dve_SCMF4           = {[<%=(Math.pow(2, gen_idx))%>:<%=(Math.pow(2, gen_idx+1))-1%>]}; 
       <% gen_idx= gen_idx+1; }  %>

        }

// #Cover.FSYS.FSC_SCCETHFx
        SCCETHF0_reg :coverpoint fcov_SCCETHF0{
       <% var chiaiu_idx=0;
       for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
            bins bit_<%=chiaiu_idx%>_chiaiu_SCCETHF0           = {[<%=(Math.pow(2, chiaiu_idx))%>:<%=(Math.pow(2, chiaiu_idx+1))-1%>]}; 
       <% chiaiu_idx = chiaiu_idx+1; } } %>
        }
        SCCETHF1_reg :coverpoint fcov_SCCETHF1{
       <% var ioaiu_idx=0;
       for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
            bins bit_<%=ioaiu_idx%>_ioaiu_SCCETHF1           = {[<%=(Math.pow(2, ioaiu_idx))%>:<%=(Math.pow(2, ioaiu_idx+1))-1%>]}; 
       <% ioaiu_idx = ioaiu_idx+1; } } %>
        }
        SCCETHF2_reg :coverpoint fcov_SCCETHF2{
       <% var dmi_idx=0;
       for (var i = 0; i<(obj.DmiInfo.length ); i++) { %>
            bins bit_<%=dmi_idx%>_dmi_SCCETHF2           = {[<%=(Math.pow(2, dmi_idx))%>:<%=(Math.pow(2, dmi_idx+1))-1%>]}; 
       <% dmi_idx= dmi_idx+1; }  %>
        }
        SCCETHF3_reg :coverpoint fcov_SCCETHF3{
       <% var dii_idx=0;
       for (var i = 0; i<(obj.DiiInfo.length ); i++) { %>
            bins bit_<%=dii_idx%>_dii_SCCETHF3           = {[<%=(Math.pow(2, dii_idx))%>:<%=(Math.pow(2, dii_idx+1))-1%>]}; 
       <% dii_idx= dii_idx+1; }  %>
        }
        SCCETHF4_reg :coverpoint fcov_SCCETHF4{
       <% var gen_idx=0;
       for (var i = 0; i<(obj.DceInfo.length ); i++) { %>
            bins bit_<%=gen_idx%>_dce_SCCETHF4           = {[<%=(Math.pow(2, gen_idx))%>:<%=(Math.pow(2, gen_idx+1))-1%>]}; 
       <% gen_idx= gen_idx+1; }  %>

       <% var gen_idx=31;
       for (var i = 0; i<(obj.DveInfo.length ); i++) { %>
            bins bit_<%=gen_idx%>_dve_SCCETHF4           = {[<%=(Math.pow(2, gen_idx))%>:<%=(Math.pow(2, gen_idx+1))-1%>]}; 
       <% gen_idx= gen_idx+1; }  %>

        }
<% if(unit_dup) { %>
        cross_bist_auto_SCLF0    : cross bist_auto,SCLF0_reg;
        cross_bist_auto_SCLF1    : cross bist_auto,SCLF1_reg;
        cross_bist_auto_SCLF2    : cross bist_auto,SCLF2_reg;
        cross_bist_auto_SCLF3    : cross bist_auto,SCLF3_reg;
        cross_bist_auto_SCLF4    : cross bist_auto,SCLF4_reg;
<% } %>
        cross_bist_auto_SCMF0    : cross bist_auto,SCMF0_reg;
        cross_bist_auto_SCMF1    : cross bist_auto,SCMF1_reg;
        cross_bist_auto_SCMF2    : cross bist_auto,SCMF2_reg;
        cross_bist_auto_SCMF3    : cross bist_auto,SCMF3_reg;
        cross_bist_auto_SCMF4    : cross bist_auto,SCMF4_reg;
        cross_bist_auto_SCCETHF0 : cross bist_auto,SCCETHF0_reg;
        cross_bist_auto_SCCETHF1 : cross bist_auto,SCCETHF1_reg;
        cross_bist_auto_SCCETHF2 : cross bist_auto,SCCETHF2_reg;
        cross_bist_auto_SCCETHF3 : cross bist_auto,SCCETHF3_reg;
        cross_bist_auto_SCCETHF4 : cross bist_auto,SCCETHF4_reg;

<% if(unit_dup) { %>
        cross_bist_manual_SCLF0    : cross bist_manual,SCLF0_reg;
        cross_bist_manual_SCLF1    : cross bist_manual,SCLF1_reg;
        cross_bist_manual_SCLF2    : cross bist_manual,SCLF2_reg;
        cross_bist_manual_SCLF3    : cross bist_manual,SCLF3_reg;
        cross_bist_manual_SCLF4    : cross bist_manual,SCLF4_reg;
<% } %>
        cross_bist_manual_SCMF0    : cross bist_manual,SCMF0_reg;
        cross_bist_manual_SCMF1    : cross bist_manual,SCMF1_reg;
        cross_bist_manual_SCMF2    : cross bist_manual,SCMF2_reg;
        cross_bist_manual_SCMF3    : cross bist_manual,SCMF3_reg;
        cross_bist_manual_SCMF4    : cross bist_manual,SCMF4_reg;
        cross_bist_manual_SCCETHF0 : cross bist_manual,SCCETHF0_reg;
        cross_bist_manual_SCCETHF1 : cross bist_manual,SCCETHF1_reg;
        cross_bist_manual_SCCETHF2 : cross bist_manual,SCCETHF2_reg;
        cross_bist_manual_SCCETHF3 : cross bist_manual,SCCETHF3_reg;
        cross_bist_manual_SCCETHF4 : cross bist_manual,SCCETHF4_reg;
endgroup
`endif // `ifdef FSYS_COV_INCL_FSC_BINS
`endif

<% } %>

  function new(string name = "concerto_fsc_tasks", uvm_component parent=null);
    super.new(name,parent);
  <% if(obj.useResiliency == 1) { %>
`ifdef FSYS_COVER_ON
`ifdef FSYS_COV_INCL_FSC_BINS
    cg_fsc_regs = new();
`endif // `ifdef FSYS_COV_INCL_FSC_BINS
`endif
  <% } %>

  endfunction: new

  function sample_cg_fsc_regs();
  <% if(obj.useResiliency == 1) { %>
`ifdef FSYS_COVER_ON
`ifdef FSYS_COV_INCL_FSC_BINS
     cg_fsc_regs.sample();
`endif // `ifdef FSYS_COV_INCL_FSC_BINS
`endif
  <% } %>
  endfunction : sample_cg_fsc_regs

  <% if(obj.useResiliency == 1) { %>
  task inj_bist_timeout_err(ref bit release_timer_err);
  // #Stimulus.FSYS.FSC_unit_timeout_error_Step5
   <% var hier_path_dut = 'tb_top.dut'; %>
   <% var hier_path_dce = ''; %>
   <% var hier_path_dmi = ''; %>
       if($test$plusargs("dce_uncorr_err_inj") || (!($test$plusargs("dce_uncorr_err_inj") || $test$plusargs("ioaiu_uncorr_err_inj") || $test$plusargs("chiaiu_uncorr_err_inj")))) begin
          randcase
          <% for (var i = 0; i<obj.DceInfo.length; i++) { %>
              <% if(obj.DceInfo[i].hierPath && obj.DceInfo[i].hierPath !== '') { 
                hier_path_dce = `${hier_path_dut}.${obj.DceInfo[i].hierPath}`;
              } else {
                hier_path_dce = hier_path_dut; 
              }%>
          1: begin
               force <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.dce_func_unit.dce_tm.u_timeout.q_sv_timer = 'hff;
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.dce_func_unit.dce_tm.u_timeout.q_sv_timer"),UVM_LOW)
               repeat(<%=obj.DceInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
               end
           <% if(obj.DceInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
               force <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.dup_unit.dce_tm.u_timeout.q_sv_timer = 'hff;
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.dup_unit.dce_tm.u_timeout.q_sv_timer"),UVM_LOW)
           <% } %>
               wait(release_timer_err);
               release <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.dce_func_unit.dce_tm.u_timeout.q_sv_timer;
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("RELEASING signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.dce_func_unit.dce_tm.u_timeout.q_sv_timer"),UVM_LOW)
               repeat(<%=obj.DceInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
               end
           <% if(obj.DceInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
               release <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.dup_unit.dce_tm.u_timeout.q_sv_timer;
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("RELEASING signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.dup_unit.dce_tm.u_timeout.q_sv_timer"),UVM_LOW)
           <% } %>
          end
          <% } %>
          endcase
       end
       else if($test$plusargs("ioaiu_uncorr_err_inj"))  begin
        <% if(numIoAiu>0) { %>
          randcase
           <% var ioaiu_index = 0;
           for (var i = 0; i<(obj.AiuInfo.length); i++) { %>
           <% if ((obj.AiuInfo[i].fnNativeInterface != "CHI-A") && (obj.AiuInfo[i].fnNativeInterface != "CHI-B")  && (obj.AiuInfo[i].fnNativeInterface != "CHI-E")) { %>
          1: begin
               force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.q_sv_timer = 'hff;
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.q_sv_timer"),UVM_LOW)
               repeat(<%=obj.AiuInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               end
           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_unit.ioaiu_core0.ioaiu_control.q_sv_timer"),UVM_LOW)
               force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_unit.ioaiu_core0.ioaiu_control.q_sv_timer = 'hff;
           <% } %>
               wait(release_timer_err);
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.q_sv_timer"),UVM_LOW)
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.q_sv_timer;
               repeat(<%=obj.AiuInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               end
           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_unit.ioaiu_core0.ioaiu_control.q_sv_timer;
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_unit.ioaiu_core0.ioaiu_control.q_sv_timer"),UVM_LOW)
           <% } %>
          end
           <% ioaiu_index = ioaiu_index + 1; } %>
           <% } %>
          endcase
        <% } %>
       end
       else if($test$plusargs("chiaiu_uncorr_err_inj")) begin
        <% if(numChiAiu>0) { %>
          randcase
       <% var chiaiu_index = 0; 
       for (var i = 0; i<(obj.AiuInfo.length); i++) { %>
       <% if ((obj.AiuInfo[i].fnNativeInterface == "CHI-A") || (obj.AiuInfo[i].fnNativeInterface == "CHI-B") || (obj.AiuInfo[i].fnNativeInterface == "CHI-E")) { %>
          1: begin
              force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.unit.ott_top.u_timeout.q_sv_timer = 'hff;
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.unit.ott_top.u_timeout.q_sv_timer"),UVM_LOW)
              repeat(<%=obj.AiuInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
              end
           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
              force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_unit.ott_top.u_timeout.q_sv_timer = 'hff;
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_unit.ott_top.u_timeout.q_sv_timer"),UVM_LOW)
           <% } %>
              wait(release_timer_err);
              release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.unit.ott_top.u_timeout.q_sv_timer;
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.unit.ott_top.u_timeout.q_sv_timer"),UVM_LOW)
              repeat(<%=obj.AiuInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
              end
           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
              release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_unit.ott_top.u_timeout.q_sv_timer;
               `uvm_info("INJ_BIST_TIMEOUT_ERR",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_unit.ott_top.u_timeout.q_sv_timer"),UVM_LOW)
           <% } %>
          end
       <% chiaiu_index = chiaiu_index+1; } %>
       <% } %>
          endcase
        <% } %>
       end
  endtask
  <% } %>

  // UVM PHASE
  extern function void build_phase(uvm_phase phase);
  extern task fsys_fsc_main_task(uvm_phase phase);
  extern virtual task  fsys_fsc_misc_task(uvm_phase phase);
  extern task fsc_regs_check();
  extern task run_bist_seq(bit bist_seq_automatic_manual);

endclass: concerto_fsc_tasks


//METHOD Definitions
///////////////////////////////////////////////////////////////////////////////// 
// #     #  #     #  #     #         ######   #     #     #      #####   #######  
// #     #  #     #  ##   ##         #     #  #     #    # #    #     #  #        
// #     #  #     #  # # # #         #     #  #     #   #   #   #        #        
// #     #  #     #  #  #  #         ######   #######  #     #   #####   #####    
// #     #   #   #   #     #         #        #     #  #######        #  #        
// #     #    # #    #     #         #        #     #  #     #  #     #  #        
//  #####      #     #     #  #####  #        #     #  #     #   #####   #######  
///////////////////////////////////////////////////////////////////////////////// 
function void concerto_fsc_tasks::build_phase(uvm_phase phase);

   if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_concerto_env_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end   
      if(!(uvm_config_db #(concerto_env)::get(uvm_root::get(), "", "m_env", m_concerto_env)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end  
     if(!(uvm_config_db #(concerto_test_cfg)::get(uvm_root::get(), "", "test_cfg", test_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_test_cfg object in UVM DB");
    end
     <% if(obj.useResiliency == 1) { %>
    uvm_config_db#(bit)::set(uvm_root::get(),"*", "include_coverage", 0);
    mission_fault_detected = new("mission_fault_detected");
    if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "mission_fault_detected" ),
                                    .value( mission_fault_detected ))) begin
       `uvm_error("Fsc test", "Event mission_fault_detected is not found")
    end
    latent_fault_detected = new("latent_fault_detected");
    if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "latent_fault_detected" ),
                                    .value( latent_fault_detected ))) begin
       `uvm_error("Fsc test", "Event latent_fault_detected is not found")
    end
    cerr_over_thresh_fault_detected = new("cerr_over_thresh_fault_detected");
    if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "cerr_over_thresh_fault_detected" ),
                                    .value( cerr_over_thresh_fault_detected ))) begin
       `uvm_error("Fsc test", "Event cerr_over_thresh_fault_detected is not found")
    end
    injectSingleErr = new("injectSingleErr");
    if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "injectSingleErr" ),
                                    .value( injectSingleErr))) begin
       `uvm_error("Fsc test", "Event injectSingleErr is not found")
    end
<% } %>

endfunction : build_phase

task concerto_fsc_tasks::fsys_fsc_misc_task(uvm_phase phase); 
`uvm_info("FSC_TASKS", "START fsys_fsc_misc_task", UVM_LOW)
phase.raise_objection(this, "fsys_fsc_misc_task");
  <% if(obj.useResiliency == 1) { %>
      uvm_resource_db#(bit)::set({"REG::",m_concerto_env.resiliency_m_regs.fsc.FSCMF0.get_full_name()}, "NO_REG_TESTS", 1,this);
      uvm_resource_db#(bit)::set({"REG::",m_concerto_env.resiliency_m_regs.fsc.FSCMF1.get_full_name()}, "NO_REG_TESTS", 1,this);
      uvm_resource_db#(bit)::set({"REG::",m_concerto_env.resiliency_m_regs.fsc.FSCMF2.get_full_name()}, "NO_REG_TESTS", 1,this);
      uvm_resource_db#(bit)::set({"REG::",m_concerto_env.resiliency_m_regs.fsc.FSCMF3.get_full_name()}, "NO_REG_TESTS", 1,this);

    if($test$plusargs("kickoff_bist_sequence_after_reset"))begin
      #100ns;
      run_bist_seq(1);
    end

    if($test$plusargs("use_fsys_fsc_reg_bit_bash_seq"))begin
    // #Stimulus.FSYS.FSC_ral_bit_bash
      reg_bit_bash_seq       = uvm_reg_bit_bash_seq::type_id::create("reg_bit_bash_seq");
      reg_bit_bash_seq.model = m_concerto_env.resiliency_m_regs;
      phase.raise_objection(this, "Start CONCERTO FSC bit-bash sequence");
      `uvm_info("FSC_bitbash_seq", "Starting CONCERTO FSC CSR bit-bash sequence",UVM_NONE)
      reg_bit_bash_seq.start(m_concerto_env.inhouse.m_apb_resiliency_agent.m_apb_sequencer);
      `uvm_info("FSC_bitbash_seq", "CONCERTO FSC CSR bit-bash sequence End",UVM_NONE)
      phase.drop_objection(this, "Finish CONCERTO FSC bit-bash sequence");
    end
    if($test$plusargs("use_fsys_fsc_reg_hw_reset_seq"))begin
    // #Stimulus.FSYS.FSC_ral_rst
      reg_hw_reset_seq       = uvm_reg_hw_reset_seq::type_id::create("reg_hw_reset_seq");
      reg_hw_reset_seq.model = m_concerto_env.resiliency_m_regs;
      phase.raise_objection(this, "Start CONCERTO FSC hw-reset sequence");
      `uvm_info("FSC_bitbash_seq", "Starting CONCERTO FSC CSR hw-reset sequence",UVM_NONE)
      reg_hw_reset_seq.start(m_concerto_env.inhouse.m_apb_resiliency_agent.m_apb_sequencer);
      `uvm_info("FSC_bitbash_seq", "CONCERTO FSC CSR hw-reset sequence End",UVM_NONE)
      phase.drop_objection(this, "Finish CONCERTO FSC hw-reset sequence");
    end
  <% } %>
phase.drop_objection(this, "fsys_fsc_misc_task");
fsys_fsc_misc_task_done.trigger();
`uvm_info("FSC_TASKS", "END fsys_fsc_misc_task", UVM_LOW)
endtask:fsys_fsc_misc_task

task concerto_fsc_tasks::fsys_fsc_main_task (uvm_phase phase); 
int bist_wait_clock_cycles;
`uvm_info("FSC_TASKS", "START fsys_fsc_main_task", UVM_LOW)

if($test$plusargs("disable_bist"))
    bist_wait_clock_cycles = 20;
else    
    bist_wait_clock_cycles = 4096;
  <% if(obj.useResiliency == 1) { %>
  if($test$plusargs("inject_uncorrectable_error")) begin:_inject_uncorr_error
      bit[31:0]  read_data;
      bit[31:0]  write_data;
      bit bist_seq_automatic_manual;  
      uvm_status_e   status;
      uvm_object objectors_list[$];
      uvm_objection objection;
      int num_dce_signals_for_uncorr_err_inj     ; 
      int num_dmi_signals_for_uncorr_err_inj     ; 
      int num_dve_signals_for_uncorr_err_inj     ; 
      int num_dii_signals_for_uncorr_err_inj     ; 
      int num_ioaiu_signals_for_uncorr_err_inj   ; 
      int num_chi_aiu_signals_for_uncorr_err_inj ;
      int num_times_uncorr_err_inj;
      int bist_step_count;
      bit release_timer_err;
      bit FSCBISTCR_single_write_en;
      bit FSCBISTCR_bist_engine_mix_mode;
      bit FSCBISTCR_bist_engine_mix_mode_done;
      bit FSCBISTCR_bist_engine_kickoff_done;

     if(!uvm_config_db#(int unsigned)::get(null, "", "num_dce_signals_for_uncorr_err_inj", num_dce_signals_for_uncorr_err_inj    )) begin
         `uvm_fatal("Concerto_Uncorr_Error_test", "Not getting value of num_dce_signals_for_uncorr_err_inj through uvm_config_db")
     end
     if(!uvm_config_db#(int unsigned)::get(null, "", "num_dmi_signals_for_uncorr_err_inj", num_dmi_signals_for_uncorr_err_inj    )) begin
         `uvm_fatal("Concerto_Uncorr_Error_test", "Not getting value of num_dmi_signals_for_uncorr_err_inj through uvm_config_db")
     end
     if(!uvm_config_db#(int unsigned)::get(null, "", "num_dve_signals_for_uncorr_err_inj", num_dve_signals_for_uncorr_err_inj    )) begin
         `uvm_fatal("Concerto_Uncorr_Error_test", "Not getting value of num_dve_signals_for_uncorr_err_inj through uvm_config_db")
     end
     if(!uvm_config_db#(int unsigned)::get(null, "", "num_dii_signals_for_uncorr_err_inj", num_dii_signals_for_uncorr_err_inj    )) begin
         `uvm_fatal("Concerto_Uncorr_Error_test", "Not getting value of num_dii_signals_for_uncorr_err_inj through uvm_config_db")
     end
     if(!uvm_config_db#(int unsigned)::get(null, "", "num_ioaiu_signals_for_uncorr_err_inj", num_ioaiu_signals_for_uncorr_err_inj  )) begin
         `uvm_fatal("Concerto_Uncorr_Error_test", "Not getting value of num_ioaiu_signals_for_uncorr_err_inj through uvm_config_db")
     end
     if(!uvm_config_db#(int unsigned)::get(null, "", "num_chi_aiu_signals_for_uncorr_err_inj", num_chi_aiu_signals_for_uncorr_err_inj)) begin
         `uvm_fatal("Concerto_Uncorr_Error_test", "Not getting value of num_chi_aiu_signals_for_uncorr_err_inj through uvm_config_db")
     end
     num_times_uncorr_err_inj = num_dce_signals_for_uncorr_err_inj + num_dmi_signals_for_uncorr_err_inj + num_dve_signals_for_uncorr_err_inj + num_dii_signals_for_uncorr_err_inj + num_ioaiu_signals_for_uncorr_err_inj + num_chi_aiu_signals_for_uncorr_err_inj;
      `uvm_info("Concerto_Uncorr_Error_test", $psprintf("num_dce_signals_for_uncorr_err_inj %0d,num_dmi_signals_for_uncorr_err_inj %0d,num_dve_signals_for_uncorr_err_inj %0d,num_dii_signals_for_uncorr_err_inj %0d,num_ioaiu_signals_for_uncorr_err_inj %0d,num_chi_aiu_signals_for_uncorr_err_inj %0d",num_dce_signals_for_uncorr_err_inj,num_dmi_signals_for_uncorr_err_inj,num_dve_signals_for_uncorr_err_inj,num_dii_signals_for_uncorr_err_inj,num_ioaiu_signals_for_uncorr_err_inj,num_chi_aiu_signals_for_uncorr_err_inj),UVM_LOW)
      `uvm_info("Concerto_Uncorr_Error_test", "Starting CONCERTO FSC uncorr sequence",UVM_LOW)
      fork
      begin
        phase.raise_objection(this, "Concerto_Uncorr_Error_test");
        repeat(num_times_uncorr_err_inj) begin
          `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Waiting for Event mission_fault_detected to be triggered"), UVM_LOW);
          if(mission_fault_detected.is_off()) begin
             mission_fault_detected.wait_trigger();
             if(!uvm_config_db#(int unsigned)::get(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication)) begin
                 `uvm_fatal("Concerto_Uncorr_Error_test", "Not getting value of uncorr_err_inj_test_start_indication through uvm_config_db")
             end
             if(uncorr_err_inj_test_start_indication==0)
                 `uvm_error("Concerto_Uncorr_Error_test", "mission fault detected without uncorrectable error injection")

             // #Check.FSYS.FSC_SCMFX_regs_uncorrect_err
             fsc_regs_check();
          end

          `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Event mission_fault_detected triggered"), UVM_LOW);

          if($test$plusargs("bist_auto")) begin
            $value$plusargs("bist_auto=%0d",bist_seq_automatic_manual);
          end else begin
            bist_seq_automatic_manual =  $urandom_range(0,1); // Deciding if start automatic bist seq or manual
          end

          if($test$plusargs("FSCBISTCR_single_write_en")) begin
            $value$plusargs("FSCBISTCR_single_write_en=%0d",FSCBISTCR_single_write_en);
          end else begin
            FSCBISTCR_single_write_en =  $urandom_range(0,1); // Deciding whether to start BIST engine in single write or double write 
          end

          if($test$plusargs("FSCBISTCR_bist_engine_mix_mode")) begin
            $value$plusargs("FSCBISTCR_bist_engine_mix_mode=%0d",FSCBISTCR_bist_engine_mix_mode);
          end else begin
            FSCBISTCR_bist_engine_mix_mode =  $urandom_range(0,1); // Deciding whether to start BIST engine in sequential mode after step mode 
          end

          FSCBISTCR_bist_engine_kickoff_done = 0;
          FSCBISTCR_bist_engine_mix_mode_done = 0;

          m_concerto_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
          `uvm_info("Concerto_Uncorr_Error_test",$psprintf("FSCBISTAR: Read data 32'h%8h before writing to FSCBISTCR reg",read_data),UVM_LOW)
          `uvm_info("Concerto_Uncorr_Error_test",$psprintf("Start BIST engine in %0s to FSCBISTCR",(FSCBISTCR_single_write_en==1)?"single write":"double write"),UVM_LOW)
          release_timer_err = 0;
          bist_step_count = 0;
          if(bist_seq_automatic_manual==0) begin //Manual Bist Seq
         // #Stimulus.FSYS.FSC_uncorr_manual
          int bist_step_loop_cnt=1;
          bit [5:0]bist_state, bist_state_prev;
          bit bist_state_1,  bist_state_3, bist_state_7, bist_state_F, bist_state_1F, bist_state_3F;
          int temp=1;
          uvm_event bist_seq_updated = new("bist_seq_updated"); 
          fork
            begin
                //#Stimulus.FSYS.BIST.step_by_step
                repeat(6) begin
                  if((bist_state_1>=1) && (FSCBISTCR_bist_engine_mix_mode==1) && (FSCBISTCR_bist_engine_mix_mode_done==0)) begin : FSCBISTCR_bist_engine_mix_mode_initiation
                      `uvm_info("Concerto_Uncorr_Error_test", "Starting BIST engine in sequential mode after step mode",UVM_NONE)
                      if(FSCBISTCR_single_write_en==0) begin
                          write_data = 'h2;
                          `uvm_info("Concerto_Uncorr_Error_test", "Writing 1st location of FSCBISTCR to 1 to set Sequential mode - BIST FSM runs all 6 BIST steps in sequence/automatic Bist seq.",UVM_NONE)
                          m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                      end
                      write_data = 'h3;
                      `uvm_info("Concerto_Uncorr_Error_test", "Writing 0th location of FSCBISTCR to 1 to start Bist seq engine for Sequential mode",UVM_NONE)
                      m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                      FSCBISTCR_bist_engine_kickoff_done = 1;
                      ev_fsc_bist_start.trigger();
                      fcov_SCBISTCR = write_data;
                      FSCBISTCR_bist_engine_mix_mode_done = 1;
                  end : FSCBISTCR_bist_engine_mix_mode_initiation
                  if ((FSCBISTCR_bist_engine_mix_mode==0) || ((FSCBISTCR_bist_engine_mix_mode==1) && (FSCBISTCR_bist_engine_mix_mode_done==0))) begin
                      if(FSCBISTCR_single_write_en==0) begin
                        write_data = 0;
                        `uvm_info("Concerto_Uncorr_Error_test", "Writing 1st location of FSCBISTCR to 0 to set single step mode",UVM_NONE)
                        m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                      end
                      bist_step_count = bist_step_count + 1;
                      `uvm_info("Concerto_Uncorr_Error_test", "Writing 1st location of FSCBISTCR to start Bist seq engine for Single step mode",UVM_NONE)
                      write_data = 'h1;
                      m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                      FSCBISTCR_bist_engine_kickoff_done = 1;
                      ev_fsc_bist_start.trigger();
                      fcov_SCBISTCR = write_data;
                      sample_cg_fsc_regs();
                  end
                  //repeat(10)@(posedge m_apb_resiliency_cfg.m_vif.clk);      //Clock delay between each bist seq step (manual)
                  //m_concerto_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
                  //`uvm_info("Concerto_Uncorr_Error_test",$psprintf("FSCBISTAR : Read data 32'h%8h expecting step-%0d without any delay",read_data,bist_step_loop_cnt),UVM_LOW)
                  //repeat($urandom_range(25,50))@(posedge m_apb_resiliency_cfg.m_vif.clk); // TODO: CONC-7515
          <%
          var BistDebugDisablePin = 0;
          if(obj.FscInfo.interfaces.bistDebugDisableInt._SKIP_==false){
            BistDebugDisablePin = 1;
          } %>
                  if(!(($test$plusargs("disable_bist"))  && 1'b<%=BistDebugDisablePin%>)) begin
                    if(bist_step_count==5  && $test$plusargs("exp_bist_timeout_err")) begin
                      fork
                      inj_bist_timeout_err(release_timer_err);
                      join_none
                    end
                    bist_seq_updated.wait_trigger();
                  end
                  bist_step_loop_cnt = bist_step_loop_cnt + 1;
                end
            end
            begin
                 // #Check.FSYS.FSCBISTAR.step_by_step_uncorrecterr
                repeat(bist_wait_clock_cycles) begin //Each read takes 5 clocks to complete, Using 2048 loops because step-5 takes 4096 cycles from IOAIU side(DCE & CHI too?)
                    wait(FSCBISTCR_bist_engine_kickoff_done==1);
                    m_concerto_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
                    fcov_SCBISTAR = read_data;
                    sample_cg_fsc_regs();
                    `uvm_info("Concerto_Uncorr_Error_test",$psprintf("FSCBISTAR : Read data 32'h%8h at clock-%0d",read_data,temp),UVM_LOW)
                    if(read_data[5:0] < bist_state) begin
                      `uvm_error("Concerto_Uncorr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg %0h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F transition. Last value 0x%0h Present Value 0x%0h",read_data,bist_state,read_data[5:0]));
                    end
                    if(read_data[11:6] != 0 && !$test$plusargs("exp_bist_timeout_err")) begin
                      `uvm_error("Concerto_Uncorr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg 32'h%8h",read_data));
                    end else if(bist_step_count==5  && $test$plusargs("exp_bist_timeout_err") && (read_data[5:0]=='h1F)) begin
                    // #Cover.FSYS.FSC_unit_timeout_error_Step5
                      if({read_data[11],read_data[9:6]} != 0) 
                         `uvm_error("Concerto_Uncorr_Error_test",$sformatf("Unexpected Error detected in Bist seq, FSCBISTAR Reg 32'h%8h",read_data));
                      if(read_data[10] != 1) 
                         `uvm_error("Concerto_Uncorr_Error_test",$sformatf("Expecting timeout Error in Bist seq, FSCBISTAR Reg 32'h%8h",read_data));
                    end
                    if(read_data[5:0]=='h1) bist_state_1 = 'h1;
                    else if(read_data[5:0]=='h3) bist_state_3 = 'h1;
                    else if(read_data[5:0]=='h7) bist_state_7 = 'h1;
                    else if(read_data[5:0]=='hF) bist_state_F = 'h1;
                    else if(read_data[5:0]=='h1F) begin bist_state_1F = 'h1; release_timer_err = 1;   end
                    else if(read_data[5:0]=='h3F) bist_state_3F = 'h1;
                    bist_state = read_data[5:0];
                    temp = temp+1;
                    if((bist_state=='h3F) && (bist_state_1==1) && (bist_state_3==1) && (bist_state_7==1) && (bist_state_F==1) && (bist_state_1F==1) && (bist_state_3F==1)) begin 
                  // #Cover.FSYS.FSC_bist_done
                        bist_seq_updated.trigger(); break;
                    end else if((bist_state=='h3F) && ((bist_state_1==0) || (bist_state_3==0) || (bist_state_7==0) || (bist_state_F==0) || (bist_state_1F==0) || (bist_state_3F==0))) begin
                        `uvm_error("Concerto_Uncorr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg 32'h%8h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F -> 0x3F transition.",read_data));
                    end else begin
                      if(bist_state != bist_state_prev) begin bist_seq_updated.trigger(); bist_state_prev = bist_state; end
                    end
                end
            end
          join
          end
          else begin //Automatic Bist Seq  
         //#Stimulus.FSYS.BIST.auto_uncorrecterr 
         // #Stimulus.FSYS.FSC_uncorr_auto
            if(FSCBISTCR_single_write_en==0) begin
                write_data = 'h2;
                `uvm_info("Concerto_Uncorr_Error_test", "Writing 1st location of FSCBISTCR to set Sequential mode - BIST FSM runs all 6 BIST steps in sequence/automatic Bist seq.",UVM_NONE)
                m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                fcov_SCBISTCR = write_data;
                sample_cg_fsc_regs();
            end
            write_data = 'h3;
            `uvm_info("Concerto_Uncorr_Error_test", "Writing 0th location of FSCBISTCR to start Bist seq engine",UVM_NONE)
            m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
            FSCBISTCR_bist_engine_kickoff_done = 1;
            ev_fsc_bist_start.trigger();
            fcov_SCBISTCR = write_data;
            sample_cg_fsc_regs();
          end
          //repeat(100) @ (posedge m_apb_resiliency_cfg.m_vif.clk);      //Wait for Bist seq to complete 
          if(bist_seq_automatic_manual) begin
          bit [5:0]bist_state;
          bit bist_state_1,  bist_state_3, bist_state_7, bist_state_F, bist_state_1F, bist_state_3F;
          int temp=1;
          // #Check.FSYS.FSCBISTAR.auto_uncorrecterr
              repeat(bist_wait_clock_cycles) begin  //Each read takes 5 clocks to complete , Using 2048 loops because step-5 takes 4096 cycles from IOAIU side(DCE & CHI too?)
                  wait(FSCBISTCR_bist_engine_kickoff_done==1);
                  m_concerto_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
                  fcov_SCBISTAR = read_data;
                  sample_cg_fsc_regs();
                  `uvm_info("Concerto_Uncorr_Error_test",$psprintf("FSCBISTAR : Read data 32'h%8h at clock-%0d",read_data,temp),UVM_LOW)
                  if(read_data[5:0] < bist_state) begin
                    `uvm_error("Concerto_Uncorr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg 32'h%8h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F transition. Last value 0x%0h Present Value 0x%0h",read_data,bist_state,read_data[5:0]));
                  end
                  if(read_data[5:0]=='h1) begin  bist_state_1 = 'h1; bist_step_count = bist_step_count+1; end
                  else if(read_data[5:0]=='h3) begin  bist_state_3 = 'h1; bist_step_count = bist_step_count+1; end
                  else if(read_data[5:0]=='h7) begin  bist_state_7 = 'h1; bist_step_count = bist_step_count+1; end
                  else if(read_data[5:0]=='hF) begin  bist_state_F = 'h1; bist_step_count = bist_step_count+1; end
                  else if(read_data[5:0]=='h1F) begin  
                      bist_state_1F = 'h1; bist_step_count = bist_step_count+1; release_timer_err = 1; 
                  end
                  else if(read_data[5:0]=='h3F) begin  bist_state_3F = 'h1; bist_step_count = bist_step_count+1; end
                  bist_state = read_data[5:0];
                  if(read_data[11:6] != 0 && !$test$plusargs("exp_bist_timeout_err")) begin
                    `uvm_error("Concerto_Uncorr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg 32'h%8h",read_data));
                  end else if(bist_step_count==5  && $test$plusargs("exp_bist_timeout_err") && (read_data[5:0]=='h1F)) begin
                    if({read_data[11],read_data[9:6]} != 0) 
                       `uvm_error("Concerto_Uncorr_Error_test",$sformatf("Unexpected Error detected in Bist seq, FSCBISTAR Reg 32'h%8h",read_data));
                    if(read_data[10] != 1) 
                       `uvm_error("Concerto_Uncorr_Error_test",$sformatf("Expecting timeout Error in Bist seq, FSCBISTAR Reg 32'h%8h",read_data));
                  end
                  temp = temp+1;
                  if((bist_state=='h3F) && (bist_state_1==1) && (bist_state_3==1) && (bist_state_7==1) && (bist_state_F==1) && (bist_state_1F==1) && (bist_state_3F==1)) begin 
                  // #Cover.FSYS.FSC_bist_done
                      break;
                  end else if((bist_state=='h3F) && ((bist_state_1==0) || (bist_state_3==0) || (bist_state_7==0) || (bist_state_F==0) || (bist_state_1F==0) || (bist_state_3F==0))) begin
                      `uvm_error("Concerto_Uncorr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg 32'h%8h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F -> 0x3F transition.",read_data));
                  end
              end
          end
          <%
          var BistDebugDisablePin = 0;
          if(obj.FscInfo.interfaces.bistDebugDisableInt._SKIP_==false){
            BistDebugDisablePin = 1;
          } %>
          if(( ($test$plusargs("disable_bist") && 1'b<%=BistDebugDisablePin%>) && read_data[5:0] != 'h00) ||
             ((!$test$plusargs("disable_bist") || !1'b<%=BistDebugDisablePin%>) && read_data[5:0] != 'h3F)) begin
           `uvm_error("Concerto_Uncorr_Error_test",$sformatf("Something went wrong in Bist seq, FSCBISTAR Reg 32'h%8h",read_data));
          end
          // average around 400 clk gets consumed by now in this thread. so set around 500 for next UCE injection
        end
        phase.drop_objection(this, "Concerto_Uncorr_Error_test");
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("%0d times checked the BIST CSR flow, now exiting...",num_times_uncorr_err_inj), UVM_LOW);
        // Fetching the objection from current phase
        objection = phase.get_objection();
        // Collecting all the objectors which currently have objections raised
        objection.get_objectors(objectors_list);
        // Dropping the objections forcefully
        foreach(objectors_list[i]) begin
          uvm_report_info("run_main", $sformatf("objection count %d", objection.get_objection_count(objectors_list[i])),UVM_MEDIUM);
          while(objection.get_objection_count(objectors_list[i]) != 0) begin
            phase.drop_objection(objectors_list[i], "dropping objections to kill the test");
          end
        end
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Jumping to report_phase"), UVM_LOW);
        phase.jump(uvm_report_phase::get());
      end
      join_none
    end:_inject_uncorr_error

    if($test$plusargs("fsc_inject_correctable_err") || $test$plusargs("LATENT_FAULT_CHK_XOR_TREE"))begin:_ceth_and_latent_fault_test_
      bit[31:0]  read_data;
      bit[31:0]  write_data;
      bit bist_seq_automatic_manual;  
      uvm_status_e   status;
      uvm_object objectors_list[$];
      uvm_objection objection;
      int num_dce_signals_for_corr_err_inj     ; 
      int num_dmi_signals_for_corr_err_inj     ; 
      int num_dve_signals_for_corr_err_inj     ; 
      int num_dii_signals_for_corr_err_inj     ; 
      int num_ioaiu_signals_for_corr_err_inj   ; 
      int num_chi_aiu_signals_for_corr_err_inj ;
      int num_times_corr_err_inj;
      bit FSCBISTCR_single_write_en;
      bit FSCBISTCR_bist_engine_mix_mode;
      bit FSCBISTCR_bist_engine_mix_mode_done;
      bit FSCBISTCR_bist_engine_kickoff_done;
      logic [<%=numChiAiu%> -1:0]          expected_caiu_latent_fault_reg;
      logic [<%=numIoAiu%> -1:0]           expected_ioaiu_latent_fault_reg;
      logic [<%=obj.DmiInfo.length%> -1:0] expected_dmi_latent_fault_reg;
      logic [<%=obj.DiiInfo.length%> -1:0] expected_dii_latent_fault_reg;
      logic [<%=obj.DveInfo.length%> -1:0] expected_dve_latent_fault_reg;
      logic [<%=obj.DceInfo.length%> -1:0] expected_dce_latent_fault_reg;
      logic [159:0] expected_latent_fault_reg;

      fork
      begin
        phase.raise_objection(this, "Concerto_corr_Error_test");
        if(!($test$plusargs("k_chiaiu_access_boot_region")) && !($test$plusargs("k_access_boot_region"))) begin
            //csr_init_done.wait_trigger();
        end else
            #1000ns;
        if($test$plusargs("LATENT_FAULT_CHK_XOR_TREE")) begin
            num_times_corr_err_inj = 1; 
        end 
        else begin
            if(!uvm_config_db#(int unsigned)::get(null, "", "num_dce_signals_for_corr_err_inj", num_dce_signals_for_corr_err_inj    )) begin
                `uvm_fatal("Concerto_corr_Error_test", "Not getting value of num_dce_signals_for_corr_err_inj through uvm_config_db")
            end
            if(!uvm_config_db#(int unsigned)::get(null, "", "num_dmi_signals_for_corr_err_inj", num_dmi_signals_for_corr_err_inj    )) begin
                `uvm_fatal("Concerto_corr_Error_test", "Not getting value of num_dmi_signals_for_corr_err_inj through uvm_config_db")
            end
            if(!uvm_config_db#(int unsigned)::get(null, "", "num_dve_signals_for_corr_err_inj", num_dve_signals_for_corr_err_inj    )) begin
                `uvm_fatal("Concerto_corr_Error_test", "Not getting value of num_dve_signals_for_corr_err_inj through uvm_config_db")
            end
            if(!uvm_config_db#(int unsigned)::get(null, "", "num_dii_signals_for_corr_err_inj", num_dii_signals_for_corr_err_inj    )) begin
                `uvm_fatal("Concerto_corr_Error_test", "Not getting value of num_dii_signals_for_corr_err_inj through uvm_config_db")
            end
            if(!uvm_config_db#(int unsigned)::get(null, "", "num_ioaiu_signals_for_corr_err_inj", num_ioaiu_signals_for_corr_err_inj  )) begin
                `uvm_fatal("Concerto_corr_Error_test", "Not getting value of num_ioaiu_signals_for_corr_err_inj through uvm_config_db")
            end
            if(!uvm_config_db#(int unsigned)::get(null, "", "num_chi_aiu_signals_for_corr_err_inj", num_chi_aiu_signals_for_corr_err_inj)) begin
                `uvm_fatal("Concerto_corr_Error_test", "Not getting value of num_chi_aiu_signals_for_corr_err_inj through uvm_config_db")
            end
            num_times_corr_err_inj = num_dce_signals_for_corr_err_inj + num_dmi_signals_for_corr_err_inj + num_dve_signals_for_corr_err_inj + num_dii_signals_for_corr_err_inj + num_ioaiu_signals_for_corr_err_inj + num_chi_aiu_signals_for_corr_err_inj;
            `uvm_info("Concerto_corr_Error_test", $psprintf("num_dce_signals_for_corr_err_inj %0d,num_dmi_signals_for_corr_err_inj %0d,num_dve_signals_for_corr_err_inj %0d,num_dii_signals_for_corr_err_inj %0d,num_ioaiu_signals_for_corr_err_inj %0d,num_chi_aiu_signals_for_corr_err_inj %0d",num_dce_signals_for_corr_err_inj,num_dmi_signals_for_corr_err_inj,num_dve_signals_for_corr_err_inj,num_dii_signals_for_corr_err_inj,num_ioaiu_signals_for_corr_err_inj,num_chi_aiu_signals_for_corr_err_inj),UVM_LOW)
        end
// #Stimulus.FSYS.v370.FSC_Latent_Fault        
// #Cover.FSYS.v370.FSC_Latent_Fault
        for(int iter=0;iter<num_times_corr_err_inj;iter=iter+1) begin
            if((iter==0) && ($test$plusargs("LATENT_FAULT_CHK_XOR_TREE"))) begin : _iter_0_ // iter==0 is for latent_fault
<% if(unit_dup) { %>
              expected_caiu_latent_fault_reg = '1;
              expected_ioaiu_latent_fault_reg = '1;
              expected_dmi_latent_fault_reg = '1;
              expected_dii_latent_fault_reg = '1;
              expected_dve_latent_fault_reg = '1;
              expected_dce_latent_fault_reg = '1;
              expected_latent_fault_reg [31:0]    = {{32-$bits(expected_caiu_latent_fault_reg){1'b0}},expected_caiu_latent_fault_reg};
              expected_latent_fault_reg [63:32]   = {{32-$bits(expected_ioaiu_latent_fault_reg){1'b0}},expected_ioaiu_latent_fault_reg};
              expected_latent_fault_reg [95:64]   = {{32-$bits(expected_dmi_latent_fault_reg){1'b0}},expected_dmi_latent_fault_reg};
              expected_latent_fault_reg [127:96]  = {{32-$bits(expected_dii_latent_fault_reg){1'b0}},expected_dii_latent_fault_reg};
              expected_latent_fault_reg [143:128] = {{16-$bits(expected_dce_latent_fault_reg){1'b0}},expected_dce_latent_fault_reg};
              expected_latent_fault_reg [158:144] = 15'b0;
              expected_latent_fault_reg [159]     = expected_dve_latent_fault_reg;

              // @(posedge tb_top.dut.dve0.u_fault_checker.clk);
              // force tb_top.dut.dve0.u_fault_checker.latent_fault_xor_tree.fault_tree_out = 1;
              // @(posedge tb_top.dut.dve0.u_fault_checker.clk);
              // release tb_top.dut.dve0.u_fault_checker.latent_fault_xor_tree.fault_tree_out;
              fork
           <% if(numIoAiu>0) { %>
           <% var ioaiu_index = 0;
           for (var i = 0; i<(obj.AiuInfo.length); i++) { %>
           <% if ((obj.AiuInfo[i].fnNativeInterface != "CHI-A") && (obj.AiuInfo[i].fnNativeInterface != "CHI-B")  && (obj.AiuInfo[i].fnNativeInterface != "CHI-E")) { %>
              begin
                  @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
                  force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_checker.latent_fault_xor_tree.fault_tree_out = 1;
                  @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
                  release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.dup_checker.latent_fault_xor_tree.fault_tree_out;
              end
           <% ioaiu_index = ioaiu_index + 1; } %>
           <% } } %>

           <% if(numChiAiu>0) { %>
           <% var chiaiu_index = 0; 
           for (var i = 0; i<(obj.AiuInfo.length); i++) { %>
           <% if ((obj.AiuInfo[i].fnNativeInterface == "CHI-A") || (obj.AiuInfo[i].fnNativeInterface == "CHI-B") || (obj.AiuInfo[i].fnNativeInterface == "CHI-E")) { %>
              begin
                  @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
                  force <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.u_chi_aiu_fault_checker.latent_fault_xor_tree.fault_tree_out = 1;
                  @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
                  release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.u_chi_aiu_fault_checker.latent_fault_xor_tree.fault_tree_out;
              end
           <% chiaiu_index = chiaiu_index+1; } %>
           <% } } %>

          <% for (var i = 0; i<obj.DceInfo.length; i++) { %>
              begin
	          <%if(obj.DceInfo[i].hierPath && obj.DceInfo[i].hierPath !== ''){%>
                      @(posedge <%=hier_path_dut%>.<%=obj.DceInfo[i].hierPath%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
                      force <%=hier_path_dut%>.<%=obj.DceInfo[i].hierPath%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.u_dce_fault_checker.latent_fault_xor_tree.fault_tree_out = 1;
                      @(posedge <%=hier_path_dut%>.<%=obj.DceInfo[i].hierPath%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
                      release <%=hier_path_dut%>.<%=obj.DceInfo[i].hierPath%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.u_dce_fault_checker.latent_fault_xor_tree.fault_tree_out;
		  <% } else { %>
                      @(posedge <%=hier_path_dut%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
                      force <%=hier_path_dut%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.u_dce_fault_checker.latent_fault_xor_tree.fault_tree_out = 1;
                      @(posedge <%=hier_path_dut%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
                      release <%=hier_path_dut%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.u_dce_fault_checker.latent_fault_xor_tree.fault_tree_out;
		  <% } %>
              end
          <% } %>

          <% for (var i = 0; i<obj.DmiInfo.length; i++) { %>
              begin
	          <%if(obj.DmiInfo[i].hierPath && obj.DmiInfo[i].hierPath !== ''){%>
                      @(posedge <%=hier_path_dut%>.<%=obj.DmiInfo[i].hierPath%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
                      force <%=hier_path_dut%>.<%=obj.DmiInfo[i].hierPath%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.u_dmi_fault_checker.latent_fault_xor_tree.fault_tree_out = 1;
                      @(posedge <%=hier_path_dut%>.<%=obj.DmiInfo[i].hierPath%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
                      release <%=hier_path_dut%>.<%=obj.DmiInfo[i].hierPath%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.u_dmi_fault_checker.latent_fault_xor_tree.fault_tree_out;
		  <% } else { %>
                      @(posedge <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
                      force <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.u_dmi_fault_checker.latent_fault_xor_tree.fault_tree_out = 1;
                      @(posedge <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
                      release <%=hier_path_dut%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.u_dmi_fault_checker.latent_fault_xor_tree.fault_tree_out;
		  <% } %>
              end
          <% } %>

          <% for (var i = 0; i<obj.DiiInfo.length; i++) { %>
              begin
                  @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
                  force <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.u_dii_fault_checker.latent_fault_xor_tree.fault_tree_out = 1;
                  @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
                  release <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.u_dii_fault_checker.latent_fault_xor_tree.fault_tree_out;
              end
          <% } %>

          <% for (var i = 0; i<obj.DveInfo.length; i++) { %>
              begin
                  @(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
                  force <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.u_fault_checker.latent_fault_xor_tree.fault_tree_out = 1;
                  @(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
                  release <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.u_fault_checker.latent_fault_xor_tree.fault_tree_out;
              end
          <% } %>
             join_none

                
                `uvm_info("Concerto_corr_Error_test", $sformatf("Waiting for Event latent_fault_detected to be triggered"), UVM_LOW);
                if(latent_fault_detected.is_off()) begin
                   latent_fault_detected.wait_trigger();

                   uvm_config_db#(int unsigned)::set(null, "", "FSCERRR", 0); 

                   uvm_config_db#(int unsigned)::set(null, "", "SCLFX0_latent_fault", expected_latent_fault_reg [31:0]); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCLFX1_latent_fault", expected_latent_fault_reg [63:32]); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCLFX2_latent_fault", expected_latent_fault_reg [95:64]); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCLFX3_latent_fault", expected_latent_fault_reg [127:96]); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCLFX4_latent_fault", expected_latent_fault_reg [159:128]); 

                   uvm_config_db#(int unsigned)::set(null, "", "SCMFX0_mission_fault",0); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCMFX1_mission_fault",0); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCMFX2_mission_fault",0); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCMFX3_mission_fault",0); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCMFX4_mission_fault",0); 

                   uvm_config_db#(int unsigned)::set(null, "", "SCCETHF0", 0); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCCETHF1", 0); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCCETHF2", 0); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCCETHF3", 0); 
                   uvm_config_db#(int unsigned)::set(null, "", "SCCETHF4", 0);
                   // #Check.FSYS.FSC_SCLFX_regs_uncorrect_err
                   fsc_regs_check();
                   expected_latent_fault_reg = 0;
                   expected_caiu_latent_fault_reg = '0;
                   expected_ioaiu_latent_fault_reg = '0;
                   expected_dmi_latent_fault_reg = '0;
                   expected_dii_latent_fault_reg = '0;
                   expected_dve_latent_fault_reg = '0;
                   expected_dce_latent_fault_reg = '0;
                end
<% } %>
            end : _iter_0_
            else begin : _high_iter_
                injectSingleErr.trigger();
                `uvm_info("Concerto_corr_Error_test", $sformatf("Waiting for Event cerr_over_thresh_fault_detected to be triggered"), UVM_LOW);
                if(cerr_over_thresh_fault_detected.is_off()) begin
                   cerr_over_thresh_fault_detected.wait_trigger();
                   if(!uvm_config_db#(int unsigned)::get(null, "", "corr_err_inj_test_start_indication", corr_err_inj_test_start_indication)) begin
                       `uvm_fatal("Concerto_corr_Error_test", "Not getting value of corr_err_inj_test_start_indication through uvm_config_db")
                   end
                   if(corr_err_inj_test_start_indication==0)
                       `uvm_error("Concerto_corr_Error_test", "cerr_over_thresh_fault detected without correctable error injection")

                 // #Check.FSYS.FSC_CETHF_regs_correcterr
                   fsc_regs_check();
                end
                `uvm_info("Concerto_corr_Error_test", $sformatf("Event latent triggered"), UVM_LOW);
            end : _high_iter_


            if($test$plusargs("bist_auto")) begin
              $value$plusargs("bist_auto=%0d",bist_seq_automatic_manual);
            end else begin
              bist_seq_automatic_manual =  $urandom_range(0,1); // Deciding if start automatic bist seq or manual
            end

            if($test$plusargs("FSCBISTCR_single_write_en")) begin
              $value$plusargs("FSCBISTCR_single_write_en=%0d",FSCBISTCR_single_write_en);
            end else begin
              FSCBISTCR_single_write_en =  $urandom_range(0,1); // Deciding whether to start BIST engine in single write or double write 
            end

            if($test$plusargs("FSCBISTCR_bist_engine_mix_mode")) begin
              $value$plusargs("FSCBISTCR_bist_engine_mix_mode=%0d",FSCBISTCR_bist_engine_mix_mode);
            end else begin
              FSCBISTCR_bist_engine_mix_mode =  $urandom_range(0,1); // Deciding whether to start BIST engine in sequential mode after step mode 
            end

            FSCBISTCR_bist_engine_kickoff_done = 0;
            FSCBISTCR_bist_engine_mix_mode_done = 0;
            m_concerto_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
            `uvm_info("Concerto_corr_Error_test",$psprintf("FSCBISTAR: Read data 32'h%8h before writing to FSCBISTCR reg",read_data),UVM_LOW)
            `uvm_info("Concerto_corr_Error_test",$psprintf("Start BIST engine in %0s to FSCBISTCR",(FSCBISTCR_single_write_en==1)?"single write":"double write"),UVM_LOW)
            if(bist_seq_automatic_manual==0) begin //Manual Bist Seq
            // #Stimulus.FSYS.FSC_corr_manual
            int bist_step_loop_cnt=1;
            bit [5:0]bist_state, bist_state_prev;
            bit bist_state_1,  bist_state_3, bist_state_7, bist_state_F, bist_state_1F, bist_state_3F;
            uvm_event bist_seq_updated = new("bist_seq_updated"); 
            int temp=1;
              fork
              begin
                  // #Stimulus.FSYS.BIST.step_by_step_correcterr
                  repeat(6) begin
                    if((bist_state_1>=1) && (FSCBISTCR_bist_engine_mix_mode==1) && (FSCBISTCR_bist_engine_mix_mode_done==0)) begin : FSCBISTCR_bist_engine_mix_mode_initiation
                        `uvm_info("Concerto_corr_Error_test", "Starting BIST engine in sequential mode after step mode",UVM_NONE)
                        if(FSCBISTCR_single_write_en==0) begin
                            write_data = 'h2;
                            `uvm_info("Concerto_corr_Error_test", "Writing 1st location of FSCBISTCR to 1 to set Sequential mode - BIST FSM runs all 6 BIST steps in sequence/automatic Bist seq.",UVM_NONE)
                            m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                        end
                        write_data = 'h3;
                        `uvm_info("Concerto_corr_Error_test", "Writing 0th location of FSCBISTCR to 1 to start Bist seq engine for Sequential mode",UVM_NONE)
                        m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                        FSCBISTCR_bist_engine_kickoff_done = 1;
                        ev_fsc_bist_start.trigger();
                        fcov_SCBISTCR = write_data;
                        FSCBISTCR_bist_engine_mix_mode_done = 1;
                    end : FSCBISTCR_bist_engine_mix_mode_initiation
                    if ((FSCBISTCR_bist_engine_mix_mode==0) || ((FSCBISTCR_bist_engine_mix_mode==1) && (FSCBISTCR_bist_engine_mix_mode_done==0))) begin
                        if(FSCBISTCR_single_write_en==0) begin
                          write_data = 0;
                          `uvm_info("Concerto_corr_Error_test", "Writing 1st location of FSCBISTCR to 0 to set single step mode",UVM_NONE)
                          m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                        end
                        `uvm_info("Concerto_corr_Error_test", "Writing 1st location of FSCBISTCR to 1 to start Bist seq engine for Single step mode",UVM_NONE)
                        write_data = 'h1;
                        m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                        FSCBISTCR_bist_engine_kickoff_done = 1;
                        ev_fsc_bist_start.trigger();
                        fcov_SCBISTCR = write_data;
                        if($test$plusargs("LATENT_FAULT_CHK_XOR_TREE")) begin
                            for(int i=0;i<32;i=i+1) begin
                                {fcov_SCLF4,fcov_SCLF3,fcov_SCLF2,fcov_SCLF1,fcov_SCLF0} = 0;
                                fcov_SCLF0[i] = SCLFX0_latent_fault[i];
                                fcov_SCLF1[i] = SCLFX1_latent_fault[i];
                                fcov_SCLF2[i] = SCLFX2_latent_fault[i];
                                fcov_SCLF3[i] = SCLFX3_latent_fault[i];
                                fcov_SCLF4[i] = SCLFX4_latent_fault[i];
                                sample_cg_fsc_regs();
                            end
                        end
                        sample_cg_fsc_regs();
                        //repeat(10)@(posedge m_apb_resiliency_cfg.m_vif.clk);      //Clock delay between each bist seq step (manual)
                        //repeat($urandom_range(25,50))@(posedge m_apb_resiliency_cfg.m_vif.clk); // TODO: CONC-7515
                        if(!(($test$plusargs("disable_bist"))  && 1'b<%=BistDebugDisablePin%>))
                          bist_seq_updated.wait_trigger();
                        bist_step_loop_cnt = bist_step_loop_cnt + 1;
                    end 
                  end
              end
              begin
                 // #Check.FSYS.FSCBISTAR.step_by_step_correcterr
                repeat(bist_wait_clock_cycles) begin  //Each read takes 5 clocks to complete 
                    wait(FSCBISTCR_bist_engine_kickoff_done==1);
                    m_concerto_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
                    fcov_SCBISTAR = read_data;
                    sample_cg_fsc_regs();
                    `uvm_info("Concerto_corr_Error_test",$psprintf("FSCBISTAR : Read data 32'h%8h at clock-%0d",read_data,temp),UVM_LOW)
                    if(read_data[5:0] < bist_state) begin
                      `uvm_error("Concerto_corr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg 32%8h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F transition. Last value 0x%0h Present Value 0x%0h",read_data,bist_state,read_data[5:0]));
                    end
                    if(read_data[11:6] != 0) begin
                      `uvm_error("Concerto_corr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg 32'h%8h",read_data));
                    end
                    if(read_data[5:0]=='h1) bist_state_1 = 'h1;
                    else if(read_data[5:0]=='h3) bist_state_3 = 'h1;
                    else if(read_data[5:0]=='h7) bist_state_7 = 'h1;
                    else if(read_data[5:0]=='hF) bist_state_F = 'h1;
                    else if(read_data[5:0]=='h1F) bist_state_1F = 'h1;
                    else if(read_data[5:0]=='h3F) bist_state_3F = 'h1;
                    bist_state = read_data[5:0];
                    temp = temp+1;
                    if((bist_state=='h3F) && (bist_state_1==1) && (bist_state_3==1) && (bist_state_7==1) && (bist_state_F==1) && (bist_state_1F==1) && (bist_state_3F==1)) begin 
                        bist_seq_updated.trigger(); break;
                    end else if((bist_state=='h3F) && ((bist_state_1==0) || (bist_state_3==0) || (bist_state_7==0) || (bist_state_F==0) || (bist_state_1F==0) || (bist_state_3F==0))) begin
                        `uvm_error("Concerto_corr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg 32'h%0h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F -> 0x3F transition.",read_data));
                    end else begin
                      if(bist_state != bist_state_prev) begin bist_seq_updated.trigger(); bist_state_prev = bist_state; end
                    end
                end
              end
              join
            end
            else begin //Automatic Bist Seq  
            // #Stimulus.FSYS.BIST.auto_correcterr 
            // #Stimulus.FSYS.FSC_corr_auto
              if(FSCBISTCR_single_write_en==0) begin
                  write_data = 'h2;
                  `uvm_info("Concerto_corr_Error_test", "Writing 1st location of FSCBISTCR to 1 to set Sequential mode - BIST FSM runs all 6 BIST steps in sequence/automatic Bist seq.",UVM_NONE)
                  m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                  fcov_SCBISTCR = write_data;
                  sample_cg_fsc_regs();
              end
              write_data = 'h3;
              `uvm_info("Concerto_corr_Error_test", "Writing 0th location of FSCBISTCR to 1 to start Bist seq engine for Sequential mode",UVM_NONE)
              m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
              FSCBISTCR_bist_engine_kickoff_done = 1;
              ev_fsc_bist_start.trigger();
              fcov_SCBISTCR = write_data;
              if($test$plusargs("LATENT_FAULT_CHK_XOR_TREE")) begin
                  for(int i=0;i<32;i=i+1) begin : _fcov_SCBISTCR_2_to_3_transition_sample_
                      {fcov_SCLF4,fcov_SCLF3,fcov_SCLF2,fcov_SCLF1,fcov_SCLF0} = 0;
                      fcov_SCLF0[i] = SCLFX0_latent_fault[i];
                      fcov_SCLF1[i] = SCLFX1_latent_fault[i];
                      fcov_SCLF2[i] = SCLFX2_latent_fault[i];
                      fcov_SCLF3[i] = SCLFX3_latent_fault[i];
                      fcov_SCLF4[i] = SCLFX4_latent_fault[i];
                      sample_cg_fsc_regs();
                  end : _fcov_SCBISTCR_2_to_3_transition_sample_
              end
              sample_cg_fsc_regs();
            end
            //repeat(100) @ (posedge m_apb_resiliency_cfg.m_vif.clk);      //Wait for Bist seq to complete 
            if(bist_seq_automatic_manual) begin
            bit [5:0]bist_state;
            bit bist_state_1,  bist_state_3, bist_state_7, bist_state_F, bist_state_1F, bist_state_3F;
            int temp=1;
            // #Check.FSYS.FSCBISTAR.auto_correcterr
                repeat(bist_wait_clock_cycles) begin  //Each read takes 5 clocks to complete, Using 2048 loops because step-5 takes 4096 cycles from IOAIU side(DCE & CHI too?)
                    wait(FSCBISTCR_bist_engine_kickoff_done==1);
                    m_concerto_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
                    fcov_SCBISTAR = read_data;
                    sample_cg_fsc_regs();
                    `uvm_info("Concerto_corr_Error_test",$psprintf("FSCBISTAR : Read data 32'h%8h at clock-%0d",read_data,temp),UVM_LOW)
                    if(read_data[5:0] < bist_state) begin
                      `uvm_error("Concerto_corr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg %0h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F transition. Last value 0x%0h Present Value 0x%0h",read_data,bist_state,read_data[5:0]));
                    end
                    if(read_data[11:6] != 0) begin
                      `uvm_error("Concerto_corr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg 32'h%8h",read_data));
                    end
                    if(read_data[5:0]=='h1) bist_state_1 = 'h1;
                    else if(read_data[5:0]=='h3) bist_state_3 = 'h1;
                    else if(read_data[5:0]=='h7) bist_state_7 = 'h1;
                    else if(read_data[5:0]=='hF) bist_state_F = 'h1;
                    else if(read_data[5:0]=='h1F) bist_state_1F = 'h1;
                    else if(read_data[5:0]=='h3F) bist_state_3F = 'h1;
                    bist_state = read_data[5:0];
                    temp = temp+1;
                    if((bist_state=='h3F) && (bist_state_1==1) && (bist_state_3==1) && (bist_state_7==1) && (bist_state_F==1) && (bist_state_1F==1) && (bist_state_3F==1)) begin 
                        break;
                    end else if((bist_state=='h3F) && ((bist_state_1==0) || (bist_state_3==0) || (bist_state_7==0) || (bist_state_F==0) || (bist_state_1F==0) || (bist_state_3F==0))) begin
                        `uvm_error("Concerto_corr_Error_test",$sformatf("Error detected in Bist seq, FSCBISTAR Reg 32'h%8h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F -> 0x3F transition.",read_data));
                    end
                end
            end
            <%
            var BistDebugDisablePin = 0;
            if(obj.FscInfo.interfaces.bistDebugDisableInt._SKIP_==false){
              BistDebugDisablePin = 1;
            } %>
            if(( ($test$plusargs("disable_bist") && 1'b<%=BistDebugDisablePin%>) && read_data[5:0] != 'h00) ||
               ((!$test$plusargs("disable_bist") || !1'b<%=BistDebugDisablePin%>) && read_data[5:0] != 'h3F)) begin
             `uvm_error("Concerto_corr_Error_test",$sformatf("Something went wrong in Bist seq, FSCBISTAR Reg 32'h%8h",read_data));
            end
            // average around 400 clk gets consumed by now in this thread. so set around 500 for next UCE injection
        end
        fsc_test_done.trigger();
        phase.drop_objection(this, "Concerto_corr_Error_test");
        `uvm_info("Concerto_corr_Error_test", $sformatf("%0d times checked the BIST CSR flow...",num_times_corr_err_inj), UVM_LOW);
        corr_err_inj_test_start_indication = 0;
      end
      join_none
    end:_ceth_and_latent_fault_test_

    if($test$plusargs("fsc_csr_parity_prot_check_test"))begin:_fsc_csr_parity_prot_check_test
// #Stimulus.FSYS.FSC_CSR_Check_parity
    bit bist_seq_automatic_manual;  
    bit fsc_csr_parity_prot_check_test_fail=0;
    string fsc_csr_parity_prot_check_test_fail_string[$];
    bit latent_fault_detected_check;
    string fsc_reg="";
    fork 
    begin
        phase.raise_objection(this, "fsc_csr_parity_prot_check_test");

        if($test$plusargs("bist_auto")) begin
          $value$plusargs("bist_auto=%0d",bist_seq_automatic_manual);
        end else begin
          bist_seq_automatic_manual =  $urandom_range(0,1); // Deciding if start automatic bist seq or manual
        end

        for(int flop_cnt=0;flop_cnt<18;flop_cnt=flop_cnt+1) begin :_flop_cnt
          if(flop_cnt!=2) begin : _exclude_reg // excluding FSCERRR
            uvm_config_db#(int unsigned)::set(null, "", "FSCERRR", 0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCLFX0_latent_fault", 0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCLFX1_latent_fault", 0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCLFX2_latent_fault", 0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCLFX3_latent_fault", 0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCLFX4_latent_fault", 0); 

            uvm_config_db#(int unsigned)::set(null, "", "SCMFX0_mission_fault",0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCMFX1_mission_fault",0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCMFX2_mission_fault",0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCMFX3_mission_fault",0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCMFX4_mission_fault",0); 

            uvm_config_db#(int unsigned)::set(null, "", "SCCETHF0", 0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCCETHF1", 0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCCETHF2", 0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCCETHF3", 0); 
            uvm_config_db#(int unsigned)::set(null, "", "SCCETHF4", 0); 
            fsc_regs_check();
            `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("Waiting for Event latent_fault_detected to be triggered"), UVM_LOW);
            if(latent_fault_detected.is_off()) begin
              fork
              begin
                case(flop_cnt)
                0 : begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTAR.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTAR.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTAR.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCBISTAR";
                end
                1 : begin 
                     force tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTCR.int_en = 1;;
                     force tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTCR.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTCR.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTCR.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCBISTCR";
                end
                2 : begin 
                   // force tb_top.dut.fsc.fsc_csr_gen.u_FSCERRR.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCERRR.u_parity_in_0.dout;
                   // `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCERRR.u_parity_in_0.dout"), UVM_LOW)
                   // fsc_reg = "FSCERRR";
                end
                3 : begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF0.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF0.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF0.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCCETHF0";
                end
                4 : begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF1.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF1.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF1.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCCETHF1";
                end
                5 : begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF2.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF2.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF2.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCCETHF2";
                end
                6 : begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF3.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF3.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF3.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCCETHF3";
                end
                7 : begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF4.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF4.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF4.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCCETHF4";
                end
                8 : begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCLF0.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCLF0.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCLF0.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCLF0";
                end
                9 : begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCLF1.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCLF1.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCLF1.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCLF1";
                end
                10 : begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCLF2.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCLF2.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCLF2.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCLF2";
                end
                11 : begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCLF3.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCLF3.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCLF3.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCLF3";
                end
                12 : begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCLF4.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCLF4.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCLF4.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCLF3";
                end
                13: begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCMF0.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCMF0.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCMF0.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCMF0";
                end
                14: begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCMF1.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCMF1.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCMF1.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCMF1";
                end
                15: begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCMF2.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCMF2.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCMF2.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCMF2";
                end
                16: begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCMF3.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCMF3.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCMF3.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCMF3";
                end
                17: begin force tb_top.dut.fsc.fsc_csr_gen.u_FSCMF4.u_parity_in_0.dout = ~tb_top.dut.fsc.fsc_csr_gen.u_FSCMF4.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("FORCING tb_top.dut.fsc.fsc_csr_gen.u_FSCMF4.u_parity_in_0.dout"), UVM_LOW)
                    fsc_reg = "FSCMF3";
                end
                endcase
                #10ns;
                if(latent_fault_detected_check==0) 
                begin 
                    fsc_csr_parity_prot_check_test_fail = 1;
                    fsc_csr_parity_prot_check_test_fail_string.push_back($sformatf("Test failed for fsc_reg %0s",fsc_reg));
                    latent_fault_detected.trigger();
                end
              end

              begin
                latent_fault_detected_check  = 0;
                fsc_csr_parity_prot_check_test_fail = 0;
                latent_fault_detected.wait_trigger();
                if(fsc_csr_parity_prot_check_test_fail==0)  begin
                    `uvm_info("fsc_csr_parity_prot_check_test", "latent fault detected",UVM_LOW)
                    latent_fault_detected_check  = 1;
                end else  latent_fault_detected.reset();
                case(flop_cnt)
                 0 : begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTAR.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTAR.u_parity_in_0.dout"), UVM_LOW)
                 end
                 1 : begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTCR.u_parity_in_0.dout;
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTCR.int_en;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCBISTCR.u_parity_in_0.dout"), UVM_LOW)
                 end
                 2 : begin
                    // release tb_top.dut.fsc.fsc_csr_gen.u_FSCERRR.u_parity_in_0.dout;
                    //`uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCERRR.u_parity_in_0.dout"), UVM_LOW)
                 end
                 3 :begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF0.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF0.u_parity_in_0.dout"), UVM_LOW)
                 end
                 4 :begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF1.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF1.u_parity_in_0.dout"), UVM_LOW)
                 end
                 5 :begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF2.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF2.u_parity_in_0.dout"), UVM_LOW)
                 end
                 6 :begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF3.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF3.u_parity_in_0.dout"), UVM_LOW)
                 end
                 7 :begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF4.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCCETHF4.u_parity_in_0.dout"), UVM_LOW)
                 end
                 8 :begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCLF0.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCLF0.u_parity_in_0.dout"), UVM_LOW)
                 end
                 9 :begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCLF1.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCLF1.u_parity_in_0.dout"), UVM_LOW)
                 end
                 10 :begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCLF2.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCLF2.u_parity_in_0.dout"), UVM_LOW)
                 end
                 11 :begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCLF3.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCLF3.u_parity_in_0.dout"), UVM_LOW)
                 end
                 12 :begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCLF4.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCLF4.u_parity_in_0.dout"), UVM_LOW)
                 end
                 13:begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCMF0.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCMF0.u_parity_in_0.dout"), UVM_LOW)
                 end
                 14:begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCMF1.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCMF1.u_parity_in_0.dout"), UVM_LOW)
                 end
                 15:begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCMF2.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCMF2.u_parity_in_0.dout"), UVM_LOW)
                 end
                 16:begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCMF3.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCMF3.u_parity_in_0.dout"), UVM_LOW)
                 end
                 17:begin 
                     release tb_top.dut.fsc.fsc_csr_gen.u_FSCMF4.u_parity_in_0.dout;
                    `uvm_info("fsc_csr_parity_prot_check_test", $sformatf("RELEASING tb_top.dut.fsc.fsc_csr_gen.u_FSCMF4.u_parity_in_0.dout"), UVM_LOW)
                 end
                endcase
                if(fsc_csr_parity_prot_check_test_fail==0)  begin
                    uvm_config_db#(int unsigned)::set(null, "", "FSCERRR", 1); 

                    uvm_config_db#(int unsigned)::set(null, "", "SCLFX0_latent_fault", 0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCLFX1_latent_fault", 0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCLFX2_latent_fault", 0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCLFX3_latent_fault", 0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCLFX4_latent_fault", 0); 

                    uvm_config_db#(int unsigned)::set(null, "", "SCMFX0_mission_fault",0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCMFX1_mission_fault",0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCMFX2_mission_fault",0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCMFX3_mission_fault",0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCMFX4_mission_fault",0); 

                    uvm_config_db#(int unsigned)::set(null, "", "SCCETHF0", 0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCCETHF1", 0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCCETHF2", 0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCCETHF3", 0); 
                    uvm_config_db#(int unsigned)::set(null, "", "SCCETHF4", 0); 

                    fsc_regs_check();
                    run_bist_seq(bist_seq_automatic_manual);
                end
              end
              join
            end
          end : _exclude_reg
        end : _flop_cnt
        if(fsc_csr_parity_prot_check_test_fail_string.size()>0) begin
             foreach(fsc_csr_parity_prot_check_test_fail_string[temp_q_idx]) begin
                 `uvm_info("fsc_csr_parity_prot_check_test", $psprintf("%0s",fsc_csr_parity_prot_check_test_fail_string[temp_q_idx]),UVM_LOW)
                 `uvm_error("fsc_csr_parity_prot_check_test", $psprintf("Test has failed"))
             end
        end
        fsc_test_done.trigger();
        phase.drop_objection(this, "fsc_csr_parity_prot_check_test");
    end
    join_none
    end:_fsc_csr_parity_prot_check_test
    <% } %>
//ev_sim_done.wait_trigger();
fsys_fsc_main_task_done.trigger();
`uvm_info("FSC_TASKS", "END fsys_fsc_main_task", UVM_LOW)
endtask:fsys_fsc_main_task

////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
task concerto_fsc_tasks::fsc_regs_check();
// #Cover.FSYS.FSC_SCLFX 
// #Cover.FSYS.FSC_SCMFX
// #Cover.FSYS.FSC_SCCETHFx
<% if(obj.useResiliency == 1) { %>
bit[31:0]  read_data;
uvm_status_e   status;

             if(!uvm_config_db#(int unsigned)::get(null, "", "FSCERRR", FSCERRR)) begin
                 `uvm_fatal("Concerto_Error_test", "Not getting value of FSCERRR through uvm_config_db")
             end

             if(!uvm_config_db#(int unsigned)::get(null, "", "SCLFX0_latent_fault", SCLFX0_latent_fault)) begin
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCLFX0_latent_fault through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCLFX1_latent_fault", SCLFX1_latent_fault)) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCLFX1_latent_fault through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCLFX2_latent_fault", SCLFX2_latent_fault)) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCLFX2_latent_fault through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCLFX3_latent_fault", SCLFX3_latent_fault)) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCLFX3_latent_fault through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCLFX4_latent_fault", SCLFX4_latent_fault)) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCLFX4_latent_fault through uvm_config_db")
             end

             if(!uvm_config_db#(int unsigned)::get(null, "", "SCMFX0_mission_fault",SCMFX0_mission_fault )) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCMFX0_mission_fault through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCMFX1_mission_fault",SCMFX1_mission_fault )) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCMFX1_mission_fault through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCMFX2_mission_fault",SCMFX2_mission_fault )) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCMFX2_mission_fault through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCMFX3_mission_fault",SCMFX3_mission_fault )) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCMFX3_mission_fault through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCMFX4_mission_fault",SCMFX4_mission_fault )) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCMFX4_mission_fault through uvm_config_db")
             end

             if(!uvm_config_db#(int unsigned)::get(null, "", "SCCETHF0",SCCETHF0 )) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCCETHF0 through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCCETHF1",SCCETHF1 )) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCCETHF1 through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCCETHF2",SCCETHF2 )) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCCETHF2 through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCCETHF3",SCCETHF3 )) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCCETHF3 through uvm_config_db")
             end
             if(!uvm_config_db#(int unsigned)::get(null, "", "SCCETHF4",SCCETHF4 )) begin 
                 `uvm_fatal("Concerto_Error_test", "Not getting value of SCCETHF4 through uvm_config_db")
             end

              m_concerto_env.resiliency_m_regs.fsc.FSCERRR.read(status,read_data);
              if(FSCERRR != read_data) begin
                  `uvm_error("Concerto_Error_test",$sformatf("FSCERRR reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,FSCERRR));
              end
              else 
                  `uvm_info("Concerto_Error_test",$sformatf("FSCERRR reg value matches. Act 'h%8h Exp 'h%8h",read_data,FSCERRR),UVM_MEDIUM)

             if(!$test$plusargs("disable_fsc_SCMFX_regs_check"))begin
                 m_concerto_env.resiliency_m_regs.fsc.FSCMF0.read(status,read_data);
                 if(SCMFX0_mission_fault != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_SCMFX0 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCMFX0_mission_fault));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_SCMFX0 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCMFX0_mission_fault),UVM_MEDIUM)
                 fcov_SCMF0 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCMF1.read(status,read_data);
                 if(SCMFX1_mission_fault != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_SCMFX1 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCMFX1_mission_fault));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_SCMFX1 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCMFX1_mission_fault),UVM_MEDIUM)
                 fcov_SCMF1 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCMF2.read(status,read_data);
                 if(SCMFX2_mission_fault != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_SCMFX2 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCMFX2_mission_fault));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_SCMFX2 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCMFX2_mission_fault),UVM_MEDIUM)
                 fcov_SCMF2 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCMF3.read(status,read_data);
                 if(SCMFX3_mission_fault != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_SCMFX3 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCMFX3_mission_fault));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_SCMFX3 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCMFX3_mission_fault),UVM_MEDIUM)
                 fcov_SCMF3 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCMF4.read(status,read_data);
                 if(SCMFX4_mission_fault != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_SCMFX4 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCMFX4_mission_fault));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_SCMFX4 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCMFX4_mission_fault),UVM_MEDIUM)
                 fcov_SCMF4 = read_data;
                 sample_cg_fsc_regs();

             end

             if(!$test$plusargs("disable_fsc_SCLFX_regs_check"))begin
                 m_concerto_env.resiliency_m_regs.fsc.FSCLF0.read(status,read_data);
                 if(SCLFX0_latent_fault != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_SCLFX0 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCLFX0_latent_fault));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_SCLFX0 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCLFX0_latent_fault),UVM_MEDIUM)
                 fcov_SCLF0 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCLF1.read(status,read_data);
                 if(SCLFX1_latent_fault != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_SCLFX1 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCLFX1_latent_fault));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_SCLFX1 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCLFX1_latent_fault),UVM_MEDIUM)
                 fcov_SCLF1 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCLF2.read(status,read_data);
                 if(SCLFX2_latent_fault != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_SCLFX2 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCLFX2_latent_fault));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_SCLFX2 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCLFX2_latent_fault),UVM_MEDIUM)
                 fcov_SCLF2 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCLF3.read(status,read_data);
                 if(SCLFX3_latent_fault != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_SCLFX3 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCLFX3_latent_fault));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_SCLFX3 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCLFX3_latent_fault),UVM_MEDIUM)
                 fcov_SCLF3 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCLF4.read(status,read_data);
                 if(SCLFX4_latent_fault != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_SCLFX4 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCLFX4_latent_fault));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_SCLFX4 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCLFX4_latent_fault),UVM_MEDIUM)
                 fcov_SCLF4 = read_data;
                 sample_cg_fsc_regs();
             end

             if(!$test$plusargs("disable_fsc_SCCETHF_regs_check"))begin
                 m_concerto_env.resiliency_m_regs.fsc.FSCCETHF0.read(status,read_data);
                 if(SCCETHF0 != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_CCETHF0 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCCETHF0));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_CCETHF0 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCCETHF0),UVM_MEDIUM)
                 fcov_SCCETHF0 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCCETHF1.read(status,read_data);
                 if(SCCETHF1 != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_CCETHF1 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCCETHF1));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_CCETHF1 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCCETHF1),UVM_MEDIUM)
                 fcov_SCCETHF1 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCCETHF2.read(status,read_data);
                 if(SCCETHF2 != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_CCETHF2 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCCETHF2));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_CCETHF2 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCCETHF2),UVM_MEDIUM)
                 fcov_SCCETHF2 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCCETHF3.read(status,read_data);
                 if(SCCETHF3 != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_CCETHF3 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCCETHF3));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_CCETHF3 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCCETHF3),UVM_MEDIUM)
                 fcov_SCCETHF3 = read_data;
                 sample_cg_fsc_regs();

                 m_concerto_env.resiliency_m_regs.fsc.FSCCETHF4.read(status,read_data);
                 if(SCCETHF4 != read_data) begin
                     `uvm_error("Concerto_Error_test",$sformatf("FSC_CCETHF4 reg value mismatch. Act 'h%8h Exp 'h%8h",read_data,SCCETHF4));
                 end
                 else 
                     `uvm_info("Concerto_Error_test",$sformatf("FSC_CCETHF4 reg value matches. Act 'h%8h Exp 'h%8h",read_data,SCCETHF4),UVM_MEDIUM)
                 fcov_SCCETHF4 = read_data;
                 sample_cg_fsc_regs();
             end
<% } %>
endtask : fsc_regs_check

task concerto_fsc_tasks::run_bist_seq(bit bist_seq_automatic_manual);
int bist_wait_clock_cycles;
<% if(obj.useResiliency == 1) { %>
      bit[31:0]  read_data;
      bit[31:0]  write_data;
      uvm_status_e   status;
      if($test$plusargs("disable_bist"))
          bist_wait_clock_cycles = 20;
      else    
          bist_wait_clock_cycles = 4096;
      if(bist_seq_automatic_manual==0) begin //Manual Bist Seq
      int bist_step_loop_cnt=1;
      bit [5:0]bist_state, bist_state_prev;
      bit bist_state_1,  bist_state_3, bist_state_7, bist_state_F, bist_state_1F, bist_state_3F;
      int temp=1;
      uvm_event bist_seq_updated = new("bist_seq_updated"); 
      fork
        begin
            //#Stimulus.FSYS.BIST.step_by_step
            write_data = 'h1;
            repeat(6) begin
              `uvm_info("run_bist_seq", "Writing 1st location of FSCBISTCR to start Bist seq engine for Single step mode",UVM_NONE)
              m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
              //repeat(10)@(posedge m_apb_resiliency_cfg.m_vif.clk);      //Clock delay between each bist seq step (manual)
              //m_concerto_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
              //`uvm_info("run_bist_seq",$psprintf("FSCBISTAR : Read data 'h%0h expecting step-%0d without any delay",read_data,bist_step_loop_cnt),UVM_LOW)
              //repeat($urandom_range(25,50))@(posedge m_apb_resiliency_cfg.m_vif.clk); // TODO: CONC-7515
      <%
      var BistDebugDisablePin = 0;
      if(obj.FscInfo.interfaces.bistDebugDisableInt._SKIP_==false){
        BistDebugDisablePin = 1;
      } %>
              if(!(($test$plusargs("disable_bist"))  && 1'b<%=BistDebugDisablePin%>))
                  bist_seq_updated.wait_trigger();
              bist_step_loop_cnt = bist_step_loop_cnt + 1;
            end
        end
        begin
             // #Check.FSYS.FSCBISTAR.step_by_step_uncorrecterr
            repeat(bist_wait_clock_cycles) begin //Each read takes 5 clocks to complete, Using 2048 loops because step-5 takes 4096 cycles from IOAIU side(DCE & CHI too?)
                m_concerto_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
                `uvm_info("run_bist_seq",$psprintf("FSCBISTAR : Read data 'h%0h at clock-%0d",read_data,temp),UVM_LOW)
                if(read_data[5:0] < bist_state) begin
                  `uvm_error("run_bist_seq",$sformatf("Error detected in Bist seq, FSCBISTAR Reg %0h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F transition. Last value 0x%0h Present Value 0x%0h",read_data,bist_state,read_data[5:0]));
                end
                if(read_data[11:6] != 0) begin
                  `uvm_error("run_bist_seq",$sformatf("Error detected in Bist seq, FSCBISTAR Reg %0h",read_data[11:6]));
                end
                if(read_data[5:0]=='h1) bist_state_1 = 'h1;
                else if(read_data[5:0]=='h3) bist_state_3 = 'h1;
                else if(read_data[5:0]=='h7) bist_state_7 = 'h1;
                else if(read_data[5:0]=='hF) bist_state_F = 'h1;
                else if(read_data[5:0]=='h1F) bist_state_1F = 'h1;
                else if(read_data[5:0]=='h3F) bist_state_3F = 'h1;
                bist_state = read_data[5:0];
                temp = temp+1;
                if((bist_state=='h3F) && (bist_state_1==1) && (bist_state_3==1) && (bist_state_7==1) && (bist_state_F==1) && (bist_state_1F==1) && (bist_state_3F==1)) begin 
                    bist_seq_updated.trigger(); break;
                end else if((bist_state=='h3F) && ((bist_state_1==0) || (bist_state_3==0) || (bist_state_7==0) || (bist_state_F==0) || (bist_state_1F==0) || (bist_state_3F==0))) begin
                    `uvm_error("run_bist_seq",$sformatf("Error detected in Bist seq, FSCBISTAR Reg %0h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F -> 0x3F transition.",read_data));
                end else begin
                  if(bist_state != bist_state_prev) begin bist_seq_updated.trigger(); bist_state_prev = bist_state; end
                end
            end
        end
      join
      end
      else begin //Automatic Bist Seq  
     //#Stimulus.FSYS.BIST.auto_uncorrecterr 
        write_data = 'h2;
        `uvm_info("run_bist_seq", "Writing 1st location of FSCBISTCR to set Sequential mode - BIST FSM runs all 6 BIST steps in sequence/automatic Bist seq.",UVM_NONE)
        m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
        sample_cg_fsc_regs();
        write_data = 'h3;
        `uvm_info("run_bist_seq", "Writing 0th location of FSCBISTCR to start Bist seq engine",UVM_NONE)
        m_concerto_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
        sample_cg_fsc_regs();
      end
      //repeat(100) @ (posedge m_apb_resiliency_cfg.m_vif.clk);      //Wait for Bist seq to complete 
      if(bist_seq_automatic_manual) begin
      bit [5:0]bist_state;
      bit bist_state_1,  bist_state_3, bist_state_7, bist_state_F, bist_state_1F, bist_state_3F;
      int temp=1;
      // #Check.FSYS.FSCBISTAR.auto_uncorrecterr
          repeat(bist_wait_clock_cycles) begin  //Each read takes 5 clocks to complete , Using 2048 loops because step-5 takes 4096 cycles from IOAIU side(DCE & CHI too?)
              m_concerto_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
              sample_cg_fsc_regs();
              `uvm_info("run_bist_seq",$psprintf("FSCBISTAR : Read data 'h%0h at clock-%0d",read_data,temp),UVM_LOW)
              if(read_data[5:0] < bist_state) begin
                `uvm_error("run_bist_seq",$sformatf("Error detected in Bist seq, FSCBISTAR Reg %0h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F transition. Last value 0x%0h Present Value 0x%0h",read_data,bist_state,read_data[5:0]));
              end
              if(read_data[11:6] != 0) begin
                `uvm_error("run_bist_seq",$sformatf("Error detected in Bist seq, FSCBISTAR Reg %0h",read_data[11:6]));
              end
              if(read_data[5:0]=='h1) bist_state_1 = 'h1;
              else if(read_data[5:0]=='h3) bist_state_3 = 'h1;
              else if(read_data[5:0]=='h7) bist_state_7 = 'h1;
              else if(read_data[5:0]=='hF) bist_state_F = 'h1;
              else if(read_data[5:0]=='h1F) bist_state_1F = 'h1;
              else if(read_data[5:0]=='h3F) bist_state_3F = 'h1;
              bist_state = read_data[5:0];
              temp = temp+1;
              if((bist_state=='h3F) && (bist_state_1==1) && (bist_state_3==1) && (bist_state_7==1) && (bist_state_F==1) && (bist_state_1F==1) && (bist_state_3F==1)) begin 
                  break;
              end else if((bist_state=='h3F) && ((bist_state_1==0) || (bist_state_3==0) || (bist_state_7==0) || (bist_state_F==0) || (bist_state_1F==0) || (bist_state_3F==0))) begin
                  `uvm_error("run_bist_seq",$sformatf("Error detected in Bist seq, FSCBISTAR Reg %0h. Not following 0 -> 0x1 -> 0x3 -> 0x7 -> 0xF -> 0x1F -> 0x3F transition.",read_data));
              end
          end
      end
      <%
      var BistDebugDisablePin = 0;
      if(obj.FscInfo.interfaces.bistDebugDisableInt._SKIP_==false){
        BistDebugDisablePin = 1;
      } %>
      if(( ($test$plusargs("disable_bist") && 1'b<%=BistDebugDisablePin%>) && read_data[5:0] != 'h00) ||
         ((!$test$plusargs("disable_bist") || !1'b<%=BistDebugDisablePin%>) && read_data[5:0] != 'h3F)) begin
       `uvm_error("run_bist_seq",$sformatf("Something went wrong in Bist seq, FSCBISTAR Reg %0h",read_data[5:0]));
      end
      // average around 400 clk gets consumed by now in this thread. so set around 500 for next UCE injection
<% } %>
endtask : run_bist_seq
