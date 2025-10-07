<%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
interface <%=obj.BlockId%>_rx_req_chan;
    import <%=obj.BlockId%>_chi_agent_pkg::*;

    logic                   rx_req_flit_pend;
    logic                   rx_req_flitv;
    logic [WREQFLIT-1: 0]   rx_req_flit;
    logic                   rx_req_lcrdv;

    chi_qos_t               qos             ;
    chi_tgtid_t             tgtid           ;
    chi_srcid_t             srcid           ;
    chi_txnid_t             txnid           ;
    chi_req_returnnid_t     returnnid       ;
    chi_req_stashnid_t      stashnid        ;
    chi_req_stashnidvalid_t stashnidvalid   ;
    chi_req_endian_t        endian          ;
    chi_req_returntxnid_t   returntxnid     ;
    chi_req_opcode_enum_t   opcode          ;
    chi_req_size_t          size            ;
    chi_addr_t              addr            ;
    chi_ns_t                ns              ;
    chi_req_likelyshared_t  likelyshared    ;
    chi_req_allowretry_t    allowretry      ;
    chi_req_order_t         order           ;
    chi_req_pcrdtype_t      pcrdtype        ;
    chi_req_memattr_t       memattr         ;
    chi_req_snpattr_t       snpattr         ;
    chi_lpid_t              lpid            ;
    chi_req_excl_t          excl            ;
    chi_req_expcompack_t    expcompack      ;
    chi_req_tagop_t         tagop           ;
    chi_tracetag_t          tracetag        ;

    assign qos              = rx_req_flit[`CHI_REQ_QOS_MSB:`CHI_REQ_QOS_LSB];
    assign tgtid            = rx_req_flit[`CHI_REQ_TGTID_MSB:`CHI_REQ_TGTID_LSB];
    assign srcid            = rx_req_flit[`CHI_REQ_SRCID_MSB:`CHI_REQ_SRCID_LSB];
    assign txnid            = rx_req_flit[`CHI_REQ_TXNID_MSB:`CHI_REQ_TXNID_LSB];
    assign returnnid        = rx_req_flit[`CHI_REQ_RTRN_NID_MSB:`CHI_REQ_RTRN_NID_LSB];
    assign stashnid         = rx_req_flit[`CHI_REQ_RTRN_NID_MSB:`CHI_REQ_RTRN_NID_LSB];
    assign stashnidvalid    = rx_req_flit[`CHI_REQ_ENDIAN_MSB:`CHI_REQ_ENDIAN_LSB];
    assign endian           = rx_req_flit[`CHI_REQ_ENDIAN_MSB:`CHI_REQ_ENDIAN_LSB];
    assign returntxnid      = rx_req_flit[`CHI_REQ_RTRN_TXNID_MSB:`CHI_REQ_RTRN_TXNID_LSB];
    assign opcode           = chi_req_opcode_enum_t'(rx_req_flit[`CHI_REQ_OPCODE_MSB:`CHI_REQ_OPCODE_LSB]);
    assign size             = rx_req_flit[`CHI_REQ_SIZE_MSB:`CHI_REQ_SIZE_LSB];
    assign addr             = rx_req_flit[`CHI_REQ_ADDR_MSB:`CHI_REQ_ADDR_LSB];
    assign ns               = rx_req_flit[`CHI_REQ_NS_MSB:`CHI_REQ_NS_LSB];
    assign likelyshared     = rx_req_flit[`CHI_REQ_LIKELYSHARED_MSB:`CHI_REQ_LIKELYSHARED_LSB];
    assign allowretry       = rx_req_flit[`CHI_REQ_ALLOWRETRY_MSB:`CHI_REQ_ALLOWRETRY_LSB];
    assign order            = rx_req_flit[`CHI_REQ_ORDER_MSB:`CHI_REQ_ORDER_LSB];
    assign pcrdtype         = rx_req_flit[`CHI_REQ_PCRDTYPE_MSB:`CHI_REQ_PCRDTYPE_LSB];
    assign memattr          = rx_req_flit[`CHI_REQ_MEMATTR_MSB:`CHI_REQ_MEMATTR_LSB];
    assign snpattr          = rx_req_flit[`CHI_REQ_SNPATTR_MSB:`CHI_REQ_SNPATTR_LSB];
    assign lpid             = rx_req_flit[`CHI_REQ_LPID_MSB:`CHI_REQ_LPID_LSB];
    assign excl             = rx_req_flit[`CHI_REQ_EXCL_MSB:`CHI_REQ_EXCL_LSB];
    assign expcompack       = rx_req_flit[`CHI_REQ_EXPCOMPACK_MSB:`CHI_REQ_EXPCOMPACK_LSB];
    assign tagop            = rx_req_flit[`CHI_REQ_TAGOP_MSB:`CHI_REQ_TAGOP_LSB];
    assign tracetag         = rx_req_flit[`CHI_REQ_TRACETAG_MSB:`CHI_REQ_TRACETAG_LSB];
