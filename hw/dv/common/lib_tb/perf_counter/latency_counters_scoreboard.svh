`include "uvm_macros.svh"
import <%=obj.BlockId%>_perf_cnt_unit_defines::*;
class <%=obj.BlockId%>_latency_counters_scoreboard extends uvm_scoreboard;
    `uvm_component_param_utils(<%=obj.BlockId%>_latency_counters_scoreboard);
    ////////////////
    const int bins_num = 8;
    latency_counter_type_tab latency_table,latency_table_tmp;
    latency_counter_type latency_counter;
    // Interfaces
    virtual <%=obj.BlockId%>_latency_if sb_latency_if;
    //perf counter if
    virtual <%=obj.BlockId%>_stall_if sb_stall_if;
  
    // declare config object

    <%=obj.BlockId%>_perf_cnt_units sb_latency_counters_cfg;
    e_latency_type latency_type ;
    bit start_count[];
    e_latency_bin_offset offset = 0;
    int latency_pre_scale = 2;
    int latency_bins[8] = '{0,0,0,0,0,0,0,0};  
    int latency_bins_dut[8] = '{0,0,0,0,0,0,0,0};   
    bit new_cfg = 0 ;
    int core_no = 0;
    ///////////////////////////

   
    // ------------------------------------------------------------------------
    // Methods
    // ------------------------------------------------------------------------
    extern function                     new             (string name="<%=obj.BlockId%>_latency_counters_scoreboard", uvm_component parent=null);
    extern virtual function void        build_phase     (uvm_phase phase);
    extern task                         main_phase      (uvm_phase phase);
    extern task                         latency_count(int alloc_id);
    extern task                         bins_count(int bins_id);
    extern function                     create_bin(int id); 
    extern function                     print_bins();   
    extern function                     compare_bins();    
    extern task                         set_new_config();       
    extern function                     latency_cov();    
    
endclass: <%=obj.BlockId%>_latency_counters_scoreboard

// ----------------------------------------------------------------------------
// Class Methods Implementation
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
function <%=obj.BlockId%>_latency_counters_scoreboard::new(string name="<%=obj.BlockId%>_latency_counters_scoreboard", uvm_component parent=null);
    super.new(name, parent);
endfunction: new
// ----------------------------------------------------------------------------
function void <%=obj.BlockId%>_latency_counters_scoreboard::build_phase(uvm_phase phase);
    // Use parent method
    super.build_phase(phase);
    
    // Bound Interface
   
    <%if((obj.testBench =="io_aiu")) {%>
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_latency_if)::get(null, "", $sformatf("<%=obj.BlockId%>_m_top_latency_if%0d", core_no), sb_latency_if)) begin
    <%} else {%>
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_latency_if)::get(null, "", "<%=obj.BlockId%>_m_top_latency_if", sb_latency_if)) begin
    <% } %>
 
        `uvm_fatal("Latency interface error", "virtual interface must be set for latency_if");
    end
    
    //scrb config

    <%if((obj.testBench =="io_aiu")) {%>
        if (!uvm_config_db#(<%=obj.BlockId%>_perf_cnt_units)::get(null, "", $sformatf("<%=obj.BlockId%>_m_perf_counters%0d", core_no), sb_latency_counters_cfg)) 
    <%} else {%>
        if (!uvm_config_db#(<%=obj.BlockId%>_perf_cnt_units)::get(null, "", "<%=obj.BlockId%>_m_perf_counters", sb_latency_counters_cfg)) 
    <% } %>
    begin
        `uvm_fatal("latency counters scoreboard config error", " config must be set");
    end
    // perf monitor:Bound stall_if Interface
    <%if((obj.testBench =="io_aiu")) {%>
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", $sformatf("<%=obj.BlockId%>_0_m_top_stall_if_%0d", core_no), sb_stall_if)) begin
            `uvm_fatal("ioaiu_scoreboard stall interface error", "virtual interface must be set for stall_if");
        end
    <%} else {%>
        <%if ((obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))   ) { %>
            if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if", sb_stall_if)) begin
        <%} else { %>
            if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_m_top_stall_if", sb_stall_if)) begin
        <% } %>
            // test this

            `uvm_fatal("dii_scoreboard stall interface error", "virtual interface must be set for stall_if");
        end
    <%}%>

    latency_table = new[sb_latency_if.nLatencyCounters];
    start_count = new[sb_latency_if.nLatencyCounters];
    latency_table_tmp = new[sb_latency_if.nLatencyCounters];
endfunction: build_phase



