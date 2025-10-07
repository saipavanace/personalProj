
`timescale 1 ns/1 ps

module tb_top();

    import uvm_pkg::*;
    `include "uvm_macros.svh"

//Import ccp env & tests
import ccp_test_pkg::*;
import <%=obj.BlockId%>_ccp_env_pkg::*;
    /** Parameter defines the clock frequency */

    parameter simulation_period = 10;
    parameter NO_OF_WAYS        = <%=obj.nWays%>; 
    bit [NO_OF_WAYS-1:0] nru_counter;

    int k_prob_iocache_single_bit_tag_error;
    int k_prob_iocache_single_bit_data_error;
    
    int k_prob_iocache_double_bit_tag_error;
    int k_prob_iocache_double_bit_data_error;

    /** Signal to generate the clock */
    bit sysclk;

    /** reinit wire */
    wire              u_reinit;
    wire              u_init_done;
    wire              u_corr_en;
    wire              u_uncorr_en;
    wire              u_tag_init_done;
    wire              u_ccp_csr_maint_req_array_sel;
    wire [257:0]      u_datamem_int_data_out;
    wire              u_datamem_int_write_en;
    wire              u_datamem_int_chip_en;
    wire [6:0]        u_datamem_int_address;
    wire [257:0]      u_datamem_int_data_in;
    wire [319:0]      u_tagmem_int_data_out;
    wire              u_tagmem_int_write_en;
    wire              u_tagmem_int_chip_en;
    wire [2:0]        u_tagmem_int_address;
    wire [319:0]      u_tagmem_int_data_in;
    wire [319:0]      u_tagmem_int_write_en_mask;
    uvm_event         init_done;

    /** Signal to generate the rst */
    bit sys_rstn;

    <%=obj.BlockId%>_ccp_if  u_ccp_if( .clk(sysclk),.rst_n(sys_rstn)); 


 <%=obj.moduleName%> dut (  
    //CCP DUT
        .clk                              ( sysclk                        ) ,
        .reset_n                          ( sys_rstn                      ) ,
        .ctrl_op_valid_p0                 ( u_ccp_if.ctrlop_vld           ) ,
        .ctrl_op_address_p0               ( u_ccp_if.ctrlop_addr          ) ,
        .ctrl_op_security_p0              ( u_ccp_if.ctrlop_security      ) ,
        .ctrl_op_allocate_p2              ( u_ccp_if.ctrlop_allocate      ) ,
        .ctrl_op_read_data_p2             ( u_ccp_if.ctrlop_rd_data       ) ,
        .ctrl_op_write_data_p2            ( u_ccp_if.ctrlop_wr_data       ) ,
        .ctrl_op_port_sel_p2              ( u_ccp_if.ctrlop_port_sel      ) ,
        .ctrl_op_bypass_p2                ( u_ccp_if.ctrlop_bypass        ) ,
        .ctrl_op_rp_update_p2             ( u_ccp_if.ctrlop_rp_update     ) ,
        .ctrl_op_tag_state_update_p2      ( u_ccp_if.ctrlop_tagstateup    ) ,
        .ctrl_op_state_p2                 ( u_ccp_if.ctrlop_state         ) ,
        .ctrl_op_burst_len_p2             ( u_ccp_if.ctrlop_burstln       ) ,
        .ctrl_op_setway_debug_p2          ( u_ccp_if.ctrlop_setway_debug  ) ,
        .ctrl_op_ways_busy_vec_p2         ( u_ccp_if.ctrlop_waybusy_vec   ) ,
        .ctrl_op_ways_stale_vec_p2        ( u_ccp_if.ctrlop_waystale_vec  ) ,
    //    .ctrl_op_cancel_p2                ( u_ccp_if.ctrlop_cancel        ) ,
        .ctrl_wr_valid                    ( u_ccp_if.ctrl_wr_vld          ) ,
        .ctrl_wr_data                     ( u_ccp_if.ctrl_wr_data         ) ,
        .ctrl_wr_byte_en                  ( u_ccp_if.ctrl_wr_byte_en      ) ,
        .ctrl_wr_beat_num                 ( u_ccp_if.ctrl_wr_beat_num     ) ,
        .ctrl_wr_last                     ( u_ccp_if.ctrl_wr_last         ) ,
        .cache_wr_ready                   ( u_ccp_if.cache_wr_rdy         ) ,
        .ctrl_fill_data_valid             ( u_ccp_if.ctrl_filldata_vld    ) ,
        .ctrl_fill_data                   ( u_ccp_if.ctrl_fill_data       ) ,
        .ctrl_fill_data_id                ( u_ccp_if.ctrl_filldata_id     ) ,
        .ctrl_fill_data_address           ( u_ccp_if.ctrl_filldata_addr   ) ,
     <% if(obj.nWays>1) { %>
        .ctrl_fill_data_way_num           ( u_ccp_if.ctrl_filldata_wayn   ) ,
     <% } %>
        .ctrl_fill_data_beat_num          ( u_ccp_if.ctrl_filldata_beatn  ) ,
        .ctrl_fill_valid                  ( u_ccp_if.ctrl_fill_vld        ) ,
        .ctrl_fill_address                ( u_ccp_if.ctrl_fill_addr       ) ,
     <% if(obj.nWays>1) { %>
        .ctrl_fill_way_num                ( u_ccp_if.ctrl_fill_wayn       ) ,
     <% } %>
        .ctrl_fill_state                  ( u_ccp_if.ctrl_fill_state      ) ,
        .ctrl_fill_security               ( u_ccp_if.ctrl_fill_security   ) ,
        .cache_evict_ready                ( u_ccp_if.cache_evict_rdy      ) ,
        .cache_rdrsp_ready                ( u_ccp_if.cache_rdrsp_rdy      ) ,
        .CorrErrDetectEn                  ( u_corr_en                     ) ,
        .UnCorrErrDetectEn                ( u_uncorr_en                   ) ,
        .reinit                           ( u_reinit                      ) ,
        .maint_req_opcode                 ( u_ccp_if.maint_req_opcode     ) ,
        .maint_req_data                   ( u_ccp_if.maint_read_data      ) ,
        .maint_req_way                    ( u_ccp_if.maint_req_way        ) ,
        .maint_req_entry                  ( u_ccp_if.maint_req_entry      ) ,
        .maint_req_word                   ( u_ccp_if.maint_req_word       ) ,
        .maint_req_array_sel              ( u_reinit ? u_ccp_csr_maint_req_array_sel : u_ccp_if.maint_req_array_sel  ) ,
        .cache_op_ready_p0                ( u_ccp_if.cacheop_rdy          ) ,
        .cache_valid_p2                   ( u_ccp_if.cache_vld            ) ,
        .cache_current_state_p2           ( u_ccp_if.cache_currentstate   ) ,
     <% if(obj.nWays>1) { %>
        .cache_alloc_way_vec_p2           ( u_ccp_if.cache_alloc_wayn     ) ,
        .cache_hit_way_vec_p2             ( u_ccp_if.cache_hit_wayn       ) ,
     <% } %>
        .cache_evict_valid_p2             ( u_ccp_if.cachectrl_evict_vld  ) ,
        .cache_evict_address_p2           ( u_ccp_if.cache_evict_addr     ) ,
        .cache_evict_security_p2          ( u_ccp_if.cache_evict_security ) ,
        .cache_evict_state_p2             ( u_ccp_if.cache_evict_state    ) ,
        .cache_nack_uce_p2                ( u_ccp_if.cache_nack_uce       ) ,
        .cache_nack_p2                    ( u_ccp_if.cache_nack           ) ,
        .cache_nack_ce_p2                 ( u_ccp_if.cache_nack_ce        ) ,
        .cache_nack_no_allocate_p2        ( u_ccp_if.cache_nack_noalloc   ) ,
        .cache_fill_data_ready            ( u_ccp_if.cache_filldata_rdy   ) ,
        .cache_fill_ready                 ( u_ccp_if.cache_fill_rdy       ) ,
        .cache_fill_done                  ( u_ccp_if.cache_fill_done      ) ,
        .cache_fill_done_id               ( u_ccp_if.cache_fill_done_id   ) ,
        .cache_evict_valid                ( u_ccp_if.cache_evict_vld      ) ,
        .cache_evict_data                 ( u_ccp_if.cache_evict_data     ) ,
        .cache_evict_byteen               ( u_ccp_if.cache_evict_byten    ) ,
        .cache_evict_last                 ( u_ccp_if.cache_evict_last     ) ,
        .cache_evict_cancel               ( u_ccp_if.cache_evict_cancel   ) ,
        .cache_rdrsp_valid                ( u_ccp_if.cache_rdrsp_vld      ) ,
        .cache_rdrsp_data                 ( u_ccp_if.cache_rdrsp_data     ) ,
        .cache_rdrsp_byteen               ( u_ccp_if.cache_rdrsp_byten    ) ,
        .cache_rdrsp_last                 ( u_ccp_if.cache_rdrsp_last     ) ,
        .cache_rdrsp_cancel               ( u_ccp_if.cache_rdrsp_cancel   ) ,
        .init_done                        ( u_init_done                   ) ,
        .maint_active                     ( u_ccp_if.maint_active         ) ,
        .maint_read_data                  ( u_ccp_if.maint_read_data      ) ,
        .maint_read_data_en               ( u_ccp_if.maint_read_data_en   ) ,
        .correctible_error_valid          (                               ) ,
        .correctible_error_type           (                               ) ,
        .correctible_error_info           (                               ) ,
        .correctible_error_entry          (                               ) ,
     <% if(obj.nWays>1) { %>
        .correctible_error_way            (                               ) ,
     <% } %>
        .correctible_error_word           (                               ) ,
        .correctible_error_double_error   (                               ) ,
        .correctible_error_addr_hi        (                               ) ,
        .uncorrectible_error_valid        (                               ) ,
        .uncorrectible_error_type         (                               ) ,
        .uncorrectible_error_info         (                               ) ,
        .uncorrectible_error_entry        (                               ) ,
     <% if(obj.nWays>1) { %>
        .uncorrectible_error_way          (                               ) ,
     <% } %>
        .uncorrectible_error_word         (                               ) ,
        .uncorrectible_error_double_error (                               ) ,
        .uncorrectible_error_addr_hi      (                               ) ,
        .DataMem00_int_data_out           ( u_datamem_int_data_out        ) ,
        .DataMem00_int_write_en           ( u_datamem_int_write_en        ) ,
        .DataMem00_int_chip_en            ( u_datamem_int_chip_en         ) ,
        .DataMem00_int_address            ( u_datamem_int_address         ) ,
        .DataMem00_int_data_in            ( u_datamem_int_data_in         ) ,
     <% if(obj.RepPolicy === "PLRU") { %>
        .plru_mem0_write_data             (                               ) ,
        .plru_mem0_write_addr             (                               ) ,
        .plru_mem0_write_en               (                               ) ,
        .plru_mem0_read_data              (                               ) ,
        .plru_mem0_read_addr              (                               ) ,
        .plru_mem0_read_en                (                               ) ,
     <% } %>
        .TagMem00_int_write_en_mask       ( u_tagmem_int_write_en_mask    ) ,
        .TagMem00_int_data_out            ( u_tagmem_int_data_out         ) ,
        .TagMem00_int_write_en            ( u_tagmem_int_write_en         ) ,
        .TagMem00_int_chip_en             ( u_tagmem_int_chip_en          ) ,
        .TagMem00_int_address             ( u_tagmem_int_address          ) ,
        .TagMem00_int_data_in             ( u_tagmem_int_data_in          ) ,
        .data_init_done                   (                               ) ,
        .tag_init_done                    ( u_tag_init_done               ) ,
        .ctrl_fill_data_byteen            ( u_ccp_if.ctrl_filldata_byten  ) ,
        .ctrl_fill_data_last              ( u_ccp_if.ctrl_filldata_last   ) ,
        .cache_current_nru_vec_p2         (                               ) ,
        .ctrl_op_burst_wrap_p2            (                               ) ,
        .trans_active                     (                               )
    );


    dmi_datamem_em_mem_external_a ccp_data_mem (
        .clk          (sysclk),
        .cg_test_en   (1'b0),
        .int_data_in  (u_datamem_int_data_in),
        .int_data_out (u_datamem_int_data_out),
        .int_address  (u_datamem_int_address),
        .int_write_en (u_datamem_int_write_en),
        .int_chip_en  (u_datamem_int_chip_en)
    );

    dmi_tagmem_em_mem_external_a ccp_tag_mem (
        .clk               (sysclk),
        .cg_test_en        (1'b0),
        .int_data_in       (u_tagmem_int_data_in),
        .int_data_out      (u_tagmem_int_data_out),
        .int_address       (u_tagmem_int_address),
        .int_write_en      (u_tagmem_int_write_en),
        .int_chip_en       (u_tagmem_int_chip_en),
        .int_write_en_mask (u_tagmem_int_write_en_mask)
    );

    initial begin
        init_done = new("init_done");
        uvm_config_db#(uvm_event)::set(.cntxt(uvm_root::get()),
                                        .inst_name( "*" ),
                                        .field_name( "init_done" ),
                                        .value( init_done));
        uvm_config_db#(virtual <%=obj.BlockId%>_ccp_if)::set(.cntxt( uvm_root::get() ),
                                                             .inst_name( "" ),
                                                             .field_name( "u_ccp_if" ),
                                                             .value( u_ccp_if ));
    end


    initial begin
        sysclk = 0 ;
        forever begin
            #(simulation_period/2)
            sysclk = ~sysclk ;
        end
    end

    initial begin
      `ifdef DUMP_ON
        if ($test$plusargs("en_dump")) begin
            $vcdpluson;
        end
      `endif
        run_test("ccp_bring_up_test");
        $finish;
    end

    initial begin
        sys_rstn = 0;
        #100
        sys_rstn = 1;
    end
