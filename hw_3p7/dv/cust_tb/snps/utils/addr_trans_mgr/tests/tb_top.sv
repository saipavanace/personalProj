
//
//Unit test bench for Address Manager
//

module tb_top();

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import addr_trans_mgr_pkg::*;

  //
  //TEST-1 Generating Dynamic memory map
  //
  task test1();
    localparam int REPEAT_LOOP = 100;
    repeat (REPEAT_LOOP) begin 
      addr_trans_mgr m_mgr;
      m_mgr = addr_trans_mgr::get_instance();
      m_mgr.gen_memory_map();
      m_mgr.destruct_instance();
    end
  endtask: test1

  //
  //TEST-2 Generating addresses for static memory map
  //
  task test2();
    localparam int REPEAT_LOOP = 100;
    addr_trans_mgr m_mgr = addr_trans_mgr::get_instance();
    m_mgr.gen_memory_map();
    repeat (REPEAT_LOOP) begin
      $display("Addr: 0x%0h", m_mgr.get_coh_addr(1));
    end
  endtask: test2

  

  initial begin
    if ($test$plusargs("test1")) begin
      test1();
      $display("\n****SUCCESS****\n");
    end

    if ($test$plusargs("test2")) begin
      test2();
      $display("\n****SUCCESS****\n");
    end
  end

endmodule: tb_top