endinterface: <%=obj.BlockId%>_rx_req_chan

interface <%=obj.BlockId%>_rx_data_chan;
    import <%=obj.BlockId%>_chi_agent_pkg::*;
    logic                   rx_dat_flit_pend;
    logic                   rx_dat_flitv;
    logic [WDATFLIT-1: 0]   rx_dat_flit;
    logic                   rx_dat_lcrdv;

    chi_qos_t               qos             ;
    chi_tgtid_t             tgtid           ;
    chi_srcid_t             srcid           ;
    chi_txnid_t             txnid           ;
    chi_dat_homenid_t       homenid         ;
    chi_dat_opcode_enum_t   opcode          ;
    chi_dat_resperr_t       resperr         ;
    chi_dat_resp_t          resp            ;
    chi_dat_fwdstate_t      fwdstate        ;
    chi_dat_datapull_t      datapull        ;
    chi_dat_datasource_t    datasource      ;
    chi_dat_cbusy_t         cbusy           ;
    chi_dat_dbid_t          dbid            ;
    chi_dat_ccid_t          ccid            ;
    chi_dat_dataid_t        dataid          ;
    chi_dat_tagop_t         tagop           ;
    chi_dat_tag_t           tag             ;
    chi_dat_tu_t            tu              ;
    chi_tracetag_t          tracetag        ;
    chi_dat_be_t            be              ;
    chi_dat_data_t          data            ;
    chi_dat_datacheck_t     datacheck       ;
    chi_dat_poison_t        poison          ;

    assign qos              = rx_dat_flit[`CHI_REQ_QOS_MSB:`CHI_REQ_QOS_LSB];
    assign tgtid            = rx_dat_flit[`CHI_REQ_TGTID_MSB:`CHI_REQ_TGTID_LSB];
    assign srcid            = rx_dat_flit[`CHI_REQ_SRCID_MSB:`CHI_REQ_SRCID_LSB];
    assign txnid            = rx_dat_flit[`CHI_REQ_TXNID_MSB:`CHI_REQ_TXNID_LSB];
    assign homenid          = rx_dat_flit[`CHI_DAT_HOMENID_MSB:`CHI_DAT_HOMENID_LSB];
    assign opcode           = chi_dat_opcode_enum_t'(rx_dat_flit[`CHI_DAT_OPCODE_MSB:`CHI_DAT_OPCODE_LSB]);
    assign resperr          = rx_dat_flit[`CHI_DAT_RESPERR_MSB:`CHI_DAT_RESPERR_LSB];
    assign resp             = rx_dat_flit[`CHI_DAT_RESP_MSB:`CHI_DAT_RESP_LSB];
    assign fwdstate         = rx_dat_flit[`CHI_DAT_DATASOURCE_MSB:`CHI_DAT_DATASOURCE_LSB];
    assign datapull         = rx_dat_flit[`CHI_DAT_DATASOURCE_MSB:`CHI_DAT_DATASOURCE_LSB];
    assign datasource       = rx_dat_flit[`CHI_DAT_DATASOURCE_MSB:`CHI_DAT_DATASOURCE_LSB];
    assign cbusy            = rx_dat_flit[`CHI_DAT_CBUSY_MSB:`CHI_DAT_CBUSY_LSB];
    assign dbid             = rx_dat_flit[`CHI_DAT_DBID_MSB:`CHI_DAT_DBID_LSB];
    assign ccid             = rx_dat_flit[`CHI_DAT_CCID_MSB:`CHI_DAT_CCID_LSB];
    assign dataid           = rx_dat_flit[`CHI_DAT_DATAID_MSB:`CHI_DAT_DATAID_LSB];
    assign tagop            = rx_dat_flit[`CHI_DAT_TAGOP_MSB:`CHI_DAT_TAGOP_LSB];
    assign tag              = rx_dat_flit[`CHI_DAT_TAG_MSB:`CHI_DAT_TAG_LSB];
    assign tu               = rx_dat_flit[`CHI_DAT_TU_MSB:`CHI_DAT_TU_LSB];
    assign tracetag         = rx_dat_flit[`CHI_DAT_TRACETAG_MSB:`CHI_DAT_TRACETAG_LSB];
    assign be               = rx_dat_flit[`CHI_DAT_BE_MSB:`CHI_DAT_BE_LSB];
    assign data             = rx_dat_flit[`CHI_DAT_DATA_MSB:`CHI_DAT_DATA_LSB];
    <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.enPoison) { %>
    assign poison           = rx_dat_flit[`CHI_DAT_POISON_MSB:`CHI_DAT_POISON_LSB];
    <% } %>
