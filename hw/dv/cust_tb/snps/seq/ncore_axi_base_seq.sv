<%const chipletObj = obj.lib.getAllChipletRefs();%>

class ncore_axi_base_seq extends svt_axi_master_base_sequence;
    rand int unsigned sequence_length = 1;
    local  svt_axi_master_agent my_agent;


    constraint reasonable_sequence_length {
        sequence_length == 1;
    }

    rand int some_rand_delay;
    int transaction = 0;
    int cache_value = 4'h0;
    int address_group = 0;
    int is_write = 0;
    int no_ace_init = 0;
    string coherent_command = "READNOSNOOP";
    int atomic_type_tx = svt_axi_transaction::NORMAL;
    string protocol,init_type;
    int master_id = 0;
    int txn_no = 0;
    int is_finished = 'h0;
    int qos_value   = 'h0;
    int xacttype = svt_axi_transaction::COHERENT;
    int xact_set = 0;
    int burstlen = 1;
    bit allocate = 1;
    int datawidth = svt_axi_transaction::BURST_SIZE_256BIT;
    int transaction_delay = 0;
    bit[<%=chipletObj[0].wSysAddr-1%>:0] start_addr[int];
    int txn_id;
    int id_width,cnt1;
    bit[47:0]addr_value = 0;
    int cnt = -1;
    int cnt_id ,cnt_idx,id,burstlen_prev,diff,len1,aiu_id,idx1,idx0,mem_region; 
    int avg_latency,total;
    int latency=0;

    //ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];

    `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)

    `svt_xvm_object_utils_begin(ncore_axi_base_seq)
    `svt_xvm_field_int(sequence_length, `SVT_XVM_ALL_ON)
    `svt_xvm_object_utils_end

    function new(string name="ncore_axi_base_seq");
        super.new(name);
    endfunction

    virtual task body();
        svt_axi_master_transaction read_tran[];
        bit status,status_nw;
        int num_completed_perf_intervals_for_master,rd,wr;
        `SVT_XVM(component)           my_component;

        time  begin_time;
        time  seq_end_time1,end_time,min_latency,max_latency;
        shortreal   bandwidth1, bandwidth2, bandwidth3, bandwidth4, latency1;
        super.body();

        my_component = p_sequencer.get_parent();
        void'($cast(my_agent,my_component));

        /** Gets the user provided sequence_length. */
        `ifdef SVT_UVM_TECHNOLOGY
            status = uvm_config_db#(int unsigned)::get(m_sequencer, get_type_name(), "sequence_length", sequence_length);
        `else
            status = m_sequencer.get_config_int({get_type_name(), ".sequence_length"}, sequence_length);
        `endif
        `svt_xvm_debug("body", $sformatf("sequence_length is %0d as a result of %0s.", sequence_length, status ? "the config DB" : "randomization"));
        read_tran = new[sequence_length];

        //repeat(100) @(posedge ncore_system_tb_top.sys_clk);

        init_type = (protocol=="ACE") ? "CAIU" : "NCAIU" ;
        
        `uvm_info("ncore_axi_base body", $sformatf("mst_id=%0d, data_width=%0d, burst_len=%0d", master_id, datawidth, burstlen), UVM_LOW)

        //for (int i=0; i<sequence_length; i++)begin
                    `uvm_create(read_tran[0])
                    read_tran[0].port_cfg = this.cfg;
                    read_tran[0] = new("read_tran_0");

                    `svt_xvm_do_with(read_tran[0],
                        {
                            addr      == start_addr[0];
                            addr[5:0] == 0;
                            id        == txn_id;
                            atomic_type == atomic_type_tx;
                            xact_type == xact_set;
                            coherent_xact_type == transaction;
                            data_before_addr == 0;
                            qos == qos_value;
                            burst_size   == datawidth;
                            burst_length == burstlen;
                            allocate_in_cache == allocate;
                            cache_type == cache_value;
                            prot_type == svt_axi_transaction::DATA_SECURE_NORMAL;
                            barrier_type inside {svt_axi_transaction::NORMAL_ACCESS_RESPECT_BARRIER};
                            burst_type   == svt_axi_transaction::INCR;
                            foreach (wstrb[i]) { wstrb[i]==( 64'h1 << (64'h1<<burst_size) ) -1;}
                        })
                    read_tran[0].wait_end();
                    latency  = read_tran[0].get_end_time() - read_tran[0].get_begin_time();  
        //end

    endtask: body

    virtual function bit is_applicable(svt_configuration cfg);
        return 1;
    endfunction : is_applicable
endclass