task <%=obj.BlockId%>_latency_counters_scoreboard::main_phase(uvm_phase phase);
    




    fork : main_fork
        
        begin : configure_count_fork
            forever begin
                @(posedge sb_latency_if.clk);
                if (new_cfg) begin
                    //`uvm_info(get_full_name(), $sformatf("ZIED DEBUG SB CFG : New config trigged and local count_clear=%0d",sb_latency_counters_cfg.localCount_reg.count_clear),UVM_LOW);
                
                    latency_type = sb_latency_counters_cfg.lct_reg.lct_type;
                    latency_pre_scale  = int'(2**(sb_latency_counters_cfg.lct_reg.lct_pre_scale+1)) ; 
                    offset = sb_latency_counters_cfg.lct_reg.lct_bin_offset;
                
                    sb_latency_if.latency_pre_scale = latency_pre_scale;
                    @(posedge sb_latency_if.div_clk_rtl);
                    repeat (2) @(posedge sb_latency_if.clk);
                    sb_latency_if.div_en = 1'b1;
                    
                end
            end
        end

        begin : get_clk_div
       
             sb_latency_if.clk_div(); 
 
        end 

        begin : main_latency_count
           for (int j=0; j< sb_latency_if.nLatencyCounters ;j++) begin
                fork 
                    automatic int lct_index= j;
                begin
                    latency_count(lct_index); 
                end
                join_none
            end
            wait fork;
        end

        begin : main_get_latency_signals
            for (int k=0; k< sb_latency_if.nLatencyCounters ;k++) begin
                 fork 
                     automatic int entry_idx= k;
                 begin
                    sb_latency_if.get_latency_signals(entry_idx); 
                 end
                 join_none
             end
             wait fork;
         end
        
        begin : bins_count_fork
            for (int i=0; i< bins_num ;i++) begin
                 fork 
                     automatic int bins_id= i;
                 begin
                    bins_count(bins_id); 
                 end
                 join_none
             end
             wait fork;
         end

    join
 
    `uvm_info(get_full_name(), $sformatf("Latency scoreboard DEBUG SB: End of latency_historgam_gen"),UVM_LOW)

endtask: main_phase



task <%=obj.BlockId%>_latency_counters_scoreboard::bins_count(int bins_id);

    forever begin  
        
        @(posedge sb_latency_if.clk);

        if (sb_latency_counters_cfg.lct_reg.lct_count_enable == 1 && sb_latency_counters_cfg.main_cntr_reg.local_count_enable == 1)  begin
   
            if (sb_latency_if.dut_latency_bins[bins_id]) begin
                `uvm_info(get_full_name(), $sformatf("DUT latency_bins_dut  bin%0d", bins_id),UVM_LOW)
                latency_bins_dut[bins_id]++;
            end
        
        end
    end

endtask: bins_count


