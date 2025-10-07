<%  if(obj.BlockId.match('chiaiu')) { %>
<% 
var NSMIIFTX = obj.nSmiRx;
%>
class smi_force_driver#(smi_agent_type_enum_t agent_type=SMI_TRANSMITTER) extends uvm_driver #(smi_seq_item) ;

    `uvm_component_param_utils(smi_force_driver #(agent_type))

    virtual <%=obj.BlockId + '_smi_if'%>         m_vif;
    virtual <%=obj.BlockId + '_smi_force_if'%>   m_force_vif;

    smi_agent_type_enum_t                m_agent_type;
    smi_seq_item  			 m_smi_seq;
    bit                                  is_transmitter;
    int                                  m_port_num;

    function new(string name = "smi_force_driver", uvm_component parent = null);
        super.new(name, parent);
        m_agent_type = agent_type;
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    task run;

        mailbox#(smi_seq_item) m_driver_seq_item = new(1);

        if (m_agent_type == SMI_TRANSMITTER) begin : SMI_TRANS
	    @(posedge m_force_vif.rst_n);
	      repeat(10)  @(posedge m_force_vif.clk);

	    fork
            	m_force_vif.drive_ready();
            join
            fork
                begin : fork_1
                    forever begin : forever_1
                        automatic smi_seq_item m_item;
                        seq_item_port.get_next_item(m_item);
                         if(m_item.smi_msg_type !== 'h7a)begin
                            m_item.pack_smi_seq_item();
                         end
            	        m_driver_seq_item.put(m_item);
                         `uvm_info("FORCE_DRV_GET_NEXT_ITEM_PUT", $sformatf("DEBUG m_item: %p", m_item.convert2string()), UVM_DEBUG)
                        seq_item_port.item_done();
                    end : forever_1
                end : fork_1

                begin : fork_2
                    forever begin : forever_2
                        smi_seq_item m_drv_item;
                        m_driver_seq_item.get(m_drv_item);
                        `uvm_info("FORCE_DRV_DRIVE_ITEM_GET", $sformatf("DEBUG m_item: %p", m_drv_item.convert2string()), UVM_DEBUG)
                        fork
                            begin
				if(m_drv_item.smi_msg_type != 0) begin
                                   m_force_vif.drive_ndp(m_drv_item);
                                   `uvm_info("FORCE_DRV_DRIVE_ITEM_DRIVE_NDP", $sformatf("DEBUG m_item: %p", m_drv_item.convert2string()), UVM_DEBUG)
				end
                            end
                            begin
                                smi_seq_item m_temp_item;
                                if (m_drv_item.smi_dp_present) begin
                                    $cast(m_temp_item, m_drv_item.clone());
                                    m_temp_item.smi_dp_data       = new[1];
                                    m_temp_item.smi_dp_data[0]    = m_drv_item.smi_dp_data[0];
                                    m_temp_item.smi_dp_user       = new [1];
                                    m_temp_item.smi_dp_user[0]    = m_drv_item.smi_dp_user[0];
                                    m_temp_item.smi_dp_last       = m_drv_item.smi_dp_last;
                                    `uvm_info("FORCE_DRV_DRIVE_ITEM_DRIVE_DP", $sformatf("ECC DEBUG D2B: m_temp_item %p", m_temp_item.convert2string()), UVM_DEBUG)
                                    #0 m_force_vif.drive_dp(m_temp_item);
                                end
                            end
                        join
                    end : forever_2
                end : fork_2
            join_none
        end : SMI_TRANS
          else if (m_agent_type == SMI_RECEIVER) begin : RECV
        end : RECV
    endtask : run
endclass : smi_force_driver
<% } %>
