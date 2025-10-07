//////////////////////////////////////////////////////////////////////////////
//
// CHI Slave Agent
//
//////////////////////////////////////////////////////////////////////////////
class chi_agent extends uvm_component;

<% if(obj.testBench=="emu") { %>
  virtual <%=obj.BlockId%>_chi_emu_if m_chi_emu_vif; <% } %>

  `uvm_component_param_utils(chi_agent)

  //CHI agent configuration object
  chi_agent_cfg m_cfg;
<% if(obj.testBench=="emu") { %>
  chi_emu_drive_collect chi_collect_comp; <% } %>


  ////////////////////////////////////////////////////////////////////////////
  //Analysis ports for requestor node
  //Entire channel specific packet is forwarded
  uvm_analysis_port#( chi_req_seq_item) chi_txreq_pkt_ap;
  uvm_analysis_port#( chi_rsp_seq_item) chi_txrsp_pkt_ap;
  uvm_analysis_port#( chi_dat_seq_item) chi_txdat_pkt_ap;
  uvm_analysis_port#( chi_rsp_seq_item) chi_rxrsp_pkt_ap;
  uvm_analysis_port#( chi_dat_seq_item) chi_rxdat_pkt_ap;
  uvm_analysis_port#( chi_snp_seq_item) chi_rxsnp_pkt_ap;
  //For all channels credit information is forwarded
  uvm_analysis_port#( chi_credit_txn) chi_txreq_crd_ap;
  uvm_analysis_port#( chi_credit_txn) chi_txrsp_crd_ap;
  uvm_analysis_port#( chi_credit_txn) chi_txdat_crd_ap;
  uvm_analysis_port#( chi_credit_txn) chi_rxrsp_crd_ap;
  uvm_analysis_port#( chi_credit_txn) chi_rxdat_crd_ap;
  uvm_analysis_port#( chi_credit_txn) chi_rxsnp_crd_ap;
  //Analysis ports for slave node. Expect for rxreq all
  //other previously defined channels are re-used
  //Entire channel specific packet is forwarded
  uvm_analysis_port#( chi_req_seq_item) chi_rxreq_pkt_ap;
  //For all channels credit information is forwarded
  uvm_analysis_port#( chi_credit_txn) chi_rxreq_crd_ap;
  //Sysco AP port. On change of req/ack, it should sample
  uvm_analysis_port#( chi_base_seq_item) chi_sysco_pkt_ap;

  //Analysis ports for link layer
  //TODO FIXME
  
  ////////////////////////////////////////////////////////////////////////////
   
  ////////////////////////////////////////////////////////////////////////////
  //Requestor node (RN-F, RN-D, RN-I) channel's drivers/monitors/sequencers
  //RN-I will not have SNP channel
  //Driver handles
  chi_actv_chnl_driver#(chi_req_seq_item) m_rn_tx_req_chnl_drv;
  chi_actv_chnl_driver#(chi_dat_seq_item) m_rn_tx_dat_chnl_drv;
  chi_actv_chnl_driver#(chi_rsp_seq_item) m_rn_tx_rsp_chnl_drv;
  chi_pasv_chnl_driver#(chi_rsp_seq_item) m_rn_rx_rsp_chnl_drv;
  chi_pasv_chnl_driver#(chi_dat_seq_item) m_rn_rx_dat_chnl_drv;
  chi_pasv_chnl_driver#(chi_snp_seq_item) m_rn_rx_snp_chnl_drv;

  //Monitor handles
  chi_chnl_monitor#(chi_req_seq_item) m_rn_tx_req_chnl_mon;
  chi_chnl_monitor#(chi_dat_seq_item) m_rn_tx_dat_chnl_mon;
  chi_chnl_monitor#(chi_rsp_seq_item) m_rn_tx_rsp_chnl_mon;
  chi_chnl_monitor#(chi_rsp_seq_item) m_rn_rx_rsp_chnl_mon;
  chi_chnl_monitor#(chi_dat_seq_item) m_rn_rx_dat_chnl_mon;
  chi_chnl_monitor#(chi_snp_seq_item) m_rn_rx_snp_chnl_mon;

  //Sequencer handles
  chi_chnl_sequencer#(chi_req_seq_item) m_rn_tx_req_chnl_seqr;
  chi_chnl_sequencer#(chi_dat_seq_item) m_rn_tx_dat_chnl_seqr;
  chi_chnl_sequencer#(chi_rsp_seq_item) m_rn_tx_rsp_chnl_seqr;
  chi_chnl_sequencer#(chi_rsp_seq_item) m_rn_rx_rsp_chnl_seqr;
  chi_chnl_sequencer#(chi_dat_seq_item) m_rn_rx_dat_chnl_seqr;
  chi_chnl_sequencer#(chi_snp_seq_item) m_rn_rx_snp_chnl_seqr;
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Slave node (SN-F, SN-I) chanee's drivers/monitors/sequencers
  //Driver handles
  chi_pasv_chnl_driver#(chi_req_seq_item) m_sn_rx_req_chnl_drv;
  chi_pasv_chnl_driver#(chi_dat_seq_item) m_sn_rx_dat_chnl_drv;
  chi_actv_chnl_driver#(chi_rsp_seq_item) m_sn_tx_rsp_chnl_drv;
  chi_actv_chnl_driver#(chi_dat_seq_item) m_sn_tx_dat_chnl_drv;

  //Monitor handles
  chi_chnl_monitor#(chi_req_seq_item) m_sn_rx_req_chnl_mon;
  chi_chnl_monitor#(chi_dat_seq_item) m_sn_rx_dat_chnl_mon;
  chi_chnl_monitor#(chi_rsp_seq_item) m_sn_tx_rsp_chnl_mon;
  chi_chnl_monitor#(chi_dat_seq_item) m_sn_tx_dat_chnl_mon;

  //Sequencer handles
  chi_chnl_sequencer#(chi_req_seq_item) m_sn_rx_req_chnl_seqr;
  chi_chnl_sequencer#(chi_dat_seq_item) m_sn_rx_dat_chnl_seqr;
  chi_chnl_sequencer#(chi_rsp_seq_item) m_sn_tx_rsp_chnl_seqr;
  chi_chnl_sequencer#(chi_dat_seq_item) m_sn_tx_dat_chnl_seqr;
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //CHI Link layer and Protocol layer drivers/montiors/sequencers
  //These are common for all channels

  chi_link_req_driver#(chi_lnk_seq_item)  m_lnk_hske_drv;
  chi_txs_actv_driver#(chi_base_seq_item) m_txs_actv_drv;
 
  chi_chnl_monitor#(chi_lnk_seq_item)     m_lnk_hske_mon;
  chi_chnl_monitor#(chi_base_seq_item)    m_txs_actv_mon;

  chi_chnl_sequencer#(chi_lnk_seq_item)   m_lnk_hske_seqr;
  chi_chnl_sequencer#(chi_base_seq_item)  m_txs_actv_seqr;

  //CHI system coherency drivers/montiors/sequencers
  chi_sysco_driver#(chi_base_seq_item)    m_sysco_drv;
  chi_chnl_sequencer#(chi_base_seq_item)  m_sysco_seqr;
  chi_sysco_monitor#(chi_base_seq_item)   m_sysco_mon;

  //CHI Link credit containers
  chi_credit_txn m_lcrdq[$];
  //CHI link status
  chi_link_state m_txlink, m_rxlink;
  chi_num_flits  m_flits;

  //API Methods
  extern function new(string name = "chi_agent", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

  //Helper methods
  extern function void get_rn_interfaces();
  extern function void construct_rn_cmp();
  extern function void configure_rn_cmp();

  extern function void get_sn_interfaces();
  extern function void construct_sn_cmp();
  extern function void configure_sn_cmp();

  extern function void construct_misc_cmp();
  extern function void construct_link_credits();
  extern function void construct_link_state_containter();
  extern function void construct_all_analysis_ports();
endclass: chi_agent

function chi_agent::new(
  string name = "chi_agent",
  uvm_component parent = null);

  super.new(name, parent);
endfunction : new

//Build Phase
function void chi_agent::build_phase(uvm_phase phase);

    super.build_phase(phase);
    if(!uvm_config_db #(chi_agent_cfg)::get(
        this, "", "config_object", m_cfg)) begin

        `uvm_fatal(get_name(), "Unable to get chi agent config object handle")
    end
