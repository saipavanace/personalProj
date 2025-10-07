
//
//Unit test bench for Address Manager
//

module tb_top();

  `timescale 1ns / 1ps

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import ncore_config_pkg::*;
  import addr_trans_mgr_pkg::*;
  import dce0_chi_agent_pkg::*;
  import chi_unit_test::*;

  logic clk, rst;

  <%=obj.BlockId%>_chi_if m_chi_if(clk, rst);

  //TB-top instantiation

  rtl_top u1 (
    .reset(rst),
    .clock(clk),
    .tx_s_active(m_chi_if.rx_s_active),
    .rx_s_active(m_chi_if.tx_s_active),
    .tx_link_active_req(m_chi_if.rx_link_active_req),
    .tx_link_active_ack(m_chi_if.rx_link_active_ack),
    .rx_link_active_req(m_chi_if.tx_link_active_req),
    .rx_link_active_ack(m_chi_if.tx_link_active_ack),
    .rx_req_flit_pend(m_chi_if.tx_req_flit_pend),
    .rx_req_flitv(m_chi_if.tx_req_flitv),
    .rx_req_flit(m_chi_if.tx_req_flit),
    .rx_req_lcrdv(m_chi_if.tx_req_lcrdv),
    .rx_rsp_flit_pend(m_chi_if.tx_rsp_flit_pend),
    .rx_rsp_flitv(m_chi_if.tx_rsp_flitv),
    .rx_rsp_flit(m_chi_if.tx_rsp_flit),
    .rx_rsp_lcrdv(m_chi_if.tx_rsp_lcrdv),
    .rx_dat_flit_pend(m_chi_if.tx_dat_flit_pend),
    .rx_dat_flitv(m_chi_if.tx_dat_flitv),
    .rx_dat_flit(m_chi_if.tx_dat_flit),
    .rx_dat_lcrdv(m_chi_if.tx_dat_lcrdv),
    .tx_rsp_flit_pend(m_chi_if.rx_rsp_flit_pend),
    .tx_rsp_flitv(m_chi_if.rx_rsp_flitv),
    .tx_rsp_flit(m_chi_if.rx_rsp_flit),
    .tx_rsp_lcrdv(m_chi_if.rx_rsp_lcrdv),
    .tx_dat_flit_pend(m_chi_if.rx_dat_flit_pend),
    .tx_dat_flitv(m_chi_if.rx_dat_flitv),
    .tx_dat_flit(m_chi_if.rx_dat_flit),
    .tx_dat_lcrdv(m_chi_if.rx_dat_lcrdv),
    .tx_snp_flit_pend(m_chi_if.rx_snp_flit_pend),
    .tx_snp_flitv(m_chi_if.rx_snp_flitv),
    .tx_snp_flit(m_chi_if.rx_snp_flit),
    .tx_snp_lcrdv(m_chi_if.rx_snp_lcrdv)
  );

  //Test call
  initial begin
      $timeformat(-9,0,"ns",0);
      `ifdef DUMP_ON
          if($test$plusargs("en_dump")) begin
              <%  if(obj.SYS_CDNS_ACE_VIP) { %>
                  $shm_open("waves.shm");
                  $shm_probe("AS");
              <%  } else { %>
                  $vcdpluson;
              <%  } %>
          end
      `endif
      run_test();
      $finish;
  end

  //UVM config db call
  initial begin
    uvm_config_db #(chi_rn_driver_vif)::set(
      null, "uvm_test_top", "chi_rn_driver_vif", m_chi_if.rn_drv_mp);
    uvm_config_db #(chi_rn_monitor_vif)::set(
      null, "uvm_test_top", "chi_rn_monitor_vif", m_chi_if.rn_mon_mp);
  end

  //rst logic
  initial begin
    rst <= 0;

    repeat (10)
      @(posedge clk);
    #13ns;
    rst <= 1;
  end

  //Clock logic
  initial begin
    clk <= 0;
    forever
      #5ns clk <= ~clk;
  end

endmodule: tb_top
