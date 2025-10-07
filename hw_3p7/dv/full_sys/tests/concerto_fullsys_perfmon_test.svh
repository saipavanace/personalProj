<%
//Embedded javascript code to figure number of blocks
   var _blkid = [];
   var _blkidpkg = [];
   var _blktype = [];
   var _blkclkperiod = [];
   var _blkports_suffix =[];
   var _blk   = [{}];
   var pidx = 0;
   var ridx = 0;
   var _idx = 0;
   var chiaiu_idx = 0;
   var ioaiu_idx = 0;
   var ioaiu_mpu_idx = 0;
   var nbr_clk= obj.Clocks.length;
   var ref_clk_period=0; //the first AiuInfo will be the reference to compare all the clokc to check if there are synchro
   obj.nAIUs_mpu =0; 
   
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _blkclkperiod[_idx] = obj.Clocks.filter(e => e.name == obj.AiuInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period)) //unitClk[0] = fct clk unitClk[1]= duplicate clk (resilience)
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'chiaiu' + chiaiu_idx +"_0";
       _blkidpkg[_idx] = 'chiaiu' + chiaiu_idx;
       _blktype[_idx]   = 'chiaiu';
       chiaiu_idx++;
       obj.nAIUs_mpu++;
       _idx++;
       } else {
       for (var port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blkclkperiod[_idx] = obj.Clocks.filter(e => e.name == obj.AiuInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period)) //unitClk[0] = fct clk unitClk[1]= duplicate clk (resilience)
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkidpkg[_idx] = 'ioaiu' + ioaiu_idx;
        _blkid[_idx] = 'ioaiu' + ioaiu_idx +"_"+port_idx;
        _blkports_suffix[_idx] = "_" + port_idx;
        _blktype[_idx]   = 'ioaiu';
         _idx++;
        obj.nAIUs_mpu++;
        }
         ioaiu_idx++;
       }
   }
   ref_clk_period=_blkclkperiod[0]; // first is the ref

   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu;
       _blkclkperiod[ridx] = obj.Clocks.filter(e => e.name == obj.DceInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period))
       _blkid[ridx] = 'dce' + pidx;
       _blkidpkg[ridx] = 'dce' + pidx;
       _blktype[ridx]   = 'dce';
       _blk[ridx]   = obj.DceInfo[pidx];
   }
 for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu + obj.nDCEs;
       _blkclkperiod[ridx] = obj.Clocks.filter(e => e.name == obj.DmiInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period))
       _blkid[ridx] = 'dmi' + pidx;
       _blkidpkg[ridx] = 'dmi' + pidx;
       _blktype[ridx]   = 'dmi';
       _blk[ridx]   = obj.DmiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu + obj.nDCEs + obj.nDMIs;
       _blkclkperiod[ridx] = obj.Clocks.filter(e => e.name == obj.DiiInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period))
       _blkid[ridx] = 'dii' + pidx;
       _blkidpkg[ridx] = 'dii' + pidx;
       _blk[ridx]   = 'dii';
       _blk[ridx]   = obj.DiiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs_mpu + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _blkclkperiod[ridx] = obj.Clocks.filter(e => e.name == obj.DveInfo[pidx].unitClk[0]).map(e => parseInt(e.params.period))
       _blkid[ridx] = 'dve' + pidx;
       _blkidpkg[ridx] = 'dve' + pidx;
       _blktype[ridx]   = 'dve';
       _blk[ridx]   = obj.DveInfo[pidx];
   }
   var nALLs = ridx+1; 
