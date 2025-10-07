////////////////////////////////////////////////////////////////////////////////
//
// DCE Directory Manager : ATT Activate Request Interface
//
////////////////////////////////////////////////////////////////////////////////

    typedef struct {

        rand bit [wADDR-1:0] addr;
        rand bit [wSFIPRIV-1:0] sfipriv;
        rand bit reqtype;
        time timestamp;

    } dir_lookup_packet_t;

    typedef struct {

        rand bit [wADDR-1:0] addr;
        rand bit [wATTID-1:0] attid;
        rand bit [wOCV-1:0] ocv;
        rand bit [wSCV-1:0] scv;
        rand bit [wATTID-1:0] rdy_attid;
        time timestamp;

    } dir_commit_packet_t;

    typedef struct {

        rand bit lookup;
        rand bit commit;
        rand bit [wATTID-1:0] attid;
        rand bit [wOLV-1:0] olv;
        rand bit [wSLV-1:0] slv;
        time timestamp;

    } dir_rsp_packet_t;

    typedef struct {

        rand bit [wADDR-1:0] addr;
        rand bit [wSFIPRIV-1:0] sfipriv;
        rand bit reqtype;
        time timestamp;

    } att_act_req_packet_t;

    typedef struct {

        rand bit [wATTID-1:0] attid;
        rand bit confl_vld;
        rand bit ways_in_use;
        time timestamp;

    } att_act_rsp_packet_t;


    class dir_lookup_transaction;
        rand dir_lookup_packet_t dir_lookup_pkt;
        bit dir_lookup_req_vld;
        bit dir_lookup_coh_rdy;
        bit dir_lookup_req_rdy;
        bit dir_lookup_upd_rdy;
    endclass : dir_lookup_transaction

    class dir_commit_transaction;
        rand dir_commit_packet_t dir_commit_pkt;
        bit dir_commit_req_vld;
        bit dir_commit_req_rdy;
    endclass : dir_commit_transaction

    class dir_rsp_transaction;
        rand dir_rsp_packet_t dir_rsp_pkt;
        bit dir_rsp_commit_vld;
        bit dir_rsp_lookup_vld;
        bit dir_rsp_rdy;
    endclass : dir_rsp_transaction

    class att_act_req_transaction;
        rand att_act_req_packet_t att_activate_req_pkt;
        bit att_activate_req_vld;
        bit att_activate_coh_rdy;
        bit att_activate_upd_rdy;
    endclass : att_act_req_transaction

    class att_act_rsp_transaction;
        rand att_act_rsp_packet_t att_activate_rsp_pkt;
        bit att_activate_rsp_vld;
        bit att_activate_rsp_rdy;
    endclass : att_act_rsp_transaction

////////////////////////////////////////////////////////////////////////////////
