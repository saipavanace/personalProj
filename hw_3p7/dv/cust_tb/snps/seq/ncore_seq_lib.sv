typedef bit[<%=obj.AiuInfo[0].wAddr%>-1:0] ncore_addr_t;
//Sequences
`include "ncore_chi_base_seq.sv"
`include "ncore_axi_base_seq.sv"
`include "ncore_axi_slave_mem_resp_seq.sv"
`include "ncore_svt_chi_rn_directed_snoop_resp_seq.sv"
`include "ncore_apb_debug_seq.sv"
`include "ncore_bit_bash_seq.sv"
//Virtual sequences
`include "ncore_base_vseq.sv"
`include "ncore_chi_directed_vseq.sv"
`include "ncore_ace_directed_vseq.sv"
`include "ncore_bandwidth_vseq.sv"
`include "ncore_bandwidth_multi_vseq.sv"
`include "ncore_cache_access_vseq.sv"
`include "ncore_connectivity_vseq.sv"
`include "ncore_snoop_vseq.sv"
`include "ncore_reg_wr_rd_vseq.sv"
`include "ncore_fsc_ralgen_err_intr_vseq.sv"
`include "ncore_apb_debug_vseq.sv"
// `include "ncore_partial_boot_vseq.sv"
<%if(obj.enInternalCode){%>
    `include "../.sanity/ncore_memregions_override_vseq.sv"
<%}%>
