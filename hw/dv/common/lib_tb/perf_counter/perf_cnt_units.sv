<%
// some list checkers
// checK if empty
if (obj.listEventArr.length==0) { throw new Error("none perf counter event find !!!");
}

//check  the index number
obj.listEventArr.forEach( function(event,idx) { 
  if (event.evt_idx != idx) { throw new Error(`!!!Perf counter list event checker name:${event.name}!!! evt_idx: ${event.evt_idx} != index of the array: ${idx} Please check your list of Event!!!`);}
})
%>
`include "uvm_macros.svh"
import <%=obj.BlockId%>_perf_cnt_unit_defines::*;
<%
var blockname = obj.Block;
if(obj.Block == "io_aiu") {blockname = "ioaiu";}
if(obj.Block == "chi_aiu") {blockname = "chiaiu";}
%>
<%
if (obj.Block == 'dii') {
    xUser = obj.DiiInfo[obj.Id].interfaces.axiInt.params.wAwUser && obj.DiiInfo[obj.Id].interfaces.axiInt.params.wArUser;

}

if (obj.Block == 'dmi') {
    xUser = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wAwUser && obj.DmiInfo[obj.Id].interfaces.axiInt.params.wArUser;

}

if (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI")){
    xUser = obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC;
} 

if ((obj.testBench =="io_aiu")){
  if(obj.interfaces.axiInt.length > 1) {
  xUser = obj.interfaces.axiInt[0].params.wAwUser;
  } else {
  xUser = obj.interfaces.axiInt.params.wAwUser;
  }
}
///////////////////////////////////////////
%>
class <%=obj.BlockId%>_perf_cnt_units extends uvm_object;

    `uvm_object_param_utils(<%=obj.BlockId%>_perf_cnt_units)

    string constraints_arg;
    int    constraints_arg2;

    int    bw_filter_val_random_funit_id[];
    int    bw_filter_val_random_user_bits[];

    string constraints_str[];

    rand  e_count_event          count_event_first       []; 
    rand  e_count_event          count_event_second      []; 
    rand  e_minimum_stall_period minimum_stall_period    []; 
    randc e_filter_select        filter_select           []; 
    rand  e_ssr_count            ssr_count               []; 
    rand  e_counter_control      counter_control         []; 
    rand  bit                    interrupt_enable        []; 
    rand  e_count_event          count_event_evt	 []; 
    rand  bit[31:0]              cnt_v		         []; 
    //    bit                    count_clear             []; 
    //    bit                    count_enable            []; 
    //    bit                    overflow_status         []; 
          bit                    loop_array              [4]; // Use temporary to constraint randomization while waiting for desing //ToBeDeleted

          bit force_count_event_first       [<%=obj.MaxnPerfCounters%>]; 
          bit force_count_event_second      [<%=obj.MaxnPerfCounters%>]; 
          bit force_minimum_stall_period    [<%=obj.MaxnPerfCounters%>]; 
          bit force_filter_select           [<%=obj.MaxnPerfCounters%>]; 
          bit force_ssr_count               [<%=obj.MaxnPerfCounters%>]; 
          bit force_counter_control         [<%=obj.MaxnPerfCounters%>]; 
          bit force_interrupt_enable        [<%=obj.MaxnPerfCounters%>]; 
          bit force_count_enable            [<%=obj.MaxnPerfCounters%>]; 
          bit force_master_count_enable = 1;  //  by default legacy behavior
          e_count_event          forced_count_event_first       [<%=obj.MaxnPerfCounters%>]; 
          e_count_event          forced_count_event_second      [<%=obj.MaxnPerfCounters%>]; 
          e_minimum_stall_period forced_minimum_stall_period    [<%=obj.MaxnPerfCounters%>]; 
          e_filter_select        forced_filter_select           [<%=obj.MaxnPerfCounters%>]; 
          e_ssr_count            forced_ssr_count               [<%=obj.MaxnPerfCounters%>]; 
          e_counter_control      forced_counter_control         [<%=obj.MaxnPerfCounters%>]; 
          bit                    forced_count_enable            [<%=obj.MaxnPerfCounters%>]; 
          bit                    forced_interrupt_enable        [<%=obj.MaxnPerfCounters%>];
      
    <%=((obj.testBench == "fsys") || (obj.testBench == "emu"))?"":"static"%> <%=obj.BlockId%>_perf_cnt_units perf_counters;
    st_evt_xCNTVR   cfg_xcntvr_reg[];   // Array of Counter Value Register
    st_cntcr_reg    cfg_reg[];   // Array of Counter Control Register
     //Pmon 3.4 feature
    <% if (obj.Block == 'dii' ||  (obj.testBench =="io_aiu") || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %> 
    ///// BW counter ///////////////////////////////////
    int xuser = <%=xUser%>;
    st_bcntfr_reg   bw_filter_reg[];   // Array of BW Counter Filter Register
    st_bcntmr_reg   bw_mask_reg[];   // Array of BW Counter mask Register
    rand e_bw_filter_value bw_filter_value []; 
    rand e_bw_filter_select bw_filter_select [];
    rand e_bw_filter_mask   bw_filter_mask[];
    
    bit force_filter_enable            []; 
    bit force_bw_filter_select         [];
    e_bw_filter_select forced_bw_filter_select        [];
    bit force_bw_filter_value         [];
    e_bw_filter_value forced_bw_filter_value        [];
    
    bit force_bw_filter_mask         [];
    e_bw_filter_mask forced_bw_filter_mask        [];

    bit pmon_bw_test=0;
    /////////////////////////////////////////////////////////////////
    /// Latency counter //////////////////////////////////////////
    st_lcntcr_reg lct_reg;
    bit force_latency_count_enable = 0;
    rand e_latency_pre_scale     lct_pre_scale ;
    rand e_latency_type          lct_type ;
    rand e_latency_bin_offset    lct_bin_offset;

    bit force_lct_pre_scale;
    e_latency_pre_scale     forced_lct_pre_scale ;
    bit force_lct_type;
    e_latency_type          forced_lct_type ;
    bit force_lct_bin_offset;
    e_latency_bin_offset    forced_lct_bin_offset;


    bit pmon_latency_test = 0 ;
    ////////////////////////////////////////////////////////////////////
    <% } %> 
     //Pmon 3.4 feature
    st_xmcntcr_reg  main_cntr_reg;
    count_value_obj count_value[];
    bit 	    perfmon_no_full_rand = 0;
    bit         perfmon_32bit_mode   = 0;
    bit         main_count_enable    = 0;
    bit         perfmon_local_count_enable = 0;
    bit         perfmon_local_count_clear = 0;
    extern function void parse_str(output string out [], input byte separator1, byte separator2, string in);
    extern function void parse_args();
    extern function bit  check_is_capture_dropped_packets();
  
