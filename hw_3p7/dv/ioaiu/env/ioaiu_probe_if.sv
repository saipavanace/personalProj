//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract:
 * Defines an interface that provides access to a internal signal of DUT .This
 */
<% 
  let nOttEntries = obj.AiuInfo[obj.Id].cmpInfo.nOttCtrlEntries;
  let nSttEntries = obj.AiuInfo[obj.Id].cmpInfo.nSttCtrlEntries;
%>

`ifndef GUARD_<%=obj.BlockId%>_PROBE_IF_SV
`define GUARD_<%=obj.BlockId%>_PROBE_IF_SV

import <%=obj.BlockId%>_smi_agent_pkg::*;

interface <%=obj.BlockId%>_probe_if (input clk,input resetn);

    parameter setup_time = 1;
    parameter hold_time  = 1;

    logic       IRQ_C                   ;
    logic       IRQ_UC                  ;
    logic       UCESR_ErrVld            ;
    logic       cesr_errvld             ;
    logic       cesar_errvld_en         ;
    logic       cesar_errvld            ;
    logic       cesr_err_cnt            ;
    logic       uesr_errvld             ;
    logic       ueir_timeout_irq_en     ;
    logic[3:0]  uesr_err_type           ;
    logic[15:0] uesr_err_info           ;
    logic       uedr_timeout_err_det_en ;
    logic       uesar_errvld_en         ;
    logic       uesar_errvld            ;
    logic       uesr_err_cnt            ; 
    logic       uncorr_mem_det_en       ;
    logic       uncorr_err_injected     ;
    logic       starv_evt_status        ;
    logic       TransActv		;
    logic       CCPReady		;
    int         global_counter          ;
    int         starv_threshold         ;
    logic       transport_det_en        ;
    logic       time_out_det_en         ;
    logic       prot_err_det_en         ;
    logic       mem_err_det_en		;
    longint cycle_counter;
    logic[<%=obj.wInitiatorId-1%>:0] cmux_dtw_rsp_initiator_id; 
    logic[7:0] cmux_dtw_rsp_cm_typ;
   logic[<%=obj.wInitiatorId-1%>:0] cmux_str_req_initiator_id;
   logic[7:0] cmux_str_req_cm_typ;
   logic[<%=obj.wInitiatorId-1%>:0] cmux_snp_req_initiator_id;
   logic[7:0] cmux_snp_req_cm_typ ;
   logic[<%=obj.wInitiatorId-1%>:0] cmux_cmp_rsp_initiator_id;
   logic[7:0] cmux_cmp_rsp_cm_typ ;
   logic[<%=obj.wInitiatorId-1%>:0] cmux_dtr_req_rx_initiator_id;
   logic[<%=obj.wInitiatorId-1%>:0] cmux_dtr_rsp_rx_initiator_id;
   logic[7:0] cmux_dtr_req_rx_cm_typ ;
   logic[7:0] cmux_dtr_rsp_rx_cm_typ ;
   logic [<%=obj.wInitiatorId-1%>:0] cmux_upd_rsp_initiator_id;
   logic[7:0] cmux_upd_rsp_cm_typ;
   logic [<%=obj.wInitiatorId-1%>:0] cmux_cmd_rsp_initiator_id;
   logic[7:0] cmux_cmd_rsp_cm_typ;
    bit snp_req_vld;
    <%=obj.BlockId%>_smi_agent_pkg::smi_addr_security_t snp_req_addr;
    bit [<%=nOttEntries%>-1 : 0] snp_req_match;
    bit [<%=nOttEntries%>-1 : 0] ott_owned_st;
    bit [<%=nOttEntries%>-1 : 0] ott_oldest_st;
    bit [<%=nOttEntries%>-1 : 0] ott_entries;
    bit [<%=nOttEntries%>-1 : 0] ott_overflow;
    bit [<%=nOttEntries%>-1 : 0] ott_security;
    bit [<%=nOttEntries%>-1 : 0] ott_prot;

    <%=obj.BlockId%>_smi_agent_pkg::smi_addr_t ott_address[<%=nOttEntries%>-1 : 0];
    bit [<%=obj.BlockId%>_axi_agent_pkg::WAXID-1:0] ott_id[<%=nOttEntries%>-1 : 0];
    //bit [<%=nOttEntries%>-1 : 0]                               ott_user[<%=nOttEntries%>-1 : 0];
    int                                                        ott_user[<%=nOttEntries%>-1 : 0];
    bit [<%=nOttEntries%>-1 : 0]                               ott_qos[<%=nOttEntries%>-1 : 0];
    bit [<%=nOttEntries%>-1 : 0]                               ott_write[<%=nOttEntries%>-1 : 0];
    bit [<%=nOttEntries%>-1 : 0]                               ott_evict[<%=nOttEntries%>-1 : 0];
    bit [3 : 0]                               		       ott_cache[<%=nOttEntries%>-1 : 0];

  <% if(obj.testBench =="io_aiu"){ %>
   <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>

   localparam OCN<%=i%> = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.OCN[31:0];
   localparam IW<%=i%> = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.IW[31:0];
   localparam AW<%=i%> = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.AW[31:0];

    logic  [OCN<%=i%> -1  : 0]  oc_val<%=i%>                       ;
    logic  [OCN<%=i%> -1  : 0]  oc_ovt<%=i%>                       ;
    logic  [AW<%=i%>  -1 :  0]  oc_addr<%=i%>[OCN<%=i%> -1  : 0]   ;
    logic  [IW<%=i%>-1    :0]   oc_id<%=i%> [OCN<%=i%>-1:0]		   ;
    logic  [OCN<%=i%> -1  : 0]  oc_security<%=i%>	           ;
    logic                       sv_ovt<%=i%>                       ;

   <%}%>