<% if (obj.testBench == "emu")  { %> 
      chi_collect_comp = chi_emu_drive_collect::type_id::create("chi_collect_comp", this);
      chi_collect_comp.m_cfg = m_cfg;     
<% } %>

    //Construct Link credit containters
    construct_link_credits();
    //Construct Link State containters
    construct_link_state_containter();
    //construct num flits counter
    m_flits = new("m_flits");
    
    //Construct link handshake/protocol layer cmps
    construct_misc_cmp();

    if (m_cfg.is_requestor_node()) begin
      //get virtual interfaces
      get_rn_interfaces();
      //Construct RN drivers, seqrs, monitors
      construct_rn_cmp();
      //configure the rn components
      configure_rn_cmp();

    end else if(m_cfg.is_slave_node()) begin
      //get virtual interface
      get_sn_interfaces();
      //Construct SN drivers, seqrs, monitors
      construct_sn_cmp();
      //configure the rn components
      configure_sn_cmp();
    end

    construct_all_analysis_ports();
endfunction: build_phase

//Connect Phase
function void chi_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

 if (m_cfg.agent_cfg == AGENT_ACTIVE) begin 
  //Non- channel specific connections
    m_lnk_hske_drv.seq_item_port.connect(
      m_lnk_hske_seqr.seq_item_export);
    m_txs_actv_drv.seq_item_port.connect(
      m_txs_actv_seqr.seq_item_export);
    m_sysco_drv.seq_item_port.connect(
      m_sysco_seqr.seq_item_export);
  end
  m_sysco_mon.chi_sysco_ap.connect(chi_sysco_pkt_ap);

  if (m_cfg.is_requestor_node()) begin
    if (m_cfg.agent_cfg == AGENT_ACTIVE) begin
      m_rn_tx_req_chnl_drv.seq_item_port.connect(
        m_rn_tx_req_chnl_seqr.seq_item_export);
      m_rn_tx_dat_chnl_drv.seq_item_port.connect(
        m_rn_tx_dat_chnl_seqr.seq_item_export);
      m_rn_tx_rsp_chnl_drv.seq_item_port.connect(
        m_rn_tx_rsp_chnl_seqr.seq_item_export);
      m_rn_rx_rsp_chnl_drv.seq_item_port.connect(
        m_rn_rx_rsp_chnl_seqr.seq_item_export);
      m_rn_rx_dat_chnl_drv.seq_item_port.connect(
        m_rn_rx_dat_chnl_seqr.seq_item_export);

