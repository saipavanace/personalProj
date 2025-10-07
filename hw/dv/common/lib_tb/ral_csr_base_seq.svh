///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// File         :   ral_csr_base_seq.svh                                     //
// Author       :   Eric Weisman 2018                                        //
// Description  :   handwritten csr access seqs should descend from this     //
//                                                                           //
// Revision     :   0                                                        //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


class ral_csr_base_seq extends uvm_reg_sequence;
    `uvm_object_param_utils(ral_csr_base_seq)

    <% if(( obj.testBench == "fsys" ) || ( obj.testBench == "emu" )) { %> //vyshak
    concerto_register_map_pkg::ral_sys_ncore            m_regs;
    <%} else if((obj.testBench == "dce") || (obj.testBench == "dmi") || (obj.testBench == "io_aiu") || (obj.testBench == "giu")){ %>
    <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore m_regs;
    <% } else { %>
    ral_sys_ncore            m_regs;
    <% } %>

    uvm_status_e           status;

    uvm_reg_data_t         rd_data,wr_data;
    uvm_reg_data_t         data;
    uvm_reg_data_t         field_rd_data;


    ////////////////////////////////////////////////////////////////////////////////
    //constructors
    //
    function new(string name="ral_csr_base_seq");
        super.new(name);
    endfunction

    task pre_body();
        $cast(m_regs,model);
    endtask

    ////////////////////////////////////////////////////////////////////////////////
    //helpers

    function void compareValues(string one, string two, int data1, int data2);
        if (data1 == data2) begin
            `uvm_info("RUN_MAIN",$sformatf("%s:0x%x, expd %s:0x%0x OKAY", one, data1, two, data2), UVM_MEDIUM)
        end else begin
            `uvm_error("RUN_MAIN",$sformatf("Mismatch %s:0x%0x, expd %s:0x%0x",one, data1, two, data2));
        end
    endfunction // compareValues

    function uvm_reg_data_t mask_data(int lsb, int msb);
        uvm_reg_data_t mask_data_val = 0;

        for(int i=0;i<32;i++)begin
            if(i>=lsb &&  i<=msb)begin
                mask_data_val[i] = 1;     
            end
        end
        //$display("func maskdataval:0x%0x",mask_data_val);
        return mask_data_val;
    endfunction:mask_data

    ////////////////////////////////////////////////////////////////////////////////
    //accessors

    task write_csr(uvm_reg_field field, uvm_reg_data_t wr_data);
        int lsb, msb;
        uvm_reg_data_t mask;
        field.get_parent().read(status, field_rd_data, .parent(this));
        lsb = field.get_lsb_pos();
        msb = lsb + field.get_n_bits() - 1;
        `uvm_info("CSR Ralgen Base Seq", $sformatf("Write %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_MEDIUM);
        // and with actual field bits 0
        mask = mask_data(lsb, msb);
        //$display("mask:0x%0x",mask);
        mask = ~mask;
        field_rd_data = field_rd_data & mask;
        // shift write data to appropriate position
        wr_data = wr_data << lsb;
        // then or with this data to get value to write
        wr_data = field_rd_data | wr_data;
        field.get_parent().write(status, wr_data, .parent(this));
    endtask : write_csr

    task read_csr(uvm_reg_field field, output uvm_reg_data_t fieldVal);
        int lsb, msb;
        uvm_reg_data_t mask;
        field.get_parent().read(status, field_rd_data, .parent(this));
        lsb = field.get_lsb_pos();
        msb = lsb + field.get_n_bits() - 1;
        `uvm_info("CSR Ralgen Base Seq", $sformatf("Read %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_MEDIUM);
        //$display("rd_data:0x%0x",field_rd_data);
        // AND other bits to 0
        mask = mask_data(lsb, msb);
        //$display("mask:0x%0x",mask);
        field_rd_data = field_rd_data & mask;
        //$display("masked data:0x%0x",field_rd_data);
        // shift read data by lsb to return field
        fieldVal = field_rd_data >> lsb;
        //$display("fieldVal:0x%0x",fieldVal);
    endtask : read_csr

    task poll_csr(uvm_reg_field field, bit [31:0] poll_till, output uvm_reg_data_t fieldVal, input int timeout = 10_000);
        //int timeout;
        //timeout = 10000;
        do begin
            timeout -=1;
            read_csr(field, fieldVal);
            //fieldVal = field_rd_data;
            `uvm_info("CSR Ralgen Base Seq", $sformatf("%s poll_till=0x%0x fieldVal=0x%0x timeout=%0d", field.get_name(), poll_till, fieldVal, timeout), UVM_NONE);
        end while ((fieldVal != poll_till) && (timeout != 0)); // UNMATCHED !!
        if (timeout == 0) begin
            `uvm_error("CSR Ralgen Base Seq", $sformatf("Timeout! Polling %s, poll_till=0x%0x fieldVal=0x%0x", field.get_name(), poll_till, fieldVal))
        end
    endtask : poll_csr


endclass : ral_csr_base_seq
