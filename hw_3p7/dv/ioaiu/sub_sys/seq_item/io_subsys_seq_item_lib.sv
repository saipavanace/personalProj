`include "io_subsys_axi_master_transaction.svh" 
`include "io_subsys_axi_slave_transaction.svh" 
`include "io_subsys_ace_master_snoop_transaction.svh" 
`ifndef GUARD_CONC_SVT_AXI_MASTER_DVM_TRANSACTION_SVH
`define GUARD_CONC_SVT_AXI_MASTER_DVM_TRANSACTION_SVH 

class conc_svt_axi_master_dvm_transaction extends io_subsys_axi_master_transaction; 

`undef CLASS_CONTRAINTS_PREFIX
`define CLASS_CONTRAINTS_PREFIX c_conc_svt_axi_master_dvm_transaction
int k_dvm_message_id_min;
int k_dvm_message_id_max;
int k_dvm_complete_id_min;
int k_dvm_complete_id_max;


    //constraint  c_dvm_id {
    //  if (port_cfg.dvm_enable) {
    //    if (coherent_xact_type == DVMMESSAGE) {
    //        id inside {[k_dvm_message_id_min : k_dvm_message_id_max]};
    //    }
    //    if (coherent_xact_type == DVMCOMPLETE) {
    //        id inside {[k_dvm_complete_id_min : k_dvm_complete_id_max]};
    //    }
    //   }
    //}

    `svt_xvm_object_utils(conc_svt_axi_master_dvm_transaction)

    function new(string name = "conc_svt_axi_master_dvm_transaction");
        super.new(name);
        dvm_test = 1;
    endfunction: new

    function void pre_randomize();
        super.pre_randomize();
        if (port_cfg.dvm_enable) begin
            k_dvm_message_id_max = port_cfg.use_separate_rd_wr_chan_id_width? ((1<<(port_cfg.read_chan_id_width))-1) : ((1<<(port_cfg.id_width))-1) ;
            k_dvm_message_id_max = (port_cfg.dvm_id_max<k_dvm_message_id_max) ? port_cfg.dvm_id_max : k_dvm_message_id_max;
            k_dvm_complete_id_min = 0;

            void'($value$plusargs("k_dvm_message_id_max=%0d",k_dvm_message_id_max)) ;
            void'($value$plusargs("k_dvm_complete_id_min=%0d",k_dvm_complete_id_min)) ; 
            k_dvm_complete_id_max = (k_dvm_message_id_max%2==0) ? (k_dvm_message_id_max/2) : (k_dvm_message_id_max+1)/ 2;
            k_dvm_message_id_min = k_dvm_complete_id_max+1;
            //`uvm_info(get_full_name(),$psprintf("k_dvm_message_id_max %0d k_dvm_message_id_min %0d k_dvm_complete_id_min %0d k_dvm_complete_id_max %0d use_separate_rd_wr_chan_id_width %0d read_chan_id_width %0d id_width %0d dvm_id_max %0d dvm_id_min %0d",k_dvm_message_id_max,k_dvm_message_id_min,k_dvm_complete_id_min,k_dvm_complete_id_max,port_cfg.use_separate_rd_wr_chan_id_width,port_cfg.read_chan_id_width,port_cfg.id_width,port_cfg.dvm_id_max,port_cfg.dvm_id_min),UVM_NONE)
            if(k_dvm_message_id_max<k_dvm_message_id_min) begin
                `uvm_fatal(get_full_name(),$psprintf("k_dvm_message_id_max<k_dvm_message_id_min is not expected",k_dvm_message_id_max,k_dvm_message_id_min))
            end
            if(k_dvm_complete_id_max<k_dvm_complete_id_min) begin
                `uvm_fatal(get_full_name(),$psprintf("k_dvm_complete_id_max<k_dvm_complete_id_min is not expected",k_dvm_complete_id_max,k_dvm_complete_id_min))
            end
        end
    endfunction: pre_randomize

    function void post_randomize();
        super.post_randomize();
        if (port_cfg.dvm_enable) begin
            if (coherent_xact_type == DVMMESSAGE) begin
                id = $urandom_range(k_dvm_message_id_max,k_dvm_message_id_min);
            end
            if (coherent_xact_type == DVMCOMPLETE) begin
                id = $urandom_range(k_dvm_complete_id_max,k_dvm_complete_id_min);
            end
            //`uvm_info(get_full_name(),$psprintf("id %0d coherent_xact_type %0s",id,coherent_xact_type.name()),UVM_NONE)
        end

    endfunction: post_randomize

endclass: conc_svt_axi_master_dvm_transaction
`endif // `ifndef GUARD_CONC_SVT_AXI_MASTER_DVM_TRANSACTION_SVH
