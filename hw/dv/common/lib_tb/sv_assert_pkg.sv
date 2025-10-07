
//
// SV unit assertioins.
//

package sv_assert_pkg;

function void basic_assert(int v, string s);
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  if(!$test$plusargs("ASSERT_OFF"))
  begin
    if (!v) begin
      `ifndef INCA
         $stacktrace;
      `endif
      `uvm_fatal("FATAL", s)
    end
  end
endfunction: basic_assert

`define ASSERT(V, S="FAIL") basic_assert(``V``, ``S``)

endpackage: sv_assert_pkg


