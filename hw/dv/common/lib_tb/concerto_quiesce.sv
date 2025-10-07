// Quiesce Logics
task quiesce_system();

//initial begin

    //event system_quiesce;
    event system_restart;

    int 	  quiesceDelay;
   
    <% if (obj.testBench == "psys") { %>
    quiesceDelay =  $urandom_range(1000, 1001);
    repeat(quiesceDelay) @(posedge sys_clk0);
    <% } else if (obj.testBench == "cbi") { %>
    quiesceDelay =  $urandom_range(5000, 6000);
    repeat(quiesceDelay) @(posedge tb_clk);
    <% } else if (obj.testBench == "aiu") { %>
    quiesceDelay =  $urandom_range(5000, 6000);
    repeat(quiesceDelay) @(posedge tb_clk);
    <% } else { %>
    quiesceDelay =  $urandom_range(500, 501);
    repeat(quiesceDelay) @(posedge tb_clk);
    <% } %>

    <% if (obj.testBench == "psys") { %>
           $display("Delay %d", quiesceDelay);

        <% for (var pidx = 0; pidx < obj.nAIUs; pidx++) { %>

            $display("Forcing AIU<%=pidx%> Valid/Ready to 0 at time %t", $realtime);

            fork
              begin
                wait(`AIU<%=pidx%>.sfi_slv_req_vld == 0);
                force `AIU<%=pidx%>.sfi_slv_req_vld = '0;
                force `AIU<%=pidx%>.sfi_slv_req_rdy = '0;
                $display("Forced slv_req channel");
              end
              begin
                repeat(1000) @(posedge `AIU<%=pidx%>.clk);
                $display("Leave slv_req channel");
              end
            join_any
            disable fork;

            fork
              begin
                wait(`AIU<%=pidx%>.sfi_slv_rsp_vld == 0);
                force `AIU<%=pidx%>.sfi_slv_rsp_vld = '0;
                force `AIU<%=pidx%>.sfi_slv_rsp_rdy = '0;
                $display("Forced slv_rsp channel");
              end
              begin
                repeat(1000) @(posedge `AIU<%=pidx%>.clk);
                $display("Leave slv_rsp channel");
              end
            join_any
            disable fork;

            fork
              begin
                wait(`AIU<%=pidx%>.sfi_mst_req_vld == 0);
                force `AIU<%=pidx%>.sfi_mst_req_vld = '0;
                force `AIU<%=pidx%>.sfi_mst_req_rdy = '0;
                $display("Forced mst_req channel");
              end
              begin
                repeat(1000) @(posedge `AIU<%=pidx%>.clk);
                $display("Leave mst_req channel");
              end
            join_any
            disable fork;

            fork
              begin
                wait(`AIU<%=pidx%>.sfi_mst_rsp_vld == 0);
                force `AIU<%=pidx%>.sfi_mst_rsp_vld = '0;
                force `AIU<%=pidx%>.sfi_mst_rsp_rdy = '0;
                $display("Forced mst_rsp channel");
              end
              begin
                repeat(1000) @(posedge `AIU<%=pidx%>.clk);
                $display("Leave mst_rsp channel");
              end
            join_any
            disable fork;

        <% } %>

        <% for (var pidx = obj.nAIUs; pidx < obj.nAIUs + obj.nCBIs; pidx++) { %>
            $display("Forcing AIU<%=pidx%> (Bridge) Valid/Ready to 0 at time %t", $realtime);

            fork
              begin
                wait(`AIU<%=pidx%>.sfi_slv_req_vld == 0);
                force `AIU<%=pidx%>.sfi_slv_req_vld = '0;
                force `AIU<%=pidx%>.sfi_slv_req_rdy = '0;
                $display("Forced slv_req channel");
              end
              begin
                repeat(1000) @(posedge `AIU<%=pidx%>.clk);
                $display("Leave slv_req channel");
              end
            join_any
            disable fork;

            fork
              begin
                wait(`AIU<%=pidx%>.sfi_slv_rsp_vld == 0);
                force `AIU<%=pidx%>.sfi_slv_rsp_vld = '0;
                force `AIU<%=pidx%>.sfi_slv_rsp_rdy = '0;
                $display("Forced slv_rsp channel");
              end
              begin
                repeat(1000) @(posedge `AIU<%=pidx%>.clk);
                $display("Leave slv_rsp channel");
              end
            join_any
            disable fork;

            fork
              begin
                wait(`AIU<%=pidx%>.sfi_mst_req_vld == 0);
                force `AIU<%=pidx%>.sfi_mst_req_vld = '0;
                force `AIU<%=pidx%>.sfi_mst_req_rdy = '0;
                $display("Forced mst_req channel");
              end
              begin
                repeat(1000) @(posedge `AIU<%=pidx%>.clk);
                $display("Leave mst_req channel");
              end
            join_any
            disable fork;

            fork
              begin
                wait(`AIU<%=pidx%>.sfi_mst_rsp_vld == 0);
                force `AIU<%=pidx%>.sfi_mst_rsp_vld = '0;
                force `AIU<%=pidx%>.sfi_mst_rsp_rdy = '0;
                $display("Forced mst_rsp channel");
              end
              begin
                repeat(1000) @(posedge `AIU<%=pidx%>.clk);
                $display("Leave mst_rsp channel");
              end
            join_any
            disable fork;


        <% } %>

        <% for (var pidx = 0; pidx < obj.nDCEs; pidx++) { %>

            $display("Forcing DCE<%=pidx%> Valid/Ready to 0 at time %t", $realtime);

            fork
              begin
                wait(`DCE<%=pidx%>.sfi_slv_req_vld == 0);
                force `DCE<%=pidx%>.sfi_slv_req_vld = '0;
                force `DCE<%=pidx%>.sfi_slv_req_rdy = '0;
                $display("Forced slv_req channel");
              end
              begin
                repeat(1000) @(posedge `DCE<%=pidx%>.clk);
                $display("Leave slv_req channel");
              end
            join_any
            disable fork;

            fork
              begin
                wait(`DCE<%=pidx%>.sfi_slv_rsp_vld == 0);
                force `DCE<%=pidx%>.sfi_slv_rsp_vld = '0;
                force `DCE<%=pidx%>.sfi_slv_rsp_rdy = '0;
                $display("Forced slv_rsp channel");
              end
              begin
                repeat(1000) @(posedge `DCE<%=pidx%>.clk);
                $display("Leave slv_rsp channel");
              end
            join_any
            disable fork;

            fork
              begin
                wait(`DCE<%=pidx%>.sfi_mst_req_vld == 0);
                force `DCE<%=pidx%>.sfi_mst_req_vld = '0;
                force `DCE<%=pidx%>.sfi_mst_req_rdy = '0;
                $display("Forced mst_req channel");
              end
              begin
                repeat(1000) @(posedge `DCE<%=pidx%>.clk);
                $display("Leave mst_req channel");
              end
            join_any
            disable fork;

            fork
              begin
                wait(`DCE<%=pidx%>.sfi_mst_rsp_vld == 0);
                force `DCE<%=pidx%>.sfi_mst_rsp_vld = '0;
                force `DCE<%=pidx%>.sfi_mst_rsp_rdy = '0;
                $display("Forced mst_rsp channel");
              end
              begin
                repeat(1000) @(posedge `DCE<%=pidx%>.clk);
                $display("Leave mst_rsp channel");
              end
            join_any
            disable fork;


        <% } %>

        <% for (var pidx = 0; pidx < obj.nDMIs; pidx++) { %>

        <% } %>

    <% } else if (obj.testBench == "dmi") { %>

        $display("Forcing Valid/Ready to 0 at time %t", $realtime);
        wait(dmi_tb_top.dut.sfi_slv_req_vld == 0);
        force dmi_tb_top.dut.sfi_slv_req_vld = '0;
        force dmi_tb_top.dut.sfi_slv_req_rdy = '0;

        wait(dmi_tb_top.dut.axi_mst_rvalid == 0);
        force dmi_tb_top.dut.axi_mst_rvalid = '0;
        force dmi_tb_top.dut.axi_mst_rready = '0;

        wait(dmi_tb_top.dut.sfi_slv_rsp_vld == 0);
        force dmi_tb_top.dut.sfi_slv_rsp_vld = '0;
        force dmi_tb_top.dut.sfi_slv_rsp_rdy = '0;

        wait(dmi_tb_top.dut.sfi_mst_req_vld == 0);
        force dmi_tb_top.dut.sfi_mst_req_vld = '0;
        force dmi_tb_top.dut.sfi_mst_req_rdy = '0;

        wait(dmi_tb_top.dut.sfi_mst_rsp_vld == 0);
        force dmi_tb_top.dut.sfi_mst_rsp_vld = '0;
        force dmi_tb_top.dut.sfi_mst_rsp_rdy = '0;

        wait(dmi_tb_top.dut.axi_mst_awvalid == 0);
        force dmi_tb_top.dut.axi_mst_awvalid = '0;
        force dmi_tb_top.dut.axi_mst_awready = '0;

        wait(dmi_tb_top.dut.axi_mst_arvalid == 0);
        force dmi_tb_top.dut.axi_mst_arvalid = '0;
        force dmi_tb_top.dut.axi_mst_arready = '0;

        wait(dmi_tb_top.dut.axi_mst_wvalid == 0);
        force dmi_tb_top.dut.axi_mst_wvalid = '0;
        force dmi_tb_top.dut.axi_mst_wready = '0;


        wait(dmi_tb_top.dut.axi_mst_bvalid == 0);
        force dmi_tb_top.dut.axi_mst_bvalid = '0;
        force dmi_tb_top.dut.axi_mst_bready = '0;




    <% } else if (obj.testBench == "cbi" ) { %>

            $display("Forcing Agent AIU  Valid/Ready to 0 at time %t", $realtime);

            wait(aiu_tb_top.dut.ace_awvalid == 0);
            force aiu_tb_top.dut.ace_awvalid = '0;
            force aiu_tb_top.dut.ace_awready = '0;

            //Wdata will be throttled once AW channel is shut off. 
            //There is no need 
            //wait(aiu_tb_top.dut.ace_wvalid == 0);
            //force aiu_tb_top.dut.ace_wvalid = '0;
            //force aiu_tb_top.dut.ace_wready = '0;

            wait(aiu_tb_top.dut.ace_arvalid == 0);
            force aiu_tb_top.dut.ace_arvalid = '0;
            force aiu_tb_top.dut.ace_arready = '0;


            wait(aiu_tb_top.dut.ace_rvalid == 0);
            force aiu_tb_top.dut.ace_rvalid = '0;
            force aiu_tb_top.dut.ace_rready = '0;

            wait(aiu_tb_top.dut.ace_bvalid == 0);
            force aiu_tb_top.dut.ace_bvalid = '0;
            force aiu_tb_top.dut.ace_bready = '0;

            wait(aiu_tb_top.dut.sfi_slv_req_vld == 0);
            force aiu_tb_top.dut.sfi_slv_req_vld = '0;
            force aiu_tb_top.dut.sfi_slv_req_rdy = '0;

            wait(aiu_tb_top.dut.sfi_slv_rsp_vld == 0);
            force aiu_tb_top.dut.sfi_slv_rsp_vld = '0;
            force aiu_tb_top.dut.sfi_slv_rsp_rdy = '0;

            wait(aiu_tb_top.dut.sfi_mst_req_vld == 0);
            force aiu_tb_top.dut.sfi_mst_req_vld = '0;
            force aiu_tb_top.dut.sfi_mst_req_rdy = '0;
            
            wait(aiu_tb_top.dut.sfi_mst_rsp_vld == 0);
            force aiu_tb_top.dut.sfi_mst_rsp_vld = '0;
            force aiu_tb_top.dut.sfi_mst_rsp_rdy = '0;

    <% } else if (obj.testBench == "dce"){ %>
        wait (!(dce_top_tb.dut.sfi_mst_req_vld || dce_top_tb.dut.sfi_slv_rsp_vld));
        force dce_top_tb.dut.sfi_slv_req_vld = '0;
        force dce_top_tb.dut.sfi_slv_rsp_vld = '0;
        force dce_top_tb.dut.sfi_mst_req_vld = '0;
        force dce_top_tb.dut.sfi_mst_rsp_vld = '0;

        force dce_top_tb.dut.sfi_slv_req_rdy = '0;
        force dce_top_tb.dut.sfi_slv_rsp_rdy = '0;
        force dce_top_tb.dut.sfi_mst_req_rdy = '0;
        force dce_top_tb.dut.sfi_mst_rsp_rdy = '0;

    <% } else if (obj.testBench == "aiu"){ %>

            $display("Forcing Agent AIU0  Valid/Ready to 0 at time %t", $realtime);
            
            wait(aiu_tb_top.dut.ace_awvalid == 0);
            force aiu_tb_top.dut.ace_awvalid = '0;
            force aiu_tb_top.dut.ace_awready = '0;

            wait(aiu_tb_top.dut.ace_arvalid == 0);
            force aiu_tb_top.dut.ace_arvalid = '0;
            force aiu_tb_top.dut.ace_arready = '0;

            wait(aiu_tb_top.dut.ace_wvalid == 0);
            force aiu_tb_top.dut.ace_wvalid = '0;
            force aiu_tb_top.dut.ace_wready = '0;

            wait(aiu_tb_top.dut.ace_rvalid == 0);
            force aiu_tb_top.dut.ace_rvalid = '0;
            force aiu_tb_top.dut.ace_rready = '0;

            wait(aiu_tb_top.dut.ace_bvalid == 0);
            force aiu_tb_top.dut.ace_bvalid = '0;
            force aiu_tb_top.dut.ace_bready = '0;

            <% if (obj.AiuInfo[0].fnNativeInterface === "ACE") { %>
            wait(aiu_tb_top.dut.ace_acvalid == 0);
            force aiu_tb_top.dut.ace_acvalid = '0;
            force aiu_tb_top.dut.ace_acready = '0;
            
            wait(aiu_tb_top.dut.ace_crvalid == 0);
            force aiu_tb_top.dut.ace_crvalid = '0;
            force aiu_tb_top.dut.ace_crready = '0;

            wait(aiu_tb_top.dut.ace_cdvalid == 0);
            force aiu_tb_top.dut.ace_cdvalid = '0;
            force aiu_tb_top.dut.ace_cdready = '0;
            <% } %>

            wait(aiu_tb_top.dut.sfi_slv_req_vld == 0);
            force aiu_tb_top.dut.sfi_slv_req_vld = '0;
            force aiu_tb_top.dut.sfi_slv_req_rdy = '0;

            wait(aiu_tb_top.dut.sfi_slv_rsp_vld == 0);
            force aiu_tb_top.dut.sfi_slv_rsp_vld = '0;
            force aiu_tb_top.dut.sfi_slv_rsp_rdy = '0;

            wait(aiu_tb_top.dut.sfi_mst_req_vld == 0);
            force aiu_tb_top.dut.sfi_mst_req_vld = '0;
            force aiu_tb_top.dut.sfi_mst_req_rdy = '0;
            
            wait(aiu_tb_top.dut.sfi_mst_rsp_vld == 0);
            force aiu_tb_top.dut.sfi_mst_rsp_vld = '0;
            force aiu_tb_top.dut.sfi_mst_rsp_rdy = '0;

    <%}%>

    $display("Finish forcing all Valid/Ready at time %t", $realtime);
    //->system_quiesce;
