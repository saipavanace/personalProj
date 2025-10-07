//
// SFI Parameters
//

typedef bit [WCCPPOISION-1:0]      ccp_data_poision_t;
typedef bit [WCCPDATA-1:0]         ccp_ctrlwr_data_t;
typedef bit                        ccp_ctrlwr_vld_t;
typedef bit [WCCPBYTEEN-1:0]       ccp_ctrlwr_byten_t;
typedef bit [WCCPBEAT-1:0]         ccp_ctrlwr_beatn_t;
typedef bit                        ccp_ctrlwr_last_t;
typedef bit                        ccp_cachewr_rdy_t;


typedef bit                        ccp_ctrlfilldata_vld_t;
typedef bit [WCCPDATA-1:0]         ccp_ctrlfill_data_t;
typedef bit [WCCPFILLID-1:0]       ccp_ctrlfilldata_Id_t;
typedef bit [WCCPADDR-1:0]         ccp_ctrlfilldata_addr_t;
typedef bit [WCCPWAYS-1:0]         ccp_ctrlfilldata_wayn_t;
typedef bit [WCCPBEAT-1:0]         ccp_ctrlfilldata_beatn_t;
typedef bit [WCCPBYTEEN-1:0]       ccp_ctrlfilldata_byten_t;
typedef bit                        ccp_ctrlfilldata_last_t;
//CONC-15425::CONC-15710 - Fill Interface udpdate: Adding Fill data full signal to the Fill Data Interafce
typedef bit                        ccp_ctrlfilldata_full_t;
typedef bit                        ccp_cachefilldata_rdy_t;
typedef bit                        ccp_ctrlfill_vld_t;
typedef bit [WCCPADDR-1:0]         ccp_ctrlfill_addr_t;
typedef bit [WCCPWAYS-1:0]         ccp_ctrlfill_wayn_t;
typedef bit [WCCPSECURITY-1:0]     ccp_ctrlfill_security_t;
typedef bit [WCCPCACHESTATE-1:0]   ccp_ctrlfill_state_t;
typedef bit                        ccp_cachefill_rdy_t;
typedef bit [WCCPFILLDONEID-1:0]   ccp_cachefill_doneId_t;
typedef bit                        ccp_cachefill_done_t;

typedef bit                        ccp_cache_evict_vld_t;
typedef bit [WCCPDATA-1:0]         ccp_cache_evict_data_t;
typedef bit [WCCPBYTEEN-1:0]       ccp_cache_evict_byten_t;
typedef bit                        ccp_cache_evict_last_t;
typedef bit                        ccp_cache_evict_cancel_t;
typedef bit                        ccp_cache_evict_rdy_t;

typedef bit                        ccp_cache_rdrsp_vld_t;
typedef bit [WCCPDATA-1:0]         ccp_cache_rdrsp_data_t;
typedef bit [WCCPBYTEEN-1:0]       ccp_cache_rdrsp_byten_t;
typedef bit                        ccp_cache_rdrsp_last_t;
typedef bit                        ccp_cache_rdrsp_cancel_t;
typedef bit                        ccp_cache_rdrsp_rdy_t;


