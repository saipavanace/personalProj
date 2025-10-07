//#Check.CHI.v3.6.new_command.Err_first_part
//#Check.CHI.v3.6.new_command.Err_first_part_persist
//#Check.CHI.v3.6.CleanSharedPersistSep_Err
//#Check.CHI.v3.7.WriteEvictOrEvict.Error

import uvm_pkg::*;
`include "uvm_macros.svh"
//`include "chi_aiu_types.svh"

typedef enum {
    CmdReq,
    CmdRsp,
    DtrReq,
    DtrRsp,
    DtwReq,
    DtwRsp,
    StrReq,
    StrRsp,
    ChiRack,
    ChiRData

} eAIUPktTypes;

class chi_aiu_scb_txn extends uvm_object;

    `uvm_object_param_utils(chi_aiu_scb_txn)

    //CHI channel member items
    chi_req_seq_item  m_chi_req_pkt;
    chi_dat_seq_item  m_chi_read_data_pkt[$];
    chi_dat_seq_item  m_chi_write_data_pkt[$];
    chi_rsp_seq_item  m_chi_crsp_pkt;
    chi_rsp_seq_item  m_chi_srsp_pkt;
    chi_dat_seq_item  m_chi_snp_data_pkt[$];
    chi_snp_seq_item  m_chi_snp_addr_pkt;
    chi_base_seq_item m_chi_sysco_req_pkt;
    chi_base_seq_item m_chi_sysco_ack_pkt;

    //CHI channel expected items
    chi_req_seq_item  exp_chi_req_pkt;
    chi_dat_seq_item  exp_chi_read_data_pkt[$];
    chi_dat_seq_item  exp_chi_write_data_pkt[$];
    chi_rsp_seq_item  exp_chi_crsp_pkt;
    chi_rsp_seq_item  exp_chi_srsp_pkt;
    chi_dat_seq_item  exp_chi_snp_data_pkt;
    chi_snp_seq_item  exp_chi_snp_addr_pkt;

   // rsp  for coverage
    chi_rsp_seq_item  current_chi_crsp_pkt;
    chi_rsp_seq_item  prev_chi_crsp_pkt;
    chi_rsp_seq_item  prev_dvmop_chi_crsp_pkt;
    chi_rsp_seq_item  curr_dvmop_chi_crsp_pkt;
    //SFI channel member items
    smi_seq_item  m_cmd_req_pkt;
    smi_seq_item  m_cmd_rsp_pkt;
    smi_seq_item  m_str_req_pkt;
    smi_seq_item  m_str_req_pkt_2;
    smi_seq_item  m_str_rsp_pkt;
    smi_seq_item  m_str_rsp_pkt_2;
    smi_seq_item  m_snp_dtw_req_pkt;
    smi_seq_item  m_snp_dtw_rsp_pkt;
    smi_seq_item  m_snp_dtr_req_pkt;
    smi_seq_item  m_snp_dtr_rsp_pkt;
    smi_seq_item  m_dtr_req_pkt;
    smi_seq_item  m_dtr_req_for_dtw_hndbk_pkt;
    smi_seq_item  m_dtr_rsp_pkt;
    smi_seq_item  m_dtw_req_pkt;
    smi_seq_item  m_dtw_rsp_pkt;
    smi_seq_item  m_snp_req_pkt;
    smi_seq_item  m_snp_rsp_pkt;
    smi_seq_item  m_upd_req_pkt;
    smi_seq_item  m_upd_rsp_pkt;
    smi_seq_item  m_cmp_rsp_pkt;
    smi_seq_item  m_sys_req_pkt[$];
    smi_seq_item  m_sys_rsp_pkt[$];

    //SFI channel expected items
    smi_seq_item  exp_cmd_req_pkt;
    smi_seq_item  exp_cmd_rsp_pkt;
    smi_seq_item  exp_str_req_pkt;
    smi_seq_item  exp_str_rsp_pkt;
    smi_seq_item  exp_str_rsp_pkt_2;
    smi_seq_item  exp_snp_dtw_req_pkt;
    smi_seq_item  exp_snp_dtw_rsp_pkt;
    smi_seq_item  exp_snp_dtr_req_pkt;
    smi_seq_item  exp_snp_dtr_rsp_pkt;
    smi_seq_item  exp_dtr_req_pkt;
    smi_seq_item  exp_dtr_req_for_dtw_hndbk_pkt;
    smi_seq_item  exp_dtr_rsp_pkt;
    smi_seq_item  exp_dtw_req_pkt;
    smi_seq_item  exp_dtw_rsp_pkt;
    smi_seq_item  exp_snp_req_pkt;
    smi_seq_item  exp_snp_rsp_pkt;
    smi_seq_item  exp_upd_req_pkt;
    smi_seq_item  exp_upd_rsp_pkt;
    smi_seq_item  exp_cmp_rsp_pkt;
    smi_seq_item  exp_sys_req_pkt[$];
    smi_seq_item  exp_sys_rsp_pkt[$];


    // Transaction type;
    bit isRead;
    bit isWrite;
    bit isUpdate;
    bit isSnoop;
    bit isDVM;
    bit isDVMSnoop;
    bit isBarrier;
    bit isIsoModeTxnKill = 0;
    bit isIsoModeEn = 0;
    bit isPartialWrite = 0;
    bit is_pv_coarse_vec;
    string temp_sftf_type;
    bit isPartialRead = 0;
    bit isErrFlit;
    bit isNSset;
    bit is_crd_zero_err;
    bit NS_NSX;
    string addr_collison;
    bit dataless_req_on_dii = 0;
    int num_of_rdata_flit_exp = 0;
    bit rcvd_compack = 0;
    bit expt_compack = 0;
    int num_of_rdata_flit_max_exp = 0;
    int num_of_wdata_flit_exp = 0;
    int num_of_wdata_flit_max_exp = 0;
    bit data_ncbwrdatacompack;
    bit mkrdunq_part1_complete = 0;
    bit cmd_req_sent = 0;

    int chi_aiu_uid = 0;
    int tb_txnid = 0;
    int snp_chi_aiu_uid = 0;
    int snp_generated = 0;

    bit atomic_coh_part_done = 0;
    bit wr_cmo_first_part_done = 0;
    bit wr_cmo_comp_rcvd = 0;
    bit compcmo_comppersist_exp = 0;
    bit is_mpf3_match         = 0;
    int k_snp_rsp_non_data_err_wgt;
    bit is_stash_snoop;
    bit max_stash_snoops_reached;

    int m_req_aiu_id;
    // Other AIU information
    //<%=obj.BlockId + '_con'%>::AIUID_t      m_req_aiu_id;
    //<%=obj.BlockId + '_con'%>::SFISlvID_t   home_dce_unit_id;
    //<%=obj.BlockId + '_con'%>::SFISlvID_t   home_dmi_unit_id;
    int                                     memRegion;
    int                                     memRegionPrefix;
    bit                                     addrNotInMemRegion;
    <% var nDCEs = obj.AiuInfo[obj.Id].nAiuConnectedDces %>
    <% var nDVEs = obj.AiuInfo[obj.Id].nDVEs %>
    int nDCEs = <%=nDCEs%>;
    int nDVEs = <%=nDVEs%>;
    smi_targ_id_bit_t sys_req_targ_id[<%=(nDCEs+nDVEs)%>];
    //smi_src_id_bit_t;

    //-----------------------------------------------------------------------
    // Status bits of the transaction
    //-----------------------------------------------------------------------
    smi_exp_t  smi_exp;
    smi_rcvd_t smi_rcvd;
    chi_exp_t  chi_exp;
    chi_rcvd_t chi_rcvd;
    bit snp_rsp_rcvd = 0;
    chi_rsp_dbid_t dbid;
    bit dbid_val;
    bit dbid_updated;
    bit[5:0]  snp_rsp_cmstatus;
    chi_dat_datapull_t datapull;
    smi_addr_t         dvm_part2_smi_addr;
    bit                dvm_part2_smi_addr_val=0;
    chi_addr_t         dvm_part2_chi_addr;
    bit                dvm_part2_chi_addr_val = 0;
    int                normal_stsh_snoop=-1;

    //NF: commented for now, will add back when/if needed to keep the code clean. Delete if still commented after coverage is coded
    // For coverage
    //bit isSnoopReqAiuIDSameAsThisReqAiuId;
    //string orderOfPkts;

    //Bit indicating if its a coherent or non-coherent request
    bit isCoherent;

    //Bit indicating if its a multi-part DVM message
    bit isDVMMultiPart;

    //Bit indicating if its a DVM Sync message
    bit isDVMSync;
    bit isSnoopDVMSync;

    bit str_rsp_1_seen = 0;
    bit compack_seen = 0;

    bit dtwrsp_cmstatus_err_seen = 0;
    bit dtwrsp_cmstatus_data_err_seen = 0;
    bit dtwrsp_cmstatus_non_data_err_seen = 0;
    bit dtwrsp_cmstatus_err_str_rsp_seen = 0;
    bit strreq_cmstatus_err_seen = 0;
    bit strreq_cmstatus_non_data_err_seen = 0;

    chi_sysco_state_t m_sysco_st = DISABLED;
    smi_sysreq_op_t   m_sysreq_op = SMI_SYSREQ_NOP;
    chi_sysco_state_t smi_sysco_state = DISABLED, chi_sysco_state = DISABLED;
    chi_sysco_state_t smi_dvm_part2_sysco_state = DISABLED, chi_dvm_part2_sysco_state = DISABLED;
    bit is_sysco_snp_returned, is_SyscoNintf;

    bit exp_smi_tm = 0;

    //Transaction time stamps
    time t_creation;
    time t_latest_update;
    time t_chi_req_rcvd;
    time t_chi_rack_rcvd;
    time t_chi_rdata_sent;
    time t_chi_wdata_rcvd;
    time t_chi_snoop_data_rcvd;
    time t_chi_sysco_req_rcvd;
    time t_chi_sysco_ack_rcvd;

    time t_smi_cmd_req;
    time t_smi_cmd_rsp;
    time t_smi_str_req;
    time t_smi_str_rsp;
    time t_smi_dtw_req;
    time t_smi_dtw_rsp;
    time t_smi_dtr_req;
    time t_smi_dtr_req_perbeat[$][];
    time t_smi_dtr_rsp;
    time t_smi_snp_req;
    time t_smi_snp_rsp;
    time t_smi_upd_req;
    time t_smi_upd_rsp;
    time t_smi_sys_req;
    time t_smi_sys_rsp;

    time t_smi_snp_dtw_req;
    time t_smi_snp_dtw_rsp;
    time t_smi_snp_dtr_req;
    time t_smi_snp_dtr_rsp;

    time t_chi_snp_req;
    time t_chi_snp_rsp;
    time t_chi_snpresp;

    time t_smi_dtw_req_perbeat[];
    bit [2:0] dec_err_type;
    bit combined_writecmo_compack = 0;


    function new(string name = "chi_aiu_scb_txn",int req_aiu_id=0);
        this.m_req_aiu_id = req_aiu_id;
        //#Check.CHIAIU.v3.4.Connectivity.SysReq
        <% for(var i=0; i<obj.AiuInfo[obj.Id].nAiuConnectedDces; i++){ %>
        sys_req_targ_id[<%=i%>] = (<%=obj.AiuInfo[obj.Id].hexAiuConnectedDceFunitId[i]%> << WSMINCOREPORTID);
        <% } %>
        <% for(var i=0; i<nDVEs; i++){ %>
        sys_req_targ_id[<%=i+nDCEs%>] = (<%= obj.DveInfo[i].FUnitId %> << WSMINCOREPORTID);
        <% } %>
        `uvm_info(`LABEL, $psprintf("sys_req_targ_id=%0p", sys_req_targ_id), UVM_LOW)
    endfunction : new

    function bit [<%=obj.AiuInfo[obj.Id].concParams.hdrParams.wPriority%>-1:0] qos_mapping(int qos);
    <%if(obj.AiuInfo[obj.Id].fnEnableQos){%>
        int qos_array[<%=obj.AiuInfo[obj.Id].QosInfo.qosMap.length%>];
	<%obj.AiuInfo[obj.Id].QosInfo.qosMap.forEach(function(val, idx){ %>
	  qos_array[<%=idx%>] = <%=val%>;
	<%});%>
          foreach(qos_array[i])
		if(qos_array[i][qos])
			return(i);
    <%}else{%>
	qos_mapping='0;
    <%}%>
    endfunction//qos_mapping

    function void setup_chi_sysco_pkt(const ref chi_base_seq_item m_pkt, input bit is_SyscoNintf = 1);
        bit is_req;
        `uvm_info(`LABEL, $psprintf("setup_chi_sysco_pkt: sysco_req = 0x%0h, sysco_ack = 0x%0h", m_pkt.sysco_req, m_pkt.sysco_ack), UVM_LOW)
        t_creation = $time;
        //#Check.CHIAIU.sysco.corropcode
        if(!(smi_exp[`SYS_REQ_OUT] | smi_rcvd[`SYS_REQ_OUT])) begin
          `uvm_info(`LABEL, $psprintf("setup_chi_sysco_pkt: dbg-0"), UVM_DEBUG)
          case({m_pkt.sysco_ack, m_pkt.sysco_req})
            2'b00 : begin
              m_sysco_st = DISABLED;
              m_sysreq_op = SMI_SYSREQ_NOP;
            end
            2'b01 : begin
              m_sysco_st = CONNECT;
              m_sysreq_op = SMI_SYSREQ_ATTACH;
              is_req = 1'b1;
            end
            2'b11 : begin
              m_sysco_st = ENABLED;
              m_sysreq_op = SMI_SYSREQ_NOP;
            end
            2'b10 : begin
              m_sysco_st = DISCONNECT;
              m_sysreq_op = SMI_SYSREQ_DETACH;
              is_req = 1'b1;
            end
          endcase
          this.is_SyscoNintf = is_SyscoNintf;
          if(is_req) begin
            if(this.is_SyscoNintf) begin
              m_chi_sysco_req_pkt = new();
              m_chi_sysco_req_pkt.copy(m_pkt);
              t_chi_sysco_req_rcvd = $time;
              chi_rcvd[`CHI_SYSCO_REQ] = 1;
            end
            set_get_sysco_state("set", m_sysco_st, 0, 1, 0);
            smi_exp[`SYS_REQ_OUT] = 1;
            gen_exp_smi_sys_req(m_sysreq_op);
            `uvm_info(`LABEL, $psprintf("setup_chi_sysco_pkt: dbg-1"), UVM_DEBUG)
          end else begin
            //#Check.CHIAIU.sysco.sysreq
            `uvm_error(`LABEL_ERROR, $psprintf("Valid(connect/disconnect) request not received yet, but trying to setup a packet"))
          end
        end
        else begin
          if(this.is_SyscoNintf) begin
            `uvm_info(`LABEL, $psprintf("setup_chi_sysco_pkt: dbg-2"), UVM_DEBUG)
            case({m_pkt.sysco_ack, m_pkt.sysco_req})
              2'b00 : begin
                m_sysco_st = DISABLED;
                m_sysreq_op = SMI_SYSREQ_NOP;
              end
              2'b01 : begin
                m_sysco_st = CONNECT;
                m_sysreq_op = SMI_SYSREQ_ATTACH;
                is_req = 1'b1;
              end
              2'b11 : begin
                m_sysco_st = ENABLED;
                m_sysreq_op = SMI_SYSREQ_NOP;
              end
              2'b10 : begin
                m_sysco_st = DISCONNECT;
                m_sysreq_op = SMI_SYSREQ_DETACH;
                is_req = 1'b1;
              end
            endcase
          end
          else begin
            `uvm_info(`LABEL, $psprintf("setup_chi_sysco_pkt: dbg-3"), UVM_DEBUG)
            casex({m_pkt.sysco_ack, m_pkt.sysco_req})
              2'b0x : begin
                m_sysco_st = DISABLED;
                m_sysreq_op = SMI_SYSREQ_NOP;
              end
              2'b1x : begin
                m_sysco_st = ENABLED;
                m_sysreq_op = SMI_SYSREQ_NOP;
              end
            endcase
          end
          if(chi_exp[`CHI_SYSCO_ACK]) begin
            `uvm_info(`LABEL, $psprintf("setup_chi_sysco_pkt: dbg-4"), UVM_DEBUG)
            //#Check.CHIAIU.sysco.sysrsp
            //#Check.CHIAIU.sysco.syscoreqack
            if(is_req)
              `uvm_error(`LABEL_ERROR, $psprintf("Seems no stable state(%0s), but trying to generate CHI_SYSCO_ACK", m_sysco_st.name))
            m_chi_sysco_ack_pkt = new();
            m_chi_sysco_ack_pkt.copy(m_pkt);
            t_chi_sysco_ack_rcvd = $time;
            chi_exp[`CHI_SYSCO_ACK] = 1'b0;
            chi_rcvd[`CHI_SYSCO_ACK] = 1'b1;
            if(chi_exp || smi_exp)
              `uvm_error(`LABEL_ERROR, $psprintf("CHI_SYSCO_ACK received but expected fields are non-zero. chi_exp = %b, smi_exp = %b", chi_exp, smi_exp))
          end
          else begin
            if(!this.is_SyscoNintf) begin
              `uvm_info(`LABEL, $psprintf("setup_chi_sysco_pkt: dbg-5"), UVM_DEBUG)
              `uvm_info(`LABEL, $psprintf("Acknowledgement won't come for CSR testing?"), UVM_NONE)
            end
            else
              `uvm_error(`LABEL_ERROR, $psprintf("Acknowledgement should have expected?"))
          end
          set_get_sysco_state("set", m_sysco_st, 0, 1, 0);
        end
    endfunction

    function void setup_chi_req_pkt(const ref chi_req_seq_item m_pkt);
        bit [6-1 : 0] dmi_targ_prefetch;
        bit snp_attr_or_cmd_to_dce;
        int csr_addr_offset;
        addrMgrConst::intq regionq;
        ncore_memory_map m_map;
        addr_trans_mgr m_addr_mgr;
        bit [addrMgrConst::ADDR_WIDTH - 1 : 0] datless_tmp_addr;
        m_chi_req_pkt = new();
        m_chi_req_pkt.copy(m_pkt);
        t_chi_req_rcvd   = $time;
        chi_rcvd[`CHI_REQ] = 1;

        t_creation = $time;
        m_addr_mgr = addr_trans_mgr::get_instance(); 
        m_map = m_addr_mgr.get_memory_map_instance();
        regionq  = m_map.get_iocoh_mem_regions();
        datless_tmp_addr = m_chi_req_pkt.addr; 

        if (m_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL<%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>, WRITENOSNPZERO<%}%>} && (!(addr_trans_mgr::check_unmapped_add(m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type))) && (m_pkt.order == 'b00)) begin
            if (addrMgrConst::is_dii_addr(m_pkt.addr)) m_chi_req_pkt.memattr[0] = 0;
        end

        //update flags
        if (!mkrdunq_part1_complete) begin
            if($test$plusargs("perf_test")) begin
                `uvm_info(`LABEL, $psprintf("setup_chi_req_pkt: opcode= %0s, addr= %0h size= %0d secure= %0d order= %0d snpattr= %0d expcompack= %0d memattr= %h,", m_chi_req_pkt.opcode.name, m_chi_req_pkt.addr, m_chi_req_pkt.size, m_chi_req_pkt.ns, m_chi_req_pkt.order, m_chi_req_pkt.snpattr, m_chi_req_pkt.expcompack, m_chi_req_pkt.memattr), UVM_NONE)
            end else begin
                `uvm_info(`LABEL, $psprintf("setup_chi_req_pkt: opcode = %0s, expcompack = %0d memattribute = %h, addr = %0h", m_chi_req_pkt.opcode.name, m_chi_req_pkt.expcompack, m_chi_req_pkt.memattr, m_chi_req_pkt.addr), UVM_NONE)
            end
        end

         NS_NSX = addrMgrConst::get_addr_gprar_nsx(m_chi_req_pkt.addr);
        if ($test$plusargs("non_secure_access_test")) begin 
         case ({m_chi_req_pkt.ns,NS_NSX})
             2'h0 : isNSset = 'h0; 
             2'h1 : isNSset = 'h0; 
             2'h2 : isNSset = 'h1; 
             2'h3 : isNSset = 'h0; 
            default: isNSset = 'h0;
         endcase
        end

        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %> 
        if ((m_chi_req_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL,READNOSNP}) || ((m_chi_req_pkt.opcode inside {CLEANSHARED, CLEANINVALID, MAKEINVALID}) && (m_chi_req_pkt.snpattr == 0))) begin
            snp_attr_or_cmd_to_dce = 0;
        end else begin
            snp_attr_or_cmd_to_dce = 1;
        end
        <% } %>

        <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
            if (m_chi_req_pkt.opcode inside {STASHONCESEPSHARED, STASHONCESEPUNIQUE}) begin
                chi_exp[`CHI_CRESP] = 1;
                gen_exp_chi_cresp(COMP);
                return;
            end else if (m_chi_req_pkt.opcode inside {WRITEUNIQUEFULL_CLEANSHARED, WRITEUNIQUEPTL_CLEANSHARED, WRITENOSNPPTL_CLEANSHARED, WRITENOSNPPTL_CLEANINV}) begin
                chi_exp[`CHI_CRESP] = 1;
                chi_exp[`COMP_DATA_OUT] = 1;
                gen_exp_chi_data(COMPDATA);
                gen_exp_chi_cresp(DBIDRESP);
            end else if (m_chi_req_pkt.opcode inside {WRITEUNQFULL_CLEANSHAREDPERSISTSEP, WRITEUNQPTL_CLEANSHAREDPERSISTSEP, WRITENOSNPPTL_CLEANSHAREDPERSISTSEP}) begin
                chi_exp[`CHI_CRESP] = 1;
                chi_exp[`COMP_DATA_OUT] = 1;
                gen_exp_chi_data(COMPDATA);
                gen_exp_chi_cresp(DBIDRESP);
            end
        <%}%>					       

        //#Check.CHIAIU.v3.4.SCM.CreditLimit
        if (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (!(m_chi_req_pkt.opcode inside {DVMOP}))) begin 
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %> 
            if (addrMgrConst::check_addr_crd_zero(m_chi_req_pkt.addr,snp_attr_or_cmd_to_dce)) begin
        <% } else { %>
            if (addrMgrConst::check_addr_crd_zero(m_chi_req_pkt.addr,m_chi_req_pkt.snpattr)) begin
        <% } %>							       
                   is_crd_zero_err = 'h1;
            end else begin
                   is_crd_zero_err = 'h0;
            end
        end

        <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %> 
          if (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (m_chi_req_pkt.opcode == PREFETCHTARGET) && (addrMgrConst::dmi_credit_zero != 'h0)) begin 
               addrMgrConst::extract_dmi_intlv_bits_in_addr(m_chi_req_pkt.addr, dmi_targ_prefetch);
               if (addrMgrConst::dmi_credit_zero[dmi_targ_prefetch] == 1)begin 
                    is_crd_zero_err = 'h1;
               end else begin
                    is_crd_zero_err = 'h0;
               end
          end else if (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (m_chi_req_pkt.opcode == PREFETCHTARGET) && (addrMgrConst::dmi_credit_zero == 'h0)) begin 
               is_crd_zero_err = 'h0;
          end
        <% } %>							       

         if ($test$plusargs("pick_boundary_addr") && !addr_trans_mgr::check_unmapped_add(m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type) && (!(m_chi_req_pkt.opcode inside {DVMOP}))) begin
         NS_NSX = 1;
         end

        <%if(obj.AiuInfo[obj.Id].fnCsrAccess  == 0) {%>
          if($value$plusargs("csr_addr_offset=%d",csr_addr_offset))begin
          `uvm_info(`LABEL, $sformatf("csr_addr_offset = %0d",csr_addr_offset), UVM_DEBUG)
          end
        <% } %>							       
        //if ($test$plusargs("unmapped_add_access")) begin
        if (((!(m_chi_req_pkt.opcode inside {DVMOP})) && 
	    ((($test$plusargs("pick_boundary_addr") || $test$plusargs("unmapped_add_access")) && addr_trans_mgr::check_unmapped_add(m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) ||
	    ($test$plusargs("user_addr_for_csr")) || (isNSset == 1))) || (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (is_crd_zero_err == 1)) ||
	    ($test$plusargs("add_selfid_rd") && (m_chi_req_pkt.addr == (addrMgrConst::NRS_REGION_BASE | ('hff000 + csr_addr_offset)))) ||
	    ($test$plusargs("illegal_csr_access_rd") && (m_chi_req_pkt.addr inside {[addrMgrConst::NRS_REGION_BASE : (addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE)]}))) begin  //#Check.CHIAIU.v3.Error.decodeerr
         `uvm_info(`LABEL, $sformatf("Received unmapped address = 0x%0x",m_chi_req_pkt.addr), UVM_LOW)
         `uvm_info(`LABEL, $sformatf("Received unmapped address = 0x%0x, opcode = %0s, order = %0b",m_chi_req_pkt.addr, m_chi_req_pkt.opcode, m_chi_req_pkt.order), UVM_LOW)
          <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
          if (m_chi_req_pkt.opcode inside {write_ops}) begin
          <% } else { %>
          if (m_chi_req_pkt.opcode inside {write_ops, WRITEUNIQUEFULLSTASH, WRITEUNIQUEPTLSTASH}) begin
	  <% } %>
              chi_exp[`CHI_CRESP] = 1;
              gen_exp_chi_cresp(COMPDBIDRESP);
          end
          if (m_chi_req_pkt.opcode inside {DVMOP}) begin
              chi_exp[`CHI_CRESP] = 1;
              gen_exp_chi_cresp(DBIDRESP);
          end
          // ReadReceipt is sent if Order is set in the txn req, figure 2-6 CHI spec.
          // #Check.CHI.v3.6.MkRdUnq
          // #Check.CHI.v3.6.MkRdUnq_excl
          if ((m_chi_req_pkt.order == 'b10 || m_chi_req_pkt.order == 'b11)
          <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
              && m_chi_req_pkt.opcode inside {READNOSNP, READONCE, READONCECLEANINVALID, READONCEMAKEINVALID
                <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                    , MAKEREADUNIQUE
                <%}%>
                }) begin
          <%}else{%>
              && m_chi_req_pkt.opcode inside {READNOSNP, READONCE}) begin
  	  <%}%> //FIXME: sai - need to add readpreferunique?
              //chi_exp[`READ_RECPT_OUT] = 1;
              `uvm_info(`LABEL, $psprintf("add_smi_cmd_req: Setting READRECEIPT flag"), UVM_MEDIUM)
              chi_exp[`CHI_CRESP] = 1;
              chi_exp[`COMP_DATA_OUT] = 1;
              gen_exp_chi_data(COMPDATA);
              gen_exp_chi_cresp(READRECEIPT);
          end

          // Read commands for which no ReadReceipt is sent.
          if ((m_chi_req_pkt.order == 'b00 
          <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
              && m_chi_req_pkt.opcode inside {READNOSNP, READONCE, READONCECLEANINVALID, READONCEMAKEINVALID})
              || (m_chi_req_pkt.opcode inside {READCLEAN, READNOTSHAREDDIRTY, READSHARED, READUNIQUE
                <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                    , READPREFERUNIQUE
                    , MAKEREADUNIQUE
                <%}%>
              })) begin
          <%}else{%>
              && m_chi_req_pkt.opcode inside {READNOSNP, READONCE})
              || (m_chi_req_pkt.opcode inside {READCLEAN, READSHARED, READUNIQUE
                <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                    , MAKEREADUNIQUE
                <%}%>
              })) begin
	  <%}%>
            chi_exp[`COMP_DATA_OUT] = 1;
            gen_exp_chi_data(COMPDATA);
          end

          <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
          if (m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops}) begin
                  if (m_chi_req_pkt.opcode inside {atomic_dat_ops}) begin
                      atomic_coh_part_done = 1;
                      chi_exp[`CHI_CRESP] = 1;
                      chi_exp[`COMP_DATA_OUT] = 1;
                      gen_exp_chi_data(COMPDATA);
                      gen_exp_chi_cresp(DBIDRESP);
                  end else begin
                      chi_exp[`CHI_CRESP] = 1;
                      gen_exp_chi_cresp(COMPDBIDRESP);
                  end
          end // atomics if
	  <% } %>
          //moved to add_smi_cmd_req() because the packets can happen in any order after CMD_REQ
          //end else if (m_chi_req_pkt.opcode inside {read_ops}) begin
          //    smi_exp[`DTR_REQ_IN] = 1;
          //    gen_exp_smi_dtr_req();
          //    chi_exp[`COMP_DATA_OUT] = 1;
          //    gen_exp_chi_data(COMPDATA);
          //end
          //for dataless ops, CHI CRESP and STR_RSP could happen at the same cycle.
          //set the flag here to not run into race condition due to 2 packets happening at the same time.
          //if (m_chi_req_pkt.opcode inside {dataless_ops}) begin
          //    smi_exp[`STR_RSP_OUT] = 1;
          //    gen_exp_smi_str_rsp();
          //end
          <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
          if (m_chi_req_pkt.opcode inside {dataless_ops}) begin
          <% } else { %>
          if (m_chi_req_pkt.opcode inside {dataless_ops, STASHONCEUNIQUE, STASHONCESHARED}) begin
	  <% } %>
              chi_exp[`CHI_CRESP] = 1;
              <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                if(m_chi_req_pkt.opcode == CLEANSHAREDPERSISTSEP)
                gen_exp_chi_cresp(COMPPERSIST);
                else 
                gen_exp_chi_cresp(COMP);
             <% } else { %>
                gen_exp_chi_cresp(COMP);
             <% } %>
          end
          return;
        end
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        if (m_chi_req_pkt.opcode inside {dataless_ops}) begin
        <% } else { %>
        if (m_chi_req_pkt.opcode inside {dataless_ops, STASHONCEUNIQUE, STASHONCESHARED}) begin
	<% } %>
            foreach (regionq[idx]) begin
                 bit [63:0] lreg;
                 bit [63:0] hreg;

                lreg = addrMgrConst::memregion_boundaries[regionq[idx]].start_addr;
                hreg = addrMgrConst::memregion_boundaries[regionq[idx]].end_addr;

                if (datless_tmp_addr >= lreg && datless_tmp_addr < hreg) begin
                   dataless_req_on_dii = 'h1; 
                   $display("%0t CHI_SCB_TXN dataless opcode %0s addr %0h lreg %0h hreg %0h",$time, m_chi_req_pkt.opcode.name, m_chi_req_pkt.addr, lreg, hreg);
                end

            end
         end

        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
         if (m_chi_req_pkt.opcode inside {dataless_ops}) begin
        <% } else { %>
         if ((m_chi_req_pkt.opcode inside {'h8, 'h9, 'hA, CLEANSHAREDPERSIST
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                ,CLEANSHAREDPERSISTSEP
            <%}%>
         }) && (m_chi_req_pkt.snpattr == 'h0) && (dataless_req_on_dii == 1)) begin
	<% } %>
            smi_exp[`CMD_REQ_OUT] = 1;
            gen_exp_smi_cmd_req();
         end else begin
         end

        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        if (m_chi_req_pkt.opcode inside {dataless_ops} && (dataless_req_on_dii == 1)) begin
        <% } else { %>
        if (m_chi_req_pkt.opcode inside {dataless_ops, STASHONCEUNIQUE, STASHONCESHARED} && (dataless_req_on_dii == 1)) begin
	<% } %>
              chi_exp[`CHI_CRESP] = 1;
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                if(m_chi_req_pkt.opcode == CLEANSHAREDPERSISTSEP)
                gen_exp_chi_cresp(COMPPERSIST);
                else 
                gen_exp_chi_cresp(COMP);
        <% } else { %>
                gen_exp_chi_cresp(COMP);
            <% } %>
              return;

        end
        if (m_chi_req_pkt.opcode inside {unsupported_ops}) begin  //#Check.CHIAIU.v3.Error.unsuppoertedtxn
              chi_exp[`CHI_CRESP] = 1;
              gen_exp_chi_cresp(COMP);
        end
        if (m_chi_req_pkt.opcode inside {read_ops} && $test$plusargs("strreq_cmstatus_with_error")) begin
              //#Check.CHIAIU.v3.Error.errinatomic
              //#Check.CHIAIU.v3.Error.strcmstatuserror
              chi_exp[`COMP_DATA_OUT] = 1;
              gen_exp_chi_data(COMPDATA);
              if(m_chi_req_pkt.order!='0)
              begin
                chi_exp[`CHI_CRESP] = 1;
                gen_exp_chi_cresp(READRECEIPT);
              end
        end
        if(m_chi_req_pkt.expcompack)begin
          chi_exp[`CHI_SRESP] = 1;
	    end
        if (m_chi_req_pkt.opcode inside {read_ops} && m_pkt.addr !==  <%=obj.AiuInfo[obj.Id].CsrInfo.csrBaseAddress.replace("0x", "'h")%>FF_000) begin
            smi_exp[`CMD_REQ_OUT] = 1;
            `uvm_info(`LABEL, $psprintf("setup_chi_req_pkt: Setting CMD_REQ_OUT flag"), UVM_HIGH)
            gen_exp_smi_cmd_req();

        end
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        if (m_chi_req_pkt.opcode inside {write_ops, DVMOP}) begin
        <% } else { %>
        if (m_chi_req_pkt.opcode inside {write_ops, atomic_dtls_ops, atomic_dat_ops, WRITEUNIQUEPTLSTASH, WRITEUNIQUEFULLSTASH}) begin
	<% } %>
            smi_exp[`CMD_REQ_OUT] = 1;
            gen_exp_smi_cmd_req();
            if (m_chi_req_pkt.snpattr)
                exp_cmd_req_pkt.smi_targ_ncore_unit_id = addrMgrConst::map_addr2dce(m_chi_req_pkt.addr);
            else
                atomic_coh_part_done = 1;
            //Generate single packet with DBID and COMP information and if packets are
            //generated seperately by the AIU, then reset the flags accordingly
            //chi_exp[`CHI_CRESP] = 1;
            //gen_exp_chi_cresp(COMPDBIDRESP);
            //smi_exp[`DTW_REQ_OUT] = 1;
            //gen_exp_smi_dtw_req();
        end
        
        if (m_chi_req_pkt.opcode inside {DVMOP}) begin

            `ifdef USE_VIP_SNPS_CHI
            if(m_chi_req_pkt.addr[13:11] inside {3'b000,3'b001,3'b010,3'b011}) begin
                isDVM     = 'b1;
            end else if(m_chi_req_pkt.addr[13:11] inside {3'b100}) begin
                isDVMSync = 'b1;
            end 
            if(m_chi_req_pkt.is_legal_dvm_request(isDVMSync) == 0 ) begin
                `uvm_error(`LABEL_ERROR, $psprintf("CHI DVM Request message received does not respect DVMOp field value restrictions, see UVM_INFO above"))
            end
           `endif // ifdef USE_VIP_SNPS_CHI

            smi_exp[`CMD_REQ_OUT] = 1;
            gen_exp_smi_cmd_req();
            atomic_coh_part_done = 1;
            //Generate single packet with DBID and COMP information and if packets are
            //generated seperately by the AIU, then reset the flags accordingly
            chi_exp[`CHI_CRESP] = 1;
            gen_exp_chi_cresp(DBIDRESP);
            smi_exp[`DTW_REQ_OUT] = 1;
            gen_exp_smi_dtw_req();
        end

        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        if (m_chi_req_pkt.opcode inside {dataless_ops}) begin
        <% } else { %>
        if (m_chi_req_pkt.opcode inside {dataless_ops, STASHONCESHARED, STASHONCEUNIQUE}) begin
	<% } %>
            smi_exp[`CMD_REQ_OUT] = 1;
            gen_exp_smi_cmd_req();
            
        end
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        if (m_chi_req_pkt.opcode == PREFETCHTARGET) begin
            smi_exp[`CMD_REQ_OUT] = 1;
            gen_exp_smi_cmd_req();
        end
	<% } %>
        if (exp_cmd_req_pkt !== null
            && exp_cmd_req_pkt.smi_msg_type inside {CMD_CLN_SH_PER, CMD_CLN_INV, CMD_CLN_VLD}) begin
            exp_cmd_req_pkt.smi_vz = 'h1;
        end
    endfunction

    function void setup_chi_rdata_pkt(const ref chi_dat_seq_item m_pkt);
        num_of_rdata_flit_exp--;
        m_chi_read_data_pkt.push_back(m_pkt);
        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : CHI rdata packet received, num_of_rdata_flit_exp:%0d, expcompack:%0h", chi_aiu_uid, num_of_rdata_flit_exp, (m_chi_req_pkt !== null) ? m_chi_req_pkt.expcompack : 1),  UVM_LOW)
        <%if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-E') {%>
            if (num_of_rdata_flit_exp == 0) begin
                chi_exp[`COMP_DATA_OUT] = 0;
                chi_rcvd[`READ_DATA_IN] = 1;

                if((smi_rcvd[`DTR_RSP_OUT] || smi_rcvd[`SNP_DTR_RSP]) && !isErrFlit)
                    rdata_pkt_field_checks(); 
                if(smi_rcvd[`STR_RSP_OUT] == '1 && (smi_rcvd[`DTR_RSP_OUT]||smi_rcvd[`SNP_DTR_RSP]) && (smi_exp !== 'h0 || (chi_exp !== 'h0 && ((chi_exp & 'h2) !== 'h2))))
                        `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : Received STR Response AND CHI RDAT recieved from AIU, but all the expectation flags are not 0, smi_exp=%0h, chi_exp=%0h", chi_aiu_uid, smi_exp, chi_exp))

                if (m_chi_req_pkt !== null
                    && m_chi_req_pkt.expcompack) begin
                    chi_exp[`CHI_SRESP] = 1;
                    gen_exp_chi_cresp(COMPACK);
                    dbid_val = 1;
                    dbid = m_pkt.dbid;
                end else if (m_chi_snp_addr_pkt!== null
                            && m_chi_snp_addr_pkt.opcode inside {stash_snps} && !m_chi_snp_addr_pkt.donotdatapull) begin
                    chi_exp[`CHI_SRESP] = 1;
                    gen_exp_chi_cresp(COMPACK);
                    dbid_val = 1;
                    dbid = m_pkt.dbid;
                end
            end
        <%}else{%>
            // CHI-E allows for early compAck resposne
            if (num_of_rdata_flit_exp == 0) begin
                chi_exp[`COMP_DATA_OUT] = 0;
                chi_rcvd[`READ_DATA_IN] = 1;

                if((smi_rcvd[`DTR_RSP_OUT] || smi_rcvd[`SNP_DTR_RSP]) && !isErrFlit)
                    rdata_pkt_field_checks(); 
                if(smi_rcvd[`STR_RSP_OUT] == '1 && (smi_rcvd[`DTR_RSP_OUT]||smi_rcvd[`SNP_DTR_RSP]) && (smi_exp !== 'h0 || (chi_exp !== 'h0 && ((chi_exp & 'h2) !== 'h2))))
                        `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : Received STR Response AND CHI RDAT recieved from AIU, but all the expectation flags are not 0, smi_exp=%0h, chi_exp=%0h", chi_aiu_uid, smi_exp, chi_exp))
   
                if (m_chi_snp_addr_pkt!== null && m_chi_snp_addr_pkt.opcode inside {stash_snps} && !m_chi_snp_addr_pkt.donotdatapull && m_chi_snp_data_pkt[0] !== null && m_chi_snp_data_pkt[0].opcode == SNPRESPDATA ) begin
                  chi_exp[`CHI_SRESP] = 1;
                  gen_exp_chi_cresp(COMPACK);
                  dbid_val = 1;
                  dbid = m_pkt.dbid;
                end
            end 
            if (num_of_rdata_flit_exp >= 0 && !expt_compack) begin
                expt_compack = 1;
                if (m_chi_req_pkt !== null
                    && m_chi_req_pkt.expcompack) begin
                    chi_exp[`CHI_SRESP] = 1;
                    gen_exp_chi_cresp(COMPACK);
                    dbid_val = 1;
                    dbid = m_pkt.dbid;
                end else if (m_chi_snp_addr_pkt!== null
                            && m_chi_snp_addr_pkt.opcode inside {stash_snps} && !m_chi_snp_addr_pkt.donotdatapull && m_chi_snp_data_pkt[0] !== null && m_chi_snp_data_pkt[0].opcode == SNPRESPDATA && chi_exp[`COMP_DATA_OUT] == 'b1) begin
                    dbid_val = 1;
                    dbid = m_chi_snp_data_pkt[0].dbid;
                end else if (m_chi_snp_addr_pkt!== null
                            && m_chi_snp_addr_pkt.opcode inside {stash_snps} && !m_chi_snp_addr_pkt.donotdatapull) begin
                    chi_exp[`CHI_SRESP] = 1;
                    gen_exp_chi_cresp(COMPACK);
                    dbid_val = 1;
                    dbid_updated = 1;
                    dbid = m_pkt.dbid;
                end
            end
        <%}%>
        t_chi_rdata_sent  = $time;
    endfunction

    function void setup_chi_wdata_pkt(const ref chi_dat_seq_item m_pkt);
        m_chi_write_data_pkt.push_back(m_pkt);
        num_of_wdata_flit_exp--;
        `uvm_info(`LABEL, $psprintf("CHI wdata packet received, num_of_wdata_flit_exp:%0d, expcompack:%0h",num_of_wdata_flit_exp, m_chi_req_pkt.expcompack), UVM_LOW)
        if (m_pkt.opcode == WRDATACANCEL) begin
            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : WRDATACANCEL opcode seen", chi_aiu_uid), UVM_DEBUG)
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            if (!(m_chi_req_pkt.opcode inside {WRITEUNIQUEPTL, WRITENOSNPPTL})) begin
        <% } else { %>
            if (!(m_chi_req_pkt.opcode inside {WRITEUNIQUEPTL, WRITEUNIQUEPTLSTASH, WRITENOSNPPTL})) begin
        <% } %>
                `uvm_error(`LABEL_ERROR, $psprintf("WRDATACANCEL opcode should only be seen for WUPtl, WUPltStsh or WNSPtl, but was seen for opcode: %0s", m_chi_req_pkt.opcode.name))
            end
        end
        if (num_of_wdata_flit_exp == 0) begin
            chi_exp[`WRITE_DATA_IN] = 0;
            chi_rcvd[`WRITE_DATA_IN] = 1;
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                if (m_pkt.opcode == NCBWRDATACOMPACK && m_chi_req_pkt.expcompack) begin
                    chi_exp[`CHI_SRESP] = 0;
                    chi_rcvd[`CHI_SRESP] = 1;
                    data_ncbwrdatacompack = 1;
                end
            <%}%>
            if (((!(m_chi_req_pkt.opcode inside {DVMOP})) && (($test$plusargs("user_addr_for_csr")) ||
	(($test$plusargs("unmapped_add_access") || ($test$plusargs("pick_boundary_addr"))) && addr_trans_mgr::check_unmapped_add(m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || 
	($test$plusargs("non_secure_access_test") && (isNSset == 1)) || (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (is_crd_zero_err == 1)))) ||
	($test$plusargs("strreq_cmstatus_with_error") && m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops, write_bk, WRITEUNIQUEPTL, WRITEUNIQUEFULL<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>, combined_wr_c_ops<%}%>} && (m_str_req_pkt.smi_cmstatus_err == 1'b1))) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : unmapped/multiple address/atomic str_cmstatus_with_error/coherent_write str_cmstatus_with_error/copyback_write_cmo str_cmstatus_with_error hit case CHI_AIU will not generate DTWREQ for command with address = 0x%0x, opcode = %0s", chi_aiu_uid, m_chi_req_pkt.addr, m_chi_req_pkt.opcode), UVM_LOW)
                smi_exp[`DTW_REQ_OUT] = 0;
            end
            else begin
                smi_exp[`DTW_REQ_OUT] = 1;
            end
            gen_exp_smi_dtw_req();
            if (m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops} && m_chi_req_pkt.snpattr == 1) begin
                if ((!($test$plusargs("strreq_cmstatus_with_error") && (m_str_req_pkt.smi_cmstatus_err == 1'b1))) && m_str_req_pkt_2 != null) begin
                    exp_dtw_req_pkt.smi_targ_ncore_unit_id = m_str_req_pkt_2.smi_src_ncore_unit_id;
                end
            end
            if (m_chi_req_pkt.opcode == DVMOP) begin
                exp_dtw_req_pkt.smi_targ_ncore_unit_id = DVE_FUNIT_IDS[0]; 
            end


	    if(((m_chi_req_pkt.opcode == WRITECLEANPTL || m_chi_req_pkt.opcode == WRITEBACKPTL) && (m_chi_write_data_pkt[0].resp == 3'b110 || m_chi_write_data_pkt[0].resp == 3'b110) && m_chi_write_data_pkt[0].opcode==2'h2) ||
	       ((m_chi_req_pkt.opcode == WRITEUNIQUEPTL || m_chi_req_pkt.opcode == WRITENOSNPPTL) && m_chi_write_data_pkt[0].resp == 3'b000 && m_chi_write_data_pkt[0].opcode==2'h3)) begin
			exp_dtw_req_pkt.smi_msg_type = DTW_DATA_PTL ;
	    end

	    if(((m_chi_req_pkt.opcode == WRITECLEANFULL || m_chi_req_pkt.opcode == WRITEBACKFULL) && (m_chi_write_data_pkt[0].resp == 3'b110 || m_chi_write_data_pkt[0].resp == 3'b110) && m_chi_write_data_pkt[0].opcode==2'h2) ||
	       ((m_chi_req_pkt.opcode == WRITEUNIQUEFULL|| m_chi_req_pkt.opcode == WRITENOSNPFULL) && m_chi_write_data_pkt[0].resp == 3'b000 && m_chi_write_data_pkt[0].opcode==2'h3)) begin
			exp_dtw_req_pkt.smi_msg_type = DTW_DATA_DTY;
	    end

        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            if (chi_exp[`CHI_CRESP] == 0
                    && (m_chi_req_pkt.opcode !== DVMOP)) begin
                if (($test$plusargs("unmapped_add_access") && addr_trans_mgr::check_unmapped_add(m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || ($test$plusargs("pick_boundary_addr") && addr_trans_mgr::check_unmapped_add(m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || ($test$plusargs("user_addr_for_csr") && (!(m_chi_req_pkt.opcode inside {DVMOP}))) || ($test$plusargs("non_secure_access_test") && (isNSset == 1)) || (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (is_crd_zero_err == 1))) begin
                    `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : unmapped/multiple address hit case CHI_AIU will not generate STRRSP for command with address = 0x%0x, opcode = %0s", chi_aiu_uid, m_chi_req_pkt.addr, m_chi_req_pkt.opcode), UVM_HIGH)
                    smi_exp[`STR_RSP_OUT] = 0;
                end
                else begin
                    smi_exp[`STR_RSP_OUT] = 1;
                end
                gen_exp_smi_str_rsp();
            end
        <% } else { %>
            if (m_chi_req_pkt.opcode inside {stash_ops}
                    && m_str_req_pkt.smi_cmstatus_snarf == 1) begin
                if (m_chi_req_pkt.opcode == WRITEUNIQUEFULLSTASH) begin
                    smi_exp[`DTW_REQ_OUT] = 0;
                    smi_exp[`DTR_REQ_IN] = 1; //this is actually OUT from AIU
                    gen_exp_smi_dtr_req();//DTR_DATA_UNQ_DTY
                    exp_dtr_req_pkt.smi_msg_type = DTR_DATA_UNQ_DTY;
                end else if (m_chi_req_pkt.opcode == WRITEUNIQUEPTLSTASH) begin
                    smi_exp[`DTW_REQ_OUT] = 1;
                    gen_exp_smi_dtw_req();//DTW_MRG_MRD_UDTY // UDTY or other type?
                    exp_dtw_req_pkt.smi_msg_type = (m_chi_write_data_pkt[0].resp == 3'b000) ? DTW_MRG_MRD_INV :
                                                   (m_chi_write_data_pkt[0].resp == 3'b010) ? DTW_MRG_MRD_UCLN : DTW_MRG_MRD_UDTY;
                    exp_dtw_req_pkt.smi_mpf1_stash_nid = 'h0;
                    exp_dtw_req_pkt.smi_mpf1_argv = 'h0;
                end
            end
            else if (chi_exp[`CHI_CRESP] == 0 && (!(m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops, WRITEUNIQUEFULLSTASH, WRITEUNIQUEPTLSTASH, DVMOP}))) begin
		if ((($test$plusargs("unmapped_add_access") || $test$plusargs("pick_boundary_addr")) && addr_trans_mgr::check_unmapped_add(m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || $test$plusargs("user_addr_for_csr") || ($test$plusargs("non_secure_access_test") && (isNSset == 1)) || (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (is_crd_zero_err == 1))) begin
                    `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : unmapped/multiple address hit case CHI_AIU will not generate STRRSP for command with address = 0x%0x, opcode = %0s", chi_aiu_uid, m_chi_req_pkt.addr, m_chi_req_pkt.opcode), UVM_HIGH)
                    smi_exp[`STR_RSP_OUT] = 0;
                end
                else begin
                    smi_exp[`STR_RSP_OUT] = 1;
                end
                gen_exp_smi_str_rsp();
            end
        <% } %>
        end
        t_chi_wdata_rcvd  = $time;
    endfunction : setup_chi_wdata_pkt

    function void setup_chi_snpaddr_pkt(const ref chi_snp_seq_item m_pkt);
        m_chi_snp_addr_pkt = chi_snp_seq_item::type_id::create("m_chi_snp_addr_pkt");
        m_chi_snp_addr_pkt.copy(m_pkt);
        chi_exp[`CHI_SNP_REQ] = 0;
        chi_rcvd[`CHI_SNP_REQ] = 1;
        chi_exp[`CHI_SRESP] = 1;
        t_chi_snp_req = $time;
        gen_exp_chi_snp_rsp();
    endfunction : setup_chi_snpaddr_pkt

    function void setup_chi_snp_rsp_data(chi_dat_seq_item m_pkt);
        num_of_rdata_flit_max_exp = (2**6)/WBE;
        num_of_rdata_flit_exp++;
        m_chi_read_data_pkt.push_back(m_pkt);
	    m_chi_snp_data_pkt.push_back(m_pkt);
        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a SNP DATA packet, resp:0x%0h, datapull:0x%0h", chi_aiu_uid, m_pkt.resp, m_pkt.datapull), UVM_LOW)
        datapull = m_pkt.datapull;
        t_chi_snp_rsp = $time;
        if (num_of_rdata_flit_exp == ((2**6)/WBE)) begin
            snp_rsp_rcvd = 1;
            chi_exp[`CHI_SRESP] = 0;
            if (m_chi_read_data_pkt[0].opcode == SNPRESPDATAPTL) begin
                `uvm_info(`LABEL, $psprintf("Received a SNP DATA packet with PTL opcode"), UVM_LOW)
                smi_exp[`SNP_DTW_REQ_OUT] = 1;
                gen_exp_smi_snp_dtw();
                case (m_chi_snp_addr_pkt.opcode)
                    SNPONCE:
                    begin
                        exp_snp_dtw_req_pkt.smi_msg_type = DTW_MRG_MRD_INV;
                        exp_snp_dtw_req_pkt.smi_mpf1_stash_nid = 'h0;
                        exp_snp_dtw_req_pkt.smi_mpf1_argv = 'h0;
                        exp_snp_dtw_req_pkt.smi_mpf1 = m_snp_req_pkt.smi_mpf1_dtr_tgt_id;
                    end
                    SNPCLEAN,
                    SNPSHARED,
                    SNPNSHDTY:
                    begin
                        if (m_snp_req_pkt.smi_msg_type == SNP_STSH_SH)
                            exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_PTL;
                        else begin
                            exp_snp_dtw_req_pkt.smi_msg_type = DTW_MRG_MRD_UCLN;
                            exp_snp_dtw_req_pkt.smi_mpf1_stash_nid = 'h0;
                            exp_snp_dtw_req_pkt.smi_mpf1_argv = 'h0;
                            exp_snp_dtw_req_pkt.smi_mpf1 = m_snp_req_pkt.smi_mpf1_dtr_tgt_id;
                        end
                    end
                    SNPUNIQUE:
                    begin
                        if (m_snp_req_pkt.smi_msg_type == SNP_STSH_UNQ)
                            exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_PTL;
                        else if (m_snp_req_pkt.smi_msg_type == SNP_UNQ_STSH && m_chi_read_data_pkt[0].datapull == 0)
                            exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_PTL;
                        else begin
                           exp_snp_dtw_req_pkt.smi_msg_type = DTW_MRG_MRD_UDTY;
                           exp_snp_dtw_req_pkt.smi_mpf1_stash_nid = 'h0;
                           exp_snp_dtw_req_pkt.smi_mpf1_argv = 'h0;
                           exp_snp_dtw_req_pkt.smi_mpf1 = m_snp_req_pkt.smi_mpf1_dtr_tgt_id;
                        end
                        if (m_snp_req_pkt.smi_msg_type inside {SNP_NITCCI, SNP_NITCMI}) begin
                           exp_snp_dtw_req_pkt.smi_msg_type = DTW_MRG_MRD_INV;
                           exp_snp_dtw_req_pkt.smi_mpf1_stash_nid = 'h0;
                           exp_snp_dtw_req_pkt.smi_mpf1_argv = 'h0;
                           exp_snp_dtw_req_pkt.smi_mpf1 = m_snp_req_pkt.smi_mpf1_dtr_tgt_id;
                        end
                    end
                    default:
                        exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_PTL;
                endcase
            end else begin
                if ((m_chi_read_data_pkt[0].resp[2] == 1)
                   && ((m_snp_req_pkt.smi_msg_type inside {SNP_CLN_DTR, SNP_NITC, SNP_CLN_DTW, SNP_INV_DTW, SNP_UNQ_STSH})
                      || (m_snp_req_pkt.smi_msg_type == SNP_NOSDINT
                          && m_chi_read_data_pkt[0].resp inside {3'b101, 3'b110})
                      || (m_snp_req_pkt.smi_msg_type == SNP_NOSDINT
                          && m_chi_read_data_pkt[0].resp inside {3'b100}
                          && m_snp_req_pkt.smi_up !== 2'b01)
                      )) begin

                    smi_exp[`SNP_DTW_REQ_OUT] = 1;
                    gen_exp_smi_snp_dtw();
                    exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_DTY;

                    if (m_snp_req_pkt.smi_msg_type inside {SNP_CLN_DTW, SNP_INV_DTW, SNP_UNQ_STSH}) begin
                        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send DTW request", chi_aiu_uid), UVM_LOW)
                    end
                    if (m_snp_req_pkt.smi_msg_type inside {SNP_CLN_DTR, SNP_NITC, SNP_NOSDINT}) begin
                        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send DTW & DTR request", chi_aiu_uid), UVM_LOW)
                        exp_snp_dtw_req_pkt.smi_mpf1 = m_snp_req_pkt.smi_mpf1_dtr_tgt_id;
                        smi_exp[`SNP_DTR_REQ] = 1;
                        gen_exp_smi_snp_dtr();
                    end
                end else if (m_chi_snp_addr_pkt.opcode == SNPUNIQUE && (m_snp_req_pkt.smi_msg_type == SNP_INV_DTR) && (m_chi_read_data_pkt[0].resp == 3'b100)) begin
                    if ((m_snp_req_pkt.smi_up == 2'b11) && (m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)) begin // #Check.CHIAIU.v3.SP.SnpInvDtr
                        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send DTW request", chi_aiu_uid), UVM_LOW)
                        smi_exp[`SNP_DTW_REQ_OUT] = 1;
                        gen_exp_smi_snp_dtw();
                        exp_snp_dtw_req_pkt.smi_mpf1 = m_snp_req_pkt.smi_mpf1_dtr_tgt_id;
                        exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_DTY;
                    end
                    else if ((m_snp_req_pkt.smi_up[1:0] == 2'b01)) begin
                        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send DTR request", chi_aiu_uid), UVM_LOW)
                        smi_exp[`SNP_DTR_REQ] = 1;
                        gen_exp_smi_snp_dtr();
                        exp_snp_dtr_req_pkt.smi_msg_type = DTR_DATA_UNQ_DTY;
                    end
                    if(!smi_exp[`SNP_DTW_REQ_OUT]) begin
                        smi_exp[`SNP_RSP_OUT] = 1;
                        gen_exp_smi_snp_rsp();
                    end
                end else begin
                    if (m_snp_req_pkt.smi_msg_type == SNP_UNQ_STSH
                        && m_chi_read_data_pkt[0].resp == 3'b000) begin
                        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send SNPResp", chi_aiu_uid), UVM_LOW)
                        if(m_chi_snp_addr_pkt.opcode == SNPUNIQUE  //non target
			  ||( m_chi_snp_addr_pkt.opcode==SNPUNQSTASH && m_snp_req_pkt.smi_up == 2'b01)) begin//target
                        	smi_exp[`SNP_DTW_REQ_OUT] = 1;
                   		gen_exp_smi_snp_dtw();
                    		exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_CLN;
			end else begin
                        	smi_exp[`SNP_RSP_OUT] = 1;
                        	gen_exp_smi_snp_rsp();
                        	m_chi_read_data_pkt.delete();
			end
                    end else if (m_snp_req_pkt.smi_msg_type == SNP_UNQ_STSH
                                && m_chi_read_data_pkt[0].resp[1:0] !== '0) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("Unexpected RESP value ('b%0b) received for SNP_UNQ_STSH", m_chi_read_data_pkt[0].resp))
                    end else if (m_snp_req_pkt.smi_msg_type inside {SNP_STSH_SH, SNP_STSH_UNQ}) begin
                        if ( (!(m_chi_snp_addr_pkt.opcode inside {stash_snps}))
                            && m_snp_req_pkt.smi_msg_type == SNP_STSH_SH
                            && (m_chi_read_data_pkt[0].resp inside {3'b100, 3'b101})
                        ) begin
                            smi_exp[`SNP_DTW_REQ_OUT] = 1;
                            gen_exp_smi_snp_dtw();
                            exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_DTY;
                            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send DTW request", chi_aiu_uid), UVM_LOW)
                        end else if ( (!(m_chi_snp_addr_pkt.opcode inside {stash_snps}))
                            && m_snp_req_pkt.smi_msg_type == SNP_STSH_UNQ
                            && (m_chi_read_data_pkt[0].resp inside {3'b100})
                        ) begin
                            smi_exp[`SNP_DTW_REQ_OUT] = 1;
                            gen_exp_smi_snp_dtw();
                            exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_DTY;
                            `uvm_info(`LABEL, $psprintf("Setting expectations for AIU to send DTW request--  CHIAIU_UID: %0d", chi_aiu_uid), UVM_LOW)
                        end else if (m_snp_req_pkt.smi_msg_type == SNP_STSH_SH
                                    && m_chi_snp_addr_pkt.opcode == SNPSHARED
                                    && m_chi_read_data_pkt[0].resp inside {3'b000, 3'b001, 3'b011}) begin //SnpRespData_I,SC,SD from CHI-ConcertoCMapping Excel
                            smi_exp[`SNP_DTW_REQ_OUT] = 1;
                            gen_exp_smi_snp_dtw();
                            exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_CLN;
                            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send DTW request", chi_aiu_uid), UVM_LOW)
                        end else if (m_snp_req_pkt.smi_msg_type == SNP_STSH_UNQ
                                    && m_chi_snp_addr_pkt.opcode == SNPUNIQUE
                                    && m_chi_read_data_pkt[0].resp inside {3'b000}) begin //SnpRespData_I from CHI-ConcertoCMapping Excel
                            smi_exp[`SNP_DTW_REQ_OUT] = 1;
                            gen_exp_smi_snp_dtw();
                            exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_CLN;
                            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send DTW request", chi_aiu_uid), UVM_LOW)
                        end else begin
                            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send SNPResp", chi_aiu_uid), UVM_LOW)
                            smi_exp[`SNP_RSP_OUT] = 1;
                            gen_exp_smi_snp_rsp();
                            m_chi_read_data_pkt.delete();
                        end
                    end else begin
                        if (m_snp_req_pkt.smi_msg_type == SNP_NITCCI
                            && m_chi_read_data_pkt[0].resp[2] == 1) begin
                            smi_exp[`SNP_DTW_REQ_OUT] = 1;
                            gen_exp_smi_snp_dtw();
                            exp_snp_dtw_req_pkt.smi_mpf1 = m_snp_req_pkt.smi_mpf1_dtr_tgt_id;
                            exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_DTY;
                            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send DTW request", chi_aiu_uid), UVM_LOW)
                        end else if ((m_snp_req_pkt.smi_msg_type == SNP_INV_DTR) && (m_chi_read_data_pkt[0].resp == 3'b000) && (m_chi_snp_addr_pkt.opcode==SNPUNIQUE) && (m_snp_req_pkt.smi_up == 2'b11) && (m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)) begin
                            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send DTW request", chi_aiu_uid), UVM_LOW)
                            smi_exp[`SNP_DTW_REQ_OUT] = 1;
                            gen_exp_smi_snp_dtw();
                            exp_snp_dtw_req_pkt.smi_mpf1 = m_snp_req_pkt.smi_mpf1_dtr_tgt_id;
                            exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_CLN;
                        end
                        if(!smi_exp[`SNP_DTW_REQ_OUT]) begin
                          smi_exp[`SNP_RSP_OUT] = 1;
                          gen_exp_smi_snp_rsp();
                        end
                        if ((m_snp_req_pkt.smi_msg_type != SNP_INV_DTR) || ((m_snp_req_pkt.smi_msg_type == SNP_INV_DTR) && (m_snp_req_pkt.smi_up[1:0] == 2'b01))) begin
                            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to send DTR request", chi_aiu_uid), UVM_LOW)
                            smi_exp[`SNP_DTR_REQ] = 1;
                            gen_exp_smi_snp_dtr();
                            if (m_snp_req_pkt.smi_msg_type == SNP_INV_DTR) begin
                                exp_snp_dtr_req_pkt.smi_msg_type = DTR_DATA_UNQ_CLN;
                            end
                            else if (((m_snp_req_pkt.smi_msg_type == SNP_CLN_DTR) || (m_snp_req_pkt.smi_msg_type == SNP_VLD_DTR) || (m_snp_req_pkt.smi_msg_type == SNP_NOSDINT)) && (m_chi_read_data_pkt[0].resp == 3'b000)) begin
                                if (m_snp_req_pkt.smi_up[1:0] == 2'b01) begin
                                    exp_snp_dtr_req_pkt.smi_msg_type = DTR_DATA_UNQ_CLN;
                                end else begin
                                    exp_snp_dtr_req_pkt.smi_msg_type = DTR_DATA_SHR_CLN;
                                end
                            end
                        end
                    end
                end
            end
            if (m_chi_snp_addr_pkt.opcode == SNP_UNQ_STSH) begin 
                if (m_chi_read_data_pkt[0].datapull == 1) begin
                    exp_snp_dtw_req_pkt.smi_msg_type = DTW_MRG_MRD_UDTY;
                    exp_snp_dtw_req_pkt.smi_mpf1_stash_nid = 'h0;
                    exp_snp_dtw_req_pkt.smi_mpf1_argv = 'h0;
                end else
                    if(m_chi_read_data_pkt[0].resp == 3'b100 && m_chi_read_data_pkt[0].opcode == SNPRESPDATAPTL)
                    	exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_PTL;
		    else if(m_chi_read_data_pkt[0].resp == 3'b100 && m_chi_read_data_pkt[0].opcode == SNPRESPDATA)
                    	exp_snp_dtw_req_pkt.smi_msg_type = DTW_DATA_DTY;
            end

            if ( m_chi_snp_addr_pkt.opcode inside {stash_snps}
                 && m_pkt.datapull == 1
               ) begin
                if (m_chi_snp_addr_pkt.donotdatapull && m_pkt.datapull)
                    `uvm_error(`LABEL_ERROR, $psprintf("CHI Agent asserted datapull for a donotdatapull snoop"))
                dbid_val = 1;
                dbid = m_pkt.dbid;
                smi_exp[`SNP_DTR_REQ] = 1;
                gen_exp_smi_snp_dtr();
                exp_snp_dtr_req_pkt.smi_msg_type = DTR_DATA_UNQ_DTY;
                chi_exp[`COMP_DATA_OUT] = 1;
                gen_exp_chi_data(COMPDATA);
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Setting expectations for AIU to receive SNP_DTR request", chi_aiu_uid), UVM_LOW)
            end
        end
        if (m_snp_req_pkt.smi_up[1:0] == 2'b11 && (num_of_rdata_flit_exp == ((2**6)/WBE))) begin
            if (m_snp_req_pkt.smi_mpf3_intervention_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
                //uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : This AIU is not unique provider for SNP transaction, reseting any DTR flags that might have been set", chi_aiu_uid), UVM_MEDIUM)
                if (m_pkt.datapull == 1)
                    `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : DATAPULL is set, DTR flag wont be reset.", chi_aiu_uid), UVM_MEDIUM)
                else
                    smi_exp[`SNP_DTR_REQ] = 0;
                //smi_exp[`SNP_DTW_REQ_OUT] = 0; - Unique permission only applies to DTRs, DTW can still go out
                if (!smi_exp[`SNP_DTW_REQ_OUT]) begin
                    smi_exp[`SNP_RSP_OUT] = 1;
                    gen_exp_smi_snp_rsp();
                    m_chi_read_data_pkt.delete();
                end
            end
        end
        if (m_snp_req_pkt.smi_msg_type inside {SNP_STSH_UNQ, SNP_STSH_SH}
            && m_snp_req_pkt.smi_mpf1_stash_nid !== <%=obj.AiuInfo[obj.Id].FUnitId%> && ((num_of_rdata_flit_exp == ((2**6)/WBE)))) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : This AIU is not stash target for SNP transaction, reseting any DTR flags that might have been set", chi_aiu_uid), UVM_LOW)
                smi_exp[`SNP_DTR_REQ] = 0;
                if (!smi_exp[`SNP_DTW_REQ_OUT]) begin
                    smi_exp[`SNP_RSP_OUT] = 1;
                    gen_exp_smi_snp_rsp();
                    m_chi_read_data_pkt.delete();
                end
        end
         t_chi_snoop_data_rcvd = $time;
    endfunction : setup_chi_snp_rsp_data

    function void setup_chi_srsp_pkt(const ref chi_rsp_seq_item m_pkt);
        int csr_addr_offset;
        m_chi_srsp_pkt = chi_rsp_seq_item::type_id::create("m_chi_srsp_pkt");
        m_chi_srsp_pkt.copy(m_pkt);
        snp_rsp_rcvd = 1;
        chi_exp[`CHI_SRESP] = 0;
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            if (m_chi_req_pkt != null && (m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops})) begin
                combined_writecmo_compack = 1;
            end
        <%}%>
        chi_rcvd[`CHI_SRESP] = 1;
        datapull = m_pkt.datapull;
        if (m_chi_snp_addr_pkt !== null) begin
            if (m_pkt.opcode == COMPACK) begin
        	rcvd_compack = 1;
                if ( m_snp_dtr_req_pkt != null && m_snp_dtr_req_pkt.smi_rl == 2'b11) begin
                    smi_exp[`SNP_DTR_RSP] = 1;
                    gen_exp_smi_dtr_rsp();
                end
            end else begin
                t_chi_snpresp = $time;
                smi_exp[`SNP_RSP_OUT] = 1;
                gen_exp_smi_snp_rsp();
                if ( m_chi_snp_addr_pkt.opcode inside {stash_snps}
                     && m_pkt.datapull == 1
                   ) begin
                    if (m_chi_snp_addr_pkt.donotdatapull && m_pkt.datapull)
                        `uvm_error(`LABEL_ERROR, $psprintf("CHI Agent asserted datapull for a donotdatapull snoop"))
                    if((($test$plusargs("SNPrsp_with_non_data_error")) && (m_pkt.resperr != 0)) || ((k_snp_rsp_non_data_err_wgt != 0) && (m_pkt.resperr != 0))) begin
                        dbid_val = 0;
                    end else begin
                        dbid_val = 1;
                    end
                    dbid = m_pkt.dbid;
                    smi_exp[`SNP_DTR_REQ] = 1;
                    gen_exp_smi_snp_dtr();
                    if (m_snp_req_pkt.smi_msg_type == SNP_STSH_UNQ
                        || m_snp_req_pkt.smi_msg_type == SNP_STSH_SH
                    ) begin
                        exp_snp_dtr_req_pkt.smi_msg_type = DTR_DATA_UNQ_CLN;
                    end else begin
                        exp_snp_dtr_req_pkt.smi_msg_type = DTR_DATA_UNQ_DTY;
                    end
                    chi_exp[`COMP_DATA_OUT] = 1;
                    gen_exp_chi_data(COMPDATA);
                    `uvm_info(`LABEL, $psprintf("Setting expectations for AIU to receive SNP_DTR request"), UVM_LOW)
                end
            end
        end else begin
	    <%if(obj.AiuInfo[obj.Id].fnCsrAccess  == 0) {%>
            if($value$plusargs("csr_addr_offset=%d",csr_addr_offset))begin
              `uvm_info(`LABEL, $sformatf("csr_addr_offset = %0d",csr_addr_offset), UVM_DEBUG)
            end
            <% } %>
            if (((!(m_chi_req_pkt.opcode inside {DVMOP})) && ((m_chi_req_pkt.opcode inside {dataless_ops} && (dataless_req_on_dii == 1)) || $test$plusargs("user_addr_for_csr") || 
	(($test$plusargs("unmapped_add_access") || $test$plusargs("pick_boundary_addr")) && addr_trans_mgr::check_unmapped_add(m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || 
	($test$plusargs("non_secure_access_test") && (isNSset == 1)) || (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (is_crd_zero_err == 1)) ||
	($test$plusargs("add_selfid_rd") && (m_chi_req_pkt.addr == (addrMgrConst::NRS_REGION_BASE | ('hff000 + csr_addr_offset)))) ||
	($test$plusargs("illegal_csr_access_rd") && (m_chi_req_pkt.addr inside {[addrMgrConst::NRS_REGION_BASE : (addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE)]})))) ||
	((dtwrsp_cmstatus_err_seen === 1) && m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops} && (str_rsp_1_seen === 1))) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : unmapped/multiple address hit case CHI_AIU will not generate STRRSP for command with address = 0x%0x, opcode = %0s", chi_aiu_uid, m_chi_req_pkt.addr, m_chi_req_pkt.opcode), UVM_HIGH)
                smi_exp[`STR_RSP_OUT] = 0;
            end
            else begin
                smi_exp[`STR_RSP_OUT] = 1;
            end
            gen_exp_smi_str_rsp();
        end
    endfunction : setup_chi_srsp_pkt

    function void setup_chi_crsp_pkt(const ref chi_rsp_seq_item m_pkt);
        chi_tracetag_t dbidresp_tracetag;
        if (prev_chi_crsp_pkt == null) prev_chi_crsp_pkt = new();
        if (current_chi_crsp_pkt == null) current_chi_crsp_pkt = new();
        if (prev_dvmop_chi_crsp_pkt == null) prev_dvmop_chi_crsp_pkt = new();
        if (curr_dvmop_chi_crsp_pkt == null) curr_dvmop_chi_crsp_pkt = new();
        if (m_chi_crsp_pkt == null) m_chi_crsp_pkt = new();
        else if (m_chi_crsp_pkt.opcode == DBIDRESP)
            dbidresp_tracetag = m_chi_crsp_pkt.tracetag;
        m_chi_crsp_pkt.copy(m_pkt);

        if (m_chi_req_pkt.opcode == DVMOP) begin
              if (m_chi_crsp_pkt.opcode == DBIDRESP) begin
                  prev_dvmop_chi_crsp_pkt.copy(m_chi_crsp_pkt);
              end else begin
                  curr_dvmop_chi_crsp_pkt.copy(m_chi_crsp_pkt);
              end
        end
        if (exp_chi_crsp_pkt.opcode == COMPDBIDRESP
            && m_chi_crsp_pkt.opcode == DBIDRESP)
        begin
            exp_chi_crsp_pkt.opcode = DBIDRESP;
            exp_chi_crsp_pkt.compare(m_chi_crsp_pkt);
            exp_chi_crsp_pkt.opcode = COMP;
            prev_chi_crsp_pkt.opcode = DBIDRESP;
            prev_chi_crsp_pkt.copy(m_chi_crsp_pkt);
        end else begin
            exp_chi_crsp_pkt.compare(m_chi_crsp_pkt);
            current_chi_crsp_pkt.opcode = m_chi_crsp_pkt.opcode;
            current_chi_crsp_pkt.copy(m_chi_crsp_pkt);
        end
        m_chi_crsp_pkt.tracetag = dbidresp_tracetag;
        case(m_chi_crsp_pkt.opcode)
        // #Check.CHI.v3.6.WrNoSnpZero
        // #Check.CHI.v3.6.WrUnqZero
        COMPDBIDRESP:
            begin
                <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                    if (!(m_chi_req_pkt.opcode inside {wr_zero_ops})) begin
                        chi_exp[`WRITE_DATA_IN] = 1;
                        gen_exp_chi_wdata();
                    end
	        <% } else { %>
                    chi_exp[`WRITE_DATA_IN] = 1;
                    gen_exp_chi_wdata();
	        <% } %>

                if (m_chi_req_pkt.expcompack == 1'b1) begin
                    chi_exp[`CHI_SRESP] = 1;
                    gen_exp_chi_cresp(COMPACK);
                end
                chi_exp[`CHI_CRESP] = 0;
                // #Check.CHI.v3.6.WriteBackFullCleanInv
                // #Check.CHI.v3.6.WriteBackFullCleanSh
                // #Check.CHI.v3.6.WriteBackFullCleanShPerSep
                <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                    if(strreq_cmstatus_err_seen == 1 || strreq_cmstatus_non_data_err_seen == 1) begin
                        if(m_chi_req_pkt.opcode inside {WRITECLEANFULL_CLEANSHARED, WRITEBACKFULL_CLEANSHARED, WRITEBACKFULL_CLEANINVALID}) begin
                            chi_exp[`CHI_CRESP] = 1; 
                            gen_exp_chi_cresp(COMPCMO);
                        end else if(m_chi_req_pkt.opcode inside {WRITEBACKFULL_CLEANSHAREDPERSISTSEP, WRITECLEANFULL_CLEANSHAREDPERSISTSEP}) begin
                            chi_exp[`CHI_CRESP] = 1; 
                            gen_exp_chi_cresp(COMPPERSIST);
                        end
                    end
	            <%}%>
            end
        DBIDRESP:
            begin
                if (m_chi_req_pkt.opcode inside {atomic_dat_ops}) begin
                    chi_exp[`CHI_CRESP] = 0;
                    if (m_chi_req_pkt.expcompack == 1'b1) begin
                        chi_exp[`CHI_SRESP] = 1;
                        gen_exp_chi_cresp(COMPACK);
                    end
                end else if (m_chi_req_pkt.opcode == DVMOP) begin
                    chi_exp[`CHI_CRESP] = 0;
                    //DVM doesnt have COMPACK. COMP is only expected after CMPrsp message
                end else if ((m_chi_req_pkt.expcompack == 1'b1) && (data_ncbwrdatacompack == 0)) begin
                    chi_exp[`CHI_SRESP] = 1;
                    gen_exp_chi_cresp(COMPACK);
                end else begin
                    // Now we expect COMP packet to go out, but write data will start to arrive
                    chi_exp[`CHI_CRESP] = 1'b1;
                end
                <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                    if (!(m_chi_req_pkt.opcode inside {wr_zero_ops})) begin
                        chi_exp[`WRITE_DATA_IN] = 1;
                        gen_exp_chi_wdata();
                    end
	        <% } else { %>
                    chi_exp[`WRITE_DATA_IN] = 1;
                    gen_exp_chi_wdata();
	        <% } %>
            end
        READRECEIPT:
            begin
                `uvm_info(`LABEL, $psprintf("setup_chi_req_pkt: resetting READRECEIPT flag"), UVM_HIGH)
                chi_exp[`CHI_CRESP] = 0;
            end
        COMPACK:
            begin
                chi_exp[`CHI_SRESP] = 0;
                if (m_chi_snp_addr_pkt == null) begin
                    smi_exp[`STR_RSP_OUT] = 1;
                    gen_exp_smi_str_rsp();
                end
                // #Check.CHI.v3.6.WriteNoSnpFullCleanInv
                // #Check.CHI.v3.6.WriteNoSnpFullCleanSh
                // #Check.CHI.v3.6.WriteNoSnpFullCleanShPerSep
                // #Check.CHI.v3.6.WriteCleanFullCleanShPreSep
                // #Check.CHI.v3.6.WriteCleanFullCleanSh
                <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                    if ((m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops})) begin
                        combined_writecmo_compack = 1;
                    end
                <%}%>
            end
        COMP:
            begin
                chi_exp[`CHI_CRESP] = 0;
                wr_cmo_comp_rcvd = 1;
                if ((m_chi_req_pkt.expcompack == 1'b1) && (data_ncbwrdatacompack == 0) && (chi_rcvd[`CHI_SRESP]==1)) begin
                    chi_exp[`CHI_SRESP] = 0;
                end else if ((m_chi_req_pkt.expcompack == 1'b1) && (data_ncbwrdatacompack == 0)) begin
                    chi_exp[`CHI_SRESP] = 1;
                    gen_exp_chi_cresp(COMPACK);
                end
                <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                    if (m_chi_req_pkt.opcode == MAKEREADUNIQUE) begin
                        dbid_val = 1;
                    end

		if(dtwrsp_cmstatus_data_err_seen == 1 || dtwrsp_cmstatus_non_data_err_seen == 1 || (compcmo_comppersist_exp == 1) || ($test$plusargs("unmapped_add_access") && addr_trans_mgr::check_unmapped_add(m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || ($test$plusargs("non_secure_access_test") && isNSset == 1) || (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (is_crd_zero_err == 1))) begin
		    if(m_chi_req_pkt.opcode inside {WRITENOSNPFULL_CLEANSHARED, WRITENOSNPFULL_CLEANINVALID}) begin
		        chi_exp[`CHI_CRESP] = 1; 
		        gen_exp_chi_cresp(COMPCMO);
		    end else if(m_chi_req_pkt.opcode inside {WRITENOSNPFULL_CLEANSHAREDPERSISTSEP}) begin
		        chi_exp[`CHI_CRESP] = 1; 
		        gen_exp_chi_cresp(COMPPERSIST);
		    end
		end
	        <% } %>
            end
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
        COMPCMO:
            begin
                chi_exp[`CHI_CRESP] = 0;
                if (m_chi_req_pkt.expcompack == 1'b1 && !data_ncbwrdatacompack && !combined_writecmo_compack) begin
                    chi_exp[`CHI_SRESP] = 1;
                    gen_exp_chi_cresp(COMPACK);
                end else begin
                    chi_exp[`CHI_SRESP] = 0;
                end
            end
        COMPPERSIST:
            begin
                chi_exp[`CHI_CRESP] = 0;
                if (m_chi_req_pkt.expcompack == 1'b1 && !data_ncbwrdatacompack && !combined_writecmo_compack) begin
                    chi_exp[`CHI_SRESP] = 1;
                    gen_exp_chi_cresp(COMPACK);
                end else begin
                    chi_exp[`CHI_SRESP] = 0;
                end
            end
	<% } %>
        endcase
        //isCHIRackRcvd   = 1'b1;
        t_chi_rack_rcvd = $time;
    endfunction

    function void set_get_sysco_state(string op, inout chi_sysco_state_t state, input bit transition, is_chi_pkt, is_dvmp_part2);
      if(op == "set") begin
        if(!is_chi_pkt)
          if(!is_dvmp_part2)
            $cast(smi_sysco_state, state);
          else
            $cast(smi_dvm_part2_sysco_state, state);
        else
          if(!is_dvmp_part2)
            $cast(chi_sysco_state, state);
          else
            $cast(chi_dvm_part2_sysco_state, state);
      end else if(op == "get") begin
        if(!is_chi_pkt)
          if(!is_dvmp_part2)
            state = smi_sysco_state;
          else
            state = smi_dvm_part2_sysco_state;
        else
          if(!is_dvmp_part2)
            state = chi_sysco_state;
          else
            state = chi_dvm_part2_sysco_state;
      end
    endfunction

    function void setup4sysco_snp_req(chi_sysco_state_t sysco_state);
      `uvm_info(`LABEL, $psprintf("sysco_state::%0s", sysco_state.name), UVM_DEBUG)
      case(sysco_state)
        CONNECT,
        DISCONNECT,
        DISABLED : begin
            bit is_gen_exp_smi_snp_rsp;
            string snp_type_s = "Normal";

            // For disabled, AIU will return rsp immediately & not process
            if(sysco_state == DISABLED) begin
              if(isDVMSnoop) begin
                if((smi_rcvd[`DVM_PART2_IN] == 1) && (chi_rcvd[`CHI_SNP_REQ] == 0)) begin
                  chi_exp = '0;
                end
              end else begin
                chi_exp = '0;
              end
            end

            if (isDVMSnoop) begin
              if(smi_exp[`DVM_PART2_IN] == 0) begin
                is_gen_exp_smi_snp_rsp = 1;
                snp_type_s = "DVM";
              end
            end else begin
                is_gen_exp_smi_snp_rsp = 1;
                snp_type_s = "Normal";
            end
            if(is_gen_exp_smi_snp_rsp) begin
              smi_exp[`SNP_RSP_OUT] = 1;
              gen_exp_smi_snp_rsp();
              `uvm_info(`LABEL, $psprintf("Expected snp_rsp(%0s) generated as %0s", snp_type_s, exp_snp_rsp_pkt.convert2string), UVM_DEBUG)
            end
        end
        ENABLED : begin
            // traffic should flow normally
        end
        // unknown
        default : begin
          `uvm_error(`LABEL_ERROR, $psprintf("Unknown sysco_state(%0s)", sysco_state.name));
        end
      endcase
    endfunction : setup4sysco_snp_req

    function void setup_smi_snoop_req(const ref smi_seq_item m_pkt);
        m_snp_req_pkt  = new();
        m_snp_req_pkt.copy(m_pkt);
        chi_exp[`CHI_SNP_REQ] = 1;
        smi_rcvd[`SNP_REQ_IN] = 1;
        gen_exp_chi_snp_req();
        t_smi_snp_req     = $time;
        isSnoop = 1;
        if ((m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)) begin
            is_mpf3_match         = 1;
        end else begin
            is_mpf3_match         = 0;
        end
        if (m_pkt.smi_msg_type == SNP_DVM_MSG) begin
            smi_exp[`DVM_PART2_IN] = 1;
            isDVMSnoop = 1;
            if(m_pkt.smi_addr[13:11] inside {3'b100}) begin
                isSnoopDVMSync = 'b1;
            end 
        end
        setup4sysco_snp_req(smi_sysco_state);
    endfunction

    function void setup_part_dvm_snp(const ref smi_seq_item m_pkt);
       smi_exp[`DVM_PART2_IN] = 0;
       smi_rcvd[`DVM_PART2_IN] = 1;
       dvm_part2_smi_addr = m_pkt.smi_addr;
       dvm_part2_smi_addr_val = 1;
       chi_exp[`DVM_PART2_OUT] = 1;
       setup4sysco_snp_req(smi_dvm_part2_sysco_state);
    endfunction : setup_part_dvm_snp

    function void setup_chi_part_dvm_snp(const ref chi_snp_seq_item m_pkt);
        chi_exp[`DVM_PART2_OUT] = 0;
        dvm_part2_chi_addr_val = 1;
        dvm_part2_chi_addr = m_pkt.addr;
    endfunction : setup_chi_part_dvm_snp

////////////////////////////////////////////////////////////////////////////////
// SFI Add Function for all types of requeust
//
//
////////////////////////////////////////////////////////////////////////////////
    function void add_smi_sys_req(const ref smi_seq_item m_pkt);
        smi_seq_item tmp_pkt;
        tmp_pkt = smi_seq_item::type_id::create("m_sys_req_pkt");
        t_smi_sys_req = $time;
        tmp_pkt.copy(m_pkt);
        m_sys_req_pkt.push_back(tmp_pkt);

        smi_exp[`SYS_RSP_IN] = 1;
        gen_exp_smi_sys_rsp(tmp_pkt);

        if(m_sys_req_pkt.size == (nDCEs + nDVEs)) begin
          smi_exp[`SYS_REQ_OUT] = 0;
          smi_rcvd[`SYS_REQ_OUT] = 1;
          `uvm_info(`LABEL, $psprintf("all smi_exp[`SYS_REQ_OUT] generated. exp=%0d:act=%0d", m_sys_req_pkt.size, (nDCEs + nDVEs)), UVM_DEBUG)
        end
    endfunction

    function void add_smi_sys_rsp(const ref smi_seq_item m_pkt);
        smi_seq_item tmp_pkt;
        tmp_pkt = smi_seq_item::type_id::create("m_sys_rsp_pkt");
        t_smi_sys_rsp = $time;
        tmp_pkt.copy(m_pkt);
        m_sys_rsp_pkt.push_back(tmp_pkt);

        if(m_sys_rsp_pkt.size == (nDCEs + nDVEs)) begin
          smi_exp[`SYS_RSP_IN] = 0;
          smi_rcvd[`SYS_RSP_IN] = 1;
          if(this.is_SyscoNintf)
            chi_exp[`CHI_SYSCO_ACK] = 1'b1;
          else begin
            chi_base_seq_item m_pkt = chi_base_seq_item::type_id::create("m_pkt");
            case(m_sysco_st)
              CONNECT : begin
                m_pkt.sysco_ack = 1;
              end
              DISCONNECT : begin
                m_pkt.sysco_ack = 0;
              end
            endcase
            setup_chi_sysco_pkt(m_pkt, 0);
          end
          `uvm_info(`LABEL, $psprintf("all smi_exp[`SYS_RSP_IN] generated. exp=%0d:act=%0d", m_sys_rsp_pkt.size, (nDCEs + nDVEs)), UVM_DEBUG)
        end
    endfunction

    function void add_smi_cmd_req(const ref smi_seq_item m_pkt);

        //If this is atomic and receiving second CMDReq
        if (m_cmd_req_pkt !== null) begin
            if (m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops}) begin
                smi_exp[`CMD_REQ_OUT] = 0;
                smi_rcvd[`CMD_REQ_OUT] = 1;
                smi_exp[`CMD_RSP_IN] = 1;
                m_cmd_req_pkt.copy(m_pkt);
                gen_exp_smi_cmd_rsp();
                smi_exp[`STR_REQ_IN] = 1; //FIXME: Does STR_REQ have to be after DTR? 
                gen_exp_smi_str_req();
                exp_str_req_pkt.smi_src_ncore_unit_id = m_pkt.smi_targ_ncore_unit_id;
                exp_str_req_pkt.smi_rmsg_id = m_pkt.smi_msg_id;
                if (m_chi_req_pkt.opcode inside {atomic_dat_ops}) begin
                    smi_exp[`DTR_REQ_IN] = 1;
                    gen_exp_smi_dtr_req();
                    chi_exp[`COMP_DATA_OUT] = 1;
                    gen_exp_chi_data(COMPDATA);
                end 
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            end else if ((m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops}) && (wr_cmo_first_part_done == 1))begin
                smi_exp[`CMD_REQ_OUT] = 0;
                smi_rcvd[`CMD_REQ_OUT] = 1;
                smi_exp[`CMD_RSP_IN] = 1;
                m_cmd_req_pkt.copy(m_pkt);
                gen_exp_smi_cmd_rsp();
                smi_exp[`STR_REQ_IN] = 1; //FIXME: Does STR_REQ have to be after DTR? 
                gen_exp_smi_str_req();
                exp_str_req_pkt.smi_src_ncore_unit_id = m_pkt.smi_targ_ncore_unit_id;
                exp_str_req_pkt.smi_rmsg_id = m_pkt.smi_msg_id;
	<% } %>
            end else
                `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : Received a CMD REQ again", chi_aiu_uid))
            return;
        end
        m_cmd_req_pkt   = new();
        //isSFICMDReqSent = 1'b1;
        t_smi_cmd_req   = $time;
        m_cmd_req_pkt.copy(m_pkt);

        smi_exp[`CMD_REQ_OUT] = 0;
        smi_rcvd[`CMD_REQ_OUT] = 1;
        smi_exp[`CMD_RSP_IN] = 1;
        gen_exp_smi_cmd_rsp();
        smi_exp[`STR_REQ_IN] = 1; // does this and CMD_RSP have any order req?
        gen_exp_smi_str_req();
        //There is no flow/order of transactions, add all the flag setting here
        //if (m_chi_req_pkt.opcode inside {write_ops, atomic_dtls_ops}) begin
        //    chi_exp[`CHI_CRESP] = 1; //DBIDRESP for write expected
        //    gen_exp_chi_cresp(COMPDBIDRESP);
        //end

        if (m_chi_req_pkt.opcode inside {read_ops, atomic_dat_ops}) begin
            if ((m_chi_req_pkt.opcode inside {read_ops}) || ((m_chi_req_pkt.opcode inside {atomic_dat_ops}) && (m_chi_req_pkt.snpattr == 0))) begin
               smi_exp[`DTR_REQ_IN] = 1;
               gen_exp_smi_dtr_req();
            end
            chi_exp[`COMP_DATA_OUT] = 1;
            gen_exp_chi_data(COMPDATA);
        end
    endfunction


    function void add_smi_dtw_req(const ref smi_seq_item m_pkt);
        m_dtw_req_pkt   = new();
        t_smi_dtw_req   = $time;
        m_dtw_req_pkt.copy(m_pkt);
        smi_exp[`DTW_REQ_OUT] = 0;
        smi_rcvd[`DTW_REQ_OUT] = 1;
        smi_exp[`DTW_RSP_IN] = 1;
        gen_exp_smi_dtw_rsp();
        if (m_chi_req_pkt.opcode == DVMOP) begin
            smi_exp[`CMP_RSP_IN] = 1;
            gen_exp_smi_cmp_rsp();
        end
    endfunction

    function void add_smi_cmp_rsp(const ref smi_seq_item m_pkt);
        m_cmp_rsp_pkt = smi_seq_item::type_id::create("m_cmp_rsp_pkt");
        m_cmp_rsp_pkt.copy(m_pkt);
        smi_exp[`CMP_RSP_IN] = 0;
        smi_exp[`STR_RSP_OUT] = 1;
        gen_exp_smi_str_rsp();
        chi_exp[`CHI_CRESP] = 1;
        gen_exp_chi_cresp(COMP);
    endfunction : add_smi_cmp_rsp

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //Description: Compare CHI snoop data packet's fields with SNP DTW's fields
    //              This check wasnt incorporated in compare() function call, because DTW
    //              and CHI wdata can happen at the same cycle.
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    function void snp_dtw_data_checks();
        bit tracetag = 0;
        bit [2:0] 	l_dwid;
        if (m_chi_snp_data_pkt.size() !== m_dtw_req_pkt.smi_dp_data.size())
            `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : Num of CHI SNP data flits('d%0d) and number of data beats('d%0d) in SMI DTW dont match.", chi_aiu_uid, m_chi_snp_data_pkt.size(), m_dtw_req_pkt.smi_dp_data.size()));
  /*      foreach (m_chi_snp_data_pkt[idx]) begin
            //FIXME: OR data with BE
            if (m_chi_snp_data_pkt[idx].be !== m_dtw_req_pkt.smi_dp_be[idx]) begin
                `uvm_error(`LABEL_ERROR, $psprintf("SNP DTW BE MISMATCH: SNP data BE received on CHI interface (%0h) doesnt match the value(%0h) in DTW packet on SMI interface", m_chi_snp_data_pkt[idx].be, m_dtw_req_pkt.smi_dp_be[idx]))
            end else begin
                `uvm_info(`LABEL, $psprintf("SNP DTW BE MATCH: SNP data BE received on CHI interface (%0h) matches the value(%0h) in DTW packet on SMI interface", m_chi_snp_data_pkt[idx].be, m_dtw_req_pkt.smi_dp_be[idx]), UVM_DEBUG)
            end
            if (m_chi_snp_data_pkt[idx].be !=='0)
             if(m_chi_snp_data_pkt[idx].data !== m_dtw_req_pkt.smi_dp_data[idx]) begin
                `uvm_error(`LABEL_ERROR, $psprintf("SNP DTW DATA MISMATCH: SNP data received on CHI interface (%0h) doesnt match the value(%0h) in DTW packet on SMI interface", m_chi_snp_data_pkt[idx].data, m_dtw_req_pkt.smi_dp_data[idx]))
             end else begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : SNP DTW DATA MATCH: SNP data received on CHI interface (%0h) matches the value(%0h) in DTW packet on SMI interface.", chi_aiu_uid, m_chi_snp_data_pkt[idx].data, m_dtw_req_pkt.smi_dp_data[idx]), UVM_DEBUG)
             end
        end*/

       if(m_dtw_req_pkt.smi_msg_type == DTW_DATA_DTY && $test$plusargs("DTW_MSG_TYPE_CHK"))
	foreach(m_dtw_req_pkt.smi_dp_be[idx])
	  if(m_dtw_req_pkt.smi_dp_be[idx]!='1)
		`uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : DtwDataFullDty all ByteEn must be asserted.", chi_aiu_uid));

       for(int i=0; i< (64*8/<%=obj.AiuInfo[obj.Id].wData%>); i++) begin //snoop size must be cacheline size
         <%if(obj.AiuInfo[obj.Id].wData==128){ %>
			if(m_snp_req_pkt.smi_intfsize==2'b01||m_snp_req_pkt.smi_intfsize==2'b00 ) //128bits
	   			l_dwid = (i+m_chi_snp_addr_pkt.addr[2:1])*2;
                        else if(m_snp_req_pkt.smi_intfsize==2'b10) //256 bits
				l_dwid = (i +m_chi_snp_addr_pkt.addr[2]*2)*2;
        		if(m_dtw_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h1, l_dwid})
			  `uvm_error(get_full_name(), $sformatf("SNP DTW DWID mismatched. Expected: %x, Actual: %x", {l_dwid+3'h1, l_dwid}, m_dtw_req_pkt.smi_dp_dwid[i]))
                        foreach(m_chi_snp_data_pkt[idx])begin
			  if(m_chi_snp_data_pkt[idx].dataid == (l_dwid/2))begin
            		 	if (m_chi_snp_data_pkt[idx].be !== m_dtw_req_pkt.smi_dp_be[i]) begin
                			`uvm_error(`LABEL_ERROR, $psprintf("SNP DTW BE MISMATCH: SNP data BE received on CHI interface (%0h) doesnt match the value(%0h) in DTW packet on SMI interface", m_chi_snp_data_pkt[idx].be, m_dtw_req_pkt.smi_dp_be[i]))
            			end else begin
                			`uvm_info(`LABEL, $psprintf("SNP DTW BE MATCH: SNP data BE received on CHI interface (%0h) matches the value(%0h) in DTW packet on SMI interface", m_chi_snp_data_pkt[idx].be, m_dtw_req_pkt.smi_dp_be[i]), UVM_DEBUG)
				end
            		 	if (m_chi_snp_data_pkt[idx].be !=='0)
             			 if(m_chi_snp_data_pkt[idx].data !== m_dtw_req_pkt.smi_dp_data[i]) begin
                			`uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : 1SNP DTW DATA MISMATCH: SNP data received on CHI interface (%0h) doesnt match the value(%0h) in DTW packet on SMI interface.", chi_aiu_uid, m_chi_snp_data_pkt[idx].data, m_dtw_req_pkt.smi_dp_data[i]))
             		 	 end else begin
                			`uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : 1SNP DTW DATA MATCH: SNP data received on CHI interface (%0h) matches the value(%0h) in DTW packet on SMI interface.", chi_aiu_uid, m_chi_snp_data_pkt[idx].data, m_dtw_req_pkt.smi_dp_data[i]), UVM_DEBUG)
				 end
			  end
			end
         <%} else if(obj.AiuInfo[obj.Id].wData==256){%>
                        if(m_snp_req_pkt.smi_intfsize==2'b10) //256 bits
                        begin
	   		  l_dwid = (i+m_chi_snp_addr_pkt.addr[2])*4;
        		  if(m_dtw_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid})
			    `uvm_error(get_full_name(), $sformatf("SNP DTW DWID mismatched. Expected: %x, Actual: %x", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_dtw_req_pkt.smi_dp_dwid[i]))
		        end
                        else if (m_snp_req_pkt.smi_intfsize==2'b01 || m_snp_req_pkt.smi_intfsize==2'b00) //128 bits
                        begin
	   		  l_dwid = (i*2+m_chi_snp_addr_pkt.addr[2:1])*2;
			  if(m_snp_req_pkt.smi_intfsize==2'b00) l_dwid += m_chi_snp_addr_pkt.addr[0];
        		  if(m_dtw_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid})
			    `uvm_error(get_full_name(), $sformatf("SNP DTW DWID mismatched. Expected: %x, Actual: %x", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_dtw_req_pkt.smi_dp_dwid[i]))
		        end
                        foreach(m_chi_snp_data_pkt[idx])begin
			  if(m_chi_snp_data_pkt[idx].dataid == (l_dwid/2))begin
            		 	if (m_chi_snp_data_pkt[idx].be !== m_dtw_req_pkt.smi_dp_be[i]) begin
                			`uvm_error(`LABEL_ERROR, $psprintf("SNP DTW BE MISMATCH: SNP data BE received on CHI interface (%0h) doesnt match the value(%0h) in DTW packet on SMI interface", m_chi_snp_data_pkt[idx].be, m_dtw_req_pkt.smi_dp_be[i]))
            			end else begin
                			`uvm_info(`LABEL, $psprintf("SNP DTW BE MATCH: SNP data BE received on CHI interface (%0h) matches the value(%0h) in DTW packet on SMI interface", m_chi_snp_data_pkt[idx].be, m_dtw_req_pkt.smi_dp_be[i]), UVM_DEBUG)
				end
            		 	if (m_chi_snp_data_pkt[idx].be !=='0)
             			 if(m_chi_snp_data_pkt[idx].data !== m_dtw_req_pkt.smi_dp_data[i]) begin
                			`uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : 1SNP DTW DATA MISMATCH: SNP data received on CHI interface (%0h) doesnt match the value(%0h) in DTW packet on SMI interface.", chi_aiu_uid, m_chi_snp_data_pkt[idx].data, m_dtw_req_pkt.smi_dp_data[i]))
             		 	 end else begin
                			`uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : 1SNP DTW DATA MATCH: SNP data received on CHI interface (%0h) matches the value(%0h) in DTW packet on SMI interface.", chi_aiu_uid, m_chi_snp_data_pkt[idx].data, m_dtw_req_pkt.smi_dp_data[i]), UVM_DEBUG)
				 end
			  end
			end
	 <%}%>
       end


    endfunction : snp_dtw_data_checks

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //Description: Compare CHI data packet's fields which has to match with DTW's fields
    //              This check wasnt incorporated in compare() function call, because DTW
    //              and CHI wdata can happen at the same cycle.
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    function void wdata_pkt_field_checks();
        bit 		tracetag = 0;
        bit [2:0] 	l_dwid;
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            if (m_chi_req_pkt.opcode inside {wr_zero_ops}) begin
                //if (m_chi_write_data_pkt.size() !== m_dtw_req_pkt.smi_dp_data.size())
                //    `uvm_error(`LABEL_ERROR, $psprintf("Num of CHI Write data flits('d%0d) and number of data beats('d%0d) in SMI DTW dont match", m_chi_write_data_pkt.size(), m_dtw_req_pkt.smi_dp_data.size()));
                foreach (m_dtw_req_pkt.smi_dp_data[idx]) begin
                    //if ( !== m_dtw_req_pkt.smi_dp_be[idx]) begin
                    //    `uvm_error(`LABEL_ERROR, $psprintf("WRITE DATA BYTE ENABLE MISMATCH: Write data BE received on CHI interface (%0h) doesnt match the value(%0h) in DTW packet on SMI interface", m_chi_write_data_pkt[idx].be, m_dtw_req_pkt.smi_dp_be[idx]))
                    //end else begin
                    //    `uvm_info(`LABEL, $psprintf("WRITE DATA BE MATCH: Write data BE received on CHI interface (%0h) matches the value(%0h) in DTW packet on SMI interface", m_chi_write_data_pkt[idx].be, m_dtw_req_pkt.smi_dp_be[idx]), UVM_DEBUG)
                    //end
                    if(m_dtw_req_pkt.smi_msg_type == DTW_DATA_DTY) begin
 	                foreach(m_dtw_req_pkt.smi_dp_be[idx1]) begin
	                    if(m_dtw_req_pkt.smi_dp_be[idx1]!='1) begin
		                `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : WRITE DATA BYTE ENABLE MISMATCH: DtwDataFullDty all ByteEn must be asserted.", chi_aiu_uid));
                            end
                        end
                    end

                    if ('h0 !== m_dtw_req_pkt.smi_dp_data[idx]) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("WRITE DATA MISMATCH: Write data value (%0h) received in DTW packet on SMI interface is not zeros", m_dtw_req_pkt.smi_dp_data[idx]))
                    end else begin
                        `uvm_info(`LABEL, $psprintf("WRITE DATA MATCH: Write data value(%0h) received in DTW packet on SMI interface is zeros as expected", m_dtw_req_pkt.smi_dp_data[idx]), UVM_DEBUG)
                    end
                end // foreach
            end
            else begin
	<% } %>
                if (m_chi_write_data_pkt.size() !== m_dtw_req_pkt.smi_dp_data.size())
                    `uvm_error(`LABEL_ERROR, $psprintf("Num of CHI Write data flits('d%0d) and number of data beats('d%0d) in SMI DTW dont match", m_chi_write_data_pkt.size(), m_dtw_req_pkt.smi_dp_data.size()));
                foreach (m_chi_write_data_pkt[idx]) begin
                    //FIXME: OR data with BE
                    if (m_chi_write_data_pkt[idx].be !== m_dtw_req_pkt.smi_dp_be[idx]) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("WRITE DATA BYTE ENABLE MISMATCH: Write data BE received on CHI interface (%0h) doesnt match the value(%0h) in DTW packet on SMI interface", m_chi_write_data_pkt[idx].be, m_dtw_req_pkt.smi_dp_be[idx]))
                    end else begin
                        `uvm_info(`LABEL, $psprintf("WRITE DATA BE MATCH: Write data BE received on CHI interface (%0h) matches the value(%0h) in DTW packet on SMI interface", m_chi_write_data_pkt[idx].be, m_dtw_req_pkt.smi_dp_be[idx]), UVM_DEBUG)
                    end
                    // #Check.CHI.v3.6.DVM.REQ_dtw_req_part
                    if (m_chi_write_data_pkt[idx].data !== m_dtw_req_pkt.smi_dp_data[idx]) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("WRITE DATA MISMATCH: Write data received on CHI interface (%0h) doesnt match the value(%0h) in DTW packet on SMI interface", m_chi_write_data_pkt[idx].data, m_dtw_req_pkt.smi_dp_data[idx]))
                    end else begin
                        `uvm_info(`LABEL, $psprintf("WRITE DATA MATCH: Write data received on CHI interface (%0h) matches the value(%0h) in DTW packet on SMI interface", m_chi_write_data_pkt[idx].data, m_dtw_req_pkt.smi_dp_data[idx]), UVM_DEBUG)
                    end

                    if(m_dtw_req_pkt.smi_msg_type == DTW_DATA_DTY && $test$plusargs("DTW_MSG_TYPE_CHK"))
 	                foreach(m_dtw_req_pkt.smi_dp_be[idx])
	                    if(m_dtw_req_pkt.smi_dp_be[idx]!='1)
		                `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : DtwDataFullDty all ByteEn must be asserted.", chi_aiu_uid));


                    if (m_chi_write_data_pkt[idx].opcode == COPYBACKWRDATA) begin
                        if ((m_chi_write_data_pkt[idx].resp == 3'b000
                             && (m_dtw_req_pkt.smi_msg_type !== DTW_NO_DATA))
                        || ((m_chi_write_data_pkt[idx].resp == 3'b001
                             || m_chi_write_data_pkt[idx].resp == 3'b011)
                           && (m_dtw_req_pkt.smi_msg_type !== DTW_DATA_CLN))
                        || ((m_chi_write_data_pkt[idx].resp == 3'b110
                             || m_chi_write_data_pkt[idx].resp == 3'b111)
                            && m_chi_req_pkt.opcode inside {WRITEBACKFULL, WRITEBACKFULL}
                            && (m_dtw_req_pkt.smi_msg_type !== DTW_DATA_DTY))
                        || ((m_chi_write_data_pkt[idx].resp == 3'b110
                             || m_chi_write_data_pkt[idx].resp == 3'b111)
                           && m_chi_req_pkt.opcode inside {WRITEBACKPTL, WRITEBACKPTL}
                           && (m_dtw_req_pkt.smi_msg_type !== DTW_DATA_PTL))
                        ) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("WRITE COMPDATA RESP field MISMATCH: RESP seen on CHI interface (%0h) doesnt match the value derived from DTW packet' smi_msg_type(%0h)", m_chi_write_data_pkt[idx].resp, m_dtw_req_pkt.smi_msg_type))
                        end else begin
                            `uvm_info(`LABEL, $psprintf("WRITE COMPDATA RESP field MATCH: RESP seen on CHI interface (%0h) matches the value derived from DTW packet' smi_msg_type(%0h)", m_chi_write_data_pkt[idx].resp, m_dtw_req_pkt.smi_msg_type), UVM_DEBUG)
                        end

                    end else if (m_chi_write_data_pkt[idx].opcode inside
                            { NONCOPYBACKWRDATA
                              <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %> , NCBWRDATACOMPACK //  #Check.CHI.v3.6.NCBWrDataCompAck
                              <% } %>
                            } ) begin
                        if (m_chi_write_data_pkt[idx].resp == 3'b000 && 
		            m_chi_req_pkt.opcode inside {WRITEUNIQUEFULL, WRITENOSNPFULL} && 
                            m_dtw_req_pkt.smi_msg_type !== DTW_DATA_DTY) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("WRITE COMPDATA RESP field MISMATCH: RESP seen on CHI interface (%0h) doesnt match the value derived from DTW packet' smi_msg_type(%0h) smi_msg_id: %x", m_chi_write_data_pkt[idx].resp, m_dtw_req_pkt.smi_msg_type, m_dtw_req_pkt.smi_msg_id))
                        end else if (m_chi_write_data_pkt[idx].resp == 3'b000 && 
		            m_chi_req_pkt.opcode inside {WRITEUNIQUEPTL, WRITENOSNPPTL} && 
                            m_dtw_req_pkt.smi_msg_type !== DTW_DATA_PTL) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("WRITE COMPDATA RESP field MISMATCH: RESP seen on CHI interface (%0h) doesnt match the value derived from DTW packet' smi_msg_type(%0h) smi_msg_id: %x", m_chi_write_data_pkt[idx].resp, m_dtw_req_pkt.smi_msg_type, m_dtw_req_pkt.smi_msg_id))
                        end else begin
                            `uvm_info(`LABEL, $psprintf("WRITE COMPDATA RESP field MATCH: RESP seen on CHI interface (%0h) matches the value derived from DTW packet' smi_msg_type(%0h)", m_chi_write_data_pkt[idx].resp, m_dtw_req_pkt.smi_msg_type), UVM_DEBUG)
                        end
                    end
                    if (m_chi_write_data_pkt[idx].tracetag == 1) tracetag = 1;
                end // foreach
                //FIXME: Figure out the correct way to predict smi_tm in DTW and rewrite/uncomment this check
                //if (m_dtw_req_pkt.smi_tm != tracetag)
                //    `uvm_error(`LABEL_ERROR, $psprintf("TM field in DTW message(%0h) doesnt match tracetag(%0h) driven on CHI WDATA packets.",m_dtw_req_pkt.smi_tm, tracetag))
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            end
	<% } %>

       for(int i=0; i<m_dtw_req_pkt.smi_dp_data.size(); i++) begin
         <%if(obj.AiuInfo[obj.Id].wData==128){ %>
			//if(m_str_req_pkt.smi_intfsize==2'b01 || m_str_req_pkt.smi_intfsize==2'b00) //128bits
                                if(i==1 && m_chi_req_pkt.addr[4] && m_chi_write_data_pkt.size==2)
				  l_dwid = (m_chi_req_pkt.addr[5:4]-1)*2;
                                else
	   			  l_dwid = (i+m_chi_req_pkt.addr[5:4])*2;
                        //else if(m_str_req_pkt.smi_intfsize==2'b10) //256 bits
			//	l_dwid = (i+m_chi_req_pkt.addr[5:4])*2;
                        if ((m_chi_req_pkt.opcode == DVMOP) && (m_chi_req_pkt.addr[5:4] != m_chi_write_data_pkt[i].ccid) && (m_chi_write_data_pkt[i].ccid == 0)) begin
                            l_dwid = i*2;
                        end
			`uvm_info(get_type_name(), $sformatf("%m DTW DWID Info. Expected: %x, Actual: %x. \n Chi[5:4]: %x, smi_intsize: %x", {l_dwid+3'h1, l_dwid}, m_dtw_req_pkt.smi_dp_dwid[i], m_chi_req_pkt.addr[5:4], m_str_req_pkt.smi_intfsize), UVM_LOW)

        		if(m_dtw_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h1, l_dwid}) begin
                    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                        if (!(m_chi_req_pkt.opcode inside {wr_zero_ops})) begin
                            `uvm_error(get_type_name(), $sformatf("%m DTW DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x, smi_intsize: %x for txnid:%0d", {l_dwid+3'h1, l_dwid}, m_dtw_req_pkt.smi_dp_dwid[i], m_chi_req_pkt.addr[5:4], m_str_req_pkt.smi_intfsize, chi_aiu_uid))
                        end
                    <%}else{%>
			            `uvm_error(get_type_name(), $sformatf("%m DTW DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x, smi_intsize: %x for txnid:%0d", {l_dwid+3'h1, l_dwid}, m_dtw_req_pkt.smi_dp_dwid[i], m_chi_req_pkt.addr[5:4], m_str_req_pkt.smi_intfsize, chi_aiu_uid))
                    <%}%>
                end
         <%} else if(obj.AiuInfo[obj.Id].wData==256){%>
	   		l_dwid = (i+m_chi_req_pkt.addr[5])*4;
                        if ((m_chi_req_pkt.opcode == DVMOP) && (m_chi_req_pkt.addr[5:4] != m_chi_write_data_pkt[i].ccid) && (m_chi_write_data_pkt[i].ccid == 0)) begin
                            l_dwid = i*4;
                        end

        		if(m_dtw_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}) begin
                    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                        if (!(m_chi_req_pkt.opcode inside {wr_zero_ops})) begin
			                `uvm_error(get_type_name(), $sformatf("%m DTW DWID mismatched. Expected: %x, Actual: %x for txnid:%0d", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_dtw_req_pkt.smi_dp_dwid[i], chi_aiu_uid))
                        end
                    <%} else {%>
			            `uvm_error(get_type_name(), $sformatf("%m DTW DWID mismatched. Expected: %x, Actual: %x for txnid:%0d", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_dtw_req_pkt.smi_dp_dwid[i], chi_aiu_uid))
                    <%}%>
                end

	 <%}%>
       end

    endfunction : wdata_pkt_field_checks

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //Description: Compare CHI SNP Resp with SMI SNP RESP field values
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //TODO: This function has grown really big with big equations, need to rewrite this checks in cleaner way
    function void snp_rsp_field_checks();
        snp_rsp_cmstatus = {m_snp_rsp_pkt.smi_cmstatus_rv,
                            m_snp_rsp_pkt.smi_cmstatus_rs,
                            m_snp_rsp_pkt.smi_cmstatus_dc,
                            m_snp_rsp_pkt.smi_cmstatus_dt_aiu,
                            m_snp_rsp_pkt.smi_cmstatus_dt_dmi};

        if((smi_sysco_state inside {DISABLED}) || (smi_sysco_state inside {CONNECT, DISCONNECT} && is_sysco_snp_returned)) begin
          if (snp_rsp_cmstatus !== 5'b00000) begin
            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00000 based on smi_sysco_state(%0s) & is_sysco_snp_returned(%0d), but actual value is: 5'b%5b, SNP RESP NO DATA", smi_sysco_state.name, is_sysco_snp_returned, snp_rsp_cmstatus))
          end

          if (chi_rcvd !== 'h0) begin
            `uvm_error(`LABEL_ERROR, $psprintf("CHI_EXP should be 0 but actual value is:%0b", chi_rcvd))
          end

          `uvm_info(`LABEL, $psprintf("snp_rsp_field_checks: Skipping further checks as smi_sysco_state=%0s", smi_sysco_state.name), UVM_LOW)
        end
        if (m_chi_srsp_pkt !== null && !m_chi_srsp_pkt.resperr === 3) begin // Since resperr in CHI SRSP will only indicate non data error
            if ((m_chi_snp_addr_pkt.opcode == SNPUNIQUE) && (m_snp_req_pkt.smi_msg_type == SNP_INV_DTR) && (m_snp_rsp_pkt.smi_cmstatus_snarf !== 0)) begin
                `uvm_error(`LABEL_ERROR, $psprintf("For SNP_INV_DTR cmstatus_snarf should be 0 but actual value is:%0b", m_snp_rsp_pkt.smi_cmstatus_snarf))
            end
            case(m_chi_srsp_pkt.resp)
                //Invalid
                3'b000:
                begin
                    if (snp_rsp_cmstatus !== 5'b00000) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00000 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP NO DATA", m_chi_srsp_pkt.resp, snp_rsp_cmstatus))
                    end
                end
                //SC
                3'b001:
                begin
                    if ((m_chi_snp_addr_pkt.opcode == SNPUNIQUE) && (m_snp_req_pkt.smi_msg_type == SNP_INV_DTR) && (snp_rsp_cmstatus !== 5'b00000)) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00000 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP NO DATA", m_chi_srsp_pkt.resp, snp_rsp_cmstatus))
                    end
                    if (!(m_chi_snp_addr_pkt.opcode inside {SNPONCE, SNPCLEAN, SNPSHARED, SNPNSHDTY, SNPCLEANSHARED, SNPSTASHUNQ, SNPSTASHSHRD})) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP NO DATA", m_chi_srsp_pkt.resp, m_chi_snp_addr_pkt.opcode.name()))
                    end else begin
                        if (snp_rsp_cmstatus !== 5'b11000) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b11000 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP NO DATA", m_chi_srsp_pkt.resp, snp_rsp_cmstatus))
                        end
                    end
                end
                //UC
                3'b010:
                begin
                    if ((m_chi_snp_addr_pkt.opcode == SNPUNIQUE) && (m_snp_req_pkt.smi_msg_type == SNP_INV_DTR) && (snp_rsp_cmstatus !== 5'b00000)) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00000 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP NO DATA", m_chi_srsp_pkt.resp, snp_rsp_cmstatus))
                    end

                    if (!(m_chi_snp_addr_pkt.opcode inside {SNPONCE, SNPCLEANSHARED, SNPSTASHUNQ, SNPSTASHSHRD})) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP NO DATA", m_chi_srsp_pkt.resp, m_chi_snp_addr_pkt.opcode.name()))
                    end else begin
                        if (snp_rsp_cmstatus !== 5'b10000) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b10000 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP NO DATA", m_chi_srsp_pkt.resp, snp_rsp_cmstatus))
                        end
                    end
                end
                //SD
                3'b011:
                begin
                    if (!(m_chi_snp_addr_pkt.opcode inside {SNPSTASHSHRD, SNPSTASHUNQ})) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP NO DATA", m_chi_srsp_pkt.resp, m_chi_snp_addr_pkt.opcode.name()))
                    end else begin
                        if (snp_rsp_cmstatus !== 5'b10000) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b10000 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP NO DATA", m_chi_srsp_pkt.resp, snp_rsp_cmstatus))
                        end
                    end
                end
                default:
                    `uvm_error(`LABEL_ERROR, $psprintf("Received an RSVD response type for CHI RESP: 3'b%0b", m_chi_srsp_pkt.resp))
            endcase
        end
        else if (m_chi_read_data_pkt.size() !== 0 && !(m_chi_read_data_pkt[0].resperr === 2 || m_chi_read_data_pkt[0].resperr === 3)) begin
            if ((m_chi_snp_addr_pkt.opcode == SNPUNIQUE) && (m_snp_req_pkt.smi_msg_type == SNP_INV_DTR) && (m_snp_rsp_pkt.smi_cmstatus_snarf !== 0)) begin
                `uvm_error(`LABEL_ERROR, $psprintf("For SNP_INV_DTR cmstatus_snarf should be 0 but actual value is:%0b", m_snp_rsp_pkt.smi_cmstatus_snarf))
            end
	    case(m_chi_read_data_pkt[0].resp)  // #Check.CHIAIU.v3.SP.SnpInvDtrcmstatus
                //Invalid
                3'b000:
                begin
                    if (m_chi_snp_addr_pkt.opcode inside {SNPCLEANSHARED, SNPCLEANINVALID, SNPMAKEINVALID, SNPMKINVSTASH, SNPSTASHUNQ, SNPSTASHSHRD}) begin //SNPMAKEINVALIDSTSH
                        `uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP DATA", m_chi_read_data_pkt[0].resp, m_chi_snp_addr_pkt.opcode.name()))
                    end else begin
                        if ((m_chi_snp_addr_pkt.opcode inside {SNPSHARED, SNPCLEAN, SNPNSHDTY}) && (m_snp_req_pkt.smi_up == 'h01) && m_snp_req_pkt.smi_msg_type !== SNP_STSH_SH) begin
                            if (snp_rsp_cmstatus !== 5'b00110)
                                `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00110 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
                        end else if ((m_chi_snp_addr_pkt.opcode inside {SNPSHARED, SNPCLEAN, SNPNSHDTY}) && (m_snp_req_pkt.smi_up != 'h01) && m_snp_req_pkt.smi_msg_type !== SNP_STSH_SH) begin
                            if (snp_rsp_cmstatus !== 5'b00010)
                                `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00010 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA opcode : %0s msg_type : %0h addr : %0h r_msg_id : %0h", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus,m_chi_snp_addr_pkt.opcode,m_snp_req_pkt.smi_msg_type,m_snp_req_pkt.smi_addr, m_snp_rsp_pkt.smi_rmsg_id))
                        end
                        if ((m_chi_snp_addr_pkt.opcode == SNPSHARED && m_snp_req_pkt.smi_msg_type == SNP_STSH_SH) || (m_chi_snp_addr_pkt.opcode == SNPUNIQUE && m_snp_req_pkt.smi_msg_type inside {SNP_STSH_UNQ, SNP_UNQ_STSH})) begin
                            if (snp_rsp_cmstatus !== 5'b00001)
                                `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00001 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
		        end else if (m_chi_snp_addr_pkt.opcode == SNPUNQSTASH && m_snp_req_pkt.smi_msg_type == SNP_UNQ_STSH) begin //target
			    if(m_snp_req_pkt.smi_up == 2'b01 && snp_rsp_cmstatus !== 5'b00001) 
                                `uvm_error(`LABEL_ERROR, $psprintf("Unique presense. SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00001 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
			    else if(snp_rsp_cmstatus !== '0)
                                `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00000 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
                        end else if ((m_chi_snp_addr_pkt.opcode == SNPONCE || (m_chi_snp_addr_pkt.opcode == SNPUNIQUE && m_snp_req_pkt.smi_msg_type inside {SNP_NITCCI, SNP_NITCMI})) && (snp_rsp_cmstatus !== 5'b00010)) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00010 (Or 5'b00010 for SNPONCE/SNPUNIQUE) based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
                       	end else if ((m_chi_snp_addr_pkt.opcode == SNPUNIQUE) && (m_snp_req_pkt.smi_msg_type == SNP_INV_DTR) && (m_snp_req_pkt.smi_up == 'h1) && (snp_rsp_cmstatus !== 5'b00110) && (m_chi_read_data_pkt[0].opcode == SNPRESPDATA)) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00110 for SNP_INV_DTR based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA msg_id is %0h smi_up is : %0h addr is : %0h", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus, m_snp_rsp_pkt.smi_rmsg_id, m_snp_req_pkt.smi_up, m_snp_req_pkt.smi_addr))
                        end else if ((m_chi_snp_addr_pkt.opcode == SNPUNIQUE) && (m_snp_req_pkt.smi_msg_type == SNP_INV_DTR) && (m_snp_req_pkt.smi_up == 'h3) && (snp_rsp_cmstatus !== 5'b00001) && (m_chi_read_data_pkt[0].opcode == SNPRESPDATA) && (m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b00001 for SNP_INV_DTR based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
                        end
                    end
                end
                //SC
                3'b001:
                begin
		    if ((m_chi_snp_addr_pkt.opcode == SNPSHARED && m_snp_req_pkt.smi_msg_type == SNP_STSH_SH) && snp_rsp_cmstatus !== 5'b11001) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b11001 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
                    end else if (((m_chi_snp_addr_pkt.opcode == SNPSHARED && m_snp_req_pkt.smi_msg_type == SNP_VLD_DTR) || m_chi_snp_addr_pkt.opcode inside {SNPONCE, SNPCLEAN, SNPNSHDTY}) && snp_rsp_cmstatus !== 5'b11010) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b11010 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
		    end else if(m_chi_snp_addr_pkt.opcode inside {SNPUNIQUE, SNPCLEANSHARED, SNPCLEANINVALID, SNPMAKEINVALID, SNPMKINVSTASH, SNPUNQSTASH, SNPSTASHUNQ, SNPSTASHSHRD}) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP DATA", m_chi_read_data_pkt[0].resp, m_chi_snp_addr_pkt.opcode.name()))
		    end
                end
                //UC or UD
                3'b010:
                begin
                    if (m_chi_snp_addr_pkt.opcode == SNPONCE && ((snp_rsp_cmstatus !== 5'b10010 && m_chi_read_data_pkt[0].opcode == SNPRESPDATA) || (snp_rsp_cmstatus !== 5'b10011 && m_chi_read_data_pkt[0].opcode == SNPRESPDATAPTL))) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b10010(Or 5'b10011 for SNPRESPDATAPTL) based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
                    end else if(m_chi_snp_addr_pkt.opcode !== SNPONCE) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP DATA", m_chi_read_data_pkt[0].resp, m_chi_snp_addr_pkt.opcode.name()))
                    end
                end
                //SD
                3'b011:
                begin
		    if ((m_chi_snp_addr_pkt.opcode == SNPSHARED && m_snp_req_pkt.smi_msg_type == SNP_STSH_SH) && snp_rsp_cmstatus !== 5'b10001) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b10001 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
                    end else if(((m_chi_snp_addr_pkt.opcode == SNPSHARED && m_snp_req_pkt.smi_msg_type == SNP_VLD_DTR) || m_chi_snp_addr_pkt.opcode inside {SNPONCE, SNPCLEAN, SNPNSHDTY}) && snp_rsp_cmstatus !== 5'b10010) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} = 5'b10010 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
		    end else if(m_chi_snp_addr_pkt.opcode inside {SNPUNIQUE, SNPCLEANSHARED, SNPCLEANINVALID, SNPMAKEINVALID, SNPMKINVSTASH, SNPUNQSTASH, SNPSTASHUNQ, SNPSTASHSHRD}) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP DATA", m_chi_read_data_pkt[0].resp, m_chi_snp_addr_pkt.opcode.name()))
		    end
                end
                //I_PD
                3'b100:
                begin
		    if(m_chi_read_data_pkt[0].opcode == SNPRESPDATA) begin
			if(((m_chi_snp_addr_pkt.opcode == SNPSHARED && m_snp_req_pkt.smi_msg_type == SNP_STSH_SH) || (m_chi_snp_addr_pkt.opcode == SNPUNIQUE && (m_snp_req_pkt.smi_msg_type inside {SNP_STSH_UNQ, SNP_UNQ_STSH} || (m_snp_req_pkt.smi_msg_type == SNP_INV_DTR && m_snp_req_pkt.smi_up == 2'b11))) || (m_chi_snp_addr_pkt.opcode inside {SNPCLEANSHARED, SNPCLEANINVALID})) && snp_rsp_cmstatus !== 5'b00001) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b00001 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
			end else if(m_chi_snp_addr_pkt.opcode == SNPUNIQUE && m_snp_req_pkt.smi_msg_type == SNP_NITCMI && snp_rsp_cmstatus !== 5'b00010) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b00010 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
			end else if(((m_chi_snp_addr_pkt.opcode == SNPONCE) || (m_chi_snp_addr_pkt.opcode == SNPUNIQUE && m_snp_req_pkt.smi_msg_type == SNP_NITCCI) || (m_chi_snp_addr_pkt.opcode == SNPCLEAN && m_snp_req_pkt.smi_up !== 2'b01) || (m_chi_snp_addr_pkt.opcode == SNPNSHDTY && m_snp_req_pkt.smi_up !== 2'b01)) && snp_rsp_cmstatus !== 5'b00011) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b00011 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
			end else if(((m_chi_snp_addr_pkt.opcode == SNPSHARED && m_snp_req_pkt.smi_msg_type == SNP_VLD_DTR) || (m_chi_snp_addr_pkt.opcode == SNPUNIQUE && m_snp_req_pkt.smi_msg_type == SNP_INV_DTR && m_snp_req_pkt.smi_up == 2'b01) || (m_chi_snp_addr_pkt.opcode == SNPNSHDTY && m_snp_req_pkt.smi_up == 2'b01)) && snp_rsp_cmstatus !== 5'b00110) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b00110 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
			end else if(m_chi_snp_addr_pkt.opcode == SNPCLEAN && m_snp_req_pkt.smi_up == 2'b01 && snp_rsp_cmstatus !== 5'b00111) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b00111 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
		    	end else if(m_chi_snp_addr_pkt.opcode inside {SNPMAKEINVALID, SNPMKINVSTASH, SNPSTASHUNQ, SNPSTASHSHRD}) begin
			    `uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP DATA", m_chi_read_data_pkt[0].resp, m_chi_snp_addr_pkt.opcode.name()))
			end
		    end else if(m_chi_read_data_pkt[0].opcode == SNPRESPDATAPTL) begin
			if(((m_chi_snp_addr_pkt.opcode == SNPSHARED && m_snp_req_pkt.smi_msg_type == SNP_STSH_SH) || (m_chi_snp_addr_pkt.opcode == SNPUNIQUE && m_snp_req_pkt.smi_msg_type inside {SNP_STSH_UNQ, SNP_UNQ_STSH}) || (m_chi_snp_addr_pkt.opcode inside {SNPCLEANSHARED, SNPCLEANINVALID})) && snp_rsp_cmstatus !== 5'b00001) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b00001 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
			end else if(((m_chi_snp_addr_pkt.opcode == SNPONCE) || (m_chi_snp_addr_pkt.opcode == SNPUNIQUE && m_snp_req_pkt.smi_msg_type inside {SNP_NITCCI, SNP_NITCMI})) && snp_rsp_cmstatus !== 5'b00011) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b00011 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
			end else if(((m_chi_snp_addr_pkt.opcode inside {SNPCLEAN, SNPNSHDTY}) || (m_chi_snp_addr_pkt.opcode == SNPSHARED && m_snp_req_pkt.smi_msg_type == SNP_VLD_DTR) || (m_chi_snp_addr_pkt.opcode == SNPUNIQUE && m_snp_req_pkt.smi_msg_type == SNP_INV_DTR)) && snp_rsp_cmstatus !== 5'b00111) begin			
                            `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b00111 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
		    	end else if(m_chi_snp_addr_pkt.opcode inside {SNPMAKEINVALID, SNPMKINVSTASH, SNPSTASHUNQ, SNPSTASHSHRD}) begin
			    `uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP DATA", m_chi_read_data_pkt[0].resp, m_chi_snp_addr_pkt.opcode.name()))
			end
		    end else begin
			`uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP DATA", m_chi_read_data_pkt[0].resp, m_chi_snp_addr_pkt.opcode.name()))
		    end
                end
                //SC_PD
                3'b101:
                begin
		    if(((m_chi_snp_addr_pkt.opcode == SNPCLEANSHARED) || (m_chi_snp_addr_pkt.opcode == SNPSHARED && m_snp_req_pkt.smi_msg_type == SNP_STSH_SH)) && snp_rsp_cmstatus !== 5'b11001) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b11001 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
		    end else if(m_chi_snp_addr_pkt.opcode inside {SNPONCE, SNPCLEAN, SNPNSHDTY} && snp_rsp_cmstatus !== 5'b11011) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b11011 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
		    end else if(m_chi_snp_addr_pkt.opcode == SNPSHARED && m_snp_req_pkt.smi_msg_type == SNP_VLD_DTR && snp_rsp_cmstatus !== 5'b11110) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b11110 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
		    end else if(m_chi_snp_addr_pkt.opcode inside {SNPUNIQUE, SNPCLEANINVALID, SNPMAKEINVALID, SNPMKINVSTASH, SNPUNQSTASH, SNPSTASHUNQ, SNPSTASHSHRD}) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP DATA", m_chi_read_data_pkt[0].resp, m_chi_snp_addr_pkt.opcode.name()))
		    end
                end
                //UC_PD
                3'b110:
                begin
		    if(m_chi_snp_addr_pkt.opcode == SNPCLEANSHARED && snp_rsp_cmstatus !== 5'b10001) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("SMI SNP RSP was expected to have {RV,RS,DC,DT} =  5'b10001 based on CHI SNP RSP (3'b%3b), but actual value is: 5'b%5b, SNP RESP DATA", m_chi_read_data_pkt[0].resp, snp_rsp_cmstatus))
		    end else if(m_chi_snp_addr_pkt.opcode !== SNPCLEANSHARED) begin
                    	`uvm_error(`LABEL_ERROR, $psprintf("CHI SNP RSP illegal(3'b%3b) for CHI snoop type: %0s, SNP RESP DATA", m_chi_read_data_pkt[0].resp, m_chi_snp_addr_pkt.opcode.name()))
		    end
                end
                default:
                    `uvm_error(`LABEL_ERROR, $psprintf("Received a RSVD or illegal response type of CHI RESP: 3'b%0b for snoop type: %0s, SNP RESP DATA", m_chi_read_data_pkt[0].resp, m_chi_snp_addr_pkt.opcode.name()))
            endcase
        end
        else if(m_chi_srsp_pkt !== null && m_chi_srsp_pkt.resperr === 3) begin
            if ((m_chi_snp_addr_pkt.opcode == SNPUNIQUE) && (m_snp_req_pkt.smi_msg_type == SNP_INV_DTR) && (m_snp_rsp_pkt.smi_cmstatus_snarf !== 0)) begin
                `uvm_error(`LABEL_ERROR, $psprintf("For SNP_INV_DTR cmstatus_snarf should be 0 but actual value is:%0b", m_snp_rsp_pkt.smi_cmstatus_snarf))
            end
            /**
             * if non-data error occured, no further loading will happen for stashing snoops
             * TODO: this is a general condition but guarding as of now. i.e CONC-7061
             */
            if($test$plusargs("SNPrsp_with_non_data_error") || (k_snp_rsp_non_data_err_wgt != 0)) begin
              if(m_chi_snp_addr_pkt != null && m_chi_snp_addr_pkt.opcode inside {stash_snps}) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : clearing expectation when stashing snoop returned with error.", chi_aiu_uid), UVM_LOW)
                chi_exp = 0;
                smi_exp = 0;
              end
            end
        end
    endfunction : snp_rsp_field_checks

    function void add_smi_snp_dtr_req(const ref smi_seq_item m_pkt);
        m_snp_dtr_req_pkt  = new();
        t_smi_snp_dtr_req  = $time;
        //t_smi_dtr_req  = $time;
        m_snp_dtr_req_pkt.copy(m_pkt);
        smi_exp[`SNP_DTR_REQ] = 0;
        smi_rcvd[`SNP_DTR_REQ] = 1;
        if (m_snp_dtr_req_pkt.smi_rl !== 2'b00) begin
            smi_exp[`SNP_DTR_RSP] = 1;
            gen_exp_smi_dtr_rsp();
        end /*else if (! (m_chi_snp_addr_pkt.opcode inside {stash_snps})) begin
            smi_exp[`SNP_DTR_RSP] = 1;
            gen_exp_smi_dtr_rsp();
        end*/
     endfunction

    function void add_smi_snp_dtw_req(const ref smi_seq_item m_pkt);
        m_dtw_req_pkt  = new();
        t_smi_dtw_req   = $time;
        //isSFISNPDTRReqSent = 1'b1;
        t_smi_snp_dtw_req  = $time;
        m_dtw_req_pkt.copy(m_pkt);
        smi_exp[`SNP_DTW_REQ_OUT] = 0;
        smi_rcvd[`SNP_DTW_REQ_OUT] = 1;
        smi_exp[`SNP_DTW_RSP_IN] = 1;
        gen_exp_smi_dtw_rsp();
        //TODO: need to add check on data to make sure correct data went out on SNP DTW
    endfunction

    function void add_smi_snp_req(const ref smi_seq_item m_pkt);
        m_snp_req_pkt   = new();
        //isSFISNPReqRcvd = 1'b1;
        t_smi_snp_req   = $time;
        m_snp_req_pkt.copy(m_pkt);
    endfunction


    function void add_smi_dtr_req(const ref smi_seq_item m_pkt);
        m_dtr_req_pkt   = new();
        t_smi_dtr_req   = $time;
        m_dtr_req_pkt.copy(m_pkt);
        smi_exp[`DTR_REQ_IN] = 0;
        smi_rcvd[`DTR_REQ_IN] = 1;
        smi_exp[`DTR_RSP_OUT] = 1; //For stash ops, this will be input to AIU
        gen_exp_smi_dtr_rsp();
        //moved to add_smi_str_req function because DTR req and CHI DATA response can happen at the same time
        //chi_exp[`COMP_DATA_OUT] = 1;
        //gen_exp_chi_data(COMPDATA);
    endfunction


    function void add_smi_str_req(const ref smi_seq_item m_pkt);
        int mem_region;
        if (m_str_req_pkt == null) begin
            m_str_req_pkt   = new();
            m_str_req_pkt.copy(m_pkt);
        end else begin
            m_str_req_pkt_2  = new();
            m_str_req_pkt_2.copy(m_pkt);
        end
        t_smi_str_req   = $time;
        smi_exp[`STR_REQ_IN] = 0;
        smi_rcvd[`STR_REQ_IN] = 1;
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        if (m_chi_req_pkt.opcode == PREFETCHTARGET) begin
            smi_exp[`STR_RSP_OUT] = 1;
            gen_exp_smi_str_rsp();
        end
	<% } %>
        if(m_chi_req_pkt.opcode inside {read_ops})
        begin
                smi_exp[`STR_RSP_OUT] = 1;
                gen_exp_smi_str_rsp();
        end
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        if (m_chi_req_pkt.opcode inside {write_ops}) begin
        <% } else { %>
        if (m_chi_req_pkt.opcode inside {write_ops, WRITEUNIQUEFULLSTASH, WRITEUNIQUEPTLSTASH}) begin
	<% } %>
            chi_exp[`CHI_CRESP] = 1;
            gen_exp_chi_cresp(COMPDBIDRESP);
        end
        if (m_chi_req_pkt.opcode inside {DVMOP}) begin
            chi_exp[`CHI_CRESP] = 1;
            gen_exp_chi_cresp(DBIDRESP);
        end
        // ReadReceipt is sent if Order is set in the txn req, figure 2-6 CHI spec.
        if ((m_chi_req_pkt.order == 'b10 || m_chi_req_pkt.order == 'b11)
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            && m_chi_req_pkt.opcode inside {READNOSNP, READONCE, READONCECLEANINVALID, READONCEMAKEINVALID}) begin
        <%}else{%>
              && m_chi_req_pkt.opcode inside {READNOSNP, READONCE}) begin
	<%}%>
            //chi_exp[`READ_RECPT_OUT] = 1;
            `uvm_info(`LABEL, $psprintf("add_smi_cmd_req: Setting READRECEIPT flag"), UVM_HIGH)
            chi_exp[`CHI_CRESP] = 1;
            gen_exp_chi_cresp(READRECEIPT);
        end
	if ($test$plusargs("strreq_cmstatus_with_error") && m_str_req_pkt.smi_cmstatus_err === 1'b1 && (<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>(m_chi_req_pkt.opcode inside {combined_wr_c_ops} && (wr_cmo_first_part_done == 0)) || <% } %>m_chi_req_pkt.opcode inside {WRITEUNIQUEPTL, WRITEUNIQUEFULL<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>, WRITEUNIQUEZERO<% } %>})) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : CHI_AIU will generate STRRSP (first part of wrcmo/write coh) for command with address = 0x%0x, opcode = %0s", chi_aiu_uid, m_chi_req_pkt.addr, m_chi_req_pkt.opcode), UVM_LOW)
                smi_exp[`DTW_REQ_OUT] = 0;
                smi_exp[`STR_RSP_OUT] = 1;
                gen_exp_smi_str_rsp();
	end
	<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %> 
	else if (m_chi_req_pkt.opcode inside {wr_zero_ops}) begin
	    	smi_exp[`DTW_REQ_OUT] = 1;
                gen_exp_smi_dtw_req();
        end
	<% } %>
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        if (m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops}) begin
            if (atomic_coh_part_done == 0) begin 
                if (m_str_req_pkt.smi_cmstatus_err === 1'b1) begin
                  smi_exp[`CMD_REQ_OUT] = 0;
                  atomic_coh_part_done = 1;
                  if (m_chi_req_pkt.opcode inside {atomic_dat_ops}) begin
                    chi_exp[`CHI_CRESP] = 1;
                    gen_exp_chi_cresp(DBIDRESP);
                    chi_exp[`COMP_DATA_OUT] = 1;
                    gen_exp_chi_data(COMPDATA);
                  end else begin
                    chi_exp[`CHI_CRESP] = 1;
                    gen_exp_chi_cresp(COMPDBIDRESP);
                  end
                  if ($test$plusargs("strreq_cmstatus_with_error")) begin
                    `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : CHI_AIU will generate STRRSP (coherent part of atomic) for command with address = 0x%0x, opcode = %0s", chi_aiu_uid, m_chi_req_pkt.addr, m_chi_req_pkt.opcode), UVM_LOW)
                    smi_exp[`STR_RSP_OUT] = 1;
                    gen_exp_smi_str_rsp();
                  end
                end else begin
                  // coherent part of atomic transaction is done, now the non-coherent part, send CmdReq to DMI
		  if ($test$plusargs("zero_nonzero_crd_test") & addrMgrConst::check_addr_crd_zero(m_chi_req_pkt.addr,0)) begin 
		      is_crd_zero_err = 'h1;
		      if (m_chi_req_pkt.opcode inside {atomic_dat_ops}) begin
			atomic_coh_part_done = 1;
			chi_exp[`CHI_CRESP] = 1;
			gen_exp_chi_cresp(DBIDRESP);
		      end else begin
			chi_exp[`CHI_CRESP] = 1;
			gen_exp_chi_cresp(COMPDBIDRESP);
		      end
                      smi_exp[`STR_RSP_OUT] = 1;
                      gen_exp_smi_str_rsp();
		    end else begin
		      atomic_coh_part_done = 1;
		      smi_exp[`CMD_REQ_OUT] = 1;
		      gen_exp_smi_cmd_req();
		      exp_cmd_req_pkt.smi_ch = 0;
		      exp_cmd_req_pkt.smi_targ_ncore_unit_id = addrMgrConst::map_addr2dmi_or_dii(m_chi_req_pkt.addr, mem_region);
		  end
                end
            end else begin
                // Atomic Coherent part is done or only non-coherent part is being executed, send DBIDResp
                if (m_chi_req_pkt.opcode inside {atomic_dat_ops}) begin
                    atomic_coh_part_done = 1;
                    chi_exp[`CHI_CRESP] = 1;
                    gen_exp_chi_cresp(DBIDRESP);
                end else begin
                    chi_exp[`CHI_CRESP] = 1;
                    gen_exp_chi_cresp(COMPDBIDRESP);
                end
                smi_exp[`STR_RSP_OUT] = 1;
                gen_exp_smi_str_rsp();
            end //snpattr if
        end // atomics if
	<% } %>
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            if (m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops} && (wr_cmo_first_part_done == 0)) begin
                  wr_cmo_first_part_done = 1;
                  smi_exp[`CMD_REQ_OUT] = 1;
                  gen_exp_smi_cmd_req();
            end else if (m_chi_req_pkt.opcode inside {WRITENOSNPFULL_CLEANSHARED, WRITENOSNPFULL_CLEANINVALID, WRITEBACKFULL_CLEANSHARED, WRITECLEANFULL_CLEANSHARED, WRITEBACKFULL_CLEANINVALID} && (wr_cmo_first_part_done == 1)) begin
		if(m_chi_req_pkt.opcode inside {WRITENOSNPFULL_CLEANSHARED, WRITENOSNPFULL_CLEANINVALID} && wr_cmo_comp_rcvd == 1) begin
                    chi_exp[`CHI_CRESP] = 1;
                    gen_exp_chi_cresp(COMPCMO);
		end else if(m_chi_req_pkt.opcode inside {WRITENOSNPFULL_CLEANSHARED, WRITENOSNPFULL_CLEANINVALID} && wr_cmo_comp_rcvd == 0) begin
                    compcmo_comppersist_exp = 1;
		end
                    smi_exp[`STR_RSP_OUT] = 1;
                    gen_exp_smi_str_rsp_2();
            end else if (m_chi_req_pkt.opcode == MAKEREADUNIQUE && m_str_req_pkt.smi_cmstatus_exok && m_chi_req_pkt.excl) begin
                if (m_str_req_pkt.smi_cmstatus_exok) begin
                    chi_exp[`CHI_CRESP] = 1;
                    gen_exp_chi_cresp(COMP);
                    smi_exp[`STR_RSP_OUT] = 1;
                    gen_exp_smi_str_rsp();
                    if (mkrdunq_part1_complete) begin
                        chi_exp[`CHI_CRESP] = 0;
                    end
                end
            end else if (m_chi_req_pkt.opcode inside { WRITENOSNPFULL_CLEANSHAREDPERSISTSEP, WRITEBACKFULL_CLEANSHAREDPERSISTSEP, WRITECLEANFULL_CLEANSHAREDPERSISTSEP} && (wr_cmo_first_part_done == 1)) begin
		if(m_chi_req_pkt.opcode inside {WRITENOSNPFULL_CLEANSHAREDPERSISTSEP} && wr_cmo_comp_rcvd == 1) begin
                    chi_exp[`CHI_CRESP] = 1;
                    gen_exp_chi_cresp(COMPPERSIST);
		end else if(m_chi_req_pkt.opcode inside {WRITENOSNPFULL_CLEANSHAREDPERSISTSEP} && wr_cmo_comp_rcvd == 0) begin
                    compcmo_comppersist_exp = 1;
		end
                    smi_exp[`STR_RSP_OUT] = 1;
                    gen_exp_smi_str_rsp_2();
            end
	<% } %>
        //moved to add_smi_cmd_req() because the packets can happen in any order after CMD_REQ
        //end else if (m_chi_req_pkt.opcode inside {read_ops}) begin
        //    smi_exp[`DTR_REQ_IN] = 1;
        //    gen_exp_smi_dtr_req();
        //    chi_exp[`COMP_DATA_OUT] = 1;
        //    gen_exp_chi_data(COMPDATA);
        //end
        //for dataless ops, CHI CRESP and STR_RSP could happen at the same cycle.
        //set the flag here to not run into race condition due to 2 packets happening at the same time.

        if (m_chi_req_pkt.opcode inside {read_ops, atomic_dat_ops}) begin
          <%if(obj.testBench == "fsys"){ %>
            if ((m_str_req_pkt.smi_cmstatus_err == 1'b1) ) begin
                     smi_exp[`DTR_REQ_IN] = 0;
            end
          <% } %>
          <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){ %>
            if (!mkrdunq_part1_complete && m_chi_req_pkt.opcode == MAKEREADUNIQUE && m_chi_req_pkt.excl ) begin
                smi_exp[`DTR_REQ_IN] = 0;
                chi_exp[`CHI_SRESP] = 0;
                chi_exp[`COMP_DATA_OUT] = 0;
            end
          <%}%>

            if ($test$plusargs("strreq_cmstatus_with_error") && (m_str_req_pkt.smi_cmstatus_err == 1'b1)) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : For STRReq cmstatus with error case CHI_AIU will not recieve DTRREQ address = 0x%0x, opcode = %0s", chi_aiu_uid, m_chi_req_pkt.addr, m_chi_req_pkt.opcode), UVM_HIGH)
                smi_exp[`DTR_REQ_IN] = 0;
            end
        end
	
          <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){ %>
            if ($test$plusargs("strreq_cmstatus_with_error") && (m_str_req_pkt.smi_cmstatus_err == 1'b1) && m_chi_req_pkt.opcode inside {combined_wr_c_ops}) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : For STRReq cmstatus with error case in WRCMO CHI_AIU will not send 2nd CMDREQ address = 0x%0x, opcode = %0s", chi_aiu_uid, m_chi_req_pkt.addr, m_chi_req_pkt.opcode), UVM_LOW)
                    smi_exp[`CMD_REQ_OUT] = 0;
            end
          <%}%>

        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        if (!m_chi_req_pkt.expcompack && m_chi_req_pkt.opcode inside {dataless_ops}) begin
        <% } else { %>
        if (!m_chi_req_pkt.expcompack && m_chi_req_pkt.opcode inside {dataless_ops, STASHONCEUNIQUE, STASHONCESHARED}) begin
	<% } %>
            smi_exp[`STR_RSP_OUT] = 1;
            gen_exp_smi_str_rsp();
        end
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        if (m_chi_req_pkt.opcode inside {dataless_ops}) begin
        <% } else { %>
        if (m_chi_req_pkt.opcode inside {dataless_ops, STASHONCEUNIQUE, STASHONCESHARED}) begin
	<% } %>
            chi_exp[`CHI_CRESP] = 1;
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                if (m_chi_req_pkt.opcode == CLEANSHAREDPERSISTSEP) begin
                    gen_exp_chi_cresp(COMPPERSIST);
                end else begin
                    gen_exp_chi_cresp(COMP);
                end
            <%}else{%>
                gen_exp_chi_cresp(COMP);
            <%}%>
        end

    endfunction

// All response related functions

    function void add_smi_cmd_rsp(const ref smi_seq_item m_pkt);
        m_cmd_rsp_pkt    = new();
        smi_exp[`CMD_RSP_IN] = 0;
        smi_rcvd[`CMD_RSP_IN] = 1;
        //smi_exp[`STR_REQ_IN] = 1;
        //gen_exp_smi_str_req();
        t_smi_cmd_rsp    = $time;
        m_cmd_rsp_pkt.copy(m_pkt);
    endfunction


    function void add_smi_dtw_rsp(const ref smi_seq_item m_pkt);
        if (smi_exp[`DTW_RSP_IN]) begin
            m_dtw_rsp_pkt    = new();
            //isSFIDTWRespRcvd = 1'b1;
            t_smi_dtw_rsp    = $time;
            smi_exp[`DTW_RSP_IN] = 0;
            smi_rcvd[`DTW_RSP_IN] = 1;
            m_dtw_rsp_pkt.copy(m_pkt);
            wdata_pkt_field_checks();
            if(m_chi_req_pkt.opcode inside {write_ops}) begin
                smi_exp[`STR_RSP_OUT] = 1;
                gen_exp_smi_str_rsp();
                if(m_chi_req_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL} && ((m_chi_req_pkt.memattr[0] == 0) || (m_chi_req_pkt.memattr[0] && m_chi_req_pkt.excl)))
                begin
                        chi_exp[`CHI_CRESP] = 1;
			gen_exp_chi_cresp(COMP);
                end	
            end
            if (m_chi_req_pkt.opcode inside {stash_ops, atomic_dat_ops, atomic_dtls_ops <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>,combined_wr_nc_ops, combined_wr_c_ops<% } %>}) begin
                //Generate second expected STR_RSP too
                if (m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %> , combined_wr_nc_ops, combined_wr_c_ops<% } %>})
                    gen_exp_smi_str_rsp_2();
            end
	    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
	    if (($test$plusargs("dtwrsp_cmstatus_with_error") || $test$plusargs("error_test")) && (dtwrsp_cmstatus_err_seen === 1) && m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops}) begin 
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : CHI_AIU will not generate CMDREQ(for 2nd part of wrcmo) for command with address = 0x%0x, opcode = %0s", chi_aiu_uid, m_chi_req_pkt.addr, m_chi_req_pkt.opcode), UVM_LOW)
                smi_exp[`CMD_REQ_OUT] = 0;
		if(m_chi_req_pkt.opcode inside {WRITECLEANFULL_CLEANSHARED, WRITEBACKFULL_CLEANSHARED, WRITEBACKFULL_CLEANINVALID}) begin
		    chi_exp[`CHI_CRESP] = 1; 
		    gen_exp_chi_cresp(COMPCMO);
		end else if(m_chi_req_pkt.opcode inside {WRITEBACKFULL_CLEANSHAREDPERSISTSEP, WRITECLEANFULL_CLEANSHAREDPERSISTSEP}) begin
		    chi_exp[`CHI_CRESP] = 1; 
		    gen_exp_chi_cresp(COMPPERSIST);
		end
		
	    end
	    <% } %>
        end else if (smi_exp[`SNP_DTW_RSP_IN]) begin
            datapull = (m_chi_srsp_pkt !== null) ? m_chi_srsp_pkt.datapull : m_chi_read_data_pkt[0].datapull;
            m_snp_dtw_rsp_pkt    = new();
            t_smi_snp_dtw_rsp    = $time;
            smi_exp[`SNP_DTW_RSP_IN] = 0;
            smi_rcvd[`SNP_DTW_RSP_IN] = 1;
            m_snp_dtw_rsp_pkt.copy(m_pkt);
            //snp_dtw_data_checks();
            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : SNP DTW REQ CHECK start", chi_aiu_uid), UVM_HIGH)
            compare_snoop_data(m_chi_snp_data_pkt, m_dtw_req_pkt);
            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : SNP DTW REQ CHECK done", chi_aiu_uid), UVM_HIGH)
         //   if (smi_exp[`SNP_DTR_RSP] !== 1 && smi_exp[`SNP_DTR_REQ] !== 1) begin
                smi_exp[`SNP_RSP_OUT] = 1;
                gen_exp_smi_snp_rsp();
        //    end
            if (smi_exp[`SNP_DTR_REQ] == 1 && datapull == 3'b001) begin
                smi_exp[`SNP_RSP_OUT] = 1;
                gen_exp_smi_snp_rsp();
            end
            if (m_chi_snp_addr_pkt.opcode inside {stash_snps} && m_chi_read_data_pkt.size() !== 0)
                m_chi_read_data_pkt.delete();
        end
    endfunction


    function void add_smi_snp_dtr_rsp(const ref smi_seq_item m_pkt);
        m_snp_dtr_rsp_pkt  = new();
        t_smi_snp_dtr_rsp  = $time;
        m_snp_dtr_rsp_pkt.copy(m_pkt);
        smi_exp[`SNP_DTR_RSP] = 0;
        smi_rcvd[`SNP_DTR_RSP] = 1;
        if(!isErrFlit) rdata_pkt_field_checks();
    endfunction

    function void add_smi_snp_rsp(const ref smi_seq_item m_pkt);
        m_snp_rsp_pkt    = new();
        smi_exp[`SNP_RSP_OUT] = 0;
        smi_rcvd[`SNP_RSP_OUT] = 1;
        t_smi_snp_rsp    = $time;
        m_snp_rsp_pkt.copy(m_pkt);
        if(smi_sysco_state inside {DISABLED, CONNECT, DISCONNECT}) begin
          if(!chi_rcvd[`CHI_SNP_REQ]) begin
            is_sysco_snp_returned = 1'b1;
            chi_exp = 0;
          end
        end
        snp_rsp_field_checks();
    endfunction


    function void add_smi_dtr_rsp(const ref smi_seq_item m_pkt);
        if (smi_exp[`DTR_RSP_OUT]) begin
            m_dtr_rsp_pkt    = new();
            smi_exp[`DTR_RSP_OUT] = 0;
            smi_rcvd[`DTR_RSP_OUT] = 1;
            t_smi_dtr_rsp    = $time;
            m_dtr_rsp_pkt.copy(m_pkt);
            if(chi_rcvd[`READ_DATA_IN] && !isErrFlit) rdata_pkt_field_checks(); 
            if(smi_rcvd[`STR_RSP_OUT] == '1 && chi_rcvd[`READ_DATA_IN] && (smi_exp !== 'h0 || chi_exp !== 'h0))
                    `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : Received STR Response AND CHI RDAT recieved from AIU, but all the expectation flags are not 0, smi_exp=%0h, chi_exp=%0h", chi_aiu_uid, smi_exp, chi_exp))
            if (m_chi_req_pkt.opcode inside {stash_ops}) begin
                smi_exp[`STR_RSP_OUT] = 1;
                gen_exp_smi_str_rsp();
            end
        end else if (smi_exp[`SNP_DTR_RSP]) begin
            m_snp_dtr_rsp_pkt    = new();
            t_smi_snp_dtr_rsp    = $time;
            smi_exp[`SNP_DTR_RSP] = 0;
            smi_rcvd[`SNP_DTR_RSP] = 1;
            m_snp_dtr_rsp_pkt.copy(m_pkt);
            if(chi_rcvd[`READ_DATA_IN] && !isErrFlit) rdata_pkt_field_checks();
           // if (smi_exp[`SNP_DTW_RSP_IN] !== 1 && smi_exp[`SNP_DTW_REQ_OUT] !== 1) begin
           //     if (!(m_chi_snp_addr_pkt.opcode inside {stash_snps})) begin
           //         smi_exp[`SNP_RSP_OUT] = 1;
           //         gen_exp_smi_snp_rsp();
           //     end
           // end
        end
    endfunction

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //Description: Compare CHI data packet's fields which has to match with received DTR's fields
    //              This check wasnt incorporated in compare() function call, because DTR and ChI rdata
    //              can happen at the same cycle.
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    function void rdata_pkt_field_checks();
        bit   [2:0] l_dwid;
        smi_dp_dwid_t exp_smi_dp_dwid;
     <%if(obj.testBench == "fsys"){ %>
        bit [127:0] 	smi_dp_data_lower;
        bit [127:0] 	smi_dp_data_upper;
        bit [63:0]      smi_dp_data_width ;
        bit smi_dp_dwid_repeat;
        <% if ( obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata > 0 ) { %>
        smi_dp_data_width = <%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>;
        <% } else { %>
        smi_dp_data_width =  <%=obj.Widths.Concerto.Dp.Data.wDpData%>;
        <% } %>
     <% } %>


        if (m_snp_dtr_req_pkt !== null) begin

            m_dtr_req_pkt = new();
            m_dtr_req_pkt.copy(m_snp_dtr_req_pkt);

            case (m_chi_snp_addr_pkt.opcode)
                SNPONCE,
                SNPCLEANINVALID:
                //SNPUNQSTASH:
                begin
                    if (m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_INV)
                        `uvm_error(`LABEL_ERROR, $psprintf("DTR type was expected to be DTR_DATA_INV for SNPONCE, CLEANINVALID and UNQSTASH, but it is: %0s",eMsgDTR'(m_snp_dtr_req_pkt.smi_msg_type)))
                end
                SNPCLEAN:
                begin
                    if ((m_chi_read_data_pkt[0].resp == 3'b000 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN)
                        || (m_chi_read_data_pkt[0].resp == 3'b100 && m_snp_req_pkt.smi_up == 2'b01 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN)
                        || (m_chi_read_data_pkt[0].resp == 3'b100 && m_chi_read_data_pkt[0].opcode == SNPRESPDATAPTL && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN)
                        || (m_chi_read_data_pkt[0].resp inside {3'b001, 3'b011, 3'b101} && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN)
                        || (m_chi_read_data_pkt[0].resp == 3'b100 && m_snp_req_pkt.smi_up !== 2'b01 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN)
                    ) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("DTR type sent from AIU(%0s) not as expected for SNPCLEAN. CHI resp received from processor is: 3'b%03b", eMsgDTR'(m_snp_dtr_req_pkt.smi_msg_type), m_chi_read_data_pkt[0].resp))
                    end
                end
                SNPSHARED:
                begin
                    if ((m_chi_read_data_pkt[0].resp == 3'b000 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN)
                        || (m_chi_read_data_pkt[0].resp == 3'b100 && m_snp_req_pkt.smi_up == 2'b01 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_DTY)
                        || (m_chi_read_data_pkt[0].resp == 3'b101 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_DTY)
                        || (m_chi_read_data_pkt[0].resp == 3'b100 && m_chi_read_data_pkt[0].opcode == SNPRESPDATAPTL && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN)
                        || (m_chi_read_data_pkt[0].resp inside {3'b001, 3'b011} && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN)
                        || (m_chi_read_data_pkt[0].resp == 3'b100 && m_snp_req_pkt.smi_up !== 2'b01 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_DTY)
                    ) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("DTR type sent from AIU(%0s) not as expected for SNPSHARED. CHI resp received from processor is: 3'b%03b",eMsgDTR'(m_snp_dtr_req_pkt.smi_msg_type), m_chi_read_data_pkt[0].resp))
                    end
                end
                SNPUNIQUE:
                begin
                    if (m_snp_req_pkt.smi_msg_type inside {SNP_NITCMI, SNP_NITCCI}
                        && (m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_INV)) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("DTR type sent from AIU(%0s) not as expected for SNP_NITCCI/MI. Expected DTR_DATA_INV",eMsgDTR'(m_snp_dtr_req_pkt.smi_msg_type)))
                    end
                    if ((!(m_snp_req_pkt.smi_msg_type inside {SNP_NITCMI, SNP_NITCCI}))
                        && ((m_chi_read_data_pkt[0].resp == 3'b000 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN)
                            || (m_chi_read_data_pkt[0].resp == 3'b100 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_DTY))
                    ) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("DTR type sent from AIU(%0s) not as expected for SNPUNIQUE. CHI resp received from processor is: 3'b%03b",eMsgDTR'(m_snp_dtr_req_pkt.smi_msg_type), m_chi_read_data_pkt[0].resp))
                    end
                end
                //TODO how to check for Passdirty in a DTR message?
                SNPNSHDTY:
                begin
                    if ((m_chi_read_data_pkt[0].resp == 3'b000 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN)
                        || (m_chi_read_data_pkt[0].resp == 3'b100 && m_snp_req_pkt.smi_up == 2'b01 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_DTY)
                        || (m_chi_read_data_pkt[0].resp == 3'b101 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN)
                        || (m_chi_read_data_pkt[0].resp == 3'b100 && m_chi_read_data_pkt[0].opcode == SNPRESPDATAPTL && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN)
                        || (m_chi_read_data_pkt[0].resp inside {3'b001, 3'b011} && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN)
                        || (m_chi_read_data_pkt[0].resp == 3'b100 && m_snp_req_pkt.smi_up !== 2'b01 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN)
                    ) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("DTR type sent from AIU(%0s) not as expected for SNPNSHDTY. CHI resp received from processor is: 3'b%03b",eMsgDTR'(m_snp_dtr_req_pkt.smi_msg_type), m_chi_read_data_pkt[0].resp))
                    end
                end
                SNPCLEANSHARED:
                begin
                    if ((m_chi_read_data_pkt[0].resp == 3'b100 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_INV)
                        || (m_chi_read_data_pkt[0].resp == 3'b101 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN)
                        || (m_chi_read_data_pkt[0].resp == 3'b110 && m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN)
                    ) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("DTR type sent from AIU(%0s) not as expected for SNPCLEANSHARED. CHI resp received from processor is: 3'b%03b",eMsgDTR'(m_snp_dtr_req_pkt.smi_msg_type), m_chi_read_data_pkt[0].resp))
                    end
                end
                SNPSTASHSHRD:
                begin
                    //if (m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN)
                        //`uvm_error(`LABEL_ERROR, $psprintf("DTR type sent from AIU(%0s) not as expected for Stashing snoop of type: %0s",eMsgDTR'(m_snp_dtr_req_pkt.smi_msg_type), m_chi_snp_addr_pkt.opcode.name))
                end
                SNPSTASHUNQ:
                begin
                    //if (m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN)
                        //`uvm_error(`LABEL_ERROR, $psprintf("DTR type sent from AIU(%0s) not as expected for Stashing snoop of type: %0s",eMsgDTR'(m_snp_dtr_req_pkt.smi_msg_type), m_chi_snp_addr_pkt.opcode.name))
                end
                SNPUNQSTASH,
                SNPMKINVSTASH:
                begin
                    //if (m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_DTY)
                        //`uvm_error(`LABEL_ERROR, $psprintf("DTR type sent from AIU(%0s) not as expected for Stashing snoop of type: %0s",eMsgDTR'(m_snp_dtr_req_pkt.smi_msg_type), m_chi_snp_addr_pkt.opcode.name))
                end
                default:
                begin
                    `uvm_error(`LABEL_ERROR, "CHECK NOT YET IMPLEMENTED")
                end
            endcase
        end

        foreach (m_chi_read_data_pkt[idx]) begin

            if (m_chi_req_pkt !== null && m_chi_req_pkt.excl == 1
                && (!(m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops, READNOSNP <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') {%> , READPREFERUNIQUE, CLEANSHAREDPERSISTSEP, MAKEREADUNIQUE<%}%>})) //JIRA 4940, Ncore3.0 doesn't support RNS with Excl?
                // Refer to JIRA 4940 "On receiving Ex Load CHI-AIU always responds back with pass when data is transferred"
                && (m_chi_read_data_pkt[idx].resperr !== ( (|m_dtr_req_pkt.smi_dp_dbad[idx]=== 1|| m_dtr_req_pkt.smi_cmstatus inside {'h83,'hA6}) ? 2'b10 : 2'b01))) begin 
                `uvm_error(`LABEL_ERROR, $psprintf("READ DATA EXOKAY MISMATCH: COMPDATA EXOKAY driven on CHI interface (0x%0h) doesnt match the expected value: %x", m_chi_read_data_pkt[idx].resperr, 
			( (|m_dtr_req_pkt.smi_dp_dbad[idx]===1 ) ? 2'b10 : 2'b01)))
            end

            if (m_chi_req_pkt !== null && m_chi_req_pkt.excl == 1
                && ((m_chi_req_pkt.opcode inside {READNOSNP})) 
                && (m_chi_read_data_pkt[idx].resperr !== ( (|m_dtr_req_pkt.smi_dp_dbad[idx]===1 || m_dtr_req_pkt.smi_cmstatus inside {'h83,'hA6}) ? 2'b10 : (m_dtr_req_pkt.smi_cmstatus_exok===1) ? 2'b01 : 2'b00))) begin 
                `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : NON EXCL READ DATA EXOKAY MISMATCH: COMPDATA EXOKAY driven on CHI interface (0x%0h) doesnt match the expected value: %x", chi_aiu_uid, m_chi_read_data_pkt[idx].resperr, (|m_dtr_req_pkt.smi_dp_dbad[idx]===1) ? 2'b10 : ( m_dtr_req_pkt.smi_cmstatus_exok===1  ? 2'b01 : 2'b00)))
            end

            <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') {%>
                if (m_chi_req_pkt !== null && m_chi_req_pkt.excl == 1
                    && ((m_chi_req_pkt.opcode inside {READPREFERUNIQUE, CLEANSHAREDPERSISTSEP})) 
                    && (m_chi_read_data_pkt[idx].resperr !== ( (|m_dtr_req_pkt.smi_dp_dbad[idx]===1 || m_dtr_req_pkt.smi_cmstatus inside {'h83,'hA6}) ? 2'b10 : 2'b00))) begin 
                    `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : NON EXCL READ DATA EXOKAY MISMATCH: COMPDATA EXOKAY driven on CHI interface (0x%0h) doesnt match the expected value: %x", chi_aiu_uid, m_chi_read_data_pkt[idx].resperr, (|m_dtr_req_pkt.smi_dp_dbad[idx]===1) ? 2'b10 : 2'b00))
                    //FIXME: SAI where are we checking 2'b11 for respErr?
                end
            <%}%>

            if (m_chi_req_pkt !== null) begin
           <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A' && (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wPoison>0)) { %> 
		if((m_chi_read_data_pkt[idx].poison != m_dtr_req_pkt.smi_dp_dbad[idx]) && |m_dtr_req_pkt.smi_dp_be[idx]!='0)
                    `uvm_error(`LABEL_ERROR, $sformatf("CHIAIU_UID:%0d : poison = %b for bad data in DTRreq: smi_db_dbad %x", chi_aiu_uid, m_chi_read_data_pkt[idx].poison, m_dtr_req_pkt.smi_dp_dbad[idx]))
	   <%}%>
                if (m_chi_read_data_pkt[idx].be !== m_dtr_req_pkt.smi_dp_be[idx]) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("READ DATA BYTE ENABLE MISMATCH: Read data BE driven on CHI interface (%0h) doesnt match the expected value(%0h) derived from read data BE received on SMI interface", m_chi_read_data_pkt[idx].be, m_dtr_req_pkt.smi_dp_be[idx]))
                end else begin
                    `uvm_info(`LABEL, $psprintf("READ DATA BE MATCH: Read data BE driven on CHI interface (%0h) matches the expected value(%0h) derived from read data BE received on SMI interface", m_chi_read_data_pkt[idx].be, m_dtr_req_pkt.smi_dp_be[idx]), UVM_DEBUG)
                end
                if (m_chi_read_data_pkt[idx].data !== m_dtr_req_pkt.smi_dp_data[idx]) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("READ DATA MISMATCH: Read data driven on CHI interface (%0h) doesnt match the expected value(%0h) derived from read data received on SMI interface", m_chi_read_data_pkt[idx].data, m_dtr_req_pkt.smi_dp_data[idx]))
                end else begin
                    `uvm_info(`LABEL, $psprintf("READ DATA MATCH: Read data driven on CHI interface (%0h) matches the expected value(%0h) derived from read data received on SMI interface", m_chi_read_data_pkt[idx].data, m_dtr_req_pkt.smi_dp_data[idx]), UVM_DEBUG)
                end
            end

            if (m_snp_dtr_req_pkt == null) begin
                if ((m_chi_read_data_pkt[idx].resp inside {3'b000, 3'b100} && m_dtr_req_pkt.smi_msg_type !== DTR_DATA_INV)
                    || (m_chi_read_data_pkt[idx].resp inside {3'b001, 3'b101} && m_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN)
                    || (m_chi_read_data_pkt[idx].resp inside {3'b111, 3'b011} && m_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_DTY)
                    || (m_chi_read_data_pkt[idx].resp == 3'b010 && m_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN)
                    || (m_chi_read_data_pkt[idx].resp == 3'b110 && m_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_DTY)
                   ) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("READ COMPDATA RESP field MISMATCH: RESP driven on CHI interface (%0h) doesnt match the expected value derived from DTR packet' smi_msg_type(%0s). Expectations: 000,100->DTR_INV, 001,101->DTR_SC, 111,011->DTR_SD, 010->DTR_UC, 110->DTR_UD", m_chi_read_data_pkt[idx].resp, eMsgDTR'(m_dtr_req_pkt.smi_msg_type)))
                end else begin
                    `uvm_info(`LABEL, $psprintf("READ COMPDATA RESP field MATCH: RESP driven on CHI interface (%0h) matches the expected value derived from DTR packet' smi_msg_type(%0s). Expectations: 000,100->DTR_INV, 001,101->DTR_SC, 111,011->DTR_SD, 010->DTR_UC, 110->DTR_UD", m_chi_read_data_pkt[idx].resp, eMsgDTR'(m_dtr_req_pkt.smi_msg_type)), UVM_DEBUG)
                end
            end
        end
        //for snoop data comparison
        if (m_chi_req_pkt == null) begin
            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : SNP DTR REQ CHECK start", chi_aiu_uid), UVM_HIGH)
            compare_snoop_data(m_chi_read_data_pkt, m_dtr_req_pkt);
            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : SNP DTR REQ CHECK done", chi_aiu_uid), UVM_HIGH)
        end
        else begin
         for(int i=0; i< m_chi_read_data_pkt.size; i++) begin
           <%if(obj.AiuInfo[obj.Id].wData==128){ %>
			//if(m_str_req_pkt.smi_intfsize==2'b01 || m_str_req_pkt.smi_intfsize==2'b00) //128bits
                                if(i==1 && m_chi_req_pkt.addr[4] && m_chi_read_data_pkt.size==2)
				  l_dwid = (m_chi_req_pkt.addr[5:4]-1)*2;
                                else
	   			  l_dwid = (i+m_chi_req_pkt.addr[5:4])*2;
                        //else if(m_str_req_pkt.smi_intfsize==2'b10) //256 bits
			//	  l_dwid = (i+m_chi_req_pkt.addr[5:4])*2;
			`uvm_info(get_type_name(), $sformatf("%m, DTR DWID Info. Expected: %x, Actual: %x. \n Chi[5:4]: %x", {l_dwid+3'h1, l_dwid}, m_dtr_req_pkt.smi_dp_dwid[i], m_chi_req_pkt.addr[5:4]), UVM_LOW)


                        <% if (obj.testBench == "fsys") { %>
                           <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
                            smi_dp_data_lower = m_dtr_req_pkt.smi_dp_data[i][63:0]; 
                            smi_dp_data_upper = m_dtr_req_pkt.smi_dp_data[i][127:64]; 
                            if((m_chi_req_pkt.opcode == ATOMICCOMPARE) && (smi_dp_data_lower == smi_dp_data_upper) && (((2**m_chi_req_pkt.size)*8) <= smi_dp_data_width) && (m_dtr_req_pkt.smi_dp_dwid[i][2:0] == m_dtr_req_pkt.smi_dp_dwid[i][5:3])) begin
                                smi_dp_dwid_repeat = 'h1;    
        			if(m_dtr_req_pkt.smi_dp_dwid[i] != {l_dwid, l_dwid})
			  	    `uvm_error(get_type_name(), $sformatf("%m, DTR DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x addr is : %0h txnid : %0h dp_data : %0p lwid : %0h size %0h", {l_dwid, l_dwid}, m_dtr_req_pkt.smi_dp_dwid[i], m_chi_req_pkt.addr[5:4], m_str_req_pkt.smi_intfsize,m_chi_req_pkt.addr, m_chi_req_pkt.txnid,m_dtr_req_pkt.smi_dp_data,l_dwid,m_chi_req_pkt.size))
             		    end
                           <% } %>
                        <% } %>

                        <% if (obj.testBench == "fsys") { %>
                              if((m_chi_req_pkt.size<4) && (smi_dp_dwid_repeat == 'h0)) begin
                        <% } else { %>    
                              if(m_chi_req_pkt.size<4) begin
                        <% } %>
			
                                if(m_chi_req_pkt.addr[3])
        			  if(m_dtr_req_pkt.smi_dp_dwid[i][5:3] != {l_dwid+3'h1})
			  		`uvm_error(get_type_name(), $sformatf("%m, DTR DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x", {l_dwid+3'h1}, m_dtr_req_pkt.smi_dp_dwid[i][5:3], m_chi_req_pkt.addr[5:3], m_str_req_pkt.smi_intfsize))
				else
 				  if(m_dtr_req_pkt.smi_dp_dwid[i][2:0] != {l_dwid})
			  		`uvm_error(get_type_name(), $sformatf("%m, DTR DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x", {l_dwid}, m_dtr_req_pkt.smi_dp_dwid[i][2:0], m_chi_req_pkt.addr[5:3], m_str_req_pkt.smi_intfsize))

                      <% if (obj.testBench == "fsys") { %>
			end else if (smi_dp_dwid_repeat == 'h0) begin
                      <% } else { %>    
			end else begin
                      <% } %>
        			if(m_dtr_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h1, l_dwid})
			  		`uvm_error(get_type_name(), $sformatf("%m, DTR DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x", {l_dwid+3'h1, l_dwid}, m_dtr_req_pkt.smi_dp_dwid[i], m_chi_req_pkt.addr[5:4], m_str_req_pkt.smi_intfsize))
                        end
           <%} else if(obj.AiuInfo[obj.Id].wData==256){%>
	   		l_dwid = (i+m_chi_req_pkt.addr[5])*4;


                        <% if (obj.testBench == "fsys") { %>
                          <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
                            smi_dp_data_lower = (smi_dp_data_width == 'd256) ? m_dtr_req_pkt.smi_dp_data[i][127:0]   :  m_dtr_req_pkt.smi_dp_data[i][63:0];
                            smi_dp_data_upper = (smi_dp_data_width == 'd256) ? m_dtr_req_pkt.smi_dp_data[i][255:128] :  m_dtr_req_pkt.smi_dp_data[i][127:64];
                            if((m_chi_req_pkt.opcode == ATOMICCOMPARE) && (smi_dp_data_lower == smi_dp_data_upper) && (((2**m_chi_req_pkt.size)*8) <= smi_dp_data_width) && (m_dtr_req_pkt.smi_dp_dwid[i][5:0] == m_dtr_req_pkt.smi_dp_dwid[i][11:6])) begin
                                smi_dp_dwid_repeat = 'h1;    
                                exp_smi_dp_dwid = (((smi_dp_data_lower[127:64] != smi_dp_data_lower[63:0]) && (smi_dp_data_upper[127:64] != smi_dp_data_upper[63:0])) || (m_chi_req_pkt.size == 5)) ? {l_dwid+3'h1, l_dwid, l_dwid+3'h1, l_dwid} : {l_dwid, l_dwid, l_dwid, l_dwid};
                                if(m_dtr_req_pkt.smi_dp_dwid[i] != exp_smi_dp_dwid)
                                    `uvm_error(get_type_name(), $sformatf("%m, DTR DWID_1 mismatched_3. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x addr is : %0h txnid : %0h dp_data : %0p lwid : %0h", exp_smi_dp_dwid, m_dtr_req_pkt.smi_dp_dwid[i], m_chi_req_pkt.addr[5:4], m_str_req_pkt.smi_intfsize,m_chi_req_pkt.addr, m_chi_req_pkt.txnid,m_dtr_req_pkt.smi_dp_data,l_dwid))
             		    end
                            else if ((m_chi_req_pkt.opcode == ATOMICCOMPARE) && (smi_dp_data_lower[127:64] == smi_dp_data_lower[63:0]) && (((2**m_chi_req_pkt.size)*8) <= smi_dp_data_width) && (m_chi_req_pkt.size <= 4) && (m_dtr_req_pkt.smi_dp_dwid[i][5:3] == m_dtr_req_pkt.smi_dp_dwid[i][2:0])) begin
                                smi_dp_dwid_repeat = 'h1;
                                exp_smi_dp_dwid = {l_dwid+3'h2, l_dwid+3'h1, l_dwid, l_dwid};
                                if(m_dtr_req_pkt.smi_dp_dwid[i] != exp_smi_dp_dwid)
                                    `uvm_error(get_type_name(), $sformatf("%m, DTR DWID_1 mismatched_31. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x addr is : %0h txnid : %0h dp_data : %0p lwid : %0h", exp_smi_dp_dwid, m_dtr_req_pkt.smi_dp_dwid[i], m_chi_req_pkt.addr[5:4], m_str_req_pkt.smi_intfsize,m_chi_req_pkt.addr, m_chi_req_pkt.txnid,m_dtr_req_pkt.smi_dp_data,l_dwid))
                            end
                        <% } %>
                        <% } %>

                      <% if (obj.testBench == "fsys") { %>
                        if((m_chi_req_pkt.size<4) && (smi_dp_dwid_repeat == 'h0))
                      <% } else { %>    
                        if(m_chi_req_pkt.size<4)
                      <% } %>
			begin
                                if(m_chi_req_pkt.addr[4:3]==2'b00)
        			  if(m_dtr_req_pkt.smi_dp_dwid[i][2:0] != {l_dwid})
			  		`uvm_error(get_type_name(), $sformatf("%m, DTR DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x", {l_dwid}, m_dtr_req_pkt.smi_dp_dwid[i][5:3], m_chi_req_pkt.addr[5:3], m_str_req_pkt.smi_intfsize))
                                else if(m_chi_req_pkt.addr[4:3]==2'b01)
        			  if(m_dtr_req_pkt.smi_dp_dwid[i][5:3] != {l_dwid+3'h1})
			  		`uvm_error(get_type_name(), $sformatf("%m, DTR DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x", {l_dwid+3'h1}, m_dtr_req_pkt.smi_dp_dwid[i][5:3], m_chi_req_pkt.addr[5:3], m_str_req_pkt.smi_intfsize))
                                else if(m_chi_req_pkt.addr[4:3]==2'b10)
        			  if(m_dtr_req_pkt.smi_dp_dwid[i][8:6] != {l_dwid+3'h2})
			  		`uvm_error(get_type_name(), $sformatf("%m, DTR DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x", {l_dwid+3'h2}, m_dtr_req_pkt.smi_dp_dwid[i][5:3], m_chi_req_pkt.addr[5:3], m_str_req_pkt.smi_intfsize))
                                else if(m_chi_req_pkt.addr[4:3]==2'b11)
        			  if(m_dtr_req_pkt.smi_dp_dwid[i][11:9] != {l_dwid+3'h3})
			  		`uvm_error(get_type_name(), $sformatf("%m, DTR DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x", {l_dwid+3'h3}, m_dtr_req_pkt.smi_dp_dwid[i][5:3], m_chi_req_pkt.addr[5:3], m_str_req_pkt.smi_intfsize))
			end      
                      <% if (obj.testBench == "fsys") { %>
                        else if((m_chi_req_pkt.size==4) && (smi_dp_dwid_repeat == 'h0))
                      <% } else { %>    
                        else if(m_chi_req_pkt.size==4)
                      <% } %>
			begin
                                if(m_chi_req_pkt.addr[4]==1'b0)
        			  if(m_dtr_req_pkt.smi_dp_dwid[i][5:0] != {l_dwid+3'h1, l_dwid})
			  		`uvm_error(get_type_name(), $sformatf("%m, DTR DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x", {l_dwid+3'h1,l_dwid}, m_dtr_req_pkt.smi_dp_dwid[i][5:3], m_chi_req_pkt.addr[5:3], m_str_req_pkt.smi_intfsize))
                                else if(m_chi_req_pkt.addr[4]==1'b1)
        			  if(m_dtr_req_pkt.smi_dp_dwid[i][11:6] != {l_dwid+3'h3, l_dwid+3'h2})
			  		`uvm_error(get_type_name(), $sformatf("%m, DTR DWID mismatched. Expected: %x, Actual: %x. \n Chi[5:4]: %x intf: %x", {l_dwid+3'h3, l_dwid+3'h2}, m_dtr_req_pkt.smi_dp_dwid[i][5:3], m_chi_req_pkt.addr[5:3], m_str_req_pkt.smi_intfsize))
                        end

                      <% if (obj.testBench == "fsys") { %>
        		else if (smi_dp_dwid_repeat == 'h0) begin
                      <% } else { %>    
        		else begin
                      <% } %>
			  if(m_dtr_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid})
			    `uvm_error(get_type_name(), $sformatf("%m, DTR DWID mismatched. Expected: %x, Actual: %x", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_dtr_req_pkt.smi_dp_dwid[i]))
                        end

	   <%}%>
         end
      end
    endfunction : rdata_pkt_field_checks

    function void compare_snoop_data(ref chi_dat_seq_item  m_chi_data_pkt[$], ref smi_seq_item m_req_pkt);
        logic [63:0] dp_data[8];
        logic [7:0] dp_be[8];
        bit   [2:0] l_dwid;

        if (m_req_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
            foreach (m_chi_data_pkt[idx]) begin

                if (m_chi_data_pkt[idx].be !== m_req_pkt.smi_dp_be[idx]) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BYTE ENABLE MISMATCH: Read data BE driven on CHI interface (%0h) doesnt match the expected value(%0h) derived from read data BE received on SMI interface", m_chi_data_pkt[idx].be, m_req_pkt.smi_dp_be[idx]))
                end else begin
                    `uvm_info(`LABEL, $psprintf("SNP DATA BE MATCH: Read data BE driven on CHI interface (%0h) matches the expected value(%0h) derived from read data BE received on SMI interface", m_chi_data_pkt[idx].be, m_req_pkt.smi_dp_be[idx]), UVM_DEBUG)
                end
                if (m_chi_data_pkt[idx].data !== m_req_pkt.smi_dp_data[idx]) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Read data driven on CHI interface (%0h) doesnt match the expected value(%0h) derived from read data received on SMI interface", m_chi_data_pkt[idx].data, m_req_pkt.smi_dp_data[idx]))
                end else begin
                    `uvm_info(`LABEL, $psprintf("SNP DATA MATCH: Read data driven on CHI interface (%0h) matches the expected value(%0h) derived from read data received on SMI interface", m_chi_data_pkt[idx].data, m_req_pkt.smi_dp_data[idx]), UVM_DEBUG)
                end
            end // foreach
            return;
        end
        for(int i=0; i< (64*8/<%=obj.AiuInfo[obj.Id].wData%>); i++) begin //snoop size must be cacheline size
         <%if(obj.AiuInfo[obj.Id].wData==128){ %>
                    //if (m_req_pkt.smi_msg_type == DTW_DATA_PTL) begin
                    //    l_dwid = (i+m_chi_snp_addr_pkt.addr[2:1])*2;
                    //end
                    //else begin
			if(m_snp_req_pkt.smi_intfsize==2'b00 ) //64 bits
			  if(m_chi_snp_addr_pkt.addr[0])
	   			l_dwid = (i+m_chi_snp_addr_pkt.addr[2:1])*2 + m_chi_snp_addr_pkt.addr[0];
			  else
	   			l_dwid = (i+m_chi_snp_addr_pkt.addr[2:1])*2;
			else if(m_snp_req_pkt.smi_intfsize==2'b01) //128bits
	   			l_dwid = (i+m_chi_snp_addr_pkt.addr[2:1])*2;
                        else if(m_snp_req_pkt.smi_intfsize==2'b10) //256 bits
				l_dwid = (i +m_chi_snp_addr_pkt.addr[2]*2)*2;
			`uvm_info(get_full_name(), $sformatf("SNP DWID Info. Expected: %x, Actual: %x. \n SNP Chi[2:1]: %x", {l_dwid+3'h1, l_dwid}, m_req_pkt.smi_dp_dwid[i], m_chi_snp_addr_pkt.addr[2:1]), UVM_LOW)
                    //end
        		if(m_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h1, l_dwid})
			  `uvm_error(get_full_name(), $sformatf("SNP DWID mismatched. Expected: %x, Actual: %x", {l_dwid+3'h1, l_dwid}, m_req_pkt.smi_dp_dwid[i]))
         <%} else if(obj.AiuInfo[obj.Id].wData==256){%>
	   		//l_dwid = (i+m_chi_snp_addr_pkt.addr[2])*4;
			//`uvm_info(get_full_name(), $sformatf("SNP DWID Info. Expected: %x, Actual: %x. \n SNP Chi[2:1]: %x", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_req_pkt.smi_dp_dwid[i], m_chi_snp_addr_pkt.addr[2:1]), UVM_LOW)
        		//if(m_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid})
			//  `uvm_error(get_full_name(), $sformatf("SNP DWID mismatched. Expected: %x, Actual: %x", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_req_pkt.smi_dp_dwid[i]))
                    //if (m_req_pkt.smi_msg_type == DTW_DATA_PTL) begin
                    //    l_dwid = (i+m_chi_snp_addr_pkt.addr[2])*4;
                    //    if(m_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid})
			//  `uvm_error(get_full_name(), $sformatf("SNP DWID mismatched. Expected: %x, Actual: %x", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_req_pkt.smi_dp_dwid[i]))
                    //end
                    //else begin
                        if(m_snp_req_pkt.smi_intfsize==2'b10) //256 bits
                        begin
	   		  l_dwid = (i+m_chi_snp_addr_pkt.addr[2])*4;
			 `uvm_info(get_full_name(), $sformatf("SNP DWID Info. Expected: %x, Actual: %x. \n SNP Chi[2:1]: %x", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_req_pkt.smi_dp_dwid[i], m_chi_snp_addr_pkt.addr[2:1]), UVM_LOW)
        		  if(m_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid})
			    `uvm_error(get_full_name(), $sformatf("SNP DWID mismatched. Expected: %x, Actual: %x", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_req_pkt.smi_dp_dwid[i]))
		        end
                        else if (m_snp_req_pkt.smi_intfsize==2'b01 || m_snp_req_pkt.smi_intfsize==2'b00) //128 bits
                        begin
	   		  l_dwid = (i*2+m_chi_snp_addr_pkt.addr[2:1])*2;
			  if(m_snp_req_pkt.smi_intfsize==2'b00) l_dwid += m_chi_snp_addr_pkt.addr[0];
			 `uvm_info(get_full_name(), $sformatf("SNP DWID Info. Expected: %x, Actual: %x. \n SNP Chi[2:1]: %x", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_req_pkt.smi_dp_dwid[i], m_chi_snp_addr_pkt.addr[2:1]), UVM_LOW)
        		  if(m_req_pkt.smi_dp_dwid[i] != {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid})
			    `uvm_error(get_full_name(), $sformatf("SNP DWID mismatched. Expected: %x, Actual: %x", {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid}, m_req_pkt.smi_dp_dwid[i]))
		        end
                    //end
	 <%}%>
        end
        
        /* 
        if (m_req_pkt.smi_msg_type == DTW_DATA_PTL) begin
        case (WDATA)
        128:
            begin
                if (m_chi_data_pkt.size() !== 4)
                    `uvm_error(`LABEL_ERROR, $psprintf("Not enough data received for the snoop transaction num_snp_data_pkts = %0d", m_chi_data_pkt.size()))
                dp_data[0] = m_chi_data_pkt[0].data[63:0];
                dp_data[1] = m_chi_data_pkt[0].data[127:64];
                dp_data[2] = m_chi_data_pkt[1].data[63:0];
                dp_data[3] = m_chi_data_pkt[1].data[127:64];
                dp_data[4] = m_chi_data_pkt[2].data[63:0];
                dp_data[5] = m_chi_data_pkt[2].data[127:64];
                dp_data[6] = m_chi_data_pkt[3].data[63:0];
                dp_data[7] = m_chi_data_pkt[3].data[127:64];
                dp_be[0] = m_chi_data_pkt[0].be[7:0];
                dp_be[1] = m_chi_data_pkt[0].be[15:8];
                dp_be[2] = m_chi_data_pkt[1].be[7:0];
                dp_be[3] = m_chi_data_pkt[1].be[15:8];
                dp_be[4] = m_chi_data_pkt[2].be[7:0];
                dp_be[5] = m_chi_data_pkt[2].be[15:8];
                dp_be[6] = m_chi_data_pkt[3].be[7:0];
                dp_be[7] = m_chi_data_pkt[3].be[15:8];

                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[1], dp_data[0]})
                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[3], dp_data[2]})
                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[5], dp_data[4]})
                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[7], dp_data[6]})
                ) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: 64bit snp_req. snoop address: %x, Expected: %0p, Actual: %0p", m_snp_req_pkt.smi_addr, dp_data, m_req_pkt.smi_dp_data))
                end
                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[1], dp_be[0]})
                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[3], dp_be[2]})
                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[5], dp_be[4]})
                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[7], dp_be[6]})
                ) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                end
            end
        256:
            begin
                if (m_chi_data_pkt.size() !== 2)
                    `uvm_error(`LABEL_ERROR, $psprintf("Not enough data received for the snoop transaction num_snp_data_pkts = %0d", m_chi_data_pkt.size()))
                dp_data[0] = m_chi_data_pkt[0].data[63:0];
                dp_data[1] = m_chi_data_pkt[0].data[127:64];
                dp_data[2] = m_chi_data_pkt[0].data[191:128];
                dp_data[3] = m_chi_data_pkt[0].data[255:192];
                dp_data[4] = m_chi_data_pkt[1].data[63:0];
                dp_data[5] = m_chi_data_pkt[1].data[127:64];
                dp_data[6] = m_chi_data_pkt[1].data[191:128];
                dp_data[7] = m_chi_data_pkt[1].data[255:192];
                dp_be[0] = m_chi_data_pkt[0].be[7:0];
                dp_be[1] = m_chi_data_pkt[0].be[15:8];
                dp_be[2] = m_chi_data_pkt[0].be[23:16];
                dp_be[3] = m_chi_data_pkt[0].be[31:24];
                dp_be[4] = m_chi_data_pkt[1].be[7:0];
                dp_be[5] = m_chi_data_pkt[1].be[15:8];
                dp_be[6] = m_chi_data_pkt[1].be[23:16];
                dp_be[7] = m_chi_data_pkt[1].be[31:24];

                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[3], dp_data[2], dp_data[1], dp_data[0]})
                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[7], dp_data[6], dp_data[5], dp_data[4]})
                ) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", dp_data, m_req_pkt.smi_dp_data))
                end
                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[3], dp_be[2], dp_be[1], dp_be[0]})
                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[7], dp_be[6], dp_be[5], dp_be[4]})
                ) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                end
            end
        default:
            `uvm_error(`LABEL_ERROR, $psprintf("Unsupported data width detected"))
        endcase
        end
        else begin
        */
        case (WDATA)
	<%if(obj.AiuInfo[obj.Id].wData==128){ %>
        128:
            begin
                if (m_chi_data_pkt.size() !== 4)
                    `uvm_error(`LABEL_ERROR, $psprintf("Not enough data received for the snoop transaction num_snp_data_pkts = %0d", m_chi_data_pkt.size()))
                dp_data[0] = m_chi_data_pkt[0].data[63:0];
                dp_data[1] = m_chi_data_pkt[0].data[127:64];
                dp_data[2] = m_chi_data_pkt[1].data[63:0];
                dp_data[3] = m_chi_data_pkt[1].data[127:64];
                dp_data[4] = m_chi_data_pkt[2].data[63:0];
                dp_data[5] = m_chi_data_pkt[2].data[127:64];
                dp_data[6] = m_chi_data_pkt[3].data[63:0];
                dp_data[7] = m_chi_data_pkt[3].data[127:64];
                dp_be[0] = m_chi_data_pkt[0].be[7:0];
                dp_be[1] = m_chi_data_pkt[0].be[15:8];
                dp_be[2] = m_chi_data_pkt[1].be[7:0];
                dp_be[3] = m_chi_data_pkt[1].be[15:8];
                dp_be[4] = m_chi_data_pkt[2].be[7:0];
                dp_be[5] = m_chi_data_pkt[2].be[15:8];
                dp_be[6] = m_chi_data_pkt[3].be[7:0];
                dp_be[7] = m_chi_data_pkt[3].be[15:8];

                case (m_snp_req_pkt.smi_intfsize)
                    //1DW - 64bits
                    3'b000:
                    begin
                        if (((WBE/8)/2) > m_snp_req_pkt.smi_intfsize) begin
                            case(m_snp_req_pkt.smi_addr[3])
                            1'b0:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[1], dp_data[0]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[3], dp_data[2]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[5], dp_data[4]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[7], dp_data[6]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: 64bit snp_req. snoop address: %x, Expected: %0p, Actual: %0p", m_snp_req_pkt.smi_addr, dp_data, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[1], dp_be[0]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[3], dp_be[2]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[5], dp_be[4]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[7], dp_be[6]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                                end
                            end
                            1'b1:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[2], dp_data[1]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[4], dp_data[3]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[6], dp_data[5]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[0], dp_data[7]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH:64bit snp_req. snoop address: %x, Expected: %0p, Actual: %0p", m_snp_req_pkt.smi_addr, {{dp_data[0], dp_data[7]}, {dp_data[6], dp_data[5]}, {dp_data[4], dp_data[3]}, {dp_data[2], dp_data[1]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[2], dp_be[1]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[4], dp_be[3]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[6], dp_be[5]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[0], dp_be[7]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[0], dp_be[7]}, {dp_be[6], dp_be[5]}, {dp_be[4], dp_be[3]}, {dp_be[2], dp_be[1]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            endcase
                            /*
                            case(m_snp_req_pkt.smi_addr[5:3]) 
                            3'b000:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[1], dp_data[0]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[3], dp_data[2]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[5], dp_data[4]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[7], dp_data[6]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", dp_data, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[1], dp_be[0]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[3], dp_be[2]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[5], dp_be[4]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[7], dp_be[6]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b001:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[2], dp_data[1]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[4], dp_data[3]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[6], dp_data[5]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[0], dp_data[7]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[0], dp_data[7]}, {dp_data[6], dp_data[5]}, {dp_data[4], dp_data[3]}, {dp_data[2], dp_data[1]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[2], dp_be[1]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[4], dp_be[3]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[6], dp_be[5]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[0], dp_be[7]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[0], dp_be[7]}, {dp_be[6], dp_be[5]}, {dp_be[4], dp_be[3]}, {dp_be[2], dp_be[1]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b010:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[3], dp_data[2]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[5], dp_data[4]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[7], dp_data[6]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[1], dp_data[0]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[1], dp_data[0]}, {dp_data[7], dp_data[6]}, {dp_data[5], dp_data[4]}, {dp_data[3], dp_data[2]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[3], dp_be[2]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[5], dp_be[4]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[7], dp_be[6]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[1], dp_be[0]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[1], dp_be[0]}, {dp_be[7], dp_be[6]}, {dp_be[5], dp_be[4]}, {dp_be[3], dp_be[2]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b011:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[4], dp_data[3]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[6], dp_data[5]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[0], dp_data[7]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[2], dp_data[1]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[2], dp_data[1]}, {dp_data[0], dp_data[7]}, {dp_data[6], dp_data[5]}, {dp_data[4], dp_data[3]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[4], dp_be[3]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[6], dp_be[5]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[0], dp_be[7]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[2], dp_be[1]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[2], dp_be[1]}, {dp_be[0], dp_be[7]}, {dp_be[6], dp_be[5]}, {dp_be[4], dp_be[3]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b100:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[5], dp_data[4]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[7], dp_data[6]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[1], dp_data[0]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[3], dp_data[2]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[3], dp_data[2]}, {dp_data[1], dp_data[0]}, {dp_data[7], dp_data[6]}, {dp_data[5], dp_data[4]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[5], dp_be[4]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[7], dp_be[6]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[1], dp_be[0]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[3], dp_be[2]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[3], dp_be[2]}, {dp_be[1], dp_be[0]}, {dp_be[7], dp_be[6]}, {dp_be[5], dp_be[4]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b101:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[6], dp_data[5]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[0], dp_data[7]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[2], dp_data[1]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[4], dp_data[3]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[4], dp_data[3]}, {dp_data[2], dp_data[1]}, {dp_data[0], dp_data[7]}, {dp_data[6], dp_data[5]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[6], dp_be[5]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[0], dp_be[7]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[2], dp_be[1]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[4], dp_be[3]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[4], dp_be[3]}, {dp_be[2], dp_be[1]}, {dp_be[0], dp_be[7]}, {dp_be[6], dp_be[5]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b110:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[7], dp_data[6]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[1], dp_data[0]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[3], dp_data[2]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[5], dp_data[4]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[5], dp_data[4]}, {dp_data[3], dp_data[2]}, {dp_data[1], dp_data[0]}, {dp_data[7], dp_data[6]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[7], dp_be[6]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[1], dp_be[0]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[3], dp_be[2]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[5], dp_be[4]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[5], dp_be[4]}, {dp_be[3], dp_be[2]}, {dp_be[1], dp_be[0]}, {dp_be[7], dp_be[6]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b111:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[0], dp_data[7]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[2], dp_data[1]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[4], dp_data[3]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[6], dp_data[5]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[6], dp_data[5]}, {dp_data[4], dp_data[3]}, {dp_data[2], dp_data[1]}, {dp_data[0], dp_data[7]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[0], dp_be[7]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[2], dp_be[1]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[4], dp_be[3]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[6], dp_be[5]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[6], dp_be[5]}, {dp_be[4], dp_be[3]}, {dp_be[2], dp_be[1]}, {dp_be[0], dp_be[7]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            endcase
                            */
                        end else if (((WBE/8)/2) == m_snp_req_pkt.smi_intfsize) begin
                            if ((m_req_pkt.smi_dp_data[0] !== {dp_data[1], dp_data[0]})
                                || (m_req_pkt.smi_dp_data[1] !== {dp_data[3], dp_data[2]})
                                || (m_req_pkt.smi_dp_data[2] !== {dp_data[5], dp_data[4]})
                                || (m_req_pkt.smi_dp_data[3] !== {dp_data[7], dp_data[6]})
                            ) begin
                                `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH:64bit snp_req. snoop address: %x, Expected: %0p, Actual: %0p", m_snp_req_pkt.smi_addr, dp_data, m_req_pkt.smi_dp_data))
                            end
                            if ((m_req_pkt.smi_dp_be[0] !== {dp_be[1], dp_be[0]})
                                || (m_req_pkt.smi_dp_be[1] !== {dp_be[3], dp_be[2]})
                                || (m_req_pkt.smi_dp_be[2] !== {dp_be[5], dp_be[4]})
                                || (m_req_pkt.smi_dp_be[3] !== {dp_be[7], dp_be[6]})
                            ) begin
                                `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                            end
                        end
                    end
                    //2DW - 128bits
                    3'b001:
                    begin
                        if ((m_req_pkt.smi_dp_data[0] !== {dp_data[1], dp_data[0]})
                            || (m_req_pkt.smi_dp_data[1] !== {dp_data[3], dp_data[2]})
                            || (m_req_pkt.smi_dp_data[2] !== {dp_data[5], dp_data[4]})
                            || (m_req_pkt.smi_dp_data[3] !== {dp_data[7], dp_data[6]})
                        ) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", dp_data, m_req_pkt.smi_dp_data))
                        end
                        if ((m_req_pkt.smi_dp_be[0] !== {dp_be[1], dp_be[0]})
                            || (m_req_pkt.smi_dp_be[1] !== {dp_be[3], dp_be[2]})
                            || (m_req_pkt.smi_dp_be[2] !== {dp_be[5], dp_be[4]})
                            || (m_req_pkt.smi_dp_be[3] !== {dp_be[7], dp_be[6]})
                        ) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                        end
                    end
                    //4DW - 256bits
                    3'b010:
                    begin
                        case(m_snp_req_pkt.smi_addr[4])
                            1'b0:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[1], dp_data[0]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[3], dp_data[2]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[5], dp_data[4]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[7], dp_data[6]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", dp_data, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[1], dp_be[0]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[3], dp_be[2]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[5], dp_be[4]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[7], dp_be[6]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                                end
                            end
                            1'b1:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[7], dp_data[6]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[1], dp_data[0]})
                                    || (m_req_pkt.smi_dp_data[2] !== {dp_data[3], dp_data[2]})
                                    || (m_req_pkt.smi_dp_data[3] !== {dp_data[5], dp_data[4]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[5], dp_data[4]}, {dp_data[3], dp_data[2]}, {dp_data[1], dp_data[0]}, {dp_data[7], dp_data[6]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[7], dp_be[6]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[1], dp_be[0]})
                                    || (m_req_pkt.smi_dp_be[2] !== {dp_be[3], dp_be[2]})
                                    || (m_req_pkt.smi_dp_be[3] !== {dp_be[5], dp_be[4]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[5], dp_be[4]}, {dp_be[3], dp_be[2]}, {dp_be[1], dp_be[0]}, {dp_be[7], dp_be[6]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                        endcase
                    end
                    //8DW - 512 bits
                    3'b011:
                    begin
                        if ((m_req_pkt.smi_dp_data[0] !== {dp_data[1], dp_data[0]})
                            || (m_req_pkt.smi_dp_data[1] !== {dp_data[3], dp_data[2]})
                            || (m_req_pkt.smi_dp_data[2] !== {dp_data[5], dp_data[4]})
                            || (m_req_pkt.smi_dp_data[3] !== {dp_data[7], dp_data[6]})
                        ) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", dp_data, m_req_pkt.smi_dp_data))
                        end
                        if ((m_req_pkt.smi_dp_be[0] !== {dp_be[1], dp_be[0]})
                            || (m_req_pkt.smi_dp_be[1] !== {dp_be[3], dp_be[2]})
                            || (m_req_pkt.smi_dp_be[2] !== {dp_be[5], dp_be[4]})
                            || (m_req_pkt.smi_dp_be[3] !== {dp_be[7], dp_be[6]})
                        ) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                        end
                    end
                    default:
                        `uvm_error(`LABEL_ERROR, $psprintf("Unsupported IntfSize seen on snoop request"))
                endcase
            end
	<%} else if(obj.AiuInfo[obj.Id].wData==256){%>
        256:
            begin
                if (m_chi_data_pkt.size() !== 2)
                    `uvm_error(`LABEL_ERROR, $psprintf("Not enough data received for the snoop transaction num_snp_data_pkts = %0d", m_chi_data_pkt.size()))
                dp_data[0] = m_chi_data_pkt[0].data[63:0];
                dp_data[1] = m_chi_data_pkt[0].data[127:64];
                dp_data[2] = m_chi_data_pkt[0].data[191:128];
                dp_data[3] = m_chi_data_pkt[0].data[255:192];
                dp_data[4] = m_chi_data_pkt[1].data[63:0];
                dp_data[5] = m_chi_data_pkt[1].data[127:64];
                dp_data[6] = m_chi_data_pkt[1].data[191:128];
                dp_data[7] = m_chi_data_pkt[1].data[255:192];
                dp_be[0] = m_chi_data_pkt[0].be[7:0];
                dp_be[1] = m_chi_data_pkt[0].be[15:8];
                dp_be[2] = m_chi_data_pkt[0].be[23:16];
                dp_be[3] = m_chi_data_pkt[0].be[31:24];
                dp_be[4] = m_chi_data_pkt[1].be[7:0];
                dp_be[5] = m_chi_data_pkt[1].be[15:8];
                dp_be[6] = m_chi_data_pkt[1].be[23:16];
                dp_be[7] = m_chi_data_pkt[1].be[31:24];

                case (m_snp_req_pkt.smi_intfsize)
                    //1DW - 64bits
                    3'b000:
                    begin
                        if (((WBE/8)/2) > m_snp_req_pkt.smi_intfsize) begin
                            case(m_snp_req_pkt.smi_addr[4:3])
                            2'b00:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[3], dp_data[2], dp_data[1], dp_data[0]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[7], dp_data[6], dp_data[5], dp_data[4]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", dp_data, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[3], dp_be[2], dp_be[1], dp_be[0]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[7], dp_be[6], dp_be[5], dp_be[4]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                                end
                            end
                            2'b01:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[4], dp_data[3], dp_data[2], dp_data[1]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[0], dp_data[7], dp_data[6], dp_data[5]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[0], dp_data[7], dp_data[6], dp_data[5]}, {dp_data[4], dp_data[3], dp_data[2], dp_data[1]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[4], dp_be[3], dp_be[2], dp_be[1]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[0], dp_be[7], dp_be[6], dp_be[5]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[0], dp_be[7], dp_be[6], dp_be[5]}, {dp_be[4], dp_be[3], dp_be[2], dp_be[1]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            2'b10:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[5], dp_data[4], dp_data[3], dp_data[2]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[1], dp_data[0], dp_data[7], dp_data[6]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[1], dp_data[0], dp_data[7], dp_data[6]}, {dp_data[5], dp_data[4], dp_data[3], dp_data[2]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[5], dp_be[4], dp_be[3], dp_be[2]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[1], dp_be[0], dp_be[7], dp_be[6]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[1], dp_be[0], dp_be[7], dp_be[6]}, {dp_be[5], dp_be[4], dp_be[3], dp_be[2]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            2'b11:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[6], dp_data[5], dp_data[4], dp_data[3]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[2], dp_data[1], dp_data[0], dp_data[7]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[2], dp_data[1], dp_data[0], dp_data[7]}, {dp_data[6], dp_data[5], dp_data[4], dp_data[3]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[6], dp_be[5], dp_be[4], dp_be[3]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[2], dp_be[1], dp_be[0], dp_be[7]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[2], dp_be[1], dp_be[0], dp_be[7]}, {dp_be[6], dp_be[5], dp_be[4], dp_be[3]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            endcase
                            /*
                            case(m_snp_req_pkt.smi_addr[5:3]) 
                            3'b000:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[3], dp_data[2], dp_data[1], dp_data[0]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[7], dp_data[6], dp_data[5], dp_data[4]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", dp_data, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[3], dp_be[2], dp_be[1], dp_be[0]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[7], dp_be[6], dp_be[5], dp_be[4]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b001:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[4], dp_data[3], dp_data[2], dp_data[1]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[0], dp_data[7], dp_data[6], dp_data[5]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[0], dp_data[7], dp_data[6], dp_data[5]}, {dp_data[4], dp_data[3], dp_data[2], dp_data[1]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[4], dp_be[3], dp_be[2], dp_be[1]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[0], dp_be[7], dp_be[6], dp_be[5]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[0], dp_be[7], dp_be[6], dp_be[5]}, {dp_be[4], dp_be[3], dp_be[2], dp_be[1]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b010:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[5], dp_data[4], dp_data[3], dp_data[2]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[1], dp_data[0], dp_data[7], dp_data[6]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[1], dp_data[0], dp_data[7], dp_data[6]}, {dp_data[5], dp_data[4], dp_data[3], dp_data[2]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[5], dp_be[4], dp_be[3], dp_be[2]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[1], dp_be[0], dp_be[7], dp_be[6]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[1], dp_be[0], dp_be[7], dp_be[6]}, {dp_be[5], dp_be[4], dp_be[3], dp_be[2]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b011:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[6], dp_data[5], dp_data[4], dp_data[3]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[2], dp_data[1], dp_data[0], dp_data[7]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[2], dp_data[1], dp_data[0], dp_data[7]}, {dp_data[6], dp_data[5], dp_data[4], dp_data[3]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[6], dp_be[5], dp_be[4], dp_be[3]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[2], dp_be[1], dp_be[0], dp_be[7]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[2], dp_be[1], dp_be[0], dp_be[7]}, {dp_be[6], dp_be[5], dp_be[4], dp_be[3]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b100:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[7], dp_data[6], dp_data[5], dp_data[4]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[3], dp_data[2], dp_data[1], dp_data[0]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[3], dp_data[2], dp_data[1], dp_data[0]}, {dp_data[7], dp_data[6], dp_data[5], dp_data[4]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[7], dp_be[6], dp_be[5], dp_be[4]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[3], dp_be[2], dp_be[1], dp_be[0]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[3], dp_be[2], dp_be[1], dp_be[0]}, {dp_be[7], dp_be[6], dp_be[5], dp_be[4]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b101:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[0], dp_data[7], dp_data[6], dp_data[5]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[4], dp_data[3], dp_data[2], dp_data[1]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[4], dp_data[3], dp_data[2], dp_data[1]}, {dp_data[0], dp_data[7], dp_data[6], dp_data[5]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[0], dp_be[7], dp_be[6], dp_be[5]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[4], dp_be[3], dp_be[2], dp_be[1]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[4], dp_be[3], dp_be[2], dp_be[1]}, {dp_be[0], dp_be[7], dp_be[6], dp_be[5]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b110:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[1], dp_data[0], dp_data[7], dp_data[6]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[5], dp_data[4], dp_data[3], dp_data[2]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[5], dp_data[4], dp_data[3], dp_data[2]}, {dp_data[1], dp_data[0], dp_data[7], dp_data[6]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[1], dp_be[0], dp_be[7], dp_be[6]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[5], dp_be[4], dp_be[3], dp_be[2]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[5], dp_be[4], dp_be[3], dp_be[2]}, {dp_be[1], dp_be[0], dp_be[7], dp_be[6]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            3'b111:
                            begin
                                if ((m_req_pkt.smi_dp_data[0] !== {dp_data[2], dp_data[1], dp_data[0], dp_data[7]})
                                    || (m_req_pkt.smi_dp_data[1] !== {dp_data[6], dp_data[5], dp_data[4], dp_data[3]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", {{dp_data[6], dp_data[5], dp_data[4], dp_data[3]}, {dp_data[2], dp_data[1], dp_data[0], dp_data[7]}}, m_req_pkt.smi_dp_data))
                                end
                                if ((m_req_pkt.smi_dp_be[0] !== {dp_be[2], dp_be[1], dp_be[0], dp_be[7]})
                                    || (m_req_pkt.smi_dp_be[1] !== {dp_be[6], dp_be[5], dp_be[4], dp_be[3]})
                                ) begin
                                    `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", {{dp_be[6], dp_be[5], dp_be[4], dp_be[3]}, {dp_be[2], dp_be[1], dp_be[0], dp_be[7]}}, m_req_pkt.smi_dp_be))
                                end
                            end
                            endcase
                            */
                        end else if (((WBE/8)/2) == m_snp_req_pkt.smi_intfsize) begin
                            if ((m_req_pkt.smi_dp_data[0] !== {dp_data[3], dp_data[2], dp_data[1], dp_data[0]})
                                || (m_req_pkt.smi_dp_data[1] !== {dp_data[7], dp_data[6], dp_data[5], dp_data[4]})
                            ) begin
                                `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", dp_data, m_req_pkt.smi_dp_data))
                            end
                            if ((m_req_pkt.smi_dp_be[0] !== {dp_be[3], dp_be[2], dp_be[1], dp_be[0]})
                                || (m_req_pkt.smi_dp_be[1] !== {dp_be[7], dp_be[6], dp_be[5], dp_be[4]})
                            ) begin
                                `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                            end
                        end
                    end
                    //2DW - 128bits
                    3'b001:
                    begin
                        case (m_snp_req_pkt.smi_addr[4])
                        2'b0:
                        begin
                            if ((m_req_pkt.smi_dp_data[0] !== {dp_data[3], dp_data[2], dp_data[1], dp_data[0]})
                                || (m_req_pkt.smi_dp_data[1] !== {dp_data[7], dp_data[6], dp_data[5], dp_data[4]})
                            ) begin
                                `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", dp_data, m_req_pkt.smi_dp_data))
                            end
                            if ((m_req_pkt.smi_dp_be[0] !== {dp_be[3], dp_be[2], dp_be[1], dp_be[0]})
                                || (m_req_pkt.smi_dp_be[1] !== {dp_be[7], dp_be[6], dp_be[5], dp_be[4]})
                            ) begin
                                `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                            end
                        end
                        2'b1:
                        begin
                            if ((m_req_pkt.smi_dp_data[0] !== {dp_data[5], dp_data[4], dp_data[3], dp_data[2]})
                                || (m_req_pkt.smi_dp_data[1] !== {dp_data[1], dp_data[0], dp_data[7], dp_data[6]})
                            ) begin
                                `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: Beat1: %0p, Beat0,: %0p Actual: Beat1:%0p, Beat0: %0p", {dp_data[1], dp_data[0], dp_data[7], dp_data[6]}, {dp_data[5], dp_data[4], dp_data[3], dp_data[2]}, m_req_pkt.smi_dp_data[1], m_req_pkt.smi_dp_data[0]))
                            end
                            if ((m_req_pkt.smi_dp_be[0] !== {dp_be[5], dp_be[4], dp_be[3], dp_be[2]})
                                || (m_req_pkt.smi_dp_be[1] !== {dp_be[1], dp_be[0], dp_be[7], dp_be[6]})
                            ) begin
                                `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected:BE[1]: %0p, BE[0]: %0p, Actual: BE[1]: %0p, BE[0]: %0p", {dp_be[1], dp_be[0], dp_be[7], dp_be[6]} ,{dp_be[5], dp_be[4], dp_be[3], dp_be[2]}, m_req_pkt.smi_dp_be[1], m_req_pkt.smi_dp_be[0]))
                            end
                        end
                        endcase
                    end
                    //4DW - 256bits
                    3'b010:
                    begin
                        if ((m_req_pkt.smi_dp_data[0] !== {dp_data[3], dp_data[2], dp_data[1], dp_data[0]})
                            || (m_req_pkt.smi_dp_data[1] !== {dp_data[7], dp_data[6], dp_data[5], dp_data[4]})
                        ) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", dp_data, m_req_pkt.smi_dp_data))
                        end
                        if ((m_req_pkt.smi_dp_be[0] !== {dp_be[3], dp_be[2], dp_be[1], dp_be[0]})
                            || (m_req_pkt.smi_dp_be[1] !== {dp_be[7], dp_be[6], dp_be[5], dp_be[4]})
                        ) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                        end
                    end
                    //8DW - 512 bits
                    3'b011:
                    begin
                        if ((m_req_pkt.smi_dp_data[0] !== {dp_data[3], dp_data[2], dp_data[1], dp_data[0]})
                            || (m_req_pkt.smi_dp_data[1] !== {dp_data[7], dp_data[6], dp_data[5], dp_data[4]})
                        ) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA MISMATCH: Expected: %0p, Actual: %0p", dp_data, m_req_pkt.smi_dp_data))
                        end
                        if ((m_req_pkt.smi_dp_be[0] !== {dp_be[3], dp_be[2], dp_be[1], dp_be[0]})
                            || (m_req_pkt.smi_dp_be[1] !== {dp_be[7], dp_be[6], dp_be[5], dp_be[4]})
                        ) begin
                            `uvm_error(`LABEL_ERROR, $psprintf("SNP DATA BE MISMATCH: Expected: %0p, Actual: %0p", dp_be, m_req_pkt.smi_dp_be))
                        end
                    end
                    default:
                        `uvm_error(`LABEL_ERROR, $psprintf("Unsupported IntfSize seen on snoop request"))
                endcase                
            end
	<%}%>
        default:
            `uvm_error(`LABEL_ERROR, $psprintf("Unsupported data width detected"))
        endcase
        //end

    endfunction : compare_snoop_data

    function void add_smi_str_rsp(const ref smi_seq_item m_pkt);
        if (m_str_rsp_pkt == null) begin
            m_str_rsp_pkt    = new();

            if((smi_rcvd[`DTR_RSP_OUT] || smi_rcvd[`SNP_DTR_RSP]) && chi_rcvd[`READ_DATA_IN] && !isErrFlit)
            	rdata_pkt_field_checks(); 

            if (!(m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %> , combined_wr_nc_ops, combined_wr_c_ops<% } %>})) begin
                smi_exp[`STR_RSP_OUT] = 0;
                smi_rcvd[`STR_RSP_OUT] = 1;
            end else if (m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops}
                       && m_chi_req_pkt.snpattr == 0) begin
                smi_exp[`STR_RSP_OUT] = 0;
                smi_rcvd[`STR_RSP_OUT] = 1;
             end
            if (smi_exp !== 'h0 || chi_exp !== 'h0) begin
                //sometimes STR RSP goes out before DTR/CMD RSP, avoid the checker in that case
                if (smi_exp !== 'h20
                    && smi_exp !== 'h02
                    && smi_exp !== 'h22
                    && ((chi_exp & 'h2) !== 'h02) && ((chi_exp & 'h8) !== 'h8)
                    ) begin
                if (!(m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>, combined_wr_nc_ops, combined_wr_c_ops<% } %>})) 
                    `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : Received STR Response from AIU, but all the expectation flags are not 0, smi_exp=%0h, chi_exp=%0h", chi_aiu_uid, smi_exp, chi_exp))
                end
            end
            t_smi_str_rsp    = $time;
            m_str_rsp_pkt.copy(m_pkt);
            //if the response is for str_req_2, copy str_req as str_req_2 because the second time around, we will match incoming
            // str_rsp with str_req_2 only
            if (m_str_req_pkt_2 !== null) begin
                if (m_str_rsp_pkt.smi_targ_ncore_unit_id == m_str_req_pkt_2.smi_src_ncore_unit_id
                    && m_str_rsp_pkt.smi_rmsg_id == m_str_req_pkt_2.smi_msg_id) begin
                    smi_seq_item temp;
                    temp = m_str_req_pkt_2;
                    m_str_req_pkt_2 = m_str_req_pkt;
                    m_str_req_pkt = temp;
                end
            end
            str_rsp_1_seen = 1;
            if ((($test$plusargs("strreq_cmstatus_with_error") && (m_str_req_pkt.smi_cmstatus_err === 1'b1)) || ($test$plusargs("zero_nonzero_crd_test") && (is_crd_zero_err == 1))) && (m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>, combined_wr_nc_ops, combined_wr_c_ops<% } %>})) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : CHI_AIU will not generate STRRSP (for non coherent part of atomic) for command with address = 0x%0x, opcode = %0s", chi_aiu_uid, m_chi_req_pkt.addr, m_chi_req_pkt.opcode), UVM_LOW)
                smi_exp[`STR_RSP_OUT] = 0;
                smi_rcvd[`STR_RSP_OUT] = 1;
            end
	    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
	    if (($test$plusargs("dtwrsp_cmstatus_with_error") || $test$plusargs("error_test")) && (dtwrsp_cmstatus_err_seen === 1) && m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops}) begin 
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : CHI_AIU will not generate STRRSP (for 2nd part of wrcmo) for command with address = 0x%0x, opcode = %0s", chi_aiu_uid, m_chi_req_pkt.addr, m_chi_req_pkt.opcode), UVM_LOW)
                smi_exp[`STR_RSP_OUT] = 0;
                smi_rcvd[`STR_RSP_OUT] = 1;
	    end
	    <% } %>
        end else begin
            //This should only happen for atomic transactions.
            smi_exp[`STR_RSP_OUT] = 0;
            smi_rcvd[`STR_RSP_OUT] = 1;
            if (smi_exp !== 'h0 || chi_exp !== 'h0) begin
               <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') {%>
                 if ((m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops, combined_wr_nc_ops, combined_wr_c_ops})) begin
                  if (chi_exp != 0)
                    `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received STR Response from AIU, but all the expectation flags are not 0, smi_exp=%0h, chi_exp=%0h",chi_aiu_uid, smi_exp, chi_exp), UVM_LOW) // Need to check this
                 end else begin
                	`uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : Received STR Response from AIU, but all the expectation flags are not 0, smi_exp=%0h, chi_exp=%0h", chi_aiu_uid, smi_exp, chi_exp))
                 end
          	<%}else{%>
                	`uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : Received STR Response from AIU, but all the expectation flags are not 0, smi_exp=%0h, chi_exp=%0h", chi_aiu_uid, smi_exp, chi_exp))
                <%}%>
            end
            t_smi_str_rsp    = $time;
            m_str_rsp_pkt_2 = new();
            m_str_rsp_pkt_2.copy(m_pkt);
        end
    endfunction

    /////////////////////////////////////////////////////////////
    // Functions to generate expected packets
    /////////////////////////////////////////////////////////////

    function void gen_exp_smi_cmd_req();
        int mem_region;
        exp_cmd_req_pkt = smi_seq_item::type_id::create("exp_cmd_req_pkt");

        exp_cmd_req_pkt.construct_cmdmsg(
                                        .smi_targ_ncore_unit_id (m_chi_req_pkt.opcode == DVMOP ? DVE_FUNIT_IDS[0] : 
						                 m_chi_req_pkt.is_coh_opcode() ? addrMgrConst::map_addr2dce(m_chi_req_pkt.addr) : addrMgrConst::map_addr2dmi_or_dii(m_chi_req_pkt.addr, mem_region)),
                                        .smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_msg_type           (get_smi_msg_type(m_chi_req_pkt.opcode)),
                                        .smi_msg_id             ('h0),
                                        .smi_msg_tier           ('h0),
					                    .smi_steer		('0),
                                        .smi_msg_qos            ('0), //WSMIQOS_EN ? |m_chi_req_pkt.qos : '0), QL not supported as per CHI AIU uARCH spec
                                        .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%>? qos_mapping(m_chi_req_pkt.qos) : 'h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0),
                                        .smi_addr               (m_chi_req_pkt.addr),
<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
                                        // #Check.CHI.v3.6.WrNoSnp.expCompAck
                                        .smi_vz                 (m_chi_req_pkt.opcode inside {CLEANINVALID, MAKEINVALID, CLEANSHARED} ? 1 :  
                                                                 m_chi_req_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL, READNOSNP} ? (~m_chi_req_pkt.memattr[0]) | (m_chi_req_pkt.memattr[1]) | (m_chi_req_pkt.excl) : 0 ), //covered in line226 of this file
                                        .smi_ac                 (m_chi_req_pkt.opcode inside {WRITEEVICTFULL} ? 1 :
                                                                (m_chi_req_pkt.opcode inside {EVICT, DVMOP} ||
                                                                (m_chi_req_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL, READNOSNP} && m_chi_req_pkt.excl)) ? 0 : m_chi_req_pkt.memattr[3]),
                                        .smi_ca                 ((m_chi_req_pkt.opcode inside {CLEANINVALID, MAKEINVALID, CLEANSHARED} ||
                                                                (m_chi_req_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL, READNOSNP} && (!m_chi_req_pkt.excl))) ? m_chi_req_pkt.memattr[2] :
                                                                ((m_chi_req_pkt.opcode inside {DVMOP} ||
                                                                (m_chi_req_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL, READNOSNP} && m_chi_req_pkt.excl))) ? 0 : 1),
<% } else { %>
                                        // #Check.CHI.v3.6.ClnShrdPersist
                                        // #Check.CHI.v3.6.WriteNoSnpZero_Err
                                        // #Check.CHI.v3.6.WriteUniqueZero_Err
                                        .smi_vz                 (m_chi_req_pkt.opcode inside {CLEANINVALID, MAKEINVALID, CLEANSHARED, CLEANSHAREDPERSIST}
                                                                <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                                                                  || (m_chi_req_pkt.opcode == CLEANSHAREDPERSISTSEP) ||
                                                                     (m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops} && (wr_cmo_first_part_done == 1))
                                                                <%}%>
                                                                 ? 1 : 
                                                                 m_chi_req_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL, READNOSNP}
                                                                 <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                                                                  || (m_chi_req_pkt.opcode == WRITENOSNPZERO) ||
                                                                     (m_chi_req_pkt.opcode inside {combined_wr_nc_ops}&& (wr_cmo_first_part_done == 0))
                                                                 <%}%>
                                                                  ? (~m_chi_req_pkt.memattr[0]) | (m_chi_req_pkt.memattr[1]) | (m_chi_req_pkt.excl) : 0),                                                                            .smi_ac                 (m_chi_req_pkt.opcode inside {WRITEEVICTFULL, PREFETCHTARGET, atomic_dtls_ops, atomic_dat_ops} ? 1 :
                                                                (m_chi_req_pkt.opcode inside {READONCEMAKEINVALID, EVICT, DVMOP
                                                                <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                                                                    , WRITEEVICTOREVICT
                                                                <%}%>
                                                                } || (m_chi_req_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL, READNOSNP
                                                                <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                                                                    ,WRITENOSNPZERO
                                                                <%}%>
                                                                } && m_chi_req_pkt.excl)) ? 0 : m_chi_req_pkt.memattr[3]),
                                        .smi_ca                 (((m_chi_req_pkt.opcode inside {CLEANINVALID, MAKEINVALID, CLEANSHARED, CLEANSHAREDPERSIST}
                                                                <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                                                                  || (m_chi_req_pkt.opcode == CLEANSHAREDPERSISTSEP) ||
                                                                     (m_chi_req_pkt.opcode inside {combined_wr_c_ops} && (wr_cmo_first_part_done == 1)) ||
                                                                     (m_chi_req_pkt.opcode inside {combined_wr_nc_ops})
                                                                <%}%>
                                                                ||(m_chi_req_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL, READNOSNP}
                                                                <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                                                                  || (m_chi_req_pkt.opcode == WRITENOSNPZERO)
                                                                <%}%>)
                                                                 && (!m_chi_req_pkt.excl)) ) ? m_chi_req_pkt.memattr[2] :
                                                                (((m_chi_req_pkt.opcode inside {DVMOP} ||
                                                                (m_chi_req_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL, READNOSNP}
                                                                <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                                                                  || (m_chi_req_pkt.opcode == WRITENOSNPZERO)
                                                                <%}%>)
                                                                 && m_chi_req_pkt.excl))  ) ? 0 : 1),
<% } %>
                                        .smi_ch                 (<%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
								((m_chi_req_pkt.opcode inside {combined_wr_c_ops}) && (wr_cmo_first_part_done == 0)) || 
								(m_chi_req_pkt.opcode == PREFETCHTARGET) ? 0 : 													 	  				     ((m_chi_req_pkt.opcode inside {combined_wr_c_ops}) && (wr_cmo_first_part_done == 1)) ? m_chi_req_pkt.snpattr : <%}%> 
								(m_chi_req_pkt.is_coh_opcode())),
<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
                                        .smi_st                 (m_chi_req_pkt.memattr[1]),
<% } else { %>
                                        .smi_st                 ((m_chi_req_pkt.opcode == PREFETCHTARGET) ? ('b0) : m_chi_req_pkt.memattr[1]),
<% } %>
                                        .smi_en                 (m_chi_req_pkt.endian),
<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
                                        .smi_es                 ((m_chi_req_pkt.excl || m_chi_req_pkt.snoopme) ? 'b1 : 'b0),
<% } else { %>
                                        .smi_es                 ((m_chi_req_pkt.opcode == PREFETCHTARGET) ? (1'b0) : ((m_chi_req_pkt.excl || m_chi_req_pkt.snoopme) ? (1'b1) : (1'b0))),
<% } %>
                                        .smi_ns                 (m_chi_req_pkt.ns),
                                        .smi_pr                 ('h0),
<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
                                        .smi_order              (m_chi_req_pkt.order),
<% } else { %>
                                        .smi_order              ((m_chi_req_pkt.opcode == PREFETCHTARGET || wr_cmo_first_part_done) ? ('h0) : m_chi_req_pkt.order),
<% } %>
                                        .smi_lk                 ('h0),
<% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
                                        .smi_rl                 ((m_chi_req_pkt.opcode inside {CLEANINVALID, MAKEINVALID, CLEANSHARED, CLEANSHAREDPERSIST
                                                                <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                                                                    ,CLEANSHAREDPERSISTSEP
                                                                <%}%>
                                        } 
                                                                <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                                                              || ((m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops}) && (wr_cmo_first_part_done == 1))
                                                                <%}%>
                                                                  ) ? 2'b10 : 2'b01),
<% } else { %>
                                        .smi_rl                 ((m_chi_req_pkt.opcode inside {CLEANINVALID, MAKEINVALID, CLEANSHARED}) ? 2'b10 : 2'b01),
<% } %>
                                        .smi_tm                 (m_chi_req_pkt.tracetag),
                                        //.smi_up                 ('h0),
                                        .smi_mpf1_stash_valid   (m_chi_req_pkt.stashnidvalid),
                                        .smi_mpf1_stash_nid     (m_chi_req_pkt.stashnid),
<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
                                        .smi_mpf1_argv          ('h0), //used to carry atomic opcode
<% } else { %>
                                        //.smi_mpf1_argv          ((m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops} && (m_chi_req_pkt.opcode !== ATOMICSWAP) && (m_chi_req_pkt.opcode !== ATOMICCOMPARE)) ? ({3'b000, m_chi_req_pkt.opcode[2:0]}) : ('h0)), //used to carry atomic opcode
                                        .smi_mpf1_argv          ((m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops}) ? ({3'b000, m_chi_req_pkt.opcode[2:0]}) : ('h0)), //used to carry atomic opcode
<% } %>
                                        .smi_mpf1_burst_type    ('h0),
                                        .smi_mpf1_alength       ('h0),
                                        .smi_mpf1_asize         ('h0),
                                        .smi_mpf1_awunique      ('h0),
                                        .smi_mpf2_stash_valid   (m_chi_req_pkt.stashlpidvalid),
                                        .smi_mpf2_stash_lpid    (m_chi_req_pkt.stashlpid),
                                        .smi_mpf2_flowid_valid  ('1),
<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
                                        .smi_mpf2_flowid        ({'0, m_chi_req_pkt.lpid}),
                                        .smi_size               (m_chi_req_pkt.size),
<% } else { %>
                                        .smi_mpf2_flowid        ((m_chi_req_pkt.opcode inside {stash_ops}) ? '0 : {'0, m_chi_req_pkt.lpid[<%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.LPID%>-1:0]}),
                                        .smi_size               ((m_chi_req_pkt.opcode == PREFETCHTARGET) ? ('h6) : m_chi_req_pkt.size),
<% } %>
                                        .smi_intfsize           ((WBE/8)/(2)), //2^(Intfsize) DWs. datawidh 128bits = 2 DW = 2^1
                                        .smi_dest_id            (m_chi_req_pkt.opcode == DVMOP ? '0 : addrMgrConst::map_addr2dmi_or_dii(m_chi_req_pkt.addr, mem_region)), //DVE_FUNIT_IDS[0]  : addrMgrConst::map_addr2dmi_or_dii(m_chi_req_pkt.addr, mem_region)),
                                        .smi_tof                ('h1),
                                        .smi_qos                (<%=obj.AiuInfo[obj.Id].fnEnableQos%>? m_chi_req_pkt.qos : 'h0),
                                        .smi_ndp_aux            (m_chi_req_pkt.rsvdc)
                                        );

    endfunction : gen_exp_smi_cmd_req

    function void gen_exp_smi_str_rsp();
        exp_str_rsp_pkt = smi_seq_item::type_id::create("exp_str_rsp_pkt");

        exp_str_rsp_pkt.construct_strrsp(
                                        .smi_targ_ncore_unit_id ((m_str_req_pkt!==null) ? m_str_req_pkt.smi_src_ncore_unit_id : 'h0),
                                        .smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_msg_tier           ('h0),
                                        .smi_steer              ('h0),
                                        .smi_msg_qos            ('0),
                                        .smi_msg_pri            ((<%=obj.AiuInfo[obj.Id].fnEnableQos%> && (m_str_req_pkt!==null))? m_str_req_pkt.smi_msg_pri : 'h0),
                                        .smi_msg_type           (STR_RSP),
                                        .smi_tm                 ((m_str_req_pkt!==null) ? m_str_req_pkt.smi_tm : 'h0),
                                        .smi_msg_id             ('h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0),
                                        .smi_rmsg_id            ((m_str_req_pkt!==null) ? m_str_req_pkt.smi_msg_id : 'h0)
                                        );
    endfunction : gen_exp_smi_str_rsp

    function void gen_exp_smi_str_rsp_2();
       exp_str_rsp_pkt_2 = smi_seq_item::type_id::create("exp_str_rsp_pkt_2");

        exp_str_rsp_pkt_2.construct_strrsp(
                                        .smi_steer              ('h0),
                                        .smi_targ_ncore_unit_id ((m_str_req_pkt_2 !== null) ? m_str_req_pkt_2.smi_src_ncore_unit_id : 'h0),
                                        .smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_msg_tier           ('h0),
                                        .smi_msg_qos            ('0),
                                        .smi_msg_pri            ((<%=obj.AiuInfo[obj.Id].fnEnableQos%> && m_str_req_pkt_2 !== null)? m_str_req_pkt_2.smi_msg_pri : 'h0),
                                        .smi_msg_type           (STR_RSP),
                                        .smi_tm                 ((m_str_req_pkt_2 !== null) ? m_str_req_pkt_2.smi_tm : 'h0),
                                        .smi_msg_id             ('h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0),
                                        .smi_rmsg_id            ((m_str_req_pkt_2 !== null) ? m_str_req_pkt_2.smi_msg_id : 'h0)
                                        );
    endfunction : gen_exp_smi_str_rsp_2


    function void gen_exp_smi_cmd_rsp();
        exp_cmd_rsp_pkt = smi_seq_item::type_id::create("exp_cmd_rsp_pkt");
       
        //why are there 2 different constructs for C and NC?
        exp_cmd_rsp_pkt.construct_ccmdrsp(
                                        .smi_steer              ('h0),
                                        .smi_targ_ncore_unit_id (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_src_ncore_unit_id  ((m_cmd_req_pkt !== null) ? m_cmd_req_pkt.smi_targ_ncore_unit_id : 'h0),
                                        .smi_msg_tier           ('h0),
                                        .smi_msg_qos            ('0),
                                        .smi_msg_pri            ((<%=obj.AiuInfo[obj.Id].fnEnableQos%> && m_cmd_req_pkt !== null)? m_cmd_req_pkt.smi_msg_pri : 'h0),
                                        .smi_msg_type           ((addrMgrConst::get_unit_type(m_cmd_req_pkt.smi_targ_ncore_unit_id)==addrMgrConst::DCE) ? C_CMD_RSP : NC_CMD_RSP),
                                        .smi_tm                 (m_cmd_req_pkt.smi_tm),
                                        .smi_msg_id             ('h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0),
                                        .smi_rmsg_id            (m_cmd_req_pkt.smi_msg_id)
                                        );
    endfunction : gen_exp_smi_cmd_rsp

    function void gen_exp_smi_dtr_req();
        int mem_region;
        exp_dtr_req_pkt = smi_seq_item::type_id::create("exp_dtr_req_pkt");
        exp_dtr_req_pkt.construct_dtrmsg(
                                        .smi_steer              ('h0),
                                        .smi_targ_ncore_unit_id (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_src_ncore_unit_id  ((m_cmd_req_pkt !== null) ? addrMgrConst::map_addr2dmi_or_dii(m_chi_req_pkt.addr, mem_region) : 'h0),
                                        .smi_msg_tier           ('h0),
                                        .smi_msg_qos            ('0),
                                        .smi_msg_pri            ((<%=obj.AiuInfo[obj.Id].fnEnableQos%> &&m_cmd_req_pkt !== null) ? m_cmd_req_pkt.smi_msg_pri : 'h0),
                                        .smi_msg_type           (DTR_DATA_INV), // Scoreboard has a function to check all posibble values: check_dtr_msg_types
                                        .smi_msg_id             ('h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0),
                                        .smi_rl                 ('h0),
                                        .smi_tm                 ('h0), 
                                        .smi_rmsg_id            (m_cmd_req_pkt.smi_msg_id), //Is this right?
                                        .smi_mpf1_dtr_long_dtw  ('h0),
        				.smi_ndp_aux            ('0 ),
                                        .smi_dp_last            ('h0),
                                        .smi_dp_data            ({'b0}),
                                        .smi_dp_be              ({'hff}),
                                        .smi_dp_protection      ({'b0}),
                                        .smi_dp_dwid            ({'b0}),
                                        .smi_dp_dbad            ({'b0}),
                                        .smi_dp_concuser        ({'b0})
                                        );
    endfunction : gen_exp_smi_dtr_req

    function void gen_exp_smi_str_req();
        bit [3:0] cm_status; //[3]:SO, [2]:SS, [1]:SD, [0]: ST
        eMsgCMD   m_cmd_type;
        if(m_cmd_req_pkt !== null) $cast(m_cmd_type, m_cmd_req_pkt.smi_msg_type);
        exp_str_req_pkt = smi_seq_item::type_id::create("exp_str_req_pkt");
        cm_status = determine_summary_bits(m_chi_req_pkt.opcode);
        exp_str_req_pkt.construct_strmsg(
                                        .smi_targ_ncore_unit_id (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_src_ncore_unit_id  ((m_cmd_req_pkt !== null) ? m_cmd_req_pkt.smi_targ_ncore_unit_id : 'h0), 
                                        .smi_msg_tier           ('h0),
                                        .smi_steer              ('h0 ),
                                        .smi_msg_qos            ('h0),
                                        .smi_msg_pri            ((<%=obj.AiuInfo[obj.Id].fnEnableQos%> && (m_cmd_req_pkt !== null))? m_cmd_req_pkt.smi_msg_pri : 'h0),
                                        .smi_msg_type           (STR_STATE),//0x7A
                                        .smi_msg_id             ('h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ({'h0,cm_status}),
                                        .smi_cmstatus_so        (cm_status[3]),
                                        .smi_cmstatus_ss        (cm_status[2]),
                                        .smi_cmstatus_sd        (cm_status[1]),
                                        .smi_cmstatus_st        (cm_status[0]),
                                        .smi_cmstatus_state     (cm_status[3:1]),
                                        .smi_cmstatus_snarf     ('h0),
                                        .smi_cmstatus_exok      ('h0),
                                        .smi_rbid               ('h0),
                                        .smi_tm                 (m_cmd_req_pkt.smi_tm),
                                        .smi_rmsg_id            (m_cmd_req_pkt.smi_msg_id),
                                        //.smi_mpf1_stash_nid     ('h0),
                                        //.smi_mpf2_dtr_msg_id    ('h0),

                                        .smi_mpf1		(((m_cmd_req_pkt !== null)&&(m_cmd_type inside{CMD_WR_STSH_PTL,CMD_WR_STSH_FULL,CMD_LD_CCH_SH,CMD_LD_CCH_UNQ})&&(m_cmd_req_pkt.smi_mpf1_stash_valid))? m_cmd_req_pkt.smi_mpf1_stash_nid : 'h0), //TO DO
                                        //.smi_mpf1		(((m_cmd_req_pkt !== null)&&(m_cmd_type inside{CMD_WR_STSH_PTL,CMD_WR_STSH_FULL})&&(m_cmd_req_pkt.smi_mpf1_stash_valid))? m_cmd_req_pkt.smi_mpf1_stash_nid : 'h0), //TO DO
					.smi_mpf2               ('h0), //TO DO
                                        .smi_intfsize           ('h0)
//        				.smi_ndp_aux            ('0 )
                                        );
        exp_str_req_pkt.unpack_smi_seq_item();
    endfunction : gen_exp_smi_str_req

    function void gen_exp_smi_dtr_rsp();
        exp_dtr_rsp_pkt = smi_seq_item::type_id::create("exp_dtr_rsp_pkt");
        exp_dtr_rsp_pkt.construct_dtrrsp(
                                        .smi_steer              ('h0),
                                        .smi_targ_ncore_unit_id ((m_snp_dtr_req_pkt == null) ? m_dtr_req_pkt.smi_src_ncore_unit_id : m_snp_dtr_req_pkt.smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  ((m_snp_dtr_req_pkt == null) ? <%=obj.AiuInfo[obj.Id].FUnitId%> : m_snp_dtr_req_pkt.smi_targ_ncore_unit_id),
                                        .smi_msg_tier           ('h0),
                                        .smi_msg_qos            ('0),
                                        .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%>? (m_snp_dtr_req_pkt == null) ? m_dtr_req_pkt.smi_msg_pri : m_snp_dtr_req_pkt.smi_msg_pri : 'h0),
                                        .smi_msg_type           (DTR_RSP),
                                        .smi_tm                 ((m_snp_dtr_req_pkt == null) ? m_dtr_req_pkt.smi_tm : m_snp_dtr_req_pkt.smi_tm),
                                        .smi_msg_id             ('h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0),
//                                        .smi_rl                 ('h0),
                                        .smi_rmsg_id            ((m_snp_dtr_req_pkt == null) ? m_dtr_req_pkt.smi_msg_id : m_snp_dtr_req_pkt.smi_msg_id)
                                        );
    endfunction : gen_exp_smi_dtr_rsp

    function void gen_exp_smi_dtw_req();
        int mem_region;
        exp_dtw_req_pkt = smi_seq_item::type_id::create("exp_dtw_req_pkt");
        //if(!$test$plusargs("unmapped_add_access"))
        if(!$test$plusargs("unmapped_add_access") || !$test$plusargs("pick_boundary_addr") || (!$test$plusargs("zero_nonzero_crd_test") || (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (is_crd_zero_err == 0))) ||(!$test$plusargs("non_secure_access_test") || ($test$plusargs("non_secure_access_test") && (isNSset == 0))) || ($test$plusargs("pick_boundary_addr") && ((!addr_trans_mgr::check_unmapped_add(m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || ((m_chi_req_pkt.opcode inside {DVMOP})))) || ($test$plusargs("unmapped_add_access") && ((!addr_trans_mgr::check_unmapped_add(m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || m_chi_req_pkt.opcode inside {DVMOP})))
        exp_dtw_req_pkt.construct_dtwmsg(
                                        .smi_steer              ('h0),
                                        .smi_targ_ncore_unit_id (m_chi_req_pkt.opcode == DVMOP ? DVE_FUNIT_IDS[0] : addrMgrConst::map_addr2dmi_or_dii(m_chi_req_pkt.addr, mem_region)), 
                                        .smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_msg_tier           ('h0),
                                        .smi_msg_qos            ('0),
                                        .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%>? qos_mapping(m_chi_req_pkt.qos): 'h0),
                                        .smi_msg_type           (DTW_DATA_CLN), // checked in wdata_pkt_field_checks() function
                                        .smi_msg_id             ('h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0),
                                        .smi_rl                 (2'b10),
                                        .smi_tm                 (exp_smi_tm),
                                        .smi_prim               ('h1),
                                        //.smi_mpf1_stash_nid     ('h0),
                                        //.smi_mpf1_argv          (m_str_req_pkt.smi_mpf1_argv),
                                        .smi_mpf1		(m_str_req_pkt !==null ? m_str_req_pkt.smi_mpf1_argv : 'h0),
					.smi_mpf2		('0),
                                        //.smi_rmsg_id            ('h0),
                                        .smi_rbid               ('h0),
                                        //.smi_intfsize		('0),
                                        .smi_intfsize           ((WBE/8)/(2)), //2^(Intfsize) DWs. datawidh 128bits = 2 DW = 2^1
                                        .smi_ndp_aux		('0),
                                        .smi_dp_last            ('h0),
                                        .smi_dp_data            ({'h0}), 
                                        .smi_dp_be              ({'h0}),
                                        .smi_dp_protection      ({'h0}),
                                        .smi_dp_dwid            ({'h0}),
                                        .smi_dp_dbad            ({'h0}),
                                        .smi_dp_concuser        ({'h0})
                                        );
    endfunction : gen_exp_smi_dtw_req

    function void gen_exp_smi_dtw_rsp();
        exp_dtw_rsp_pkt = smi_seq_item::type_id::create("exp_dtw_rsp_pkt");
        exp_dtw_rsp_pkt.construct_dtwrsp(
                                        .smi_steer              ('h0),
                                        .smi_targ_ncore_unit_id (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_src_ncore_unit_id  ((m_dtw_req_pkt !== null) ? m_dtw_req_pkt.smi_targ_ncore_unit_id : 'h0),
                                        .smi_msg_tier           ('h0),
                                        .smi_msg_qos            ('0),
                                        .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%>? (m_snp_dtw_req_pkt == null) ? m_dtw_req_pkt.smi_msg_pri : m_snp_dtw_req_pkt.smi_msg_pri : 'h0),
                                        .smi_msg_type           (DTW_RSP),
                                        .smi_tm                 (m_dtw_req_pkt.smi_tm),
                                        .smi_msg_id             ('h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0),
                                        .smi_rl                 ('h0),
                                        .smi_rmsg_id            (m_dtw_req_pkt.smi_msg_id)
                                        );
    endfunction : gen_exp_smi_dtw_rsp

    function void gen_exp_smi_snp_rsp();
        exp_snp_rsp_pkt = smi_seq_item::type_id::create("exp_snp_rsp_pkt");
        exp_snp_rsp_pkt.construct_snprsp(
                                        .smi_steer              ('h0),
                                        .smi_targ_ncore_unit_id ((m_snp_req_pkt !== null) ? m_snp_req_pkt.smi_src_ncore_unit_id : 'h0),
                                        .smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_msg_tier           ('h0),
                                        .smi_msg_qos            ('h0),
                                        .smi_msg_pri            ((<%=obj.AiuInfo[obj.Id].fnEnableQos%> && m_snp_req_pkt !== null) ? m_snp_req_pkt.smi_msg_pri : 'h0),
                                        .smi_msg_type           (SNP_RSP),
                                        .smi_msg_id             ('h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0),//SNPrsp: CMStatus[6]: Reserved; CMStatus[5:0] = RV, RS, DC, DT[1:0], Snarf; DT[1]: Data transfer to an AIU; DT[0]: Data transfer to DMI.
                                        .smi_cmstatus_rv        ('h0),
                                        .smi_cmstatus_rs        ('h0),
                                        .smi_cmstatus_dc        ('h0),
                                        .smi_cmstatus_dt_aiu    ('h0),
                                        .smi_cmstatus_dt_dmi    ('h0),
                                        .smi_cmstatus_snarf     (datapull),
                                        .smi_tm                 (m_snp_req_pkt.smi_tm),
                                        .smi_rmsg_id            (m_snp_req_pkt.smi_msg_id),
                                        .smi_mpf1_dtr_msg_id    ('h0),
                                        .smi_intfsize           ((WBE/8)/(2)) //2^(Intfsize) DWs. datawidh 128bits = 2 DW = 2^1
                                        );
    endfunction : gen_exp_smi_snp_rsp

    function void gen_exp_smi_snp_dtr();
        exp_snp_dtr_req_pkt = smi_seq_item::type_id::create("exp_snp_dtr_req_pkt");
        exp_snp_dtr_req_pkt.construct_dtrmsg(
                                         .smi_steer              ('h0),
                                         .smi_targ_ncore_unit_id (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                         .smi_src_ncore_unit_id  ('h0),
                                         .smi_msg_tier           ('h0),
                                         .smi_msg_qos            ('0),
                                         .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%> ? m_snp_req_pkt.smi_msg_pri:'0),
                                         .smi_msg_type           (DTR_DATA_INV), // Scoreboard has a function to check all posibble values: check_dtr_msg_types
                                         .smi_msg_id             ('h0),
                                         .smi_msg_err            ('h0),
                                         .smi_cmstatus           ('h0),
                                         .smi_rl                 (2'b01),
                                         .smi_tm                 ('h0),
                                         .smi_rmsg_id            (m_snp_req_pkt.smi_mpf2_dtr_msg_id),
                                         .smi_mpf1_dtr_long_dtw  ('h0),
                                         .smi_ndp_aux		 ('0),
                                         .smi_dp_last            ('h0),
                                         .smi_dp_data            ({'b0}),
                                         .smi_dp_be              ({'hff}),
                                         .smi_dp_protection      ({'b0}),
                                         .smi_dp_dwid            ({'b0}),
                                         .smi_dp_dbad            ({'b0}),
                                         .smi_dp_concuser        ({'b0})
                                         );
    endfunction : gen_exp_smi_snp_dtr

    function void gen_exp_smi_snp_dtw();
        int mem_region;
        exp_snp_dtw_req_pkt = smi_seq_item::type_id::create("exp_snp_dtw_req_pkt");
        exp_snp_dtw_req_pkt.construct_dtwmsg(
                                        .smi_steer              ('h0),
                                        .smi_targ_ncore_unit_id (addrMgrConst::map_addr2dmi_or_dii(m_snp_req_pkt.smi_addr, mem_region)), 
                                        .smi_src_ncore_unit_id  (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_msg_tier           ('h0),
                                        .smi_msg_qos            ('0),
                                        .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%> ? qos_mapping(m_snp_req_pkt.smi_qos) : '0),
                                        .smi_msg_type           (DTW_DATA_CLN), 
                                        .smi_msg_id             ('h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0),
                                        .smi_rl                 (2'b10),
                                        .smi_tm                 (m_snp_req_pkt.smi_tm),
                                        .smi_prim               ('h0),
                                        //.smi_mpf1_stash_nid     (m_snp_req_pkt.smi_mpf1_stash_nid),
                                        //.smi_mpf1_argv          (m_snp_req_pkt.smi_mpf1_argv),
					.smi_mpf1		(m_snp_req_pkt.smi_mpf1_stash_valid ? {m_snp_req_pkt.smi_mpf1_stash_valid,{(WSMIMPF1-WSMISTASHNID-1){1'b0}},m_snp_req_pkt.smi_mpf1_stash_nid} : m_snp_req_pkt.smi_mpf1_argv),
					.smi_mpf2		(m_snp_req_pkt.smi_mpf2),		
                                        //.smi_rmsg_id            ('h0),
                                        .smi_rbid               ('h0),
					.smi_intfsize		('0),
					.smi_ndp_aux		('0),
                                        .smi_dp_last            ('h0),
                                        .smi_dp_data            ({'h0}), // checked in snp_dtw_data_checks() function
                                        .smi_dp_be              ({'h0}),
                                        .smi_dp_protection      ({'h0}),
                                        .smi_dp_dwid            ({'h0}),
                                        .smi_dp_dbad            ({'h0}),
                                        .smi_dp_concuser        ({'h0})
                                        );
    endfunction : gen_exp_smi_snp_dtw

    function void gen_exp_smi_cmp_rsp();
        exp_cmp_rsp_pkt = smi_seq_item::type_id::create("exp_cmp_rsp_pkt");
        exp_cmp_rsp_pkt.construct_cmprsp(
                                        .smi_steer              ('h0),
                                        .smi_targ_ncore_unit_id (<%=obj.AiuInfo[obj.Id].FUnitId%>),
                                        .smi_src_ncore_unit_id  (DVE_FUNIT_IDS[0]),
                                        .smi_msg_tier           ('h0),
                                        .smi_msg_qos            ('0),
                                        .smi_msg_pri            (<%=obj.AiuInfo[obj.Id].fnEnableQos%> ? qos_mapping(m_cmd_req_pkt.smi_qos) : '0),
                                        .smi_msg_type           (CMP_RSP),
                                        .smi_tm                 (m_cmd_req_pkt.smi_tm),
                                        .smi_msg_id             ('h0),
                                        .smi_msg_err            ('h0),
                                        .smi_cmstatus           ('h0),
                                        .smi_rmsg_id            (m_cmd_req_pkt.smi_msg_id)
                                        );
    endfunction : gen_exp_smi_cmp_rsp

    function void gen_exp_chi_cresp(chi_rsp_opcode_enum_t resp);
        chi_rsp_seq_item m_pkt;
        //there could be multiple rsp sent on CHI for a given transaction, but at
        //a given time there should only be 1 outstanding
        m_pkt = chi_rsp_seq_item::type_id::create("m_pkt");
        if (m_chi_snp_addr_pkt !== null) begin
            m_pkt.qos = m_chi_snp_addr_pkt.qos;
            m_pkt.tgtid = m_chi_snp_addr_pkt.srcid;
            m_pkt.srcid = m_req_aiu_id; //m_chi_snp_addr_pkt.tgtid;
            m_pkt.txnid = dbid;
            m_pkt.pcrdtype = 0;
            m_pkt.opcode = resp;
            m_pkt.resperr = 'b00;
            m_pkt.resp = 'h0;
            m_pkt.fwdstate = 'h0;
            m_pkt.datapull = 'h0;
            exp_chi_srsp_pkt = chi_rsp_seq_item::type_id::create("exp_chi_srsp_pkt");
            exp_chi_srsp_pkt.copy(m_pkt);
            return;
        end
        m_pkt.qos = m_chi_req_pkt.qos;
        if (resp == COMPACK) begin
            m_pkt.tgtid = m_chi_req_pkt.tgtid;
            m_pkt.srcid = m_chi_req_pkt.srcid;
        end else begin
            m_pkt.tgtid = m_chi_req_pkt.srcid;
            m_pkt.srcid = m_chi_req_pkt.tgtid;
        end
        if ((m_chi_req_pkt.opcode inside {read_ops}) && (resp == COMPACK)
            <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                && m_chi_req_pkt.opcode != MAKEREADUNIQUE
            <%}%>
        ) begin
            m_pkt.txnid = m_chi_read_data_pkt[0].dbid; // FOR reads, this is same as DBID of the read data, for dataless, set this before comparing
        end else begin
            m_pkt.txnid = m_chi_req_pkt.txnid;
        end
        // <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
        //     if (m_chi_req_pkt.opcode == MAKEREADUNIQUE) begin
        //         if (m_chi_req_pkt.excl && m_str_req_pkt.smi_cmstatus_exok && !mkrdunq_part1_complete) begin
        //             m_pkt.txnid = m_chi_crsp_pkt.dbid;
        //         end else begin
        //             m_pkt.txnid = m_chi_read_data_pkt[0].dbid;
        //         end
        //     end
        // <%}%>
        m_pkt.pcrdtype = 'h0;
        m_pkt.opcode = resp;
        m_pkt.resperr = 'b00;
        if (m_chi_req_pkt.excl == 1 && 
<%if ((obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E')) {%>
           (m_chi_req_pkt.opcode inside {CLEANUNIQUE, WRITENOSNPPTL, WRITENOSNPFULL, READNOSNP, READCLEAN, READSHARED, READNOTSHAREDDIRTY})) begin
<%}else{%>
           (m_chi_req_pkt.opcode inside {CLEANUNIQUE, WRITENOSNPPTL, WRITENOSNPFULL, READNOSNP, READCLEAN, READSHARED })) begin
<%}%>
            if(m_chi_req_pkt.opcode inside {CLEANUNIQUE})
              m_pkt.resperr = m_str_req_pkt !==null ? m_str_req_pkt.smi_cmstatus_exok : 2'b00;
            else if(m_chi_req_pkt.opcode inside {READNOSNP})begin
              m_pkt.resperr = resp==READRECEIPT ? 2'b00 : m_dtr_req_pkt !==null ? m_dtr_req_pkt.smi_cmstatus_exok : 2'b00;
<%if ((obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E')) {%>
            end else if(m_chi_req_pkt.opcode inside {READCLEAN, READSHARED, READNOTSHAREDDIRTY})begin
<%}else{%>
            end else if(m_chi_req_pkt.opcode inside {READCLEAN, READSHARED})begin
<%}%>
	      m_pkt.resperr = 2'b01; //Per Khaleel coh exclusive load always pass 7/22/2020
	    end else
              m_pkt.resperr = resp==DBIDRESP ? 2'b00 : m_dtw_rsp_pkt !==null ? m_dtw_rsp_pkt.smi_cmstatus_exok : 
			      (m_str_req_pkt !==null ? m_str_req_pkt.smi_cmstatus_exok : 2'b00);
        end
        if (m_str_req_pkt != null && m_str_req_pkt.smi_cmstatus_err === 1'b1 && (m_str_req_pkt.smi_cmstatus_err_payload === 7'b000_0011 || m_str_req_pkt.smi_cmstatus_err_payload === 7'b010_0110) && resp != COMPACK && resp != READRECEIPT && resp != DBIDRESP) begin
          m_pkt.resperr = 2'b10; //Data error
        end else if (m_str_req_pkt != null && m_str_req_pkt.smi_cmstatus_err === 1'b1 && resp != COMPACK && resp != READRECEIPT && resp != DBIDRESP) begin
          m_pkt.resperr = 2'b11; //Non data error
        end
        
        //m_pkt.resperr = 'b11; DVMop Error

        if (resp == COMPACK) begin
          m_pkt.resperr = 0;
        end
        m_pkt.resp = 'h0;
        m_pkt.fwdstate = 'h0;
        m_pkt.datapull = 'h0;
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        if (m_chi_req_pkt.opcode inside {MAKEUNIQUE, CLEANUNIQUE, CLEANSHARED}) begin
        <% } else { %>
        if (m_chi_req_pkt.opcode inside {MAKEUNIQUE, CLEANUNIQUE, CLEANSHARED, CLEANSHAREDPERSIST
            <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                ,CLEANSHAREDPERSISTSEP, MAKEREADUNIQUE
            <%}%>
        }) begin
        <% } %>
            m_pkt.resp = 3'b010;
        end else if (m_chi_req_pkt.opcode inside {EVICT, CLEANINVALID, MAKEINVALID, DVMOP
            <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                , WRITEEVICTOREVICT
            <%}%>
        }) begin
	    //#Check.CHI.v3.7.WriteEvictOrEvict.NoError
            m_pkt.resp = 3'b000;
        end
        if (resp == COMPACK) begin
            exp_chi_srsp_pkt = chi_rsp_seq_item::type_id::create("exp_chi_srsp_pkt");
            exp_chi_srsp_pkt.copy(m_pkt);
        end else begin
            exp_chi_crsp_pkt = chi_rsp_seq_item::type_id::create("exp_chi_crsp_pkt");
            exp_chi_crsp_pkt.copy(m_pkt);
        end
    endfunction : gen_exp_chi_cresp

    function void gen_exp_chi_wdata();
        num_of_wdata_flit_exp = ((2**m_chi_req_pkt.size)/WBE) == 0 ? 1 : (2**m_chi_req_pkt.size)/WBE;
        num_of_wdata_flit_max_exp = num_of_wdata_flit_exp;
        //bit[6:0] end_addr = (m_chi_req_pkt.addr[5:0]+((2**m_chi_req_pkt.size)-1));
        //if (end_addr > m_chi_req_pkt.addr[5:0]) num_of_wdata_flit_exp = ((end_addr/WBE) - (m_chi_req_pkt.addr[5:0]/WBE)) + 1;
        //else num_of_wdata_flit_exp = ((m_chi_req_pkt.addr[5:0]/WBE) - (end_addr/WBE)) + 1;
        //if (num_of_wdata_flit_exp > 4) num_of_wdata_flit_exp = 4;
        //`uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : start_Addr=0x%0h, end_addr=0x%0h, num_of_wdata_flit_exp=%0d, (end_addr/WBE)=0x%0h, start_Addr[5:0]/WBE=0x%0h", chi_aiu_uid, m_chi_req_pkt.addr, end_addr, num_of_wdata_flit_exp, (end_addr/WBE), (m_chi_req_pkt.addr[5:0]/WBE)), UVM_MEDIUM)
        for (int i = 0; i < num_of_wdata_flit_exp; i++) begin
            automatic chi_dat_seq_item   tmp_pkt;
            tmp_pkt = chi_dat_seq_item::type_id::create("exp_chi_write_data_pkt");
            case (i)
                0:
                begin
                    if (WDATA == 128)
                        tmp_pkt.dataid = m_chi_req_pkt.addr[5:4];
                    else if (WDATA == 256)
                        tmp_pkt.dataid = (m_chi_req_pkt.addr[5:4] == 2'b01) ? 2'b00 : (m_chi_req_pkt.addr[5:4] == 2'b11) ? 2'b10 : m_chi_req_pkt.addr[5:4];
                    else
                        tmp_pkt.dataid = 2'b00;
                end
                1:
                begin
                    if (WDATA == 128)
                        tmp_pkt.dataid = exp_chi_write_data_pkt[0].dataid + 'b01;
                    else if (WDATA == 256)
                        tmp_pkt.dataid = exp_chi_write_data_pkt[0].dataid + 'b10;
                    else if (WDATA == 512)
                        `uvm_error(`LABEL_ERROR, $psprintf("For Data width of 512, there should only be 1 expected data packet, num_of_wdata_flit_exp = %0h", num_of_wdata_flit_exp))
                end
                2:
                begin
                    if (WDATA == 128)
                        tmp_pkt.dataid = exp_chi_write_data_pkt[0].dataid + 'b10;
                    else if (WDATA == 256)
                        `uvm_error(`LABEL_ERROR, $psprintf("For Data width of 256, there should only be maximum 2 expected data packet, num_of_wdata_flit_exp = %0h", num_of_wdata_flit_exp))
                    else if (WDATA == 512)
                        `uvm_error(`LABEL_ERROR, $psprintf("For Data width of 512, there should only be 1 expected data packet, num_of_wdata_flit_exp = %0h", num_of_wdata_flit_exp))
                end
                3:
                begin
                    if (WDATA == 128)
                        tmp_pkt.dataid = exp_chi_write_data_pkt[0].dataid + 'b11;
                    else if (WDATA == 256)
                        `uvm_error(`LABEL_ERROR, $psprintf("For Data width of 256, there should only be maximum 2 expected data packet, num_of_wdata_flit_exp = %0h", num_of_wdata_flit_exp))
                    else if (WDATA == 512)
                        `uvm_error(`LABEL_ERROR, $psprintf("For Data width of 512, there should only be 1 expected data packet, num_of_wdata_flit_exp = %0h", num_of_wdata_flit_exp))
                end
            endcase
            tmp_pkt.dbid = m_chi_crsp_pkt.dbid;
            tmp_pkt.ccid = m_chi_req_pkt.addr[5:4];
            tmp_pkt.qos = m_chi_crsp_pkt.qos;
            tmp_pkt.txnid = m_chi_crsp_pkt.dbid;//CHI spec 2.7.3 (Transaction ID flows, Write transactions) bullet #3
            tmp_pkt.tgtid = m_chi_crsp_pkt.srcid;
            tmp_pkt.srcid = m_chi_crsp_pkt.tgtid;
            tmp_pkt.homenid = 'h0; // HomeNID is applicable in CompData and is inapplicable, and must be set to zero, for all other data messages
            tmp_pkt.tracetag = m_chi_crsp_pkt.tracetag;
            exp_chi_write_data_pkt.push_back(tmp_pkt);
        end
    endfunction : gen_exp_chi_wdata

    function void gen_exp_chi_data(chi_dat_opcode_t opcode);
        //bit[6:0] end_addr = (m_chi_req_pkt.addr[5:0]+((2**m_chi_req_pkt.size)-1));

        `uvm_info(`LABEL, $psprintf("packet size: %0h, bytes per flit: %0d", (m_chi_req_pkt !== null) ? m_chi_req_pkt.size : 6, WBE), UVM_MEDIUM)
        if ( m_chi_snp_addr_pkt!== null
             && m_chi_snp_addr_pkt.opcode inside {stash_snps}) begin
            //num_of_rdata_flit_exp = 4;
            num_of_rdata_flit_exp = ((2**6)/WBE);
        end else begin
            <%if ((obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E')) {%>
                if(m_chi_req_pkt.opcode == ATOMICCOMPARE)
                    num_of_rdata_flit_exp = ((2**m_chi_req_pkt.size)/WBE <= 1) ? 1 : ((2**m_chi_req_pkt.size)/WBE)/2;
                else		
                    num_of_rdata_flit_exp = ((2**m_chi_req_pkt.size)/WBE == 0) ? 1 : ((2**m_chi_req_pkt.size)/WBE);
            <%}else{%>
                num_of_rdata_flit_exp = ((2**m_chi_req_pkt.size)/WBE == 0) ? 1 : ((2**m_chi_req_pkt.size)/WBE);
            <%}%>
        end

        num_of_rdata_flit_max_exp = num_of_rdata_flit_exp;
        for (int i = 0; i < num_of_rdata_flit_exp; i++) begin
            automatic chi_dat_seq_item   tmp_pkt;
            tmp_pkt = chi_dat_seq_item::type_id::create("exp_chi_read_data_pkt");

            if ( m_chi_snp_addr_pkt!== null
                && m_chi_snp_addr_pkt.opcode inside {stash_snps}) begin
                tmp_pkt.qos = m_chi_snp_addr_pkt.qos;
                tmp_pkt.tgtid = m_req_aiu_id ; //for stashing, the chi rdata flit is in the same direction as chi snp flit
                tmp_pkt.srcid = m_chi_snp_addr_pkt.srcid;
                tmp_pkt.txnid = dbid;
                tmp_pkt.homenid = m_chi_snp_addr_pkt.srcid;
                if (m_dtr_req_pkt !== null) tmp_pkt.dbid = m_dtr_req_pkt.smi_rbid;
                $cast(tmp_pkt.opcode , opcode);
                //tmp_pkt.resperr = 0;
                tmp_pkt.resp = 'h0;
                tmp_pkt.fwdstate = 'h0;
                tmp_pkt.datapull = 'h0;
                tmp_pkt.datasource = 'h0;
                tmp_pkt.ccid = (WBE == 16) ? m_chi_snp_addr_pkt.addr[2:1] : (WBE == 32) ? { m_chi_snp_addr_pkt.addr[2], 1'b0} : 2'b00;
                tmp_pkt.be = 0;
                tmp_pkt.data = 0;
                <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A' && (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wPoison>0)) { %> 
                if (m_dtr_req_pkt !== null) tmp_pkt.poison = m_dtr_req_pkt.smi_dp_dbad[i];
		<%}%>
                tmp_pkt.last = 'h0;//(i == (num_of_rdata_flit_exp-1)) ? 1'b1 : 1'b0;
            end else begin
                tmp_pkt.qos = m_chi_req_pkt.qos;
                tmp_pkt.tgtid = m_chi_req_pkt.srcid;
                tmp_pkt.srcid = m_chi_req_pkt.tgtid;
                tmp_pkt.txnid = m_chi_req_pkt.txnid;
                //if (m_chi_req_pkt.opcode == READNOSNP) tmp_pkt.txnid = m_chi_req_pkt.returntxnid;
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
                tmp_pkt.homenid = m_chi_req_pkt.tgtid;
<% } else { %>
                tmp_pkt.homenid = 'h0; //FIXME: balajik - see if unused fields for CHI-A can be removed from the sequence item.
<% } %>
                if (m_dtr_rsp_pkt !== null) tmp_pkt.dbid = m_dtr_req_pkt.smi_rbid;
                $cast(tmp_pkt.opcode , opcode);
                //tmp_pkt.resperr = 0;
                if (m_chi_req_pkt.excl == 1 &&(!(m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops}))) begin
                    if(m_chi_req_pkt.opcode inside {READNOSNP})
	              tmp_pkt.resperr = m_dtr_req_pkt!==null ?  m_dtr_req_pkt.smi_cmstatus_exok :
						(m_str_req_pkt !==null ? m_str_req_pkt.smi_cmstatus_exok : 2'b00);
<%if ((obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E')) {%>
		    else if (m_chi_req_pkt.opcode inside {READCLEAN, READSHARED, READNOTSHAREDDIRTY}) //per Khaleel coh excl load always pass
<%}else{%>
		    else if (m_chi_req_pkt.opcode inside {READCLEAN, READSHARED }) //per Khaleel coh excl load always pass
<%}%>

                      tmp_pkt.resperr = 2'b01;
                end
                if (m_str_req_pkt != null && m_str_req_pkt.smi_cmstatus_err === 1'b1 && (m_str_req_pkt.smi_cmstatus_err_payload === 7'b000_0011 || m_str_req_pkt.smi_cmstatus_err_payload === 7'b010_0110)) begin
                  tmp_pkt.resperr = 2'b10; //Data error
                end else if (m_str_req_pkt != null && m_str_req_pkt.smi_cmstatus_err === 1'b1) begin
                  tmp_pkt.resperr = 2'b11; //Non data error
                end
                if (m_str_req_pkt != null && m_str_req_pkt.smi_cmstatus_err === 1'b1) begin
                  tmp_pkt.poison = '1;
                end
                tmp_pkt.resp = 'h0;
                tmp_pkt.fwdstate = 'h0;
                tmp_pkt.datapull = 'h0;
                tmp_pkt.datasource = 'h0;
                tmp_pkt.ccid = m_chi_req_pkt.addr[5:4];
                tmp_pkt.be = 0;
                tmp_pkt.data = 0;
                <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A' && (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wPoison>0)) { %> 
                if (m_dtr_req_pkt !== null) begin 
			tmp_pkt.poison = m_dtr_req_pkt.smi_dp_dbad[i];
		end
		<%}%>
                tmp_pkt.last = 'h0;//(i == (num_of_rdata_flit_exp-1)) ? 1'b1 : 1'b0;
            end

            case (i)
                0:
                begin
                    if (WDATA == 128)
                        tmp_pkt.dataid = tmp_pkt.ccid;
                    else if (WDATA == 256)
                        tmp_pkt.dataid = (tmp_pkt.ccid == 2'b01) ? 2'b00 : (tmp_pkt.ccid == 2'b11) ? 2'b10 : tmp_pkt.ccid;
                    else
                        tmp_pkt.dataid = 2'b00;
                end
                1:
                begin
                    if (WDATA == 128)
                        if(num_of_rdata_flit_exp==2 && tmp_pkt.ccid%2==1)
				tmp_pkt.dataid = tmp_pkt.ccid - 1;
			else
                        	tmp_pkt.dataid = exp_chi_read_data_pkt[0].dataid + 'b01;
                    else if (WDATA == 256)
                        tmp_pkt.dataid = exp_chi_read_data_pkt[0].dataid + 'b10;
                    else if (WDATA == 512)
                        `uvm_error(`LABEL_ERROR, $psprintf("For Data width of 512, there should only be 1 expected data packet, num_of_wdata_flit_exp = %0h", num_of_wdata_flit_exp))
                end
                2:
                begin
                    if (WDATA == 128)
                        tmp_pkt.dataid = exp_chi_read_data_pkt[0].dataid + 'b10;
                    else if (WDATA == 256)
                        `uvm_error(`LABEL_ERROR, $psprintf("For Data width of 256, there should only be maximum 2 expected data packet, num_of_wdata_flit_exp = %0h", num_of_wdata_flit_exp))
                    else if (WDATA == 512)
                        `uvm_error(`LABEL_ERROR, $psprintf("For Data width of 512, there should only be 1 expected data packet, num_of_wdata_flit_exp = %0h", num_of_wdata_flit_exp))
                end
                3:
                begin
                    if (WDATA == 128)
                        tmp_pkt.dataid = exp_chi_read_data_pkt[0].dataid + 'b11;
                    else if (WDATA == 256)
                        `uvm_error(`LABEL_ERROR, $psprintf("For Data width of 256, there should only be maximum 2 expected data packet, num_of_wdata_flit_exp = %0h", num_of_wdata_flit_exp))
                    else if (WDATA == 512)
                        `uvm_error(`LABEL_ERROR, $psprintf("For Data width of 512, there should only be 1 expected data packet, num_of_wdata_flit_exp = %0h", num_of_wdata_flit_exp))
                end
            endcase

            //JIRA 4553: CCID remains same as addr[5:4] only dataid changes when data width is 256bits.
            if ( m_chi_snp_addr_pkt!== null) begin
            //    && m_chi_snp_addr_pkt.opcode inside {stash_snps}) begin
                tmp_pkt.ccid = m_chi_snp_addr_pkt.addr[2:1];
            end

            exp_chi_read_data_pkt.push_back(tmp_pkt);

        end
    endfunction : gen_exp_chi_data


    function void gen_exp_chi_snp_req();
        exp_chi_snp_addr_pkt = chi_snp_seq_item::type_id::create("m_chi_snp_addr_pkt");
        exp_chi_snp_addr_pkt.qos = <%=obj.AiuInfo[obj.Id].fnEnableQos%> ? m_snp_req_pkt.smi_qos : '0;
        exp_chi_snp_addr_pkt.tgtid = 'h0; //FIXME //SNP tgtid dont care for now. Khaleel is checking.
        exp_chi_snp_addr_pkt.srcid = (m_snp_req_pkt.smi_msg_type inside {SNP_DVM_MSG}) ? <%=obj.DveInfo[0].FUnitId%> : m_req_aiu_id; // FIXME: waiting for Sanjay's input <%=obj.FUnitId%>;
        exp_chi_snp_addr_pkt.fwdnid = <%=obj.AiuInfo[obj.Id].FUnitId%>;
        
        <%if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            if (m_snp_req_pkt.smi_msg_type inside {SNP_DVM_MSG}) begin
                exp_chi_snp_addr_pkt.vmidext  = (m_snp_req_pkt.smi_addr[3] == 'b0) ? m_snp_req_pkt.smi_mpf1_vmid_ext : 0;
                exp_chi_snp_addr_pkt.fwdtxnid = (m_snp_req_pkt.smi_addr[3] == 'b0) ? m_snp_req_pkt.smi_mpf1_vmid_ext : 0;
            end
            else begin
                exp_chi_snp_addr_pkt.fwdtxnid = (m_snp_req_pkt.smi_mpf1_stash_valid && m_snp_req_pkt.smi_mpf1_stash_nid == <%=obj.AiuInfo[obj.Id].FUnitId%>) ?
                            {m_snp_req_pkt.smi_mpf2_stash_valid, m_snp_req_pkt.smi_mpf2_stash_lpid} :  'h0; // CHI protocol: 12.9.13: Applicable in forward type snoops. Inapplicable and must be zero in all other snoop requests.

                exp_chi_snp_addr_pkt.vmidext = (m_snp_req_pkt.smi_mpf1_stash_valid && m_snp_req_pkt.smi_mpf1_stash_nid == <%=obj.AiuInfo[obj.Id].FUnitId%>) ?
                            {m_snp_req_pkt.smi_mpf2_stash_valid, m_snp_req_pkt.smi_mpf2_stash_lpid} :  'h0;
            end
        <%}else{%>
            exp_chi_snp_addr_pkt.fwdtxnid = 'h0; 
            exp_chi_snp_addr_pkt.vmidext = 'h0; 
        <%}%>
        if (m_snp_req_pkt.smi_msg_type inside {SNP_INV_STSH, SNP_UNQ_STSH, SNP_STSH_SH, SNP_STSH_UNQ} && m_snp_req_pkt.smi_mpf1_stash_valid) 
            exp_chi_snp_addr_pkt.opcode = get_chi_snp_opcode(m_snp_req_pkt.smi_msg_type, m_snp_req_pkt.smi_mpf1_stash_nid == <%=obj.AiuInfo[obj.Id].FUnitId%>);
        else
            exp_chi_snp_addr_pkt.opcode = get_chi_snp_opcode(m_snp_req_pkt.smi_msg_type, 0);

        //According to CCMP 1st Snp field to CHI E 1st Snp field mapping  ADDR is shifted by 3 bits
        exp_chi_snp_addr_pkt.addr = (m_snp_req_pkt !== null) ? (m_snp_req_pkt.smi_addr >> 3) : 'h0; 

        if (m_snp_req_pkt.smi_msg_type inside {SNP_DVM_MSG}) begin
            exp_chi_snp_addr_pkt.ns = 'h0;
        end
        else begin
            exp_chi_snp_addr_pkt.ns = (m_snp_req_pkt !== null) ? m_snp_req_pkt.smi_ns : 'h0;
        end
        if (exp_chi_snp_addr_pkt.opcode inside {SNPUNIQUE, SNPCLEANSHARED, SNPCLEANINVALID, SNPMAKEINVALID})
            exp_chi_snp_addr_pkt.donotgotosd = 'b1;
        else
        exp_chi_snp_addr_pkt.donotgotosd = 'b0; //FIXME: else it can be any value (probably gets its value from SMI SNP REQ
        exp_chi_snp_addr_pkt.donotdatapull = 'h0; //Only applicable in Stash snoops
        //exp_chi_snp_addr_pkt.rettosrc = 'h0; //FIXME
        exp_chi_snp_addr_pkt.tracetag = m_snp_req_pkt.smi_tm;
        <%if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            if (m_snp_req_pkt.smi_msg_type inside {SNP_DVM_MSG}) begin
                exp_chi_snp_addr_pkt.stashlpid[4:0] = (m_snp_req_pkt.smi_addr[3] == 'b0) ? m_snp_req_pkt.smi_mpf1_vmid_ext[4:0] : 0;
                exp_chi_snp_addr_pkt.stashlpidvalid = (m_snp_req_pkt.smi_addr[3] == 'b0) ? m_snp_req_pkt.smi_mpf1_vmid_ext[5] : 0;
            end
            else begin
                exp_chi_snp_addr_pkt.stashlpidvalid = (m_snp_req_pkt.smi_mpf1_stash_valid && m_snp_req_pkt.smi_mpf1_stash_nid == <%=obj.AiuInfo[obj.Id].FUnitId%>) ? m_snp_req_pkt.smi_mpf2_stash_valid : '0;
                exp_chi_snp_addr_pkt.stashlpid = (m_snp_req_pkt.smi_mpf1_stash_valid && m_snp_req_pkt.smi_mpf1_stash_nid == <%=obj.AiuInfo[obj.Id].FUnitId%>) ? m_snp_req_pkt.smi_mpf2_stash_lpid : '0;
            end
        <%}else{%>
            exp_chi_snp_addr_pkt.stashlpidvalid = 'h0;
            exp_chi_snp_addr_pkt.stashlpid = 'h0;
        <%}%>
        if (m_snp_req_pkt.smi_msg_type inside {SNP_DVM_MSG}) begin
            exp_chi_snp_addr_pkt.fwdnid = 'h0;
            if(m_snp_req_pkt.smi_mpf3_dvmop_portion == 1'b0) begin
                exp_chi_snp_addr_pkt.fwdnid[0] = m_snp_req_pkt.smi_mpf3_range;
            end else begin
                exp_chi_snp_addr_pkt.fwdnid[4:0] = m_snp_req_pkt.smi_mpf3_num;
            end
        end else begin
            exp_chi_snp_addr_pkt.fwdnid = 'h0;
        end


    endfunction : gen_exp_chi_snp_req

    function void gen_exp_chi_snp_rsp();
        exp_chi_srsp_pkt = chi_rsp_seq_item::type_id::create("exp_chi_srsp_pkt");
        exp_chi_srsp_pkt.qos = m_chi_snp_addr_pkt.qos;
        exp_chi_srsp_pkt.tgtid = m_chi_snp_addr_pkt.srcid;
        exp_chi_srsp_pkt.srcid = m_req_aiu_id; //m_chi_snp_addr_pkt.tgtid;
        exp_chi_srsp_pkt.txnid = m_chi_snp_addr_pkt.txnid;
        exp_chi_srsp_pkt.pcrdtype = 'h0;
        exp_chi_srsp_pkt.opcode = SNPRESP;
        exp_chi_srsp_pkt.resperr = 'b00;
        exp_chi_srsp_pkt.resp = 'h0;
        exp_chi_srsp_pkt.fwdstate = 'h0;
        exp_chi_srsp_pkt.datapull = 'h0;
        exp_chi_srsp_pkt.resp = 3'b000;
    endfunction : gen_exp_chi_snp_rsp

    function void gen_exp_smi_sys_req(smi_sysreq_op_t m_sysreq_op);
      string spkt;
      case(m_sysreq_op)
        SMI_SYSREQ_NOP : begin
          `uvm_info(`LABEL, $psprintf("Do nothing for now."), UVM_LOW)
        end
        SMI_SYSREQ_ATTACH,
        SMI_SYSREQ_DETACH : begin
          //#Check.CHIAIU.v3.4.Connectivity.SysReq
          foreach(sys_req_targ_id[i]) begin
            smi_seq_item tmp_pkt;
            tmp_pkt = smi_seq_item::type_id::create("exp_sys_req_pkt");
            tmp_pkt.construct_sysmsg(
              .smi_targ_ncore_unit_id   (sys_req_targ_id[i] >> WSMINCOREPORTID),
              .smi_src_ncore_unit_id    (<%=obj.AiuInfo[obj.Id].FUnitId%>),
              .smi_msg_type             (SYS_REQ),
              .smi_msg_id               ('h0),
              .smi_msg_tier             ('h0),
              .smi_steer                ('h0),
              .smi_msg_pri              ('h0),
              .smi_msg_qos              ('h0),
              .smi_rmsg_id              ('h0),
              .smi_msg_err              ('h0),
              .smi_cmstatus             ('h0),
              .smi_sysreq_op            (m_sysreq_op),
              .smi_ndp_aux              ('h0)
              );
            exp_sys_req_pkt.push_back(tmp_pkt);
            $sformat(spkt, "%0s pkt[%0d]=%0s\n", spkt, i, tmp_pkt.convert2string);
          end
          `uvm_info(`LABEL, $psprintf("Generated exp_sys_req_pkt as, \n %0s", spkt), UVM_DEBUG)
        end
        default : begin
          `uvm_error(`LABEL_ERROR, $sformatf("INSIDE: process_sys_req opcode support not added yet smi_sysreq_op=%0d", m_sysreq_op))
        end
      endcase
    endfunction : gen_exp_smi_sys_req

    function void gen_exp_smi_sys_rsp(const ref smi_seq_item m_pkt);
      smi_seq_item tmp_pkt;
      string spkt;
      tmp_pkt = smi_seq_item::type_id::create("exp_sys_rsp_pkt");
      case(m_sysreq_op)
        SMI_SYSREQ_NOP : begin
          `uvm_error(`LABEL_ERROR, $psprintf("No response expected?!"))
        end
        SMI_SYSREQ_ATTACH,
        SMI_SYSREQ_DETACH : begin
          tmp_pkt.construct_sysrsp(
                                  .smi_targ_ncore_unit_id (m_pkt.smi_src_ncore_unit_id),
                                  .smi_src_ncore_unit_id  (m_pkt.smi_targ_ncore_unit_id),
                                  .smi_msg_type           (SYS_RSP),
                                  .smi_msg_id             ('h0),
                                  .smi_msg_tier           ('h0),
                                  .smi_steer              ('h0),
                                  //.smi_msg_pri            (m_pkt.smi_msg_pri),
                                  .smi_msg_pri            ('0),
                                  .smi_msg_qos            ('0),
                                  .smi_tm                 ('h0),
                                  .smi_rmsg_id            (m_pkt.smi_msg_id),
                                  .smi_msg_err            ('h0),
                                  .smi_cmstatus           ('h3),
                                  .smi_ndp_aux            ('h0)
                                  );
          exp_sys_rsp_pkt.push_back(tmp_pkt);
          $sformat(spkt, "%0s pkt=%0s\n", spkt, tmp_pkt.convert2string);
          `uvm_info(`LABEL, $psprintf("Generated exp_sys_rsp_pkt as, \n %0s", spkt), UVM_DEBUG)
        end
        default : begin
          `uvm_error(`LABEL_ERROR, $sformatf("INSIDE: process_sys_req opcode support not added yet smi_sysreq_op=%0d", m_sysreq_op))
        end
      endcase
    endfunction : gen_exp_smi_sys_rsp

    function bit[3:0] determine_summary_bits(chi_req_opcode_enum_t chi_opcode);
        bit[3:0] cm_status = 4'b0;
        case(chi_opcode)
            REQLCRDRETURN        : cm_status = 'b0;
            READSHARED           : cm_status = 'b0;
            READCLEAN            : cm_status = 'b0;
            READONCE             : cm_status = 'b0;
            READNOSNP            : cm_status[0] = 'b1; //cmstatus[0]=1:completion
            PCRDRETURN           : cm_status = 'b0;
            READUNIQUE           : cm_status = 'b0;
            CLEANSHARED          : cm_status = 'b0;
            CLEANINVALID         : cm_status = 'b0;
            MAKEINVALID          : cm_status = 'b0;
            CLEANUNIQUE          : cm_status = 'b0;
            MAKEUNIQUE           : cm_status[3] = 'b1; //SO=1
            EVICT                : cm_status = 'b0;
            EOBARRIER            : cm_status = 'b0;
            ECBARRIER            : cm_status = 'b0;
            DVMOP                : cm_status = 'b0;
            WRITEEVICTFULL       : cm_status = 'b0;
            WRITECLEANPTL        : cm_status = 'b0;
            WRITECLEANFULL       : cm_status = 'b0;
            WRITEUNIQUEPTL       : cm_status = 'b0;
            WRITEUNIQUEFULL      : cm_status = 'b0;
            WRITEBACKPTL         : cm_status = 'b0;
            WRITEBACKFULL        : cm_status = 'b0;
            WRITENOSNPPTL        : cm_status = 'b0;
            WRITENOSNPFULL       : cm_status = 'b0;
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            WRITEUNIQUEFULLSTASH : cm_status = 'b0;
            WRITEUNIQUEPTLSTASH  : cm_status = 'b0;
            STASHONCESHARED      : cm_status = 'b0;
            STASHONCEUNIQUE      : cm_status = 'b0;
            READONCECLEANINVALID : cm_status = 'b0;
            READONCEMAKEINVALID  : cm_status = 'b0;
            READNOTSHAREDDIRTY   : cm_status = 'b0;
            CLEANSHAREDPERSIST   : cm_status = 'b0;
            <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
                CLEANSHAREDPERSISTSEP : cm_status = 'b0;
                MAKEREADUNIQUE   : cm_status = 'b0;
                WRITEEVICTOREVICT: cm_status = 'b0;
            <%}%>
            ATOMICSTORE_STADD    : cm_status = 'b0;
            ATOMICSTORE_STCLR    : cm_status = 'b0;
            ATOMICSTORE_STEOR    : cm_status = 'b0;
            ATOMICSTORE_STSET    : cm_status = 'b0;
            ATOMICSTORE_STSMAX   : cm_status = 'b0;
            ATOMICSTORE_STMIN    : cm_status = 'b0;
            ATOMICSTORE_STUSMAX  : cm_status = 'b0;
            ATOMICSTORE_STUMIN   : cm_status = 'b0;
            ATOMICLOAD_LDADD     : cm_status = 'b0;
            ATOMICLOAD_LDCLR     : cm_status = 'b0;
            ATOMICLOAD_LDEOR     : cm_status = 'b0;
            ATOMICLOAD_LDSET     : cm_status = 'b0;
            ATOMICLOAD_LDSMAX    : cm_status = 'b0;
            ATOMICLOAD_LDMIN     : cm_status = 'b0;
            ATOMICLOAD_LDUSMAX   : cm_status = 'b0;
            ATOMICLOAD_LDUMIN    : cm_status = 'b0;
            ATOMICSWAP           : cm_status = 'b0;
            ATOMICCOMPARE        : cm_status = 'b0;
            PREFETCHTARGET       : cm_status = 'b0;
        <% } %>
        endcase
        return cm_status;
    endfunction : determine_summary_bits

    function chi_snp_opcode_enum_t get_chi_snp_opcode(smi_msg_type_bit_t smi_msg_type, bit targetted_snooper=0);
        chi_snp_opcode_enum_t opcode;
        case(smi_msg_type)
            SNP_CLN_DTR     : opcode = SNPCLEAN;
            SNP_NITC        : opcode = SNPONCE;
            SNP_VLD_DTR     : opcode = SNPSHARED;
            SNP_INV_DTR     : opcode = SNPUNIQUE;
<% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            SNP_NOSDINT     : opcode = SNPNSHDTY;
<% } else { %>
            SNP_NOSDINT     : opcode = SNPSHARED;
<% } %>
            SNP_INV_DTW     : opcode = SNPCLEANINVALID;
            SNP_INV         : opcode = SNPMAKEINVALID;
            SNP_CLN_DTW     : opcode = SNPCLEANSHARED;
            SNP_INV_STSH    : opcode = targetted_snooper ? SNPMKINVSTASH : SNPMAKEINVALID;
            SNP_UNQ_STSH    : opcode = targetted_snooper ? SNPUNQSTASH : SNPUNIQUE;
            SNP_STSH_SH     : opcode = targetted_snooper ? SNPSTASHSHRD : SNPSHARED;
            SNP_STSH_UNQ    : opcode = targetted_snooper ? SNPSTASHUNQ : SNPUNIQUE;
            SNP_DVM_MSG     : opcode = SNPDVMOP;
            SNP_NITCCI      : opcode = SNPUNIQUE;
            SNP_NITCMI      : opcode = SNPUNIQUE;
        endcase
        return opcode;
    endfunction : get_chi_snp_opcode

    function smi_msg_type_bit_t get_smi_msg_type(chi_req_opcode_enum_t chi_opcode);
        smi_msg_type_bit_t smi_msg_type;
        case(chi_opcode)
            REQLCRDRETURN        : smi_msg_type = 'hxx;
            READSHARED           : smi_msg_type = 'h03;
            READCLEAN            : smi_msg_type = 'h01;
            READONCE             : smi_msg_type = 'h07;
            READNOSNP            : smi_msg_type = 'h0B;
            PCRDRETURN           : smi_msg_type = 'hxx;
            READUNIQUE           : smi_msg_type = 'h04;
            CLEANSHARED          : smi_msg_type = 'h08;
            CLEANINVALID         : smi_msg_type = 'h09;
            MAKEINVALID          : smi_msg_type = 'h0A;
            CLEANUNIQUE          : smi_msg_type = 'h05;
            MAKEUNIQUE           : smi_msg_type = 'h06;
            EVICT                : smi_msg_type = 'h17;
            EOBARRIER            : smi_msg_type = 'h0D;
            ECBARRIER            : smi_msg_type = 'h0E;
            DVMOP                : smi_msg_type = 'h0F;
            WRITEEVICTFULL       : smi_msg_type = 'h16;
            WRITECLEANPTL        : smi_msg_type = 'h19;
            WRITECLEANFULL       : smi_msg_type = 'h15;
            WRITEUNIQUEPTL       : smi_msg_type = 'h10;
            WRITEUNIQUEFULL      : smi_msg_type = 'h11;
            WRITEBACKPTL         : smi_msg_type = 'h18;
            WRITEBACKFULL        : smi_msg_type = 'h14;
            WRITENOSNPPTL        : smi_msg_type = 'h20;
            WRITENOSNPFULL       : smi_msg_type = 'h21;
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            WRITEUNIQUEFULLSTASH : smi_msg_type = 'h22;
            WRITEUNIQUEPTLSTASH  : smi_msg_type = 'h23;
            STASHONCESHARED      : smi_msg_type = 'h24;
            STASHONCEUNIQUE      : smi_msg_type = 'h25;
            READONCECLEANINVALID : smi_msg_type = 'h26;
            READONCEMAKEINVALID  : smi_msg_type = 'h27;
            READNOTSHAREDDIRTY   : smi_msg_type = 'h02;
            CLEANSHAREDPERSIST   : smi_msg_type = 'h28;
            ATOMICSTORE_STADD    : smi_msg_type = 'h12;
            ATOMICSTORE_STCLR    : smi_msg_type = 'h12;
            ATOMICSTORE_STEOR    : smi_msg_type = 'h12;
            ATOMICSTORE_STSET    : smi_msg_type = 'h12;
            ATOMICSTORE_STSMAX   : smi_msg_type = 'h12;
            ATOMICSTORE_STMIN    : smi_msg_type = 'h12;
            ATOMICSTORE_STUSMAX  : smi_msg_type = 'h12;
            ATOMICSTORE_STUMIN   : smi_msg_type = 'h12;
            ATOMICLOAD_LDADD     : smi_msg_type = 'h13;
            ATOMICLOAD_LDCLR     : smi_msg_type = 'h13;
            ATOMICLOAD_LDEOR     : smi_msg_type = 'h13;
            ATOMICLOAD_LDSET     : smi_msg_type = 'h13;
            ATOMICLOAD_LDSMAX    : smi_msg_type = 'h13;
            ATOMICLOAD_LDMIN     : smi_msg_type = 'h13;
            ATOMICLOAD_LDUSMAX   : smi_msg_type = 'h13;
            ATOMICLOAD_LDUMIN    : smi_msg_type = 'h13;
            ATOMICSWAP           : smi_msg_type = 'h29;
            ATOMICCOMPARE        : smi_msg_type = 'h2A;
            PREFETCHTARGET       : smi_msg_type = 'h2B;
        <% } %>
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            READPREFERUNIQUE              	 : smi_msg_type = 'h02;
            CLEANSHAREDPERSISTSEP          	 : smi_msg_type = CMD_CLN_SH_PER; //FIXME: Use enums instead of hardcoded values for others
            MAKEREADUNIQUE                   : smi_msg_type = (m_chi_req_pkt.excl) ? ((mkrdunq_part1_complete) ? CMD_RD_NOT_SHD : CMD_CLN_UNQ) : (CMD_RD_UNQ);
            WRITEUNIQUEZERO                  : smi_msg_type = CMD_WR_UNQ_FULL;
            WRITENOSNPZERO                   : smi_msg_type = CMD_WR_NC_FULL;
            WRITEEVICTOREVICT                : smi_msg_type = 'h17;
            WRITENOSNPFULL_CLEANSHARED    	 : smi_msg_type = 'h21;
            WRITENOSNPFULL_CLEANINVALID   	 : smi_msg_type = 'h21;
            WRITENOSNPFULL_CLEANSHAREDPERSISTSEP : smi_msg_type = 'h21;
            WRITEBACKFULL_CLEANSHARED     	 : smi_msg_type = 'h14;
            WRITEBACKFULL_CLEANINVALID    	 : smi_msg_type = 'h14;
            WRITEBACKFULL_CLEANSHAREDPERSISTSEP  : smi_msg_type = 'h14;
            WRITECLEANFULL_CLEANSHARED    	 : smi_msg_type = 'h15;
            WRITECLEANFULL_CLEANSHAREDPERSISTSEP : smi_msg_type = 'h15;
        <%}%>
            //FIXME : add a default case to throw an error
        endcase
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
        if ((m_chi_req_pkt.opcode inside {WRITENOSNPFULL_CLEANINVALID, WRITEBACKFULL_CLEANINVALID}) && (wr_cmo_first_part_done == 1)) begin
                smi_msg_type = 'h9;
        end else if ((m_chi_req_pkt.opcode inside {WRITENOSNPFULL_CLEANSHARED, WRITEBACKFULL_CLEANSHARED, WRITECLEANFULL_CLEANSHARED}) && (wr_cmo_first_part_done == 1)) begin
                smi_msg_type = 'h8;
        end else if ((m_chi_req_pkt.opcode inside {WRITENOSNPFULL_CLEANSHAREDPERSISTSEP, WRITEBACKFULL_CLEANSHAREDPERSISTSEP, WRITECLEANFULL_CLEANSHAREDPERSISTSEP}) && (wr_cmo_first_part_done == 1)) begin
                smi_msg_type = CMD_CLN_SH_PER;
        end 
        <%}%>
        return smi_msg_type;
    endfunction : get_smi_msg_type

endclass : chi_aiu_scb_txn
