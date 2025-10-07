`ifndef <%=obj.BlockId%>_WRITE_PROBE_IF_SV
`define <%=obj.BlockId%>_WRITE_PROBE_IF_SV

///////////////////////////////////////////////////////////////////////////////////////////////
//Interface probes the write arbiter inside DMI to collect time of arrival data for write txns
//////////////////////////////////////////////////////////////////////////////////////////////

import <%=obj.BlockId%>_write_probe_agent_pkg::*;
interface <%=obj.BlockId%>_write_probe_if(input clk, input rst_n);

  parameter     setup_time = 1;
  parameter     hold_time  = 0;

  logic nc_write_valid;
  logic nc_write_ready;
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] nc_write_addr;
  logic nc_write_ns;
  logic nc_write_es;
  logic nc_write_ca;
  logic nc_write_ac;
  logic nc_write_vz;
  logic nc_write_pr;
  logic [31:0] nc_write_trans_id;
  logic [31:0] nc_write_late_resp_id;
  logic [31:0] nc_write_intf_size;
  logic [31:0] nc_write_mpf1;
  logic [31:0] nc_write_mpf2;
  logic [31:0] nc_write_cm_type;
  logic [31:0] nc_write_aiu_id;
  logic [31:0] nc_write_aiu_trans_id;
  logic [31:0] nc_write_size;
  logic [31:0] nc_write_qos;
  logic nc_write_tm;
  logic nc_write_ex_pass;
  
  logic coh_write_valid;
  logic coh_write_ready;
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] coh_write_addr;
  logic coh_write_ns;
  logic coh_write_es;
  logic coh_write_ca;
  logic coh_write_ac;
  logic coh_write_vz;
  logic coh_write_pr;
  logic [31:0] coh_write_trans_id;
  logic [31:0] coh_write_late_resp_id;
  logic [31:0] coh_write_intf_size;
  logic [31:0] coh_write_mpf1;
  logic [31:0] coh_write_mpf2;
  logic [31:0] coh_write_cm_type;
  logic [31:0] coh_write_aiu_id;
  logic [31:0] coh_write_aiu_trans_id;
  logic [31:0] coh_write_size;
  logic [31:0] coh_write_qos;
  logic coh_write_tm;
  logic coh_write_ex_pass;
  logic [31:0] dtw_aiu_src_id;
  
  clocking mon_cb @(negedge clk);
    default input #setup_time output #hold_time;
  
    input nc_write_valid;
    input nc_write_ready;
    input nc_write_addr;
    input nc_write_ns;
    input nc_write_es;
    input nc_write_ca;
    input nc_write_ac;
    input nc_write_vz;
    input nc_write_pr;
    input nc_write_trans_id;
    input nc_write_late_resp_id;
    input nc_write_intf_size;
    input nc_write_mpf1;
    input nc_write_mpf2;
    input nc_write_cm_type;
    input nc_write_aiu_id;
    input nc_write_aiu_trans_id;
    input nc_write_size;
    input nc_write_qos;
    input nc_write_tm;
    input nc_write_ex_pass;
    
    input coh_write_valid;
    input coh_write_ready;
    input coh_write_addr;
    input coh_write_ns;
    input coh_write_es;
    input coh_write_ca;
    input coh_write_ac;
    input coh_write_vz;
    input coh_write_pr;
    input coh_write_trans_id;
    input coh_write_late_resp_id;
    input coh_write_intf_size;
    input coh_write_mpf1;
    input coh_write_mpf2;
    input coh_write_cm_type;
    input coh_write_aiu_id;
    input coh_write_aiu_trans_id;
    input coh_write_size;
    input coh_write_qos;
    input coh_write_tm;
    input coh_write_ex_pass;

    input dtw_aiu_src_id;
  
  endclocking: mon_cb

  task automatic collect_nc_write_packet(ref <%=obj.BlockId%>_write_probe_txn pkt);
    bit done = 0;
    pkt.valid = 0;
    do begin
      @(mon_cb);
      if(mon_cb.nc_write_valid && mon_cb.nc_write_ready) begin
        pkt.t_pkt       = $time;
        pkt.valid       = 1;
        pkt.addr        = mon_cb.nc_write_addr;
        pkt.ns          = mon_cb.nc_write_ns;
        pkt.cmd_type    = mon_cb.nc_write_cm_type;
        pkt.aiu_id      = mon_cb.nc_write_aiu_id;
        pkt.rmsg_id     = mon_cb.nc_write_aiu_trans_id;
        pkt.dtw_aiu_id  = mon_cb.dtw_aiu_src_id;
        pkt.pkt_type    = "NON_COH_WRITE_ARB_PROBE";
        done = 1;
      end
    end while(!done);
  endtask
  
  task automatic collect_coh_write_packet(ref <%=obj.BlockId%>_write_probe_txn pkt);
    bit done = 0;
    pkt.valid = 0;
    do begin
      @(mon_cb);
      if(mon_cb.coh_write_valid && mon_cb.coh_write_ready) begin
        pkt.t_pkt       = $time;
        pkt.valid       = 1;
        pkt.addr        = mon_cb.coh_write_addr;
        pkt.ns          = mon_cb.coh_write_ns;
        pkt.cmd_type    = mon_cb.coh_write_cm_type;
        pkt.aiu_id      = mon_cb.coh_write_aiu_id;
        pkt.rmsg_id     = mon_cb.coh_write_aiu_trans_id;
        pkt.dtw_aiu_id  = mon_cb.dtw_aiu_src_id;
        pkt.pkt_type    = "COH_WRITE_ARB_PROBE";
        done = 1;
      end
    end while(!done);
  endtask
  
endinterface
`endif
