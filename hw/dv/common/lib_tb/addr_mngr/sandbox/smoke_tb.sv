// `timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
import mem_agent_pkg::*;

module smoke_tb;

    initial begin
        mem_agent     ma  = mem_agent::get();
        mem_agent_cfg cfg = ma.m_mem_cfg;
        ma.generate_memory_regions();
        ma.print_all_chiplets_region_table();
        $display("\nSmoke test complete.");
        $finish;
    end

endmodule: smoke_tb