<% if(obj.testBench=="emu") { %>
      m_rn_tx_req_chnl_drv.tx_req_port.connect(chi_collect_comp.req_export);
      m_rn_tx_dat_chnl_drv.tx_dat_port.connect(chi_collect_comp.dat_export);
      m_rn_tx_rsp_chnl_drv.tx_rsp_port.connect(chi_collect_comp.rsp_export); <% } %>
      if(m_cfg.chi_node_type != RN_I) begin
          m_rn_rx_snp_chnl_drv.seq_item_port.connect(
            m_rn_rx_snp_chnl_seqr.seq_item_export);
      end
    end
    //broadcasting chi channel specific pkts
    m_rn_tx_req_chnl_mon.chi_pkt_ap.connect(chi_txreq_pkt_ap);
    m_rn_tx_rsp_chnl_mon.chi_pkt_ap.connect(chi_txrsp_pkt_ap);
    m_rn_tx_dat_chnl_mon.chi_pkt_ap.connect(chi_txdat_pkt_ap);
    m_rn_rx_rsp_chnl_mon.chi_pkt_ap.connect(chi_rxrsp_pkt_ap);
    m_rn_rx_dat_chnl_mon.chi_pkt_ap.connect(chi_rxdat_pkt_ap);
    if(m_cfg.chi_node_type != RN_I) begin
      m_rn_rx_snp_chnl_mon.chi_pkt_ap.connect(chi_rxsnp_pkt_ap);
    end
    //broadcasting all channels credit information
    m_rn_tx_req_chnl_mon.chi_credit_ap.connect(chi_txreq_crd_ap);
    m_rn_tx_rsp_chnl_mon.chi_credit_ap.connect(chi_txrsp_crd_ap);
    m_rn_tx_dat_chnl_mon.chi_credit_ap.connect(chi_txdat_crd_ap);
    m_rn_rx_rsp_chnl_mon.chi_credit_ap.connect(chi_rxrsp_crd_ap);
    m_rn_rx_dat_chnl_mon.chi_credit_ap.connect(chi_rxdat_crd_ap);
    if(m_cfg.chi_node_type != RN_I) begin
      m_rn_rx_snp_chnl_mon.chi_credit_ap.connect(chi_rxsnp_crd_ap);
    end
  end else if(m_cfg.is_slave_node()) begin
    if(m_cfg.agent_cfg == AGENT_ACTIVE) begin
        m_sn_rx_req_chnl_drv.seq_item_port.connect(
          m_sn_rx_req_chnl_seqr.seq_item_export);
        m_sn_rx_dat_chnl_drv.seq_item_port.connect(
          m_sn_rx_dat_chnl_seqr.seq_item_export);
        m_sn_tx_rsp_chnl_drv.seq_item_port.connect(
          m_sn_tx_rsp_chnl_seqr.seq_item_export);
        m_sn_tx_dat_chnl_drv.seq_item_port.connect(
          m_sn_tx_dat_chnl_seqr.seq_item_export);
    end
    //broadcasting chi channel specific pkts
    m_sn_rx_req_chnl_mon.chi_pkt_ap.connect(chi_rxreq_pkt_ap);
    m_sn_rx_dat_chnl_mon.chi_pkt_ap.connect(chi_rxdat_pkt_ap);
    m_sn_tx_rsp_chnl_mon.chi_pkt_ap.connect(chi_txrsp_pkt_ap);
    m_sn_tx_dat_chnl_mon.chi_pkt_ap.connect(chi_txdat_pkt_ap);
    //broadcasting all channels credit information
    m_sn_rx_req_chnl_mon.chi_credit_ap.connect(chi_rxreq_crd_ap);
    m_sn_rx_dat_chnl_mon.chi_credit_ap.connect(chi_rxdat_crd_ap);
    m_sn_tx_rsp_chnl_mon.chi_credit_ap.connect(chi_txrsp_crd_ap);
    m_sn_tx_dat_chnl_mon.chi_credit_ap.connect(chi_txdat_crd_ap);
  end
