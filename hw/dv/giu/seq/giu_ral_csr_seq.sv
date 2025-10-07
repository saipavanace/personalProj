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

typedef uvm_reg array_of_regs[$];
typedef struct packed {
                        bit [`UVM_REG_ADDR_WIDTH-1 : 0] lower_addr;
                        bit [`UVM_REG_ADDR_WIDTH-1 : 0] upper_addr;
                    } csr_addr;
typedef csr_addr array_of_csr_addr[$];
//-----------------------------------------------------------------------
//   base method for giu 
//-----------------------------------------------------------------------
class giu_ral_csr_base_seq extends ral_csr_base_seq;

    `uvm_object_utils(giu_ral_csr_base_seq)
    virtual giu_csr_probe_if u_csr_probe_vif;
    virtual <%=obj.BlockId%>_apb_if  apb_vif;

    extern function new(string name="");
    extern function void getCsrProbeIf();
    extern function bit [`UVM_REG_ADDR_WIDTH-1 : 0] get_unmapped_csr_addr();
    extern function void get_apb_if();

    task poll_GIUUUESR_ErrVld(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.GiuInfo[obj.Id].strRtlNamePrefix%>.GIUUUESR.ErrVld,poll_till,fieldVal);
    endtask

    task body();
        // Set the list of registers in the config DB
        array_of_regs my_regs;
        m_regs.giu<%=Id%>.get_registers(my_regs);
        uvm_config_db#(array_of_regs)::set(null, "uvm_test_top", "my_regs",
                                           my_regs);

    endtask

endclass : giu_ral_csr_base_seq

function giu_ral_csr_base_seq::new(string name="");
    super.new(name);
endfunction : new

function void giu_ral_csr_base_seq::getCsrProbeIf();
    if(!uvm_config_db#(virtual giu_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif))
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
endfunction : getCsrProbeIf

function bit [`UVM_REG_ADDR_WIDTH-1 : 0] giu_ral_csr_base_seq::get_unmapped_csr_addr();
    bit [`UVM_REG_ADDR_WIDTH-1 : 0] all_csr_addr[$];

    array_of_csr_addr csr_unmapped_addr_range;
    int randomly_selected_unmapped_csr_sddr;
    
    <% obj.GiuInfo[obj.Id].csr.spaceBlock[0].registers.forEach(function GetAllregAddr(item,i){ %>
                                //all_csr_addr.push_back({12'h<%=obj.GiuInfo[obj.Id].nrri%>,8'h<%=obj.GiuInfo[obj.Id].rpn%>,12'h<%=item.addressOffset%>});
                                all_csr_addr.push_back(<%=item.addressOffset%>);
                            <% }); %>
    all_csr_addr.sort();
    `uvm_info(get_full_name(),$sformatf("all_csr_addr : %0p",all_csr_addr),UVM_HIGH);
    for (int i = 0; i <= (all_csr_addr.size() - 2); i++) begin 
    if ((all_csr_addr[i+1] - all_csr_addr[i]) > 'h4) begin
        csr_unmapped_addr_range.push_back({(all_csr_addr[i]+'h4),(all_csr_addr[i+1]-4)});
    end
    end
    `uvm_info(get_full_name(),$sformatf("csr_unmapped_addr_range : %0p",csr_unmapped_addr_range),UVM_HIGH);
    uvm_config_db#(array_of_csr_addr)::set(null, "uvm_test_top", "csr_unmapped_addr_range",csr_unmapped_addr_range);

    randomly_selected_unmapped_csr_sddr = $urandom_range((csr_unmapped_addr_range.size()-1),0);
    get_unmapped_csr_addr = $urandom_range(csr_unmapped_addr_range[randomly_selected_unmapped_csr_sddr].lower_addr,csr_unmapped_addr_range[randomly_selected_unmapped_csr_sddr].upper_addr);
    `uvm_info(get_full_name(),$sformatf("unmapped_csr_addr : 0x%0x",get_unmapped_csr_addr),UVM_HIGH);
endfunction : get_unmapped_csr_addr

function void giu_ral_csr_base_seq::get_apb_if();
    if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt(null),
                                        .inst_name(this.get_full_name()),
                                        .field_name("m_apb_if"),
                                        .value(apb_vif)))
    `uvm_error(get_name,"Failed to get apb if")
endfunction : get_apb_if

class access_unmapped_csr_addr extends giu_ral_csr_base_seq;
    `uvm_object_utils(access_unmapped_csr_addr)
    bit [`UVM_REG_ADDR_WIDTH-1 : 0] unmapped_csr_addr;
    apb_pkt_t apb_pkt;

    extern function new(string name="");

    task body();
        get_apb_if();
        unmapped_csr_addr = get_unmapped_csr_addr();
        uvm_config_db#(bit [`UVM_REG_ADDR_WIDTH-1 : 0])::set(null, "uvm_test_top", "unmapped_csr_addr",unmapped_csr_addr);
        apb_pkt = apb_pkt_t::type_id::create("apb_pkt");
        start_item(apb_pkt);
        apb_pkt.paddr = unmapped_csr_addr;
        apb_pkt.unmap_addr = unmapped_csr_addr;
        apb_pkt.pwrite = 1;
        apb_pkt.psel = 1;
        apb_pkt.pwdata = $urandom;
        finish_item(apb_pkt);
    endtask
endclass : access_unmapped_csr_addr

