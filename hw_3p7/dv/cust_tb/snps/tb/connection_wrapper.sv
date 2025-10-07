import ncore_param_info::flit_info_t;
parameter PAD_ZEROS=1000;

module connection_wrapper#(parameter flit_info_t CHI_INFO, parameter string INTF_TYPE, parameter bit IS_MIXED) (chi_if inhouse_chi_if, svt_chi_rn_if svt_chi_if);

    // Sysco connections
    assign inhouse_chi_if.sysco_req = svt_chi_if.SYSCOREQ ;
    assign svt_chi_if.SYSCOACK = inhouse_chi_if.sysco_ack;

    // Link Channel connections
    assign inhouse_chi_if.tx_sactive = svt_chi_if.TXSACTIVE ; 
    assign svt_chi_if.RXSACTIVE = inhouse_chi_if.rx_sactive; 
    assign inhouse_chi_if.tx_link_active_req = svt_chi_if.TXLINKACTIVEREQ  ;
    assign svt_chi_if.TXLINKACTIVEACK  = inhouse_chi_if.tx_link_active_ack ; 
    assign svt_chi_if.RXLINKACTIVEREQ  = inhouse_chi_if.rx_link_active_req ; 
    assign inhouse_chi_if.rx_link_active_ack = svt_chi_if.RXLINKACTIVEACK  ;

    //-----------------------------------------------------------------------
    // TX Request Virtual Channel
    //-----------------------------------------------------------------------
    assign inhouse_chi_if.tx_req_flit_pend = svt_chi_if.TXREQFLITPEND ; 
    assign inhouse_chi_if.tx_req_flitv = svt_chi_if.TXREQFLITV        ;
    assign svt_chi_if.TXREQLCRDV = inhouse_chi_if.tx_req_lcrdv        ;

    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_QOS_MSB : CHI_INFO.REQ_QOS_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_QOS_MSB:`MAX_REQ_QOS_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_TGTID_MSB : CHI_INFO.REQ_TGTID_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_TGTID_MSB:`MAX_REQ_TGTID_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_SRCID_MSB : CHI_INFO.REQ_SRCID_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_SRCID_MSB:`MAX_REQ_SRCID_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_TXNID_MSB : CHI_INFO.REQ_TXNID_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_TXNID_MSB:`MAX_REQ_TXNID_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_RETNID_MSB : CHI_INFO.REQ_RETNID_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_RETNID_MSB:`MAX_REQ_RETNID_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_ENDIAN_MSB : CHI_INFO.REQ_ENDIAN_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_ENDIAN_MSB:`MAX_REQ_ENDIAN_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_RETTXNID_MSB : CHI_INFO.REQ_RETTXNID_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_RETTXNID_MSB:`MAX_REQ_RETTXNID_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_OPCODE_MSB : CHI_INFO.REQ_OPCODE_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_OPCODE_MSB:`MAX_REQ_OPCODE_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_SIZE_MSB : CHI_INFO.REQ_SIZE_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_SIZE_MSB:`MAX_REQ_SIZE_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_ADDR_MSB : CHI_INFO.REQ_ADDR_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_ADDR_MSB:`MAX_REQ_ADDR_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_NS_MSB : CHI_INFO.REQ_NS_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_NS_MSB:`MAX_REQ_NS_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_LIKELYSHRD_MSB : CHI_INFO.REQ_LIKELYSHRD_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_LIKELYSHRD_MSB:`MAX_REQ_LIKELYSHRD_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_ALLOWRETRY_MSB : CHI_INFO.REQ_ALLOWRETRY_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_ALLOWRETRY_MSB:`MAX_REQ_ALLOWRETRY_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_ORDER_MSB : CHI_INFO.REQ_ORDER_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_ORDER_MSB:`MAX_REQ_ORDER_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_PCRDTYPE_MSB : CHI_INFO.REQ_PCRDTYPE_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_PCRDTYPE_MSB:`MAX_REQ_PCRDTYPE_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_MEMATTR_MSB : CHI_INFO.REQ_MEMATTR_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_MEMATTR_MSB:`MAX_REQ_MEMATTR_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_SNPATTR_MSB : CHI_INFO.REQ_SNPATTR_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_SNPATTR_MSB:`MAX_REQ_SNPATTR_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_LPID_MSB : CHI_INFO.REQ_LPID_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_LPID_MSB:`MAX_REQ_LPID_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_EXCL_MSB : CHI_INFO.REQ_EXCL_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_EXCL_MSB:`MAX_REQ_EXCL_LSB];
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_EXPCOMPACK_MSB : CHI_INFO.REQ_EXPCOMPACK_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_EXPCOMPACK_MSB:`MAX_REQ_EXPCOMPACK_LSB];
    `ifdef MAX_REQ_TAGOP_MSB
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_TAGOP_MSB : CHI_INFO.REQ_TAGOP_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_TAGOP_MSB:`MAX_REQ_TAGOP_LSB];
    `endif
    assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_TRACETAG_MSB : CHI_INFO.REQ_TRACETAG_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_TRACETAG_MSB:`MAX_REQ_TRACETAG_LSB];
    `ifdef MAX_REQ_RSVDC_MSB
        generate
            if (CHI_INFO.REQ_RSVDC_MSB >= 0) begin
                assign inhouse_chi_if.tx_req_flit[CHI_INFO.REQ_RSVDC_MSB : CHI_INFO.REQ_RSVDC_LSB] = svt_chi_if.TXREQFLIT[`MAX_REQ_RSVDC_MSB:`MAX_REQ_RSVDC_LSB];
            end
        endgenerate
    `endif

    //-----------------------------------------------------------------------
    // RX Response Virtual Channel
    //-----------------------------------------------------------------------
    assign svt_chi_if.RXRSPFLITPEND = inhouse_chi_if.rx_rsp_flit_pend  ;
    assign svt_chi_if.RXRSPFLITV    = inhouse_chi_if.rx_rsp_flitv      ;
    assign inhouse_chi_if.rx_rsp_lcrdv = svt_chi_if.RXRSPLCRDV         ;

    assign svt_chi_if.RXRSPFLIT[`MAX_RSP_QOS_MSB:`MAX_RSP_QOS_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_QOS_MSB: CHI_INFO.RSP_QOS_LSB]};
    assign svt_chi_if.RXRSPFLIT[`MAX_RSP_TGTID_MSB:`MAX_RSP_TGTID_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_TGTID_MSB: CHI_INFO.RSP_TGTID_LSB]};
    assign svt_chi_if.RXRSPFLIT[`MAX_RSP_SRCID_MSB:`MAX_RSP_SRCID_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_SRCID_MSB: CHI_INFO.RSP_SRCID_LSB]};
    assign svt_chi_if.RXRSPFLIT[`MAX_RSP_TXNID_MSB:`MAX_RSP_TXNID_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_TXNID_MSB: CHI_INFO.RSP_TXNID_LSB]};
    assign svt_chi_if.RXRSPFLIT[`MAX_RSP_OPCODE_MSB:`MAX_RSP_OPCODE_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_OPCODE_MSB: CHI_INFO.RSP_OPCODE_LSB]};
    assign svt_chi_if.RXRSPFLIT[`MAX_RSP_RESPERR_MSB:`MAX_RSP_RESPERR_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_RESPERR_MSB: CHI_INFO.RSP_RESPERR_LSB]};
    assign svt_chi_if.RXRSPFLIT[`MAX_RSP_RESP_MSB:`MAX_RSP_RESP_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_RESP_MSB: CHI_INFO.RSP_RESP_LSB]};
    assign svt_chi_if.RXRSPFLIT[`MAX_RSP_FWDSTATE_MSB:`MAX_RSP_FWDSTATE_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_FWDSTATE_MSB: CHI_INFO.RSP_FWDSTATE_LSB]};
    `ifdef MAX_RSP_CBUSY_MSB
    generate
        if (INTF_TYPE == "CHI-E") begin
            assign svt_chi_if.RXRSPFLIT[`MAX_RSP_CBUSY_MSB:`MAX_RSP_CBUSY_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_CBUSY_MSB: CHI_INFO.RSP_CBUSY_LSB]};
        end else if (IS_MIXED) begin
            assign svt_chi_if.RXRSPFLIT[`MAX_RSP_CBUSY_MSB:`MAX_RSP_CBUSY_LSB] = 'd0;
        end
    endgenerate
    `endif
    assign svt_chi_if.RXRSPFLIT[`MAX_RSP_DBID_MSB:`MAX_RSP_DBID_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_DBID_MSB: CHI_INFO.RSP_DBID_LSB]};
    assign svt_chi_if.RXRSPFLIT[`MAX_RSP_PCRDTYPE_MSB:`MAX_RSP_PCRDTYPE_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_PCRDTYPE_MSB: CHI_INFO.RSP_PCRDTYPE_LSB]};
    `ifdef MAX_RSP_TAGOP_MSB
    generate
        if (INTF_TYPE == "CHI-E") begin
            assign svt_chi_if.RXRSPFLIT[`MAX_RSP_TAGOP_MSB:`MAX_RSP_TAGOP_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_TAGOP_MSB: CHI_INFO.RSP_TAGOP_LSB]};
        end else if (IS_MIXED) begin
            assign svt_chi_if.RXRSPFLIT[`MAX_RSP_TAGOP_MSB:`MAX_RSP_TAGOP_LSB] = 'd0;
        end
    endgenerate
    `endif
    assign svt_chi_if.RXRSPFLIT[`MAX_RSP_TRACETAG_MSB:`MAX_RSP_TRACETAG_LSB] = {{(PAD_ZEROS){1'b0}}, inhouse_chi_if.rx_rsp_flit[CHI_INFO.RSP_TRACETAG_MSB: CHI_INFO.RSP_TRACETAG_LSB]};

    //-----------------------------------------------------------------------
    // RX Dat Virtual Channel
    //-----------------------------------------------------------------------
    assign svt_chi_if.RXDATFLITPEND = inhouse_chi_if.rx_dat_flit_pend  ;
    assign svt_chi_if.RXDATFLITV    = inhouse_chi_if.rx_dat_flitv      ; 
    assign inhouse_chi_if.rx_dat_lcrdv = svt_chi_if.RXDATLCRDV         ;

    assign svt_chi_if.RXDATFLIT[`MAX_DAT_QOS_MSB:`MAX_DAT_QOS_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_QOS_MSB: CHI_INFO.DAT_QOS_LSB]};
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_TGTID_MSB:`MAX_DAT_TGTID_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_TGTID_MSB: CHI_INFO.DAT_TGTID_LSB]};
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_SRCID_MSB:`MAX_DAT_SRCID_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_SRCID_MSB: CHI_INFO.DAT_SRCID_LSB]};
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_TXNID_MSB:`MAX_DAT_TXNID_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_TXNID_MSB: CHI_INFO.DAT_TXNID_LSB]};
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_HOMENID_MSB:`MAX_DAT_HOMENID_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_HOMENID_MSB: CHI_INFO.DAT_HOMENID_LSB]};
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_OPCODE_MSB:`MAX_DAT_OPCODE_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_OPCODE_MSB: CHI_INFO.DAT_OPCODE_LSB]};
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_RESPERR_MSB:`MAX_DAT_RESPERR_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_RESPERR_MSB: CHI_INFO.DAT_RESPERR_LSB]};
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_RESP_MSB:`MAX_DAT_RESP_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_RESP_MSB: CHI_INFO.DAT_RESP_LSB]};
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_FWDSTATE_MSB:`MAX_DAT_FWDSTATE_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_FWDSTATE_MSB: CHI_INFO.DAT_FWDSTATE_LSB]};
    `ifdef MAX_DAT_CBUSY_MSB
    generate
        if (INTF_TYPE == "CHI-E") begin
            assign svt_chi_if.RXDATFLIT[`MAX_DAT_CBUSY_MSB:`MAX_DAT_CBUSY_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_CBUSY_MSB: CHI_INFO.DAT_CBUSY_LSB]};
        end else if (IS_MIXED) begin
            assign svt_chi_if.RXDATFLIT[`MAX_DAT_CBUSY_MSB:`MAX_DAT_CBUSY_LSB] = 'd0;
        end
    endgenerate
    `endif
    
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_DBID_MSB:`MAX_DAT_DBID_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_DBID_MSB: CHI_INFO.DAT_DBID_LSB]};

    assign svt_chi_if.RXDATFLIT[`MAX_DAT_CCID_MSB:`MAX_DAT_CCID_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_CCID_MSB: CHI_INFO.DAT_CCID_LSB]};
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_DATAID_MSB:`MAX_DAT_DATAID_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_DATAID_MSB: CHI_INFO.DAT_DATAID_LSB]};
    generate
        if (INTF_TYPE == "CHI-E") begin
            `ifdef MAX_DAT_TAGOP_MSB
            assign svt_chi_if.RXDATFLIT[`MAX_DAT_TAGOP_MSB:`MAX_DAT_TAGOP_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_TAGOP_MSB: CHI_INFO.DAT_TAGOP_LSB]};
            `endif
            `ifdef MAX_DAT_TAG_MSB
            assign svt_chi_if.RXDATFLIT[`MAX_DAT_TAG_MSB:`MAX_DAT_TAG_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_TAG_MSB: CHI_INFO.DAT_TAG_LSB]};
            `endif
            `ifdef MAX_DAT_TU_MSB
            assign svt_chi_if.RXDATFLIT[`MAX_DAT_TU_MSB:`MAX_DAT_TU_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_TU_MSB: CHI_INFO.DAT_TU_LSB]};
            `endif
        end else if (IS_MIXED) begin
            `ifdef MAX_DAT_TAGOP_MSB
            assign svt_chi_if.RXDATFLIT[`MAX_DAT_TAGOP_MSB:`MAX_DAT_TAGOP_LSB] = 'd0;
            `endif
            `ifdef MAX_DAT_TAG_MSB
            assign svt_chi_if.RXDATFLIT[`MAX_DAT_TAG_MSB:`MAX_DAT_TAG_LSB] = 'd0;
            `endif
            `ifdef MAX_DAT_TU_MSB
            assign svt_chi_if.RXDATFLIT[`MAX_DAT_TU_MSB:`MAX_DAT_TU_LSB] = 'd0;
            `endif
        end
    endgenerate
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_TRACETAG_MSB:`MAX_DAT_TRACETAG_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_TRACETAG_MSB: CHI_INFO.DAT_TRACETAG_LSB]};
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_BE_MSB:`MAX_DAT_BE_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_BE_MSB: CHI_INFO.DAT_BE_LSB]};
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_DATA_MSB:`MAX_DAT_DATA_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_DATA_MSB: CHI_INFO.DAT_DATA_LSB]};
    `ifdef MAX_DAT_DATACHECK_MSB
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_DATACHECK_MSB:`MAX_DAT_DATACHECK_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_DATACHECK_MSB: CHI_INFO.DAT_DATACHECK_LSB]};
    `endif
    `ifdef MAX_DAT_POISON_MSB
    assign svt_chi_if.RXDATFLIT[`MAX_DAT_POISON_MSB:`MAX_DAT_POISON_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_dat_flit[CHI_INFO.DAT_POISON_MSB: CHI_INFO.DAT_POISON_LSB]};
    `endif

    //-----------------------------------------------------------------------
    // RX Snoop Virtual Channel
    //-----------------------------------------------------------------------
    assign svt_chi_if.RXSNPFLITPEND = inhouse_chi_if.rx_snp_flit_pend  ;
    assign svt_chi_if.RXSNPFLITV    = inhouse_chi_if.rx_snp_flitv      ;     
    assign inhouse_chi_if.rx_snp_lcrdv = svt_chi_if.RXSNPLCRDV    ;    

    assign svt_chi_if.RXSNPFLIT[`MAX_SNP_QOS_MSB:`MAX_SNP_QOS_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_snp_flit[CHI_INFO.SNP_QOS_MSB:CHI_INFO.SNP_QOS_LSB]};
    assign svt_chi_if.RXSNPFLIT[`MAX_SNP_SRCID_MSB:`MAX_SNP_SRCID_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_snp_flit[CHI_INFO.SNP_SRCID_MSB:CHI_INFO.SNP_SRCID_LSB]};
    assign svt_chi_if.RXSNPFLIT[`MAX_SNP_TXNID_MSB:`MAX_SNP_TXNID_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_snp_flit[CHI_INFO.SNP_TXNID_MSB:CHI_INFO.SNP_TXNID_LSB]};
    assign svt_chi_if.RXSNPFLIT[`MAX_SNP_FWDNID_MSB:`MAX_SNP_FWDNID_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_snp_flit[CHI_INFO.SNP_FWDNID_MSB:CHI_INFO.SNP_FWDNID_LSB]};
    assign svt_chi_if.RXSNPFLIT[`MAX_SNP_FWDTXNID_MSB:`MAX_SNP_FWDTXNID_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_snp_flit[CHI_INFO.SNP_FWDTXNID_MSB:CHI_INFO.SNP_FWDTXNID_LSB]};
    assign svt_chi_if.RXSNPFLIT[`MAX_SNP_OPCODE_MSB:`MAX_SNP_OPCODE_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_snp_flit[CHI_INFO.SNP_OPCODE_MSB:CHI_INFO.SNP_OPCODE_LSB]};
    assign svt_chi_if.RXSNPFLIT[`MAX_SNP_ADDR_MSB:`MAX_SNP_ADDR_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_snp_flit[CHI_INFO.SNP_ADDR_MSB:CHI_INFO.SNP_ADDR_LSB]};
    assign svt_chi_if.RXSNPFLIT[`MAX_SNP_NS_MSB:`MAX_SNP_NS_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_snp_flit[CHI_INFO.SNP_NS_MSB:CHI_INFO.SNP_NS_LSB]};
    assign svt_chi_if.RXSNPFLIT[`MAX_SNP_DONTGOTOSD_MSB:`MAX_SNP_DONTGOTOSD_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_snp_flit[CHI_INFO.SNP_DONTGOTOSD_MSB:CHI_INFO.SNP_DONTGOTOSD_LSB]};
    assign svt_chi_if.RXSNPFLIT[`MAX_SNP_RETTOSRC_MSB:`MAX_SNP_RETTOSRC_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_snp_flit[CHI_INFO.SNP_RETTOSRC_MSB:CHI_INFO.SNP_RETTOSRC_LSB]};
    assign svt_chi_if.RXSNPFLIT[`MAX_SNP_TRACETAG_MSB:`MAX_SNP_TRACETAG_LSB] = {{(PAD_ZEROS){1'b0}},inhouse_chi_if.rx_snp_flit[CHI_INFO.SNP_TRACETAG_MSB:CHI_INFO.SNP_TRACETAG_LSB]};

    //-----------------------------------------------------------------------
    // TX Response Virtual Channel
    //-----------------------------------------------------------------------
    assign inhouse_chi_if.tx_rsp_flit_pend = svt_chi_if.TXRSPFLITPEND  ; 
    assign inhouse_chi_if.tx_rsp_flitv = svt_chi_if.TXRSPFLITV     ;
    assign svt_chi_if.TXRSPLCRDV  = inhouse_chi_if.tx_rsp_lcrdv   ;

    assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_QOS_MSB : CHI_INFO.RSP_QOS_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_QOS_MSB:`MAX_RSP_QOS_LSB];
    assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_TGTID_MSB : CHI_INFO.RSP_TGTID_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_TGTID_MSB:`MAX_RSP_TGTID_LSB];
    assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_SRCID_MSB : CHI_INFO.RSP_SRCID_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_SRCID_MSB:`MAX_RSP_SRCID_LSB];
    assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_TXNID_MSB : CHI_INFO.RSP_TXNID_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_TXNID_MSB:`MAX_RSP_TXNID_LSB];
    assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_OPCODE_MSB : CHI_INFO.RSP_OPCODE_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_OPCODE_MSB:`MAX_RSP_OPCODE_LSB];
    assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_RESPERR_MSB : CHI_INFO.RSP_RESPERR_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_RESPERR_MSB:`MAX_RSP_RESPERR_LSB];
    assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_RESP_MSB : CHI_INFO.RSP_RESP_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_RESP_MSB:`MAX_RSP_RESP_LSB];
    assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_FWDSTATE_MSB : CHI_INFO.RSP_FWDSTATE_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_FWDSTATE_MSB:`MAX_RSP_FWDSTATE_LSB];
    `ifdef MAX_RSP_CBUSY_MSB
    generate
        if (INTF_TYPE == "CHI-E") begin
            assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_CBUSY_MSB : CHI_INFO.RSP_CBUSY_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_CBUSY_MSB:`MAX_RSP_CBUSY_LSB];
        end
    endgenerate
    `endif
    
    assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_DBID_MSB : CHI_INFO.RSP_DBID_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_DBID_MSB:`MAX_RSP_DBID_LSB];
    assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_PCRDTYPE_MSB : CHI_INFO.RSP_PCRDTYPE_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_PCRDTYPE_MSB:`MAX_RSP_PCRDTYPE_LSB];
    `ifdef MAX_RSP_TAGOP_MSB
    generate
        if (INTF_TYPE == "CHI-E") begin
            assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_TAGOP_MSB : CHI_INFO.RSP_TAGOP_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_TAGOP_MSB:`MAX_RSP_TAGOP_LSB];
        end
    endgenerate
    `endif
    assign inhouse_chi_if.tx_rsp_flit[CHI_INFO.RSP_TRACETAG_MSB : CHI_INFO.RSP_TRACETAG_LSB] = svt_chi_if.TXRSPFLIT[`MAX_RSP_TRACETAG_MSB:`MAX_RSP_TRACETAG_LSB];

    //-----------------------------------------------------------------------
    // TX Dat Virtual Channel
    //-----------------------------------------------------------------------
    assign inhouse_chi_if.tx_dat_flit_pend = svt_chi_if.TXDATFLITPEND ;  
    assign inhouse_chi_if.tx_dat_flitv = svt_chi_if.TXDATFLITV    ;
    assign svt_chi_if.TXDATLCRDV  = inhouse_chi_if.tx_dat_lcrdv  ;

    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_QOS_MSB : CHI_INFO.DAT_QOS_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_QOS_MSB:`MAX_DAT_QOS_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_TGTID_MSB : CHI_INFO.DAT_TGTID_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_TGTID_MSB:`MAX_DAT_TGTID_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_SRCID_MSB : CHI_INFO.DAT_SRCID_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_SRCID_MSB:`MAX_DAT_SRCID_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_TXNID_MSB : CHI_INFO.DAT_TXNID_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_TXNID_MSB:`MAX_DAT_TXNID_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_HOMENID_MSB : CHI_INFO.DAT_HOMENID_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_HOMENID_MSB:`MAX_DAT_HOMENID_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_OPCODE_MSB : CHI_INFO.DAT_OPCODE_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_OPCODE_MSB:`MAX_DAT_OPCODE_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_RESPERR_MSB : CHI_INFO.DAT_RESPERR_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_RESPERR_MSB:`MAX_DAT_RESPERR_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_RESP_MSB : CHI_INFO.DAT_RESP_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_RESP_MSB:`MAX_DAT_RESP_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_FWDSTATE_MSB : CHI_INFO.DAT_FWDSTATE_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_FWDSTATE_MSB:`MAX_DAT_FWDSTATE_LSB];
    
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_DBID_MSB : CHI_INFO.DAT_DBID_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_DBID_MSB:`MAX_DAT_DBID_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_CCID_MSB : CHI_INFO.DAT_CCID_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_CCID_MSB:`MAX_DAT_CCID_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_DATAID_MSB : CHI_INFO.DAT_DATAID_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_DATAID_MSB:`MAX_DAT_DATAID_LSB];
    generate
        if (INTF_TYPE == "CHI-E") begin
            `ifdef MAX_DAT_CBUSY_MSB
            assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_CBUSY_MSB : CHI_INFO.DAT_CBUSY_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_CBUSY_MSB:`MAX_DAT_CBUSY_LSB];
            `endif
            `ifdef MAX_DAT_TAGOP_MSB
            assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_TAGOP_MSB : CHI_INFO.DAT_TAGOP_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_TAGOP_MSB:`MAX_DAT_TAGOP_LSB];
            `endif
            `ifdef MAX_DAT_TAG_MSB
            assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_TAG_MSB : CHI_INFO.DAT_TAG_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_TAG_MSB:`MAX_DAT_TAG_LSB];
            `endif
            `ifdef MAX_DAT_TU_MSB
            assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_TU_MSB : CHI_INFO.DAT_TU_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_TU_MSB:`MAX_DAT_TU_LSB];
            `endif
        end
    endgenerate
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_TRACETAG_MSB : CHI_INFO.DAT_TRACETAG_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_TRACETAG_MSB:`MAX_DAT_TRACETAG_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_BE_MSB : CHI_INFO.DAT_BE_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_BE_MSB:`MAX_DAT_BE_LSB];
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_DATA_MSB : CHI_INFO.DAT_DATA_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_DATA_MSB:`MAX_DAT_DATA_LSB];
    `ifdef MAX_DAT_DATACHECK_MSB
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_DATACHECK_MSB : CHI_INFO.DAT_DATACHECK_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_DATACHECK_MSB:`MAX_DAT_DATACHECK_LSB];
    `endif
    `ifdef MAX_DAT_POISON_MSB
    assign inhouse_chi_if.tx_dat_flit[CHI_INFO.DAT_POISON_MSB : CHI_INFO.DAT_POISON_LSB] = svt_chi_if.TXDATFLIT[`MAX_DAT_POISON_MSB:`MAX_DAT_POISON_LSB];
    `endif

endmodule