typedef bit [WCCPBANKBIT-1:0]      ccp_ctrlop_bank_t;
typedef bit [WCCPADDR-1:0]         ccp_ctrlop_addr_t;
typedef bit [WCCPSECURITY-1:0]     ccp_ctrlop_security_t;
typedef bit [WCCPBANKBIT-1:0]      ccp_ctrlop_rdy_t;
typedef bit                        ccp_ctrlop_allocate_t;
typedef bit                        ccp_ctrlop_rd_data_t;
typedef bit                        ccp_ctrlop_wr_data_t;
typedef bit                        ccp_ctrlop_port_sel_t;
typedef bit                        ccp_ctrlop_bypass_t;
typedef bit                        ccp_ctrlop_rp_update_t;
typedef bit                        ccp_ctrlop_cancel_t;
typedef bit                        ccp_ctrlop_tag_state_update_t;
typedef bit [WCCPBUSRTLN-1:0]      ccp_ctrlop_burstln_t;
typedef bit                        ccp_ctrlop_burstwrap_t;
typedef bit                        ccp_ctrlop_setway_debug_t;
typedef bit [<%=obj.DutInfo.nWays%>-1:0]            ccp_ctrlop_waybusy_vec_t;
typedef bit [<%=obj.DutInfo.nWays%>-1:0]            ccp_ctrlop_waystale_vec_t;
typedef bit [WCCPBANKBIT-1:0]      ccp_cacheop_rdy_t;
typedef bit                        ccp_cache_vld_t;
typedef bit [<%=obj.DutInfo.nWays%>-1:0]            ccp_cache_alloc_wayn_t;
typedef bit [<%=obj.DutInfo.nWays%>-1:0]            ccp_cache_hit_wayn_t;
typedef bit [<%=obj.DutInfo.nWays%>-1:0]            ccp_cache_wayn_t;
typedef bit                        ccp_cache_evictvld_t;
typedef bit [WCCPADDR-1:0]         ccp_cache_evictaddr_t;
typedef bit [WCCPSECURITY-1:0]     ccp_cache_evictsecurity_t;
typedef bit                        ccp_cache_nackuce_t;
typedef bit                        ccp_cache_nack_t;
typedef bit                        ccp_cache_nackce_t;
typedef bit                        ccp_cachenacknoalloc_t;
typedef bit                        ccp_cachenoways2alloc_t;

//scratchpad related data types
typedef logic [<%=obj.DutInfo.nDataBanks%>-1:0]                        ccp_sp_ctrl_rdy_logic_t;  
typedef logic [<%=obj.DutInfo.nDataBanks%>-1:0]                        ccp_sp_ctrl_vld_logic_t ;      
typedef logic                                                  ccp_sp_ctrl_wr_data_logic_t;
typedef logic                                                  ccp_sp_ctrl_rd_data_logic_t;  
typedef logic [$clog2(<%=obj.DutInfo.nSets%>/<%=obj.DutInfo.nDataBanks%>)-1:0] ccp_sp_ctrl_index_addr_logic_t;
typedef logic [$clog2(<%=obj.DutInfo.nDataBanks%>)-1:0]                ccp_sp_ctrl_data_bank_logic_t;
typedef logic [WCCPWAYS-1:0]                                   ccp_sp_ctrl_way_num_logic_t;
typedef logic [WCCPBEAT-1:0]                                   ccp_sp_ctrl_beat_num_logic_t; 
typedef logic [WCCPBUSRTLN-1:0]                                ccp_sp_ctrl_burst_len_logic_t;
typedef logic                                                  ccp_sp_ctrl_burst_type_logic_t;
typedef logic [WSMIMSG-1:0]                                    ccp_sp_ctrl_msg_type_logic_t;

typedef bit [<%=obj.DutInfo.nDataBanks%>-1:0]                        ccp_sp_ctrl_rdy_t;
typedef bit [<%=obj.DutInfo.nDataBanks%>-1:0]                        ccp_sp_ctrl_vld_t;      
typedef bit                                                  ccp_sp_ctrl_wr_data_t;
typedef bit                                                  ccp_sp_ctrl_rd_data_t;  
typedef bit [$clog2(<%=obj.DutInfo.nSets%>/<%=obj.DutInfo.nDataBanks%>)-1:0] ccp_sp_ctrl_index_addr_t;
typedef bit [$clog2(<%=obj.DutInfo.nDataBanks%>)-1:0]                ccp_sp_ctrl_data_bank_t;
typedef bit [WCCPWAYS-1:0]                                   ccp_sp_ctrl_way_num_t;
typedef bit [WCCPBEAT-1:0]                                   ccp_sp_ctrl_beat_num_t; 
typedef bit [WCCPBUSRTLN-1:0]                                ccp_sp_ctrl_burst_len_t;
typedef bit                                                  ccp_sp_ctrl_burst_type_t;
typedef bit [WSMIMSG-1:0]                                    ccp_sp_ctrl_msg_type_t;