`ifndef FSYS_COVER_ON
`ifndef IOAIU_SUBSYS_COVER_ON
    // coverage instance
<% if (obj.DutInfo.nPerfCounters>0) { %>
    cov_perf_cnt m_cov_perf_cnt[<%=obj.DutInfo.nPerfCounters%>];
<% }else{ %>
    cov_perf_cnt m_cov_perf_cnt[4];
<% } %>
<% if ((obj.testBench =="io_aiu")) {  %>  
<% if (obj.DutInfo.nPerfCounters>0) { %>
    cov_perf_cnt_evt_xCNTVR m_cov_perf_cnt_evt_xCNTVR[<%=obj.DutInfo.nPerfCounters%>];
<% }else{ %>
    cov_perf_cnt_evt_xCNTVR m_cov_perf_cnt_evt_xCNTVR[4];
<% } %>
<% } %>
     //Pmon 3.4 feature
<% if (obj.Block == 'dii' || (obj.testBench =="io_aiu") || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  
    // BW coverage instance
<% if (obj.DutInfo.nPerfCounters>0) { %>
    cov_bw_cnt m_cov_bw_cnt[<%=obj.DutInfo.nPerfCounters%>];
<% }else{ %>
    cov_bw_cnt m_cov_bw_cnt[4];
<% } %>
    // LCT coverage instance
    cov_lct_cnt  m_cov_lct_cnt;
<% }%>
    cov_main_cnt m_cov_main_cnt;
`endif // IOAIU_SUBSYS_COVER_ON
`endif // FSYS_COVER_ON

    // Consructor 
    function new(string name = "perf_counters");
        super.new(name);
        bw_filter_val_random_funit_id  = new [<%=obj.DutInfo.nPerfCounters%>];
        bw_filter_val_random_user_bits = new [<%=obj.DutInfo.nPerfCounters%>];
        count_event_first       = new [<%=obj.DutInfo.nPerfCounters%>];
        count_event_second      = new [<%=obj.DutInfo.nPerfCounters%>];
        minimum_stall_period    = new [<%=obj.DutInfo.nPerfCounters%>];
        filter_select           = new [<%=obj.DutInfo.nPerfCounters%>];
        ssr_count               = new [<%=obj.DutInfo.nPerfCounters%>];
        counter_control         = new [<%=obj.DutInfo.nPerfCounters%>];
        interrupt_enable        = new [<%=obj.DutInfo.nPerfCounters%>];
        count_event_evt         = new [<%=obj.DutInfo.nPerfCounters%>];
        cfg_xcntvr_reg		= new [<%=obj.DutInfo.nPerfCounters%>];
        cnt_v                   = new [<%=obj.DutInfo.nPerfCounters%>];
      //  count_clear             = new [<%=obj.DutInfo.nPerfCounters%>];
      //  count_enable            = new [<%=obj.DutInfo.nPerfCounters%>];
      //  overflow_status         = new [<%=obj.DutInfo.nPerfCounters%>];

        cfg_reg = new [<%=obj.DutInfo.nPerfCounters%>];
<% if (obj.Block == 'dii' ||  (obj.testBench =="io_aiu") || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %> 
        bw_filter_reg= new [<%=obj.DutInfo.nPerfCounters%>];   // Array of BW Counter Filter Register
        bw_mask_reg= new [<%=obj.DutInfo.nPerfCounters%>];   // Array of BW Counter mask Register
        bw_filter_value  = new   [<%=obj.DutInfo.nPerfCounters%>]; 
        bw_filter_select= new   [<%=obj.DutInfo.nPerfCounters%>];
        bw_filter_mask  = new   [<%=obj.DutInfo.nPerfCounters%>];
        force_filter_enable                = new  [<%=obj.DutInfo.nPerfCounters%>]; 
        force_bw_filter_select             = new  [<%=obj.DutInfo.nPerfCounters%>];
        forced_bw_filter_select            = new  [<%=obj.DutInfo.nPerfCounters%>];
        force_bw_filter_value              = new  [<%=obj.DutInfo.nPerfCounters%>];
        forced_bw_filter_value             = new  [<%=obj.DutInfo.nPerfCounters%>];
        force_bw_filter_mask               = new  [<%=obj.DutInfo.nPerfCounters%>];
        forced_bw_filter_mask              = new  [<%=obj.DutInfo.nPerfCounters%>];
<%}%>
        count_value = new[<%=obj.DutInfo.nPerfCounters%>];
`ifndef FSYS_COVER_ON
`ifndef IOAIU_SUBSYS_COVER_ON
        for(int i=0;i<<%=obj.DutInfo.nPerfCounters%> ;i++) begin
            m_cov_perf_cnt[i] = new(cfg_reg[i]);
             //Pmon 3.4 feature
            <% if (obj.Block == 'dii' ||  (obj.testBench =="io_aiu") || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  

            m_cov_bw_cnt[i] = new(bw_filter_reg[i]);

            <% }  %>  
        end
<% if ((obj.testBench =="io_aiu")) {%>  
        for(int i=0;i<<%=obj.DutInfo.nPerfCounters%> ;i++) begin
            m_cov_perf_cnt_evt_xCNTVR[i] = new(cfg_xcntvr_reg[i]);
             //Pmon 3.4 feature
            <% if (obj.Block == 'dii' ||  (obj.testBench =="io_aiu") || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  
            m_cov_bw_cnt[i] = new(bw_filter_reg[i]);
            <% }  %>  
        end
<%}%>  
         //Pmon 3.4 feature
<% if (obj.Block == 'dii' ||  (obj.testBench =="io_aiu")  || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  
            m_cov_lct_cnt = new(lct_reg);
<%}%>
            m_cov_main_cnt = new(main_cntr_reg);
