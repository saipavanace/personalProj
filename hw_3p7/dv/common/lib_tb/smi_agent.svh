////////////////////////////////////////////////////////////////////////////////
//
// SMI Agent
<% if (1 == 0) { %>
// Author: Chirag Gandhi
<% } %>
//
////////////////////////////////////////////////////////////////////////////////
class smi_agent extends uvm_agent;

    `uvm_component_param_utils(smi_agent)

    smi_agent_config m_cfg;
    smi_coverage m_smi_cov;

    <% var NSMIIFTX = obj.nSmiRx;
    for (var i = 0; i < NSMIIFTX; i++) { %>
        uvm_analysis_port #(smi_seq_item) m_smi<%=i%>_tx_port_ap;
        uvm_analysis_port #(smi_seq_item) m_smi<%=i%>_tx_every_beat_port_ap;
        uvm_analysis_port #(smi_seq_item) m_smi<%=i%>_tx_ndp_ap;
        smi_monitor                       m_smi<%=i%>_tx_monitor;
        smi_driver#(SMI_TRANSMITTER)      m_smi<%=i%>_tx_driver;
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
        smi_force_driver#(SMI_TRANSMITTER)  m_smi<%=i%>_tx_force_driver;
    `endif
<% } %>
        smi_sequencer                     m_smi<%=i%>_tx_seqr;
    <% } %>
    <% var NSMIIFRX = obj.nSmiTx;
    for (var i = 0; i < NSMIIFRX; i++) { %>
        uvm_analysis_port #(smi_seq_item) m_smi<%=i%>_rx_port_ap;
        uvm_analysis_port #(smi_seq_item) m_smi<%=i%>_rx_every_beat_port_ap;
        uvm_analysis_port #(smi_seq_item) m_smi<%=i%>_rx_ndp_ap;
        smi_monitor                       m_smi<%=i%>_rx_monitor;
        smi_driver#(SMI_RECEIVER)         m_smi<%=i%>_rx_driver;
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
        smi_force_driver#(SMI_RECEIVER)     m_smi<%=i%>_rx_force_driver;
    `endif
<% } %>
        smi_sequencer                     m_smi<%=i%>_rx_seqr;
    <% } %>


    smi_virtual_sequencer                 m_smi_virtual_seqr;

<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
    <%=obj.BlockId%>_smi_force_virtual_sequencer           m_smi_force_virtual_seqr;
    `endif
<% } %>

    function new(string name = "smi_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);


        if (uvm_config_db#(smi_agent_config)::get(
            .cntxt( this ), 
            .inst_name ( "" ), 
            .field_name( "smi_agent_config" ),
        .value( m_cfg ))) begin
                `uvm_info("smi_agent", $psprintf("Got smi_agent_config"),UVM_MEDIUM)
        end else begin
            smi_port_config m_temp_smi_port_config;
            virtual <%=obj.BlockId + '_smi_if'%> m_temp_smi_if;
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
            virtual <%=obj.BlockId + '_smi_force_if'%> m_temp_smi_force_if; 
    `endif
