//Root class for all DMI sequence items to extend from
class dmi_seq_item extends smi_seq_item;

  dmi_env_config cfg;
  dmi_cmd_args args;
  longint unsigned pkt_id;
  static longint unsigned uid;
  smi_addr_t gen_addr, gen_SP_addr;
  bit gen_addr_is_SP;
  rand dmi_addr_format_t m_addr_type;
  rand dmi_pattern_type_t m_pattern_type;
  aiu_id_t aiu_gen_id,aiu_gen_id_mpf;
  dce_id_t dce_gen_id;  
  int qos_pgm_idx;
  smi_type_t atomic_types[$],mrd_types[$],cmo_types[$];
  smi_type_t dtwmrgmrd_types[$],coh_write_types[$],noncoh_read_types[$];
  smi_type_t cmd_cmo_types[$],noncoh_write_types[$];
  smi_type_t read_types[$],write_types[$];
  smi_type_t legal_exclusive_types[$];

  `uvm_object_utils_begin(dmi_seq_item)
  `uvm_object_utils_end

  extern function set_default_queues();
  
  function new(string name = "dmi_seq_item");
    super.new(name);
    set_default_queues();
    uid++;
    pkt_id = uid;
  endfunction

  function get_cfg(const ref dmi_env_config r_cfg);
    cfg = r_cfg;
    get_args(r_cfg.m_args);
    pkt_uid = cfg.m_rsrc_mgr.get_unique_pkt_uid();
    qos_pgm_idx = (cfg.qos_mode == QOS_UPDATE) ? 1: 0;
  endfunction

  function get_args(const ref dmi_cmd_args r_args);
    args = r_args;
  endfunction


endclass

function dmi_seq_item::set_default_queues();
  atomic_types = {CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM};
  mrd_types = {MRD_RD_WITH_SHR_CLN,MRD_RD_WITH_UNQ_CLN,MRD_RD_WITH_UNQ,MRD_RD_WITH_INV,MRD_FLUSH,MRD_CLN,MRD_INV,MRD_PREF};
  cmo_types = {MRD_FLUSH,MRD_CLN,MRD_INV,MRD_PREF,CMD_CLN_INV,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF};
  cmd_cmo_types = {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV};
  dtwmrgmrd_types = {DTW_MRG_MRD_UCLN,DTW_MRG_MRD_UDTY,DTW_MRG_MRD_INV};
  coh_write_types = {DTW_NO_DATA,DTW_DATA_CLN,DTW_DATA_PTL,DTW_DATA_DTY};
  noncoh_read_types = {CMD_RD_NC};
  noncoh_write_types = {CMD_WR_NC_PTL,CMD_WR_NC_FULL};
  read_types = {mrd_types,noncoh_read_types};
  write_types = {DTW_DATA_CLN,DTW_DATA_PTL,DTW_DATA_DTY,noncoh_write_types};
  legal_exclusive_types = {atomic_types,noncoh_read_types,noncoh_write_types};
endfunction