//----------------------------------------------
// Enabling  correctable or uncorrectable error
//---------------------------------------------- 
   reg correrr_en,uncorrerr_en;
 
    assign u_corr_en   = correrr_en;
    assign u_uncorr_en = uncorrerr_en;

   initial  begin
     static string fnerrdetectcorrect = "<%=obj.fnErrDetectCorrect%>";

     if ($test$plusargs("correrr_en")) begin
        correrr_en = 1; 
     end else begin
        correrr_en = 0; 
     end 
     if ($test$plusargs("uncorrerr_en")) begin
        uncorrerr_en = 1; 
     end else begin
        uncorrerr_en = 0; 
     end 
//----------------------------------------------
// Error Injection logic
//---------------------------------------------- 

   <% if(obj.isBridgeInterface && obj.useIoCache){%>
        
        if(!($value$plusargs("k_prob_iocache_single_bit_tag_error=%d",k_prob_iocache_single_bit_tag_error))) begin
            k_prob_iocache_single_bit_tag_error = 10;
        end

        if(!($value$plusargs("k_prob_iocache_single_bit_data_error=%d",k_prob_iocache_single_bit_data_error))) begin
            k_prob_iocache_single_bit_data_error = 5;
        end

        if(!($value$plusargs("k_prob_iocache_double_bit_tag_error=%d",k_prob_iocache_double_bit_tag_error))) begin
            k_prob_iocache_double_bit_tag_error = 20;
        end

        if(!($value$plusargs("k_prob_iocache_double_bit_data_error=%d",k_prob_iocache_double_bit_data_error))) begin
            k_prob_iocache_double_bit_data_error = 25;
        end

       if($test$plusargs("iocache_single_bit_error_test") &&
           ((fnerrdetectcorrect == "SECDED") || 
            (fnerrdetectcorrect == "SECDED64BITS") || 
            (fnerrdetectcorrect == "SECDED128BITS"))
        ) begin

        <%
        var num_SysCacheline = Math.pow(2, obj.wCacheLineOffset);
        var numDataBeats  = ((num_SysCacheline*8)/obj.wMasterData); 
        %>
        <%for( var i=0;i<nDataBanks;i++){%>
      //      ccp_tb_top.dut.mem.data_mem<%=i%>.internal_mem_inst.inject_errors(<%=i%>+k_prob_iocache_single_bit_data_error,0,0);
        <%}%>

        <%for( var i=0;i<nTagBanks;i++){%>
    //        ccp_tb_top.dut.mem.mem<%=i%>.internal_mem_inst.inject_errors(k_prob_iocache_single_bit_tag_error,0,0);
        <%}%>
    end 
    
    if ($test$plusargs("iocache_double_bit_data_error_test") && 
        ((fnerrdetectcorrect == "SECDED") || 
        (fnerrdetectcorrect == "SECDED64BITS") || 
        (fnerrdetectcorrect == "SECDED128BITS") 
        )) begin
        <%
        var num_SysCacheline = Math.pow(2, obj.wCacheLineOffset);
        var numDataBeats  = ((num_SysCacheline*8)/obj.wMasterData); 
        %>
        <%for( var i=0;i<nDataBanks;i++){%>
     //      ccp_tb_top.dut.mem.data_mem<%=i%>.internal_mem_inst.inject_errors(<%=i%>+k_prob_iocache_single_bit_data_error,0,0);
        <%}%>

    end else if (($test$plusargs("iocache_double_bit_data_error_test")) && 
        ((fnerrdetectcorrect == "PARITYENTRY") || 
        (fnerrdetectcorrect == "PARITY8BITS") || 
        (fnerrdetectcorrect == "PARITY16BITS"))) begin
        <%
        var num_SysCacheline = Math.pow(2, obj.wCacheLineOffset);
        var numDataBeats  = ((num_SysCacheline*8)/obj.wMasterData); 
        %>
        <%for( var i=0;i<nDataBanks;i++){%>
     //       ccp_tb_top.dut.mem.data_mem<%=i%>.internal_mem_inst.inject_errors(<%=i%>+k_prob_iocache_single_bit_data_error,0,0);
        <%}%>
    end

    if ($test$plusargs("iocache_double_bit_tag_error_test") &&  
        ((fnerrdetectcorrect == "SECDED") || 
        (fnerrdetectcorrect == "SECDED64BITS") || 
        (fnerrdetectcorrect == "SECDED128BITS") 
        )) begin
        <%for( var i=0;i<nTagBanks;i++){%>
   //         ccp_tb_top.dut.mem.mem<%=i%>.internal_mem_inst.inject_errors(k_prob_iocache_single_bit_tag_error,0,0);
        <%}%>
    end else if (($test$plusargs("iocache_double_bit_tag_error_test")) && 
        ((fnerrdetectcorrect == "PARITYENTRY") || 
        (fnerrdetectcorrect == "PARITY8BITS") || 
        (fnerrdetectcorrect == "PARITY16BITS"))) begin
        <%for( var i=0;i<nTagBanks;i++){%>
  //          ccp_tb_top.dut.mem.mem<%=i%>.internal_mem_inst.inject_errors(k_prob_iocache_single_bit_tag_error,0,0);
        <%}%>
    end


    if ((($urandom_range(0,100) < 50 && 
          ((fnerrdetectcorrect == "SECDED") ||
          (fnerrdetectcorrect == "SECDED64BITS") || 
          (fnerrdetectcorrect == "SECDED128BITS"))) &&  
            $test$plusargs("iocache_single_bit_error_test"))
          ) begin
        <%for( var i=0;i<nDataBanks;i++){%>
   //         ccp_tb_top.dut.mem.data_mem<%=i%>.internal_mem_inst.inject_errors(<%=i%>+k_prob_iocache_single_bit_data_error,0,0);
        <%}%>

        <%for( var i=0;i<nTagBanks;i++){%>
   //         ccp_tb_top.dut.mem.mem<%=i%>.internal_mem_inst.inject_errors(k_prob_iocache_single_bit_tag_error,0,0);
        <%}%>
    end





    <%}%>
   end