<% } %>

            m_cfg = smi_agent_config::type_id::create("m_smi_agent_config", this);
            <% for (var i = 0; i < NSMIIFTX; i++) { %>
                if (uvm_config_db#(smi_port_config)::get(
                    .cntxt      ( this ), 
                    .inst_name  ( "" ), 
                    .field_name ( "m_smi<%=i%>_tx_port_config" ),
                    .value      ( m_temp_smi_port_config ))) begin
                    m_cfg.m_smi<%=i%>_tx_port_config = m_temp_smi_port_config;
                end
		        else begin
                    m_cfg.m_smi<%=i%>_tx_port_config = smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config",this);
		        end				    
                if (uvm_config_db#(virtual <%=obj.BlockId + '_smi_if'%>)::get(
                    .cntxt      ( this ), 
                    .inst_name  ( "" ), 
                    .field_name ( "m_smi<%=i%>_tx_port_if" ),
                    .value      ( m_temp_smi_if))) begin
                    m_cfg.m_smi<%=i%>_tx_port_config.m_vif = m_temp_smi_if;
                end
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
                if (uvm_config_db#(virtual <%=obj.BlockId + '_smi_force_if'%>)::get(
                    .cntxt      ( this ), 
                    .inst_name  ( "" ), 
                    .field_name ( "m_smi<%=i%>_tx_port_if" ),
                    .value      ( m_temp_smi_force_if))) begin
                    m_cfg.m_smi<%=i%>_tx_port_config.m_force_vif = m_temp_smi_force_if;
                end
    `endif
<% } %>
            <% } %>
            <% for (var i = 0; i < NSMIIFRX; i++) { %>
                if (uvm_config_db#(smi_port_config)::get(
                    .cntxt      ( this ), 
                    .inst_name  ( "" ), 
                    .field_name ( "m_smi<%=i%>_rx_port_config" ),
                .value      ( m_temp_smi_port_config ))) begin
                    m_cfg.m_smi<%=i%>_rx_port_config = m_temp_smi_port_config;
                end
                else begin
                    m_cfg.m_smi<%=i%>_rx_port_config = smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config",this);
                end

                if (uvm_config_db#(virtual <%=obj.BlockId + '_smi_if'%>)::get(
                    .cntxt      ( this ), 
                    .inst_name  ( "" ), 
                    .field_name ( "m_smi<%=i%>_rx_port_if" ),
                .value      ( m_temp_smi_if))) begin
                    m_cfg.m_smi<%=i%>_rx_port_config.m_vif = m_temp_smi_if;
                end
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
                if (uvm_config_db#(virtual <%=obj.BlockId + '_smi_force_if'%>)::get(
                    .cntxt      ( this ), 
                    .inst_name  ( "" ), 
                    .field_name ( "m_smi<%=i%>_rx_port_if" ),
                    .value      ( m_temp_smi_force_if))) begin
                    m_cfg.m_smi<%=i%>_rx_port_config.m_force_vif = m_temp_smi_force_if;
                end
    `endif
<% } %>
            <% } %>
        end
        <% for (var i = 0; i < NSMIIFTX; i++) { %>
            m_smi<%=i%>_tx_monitor = smi_monitor#(SMI_TRANSMITTER, <%=i%>)::type_id::create("m_smi<%=i%>_tx_monitor", this);
            if(m_cfg.active == UVM_ACTIVE) begin
                m_smi<%=i%>_tx_driver = smi_driver#(SMI_TRANSMITTER)::type_id::create("m_smi<%=i%>_tx_driver", this);
                m_smi<%=i%>_tx_seqr   = smi_sequencer::type_id::create("m_smi<%=i%>_tx_seqr", this);
            end
            else begin
             <%  if(obj.BlockId.match('chiaiu')) { %>
                `ifdef CHI_SUBSYS
                   m_smi<%=i%>_tx_force_driver = smi_force_driver#(SMI_TRANSMITTER)::type_id::create("m_smi<%=i%>_tx_force_driver", this);
                   m_smi<%=i%>_tx_seqr         = smi_sequencer::type_id::create("m_smi<%=i%>_tx_seqr", this);
                 `endif
             <% } %>
           end
        <%}%>
        <% for (var i = 0; i < NSMIIFRX; i++) { %>
            m_smi<%=i%>_rx_monitor = smi_monitor#(SMI_RECEIVER, <%=i%>)::type_id::create("m_smi<%=i%>_rx_monitor", this);
            if(m_cfg.active == UVM_ACTIVE) begin
                m_smi<%=i%>_rx_driver = smi_driver#(SMI_RECEIVER)::type_id::create("m_smi<%=i%>_rx_driver", this);
                m_smi<%=i%>_rx_seqr   = smi_sequencer::type_id::create("m_smi<%=i%>_rx_seqr", this);
            end
            else begin
             <%  if(obj.BlockId.match('chiaiu')) { %>
                `ifdef CHI_SUBSYS
                   m_smi<%=i%>_rx_force_driver = smi_force_driver#(SMI_RECEIVER)::type_id::create("m_smi<%=i%>_rx_force_driver", this);
                `endif
             <% } %>
            end
        <%}%>
        if(m_cfg.active == UVM_ACTIVE) begin
            m_smi_virtual_seqr = smi_virtual_sequencer::type_id::create("smi_virtual_sequencer", this);
        end

      <%if(obj.BlockId.match('chiaiu')) {%>
          `ifdef CHI_SUBSYS
            m_smi_force_virtual_seqr = <%=obj.BlockId%>_smi_force_virtual_sequencer::type_id::create("m_smi_force_virtual_seqr", this);
           `endif
      <%}%>
        if(m_cfg.cov_en) begin
          `uvm_info("smi_agent",$psprintf("smi_coverage will be collected"),UVM_DEBUG);
          m_smi_cov = smi_coverage::type_id::create("m_smi_cov",this);
        end
                 `uvm_info("smi_agent",$psprintf("end of build phase"),UVM_MEDIUM);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
                 `uvm_info("smi_agent",$psprintf("connect phase started <%=i%>"),UVM_MEDIUM);
        <% for (var i = 0; i < NSMIIFTX; i++) { %>
            // Checking to make sure an interface has been assigned
            if (m_cfg.m_smi<%=i%>_tx_port_config.m_vif == null) begin
                `uvm_error("smi_agent", $psprintf("TX Interface for port %0d is null", <%=i%>))
            end 
            else begin
                 `uvm_info("smi_agent",$psprintf("Got smi_if m_cfg.m_smi<%=i%>_tx_port_config.m_vif = %p",m_cfg.m_smi<%=i%>_tx_port_config.m_vif),UVM_MEDIUM);
            end
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
            if (m_cfg.m_smi<%=i%>_tx_port_config.m_force_vif == null) begin
                `uvm_error("smi_agent", $psprintf("TX force Interface for port %0d is null", <%=i%>))
            end 
            else begin
                 `uvm_info("smi_agent",$psprintf("Got smi_if m_cfg.m_smi<%=i%>_tx_port_config.m_force_vif = %p",m_cfg.m_smi<%=i%>_tx_port_config.m_vif),UVM_MEDIUM);
            end
    `endif
