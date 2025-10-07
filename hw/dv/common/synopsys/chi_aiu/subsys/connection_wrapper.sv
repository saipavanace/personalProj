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
let max_req_rsvdv = 0;

for( let i=0; i < obj.nCHIs; i++) {
    if(obj.ChiaiuInfo[i].fnNativeInterface == 'CHI-E') {
        max_req_txnid = 12;
        max_req_rettxnid = 12;
        max_req_opcode = 7;
        max_req_lpid = 8;
        max_req_tagop = 2;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.REQ_RSVDC > max_req_rsvdv) {
        max_req_rsvdv = obj.ChiaiuInfo[i].interfaces.chiInt.params.REQ_RSVDC;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.wAddr > max_req_addr) {
        max_req_addr = obj.ChiaiuInfo[i].interfaces.chiInt.params.wAddr;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.TgtID > max_req_tgtid) {
        max_req_tgtid = obj.ChiaiuInfo[i].interfaces.chiInt.params.TgtID;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.SrcID > max_req_srcid) {
        max_req_srcid = obj.ChiaiuInfo[i].interfaces.chiInt.params.SrcID;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.ReturnNID > max_req_retnid) {
        max_req_retnid = obj.ChiaiuInfo[i].interfaces.chiInt.params.ReturnNID;
    }
}

let max_req_flit = {};

max_req_flit['qos']        = 3;
max_req_flit['tgtid']      = max_req_tgtid + max_req_flit['qos'];
max_req_flit['srcid']      = max_req_srcid + max_req_flit['tgtid'];
max_req_flit['txnid']      = max_req_txnid + max_req_flit['srcid'];
max_req_flit['retnid']     = max_req_retnid + max_req_flit['txnid'];
max_req_flit['endian']     = max_req_endian + max_req_flit['retnid'];
max_req_flit['rettxnid']   = max_req_rettxnid + max_req_flit['endian'];
max_req_flit['opcode']     = max_req_opcode + max_req_flit['rettxnid'];
max_req_flit['size']       = max_req_size + max_req_flit['opcode'];
max_req_flit['addr']       = max_req_addr + max_req_flit['size'];
max_req_flit['ns']         = max_req_ns + max_req_flit['addr'];
max_req_flit['likelyshrd'] = max_req_likelyshrd + max_req_flit['ns'];
max_req_flit['allowretry'] = max_req_allowretry + max_req_flit['likelyshrd'];
max_req_flit['order']      = max_req_order + max_req_flit['allowretry'];
max_req_flit['pcrdtype']   = max_req_pcrdtype + max_req_flit['order'];
max_req_flit['memattr']    = max_req_memattr + max_req_flit['pcrdtype'];
max_req_flit['snpattr']    = max_req_snpattr + max_req_flit['memattr'];
max_req_flit['lpid']       = max_req_lpid + max_req_flit['snpattr'];
max_req_flit['excl']       = max_req_excl + max_req_flit['lpid'];
max_req_flit['expcompack'] = max_req_expcompack + max_req_flit['excl'];
max_req_flit['tagop']      = max_req_tagop + max_req_flit['expcompack'];
max_req_flit['tracetag']   = max_req_tracetag + max_req_flit['tagop'];
max_req_flit['rsvdc']      = max_req_rsvdv + max_req_flit['tracetag'];

