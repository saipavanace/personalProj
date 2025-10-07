<%const chipletObj = obj.lib.getAllChipletRefs();%>

class ncore_chi_base_seq extends svt_chi_rn_transaction_base_sequence;
    local svt_chi_rn_agent my_agent;

    `uvm_object_utils(ncore_chi_base_seq)

    extern function new(string name="ncore_chi_base_seq");

    svt_chi_node_configuration cfg;

    rand int unsigned sequence_length;


    constraint reasonable_sequence_length {
        sequence_length == 1;
    }

    bit[<%=chipletObj[0].wSysAddr-1%>:0] start_addr[int] ;
    int txn_id;
    int transaction = 0;
    bit [5:0] cache_value = 5'h0;
    int address_group = 0;
    bit trace_tag = 0;
    int is_write = 0;
    string coherent_command = "READNOSNOOP";
    int master_id = 0;
    int txn_no = 0;
    int is_finished = 'h0;
    int qos_value   = 'h0;
    int transaction_delay = 0;
    int id_width;
    int avg_latency,total,rd,wr;
    int cnt_id ,cnt_idx,id,aiu_id,idx1,idx0,mem_region; 
    int latency=0;
    int exclusive=0;
    int datawidth = svt_chi_transaction::SIZE_64BYTE;
    int burst_size;

    //ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];

    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    virtual task body();
        svt_chi_rn_transaction read_tran[];
        bit status;
        `SVT_XVM(component)           my_component;

        super.body();

        my_component = p_sequencer.get_parent();
        void'($cast(my_agent,my_component));

        read_tran = new[sequence_length];


	    //for (int i=0; i < sequence_length; i++) begin
                    `uvm_create(read_tran[0])
                    read_tran[0].cfg = this.cfg;
                    read_tran[0] = new("read_tran_0");

                    `svt_xvm_do_with(read_tran[0],
                        {
                            addr                               == start_addr[0];
                            addr[5:0]                          == 0;
                            txn_id                             == txn_id;
                            qos                                == qos_value;
                            is_non_secure_access               == 1'b0;
                            data_size                          == datawidth;
                            xact_type                          == transaction;
                            byte_enable                        == {`SVT_CHI_MAX_BE_WIDTH{1'b1}};
                            snp_attr_is_snoopable              == cache_value[1];
                            mem_attr_allocate_hint             == cache_value[4];
                            snp_attr_snp_domain_type           == svt_chi_transaction::INNER;
                            mem_attr_mem_type                  == svt_chi_transaction::NORMAL;
                            trace_tag == trace_tag;
                            is_exclusive== exclusive;
                        })
    
                    read_tran[0].wait_end();
                    latency  = read_tran[0].get_end_time() - read_tran[0].get_begin_time();  
                    burst_size = read_tran[0].data_size; 
        //end
        `uvm_info("body", "Exiting...", UVM_LOW)
    endtask: body
endclass: ncore_chi_base_seq

function ncore_chi_base_seq::new(string name="ncore_chi_base_seq");
  super.new(name);
  //Set the response depth to -1, to accept infinite number of responses
  this.set_response_queue_depth(-1);
endfunction