endinterface: <%=obj.BlockId%>_rx_data_chan

interface <%=obj.BlockId%>_rx_rsp_chan;
    import <%=obj.BlockId%>_chi_agent_pkg::*;

    logic                   rx_rsp_flit_pend;
    logic                   rx_rsp_flitv;
    logic [WRSPFLIT-1: 0]   rx_rsp_flit;
    logic                   rx_rsp_lcrdv;

    chi_qos_t               qos             ;
    chi_tgtid_t             tgtid           ;
    chi_srcid_t             srcid           ;
    chi_txnid_t             txnid           ;
    chi_rsp_opcode_enum_t   opcode          ;
    chi_rsp_resperr_t       resperr         ;
    chi_rsp_resp_t          resp            ;
    chi_dat_fwdstate_t      fwdstate        ;
    chi_rsp_cbusy_t         cbusy           ;
    chi_rsp_dbid_t          dbid            ;
    chi_rsp_pcrdtype_t      pcrdtype        ;
    chi_req_tagop_t         tagop           ;
    chi_tracetag_t          tracetag        ;

    assign qos             = rx_rsp_flit[`CHI_REQ_QOS_MSB:`CHI_REQ_QOS_LSB];
    assign tgtid           = rx_rsp_flit[`CHI_REQ_TGTID_MSB:`CHI_REQ_TGTID_LSB];
    assign srcid           = rx_rsp_flit[`CHI_REQ_SRCID_MSB:`CHI_REQ_SRCID_LSB];
    assign txnid           = rx_rsp_flit[`CHI_REQ_TXNID_MSB:`CHI_REQ_TXNID_LSB];
    assign opcode          = chi_rsp_opcode_enum_t'(rx_rsp_flit[`CHI_RSP_OPCODE_MSB:`CHI_RSP_OPCODE_LSB]);
    assign resperr         = rx_rsp_flit[`CHI_RSP_RESPERR_MSB:`CHI_RSP_RESPERR_LSB];
    assign resp            = rx_rsp_flit[`CHI_RSP_RESP_MSB:`CHI_RSP_RESP_LSB];
    assign fwdstate        = rx_rsp_flit[`CHI_RSP_FWDSTATE_MSB:`CHI_RSP_FWDSTATE_LSB];
    assign cbusy           = rx_rsp_flit[`CHI_RSP_CBUSY_MSB:`CHI_RSP_CBUSY_LSB];
    assign dbid            = rx_rsp_flit[`CHI_RSP_DBID_MSB:`CHI_RSP_DBID_LSB];
    assign pcrdtype        = rx_rsp_flit[`CHI_RSP_PCRDTYPE_MSB:`CHI_RSP_PCRDTYPE_LSB];
    assign tagop           = rx_rsp_flit[`CHI_RSP_TAGOP_MSB:`CHI_RSP_TAGOP_LSB];
    assign tracetag        = rx_rsp_flit[`CHI_RSP_TRACETAG_MSB:`CHI_RSP_TRACETAG_LSB];
