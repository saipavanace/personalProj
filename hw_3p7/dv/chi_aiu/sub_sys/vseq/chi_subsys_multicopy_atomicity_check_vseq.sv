class chi_subsys_multicopy_atomicity_check_vseq extends chi_subsys_random_vseq;
    `uvm_object_utils(chi_subsys_multicopy_atomicity_check_vseq)

    <%for(let idx = 0; idx < 3; idx++) { %>
        chi_subsys_multicopy_atomicity_wr_seq m_directed_wr_seq<%=idx%>;
    <%}%>
    <%for(let idx = 0; idx < 3; idx++) { %>
        chi_subsys_read_directed_seq m_directed_rd_seq<%=idx%>;
        <%if(idx == 2){ %>
        chi_subsys_read_directed_seq m_directed_rd_seq<%=idx%>1;
        <%}%>
    <%}%>
    bit is_non_secure_access;
    bit[addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] addr;
    svt_chi_transaction::order_type_enum rd_order_type;
    string chi_rn_arg_rd_order_type;
    svt_chi_transaction::order_type_enum wr_order_type;
    string chi_rn_arg_wr_order_type;

    function new(string name = "chi_subsys_multicopy_atomicity_check_vseq");
        super.new(name);
        <%for(let idx = 0; idx < 3; idx++) { %>
            m_directed_wr_seq<%=idx%> = chi_subsys_multicopy_atomicity_wr_seq::type_id::create("m_directed_wr_seq<%=idx%>");
            m_directed_rd_seq<%=idx%> = chi_subsys_read_directed_seq::type_id::create("m_directed_rd_seq<%=idx%>");
            <%if(idx == 2){ %>
            m_directed_rd_seq<%=idx%>1 = chi_subsys_read_directed_seq::type_id::create("m_directed_rd_seq<%=idx%>1");
            <%}%>
        <%}%>
        is_non_secure_access = $urandom_range(1,0);
        to_execute_body_method_of_chi_subsys_random_vseq = 0;
    endfunction: new

    virtual task body();
        `uvm_info("VSEQ", "Starting chi_subsys_multicopy_atomicity_check_vseq", UVM_LOW);
        super.body();

        if($value$plusargs("chi_rn_arg_rd_order_type=%0s",chi_rn_arg_rd_order_type)) begin
            `uvm_info(get_full_name(), $psprintf("Plusarg chi_rn_arg_rd_order_type=%0s is set",chi_rn_arg_rd_order_type), UVM_LOW)
        end
        if(chi_rn_arg_rd_order_type == "REQ_EP_ORDERING_REQUIRED") begin
            rd_order_type = svt_chi_common_transaction::REQ_EP_ORDERING_REQUIRED;
        end else if(chi_rn_arg_rd_order_type == "REQ_ORDERING_REQUIRED") begin
            rd_order_type = svt_chi_common_transaction::REQ_ORDERING_REQUIRED;
        end else if(chi_rn_arg_rd_order_type == "NO_ORDERING_REQUIRED") begin
            rd_order_type = svt_chi_common_transaction::NO_ORDERING_REQUIRED;
        end

        if($value$plusargs("chi_rn_arg_wr_order_type=%0s",chi_rn_arg_wr_order_type)) begin
            `uvm_info(get_full_name(), $psprintf("Plusarg chi_rn_arg_wr_order_type=%0s is set",chi_rn_arg_wr_order_type), UVM_LOW)
        end
        if(chi_rn_arg_wr_order_type == "REQ_EP_ORDERING_REQUIRED") begin
            wr_order_type = svt_chi_common_transaction::REQ_EP_ORDERING_REQUIRED;
        end else if(chi_rn_arg_wr_order_type == "REQ_ORDERING_REQUIRED") begin
            wr_order_type = svt_chi_common_transaction::REQ_ORDERING_REQUIRED;
        end else if(chi_rn_arg_wr_order_type == "NO_ORDERING_REQUIRED") begin
            wr_order_type = svt_chi_common_transaction::NO_ORDERING_REQUIRED;
        end

        fork 
            begin
                m_directed_wr_seq0.chiaiu_idx = 0;
                <%if(obj.nCHIs > 0){ %>
                m_directed_wr_seq0.start(rn_xact_seqr0);
                <% } else { %>
                `uvm_error(get_full_name, $sformatf("Need atleast 3 CHI AIU's to run this vseq."))
                <%}%>
                m_directed_wr_seq0.wait_for_active_xacts_to_end();
                fork
                    begin
                        m_directed_rd_seq0.sequence_length = 1;
                        m_directed_rd_seq0.enable_outstanding = 0;
                        m_directed_rd_seq0.rd_coh=0;
                        m_directed_rd_seq0.size=6;
                        m_directed_rd_seq0.min_addr = m_directed_wr_seq0.all_dii_start_addr[0][0] + 512;
                        m_directed_rd_seq0.max_addr = m_directed_wr_seq0.all_dii_start_addr[0][0] + 512;
                        m_directed_rd_seq0.hn_addr_rand_type = svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE;
                        m_directed_rd_seq0.by_pass_read_data_check = 1;
                        m_directed_rd_seq0.use_seq_is_non_secure_access = 1;
                        m_directed_rd_seq0.seq_is_non_secure_access = 0;
                        m_directed_rd_seq0.seq_exp_comp_ack = 0;
                        m_directed_rd_seq0.seq_order_type = wr_order_type;
                        if(m_directed_wr_seq0.chi_rn_arg_mem_attr_mem_type == "NORMAL") begin
                            m_directed_rd_seq0.seq_mem_attr_mem_type = svt_chi_transaction::NORMAL;
                        end else if(m_directed_wr_seq0.chi_rn_arg_mem_attr_mem_type == "DEVICE") begin
                            m_directed_rd_seq0.seq_mem_attr_mem_type = svt_chi_transaction::DEVICE;
                        end
                        <%if(obj.nCHIs > 0){ %>
                        m_directed_rd_seq0.start(rn_xact_seqr0);
                        <% } else { %>
                        `uvm_error(get_full_name, $sformatf("Need atleast 3 CHI AIU's to run this vseq."))
                        <%}%>
                        if (m_directed_rd_seq0.read_tran.data == m_directed_wr_seq0.data_pattern_1) begin
                            `uvm_info(get_full_name, $sformatf("CHI0 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq0.read_tran.data, m_directed_wr_seq0.data_pattern_1), UVM_LOW)
                        end
                        else if (m_directed_rd_seq0.read_tran.data == m_directed_wr_seq0.data_pattern_2) begin
                            `uvm_info(get_full_name, $sformatf("CHI0 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq0.read_tran.data, m_directed_wr_seq0.data_pattern_2), UVM_LOW)
                        end
                        else if (m_directed_rd_seq0.read_tran.data == m_directed_wr_seq0.data_pattern_3) begin
                            `uvm_info(get_full_name, $sformatf("CHI0 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq0.read_tran.data, m_directed_wr_seq0.data_pattern_3), UVM_LOW)
                        end
                        else begin
                            `uvm_error(get_full_name, $sformatf("CHI0 DII Data Mismatch. Read Data = %x", m_directed_rd_seq0.read_tran.data))
                        end
                    end
                    begin
                        m_directed_rd_seq2.sequence_length = 1;
                        m_directed_rd_seq2.enable_outstanding = 0;
                        m_directed_rd_seq2.rd_coh=0;
                        m_directed_rd_seq2.size=6;
                        m_directed_rd_seq2.min_addr = m_directed_wr_seq0.all_dii_start_addr[0][0] + 512;
                        m_directed_rd_seq2.max_addr = m_directed_wr_seq0.all_dii_start_addr[0][0] + 512;
                        m_directed_rd_seq2.hn_addr_rand_type = svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE;
                        m_directed_rd_seq2.by_pass_read_data_check = 1;
                        m_directed_rd_seq2.use_seq_is_non_secure_access = 1;
                        m_directed_rd_seq2.seq_is_non_secure_access = 0;
                        m_directed_rd_seq2.seq_exp_comp_ack = 0;
                        m_directed_rd_seq2.seq_order_type = rd_order_type;
                        if(m_directed_wr_seq0.chi_rn_arg_mem_attr_mem_type == "NORMAL") begin
                            m_directed_rd_seq2.seq_mem_attr_mem_type = svt_chi_transaction::NORMAL;
                        end else if(m_directed_wr_seq0.chi_rn_arg_mem_attr_mem_type == "DEVICE") begin
                            m_directed_rd_seq2.seq_mem_attr_mem_type = svt_chi_transaction::DEVICE;
                        end
                        <%if(obj.nCHIs > 2){ %>
                        m_directed_rd_seq2.start(rn_xact_seqr2);
                        <% } else { %>
                        `uvm_error(get_full_name, $sformatf("Need atleast 3 CHI AIU's to run this vseq."))
                        <%}%>
                        if (m_directed_rd_seq2.read_tran.data == m_directed_wr_seq0.data_pattern_1) begin
                            `uvm_info(get_full_name, $sformatf("CHI2_0 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq2.read_tran.data, m_directed_wr_seq0.data_pattern_1), UVM_LOW)
                        end
                        else if (m_directed_rd_seq2.read_tran.data == m_directed_wr_seq0.data_pattern_2) begin
                            `uvm_info(get_full_name, $sformatf("CHI2_0 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq2.read_tran.data, m_directed_wr_seq0.data_pattern_2), UVM_LOW)
                        end
                        else if (m_directed_rd_seq2.read_tran.data == m_directed_wr_seq0.data_pattern_3) begin
                            `uvm_info(get_full_name, $sformatf("CHI2_0 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq2.read_tran.data, m_directed_wr_seq0.data_pattern_3), UVM_LOW)
                        end
                        else begin
                            `uvm_error(get_full_name, $sformatf("CHI2_0 DII Data Mismatch. Read Data = %x", m_directed_rd_seq2.read_tran.data))
                        end
                    end
                join
            end
            begin
                m_directed_wr_seq1.chiaiu_idx = 1;
                <%if(obj.nCHIs > 1){ %>
                m_directed_wr_seq1.start(rn_xact_seqr1);
                <% } else { %>
                `uvm_error(get_full_name, $sformatf("Need atleast 3 CHI AIU's to run this vseq."))
                <%}%>
                m_directed_wr_seq1.wait_for_active_xacts_to_end();
                fork
                    begin
                        m_directed_rd_seq1.sequence_length = 1;
                        m_directed_rd_seq1.enable_outstanding = 0;
                        m_directed_rd_seq1.rd_coh=0;
                        m_directed_rd_seq1.size=6;
                        m_directed_rd_seq1.min_addr = m_directed_wr_seq1.all_dii_start_addr[0][0] + 512;
                        m_directed_rd_seq1.max_addr = m_directed_wr_seq1.all_dii_start_addr[0][0] + 512;
                        m_directed_rd_seq1.hn_addr_rand_type = svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE;
                        m_directed_rd_seq1.by_pass_read_data_check = 1;
                        m_directed_rd_seq1.use_seq_is_non_secure_access = 1;
                        m_directed_rd_seq1.seq_is_non_secure_access = 0;
                        m_directed_rd_seq1.seq_exp_comp_ack = 0;
                        m_directed_rd_seq1.seq_order_type = wr_order_type;
                        if(m_directed_wr_seq1.chi_rn_arg_mem_attr_mem_type == "NORMAL") begin
                            m_directed_rd_seq1.seq_mem_attr_mem_type = svt_chi_transaction::NORMAL;
                        end else if(m_directed_wr_seq1.chi_rn_arg_mem_attr_mem_type == "DEVICE") begin
                            m_directed_rd_seq1.seq_mem_attr_mem_type = svt_chi_transaction::DEVICE;
                        end
                        <%if(obj.nCHIs > 1){ %>
                        m_directed_rd_seq1.start(rn_xact_seqr1);
                        <% } else { %>
                        `uvm_error(get_full_name, $sformatf("Need atleast 3 CHI AIU's to run this vseq."))
                        <%}%>
                        if (m_directed_rd_seq1.read_tran.data == m_directed_wr_seq0.data_pattern_0) begin
                            `uvm_info(get_full_name, $sformatf("CHI1 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq1.read_tran.data, m_directed_wr_seq1.data_pattern_0), UVM_LOW)
                        end
                        else if (m_directed_rd_seq1.read_tran.data == m_directed_wr_seq0.data_pattern_2) begin
                            `uvm_info(get_full_name, $sformatf("CHI1 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq1.read_tran.data, m_directed_wr_seq1.data_pattern_2), UVM_LOW)
                        end
                        else if (m_directed_rd_seq1.read_tran.data == m_directed_wr_seq0.data_pattern_3) begin
                            `uvm_info(get_full_name, $sformatf("CHI1 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq1.read_tran.data, m_directed_wr_seq1.data_pattern_3), UVM_LOW)
                        end
                        else begin
                            `uvm_error(get_full_name, $sformatf("CHI1 DII Data Mismatch. Read Data = %x", m_directed_rd_seq1.read_tran.data))
                        end
                    end
                    begin
                        m_directed_rd_seq21.sequence_length = 1;
                        m_directed_rd_seq21.enable_outstanding = 0;
                        m_directed_rd_seq21.rd_coh=0;
                        m_directed_rd_seq21.size=6;
                        m_directed_rd_seq21.min_addr = m_directed_wr_seq1.all_dii_start_addr[0][0] + 512;
                        m_directed_rd_seq21.max_addr = m_directed_wr_seq1.all_dii_start_addr[0][0] + 512;
                        m_directed_rd_seq21.hn_addr_rand_type = svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE;
                        m_directed_rd_seq21.by_pass_read_data_check = 1;
                        m_directed_rd_seq21.use_seq_is_non_secure_access = 1;
                        m_directed_rd_seq21.seq_is_non_secure_access = 0;
                        m_directed_rd_seq21.seq_exp_comp_ack = 0;
                        m_directed_rd_seq21.seq_order_type = rd_order_type;
                        if(m_directed_wr_seq1.chi_rn_arg_mem_attr_mem_type == "NORMAL") begin
                            m_directed_rd_seq21.seq_mem_attr_mem_type = svt_chi_transaction::NORMAL;
                        end else if(m_directed_wr_seq1.chi_rn_arg_mem_attr_mem_type == "DEVICE") begin
                            m_directed_rd_seq21.seq_mem_attr_mem_type = svt_chi_transaction::DEVICE;
                        end
                        <%if(obj.nCHIs > 2){ %>
                        m_directed_rd_seq21.start(rn_xact_seqr2);
                        <% } else { %>
                        `uvm_error(get_full_name, $sformatf("Need atleast 3 CHI AIU's to run this vseq."))
                        <%}%>
                        if (m_directed_rd_seq21.read_tran.data == m_directed_wr_seq1.data_pattern_0) begin
                            `uvm_info(get_full_name, $sformatf("CHI2_1 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq21.read_tran.data, m_directed_wr_seq1.data_pattern_0), UVM_LOW)
                        end
                        else if (m_directed_rd_seq21.read_tran.data == m_directed_wr_seq1.data_pattern_2) begin
                            `uvm_info(get_full_name, $sformatf("CHI2_1 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq21.read_tran.data, m_directed_wr_seq1.data_pattern_2), UVM_LOW)
                        end
                        else if (m_directed_rd_seq21.read_tran.data == m_directed_wr_seq1.data_pattern_3) begin
                            `uvm_info(get_full_name, $sformatf("CHI2_1 DII Data Match. Read Data = %x Write Data = %x", m_directed_rd_seq21.read_tran.data, m_directed_wr_seq1.data_pattern_3), UVM_LOW)
                        end
                        else begin
                            `uvm_error(get_full_name, $sformatf("CHI2_1 DII Data Mismatch. Read Data = %x", m_directed_rd_seq21.read_tran.data))
                        end
                    end
                join
            end
        join

        `uvm_info("VSEQ", "Finished chi_subsys_multicopy_atomicity_check_vseq", UVM_LOW);
    endtask: body

endclass: chi_subsys_multicopy_atomicity_check_vseq