let req_flit = {};
req_flit['qos']        = 3;
req_flit['tgtid']      = obj.AiuInfo[obj.Id].interfaces.chiInt.params.TgtID + req_flit['qos'];
req_flit['srcid']      = obj.AiuInfo[obj.Id].interfaces.chiInt.params.SrcID + req_flit['tgtid'];
req_flit['txnid']      = obj.AiuInfo[obj.Id].interfaces.chiInt.params.TxnID + req_flit['srcid'];
req_flit['retnid']     = obj.AiuInfo[obj.Id].interfaces.chiInt.params.ReturnNID + req_flit['txnid'];
req_flit['endian']     = 1 + req_flit['retnid'];
req_flit['rettxnid']   = obj.AiuInfo[obj.Id].interfaces.chiInt.params.ReturnTxnID + req_flit['endian'];
req_flit['opcode']     = obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_Opcode + req_flit['rettxnid'];
req_flit['size']       = 3 + req_flit['opcode'];
req_flit['addr']       = obj.AiuInfo[obj.Id].interfaces.chiInt.params.wAddr + req_flit['size'];
req_flit['ns']         = 1 + req_flit['addr'];
req_flit['likelyshrd'] = 1 + req_flit['ns'];
req_flit['allowretry'] = 1 + req_flit['likelyshrd'];
req_flit['order']      = 2 + req_flit['allowretry'];
req_flit['pcrdtype']   = 4 + req_flit['order'];
req_flit['memattr']    = 4 + req_flit['pcrdtype'];
req_flit['snpattr']    = 1 + req_flit['memattr'];
req_flit['lpid']       = ((obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') ? 8 : obj.AiuInfo[obj.Id].interfaces.chiInt.params.LPID) + req_flit['snpattr'];
req_flit['excl']       = 1 + req_flit['lpid'];
req_flit['expcompack'] = 1 + req_flit['excl'];
req_flit['tagop']      = (obj.AiuInfo[obj.Id].interfaces.chiInt.params.TagOp ? obj.AiuInfo[obj.Id].interfaces.chiInt.params.TagOp : 0) + req_flit['expcompack'];
req_flit['tracetag']   = 1 + req_flit['tagop'];
req_flit['rsvdc']      = obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC + req_flit['tracetag'];

//////////////////////////////////////////////////////////////////////////
//
//  JAVASCRIPT PROCESSING CODE FOR RSP FLITS
//
//////////////////////////////////////////////////////////////////////////
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

for( let i=0; i < obj.nCHIs; i++) {
    if(obj.ChiaiuInfo[i].fnNativeInterface == 'CHI-E') {
        max_rsp_txnid = 12;
        max_rsp_opcode = 5;
        max_rsp_cbusy = 3;
        max_rsp_dbid = 12;
        max_rsp_tagop = 2;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.TgtID > max_rsp_tgtid) {
        max_rsp_tgtid = obj.ChiaiuInfo[i].interfaces.chiInt.params.TgtID;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.SrcID > max_rsp_srcid) {
        max_rsp_srcid = obj.ChiaiuInfo[i].interfaces.chiInt.params.SrcID;
    }
}

let max_rsp_flit = {};

max_rsp_flit['qos']        = 3;
max_rsp_flit['tgtid']      = max_rsp_tgtid + max_rsp_flit['qos'];
max_rsp_flit['srcid']      = max_rsp_srcid + max_rsp_flit['tgtid'];
max_rsp_flit['txnid']      = max_rsp_txnid + max_rsp_flit['srcid'];
max_rsp_flit['opcode']     = max_rsp_opcode + max_rsp_flit['txnid'];
max_rsp_flit['resperr']    = max_rsp_resperr + max_rsp_flit['opcode'];
max_rsp_flit['resp']       = max_rsp_resp + max_rsp_flit['resperr'];
max_rsp_flit['fwdstate']   = max_rsp_fwdstate + max_rsp_flit['resp'];
max_rsp_flit['cbusy']      = max_rsp_cbusy + max_rsp_flit['fwdstate'];
max_rsp_flit['dbid']       = max_rsp_dbid + max_rsp_flit['cbusy'];
max_rsp_flit['pcrdtype']   = max_rsp_pcrdtype + max_rsp_flit['dbid'];
max_rsp_flit['tagop']      = max_rsp_tagop + max_rsp_flit['pcrdtype'];
max_rsp_flit['tracetag']   = max_rsp_tracetag + max_rsp_flit['tagop'];

let rsp_flit = {};

rsp_flit['qos']        = 3;
rsp_flit['tgtid']      = obj.AiuInfo[obj.Id].interfaces.chiInt.params.TgtID + rsp_flit['qos'];
rsp_flit['srcid']      = obj.AiuInfo[obj.Id].interfaces.chiInt.params.SrcID + rsp_flit['tgtid'];
rsp_flit['txnid']      = obj.AiuInfo[obj.Id].interfaces.chiInt.params.TxnID + rsp_flit['srcid'];
rsp_flit['opcode']     = obj.AiuInfo[obj.Id].interfaces.chiInt.params.RSP_Opcode + rsp_flit['txnid'];
rsp_flit['resperr']    = 2 + rsp_flit['opcode'];
rsp_flit['resp']       = 3 + rsp_flit['resperr'];
rsp_flit['fwdstate']   = 3 + rsp_flit['resp'];
rsp_flit['cbusy']      = (obj.AiuInfo[obj.Id].interfaces.chiInt.params.CBusy? obj.AiuInfo[obj.Id].interfaces.chiInt.params.CBusy : 0) + rsp_flit['fwdstate'];
rsp_flit['dbid']       = obj.AiuInfo[obj.Id].interfaces.chiInt.params.DBID + rsp_flit['cbusy'];
rsp_flit['pcrdtype']   = 4 + rsp_flit['dbid'];
rsp_flit['tagop']      = (obj.AiuInfo[obj.Id].interfaces.chiInt.params.TagOp ? obj.AiuInfo[obj.Id].interfaces.chiInt.params.TagOp : 0) + rsp_flit['pcrdtype'];
rsp_flit['tracetag']   = 1 + rsp_flit['tagop'];


//////////////////////////////////////////////////////////////////////////
//
//  JAVASCRIPT PROCESSING CODE FOR DATA FLITS
//
//////////////////////////////////////////////////////////////////////////
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

for( let i=0; i < obj.nCHIs; i++) {
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.wData > max_dat_data) {
        max_dat_data = obj.ChiaiuInfo[i].interfaces.chiInt.params.wData;
        max_dat_be = max_dat_data/8;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.useDataCheck) {
        max_dat_datacheck = max_dat_data/8;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.enPoison) {
        max_dat_poison = max_dat_data/64;
    }
    if(obj.ChiaiuInfo[i].fnNativeInterface == 'CHI-E') {
        max_dat_txnid = 12;
        max_dat_opcode = 4;
        max_dat_fwdstate = 4;
        max_dat_cbusy = 3;
        max_dat_dbid = 12;
        max_dat_tagop = 2;
        has_atleast_one_chie = 1;
    }
    
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.wAddr > max_req_addr) {
        max_req_addr = obj.ChiaiuInfo[i].interfaces.chiInt.params.wAddr;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.TgtID > max_dat_tgtid) {
        max_dat_tgtid = obj.ChiaiuInfo[i].interfaces.chiInt.params.TgtID;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.SrcID > max_dat_srcid) {
        max_dat_srcid = obj.ChiaiuInfo[i].interfaces.chiInt.params.SrcID;
    }
    if (obj.ChiaiuInfo[i].interfaces.chiInt.params.Homenode_ID > max_dat_homenid) {
        max_dat_homenid = obj.ChiaiuInfo[i].interfaces.chiInt.params.Homenode_ID;
    }
}