endinterface: <%=obj.BlockId%>_rx_rsp_chan

interface <%=obj.BlockId%>_tx_data_chan;
    import <%=obj.BlockId%>_chi_agent_pkg::*;

    logic                   tx_dat_flit_pend;
    logic                   tx_dat_flitv    ;
    logic [WDATFLIT-1: 0]   tx_dat_flit     ;
    logic                   tx_dat_lcrdv    ;

    chi_qos_t               qos             ;
    chi_tgtid_t             tgtid           ;
    chi_srcid_t             srcid           ;
    chi_txnid_t             txnid           ;
    chi_dat_homenid_t       homenid         ;
    chi_dat_opcode_enum_t   opcode          ;
    chi_dat_resperr_t       resperr         ;
    chi_dat_resp_t          resp            ;
    chi_dat_fwdstate_t      fwdstate        ;
    chi_dat_datapull_t      datapull        ;
    chi_dat_datasource_t    datasource      ;
    chi_dat_cbusy_t         cbusy           ;
    chi_dat_dbid_t          dbid            ;
    chi_dat_ccid_t          ccid            ;
    chi_dat_dataid_t        dataid          ;
    chi_dat_tagop_t         tagop           ;
    chi_dat_tag_t           tag             ;
    chi_dat_tu_t            tu              ;
    chi_tracetag_t          tracetag        ;
    chi_dat_be_t            be              ;
    chi_dat_data_t          data            ;
    chi_dat_datacheck_t     datacheck       ;
    chi_dat_poison_t        poison          ;

    assign qos              = tx_dat_flit[`CHI_REQ_QOS_MSB:`CHI_REQ_QOS_LSB];
    assign tgtid            = tx_dat_flit[`CHI_REQ_TGTID_MSB:`CHI_REQ_TGTID_LSB];
    assign srcid            = tx_dat_flit[`CHI_REQ_SRCID_MSB:`CHI_REQ_SRCID_LSB];
    assign txnid            = tx_dat_flit[`CHI_REQ_TXNID_MSB:`CHI_REQ_TXNID_LSB];
    assign homenid          = tx_dat_flit[`CHI_DAT_HOMENID_MSB:`CHI_DAT_HOMENID_LSB];
    assign opcode           = chi_dat_opcode_enum_t'(tx_dat_flit[`CHI_DAT_OPCODE_MSB:`CHI_DAT_OPCODE_LSB]);
    assign resperr          = tx_dat_flit[`CHI_DAT_RESPERR_MSB:`CHI_DAT_RESPERR_LSB];
    assign resp             = tx_dat_flit[`CHI_DAT_RESP_MSB:`CHI_DAT_RESP_LSB];
    assign fwdstate         = tx_dat_flit[`CHI_DAT_DATASOURCE_MSB:`CHI_DAT_DATASOURCE_LSB];
    assign datapull         = tx_dat_flit[`CHI_DAT_DATASOURCE_MSB:`CHI_DAT_DATASOURCE_LSB];
    assign datasource       = tx_dat_flit[`CHI_DAT_DATASOURCE_MSB:`CHI_DAT_DATASOURCE_LSB];
    assign cbusy            = tx_dat_flit[`CHI_DAT_CBUSY_MSB:`CHI_DAT_CBUSY_LSB];
    assign dbid             = tx_dat_flit[`CHI_DAT_DBID_MSB:`CHI_DAT_DBID_LSB];
    assign ccid             = tx_dat_flit[`CHI_DAT_CCID_MSB:`CHI_DAT_CCID_LSB];
    assign dataid           = tx_dat_flit[`CHI_DAT_DATAID_MSB:`CHI_DAT_DATAID_LSB];
    assign tagop            = tx_dat_flit[`CHI_DAT_TAGOP_MSB:`CHI_DAT_TAGOP_LSB];
    assign tag              = tx_dat_flit[`CHI_DAT_TAG_MSB:`CHI_DAT_TAG_LSB];
    assign tu               = tx_dat_flit[`CHI_DAT_TU_MSB:`CHI_DAT_TU_LSB];
    assign tracetag         = tx_dat_flit[`CHI_DAT_TRACETAG_MSB:`CHI_DAT_TRACETAG_LSB];
    assign be               = tx_dat_flit[`CHI_DAT_BE_MSB:`CHI_DAT_BE_LSB];
    assign data             = tx_dat_flit[`CHI_DAT_DATA_MSB:`CHI_DAT_DATA_LSB];
    <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.enPoison) { %>
    assign poison           = tx_dat_flit[`CHI_DAT_POISON_MSB:`CHI_DAT_POISON_LSB];
    <% } %>