endfunction: connect_phase

function void chi_agent::get_rn_interfaces();
 if (m_cfg.chi_node_type == RN_F) begin
   //get virtual interface
   if(!uvm_config_db#(chi_rn_driver_vif)::get(this, 
       "", "chi_rn_driver_vif", m_cfg.m_rn_drv_vif)) begin
       `uvm_fatal(get_name(), "Unable to get virtual interface handle chi_rn_driver_vif")
   end
   if(!uvm_config_db#(chi_rn_monitor_vif)::get(this, 
       "", "chi_rn_monitor_vif", m_cfg.m_rn_mon_vif)) begin
       `uvm_fatal(get_name(), "Unable to get  virtual interface handle chi_rn_monitor_vif")
   end
 end else if(m_cfg.chi_node_type == RN_I) begin
   //get virtual interface
   if(!uvm_config_db#(chi_rni_driver_vif)::get(this, 
       "", "chi_rni_driver_vif", m_cfg.m_rni_drv_vif)) begin
       `uvm_fatal(get_name(), "Unable to get virtual interface handle chi_rni_driver_vif")
   end
   if(!uvm_config_db#(chi_rni_monitor_vif)::get(this, 
       "", "chi_rni_monitor_vif", m_cfg.m_rni_mon_vif)) begin
       `uvm_fatal(get_name(), "Unable to get virtual interface handle chi_rni_monitor_vif")
   end
 end
endfunction: get_rn_interfaces

function void chi_agent::construct_misc_cmp();
 if (m_cfg.agent_cfg == AGENT_ACTIVE) begin 
   m_lnk_hske_drv  = 
    chi_link_req_driver#(chi_lnk_seq_item)::type_id::create(
      "<%=obj.BlockId%>_LinkActvDrv", null);
  end
  m_lnk_hske_mon  = 
    chi_chnl_monitor#(chi_lnk_seq_item)::type_id::create(
      "<%=obj.BlockId%>_LinkActvMon", null);
  m_lnk_hske_seqr = 
    chi_chnl_sequencer#(chi_lnk_seq_item)::type_id::create(
      "<%=obj.BlockId%>_LinkActvSeqr", null);
  
 if (m_cfg.agent_cfg == AGENT_ACTIVE) begin 
    m_txs_actv_drv  = 
    chi_txs_actv_driver#(chi_base_seq_item)::type_id::create(
      "<%=obj.BlockId%>_TxsActvDrv", null);
  end
  m_txs_actv_mon  = 
    chi_chnl_monitor#(chi_base_seq_item)::type_id::create(
      "<%=obj.BlockId%>_TxsActvMon", null);
  m_txs_actv_seqr = 
    chi_chnl_sequencer#(chi_base_seq_item)::type_id::create(
      "<%=obj.BlockId%>_TxsActvSeqr", null);

  //Assign config objects
 if (m_cfg.agent_cfg == AGENT_ACTIVE) begin 
   m_lnk_hske_drv.m_cfg    = m_cfg;
   m_txs_actv_drv.m_cfg    = m_cfg;
 end
  m_lnk_hske_mon.m_cfg    = m_cfg;
  m_txs_actv_mon.m_cfg    = m_cfg;

  //Assign link objects
 if (m_cfg.agent_cfg == AGENT_ACTIVE) begin 
  m_lnk_hske_drv.m_txlink = m_txlink;
  m_lnk_hske_drv.m_rxlink = m_rxlink;
  m_txs_actv_drv.m_lnk    = m_txlink;

  m_lnk_hske_drv.assign_link_params();
  m_txs_actv_drv.assign_link_params();
 end
  m_lnk_hske_mon.assign_link_params();
  m_txs_actv_mon.assign_link_params();

 if (m_cfg.agent_cfg == AGENT_ACTIVE) begin
     m_sysco_drv  =
       chi_sysco_driver#(chi_base_seq_item)::type_id::create(
         "<%=obj.BlockId%>_RnSyscoDrv", this);
     m_sysco_seqr =
       chi_chnl_sequencer#(chi_base_seq_item)::type_id::create(
         "<%=obj.BlockId%>_RnSyscoSeqr", this);

     m_sysco_drv.assign_chnl_params(CHI_ACTIVE,   CHI_REQ);
     m_sysco_drv.assign_link_params();
     m_sysco_drv.m_cfg = m_cfg;
 end
   m_sysco_mon = chi_sysco_monitor#(chi_base_seq_item)::type_id::create(
                              "<%=obj.BlockId%>_RnSyscoMon", this);
   m_sysco_mon.m_cfg = m_cfg;
