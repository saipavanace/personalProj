
`uvm_analysis_imp_decl(_mst_rsp)
`uvm_analysis_imp_decl(_slv_req)

////////////////////////////////////////////////////////////////////////////////
//
// DMI Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class dmi_master_virtual_sequencer extends uvm_sequencer;


   sfi_master_req_sequencer  m_sfi_mst_req_seqr;
   sfi_master_rsp_sequencer  m_sfi_mst_rsp_seqr;

   sfi_master_req_sequencer  m_sfi_mst_dtw_req_seqr;
   sfi_master_rsp_sequencer  m_sfi_mst_dtw_rsp_seqr;



   `uvm_component_utils_begin(dmi_master_virtual_sequencer)
      `uvm_field_obejct(m_sfi_mst_req_seqr,UVM_ALL_ON);
      `uvm_field_obejct(m_sfi_mst_rsp_seqr,UVM_ALL_ON);
      `uvm_field_obejct(m_sfi_mst_dtw_req_seqr,UVM_ALL_ON);
      `uvm_field_obejct(m_sfi_mst_dtw_rsp_seqr,UVM_ALL_ON);
   `uvm_component_utils_end

   function new(string name "dmi_master_virtual_sequencer", uvm_component parent = null);
     super.new(name,parent) 
   endfunction


endclass:dmi_master_virtual_sequencer

class dmi_slave_virtual_sequencer extends uvm_sequencer;


   sfi_slave_req_sequencer   m_sfi_slv_dtr_req_seqr;
   sfi_slave_rsp_sequencer   m_sfi_slv_dtr_rsp_seqr;

   sfi_slave_req_sequencer   m_sfi_slv_strNc_req_seqr;
   sfi_slave_rsp_sequencer   m_sfi_slv_strNc_rsp_seqr;


   `uvm_component_utils_begin(dmi_slave_virtual_sequencer)
      `uvm_field_obejct(m_sfi_slv_dtr_req_seqr,UVM_ALL_ON);
      `uvm_field_obejct(m_sfi_slv_dtr_rsp_seqr,UVM_ALL_ON);
      `uvm_field_obejct(m_sfi_slv_strNc_req_seqr,UVM_ALL_ON);
      `uvm_field_obejct(m_sfi_slv_strNc_rsp_seqr,UVM_ALL_ON);
   `uvm_component_utils_end

   function new(string name "dmi_slave_virtual_sequencer", uvm_component parent = null);
     super.new(name,parent) 
   endfunction


endclass:dmi_slave_virtual_sequencer