endtask // quiesce_system

/*    <% if (obj.testBench == "psys") { %>
    repeat(500) @(posedge sys_clk);
    <% } else { %>
    repeat(50000) @(posedge tb_clk);
    <% } %>*/

task unquiesce_system();
    $display("Restarting system at time %t", $realtime);
    //@system_restart;

    <% if (obj.testBench == "psys") { %>

        <% for (var pidx = 0; pidx < obj.nAIUs; pidx++) { %>

            $display("Release Forcing AIU<%=pidx%> Valid/Ready at time %t", $realtime);
            @(posedge `AIU<%=pidx%>.clk);
            release `AIU<%=pidx%>.sfi_slv_req_vld;
            release `AIU<%=pidx%>.sfi_slv_rsp_vld;
            release `AIU<%=pidx%>.sfi_mst_req_vld;
            release `AIU<%=pidx%>.sfi_mst_rsp_vld;

            release `AIU<%=pidx%>.sfi_slv_req_rdy;
            release `AIU<%=pidx%>.sfi_slv_rsp_rdy;
            release `AIU<%=pidx%>.sfi_mst_req_rdy;
            release `AIU<%=pidx%>.sfi_mst_rsp_rdy;

        <% } %>

        <% for (var pidx = obj.nAIUs; pidx < obj.nAIUs + obj.nCBIs; pidx++) { %>

            $display("Release Forcing AIU<%=pidx%> (Bridge) Valid/Ready at time %t", $realtime);
            @(posedge `AIU<%=pidx%>.clk);
            release `AIU<%=pidx%>.sfi_slv_req_vld;
            release `AIU<%=pidx%>.sfi_slv_rsp_vld;
            release `AIU<%=pidx%>.sfi_mst_req_vld;
            release `AIU<%=pidx%>.sfi_mst_rsp_vld;

            release `AIU<%=pidx%>.sfi_slv_req_rdy;
            release `AIU<%=pidx%>.sfi_slv_rsp_rdy;
            release `AIU<%=pidx%>.sfi_mst_req_rdy;
            release `AIU<%=pidx%>.sfi_mst_rsp_rdy;

        <% } %>

        <% for (var pidx = 0; pidx < obj.nDCEs; pidx++) { %>

            $display("Release Forcing DCE <%=pidx%> Valid/Ready at time %t", $realtime);
            @(posedge `DCE<%=pidx%>.clk);
            release `DCE<%=pidx%>.sfi_slv_req_vld;
            release `DCE<%=pidx%>.sfi_slv_rsp_vld;
            release `DCE<%=pidx%>.sfi_mst_req_vld;
            release `DCE<%=pidx%>.sfi_mst_rsp_vld;

            release `DCE<%=pidx%>.sfi_slv_req_rdy;
            release `DCE<%=pidx%>.sfi_slv_rsp_rdy;
            release `DCE<%=pidx%>.sfi_mst_req_rdy;
            release `DCE<%=pidx%>.sfi_mst_rsp_rdy;

        <% } %>

        <% for (var pidx = 0; pidx < obj.nDMIs; pidx++) { %>

        <% } %>

    <% } else if (obj.testBench == "dmi") { %>

    $display("Release Forcing Valid/Ready at time %t", $realtime);

        release dmi_tb_top.dut.axi_mst_awvalid;
        release dmi_tb_top.dut.axi_mst_arvalid;
        release dmi_tb_top.dut.axi_mst_wvalid;
        release dmi_tb_top.dut.axi_mst_rvalid;
        release dmi_tb_top.dut.axi_mst_bvalid;

        release dmi_tb_top.dut.axi_mst_awready;
        release dmi_tb_top.dut.axi_mst_arready;
        release dmi_tb_top.dut.axi_mst_wready;
        release dmi_tb_top.dut.axi_mst_rready;
        release dmi_tb_top.dut.axi_mst_bready;

        release dmi_tb_top.dut.sfi_slv_req_vld;
        release dmi_tb_top.dut.sfi_slv_rsp_vld;
        release dmi_tb_top.dut.sfi_mst_req_vld;
        release dmi_tb_top.dut.sfi_mst_rsp_vld;

        release dmi_tb_top.dut.sfi_slv_req_rdy;
        release dmi_tb_top.dut.sfi_slv_rsp_rdy;
        release dmi_tb_top.dut.sfi_mst_req_rdy;
        release dmi_tb_top.dut.sfi_mst_rsp_rdy;

   <% } else if (obj.testBench == "cbi" ) { %>

            $display("Releasing Agent AIU  Valid/Ready to 0 at time %t", $realtime);

            release aiu_tb_top.dut.ace_awvalid ;
            release aiu_tb_top.dut.ace_arvalid ;
            //release aiu_tb_top.dut.ace_wvalid ;
            release aiu_tb_top.dut.ace_rvalid ;
            release aiu_tb_top.dut.ace_bvalid ;


            release aiu_tb_top.dut.ace_awready ;
            release aiu_tb_top.dut.ace_arready ;
            //release aiu_tb_top.dut.ace_wready ;
            release aiu_tb_top.dut.ace_rready ;
            release aiu_tb_top.dut.ace_bready ;


            release aiu_tb_top.dut.sfi_slv_req_vld ;
            release aiu_tb_top.dut.sfi_slv_rsp_vld ;
            release aiu_tb_top.dut.sfi_mst_req_vld ;
            release aiu_tb_top.dut.sfi_mst_rsp_vld ;

            release aiu_tb_top.dut.sfi_slv_req_rdy ;
            release aiu_tb_top.dut.sfi_slv_rsp_rdy ;
            release aiu_tb_top.dut.sfi_mst_req_rdy ;
            release aiu_tb_top.dut.sfi_mst_rsp_rdy ;

   
   
    <% } else if (obj.testBench == "dce") { %>
        release dce_top_tb.dut.sfi_slv_req_vld;
        release dce_top_tb.dut.sfi_slv_rsp_vld;
        release dce_top_tb.dut.sfi_mst_req_vld;
        release dce_top_tb.dut.sfi_mst_rsp_vld;

        release dce_top_tb.dut.sfi_slv_req_rdy;
        release dce_top_tb.dut.sfi_slv_rsp_rdy;
        release dce_top_tb.dut.sfi_mst_req_rdy;
        release dce_top_tb.dut.sfi_mst_rsp_rdy;
    <% } else if (obj.testBench == "aiu"){ %>


            $display("Releasing Agent AIU0  Valid/Ready to 0 at time %t", $realtime);
            
            release aiu_tb_top.dut.ace_awvalid ;
            release aiu_tb_top.dut.ace_arvalid ;
            release aiu_tb_top.dut.ace_wvalid ;
            release aiu_tb_top.dut.ace_rvalid ;
            release aiu_tb_top.dut.ace_bvalid ;

            <% if (obj.AiuInfo[0].fnNativeInterface === "ACE") { %>
            release aiu_tb_top.dut.ace_acvalid ;
            release aiu_tb_top.dut.ace_crvalid ;
            release aiu_tb_top.dut.ace_cdvalid ;
            <% } %>

            release aiu_tb_top.dut.ace_awready ;
            release aiu_tb_top.dut.ace_arready ;
            release aiu_tb_top.dut.ace_wready ;
            release aiu_tb_top.dut.ace_rready ;
            release aiu_tb_top.dut.ace_bready ;


            <% if (obj.AiuInfo[0].fnNativeInterface === "ACE") { %>
            release aiu_tb_top.dut.ace_acready ;
            release aiu_tb_top.dut.ace_crready ;
            release aiu_tb_top.dut.ace_cdready ;
            <% } %>

            release aiu_tb_top.dut.sfi_slv_req_vld ;
            release aiu_tb_top.dut.sfi_slv_rsp_vld ;
            release aiu_tb_top.dut.sfi_mst_req_vld ;
            release aiu_tb_top.dut.sfi_mst_rsp_vld ;

            release aiu_tb_top.dut.sfi_slv_req_rdy ;
            release aiu_tb_top.dut.sfi_slv_rsp_rdy ;
            release aiu_tb_top.dut.sfi_mst_req_rdy ;
            release aiu_tb_top.dut.sfi_mst_rsp_rdy ;


    <%}%>
      endtask // unquiesce_system

//end

// End Quiesce Logics