typedef bit [WCSRDATA-1:0]         csr_maint_wrdata_t;
typedef bit [WCSRDATA-1:0]         csr_maint_rddata_t;
typedef bit [WCSRDATA-1:0]         csr_maint_req_data_t;
typedef bit [WCSROP-1:0]           csr_maint_req_opc_t;
typedef bit [WCSRWAY-1:0]          csr_maint_req_way_t;
typedef bit [WCSRENTRY-1:0]        csr_maint_req_entry_t;
typedef bit [WCSRWORD-1:0]         csr_maint_req_word_t;
typedef bit [WCCPARRAYSEL-1:0]     csr_maint_req_array_sel_t;
typedef bit                        csr_maint_active_t;
typedef bit                        csr_maint_rddata_en_t;
  
typedef enum bit [3:0] { READ,
                         WRITE,
                         SNOOP,
                         EVICT,
                         READ_FILL,
                         WRITE_FILL,
                         READ_DATA,
                         SNOOP_DATA,
                         MNT_OP,
                         NONE} cbi_cmdtype_t;

 <%     if(obj.Block !=='dmi') { %>
//typedef enum  bit [WCCPCACHESTATE-1:0]{ 
//                                      IX,SC,UC,UD
//                                      } ccp_cachestate_enum_t;
//DCTODO CCPCHK make these encodings configurable?
<%if(obj.DutInfo.fnCacheStates == "MOESI") { %>
typedef enum  bit [WCCPCACHESTATE-1:0]{ 
					IX = 3'h0,
					SC = 3'h1,
					SD = 3'h3,
					UC = 3'h5,
					UD = 3'h7
                                      } ccp_cachestate_enum_t;
<% } else { %>
typedef enum  bit [WCCPCACHESTATE-1:0]{ 
					IX = 3'h0,
					SC = 3'h1,
					SD = 3'h3,
					UC = 3'h5,
					UD = 3'h7
                                      } ccp_cachestate_enum_t;
<% } %>
 <% } else { %>
typedef enum  bit [WCCPCACHESTATE-1:0]{ 
                                      IX,SC,UD
                                      } ccp_cachestate_enum_t;

 <% } %>
typedef enum  bit  { 
                    NRU,RAND
                    } ccp_Rep_policy_enum_t;


typedef enum  int  { RD,
                     RDALLOC,
                     WR,
                     WRALLOC,
                     WRSYS,
                     INVL,
                     RDINVL,
                     RDSNP,
                     RDCLNSNP,
                     WRSNP
                    } ccp_ctrlop_type_enum_t;



typedef logic [WCCPDATA_IF-1:0]      ccp_ctrlwr_data_logic_t;
typedef logic                        ccp_ctrlwr_vld_logic_t;
typedef logic [WCCPBYTEEN-1:0]       ccp_ctrlwr_byten_logic_t;
typedef logic [WCCPBEAT-1:0]         ccp_ctrlwr_beatn_logic_t;
typedef logic                        ccp_ctrlwr_last_logic_t;
typedef logic                        ccp_cachewr_rdy_logic_t;


