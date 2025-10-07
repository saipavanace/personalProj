//////////////////////////////////////////////////////////////////////////////////
//This is the new dmi_coverage file. This will replace the old dmi_coverage file//
/////////////////////////////////////////////////////////////////////////////////
 <%
     var wRegion          = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wRegion    ;
     var wAwUser          = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wAwUser    ;
     var wArUser          = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wArUser    ;
     var wWUser           = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wWUser     ;
     var wBUser           = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wBUser     ;
     var wRUser           = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wRUser     ;
     var wQos             = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wQos       ;
     var wProt            = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wProt      ;
     var wLock            = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wLock      ;
     var ccp_wAddr        = obj.DmiInfo[obj.Id].ccpParams.wAddr;
     var secsubrows_sum = 0;
     var hasBitsIndx = function(SecSubRow) {
       var idx = 0 ;
       var base_idx = 0;
       var bval;
       var hasBitsq = [];
       var bit_array = Array.from(SecSubRow.replace("'h",""));
       //JS can't handle > 32bit strip into array and parse per nibble
       for(itr= bit_array.length-1; itr >=0; itr--) {
         base_idx = (bit_array.length-itr-1) * 4;
         var nibble = parseInt(bit_array[itr],16);
         idx =0;
         while(nibble > 0 ){
           bval = nibble & 1;
           if(bval == 1){
             hasBitsq.push(base_idx+idx);
           }
           idx+=1;
           nibble = nibble >>> 1;
           secsubrows_sum++;
         }
       }
       return hasBitsq;
     };
     
     //Abstrached Mehod for reading any General selection algorithm table
     var getSelectionInfo = function(bundle, num_entries, strName) {
         //console.log('primbits ' + bundle.PriSubDiagAddrBits.length);
         return({
             'nEntries' : num_entries,
             'nResorcs' : bundle.PriSubDiagAddrBits.length,
             'primBits' : bundle.PriSubDiagAddrBits,
             'hashBits' : Object.keys(bundle.SecSubRows).map(function(indx) {
                              return hasBitsIndx(bundle.SecSubRows[indx]);
                          }),
             'strInfo'  : strName
         });
     };
     
     //If there is no setSelection for that agent then to avoid messing up
     //logical Id count this method is called
     var emptySelection = function(strName) {
         return({
             'nEntries' : 0,
             'nResorcs' : 0,
             'primBits' : [],
             'hashBits' : [],
             'strInfo'  : strName
         });
     };

     var cmcCache = [];
     obj.DmiInfo.forEach(function(bundle, indx) {
       if(indx == obj.Id){
             if(bundle.useCmc) {
                 cmcCache.push(getSelectionInfo(bundle.ccpParams,
                                                bundle.ccpParams.nSets, 
                                                ("CMC" + indx)));
             } else {
                 cmcCache.push(emptySelection("CMC" + indx));
             }
       }
     });
   %>