if (has_atleast_one_chie) {
    max_dat_tag = max_dat_data/32;
    max_dat_tu = max_dat_data/128;
}

let max_dat_flit = {};

max_dat_flit['qos']         = 3;
max_dat_flit['tgtid']       = max_dat_tgtid + max_dat_flit['qos'];
max_dat_flit['srcid']       = max_dat_srcid + max_dat_flit['tgtid'];
max_dat_flit['txnid']       = max_dat_txnid + max_dat_flit['srcid'];
max_dat_flit['homenid']     = max_dat_homenid + max_dat_flit['txnid'];
max_dat_flit['opcode']      = max_dat_opcode + max_dat_flit['homenid'];
max_dat_flit['resperr']     = max_dat_resperr + max_dat_flit['opcode'];
max_dat_flit['resp']        = max_dat_resp + max_dat_flit['resperr'];
max_dat_flit['fwdstate']    = max_dat_fwdstate + max_dat_flit['resp'];
max_dat_flit['cbusy']       = max_dat_cbusy + max_dat_flit['fwdstate'];
max_dat_flit['dbid']        = max_dat_dbid + max_dat_flit['cbusy'];
max_dat_flit['ccid']        = max_dat_ccid + max_dat_flit['dbid'];
max_dat_flit['dataid']      = max_dat_dataid + max_dat_flit['ccid'];
max_dat_flit['tagop']       = max_dat_tagop + max_dat_flit['dataid'];
max_dat_flit['tag']         = max_dat_tag + max_dat_flit['tagop'];
max_dat_flit['tu']          = max_dat_tu + max_dat_flit['tag'];
max_dat_flit['tracetag']    = max_dat_tracetag + max_dat_flit['tu'];
max_dat_flit['be']          = max_dat_be + max_dat_flit['tracetag'];
max_dat_flit['data']        = max_dat_data + max_dat_flit['be'];
max_dat_flit['datacheck']   = max_dat_datacheck + max_dat_flit['data'];
max_dat_flit['poison']      = max_dat_poison + max_dat_flit['datacheck'];

