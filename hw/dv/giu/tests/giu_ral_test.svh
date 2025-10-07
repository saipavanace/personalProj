//--------------------------------------------------------------------------------------
// Copyright(C) 2014-2025 Arteris, Inc. and its applicable subsidiaries.
// All rights reserved.
//
// Disclaimer: This release is not provided nor intended for any chip implementations, 
//             tapeouts, or other features of production releases. 
//
// These files and associated documentation is proprietary and confidential to
// Arteris, Inc. and its applicable subsidiaries. The files and documentation
// may only be used pursuant to the terms and conditions of a signed written
// license agreement with Arteris, Inc. or one of its subsidiaries.
// All other use, reproduction, modification, or distribution of the information
// contained in the files or the associated documentation is strictly prohibited.
// This product and its technology is protected by patents and other forms of 
// intellectual property protection.
//
// License: Arteris Confidential
<%// Project: GIU
// Product: Ncore 3.8
// Author: esherk
// %> 
//--------------------------------------------------------------------------------------

<%
    //all csr sequences
    var csr_seqs = [
        "giu_ral_csr_base_seq",
        "uvm_reg_hw_reset_seq",
        "uvm_reg_bit_bash_seq",
        "giu_unmapped_csr_addrs_seq"
        //TODO seqs from dve_ral_csr_seq.sv
    ];
%>