`endif // IOAIU_SUBSYS_COVER_ON
`endif // FSYS_COVER_ON
    endfunction: new

  // Make it static,
  // so user can use it before class is constructed
  // To create instance of this class first time when this it is not create
    <%=((obj.testBench == "fsys") || (obj.testBench == "emu"))?"":"static"%> function <%=obj.BlockId%>_perf_cnt_units get_instance();
        if (perf_counters == null) begin
          $display("Object perf_counters is null, so creating new object");
          perf_counters = new("_<%=obj.BlockId%>_perf_counters");
        end
        return perf_counters;
    endfunction : get_instance

     // Debug
    function void pre_randomize();
        // By default all counters are enabled
        foreach(force_count_enable[i]) force_count_enable[i] = '1;
        //Pmon 3.4 feature
        <% if (obj.Block == 'dii' || (obj.testBench =="io_aiu")  || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  
        // By default all Bandwidth filter counters are disabled
        foreach(force_count_enable[i]) force_filter_enable[i] = '0;
        <%}%> 
        
        //if ($test$plusargs("perfmon_directed_rand")) begin
            //Always parse cmd line 
            parse_args(); // Will override regs value according to cmdline args
        //end
    endfunction: pre_randomize

    function void post_randomize();
        set_cfg_regs();
        //Pmon 3.4 feature
        <% if (obj.Block == 'dii' ||  (obj.testBench =="io_aiu")  || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %> 
        //#Stimulus.DII.Pmon.v3.4.BwFilterFixed 
        //#Stimulus.CHIAIU.Pmon.v3.4.BwFilterFixed 
        //#Stimulus.IOAIU.Pmon.v3.4.BwFilterFixed 
        //#Stimulus.DMI.Pmon.v3.4.BwFilterFixed 
        //#Stimulus.DII.Pmon.v3.4.BwFilterRand
        //#Stimulus.CHIAIU.Pmon.v3.4.BwFilterRand
        //#Stimulus.IOAIU.Pmon.v3.4.BwFilterRand
        //#Stimulus.DMI.Pmon.v3.4.BwFilterRand
        set_bw_cfg_regs(); 
        //#Stimulus.DII.Pmon.v3.4.LatencyFixed 
        //#Stimulus.CHIAIU.Pmon.v3.4.LatencyFixed 
        //#Stimulus.IOAIU.Pmon.v3.4.LatencyFixed 
        //#Stimulus.DMI.Pmon.v3.4.LatencyFixed
        //#Stimulus.DII.Pmon.v3.4.LatencyRand
        //#Stimulus.CHIAIU.Pmon.v3.4.LatencyRand
        //#Stimulus.IOAIU.Pmon.v3.4.LatencyRand
        //#Stimulus.DMI.Pmon.v3.4.LatencyRand
        set_lct_cfg_regs(); 
        <%}%> 
        // CHECK that cfg is OK

        `uvm_info("perf_counter_units",$sformatf("Sample cfg_reg for functionnal coverage"), UVM_MEDIUM )
`ifndef FSYS_COVER_ON
`ifndef IOAIU_SUBSYS_COVER_ON
        sample_for_counters();
`endif
`endif
        endfunction: post_randomize

    extern function void print_cfgs(int id);
    extern function void set_cfg_regs();
`ifndef FSYS_COVER_ON
`ifndef IOAIU_SUBSYS_COVER_ON
    extern function void sample_for_counters();
`endif
`endif
    //Pmon 3.4 feature
    <% if (obj.Block == 'dii'  || (obj.testBench =="io_aiu")  || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %> 
    extern function void set_bw_cfg_regs();
    extern function void set_lct_cfg_regs();
    <%}%> 
    constraint c_user_defined_cfg{
        foreach(count_event_first[i]) {
            if(force_count_event_first[i]== 1)     { count_event_first[i] == forced_count_event_first[i];}
            if(force_count_event_second[i]== 1)    { count_event_second[i] == forced_count_event_second[i];}
            if(force_minimum_stall_period [i]== 1) { minimum_stall_period[i] == forced_minimum_stall_period[i];}
            if(force_filter_select[i]== 1)         { filter_select[i] == forced_filter_select[i];}
            if(force_ssr_count[i]== 1)             { ssr_count[i] == forced_ssr_count[i];}
            if(force_counter_control[i]== 1)       { counter_control[i] == forced_counter_control[i];}
            if(force_interrupt_enable[i]== 1)      { interrupt_enable[i] == forced_interrupt_enable[i];}
        }
    }


     constraint c_count_event_reserved{ // list all reserved
        <%=
        ["first","second"].map(litteral_nbr => 
`        foreach(count_event_${litteral_nbr}[i]) {
             !(count_event_${litteral_nbr}[i] inside {
                  ${obj.listEventArr.filter(e => e.name.match(/reserve/i)).map(e => e.name).join(',')}
            }); 
        }`).join('\n')%>

        <% if(obj.useCache) { %>
        // Proxy performance events Reserved
        foreach(count_event_first[i]) {
            ! {count_event_first[i] inside {[<%=obj.listEventArr.length%>:63]}}; 
        }
        foreach(count_event_second[i]) {
            ! {count_event_second[i] inside {[<%=obj.listEventArr.length%>:63]}};
        } 
        <% } %>
    }
    constraint c_count_event{
        <% if ((obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %> 

        if(pmon_bw_test) {
            foreach (count_event_first[i]){
                count_event_first[i]   inside {<%=obj.listEventArr.filter(e => e.type == 'bw').map(e => e.name).join(',')%>};
            }   
            foreach (count_event_second[i]){
                count_event_second[i]   inside {<%=obj.listEventArr.filter(e => e.name.match(/div_/i)).map(e => e.name).join(',')%>};
            }   

        } else <% } %>
        if (perfmon_no_full_rand) { 
            foreach (count_event_second[i]){
            
                if (count_event_first[i]   inside {<%=obj.listEventStallName.map(item => `${item}`).join(",")%>}) {
                    if(force_count_event_second[i]!= 1) {count_event_second[i]   inside {<%=obj.listEventStallName.map(item => `${item}`).join(",")%>};}
                }
                if (!(count_event_first[i]  inside {<%=obj.listEventStallName.map(item => `${item}`).join(",")%>})) {
                    if(force_count_event_second[i]!= 1) {!(count_event_second[i] inside {<%=obj.listEventStallName.filter(item => item != obj.listEventArr[0].name).map(item => `${item}`).join(",")%>});}
                }
            }
            foreach (count_event_first[i]){
                if(counter_control[i] == AND_C  || counter_control[i] == XOR_C )
                {
                    if(force_count_event_first[i] != 1) count_event_first[i]  inside {<%=obj.listEventStallName.map(item => `${item}`).join(",")%>};
                    if(force_count_event_second[i]!= 1) count_event_second[i] inside {<%=obj.listEventStallName.map(item => `${item}`).join(",")%>};
                }
                if(counter_control[i] == STATIC_C )
                {
                    if(force_count_event_first[i]!= 1) count_event_first[i]   inside {${obj.listEventArr.filter(e => (e.width > 1 || e.name == obj.listEventArr[0].name)).map(e => e.name).join(',')}};
                    if(force_count_event_second[i]!= 1) count_event_second[i]   inside {${obj.listEventArr.filter(e => (e.width > 1 || e.name == obj.listEventArr[0].name)).map(e => e.name).join(',')}};
                } 
            }
        } else {
            foreach (count_event_first[i]){
                count_event_first[i]   inside {<%=obj.listEventArr.filter(e => e.randomizable == 1).map(e => e.name).join(',')%>};
            }
            
            foreach (count_event_second[i]){
                count_event_second[i]   inside {<%=obj.listEventArr.filter(e => e.randomizable == 1).map(e => e.name).join(',')%>};
            }   
        }
    }

    constraint c_ssr_count {
        if (!perfmon_no_full_rand) {
            foreach (ssr_count[i]){
                ssr_count[i] inside {CLEAR,CAPTURE};
            }
        
        }
        if (!perfmon_32bit_mode) {
            foreach (ssr_count[i]){
                !(ssr_count[i] inside {COUNTER_32BIT_SAT});  

            }  
        }

        <% if((obj.testBench != 'chi_aiu') && (obj.testBench != 'io_aiu')) { %>
        foreach (ssr_count[i]){
            !(ssr_count[i] inside {MAX_SATURATION}); 

        }  
        <% } %>

    }

    constraint c_counter_control{
        if (perfmon_no_full_rand) {
            foreach (counter_control[i]){
                if(ssr_count[i] inside {LPF,MAX_SATURATION})
                {
                    counter_control[i] inside {STATIC_C}; 
                } else if ( ssr_count[i] != COUNTER_32BIT_SAT) {

                    !(counter_control[i] inside {COUNTER_32BIT_C});
                }
                
            }   

        } else {

            foreach (counter_control[i]){

                    counter_control[i] inside {AND_C,NORMAL_C,XOR_C}; 
                
            }

        } 
    
    }

    constraint c_counter_control_reserved{
        foreach (counter_control[i]){
            !(counter_control[i] inside {'b101,'b110,'b111}); // Reserved 
        }
    }

    constraint c_minimum_stall_period{
        foreach (minimum_stall_period[i]){
            if (    !(count_event_first[i] inside {<%=obj.listEventStallName.map(item => `${item}`).join(",")%>})
                ||  !(count_event_second[i] inside {<%=obj.listEventStallName.map(item => `${item}`).join(",")%>}))   
                {minimum_stall_period[i] inside {NB_CYCLE_1};}    
        }
    }
    
    constraint c_perfmon_constraint_order{
        solve ssr_count             before counter_control;
        solve counter_control       before count_event_first;
        solve counter_control       before count_event_second;
        solve count_event_first     before count_event_second;     
        solve count_event_first     before minimum_stall_period;
        solve count_event_second    before minimum_stall_period;

    }

    //Pmon bw constraints
    <% if (obj.Block == 'dii' || obj.Block == 'dmi') {  %> 
    constraint c_bw_filter_value{
        
        foreach(bw_filter_value[i]) {
            if (bw_filter_select[i]) { bw_filter_value[i] inside {[0:<%=obj.DveInfo[0].nAius%>]};} // dii funit id values
            else  { bw_filter_value[i] inside {[5:15]};} // dii user bits values
        }
    }

    constraint c_bw_filter_mask{
        
        foreach(bw_filter_mask[i]) {
            if (bw_filter_select[i]) { 
                (bw_filter_val_random_funit_id[i] & bw_filter_mask[i]) inside {[1:<%=obj.DveInfo[0].nAius%>]};
            } // Constraint mask for bw funit id filter values
            else  { 
                (bw_filter_val_random_user_bits[i] & bw_filter_mask[i]) inside {[5:15]};
            } // Constraint mask for bw user bits filter values
        }
    }
    <%  } else if (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI")) { %> 

    constraint c_bw_filter_value{
        foreach(bw_filter_value[i]) {
            if (bw_filter_select[i]) { bw_filter_value[i] inside {[ncoreConfigInfo::NUM_AIUS : ncoreConfigInfo::NUM_AGENTS -1]};} // inside all DCE,DVE,DMI,DII funitds id values
            else  { bw_filter_value[i] inside {[5:15]};} // chi user bits values
        }
    }

    constraint c_bw_filter_mask{
        
        foreach(bw_filter_mask[i]) {
            if (bw_filter_select[i]) { 
                (bw_filter_val_random_funit_id[i] & bw_filter_mask[i]) inside {[ncoreConfigInfo::NUM_AIUS : ncoreConfigInfo::NUM_AGENTS -1]};
            } // Constraint mask for bw funit id filter values
            else  { 
                (bw_filter_val_random_user_bits[i] & bw_filter_mask[i]) inside {[5:15]};
            } // Constraint mask for bw user bits filter values
        }
    }
    <%  } 

    else  if (obj.testBench =="io_aiu")   { %>
    constraint c_bw_filter_value{
        foreach(bw_filter_value[i]) {
            if (bw_filter_select[i]) { bw_filter_value[i] inside {[ncoreConfigInfo::NUM_AIUS : ncoreConfigInfo::NUM_AGENTS -1]};} // inside all DCE,DVE,DMI,DII funitds id values
            else  { bw_filter_value[i] inside {[5:15]};} // ioaiu user bits values
        }
    }

    constraint c_bw_filter_mask{
        
        foreach(bw_filter_mask[i]) {
            if (bw_filter_select[i]) { 
                (bw_filter_val_random_funit_id[i] & bw_filter_mask[i]) inside {[ncoreConfigInfo::NUM_AIUS : ncoreConfigInfo::NUM_AGENTS -1]};
            } // Constraint mask for bw funit id filter values
            else  { 
                (bw_filter_val_random_user_bits[i] & bw_filter_mask[i]) inside {[5:15]};
            } // Constraint mask for bw user bits filter values
        }
    }

    <%  }  %> 
    
    //Pmon 3.4 feature
    <% if (obj.Block == 'dii' ||  (obj.testBench =="io_aiu")  || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %> 
    ///// BW counter config constraints////////
    constraint c_bw_user_defined_cfg{
        foreach(bw_filter_value[i]) {
            if(force_bw_filter_value[i]== 1)     { bw_filter_value[i] == forced_bw_filter_value[i];}
            if(force_bw_filter_select[i]== 1)    { bw_filter_select[i] == forced_bw_filter_select[i];}
            if(force_bw_filter_mask[i]== 1)    { bw_filter_mask[i] == forced_bw_filter_mask[i];}
        }
    }

    constraint c_bw_filter_select{

        foreach(bw_filter_select[i]) {
            if (xuser > 0) { bw_filter_select[i] inside {0,1};}
            else { bw_filter_select[i] inside {1};} // no user bits filtering with configuration without User fields

        }
    }
    constraint c_perfmon_bw_constraint_order{
        solve bw_filter_select  before bw_filter_value;
        solve bw_filter_value  before bw_filter_mask;

    }
    /////////////// Latency counter config constraints////////
    constraint c_latency_user_defined_cfg{
     
        if(force_lct_pre_scale == 1)     { lct_pre_scale == forced_lct_pre_scale;}
        if(force_lct_type == 1)          { lct_type == forced_lct_type;}
        if(force_lct_bin_offset == 1)    { lct_bin_offset == forced_lct_bin_offset;}
        
    }

    constraint c_lct_pre_scale{

        
        lct_pre_scale  inside {LCT_NB_CYCLE_2,LCT_NB_CYCLE_4,LCT_NB_CYCLE_8,LCT_NB_CYCLE_16};
    
    }
    constraint c_lct_type{

        
        lct_type  inside {LCT_READ,LCT_WRITE};
    
    }
    <% }  %> 
endclass: <%=obj.BlockId%>_perf_cnt_units


function void <%=obj.BlockId%>_perf_cnt_units::print_cfgs(int id);
    // Print config
    `uvm_info("perf_counter_units",$sformatf("\n%30s Counter Control Register CNTCR%0d : \n%p"," ", id, cfg_reg[id]), UVM_MEDIUM )
    `uvm_info("perf_counter_units",$sformatf("\n%30s Counter Value   Register CNTVR%0d : \n%p"," ", id, cfg_xcntvr_reg[id]), UVM_MEDIUM )
endfunction: print_cfgs



function void <%=obj.BlockId%>_perf_cnt_units::set_cfg_regs();
    
    for(int i=0;i<<%=obj.DutInfo.nPerfCounters%> ;i++) begin
        cfg_reg[i].count_event_first    = count_event_first      [i]; 
        cfg_reg[i].count_event_second   = count_event_second     [i]; 
        cfg_reg[i].minimum_stall_period = minimum_stall_period   [i]; 
        cfg_reg[i].filter_select        = filter_select          [i]; 
        cfg_reg[i].ssr_count            = ssr_count              [i]; 
        cfg_reg[i].counter_control      = counter_control        [i]; 
        cfg_reg[i].interrupt_enable     = interrupt_enable       [i]; 
        print_cfgs(i);
    <% if  (obj.testBench =="io_aiu") { %> 

        cfg_xcntvr_reg[i].count_event_evt = (cfg_reg[i].count_event_first !=0) ? cfg_reg[i].count_event_first : cfg_reg[i].count_event_second;

    <% }  %>
    end

endfunction: set_cfg_regs


`ifndef FSYS_COVER_ON
`ifndef IOAIU_SUBSYS_COVER_ON
function void <%=obj.BlockId%>_perf_cnt_units::sample_for_counters();
    for(int i=0;i<<%=obj.DutInfo.nPerfCounters%> ;i++) begin
        m_cov_perf_cnt[i].sample();
        //Pmon 3.4 feature
        <% if (obj.Block == 'dii' || obj.Block == 'dmi' || (obj.testBench =="io_aiu") || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  

        m_cov_bw_cnt[i].sample();

        <% }  %>  
    end
<% if ((obj.testBench =="io_aiu")) {%>  
    for(int i=0;i<<%=obj.DutInfo.nPerfCounters%> ;i++) begin
        m_cov_perf_cnt_evt_xCNTVR[i].sample();
        //Pmon 3.4 feature
        <% if (obj.Block == 'dii' || obj.Block == 'dmi' || (obj.testBench =="io_aiu") || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  

        m_cov_bw_cnt[i].sample();

        <% }  %>  
    end
<%}%>  
endfunction: sample_for_counters
`endif
`endif
function void <%=obj.BlockId%>_perf_cnt_units::parse_args();

    // First check cmdline args to SET ALL COUNTER WITH SAME VALUE
    if($value$plusargs("perfmon_event=%d", constraints_arg2)) begin
        bit val_first_sel ;
        bit val_second_sel; 
        int val_first = 0 ; 
        int val_second =0; 
        while (val_first ==  val_second) begin
            val_first_sel = $urandom_range(0,1);
            val_second_sel = $urandom_range(0,1);
            if (val_first_sel) begin 
                val_first=constraints_arg2;
            end else begin 
                val_first=0;
            end 
            if (val_second_sel) begin 
                val_second=constraints_arg2;
            end else begin
                val_second=0;
            end 
        end 
        foreach(forced_count_event_first[i]) forced_count_event_first[i]= e_count_event'(val_first);
        foreach(force_count_event_first[i]) force_count_event_first[i] = 1;
        foreach(forced_count_event_second[i]) forced_count_event_second[i] = e_count_event'(val_second);
        foreach(force_count_event_second[i]) force_count_event_second[i] = 1;
    end
    if($value$plusargs("event_first=%d", constraints_arg2)) begin
        foreach(forced_count_event_first[i]) forced_count_event_first[i]= e_count_event'(constraints_arg2);
        foreach(force_count_event_first[i]) force_count_event_first[i] = 1;
    end
    if($value$plusargs("event_second=%d", constraints_arg2)) begin
        foreach(forced_count_event_second[i]) forced_count_event_second[i] = e_count_event'(constraints_arg2);
        foreach(force_count_event_second[i]) force_count_event_second[i] = 1;
    end
    if($value$plusargs("counter_control=%d", constraints_arg2)) begin
        foreach(forced_counter_control[i]) forced_counter_control[i] = e_counter_control'(constraints_arg2);
        foreach(force_counter_control[i]) force_counter_control[i] = 1;
    end
    if($value$plusargs("min_stall_period=%d", constraints_arg2)) begin
        foreach(forced_minimum_stall_period[i]) forced_minimum_stall_period[i] = e_minimum_stall_period'(constraints_arg2);
        foreach(force_minimum_stall_period[i]) force_minimum_stall_period[i] = 1;
    end
    if($value$plusargs("filter_select=%d", constraints_arg2)) begin
        foreach(forced_filter_select[i]) forced_filter_select[i] = e_filter_select'(constraints_arg2);
        foreach(force_filter_select[i]) force_filter_select[i] = 1;
    end
    if($value$plusargs("ssr_count=%d", constraints_arg2)) begin
        foreach(forced_ssr_count[i]) forced_ssr_count[i] = e_ssr_count'(constraints_arg2);
        foreach(force_ssr_count[i]) force_ssr_count[i] = 1;
    end
    if($value$plusargs("interrupt_enable=%d", constraints_arg2)) begin
        foreach(forced_interrupt_enable[i]) forced_interrupt_enable[i] = bit'(constraints_arg2);
        foreach(force_interrupt_enable[i]) force_interrupt_enable[i] = 1;
    end
    if($value$plusargs("count_enable=%d", constraints_arg2)) begin
        foreach(force_count_enable[i]) force_count_enable[i] = bit'(constraints_arg2);
    end
    
    // Second : check cmdline args to OVERRIDE PER BLOCK
    if($value$plusargs("<%=blockname%>_event_first=%d", constraints_arg2)) begin
        foreach(forced_count_event_first[i]) forced_count_event_first[i]= e_count_event'(constraints_arg2);
        foreach(force_count_event_first[i]) force_count_event_first[i] = 1;
    end
    if($value$plusargs("<%=blockname%>_event_second=%d", constraints_arg2)) begin
        foreach(forced_count_event_second[i]) forced_count_event_second[i] = e_count_event'(constraints_arg2);
        foreach(force_count_event_second[i]) force_count_event_second[i] = 1;
    end
    if($value$plusargs("<%=blockname%>_counter_control=%d", constraints_arg2))  begin
        foreach(forced_counter_control[i]) forced_counter_control[i] = e_counter_control'(constraints_arg2);
        foreach(force_counter_control[i]) force_counter_control[i] = 1;
    end
    if($value$plusargs("<%=blockname%>_min_stall_period=%d", constraints_arg2)) begin
        foreach(forced_minimum_stall_period[i]) forced_minimum_stall_period[i] = e_minimum_stall_period'(constraints_arg2);
        foreach(force_minimum_stall_period[i]) force_minimum_stall_period[i] = 1;
    end
    if($value$plusargs("<%=blockname%>_filter_select=%d", constraints_arg2)) begin
        foreach(forced_filter_select[i]) forced_filter_select[i] = e_filter_select'(constraints_arg2);
        foreach(force_filter_select[i]) force_filter_select[i] = 1;
    end
    if($value$plusargs("<%=blockname%>_ssr_count=%d", constraints_arg2)) begin
        foreach(forced_ssr_count[i]) forced_ssr_count[i] = e_ssr_count'(constraints_arg2);
        foreach(force_ssr_count[i]) force_ssr_count[i] = 1;
    end
    if($value$plusargs("<%=blockname%>_interrupt_enable=%d", constraints_arg2)) begin
        foreach(forced_interrupt_enable[i]) forced_interrupt_enable[i] = bit'(constraints_arg2);
        foreach(force_interrupt_enable[i]) force_interrupt_enable[i] = 1;
    end
    if($value$plusargs("<%=blockname%>_count_enable=%d", constraints_arg2)) begin
        foreach(force_count_enable[i]) force_count_enable[i] = bit'(constraints_arg2);
    end

            // Third : check cmdline args to  OVERRIDE PER UNIT

    if($value$plusargs("<%=obj.BlockId%>_event_first=%s", constraints_arg)) begin
        parse_str(constraints_str, "v", "n",  constraints_arg);
        for(int i=0 ; i< $size(constraints_str) ; i=i+2) begin
            forced_count_event_first[constraints_str[i].atoi()] = e_count_event'(constraints_str[i+1].atoi());
            force_count_event_first[constraints_str[i].atoi()] = 1;
        end
    end
    if($value$plusargs("<%=obj.BlockId%>_event_second=%s", constraints_arg)) begin
        parse_str(constraints_str, "v", "n",  constraints_arg);
        for(int i=0 ; i< $size(constraints_str) ; i=i+2) begin
            forced_count_event_second[constraints_str[i].atoi()] = e_count_event'(constraints_str[i+1].atoi());
            force_count_event_second[constraints_str[i].atoi()] = 1;
        end
    end
    if($value$plusargs("<%=obj.BlockId%>_counter_control=%s", constraints_arg)) begin
        parse_str(constraints_str, "v", "n",  constraints_arg);
        for(int i=0 ; i< $size(constraints_str) ; i=i+2) begin
            forced_counter_control[constraints_str[i].atoi()] = e_counter_control'(constraints_str[i+1].atoi());
            force_counter_control[constraints_str[i].atoi()] = 1;
        end
    end
    if($value$plusargs("<%=obj.BlockId%>_min_stall_period=%s", constraints_arg)) begin
        parse_str(constraints_str, "v", "n",  constraints_arg);
        for(int i=0 ; i< $size(constraints_str) ; i=i+2) begin
            forced_minimum_stall_period[constraints_str[i].atoi()] = e_minimum_stall_period'(constraints_str[i+1].atoi());
            force_minimum_stall_period[constraints_str[i].atoi()] = 1;
        end
    end
    if($value$plusargs("<%=obj.BlockId%>_filter_select=%s", constraints_arg)) begin
       parse_str(constraints_str, "v", "n",  constraints_arg);
        for(int i=0 ; i< $size(constraints_str) ; i=i+2) begin
            forced_filter_select[constraints_str[i].atoi()] = e_filter_select'(constraints_str[i+1].atoi());
            force_filter_select[constraints_str[i].atoi()] = 1;
        end
    end
    if($value$plusargs("<%=obj.BlockId%>_ssr_count=%s", constraints_arg)) begin
       parse_str(constraints_str, "v", "n",  constraints_arg);
        for(int i=0 ; i< $size(constraints_str) ; i=i+2) begin
            forced_ssr_count[constraints_str[i].atoi()] = e_ssr_count'(constraints_str[i+1].atoi());
            force_ssr_count[constraints_str[i].atoi()] = 1;
        end
    end
    if($value$plusargs("<%=obj.BlockId%>_interrupt_enable=%s", constraints_arg)) begin
        parse_str(constraints_str, "v", "n",  constraints_arg);
         for(int i=0 ; i< $size(constraints_str) ; i=i+2) begin
            forced_interrupt_enable[constraints_str[i].atoi()] = bit'(constraints_str[i+1].atoi());
            force_interrupt_enable[constraints_str[i].atoi()] = 1;
         end
     end
    if($value$plusargs("<%=obj.BlockId%>_count_enable=%s", constraints_arg)) begin
        parse_str(constraints_str, "v", "n",  constraints_arg);
         for(int i=0 ; i< $size(constraints_str) ; i=i+2) begin
            force_count_enable[constraints_str[i].atoi()] = bit'(constraints_str[i+1].atoi());
         end
     end
    for (int i=0; i< <%=obj.DutInfo.nPerfCounters%>; i++) begin
      if ((force_count_event_second[i]) ||  
    	  (force_minimum_stall_period[i]) ||  
    	  (force_filter_select[i]) ||  
    	  (force_ssr_count[i]) ||  
    	  (force_counter_control[i]) ||  
    	  (force_interrupt_enable[i])) begin
	    perfmon_no_full_rand = 1;
	    break;
	  end
     end
     `uvm_info("perf_counter_units : ZIED TLILI",$sformatf("perfmon_no_full_rand%0d", perfmon_no_full_rand), UVM_MEDIUM )

     if($test$plusargs("perfmon_32bit_mode")) begin
        perfmon_32bit_mode = 1;
    end
    if($test$plusargs("<%=obj.BlockId%>_perfmon_32bit_mode")) begin
        perfmon_32bit_mode = 1;
    end

    if($test$plusargs("perfmon_local_count_enable")) begin
        perfmon_local_count_enable = 1;
    end
    if($test$plusargs("<%=obj.BlockId%>_perfmon_local_count_enable")) begin
        perfmon_local_count_enable = 1;
    end

    if($test$plusargs("perfmon_local_count_clear")) begin
        perfmon_local_count_clear = 1;
    end
    if($test$plusargs("<%=obj.BlockId%>_perfmon_local_count_clear")) begin
        perfmon_local_count_clear = 1;
    end
    
    if($test$plusargs("perfmon_main_count_enable")) begin
        main_count_enable = 1;
    end
    if($test$plusargs("<%=obj.BlockId%>_perfmon_main_count_enable")) begin
        main_count_enable = 1;
    end
   
    ///////////////// BW filter set from args
    //Pmon 3.4 feature
    <% if (obj.Block == 'dii' ||  (obj.testBench =="io_aiu") || obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %> 
    // filter enable
    if($value$plusargs("filter_enable=%d", constraints_arg2)) begin
        foreach(force_filter_enable[i]) force_filter_enable[i] = bit'(constraints_arg2);
    end

    if($value$plusargs("<%=blockname%>_filter_enable=%d", constraints_arg2)) begin
        foreach(force_filter_enable[i]) force_filter_enable[i] = bit'(constraints_arg2);
    end
    // filter select
    if($value$plusargs("bw_filter_select=%d", constraints_arg2)) begin
        foreach(forced_bw_filter_select[i]) begin 
            forced_bw_filter_select[i] = e_bw_filter_select'(constraints_arg2);
            if ((xuser == 0) && (forced_bw_filter_select[i] == 0) )
            `uvm_error(get_full_name(), $sformatf("Configuration doesn't support userbits so filter select testarg ##bw_filter_select## shouldn't be defined as user bits filtering "))
        end
        foreach(force_bw_filter_select[i]) force_bw_filter_select[i] = 1;
        
    end

    if($value$plusargs("<%=blockname%>_bw_filter_select=%d", constraints_arg2)) begin
        foreach(forced_bw_filter_select[i]) begin
            forced_bw_filter_select[i] = e_bw_filter_select'(constraints_arg2);
            if ((xuser == 0) && (forced_bw_filter_select[i] == 0) )
            `uvm_error(get_full_name(), $sformatf("Configuration doesn't support userbits so filter select testarg ##bw_filter_select## shouldn't be defined as user bits filtering "))
        end
        foreach(force_bw_filter_select[i]) force_bw_filter_select[i] = 1;
    end
    //filter value
    if($value$plusargs("bw_filter_value=%h", constraints_arg2)) begin
        foreach(forced_bw_filter_value[i]) forced_bw_filter_value[i] = e_bw_filter_value'(constraints_arg2);
        foreach(force_bw_filter_value[i]) force_bw_filter_value[i] = 1;
    end

    if($value$plusargs("<%=blockname%>_bw_filter_value=%h", constraints_arg2)) begin
        foreach(forced_bw_filter_value[i]) forced_bw_filter_value[i] = e_bw_filter_value'(constraints_arg2);
        foreach(force_bw_filter_value[i]) force_bw_filter_value[i] = 1;
    end

    //filter mask

       //filter value
    if($value$plusargs("bw_filter_mask=%h", constraints_arg2)) begin
        foreach(forced_bw_filter_mask[i]) forced_bw_filter_mask[i] = e_bw_filter_mask'(constraints_arg2);
        foreach(force_bw_filter_mask[i]) force_bw_filter_mask[i] = 1;
    end

    if($value$plusargs("<%=blockname%>_bw_filter_mask=%h", constraints_arg2)) begin
        foreach(forced_bw_filter_mask[i]) forced_bw_filter_mask[i] = e_bw_filter_mask'(constraints_arg2);
        foreach(force_bw_filter_mask[i]) force_bw_filter_mask[i] = 1;
    end

    if($test$plusargs("pmon_bw_test")) begin
        pmon_bw_test = 1;
    end
    if($test$plusargs("<%=obj.BlockId%>_pmon_bw_test")) begin
        pmon_bw_test = 1;
    end
    //////////////////////////////////////// Latency counter set from args


    if($test$plusargs("pmon_latency_test")) begin
        pmon_latency_test = 1;
    end
    if($test$plusargs("<%=obj.BlockId%>_pmon_latency_test")) begin
        pmon_latency_test = 1;
    end


    if($test$plusargs("latency_count_enable")) begin
        force_latency_count_enable = 1;
    end
    if($test$plusargs("<%=obj.BlockId%>_latency_count_enable")) begin
        force_latency_count_enable = 1;
    end
    
    // latency prescale
    if($value$plusargs("lct_pre_scale=%d", constraints_arg2)) begin
        forced_lct_pre_scale= e_latency_pre_scale'(constraints_arg2);
        force_lct_pre_scale = 1;
    end

    if($value$plusargs("<%=blockname%>_lct_pre_scale=%d", constraints_arg2)) begin
        forced_lct_pre_scale= e_latency_pre_scale'(constraints_arg2);
        force_lct_pre_scale = 1;
    end
    // latency bin offset
    if($value$plusargs("lct_bin_offset=%h", constraints_arg2)) begin
        forced_lct_bin_offset = e_latency_bin_offset'(constraints_arg2);
        force_lct_bin_offset = 1;
    end

    if($value$plusargs("<%=blockname%>_lct_bin_offset=%h", constraints_arg2)) begin
        forced_lct_bin_offset = e_latency_bin_offset'(constraints_arg2);
        force_lct_bin_offset = 1;
    end

    // latency type
    if($value$plusargs("lct_type=%d", constraints_arg2)) begin
        forced_lct_type= e_latency_type'(constraints_arg2);
        force_lct_type = 1;
    end

    if($value$plusargs("<%=blockname%>_lct_type=%d", constraints_arg2)) begin
        forced_lct_type= e_latency_type'(constraints_arg2);
        force_lct_type = 1;
    end
    <% }  %>

    <% if (obj.Block == 'dii' || obj.Block == 'dmi') {  %> 
    foreach(bw_filter_val_random_funit_id[i]) 
        bw_filter_val_random_funit_id[i] = $urandom_range(1,<%=obj.DveInfo[0].nAius%>);
    foreach(bw_filter_val_random_user_bits[i]) 
        bw_filter_val_random_user_bits[i] = $urandom_range(5,15);
    <% }  %>
    <% if (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI")) {  %> 
    foreach(bw_filter_val_random_funit_id[i]) 
        bw_filter_val_random_funit_id[i] = $urandom_range(ncoreConfigInfo::NUM_AIUS,ncoreConfigInfo::NUM_AGENTS - 1);
    foreach(bw_filter_val_random_user_bits[i]) 
        bw_filter_val_random_user_bits[i] = $urandom_range(5,15);
    <% }  %>

 <% if (obj.testBench =="io_aiu")  {  %> 
    foreach(bw_filter_val_random_funit_id[i]) 
        bw_filter_val_random_funit_id[i] = $urandom_range(ncoreConfigInfo::NUM_AIUS,ncoreConfigInfo::NUM_AGENTS - 1);
    foreach(bw_filter_val_random_user_bits[i]) 
        bw_filter_val_random_user_bits[i] = $urandom_range(5,15);
    <% }  %>