function access_unmapped_csr_addr::new(string name="");
    super.new(name);
endfunction : new

class giu_unmapped_csr_addrs_seq extends giu_ral_csr_base_seq;
    `uvm_object_utils(giu_unmapped_csr_addrs_seq)

    bit [`UVM_REG_ADDR_WIDTH-1 : 0] unmapped_csr_addr;
    apb_pkt_t apb_pkt;
    array_of_csr_addr csr_unmapped_addr_range;

    extern function new(string name="");
    extern function array_of_csr_addr get_unmapped_csr_addrs();

    task body();
        get_apb_if();
        csr_unmapped_addr_range = get_unmapped_csr_addrs();
 
        `uvm_info("CSRSEQ", $sformatf("unmapped CSR array: %0p", csr_unmapped_addr_range), UVM_HIGH)

        uvm_config_db#(bit [`UVM_REG_ADDR_WIDTH-1 : 0])::set(null, "uvm_test_top", "unmapped_csr_addr",unmapped_csr_addr);

                foreach (csr_unmapped_addr_range[i]) begin
                    `uvm_info("CSRSEQ", $sformatf("unmapped CSR address lower: %0h - upper: %0h", csr_unmapped_addr_range[i].lower_addr,csr_unmapped_addr_range[i].upper_addr), UVM_HIGH)
                    for (logic [31:0] addr = csr_unmapped_addr_range[i].lower_addr; addr <= csr_unmapped_addr_range[i].upper_addr; addr += 4) begin
                        `uvm_info("CSRSEQ", $sformatf("unmapped CSR address: %0h", addr), UVM_HIGH)
                        uvm_config_db#(bit [`UVM_REG_ADDR_WIDTH-1 : 0])::set(null, "uvm_test_top", "unmapped_csr_addr",addr);
                        apb_pkt = apb_pkt_t::type_id::create("apb_pkt");
                        start_item(apb_pkt);
                        apb_pkt.paddr = addr;
                        apb_pkt.unmap_addr = addr;  // this causes pslverr to be checked in APB driver
                        apb_pkt.pwrite = 1;
                        apb_pkt.psel = 1;
                        apb_pkt.pwdata = $urandom;
                        finish_item(apb_pkt);
                    end
                end
    endtask

endclass : giu_unmapped_csr_addrs_seq

function giu_unmapped_csr_addrs_seq::new(string name="");
    super.new(name);
endfunction : new

function array_of_csr_addr giu_unmapped_csr_addrs_seq::get_unmapped_csr_addrs();
    bit [`UVM_REG_ADDR_WIDTH-1 : 0] all_csr_addr[$];

    array_of_csr_addr csr_unmapped_addr_range;
    
    <% obj.GiuInfo[obj.Id].csr.spaceBlock[0].registers.forEach(function GetAllregAddr(item,i){ %>
                                //all_csr_addr.push_back({12'h<%=obj.GiuInfo[obj.Id].nrri%>,8'h<%=obj.GiuInfo[obj.Id].rpn%>,12'h<%=item.addressOffset%>});
                                all_csr_addr.push_back(<%=item.addressOffset%>);
                            <% }); %>
    all_csr_addr.sort();
    `uvm_info(get_full_name(),$sformatf("all_csr_addr : %0p",all_csr_addr),UVM_NONE);
    for (int i = 0; i <= (all_csr_addr.size() - 2); i++) begin 
    if ((all_csr_addr[i+1] - all_csr_addr[i]) > 'h4) begin
        csr_unmapped_addr_range.push_back({(all_csr_addr[i]+'h4),(all_csr_addr[i+1]-4)});
    end
    end
    `uvm_info(get_full_name(),$sformatf("csr_unmapped_addr_range : %0p",csr_unmapped_addr_range),UVM_NONE);
    uvm_config_db#(array_of_csr_addr)::set(null, "uvm_test_top", "csr_unmapped_addr_range",csr_unmapped_addr_range);
    get_unmapped_csr_addrs = csr_unmapped_addr_range;
endfunction : get_unmapped_csr_addrs


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//  Task    : giu_csr_init_seq
//  Purpose : GIU CSR init at startup
//
//-----------------------------------------------------------------------
class giu_csr_init_seq extends giu_ral_csr_base_seq; 
   `uvm_object_utils(giu_csr_init_seq)
    virtual <%=obj.BlockId%>_apb_if  apb_vif;

    extern function new(string name="");

    task body();
        // make sure CXS_RX_en and CXS_TX_en are set, reset value is set but make sure
        uvm_status_e status;
        uvm_reg_data_t write_data=32'h00000011;
        string reg_name = "GIUCXSLR";
        uvm_reg my_reg = m_regs.giu<%=Id%>.get_reg_by_name(reg_name);
    
        if (my_reg != null) 
            begin : csr_init_seq
                my_reg.write(status, write_data);
                if (status != UVM_IS_OK ) 
                    begin : csr_write_fail
                        `uvm_error("CSR_INIT", $sformatf("write to reg %s failed",reg_name))
                    end : csr_write_fail
            end : csr_init_seq
        else 
            begin : init_reg_missing
                `uvm_error("CSR_INIT", $sformatf("could not initialize %s, reg not found",reg_name))
            end : init_reg_missing

    // put any special initialization here
    endtask

endclass : giu_csr_init_seq

function giu_csr_init_seq::new(string name="");
    super.new(name);
endfunction : new
