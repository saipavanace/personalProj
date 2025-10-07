////////////////////////////////////////////////////////////////////////////////
//
// DCE Directory Manager : ATT Activate Request Interface
//
////////////////////////////////////////////////////////////////////////////////

interface att_activate_req_if (input clk, input reset_n);

    parameter wADDR = 40;
    parameter wSFIPRIV = 15;

    //
    // interface signals
    //
    logic att_activate_req_vld
   ;logic [wADDR-1:0] att_activate_txn_addr
   ;logic [wSFIPRIV-1:0] att_activate_txn_sfipriv
   ;logic att_activate_txn_type
   ;logic att_activate_coh_rdy
   ;logic att_activate_upd_rdy
   ;

    //
    // slave modport
    //
    modport slave_mp (
        input att_activate_req_vld
       ,input att_activate_txn_addr
       ,input att_activate_txn_sfipriv
       ,input att_activate_txn_type
       ,output att_activate_coh_rdy
       ,output att_activate_upd_rdy

       ,import reset_slave
       ,import drive_slave
       ,import collect_slave
    );

    initial begin
        $timeformat(-9, 2, " ns", 10);
    end

    initial begin
        @(posedge reset_n);
        reset_slave;
        forever begin
            drive_slave();
        end
    end

//------------------------------------------------------------------------------
// Reset slave interface
//------------------------------------------------------------------------------
    task automatic reset_slave;
        att_activate_coh_rdy <= 'b0;
        att_activate_upd_rdy <= 'b0;
    endtask : reset_slave;

//------------------------------------------------------------------------------
// Drive slave interface
//------------------------------------------------------------------------------
    task automatic drive_slave;
         @(posedge clk);
         att_activate_coh_rdy <= 1'b1;
         att_activate_upd_rdy <= 1'b1;
    endtask : drive_slave;

//------------------------------------------------------------------------------
// Collect slave interface
//------------------------------------------------------------------------------
    task automatic collect_slave;
        output [wADDR-1:0] txn_addr;
        output [wSFIPRIV-1:0] txn_sfipriv;
        output txn_type;
        automatic bit done;
        done = 0;
        do begin
            @(negedge clk);
            if (att_activate_req_vld & (att_activate_coh_rdy | att_activate_upd_rdy)) begin
                txn_addr = att_activate_txn_addr;
                txn_sfipriv = att_activate_txn_sfipriv;
                txn_type = att_activate_txn_type;
                done = 1;
            end
        end while (!done);
        $display("%t att_activate_req_if: type=%x addr=%x sfipriv=%x", $time, txn_type, txn_addr, txn_sfipriv);
    endtask : collect_slave;

//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------
assert_addr_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (att_activate_req_vld) |-> (!$isunknown(att_activate_txn_addr)) );

assert_sfipriv_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (att_activate_req_vld) |-> (!$isunknown(att_activate_txn_sfipriv)) );

assert_type_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (att_activate_req_vld) |-> (!$isunknown(att_activate_txn_type)) );

assert_vld_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(att_activate_req_vld)) );

assert_coh_rdy_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(att_activate_coh_rdy)) );

assert_upd_rdy_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(att_activate_upd_rdy)) );

endinterface : att_activate_req_if

////////////////////////////////////////////////////////////////////////////////
//
// DCE Directory Manager : ATT Activate Response Interface
//
////////////////////////////////////////////////////////////////////////////////

interface att_activate_rsp_if (input clk, input reset_n);

    parameter wATTID = 3;

    //
    // interface signals
    //
    logic att_activate_rsp_vld
   ;logic [wATTID-1:0] att_activate_rsp_attid
   ;logic att_activate_rsp_confl_vld
   ;logic att_activate_rsp_ways_in_use
   ;logic att_activate_rsp_rdy
   ;

    //
    // master modport
    //
    modport master_mp (
        output att_activate_rsp_vld
       ,output att_activate_rsp_attid
       ,output att_activate_rsp_confl_vld
       ,output att_activate_rsp_ways_in_use
       ,input att_activate_rsp_rdy

       ,import reset_master
       ,import drive_master
       ,import collect_master
    );

    initial begin
        $timeformat(-9, 2, " ns", 10);
    end

    initial begin
        @(posedge reset_n);
        reset_master;
    end
//------------------------------------------------------------------------------
// Reset master interface
//------------------------------------------------------------------------------
    task automatic reset_master;
        att_activate_rsp_vld <= 'b0;
        att_activate_rsp_attid <= 'b0;
        att_activate_rsp_confl_vld <= 'b0;
        att_activate_rsp_ways_in_use <= 'b0;
    endtask : reset_master;