endfunction: parse_args

/*
function void <%=obj.BlockId%>_perf_cnt_units::check_cfgs();
    for(int i=0; i< $size(counter_control); i++)begin
        //Priority to counter conrol mode
        if((count_event_first[i] == 0 || count_event_second[i] == 0) && counter_control[i] == AND_C) begin
            if(($test$plusargs("<%=obj.BlockId%>_counter_control") || $test$plusargs("<%=blockname%>_counter_control") || $test$plusargs("counter_control")) ) begin
                if (count_event_first[i] == 0)   std::randomize(count_event_first[i]) with {c_count_event_reserved;count_event_first[i] != 0;};
                if (count_event_second[i] == 0)  std::randomize(count_event_second[i]) with {c_count_event_reserved;count_event_second[i] != 0;};
            end else begin
                std::randomize(counter_control[i]) with {counter_control[i] != {'b011,'b100,'b101,'b111,AND_C};};
            end
        end
    end
endfunction : check_cfgs
*/

function void <%=obj.BlockId%>_perf_cnt_units::parse_str(output string out [], input byte separator1, byte separator2, string in);
int index [$]; // queue of indices (begin, end) of characters between separator

if((in.tolower() != "none") && (in.tolower() != "null")) begin
foreach(in[i]) begin // find separator
  if (in[i]==separator1 || in[i]==separator2) begin
     index.push_back(i-1); // index of byte before separator
     index.push_back(i+1); // index of byte after separator
  end
