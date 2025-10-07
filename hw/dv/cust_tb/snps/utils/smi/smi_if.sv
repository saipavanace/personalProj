////////////////////////////////////////////////////////////////////////////////
//
// SMI Interface
//
////////////////////////////////////////////////////////////////////////////////
<%const chipletObj = obj.lib.getAllChipletRefs();%>

interface smi_if (input clk, input rst_n);

    import uvm_pkg::*;

    parameter      setup_time = 1;
    parameter      hold_time  = 0;
 
    tri0 smi_msg_valid_logic_t     smi_msg_valid;
    tri0 smi_msg_ready_logic_t     smi_msg_ready;
    tri0 smi_steer_logic_t         smi_steer;
    tri0 smi_targ_id_logic_t       smi_targ_id;
    tri0 smi_src_id_logic_t        smi_src_id;
    tri0 smi_msg_tier_logic_t      smi_msg_tier;
    tri0 smi_msg_qos_logic_t       smi_msg_qos;
    tri0 smi_msg_pri_logic_t       smi_msg_pri;
    tri0 smi_msg_type_logic_t      smi_msg_type;
    tri0 smi_ndp_len_logic_t       smi_ndp_len;
    tri0 smi_ndp_logic_t           smi_ndp;
    tri0 smi_dp_present_logic_t    smi_dp_present;
    tri0 smi_msg_id_logic_t        smi_msg_id;
    tri0 smi_msg_user_logic_t      smi_msg_user;
    tri0 smi_msg_err_logic_t       smi_msg_err;
    tri0 smi_dp_valid_logic_t      smi_dp_valid;
    tri0 smi_dp_ready_logic_t      smi_dp_ready;
    tri0 smi_dp_last_logic_t       smi_dp_last;
    tri0 smi_dp_data_logic_t       smi_dp_data;
    tri0 smi_dp_user_logic_t       smi_dp_user;
    
    //-----------------------------------------------------------------------
    //params to control SMI readys for perf counter(stall events)
    //----------------------------------------------------------------------- 

    clocking transmitter_cb @(posedge clk);

        default input #setup_time output #hold_time;
        output smi_msg_valid;
        input  smi_msg_ready;
        output smi_steer;
        output smi_targ_id;
        output smi_src_id;
        output smi_msg_tier;
        output smi_msg_qos;
        output smi_msg_pri;
        output smi_msg_type;
        output smi_ndp_len;
        output smi_ndp;
        output smi_dp_present;
        output smi_msg_id;
        output smi_msg_user;
        output smi_msg_err;
        output smi_dp_valid;
        input  smi_dp_ready;
        output smi_dp_last;
        output smi_dp_data;
        output smi_dp_user;

    endclocking : transmitter_cb

    clocking receiver_cb @(posedge clk);

        default input #setup_time output #hold_time;
        input  smi_msg_valid;
        output smi_msg_ready;
        input  smi_steer;
        input  smi_targ_id;
        input  smi_src_id;
        input  smi_msg_tier;
        input  smi_msg_qos;
        input  smi_msg_pri;
        input  smi_msg_type;
        input  smi_ndp_len;
        input  smi_ndp;
        input  smi_dp_present;
        input  smi_msg_id;
        input  smi_msg_user;
        input  smi_msg_err;
        input  smi_dp_valid;
        output smi_dp_ready;
        input  smi_dp_last;
        input  smi_dp_data;
        input  smi_dp_user;

    endclocking : receiver_cb

    clocking monitor_cb @(negedge clk);

        default input #setup_time;
        input smi_msg_valid;
        input smi_msg_ready;
        input smi_steer;
        input smi_targ_id;
        input smi_src_id;
        input smi_msg_tier;
        input smi_msg_qos;
        input smi_msg_pri;
        input smi_msg_type;
        input smi_ndp_len;
        input smi_ndp;
        input smi_dp_present;
        input smi_msg_id;
        input smi_msg_user;
        input smi_msg_err;
        input smi_dp_valid;
        input smi_dp_ready;
        input smi_dp_last;
        input smi_dp_data;
        input smi_dp_user;

    endclocking : monitor_cb

    //------------------------------------------------------------------------------
    // Collect NDP
    //------------------------------------------------------------------------------
    task automatic collect_ndp(ref smi_seq_item pkt);
        automatic bit first_pass = 1;
        automatic bit done = 0;
    
        while (!done) begin
            @(monitor_cb);
            if (smi_msg_valid && first_pass) begin
                pkt.t_smi_ndp_valid = $time;
                pkt.smi_msg_valid  = 1;
                first_pass = 0;
            end
            if (smi_msg_valid & monitor_cb.smi_msg_ready) begin
                pkt.t_smi_ndp_ready = $time;
                pkt.smi_msg_ready  = 1;
                pkt.smi_steer      = monitor_cb.smi_steer;
                pkt.smi_targ_id    = monitor_cb.smi_targ_id;
                pkt.smi_src_id     = monitor_cb.smi_src_id;
                pkt.smi_msg_tier   = monitor_cb.smi_msg_tier;
                pkt.smi_msg_qos    = monitor_cb.smi_msg_qos;
                pkt.smi_msg_pri    = monitor_cb.smi_msg_pri;
                pkt.smi_msg_type   = monitor_cb.smi_msg_type;
                pkt.smi_ndp_len    = monitor_cb.smi_ndp_len;
                pkt.smi_ndp        = monitor_cb.smi_ndp;
                pkt.smi_dp_present = monitor_cb.smi_dp_present;
                pkt.smi_msg_id     = monitor_cb.smi_msg_id;
                <% if (chipletObj[0].AiuInfo[0].useResiliency) { %>
                pkt.smi_msg_user   = monitor_cb.smi_msg_user;
                <% } else { %>
                pkt.smi_msg_user   = 'h0;
                <% } %>
                pkt.smi_msg_err    = monitor_cb.smi_msg_err;
                done               = 1;
                `uvm_info("SMI_IF: COLLECT_NDP", $sformatf("DEBUG (collect_ndp): pkt:%p", pkt.convert2string()), UVM_LOW)
            end
        end 
    endtask : collect_ndp

    task automatic collect_dp(ref smi_seq_item pkt);
        bit first_pass = 1;
        bit done = 0;
    
        while (!done) begin
            @(monitor_cb);
            if (smi_dp_valid && first_pass) begin
                pkt.t_smi_dp_valid    = new[1];
                pkt.t_smi_dp_valid[0] = $time;
                pkt.smi_dp_valid      = 1;
                first_pass            = 0;
            end
            if (smi_dp_valid & monitor_cb.smi_dp_ready) begin
                pkt.t_smi_dp_ready    = new[1];
                pkt.t_smi_dp_ready[0] = $time;
                pkt.smi_dp_ready      = 1;
                pkt.smi_dp_last       = monitor_cb.smi_dp_last;
                pkt.smi_dp_data       = new [1];
                pkt.smi_dp_data[0]    = monitor_cb.smi_dp_data;
                pkt.smi_dp_user       = new [1];
                pkt.smi_dp_user[0]    = monitor_cb.smi_dp_user;
                done                  = 1;
                `uvm_info("SMI_IF: COLLECT_DP", $sformatf("DEBUG (collect_dp): pkt:%p", pkt.convert2string()), UVM_LOW)
            end
        end
    endtask : collect_dp

endinterface

