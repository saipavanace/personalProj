
import uvm_pkg::*;
`include "uvm_macros.svh"

class chi_scoreboard extends uvm_scoreboard;
    `uvm_component_param_utils(chi_scoreboard)

    `uvm_analysis_imp_decl ( _smi_port         )
    `uvm_analysis_imp_decl ( _chi_req_port     )
    `uvm_analysis_imp_decl ( _chi_wdata_port   )
    `uvm_analysis_imp_decl ( _chi_srsp_port    )
    `uvm_analysis_imp_decl ( _chi_crsp_port    )
    `uvm_analysis_imp_decl ( _chi_rdata_port   )
    `uvm_analysis_imp_decl ( _chi_snpaddr_port )


    //CHI Ports
    uvm_analysis_imp_chi_req_port     #(chi_req_seq_item, chi_scoreboard) chi_req_port;
    uvm_analysis_imp_chi_wdata_port   #(chi_dat_seq_item, chi_scoreboard) chi_wdata_port;
    uvm_analysis_imp_chi_srsp_port    #(chi_rsp_seq_item, chi_scoreboard) chi_srsp_port;
    uvm_analysis_imp_chi_crsp_port    #(chi_rsp_seq_item, chi_scoreboard) chi_crsp_port;
    uvm_analysis_imp_chi_rdata_port   #(chi_dat_seq_item, chi_scoreboard) chi_rdata_port;
    uvm_analysis_imp_chi_snpaddr_port #(chi_snp_seq_item, chi_scoreboard) chi_snpaddr_port;

    //SMI Port
    uvm_analysis_imp_smi_port #(smi_seq_item, chi_scoreboard) smi_port;

    chi_txn_memory txn_mem;
    chi_predictor m_predictor;
    chi_comparator m_comparator;

    function new (string name="chi_scoreboard", uvm_component parent=null);
        super.new (name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        txn_mem = chi_txn_memory::get_instance();
        m_predictor = chi_predictor::type_id::create("m_predictor", this);
        m_comparator = chi_comparator::type_id::create("m_comparator", this);

        chi_req_port    = new("chi_req_port", this);
        chi_wdata_port  = new("chi_wdata_port", this);
        chi_srsp_port   = new("chi_srsp_port", this);
        chi_crsp_port   = new("chi_crsp_port", this);
        chi_rdata_port  = new("chi_rdata_port", this);
        chi_snpaddr_port= new("chi_snpaddr_port", this);
        smi_port        = new("smi_port", this);
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase

    function void write_chi_req_port(const ref chi_req_seq_item m_pkt);
        m_predictor.chi_req_port.write(m_pkt);
        m_comparator.chi_req_port.write(m_pkt);
    endfunction: write_chi_req_port

    function void write_chi_wdata_port( const ref chi_dat_seq_item m_pkt) ;
        m_predictor.chi_wdata_port.write(m_pkt);
        m_comparator.chi_wdata_port.write(m_pkt);
    endfunction: write_chi_wdata_port

    function void write_chi_srsp_port(const ref chi_rsp_seq_item m_pkt) ;
        m_predictor.chi_srsp_port.write(m_pkt);
        m_comparator.chi_srsp_port.write(m_pkt);
    endfunction: write_chi_srsp_port

    function void write_chi_crsp_port    ( const ref chi_rsp_seq_item m_pkt  ) ;
        m_predictor.chi_crsp_port.write(m_pkt);
        m_comparator.chi_crsp_port.write(m_pkt);
    endfunction: write_chi_crsp_port

    function void write_chi_rdata_port   ( const ref chi_dat_seq_item m_pkt ) ;
        m_predictor.chi_rdata_port.write(m_pkt);
        m_comparator.chi_rdata_port.write(m_pkt);
    endfunction: write_chi_rdata_port

    function void write_chi_snpaddr_port ( const ref chi_snp_seq_item m_pkt  ) ;
        m_predictor.chi_snpaddr_port.write(m_pkt);
        m_comparator.chi_snpaddr_port.write(m_pkt);
    endfunction: write_chi_snpaddr_port

    function void write_smi_port ( const ref smi_seq_item m_pkt);
        m_predictor.smi_port.write(m_pkt);
        m_comparator.smi_port.write(m_pkt);
    endfunction: write_smi_port
    
endclass: chi_scoreboard