
`ifndef SYNOPSYS_VIP_SLAVE_MODAL
class axi_slv_mem_modal extends AXI_env;

    `uvm_component_param_utils_begin(axi_slv_mem_modal)
    `uvm_component_param_utils_end

    //Constructor
    function new(string name = "axi_slv_mem_modal", uvm_component parent = null);
        super.new(name, parent);

        //AXI env config 
        m_env_conf = AXI_env_conf::type_id::create("m_env_conf", this);
    endfunction: new

    //Build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

    endfunction: build_phase

    //Method to add slave Address Map
    function void add_slave(string name,
                            int unsigned start_addr,
                            int unsigned end_addr,
                            int unsigned full_size         = 5,
                            int unsigned c_axi_id_width    = 4,
                            int unsigned c_axi_addr_width  = 32,
                            int unsigned c_axi_reg_width   = 4,
                            int unsigned c_axi_data_width  = 32,
                            int unsigned c_axi_len_width   = 8,
                            int unsigned c_axi_size_width  = 3,
                            int unsigned c_axi_burst_width = 2,
                            int unsigned c_axi_cache_width = 4,
                            int unsigned c_axi_prot_width  = 3,
                            int unsigned c_axi_qos_width   = 4,
                            int unsigned c_axi_strb_width  = 4,
                            int unsigned c_axi_resp_width  = 2,
                            uvm_active_passive_enum is_active = UVM_ACTIVE,
                            slave_type_enum sv_type = VIRTUAL_SLAVE);
        
        m_env_conf.add_slave(name, start_addr, end_addr, full_size, c_axi_id_width, c_axi_addr_width, c_axi_reg_width, c_axi_data_width, c_axi_len_width, c_axi_size_width, c_axi_burst_width, c_axi_cache_width, c_axi_prot_width, c_axi_qos_width, c_axi_strb_width, c_axi_resp_width, is_active, sv_type);
        `uvm_info("axi_slv_mem_modal", $psprintf("Added memory modal [%s] to address map", name), UVM_LOW);
    endfunction: add_slave

    //Method to load Memory model
    //This method is now called implicitely in open source memory model while
    //building
    //function void load_mem(int unsigned start_addr,
    //                       int unsigned end_addr);

    //    for(int unsigned idx = start_addr; idx <= end_addr; idx++)
    //        m_slaves[0].m_driver.m_mem[idx] = idx;
    //endfunction: load_mem

endclass: axi_slv_mem_modal

`else
class axi_slv_mem_modal extends uvm_env;

     `uvm_component_param_utils_begin(axi_slv_mem_modal)
    `uvm_component_param_utils_end

    //Constructor
    function new(string name = "axi_slv_mem_modal", uvm_component parent = null);
        super.new(name, parent);

    endfunction: new

    //FIXME: Logic to be added

endclass: axi_slv_mem_modal
`endif