endfunction: construct_misc_cmp

function void chi_agent::construct_rn_cmp();
 if (m_cfg.agent_cfg == AGENT_ACTIVE) begin 
   //Construct drivers
   m_rn_tx_req_chnl_drv = 
     chi_actv_chnl_driver #(chi_req_seq_item)::type_id::create(
       "<%=obj.BlockId%>_RnTxreqDrv", null);
   m_rn_tx_dat_chnl_drv =
     chi_actv_chnl_driver#(chi_dat_seq_item)::type_id::create(
       "<%=obj.BlockId%>_RnTxDatDrv", null);
   m_rn_tx_rsp_chnl_drv = 
     chi_actv_chnl_driver#(chi_rsp_seq_item)::type_id::create(
       "<%=obj.BlockId%>_RnTxRspDrv", null);
   m_rn_rx_rsp_chnl_drv = 
     chi_pasv_chnl_driver#(chi_rsp_seq_item)::type_id::create(
       "<%=obj.BlockId%>_RnRxRspDrv", null);
   m_rn_rx_dat_chnl_drv = 
      chi_pasv_chnl_driver#(chi_dat_seq_item)::type_id::create(
        "<%=obj.BlockId%>_RnRxDatDrv", null);
   if (m_cfg.snp_chnl_exists()) begin
     m_rn_rx_snp_chnl_drv =
        chi_pasv_chnl_driver#(chi_snp_seq_item)::type_id::create(
          "<%=obj.BlockId%>_RnRxSnpDrv", null);
   end

   //Construct sequencers
   m_rn_tx_req_chnl_seqr = 
     chi_chnl_sequencer#(chi_req_seq_item)::type_id::create(
       "<%=obj.BlockId%>_RnTxreqSeqr", null);
   m_rn_tx_dat_chnl_seqr = 
     chi_chnl_sequencer#(chi_dat_seq_item)::type_id::create(
       "<%=obj.BlockId%>_RnTxDatSeqr", null);
   m_rn_tx_rsp_chnl_seqr = 
     chi_chnl_sequencer#(chi_rsp_seq_item)::type_id::create(
       "<%=obj.BlockId%>_RnTxRspSeqr", null);
   m_rn_rx_rsp_chnl_seqr = 
     chi_chnl_sequencer#(chi_rsp_seq_item)::type_id::create(
       "<%=obj.BlockId%>_RnRxRspseqr", null);
   m_rn_rx_dat_chnl_seqr = 
     chi_chnl_sequencer#(chi_dat_seq_item)::type_id::create(
       "<%=obj.BlockId%>_RnRxDatSeqr", null);
   if(m_cfg.snp_chnl_exists()) begin
      m_rn_rx_snp_chnl_seqr = 
        chi_chnl_sequencer#(chi_snp_seq_item)::type_id::create(
          "<%=obj.BlockId%>_RnRxSnpSeqr", null);
   end
 end

 //Construct monitors
 m_rn_tx_req_chnl_mon = chi_chnl_monitor#(chi_req_seq_item)::type_id::create(
                            "<%=obj.BlockId%>_RnTxreqMon", null);
 m_rn_tx_dat_chnl_mon = chi_chnl_monitor#(chi_dat_seq_item)::type_id::create(
                            "<%=obj.BlockId%>_RnTxDatMon", null);
 m_rn_tx_rsp_chnl_mon = chi_chnl_monitor#(chi_rsp_seq_item)::type_id::create(
                            "<%=obj.BlockId%>_RnTxRspMon", null);
 m_rn_rx_rsp_chnl_mon = chi_chnl_monitor#(chi_rsp_seq_item)::type_id::create(
                            "<%=obj.BlockId%>_RnRxRspMon", null);
 m_rn_rx_dat_chnl_mon = chi_chnl_monitor#(chi_dat_seq_item)::type_id::create(
                            "<%=obj.BlockId%>_RnRxDatMon", null);
 if (m_cfg.snp_chnl_exists()) begin
   m_rn_rx_snp_chnl_mon = chi_chnl_monitor#(chi_snp_seq_item)::type_id::create(
     "<%=obj.BlockId%>_RnRxSnpMon", null);
 end
