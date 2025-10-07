`ifndef <%=obj.BlockId%>_READ_PROBE_IF_SV
`define <%=obj.BlockId%>_READ_PROBE_IF_SV

//////////////////////////////////////////////////////////////////////////////////////////////
//Interface probes the read arbiter inside DMI to collect time of arrival data for read txns
//////////////////////////////////////////////////////////////////////////////////////////////

import <%=obj.BlockId%>_read_probe_agent_pkg::*;
interface <%=obj.BlockId%>_read_probe_if(input clk, input rst_n);

  parameter     setup_time = 1;
  parameter     hold_time  = 0;

  logic nc_read_valid;
  logic nc_read_ready;
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] nc_read_addr;
  logic nc_read_ns;
  logic nc_read_es;
  logic nc_read_ca;
  logic nc_read_ac;
  logic nc_read_vz;
  logic nc_read_pr;
  logic [31:0] nc_read_trans_id;
  logic [31:0] nc_read_late_resp_id;
  logic [31:0] nc_read_intf_size;
  logic [31:0] nc_read_mpf1;
  logic [31:0] nc_read_mpf2;
  logic [31:0] nc_read_cm_type;
  logic [31:0] nc_read_aiu_id;
  logic [31:0] nc_read_aiu_trans_id;
  logic [31:0] nc_read_size;
  logic [31:0] nc_read_qos;
  logic nc_read_tm;
  logic nc_read_ex_pass;
  
  logic coh_read_valid;
  logic coh_read_ready;
  logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] coh_read_addr;
  logic coh_read_ns;
  logic coh_read_es;
  logic coh_read_ca;
  logic coh_read_ac;
  logic coh_read_vz;
  logic coh_read_pr;
  logic [31:0] coh_read_trans_id;
  logic [31:0] coh_read_late_resp_id;
  logic [31:0] coh_read_intf_size;
  logic [31:0] coh_read_mpf1;
  logic [31:0] coh_read_mpf2;
  logic [31:0] coh_read_cm_type;
  logic [31:0] coh_read_aiu_id;
  logic [31:0] coh_read_aiu_trans_id;
  logic [31:0] coh_read_size;
  logic [31:0] coh_read_qos;
  logic coh_read_tm;
  logic coh_read_ex_pass;
  
  clocking mon_cb @(negedge clk);
    default input #setup_time output #hold_time;
  
    input nc_read_valid;
    input nc_read_ready;
    input nc_read_addr;
    input nc_read_ns;
    input nc_read_es;
    input nc_read_ca;
    input nc_read_ac;
    input nc_read_vz;
    input nc_read_pr;
    input nc_read_trans_id;
    input nc_read_late_resp_id;
    input nc_read_intf_size;
    input nc_read_mpf1;
    input nc_read_mpf2;
    input nc_read_cm_type;
    input nc_read_aiu_id;
    input nc_read_aiu_trans_id;
    input nc_read_size;
    input nc_read_qos;
    input nc_read_tm;
    input nc_read_ex_pass;
    
    input coh_read_valid;
    input coh_read_ready;
    input coh_read_addr;
    input coh_read_ns;
    input coh_read_es;
    input coh_read_ca;
    input coh_read_ac;
    input coh_read_vz;
    input coh_read_pr;
    input coh_read_trans_id;
    input coh_read_late_resp_id;
    input coh_read_intf_size;
    input coh_read_mpf1;
    input coh_read_mpf2;
    input coh_read_cm_type;
    input coh_read_aiu_id;
    input coh_read_aiu_trans_id;
    input coh_read_size;
    input coh_read_qos;
    input coh_read_tm;
    input coh_read_ex_pass;
  
  endclocking: mon_cb

  task automatic collect_nc_read_packet(ref <%=obj.BlockId%>_read_probe_txn pkt);
    bit done = 0;
    pkt.valid = 0;
    do begin
      @(mon_cb);
      if(mon_cb.nc_read_valid && mon_cb.nc_read_ready) begin
        pkt.t_pkt       = $time;
        pkt.valid       = 1;
        pkt.addr        = mon_cb.nc_read_addr;
        pkt.ns          = mon_cb.nc_read_ns;
        pkt.cmd_type    = mon_cb.nc_read_cm_type;
        pkt.aiu_id      = mon_cb.nc_read_aiu_id;
        pkt.rmsg_id     = mon_cb.nc_read_aiu_trans_id;
        pkt.pkt_type    = "NON_COH_READ_ARB_PROBE";
        done = 1;
      end
    end while(!done);
  endtask
  
  task automatic collect_coh_read_packet(ref <%=obj.BlockId%>_read_probe_txn pkt);
    bit done = 0;
    pkt.valid = 0;
    do begin
      @(mon_cb);
      if(mon_cb.coh_read_valid && mon_cb.coh_read_ready) begin
        pkt.t_pkt       = $time;
        pkt.valid       = 1;
        pkt.addr        = mon_cb.coh_read_addr;
        pkt.ns          = mon_cb.coh_read_ns;
        pkt.cmd_type    = mon_cb.coh_read_cm_type;
        pkt.aiu_id      = mon_cb.coh_read_aiu_id;
        pkt.rmsg_id     = mon_cb.coh_read_aiu_trans_id;
        pkt.pkt_type    = "COH_READ_ARB_PROBE";
        done = 1;
      end
    end while(!done);
  endtask
  
endinterface
`endif
