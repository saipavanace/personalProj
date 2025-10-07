import uvm_pkg::*;
`include "uvm_macros.svh"

<%
var nWttEntries = 0;
var nRttEntries = 0 ;

if (obj.BlockId.includes("dii")) {
          nWttEntries = obj.DiiInfo[obj.Id].cmpInfo.nWttCtrlEntries;
          nRttEntries = obj.DiiInfo[obj.Id].cmpInfo.nRttCtrlEntries;
}

if (obj.BlockId.includes("dmi")) {
          nWttEntries = obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries;
          nRttEntries = obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries;

}

if ((obj.testBench =="io_aiu") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))){
var nXttEntries = obj.AiuInfo[obj.Id].cmpInfo.nOttCtrlEntries;
} else {
var nXttEntries = Math.max(nRttEntries,nWttEntries);
} 

if (nXttEntries < 16) {
    var nLatencyCounters = nXttEntries;
} else {
    nLatencyCounters = 16 ;
}
%>
//Pmon 3.4 latency
<% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu")|| obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>

interface <%=obj.BlockId%>_latency_if;
   

int nLatencyCounters = <%=nLatencyCounters%>;
int nXttEntries     = <%=nXttEntries%>; 
int nWttEntries      = <%=nWttEntries%>;
int nRttEntries      = <%=nRttEntries%>;

logic clk;
logic rst_n;

logic div_clk_rtl;

bit div_en;
logic div_clk = 1'b0;
int div_cpt = 0;
bit [7:0] dut_latency_bins;
int latency_pre_scale;
bit [8:0] cnt_value;
bit [8:0] cnt_value_with_offset;
logic local_count_enable;
// write
logic [<%=nLatencyCounters%>-1:0] alloc;
logic [<%=nXttEntries%>-1:0] alloc_if;
int     alloc_id[<%=nLatencyCounters%>];

logic [<%=nLatencyCounters%>-1:0] dealloc;
logic [<%=nXttEntries%>-1:0] dealloc_if;
int     dealloc_id[<%=nLatencyCounters%>];

bit [8:0]   latency_cpt[<%=nLatencyCounters%>];
bit         start_count[<%=nLatencyCounters%>];


task automatic get_latency_signals(int latency_index);

    dealloc_id[latency_index]   = -1;
    alloc_id[latency_index]     = -1;

    forever begin
        alloc[latency_index] = 1'b0;
        dealloc[latency_index] = 1'b0;

        for (int i=latency_index; i < <%=nXttEntries%> ; i=i+16) begin

                if ((dealloc_if[i] == 1'b1) && (alloc_id[latency_index] == i)) begin
                    dealloc[latency_index]      = dealloc_if[i];
                    dealloc_id[latency_index]   = i;
                end
                else if ((dealloc_if[i] == 1'b1) && (alloc_if[alloc_id[latency_index]] == 1'b1)) begin

                    dealloc[latency_index]      = dealloc_if[i];
                end

                if ((alloc_if[i] == 1'b1) && (alloc_id[latency_index] == dealloc_id[latency_index])) begin
                    alloc[latency_index]        = alloc_if[i];
                    alloc_id[latency_index]     = i;
                    dealloc_id[latency_index]   = -1;
                end
                else if ((alloc_if[i] == 1'b1) && (dealloc_if[alloc_id[latency_index]] == 1'b1)) begin
                
                    alloc[latency_index]        = alloc_if[i];
                    alloc_id[latency_index]     = i;
                    dealloc_id[latency_index]   = -1;
                end

        end

        @(posedge clk);
        div_clk = div_clk_rtl;
        
    end

endtask : get_latency_signals


task automatic generate_clk_pulse();

    div_clk = 1'b1;
    div_cpt++;

    repeat(1) @(posedge clk) ;
    div_clk = 1'b0;

endtask : generate_clk_pulse
task automatic clk_div();


forever begin
 
    if(div_en) begin
        if (div_cpt % latency_pre_scale == latency_pre_scale-2) begin
            //generate_clk_pulse();
        end

        if( ! rst_n) begin
            div_cpt=0;
        end else begin
            div_cpt++;
        end


    end
    @(posedge clk); 

 

end

endtask : clk_div
endinterface

<% } %>
