interface chi_if #(parameter WREQFLIT=0, WRSPFLIT=0, WDATFLIT=0, WSNPFLIT=0);
    // parameter WREQFLIT=128;
    // parameter WRSPFLIT=128;
    // parameter WDATFLIT=128;
    // parameter WSNPFLIT=128;
    //===================================
    //Interface Specific Signals
    //===================================
    logic                                             tx_sactive;
    logic                                             rx_sactive;

    logic                                             sysco_req;
    logic                                             sysco_ack;

    //===================================
    //TxLink specific signals
    //===================================
    logic                                             tx_link_active_req;
    logic                                             tx_link_active_ack;

    //===================================
    //RxLink specific signals
    //===================================
    logic                                             rx_link_active_req;
    logic                                             rx_link_active_ack;

    //===================================
    //TxREQ channel interface signals
    //===================================
    logic                                             tx_req_flit_pend;
    logic                                             tx_req_flitv;
    logic [WREQFLIT-1: 0]                             tx_req_flit;
    logic                                             tx_req_lcrdv;

    //===================================
    //TxRSP channel interface signals
    //===================================
    logic                                             tx_rsp_flit_pend;
    logic                                             tx_rsp_flitv;
    logic [WRSPFLIT-1: 0]                             tx_rsp_flit;
    logic                                             tx_rsp_lcrdv;

    //===================================
    //TxDAT channel interface signals
    //===================================
    logic                                             tx_dat_flit_pend;
    logic                                             tx_dat_flitv;
    logic [WDATFLIT-1: 0]                             tx_dat_flit;
    logic                                             tx_dat_lcrdv;

    //===================================
    //RxRSP channel interface signals
    //===================================
    logic                                             rx_rsp_flit_pend;
    logic                                             rx_rsp_flitv;
    logic [WRSPFLIT-1: 0]                             rx_rsp_flit;
    logic                                             rx_rsp_lcrdv;

    //===================================
    //RxDAT channel interface signals
    //===================================
    logic                                             rx_dat_flit_pend;
    logic                                             rx_dat_flitv;
    logic [WDATFLIT-1: 0]                             rx_dat_flit;
    logic                                             rx_dat_lcrdv;

    //===================================
    //RxSNP channel interface signals
    //===================================
    logic                                             rx_snp_flit_pend;
    logic                                             rx_snp_flitv;
    logic [WSNPFLIT-1: 0]                             rx_snp_flit;
    logic                                             rx_snp_lcrdv;

    //===================================
    //RxREQ channel interface signals
    //===================================
    logic                                             rx_req_flit_pend;
    logic                                             rx_req_flitv;
    logic [WREQFLIT-1: 0]                             rx_req_flit;
    logic                                             rx_req_lcrdv;

    //===================================
    // Interface Parity signals
    //===================================

    logic                                             tx_sactive_chk;
    logic                                             rx_sactive_chk;

    logic                                             sysco_req_chk;
    logic                                             sysco_ack_chk;

    //===================================
    //TxLink specific signals
    //===================================
    logic                                             tx_link_active_req_chk;
    logic                                             tx_link_active_ack_chk;

    //===================================
    //RxLink specific signals
    //===================================
    logic                                             rx_link_active_req_chk;
    logic                                             rx_link_active_ack_chk;

    //===================================
    //TxREQ channel interface signals
    //===================================
    logic                                             tx_req_flit_pend_chk;
    logic                                             tx_req_flitv_chk;
    logic [((WREQFLIT/8)+(WREQFLIT%8 != 0))-1 : 0]    tx_req_flit_chk;
    logic                                             tx_req_lcrdv_chk;

    //===================================
    //TxRSP channel interface signals
    //===================================
    logic                                             tx_rsp_flit_pend_chk;
    logic                                             tx_rsp_flitv_chk;
    logic [((WRSPFLIT/8)+(WRSPFLIT%8 != 0))-1 : 0]    tx_rsp_flit_chk;
    logic                                             tx_rsp_lcrdv_chk;

    //===================================
    //TxDAT channel interface signals
    //===================================
    logic                                             tx_dat_flit_pend_chk;
    logic                                             tx_dat_flitv_chk;
    logic [((WDATFLIT/8)+(WDATFLIT%8 != 0))-1 : 0]    tx_dat_flit_chk;
    logic                                             tx_dat_lcrdv_chk;

    //===================================
    //RxRSP channel interface signals
    //===================================
    logic                                             rx_rsp_flit_pend_chk;
    logic                                             rx_rsp_flitv_chk;
    logic [((WRSPFLIT/8)+(WRSPFLIT%8 != 0))-1 : 0]    rx_rsp_flit_chk;
    logic                                             rx_rsp_lcrdv_chk;

    //===================================
    //RxDAT channel interface signals
    //===================================
    logic                                             rx_dat_flit_pend_chk;
    logic                                             rx_dat_flitv_chk;
    logic [((WDATFLIT/8)+(WDATFLIT%8 != 0))-1 : 0]    rx_dat_flit_chk;
    logic                                             rx_dat_lcrdv_chk;

    //===================================
    //RxSNP channel interface signals
    //===================================
    logic                                             rx_snp_flit_pend_chk;
    logic                                             rx_snp_flitv_chk;
    logic [((WSNPFLIT/8)+(WSNPFLIT%8 != 0))-1 : 0]    rx_snp_flit_chk;
    logic                                             rx_snp_lcrdv_chk;

    //===================================
    //RxREQ channel interface signals
    //===================================
    logic                                             rx_req_flit_pend_chk;
    logic                                             rx_req_flitv_chk;
    logic [((WREQFLIT/8)+(WREQFLIT%8 != 0))-1 : 0]    rx_req_flit_chk;
    logic                                             rx_req_lcrdv_chk;

    always_comb begin
        tx_sactive_chk = !tx_sactive;
        sysco_req_chk = !sysco_req;
        rx_link_active_ack_chk = !rx_link_active_ack;
        tx_link_active_req_chk = !tx_link_active_req;

        tx_req_flit_pend_chk = !tx_req_flit_pend;
        tx_req_flitv_chk = !tx_req_flitv;
        
        tx_rsp_flit_pend_chk = !tx_rsp_flit_pend;
        tx_rsp_flitv_chk = !tx_rsp_flitv;

        tx_dat_flit_pend_chk = !tx_dat_flit_pend;
        tx_dat_flitv_chk = !tx_dat_flitv;

        rx_rsp_lcrdv_chk = !rx_rsp_lcrdv;
        rx_dat_lcrdv_chk = !rx_dat_lcrdv;
        rx_snp_lcrdv_chk = !rx_snp_lcrdv;
        rx_req_lcrdv_chk = !rx_req_lcrdv;

        foreach(tx_req_flit_chk[i]) begin
            tx_req_flit_chk[i] = (($countones(tx_req_flit[(i*8) +: 8])) % 2 == 0);
        end

        foreach(tx_rsp_flit_chk[i]) begin
            tx_rsp_flit_chk[i] = (($countones(tx_rsp_flit[(i*8) +: 8])) % 2 == 0);
        end

        foreach(tx_dat_flit_chk[i]) begin
            tx_dat_flit_chk[i] = (($countones(tx_dat_flit[(i*8) +: 8])) % 2 == 0);
        end
    end
endinterface: chi_if

