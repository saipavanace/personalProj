`undef macro_perf_cnt_test_all_declarations
`define macro_perf_cnt_test_all_declarations \
      typedef bit unsigned [63:0] uint64_type;\
      const int nPerfCounters = <%=obj.nPerfCounters%>; // Number of perf counters instantiated within each unit  \
      bit perfmon_test = 1'b0;\
      uint64_type main_seq_iter=1;\
      bit smi_rx_stall_en;\
      bit force_axi_stall_en;\
    <%if((obj.testBench =="io_aiu")) {%> \
         <%=obj.BlockId%>_perf_cnt_units            perf_counters[<%=obj.DutInfo.nNativeInterfacePorts%>];\
         <%=obj.BlockId%>_perf_counters_scoreboard  m_perf_cnt_sb[<%=obj.DutInfo.nNativeInterfacePorts%>];\
    <%} else if ((obj.testBench =="dii")){%> \
      <%=obj.BlockId%>_perf_cnt_units            perf_counters;\
      <%=obj.BlockId%>_perf_cnt_unit_cfg_seq     perf_counter_seq;\
      <%=obj.BlockId%>_perf_cnt_enable_cfg_seq   perf_counter_enable_seq;\
       <%=obj.BlockId%>_perf_cnt_overflow_cfg_seq   perf_counter_overflow_seq;\
          <%=obj.BlockId%>_perf_cnt_read_status_seq   perf_counter_read_status_seq;\
      <%=obj.BlockId%>_perf_counters_scoreboard  m_perf_cnt_sb;\
    <%} else {%> \
      <%=obj.BlockId%>_perf_cnt_units            perf_counters;\
      <%=obj.BlockId%>_perf_cnt_unit_cfg_seq     perf_counter_seq;\
      <%=obj.BlockId%>_perf_counters_scoreboard  m_perf_cnt_sb;\
    <% } %> \
      virtual task main_seq_pre_hook(uvm_phase phase);      endtask \
      virtual task main_seq_post_hook(uvm_phase phase);     endtask \
      virtual task main_seq_iter_pre_hook(uvm_phase phase, uint64_type iter);  endtask \
      virtual task main_seq_iter_post_hook(uvm_phase phase, uint64_type iter); endtask \
      virtual task main_seq_hook_end_run_phase(uvm_phase phase); endtask \
      //Pmon 3.4 latency \
      <% if (obj.BlockId.includes("dii") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) { %> \
      <%=obj.BlockId%>_latency_counters_scoreboard  m_latency_cnt_sb; \
      <% } else if((obj.testBench =="io_aiu")) {%> \
              <%=obj.BlockId%>_latency_counters_scoreboard  m_latency_cnt_sb[<%=obj.DutInfo.nNativeInterfacePorts%>]; \
      <% } %> \


//END MACRO