<% } %>
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
            m_smi<%=i%>_tx_monitor.m_vif        = m_cfg.m_smi<%=i%>_tx_port_config.m_force_vif;
      `else
            m_smi<%=i%>_tx_monitor.m_vif        = m_cfg.m_smi<%=i%>_tx_port_config.m_vif;
    `endif
<% } else { %> 
            m_smi<%=i%>_tx_monitor.m_vif        = m_cfg.m_smi<%=i%>_tx_port_config.m_vif;
<% } %>
            m_smi<%=i%>_tx_monitor.delay_export = m_cfg.m_smi<%=i%>_tx_port_config.delay_export;
            m_smi<%=i%>_tx_monitor.is_transmitter  = 1;
            m_smi<%=i%>_tx_port_ap              = m_smi<%=i%>_tx_monitor.smi_ap;
            m_smi<%=i%>_tx_every_beat_port_ap   = m_smi<%=i%>_tx_monitor.every_beat_smi_ap;
            m_smi<%=i%>_tx_ndp_ap               = m_smi<%=i%>_tx_monitor.smi_ndp_ap;
            if(m_cfg.active == UVM_ACTIVE) begin
                m_cfg.m_smi<%=i%>_tx_port_config.m_vif.is_active   = 1;
                m_cfg.m_smi<%=i%>_tx_port_config.m_vif.is_receiver = 0;
                m_smi<%=i%>_tx_driver.seq_item_port.connect(m_smi<%=i%>_tx_seqr.seq_item_export);
                m_smi<%=i%>_tx_driver.m_vif                         = m_cfg.m_smi<%=i%>_tx_port_config.m_vif;
                m_smi<%=i%>_tx_driver.m_vif.k_delay_min             = m_cfg.m_smi<%=i%>_tx_port_config.k_delay_min.get_value();
                m_smi<%=i%>_tx_driver.m_vif.k_delay_max             = m_cfg.m_smi<%=i%>_tx_port_config.k_delay_max.get_value();
                m_smi<%=i%>_tx_driver.m_vif.k_burst_pct             = m_cfg.m_smi<%=i%>_tx_port_config.k_burst_pct.get_value();
                m_smi<%=i%>_tx_driver.m_vif.k_is_bfm_delay_changing = m_cfg.m_smi<%=i%>_tx_port_config.change_delays_over_time.get_value();
                m_smi_virtual_seqr.m_smi<%=i%>_tx_seqr              = m_smi<%=i%>_tx_seqr;
            end else begin
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
                m_cfg.m_smi<%=i%>_tx_port_config.m_force_vif.is_active   = 1;
                m_cfg.m_smi<%=i%>_tx_port_config.m_force_vif.is_receiver = 0;
                m_smi<%=i%>_tx_force_driver.seq_item_port.connect(m_smi<%=i%>_tx_seqr.seq_item_export);
                m_smi<%=i%>_tx_force_driver.m_force_vif                         = m_cfg.m_smi<%=i%>_tx_port_config.m_force_vif;
                m_smi<%=i%>_tx_force_driver.m_vif                         	= m_cfg.m_smi<%=i%>_tx_port_config.m_vif;
                m_smi<%=i%>_tx_force_driver.m_force_vif.k_delay_min             = m_cfg.m_smi<%=i%>_tx_port_config.k_delay_min.get_value();
                m_smi<%=i%>_tx_force_driver.m_force_vif.k_delay_max             = m_cfg.m_smi<%=i%>_tx_port_config.k_delay_max.get_value();
                m_smi<%=i%>_tx_force_driver.m_force_vif.k_burst_pct             = m_cfg.m_smi<%=i%>_tx_port_config.k_burst_pct.get_value();
                m_smi<%=i%>_tx_force_driver.m_force_vif.k_is_bfm_delay_changing = m_cfg.m_smi<%=i%>_tx_port_config.change_delays_over_time.get_value();
                m_smi_force_virtual_seqr.m_smi<%=i%>_tx_seqr                    = m_smi<%=i%>_tx_seqr;
                m_smi_force_virtual_seqr.m_<%=i%>_vif                         	= m_cfg.m_smi<%=i%>_tx_port_config.m_vif;
    `endif
<% } %>
end
        <% } %>
        <% for (var i = 0; i < NSMIIFRX; i++) { %>
            // Checking to make sure an interface has been assigned
            if (m_cfg.m_smi<%=i%>_rx_port_config.m_vif == null) begin
                `uvm_error("smi_agent", $psprintf("rx Interface for port %0d is null", <%=i%>))
            end
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
            if (m_cfg.m_smi<%=i%>_rx_port_config.m_force_vif == null) begin
                `uvm_error("smi_agent", $psprintf("rx force Interface for port %0d is null", <%=i%>))
            end
    `endif
