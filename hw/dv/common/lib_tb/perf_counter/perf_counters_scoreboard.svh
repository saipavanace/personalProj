`include "uvm_macros.svh"
import <%=obj.BlockId%>_perf_cnt_unit_defines::*;
class <%=obj.BlockId%>_perf_counters_scoreboard extends uvm_scoreboard;
    `uvm_component_param_utils(<%=obj.BlockId%>_perf_counters_scoreboard);
    ////////////////
        
    typedef count_value_obj count_value_fifo[$];
    typedef bit [31:0] cnt_value_fifo[$];
    count_value_fifo perf_counters[<%=obj.MaxnPerfCounters%>];
    const int pmon_latency_num = 4 ;
    // Interfaces
    virtual <%=obj.BlockId%>_stall_if sb_stall_if;

    // declare config object

    <%=obj.BlockId%>_perf_cnt_units sb_perf_counters_cfg;

    ///////////////////////////

    counter_type counter[];
    counter_type counter_saved[];

    bit disable_sb = 0;
    bit new_cfg = 0;
    bit new_cfg_setted;
    bit save_counter = 0;
    bit pmon_latency_test =0;
    bit overflow_status[];
    bit [15:0] R_LPF[];
    bit event_trigged[][2];
    count_value_fifo perf_cnt_ref_value[];
    cnt_value_fifo reg_lpf_value[];
    cnt_value_fifo ref_lpf_value[];
    int tolerance_pct   = 0 ;
    int xtt_entries_tolerance_pct=0;
    bit test_only_lpf   = 0 ;
    bit no_event_check_dis = 0 ;
    bit queue_check_dis = 0 ;
    int core_no = 0;

    <%if((obj.testBench =="io_aiu")) {%> 
    string inst_scb_cfg_name = $sformatf("<%=obj.BlockId%>_m_perf_counters%0d", core_no);
    <%} else {%> 
    string inst_scb_cfg_name = "<%=obj.BlockId%>_m_perf_counters";
    <% } %> 
    string stall_if_name = "<%=obj.BlockId%>_m_top_stall_if";
    // ------------------------------------------------------------------------
    // Methods
    // ------------------------------------------------------------------------
    extern function                     new             (string name="<%=obj.BlockId%>_perf_counters_scoreboard", uvm_component parent=null);
    extern virtual function void        build_phase     (uvm_phase phase);
    //extern task                         configure_phase (uvm_phase phase);
    //extern task                         pre_main_phase  (uvm_phase phase);
    extern task                         configure_counter(int perf_counter_id);
    extern task                         main_phase      (uvm_phase phase);
    extern function void                stall_counter_compare(int perf_cnt_id);
    extern function void                multi_bits_counter_compare(int perf_cnt_id);
    extern function void                xtt_entries_event_counter_compare(int perf_cnt_id);
    extern function void                xtt_entries_event_max_min_check(int perf_cnt_id);
    extern function void                interleaved_data_event_counter_compare(int perf_cnt_id);
    extern function void                stall_counter_compare_all();
    extern function void                clear_counter(int perf_cnt_id);
    extern function void                clear_full_counter();
    extern function bit                 check_is_multi_event(int perf_cnt_id);
    extern task                         stall_count(int perf_cnt_id);
    extern task                         multi_bits_event_count(int perf_cnt_id);
    extern task                         set_new_config();
    extern task                         set_save_counter();
    extern function void                print_counter(int perf_cnt_id);
    extern function void                print_full_counter();
    extern task                         force_counter_value(counter_type counter_arg,int perf_cnt_id);
    extern task                         force_all_counter_value(counter_type counter_arg);
    extern function void                store_counter_value(counter_type counter_arg,int perf_cnt_id);
    extern function int                 store_max_saturation_value(counter_type counter_arg,int perf_cnt_id);
    extern function int                 store_lpf_value(counter_type counter_arg,int perf_cnt_id);
    extern function void                set_rollover_overflow_status(counter_type counter_arg,int perf_cnt_id);
    extern task                         set_cnt_reg_value_q(int id);
    extern function bit                 check_is_counting(int perf_cnt_id);
    extern function bit                 check_is_xtt_entries_event(int perf_cnt_id);
    extern function bit                 check_is_interleaved_data_event(int perf_cnt_id);
    extern task                         set_lpf_value(int id);
    extern function void                cross_check_queues(count_value_fifo fifo1, count_value_fifo fifo2 , ref int communs_items_idx[$]);
    extern function void                xtt_entries_event_counter_compare_with_tolerance(int perf_cnt_id);
    extern function int                 get_max(count_value_fifo q);
    //Pmon 3.4 latency
    <% if (obj.Block == 'dii' || (obj.testBench =="io_aiu")  || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>
   
    extern function void latency_counter_compare(int perf_cnt_id);
    extern task latency_count(int perf_cnt_id);
    
    <% } %>
endclass: <%=obj.BlockId%>_perf_counters_scoreboard

// ----------------------------------------------------------------------------
// Class Methods Implementation
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
function <%=obj.BlockId%>_perf_counters_scoreboard::new(string name="<%=obj.BlockId%>_perf_counters_scoreboard", uvm_component parent=null);
    super.new(name, parent);
    counter = new [<%=obj.DutInfo.nPerfCounters%>];
    counter_saved = new [<%=obj.DutInfo.nPerfCounters%>];
    overflow_status = new [<%=obj.DutInfo.nPerfCounters%>];
    R_LPF = new [<%=obj.DutInfo.nPerfCounters%>];
    event_trigged = new [<%=obj.DutInfo.nPerfCounters%>];
    perf_cnt_ref_value = new [<%=obj.DutInfo.nPerfCounters%>];
    reg_lpf_value = new [<%=obj.DutInfo.nPerfCounters%>];
    ref_lpf_value = new [<%=obj.DutInfo.nPerfCounters%>];
endfunction: new