typedef logic                        ccp_ctrlfilldata_vld_logic_t;
typedef logic                        ccp_ctrlfilldata_scratchpad_t;
typedef logic [WCCPDATA_IF-1:0]      ccp_ctrlfill_data_logic_t;
typedef logic [WCCPFILLID-1:0]       ccp_ctrlfilldata_Id_logic_t;
typedef logic [WCCPADDR-1:0]         ccp_ctrlfilldata_addr_logic_t;
typedef logic [WCCPWAYS-1:0]         ccp_ctrlfilldata_wayn_logic_t;
typedef logic [WCCPBEAT-1:0]         ccp_ctrlfilldata_beatn_logic_t;
typedef logic [WCCPBYTEEN-1:0]       ccp_ctrlfilldata_byten_logic_t;
typedef logic                        ccp_ctrlfilldata_last_logic_t;
//CONC-15425::CONC-15710 - Fill Interface udpdate: Adding Fill data full signal to the Fill Data Interafce
typedef logic                        ccp_ctrlfilldata_full_logic_t;
typedef logic                        ccp_cachefilldata_rdy_logic_t;
typedef logic                        ccp_ctrlfill_vld_logic_t;
typedef logic [WCCPADDR-1:0]         ccp_ctrlfill_addr_logic_t;
typedef logic [WCCPWAYS-1:0]         ccp_ctrlfill_wayn_logic_t;
typedef logic [WCCPSECURITY-1:0]     ccp_ctrlfill_security_logic_t;
typedef logic [WCCPCACHESTATE-1:0]   ccp_ctrlfill_state_logic_t;
typedef logic                        ccp_cachefill_rdy_logic_t;
typedef logic [WCCPFILLDONEID-1:0]   ccp_cachefill_doneId_logic_t;
typedef logic                        ccp_cachefill_done_logic_t;

typedef logic                        ccp_cache_evict_vld_logic_t;
typedef logic [WCCPDATA_IF-1:0]      ccp_cache_evict_data_logic_t;
typedef logic [WCCPBYTEEN-1:0]       ccp_cache_evict_byten_logic_t;
typedef logic                        ccp_cache_evict_last_logic_t;
typedef logic                        ccp_cache_evict_cancel_logic_t;
typedef logic                        ccp_cache_evict_rdy_logic_t;

typedef logic                        ccp_cache_rdrsp_vld_logic_t;
typedef logic [WCCPDATA_IF-1:0]      ccp_cache_rdrsp_data_logic_t;
typedef logic [WCCPBYTEEN-1:0]       ccp_cache_rdrsp_byten_logic_t;
typedef logic                        ccp_cache_rdrsp_last_logic_t;
typedef logic                        ccp_cache_rdrsp_cancel_logic_t;
typedef logic                        ccp_cache_rdrsp_rdy_logic_t;

typedef logic [WCCPBANKBIT-1:0]      ccp_ctrlop_vld_logic_t;
typedef logic [WCCPADDR-1:0]         ccp_ctrlop_addr_logic_t;
typedef logic [WCCPSECURITY-1:0]     ccp_ctrlop_security_logic_t;
typedef logic [WCCPBANKBIT-1:0]      ccp_ctrlop_rdy_logic_t;
typedef logic                        ccp_ctrlop_allocate_logic_t;
typedef logic                        ccp_ctrlop_rd_data_logic_t;
typedef logic                        ccp_ctrlop_wr_data_logic_t;
typedef logic                        ccp_ctrlop_port_sel_logic_t;
typedef logic                        ccp_ctrlop_bypass_logic_t;
typedef logic                        ccp_ctrlop_rp_update_logic_t;
typedef logic                        ccp_ctrlop_tagstateup_logic_t;
typedef logic [WCCPBUSRTLN-1:0]      ccp_ctrlop_burstln_logic_t;
typedef logic                        ccp_ctrlop_burstwrap_logic_t;
typedef logic                        ccp_ctrlop_setway_debug_logic_t;
typedef logic [<%=obj.DutInfo.nWays%>-1:0]            ccp_ctrlop_waybusy_vec_logic_t;
typedef logic [<%=obj.DutInfo.nWays%>-1:0]            ccp_ctrlop_waystale_vec_logic_t;
typedef logic [WCCPBANKBIT-1:0]      ccp_cacheop_rdy_logic_t;
typedef logic                        ccp_cache_vld_logic_t;
typedef logic [<%=obj.DutInfo.nWays%>-1:0]            ccp_cache_alloc_wayn_logic_t;
typedef logic [<%=obj.DutInfo.nWays%>-1:0]            ccp_cache_nru_vec_logic_t;
typedef logic [<%=obj.DutInfo.nWays%>-1:0]            ccp_cache_hit_wayn_logic_t;
typedef logic                        ccp_cache_evictvld_logic_t;
typedef logic [WCCPADDR-1:0]         ccp_cache_evictaddr_logic_t;
typedef logic [WCCPSECURITY-1:0]     ccp_cache_evictsecurity_logic_t;
typedef logic                        ccp_cache_nackuce_logic_t;
typedef logic                        ccp_cache_nack_logic_t;
typedef logic                        ccp_cache_nackce_logic_t;
typedef logic                        ccp_cachenacknoalloc_logic_t;
typedef logic                        ccp_cachenoways2alloc_logic_t;

