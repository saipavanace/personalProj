//typedef class dce_scoreboard;

class dce_virtual_seq extends dce_virtual_base_seq;

  `uvm_object_utils(dce_virtual_seq);
  addrMgrConst::addrq user_addr_q;

  //Methods
  extern function new(string name = "dce_virtual_seq");
  extern task body();

endclass: dce_virtual_seq

function dce_virtual_seq::new(string name = "dce_virtual_seq");
  super.new(name);
endfunction: new

task dce_virtual_seq::body();
  m_mst_seq      = dce_default_mst_seq::type_id::create("aius_mst_seq");
  m_slv_seq4aius = dce_slv_base_seq::type_id::create("aius_slv_seq");
  m_slv_seq4dmis = dce_slv_base_seq::type_id::create("dmis_slv_seq");
  
  m_mst_seq.get_handles(m_phase, m_dce_cntr, m_unit_args);
  
  //TX --> CMDREQ-UPDREQ || RX --> CMDRSP-UPDRSP
  m_mst_seq.get_seqrs(m_smi_sqr_tx_hash["cmd_req_"], m_smi_sqr_rx_hash["cmd_rsp_"]);
  m_mst_seq.e_single_step = e_single_step;
  m_mst_seq.m_scb         = m_scb; 
  m_mst_seq.user_addrq    = user_addr_q;
  
  m_slv_seq4aius.get_handles(m_phase, m_dce_cntr, m_unit_args);

  //TX --> SNPRSP-STRRSP || RX --> SNPREQ-STRREQ
  m_slv_seq4aius.get_seqrs(m_smi_sqr_tx_hash["snp_rsp_"], m_smi_sqr_rx_hash["snp_req_"]);
  m_slv_seq4aius.m_scb         = m_scb; 
  
  m_slv_seq4dmis.get_handles(m_phase, m_dce_cntr, m_unit_args);

  //TX --> RBUREQ-MRDRSP-RBRSP || RX --> RBURSP-MRDREQ-RBIDREQ
  m_slv_seq4dmis.get_seqrs(m_smi_sqr_tx_hash["mrd_rsp_"], m_smi_sqr_rx_hash["mrd_req_"]);
  m_slv_seq4dmis.m_scb = m_scb; 

  fork
    m_mst_seq.start(null);
    m_slv_seq4aius.start(null);
    m_slv_seq4dmis.start(null);
  join

endtask: body