class dmi_coverage;

    dmi_scb_txn                                             rtt_cov_q[$];
    dmi_scb_txn                                             wtt_cov_q[$];
    
    //variables related to axi coverage
    time                                                    t_wr_addr, t_wr_data; 
    enum {ignore0, ar, aw}                                  axi_msg_type;
    axi_awid_t                                              awid;
    axi_arid_t                                              arid;
    <% if (wRegion==0) { %>
    axi_axregion_t                                          arregion, awregion;
    <% } %>
    axi_bresp_t                                             bresp;
    axi_rresp_t                                             rresp_per_beat;
    axi_buser_t                                             buser;
    bit [$clog2(SYS_nSysCacheline/(WXDATA/8))-1:0]          beat_num; // DMI will not do multi cacheline access
    bit                                                     addr_trans_hit;

    smi_msg_type_bit_t                                      smi_msg_type;
    smi_ns_t                                                smi_ns;
    smi_ac_t                                                smi_ac;
    smi_pr_t                                                smi_pr;
    smi_rl_t                                                smi_rl;
    smi_tm_t                                                smi_tm;
    smi_size_t                                              smi_size;
    smi_intfsize_t                                          smi_intfsize;
    smi_ncore_unit_id_bit_t                                 dce_src_ncore_unit_id;
    smi_ncore_unit_id_bit_t                                 dtr_targ_ncore_unit_id;
    smi_msg_id_bit_t                                        dtr_rmsg_id;
    smi_qos_t                                               smi_qos;
    smi_msg_pri_bit_t                                       smi_msg_pri;
    smi_msg_id_bit_t                                        smi_msg_id;
    smi_addr_t                                              cache_addr; 
    bit [$clog2(SYS_nSysCacheline/(WXDATA/8))-1:0]          beat_access;    //beat_num
    smi_msg_user_bit_t                                      smi_msg_user;
    smi_cmstatus_t                                          smi_cmstatus; 
    int                                                     find_q[$];
    smi_msg_type_bit_t                                      smi_msg_type_prev;
    smi_msg_type_bit_t                                      dtw_msg_type_prev;
    int                                                     find_ncRd_cohRd_q[$]; 
    int                                                     find_ncRd_cohWr_q[$];
    int                                                     find_ncWr_cohRd_q[$];
    int                                                     find_ncWr_cohWr_q[$];
    int                                                     find_cohRd_ncRd_q[$];
    int                                                     find_cohRd_ncWr_q[$];
    int                                                     find_cohWr_ncRd_q[$];
    int                                                     find_cohWr_ncWr_q[$];
    int                                                     find_dtw_data_ptl[$];
    int                                                     find_dtw_data_cln[$];
    int                                                     find_dtw_data_dty[$];
    int                                                     find_dtw_no_data[$];
    smi_seq_item                                            smi_txn_q[$];
    smi_seq_item                                            smi_txn_q1[$];
    smi_seq_item                                            rbreq_dtw_q[$];
    smi_msg_type_bit_t                                      dtw_msg_type;
    smi_seq_item                                            matched_cmd_req_item;
    smi_seq_item                                            matched_rb_req_item;
    bit                                                     same_addr_diff_ns;
    bit                                                     mrd_dtw_data_ptl_same_addr_ns;
    bit                                                     mrd_dtw_data_dty_same_addr_ns;
    bit                                                     mrd_dtw_data_cln_same_addr_ns;
    bit                                                     mrd_dtw_no_data_same_addr_ns;
    enum {  ignore1,
            ncRd_cohRd,
            ncRd_cohWr,
            ncWr_cohRd,
            ncWr_cohWr,
            cohRd_ncRd,
            cohRd_ncWr,
            cohWr_ncRd,
            cohWr_ncWr} coh_nc_txn_same_addr;
    bit                                                     isSmiMsg_cmd;
    int                                                     cmd_beatn;
    smi_seq_item                                            smi_prev_txn;
    enum {  ignore2,
            same_src_rd_after_rd,
            same_src_wr_after_wr,
            same_src_wr_after_rd,
            same_src_rd_after_wr,
            diff_src_rd_after_rd,
            diff_src_wr_after_wr,
            diff_src_wr_after_rd,
            diff_src_rd_after_wr} backtobackrdwr;
    enum {  ignore5,
            inorder,
            notinorder} ncwrdtworder;
    smi_seq_item                                            smi_txn_cmd;
    smi_seq_item                                            smi_txn_str;
    enum {  ignore7,
            sp_base_addr_lower,
            sp_base_addr,
            sp_base_addr_high,
            sp_max_addr_lower,
            sp_max_addr,
            sp_max_addr_high} spaddr_edges;
    smi_addr_t                                              k_sp_base_addr;
    smi_addr_t                                              k_sp_max_addr;
    int                                                     spaddr_index, sp_ways;
    int                     MrdInflight_cnt;
    bit                     rd_atomic_hit_rtt;
    bit                     wr_atomic_hit_rtt;
    bit                     sw_atomic_hit_rtt;
    bit                     cmp_atomic_hit_rtt;

    bit [31:0]              nDCE_RBentries;

    bit [5:0]                           cmc_policy; 
    bit                                 isSpTxn;                                  
    <% if(obj.DutInfo.useCmc) { %>
    ccp_cachestate_enum_t               cache_state;
    <% } %>
    smi_msg_type_bit_t                  rtt_txn_msg_type;
    enum {  ignore4,
            dtr_data_shr_cln__mrd_rd_with_shr_cln,
            dtr_data_unq_cln__mrd_rd_with_unq_cln,
            dtr_data_unq_cln__mrd_rd_with_unq,
            dtr_data_unq_dty__mrd_rd_with_unq,
            dtr_data_inv__mrd_rd_with_inv,
            dtr_data_inv__cmd_nc_rd}    dtrType_mrdType_ncRd;
    bit                                 dtwmrgmrd_alloc_valid;
    bit                                 isAtomicCmp_match;

    dmi_scb_txn                         m_scb_txn;
    smi_rbid_t                          smi_rbid;
    bit                                 isNcWr, isCoh;
    smi_prim_t                          smi_prim;
    enum {ignore3,
          dtw_data_cln__cmd_wr_nc_full,
          dtw_data_dty__cmd_wr_nc_full,
          dtw_data_ptl__cmd_wr_nc_ptl,
          dtw_no_data__cmd_wr_nc_ptl}   dtwType_ncWr;
    bit                                 waybusy; 
    bit                                 dtwmrgmrd_noalloc_valid_cache_miss;
    bit                                 dtwmrgmrd_noalloc_valid_waysbusy;
    bit                                 dtwmrgmrd_hit_valid;
    bit                                 dtwprotocolflow_match;
    bit                                 dtwmrgmrd_protocolflow_match;
    bit                                 isCacheHit;
    bit [31:0]                          rbBaseValue;  // Used for DMI deadlock due to RB credit allocated by DCE: 
    enum {  dtw_first,
            rbreq_first,
            same_time} rbreq_dtw_seq;
    bit                                 rbreq_dtw_seq_valid;
    enum {  dtw_01_match,
            dtw_1_match} mw_dtw_seq;
    bit                                 mw_dtw_seq_valid;
    enum {  rbrreq_before_rbrsp,
            rbrreq_after_rbrsp} rbresrelorder;
    bit                                 rbresrelorder_valid;
    bit                                 rbresrelrbid_hit;
    enum {  ignore6,
            addr_before_data,
            data_before_addr,
            addr_with_data} axi_wr_seq;

    bit                                 mrd_flush_hit_wtt;
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
    bit                                 rd_atomic_hit_wtt;
    bit                                 wr_atomic_hit_wtt;
    bit                                 sw_atomic_hit_wtt;
    bit                                 cmp_atomic_hit_wtt;
    <% } %>
    
    bit                                 evict_vld_alloc_hit;

    bit                                 alloc_en;
    bit [4:0]                           alloc_csr;

    int                                 cycle_valid_sp_ctrl_pkt;
    int                                 cycle_valid_ccp_ctrl_pkt;
    bit                                 sp_cache_access_back_to_back;

    bit                                 SpTxn;

    bit [3:0]                           mask;
    bit                                 found;
    int                                 idx;

    bit [7:0]                           wtt_qosrsv, rtt_qosrsv;
    bit [3:0]                           qosth;
    int                                 mntBeat, mntWord;
    int                                 pri_bits, sec_bits;
    smi_msg_type_logic_t                atomic_cmdtype; 
    int                                 atomic_outcome;
    bit[2:0]                            atomic_mpf1_opcode;
    int                                 plru_set_index;
    <% if(obj.DutInfo.useCmc) { %>
    bit [N_CCP_WAYS-1:0]                plru_victim_way;
    <% } %>
    bit                                 sp_intrlv_en, amif_function;
    int                                 amig_set, amif_way,sp_full; 
    
    <% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM" || obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
     bit      err_overflow;
     bit      err_mission_fault;
     bit[7:0] err_threshold;
     bit      err_type; //C:0 or UC:1
     bit[3:0] err_location; 
    <% } %>
    function smi_addr_t cl_aligned(smi_addr_t addr);
        smi_addr_t cl_aligned_addr;
        cl_aligned_addr = (addr >> $clog2(SYS_nSysCacheline));
        return cl_aligned_addr;
    endfunction // cl_aligned

    //These functions are called from dmi scoreboard. They sample the covergroups
    extern function void collect_axi_write_addr_pkt(axi4_write_addr_pkt_t txn);
    extern function void collect_axi_write_data_pkt(axi4_write_data_pkt_t txn);
    extern function void collect_axi_write_resp_pkt(axi4_write_resp_pkt_t txn);
    extern function void collect_axi_read_addr_pkt(axi4_read_addr_pkt_t txn);
    extern function void collect_axi_read_data_pkt(axi4_read_data_pkt_t txn);
    extern function void collect_smi_seq_item(smi_seq_item m_pkt);
    extern function void collect_rtt_entry(dmi_scb_txn txn);
    extern function void collect_wtt_entry(dmi_scb_txn txn);
    extern function void collect_rd_inflight(dmi_scb_txn rtt_q[], smi_seq_item txn);
    extern function void collect_wr_inflight(dmi_scb_txn wtt_q[], smi_seq_item txn);
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
    extern function void collect_atomic_rw_semantics(smi_msg_type_logic_t m_cmdtype, bit[3:0] m_opcode, bit m_outcome);
    <% }%>
    <% if(obj.DutInfo.useCmc) { %>
    extern function void collect_CMO_entry(bit [5:0] word);
    extern function void collect_ccp_ctrl_pkt(ccp_ctrl_pkt_t txn);
    extern function void collect_ccp_evict_addr(ccp_ctrl_pkt_t txn);
    <%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
    extern function void collect_ccp_plru_eviction(int m_victim, int m_set_index);
    <% }%>
    extern function void collect_ccp_rd_inflight(dmi_scb_txn rtt_q[], ccp_ctrl_pkt_t txn);
    extern function void collect_ccp_wr_inflight(dmi_scb_txn wtt_q[], ccp_ctrl_pkt_t txn);
    extern function void collect_ccp_alloc_field(bit alloc_en, bit ClnWrAllocDisable, bit DtyWrAllocDisable, bit RdAllocDisable, bit WrAllocDisable, bit WrDataClnPropagateEn);
    <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
    extern function void collect_sp_ctrl_pkt(ccp_sp_ctrl_pkt_t txn);
    extern function void collect_sp_pgm(bit en, func, int set,way);
    extern function void collect_sp_occupancy(bit hit);
    <%}%>
    <% } %>
    <% if ( (obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys") ) { %>
    extern function void collect_addrtrans_pkt(bit [31:0] addrTransV[4], bit [3:0] mask, bit found, int idx);
    <% } %>
    <% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM" || obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
    extern function void collect_skidbuf_CE_stats(bit overflow, bit[7:0] threshold, bit [3:0] location);
    extern function void collect_skidbuf_UCE_stats(bit [3:0] location, bit mission_fault);
    <% } %>
    <% if(obj.DmiInfo[obj.Id].fnEnableQos) { %>
    extern function void collect_dmiutqoscr_reg_cov(bit[7:0] wtt_qosrsv, bit [7:0] rtt_qosrsv, bit [3:0] qosth);
    <% } %>
    extern function new();

    // Covergroups

    covergroup axi_write_addr;
       
        // #Cover.DMI.axi_txn_type
        axi_txn_type: coverpoint axi_msg_type {
            bins write = {aw};
        }

        // #Cover.DMI.aw.Awid
        write_addr_id: coverpoint awid;

        <%if (wRegion==0){%>
        // #Cover.DMI.aw.Awregion
        write_addr_region: coverpoint awregion{         // tied to zero
            type_option.weight  = 0;
            type_option.goal    = 0;
            option.weight       = 0;
            option.goal         = 0;
        }
        <% } %>
        
    endgroup : axi_write_addr

    covergroup axi_write_resp; 
        <%if(wBUser>0) { %>
        // #Cover.DMI.b.buser
        user_signal: coverpoint buser;
        <%}%>
        // #Cover.DMI.b.bresp
        write_resp: coverpoint bresp {
            bins okay   = {OKAY};
            bins exokay = {EXOKAY};
            bins slverr = {SLVERR};
            bins decerr = {DECERR};
        }

    endgroup : axi_write_resp

    covergroup axi_read_addr();
       
        // #Cover.DMI.axi_txn_type
        axi_txn_type: coverpoint axi_msg_type {
            bins read = {ar};
        }

        // #Cover.DMI.ar.Arid
        read_addr_id: coverpoint arid[WSMIMPF2-2:0]{
            option.auto_bin_max = 8;
        }
        
        <%if (wRegion==0){%>
        // #Cover.DMI.ar.Arregion
        read_addr_region: coverpoint arregion{  // tied to zero
            type_option.weight  = 0;
            type_option.goal    = 0;
            option.weight       = 0;
            option.goal         = 0;
        }
        <% } %>

    endgroup : axi_read_addr

    covergroup axi_read_data;
        
        // #Cover.DMI.r.rresp_per_beat
        read_resp: coverpoint rresp_per_beat {
            bins okay   = {OKAY};
            bins exokay = {EXOKAY};
            bins slverr = {SLVERR};
            bins decerr = {DECERR};
        }

        // #CoverCross.DMI.r.rresp_per_beat_cross_beat_num
        cross_read_resp_beat_num: cross read_resp, beat_num;

    endgroup : axi_read_data    

    <% if(obj.DutInfo.useCmc) { %>
    covergroup cmo_mntop;
      //#Cover.DMI.Concerto.v3.6.WordLookup
      beats : coverpoint mntBeat {
        bins b[] = {[0:((512/<%=obj.DmiInfo[obj.Id].ccpParams.wData%>)/<%=obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank%>)-1]} ;
      }
      words : coverpoint mntWord {
        <% if(obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2 && obj.DmiInfo[obj.Id].ccpParams.wData == 256) { %>  
        bins w[] = {[0:<%=(512/obj.DmiInfo[obj.Id].ccpParams.wData)%>*8]};
        <%} else {%>
        bins w[] = {[0:<%=(obj.DmiInfo[obj.Id].ccpParams.wData/32)%>]};
        <%}%>
      }
    endgroup: cmo_mntop
    <% } %>
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
    covergroup atomic_rw_semantics;
      action : coverpoint atomic_cmdtype{
        bins load  = {CMD_RD_ATM};
        bins store = {CMD_WR_ATM};
        bins compare = {CMD_CMP_ATM};
      }
      outcome : coverpoint atomic_outcome{
        //Outcome of atomic calculation
        bins o[2] = {[0:1]};
      }
      opcode : coverpoint atomic_mpf1_opcode{ 
        //CmdReq MPF1 special opcode argument for atomics
        bins t[8] = {[0:7]};
      }
      rw_action_x_outcome : cross action, outcome, opcode{
        ignore_bins ignore_cmp = binsof(action) intersect {CMD_CMP_ATM};
        //Add, Clear, Exclusive and Logical OR opcodes will always update memory
        ignore_bins always_update_mem = binsof(outcome) intersect {0} &&
                                         binsof(opcode) intersect {0,1,2,3};
      }
      swap_x_type : cross action, outcome{
        ignore_bins ignore_rw = binsof(action) intersect {CMD_RD_ATM,CMD_WR_ATM};
      }
    endgroup: atomic_rw_semantics
    <% } %>
    covergroup smi_transaction;

        //#Cover.DMI.Concerto.v3.0.DceunitId
        dce_src_id: coverpoint dce_src_ncore_unit_id {
        <%  for( var i=0;i<obj.DceInfo.length;i++) { %>
            bins src_id<%=i%> = {<%=obj.DceInfo[i].FUnitId%>};
        <% } %>
        }

        //#Cover.DMI.Concerto.v3.0.MrdmsgId
        msg_id : coverpoint smi_msg_id;

        <% if(obj.DmiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType != "none") { %>
        //#Cover.DMI.Concerto.v3.0.ReqHProt
        H_Protection: coverpoint smi_msg_user;
        <% } %>
        
        //#Check.DMI.Concerto.v3.0.MrdReqIntfSize
        rd_intf_size:coverpoint smi_intfsize{
          bins dword1 = {0};
          bins dword2 = {1};
          bins dword4 = {2};
          illegal_bins not_valid = {3};
        }

        // #Cover.DMI.Concerto.v3.0.MrdReqsize
        access_size: coverpoint smi_size {
            bins size0 = {0};
            bins size1 = {1};
            bins size2 = {2};
            bins size3 = {3};
            bins size4 = {4};
            bins size5 = {5};
            bins size6 = {6};
        }
        
        //#Cover.DMI.Concerto.v3.0.MrdReqAddr[5:0]
        addr_aligned :coverpoint cache_addr[5:0]{
            wildcard bins beat_0 = {6'b?????0,6'b?????1};
            wildcard bins beat_1 = {6'b?????0};
            wildcard bins beat_2 = {6'b????00};
            wildcard bins beat_3 = {6'b???000};
            wildcard bins beat_4 = {6'b??0000};
            wildcard bins beat_5 = {6'b?00000};
            wildcard bins beat_6 = {6'b000000};
        }

        //#Cover.DMI.Concerto.v3.0.MrdReqAddr(min,mid,max)
        addr_range :coverpoint cache_addr;

        //#Cover.DMI.Concerto.v3.0.MrdMsgType
        mrd_type:coverpoint smi_msg_type {
            bins mrd_rd_with_shr_cln = {MRD_RD_WITH_SHR_CLN};
            bins mrd_rd_with_unq_cln = {MRD_RD_WITH_UNQ_CLN};
            bins mrd_rd_with_unq     = {MRD_RD_WITH_UNQ};
            bins mrd_rd_with_inv     = {MRD_RD_WITH_INV};
        }

        rd_cmd_type:coverpoint smi_msg_type {
            bins mrd_rd_with_shr_cln = {MRD_RD_WITH_SHR_CLN};
            bins mrd_rd_with_unq_cln = {MRD_RD_WITH_UNQ_CLN};
            bins mrd_rd_with_unq     = {MRD_RD_WITH_UNQ};
            bins mrd_rd_with_inv     = {MRD_RD_WITH_INV};
            bins cmd_rd_nc           = {CMD_RD_NC};
        }

        Coh_Cmo_type:coverpoint smi_msg_type {
            bins mrd_cln     = {MRD_CLN};
            bins mrd_inv     = {MRD_INV};
            bins mrd_flush   = {MRD_FLUSH};
        }

        dce_cmd_type:coverpoint smi_msg_type{
            bins mrd_rd_with_shr_cln = {MRD_RD_WITH_SHR_CLN};
            bins mrd_rd_with_unq_cln = {MRD_RD_WITH_UNQ_CLN};
            bins mrd_rd_with_unq     = {MRD_RD_WITH_UNQ};
            bins mrd_rd_with_inv     = {MRD_RD_WITH_INV};
            bins mrd_cln             = {MRD_CLN};
            bins mrd_inv             = {MRD_INV};
            bins mrd_flush           = {MRD_FLUSH};
            bins mrd_pref            = {MRD_PREF};
            bins rb_req              = {RB_REQ};
        }

        // #Cover.DMI.v3.0.crossMrdwithAccessSize
        mrd_with_vld_access_size: cross mrd_type, access_size;

        mrd_req_dce_src :cross mrd_type,dce_src_id;

        cmo_req_dce_src :cross Coh_Cmo_type,dce_src_id;

        cmd_req_dce_msg_id :cross dce_cmd_type,msg_id;

        rd_cmd_type_Intf_size_access_size: cross rd_cmd_type,rd_intf_size,access_size;

        //#Cover.DMI.Concerto.v3.0.DtwMsgType
        dtw_type: coverpoint dtw_msg_type {
            bins dtw_no_data         = {DTW_NO_DATA};
            bins dtw_data_cln        = {DTW_DATA_CLN};
            bins dtw_data_dty        = {DTW_DATA_DTY};
            bins dtw_data_ptl        = {DTW_DATA_PTL};
        }

        // #Cover.DMI.v3.0.NonCohRdWr
        cmd_type: coverpoint smi_msg_type {
            bins cmd_rd_nc           = {CMD_RD_NC};
            bins cmd_wr_nc_ptl       = {CMD_WR_NC_PTL};
            bins cmd_wr_nc_full      = {CMD_WR_NC_FULL};
        }

        <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
        //#Cover.DMI.Concerto.v3.0.AtomicType
        atomic_type_access: coverpoint smi_msg_type {
            bins cmd_rd_atm          = {CMD_RD_ATM};
            bins cmd_wr_atm          = {CMD_WR_ATM};
            bins cmd_sw_atm          = {CMD_SW_ATM};
            bins cmd_cmp_atm         = {CMD_CMP_ATM};
        }

        // #Cover.DMI.v3.0.crossAtomicwithSize
        //#Cover.DMI.Concerto.v3.0.AtomicSize
        atomic_with_vld_access_size: cross atomic_type_access, access_size {
            ignore_bins ignore_cmp = binsof(atomic_type_access) intersect {CMD_CMP_ATM} &&
                                    binsof(access_size) intersect {0,6};
            ignore_bins ignore_other = binsof(atomic_type_access) intersect {CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM} &&
                                   binsof(access_size) intersect {4,5,6};
        }
        <% } %>

        // #Cover.DMI.v3.0.SecPrivTmAttribute
        sec_pri_tm_bit: coverpoint {smi_ns,smi_pr,smi_tm};

        resplevel: coverpoint smi_rl;

        // #Cover.DMI.Concerto.v3.0.MrdReqprivilege
        Privileged_access : coverpoint smi_pr;

        // #Cover.DMI.Concerto.v3.0.MrdSecurityAttribute
        Non_secure_access : coverpoint smi_ns;

        // #Cover.DMI.Concerto.v3.0.MrdRqTM
        CohCmd_type_with_sec_pri_tm: cross dce_cmd_type,sec_pri_tm_bit;/*{*/
            //ignore_bins ignore_rb_tm = CohCmd_type_with_sec_pri_tm with (dce_cmd_type==RB_REQ && sec_pri_tm_bit[0] == 1); //rbreq doesnt have smi_tm field
        //}

        NonCohcmd_type_with_sec_pri_tm: cross cmd_type,sec_pri_tm_bit;

        //#Check.DMI.Concerto.v3.0.MrdReqRL
        dce_cmd_type_with_rl: cross dce_cmd_type,resplevel{
            //illegal_bins not_validRbreq = binsof(dce_cmd_type.rb_req) && ! binsof(resplevel) intersect {2'b01};  rsplevel should be 'b10 according to the testplan 
            illegal_bins not_validRbreq = binsof(dce_cmd_type.rb_req) && ! binsof(resplevel) intersect {2'b10};
            illegal_bins not_validMrd = binsof(dce_cmd_type) intersect {MRD_RD_CLN,MRD_RD_WITH_SHR_CLN,MRD_RD_WITH_UNQ_CLN} && binsof(resplevel) intersect {2'b00,2'b10};
            illegal_bins not_validCohCmos = binsof(dce_cmd_type) intersect {MRD_FLUSH,MRD_CLN,MRD_INV}  && ! binsof(resplevel) intersect {2'b10};
            illegal_bins not_validMrdPerf = binsof(dce_cmd_type.mrd_pref) && ! binsof(resplevel) intersect {2'b01};
            ignore_bins ignore_mrd = binsof(dce_cmd_type) intersect {MRD_RD_WITH_UNQ, MRD_RD_WITH_INV} && binsof(resplevel) intersect {2'b11,2'b10,2'b00};
        }
        
        //#Cover.DMI.Concerto.v.3.MrdReqAiUIds
        dtr_aiu_id :coverpoint dtr_targ_ncore_unit_id {
            bins aiu_id[] = {[0:<%=obj.DmiInfo[obj.Id].nAius-1%>]};
        }

        //#Cover.DMI.Concerto.v3.3.MaxDtrInFlightperAius
        dtr_rmsg_id:coverpoint dtr_rmsg_id;

        mrd_type_dtr_aiu_id:cross mrd_type,dtr_aiu_id;

        <% if(obj.DmiInfo[obj.Id].fnEnableQos == 1) {%>
        smi_qos:coverpoint smi_qos;
            
        smi_priority:coverpoint smi_msg_pri;
        <% } %>

        <% if(obj.DmiInfo[obj.Id].fnEnableQos == 1) {%>
        //#Cover.DMI.Concerto.v3.0.MrdReqQos
        mrd_type_qos:cross mrd_type,smi_qos;
        <% } %>

        Mrd_type_reqsize_intfsize_addrallign:cross mrd_type,access_size,rd_intf_size,addr_aligned;

        <% if(obj.DmiInfo[obj.Id].useAtomic) {%>
        atm_type_with_sec_pri_tm: cross sec_pri_tm_bit, atomic_type_access;
        <% } %>

        // #Cover.DMI.v3.0.crossCmdSecurityattribute
        mrd_type_prev:coverpoint smi_msg_type_prev {
            bins mrd_rd_with_shr_cln = {MRD_RD_WITH_SHR_CLN};
            bins mrd_rd_with_unq_cln = {MRD_RD_WITH_UNQ_CLN};
            bins mrd_rd_with_unq     = {MRD_RD_WITH_UNQ};
            bins mrd_rd_with_inv     = {MRD_RD_WITH_INV};
        }

        dtw_type_prev: coverpoint dtw_msg_type_prev {
            bins dtw_no_data         = {DTW_NO_DATA};
            bins dtw_data_cln        = {DTW_DATA_CLN};
            bins dtw_data_dty        = {DTW_DATA_DTY};
            bins dtw_data_ptl        = {DTW_DATA_PTL};
        }

        cmd_type_prev: coverpoint smi_msg_type_prev {
            bins cmd_rd_nc           = {CMD_RD_NC};
            bins cmd_wr_nc_ptl       = {CMD_WR_NC_PTL};
            bins cmd_wr_nc_full      = {CMD_WR_NC_FULL};
        }

        <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
        atomic_type_access_prev: coverpoint smi_msg_type_prev {
            bins cmd_rd_atm          = {CMD_RD_ATM};
            bins cmd_wr_atm          = {CMD_WR_ATM};
            bins cmd_sw_atm          = {CMD_SW_ATM};
            bins cmd_cmp_atm         = {CMD_CMP_ATM};
        }
        <% } %>

        same_addr_diff_security_bit: coverpoint same_addr_diff_ns {
            bins cp_same_addr_diff_ns = {1};
        }
       
        all_mrd_mrd_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, mrd_type, mrd_type_prev;

        all_mrd_dtw_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, mrd_type, dtw_type_prev;

        all_mrd_cmd_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, mrd_type, cmd_type_prev;

        all_cmd_mrd_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, cmd_type, mrd_type_prev;

        all_cmd_dtw_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, cmd_type, dtw_type_prev;

        all_dtw_mrd_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, dtw_type, mrd_type_prev;

        all_dtw_dtw_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, dtw_type, dtw_type_prev;

        all_dtw_cmd_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, dtw_type, cmd_type_prev;

        <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
        all_cmd_atm_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, cmd_type, atomic_type_access_prev;

        all_cmd_cmd_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, cmd_type, cmd_type_prev;

        all_mrd_atm_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, mrd_type, atomic_type_access_prev;

        all_dtw_atm_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, dtw_type, atomic_type_access_prev;

        all_atm_mrd_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, atomic_type_access, mrd_type_prev;

        all_atm_dtw_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, atomic_type_access, dtw_type_prev;

        all_atm_cmd_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, atomic_type_access, cmd_type_prev;

        all_atm_atm_to_same_addr_diff_security_bit: cross same_addr_diff_security_bit, atomic_type_access, atomic_type_access_prev;
        <% } %>
       
        // #Cover.DMI.v3.0.DtwfollowedbyMrd
        mrd_after_dtw_data_ptl_to_same_addr_and_security_bit: coverpoint mrd_dtw_data_ptl_same_addr_ns {
            bins cp_mrd_dtw_data_ptl_same_addr_ns = {1};
        }
        all_mrd_after_dtw_data_ptl_to_same_addr_and_security_bit: cross mrd_after_dtw_data_ptl_to_same_addr_and_security_bit, mrd_type;
        mrd_after_dtw_data_dty_to_same_addr_and_security_bit: coverpoint mrd_dtw_data_dty_same_addr_ns {
            bins cp_mrd_dtw_data_dty_same_addr_ns = {1};
        }
        all_mrd_after_dtw_data_dty_to_same_addr_and_security_bit: cross mrd_after_dtw_data_dty_to_same_addr_and_security_bit, mrd_type;
        mrd_after_dtw_data_cln_to_same_addr_and_security_bit: coverpoint mrd_dtw_data_cln_same_addr_ns {
            bins cp_mrd_dtw_data_cln_same_addr_ns = {1};
        }
        all_mrd_after_dtw_data_cln_to_same_addr_and_security_bit: cross mrd_after_dtw_data_cln_to_same_addr_and_security_bit, mrd_type;
        mrd_after_dtw_no_data_to_same_addr_and_security_bit: coverpoint mrd_dtw_no_data_same_addr_ns {
            bins cp_mrd_dtw_no_data_same_addr_ns = {1};
        }
        all_mrd_after_dtw_no_data_to_same_addr_and_security_bit: cross mrd_after_dtw_no_data_to_same_addr_and_security_bit, mrd_type;

       // #Cover.DMI.v3.0.CohNcWrRdallpossibleorder
       // #Cover.DMI.Concerto.v3.0.CohNonCohAddrCollision
       // #Cover.DMI.Concerto.v3.0.NcCmdInflight
       // #Check.DMI.Concerto.v3.0.NcRdCollideNcWr
       coh_and_nc_txn_to_same_addr: coverpoint coh_nc_txn_same_addr{
            bins cp_ncRd_cohRd = {1};
            bins cp_ncRd_cohWr = {2};
            bins cp_ncWr_cohRd = {3};
            bins cp_ncWr_cohWr = {4};
            bins cp_cohRd_ncRd = {5};
            bins cp_cohRd_ncWr = {6};
            bins cp_cohWr_ncRd = {7};
            bins cp_cohWr_ncWr = {8};
        }
        
        // #Cover.DMI.v3.0.Cmdwithbeataligned
        beat_aligned_access: coverpoint beat_access;

        mrd_type_with_all_beat_aligned_access: cross mrd_type, beat_aligned_access;

        dtw_type_with_all_beat_aligned_access: cross dtw_type, beat_aligned_access{
            type_option.goal    = 0;    // dtw doesnot carry address field
            type_option.weight  = 0;
        }

        cmd_type_with_all_beat_aligned_access: cross cmd_type, beat_aligned_access;

        <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
        atm_type_with_all_beat_aligned_access: cross atomic_type_access, beat_aligned_access;
        <% } %>
        
        //#Cover.DMI.Concerto.v3.0.MrdReqallocate
        cache_allocate_attribute: coverpoint smi_ac;
        mrd_type_with_allocate_bit: cross cache_allocate_attribute, mrd_type;
        cmd_type_with_allocate_bit: cross cache_allocate_attribute, cmd_type;
        dtw_type_with_allocate_bit: cross cache_allocate_attribute, dtw_type{
            type_option.weight  = 0;   // dtw doesnt have ac field
            type_option.goal    = 0;
        }
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
        atm_type_with_allocate_bit: cross cache_allocate_attribute, atomic_type_access{
            ignore_bins ignore_no_allocate = atm_type_with_allocate_bit with (cache_allocate_attribute==0);
        }
    <% } %>

        cmd_smi_intfsize : coverpoint smi_intfsize iff(isSmiMsg_cmd == 1){
            bins intfsize_0 = {0};
            bins intfsize_1 = {1};
            bins intfsize_2 = {2};
        }

        cmd_smi_size : coverpoint smi_size iff(isSmiMsg_cmd == 1){
            bins size_0     = {0};
            bins size_1     = {1};
            bins size_2     = {2};
            bins size_3     = {3};
            bins size_4     = {4};
            bins size_5     = {5};
            bins size_6     = {6};
        }

       cmd_smi_beatn : coverpoint cmd_beatn iff(isSmiMsg_cmd == 1){
            bins beat_0     = {0};
            bins beat_1     = {1};
            bins beat_2     = {2};
            bins beat_3     = {3};
            bins beat_4     = {4};
            bins beat_5     = {5};
            bins beat_6     = {6};
            bins beat_7     = {7};
       }
        // #Cover.DMI.Concerto.v3.0.DataAdept
       data_adept : cross cmd_smi_intfsize, cmd_smi_beatn, cmd_smi_size iff(isSmiMsg_cmd == 1){
            //ignore_bins ignore_some_beat = data_adept with (beatn_cmd >= (512/(2**smi_intfsize)*64));
            ignore_bins ignore_intf2_beats = data_adept with (cmd_smi_intfsize==2 && cmd_smi_beatn > 1);
            ignore_bins ignore_intf1_beats = data_adept with (cmd_smi_intfsize==1 && cmd_smi_beatn > 3);
       }
 
        // #Cover.DMI.Concerto.v3.0.BacktoBckRdWr
        backtobackrdwr_cp : coverpoint backtobackrdwr {
           bins ignore                  = {ignore2};
           bins same_src_rd_after_rd    = {same_src_rd_after_rd};
           bins same_src_wr_after_wr    = {same_src_wr_after_wr};
           bins same_src_wr_after_rd    = {same_src_wr_after_rd};
           bins same_src_rd_after_wr    = {same_src_rd_after_wr};
           bins diff_src_rd_after_rd    = {diff_src_rd_after_rd};
           bins diff_src_wr_after_wr    = {diff_src_wr_after_wr};
           bins diff_src_wr_after_rd    = {diff_src_wr_after_rd};
           bins diff_src_rd_after_wr    = {diff_src_rd_after_wr};
        } 

        // #Cover.DMI.Concerto.v3.0.NcWrDtwOrder
        ncwrdtworder_cp : coverpoint ncwrdtworder {
            bins inorder        = {1};
            bins notinorder     = {2};
        }
       
        <% if(obj.DutInfo.useCmc) { %>
        <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
        // #Cover.DMI.Concerto.v3.0.spaddr_edges
        spaddr_edges : coverpoint spaddr_edges {
            bins sp_base_addr_lower = {sp_base_addr_lower};
            bins sp_base_addr       = {sp_base_addr};
            bins sp_base_addr_high  = {sp_base_addr_high};
            bins sp_max_addr_lower  = {sp_max_addr_lower};
            bins sp_max_addr        = {sp_max_addr};
            bins sp_max_addr_high   = {sp_max_addr_high};
        }
        <% } %>
        <% } %>

        // #Cover.DMI.Concerto.v3.0.backtobackmrds
        backtobackmrds : cross mrd_type, mrd_type_prev;

    endgroup : smi_transaction

    covergroup rd_inflight;
        
        //#Cover.DMI.Concerto.v3.0.maxMrdInflight
        MrdInflight:coverpoint MrdInflight_cnt{
            bins MrdInfcnt[] = {[1:<%=obj.DmiInfo[obj.Id].nMrdSkidBufSize%>]};
        }
        
        <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
        // #Cover.DMI.v3.0.AtomichitwithRTT
        rd_atomic_hit_with_rtt: coverpoint rd_atomic_hit_rtt {
            bins rd_atm_hit_rtt = {1};
        }

        wr_atomic_hit_with_rtt: coverpoint wr_atomic_hit_rtt {
            bins wr_atm_hit_rtt = {1};
        }

        sw_atomic_hit_with_rtt: coverpoint sw_atomic_hit_rtt {
            bins sw_atm_hit_rtt = {1};
        }

        cmp_atomic_hit_with_rtt: coverpoint cmp_atomic_hit_rtt {
            bins cmp_atm_hit_rtt = {1};
        }
        <% } %>

    endgroup : rd_inflight

    covergroup wr_inflight_cg;
       
        // #Cover.DMI.v3.0.MrdFlushhitwtt 
        mrdFlush_hit_with_wtt: coverpoint mrd_flush_hit_wtt {
            bins mrd_flush_hit = {1};
        }

        <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
        // #Cover.DMI.v3.0.AtomichitwithWtt
        rd_atomic_hit_with_wtt: coverpoint rd_atomic_hit_wtt {
            bins rd_atm_hit_wtt = {1};
        }
        wr_atomic_hit_with_wtt: coverpoint wr_atomic_hit_wtt {
            bins wr_atm_hit_wtt = {1};
        }
        sw_atomic_hit_with_wtt: coverpoint sw_atomic_hit_wtt {
            bins sw_atm_hit_wtt = {1};
        }
        cmp_tomic_hit_with_wtt: coverpoint cmp_atomic_hit_wtt {
            bins cmp_atm_hit_wtt = {1};
        }
        <% } %>
    endgroup : wr_inflight_cg

    covergroup wtt_entry_cg;
       
       //#Cover.DMI.Concerto.v3.0.DtwRbId
       //#Cover.DMI.Concerto.v3.0.DtwReqRbId
       coh_rbid: coverpoint smi_rbid[WSMIRBID-2:0] iff(isCoh) {
         //Consider covering non coherent RBID too
         bins cohrbid[] = {[0:<%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%>-1]};
       }

       coh_gid: coverpoint smi_rbid[WSMIRBID-1] iff(isCoh) {
         bins gid[] = {0,1};
       }

       //#Cover.DMI.Concerto.v3.6.RBusage
       gid_used : cross coh_gid, coh_rbid; 

        // #Cover.DMI.Concerto.v3.0.DtwPrim
        dtw_prim : coverpoint smi_prim iff(isNcWr == 1) {
            bins prim = {1};
        }

        // #Cover.DMI.v3.0.NcWrwithdtw
        dtwType_for_ncWr: coverpoint dtwType_ncWr {
             bins cp_dtw_data_cln__cmd_wr_nc_full = {1};
             bins cp_dtw_data_dty__cmd_wr_nc_full = {2};
             bins cp_dtw_data_ptl__cmd_wr_nc_ptl  = {3};
             bins cp_dtw_no_data__cmd_wr_nc_ptl   = {4};
        }

        // #Cover.DMI.Concerto.v3.0.DTWMrgMrdNoAlloc
        <% if(obj.DutInfo.useCmc) { %>
        dtwmrgmrd_noalloc_cp_cache_miss : coverpoint dtwmrgmrd_noalloc_valid_cache_miss {
            bins no_match   = {0};
            bins match      = {1};
        } 
        <% } %>

        <% if(obj.DutInfo.useCmc && (obj.DmiInfo[obj.Id].ccpParams.nWays < obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries)) { %>
         dtwmrgmrd_noalloc_cp_waysbusy : coverpoint dtwmrgmrd_noalloc_valid_waysbusy {
            bins no_match   = {0};
            bins match      = {1};
        }
        <% } %>

       <% if(obj.DutInfo.useCmc) { %>
        // #Cover.DMI.Concerto.v3.0.DTWMrgMrdHit
        dtwmrgmrd_hit_cp : coverpoint dtwmrgmrd_hit_valid {
            bins no_match   = {0};
            bins match      = {1};
        }
        <% } %>
        // #Cover.DMI.Concerto.v3.0.DTWProtocolFlow
        dtwprotocolflow_cp : coverpoint dtwprotocolflow_match {
            bins no_match   = {0};
            bins match      = {1};
        }

        // #Cover.DMI.Concerto.v3.0.DTWMrgMrdProtocolFlow
         dtwmrgmrd_protocolflow_cp : coverpoint dtwmrgmrd_protocolflow_match {
            bins no_match   = {0};
            bins match      = {1};
        }

        <% if(obj.DutInfo.useCmc) { %>
        // #Cover.DMI.v3.0.Cmdhitmiss
        cache_hit_miss: coverpoint isCacheHit;
        <% } %>
    
        // #Cover.DMI.Concerto.v3.0.RBreqDtwReqOrder 
        rbreq_dtw_seq_cp : coverpoint rbreq_dtw_seq iff(rbreq_dtw_seq_valid == 1){
            bins dtw_first      = {dtw_first};
            bins rbreq_first    = {rbreq_first};
            bins same_time      = {same_time};
        }
        
        // #Cover.DMI.Concerto.v3.0.MWwithDtw
        rbreq_mw_dtw_seq_cp : coverpoint mw_dtw_seq iff(mw_dtw_seq_valid == 1) {
            bins dtw_01_match   = {dtw_01_match};
            bins dtw_1_match    = {dtw_1_match};
        }
        
        //#Cover.DMI.Concerto.v3.0.DTWMrgMrdmisswithAlloc
        dtwmrgmrd_alloc_cp : coverpoint dtwmrgmrd_alloc_valid {
            bins no_match   = {0};
            bins match      = {1};
        }
         
        // #Cover.DMI.Concerto.v3.0.RbResRelOrder
        rbresrel_order_cp : coverpoint rbresrelorder iff(rbresrelorder_valid == 1) {
            bins rbrreq_before_rbrsp = {rbrreq_before_rbrsp};
            bins rbrreq_after_rbrsp = {rbrreq_after_rbrsp};
        }
        
        // #Cover.DMI.Concerto.v3.0.RbResRelRbid
        rbresrel_rbid_cp : coverpoint rbresrelrbid_hit {
            bins miss   = {0};
            bins hit    = {1};
        } 
    
        // #CoverTime.DMI.aw_w.Sequence
        write_addr_data_order: coverpoint axi_wr_seq {
            bins addr_before_data   = {1};
            bins data_before_addr   = {2};
            bins addr_with_data     = {3};
        }

    endgroup : wtt_entry_cg

    covergroup rtt_entry_cg;

        <% if(obj.DutInfo.useCmc) { %>
        // #Cover.DMI.v3.0.crossMrdFlushhitcache
        // #Cover.DMI.v3.0.crossAtomicwithcachestate
        hit_cache_state: coverpoint cache_state {
            bins mrd_flush_invalid        = {IX} iff (!isSpTxn && rtt_txn_msg_type == MRD_FLUSH);
            bins mrd_flush_shared_clean   = {SC} iff (!isSpTxn && rtt_txn_msg_type == MRD_FLUSH);
            bins mrd_flush_unique_dirty   = {UD} iff (!isSpTxn && rtt_txn_msg_type == MRD_FLUSH);
            <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
            bins cmd_rd_atm_invalid       = {IX} iff (!isSpTxn && rtt_txn_msg_type == CMD_RD_ATM);
            bins cmd_rd_atm_shared_clean  = {SC} iff (!isSpTxn && rtt_txn_msg_type == CMD_RD_ATM);
            bins cmd_rd_atm_unique_dirty  = {UD} iff (!isSpTxn && rtt_txn_msg_type == CMD_RD_ATM);
            bins cmd_wr_atm_invalid       = {IX} iff (!isSpTxn && rtt_txn_msg_type == CMD_WR_ATM);
            bins cmd_wr_atm_shared_clean  = {SC} iff (!isSpTxn && rtt_txn_msg_type == CMD_WR_ATM);
            bins cmd_wr_atm_unique_dirty  = {UD} iff (!isSpTxn && rtt_txn_msg_type == CMD_WR_ATM);
            bins cmd_sw_atm_invalid       = {IX} iff (!isSpTxn && rtt_txn_msg_type == CMD_SW_ATM);
            bins cmd_sw_atm_shared_clean  = {SC} iff (!isSpTxn && rtt_txn_msg_type == CMD_SW_ATM);
            bins cmd_sw_atm_unique_dirty  = {UD} iff (!isSpTxn && rtt_txn_msg_type == CMD_SW_ATM);
            bins cmd_cmp_atm_invalid      = {IX} iff (!isSpTxn && rtt_txn_msg_type == CMD_CMP_ATM);
            bins cmd_cmp_atm_shared_clean = {SC} iff (!isSpTxn && rtt_txn_msg_type == CMD_CMP_ATM);
            bins cmd_cmp_atm_unique_dirty = {UD} iff (!isSpTxn && rtt_txn_msg_type == CMD_CMP_ATM);
            <% } %>
        }
        <% } %>

        // #Cover.DMI.v3.0.CrossCohNcRdwithDTRtype
        dtrType_for_mrd_and_ncRd: coverpoint dtrType_mrdType_ncRd{
            bins cp_dtr_data_shr_cln__mrd_rd_with_shr_cln = {1};
            bins cp_dtr_data_unq_cln__mrd_rd_with_unq_cln = {2};
            bins cp_dtr_data_unq_cln__mrd_rd_with_unq     = {3};
            //bins cp_dtr_data_unq_dty__mrd_rd_with_unq     = {4}; //CONC-9065 DMI always returns DTR Data Unq Cln for MRd Rd with Unq
            bins cp_dtr_data_inv__mrd_rd_with_inv         = {5};
            bins cp_dtr_data_inv__cmd_nc_rd               = {6};
        }

        // #Cover.DMI.Concerto.v3.0.DTWMrgMrdmisswithalloc
        dtwmrgmrd_alloc_cp : coverpoint dtwmrgmrd_alloc_valid {
            bins no_match   = {0};
            bins match      = {1};
        }

        <% if(obj.DutInfo.useCmc) { %>
        // #Cover.DMI.Concerto.v3.0.DTWMrgMrdHit
        dtwmrgmrd_hit_cp : coverpoint dtwmrgmrd_hit_valid {
            bins no_match   = {0};
            bins match      = {1};
        }
        <% } %>

        // #Cover.DMI.Concerto.v3.0.DTWMrgMrdProtocolFlow
        dtwmrgmrd_protocolflow_cp : coverpoint dtwmrgmrd_protocolflow_match {
            bins no_match   = {0};
            bins match      = {1};
        }
        
        <% if(obj.DutInfo.useCmc) { %>
        <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
        atomiccmp_match : coverpoint isAtomicCmp_match;
        <% } %>
        <% } %>

        <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
        spaddr_occupancy : coverpoint spaddr_index {
          bins range[] = {[0:N_CCP_SETS*sp_ways]};
        }
        <% } %>
    endgroup : rtt_entry_cg

    <% if(obj.DutInfo.useCmc) { %>
    covergroup ccp_evict_addr_cg;
       
        // Evict with Alloc from SMC due to fix index addresses
        evict_vld_with_alloc_hit: coverpoint evict_vld_alloc_hit {
            bins evict_vld_alloc = {1};
        }

    endgroup : ccp_evict_addr_cg
    
    <%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
    covergroup ccp_plru_cg;
      //#Cover.DMI.Concerto.v3.6.EvictedWays
      evicted_way : coverpoint plru_victim_way {
        bins way[] = {[0:N_CCP_WAYS-1]};
      }
      set : coverpoint plru_set_index{
        bins s[3] = {[0:N_CCP_SETS]};
      }
      set_way : cross evicted_way, set;
    endgroup: ccp_plru_cg
    <% } %>

    // #Cover.DMI.Concerto.v3.0.CmcPolicyToggle
    covergroup cmc_alloc_cg;
        alloc_en : coverpoint alloc_en;
        clnWrAllocDisable : coverpoint alloc_csr[0];
        DtyWrAllocDisable : coverpoint alloc_csr[1];
        RdAllocDisable : coverpoint alloc_csr[2];
        WrAllocDisable : coverpoint alloc_csr[3];
        WrDataClnPropagateEn : coverpoint alloc_csr[4];
    endgroup : cmc_alloc_cg