let dat_flit = {};
dat_flit['qos']        = 3;
dat_flit['tgtid']      = obj.AiuInfo[obj.Id].interfaces.chiInt.params.TgtID + dat_flit['qos'];
dat_flit['srcid']      = obj.AiuInfo[obj.Id].interfaces.chiInt.params.SrcID + dat_flit['tgtid'];
dat_flit['txnid']      = obj.AiuInfo[obj.Id].interfaces.chiInt.params.TxnID + dat_flit['srcid'];
dat_flit['homenid']     = obj.AiuInfo[obj.Id].interfaces.chiInt.params.Homenode_ID + dat_flit['txnid'];
dat_flit['opcode']     = obj.AiuInfo[obj.Id].interfaces.chiInt.params.DAT_Opcode + dat_flit['homenid'];
dat_flit['resperr']   = 2 + dat_flit['opcode'];
dat_flit['resp']     = 3 + dat_flit['resperr'];
dat_flit['fwdstate']       = (obj.AiuInfo[obj.Id].interfaces.chiInt.params.DataSource ? obj.AiuInfo[obj.Id].interfaces.chiInt.params.DataSource : obj.AiuInfo[obj.Id].interfaces.chiInt.params.FwdState) + dat_flit['resp'];
dat_flit['cbusy']       = (obj.AiuInfo[obj.Id].interfaces.chiInt.params.CBusy? obj.AiuInfo[obj.Id].interfaces.chiInt.params.CBusy : 0) + dat_flit['fwdstate'];
dat_flit['dbid']         = obj.AiuInfo[obj.Id].interfaces.chiInt.params.DBID + dat_flit['cbusy'];
dat_flit['ccid'] = 2 + dat_flit['dbid'];
dat_flit['dataid'] = 2 + dat_flit['ccid'];
if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){
    dat_flit['tagop'] = obj.AiuInfo[obj.Id].interfaces.chiInt.params.TagOp + dat_flit['dataid'];
    dat_flit['tag']   = (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData/32) + dat_flit['tagop'];
    dat_flit['tu']    = (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData/128) + dat_flit['tag'];
} else {
    dat_flit['tagop'] = dat_flit['dataid'];
    dat_flit['tag']   = dat_flit['tagop'];
    dat_flit['tu']    = dat_flit['tag'];
}

dat_flit['tracetag']    = 1 + dat_flit['tu'];
dat_flit['be']       = (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData/8) + dat_flit['tracetag'];
dat_flit['data']       = (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData) + dat_flit['be'];