//------------------------------------------------------------------------------
// Drive master interface
//------------------------------------------------------------------------------
    task automatic drive_master;
        input [wATTID-1:0] rsp_attid;
        input rsp_confl_vld;
        input rsp_ways_in_use;
        automatic bit done;
        done = 0;
        do begin
            @(posedge clk);
            att_activate_rsp_vld <= 1'b1;
            att_activate_rsp_attid <= rsp_attid;
            att_activate_rsp_confl_vld <= rsp_confl_vld;
            att_activate_rsp_ways_in_use <= rsp_ways_in_use;
            done = att_activate_rsp_vld & att_activate_rsp_rdy;
            if (done) att_activate_rsp_vld <= 1'b0;
        end while (!done);
    endtask : drive_master;

//------------------------------------------------------------------------------
// Collect master interface
//------------------------------------------------------------------------------
    task automatic collect_master;
        output [wATTID-1:0] rsp_attid;
        output rsp_confl_vld;
        output rsp_ways_in_use;
        automatic bit done;
        done = 0;
        do begin
            @(negedge clk);
            if (att_activate_rsp_vld & att_activate_rsp_rdy) begin
                rsp_attid = att_activate_rsp_attid;
                rsp_confl_vld = att_activate_rsp_confl_vld;
                rsp_ways_in_use = att_activate_rsp_ways_in_use;
                done = 1;
            end
        end while (!done);
        $display("%t att_activate_rsp_if: attid=%x confl_vld=%x ways_in_use=%x", $time, rsp_attid, rsp_confl_vld, rsp_ways_in_use);
    endtask : collect_master;

//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------
assert_attid_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (att_activate_rsp_vld) |-> (!$isunknown(att_activate_rsp_attid)) );

assert_confl_vld_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (att_activate_rsp_vld) |-> (!$isunknown(att_activate_rsp_confl_vld)) );

assert_ways_in_use_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (att_activate_rsp_vld) |-> (!$isunknown(att_activate_rsp_ways_in_use)) );

assert_vld_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(att_activate_rsp_vld)) );

assert_rdy_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(att_activate_rsp_rdy)) );

endinterface : att_activate_rsp_if

////////////////////////////////////////////////////////////////////////////////
//
// DCE Directory Manager : DIR Lookup Interface
//
////////////////////////////////////////////////////////////////////////////////

interface dir_lookup_req_if (input clk, input reset_n);

    parameter wADDR = 40;
    parameter wSFIPRIV = 15;

    //
    // interface signals
    //
    logic dir_lookup_req_vld
   ;logic [wADDR-1:0] dir_lookup_txn_addr
   ;logic [wSFIPRIV-1:0] dir_lookup_txn_sfipriv
   ;logic dir_lookup_txn_type
   ;logic dir_lookup_coh_rdy
   ;logic dir_lookup_req_rdy
   ;logic dir_lookup_upd_rdy
   ;

    //
    // master modport
    //
    modport master_mp (
        output dir_lookup_req_vld
       ,output dir_lookup_txn_addr
       ,output dir_lookup_txn_sfipriv
       ,output dir_lookup_txn_type
       ,input dir_lookup_coh_rdy
       ,input dir_lookup_req_rdy
       ,input dir_lookup_upd_rdy

       ,import reset_master
       ,import drive_master
       ,import collect_master
    );

    initial begin
        $timeformat(-9, 2, " ns", 10);
    end

    initial begin
        @(posedge reset_n);
        reset_master;
    end

//------------------------------------------------------------------------------
// Reset master interface
//------------------------------------------------------------------------------
    task automatic reset_master;
        dir_lookup_req_vld <= 'b0;
        dir_lookup_txn_addr <= 'b0;
        dir_lookup_txn_sfipriv <= 'b0;
        dir_lookup_txn_type <= 'b0;
    endtask : reset_master;

//------------------------------------------------------------------------------
// Drive master interface
//------------------------------------------------------------------------------
    task automatic drive_master;
        input [wADDR-1:0] txn_addr;
        input [wSFIPRIV-1:0] txn_sfipriv;
        input txn_type;
        automatic bit done;
        done = 0;
        do begin
            @(posedge clk);
            dir_lookup_req_vld <= 1'b1;
            dir_lookup_txn_addr <= txn_addr;
            dir_lookup_txn_sfipriv <= txn_sfipriv;
            dir_lookup_txn_type <= txn_type;
            done = dir_lookup_req_vld & dir_lookup_req_rdy;
            if (done) dir_lookup_req_vld <= 1'b0;
        end while (!done);
    endtask : drive_master;

