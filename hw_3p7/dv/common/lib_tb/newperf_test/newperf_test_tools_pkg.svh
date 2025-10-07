///////////////////////////////////////////////////////////////////////////////
//
// New Performance test scrobarod only in case of full sys simulation
// to import in chi/ace or ioaiu env pkg 
////////////////////////////////////////////////////////////////////////////////
`ifndef NEWPERF_TEST_TOOLS_PKG
`define NEWPERF_TEST_TOOLS_PKG
package newperf_test_tools_pkg;
   `include "newperf_test_types.svh"
   `include "newperf_test_latency_tools.sv"
   `include "newperf_test_bw_tools.sv"
endpackage : newperf_test_tools_pkg
`endif