typedef logic [WCSRDATA-1:0]         csr_maint_wrdata_logic_t;
typedef logic [WCSRDATA-1:0]         csr_maint_req_data_logic_t;
typedef logic [WCSRDATA-1:0]         csr_maint_rddata_logic_t;
typedef logic [WCSROP-1:0]           csr_maint_req_opc_logic_t;
typedef logic [WCSRWAY-1:0]          csr_maint_req_way_logic_t;
typedef logic [WCSRENTRY-1:0]        csr_maint_req_entry_logic_t;
typedef logic [WCSRWORD-1:0]         csr_maint_req_word_logic_t;
typedef logic [WCCPARRAYSEL-1:0]     csr_maint_req_array_sel_logic_t;
typedef logic                        csr_maint_active_logic_t;
typedef logic                        csr_maint_rddata_en_logic_t;

typedef logic [WCCPCACHESTATE-1:0]   ccp_cachestate_logic_t; 
typedef enum  bit [3:0] { NOP                   = 4'b0000,
                          BYPASSWRTORDP         = 4'b0001,
                          BYPASSWRTOEVCTP       = 4'b0011,
                          WRDATATOARRAY         = 4'b0100,
                          WRDATATOARRAYANDRDP   = 4'b0101,
                          WRDATATOARRAY1        = 4'b0110,
                          WRDATATOARRAYANDEVCTP = 4'b0111,
                          RDDATATORDP           = 4'b1000,
                          RDDATATOEVCTP         = 4'b1010,
                         //RDDATAEVCTBYWRTORDRSP = 4'b1001,
                         //RDDATAEVCTBYWRTOEVCTP = 4'b1011,
                          WRTOANDRDTOEVCT       = 4'b1100,
                          WRTOANDRDTOEVCT1      = 4'b1110} ctrlopcmd_enum_t;


`ifdef INCA

     class fill_addr_inflight_t;
                   bit                       fillctrl;
                   bit                       filldata;
                   int                       index;
                   ccp_ctrlfill_security_t   secu;
                   ccp_ctrlfilldata_Id_t     Id;
                   ccp_ctrlfill_wayn_logic_t wayn;
                   ccp_ctrlfilldata_addr_t   addr;
     endclass: fill_addr_inflight_t       

`else
    typedef struct {
                   bit                       fillctrl;
                   bit                       filldata;
                   int                       index;
                   ccp_ctrlfill_security_t   secu;
                   ccp_ctrlfilldata_Id_t     Id;
                   ccp_ctrlfill_wayn_logic_t wayn;
                   ccp_ctrlfilldata_addr_t   addr;
                  
                   } fill_addr_inflight_t; 
`endif

typedef struct {
               int              indx;
              // ccp_ctrlop_security_t           secu;
               ccp_ctrlop_waybusy_vec_logic_t wayn;
               } busy_index_way_t; 
typedef struct {
               rand ccp_ctrlop_addr_t     addr;
               rand ccp_ctrlop_security_t secu;
              
               } ctrlop_addr_t; 







 
