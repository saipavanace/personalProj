//////////////////////////////////////////////////////////////////////////////
// DCE Probe ATT packet
//////////////////////////////////////////////////////////////////////////////
typedef struct {
  bit           valid;
  AIUID_t       aiu_id;
  AIUTransID_t  aiu_trans_id;

} dce_probe_att_packet_t;

////////////////////////////////////////////////////////////////////////////////
// DCE Probe DIRLOOKUP packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {
  bit                                       valid;
  bit                                       dir_lookup_txn_type;
  <%=obj.BlockId + '_con'%>::sfi_addr_t     dir_lookup_txn_addr;
  <%=obj.BlockId + '_con'%>::sfi_reqPriv_t  dir_lookup_txn_sfipriv;

} dce_probe_dirlookup_packet_t;


////////////////////////////////////////////////////////////////////////////////
// DCE Probe coherent request packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {
  bit                                         valid;
  <%=obj.BlockId + '_con'%>::sfi_addr_t       coh_req_addr;
  <%=obj.BlockId + '_con'%>::sfi_security_t   coh_req_security;
  <%=obj.BlockId + '_con'%>::sfi_reqPriv_t    coh_req_sfipriv;
  <%=obj.BlockId + '_con'%>::sfi_urgency_t    coh_req_urgency;
  bit                                         coh_req_vld;
  bit                                         coh_req_rdy;
  int                                         is_victim_buffer_hit;
  bit [<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0] att_activate_rsp_attid;
} dce_probe_coh_req_packet_t;

////////////////////////////////////////////////////////////////////////////////
// DCE Probe wake request packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {
  bit                                         valid;
  <%=obj.BlockId + '_con'%>::sfi_addr_t       wake_req_addr;
  bit [<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0] wake_req_attid;
  <%=obj.BlockId + '_con'%>::sfi_security_t   wake_req_security;
  <%=obj.BlockId + '_con'%>::sfi_reqPriv_t    wake_req_sfipriv;
  <%=obj.BlockId + '_con'%>::sfi_urgency_t    wake_req_urgency;
  bit                                         wake_req_vld;
  bit                                         wake_req_rdy;
} dce_probe_wake_req_packet_t;

////////////////////////////////////////////////////////////////////////////////
// DCE Probe dir commit request packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {
  bit                                         valid;
  <%=obj.BlockId + '_con'%>::sfi_addr_t       dir_commit_req_addr;
  <%=obj.BlockId + '_con'%>::AIUID_t          dir_commit_req_aiuid;
  bit [<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0] dir_commit_req_attid;
  bit                                         dir_commit_req_dont_write;
  bit [<%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs-1:0] dir_commit_req_ocv;
  bit [<%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs-1:0] dir_commit_req_scv;
  <%=obj.BlockId + '_con'%>::sfi_security_t   dir_commit_req_security;
  bit                                         dir_commit_req_vld;
  bit                                         dir_commit_req_rdy;
  bit                                         dir_commit_req_maint_recall;
} dce_probe_dir_commit_req_packet_t;

////////////////////////////////////////////////////////////////////////////////
// DCE Probe update request packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {
  bit                                         valid;
  <%=obj.BlockId + '_con'%>::sfi_addr_t       upd_req_addr;
  <%=obj.BlockId + '_con'%>::sfi_security_t   upd_req_security;
  <%=obj.BlockId + '_con'%>::sfi_reqPriv_t    upd_req_sfipriv;
  <%=obj.BlockId + '_con'%>::sfi_urgency_t    upd_req_urgency;
  <%=obj.BlockId + '_con'%>::AIUID_t          p2_aiuid;
  bit                                         upd_req_vld;
  bit                                         upd_req_rdy;
  int                                         is_victim_buffer_hit;

} dce_probe_upd_req_packet_t;


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
typedef struct {

  bit dont_write;
  bit [<%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs-1:0] c_owner_commit_vector;
  bit [<%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs-1:0] c_sharer_commit_vector;
  <%=obj.BlockId + '_con'%>::CMDreqEntry_t  cmd_req_entry;
  <%=obj.BlockId + '_con'%>::STRreqEntry_t  str_req_entry;
  <%=obj.BlockId + '_con'%>::STRrspEntry_t  str_rsp_entry;

} dce_dir_commit_info_t;


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
typedef struct {

  
  bit                                                  valid;
  bit                                                  att_activate_recall_req;
  bit                                                  att_activate_maint_recall;
  bit [<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0] att_activate_rsp_attid;
  bit                                                  att_activate_security;
  <%=obj.BlockId + '_con'%>::sfi_addr_t                att_activate_txn_addr;
  <%=obj.BlockId + '_con'%>::sfi_reqPriv_t             att_activate_txn_sfipriv;
  bit                                                  att_activate_txn_is_wakeup;
  bit                                                  att_activate_req_vld;
  <%=obj.BlockId + '_con'%>::AIUID_t                   p2_aiuid;
  bit [4:0]                                            maint_req_snoopfilter_id;
  bit                                                  p1_lookup_valid;

} dce_recall_info_packet_t;

typedef struct {
  bit                                                  valid;
  bit [<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0] dir_rsp_attid;
  int                                                  is_victim_buffer_hit;
} dce_dir_rsp_packet_t;


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
typedef struct {

  bit         valid;
  bit [127:0] DIRUCASER_CaSnpEn;
  bit [31:0]  DIRUMRHER_MrHntEn;
  bit [31:0]  DIRUSFER_SfEn;
  bit [127:0] CSADSER_DvmSnpEn;

} dce_hw_info_packet_t;

typedef struct {
    maint_req_opcode_t maint_opcode;
    bit [4:0]          sf_id;
    bit                security_bit;
    bit [19:0]         maint_entry;
    bit [5:0]          maint_way;
    bit [5:0]          maint_word;
    bit [11:0]         maint_addr;
} dce_maint_pkt_t;

typedef struct {
    int sf_width;
    int nblocks;
    int nwords_per_block;
} dce_sf_info_t;
