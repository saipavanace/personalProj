
module tb_top();

import uvm_pkg::*;
`include "uvm_macros.svh"
import sv_assert_pkg::*;
import addr_trans_mgr_pkg::*;
import chi_bfm_types_pkg::*;
import chi_aiu_unit_args_pkg::*;
import chi_bfm_txn_pkg::*;
import chi_traffic_seq_lib_pkg::*;
import chi_container_pkg::*;

task test_cache_model();
  chi_cache_info m_info;
  bit [7:0] data[64];
  bit be[64];

  bit [7:0] act_data[64];
  bit       act_be[64];

  bit [128:0] m_16Bdata[4];
  bit [15:0]  m_16be;
  bit [255:0] m_32Bdata[2];
  bit [31:0]  m_32be;

  m_info = new();

  for (int i = 0; i < 64; ++i) begin
    data[i] = $urandom_range(0, 255);
    be[i] = 1;
    case ( int'(i / 16))
      0 : begin
        m_16Bdata[0] = m_16Bdata[0] >> 8;
        m_16Bdata[0][127:120] = data[i];
      end
      1 : begin
        m_16Bdata[1] = m_16Bdata[1] >> 8;
        m_16Bdata[1][127:120] = data[i];
      end
      2 : begin
        m_16Bdata[2] = m_16Bdata[2] >> 8;
        m_16Bdata[2][127:120] = data[i];
      end
      3 : begin
        m_16Bdata[3] = m_16Bdata[3] >> 8;
        m_16Bdata[3][127:120] = data[i];
      end
    endcase

    case ( int'(i / 32))
      0 : begin
        m_32Bdata[0] = m_32Bdata[0] >> 8;
        m_32Bdata[0][255:248] = data[i];
      end
      1 : begin
        m_32Bdata[1] = m_32Bdata[1] >> 8;
        m_32Bdata[1][255:248] = data[i];
      end
    endcase
  end

  m_16be = (1 << 16) - 1;
  m_32be = (1 << 32) - 1;
  
  act_data = m_info.get_cacheline_data();
  act_be   = m_info.get_cacheline_be();

  for (int i = 0; i < 64; ++i) begin
    string s;

    $sformat(s, "%s act_data:0x%0h ref_data:0x%0h act_be:0x%0h ref_be:0x%0h",
             s, act_data[i], data[i], act_be[i], be[i]);
    `ASSERT(act_data[i] == data[i] && act_be[i] == be[i], s);
  end
  `uvm_info("TEST1", "TEST PASSED", UVM_NONE)
endtask: test_cache_model

task test_chi_traffic_seq();

  chi_rn_traffic_cmd_seq m_seq;
  chi_aiu_unit_args          m_args;

  m_seq  = new("m_seq");
  m_args = new("m_args");

  m_seq.get_cmd_args(m_args);
  repeat (50) begin
    `ASSERT(m_seq.randomize());
    `uvm_info("TEST2", m_seq.convert2string(), UVM_NONE)
  end
  `uvm_info("TEST2", "TEST PASSED", UVM_NONE)
endtask: test_chi_traffic_seq


initial begin
  test_cache_model();
  test_chi_traffic_seq();
end


endmodule: tb_top
