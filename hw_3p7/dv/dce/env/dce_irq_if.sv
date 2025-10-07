////////////////////////////////////////////
//
//DCE irq interface for correctible/uncorrectible errors
//IRQ interface
////////////////////////////////////////////

interface <%=obj.BlockId%>_irq_if(input clk, input reset_n);

  parameter      setup_time = 1;
  parameter      hold_time  = 0;

    //Correctible errors, Uncorrectible errros
<% obj.AiuInfo.forEach(function(bundle, indx, array) { %>
    logic aiu<%=indx%>_correctible_error_irq;
    logic aiu<%=indx%>_uncorrectible_error_irq;
<% }); %>

<% obj.BridgeAiuInfo.forEach(function(bundle, indx, array) { %>
    logic cbi<%=indx%>_correctible_error_irq;
    logic cbi<%=indx%>_uncorrectible_error_irq;
<% }); %>

<% obj.DmiInfo.forEach(function(bundle, indx, array) { %>
    logic dmi<%=indx%>_correctible_error_irq;
    logic dmi<%=indx%>_uncorrectible_error_irq;
<% }); %>

<% for(var indx = 1; indx <obj.DceInfo.nDces; indx++) { %>
    logic dce<%=indx%>_correctible_error_irq;
    logic dce<%=indx%>_uncorrectible_error_irq;
<% } %>

    logic correctible_error_irq;
    logic uncorrectible_error_irq;


    clocking master_cb @(posedge clk);
        default input #setup_time output #hold_time;

    //Correctible errors, Uncorrectible errros
<% obj.AiuInfo.forEach(function(bundle, indx, array) { %>
        output aiu<%=indx%>_correctible_error_irq;
        output aiu<%=indx%>_uncorrectible_error_irq;
<% }); %>

<% obj.BridgeAiuInfo.forEach(function(bundle, indx, array) { %>
        output cbi<%=indx%>_correctible_error_irq;
        output cbi<%=indx%>_uncorrectible_error_irq;
<% }); %>

<% obj.DmiInfo.forEach(function(bundle, indx, array) { %>
        output dmi<%=indx%>_correctible_error_irq;
        output dmi<%=indx%>_uncorrectible_error_irq;
<% }); %>

<% for(var indx = 1; indx <obj.DceInfo.nDces; indx++) { %>
        output dce<%=indx%>_correctible_error_irq;
        output dce<%=indx%>_uncorrectible_error_irq;
<% } %>

        input correctible_error_irq;
        input uncorrectible_error_irq;
    endclocking: master_cb

    modport master (
<% obj.AiuInfo.forEach(function(bundle, indx, array) { %>
        output aiu<%=indx%>_correctible_error_irq,
        output aiu<%=indx%>_uncorrectible_error_irq,
<% }); %>

<% obj.BridgeAiuInfo.forEach(function(bundle, indx, array) { %>
        output cbi<%=indx%>_correctible_error_irq,
        output cbi<%=indx%>_uncorrectible_error_irq,
<% }); %>

<% obj.DmiInfo.forEach(function(bundle, indx, array) { %>
        output dmi<%=indx%>_correctible_error_irq,
        output dmi<%=indx%>_uncorrectible_error_irq,
<% }); %>

<% for(var indx = 1; indx <obj.DceInfo.nDces; indx++) { %>
        output dce<%=indx%>_correctible_error_irq,
        output dce<%=indx%>_uncorrectible_error_irq,
<% } %>

        input correctible_error_irq,
        input uncorrectible_error_irq

    );

endinterface: <%=obj.BlockId%>_irq_if