endinterface: <%=obj.BlockId%>_tx_data_chan

interface <%=obj.BlockId%>_tx_rsp_chan;
    import <%=obj.BlockId%>_chi_agent_pkg::*;
    logic                   tx_rsp_flit_pend;
    logic                   tx_rsp_flitv    ;
    logic [WRSPFLIT-1: 0]   tx_rsp_flit     ;
    logic                   tx_rsp_lcrdv    ;
    chi_qos_t               qos             ;
    chi_tgtid_t             tgtid           ;
    chi_srcid_t             srcid           ;
    chi_txnid_t             txnid           ;
    chi_rsp_opcode_enum_t   opcode          ;
    chi_rsp_resperr_t       resperr         ;
    chi_rsp_resp_t          resp            ;
    chi_dat_fwdstate_t      fwdstate        ;
    chi_rsp_cbusy_t         cbusy           ;
    chi_rsp_dbid_t          dbid            ;
    chi_rsp_pcrdtype_t      pcrdtype        ;
    chi_req_tagop_t         tagop           ;
    chi_tracetag_t          tracetag        ;

    assign qos             = tx_rsp_flit[`CHI_REQ_QOS_MSB:`CHI_REQ_QOS_LSB];
    assign tgtid           = tx_rsp_flit[`CHI_REQ_TGTID_MSB:`CHI_REQ_TGTID_LSB];
    assign srcid           = tx_rsp_flit[`CHI_REQ_SRCID_MSB:`CHI_REQ_SRCID_LSB];
    assign txnid           = tx_rsp_flit[`CHI_REQ_TXNID_MSB:`CHI_REQ_TXNID_LSB];
    assign opcode          = chi_rsp_opcode_enum_t'(tx_rsp_flit[`CHI_RSP_OPCODE_MSB:`CHI_RSP_OPCODE_LSB]);
    assign resperr         = tx_rsp_flit[`CHI_RSP_RESPERR_MSB:`CHI_RSP_RESPERR_LSB];
    assign resp            = tx_rsp_flit[`CHI_RSP_RESP_MSB:`CHI_RSP_RESP_LSB];
    assign fwdstate        = tx_rsp_flit[`CHI_RSP_FWDSTATE_MSB:`CHI_RSP_FWDSTATE_LSB];
    assign cbusy           = tx_rsp_flit[`CHI_RSP_CBUSY_MSB:`CHI_RSP_CBUSY_LSB];
    assign dbid            = tx_rsp_flit[`CHI_RSP_DBID_MSB:`CHI_RSP_DBID_LSB];
    assign pcrdtype        = tx_rsp_flit[`CHI_RSP_PCRDTYPE_MSB:`CHI_RSP_PCRDTYPE_LSB];
    assign tagop           = tx_rsp_flit[`CHI_RSP_TAGOP_MSB:`CHI_RSP_TAGOP_LSB];
    assign tracetag        = tx_rsp_flit[`CHI_RSP_TRACETAG_MSB:`CHI_RSP_TRACETAG_LSB];
endinterface: <%=obj.BlockId%>_tx_rsp_chan

interface <%=obj.BlockId%>_tx_snp_chan;
    import <%=obj.BlockId%>_chi_agent_pkg::*;
    logic                                             tx_snp_flit_pend;
    logic                                             tx_snp_flitv;
    logic [WSNPFLIT-1: 0]                             tx_snp_flit;
    logic                                             tx_snp_lcrdv;