// ----------------------------------------------------------------------------
function void <%=obj.BlockId%>_perf_counters_scoreboard::build_phase(uvm_phase phase);
    // Use parent method
    super.build_phase(phase);

    // Bound Interface
    <%if(obj.testBench !== "fsys" && (obj.testBench != "emu")){%>            
        <% if((obj.Block =='chi_aiu') && (obj.testBench != "fsys")){ %>     
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if", sb_stall_if)) begin
        <%}else if(obj.Block == 'io_aiu'){%>
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", $sformatf("<%=obj.BlockId%>_0_m_top_stall_if_%0d", core_no), sb_stall_if)) begin
        <% } else { %>
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", stall_if_name, sb_stall_if)) begin
        <% } %>
            `uvm_fatal("Stall interface error", "virtual interface must be set for stall_if");
        end
    <%} else {%>
        <% if((obj.Block =='chi_aiu') && (obj.testBench != "fsys" && (obj.testBench != "emu"))){ %>     
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if", sb_stall_if)) begin
        <% } else if ((obj.Block == 'io_aiu') && (obj.testBench != "fsys" && (obj.testBench != "emu"))) { %>
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", $sformatf("<%=obj.BlockId%>_0_m_top_stall_if_%0d", core_no), sb_stall_if)) begin
        <% } else { %>
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", stall_if_name, sb_stall_if)) begin
        <% } %>
            `uvm_fatal("Stall interface error", "virtual interface must be set for stall_if");
        end  
    <%}%>

    // scrb config

    <%if((obj.testBench =="io_aiu")) {%> 
    inst_scb_cfg_name = $sformatf("<%=obj.BlockId%>_m_perf_counters%0d", core_no);
    <%}  %>

     // Bound Interface
    if (!uvm_config_db#(<%=obj.BlockId%>_perf_cnt_units)::get(null, "", inst_scb_cfg_name, sb_perf_counters_cfg)) 
    begin
        `uvm_fatal("perf counters scoreboard config error", " config must be set");
    end

endfunction: build_phase



task <%=obj.BlockId%>_perf_counters_scoreboard::configure_counter(int perf_counter_id);
    
    string stall_event_first,stall_event_second;
    //Pmon 3.4 feature
    <% if (obj.Block == 'dii' || (obj.testBench =="io_aiu")  || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %> 
    ///////////// BW /////////////////
    bit filter_en ;
    bit [19:0] filter_value_out;
    bit filter_select ;
    bit [19:0] filter_mask;

    filter_en          = sb_perf_counters_cfg.bw_filter_reg[perf_counter_id].filter_enable;
    filter_value_out   = sb_perf_counters_cfg.bw_filter_reg[perf_counter_id].filter_value;
    filter_select      = sb_perf_counters_cfg.bw_filter_reg[perf_counter_id].filter_select;
    filter_mask        =  sb_perf_counters_cfg.bw_mask_reg[perf_counter_id].mask_value;
    //////////////////////////////////////
    <% } %> 
    stall_event_first  = sb_perf_counters_cfg.cfg_reg[perf_counter_id].count_event_first.name();
    stall_event_second = sb_perf_counters_cfg.cfg_reg[perf_counter_id].count_event_second.name();
    
    

  
    fork : configure_count_fork
        begin
            forever begin
                @(posedge sb_stall_if.clk);
                if (new_cfg) begin
                `uvm_info(get_full_name(), $sformatf("SB CFG : New config trigged and count_clear=%0d",sb_perf_counters_cfg.cfg_reg[perf_counter_id].count_clear),UVM_LOW);
                stall_event_first  =  sb_perf_counters_cfg.cfg_reg[perf_counter_id].count_event_first.name(); 
                stall_event_second =  sb_perf_counters_cfg.cfg_reg[perf_counter_id].count_event_second.name();
                new_cfg_setted=1;
                //Pmon 3.4 feature
                <% if (obj.Block == 'dii' || obj.Block == 'dmi' || (obj.testBench =="io_aiu")  || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %> 
                filter_en          =  sb_perf_counters_cfg.bw_filter_reg[perf_counter_id].filter_enable;
                filter_value_out   =  sb_perf_counters_cfg.bw_filter_reg[perf_counter_id].filter_value;
                filter_select      =  sb_perf_counters_cfg.bw_filter_reg[perf_counter_id].filter_select;
                filter_mask        =  sb_perf_counters_cfg.bw_mask_reg[perf_counter_id].mask_value;
                <% } %> 
              
                end
                sb_stall_if.stall_event[perf_counter_id][0] = stall_event_first; 
                sb_stall_if.stall_event[perf_counter_id][1] = stall_event_second;
                //Pmon 3.4 feature
                <% if (obj.Block == 'dii' || obj.Block == 'dmi'|| (obj.testBench =="io_aiu")  || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %> 
                sb_stall_if.filter_en[perf_counter_id]      =   filter_en    ;                                                                
                sb_stall_if.filter_value_out[perf_counter_id]   =   filter_value_out ;
                sb_stall_if.filter_select[perf_counter_id]  =   filter_select;
                sb_stall_if.filter_mask[perf_counter_id]  =   filter_mask;
                <% } %> 
            end
        end
        

        begin : forever_stall_event0 
            sb_stall_if.get_stall_event_signals(perf_counter_id,0);
        end

        begin : forever_stall_event1
            sb_stall_if.get_stall_event_signals(perf_counter_id,1);
        end

        begin : forever_multi_bits_event0 
            sb_stall_if.get_multi_bits_event_signals(perf_counter_id,0);
        end

        begin : forever_multi_bits_event1
            sb_stall_if.get_multi_bits_event_signals(perf_counter_id,1);
        end

<% if ((obj.testBench != "fsys") && (obj.Block == 'dve')) { %>
        begin : update_master_count_enable
            bit master_count_enable_rtl = 1'b0;
            bit master_count_enable_sb = 1'b0;
            int delay = 0;
            int cutoff = 1; // max time to wait for propagation
          forever begin
            @(posedge sb_stall_if.clk);
            master_count_enable_sb = sb_perf_counters_cfg.main_cntr_reg.master_count_enable;
            master_count_enable_rtl = sb_stall_if.master_cnt_enable;
            // #Check.DVE.PerfMon.MasterTrigger
            if(master_count_enable_sb != master_count_enable_rtl) begin
              delay++;
              if(delay > cutoff) begin
                `uvm_error(get_full_name(), "master_count_enable enable not propagated to stall_if")
              end
            end else begin
              if(delay > 0) begin
                `uvm_info(get_full_name(), $sformatf("master_count_enable propagated in %0d cycles", delay), UVM_HIGH)
              end
              delay = 0;
            end
          end
        end: update_master_count_enable
<% } %>

    join_any
   
    `uvm_info(get_full_name(), $sformatf("SB CFG : End of get_stall_event"),UVM_LOW)


endtask: configure_counter


task <%=obj.BlockId%>_perf_counters_scoreboard::stall_count(int perf_cnt_id);

e_counter_control   counter_control;
counter_type        counter_stall = 0;
int                 stall_period = 1;
count_value_obj     cnt_value_t;
bit                 count_value_saved;
bit initial_value_setted[2]='{0,0};
bit current_cycle[2] = '{0,0};
bit prev_cycle[2] = '{0,0};
bit prev_prev_cycle[2] = '{0,0};
bit entered[2] = '{0,0};
bit not_event_result;
counter_type counter_stalled[2] ='{0,0};
bit event_signal[2];
cnt_value_t.cnt_v = 0;
cnt_value_t.cnt_v_str = 0;

forever begin
    string list_stall_evt[<%=obj.listEventStallName.length%>] = '{<%=obj.listEventStallName.map(item => `"${item}"`).join(",")%>};
    string q_first[$], q_second[$];
    bit local_count_enable = 0 ;
    bit master_count_enable = 0 ; // only availble on dve;

    @(posedge sb_stall_if.clk);
     //Pmon 3.4 feature
    local_count_enable = sb_perf_counters_cfg.main_cntr_reg.local_count_enable;
<% if ((obj.testBench == "fsys") || !(obj.Block == 'dve')) { %>
    master_count_enable = sb_perf_counters_cfg.main_cntr_reg.master_count_enable && sb_stall_if.master_cnt_enable; //pilot by DVE
<% } %>

    counter_control = sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control;
    q_first=list_stall_evt.find(str) with (str==sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name());
    q_second=list_stall_evt.find(str) with (str==sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name());
    if( q_first.size() && q_second.size()) begin
        stall_period  = int'(2**sb_perf_counters_cfg.cfg_reg[perf_cnt_id].minimum_stall_period) ; 
    end
    //#Check.DII.Pmon.v3.2.MinStallPeriod
    if(new_cfg_setted) begin
       prev_prev_cycle[0] = prev_cycle[0];
       prev_cycle     [0] = current_cycle[0];
       current_cycle  [0] = sb_stall_if.stall_event_signal[perf_cnt_id][0];
       prev_prev_cycle[1] = prev_cycle[1];
       prev_cycle     [1] = current_cycle[1];
       current_cycle  [1] = sb_stall_if.stall_event_signal[perf_cnt_id][1];
    end
    if (sb_stall_if.stall_event_signal[perf_cnt_id][0]) begin
        counter_stalled[0]++;
        if (counter_stalled[0]%stall_period == 0) begin
            event_signal[0] = 1;
            counter_stalled[0] = 0 ;
        end else begin
            event_signal[0] = 0;
        end
        //CONC-17129
        if(sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_enable  == 0 && counter[perf_cnt_id] == 0 && new_cfg_setted && entered[0]==0) begin
          entered[0] = 1;
           if(stall_period > 2) begin
                counter_stalled[0] =2;
           end
           else begin
             fork
             begin : BEGIN1
                wait(sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_enable  == 1);
                if(stall_period==2 && counter[perf_cnt_id] ==0)begin
                     if(prev_prev_cycle[0] && prev_cycle[0])counter[perf_cnt_id] = 1; 
                     else if(prev_cycle[0])counter_stalled[0] =1;
                end
                if(stall_period==1 && counter[perf_cnt_id] ==0) begin
                    if(prev_prev_cycle[0] && prev_cycle[0]) counter[perf_cnt_id] = 2;
                    if((prev_prev_cycle[0]==0 && prev_cycle[0]==1) || (prev_prev_cycle[0]==1 && prev_cycle[0]==0)) begin 
                        counter[perf_cnt_id]=1;                        
                    end
                end
                initial_value_setted[0]=1;
             end
             join_none
           end
        end 
    end
    else begin 
        event_signal[0] = 0;
        counter_stalled[0] = 0 ;
    end
    if (sb_stall_if.stall_event_signal[perf_cnt_id][1]) begin
        counter_stalled[1]++;
        if (counter_stalled[1]%stall_period == 0) begin
            event_signal[1] = 1;
            counter_stalled[1] = 0 ;
        end else begin
            event_signal[1] = 0;
        end
        if(sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_enable  == 0 && counter[perf_cnt_id] == 0 && new_cfg_setted && entered[1]==0) begin
             entered[1] = 1;
           if(stall_period > 2) begin
                counter_stalled[1] =2;
           end
           else begin
             fork
             begin
                wait(sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_enable  == 1 );
                if(stall_period==2 && counter[perf_cnt_id] ==0)begin
                     if(prev_prev_cycle[0] && prev_cycle[0])counter[perf_cnt_id] = 1; 
                     else if(prev_cycle[0])counter_stalled[0] =1;
                end
                if(stall_period==1 && counter[perf_cnt_id] ==0) begin
                    if(prev_prev_cycle[0] && prev_cycle[0]) counter[perf_cnt_id] = 2;
                    if((prev_prev_cycle[0]==0 && prev_cycle[0]==1) || (prev_prev_cycle[0]==1 && prev_cycle[0]==0)) begin 
                        counter[perf_cnt_id]=1;
                    end
                end
                initial_value_setted[1]=1;
             end
             join_none
           end
        end 
    end
    else begin 
        event_signal[1] = 0;
        counter_stalled[1] = 0 ;
    end
    if ((check_is_multi_event(perf_cnt_id) == 0 ) && (pmon_latency_test == 0)) begin
        if (sb_stall_if.stall_event_signal[perf_cnt_id][0]) begin
            event_trigged[perf_cnt_id][0] = 1;
        end

        if (sb_stall_if.stall_event_signal[perf_cnt_id][1]) begin
            event_trigged[perf_cnt_id][1] = 1;
        end
        //#Check.DII.Pmon.v3.4.LocalEnableDisable 
        //#Check.CHIAIU.Pmon.v3.4.LocalEnableDisable
        //#Check.IOAIU.Pmon.v3.4.LocalEnableDisable
        if ((sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_enable  == 1) || (local_count_enable  == 1) || (master_count_enable == 1)) begin 
            sb_stall_if.div_16_counter_en=1'b1;
            case (counter_control)
            //#Check.DII.Pmon.v3.2.Normal
            NORMAL_C : begin
                    //events may be asserted ==> verify cases if asserted
                        if (event_signal[0]) begin
                            counter[perf_cnt_id]++;
                            count_value_saved = 0;
                        end
                    
                        if (event_signal[1]) begin
                            counter[perf_cnt_id]++;
                            count_value_saved = 0;
                        end
                        not_event_result = !(event_signal[0] || event_signal[1]);
            end
            //#Check.DII.Pmon.v3.2.And
            AND_C : begin
                    // event 0 and event 1 asserted together
                      if (event_signal[0] && event_signal[1]) begin
                            counter[perf_cnt_id]++;
                            count_value_saved = 0;
                       end
                       not_event_result = !(event_signal[0] && event_signal[1]);
            end
            //#Check.DII.Pmon.v3.2.XOR
            XOR_C : begin
                   /// //only event 0 asserted
                    if (event_signal[0] && !event_signal[1]) begin
                        counter[perf_cnt_id]++;
                        count_value_saved = 0;
                    end

                   //only event 1 asserted
                    if (event_signal[1] && !event_signal[0] ) begin
                        counter[perf_cnt_id]++;
                        count_value_saved = 0;
                    end

                    not_event_result = !((event_signal[0] && !event_signal[1])||
                    (event_signal[1] && !event_signal[0]));
            end
            //#Check.DII.Pmon.v3.4.XCNT32BIT  
            //#Check.DMI.Pmon.v3.4.XCNT32BIT
            //#Check.CHIAIU.Pmon.v3.4.XCNT32BIT
            //#Check.IOAIU.Pmon.v3.4.XCNT32BIT
            COUNTER_32BIT_C : begin 
                if (event_signal[0]) begin
                    counter[perf_cnt_id][31:0]++;
                    count_value_saved = 0;
                end
            
                if (event_signal[1]) begin
                    counter[perf_cnt_id][63:32]++;
                    count_value_saved = 0;
                end
                not_event_result = !(event_signal[0] || event_signal[1]);

            end
            endcase


                //No events may be asserted ==> save counter value
            if ( not_event_result && !count_value_saved) begin
                store_counter_value(counter[perf_cnt_id],perf_cnt_id);
                count_value_saved = 1;
            end
        end
        if (((disable_sb ==1) || (save_counter == 1)) && !count_value_saved) begin
            store_counter_value(counter[perf_cnt_id],perf_cnt_id);
            count_value_saved = 1;
        end
    end
end
endtask: stall_count




task <%=obj.BlockId%>_perf_counters_scoreboard::force_counter_value(counter_type counter_arg,int perf_cnt_id);
    counter[perf_cnt_id] = counter_arg;
    store_counter_value(counter_arg, perf_cnt_id);
endtask: force_counter_value

task <%=obj.BlockId%>_perf_counters_scoreboard::force_all_counter_value(counter_type counter_arg);
    for (int i=0; i< <%=obj.DutInfo.nPerfCounters%> ;i++) begin
        force_counter_value(counter_arg,i);
    end
endtask:force_all_counter_value


function void <%=obj.BlockId%>_perf_counters_scoreboard::store_counter_value(counter_type counter_arg,int perf_cnt_id);
    e_ssr_count   ssr_count;
    count_value_obj     cnt_value_t;
    
    ssr_count = sb_perf_counters_cfg.cfg_reg[perf_cnt_id].ssr_count;
    cnt_value_t.cnt_v = counter_arg[31:0];
    //#Check.DII.Pmon.v3.2.SsrCapture
    cnt_value_t.cnt_v_str = counter_arg[63:32];

    case (ssr_count)
        //#Check.DII.Pmon.v3.2.SsrClear
        CLEAR : begin
            cnt_value_t.cnt_v_str = 0;
        end

        MAX_SATURATION : begin
            cnt_value_t.cnt_v_str = store_max_saturation_value(counter_arg,perf_cnt_id);
        end
    endcase
    // stroe value to perf counter queue
    perf_counters[perf_cnt_id].push_back(cnt_value_t);
    // test if overflow happens and set overflow status if this case is trigged
    //#Check.DII.Pmon.v3.2.Overflow
    set_rollover_overflow_status(counter_arg,perf_cnt_id);


endfunction : store_counter_value


function int <%=obj.BlockId%>_perf_counters_scoreboard::store_max_saturation_value(counter_type counter_arg,int perf_cnt_id);

    counter_type max_saturation=perf_counters[perf_cnt_id][perf_counters[perf_cnt_id].size()-1].cnt_v_str;

    if (max_saturation < counter_arg) begin
        return(counter_arg);
    end
    else begin
        return(max_saturation);
    end

endfunction : store_max_saturation_value

function void <%=obj.BlockId%>_perf_counters_scoreboard::set_rollover_overflow_status(counter_type counter_arg,int perf_cnt_id);

    e_ssr_count   ssr_count;   
    ssr_count = sb_perf_counters_cfg.cfg_reg[perf_cnt_id].ssr_count;
    //if ( ( (ssr_count == CAPTURE) && (cnt_value_t.cnt_v_str == (2**32 - 1) ) ) || ( (ssr_count != CAPTURE) && (cnt_value_t.cnt_v == (2**32-1))) ) begin
    if ( ( (ssr_count == CAPTURE) && counter_arg[64] ) || ( (ssr_count != COUNTER_32BIT_SAT) && (ssr_count != CAPTURE) && counter_arg[32])) begin
        overflow_status[perf_cnt_id] = 1;
        `uvm_info(get_full_name(), $sformatf("Rollover/Overflow is detected on perf counter %0d , overflow_status is set to %0d",perf_cnt_id,overflow_status[perf_cnt_id]),UVM_MEDIUM)
    end

endfunction : set_rollover_overflow_status

function int <%=obj.BlockId%>_perf_counters_scoreboard::store_lpf_value(counter_type counter_arg,int perf_cnt_id);

    e_filter_select filter_select;
    bit [15:0] R = 0;
    bit [15:0] CNT = 0;
    filter_select = sb_perf_counters_cfg.cfg_reg[perf_cnt_id].filter_select;
    CNT[15:8] = counter_arg[7:0]; 
    R = (CNT >> 7) ;
    for (int i = 1 ;i<8; i++) begin
        if ( i == filter_select) 
        begin
            R = R + (R_LPF[perf_cnt_id] >> i);
        end
        else begin
            R = R + (CNT >> i);  
        end
    end

    R_LPF[perf_cnt_id] = R;
    return (R);

endfunction : store_lpf_value

task <%=obj.BlockId%>_perf_counters_scoreboard::multi_bits_event_count(int perf_cnt_id);

    e_counter_control   counter_control;
    count_value_obj     cnt_value_t;
    bit local_count_enable = 0;
    bit master_count_enable  = 0;
    
    cnt_value_t.cnt_v = 0;
    cnt_value_t.cnt_v_str = 0;
    
    forever begin
        @(posedge sb_stall_if.clk);
        //Pmon 3.4 feature
        local_count_enable = sb_perf_counters_cfg.main_cntr_reg.local_count_enable;
<% if ((obj.testBench == "fsys") || !(obj.Block == 'dve')) { %>
        master_count_enable = sb_perf_counters_cfg.main_cntr_reg.master_count_enable && sb_stall_if.master_cnt_enable; //pilot by DVE
<% } %>
        counter_control = sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control;

        if ((check_is_multi_event(perf_cnt_id) == 1 ) && (pmon_latency_test == 0)) begin
            if (sb_stall_if.multi_bits_event_signal[perf_cnt_id][0] > 0) begin
                event_trigged[perf_cnt_id][0] = 1;
            end
    
            if (sb_stall_if.multi_bits_event_signal[perf_cnt_id][1] > 0) begin
                event_trigged[perf_cnt_id][1] = 1;
            end
            //#Check.DII.Pmon.v3.4.LocalEnableDisable 
            //#Check.DMI.Pmon.v3.4.LocalEnableDisable
            //#Check.CHIAIU.Pmon.v3.4.LocalEnableDisable
            //#Check.IOAIU.Pmon.v3.4.LocalEnableDisable

            if ((sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_enable == 1) ||(local_count_enable == 1) || (master_count_enable == 1) ) begin
                case (counter_control)
                    //#Check.DII.Pmon.v3.2.Normal
                    NORMAL_C : begin
                        counter[perf_cnt_id] = counter_saved[perf_cnt_id] + sb_stall_if.multi_bits_event_signal[perf_cnt_id][0] + sb_stall_if.multi_bits_event_signal[perf_cnt_id][1];
                    end
                    //#Check.DII.Pmon.v3.2.Static
                    STATIC_C : begin
                        counter[perf_cnt_id] = sb_stall_if.multi_bits_event_signal[perf_cnt_id][0] + sb_stall_if.multi_bits_event_signal[perf_cnt_id][1];
                    end
     
                    default : `uvm_fatal(get_full_name(), $sformatf("Counter control = %0d is selected : multi-bits event should be selected with NORMAL or STATIC counter control",counter_control))

                endcase

                //save counter value
                if ( (counter[perf_cnt_id] != counter_saved[perf_cnt_id])) begin
                    //save counter value
                    store_counter_value(counter[perf_cnt_id],perf_cnt_id);
                    counter_saved[perf_cnt_id] = counter[perf_cnt_id]; 
                end
            end
            if ( (disable_sb ==1) || (save_counter == 1) && (counter[perf_cnt_id] != counter_saved[perf_cnt_id])) begin
                //save counter value
                store_counter_value(counter[perf_cnt_id],perf_cnt_id);
                counter_saved[perf_cnt_id] = counter[perf_cnt_id]; 
            end
        end
    end
endtask: multi_bits_event_count


task <%=obj.BlockId%>_perf_counters_scoreboard::main_phase(uvm_phase phase);
    int perf_cnt_id = 0;
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Start of main_phase"),UVM_LOW)

    super.run_phase (phase);
    if($test$plusargs("tolerance_pct")) begin
        if(!$value$plusargs("tolerance_pct=%d",tolerance_pct)) begin
            tolerance_pct = 2;     
        end 
    end
    if($test$plusargs("<%=obj.BlockId%>_tolerance_pct")) begin
        if( !$value$plusargs("<%=obj.BlockId%>_tolerance_pct=%d",tolerance_pct)) begin
            tolerance_pct = 2;
        end     
    end
    if($test$plusargs("xtt_entries_tolerance_pct")) begin
        if(!$value$plusargs("xtt_entries_tolerance_pct=%d",xtt_entries_tolerance_pct)) begin
            xtt_entries_tolerance_pct = 5;     
        end 
    end
    if($test$plusargs("<%=obj.BlockId%>_xtt_entries_tolerance_pct")) begin
        if( !$value$plusargs("<%=obj.BlockId%>_xtt_entries_tolerance_pct=%d",xtt_entries_tolerance_pct)) begin
            xtt_entries_tolerance_pct = 5;
        end     
    end
    if($test$plusargs("test_only_lpf")) begin
        test_only_lpf = 1;
    end
    if($test$plusargs("<%=obj.BlockId%>_test_only_lpf")) begin
        test_only_lpf = 1;
    end

    if($test$plusargs("no_event_check_dis")) begin
        no_event_check_dis = 1;
    end
    if($test$plusargs("<%=obj.BlockId%>_no_event_check_dis")) begin
        no_event_check_dis = 1;
    end

    if($test$plusargs("queue_check_dis")) begin
        queue_check_dis = 1;
    end
    if($test$plusargs("<%=obj.BlockId%>_queue_check_dis")) begin
        queue_check_dis = 1;
    end
    if($test$plusargs("<%=obj.BlockId%>_pmon_latency_test")) begin
        pmon_latency_test = 1;
    end

    if($test$plusargs("pmon_latency_test")) begin
        pmon_latency_test = 1;
    end

       fork : main_fork

           begin
                for (int j=0; j< <%=obj.DutInfo.nPerfCounters%> ;j++) begin
                    fork 
                        automatic int cnt_id= j;
                    begin
                        configure_counter(cnt_id);
                    end
                    join_none;
                end
                wait fork;    
           end
            
           begin
                for (int i=0; i< <%=obj.DutInfo.nPerfCounters%> ;i++) begin
                    fork 
                        automatic int perf_cnt_id= i;
                    begin
                        stall_count(perf_cnt_id); 
                    end
                    join_none
                end
                wait fork;
            end

            begin
                for (int i=0; i< <%=obj.DutInfo.nPerfCounters%> ;i++) begin
                    fork 
                        automatic int perf_counter_id= i;
                    begin
                        multi_bits_event_count(perf_counter_id); 
                    end
                    join_none
                end
                wait fork;
            end

            begin
                for (int i=0; i< <%=obj.DutInfo.nPerfCounters%> ;i++) begin
                    fork 
                        automatic int id= i;
                    begin
                        set_cnt_reg_value_q(id); 
                    end
                    join_none
                end
                wait fork;
            end

            begin
                for (int i=0; i< <%=obj.DutInfo.nPerfCounters%> ;i++) begin
                    fork 
                        automatic int c_id= i;
                    begin
                        //#Check.DII.Pmon.v3.2.SsrLPF
                        set_lpf_value(c_id); 
                    end
                    join_none
                end
                wait fork;
            end

            begin : generate_events
                sb_stall_if.generate_all_events();
            end  
            //Pmon 3.4 latency
            <% if (obj.Block == 'dii' ||  (obj.testBench =="io_aiu") || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>
            /// generate Latency bins
            begin : generate_latency_events
                sb_stall_if.generate_all_latency_events();
            end          
            <% }  %> 
            begin
                forever begin
                    @(posedge sb_stall_if.clk); 
                    if (disable_sb) begin
                        repeat(1) @(posedge sb_stall_if.clk); 
                        disable main_fork;
                    end    
                end
            end
           //Pmon 3.4 latency
            <% if (obj.Block == 'dii' ||(obj.testBench =="io_aiu")  || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>
            begin
                for (int i=0; i< pmon_latency_num ;i++) begin
                    fork 
                        automatic int lct_id= i;
                    begin
                        latency_count(lct_id); 
                    end
                    join_none
                end
                wait fork;
            end
            <% }  %>
        
        join_any


    `uvm_info(get_full_name(), $sformatf("End of main_phase"),UVM_LOW)

    phase.drop_objection(this);
endtask: main_phase

//#Check.DII.Pmon.v3.2.Events
function void <%=obj.BlockId%>_perf_counters_scoreboard::stall_counter_compare_all();
    if(pmon_latency_test == 0) begin
        for (int i=0; i< <%=obj.DutInfo.nPerfCounters%> ;i++) begin
            if (check_is_multi_event(i) == 1) begin
                if (check_is_xtt_entries_event(i) == 1) begin 
                    if (xtt_entries_tolerance_pct == 0) xtt_entries_event_counter_compare(i);
                    else  if (queue_check_dis == 0) xtt_entries_event_counter_compare_with_tolerance(i);
                    xtt_entries_event_max_min_check(i);
                end
                else if (check_is_interleaved_data_event(1) == 1) begin 
                    if (xtt_entries_tolerance_pct == 0)  interleaved_data_event_counter_compare(i);
                    else if (queue_check_dis == 0) xtt_entries_event_counter_compare_with_tolerance(i);
                end
                else multi_bits_counter_compare(i);

            //#Check.DII.Pmon.v3.4.Bw  
            //#Check.DMI.Pmon.v3.4.Bw
            //#Check.CHIAIU.Pmon.v3.4.Bw
            //#Check.DII.Pmon.v3.4.BwFilter 
            //#Check.DMI.Pmon.v3.4.BwFilter
            //#Check.CHIAIU.Pmon.v3.4.BwFilter
            //#Check.DII.Pmon.v3.4.DtrReq 
            //#Check.DMI.Pmon.v3.4.DtrReq 
            //#Check.DII.Pmon.v3.4.DtwReq
            //#Check.DMI.Pmon.v3.4.DtwReq 
            //#Check.CHIAIU.Pmon.v3.4.CmdReqWr 
            //#Check.CHIAIU.Pmon.v3.4.CmdReqRd 
            //#Check.CHIAIU.Pmon.v3.4.SnpRsp
            //#Check.IOAIU.Pmon.v3.4.CmdReqWr 
            //#Check.IOAIU.Pmon.v3.4.CmdReqRd    
            //#Check.IOAIU.Pmon.v3.4.SnpRsp
            //#Check.IOAIU.Pmon.v3.4.BwFilter
            end else stall_counter_compare(i); 

        end
    end
    //Pmon 3.4 latency
    <% if (obj.Block == 'dii' || (obj.testBench =="io_aiu")  || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>
    else begin
    
        for (int i=0; i< pmon_latency_num ;i++) begin
            //#Check.DII.Pmon.v3.4.LatencyCounter 
            //#Check.DMI.Pmon.v3.4.LatencyCounter
            //#Check.CHIAIU.Pmon.v3.4.LatencyCounter
            //#Check.IOAIU.Pmon.v3.4.LatencyCounter
            latency_counter_compare(i); 
        end
    end
    <% }  %>
endfunction: stall_counter_compare_all

function void <%=obj.BlockId%>_perf_counters_scoreboard::xtt_entries_event_counter_compare(int perf_cnt_id);

    // Counter queues (CNTVR,CNTSR)
    int sb_fifo_size=perf_counters[perf_cnt_id].size();
    int rg_fifo_size=perf_cnt_ref_value[perf_cnt_id].size();
    //LPF QUEUES
    int sb_lpf_fifo_size = ref_lpf_value[perf_cnt_id].size();
    int rg_lpf_fifo_size = reg_lpf_value[perf_cnt_id].size();

    if (check_is_counting(perf_cnt_id) == 1) begin
        if (sb_perf_counters_cfg.cfg_reg[perf_cnt_id].ssr_count == LPF) begin
        /// CAse of LPF : check queue of LPF
            if (test_only_lpf == 0 && queue_check_dis == 0) begin
                if (sb_fifo_size != rg_fifo_size) begin
                    `uvm_error(get_full_name(), $sformatf("mismatch in queue size between scoreboard and reg for CNTVR : Reg queue size %0d /= reference SB queue size %0d for perf counter %0d"
                    ,rg_fifo_size,sb_fifo_size,perf_cnt_id))
                end
                else begin
                    for (int i=0; i< sb_fifo_size;i++) begin
                        if (perf_counters[perf_cnt_id][i].cnt_v != perf_cnt_ref_value[perf_cnt_id][i].cnt_v) begin
                            `uvm_error(get_full_name(), $sformatf("Error in CNTVR : Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d",perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v,perf_cnt_id))
                        end else begin
                            `uvm_info(get_full_name(), $sformatf("CNTVR OK Reg value %0d(0x%0x) == SB value %0d(0x%0x) for perf counter %0d",perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v, perf_cnt_id),UVM_MEDIUM)
                        end
                    end
                end
            end
            if (sb_lpf_fifo_size != rg_lpf_fifo_size) begin
                `uvm_error(get_full_name(), $sformatf("mismatch in queue size between scoreboard and reg for CNTSR : Reg queue size %0d /= reference SB queue size %0d for perf counter %0d"
                ,rg_lpf_fifo_size,sb_lpf_fifo_size,perf_cnt_id))
            end
            //#Check.DII.Pmon.v3.2.LPF
            else begin
                for (int i=0; i< sb_lpf_fifo_size;i++) begin
                    if (ref_lpf_value[perf_cnt_id][i] != reg_lpf_value[perf_cnt_id][i]) begin
                        `uvm_error(get_full_name(), $sformatf("Error in CNTSR (LPF) index %0d: Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d",i,reg_lpf_value[perf_cnt_id][i],reg_lpf_value[perf_cnt_id][i],ref_lpf_value[perf_cnt_id][i],ref_lpf_value[perf_cnt_id][i],perf_cnt_id))
                    end else begin
                        `uvm_info(get_full_name(), $sformatf("CNTSR (LPF) OK index %0d: Reg value %0d(0x%0x) == SB value %0d(0x%0x) for perf counter %0d",i,reg_lpf_value[perf_cnt_id][i],reg_lpf_value[perf_cnt_id][i],ref_lpf_value[perf_cnt_id][i],ref_lpf_value[perf_cnt_id][i], perf_cnt_id),UVM_MEDIUM)
                    end
                end
            end


        end
        else begin
            if (queue_check_dis == 0) begin
                if (sb_fifo_size != rg_fifo_size) begin
                    `uvm_error(get_full_name(), $sformatf("mismatch in queue size between scoreboard and reg captured values for : Reg queue size %0d /= reference SB queue size %0d for perf counter %0d"
                    ,rg_fifo_size,sb_fifo_size,perf_cnt_id))
                end

                else begin
                    `uvm_info(get_full_name(), $sformatf("Queues size of reg value and ref sb values are matching so start Checking values for perf counter %0d",perf_cnt_id),UVM_MEDIUM)
                    for (int i=0; i< sb_fifo_size;i++) begin
                        if ((perf_counters[perf_cnt_id][i].cnt_v == perf_cnt_ref_value[perf_cnt_id][i].cnt_v) && (perf_counters[perf_cnt_id][i].cnt_v_str == perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str) ) begin
                            `uvm_info(get_full_name(), $sformatf("Check Perf counter is OK for perf counter %0d",perf_cnt_id),UVM_MEDIUM)
                        end
                        if (perf_counters[perf_cnt_id][i].cnt_v != perf_cnt_ref_value[perf_cnt_id][i].cnt_v) begin
                            `uvm_error(get_full_name(), $sformatf("Error in Count Value : Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d",perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v,perf_cnt_id))
                        end else begin
                            `uvm_info(get_full_name(), $sformatf("Count value OK Reg value %0d(0x%0x) == SB value %0d(0x%0x) for perf counter %0d",perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v, perf_cnt_id),UVM_MEDIUM)
                        end
                        if (perf_counters[perf_cnt_id][i].cnt_v_str != perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str) begin
                            `uvm_error(get_full_name(), $sformatf("Error in Count Saturation Value : Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d",perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str,perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str,perf_counters[perf_cnt_id][i].cnt_v_str,perf_counters[perf_cnt_id][i].cnt_v_str,perf_cnt_id))
                        end else begin
                            `uvm_info(get_full_name(), $sformatf("Count saturation value OK Reg value %0d(0x%0x) == SB value %0d(0x%0x) for perf counter %0d",perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str,perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str,perf_counters[perf_cnt_id][i].cnt_v_str,perf_counters[perf_cnt_id][i].cnt_v_str,perf_cnt_id),UVM_MEDIUM)
                        end
                    end 
                end
            end
        end
    end
    else begin
        if (rg_fifo_size == 0 || ((rg_fifo_size == 1) && (perf_cnt_ref_value[perf_cnt_id][0].cnt_v == 0))) begin
        `uvm_error(get_full_name(), $sformatf("NO event was counted at counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d"
            ,perf_cnt_id,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
        end

        else begin
            `uvm_error(get_full_name(), $sformatf("NO event was detected at scoreboard but event was received by RTL for counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d"
            ,perf_cnt_id,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
        end
    end
    

endfunction : xtt_entries_event_counter_compare


function void <%=obj.BlockId%>_perf_counters_scoreboard::xtt_entries_event_max_min_check(int perf_cnt_id);

    int xtt_entries_nb;
    // Counter queues (CNTVR,CNTSR)
    count_value_obj reg_value= sb_perf_counters_cfg.count_value[perf_cnt_id];
    int pmon_xtt_entries_max = get_max(perf_cnt_ref_value[perf_cnt_id]);
    string multi_bits_event_first = sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name();
    string multi_bits_event_second =sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name();
    
    <%if (obj.Block == 'dve') {%>
        xtt_entries_nb = (1<<<%=obj.DveInfo[obj.Id].cmpInfo.nSttEntries%>);   
    <%}/*dve*/%>
         
    <%if (obj.Block == 'dce') {%>
    xtt_entries_nb = <%=obj.DceInfo[0].nAttCtrlEntries%>;
    <%}/*dce*/%>
    
    <% if (obj.Block == 'dii') {%>
          int wtt_entries_nb = <%=obj.DiiInfo[obj.Id].cmpInfo.nWttCtrlEntries%>;
          int rtt_entries_nb = <%=obj.DiiInfo[obj.Id].cmpInfo.nRttCtrlEntries%>;
          if((multi_bits_event_first=="Active_WTT_entries") || (multi_bits_event_second=="Active_WTT_entries")) begin
            xtt_entries_nb = wtt_entries_nb;
          end

        if((multi_bits_event_first=="Active_RTT_entries") || (multi_bits_event_second=="Active_RTT_entries")) begin
            xtt_entries_nb = rtt_entries_nb;
         end
    <%}/*dii*/%>
    <% if (obj.Block == 'dmi') {%>
          int wtt_entries_nb = <%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries%>;
          int rtt_entries_nb = <%=obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries%>;
          if((multi_bits_event_first=="Active_WTT_entries") || (multi_bits_event_second=="Active_WTT_entries")) begin
            xtt_entries_nb = wtt_entries_nb;
          end

        if((multi_bits_event_first=="Active_RTT_entries") || (multi_bits_event_second=="Active_RTT_entries")) begin
            xtt_entries_nb = rtt_entries_nb;
         end
    <%}/*dmi*/%>

    <% if (obj.BlockId.includes("caiu") || obj.BlockId.includes("ncaiu") || (obj.testBench =="io_aiu")  || obj.BlockId.includes("aiu") || obj.Block == 'chi_aiu'){%>
        xtt_entries_nb = <%=obj.AiuInfo[obj.Id].cmpInfo.nOttCtrlEntries%>;
    <%}/*caiu*/%>  
    if (check_is_counting(perf_cnt_id) == 1) begin
         if (pmon_xtt_entries_max > xtt_entries_nb) begin
            `uvm_info(get_full_name(), $sformatf(" Pmon XTT entries value %0d(0x%0x) /= nXttCtrlEntries %0d(0x%0x) for perf counter %0d",pmon_xtt_entries_max,pmon_xtt_entries_max,
            xtt_entries_nb,xtt_entries_nb,perf_cnt_id), UVM_NONE)
            `uvm_error(get_full_name(), $sformatf("XTT entries count is more than XTT_entries Ctrl Entries number "))
        end
        else
        `uvm_info(get_full_name(), $sformatf("Checking Pmon xtt entries max value for perf counter %0d is OK",perf_cnt_id),UVM_NONE)
        <% if (!obj.Block == 'dii') {%>
        if (reg_value.cnt_v > 0) begin
            `uvm_info(get_full_name(), $sformatf(" Final Pmon XTT entries value %0d(0x%0x) /= 0 for perf counter %0d",reg_value.cnt_v,reg_value.cnt_v,perf_cnt_id), UVM_NONE)
            `uvm_error(get_full_name(), $sformatf("Pmon XTT entries final value should be 0"))
        end
        else
        `uvm_info(get_full_name(), $sformatf("Final Pmon xtt entries max value for perf counter %0d is OK (equal to 0)",perf_cnt_id),UVM_NONE)
        <%}/*dii*/%>
    end

endfunction : xtt_entries_event_max_min_check
function void <%=obj.BlockId%>_perf_counters_scoreboard::interleaved_data_event_counter_compare(int perf_cnt_id);

    // Counter queues (CNTVR,CNTSR)
    int sb_fifo_size=perf_counters[perf_cnt_id].size();
    int rg_fifo_size=perf_cnt_ref_value[perf_cnt_id].size();


    if (check_is_counting(perf_cnt_id) == 1) begin
        if (queue_check_dis == 0) begin
            if (sb_fifo_size != rg_fifo_size) begin
                `uvm_error(get_full_name(), $sformatf("mismatch in queue size between scoreboard and reg captured values for : Reg queue size %0d /= reference SB queue size %0d for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d "
                ,rg_fifo_size,sb_fifo_size,perf_cnt_id,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
            end

            else begin
                `uvm_info(get_full_name(), $sformatf("Queues size of reg value and ref sb values are matching so start Checking values for perf counter %0d ",perf_cnt_id),UVM_MEDIUM)
                for (int i=0; i< sb_fifo_size;i++) begin
                    if ((perf_counters[perf_cnt_id][i].cnt_v == perf_cnt_ref_value[perf_cnt_id][i].cnt_v) && (perf_counters[perf_cnt_id][i].cnt_v_str == perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str) ) begin
                        `uvm_info(get_full_name(), $sformatf("Check Perf counter is OK for perf counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",perf_cnt_id,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()),UVM_MEDIUM)
                    end
                    if (perf_counters[perf_cnt_id][i].cnt_v != perf_cnt_ref_value[perf_cnt_id][i].cnt_v) begin
                        `uvm_error(get_full_name(), $sformatf("Error in Count Value : Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v,perf_cnt_id,
                        sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
                    end else begin
                        `uvm_info(get_full_name(), $sformatf("Count value OK Reg value %0d(0x%0x) == SB value %0d(0x%0x) for perf counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_cnt_ref_value[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v,perf_counters[perf_cnt_id][i].cnt_v, perf_cnt_id
                        ,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()),UVM_MEDIUM)
                    end
                    if (perf_counters[perf_cnt_id][i].cnt_v_str != perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str) begin
                        `uvm_error(get_full_name(), $sformatf("Error in Count Saturation Value : Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str,perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str,perf_counters[perf_cnt_id][i].cnt_v_str,perf_counters[perf_cnt_id][i].cnt_v_str,perf_cnt_id
                        ,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
                    end else begin
                        `uvm_info(get_full_name(), $sformatf("Count saturation value OK Reg value %0d(0x%0x) == SB value %0d(0x%0x) for perf counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str,perf_cnt_ref_value[perf_cnt_id][i].cnt_v_str,perf_counters[perf_cnt_id][i].cnt_v_str,perf_counters[perf_cnt_id][i].cnt_v_str,perf_cnt_id
                        ,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()),UVM_MEDIUM)
                    end
                end 
            end
        end
    end
    
    else begin
        if (rg_fifo_size == 0 || ((rg_fifo_size == 1) && (perf_cnt_ref_value[perf_cnt_id][0].cnt_v == 0))) begin
            `uvm_error(get_full_name(), $sformatf("NO event was counted at counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d"
                ,perf_cnt_id,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
        end
    
        else begin
                `uvm_error(get_full_name(), $sformatf("NO event was detected at scoreboard but event was received by RTL for counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d"
                ,perf_cnt_id,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
        end

    end

endfunction : interleaved_data_event_counter_compare

function void <%=obj.BlockId%>_perf_counters_scoreboard::multi_bits_counter_compare(int perf_cnt_id);
    count_value_obj ref_cnt,ref_cnt_tolerance1,ref_cnt_tolerance2,reg_value;
    count_value_fifo ref_cnt_fifo; 
    int j=0;   
    int fifo_size=perf_counters[perf_cnt_id].size();
    int rg_fifo_size=perf_cnt_ref_value[perf_cnt_id].size();
    reg_value= sb_perf_counters_cfg.count_value[perf_cnt_id];

    for (int i=0; i< fifo_size;i++) begin
        ref_cnt_fifo[i]= perf_counters[perf_cnt_id][i];
    end
    <% var list_dropped_event = obj.listEventArr.filter(e => (e.name.match(/dropped/i) || e.name.match(/DtwDbgReq_packets/i))).map(e => `"${e.name}"`)
    if (obj.Block == 'dce'){list_dropped_event = [`"DCE_does_not_have_Dropped_packets_events"`];}%>

    if (sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name()
        inside {<%=list_dropped_event.join(",")%>}
     || sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name()
        inside {<%=list_dropped_event.join(",")%>}) begin
        ref_cnt.cnt_v = sb_stall_if.multi_bits_event_signal[perf_cnt_id][0] + sb_stall_if.multi_bits_event_signal[perf_cnt_id][1];  
        ref_cnt.cnt_v_str = 0;   
        overflow_status[perf_cnt_id] = 0;
        perf_counters[perf_cnt_id].delete();
        perf_counters[perf_cnt_id].push_back(ref_cnt);
    end else begin
        ref_cnt = ref_cnt_fifo.pop_back();
        if(fifo_size >= 2)  ref_cnt_tolerance1 = ref_cnt_fifo.pop_back();
        if(fifo_size >= 3)  ref_cnt_tolerance2 = ref_cnt_fifo.pop_back();
    end
    
    if (check_is_counting(perf_cnt_id) == 1) begin
        if (sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name()
            inside {<%=list_dropped_event.join(",")%>}
         || sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name()
            inside {<%=list_dropped_event.join(",")%>}) begin
                if ((ref_cnt.cnt_v == reg_value.cnt_v) && (ref_cnt.cnt_v_str == reg_value.cnt_v_str) ) begin
                    `uvm_info(get_full_name(), $sformatf("Check Perf counter is OK for perf counter %0d",perf_cnt_id),UVM_MEDIUM)
                end
                if (ref_cnt.cnt_v != reg_value.cnt_v) `uvm_error(get_full_name(), $sformatf("Error in Count Value : Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v,reg_value.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v,perf_cnt_id
                ,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name())) 
                else  `uvm_info(get_full_name(), $sformatf("Count value OK Reg value %0d(0x%0x) == SB value %0d(0x%0x) for perf counter %0d",reg_value.cnt_v,reg_value.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v,perf_cnt_id),UVM_MEDIUM)  

        end
        else begin 
                if ((ref_cnt.cnt_v == reg_value.cnt_v) && (ref_cnt.cnt_v_str == reg_value.cnt_v_str) ) begin
                    `uvm_info(get_full_name(), $sformatf("Check Perf counter is OK for perf counter %0d",perf_cnt_id),UVM_MEDIUM)
                end
                if (ref_cnt.cnt_v != reg_value.cnt_v) begin
                    if ( fifo_size >= 2 ) begin
                        if (ref_cnt_tolerance1.cnt_v != reg_value.cnt_v) begin
                            if ( fifo_size >= 3 ) begin
                                if (ref_cnt_tolerance2.cnt_v != reg_value.cnt_v) begin
                                    `uvm_error(get_full_name(), $sformatf("Error in Count Value with tolerance 2 : Reg value %0d(0x%0x) /= reference SB value with tolerance 2 %0d(0x%0x) /= reference final SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v,reg_value.cnt_v,ref_cnt_tolerance2.cnt_v,ref_cnt_tolerance2.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v,perf_cnt_id,
                                    sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
                                end else `uvm_info(get_full_name(), $sformatf("Count value OK Reg value with tolerance 2 %0d(0x%0x) == SB value %0d(0x%0x)  and final SB value = %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v,reg_value.cnt_v,ref_cnt_tolerance2.cnt_v,ref_cnt_tolerance2.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v,perf_cnt_id,
                                sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()),UVM_MEDIUM)
                            
                            end
                            else `uvm_error(get_full_name(), $sformatf("Error in Count Value with tolerance 1 : Reg value %0d(0x%0x) /= reference SB value with tolerance 1 %0d(0x%0x) /= reference final SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v,reg_value.cnt_v,ref_cnt_tolerance1.cnt_v,ref_cnt_tolerance1.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v,perf_cnt_id,
                            sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
                    end
                    else `uvm_info(get_full_name(), $sformatf("Count value OK Reg value with tolerance 1 %0d(0x%0x) == SB value %0d(0x%0x) and final SB value = %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v,reg_value.cnt_v,ref_cnt_tolerance1.cnt_v,ref_cnt_tolerance1.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v,perf_cnt_id,
                    sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()),UVM_MEDIUM)

                end
                else `uvm_error(get_full_name(), $sformatf("Error in Count Value : Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v,reg_value.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v,perf_cnt_id,
                sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name())) 
            end else begin
                `uvm_info(get_full_name(), $sformatf("Count value OK Reg value %0d(0x%0x) == SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v,reg_value.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v, perf_cnt_id,
                sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()),UVM_MEDIUM)
            end
        end



        if (ref_cnt.cnt_v_str != reg_value.cnt_v_str) begin
            `uvm_error(get_full_name(), $sformatf("Error in Count Saturation Value : Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v_str,reg_value.cnt_v_str,ref_cnt.cnt_v_str,ref_cnt.cnt_v_str,perf_cnt_id,
            sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
        end else begin
            `uvm_info(get_full_name(), $sformatf("Count saturation value OK Reg value %0d(0x%0x) == SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v_str,reg_value.cnt_v_str,ref_cnt.cnt_v_str,ref_cnt.cnt_v_str,perf_cnt_id,
            sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()),UVM_MEDIUM)
        end
        if (sb_perf_counters_cfg.cfg_reg[perf_cnt_id].overflow_status != overflow_status[perf_cnt_id] ) begin
            `uvm_error(get_full_name(), $sformatf("Error in Perf counter overflow status for perf counter %0d", perf_cnt_id))
            `uvm_info(get_full_name(), $sformatf("Overflow Status Reg value (%0x) /= SB value (%0x) for perf counter %0d",sb_perf_counters_cfg.cfg_reg[perf_cnt_id].overflow_status, overflow_status[perf_cnt_id], perf_cnt_id),UVM_NONE)
        end else begin
            `uvm_info(get_full_name(), $sformatf("Check Perf counter overflow status is OK for perf counter %0d",perf_cnt_id),UVM_MEDIUM)
            `uvm_info(get_full_name(), $sformatf("Overflow Status Reg value (%0x) == SB value (%0x) for perf counter %0d",sb_perf_counters_cfg.cfg_reg[perf_cnt_id].overflow_status, overflow_status[perf_cnt_id], perf_cnt_id),UVM_MEDIUM)
        end
    end
    else begin
        if (rg_fifo_size == 0 || (reg_value.cnt_v == 0)) begin
            `uvm_error(get_full_name(), $sformatf("NO event was counted at counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d"
                ,perf_cnt_id,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
        end
    
        else begin
                `uvm_error(get_full_name(), $sformatf("NO event was detected at scoreboard but event was received by RTL for counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d"
                ,perf_cnt_id,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
        end

    end



endfunction : multi_bits_counter_compare

function void <%=obj.BlockId%>_perf_counters_scoreboard::stall_counter_compare(int perf_cnt_id);
    
    count_value_obj ref_cnt,ref_cnt_tolerance1,ref_cnt_tolerance2,reg_value;
    count_value_fifo ref_cnt_fifo; 
    int j=0;   
    int fifo_size=perf_counters[perf_cnt_id].size();
    int cnt_v_error,error_pct ;
    int rg_fifo_size=perf_cnt_ref_value[perf_cnt_id].size();
    reg_value= sb_perf_counters_cfg.count_value[perf_cnt_id];
    

    for (int i=0; i< fifo_size;i++) begin
        ref_cnt_fifo[i]= perf_counters[perf_cnt_id][i];
    end
    
    ref_cnt = ref_cnt_fifo.pop_back();

    
    if (check_is_counting(perf_cnt_id) == 1) begin
        if ((sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first == Div_16_counter || sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second == Div_16_counter) && sb_perf_counters_cfg.cfg_reg[perf_cnt_id].ssr_count != COUNTER_32BIT_SAT) begin
            cnt_v_error =  ref_cnt.cnt_v - reg_value.cnt_v;
            if (cnt_v_error < 0 ) cnt_v_error = - cnt_v_error;
<% if (obj.testBench != "fsys") { %>
            if (cnt_v_error <= 5 )
<% } else { %>
            if (cnt_v_error <= 15 ) // FSYS increase tolerance because one div_16 ref for all the counter values but can have delay in the CSR network when write "enable" counter
<% } %>
            begin
                `uvm_info(get_full_name(), $sformatf("Check Perf counter is OK for Div_16_counter on perf counter %0d",perf_cnt_id),UVM_MEDIUM)
            end
            else `uvm_error(get_full_name(), $sformatf("Error in Count Value for Div_16_counter : Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d",reg_value.cnt_v,reg_value.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v,perf_cnt_id)) 

        end
        else begin 
                if ((ref_cnt.cnt_v == reg_value.cnt_v) && (ref_cnt.cnt_v_str == reg_value.cnt_v_str) ) begin
                    `uvm_info(get_full_name(), $sformatf("Check Perf counter is OK for perf counter %0d",perf_cnt_id),UVM_MEDIUM)
                end
                if (ref_cnt.cnt_v != reg_value.cnt_v) begin
                    cnt_v_error =  (ref_cnt.cnt_v+1) - reg_value.cnt_v;
                    if (cnt_v_error < 0 ) cnt_v_error = - cnt_v_error;
                    if (ref_cnt.cnt_v > 0 ) error_pct = (cnt_v_error*100)/ref_cnt.cnt_v ;
                    else  error_pct = (cnt_v_error*100)/reg_value.cnt_v ;
                    if (error_pct > tolerance_pct <% if (obj.Block == 'dii' || obj.Block == 'dce' || obj.Block == 'dve') {  %>& (cnt_v_error > 2)<% } %>)
                    `uvm_error(get_full_name(), $sformatf("Error in Count Value with tolerance %0d percent : Reg value %0d(0x%0x) /= reference final SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0s",tolerance_pct,reg_value.cnt_v,reg_value.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v,perf_cnt_id,
                    sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
                    else `uvm_info(get_full_name(), $sformatf("Count value OK with tolerance %0d percent :  Reg value %0d(0x%0x) = SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",tolerance_pct,reg_value.cnt_v,reg_value.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v,perf_cnt_id,
                    sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()),UVM_MEDIUM)

                end
            
                else begin
                    `uvm_info(get_full_name(), $sformatf("Count value OK Reg value %0d(0x%0x) == SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v,reg_value.cnt_v,ref_cnt.cnt_v,ref_cnt.cnt_v, perf_cnt_id,
                    sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()),UVM_MEDIUM)
                end
        end


        if (sb_perf_counters_cfg.cfg_reg[perf_cnt_id].ssr_count == COUNTER_32BIT_SAT && sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second == Div_16_counter) begin
            cnt_v_error =  ref_cnt.cnt_v_str - reg_value.cnt_v_str;
            if (cnt_v_error < 0 ) cnt_v_error = - cnt_v_error;
            if (cnt_v_error <= 2 ) begin
                `uvm_info(get_full_name(), $sformatf("Check Perf counter is OK for Div_16_counter on bandwidth calculation on perf counter %0d",perf_cnt_id),UVM_MEDIUM)
            end
            else `uvm_error(get_full_name(), $sformatf("Error in Count Saturation Value : Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v_str,reg_value.cnt_v_str,ref_cnt.cnt_v_str,ref_cnt.cnt_v_str,perf_cnt_id,
            sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))

        end

        else begin
            if (ref_cnt.cnt_v_str != reg_value.cnt_v_str) begin
                `uvm_error(get_full_name(), $sformatf("Error in Count Saturation Value : Reg value %0d(0x%0x) /= reference SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v_str,reg_value.cnt_v_str,ref_cnt.cnt_v_str,ref_cnt.cnt_v_str,perf_cnt_id,
                sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
            end else begin
                `uvm_info(get_full_name(), $sformatf("Count saturation value OK Reg value %0d(0x%0x) == SB value %0d(0x%0x) for perf counter %0d and for configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",reg_value.cnt_v_str,reg_value.cnt_v_str,ref_cnt.cnt_v_str,ref_cnt.cnt_v_str,perf_cnt_id,
                sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()),UVM_MEDIUM)
            end
        end
        if (sb_perf_counters_cfg.cfg_reg[perf_cnt_id].overflow_status != overflow_status[perf_cnt_id] ) begin
            `uvm_error(get_full_name(), $sformatf("Error in Perf counter overflow status for perf counter %0d", perf_cnt_id))
            `uvm_info(get_full_name(), $sformatf("Overflow Status Reg value (%0x) /= SB value (%0x) for perf counter %0d",sb_perf_counters_cfg.cfg_reg[perf_cnt_id].overflow_status, overflow_status[perf_cnt_id], perf_cnt_id),UVM_NONE)
        end else begin
            `uvm_info(get_full_name(), $sformatf("Check Perf counter overflow status is OK for perf counter %0d",perf_cnt_id),UVM_MEDIUM)
            `uvm_info(get_full_name(), $sformatf("Overflow Status Reg value (%0x) == SB value (%0x) for perf counter %0d",sb_perf_counters_cfg.cfg_reg[perf_cnt_id].overflow_status, overflow_status[perf_cnt_id], perf_cnt_id),UVM_MEDIUM)
        end
    end
    else begin
        if (rg_fifo_size == 0 || (reg_value.cnt_v == 0)) begin
            `uvm_error(get_full_name(), $sformatf("NO event was counted at counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d"
                ,perf_cnt_id,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
        end
    
        else begin
                `uvm_error(get_full_name(), $sformatf("NO event was detected at scoreboard but event was received by RTL for counter %0d for this configuration :###### event_first = %s ######  event_second =%s ###### counter_control =%0d"
                ,perf_cnt_id,sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))
        end

    end

endfunction: stall_counter_compare


function void <%=obj.BlockId%>_perf_counters_scoreboard::clear_counter(int perf_cnt_id);

    `uvm_info(get_full_name(), $sformatf("Clear Perf counter %d",perf_cnt_id),UVM_HIGH)

    perf_counters[perf_cnt_id].delete();
    perf_cnt_ref_value[perf_cnt_id].delete();
    counter[perf_cnt_id] = 0 ;
    counter_saved[perf_cnt_id] = 0 ;
    R_LPF[perf_cnt_id] = 0;
    overflow_status[perf_cnt_id] = 0;
    sb_stall_if.div_16_counter_en=1'b0;
    event_trigged[perf_cnt_id][0]=0;
    event_trigged[perf_cnt_id][1]=0;
    reg_lpf_value[perf_cnt_id].delete();
    ref_lpf_value[perf_cnt_id].delete();

endfunction: clear_counter

function void <%=obj.BlockId%>_perf_counters_scoreboard::clear_full_counter();

    `uvm_info(get_full_name(), $sformatf("Clear all Perf counters"),UVM_HIGH)
    for (int perf_counter_id=0; perf_counter_id< <%=obj.DutInfo.nPerfCounters%>;perf_counter_id++) begin
        clear_counter(perf_counter_id);
    end

endfunction: clear_full_counter

task <%=obj.BlockId%>_perf_counters_scoreboard::set_new_config();

    new_cfg = 1'b1;
    repeat(2) @(posedge sb_stall_if.clk); 
    new_cfg = 1'b0;

endtask: set_new_config

task <%=obj.BlockId%>_perf_counters_scoreboard::set_save_counter();

    save_counter = 1'b1;
    repeat(2) @(posedge sb_stall_if.clk); 
    save_counter = 1'b0;

endtask: set_save_counter

function void <%=obj.BlockId%>_perf_counters_scoreboard::print_counter(int perf_cnt_id);

    count_value_obj     cnt_value_t;
    cnt_value_t = perf_counters[perf_cnt_id].pop_back();

    `uvm_info(get_full_name(), $sformatf("Printing perf counter %0d values : Count value = %0d(0x%0h) and Count saturation value = %0d(0x%0h)",
    perf_cnt_id,cnt_value_t.cnt_v, cnt_value_t.cnt_v, cnt_value_t.cnt_v_str, cnt_value_t.cnt_v_str),UVM_LOW) 

endfunction: print_counter

function void <%=obj.BlockId%>_perf_counters_scoreboard::print_full_counter();

    `uvm_info(get_full_name(), $sformatf("Printing all Perf counters values"),UVM_LOW)
    for (int perf_counter_id=0; perf_counter_id< <%=obj.DutInfo.nPerfCounters%>;perf_counter_id++) begin
        print_counter(perf_counter_id);
    end

endfunction: print_full_counter

function bit <%=obj.BlockId%>_perf_counters_scoreboard::check_is_multi_event(int perf_cnt_id);
    int index_first_event[$],index_second_event[$] ;
    
    string multi_bits_event_first,multi_bits_event_second;
    <% var list_multi_event = obj.listEventArr.filter(e => e.type=="data").map(e => `"${e.name}"`)%>
    string multi_bits_event_queue[<%=list_multi_event.length%>]={<%=list_multi_event.join(",")%>};
    multi_bits_event_first = sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name();
    multi_bits_event_second =sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name();

    index_first_event = multi_bits_event_queue.find_first_index(x) with (x == multi_bits_event_first);
    index_second_event = multi_bits_event_queue.find_first_index(x) with (x == multi_bits_event_second);
    //`uvm_info(get_full_name(), $sformatf("check_is_stall_event : index_first_event=%d,index_second_event=%d",index_first_event[0],index_second_event[0]),UVM_LOW)
    if (multi_bits_event_first == <%=`"${obj.listEventArr[0].name}"`%> && multi_bits_event_second == <%=`"${obj.listEventArr[0].name}"`%>) return(0);
    else begin
        if (index_first_event.size() > 0 && index_second_event.size() > 0) return (1);
        else return(0);
    end
endfunction: check_is_multi_event

task <%=obj.BlockId%>_perf_counters_scoreboard::set_cnt_reg_value_q(int id);
    
    count_value_obj ref_cnt;
    bit master_count_enable = 0;
    bit local_count_enable = 0;
    forever begin
      
        
        @(sb_stall_if.cnt_reg_capture[id].cnt_v);
        //Pmon 3.4 feature
        local_count_enable = sb_perf_counters_cfg.main_cntr_reg.local_count_enable;
<% if ((obj.testBench == "fsys") || !(obj.Block == 'dve')) { %>
        master_count_enable = sb_perf_counters_cfg.main_cntr_reg.master_count_enable && sb_stall_if.master_cnt_enable; //pilot by DVE
<% } %>
        if (((sb_perf_counters_cfg.cfg_reg[id].count_enable == 1 || (local_count_enable == 1) || (master_count_enable == 1))) 
        && (check_is_multi_event(id) == 1)) begin
            ref_cnt.cnt_v = sb_stall_if.cnt_reg_capture[id].cnt_v;
            ref_cnt.cnt_v_str = sb_stall_if.cnt_reg_capture[id].cnt_v_str;
            perf_cnt_ref_value[id].push_back(ref_cnt);
              
        end
    end

endtask: set_cnt_reg_value_q

task <%=obj.BlockId%>_perf_counters_scoreboard::set_lpf_value(int id);
    
    bit [31:0] reg_cnt_v,reg_cnt_v_str,ref_cnt_v_str;
    bit master_count_enable = 0;
    bit local_count_enable = 0;
    forever begin
      
        
        @(posedge sb_stall_if.clk);
        //Pmon 3.4 feature
        local_count_enable = sb_perf_counters_cfg.main_cntr_reg.local_count_enable;
<% if ((obj.testBench == "fsys") || !(obj.Block == 'dve')) { %>
        master_count_enable = sb_perf_counters_cfg.main_cntr_reg.master_count_enable && sb_stall_if.master_cnt_enable; //pilot by DVE
<% } %>
        if (((sb_perf_counters_cfg.cfg_reg[id].count_enable == 1) || (local_count_enable == 1) || (master_count_enable == 1)) 
        && (check_is_multi_event(id) == 1)) begin
            reg_cnt_v = sb_stall_if.cnt_reg_capture[id].cnt_v;
            reg_cnt_v_str = sb_stall_if.cnt_reg_capture[id].cnt_v_str;
            ref_cnt_v_str = store_lpf_value(reg_cnt_v,id);
            reg_lpf_value[id].push_back(reg_cnt_v_str);
            ref_lpf_value[id].push_back(ref_cnt_v_str);
              
        end
    end

endtask: set_lpf_value




function bit <%=obj.BlockId%>_perf_counters_scoreboard::check_is_counting(int perf_cnt_id);
    if(no_event_check_dis == 0) begin
        //#Check.DII.Pmon.v3.2.NoEvent
        if(((sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first == 0) && (sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second == 0 )) || (sb_perf_counters_cfg.perfmon_no_full_rand == 0) ) return(1);
        else begin
            if ((event_trigged[perf_cnt_id][0] == 0) && (event_trigged[perf_cnt_id][1] == 0 )) begin
                return(0);
            end

            else return(1);
        end
    end
    else begin
        return(1);
    end
endfunction : check_is_counting

function bit <%=obj.BlockId%>_perf_counters_scoreboard::check_is_xtt_entries_event(int perf_cnt_id);
    int index_first_event[$],index_second_event[$] ;
    
    string multi_bits_event_first,multi_bits_event_second;
    <% var list_multi_event = obj.listEventArr.filter(e => e.name.match(/tt_entries/i)).map(e => `"${e.name}"`)%>
    string multi_bits_event_queue[<%=list_multi_event.length%>]={<%=list_multi_event.join(",")%>};
    multi_bits_event_first = sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name();
    multi_bits_event_second =sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name();

    index_first_event = multi_bits_event_queue.find_first_index(x) with (x == multi_bits_event_first);
    index_second_event = multi_bits_event_queue.find_first_index(x) with (x == multi_bits_event_second);
    //`uvm_info(get_full_name(), $sformatf("check_is_stall_event : index_first_event=%d,index_second_event=%d",index_first_event[0],index_second_event[0]),UVM_LOW)
    if (multi_bits_event_first == <%=`"${obj.listEventArr[0].name}"`%> && multi_bits_event_second == <%=`"${obj.listEventArr[0].name}"`%>) return(0);
    else begin
        if (index_first_event.size() > 0 || index_second_event.size() > 0) return (1);
        else return(0);
    end
endfunction: check_is_xtt_entries_event

function bit <%=obj.BlockId%>_perf_counters_scoreboard::check_is_interleaved_data_event(int perf_cnt_id);
    int index_first_event[$],index_second_event[$] ;
    
    string multi_bits_event_first,multi_bits_event_second;
    <% var list_multi_event = obj.listEventArr.filter(e => e.name.match(/interleaved_data/i)).map(e => `"${e.name}"`)%>
    string multi_bits_event_queue[<%=(list_multi_event.length)?list_multi_event.length:1%>]={<%=(list_multi_event.length)?list_multi_event.join(","):'"notused"'%>};  // CLU tmp fix
    multi_bits_event_first = sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name();
    multi_bits_event_second =sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name();

    index_first_event = multi_bits_event_queue.find_first_index(x) with (x == multi_bits_event_first);
    index_second_event = multi_bits_event_queue.find_first_index(x) with (x == multi_bits_event_second);
    //`uvm_info(get_full_name(), $sformatf("check_is_stall_event : index_first_event=%d,index_second_event=%d",index_first_event[0],index_second_event[0]),UVM_LOW)
    if (multi_bits_event_first == <%=`"${obj.listEventArr[0].name}"`%> && multi_bits_event_second == <%=`"${obj.listEventArr[0].name}"`%>) return(0);
    else begin
        if (index_first_event.size() > 0 || index_second_event.size() > 0) return (1);
        else return(0);
    end
endfunction: check_is_interleaved_data_event



function void <%=obj.BlockId%>_perf_counters_scoreboard::cross_check_queues(count_value_fifo fifo1, count_value_fifo fifo2 , ref int communs_items_idx[$]);
    int fifo1_size = fifo1.size();
    int fifo2_size = fifo2.size();
    int k = 0;
    bit find ;
    if (fifo1_size == 0 || fifo2_size == 0) begin
        communs_items_idx = {};
    end

    foreach(fifo1[id]) begin
        find = 0;
        while ((find == 0) && k < fifo2_size) begin
            if (fifo1[id].cnt_v == fifo2[k].cnt_v) begin
                find = 1;
                communs_items_idx.push_back(k);
                //`uvm_info(get_full_name(), $sformatf("item match between two queues and item_idx = %0d",
                //k),UVM_LOW) 
          

            end
            k++;
        end

    end

endfunction: cross_check_queues


function void <%=obj.BlockId%>_perf_counters_scoreboard::xtt_entries_event_counter_compare_with_tolerance(int perf_cnt_id);

        int communs_items_idx[$];
        int error_pct;
        cross_check_queues(perf_counters[perf_cnt_id],perf_cnt_ref_value[perf_cnt_id],communs_items_idx);
        error_pct = ((perf_counters[perf_cnt_id].size() - communs_items_idx.size())*100)/perf_counters[perf_cnt_id].size();
        if (error_pct <= xtt_entries_tolerance_pct)
        `uvm_info(get_full_name(), $sformatf("check OK with tolerance %0d percent : error percentage = %0d for  perf counter %0d : commun items numbers = %0d #### rtl items number = %0d #### sb items number = %0d :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",xtt_entries_tolerance_pct,error_pct,perf_cnt_id,
        communs_items_idx.size(),perf_cnt_ref_value[perf_cnt_id].size(),perf_counters[perf_cnt_id].size(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()),UVM_NONE)
        else   `uvm_error(get_full_name(), $sformatf("Error in Count Value with tolerance %0d percent : error percentage = %0d for  perf counter %0d : commun items numbers = %0d #### rtl items number = %0d #### sb items number = %0d :###### event_first = %s ######  event_second =%s ###### counter_control =%0d",xtt_entries_tolerance_pct,error_pct,perf_cnt_id,
        communs_items_idx.size(),perf_cnt_ref_value[perf_cnt_id].size(),perf_counters[perf_cnt_id].size(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_first.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_event_second.name(),sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control.name()))

  

endfunction: xtt_entries_event_counter_compare_with_tolerance

function int <%=obj.BlockId%>_perf_counters_scoreboard::get_max(count_value_fifo q);
int q_size = q.size();
int max = 0;
for (int i=0;i<q_size;i++) begin
    if(q[i].cnt_v > max) max= q[i].cnt_v;

end

return(max);
endfunction: get_max
//Pmon 3.4 latency
<% if (obj.Block == 'dii' || (obj.testBench =="io_aiu")  || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>
task <%=obj.BlockId%>_perf_counters_scoreboard::latency_count(int perf_cnt_id);

e_counter_control   counter_control;
count_value_obj     cnt_value_t;
bit                 count_value_saved;
bit not_event_result;
int event0,event1;
bit local_count_enable = 0 ;
bit master_count_enable = 0 ; // only availble on dve;

cnt_value_t.cnt_v = 0;
cnt_value_t.cnt_v_str = 0;

forever begin


    event0 = 2*perf_cnt_id;
    event1 = 2*perf_cnt_id + 1 ;

    @(negedge sb_stall_if.clk);
    //Pmon 3.4 feature
    local_count_enable = sb_perf_counters_cfg.main_cntr_reg.local_count_enable;
<% if ((obj.testBench == "fsys") || !(obj.Block == 'dve')) { %>
    master_count_enable = sb_perf_counters_cfg.main_cntr_reg.master_count_enable && sb_stall_if.master_cnt_enable; //pilot by DVE
<% } %>
    
    counter_control = sb_perf_counters_cfg.cfg_reg[perf_cnt_id].counter_control;
    
   
   
    if (pmon_latency_test == 1) begin
        //#Check.DII.Pmon.v3.4.LocalEnableDisable 
        //#Check.CHIAIU.Pmon.v3.4.LocalEnableDisable

        if ((sb_perf_counters_cfg.cfg_reg[perf_cnt_id].count_enable  == 1) || (local_count_enable  == 1) || (master_count_enable == 1)) begin
         
            case (counter_control)

   
            //#Check.DII.Pmon.v3.4.XCNT32BIT 
            //#Check.CHIAIU.Pmon.v3.4.XCNT32BIT
            //#Check.IOAIU.Pmon.v3.4.XCNT32BIT
            COUNTER_32BIT_C : begin 
                if (sb_stall_if.latency_bins[event0]) begin
                    counter[perf_cnt_id][31:0]++;
                    count_value_saved = 0;
                end
       
                if (sb_stall_if.latency_bins[event1]) begin
                    counter[perf_cnt_id][63:32]++;
                    count_value_saved = 0;
                end
                not_event_result = !(sb_stall_if.latency_bins[event0] || sb_stall_if.latency_bins[event1]);

            end
            default : `uvm_fatal(get_full_name(), $sformatf("Counter control = %0d is selected : latency counter should be selected with COUNTER_32BIT_C counter control",counter_control))
            endcase


                //No events may be asserted ==> save counter value
            if ( not_event_result && !count_value_saved) begin
                store_counter_value(counter[perf_cnt_id],perf_cnt_id);
                count_value_saved = 1;
            end
        end
        if (((disable_sb ==1) || (save_counter == 1)) && !count_value_saved) begin
            store_counter_value(counter[perf_cnt_id],perf_cnt_id);
            count_value_saved = 1;
        end
    end
end
endtask: latency_count

function void <%=obj.BlockId%>_perf_counters_scoreboard::latency_counter_compare(int perf_cnt_id);
    
    count_value_obj ref_cnt,reg_value;
    count_value_fifo ref_cnt_fifo; 
    int j=0;   
    int fifo_size=perf_counters[perf_cnt_id].size();
    int rg_fifo_size=perf_cnt_ref_value[perf_cnt_id].size();
    reg_value= sb_perf_counters_cfg.count_value[perf_cnt_id];
    

    for (int i=0; i< fifo_size;i++) begin
        ref_cnt_fifo[i]= perf_counters[perf_cnt_id][i];
    end
    
    ref_cnt = ref_cnt_fifo.pop_back();

    
  
    if ((ref_cnt.cnt_v == reg_value.cnt_v)) begin
         `uvm_info(get_full_name(), $sformatf("Check latency value for CNTVR : on Perf counter is OK for perf counter %0d",perf_cnt_id),UVM_MEDIUM)
    end
    else begin
 
        `uvm_error(get_full_name(), $sformatf("Mismatch Reg value %0d(0x%0x) /= reference final SB value %0d(0x%0x) for perf counter %0d and for Latency configuration :###### Latency type = %s ######  latency scale = %0d ###### latency bins offset =%0d",reg_value.cnt_v,reg_value.cnt_v, ref_cnt.cnt_v,ref_cnt.cnt_v,perf_cnt_id,sb_perf_counters_cfg.lct_reg.lct_type.name(),int'(2**(sb_perf_counters_cfg.lct_reg.lct_pre_scale+1)),sb_perf_counters_cfg.lct_reg.lct_bin_offset))
                  
    end

    if (ref_cnt.cnt_v_str == reg_value.cnt_v_str) begin
        `uvm_info(get_full_name(), $sformatf("Check latency value for CNTVR : on Perf counter is OK for perf counter %0d",perf_cnt_id),UVM_MEDIUM)
    end else begin
        `uvm_error(get_full_name(), $sformatf("Mismatch Reg value %0d(0x%0x) /= reference final SB value %0d(0x%0x) for perf counter %0d and for Latency configuration :###### Latency type = %s ######  latency scale = %0d ###### latency bins offset =%0d",reg_value.cnt_v_str,reg_value.cnt_v_str,ref_cnt.cnt_v_str,ref_cnt.cnt_v_str,perf_cnt_id,sb_perf_counters_cfg.lct_reg.lct_type.name(),int'(2**(sb_perf_counters_cfg.lct_reg.lct_pre_scale+1)),sb_perf_counters_cfg.lct_reg.lct_bin_offset))

    end
       

endfunction: latency_counter_compare

<% } %>          
