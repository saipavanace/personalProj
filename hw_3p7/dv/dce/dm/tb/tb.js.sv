module tb;

    `timescale 1ns / 1ps
// <%=obj.AiuInfo.length%>
    //----------------------------------------------------------------------------
    // Parameters
    //----------------------------------------------------------------------------
    parameter wADDR = 40;
    parameter wSFIPRIV = 15;
    parameter wATTID = 3;
    parameter wOCV = 4;
    parameter wSCV = 4;
    parameter wOLV = 4;
    parameter wSLV = 4;

    //----------------------------------------------------------------------------
    // Includes
    //----------------------------------------------------------------------------
    `include "dm_transaction.svh"

    //----------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------
    // Configuration
    int num_trans;
    int num_addrs;
    int max_cycles;

    // Lists for stimulus generation
    dir_lookup_packet_t stim_dir_lookup_pkts [$];

    // Lists for packet collection
    dir_lookup_packet_t dir_lookup_pkts [$];
    dir_commit_packet_t dir_commit_pkts [$];
    dir_rsp_packet_t dir_rsp_lookup_pkts [$];
    dir_rsp_packet_t dir_rsp_commit_pkts [$];
    att_act_req_packet_t att_act_req_pkts [$];
    att_act_rsp_packet_t att_act_rsp_pkts [$];

    bit [wADDR-1:-0] addrpool [$];

    // Maps
    dir_commit_packet_t dir_commit_map [bit [wADDR-1:0]];

    //----------------------------------------------------------------------------
    // Signals
    //----------------------------------------------------------------------------
    logic clk
   ;logic reset_n
   ;

    //----------------------------------------------------------------------------
    // BFMs
    //----------------------------------------------------------------------------
    dir_lookup_req_if # (
        .wADDR(wADDR)
       ,.wSFIPRIV(wSFIPRIV)
    ) dir_lookup_req_if_ins (
        .clk(clk)
       ,.reset_n(reset_n)
    );

    dir_commit_req_if # (
        .wADDR(wADDR)
       ,.wATTID(wATTID)
       ,.wOCV(wOCV)
       ,.wSCV(wSCV)
    ) dir_commit_req_if_ins (
        .clk(clk)
       ,.reset_n(reset_n)
    );

    att_activate_rsp_if # (
        .wATTID(wATTID)
    ) att_activate_rsp_if_ins (
        .clk(clk)
       ,.reset_n(reset_n)
    );

    att_activate_req_if # (
        .wADDR(wADDR)
       ,.wSFIPRIV(wSFIPRIV)
    ) att_activate_req_if_ins (
        .clk(clk)
       ,.reset_n(reset_n)
    );

    dir_rsp_if # (
        .wATTID(wATTID)
       ,.wOLV(wOLV)
       ,.wSLV(wSLV)
    ) dir_rsp_if_ins (
        .clk(clk)
       ,.reset_n(reset_n)
    );

    //----------------------------------------------------------------------------
    // Collecting packets on DUT interfaces
    //----------------------------------------------------------------------------
    initial begin
        dir_commit_packet_t p;
        forever begin
            dir_commit_req_if_ins.collect_master(p.addr, p.attid, p.ocv, p.scv, p.rdy_attid);
            p.timestamp = $time;
            dir_commit_pkts.push_back(p);
            dir_commit_map [p.addr] = p;
        end
    end

    initial begin
        dir_lookup_packet_t p;
        forever begin
            dir_lookup_req_if_ins.collect_master(p.addr, p.sfipriv, p.reqtype);
            p.timestamp = $time;
            dir_lookup_pkts.push_back(p);
        end
    end

    initial begin
        dir_rsp_packet_t p;
        forever begin
            dir_rsp_if_ins.collect_slave(p.attid, p.olv, p.slv, p.lookup, p.commit);
            p.timestamp = $time;
            if (p.lookup) dir_rsp_lookup_pkts.push_back(p);
            if (p.commit) dir_rsp_commit_pkts.push_back(p);
        end
    end

    initial begin
        att_act_req_packet_t p;
        forever begin
            att_activate_req_if_ins.collect_slave(p.addr, p.sfipriv, p.reqtype);
            p.timestamp = $time;
            att_act_req_pkts.push_back(p);
        end
    end

    initial begin
        att_act_rsp_packet_t p;
        forever begin
            att_activate_rsp_if_ins.collect_master(p.attid, p.confl_vld, p.ways_in_use);
            p.timestamp = $time;
            att_act_rsp_pkts.push_back(p);
        end
    end

    //----------------------------------------------------------------------------
    // Responders
    //----------------------------------------------------------------------------
    // Driving att_activate_rsp_if by processing packets captured from att_activate_req_if
    initial begin
        att_act_req_packet_t req;
        att_act_rsp_packet_t rsp;
        bit [wATTID-1:0] attid;
        int idx;
        idx = 0;
        forever begin
            idle_cycle(1);
            if (att_act_req_pkts.size() > idx) begin
                req = att_act_req_pkts[idx];
                rsp.attid = attid;
                rsp.confl_vld = $urandom_range(0, 1);
                rsp.ways_in_use = $urandom_range(0, 1);
                att_activate_rsp_if_ins.drive_master(rsp.attid, rsp.confl_vld, rsp.ways_in_use);
                attid++;
                idx++;
            end
        end
    end

    // Driving dir_commit_req_if by processing packets captured from att_activate_req_if and att_activate_rsp_if
    initial begin
        att_act_req_packet_t req;
        att_act_rsp_packet_t rsp;
        dir_commit_packet_t p;
        int idx;
        idx = 0;
        forever begin
            idle_cycle(1);
            if ((att_act_req_pkts.size() > idx) && (att_act_rsp_pkts.size() > idx)) begin
                req = att_act_req_pkts[idx];
                rsp = att_act_rsp_pkts[idx];
                p.addr = req.addr;
                p.attid = rsp.attid;
                p.ocv = $urandom_range(0, wOCV);
                p.scv = $urandom_range(0, wSCV);
                dir_commit_req_if_ins.drive_master(p.addr, p.attid, p.ocv, p.scv, p.rdy_attid);
                idx++;
            end
        end
    end

    //----------------------------------------------------------------------------
    // Stimulus
    //----------------------------------------------------------------------------
    // Driving dir_lookup_req_if by processing packets rendered by test in stim_dir_lookup_pkts
    initial begin
        dir_lookup_packet_t p;
        forever begin
            idle_cycle(1);
            if (stim_dir_lookup_pkts.size()) begin
                p = stim_dir_lookup_pkts[0];
                if ((p.timestamp == 0) || ($time > p.timestamp)) begin
                    dir_lookup_req_if_ins.drive_master(p.addr, p.sfipriv, p.reqtype);
                    idle_cycle($urandom_range(0, 3));
                    stim_dir_lookup_pkts.pop_front();
                end else begin
                    do begin
                        idle_cycle(1);
                    end while ($time > p.timestamp);
                    dir_lookup_req_if_ins.drive_master(p.addr, p.sfipriv, p.reqtype);
                    stim_dir_lookup_pkts.pop_front();
                end
            end
        end
    end

    //----------------------------------------------------------------------------
    // Checkers
    //----------------------------------------------------------------------------
    // att_act_req_pkts must match dir_lookup_req_pkts
    initial begin
        att_act_req_packet_t req;
        dir_lookup_packet_t  p;
        int idx;
        idx = 0;
        forever begin
            idle_cycle(1);
            if ((att_act_req_pkts.size() > idx) && (dir_lookup_pkts.size() > idx)) begin
                req = att_act_req_pkts[idx];
                p = dir_lookup_pkts[idx];
                if (req.addr != p.addr) begin
                    $display("%t ERROR: att_act_req_pkts[%0d].addr does not match dir_lookup_pkts[%0d].addr : rcv=%p exp=%p", $time, idx, idx, req.addr, p.addr);
                end
                if (req.sfipriv != p.sfipriv) begin
                    $display("%t ERROR: att_act_req_pkts[%0d].sfipriv does not match dir_lookup_pkts[%0d].sfipriv : rcv=%p exp=%p", $time, idx, idx, req.sfipriv, p.sfipriv);
                end
                if (req.reqtype != p.reqtype) begin
                    $display("%t ERROR: att_act_req_pkts[%0d].reqtype does not match dir_lookup_pkts[%0d].reqtype : rcv=%p exp=%p", $time, idx, idx, req.reqtype, p.reqtype);
                end
                idx++;
            end
        end
    end

    // dir_rsp_commit_pkts must match dir_commit_pkts
    initial begin
        dir_rsp_packet_t     req;
        dir_commit_packet_t  p;
        int idx;
        idx = 0;
        forever begin
            idle_cycle(1);
            if ((dir_rsp_commit_pkts.size() > idx) && (dir_commit_pkts.size() > idx)) begin
                req = dir_rsp_commit_pkts[idx];
                p = dir_commit_pkts[idx];
                if (req.attid != p.attid) begin
                    $display("%t ERROR: dir_rsp_commit_pkts[%0d].attid does not match dir_commit_pkts[%0d].attid : rcv=%p exp=%p", $time, idx, idx, req.attid, p.attid);
                end
                if (req.olv != p.ocv) begin
                    $display("%t ERROR: dir_rsp_commit_pkts[%0d].olv does not match dir_commit_pkts[%0d].ocv : rcv=%p exp=%p", $time, idx, idx, req.olv, p.ocv);
                end
                if (req.slv != p.scv) begin
                    $display("%t ERROR: dir_rsp_commit_pkts[%0d].slv does not match dir_commit_pkts[%0d].scv : rcv=%p exp=%p", $time, idx, idx, req.slv, p.scv);
                end
                idx++;
            end
        end
    end

    // dir_rsp_lookup_pkts must match dir_lookup_pkts and dir_commit_map
    initial begin
        dir_rsp_packet_t     req;
        dir_lookup_packet_t  p;
        dir_commit_packet_t  c;
        int idx;
        idx = 0;
        forever begin
            idle_cycle(1);
            if ((dir_rsp_lookup_pkts.size() > idx) && (dir_lookup_pkts.size() > idx)) begin
                req = dir_rsp_lookup_pkts[idx];
                p = dir_lookup_pkts[idx];
                if (dir_commit_map.exists(p.addr)) begin
                    c = dir_commit_map [p.addr];
                    if (req.attid != c.attid) begin
                        $display("%t ERROR: dir_rsp_lookup_pkts[%0d].attid does not match dir_commit_map[%x].attid : rcv=%p exp=%p", $time, idx, p.addr, req.attid, c.attid);
                    end
                    if (req.olv != c.ocv) begin
                        $display("%t ERROR: dir_rsp_lookup_pkts[%0d].olv does not match dir_commit_map[%x].ocv : rcv=%p exp=%p", $time, idx, p.addr, req.olv, c.ocv);
                    end
                    if (req.slv != c.scv) begin
                        $display("%t ERROR: dir_rsp_lookup_pkts[%0d].slv does not match dir_commit_map[%x].scv : rcv=%p exp=%p", $time, idx, p.addr, req.slv, c.scv);
                    end
                end
                idx++;
            end
        end
    end

    //----------------------------------------------------------------------------
    // DUT
    //----------------------------------------------------------------------------
    top__coh__dce__dirm dut (
        // inputs
        .clk (clk)
       ,.reset_n (reset_n)
       ,.att_activate_coh_rdy(att_activate_req_if_ins.att_activate_coh_rdy)
       ,.att_activate_rsp_attid(att_activate_rsp_if_ins.att_activate_rsp_attid)
       ,.att_activate_rsp_confl_vld(att_activate_rsp_if_ins.att_activate_rsp_confl_vld)
       ,.att_activate_rsp_vld(att_activate_rsp_if_ins.att_activate_rsp_vld)
       ,.att_activate_rsp_ways_in_use(att_activate_rsp_if_ins.att_activate_rsp_ways_in_use)
       ,.att_activate_upd_rdy(att_activate_req_if_ins.att_activate_upd_rdy)
       ,.dir_commit_req_addr(dir_commit_req_if_ins.dir_commit_req_addr)
       ,.dir_commit_req_aiuid(2'b0)
       ,.dir_commit_req_attid(dir_commit_req_if_ins.dir_commit_req_attid)
       ,.dir_commit_req_ocv(dir_commit_req_if_ins.dir_commit_req_ocv)
       ,.dir_commit_req_scv(dir_commit_req_if_ins.dir_commit_req_scv)
       ,.dir_commit_req_vld(dir_commit_req_if_ins.dir_commit_req_vld)
       ,.dir_commit_req_way_to_use(3'b0)
       ,.coh_req_vld(dir_lookup_req_if_ins.dir_lookup_req_vld)
       ,.coh_req_addr(dir_lookup_req_if_ins.dir_lookup_txn_addr)
       ,.coh_req_sfipriv(dir_lookup_req_if_ins.dir_lookup_txn_sfipriv)
       ,.dir_rsp_rdy(dir_rsp_if_ins.dir_rsp_rdy)
       ,.upd_req_addr(40'b0)
       ,.upd_req_sfipriv(15'b0)
       ,.upd_req_vld(1'b0)

        // outputs
       ,.att_activate_filter_num()
       ,.att_activate_req_vld(att_activate_req_if_ins.att_activate_req_vld)
       ,.att_activate_rsp_rdy(att_activate_rsp_if_ins.att_activate_rsp_rdy)
       ,.att_activate_txn_addr(att_activate_req_if_ins.att_activate_txn_addr)
       ,.att_activate_txn_sfipriv(att_activate_req_if_ins.att_activate_txn_sfipriv)
       ,.att_activate_txn_type(att_activate_req_if_ins.att_activate_txn_type)
       ,.dir_commit_req_rdy(dir_commit_req_if_ins.dir_commit_req_rdy)
       ,.dir_commit_req_rdy_attid(dir_commit_req_if_ins.dir_commit_req_rdy_attid)
       ,.coh_req_rdy(dir_lookup_req_if_ins.dir_lookup_coh_rdy)
       ,.upd_req_rdy(dir_lookup_req_if_ins.dir_lookup_upd_rdy)
       ,.dir_rsp_attid(dir_rsp_if_ins.dir_rsp_attid)
       ,.dir_rsp_commit_vld(dir_rsp_if_ins.dir_rsp_commit_vld)
       ,.dir_rsp_lookup_vld(dir_rsp_if_ins.dir_rsp_lookup_vld)
       ,.dir_rsp_olv(dir_rsp_if_ins.dir_rsp_olv)
       ,.dir_rsp_slv(dir_rsp_if_ins.dir_rsp_slv)
       ,.dir_rsp2_attid()
       ,.dir_rsp2_valid()
       ,.dir_rsp2_way_to_use()
    );

    assign dir_lookup_req_if_ins.dir_lookup_req_rdy = dir_lookup_req_if_ins.dir_lookup_coh_rdy;

    //----------------------------------------------------------------------------
    // Functions
    //----------------------------------------------------------------------------
    function void parse(output string out [], input byte separator, input string in);
        int index [$]; // queue
        foreach(in[i]) begin // find commas
            if (in[i]==separator) begin
                index.push_back(i-1); // index before comma
                index.push_back(i+1); // index after comma
            end
        end
        index.push_front(0); // first index
        index.push_back(in.len()-1); // last index
        out = new[index.size()/2];
        foreach (out[i]) begin
            out[i] = in.substr(index[2*i],index[2*i+1]);
            //$display("cmd[%0d] == in.substr(%0d,%0d) == \"%s\"", i, index[2*i],index[2*i+1], out[i]);
        end
    endfunction : parse

    function dump_packets;
        $display("BEGIN of dump_packets()---------------------------------------");
        for (int i=0; i<dir_lookup_pkts.size(); i++) $display("%t dir_lookup_pkts[%0d]=%p", dir_lookup_pkts[i].timestamp, i, dir_lookup_pkts[i]);
        for (int i=0; i<att_act_req_pkts.size(); i++) $display("%t att_act_req_pkts[%0d]=%p", att_act_req_pkts[i].timestamp, i, att_act_req_pkts[i]);
        for (int i=0; i<att_act_rsp_pkts.size(); i++) $display("%t att_act_rsp_pkts[%0d]=%p", att_act_rsp_pkts[i].timestamp, i, att_act_rsp_pkts[i]);
        for (int i=0; i<dir_commit_pkts.size(); i++) $display("%t dir_commit_pkts[%0d]=%p", dir_commit_pkts[i].timestamp, i, dir_commit_pkts[i]);
        for (int i=0; i<dir_rsp_lookup_pkts.size(); i++) $display("%t dir_rsp_lookup_pkts[%0d]=%p", dir_rsp_lookup_pkts[i].timestamp, i, dir_rsp_lookup_pkts[i]);
        for (int i=0; i<dir_rsp_commit_pkts.size(); i++) $display("%t dir_rsp_commit_pkts[%0d]=%p", dir_rsp_commit_pkts[i].timestamp, i, dir_rsp_commit_pkts[i]);
        $display("END of dump_packets()-----------------------------------------");
    endfunction : dump_packets

    //----------------------------------------------------------------------------
    // Tasks
    //----------------------------------------------------------------------------
    task idle_cycle;
        input int num;
        for (int i=0; i < num; i++) @(posedge clk);
    endtask : idle_cycle;

    //----------------------------------------------------------------------------
    // $plusargs
    //----------------------------------------------------------------------------
    initial begin
        string addr[];
        string plusarg_string;
        dir_lookup_transaction txn;
        dir_lookup_packet_t    p;

        if (!$value$plusargs("num_trans=%0d", num_trans)) begin
            num_trans = 5;
        end
        if (!$value$plusargs("num_addrs=%0d", num_addrs)) begin
            num_addrs = 3;
        end
        if (!$value$plusargs("max_cycles=%0d", max_cycles)) begin
            max_cycles = 10000;
        end

        if ( $value$plusargs("addr=%s",plusarg_string) ) begin
            parse(addr, ",", plusarg_string);
        end
        foreach(addr[i]) begin
            $display("addr[%0d]:'%s'",i,addr[i]);
            addrpool.push_back(addr[i].atohex);
        end
        if (addrpool.size() == 0) begin
            for (int i=0; i < num_addrs; i++) begin
                txn = new();
                txn.randomize();
                p = txn.dir_lookup_pkt;
                addrpool.push_back(p.addr);
            end
        end
        $display("addrpool=%p",addrpool);
    end

    //----------------------------------------------------------------------------
    // Run test
    //----------------------------------------------------------------------------
    initial begin
        $timeformat(-9, 2, " ns", 10);
        $vcdpluson;
        @(posedge reset_n);
        fork
          run_test();
          run_watchdog_timer();
        join_any
        repeat (100) @(posedge clk);
        //dump_packets();
        $finish;
    end

    task automatic run_test();
        dir_lookup_transaction txn;
        dir_lookup_packet_t    p;
        // startup time
        idle_cycle(10);
        // render stimulus packets
        for (int i=0; i < num_trans; i++) begin
            txn = new();
            txn.randomize();
            p = txn.dir_lookup_pkt;
            p.addr = addrpool[$urandom_range(0, addrpool.size()-1)];
            stim_dir_lookup_pkts.push_back(p);
        end
        // wait for stimulus to be completely drained
        do begin
            idle_cycle(1);
        end while (stim_dir_lookup_pkts.size());
        // drain time for transaction to finish
        idle_cycle(20);
    endtask : run_test

    task automatic run_watchdog_timer();
        repeat (max_cycles) @(posedge clk);
        $display("ERROR!! watchdog_timer times out!!");
        $finish;
    endtask : run_watchdog_timer

    //----------------------------------------------------------------------------
    // Clock and reset
    //----------------------------------------------------------------------------
    initial begin
      clk = 0;
      reset_n = 0;
      repeat(8) begin
        #5ns clk = ~clk;
      end
      reset_n = 1;
      forever begin
        #5ns clk = ~clk;
      end
    end // initial begin
   
endmodule : tb
