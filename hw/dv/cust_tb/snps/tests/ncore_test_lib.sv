<%const chipletObj = obj.lib.getAllChipletRefs();%>

`include "ncore_seq_lib.sv"
`include "ncore_base_test.sv"
`include "ncore_sys_test.sv"
//`include "ncore_chi_directed_test.sv"
//`include "ncore_ace_directed_test.sv"
//`include "ncore_exclusive_access_test.sv"
//`include "ncore_snoop_test.sv"
//`include "ncore_atomic_test.sv"
//`include "ncore_cache_access_test.sv"
//`include "ncore_reg_wr_rd_test.sv"
//`include "ncore_ral_bit_bash_test.sv"
//`include "ncore_ral_reset_value_test.sv"
<%if(chipletObj[0].useResiliency == 1){%>
//`include "ncore_fsc_ral_bit_bash_test.sv"
//`include "ncore_fsc_ral_reset_value_test.sv"
//`include "ncore_fsc_ralgen_err_intr_test.sv"
//`include "ncore_fsc_Uncorr_Error_test.sv"
<%}%>
//`include "ncore_bandwidth_test.sv"
//`include "ncore_bandwidth_test_multi.sv"
//`include "ncore_connectivity_test.sv"
//`include "ncore_apb_debug_test.sv"
<%if(process.env.ENABLE_INTERNAL_CODE){%>
//`include "../sanity/ncore_memregions_override_test.sv"
<%}%>