`ifndef COMMONKNOBPKG
`define COMMONKNOBPKG
import common_knob_pkg::*;
`endif

class giu_ral_test extends giu_base_test;
    `uvm_component_utils(giu_ral_test)

    virtual <%=obj.BlockId%>_apb_if      m_apb_if;

    giu_env_config      m_env_cfg;
    giu_env             m_giu_env;

    giu_csr_init_seq    csr_init_seq;

    array_of_regs       my_regs;
    bit [`UVM_REG_ADDR_WIDTH-1 : 0]            unmapped_csr_addr;

    // sequence knobs
    string name = "giu_ral_test";
    string test_name = name;
    int m_timeout_us;

    function new(string _name = "giu_ral_test", uvm_component parent = null);
        super.new(_name, parent);
        name = _name;
    endfunction // new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(test_name, "build_phase", UVM_NONE);

        // env config
        m_env_cfg = giu_env_config::type_id::create("m_env_cfg");

        // Put the env config object into configuration database.
        uvm_config_db#(giu_env_config)::set(
        .cntxt(null),
        .inst_name("*"),
        .field_name("giu_env_config"),
        .value(m_env_cfg)
        );

        // SMI agent config
        m_env_cfg.m_smi_agent_cfg = smi_agent_config::type_id::create("m_smi_agent_cfg");
        m_env_cfg.m_smi_agent_cfg.active = UVM_ACTIVE;

        m_env_cfg.m_apb_agent_cfg = apb_agent_config::type_id::create("m_apb_agent_config",  this);

        if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt( this ),
                                            .inst_name( "" ),
                                            .field_name( "m_apb_if" ),
                                            .value(m_env_cfg.m_apb_agent_cfg.m_vif ))) begin
            `uvm_error(get_name(), "m_apb_if not found")
        end

        m_env_cfg.m_q_chnl_agent_cfg = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);
    
        if (!uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if)::get(.cntxt( this ),
                                            .inst_name( "" ),
                                            .field_name( "m_q_chnl_if" ),
                                            .value(m_env_cfg.m_q_chnl_agent_cfg.m_vif ))) begin
            `uvm_error(get_name(), "m_q_chnl_if not found")
        end

        if (!uvm_config_db#(virtual <%=obj.BlockId%>_clock_counter_if)::get(.cntxt( this ),
                                            .inst_name( "" ),
                                            .field_name( "m_clock_counter_if" ),
                                            .value(m_env_cfg.m_clock_counter_vif ))) begin
            `uvm_error(get_name(), "m_clock_counter_if not found")
        end

        // SMI TX interface from TB perspective
        <% for (var i = 0; i < obj.nSmiRx; i++) { %>
            if (!uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::get(
                .cntxt(this),
                .inst_name(""),
                .field_name("m_smi<%=i%>_tx_vif"),
                .value(m_env_cfg.m_smi<%=i%>_tx_vif))) begin

                `uvm_fatal(get_name(), "unable to find m_smi<%=i%>_tx_vif")
            end
            m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config =
            smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config");

            m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.m_vif = m_env_cfg.m_smi<%=i%>_tx_vif;
        <% } %>

        //SMI RX interface from TB perspective
        <% for (var i = 0; i < obj.nSmiTx; i++) { %>
            if (!uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::get(
                .cntxt(this),
                .inst_name(""),
                .field_name("m_smi<%=i%>_rx_vif"),
                .value(m_env_cfg.m_smi<%=i%>_rx_vif))) begin

                `uvm_fatal(get_name(), "unable to find m_smi<%=i%>_rx_vif")
            end
            m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config =
            smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config");

            m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif = m_env_cfg.m_smi<%=i%>_rx_vif;
        <% } %>

        uvm_config_db#(smi_agent_config)::set(
        .cntxt(null),
        .inst_name("*"),
        .field_name("smi_agent_config"),
        .value(m_env_cfg.m_smi_agent_cfg)
        );

        //Create the env
        m_giu_env = giu_env::type_id::create("m_giu_env", this);

    endfunction // build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction : connect_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
    endfunction // end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        uvm_reg_sequence csr_seq;
        string  k_csr_seq   = "";

        uvm_reg_data_t read_data, reset_data, write_data;
        uvm_status_e status;
        uvm_reg_addr_t offset;
        string reg_name;

        super.run_phase(phase);
        `uvm_info(test_name, "run_phase", UVM_DEBUG)

        if (!$value$plusargs("k_csr_seq=%s",k_csr_seq)) k_csr_seq = "giu_ral_csr_base_seq";

        //instantiate the csr seq
        <% for (i in csr_seqs) { %>
        if (k_csr_seq == "<%=csr_seqs[i]%>")
            csr_seq = <%=csr_seqs[i]%>::type_id::create("csr_seq"); 
        <% } %>

        csr_seq.model = m_giu_env.m_regs;

        `uvm_info(test_name, "Starting CSR Test", UVM_MEDIUM)
        phase.raise_objection(this, $sformatf("Start %s", k_csr_seq));

        `uvm_info("RALTEST", $sformatf("sequence in progress: %s", k_csr_seq),UVM_MEDIUM)

        case (k_csr_seq)

            "giu_ral_csr_base_seq" : begin
                csr_seq.start(m_giu_env.m_apb_agent.m_apb_sequencer);
                // Retrieve the list of registers from the config DB, exit if not found
                if (!uvm_config_db#(array_of_regs)::get(this, "", "my_regs", my_regs)) begin
                    `uvm_fatal("REGS_NOT_FOUND","Could not get register list from config DB")
                end
                foreach (my_regs[i]) begin : read_reset_testing
                    uvm_reg this_reg;
                    this_reg = my_regs[i];
                    reg_name = this_reg.get_name();
                    offset   = this_reg.get_offset();

                    // check that register is aligned
                    if ((offset % 4) != 0) begin
                        `uvm_error(test_name, $sformatf("Register %s[%0d]: is misaligned",
                                                    reg_name, offset))
                    end

                    begin : do_read
                        reset_data = this_reg.get_reset();
                        fork
                            begin
                                #100000ns `uvm_fatal(test_name, "timeout occurred")
                            end
                            begin
                                `uvm_info(test_name, $sformatf("register: %s", reg_name
                                        ), UVM_DEBUG)
                                this_reg.read(status, read_data);
                            end
                        join_any
                        // make sure read was successful
                        if (status != UVM_IS_OK) begin
                            `uvm_error(test_name,
                                $sformatf(
                                    "Register %s[%0d]: error reading register: %s",
                                    reg_name, offset, status))
                        end

                        `uvm_info("REGS", $sformatf(
                                "Register %s[%0d]: read= 0x%0h, reset = 0x%0h",
                                reg_name,
                                offset,
                                read_data,
                                reset_data
                                ), UVM_DEBUG)

                        if (read_data !== reset_data) begin
                            `uvm_error(test_name,
                                $sformatf(
                                    "Register %s[%0d]: wrong reset value, actual= 0x%0h, expected = 0x%0h",
                                    reg_name, offset, read_data, reset_data))
                        end
                    end : do_read
                end : read_reset_testing

                foreach (my_regs[i]) begin : write_testing
                    uvm_reg this_reg;
                    uvm_reg_data_t
                        old_field_val, new_field_val, new_write_data,
                        new_read_data, new_read_mask, reset_data;
                    string my_field_name;
                    string my_access;
                    int my_lsb;
                    int my_size;
                    uvm_reg_field my_fields[$], this_field;

                    this_reg = my_regs[i];
                    reg_name = this_reg.get_name();
                    offset = this_reg.get_offset();
                    reset_data = this_reg.get_reset();

                    new_write_data = `UVM_REG_DATA_WIDTH'b0;
                    this_reg.get_fields(my_fields);

                    new_read_mask = `UVM_REG_DATA_WIDTH'hfffffffff;
                    foreach (my_fields[j]) begin : compose_write
                        this_field = my_fields[j];
                        my_access = this_field.get_access();
                        my_field_name = this_field.get_name();
                        my_lsb = this_field.get_lsb_pos();
                        my_size = this_field.get_n_bits();
                        old_field_val = this_field.get_mirrored_value();
                        old_field_val &= ((1 << my_size) - 1);
                        new_field_val = old_field_val;
                        if (my_access != "RO") begin
                            new_field_val = (~old_field_val) & ((1 << my_size) - 1);
                        end
                        if (my_access == "W1C") begin
                            new_read_mask &= ~(((1 << my_size) - 1) << my_lsb);
                        end
                        new_write_data |= (new_field_val << (my_lsb));
                    end : compose_write

                    this_reg.write(status, new_write_data);
                    // force extra read of GIUNRSBLR in case GIUNRSBAR was written
                    if (reg_name == "GIUNRSBLR") begin
                        this_reg.read(status, new_read_data);
                    end

                    this_reg.read(status, new_read_data);
                    // GIUCSXLR mask status fields since RX/TX status set if RX/TX enabled
                    if (reg_name == "GIUCXSLR") begin
                        new_read_data = new_read_data & 32'hffff_ff99;
                    end

                    if (new_read_data != (new_read_mask & new_write_data)) begin
                        if (this_reg.get_rights() == "RO") begin
                            `uvm_error(test_name,$sformatf(
                                    "Register %s[%0d]: miscompare on read after write of RO register: write = 0x%0h read = 0x%0h",
                                    reg_name, offset, new_write_data, new_read_data))
                        end else begin
                        `uvm_error(test_name,$sformatf(
                                    "Register %s[%0d]: miscompare on read after write of RW register: write = 0x%0h expected read = 0x%0h read = 0x%0h",
                                    reg_name,
                                    offset,
                                    new_write_data,
                                    (new_read_mask & new_write_data),
                                    new_read_data))
                        end
                    end
                    if (this_reg.get_rights() != "RO") begin
                        this_reg.write(status,
                                    reset_data);  // put the register back to post-reset if not RO
                    end
                end : write_testing
            end

            "giu_unmapped_csr_addrs_seq": begin
                csr_seq.start(m_giu_env.m_apb_agent.m_apb_sequencer);
            end

            "uvm_reg_hw_reset_seq": begin 
                `uvm_info("CSRSEQ",$sformatf("Sequence not yet implemented: %s", k_csr_seq), UVM_NONE)
            end

            default: `uvm_error("CSRSEQ",$sformatf("Bad sequence called: %s", k_csr_seq))
        endcase

        phase.drop_objection(this, $sformatf("Finish %s", k_csr_seq));
        `uvm_info(test_name, "Completed CSR test", UVM_MEDIUM)

    endtask // run_phase

endclass // giu_ral_test
