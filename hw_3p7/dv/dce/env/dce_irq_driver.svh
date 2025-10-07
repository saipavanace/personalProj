//
//dce_irq_driver.svh
//Dirves correctibe/uncorrectible error signals
//

class <%=obj.BlockId%>_irq_driver extends uvm_driver #(<%=obj.BlockId%>_irq_seq_item);

     `uvm_component_utils(<%=obj.BlockId%>_irq_driver)

    virtual <%=obj.BlockId%>_irq_if m_vif;
    bit mode_of_operation;

    extern function new(string name = "<%=obj.BlockId%>_irq_driver", uvm_component parent = null);
    extern task run_phase(uvm_phase phase);

    //internal methods
    extern task drive_reset_values();
    extern task drive_request(const ref <%=obj.BlockId%>_irq_seq_item seq_item);
    extern task collect_response(ref <%=obj.BlockId%>_irq_seq_item seq_item);

endclass: <%=obj.BlockId%>_irq_driver

function <%=obj.BlockId%>_irq_driver::new(string name = "<%=obj.BlockId%>_irq_driver",
    uvm_component parent = null);
    super.new(name, parent);
endfunction: new

task <%=obj.BlockId%>_irq_driver::run_phase(uvm_phase phase);
    <%=obj.BlockId%>_irq_seq_item m_seq_item;

    if(mode_of_operation) begin //master mode
        fork
            begin
                forever begin
                    @(posedge m_vif.clk);
                    if(!m_vif.reset_n)
                        drive_reset_values();
                end
            end
            begin
                forever begin
                    wait(m_vif.reset_n);
                    seq_item_port.get_next_item(m_seq_item);
                    @(posedge m_vif.clk);
                    drive_request(m_seq_item);
                    @(posedge m_vif.clk);
                    collect_response(m_seq_item);
                    seq_item_port.item_done();
                end
            end
        join_none
    end else begin //slave mode
        fork
            begin
                forever begin
                    @(posedge m_vif.clk);
                    if(!m_vif.reset_n)
                        drive_reset_values();
                end
            end
            begin
                forever begin
                    wait(m_vif.reset_n);
                    seq_item_port.get_next_item(m_seq_item);
                    @(posedge m_vif.clk);
                    wait(m_vif.correctible_error_irq || m_vif.uncorrectible_error_irq);
                    collect_response(m_seq_item);
                    seq_item_port.item_done();
                end
            end
        join_none
    end

endtask: run_phase

task <%=obj.BlockId%>_irq_driver::drive_reset_values();

<% obj.AiuInfo.forEach(function(bundle, indx, array) { %>
    m_vif.master_cb.aiu<%=indx%>_correctible_error_irq      <= 1'b0;
    m_vif.master_cb.aiu<%=indx%>_uncorrectible_error_irq    <= 1'b0;
<% }); %>

<% obj.BridgeAiuInfo.forEach(function(bundle, indx, array) { %>
    m_vif.master_cb.cbi<%=indx%>_correctible_error_irq      <= 1'b0;
    m_vif.master_cb.cbi<%=indx%>_uncorrectible_error_irq    <= 1'b0;
<% }); %>

<% obj.DmiInfo.forEach(function(bundle, indx, array) { %>
    m_vif.master_cb.dmi<%=indx%>_correctible_error_irq      <= 1'b0;
    m_vif.master_cb.dmi<%=indx%>_uncorrectible_error_irq    <= 1'b0;
<% }); %>

//DCE0 is excluded
<% for(var indx = 1; indx <obj.DceInfo.nDces; indx++) { %>
    m_vif.master_cb.dce<%=indx%>_correctible_error_irq      <= 1'b0;
    m_vif.master_cb.dce<%=indx%>_uncorrectible_error_irq    <= 1'b0;
<% } %>

endtask: drive_reset_values

task <%=obj.BlockId%>_irq_driver::drive_request(const ref <%=obj.BlockId%>_irq_seq_item seq_item);
    
<% obj.AiuInfo.forEach(function(bundle, indx, array) { %>
    m_vif.master_cb.aiu<%=indx%>_correctible_error_irq    <= seq_item.aiu_cor_irq_vld[<%=indx%>];
    m_vif.master_cb.aiu<%=indx%>_uncorrectible_error_irq  <= seq_item.aiu_uncor_irq_vld[<%=indx%>];
<% }); %>

<% obj.BridgeAiuInfo.forEach(function(bundle, indx, array) { %>
    m_vif.master_cb.cbi<%=indx%>_correctible_error_irq    <= seq_item.cbi_cor_irq_vld[<%=indx%>];
    m_vif.master_cb.cbi<%=indx%>_uncorrectible_error_irq  <= seq_item.cbi_uncor_irq_vld[<%=indx%>];
<% }); %>

<% obj.DmiInfo.forEach(function(bundle, indx, array) { %>
    m_vif.master_cb.dmi<%=indx%>_correctible_error_irq    <= seq_item.dmi_cor_irq_vld[<%=indx%>];
    m_vif.master_cb.dmi<%=indx%>_uncorrectible_error_irq    <= seq_item.dmi_uncor_irq_vld[<%=indx%>];
<% }); %>

//DCE0 is excluded
<% for(var indx = 1; indx <obj.DceInfo.nDces; indx++) { %>
    m_vif.master_cb.dce<%=indx%>_correctible_error_irq    <= seq_item.dce_cor_irq_vld[<%=indx%>];
    m_vif.master_cb.dce<%=indx%>_uncorrectible_error_irq  <= seq_item.dce_uncor_irq_vld[<%=indx%>];
<% } %>

endtask: drive_request

task <%=obj.BlockId%>_irq_driver::collect_response(ref <%=obj.BlockId%>_irq_seq_item seq_item);
    seq_item.correctible_error_irq    = m_vif.master_cb.correctible_error_irq;
    seq_item.uncorrectible_error_irq  = m_vif.master_cb.uncorrectible_error_irq;
endtask: collect_response