task <%=obj.BlockId%>_latency_counters_scoreboard::latency_count(int alloc_id);

    int counter_pre_scaled = 0;
    bit latency_event = 0 ;
    latency_table[alloc_id] = 0;
    latency_table_tmp[alloc_id] = 0;
    
    fork
    begin
        forever begin
            @(posedge sb_latency_if.clk);
            if (sb_latency_counters_cfg.main_cntr_reg.local_count_enable == 1) begin
                if ( sb_latency_if.dealloc[alloc_id] && (start_count[alloc_id] || sb_latency_if.alloc[alloc_id]) &&  sb_latency_if.local_count_enable  == 1) begin
                    if (sb_latency_if.start_count[alloc_id]) begin
                        if (latency_table[alloc_id] < 511 ) begin
                            latency_table[alloc_id]= latency_table[alloc_id] + latency_table_tmp[alloc_id];
                        end

                        create_bin(alloc_id); // Create bins prior to clear it
                    end

                    latency_table[alloc_id] = 0; // Clear latency counter entry value
                    latency_table_tmp[alloc_id] = 0 ;
                    if (! sb_latency_if.alloc[alloc_id]) begin // if alloc appear in same time, we let lct counter runs .
                        start_count[alloc_id] = 0;
                    end
                end else begin
                   if ( sb_latency_if.dealloc[alloc_id] && (start_count[alloc_id] || sb_latency_if.alloc[alloc_id]) && sb_latency_if.local_count_enable == 0) begin
                   repeat(4)begin
                           @(posedge sb_latency_if.clk);                    
                   end
                   if(sb_latency_counters_cfg.main_cntr_reg.local_count_enable == 1)
                        `uvm_error("Latency_SCB",$sformatf("not expect local_count_enable 1 at here"))
                   else if (! sb_latency_if.alloc[alloc_id]) 
                   start_count[alloc_id] = 0;

                   end
 
                end
            end
        end
    end

    begin
        forever begin
            @(posedge sb_latency_if.clk);
            if (sb_latency_counters_cfg.main_cntr_reg.local_count_enable == 1) begin

                if (sb_latency_if.alloc[alloc_id] == 1'b1) begin
                    start_count[alloc_id] = 1;
                    if (sb_latency_if.div_clk) begin // CONC-10272
                        latency_table_tmp[alloc_id]++;
                    end
                end
            end
        end

    end

    begin
        forever begin  : latency_count
            @(posedge sb_latency_if.div_clk);
            if (sb_latency_counters_cfg.main_cntr_reg.local_count_enable == 1) begin

                if ((sb_latency_counters_cfg.lct_reg.lct_count_enable == 1) && start_count[alloc_id]  && !sb_latency_if.dealloc[alloc_id] ) begin // CONC-10285
                    @(posedge sb_latency_if.clk);
                    if (latency_table[alloc_id] < 511 ) begin
                        latency_table[alloc_id]++;
                    end
                end
            end
        end
    end

    begin
        forever begin
            @(posedge sb_latency_if.clk);
            for (int i=0; i < sb_latency_if.nLatencyCounters ;i++) begin
                sb_latency_if.start_count[i] = start_count[i];
                sb_latency_if.latency_cpt[i] = latency_table[i];
            end
        end
    end

join
endtask: latency_count

function <%=obj.BlockId%>_latency_counters_scoreboard::create_bin(int id);
    
    int latency_with_offset =  0;
    int bins_id =  0;
    if (latency_table[id] > offset) latency_with_offset = latency_table[id] - offset;
    // collect latency_value to latency_if for debug
    sb_latency_if.cnt_value = latency_table[id];
    sb_latency_if.cnt_value_with_offset = latency_with_offset;

    //Coverage collect
    latency_counter         = latency_table[id];


    case (latency_with_offset) inside 

            [0:7] : begin 
                        latency_bins[0]++;
                        sb_stall_if.perf_count_events["Bins0"].push_back(0);
                        bins_id = 0;
                    end
            [8:15]: begin 
                        latency_bins[1]++;
                        sb_stall_if.perf_count_events["Bins1"].push_back(1);
                        bins_id = 1;
                    end
            [16:31] :begin 
                        latency_bins[2]++;
                        sb_stall_if.perf_count_events["Bins2"].push_back(2);
                        bins_id = 2;
                    end
            [32:63] :begin 
                        latency_bins[3]++;
                        sb_stall_if.perf_count_events["Bins3"].push_back(3);
                        bins_id = 3;
                    end
            [64:95] :begin 
                        latency_bins[4]++;
                        sb_stall_if.perf_count_events["Bins4"].push_back(4);
                        bins_id = 4;
                    end
            [96:127] : begin 
                        latency_bins[5]++;
                        sb_stall_if.perf_count_events["Bins5"].push_back(5);
                        bins_id = 5;
                    end
            [128:255] :begin 
                         latency_bins[6]++;
                         sb_stall_if.perf_count_events["Bins6"].push_back(6);
                        bins_id = 6;
                    end
            default : begin 
                        latency_bins[7]++;
                        sb_stall_if.perf_count_events["Bins7"].push_back(7);
                        bins_id = 7;
            end

    endcase

    `uvm_info(get_full_name(), $sformatf("TB latency_with_offset %0d from entry %0d into bin%0d latency_table=%0d offset=%0d ",latency_with_offset, id, bins_id, latency_table[id], offset),UVM_LOW)


endfunction: create_bin

function <%=obj.BlockId%>_latency_counters_scoreboard::print_bins();
       
    foreach (latency_bins[i]) begin
        `uvm_info(get_full_name(), $sformatf("Latency scoreboard DEBUG SB: latency_bin[%2d] = %0d",i,latency_bins[i]),UVM_LOW)
    end

endfunction: print_bins


task <%=obj.BlockId%>_latency_counters_scoreboard::set_new_config();

    new_cfg = 1'b1;
    repeat(2) @(posedge sb_latency_if.clk); 
    new_cfg = 1'b0;

endtask: set_new_config

//#Check.DII.Pmon.v3.4.LatencyBins 
//#Check.DMI.Pmon.v3.4.LatencyBins
//#Check.CHIAIU.Pmon.v3.4.LatencyBins
//#Check.IOAIU.Pmon.v3.4.LatencyBins
function <%=obj.BlockId%>_latency_counters_scoreboard::compare_bins();
    
    
    for (int j=0; j< bins_num ;j++) begin
        if (latency_bins[j] == latency_bins_dut[j])
            `uvm_info(get_full_name(), $sformatf("Latency scoreboard check_latency bin %0d is OK",j),UVM_LOW)
        else 
            `uvm_error(get_full_name(), $sformatf("Mismatch bin %0d  : dut value %0d(0x%0x) /= reference final SB value %0d(0x%0x) for Latency configuration :###### Latency type = %s ######  latency scale = %0d ###### latency bins offset =%0d",j,latency_bins_dut[j],latency_bins_dut[j], latency_bins[j],latency_bins[j],sb_latency_counters_cfg.lct_reg.lct_type.name(),int'(2**(sb_latency_counters_cfg.lct_reg.lct_pre_scale+1)),sb_latency_counters_cfg.lct_reg.lct_bin_offset))
    end
    latency_cov();

endfunction: compare_bins 

function <%=obj.BlockId%>_latency_counters_scoreboard::latency_cov();
  foreach (latency_bins[i]) begin
      latency_cnt_bins=8'h00;
   for(int k=0;k < latency_bins[i];k++)begin
      latency_cnt_bins[i] = 1'b1;
      sb_latency_counters_cfg.m_cov_lct_cnt.sample();
   end
   end
    
endfunction:latency_cov