if (obj.AiuInfo[obj.Id].interfaces.chiInt.params.useDataCheck) {
    dat_flit['datacheck'] = (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData/8) + dat_flit['data'];
} else {
    dat_flit['datacheck'] = dat_flit['data'];
}
if (obj.AiuInfo[obj.Id].interfaces.chiInt.params.enPoison) {
    dat_flit['poison'] =  (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData/64) + dat_flit['datacheck'];
} else {
    dat_flit['poison'] = dat_flit['datacheck'];
}

//////////////////////////////////////////////////////////////////////////
//
//  JAVASCRIPT PROCESSING CODE FOR DATA FLITS
//
//////////////////////////////////////////////////////////////////////////
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


for( let i=0; i < obj.nCHIs; i++) {
    if(obj.ChiaiuInfo[i].fnNativeInterface == 'CHI-E') {
        max_snp_txnid = 12;
        max_snp_fwdtxnid = 12;
    }
    
    if ((obj.ChiaiuInfo[i].interfaces.chiInt.params.wAddr-3) > max_snp_addr) {
        max_snp_addr = (obj.ChiaiuInfo[i].interfaces.chiInt.params.wAddr-3);
    }
    if ((obj.ChiaiuInfo[i].interfaces.chiInt.params.SrcID) > max_snp_srcid) {
        max_snp_srcid = (obj.ChiaiuInfo[i].interfaces.chiInt.params.SrcID);
    }
    if ((obj.ChiaiuInfo[i].interfaces.chiInt.params.FwdNID) > max_snp_fwdnid) {
        max_snp_fwdnid = (obj.ChiaiuInfo[i].interfaces.chiInt.params.FwdNID);
    }
}

let max_snp_flit = {};

max_snp_flit['qos']         = 3;
max_snp_flit['srcid']       = max_snp_srcid + max_snp_flit['qos'];
max_snp_flit['txnid']       = max_snp_txnid + max_snp_flit['srcid'];
max_snp_flit['fwdnid']      = max_snp_fwdnid + max_snp_flit['txnid'];
max_snp_flit['fwdtxnid']    = max_snp_fwdtxnid + max_snp_flit['fwdnid'];
max_snp_flit['opcode']      = max_snp_opcode + max_snp_flit['fwdtxnid'];
max_snp_flit['addr']        = max_snp_addr + max_snp_flit['opcode'];
max_snp_flit['ns']          = max_snp_ns + max_snp_flit['addr'];
max_snp_flit['dontgotosd']  = max_snp_dontgotosd + max_snp_flit['ns'];
max_snp_flit['rettosrc']    = max_snp_rettosrc + max_snp_flit['dontgotosd'];
max_snp_flit['tracetag']    = max_snp_tracetag + max_snp_flit['rettosrc'];

let snp_flit = {};

snp_flit['qos'] = 3;
snp_flit['srcid'] = obj.AiuInfo[obj.Id].interfaces.chiInt.params.TgtID + snp_flit['qos'];
snp_flit['txnid'] = obj.AiuInfo[obj.Id].interfaces.chiInt.params.TxnID + snp_flit['srcid'];
snp_flit['fwdnid'] = obj.AiuInfo[obj.Id].interfaces.chiInt.params.FwdNID + snp_flit['txnid'];
snp_flit['fwdtxnid'] = obj.AiuInfo[obj.Id].interfaces.chiInt.params.TxnID + snp_flit['fwdnid'];
snp_flit['opcode'] = 5 + snp_flit['fwdtxnid'];
snp_flit['addr'] = (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wAddr-3) + snp_flit['opcode'];
snp_flit['ns'] = 1 + snp_flit['addr'];
snp_flit['dontgotosd'] = 1 + snp_flit['ns'];
snp_flit['rettosrc'] = 1 + snp_flit['dontgotosd'];
snp_flit['tracetag'] = 1 + snp_flit['rettosrc'];

%>


module <%=obj.BlockId%>_connection_wrapper (<%=obj.BlockId%>_chi_if inhouse_chi_if, svt_chi_rn_if svt_chi_if);