endfunction: construct_rn_cmp

function void chi_agent::configure_rn_cmp();
  //Assign configuration porperties to drivers/monitors
  if (m_cfg.agent_cfg == AGENT_ACTIVE) begin
    m_rn_tx_req_chnl_drv.assign_chnl_params(CHI_ACTIVE,   CHI_REQ);
    m_rn_tx_dat_chnl_drv.assign_chnl_params(CHI_ACTIVE,   CHI_DAT);
    m_rn_tx_rsp_chnl_drv.assign_chnl_params(CHI_ACTIVE,   CHI_RSP);
    m_rn_rx_rsp_chnl_drv.assign_chnl_params(CHI_REACTIVE, CHI_RSP);
    m_rn_rx_dat_chnl_drv.assign_chnl_params(CHI_REACTIVE, CHI_DAT);

    m_rn_tx_req_chnl_drv.m_cfg = m_cfg; 
    m_rn_tx_dat_chnl_drv.m_cfg = m_cfg;
    m_rn_tx_rsp_chnl_drv.m_cfg = m_cfg;
    m_rn_rx_rsp_chnl_drv.m_cfg = m_cfg;
    m_rn_rx_dat_chnl_drv.m_cfg = m_cfg;
    m_rn_tx_req_chnl_drv.m_lnk = m_txlink;
    m_rn_tx_dat_chnl_drv.m_lnk = m_txlink;
    m_rn_tx_rsp_chnl_drv.m_lnk = m_txlink;
    m_rn_rx_rsp_chnl_drv.m_lnk = m_rxlink;
    m_rn_rx_dat_chnl_drv.m_lnk = m_rxlink;

    //Num flits containter
    m_rn_tx_req_chnl_drv.m_num_flits = m_flits;
    m_rn_tx_dat_chnl_drv.m_num_flits = m_flits;
    m_rn_tx_rsp_chnl_drv.m_num_flits = m_flits;

    //Fwd Link credits
    m_rn_tx_req_chnl_drv.m_crd = m_lcrdq[0];
    m_rn_tx_dat_chnl_drv.m_crd = m_lcrdq[1];
    m_rn_tx_rsp_chnl_drv.m_crd = m_lcrdq[2];
    m_rn_rx_rsp_chnl_drv.m_crd = m_lcrdq[3];
    m_rn_rx_dat_chnl_drv.m_crd = m_lcrdq[4];

    if (m_cfg.snp_chnl_exists()) begin
      m_rn_rx_snp_chnl_drv.assign_chnl_params(CHI_REACTIVE, CHI_SNP);
      m_rn_rx_snp_chnl_drv.m_cfg = m_cfg;
      m_rn_rx_snp_chnl_drv.m_crd = m_lcrdq[5];
      m_rn_rx_snp_chnl_drv.m_lnk = m_rxlink;
    end
  end
  m_rn_tx_req_chnl_mon.assign_chnl_params(CHI_ACTIVE,   CHI_REQ);
  m_rn_tx_dat_chnl_mon.assign_chnl_params(CHI_ACTIVE,   CHI_DAT);
  m_rn_tx_rsp_chnl_mon.assign_chnl_params(CHI_ACTIVE,   CHI_RSP);
  m_rn_rx_rsp_chnl_mon.assign_chnl_params(CHI_REACTIVE, CHI_RSP);
  m_rn_rx_dat_chnl_mon.assign_chnl_params(CHI_REACTIVE, CHI_DAT);
  m_rn_tx_req_chnl_mon.m_cfg = m_cfg; 
  m_rn_tx_dat_chnl_mon.m_cfg = m_cfg;
  m_rn_tx_rsp_chnl_mon.m_cfg = m_cfg;
  m_rn_rx_rsp_chnl_mon.m_cfg = m_cfg;
  m_rn_rx_dat_chnl_mon.m_cfg = m_cfg;
  m_rn_tx_req_chnl_mon.m_lnk = m_txlink;
  m_rn_tx_dat_chnl_mon.m_lnk = m_txlink;
  m_rn_tx_rsp_chnl_mon.m_lnk = m_txlink;
  m_rn_rx_rsp_chnl_mon.m_lnk = m_rxlink;
  m_rn_rx_dat_chnl_mon.m_lnk = m_rxlink;

  //Fwd Link credits
  m_rn_tx_req_chnl_mon.m_crd = m_lcrdq[0];
  m_rn_tx_dat_chnl_mon.m_crd = m_lcrdq[1];
  m_rn_tx_rsp_chnl_mon.m_crd = m_lcrdq[2];
  m_rn_rx_rsp_chnl_mon.m_crd = m_lcrdq[3];
  m_rn_rx_dat_chnl_mon.m_crd = m_lcrdq[4];
  
  if (m_cfg.snp_chnl_exists()) begin
    m_rn_rx_snp_chnl_mon.assign_chnl_params(CHI_REACTIVE, CHI_SNP);
    m_rn_rx_snp_chnl_mon.m_cfg = m_cfg;
    m_rn_rx_snp_chnl_mon.m_crd = m_lcrdq[5];
    m_rn_rx_snp_chnl_mon.m_lnk = m_rxlink;
  end