<% } %>
            m_cfg.m_smi<%=i%>_rx_port_config.delay_export = 1;
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
            m_smi<%=i%>_rx_monitor.m_vif    = m_cfg.m_smi<%=i%>_rx_port_config.m_force_vif;
    `else
            m_smi<%=i%>_rx_monitor.m_vif        = m_cfg.m_smi<%=i%>_rx_port_config.m_vif;
    `endif
<% } else { %> 
            m_smi<%=i%>_rx_monitor.m_vif        = m_cfg.m_smi<%=i%>_rx_port_config.m_vif;
<% } %>
            m_smi<%=i%>_rx_monitor.delay_export = m_cfg.m_smi<%=i%>_rx_port_config.delay_export;
            m_smi<%=i%>_rx_monitor.is_transmitter  = 0;
            m_smi<%=i%>_rx_port_ap              = m_smi<%=i%>_rx_monitor.smi_ap;
            m_smi<%=i%>_rx_every_beat_port_ap   = m_smi<%=i%>_rx_monitor.every_beat_smi_ap;
            m_smi<%=i%>_rx_ndp_ap               = m_smi<%=i%>_rx_monitor.smi_ndp_ap;
            if(m_cfg.active == UVM_ACTIVE) begin
                m_cfg.m_smi<%=i%>_rx_port_config.m_vif.is_active   = 1;
                m_cfg.m_smi<%=i%>_rx_port_config.m_vif.is_receiver = 1;
                m_smi<%=i%>_rx_driver.seq_item_port.connect(m_smi<%=i%>_rx_seqr.seq_item_export);
                m_smi<%=i%>_rx_driver.m_vif                         = m_cfg.m_smi<%=i%>_rx_port_config.m_vif;
                m_smi<%=i%>_rx_driver.m_vif.k_delay_min             = m_cfg.m_smi<%=i%>_rx_port_config.k_delay_min.get_value();
                m_smi<%=i%>_rx_driver.m_vif.k_delay_max             = m_cfg.m_smi<%=i%>_rx_port_config.k_delay_max.get_value();
                m_smi<%=i%>_rx_driver.m_vif.k_burst_pct             = m_cfg.m_smi<%=i%>_rx_port_config.k_burst_pct.get_value();
                m_smi<%=i%>_rx_driver.m_vif.k_is_bfm_delay_changing = m_cfg.m_smi<%=i%>_rx_port_config.change_delays_over_time.get_value();
                m_smi_virtual_seqr.m_smi<%=i%>_rx_seqr              = m_smi<%=i%>_rx_seqr;
                if (m_cfg.bfm_connect_to_per_beat_rx) begin
                   m_smi<%=i%>_rx_monitor.every_beat_smi_ap.connect( m_smi<%=i%>_rx_seqr.m_rx_analysis_fifo.analysis_export);
                end else begin
                   m_smi<%=i%>_rx_monitor.smi_ap.connect( m_smi<%=i%>_rx_seqr.m_rx_analysis_fifo.analysis_export);
                end
            end else begin
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
                m_cfg.m_smi<%=i%>_rx_port_config.m_force_vif.is_active   = 1;
                m_cfg.m_smi<%=i%>_rx_port_config.m_force_vif.is_receiver = 1;
                m_smi<%=i%>_rx_force_driver.m_force_vif                         = m_cfg.m_smi<%=i%>_rx_port_config.m_force_vif;
                m_smi<%=i%>_rx_force_driver.m_vif                         	= m_cfg.m_smi<%=i%>_rx_port_config.m_vif;
                m_smi<%=i%>_rx_force_driver.m_force_vif.k_delay_min             = m_cfg.m_smi<%=i%>_rx_port_config.k_delay_min.get_value();
                m_smi<%=i%>_rx_force_driver.m_force_vif.k_delay_max             = m_cfg.m_smi<%=i%>_rx_port_config.k_delay_max.get_value();
                m_smi<%=i%>_rx_force_driver.m_force_vif.k_burst_pct             = m_cfg.m_smi<%=i%>_rx_port_config.k_burst_pct.get_value();
                m_smi<%=i%>_rx_force_driver.m_force_vif.k_is_bfm_delay_changing = m_cfg.m_smi<%=i%>_rx_port_config.change_delays_over_time.get_value();
    `endif
<% } %>
end
        <% } %>

      if(m_cfg.cov_en) begin
	    <% for (var i = 0; i < NSMIIFTX; i++) { %>
	    	m_smi<%=i%>_tx_monitor.smi_ap.connect(m_smi_cov.analysis_smi);
	    <%}%>
	    <% for (var i = 0; i < NSMIIFRX; i++) { %>
            m_smi<%=i%>_rx_monitor.smi_ap.connect(m_smi_cov.analysis_smi);
	    <%}%>
      end

    endfunction : connect_phase

    task run_phase (uvm_phase phase);
        // Driving smi_dp_valid to 0 so that the signal does not remain undriven
        // on ports where smi_dp* do not exist adn ready is input
        <% for (var i = 0; i < NSMIIFRX; i++) { %>
            <% if (!obj.interfaces.smiTxInt[i].params.nSmiDPvc) { %>
                m_cfg.m_smi<%=i%>_rx_port_config.m_vif.drive_dp_nonvalid();
            <% } %>
        <% } %>
    endtask : run_phase

endclass: smi_agent