%>
// agent DEBUG
// nbr agents: <%=obj.nAIUs%>
// nbr agents with mpu: <%=obj.nAIUs_mpu%>
// CLOCK DEBUG
// nbr clock=<%=nbr_clk%>
// ref_clk_period = <%=ref_clk_period%>
// Clock ratio
<%for(var pidx = 0; pidx < nALLs; pidx++) {   %>
// _<%=_blkid[pidx]%> = <%=_blkclkperiod[pidx]%>
<% } %>
// END CLOCK DEBUG
class concerto_fullsys_perfmon_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_perfmon_test)

  bit perfmon_test = 1;
  int main_seq_iter=1;
  bit smi_rx_stall_en;
  bit force_axi_stall_en;
  
 <%for(var pidx = 0; pidx < nALLs; pidx++) {   %>
    const int <%=_blkid[pidx]%>_nPerfCounters = <%=_blk[pidx].nPerfCounters%>; // Number of perf counters instantiated within each unit
    <%=_blkidpkg[pidx]%>_perf_cnt_pkg::<%=_blkidpkg[pidx]%>_perf_cnt_units            <%=_blkid[pidx]%>_perf_counters;
    <%=_blkidpkg[pidx]%>_perf_cnt_pkg::<%=_blkidpkg[pidx]%>_perf_cnt_unit_cfg_seq     <%=_blkid[pidx]%>_perf_counter_seq;
    <%=_blkidpkg[pidx]%>_perf_cnt_pkg::<%=_blkidpkg[pidx]%>_perf_counters_scoreboard <%=_blkid[pidx]%>_perf_cnt_sb;
  <% } // foreach aiu%>
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                                  
  // !!! some declarations in the parent with the macro `concerto_fullsys_perfmon_test_all_declarations in files perf_cnt_unit_defines!!!!
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                                  
                                  
  function new(string name = "concerto_fullsys_perfmon_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  // UVM PHASE
  extern function void build_phase(uvm_phase phase);
  extern task run_phase (uvm_phase phase);
//  extern task post_shutdown_phase (uvm_phase phase);

  // HOOK task call in the parent class
  //extern virtual task main_seq_pre_hook(uvm_phase phase);  // before the iteration (outside the iteration loop)
  //extern virtual task main_seq_post_hook(uvm_phase phase); // after the iteration (outside the iteration loop)
  extern virtual task main_seq_iter_pre_hook(uvm_phase phase, int iter); // at the beginning of the iteration(inside the iteration loop)
  extern virtual task main_seq_iter_post_hook(uvm_phase phase, int iter);// at the end of the iteration (inside the iteration)
  extern virtual task main_seq_hook_end_run_phase(uvm_phase phase);
  // PRIVATE TASK
  extern task perf_cnt_process_counter(uvm_phase phase,int iter=-1); //Will do save,read,compare 

  // FUNCTION

  // Interfaces
 <%for(var pidx = 0; pidx < nALLs; pidx++) {   %>
       virtual <%=_blkidpkg[pidx]%>_stall_if <%=_blkid[pidx]%>_sb_stall_if;
  <% } // foreach agent%>
endclass: concerto_fullsys_perfmon_test


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
function void concerto_fullsys_perfmon_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
 <%for(var pidx = 0; pidx < nALLs; pidx++) {   %>
  
       <%=_blkid[pidx]%>_perf_counters = <%=_blkidpkg[pidx]%>_perf_cnt_pkg::<%=_blkidpkg[pidx]%>_perf_cnt_units::new("<%=_blkid[pidx]%>_perf_counters");
       uvm_config_db#(<%=_blkidpkg[pidx]%>_perf_cnt_pkg::<%=_blkidpkg[pidx]%>_perf_cnt_units)::set(null, "", "<%=_blkid[pidx]%>_m_perf_counters", <%=_blkid[pidx]%>_perf_counters);
  
       <%=_blkid[pidx]%>_perf_cnt_sb = <%=_blkidpkg[pidx]%>_perf_cnt_pkg::<%=_blkidpkg[pidx]%>_perf_counters_scoreboard::type_id::create("<%=_blkid[pidx]%>_perf_cnt_sb", this);
       <%=_blkid[pidx]%>_perf_cnt_sb.inst_scb_cfg_name = "<%=_blkid[pidx]%>_m_perf_counters"; // in case of multiport update the uvm_config_db name corresponding
       <% if(_blktype[pidx] != 'ioaiu') { %>
       <%=_blkid[pidx]%>_perf_cnt_sb.stall_if_name = "<%=_blkid[pidx]%>_m_top_stall_if"; // in case of multiport update the uvm_config_db name corresponding
       <% } %>
       <% if(_blktype[pidx] != 'ioaiu') { %>
       if (!uvm_config_db#(virtual <%=_blkidpkg[pidx]%>_stall_if)::get(null, "", "<%=_blkid[pidx]%>_m_top_stall_if", <%=_blkid[pidx]%>_sb_stall_if)) begin
          `uvm_fatal("Stall interface error", "virtual interface must be set for <%=_blkid[pidx]%>_m_top_stall_if");
      end
       <% } %>
  <% } // foreach agent%>
  <% var ioaiu_idx=0 ;%>
  <% var blk_type='ioaiu' ;%>
  <%for(var pidx = 0; pidx < obj.nAIUs; pidx++) {   %>
      <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B' && obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
          <% for (var port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {%>
          <%=blk_type%><%=ioaiu_idx%>_<%=port_idx%>_perf_cnt_sb.stall_if_name = "<%=blk_type%><%=ioaiu_idx%>_0_m_top_stall_if_<%=port_idx%>"; // in case of multiport update the uvm_config_db name corresponding
       if (!uvm_config_db#(virtual <%=blk_type%><%=ioaiu_idx%>_stall_if)::get(null, "", "<%=blk_type%><%=ioaiu_idx%>_0_m_top_stall_if_<%=port_idx%>", <%=blk_type%><%=ioaiu_idx%>_<%=port_idx%>_sb_stall_if)) begin
          `uvm_fatal("Stall interface error", "virtual interface must be set for <%=blk_type%><%=ioaiu_idx%>_0_m_top_stall_if<%=port_idx%>");
      end
          <% } %>
          <% ioaiu_idx = ioaiu_idx + 1; %>
      <% } %>
  <% } %>
endfunction : build_phase
task concerto_fullsys_perfmon_test::run_phase (uvm_phase phase); 
 // Before start the iteration create & setup all the attributs
 <%for(var pidx = 0; pidx < nALLs; pidx++) {   %>
       <%=_blkid[pidx]%>_perf_counter_seq =<%=_blkidpkg[pidx]%>_perf_cnt_pkg::<%=_blkidpkg[pidx]%>_perf_cnt_unit_cfg_seq::type_id::create("<%=_blkid[pidx]%>_perf_cnt_unit_cfg_seq");;
       <% if (_blk[pidx].nNativeInterfacePorts && (_blk[pidx].nNativeInterfacePorts > 1)) {%>
          <%=_blkid[pidx]%>_perf_counter_seq.blockreg_str = {<%=_blkid[pidx]%>_perf_counter_seq.blockreg_str,"<%=_blkports_suffix[pidx]%>"};
       <%}%>
       <%=_blkid[pidx]%>_perf_counter_seq.perf_counters = <%=_blkid[pidx]%>_perf_counters;
       <%=_blkid[pidx]%>_perf_counter_seq.m_regs = m_concerto_env.m_regs;
  <% } // foreach agent%>
  max_iteration = 4;
  super.run_phase(phase);
endtask:run_phase

////////////////////////////////////////////////////////////////////////////////////////
// #     #  #######  #######  #    #         #######     #      #####   #    #   #####   
// #     #  #     #  #     #  #   #             #       # #    #     #  #   #   #     #  
// #     #  #     #  #     #  #  #              #      #   #   #        #  #    #        
// #######  #     #  #     #  ###               #     #     #   #####   ###      #####   
// #     #  #     #  #     #  #  #              #     #######        #  #  #          #  
// #     #  #     #  #     #  #   #             #     #     #  #     #  #   #   #     #  
// #     #  #######  #######  #    #  #####     #     #     #   #####   #    #   ##### 
// #Stimulus.FSYS.perfmon.mastercountenable 
////////////////////////////////////////////////////////////////////////////////////////
//////////////////// PRE HOOK                   ////////////
task concerto_fullsys_perfmon_test::main_seq_iter_pre_hook(uvm_phase phase, int iter);
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_pre_hook iter:%0d",iter), UVM_NONE)
  phase.raise_objection(this, "Start perf counter cfg sequence");
  `uvm_info(get_name(), "Perf counter cfg sequence started", UVM_NONE)
 <%for(var pidx = 0; pidx < nALLs; pidx++) {   %>
       <%=_blkid[pidx]%>_perf_counter_seq.iteration =iter;
       
       if (iter >1) begin  // use local count enable
          <%=_blkid[pidx]%>_perf_counters.perfmon_local_count_clear = 1;
          end
       
          <%=_blkid[pidx]%>_perf_counter_seq.start(null);
      `uvm_info(get_name(), "<%=_blkid[pidx]%> Perf counter cfg sequence finished", UVM_NONE)
       
       //TRIG NEW CFG
       //m_latency_cnt_sb.set_new_config();
       <%=_blkid[pidx]%>_perf_cnt_sb.set_new_config();

        //reminder: count_enable: for each counter of one block// local_count_enable: all counter of one block// master_count_enable: all counter of ALL blocks
       case(iter)
        0:begin   // use count enable
          <%=_blkid[pidx]%>_perf_counters.perfmon_local_count_enable =0; // don't use local_count_enable
          <%=_blkid[pidx]%>_perf_counters.force_master_count_enable = 0;
          foreach(<%=_blkid[pidx]%>_perf_counters.force_count_enable[i])  <%=_blkid[pidx]%>_perf_counters.force_count_enable[i]=1;
          end
        1:begin  // use local count enable
          <%=_blkid[pidx]%>_perf_counters.perfmon_local_count_enable =1; 
          <%=_blkid[pidx]%>_perf_counters.perfmon_local_count_clear = 1;
          <%=_blkid[pidx]%>_perf_counters.force_master_count_enable = 0;

          foreach(<%=_blkid[pidx]%>_perf_counters.force_count_enable[i])  <%=_blkid[pidx]%>_perf_counters.force_count_enable[i]=0;
          end
        default:begin  // use master count enable & local count clear
          <%=_blkid[pidx]%>_perf_counters.perfmon_local_count_enable =0; 
          <%=_blkid[pidx]%>_perf_counters.perfmon_local_count_clear = 1;
          <%=_blkid[pidx]%>_perf_counters.force_master_count_enable = 1;
          foreach(<%=_blkid[pidx]%>_perf_counters.force_count_enable[i])  <%=_blkid[pidx]%>_perf_counters.force_count_enable[i]=0;
          end
     endcase 
       //Enable counter
       `uvm_info(get_name(), "<%=_blkid[pidx]%> Scoreboard counters cleared and New cfg triggered", UVM_NONE)

       <%=_blkid[pidx]%>_perf_counter_seq.enable_all_counters();
       if (iter >1) <%=_blkid[pidx]%>_perf_counters.main_cntr_reg.master_count_enable =1;  // set all scb master_count_enable

  <% } // foreach agent%>
  #1us; // wait propagation of the last write to register
    // TODO FOREACH DVE,DCE,DMI,DII
  phase.drop_objection(this, "Finish perf counter cfg sequence");
  `uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_pre_hook iter:%0d",iter), UVM_NONE)

endtask:main_seq_iter_pre_hook

////////////////////////////////////////////////////////////
//////////////////// POST HOOK ///////////
task concerto_fullsys_perfmon_test::main_seq_iter_post_hook(uvm_phase phase, int iter);
  
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)
  if (iter != max_iteration-1) begin
     perf_cnt_process_counter(phase,iter);
  end

    `ifndef USE_VIP_SNPS 
      `ifdef VCS
      super.main_seq_iter_post_hook(phase,iter); 
      `endif // `ifdef VCS
   `endif // `ifndef USE_VIP_SNPS 

  `uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)

endtask:main_seq_iter_post_hook

////////////////////////////////////////////////////////////
////////////   HOOK END RUN PHASE       ///////////////
task concerto_fullsys_perfmon_test::main_seq_hook_end_run_phase(uvm_phase phase);
  phase.raise_objection(this, "main_seq_hook_end_run_phase");
  `uvm_info(get_name(), "HOOK main_seq_hook_end_run_phase", UVM_NONE)
   perf_cnt_process_counter(phase);
 <%for(var pidx = 0; pidx < nALLs; pidx++) {   %>
  <%=_blkid[pidx]%>_perf_cnt_sb.disable_sb  = 1;
  <% } // foreach agent%>

  `uvm_info(get_name(), "end of HOOK main_seq_hook_end_run_phase, perf_cnt_sb disabled!!", UVM_NONE)
   phase.drop_objection(this, "main_seq_hook_end_run_phase");

endtask:main_seq_hook_end_run_phase

////////////////////////////////////////////////////////////
///////////// PROCESS COUNTER              ///////////////
task concerto_fullsys_perfmon_test::perf_cnt_process_counter(uvm_phase phase, int iter=-1);

  // disable Counters
     case (iter)
        0: begin  // disable with count_enable register
          <%for(var pidx = 0; pidx < nALLs; pidx++) {   %>
            for (int i=0;i < <%=_blkid[pidx]%>_nPerfCounters;i++) begin
              <%=_blkid[pidx]%>_perf_counter_seq.write_count_enable(.id(i), .counter_enable(1'b0));
            end
          <%}%>
          end
        1: begin
          <%for(var pidx = 0; pidx < nALLs; pidx++) {   %>
             <%=_blkid[pidx]%>_perf_counter_seq.write_local_count_enable(1'b0, 1'b0);
          <%}%>
        end
        default: begin
             dve0_perf_counter_seq.write_master_count_enable(1'b0, 1'b0);
          <%for(var pidx = 0; pidx < nALLs; pidx++) {   %>
             <%=_blkid[pidx]%>_perf_counters.main_cntr_reg.master_count_enable =0;  // set all scb master_count_enable
          <%}%>
        end
     endcase
 <%for(var pidx = 0; pidx < nALLs; pidx++) {   %>
  //print counter values and clean sb
  #2us;
  //force counter to save values
    <%=_blkid[pidx]%>_perf_cnt_sb.set_save_counter();
  #5ns;
  // read cnt_value and cnt_value_str from register 
  <%=_blkid[pidx]%>_perf_counter_seq.read_all_cnt_value_reg();
  <%=_blkid[pidx]%>_perf_counter_seq.read_all_cnt_saturation_reg();
  <%=_blkid[pidx]%>_perf_counter_seq.read_all_overflow_status();
  

  // In addition, some counters reg values check  //regsiter has been read by read_all_cnt_value_reg
  for (int i=0;i < <%=_blkid[pidx]%>_nPerfCounters;i++) begin
      // Check-1: We run all the counter therefore shouldn't be zero
      if (!<%=_blkid[pidx]%>_perf_counters.count_value[i].cnt_v) begin // value set by read_all_cnt_value_reg
          `uvm_error(get_name(), $sformatf("<%=_blkid[pidx]%>_perf_counters.count_value[%0d] egal zero shouldn't be the case!!",i));
      end
      // Check-2
      if (iter > 1  // only in case of master_count_enable
          && <%=_blkid[pidx]%>_perf_counters.count_event_first[i] == 'd30 // 30 == div_16 for all the block
          && !<%=_blkid[pidx]%>_perf_counters.count_event_second[i]) begin //  event_second not used
        <% if (nbr_clk>1) { %> 
          // in case of multi clock:
          // 1- the div_16 isn't the same but we correct the value with the ratio between ref_div_16 (first agent)& div_16 from others agents
          // 2- add also 5% in the clock ratio because the master_enable signal cross a clock domain
           // use the first agent cnt value as reference in case of master_cnt_enable all the cnt must be synchronize with a tolerance of +/- 5%
          if ( <%=_blkid[pidx]%>_perf_counters.count_value[i].cnt_v > (<%=_blkid[0]%>_perf_counters.count_value[i].cnt_v * <%=(_blkclkperiod[0]/_blkclkperiod[pidx])%>)*1.05 ||
               <%=_blkid[pidx]%>_perf_counters.count_value[i].cnt_v < (<%=_blkid[0]%>_perf_counters.count_value[i].cnt_v * <%=(_blkclkperiod[0]/_blkclkperiod[pidx])%>)*0.95 ) begin
          `uvm_error(get_name(), $sformatf("ref: <%=_blkid[0]%>_perf_counters.count_value[%0d]=0x%0h (0x%0h:without clk ratio correction) isn't correctly synchronized with <%=_blkid[pidx]%>_perf_counters.count_value[%0d].cnt_v=0x%0h in case of Master_count_enable",
                     i,(<%=_blkid[0]%>_perf_counters.count_value[i].cnt_v * <%=(_blkclkperiod[pidx]/_blkclkperiod[0])%>),<%=_blkid[0]%>_perf_counters.count_value[i].cnt_v,i,<%=_blkid[pidx]%>_perf_counters.count_value[i].cnt_v,));
           end
        <% } else {%>
           // use the first agent cnt value as reference in case of master_cnt_enable all the cnt must be synchronize with a tolerance of +/- 1
        if ( <%=_blkid[pidx]%>_perf_counters.count_value[i].cnt_v > (<%=_blkid[0]%>_perf_counters.count_value[i].cnt_v +1) ||
        <%=_blkid[pidx]%>_perf_counters.count_value[i].cnt_v < (<%=_blkid[0]%>_perf_counters.count_value[i].cnt_v -1) ) begin
             `uvm_error(get_name(), $sformatf("ref: <%=_blkid[0]%>_perf_counters.count_value[%0d]=0x%0h isn't correctly synchronized with <%=_blkid[pidx]%>_perf_counters.count_value[%0d].cnt_v=0x%0h in case of Master_count_enable",
              i,<%=_blkid[0]%>_perf_counters.count_value[i].cnt_v,i,<%=_blkid[pidx]%>_perf_counters.count_value[i].cnt_v));
         end
        <% } %>
          end
  end

  `uvm_info(get_name(), "<%=_blkid[pidx]%> Start comparison between design and scoreboard for all counters", UVM_LOW)
  // Compare reg value and saturation value to sb value
  <%=_blkid[pidx]%>_perf_cnt_sb.stall_counter_compare_all();
  // printing latency scoreboard bins value
  //<%=_blkid[pidx]%>_latency_cnt_sb.print_bins();
  
  // clear sb value and reg value
  `uvm_info(get_name(), "Printing SB counters values before clearing counters", UVM_NONE)
  <%=_blkid[pidx]%>_perf_cnt_sb.print_full_counter();
  <%=_blkid[pidx]%>_perf_cnt_sb.clear_full_counter();
  <% } // foreach agent%>
  #1us; // wait propagation of the last write to register

endtask:perf_cnt_process_counter

//task concerto_fullsys_perfmon_test::post_shutdown_phase(uvm_phase phase);
//main_seq_hook_end_run_phase(phase);
//endtask:post_shutdown_phase


////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