endinterface: <%=obj.BlockId%>_tx_snp_chan

interface <%=obj.BlockId%>_chi_debug_if (input logic clk, reset_n);
    import <%=obj.BlockId%>_chi_agent_pkg::*;
    <%=obj.BlockId%>_rx_req_chan     rx_req();
    <%=obj.BlockId%>_rx_data_chan    rx_data();
    <%=obj.BlockId%>_rx_rsp_chan     rx_rsp();
    <%=obj.BlockId%>_tx_data_chan    tx_data();
    <%=obj.BlockId%>_tx_rsp_chan     tx_rsp();
    <%=obj.BlockId%>_tx_snp_chan     tx_snp();

    // Sub Interfaces
    //===================================
    //Interface Specific Signals
    //===================================
    // logic                                             tx_sactive;
    // logic                                             rx_sactive;

    // logic                                             sysco_req;
    // logic                                             sysco_ack;

    //===================================
    //TxLink specific signals
    //===================================
    // logic                                             tx_link_active_req;
    // logic                                             tx_link_active_ack;

    //===================================
    //RxLink specific signals
    //===================================
    // logic                                             rx_link_active_req;
    // logic                                             rx_link_active_ack;

    //===================================
    //RxREQ channel interface signals
    //===================================
    logic                                             rx_req_flit_pend;
    logic                                             rx_req_flitv;
    logic [WREQFLIT-1: 0]                             rx_req_flit;
    logic                                             rx_req_lcrdv;

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
    //TxSNP channel interface signals
    //===================================
    logic                                             tx_snp_flit_pend;
    logic                                             tx_snp_flitv;
    logic [WSNPFLIT-1: 0]                             tx_snp_flit;
    logic                                             tx_snp_lcrdv;


    // Connect RX REQ Channel
    assign rx_req.rx_req_flit_pend  = rx_req_flit_pend;
    assign rx_req.rx_req_flitv      = rx_req_flitv;
    assign rx_req.rx_req_flit       = rx_req_flit;
    assign rx_req.rx_req_lcrdv      = rx_req_lcrdv;

    // Connect RX RSP Channel
    assign rx_rsp.rx_rsp_flit_pend  = rx_rsp_flit_pend;
    assign rx_rsp.rx_rsp_flitv      = rx_rsp_flitv;
    assign rx_rsp.rx_rsp_flit       = rx_rsp_flit;
    assign rx_rsp.rx_rsp_lcrdv      = rx_rsp_lcrdv;

    // Connect RX DATA Channel
    assign rx_data.rx_dat_flit_pend  = rx_dat_flit_pend;
    assign rx_data.rx_dat_flitv      = rx_dat_flitv;
    assign rx_data.rx_dat_flit       = rx_dat_flit;
    assign rx_data.rx_dat_lcrdv      = rx_dat_lcrdv;

    // Connect TX RSP Channel
    assign tx_rsp.tx_rsp_flit_pend  = tx_rsp_flit_pend;
    assign tx_rsp.tx_rsp_flitv      = tx_rsp_flitv;
    assign tx_rsp.tx_rsp_flit       = tx_rsp_flit;
    assign tx_rsp.tx_rsp_lcrdv      = tx_rsp_lcrdv;

    // Connect TX DATA Channel
    assign tx_data.tx_dat_flit_pend = tx_dat_flit_pend;
    assign tx_data.tx_dat_flitv     = tx_dat_flitv;
    assign tx_data.tx_dat_flit      = tx_dat_flit;
    assign tx_data.tx_dat_lcrdv     = tx_dat_lcrdv;

    // Connect TX SNP Channel
    assign tx_snp.tx_snp_flit_pend  = tx_snp_flit_pend;
    assign tx_snp.tx_snp_flitv      = tx_snp_flitv;
    assign tx_snp.tx_snp_flit       = tx_snp_flit;
    assign tx_snp.tx_snp_lcrdv      = tx_snp_lcrdv;
    
endinterface: <%=obj.BlockId%>_chi_debug_if
<%}%>