//------------------------------------------------------------------------------
// Collect master interface
//------------------------------------------------------------------------------
    task automatic collect_master;
        output [wADDR-1:0] txn_addr;
        output [wSFIPRIV-1:0] txn_sfipriv;
        output txn_type;
        automatic bit done;
        done = 0;
        do begin
            @(negedge clk);
            if (dir_lookup_req_vld & dir_lookup_req_rdy) begin
                txn_addr = dir_lookup_txn_addr;
                txn_sfipriv = dir_lookup_txn_sfipriv;
                txn_type = dir_lookup_txn_type;
                done = 1;
            end
        end while (!done);
        $display("%t dir_lookup_req_if: type=%x addr=%x sfipriv=%x", $time, txn_type, txn_addr, txn_sfipriv);
    endtask : collect_master;

//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------
assert_addr_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (dir_lookup_req_vld) |-> (!$isunknown(dir_lookup_txn_addr)) );

assert_sfipriv_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (dir_lookup_req_vld) |-> (!$isunknown(dir_lookup_txn_sfipriv)) );

assert_type_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (dir_lookup_req_vld) |-> (!$isunknown(dir_lookup_txn_type)) );

assert_vld_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(dir_lookup_req_vld)) );

assert_rdy_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(dir_lookup_req_rdy)) );

assert_coh_rdy_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(dir_lookup_coh_rdy)) );

assert_upd_rdy_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(dir_lookup_upd_rdy)) );

endinterface : dir_lookup_req_if

////////////////////////////////////////////////////////////////////////////////
//
// DCE Directory Manager : DIR Commit Interface
//
////////////////////////////////////////////////////////////////////////////////

interface dir_commit_req_if (input clk, input reset_n);


    parameter wADDR = 40;
    parameter wATTID = 3;
    parameter wOCV = 4;
    parameter wSCV = 4;

    //
    // interface signals
    //
    logic dir_commit_req_vld
   ;logic [wADDR-1:0] dir_commit_req_addr
   ;logic [wATTID-1:0] dir_commit_req_attid
   ;logic [wOCV-1:0] dir_commit_req_ocv
   ;logic [wSCV-1:0] dir_commit_req_scv
   ;logic dir_commit_req_rdy
   ;logic [wATTID-1:0] dir_commit_req_rdy_attid
   ;

    //
    // master modport
    //
    modport master_mp (
        output dir_commit_req_vld
       ,output dir_commit_req_addr
       ,output dir_commit_req_attid
       ,output dir_commit_req_ocv
       ,output dir_commit_req_scv
       ,input dir_commit_req_rdy
       ,input dir_commit_req_rdy_attid

       ,import reset_master
       ,import drive_master
       ,import collect_master
    );

    initial begin
        $timeformat(-9, 2, " ns", 10);
    end

    initial begin
        @(posedge reset_n);
        reset_master;
    end

//------------------------------------------------------------------------------
// Reset master interface
//------------------------------------------------------------------------------
    task automatic reset_master;
        dir_commit_req_vld <= 'b0;
        dir_commit_req_addr <= 'b0;
        dir_commit_req_attid <= 'b0;
        dir_commit_req_ocv <= 'b0;
        dir_commit_req_scv <= 'b0;
    endtask : reset_master;

//------------------------------------------------------------------------------
// Drive master interface
//------------------------------------------------------------------------------
    task automatic drive_master;
        input [wADDR-1:0] req_addr;
        input [wATTID-1:0] req_attid;
        input [wOCV-1:0] req_ocv;
        input [wSCV-1:0] req_scv;
        output [wATTID-1:0] req_rdy_attid;
        automatic bit done;
        done = 0;
        do begin
            @(posedge clk);
            dir_commit_req_vld <= 1'b1;
            dir_commit_req_addr <= req_addr;
            dir_commit_req_attid <= req_attid;
            dir_commit_req_ocv <= req_ocv;
            dir_commit_req_scv <= req_scv;
            req_rdy_attid = dir_commit_req_rdy_attid;
            done = dir_commit_req_rdy;
        end while (!done);
        dir_commit_req_vld <= 1'b0;
    endtask : drive_master;

//------------------------------------------------------------------------------
// Collect master interface
//------------------------------------------------------------------------------
    task automatic collect_master;
        output [wADDR-1:0] req_addr;
        output [wATTID-1:0] req_attid;
        output [wOCV-1:0] req_ocv;
        output [wSCV-1:0] req_scv;
        output [wATTID-1:0] req_rdy_attid;
        automatic bit done;
        done = 0;
        do begin
            @(negedge clk);
            if (dir_commit_req_vld & dir_commit_req_rdy) begin
                req_addr = dir_commit_req_addr;
                req_attid = dir_commit_req_attid;
                req_ocv = dir_commit_req_ocv;
                req_scv = dir_commit_req_scv;
                req_rdy_attid = dir_commit_req_rdy_attid;
                done = 1;
            end
        end while (!done);
        $display("%t dir_commit_req_if: addr=%x attid=%x ocv=%x scv=%x rdy_attid=%x", $time, req_addr, req_attid, req_ocv, req_scv, req_rdy_attid);
    endtask : collect_master;