bit en_chiaiu_coherency_via_reg;  
bit sysco_attached_via_reg;
uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
static uvm_event ev_all_aiu_sysco_attached= ev_pool.get("ev_all_aiu_sysco_attached");

initial begin
    if (!$value$plusargs("en_chiaiu_coherency_via_reg=%0d",en_chiaiu_coherency_via_reg)) begin
        en_chiaiu_coherency_via_reg= 0; 
    end  
    ev_all_aiu_sysco_attached.wait_trigger();
    sysco_attached_via_reg = 1;
end

    // Sysco connections
    assign inhouse_chi_if.sysco_req = (en_chiaiu_coherency_via_reg==0)?svt_chi_if.SYSCOREQ:1'b0 ;
    assign svt_chi_if.SYSCOACK = (en_chiaiu_coherency_via_reg==0)?inhouse_chi_if.sysco_ack:(sysco_attached_via_reg && svt_chi_if.SYSCOREQ);

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
    assign inhouse_chi_if.tx_req_flit[<%=req_flit['qos']%> : 0] = svt_chi_if.TXREQFLIT[<%=max_req_flit['qos']%> : 0];

    <%
    let keys = Object.keys(req_flit);
    let max_keys = Object.keys(max_req_flit);
    let diff = 0;
    %>
    <%for (let i = 1; i < keys.length; i++) {%>
        <%if(req_flit[keys[i]] != req_flit[keys[i-1]]){%>
            assign inhouse_chi_if.tx_req_flit[<%=req_flit[keys[i]]%>:<%=(req_flit[keys[i-1]]+1)%>] = svt_chi_if.TXREQFLIT[<%=max_req_flit[max_keys[i]]%>:<%=(max_req_flit[max_keys[i-1]]+1)%>];
        <%}%>
    <%}%>

    //-----------------------------------------------------------------------
    // RX Response Virtual Channel
    //-----------------------------------------------------------------------
    assign svt_chi_if.RXRSPFLITPEND = inhouse_chi_if.rx_rsp_flit_pend  ;
    assign svt_chi_if.RXRSPFLITV    = inhouse_chi_if.rx_rsp_flitv      ;
    assign inhouse_chi_if.rx_rsp_lcrdv = svt_chi_if.RXRSPLCRDV         ;
    assign svt_chi_if.RXRSPFLIT[<%=max_rsp_flit['qos']%> : 0] = inhouse_chi_if.rx_rsp_flit[<%=rsp_flit['qos']%> : 0];
    <%
    keys = Object.keys(rsp_flit);
    max_keys = Object.keys(max_rsp_flit);
    %>
    <%for (let i = 1; i < keys.length; i++) {%>
        <%if(rsp_flit[keys[i]] != rsp_flit[keys[i-1]]){%>
            <%
            diff = max_rsp_flit[max_keys[i]] - max_rsp_flit[max_keys[i-1]] - (rsp_flit[keys[i]] - rsp_flit[keys[i-1]]);
            %>
            <%if(diff>0){%>
                assign svt_chi_if.RXRSPFLIT[<%=max_rsp_flit[max_keys[i]]%>:<%=(max_rsp_flit[max_keys[i]]-diff+1)%>] = 'd0;
                assign svt_chi_if.RXRSPFLIT[<%=max_rsp_flit[max_keys[i]]-diff%>:<%=(max_rsp_flit[max_keys[i-1]]+1)%>] = inhouse_chi_if.rx_rsp_flit[<%=rsp_flit[keys[i]]%>:<%=(rsp_flit[keys[i-1]])+1%>];
            <%}else{%>
                assign svt_chi_if.RXRSPFLIT[<%=max_rsp_flit[max_keys[i]]%>:<%=(max_rsp_flit[max_keys[i-1]]+1)%>] = inhouse_chi_if.rx_rsp_flit[<%=rsp_flit[keys[i]]%>:<%=(rsp_flit[keys[i-1]])+1%>];
            <%}%>
        <%}else if (max_rsp_flit[keys[i]] != max_rsp_flit[keys[i-1]]){%>
            assign svt_chi_if.RXRSPFLIT[<%=max_rsp_flit[max_keys[i]]%>:<%=(max_rsp_flit[max_keys[i-1]]+1)%>] = 'd0;
        <%}%>
    <%}%>

    //-----------------------------------------------------------------------
    // RX Dat Virtual Channel
    //-----------------------------------------------------------------------
    assign svt_chi_if.RXDATFLITPEND = inhouse_chi_if.rx_dat_flit_pend  ;
    assign svt_chi_if.RXDATFLITV    = inhouse_chi_if.rx_dat_flitv      ; 
    assign inhouse_chi_if.rx_dat_lcrdv = svt_chi_if.RXDATLCRDV         ; 
    assign svt_chi_if.RXDATFLIT[<%=max_dat_flit['qos']%> : 0] = inhouse_chi_if.rx_dat_flit[<%=dat_flit['qos']%> : 0];

    <%
    keys = Object.keys(dat_flit);
    max_keys = Object.keys(max_dat_flit);
    %>
    <%for (let i = 1; i < keys.length; i++) {%>
        <%if(dat_flit[keys[i]] != dat_flit[keys[i-1]]){%>
            <%
            diff = max_dat_flit[max_keys[i]] - max_dat_flit[max_keys[i-1]] - (dat_flit[keys[i]] - dat_flit[keys[i-1]]);
            %>
            <%if(diff>0) {%>
                assign svt_chi_if.RXDATFLIT[<%=max_dat_flit[max_keys[i]]%>:<%=(max_dat_flit[max_keys[i]]-diff+1)%>] = 'd0;
                assign svt_chi_if.RXDATFLIT[<%=max_dat_flit[max_keys[i]]-diff%>:<%=(max_dat_flit[max_keys[i-1]]+1)%>] = inhouse_chi_if.rx_dat_flit[<%=dat_flit[keys[i]]%>:<%=(dat_flit[keys[i-1]])+1%>];
            <%}else{%>
                assign svt_chi_if.RXDATFLIT[<%=max_dat_flit[max_keys[i]]%>:<%=(max_dat_flit[max_keys[i-1]]+1)%>] = inhouse_chi_if.rx_dat_flit[<%=dat_flit[keys[i]]%>:<%=(dat_flit[keys[i-1]]+1)%>];
            <%}%>
        <%}else if(max_dat_flit[keys[i]] != max_dat_flit[keys[i-1]]){%>
            assign svt_chi_if.RXDATFLIT[<%=max_dat_flit[max_keys[i]]%>:<%=(max_dat_flit[max_keys[i-1]]+1)%>] = 'd0;
        <%}%>
    <%}%>

    //-----------------------------------------------------------------------
    // RX Snoop Virtual Channel
    //-----------------------------------------------------------------------
    assign svt_chi_if.RXSNPFLITPEND = inhouse_chi_if.rx_snp_flit_pend  ;
    assign svt_chi_if.RXSNPFLITV    = inhouse_chi_if.rx_snp_flitv      ;     
    assign inhouse_chi_if.rx_snp_lcrdv = svt_chi_if.RXSNPLCRDV    ;     
    assign svt_chi_if.RXSNPFLIT[<%=max_snp_flit['qos']%> : 0] = inhouse_chi_if.rx_snp_flit[<%=snp_flit['qos']%> : 0];

    <%
    keys = Object.keys(snp_flit);
    max_keys = Object.keys(max_snp_flit);
    %>
    <%for (let i = 1; i < keys.length; i++) {%>
        <%if(snp_flit[keys[i]] != snp_flit[keys[i-1]]){%>
            <%
            diff = max_snp_flit[max_keys[i]] - max_snp_flit[max_keys[i-1]] - (snp_flit[keys[i]] - snp_flit[keys[i-1]]);
            %>
            <%if(diff>0) {%>
                assign svt_chi_if.RXSNPFLIT[<%=max_snp_flit[max_keys[i]]%>:<%=(max_snp_flit[max_keys[i]]-diff+1)%>] = 'd0;
                assign svt_chi_if.RXSNPFLIT[<%=max_snp_flit[max_keys[i]]-diff%>:<%=(max_snp_flit[max_keys[i-1]]+1)%>] = inhouse_chi_if.rx_snp_flit[<%=snp_flit[keys[i]]%>:<%=(snp_flit[keys[i-1]])+1%>];
            <%}else{%>
                assign svt_chi_if.RXSNPFLIT[<%=max_snp_flit[max_keys[i]]%>:<%=(max_snp_flit[max_keys[i-1]]+1)%>] = inhouse_chi_if.rx_snp_flit[<%=snp_flit[keys[i]]%>:<%=(snp_flit[keys[i-1]]+1)%>];
            <%}%>
        <%}else if(max_snp_flit[keys[i]] != max_snp_flit[keys[i-1]]){%>
            assign svt_chi_if.RXSNPFLIT[<%=max_snp_flit[max_keys[i]]%>:<%=(max_snp_flit[max_keys[i-1]]+1)%>] = 'd0;
        <%}%>
    <%}%>  

    //-----------------------------------------------------------------------
    // TX Response Virtual Channel
    //-----------------------------------------------------------------------
    assign inhouse_chi_if.tx_rsp_flit_pend = svt_chi_if.TXRSPFLITPEND  ; 
    assign inhouse_chi_if.tx_rsp_flitv = svt_chi_if.TXRSPFLITV     ;
    assign svt_chi_if.TXRSPLCRDV  = inhouse_chi_if.tx_rsp_lcrdv   ;

    assign inhouse_chi_if.tx_rsp_flit[<%=rsp_flit['qos']%> : 0] = svt_chi_if.TXRSPFLIT[<%=max_rsp_flit['qos']%> : 0];
    <%
    keys = Object.keys(rsp_flit);
    max_keys = Object.keys(max_rsp_flit);
    %>
    <%for (let i = 1; i < keys.length; i++) {%>
        <%if(rsp_flit[keys[i]] != rsp_flit[keys[i-1]]){%>
            assign inhouse_chi_if.tx_rsp_flit[<%=rsp_flit[keys[i]]%>:<%=(rsp_flit[keys[i-1]]+1)%>] = svt_chi_if.TXRSPFLIT[<%=max_rsp_flit[max_keys[i]]%>:<%=(max_rsp_flit[max_keys[i-1]]+1)%>];
        <%}%>
    <%}%>

    //-----------------------------------------------------------------------
    // TX Dat Virtual Channel
    //-----------------------------------------------------------------------
    assign inhouse_chi_if.tx_dat_flit_pend = svt_chi_if.TXDATFLITPEND ;  
    assign inhouse_chi_if.tx_dat_flitv = svt_chi_if.TXDATFLITV    ;
    assign svt_chi_if.TXDATLCRDV  = inhouse_chi_if.tx_dat_lcrdv  ;
    assign inhouse_chi_if.tx_dat_flit[<%=dat_flit['qos']%> : 0] = svt_chi_if.TXDATFLIT[<%=max_dat_flit['qos']%> : 0];

    <%
    keys = Object.keys(dat_flit);
    max_keys = Object.keys(max_dat_flit);
    %>
    <%for (let i = 1; i < keys.length; i++) {%>
        <%if(dat_flit[keys[i]] != dat_flit[keys[i-1]]){%>
            assign inhouse_chi_if.tx_dat_flit[<%=dat_flit[keys[i]]%>:<%=(dat_flit[keys[i-1]]+1)%>] = svt_chi_if.TXDATFLIT[<%=max_dat_flit[max_keys[i]]%>:<%=(max_dat_flit[max_keys[i-1]]+1)%>];
        <%}%>
    <%}%>

endmodule