endfunction: configure_rn_cmp

function void chi_agent::get_sn_interfaces();
  if (!uvm_config_db#(chi_sn_driver_vif)::get(this,
    "", "chi_sn_driver_vif", m_cfg.m_sn_drv_vif)) begin
    `uvm_fatal(get_name(), "Unable to get virtual interface handle chi_sn_driver_vif")
  end
  if (!uvm_config_db#(chi_sn_monitor_vif)::get(this, 
    "", "chi_sn_monitor_vif", m_cfg.m_sn_mon_vif)) begin
    `uvm_fatal(get_name(), "Unable to get virtual interface handle chi_sn_monitor_vif")
  end
endfunction: get_sn_interfaces

function void chi_agent::construct_sn_cmp();
  if (m_cfg.agent_cfg == AGENT_ACTIVE) begin
    //Construct drivers
    m_sn_rx_req_chnl_drv = 
      chi_pasv_chnl_driver#(chi_req_seq_item)::type_id::create(
        "<%=obj.BlockId%>_SnRxReqDrv", null);
    m_sn_rx_dat_chnl_drv = 
      chi_pasv_chnl_driver#(chi_dat_seq_item)::type_id::create(
        "<%=obj.BlockId%>_SnRxDatDrv", null);
    m_sn_tx_rsp_chnl_drv = 
      chi_actv_chnl_driver#(chi_rsp_seq_item)::type_id::create(
        "<%=obj.BlockId%>_SnTxRspDrv", null);
    m_sn_tx_dat_chnl_drv = 
      chi_actv_chnl_driver#(chi_dat_seq_item)::type_id::create(
        "<%=obj.BlockId%>_SnTxDatDrv", null);

    //Construct sequencers
    m_sn_rx_req_chnl_seqr = 
      chi_chnl_sequencer#(chi_req_seq_item)::type_id::create(
        "<%=obj.BlockId%>_SnRxReqMon", null);
    m_sn_rx_dat_chnl_seqr = 
      chi_chnl_sequencer#(chi_dat_seq_item)::type_id::create(
        "<%=obj.BlockId%>_SnRxDatMon", null);
    m_sn_tx_rsp_chnl_seqr = 
      chi_chnl_sequencer#(chi_rsp_seq_item)::type_id::create(
        "<%=obj.BlockId%>_SnTxRspMon", null);
    m_sn_tx_dat_chnl_seqr = 
      chi_chnl_sequencer#(chi_dat_seq_item)::type_id::create(
        "<%=obj.BlockId%>_SnTxDatMon", null);
  end
  //Construct monitors
  m_sn_rx_req_chnl_mon = chi_chnl_monitor#(chi_req_seq_item)::type_id::create(
    "<%=obj.BlockId%>_SnRxReqMon", null);
  m_sn_rx_dat_chnl_mon = chi_chnl_monitor#(chi_dat_seq_item)::type_id::create(
    "<%=obj.BlockId%>_SnRxDatMon", null);
  m_sn_tx_rsp_chnl_mon = chi_chnl_monitor#(chi_rsp_seq_item)::type_id::create(
    "<%=obj.BlockId%>_SnTxRspMon", null);
  m_sn_tx_dat_chnl_mon = chi_chnl_monitor#(chi_dat_seq_item)::type_id::create(
    "<%=obj.BlockId%>_SnTxDatMon", null);
endfunction: construct_sn_cmp

