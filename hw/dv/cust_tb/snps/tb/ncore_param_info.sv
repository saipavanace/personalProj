package <%=obj.filename?? 'ncore_param_info'%>; //FIXME: Need to open a ticket to fix the filename?

    `define print_macro(A) \
        $write("%s", $sformatf A ); \

    // Enable Resiliency
    bit enResiliency = <%=obj.useResiliency%>;
    int nCHIs   = <%=obj.ChiaiuInfo.length%>;
    int nAIUs   = <%=obj.AiuInfo.length%>;
    int nIOAIUs = <%=obj.IoaiuInfo.length%>;

    class ncore_params;

        function new();

        endfunction: new

        function update_params();
            
            if (enResiliency) begin
                `define EN_RESILIENCY
            end

            <%for(let i=0; i<obj.AiuInfo.length; i++){%>
                <%if(obj.AiuInfo[i].fnNativeInterface == 'CHI-E'){%>
                    `define SVT_CHI_ISSUE_E_ENABLE
                <%}else{%>
                    `define SVT_CHI_ISSUE_B_ENABLE
                <%}%>
            <%}%>

        endfunction: update_params

    endclass: ncore_params

    <% const prevField = [];
    const constructDefine = (field, width) => {
        if (width <= 0) return '';
        const pField = prevField.pop();
        const returnString = `\`define ${field}_MSB (\`${pField}_MSB+${width})
    \`define ${field}_LSB (\`${pField}_MSB+1)`;

        prevField.push(field);
        return returnString;
    }%>

    <%for(pidx = 0; pidx < obj.nAIUs; pidx++) {
        if (obj.AiuInfo[pidx].fnCsrAccess == 1) {%>
            <%if(pidx < obj.nCHIs){%>
                int chi_id_with_csr_access = <%=pidx%>;
                bit chi_has_csr_access = 1;
                int ioaiu_id_with_csr_access = -1;
                <%break;%>
            <%}else{%>
                bit chi_has_csr_access = 0;
                int chi_id_with_csr_access = -1;
                int ioaiu_id_with_csr_access = <%=(pidx-obj.nCHIs)%>;
                <%break;%>
            <%}%>
        <%}%>
    <%}%>

    //<%if(1==0){%> Logic to handle the flit width differences between the SNPS VIP interface and actual design<%}%>
    typedef struct {
        integer REQ_QOS_MSB;
        integer REQ_QOS_LSB;
        integer REQ_TGTID_MSB;
        integer REQ_TGTID_LSB;
        integer REQ_SRCID_MSB;
        integer REQ_SRCID_LSB;
        integer REQ_TXNID_MSB;
        integer REQ_TXNID_LSB;
        integer REQ_RETNID_MSB;
        integer REQ_RETNID_LSB;
        integer REQ_ENDIAN_MSB;
        integer REQ_ENDIAN_LSB;
        integer REQ_RETTXNID_MSB;
        integer REQ_RETTXNID_LSB;
        integer REQ_OPCODE_MSB;
        integer REQ_OPCODE_LSB;
        integer REQ_SIZE_MSB;
        integer REQ_SIZE_LSB;
        integer REQ_ADDR_MSB;
        integer REQ_ADDR_LSB;
        integer REQ_NS_MSB;
        integer REQ_NS_LSB;
        integer REQ_LIKELYSHRD_MSB;
        integer REQ_LIKELYSHRD_LSB;
        integer REQ_ALLOWRETRY_MSB;
        integer REQ_ALLOWRETRY_LSB;
        integer REQ_ORDER_MSB;
        integer REQ_ORDER_LSB;
        integer REQ_PCRDTYPE_MSB;
        integer REQ_PCRDTYPE_LSB;
        integer REQ_MEMATTR_MSB;
        integer REQ_MEMATTR_LSB;
        integer REQ_SNPATTR_MSB;
        integer REQ_SNPATTR_LSB;
        integer REQ_LPID_MSB;
        integer REQ_LPID_LSB;
        integer REQ_EXCL_MSB;
        integer REQ_EXCL_LSB;
        integer REQ_EXPCOMPACK_MSB;
        integer REQ_EXPCOMPACK_LSB;
        integer REQ_TAGOP_MSB;
        integer REQ_TAGOP_LSB;
        integer REQ_TRACETAG_MSB;
        integer REQ_TRACETAG_LSB;
        integer REQ_RSVDC_MSB;
        integer REQ_RSVDC_LSB;
        integer RSP_QOS_MSB;
        integer RSP_QOS_LSB;
        integer RSP_TGTID_MSB;
        integer RSP_TGTID_LSB;
        integer RSP_SRCID_MSB;
        integer RSP_SRCID_LSB;
        integer RSP_TXNID_MSB;
        integer RSP_TXNID_LSB;
        integer RSP_OPCODE_MSB;
        integer RSP_OPCODE_LSB;
        integer RSP_RESPERR_MSB;
        integer RSP_RESPERR_LSB;
        integer RSP_RESP_MSB;
        integer RSP_RESP_LSB;
        integer RSP_FWDSTATE_MSB;
        integer RSP_FWDSTATE_LSB;
        integer RSP_CBUSY_MSB;
        integer RSP_CBUSY_LSB;
        integer RSP_DBID_MSB;
        integer RSP_DBID_LSB;
        integer RSP_PCRDTYPE_MSB;
        integer RSP_PCRDTYPE_LSB;
        integer RSP_TAGOP_MSB;
        integer RSP_TAGOP_LSB;
        integer RSP_TRACETAG_MSB;
        integer RSP_TRACETAG_LSB;
        integer DAT_QOS_MSB;
        integer DAT_QOS_LSB;
        integer DAT_TGTID_MSB;
        integer DAT_TGTID_LSB;
        integer DAT_SRCID_MSB;
        integer DAT_SRCID_LSB;
        integer DAT_TXNID_MSB;
        integer DAT_TXNID_LSB;
        integer DAT_HOMENID_MSB;
        integer DAT_HOMENID_LSB;
        integer DAT_OPCODE_MSB;
        integer DAT_OPCODE_LSB;
        integer DAT_RESPERR_MSB;
        integer DAT_RESPERR_LSB;
        integer DAT_RESP_MSB;
        integer DAT_RESP_LSB;
        integer DAT_FWDSTATE_MSB;
        integer DAT_FWDSTATE_LSB;
        integer DAT_CBUSY_MSB;
        integer DAT_CBUSY_LSB;
        integer DAT_DBID_MSB;
        integer DAT_DBID_LSB;
        integer DAT_CCID_MSB;
        integer DAT_CCID_LSB;
        integer DAT_DATAID_MSB;
        integer DAT_DATAID_LSB;
        integer DAT_TAGOP_MSB;
        integer DAT_TAGOP_LSB;
        integer DAT_TAG_MSB;
        integer DAT_TAG_LSB;
        integer DAT_TU_MSB;
        integer DAT_TU_LSB;
        integer DAT_TRACETAG_MSB;
        integer DAT_TRACETAG_LSB;
        integer DAT_BE_MSB;
        integer DAT_BE_LSB;
        integer DAT_DATA_MSB;
        integer DAT_DATA_LSB;
        integer DAT_DATACHECK_MSB;
        integer DAT_DATACHECK_LSB;
        integer DAT_POISON_MSB;
        integer DAT_POISON_LSB;
        integer SNP_QOS_MSB;
        integer SNP_QOS_LSB;
        integer SNP_SRCID_MSB;
        integer SNP_SRCID_LSB;
        integer SNP_TXNID_MSB;
        integer SNP_TXNID_LSB;
        integer SNP_FWDNID_MSB;
        integer SNP_FWDNID_LSB;
        integer SNP_FWDTXNID_MSB;
        integer SNP_FWDTXNID_LSB;
        integer SNP_OPCODE_MSB;
        integer SNP_OPCODE_LSB;
        integer SNP_ADDR_MSB;
        integer SNP_ADDR_LSB;
        integer SNP_NS_MSB;
        integer SNP_NS_LSB;
        integer SNP_DONTGOTOSD_MSB;
        integer SNP_DONTGOTOSD_LSB;
        integer SNP_RETTOSRC_MSB;
        integer SNP_RETTOSRC_LSB;
        integer SNP_TRACETAG_MSB;
        integer SNP_TRACETAG_LSB;
    } flit_info_t;
    <%
    //////////////////////////////////////////////////////////////////////////
    //
    //  JAVASCRIPT PROCESSING CODE FOR REQUEST FLITS
    //
    //////////////////////////////////////////////////////////////////////////
    let max_req_qos = 4;
    let max_req_tgtid = 7;
    let max_req_srcid = 7;
    let max_req_txnid = 8;
    let max_req_retnid = 7;
    let max_req_endian = 1;
    let max_req_rettxnid = 8;
    let max_req_opcode = 6;
    let max_req_size = 3;
    let max_req_addr = 44;
    let max_req_ns = 1;
    let max_req_likelyshrd = 1;
    let max_req_allowretry = 1;
    let max_req_order = 2;
    let max_req_pcrdtype = 4;
    let max_req_memattr = 4;
    let max_req_snpattr = 1;
    let max_req_lpid = 5;
    let max_req_excl = 1;
    let max_req_expcompack = 1;
    let max_req_tagop = 0;
    let max_req_tracetag = 1;
    let max_req_rsvdc = 0;

    for( let i=0; i < obj.AiuInfo.length; i++) {
        if(obj.AiuInfo[i].fnNativeInterface.includes('CHI')){
        if(obj.AiuInfo[i].fnNativeInterface == 'CHI-E') {
            max_req_txnid = 12;
            max_req_rettxnid = 12;
            max_req_opcode = 7;
            max_req_lpid = 8;
            max_req_tagop = 2;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.REQ_RSVDC > max_req_rsvdc) {
            max_req_rsvdc = obj.AiuInfo[i].interfaces.chiInt.params.REQ_RSVDC;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.wAddr > max_req_addr) {
            max_req_addr = obj.AiuInfo[i].interfaces.chiInt.params.wAddr;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.TgtID > max_req_tgtid) {
            max_req_tgtid = obj.AiuInfo[i].interfaces.chiInt.params.TgtID;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.SrcID > max_req_srcid) {
            max_req_srcid = obj.AiuInfo[i].interfaces.chiInt.params.SrcID;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.ReturnNID > max_req_retnid) {
            max_req_retnid = obj.AiuInfo[i].interfaces.chiInt.params.ReturnNID;
        }
        }
    }%>

    `define MAX_REQ_QOS_MSB 3
    `define MAX_REQ_QOS_LSB 0
    <%prevField.push("MAX_REQ_QOS");%>
    <%=constructDefine("MAX_REQ_TGTID", max_req_tgtid)%>
    <%=constructDefine("MAX_REQ_SRCID", max_req_srcid)%>
    <%=constructDefine("MAX_REQ_TXNID", max_req_txnid)%>
    <%=constructDefine("MAX_REQ_RETNID", max_req_retnid)%>
    <%=constructDefine("MAX_REQ_ENDIAN", max_req_endian)%>
    <%=constructDefine("MAX_REQ_RETTXNID", max_req_rettxnid)%>
    <%=constructDefine("MAX_REQ_OPCODE", max_req_opcode)%>
    <%=constructDefine("MAX_REQ_SIZE", max_req_size)%>
    <%=constructDefine("MAX_REQ_ADDR", max_req_addr)%>
    <%=constructDefine("MAX_REQ_NS", max_req_ns)%>
    <%=constructDefine("MAX_REQ_LIKELYSHRD", max_req_likelyshrd)%>
    <%=constructDefine("MAX_REQ_ALLOWRETRY", max_req_allowretry)%>
    <%=constructDefine("MAX_REQ_ORDER", max_req_order)%>
    <%=constructDefine("MAX_REQ_PCRDTYPE", max_req_pcrdtype)%>
    <%=constructDefine("MAX_REQ_MEMATTR", max_req_memattr)%>
    <%=constructDefine("MAX_REQ_SNPATTR", max_req_snpattr)%>
    <%=constructDefine("MAX_REQ_LPID", max_req_lpid)%>
    <%=constructDefine("MAX_REQ_EXCL", max_req_excl)%>
    <%=constructDefine("MAX_REQ_EXPCOMPACK", max_req_expcompack)%>
    <%=constructDefine("MAX_REQ_TAGOP", max_req_tagop)%>
    <%=constructDefine("MAX_REQ_TRACETAG", max_req_tracetag)%>
    <%=constructDefine("MAX_REQ_RSVDC", max_req_rsvdc)%>

    <%
    let max_rsp_qos = 4;
    let max_rsp_tgtid = 7;
    let max_rsp_srcid = 7;
    let max_rsp_txnid = 8;
    let max_rsp_opcode = 4;
    let max_rsp_resperr = 2;
    let max_rsp_resp = 3;
    let max_rsp_fwdstate = 3;
    let max_rsp_cbusy = 0;
    let max_rsp_dbid = 8;
    let max_rsp_pcrdtype = 4;
    let max_rsp_tagop = 0;
    let max_rsp_tracetag = 1;

    for( let i=0; i < obj.AiuInfo.length; i++) {
        if(obj.AiuInfo[i].fnNativeInterface.includes('CHI')){

        if(obj.AiuInfo[i].fnNativeInterface == 'CHI-E') {
            max_rsp_txnid = 12;
            max_rsp_opcode = 5;
            max_rsp_cbusy = 3;
            max_rsp_dbid = 12;
            max_rsp_tagop = 2;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.TgtID > max_rsp_tgtid) {
            max_rsp_tgtid = obj.AiuInfo[i].interfaces.chiInt.params.TgtID;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.SrcID > max_rsp_srcid) {
            max_rsp_srcid = obj.AiuInfo[i].interfaces.chiInt.params.SrcID;
        }
        }
    }%>
    `define MAX_RSP_QOS_MSB 3
    `define MAX_RSP_QOS_LSB 0
    <%prevField.push("MAX_RSP_QOS");%>
    <%=constructDefine("MAX_RSP_TGTID", max_rsp_tgtid)%>
    <%=constructDefine("MAX_RSP_SRCID", max_rsp_srcid)%>
    <%=constructDefine("MAX_RSP_TXNID", max_rsp_txnid)%>
    <%=constructDefine("MAX_RSP_OPCODE", max_rsp_opcode)%>
    <%=constructDefine("MAX_RSP_RESPERR", max_rsp_resperr)%>
    <%=constructDefine("MAX_RSP_RESP", max_rsp_resp)%>
    <%=constructDefine("MAX_RSP_FWDSTATE", max_rsp_fwdstate)%>
    <%=constructDefine("MAX_RSP_CBUSY", max_rsp_cbusy)%>
    <%=constructDefine("MAX_RSP_DBID", max_rsp_dbid)%>
    <%=constructDefine("MAX_RSP_PCRDTYPE", max_rsp_pcrdtype)%>
    <%=constructDefine("MAX_RSP_TAGOP", max_rsp_tagop)%>
    <%=constructDefine("MAX_RSP_TRACETAG", max_rsp_tracetag)%>
    <%
    let max_rsp_flit = {};

    let max_dat_qos = 4;
    let max_dat_tgtid = 7;
    let max_dat_srcid = 7;
    let max_dat_txnid = 8;
    let max_dat_homenid = 7;
    let max_dat_opcode = 3;
    let max_dat_resperr = 2;
    let max_dat_resp = 3;
    let max_dat_fwdstate = 3;
    let max_dat_cbusy = 0;
    let max_dat_dbid = 8;
    let max_dat_ccid = 2;
    let max_dat_dataid = 2;
    let max_dat_tagop = 0;
    let max_dat_tag = 0;
    let max_dat_tu = 0;
    let max_dat_tracetag = 1;
    let max_dat_be = 16;
    let max_dat_data = 128;
    let max_dat_datacheck = 0;
    let max_dat_poison = 0;

    let has_atleast_one_chie = 0;

    //FIXME: If there is a CHI-E with smaller wData than CHI-B in the same config,
    // will max_dat_tag, max_dat_tu be computed on the max_data width on all configs? or just CHI-E config

    for( let i=0; i < obj.AiuInfo.length; i++) {
        if(obj.AiuInfo[i].fnNativeInterface.includes('CHI')){
        if (obj.AiuInfo[i].interfaces.chiInt.params.wData > max_dat_data) {
            max_dat_data = obj.AiuInfo[i].interfaces.chiInt.params.wData;
            max_dat_be = max_dat_data/8;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.useDataCheck) {
            max_dat_datacheck = max_dat_data/8;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.enPoison) {
            max_dat_poison = max_dat_data/64;
        }
        if(obj.AiuInfo[i].fnNativeInterface == 'CHI-E') {
            max_dat_txnid = 12;
            max_dat_opcode = 4;
            max_dat_fwdstate = 4;
            max_dat_cbusy = 3;
            max_dat_dbid = 12;
            max_dat_tagop = 2;
            has_atleast_one_chie = 1;
        }
        
        if (obj.AiuInfo[i].interfaces.chiInt.params.wAddr > max_req_addr) {
            max_req_addr = obj.AiuInfo[i].interfaces.chiInt.params.wAddr;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.TgtID > max_dat_tgtid) {
            max_dat_tgtid = obj.AiuInfo[i].interfaces.chiInt.params.TgtID;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.SrcID > max_dat_srcid) {
            max_dat_srcid = obj.AiuInfo[i].interfaces.chiInt.params.SrcID;
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.Homenode_ID > max_dat_homenid) {
            max_dat_homenid = obj.AiuInfo[i].interfaces.chiInt.params.Homenode_ID;
        }
        }
    }

    if (has_atleast_one_chie) {
        max_dat_tag = max_dat_data/32;
        max_dat_tu = max_dat_data/128;
    }%>
    `define MAX_DAT_QOS_MSB 3
    `define MAX_DAT_QOS_LSB 0
    <%prevField.push("MAX_DAT_QOS");%>
    <%=constructDefine("MAX_DAT_TGTID", max_rsp_tgtid)%>
    <%=constructDefine("MAX_DAT_SRCID", max_dat_srcid)%>
    <%=constructDefine("MAX_DAT_TXNID", max_dat_txnid)%>
    <%=constructDefine("MAX_DAT_HOMENID", max_dat_homenid)%>
    <%=constructDefine("MAX_DAT_OPCODE", max_dat_opcode)%>
    <%=constructDefine("MAX_DAT_RESPERR", max_dat_resperr)%>
    <%=constructDefine("MAX_DAT_RESP", max_dat_resp)%>
    <%=constructDefine("MAX_DAT_FWDSTATE", max_dat_fwdstate)%>
    <%=constructDefine("MAX_DAT_CBUSY", max_dat_cbusy)%>
    <%=constructDefine("MAX_DAT_DBID", max_dat_dbid)%>
    <%=constructDefine("MAX_DAT_CCID", max_dat_ccid)%>
    <%=constructDefine("MAX_DAT_DATAID", max_dat_dataid)%>
    <%=constructDefine("MAX_DAT_TAGOP", max_dat_tagop)%>
    <%=constructDefine("MAX_DAT_TAG", max_dat_tag)%>
    <%=constructDefine("MAX_DAT_TU", max_dat_tu)%>
    <%=constructDefine("MAX_DAT_TRACETAG", max_dat_tracetag)%>
    <%=constructDefine("MAX_DAT_BE", max_dat_be)%>
    <%=constructDefine("MAX_DAT_DATA", max_dat_data)%>
    <%=constructDefine("MAX_DAT_DATACHECK", max_dat_datacheck)%>
    <%=constructDefine("MAX_DAT_POISON", max_dat_poison)%>
    <%
    let max_dat_flit = {};

    let max_snp_qos         = 4;
    let max_snp_srcid       = 7;
    let max_snp_txnid       = 8;
    let max_snp_fwdnid      = 7;
    let max_snp_fwdtxnid    = 8;
    let max_snp_opcode      = 5;
    let max_snp_addr        = 41;
    let max_snp_ns          = 1;
    let max_snp_dontgotosd  = 1;
    let max_snp_rettosrc    = 1;
    let max_snp_tracetag    = 1;


    for( let i=0; i < obj.AiuInfo.length; i++) {
        if(obj.AiuInfo[i].fnNativeInterface.includes('CHI')){
        if(obj.AiuInfo[i].fnNativeInterface == 'CHI-E') {
            max_snp_txnid = 12;
            max_snp_fwdtxnid = 12;
        }
        
        if ((obj.AiuInfo[i].interfaces.chiInt.params.wAddr-3) > max_snp_addr) {
            max_snp_addr = (obj.AiuInfo[i].interfaces.chiInt.params.wAddr-3);
        }
        if ((obj.AiuInfo[i].interfaces.chiInt.params.SrcID) > max_snp_srcid) {
            max_snp_srcid = (obj.AiuInfo[i].interfaces.chiInt.params.SrcID);
        }
        if ((obj.AiuInfo[i].interfaces.chiInt.params.FwdNID) > max_snp_fwdnid) {
            max_snp_fwdnid = (obj.AiuInfo[i].interfaces.chiInt.params.FwdNID);
        }
        }
    }%>
    `define MAX_SNP_QOS_MSB 3
    `define MAX_SNP_QOS_LSB 0
    <%prevField.push("MAX_SNP_QOS");%>
    <%=constructDefine("MAX_SNP_SRCID", max_snp_srcid)%>
    <%=constructDefine("MAX_SNP_TXNID", max_snp_txnid)%>
    <%=constructDefine("MAX_SNP_FWDNID", max_snp_fwdnid)%>
    <%=constructDefine("MAX_SNP_FWDTXNID", max_snp_fwdtxnid)%>
    <%=constructDefine("MAX_SNP_OPCODE", max_snp_opcode)%>
    <%=constructDefine("MAX_SNP_ADDR", max_snp_addr)%>
    <%=constructDefine("MAX_SNP_NS", max_snp_ns)%>
    <%=constructDefine("MAX_SNP_DONTGOTOSD", max_snp_dontgotosd)%>
    <%=constructDefine("MAX_SNP_RETTOSRC", max_snp_rettosrc)%>
    <%=constructDefine("MAX_SNP_TRACETAG", max_snp_tracetag)%>
    <%

    let max_snp_flit = {};

    let req_flit_array = [];    
    let rsp_flit_array = [];    
    let dat_flit_array = [];    
    let snp_flit_array = [];
    let req_flit = {};
    let rsp_flit = {};
    let dat_flit = {};
    let snp_flit = {}; 

    for (let i=0; i< obj.AiuInfo.length; i+=1) {
        if(obj.AiuInfo[i].fnNativeInterface.includes('CHI')){
        req_flit = {};
        rsp_flit = {};
        dat_flit = {};
        snp_flit = {};

        req_flit['qos']        = 3;
        req_flit['tgtid']      = obj.AiuInfo[i].interfaces.chiInt.params.TgtID + req_flit['qos'];
        req_flit['srcid']      = obj.AiuInfo[i].interfaces.chiInt.params.SrcID + req_flit['tgtid'];
        req_flit['txnid']      = obj.AiuInfo[i].interfaces.chiInt.params.TxnID + req_flit['srcid'];
        req_flit['retnid']     = obj.AiuInfo[i].interfaces.chiInt.params.ReturnNID + req_flit['txnid'];
        req_flit['endian']     = 1 + req_flit['retnid'];
        req_flit['rettxnid']   = obj.AiuInfo[i].interfaces.chiInt.params.ReturnTxnID + req_flit['endian'];
        req_flit['opcode']     = obj.AiuInfo[i].interfaces.chiInt.params.REQ_Opcode + req_flit['rettxnid'];
        req_flit['size']       = 3 + req_flit['opcode'];
        req_flit['addr']       = obj.AiuInfo[i].interfaces.chiInt.params.wAddr + req_flit['size'];
        req_flit['ns']         = 1 + req_flit['addr'];
        req_flit['likelyshrd'] = 1 + req_flit['ns'];
        req_flit['allowretry'] = 1 + req_flit['likelyshrd'];
        req_flit['order']      = 2 + req_flit['allowretry'];
        req_flit['pcrdtype']   = 4 + req_flit['order'];
        req_flit['memattr']    = 4 + req_flit['pcrdtype'];
        req_flit['snpattr']    = 1 + req_flit['memattr'];
        req_flit['lpid']       = (obj.AiuInfo[i].fnNativeInterface == 'CHI-E' ? 8:5) + req_flit['snpattr'];
        req_flit['excl']       = 1 + req_flit['lpid'];
        req_flit['expcompack'] = 1 + req_flit['excl'];
        req_flit['tagop']      = (obj.AiuInfo[i].interfaces.chiInt.params.TagOp ? obj.AiuInfo[i].interfaces.chiInt.params.TagOp : 0) + req_flit['expcompack'];
        req_flit['tracetag']   = 1 + req_flit['tagop'];
        req_flit['rsvdc']      = obj.AiuInfo[i].interfaces.chiInt.params.REQ_RSVDC + req_flit['tracetag'];

        req_flit_array.push(req_flit);

        rsp_flit['qos']        = 3;
        rsp_flit['tgtid']      = obj.AiuInfo[i].interfaces.chiInt.params.TgtID + rsp_flit['qos'];
        rsp_flit['srcid']      = obj.AiuInfo[i].interfaces.chiInt.params.SrcID + rsp_flit['tgtid'];
        rsp_flit['txnid']      = obj.AiuInfo[i].interfaces.chiInt.params.TxnID + rsp_flit['srcid'];
        rsp_flit['opcode']     = obj.AiuInfo[i].interfaces.chiInt.params.RSP_Opcode + rsp_flit['txnid'];
        rsp_flit['resperr']    = 2 + rsp_flit['opcode'];
        rsp_flit['resp']       = 3 + rsp_flit['resperr'];
        rsp_flit['fwdstate']   = 3 + rsp_flit['resp'];
        rsp_flit['cbusy']      = (obj.AiuInfo[i].interfaces.chiInt.params.CBusy? obj.AiuInfo[i].interfaces.chiInt.params.CBusy : 0) + rsp_flit['fwdstate'];
        rsp_flit['dbid']       = obj.AiuInfo[i].interfaces.chiInt.params.DBID + rsp_flit['cbusy'];
        rsp_flit['pcrdtype']   = 4 + rsp_flit['dbid'];
        rsp_flit['tagop']      = (obj.AiuInfo[i].interfaces.chiInt.params.TagOp ? obj.AiuInfo[i].interfaces.chiInt.params.TagOp : 0) + rsp_flit['pcrdtype'];
        rsp_flit['tracetag']   = 1 + rsp_flit['tagop'];

        rsp_flit_array.push(rsp_flit);

        dat_flit['qos']        = 3;
        dat_flit['tgtid']      = obj.AiuInfo[i].interfaces.chiInt.params.TgtID + dat_flit['qos'];
        dat_flit['srcid']      = obj.AiuInfo[i].interfaces.chiInt.params.SrcID + dat_flit['tgtid'];
        dat_flit['txnid']      = obj.AiuInfo[i].interfaces.chiInt.params.TxnID + dat_flit['srcid'];
        dat_flit['homenid']     = obj.AiuInfo[i].interfaces.chiInt.params.Homenode_ID + dat_flit['txnid'];
        dat_flit['opcode']     = obj.AiuInfo[i].interfaces.chiInt.params.DAT_Opcode + dat_flit['homenid'];
        dat_flit['resperr']   = 2 + dat_flit['opcode'];
        dat_flit['resp']     = 3 + dat_flit['resperr'];
        dat_flit['fwdstate']       = (obj.AiuInfo[i].interfaces.chiInt.params.DataSource ? obj.AiuInfo[i].interfaces.chiInt.params.DataSource : obj.AiuInfo[i].interfaces.chiInt.params.FwdState) + dat_flit['resp'];
        dat_flit['cbusy']       = (obj.AiuInfo[i].interfaces.chiInt.params.CBusy? obj.AiuInfo[i].interfaces.chiInt.params.CBusy : 0) + dat_flit['fwdstate'];
        dat_flit['dbid']         = obj.AiuInfo[i].interfaces.chiInt.params.DBID + dat_flit['cbusy'];
        dat_flit['ccid'] = 2 + dat_flit['dbid'];
        dat_flit['dataid'] = 2 + dat_flit['ccid'];
        if(obj.AiuInfo[i].fnNativeInterface == 'CHI-E'){
            dat_flit['tagop'] = obj.AiuInfo[i].interfaces.chiInt.params.TagOp + dat_flit['dataid'];
            dat_flit['tag']   = (obj.AiuInfo[i].interfaces.chiInt.params.wData/32) + dat_flit['tagop'];
            dat_flit['tu']    = (obj.AiuInfo[i].interfaces.chiInt.params.wData/128) + dat_flit['tag'];
        } else {
            dat_flit['tagop'] = dat_flit['dataid'];
            dat_flit['tag']   = dat_flit['tagop'];
            dat_flit['tu']    = dat_flit['tag'];
        }

        dat_flit['tracetag']    = 1 + dat_flit['tu'];
        dat_flit['be']       = (obj.AiuInfo[i].interfaces.chiInt.params.wData/8) + dat_flit['tracetag'];
        dat_flit['data']       = (obj.AiuInfo[i].interfaces.chiInt.params.wData) + dat_flit['be'];

        if (obj.AiuInfo[i].interfaces.chiInt.params.useDataCheck) {
            dat_flit['datacheck'] = (obj.AiuInfo[i].interfaces.chiInt.params.wData/8) + dat_flit['data'];
        } else {
            dat_flit['datacheck'] = dat_flit['data'];
        }
        if (obj.AiuInfo[i].interfaces.chiInt.params.enPoison) {
            dat_flit['poison'] =  (obj.AiuInfo[i].interfaces.chiInt.params.wData/64) + dat_flit['datacheck'];
        } else {
            dat_flit['poison'] = dat_flit['datacheck'];
        }

        dat_flit_array.push(dat_flit);

        snp_flit['qos'] = 3;
        snp_flit['srcid'] = obj.AiuInfo[i].interfaces.chiInt.params.TgtID + snp_flit['qos'];
        snp_flit['txnid'] = obj.AiuInfo[i].interfaces.chiInt.params.TxnID + snp_flit['srcid'];
        snp_flit['fwdnid'] = obj.AiuInfo[i].interfaces.chiInt.params.FwdNID + snp_flit['txnid'];
        snp_flit['fwdtxnid'] = obj.AiuInfo[i].interfaces.chiInt.params.TxnID + snp_flit['fwdnid'];
        snp_flit['opcode'] = 5 + snp_flit['fwdtxnid'];
        snp_flit['addr'] = (obj.AiuInfo[i].interfaces.chiInt.params.wAddr-3) + snp_flit['opcode'];
        snp_flit['ns'] = 1 + snp_flit['addr'];
        snp_flit['dontgotosd'] = 1 + snp_flit['ns'];
        snp_flit['rettosrc'] = 1 + snp_flit['dontgotosd'];
        snp_flit['tracetag'] = 1 + snp_flit['rettosrc'];

        snp_flit_array.push(snp_flit);
        }
    }%>
    <%if(obj.nCHIs > 0){%>
    parameter flit_info_t FLIT_INFO[<%=obj.nCHIs%>] = '{
        <%for(let i=0; i<obj.nCHIs; i+=1){%>
            {
                <%req_flit = req_flit_array[i];%>
                <%rsp_flit = rsp_flit_array[i];%>
                <%dat_flit = dat_flit_array[i];%>
                <%snp_flit = snp_flit_array[i];%>
                REQ_QOS_MSB: <%=req_flit['qos']%>,
                REQ_QOS_LSB: 0,
                REQ_TGTID_MSB: <%=req_flit['tgtid']%>,
                REQ_TGTID_LSB: <%=(req_flit['qos']+1)%>,
                REQ_SRCID_MSB: <%=(req_flit['srcid'])%>,
                REQ_SRCID_LSB: <%=(req_flit['tgtid']+1)%>,
                REQ_TXNID_MSB: <%=(req_flit['txnid'])%>,
                REQ_TXNID_LSB: <%=(req_flit['srcid']+1)%>,
                REQ_RETNID_MSB: <%=(req_flit['retnid'])%>,
                REQ_RETNID_LSB: <%=(req_flit['txnid']+1)%>,
                REQ_ENDIAN_MSB: <%=(req_flit['endian'])%>,
                REQ_ENDIAN_LSB: <%=(req_flit['retnid']+1)%>,
                REQ_RETTXNID_MSB: <%=(req_flit['rettxnid'])%>,
                REQ_RETTXNID_LSB: <%=(req_flit['endian']+1)%>,
                REQ_OPCODE_MSB: <%=(req_flit['opcode'])%>,
                REQ_OPCODE_LSB: <%=(req_flit['rettxnid']+1)%>,
                REQ_SIZE_MSB: <%=(req_flit['size'])%>,
                REQ_SIZE_LSB: <%=(req_flit['opcode']+1)%>,
                REQ_ADDR_MSB: <%=(req_flit['addr'])%>,
                REQ_ADDR_LSB: <%=(req_flit['size']+1)%>,
                REQ_NS_MSB: <%=(req_flit['ns'])%>,
                REQ_NS_LSB: <%=(req_flit['addr']+1)%>,
                REQ_LIKELYSHRD_MSB: <%=(req_flit['likelyshrd'])%>,
                REQ_LIKELYSHRD_LSB: <%=(req_flit['ns']+1)%>,
                REQ_ALLOWRETRY_MSB: <%=(req_flit['allowretry'])%>,
                REQ_ALLOWRETRY_LSB: <%=(req_flit['likelyshrd']+1)%>,
                REQ_ORDER_MSB: <%=(req_flit['order'])%>,
                REQ_ORDER_LSB: <%=(req_flit['allowretry']+1)%>,
                REQ_PCRDTYPE_MSB: <%=(req_flit['pcrdtype'])%>,
                REQ_PCRDTYPE_LSB: <%=(req_flit['order']+1)%>,
                REQ_MEMATTR_MSB: <%=(req_flit['memattr'])%>,
                REQ_MEMATTR_LSB: <%=(req_flit['pcrdtype']+1)%>,
                REQ_SNPATTR_MSB: <%=(req_flit['snpattr'])%>,
                REQ_SNPATTR_LSB: <%=(req_flit['memattr']+1)%>,
                REQ_LPID_MSB: <%=(req_flit['lpid'])%>,
                REQ_LPID_LSB: <%=(req_flit['snpattr']+1)%>,
                REQ_EXCL_MSB: <%=(req_flit['excl'])%>,
                REQ_EXCL_LSB: <%=(req_flit['lpid']+1)%>,
                REQ_EXPCOMPACK_MSB: <%=(req_flit['expcompack'])%>,
                REQ_EXPCOMPACK_LSB: <%=(req_flit['excl']+1)%>,
                REQ_TAGOP_MSB: <%=(req_flit['tagop'])%>,
                REQ_TAGOP_LSB: <%=(req_flit['expcompack']+1)%>,
                REQ_TRACETAG_MSB: <%=(req_flit['tracetag'])%>,
                REQ_TRACETAG_LSB: <%=(req_flit['tagop']+1)%>,
                REQ_RSVDC_MSB: <%=((req_flit['rsvdc'] == req_flit['tracetag']) ? (-1) : (req_flit['rsvdc']))%>,
                REQ_RSVDC_LSB: <%=(req_flit['tracetag']+1)%>,
                RSP_QOS_MSB: <%=(rsp_flit['qos'])%>,
                RSP_QOS_LSB: <%=0%>,
                RSP_TGTID_MSB: <%=(rsp_flit['tgtid'])%>,
                RSP_TGTID_LSB: <%=(rsp_flit['qos']+1)%>,
                RSP_SRCID_MSB: <%=(rsp_flit['srcid'])%>,
                RSP_SRCID_LSB: <%=(rsp_flit['tgtid']+1)%>,
                RSP_TXNID_MSB: <%=(rsp_flit['txnid'])%>,
                RSP_TXNID_LSB: <%=(rsp_flit['srcid']+1)%>,
                RSP_OPCODE_MSB: <%=(rsp_flit['opcode'])%>,
                RSP_OPCODE_LSB: <%=(rsp_flit['txnid']+1)%>,
                RSP_RESPERR_MSB: <%=(rsp_flit['resperr'])%>,
                RSP_RESPERR_LSB: <%=(rsp_flit['opcode']+1)%>,
                RSP_RESP_MSB: <%=(rsp_flit['resp'])%>,
                RSP_RESP_LSB: <%=(rsp_flit['resperr']+1)%>,
                RSP_FWDSTATE_MSB: <%=(rsp_flit['fwdstate'])%>,
                RSP_FWDSTATE_LSB: <%=(rsp_flit['resp']+1)%>,
                RSP_CBUSY_MSB: <%=(rsp_flit['cbusy'])%>,
                RSP_CBUSY_LSB: <%=(rsp_flit['fwdstate']+1)%>,
                RSP_DBID_MSB: <%=(rsp_flit['dbid'])%>,
                RSP_DBID_LSB: <%=(rsp_flit['cbusy']+1)%>,
                RSP_PCRDTYPE_MSB: <%=(rsp_flit['pcrdtype'])%>,
                RSP_PCRDTYPE_LSB: <%=(rsp_flit['dbid']+1)%>,
                RSP_TAGOP_MSB: <%=(rsp_flit['tagop'])%>,
                RSP_TAGOP_LSB: <%=(rsp_flit['pcrdtype']+1)%>,
                RSP_TRACETAG_MSB: <%=(rsp_flit['tracetag'])%>,
                RSP_TRACETAG_LSB: <%=(rsp_flit['tagop']+1)%>,
                DAT_QOS_MSB: <%=(dat_flit['qos'])%>,
                DAT_QOS_LSB: <%=0%>,
                DAT_TGTID_MSB: <%=(dat_flit['tgtid'])%>,
                DAT_TGTID_LSB: <%=(dat_flit['qos']+1)%>,
                DAT_SRCID_MSB: <%=(dat_flit['srcid'])%>,
                DAT_SRCID_LSB: <%=(dat_flit['tgtid']+1)%>,
                DAT_TXNID_MSB: <%=(dat_flit['txnid'])%>,
                DAT_TXNID_LSB: <%=(dat_flit['srcid']+1)%>,
                DAT_HOMENID_MSB: <%=(dat_flit['homenid'])%>,
                DAT_HOMENID_LSB: <%=(dat_flit['txnid']+1)%>,
                DAT_OPCODE_MSB: <%=(dat_flit['opcode'])%>,
                DAT_OPCODE_LSB: <%=(dat_flit['homenid']+1)%>,
                DAT_RESPERR_MSB: <%=(dat_flit['resperr'])%>,
                DAT_RESPERR_LSB: <%=(dat_flit['opcode']+1)%>,
                DAT_RESP_MSB: <%=(dat_flit['resp'])%>,
                DAT_RESP_LSB: <%=(dat_flit['resperr']+1)%>,
                DAT_FWDSTATE_MSB: <%=(dat_flit['fwdstate'])%>,
                DAT_FWDSTATE_LSB: <%=(dat_flit['resp']+1)%>,
                DAT_CBUSY_MSB: <%=(dat_flit['cbusy'])%>,
                DAT_CBUSY_LSB: <%=(dat_flit['fwdstate']+1)%>,
                DAT_DBID_MSB: <%=(dat_flit['dbid'])%>,
                DAT_DBID_LSB: <%=(dat_flit['cbusy']+1)%>,
                DAT_CCID_MSB: <%=(dat_flit['ccid'])%>,
                DAT_CCID_LSB: <%=(dat_flit['dbid']+1)%>,
                DAT_DATAID_MSB: <%=(dat_flit['dataid'])%>,
                DAT_DATAID_LSB: <%=(dat_flit['ccid']+1)%>,
                DAT_TAGOP_MSB: <%=(dat_flit['tagop'])%>,
                DAT_TAGOP_LSB: <%=(dat_flit['dataid']+1)%>,
                DAT_TAG_MSB: <%=(dat_flit['tag'])%>,
                DAT_TAG_LSB: <%=(dat_flit['tagop']+1)%>,
                DAT_TU_MSB: <%=(dat_flit['tu'])%>,
                DAT_TU_LSB: <%=(dat_flit['tag']+1)%>,
                DAT_TRACETAG_MSB: <%=(dat_flit['tracetag'])%>,
                DAT_TRACETAG_LSB: <%=(dat_flit['tu']+1)%>,
                DAT_BE_MSB: <%=(dat_flit['be'])%>,
                DAT_BE_LSB: <%=(dat_flit['tracetag']+1)%>,
                DAT_DATA_MSB: <%=(dat_flit['data'])%>,
                DAT_DATA_LSB: <%=(dat_flit['be']+1)%>,
                DAT_DATACHECK_MSB: <%=(dat_flit['datacheck'])%>,
                DAT_DATACHECK_LSB: <%=(dat_flit['data']+1)%>,
                DAT_POISON_MSB: <%=(dat_flit['poison'])%>,
                DAT_POISON_LSB: <%=(dat_flit['datacheck']+1)%>,
                SNP_QOS_MSB: <%=snp_flit['qos']%>,
                SNP_QOS_LSB: <%=0%>,
                SNP_SRCID_MSB: <%=snp_flit['srcid']%>,
                SNP_SRCID_LSB: <%=(snp_flit['qos']+1)%>,
                SNP_TXNID_MSB: <%=(snp_flit['txnid'])%>,
                SNP_TXNID_LSB: <%=(snp_flit['srcid']+1)%>,
                SNP_FWDNID_MSB: <%=(snp_flit['fwdnid'])%>,
                SNP_FWDNID_LSB: <%=(snp_flit['txnid']+1)%>,
                SNP_FWDTXNID_MSB: <%=(snp_flit['fwdtxnid'])%>,
                SNP_FWDTXNID_LSB: <%=(snp_flit['fwdnid']+1)%>,
                SNP_OPCODE_MSB: <%=(snp_flit['opcode'])%>,
                SNP_OPCODE_LSB: <%=(snp_flit['fwdtxnid']+1)%>,
                SNP_ADDR_MSB: <%=(snp_flit['addr'])%>,
                SNP_ADDR_LSB: <%=(snp_flit['opcode']+1)%>,
                SNP_NS_MSB: <%=(snp_flit['ns'])%>,
                SNP_NS_LSB: <%=(snp_flit['addr']+1)%>,
                SNP_DONTGOTOSD_MSB: <%=(snp_flit['dontgotosd'])%>,
                SNP_DONTGOTOSD_LSB: <%=(snp_flit['ns']+1)%>,
                SNP_RETTOSRC_MSB: <%=(snp_flit['rettosrc'])%>,
                SNP_RETTOSRC_LSB: <%=(snp_flit['dontgotosd']+1)%>,
                SNP_TRACETAG_MSB: <%=(snp_flit['tracetag'])%>,
                SNP_TRACETAG_LSB: <%=(snp_flit['rettosrc']+1)%>
            }
            <%if(i != obj.nCHIs-1){%>,<%}%>
        <%}%>
    };
    <%}%>

endpackage: <%=obj.filename%>