//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------
assert_addr_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (dir_commit_req_vld) |-> (!$isunknown(dir_commit_req_addr)) );

assert_attid_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (dir_commit_req_vld) |-> (!$isunknown(dir_commit_req_attid)) );

assert_ocv_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (dir_commit_req_vld) |-> (!$isunknown(dir_commit_req_ocv)) );

assert_scv_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (dir_commit_req_vld) |-> (!$isunknown(dir_commit_req_scv)) );

assert_rdy_attid_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (dir_commit_req_rdy) |-> (!$isunknown(dir_commit_req_rdy_attid)) );

assert_rdy_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(dir_commit_req_rdy)) );

assert_vld_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(dir_commit_req_vld)) );

endinterface : dir_commit_req_if

////////////////////////////////////////////////////////////////////////////////
//
// DCE Directory Manager : DIR Response Interface
//
////////////////////////////////////////////////////////////////////////////////

interface dir_rsp_if (input clk, input reset_n);

    parameter wATTID = 3;
    parameter wOLV = 4;
    parameter wSLV = 4;

    //
    // interface signals
    //
    logic dir_rsp_rdy
   ;logic dir_rsp_commit_vld
   ;logic dir_rsp_lookup_vld
   ;logic [wATTID-1:0] dir_rsp_attid
   ;logic [wOLV-1:0] dir_rsp_olv
   ;logic [wSLV-1:0] dir_rsp_slv
   ;

    //
    // slave modport
    //
    modport slave_mp (
        output dir_rsp_rdy
       ,input dir_rsp_commit_vld
       ,input dir_rsp_lookup_vld
       ,input dir_rsp_attid
       ,input dir_rsp_olv
       ,input dir_rsp_slv

       ,import reset_slave
       ,import drive_slave
       ,import collect_slave
    );

    initial begin
        $timeformat(-9, 2, " ns", 10);
    end

    initial begin
        @(posedge reset_n);
        reset_slave;
        forever begin
            drive_slave();
        end
    end
//------------------------------------------------------------------------------
// Reset slave interface
//------------------------------------------------------------------------------
    task automatic reset_slave;
        dir_rsp_rdy <= 'b0;
    endtask : reset_slave;

//------------------------------------------------------------------------------
// Drive slave interface
//------------------------------------------------------------------------------
    task automatic drive_slave;
        @(posedge clk);
        dir_rsp_rdy <= 1;
    endtask : drive_slave;

//------------------------------------------------------------------------------
// Collect slave interface
//------------------------------------------------------------------------------
    task automatic collect_slave;
        output [wATTID-1:0] rsp_attid;
        output [wOLV-1:0] rsp_olv;
        output [wSLV-1:0] rsp_slv;
        output rsp_lookup;
        output rsp_commit;
        automatic bit done;
        done = 0;
        do begin
            @(negedge clk);
            if ((dir_rsp_commit_vld | dir_rsp_lookup_vld) & dir_rsp_rdy) begin
                rsp_attid = dir_rsp_attid;
                rsp_olv = dir_rsp_olv;
                rsp_slv = dir_rsp_slv;
                rsp_lookup = dir_rsp_lookup_vld;
                rsp_commit= dir_rsp_commit_vld;
                done = 1;
            end
        end while (!done);
        $display("%t dir_rsp_if: lookup=%x commit=%x attid=%x olv=%x slv=%x", $time, rsp_lookup, rsp_commit, rsp_attid, rsp_olv, rsp_slv);
    endtask : collect_slave;

//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------
assert_attid_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    ((dir_rsp_commit_vld | dir_rsp_lookup_vld)) |-> (!$isunknown(dir_rsp_attid)) );

assert_olv_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    ((dir_rsp_commit_vld | dir_rsp_lookup_vld)) |-> (!$isunknown(dir_rsp_olv)) );

assert_slv_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    ((dir_rsp_commit_vld | dir_rsp_lookup_vld)) |-> (!$isunknown(dir_rsp_slv)) );

assert_commit_vld_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(dir_rsp_commit_vld)) );

assert_lookup_vld_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(dir_rsp_lookup_vld)) );

assert_rdy_not_x_z:
  assert property( @(posedge clk) disable iff (~reset_n)
    (!$isunknown(dir_rsp_rdy)) );

endinterface : dir_rsp_if

////////////////////////////////////////////////////////////////////////////////