//#Cover.DMI.Concerto.v3.0.spcacheaccess
    <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
    covergroup sp_cache_access_cg;
        sp_cache_access_back_to_back : coverpoint sp_cache_access_back_to_back;
    endgroup : sp_cache_access_cg

    covergroup sp_cg;
        sp_txn : coverpoint SpTxn {
            bins SpTxn = {1};
        }
    endgroup : sp_cg
    covergroup sp_intrlv_pgm_cg;
       intrlv_en : coverpoint sp_intrlv_en;
       set : coverpoint amig_set{
         bins s[] = {[0:<%=obj.DmiInfo[obj.Id].InterleaveInfo.dmiIGSV.length-1%>]};
       }
       way : coverpoint amif_way{
         bins w[] = {2,4,8,16};
       }
       func : coverpoint amif_function;
       sp_pgm_cross : cross intrlv_en, set, way, func{
         ignore_bins ignore_disabled = binsof(intrlv_en) intersect{0};
       }
    endgroup : sp_intrlv_pgm_cg
    covergroup sp_usage_cg;
      full : coverpoint sp_full{
        bins hit = {1};
      }
    endgroup: sp_usage_cg
    <% } %>
    <% } %>
    <% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM" || obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
    covergroup skidbuf_error_cg;
    <% if(obj.DmiInfo[obj.Id].fnErrDetectCorrect == "SECDED") { %>
      overflow : coverpoint err_overflow;
      threshold : coverpoint err_threshold{
        bins range[2] = {[0:127],[128:255]};
      }
    <% } %>
      c_or_uc : coverpoint err_type{
    <% if(obj.DmiInfo[obj.Id].fnErrDetectCorrect == "SECDED") { %>
        bins correctable   = {0};
    <% } %>
        bins uncorrectable = {1};
      }
      location : coverpoint err_location{
      <% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { %>
        bins cmd_skid_buffer = {3'b101};
      <% } %>
      <% if (obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
        bins mrd_skid_buffer = {3'b110};
      <% } %>
      }
      UCE_cross : cross c_or_uc, location {
        ignore_bins ignore_correctable = binsof(c_or_uc) intersect {0};
      }
    <% if(obj.DmiInfo[obj.Id].fnErrDetectCorrect == "SECDED") { %>
      CE_cross : cross c_or_uc, overflow, threshold, location{
        ignore_bins ignore_uncorrectable = binsof(c_or_uc) intersect {1};
      }
    <% } %>
      mission_fault : coverpoint err_mission_fault;
      mission_fault_cross : cross location, err_mission_fault;
    endgroup : skidbuf_error_cg
    <% } %>
    
    <% if ( (obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys") ) { %>
    covergroup addrtrans_cg;
        // #Cover.DMI.Concerto.v3.0.AddressTranslationMaskbit
        mask : coverpoint mask;
        // #Cover.DMI.Concerto.v3.0.AddressTransalationFAR
        addrtrans_far : coverpoint idx iff(found == 1){
            <% for (var i=0; i < obj.DmiInfo[obj.Id].nAddrTransRegisters; i++) { %>
            bins dmiurfar_<%=i%> = {<%=i%>};
            <% } %>
        }
        addr_trans_hit : coverpoint found {
            bins no_addr_trans = {0};
            bins addr_trans    = {1};
        }
    endgroup : addrtrans_cg
    <% } %>

//#Cover.DMI.CmdReqQos
//#Cover.DMI.MrdReqQos
//#Cover.DMI.RbReqQos
    <% if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
    covergroup qosth_cg(int wtt_qosrsv_max);
        c_wtt_qosrsv : coverpoint wtt_qosrsv {
            bins wtt_zero = {0};
            bins wtt_min  = {1}; // #Cover.DMI.DmiQosRsv
         <% if(obj.testBench == "dmi" || (obj.testBench == "fsys")){ %>
           `ifndef VCS
            bins wtt_valid_range[] = {[2:wtt_qosrsv_max-1]} with (wtt_qosrsv_max >= 2); // #Cover.DMI.DmiQosRegRand
           `else 
            bins wtt_valid_range[] = {[2:wtt_qosrsv_max-1]} iff (wtt_qosrsv_max >= 2); // #Cover.DMI.DmiQosRegRand
           `endif  // `ifndef VCS ... `else ...
         <% } else {%>
            bins wtt_valid_range[] = {[2:wtt_qosrsv_max-1]} with (wtt_qosrsv_max >= 2); // #Cover.DMI.DmiQosRegRand
         <% } %>
        }
        c_rtt_qosrsv : coverpoint rtt_qosrsv {
            bins rtt_zero = {0};
            bins rtt_min  = {1};// #Cover.DMI.DmiQosRsv
            bins rtt_valid_range[] = {[2:31]};// #Cover.DMI.DmiQosRegRand
        }
        c_qosth : coverpoint qosth {
            bins qosth_min  = {1};
            bins qosth_valid_range[] = {[2:14]};// #CoverDMI.DmiQosRegRand
            bins qosth_max  = {15};
        }
    endgroup : qosth_cg
    <% } %>
    // #CoverToggle.DMI.r.Rdata
    toggle_coverage toggle_cg_axi_read_data;
    // #CoverToggle.DMI.w.Wdata
    toggle_coverage toggle_cg_axi_write_data;
    <% if(typeof obj.DmiInfo[obj.Id].ccpParams.SecSubRows !== 'undefined' && obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length-1 != 0 && secsubrows_sum !=0) { %>
    covergroup addr_hash_cg ();
    //#Cover.DMI.Concerto.v3.6.DistributedSecAddrBits
      c_sec_bits : coverpoint sec_bits{
        bins y[] = {[6:<%=ccp_wAddr%>-1]};
        ignore_bins ignore_pribits = <%cmcCache.forEach(function(bundle, i, array){%>{<%=bundle.primBits%>} <%});%>;
      }
      c_prim_bits : coverpoint pri_bits{
        bins x[] = <%cmcCache.forEach(function(bundle, i, array){%>{<%=bundle.primBits%>} <%});%>;
      }
    endgroup : addr_hash_cg
    <% } %>
endclass :dmi_coverage

function void dmi_coverage::collect_axi_write_addr_pkt(axi4_write_addr_pkt_t txn);
    axi_msg_type    = aw;
    awid            = txn.awid;
    <% if (wRegion==0) {%>
        awregion        = txn.awregion;
    <%}%>
    
    axi_write_addr.sample();
endfunction : collect_axi_write_addr_pkt

function void dmi_coverage::collect_axi_write_data_pkt(axi4_write_data_pkt_t txn);
    foreach (txn.wdata[i]) begin
        for (int j = 0; j < WXDATA; j++) begin
            toggle_cg_axi_write_data.field[j] = txn.wdata[i][j];
        end
        toggle_cg_axi_write_data.sample();
    end
endfunction : collect_axi_write_data_pkt

function void dmi_coverage::collect_axi_write_resp_pkt(axi4_write_resp_pkt_t txn);
    bresp = txn.bresp;
    <%if(wBUser >0) { %>
    buser = txn.buser;
    <%}%>
    axi_write_resp.sample();
endfunction : collect_axi_write_resp_pkt

function void dmi_coverage::collect_axi_read_addr_pkt(axi4_read_addr_pkt_t txn);
    axi_msg_type = ar;
    arid = txn.arid;
    <%if (wRegion==0) {%>
    arregion = txn.arregion;
    <%}%>

    axi_read_addr.sample();
endfunction : collect_axi_read_addr_pkt

function void dmi_coverage::collect_axi_read_data_pkt(axi4_read_data_pkt_t txn);
    beat_num = 0;
    foreach (txn.rresp_per_beat[i]) begin
        rresp_per_beat = txn.rresp_per_beat[i];
        axi_read_data.sample();
        beat_num++;
        for (int j = 0; j < WXDATA; j++) begin
            toggle_cg_axi_read_data.field[j] = txn.rdata[i][j];
        end
        toggle_cg_axi_read_data.sample();
    end
endfunction : collect_axi_read_data_pkt

function void dmi_coverage::collect_smi_seq_item(smi_seq_item m_pkt);
    smi_seq_item            txn;
    int                     find_entry[$];
    int                     find_rbid_match_q[$];
    txn                     = new();
    txn.do_copy(m_pkt);
    smi_msg_type            = txn.smi_msg_type;
    smi_ns                  = txn.smi_ns;
    smi_ac                  = txn.smi_ac;
    smi_pr                  = txn.smi_pr;
    smi_rl                  = txn.smi_rl;
    smi_tm                  = txn.smi_tm;
    smi_size                = txn.smi_size;
    smi_intfsize            = txn.smi_intfsize;
    dce_src_ncore_unit_id   = txn.smi_src_ncore_unit_id;
    dtr_targ_ncore_unit_id  = txn.smi_mpf1_dtr_tgt_id[WSMINCOREUNITID-1:0];
    dtr_rmsg_id             = txn.smi_mpf2_dtr_msg_id ;
    smi_qos                 = txn.smi_qos;
    smi_msg_pri             = txn.smi_msg_pri;
    smi_msg_id              = txn.smi_msg_id;
    cache_addr              = txn.smi_addr;
    beat_access             = txn.smi_addr[$clog2(WXDATA/8)+$clog2(SYS_nSysCacheline/(WXDATA/8))-1:$clog2(WXDATA/8)];
    smi_msg_user            = txn.smi_msg_user;
    smi_cmstatus            = txn.smi_cmstatus;
   
    same_addr_diff_ns               = 0;
    mrd_dtw_data_ptl_same_addr_ns   = 0;
    mrd_dtw_data_dty_same_addr_ns   = 0;
    mrd_dtw_data_cln_same_addr_ns   = 0;
    mrd_dtw_no_data_same_addr_ns    = 0;
    coh_nc_txn_same_addr            = ignore1;
    backtobackrdwr                  = ignore2;

    if(txn.isDtwMsg() && txn.smi_rbid >= <%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%> && matched_cmd_req_item != null) begin       //non-coherent txn
        txn.smi_addr = matched_cmd_req_item.smi_addr;
        txn.smi_ns   = matched_cmd_req_item.smi_ns;
    end
    else if (txn.isDtwMsg() || txn.isRbMsg()) begin                                                 //coherent txn
        find_rbid_match_q = {};    
        find_rbid_match_q = rbreq_dtw_q.find_index with ((item.smi_rbid == txn.smi_rbid) && (txn.isRbMsg() || txn.isDtwMsg()));
    
        if(find_rbid_match_q.size() > 0) begin
            dtw_msg_type = txn.isDtwMsg() ? txn.smi_msg_type : rbreq_dtw_q[find_rbid_match_q[0]].smi_msg_type;
            if(txn.isDtwMsg()) begin
                txn.smi_addr = rbreq_dtw_q[find_rbid_match_q[0]].smi_addr;
                txn.smi_ns   = rbreq_dtw_q[find_rbid_match_q[0]].smi_ns;
            end
            rbreq_dtw_q.delete(find_rbid_match_q[0]);
        end
        else if(txn.isRbMsg()||txn.isDtwMsg()) rbreq_dtw_q.push_back(txn);
    end

    if (smi_txn_q.size() > 0) begin
        //same addr same msg type diff ns 
        find_q = smi_txn_q.find_index with (cl_aligned(item.smi_addr) == cl_aligned(txn.smi_addr) &&
                                            //item.smi_msg_type == txn.smi_msg_type &&
                                            item.smi_ns       != txn.smi_ns); 
        if(find_q.size() > 0) 
            smi_msg_type_prev =  smi_txn_q[find_q[$]].smi_msg_type; 

        //dtw msg doesn't contain smi addr. checking cache addr of the wtt entry
        find_entry = {};
        find_entry = wtt_cov_q.find_index with  (cl_aligned(item.cache_addr) == cl_aligned(txn.smi_addr) &&
                                                item.security   != txn.smi_ns   &&
                                                item.DTW_req_recd);
        if(find_entry.size() >=1) begin
            dtw_msg_type_prev = wtt_cov_q[find_entry[$]].dtw_msg_type;
        end
    end
     
    if (smi_txn_q1.size() > 0) begin
        //using wtt_cov_q for dtw. Because dtw doesn't contain address
        find_dtw_data_ptl = wtt_cov_q.find_index with   (cl_aligned(item.cache_addr) == cl_aligned(txn.smi_addr) &&
                                                        item.security   == txn.smi_ns &&
                                                        item.dtw_msg_type == DTW_DATA_PTL && txn.isMrdMsg());
        find_dtw_data_cln = wtt_cov_q.find_index with   (cl_aligned(item.cache_addr) == cl_aligned(txn.smi_addr) &&
                                                        item.security   == txn.smi_ns &&
                                                        item.dtw_msg_type == DTW_DATA_CLN && txn.isMrdMsg());
        find_dtw_data_dty = wtt_cov_q.find_index with   (cl_aligned(item.cache_addr) == cl_aligned(txn.smi_addr) &&
                                                        item.security   == txn.smi_ns &&
                                                        item.dtw_msg_type == DTW_DATA_DTY && txn.isMrdMsg());
        find_dtw_no_data  = wtt_cov_q.find_index with   (cl_aligned(item.cache_addr) == cl_aligned(txn.smi_addr) &&
                                                        item.security   == txn.smi_ns &&
                                                        item.dtw_msg_type == DTW_NO_DATA && txn.isMrdMsg());
        find_ncRd_cohRd_q = smi_txn_q1.find_index with (item.smi_addr == txn.smi_addr &&
                                                        item.isCmdNcRdMsg() && txn.isMrdMsg());
        find_ncRd_cohWr_q = smi_txn_q1.find_index with (item.smi_addr == txn.smi_addr &&
                                                        item.isCmdNcRdMsg() && txn.isDtwMsg());
        find_ncWr_cohRd_q = smi_txn_q1.find_index with (item.smi_addr == txn.smi_addr &&
                                                        item.isCmdNcWrMsg && txn.isMrdMsg());
        find_ncWr_cohWr_q = smi_txn_q1.find_index with (item.smi_addr == txn.smi_addr &&
                                                        item.isCmdNcWrMsg && txn.isDtwMsg());
        find_cohRd_ncRd_q = smi_txn_q1.find_index with (item.smi_addr == txn.smi_addr &&
                                                        item.isMrdMsg && txn.isCmdNcRdMsg());
        find_cohRd_ncWr_q = smi_txn_q1.find_index with (item.smi_addr == txn.smi_addr &&
                                                        item.isMrdMsg && txn.isCmdNcWrMsg());
        find_cohWr_ncRd_q = smi_txn_q1.find_index with (item.smi_addr == txn.smi_addr &&
                                                        item.isDtwMsg && txn.isCmdNcRdMsg());
        find_cohWr_ncWr_q = smi_txn_q1.find_index with (item.smi_addr == txn.smi_addr &&
                                                        item.isDtwMsg && txn.isCmdNcWrMsg());
    end
    smi_txn_q.push_back(txn);
    smi_txn_q1.push_back(txn);
    
    if (find_q.size() > 0 || find_entry.size() > 0)         same_addr_diff_ns               = 1;
    if (find_dtw_data_ptl.size() > 0)                       mrd_dtw_data_ptl_same_addr_ns   = 1;
    if (find_dtw_data_dty.size() > 0)                       mrd_dtw_data_dty_same_addr_ns   = 1;
    if (find_dtw_data_cln.size() > 0)                       mrd_dtw_data_cln_same_addr_ns   = 1;
    if (find_dtw_no_data.size()  > 0)                       mrd_dtw_no_data_same_addr_ns    = 1;
    if (find_ncRd_cohRd_q.size() > 0)                       coh_nc_txn_same_addr            = ncRd_cohRd;
    if (find_ncRd_cohWr_q.size() > 0)                       coh_nc_txn_same_addr            = ncRd_cohWr;
    if (find_ncWr_cohRd_q.size() > 0)                       coh_nc_txn_same_addr            = ncWr_cohRd;
    if (find_ncWr_cohWr_q.size() > 0)                       coh_nc_txn_same_addr            = ncWr_cohWr;
    if (find_cohRd_ncRd_q.size() > 0)                       coh_nc_txn_same_addr            = cohRd_ncRd;
    if (find_cohRd_ncWr_q.size() > 0)                       coh_nc_txn_same_addr            = cohRd_ncWr;
    if (find_cohWr_ncRd_q.size() > 0)                       coh_nc_txn_same_addr            = cohWr_ncRd;
    if (find_cohWr_ncWr_q.size() > 0)                       coh_nc_txn_same_addr            = cohWr_ncWr;

    if(txn.isCmdMsg())  isSmiMsg_cmd = 1;

    if(txn.isCmdMsg()) begin
        //beatn_cmd = txn.smi_addr[$clog2(((txn.smi_intfsize+1)*64)/8)+$clog2(SYS_nSysCacheline/((txn.smi_intfsize+1)*64)/8)-1:$clog2(((txn.smi_intfsize+1)*64)/8)];
        int start = $clog2(((2**txn.smi_intfsize)*64)/8);
        int limit = $clog2(((2**txn.smi_intfsize)*64)/8)+$clog2(SYS_nSysCacheline/(((2**txn.smi_intfsize)*64)/8))-1;
        for(int j = 0, i = start; i <= limit; j++,i++) begin
            cmd_beatn[j] = txn.smi_addr[i];                 //aiu data width is variable, cmd_beatn indicates the critical beat         
        end
    end 

    if(smi_prev_txn != null && txn.isCmdMsg() && (txn.smi_addr == smi_prev_txn.smi_addr) && (txn.smi_src_ncore_unit_id == smi_prev_txn.smi_src_ncore_unit_id)) begin
        if(smi_prev_txn.isCmdNcRdMsg() && txn.isCmdNcRdMsg()) $cast(backtobackrdwr, {same_src_rd_after_rd});
        if(smi_prev_txn.isCmdNcWrMsg() && txn.isCmdNcWrMsg()) $cast(backtobackrdwr, {same_src_wr_after_wr});
        if(smi_prev_txn.isCmdNcRdMsg() && txn.isCmdNcWrMsg()) $cast(backtobackrdwr, {same_src_wr_after_rd});
        if(smi_prev_txn.isCmdNcWrMsg() && txn.isCmdNcRdMsg()) $cast(backtobackrdwr, {same_src_rd_after_wr});
    end
    else if (smi_prev_txn != null && txn.isCmdMsg() && (txn.smi_addr == smi_prev_txn.smi_addr) && (txn.smi_src_ncore_unit_id != smi_prev_txn.smi_src_ncore_unit_id)) begin
        if(smi_prev_txn.isCmdNcRdMsg() && txn.isCmdNcRdMsg()) $cast(backtobackrdwr, {diff_src_rd_after_rd});
        if(smi_prev_txn.isCmdNcWrMsg() && txn.isCmdNcWrMsg()) $cast(backtobackrdwr, {diff_src_wr_after_wr});
        if(smi_prev_txn.isCmdNcRdMsg() && txn.isCmdNcWrMsg()) $cast(backtobackrdwr, {diff_src_wr_after_rd});
        if(smi_prev_txn.isCmdNcWrMsg() && txn.isCmdNcRdMsg()) $cast(backtobackrdwr, {diff_src_rd_after_wr});
    end

    if(txn.isCmdMsg()) smi_prev_txn = txn;

    //NcWrDtwOrder
    if(txn.isCmdNcWrMsg())  smi_txn_cmd = txn;
    if(txn.isStrMsg())      smi_txn_str  = txn;
    if(txn.isDtwMsg() && smi_txn_cmd != null && smi_txn_str != null) begin
        if((smi_txn_cmd.smi_msg_id == smi_txn_str.smi_rmsg_id)
            && (smi_txn_str.smi_rbid == txn.smi_rbid)) $cast(ncwrdtworder, {inorder});
        else $cast(ncwrdtworder, {notinorder});
    end else begin
        $cast(ncwrdtworder, {ignore5});
    end
    //#Cover.DMI.Concerto.v3.0.spedges

    if(cl_aligned(txn.smi_addr) == (cl_aligned(k_sp_base_addr)-1)) spaddr_edges = sp_base_addr_lower;
    else if(cl_aligned(txn.smi_addr) == (cl_aligned(k_sp_base_addr))) spaddr_edges = sp_base_addr;
    else if(cl_aligned(txn.smi_addr) == (cl_aligned(k_sp_base_addr)+1)) spaddr_edges = sp_base_addr_high;
    else if(cl_aligned(txn.smi_addr) == (cl_aligned(k_sp_max_addr)-1)) spaddr_edges = sp_max_addr_lower;
    else if(cl_aligned(txn.smi_addr) == (cl_aligned(k_sp_max_addr))) spaddr_edges = sp_max_addr;
    else if(cl_aligned(txn.smi_addr) == (cl_aligned(k_sp_max_addr))+1) spaddr_edges = sp_max_addr_high;
    else spaddr_edges = ignore7;
    
    smi_transaction.sample();
endfunction : collect_smi_seq_item

<% if(obj.DutInfo.useCmc) { %>
function void dmi_coverage::collect_CMO_entry(bit[5:0] word);
  <%if(obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2 && obj.DmiInfo[obj.Id].ccpParams.wData == 256) { %>  
    mntBeat = word[5];
    mntWord = word[4:0];
  <%} else {%> 
    mntBeat = word[4:(5-$clog2(<%=(512/obj.DmiInfo[obj.Id].ccpParams.wData)%>))]; 
    mntWord = word[(5-$clog2(<%=(512/obj.DmiInfo[obj.Id].ccpParams.wData)%>)-1):0];
  <%}%>
  cmo_mntop.sample();
endfunction
<% } %>
<% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
function void dmi_coverage::collect_atomic_rw_semantics(smi_msg_type_logic_t m_cmdtype, bit[3:0] m_opcode, bit m_outcome);
  atomic_cmdtype = m_cmdtype;
  atomic_outcome = m_outcome;
  atomic_mpf1_opcode = m_opcode;
  atomic_rw_semantics.sample();
endfunction
<% } %>

function void dmi_coverage::collect_rtt_entry(dmi_scb_txn txn);
    dtrType_mrdType_ncRd = ignore4;

    <% if(obj.DutInfo.useCmc) { %>
    // Sample cache state only for non scratchpad txns
    isSpTxn = txn.sp_txn;
    if (!txn.sp_txn)begin
      if(cmc_policy[0])begin  // lookup_en =1
        cache_state = txn.cache_ctrl_pkt.state;
      end
    end
    else begin
      spaddr_index = txn.sp_index;
    end
    <% } %>

    if(!txn.nackuce)begin
       if (txn.isMrd) 
           rtt_txn_msg_type = txn.mrd_req_pkt.smi_msg_type;
       if (txn.isAtomic)
           rtt_txn_msg_type = txn.cmd_req_pkt.smi_msg_type;
       if (txn.isMrd && txn.mrd_req_pkt.smi_msg_type == MRD_RD_WITH_SHR_CLN && txn.dtr_req_pkt.smi_msg_type == DTR_DATA_SHR_CLN)    $cast(dtrType_mrdType_ncRd , {dtr_data_shr_cln__mrd_rd_with_shr_cln});
       if (txn.isMrd && txn.mrd_req_pkt.smi_msg_type == MRD_RD_WITH_UNQ_CLN && txn.dtr_req_pkt.smi_msg_type == DTR_DATA_UNQ_CLN)    $cast(dtrType_mrdType_ncRd , {dtr_data_unq_cln__mrd_rd_with_unq_cln});
       if (txn.isMrd && txn.mrd_req_pkt.smi_msg_type == MRD_RD_WITH_UNQ     && txn.dtr_req_pkt.smi_msg_type == DTR_DATA_UNQ_CLN)    $cast(dtrType_mrdType_ncRd , {dtr_data_unq_cln__mrd_rd_with_unq});
       if (txn.isMrd && txn.mrd_req_pkt.smi_msg_type == MRD_RD_WITH_UNQ     && txn.dtr_req_pkt.smi_msg_type == DTR_DATA_UNQ_DTY)    $cast(dtrType_mrdType_ncRd , {dtr_data_unq_dty__mrd_rd_with_unq});
       if (txn.isMrd && txn.mrd_req_pkt.smi_msg_type == MRD_RD_WITH_INV     && txn.dtr_req_pkt.smi_msg_type == DTR_DATA_INV)        $cast(dtrType_mrdType_ncRd , {dtr_data_inv__mrd_rd_with_inv});
       if (txn.isNcRd && txn.cmd_req_pkt.smi_msg_type == CMD_RD_NC          && txn.dtr_req_pkt.smi_msg_type == DTR_DATA_INV)        $cast(dtrType_mrdType_ncRd , {dtr_data_inv__cmd_nc_rd});
    end

    <% if(obj.DutInfo.useCmc) { %>
    if(txn.cache_ctrl_pkt != null) begin
        if($countbits(txn.cache_ctrl_pkt.waypbusy_vec,1) == N_WAY) waybusy = 1; 
    end
    else waybusy = 0;
    <% } %>

    if(txn.smi_ac  
    && txn.AXI_read_addr_recd && txn.AXI_read_data_recd 
    && !txn.AXI_write_addr_recd_rtt && !txn.AXI_write_data_recd_rtt && !txn.AXI_write_resp_recd_rtt 
    && txn.isDtwMrgMrd && txn.DTR_req_recd && txn.DTR_rsp_recd)
        dtwmrgmrd_alloc_valid = 1;
    else dtwmrgmrd_alloc_valid = 0;

    if(txn.isCacheHit && !txn.AXI_read_addr_recd && !txn.AXI_read_data_recd 
        && txn.isDtwMrgMrd && txn.DTR_req_recd && txn.DTR_rsp_recd)
        dtwmrgmrd_hit_valid = 1;
    else dtwmrgmrd_hit_valid = 0;
        
    if( txn.isDtwMrgMrd && txn.RB_req_recd_rtt && txn.RB_rsp_recd_rtt 
        && txn.DTW_req_recd_rtt && txn.DTW_rsp_recd_rtt 
        && txn.DTR_req_recd && txn.DTR_rsp_recd) dtwmrgmrd_protocolflow_match = 1;
    else dtwmrgmrd_protocolflow_match = 0;

    isAtomicCmp_match = txn.isAtomicCmp_match;

    rtt_cov_q.push_back(txn);

    rtt_entry_cg.sample();
endfunction : collect_rtt_entry

function void dmi_coverage::collect_wtt_entry(dmi_scb_txn txn);
    m_scb_txn = txn;
    smi_rbid  = txn.smi_rbid;
    isNcWr    = txn.isNcWr;
    isCoh     = txn.isCoh;
     
    dtwType_ncWr = ignore3;

    if(isNcWr) 
        smi_prim  = txn.dtw_req_pkt.smi_prim;
    
    if (txn.isNcWr && txn.cmd_req_pkt.smi_msg_type == CMD_WR_NC_FULL && txn.dtw_req_pkt.smi_msg_type == DTW_DATA_CLN)    $cast(dtwType_ncWr , {dtw_data_cln__cmd_wr_nc_full});
    if (txn.isNcWr && txn.cmd_req_pkt.smi_msg_type == CMD_WR_NC_FULL && txn.dtw_req_pkt.smi_msg_type == DTW_DATA_DTY)    $cast(dtwType_ncWr , {dtw_data_dty__cmd_wr_nc_full});
    if (txn.isNcWr && txn.cmd_req_pkt.smi_msg_type == CMD_WR_NC_PTL  && txn.dtw_req_pkt.smi_msg_type == DTW_DATA_PTL)    $cast(dtwType_ncWr , {dtw_data_ptl__cmd_wr_nc_ptl});
    if (txn.isNcWr && txn.cmd_req_pkt.smi_msg_type == CMD_WR_NC_PTL  && txn.dtw_req_pkt.smi_msg_type == DTW_NO_DATA)     $cast(dtwType_ncWr , {dtw_no_data__cmd_wr_nc_ptl}); 
    
    <% if(obj.DutInfo.useCmc) { %>
    if(txn.cache_ctrl_pkt != null) begin
        if($countbits(txn.cache_ctrl_pkt.waypbusy_vec,1) == N_WAY) waybusy = 1; 
    end
    else waybusy = 0;
    <% } %>

    if( txn.isCacheMiss 
        && txn.AXI_read_addr_recd_wtt && txn.AXI_read_data_recd_wtt
        && txn.AXI_write_addr_recd && txn.AXI_write_data_recd && txn.AXI_write_resp_recd
        && txn.isDtwMrgMrd 
        && txn.DTR_req_recd_wtt && txn.DTR_rsp_recd_wtt
        ) 
        dtwmrgmrd_noalloc_valid_cache_miss = 1;
    else dtwmrgmrd_noalloc_valid_cache_miss = 0;
     
    if( (txn.smi_ac == 1 && waybusy)
        && txn.AXI_read_addr_recd_wtt && txn.AXI_read_data_recd_wtt
        && txn.AXI_write_addr_recd && txn.AXI_write_data_recd && txn.AXI_write_resp_recd
        && txn.isDtwMrgMrd 
        && txn.DTR_req_recd_wtt && txn.DTR_rsp_recd_wtt
        ) 
        dtwmrgmrd_noalloc_valid_waysbusy = 1;
    else dtwmrgmrd_noalloc_valid_waysbusy = 0;

    if(txn.isCacheHit 
        && !txn.AXI_write_addr_recd && !txn.AXI_write_data_recd && !txn.AXI_write_resp_recd
        && txn.isDtwMrgMrd)
        dtwmrgmrd_hit_valid = 1;
    else dtwmrgmrd_hit_valid = 0;
    
    if( txn.isDtw && txn.RB_req_recd && txn.RB_rsp_recd 
        && txn.DTW_req_recd && txn.DTW_rsp_recd)
        dtwprotocolflow_match = 1;
    else dtwprotocolflow_match = 0;

    if( txn.isDtwMrgMrd && txn.RB_req_recd && txn.RB_rsp_recd 
        && txn.DTW_req_recd && txn.DTW_rsp_recd
        && txn.DTR_req_recd_wtt && txn.DTR_rsp_recd_wtt) dtwmrgmrd_protocolflow_match = 1;
    else dtwmrgmrd_protocolflow_match = 0;
    
    isCacheHit = txn.isCacheHit;

    // ---------------------   DMI deadlock v3.4   -----------------------------
    // ----         DMI deadlock due to RB credit allocated by DCE:          ---
    // First, refer to Ncore 3.2.x -- DMI Code Coverage Configuration Details:::
    // you need to look at the value nDceRbEntries defined by the SPEC, for each
    // of the configs in DMI v3.4.
    // for config1::       rbBaseValue will have a value between [10_000 : 10_009] 
    // for config4::       rbBaseValue will have a value between [40_000 : 40_047] 
    // for config5::       rbBaseValue will have a value between [50_000 : 50_015] 
    // for config6::       rbBaseValue will have a value between [60_000 : 60_159] 
    // for config7::       rbBaseValue will have a value between [70_000 : 70_047] 
    // for config7_snps::  rbBaseValue will have a value between [71_000 : 71_079] 
    // for config7_snps0:: rbBaseValue will have a value between [72_000 : 72_079] 
    // for config8::       rbBaseValue will have a value between [80_000 : 80_079] 
    if (txn.isCoh) begin
        if(<%=obj.DutInfo.cmpInfo.nDmiRbEntries%>    == 2)                                 rbBaseValue=10000; 
        if((<%=obj.DutInfo.cmpInfo.nDceRbEntries%>   == 48) && (!<%=obj.DutInfo.useCmc%>))         rbBaseValue=40000;
        if((<%=obj.DutInfo.cmpInfo.nRttCtrlEntries%> == 4)  &&
           (<%=obj.DutInfo.cmpInfo.nDceRbEntries%> == <%=obj.DutInfo.cmpInfo.nDmiRbEntries%>))             rbBaseValue=50000;

        if(<%=obj.DutInfo.cmpInfo.nDceRbEntries%>    == 160)                               rbBaseValue=60000;
        if((<%=obj.DutInfo.cmpInfo.nDceRbEntries%>   == 48) && (<%=obj.DutInfo.useCmc%>))          rbBaseValue=70000;
        if((<%=obj.DutInfo.cmpInfo.nDceRbEntries%>   == 80) && (!<%=obj.useResiliency%>))  rbBaseValue=71000;
        if((<%=obj.DutInfo.cmpInfo.nDceRbEntries%>   == 80) && (<%=obj.useResiliency%>))   rbBaseValue=72000;
        if((<%=obj.DutInfo.cmpInfo.nDceRbEntries%>   == 80) && 
           (<%=obj.DutInfo.cmpInfo.nDmiRbEntries%>   == 24))                               rbBaseValue=80000;

        nDCE_RBentries = rbBaseValue + txn.smi_rbid;
    end

    if(txn.isCoh && txn.DTW_req_recd && txn.RB_req_recd) begin
        if      (txn.t_dtwreq < txn.t_rbreq)    $cast(rbreq_dtw_seq, {dtw_first});
        else if (txn.t_rbreq  < txn.t_dtwreq)   $cast(rbreq_dtw_seq, {rbreq_first});
        else                                    $cast(rbreq_dtw_seq, {same_time});
        rbreq_dtw_seq_valid = 1;
    end
    else rbreq_dtw_seq_valid = 0;
    
    if(txn.isCoh && txn.DTW_req_recd && txn.DTW2nd_req_recd && txn.RB_req_recd && txn.isMW) begin
        $cast(mw_dtw_seq , {dtw_01_match});
        mw_dtw_seq_valid = 1;
    end else if (txn.isCoh && txn.DTW_req_recd && !txn.DTW2nd_req_recd && txn.RB_req_recd && txn.isMW) begin
        $cast(mw_dtw_seq, {dtw_1_match});
        mw_dtw_seq_valid = 1;
    end
    else mw_dtw_seq_valid = 0;

    if(txn.RB_req_recd && txn.RBRL_req_recd && txn.RB_rsp_recd) begin
        if      (txn.t_rbrlreq < txn.t_rbrsrsp)     $cast(rbresrelorder,    {rbrreq_before_rbrsp});
        else if (txn.t_rbrlreq > txn.t_rbrsrsp)     $cast(rbresrelorder,    {rbrreq_after_rbrsp});
        rbresrelorder_valid = 1;
    end else rbresrelorder_valid = 0;

    if(txn.RB_req_recd && txn.RBRL_req_recd) rbresrelrbid_hit = 1;
    else rbresrelrbid_hit   = 0;

    if(txn.AXI_write_addr_recd) begin
        if (txn.axi_write_addr_pkt.t_pkt_seen_on_intf < txn.axi_write_data_pkt.t_pkt_seen_on_intf) axi_wr_seq = addr_before_data;
        else if (txn.axi_write_data_pkt.t_pkt_seen_on_intf < txn.axi_write_addr_pkt.t_pkt_seen_on_intf) axi_wr_seq = data_before_addr;
        else axi_wr_seq = addr_with_data;
    end else begin
        axi_wr_seq = ignore6;
    end

    wtt_cov_q.push_back(txn);

    wtt_entry_cg.sample();
endfunction : collect_wtt_entry

function void dmi_coverage::collect_rd_inflight(dmi_scb_txn rtt_q[], smi_seq_item txn);
    int find_rd_inflight_q[$],Mrd_inflight[$];
    rd_atomic_hit_rtt   = 0;
    wr_atomic_hit_rtt   = 0;
    sw_atomic_hit_rtt   = 0;
    cmp_atomic_hit_rtt  = 0;

    find_rd_inflight_q = {};
    find_rd_inflight_q = rtt_q.find_index with (cl_aligned(item.cache_addr) == cl_aligned(txn.smi_addr) &&
                                                item.security == txn.smi_ns);
    Mrd_inflight = rtt_q.find_index with (item.MRD_rsp_expd && !item.MRD_rsp_recd);
    MrdInflight_cnt = Mrd_inflight.size();
    <% if(obj.DutInfo.useCmc) {%>
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
    if (find_rd_inflight_q.size() > 0) begin
        if (txn.smi_msg_type == CMD_RD_ATM) rd_atomic_hit_rtt = 1;
        if (txn.smi_msg_type == CMD_WR_ATM) wr_atomic_hit_rtt = 1;
        if (txn.smi_msg_type == CMD_SW_ATM) sw_atomic_hit_rtt = 1;
        if (txn.smi_msg_type == CMD_CMP_ATM) cmp_atomic_hit_rtt = 1;
    end
    <% } %>
    <% } %>
    rd_inflight.sample();
endfunction : collect_rd_inflight

function void dmi_coverage::collect_wr_inflight(dmi_scb_txn wtt_q[], smi_seq_item txn);
    int find_wr_inflight_q[$];
    mrd_flush_hit_wtt  = 0;
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
    rd_atomic_hit_wtt  = 0;
    wr_atomic_hit_wtt  = 0;
    sw_atomic_hit_wtt  = 0;
    cmp_atomic_hit_wtt = 0;
    <% } %>
    find_wr_inflight_q = {};
    find_wr_inflight_q = wtt_q.find_index with (cl_aligned(item.cache_addr) == cl_aligned(txn.smi_addr) &&
                                                item.security == txn.smi_ns);
    if (find_wr_inflight_q.size() > 0) begin
        if (txn.smi_msg_type == MRD_FLUSH) mrd_flush_hit_wtt = 1;
<% if(obj.DutInfo.useCmc) {%>                                                
 <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
        if (txn.smi_msg_type == CMD_RD_ATM) rd_atomic_hit_wtt = 1;
        if (txn.smi_msg_type == CMD_WR_ATM) wr_atomic_hit_wtt = 1;
        if (txn.smi_msg_type == CMD_SW_ATM) sw_atomic_hit_wtt = 1;
        if (txn.smi_msg_type == CMD_CMP_ATM) cmp_atomic_hit_wtt = 1;
<% } %>
<% } %>
    end
    
    wr_inflight_cg.sample();
endfunction : collect_wr_inflight

//CCP covergroups are sampled here////////////////////////

<% if(obj.DutInfo.useCmc) { %>
function void dmi_coverage::collect_ccp_ctrl_pkt(ccp_ctrl_pkt_t txn);
    <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
    cycle_valid_ccp_ctrl_pkt = txn.posedge_count;
    if((cycle_valid_sp_ctrl_pkt - cycle_valid_ccp_ctrl_pkt) == 1) sp_cache_access_back_to_back = 1;
    else if((cycle_valid_ccp_ctrl_pkt - cycle_valid_sp_ctrl_pkt) == 1) sp_cache_access_back_to_back = 1;
    else sp_cache_access_back_to_back = 0;
    
    sp_cache_access_cg.sample();
    <% } %>

endfunction : collect_ccp_ctrl_pkt

<%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
function void dmi_coverage::collect_ccp_plru_eviction(int m_victim, int m_set_index);
  plru_victim_way = m_victim;
  plru_set_index   = m_set_index;
  ccp_plru_cg.sample();
endfunction
<% }%>

function void dmi_coverage::collect_ccp_evict_addr(ccp_ctrl_pkt_t txn);
    // Sample the eviction with alloc as result of SMC cacheline eviction due to fix index
    if(txn.alloc) evict_vld_alloc_hit = 1;
    else          evict_vld_alloc_hit = 0;

    ccp_evict_addr_cg.sample();
endfunction : collect_ccp_evict_addr

function void dmi_coverage::collect_ccp_rd_inflight(dmi_scb_txn rtt_q[], ccp_ctrl_pkt_t txn);

endfunction : collect_ccp_rd_inflight

function void dmi_coverage::collect_ccp_wr_inflight(dmi_scb_txn wtt_q[], ccp_ctrl_pkt_t txn);

endfunction : collect_ccp_wr_inflight

function void dmi_coverage::collect_ccp_alloc_field(bit alloc_en, bit ClnWrAllocDisable, bit DtyWrAllocDisable, bit RdAllocDisable, bit WrAllocDisable, bit WrDataClnPropagateEn);
    this.alloc_en       =  alloc_en;
    alloc_csr[0]        =  ClnWrAllocDisable;
    alloc_csr[1]        =  DtyWrAllocDisable;
    alloc_csr[2]        =  RdAllocDisable;
    alloc_csr[3]        =  WrAllocDisable;
    alloc_csr[4]        =  WrDataClnPropagateEn;
    cmc_alloc_cg.sample();
endfunction : collect_ccp_alloc_field

<% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
function void dmi_coverage::collect_sp_ctrl_pkt(ccp_sp_ctrl_pkt_t txn);
    cycle_valid_sp_ctrl_pkt = txn.posedge_count;
    if((cycle_valid_sp_ctrl_pkt - cycle_valid_ccp_ctrl_pkt) == 1) sp_cache_access_back_to_back = 1;
    else if((cycle_valid_ccp_ctrl_pkt - cycle_valid_sp_ctrl_pkt) == 1) sp_cache_access_back_to_back = 1;
    else sp_cache_access_back_to_back = 0;
  
    SpTxn = 1;

    sp_cg.sample();
   sp_cache_access_cg.sample();
endfunction : collect_sp_ctrl_pkt

function void dmi_coverage::collect_sp_pgm(bit en, func, int set, way);
  sp_intrlv_en =en;
  amif_function = func;
  amig_set = set;
  amif_way = way;
  sp_intrlv_pgm_cg.sample();
endfunction : collect_sp_pgm

function void dmi_coverage::collect_sp_occupancy(bit hit);
  sp_full = hit;
  sp_usage_cg.sample();
endfunction: collect_sp_occupancy
<% } %>
<% } %>

<% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM" || obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
function void dmi_coverage::collect_skidbuf_UCE_stats(bit [3:0] location, bit mission_fault);
  this.err_type = 1;
  this.err_location = location;
  this.err_overflow = 0;
  this.err_threshold = 0; 
  this.err_mission_fault = mission_fault;
  skidbuf_error_cg.sample();
endfunction

function void dmi_coverage::collect_skidbuf_CE_stats(bit overflow, bit[7:0] threshold, bit [3:0] location);
  this.err_overflow = overflow;
  this.err_threshold = threshold; 
  this.err_type = 0;
  this.err_location = location;
  skidbuf_error_cg.sample();
endfunction
<% } %>

<% if ( (obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys") ) { %>
function void dmi_coverage::collect_addrtrans_pkt(bit [31:0] addrTransV[4], bit [3:0] mask, bit found, int idx);
    this.mask = mask;
    this.found = found;
    this.idx = idx;
    addrtrans_cg.sample();
endfunction : collect_addrtrans_pkt
<% } %>

<% if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
function void dmi_coverage::collect_dmiutqoscr_reg_cov(bit[7:0] wtt_qosrsv, bit [7:0] rtt_qosrsv, bit [3:0] qosth);
   this.wtt_qosrsv = wtt_qosrsv;
   this.rtt_qosrsv = rtt_qosrsv;
   this.qosth = qosth;
   qosth_cg.sample();
endfunction : collect_dmiutqoscr_reg_cov
<% } %>

/////////////////////////////////////////////////////////

function dmi_coverage::new();
    int wtt_qosrsv_max = 33;
    int lid, uid;
    ncoreConfigInfo::ncore_unit_type_t utype;
    ncoreConfigInfo::get_logical_uinfo(<%=obj.DmiInfo[obj.Id].FUnitId%>, lid, uid, utype);
    <% if(typeof obj.DmiInfo[obj.Id].ccpParams.SecSubRows !== 'undefined' && obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length-1 != 0 && secsubrows_sum !=0) { %>
    addr_hash_cg = new();
    foreach (ncoreConfigInfo::cmc_set_sel[lid].pri_bits[i]) begin
      if(ncoreConfigInfo::cmc_set_sel[lid].sec_bits[i].size() > 0) begin
        foreach (ncoreConfigInfo::cmc_set_sel[lid].sec_bits[i][j]) begin
          sec_bits = ncoreConfigInfo::cmc_set_sel[lid].sec_bits[i][j];
          pri_bits = ncoreConfigInfo::cmc_set_sel[lid].pri_bits[i];
          addr_hash_cg.sample();
        end
      end
    end
    <% } %>
    axi_write_addr      = new();
    axi_write_resp      = new();
    axi_read_addr       = new();
    axi_read_data       = new();
    smi_transaction     = new();
    rd_inflight         = new();
    wtt_entry_cg        = new();
    rtt_entry_cg        = new();
    wr_inflight_cg      = new();
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
    atomic_rw_semantics = new();
    <% } %>
    <% if(obj.DutInfo.useCmc) { %>
    ccp_evict_addr_cg   = new();
    cmo_mntop = new();
    <%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
    ccp_plru_cg         = new();
    <%}%>
    cmc_alloc_cg        = new();
    <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
    sp_cache_access_cg  = new();
    sp_cg               = new();
    sp_intrlv_pgm_cg    = new();
    sp_usage_cg         = new();
    <% } %>
    <% } %>
    <% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM" || obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
    skidbuf_error_cg = new();
    <% } %>
    <% if ( (obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys") ) { %>
    addrtrans_cg = new();
    <% } %>
    <% if (obj.DmiInfo[obj.Id].fnEnableQos) { %>

        if(<%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries%> < wtt_qosrsv_max)
           wtt_qosrsv_max = <%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries%>;
        if(<%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%> < wtt_qosrsv_max)
           wtt_qosrsv_max = <%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%>;
        if(<%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%> < wtt_qosrsv_max)
           wtt_qosrsv_max = <%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%>;

       qosth_cg = new(wtt_qosrsv_max);

    <% } %>
    toggle_cg_axi_read_data = new(WXDATA,"axi_read_data");
    toggle_cg_axi_write_data = new(WXDATA,"axi_write_data");
endfunction :new