<%}%>

     <%if(obj.useCache){%>
            <% if(obj.testBench =="io_aiu") {%>
                <%for( var i=0;i<obj.nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                   bit bypass_bank<%=i%>; 
                <%}%>
             <%}%>
      <%}%>


    <%if(obj.assertOn && obj.testBench =="io_aiu"){%>
      <%if(obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") {%>
        localparam OCN = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.OCN[31:0];
        localparam IW = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.IW[31:0];
        localparam AW = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.AW[31:0];
        localparam OLA = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.OLA[31:0];
        
       	<%if(obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].MemType == "NONE") {%>
        localparam DATA_WIDTH = tb_top.dut.OttMem0.internal_mem_inst.DATA_WIDTH[31:0];
        <%} else if(obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].MemType == "SYNOPSYS") {%>
        localparam DATA_WIDTH = tb_top.dut.OttMem0.external_mem_inst.internal_mem_inst.DATA_WIDTH[31:0];
         <%}%>

        bit[5:0] mem_err_index;
        bit sngl_nxt, dbl_nxt, chip_en, wr_en;
        logic[IW-1:0] oc_id [OCN-1:0];
        logic[AW-1:0] oc_addr[OCN-1:0];
        logic[OLA-1:0] oc_dptr [OCN-1:0];
      <%}%>
        
    <%}%>
        <%if(obj.AiuInfo[obj.Id].cmpInfo.nSttCtrlEntries > 0) {%>
        //localparam STN = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.STN;
        logic[<%=nSttCtrlEntries%>-1:0]	q_st_val;
        bit concerto_mux_fifo_full;
        <% } %>

      
        <%if(obj.assertOn){%>
        <% if(obj.testBench =="io_aiu") {%>
        <%if(obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") {%>
        <%for( var i=0;i< (obj.nOttDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>

        bit[DATA_WIDTH -1 :0] error_data<%=i%>;
        bit[32:0] single_error_count<%=i%>;
        bit[32:0] double_error_count<%=i%>;

        <%}%>
        <%}%>
        <%}%>
    <%}%>


    <%if(obj.useResiliency){%>
        logic       fault_mission_fault     ;
        logic       fault_latent_fault      ;
        logic[9:0]  cerr_threshold          ;
        logic[15:0] cerr_counter            ;
        logic       cerr_over_thres_fault   ;
    <%}%>

      <% if(obj.testBench =="io_aiu") {%>
      	<%for( var i=0;i< obj.DutInfo.nNativeInterfacePorts;i++){%>
        logic str_req_valid_<%=i%>;
	logic dtw_dbg_rsp_valid_<%=i%>;
	logic sys_rsp_valid_<%=i%>;
        logic cmd_rsp_valid_<%=i%>;
        logic upd_rsp_valid_<%=i%>;
        logic dtw_rsp_valid_<%=i%>;
        logic dtr_rsp_valid_<%=i%>;
        logic cmp_rsp_valid_<%=i%>;
        logic dtr_req_valid_<%=i%>;
        logic snp_req_valid_<%=i%>;
        logic sys_req_valid_<%=i%>;

        logic str_req_ready_<%=i%>;
	logic dtw_dbg_rsp_ready_<%=i%>;
	logic sys_rsp_ready_<%=i%>;
        logic cmd_rsp_ready_<%=i%>;
        logic upd_rsp_ready_<%=i%>;
        logic dtw_rsp_ready_<%=i%>;
        logic cmp_rsp_ready_<%=i%>;
        logic dtr_rsp_ready_<%=i%>;
        logic dtr_req_ready_<%=i%>;
        logic snp_req_ready_<%=i%>;
        logic sys_req_ready_<%=i%>;

      <%}%>
      <%for( var i=0;i< obj.DutInfo.nNativeInterfacePorts;i++){%>
        <% for (var j=0; j<obj.nDCEs; j++) {%>
        bit [2:0] XAIUCCR<%=j%>_DCECounterState_<%=i%>;
        <%}%>
        <% for (var j=0; j<obj.nDMIs; j++) {%>
        bit [2:0] XAIUCCR<%=j%>_DMICounterState_<%=i%>;
        <%}%>
        <% for (var j=0; j<obj.nDIIs; j++) {%>
        bit [2:0] XAIUCCR<%=j%>_DIICounterState_<%=i%>;
        <%}%>
	  <%}%>
    <%}%>

    <%if(obj.assertOn){%>
        var ottIdx;
        <% if(obj.testBench =="io_aiu") {%>
        <%if(obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") {%>
            <%for( var i=0;i< (obj.nOttDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                logic   inject_ott_single_next<%=i%>                    ;
                logic   inject_ott_double_next<%=i%>                    ;
                logic   inject_ott_single_double_multi_blk_next<%=i%>   ;
                logic   inject_ott_double_multi_blk_next<%=i%>          ;
                logic   inject_ott_single_multi_blk_next<%=i%>          ;
                logic   inject_ott_addr_next<%=i%>			;
            <%}%>
        <%}%>
           <%if(obj.AiuInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
            <%for( var i=0;i<=(obj.AiuInfo[obj.Id].ccpParams.nRPPorts * obj.DutInfo.nNativeInterfacePorts);i++){%>
                logic   inject_plru_single_next<%=i%>                    ;
                logic   inject_plru_double_next<%=i%>                    ;
                logic   inject_plru_addr_next<%=i%>			;
          <%}%>
          <%}%>
        <%}%>
    <%}%>
    <%if(obj.assertOn){%>
        <%if(obj.useCache){%>
            <% if(obj.testBench =="io_aiu") {%>
            <%if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") {%>
                <%for( var i=0;i<obj.nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                    logic   inject_tag_single_next<%=i%>                    ;
                    logic   inject_tag_double_next<%=i%>                    ;
                    logic   inject_tag_single_double_multi_blk_next<%=i%>   ;
                    logic   inject_tag_double_multi_blk_next<%=i%>          ;
                    logic   inject_tag_single_multi_blk_next<%=i%>          ;
                    logic   inject_tag_addr_next<%=i%>		            ;
                <%}%>
            <%}%>
           
            <%if(obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY") {%>
                <%for(var i=0;i<obj.nDataBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                    logic   inject_data_single_next<%=i%>                   ;
                    logic   inject_data_double_next<%=i%>                   ;
                    logic   inject_data_single_double_multi_blk_next<%=i%>  ;
                    logic   inject_data_double_multi_blk_next<%=i%>         ;
                    logic   inject_data_single_multi_blk_next<%=i%>         ;
                    logic   inject_data_addr_next<%=i%>		            ;
                <%}%>
            <%}%>
        <%}%>
     <%}%>
    <%}%>

    clocking monitor_cb @(negedge clk);

        default input #setup_time output #hold_time;
    endclocking:monitor_cb

    <%if(obj.assertOn && 
        (typeof obj.AiuInfo[obj.Id].MemoryGeneration.ottMem !== 'undefined')){%>
         <% if(obj.testBench =="io_aiu") {%>
        <%if(obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") {%>
        <%if(obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].MemType != "SYNOPSYS"){%>
          <%for( var i=0;i<(obj.nOttDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
              assign inject_ott_single_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_NEXT;
              assign inject_ott_double_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_NEXT;
              assign inject_ott_single_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
              assign inject_ott_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
              assign inject_ott_single_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
              assign inject_ott_addr_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_ADDR_NEXT;
          <%}%>
        <%} else if(obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].MemType == "SYNOPSYS"){%>
          <%for( var i=0;i< (obj.nOttDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
              assign inject_ott_single_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT;
              assign inject_ott_double_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_NEXT;
              assign inject_ott_single_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
              assign inject_ott_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
              assign inject_ott_single_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
	      assign inject_ott_addr_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_ADDR_NEXT;
          <%}%>
        <% } %>
        <%}%>
        <%if(obj.AiuInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
        <%if(obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[0].MemType != "SYNOPSYS"){%>
          <%for( var i=0;i<=(obj.AiuInfo[obj.Id].ccpParams.nRPPorts  * obj.DutInfo.nNativeInterfacePorts);i++){%>
              assign inject_plru_single_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_NEXT;
              assign inject_plru_double_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_NEXT;
              assign inject_plru_addr_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_ADDR_NEXT;
        <% } %>
        <%} else if(obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[0].MemType == "SYNOPSYS"){%>
          <%for( var i=0;i<= (obj.AiuInfo[obj.Id].ccpParams.nRPPorts  * obj.DutInfo.nNativeInterfacePorts);i++){%>
              assign inject_plru_single_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT;
              assign inject_plru_double_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_NEXT;
              assign inject_plru_addr_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_ADDR_NEXT;
        <%}%>
        <%}%>
        <%}%>
        <%}%>
      
       <% if(obj.testBench =="io_aiu") {%>
        <%for( var i=0;i<obj.DutInfo.nNativeInterfacePorts;i++){%>
        assign str_req_valid_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_str_req_valid;
        assign cmd_rsp_valid_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_cmd_rsp_valid;
        assign upd_rsp_valid_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_upd_rsp_valid;
        assign dtw_rsp_valid_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_dtw_rsp_valid;
        assign dtr_rsp_valid_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_dtr_rsp_rx_valid;
        assign dtr_req_valid_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_dtr_req_rx_valid;
        assign snp_req_valid_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_snp_req_valid;

       
        assign cmd_rsp_ready_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_cmd_rsp_ready ;
        assign upd_rsp_ready_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_upd_rsp_ready;
        assign dtw_rsp_ready_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_dtw_rsp_ready;
        assign dtr_rsp_ready_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_dtr_rsp_rx_ready;
        assign dtr_req_ready_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_dtr_req_rx_ready;
        assign snp_req_ready_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_snp_req_ready;
        assign str_req_ready_<%=i%> = tb_top.dut.ioaiu_core_wrapper.req_rsp_mux.out_rsp_<%=i%>_str_req_ready;
        <%}%>
        <%}%>


        <%if(obj.useCache){%>
             <% if(obj.testBench =="io_aiu") {%>
            <%for( var i=0;i<obj.nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                <%if(obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].MemType != "SYNOPSYS"){%>
                    assign inject_tag_single_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_NEXT;
                    assign inject_tag_double_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_NEXT;
                    assign inject_tag_single_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
                    assign inject_tag_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
                    assign inject_tag_single_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
                    assign inject_tag_addr_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_ADDR_NEXT;
                 <%} else if(obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].MemType == "SYNOPSYS") {%>
                    assign inject_tag_single_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT;
                    assign inject_tag_double_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_NEXT;
                    assign inject_tag_single_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
                    assign inject_tag_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
                    assign inject_tag_single_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
                    assign inject_tag_addr_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_ADDR_NEXT;
    
                 <%}%>
                 <%}%>
                 <%}%>
            <% if(obj.testBench =="io_aiu") {%> 
            <%for(var i=0;i<obj.nDataBanks * obj.DutInfo.nNativeInterfacePorts;i++){%> 
                <%if(obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].MemType != "SYNOPSYS") {%>
                    assign inject_data_single_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_NEXT;
                    assign inject_data_double_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_NEXT;
                    assign inject_data_single_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
                    assign inject_data_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
                    assign inject_data_single_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
                    assign inject_data_addr_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_ADDR_NEXT;
                <%} else if(obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].MemType  == "SYNOPSYS") {%>
                   assign inject_data_single_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT;
                    assign inject_data_double_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_NEXT;
                    assign inject_data_single_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
                    assign inject_data_double_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
                    assign inject_data_single_multi_blk_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
        	    assign inject_data_addr_next<%=i%> = dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_ADDR_NEXT;

           <%}%>
       <%}%>
       <%}%>
     <%}%>
    <%}%>


 

    //assign UCESR_ErrVld = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUCESR_ErrVld_out;

    <%if(obj.assertOn && obj.testBench =="io_aiu"){%>
      <%if(obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") {%>
    		<%if(obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].MemType == "NONE") {%>
            	assign mem_err_index = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].rtlPrefixString%>.internal_mem_inst.address;
        		assign sngl_nxt          = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_NEXT;
        		assign dbl_nxt 		 = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_NEXT;
        		assign chip_en           = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].rtlPrefixString%>.internal_mem_inst.chip_enable;
        		assign wr_en 		 = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].rtlPrefixString%>.internal_mem_inst.write_enable;
  		    <%} else if(obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].MemType == "SYNOPSYS") {%>
            	assign mem_err_index = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.address;
        		assign sngl_nxt          = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT;
        		assign dbl_nxt 		 = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_NEXT;
        		assign chip_en 		 = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.chip_enable;
        		assign wr_en 		 = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.write_enable;
            <%}%>


      <%}%>
    <%}%>

      <%if(obj.assertOn && obj.testBench =="io_aiu"){%>
      <%if(obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") {%>
    		<%if(obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].MemType == "NONE") {%>
                        <%for( var i=0;i< (obj.nOttDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                        assign error_data<%=i%>        =  tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.Q ;
             		assign single_error_count<%=i%> = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.SINGLE_ERROR_COUNT;
                        assign double_error_count<%=i%> = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.DOUBLE_ERROR_COUNT;
  		        <%}%>
                <%} else if(obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[0].MemType == "SYNOPSYS") {%>
                       <%for( var i=0;i< (obj.nOttDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                        assign error_data<%=i%>        =  tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.Q ;
             		assign single_error_count<%=i%> = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.SINGLE_ERROR_COUNT;
                        assign double_error_count<%=i%> = tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.DOUBLE_ERROR_COUNT;
            <%}%>

      <%}%>
    <%}%>
    <%}%>

   
      <%if( obj.testBench !="fsys"){%>
    assign TcapBusy  = tb_top.dut.ioaiu_core_wrapper.trace_capture_busy;
    <%}%>

    <%if(obj.AiuInfo[obj.Id].cmpInfo.nSttCtrlEntries > 0) {%>
      <%if( obj.testBench =="fsys"){%>
    assign concerto_mux_fifo_full = tb_top.dut.<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.ioaiu_core_wrapper.concerto_mux.snp_req_fifo.fifo.full;
      <%if( obj.orderedWriteObservation == true){%>
    assign q_st_val               = tb_top.dut.<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.stt.stt_valid;
      <%} else {%>
    assign q_st_val               = tb_top.dut.<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.t_st_val;
      <%}%>
      <%} else {%>
    assign concerto_mux_fifo_full = tb_top.dut.ioaiu_core_wrapper.concerto_mux.snp_req_fifo.fifo.full;
      <%if( obj.orderedWriteObservation == true){%>
    assign q_st_val               = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.stt.stt_valid;
      <%} else {%>
    assign q_st_val               = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.t_st_val;
      <%}%>
      <%}%>
    <% } %>
/*
    assign TransActv = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.t_pma_busy;
    <%if(obj.useCache){%>
        assign CCPReady = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ccp_top.init_done; // CCP ready, indicating that Tag and Data Memory are initialized
    <%}%>

    <%if(obj.assertOn){%>
        <%if(obj.useCache){%>
            <%if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED") || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY" || (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")){%>
                assign cesr_errvld = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUCESR_ErrVld_out;
                assign cesar_errvld_en = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUCESR_ErrVld_wr;
                assign cesar_errvld = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUCESR_ErrVld_in;
                assign cesr_err_cnt = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUCECR_ErrDetEn_out & tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.cerrs_o[0];
                assign uesr_errvld = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUUESR_ErrVld_out;
                assign uesar_errvld_en = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUUESR_ErrVld_wr;
                assign uesar_errvld = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUUESR_ErrVld_in;
                assign uesr_err_cnt = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUUEDR_MemErrDetEn_out & tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.uerrs_o[0];
                assign uncorr_mem_det_en = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUUEDR_MemErrDetEn_out;

                always @(posedge clk) begin
                    if(uncorr_mem_det_en === 1 && uesr_errvld === 1)
                        uncorr_err_injected = 1;
                end

                property assert_corrErrInjWhileSoftwareWriteHappens;                                                
                    @(posedge clk) disable iff (~resetn) ((!cesr_errvld & cesar_errvld_en & !cesar_errvld & cesr_err_cnt) |=> !cesr_errvld); 
                endproperty

                property assert_uncorrErrInjWhileSoftwareWriteHappens;                                                
                    @(posedge clk) disable iff (~resetn) ((!uesr_errvld & uesar_errvld_en & !uesar_errvld & uesr_err_cnt) |=> !uesr_errvld); 
                endproperty
                
                assertcorrErrInjWhileSoftwareWriteHappens : assert property (assert_corrErrInjWhileSoftwareWriteHappens) else 
                                                            `uvm_error("IO-AIU_PROBE_IF",$sformatf(" UCESR_ErrVld bit not cleared  "));

                assertuncorrErrInjWhileSoftwareWriteHappens : assert property (assert_uncorrErrInjWhileSoftwareWriteHappens) else 
                                                            `uvm_error("IOAIU_PROBE_IF",$sformatf(" CAIUUESR_ErrVld bit not cleared  "));
            <%}%>
        <%}%>
    <%}%>

     */

    initial begin
	cycle_counter 	 <= 0;
   	forever begin
        @(monitor_cb)
        cycle_counter 		<= cycle_counter + 1;
	end
    end

<%if(obj.AiuInfo[obj.Id].cmpInfo.nSttCtrlEntries > 0) {%>
    property stt_full(q_st_val, concerto_mux_fifo_full);
    @(posedge clk) disable iff(!resetn)
      <% if (nSttCtrlEntries <= 16) { %>
        ($countones(q_st_val)) == <%=nSttCtrlEntries%>;
      <% } else { %>
        concerto_mux_fifo_full == 1;
      <% } %>
    endproperty: stt_full
    
    COVER_stt_full: cover property(stt_full(q_st_val, concerto_mux_fifo_full));
<% } %>

function longint get_cycle_count();
	return cycle_counter;
endfunction: get_cycle_count


     //#Check.IOAIU.EOT.TransActv
      property assert_transActv_initial;
        @(posedge clk) $rose(resetn) |-> !TransActv;
    endproperty

    <%if(!obj.useCache){%>
        assertTransactvInitialcheck: assert property (assert_transActv_initial) else
                                    `uvm_error("IO-AIU_PROBE_IF",$sformatf(" TransActv signal reset value is not zero  "));
    <%}%>
   
endinterface

`endif // GUARD_<%=obj.BlockId%>_PROBE_IF_SV

/*
<%/*=JSON.stringify(obj,null,3)*/%>
*/