//Free Running Counter to mimic Eviction Counter
// in IO Cache.

assign u_ccp_if.nru_counter = nru_counter;

always @ (posedge sysclk or negedge sys_rstn)
begin
    if(~sys_rstn) begin
        nru_counter <= '0;
    end else begin
        if(nru_counter<(NO_OF_WAYS-1)) 
            nru_counter <= nru_counter+1'b1;
        else 
            nru_counter <= '0;
    end
end
//-----------------------------------------   
// generating reinit pulse after reset 
//---------------------------------------
    reg initdone,initdone_dly;
    reg taginitdone, taginitdone_dly;
     
    assign u_reinit = (initdone & ~initdone_dly) || (taginitdone & ~taginitdone_dly); 
    assign u_ccp_csr_maint_req_array_sel = (u_reinit & u_tag_init_done);

    always @(posedge sysclk or negedge sys_rstn)
       if(!sys_rstn)begin
        initdone     <= 0;
        initdone_dly <= 0;
        taginitdone     <= 0;
        taginitdone_dly <= 0;
       end else begin
        initdone     <= 1;
        initdone_dly <= initdone;   
        taginitdone <= u_tag_init_done;
        taginitdone_dly <= taginitdone;
       end
   
    always @(posedge u_init_done)
      begin
          if(!uvm_config_db#(uvm_event)::get(.cntxt(uvm_root::get()),
                                        .inst_name( "*" ),
                                        .field_name( "init_done" ),
                                        .value( init_done)))begin
         `uvm_error("CCP_TB_TOP", "Event init_done not found")
          end
          init_done.trigger();
         `uvm_info("CCP_TB_TOP", "triggered init_done event",UVM_NONE)
     end
endmodule