function void chi_agent::configure_sn_cmp();
  //Assign configuration properties to drivers/monitors
  if(m_cfg.agent_cfg == AGENT_ACTIVE) begin
    m_sn_rx_req_chnl_drv.assign_chnl_params(CHI_REACTIVE, CHI_REQ);
    m_sn_rx_dat_chnl_drv.assign_chnl_params(CHI_REACTIVE, CHI_DAT);
    m_sn_tx_rsp_chnl_drv.assign_chnl_params(CHI_ACTIVE,   CHI_RSP);
    m_sn_tx_dat_chnl_drv.assign_chnl_params(CHI_ACTIVE,   CHI_DAT);
    m_sn_rx_req_chnl_drv.m_cfg = m_cfg;
    m_sn_rx_dat_chnl_drv.m_cfg = m_cfg;
    m_sn_tx_rsp_chnl_drv.m_cfg = m_cfg;
    m_sn_tx_dat_chnl_drv.m_cfg = m_cfg;

    m_sn_rx_req_chnl_drv.m_lnk = m_rxlink;
    m_sn_rx_dat_chnl_drv.m_lnk = m_rxlink;
    m_sn_tx_rsp_chnl_drv.m_lnk = m_txlink;
    m_sn_tx_dat_chnl_drv.m_lnk = m_txlink;
    m_sn_rx_req_chnl_drv.m_crd = m_lcrdq[0];
    m_sn_rx_dat_chnl_drv.m_crd = m_lcrdq[1];
    m_sn_tx_rsp_chnl_drv.m_crd = m_lcrdq[2];
    m_sn_tx_dat_chnl_drv.m_crd = m_lcrdq[3];

    //Num flits containter
    m_sn_tx_dat_chnl_drv.m_num_flits = m_flits;
    m_sn_tx_rsp_chnl_drv.m_num_flits = m_flits;
  end

  m_sn_rx_req_chnl_mon.assign_chnl_params(CHI_REACTIVE, CHI_REQ);
  m_sn_rx_dat_chnl_mon.assign_chnl_params(CHI_REACTIVE, CHI_DAT);
  m_sn_tx_rsp_chnl_mon.assign_chnl_params(CHI_ACTIVE,   CHI_RSP);
  m_sn_tx_dat_chnl_mon.assign_chnl_params(CHI_ACTIVE,   CHI_DAT);
  m_sn_rx_req_chnl_mon.m_cfg = m_cfg;
  m_sn_rx_dat_chnl_mon.m_cfg = m_cfg;
  m_sn_tx_rsp_chnl_mon.m_cfg = m_cfg;
  m_sn_tx_dat_chnl_mon.m_cfg = m_cfg;
  m_sn_rx_req_chnl_mon.m_lnk = m_rxlink;
  m_sn_rx_dat_chnl_mon.m_lnk = m_rxlink;
  m_sn_tx_rsp_chnl_mon.m_lnk = m_txlink;
  m_sn_tx_dat_chnl_mon.m_lnk = m_txlink;

  m_sn_rx_req_chnl_mon.m_crd = m_lcrdq[0];
  m_sn_rx_dat_chnl_mon.m_crd = m_lcrdq[1];
  m_sn_tx_rsp_chnl_mon.m_crd = m_lcrdq[2];
  m_sn_tx_dat_chnl_mon.m_crd = m_lcrdq[3];    
endfunction: configure_sn_cmp

function void chi_agent::construct_link_credits();
  for (int i = 0; i < m_cfg.get_num_links(); i++)
    m_lcrdq.push_back(chi_credit_txn::type_id::create(
      $psprintf("LCRD-%0d", i)));
endfunction: construct_link_credits
  
function void chi_agent::construct_link_state_containter();
  m_txlink = chi_link_state::type_id::create("m_txlink");
  m_rxlink = chi_link_state::type_id::create("m_rxlink");
endfunction: construct_link_state_containter

function void chi_agent::construct_all_analysis_ports();
  chi_txreq_pkt_ap = new("chi_txreq_pkt_ap", this); 
  chi_txrsp_pkt_ap = new("chi_txrsp_pkt_ap", this);
  chi_txdat_pkt_ap = new("chi_txdat_pkt_ap", this);
  chi_rxrsp_pkt_ap = new("chi_rxrsp_pkt_ap", this);
  chi_rxdat_pkt_ap = new("chi_rxdat_pkt_ap", this);
  chi_rxsnp_pkt_ap = new("chi_rxsnp_pkt_ap", this);
                          
  chi_txreq_crd_ap = new("chi_txreq_crd_ap", this);
  chi_txrsp_crd_ap = new("chi_txrsp_crd_ap", this);
  chi_txdat_crd_ap = new("chi_txdat_crd_ap", this);
  chi_rxrsp_crd_ap = new("chi_rxrsp_crd_ap", this);
  chi_rxdat_crd_ap = new("chi_rxdat_crd_ap", this);
  chi_rxsnp_crd_ap = new("chi_rxsnp_crd_ap", this);

  chi_sysco_pkt_ap = new("chi_sysco_pkt_ap", this);
endfunction: construct_all_analysis_ports

