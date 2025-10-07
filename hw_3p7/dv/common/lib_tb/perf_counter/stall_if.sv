import uvm_pkg::*;
`include "uvm_macros.svh"

<% var nPerfCounters_stall_if = (obj.nPerfCounters)?obj.nPerfCounters:1; // can't be zero in the declaration%>

interface <%=obj.BlockId%>_stall_if;
   
<%=obj.listEventArr.filter(e => e.type=="stall").map(e =>
`logic ${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_valid; // event index: ${e.evt_idx} ${(e.comment)?e.comment:""}
logic ${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_ready;`).join('\n')%>

//multi-bits events
<%=obj.listEventArr.filter(e => e.type=="data" && e.width).map(e =>
`bit [${e.width-1} :0] ${(e.itf_name)?e.itf_name:e.name.toLowerCase()}; // event index:${e.evt_idx} ${(e.comment)?e.comment:""}`).join('\n')%>

// one bit event
<%=obj.listEventArr.filter(e => e.type=="signal").map(e =>
`bit ${(e.itf_name)?e.itf_name:e.name.toLowerCase()};   //event index:${e.evt_idx} ${(e.comment)?e.comment:""}`).join('\n')%>

// bandwidth event

<%=obj.listEventArr.filter(e => e.type=="bw").map(e =>
`logic ${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_valid; // event index: ${e.evt_idx} ${(e.comment)?e.comment:""}
bit ${(e.itf_name)?e.itf_name:e.name.toLowerCase()};
bit [19:0] ${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_funit_id_if;
bit [19:0] ${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_funit_id;
bit [19:0] ${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_user_bits_if;
bit [19:0] ${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_user_bits;
logic ${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_ready;`).join('\n')%>
// div 16 event
<%=obj.listEventArr.filter(e => e.name.match(/div_/i)).map(e =>
`int ${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_cpt;
bit ${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_en;`).join('\n')%>

logic stall_event_signal[<%=nPerfCounters_stall_if%>][2];
int   multi_bits_event_signal[<%=nPerfCounters_stall_if%>][2];

bit master_cnt_enable;

logic clk;
logic rst_n;
logic ott_busy;

logic trace_capture_busy;
int   num_SMI_packets_registered;

const int num_bins = 8;

typedef int event_q[$];
event_q perf_count_events[string]; 

string stall_event[<%=nPerfCounters_stall_if%>][2];
typedef struct {
    bit unsigned [31:0] cnt_v;
    bit unsigned [31:0] cnt_v_str;
} count_value_obj_if;
count_value_obj_if cnt_reg_capture[<%=nPerfCounters_stall_if%>];
logic [7:0] latency_bins = 8'h0;

///////////// BW /////////////////
bit filter_en[<%=nPerfCounters_stall_if%>];
bit [19:0] filter_value_out[<%=nPerfCounters_stall_if%>];
bit [19:0] filter_mask[<%=nPerfCounters_stall_if%>];
bit filter_select[<%=nPerfCounters_stall_if%>];
///////
task automatic get_multi_bits_event_signals( int perf_counter_id ,  int event_id);
    forever begin
        @(posedge clk);
        #1; 
        case (stall_event[perf_counter_id][event_id])
              <%=obj.listEventArr.filter(e => e.type == "data"&& e.width).map(e =>`
                    "${e.name}": begin //event index:${e.evt_idx} ${(e.comment)?e.comment:""}
                        multi_bits_event_signal[perf_counter_id][event_id] =${(e.itf_name)?e.itf_name:e.name.toLowerCase()};
                    end`).join("\n")%>
            default       : multi_bits_event_signal[perf_counter_id][event_id] = 0;
        endcase
    end
endtask : get_multi_bits_event_signals


task automatic get_stall_event_signals( int perf_counter_id ,  int event_id);

    forever begin
        @(posedge clk);
        <% if(obj.testBench == 'dii') { %>
         `ifndef VCS
          #1;
         `else // `ifndef VCS
          //#1;
         `endif
        <% } else { %>
         #1;
        <% } %>
        case (stall_event[perf_counter_id][event_id])
            <%=obj.listEventArr.filter(e => e.type && e.type != "data" && e.type != "bw").map(e =>`
                "${e.name}": begin //event index:${e.evt_idx} ${(e.comment)?e.comment:""}
                    stall_event_signal[perf_counter_id][event_id] =   ${(e.type=="stall")?`(${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_valid && !${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_ready);`
                                                                                          :`${(e.itf_name)?e.itf_name:e.name.toLowerCase()};`}
                end`).join("\n")%>
                //#Check.DII.Pmon.v3.4.BwFilter
                //#Check.CHIAIU.Pmon.v3.4.BwFilter
            <%=obj.listEventArr.filter(e => e.type == "bw"&& e.width).map(e =>`
                "${e.name}": begin //event index:${e.evt_idx} ${(e.comment)?e.comment:""}
                    stall_event_signal[perf_counter_id][event_id] =${(e.itf_name)?e.itf_name:e.name.toLowerCase()} 
                    &&  ( (filter_en[perf_counter_id]==0) || 
                        ( (filter_en[perf_counter_id]==1) && ((${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_funit_id & filter_mask[perf_counter_id]) == filter_value_out[perf_counter_id]) && (filter_select[perf_counter_id] == 1)) || 
                        ( (filter_en[perf_counter_id]==1) && ((${(e.itf_name)?e.itf_name:e.name.toLowerCase()}_user_bits & filter_mask[perf_counter_id]) == filter_value_out[perf_counter_id]) && (filter_select[perf_counter_id] == 0)));
                end`).join("\n")%>
            default       : stall_event_signal[perf_counter_id][event_id] = 0;
        endcase
    end

endtask : get_stall_event_signals

/*
task generate_pulse(string event_s="", bit sig=1'b0);
    bit item;
    @(posedge clk) ;
    sig <= 'b1;
    repeat(1) @(posedge clk) ;
    sig <= 'b0;           
    item=perf_count_events[event_s].pop_front();
endtask
*/

task automatic generate_event (string m_event);
    bit item;
    begin
    case (m_event)
<% obj.listEventArr.forEach( function(event) { if(event.type !="stall" && event.type !="bw" && event.width == 1)  { %>
        "<%=event.name%>" : begin
<% if (event.name.match(/div_/i)) { // case divide %>
                <%=event.name.toLowerCase()%> = <%=event.width%>'b1;
                <%=event.name.toLowerCase()%>_cpt++;
<%} else {%>
                @(posedge clk) ;
                <%=event.name.toLowerCase()%> = <%=event.width%>'b1;<%}%>
                repeat(1) @(posedge clk) ;
                <%=event.name.toLowerCase()%> = <%=event.width%>'b0;
<% if (!event.name.match(/div_/i)) {%>                 item=perf_count_events["<%=event.name%>"].pop_front(); <%}%>
                end
<%}}) //end foreach listEventArr %>
    endcase

end
endtask : generate_event

task automatic generate_all_events();
@(posedge clk);

fork
<% obj.listEventArr.forEach( function(event) { if(event.type && (event.type !="stall") && !event.name.match(/disable/i) && !event.name.match(/dropped/i) &&  !event.name.match(/captured_dtwdbgreq/i) ) { %>
    begin 
        forever begin
            <% if (event.name.match(/div_/i)) { // case divide %>
            <%  var value_div = event.name.match(/_([0-9]+)_/); // extract value_div in regxexpvar[1] [0] all regexp match & [1] only the value between () %>
               if (<%=event.name.toLowerCase()%>_cpt % <%=value_div[1]%> == <%=value_div[1]%>-2) begin
                    generate_event("<%=event.name%>");
                end
                if( ! rst_n) begin
                    <%=event.name.toLowerCase()%>_cpt=0;
                end else begin
                    <%=event.name.toLowerCase()%>_cpt++;
                end
            @(posedge clk); 
            <%} else if (event.type =="bw"){%> 
            @(posedge clk);
            //#Stimulus.DII.Pmon.v3.4.Bw 
            //#Stimulus.DMI.Pmon.v3.4.Bw
            //#Stimulus.CHIAIU.Pmon.v3.4.Bw
            generate_bandwidth_event("<%=event.name%>"); 
            <%} else  {%>   // if not div clock
            @(posedge clk); 
            if (perf_count_events["<%=event.name%>"].size()>0) begin
                <% if (event.width == 1 && event.type !="bw"){%>generate_event("<%=event.name%>"); <%}  else  {%>
                <%=event.itf_name%> = perf_count_events["<%=event.name%>"].pop_front();<%}%>
            end <%}%>
            <% if (event.width > 1 && ! (event.name.toLowerCase().includes("tt_entries")) && ! (event.name.toLowerCase().includes("interleaved_data")) ) {%> else <%=event.itf_name%> = 0 ; <%}%>
            end
        end
<%}}) //end foreach listEventArr %>
join

endtask : generate_all_events

//Pmon 3.4 feature
// note that obj.Block.includes("aiu") is to get ioaiu (and chi) since ioaiu BlockId can different for customer configs
<% if (obj.BlockId.includes("dii") || obj.BlockId.includes("dmi") || obj.Block.includes("aiu") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  
task automatic generate_bandwidth_event (string m_event);
    bit item;
    begin
   
    case (m_event)
<% obj.listEventArr.forEach( function(event) { if(event.type =="bw" )  { %>
        "<%=event.name%>" : begin
                    <%=event.itf_name%> = <%=event.itf_name.toLowerCase()%>_valid && <%=event.itf_name.toLowerCase()%>_ready; 
                    <%=event.itf_name%>_funit_id =  <%=event.itf_name%>_funit_id_if  ;
                    <%=event.itf_name%>_user_bits =  <%=event.itf_name%>_user_bits_if ;  
        end
    <%}}) //end foreach listEventArr %>
    endcase
end

endtask : generate_bandwidth_event

<% }%>
<% if(obj.BlockId.includes("dii") || obj.BlockId.includes("dmi") || (obj.testBench =="io_aiu")  || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) { %>
task automatic generate_latency_event (string m_event);
    int item;
    @(posedge clk); 
    item=perf_count_events[m_event].pop_front();
    latency_bins[item]=1'b1;
    repeat(1) @(posedge clk) ;
    latency_bins[item] = 1'b0;


endtask : generate_latency_event

task automatic generate_all_latency_events ();

    fork 
        
        begin : main_latency_count
           for (int j=0; j< num_bins ;j++) begin
                fork 
                    automatic string lct_bins= $sformatf("Bins%0d",j);
                begin
                    generate_latency_bins(lct_bins); 
                end
                join_none
            end
            wait fork;
        end
        
    join

endtask : generate_all_latency_events


task automatic generate_latency_bins (string m_event);
forever begin

     @(posedge clk); 
     if (perf_count_events[m_event].size()>0) begin
        generate_latency_event(m_event); 
     end 
end

endtask : generate_latency_bins
<% }%>
endinterface