end
index.push_front(0); // begin index of 1st group of characters
index.push_back(in.len()-1); // last index of last group of characters

out = new[index.size()/2];

// grep characters between separator
foreach (out[i]) begin
  out[i] = in.substr(index[2*i],index[2*i+1]);
end
end // if ((in.tolower() != "none") || (in.tolower() != "null"))

endfunction : parse_str

function bit <%=obj.BlockId%>_perf_cnt_units::check_is_capture_dropped_packets();
    bit out = 0 ;
    <% var drop_listname = obj.listEventArr.filter(e => e.name.match(/.*ed.*packets.*/i)).map(e => e.name);
     if (drop_listname.length) {%>
    for(int i=0;i<<%=obj.DutInfo.nPerfCounters%> ;i++) begin 
        if ((cfg_reg[i].count_event_first inside {<%=drop_listname.join(",")%>})
         || (cfg_reg[i].count_event_second inside {<%=drop_listname.join(",")%>})) 
            out =1 ;
    end
    <% } %>
    return (out);
endfunction : check_is_capture_dropped_packets

//Pmon 3.4 feature
<% if (obj.Block == 'dii' ||(obj.testBench =="io_aiu")|| obj.Block == 'dmi' || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %> 
function void <%=obj.BlockId%>_perf_cnt_units::set_bw_cfg_regs();
    
    for(int i=0;i<<%=obj.DutInfo.nPerfCounters%> ;i++) begin

        bw_filter_reg[i].filter_select = bw_filter_select[i];
        bw_filter_reg[i].filter_value = bw_filter_value[i];
        bw_mask_reg[i].mask_value = bw_filter_mask[i];

    end

endfunction: set_bw_cfg_regs

//#Stimulus.DII.Pmon.v3.4.LatencyFixed
//#Stimulus.CHIAIU.Pmon.v3.4.LatencyFixed
//#Stimulus.DII.Pmon.v3.4.LatencyRand
//#Stimulus.CHIAIU.Pmon.v3.4.LatencyRand
function void <%=obj.BlockId%>_perf_cnt_units::set_lct_cfg_regs();

    lct_reg.lct_pre_scale  = lct_pre_scale;
    lct_reg.lct_type       = lct_type;     
    lct_reg.lct_bin_offset = lct_bin_offset;                            

endfunction: set_lct_cfg_regs
<% }  %>

