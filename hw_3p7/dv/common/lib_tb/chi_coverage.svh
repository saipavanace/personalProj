////////////////////////////////////////////////////////////////////////
//
//
//CHI coverage
//
////////////////////////////////////////////////////////////////////////

//chi request class
`uvm_analysis_imp_decl(_chi_req)

class chi_req_cov extends uvm_component;

`uvm_component_utils(chi_req_cov)

uvm_analysis_imp_chi_req #(chi_req_seq_item, chi_req_cov) an_chi_req;

chi_req_seq_item  m_chi_req_item;

function void write_chi_req     ( chi_req_seq_item m_pkt  ) ;
endfunction


function new(string name = "chi_req_cov", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  an_chi_req = new ("an_chi_req", this);
endfunction : build_phase

covergroup chi_req_qos;
        coverpoint m_chi_req_item.qos;
endgroup

covergroup chi_req_srcid;
        coverpoint m_chi_req_item.srcid;
endgroup

covergroup chi_req_tgtid;
        coverpoint m_chi_req_item.tgtid;
endgroup

covergroup chi_req_txnid;
        coverpoint m_chi_req_item.txnid;
endgroup

covergroup chi_req_returnnid;
        coverpoint m_chi_req_item.returnnid;
endgroup

covergroup chi_req_returntxnid;
        coverpoint m_chi_req_item.returntxnid;
endgroup

covergroup chi_req_stashnid;
        coverpoint m_chi_req_item.stashnid;
endgroup

covergroup chi_req_stashnidvalid;
        coverpoint m_chi_req_item.stashnidvalid;
endgroup

covergroup chi_req_endian;
        coverpoint m_chi_req_item.endian;
endgroup

covergroup chi_req_stashlpid;
        coverpoint m_chi_req_item.stashlpid;
endgroup

covergroup chi_req_stashlpidvalid;
        coverpoint m_chi_req_item.stashlpidvalid;
endgroup

covergroup chi_req_opcode;
        coverpoint m_chi_req_item.opcode;
endgroup

covergroup chi_req_size;
        coverpoint m_chi_req_item.size;
endgroup

covergroup chi_req_addr;
        coverpoint m_chi_req_item.addr;
endgroup

covergroup chi_req_ns;
        coverpoint m_chi_req_item.ns;
endgroup

covergroup chi_req_likelyshared;
        coverpoint m_chi_req_item.likelyshared;
endgroup

covergroup chi_req_allowretry;
        coverpoint m_chi_req_item.allowretry;
endgroup

covergroup chi_req_order;
        coverpoint m_chi_req_item.order;
endgroup

covergroup chi_req_pcrdtype;
        coverpoint m_chi_req_item.pcrdtype;
endgroup

covergroup chi_req_memattr;
        coverpoint m_chi_req_item.memattr;
endgroup

covergroup chi_req_snpattr;
        coverpoint m_chi_req_item.snpattr;
endgroup

covergroup chi_req_lpid;
        coverpoint m_chi_req_item.lpid;
endgroup

covergroup chi_req_expcompack;
	coverpoint m_chi_req_item.expcompack;
endgroup

covergroup chi_req_excl;
        coverpoint m_chi_req_item.excl;
endgroup

covergroup chi_req_tracetag;
        coverpoint m_chi_req_item.tracetag;
endgroup

covergroup chi_req_rsvdc;
	coverpoint m_chi_req_item.rsvdc;
endgroup

endclass: chi_req_cov

//chi response class
`uvm_analysis_imp_decl(_chi_rsp)

class chi_rsp_cov extends uvm_component;

`uvm_component_utils(chi_rsp_cov)

uvm_analysis_imp_chi_rsp #(chi_rsp_seq_item, chi_rsp_cov) an_chi_rsp;

chi_rsp_seq_item  m_chi_rsp_item;

function void write_chi_rsp     ( chi_rsp_seq_item m_pkt  ) ;
endfunction


function new(string name = "chi_rsp_cov", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  an_chi_rsp = new ("an_chi_rsp", this);
endfunction : build_phase

covergroup chi_rsp_qos;
        coverpoint m_chi_rsp_item.qos;
endgroup

covergroup chi_rsp_srcid;
        coverpoint m_chi_rsp_item.srcid;
endgroup

covergroup chi_rsp_tgtid;
        coverpoint m_chi_rsp_item.tgtid;
endgroup

covergroup chi_rsp_txnid;
        coverpoint m_chi_rsp_item.txnid;
endgroup

covergroup chi_rsp_opcode;
        coverpoint m_chi_rsp_item.opcode;
endgroup

covergroup chi_rsp_resperr;
        coverpoint m_chi_rsp_item.resperr;
endgroup

covergroup chi_rsp_resp;
        coverpoint m_chi_rsp_item.resp;
endgroup

covergroup chi_rsp_fwdstate;
        coverpoint m_chi_rsp_item.fwdstate;
endgroup

covergroup chi_rsp_datapull;
        coverpoint m_chi_rsp_item.datapull;
endgroup

covergroup chi_rsp_dbid;
        coverpoint m_chi_rsp_item.dbid;
endgroup

covergroup chi_rsp_pcrdtype;
        coverpoint m_chi_rsp_item.pcrdtype;
endgroup

covergroup chi_rsp_tracetag;
        coverpoint m_chi_rsp_item.tracetag;
endgroup

endclass: chi_rsp_cov

//chi snoop class
`uvm_analysis_imp_decl(_chi_snp)

class chi_snp_cov extends uvm_component;

`uvm_component_utils(chi_snp_cov)

uvm_analysis_imp_chi_snp #(chi_snp_seq_item, chi_snp_cov) an_chi_snp;

chi_snp_seq_item  m_chi_snp_item;

function void write_chi_snp     ( chi_snp_seq_item m_pkt  ) ;
endfunction


function new(string name = "chi_snp_cov", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  an_chi_snp = new ("an_chi_snp", this);
endfunction : build_phase

covergroup chi_snp_qos;
        coverpoint m_chi_snp_item.qos;
endgroup

covergroup chi_snp_srcid;
        coverpoint m_chi_snp_item.srcid;
endgroup

covergroup chi_snp_tgtid;
        coverpoint m_chi_snp_item.tgtid;
endgroup

covergroup chi_snp_txnid;
        coverpoint m_chi_snp_item.txnid;
endgroup

covergroup chi_snp_fwdnid;
        coverpoint m_chi_snp_item.fwdnid;
endgroup

covergroup chi_snp_fwdtxnid;
        coverpoint m_chi_snp_item.fwdtxnid;
endgroup

covergroup chi_snp_stashpid;
        coverpoint m_chi_snp_item.stashlpid;
endgroup

covergroup chi_snp_stashlpidvalid;
        coverpoint m_chi_snp_item.stashlpidvalid;
endgroup

covergroup chi_snp_vmidext;
        coverpoint m_chi_snp_item.vmidext;
endgroup

covergroup chi_snp_opcode;
        coverpoint m_chi_snp_item.opcode;
endgroup

covergroup chi_snp_addr;
        coverpoint m_chi_snp_item.addr;
endgroup

covergroup chi_snp_ns;
        coverpoint m_chi_snp_item.ns;
endgroup

covergroup chi_snp_donotgotosd;
        coverpoint m_chi_snp_item.donotgotosd;
endgroup

covergroup chi_snp_donotdatapull;
        coverpoint m_chi_snp_item.donotdatapull;
endgroup

covergroup chi_snp_rettosrc;
        coverpoint m_chi_snp_item.rettosrc;
endgroup

covergroup chi_snp_tracetag;
        coverpoint m_chi_snp_item.tracetag;
endgroup

endclass: chi_snp_cov

//chi data class
`uvm_analysis_imp_decl(_chi_dat)

class chi_dat_cov extends uvm_component;

`uvm_component_utils(chi_dat_cov)

uvm_analysis_imp_chi_dat #(chi_dat_seq_item, chi_dat_cov) an_chi_dat;

chi_dat_seq_item  m_chi_dat_item;

function void write_chi_dat     ( chi_dat_seq_item m_pkt  ) ;
endfunction

function new(string name = "chi_dat_cov", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  an_chi_dat = new ("an_chi_dat", this);
endfunction : build_phase

covergroup chi_dat_qos;
        coverpoint m_chi_dat_item.qos;
endgroup

covergroup chi_dat_srcid;
        coverpoint m_chi_dat_item.srcid;
endgroup

covergroup chi_dat_tgtid;
        coverpoint m_chi_dat_item.tgtid;
endgroup

covergroup chi_dat_txnid;
        coverpoint m_chi_dat_item.txnid;
endgroup

covergroup chi_dat_opcode;
        coverpoint m_chi_dat_item.opcode;
endgroup

covergroup chi_dat_tracetag;
        coverpoint m_chi_dat_item.tracetag;
endgroup

covergroup chi_dat_homenid;
        coverpoint m_chi_dat_item.homenid;
endgroup

covergroup chi_dat_resp;
        coverpoint m_chi_dat_item.resp;
endgroup

//covergroup chi_dat_resperr;
//      coverpoint m_chi_dat_item.resperr;
//endgroup

covergroup chi_dat_fwdstate;
        coverpoint m_chi_dat_item.fwdstate;
endgroup

covergroup chi_dat_datapull;
        coverpoint m_chi_dat_item.datapull;
endgroup

covergroup chi_dat_datasource;
        coverpoint m_chi_dat_item.datasource;
endgroup

covergroup chi_dat_dbid;
        coverpoint m_chi_dat_item.dbid;
endgroup

covergroup chi_dat_ccid;
        coverpoint m_chi_dat_item.ccid;
endgroup

//covergroup chi_dat_dataid;
//        coverpoint m_chi_dat_item.dataid;
//endgroup

covergroup chi_dat_rsvdc;
        coverpoint m_chi_dat_item.rsvdc;
endgroup

//covergroup chi_dat_be;
//        coverpoint m_chi_dat_item.be;
//endgroup

//covergroup chi_dat_datacheck;
//        coverpoint m_chi_dat_item.datacheck;
//endgroup

//covergroup chi_dat_data;
//      coverpoint m_chi_dat_item.data;
//endgroup

covergroup chi_dat_poison;
        coverpoint m_chi_dat_item.poison;
endgroup

endclass: chi_dat_cov

`uvm_analysis_imp_decl(_chi_credit)
class chi_credit_chnl extends uvm_component;

`uvm_component_utils(chi_credit_chnl)

uvm_analysis_imp_chi_credit #(chi_credit_txn, chi_credit_chnl) an_chi_credit;
  
chi_credit_txn m_chi_credit_txn;

function void write_chi_credit     ( chi_credit_txn m_pkt  ) ;
endfunction


function new(string name = "chi_credit_chnl", uvm_component parent = null);
   super.new(name, parent);
endfunction : new

function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   an_chi_credit = new ("an_chi_credit", this);
endfunction : build_phase

covergroup chi_txn_credits;
	coverpoint m_chi_credit_txn.num_credits;
endgroup

endclass: chi_credit_chnl



// chi_coverage class
class chi_coverage extends uvm_component;

`uvm_component_utils(chi_coverage)
//uvm_analysis_imp_chi #(chi_req_seq_item, chi_coverage) analysis_chi_req;
//uvm_analysis_imp_chi #(chi_rsp_seq_item, chi_coverage) analysis_chi_rsp;
//uvm_analysis_imp_chi #(chi_snp_seq_item, chi_coverage) analysis_chi_snp;
//uvm_analysis_imp_chi #(chi_dat_seq_item, chi_coverage) analysis_chi_dat;

chi_req_cov m_txreq_cov;
chi_rsp_cov m_txrsp_cov;
chi_rsp_cov m_rxrsp_cov;
chi_snp_cov m_rxsnp_cov;
chi_dat_cov m_txdat_cov;
chi_dat_cov m_rxdat_cov;

function new(string name = "chi_coverage", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        m_txreq_cov = chi_req_cov::type_id::create("m_txreq_cov", this);
	m_rxrsp_cov = chi_rsp_cov::type_id::create("m_rxrsp_cov", this);
	m_txrsp_cov = chi_rsp_cov::type_id::create("m_txrsp_cov", this);
	m_rxsnp_cov = chi_snp_cov::type_id::create("m_rxsnp_cov", this);
	m_txdat_cov = chi_dat_cov::type_id::create("m_txdat_cov", this);
	m_rxdat_cov = chi_dat_cov::type_id::create("m_rxdat_cov", this);

        //analysis_chi_req = new ("analysis_chi_req", this);
	//analysis_chi_rsp = new ("analysis_chi_rsp", this);
	//analysis_chi_snp = new ("analysis_chi_snp", this);
	//analysis_chi_dat = new ("analysis_chi_dat", this);

endfunction : build_phase



endclass: chi_coverage
